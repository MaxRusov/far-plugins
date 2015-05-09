{$I Defines.inc}

unit MoreHistoryMain;

{******************************************************************************}
{* (c) 2009-2011, Max Rusov                                                   *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    Far_API,
    FarCtrl,
    FarConMan,
    FarMenu,
    FarPlug,

    MoreHistoryCtrl,
    MoreHistoryListBase,
    MoreHistoryDlg,
    MoreHistoryEdtDlg,
   {$ifdef bCmdHistory}
    MoreHistoryCmdDlg,
   {$endif bCmdHistory}
    MoreHistoryClasses;

  type
    TMoreHistoryPlug = class(TFarPlug)
    public
      destructor Destroy; override;

      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
     {$endif Far3}
      function Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      function ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;

    private
      FLastFolder  :TString;
     {$ifdef Far3}
      FModEdtID    :Integer;
     {$endif Far3}

     {$ifdef Far3}
      FLastUpdate  :DWORD;
      FHistFilter  :TMyFilter;
      FIdxWhat     :Integer;
      FIdxType     :Integer;
      FIdxRevision :Integer;
      FIdxHidden   :Integer;
//    FIdxFilter   :TString;
     {$endif Far3}

     {$ifdef Far3}
      function MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;
     {$endif Far3}
    end;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  var
    FCallInProgress :Boolean;

 {-----------------------------------------------------------------------------}

  var
    hFarWindow  :THandle = THandle(-1);
    hConEmuWnd  :THandle = THandle(-1);


  function hConsoleWnd :THandle;
  var
    hWnd :THandle;
  begin
    Result := hFarWindow;
    if not IsWindowVisible(hFarWindow) then begin
      { Запущено из-под ConEmu?... }
      hWnd := GetAncestor(hFarWindow, GA_PARENT);

      if (hWnd = 0) or (hWnd = GetDesktopWindow) then begin
        { Новая версия ConEmu не делает SetParent... }
        if hConEmuWnd = THandle(-1) then
          hConEmuWnd := CheckConEmuWnd;
        hWnd := hConEmuWnd;
      end;

      if hWnd <> 0 then
        Result := hWnd;
    end;
  end;


  function IsActiveConsole :boolean;
  begin
    Result := WindowIsChildOf(hConsoleWnd, GetForegroundWindow) and ConManIsActiveConsole;
  end;


 {-----------------------------------------------------------------------------}
 { THistThread                                                                 }
 {-----------------------------------------------------------------------------}

  type
    THistThread = class(TThread)
    public
      constructor Create;
      destructor Destroy; override;
      procedure Execute; override;
    private
      FEvent :THandle;
    end;


  constructor THistThread.Create; {override;}
  begin
    inherited Create(False);
    FEvent := CreateEvent(nil, {ManualReset=}True, {InitialState=}False, nil);
  end;


  destructor THistThread.Destroy; {override;}
  begin
    CloseHandle(FEvent);
    inherited Destroy;
  end;


  procedure THistThread.Execute; {override;}
  var
//  vHandles :array[0..1] of THandle;
    vStr, vLastTitle :TString;
    vActive, vLastActive :Boolean;
    vRes :DWORD;
  begin
    vLastActive := False;
    vLastTitle := '';
//  FarHistory.RestoreHistory;

//  vHandles[0] := Fevent;
//  vHandles[1] := hStdIn;
    while not Terminated do begin
      vRes := WaitForSingleObject(FEvent, 100);
//    vRes := WaitForMultipleObjects( 2, Pointer(@vHandles), {WaitAll=}False, 5000);
//    TraceF('%d', [vRes]);
      if Terminated then
        Exit;

//    if CanCheckWindow then
//      { Контролируем смену консольного окна (на случай Detach'а консоли) }
//      hFarWindow := GetConsoleWindow;

      vActive := IsActiveConsole;
      if vActive <> vLastActive then begin
        if vActive then begin
//        Trace('Far Active Now...');
          vLastActive := True;
        end else
        begin
//        Trace('Go sleep...');
          FldHistory.TryLockAndStore;
          EdtHistory.TryLockAndStore;
         {$ifdef bCmdHistory}
          CmdHistory.TryLockAndStore;
         {$endif bCmdHistory}

          vLastActive := False;
        end;
      end;

      if vActive and not FCallInProgress then begin
        vStr := GetConsoleTitleStr;
        if vStr <> vLastTitle then begin
          vLastTitle := vStr;
          FCallInProgress := True;
//        TraceF('Call... (%s)', [vStr]);
          FarAdvControl(ACTL_SYNCHRO, nil);
        end;
      end;

      if vRes = WAIT_OBJECT_0 then
        ResetEvent(FEvent);
    end;

    NOP;
  end;


 {-----------------------------------------------------------------------------}

  var
    HistThread :THistThread;

  procedure SetHistoryWatcher(AOn :Boolean);
  begin
    if AOn <> (HistThread <> nil) then begin
      if AOn then
        HistThread := THistThread.Create
      else begin
        SetEvent(HistThread.FEvent);
        FreeObj(HistThread);
      end
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TPluginCmd = (
      pcFolderHistory,
      pcActiveHistory,
      pcEditorHistory,
      pcModifyHistory,
     {$ifdef bCmdHistory}
      pcCommandHistory,
      pcPrevCommand,
      pcNextCommand,
     {$endif bCmdHistory}
      pcOptions,
      pcNone
    );

    
  procedure RunCommand(ACmd :TPluginCmd; const AFilter :TString = '';
     AGroup :Integer = MaxInt; ASort :Integer = MaxInt; AHidden :Integer = MaxInt);

   {$ifdef bCmdHistory}
    function LocGetCmdStr :TString;
    begin
      if AFilter <> '' then
        Result := AFilter
      else
        Result := FarPanelString(PANEL_NONE, FCTL_GETCMDLINE);
    end;
   {$endif bCmdHistory}

  begin
    case ACmd of
      pcFolderHistory:  OpenHistoryDlg1(GetMsg(strFoldersHistoryTitle), 'Folders\All', 0, AFilter, AGroup, ASort, AHidden);
      pcActiveHistory:  OpenHistoryDlg1(GetMsg(strActFoldersHistoryTitle), 'Folders\Active', 1, AFilter, AGroup, ASort, AHidden);
      pcEditorHistory:  OpenEdtHistoryDlg1(GetMsg(strViewEditHistoryTitle), 'Files\View', 0, AFilter, AGroup, ASort, AHidden);
      pcModifyHistory:  OpenEdtHistoryDlg1(GetMsg(strModifyHistoryTitle), 'Files\Modify', 1, AFilter, AGroup, ASort, AHidden);
     {$ifdef bCmdHistory}
      pcCommandHistory: OpenCmdHistoryDlg1(GetMsg(strCommandHistoryTitle), 'Commands', CmdHistory.CmdLineFilter(LocGetCmdStr), AGroup, ASort, AHidden );
      pcPrevCommand:    CmdHistory.CmdLineNext(False, LocGetCmdStr);
      pcNextCommand:    CmdHistory.CmdLineNext(True, LocGetCmdStr);
     {$endif bCmdHistory}
      pcOptions:        OptionsMenu;
    end;
  end;


  procedure OpenMenu;
  var
    vMenu :TFarMenu;
    vWinInfo :TWindowInfo;
  begin
    FarGetWindowInfo(-1, vWinInfo);

    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMFoldersHistory),
      GetMsg(strMActFoldersHistory),
      '',
      GetMsg(strMViewEditHistory),
      GetMsg(strMModifyHistory),

     {$ifdef bCmdHistory}
      '',
      GetMsg(strMCommandHistory),
      GetMsg(strMPreviousCommand),
      GetMsg(strMNextCommand),
     {$endif bCmdHistory}

      '',
      GetMsg(strMOptions1)
    ]);
    try
     {$ifdef bCmdHistory}
      vMenu.Enabled[6] := vWinInfo.WindowType = WTYPE_PANELS;
      vMenu.Enabled[7] := vWinInfo.WindowType = WTYPE_PANELS;
     {$endif bCmdHistory}

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : RunCommand(pcFolderHistory);
        1 : RunCommand(pcActiveHistory);

        3 : RunCommand(pcEditorHistory);
        4 : RunCommand(pcModifyHistory);

       {$ifdef bCmdHistory}
        6 : RunCommand(pcCommandHistory);
        7 : RunCommand(pcNextCommand);
        8 : RunCommand(pcPrevCommand);
       {$endif bCmdHistory}

      else
        RunCommand(pcOptions);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;

 {-----------------------------------------------------------------------------}
 { TMoreHistoryPlug                                                            }
 {-----------------------------------------------------------------------------}

  destructor TMoreHistoryPlug.Destroy; {override;}
  begin
   {$ifdef Far3}
    FreeObj(FHistFilter);
   {$endif Far3}
    inherited Destroy;
  end;


  procedure TMoreHistoryPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
    FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
//  FMinFarVer := MakeVersion(3, 0, 2343);   { FCTL_GETPANELDIRECTORY/FCTL_SETPANELDIRECTORY }
//  FMinFarVer := MakeVersion(3, 0, 2460);   { OPEN_FROMMACRO }
//  FMinFarVer := MakeVersion(3, 0, 2572);   { Api changes }
//  FMinFarVer := MakeVersion(3, 0, 2851);   { LUA }
    FMinFarVer := MakeVersion(3, 0, 3000);   { Stable }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1573);   { ACTL_GETFARRECT }
   {$endif Far3}

   {$ifdef Far3}
    FModEdtID := -1;
   {$endif Far3}
  end;


  procedure TMoreHistoryPlug.Startup; {override;}
  begin
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    { Получаем Handle консоли Far'а }
    hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);

    RestoreDefColor;
    ReadSettings;

    FldHistory := TFldHistory.Create;
    EdtHistory := TEdtHistory.Create;
   {$ifdef bCmdHistory}
    CmdHistory := TCmdHistory.Create;
   {$endif bCmdHistory}

   {$ifdef Far3}
    FHistFilter := TMyFilter.Create;
    FIdxWhat := -1;
   {$endif Far3}

    SetHistoryWatcher(True);
  end;


  procedure TMoreHistoryPlug.ExitFar; {override;}
  begin
    SetHistoryWatcher(False);
    
    FldHistory.StoreModifiedHistory;
    EdtHistory.StoreModifiedHistory;
   {$ifdef bCmdHistory}
    CmdHistory.StoreModifiedHistory;
   {$endif bCmdHistory}

    FreeObj(FldHistory);
    FreeObj(EdtHistory);
   {$ifdef bCmdHistory}
    FreeObj(CmdHistory);
   {$endif bCmdHistory}
  end;


  procedure TMoreHistoryPlug.GetInfo; {override;}
  begin
    FFlags := PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG or PF_FULLCMDLINE;
    FPrefix := cPrefixes;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID  := cConfigID;
   {$endif Far3}
  end;


  function TMoreHistoryPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    OpenMenu;
  end;


  function TMoreHistoryPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vStr :TString;
    vCmd :TPluginCmd;
  begin
    Result:= INVALID_HANDLE_VALUE;
    vStr := AStr;

    if UpCompareSubStr(cFldPrefix + ':', vStr) = 0 then
      vCmd := pcFolderHistory
    else
    if UpCompareSubStr(cEdtPrefix + ':', vStr) = 0 then
      vCmd := pcEditorHistory
   {$ifdef bCmdHistory}
    else
    if UpCompareSubStr(cCmdPrefix + ':', vStr) = 0 then
      vCmd := pcCommandHistory
   {$endif bCmdHistory}
    else
      Exit;
      
    RunCommand(vCmd, ExtractWords(2, MaxInt, vStr, [':']));
  end;


  function TMoreHistoryPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    if (AInt >= 1) and (AInt <= Byte(High(TPluginCmd))) then begin
     {$ifdef Far3}
      RunCommand(TPluginCmd(AInt - 1));
     {$else}
      FarAdvControl(ACTL_SYNCHRO, Pointer(AInt));
     {$endif Far3}
      Exit;
    end;
    OpenMenu;
  end;


 {$ifdef Far3}
  function TMoreHistoryPlug.OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {override;}
  begin
    Result := 0;
    if (ACount = 0) or ((ACount = 1) and (AParams[0].fType in [FMVT_INTEGER, FMVT_DOUBLE])) then
      Result := inherited OpenMacroEx(ACount, AParams)
    else
    if AParams[0].fType = FMVT_STRING then
      Result := MacroCommand(AParams[0].Value.fString, ACount, AParams);
  end;

  const
    kwShowFolderHist  = 1;
    kwShowEditorHist  = 2;
    kwShowCommandHist = 3;

    kwFolderHist      = 4;
    kwEditorHist      = 5;
    kwCommandHist     = 6;

    kwNextCommand     = 7;
    kwPrevCommand     = 8;

    kwGotoFolder      = 9;
    kwOpenEditor      = 10;

  var
    CmdWords :TKeywordsList;

  procedure InitKeywords;
  begin
    if CmdWords <> nil then
      Exit;

    CmdWords := TKeywordsList.Create;
    with CmdWords do begin
      Add('OpenFolderHistory', kwShowFolderHist);
      Add('OpenEditorHistory', kwShowEditorHist);
      Add('OpenCommandHistory', kwShowCommandHist);

      Add('FolderHistory', kwFolderHist);
      Add('EditorHistory', kwEditorHist);
      Add('CommandHistory', kwCommandHist);

      Add('NextCommand', kwNextCommand);
      Add('PrevCommand', kwPrevCommand);

      Add('GotoFolder', kwGotoFolder);
      Add('OpenEditor', kwOpenEditor);
    end;
  end;


  function TMoreHistoryPlug.MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;

    procedure LocIndexHistory(AHist :THistory; AWhat, AType, AHidden :Integer);
    var
      I :Integer;
      vItem :THistoryEntry;
      vAdd :Boolean;
    begin
      if (AWhat = FIdxWhat) and (AType = FIdxType) and (AHist.Revision = FIdxRevision) and (FIdxHidden = AHidden) then
        Exit;

      FHistFilter.History := AHist;
      FHistFilter.Clear;
      for I := AHist.History.Count - 1 downto 0 do begin
        vItem := AHist[I];
        vAdd := True;
        if (AWhat = 0) and (AType = 1) then
          vAdd := TFldHistoryEntry(vItem).IsActive;
        if (AWhat = 1) and (AType = 1) then
          vAdd := TEdtHistoryEntry(vItem).EdtTime <> 0;
        if vAdd then
          FHistFilter.Add(I, 0, 0);
      end;
      if (AWhat in [0, 1]) and (AType = 1) then
        FHistFilter.SortList(True, -4 {By ModTime} );

      FIdxRevision := AHist.Revision;
      FIdxHidden := AHidden;
      FIdxType := AType;
      FIdxWhat := AWhat;
    end;


    procedure LocInitFilter(AWhat, AType, AHidden :Integer);
    var
      vHist :THistory;
      vTick :DWORD;
    begin
      vHist := nil;
      case AWhat of
        0 : vHist := FldHistory;
        1 : vHist := EdtHistory;
       {$ifdef bCmdHistory}
        2 : vHist := CmdHistory;
       {$endif bCmdHistory}
      else
        Wrong;
      end;

      vTick := GetTickCount;
      if (FLastUpdate = 0) or (TickCountDiff(vTick, FLastUpdate) > 100) then begin
        vHist.LoadModifiedHistory;
       {$ifdef bCmdHistory}
        if vHist is TCmdHistory then
          TCmdHistory(vHist).UpdateHistory;
       {$endif bCmdHistory}
        FLastUpdate := vTick;
      end;

      LocIndexHistory(vHist, AWhat, AType, AHidden);
    end;


    function LocHistory(AWhat :Integer) :TIntPtr;
    var
      vType, vIdx :Integer;
    begin
      Result := 0;

      vType := FarValuesToInt(AParams, ACount, 1, 0);
      vIdx := FarValuesToInt(AParams, ACount, 2, -1);

      LocInitFilter(AWhat, vType, 0);

      if vIdx = -1 then
        Result := FarReturnValues([FHistFilter.Count])
      else begin
        if (vIdx >= 0) and (vIdx < FHistFilter.Count) then
          with FHistFilter.History[FHistFilter[vIdx]] do
            Result := FarReturnValues([Path]);
      end;
    end;


    procedure GotoFolder;
    var
      vType, vIdx :Integer;
    begin
      vType := FarValuesToInt(AParams, ACount, 1, 0);
      vIdx := FarValuesToInt(AParams, ACount, 2, 0);
      LocInitFilter(0, vType, 0);
      if (vIdx >= 0) and (vIdx < FHistFilter.Count) then
        JumpToPathBy( FHistFilter.History[FHistFilter[vIdx]] as TFldHistoryEntry, False, False);
    end;


    procedure OpenEditor;
    var
      vType, vIdx :Integer;
    begin
      vType := FarValuesToInt(AParams, ACount, 1, 0);
      vIdx := FarValuesToInt(AParams, ACount, 2, 0);
      LocInitFilter(1, vType, 0);
      if (vIdx >= 0) and (vIdx < FHistFilter.Count) then
        OpenEditorBy( FHistFilter.History[FHistFilter[vIdx]] as TEdtHistoryEntry, vType = 1);
    end;


    procedure LocOpenHistory(AWhat :Integer);
    const
      cCommands :array[0..2] of TPluginCmd =
        (pcFolderHistory, pcEditorHistory, {$ifdef bCmdHistory}pcCommandHistory{$else}pcNone {$endif bCmdHistory});
    var
      vFilter :TString;
      vType, vGroup, vSort, vHidden :Integer;
      vCmd :TPluginCmd;
    begin
      vType := FarValuesToInt(AParams, ACount, 1, 0);

      vFilter := FarValuesToStr(AParams, ACount, 2, #0);
      vFilter := StrIf(vFilter = #0, '', StrIf(vFilter = '', #0, vFilter));

      vGroup := FarValuesToInt(AParams, ACount, 3, MaxInt);
      vSort := FarValuesToInt(AParams, ACount, 4, MaxInt);
      vHidden := FarValuesToInt(AParams, ACount, 5, MaxInt);

      vCmd := cCommands[AWhat];
      if vType = 1 then
        Inc(vCmd);
      RunCommand(vCmd, vFilter, vGroup, vSort, vHidden);
    end;


  var
    vCmd :Integer;
  begin
    Result := 1;
    InitKeywords;
    vCmd := CmdWords.GetKeywordStr(ACmd);
    case vCmd of
      kwShowFolderHist, kwShowEditorHist, kwShowCommandHist:
        LocOpenHistory(vCmd - kwShowFolderHist);
      kwFolderHist, kwEditorHist, kwCommandHist:
        Result := LocHistory(vCmd - kwFolderHist);
     {$ifdef bCmdHistory}
      kwNextCommand:
        RunCommand(pcNextCommand);
      kwPrevCommand:
        RunCommand(pcPrevCommand);
     {$endif bCmdHistory}
      kwGotoFolder:
        GotoFolder;
      kwOpenEditor:
        OpenEditor;
    else
      Result := 0;
    end;
  end;
 {$endif Far3}


  procedure TMoreHistoryPlug.Configure; {override;}
  begin
    ReadSetup('');
    OptionsMenu;
  end;


  procedure TMoreHistoryPlug.SynchroEvent(AParam :Pointer); {override;}
  var
    vStr :TString;
  begin
    try
      if AParam <> nil then
        { Асинхронная команда }
        RunCommand(TPluginCmd(TUnsPtr(AParam) - 1))
      else begin
        { Pool текущего каталога }

        { История не должна меняться, пока активен диалог }
        if HistDlgOpened then
          Exit;

        FldHistory.LockHistory;
        try
          FldHistory.LoadModifiedHistory;

          vStr := GetCurrentPanelPath;
          if vStr <> '' then begin
//          TraceF('Add: %s', [vStr]);
            if vStr <> FLastFolder then begin
              FldHistory.AddHistory(vStr, faEnter);
              FLastFolder := vStr;
            end;
          end else
          if FLastFolder <> '' then begin
            { Текущий контекст - не панель (редактор, viewer, dialog): }
            { считаем активным действием в последнем  каталоге }
            FldHistory.AddHistory(FLastFolder, faActivity);
            FldHistory.RememberCurrentPos;
          end;

        finally
          FldHistory.UnlockHistory;
        end;
      end;

    finally
      FCallInProgress := False;
    end;
  end;


  function TMoreHistoryPlug.EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  var
    vName :TString;
    vInfo :TEditorInfo;
    vAction :TEdtAction;
    vRow, vCol :Integer;
  begin
//  TraceF('ProcessEditorEvent: %d, %x', [AEvent, TIntPtr(AParam)]);
    Result := 0;
    case AEvent of
      EE_READ     :
        begin
          FarEditorSubscribeChangeEvent(-1{AID}, True);
          vAction := eaOpenEdit;
        end;
      EE_SAVE     : vAction := eaSaveEdit;
      EE_GOTFOCUS : vAction := eaGotFocus;
     {$ifdef Far3}
      EE_CHANGE:
        with PEditorChange(AParam)^ do begin
//        TraceF('EE_CHANGE: Type=%d, Row=%d', [_Type, StringNumber]);
          { Из события EE_CHANGE нельзя вызывать EditorControl, да и вообще - }
          { оно должно быть максимально быстрым, чтобы не замедлять модификацию файла... }
          FModEdtID := AID;
          Exit;
        end;
      EE_REDRAW:
        if FModEdtID = AID then begin
          FModEdtID := -1;
          vAction := eaModify
        end else
          Exit;
     {$else}
      EE_REDRAW   :
        if AParam = EEREDRAW_CHANGE then
          vAction := eaModify
        else
          Exit;
     {$endif Far3}
    else
      Exit;
    end;

    vName := EditorControlString(ECTL_GETFILENAME);
    EdtHistory.LockHistory;
    try
      vRow := 0; vCol := 0;
      if vAction = eaModify then begin
        FillZero(vInfo, SizeOf(vInfo));
       {$ifdef Far3}
        vInfo.StructSize := SizeOf(vInfo);
       {$endif Far3}
        if FarEditorControl(ECTL_GETINFO, @vInfo) <> 1 then
          Exit;
        vRow := vInfo.CurLine + 1;
        vCol := vInfo.CurPos + 1;
      end;

      EdtHistory.LoadModifiedHistory;
      EdtHistory.AddHistory(vName, vAction, vRow, vCol);
    finally
      EdtHistory.UnlockHistory;
    end;
  end;


  function TMoreHistoryPlug.ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  var
    vName :TString;
    vInfo :TViewerInfo;
    vAction :TEdtAction;
    vQuickView :Boolean;
  begin
//  TraceF('ProcessViewerEvent: %d, %x', [AEvent, TIntPtr(AParam)]);
    Result := 0;
    case AEvent of
      VE_READ     : vAction := eaOpenView;
      VE_GOTFOCUS : vAction := eaGotFocus;
    else
      Exit;
    end;

    FillZero(vInfo, SizeOf(vInfo));
    vInfo.StructSize := SizeOf(vInfo);
    FarViewerControl(VCTL_GetInfo, @vInfo);
   {$ifdef Far3}
    vName := ViewerControlString(VCTL_GETFILENAME);
   {$else}
    vName := FarChar2Str(vInfo.FileName);
   {$endif Far3}

    vQuickView := vInfo.WindowSizeX < FarGetWindowSize.cx;
    if vQuickView and optSkipQuickView then
      Exit;

    EdtHistory.LockHistory;
    try
      EdtHistory.LoadModifiedHistory;
      EdtHistory.AddHistory(vName, vAction, 0, 0);
    finally
      EdtHistory.UnlockHistory;
    end;
  end;


  function TMoreHistoryPlug.Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :THandle; {override;}
  begin
    if (AMode and OPM_FIND = 0) and (GetCurrentThreadID = MainThreadID) then begin
      FldHistory.AddCurrentToHistory;
//    if optCmdExcludeFile then
//      GSkipFile := AName;
    end;
    Result := INVALID_HANDLE_VALUE;
  end;


initialization
finalization
 {$ifdef Far3}
  FreeObj(CmdWords);
 {$endif Far3}
  FreeObj(HistThread);
end.


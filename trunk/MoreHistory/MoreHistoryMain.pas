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
    MoreHistoryDlg,
    MoreHistoryEdtDlg,
   {$ifdef bCmdHistory}
    MoreHistoryCmdDlg,
   {$endif bCmdHistory}
    MoreHistoryClasses;

  type
    TMoreHistoryPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
      function Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      function ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;

    private
     {$ifdef Far3}
      FModEdtID :Integer;
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
      pcEditorHistory,
      pcModifyHistory,
     {$ifdef bCmdHistory}
      pcCommandHistory,
      pcPrevCommand,
      pcNextCommand,
     {$endif bCmdHistory}
      pcOptions
    );


  procedure RunCommand(ACmd :TPluginCmd; const AStr :TString = '');

   {$ifdef bCmdHistory}
    function LocGetCmdStr :TString;
    begin
      if AStr <> '' then
        Result := AStr
      else
        Result := FarPanelString(PANEL_NONE, FCTL_GETCMDLINE);
    end;
   {$endif bCmdHistory}

  begin
    case ACmd of
      pcFolderHistory:  OpenHistoryDlg(GetMsg(strFoldersHistoryTitle), 'Folders', 0, AStr);
      pcEditorHistory:  OpenEdtHistoryDlg(GetMsg(strViewEditHistoryTitle), 'Files\View', 0, AStr);
      pcModifyHistory:  OpenEdtHistoryDlg(GetMsg(strModifyHistoryTitle), 'Files\Modify', 1, AStr);
     {$ifdef bCmdHistory}
      pcCommandHistory: OpenCmdHistoryDlg(GetMsg(strCommandHistoryTitle), 'Commands', CmdHistory.CmdLineFilter(LocGetCmdStr) );
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

        2 : RunCommand(pcEditorHistory);
        3 : RunCommand(pcModifyHistory);

       {$ifdef bCmdHistory}
        5 : RunCommand(pcCommandHistory);
        6 : RunCommand(pcNextCommand);
        7 : RunCommand(pcPrevCommand);
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
    FMinFarVer := MakeVersion(3, 0, 2851);   { LUA }
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

    FldHistory.AddCurrentToHistory;
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
//   {$ifdef Far3}
//    RunCommand(TPluginCmd(AInt - 1));
//   {$else}
      FarAdvControl(ACTL_SYNCHRO, Pointer(AInt));
//   {$endif Far3}
      Exit;
    end;
    OpenMenu;
  end;


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
            FldHistory.AddHistory(vStr, False);
          end else
          if GLastAdded <> '' then begin
            vStr := GLastAdded;
            FldHistory.AddHistory(vStr, True);
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
      EE_READ     : vAction := eaOpenEdit;
      EE_SAVE     : vAction := eaSaveEdit;
      EE_GOTFOCUS : vAction := eaGotFocus;
     {$ifdef Far3}
      EE_CHANGE:
        begin
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
    if (AMode and OPM_FIND = 0) and (GetCurrentThreadID = MainThreadID) then
      FldHistory.AddCurrentToHistory;
    Result := INVALID_HANDLE_VALUE;
  end;


initialization
finalization
  FreeObj(HistThread);
end.


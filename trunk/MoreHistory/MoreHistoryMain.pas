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
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

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
      function Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :Integer; override;
      procedure SynchroEvent(AParam :Pointer); override;
      function EditorEvent(AEvent :Integer; AParam :Pointer) :Integer; override;
      function ViewerEvent(AEvent :Integer; AParam :Pointer) :Integer; override;
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

  
  procedure OpenCmdLine(const AStr :TString);
  var
    vStr :TString;
  begin
    vStr := ExtractWords(2, MaxInt, AStr, [':']);

    if UpCompareSubStr(cFldPrefix + ':', AStr) = 0 then
      RunCommand(pcFolderHistory, vStr)
    else
    if UpCompareSubStr(cEdtPrefix + ':', AStr) = 0 then
      RunCommand(pcEditorHistory, vStr)
   {$ifdef bCmdHistory}
    else
    if UpCompareSubStr(cCmdPrefix + ':', AStr) = 0 then
      RunCommand(pcCommandHistory, vStr)
   {$endif bCmdHistory}
    ;
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

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
    FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
    FMinFarVer := MakeVersion(3, 0, 2343);   { FCTL_GETPANELDIRECTORY/FCTL_SETPANELDIRECTORY }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1573);   { ACTL_GETFARRECT }
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
    if AFrom and OPEN_FROMMACRO <> 0 then begin

      if AFrom and OPEN_FROMMACROSTRING <> 0 then
        {!!!}
      else
      if (AParam >= 1) and (AParam <= Byte(High(TPluginCmd))) then
//      RunCommand(TPluginCmd(AParam - 1))
        FarAdvControl(ACTL_SYNCHRO, Pointer(AParam))
      else
        OpenMenu;

    end else
    if AFrom = OPEN_COMMANDLINE then
      OpenCmdLine(PFarChar(AParam))
    else
      OpenMenu;
    Result := INVALID_HANDLE_VALUE;
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


  function TMoreHistoryPlug.EditorEvent(AEvent :Integer; AParam :Pointer) :Integer; {override;}
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
      EE_REDRAW   :
        if AParam = EEREDRAW_CHANGE then
          vAction := eaModify
        else
          Exit;
    else
      Exit;
    end;

    vName := EditorControlString(ECTL_GETFILENAME);
    EdtHistory.LockHistory;
    try
      vRow := 0; vCol := 0;
      if vAction = eaModify then begin
        FillZero(vInfo, SizeOf(vInfo));
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


  function TMoreHistoryPlug.ViewerEvent(AEvent :Integer; AParam :Pointer) :Integer; {override;}
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
    vName := FarChar2Str(vInfo.FileName);

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


  function TMoreHistoryPlug.Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :Integer; {override;}
  begin
    FldHistory.AddCurrentToHistory;
    Result := 0;
  end;


initialization
finalization
  FreeObj(HistThread);
end.


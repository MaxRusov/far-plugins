{$I Defines.inc}

unit MoreHistoryMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    PluginW,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    FarCtrl,
    FarConMan,
    FarMenu,

    MoreHistoryCtrl,
    MoreHistoryClasses,
    MoreHistoryDlg,
    MoreHistoryEdtDlg;


  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function OpenFilePluginW(const AName :PTChar; Data :Pointer; DataSize :Integer; OpMode :Integer) :THandle; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  function ProcessViewerEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;


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

          if FldHistory.TryLockHistory then begin
            try
              try
                FldHistory.StoreModifiedHistory;
              except
              end;
            finally
              FldHistory.UnlockHistory;
            end;
          end;

          if EdtHistory.TryLockHistory then begin
            try
              try
                EdtHistory.StoreModifiedHistory;
              except
              end;
            finally
              EdtHistory.UnlockHistory;
            end;
          end;

          vLastActive := False;
        end;
      end;

      if vActive and not FCallInProgress then begin
        vStr := GetConsoleTitleStr;
        if vStr <> vLastTitle then begin
          vLastTitle := vStr;
          FCallInProgress := True;
//        TraceF('Call... (%s)', [vStr]);
          FARAPI.AdvControl(hModule, ACTL_SYNCHRO, nil);
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

  procedure OpenMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMFoldersHistory),
      '',
      GetMsg(strMViewEditHistory),
      GetMsg(strMModifyHistory),
      '',
      GetMsg(strMOptions1)
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : OpenHistoryDlg(GetMsg(strFoldersHistoryTitle), 'Folders', 0, '');

        2 : OpenEdtHistoryDlg(GetMsg(strViewEditHistoryTitle), 'Files\View', 0, '');
        3 : OpenEdtHistoryDlg(GetMsg(strModifyHistoryTitle), 'Files\Modify', 1, '');

        5 : OptionsMenu;
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
      OpenHistoryDlg(GetMsg(strFoldersHistoryTitle), 'Folders', 0, vStr)
    else
    if UpCompareSubStr(cEdtPrefix + ':', AStr) = 0 then
      OpenEdtHistoryDlg(GetMsg(strViewEditHistoryTitle), 'Files\View', 0, vStr);
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  function GetMinFarVersionW :Integer; stdcall;
  begin
    Result := MakeFarVersion(2, 0, 1573);   { ACTL_GETFARRECT }
  end;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    FARAPI := psi;
    FARSTD := psi.fsf^;

    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

    { Получаем Handle консоли Far'а }
    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);

//  InitConsoleProc;
//  hConWindow := GetConsoleWindow;
//  CanCheckWindow := GetConsoleWindow = hFarWindow;

    RestoreDefColor;
    ReadSettings;

    FldHistory := TFldHistory.Create;
    EdtHistory := TEdtHistory.Create;
    SetHistoryWatcher(True);
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;
    ConfigMenuStrings: array[0..0] of PFarChar;

  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);

    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG or PF_FULLCMDLINE;

    PluginMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginMenuStrings:= Pointer(@PluginMenuStrings);
    pi.PluginMenuStringsNumber:= 1;

    ConfigMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginConfigStrings := Pointer(@ConfigMenuStrings);
    pi.PluginConfigStringsNumber := 1;

    pi.CommandPrefix := PFarChar(cPrefixes);

    FldHistory.AddCurrentToHistory;
  end;


  procedure ExitFARW; stdcall;
  begin
//  Trace('ExitFAR');
    SetHistoryWatcher(False);
    FldHistory.StoreModifiedHistory;
    EdtHistory.StoreModifiedHistory;
    FreeObj(FldHistory);
    FreeObj(EdtHistory);
  end;


  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  begin
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
    Result:= INVALID_HANDLE_VALUE;
    try
      if OpenFrom = OPEN_COMMANDLINE then
        OpenCmdLine(StrOEMToAnsi(PFarChar(Item)))
      else
        OpenMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function OpenFilePluginW(const AName :PTChar; Data :Pointer; DataSize :Integer; OpMode :Integer) :THandle; stdcall;
  begin
//  TraceF('OpenFilePluginW: %s', [AName]);
    Result:= INVALID_HANDLE_VALUE;
    FldHistory.AddCurrentToHistory;
  end;


  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    Result := 1;
    try
      ReadSetup('');
      OptionsMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


(*
  function ProcessEditorInputW(const ARec :INPUT_RECORD) :Integer; stdcall;
  begin
//  TraceF('ProcessEditorInputW: Event=%d', [ARec.EventType]);
    if ARec.EventType = 0 then begin
      {???}
    end else
    if ARec.EventType = KEY_EVENT then begin
      with ARec.Event.KeyEvent do begin
        if bKeyDown and not (wVirtualKeyCode in [0, VK_SHIFT, VK_CONTROL, VK_MENU]) then begin
//        TraceF('ProcessEditorInputW (KEY_EVENT): Press=%d, Key=%d', [Byte(bKeyDown), wVirtualKeyCode]);
          EdtClearMark(not optPersistMatch);
        end;
      end;
    end else
    if ARec.EventType = _MOUSE_EVENT then begin
      with ARec.Event.MouseEvent do
        if MOUSE_MOVED and dwEventFlags = 0 then begin
//        TraceF('ProcessEditorInputW (MOUSE_EVENT): Flags=%d', [dwEventFlags]);
          EdtClearMark(not optPersistMatch);
        end
    end;
    Result := 0;
  end;
*)


  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
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
        if FARAPI.EditorControl(ECTL_GETINFO, @vInfo) <> 1 then
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


  function ProcessViewerEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
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
    FARAPI.ViewerControl(VCTL_GetInfo, @vInfo);
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


  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  var
    vStr :TString;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);
    Result := 0;
    try
      if Event <> SE_COMMONSYNCHRO then
        Exit;

      { История не должна меняться, пока активен диалог }
      if HistDlgOpened then
        Exit;

      FldHistory.LockHistory;
      try
        FldHistory.LoadModifiedHistory;

        vStr := GetCurrentPanelPath;
        if vStr <> '' then begin
//        TraceF('Add: %s', [vStr]);
          FldHistory.AddHistory(vStr, False);
        end else
        if GLastAdded <> '' then begin
          vStr := GLastAdded;
          FldHistory.AddHistory(vStr, True);
        end;

      finally
        FldHistory.UnlockHistory;
      end;

    finally
      FCallInProgress := False;
    end;
  end;



initialization
finalization
  FreeObj(HistThread);
end.


{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}
{$Typedaddress Off}

unit PanelTabsMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

   {$ifdef bUnicodeFar}
    PluginW,
    FarKeysW,
   {$else}
    Plugin,
    FarKeys,
   {$endif bUnicodeFar}
    FarCtrl,
    FarConMan,
    PanelTabsCtrl,
    PanelTabsClasses;


 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  procedure ExitFAR; stdcall;
  function OpenPlugin(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function Configure(Item: integer) :Integer; stdcall;
 {$endif bUnicodeFar}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}

  var
    GlobalCommand  :Integer;


  function IsActiveConsole :boolean;
  begin
    Result := WindowIsChildOf(hConsoleWnd, GetForegroundWindow) and ConManIsActiveConsole;
  end;


  function AlertableSleep(APeriod :Cardinal) :Boolean;
  begin
    Result := WaitForSingleObject(hStdin, APeriod) <> WAIT_TIMEOUT;
  end;


  procedure SendKeys(AKey, ACtrl :Word);
  var
    vRec :array[0..1] of INPUT_RECORD;
    vRes :DWORD;
  begin
    FillChar(vRec, SizeOf(vRec), 0);
    with vRec[0], Event.KeyEvent do begin
      EventType := KEY_EVENT;
      bKeyDown := True;
      wVirtualKeyCode := AKey;
      dwControlKeyState := ACtrl;
    end;
    with vRec[1], Event.KeyEvent do begin
      EventType := KEY_EVENT;
      bKeyDown := False;
    end;
    WriteConsoleInput(hStdin, vRec[0], 2, vRes);
  end;


  type
    TEventType = (
      cetKeyDown,
      cetKeyUp,
      cetPrefixKeyDown,
      cetMouseMove,
      cetMousePress,
      cetOther
    );
    TEventTypes = set of TEventType;


  function CheckInput :TEventTypes;
  var
    I, vCount :Integer;
    vEventType :TEventType;
    vBuf :array[0..16] of Windows.TInputRecord;
  begin
    Result := [];
    if PeekConsoleInput(hStdin, vBuf[0], High(vBuf), DWORD(vCount)) then begin
      for I := 0 to vCount - 1 do begin
        with vBuf[I] do begin
          case EventType of
            KEY_EVENT:
              with Event.KeyEvent do
                if bKeyDown then begin
                  if wVirtualKeyCode in [VK_Shift, VK_Control, VK_Menu] then
                    vEventType := cetPrefixKeyDown
                  else
                    vEventType := cetKeyDown
                end else
                  vEventType := cetKeyUp;
            _MOUSE_EVENT:
              with Event.MouseEvent do
                if (MOUSE_MOVED and dwEventFlags = 0) or (dwButtonState <> 0) then
                  vEventType := cetMousePress
                else
                  vEventType := cetMouseMove
          else
            vEventType := cetOther;
          end;
        end;
        Result := Result + [vEventType];
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { THistThread                                                                 }
 {-----------------------------------------------------------------------------}

  type
    TTabsThread = class(TThread)
    public
      procedure Execute; override;
      function CallPlugin(ACmd :Integer) :Boolean;
    end;


  procedure TTabsThread.Execute; {override;}
  const
   {$ifdef bUnicodeFar}
    cRetryPeriod = 0;
   {$else}
    cRetryPeriod = 300;
   {$endif bUnicodeFar}
  var
    vInput :TEventTypes;
    vTitle, vLastTitle :TString;
    vWasInput :Boolean;
    vPoint :TPoint;
    vIndex :Integer;
    vKind :TTabKind;
    X, Y :Integer;
    vTick :DWORD;
    vCh :TChar;
  begin
    vLastTitle := '';
    vWasInput := False;

    while not Terminated do begin

      if ((GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0)) and IsActiveConsole then begin
        vPoint := GetConsoleMousePos;
//      TraceF('Mouse down: %d x %d...', [vPoint.X, vPoint.Y]);
        if TabsManager.HitTest(vPoint.X, vPoint.Y, vKind, vIndex) <> hsNone then
          CallPlugin(2);
        while not Terminated and ((GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0)) do
          Sleep(10);
//      Trace('Mouse Up.');
      end else
      begin
        vInput := CheckInput;
//      TraceF('Input=%d, WasInput=%d', [Byte(vInput), Byte(vWasInput)]);

        if vInput = [] then begin
          vTitle := GetConsoleTitleStr;
          if vTitle <> vLastTitle then begin
//          Trace('Title changed...');
            vLastTitle := vTitle;
            CallPlugin(1);
            vWasInput := False;
          end else
          begin
            if TabsManager.NeedCheck(X, Y) then begin
              vCh := ReadScreenChar(X, Y);

              if vCh <> '+' then begin
//              Trace('Screen need repaint...');
                CallPlugin(1);
              end;
              vWasInput := False;
            end else
            if vWasInput then begin

              vTick := GetTickCount;
              while not Terminated and (TickCountDiff(GetTickCount, vTick) < cRetryPeriod) do begin
                vInput := CheckInput;
                if vInput <> [] then
                  Break;
              end;

              if vInput = [] then begin
//              Trace('Possible need repaint???...');
                CallPlugin(1);
                vWasInput := False;
              end;

            end;
          end;
        end else
          vWasInput := vWasInput or ([cetKeyDown{, cetKeyUp}] * vInput <> []);

        if (vInput <> []) or vWasInput then begin
          Sleep(10)
        end else
        if AlertableSleep(1000) then begin
//        Trace('Alert!');
        end;
      end;

    end;
  end;



 {$ifdef bUnicodeFar}
  function TTabsThread.CallPlugin(ACmd :Integer) :Boolean;
  begin
    Result := False;
//  Trace('Can call?');
    if not TabsManager.CanPaintTabs(True) then begin
//    Trace('Can not paint...');
      Exit;
    end;

//  TraceF('Call plugin: ACmd=%d', [ACmd]);
    FARAPI.AdvControl(hModule, ACTL_SYNCHRO, Pointer(TIntPtr(ACmd)));
  end;

 {$else}

  function TTabsThread.CallPlugin(ACmd :Integer) :Boolean;
  var
    vKey, vCtrl :Word;
  begin
    Result := False;

    vKey  := TabKey1;
    vCtrl := TabShift1;
    if vKey = 0 then
      Exit;

    if not TabsManager.CanPaintTabs(True) then
      Exit;

//  TraceF('Call plugin: ACmd=%d', [ACmd]);
    GlobalCommand := ACmd;
    { Вызовем плагин в основном потоке, через механизм макросов... }
    SendKeys(vKey, vCtrl);

    { Ждем пока посланое сообщение не будет выбрано из буфера }
    while not Terminated and ([cetKeyDown, cetKeyUp] * CheckInput <> []) do
      Sleep(1);

    Result := True;
  end;
 {$endif bUnicodeFar}


 {-----------------------------------------------------------------------------}

  var
    TabsThread :TTabsThread;

  procedure SetTabsThread(AOn :Boolean);
  begin
    if AOn <> (TabsThread <> nil) then begin
      if AOn then begin
        TabsThread := TTabsThread.Create(False);
      end else
      begin
        FreeObj(TabsThread);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  const
    cMenuCount = 3;
  var
    vRes, I :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strMShowTabs));
      SetMenuItemChrEx(vItem, GetMsg(strMShowNumbers));
//    SetMenuItemChrEx(vItem, GetMsg(strMShowButton));
      SetMenuItemChrEx(vItem, GetMsg(strMSeparateTabs));

      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, optShowTabs);
        vItems[1].Flags := SetFlag(0, MIF_CHECKED1, optShowNumbers);
//      vItems[2].Flags := SetFlag(0, MIF_CHECKED1, optShowButton);
        vItems[2].Flags := SetFlag(0, MIF_CHECKED1, optSeparateTabs);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strOptions),
          '',
          ''{'Options'},
          nil, nil,
          Pointer(vItems),
          cMenuCount);

        if vRes = -1 then
          Exit;

        case vRes of
          0: TabsManager.ToggleOption(optShowTabs);
          1: TabsManager.ToggleOption(optShowNumbers);
//        2: TabsManager.ToggleOption(optShowButton);
          2: TabsManager.ToggleOption(optSeparateTabs);
        end;

//      Exit;
      end;

    finally
      MemFree(vItems);
    end;
  end;


  procedure SelectTabByKey;
  var
    vKey :Integer;
    vChr :TChar;
  begin
    vKey := FARAPI.AdvControl(hModule, ACTL_WAITKEY, nil);
    case vKey of
      KEY_ESC:
        {};
      KEY_INS:
        TabsManager.AddTab(True);
      KEY_DEL:
        TabsManager.DeleteTab(True);
      KEY_SPACE:
        TabsManager.ListTab(True);
      KEY_MULTIPLY:
        TabsManager.FixUnfixTab(True);
    else
//    TabsManager.SelectTab(True, VKeyToIndex(vKey));
     {$ifdef bUnicodeFar}
      if (vKey > 32) and (vKey < $FFFF) then begin
     {$else}
      if (vKey > 32) and (vKey <= $FF) then begin
     {$endif bUnicodeFar}
        vChr := TChar(vKey);
       {$ifndef bUnicodeFar}
        ChrOemToAnsi(vChr, 1);
       {$endif bUnicodeFar}
        TabsManager.SelectTabByKey(True, vChr);
      end;
    end;
  end;


  procedure OpenMenu;
  var
    vItems :array[0..4] of TFarMenuItemEx;
    vRes :Integer;
  begin
    TabsManager.PaintTabs;

    FillChar(vItems, SizeOf(vItems), 0);
    SetMenuItemChr(@vItems[0], GetMsg(strMAddTab));
    SetMenuItemChr(@vItems[1], GetMsg(strMEditTabs));
    SetMenuItemChr(@vItems[2], GetMsg(strMSelectTab));
    SetMenuItemChr(@vItems[3], '', MIF_SEPARATOR);
    SetMenuItemChr(@vItems[4], GetMsg(strMOptions));

    vRes := FARAPI.Menu(hModule, -1, -1, 0,
      FMENU_WRAPMODE or FMENU_USEEXT,
      GetMsg(strTitle),
      '',
      'Contents',
      nil, nil,
      @vItems,
      High(vItems)+1);

    case vRes of
      0: TabsManager.AddTab(True);
      1: TabsManager.ListTab(True);
      2: SelectTabByKey;
      4: OptionsMenu;
    end;
  end;


  procedure OpenCmdLine(const AStr :TString);
  var
    vStr :PTChar;
    vCmd :TString;
  begin
    if AStr <> '' then begin
      vStr := PTChar(AStr);
      while vStr^ <> #0 do begin
        vCmd := ExtractParamStr(vStr);
        if vCmd <> '' then begin
          if (vCmd[1] = '/') or (vCmd[1] = '-') then begin
            Delete(vCmd, 1, 1);
            TabsManager.RunCommand(vCmd);
          end;
        end;
      end;
    end else
      OpenMenu;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := MakeFarVersion(2, 0, 1005);   { ProcessSynchroEvent }
//  Result := MakeFarVersion(2, 0, 1148);   { ConvertPath }
    Result := MakeFarVersion(2, 0, 1573);   { ACTL_GETFARRECT }
  end;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);

    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

    { Получаем Handle консоли Far'а }
    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
(*
    InitConsoleProc;
//  hConWindow := GetConsoleWindow;
    CanCheckWindow := GetConsoleWindow = hFarWindow;
*)
    ReadSetup;

    TabsManager := TTabsManager.Create;
    SetTabsThread(True);
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;
    ConfigMenuStrings: array[0..0] of PFarChar;

 {$ifdef bUnicodeFar}
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
 {$else}
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('GetPluginInfo: %s', ['']);

    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_PRELOAD;

    PluginMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginMenuStrings := @PluginMenuStrings;
    pi.PluginMenuStringsNumber := 1;

    ConfigMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginConfigStrings := @ConfigMenuStrings;
    pi.PluginConfigStringsNumber := 1;

    pi.CommandPrefix := cFarTabPrefix;
    pi.Reserved := cFarTabGUID;

//  TabsManager.RefreshTabs;
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
    SetTabsThread(False);
    try
      TabsManager.StoreTabs;
    except
    end;
    FreeObj(TabsManager);
  end;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}
  begin
    Result:= INVALID_HANDLE_VALUE;
    try
//    TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);

     {$ifndef bUnicodeFar}
      SetFileApisToAnsi;
      try
     {$endif bUnicodeFar}

      if OpenFrom and OPEN_FROMMACRO <> 0 then begin
        Item := Item and not OPEN_FROMMACRO;
        if Item = 0 then begin
          case GlobalCommand of
            1: TabsManager.PaintTabs;
            2: TabsManager.MouseClick;
          end;
          GlobalCommand := 0;
        end else
        begin
          case Item of
            1: TabsManager.AddTab(True);
            2: TabsManager.ListTab(True);
            3: SelectTabByKey;
            4: OptionsMenu;
          end;
        end;
      end else
      if OpenFrom = OPEN_COMMANDLINE then
        OpenCmdLine(FarChar2Str(PFarChar(Item)))
      else
        OpenMenu;

     {$ifndef bUnicodeFar}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicodeFar}

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {$ifdef bUnicodeFar}
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);

    Result := 0;
    try
      if Event <> SE_COMMONSYNCHRO then
        Exit;

      case TUnsPtr(Param) of
        1: TabsManager.PaintTabs(True);
        2: TabsManager.MouseClick;
      end;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;
 {$endif bUnicodeFar}



 {$ifdef bUnicodeFar}
  function ConfigureW(Item: integer) :Integer; stdcall;
 {$else}
  function Configure(Item: integer) :Integer; stdcall;
 {$endif bUnicodeFar}
  begin
    Result := 1;
    try
      OptionsMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


initialization
finalization
//FreeObj(TabsThread);
end.


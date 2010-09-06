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
 { Injecting                                                                   }
 {-----------------------------------------------------------------------------}

 {$ifdef bUseInjecting}

  var
    NeedRedrawTabs :Boolean;

  const
    ImagehlpLib = 'IMAGEHLP.DLL';


  function ImageDirectoryEntryToData(Base :Pointer; MappedAsImage :ByteBool;
    DirectoryEntry :Word; var Size: ULONG): Pointer; stdcall; external ImagehlpLib name 'ImageDirectoryEntryToData';


  var
    OldWriteConsoleOutputW :function (hConsoleOutput :THandle; lpBuffer :Pointer;
      dwBufferSize, dwBufferCoord :TCoord; var lpWriteRegion :TSmallRect) :BOOL; stdcall;

    WriteConsoleOutputPtr :PPointer;


  function XYInSRect(X, Y :Integer; const ARect :TSmallRect) :Boolean;
  begin
    with ARect do
      Result := (X >= Left) and (X <= Right) and (Y >= Top) and (Y <= Bottom)
  end;


  function MyWriteConsoleOutputW(hConsoleOutput :THandle; lpBuffer :Pointer;
    dwBufferSize, dwBufferCoord :TCoord; var lpWriteRegion :TSmallRect): BOOL; stdcall;
  var
    X, Y :Integer;
  begin
//  TraceF('MyWriteConsoleOutputW (Coord=%dx%d, Size=%dx%d, Out:%d-%d, %d-%d)', [dwBufferCoord.X, dwBufferCoord.Y, dwBufferSize.X, dwBufferSize.Y,
//    lpWriteRegion.Top, lpWriteRegion.Bottom, lpWriteRegion.Left, lpWriteRegion.Right]);

    Result := OldWriteConsoleOutputW(hConsoleOutput, lpBuffer, dwBufferSize, dwBufferCoord, lpWriteRegion);
//  Result := True;

    if (TabsManager.DrawLock = 0) and TabsManager.NeedCheck(X, Y) and XYInSRect(X, Y, lpWriteRegion) then begin
      TraceF('NeedRedraw (Coord=%dx%d, Size=%dx%d, Out:%d-%d, %d-%d)', [dwBufferCoord.X, dwBufferCoord.Y, dwBufferSize.X, dwBufferSize.Y,
        lpWriteRegion.Top, lpWriteRegion.Bottom, lpWriteRegion.Left, lpWriteRegion.Right]);
      NeedRedrawTabs := True;
    end;

  end;



  function InjectFunc(AFuncPtr :PPointer; ANewFunc :Pointer) :Pointer;
  var
    vMem :MEMORY_BASIC_INFORMATION;
    vTmp :DWORD;
  begin
    VirtualQuery(AFuncPtr, vMem, SizeOf(MEMORY_BASIC_INFORMATION));
    VirtualProtect(vMem.BaseAddress, vMem.RegionSize, PAGE_READWRITE, @vTmp);
    Result := AFuncPtr^;
    AFuncPtr^ := ANewFunc;
    VirtualProtect(vMem.BaseAddress, vMem.RegionSize, vTmp, @vTmp);
  end;


  function InjectHandlers :Boolean;
  var
    vHandle :THandle;
    vImport :PIMAGE_IMPORT_DESCRIPTOR;
    vThunk :PIMAGE_THUNK_DATA;
    vAddr :Pointer;
    vName :PAnsiChar;
    vSize :ULONG;
  begin
    Result := False;
    vAddr := GetProcAddress(GetModuleHandle(kernel32), 'WriteConsoleOutputW');

    vHandle := GetModuleHandle(nil);
    vImport := ImageDirectoryEntryToData(Pointer(vHandle), True, IMAGE_DIRECTORY_ENTRY_IMPORT, vSize);

    while vImport.OriginalFirstThunk <> 0 do begin
      vName := PAnsiChar(vHandle + vImport.Name);

      if lstrcmpiA(vName, kernel32) = 0 then begin
        vThunk := Pointer(vHandle + vImport.FirstThunk);

        while (vThunk._Function <> 0) and (Pointer(vThunk._Function) <> vAddr) do
          Inc(vThunk);

        if vThunk._Function <> 0 then begin
          WriteConsoleOutputPtr := @vThunk._Function;
          OldWriteConsoleOutputW := InjectFunc(WriteConsoleOutputPtr, @MyWriteConsoleOutputW);
          Result := True;
        end;

        Exit;
      end;
      Inc(vImport);
    end;
  end;


  procedure RemoveHandlers;
  begin
    if (WriteConsoleOutputPtr <> nil) {and (WriteConsoleOutputPtr^ = @MyWriteConsoleOutputW)} then begin
//    TraceF('RemoveHandlers... Old=%p', [@OldWriteConsoleOutputW]);
      InjectFunc(WriteConsoleOutputPtr, @OldWriteConsoleOutputW);
      WriteConsoleOutputPtr := nil;
    end;
  end;

 {$endif bUseInjecting}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetConsoleWindowSize :TSize;
  var
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);
    with vScreenInfo.srWindow do
      Result := Size(Right - Left, Bottom - Top);
  end;



  { Получаем символ из позиции X, Y }

  function ReadScreenChar(X, Y :Integer) :TChar;
  var
    vInfo :TConsoleScreenBufferInfo;
    vBuf :array[0..1, 0..1] of TCharInfo;
    vSize, vCoord :TCoord;
    vReadRect :TSmallRect;
  begin
    Result := #0;
    if not GetConsoleScreenBufferInfo(hStdOut, vInfo) then
      Exit;

    { Коррекция для режима "большого буфера" (/w) }
    with FarGetWindowRect do begin
      Inc(Y, Top);
      Inc(X, Left);
    end;

    if (X < vInfo.dwSize.X) and (Y < vInfo.dwSize.Y) then begin
      vSize.X := 1; vSize.Y := 1; vCoord.X := 0; vCoord.Y := 0;
      vReadRect := SBounds(X, Y, 1, 1);
      FillChar(vBuf, SizeOf(vBuf), 0);

//    TraceF('ReadConsoleOutput: %d, %d, %d, %d', [X, Y, vInfo.dwSize.X, vInfo.dwSize.Y]);
      if ReadConsoleOutput(hStdOut, @vBuf, vSize, vCoord, vReadRect) then begin
       {$ifdef bUnicode}
        Result := vBuf[0, 0].UnicodeChar;
       {$else}
        Result := vBuf[0, 0].AsciiChar;
       {$endif bUnicode}
      end else
        {RaiseLastWin32Error};
    end;
  end;


(*
  function ReadScreenChar(X, Y :Integer) :TChar;
  var
    vInfo :TConsoleScreenBufferInfo;
//  vTst1 :Integer;
    vBuf :array[0..128, 0..2] of TCharInfo;
//  vTst2 :Integer;

    vSize, vCoord :TCoord;
    vReadRect :TSmallRect;
  begin
    Result := #0;

//  vTst1 := $12345678;
//  vTst2 := $12345678;

//  Trace('GetConsoleScreenBufferInfo...');
    if not GetConsoleScreenBufferInfo(hStdOut, vInfo) then begin
      NOP;
      Exit;
    end;
//  Trace('Done');

    if (X < vInfo.dwSize.X) and (Y < vInfo.dwSize.Y) then begin

      if (X < 0) or (Y < 0) then
        NOP;

      vSize.X := 1; vSize.Y := 1; vCoord.X := 0; vCoord.Y := 0;
      vReadRect := SBounds(X, Y, 1, 1);
      FillChar(vBuf, SizeOf(vBuf), 0);

//    TraceF('ReadConsoleOutput: %d, %d, %d, %d', [X, Y, vInfo.dwSize.X, vInfo.dwSize.Y]);
      if ReadConsoleOutput(hStdOut, @vBuf, vSize, vCoord, vReadRect) then begin
       {$ifdef bUnicode}
        Result := vBuf[0, 0].UnicodeChar;
       {$else}
        Result := vBuf[0, 0].AsciiChar;
       {$endif bUnicode}
      end else
        RaiseLastWin32Error;
//    Trace('Done');

    end;

//  Assert(vTst1 = $12345678);
//  Assert(vTst2 = $12345678);
  end;
*)

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    GlobalCommand  :Integer;


  function IsActiveConsole :boolean;
  begin
    Result := WindowIsChildOf(hConsoleWnd, GetForegroundWindow) and ConManIsActiveConsole;
  end;


  function AlertableSleep(APeriod :Cardinal) :Boolean;
  begin
//  Trace('Sleep...');
    Result := WaitForSingleObject(hStdin, APeriod) <> WAIT_TIMEOUT;
//  TraceF('...Awake (%d)', [byte(Result)]);
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
    X, Y :Integer;
    vInput :TEventTypes;
    vTitle, vLastTitle :TString;
    vSize, vLastSize :TSize;
    vWasInput :Boolean;
    vPoint :TPoint;
    vIndex :Integer;
    vKind :TTabKind;
    vTick :DWORD;
   {$ifdef bUseInjecting}
   {$else}
    vCh :TChar;
   {$endif bUseInjecting}
  begin
    vLastTitle := '';
    vLastSize := GetConsoleWindowSize;
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
//          TraceF('Title changed (%s)...', [vTitle]);
            vLastTitle := vTitle;
            CallPlugin(1);
            vWasInput := False;
          end else
          begin
            vSize := GetConsoleWindowSize;

            if (vSize.CX <> vLastSize.CX) or (vSize.CY <> vLastSize.CY) then begin
//            TraceF('Window size changed (%d x %d)...', [vSize.CX, vSize.CY]);
              vLastSize := vSize;
              CallPlugin(1);
              vWasInput := False;
            end else
            begin
             {$ifdef bUseInjecting}
              if TabsManager.NeedCheck(X, Y) then begin
                if NeedRedrawTabs then begin
                  NeedRedrawTabs := False;
                  Trace('Screen need repaint...');
                  CallPlugin(1);
                end;
                vWasInput := False;
              end else
             {$else}
              if TabsManager.NeedCheck(X, Y) then begin
                vCh := ReadScreenChar(X, Y);
                if vCh <> '+' then begin
//                Trace('Screen need repaint...');
                  CallPlugin(1);
                end;
                vWasInput := False;
              end else
             {$endif bUseInjecting}

              if vWasInput then begin

                vTick := GetTickCount;
                while not Terminated and (TickCountDiff(GetTickCount, vTick) < cRetryPeriod) do begin
                  vInput := CheckInput;
                  if vInput <> [] then
                    Break;
                end;

                if vInput = [] then begin
//                Trace('Possible need repaint???...');
                  CallPlugin(1);
                  vWasInput := False;
                end;

              end;

            end; {Size}
          end; {Title}

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
      MainMenu;
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
    FARAPI := psi;
    FARSTD := psi.fsf^;

    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

    { Получаем Handle консоли Far'а }
    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);

    RestoreDefColor;
    ReadSetup;

    TabsManager := TTabsManager.Create;
    SetTabsThread(True);

   {$ifdef bUseInjecting}
    InjectHandlers;
   {$endif bUseInjecting}
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
   {$ifdef bUseInjecting}
    RemoveHandlers;
   {$endif bUseInjecting}

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
            3: ProcessSelectMode;
            4: OptionsMenu;
          end;
        end;
      end else
      if OpenFrom = OPEN_COMMANDLINE then
        OpenCmdLine(FarChar2Str(PFarChar(Item)))
      else
        MainMenu;

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


end.


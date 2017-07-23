{******************************************************************************}
{* (c) 2009-2013 Max Rusov                                                    *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}

unit PanelTabsMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    Far_API,
    FarCtrl,
    FarConMan,
    FarPlug,

    PanelTabsCtrl,
    PanelTabsClasses,
    PanelTabsOptions;


  type
    TPanelTabsPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;

      procedure Configure; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
     {$ifdef bUseProcessConsoleInput}
      function ConsoleInput(const ARec :TInputRecord) :Integer; override;
     {$endif bUseProcessConsoleInput}
    end;


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


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

 {$ifdef bUseThread}

  function IsActiveConsole :boolean;
  begin
    Result := WindowIsChildOf(GetConsoleWnd, GetForegroundWindow) and ConManIsActiveConsole;
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
    vCount := 0;
//  TraceF('PeekConsoleInput %d (%d)...', [hStdin, High(vBuf)]);
    if PeekConsoleInput(hStdin, vBuf[0], High(vBuf), DWORD(vCount)) then begin
//    TraceF('Events %d', [vCount]);

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
    end else
      {TraceF('Error %d', [GetLastError])};
  end;


 {-----------------------------------------------------------------------------}
 { TTabsThread                                                                 }
 {-----------------------------------------------------------------------------}

  type
    TTabsThread = class(TThread)
    public
      constructor Create;
      destructor Destroy; override;
      procedure Execute; override;

    private
      FEvent :THandle;

      function AlertableSleep(APeriod :Cardinal) :Boolean;
      function CallPlugin(ACmd :Integer) :Boolean;
    end;


  constructor TTabsThread.Create; {override;}
  begin
    inherited Create(False);
    FEvent := CreateEvent(nil, {ManualReset=}False, {InitialState=}False, nil);
  end;


  destructor TTabsThread.Destroy; {override;}
  begin
    CloseHandle(FEvent);
    inherited Destroy;
  end;


  procedure TTabsThread.Execute; {override;}
  const
    cRetryPeriod = 0;
  var
    X, Y :Integer;
    vTick :DWORD;
    vInput :TEventTypes;
    vTitle, vLastTitle :TString;
    vSize, vLastSize :TSize;
    vWasInput :Boolean;
   {$ifdef bUseProcessConsoleInput}
   {$else}
    vPoint :TPoint;
    vIndex :Integer;
    vKind :TTabKind;
   {$endif bUseProcessConsoleInput}
   {$ifdef bUseInjecting}
   {$else}
    vCh :TChar;
   {$endif bUseInjecting}
  begin
    vLastTitle := '';
    vLastSize := GetConsoleWindowSize;
    vWasInput := False;

    while not Terminated do begin

     {$ifdef bUseProcessConsoleInput}
     {$else}
      if ((GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0)) and IsActiveConsole then begin
        vPoint := GetConsoleMousePos;
//      TraceF('Mouse down: %d x %d...', [vPoint.X, vPoint.Y]);
        if TabsManager.HitTest(vPoint.X, vPoint.Y, vKind, vIndex) <> hsNone then
          CallPlugin(2);
        while not Terminated and ((GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0)) do
          Sleep(10);
//      Trace('Mouse Up.');
      end else
     {$endif bUseProcessConsoleInput}
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
//                Trace('Screen need repaint...');
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
//        Trace('sleep(10)');
          Sleep(10)
        end else
        if AlertableSleep(100{!!!}) then begin
//        Trace('Alert!');
        end;
      end;
    end;
//  Trace('Finish...');
  end;


  function TTabsThread.AlertableSleep(APeriod :Cardinal) :Boolean;
  var
    vHandles :array[0..1] of THandle;
    vRes :DWORD;
  begin
//  Trace('Sleep...');
    vHandles[0] := FEvent;
    vHandles[1] := hStdIn;
    vRes := WaitForMultipleObjects( 2, Pointer(@vHandles), {WaitAll=}False, APeriod);
    Result := vRes <> WAIT_TIMEOUT;
//  TraceF('...Awake (%d)', [byte(Result)]);
  end;


  function TTabsThread.CallPlugin(ACmd :Integer) :Boolean;
  begin
    Result := False;

//  Trace('Can call?');
    if not TabsManager.CanPaintTabs(True) then begin
//    Trace('Can not paint...');
      Exit;
    end;

//  TraceF('Call plugin: ACmd=%d', [ACmd]);
    FarAdvControl(ACTL_SYNCHRO, Pointer(TIntPtr(ACmd)));
  end;


 {-----------------------------------------------------------------------------}

  var
    TabsThread :TTabsThread;

  procedure SetTabsThread(AOn :Boolean);
  begin
    if AOn <> (TabsThread <> nil) then begin
      if AOn then
        TabsThread := TTabsThread.Create
      else begin
        SetEvent(TabsThread.FEvent);
        FreeObj(TabsThread);
      end;
    end;
  end;

 {$endif bUseThread}


 {-----------------------------------------------------------------------------}
 { TPanelTabsPlug                                                              }
 {-----------------------------------------------------------------------------}

  procedure TPanelTabsPlug.Init; {override;}
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
    FMinFarVer := MakeVersion(3, 0, 2927);   { Release }
   {$else}
//  FMinFarVer := MakeVersion(2, 0, 1005);   { ProcessSynchroEvent }
//  FMinFarVer := MakeVersion(2, 0, 1148);   { ConvertPath }
    FMinFarVer := MakeVersion(2, 0, 1573);   { ACTL_GETFARRECT }
   {$endif Far3}
  end;


  procedure TPanelTabsPlug.Startup; {override;}
  begin
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    RestoreDefColor;
    ReadSetup;

    TabsManager := TTabsManager.Create;

   {$ifdef bUseInjecting}
    InjectHandlers;
   {$endif bUseInjecting}

   {$ifdef bUseThread}
    SetTabsThread(True);
   {$else}
    FarAdvControl(ACTL_SYNCHRO, Pointer(1));
   {$endif bUseThread}
  end;


  procedure TPanelTabsPlug.GetInfo; {override;}
  begin
    FFlags := PF_PRELOAD;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    FPrefix := cFarTabPrefix;
  end;


  procedure TPanelTabsPlug.ExitFar; {override;}
  begin
//  Trace('Exit far...');

   {$ifdef bUseInjecting}
    RemoveHandlers;
   {$endif bUseInjecting}

   {$ifdef bUseThread}
    SetTabsThread(False);
   {$endif bUseThread}
    try
      {???}
      TabsManager.StoreTabs;
    except
    end;
    FreeObj(TabsManager);
  end;


  procedure TPanelTabsPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  function TPanelTabsPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    hFarWindow := 0;
    MainMenu;
  end;


  function TPanelTabsPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vCmd :TString;
  begin
    Result := INVALID_HANDLE_VALUE;
    if AStr <> nil then begin
      while AStr^ <> #0 do begin
        vCmd := ExtractParamStr(AStr);
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


  function TPanelTabsPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    if (AInt = 0) and (AStr = nil) then
      MainMenu
    else
    if AInt > 0 then begin
      case AInt of
        1: TabsManager.AddTab(True);
        2: TabsManager.ListTab(True);
        3: ProcessSelectMode;
        4: OptionsMenu;
      end;
    end;
  end;


 {$ifdef bUseProcessConsoleInput}
  function TPanelTabsPlug.ConsoleInput(const ARec :TInputRecord) :Integer; {override;}
  var
    vButton :Integer;
  begin
    Result := 0;
    try

      if (ARec.EventType = _MOUSE_EVENT) {and opt_MouseSupport} then begin
        with ARec.Event.MouseEvent do begin
//        TraceF('ConsoleInput: Flags: %d, Button: %d, Control: %x', [dwEventFlags, dwButtonState, dwControlKeyState]);
          if (dwEventFlags = 0) or (DOUBLE_CLICK and dwEventFlags <> 0) then begin
            if dwButtonState <> 0 then begin
              vButton := 1;
              if dwButtonState and RIGHTMOST_BUTTON_PRESSED <> 0 then
                vButton := 2;
              if dwButtonState and FROM_LEFT_2ND_BUTTON_PRESSED <> 0 then
                vButton := 3;
              if TabsManager.TrackMouseStart(vButton, dwMousePosition.X, dwMousePosition.Y, DOUBLE_CLICK and dwEventFlags <> 0, dwControlKeyState) then
                Result := 1;
            end else
            if TabsManager.TrackMouseEnd(dwMousePosition.X, dwMousePosition.Y) then
              Result := 1;
          end else
          if MOUSE_MOVED and dwEventFlags <> 0 then begin
            if TabsManager.TrackMouseContinue(dwMousePosition.X, dwMousePosition.Y) then
              Result := 1;
          end;
        end;
      end else
      if ARec.EventType = WINDOW_BUFFER_SIZE_EVENT then
        TabsManager.PaintTabs;

    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;
 {$endif bUseProcessConsoleInput}


  procedure TPanelTabsPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
//  TraceF('SynchroEvent %d', [TUnsPtr(AParam)]);
    try
      hFarWindow := 0;

      case TUnsPtr(AParam) of
        1: TabsManager.PaintTabs(True);
       {$ifdef bUseProcessConsoleInput}
       {$else}
        2: TabsManager.MouseClick;
       {$endif bUseProcessConsoleInput}
      end;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


end.


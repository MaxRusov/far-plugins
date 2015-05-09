{$I Defines.inc}

unit FastWheelMain;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Editor Whell Extender                                                      *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,
    Far_API,
    FarCtrl,
    FarConfig,
    FarPlug;

  const
    strTitle = 1;

  const
    cPluginName = 'FastWheel';
    cPluginDescr = 'FastWheel plugin for FAR manager';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID    :TGUID = '{4DF17F5F-E79B-46B1-A70C-04B573CECAA4}';
    cMenuID      :TGUID = '{03A3A9EF-445C-4B8D-8F65-9B6B97C606F1}';
    cConfigID    :TGUID = '{5813F8AF-587D-4191-8B37-83ECF8A5FBA4}';
   {$else}
    cPluginID      = $4C485745;
    cPlugRegFolder = 'FastWheel';
   {$endif Far3}

    cWavFileName   = 'Click.wav';

  var
    opt_AccelPeriod  :Integer = 300;
    opt_Acceleration :Integer = 16;
    opt_ScrollDelay  :Integer = 8;
    opt_MaxSpeed     :Integer = 3;

    opt_ShiftFilter  :Integer = RIGHT_ALT_PRESSED + LEFT_ALT_PRESSED + RIGHT_CTRL_PRESSED + LEFT_CTRL_PRESSED + SHIFT_PRESSED;


  type
    TFastWheelPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure GetInfo; override;
      procedure ExitFar; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;

      procedure SynchroEvent(AParam :Pointer); override;
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      function EditorInput(const ARec :TInputRecord) :Integer; override;
     {$ifdef bUseProcessConsoleInput}
      function ConsoleInput(const ARec :TInputRecord) :Integer; override;
     {$endif bUseProcessConsoleInput}

    private
      FLastScroll   :DWORD;
      FLastImpact   :Integer;

      procedure Impact(ADirection :Integer);
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    FLock      :TRTLCriticalSection;
    FSound     :Pointer;

    FImpact    :Integer;
    FDirection :Integer;


  procedure ImmediateStop;
  begin
    FImpact := 0;
    FDirection := 0;
  end;


 {-----------------------------------------------------------------------------}


  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

        IntValue('Acceleration', opt_Acceleration);

//      IntValue('Period', opt_AccelPeriod);
//      IntValue('Delay', opt_ScrollDelay);
//      IntValue('MaxSpeed', opt_MaxSpeed);

      finally
        Destroy;
      end;
  end;


  procedure OptionsDlg;
  var
    vStr :TString;
  begin
    vStr := Int2Str(opt_Acceleration);
    if FarInputBox(GetMsg(strTitle), 'Acceleration', vStr) then begin
      opt_Acceleration := IntMax(Str2IntDef(vStr, opt_Acceleration), 1);
      PluginConfig(True);
    end;
  end;


 {-----------------------------------------------------------------------------}

  const
    SND_SYNC            = $0000;      { play synchronously (default) }
    SND_ASYNC           = $0001;      { play asynchronously }
    SND_NODEFAULT       = $0002;      { don't use default sound }
    SND_MEMORY          = $0004;      { lpszSoundName points to a memory file }
    SND_LOOP            = $0008;      { loop the sound until next sndPlaySound }
    SND_NOSTOP          = $0010;      { don't stop any currently playing sound }
    SND_NOWAIT          = $00002000;  { don't wait if the driver is busy }
    SND_ALIAS           = $00010000;  { name is a registry alias }
    SND_ALIAS_ID        = $00110000;  { alias is a predefined ID }
    SND_FILENAME        = $00020000;  { name is file name }
    SND_RESOURCE        = $00040004;  { name is resource name or atom }
    SND_PURGE           = $0040;      { purge non-static events for task }
    SND_APPLICATION     = $0080;      { look for application specific association }


  function PlaySound(pszSound :PTChar; hmod :THandle; fdwSound: DWORD) :BOOL; stdcall;
    external 'winmm.dll' name 'PlaySoundW';


  procedure InitScrollSound;
  var
    vFileName :TString;
    vFile :THandle;
    vSize :Integer;
  begin
    if FSound = nil then begin
      vFileName := FarChar2Str(FARAPI.ModuleName);
      vFileName := AddFileName(ExtractFilePath(vFileName), cWavFileName);

      if WinFileExists(vFileName) then begin

        vFile := FileOpen(vFileName, fmOpenRead or fmShareDenyWrite);
        if vFile = INVALID_HANDLE_VALUE then
          Exit;
        try
          vSize := GetFileSize(vFile, nil);
          if vSize > 0 then begin
            FSound := MemAlloc(vSize);
            FileRead(vFile, FSound^, vSize);
          end;
        finally
          FileClose(vFile);
        end;
      end;
    end;
  end;


  procedure PlayScrollSound;
  begin
    if FSound <> nil then
      PlaySound(FSound, 0, SND_MEMORY or SND_ASYNC or SND_NOWAIT or SND_NOSTOP);
  end;



 {-----------------------------------------------------------------------------}
 { TWheelThread                                                                }
 {-----------------------------------------------------------------------------}

  type
    TWheelThread = class(TThread)
    public
      constructor Create;
      destructor Destroy; override;
      procedure Execute; override;

    private
      FEvent1 :THandle;
      FEvent2 :THandle;
      FWTimer :THandle;
    end;


  constructor TWheelThread.Create; {override;}
  begin
    inherited Create(False);
    FEvent1 := CreateEvent(nil, {ManualReset=}False, {InitialState=}False, nil);
    FEvent2 := CreateEvent(nil, {ManualReset=}False, {InitialState=}False, nil);
    FWTimer := CreateWaitableTimer(nil, True, nil);
  end;


  destructor TWheelThread.Destroy; {override;}
  begin
    CloseHandle(FEvent1);
    CloseHandle(FEvent2);
    CloseHandle(FWTimer);
    inherited Destroy;
  end;



  procedure TWheelThread.Execute; {override;}
  var
    vDelta :TIntPtr;
    vDelay :TInt64;
    vImpact, vDir :Integer;
    vHandles :array[0..1] of THandle;
  begin
    vHandles[0] := FEvent2;
    vHandles[1] := FWTimer;

    while not Terminated do begin
      WaitForSingleObject(FEvent1, 1000);
//    TraceF('%d', [vRes]);
      if Terminated then
        Exit;

      EnterCriticalSection(FLock);
      try
        vImpact := FImpact;
        vDir := FDirection;
      finally
        LeaveCriticalSection(FLock);
      end;

      if vImpact <> 0 then begin
//      Trace('Run...');
        vDelta := 1;

        while not Terminated do begin
          vDelay := -(opt_ScrollDelay * 10000);
//        if vImpact <= 3 then
//          vDelay := vDelay * (4 - vImpact);
          ApiCheck(SetWaitableTimer(FWTimer, vDelay, 0, nil, nil, False));

//        TraceF('Run... (Impacts=%d, Steps=%d)', [FImpact, vDelta]);
//        PlayScrollSound;

          FarAdvControl(ACTL_SYNCHRO, pointer(vDelta * vDir));
//        WaitForSingleObject(FEvent2, 1000);
          WaitForMultipleObjects(2, PWOHandleArray(@vHandles), True, 1000);

          EnterCriticalSection(FLock);
          try
            if FImpact > 0 then
              FImpact := IntMax(FImpact - vDelta, 0);

            if (FImpact = 0) or (vDir <> FDirection) then
              { Принудительная остановка }
              Break;

            vDelta := IntMin((FImpact div 10) + 1, opt_MaxSpeed);
//          vImpact := FImpact;

          finally
            LeaveCriticalSection(FLock);
          end;
        end;

      end;
    end;
  end;


  var
    WheelThread :TWheelThread;

  procedure SetWheelThread(AOn :Boolean);
  begin
    if AOn <> (WheelThread <> nil) then begin
      if AOn then
        WheelThread := TWheelThread.Create
      else begin
        SetEvent(WheelThread.FEvent1);
        SetEvent(WheelThread.FEvent2);
        FreeObj(WheelThread);
      end
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFastWheelPlug                                                              }
 {-----------------------------------------------------------------------------}

  procedure TFastWheelPlug.Init; {override;}
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
//  FMinFarVer := MakeVersion(3, 0, 2460);   { OPEN_FROMMACRO }
//  FMinFarVer := MakeVersion(3, 0, 2572);   { Api changes }
    FMinFarVer := MakeVersion(3, 0, 3000);   { Lua stable }
   {$else}
   {$endif Far3}
  end;


  procedure TFastWheelPlug.Startup; {override;}
  begin
//  InitScrollSound;
    PluginConfig(False);
  end;

  procedure TFastWheelPlug.ExitFar; {override;}
  begin
    SetWheelThread(False);
    MemFree(FSound);
//  WriteSetup;
  end;


  procedure TFastWheelPlug.GetInfo; {override;}
  begin
    FFlags := {PF_DISABLEPANELS or} PF_EDITOR or PF_VIEWER {or PF_DIALOG};

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}
  end;


  procedure TFastWheelPlug.Configure; {override;}
  begin
    OptionsDlg;
  end;


  function TFastWheelPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
  end;


  function TFastWheelPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    if AInt > 0 then
      Impact(IntIf(AInt = 1, -1, 1));
  end;


  procedure TFastWheelPlug.Impact(ADirection :Integer);
  var
    vTime :DWORD;
    vPeriod, vImpacts :Integer;
  begin
//  TraceF('Impact. Direction=%d', [ADirection]);

    SetWheelThread(True);
    vTime := GetTickCount;

    EnterCriticalSection(FLock);
    try
      if ADirection <> FDirection then
        ImmediateStop;

      vImpacts := 1;
      if FLastScroll <> 0 then begin
        vPeriod := TickCountDiff(vTime, FLastScroll);
        if vPeriod < opt_AccelPeriod then begin
          vImpacts := IntMax(Round((opt_AccelPeriod - vPeriod) * opt_Acceleration / opt_AccelPeriod), 1);
          if vImpacts > FLastImpact * 2 then
            vImpacts := FLastImpact * 2;
        end;
      end;

      FDirection := ADirection;
      Inc(FImpact, vImpacts);
//    TraceF('Impact=+d -> %d', [vImpacts, FImpact]);

      FLastImpact := vImpacts;
      FLastScroll := vTime;
      SetEvent(WheelThread.FEvent1);

    finally
      LeaveCriticalSection(FLock);
    end;
  end;


  procedure TFastWheelPlug.SynchroEvent(AParam :Pointer); {override;}
  var
    I, vDelta :Integer;
    vWinInfo :TWindowInfo;
    vEdtInfo :TEditorInfo;
    vEdtPos  :TEditorSetPosition;
    vPanInfo :TPanelInfo;
    vPanPos  :TPanelRedrawInfo;
    vStr :TString;
  begin
    try
      vDelta := TIntPtr(AParam);
//    TraceF('Scroll. Delta=%d', [vDelta]);

      FarGetWindowInfo(-1, vWinInfo);

      if vWinInfo.WindowType = WTYPE_PANELS then begin

        FarGetPanelInfo(PANEL_ACTIVE, vPanInfo);

       {$ifdef Far3}
        vPanPos.StructSize := SizeOf(vPanPos);
       {$endif Far3}
        vPanPos.CurrentItem := RangeLimit(Integer(vPanInfo.CurrentItem) + vDelta, 0, vPanInfo.ItemsNumber);
        vPanPos.TopPanelItem := RangeLimit(Integer(vPanInfo.TopPanelItem) + vDelta, 0, vPanInfo.ItemsNumber);
        FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, @vPanPos);

      end else
      if vWinInfo.WindowType = WTYPE_EDITOR then begin
        FillZero(vEdtInfo, SizeOf(vEdtInfo));
       {$ifdef Far3}
        vEdtInfo.StructSize := SizeOf(vEdtInfo);
       {$endif Far3}
        FarEditorControl(ECTL_GETINFO, @vEdtInfo);

       {$ifdef Far3}
        vEdtPos.StructSize := SizeOf(vEdtPos);
       {$endif Far3}
        vEdtPos.CurLine := RangeLimit(vEdtInfo.CurLine + vDelta, 0, vEdtInfo.TotalLines);
        vEdtPos.TopScreenLine := RangeLimit(vEdtInfo.TopScreenLine + vDelta, 0, vEdtInfo.TotalLines);

        vEdtPos.CurPos := -1;
        vEdtPos.CurTabPos := -1;
        vEdtPos.LeftPos := -1;
        vEdtPos.Overtype := -1;
        FarEditorControl(ECTL_SETPOSITION, @vEdtPos);
        FarEditorControl(ECTL_REDRAW, nil);
      end else
      if vWinInfo.WindowType = WTYPE_VIEWER then begin

        vStr := '';
        for I := 0 to Abs(vDelta) - 1 do begin
          if vStr <> '' then
            vStr := vStr + ' ';
          if vDelta > 0 then
            vStr := vStr + FarKeyToMacro('Down')
          else
            vStr := vStr + FarKeyToMacro('Up');
        end;

        FarPostMacro(vStr{, KSFLAGS_NOSENDKEYSTOPLUGINS});
//      FARAPI.ViewerControl(VCTL_REDRAW, nil);

      end else
        ImmediateStop;

    finally
      if WheelThread <> nil then
        SetEvent(WheelThread.FEvent2);
    end;
  end;


  function TFastWheelPlug.EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  begin
//  TraceF('EditorEvent: %d', [AEvent]);
    if AEvent in [EE_CLOSE, EE_KILLFOCUS{, EE_GOTFOCUS}] then
      ImmediateStop;
    Result := 0;
  end;


  function TFastWheelPlug.EditorInput(const ARec :TInputRecord) :Integer; {override;}
  begin
    if ARec.EventType = _MOUSE_EVENT then
      if ARec.Event.MouseEvent.dwEventFlags = 0 then
        { Клик мышкой останавливает прокрутку }
        ImmediateStop;
    Result := 0;
  end;


 {$ifdef bUseProcessConsoleInput}
  function TFastWheelPlug.ConsoleInput(const ARec :TInputRecord) :Integer; {override;}
  begin
    Result := 0;
    if ARec.EventType = _MOUSE_EVENT then begin
      with ARec.Event.MouseEvent do
        if dwEventFlags = 0 then begin
          ImmediateStop;
        end else
        if dwEventFlags and MOUSE_WHEELED <> 0 then begin

          if dwControlKeyState and opt_ShiftFilter <> 0 then
            Exit;

          if Integer(dwButtonState) > 0 then
            Impact(-1)
          else
          if Integer(dwButtonState) < 0 then
            Impact(1);
          Result := 1;
        end;
    end;
  end;
 {$endif bUseProcessConsoleInput}


initialization
  InitializeCriticalSection(FLock);
finalization
  DeleteCriticalSection(FLock);
end.


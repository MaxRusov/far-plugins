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

    PluginW,
    FarKeys,

    FarCtrl;

  const
    strTitle = 1;

  const
    cPluginGUID    = $4C485745;
    cPlugRegFolder = 'FastWheel';

    cWavFileName   = 'Click.wav';

  var
    opt_AccelPeriod  :Integer = 300;
    opt_Acceleration :Integer = 16;
    opt_ScrollDelay  :Integer = 8;
    opt_MaxSpeed     :Integer = 3;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
//function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;

  function ProcessEditorInputW(const ARec :INPUT_RECORD) :Integer; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;

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

  procedure ReadSetup;
  var
    vRoot :TString;
    vKey :HKEY;
  begin
    vRoot := FARAPI.RootKey;
    if RegOpenRead(HKCU, vRoot + '\' + cPlugRegFolder, vKey) then begin
      try
        opt_AccelPeriod  := RegQueryInt(vKey, 'Period', opt_AccelPeriod);
        opt_Acceleration := RegQueryInt(vKey, 'Acceleration', opt_Acceleration);
        opt_ScrollDelay  := RegQueryInt(vKey, 'Delay', opt_ScrollDelay);
        opt_MaxSpeed     := RegQueryInt(vKey, 'MaxSpeed', opt_MaxSpeed);
      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure WriteSetup;
  var
    vRoot :TString;
    vKey :HKEY;
  begin
    vRoot := FARAPI.RootKey;
    RegOpenWrite(HKCU, vRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteInt(vKey, 'Acceleration', opt_Acceleration);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure OptionsDlg;
  var
    vStr :TString;
  begin
    vStr := Int2Str(opt_Acceleration);
    if FarInputBox(GetMsg(strTitle), 'Acceleration', vStr) then begin
      opt_Acceleration := IntMax(Str2IntDef(vStr, opt_Acceleration), 1);
      WriteSetup;
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
      PlaySound(FSound, 0, SND_MEMORY or SND_ASYNC or SND_NOWAIT);
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

//        TraceF('Run... (Impacts=%d, Steps=%s)', [FImpact, vDelta]);
//        PlayScrollSound;
          FARAPI.AdvControl(hModule, ACTL_SYNCHRO, pointer(vDelta * vDir));
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
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

(*
  function GetMinFarVersionW :Integer; stdcall;
  begin
    Result := 0;
  end;
*)


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    FARAPI := psi;
    FARSTD := psi.fsf^;

//  InitScrollSound;
    ReadSetup;
  end;



  var
    PluginMenuStrings: array[0..0] of PFarChar;

  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= {PF_DISABLEPANELS or} PF_EDITOR or PF_VIEWER {or PF_DIALOG};

    PluginMenuStrings[0] := GetMsg(strTitle);
//  pi.PluginMenuStringsNumber := 1;
//  pi.PluginMenuStrings := Pointer(@PluginMenuStrings);

    pi.PluginConfigStrings := Pointer(@PluginMenuStrings);
    pi.PluginConfigStringsNumber := 1;

    pi.Reserved := cPluginGUID;
  end;


  procedure ExitFARW; stdcall;
  begin
//  Trace('ExitFAR');
    SetWheelThread(False);
    MemFree(FSound);
//  WriteSetup;
  end;



  var
    FLastScroll   :DWORD;
    FLastImpact   :Integer;


  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  var
    vTime :DWORD;
    vPeriod, vDirection, vImpacts :Integer;
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);

    SetWheelThread(True);

    if OpenFrom and OPEN_FROMMACRO <> 0 then begin
      vTime := GetTickCount;

      EnterCriticalSection(FLock);
      try
        vDirection := IntIf(Item = 1, -1, 1);
        if vDirection <> FDirection then
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

        FDirection := vDirection;
        Inc(FImpact, vImpacts);
//      TraceF('Impact=+d -> %d', [vImpacts, FImpact]);

        FLastImpact := vImpacts;
        FLastScroll := vTime;
        SetEvent(WheelThread.FEvent1);

      finally
        LeaveCriticalSection(FLock);
      end;
    end;
  end;



  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    Result := 1;
    OptionsDlg;
  end;



  function ProcessEditorInputW(const ARec :INPUT_RECORD) :Integer; stdcall;
  begin
    if ARec.EventType = _MOUSE_EVENT then
      if ARec.Event.MouseEvent.dwEventFlags = 0 then
        { Клик мышкой останавливает прокрутку }
        ImmediateStop;
    Result := 0;
  end;


  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  begin
//  TraceF('ProcessEditorEvent: %d, %x', [AEvent, TIntPtr(AParam)]);
    if AEvent in [EE_CLOSE, EE_KILLFOCUS, EE_GOTFOCUS] then
      ImmediateStop;
    Result := 0;
  end;


  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  var
    I, vDelta :Integer;
    vWinInfo :TWindowInfo;
    vEdtInfo :TEditorInfo;
    vEdtPos  :TEditorSetPosition;
    vPanInfo :TPanelInfo;
    vPanPos  :TPanelRedrawInfo;
    vStr :TString;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);
    Result := 0;
    if Event <> SE_COMMONSYNCHRO then
      Exit;

    try
      vDelta := TIntPtr(Param);
//    TraceF('Scroll. Delta=%d', [vDelta]);

      FillZero(vWinInfo, SizeOf(vWinInfo));
      vWinInfo.Pos := -1;
      FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);

      if vWinInfo.WindowType = WTYPE_PANELS then begin

        FillZero(vPanInfo, SizeOf(vPanInfo));
        FARAPI.Control(PANEL_ACTIVE, FCTL_GETPANELINFO, 0, @vPanInfo);

        vPanPos.CurrentItem := RangeLimit(vPanInfo.CurrentItem + vDelta, 0, vPanInfo.ItemsNumber);
        vPanPos.TopPanelItem := RangeLimit(vPanInfo.TopPanelItem + vDelta, 0, vPanInfo.ItemsNumber);
        FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, @vPanPos);

      end else
      if vWinInfo.WindowType = WTYPE_EDITOR then begin

        FillZero(vEdtInfo, SizeOf(vEdtInfo));
        FARAPI.EditorControl(ECTL_GETINFO, @vEdtInfo);

        vEdtPos.CurLine := RangeLimit(vEdtInfo.CurLine + vDelta, 0, vEdtInfo.TotalLines);
        vEdtPos.TopScreenLine := RangeLimit(vEdtInfo.TopScreenLine + vDelta, 0, vEdtInfo.TotalLines);

        vEdtPos.CurPos := -1;
        vEdtPos.CurTabPos := -1;
        vEdtPos.LeftPos := -1;
        vEdtPos.Overtype := -1;
        FARAPI.EditorControl(ECTL_SETPOSITION, @vEdtPos);
        FARAPI.EditorControl(ECTL_REDRAW, nil);

      end else
      if vWinInfo.WindowType = WTYPE_VIEWER then begin

        vStr := '';
        for I := 0 to Abs(vDelta) - 1 do begin
          if vStr <> '' then
            vStr := vStr + ' ';
          if vDelta > 0 then
            vStr := vStr + 'Down'
          else
            vStr := vStr + 'Up';
        end;

        FarPostMacro(vStr, KSFLAGS_NOSENDKEYSTOPLUGINS);
//      FARAPI.ViewerControl(VCTL_REDRAW, nil);

      end else
        ImmediateStop;

    finally
      if WheelThread <> nil then
        SetEvent(WheelThread.FEvent2);
    end;
  end;



initialization
  InitializeCriticalSection(FLock);
finalization
  DeleteCriticalSection(FLock);
end.


{$I Defines.inc}
{$Typedaddress Off}

unit FarHintsMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarConMan,
    
    FarHintsConst,
    FarHintsAPI,
    FarHintsReg,
    FarHintsUtils,
    FarHintsPlugins,
    FarHintsClasses;


 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$ifdef bSynchroCall}
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
 {$endif bSynchroCall}
  procedure ExitFARW; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  procedure ExitFAR; stdcall;
  function OpenPlugin(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$endif bUnicodeFar}

  function GetFarHinstAPI :IFarHintsAPI; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    gCallMode       :Integer;
    gHintCommand    :Boolean;

  var
    hFarWindow  :THandle = THandle(-1);
    hConEmuWnd  :THandle = THandle(-1);
    hStdin      :THandle;
    hStdOut     :THandle;
//  hMainThread :Integer;

    CanCheckWindow :Boolean;

  var
    WinGetConsoleWindow :function :HWND; stdcall;


  procedure InitConsoleProc;
  var
    vKernel :THandle;
  begin
    vKernel := GetModuleHandle(Windows.Kernel32);
    if vKernel <> 0 then
      @WinGetConsoleWindow := GetProcAddress(vKernel, 'GetConsoleWindow');
  end;


  function GetConsoleWindow :THandle;
  begin
    Result := 0;
    if Assigned(WinGetConsoleWindow) then
      Result := WinGetConsoleWindow;
  end;


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
    Result := WindowIsChildOf(hConsoleWnd, GetForegroundWindow) {and ConManIsActiveConsole - Не так часто...} ;
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


  function MulDivTrunc(ANum, AMul, ADiv :Integer) :Integer;
  begin
    if ADiv = 0 then
      Result := 0
    else
      Result := ANum * AMul div ADiv;
  end;


  function GetConsoleMousePos :TPoint;
    { Вычисляем позицию мыши в консольных координатах }
  var
    vWnd  :THandle;
    vPos  :TPoint;
    vRect :TRect;
    vInfo :TConsoleScreenBufferInfo;
  begin
    GetCursorPos(vPos);

    vWnd := hConsoleWnd;
    ScreenToClient(vWnd, vPos);
    GetClientRect(vWnd, vRect);
    GetConsoleScreenBufferInfo(hStdOut, vInfo);
    with vInfo.srWindow do begin
//    TraceF('%d, %d - %d, %d', [Left, Top, Right, Bottom]);
      Result.Y := Top + MulDivTrunc(vPos.Y, Bottom - Top + 1, vRect.Bottom - vRect.Top);
      Result.X := Left + MulDivTrunc(vPos.X, Right - Left + 1, vRect.Right - vRect.Left);
    end;
  end;


  function ConsolePosToWindowPos(AX, AY :Integer) :TPoint;
    { Пересчитываем консольные координаты в координаты Windows }
  var
    vWnd  :THandle;
    vRect :TRect;
    vInfo :TConsoleScreenBufferInfo;
  begin
    vWnd := hConsoleWnd;
    GetClientRect(vWnd, vRect);
    GetConsoleScreenBufferInfo(hStdOut, vInfo);
    with vInfo.srWindow do begin
      Result.Y := MulDiv(AY - Top, vRect.Bottom, Bottom - Top + 1);
      Result.X := MulDiv(AX - Left, vRect.Right, Right - Left + 1);
    end;
    ClientToScreen(vWnd, Result);
  end;


 {-----------------------------------------------------------------------------}
 { THintThread                                                                 }
 {-----------------------------------------------------------------------------}

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

  type
    THintThread = class(TThread)
    public
      procedure Execute; override;

    private
      function CheckInput :TEventTypes;
      function CheckLocation :Boolean;
      function GetCallContext :THintCallContext;
      function CanCallPluginNow(APanelOnly :Boolean) :Boolean;
      function CheckCurrentPanel(var AFolder :TString; var ACurrent :Integer) :Boolean;
      function ShowHint(ACallMode :Integer) :Boolean;
      procedure WaitForCallComplete;
      procedure HideHint;
    end;



  function AlertableSleep(APeriod :Cardinal) :Boolean;
  begin
//  TraceF('Sleep: %d', [APeriod]);
//  Sleep(APeriod);
    Result := WaitForSingleObject(hStdin, APeriod) <> WAIT_TIMEOUT;
  end;


  function THintThread.CheckInput :TEventTypes;
  var
    I, vCount :Integer;
    vBuf :array[0..16] of Windows.TInputRecord;
    vEventType :TEventType;
  begin
    Result := [];
    if PeekConsoleInput(hStdin, vBuf[0], High(vBuf), DWORD(vCount)) then begin
      for I := 0 to vCount - 1 do begin
        with vBuf[I] do begin
          case EventType of
            KEY_EVENT:
              with Event.KeyEvent do begin
//              TraceF('KEY_EVENT: Char=%d, Ctrl=%d', [Byte(AsciiChar), dwControlKeyState]);
                if bKeyDown then begin
                  if wVirtualKeyCode in [VK_Shift, VK_Control, VK_Menu] then
                    vEventType := cetPrefixKeyDown
                  else
                    vEventType := cetKeyDown
                end else
                  vEventType := cetKeyUp;
              end;    
            _MOUSE_EVENT:
              with Event.MouseEvent do begin
//              TraceF('MOUSE_EVENT: Flags=%d', [dwEventFlags]);
                if (MOUSE_MOVED and dwEventFlags = 0) or (dwButtonState <> 0) then
                  vEventType := cetMousePress
                else
                  vEventType := cetMouseMove
              end;
          else
            vEventType := cetOther;
          end;
        end;
        Result := Result + [vEventType];
      end;
    end;
  end;


  function THintThread.CheckLocation :Boolean;
  var
    vPos  :TPoint;
    vRect :TRect;
    vWin, vConsole :THandle;
  begin
    Result := False;
    vConsole := hConsoleWnd;
    if IsActiveConsole then begin
      GetCursorPos(vPos);
      vWin := WindowFromPoint(vPos);
      if (vWin = vConsole) or FarHints.IsHintWindow(vWin)
        { Поддержка ConEmu с невидимым консольным окном }
        or ((vConsole = hConEmuWnd) and WindowIsChildOf(vConsole, vWin))  
      then begin
        ScreenToClient(vConsole, vPos);
        GetClientRect(vConsole, vRect);
        if PtInRect(vRect, vPos) then
          Result := True;
      end;
    end;
  end;


  function THintThread.GetCallContext :THintCallContext;
  var
    vWinInfo :TWindowInfo;
    vCursorInfo :TConsoleCursorInfo;
    vStr :TString;
  begin
    Result := hccNone;
    if not IsActiveConsole or not ConManIsActiveConsole then
      Exit;

    if (GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0) then
      { Чтобы хинт на сбивал Drag&Drop, да и вообще - нефиг }
      Exit;

    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);
//  TraceF('WindowType=%d', [vWinInfo.WindowType]);
    if vWinInfo.WindowType = WTYPE_PANELS then begin

      GetConsoleCursorInfo(hStdOut, vCursorInfo);
//    TraceF('Cursor=%d', [Byte(vCursorInfo.bVisible)]);
      if not vCursorInfo.bVisible then
        { Нет курсора - значит активна не панель. Этой проверкой отсекаем ситуацию, }
        { когда активно меню и т.п., что не определяется с помощью ACTL_GETWINDOWINFO }
        Exit;

      vStr := GetConsoleTitleStr;
//    TraceF('Title=%s', [vStr]);
      if (vStr = '') or (vStr[1] <> '{') then
        { Этой проверкой отсекаем ситуацию, когда из под Far'а запущена консольная программа }
        Exit;

      Result := hccPanel;

    end else
    begin
      case vWinInfo.WindowType of
        WTYPE_EDITOR:
          Result := hccEditor;
        WTYPE_VIEWER:
          Result := hccViewer;
        WTYPE_DIALOG:
          Result := hccDialog;
      end;
    end;
  end;


  function THintThread.CanCallPluginNow(APanelOnly :Boolean) :Boolean;
  begin
    Result := False;
    case GetCallContext of
      hccPanel:
        Result := FarHintsInPanel;
      hccDialog:
        Result := FarHintsInDialog and not APanelOnly;
//    hccEditor:
//      Result :=
//    hccViewer:
//      Result :=
    end;
  end;


  function THintThread.CheckCurrentPanel(var AFolder :TString; var ACurrent :Integer) :Boolean;
    {-Проверка, что текущая панель видима и содержит элементы. }
    { Вызвается только при автотрекинге клавиатуры }
  var
    vInfo :TPanelInfo;
  begin
    Result := False;
    if GetCallContext <> hccPanel then
      Exit;

//  Trace('FCTL_GetPanelShortInfo...');
    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelShortInfo, @vInfo);
   {$endif bUnicodeFar}

    if (vInfo.Visible = 0) {or not vInfo.Focus} then
      Exit;
    if not (vInfo.PanelType in [PTYPE_FILEPANEL, PTYPE_TREEPANEL]) then
      { Другие типы панелей: PTYPE_QVIEWPANEL or PTYPE_INFOPANEL }
      Exit;
    if (vInfo.PanelType = PTYPE_FILEPANEL) and (vInfo.ItemsNumber = 0) then
      Exit;

   {$ifdef bUnicodeFar}
    AFolder := FarPanelGetCurrentDirectory(INVALID_HANDLE_VALUE);
   {$else}
    AFolder := vInfo.CurDir;
   {$endif bUnicodeFar}
    ACurrent := IntIf(vInfo.PanelType = PTYPE_FILEPANEL, vInfo.CurrentItem, -1);
    Result := True;
  end;



  procedure THintThread.Execute; {override;}
  var
    vStartTime, vLastKeyTime, vLastCheckTime :Cardinal;
    vDelay :Integer;
    vNeedShow :Boolean;
    vCallMode :Integer;
    vInput :TEventTypes;
    vPos, vLastPos :TPoint;
    vFolder, vLastFolder :TString;
    vCurrent, vLastCurrent :Integer;
    vHintForced, vLastForced :Boolean;
    vIsTop, vLastIsTop :Boolean;
    vValid, vLastIsValid :Boolean;
    vWasAlert :Boolean;
  begin
    vDelay := 0;
    vLastKeyTime := 0;
    vLastCheckTime := 0;
    vNeedShow := False;
    
    vCallMode := 0;
    vLastFolder := '';
    vLastCurrent := -1;
    vLastForced := False;
    vLastIsValid := False;
    vWasAlert := False;

    vLastIsTop := True;
    GetCursorPos(vLastPos);

    if True {not IsWindowVisible(hFarWindow)} then begin
      { Главное окно невидимо, возможно - работаем под ConEmu }
      { Выждем небольшую паузу, чтобы успел загрузиться плагин ConEmu.dll }
      { Выжидаем паузу всегда - чтобы Far успел очистить входную очередь событий... } 
      vStartTime := GetTickCount;
      while not Terminated and (TickCountDiff(GetTickCount, vStartTime) < 1500) do
        Sleep(1);
    end;

    vStartTime := 0;
    while not Terminated do begin

      if CanCheckWindow then
        { Контролируем смену консольного окна (на случай Detach'а консоли) }
        hFarWindow := GetConsoleWindow;

      vInput := CheckInput;

      vIsTop := IsActiveConsole;
      vHintForced := (FarHintForceKey <> 0) and (GetKeyState(FarHintForceKey) < 0);

      if FarHintsPermanent then begin
        { Persistent hint гасится при нажатии Alt - благодоря этому }
        { он не подвисает при быстром поиске... }
        vValid := vIsTop and not (GetKeyState(VK_MENU) < 0) and CanCallPluginNow(True);

        if ([cetKeyDown, cetMousePress] * vInput <> []) or (vIsTop <> vLastIsTop) or (vValid <> vLastIsValid) then begin
          vLastIsTop := vIsTop;
          vLastIsValid := vValid;
          GetCursorPos(vLastPos);  { Чтобы потом не появился мышиный курсор }

          if vValid then begin

            { Посылаем команду на вызов хинта в основном потоке }
            ShowHint(3 {Persistent});

            {???}
            { Ждем пока фар не обработает свои сообщения }
            while not Terminated and (cetKeyDown in CheckInput) do
              Sleep(1);

            if Terminated then
              Exit;

            if FarHintsPermanent and CanCallPluginNow(True) then begin
              vNeedShow := True;
              vCallMode := 3;
              vStartTime := GetTickCount;
              vDelay := 300;
            end else
              HideHint;

          end else
            HideHint;
        end;

      end else
      if [cetKeyDown, cetMousePress] * vInput <> [] then begin

        if FarHintsAutoKey and (cetKeyDown in vInput) then begin
          { Запоминаем время последнего нажатия на клавишу, для работы автотрекинга клавиатуры... }
          if GetCallContext = hccPanel then begin
//          Trace('KeyDown in panel');
            vLastKeyTime := GetTickCount
          end else
          begin
//          Trace('KeyDown in ???');
            vLastKeyTime := 0;
          end;
        end;

        if {FarHints.HintVisible and} FarHints.CurrentHintAge >= HideHindAgeLock then begin
          { Хинт виден и достаточно длительное время. Делаем запрос на его сокрытие. }
          { Задержка HideHindAgeLock нужна, чтобы хинт вызываемый вручную, через макрос }
          { не пропадал сразу после появления. }
          if vStartTime = 0 then begin
            vNeedShow := False;
            vStartTime := GetTickCount;
            vDelay := HideHintDelay;
            gHintCommand := False;
          end;
        end else
          { Иначе, просто отменяем запрос на показ (может быть только от мыши) }
          vStartTime := 0;

      end else
      begin
        GetCursorPos(vPos);
        if (vPos.X <> vLastPos.X) or (vPos.Y <> vLastPos.Y) or (vLastForced <> vHintForced) or ((vIsTop <> vLastIsTop) and not vIsTop) then begin
          { Обнаружено перемещение мыши (или нажатие клавиши форсированного вызова) }
          vLastPos := vPos;
          vLastIsTop := vIsTop;

          { Отменяем автотрекинг клавиатуры, если он был... }
          vLastKeyTime := 0;

          if (FarHintsAutoMouse or vHintForced) and vIsTop and CheckLocation { Курсор мыши в окне Far'а } then begin
            vPos := GetConsoleMousePos;
            if FarHints.CurrentHintMode <> hcmMouse then
              { Убиваем клавиатурный хинт }
              HideHint;

            if not FarHints.HintVisible then begin

              if (vLastForced <> vHintForced) and not vHintForced then
                vStartTime := 0
              else begin
                vNeedShow := True;
                vCallMode := 1; {Mouse}
                vStartTime := GetTickCount;
                vDelay := ShowHintFirstDelay
              end;

            end else
            begin
              if not FarHints.InItemRect(vPos) then begin
                vNeedShow := True;
                vCallMode := 1; {Mouse}
                vStartTime := GetTickCount;
                vDelay := 0;
                if not vHintForced then
                  vDelay := ShowHintNextDelay;
                if vDelay > 0 then
                  HideHint;
              end;
            end;
          end else
          begin
            vStartTime := 0;
            HideHint;
          end;

          vLastForced := vHintForced;

        end else
        begin
          if FarHintsAutoKey and (vLastKeyTime <> 0) and (TickCountDiff(GetTickCount, vLastKeyTime) >= ShowHintFirstDelay1) then begin
            { После последнего нажатия на клавишу прошло более ShowHintFirstDelay1...}
            if CheckCurrentPanel(vFolder, vCurrent) and ((vLastCurrent <> vCurrent) or (vLastFolder <> vFolder))  then begin
              { Показываем клавиатурный хинт. Сразу, т.к. пауза уже выдержана }
              vLastCurrent := vCurrent;
              vLastFolder := vFolder;
              vNeedShow := True;
              vCallMode := 2; {Keyboard}
              vStartTime := GetTickCount;
              vDelay := 0;
            end;
            vLastKeyTime := 0;
          end;

          if vIsTop and {FarHints.HintVisible and} (FarHints.CurrentHintAge >= HideHindAgeLock) and (TickCountDiff(GetTickCount, vLastCheckTime) > 100) then begin
            vLastCheckTime := GetTickCount;
            if FarHints.CurrentHintContext <> GetCallContext then begin
              { Чтобы Hint не "подвисал" в недопустимых контекстах }
              vStartTime := 0;
              HideHint;
            end;
          end;

        end;
      end;

      if (vStartTime <> 0) and (TickCountDiff(GetTickCount, vStartTime) >= vDelay) then begin
        try
          vStartTime := 0;
          if vNeedShow then
            { Посылаем команду на вызов хинта в основном потоке }
            ShowHint(vCallMode)
          else begin
            if not gHintCommand then
              HideHint;
          end;

          gHintCommand := False;

        except
          {Nothing...}
        end;
      end;

      if vWasAlert then begin
        { Защита от повышенной загрузки процессора, если Far не чистит консольный буфер. }
        { Например, при запуске внешней программы }
        vWasAlert := False;
        Sleep(10)
      end else
//    if AlertableSleep(IntIf(vIsTop, 1, 100)) then begin
      if AlertableSleep(100) then begin
//      Trace('Alert!');
        vWasAlert := True;
      end;
    end;
  end;


 {$ifdef bSynchroCall}
  function THintThread.ShowHint(ACallMode :Integer) :Boolean;
  begin
    Result := False;
    if not CanCallPluginNow(ACallMode = 3) then
      Exit;

    gCallMode := ACallMode;
//  TraceF('Call plugin: AKey=%d...', [Byte(AKey)]);
    FARAPI.AdvControl(hModule, ACTL_SYNCHRO, nil);
    WaitForCallComplete;
//  Trace('  Done call');
    Result := True;
  end;

 {$else}

  function THintThread.ShowHint(ACallMode :Integer) :Boolean;
  begin
    Result := False;
    if FarHintsKey = 0 then
      Exit;

    if not CanCallPluginNow(ACallMode = 3) then
      Exit;

    gCallMode := ACallMode;
//  TraceF('Call plugin: CallMode=%d', [ACallMode]);
    { Вызовем плагин в основном потоке, через механизм макросов... }
    SendKeys(FarHintsKey, FarHintsShift);
    WaitForCallComplete;
//  Trace('  Done call');
    Result := True;
  end;
 {$endif bSynchroCall}


  procedure THintThread.WaitForCallComplete;
  var
    vStart :Cardinal;
  begin
    vStart := GetTickCount;
    while not Terminated and (gCallMode <> 0) and (TickCountDiff(GetTickCount, vStart) < 1000) do
      Sleep(1);
    gCallMode := 0;
  end;


  procedure THintThread.HideHint;
  begin
    FarHints.HideHint;
  end;


 {-----------------------------------------------------------------------------}

  var
    GHintThread :THintThread;

  procedure SetMouseHook(AOn :Boolean);
  begin
    if AOn <> (GHintThread <> nil) then begin
      if AOn then begin
        GHintThread := THintThread.Create(False);
      end else
      begin
        GHintThread.Terminate;
        GHintThread.WaitFor;
        FreeObj(GHintThread);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CheckPanelExists :Boolean;
  var
    vWinInfo :TWindowInfo;
  begin
    Result := False;
   {$ifdef bUnicodeFar}
    if FARAPI.Control(hModule, FCTL_CHECKPANELSEXIST, 0, nil) = 0 then
   {$else}
    if FARAPI.Control(hModule, FCTL_CHECKPANELSEXIST, nil) = 0 then
   {$endif bUnicodeFar}
      { Нет панелей... }
      Exit;

    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
//  FARAPI.AdvControl(hModule, ACTL_GETWINDOWINFO, @vWinInfo);
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO , @vWinInfo);
    if vWinInfo.WindowType <> WTYPE_PANELS then
      { Активное окно - не панель }
      Exit;

    Result := True;
  end;


  function CheckMouseLocation(AByMousePos :Boolean; const APos :TPoint; var APanelIndex :Integer;
    var APrimaryPanel :Boolean; var AItemRect :TRect) :Boolean;
  var
    vShowTitles :Boolean;
    vShowStatus :Boolean;

    procedure DetectPanelSettings;
    var
      vRes :Integer;
    begin
      vRes := FARAPI.AdvControl(hModule, ACTL_GETPANELSETTINGS, nil);
      vShowTitles := (FPS_SHOWCOLUMNTITLES and vRes) <> 0;
      vShowStatus := (FPS_SHOWSTATUSLINE and vRes) <> 0;
    end;


    function CheckPanel(APrimary :Boolean) :boolean;

      function ColumnsCount(const vInfo :TPanelInfo; var ASubCols :Integer) :Integer;
      var
       {$ifdef bUnicodeFar}
        vTypesStr :TFarStr;
       {$endif bUnicodeFar}
        vStr :PFarChar;
        vChr, vFirst :TChar;
        vSubCol :Integer;
        vPattern :TString;
      begin
        Result := 0;

       {$ifdef bUnicodeFar}
        vTypesStr := FarPanelString(THandle(IntIf(APrimary, PANEL_ACTIVE, PANEL_PASSIVE)), FCTL_GETCOLUMNTYPES);
        vStr := PFarChar(vTypesStr);
       {$else}
        vStr := vInfo.ColumnTypes;
       {$endif bUnicodeFar}
        if vStr = nil then
          Exit;

        ASubCols := 0;
        vSubCol := 0;
        vPattern := '';
        vFirst := CharUpCase(TChar(vStr^));
        while vStr^ <> #0 do begin
          vChr := CharUpCase(TChar(vStr^));
          if vChr = vFirst then begin
            Inc(Result);
            vSubCol := 0;
          end;
          Inc(vSubCol);
          if Result = 1 then begin
            vPattern := vPattern + vChr;
            Inc(ASubCols);
          end else
          begin
            if (vSubCol > ASubCols) or (vChr <> vPattern[vSubCol]) then begin
              ASubCols := 0;
              Result := 1;
              Exit;
            end;
          end;
          Inc(vStr);
          while (vStr^ <> #0) and (vStr^ <> ',') do
            Inc(vStr);
          if vStr^ <> #0 then
            Inc(vStr);
        end;
      end;


      procedure FillWidths(ACount, ASubCols :Integer; AWidths :PIntegerArray; const vInfo :TPanelInfo);
      var
       {$ifdef bUnicodeFar}
        vWidthsStr :TFarStr;
       {$endif bUnicodeFar}
        vCol, vSubCol, vWidth :Integer;
        vStr, vBeg :PFarChar;
        vNum :TFarStr;
      begin
        FillChar(AWidths^, ACount * SizeOf(Integer), 0);
        vCol := 0;
        vSubCol := 0;
       {$ifdef bUnicodeFar}
        vWidthsStr := FarPanelString(THandle(IntIf(APrimary, PANEL_ACTIVE, PANEL_PASSIVE)), FCTL_GETCOLUMNWIDTHS);
        vStr := PFarChar(vWidthsStr);
       {$else}
        vStr := vInfo.ColumnWidths;
       {$endif bUnicodeFar}
        while vStr^ <> #0 do begin
          vBeg := vStr;
          while (vStr^ <> #0) and (vStr^ <> ',') do
            Inc(vStr);
          SetString(vNum, vBeg, vStr - vBeg);
          vWidth := Str2IntDef(vNum, 0);
          Inc(AWidths[vCol], vWidth + 1);
          Inc(vSubCol);
          if vSubCol = ASubCols then begin
            Inc(vCol);
            vSubCol := 0;
          end;
          if vCol = ACount then
            Exit;
          if vStr^ <> #0 then
            Inc(vStr);
        end;
      end;


      function CalcMouseItemIndex(const vInfo :TPanelInfo; const ARect :TRect) :Integer;
        { Попытка вычислить индекс Item'а в позиции мыши... }
      var
        X, Y, I, vCount, vSubCol, vDelta :Integer;
        vWidths :PIntegerArray;
      begin
        Result := -1;
        X := APos.X - ARect.Left;
        Y := APos.Y - ARect.Top;
        if (X < 0) or (Y < 0) then
          Exit;

        AItemRect := Rect(ARect.Left, APos.Y, ARect.Right, APos.Y + 1);
        vCount := ColumnsCount(vInfo, vSubCol);
        if vCount <= 1 then
          Result := Y
        else begin
          Result := 0;
          vWidths := MemAlloc(vCount * SizeOf(Integer));
          try
            FillWidths(vCount, vSubCol, vWidths, vInfo);
            vDelta := 0;
            for I := 0 to vCount - 1 do begin
              Inc(vDelta, vWidths[I]);
              if X < vDelta then
                Break;
              AItemRect.Left := ARect.Left + vDelta;
              Inc(Result, ARect.Bottom - ARect.Top);
            end;
            AItemRect.Right := ARect.Left + vDelta;
            Inc(Result, Y);
          finally
            MemFree(vWidths);
          end;
        end;
      end;


      function CalcCurrentItemIndex(const vInfo :TPanelInfo; const ARect :TRect) :Integer;
      var
        I, vCount, vHeight, vSubCol, vDeltaX, vDeltaY :Integer;
        vWidths :PIntegerArray;
      begin
        Result := vInfo.CurrentItem - vInfo.TopPanelItem;

        vCount := ColumnsCount(vInfo, vSubCol);
        if vCount <= 1 then
          AItemRect := Rect(ARect.Left, ARect.Top + Result, ARect.Right, ARect.Top + Result + 1)
        else begin
          vWidths := MemAlloc(vCount * SizeOf(Integer));
          try
            FillWidths(vCount, vSubCol, vWidths, vInfo);
            vHeight := ARect.Bottom - ARect.Top;
            vDeltaX := 0;
            vDeltaY := Result;
            AItemRect.Left := ARect.Left;
            for I := 0 to vCount - 1 do begin
              Inc(vDeltaX, vWidths[I]);
              if vDeltaY < vHeight then
                Break;
              AItemRect.Left := ARect.Left + vDeltaX;
              Dec(vDeltaY, vHeight);
            end;
            AItemRect.Right := ARect.Left + vDeltaX;
            AItemRect.Top := ARect.Top + vDeltaY;
            AItemRect.Bottom := ARect.Top + vDeltaY + 1;
          finally
            MemFree(vWidths);
          end;
        end;
      end;


    var
      vInfo :TPanelInfo;
      vIndex :Integer;
      vRect :TRect;
    begin {CheckPanel}
      Result := False;

      FillChar(vInfo, SizeOf(vInfo), 0);
     {$ifdef bUnicodefar}
      FARAPI.Control(THandle(IntIf(APrimary, PANEL_ACTIVE, PANEL_PASSIVE)), FCTL_GetPanelInfo, 0, @vInfo);
     {$else}
      FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(APrimary, FCTL_GetPanelShortInfo, FCTL_GetAnotherPanelShortInfo), @vInfo);
     {$endif bUnicodefar}
      if (vInfo.Visible = 0) {or not vInfo.Focus} then
        Exit;

      if vInfo.PanelType = PTYPE_TREEPANEL then begin

        if AByMousePos then
          Exit;

        APanelIndex := -1; {Unknown}
        APrimaryPanel := APrimary;
        Result := True;

      end else
      if vInfo.PanelType = PTYPE_FILEPANEL then begin
//      if ((vInfo.Flags and PFLAGS_REALNAMES) = 0) {or (vInfo.Plugin = 1)} then
//        { Панели не файловых plugin'ов пока не поддерживаются... }
//        Exit;

        if vInfo.ItemsNumber = 0 then
          Exit;

        vRect := vInfo.PanelRect;
        Inc(vRect.Top, 1);
        Inc(vRect.Left, 1);
        if vShowTitles then
          Inc(vRect.Top, 1);
        if vShowStatus then
          Dec(vRect.Bottom, 2);

        if AByMousePos then
          if not PtInRect(vRect, APos) then
            Exit;

        if AByMousePos then
          vIndex := CalcMouseItemIndex(vInfo, vRect)
        else
          vIndex := CalcCurrentItemIndex(vInfo, vRect);
        if vIndex < 0 then
          Exit;

        Inc(vIndex, vInfo.TopPanelItem);
        if vIndex >= vInfo.ItemsNumber then
          Exit;

        APanelIndex := vIndex;
        APrimaryPanel := APrimary;

        Result := True;
      end else
        { Другие типы панелей: PTYPE_QVIEWPANEL or PTYPE_INFOPANEL };
    end;  {CheckPanel}


  begin
//  vByMousePos := (APos.X >= 0) and (APos.Y >= 0);

    Result := CheckPanelExists;
    if not Result then
      Exit;

    DetectPanelSettings;
    if AByMousePos then
      Result := CheckPanel(True) or CheckPanel(False)
    else
      Result := CheckPanel(True);
  end;



  procedure ShowMouseHint;
  var
    vPos, vShowPos :TPoint;
    vItemRect :TRect;
    vIndex :Integer;
    vPrimary :Boolean;
    vInfo :TPanelInfo;
    vTitle :TString;
    vPlugin :Boolean;
    vCurDir :TString;
    vPItem :PPluginPanelItem;
   {$ifdef bUnicodeFar}
    vHandle :THandle;
   {$endif bUnicodeFar}
  begin
    vPos := GetConsoleMousePos;
//  TraceF('ShowMouseHint: %d x %d', [vPos.X, vPos.Y]);

//  vItemRect := Bounds(vPos.X, vPos.Y, 1, 1); ???
    if not CheckMouseLocation(True, vPos, vIndex, vPrimary, vItemRect) then begin
      FarHints.HideHint;
      Exit;
    end;

    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodefar}
    vHandle := THandle(IntIf(vPrimary, PANEL_ACTIVE, PANEL_PASSIVE));
    FARAPI.Control(vHandle, FCTL_GetPanelInfo, 0, @vInfo);
    vCurDir := FarPanelGetCurrentDirectory(vHandle);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(vPrimary, FCTL_GetPanelInfo, FCTL_GetAnotherPanelInfo), @vInfo);
    vCurDir := vInfo.CurDir;
   {$endif bUnicodefar}
    if vIndex >= vInfo.ItemsNumber then begin
      FarHints.HideHint;
      Exit;
    end;

    vPlugin := (vInfo.Plugin <> 0) and ((vInfo.Flags and PFLAGS_REALNAMES) = 0);
    if vPlugin and vPrimary then
      vTitle := ExtractWord(1, GetConsoleTitleStr, ['{', '}']);

   {$ifdef bTrace}
//  TraceF('ShowMouseHint: %d', [vIndex]);
   {$endif bTrace}

   {$ifdef bUnicodeFar}
    vPItem := FarPanelItem(vHandle, FCTL_GETPANELITEM, vIndex);
    try
   {$else}
    vPItem := @vInfo.PanelItems[vIndex];
   {$endif bUnicodefar}

    vShowPos := ConsolePosToWindowPos(vPos.X + 2, vPos.Y + 1);
    if FarHints.ShowHint(hccPanel, hcmMouse, vPlugin, vPrimary, vTitle, vPos.X, vPos.Y, vShowPos.X, vShowPos.Y, @vItemRect, vCurDir, vPItem) then
      {}
    else
      FarHints.HideHint;

   {$ifdef bUnicodefar}
    finally
      MemFree(vPItem);
    end;
   {$endif bUnicodefar}
  end;


  procedure ShowKeyHint;
  var
    vPos :TPoint;
    vItemRect :TRect;
    vIndex :Integer;
    vPrimary :Boolean;
    vInfo :TPanelInfo;
    vTitle :TString;
    vPlugin :Boolean;
    vCurDir :TString;
    vPItem :PPluginPanelItem;
  begin
    if not CheckMouseLocation(False, Point(-1, -1), vIndex, vPrimary, vItemRect) then begin
      FarHints.HideHint;
      Exit;
    end;

    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodefar}
    FARAPI.Control(THandle(PANEL_ACTIVE), FCTL_GetPanelInfo, 0, @vInfo);
    vCurDir := FarPanelGetCurrentDirectory(THandle(PANEL_ACTIVE));
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, @vInfo);
    vCurDir := vInfo.CurDir;
   {$endif bUnicodefar}

    if vInfo.PanelType = PTYPE_TREEPANEL then begin

      with vInfo.PanelRect do
        vPos := ConsolePosToWindowPos(Left + 2, Bottom {- 2});

     {$ifdef bTrace}
//    TraceF('ShowKeyHint: For tree (%s)', [vInfo.CurDir]);
     {$endif bTrace}

      if FarHints.ShowHint(hccPanel, hcmCurrent, False, True, '', -1, -1, vPos.X, vPos.Y, @vItemRect, vCurDir, nil) then
        {}
      else
        FarHints.HideHint;

    end else
    begin
      vIndex := vInfo.CurrentItem;
      if (vIndex < 0) or (vIndex >= vInfo.ItemsNumber) then begin
        FarHints.HideHint;
        Exit;
      end;

      vPlugin := (vInfo.Plugin <> 0) and ((vInfo.Flags and PFLAGS_REALNAMES) = 0);
      if vPlugin and vPrimary then
        vTitle := ExtractWord(1, GetConsoleTitleStr, ['{', '}']);

      vPos := ConsolePosToWindowPos(vItemRect.Left + 2, vItemRect.Top + 1);

     {$ifdef bTrace}
//    TraceF('ShowKeyHint: %d', [vIndex]);
     {$endif bTrace}

     {$ifdef bUnicodeFar}
      vPItem := FarPanelItem(THandle(PANEL_ACTIVE), FCTL_GETPANELITEM, vIndex);
      try
     {$else}
      vPItem := @vInfo.PanelItems[vIndex];
     {$endif bUnicodefar}

      if FarHints.ShowHint(hccPanel, hcmCurrent, vPlugin, True, vTitle, -1, -1, vPos.X, vPos.Y, @vItemRect, vCurDir, vPItem) then
        {}
      else
        FarHints.HideHint;

     {$ifdef bUnicodefar}
      finally
        MemFree(vPItem);
      end;
     {$endif bUnicodefar}
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure ShowMouseHintEdt;
(*
  var
    vPos :TPoint;
    vWinInfo :TWindowInfo;
    vEdtInfo :TEditorInfo;
    vEdtStr :TEditorGetString;
    vStr :TString;
  begin
    vPos := GetConsoleMousePos;
//  TraceF('ShowMouseHintEdt: %d x %d', [vPos.X, vPos.Y]);

    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);
    if not (vWinInfo.WindowType in [WTYPE_EDITOR , WTYPE_VIEWER]) then
      Exit;

    FillChar(vEdtInfo, SizeOf(vEdtInfo), 0);
    FARAPI.EditorControl(ECTL_GETINFO, @vEdtInfo);
    try
      FillChar(vEdtStr, SizeOf(vEdtStr), 0);
      vEdtStr.StringNumber := vEdtInfo.TopScreenLine + vPos.y - 1;
      FARAPI.EditorControl(ECTL_GETSTRING, @vEdtStr);

      vStr := FarChar2Str(vEdtStr.StringText);
//    Trace(vStr);

    finally
     {$ifdef bUnicodefar}
      FARAPI.EditorControl(ECTL_FREEINFO, @vEdtInfo);
     {$endif bUnicodefar}
    end;
*)
  begin
    {};    
  end;


  procedure ShowMouseHintDlg;
  var
    vPos, vShowPos :TPoint;
    vWinInfo :TWindowInfo;
  begin
    vPos := GetConsoleMousePos;
//  TraceF('ShowMouseHintDlg: %d x %d', [vPos.X, vPos.Y]);

    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);
    if not (vWinInfo.WindowType in [WTYPE_DIALOG]) then
      Exit;

    vShowPos := ConsolePosToWindowPos(vPos.X + 2, vPos.Y + 1);

    if FarHints.ShowHint(hccDialog, hcmMouse, {Plugin=}False, {Primary=}True, {Title=}'', vPos.X, vPos.Y, vShowPos.X, vShowPos.Y, nil, '', nil) then
      {}
    else
      FarHints.HideHint;
  end;



  procedure MakeAutoCall(ACallMode :Integer);
  var
    vWinInfo :TWindowInfo;
  begin
    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);
//  TraceF('WindowType=%d', [vWinInfo.WindowType]);
    if ACallMode = 1 then begin
      case vWinInfo.WindowType of
        WTYPE_PANELS:
          ShowMouseHint;
        WTYPE_VIEWER:
          {};
        WTYPE_EDITOR:
          ShowMouseHintEdt;
        WTYPE_DIALOG:
          ShowMouseHintDlg;
      end;
    end else
    if (ACallMode = 2) and (vWinInfo.WindowType = WTYPE_PANELS) then begin
      ShowKeyHint;
    end else
    if (ACallMode = 3) and (vWinInfo.WindowType = WTYPE_PANELS) then begin
      if FarHintsPermanent then
        ShowKeyHint;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure SubpluginCommandsRun(ACmd :Integer);
  begin
    case ACmd of
      1: FarHints.HintCommand(0);
      2: FarHints.HintCommand(1);
      3: FarHints.HideHint;
    end;
  end;


  procedure ShowSubpluginCommands;
  const
    vCount = 4;
  var
    vItems :array[0..3] of TFarMenuItemEx;
    vRes :Integer;
  begin
    FillChar(vItems, SizeOf(vItems), 0);

    if FarHints.HintVisible then begin
      SetMenuItemChr(@vItems[0], '&+ Increase');
      SetMenuItemChr(@vItems[1], '&- Decrease');
      vItems[2].Flags := MIF_SEPARATOR;
      SetMenuItemChr(@vItems[3], '&Close Hint');
    end else
    begin
      SetMenuItemChr(@vItems[0], '+ Increase');
      SetMenuItemChr(@vItems[1], '- Decrease');
      vItems[2].Flags := MIF_SEPARATOR;
      SetMenuItemChr(@vItems[3], 'Close Hint');
    end;

    vRes := FARAPI.Menu(hModule, -1, -1, 0,
      FMENU_WRAPMODE or FMENU_USEEXT,
      GetMsg(strCommandsTitle),
      '',
      '',
      nil, nil,
      @vItems,
      vCount);

    case vRes of
      0: SubpluginCommandsRun(1);
      1: SubpluginCommandsRun(2);
      2: {};
      3: SubpluginCommandsRun(3);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  var
    vItems :array[0..7] of TFarMenuItemEx;
    vRes :Integer;
  begin
    FillChar(vItems, SizeOf(vItems), 0);

    SetMenuItemChr(@vItems[0], GetMsg(strAutoMouse));
    if FarHintsAutoMouse then
      vItems[0].Flags := MIF_CHECKED;

    SetMenuItemChr(@vItems[1], GetMsg(strAutoKey));
    if FarHintsAutoKey then
      vItems[1].Flags := MIF_CHECKED;

    vItems[2].Flags := MIF_SEPARATOR;

    SetMenuItemChr(@vItems[3], GetMsg(strHintInPanel));
    if FarHintsInPanel then
      vItems[3].Flags := MIF_CHECKED;

    SetMenuItemChr(@vItems[4], GetMsg(strHintInDialog));
    if FarHintsInDialog then
      vItems[4].Flags := MIF_CHECKED;

    vItems[5].Flags := MIF_SEPARATOR;

    SetMenuItemChr(@vItems[6], GetMsg(strShellThumbnail));
    if FarHintUseThumbnail then
      vItems[6].Flags := MIF_CHECKED;

    SetMenuItemChr(@vItems[7], GetMsg(strIconOnThumbnail));
    if FarHintIconOnThumb then
      vItems[7].Flags := MIF_CHECKED;

    vRes := FARAPI.Menu(hModule, -1, -1, 0,
      FMENU_WRAPMODE or FMENU_USEEXT,
      GetMsg(strOptionsTitle),
      '',
      '',
      nil, nil,
      @vItems,
      High(vItems)+1);
    if vRes = -1 then
      Exit;

    case vRes of
      0: FarHintsAutoMouse := not FarHintsAutoMouse;
      1: FarHintsAutoKey := not FarHintsAutoKey;

      3: FarHintsInPanel := not FarHintsInPanel;
      4: FarHintsInDialog := not FarHintsInDialog;

      6: FarHintUseThumbnail := not FarHintUseThumbnail;
      7: FarHintIconOnThumb := not FarHintIconOnThumb;
    end;

    WriteSomeSettings(FRegRoot);
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := $02A80200;  { Need 2.0.680 }
//  Result := $02F40200;  { Need 2.0.756 }
//  Result := $03150200;  { Need 2.0.789 }
    Result := $03E30200;  { Need 2.0.995 }   { Изменена TWindowInfo }
  end;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
 {$endif bUnicodeFar}
  var
    vStr :TString;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);

    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

//  vRes := FARAPI.AdvControl(hModule, ACTL_GETFARVERSION, nil);

    { Получаем Handle консоли Far'а }
    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
//  hMainThread := GetCurrentThreadID;
    FRegRoot := psi.RootKey;

    InitConsoleProc;
//  hConWindow := GetConsoleWindow;
    CanCheckWindow := GetConsoleWindow = hFarWindow;

    FarHints := TFarHintsMain.Create;

    vStr := AddFileName(ExtractFilePath(psi.ModuleName), cPluginsFolder);
    FarHints.Plugins.ScanPlugins(vStr);

    ReadSetup(FRegRoot);
//  ReadSettings(FarHints.RegRoot);

    SetMouseHook(FarHintsEnabled);
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;

 {$ifdef bUnicodeFar}
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
 {$else}
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('GetPluginInfo: %s', ['']);

    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginMenuStrings:= @PluginMenuStrings;
    pi.PluginMenuStringsNumber:= 1;

    pi.Reserved := cPluginGUID;
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
//  Trace('ExitFAR');

    SetMouseHook(False);
    FarHints.Free;
    FarHints := nil;
   {$ifdef bThumbnail}
    DoneThumbnailThread;
   {$endif bThumbnail}
  end;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr) :THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item :TIntPtr) :THandle; stdcall;
 {$endif bUnicodeFar}

    procedure LocAction(ACode :Integer);
    begin
      case ACode of
        0: MakeAutoCall(gCallMode);

        1:
        case OpenFrom of
          OPEN_PLUGINSMENU, OPEN_COMMANDLINE:
            ShowMouseHint;
//        OPEN_EDITOR, OPEN_VIEWER:
//          ShowMouseHintEdt;
          OPEN_DIALOG:
            ShowMouseHintDlg;
        end;

        2: ShowKeyHint;

        3:
        begin
          FarHintsPermanent := not FarHintsPermanent;
          if FarHintsPermanent then
            ShowKeyHint
          else
            FarHints.HideHint;
        end;

        4: ShowSubpluginCommands;

        5: OptionsMenu;

        41..49:
          SubpluginCommandsRun(ACode mod 10);
      end;
    end;

  var
    vItems :array[0..5] of TFarMenuItemEx;
    vRes :Integer;
  begin
    Result:= INVALID_HANDLE_VALUE;
    try
//    TraceF('OpenPlugin: From=%d, Item=%d, CallMode=%d', [OpenFrom, Item, gCallMode]);

      gHintCommand := True;

      if OpenFrom and OPEN_FROMMACRO <> 0 then begin
        { Быстрый вызов, через CallPlugin}
        OpenFrom := OpenFrom and not OPEN_FROMMACRO;
        LocAction(Item);
      end else
      begin
        FillChar(vItems, SizeOf(vItems), 0);
        SetMenuItemChr(@vItems[0], GetMsg(strMouseHint));
        SetMenuItemChr(@vItems[1], GetMsg(strCurItemHint));

        SetMenuItemChr(@vItems[2], GetMsg(strPermanentHint));
        if FarHintsPermanent then
          vItems[2].Flags := MIF_CHECKED;

        SetMenuItemChr(@vItems[3], GetMsg(strHintCommands));

        vItems[4].Flags := MIF_SEPARATOR;

        SetMenuItemChr(@vItems[5], GetMsg(strOptions));

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strTitle),
          '',
          '',
          nil, nil,
          @vItems,
          High(vItems)+1);

        case vRes of
          0: LocAction(1);
          1: LocAction(2);
          2: LocAction(3);
          3: LocAction(4);
          5: LocAction(5);
        end;
      end;

      gCallMode := 0;

    except
      on E :Exception do begin
        ShowMessage('FarHints', E.Message, FMSG_WARNING or FMSG_MB_OK);
        gCallMode := 0;
      end;
    end;
  end;


 {$ifdef bSynchroCall}
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, TUnsPtr(Param)]);

    Result := 0;
    try
      try
        if Event <> SE_COMMONSYNCHRO then
          Exit;

        MakeAutoCall(gCallMode);

      finally
        gCallMode := 0;
      end;
    except
      on E :Exception do
        ShowMessage('FarHints', E.Message, FMSG_WARNING or FMSG_MB_OK);
    end;
  end;
 {$endif bSynchroCall}


 {-----------------------------------------------------------------------------}
 { Embedded plugin support                                                     }

  function GetFarHinstAPI :IFarHintsAPI; stdcall;
  begin
    Result := FarHints;
  end;


end.


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

    Far_API,
    FarCtrl,
    FarConfig,
    FarPlug,
    FarConMan,
    FarMenu,

    FarHintsConst,
    FarHintsAPI,
    FarHintsReg,
    FarHintsUtils,
    FarHintsPlugins,
    FarHintsClasses;


  type
    TFarHinstPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
     {$endif Far3}
      procedure SynchroEvent(AParam :Pointer); override;
      procedure Configure; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FInited :Boolean;

      procedure InitSubplugins;
    end;

    
 {$ifdef b64}
 { Для совместимости с FreePascal }
  function GetFarHinstAPI :Pointer; stdcall;
 {$else}
  function GetFarHinstAPI :IFarHintsAPI; stdcall;
 {$endif b64}

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    gCallMode       :Integer;
    gHintCommand    :Boolean;

  var
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

    { Коррекция для режима "большого буфера" (/w) }
    with FarGetWindowRect do begin
//    TraceF('FWR: %d-%d, %d-%d', [Top, Bottom, Left, Right]);
      Dec(Result.Y, Top);
      Dec(Result.X, Left);
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

    { Коррекция для режима "большого буфера" (/w) }
    with FarGetWindowRect do begin
//    TraceF('FWR: %d-%d, %d-%d', [Top, Bottom, Left, Right]);
      Inc(AY, Top);
      Inc(AX, Left);
    end;

    with vInfo.srWindow do begin
      Result.Y := MulDiv(AY - Top, vRect.Bottom, Bottom - Top + 1);
      Result.X := MulDiv(AX - Left, vRect.Right, Right - Left + 1);
    end;

    ClientToScreen(vWnd, Result);
  end;



  function FarPanelShowColumnTitles :Boolean;
  begin
   {$ifdef Far3}
    Result := FarGetSetting(FSSF_PANELLAYOUT, 'ColumnTitles') <> 0;
   {$else}
    Result := FarAdvControl(ACTL_GETPANELSETTINGS, nil) and FPS_SHOWCOLUMNTITLES <> 0;
   {$endif Far3}
  end;


  function FarPanelShowStatusLine :Boolean;
  begin
   {$ifdef Far3}
    Result := FarGetSetting(FSSF_PANELLAYOUT, 'StatusLine') <> 0;
   {$else}
    Result := FarAdvControl(ACTL_GETPANELSETTINGS, nil) and FPS_SHOWSTATUSLINE <> 0;
   {$endif Far3}
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
    vWinType :Integer;
    vCursorInfo :TConsoleCursorInfo;
    vStr :TString;
  begin
    Result := hccNone;
    if not IsActiveConsole or not ConManIsActiveConsole then
      Exit;

    if (GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0) then
      { Чтобы хинт на сбивал Drag&Drop, да и вообще - нефиг }
      Exit;

    vWinType := FarGetWindowType;
//  TraceF('WindowType=%d', [vWinType]);
    if vWinType = WTYPE_PANELS then begin

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
      case vWinType of
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
    FarGetPanelInfo(True, vInfo);
    if not IsVisiblePanel(vInfo) then
      Exit;
    if not (vInfo.PanelType in [PTYPE_FILEPANEL, PTYPE_TREEPANEL]) then
      { Другие типы панелей: PTYPE_QVIEWPANEL or PTYPE_INFOPANEL }
      Exit;
    if (vInfo.PanelType = PTYPE_FILEPANEL) and (vInfo.ItemsNumber = 0) then
      Exit;

    AFolder := FarPanelGetCurrentDirectory;
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
    vCurHintMode :THintCallMode;
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

        if (FarHints.CurrentHintMode <> hcmInfo) and (FarHints.CurrentHintAge >= HideHindAgeLock) then begin
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

            vCurHintMode := FarHints.CurrentHintMode;
            if vCurHintMode = hcmCurrent then
              { Убиваем клавиатурный хинт }
              HideHint;

            if vCurHintMode <> hcmMouse then begin
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
            if FarHints.CurrentHintMode <> hcmInfo then
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

          if vIsTop and (FarHints.CurrentHintMode <> hcmInfo) and (FarHints.CurrentHintAge >= HideHindAgeLock) and (TickCountDiff(GetTickCount, vLastCheckTime) > 100) then begin
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
    FarAdvControl(ACTL_SYNCHRO, nil);
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
   {$ifdef bTrace1}
    TraceF('Call plugin: CallMode=%d', [ACallMode]);
   {$endif bTrace1}
    { Вызовем плагин в основном потоке, через механизм макросов... }
    SendKeys(FarHintsKey, FarHintsShift);
    WaitForCallComplete;
   {$ifdef bTrace1}
    Trace('  Done call');
   {$endif bTrace1}
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
  begin
    Result := False;
    if FARAPI.Control({$ifdef Far3}INVALID_HANDLE_VALUE{$else}hModule{$endif}, FCTL_CHECKPANELSEXIST, 0, nil) = 0 then
      { Нет панелей... }
      Exit;

    if FarGetWindowType <> WTYPE_PANELS then
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
    begin
      vShowTitles := FarPanelShowColumnTitles;
      vShowStatus := FarPanelShowStatusLine
    end;


    function CheckPanel(APrimary :Boolean) :boolean;

      function ColumnsCount(const vInfo :TPanelInfo; var ASubCols :Integer) :Integer;
      var
        vTypesStr :TFarStr;
        vStr :PFarChar;
        vChr, vFirst :TChar;
        vSubCol :Integer;
        vPattern :TString;
      begin
        Result := 0;

        vTypesStr := FarPanelString(HandleIf(APrimary, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_GETCOLUMNTYPES);
        vStr := PFarChar(vTypesStr);
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
        vWidthsStr :TFarStr;
        vCol, vSubCol, vWidth :Integer;
        vStr, vBeg :PFarChar;
        vNum :TFarStr;
      begin
        FillChar(AWidths^, ACount * SizeOf(Integer), 0);
        vCol := 0;
        vSubCol := 0;
        vWidthsStr := FarPanelString(HandleIf(APrimary, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_GETCOLUMNWIDTHS);
        vStr := PFarChar(vWidthsStr);
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

      FarGetPanelInfo(APrimary, vInfo);
      if not IsVisiblePanel(vInfo) then
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
    vHandle :THandle;
  begin
    vPos := GetConsoleMousePos;
//  TraceF('ShowMouseHint: %d x %d', [vPos.X, vPos.Y]);

//  vItemRect := Bounds(vPos.X, vPos.Y, 1, 1); ???
    if not CheckMouseLocation(True, vPos, vIndex, vPrimary, vItemRect) then begin
      FarHints.HideHint;
      Exit;
    end;

    vHandle := HandleIf(vPrimary, PANEL_ACTIVE, PANEL_PASSIVE);
    FarGetPanelInfo(vHandle, vInfo);
    vCurDir := FarPanelGetCurrentDirectory(vHandle);
    if vIndex >= vInfo.ItemsNumber then begin
      FarHints.HideHint;
      Exit;
    end;

    vPlugin := IsPluginPanel(vInfo) and (vInfo.Flags and PFLAGS_REALNAMES = 0);
    if vPlugin and vPrimary then
      vTitle := ExtractWord(1, GetConsoleTitleStr, ['{', '}']);

   {$ifdef bTrace1}
//  TraceF('ShowMouseHint: %d', [vIndex]);
   {$endif bTrace1}

    vPItem := FarPanelItem(vHandle, FCTL_GETPANELITEM, vIndex);
    try
      vShowPos := ConsolePosToWindowPos(vPos.X + 2, vPos.Y + 1);
      if FarHints.ShowHint(hccPanel, hcmMouse, vPlugin, vPrimary, vTitle, vPos.X, vPos.Y, vShowPos.X, vShowPos.Y, @vItemRect, vCurDir, vPItem) then
        {}
      else
        FarHints.HideHint;
    finally
      MemFree(vPItem);
    end;
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

    FarGetPanelInfo(True, vInfo);
    vCurDir := FarPanelGetCurrentDirectory;

    if vInfo.PanelType = PTYPE_TREEPANEL then begin

      with vInfo.PanelRect do
        vPos := ConsolePosToWindowPos(Left + 2, Bottom {- 2});

     {$ifdef bTrace1}
//    TraceF('ShowKeyHint: For tree (%s)', [vInfo.CurDir]);
     {$endif bTrace1}

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

      vPlugin := IsPluginPanel(vInfo) and (vInfo.Flags and PFLAGS_REALNAMES = 0);
      if vPlugin and vPrimary then
        vTitle := ExtractWord(1, GetConsoleTitleStr, ['{', '}']);

      vPos := ConsolePosToWindowPos(vItemRect.Left + 2, vItemRect.Top + 1);

     {$ifdef bTrace1}
//    TraceF('ShowKeyHint: %d', [vIndex]);
     {$endif bTrace1}

      vPItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
      try
        if FarHints.ShowHint(hccPanel, hcmCurrent, vPlugin, True, vTitle, -1, -1, vPos.X, vPos.Y, @vItemRect, vCurDir, vPItem) then
          {}
        else
          FarHints.HideHint;
      finally
        MemFree(vPItem);
      end;
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
      FARAPI.EditorControl(ECTL_FREEINFO, @vEdtInfo);
    end;
*)
  begin
    {};    
  end;


  procedure ShowMouseHintDlg;
  var
    vPos, vShowPos :TPoint;
  begin
    vPos := GetConsoleMousePos;
//  TraceF('ShowMouseHintDlg: %d x %d', [vPos.X, vPos.Y]);

    if not (FarGetWindowType in [WTYPE_DIALOG]) then
      Exit;

    vShowPos := ConsolePosToWindowPos(vPos.X + 2, vPos.Y + 1);

    if FarHints.ShowHint(hccDialog, hcmMouse, {Plugin=}False, {Primary=}True, {Title=}'', vPos.X, vPos.Y, vShowPos.X, vShowPos.Y, nil, '', nil) then
      {}
    else
      FarHints.HideHint;
  end;



  procedure MakeAutoCall(ACallMode :Integer);
  var
    vWinType :Integer;
  begin
    vWinType := FarGetWindowType;
//  TraceF('WindowType=%d', [vWinType]);
    if ACallMode = 1 then begin
      case vWinType of
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
    if (ACallMode = 2) and (vWinType = WTYPE_PANELS) then begin
      ShowKeyHint;
    end else
    if (ACallMode = 3) and (vWinType = WTYPE_PANELS) then begin
      if FarHintsPermanent then
        ShowKeyHint;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure SubpluginCommandsRun(ACmd :Integer);
  begin
    case ACmd of
      1: FarHints.HintCommand(cmhResize, 1);
      2: FarHints.HintCommand(cmhResize, -1);
      3: FarHints.HideHint;
    end;
  end;


  procedure ShowSubpluginCommands;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCommandsTitle),
    [
      '&+ Increase',
      '&- Decrease',
      '',
      '&Close Hint'
    ]);

    try
      vMenu.Enabled[0] := FarHints.HintVisible;
      vMenu.Enabled[1] := FarHints.HintVisible;
      vMenu.Enabled[3] := FarHints.HintVisible;

      if not vMenu.Run then
        Exit;

      SubpluginCommandsRun( vMenu.ResIdx + IntIf(vMenu.ResIdx < 2, 1, 0) );

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle),
    [
      GetMsg(strAutoMouse),
      GetMsg(strAutoKey),
      '',
      GetMsg(strHintInPanel),
      GetMsg(strHintInDialog),
      '',
      GetMsg(strShowIcons),
      GetMsg(strShellThumbnail),
      GetMsg(strIconOnThumbnail)
    ]);

    try
      while True do begin
        vMenu.Checked[0] := FarHintsAutoMouse;
        vMenu.Checked[1] := FarHintsAutoKey;
        vMenu.Checked[3] := FarHintsInPanel;
        vMenu.Checked[4] := FarHintsInDialog;
        vMenu.Checked[6] := FarHintShowIcon;
        vMenu.Checked[7] := FarHintUseThumbnail;
        vMenu.Checked[8] := FarHintIconOnThumb;

        vMenu.SetSelected(vMenu.ResIdx);
        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: FarHintsAutoMouse := not FarHintsAutoMouse;
          1: FarHintsAutoKey := not FarHintsAutoKey;

          3: FarHintsInPanel := not FarHintsInPanel;
          4: FarHintsInDialog := not FarHintsInDialog;

          6: FarHintShowIcon := not FarHintShowIcon;
          7: FarHintUseThumbnail := not FarHintUseThumbnail;
          8: FarHintIconOnThumb := not FarHintIconOnThumb;
        end;

        WriteSomeSettings;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function PluginCommand(ACmd :Integer) :Boolean;
  begin
    Result := True;
    case ACmd of
      0: MakeAutoCall(gCallMode);

      1:
      case FarGetWindowType of
        WTYPE_PANELS:
          ShowMouseHint;
//      WTYPE_EDITOR, WTYPE_VIEWER:
//        ShowMouseHintEdt;
        WTYPE_DIALOG:
          ShowMouseHintDlg;
      else
        Result := False;
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
        SubpluginCommandsRun(ACmd mod 10);

    else
      Result := False
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFarHinstPlug                                                               }
 {-----------------------------------------------------------------------------}

  procedure TFarHinstPlug.Init; {override;}
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
//  FMinFarVer := MakeVersion(3, 0, 2572);   { Api changes }
//  FMinFarVer := MakeVersion(3, 0, 2851);   { LUA }
    FMinFarVer := MakeVersion(3, 0, 2927);   { Release }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1573);   { ACTL_GETFARRECT }
   {$endif Far3}
  end;


  procedure TFarHinstPlug.Startup; {override;}
  begin
    { Получаем Handle консоли Far'а }
    hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
//  hMainThread := GetCurrentThreadID;

    InitConsoleProc;
//  hConWindow := GetConsoleWindow;
    CanCheckWindow := GetConsoleWindow = hFarWindow;

    FarHints := TFarHintsMain.Create;
//  InitSubplugins;
    FarAdvControl(ACTL_SYNCHRO, scmInitSubPlugins);
  end;


  procedure TFarHinstPlug.InitSubplugins;
  var
    vStr :TString;
  begin
    if FInited then
      Exit;

    vStr := AddFileName(ExtractFilePath(FARAPI.ModuleName), cPluginsFolder);
    FarHints.Plugins.ScanPlugins(vStr);

    ReadSetup;
//  ReadSettings;

    SetMouseHook(FarHintsEnabled);
    FInited := True;
  end;


  procedure TFarHinstPlug.ExitFar; {override;}
  begin
    SetMouseHook(False);
    FarHints.Free;
    FarHints := nil;
   {$ifdef bThumbnail}
    DoneThumbnailThread;
   {$endif bThumbnail}
  end;


  procedure TFarHinstPlug.GetInfo; {override;}
  begin
    FFlags := PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID  := cConfigID;
   {$endif Far3}
  end;


  function TFarHinstPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  var
    vMenu :TFarMenu;
  begin
    Result:= INVALID_HANDLE_VALUE;

    gHintCommand := True;
    InitSubplugins;

    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMouseHint),
      GetMsg(strCurItemHint),
      GetMsg(strPermanentHint),
      GetMsg(strHintCommands),
      '',
      GetMsg(strOptions)
    ]);
    try
      vMenu.Checked[2] := FarHintsPermanent;

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: PluginCommand(1);
        1: PluginCommand(2);
        2: PluginCommand(3);
        3: PluginCommand(4);
        5: PluginCommand(5);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  function TFarHinstPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result := 0;
    InitSubplugins;
    gHintCommand := True;
    if AStr = nil then
      if PluginCommand(AInt) then
        Result := INVALID_HANDLE_VALUE;
  end;


 {$ifdef Far3}
  function MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :Boolean;

    procedure LocShowInfo;
    var
      vStr :TString;
      vInt, vDelay :Integer;
      vConPos, vWinPos :TPoint;
      vInfo :TConsoleScreenBufferInfo;
    begin
      vStr := '';
      vDelay := InfoHintPeriod;
      vConPos.X := -1;
      vConPos.Y := -3;

      if (ACount >= 2) and (AParams[1].fType = FMVT_STRING) then
        vStr := AParams[1].Value.fString;
      if (ACount >= 3) and FarValueIsInteger(AParams[2], vInt) then
        vConPos.X := vInt;
      if (ACount >= 4) and FarValueIsInteger(AParams[3], vInt) then
        vConPos.Y := vInt;
      if (ACount >= 5) and FarValueIsInteger(AParams[4], vInt) then
        vDelay := vInt;

      if vConPos.y < 0 then begin
//      vConPos.y := FarGetWindowRect.Bottom + vConPos.y + 1;
        GetConsoleScreenBufferInfo(hStdOut, vInfo);
        vConPos.y := vInfo.srWindow.Bottom - vInfo.srWindow.Top + vConPos.y + 1;
      end;
      vWinPos := ConsolePosToWindowPos(vConPos.X, vConPos.Y);
      if vConPos.x = -1 then
        vWinPos.x := -1;

//    if vStr <> '' then
        Result := FarHints.ShowInfo(vStr, vWinPos.X, vWinPos.Y, vDelay)
//    else begin
//      if FarHints.CurrentHintMode = hcmInfo then
//        FarHints.HideHint;
//    end;
    end;

  var
    vMouse :Boolean;
    vInt :Integer;
  begin
    Result := False;
    if StrEqual(ACmd, 'Info') then
      LocShowInfo
    else
    if StrEqual(ACmd, 'Hide') then
      Result := FarHints.HideHint
    else
    if StrEqual(ACmd, 'Show') then begin
      vMouse := True;
      if (ACount >= 2) and FarValueIsInteger(AParams[1], vInt) then
        vMouse := vInt = 1;
      Result := PluginCommand(IntIf(vMouse, 1, 2));
    end else
    if StrEqual(ACmd, 'Size') then begin
      if (ACount >= 2) and FarValueIsInteger(AParams[1], vInt) and (vInt <> 0) then
        Result := FarHints.HintCommand(cmhResize, vInt);
    end else
    if StrEqual(ACmd, 'Color') then begin
      if (ACount >= 2) and FarValueIsInteger(AParams[1], vInt) then
        Result := FarHints.HintCommand(cmhColor, vInt);
    end else
    if StrEqual(ACmd, 'FontSize') then begin
      if (ACount >= 2) and FarValueIsInteger(AParams[1], vInt) then
        Result := FarHints.HintCommand(cmhFontSize, vInt);
    end else
    if StrEqual(ACmd, 'FontColor') then begin
      if (ACount >= 2) and FarValueIsInteger(AParams[1], vInt) then
        Result := FarHints.HintCommand(cmhFontColor, vInt);
    end else
    if StrEqual(ACmd, 'Transparency') then begin
      if (ACount >= 2) and FarValueIsInteger(AParams[1], vInt) then
        Result := FarHints.HintCommand(cmhTransparent, vInt);
    end;
  end;


  function TFarHinstPlug.OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {override;}
  begin
    Result := 0;
    if (ACount = 0) or ((ACount = 1) and (AParams[0].fType = FMVT_INTEGER)) then
      Result := inherited OpenMacroEx(ACount, AParams)
    else
    if AParams[0].fType = FMVT_STRING then begin
      InitSubplugins;
      gHintCommand := True;
      if MacroCommand(AParams[0].Value.fString, ACount, AParams) then
        Result := 1{INVALID_HANDLE_VALUE};
    end;
  end;
 {$endif Far3}


  procedure TFarHinstPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
    if AParam = scmInitSubPlugins then
      InitSubplugins
    else
    if AParam = scmHideHint then
      FarHints.HideHint
    else
    if AParam = scmSaveSettings then
      WriteSizeSettings
    else
      MakeAutoCall(gCallMode);
    gCallMode := 0;
  end;


  procedure TFarHinstPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  procedure TFarHinstPlug.ErrorHandler(E :Exception); {override;}
  begin
    inherited ErrorHandler(E);
    gCallMode := 0;
  end;


 {-----------------------------------------------------------------------------}
 { Embedded plugin support                                                     }

 {$ifdef b64}
  function GetFarHinstAPI :Pointer; stdcall;
  begin
    Result := IFarHintsApi(FarHints);
  end;
 {$else}
  function GetFarHinstAPI :IFarHintsAPI; stdcall;
  begin
    Result := FarHints;
  end;
 {$endif b64}


end.


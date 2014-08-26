{$I Defines.inc}

unit ReviewMain;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

{
ToDo:
  * Slideshow
    - Режим показа media-файлов
    - Глюк плавного перехода (?)

  - Tags: отображение Разрешения

  - Кэширование декодеров: "наследование" списка расширений

  - DXVideo.pvd
    - Показывать скрытый OSD при управлении с клавиатуры
    - Глючит с ConEmu
    - Управление через макросы
    * Улучшенное качество (?)

  - GFL.pvd
    - Запрос информации через EXIF2

  - Глючит позиционирование окна QuickView в режиме Far Fullscreen
  - Глючит: QuicView-F3-PgDn-Esc


На будущее:
  + Поддержка PVD v1
  - Поддержка PVD v3
  - Popup меню
  - Копирование в clipboard
  - SaveAs: форматы Bitmaps
  - SaveAs: для *.pvd декодеров
  - Декодирование с экранным разрешением для *.pvd декодеров

Ready:
  + Help
  + Выделение
  + Fulscreen mode
  + Tile mode
  + Косячат повороты
    + Глючит прогнозирование размеров повернутых изображений
  + Запоминать состояние FullScreen

  + Кэширование декодеров
    + Сохранение кэша при первом запуске

  + Поддержка макросов:
    + Zoom
    + Навигация
    + Повороты
    + Сохранение

  + Сообщение о длительных операциях
    + Сохранение/поворот
    + Национализация
    x Оптимизация (?)

  * Сохранение картинок
    + Сохранение даты файла при сохранении
    + Уникальные имена бэкапов
    + Обработка ошибок сохранения
    + Перечитывание после сохранения (или сброс ориентации?)
    + Блокировка изображения при фоновом декодировании...
      + Удаление временного файла при ошибках

  * Видео:
    + DoubleClick - Fullscreen
    + Улучшенная навигация через трекер
    + Управление с клавиатуры
      + Позиционирование
      + Play/Pause
    + Управление громкостью


  - Настройки
    + Диалог настроек
      + Национализация
      + Запрещение команд
      + Настройка префикса

    * Настройки декодеров
      + Сохранение настроек
      + Поддержка свойства Enable
      + Национализация
      + Кнопка "Загрузить"
      + Информация о декодере + состояние
      + Кнопка "Восстановить умолчания"
      - Настройка ширин столбцов

  + Поддержка Detach Console
  + Поддержка ConEmu

  + Улучшенный вывод информации
    + Свертка длинных строк
    + Затенение фона
  + Показ Tag'ов
    + Локализация Tag'ов
    + Нормализация дат

  + Slideshow
}

interface

  uses
    Windows,
    ActiveX,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMenu,
    FarPlug,

    ReviewConst,
    ReviewDecoders,
    ReviewClasses;

  type
    TReviewPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;

//    function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
     {$endif Far3}

      function ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      procedure SynchroEvent(AParam :Pointer); override;

    private
      FCmdWords  :TKeywordsList;

     {$ifdef Far3}
      function MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;
     {$endif Far3}
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TReviewPlug                                                                 }
 {-----------------------------------------------------------------------------}

  procedure TReviewPlug.Init; {override;}
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
    FMinFarVer := MakeVersion(3, 0, 3000);   { LUA }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1800);   { OPEN_FROMMACROSTRING, MCMD_POSTMACROSTRING };
   {$endif Far3}
  end;


  procedure TReviewPlug.Startup; {override;}
  begin
    { Получаем Handle консоли Far'а }
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    FFarExePath := AddBackSlash(ExtractFilePath(GetExeModuleFileName));

    RestoreDefColor;
    PluginConfig(False);

    Review := TReviewManager.Create;
    Review.InitSubplugins;
  end;


  procedure TReviewPlug.ExitFar; {override;}
  begin
    FreeObj(FCmdWords);
    FreeObj(Review);
  end;


  procedure TReviewPlug.GetInfo; {override;}
  begin
    FFlags:= {PF_PRELOAD or PF_EDITOR or} PF_VIEWER;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    if optCmdPrefix <> '' then
      FPrefix := PTChar(optCmdPrefix);
  end;



  function TReviewPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}

    function IsRealFile :Boolean;
    var
      vInfo :TPanelInfo;
    begin
      Result := False;
      if (FarGetMacroArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}]) and (FarGetWindowType = WTYPE_PANELS) then
        if FarGetPanelInfo(True, vInfo) {and IsVisiblePanel(vInfo)} and (vInfo.PanelType = PTYPE_FILEPANEL) then
          Result := not IsPluginPanel(vInfo) or (vInfo.Flags and PFLAGS_REALNAMES <> 0);
    end;

  begin
    Result:= INVALID_HANDLE_VALUE;
    case AFrom of
      OPEN_PLUGINSMENU:
        if IsRealFile then begin
          if Review.ShowImage('', 0, True) then
            ViewModalState(False, False);
        end else
        begin
          Review.SetForceFile(FarPanelItemName(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0), 2);
          FarPostMacro('Keys("F3")');
        end;  

      OPEN_VIEWER:
        if Review.ShowImage(ViewerControlString(VCTL_GETFILENAME), 0, True) then
          ViewModalState(False, False);

//    OPEN_ANALYSE:
//      {};
    end;
  end;


  function TReviewPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vName :TString;
  begin
    Result:= INVALID_HANDLE_VALUE;
    if not optProcessPrefix then
      Exit;

    if (AStr = nil) or (AStr^ = #0) then
      {}
    else begin
      vName := AStr;
      if (vName <> '') and (vName[1] = '"') and (vName[length(vName)] = '"') then
        vName := Copy(vName, 2, length(vName) - 2);
      vName := FarExpandFileName(vName);
      if Review.ShowImage(vName, 0, True) then
        ViewModalState(False, False);
    end;
  end;


  procedure TReviewPlug.Configure; {override;}
  begin
    Review.PluginSetup;
  end;


 {$ifdef Far3}
  function TReviewPlug.OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {override;}
  begin
    Result := 0;
    if (ACount = 0) or ((ACount = 1) and (AParams[0].fType in [FMVT_INTEGER, FMVT_DOUBLE])) then
      Result := inherited OpenMacroEx(ACount, AParams)
    else
    if AParams[0].fType = FMVT_STRING then
      Result := MacroCommand(AParams[0].Value.fString, ACount, AParams);
  end;

  
  const
    kwIsQuickView     = 1;
    kwUpdate          = 2;
    kwGoto            = 3;
    kwPage            = 4;
    kwScale           = 5;
    kwDecoder         = 6;
    kwRotate          = 7;
    kwSave            = 8;
    kwFullscreen      = 9;
    kwSlideShow       = 10;


  function TReviewPlug.MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;

    procedure InitKeywords;
    begin
      if FCmdWords <> nil then
        Exit;

      FCmdWords := TKeywordsList.Create;
      with FCmdWords do begin
        Add('IsQuickView', kwIsQuickView);
        Add('Update', kwUpdate);
        Add('Goto', kwGoto);
        Add('Page', kwPage);
        Add('Scale', kwScale);
        Add('Decoder', kwDecoder);
        Add('Rotate', kwRotate);
        Add('Save', kwSave);
        Add('Fullscreen', kwFullscreen);
        Add('SlideShow', kwSlideShow);
      end;
    end;

    
    function LocGoto :TIntPtr;
    var
      vOrig, vDir :Integer;
      vRes :Boolean;
    begin
      vRes := False;
      vOrig := FarValuesToInt(AParams, ACount, 1, -1);
      vDir := FarValuesToInt(AParams, ACount, 2, 1);
      if (vOrig >= 0) and (vOrig <= 2) then begin
        vRes := Review.Navigate(vOrig, vDir > 0, optEffectOnManual);
      end else
      if vOrig = 3 then
        vRes := Review.NavigateTo(FarValuesToStr(AParams, ACount, 2, ''));
      Result := FarReturnValues([vRes]);
    end;


    function LocPage :TIntPtr;
    var
      vPage :Integer;
      vImage :TReviewImage;
    begin
      Result := 0;
      vPage := FarValuesToInt(AParams, ACount, 1) - 1;
      if vPage >= 0 then
        Review.SetImagePage(vPage);
      vImage := Review.CurImage;
      if vImage <> nil then
        Result := FarReturnValues([vImage.Page + 1, vImage.Pages]);
    end;


    function LocScale :TIntPtr;
    var
      vMode :TScaleSetMode;
      vValue :Integer;
      vFloat :TFloat;
    begin
      Result := 0;
      vMode := TScaleSetMode(FarValuesToInt(AParams, ACount, 1, 0));
      if vMode = smSetMode then begin
        vValue := FarValuesToInt(AParams, ACount, 2, -1);
        if vValue >= 1 then
          Review.SetScale(vMode, TScaleMode(vValue), 0);
      end else
      if vMode in [smSetScale, smDeltaScale, smDeltaScaleMouse] then begin
        vFloat := FarValuesToFloat(AParams, ACount, 2, 0);
        if vFloat <> 0 then
          Review.SetScale(vMode, smExact, vFloat);
      end;
      if Review.Window <> nil then
        Result := FarReturnValues([byte(Review.Window.ScaleMode), Review.Window.Scale]);
    end;


    function LocDecoder :TIntPtr;
    var
      vMode :Integer;
      vImage :TReviewImage;
    begin
      Result := 0;
      vMode := FarValuesToInt(AParams, ACount, 1, -1);
      if vMode >= 0 then
        Review.Redecode(TRedecodeMode(vMode));
      vImage := Review.CurImage;
      if vImage <> nil then
        Result := FarReturnValues([vImage.Decoder.Name]);
    end;

    function LocRotate :TIntPtr;
    var
      vMode, vValue :Integer;
      vImage :TReviewImage;
    begin
      Result := 0;
      vMode := FarValuesToInt(AParams, ACount, 1, -1);
      vValue := FarValuesToInt(AParams, ACount, 2, -1);
      if vMode <> -1 then
        if vMode = 0 then
          Review.Rotate(vValue)
        else
          Review.Orient(vValue);
      vImage := Review.CurImage;
      if vImage <> nil then
        Result := FarReturnValues([vImage.Orient]);
    end;

    function LocSave :TIntPtr;
    var
      vMode :Byte;
      vRes :Boolean;
    begin
      vMode := FarValuesToInt(AParams, ACount, 1, 0);
      vRes := Review.Save('', '', 0, 0, TSaveOptions(vMode));
      Result := FarReturnValues([vRes]);
    end;

    function LocFullscreen :TIntPtr;
    var
      vMode :Integer;
    begin
      Result := 0;
      if Review.Window <> nil then begin
        vMode := FarValuesToInt(AParams, ACount, 1, -1);
        if vMode >= 0 then
          Review.SetFullscreen(vMode = 1);
        Result := FarReturnValues([Review.Window.WinMode = wmFullscreen]);
      end;
    end;

    function LocSlideShow :TIntPtr;
    var
      vMode :Integer;
    begin
      Result := 0;
      if Review.Window <> nil then begin
        vMode := FarValuesToInt(AParams, ACount, 1, -2);
        if vMode <> -2 then
          Review.SlideShow(vMode, False);
        Result := FarReturnValues([Review.Window.SlideDelay <> 0]);
      end;
    end;

  var
    vCmd :Integer;
  begin
    InitKeywords;
    vCmd := FCmdWords.GetKeywordStr(ACmd);
    Result := 0;
    case vCmd of
      kwIsQuickView:
        Result := FarReturnValues([Review.IsQViewMode]);
      kwUpdate:
        Review.SyncDelayed(SyncCmdUpdateWin, FarValuesToInt(AParams, ACount, 1, optSyncDelay));
      kwGoto:
        Result := LocGoto;
      kwPage:
        Result := LocPage;
      kwScale:
        Result := LocScale;
      kwDecoder:
        Result := LocDecoder;
      kwRotate:
        Result := LocRotate;
      kwSave:
        Result := LocSave;
      kwFullscreen:
        Result := LocFullscreen;
      kwSlideShow:
        Result := LocSlideShow;
    end;
  end;
 {$endif Far3}



  function TReviewPlug.ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  var
    vAltView, vQuickView, vRealNames :Boolean;
    vForce :Integer;
    vInfo :TPanelInfo;
    vName :TString;
  begin
//  TraceF('Event=%d, AParam=%d, AID=%d', [AEvent, TIntPtr(AParam), AID]);

    if AEvent = VE_Read then begin
      vForce := 0;
      try
       {$ifdef Far3}
        vName := ViewerControlString(VCTL_GETFILENAME);
       {$else}
//      vName := FarChar2Str(vInfo.FileName);
       {$endif Far3}

        vQuickView := False; vRealNames := False;
        if (FarGetMacroArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}]) and (FarGetWindowType = WTYPE_PANELS) then
          if FarGetPanelInfo(False, vInfo) {and IsVisiblePanel(vInfo)} and (vInfo.PanelType = PTYPE_QVIEWPANEL) then
            if FarGetPanelInfo(True, vInfo) {and IsVisiblePanel(vInfo)} and (vInfo.PanelType = PTYPE_FILEPANEL) then begin
              vQuickView := True;
              vRealNames := PFLAGS_REALNAMES and vInfo.Flags <> 0;
            end;

        if vQuickView then begin
          if optProcessQView then
            if Review.IsQViewMode and optAsyncQView and vRealNames then
              Review.SyncDelayed(SyncCmdSyncImage, optSyncDelay)
            else
            if Review.ShowImage(vName, 1) then
              { Модальное состояние для QuickView. Плохо, так как не работают макросы... }
              { ViewModalState(True) };
        end else
        begin
          vForce := Review.ForceMode;
          if vForce <> 0 then begin
            if not StrEqual(Review.ForceFile, ExtractFileName(vName)) then
              vForce := 0;
            Review.SetForceFile('', 0);
          end;

          vAltView := (GetKeyState(VK_Menu) < 0) or
            ((GetKeyState(VK_Control) < 0) and (GetKeyState(VK_Shift) < 0));
          if (optProcessView and not vAltView) or (vForce <> 0) then
            if Review.ShowImage(vName, 0, vForce = 2) then  
              ViewModalState(True, False);
        end;
      except
        on E :Exception do begin
          Plug.ErrorHandler(E);
          if vForce = 2 then
            FarPostMacro('Keys("Esc")');
        end;
      end;
    end else
    if AEvent = VE_CLOSE then
      if Review.IsQViewMode then
        Review.SyncDelayed(SyncCmdSyncImage, optSyncDelay);

    Result := 0;
  end;


  procedure TReviewPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
    if Review = nil then
      Exit;

    case TUnsPtr(AParam) of
      SyncCmdUpdateWin   : Review.UpdateWindowPos;
      SyncCmdSyncImage   : Review.SyncWindow;
      SyncCmdUpdateTitle :
        if ModalDlg <> nil then
          ModalDlg.UpdateTitle;
      SyncCmdCacheNext   : Review.CacheNeighbor(True);
      SyncCmdCachePrev   : Review.CacheNeighbor(False);
      SyncCmdNextSlide   : Review.GoNextSlide;
      SyncCmdClose       :
        if ModalDlg = nil then
          Review.CloseWindow;
    end;
  end;


initialization
finalization
end.


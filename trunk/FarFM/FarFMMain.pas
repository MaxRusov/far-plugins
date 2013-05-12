{$I Defines.inc}

unit FarFMMain;

{TODO:

  Настройки:
    - формат Playlist'ов
    - формат имен треков
    - Язык информации

  - Изменение формата отображения трека  
  - Оптимизация навигации (Выход из группы без зпросов)

  - Интеграция с FarHints

  - Показ года альбома
  - Списки Изображений

------------------------------------------

  + Поиск артистов по имени, альбому, треку
    - Подбор цветов...
    - Постраничный вывод

  Скачивание
    + Прерываемое скачивание картинок
    + Удаление недоскаченных файлов
    - Улучшенная обработка ошибок

  Группа Пользователей
    x Поиск пользователей
    + Локализация информации
    + Артисты, Альбомы, треки пользователей
    - плейлисты пользователей ???

------------------------------------------
  + Работа с моим аккаунтом

  + "Удаление" альбомов/треков
  + Показ лирики
  + Поиск альтернативных треков на VK
  + Обновление кэша URL

  + Сортировка списка артистов
  + Поддержка команд (Add, Next)
  + Дозагрузка треков
  + Копирование треков
    + Локализация playlist'ов
    + Копирование альбомов
  + Визуализация найденых треков

  + Обработка timeout'ов VK
  + Кэширование треков VK
  + Прозрачная авторизация на VK
  + Прерываемая загрузка (в отдельном потоке?)
    + Для скачивания изображений

  + Показ информации об артисте, альбоме
  + Списки Similar

  + Поддержка префикса
  + Поддержка истории Far и MoreHistory
}

interface

  uses
    Windows,
    ActiveX,
    MSXML,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    Far_API,  //Plugin3.pas
    FarCtrl,
    FarPlug,
    FarMenu,
    FarDlg,
    FarConfig,
    FarFmCtrl,
    FarFmClasses;


  type
    TFarFMPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure GetInfo; override;
      procedure ExitFar; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
      procedure ClosePanel(AHandle :THandle); override;
      procedure GetPanelInfo(AHandle :THandle; var AInfo :TOpenPanelInfo); override;
      function GetPanelItems(AHandle :THandle; AMode :Integer; var AItems :PPluginPanelItemArray; var ACount :Integer) :boolean; override;
      procedure FreePanelItems(AHandle :THandle; AItems :PPluginPanelItemArray; ACount :Integer); override;
      function PanelSetDirectory(AHandle :THandle; AMode :Integer; ADir :PFarChar) :Boolean; override;
      function PanelMakeDirectory(AHandle :THandle; AMode :Integer; var ADir :TString) :Boolean; override;
      function PanelGetFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer; AMove :boolean; var ADestPath :TString) :Boolean; override;
      function PanelDeleteFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean; override;
      function PanelInput(AHandle :THandle; AKey :Integer) :Boolean; override;
     {$ifdef Far3}
//    function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
     {$endif Far3}
      procedure Configure; override;
      procedure SynchroEvent(AParam :Pointer); override;

      procedure ErrorHandler(E :Exception); override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFarFMPlug                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TFarFMPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison;

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
   {$endif Far3}

   {$ifdef Far3}
    FMinFarVer := MakeVersion(3, 0, 3000);
   {$endif Far3}
  end;


  procedure TFarFMPlug.Startup; {override;}
  begin
    FarFM := TFarFM.Create;
//  PluginConfig(False);
  end;


  procedure TFarFMPlug.ExitFar; {override;}
  begin
//  HookConsole(False);
    FreeObj(FarFM);
  end;


  procedure TFarFMPlug.GetInfo; {override;}
  begin
//  FFlags := PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    FMenuStr := FName {GetMsg(sTitle)} ;
    FConfigStr := FName;
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    FPrefix := cPrefix;
  end;


  function TFarFMPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Pointer(Result) := TFarFmPanel.Create;
  end;

  procedure TFarFMPlug.ClosePanel(AHandle :THandle); {override;}
  begin
    TFarFmPanel(AHandle).Destroy;
  end;

  procedure TFarFMPlug.GetPanelInfo(AHandle :THandle; var AInfo :TOpenPanelInfo); {override;}
  begin
    TFarFmPanel(AHandle).GetInfo(AInfo);
  end;

  function TFarFMPlug.GetPanelItems(AHandle :THandle; AMode :Integer; var AItems :PPluginPanelItemArray; var ACount :Integer) :boolean; {override;}
  begin
    Result := TFarFmPanel(AHandle).GetItems(AMode, AItems, ACount);
  end;

  procedure TFarFMPlug.FreePanelItems(AHandle :THandle; AItems :PPluginPanelItemArray; ACount :Integer); {override;}
  begin
    TFarFmPanel(AHandle).FreeItems(AItems, ACount);
  end;

  function TFarFMPlug.PanelSetDirectory(AHandle :THandle; AMode :Integer; ADir :PFarChar) :Boolean; {override;}
  begin
    Result := TFarFmPanel(AHandle).SetDirectory(AMode, ADir);
  end;

  function TFarFMPlug.PanelMakeDirectory(AHandle :THandle; AMode :Integer; var ADir :TString) :Boolean; {override;}
  begin
    Result := TFarFmPanel(AHandle).MakeDirectory(AMode, ADir);
  end;

  function TFarFMPlug.PanelGetFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer; AMove :boolean; var ADestPath :TString) :Boolean; {override;}
  begin
    Result := TFarFmPanel(AHandle).GetFiles(AMode, AItems, ACount, AMove, ADestPath);
  end;

  function TFarFMPlug.PanelDeleteFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean; {override;}
  begin
    Result := TFarFmPanel(AHandle).DeleteFiles(AMode, AItems, ACount);
  end;

  function TFarFMPlug.PanelInput(AHandle :THandle; AKey :Integer) :Boolean; {override;}
  begin
    Result := TFarFmPanel(AHandle).ProcessInput(AKey);
  end;


  function TFarFMPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  begin
    Pointer(Result) := TFarFmPanel.Create;
    try
      if (AStr <> nil) and (AStr^ <> #0) then
        TFarFmPanel(Result).Navigate(0, AStr);
    except
      FreeObj(Result);
      raise;
    end;
  end;


  procedure TFarFMPlug.Configure; {override;}
  begin
//  OptionsMenu;
  end;


  procedure TFarFMPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
    if TObject(AParam) is TAsyncCommand then
      with TAsyncCommand(AParam) do begin
        try
          Panel.RunCommand(Cmd, Param);
        finally
          Free;
        end;
      end;
  end;


  procedure TFarFMPlug.ErrorHandler(E :Exception); {override;}
  begin
    if not (E is EAbort) and not (E is ECtrlBreak) then
      ShowMessage(FName, StrReplaceChars(E.Message, [#13], #10), FMSG_WARNING or FMSG_MB_OK or FMSG_LEFTALIGN);
  end;

 {-----------------------------------------------------------------------------}

(*
  procedure TFarFMPlug.MainMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      FName,
    [
      '&1 Command1',
      '&2 Command2',
      '&3 Command3'
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: {};
        1: {};
        2: {};
      end;

    finally
      FreeObj(vMenu);
    end;
  end;
*)


end.


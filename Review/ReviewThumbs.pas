{$I Defines.inc}

unit ReviewThumbs;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

{
To Do:
  - Фильтрация

  - Глюки ориентации (из-за многопоточности?)

  - Извлечение эскизов
    - Поддержка SelfPaint (типа WMF/EMF)
    + Ограничение размера извлекаемого системного эскиза

  * Скроллер прокрутки
    + "Длинный" скроллер
    - "Зацепление" скроллера

  * Синхронизация с окном просмотора
    + Синхронизация выделения
    + Оптимизировать поиск
    - В режиме not FSyncPanel?

  - Оптимизация по масштабированию?
  - Поддержка 16 цветного режима?

  * Помощь


Готово:
  + Выбор декодера - без асинхронного события.
  + Переключение приоритетов декодера на лету

  + Оптимизация получения иконок (кэшировать расширения)
  + Заголовок окна в плагинных панелях

  + Оптимизация по Handle
    + Утилизация Handle'ов
    + Ограничение количества активных Handle

  + Обновление с сохранением смещения
    + Cохранение смещения, если текущая позиция за пределами окна
  + Масштабирование с сохранением смещения
  + При изменении размеров окна сохранять смещение (?)
  + При переключении показа заголовков сохранять смещение (как при мастабировании)

  + Поддержка полупрозрачности
    + Информация о полупрозрачности...

  + Предварительное декодирование на страницу
    + Оптимизация проходов
  + Независимые режимы максимизации
    + При демаксимизации картинки она проваливается под ThumbView
  + Переход из окна просмтора в окно эскизов

  + Поддержка DblClick

  + Отображение
    + Без моргания
    + Улучшение горизонтальной раскладки
    + Надписи:
      + Опцинальный показ надписей
      + Вычисление высоты надписи
      x Шрифт надписи
      + Свертка надписи?
        + Свертка без пробелов
    + Оптимизация заливки (без ExcludeClipRect)
    + Улучшение рисования выделения и рамок

  + Скроллинг окна
    + Плавный скроллинг

  * Просмотр эскизов
    * Комбинированное извлечение (размер - через PVD, эскиз - от системы)
      * Автоповороты системных эскизов
        + С декодером WIC
        x С декодером GFL
      * Опциональное отключение автоповоротов
        + В настройки
        + В помощь
    * Растягивать маленькие эскизы (если известен размер?)
      + В том числе - для системных эскизов (при комбинированном извлечении)
    * Use Explorer thumbnails
      x Не всегда извлекавется картинка высокого качества?
    * Use Review Decoders
      + Уменьшать размер изображения, если декодер вернул слишком большое...
        + Улучшенное сглаживание?
        + Поддержка прозрачности?
      * Поддержать для WIC/GFL опцию извлечения эскизов
      * Поддержать для WIC/GFL опцию декодирования с заданным размером
      * Опции декодера: поддерживает эскизы, потоки, Selfdarw
      + Для GDI+ - не асинхронное извлечение
      + Поддержка Precache File
    * Приоритеты извлечения

  + Выделение
    + Выделять правой кнопкой
    + Выделить все (CtrlA, Ctrl+, Ctrl-)
    + Инверсия выделения
    + Улучшить выделение мышкой
    x Оптимизировать поиск

  * Макросы
    + Установка размера эскиза

  + Настройка цветов
  + Диалог настроек
}

interface

  uses
    Windows,
    ActiveX,
    Commctrl,
    ShellAPI,
    ShlObj,
    MultiMon,
    Messages,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,
    MSWinAPI,

    Far_API,
    FarCtrl,
    FarMenu,
    FarPlug,
    FarDlg,
    FarGrid,
    FarListDlg,
    FarColorDlg,
    FarConMan,

    PVAPI,
    GDIPAPI,
    GDIImageUtil,
    ReviewConst,
    ReviewDecoders,
    ReviewGDIPlus,
    ReviewClasses;


  const
    cPanelDeltaX  = 4;
    cPanelDeltaY  = 4;
    cThumbDeltaX  = 4;
    cThumbDeltaY  = 4;
    cThumbSplitX  = 4;
    cThumbSplitY  = 4;
    cTextHeight   = 13;

    cMinThumbSize = 16;
    cDefThumbSize = 96;
    cMaxThumbSize = 1024;

    cFillWidth    = True;


  const
    cmMovePos    = 0;
    cmMoveSelect = 1;
    cmMoveByName = 2;
    cmMoveScroll = 3;

    cmSelSet     = 1;
    cmSelClr     = 2;
    cmSelInv     = 3;
    cmSelSetName = 4;
    cmSelClrName = 5;


  type
    TReviewThumb = class;
    TThumbsWindow = class;
    TThumbModalDlg = class;
    TThumbList = class;

    PSetThumbsRec = ^TSetThumbsRec;
    TSetThumbsRec = packed record
      Thumbs    :TThumbList;
      Path      :TString;
      CurFile   :TString;
      WinMode   :Integer;
      WinRect   :TRect;
      SyncPanel :Boolean;
    end;


    TReviewThumb = class(TReviewImageRec)
    public
      constructor Create(const AName :TString; ASize :Int64; ATime :Integer; AIsFolder, ASelected :Boolean); overload;
      destructor Destroy; override;

      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

      function DecodeImage(const AName :TString; ASize :Integer; ALevel :Integer) :THandle;

      procedure PrepareBitmap;

    private
      FIsFolder      :Boolean;
      FSelected      :Boolean;
      FIconIdx       :Integer;
      FIconIdx2      :Integer;  { Оверлейная иконка. Не поддерживается... }
      FIconLevel     :Integer;

      FTmpBitmap     :THandle;  { Декодированный эскиз. Временное значение для передачи между потоками. }
      FBitmapSize    :Integer;

      FRenderLevel   :Integer;  { 0-Не извлекалось, 1-Извлечен из кэша, 2-Извлечен из эскиза, 3-Извлечен из картинки }
      FRenderSize    :Integer;  { Размер, для которого извлекалось }

     {$ifdef bDebug}
      FDecodeTime1   :Integer;
      FDecodeTime2   :Integer;
     {$endif bDebug}
    end;


    TThumbList = class(TObjList)
    public
      procedure Add(AItem :TReviewThumb);
    protected
      procedure ItemFree(PItem :Pointer); override;
    private
      function GetItems(Index :Integer) :TReviewThumb;
    public
      property Items[I :Integer] :TReviewThumb read GetItems; default;
    end;


    TThumbsWindow = class(TReviewWindow)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure PaintWindow(APaintDC :HDC); override;
      function Idle :Boolean; override;

      procedure CMSetImage(var Mess :TMessage); message CM_SetImage;
      procedure CMSetVisible(var Mess :TMessage); message CM_SetVisible;
      procedure CMMove(var Mess :TMessage); message CM_Move;
      procedure CMScale(var Mess :TMessage); message CM_Scale;
      procedure CMSelect(var Mess :TMessage); message CM_Select;
      procedure CMTransform(var Mess :TMessage); message CM_Transform;
      procedure CMRenderImage(var Mess :TMessage); message CM_RenderImage;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMShowWindow(var Mess :TWMShowWindow); message WM_ShowWindow;
      procedure WMSetCursor(var Mess :TWMSetCursor); message WM_SetCursor;
      procedure WMLButtonDown(var Mess :TWMLButtonDown); message WM_LButtonDown;
      procedure WMLButtonUp(var Mess :TWMLButtonUp); message WM_LButtonUp;
      procedure WMLButtonDblClk(var Mess :TWMLButtonDblClk); message WM_LButtonDblClk;
      procedure WMRButtonDown(var Mess :TWMLButtonDown); message WM_RButtonDown;
      procedure WMRButtonUp(var Mess :TWMLButtonUp); message WM_RButtonUp;
      procedure WMMouseMove(var Mess :TWMMouseMove); message WM_MouseMove;
      procedure WMHScroll(var Mess :TWMHScroll); message WM_HScroll;
      procedure WMVScroll(var Mess :TWMVScroll); message WM_VScroll;
      procedure WMSize(var Mess :TWMSize); message WM_Size;
      procedure WMTimer(var Mess :TWMTimer); message WM_Timer;

    private
      FThumbs       :TThumbList;
      FPath         :TString;         { Текущий путь. Для плагинных панелей = '' }
      FSyncPanel    :Boolean;         { Окно синхронизируется с панелью }
      FThumbSize    :Integer;         { Желаемый размер эскиза }

      FWinSize      :TSize;
      FWinLen       :Integer;
      FWinWid       :Integer;
      FSeatCount    :Integer;
      FLineCount    :Integer;
      FSeatSplit    :Integer;
      FSeatSize     :Integer;
      FLineSize     :Integer;
      FTextHeight   :Integer;

      FCurrent      :Integer;
      FDelta        :Integer;

      FAsyncDelta   :Integer;
      FAsyncDir     :Integer;
      FScrollTimer  :TUnsPtr;
      FStartDelta   :Integer;
      FStartTime    :DWORD;
      FScrollPeriod :Integer;
      FScrollLock   :Integer;

      FDragged      :Integer;
      FClicked      :Integer;

      FSysIcons     :THandle;         { Системный ImageList иконок, используется пока не извлечен эскиз }
      FIconSize     :TSize;

      FHandCursor   :HCURSOR;

      FScrollDirect :Integer;
      FNeedRender   :Boolean;
      FThumbThread  :TThread;

      FMinAlloc     :Integer;
      FMaxAlloc     :Integer;
      FAllocLimit   :Integer;

      procedure FillStdIcons;
      function AddAsyncTasks :Boolean;
      procedure CheckHandleOverflow(AIndex :Integer);
      function GetWorkRect :TRect;
      procedure RecalcSizes;
      procedure SafeRecalcSizes;
      procedure SetSize(ASize :Integer);
      procedure SetScroller(BarType, Min, Max, OnPage, Pos :Integer; Disable :Boolean = False);
      procedure SmoothScrollTo(AOffset :Integer);
      procedure SmoothScroll(ADelta :Integer);
      procedure AsyncScroll(ADir :Integer);
      procedure ScrollTo(ADelta :Integer; ASmoothStep :Boolean = False);
      procedure GoToItem(AIndex :Integer; AScroll :Boolean; ASelect :Boolean = False; ASync :Boolean = True);
      procedure SelectRange(AIdx, AIdx2 :Integer; ACmd :Integer; ASync :Boolean = True);
      function GetItemRect(AIdx :Integer) :TRect;
      function CalcHotSpot(X, Y :Integer; ACheckRect :Boolean = True) :Integer;
      function Selected(AIdx :Integer) :Boolean;
      function FindByName(const AName :TString) :Integer;

    public
      property ThumbSize :Integer read FThumbSize;
    end;


    TThumbModalDlg = class(TModalStateDlg)
    public
      procedure UpdateTitle;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; override;
    end;

  const
    cKeepCurrent = '.';


  function CollectThumb(const AFolder :TString) :TThumbList;
  procedure ChooseDecoders(AThumbs :TThumbList);


  var ThumbsModalDlg :TThumbModalDlg;

  function ThumbModalState :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewDlgDecoders,
    ReviewDlgGeneral,
    ReviewDlgSaveAs,
    ReviewDlgSlideShow,
    MixDebug;

  const
    cmSetFile    = 1;
    cmGoFolder   = 2;
    cmGoFolder1  = 3;
    cmView       = 4;

  const
    cLimitSBar = $7FF0;


  function Sign(AVal :Integer) :Integer;
  begin
    if AVal > 0 then
      Result := 1
    else
    if Aval < 0 then
      Result := -1
    else
      Result := 0;
  end;


 {-----------------------------------------------------------------------------}
 { TCmdSelect                                                                  }
 {-----------------------------------------------------------------------------}

  type
    TCmdSelect = class(TCmdObject)
    public
      procedure Execute; override;
    end;


  procedure TCmdSelect.Execute; {override;}
    {!!!Оптимизировать... }
  var
    I, vIndex, vCount :Integer;
    vName :TString;
    vItem :PPluginPanelItem;
    vInfo :TPanelInfo;
    vSelect :Boolean;
  begin
   {$ifdef bDebug}
//  TraceBegF('%s %d', [StrIf(ACmd.FCommand = CmdSelect, 'Select', 'Deselect'), ACmd.Count]);
   {$endif bDebug}

    if FarGetPanelInfo(PANEL_ACTIVE, vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) then begin
      FARAPI.Control(PANEL_ACTIVE, FCTL_BEGINSELECTION, 0, nil);
      try
        vCount := 0;
        SortList(True, 0);
        for I := 0 to vInfo.ItemsNumber - 1 do begin
          vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, I);
          if vItem <> nil then begin
            try
              vName := vItem.FileName;
              if FindKey(Pointer(vName), 0, [foBinary], vIndex) then begin
                if FCommand = cmSelInv then
                  vSelect := not (PPIF_SELECTED and vItem.Flags <> 0)
                else
                  vSelect := FCommand = cmSelSet;
                FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, I, Pointer(TIntPtr(IntIf(vSelect, PPIF_SELECTED, 0))) );
                Inc(vCount);
                if vCount = Count then
                  Break;
              end;
            finally
              MemFree(vItem);
            end
          end;
        end;
      finally
        FARAPI.Control(PANEL_ACTIVE, FCTL_ENDSELECTION, 0, nil);
      end;
      FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
    end;

   {$ifdef bDebug}
//  TraceEnd('   Done');
   {$endif bDebug}
  end;


 {-----------------------------------------------------------------------------}
 { TCmdThumb                                                                   }
 {-----------------------------------------------------------------------------}

  type
    TCmdThumb = class(TCmdObject)
    public
      constructor Create(ACmd :Integer; const AStr :TString; ADelta :Integer); overload;
      procedure Execute; override;

    private
      FDelta :Integer;
    end;


  constructor TCmdThumb.Create(ACmd :Integer; const AStr :TString; ADelta :Integer);
  begin
    Create(ACmd, AStr);
    FDelta := ADelta;
  end;


  procedure TCmdThumb.Execute; {override;}

    procedure LocSetCurrent(const AName :TString);
    var
      vIndex :Integer;
      vInfo :TPanelInfo;
    begin
      vIndex := -1;
      if FDelta <> 0 then
        if FarGetPanelInfo(PANEL_ACTIVE, vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) then begin
          vIndex := vInfo.CurrentItem + FDelta;
          if not StrEqual(FarPanelItemName(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex), AName) then
            vIndex := -1;
        end;

      if vIndex <> -1 then
        FarPanelSetCurrentItem(True, vIndex)
      else
        FarPanelSetCurrentItem(True, AName);

      if ThumbsModalDlg <> nil then
        ThumbsModalDlg.UpdateTitle;
    end;

  begin
    case FCommand of
      cmSetFile   : LocSetCurrent(Items[0]);
      cmGoFolder  : Review.ThumbChangePath(Items[0], '', True);
      cmGoFolder1 : Review.ThumbChangePath(Items[0], '', False);
      cmView      : Review.ThumbView(Items[0]);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TThumbThread                                                                }
 {-----------------------------------------------------------------------------}

  type
    TThumbThread = class(TThread)
    public
      constructor Create(AOwner :TThumbsWindow);
      destructor Destroy; override;

      procedure Execute; override;

      procedure AddTasks(ATasks :TThumbList; const APath :TString; ALevel, ASize :Integer);
      procedure CancelTasks;

    private
      FOwner    :TThumbsWindow;
      FEvent    :THandle;
      FTaskCS   :TRTLCriticalSection;
      FTasks    :TThumbList;
      FIndex    :Integer;
      FPath     :TString;
      FLevel    :Integer;
      FSize     :Integer;

      FCache    :IThumbnailCache;

     {$ifdef bXPSupport}
      FMalloc   :IMalloc;
      FDesktop  :IShellFolder;
     {$endif bXPSupport}

      function DoTask :Boolean;
      function Render(AThumb :TReviewThumb; ALevel, ASize :Integer) :boolean;
      function GetIconIndex(const AName :TString) :Integer;
      function GetSystemThumbnail(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
      function GetSystemThumbnailVista(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
     {$ifdef bXPSupport}
      function GetSystemThumbnailXP(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
     {$endif bXPSupport}
      function GetReviewThumbnail(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
    end;


  constructor TThumbThread.Create(AOwner :TThumbsWindow);
  begin
    inherited Create(False);
    InitializeCriticalSection(FTaskCS);
    FEvent := CreateEvent(nil, True, False, nil);
    FOwner := AOwner;
  end;


  destructor TThumbThread.Destroy; {override;}
  begin
    Terminate;
    SetEvent(FEvent);
    WaitFor;

    FreeObj(FTasks);
    CloseHandle(FEvent);
    DeleteCriticalSection(FTaskCS);
    inherited Destroy;
  end;


  procedure TThumbThread.AddTasks(ATasks :TThumbList; const APath :TString; ALevel, ASize :Integer);
  begin
    EnterCriticalSection(FTaskCS);
    try
      FreeObj(FTasks);
      FTasks := ATasks;
      FPath  := APath;
      FLevel := ALevel;
      FSize  := ASize;
      FIndex := 0;
    finally
      LeaveCriticalSection(FTaskCS);
    end;
    SetEvent(FEvent);
  end;


  procedure TThumbThread.CancelTasks;
  begin
    EnterCriticalSection(FTaskCS);
    try
      FIndex := 0;
      FreeObj(FTasks);
    finally
      LeaveCriticalSection(FTaskCS);
    end;
  end;


  procedure TThumbThread.Execute;
  var
    vRes :DWORD;
   {$ifdef bDebug}
    vStart :DWORD;
   {$endif bDebug}
  begin
    CoInitialize(nil);
    try
      CoCreateInstance(CLSID_ThumbnailCache, nil, CLSCTX_INPROC_SERVER, IThumbnailCache, FCache);
     {$ifdef bXPSupport}
      if FCache = nil then begin
        SHGetMalloc(FMalloc);
        SHGetDesktopFolder(FDesktop);
      end;
     {$endif bXPSupport}

      while not Terminated do begin
        vRes := WaitForSingleObject(FEvent, 5000);
//      TraceF('WaitRes = %d', [integer(vRes)]);
        if Terminated then
          break;

        if vRes = WAIT_OBJECT_0 then begin
         {$ifdef bDebug}
          vStart := GetTickCount;
         {$endif bDebug}

          ResetEvent(FEvent);
          while not Terminated and DoTask do;

         {$ifdef bDebug}
          Trace('Task complete, %d ms', [TickCountDiff(GetTickCount, vStart)]);
         {$endif bDebug}
        end;
      end;

    finally
      FreeIntf(FCache);
      CoUninitialize;
    end;
  end;


  function TThumbThread.DoTask :Boolean;
  var
    vTask :TReviewThumb;
    vSize, vLevel :Integer;
    vLast :Boolean;
  begin
    Result := False;

    EnterCriticalSection(FTaskCS);
    try
      if (FTasks = nil) or (FIndex >= FTasks.Count) then
        Exit;

      vTask := FTasks[FIndex];
      FTasks.List[FIndex] := nil;

      vLevel := FLevel;
      vSize := FSize;

      Inc(FIndex);
      vLast := FIndex >= FTasks.Count;
      if vLast then
        FreeObj(FTasks);

     finally
      LeaveCriticalSection(FTaskCS);
    end;

    if Render(vTask, vLevel, vSize) then
      PostMessage(FOwner.Handle, CM_RenderImage, 0, LPARAM(vTask));
    if vLast then
      PostMessage(FOwner.Handle, CM_RenderImage, 0, 0);

    vTask._Release;

    Result := True;
  end;


  function TThumbThread.Render(AThumb :TReviewThumb; ALevel, ASize :Integer) :boolean;

    procedure LocUpdateBitmap(ABitmap :THandle);
    var
      vBitmap1, vOldBitmap :THandle;
      vSize :TSize;
      vMaxSize :Integer;
    begin
      vSize := GetBitmapSize(ABitmap);
      vMaxSize := IntMax(vSize.CX, vSize.CY);

      if vMaxSize > AThumb.FBitmapSize then begin

        if (vMaxSize > ASize) and ((ALevel = 3) or (vMaxSize > 256)) then begin
          { Уменьшаем извлеченный эскиз до требуемого размера, чтобы экономить память и не замедлять отображение }
          CorrectBoundEx(vSize, Size(ASize, ASize));
          vBitmap1 := ResizeBitmap(ABitmap, vSize.CX, vSize.CY, AThumb.FTransparent{?});
          if vBitmap1 <> 0 then begin
            DeleteObject(ABitmap);
            ABitmap := vBitmap1;
          end;
          vMaxSize := ASize;
        end;

        vOldBitmap := THandle(InterlockedExchangePointer(Pointer(AThumb.FTmpBitmap), nil));
        if vOldBitmap <> 0 then
          DeleteObject(vOldBitmap);

        InterlockedExchangePointer(Pointer(AThumb.FTmpBitmap), Pointer(ABitmap));
        AThumb.FBitmapSize := vMaxSize;

        if (AThumb.FWidth > 0) and (AThumb.FHeight > 0) then
          if vMaxSize >= IntMax(AThumb.FWidth, AThumb.FHeight) then
            AThumb.FRenderLevel := MaxInt; { Извлечена наилучшая картинка, дальнейшие попытки бессмыслены }

        Result := True;
      end else
        DeleteObject(ABitmap);

      AThumb.FRenderSize := ASize;
    end;

  var
    vName :TString;
    vBitmap :HBitmap;
    vIconIndex :Integer;
  begin
    Result := False;
    vBitmap := 0;
    try
//    Trace('Render: %s', [AThumb.Name]);
//    Sleep(100);

      vName := AddFileName(FPath, AThumb.Name);

      if (optExtractPriority in [1, 3]) or ((optExtractPriority = 2) and AThumb.FIsFolder) then
        vBitmap := GetSystemThumbnail(AThumb, vName, ALevel, ASize);

      if (vBitmap = 0) and (optExtractPriority in [1, 2, 4]) and not AThumb.FIsFolder and not Terminated then
        vBitmap := GetReviewThumbnail(AThumb, vName, ALevel, ASize);

      if (vBitmap = 0) and (optExtractPriority = 2) and (ALevel > 1) and not Terminated then
        vBitmap := GetSystemThumbnail(AThumb, vName, ALevel, ASize);

      if vBitmap <> 0 then begin
        LocUpdateBitmap(vBitmap);
        vBitmap := 0;
      end;

      if (ALevel > 1) and (AThumb.FIconLevel = 0) and (AThumb.FBitmapSize = 0) and not Terminated then begin
        AThumb.FIconLevel := 1;
        vIconIndex := GetIconIndex(vName);
        if (vIconIndex <> -1) and (vIconIndex <> AThumb.FIconIdx) then begin
          AThumb.FIconIdx := vIconIndex;
          Result := True;
        end;
      end;

      AThumb.FRenderLevel := IntMax(AThumb.FRenderLevel, ALevel);
      if ((ALevel >= 3) {or ((ALevel = 2) and not optThumbFirst))} and (AThumb.FBitmapSize < ASize)) or

        { На втором уровне извлекается эскиз, а если не удалось - декодируется картинка. }
        { Т.ч. если ничего не извлеклось, то далее пробовать бессмысленно... }
        ((ALevel = 2) and (AThumb.FBitmapSize = 0))

      then
        AThumb.FRenderLevel := MaxInt { Дальнейшие попытки бессмыслены }

    except
      AThumb.FRenderLevel := MaxInt; { Ошибка, дальнейшие попытки бессмыслены }
      if vBitmap <> 0 then
        DeleteObject(vBitmap);
    end;
  end;


  function TThumbThread.GetIconIndex(const AName :TString) :Integer;
  const
    SHGFI_ADDOVERLAYS  = $20;
    SHGFI_OVERLAYINDEX = $40;
  var
    vInfo :SHFILEINFO;
    vFlags :UINT;
    vList :THandle;
  begin
    Result := -1;
//  Trace('Extract icon: %s', [AName]);
//  Sleep(250);

    FillZero(vInfo, SizeOf(vInfo));
    vFlags := {SHGFI_ICON} SHGFI_SYSICONINDEX {or SHGFI_LINKOVERLAY} {or SHGFI_OVERLAYINDEX} {or SHGFI_ADDOVERLAYS {or SHGFI_SMALLICON} {or SHGFI_LARGEICON} {or SHGFI_SHELLICONSIZE};
    vList := SHGetFileInfo( PTChar(AName), 0, vInfo, SizeOf(vInfo), vFlags );

    if vList <> 0 then begin
//    if vInfo.iIcon <> 0 then begin
        Result := vInfo.iIcon and $00FFFFFF;
//      ATask.FIconIdx2 := (vInfo.iIcon and $FF000000) shr 24;
//    end;
      if vInfo.hIcon <> 0 then
        DestroyIcon(vInfo.hIcon);
    end;
  end;



  function TThumbThread.GetSystemThumbnail(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
  begin
    if (FCache <> nil) and Assigned(SHCreateItemFromParsingName) then
      Result := GetSystemThumbnailVista(AThumb, AName, ALevel, ASize)
    else
     {$ifdef bXPSupport}
      Result := GetSystemThumbnailXP(AThumb, AName, ALevel, ASize);
     {$else}
      Result := 0;
     {$endif bXPSupport}
  end;


  function TThumbThread.GetSystemThumbnailVista(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
  var
    vItem :IShellItem;
    vBitmap :ISharedBitmap;
    vFormat :DWORD;
    vHBitmap, vHBitmap1 :HBitmap;
    vFlags, vOutFlags :DWORD;
   {$ifdef bDebug}
    vStart :DWORD;
    vTime :Integer;
   {$endif bDebug}
  begin
    Result := 0;
   {$ifdef bDebug}
    Trace('System Extract Level %d: %s', [ALevel, AName]);
    vStart := GetTickCount;
   {$endif bDebug}

    if not Succeeded( SHCreateItemFromParsingName( PWideChar(AName), nil, IShellItem, @vItem) ) then
      Exit;

    vFlags := 0; vOutFlags := 0;

    case ALevel of
      1: vFlags := WTS_INCACHEONLY;
      2: vFlags := WTS_FASTEXTRACT;
      3: vFlags := WTS_EXTRACT or WTS_SLOWRECLAIM;
    end;

    if ALevel < 3 then
      ASize := IntMin(ASize, 256);

    if not Succeeded( FCache.GetThumbnail(vItem, ASize, vFlags, @vBitmap, vOutFlags, nil) ) then begin
//    if (ALevel = 2) then
//      FCache.GetThumbnail(vItem, ASize, vFlags, @vBitmap, vOutFlags, nil)
      if (ALevel = 2) and not optThumbFirst then begin
        if not Succeeded( FCache.GetThumbnail(vItem, ASize, WTS_EXTRACT, @vBitmap, vOutFlags, nil) ) then
          Exit;
      end else
        Exit;
    end;

    if Succeeded( vBitmap.GetFormat(vFormat) ) then
      AThumb.FTransparent := vFormat = WTSAT_ARGB;

    vHBitmap := 0;
    if not Succeeded( vBitmap.Detach(vHBitmap) ) then
      Exit;

    {!!!Всегда?}
    vHBitmap1 := RescaleBitmapAlpha(vHBitmap);
    if vHBitmap1 <> 0 then begin
      DeleteObject(vHBitmap);
      vHBitmap := vHBitmap1;
    end;

    Result := vHBitmap;

   {$ifdef bDebug}
    vTime := TickCountDiff(GetTickCount, vStart);
    if ALevel =  2 then
      AThumb.FDecodeTime1 := vTime
    else
      AThumb.FDecodeTime2 := vTime;
    with GetBitmapSize(Result) do
      Trace('  Ok, %d x %d, %d ms', [CX, CY, vTime]);
   {$endif bDebug}

    if optExtractSize and not AThumb.FIsFolder and ((AThumb.FWidth = 0) and (AThumb.FHeight = 0)) then
      GetReviewThumbnail(AThumb, AName, 0, 0);
  end;


 {$ifdef bXPSupport}
  function TThumbThread.GetSystemThumbnailXP(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
  var
    vPath, vName :TWideStr;
    vFolder :IShellFolder;
    vXtractImg :IExtractImage;
    vItems :PItemIDList;
    vEaten, vAttrs :Cardinal;

    vBuf: array[0..MAX_PATH] of WideChar;
    vPriority, vColorDepth, vFlags :Cardinal;
    vSize :TSize;
    vRes :HResult;

    vHBitmap :HBitmap;
//  vHBitmap1 :HBitmap;

   {$ifdef bDebug}
    vStart :DWORD;
    vTime :Integer;
   {$endif bDebug}
  begin
    Result := 0;
    if ALevel = 1 then
      Exit;

   {$ifdef bDebug}
    Trace('System Extract XP Level %d: %s', [ALevel, AName]);
    vStart := GetTickCount;
   {$endif bDebug}

    if not Assigned(FMalloc) or not Assigned(FDesktop) then
      Exit;

    vPath := RemoveBackSlash(ExtractFilePath(AName));
    if not Succeeded( FDesktop.ParseDisplayName(0, nil, PWideChar(vPath), vEaten, vItems, vAttrs) ) then
      Exit;
    FDesktop.BindToObject(vItems, nil, IShellFolder, vFolder);
    FMalloc.Free(vItems);

    vName := ExtractFileName(AName);
    if not Succeeded( vFolder.ParseDisplayName(0, nil, PWideChar(vName), vEaten, vItems, vAttrs)) then
      Exit;
    vFolder.GetUIObjectOf(0, 1, vItems, IExtractImage, nil, vXtractImg);
    FMalloc.Free(vItems);

    if vXtractImg = nil then
      Exit;

    vFlags :=
      IEIFLAG_ORIGSIZE or
//    IEIFLAG_QUALITY or
//    IEIFLAG_ASPECT or
//    IEIFLAG_SCREEN or
//    IEIFLAG_CACHE or
//    IEIFLAG_OFFLINE or
      0;

    if ALevel = 3 then
      vFlags := vFlags or IEIFLAG_QUALITY;

    vPriority := 0;
    vColorDepth := 32;
    vSize.cx := ASize;
    vSize.cy := ASize;

    vRes := vXtractImg.GetLocation(vBuf, High(vBuf), vPriority, vSize, vColorDepth, vFlags);
    if (vRes <> NOERROR) {or (vRes = E_PENDING)} then
      Exit;

    if not Succeeded( vXtractImg.Extract(vHBitmap) ) then
      Exit;

//  vHBitmap1 := RescaleBitmapAlpha(vHBitmap);
//  if vHBitmap1 <> 0 then begin
//    DeleteObject(vHBitmap);
//    vHBitmap := vHBitmap1;
//  end;

    Result := vHBitmap;

   {$ifdef bDebug}
    vTime := TickCountDiff(GetTickCount, vStart);
    if ALevel =  2 then
      AThumb.FDecodeTime1 := vTime
    else
      AThumb.FDecodeTime2 := vTime;
    with GetBitmapSize(Result) do
      Trace('  Ok, %d x %d, %d ms', [CX, CY, vTime]);
   {$endif bDebug}

    if optExtractSize and not AThumb.FIsFolder and ((AThumb.FWidth = 0) and (AThumb.FHeight = 0)) then begin
      GetReviewThumbnail(AThumb, AName, 0, 0);
//    AThumb.FWidth := 0;
//    AThumb.FHeight := 0;
    end;
  end;
 {$endif bXPSupport}


  function TThumbThread.GetReviewThumbnail(AThumb :TReviewThumb; const AName :TString; ALevel, ASize :Integer) :HBitmap;
 {$ifdef bDebug}
  var
//  vIdx :Integer;
    vStart :DWORD;
    vTime :Integer;
 {$endif bDebug}
  begin
    Result := 0;
    if ALevel = 1 then
      Exit;

   {$ifdef bDebug}
    Trace('Review Extract Level %d: %s', [ALevel, AName]);
    vStart := GetTickCount;
   {$endif bDebug}

    if (AThumb.FDecoder <> nil) and not Terminated then begin
      Result := AThumb.DecodeImage(AName, ASize, ALevel);
      if (Result = 0) and (ALevel <> 0) then
        AThumb.FDecoder := nil;

     {$ifdef bDebug}
      if Result <> 0 then begin
        vTime := TickCountDiff(GetTickCount, vStart);
        if ALevel =  2 then
          AThumb.FDecodeTime1 := vTime
        else
          AThumb.FDecodeTime2 := vTime;
        with GetBitmapSize(Result) do
          Trace('  Ok, %d x %d, %d ms', [CX, CY, vTime]);
      end;
     {$endif bDebug}
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewThumb                                                                }
 {-----------------------------------------------------------------------------}

  constructor TReviewThumb.Create(const AName :TString; ASize :Int64; ATime :Integer; AIsFolder, ASelected :Boolean);
  begin
    Create;
    FName := AName;
    FSize := ASize;
    FTime := ATime;
    FIsFolder := AIsFolder;
    FSelected := ASelected;
    FIconIdx := -1;
    FIconIdx2 := -1;
  end;


  destructor TReviewThumb.Destroy; {override;}
  begin
    if FTmpBitmap <> 0 then
      DeleteObject(FTmpBitmap);
    inherited Destroy;
  end;


  function TReviewThumb.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    Result := -LogCompare(FIsFolder, TReviewThumb(Another).FIsFolder);
    if Result = 0 then
      Result := UpCompareStr(FName, TReviewThumb(Another).Name);
  end;


  function TReviewThumb.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FName, TString(Key));
  end;


  procedure TReviewThumb.PrepareBitmap;
  var
    vHBitmap :THandle;
  begin
    FreeObj(FBitmap);

    vHBitmap := THandle(InterlockedExchangePointer(Pointer(FTmpBitmap), nil));

    if vHBitmap <> 0 then begin
      FBitmap := TReviewBitmap.Create1(vHBitmap, True);

      if optThumbAutoRotate and (FOrient0 > 1) then begin
        FOrient := FOrient0;
        OrientBitmap(FOrient);
      end;
    end;
  end;


  function TReviewThumb.DecodeImage(const AName :TString; ASize :Integer; ALevel :Integer) :THandle;
    { Метод вызывается из потока декодирования, и в нем устанавливаются свойства эскиза }
    { К некоторым эти свойствам возможно обращение в потоке окна. Не совсем хорошо, но пока так. }
  var
    vMode :TDecodeMode;
    vIsThumb :Boolean;
    vSize :TSize;
  begin
    Result := 0;

    vMode := dmImage;
    if ALevel = 2 then
      if optThumbFirst then
        vMode := dmThumbnail
      else
        vMode := dmThumbnailOrImage;

    if (FCacheBuf = nil) and FDecoder.NeedPrecache then
      if not PrecacheFile(AName) then
        Exit;
    try
      if FDecoder.pvdFileOpen(AName, Self) then begin
        try
          if FDecoder.pvdGetPageInfo(Self) then begin
            try
              if ALevel > 0 then begin
                vSize := Size(FWidth, FHeight);
                CorrectBoundEx(vSize, Size(ASize, ASize));
                if FDecoder.pvdPageDecode(Self, vSize.CX, vSize.CY, vMode) then begin
                  if FSelfdraw or FSelfPaint then begin
                    {!!! Пока не поддерживается}
                    NOP;
                  end else
                    Result := FDecoder.GetBitmapHandle(Self, vIsThumb);
                end;
              end;
            finally
              FDecoder.pvdPageFree(Self);
            end;
          end;
        finally
          FDecoder.pvdFileClose(Self);
        end;
      end;

    finally
      ReleaseCache;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TThumbList                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TThumbList.Add(AItem :TReviewThumb);
  begin
    inherited Add(AItem);
    AItem._AddRef;
  end;


  procedure TThumbList.ItemFree(PItem :Pointer); {override;}
  begin
    if TReviewThumb(PItem^) <> nil then
      TReviewThumb(PItem^)._Release;
  end;


  function TThumbList.GetItems(Index :Integer) :TReviewThumb;
  begin
    Result := inherited Items[Index];
  end;


 {-----------------------------------------------------------------------------}
 { TThumbsWindow                                                               }
 {-----------------------------------------------------------------------------}

  constructor TThumbsWindow.Create; {override;}
  begin
    inherited Create;
    FThumbs := TThumbList.Create;
    FThumbSize := optThumbSize;
    FHandCursor := LoadCursor(0, IDC_HAND);
    FThumbThread := TThumbThread.Create(Self);  
  end;


  destructor TThumbsWindow.Destroy; {override;}
  begin
    AsyncScroll(0);
    FreeObj(FThumbThread);
    FreeObj(FThumbs);
    inherited Destroy;
  end;


  procedure TThumbsWindow.WMShowWindow(var Mess :TWMShowWindow); {message WM_ShowWindow;}
  begin
    inherited;
    if Mess.Show then
      SetColor( FarAttrToCOLORREF(GetColorBG(optBkColor3)) );
  end;


  procedure TThumbsWindow.CMSetImage(var Mess :TMessage); {message CM_SetImage;}
  var
    vIndex, vOldDelta, vOldCurrent :Integer;
  begin
    with PSetThumbsRec(Mess.LParam)^ do begin
      vOldDelta := FDelta;
      vOldCurrent := FCurrent;

      SetFullscreen( optThumbFullscreen );

      FWinRect := WinRect;
      FWinBPP  := ScreenBitPerPixel;

      FLastArea := MACROAREA_SHELL;
      FNeedSync := False;

      with FThumbThread as TThumbThread do
        CancelTasks;
      AsyncScroll(0);
      FreeObj(FThumbs);
      FThumbs := Thumbs;
      FPath := Path;
      FSyncPanel := SyncPanel;
      FCurrent := -1;
      FDelta := 0;
      FAsyncDelta := 0;

      FMinAlloc := 0;
      FMaxAlloc := 0;

      FillStdIcons;
      RecalcSizes;
      if not IsWindowVisible(Handle) then
        ShowWindow
      else
      if FWinMode <> wmFullscreen then
        SetWindowBounds(CalcWinRect);

      Inc(FScrollLock);
      try
        if CurFile <> cKeepCurrent then begin
          if FThumbs.FindKey(Pointer(CurFile), 0, [], vIndex) then
            GoToItem(vIndex, {Scroll:}True, {Select:}False, {Sync:}False)
          else
            GoToItem(0, {Scroll:}True, {Select:}False, {Sync:}False);
        end else
        begin
          ScrollTo(vOldDelta);
          GoToItem(vOldCurrent, {Scroll:}True, {Select:}False, {Sync:}False);
        end;
      finally
        Dec(FScrollLock);
      end;

      Invalidate;
      FNeedRender := True;
      FScrollDirect := 0;

      FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
    end;
  end;


  procedure TThumbsWindow.CMSetVisible(var Mess :TMessage); {message CM_SetVisible;}
  begin
    if Mess.wParam = 1 then
      SafeRecalcSizes;
    inherited;
  end;


  function TThumbsWindow.FindByName(const AName :TString) :Integer;
  var
    vName :TString;
    vIndex :Integer;
  begin
    Result := -1;

    if FPath = '' then
      vName := AName
    else
      vName := ExtractFileName(AName);

    {!!!Оптимизировать... }
    if FThumbs.FindKey(Pointer(vName), 0, [], vIndex) then
      Result := vIndex;
  end;


  procedure TThumbsWindow.CMMove(var Mess :TMessage); {message CM_Move;}
  var
    vIndex :Integer;
  begin
    if (Mess.wParam = cmMovePos) or (Mess.wParam = cmMoveSelect) then
      GoToItem( Mess.LParam, True, Mess.wParam = cmMoveSelect)
    else
    if Mess.wParam = cmMoveByName then begin
      vIndex := FindByName( TString(Mess.lParam) );
      if vIndex <> -1 then
        GoToItem( vIndex, {Scroll:}True, {Select:}False, {Sync:}False)
    end else
    if Mess.wParam = cmMoveScroll then
      SmoothScroll( Mess.LParam * FLineSize )
  end;


  procedure TThumbsWindow.CMSelect(var Mess :TMessage); {message CM_Select;}
  var
    vIndex :Integer;
  begin
    if Mess.wParam in [cmSelSetName, cmSelClrName] then begin
      vIndex := FindByName( TString(Mess.lParam) );
      if vIndex <> -1 then
        SelectRange( vIndex, vIndex, IntIf(Mess.wParam = cmSelSetName, cmSelSet, cmSelClr), False )
    end else
    if Mess.LParam <> -1 then
      SelectRange( Mess.LParam, Mess.LParam, Mess.wParam)
    else
      SelectRange( 0, FThumbs.Count - 1, Mess.wParam);
  end;


  procedure TThumbsWindow.CMScale(var Mess :TMessage); {message CM_Scale;}
  begin
    if Mess.wParam = 0 then
      SetSize( Mess.LParam )
    else
      SetSize( FThumbSize + Mess.LParam );
    Mess.Result := FThumbSize;
  end;



  procedure TThumbsWindow.CMTransform(var Mess :TMessage); {message CM_Transform;}

    procedure LocInvalidate(ARealign :Boolean);
    begin
      if ARealign then begin
        SafeRecalcSizes;
        FNeedRender := True;
      end;
      Invalidate;
    end;

    procedure LocRotate(ARotate :Integer);
    begin
      if FCurrent < FThumbs.Count then begin
        with FThumbs[FCurrent] do
          Rotate(ARotate);
        Invalidate(GetItemRect(FCurrent));
      end;
    end;

  begin
    case Mess.wParam of
      cmtInvalidate : LocInvalidate(Mess.lParam = 1);
//    cmtSetPage    : {};
      cmtRotate     : LocRotate(Mess.lParam);
//    cmtOrient     : {};
    end;
  end;


  procedure TThumbsWindow.CMRenderImage(var Mess :TMessage); {message CM_RenderImage;}
  var
    vIdx :Integer;
  begin
    if Mess.LParam <> 0 then begin
      vIdx := FThumbs.IndexOf(Pointer(Mess.LParam));
      if vIdx <> -1 then begin
        FThumbs[vIdx].PrepareBitmap;
        CheckHandleOverflow(vIdx);
        Invalidate(GetItemRect(vIdx));
      end;
    end else
      { Задание завершено. Возможно, потребуется еще один проход }
      FNeedRender := True;
  end;

 {-----------------------------------------------------------------------------}

  procedure TThumbsWindow.WMSetCursor(var Mess :TWMSetCursor); {message WM_SetCursor;}
  var
    vIdx :Integer;
  begin
    inherited;
    with GetMousePos do
      vIdx := CalcHotSpot(X, Y);
    if vIdx <> -1 then
      SetCursor(FHandCursor);
  end;


  procedure TThumbsWindow.WMLButtonDown(var Mess :TWMLButtonDown); {message WM_LButtonDown;}
  begin
    SetCapture(Handle);
    with Mess.Pos do
      FClicked := CalcHotSpot(X, Y);
    if FClicked <> -1 then begin
      GoToItem(FClicked, False, GetKeyState(VK_Shift) < 0);
      FDragged := 1;
    end;
    Mess.Result := 0;
  end;


  procedure TThumbsWindow.WMLButtonUp(var Mess :TWMLButtonUp); {message WM_LButtonUp;}
  begin
    if FDragged <> 0 then begin
      ReleaseCapture;
      FDragged := 0;
      GoToItem(FCurrent, True);
    end;
    Mess.Result := 0;
  end;


  procedure TThumbsWindow.WMRButtonDown(var Mess :TWMLButtonDown); {message WM_RButtonDown;}
  begin
    SetCapture(Handle);
    with Mess.Pos do
      FClicked := CalcHotSpot(X, Y);
    if FClicked <> -1 then begin
      GoToItem(FClicked, False, False);
      if not FThumbs[FClicked].FSelected then begin
        SelectRange(FClicked, FClicked, cmSelInv);
        FDragged := 2;
      end else
        FDragged := 3;
    end;
    Mess.Result := 0;
  end;

  procedure TThumbsWindow.WMRButtonUp(var Mess :TWMLButtonUp); {message WM_RButtonUp;}
  begin
    if FDragged <> 0 then begin
      ReleaseCapture;
      if FDragged = 3 then
        if (FCurrent = FClicked) or (((FCurrent = 0) or not FThumbs[FCurrent - 1].FSelected) and ((FCurrent = FThumbs.Count - 1) or not FThumbs[FCurrent + 1].FSelected)) then 
          SelectRange(FCurrent, FCurrent, cmSelInv);
      GoToItem(FCurrent, True);
      FDragged := 0;
    end;
    Mess.Result := 0;
  end;


  procedure TThumbsWindow.WMMouseMove(var Mess :TWMMouseMove); {message WM_MouseMove;}
  var
    vIdx :Integer;
  begin
    if FDragged <> 0 then begin
      with Mess.Pos do
        vIdx := CalcHotSpot(X, Y);
      if vIdx <> -1 then
        GoToItem(vIdx, False, optMouseSelect or (FDragged > 1) or (GetKeyState(VK_Shift) < 0));
    end;
    Mess.Result := 0;
  end;


  procedure TThumbsWindow.WMLButtonDblClk(var Mess :TWMLButtonDblClk); {message WM_LButtonDblClk;}
  var
    vIdx :Integer;
  begin
    if GetKeyState(VK_Control) < 0 then begin
      if FWinMode <> wmQuickView then
//      SetFullscreen( FWinMode = wmNormal )
        FarAdvControl(ACTL_SYNCHRO, SyncCmdFullscreen);
    end else
    begin
      with Mess.Pos do
        vIdx := CalcHotSpot(X, Y);
      if vIdx <> -1 then
        with FThumbs[vIdx] do
          if FIsFolder then begin
            if FPath <> '' then
              FarAdvControl(ACTL_SYNCHRO, TCmdThumb.Create(IntIf(FSyncPanel, cmGoFolder, cmGoFolder1), AddFileName(FPath, Name)) )
            else
              Beep;
          end else
            FarAdvControl(ACTL_SYNCHRO, TCmdThumb.Create(cmView, AddFileName(FPath, Name)) )
    end;
    Mess.Result := 0;
  end;


  procedure TThumbsWindow.WMHScroll(var Mess :TWMHScroll); {message WM_HScroll;}
  begin
    WMVScroll(Mess);
  end;


  procedure TThumbsWindow.WMVScroll(var Mess :TWMVScroll); {message WM_VScroll;}
  var
    vMax, vDelta :Integer;
  begin
    vDelta := 0;
    case Mess.ScrollCode of
      SB_LINEUP{, SB_LINELEFT}:
        Dec(vDelta, FLineSize);
      SB_LINEDOWN{, SB_LINERIGHT}:
        Inc(vDelta, FLineSize);

      SB_PAGEUP:
        Dec(vDelta, FLineSize * (FWinLen div FLineSize) );
      SB_PAGEDOWN:
        Inc(vDelta, FLineSize * (FWinLen div FLineSize) );

      SB_THUMBPOSITION, SB_THUMBTRACK:
        begin
          vMax := FLineSize * FLineCount;
          if vMax <= cLimitSBar then
            vDelta := Mess.Pos
          else
            vDelta := MulDiv(Mess.Pos, vMax, cLimitSBar);
          ScrollTo(vDelta);
          Idle;
          Exit;
        end;
    end;
    if vDelta <> 0 then begin
      SmoothScroll(vDelta);
      Idle;
    end;
  end;


  procedure TThumbsWindow.WMSize(var Mess :TWMSize); {message WM_Size;}
  begin
    inherited;
    SafeRecalcSizes;
    FNeedRender := True;
//  Invalidate;
  end;


 {-----------------------------------------------------------------------------}

  function TThumbsWindow.GetWorkRect :TRect;
  begin
    Result := ClientRect;
    RectGrow(Result, -cPanelDeltaX, -cPanelDeltaY);
  end;


  procedure TThumbsWindow.SetScroller(BarType, Min, Max, OnPage, Pos :Integer; Disable :Boolean = False);
  var
    SI :TScrollInfo;
  begin
    if Max >= cLimitSBar then begin
      OnPage := MulDiv(OnPage, cLimitSBar, Max);
      Pos := MulDiv(Pos, cLimitSBar, Max);
      Max := cLimitSBar;
    end;

    SI.cbSize := SizeOf(SI);
    SI.fMask  := SIF_Page or SIF_Pos or SIF_Range;
    if Disable then
      SI.fMask  := SI.fMask or SIF_DisableNoScroll;
    SI.nMin   := Min;
    SI.nMax   := Max;
    SI.nPage  := IntMax(OnPage, 0);
    SI.nPos   := Pos;
    SetScrollInfo(Handle, BarType, SI, True);
  end;



  procedure TThumbsWindow.RecalcSizes;
  var
    vFont :HFont;
  begin
    FWinSize := RectSize(GetWorkRect);

    FWinLen := FWinSize.cy;
    FWinWid := FWinSize.cx;
    if not optVerticalScroll then
      IntSwap(FWinLen, FWinWid);

    FTextHeight := cTextHeight;
    vFont := GetStockObject(DEFAULT_GUI_FONT);
    if vFont <> 0 then
      FTextHeight := TextSize(vFont, '0').CY;

    FSeatSize := FThumbSize + cThumbDeltaX * 2 + cThumbSplitX;
    FLineSize := FThumbSize + cThumbDeltaY * 2 + cThumbSplitY;
    if optThumbShowTitle {and not optThumbFoldTitle} then begin
      if optVerticalScroll then
        Inc(FLineSize, FTextHeight)
      else
        Inc(FSeatSize, FTextHeight);
    end;

    if (FThumbs.Count > 0) and (FWinSize.cx > 0) and (FWinSize.cy > 0) then begin
      FSeatCount := IntMax(FWinWid div FSeatSize, 1);
      FLineCount := (FThumbs.Count + FSeatCount - 1) div FSeatCount;

      FSeatSplit := 0;
      if cFillWidth and (FSeatCount > 1) and (FLineCount > 1) then
        FSeatSplit := (FWinWid - FSeatSize * FSeatCount) div (FSeatCount - IntIf(FSeatCount > 3{???}, 1, 0) );

      FAllocLimit := IntMin(FSeatCount * ((FWinLen div FLineSize) + 1), optHandlesLimit);

      SetScroller(IntIf(optVerticalScroll, SB_Vert, SB_Horz), 0, FLineSize * FLineCount - cThumbSplitY, FWinLen, FDelta);
      SetScroller(IntIf(optVerticalScroll, SB_Horz, SB_Vert), 0, 1, 2, 0);
    end else
    begin
      SetScroller(SB_Vert, 0, 1, 2, 0);
      SetScroller(SB_Horz, 0, 1, 2, 0);

      FLineCount  := 0;
      FSeatCount  := 1;
      FSeatSplit  := 0;
      FDelta      := 0;
      FAsyncDelta := 0;
      FCurrent    := 0;
      FAllocLimit := 0;
    end;
  end;


  procedure TThumbsWindow.SafeRecalcSizes;
  var
    vIdx, vTopDelta :Integer;
    vRect :TRect;
  begin
    Inc(FScrollLock);
    try
      if FLineSize > 0 then begin
        vIdx := FCurrent;
        with GetItemRect(vIdx) do
          vTopDelta := IntIf(optVerticalScroll, Top, Left);

        vRect := GetWorkRect;
        if (vTopDelta < 0) or (vTopDelta > IntIf(optVerticalScroll, vRect.Bottom, vRect.Right)) then begin
          vIdx := CalcHotSpot(vRect.Left, vRect.Top, False);
          with GetItemRect(vIdx) do
            vTopDelta := IntIf(optVerticalScroll, Top, Left);
        end;

        RecalcSizes;

        with GetItemRect(vIdx) do
          ScrollTo(FDelta + IntIf(optVerticalScroll, Top, Left) - vTopDelta);
      end else
        RecalcSizes;
    finally
      Dec(FScrollLock);
    end;
  end;


  procedure TThumbsWindow.SetSize(ASize :Integer);
  begin
    ASize := RangeLimit(ASize, cMinThumbSize, cMaxThumbSize);
    if ASize <> FThumbSize then begin
      FThumbSize := ASize;
      SafeRecalcSizes;

      SetTempMsg(Format('Size: %d', [FThumbSize]));  {!Localize}
      Invalidate;
      FNeedRender := True;
      FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);

      optThumbSize := ASize;
      InterlockedIncrement(OptionsRevision);
    end;
  end;


  procedure TThumbsWindow.SmoothScrollTo(AOffset :Integer);
  begin
    if optSmoothScroll and (FScrollLock = 0) then begin
      if AOffset <> FAsyncDelta then
        SmoothScroll(AOffset - FAsyncDelta)
    end else
      ScrollTo(AOffset);
  end;


  procedure TThumbsWindow.SmoothScroll(ADelta :Integer);
  var
    vDir :Integer;
  begin
    if optSmoothScroll and (Abs(ADelta) <= FWinLen) and (FScrollLock = 0) then begin

      vDir := Sign(ADelta);
      if vDir <> FAsyncDir then
        FAsyncDelta := FDelta;
      FAsyncDelta := RangeLimit(FAsyncDelta + ADelta, 0, FLineCount * FLineSize - FWinLen);
      AsyncScroll(vDir);

      FStartDelta   := FDelta;
      FStartTime    := GetTickCount;
      FScrollPeriod := optScrollPeriod;

    end else
      ScrollTo(FDelta + ADelta);
  end;


  procedure TThumbsWindow.AsyncScroll(ADir :Integer);
  begin
    if FAsyncDir <> ADir then begin
      if FScrollTimer <> 0 then begin
        KillTimer(FHandle, FScrollTimer);
        FScrollTimer := 0;
        FAsyncDir := 0;
      end;

      if ADir <> 0 then begin
        FScrollTimer := SetTimer(FHandle, 1, 1, nil);
        FAsyncDir := ADir;
      end;
    end;
  end;


  procedure TThumbsWindow.WMTimer(var Mess :TWMTimer); {message WM_Timer;}
  var
    vPeriod, vDelta :Integer;
  begin
//  Trace('WMTimer: %d', [Mess.TimerID]);
    if Mess.TimerID = 1 then begin
      if Sign(FAsyncDelta - FDelta) = FAsyncDir then begin
        vPeriod := TickCountDiff(GetTickCount, FStartTime);
        vDelta := MulDiv( FAsyncDelta - FStartDelta, IntMin(vPeriod, FScrollPeriod), FScrollPeriod );
        ScrollTo(FStartDelta + vDelta, True);
      end;
      if Sign(FAsyncDelta - FDelta) <> FAsyncDir then
        AsyncScroll(0);
    end;
  end;


  procedure TThumbsWindow.ScrollTo(ADelta :Integer; ASmoothStep :Boolean = False);
  var
    vDY, vDX :Integer;
    vRect :TRect;
  begin
    if not ASmoothStep then
      AsyncScroll(0);

    ADelta := RangeLimit(ADelta, 0, FLineCount * FLineSize - FWinLen);
    if ADelta = FDelta then
      Exit;

    vDY := FDelta - ADelta;
    vDX := 0;

    FDelta := ADelta;
    if FAsyncDir = 0 then
      FAsyncDelta := FDelta;

    if (Abs(vDY) > FWinLen) or (FScrollLock > 0) then
      Invalidate
    else begin
      if FTempMsg <> '' then begin
        FTempMsg := '';
        InvalidateMsgRect;
      end;
      vRect := ClientRect;
      if not optVerticalScroll then
        IntSwap(vDX, vDY);
      ScrollWindowEx(Handle, vDX, vDY, @vRect, @vRect, 0, nil,
        SW_Erase or SW_Invalidate {or SW_ScrollChildren} {or Flags});
      UpdateWindow(Handle);  
    end;

    SetScroller(IntIf(optVerticalScroll, SB_Vert, SB_Horz), 0, FLineSize * FLineCount, FWinLen, FDelta);

    FScrollDirect := IntIf(vDY > 0, -1, 1);
    FNeedRender := True;
  end;


  function TThumbsWindow.Selected(AIdx :Integer) :Boolean;
  begin
    Result := FThumbs[AIdx].FSelected;
  end;


  procedure TThumbsWindow.SelectRange(AIdx, AIdx2 :Integer; ACmd :Integer; ASync :Boolean = True);
  var
    vCmd :TCmdObject;
  begin
    vCmd := nil;
    if ASync and FSyncPanel then
      vCmd := TCmdSelect.Create(ACmd, '');
    try
      while AIdx < FThumbs.Count do begin
        with FThumbs[AIdx] do begin
          if (ACmd = cmSelInv) or (FSelected <> (ACmd = cmSelSet)) then begin
            FSelected := not FSelected;
            Invalidate(GetItemRect(AIdx));
          end;
          if vCmd <> nil then
            vCmd.Add(Name);
        end;
        if AIdx = AIdx2 then
          break;
        if AIdx2 > AIdx then
          Inc(AIdx)
        else
          Dec(AIdx);
      end;
      if (vCmd <> nil) and (vCmd.Count > 0) then
        FarAdvControl(ACTL_SYNCHRO, vCmd);
    except
      FreeObj(vCmd);
      raise;
    end;
  end;


  procedure TThumbsWindow.GoToItem(AIndex :Integer; AScroll :Boolean; ASelect :Boolean = False; ASync :Boolean = True);

    procedure MakeSelection(AOldPos, ANewPos :Integer);
    var
      vLock, vStart :Integer;
    begin
      if (ANewPos <> AOldPos) and Selected(AOldPos) then begin
        vLock := 0;
        if (AOldPos = FThumbs.Count - 1) or not Selected(AOldPos + 1) then
          vLock := 1
        else
        if (AOldPos = 0) or not Selected(AOldPos - 1) then
          vLock := -1;
        if vLock = 0 then
          vLock := -IntCompare(AOldPos, ANewPos);

        if vLock <> 0 then begin
          if vLock > 0 then begin
            vStart := AOldPos;
            while (vStart > 0) and Selected(vStart - 1) do
              Dec(vStart);
          end else
          begin
            vStart := AOldPos;
            while (vStart < FThumbs.Count - 1) and Selected(vStart + 1) do
              Inc(vStart);
          end;

          if ((AOldPos >= vStart) and (ANewPos < vStart)) or ((AOldPos <= vStart) and (ANewPos > vStart)) then begin
            if AOldPos <> vStart then
              SelectRange(vStart, AOldPos, cmSelClr);
            SelectRange(vStart, ANewPos, cmSelSet);
          end else
          begin
            if AOldPos >= vStart then begin
              if ANewPos > AOldPos then
                SelectRange(AOldPos + 1, ANewPos, cmSelSet)
              else
                SelectRange(AOldPos, ANewPos + 1, cmSelClr)
            end else
            begin
              if ANewPos < AOldPos then
                SelectRange(AOldPos - 1, ANewPos, cmSelSet)
              else
                SelectRange(AOldPos, ANewPos - 1, cmSelClr)
            end;
          end;
        end else
          {???};
      end else
        SelectRange(AOldPos, ANewPos, cmSelSet);
    end;

  var
    vOldPos, vDelta :Integer;
  begin
    AIndex := RangeLimit(AIndex, 0, FThumbs.Count - 1);

    vOldPos := FCurrent;

    if AIndex <> FCurrent then begin
      Invalidate(GetItemRect(FCurrent));
      FCurrent := AIndex;
      Invalidate(GetItemRect(FCurrent));

      if ASync and FSyncPanel then
        with FThumbs[FCurrent] do
          FarAdvControl(ACTL_SYNCHRO, TCmdThumb.Create(cmSetFile, Name, FCurrent - vOldPos) );
    end;

    if ASelect and (vOldPos <> FCurrent) then
      MakeSelection(vOldPos, FCurrent);

    if AScroll then begin
      vDelta := (FCurrent div FSeatCount) * FLineSize;
      if vDelta < FDelta then
        SmoothScrollTo(vDelta)
      else
      if vDelta + FLineSize - cThumbSplitY > FDelta + FWinLen then
        SmoothScrollTo(vDelta + FLineSize - cThumbSplitY - FWinLen);
    end;
  end;


  function TThumbsWindow.GetItemRect(AIdx :Integer) :TRect;
  var
    vSeat, vLine :Integer;
  begin
    if FSeatCount > 0 then begin
      vLine := AIdx div FSeatCount;
      vSeat := AIdx mod FSeatCount;

      with GetWorkRect do
        if optVerticalScroll then
          Result := Bounds(
            Left + vSeat * (FSeatSize + FSeatSplit),
            Top + (vLine * FLineSize) - FDelta,
            FSeatSize - cThumbSplitX,
            FLineSize - cThumbSplitY
          )
        else
          Result := Bounds(
            Left +(vLine * FLineSize) - FDelta,
            Top + vSeat * (FSeatSize + FSeatSplit),
            FLineSize - cThumbSplitY,
            FSeatSize - cThumbSplitX
          );
    end else
      Result := Rect(0,0,0,0);
  end;


  function TThumbsWindow.CalcHotSpot(X, Y :Integer; ACheckRect :Boolean = True) :Integer;
  var
    vLine, vSeat, vIdx :Integer;
    vRect :TRect;
  begin
    Result := -1;

    with GetWorkRect do begin
      if optVerticalScroll then begin
        vLine := ((Y - Top) + FDelta) div FLineSize;
        vSeat := (X - Left) div (FSeatSize + FSeatSplit);
      end else
      begin
        vLine := ((X - Left) + FDelta) div FLineSize;
        vSeat := (Y - Top) div (FSeatSize + FSeatSplit);
      end;
    end;
    vIdx := (vLine * FSeatCount) + vSeat;

    if vIdx < FThumbs.Count then begin
      if ACheckRect then begin
        vRect := GetItemRect(vIdx);
//      RectGrow(vRect, -cThumbDeltaX, -cThumbDeltaY);
        if RectContainsXY(vRect, X, Y) then
          Result := vIdx;
      end else
        Result := vIdx;
    end;
  end;


  procedure TThumbsWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
//  FillRect(Mess.DC, ClientRect, FBrush);
    Mess.Result := 1;
  end;



  procedure TThumbsWindow.PaintWindow(APaintDC :HDC); {override;}
  var
    vMemDC :TMemDC;
    vClipRect :TRect;
    vItemSize :TSize;
    vTColor1, vTColor2 :COLORREF;
//  vBColor1, vBColor2 :COLORREF;


    procedure LocFill(X1, X2, Y1, Y2 :Integer);
    begin
      if (X1 < X2) and (Y1 < Y2) then
        if optVerticalScroll then
          FillRect(APaintDC, Rect(X1, Y1, X2, Y2), FBrush)
        else
          FillRect(APaintDC, Rect(Y1, X1, Y2, X2), FBrush)
    end;


    procedure LocDrawTempText(DC :HDC; const AStr :TString; {const} ARect :TRect);
    var
      vFont, vOldFont :HFont;
      vRect :TRect;
      vFlags :DWORD;
      vWidth :Integer;
    begin
      vFont := GetStockObject(DEFAULT_GUI_FONT);
      vOldFont := SelectObject(DC, vFont);
      if vOldFont = 0 then
        Exit;
      try
//      SetBkMode(DC, OPAQUE);
        SetBkMode(DC, TRANSPARENT);

        vRect := ARect;

        if optThumbFoldTitle then begin
          vFlags := DT_CENTER or DT_WORDBREAK or DT_EDITCONTROL{???} or DT_NOCLIP;

          DrawText(DC, PTChar(AStr), Length(AStr), vRect, vFlags or DT_CALCRECT);

          vRect.Top := ARect.Bottom - (vRect.Bottom - vRect.Top);
          vRect.Bottom := ARect.Bottom;

          vWidth := vRect.Right - vRect.Left;
          vRect.Left := ARect.Left;
          vRect.Right := ARect.Right;
          if vWidth < ARect.Right - ARect.Left then
            vRect := RectCenter(vRect, vWidth, vRect.Bottom - vRect.Top);

//        GDIFillRectTransp(DC, vRect, vBColor1, optPanelTransp);
//        GDIFillRectTransp(DC, vRect, vBColor2, optPanelTransp);
        end else
          vFlags := DT_CENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOCLIP;


        if vTColor1 <> vTColor2 then begin
          SetTextColor(DC, vTColor2);
          RectMove(vRect, +1, +1);
          DrawText(DC, PTChar(AStr), Length(AStr), vRect, vFlags);
          RectMove(vRect, -1, -1);
        end;  

        SetTextColor(DC, vTColor1);
        DrawText(DC, PTChar(AStr), Length(AStr), vRect, vFlags);

      finally
        SelectObject(DC, vOldFont);
      end;
    end;


    procedure LocDrawImage(DC :HDC; AIndex :Integer; AItem :TReviewThumb; const ARect :TRect);
    var
      vRect, vSrcRect :TRect;
      vScale :TFloat;
      vSize, vBmpSize, vSrcSize :TSize;
    begin
      vSize := RectSize(ARect);
//    GdiFillRect(DC, ARect, IntIf(AItem.FSelected, $0000FF, $FFFFFF));
//    LocDrawTempText(Int2Str(vItem.FIconIdx), vRect.Left, vRect.Top);

      if AItem.FBitmap <> nil then begin
        CheckHandleOverflow(AIndex);
        AItem.FBitmap.AllocHandles;

        vBmpSize := AItem.FBitmap.Size;
        vSrcSize := vBmpSize;
        if (AItem.FWidth > 0) and (AItem.FHeight > 0) then begin
          vSrcSize := Size(AItem.FWidth, AItem.FHeight);
          if AItem.FOrient in [5,6,7,8] then
            IntSwap(vSrcSize.CX, vSrcSize.CY);
        end else
        begin
          if AItem.FIsFolder then
            StretchBounds(vSrcSize, vSize);
        end;

        if (vSrcSize.CX <= vSize.CX) and (vSrcSize.CY <= vSize.CY) then begin
          vRect := RectCenter(ARect, vSrcSize.CX, vSrcSize.CY);
          vSrcRect := Bounds(0, 0, vBmpSize);
        end else
        begin
          if optZoomThumb  then begin
            vScale := FloatMax( vSize.cx / vBmpSize.CX, vSize.cy / vBmpSize.CY);

            vSrcRect := Bounds(0, 0, vBmpSize);
            vSrcRect := RectCenter(vSrcRect, Round( vSize.CX / vScale), Round( vSize.CY / vScale));

            vRect := ARect;

          end else
          begin
            CorrectBoundEx(vSrcSize, vSize);
            vRect := RectCenter(ARect, vSrcSize.CX, vSrcSize.CY);
            vSrcRect := Bounds(0, 0, vBmpSize);
          end;
        end;

        if AItem.FTransparent and not RectEqualSize(vRect, vSrcRect) then
          GPStretchDraw(DC, vRect, AItem.FBitmap.BMP, vSrcRect, {Alpha=}AItem.FTransparent, {Smooth=}True)
        else
          GDIStretchDraw(DC, vRect, AItem.FBitmap.DC, vSrcRect, {Alpha=}AItem.FTransparent, {Smooth=}True);

      end else
      begin
        if AItem.FIconIdx <> -1 then
          with RectCenter(ARect, FIconSize.CX, FIconSize.CY) do
            ImageList_Draw(FSysIcons, AItem.FIconIdx, DC, Left, Top, ILD_TRANSPARENT);
        if AItem.FIconIdx2 <> -1 then
          with RectCenter(ARect, FIconSize.CX, FIconSize.CY) do
            ImageList_Draw(FSysIcons, AItem.FIconIdx2, DC, Left, Top, ILD_TRANSPARENT);
      end;
    end;


   {$ifdef bDebug}
    procedure LocDrawDebugInfo(DC :HDC; AItem :TReviewThumb; X, Y :Integer);
    var
      vStr :TString;
    begin
      if (AItem.FWidth > 0) or (AItem.FHeight > 0) then begin
        vStr := Format('%d x %d', [AItem.FWidth, AItem.FHeight]);
        LocDrawTempText(DC, vStr, Bounds(X, Y, FThumbSize, FTextHeight));
        Inc(Y, FTextHeight);
      end;
      if AItem.FDecoder <> nil then begin
        vStr := Format('%s (%d, %d)', [AItem.FDecoder.Name, AItem.FDecodeTime1, AItem.FDecodeTime2]);
        LocDrawTempText(DC, vStr, Bounds(X, Y, FThumbSize, FTextHeight));
      end;
    end;
   {$endif bDebug}


    procedure PaintItemAt(DC :HDC; AIndex :Integer; X, Y :Integer);
    var
      vItem :TReviewThumb;
      vRect0, vRect :TRect;
      vColor, vPenColor :DWORD;
    begin
      vItem := FThumbs[AIndex];
//    Trace('  Item %d, %s', [AIndex, ExtractFileName(vItem.Name)]);
      vRect0 := Bounds(X, Y, vItemSize);

      vColor := FColor;
//    vPenColor := FarAttrToCOLORREF(GetColorBG(optCurColor));
      vPenColor := FarAttrToCOLORREF(GetColorFG(optBkColor3));
      if (AIndex = FCurrent) or vItem.FSelected then begin
        if vItem.FSelected then begin
          vColor := FarAttrToCOLORREF(GetColorBG(optSelColor));
          vPenColor := vColor;
        end;
        if AIndex = FCurrent then
          vColor := FarAttrToCOLORREF(GetColorBG(optCurColor));
      end;

      GdiFillRect2(DC, vRect0, vColor, vPenColor);

      vRect := Bounds(X + cThumbDeltaX, Y + cThumbDeltaY, FThumbSize, FThumbSize);
      LocDrawImage(DC, AIndex, vItem, vRect);

     {$ifdef bDebug}
      if optThumbShowInfo then
        LocDrawDebugInfo(DC, vItem, vRect.Left, vRect.Top);
     {$endif bDebug}

      if optThumbShowTitle then begin
        vRect.Top := vRect.Bottom;
        vRect.Bottom := vRect.Top + FTextHeight;
        LocDrawTempText(DC, ExtractFileName(vItem.Name), vRect);
      end;
    end;


    procedure PaintItem(AIndex :Integer; X, Y :Integer);
    var
      vSize :TSize;
    begin
      if vMemDC = nil then
        PaintItemAt(APaintDC, AIndex, X, Y)
      else begin
        PaintItemAt(vMemDC.DC, AIndex, 0, 0);
        GDIBitBlt(APaintDC, Bounds(X, Y, vMemDC.Size), vMemDC.DC, Bounds(0, 0, vMemDC.Size), False);
      end;

      vSize := vItemSize;
      if not optVerticalScroll then begin
        IntSwap(X, Y);
        IntSwap(vSize.CX, vSize.CY);
      end;

      LocFill(X + vSize.CX, X + FSeatSize + FSeatSplit, Y, Y + FLineSize);
      LocFill(X, X + FSeatSize + FSeatSplit, Y + vSize.CY, Y + FLineSize);
    end;


  var
    vWorkBeg, vClipBeg, vClipEnd :TPoint;
    vIdx, X, Y, vRow, vCol, vRow1, vRow2, vCol1, vCol2, vColWidth :Integer;
  begin
//  TraceBegF('%s PaintWindow...', [ClassName]);

//  vBColor1 := FarAttrToCOLORREF(GetColorBG(optPanelColor));  // On black
//  vBColor2 := FarAttrToCOLORREF(GetColorFG(optPanelColor));
    vTColor1 := FarAttrToCOLORREF(GetColorFG(optTitleColor));
    vTColor2 := FarAttrToCOLORREF(GetColorBG(optTitleColor));

    vWorkBeg := GetWorkRect.TopLeft;
    if not optVerticalScroll then
      IntSwap(vWorkBeg.X, vWorkBeg.Y);

    try
      GetClipBox(APaintDC, vClipRect);
//    FillRect(DC, vClipRect, FBrush);

      vClipBeg := vClipRect.TopLeft;
      vClipEnd := vClipRect.BottomRight;
      if not optVerticalScroll then begin
        IntSwap(vClipBeg.X, vClipBeg.Y);
        IntSwap(vClipEnd.X, vClipEnd.Y);
      end;

      vRow1 := (vClipBeg.Y - vWorkBeg.Y + FDelta) div FLineSize;
      if vRow1 < FLineCount then begin
        LocFill(vClipBeg.X, vClipEnd.X, vClipBeg.Y, vWorkBeg.Y);

        vRow2 := IntMin((vClipEnd.Y - vWorkBeg.Y + FDelta - 1) div FLineSize + 1, FLineCount);

        vItemSize := Size(FThumbSize + cThumbDeltaX * 2, FThumbSize + cThumbDeltaY * 2);
        if optThumbShowTitle {and not optThumbFoldTitle} then
          Inc(vItemSize.CY, FTextHeight);

        vMemDC := TMemDC.Create(vItemSize.CX, vItemSize.CY);
        try
          vColWidth := FSeatSize + FSeatSplit;

          vCol1 := (vClipBeg.X - vWorkBeg.X) div vColWidth;
          vCol2 := IntMin((vClipEnd.X - vWorkBeg.X - 1) div vColWidth + 1, FSeatCount);

          Y := vWorkBeg.Y + (vRow1 * FLineSize) - FDelta;
          vIdx := vRow1 * FSeatCount;
          for vRow := vRow1 to vRow2 - 1 do begin
            LocFill(vClipBeg.X, vWorkBeg.X, Y, Y + FLineSize);

            X := vWorkBeg.X + (vCol1 * vColWidth);
            for vCol := vCol1 to vCol2 - 1 do begin
              if vIdx + vCol >= FThumbs.Count then
                Break;
              if optVerticalScroll then
                PaintItem(vIdx + vCol, X, Y)
              else
                PaintItem(vIdx + vCol, Y, X);
              Inc(X, vColWidth);
            end;

            LocFill(X, vClipEnd.X, Y, Y + FLineSize);

            Inc(vIdx, FSeatCount);
            Inc(Y, FLineSize);
          end;

        finally
          FreeObj(vMemDC);
        end;

        LocFill(vClipBeg.X, vClipEnd.X, Y, vClipEnd.Y);
      end else
        FillRect(APaintDC, vClipRect, FBrush);

      if FTempMsg <> '' then
        DrawTempText(APaintDC, FTempMsg);

//    TraceEnd('  done');

    except
      on E :Exception do begin
        FillRect(APaintDC, vClipRect, FBrush);
//      DrawTempText(APaintDC, E.Message);
      end;
    end;
  end;



  function TThumbsWindow.Idle :Boolean; {override;}
  begin
    Result := inherited Idle;

    if (FClipStart <> 0) and (TickCountDiff(GetTickCount, FClipStart) > 150) then begin
//    Trace('Clipped redraw...');
//    FHiQual := not FDraftMode;
      FClipStart := 0;
      RedrawWindow(Handle, nil, 0, {RDW_ERASE??? or} RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME);
    end;

    if (FTempMsg <> '') and (TickCountDiff(GetTickCount, FMsgStart) > FMsgDelay) then begin
      { Прячем надпись... }
//    FHiQual := not FDraftMode;
      FTempMsg := '';
      InvalidateMsgRect;
    end;

    if FNeedRender then begin
      FNeedRender := False;
      AddAsyncTasks;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TThumbsWindow.FillStdIcons;
  var
    i, vFolder, vIdx :Integer;
    vFlags :UINT;
    vInfo :SHFILEINFO;
    vList :THandle;
    vItem :TReviewThumb;
    vCache :TStringList;
  begin
   {$ifdef bDebug}
    TraceBegF('FillStdIcons (%d)', [FThumbs.Count]);
   {$endif bDebug}

    vCache := TStringList.Create;
    try
      vCache.Sorted := True;

      vFolder := -1;
      for i := 0 to FThumbs.Count - 1 do begin
        vItem := FThumbs[i];
        if vItem.FIsFolder then
          vIdx := vFolder
        else begin
          vIdx := vCache.IndexOf(ExtractFileExtension(vItem.Name));
          if vIdx <> -1 then
            vIdx := TIntPtr(vCache.Objects[vIdx]);
        end;
        if vIdx <> -1 then
          vItem.FIconIdx := vIdx
        else begin
          FillZero(vInfo, SizeOf(vInfo));
          vFlags := SHGFI_SYSICONINDEX {or SHGFI_SMALLICON} {or SHGFI_LARGEICON} {or SHGFI_SHELLICONSIZE};
          if vItem.FIsFolder then
            vList := SHGetFileInfo( PTChar(AddFileName(FPath, vItem.Name)), 0, vInfo, SizeOf(vInfo), vFlags)
          else
            vList := SHGetFileInfo( PTChar(vItem.Name), 0, vInfo, SizeOf(vInfo), vFlags or SHGFI_USEFILEATTRIBUTES);
          if vList <> 0 then begin
            if FSysIcons = 0 then begin
              FSysIcons := vList;
              ImageList_GetIconSize(FSysIcons, FIconSize.CX, FIconSize.CY);
            end;
            vItem.FIconIdx := vInfo.iIcon;
            if vItem.FIsFolder then
              vFolder := vInfo.iIcon
            else
              vCache.AddObject(ExtractFileExtension(vItem.Name), Pointer(TIntPtr(vInfo.iIcon)));
          end;
        end;
      end;

    finally
      vCache.Destroy;
    end;

   {$ifdef bDebug}
    TraceEnd('   Done');
   {$endif bDebug}
  end;


  function TThumbsWindow.AddAsyncTasks :Boolean;

    function CanTryCache(AThumb :TReviewThumb) :Boolean;
    begin
      Result := (AThumb.FRenderLevel = 0) or
        ((AThumb.FRenderLevel = 1) and (AThumb.FBitmapSize > 0) and (AThumb.FRenderSize < FThumbSize));
    end;

    function LocMakeTask(AIdx1, AIdx2 :Integer) :Boolean;
    var
      i :Integer;
      vThumb :TReviewThumb;
      vTasks :TThumbList;
      vLevel :Integer;
    begin
      Result := False;
      vTasks := nil;
      try
        vLevel := MaxInt;
        for i := AIdx1 to AIdx2 - 1 do begin
          vThumb := FThumbs[i];
          if (vThumb.FRenderLevel < MaxInt) and (vThumb.FBitmapSize < FThumbSize) then begin
            if CanTryCache(vThumb) then begin
              { Быстрый проход (из кэша) }
              vLevel := 1;
              Break;
            end else
            begin
              { Следующий уровень извлечения }
              if vThumb.FRenderLevel + 1 < vLevel then
                vLevel := vThumb.FRenderLevel + 1;
            end;
          end;
        end;

        if vLevel = MaxInt then
          Exit;

        for i := AIdx1 to AIdx2 - 1 do begin
          vThumb := FThumbs[i];
          if (vThumb.FRenderLevel < MaxInt) and (vThumb.FBitmapSize < FThumbSize) then begin
            if (vThumb.FRenderLevel < vLevel) or ((vLevel = 1) and CanTryCache(vThumb)) then begin
              if vTasks = nil then
                vTasks := TThumbList.Create;
              vTasks.Add( vThumb );
            end;
          end;
        end;

        if vTasks <> nil then begin
         {$ifdef bDebug}
          Trace('AddAsyncTasks (%d), Level=%d, Size=%d', [vTasks.Count, vLevel, FThumbSize]);
         {$endif bDebug}
          with FThumbThread as TThumbThread do
            AddTasks(vTasks, Self.FPath, vLevel, FThumbSize);
          Result := True;
        end;

      except
        vTasks.Free;
        raise;
      end;
    end;

  var
    vIdx1, vIdx2, vCount :Integer;
  begin
    Result := False;
    if (FThumbs.Count = 0) or (FLineSize = 0) then
      Exit;

    with GetWorkRect do
      if optVerticalScroll then begin
        vIdx1 := ((Top + FDelta) div FLineSize) * FSeatCount;
        vIdx2 := IntMin(((Bottom + FDelta - 1) div FLineSize + 1) * FSeatCount, FThumbs.Count);
      end else
      begin
        vIdx1 := ((Left + FDelta) div FLineSize) * FSeatCount;
        vIdx2 := IntMin(((Right + FDelta - 1) div FLineSize + 1) * FSeatCount, FThumbs.Count);
      end;


    Result := LocMakeTask(vIdx1, vIdx2);

    if not Result and optRenderAhead and (FScrollDirect <> 0) then begin
      vCount := vIdx2 - vIdx1;
      vIdx1 := RangeLimit(vIdx1 + vCount * FScrollDirect, 0, FThumbs.Count);
      vIdx2 := RangeLimit(vIdx2 + vCount * FScrollDirect, 0, FThumbs.Count);

      Result := LocMakeTask(vIdx1, vIdx2);
    end;
  end;


  procedure TThumbsWindow.CheckHandleOverflow(AIndex :Integer);
  var
    vIndex :Integer;
  begin
    FMinAlloc := IntMin(FMinAlloc, AIndex);
    FMaxAlloc := IntMax(FMaxAlloc, AIndex + 1);

    while FMaxAlloc - FMinAlloc > FAllocLimit do begin
      if FMaxAlloc - AIndex <= AIndex - FMinAlloc then begin
        vIndex := FMinAlloc;
        Inc(FMinAlloc);
      end else
      begin
        Dec(FMaxAlloc);
        vIndex := FMaxAlloc;
      end;
      with FThumbs[vIndex] do
        if FBitmap <> nil then
          FBitmap.FreeHandles;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Диалог модального состояния                                                 }
 {-----------------------------------------------------------------------------}

  procedure TThumbModalDlg.Prepare; {override;}
  var
    vTitle :TString;
  begin
    FHelpTopic := 'Thumb';
    FGUID := cThumbDlgID;
    FFlags := FDLG_NODRAWSHADOW or FDLG_NODRAWPANEL;
    FWidth := 20;
    FHeight := 5;
    vTitle := Review.GetWindowTitle; {???}
    FDialog := CreateDialog(
      [ NewItemApi(DI_DoubleBox, 0,  0, FWidth, FHeight, 0, PTChar(vTitle)) ],
      @FItemCount
    );
  end;


  procedure TThumbModalDlg.InitDialog; {override;}
  begin
    ResizeDialog;
    UpdateTitle;
  end;


  procedure TThumbModalDlg.UpdateTitle;
  const
    vDelim = $2022;
  var
    vWin :TThumbsWindow;
    vStr :TString;
  begin
    vWin := Review.ThumbWindow as TThumbsWindow;
    vStr := vWin.FPath;
    if vStr = '' then
      vStr := FarPanelString(PANEL_ACTIVE, FCTL_GETPANELFORMAT);
    vStr :=
      vStr + ' ' + TChar(vDelim) + ' ' +
//    Int2Str(vWin.FThumbSize) + ' ' + TChar(vDelim) + ' ' +
      Int2Str(vWin.FCurrent + 1) + ' / ' + Int2Str(vWin.FThumbs.Count);
    SetTitle(vStr);
  end;


  function TThumbModalDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  var
    vWin :TThumbsWindow;

    procedure LocSend(AMsg :UINT; AParam1 :TIntPtr = 0; AParam2 :TIntPtr = 0);
    begin
      SendMessage(vWin.Handle, AMsg, AParam1, AParam2);
    end;


    procedure LocGoto(AIdx :Integer);
    begin
      LocSend(CM_Move, IntIf(AKey and Key_Shift <> 0, cmMoveSelect, cmMovePos), AIdx);
    end;

    procedure LocGotoPage(ADY :Integer);
    begin
      LocGoto(
        vWin.FCurrent + (vWin.FSeatCount * (vWin.FWinLen div vWin.FLineSize)) * ADY);
    end;

    procedure LocMove(ADX, ADY :Integer);
    var
      vIdx :Integer;
    begin
      if not optVerticalScroll then
        IntSwap(ADX, ADY);
      vIdx := vWin.FCurrent;
      vIdx := vIdx + ADX + ADY * vWin.FSeatCount;
      LocGoto(vIdx);
    end;

    procedure LocSetScale(AMode, AValue :Integer);
    begin
      LocSend(CM_Scale, AMode, AValue);
    end;

    procedure LocRotate(ARotate :Integer);
    begin
      LocSend(CM_Transform, cmtRotate, ARotate);
    end;


    procedure LocSwitchOption(var AOption :Boolean; ARealign :Boolean = True);
    begin
      AOption := not AOption;
      InterlockedIncrement(OptionsRevision);
      LocSend(CM_Transform, cmtInvalidate, IntIf(ARealign, 1, 0));
    end;


    procedure LocReRead;
    var
      vPath :TString;
    begin
      vPath := '';
      if not vWin.FSyncPanel then
        vPath := vWin.FPath;
      Review.ShowThumbs(vPath, cKeepCurrent);
    end;


    procedure LocRedecode(AMode :TRedecodeMode);
    begin
      if vWin.FThumbs.Count > 0 then begin
        with vWin.FThumbs[vWin.FCurrent] do
          if not FIsFolder and Review.ThumbRedecode(AMode, FDecoder, FName) then begin
            LocReRead;
            if Review.FavDecoder <> nil then
              Review.SetTempMsg(Format('Decoder: %s', [Review.FavDecoder.Title]));  {!Localize}
          end else
            Beep;
      end else
        Beep;  
    end;

  var
    vPath :TString;
  begin
    Result := True;

    vWin := Review.ThumbWindow as TThumbsWindow;

    if (AKey >= byte('A')) and (AKey <= byte('Z')) then
      AKey := AKey + 32;

    case AKey of
      KEY_F1 : begin
        Review.ThumbSyncDelayed(SyncCmdUpdateWin, 100);
        Result := inherited KeyDown(AID, AKey);
      end;

      KEY_F9 : begin
        Review.ThumbSyncDelayed(SyncCmdUpdateWin, 100);
        Review.PluginSetup;
      end;

      KEY_F10:
        Close;
      KEY_F4..KEY_F8,KEY_F11,
      KEY_SHIFTF3..KEY_SHIFTF8,
      KEY_ALTF3,KEY_ALTF4:
      begin
        FPostKey := AKey;
        Close;
      end;

      KEY_Enter, Key_F3:
        with vWin.FThumbs[vWin.FCurrent] do
          if FIsFolder then begin
            if AKey = KEY_Enter then
              Review.ThumbChangePath( AddFileName(vWin.FPath, Name), '', vWin.FSyncPanel )
            else
              Beep;
          end else
            Review.ThumbView( AddFileName(vWin.FPath, Name) );
(*
          begin
            if vWin.WinMode = wmFullscreen then
              optFullscreen := True;
            if Review.ShowImage( AddFileName(vWin.FPath, Name), 0) then
              ViewModalState(False, False);
          end;
*)

      KEY_BS:
        begin
          vPath := ExtractFilePath(vWin.FPath);
          if not StrEqual(vPath, vWin.FPath) then
            Review.ThumbChangePath( vPath, ExtractFileName(vWin.FPath), vWin.FSyncPanel )
          else
            Beep;
        end;

      { Смещение }
      Key_Left, Key_ShiftLeft, Key_NumPad4, Key_ShiftNumPad4:
        LocMove(-1,  0);
      Key_Right, Key_ShiftRight, Key_NumPad6, Key_ShiftNumPad6:
        LocMove(+1,  0);
      Key_Up, Key_ShiftUp, Key_NumPad8, Key_ShiftNumPad8:
        LocMove( 0, -1);
      Key_Down, Key_ShiftDown, Key_NumPad2, Key_ShiftNumPad2:
        LocMove( 0, +1);

      Key_Home, Key_ShiftHome, Key_NumPad7:
        LocGoto(0);
      Key_End, Key_ShiftEnd, Key_NumPad1:
        LocGoto(MaxInt);
      Key_PgDn, Key_ShiftPgDn, Key_NumPad3:
        LocGotoPage(+1);
      Key_PgUp, Key_ShiftPgUp, Key_NumPad9:
        LocGotoPage(-1);

      { Переключение декодеров }
      Key_AltHome  : LocRedecode(rmBest);
      Key_AltPgDn  : LocRedecode(rmNext);
      Key_AltPgUp  : LocRedecode(rmPrev);

      KEY_Ins:
        begin
          LocSend(CM_Select, cmSelInv, vWin.FCurrent);
          if optVerticalScroll then
            LocMove(+1,  0)
          else
            LocMove( 0, +1);
        end;
      KEY_Del:
        {};
      KEY_Multiply         : LocSend(CM_Select, cmSelInv, -1);
      KEY_CtrlAdd          : LocSend(CM_Select, cmSelSet, -1);
      KEY_CtrlSubtract     : LocSend(CM_Select, cmSelClr, -1);
      KEY_CtrlA, Byte('a') : LocSend(CM_Select, cmSelSet, -1);

      KEY_DIVIDE           : LocSetScale(0, cDefThumbSize);
      KEY_Add              : LocSetScale(1, +16 );
      KEY_Subtract         : LocSetScale(1, -16 );
      KEY_ShiftAdd         : LocSetScale(1, +1 );
      KEY_ShiftSubtract    : LocSetScale(1, -1 );

      Byte('.')            : LocRotate(1); { > - Поворот по часовой }
      Byte(',')            : LocRotate(2); { < - Поворот против часовой }
      Key_Alt + Byte('.')  : LocRotate(3); { Alt> - X-Flip }
      Key_Alt + Byte(',')  : LocRotate(4); { Alt< - Y-Flip }

      KEY_CtrlF, Byte('f') :
//      Review.SetFullscreen(vWin.FWinMode = wmNormal);
        Review.SetFullscreen(-1);

      KEY_CtrlR, Byte('r') : LocReRead;
      KEY_CtrlT, Byte('t') : LocSwitchOption(optThumbShowTitle, True);
      KEY_AltT             : LocSwitchOption(optThumbFoldTitle, True);
      KEY_CtrlZ, Byte('z') : LocSwitchOption(optZoomThumb, False);
      KEY_CtrlJ, Byte('j') : LocSwitchOption(optVerticalScroll, True);
      KEY_CtrlI, Byte('i') : LocSwitchOption(optThumbShowInfo, False);

      KEY_CtrlO, Byte('o') :
        begin
          optThumbAutoRotate := not optThumbAutoRotate;
          InterlockedIncrement(OptionsRevision);
          LocReRead;
        end;

      KEY_CTRL0..KEY_CTRL4:
        begin
          optExtractPriority := AKey - KEY_CTRL0;
          InterlockedIncrement(OptionsRevision);
          LocReRead;
        end;
(*
      KEY_CTRL5:
        begin
          optThumbFirst := not optThumbFirst;
          LocReRead;
        end;
      KEY_CTRL6:
        begin
          optRenderAhead := not optRenderAhead;
          LocReRead;
        end;
*)
      KEY_CTRL7:
        begin
          optExtractSize := not optExtractSize;
          LocReRead;
        end;
      KEY_CTRL8:
        begin
          optCorrectThumb := not optCorrectThumb;
          LocReRead;
        end;

     {$ifdef bDebug}
      KEY_AltX : Sorry;
     {$endif bDebug}

    else
      Result := inherited KeyDown(AID, AKey);
    end;
//  UpdateTitle;
  end;


  function TThumbModalDlg.MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; {override;}
  var
    vWin :TThumbsWindow;
  begin
//  if AMouse.dwEventFlags and MOUSE_HWHEELED <> 0 then
//    {}
//  else
    if AMouse.dwEventFlags and MOUSE_WHEELED <> 0 then begin
      vWin := Review.ThumbWindow as TThumbsWindow;
      SendMessage(vWin.Handle, CM_Move, cmMoveScroll, IntIf(Smallint(LongRec(AMouse.dwButtonState).Hi) > 0, -1, 1) );
    end;
    Result := inherited MouseEvent(AID, AMouse);
  end;


  function ThumbModalState :Boolean;
  var
    vRevision :Integer;
  begin
    Assert(ThumbsModalDlg = nil);
    ThumbsModalDlg := TThumbModalDlg.Create;
    try
      vRevision := OptionsRevision;

      Result := ThumbsModalDlg.Run = -1;

      if vRevision <> OptionsRevision then
        PluginConfig(True);

      if ThumbsModalDlg.FErrorStr <> '' then begin
        Review.CloseThumbWindow;
        ShowMessage(cPluginName, ThumbsModalDlg.FErrorStr, FMSG_WARNING or FMSG_MB_OK);
      end else
      begin
        Review.CloseThumbWindow;
        if ThumbsModalDlg.FPostKey <> 0 then
          FarPostMacro('Keys("' + FarKeyToName(ThumbsModalDlg.FPostKey) + '")');
      end;

    finally
      FreeObj(ThumbsModalDlg);
    end;
  end;



 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CollectThumb(const AFolder :TString) :TThumbList;

    procedure FillFromPanel(AList :TThumbList);
    var
      i :Integer;
      vInfo :TPanelInfo;
      vItem :PPluginPanelItem;
      vName :TString;
    begin
      if FarGetPanelInfo(PANEL_ACTIVE, vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) and
        { Не работает на плагинных панелях с "ненастоящими" файлами }
        (PFLAGS_REALNAMES and vInfo.Flags <> 0) then
      begin
        for i := 0 to vInfo.ItemsNumber - 1 do begin
          vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, i);
          if vItem <> nil then begin
            try
              vName := vItem.FileName;
              if vName = '..' then
                Continue;
              AList.Add( TReviewThumb.Create(
                vName,
                vItem.FileSize,
                FileTimeToDosFileDate(vItem.LastWriteTime),
                vItem.FileAttributes and faDirectory <> 0,
                PPIF_SELECTED and vItem.Flags <> 0) );
            finally
              MemFree(vItem);
            end;
          end;
        end;
      end else
        FreeObj(Result);
    end;

    procedure FillFromFolder(AList :TThumbList);

      function LocEnumFiles(const APath :TString; const ARec :TWin32FindData) :Boolean;
      begin
        AList.Add( TReviewThumb.Create(
          ARec.cFileName,
          MakeInt64(ARec.nFileSizeLow, ARec.nFileSizeHigh),
          FileTimeToDosFileDate(ARec.ftLastWriteTime),
          ARec.dwFileAttributes and faDirectory <> 0,
          False));
        Result := True;
      end;

    begin
      WinEnumFiles(AFolder, '*.*', faEnumFilesAndFolders, LocalAddr(@LocEnumFiles));
      AList.SortList(True, 1);
    end;

  begin
    Result := TThumbList.Create;
    try
      if AFolder = '' then
        FillFromPanel(Result)
      else
        FillFromFolder(Result);
    except
      FreeObj(Result);
      raise;
    end;
  end;


  procedure ChooseDecoders(AThumbs :TThumbList);

    function ChooseDecoder(const AName :TString) :TReviewDecoder;
    var
      I :Integer;
      vDecoder :TReviewDecoder;
    begin
      Result := nil;
      if Review.FavDecoder <> nil then
        if Review.FavDecoder.CanShowThumbFor(AName) then begin
          Result := Review.FavDecoder;
          Exit;
        end;

      for I := 0 to Review.Decoders.Count - 1 do begin
        vDecoder := Review.Decoders[I];
        if (vDecoder <> Review.FavDecoder) and vDecoder.CanShowThumbFor(AName) then begin
          Result := vDecoder;
          Exit;
        end;
      end;
    end;

  var
    i, j :Integer;
    vExt :TString;
    vThumb :TReviewThumb;
    vDecoder :TReviewDecoder;
    vDecoders :TStringList;
  begin
   {$ifdef bDebug}
    TraceBegF('ChooseDecoders (%d)', [AThumbs.Count]);
   {$endif bDebug}

    vDecoders := TStringList.Create;
    try
      for i := 0 to AThumbs.Count - 1 do begin
        vThumb := AThumbs[I];
        if vThumb.FIsFolder then
          Continue;

        vExt := ExtractFileExtension(vThumb.Name);
        if vDecoders.FindKey(Pointer(vExt), 0, [foBinary], j) then
          vDecoder := vDecoders.Objects[j] as TReviewDecoder
        else begin
          vDecoder := ChooseDecoder(vThumb.Name);
          vDecoders.InsertObject(j, vExt, vDecoder)
        end;

        vThumb.FDecoder := vDecoder;
      end;

     {$ifdef bDebug}
      TraceEnd(Format('  Done, %d Exts', [vDecoders.Count]));
     {$endif bDebug}

    finally
      FreeObj(vDecoders);
    end;
  end;


end.


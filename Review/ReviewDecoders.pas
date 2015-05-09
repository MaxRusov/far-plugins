{$I Defines.inc}

{$Define bUseMapping}

unit ReviewDecoders;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarConfig,
    PVAPI,

    ReviewConst,
    GDIImageUtil;


  const
    cPreCacheLimit = 128 * 1024 * 1024;  //???

  type
    TReviewDecoder = class;

    TReviewImageRec = class(TComBasis)
    public
      FName        :TString;           { Имя файла (не обязательно с путем) }

      FSize        :Int64;             { Размер файла }
      FTime        :Integer;           { Время файла }
      FCacheBuf    :Pointer;           { Считанный файл (первые cPreCacheLimit байт), ...  }
      FCacheSize   :Integer;           { ... если декодер требует буффер. Используется Memory Mapping. }

      FContext     :Pointer;           { Контекст для декодирования }
      FFormat      :TString;           { Имя формата }
      FCompress    :TString;           { Алгоритм сжатия }
      FDescr       :TString;           { Описание }
      FPages       :Integer;           { Количество страниц }
      FPage        :Integer;           { Текущая страница }
      FWidth       :Integer;           { Ширина изображения }
      FHeight      :Integer;           { Высота изображения }
      FBPP         :Integer;           { Цветность }
      FTransparent :Boolean;           { Полупрозрачное изображение }
      FAnimated    :Boolean;           { Анимированное изображение }
      FMovie       :Boolean;           { Видео-файл }
      FLength      :Integer;           { Длительность видео в MS }
      FDelay       :Integer;           { Задержка текущей страницы при анимации }
      FOrient0     :Integer;           { Начальная ориентация (по EXIF) }
      FOrient      :Integer;           { Текущая ориентация (дополнительный поворот после декодирования) }

      FSelfdraw    :Boolean;
      FSelfPaint   :Boolean;

      FDecodeInfo  :Pointer;           { Временные данные декодирования }
      FDisplayCtx  :Pointer;           { Контекст для отображения (только для Selfdraw) }

      FMapFile     :THandle;
      FMapHandle   :THandle;

      FDecoder     :TReviewDecoder;    { Выбранный декодер }
      FBitmap      :TReviewBitmap;     { Bitmap (только для не Selfdraw) }

      destructor Destroy; override;

      procedure Rotate(ARotate :Integer);
      procedure OrientBitmap(AOrient :Integer);
      function CorrectThumbnail(ABitmap :HBitmap) :HBitmap;

      function PrecacheFile(const AFileName :TString) :Boolean;
      procedure ReleaseCache;

      property Name :TString read FName write FName;
    end;


    TDecoderState = (
      rdsInternal,
      rdsCached,
      rdsLoaded,
      rdsError
    );

    TDecodeMode = (
      dmImage,                  { Основное изображение }
      dmThumbnail,              { Эскиз. Если эскиза нет - возвращаем ошибку }
      dmThumbnailOrImage        { Эскиз, а если его нет - основное изображение }
    );

    TSaveOptions = set of (
      soExifRotation,
      soTransformation,
      soEnableLossy,
      soKeepDate
    );

    TReviewDecoderClass = class of TReviewDecoder;
    TReviewDllDecoderClass = class of TReviewDllDecoder;

    TDecodeCallback = procedure(ASender :Pointer; APercent :Integer; var AContinue :Boolean) of object;

    TReviewDecoder = class(TNamedObject)
    public
      constructor Create; override;
      constructor CreateCache(const aName, aTitle :TString; aModified :Integer;
        aEnabled :Boolean; aPriority :Integer; const aActive, aIgnore :TString; ACustomMask :Boolean);
      destructor Destroy; override;

      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

      function GetState :TDecoderState; virtual; abstract;
      function CanWork(aLoad :Boolean) :boolean; virtual; abstract;
      function CanShowThumbs :boolean; virtual;
      function NeedPrecache :boolean; virtual;
      procedure ResetSettings; virtual;
      procedure SetExtensions(const aActive, aIgnore :TString);
      function SupportedFile(const aName :TString) :Boolean;
      function CanShowThumbFor(const AName :TString) :Boolean;
      function GetMaskAsStr :TString;

      { Функции декодирования }
      function pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; virtual; abstract;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; virtual; abstract;
      function pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
        const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; virtual; abstract;
      procedure pvdPageFree(AImage :TReviewImageRec); virtual; abstract;
      procedure pvdFileClose(AImage :TReviewImageRec); virtual; abstract;

      { Функции отображения (для Selfdraw) }
      function pvdDisplayInit(AWnd :THandle) :Boolean; virtual;
      procedure pvdDisplayDone(AWnd :THandle); virtual;
      function pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean; virtual;
      function pvdDisplayPaint(AWnd :THandle; ADC :HDC; AImage :TReviewImageRec; const AImageRect, ADisplayRect, AFullDisplayRect :TRect; AColor :DWORD) :Boolean; virtual;
      procedure pvdDisplayClose(AImage :TReviewImageRec); virtual;

//    function pvdPlayControl(AImage :TReviewImageRec; aCmd :Integer; aInfo :TIntPtr) :Integer; {virtual;}
      function pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; virtual;

      { Расширенные функции, пока не вынесенные в pvd интерфейс }
      function GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; virtual;
      function Save(AImage :TReviewImageRec; const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean; virtual;
      function Idle(AImage :TReviewImageRec; AWidth, AHeight :Integer) :Boolean; virtual;

    protected
      FKind       :Integer;
      FTitle      :TString;
      FVersion    :TString;
      FComment    :TString;
      FPriority   :Integer;

      FInitState  :Integer;  { 0-не инициализирован, 1-инициализирован, 2-ошибка при инициализации }
      FModified   :Integer;  { Дата модификации PVD файла - для проверки актуальности кэша }
      FEnabled    :Boolean;
      FWasInCache :Boolean;  { Вспом. при инициализации }

      FActiveStr  :TString;
      FIgnoreStr  :TString;
      FCustomMask :Boolean;  { Список расширений был изменен пользователем }

      FActiveMask :TString;
      FIgnoreMask :TString;

      FLastError  :TString;

    public
      property Kind :Integer read FKind;
      property Title :TString read FTitle;
      property Version :TString read FVersion;
      property Comment :TString read FComment;
      property Priority :Integer read FPriority;
      property Modified :Integer read FModified;
      property Enabled :Boolean read FEnabled write FEnabled;
      property ActiveStr :TString read FActiveStr;
      property IgnoreStr :TString read FIgnoreStr;
      property CustomMask :Boolean read FCustomMask write FCustomMask;
      property LastError :TString read FLastError;
    end;


    TReviewDllDecoder = class(TReviewDecoder)
    public
      constructor CreateEx(const aName :TString; aModified :Integer);
      destructor Destroy; override;

      function GetState :TDecoderState; override;
      function CanWork(aLoad :Boolean) :boolean; override;

    protected
      procedure InitPlugin(aKeepSettings :Boolean); virtual; abstract;
      procedure DonePlugin; virtual; abstract;

    private
      FHandle         :THandle;
      FDllName        :TString;

      { Параметры, возвращаемые плагином }
      FInitError      :Integer;
      FInitContext    :Pointer;
    end;


    TReviewDllDecoder1 = class(TReviewDllDecoder)
    public
      constructor Create; override;

      { Функции инициализации }
      procedure pvdInit;
      procedure pvdExit;
      procedure pvdGetInfo;

      { Функции декодирования }
      function pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; override;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; override;
      function pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
        const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; override;
      procedure pvdPageFree(AImage :TReviewImageRec); override;
      procedure pvdFileClose(AImage :TReviewImageRec); override;

      function GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; override;

    protected
      procedure InitPlugin(aKeepSettings :Boolean); override;
      procedure DonePlugin; override;

    private
      { PictureView1 interface }
      FpvdInit           :TpvdInit;
      FpvdExit           :TpvdExit;
      FpvdPluginInfo     :TpvdPluginInfo;

      FpvdFileOpen       :TpvdFileOpen;
      FpvdPageInfo       :TpvdPageInfo;
      FpvdPageDecode     :TpvdPageDecode;
      FpvdPageFree       :TpvdPageFree;
      FpvdFileClose      :TpvdFileClose;
    end;


    TReviewDllDecoder2 = class(TReviewDllDecoder)
    public
      constructor Create; override;
      function CanShowThumbs :boolean; override;
      function NeedPrecache :boolean; override;
      procedure ResetSettings; override;

      { Функции инициализации }
      procedure pvdInit;
      procedure pvdExit;
      procedure pvdGetInfo;
      procedure pvdGetFormats;
      function pvdTranslateError(aCode :DWORD) :TString;

      { Функции декодирования }
      function pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; override;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; override;
      function pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
        const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; override;
      procedure pvdPageFree(AImage :TReviewImageRec); override;
      procedure pvdFileClose(AImage :TReviewImageRec); override;

      { Функции отображения (для Selfdraw) }
      function pvdDisplayInit(AWnd :THandle) :Boolean; override;
      procedure pvdDisplayDone(AWnd :THandle); override;
      function pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean; override;
      function pvdDisplayPaint(AWnd :THandle; ADC :HDC; AImage :TReviewImageRec; const AImageRect, ADisplayRect, AFullDisplayRect :TRect; AColor :DWORD) :Boolean; override;
      procedure pvdDisplayClose(AImage :TReviewImageRec); override;

      function pvdPlayControl(AImage :TReviewImageRec; aCmd :Integer; aInfo :TIntPtr) :Integer; {override;}
      function pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; override;

      function GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; override;

    protected
      procedure InitPlugin(aKeepSettings :Boolean); override;
      procedure DonePlugin; override;

    private
      FRegKey            :TString;
      FPlugFlags         :UINT;         { Возможные флаги PVD_IP_xxx }

      { PictureView2 interface }
      FpvdInit           :TpvdInit2;
      FpvdExit           :TpvdExit2;
      FpvdPluginInfo     :TpvdPluginInfo2;
      FpvdReloadConfig   :TpvdReloadConfig2;
      FpvdTranslateError :TpvdTranslateError2;

      FpvdGetFormats     :TpvdGetFormats2;
      FpvdFileOpen       :TpvdFileOpen2;
      FpvdPageInfo       :TpvdPageInfo2;
      FpvdPageDecode     :TpvdPageDecode2;
      FpvdPageFree       :TpvdPageFree2;
      FpvdFileClose      :TpvdFileClose2;

      FpvdDisplayInit    :TpvdDisplayInit2;
      FpvdDisplayAttach  :TpvdDisplayAttach2;
      FpvdDisplayCreate  :TpvdDisplayCreate2;
      FpvdDisplayPaint   :TpvdDisplayPaint2;
      FpvdDisplayClose   :TpvdDisplayClose2;
      FpvdDisplayExit    :TpvdDisplayExit2;

      FpvdPlayControl    :TpvdPlayControl;
      FpvdTagInfo        :TpvdTagInfo;
    end;


  var
    NeedStoreCache :Boolean;

  function GetPVDVersion(const AName :TString; var AHandle :THandle) :Integer;

  procedure SaveDecodersInfo(aDecoders :TObjList);
  function RestoreDecodersCache(aDecoders :TObjList) :Boolean;
  procedure InitDecodersFrom(aDecoders :TObjList; const aPath :TString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewGDIPlus,
    ReviewGDI,
   {$ifdef bUseLibJPEG}
    ReviewJPEG,
   {$endif bUseLibJPEG}
    MixDebug;


  const
    strPluginInitError    = 'Plugin init error (%x)';
    strUnsupportedPlugin  = 'Unsupported plugin version (%d)';
    strUnsupportedFeature = 'Feature not supported';


//BOOL WINAPI SetDllDirectory(_In_opt_  LPCTSTR lpPathName);

  function SetDllDirectory(aPath :PTChar) :BOOL; stdcall;
    external kernel32 name 'SetDllDirectory'+_X;


 {-----------------------------------------------------------------------------}
 { TReviewImageRec                                                             }
 {-----------------------------------------------------------------------------}

  destructor TReviewImageRec.Destroy; {override;}
  begin
    ReleaseCache;
    FreeObj(FBitmap);
    inherited Destroy;
  end;


  procedure TReviewImageRec.Rotate(ARotate :Integer);
  const
    cReorient :array[0..8, 0..4] of Integer = (
     (1,6,8,2,4), //
     (1,6,8,2,4), //
     (2,7,5,1,3), // X
     (3,8,6,4,2), // LL = RR
     (4,5,7,3,1), // Y
     (5,2,4,6,8), // XR
     (6,3,1,5,7), // R
     (7,4,2,8,6), // XL
     (8,1,3,7,5)  // L
    );
    cTransform :array[0..4] of Integer =
      (0, 6, 8, 2, 4);
  begin
    if FBitmap <> nil then begin
      FOrient := cReorient[FOrient, ARotate];
      OrientBitmap(cTransform[ARotate]);
    end;
  end;


  procedure TReviewImageRec.OrientBitmap(AOrient :Integer);
  begin
    if FBitmap <> nil then
      FBitmap.Transform(AOrient);
  end;


  function TReviewImageRec.CorrectThumbnail(ABitmap :HBitmap) :HBitmap;
  var
    vSize, vSize1 :TSize;
    vRatio1, vRatio2 :TFloat;
  begin
    Result := ABitmap;

    vSize := GetBitmapSize(ABitmap);
    if (FWidth = 0) or (FHeight = 0) or (vSize.CX = 0) then
      Exit;

    vRatio1 := FHeight / FWidth;
    vRatio2 := vSize.CY / vSize.CX;

    vSize1 := vSize;
    if vRatio2 > vRatio1 then
      vSize1.CY := Round( vSize1.CX * vRatio1)
    else
      vSize1.CX := Round( vSize1.CY / vRatio1);

    if (vSize1.CX <> vSize.CX) or (vSize1.CY <> vSize.CY) then begin
      Result := StretchBitmap(ABitmap, vSize1.CX, vSize1.CY-1);
      DeleteObject(ABitmap);
    end;
  end;


 {$ifdef bUseMapping}
  function TReviewImageRec.PrecacheFile(const AFileName :TString) :Boolean;
  begin
//  Trace('Create FileMapping: %s', [AFileName] );

    Result := False;
    FMapFile := CreateFile(PTChar(AFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
    if FMapFile = INVALID_HANDLE_VALUE then
      Exit;

    FSize := FileSize(FMapFile);
    if FSize <= 0 then
      begin ReleaseCache; Exit; end;

    FCacheSize := cPreCacheLimit;
    if FSize < FCacheSize then
      FCacheSize := FSize;

    FMapHandle := CreateFileMapping(FMapFile, nil, PAGE_READONLY, 0, FCacheSize, nil);
    if FMapHandle = 0 then
      begin ReleaseCache; Exit; end;

    FCacheBuf := MapViewOfFile(FMapHandle, FILE_MAP_READ, 0, 0, FCacheSize);
    if FCacheBuf = nil then
      begin ReleaseCache; Exit; end;

    Result := True;
  end;


  procedure TReviewImageRec.ReleaseCache;
  begin
//  if FMapFile <> 0 then
//    Trace('Close FileMapping: %s', [FName] );

    if FCacheBuf <> nil then
      UnmapViewOfFile(FCacheBuf);
    FCacheBuf := nil;

    if FMapHandle <> 0 then
      FileClose(FMapHandle);
    FMapHandle := 0;
    if (FMapFile <> 0) and (FMapFile <> INVALID_HANDLE_VALUE) then
      FileClose(FMapFile);
    FMapFile := 0;
  end;

 {$else}

  function TReviewImageRec.PrecacheFile(const AFileName :TString) :Boolean;
  var
    vFile :THandle;
  begin
    vFile := CreateFile(PTChar(AFileName), GENERIC_READ, FILE_SHARE_READ {or FILE_SHARE_WRITE}, nil, OPEN_EXISTING,
       FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0);
    try
      FSize := FileSize(vFile);

      FCacheSize := IntMin(FSize, cPreCacheLimit);

      FCacheBuf := MemAlloc(FCacheSize);
      FCacheSize := FileRead(vFile, FCacheBuf^, FCacheSize);

      Result := True;

    finally
      FileClose(vFile);
    end;
  end;


  procedure TReviewImageRec.ReleaseCache;
  begin
    MemFree(FCacheBuf);
  end;
 {$endif bUseMapping}



 {-----------------------------------------------------------------------------}
 { TReviewDecoder                                                              }
 {-----------------------------------------------------------------------------}

  constructor TReviewDecoder.Create; {override;}
  begin
    inherited Create;
    FEnabled := True;
  end;


  constructor TReviewDecoder.CreateCache(const aName, aTitle :TString; aModified :Integer;
    aEnabled :Boolean; aPriority :Integer; const aActive, aIgnore :TString; ACustomMask :Boolean);
  begin
    Create;

    FName := aName;
    FTitle := aTitle;
    FModified := aModified;
    FEnabled := aEnabled;
    FPriority := aPriority;

    SetExtensions(aActive, aIgnore);
    FCustomMask := ACustomMask;
  end;


  destructor TReviewDecoder.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  function TReviewDecoder.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    if Context = 1 then
      Result := IntCompare(FPriority, TReviewDecoder(Another).FPriority)
    else
      Result := inherited CompareObj(Another, Context);
  end;


  function TReviewDecoder.CanShowThumbs :boolean; {virtual;}
  begin
    Result := True;
  end;


  function TReviewDecoder.NeedPrecache :boolean; {virtual;}
  begin
    Result := True;
  end;


  procedure TReviewDecoder.ResetSettings; {virtual;}
  begin
  end;


  procedure TReviewDecoder.SetExtensions(const aActive, aIgnore :TString);

    function LocConvertMask(const AStr :TString) :TString;
    var
      i :Integer;
      vStr :TString;
      vList :TStringList;
    begin
      vList := TStringList.Create;
      try
        vList.Text := StrDeleteChars(StrReplaceChars(AStr, [',', ';'], #13), [' ']);
        for i := 0 to vList.Count - 1 do begin
          vStr := vList[i];
          if (vStr <> '') and (vStr[1] <> '<') and not FileNameHasMask(vStr) then
            vList[i] := '*.' + vStr;
        end;
        Result := vList.GetTextStrEx(',');
      finally
        FreeObj(vList);
      end;
    end;

  begin
    FActiveStr := aActive;
    FIgnoreStr := aIgnore;

    FActiveMask := LocConvertMask(FActiveStr);
    FIgnoreMask := LocConvertMask(FIgnoreStr);
  end;


  function TReviewDecoder.SupportedFile(const AName :TSTring) :Boolean;
  var
    vName :TString;
  begin
    vName := ExtractFileName(AName);
    Result := FARSTD.ProcessName(PTChar(FActiveMask), PTChar(vName), 0, PN_CMPNAMELIST) <> 0;
    if Result then
      Result := FARSTD.ProcessName(PTChar(FIgnoreMask), PTChar(vName), 0, PN_CMPNAMELIST) = 0;
  end;


  function TReviewDecoder.CanShowThumbFor(const AName :TString) :Boolean;
  begin
    Result := Enabled and SupportedFile(AName) and CanWork(True) and CanShowThumbs;
  end;


  function TReviewDecoder.GetMaskAsStr :TString;
  begin
    Result := FActiveStr;
    if FIgnoreStr <> '' then
      Result := Result + '|' + FIgnoreStr;
  end;


  function TReviewDecoder.GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; {virtual;}
  begin
    Result := 0;
  end;


  function TReviewDecoder.Idle(AImage :TReviewImageRec; AWidth, AHeight :Integer) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TReviewDecoder.Save(AImage :TReviewImageRec; const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean; {virtual;}
  begin
    AppError(strUnsupportedFeature);
    Result := False;
  end;


 {-----------------------------------------------------------------------------}

  function TReviewDecoder.pvdDisplayInit(AWnd :THandle) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  procedure TReviewDecoder.pvdDisplayDone(AWnd :THandle); {virtual;}
  begin
  end;


  function TReviewDecoder.pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function TReviewDecoder.pvdDisplayPaint(AWnd :THandle; ADC :HDC; AImage :TReviewImageRec; const AImageRect, ADisplayRect, AFullDisplayRect :TRect; AColor :DWORD) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  procedure TReviewDecoder.pvdDisplayClose(AImage :TReviewImageRec); {virtual;}
  begin
  end;


 {-----------------------------------------------------------------------------}

  function TReviewDecoder.pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; {virtual;}
  begin
    Result := False;
  end;



 {-----------------------------------------------------------------------------}
 { TReviewDllDecoder                                                           }
 {-----------------------------------------------------------------------------}

  constructor TReviewDllDecoder.CreateEx(const AName :TString; aModified :Integer);
  begin
    Create;
    FDllName := aName;
    FModified := aModified;
    FName := ExtractFileName(AName);
    InitPlugin(False);
  end;


  destructor TReviewDllDecoder.Destroy; {override;}
  begin
    DonePlugin;
    inherited Destroy;
  end;


  function TReviewDllDecoder.GetState :TDecoderState; {override;}
  begin
    if FInitState = 0 then
      Result := rdsCached
    else
    if FInitState = 1 then
      Result := rdsLoaded
    else
      Result := rdsError;
  end;


  function TReviewDllDecoder.CanWork(aLoad :Boolean) :Boolean; {override;}
  var
    vPath, vOldExts :TString;
  begin
    if not aLoad then
      Result := FInitState < 2
    else begin
      if FInitState = 0 then begin
        { Декодер был закэширован, теперь инициализируем его}

        if not CustomMask then
          vOldExts := GetMaskAsStr;

        vPath := RemoveBackSlash(ExtractFilePath(FDLLName));
        SetDllDirectory(PTChar(vPath));
        try
          InitPlugin(CustomMask);
        finally
          SetDllDirectory(nil);
        end;

        if not CustomMask and not StrEqual(vOldExts, GetMaskAsStr) then
          { Изменился состав масок, обрабатываемых декодером по умолчанию. }
          { Например, установили новый кодек... }
          NeedStoreCache := True;
      end;
      Result := FInitState = 1;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewDllDecoder1                                                          }
 {-----------------------------------------------------------------------------}

  constructor TReviewDllDecoder1.Create; {override;}
  begin
    inherited Create;
    FKind := 1;
  end;


  procedure TReviewDllDecoder1.InitPlugin(aKeepSettings :Boolean);
  begin
    try
      FHandle := LoadLibraryEx(FDllName);

      FpvdInit           := GetProcAddressEx(FHandle, 'pvdInit');
      FpvdExit           := GetProcAddressEx(FHandle, 'pvdExit', False);

      FpvdPluginInfo     := GetProcAddressEx(FHandle, 'pvdPluginInfo', False);

      FpvdFileOpen       := GetProcAddressEx(FHandle, 'pvdFileOpen');
      FpvdPageInfo       := GetProcAddressEx(FHandle, 'pvdPageInfo', False);
      FpvdPageDecode     := GetProcAddressEx(FHandle, 'pvdPageDecode', False);
      FpvdPageFree       := GetProcAddressEx(FHandle, 'pvdPageFree', False);
      FpvdFileClose      := GetProcAddressEx(FHandle, 'pvdFileClose', False);

      pvdInit;
      pvdGetInfo;

      if not aKeepSettings then
//      FActiveExt.Text := '*';
        SetExtensions('*', '');

      FInitState := 1;

    except
      on E :Exception do begin
        FLastError := E.Message;
        FInitState := 2;
      end;
    end;
  end;


  procedure TReviewDllDecoder1.DonePlugin;
  begin
    if FHandle <> 0 then begin
      if FInitState = 1 then
        pvdExit;
      FreeLibrarySafe(FHandle);
      FHandle := 0;
    end;
  end;


  procedure TReviewDllDecoder1.pvdInit;
  var
    vRes :Integer;
  begin
    vRes := FpvdInit();

    if vRes <> PVD_CURRENT_INTERFACE_VERSION then begin
      pvdExit;
      AppErrorFmt(strUnsupportedPlugin, [vRes]);
    end;
  end;


  procedure TReviewDllDecoder1.pvdExit;
  begin
    if not Assigned(FpvdExit) then
      Exit;
    FpvdExit();
  end;


  procedure TReviewDllDecoder1.pvdGetInfo;
  var
    vRec :TPVDInfoPlugin;
  begin
    if not Assigned(FpvdPluginInfo) then
      Exit;

    FillZero(vRec, SizeOf(vRec));
    FpvdPluginInfo(@vRec);

    FTitle    := vRec.pName;
    FVersion  := vRec.pVersion;
    FComment  := vRec.pComments;
    FPriority := vRec.Priority;
  end;


  function TReviewDllDecoder1.pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoImage;
    vFileName :TAnsiStr;
  begin
    vFileName := WideToUTF8(AFileName);

    FillZero(vInfo, SizeOf(vInfo));
    Result := FpvdFileOpen(PAnsiChar(vFileName), AImage.FSize, AImage.FCacheBuf, AImage.FCacheSize, @vInfo, AImage.FContext);

    if Result then begin
      AImage.FFormat := vInfo.pFormatName;
      AImage.FCompress := vInfo.pCompression;
      AImage.FDescr := vInfo.pComments;
      AImage.FPages := vInfo.nPages;
      AImage.FAnimated := vInfo.Flags and PVD_IIF_ANIMATED <> 0;
    end;
  end;


  function TReviewDllDecoder1.pvdGetPageInfo(AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoPage;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    Result := FpvdPageInfo(AImage.FContext, AImage.FPage, @vInfo);

    if Result then begin
      AImage.FWidth  := vInfo.lWidth;
      AImage.FHeight := vInfo.lHeight;
      AImage.FBPP    := vInfo.nBPP;
      AImage.FDelay  := vInfo.lFrameTime;
    end;
  end;


  function MyDecodeCallback1(AContext :Pointer; AStep, ASteps :Cardinal) :Boolean; stdcall;
  begin
    Result := True;
  end;


  function TReviewDllDecoder1.pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
    const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean;
  var
    vInfo :TPVDInfoDecode;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    Result := FpvdPageDecode(AImage.FContext, AImage.FPage, @vInfo, MyDecodeCallback1, Self);
    if Result then begin
      AImage.FDecodeInfo := MemAlloc(SizeOf(vInfo));
      Move(vInfo, AImage.FDecodeInfo^, SizeOf(vInfo));
    end;
  end;


  function TReviewDllDecoder1.GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; {override;}
  begin
    Result := 0; aIsThumbnail := False;
    if AImage.FDecodeInfo <> nil then
      with PPVDInfoDecode(AImage.FDecodeInfo)^ do
        Result := CreateBitmapAs(AImage.FWidth, AImage.FHeight, nBPP, lImagePitch, pImage, pPalette, PVD_CM_BGR, 0);
  end;


  procedure TReviewDllDecoder1.pvdPageFree(AImage :TReviewImageRec);
  begin
    if not Assigned(FpvdPageFree) then
      Exit;
    FpvdPageFree(AImage.FContext, AImage.FDecodeInfo);
    MemFree(AImage.FDecodeInfo);
  end;


  procedure TReviewDllDecoder1.pvdFileClose(AImage :TReviewImageRec);
  begin
    if not Assigned(FpvdFileClose) then
      Exit;
    FpvdFileClose(AImage.FContext);
    AImage.FContext := nil;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewDllDecoder2                                                          }
 {-----------------------------------------------------------------------------}

  constructor TReviewDllDecoder2.Create; {override;}
  begin
    inherited Create;
    FKind := 2;
  end;


  function TReviewDllDecoder2.CanShowThumbs :boolean; {override;}
  begin
    Result := FPlugFlags and PVD_IP_DISPLAY = 0;
  end;


  function TReviewDllDecoder2.NeedPrecache :boolean; {override;}
  begin
    Result := FPlugFlags and PVD_IP_NEEDFILE = 0;
//  Result := True;
  end;


  procedure TReviewDllDecoder2.ResetSettings; {override;}
  begin
    if CanWork(True) then
      pvdGetFormats
    else
      SetExtensions('', '');
    FCustomMask := False;
  end;


  procedure TReviewDllDecoder2.InitPlugin(aKeepSettings :Boolean);
  begin
    try
      FHandle := LoadLibraryEx(FDllName);

      FpvdInit           := GetProcAddressEx(FHandle, 'pvdInit2');
      FpvdExit           := GetProcAddressEx(FHandle, 'pvdExit2', False);

      FpvdPluginInfo     := GetProcAddressEx(FHandle, 'pvdPluginInfo2', False);
      FpvdGetFormats     := GetProcAddressEx(FHandle, 'pvdGetFormats2', False);
      FpvdReloadConfig   := GetProcAddressEx(FHandle, 'pvdReloadConfig2', False);
      FpvdTranslateError := GetProcAddressEx(FHandle, 'pvdTranslateError2', False);

      FpvdFileOpen       := GetProcAddressEx(FHandle, 'pvdFileOpen2');
      FpvdPageInfo       := GetProcAddressEx(FHandle, 'pvdPageInfo2', False);
      FpvdPageDecode     := GetProcAddressEx(FHandle, 'pvdPageDecode2', False);
      FpvdPageFree       := GetProcAddressEx(FHandle, 'pvdPageFree2', False);
      FpvdFileClose      := GetProcAddressEx(FHandle, 'pvdFileClose2', False);

      FpvdDisplayInit    := GetProcAddressEx(FHandle, 'pvdDisplayInit2', False);
      FpvdDisplayAttach  := GetProcAddressEx(FHandle, 'pvdDisplayAttach2', False);
      FpvdDisplayCreate  := GetProcAddressEx(FHandle, 'pvdDisplayCreate2', False);
      FpvdDisplayPaint   := GetProcAddressEx(FHandle, 'pvdDisplayPaint2', False);
      FpvdDisplayClose   := GetProcAddressEx(FHandle, 'pvdDisplayClose2', False);
      FpvdDisplayExit    := GetProcAddressEx(FHandle, 'pvdDisplayExit2', False);

      FpvdPlayControl    := GetProcAddressEx(FHandle, 'pvdPlayControl', False);
      FpvdTagInfo        := GetProcAddressEx(FHandle, 'pvdTagInfo', False);

      pvdInit;
      pvdGetInfo;

      if not aKeepSettings then
        pvdGetFormats;

      FInitState := 1;

    except
      on E :Exception do begin
        FLastError := E.Message;
        FInitState := 2;
      end;
    end;
  end;


  procedure TReviewDllDecoder2.DonePlugin;
  begin
    if FHandle <> 0 then begin
      if FInitState = 1 then
        pvdExit;
      FreeLibrarySafe(FHandle);
      FHandle := 0;
    end;
  end;


  procedure TReviewDllDecoder2.pvdInit;
  var
    vRec :TPVDInitPlugin2;
    vRes :Integer;
  begin
    if FRegKey = '' then
      FRegKey := cRegPath + '\' + FName;

    FillZero(vRec, SizeOf(vRec));
    vRec.cbSize := SizeOf(vRec);
    vRec.hModule := FHandle;
    vRec.nMaxVersion := PVD_UNICODE_INTERFACE_VERSION;
    vRec.pRegKey := PTChar(FRegKey);
    vRec.CallSehed := nil; //!!!
    vRec.SortExtensions := @SortExtensions;
    vRec.MulDivI32 := @MulDivI32;
    vRec.MulDivU32 := @MulDivU32;
    vRec.MulDivU32R := @MulDivU32R;
    vRec.MulDivIU32R := @MulDivIU32R;

    vRes := FpvdInit(@vRec);

    FInitError := Integer(vRec.nErrNumber);
    FInitContext := vRec.pContext;

    if vRes <> PVD_UNICODE_INTERFACE_VERSION then begin
      pvdExit;
      AppErrorFmt(strPluginInitError, [FInitError]);
    end;
  end;


  procedure TReviewDllDecoder2.pvdExit;
  begin
    if not Assigned(FpvdExit) then
      Exit;
    FpvdExit(FInitContext);
  end;


  procedure TReviewDllDecoder2.pvdGetInfo;
  var
    vRec :TPVDInfoPlugin2;
  begin
    if not Assigned(FpvdPluginInfo) then
      Exit;

    FillZero(vRec, SizeOf(vRec));
    vRec.cbSize := SizeOf(vRec);
    vRec.hModule := FHandle;

    FpvdPluginInfo(@vRec);

    FTitle     := vRec.pName;
    FVersion   := vRec.pVersion;
    FComment   := vRec.pComments;
    FPriority  := vRec.Priority;
    FPlugFlags := vRec.Flags;

//  Trace('pvdGetInfo: %s, Flags=%x', [FName, FPlugFlags]);
  end;


  procedure TReviewDllDecoder2.pvdGetFormats;
  var
    vRec :TPVDFormats2;
  begin
    if not Assigned(FpvdGetFormats) then
      Exit;

    FillZero(vRec, SizeOf(vRec));
    vRec.cbSize := SizeOf(vRec);

    FpvdGetFormats(FInitContext, @vRec);
    SetExtensions(vRec.pSupported, vRec.pIgnored);
  end;


  function TReviewDllDecoder2.pvdTranslateError(aCode :DWORD) :TString;
  var
    vBuf :array[0..1024] of TChar;
  begin
    Result := '';
    if not Assigned(FpvdTranslateError) or (aCode = 0) then
      Exit;

    FillZero(vBuf, SizeOf(vBuf));
    if FpvdTranslateError(aCode, vBuf, High(vBuf)) then
      Result := vBuf;
    if Result = '' then
      Result := 'Error code = ' + Int2Str(Integer(aCode));  
  end;


 {-----------------------------------------------------------------------------}

  function TReviewDllDecoder2.pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoImage2;
  begin
    FLastError := '';
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.pImageContext := AImage.FContext;

    Result := FpvdFileOpen(FInitContext, PTChar(AFileName), AImage.FSize, AImage.FCacheBuf, AImage.FCacheSize, @vInfo);

    if Result then begin
      AImage.FContext := vInfo.pImageContext;
      AImage.FFormat := vInfo.pFormatName;
      AImage.FCompress := vInfo.pCompression;
      AImage.FDescr := vInfo.pComments;
      AImage.FAnimated := vInfo.Flags and PVD_IIF_ANIMATED <> 0;
      AImage.FMovie := vInfo.Flags and PVD_IIF_MOVIE <> 0;
      if AImage.FMovie then
        AImage.FLength := vInfo.nPages
      else
        AImage.FPages := vInfo.nPages;
    end else
      FLastError := pvdTranslateError(vInfo.nErrNumber);
  end;


  function TReviewDllDecoder2.pvdGetPageInfo(AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoPage2;
  begin
    FLastError := '';
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.iPage := AImage.FPage;

    Result := FpvdPageInfo(FInitContext, AImage.FContext, @vInfo);

    if Result then begin
      AImage.FWidth   := vInfo.lWidth;
      AImage.FHeight  := vInfo.lHeight;
      AImage.FBPP     := vInfo.nBPP;
      AImage.FDelay   := vInfo.lFrameTime;
      AImage.FOrient0 := vInfo.Orientation;

      { Коррекция 1 }
      if vInfo.nPages <> 0 then
        AImage.FPages := vInfo.nPages;
      if vInfo.pFormatName <> nil then
        AImage.FFormat := vInfo.pFormatName;
      if vInfo.pCompression <> nil then
        AImage.FCompress := vInfo.pCompression;
    end else
      FLastError := pvdTranslateError(vInfo.nErrNumber);
  end;


  type
    PContextRec = ^TContextRec;
    TContextRec = record
      Callback :TDecodeCallback;
      Data :Pointer;
    end;

  function MyDecodeCallback2(AContext :Pointer; AStep, ASteps :Cardinal; AInfo :Pointer) :Boolean; stdcall;
  begin
//  Trace('MyDecodeCallback2 %d/%d...', [AStep, ASteps]);
    Result := True;
    with PContextRec(AContext)^ do
      if Assigned(Callback) then
        Callback(Data, MulDiv(AStep, 100, ASteps), Result);
  end;


  function TReviewDllDecoder2.pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
    const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean;
  var
    vInfo :TPVDInfoDecode2;
    vContext :TContextRec;
  begin
    FLastError := '';
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.iPage := AImage.FPage;
    vInfo.lWidth := AWidth;
    vInfo.lHeight := AHeight;
    vInfo.nBackgroundColor := 0{ABkColor};
    vInfo.Flags := 0;
    if AMode = dmThumbnail then
      vInfo.Flags := vInfo.Flags or PVD_IDF_THUMBONLY
    else
    if AMode = dmThumbnailOrImage then
      vInfo.Flags := vInfo.Flags or PVD_IDF_THUMBFIRST;

    vContext.Callback := ACallback;
    vContext.Data := ACallbackData;

    Result := FpvdPageDecode(FInitContext, AImage.FContext, @vInfo, MyDecodeCallback2, @vContext);

    if Result then begin
      AImage.FSelfdraw := vInfo.Flags and PVD_IDF_PRIVATE_DISPLAY <> 0;
      AImage.FTransparent := vInfo.Flags and ({PVD_IDF_TRANSPARENT + PVD_IDF_TRANSPARENT_INDEX +} PVD_IDF_ALPHA) <> 0;
      if vInfo.Orientation <> 0 then
        AImage.FOrient0 := vInfo.Orientation;

      { Коррекция 2 }
      if vInfo.nPages <> 0 then
        AImage.FPages := vInfo.nPages;
      if vInfo.pFormatName <> nil then
        AImage.FFormat := vInfo.pFormatName;
      if vInfo.pCompression <> nil then
        AImage.FCompress := vInfo.pCompression;
      if vInfo.lSrcWidth <> 0 then
        AImage.FWidth := vInfo.lSrcWidth;
      if vInfo.lSrcHeight <> 0 then
        AImage.FHeight := vInfo.lSrcHeight;
      if vInfo.lSrcBPP <> 0 then
        AImage.FBPP := vInfo.lSrcBPP;

      AImage.FDecodeInfo  := MemAlloc(SizeOf(vInfo));
      Move(vInfo, AImage.FDecodeInfo^, SizeOf(vInfo));
    end else
      FLastError := pvdTranslateError(vInfo.nErrNumber);
  end;


  function TReviewDllDecoder2.GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; {override;}
  var
    vTranspColor :UINT;
  begin
    Result := 0; aIsThumbnail := False;
    if AImage.FDecodeInfo <> nil then
      with PPVDInfoDecode2(AImage.FDecodeInfo)^ do begin
        vTranspColor := nTransparentColor;
        if Flags and (PVD_IDF_TRANSPARENT + PVD_IDF_TRANSPARENT_INDEX) = 0 then
          vTranspColor := DWORD(-1);
        Result := CreateBitmapAs(lWidth, lHeight, nBPP, lImagePitch, pImage, pPalette, ColorModel, vTranspColor);
        aIsThumbnail := PVD_IDF_THUMBNAIL and Flags <> 0;
        if aIsThumbnail and optCorrectThumb then
          Result := AImage.CorrectThumbnail(Result);
      end;
  end;


  procedure TReviewDllDecoder2.pvdPageFree(AImage :TReviewImageRec);
  begin
    if not Assigned(FpvdPageFree) then
      Exit;
    FpvdPageFree(FInitContext, AImage.FContext, AImage.FDecodeInfo);
    MemFree(AImage.FDecodeInfo);
  end;


  procedure TReviewDllDecoder2.pvdFileClose(AImage :TReviewImageRec);
  begin
    if not Assigned(FpvdFileClose) then
      Exit;
    FpvdFileClose(FInitContext, AImage.FContext);
    AImage.FContext := nil;
  end;


 {-----------------------------------------------------------------------------}

{
  // Инициализация контекста дисплея. Используется тот pContext, который был получен в pvdInit2
  function pvdDisplayInit2(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;

  // Прицепиться или отцепиться от окна вывода
  function pvdDisplayAttach2(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;

  // Создать контекст для отображения картинки в pContext (перенос декодированных данных в видеопамять)
  function pvdDisplayCreate2(pContext :Pointer; pDisplayCreate :PPVDInfoDisplayCreate2) :BOOL; stdcall;

  // Собственно отрисовка. Функция должна при необходимости выполнять "Stretch"
  function pvdDisplayPaint2(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;

  // Закрыть контекст для отображения картинки (освободить видеопамять)
  procedure pvdDisplayClose2(pContext :Pointer; pDisplayContext :Pointer); stdcall;

  // Закрыть модуль вывода (освобождение интерфейсов DX, отцепиться от окна)
  procedure pvdDisplayExit2(pContext :Pointer); stdcall;
}


  function TReviewDllDecoder2.pvdDisplayInit(AWnd :THandle) :Boolean;
  var
    vInit :TPVDInfoDisplayInit2;
    vAttach :TPVDInfoDisplayAttach2;
  begin
    Result := True;
    if not Assigned(FpvdDisplayInit) then
      Exit;

    FillZero(vInit, SizeOf(vInit));
    vInit.cbSize := SizeOf(vInit);
    vInit.hWnd := AWnd;
//  vInit.nCMYKparts :=  ???
//  vInit.pCMYKpalette :=
//  vInit.nCMYKsize :=
//  vInit.uCMYK2RGB :=

    Result := FpvdDisplayInit(FInitContext, @vInit);
    if not Result then
      Exit;

    {??? Может вообще не нужно?...}
    if Assigned(FpvdDisplayAttach) then begin
      FillZero(vAttach, SizeOf(vAttach));
      vAttach.cbSize := SizeOf(vAttach);
      vAttach.hWnd := AWnd;
      vAttach.bAttach := True;

      {Result :=} FpvdDisplayAttach(FInitContext, @vAttach);
    end;
  end;


  procedure TReviewDllDecoder2.pvdDisplayDone(AWnd :THandle);
  begin
    if not Assigned(FpvdDisplayExit) then
      Exit;
    {??? Detach? }
    FpvdDisplayExit(FInitContext);
  end;


  function TReviewDllDecoder2.pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean;
  var
    vRec :TPVDInfoDisplayCreate2;
  begin
    Result := False;
    if not Assigned(FpvdDisplayCreate) then
      Exit;

    FillZero(vRec, SizeOf(vRec));
    vRec.cbSize := SizeOf(vRec);
    vRec.pImage := AImage.FDecodeInfo;
//  vRec.BackColor := ...

    Result := FpvdDisplayCreate(FInitContext, @vRec);

    if Result then begin
      AImage.FDisplayCtx := vRec.pDisplayContext;
    end;
  end;


  function TReviewDllDecoder2.pvdDisplayPaint(AWnd :THandle; ADC :HDC; AImage :TReviewImageRec; const AImageRect, ADisplayRect, AFullDisplayRect :TRect; AColor :DWORD) :Boolean;
  var
    vRec :TPVDInfoDisplayPaint2;
  begin
    Result := False;
    if not Assigned(FpvdDisplayPaint) then
      Exit;

    FillZero(vRec, SizeOf(vRec));
    vRec.cbSize := SizeOf(vRec);
    vRec.hWnd := AWnd;
//  vRec.hParentWnd := ...
    vRec.nBackColor := AColor;
    vRec.ImageRect := AImageRect;
    vRec.DisplayRect := ADisplayRect;

    vRec.Operation := PVD_IDP_BEGIN;
    if FpvdDisplayPaint(FInitContext, AImage.FDisplayCtx, @vRec) then begin
      try
        vRec.Operation := PVD_IDP_COLORFILL;
        FpvdDisplayPaint(FInitContext, AImage.FDisplayCtx, @vRec);

        vRec.Operation := PVD_IDP_PAINT;
        Result := FpvdDisplayPaint(FInitContext, AImage.FDisplayCtx, @vRec);

      finally
        vRec.Operation := PVD_IDP_COMMIT;
        FpvdDisplayPaint(FInitContext, AImage.FDisplayCtx, @vRec);
      end;
    end;
  end;


  procedure TReviewDllDecoder2.pvdDisplayClose(AImage :TReviewImageRec);
  begin
    if not Assigned(FpvdDisplayClose) then
      Exit;
    FpvdDisplayClose(FInitContext, AImage.FDisplayCtx);
    AImage.FDisplayCtx := nil;
  end;



  function TReviewDllDecoder2.pvdPlayControl(AImage :TReviewImageRec; aCmd :Integer; aInfo :TIntPtr) :Integer; {override;}
  begin
    Result := 0;
    if not Assigned(FpvdPlayControl) then
      Exit;

    Result := FpvdPlayControl(FInitContext, AImage.FContext, aCmd, Pointer(aInfo));
  end;


  function TReviewDllDecoder2.pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; {virtual;}
  begin
    Result := False;
    if not Assigned(FpvdTagInfo) then
      Exit;

    Result := FpvdTagInfo(FInitContext, AImage.FContext, PVD_TagCmd_Get, aCode, aType, aValue);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetPVDVersion(const AName :TString; var AHandle :THandle) :Integer;
  begin
    Result := 0;
    AHandle := LoadLibraryEx(AName, False);
    if AHandle <> 0 then begin
      if GetProcAddress(AHandle, 'pvdInit2') <> nil then
        Result := 2
      else
      if GetProcAddress(AHandle, 'pvdInit') <> nil then
        Result := 1
    end;
  end;


  procedure SaveDecodersInfo(aDecoders :TObjList);
  var
    vConfig :TFarConfig;

    procedure LocSave(AIndex :Integer; aDecoder :TReviewDecoder);
    begin
      if vConfig.OpenKey(cDecodersRegFolder + '\' + cDecoderRegFolder + Int2Str(AIndex)) then begin
        try
          vConfig.WriteInt(cDecoderKindRegKey, aDecoder.Kind);
          vConfig.WriteStr(cDecoderNameRegKey, aDecoder.Name);
          vConfig.WriteStr(cDecoderTitleRegKey, aDecoder.Title);
          vConfig.WriteInt(cDecoderPriorityRegKey, aDecoder.Priority);
          vConfig.WriteInt(cDecoderModifiedRegKey, aDecoder.Modified);
          vConfig.WriteLog(cDecoderEnabledRegKey, aDecoder.Enabled);
          vConfig.WriteStr(cDecoderActiveRegKey, aDecoder.ActiveStr);
          vConfig.WriteStr(cDecoderIgnoreRegKey, aDecoder.IgnoreStr);
          vConfig.WriteLog(cDecoderCustomRegKey, aDecoder.CustomMask);
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I :Integer;
  begin
//  TraceF('SaveDecodersInfo (%d)...', [aDecoders.Count]);
    vConfig := TFarConfig.CreateEx(True, cPluginName);
    try
      if vConfig.OpenKey(cDecodersRegFolder) then begin
        vConfig.WriteInt(cDecodersCount, aDecoders.Count);
        vConfig.OpenKey( '' );

        for I := 0 to aDecoders.Count - 1 do
          LocSave(I, aDecoders[I]);

        NeedStoreCache := False;
      end;
    finally
      FreeObj(vConfig);
    end;
  end;



  function RestoreDecodersCache(aDecoders :TObjList) :Boolean;
  var
    vConfig :TFarConfig;
    vPos :Integer;

    procedure LocLoad(AIndex :Integer);
    var
      vName, vTitle, vActive, vIgnore :TString;
      vKind, vModified, vPriority, vIndex :Integer;
      vEnabled, vCustomMask :Boolean;
      vClass :TReviewDecoderClass;
      vDecoder :TReviewDecoder;
    begin
      if vConfig.OpenKey( cDecodersRegFolder + '\' + cDecoderRegFolder + Int2Str(AIndex) ) then begin
        try
          vKind := vConfig.ReadInt(cDecoderKindRegKey, -1);
          vName := vConfig.ReadStr(cDecoderNameRegKey);
          vTitle := vConfig.ReadStr(cDecoderTitleRegKey);
          vPriority := vConfig.ReadInt(cDecoderPriorityRegKey);
          vModified := vConfig.ReadInt(cDecoderModifiedRegKey);
          vEnabled := vConfig.ReadLog(cDecoderEnabledRegKey, True);
          vActive := vConfig.ReadStr(cDecoderActiveRegKey);
          vIgnore := vConfig.ReadStr(cDecoderIgnoreRegKey);
          vCustomMask := vConfig.ReadLog(cDecoderCustomRegKey);

          if vKind = 0 then begin
            if not aDecoders.FindKey(Pointer(vName), 0, [], vIndex) then
              Exit;

            vDecoder := aDecoders[vIndex];
            vDecoder.FEnabled := vEnabled;
            if vCustomMask then begin
              vDecoder.SetExtensions(vActive, vIgnore);
              vDecoder.FCustomMask := True;
            end;
            vDecoder.FWasInCache := True;

            if vIndex <> vPos then
              aDecoders.Move(vIndex, vPos);
            Inc(vPos);
          end else
          begin
            if aDecoders.FindKey(Pointer(vName), 0, [], vIndex) then
              Exit;

            case vKind of
              1: vClass := TReviewDllDecoder1;
              2: vClass := TReviewDllDecoder2;
            else
              Exit;
            end;

            aDecoders.Insert(vPos, vClass.CreateCache(vName, vTitle, vModified, vEnabled, vPriority, vActive, vIgnore, vCustomMask) );
            Inc(vPos);
          end;
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I, vCount :Integer;
  begin
    Result := False;
    vConfig := TFarConfig.CreateEx(False, cPluginName);
    try
      if vConfig.Exists and vConfig.OpenKey( cDecodersRegFolder ) then begin
        vCount := vConfig.ReadInt(cDecodersCount);
        vConfig.OpenKey( '' );
        if vCount > 0 then begin
          vPos := 0;
          for I := 0 to vCount - 1 do
            LocLoad(I);
          Result := True;
        end;
      end;
    finally
      FreeObj(vConfig);
    end;
  end;


  procedure InitDecodersFrom(aDecoders :TObjList; const aPath :TString);
  var
    vCache :Boolean;

    function LocEnumPlugin(const APath :TString; const ARec :TWin32FindData) :Boolean;
    var
      vClass :TReviewDllDecoderClass;
      vName, vFileName :TString;
      vIndex, vFileDate :Integer;
      vHandle :THandle;
      vDecoder :TReviewDecoder;
      vVer :Integer;
    begin
      Result := True;
      vName := ARec.cFileName;
      vFileName := AddFileName(APath, vName);
      vFileDate := FileTimeToDosFileDate(ARec.ftLastWriteTime);

      vDecoder := nil;
      if vCache and aDecoders.FindKey(Pointer(vName), 0, [], vIndex) then begin
        vDecoder := aDecoders[vIndex];
        if (vDecoder is TReviewDllDecoder) and (vDecoder.Modified = vFileDate) then begin
          { Информация в кэше соответствует файлу, загрузим декодер позже - по необходимости }
          TReviewDllDecoder(vDecoder).FDllName := vFileName;
          Exit;
        end;
      end;

     {$ifdef bTrace}
      TraceF('PVD: %s', [vFileName]);
     {$endif bTrace}
      SetDllDirectory(PTChar(APath));
      vVer := GetPVDVersion(vFileName, vHandle);
      try
        case vVer of
          1: vClass := TReviewDllDecoder1;
          2: vClass := TReviewDllDecoder2;
        else
          Exit;
        end;

        if (vDecoder <> nil) and (vDecoder.ClassType = vClass) then begin
          { Обновляем настройки декодера }
          with TReviewDllDecoder(vDecoder) do begin
            FDllName := vFileName;
            FModified := vFileDate;
            InitPlugin(CustomMask);
          end;
        end else
        begin
          if vDecoder <> nil then
            { Изменился тип декодера - экзотическая ситуация, но - на всякий случай }
            aDecoders.FreeAt(vIndex)
          else
            vIndex := aDecoders.Count;

          vDecoder := vClass.CreateEx(vFileName, vFileDate);
          aDecoders.Insert( vIndex, vDecoder );
        end;

        NeedStoreCache := True;

      finally
        if vHandle <> 0 then
          FreeLibrary(vHandle);
        SetDllDirectory(nil);
      end;
    end;

  var
    I :Integer;
    vDecoder :TReviewDecoder;
  begin
   {$ifdef bUseLibJPEG}
    aDecoders.Add(TReviewJPEGDecoder.Create);
    vDecoder := aDecoders[0];
   {$endif bUseLibJPEG}
    aDecoders.Add(TReviewGDIDecoder.Create);
    aDecoders.Add(TReviewWMFDecoder.Create);

    vCache := RestoreDecodersCache(aDecoders);
    NeedStoreCache := not vCache;

    if WinFolderExists(aPath) then begin
      WinEnumFilesEx(aPath, cPluginsMask, faEnumFiles, [efoRecursive],  LocalAddr(@LocEnumPlugin));

      if not vCache then
        { Если это первая загрузка - сортируем декодеры по приоритетам }
        { Если декодеры были добавлены потом - приоритеты игнорируются, }
        { новые декодеры окажутся в конце списка. }
        aDecoders.SortList(False, 1)
      else begin
       {$ifdef bUseLibJPEG}
        if not vDecoder.FWasInCache then
          aDecoders.Move(aDecoders.IndexOf(vDecoder), 0);
       {$endif bUseLibJPEG}
      end;
    end;

    { Удалим декодеры, для которых не найдено DLL }
    for I := aDecoders.Count - 1 downto 0 do begin
      vDecoder := aDecoders[I];
      if (vDecoder is TReviewDllDecoder) and (TReviewDllDecoder(vDecoder).FDllName = '') then
        aDecoders.FreeAt(I);
    end;

    if NeedStoreCache then
      SaveDecodersInfo(aDecoders);
  end;

end.


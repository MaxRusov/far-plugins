{$I Defines.inc}

unit ReviewDecoders;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* Review                                                                     *}
{* Image Viewer Plugn for Far 2/3                                             *}
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
    FarConfig,
    PVAPI,

    ReviewConst;


  type
    TReviewImageRec = class(TComBasis)
    public
      FName        :TString;           { Имя файла }

      FSize        :Int64;             { Размер файла }
      FCacheBuf    :Pointer;
      FCacheSize   :Integer;

      FContext     :Pointer;           { Контекст для декодирования }
      FFormat      :TString;           { Имя формата }
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
      FOrient      :Integer;           { Ориентация (дополнительный поворот после декодирования) }

      FSelfdraw    :Boolean;

      FBmpWidth    :Integer;
      FBmpHeight   :Integer;
      FBmpBPP      :Integer;
      FBmpBits     :Pointer;
      FBmpPalette  :Pointer;
      FBmpColors   :Integer;
      FBmpRowBytes :Integer;
      FColorModel  :byte;
      FTranspColor :UINT;
      FDecodeInfo  :Pointer;

      FDisplayCtx  :Pointer;           { Контекст для отображения (только для Selfdraw) }
    end;


    TDecoderState = (
      rdsInternal,
      rdsCached,
      rdsLoaded,
      rdsError
    );

    TSaveOptions = set of (
      soExifRotation,
      soTransformation,
      soEnableLossy,
      soKeepDate
    );

    TReviewDecoderClass = class of TReviewDecoder;

    TReviewDecoder = class(TNamedObject)
    public
      constructor Create; override;
      constructor CreateCache(const aName, aTitle :TString; aModified :Integer;
        aEnabled :Boolean; aPriority :Integer; const aActive, aIgnore :TString);
      destructor Destroy; override;

      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

      function GetState :TDecoderState; virtual; abstract;
      function CanWork(aLoad :Boolean) :boolean; virtual; abstract;
      function NeedPrecache :boolean; virtual;
      procedure ResetSettings; virtual;
      procedure SetExtensions(const aActive, aIgnore :TString);
      function SupportedFile(const aName :TString) :Boolean;
      function GetInfoStr :TString; virtual;

      { Функции декодирования }
      function pvdFileOpen(AImage :TReviewImageRec) :Boolean; virtual; abstract;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; virtual; abstract;
      function pvdPageDecode(AImage :TReviewImageRec; ABkColor :Integer; AWidth, AHeight :Integer; ACache :Boolean) :Boolean; virtual; abstract;
      procedure pvdPageFree(AImage :TReviewImageRec); virtual; abstract;
      procedure pvdFileClose(AImage :TReviewImageRec); virtual; abstract;

      { Функции отображения (для Selfdraw) }
      function pvdDisplayInit(AWnd :THandle) :Boolean; virtual;
      procedure pvdDisplayDone(AWnd :THandle); virtual;
      function pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean; virtual;
      function pvdDisplayPaint(AWnd :THandle; AImage :TReviewImageRec; const AImageRect, ADisplayRect :TRect; AColor :DWORD) :Boolean; virtual;
      procedure pvdDisplayClose(AImage :TReviewImageRec); virtual;

      { Расширенные функции, пока не вынесенные в pvd интерфейс }
//    function GetBitmapDC(AImage :TReviewImageRec; var ACX, ACY :Integer) :HDC; virtual;
      function GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; virtual;
      function Idle(AImage :TReviewImageRec; AWidth, AHeight :Integer) :Boolean; virtual;
      function Save(AImage :TReviewImageRec; const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean; virtual;

    protected
      FKind      :Integer;
      FTitle     :TString;
      FVersion   :TString;
      FComment   :TString;
      FPriority  :Integer;

      FInitState :Integer;  { 0-не инициализирован, 1-инициализирован, 2-ошибка при инициализации }
      FModified  :Integer;  { Дата модификации PVD файла - для проверки актуальности кэша }
      FEnabled   :Boolean;

      FActiveStr :TString;
      FIgnoreStr :TString;

      FActiveExt :TStringList;
      FIgnoreExt :TStringList;

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
    end;


    TReviewDllDecoder = class(TReviewDecoder)
    public
      constructor CreateEx(const aName :TString; aModified :Integer);
      destructor Destroy; override;

      function GetState :TDecoderState; override;
      function CanWork(aLoad :Boolean) :boolean; override;
      function GetInfoStr :TString; override;

    protected
      procedure InitPlugin(aKeepSettings :Boolean); virtual; abstract;
      procedure DonePlugin; virtual; abstract;

    private
      FHandle         :THandle;
      FDllName        :TString;

      { Параметры, возвращаемые плагином }
      FInitError      :Integer;
      FInitContext    :Pointer;
      FInitErrorMess  :TString;

    public
      property InitErrorMess :TString read FInitErrorMess;
    end;


    TReviewDllDecoder1 = class(TReviewDllDecoder)
    public
      constructor Create; override;

      { Функции инициализации }
      procedure pvdInit;
      procedure pvdExit;
      procedure pvdGetInfo;

      { Функции декодирования }
      function pvdFileOpen(AImage :TReviewImageRec) :Boolean; override;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; override;
      function pvdPageDecode(AImage :TReviewImageRec; ABkColor :Integer; AWidth, AHeight :Integer; ACache :Boolean) :Boolean; override;
      procedure pvdPageFree(AImage :TReviewImageRec); override;
      procedure pvdFileClose(AImage :TReviewImageRec); override;

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
      function NeedPrecache :boolean; override;
      procedure ResetSettings; override;

      { Функции инициализации }
      procedure pvdInit;
      procedure pvdExit;
      procedure pvdGetInfo;
      procedure pvdGetFormats;

      { Функции декодирования }
      function pvdFileOpen(AImage :TReviewImageRec) :Boolean; override;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; override;
      function pvdPageDecode(AImage :TReviewImageRec; ABkColor :Integer; AWidth, AHeight :Integer; ACache :Boolean) :Boolean; override;
      procedure pvdPageFree(AImage :TReviewImageRec); override;
      procedure pvdFileClose(AImage :TReviewImageRec); override;

      { Функции отображения (для Selfdraw) }
      function pvdDisplayInit(AWnd :THandle) :Boolean; override;
      procedure pvdDisplayDone(AWnd :THandle); override;
      function pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean; override;
      function pvdDisplayPaint(AWnd :THandle; AImage :TReviewImageRec; const AImageRect, ADisplayRect :TRect; AColor :DWORD) :Boolean; override;
      procedure pvdDisplayClose(AImage :TReviewImageRec); override;

      function pvdPlayControl(AImage :TReviewImageRec; aCmd :Integer; aInfo :TIntPtr) :Integer; {override;}

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
    end;


  function GetPVDVersion(const AName :TString; var AHandle :THandle) :Integer;

  procedure SaveDecodersInfo(aDecoders :TObjList);
  function RestoreDecodersCache(aDecoders :TObjList) :Boolean;
  procedure InitDecodersFrom(aDecoders :TObjList; const aPath :TString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewGDIPlus,
    MixDebug;


  const
    strPluginInitError    = 'Plugin init error (%x)';
    strUnsupportedPlugin  = 'Unsupported plugin version (%d)';
    strUnsupportedFeature = 'Feature not supported';


(*
BOOL WINAPI SetDllDirectory(
  _In_opt_  LPCTSTR lpPathName
);
*)


  function SetDllDirectory(aPath :PTChar) :BOOL; stdcall;
    external kernel32 name 'SetDllDirectory'+_X;


 {-----------------------------------------------------------------------------}
 { TReviewDecoder                                                              }
 {-----------------------------------------------------------------------------}

  constructor TReviewDecoder.Create; {override;}
  begin
    inherited Create;
    FEnabled := True;
    FActiveExt := TStringList.Create;
    FActiveExt.Sorted := True;
    FIgnoreExt := TStringList.Create;
    FActiveExt.Sorted := True;
  end;


  constructor TReviewDecoder.CreateCache(const aName, aTitle :TString; aModified :Integer;
    aEnabled :Boolean; aPriority :Integer; const aActive, aIgnore :TString);
  begin
    Create;

    FName := aName;
    FTitle := aTitle;
    FModified := aModified;
    FEnabled := aEnabled;
    FPriority := aPriority;

    SetExtensions(aActive, aIgnore);
  end;


  destructor TReviewDecoder.Destroy; {override;}
  begin
    FreeObj(FActiveExt);
    FreeObj(FIgnoreExt);
    inherited Destroy;
  end;


  function TReviewDecoder.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    if Context = 1 then
      Result := IntCompare(FPriority, TReviewDecoder(Another).FPriority)
    else
      Result := inherited CompareObj(Another, Context);
  end;


  function TReviewDecoder.NeedPrecache :boolean; {virtual;}
  begin
    Result := True;
  end;


  procedure TReviewDecoder.ResetSettings; {virtual;}
  begin
  end;


  procedure TReviewDecoder.SetExtensions(const aActive, aIgnore :TString);
  begin
    FActiveStr := aActive;
    FIgnoreStr := aIgnore;
//  FUnusualStr :=

    FActiveExt.Text := StrDeleteChars(StrReplaceChars(aActive, [',', ';'], #13), [' ']);
    FIgnoreExt.Text := StrDeleteChars(StrReplaceChars(aIgnore, [',', ';'], #13), [' ']);
  end;


  function TReviewDecoder.SupportedFile(const AName :TSTring) :Boolean;
  var
    vExt :TString;
  begin
    vExt := ExtractFileExtension(AName);
    Result := (FActiveExt.IndexOf('*') <> -1) or (FActiveExt.IndexOf(vExt) <> -1);
    if Result then
      Result := (FIgnoreExt.IndexOf('*') = -1) and (FIgnoreExt.IndexOf(vExt) = -1);
  end;


  function TReviewDecoder.GetInfoStr :TString;
  begin
    Result := StrLoCase(FActiveExt.GetTextStrEx(','));
  end;

(*
  function TReviewDecoder.GetBitmapDC(AImage :TReviewImageRec; var ACX, ACY :Integer) :HDC; {override;}
  begin
    Result := 0;
  end;
*)

  function TReviewDecoder.GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; {override;}
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

  function TReviewDecoder.pvdDisplayInit(AWnd :THandle) :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TReviewDecoder.pvdDisplayDone(AWnd :THandle); {override;}
  begin
  end;


  function TReviewDecoder.pvdDisplayShow(AWnd :THandle; AImage :TReviewImageRec) :Boolean; {override;}
  begin
    Result := True;
  end;


  function TReviewDecoder.pvdDisplayPaint(AWnd :THandle; AImage :TReviewImageRec; const AImageRect, ADisplayRect :TRect; AColor :DWORD) :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TReviewDecoder.pvdDisplayClose(AImage :TReviewImageRec); {override;}
  begin
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
    vPath :TString;
  begin
    if not aLoad then
      Result := FInitState < 2
    else begin
      if FInitState = 0 then begin
        vPath := RemoveBackSlash(ExtractFilePath(FDLLName));
        SetDllDirectory(PTChar(vPath));
        try
          InitPlugin(True);
        finally
          SetDllDirectory(nil);
        end;
      end;
      Result := FInitState = 1;
    end;
  end;



  function TReviewDllDecoder.GetInfoStr :TString;
  begin
    if FInitState < 2 then
      Result := inherited GetInfoStr
    else
      Result := '-- ' + FInitErrorMess;
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
        FInitErrorMess := E.Message;
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


  function TReviewDllDecoder1.pvdFileOpen(AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoImage;
    vFileName :TAnsiStr;
  begin
    vFileName := WideToUTF8(AImage.FName);

    FillZero(vInfo, SizeOf(vInfo));
    Result := FpvdFileOpen(PAnsiChar(vFileName), AImage.FSize, AImage.FCacheBuf, AImage.FCacheSize, @vInfo, AImage.FContext);

    if Result then begin
      AImage.FFormat := vInfo.pFormatName;
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


  function TReviewDllDecoder1.pvdPageDecode(AImage :TReviewImageRec; ABkColor :Integer; AWidth, AHeight :Integer; ACache :Boolean) :Boolean;
  var
    vInfo :TPVDInfoDecode;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    Result := FpvdPageDecode(AImage.FContext, AImage.FPage, @vInfo, nil, nil);

    if Result then begin
      AImage.FBmpWidth    := AImage.FWidth;
      AImage.FBmpHeight   := AImage.FHeight;
      AImage.FBmpBPP      := vInfo.nBPP;
      AImage.FBmpBits     := vInfo.pImage;
      AImage.FBmpPalette  := vInfo.pPalette;
      AImage.FBmpColors   := vInfo.nColorsUsed;
      AImage.FBmpRowBytes := vInfo.lImagePitch;
      AImage.FColorModel  := PVD_CM_BGR;

      AImage.FDecodeInfo  := MemAlloc(SizeOf(vInfo));
      Move(vInfo, AImage.FDecodeInfo^, SizeOf(vInfo));
    end;
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


  function TReviewDllDecoder2.NeedPrecache :boolean; {override;}
  begin
    Result := FPlugFlags and PVD_IP_NEEDFILE = 0;
//  Result := True;
  end;


  procedure TReviewDllDecoder2.ResetSettings; {override;}
  begin
    pvdGetFormats;
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

      pvdInit;
      pvdGetInfo;

      if not aKeepSettings then
        pvdGetFormats;

      FInitState := 1;

    except
      on E :Exception do begin
        FInitErrorMess := E.Message;
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


 {-----------------------------------------------------------------------------}

  function TReviewDllDecoder2.pvdFileOpen(AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoImage2;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.pImageContext := AImage.FContext;

    Result := FpvdFileOpen(FInitContext, PTChar(AImage.FName), AImage.FSize, AImage.FCacheBuf, AImage.FCacheSize, @vInfo);

    if Result then begin
      AImage.FContext := vInfo.pImageContext;
      AImage.FFormat := vInfo.pFormatName;
      AImage.FAnimated := vInfo.Flags and PVD_IIF_ANIMATED <> 0;
      AImage.FMovie := vInfo.Flags and PVD_IIF_MOVIE <> 0;
      if AImage.FMovie then
        AImage.FLength := vInfo.nPages
      else
        AImage.FPages := vInfo.nPages;
    end;
  end;


  function TReviewDllDecoder2.pvdGetPageInfo(AImage :TReviewImageRec) :Boolean;
  var
    vInfo :TPVDInfoPage2;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.iPage := AImage.FPage;

    Result := FpvdPageInfo(FInitContext, AImage.FContext, @vInfo);

    if Result then begin
      AImage.FWidth  := vInfo.lWidth;
      AImage.FHeight := vInfo.lHeight;
      AImage.FBPP    := vInfo.nBPP;
      AImage.FDelay  := vInfo.lFrameTime;
    end;
  end;


  function TReviewDllDecoder2.pvdPageDecode(AImage :TReviewImageRec; ABkColor :Integer; AWidth, AHeight :Integer; ACache :Boolean) :Boolean;
  var
    vInfo :TPVDInfoDecode2;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.iPage := AImage.FPage;
    vInfo.Flags := 0; //PVD_IDF_ASDISPLAY;
    vInfo.lWidth := 0; //!!!
    vInfo.lHeight := 0; //!!!
    vInfo.nBackgroundColor := ABkColor;

    Result := FpvdPageDecode(FInitContext, AImage.FContext, @vInfo, nil, nil);

    if Result then begin
      AImage.FSelfdraw    := vInfo.Flags and PVD_IDF_PRIVATE_DISPLAY <> 0;
      AImage.FTransparent := vInfo.Flags and ({PVD_IDF_TRANSPARENT + PVD_IDF_TRANSPARENT_INDEX +} PVD_IDF_ALPHA) <> 0;

      AImage.FBmpWidth    := vInfo.lWidth;
      AImage.FBmpHeight   := vInfo.lHeight;
      AImage.FBmpBPP      := vInfo.nBPP;
      AImage.FBmpBits     := vInfo.pImage;
      AImage.FBmpPalette  := vInfo.pPalette;
      AImage.FBmpColors   := vInfo.nColorsUsed;
      AImage.FBmpRowBytes := vInfo.lImagePitch;
      AImage.FColorModel  := vInfo.ColorModel;
      AImage.FTranspColor := vInfo.nTransparentColor;
      if vInfo.Flags and (PVD_IDF_TRANSPARENT + PVD_IDF_TRANSPARENT_INDEX) = 0 then
        AImage.FTranspColor := DWORD(-1);

      AImage.FDecodeInfo  := MemAlloc(SizeOf(vInfo));
      Move(vInfo, AImage.FDecodeInfo^, SizeOf(vInfo));
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

(*
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
*)


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


(*
struct pvdInfoDisplayCreate2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	pvdInfoDecode2* pImage;      // [IN]
	DWORD BackColor;             // [IN]  RGB background
	void* pDisplayContext;       // [OUT]
	DWORD nErrNumber;            // [OUT]
	const wchar_t* pFileName;    // [IN]  Information only. Valid only in pvdDisplayCreate2
	UINT32 iPage;                // [IN]  Information only
};
*)
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


(*
struct pvdInfoDisplayPaint2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	DWORD Operation;  // PVD_IDP_*
	HWND hWnd;                   // [IN]  Где рисовать
	HWND hParentWnd;             // [IN]
	union {
	RGBQUAD BackColor;  //
	DWORD  nBackColor;  //
	};
	RECT ImageRect;
	RECT DisplayRect;

	LPVOID pDrawContext; // Это поле может использоваться субплагином для хранения "HDC". Освобождать должен субплагин по команде PVD_IDP_COMMIT

	//RECT ParentRect;
	////DWORD BackColor;             // [IN]  RGB background
	//BOOL bFreePosition;
	//BOOL bCorrectMousePos;
	//POINT ViewCenter;
	//POINT DragBase;
	//UINT32 Zoom;
	//RECT rcGlobal;               // [IN]  в каком месте окна нужно показать изображение (остальное заливается фоном BackColor)
	//RECT rcCrop;                 // [IN]  прямоугольник отсечения (клиентская часть окна)
	DWORD nErrNumber;            // [OUT]

	DWORD nZoom; // [IN] передается только для информации. 0x10000 == 100%
	DWORD nFlags; // [IN] PVD_IDPF_*

	DWORD *pChessMate;
	DWORD uChessMateWidth;
	DWORD uChessMateHeight;
};
*)
  function TReviewDllDecoder2.pvdDisplayPaint(AWnd :THandle; AImage :TReviewImageRec; const AImageRect, ADisplayRect :TRect; AColor :DWORD) :Boolean;
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
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I :Integer;
  begin
//  Trace('SaveDecodersInfo...');

    vConfig := TFarConfig.CreateEx(True, cPluginName);
    try
      if vConfig.OpenKey(cDecodersRegFolder) then begin
        vConfig.WriteInt(cDecodersCount, aDecoders.Count);
        vConfig.OpenKey( '' );

        for I := 0 to aDecoders.Count - 1 do
          LocSave(I, aDecoders[I]);
      end;
    finally
      FreeObj(vConfig);
    end;
  end;


  function RestoreDecodersCache(aDecoders :TObjList) :Boolean;
  var
    vConfig :TFarConfig;

    function LocLoad(AIndex :Integer) :Boolean;
    var
      vName, vTitle, vActive, vIgnore :TString;
      vKind, vModified, vPriority, vIndex :Integer;
      vEnabled :Boolean;
      vClass :TReviewDecoderClass;
    begin
      Result := False;
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

          if (vKind = 0) and not StrEqual(vName, cDefGDIDecoderName) then
            Exit;
          if aDecoders.FindKey(Pointer(vName), 0, [], vIndex) then
            Exit;

          case vKind of
            0: vClass := TReviewGDIDecoder;
            1: vClass := TReviewDllDecoder1;
            2: vClass := TReviewDllDecoder2;
          else
            Exit;
          end;

          aDecoders.Add( vClass.CreateCache(vName, vTitle, vModified, vEnabled, vPriority, vActive, vIgnore) );

          Result := True;

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

        for I := 0 to vCount - 1 do
          LocLoad(I);

        Result := aDecoders.Count > 0;
      end;
    finally
      FreeObj(vConfig);
    end;
  end;


  procedure InitDecodersFrom(aDecoders :TObjList; const aPath :TString);
  var
    vCache, vNeedStore :Boolean;

    function LocEnumPlugin(const APath :TString; const ARec :TWin32FindData) :Boolean;
    var
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

      if vCache and aDecoders.FindKey(Pointer(vName), 0, [], vIndex) then begin
        vDecoder := aDecoders[vIndex];
        if (vDecoder is TReviewDllDecoder) and (vDecoder.Modified = vFileDate) then begin
          { Информация в кэше соответствует файлу, загрузим декодер позже - по необходимости }
          TReviewDllDecoder(vDecoder).FDllName := vFileName;
          Exit;
        end else
          { Что-то изменилось - надо обновить информацию }
          aDecoders.FreeAt(vIndex);
      end else
        vIndex := aDecoders.Count;

     {$ifdef bTrace}
      TraceF('PVD: %s', [vFileName]);
     {$endif bTrace}
      vHandle := 0; vDecoder := nil;
      SetDllDirectory(PTChar(APath));
      vVer := GetPVDVersion(vFileName, vHandle);
      try
        case vVer of
        0,1: vDecoder := TReviewDllDecoder1.CreateEx(vFileName, vFileDate);
          2: vDecoder := TReviewDllDecoder2.CreateEx(vFileName, vFileDate);
        end;

        if vDecoder <> nil then begin
          aDecoders.Insert( vIndex, vDecoder );
          vNeedStore := True;
        end;

      finally
        if vHandle <> 0 then
          FreeLibrary(vHandle);
        SetDllDirectory(nil);
      end;
    end;

  var
    I, vIndex :Integer;
    vDecoder :TReviewDecoder;
    vName :TString;
  begin
    vCache := RestoreDecodersCache(aDecoders);
    vNeedStore := not vCache;

    vName := cDefGDIDecoderName;
    if not aDecoders.FindKey(Pointer(vName), 0, [], vIndex) then
      aDecoders.Add(TReviewGDIDecoder.Create);

    if WinFolderExists(aPath) then begin
      WinEnumFilesEx(aPath, cPluginsMask, faEnumFiles, [efoRecursive],  LocalAddr(@LocEnumPlugin));
      if not vCache then
        aDecoders.SortList(False, 1);
    end;

    { Удалим декодеры, для которых не найдено файлов}
    for I := aDecoders.Count - 1 downto 0 do begin
      vDecoder := aDecoders[I];
      if (vDecoder is TReviewDllDecoder) and (TReviewDllDecoder(vDecoder).FDllName = '') then
        aDecoders.FreeAt(I);
    end;

    if vNeedStore then
      SaveDecodersInfo(aDecoders);
  end;


(*
  procedure InitDecodersFrom(aDecoders :TObjList; const aPath :TString);

    function LocEnumPlugin(const APath :TString; const ARec :TWin32FindData) :Boolean;
    var
      vFileName :TString;
      vFileDate :Integer;
      vHandle :THandle;
      vDecoder :TReviewDecoder;
      vVer :Integer;
    begin
      vFileName := AddFileName(APath, ARec.cFileName);
      vFileDate := FileTimeToDosFileDate(ARec.ftLastWriteTime);
     {$ifdef bTrace}
      TraceF('PVD: %s', [vFileName]);
     {$endif bTrace}

      vHandle := 0; vDecoder := nil;
      vVer := GetPVDVersion(vFileName, vHandle);
      try
        case vVer of
        0,1: vDecoder := TReviewDllDecoder1.CreateEx(vFileName, vFileDate);
          2: vDecoder := TReviewDllDecoder2.CreateEx(vFileName, vFileDate);
        end;

        if vDecoder <> nil then
          aDecoders.AddSorted( vDecoder, 0, dupAccept );

      finally
        if vHandle <> 0 then
          FreeLibrary(vHandle);
      end;
      Result := True;
    end;


  begin
    aDecoders.Add(TReviewGDIDecoder.Create);

    if not WinFolderExists(aPath) then
      Exit;

    WinEnumFilesEx(aPath, cPluginsMask, faEnumFiles, [efoRecursive],  LocalAddr(@LocEnumPlugin));
    aDecoders.SortList(False, 1);
  end;
*)

end.


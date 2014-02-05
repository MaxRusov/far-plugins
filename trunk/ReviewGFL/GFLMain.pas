{$I Defines.inc}

unit GFLMain;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* GFL                                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    LibGFL,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,
    PVApi;


  var
    opt_PluginPath :TString = 'GFL';
    opt_EpsDpi     :Integer = 144 {72};


  function pvdInit2(pInit :PpvdInitPlugin2) :integer; stdcall;
  procedure pvdExit2(pContext :Pointer); stdcall;
  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  procedure pvdReloadConfig2(pContext :Pointer); stdcall;

  procedure pvdGetFormats2(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  function pvdFileOpen2(pContext :Pointer; pFileName :PWideChar; lFileSize :TInt64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage2) :BOOL; stdcall;
  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  procedure pvdPageFree2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2); stdcall;
  procedure pvdFileClose2(pContext :Pointer; pImageContext :Pointer); stdcall;

  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  type
    EGflError = class(Exception);

  procedure GFLError(aCode :Integer);
  var
    vErr :EGflError;
  begin
    vErr := EGflError.CreateFmt('GFL Error (code: %x)', [aCode]);
//  vErr.ErrorCode := DWORD(ErrorCode);
    raise vErr;
  end;


(*
{pvdColorModel}
const
  // Сейчас допустимы только "PVD_CM_BGR" и "PVD_CM_BGRA"
  PVD_CM_UNKNOWN =  0;  // -- Такое изображение скорее всего не будет показано плагином
  PVD_CM_GRAY    =  1;  // "Gray scale"  -- UNSUPPORTED !!!
  PVD_CM_AG      =  2;  // "Alpha_Gray"  -- UNSUPPORTED !!!
  PVD_CM_RGB     =  3;  // "RGB"         -- UNSUPPORTED !!!
  PVD_CM_BGR     =  4;  // "BGR"
  PVD_CM_YCBCR   =  5;  // "YCbCr"       -- UNSUPPORTED !!!
  PVD_CM_CMYK    =  6;  // "CMYK"
  PVD_CM_YCCK    =  7;  // "YCCK"        -- UNSUPPORTED !!!
  PVD_CM_YUV     =  8;  // "YUV"         -- UNSUPPORTED !!!
  PVD_CM_BGRA    =  9;  // "BGRA"
  PVD_CM_RGBA    = 10;  // "RGBA"        -- UNSUPPORTED !!!
  PVD_CM_ABRG    = 11;  // "ABRG"        -- UNSUPPORTED !!!
  PVD_CM_PRIVATE = 12;  // Только если Дисплей==Декодер и биты не возвращаются

const
  GFL_BINARY = $0001;
  GFL_GREY   = $0002;
  GFL_COLORS = $0004;
  GFL_RGB    = $0010;
  GFL_RGBA   = $0020;
  GFL_BGR    = $0040;
  GFL_ABGR   = $0080;
  GFL_BGRA   = $0100;
  GFL_ARGB   = $0200;
  GFL_CMYK   = $0400;
*)

  function GflType2PvdColorModel(aType :Integer) :Byte;
  begin
    Result := PVD_CM_UNKNOWN;
    case aType of
      GFL_BINARY : Result := PVD_CM_BGR;
      GFL_GREY   : Result := PVD_CM_BGR;
      GFL_COLORS : Result := PVD_CM_BGR;
      GFL_RGB    : {Result := PVD_CM_RGB};
      GFL_RGBA   : {Result := PVD_CM_RGBA};
      GFL_BGR    : Result := PVD_CM_BGR;
      GFL_ABGR   : {Result := PVD_CM_ABRG};
      GFL_BGRA   : Result := PVD_CM_BGRA;
      GFL_ARGB   : {Result := PVD_CM_ABRG};
      GFL_CMYK   : Result := PVD_CM_CMYK;
    end;
  end;


  function GetExifInfo(aInfo :PGFL_EXIF_DATA; aTag :DWORD) :TSTring;
  var
    i :Integer;
  begin
    Result := '';
    for i := 0 to aInfo.NumberOfItems - 1 do
      with aInfo.ItemsList[i] do
        if Tag = aTag then begin
          Result := Value;
          Exit;
        end;
  end;

 {$ifdef bTrace}
  procedure TraceExif(aInfo :PGFL_EXIF_DATA);
  var
    i :Integer;
  begin
    for i := 0 to aInfo.NumberOfItems - 1 do
      with aInfo.ItemsList[i] do
        TraceF('%d, %d, %s, %s', [Flag, Tag, Name, Value]);
  end;

  procedure TraceExif2(aInfo :PGFL_EXIF_DATAEX);
//var
//  i :Integer;
  begin
//  for i := 0 to aInfo.NumberOfItems - 1 do
//    with aInfo.ItemsList[i] do
//      TraceF('%d, %d, %s, %s', [Flag, Tag, Name, Value]);
  end;
 {$endif bTrace}

  
 {-----------------------------------------------------------------------------}

  type
    TManager = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure CollectInfo;

    private
      FInited :Boolean;
      FPluginsPath :TString;
      FExts :TString;
    end;


  constructor TManager.Create; {override;}
  begin
    inherited Create;

    gflLoadLib;

    if opt_PluginPath <> '' then begin
      FPluginsPath := AddBackSlash(AddFileName(ExtractFilePath(GetModuleFileNameEx), opt_PluginPath));
//    gflSetPluginsPathname(PAnsiChar(FPluginsPath));
      gflSetPluginsPathnameW(PTChar(FPluginsPath));
    end;

    gflLibraryInit;
    gflEnableLZW(GFL_TRUE);
    FInited := True;
  end;


  destructor TManager.Destroy; {override;}
  begin
    if FInited then
      gflLibraryExit;
    inherited Destroy;
  end;


  procedure TManager.CollectInfo;
  var
    i, j, n :Integer;
    vInfo :TGFL_FORMAT_INFORMATION;
    vList :TStringList;
  begin
    FExts := '';

    vList := TStringList.Create;
    try
      vList.Sorted := True;
      vList.Duplicates := dupIgnore;

      n := gflGetNumberOfFormat;

      FillZero(vInfo, Sizeof(vInfo));
      for i := 0 to n - 1 do begin
        if gflGetFormatInformationByIndex(i, vInfo) <> 0 then
          Exit;

//      if gflFormatIsReadableByIndex(i) <> 0 then begin
        if vInfo.Status and GFL_READ <> 0 then begin
          for j := 0 to vInfo.NumberOfExtension - 1 do
            vList.Add(  vInfo.Extension[j] );
        end;
      end;

      FExts := vList.GetTextStrEx(',');

    finally
      FreeObj(vList);
    end;
  end;


 {-----------------------------------------------------------------------------}


  type
    TView = class(TComBasis)
    public
      destructor Destroy; override;
      class function CreateByFile(AManager :TManager; const AName :TString) :TView;
      function LoadFile(const AName :TString) :Boolean;
      procedure SetPage(AIndex :Integer);
      procedure FreePage;
      procedure FreeExif;

      function TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

    private
      FFileName   :TString;
      FFmtIndex   :Integer;
      FFmtName    :TString;
      FCompress   :TString;
      FDescr      :TString;
      FFrames     :Cardinal;
      FCurFrame   :Integer;
      FSize       :TSize;
      FPixBPP     :Integer;      { Исходная глубина цвета (BPP) }
      FDelay      :Integer;      { Задержка страницы, для анимированных изображений }
      FOrient0    :Integer;      { Ориентация страницы }

      FBmp        :PGFL_BITMAP;
      FPalette    :Pointer;
      FBmpBPP     :Integer;      { Декодированная глубина цвета (BPP) }
      FBmpCM      :byte;         { PPVDColorModel }
      FAlpha      :Boolean;      { Наличие альфа-канала на странице }

      FExif       :PGFL_EXIF_DATA;
//    FExif2      :PGFL_EXIF_DATAEX;
//    FIptc       :PGFL_IPTC_DATA;

      FStrTag   :TString;
//    FInt64Tag :Int64;

      procedure MakePalette(aColors :Integer);
    end;



  destructor TView.Destroy; {override;}
  begin
    FreePage;
    FreeExif;
    inherited Destroy;
  end;


  class function TView.CreateByFile(AManager :TManager; const AName :TString) :TView;
  begin
    Result := TView.Create;
    if Result.LoadFile(AName) then
      {}
    else
      FreeObj(Result);
  end;


  function TView.LoadFile(const AName :TString) :Boolean;
  var
    vInfo :TGFL_FILE_INFORMATION;
    vRes :GFL_ERROR;
  begin
    Result := False;

   {$ifdef bTrace}
    TraceF('GFL Check: "%s"...', [AName]);
   {$endif bTrace}

    FFileName := AName;
    FillZero(vInfo, SizeOf(vInfo));
    vRes := gflGetFileInformationW(PTChar(AName), -1, vInfo);

    if vRes <> gfl_no_error then begin
     {$ifdef bTrace}
      TraceF('  Error, Code=%x', [vRes]);
     {$endif bTrace}
      Exit;
    end;

    FFmtIndex := vInfo.FormatIndex;
    FFmtName := StrUpCase(vInfo.FormatName);
    if vInfo.Compression <> GFL_NO_COMPRESSION then
      FCompress := vInfo.CompressionDescription;
    FDescr := vInfo.Description;
    FFrames := vInfo.NumberOfImages;
    FPixBPP := vInfo.BitsPerComponent * vInfo.ComponentsPerPixel;

    gflFreeFileInformation(vInfo);

   {$ifdef bTrace}
    TraceF('  OK, Format=%s, Frames=%d', [FFmtName, FFrames]);
   {$endif bTrace}

    FCurFrame := -1;

    if FFmtName = 'GIF' then
      { Иначе не устанавливается число страниц. Ошибка GFL? }
      SetPage(0);

    Result := True;
  end;


  procedure TView.SetPage(AIndex :Integer);
  var
    vParam :TGFL_LOAD_PARAMS;
    vInfo :TGFL_FILE_INFORMATION;
    vRes :GFL_ERROR;
    vStr :TString;
  begin
    if FCurFrame = AIndex then
      Exit;

    FreePage;
    FreeExif;

   {$ifdef bTrace}
    TraceBegF('GFL Load: "%s", Sizeof(FBmp)=%d, Sizeof(vParam)=%d, Sizeof(vInfo)=%d...', [FFileName, SizeOf(FBmp), SizeOf(vParam), SizeOf(vInfo)]);
   {$endif bTrace}

    FillZero(vParam, SizeOf(vParam));
    gflGetDefaultLoadParams(vParam);
//  vParam.FormatIndex := FFmtIndex;
    vParam.ImageWanted := AIndex;
    vParam.Flags := GFL_LOAD_METADATA; //GFL_LOAD_COMMENT;
//  vParam.Flags := GFL_LOAD_ORIGINAL_COLORMODEL;
//  vParam.Flags := GFL_LOAD_FORCE_COLOR_MODEL or GFL_LOAD_BINARY_AS_GREY;
    vParam.ColorModel := GFL_BGRA;
//  vParam.ColorModel := vParam.ColorModel;
    vParam.EpsDpi := opt_EpsDpi;

    FillZero(vInfo, SizeOf(vInfo));
    vRes := gflLoadBitmapW(PTChar(FFileName), FBmp, vParam, vInfo);
    if vRes <> gfl_no_error then
      GFLError(vRes);

   {$ifdef bTrace}
    TraceEnd('  done');
   {$endif bTrace}

    if AIndex = 0 then
      FFrames := vInfo.NumberOfImages;
    FCurFrame := AIndex;

    FSize.cx := vInfo.Width;
    FSize.cy := vInfo.Height;
    FPixBPP := vInfo.BitsPerComponent * vInfo.ComponentsPerPixel;

    if vInfo.Compression <> GFL_NO_COMPRESSION then
      FCompress := vInfo.CompressionDescription;
    FDescr := vInfo.Description;

    FBmpCM := GflType2PvdColorModel(FBmp.BType);
    FAlpha := FBmpCM in [PVD_CM_BGRA];
    if FBmp.BType in [GFL_COLORS, GFL_GREY{???}] then
      FBmpBPP := 8
    else
      FBmpBPP := FBmp.BitsPerComponent * FBmp.ComponentsPerPixel;

    if FBmp.ColorUsed > 0 then
      MakePalette( RangeLimit(FBmp.ColorUsed, 1, 256) );

    FExif := gflBitmapGetEXIF(FBmp, 0);
//  FExif2 := gflBitmapGetEXIF2(FBmp);
//  FIptc := gflBitmapGetIPTC(FBmp, 0);

    FDelay  := 0;
    if FExif <> nil then begin
     {$ifdef bTrace}
      TraceExif(FExif);
     {$endif bTrace}  

      vStr := GetExifInfo(FExif, GFL_EXIF_ORIENTATION);
      if vStr <> '' then
        FOrient0 := Str2IntDef( ExtractWord(2, vStr, ['(', ')']), 0);

//    FDelay := ...   !!!
    end;
  end;


  procedure TView.MakePalette(aColors :Integer);
  var
    i :Integer;
    vRGB :PRGBQuad;
  begin
//  TraceF('MakePalette: %d, SizeOf(TRGBQuad)=%d', [aColors, SizeOf(TRGBQuad)]);

    FPalette := MemAllocZero(aColors * SizeOf(TRGBQuad) );
    if FBmp.ColorMap = nil then begin
      { Нет палитры - используем GrayScale }
      vRGB := FPalette;
      for i := 0 to aColors - 1 do begin
        vRGB.rgbRed := MulDiv(i, 255, aColors - 1);
        vRGB.rgbGreen := vRGB.rgbRed;
        vRGB.rgbBlue := vRGB.rgbRed;
        Inc(TIntPtr(vRGB), Sizeof(TRGBQuad));
      end;
    end else
    begin
      vRGB := FPalette;
      for i := 0 to aColors - 1 do begin
        vRGB.rgbRed := FBmp.ColorMap.Red[i];
        vRGB.rgbGreen := FBmp.ColorMap.Green[i];
        vRGB.rgbBlue := FBmp.ColorMap.Blue[i];
        Inc(TIntPtr(vRGB), Sizeof(TRGBQuad));
      end;
    end;
  end;


  procedure TView.FreePage;
  begin
    MemFree(FPalette);
    if FBmp <> nil then begin
      gflFreeBitmap(FBmp);
      FBmp := nil;
    end;
  end;


  procedure TView.FreeExif;
  begin
    if FExif <> nil then begin
      gflFreeEXIF(FExif);
      FExif := nil;
    end;
//  if FExif2 <> nil then begin
//    gflFreeEXIF2(FExif2);
//    FExif := nil;
//  end;
//  if FIptc <> nil then begin
//    gflFreeIPTC(FIptc);
//    FIptc := nil;
//  end;
  end;



  function TView.TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;
(*

    procedure LocInt64Tag(const aName :TString);
    begin
      Result := MetaQueryInt64(FMetadata, aName, FInt64Tag);
      if Result then begin
        aValue := @FInt64Tag;
        aType := PVD_TagType_Int64;
      end;
    end;
*)
    procedure LocStrTag(aTag :DWORD);
    begin
      FStrTag := GetExifInfo(FExif, aTag);
      if FStrTag <> '' then begin
        aValue := PTChar(FStrTag);
        aType := PVD_TagType_Str;
        Result := True;
      end;
    end;

    procedure LocIntTag(aTag :DWORD);
    var
      vStr :TString;
      vInt :Integer;
    begin
      Result := False;
      vStr := GetExifInfo(FExif, aTag);
      if vStr <> '' then begin
        Result :=  TryStrToInt(vStr, vInt);
        aValue := Pointer(TIntPtr(vInt));
        aType := PVD_TagType_Int;
      end;
    end;

  begin
    Result := False;
    if FExif = nil then
      Exit;

    case aCode of
      PVD_Tag_Description  : LocStrTag(270);
      PVD_Tag_Time         : LocStrTag(GFL_EXIF_DATETIME_ORIGINAL);
      PVD_Tag_EquipMake    : LocStrTag(GFL_EXIF_MAKER);
      PVD_Tag_EquipModel   : LocStrTag(GFL_EXIF_MODEL);
      PVD_Tag_Software     : LocStrTag(305);
      PVD_Tag_Author       : LocStrTag(315);
      PVD_Tag_Copyright    : LocStrTag(33432);

//    PVD_Tag_ExposureTime : LocInt64Tag(vIFD + 'exif/{ushort=33434}');
//    PVD_Tag_FNumber      : LocInt64Tag(vIFD + 'exif/{ushort=33437}');
//    PVD_Tag_FocalLength  : LocInt64Tag(vIFD + 'exif/{ushort=37386}');
//    PVD_Tag_ISO          : LocIntTag(vIFD + 'exif/{ushort=34855}');
//    PVD_Tag_Flash        : LocIntTag(vIFD + 'exif/{ushort=37385}');

      PVD_Tag_XResolution  : LocIntTag(282);
      PVD_Tag_YResolution  : LocIntTag(283);
    end;
  end;

 {-----------------------------------------------------------------------------}
 { Экспортируемые функции                                                      }
 {-----------------------------------------------------------------------------}

  threadvar
    FLastError :TString;


  function pvdInit2(pInit :PPVDInitPlugin2) :integer; stdcall;
  var
    vManager :TManager;
  begin
    FLastError := '';
    try
      vManager := TManager.Create;
      pInit.pContext := vManager;
      Result := PVD_UNICODE_INTERFACE_VERSION;
    except
      on E :Exception do begin
        FLastError := E.Message;
        Result := 0;
      end;
    end;
  end;

  procedure pvdExit2(pContext :Pointer); stdcall;
  begin
    if pContext <> nil then
      FreeObj(pContext);
  end;


  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  begin
    pPluginInfo.pName := 'GFL';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2014, Maxim Rusov';
    pPluginInfo.Flags := PVD_IP_DECODE or PVD_IP_NEEDFILE;
    pPluginInfo.Priority := $0F02;
  end;


  procedure pvdReloadConfig2(pContext :Pointer); stdcall;
  begin
  end;


  procedure pvdGetFormats2(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  begin
    with TManager(pContext) do begin
      CollectInfo;
      pFormats.pSupported := PTChar(FExts);
      pFormats.pIgnored := '';
    end;
  end;


  function pvdFileOpen2(pContext :Pointer; pFileName :PWideChar; lFileSize :TInt64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage2) :BOOL; stdcall;
  var
    vView :TView;
  begin
    Result := False; FLastError := '';
    try
      vView := TView.CreateByFile(pContext, pFileName);

      if vView <> nil then begin
        pImageInfo.pFormatName := PTChar(vView.FFmtName);
        pImageInfo.pCompression := PTChar(vView.FCompress);
        pImageInfo.pComments := PTChar(vView.FDescr);
        pImageInfo.nPages := vView.FFrames;
        pImageInfo.Flags := 0;
        if (vView.FFrames > 1) and (vView.FDelay <> 0) then
          pImageInfo.Flags := pImageInfo.Flags or PVD_IIF_ANIMATED;

        pImageInfo.pImageContext := vView;
        vView._AddRef;

        Result := True;
      end;

    except
      on E :Exception do
        FLastError := E.Message;
    end;
  end;


  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  var
    vView :TView;
  begin
    Result := False; FLastError := '';
    try
      vView := pImageContext;

      vView.SetPage(pPageInfo.iPage);

      pPageInfo.pFormatName := PTChar(vView.FFmtName);
      pPageInfo.pCompression := PTChar(vView.FCompress);
//    pPageInfo.pComments := PTChar(vView.FDescr);

      pPageInfo.lWidth := vView.FSize.cx;
      pPageInfo.lHeight := vView.FSize.cy;
      pPageInfo.nBPP := vView.FPixBPP;
      pPageInfo.lFrameTime := vView.FDelay;

      Result := True;

    except
      on E :Exception do
        FLastError := E.Message;
    end;
  end;


  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  var
    vView :TView;
  begin
    Result := False; FLastError := '';
    try
      vView := pImageContext;

      vView.SetPage(pDecodeInfo.iPage);

      pDecodeInfo.lWidth := vView.FBmp.Width;
      pDecodeInfo.lHeight := vView.FBmp.Height;
      pDecodeInfo.nBPP := vView.FBmpBPP;
      pDecodeInfo.ColorModel := vView.FBmpCM;
      pDecodeInfo.Flags := IntIf(vView.FAlpha, PVD_IDF_ALPHA, 0);

      pDecodeInfo.lImagePitch := vView.FBmp.BytesPerLine;
      pDecodeInfo.pImage := vView.FBmp.Data;
      pDecodeInfo.pPalette := vView.FPalette;
      pDecodeInfo.nColorsUsed := 0 {FBmp.ColorUsed} ;

      pDecodeInfo.Orientation := vView.FOrient0;

      Result := True;

    except
      on E :Exception do
        FLastError := E.Message;
    end;
  end;


  procedure pvdPageFree2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2); stdcall;
  begin
    with TView(pImageContext) do
      FreePage;
  end;


  procedure pvdFileClose2(pContext :Pointer; pImageContext :Pointer); stdcall;
  begin
    if pImageContext <> nil then
      TView(pImageContext)._Release;
  end;



  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;
  var
    vView :TView;
  begin
    Result := False;
    try
      vView := pImageContext;

      if aCmd = PVD_TagCmd_Get then begin
        aType := 0; aValue := nil;
        Result := vView.TagInfo(aCode, aType, aValue);
      end;

    except
      on E :Exception do
        FLastError := E.Message;
    end;
  end;



end.


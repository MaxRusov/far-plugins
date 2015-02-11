{$I Defines.inc}

{-$Define bMyGetMem}
{$Define bExifV2}

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

  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  type
    EGflError = class(Exception);

  procedure GFLError(aCode :Integer);
  var
    vStr :TString;
    vErr :EGflError;
  begin
    vStr := gflGetErrorString(aCode);
    if vStr = '' then
      vStr := 'GFL Error';
    vErr := EGflError.CreateFmt('%s (code: %x)', [vStr, aCode]);
//  vErr.ErrorCode := DWORD(ErrorCode);
    raise vErr;
  end;


  function Invert32(AInt :TInt32) :TInt32;
  begin
    with LongRec(AInt) do
      Result := MakeLong( Swap(Hi), Swap(Lo) );
  end;

  function InvertU32(AInt :TUns32) :TUns32;
  begin
    with LongRec(AInt) do
      Result := TUns32( MakeLong( Swap(Hi), Swap(Lo) ));
  end;

  function Invert64(AInt :Int64) :Int64;
  begin
    with Int64Rec(AInt) do
      Result := MakeInt64( InvertU32(Lo), InvertU32(Hi) );
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


 {$ifdef bExifV2}
  function FindExifInfo(aInfo :PGFL_EXIF_DATAEX; aLFD :Integer; aTag :DWORD) :PGFL_EXIF_ENTRYEX;
  begin
    Result := aInfo.Root;
    while (Result <> nil) and ((Result.lfd <> aLFD) or (Result.Tag <> aTag)) do
      Result := Result.Next;
  end;

  function GetExifInfoStr(aInfo :PGFL_EXIF_DATAEX; aLFD :Integer; aTag :DWORD; var ARes :TString) :Boolean;
  var
    vEntry :PGFL_EXIF_ENTRYEX;
    vStr :PAnsiChar;
  begin
    Result := False;
    vEntry := FindExifInfo(aInfo, aLFD, aTag);
    if (vEntry <> nil) and (vEntry.Format = GFL_EXIF_STRING) and (vEntry.Data <> nil) then begin
      vStr := vEntry.Data;
      if DetectUTF8(vStr) then
        ARes := UTF8ToWide(vStr)
      else
        ARes := vStr;
      Result := True;
    end;
  end;

  function GetExifInfoInt(aInfo :PGFL_EXIF_DATAEX; aLFD :Integer; aTag :DWORD; var ARes :Integer) :Boolean;
  var
    vEntry :PGFL_EXIF_ENTRYEX;
  begin
    Result := False;
    vEntry := FindExifInfo(aInfo, aLFD, aTag);
    if (vEntry <> nil) and (vEntry.Format in [GFL_EXIF_USHORT, GFL_EXIF_ULONG, GFL_EXIF_SSHORT, GFL_EXIF_SLONG]) then begin
      ARes := TInt32(vEntry.Value);
      Result := True;
    end;
  end;

  function GetExifInfoInt64(aInfo :PGFL_EXIF_DATAEX; aLFD :Integer; aTag :DWORD; var ARes :Int64) :Boolean;
  var
    vEntry :PGFL_EXIF_ENTRYEX;
  begin
    Result := False;
    vEntry := FindExifInfo(aInfo, aLFD, aTag);
    if (vEntry <> nil) and (vEntry.Format in [GFL_EXIF_URATIONAL, GFL_EXIF_SRATIONAL]) then begin
      ARes := TInt64(vEntry.Data^);
      if aInfo.UseMSBF = 1 then  {MSBF - Most Significant Bit First }
        ARes := Invert64(ARes);
      Result := True;
    end;
  end;

 {$else}

  function GetExifInfo(aInfo :PGFL_EXIF_DATA; aTag :DWORD; AsStr :Boolean = False) :TString;
  var
    i :Integer;
  begin
    Result := '';
    for i := 0 to aInfo.NumberOfItems - 1 do
      with aInfo.ItemsList[i] do
        if Tag = aTag then begin
          if AsStr and DetectUTF8(Value) then
            Result := UTF8ToWide(Value)
          else
            Result := Value;
          Exit;
        end;
  end;
 {$endif bExifV2}


 {$ifdef bTrace}
 {$ifdef bExifV2}
  procedure TraceExif(aInfo :PGFL_EXIF_DATAEX);

    procedure LocTrace(aEntry :PGFL_EXIF_ENTRYEX);
    begin
      while aEntry <> nil do begin
        with aEntry^ do
          Trace('  Tag=%d, Fmt=%d, lfd=%d, Num=%d, Value=%d, DataLen=%d', [Tag, Format, lfd, NumberOfComponents, Value, DataLength]);
        aEntry := aEntry.Next;
      end;
    end;

  begin
    Trace('EXIF Info (MSBF=%x):', [aInfo.UseMSBF]);
    LocTrace(aInfo.Root);
    Trace('Done');
  end;

 {$else}

  procedure TraceExif(aInfo :PGFL_EXIF_DATA);
  var
    i :Integer;
  begin
    for i := 0 to aInfo.NumberOfItems - 1 do
      with aInfo.ItemsList[i] do
        Trace('%d, %d, %s, %s', [Flag, Tag, Name, Value]);
  end;
 {$endif bExifV2}
 {$endif bTrace}


 {-----------------------------------------------------------------------------}

 {$ifdef bMyGetMem}
  function MyAlloc(size: GFL_UINT32; param: Pointer) :Pointer; stdcall;
  begin
    Trace('MyAlloc %d', [size]);
    GetMem(Result, Size);
    FillZero(Result^, size);
  end;

  function MyRealloc(ptr: Pointer; newsize: GFL_UINT32; param: Pointer) :Pointer; stdcall;
  begin
    Trace('MyRealloc %d', [newsize]);
    ReallocMem(Ptr, NewSize);
    Result := Ptr;
  end;

  procedure MyFree(buffer: Pointer; param: Pointer); stdcall;
  begin
    Trace('MyFree %p', [buffer]);
    FreeMem(Buffer);
  end;
 {$endif bMyGetMem}


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

   {$ifdef bMyGetMem}
    gflLibraryInitEx(MyAlloc, MyRealloc, MyFree, Pointer($1));
   {$else}
    gflLibraryInit;
   {$endif bMyGetMem}

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
      class function CreateByFile(AManager :TManager; const AName :TString; ABuf :Pointer; ABufSize :Integer) :TView;
      function LoadFile :Boolean;
      function DecodePage(AIndex :Integer; ACX, ACY :Integer; AThumbnail :Boolean) :GFL_ERROR;
      procedure FreePage;
      procedure FreeExif;

      function TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

    private
      FFileName   :TString;
      FBuffer     :Pointer;
      FBufSize    :Integer;
      FFmtIndex   :Integer;
      FFmtName    :TString;
      FCompress   :TString;
      FDescr      :TString;
      FFrames     :Cardinal;
      FCurFrame   :Integer;
      FSize       :TSize;
      FColorModel :GFL_COLORMODEL;
      FPixBPP     :Integer;      { Исходная глубина цвета (BPP) }
      FDelay      :Integer;      { Задержка страницы, для анимированных изображений }
      FOrient0    :Integer;      { Ориентация страницы }

      FBmp        :PGFL_BITMAP;
      FPalette    :Pointer;
      FBmpBPP     :Integer;      { Декодированная глубина цвета (BPP) }
      FBmpCM      :byte;         { PPVDColorModel }
      FAlpha      :Boolean;      { Наличие альфа-канала на странице }
      FCanThumb   :Boolean;
      FThumbnail  :Boolean;

     {$ifdef bExifV2}
      FExif       :PGFL_EXIF_DATAEX;
     {$else}
      FExif       :PGFL_EXIF_DATA;
     {$endif bExifV2}
//    FIptc       :PGFL_IPTC_DATA;

      FStrTag     :TString;
      FInt64Tag   :Int64;

      FCallback   :TPVDDecodeCallback2;
      FCallbackContext :Pointer;
      FInterrupt :Boolean;

      procedure MakePalette(aColors :Integer);
    end;



  destructor TView.Destroy; {override;}
  begin
    FreePage;
    FreeExif;
    inherited Destroy;
  end;


  class function TView.CreateByFile(AManager :TManager; const AName :TString; ABuf :Pointer; ABufSize :Integer) :TView;
  begin
    Result := TView.Create;
    Result.FFileName := AName;
    Result.FBuffer := ABuf;
    Result.FBufSize := ABufSize;
    if Result.LoadFile then
      {}
    else
      FreeObj(Result);
  end;


  function TView.LoadFile :Boolean;
  var
    vInfo :TGFL_FILE_INFORMATION;
    vRes :GFL_ERROR;
  begin
    Result := False;

   {$ifdef bTrace}
    Trace('GFL Check: "%s" (BufSize=%d)...', [FFileName, FBufSize]);
   {$endif bTrace}

    FillZero(vInfo, SizeOf(vInfo));
    if FBuffer <> nil then begin
      vRes := gflGetFileInformationFromMemory(FBuffer, FBufSize, -1, vInfo);
      if vRes <> gfl_no_error then
        vRes := gflGetFileInformationW(PTChar(FFileName), -1, vInfo);
    end else
      vRes := gflGetFileInformationW(PTChar(FFileName), -1, vInfo);

    if vRes <> gfl_no_error then begin
     {$ifdef bTrace}
      Trace('  Error, Code=%x (%s)', [vRes, gflGetErrorString(vRes)]);      
     {$endif bTrace}
      Exit;
    end;

    FFmtIndex := vInfo.FormatIndex;
    FFmtName := StrUpCase(vInfo.FormatName);
    if vInfo.Compression <> GFL_NO_COMPRESSION then
      FCompress := vInfo.CompressionDescription;
    FDescr := vInfo.Description;
    FFrames := vInfo.NumberOfImages;

    FSize.cx := vInfo.Width;
    FSize.cy := vInfo.Height;
    FPixBPP := vInfo.BitsPerComponent * vInfo.ComponentsPerPixel;

    FColorModel := vInfo.ColorModel;

    gflFreeFileInformation(vInfo);

   {$ifdef bTrace}
    Trace('  OK, Format=%s, %d x %d, %d bpp, ColorModel=%d, Frames=%d(?)', [FFmtName, FSize.cx, FSize.cy, FPixBPP, FColorModel, FFrames]);
   {$endif bTrace}

    FCurFrame := -1;

    { Количество страниц в GIF'ах определяется только при декодировании. Ошибка GFL? }
//  FCanThumb := True;
//  FCanThumb := FFmtName <> 'GIF';
    FCanThumb := FFmtName = 'JPEG';

//  if FFmtName = 'GIF' then
//    { Неважно - установится при Decode }
//    SetPage(0);

    Result := True;
  end;


(*
  function MyRead(handle: GFL_HANDLE; var buffer: Pointer; size: GFL_UINT32): GFL_UINT32; stdcall;
  begin
    Trace('MyRead');
    Result := 0;
  end;

  function MyAllocateBitmap(width: GFL_INT32; height: GFL_INT32; number_component: GFL_INT32; bits_per_component: GFL_INT32; padding: GFL_INT32; bytes_per_line: GFL_INT32; user_params: Pointer): GFL_UINT32; stdcall;
  begin
    Trace('MyAllocateBitmap');
    Result := 0
  end;
*)

  procedure MyProgress(percent: GFL_INT32; user_params: Pointer); stdcall;
  begin
//  Trace('MyProgress %d', [percent]);
    with TView(user_params) do
      if Assigned(FCallback) then
        FInterrupt := not FCallback(FCallbackContext, percent, 100, nil);
  end;

  function MyWantCancel(user_params :Pointer): GFL_BOOL; stdcall;
  begin
//  Trace('MyWantCancel');
    with TView(user_params) do
      Result := IntIf(FInterrupt, 1, 0);
  end;


  function TView.DecodePage(AIndex :Integer; ACX, ACY :Integer; AThumbnail :Boolean) :GFL_ERROR;
  var
    vParam :TGFL_LOAD_PARAMS;
    vInfo :TGFL_FILE_INFORMATION;
    vThumb :Boolean;
   {$ifdef bExifV2}
   {$else}
    vStr :TString;
   {$endif bExifV2}
  begin
//  Result := gfl_no_error;

    FreePage;
    FreeExif;

   {$ifdef bTrace}
//  TraceBegF('GFL Load: "%s", Sizeof(FBmp)=%d, Sizeof(vParam)=%d, Sizeof(vInfo)=%d...', [FFileName, SizeOf(FBmp), SizeOf(vParam), SizeOf(vInfo)]);
    TraceBegF('GFL Load: Frame=%d, %d x %d, Thumb=%d...', [AIndex, ACX, ACY, byte(AThumbnail)]);
   {$endif bTrace}

    vThumb := FCanThumb and (AThumbnail or ((ACX > 0) and (ACY > 0)));

    FillZero(vParam, SizeOf(vParam));
    if vThumb then
      gflGetDefaultThumbnailParams(vParam)
    else
      gflGetDefaultLoadParams(vParam);

//  vParam.FormatIndex := FFmtIndex;
    vParam.ImageWanted := AIndex;

    vParam.Flags := GFL_LOAD_METADATA;
//  vParam.Flags := GFL_LOAD_COMMENT;
    vParam.Flags := vParam.Flags or GFL_LOAD_IGNORE_READ_ERROR;
//  vParam.Flags := vParam.Flags or GFL_LOAD_FORCE_COLOR_MODEL;
//  vParam.Flags := vParam.Flags or GFL_LOAD_ONLY_FIRST_FRAME;

//  vParam.ColorModel := GFL_BGR;
    vParam.ColorModel := GFL_BGRA;

//  if FColorModel = GFL_CM_CMYK then begin
//    vParam.Flags := vParam.Flags or GFL_LOAD_ORIGINAL_COLORMODEL;
//    vParam.ColorModel := GFL_CM_CMYK;
//  end;

//  vParam.Flags := vParam.Flags or GFL_LOAD_ORIGINAL_COLORMODEL;
//  vParam.Flags := vParam.Flags or GFL_LOAD_ORIGINAL_DEPTH;
//  vParam.ColorModel := GFL_TRUECOLORS;

//  vParam.ChannelOrder := GFL_CORDER_INTERLEAVED;
//  vParam.ChannelOrder := GFL_CORDER_SEQUENTIAL;
//  vParam.ChannelOrder := GFL_CORDER_SEPARATE;

//  vParam.ChannelType := GFL_CTYPE_BGR;
//  vParam.ChannelType := GFL_CTYPE_RGBA;
//  vParam.ChannelType := GFL_CTYPE_ABGR;

//  vParam.LinePadding := 1;  {???}
    vParam.EpsDpi := opt_EpsDpi;

//  vParam.Callbacks.Read := MyRead;
//  vParam.Callbacks.AllocateBitmap := MyAllocateBitmap;

    vParam.Callbacks.Progress := MyProgress;
    vParam.Callbacks.ProgressParams := Self;
    vParam.Callbacks.WantCancel := MyWantCancel;
    vParam.Callbacks.WantCancelParams := Self;
    
    FInterrupt := False;

    FillZero(vInfo, SizeOf(vInfo));
    FThumbnail := False;
    if vThumb then begin
      { Извлекаем эскиз }
      if AThumbnail then begin
        ACX := 0; ACY := 0;
        vParam.Flags := vParam.Flags or GFL_LOAD_EMBEDDED_THUMBNAIL;
//      vParam.Flags := vParam.Flags or GFL_LOAD_ORIGINAL_EMBEDDED_THUMBNAIL  ???
      end else
//      vParam.Flags := vParam.Flags or GFL_LOAD_PREVIEW_NO_CANVAS_RESIZE {or GFL_LOAD_HIGH_QUALITY_THUMBNAIL};
        vParam.Flags := vParam.Flags or GFL_LOAD_HIGH_QUALITY_THUMBNAIL;

      if FBuffer <> nil then begin
        Result := gflLoadThumbnailFromMemory(FBuffer, FBufSize, ACX, ACY, FBmp, vParam, @vInfo);
        if Result <> gfl_no_error then
          Result := gflLoadThumbnailW(PTChar(FFileName), ACX, ACY, FBmp, vParam, @vInfo);
      end else
        Result := gflLoadThumbnailW(PTChar(FFileName), ACX, ACY, FBmp, vParam, @vInfo);

      FThumbnail := AThumbnail and ((FBmp.Width < vInfo.Width) or (FBmp.Height < vInfo.Height));
    end else
    begin
      if FBuffer <> nil then begin
        Result := gflLoadBitmapFromMemory(FBuffer, FBufSize, FBmp, vParam, @vInfo);
        if Result <> gfl_no_error then
          Result := gflLoadBitmapW(PTChar(FFileName), FBmp, vParam, @vInfo);
      end else
        Result := gflLoadBitmapW(PTChar(FFileName), FBmp, vParam, @vInfo);
    end;

    if Result <> gfl_no_error then
//    GFLError(vRes);
      Exit;

    if AIndex = 0 then
      FFrames := vInfo.NumberOfImages;
    FCurFrame := AIndex;

    FSize.cx := vInfo.Width;
    FSize.cy := vInfo.Height;
    FPixBPP := vInfo.BitsPerComponent * vInfo.ComponentsPerPixel;

    if vInfo.Compression <> GFL_NO_COMPRESSION then
      FCompress := vInfo.CompressionDescription;
    FDescr := vInfo.Description;

    gflFreeFileInformation(vInfo);

    FBmpCM := GflType2PvdColorModel(FBmp.BType);
    FAlpha := FBmpCM in [PVD_CM_BGRA];
    if FBmp.BType in [GFL_COLORS, GFL_GREY{???}] then
      FBmpBPP := 8
    else
      FBmpBPP := FBmp.BitsPerComponent * FBmp.ComponentsPerPixel;

    if FBmp.ColorUsed > 0 then
      MakePalette( RangeLimit(FBmp.ColorUsed, 1, 256) );

   {$ifdef bExifV2}
    FExif := gflBitmapGetEXIF2(FBmp);
   {$else}
    FExif := gflBitmapGetEXIF(FBmp, 0);
   {$endif bExifV2}
//  FIptc := gflBitmapGetIPTC(FBmp, 0);

    FDelay  := 0;
    if FExif <> nil then begin
     {$ifdef bTrace}
      TraceExif(FExif);
     {$endif bTrace}

     {$ifdef bExifV2}
      GetExifInfoInt(FExif, GFL_EXIF_IFD_0, GFL_EXIF_ORIENTATION, FOrient0);
     {$else}
      vStr := GetExifInfo(FExif, GFL_EXIF_ORIENTATION);
      if vStr <> '' then
        FOrient0 := Str2IntDef( ExtractWord(2, vStr, ['(', ')']), 0);
     {$endif bExifV2}

//    FDelay := ...   !!!
    end;

   {$ifdef bTrace}
    TraceEnd(Format('  done, %d x %d', [FBmp.Width, FBmp.Height]));
   {$endif bTrace}
  end;


  procedure TView.MakePalette(aColors :Integer);
  var
    i :Integer;
    vRGB :PRGBQuad;
  begin
//  Trace('MakePalette: %d, SizeOf(TRGBQuad)=%d', [aColors, SizeOf(TRGBQuad)]);

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
     {$ifdef bExifV2}
      gflFreeEXIF2(FExif);
     {$else}
      gflFreeEXIF(FExif);
     {$endif bExifV2}
      FExif := nil;
    end;
//  if FIptc <> nil then begin
//    gflFreeIPTC(FIptc);
//    FIptc := nil;
//  end;
  end;



  function TView.TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

    procedure LocStrTag(aLFD :Integer; aTag :DWORD);
   {$ifdef bExifV2}
    begin
      Result := GetExifInfoStr(FExif, aLFD, aTag, FStrTag);
      if Result then begin
        aValue := PTChar(FStrTag);
        aType := PVD_TagType_Str;
      end;
   {$else}
    begin
      FStrTag := GetExifInfo(FExif, aTag, True);
      if FStrTag <> '' then begin
        aValue := PTChar(FStrTag);
        aType := PVD_TagType_Str;
        Result := True;
      end;
   {$endif bExifV2}
    end;

    procedure LocIntTag(aLFD :Integer; aTag :DWORD);
   {$ifdef bExifV2}
    var
      vInt :Integer;
    begin
      Result := GetExifInfoInt(FExif, aLFD, aTag, vInt);
      if Result then begin
        aValue := Pointer(TIntPtr(vInt));
        aType := PVD_TagType_Int;
      end
   {$else}
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
   {$endif bExifV2}
    end;


   {$ifdef bExifV2}
    procedure LocInt64Tag(aLFD :Integer; aTag :DWORD);
    begin
      Result := GetExifInfoInt64(FExif, aLFD, aTag, FInt64Tag);
      if Result then begin
        aValue := @FInt64Tag;
        aType := PVD_TagType_Int64;
      end;
    end;


    procedure LocResolutionTag(aLFD :Integer; aTag :DWORD);
    var
      vInt, vUnit :Integer;
      vInt64 :TInt64;
      vIsSM :Boolean;
    begin
      vIsSM := False; vInt := 0;
      Result := GetExifInfoInt64(FExif, aLFD, aTag, vInt64);
      if Result then begin
        with Int64Rec(vInt64) do
          vInt := Trunc(Lo / Hi);
        if GetExifInfoInt(FExif, GFL_EXIF_IFD_0, 296, vUnit) then
          vIsSM := vUnit = 3;
      end;
      if Result then begin
        if vIsSM then
          { Разрешение в сантиметрах, пересчитываем в дюймы }
          vInt := Trunc(vInt * 2.54);
        aValue := Pointer(TIntPtr(vInt));
        aType := PVD_TagType_Int;
      end;
    end;
   {$endif bExifV2}


  begin
    Result := False;
    if FExif = nil then
      Exit;

    case aCode of
      PVD_Tag_Description  : LocStrTag(GFL_EXIF_IFD_0, 270);
      PVD_Tag_Time         : LocStrTag(GFL_EXIF_MAIN_IFD, GFL_EXIF_DATETIME_ORIGINAL);
      PVD_Tag_EquipMake    : LocStrTag(GFL_EXIF_IFD_0, GFL_EXIF_MAKER);
      PVD_Tag_EquipModel   : LocStrTag(GFL_EXIF_IFD_0, GFL_EXIF_MODEL);
      PVD_Tag_Software     : LocStrTag(GFL_EXIF_IFD_0, 305);
      PVD_Tag_Author       : LocStrTag(GFL_EXIF_IFD_0, 315);
      PVD_Tag_Copyright    : LocStrTag(GFL_EXIF_IFD_0, 33432);

     {$ifdef bExifV2}
      PVD_Tag_ExposureTime : LocInt64Tag(GFL_EXIF_MAIN_IFD, GFL_EXIF_EXPOSURETIME {33434} );
      PVD_Tag_FNumber      : LocInt64Tag(GFL_EXIF_MAIN_IFD, GFL_EXIF_FNUMBER {33437} );
      PVD_Tag_FocalLength  : LocInt64Tag(GFL_EXIF_MAIN_IFD, GFL_EXIF_FOCALLENGTH {37386} );
      PVD_Tag_ISO          : LocIntTag(GFL_EXIF_MAIN_IFD, 34855);
      PVD_Tag_Flash        : LocIntTag(GFL_EXIF_MAIN_IFD, 37385);
     {$endif bExifV2}

     {$ifdef bExifV2}
      PVD_Tag_XResolution  : LocResolutionTag(GFL_EXIF_IFD_0, 282);
      PVD_Tag_YResolution  : LocResolutionTag(GFL_EXIF_IFD_0, 283);
     {$else}
      PVD_Tag_XResolution  : LocIntTag(GFL_EXIF_IFD_0, 282);
      PVD_Tag_YResolution  : LocIntTag(GFL_EXIF_IFD_0, 283);
     {$endif bExifV2}
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
    pPluginInfo.Flags := PVD_IP_DECODE
      or PVD_IP_NEEDFILE;
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
      if lFileSize > lBuf then begin
        pBuf := nil;
        lBuf := 0;
      end;

      vView := TView.CreateByFile(pContext, pFileName, pBuf, lBuf);

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
      on E :Exception do begin
        FLastError := E.Message;
        pImageInfo.nErrNumber := DWORD(-1);
      end;
    end;
  end;


  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  var
    vView :TView;
  begin
    Result := False; FLastError := '';
    try
      vView := pImageContext;

      if (pPageInfo.iPage = 0) and (vView.FCurFrame = -1) then
        { Получение полной информации о странице возможно только(?) одновременно с }
        { декодированием, что не подходит для работы ThumbView. }
        { Для первой страницы возвращаем информацию, полученную при FileOpen, }
        { хотя она и не совсем полная (некорректна FOrient) }
        NOP
      else begin
        Result := True;
        Exit;
      end;

      pPageInfo.pFormatName := PTChar(vView.FFmtName);
      pPageInfo.pCompression := PTChar(vView.FCompress);
//    pPageInfo.pComments := PTChar(vView.FDescr);

      pPageInfo.lWidth := vView.FSize.cx;
      pPageInfo.lHeight := vView.FSize.cy;
      pPageInfo.nBPP := vView.FPixBPP;
      pPageInfo.lFrameTime := vView.FDelay;
      pPageInfo.Orientation := vView.FOrient0;

      Result := True;

    except
      on E :Exception do begin
        FLastError := E.Message;
        pPageInfo.nErrNumber := DWORD(-1);
      end;
    end;
  end;


  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  var
    vView :TView;
    vRes :GFL_ERROR;
  begin
    Result := False; FLastError := '';
    try
      vView := pImageContext;

      vView.FCallback := DecodeCallback;
      vView.FCallbackContext := pDecodeCallbackContext;

      if pDecodeInfo.Flags and PVD_IDF_THUMBONLY <> 0 then begin
        vRes := vView.DecodePage(pDecodeInfo.iPage, pDecodeInfo.lWidth, pDecodeInfo.lHeight, True);
        if vRes <> gfl_no_error then
          Exit;
      end else
      if pDecodeInfo.Flags and PVD_IDF_THUMBFIRST <> 0 then begin
        vRes := vView.DecodePage(pDecodeInfo.iPage, pDecodeInfo.lWidth, pDecodeInfo.lHeight, True);
        if vRes <> gfl_no_error then
          vRes := vView.DecodePage(pDecodeInfo.iPage, pDecodeInfo.lWidth, pDecodeInfo.lHeight, False);
      end else
        vRes := vView.DecodePage(pDecodeInfo.iPage, pDecodeInfo.lWidth, pDecodeInfo.lHeight, False);
      if vRes <> gfl_no_error then
        GFLError(vRes);

      pDecodeInfo.lSrcWidth := vView.FSize.cx;
      pDecodeInfo.lSrcHeight := vView.FSize.cy;
      pDecodeInfo.lSrcBPP := vView.FPixBPP;
      pDecodeInfo.nPages := vView.FFrames;

      pDecodeInfo.lWidth := vView.FBmp.Width;
      pDecodeInfo.lHeight := vView.FBmp.Height;
      pDecodeInfo.nBPP := vView.FBmpBPP;
      pDecodeInfo.ColorModel := vView.FBmpCM;
      pDecodeInfo.Flags := IntIf(vView.FAlpha, PVD_IDF_ALPHA, 0) or IntIf(vView.FThumbnail, PVD_IDF_THUMBNAIL, 0);

      pDecodeInfo.lImagePitch := vView.FBmp.BytesPerLine;
      pDecodeInfo.pImage := vView.FBmp.Data;
      pDecodeInfo.pPalette := vView.FPalette;
      pDecodeInfo.nColorsUsed := 0 {FBmp.ColorUsed} ;

      pDecodeInfo.Orientation := vView.FOrient0;

      Result := True;

    except
      on E :Exception do begin
        FLastError := E.Message;
        pDecodeInfo.nErrNumber := DWORD(-1);
      end;
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


  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;
  begin
    StrPLCopy(pErrInfo, FLastError, nBufLen);
    Result := True;
  end;


end.


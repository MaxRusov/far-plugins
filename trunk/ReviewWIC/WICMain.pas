{$I Defines.inc}

unit WICMain;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* WIC                                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    Commctrl,
    ActiveX,
    Wincodec,

    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,
    PVApi;

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

(*function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; var aTagCount :Integer; var aTags :PPvdTagArray) :Integer; stdcall;  *)
  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;

  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure OleError(ErrorCode: HResult);
  begin
    raise EOleSysError.Create('', ErrorCode, 0);
  end;


  procedure OleCheck(Result: HResult);
  begin
    if not Succeeded(Result) then
      OleError(Result);
  end;


  function WICError2Mess(aCode :HResult) :TString;
  begin
    Result := '';
    case DWORD(aCode) of
      $88982f04: Result := 'Wrong state';
      $88982f05: Result := 'Value out of range';
      $88982f07: Result := 'Unknown image format';
      $88982f0B: Result := 'Unsupported version';
      $88982f0C: Result := 'Not initialized';
      $88982f0D: Result := 'Already locked';
      $88982f40: Result := 'Property not found';
      $88982f41: Result := 'Property not supported';
      $88982f42: Result := 'Property size';
      $88982f43: Result := 'Codec present';
      $88982f44: Result := 'Codec not humbnail';
      $88982f45: Result := 'Palette unavailable';
      $88982f46: Result := 'Codec too many scan lines';
      $88982f48: Result := 'Internal error';
      $88982f49: Result := 'Source rect does not match dimensions';
      $88982f50: Result := 'Component not found';
      $88982f51: Result := 'Image size out of range';
      $88982f52: Result := 'Too much metadata';
      $88982f60: Result := 'Bad image';
      $88982f61: Result := 'Bad header';
      $88982f62: Result := 'Frame missing';
      $88982f63: Result := 'Bad metadata header';
      $88982f70: Result := 'Bad stream data';
      $88982f71: Result := 'Stream write';
      $88982f72: Result := 'Stream read';
      $88982f73: Result := 'Stream not available';
      $88982f80: Result := 'Unsupported pixel format';
      $88982f81: Result := 'Unsupported operation';
      $88982f8A: Result := 'Invalid registration';
      $88982f8B: Result := 'Component initialize failure';
      $88982f8C: Result := 'Insufficient buffer';
      $88982f8D: Result := 'Duplicate metadata present';
      $88982f8E: Result := 'Property unexpected type';
      $88982f8F: Result := 'Unexpected size';
      $88982f90: Result := 'Invalid query request';
      $88982f91: Result := 'Unexpected metadata type';
      $88982f92: Result := 'Request only valid at metadata root';
      $88982f93: Result := 'Invalid query character';
    end;
  end;
  

  type
    EWicError = class(EWin32Error);

  procedure WicError(aCode :HResult);
  var
    vStr :TString;
    vErr :EWin32Error;
  begin
//  TraceF('WICError=%d', [ErrorCode]);
    vStr := WICError2Mess(aCode);
    if vStr = '' then
      vStr := SysErrorMessage(aCode);
    vErr := EWicError.CreateFmt('WIC Error code: %x'#10'%s', [aCode, vStr]);
    vErr.ErrorCode := DWORD(aCode);
    raise vErr;
  end;


  procedure WicCheck(Result: HResult);
  begin
    if not Succeeded(Result) then
      WicError(Result);
  end;


 {-----------------------------------------------------------------------------}

  function NameOfFormat(const AID :TGUID) :TString;
  begin
    Result := '';
    if IsEqualGUID(AID, GUID_ContainerFormatJpeg) then
      Result := 'JPEG'
    else
    if IsEqualGUID(AID, GUID_ContainerFormatBmp) then
      Result := 'BMP'
    else
    if IsEqualGUID(AID, GUID_ContainerFormatPng) then
      Result := 'PNG'
    else
    if IsEqualGUID(AID, GUID_ContainerFormatGif) then
      Result := 'GIF'
    else
    if IsEqualGUID(AID, GUID_ContainerFormatTiff) then
      Result := 'TIFF'
    else
    if IsEqualGUID(AID, GUID_ContainerFormatIco) then
      Result := 'ICO';
  end;


  function WICGetShortName(const AID :TGUID) :TString;
  var
    vBuf :array[0..255] of TChar;
    vLen :UINT;
  begin
    Result := '';
    if WICMapGuidToShortName(AID,High(vBuf), vBuf, vLen) = S_OK then
      SetString(Result, PTChar(@vBuf), vLen);
  end;


  function GetFriendlyName(const aInfo :IWICComponentInfo) :TString; overload;
  var
    vBuf :array[0..255] of TChar;
    vLen :UINT;
  begin
    Result := '';
    if (aInfo.GetFriendlyName(High(vBuf), vBuf, vLen) = S_OK) and (vLen > 1) then
      SetString(Result, PTChar(@vBuf), vLen - 1);
  end;


  function GetFriendlyName(const AFactory :IWICImagingFactory; const AID :TGUID) :TString; overload;
  var
    vInfo :IWICComponentInfo;
  begin
    Result := '';
    if Succeeded(AFactory.CreateComponentInfo(AID, vInfo)) then
      Result := GetFriendlyName(vInfo);
  end;


  function PixelsFromFormat(const AFactory :IWICImagingFactory; const AID :TGUID) :Integer;
  var
    vInfo :IWICComponentInfo;
    vFmtInfo :IWICPixelFormatInfo;
    vBPP :Cardinal;
  begin
    Result := 0;
    if Succeeded(AFactory.CreateComponentInfo(AID, vInfo)) and
       Succeeded(vInfo.QueryInterface(IID_IWICPixelFormatInfo, vFmtInfo)) and
       Succeeded(vFmtInfo.GetBitsPerPixel(vBPP))
    then begin
     {$ifdef bTrace}
//    Trace(GetFriendlyName(vFmtInfo));
     {$endif bTrace}
      Result := vBPP;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GetFileExtensions(const aInfo :IWICBitmapCodecInfo) :TString;
  var
    vLen :Cardinal;
  begin
    Result := '';
    if (aInfo.GetFileExtensions(0, nil, vLen) = S_OK) and (vLen > 1) then begin
      SetLength(Result, vLen - 1);
      aInfo.GetFileExtensions(vLen, PTChar(Result), vLen)
    end;
  end;

  function GetMimeTypes(const aInfo :IWICBitmapCodecInfo) :TString;
  var
    vLen :Cardinal;
  begin
    Result := '';
    if (aInfo.GetMimeTypes(0, nil, vLen) = S_OK) and (vLen > 1) then begin
      SetLength(Result, vLen - 1);
      aInfo.GetMimeTypes(vLen, PTChar(Result), vLen)
    end;
  end;


  type
    TEnumDecoderCallback = procedure(const aDecoderInfo :IWICBitmapDecoderInfo) of object;

  function EnumFormats(const AFactory :IWICImagingFactory; aCallback :TEnumDecoderCallback) :HRESULT;
  var
    vDecodersEnum :IEnumUnknown;
    vDecoderInfo :IWICBitmapDecoderInfo;
    vIntf :IUnknown;
  begin
    Result := AFactory.CreateComponentEnumerator(WICDecoder, WICComponentEnumerateDefault, vDecodersEnum);
    if Result <> S_OK then
      Exit;

    while vDecodersEnum.Next(1, vIntf, nil) = S_OK do begin
      if Succeeded(vIntf.QueryInterface(IID_IWICBitmapDecoderInfo, vDecoderInfo)) then
        aCallback(vDecoderInfo);
      vIntf := nil;
    end;
  end;



 {-----------------------------------------------------------------------------}
 { Metadata                                                                    }

//IWICMetadataQueryReader

  const
    ole32 = 'ole32.dll';

  function PropVariantClear(var pvar: PROPVARIANT): HRESULT; stdcall;
    external ole32 name 'PropVariantClear';


  function VarToInt(const aVar :PROPVARIANT; var aRes :Integer) :Boolean;
  begin
    Result := True;
    case aVar.vt of
      VT_I1 : aRes := shortint(aVar.bVal);
      VT_I2 : aRes := aVar.iVal;
      VT_I4 : aRes := aVar.lVal;
      VT_UI1: aRes := aVar.bVal;
      VT_UI2: aRes := aVar.uiVal;
      VT_UI4: aRes := aVar.ulVal;
    else
      Result := False;
    end;
  end;

  function VarToInt64(const aVar :PROPVARIANT; var aRes :Int64) :Boolean;
  begin
    Result := True;
    case aVar.vt of
      VT_I8, VT_UI8:
        aRes := Int64(aVar.hVal);
    else
      Result := False;
    end;
  end;

  function VarToStr(const aVar :PROPVARIANT; var aRes :TString) :Boolean;
  begin
    Result := True;
    case aVar.vt of
      VT_LPSTR  :
        if DetectUTF8(aVar.pszVal) then
          aRes := UTF8ToWide(aVar.pszVal)
        else
          aRes := aVar.pszVal;
      VT_LPWSTR :
        aRes := aVar.pwszVal
    else
      Result := False;
    end;
  end;


  function VarAsStr(const aVar :PROPVARIANT) :TString;
  var
    vInt :Integer;
  begin
    case aVar.vt of
      VT_I1, VT_I2, VT_I4, VT_UI1, VT_UI2, VT_UI4:
        if VarToInt(aVar, vInt) then
          Result := Int2Str(vInt);
      VT_I8, VT_UI8:
//      Result := Int64ToStr(TLargeInteger(aVar.hVal));
        Result := HexStr(TLargeInteger(aVar.hVal), 16);
      VT_BOOL:
        Result := StrIf(aVar.bVal = 0, 'False', 'True');
      VT_LPSTR:
        Result := aVar.pszVal;
      VT_LPWSTR:
        Result := aVar.pwszVal;
      VT_BLOB:
        Result := 'Blob';
    else
      Result := 'UnknownType' + Int2Str(aVar.vt);
    end;
  end;


  function MetaExist(const aMetadata :IWICMetadataQueryReader; const aQuery :TString) :Boolean;
  var
    vRes :PROPVARIANT;
  begin
    FillZero(vRes, SizeOf(vRes));
    Result := aMetadata.GetMetadataByName(PTChar(aQuery), vRes) = S_OK;
    if Result then
      PropVariantClear(vRes);
  end;


  function MetaQueryLog(const aMetadata :IWICMetadataQueryReader; const aQuery :TString; var aRes :Boolean) :Boolean;
  var
    vVar :PROPVARIANT;
  begin
    FillZero(vVar, SizeOf(vVar));
    Result := (aMetadata.GetMetadataByName(PTChar(aQuery), vVar) = S_OK) and (vVar.vt = VT_BOOL);
    if Result then
      aRes := vVar.boolVal;
  end;

  function MetaQueryInt(const aMetadata :IWICMetadataQueryReader; const aQuery :TString; var aRes :Integer) :Boolean;
  var
    vVar :PROPVARIANT;
  begin
    FillZero(vVar, SizeOf(vVar));
    Result := aMetadata.GetMetadataByName(PTChar(aQuery), vVar) = S_OK;
    if Result then
      Result := VarToInt(vVar, aRes);
  end;

  function MetaQueryInt64(const aMetadata :IWICMetadataQueryReader; const aQuery :TString; var aRes :Int64) :Boolean;
  var
    vVar :PROPVARIANT;
  begin
    FillZero(vVar, SizeOf(vVar));
    Result := aMetadata.GetMetadataByName(PTChar(aQuery), vVar) = S_OK;
    if Result then
      Result := VarToInt64(vVar, aRes);
  end;

  function MetaQueryStr(const aMetadata :IWICMetadataQueryReader; const aQuery :TString; var aRes :TString) :Boolean;
  var
    vVar :PROPVARIANT;
  begin
    FillZero(vVar, SizeOf(vVar));
    Result := aMetadata.GetMetadataByName(PTChar(aQuery), vVar) = S_OK;
    if Result then
      Result := VarToStr(vVar, aRes);
  end;


  type
    TEnumMetadataCallback = procedure(const aName :TSTring; const aVal :PROPVARIANT; var aMore :Boolean) of object;

  function EnumMetadata(const aMetadata :IWICMetadataQueryReader; const aPath :TString; aCallback :TEnumMetadataCallback; aRecursive :Boolean) :HResult;
  var
    vENum :IEnumString;
    vPStr :POLESTR;
    vVal :PROPVARIANT;
    vSubMetadata :IWICMetadataQueryReader;
    vMore :Boolean;
  begin
    Result := aMetadata.GetEnumerator(vEnum);
    if Result <> S_OK then
      Exit;
    vMore := True;
    FillZero(vVal, SizeOf(vVal));
    while vMore and (vEnum.Next(1, vPStr, nil) = S_OK) do begin
      if aMetadata.GetMetadataByName(vPStr, vVal) = S_OK then begin
        if vVal.vt = VT_UNKNOWN then begin
          if aRecursive and Succeeded(IUnknown(vVal.pStream).QueryInterface(IID_IWICMetadataQueryReader, vSubMetadata)) then begin
            EnumMetadata(vSubMetadata, vPStr, aCallback, aRecursive);
            vSubMetadata := nil;
          end;
        end else
          aCallback(aPath + vPStr, vVal, vMore);
        PropVariantClear(vVal);
      end;
      CoTaskMemFree(vPStr);
    end;
  end;


 {-----------------------------------------------------------------------------}

  type
    TManager = class(TBasis)
    public
      constructor Create; override;
      procedure CollectInfo;

    private
      FFactory  :IWICImagingFactory;
      FExts :TString;

      procedure DecoderCallback(const aDecoderInfo :IWICBitmapDecoderInfo);
    end;


  constructor TManager.Create; {override;}
  begin
    inherited Create;
    OleCheck( CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER, IID_IWICImagingFactory, FFactory) );
  end;


  procedure TManager.DecoderCallback(const aDecoderInfo :IWICBitmapDecoderInfo);
  begin
   {$ifdef bTrace}
    TraceF('Decoder: %s, Types: %s, Exts: %s', [GetFriendlyName(aDecoderInfo), GetMimeTypes(aDecoderInfo), GetFileExtensions(aDecoderInfo)]);
   {$endif bTrace}
    FExts := AppendStrCh(FExts, StrDeleteChars(GetFileExtensions(aDecoderInfo), ['.']), ',');
  end;


  procedure TManager.CollectInfo;
  begin
    FExts := '';
    EnumFormats(FFactory, DecoderCallback);
  end;


 {-----------------------------------------------------------------------------}

  type
    TView = class(TComBasis)
    public
      destructor Destroy; override;
      class function CreateByFile(AManager :TManager; const AName :TString) :TView;
      function LoadFile(const AName :TString) :Boolean;
      procedure SetPage(AIndex :Integer);
      procedure DecodePage(ACX, ACY :Integer; AThumbnail :Boolean);
      procedure FreePage;

      function TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

    private
      FFactory   :IWICImagingFactory;
      FDecoder   :IWICBitmapDecoder;
      FFrame     :IWICBitmapFrameDecode;
      FBitmap    :IWICBitmapSource;
      FBitmap2   :IWICBitmapSource;
      FMetadata  :IWICMetadataQueryReader;
      FFmtID     :TGUID;
      FFmtName   :TString;
//    FCompress  :TString;
      FDescr     :TString;
      FFrames    :Cardinal;
      FCurFrame  :Integer;
      FSize      :TSize;
      FSize2     :TSize;
      FPixFmt    :TGUID;        { Исходный формат цвета }
      FPixBPP    :Integer;      { Исходная глубина цвета (BPP) }
      FPixBPP2   :Integer;      { Сконветированная глубина цвета }
      FAlpha     :Boolean;      { Наличие альфа-канала на странице }
      FTransp    :Boolean;
      FDelay     :Integer;      { Задержка страницы, для анимированных изображений }
      FOrient0   :Integer;      { Ориентация страницы }
      FRowSize   :Integer;      { Количество байт на строку (FSize2.CX * 3 или 4) }
      FBuffer    :Pointer;
      FThumbnail :Boolean;
      FStrTag    :TString;
      FInt64Tag  :Int64;

      FCallback :TPVDDecodeCallback2;
      FCallbackContext :Pointer;
      FLastProgress :Integer;
      FProgressStep :Integer;
//    FInterrupt :Boolean;

     {$ifdef bTrace}
      procedure MetadataCallback(const aName :TString; const aVal :PROPVARIANT; var aMore :Boolean);
     {$endif bTrace}
    end;



  destructor TView.Destroy; {override;}
  begin
    FreePage;
    inherited Destroy;
  end;


  class function TView.CreateByFile(AManager :TManager; const AName :TString) :TView;
  begin
    Result := TView.Create;
    Result.FFactory := AManager.FFactory;
    if Result.LoadFile(AName) then
      {}
    else
      FreeObj(Result);
  end;


  function TView.LoadFile(const AName :TString) :Boolean;
  var
    vRes :HResult;
    vInfo :IWICBitmapDecoderInfo;
  begin
    Result := False;

   {$ifdef bTrace}
    TraceF('WIC Load: "%s"...', [AName]);
   {$endif bTrace}
    vRes := FFactory.CreateDecoderFromFilename(PTChar(AName), nil{AnyVendor}, GENERIC_READ, WICDecodeMetadataCacheOnDemand, FDecoder);
    if vRes <> S_OK then begin
     {$ifdef bTrace}
      TraceF('  Error, Code=%x', [vRes]);
     {$endif bTrace}
      Exit;
    end;

    if (FDecoder.GetFrameCount(FFrames) <> S_OK) or (FFrames = 0{???}) then
      Exit;
    if FDecoder.GetContainerFormat(FFmtID) = S_OK then
      FFmtName := NameOfFormat(FFmtID);
//  if FFmtName = '' then
//    FFmtName := GetFriendlyName(FFactory, FFmtID);
//    FFmtName := WICGetShortName(FFmtID);
//    FFmtName := GUIDToString(FFmtID);

    if FDecoder.GetDecoderInfo(vInfo) = S_OK then
      FDescr := GetFriendlyName(vInfo);

   {$ifdef bTrace}
    TraceF('  OK, Format=%s, Frames=%d', [FFmtName {GetFriendlyName(FFactory, vFmtID)}, FFrames]);
   {$endif bTrace}

    FCurFrame := -1;
    Result := True;
  end;


 {$ifdef bTrace}
  procedure TView.MetadataCallback(const aName :TString; const aVal :PROPVARIANT; var aMore :Boolean);
  begin
    TraceF('%s = %s', [aName, VarAsStr(aVal)]);
  end;
 {$endif bTrace}


  procedure TView.SetPage(AIndex :Integer);
  var
    vCX, vCY :Cardinal;
    vOrient :Integer;
//  vMetadata :IWICMetadataQueryReader;
  begin
    if FCurFrame = AIndex then
      Exit;

    WicCheck(FDecoder.GetFrame(AIndex, FFrame));

    FCurFrame := AIndex;
    FreeIntf(FBitmap);
    OleCheck(FFrame.QueryInterface(IID_IWICBitmapSource, FBitmap));

    if FBitmap.GetSize(vCX, vCY) = S_OK then
      FSize := Size(vCX, vCY);
    if FBitmap.GetPixelFormat(FPixFmt) = S_OK then
      FPixBPP := PixelsFromFormat(FFactory, FPixFmt);

    FDelay  := 0;
    FAlpha  :=
      IsEqualGUID(FPixFmt, GUID_WICPixelFormat32bppBGRA) or
      IsEqualGUID(FPixFmt, GUID_WICPixelFormat8bppAlpha);
    FTransp := FAlpha;
    FOrient0 := 0;

    if FFrame.GetMetadataQueryReader(FMetadata) = S_OK then begin
     {$ifdef bTrace}
      EnumMetadata(FMetadata, '', MetadataCallback, True);
     {$endif bTrace}

      if IsEqualGUID(FFmtID, GUID_ContainerFormatGIF) then begin
        MetaQueryLog(FMetadata, '/grctlext/TransparencyFlag', FTransp);  
        MetaQueryInt(FMetadata, '/grctlext/Delay', FDelay);
        FDelay := FDelay * 10;
      end else
      if IsEqualGUID(FFmtID, GUID_ContainerFormatPNG) then begin
        FTransp := True; {???}
//      if MetaQueryInt(vMetadata, '/bKGD/BackgroundColor', vColor) then
//      if MetaExist(vMetadata, '/tRNS') then
//      if MetaExist(vMetadata, '/iCCP') then
//      if MetaExist(vMetadata, '/bKGD') then
//        FTransp := True;
      end;

      if IsEqualGUID(FFmtID, GUID_ContainerFormatJpeg) then begin
        if MetaQueryInt(FMetadata, '/app1/ifd/{ushort=274}', vOrient) then
          FOrient0 := vOrient;
      end else
      begin
        if MetaQueryInt(FMetadata, '/ifd/{ushort=274}', vOrient) then
          FOrient0 := vOrient;
      end;
    end;
  end;


//typedef HRESULT (*PFNProgressNotification) (
//   LPVOID pvData,
//   ULONG uFrameNum,
//   WICProgressOperation operation,
//   double dblProgress );

  function MyProgress(pvData :Pointer; uFrameNum :ULONG; Operation :WICProgressOperation; dblProgress :Double) :HResult; stdcall;
  var
    vPercent :Integer;
  begin
    Result := 0;
//  Trace('MyProgress: Frame=%d, Operation=%d, Percent=%g', [uFrameNum, Operation, dblProgress]);
    with TView(pvData) do
      if Assigned(FCallback) then begin

        vPercent := Round(dblProgress * 100);
        if vPercent < FLastProgress then
          Inc(FProgressStep);
        FLastProgress := vPercent;

//      Trace('MyProgress: %d, %d', [vPercent, FProgressStep]);
        if not FCallback(FCallbackContext, (100 * FProgressStep) + vPercent, 100, nil) then
          Result := WINCODEC_ERR_ABORTED;
      end;
  end;


// const
//   IID_IWICBitmapSource1  :TGUID = '{00000120-a8f2-4877-ba0a-fd2b6645ffff}';

(*
  procedure CorrectBoundEx(var ASize :TSize; const ALimit :TSize);
  var
    vScale :TFloat;
  begin
    if (ASize.cx > ALimit.cx) or (ASize.cy > ALimit.cy) then begin
      vScale := FloatMin( ALimit.cx / ASize.cx, ALimit.cy / ASize.cy);
      ASize.cx := Round(ASize.cx * vScale);
      ASize.cy := Round(ASize.cy * vScale);
    end;
  end;
*)

(*
  procedure TView.DecodePage(ACX, ACY :Integer; AThumbnail :Boolean);
  var
    vScaler :IWICBitmapScaler;
    vConverter :IWICFormatConverter;
    vBufSize :Integer;
    vPixID :TGUID;
    vCX, vCY :Cardinal;
    vProgress :IWICBitmapCodecProgressNotification;
  begin
    FSize2 := FSize;
    if (ACX > 0) and (ACY > 0) then
      CorrectBoundEx(FSize2, Size(ACX, ACY));

    if AThumbnail then begin

      if not Succeeded(FFrame.GetThumbnail(FBitmap2)) then
        Exit;

      if FBitmap2.GetSize(vCX, vCY) = S_OK then
        FSize2 := Size(vCX, vCY);
      WicCheck(FBitmap2.GetPixelFormat(vPixID));
      FPixBPP2 := PixelsFromFormat(FFactory, vPixID);
      FAlpha := IsEqualGUID(vPixID, GUID_WICPixelFormat32bppBGRA)

    end else
    if (FTransp = FAlpha) and
    ((FSize2.CX = FSize.CX) and (FSize2.CY = FSize.CY)) and
    (
      {$ifdef b64}
       False   { Иначе иногда почему-то падает. Пока не разобрался. }
      {$else}
//     IsEqualGUID(FPixFmt, GUID_WICPixelFormat32bppCMYK) or
       IsEqualGUID(FPixFmt, GUID_WICPixelFormat24bppBGR) or
       IsEqualGUID(FPixFmt, GUID_WICPixelFormat32bppBGR) or
       IsEqualGUID(FPixFmt, GUID_WICPixelFormat32bppBGRA)
      {$endif b64}
    )
    then begin
      { Конвертация формата не требуется }
      FBitmap2 := FBitmap;
      FPixBPP2 := FPixBPP;
    end else
    begin
      { Сконвертируем в формат, поддерживаемый Review }

     {$ifdef bTrace}
      TraceBeg('ConvertFormat...');
     {$endif bTrace}

      { Create a BitmapScaler }
      WicCheck(FFactory.CreateBitmapScaler(vScaler));
      { Initialize the bitmap scaler from the original bitmap map bits }
      WicCheck(vScaler.Initialize(FBitmap, FSize2.CX, FSize2.CY, WICBitmapInterpolationModeFant));

      { Format convert the bitmap into convenient pixel format for GDI rendering }
      if FTransp then
        vPixID := GUID_WICPixelFormat32bppBGRA
      else
        vPixID := GUID_WICPixelFormat24bppBGR;
      WicCheck(FFactory.CreateFormatConverter(vConverter));
      WicCheck(vConverter.Initialize(vScaler, vPixID, WICBitmapDitherTypeNone, nil, 0, WICBitmapPaletteTypeCustom));

      { Store the converted bitmap as ppToRenderBitmapSource }
      OleCheck(vConverter.QueryInterface(IID_IWICBitmapSource, FBitmap2));

     {$ifdef bTrace}
      TraceEnd('  done');
     {$endif bTrace}

      WicCheck(FBitmap2.GetPixelFormat(vPixID));
      FPixBPP2 := PixelsFromFormat(FFactory, vPixID);
      FAlpha := IsEqualGUID(vPixID, GUID_WICPixelFormat32bppBGRA)
    end;

    FRowSize := FSize2.CX * IntIf(FPixBPP2 = 24, 3, 4);
    FRowSize := (FRowSize + 3) div 4 * 4; { Выравниваем, чтобы избежать RealignBits в CreateBitmap }
    vBufSize := FRowSize * FSize2.CY;
    FBuffer := MemAlloc(vBufSize);

    FLastProgress := 0;
    FProgressStep := 0;
    FDecoder.QueryInterface(IWICBitmapCodecProgressNotification, vProgress);
    if vProgress <> nil then
      vProgress.RegisterProgressNotification(MyProgress, Self, WICProgressOperationAll or WICProgressNotificationAll);

   {$ifdef bTrace}
    TraceBegF('CopyPixels (%d x %d, %d K)...', [FSize2.CX, FSize2.CY, vBufSize div 1024]);
   {$endif bTrace}
    WicCheck(FBitmap2.CopyPixels(nil, FRowSize, vBufSize, FBuffer));
   {$ifdef bTrace}
    TraceEnd('  done');
   {$endif bTrace}
  end;
*)

  procedure TView.DecodePage(ACX, ACY :Integer; AThumbnail :Boolean);
  var
    vScaler :IWICBitmapScaler;
    vConverter :IWICFormatConverter;
    vBufSize :Integer;
    vPixFmt, vNewPixFmt :TGUID;
    vCX, vCY :Cardinal;
    vProgress :IWICBitmapCodecProgressNotification;
  begin
    FSize2 := FSize;
    if (ACX > 0) and (ACY > 0) then
//    CorrectBoundEx(FSize2, Size(ACX, ACY));
      FSize2 := Size(ACX, ACY);

    FThumbnail := False;
    if AThumbnail then begin
      { Извлекаем эскиз }
      if not Succeeded(FFrame.GetThumbnail(FBitmap2)) then
        Exit;

      if FBitmap2.GetSize(vCX, vCY) = S_OK then
        FSize2 := Size(vCX, vCY);
      WicCheck(FBitmap2.GetPixelFormat(vPixFmt));
      FThumbnail := True;
    end else
    begin
      FBitmap2 := FBitmap;
      vPixFmt := FPixFmt;

      if (FSize2.CX <> FSize.CX) or (FSize2.CY <> FSize.CY) then begin
       {$ifdef bTrace}
        TraceBeg('Scale image...');
       {$endif bTrace}

        { Create a BitmapScaler }
        WicCheck(FFactory.CreateBitmapScaler(vScaler));
        { Initialize the bitmap scaler from the original bitmap map bits }
        WicCheck(vScaler.Initialize(FBitmap, FSize2.CX, FSize2.CY, WICBitmapInterpolationModeFant));

        { Store the converted bitmap as ppToRenderBitmapSource }
        OleCheck(vScaler.QueryInterface(IID_IWICBitmapSource, FBitmap2));

       {$ifdef bTrace}
        TraceEnd('  done');
       {$endif bTrace}
      end;
    end;

    if (FTransp <> FAlpha) or not
    (
      {$ifdef b64}
       False   { Иначе иногда почему-то падает. Пока не разобрался. }
      {$else}
//     IsEqualGUID(vPixFmt, GUID_WICPixelFormat32bppCMYK) or
       IsEqualGUID(vPixFmt, GUID_WICPixelFormat24bppBGR) or
       IsEqualGUID(vPixFmt, GUID_WICPixelFormat32bppBGR) or
       IsEqualGUID(vPixFmt, GUID_WICPixelFormat32bppBGRA)
      {$endif b64}
    )
    then begin
      { Format convert the bitmap into convenient pixel format for GDI rendering }
      if FTransp then
        vNewPixFmt := GUID_WICPixelFormat32bppBGRA
      else
        vNewPixFmt := GUID_WICPixelFormat24bppBGR;

     {$ifdef bTrace}
      TraceBegF('ConvertFormat (%s -> %s)...', [GetFriendlyName(FFactory, vPixFmt), GetFriendlyName(FFactory, vNewPixFmt)]);
     {$endif bTrace}

      WicCheck(FFactory.CreateFormatConverter(vConverter));
      WicCheck(vConverter.Initialize(FBitmap2, vNewPixFmt, WICBitmapDitherTypeNone, nil, 0, WICBitmapPaletteTypeCustom));

      { Store the converted bitmap as ppToRenderBitmapSource }
      OleCheck(vConverter.QueryInterface(IID_IWICBitmapSource, FBitmap2));

      WicCheck(FBitmap2.GetPixelFormat(vPixFmt));

     {$ifdef bTrace}
      TraceEnd('  done');
     {$endif bTrace}
    end;

    FPixBPP2 := PixelsFromFormat(FFactory, vPixFmt);
    FAlpha := IsEqualGUID(vPixFmt, GUID_WICPixelFormat32bppBGRA);

    FRowSize := FSize2.CX * IntIf(FPixBPP2 = 24, 3, 4);
    FRowSize := (FRowSize + 3) div 4 * 4; { Выравниваем, чтобы избежать RealignBits в CreateBitmap }
    vBufSize := FRowSize * FSize2.CY;
    FBuffer := MemAlloc(vBufSize);

    FLastProgress := 0;
    FProgressStep := 0;
    FDecoder.QueryInterface(IWICBitmapCodecProgressNotification, vProgress);
    if vProgress <> nil then
      vProgress.RegisterProgressNotification(MyProgress, Self, WICProgressOperationAll or WICProgressNotificationAll);

   {$ifdef bTrace}
    TraceBegF('CopyPixels (%d x %d, %s, %d K)...', [FSize2.CX, FSize2.CY, GetFriendlyName(FFactory, vPixFmt), vBufSize div 1024]);
   {$endif bTrace}
    WicCheck(FBitmap2.CopyPixels(nil, FRowSize, vBufSize, FBuffer));
   {$ifdef bTrace}
    TraceEnd('  done');
   {$endif bTrace}
  end;


  procedure TView.FreePage;
  begin
    MemFree(FBuffer);
    FreeIntf(FBitmap2);
//  FreeIntf(FBitmap);
  end;


  function TView.TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;
  var
    vIFD :TString;

    procedure LocIntTag(const aName :TString);
    var
      vIntTag :Integer;
    begin
      Result := MetaQueryInt(FMetadata, aName, vIntTag);
      if Result then begin
        aValue := Pointer(TIntPtr(vIntTag));
        aType := PVD_TagType_Int;
      end;
    end;

    procedure LocInt64Tag(const aName :TString);
    begin
      Result := MetaQueryInt64(FMetadata, aName, FInt64Tag);
      if Result then begin
        aValue := @FInt64Tag;
        aType := PVD_TagType_Int64;
      end;
    end;

    procedure LocStrTag(const aName :TString);
    begin
      Result := MetaQueryStr(FMetadata, aName, FStrTag);
      if Result then begin
        aValue := PTChar(FStrTag);
        aType := PVD_TagType_Str;
      end;
    end;

    procedure LocResolutionTag(const aName1, aName2 :TString);
    var
      vInt, vUnit :Integer;
      vInt64 :TInt64;
      vIsSM :Boolean;
    begin
      vIsSM := False; vInt := 0;
      Result := MetaQueryInt64(FMetadata, aName1, vInt64);
      if Result then begin
        with Int64Rec(vInt64) do
          vInt := Trunc(Lo / Hi);
        if MetaQueryInt(FMetadata, vIFD + '{ushort=296}', vUnit) then
          vIsSM := vUnit = 3;
      end else
      if IsEqualGUID(FFmtID, GUID_ContainerFormatJpeg) then
        { units (1 byte) Units for the X and Y densities.
          units = 0: no units, X and Y specify the pixel aspect ratio
          units = 1: X and Y are dots per inch
          units = 2: X and Y are dots per cm }
        if MetaQueryInt(FMetadata, '/app0/{ushort=1}', vUnit) then
          if vUnit <> 0 then begin
            Result := MetaQueryInt(FMetadata, aName2, vInt);
            vIsSM := vUnit = 2;
          end;
      if Result then begin
        if vIsSM then
          { Разрешение в сантиметрах, пересчитываем в дюймы }
          vInt := Trunc(vInt * 2.54);
        aValue := Pointer(TIntPtr(vInt));
        aType := PVD_TagType_Int;
      end;
    end;

  begin
    Result := False;
    if FMetadata = nil then
      Exit;

    if IsEqualGUID(FFmtID, GUID_ContainerFormatJpeg) then
      vIFD := '/app1/ifd/'
    else
      vIFD := '/ifd/';

    case aCode of
      PVD_Tag_Description  : LocStrTag(vIFD + '{ushort=270}');
      PVD_Tag_Time         : LocStrTag(vIFD + 'exif/{ushort=36867}');  // '{ushort=36867}'
      PVD_Tag_EquipMake    : LocStrTag(vIFD + '{ushort=271}');
      PVD_Tag_EquipModel   : LocStrTag(vIFD + '{ushort=272}');
      PVD_Tag_Software     : LocStrTag(vIFD + '{ushort=305}');
      PVD_Tag_Author       : LocStrTag(vIFD + '{ushort=315}');
      PVD_Tag_Copyright    : LocStrTag(vIFD + '{ushort=33432}');

      PVD_Tag_ExposureTime : LocInt64Tag(vIFD + 'exif/{ushort=33434}');
      PVD_Tag_FNumber      : LocInt64Tag(vIFD + 'exif/{ushort=33437}');
      PVD_Tag_FocalLength  : LocInt64Tag(vIFD + 'exif/{ushort=37386}');
      PVD_Tag_ISO          : LocIntTag(vIFD + 'exif/{ushort=34855}');
      PVD_Tag_Flash        : LocIntTag(vIFD + 'exif/{ushort=37385}');

      PVD_Tag_XResolution  : LocResolutionTag(vIFD + '{ushort=282}', '/app0/{ushort=2}');
      PVD_Tag_YResolution  : LocResolutionTag(vIFD + '{ushort=283}', '/app0/{ushort=3}');
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
    pPluginInfo.pName := 'WIC';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2013, Maxim Rusov';
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
        vView.SetPage(0);

        pImageInfo.pFormatName := PTChar(vView.FFmtName);
//      pImageInfo.pCompression :=
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
  begin
    Result := False; FLastError := '';
    try
      with TView(pImageContext) do begin
        SetPage(pPageInfo.iPage);

        pPageInfo.lWidth := FSize.cx;
        pPageInfo.lHeight := FSize.cy;
        pPageInfo.nBPP := FPixBPP;
        pPageInfo.lFrameTime := FDelay;
        pPageInfo.Orientation := FOrient0;

        Result := True;
      end;
    except
      on E :Exception do begin
        FLastError := E.Message;
        pPageInfo.nErrNumber := DWORD(-1);
      end;
    end;
  end;


  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  begin
    Result := False; FLastError := '';
    try
      with TView(pImageContext) do begin
        SetPage(pDecodeInfo.iPage);

        FCallback := DecodeCallback;
        FCallbackContext := pDecodeCallbackContext;

        if pDecodeInfo.Flags and PVD_IDF_THUMBONLY <> 0 then begin
          DecodePage(pDecodeInfo.lWidth, pDecodeInfo.lHeight, True);
          if FBuffer = nil then
            Exit;
        end else
        if pDecodeInfo.Flags and PVD_IDF_THUMBFIRST <> 0 then begin
          DecodePage(pDecodeInfo.lWidth, pDecodeInfo.lHeight, True);
          if FBuffer = nil then
            DecodePage(pDecodeInfo.lWidth, pDecodeInfo.lHeight, False);
        end else
          DecodePage(pDecodeInfo.lWidth, pDecodeInfo.lHeight, False);

        pDecodeInfo.lWidth := FSize2.cx;
        pDecodeInfo.lHeight := FSize2.cy;
        pDecodeInfo.nBPP := FPixBPP2;
        pDecodeInfo.Flags := IntIf(FAlpha, PVD_IDF_ALPHA, 0) or IntIf(FThumbnail, PVD_IDF_THUMBNAIL, 0);
        pDecodeInfo.ColorModel := IntIf(FAlpha, PVD_CM_BGRA, PVD_CM_BGR);

        pDecodeInfo.lImagePitch := FRowSize;
        pDecodeInfo.pImage := FBuffer;
        pDecodeInfo.pPalette := nil;

        pDecodeInfo.Orientation := FOrient0;

        Result := True;
      end;
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


(*
  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; var aTagCount :Integer; var aTags :PPvdTagArray) :Integer; stdcall;
  begin
    Result := 0;
    try
      with TView(pImageContext) do begin
        case aCmd of
          PVD_TagCmd_Get  : {};
          PVD_TagCmd_Free : {};
        end;
      end;
    except
      on E :Exception do
        FLastError := E.Message;
    end;
  end;
*)

  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;
  begin
    Result := False;
    try
      with TView(pImageContext) do
        if aCmd = PVD_TagCmd_Get then begin
          aType := 0; aValue := nil;
          Result := TagInfo(aCode, aType, aValue);
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


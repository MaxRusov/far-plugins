{$I Defines.inc}

unit GDIImageUtil;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    MixTypes,
    MixUtils,
    MixStrings,
    GDIPAPI,
    GDIPOBJ;


  type
    TMemDC = class(TObject)
    public
      constructor Create(ADC :HDC; W, H :Integer);
      destructor Destroy; override;

      procedure Clear;

      procedure Transform(AOrient :Integer);

    private
      FDC :HDC;
      FWidth, FHeight :Integer;
      FBMP, FOldBmp :HBitmap;
      FBrush, FOldBrush :HBrush;

    public
      property DC :HDC read FDC;
      property Width :Integer read FWidth;
      property Height :Integer read FHeight;
    end;

  procedure GDIStretchDraw(ADC :HDC; const ADstRect :TGPRect; ASrcDC :TMemDC; const ASrcRect :TGPRect; ASmooth :Boolean = True);
  procedure GDIPlusStretchDraw(ADC :HDC; const ADstRect :TGPRect; ASrcDC :TMemDC; const ASrcRect :TGPRect; ASmooth :Boolean = True);

  procedure GradientFillRect(AHandle :THandle; const ARect :TRect; AColor1, AColor2 :DWORD; AVert :Boolean);

  function GDIPlusErrorMessage(AStatus :TStatus) :AnsiString;
  procedure GDICheck(ARes :TStatus);

  function GetEncoderClsid(const AFormat :WideString; out pClsid: TGUID) :Integer;

  function GetImgFmtName(AGUID :TGUID) :AnsiString;
  function GetImagePropName(id :ULONG) :AnsiString;

  function GetExifTagValueAsInt(AImage :TGPImage; AID :ULONG; var AValue :Integer) :Boolean;
  procedure SetExifTagValueInt(AImage :TGPImage; AID :ULONG; AValue :Word);

  function GetFrameCount(AImage :TGPImage; ADimID :PGUID; ADelays :PPointer {^PPropertyItem}; ADelCount :PInteger) :Integer;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TMemDC                                                                      }
 {-----------------------------------------------------------------------------}

  function CreateScreenCompatibleBitmap(DX, DY :Integer) :HBitmap;
  var
    vDC :HDC;
  begin
    vDC := GetDC(0);
    try
      Result := CreateCompatibleBitmap(vDC, DX, DY);
      ApiCheck(Result <> 0);
    finally
      ReleaseDC(0, vDC);
    end;
  end;


  constructor TMemDC.Create(ADC :HDC; W, H :Integer);
  begin
    FWidth := W;
    FHeight := H;

    FBMP := CreateScreenCompatibleBitmap(W, H);
    FDC := CreateCompatibleDC(0);
    FOldBmp := SelectObject(FDC, FBmp);

    if ADC <> 0 then begin
      FBrush := GetCurrentObject(ADC, OBJ_BRUSH);
      FOldBrush := SelectObject(FDC, FBrush);
      Clear;
    end;
  end;

  destructor TMemDC.Destroy; {override;}
  begin
    if FOldBrush <> 0 then
      SelectObject(FDC, FOldBrush);
    if FOldBmp <> 0 then
      SelectObject(FDC, FOldBmp);
    if FBMP <> 0 then
      DeleteObject(FBMP);
    if FDC <> 0 then
      DeleteDC(FDC);
  end;


  procedure TMemDC.Clear;
  begin
    FillRect(FDC, Bounds(0, 0, FWIdth, FHeight), FBrush);
  end;


  procedure TMemDC.Transform(AOrient :Integer);
  var
    I, J, vSize, vWidth1, vHeight1 :Integer;
    vInfo :TBitmapInfo;
    vPtr, vNew :Pointer;
    vSrc :PRGBQuad;
    vNewBmp :HBitmap;
  begin
    if AOrient <= 1 then
      Exit;

    vSize := FWidth * FHeight * 4;
    vPtr := MemAlloc(vSize);
    try
      FillChar(vInfo, SizeOf(vInfo), 0);
      vInfo.bmiHeader.biSize := sizeof(vInfo.bmiHeader);
      vInfo.bmiHeader.biWidth := FWidth;
      vInfo.bmiHeader.biHeight := FHeight;
      vInfo.bmiHeader.biPlanes := 1;
      vInfo.bmiHeader.biBitCount := 32;
      vInfo.bmiHeader.biCompression := BI_RGB;
      if GetDIBits(FDC, FBMP, 0, FHeight, vPtr, vInfo, DIB_RGB_COLORS) = 0 then
        ApiCheck(False);

      vNew := MemAlloc(vSize);
      try
        vSrc := vPtr;

        for J := 0 to FHeight - 1 do begin
          for I := 0 to FWidth - 1 do begin
            case AOrient of
              2: PRGBQuad(PAnsiChar(vNew) + (J * FWidth * 4) + ((FWidth - I - 1) * 4))^ := vSrc^;                   {X}
              3: PRGBQuad(PAnsiChar(vNew) + ((FHeight - J - 1) * FWidth * 4) + ((FWidth - I - 1) * 4))^ := vSrc^;   {LL: 180 }
              4: PRGBQuad(PAnsiChar(vNew) + ((FHeight - J - 1) * FWidth * 4) + (I * 4))^ := vSrc^;                  {Y}

              5: PRGBQuad(PAnsiChar(vNew) + ((FWidth - I - 1) * FHeight * 4) + ((FHeight - J - 1) * 4))^ := vSrc^;
              6: PRGBQuad(PAnsiChar(vNew) + ((FWidth - I - 1) * FHeight * 4) + (J * 4))^ := vSrc^;                  {R: 90 }
              7: PRGBQuad(PAnsiChar(vNew) + (I * FHeight * 4) + (J * 4))^ := vSrc^;
              8: PRGBQuad(PAnsiChar(vNew) + (I * FHeight * 4) + ((FHeight - J - 1) * 4))^ := vSrc^;                 {L: -90 }
            end;
            Inc(PAnsiChar(vSrc), SizeOf(vSrc^));
          end;
        end;

        if AOrient in [5,6,7,8] then begin
          vWidth1 := FHeight;
          vHeight1 := FWidth;
        end else
        begin
          vWidth1 := FWidth;
          vHeight1 := FHeight;
        end;

        MemFree(vPtr);

        vNewBmp := CreateScreenCompatibleBitmap(vWidth1, vHeight1);
        if SelectObject(FDC, vNewBmp) <> 0 then begin
          DeleteObject(FBMP);
          FBMP := vNewBmp;

          vInfo.bmiHeader.biSize := sizeof(vInfo.bmiHeader);
          vInfo.bmiHeader.biWidth := vWidth1;
          vInfo.bmiHeader.biHeight := vHeight1;
          vInfo.bmiHeader.biPlanes := 1;
          vInfo.bmiHeader.biBitCount := 32;
          vInfo.bmiHeader.biCompression := BI_RGB;
          SetDIBits(FDC, FBMP, 0, vHeight1, vNew, vInfo, DIB_RGB_COLORS);

          FWidth := vWidth1;
          FHeight := vHeight1;
        end else
          DeleteObject(vNewBMP);

      finally
        MemFree(vNew);
      end;

    finally
      MemFree(vPtr);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure GDIStretchDraw(ADC :HDC; const ADstRect :TGPRect; ASrcDC :TMemDC; const ASrcRect :TGPRect; ASmooth :Boolean = True);
  begin
//  if ASmooth then
//    TraceBegF('GDIStretchDraw. Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d...',
//      [ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height,
//       ADstRect.X, ADstRect.Y, ADstRect.Width, ADstRect.Height]);

    if ASmooth then
      SetStretchBltMode(ADC, HALFTONE)
    else
      SetStretchBltMode(ADC, COLORONCOLOR);

    StretchBlt(
      ADC,
      ADstRect.X, ADstRect.Y, ADstRect.Width, ADstRect.Height,
      ASrcDC.DC,
      ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height,
      SRCCOPY);

//  if ASmooth then
//    TraceEnd('  done');
  end;


  procedure GDIPlusStretchDraw(ADC :HDC; const ADstRect :TGPRect; ASrcDC :TMemDC; const ASrcRect :TGPRect; ASmooth :Boolean = True);
  var
    vBmp :TGPBitmap;
    vGraphics :TGPGraphics;
  begin
//  TraceBegF('GDIPlusStretchDraw. Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d...',
//    [ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height,
//     ADstRect.X, ADstRect.Y, ADstRect.Width, ADstRect.Height]);

    vBmp := TGPBitmap.Create(ASrcDC.FBMP, 0);
    try
      vGraphics := TGPGraphics.Create(ADC);
      try
(*      if not ASmooth then begin
          vGraphics.SetCompositingMode(CompositingModeSourceCopy);
          vGraphics.SetCompositingQuality(CompositingQualityHighSpeed);
          vGraphics.SetSmoothingMode(SmoothingModeHighSpeed);
          vGraphics.SetInterpolationMode(InterpolationModeLowQuality);
        end else
        begin
          vGraphics.SetSmoothingMode(SmoothingModeHighQuality);
        end; *)

        vGraphics.DrawImage(vBmp, ADstRect, ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height, UnitPixel);

      finally
        FreeObj(vGraphics);
      end;
    finally
      FreeObj(vBmp);
    end;

//  TraceEnd('  done');
  end;

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    RGBRec = packed record
      Red, Green, Blue, Dummy :Byte;
    end;


  procedure GradientFillRect(AHandle :THandle; const ARect :TRect; AColor1, AColor2 :DWORD; AVert :Boolean);
  const
    FillFlag :Array[Boolean] of Integer = (GRADIENT_FILL_RECT_H, GRADIENT_FILL_RECT_V);
  var
    VA :array[0..1] of TTriVertex;
    GR :TGradientRect;
  begin
    VA[0].X := ARect.Left;
    VA[0].Y := ARect.Top;
    with RGBRec({ColorToRGB}(AColor1)) do begin
      VA[0].Red := Red*255;
      VA[0].Green := Green*255;
      VA[0].Blue := Blue*255;
      VA[0].Alpha := 0;
    end;

    VA[1].X := ARect.Right;
    VA[1].Y := ARect.Bottom;
    with RGBRec({ColorToRGB}(AColor2)) do begin
      VA[1].Red := Red*255;
      VA[1].Green := Green*255;
      VA[1].Blue := Blue*255;
      VA[1].Alpha := 0;
    end;

    GR.UpperLeft := 0;
    GR.LowerRight := 1;
    GradientFill(AHandle, VA[0], 2, @GR, 1, FillFlag[AVert]);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}


  function GDIPlusErrorMessage(AStatus :TStatus) :AnsiString;
  begin
    case AStatus of
      Ok                        : result := 'Ok';
      GenericError              : result := 'Generic Error';
      InvalidParameter          : result := 'Invalid Parameter';
      OutOfMemory               : result := 'Out Of Memory';
      ObjectBusy                : result := 'Object Busy';
      InsufficientBuffer        : result := 'Insufficient Buffer';
      NotImplemented            : result := 'Not Implemented';
      Win32Error                : result := 'Win32 Error';
      WrongState                : result := 'Wrong State';
      Aborted                   : result := 'Aborted';
      FileNotFound              : result := 'File Not Found';
      ValueOverflow             : result := 'Value Overflow';
      AccessDenied              : result := 'Access Denied';
      UnknownImageFormat        : result := 'Unknown Image Format';
      FontFamilyNotFound        : result := 'Font Family Not Found';
      FontStyleNotFound         : result := 'Font Style Not Found';
      NotTrueTypeFont           : result := 'Not TrueType Font';
      UnsupportedGdiplusVersion : result := 'Unsupported Gdiplus Version';
      GdiplusNotInitialized     : result := 'Gdiplus Not Initialized';
      PropertyNotFound          : result := 'Property Not Found';
      PropertyNotSupported      : result := 'Property Not Supported';
    else
      result := '<UnKnown>';
    end;
  end;

  
  procedure GDICheck(ARes :TStatus);
  begin
    if ARes <> Ok then begin
     {$ifdef bTraceError}
      SetErrorAddress(ReturnAddr);
     {$endif bTraceError}
      AppError(GDIPlusErrorMessage(ARes));
    end;
  end;


  function GetEncoderClsid(const AFormat :WideString; out pClsid: TGUID) :Integer;
  Type
    ArrIMgInf = array of TImageCodecInfo;
  var
    i, vNum, vSize :UINT;
    vImageCodecInfo :PImageCodecInfo;
  begin
    Result := -1;

    vNum  := 0; { number of image encoders }
    vSize := 0; { size of the image encoder array in bytes }

    GetImageEncodersSize(vNum, vSize);
    if vSize = 0 then
      Exit;

    vImageCodecInfo := MemAlloc(vSize);
    try
      GetImageEncoders(vNum, vSize, vImageCodecInfo);

      for i := 0 to vNum - 1 do begin
        if ArrIMgInf(vImageCodecInfo)[i].MimeType = AFormat then begin
          pClsid := ArrIMgInf(vImageCodecInfo)[i].Clsid;
          Result := i;
          Break;
        end;
      end;

    finally
      MemFree(vImageCodecInfo);
    end;
  end;


  function GetImgFmtName(AGUID :TGUID) :AnsiString;
  begin
    Result := '';
    if IsEqualGUID(AGUID, ImageFormatBMP) then
      Result := 'BMP'
    else
    if IsEqualGUID(AGUID, ImageFormatJPEG) then
      Result := 'JPEG'
    else
    if IsEqualGUID(AGUID, ImageFormatPNG) then
      Result := 'PNG'
    else
    if IsEqualGUID(AGUID, ImageFormatGIF) then
      Result := 'GIF'
    else
    if IsEqualGUID(AGUID, ImageFormatTIFF) then
      Result := 'TIFF'
    else
    if IsEqualGUID(AGUID, ImageFormatEXIF) then
      Result := 'EXIF'
    else
    if IsEqualGUID(AGUID, ImageFormatIcon) then
      Result := 'Icon'
    else
    if IsEqualGUID(AGUID, ImageFormatEMF) then
      Result := 'EMF'
    else
    if IsEqualGUID(AGUID, ImageFormatWMF) then
      Result := 'WMF';
//  else
//  if AGUID = ImageFormatMemoryBMP then
//    Result := ''
//  else
//  if AGUID = ImageFormatUndefined then
//    Result := '';
  end;



  function GetImagePropName(id :ULONG) :AnsiString;
  begin
    case id of
      PropertyTagExifIFD                        : result := 'ExifIFD';
      PropertyTagGpsIFD                         : result := 'GpsIFD';
      PropertyTagNewSubfileType                 : result := 'NewSubfileType';
      PropertyTagSubfileType                    : result := 'SubfileType';
      PropertyTagImageWidth                     : result := 'ImageWidth';
      PropertyTagImageHeight                    : result := 'ImageHeight';
      PropertyTagBitsPerSample                  : result := 'BitsPerSample';
      PropertyTagCompression                    : result := 'Compression';
      PropertyTagPhotometricInterp              : result := 'PhotometricInterp';
      PropertyTagThreshHolding                  : result := 'ThreshHolding';
      PropertyTagCellWidth                      : result := 'CellWidth';
      PropertyTagCellHeight                     : result := 'CellHeight';
      PropertyTagFillOrder                      : result := 'FillOrder';
      PropertyTagDocumentName                   : result := 'DocumentName';
      PropertyTagImageDescription               : result := 'ImageDescription';
      PropertyTagEquipMake                      : result := 'EquipMake';
      PropertyTagEquipModel                     : result := 'EquipModel';
      PropertyTagStripOffsets                   : result := 'StripOffsets';
      PropertyTagOrientation                    : result := 'Orientation';
      PropertyTagSamplesPerPixel                : result := 'SamplesPerPixel';
      PropertyTagRowsPerStrip                   : result := 'RowsPerStrip';
      PropertyTagStripBytesCount                : result := 'StripBytesCount';
      PropertyTagMinSampleValue                 : result := 'MinSampleValue';
      PropertyTagMaxSampleValue                 : result := 'MaxSampleValue';
      PropertyTagXResolution                    : result := 'XResolution';
      PropertyTagYResolution                    : result := 'YResolution';
      PropertyTagPlanarConfig                   : result := 'PlanarConfig';
      PropertyTagPageName                       : result := 'PageName';
      PropertyTagXPosition                      : result := 'XPosition';
      PropertyTagYPosition                      : result := 'YPosition';
      PropertyTagFreeOffset                     : result := 'FreeOffset';
      PropertyTagFreeByteCounts                 : result := 'FreeByteCounts';
      PropertyTagGrayResponseUnit               : result := 'GrayResponseUnit';
      PropertyTagGrayResponseCurve              : result := 'GrayResponseCurve';
      PropertyTagT4Option                       : result := 'T4Option';
      PropertyTagT6Option                       : result := 'T6Option';
      PropertyTagResolutionUnit                 : result := 'ResolutionUnit';
      PropertyTagPageNumber                     : result := 'PageNumber';
      PropertyTagTransferFuncition              : result := 'TransferFuncition';
      PropertyTagSoftwareUsed                   : result := 'SoftwareUsed';
      PropertyTagDateTime                       : result := 'DateTime';
      PropertyTagArtist                         : result := 'Artist';
      PropertyTagHostComputer                   : result := 'HostComputer';
      PropertyTagPredictor                      : result := 'Predictor';
      PropertyTagWhitePoint                     : result := 'WhitePoint';
      PropertyTagPrimaryChromaticities          : result := 'PrimaryChromaticities';
      PropertyTagColorMap                       : result := 'ColorMap';
      PropertyTagHalftoneHints                  : result := 'HalftoneHints';
      PropertyTagTileWidth                      : result := 'TileWidth';
      PropertyTagTileLength                     : result := 'TileLength';
      PropertyTagTileOffset                     : result := 'TileOffset';
      PropertyTagTileByteCounts                 : result := 'TileByteCounts';
      PropertyTagInkSet                         : result := 'InkSet';
      PropertyTagInkNames                       : result := 'InkNames';
      PropertyTagNumberOfInks                   : result := 'NumberOfInks';
      PropertyTagDotRange                       : result := 'DotRange';
      PropertyTagTargetPrinter                  : result := 'TargetPrinter';
      PropertyTagExtraSamples                   : result := 'ExtraSamples';
      PropertyTagSampleFormat                   : result := 'SampleFormat';
      PropertyTagSMinSampleValue                : result := 'SMinSampleValue';
      PropertyTagSMaxSampleValue                : result := 'SMaxSampleValue';
      PropertyTagTransferRange                  : result := 'TransferRange';
      PropertyTagJPEGProc                       : result := 'JPEGProc';
      PropertyTagJPEGInterFormat                : result := 'JPEGInterFormat';
      PropertyTagJPEGInterLength                : result := 'JPEGInterLength';
      PropertyTagJPEGRestartInterval            : result := 'JPEGRestartInterval';
      PropertyTagJPEGLosslessPredictors         : result := 'JPEGLosslessPredictors';
      PropertyTagJPEGPointTransforms            : result := 'JPEGPointTransforms';
      PropertyTagJPEGQTables                    : result := 'JPEGQTables';
      PropertyTagJPEGDCTables                   : result := 'JPEGDCTables';
      PropertyTagJPEGACTables                   : result := 'JPEGACTables';
      PropertyTagYCbCrCoefficients              : result := 'YCbCrCoefficients';
      PropertyTagYCbCrSubsampling               : result := 'YCbCrSubsampling';
      PropertyTagYCbCrPositioning               : result := 'YCbCrPositioning';
      PropertyTagREFBlackWhite                  : result := 'REFBlackWhite';
      PropertyTagICCProfile                     : result := 'ICCProfile';
      PropertyTagGamma                          : result := 'Gamma';
      PropertyTagICCProfileDescriptor           : result := 'ICCProfileDescriptor';
      PropertyTagSRGBRenderingIntent            : result := 'SRGBRenderingIntent';
      PropertyTagImageTitle                     : result := 'ImageTitle';
      PropertyTagCopyright                      : result := 'Copyright';
      PropertyTagResolutionXUnit                : result := 'ResolutionXUnit';
      PropertyTagResolutionYUnit                : result := 'ResolutionYUnit';
      PropertyTagResolutionXLengthUnit          : result := 'ResolutionXLengthUnit';
      PropertyTagResolutionYLengthUnit          : result := 'ResolutionYLengthUnit';
      PropertyTagPrintFlags                     : result := 'PrintFlags';
      PropertyTagPrintFlagsVersion              : result := 'PrintFlagsVersion';
      PropertyTagPrintFlagsCrop                 : result := 'PrintFlagsCrop';
      PropertyTagPrintFlagsBleedWidth           : result := 'PrintFlagsBleedWidth';
      PropertyTagPrintFlagsBleedWidthScale      : result := 'PrintFlagsBleedWidthScale';
      PropertyTagHalftoneLPI                    : result := 'HalftoneLPI';
      PropertyTagHalftoneLPIUnit                : result := 'HalftoneLPIUnit';
      PropertyTagHalftoneDegree                 : result := 'HalftoneDegree';
      PropertyTagHalftoneShape                  : result := 'HalftoneShape';
      PropertyTagHalftoneMisc                   : result := 'HalftoneMisc';
      PropertyTagHalftoneScreen                 : result := 'HalftoneScreen';
      PropertyTagJPEGQuality                    : result := 'JPEGQuality';
      PropertyTagGridSize                       : result := 'GridSize';
      PropertyTagThumbnailFormat                : result := 'ThumbnailFormat';
      PropertyTagThumbnailWidth                 : result := 'ThumbnailWidth';
      PropertyTagThumbnailHeight                : result := 'ThumbnailHeight';
      PropertyTagThumbnailColorDepth            : result := 'ThumbnailColorDepth';
      PropertyTagThumbnailPlanes                : result := 'ThumbnailPlanes';
      PropertyTagThumbnailRawBytes              : result := 'ThumbnailRawBytes';
      PropertyTagThumbnailSize                  : result := 'ThumbnailSize';
      PropertyTagThumbnailCompressedSize        : result := 'ThumbnailCompressedSize';
      PropertyTagColorTransferFunction          : result := 'ColorTransferFunction';
      PropertyTagThumbnailData                  : result := 'ThumbnailData';
      PropertyTagThumbnailImageWidth            : result := 'ThumbnailImageWidth';
      PropertyTagThumbnailImageHeight           : result := 'ThumbnailImageHeight';
      PropertyTagThumbnailBitsPerSample         : result := 'ThumbnailBitsPerSample';
      PropertyTagThumbnailCompression           : result := 'ThumbnailCompression';
      PropertyTagThumbnailPhotometricInterp     : result := 'ThumbnailPhotometricInterp';
      PropertyTagThumbnailImageDescription      : result := 'ThumbnailImageDescription';
      PropertyTagThumbnailEquipMake             : result := 'ThumbnailEquipMake';
      PropertyTagThumbnailEquipModel            : result := 'ThumbnailEquipModel';
      PropertyTagThumbnailStripOffsets          : result := 'ThumbnailStripOffsets';
      PropertyTagThumbnailOrientation           : result := 'ThumbnailOrientation';
      PropertyTagThumbnailSamplesPerPixel       : result := 'ThumbnailSamplesPerPixel';
      PropertyTagThumbnailRowsPerStrip          : result := 'ThumbnailRowsPerStrip';
      PropertyTagThumbnailStripBytesCount       : result := 'ThumbnailStripBytesCount';
      PropertyTagThumbnailResolutionX           : result := 'ThumbnailResolutionX';
      PropertyTagThumbnailResolutionY           : result := 'ThumbnailResolutionY';
      PropertyTagThumbnailPlanarConfig          : result := 'ThumbnailPlanarConfig';
      PropertyTagThumbnailResolutionUnit        : result := 'ThumbnailResolutionUnit';
      PropertyTagThumbnailTransferFunction      : result := 'ThumbnailTransferFunction';
      PropertyTagThumbnailSoftwareUsed          : result := 'ThumbnailSoftwareUsed';
      PropertyTagThumbnailDateTime              : result := 'ThumbnailDateTime';
      PropertyTagThumbnailArtist                : result := 'ThumbnailArtist';
      PropertyTagThumbnailWhitePoint            : result := 'ThumbnailWhitePoint';
      PropertyTagThumbnailPrimaryChromaticities : result := 'ThumbnailPrimaryChromaticities';
      PropertyTagThumbnailYCbCrCoefficients     : result := 'ThumbnailYCbCrCoefficients';
      PropertyTagThumbnailYCbCrSubsampling      : result := 'ThumbnailYCbCrSubsampling';
      PropertyTagThumbnailYCbCrPositioning      : result := 'ThumbnailYCbCrPositioning';
      PropertyTagThumbnailRefBlackWhite         : result := 'ThumbnailRefBlackWhite';
      PropertyTagThumbnailCopyRight             : result := 'ThumbnailCopyRight';
      PropertyTagLuminanceTable                 : result := 'LuminanceTable';
      PropertyTagChrominanceTable               : result := 'ChrominanceTable';
      PropertyTagFrameDelay                     : result := 'FrameDelay';
      PropertyTagLoopCount                      : result := 'LoopCount';
      PropertyTagPixelUnit                      : result := 'PixelUnit';
      PropertyTagPixelPerUnitX                  : result := 'PixelPerUnitX';
      PropertyTagPixelPerUnitY                  : result := 'PixelPerUnitY';
      PropertyTagPaletteHistogram               : result := 'PaletteHistogram';
      PropertyTagExifExposureTime               : result := 'ExifExposureTime';
      PropertyTagExifFNumber                    : result := 'ExifFNumber';
      PropertyTagExifExposureProg               : result := 'ExifExposureProg';
      PropertyTagExifSpectralSense              : result := 'ExifSpectralSense';
      PropertyTagExifISOSpeed                   : result := 'ExifISOSpeed';
      PropertyTagExifOECF                       : result := 'ExifOECF';
      PropertyTagExifVer                        : result := 'ExifVer';
      PropertyTagExifDTOrig                     : result := 'ExifDTOrig';
      PropertyTagExifDTDigitized                : result := 'ExifDTDigitized';
      PropertyTagExifCompConfig                 : result := 'ExifCompConfig';
      PropertyTagExifCompBPP                    : result := 'ExifCompBPP';
      PropertyTagExifShutterSpeed               : result := 'ExifShutterSpeed';
      PropertyTagExifAperture                   : result := 'ExifAperture';
      PropertyTagExifBrightness                 : result := 'ExifBrightness';
      PropertyTagExifExposureBias               : result := 'ExifExposureBias';
      PropertyTagExifMaxAperture                : result := 'ExifMaxAperture';
      PropertyTagExifSubjectDist                : result := 'ExifSubjectDist';
      PropertyTagExifMeteringMode               : result := 'ExifMeteringMode';
      PropertyTagExifLightSource                : result := 'ExifLightSource';
      PropertyTagExifFlash                      : result := 'ExifFlash';
      PropertyTagExifFocalLength                : result := 'ExifFocalLength';
      PropertyTagExifMakerNote                  : result := 'ExifMakerNote';
      PropertyTagExifUserComment                : result := 'ExifUserComment';
      PropertyTagExifDTSubsec                   : result := 'ExifDTSubsec';
      PropertyTagExifDTOrigSS                   : result := 'ExifDTOrigSS';
      PropertyTagExifDTDigSS                    : result := 'ExifDTDigSS';
      PropertyTagExifFPXVer                     : result := 'ExifFPXVer';
      PropertyTagExifColorSpace                 : result := 'ExifColorSpace';
      PropertyTagExifPixXDim                    : result := 'ExifPixXDim';
      PropertyTagExifPixYDim                    : result := 'ExifPixYDim';
      PropertyTagExifRelatedWav                 : result := 'ExifRelatedWav';
      PropertyTagExifInterop                    : result := 'ExifInterop';
      PropertyTagExifFlashEnergy                : result := 'ExifFlashEnergy';
      PropertyTagExifSpatialFR                  : result := 'ExifSpatialFR';
      PropertyTagExifFocalXRes                  : result := 'ExifFocalXRes';
      PropertyTagExifFocalYRes                  : result := 'ExifFocalYRes';
      PropertyTagExifFocalResUnit               : result := 'ExifFocalResUnit';
      PropertyTagExifSubjectLoc                 : result := 'ExifSubjectLoc';
      PropertyTagExifExposureIndex              : result := 'ExifExposureIndex';
      PropertyTagExifSensingMethod              : result := 'ExifSensingMethod';
      PropertyTagExifFileSource                 : result := 'ExifFileSource';
      PropertyTagExifSceneType                  : result := 'ExifSceneType';
      PropertyTagExifCfaPattern                 : result := 'ExifCfaPattern';
      PropertyTagGpsVer                         : result := 'GpsVer';
      PropertyTagGpsLatitudeRef                 : result := 'GpsLatitudeRef';
      PropertyTagGpsLatitude                    : result := 'GpsLatitude';
      PropertyTagGpsLongitudeRef                : result := 'GpsLongitudeRef';
      PropertyTagGpsLongitude                   : result := 'GpsLongitude';
      PropertyTagGpsAltitudeRef                 : result := 'GpsAltitudeRef';
      PropertyTagGpsAltitude                    : result := 'GpsAltitude';
      PropertyTagGpsGpsTime                     : result := 'GpsGpsTime';
      PropertyTagGpsGpsSatellites               : result := 'GpsGpsSatellites';
      PropertyTagGpsGpsStatus                   : result := 'GpsGpsStatus';
      PropertyTagGpsGpsMeasureMode              : result := 'GpsGpsMeasureMode';
      PropertyTagGpsGpsDop                      : result := 'GpsGpsDop';
      PropertyTagGpsSpeedRef                    : result := 'GpsSpeedRef';
      PropertyTagGpsSpeed                       : result := 'GpsSpeed';
      PropertyTagGpsTrackRef                    : result := 'GpsTrackRef';
      PropertyTagGpsTrack                       : result := 'GpsTrack';
      PropertyTagGpsImgDirRef                   : result := 'GpsImgDirRef';
      PropertyTagGpsImgDir                      : result := 'GpsImgDir';
      PropertyTagGpsMapDatum                    : result := 'GpsMapDatum';
      PropertyTagGpsDestLatRef                  : result := 'GpsDestLatRef';
      PropertyTagGpsDestLat                     : result := 'GpsDestLat';
      PropertyTagGpsDestLongRef                 : result := 'GpsDestLongRef';
      PropertyTagGpsDestLong                    : result := 'GpsDestLong';
      PropertyTagGpsDestBearRef                 : result := 'GpsDestBearRef';
      PropertyTagGpsDestBear                    : result := 'GpsDestBear';
      PropertyTagGpsDestDistRef                 : result := 'GpsDestDistRef';
      PropertyTagGpsDestDist                    : result := 'GpsDestDist';
    else
      Result := ''
    end;
  end;


(*
  procedure TraceExifProps(AImage :TGPImage);
  var
    I :Integer;
    vSize, vCount :Cardinal;
    vBuffer, vItem :PPropertyItem;
    vName, vValue :TString;
  begin
    AImage.GetPropertySize(vSize, vCount);
    if vCount > 0 then begin
      GetMem(vBuffer, vSize);
      ZeroMemory(vBuffer, vSize);
      try
        AImage.GetAllPropertyItems(vSize, vCount, vBuffer);

        vItem := vBuffer;
        for i := 0 to Integer(vCount) - 1 do begin
          vName := GetImagePropName(vItem.id);
          if vName = '' then
            vName := Format('Prop%d', [vItem.id]);

          vValue := '';
          if vItem.type_ = PropertyTagTypeASCII then
            vValue := PChar(vItem.value)
          else
          if vItem.type_ = PropertyTagTypeByte then
            vValue := Int2Str(Byte(vItem.value^))
          else
          if vItem.type_ = PropertyTagTypeShort then
            vValue := Int2Str(Word(vItem.value^))
          else
          if vItem.type_ in [PropertyTagTypeLong, PropertyTagTypeSLONG] then
            vValue := Int2Str(Integer(vItem.value^))
          else
          if vItem.type_ in [PropertyTagTypeRational, PropertyTagTypeSRational] then
            vValue := '???';

          if (vName <> '') {and (vValue <> '')} then
            TraceF('Prop: %s = %s', [ vName, vValue ]);

          Inc(PChar(vItem), SizeOf(TPropertyItem));
        end;

      finally
        FreeMem(vBuffer);
      end;
    end;
  end;
*)

  function GetExifTagValueAsInt(AImage :TGPImage; AID :ULONG; var AValue :Integer) :Boolean;
  var
    vSize :UINT;
    vItem :PPropertyItem;
  begin
    Result := False;
    vSize := AImage.GetPropertyItemSize(AID);
    if (AImage.GetLastStatus = OK) and (vSize > 0) then begin
      vItem := MemAlloc(vSize);
      try
        AImage.GetPropertyItem(AID, vSize, vItem);
        if AImage.GetLastStatus = OK then begin
          Result := True;
          if vItem.type_ = PropertyTagTypeByte then
            AValue := Byte(vItem.value^)
          else
          if vItem.type_ = PropertyTagTypeShort then
            AValue := Word(vItem.value^)
          else
          if vItem.type_ in [PropertyTagTypeLong, PropertyTagTypeSLONG] then
            AValue := Integer(vItem.value^)
          else
            Result := False;
        end;
      finally
        MemFree(vItem);
      end;
    end;
  end;


  procedure SetExifTagValueInt(AImage :TGPImage; AID :ULONG; AValue :Word);
  var
    vItem :TPropertyItem;
  begin
    vItem.id := AID;
    vItem.length := SizeOf(AValue);
    vItem.type_ := PropertyTagTypeSHORT;
    vItem.value := @AValue;
    AImage.SetPropertyItem(vItem);
    GDICheck(AImage.GetLastStatus);
  end;



  function GetFrameCount(AImage :TGPImage; ADimID :PGUID; ADelays :PPointer {^PPropertyItem}; ADelCount :PInteger) :Integer;
  var
    vCount, vSize :Integer;
    vDims :PGUID;
  begin
    Result := 0;
    if ADelays <> nil then
      ADelays^ := nil;
    if ADelCount <> nil then
      ADelCount^ := 0;
    vCount := AImage.GetFrameDimensionsCount;
    if vCount > 0 then begin
      GetMem(vDims, vCount * SizeOf(TGUID));
      try
        AImage.GetFrameDimensionsList(vDims, vCount);

        Result := AImage.GetFrameCount(vDims^);

        if ADimID <> nil then
          ADimID^ := vDims^;

        if (Result > 1) and (ADelays <> nil) and (ADelCount <> nil) then begin
          vSize := AImage.GetPropertyItemSize(PropertyTagFrameDelay);
          if vSize > SizeOf(TPropertyItem) then begin
            GetMem(ADelays^, vSize);
            AImage.GetPropertyItem(PropertyTagFrameDelay, vSize, ADelays^);
            ADelCount^ := (vSize - SizeOf(TPropertyItem)) div SizeOf(Integer);
          end;
        end;

      finally
        FreeMem(vDims);
      end;
    end;
  end;


end.

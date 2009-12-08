{$I Defines.inc}

unit FarHintsImageUtil;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    GDIPAPI,
    GDIPOBJ;

  function GetImagePropName(id :ULONG) :AnsiString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


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


end.

{*******************************************************}
{                                                       }
{                Delphi Runtime Library                 }
{                                                       }
{          File: wincodec.h                             }
{          Copyright (c) Microsoft Corporation.         }
{                                                       }
{       Translator: Embarcadero Technologies, Inc.      }
{ Copyright(c) 1995-2012 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

unit Wincodec;

interface

{$ALIGN ON}
{$MINENUMSIZE 4}

uses Windows, ActiveX;


type
  IPropertyBag2 = interface(IUnknown)
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IUnknown)' }
    ['{22F55882-280B-11d0-A8A9-00A0C90C2004}']
(*
    function Read(pPropBag: PPropBag2; pErrLog: IErrorLog;
      pvarValue: PVariant; phrError: PHResult): HRESULT; stdcall;

    function Write(cProperties: ULONG; pPropBag: PPropBag2;
      pvarValue: PVariant): HRESULT; stdcall;
    function CountProperties(var pcProperties: ULONG): HRESULT; stdcall;

    function GetPropertyInfo(iProperty, cProperties: ULONG;
      pPropBag: PPropBag2; var pcProperties: ULONG): HRESULT; stdcall;

    function LoadObject(pstrName:POleStr; dwHint: DWORD; pUnkObject: IUnknown;
      pErrLog: IErrorLog): HRESULT; stdcall;
*)
  end;


{$HPPEMIT '#include "wincodec.h"'}
{$HPPEMIT '#ifndef _WIN64'}
{$HPPEMIT '#pragma link "windowscodecs.lib"'}
{$HPPEMIT '#endif //_WIN64'}
const
  SID_IWICPalette                         = '{00000040-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICBitmapSource                    = '{00000120-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICFormatConverter                 = '{00000301-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICBitmapScaler                    = '{00000302-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICBitmapClipper                   = '{E4FBCF03-223D-4e81-9333-D635556DD1B5}';
  SID_IWICBitmapFlipRotator               = '{5009834F-2D6A-41ce-9E1B-17C5AFF7A782}';
  SID_IWICBitmapLock                      = '{00000123-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICBitmap                          = '{00000121-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICColorTransform                  = '{B66F034F-D0E2-40ab-B436-6DE39E321A94}';
  SID_IWICColorContext                    = '{3C613A02-34B2-44ea-9A7C-45AEA9C6FD6D}';
  SID_IWICFastMetadataEncoder             = '{B84E2C09-78C9-4AC4-8BD3-524AE1663A2F}';
  SID_IWICStream                          = '{135FF860-22B7-4ddf-B0F6-218F4F299A43}';
  SID_IWICEnumMetadataItem                = '{DC2BB46D-3F07-481E-8625-220C4AEDBB33}';
  SID_IWICMetadataQueryReader             = '{30989668-E1C9-4597-B395-458EEDB808DF}';
  SID_IWICMetadataQueryWriter             = '{A721791A-0DEF-4d06-BD91-2118BF1DB10B}';
  SID_IWICBitmapEncoder                   = '{00000103-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICBitmapFrameEncode               = '{00000105-a8f2-4877-ba0a-fd2b6645fb94}';
  SID_IWICBitmapDecoder                   = '{9EDDE9E7-8DEE-47ea-99DF-E6FAF2ED44BF}';
  SID_IWICBitmapSourceTransform           = '{3B16811B-6A43-4ec9-B713-3D5A0C13B940}';
  SID_IWICBitmapFrameDecode               = '{3B16811B-6A43-4ec9-A813-3D930C13B940}';
  SID_IWICProgressiveLevelControl         = '{DAAC296F-7AA5-4dbf-8D15-225C5976F891}';
  SID_IWICProgressCallback                = '{4776F9CD-9517-45FA-BF24-E89C5EC5C60C}';
  SID_IWICBitmapCodecProgressNotification = '{64C1024E-C3CF-4462-8078-88C2B11C46D9}';
  SID_IWICComponentInfo                   = '{23BC3F0A-698B-4357-886B-F24D50671334}';
  SID_IWICFormatConverterInfo             = '{9F34FB65-13F4-4f15-BC57-3726B5E53D9F}';
  SID_IWICBitmapCodecInfo                 = '{E87A44C4-B76E-4c47-8B09-298EB12A2714}';
  SID_IWICBitmapEncoderInfo               = '{94C9B4EE-A09F-4f92-8A1E-4A9BCE7E76FB}';
  SID_IWICBitmapDecoderInfo               = '{D8CD007F-D08F-4191-9BFC-236EA7F0E4B5}';
  SID_IWICPixelFormatInfo                 = '{E8EDA601-3D48-431a-AB44-69059BE88BBE}';
  SID_IWICPixelFormatInfo2                = '{A9DB33A2-AF5F-43C7-B679-74F5984B5AA4}';
  SID_IWICImagingFactory                  = '{ec5ec8a9-c395-4314-9c77-54d7a935ff70}';
  SID_IWICDevelopRawNotificationCallback  = '{95c75a6e-3e8c-4ec2-85a8-aebcc551e59b}';
  SID_IWICDevelopRaw                      = '{fbec5e44-f7be-4b65-b7f8-c0c81fef026d}';

  IID_IWICPalette:                         TGUID = SID_IWICPalette;
  {$EXTERNALSYM IID_IWICPalette}
  IID_IWICBitmapSource:                    TGUID = SID_IWICBitmapSource;
  {$EXTERNALSYM IID_IWICBitmapSource}
  IID_IWICFormatConverter:                 TGUID = SID_IWICFormatConverter;
  {$EXTERNALSYM IID_IWICFormatConverter}
  IID_IWICBitmapScaler:                    TGUID = SID_IWICBitmapScaler;
  {$EXTERNALSYM IID_IWICBitmapScaler}
  IID_IWICBitmapClipper:                   TGUID = SID_IWICBitmapClipper;
  {$EXTERNALSYM IID_IWICBitmapClipper}
  IID_IWICBitmapFlipRotator:               TGUID = SID_IWICBitmapFlipRotator;
  {$EXTERNALSYM IID_IWICBitmapFlipRotator}
  IID_IWICBitmapLock:                      TGUID = SID_IWICBitmapLock;
  {$EXTERNALSYM IID_IWICBitmapLock}
  IID_IWICBitmap:                          TGUID = SID_IWICBitmap;
  {$EXTERNALSYM IID_IWICBitmap}
  IID_IWICColorTransform:                  TGUID = SID_IWICColorTransform;
  {$EXTERNALSYM IID_IWICColorTransform}
  IID_IWICColorContext:                    TGUID = SID_IWICColorContext;
  {$EXTERNALSYM IID_IWICColorContext}
  IID_IWICFastMetadataEncoder:             TGUID = SID_IWICFastMetadataEncoder;
  {$EXTERNALSYM IID_IWICFastMetadataEncoder}
  IID_IWICStream:                          TGUID = SID_IWICStream;
  {$EXTERNALSYM IID_IWICStream}
  IID_IWICEnumMetadataItem:                TGUID = SID_IWICEnumMetadataItem;
  {$EXTERNALSYM IID_IWICEnumMetadataItem}
  IID_IWICMetadataQueryReader:             TGUID = SID_IWICMetadataQueryReader;
  {$EXTERNALSYM IID_IWICMetadataQueryReader}
  IID_IWICMetadataQueryWriter:             TGUID = SID_IWICMetadataQueryWriter;
  {$EXTERNALSYM IID_IWICMetadataQueryWriter}
  IID_IWICBitmapEncoder:                   TGUID = SID_IWICBitmapEncoder;
  {$EXTERNALSYM IID_IWICBitmapEncoder}
  IID_IWICBitmapFrameEncode:               TGUID = SID_IWICBitmapFrameEncode;
  {$EXTERNALSYM IID_IWICBitmapFrameEncode}
  IID_IWICBitmapDecoder:                   TGUID = SID_IWICBitmapDecoder;
  {$EXTERNALSYM IID_IWICBitmapDecoder}
  IID_IWICBitmapSourceTransform:           TGUID = SID_IWICBitmapSourceTransform;
  {$EXTERNALSYM IID_IWICBitmapSourceTransform}
  IID_IWICBitmapFrameDecode:               TGUID = SID_IWICBitmapFrameDecode;
  {$EXTERNALSYM IID_IWICBitmapFrameDecode}
  IID_IWICProgressiveLevelControl:         TGUID = SID_IWICProgressiveLevelControl;
  {$EXTERNALSYM IID_IWICProgressiveLevelControl}
  IID_IWICProgressCallback:                TGUID = SID_IWICProgressCallback;
  {$EXTERNALSYM IID_IWICProgressCallback}
  IID_IWICBitmapCodecProgressNotification: TGUID = SID_IWICBitmapCodecProgressNotification;
  {$EXTERNALSYM IID_IWICBitmapCodecProgressNotification}
  IID_IWICComponentInfo:                   TGUID = SID_IWICComponentInfo;
  {$EXTERNALSYM IID_IWICComponentInfo}
  IID_IWICFormatConverterInfo:             TGUID = SID_IWICFormatConverterInfo;
  {$EXTERNALSYM IID_IWICFormatConverterInfo}
  IID_IWICBitmapCodecInfo:                 TGUID = SID_IWICBitmapCodecInfo;
  {$EXTERNALSYM IID_IWICBitmapCodecInfo}
  IID_IWICBitmapEncoderInfo:               TGUID = SID_IWICBitmapEncoderInfo;
  {$EXTERNALSYM IID_IWICBitmapEncoderInfo}
  IID_IWICBitmapDecoderInfo:               TGUID = SID_IWICBitmapDecoderInfo;
  {$EXTERNALSYM IID_IWICBitmapDecoderInfo}
  IID_IWICPixelFormatInfo:                 TGUID = SID_IWICPixelFormatInfo;
  {$EXTERNALSYM IID_IWICPixelFormatInfo}
  IID_IWICPixelFormatInfo2:                TGUID = SID_IWICPixelFormatInfo2;
  {$EXTERNALSYM IID_IWICPixelFormatInfo2}
  IID_IWICImagingFactory:                  TGUID = SID_IWICImagingFactory;
  {$EXTERNALSYM IID_IWICImagingFactory}
  IID_IWICDevelopRawNotificationCallback:  TGUID = SID_IWICDevelopRawNotificationCallback;
  {$EXTERNALSYM IID_IWICDevelopRawNotificationCallback}
  IID_IWICDevelopRaw:                      TGUID = SID_IWICDevelopRaw;
  {$EXTERNALSYM IID_IWICDevelopRaw}

const
  WINCODEC_SDK_VERSION = $0236; 
  {$EXTERNALSYM WINCODEC_SDK_VERSION}
  CLSID_WICImagingFactory:           TGUID = '{CACAF262-9370-4615-A13B-9F5539DA4C0A}';
  {$EXTERNALSYM CLSID_WICImagingFactory}
  GUID_VendorMicrosoft:              TGUID = '{F0E749CA-EDEF-4589-A73A-EE0E626A2A2B}';
  {$EXTERNALSYM GUID_VendorMicrosoft}
  GUID_VendorMicrosoftBuiltIn:       TGUID = '{257A30FD-06B6-462B-AEA4-63F70B86E533}';
  {$EXTERNALSYM GUID_VendorMicrosoftBuiltIn}
  CLSID_WICBmpDecoder:               TGUID = '{6B462062-7CBF-400D-9FDB-813DD10F2778}';
  {$EXTERNALSYM CLSID_WICBmpDecoder}
  CLSID_WICPngDecoder:               TGUID = '{389EA17B-5078-4CDE-B6EF-25C15175C751}';
  {$EXTERNALSYM CLSID_WICPngDecoder}
  CLSID_WICIcoDecoder:               TGUID = '{C61BFCDF-2E0F-4AAD-A8D7-E06BAFEBCDFE}';
  {$EXTERNALSYM CLSID_WICIcoDecoder}
  CLSID_WICJpegDecoder:              TGUID = '{9456A480-E88B-43EA-9E73-0B2D9B71B1CA}';
  {$EXTERNALSYM CLSID_WICJpegDecoder}
  CLSID_WICGifDecoder:               TGUID = '{381DDA3C-9CE9-4834-A23E-1F98F8FC52BE}';
  {$EXTERNALSYM CLSID_WICGifDecoder}
  CLSID_WICTiffDecoder:              TGUID = '{B54E85D9-FE23-499F-8B88-6ACEA713752B}';
  {$EXTERNALSYM CLSID_WICTiffDecoder}
  CLSID_WICWmpDecoder:               TGUID = '{A26CEC36-234C-4950-AE16-E34AACE71D0D}';
  {$EXTERNALSYM CLSID_WICWmpDecoder}
  CLSID_WICBmpEncoder:               TGUID = '{69BE8BB4-D66D-47C8-865A-ED1589433782}';
  {$EXTERNALSYM CLSID_WICBmpEncoder}
  CLSID_WICPngEncoder:               TGUID = '{27949969-876A-41D7-9447-568F6A35A4DC}';
  {$EXTERNALSYM CLSID_WICPngEncoder}
  CLSID_WICJpegEncoder:              TGUID = '{1A34F5C1-4A5A-46DC-B644-1F4567E7A676}';
  {$EXTERNALSYM CLSID_WICJpegEncoder}
  CLSID_WICGifEncoder:               TGUID = '{114F5598-0B22-40A0-86A1-C83EA495ADBD}';
  {$EXTERNALSYM CLSID_WICGifEncoder}
  CLSID_WICTiffEncoder:              TGUID = '{0131BE10-2001-4C5F-A9B0-CC88FAB64CE8}';
  {$EXTERNALSYM CLSID_WICTiffEncoder}
  CLSID_WICWmpEncoder:               TGUID = '{AC4CE3CB-E1C1-44CD-8215-5A1665509EC2}';
  {$EXTERNALSYM CLSID_WICWmpEncoder}
  GUID_ContainerFormatBmp:           TGUID = '{0AF1D87E-FCFE-4188-BDEB-A7906471CBE3}';
  {$EXTERNALSYM GUID_ContainerFormatBmp}
  GUID_ContainerFormatPng:           TGUID = '{1B7CFAF4-713F-473C-BBCD-6137425FAEAF}';
  {$EXTERNALSYM GUID_ContainerFormatPng}
  GUID_ContainerFormatIco:           TGUID = '{A3A860C4-338F-4C17-919A-FBA4B5628F21}';
  {$EXTERNALSYM GUID_ContainerFormatIco}
  GUID_ContainerFormatJpeg:          TGUID = '{19E4A5AA-5662-4FC5-A0C0-1758028E1057}';
  {$EXTERNALSYM GUID_ContainerFormatJpeg}
  GUID_ContainerFormatTiff:          TGUID = '{163BCC30-E2E9-4F0B-961D-A3E9FDB788A3}';
  {$EXTERNALSYM GUID_ContainerFormatTiff}
  GUID_ContainerFormatGif:           TGUID = '{1F8A5601-7D4D-4CBD-9C82-1BC8D4EEB9A5}';
  {$EXTERNALSYM GUID_ContainerFormatGif}
  GUID_ContainerFormatWmp:           TGUID = '{57A37CAA-367A-4540-916B-F183C5093A4B}';
  {$EXTERNALSYM GUID_ContainerFormatWmp}
  CLSID_WICImagingCategories:        TGUID = '{FAE3D380-FEA4-4623-8C75-C6B61110B681}';
  {$EXTERNALSYM CLSID_WICImagingCategories}
  CATID_WICBitmapDecoders:           TGUID = '{7ED96837-96F0-4812-B211-F13C24117ED3}';
  {$EXTERNALSYM CATID_WICBitmapDecoders}
  CATID_WICBitmapEncoders:           TGUID = '{AC757296-3522-4E11-9862-C17BE5A1767E}';
  {$EXTERNALSYM CATID_WICBitmapEncoders}
  CATID_WICPixelFormats:             TGUID = '{2B46E70F-CDA7-473E-89F6-DC9630A2390B}';
  {$EXTERNALSYM CATID_WICPixelFormats}
  CATID_WICFormatConverters:         TGUID = '{7835EAE8-BF14-49D1-93CE-533A407B2248}';
  {$EXTERNALSYM CATID_WICFormatConverters}
  CATID_WICMetadataReader:           TGUID = '{05AF94D8-7174-4CD2-BE4A-4124B80EE4B8}';
  {$EXTERNALSYM CATID_WICMetadataReader}
  CATID_WICMetadataWriter:           TGUID = '{ABE3B9A4-257D-4B97-BD1A-294AF496222E}';
  {$EXTERNALSYM CATID_WICMetadataWriter}
  CLSID_WICDefaultFormatConverter:   TGUID = '{1A3F11DC-B514-4B17-8C5F-2154513852F1}';
  {$EXTERNALSYM CLSID_WICDefaultFormatConverter}
  CLSID_WICFormatConverterHighColor: TGUID = '{AC75D454-9F37-48F8-B972-4E19BC856011}';
  {$EXTERNALSYM CLSID_WICFormatConverterHighColor}
  CLSID_WICFormatConverterNChannel:  TGUID = '{C17CABB2-D4A3-47D7-A557-339B2EFBD4F1}';
  {$EXTERNALSYM CLSID_WICFormatConverterNChannel}
  CLSID_WICFormatConverterWMPhoto:   TGUID = '{9CB5172B-D600-46BA-AB77-77BB7E3A00D9}';
  {$EXTERNALSYM CLSID_WICFormatConverterWMPhoto}

type
  WICColor = Cardinal;
  {$EXTERNALSYM WICColor}
  TWICColor = WICColor;
  PWICColor = ^TWicColor;

  WICRect = record
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
  end;
  {$EXTERNALSYM WICRect}
  PWICRect = ^WICRect;
  {$EXTERNALSYM PWICRect}


  WICInProcPointer = ^Byte;
  { $EXTERNALSYM WICInProcPointer}
  TWICInProcPointer = WICInProcPointer;
  PWICInProcPointer = ^TWICInProcPointer;

type
  WICColorContextType = type Integer;
  {$EXTERNALSYM WICColorContextType}
const
  WICColorContextUninitialized  = 0;
  {$EXTERNALSYM WICColorContextUninitialized}
  WICColorContextProfile        = $1;
  {$EXTERNALSYM WICColorContextProfile}
  WICColorContextExifColorSpace = $2;
  {$EXTERNALSYM WICColorContextExifColorSpace}

type
  REFWICPixelFormatGUID = PGUID;
  {$EXTERNALSYM REFWICPixelFormatGUID}
  WICPixelFormatGUID = TGUID;
  {$EXTERNALSYM WICPixelFormatGUID}
  TWICPixelFormatGUID = WICPixelFormatGUID;
  PWICPixelFormatGUID = ^TWICPixelFormatGUID;

const
  GUID_WICPixelFormatUndefined:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC900}';
  {$EXTERNALSYM GUID_WICPixelFormatUndefined}
  GUID_WICPixelFormatDontCare:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC900}';
  {$EXTERNALSYM GUID_WICPixelFormatDontCare}
  GUID_WICPixelFormat1bppIndexed:          TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC901}';
  {$EXTERNALSYM GUID_WICPixelFormat1bppIndexed}
  GUID_WICPixelFormat2bppIndexed:          TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC902}';
  {$EXTERNALSYM GUID_WICPixelFormat2bppIndexed}
  GUID_WICPixelFormat4bppIndexed:          TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC903}';
  {$EXTERNALSYM GUID_WICPixelFormat4bppIndexed}
  GUID_WICPixelFormat8bppIndexed:          TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC904}';
  {$EXTERNALSYM GUID_WICPixelFormat8bppIndexed}
  GUID_WICPixelFormatBlackWhite:           TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC905}';
  {$EXTERNALSYM GUID_WICPixelFormatBlackWhite}
  GUID_WICPixelFormat2bppGray:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC906}';
  {$EXTERNALSYM GUID_WICPixelFormat2bppGray}
  GUID_WICPixelFormat4bppGray:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC907}';
  {$EXTERNALSYM GUID_WICPixelFormat4bppGray}
  GUID_WICPixelFormat8bppGray:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC908}';
  {$EXTERNALSYM GUID_WICPixelFormat8bppGray}
  GUID_WICPixelFormat8bppAlpha:            TGUID = '{E6CD0116-EEBA-4161-AA85-27DD9FB3A895}';
  {$EXTERNALSYM GUID_WICPixelFormat8bppAlpha}
  GUID_WICPixelFormat16bppBGR555:          TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC909}';
  {$EXTERNALSYM GUID_WICPixelFormat16bppBGR555}
  GUID_WICPixelFormat16bppBGR565:          TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC90A}';
  {$EXTERNALSYM GUID_WICPixelFormat16bppBGR565}
  GUID_WICPixelFormat16bppBGRA5551:        TGUID = '{05EC7C2B-F1E6-4961-AD46-E1CC810A87D2}';
  {$EXTERNALSYM GUID_WICPixelFormat16bppBGRA5551}
  GUID_WICPixelFormat16bppGray:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC90B}';
  {$EXTERNALSYM GUID_WICPixelFormat16bppGray}
  GUID_WICPixelFormat24bppBGR:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC90C}';
  {$EXTERNALSYM GUID_WICPixelFormat24bppBGR}
  GUID_WICPixelFormat24bppRGB:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC90D}';
  {$EXTERNALSYM GUID_WICPixelFormat24bppRGB}
  GUID_WICPixelFormat32bppBGR:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC90E}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppBGR}
  GUID_WICPixelFormat32bppBGRA:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC90F}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppBGRA}
  GUID_WICPixelFormat32bppPBGRA:           TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC910}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppPBGRA}
  GUID_WICPixelFormat32bppGrayFloat:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC911}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppGrayFloat}
  GUID_WICPixelFormat32bppRGBA:            TGUID = '{F5C7AD2D-6A8D-43DD-A7A8-A29935261AE9}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppRGBA}
  GUID_WICPixelFormat32bppPRGBA:           TGUID = '{3CC4A650-A527-4D37-A916-3142C7EBEDBA}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppPRGBA}
  GUID_WICPixelFormat48bppRGB:             TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC915}';
  {$EXTERNALSYM GUID_WICPixelFormat48bppRGB}
  GUID_WICPixelFormat48bppBGR:             TGUID = '{E605A384-B468-46CE-BB2E-36F180E64313}';
  {$EXTERNALSYM GUID_WICPixelFormat48bppBGR}
  GUID_WICPixelFormat64bppRGBA:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC916}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppRGBA}
  GUID_WICPixelFormat64bppBGRA:            TGUID = '{1562FF7C-D352-46F9-979E-42976B792246}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppBGRA}
  GUID_WICPixelFormat64bppPRGBA:           TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC917}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppPRGBA}
  GUID_WICPixelFormat64bppPBGRA:           TGUID = '{8C518E8E-A4EC-468B-AE70-C9A35A9C5530}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppPBGRA}
  GUID_WICPixelFormat16bppGrayFixedPoint:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC913}';
  {$EXTERNALSYM GUID_WICPixelFormat16bppGrayFixedPoint}
  GUID_WICPixelFormat32bppBGR101010:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC914}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppBGR101010}
  GUID_WICPixelFormat48bppRGBFixedPoint:   TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC912}';
  {$EXTERNALSYM GUID_WICPixelFormat48bppRGBFixedPoint}
  GUID_WICPixelFormat48bppBGRFixedPoint:   TGUID = '{49CA140E-CAB6-493B-9DDF-60187C37532A}';
  {$EXTERNALSYM GUID_WICPixelFormat48bppBGRFixedPoint}
  GUID_WICPixelFormat96bppRGBFixedPoint:   TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC918}';
  {$EXTERNALSYM GUID_WICPixelFormat96bppRGBFixedPoint}
  GUID_WICPixelFormat128bppRGBAFloat:      TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC919}';
  {$EXTERNALSYM GUID_WICPixelFormat128bppRGBAFloat}
  GUID_WICPixelFormat128bppPRGBAFloat:     TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC91A}';
  {$EXTERNALSYM GUID_WICPixelFormat128bppPRGBAFloat}
  GUID_WICPixelFormat128bppRGBFloat:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC91B}';
  {$EXTERNALSYM GUID_WICPixelFormat128bppRGBFloat}
  GUID_WICPixelFormat32bppCMYK:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC91C}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppCMYK}
  GUID_WICPixelFormat64bppRGBAFixedPoint:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC91D}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppRGBAFixedPoint}
  GUID_WICPixelFormat64bppBGRAFixedPoint:  TGUID = '{356de33c-54d2-4a23-bb04-9b7bf9b1d42d}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppBGRAFixedPoint}
  GUID_WICPixelFormat64bppRGBFixedPoint:   TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC940}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppRGBFixedPoint}
  GUID_WICPixelFormat128bppRGBAFixedPoint: TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC91E}';
  {$EXTERNALSYM GUID_WICPixelFormat128bppRGBAFixedPoint}
  GUID_WICPixelFormat128bppRGBFixedPoint:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC941}';
  {$EXTERNALSYM GUID_WICPixelFormat128bppRGBFixedPoint}
  GUID_WICPixelFormat64bppRGBAHalf:        TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC93A}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppRGBAHalf}
  GUID_WICPixelFormat64bppRGBHalf:         TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC942}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppRGBHalf}
  GUID_WICPixelFormat48bppRGBHalf:         TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC93B}';
  {$EXTERNALSYM GUID_WICPixelFormat48bppRGBHalf}
  GUID_WICPixelFormat32bppRGBE:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC93D}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppRGBE}
  GUID_WICPixelFormat16bppGrayHalf:        TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC93E}';
  {$EXTERNALSYM GUID_WICPixelFormat16bppGrayHalf}
  GUID_WICPixelFormat32bppGrayFixedPoint:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC93F}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppGrayFixedPoint}
  GUID_WICPixelFormat32bppRGBA1010102:     TGUID = '{25238D72-FCF9-4522-B514-5578E5AD55E0}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppRGBA1010102}
  GUID_WICPixelFormat32bppRGBA1010102XR:   TGUID = '{00DE6B9A-C101-434B-B502-D0165EE1122C}';
  {$EXTERNALSYM GUID_WICPixelFormat32bppRGBA1010102XR}
  GUID_WICPixelFormat64bppCMYK:            TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC91F}';
  {$EXTERNALSYM GUID_WICPixelFormat64bppCMYK}
  GUID_WICPixelFormat24bpp3Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC920}';
  {$EXTERNALSYM GUID_WICPixelFormat24bpp3Channels}
  GUID_WICPixelFormat32bpp4Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC921}';
  {$EXTERNALSYM GUID_WICPixelFormat32bpp4Channels}
  GUID_WICPixelFormat40bpp5Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC922}';
  {$EXTERNALSYM GUID_WICPixelFormat40bpp5Channels}
  GUID_WICPixelFormat48bpp6Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC923}';
  {$EXTERNALSYM GUID_WICPixelFormat48bpp6Channels}
  GUID_WICPixelFormat56bpp7Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC924}';
  {$EXTERNALSYM GUID_WICPixelFormat56bpp7Channels}
  GUID_WICPixelFormat64bpp8Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC925}';
  {$EXTERNALSYM GUID_WICPixelFormat64bpp8Channels}
  GUID_WICPixelFormat48bpp3Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC926}';
  {$EXTERNALSYM GUID_WICPixelFormat48bpp3Channels}
  GUID_WICPixelFormat64bpp4Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC927}';
  {$EXTERNALSYM GUID_WICPixelFormat64bpp4Channels}
  GUID_WICPixelFormat80bpp5Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC928}';
  {$EXTERNALSYM GUID_WICPixelFormat80bpp5Channels}
  GUID_WICPixelFormat96bpp6Channels:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC929}';
  {$EXTERNALSYM GUID_WICPixelFormat96bpp6Channels}
  GUID_WICPixelFormat112bpp7Channels:      TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC92A}';
  {$EXTERNALSYM GUID_WICPixelFormat112bpp7Channels}
  GUID_WICPixelFormat128bpp8Channels:      TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC92B}';
  {$EXTERNALSYM GUID_WICPixelFormat128bpp8Channels}
  GUID_WICPixelFormat40bppCMYKAlpha:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC92C}';
  {$EXTERNALSYM GUID_WICPixelFormat40bppCMYKAlpha}
  GUID_WICPixelFormat80bppCMYKAlpha:       TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC92D}';
  {$EXTERNALSYM GUID_WICPixelFormat80bppCMYKAlpha}
  GUID_WICPixelFormat32bpp3ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC92E}';
  {$EXTERNALSYM GUID_WICPixelFormat32bpp3ChannelsAlpha}
  GUID_WICPixelFormat40bpp4ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC92F}';
  {$EXTERNALSYM GUID_WICPixelFormat40bpp4ChannelsAlpha}
  GUID_WICPixelFormat48bpp5ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC930}';
  {$EXTERNALSYM GUID_WICPixelFormat48bpp5ChannelsAlpha}
  GUID_WICPixelFormat56bpp6ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC931}';
  {$EXTERNALSYM GUID_WICPixelFormat56bpp6ChannelsAlpha}
  GUID_WICPixelFormat64bpp7ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC932}';
  {$EXTERNALSYM GUID_WICPixelFormat64bpp7ChannelsAlpha}
  GUID_WICPixelFormat72bpp8ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC933}';
  {$EXTERNALSYM GUID_WICPixelFormat72bpp8ChannelsAlpha}
  GUID_WICPixelFormat64bpp3ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC934}';
  {$EXTERNALSYM GUID_WICPixelFormat64bpp3ChannelsAlpha}
  GUID_WICPixelFormat80bpp4ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC935}';
  {$EXTERNALSYM GUID_WICPixelFormat80bpp4ChannelsAlpha}
  GUID_WICPixelFormat96bpp5ChannelsAlpha:  TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC936}';
  {$EXTERNALSYM GUID_WICPixelFormat96bpp5ChannelsAlpha}
  GUID_WICPixelFormat112bpp6ChannelsAlpha: TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC937}';
  {$EXTERNALSYM GUID_WICPixelFormat112bpp6ChannelsAlpha}
  GUID_WICPixelFormat128bpp7ChannelsAlpha: TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC938}';
  {$EXTERNALSYM GUID_WICPixelFormat128bpp7ChannelsAlpha}
  GUID_WICPixelFormat144bpp8ChannelsAlpha: TGUID = '{6FDDC324-4E03-4BFE-B185-3D77768DC939}';
  {$EXTERNALSYM GUID_WICPixelFormat144bpp8ChannelsAlpha}
type
  WICBitmapCreateCacheOption = type Integer;
  {$EXTERNALSYM WICBitmapCreateCacheOption}
const
  WICBitmapNoCache                       = 0;
  {$EXTERNALSYM WICBitmapNoCache}
  WICBitmapCacheOnDemand                 = $1;
  {$EXTERNALSYM WICBitmapCacheOnDemand}
  WICBitmapCacheOnLoad                   = $2;
  {$EXTERNALSYM WICBitmapCacheOnLoad}
  WICBITMAPCREATECACHEOPTION_FORCE_DWORD = $7FFFFFFF;
  {$EXTERNALSYM WICBITMAPCREATECACHEOPTION_FORCE_DWORD}

type
  WICDecodeOptions = type Integer; 
  {$EXTERNALSYM WICDecodeOptions}
const
  WICDecodeMetadataCacheOnDemand     = 0; 
  {$EXTERNALSYM WICDecodeMetadataCacheOnDemand}
  WICDecodeMetadataCacheOnLoad       = $1; 
  {$EXTERNALSYM WICDecodeMetadataCacheOnLoad}
  WICMETADATACACHEOPTION_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICMETADATACACHEOPTION_FORCE_DWORD}

type
  WICBitmapEncoderCacheOption = type Integer; 
  {$EXTERNALSYM WICBitmapEncoderCacheOption}
const
  WICBitmapEncoderCacheInMemory           = 0; 
  {$EXTERNALSYM WICBitmapEncoderCacheInMemory}
  WICBitmapEncoderCacheTempFile           = $1; 
  {$EXTERNALSYM WICBitmapEncoderCacheTempFile}
  WICBitmapEncoderNoCache                 = $2;
  {$EXTERNALSYM WICBitmapEncoderNoCache}
  WICBITMAPENCODERCACHEOPTION_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPENCODERCACHEOPTION_FORCE_DWORD}

type
  WICComponentType = type Integer; 
  {$EXTERNALSYM WICComponentType}
const
  WICDecoder                   = $1; 
  {$EXTERNALSYM WICDecoder}
  WICEncoder                   = $2; 
  {$EXTERNALSYM WICEncoder}
  WICPixelFormatConverter      = $4; 
  {$EXTERNALSYM WICPixelFormatConverter}
  WICMetadataReader            = $8; 
  {$EXTERNALSYM WICMetadataReader}
  WICMetadataWriter            = $10; 
  {$EXTERNALSYM WICMetadataWriter}
  WICPixelFormat               = $20; 
  {$EXTERNALSYM WICPixelFormat}
  WICAllComponents             = $3F; 
  {$EXTERNALSYM WICAllComponents}
  WICCOMPONENTTYPE_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICCOMPONENTTYPE_FORCE_DWORD}

type
  WICComponentEnumerateOptions = type Integer; 
  {$EXTERNALSYM WICComponentEnumerateOptions}
const
  WICComponentEnumerateDefault             = 0; 
  {$EXTERNALSYM WICComponentEnumerateDefault}
  WICComponentEnumerateRefresh             = $1; 
  {$EXTERNALSYM WICComponentEnumerateRefresh}
  WICComponentEnumerateDisabled            = $80000000; 
  {$EXTERNALSYM WICComponentEnumerateDisabled}
  WICComponentEnumerateUnsigned            = $40000000; 
  {$EXTERNALSYM WICComponentEnumerateUnsigned}
  WICComponentEnumerateBuiltInOnly         = $20000000; 
  {$EXTERNALSYM WICComponentEnumerateBuiltInOnly}
  WICCOMPONENTENUMERATEOPTIONS_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICCOMPONENTENUMERATEOPTIONS_FORCE_DWORD}

type
  WICBitmapPattern = record
    Position: ULARGE_INTEGER;
    Length: ULONG;
    Pattern: PBYTE;
    Mask: PBYTE;
    EndOfStream: BOOL;
  end;
  {$EXTERNALSYM WICBitmapPattern}
  TWICBitmapPattern = WICBitmapPattern;
  PWICBitmapPattern = ^WICBitmapPattern;

type
  WICBitmapInterpolationMode = type Integer; 
  {$EXTERNALSYM WICBitmapInterpolationMode}
const
  WICBitmapInterpolationModeNearestNeighbor = 0; 
  {$EXTERNALSYM WICBitmapInterpolationModeNearestNeighbor}
  WICBitmapInterpolationModeLinear          = $1; 
  {$EXTERNALSYM WICBitmapInterpolationModeLinear}
  WICBitmapInterpolationModeCubic           = $2; 
  {$EXTERNALSYM WICBitmapInterpolationModeCubic}
  WICBitmapInterpolationModeFant            = $3; 
  {$EXTERNALSYM WICBitmapInterpolationModeFant}
  WICBITMAPINTERPOLATIONMODE_FORCE_DWORD    = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPINTERPOLATIONMODE_FORCE_DWORD}

type
  WICBitmapPaletteType = type Integer; 
  {$EXTERNALSYM WICBitmapPaletteType}
const
  WICBitmapPaletteTypeCustom           = 0; 
  {$EXTERNALSYM WICBitmapPaletteTypeCustom}
  WICBitmapPaletteTypeMedianCut        = $1; 
  {$EXTERNALSYM WICBitmapPaletteTypeMedianCut}
  WICBitmapPaletteTypeFixedBW          = $2; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedBW}
  WICBitmapPaletteTypeFixedHalftone8   = $3; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone8}
  WICBitmapPaletteTypeFixedHalftone27  = $4; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone27}
  WICBitmapPaletteTypeFixedHalftone64  = $5; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone64}
  WICBitmapPaletteTypeFixedHalftone125 = $6;
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone125}
  WICBitmapPaletteTypeFixedHalftone216 = $7; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone216}
  WICBitmapPaletteTypeFixedWebPalette  = WICBITMAPPALETTETYPEFIXEDHALFTONE216; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedWebPalette}
  WICBitmapPaletteTypeFixedHalftone252 = $8; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone252}
  WICBitmapPaletteTypeFixedHalftone256 = $9; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedHalftone256}
  WICBitmapPaletteTypeFixedGray4       = $A; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedGray4}
  WICBitmapPaletteTypeFixedGray16      = $B;
  {$EXTERNALSYM WICBitmapPaletteTypeFixedGray16}
  WICBitmapPaletteTypeFixedGray256     = $C; 
  {$EXTERNALSYM WICBitmapPaletteTypeFixedGray256}
  WICBITMAPPALETTETYPE_FORCE_DWORD     = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPPALETTETYPE_FORCE_DWORD}

type
  WICBitmapDitherType = type Integer; 
  {$EXTERNALSYM WICBitmapDitherType}
const
  WICBitmapDitherTypeNone           = 0; 
  {$EXTERNALSYM WICBitmapDitherTypeNone}
  WICBitmapDitherTypeSolid          = 0; 
  {$EXTERNALSYM WICBitmapDitherTypeSolid}
  WICBitmapDitherTypeOrdered4x4     = $1; 
  {$EXTERNALSYM WICBitmapDitherTypeOrdered4x4}
  WICBitmapDitherTypeOrdered8x8     = $2; 
  {$EXTERNALSYM WICBitmapDitherTypeOrdered8x8}
  WICBitmapDitherTypeOrdered16x16   = $3; 
  {$EXTERNALSYM WICBitmapDitherTypeOrdered16x16}
  WICBitmapDitherTypeSpiral4x4      = $4; 
  {$EXTERNALSYM WICBitmapDitherTypeSpiral4x4}
  WICBitmapDitherTypeSpiral8x8      = $5; 
  {$EXTERNALSYM WICBitmapDitherTypeSpiral8x8}
  WICBitmapDitherTypeDualSpiral4x4  = $6; 
  {$EXTERNALSYM WICBitmapDitherTypeDualSpiral4x4}
  WICBitmapDitherTypeDualSpiral8x8  = $7; 
  {$EXTERNALSYM WICBitmapDitherTypeDualSpiral8x8}
  WICBitmapDitherTypeErrorDiffusion = $8; 
  {$EXTERNALSYM WICBitmapDitherTypeErrorDiffusion}
  WICBITMAPDITHERTYPE_FORCE_DWORD   = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPDITHERTYPE_FORCE_DWORD}

type
  WICBitmapAlphaChannelOption = type Integer; 
  {$EXTERNALSYM WICBitmapAlphaChannelOption}
const
  WICBitmapUseAlpha                        = 0; 
  {$EXTERNALSYM WICBitmapUseAlpha}
  WICBitmapUsePremultipliedAlpha           = $1; 
  {$EXTERNALSYM WICBitmapUsePremultipliedAlpha}
  WICBitmapIgnoreAlpha                     = $2; 
  {$EXTERNALSYM WICBitmapIgnoreAlpha}
  WICBITMAPALPHACHANNELOPTIONS_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPALPHACHANNELOPTIONS_FORCE_DWORD}

type
  WICBitmapTransformOptions = type Integer;
  {$EXTERNALSYM WICBitmapTransformOptions}
const
  WICBitmapTransformRotate0             = 0; 
  {$EXTERNALSYM WICBitmapTransformRotate0}
  WICBitmapTransformRotate90            = $1; 
  {$EXTERNALSYM WICBitmapTransformRotate90}
  WICBitmapTransformRotate180           = $2; 
  {$EXTERNALSYM WICBitmapTransformRotate180}
  WICBitmapTransformRotate270           = $3; 
  {$EXTERNALSYM WICBitmapTransformRotate270}
  WICBitmapTransformFlipHorizontal      = $8; 
  {$EXTERNALSYM WICBitmapTransformFlipHorizontal}
  WICBitmapTransformFlipVertical        = $10; 
  {$EXTERNALSYM WICBitmapTransformFlipVertical}
  WICBITMAPTRANSFORMOPTIONS_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPTRANSFORMOPTIONS_FORCE_DWORD}

type
  WICBitmapLockFlags = type Integer; 
  {$EXTERNALSYM WICBitmapLockFlags}
const
  WICBitmapLockRead              = $1; 
  {$EXTERNALSYM WICBitmapLockRead}
  WICBitmapLockWrite             = $2; 
  {$EXTERNALSYM WICBitmapLockWrite}
  WICBITMAPLOCKFLAGS_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPLOCKFLAGS_FORCE_DWORD}

type
  WICBitmapDecoderCapabilities = type Integer; 
  {$EXTERNALSYM WICBitmapDecoderCapabilities}
const
  WICBitmapDecoderCapabilitySameEncoder          = $1; 
  {$EXTERNALSYM WICBitmapDecoderCapabilitySameEncoder}
  WICBitmapDecoderCapabilityCanDecodeAllImages   = $2; 
  {$EXTERNALSYM WICBitmapDecoderCapabilityCanDecodeAllImages}
  WICBitmapDecoderCapabilityCanDecodeSomeImages  = $4; 
  {$EXTERNALSYM WICBitmapDecoderCapabilityCanDecodeSomeImages}
  WICBitmapDecoderCapabilityCanEnumerateMetadata = $8; 
  {$EXTERNALSYM WICBitmapDecoderCapabilityCanEnumerateMetadata}
  WICBitmapDecoderCapabilityCanDecodeThumbnail   = $10; 
  {$EXTERNALSYM WICBitmapDecoderCapabilityCanDecodeThumbnail}
  WICBITMAPDECODERCAPABILITIES_FORCE_DWORD       = $7FFFFFFF; 
  {$EXTERNALSYM WICBITMAPDECODERCAPABILITIES_FORCE_DWORD}

type
  WICProgressOperation = type Integer; 
  {$EXTERNALSYM WICProgressOperation}
const
  WICProgressOperationCopyPixels   = $1;
  {$EXTERNALSYM WICProgressOperationCopyPixels}
  WICProgressOperationWritePixels  = $2; 
  {$EXTERNALSYM WICProgressOperationWritePixels}
  WICProgressOperationAll          = $FFFF; 
  {$EXTERNALSYM WICProgressOperationAll}
  WICPROGRESSOPERATION_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPROGRESSOPERATION_FORCE_DWORD}

type
  WICProgressNotification = type Integer; 
  {$EXTERNALSYM WICProgressNotification}
const
  WICProgressNotificationBegin        = $10000; 
  {$EXTERNALSYM WICProgressNotificationBegin}
  WICProgressNotificationEnd          = $20000; 
  {$EXTERNALSYM WICProgressNotificationEnd}
  WICProgressNotificationFrequent     = $40000; 
  {$EXTERNALSYM WICProgressNotificationFrequent}
  WICProgressNotificationAll          = $FFFF0000; 
  {$EXTERNALSYM WICProgressNotificationAll}
  WICPROGRESSNOTIFICATION_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPROGRESSNOTIFICATION_FORCE_DWORD}

type
  WICComponentSigning = type Integer; 
  {$EXTERNALSYM WICComponentSigning}
const
  WICComponentSigned              = $1; 
  {$EXTERNALSYM WICComponentSigned}
  WICComponentUnsigned            = $2; 
  {$EXTERNALSYM WICComponentUnsigned}
  WICComponentSafe                = $4; 
  {$EXTERNALSYM WICComponentSafe}
  WICComponentDisabled            = $80000000; 
  {$EXTERNALSYM WICComponentDisabled}
  WICCOMPONENTSIGNING_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICCOMPONENTSIGNING_FORCE_DWORD}

type
  WICGifLogicalScreenDescriptorProperties = type Integer; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorProperties}
const
  WICGifLogicalScreenSignature                        = $1; 
  {$EXTERNALSYM WICGifLogicalScreenSignature}
  WICGifLogicalScreenDescriptorWidth                  = $2; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorWidth}
  WICGifLogicalScreenDescriptorHeight                 = $3; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorHeight}
  WICGifLogicalScreenDescriptorGlobalColorTableFlag   = $4;
  {$EXTERNALSYM WICGifLogicalScreenDescriptorGlobalColorTableFlag}
  WICGifLogicalScreenDescriptorColorResolution        = $5; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorColorResolution}
  WICGifLogicalScreenDescriptorSortFlag               = $6; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorSortFlag}
  WICGifLogicalScreenDescriptorGlobalColorTableSize   = $7; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorGlobalColorTableSize}
  WICGifLogicalScreenDescriptorBackgroundColorIndex   = $8;
  {$EXTERNALSYM WICGifLogicalScreenDescriptorBackgroundColorIndex}
  WICGifLogicalScreenDescriptorPixelAspectRatio       = $9; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorPixelAspectRatio}
  WICGifLogicalScreenDescriptorProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICGifLogicalScreenDescriptorProperties_FORCE_DWORD}

type
  WICGifImageDescriptorProperties = type Integer; 
  {$EXTERNALSYM WICGifImageDescriptorProperties}
const
  WICGifImageDescriptorLeft                   = $1; 
  {$EXTERNALSYM WICGifImageDescriptorLeft}
  WICGifImageDescriptorTop                    = $2; 
  {$EXTERNALSYM WICGifImageDescriptorTop}
  WICGifImageDescriptorWidth                  = $3; 
  {$EXTERNALSYM WICGifImageDescriptorWidth}
  WICGifImageDescriptorHeight                 = $4; 
  {$EXTERNALSYM WICGifImageDescriptorHeight}
  WICGifImageDescriptorLocalColorTableFlag    = $5; 
  {$EXTERNALSYM WICGifImageDescriptorLocalColorTableFlag}
  WICGifImageDescriptorInterlaceFlag          = $6; 
  {$EXTERNALSYM WICGifImageDescriptorInterlaceFlag}
  WICGifImageDescriptorSortFlag               = $7; 
  {$EXTERNALSYM WICGifImageDescriptorSortFlag}
  WICGifImageDescriptorLocalColorTableSize    = $8; 
  {$EXTERNALSYM WICGifImageDescriptorLocalColorTableSize}
  WICGifImageDescriptorProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICGifImageDescriptorProperties_FORCE_DWORD}

type
  WICGifGraphicControlExtensionProperties = type Integer; 
  {$EXTERNALSYM WICGifGraphicControlExtensionProperties}
const
  WICGifGraphicControlExtensionDisposal               = $1; 
  {$EXTERNALSYM WICGifGraphicControlExtensionDisposal}
  WICGifGraphicControlExtensionUserInputFlag          = $2; 
  {$EXTERNALSYM WICGifGraphicControlExtensionUserInputFlag}
  WICGifGraphicControlExtensionTransparencyFlag       = $3; 
  {$EXTERNALSYM WICGifGraphicControlExtensionTransparencyFlag}
  WICGifGraphicControlExtensionDelay                  = $4;
  {$EXTERNALSYM WICGifGraphicControlExtensionDelay}
  WICGifGraphicControlExtensionTransparentColorIndex  = $5; 
  {$EXTERNALSYM WICGifGraphicControlExtensionTransparentColorIndex}
  WICGifGraphicControlExtensionProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICGifGraphicControlExtensionProperties_FORCE_DWORD}

type
  WICGifApplicationExtensionProperties = type Integer; 
  {$EXTERNALSYM WICGifApplicationExtensionProperties}
const
  WICGifApplicationExtensionApplication            = $1; 
  {$EXTERNALSYM WICGifApplicationExtensionApplication}
  WICGifApplicationExtensionData                   = $2; 
  {$EXTERNALSYM WICGifApplicationExtensionData}
  WICGifApplicationExtensionProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICGifApplicationExtensionProperties_FORCE_DWORD}

type
  WICGifCommentExtensionProperties = type Integer; 
  {$EXTERNALSYM WICGifCommentExtensionProperties}
const
  WICGifCommentExtensionText                   = $1; 
  {$EXTERNALSYM WICGifCommentExtensionText}
  WICGifCommentExtensionProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICGifCommentExtensionProperties_FORCE_DWORD}

type
  WICJpegCommentProperties = type Integer; 
  {$EXTERNALSYM WICJpegCommentProperties}
const
  WICJpegCommentText                   = $1; 
  {$EXTERNALSYM WICJpegCommentText}
  WICJpegCommentProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICJpegCommentProperties_FORCE_DWORD}

type
  WICJpegLuminanceProperties = type Integer; 
  {$EXTERNALSYM WICJpegLuminanceProperties}
const
  WICJpegLuminanceTable                  = $1; 
  {$EXTERNALSYM WICJpegLuminanceTable}
  WICJpegLuminanceProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICJpegLuminanceProperties_FORCE_DWORD}

type
  WICJpegChrominanceProperties = type Integer; 
  {$EXTERNALSYM WICJpegChrominanceProperties}
const
  WICJpegChrominanceTable                  = $1;
  {$EXTERNALSYM WICJpegChrominanceTable}
  WICJpegChrominanceProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICJpegChrominanceProperties_FORCE_DWORD}

type
  WIC8BIMIptcProperties = type Integer; 
  {$EXTERNALSYM WIC8BIMIptcProperties}
const
  WIC8BIMIptcPString                = 0; 
  {$EXTERNALSYM WIC8BIMIptcPString}
  WIC8BIMIptcEmbeddedIPTC           = $1; 
  {$EXTERNALSYM WIC8BIMIptcEmbeddedIPTC}
  WIC8BIMIptcProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WIC8BIMIptcProperties_FORCE_DWORD}

type
  WIC8BIMResolutionInfoProperties = type Integer; 
  {$EXTERNALSYM WIC8BIMResolutionInfoProperties}
const
  WIC8BIMResolutionInfoPString                = $1; 
  {$EXTERNALSYM WIC8BIMResolutionInfoPString}
  WIC8BIMResolutionInfoHResolution            = $2; 
  {$EXTERNALSYM WIC8BIMResolutionInfoHResolution}
  WIC8BIMResolutionInfoHResolutionUnit        = $3; 
  {$EXTERNALSYM WIC8BIMResolutionInfoHResolutionUnit}
  WIC8BIMResolutionInfoWidthUnit              = $4; 
  {$EXTERNALSYM WIC8BIMResolutionInfoWidthUnit}
  WIC8BIMResolutionInfoVResolution            = $5; 
  {$EXTERNALSYM WIC8BIMResolutionInfoVResolution}
  WIC8BIMResolutionInfoVResolutionUnit        = $6; 
  {$EXTERNALSYM WIC8BIMResolutionInfoVResolutionUnit}
  WIC8BIMResolutionInfoHeightUnit             = $7; 
  {$EXTERNALSYM WIC8BIMResolutionInfoHeightUnit}
  WIC8BIMResolutionInfoProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WIC8BIMResolutionInfoProperties_FORCE_DWORD}

type
  WIC8BIMIptcDigestProperties = type Integer;
  {$EXTERNALSYM WIC8BIMIptcDigestProperties}
const
  WIC8BIMIptcDigestPString                = $1; 
  {$EXTERNALSYM WIC8BIMIptcDigestPString}
  WIC8BIMIptcDigestIptcDigest             = $2; 
  {$EXTERNALSYM WIC8BIMIptcDigestIptcDigest}
  WIC8BIMIptcDigestProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WIC8BIMIptcDigestProperties_FORCE_DWORD}

type
  WICPngGamaProperties = type Integer;
  {$EXTERNALSYM WICPngGamaProperties}
const
  WICPngGamaGamma                  = $1; 
  {$EXTERNALSYM WICPngGamaGamma}
  WICPngGamaProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngGamaProperties_FORCE_DWORD}

type
  WICPngBkgdProperties = type Integer; 
  {$EXTERNALSYM WICPngBkgdProperties}
const
  WICPngBkgdBackgroundColor        = $1; 
  {$EXTERNALSYM WICPngBkgdBackgroundColor}
  WICPngBkgdProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngBkgdProperties_FORCE_DWORD}

type
  WICPngItxtProperties = type Integer; 
  {$EXTERNALSYM WICPngItxtProperties}
const
  WICPngItxtKeyword                = $1; 
  {$EXTERNALSYM WICPngItxtKeyword}
  WICPngItxtCompressionFlag        = $2; 
  {$EXTERNALSYM WICPngItxtCompressionFlag}
  WICPngItxtLanguageTag            = $3; 
  {$EXTERNALSYM WICPngItxtLanguageTag}
  WICPngItxtTranslatedKeyword      = $4; 
  {$EXTERNALSYM WICPngItxtTranslatedKeyword}
  WICPngItxtText                   = $5; 
  {$EXTERNALSYM WICPngItxtText}
  WICPngItxtProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngItxtProperties_FORCE_DWORD}

type
  WICPngChrmProperties = type Integer; 
  {$EXTERNALSYM WICPngChrmProperties}
const
  WICPngChrmWhitePointX            = $1;
  {$EXTERNALSYM WICPngChrmWhitePointX}
  WICPngChrmWhitePointY            = $2; 
  {$EXTERNALSYM WICPngChrmWhitePointY}
  WICPngChrmRedX                   = $3; 
  {$EXTERNALSYM WICPngChrmRedX}
  WICPngChrmRedY                   = $4; 
  {$EXTERNALSYM WICPngChrmRedY}
  WICPngChrmGreenX                 = $5; 
  {$EXTERNALSYM WICPngChrmGreenX}
  WICPngChrmGreenY                 = $6; 
  {$EXTERNALSYM WICPngChrmGreenY}
  WICPngChrmBlueX                  = $7;
  {$EXTERNALSYM WICPngChrmBlueX}
  WICPngChrmBlueY                  = $8; 
  {$EXTERNALSYM WICPngChrmBlueY}
  WICPngChrmProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngChrmProperties_FORCE_DWORD}

type
  WICPngHistProperties = type Integer; 
  {$EXTERNALSYM WICPngHistProperties}
const
  WICPngHistFrequencies            = $1; 
  {$EXTERNALSYM WICPngHistFrequencies}
  WICPngHistProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngHistProperties_FORCE_DWORD}

type
  WICPngIccpProperties = type Integer; 
  {$EXTERNALSYM WICPngIccpProperties}
const
  WICPngIccpProfileName            = $1; 
  {$EXTERNALSYM WICPngIccpProfileName}
  WICPngIccpProfileData            = $2; 
  {$EXTERNALSYM WICPngIccpProfileData}
  WICPngIccpProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngIccpProperties_FORCE_DWORD}

type
  WICPngSrgbProperties = type Integer; 
  {$EXTERNALSYM WICPngSrgbProperties}
const
  WICPngSrgbRenderingIntent        = $1; 
  {$EXTERNALSYM WICPngSrgbRenderingIntent}
  WICPngSrgbProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngSrgbProperties_FORCE_DWORD}

type
  WICPngTimeProperties = type Integer;
  {$EXTERNALSYM WICPngTimeProperties}
const
  WICPngTimeYear                   = $1; 
  {$EXTERNALSYM WICPngTimeYear}
  WICPngTimeMonth                  = $2; 
  {$EXTERNALSYM WICPngTimeMonth}
  WICPngTimeDay                    = $3; 
  {$EXTERNALSYM WICPngTimeDay}
  WICPngTimeHour                   = $4; 
  {$EXTERNALSYM WICPngTimeHour}
  WICPngTimeMinute                 = $5;
  {$EXTERNALSYM WICPngTimeMinute}
  WICPngTimeSecond                 = $6; 
  {$EXTERNALSYM WICPngTimeSecond}
  WICPngTimeProperties_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPngTimeProperties_FORCE_DWORD}

type
  WICSectionAccessLevel = type Integer; 
  {$EXTERNALSYM WICSectionAccessLevel}
const
  WICSectionAccessLevelRead         = $1; 
  {$EXTERNALSYM WICSectionAccessLevelRead}
  WICSectionAccessLevelReadWrite    = $3; 
  {$EXTERNALSYM WICSectionAccessLevelReadWrite}
  WICSectionAccessLevel_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICSectionAccessLevel_FORCE_DWORD}

type
  WICPixelFormatNumericRepresentation = type Integer;
  {$EXTERNALSYM WICPixelFormatNumericRepresentation}
const
  WICPixelFormatNumericRepresentationUnspecified     = 0; 
  {$EXTERNALSYM WICPixelFormatNumericRepresentationUnspecified}
  WICPixelFormatNumericRepresentationIndexed         = $1; 
  {$EXTERNALSYM WICPixelFormatNumericRepresentationIndexed}
  WICPixelFormatNumericRepresentationUnsignedInteger = $2;
  {$EXTERNALSYM WICPixelFormatNumericRepresentationUnsignedInteger}
  WICPixelFormatNumericRepresentationSignedInteger   = $3; 
  {$EXTERNALSYM WICPixelFormatNumericRepresentationSignedInteger}
  WICPixelFormatNumericRepresentationFixed           = $4; 
  {$EXTERNALSYM WICPixelFormatNumericRepresentationFixed}
  WICPixelFormatNumericRepresentationFloat           = $5; 
  {$EXTERNALSYM WICPixelFormatNumericRepresentationFloat}
  WICPixelFormatNumericRepresentation_FORCE_DWORD    = $7FFFFFFF; 
  {$EXTERNALSYM WICPixelFormatNumericRepresentation_FORCE_DWORD}

type
  IWICBitmapSource = interface;
  IWICMetadataQueryWriter = interface;
  IWICBitmapEncoderInfo = interface;
  IWICBitmapFrameEncode = interface;
  IWICBitmapDecoderInfo = interface;
  IWICBitmapFrameDecode = interface;

{ interface IWICPalette }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICPalette);'}
  IWICPalette = interface(IUnknown)
    [SID_IWICPalette]
    function InitializePredefined(ePaletteType: WICBitmapPaletteType; 
      fAddTransparentColor: BOOL): HRESULT; stdcall;

    function InitializeCustom(pColors: PWICColor; cCount: UINT): HRESULT; stdcall;
  
    function InitializeFromBitmap(pISurface: IWICBitmapSource; cCount: UINT;
      fAddTransparentColor: BOOL): HRESULT; stdcall;

    function InitializeFromPalette(pIPalette: IWICPalette): HRESULT; stdcall;

    function GetType(var pePaletteType: WICBitmapPaletteType): HRESULT; stdcall;

    function GetColorCount(var pcCount: UINT): HRESULT; stdcall;

    function GetColors(cCount: UINT; pColors: PWICColor;
      var pcActualColors: UINT): HRESULT; stdcall;

    function IsBlackWhite(var pfIsBlackWhite: BOOL): HRESULT; stdcall;

    function IsGrayscale(var pfIsGrayscale: BOOL): HRESULT; stdcall;

    function HasAlpha(var pfHasAlpha: BOOL): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICPalette}

{ interface IWICBitmapSource }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapSource);'}
  IWICBitmapSource = interface(IUnknown)
    [SID_IWICBitmapSource]
    function GetSize(var puiWidth: UINT; var puiHeight: UINT): HRESULT; stdcall;

    function GetPixelFormat(
      var pPixelFormat: WICPixelFormatGUID): HRESULT; stdcall;

    function GetResolution(var pDpiX: Double; var pDpiY: Double): HRESULT; stdcall;

    function CopyPalette(pIPalette: IWICPalette): HRESULT; stdcall;

    function CopyPixels(prc: PWICRect; cbStride: UINT; cbBufferSize: UINT;
      pbBuffer: PByte): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapSource}

{ interface IWICFormatConverter }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICFormatConverter);'}
  IWICFormatConverter = interface(IWICBitmapSource)
    [SID_IWICFormatConverter]
    function Initialize(pISource: IWICBitmapSource;
      const dstFormat: WICPixelFormatGUID; dither: WICBitmapDitherType;
      const pIPalette: IWICPalette; alphaThresholdPercent: Double;
      paletteTranslate: WICBitmapPaletteType): HRESULT; stdcall;

    function CanConvert(srcPixelFormat: REFWICPixelFormatGUID;
      dstPixelFormat: REFWICPixelFormatGUID;
      var pfCanConvert: BOOL): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICFormatConverter}

{ interface IWICBitmapScaler }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapScaler);'}
  IWICBitmapScaler = interface(IWICBitmapSource)
    [SID_IWICBitmapScaler]
    function Initialize(pISource: IWICBitmapSource; uiWidth: UINT;
      uiHeight: UINT; mode: WICBitmapInterpolationMode): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapScaler}

{ interface IWICBitmapClipper }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapClipper);'}
  IWICBitmapClipper = interface(IWICBitmapSource)
    [SID_IWICBitmapClipper]
    function Initialize(pISource: IWICBitmapSource;
      var prc: WICRect): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapClipper}

{ interface IWICBitmapFlipRotator }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapFlipRotator);'}
  IWICBitmapFlipRotator = interface(IWICBitmapSource)
    [SID_IWICBitmapFlipRotator]
    function Initialize(pISource: IWICBitmapSource;
      options: WICBitmapTransformOptions): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapFlipRotator}

{ interface IWICBitmapLock }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapLock);'}
  IWICBitmapLock = interface(IUnknown)
    [SID_IWICBitmapLock]
    function GetSize(var puiWidth: UINT; var puiHeight: UINT): HRESULT; stdcall;

    function GetStride(var pcbStride: UINT): HRESULT; stdcall;

    function GetDataPointer(var pcbBufferSize: UINT;
      var ppbData: WICInProcPointer): HRESULT; stdcall;

    function GetPixelFormat(
      var pPixelFormat: WICPixelFormatGUID): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapLock}

{ interface IWICBitmap }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmap);'}
  IWICBitmap = interface(IWICBitmapSource)
    [SID_IWICBitmap]
    function Lock(const prcLock: WICRect; flags: DWORD;
      out ppILock: IWICBitmapLock): HRESULT; stdcall;

    function SetPalette(pIPalette: IWICPalette): HRESULT; stdcall;

    function SetResolution(dpiX: Double; dpiY: Double): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmap}

{ interface IWICColorContext }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICColorContext);'}
  IWICColorContext = interface(IUnknown)
    [SID_IWICColorContext]
    function InitializeFromFilename(wzFilename: LPCWSTR): HRESULT; stdcall;

    function InitializeFromMemory(const pbBuffer: PByte;
      cbBufferSize: UINT): HRESULT; stdcall;

    function InitializeFromExifColorSpace(value: UINT): HRESULT; stdcall;

    function GetType(var pType: WICColorContextType): HRESULT; stdcall;

    function GetProfileBytes(cbBuffer: UINT;
      pbBuffer: PBYTE; var pcbActual: UINT): HRESULT; stdcall;

    function GetExifColorSpace(var pValue: UINT): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICColorContext}
  PIWICColorContext = ^IWICColorContext;
  {$EXTERNALSYM PIWICColorContext}

{ interface IWICColorTransform }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICColorTransform);'}
  IWICColorTransform = interface(IWICBitmapSource)
    [SID_IWICColorTransform]
    function Initialize(pIBitmapSource: IWICBitmapSource;
      pIContextSource: IWICColorContext; pIContextDest: IWICColorContext;
      pixelFmtDest: REFWICPixelFormatGUID): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICColorTransform}

{ interface IWICFastMetadataEncoder }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICFastMetadataEncoder);'}
  IWICFastMetadataEncoder = interface(IUnknown)
    [SID_IWICFastMetadataEncoder]
    function Commit: HRESULT; stdcall;

    function GetMetadataQueryWriter(
      out ppIMetadataQueryWriter: IWICMetadataQueryWriter): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICFastMetadataEncoder}

{ interface IWICStream }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICStream);'}
  IWICStream = interface(IStream)
    [SID_IWICStream]
    function InitializeFromIStream(pIStream: IStream): HRESULT; stdcall;

    function InitializeFromFilename(wzFileName: LPCWSTR;
      dwDesiredAccess: DWORD): HRESULT; stdcall;

    function InitializeFromMemory(pbBuffer: WICInProcPointer;
      cbBufferSize: DWORD): HRESULT; stdcall;

    function InitializeFromIStreamRegion(pIStream: IStream;
      ulOffset: ULARGE_INTEGER; ulMaxSize: ULARGE_INTEGER): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICStream}

{ interface IWICEnumMetadataItem }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICEnumMetadataItem);'}
  IWICEnumMetadataItem = interface(IUnknown)
    [SID_IWICEnumMetadataItem]
    function Next(celt: Cardinal;
      rgeltSchema: PPropVariant;
      rgeltID: PPropVariant;
      rgeltValue: PPropVariant;
      var pceltFetched: ULONG): HRESULT; stdcall;

    function Skip(celt: Cardinal): HRESULT; stdcall;

    function Reset: HRESULT; stdcall;

    function Clone(
      out ppIEnumMetadataItem: IWICEnumMetadataItem): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICEnumMetadataItem}

{ interface IWICMetadataQueryReader }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICMetadataQueryReader);'}
  IWICMetadataQueryReader = interface(IUnknown)
    [SID_IWICMetadataQueryReader]
    function GetContainerFormat(var pguidContainerFormat: TGUID): HRESULT; stdcall;

    function GetLocation(cchMaxLength: UINT;
      wzNamespace: PWCHAR;
      var pcchActualLength: UINT): HRESULT; stdcall;

    function GetMetadataByName(wzName: LPCWSTR;
      var pvarValue: PROPVARIANT): HRESULT; stdcall;

    function GetEnumerator(out ppIEnumString: IEnumString): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICMetadataQueryReader}

{ interface IWICMetadataQueryWriter }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICMetadataQueryWriter);'}
  IWICMetadataQueryWriter = interface(IWICMetadataQueryReader)
    [SID_IWICMetadataQueryWriter]
    function SetMetadataByName(wzName: LPCWSTR;
      const pvarValue: TPropVariant): HRESULT; stdcall;

    function RemoveMetadataByName(wzName: LPCWSTR): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICMetadataQueryWriter}

{ interface IWICBitmapEncoder }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapEncoder);'}
  IWICBitmapEncoder = interface(IUnknown)
    [SID_IWICBitmapEncoder]
    function Initialize(pIStream: IStream;
      cacheOption: WICBitmapEncoderCacheOption): HRESULT; stdcall;

    function GetContainerFormat(var pguidContainerFormat: TGUID): HRESULT; stdcall;

    function GetEncoderInfo(
      out ppIEncoderInfo: IWICBitmapEncoderInfo): HRESULT; stdcall;

    function SetColorContexts(cCount: UINT;
      ppIColorContext: PIWICColorContext): HRESULT; stdcall;

    function SetPalette(pIPalette: IWICPalette): HRESULT; stdcall;

    function SetThumbnail(pIThumbnail: IWICBitmapSource): HRESULT; stdcall;

    function SetPreview(pIPreview: IWICBitmapSource): HRESULT; stdcall;

    function CreateNewFrame(out ppIFrameEncode: IWICBitmapFrameEncode;
      var ppIEncoderOptions: IPropertyBag2): HRESULT; stdcall;

    function Commit: HRESULT; stdcall;

    function GetMetadataQueryWriter(
      out ppIMetadataQueryWriter: IWICMetadataQueryWriter): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapEncoder}

{ interface IWICBitmapFrameEncode }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapFrameEncode);'}
  IWICBitmapFrameEncode = interface(IUnknown)
    [SID_IWICBitmapFrameEncode]
    function Initialize(pIEncoderOptions: IPropertyBag2): HRESULT; stdcall;

    function SetSize(uiWidth: UINT; uiHeight: UINT): HRESULT; stdcall;

    function SetResolution(dpiX: Double; dpiY: Double): HRESULT; stdcall;

    function SetPixelFormat(
      var pPixelFormat: WICPixelFormatGUID): HRESULT; stdcall;

    function SetColorContexts(cCount: UINT;
      ppIColorContext: PIWICColorContext): HRESULT; stdcall;

    function SetPalette(pIPalette: IWICPalette): HRESULT; stdcall;

    function SetThumbnail(pIThumbnail: IWICBitmapSource): HRESULT; stdcall;

    function WritePixels(lineCount: UINT; cbStride: UINT; cbBufferSize: UINT;
      pbPixels: PByte): HRESULT; stdcall;

    function WriteSource(pIBitmapSource: IWICBitmapSource;
      prc: PWICRect): HRESULT; stdcall;

    function Commit: HRESULT; stdcall;

    function GetMetadataQueryWriter(
      out ppIMetadataQueryWriter: IWICMetadataQueryWriter): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapFrameEncode}

{ interface IWICBitmapDecoder }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapDecoder);'}
  IWICBitmapDecoder = interface(IUnknown)
    [SID_IWICBitmapDecoder]
    function QueryCapability(pIStream: IStream;
      var pdwCapability: DWORD): HRESULT; stdcall;

    function Initialize(pIStream: IStream;
      cacheOptions: WICDecodeOptions): HRESULT; stdcall;

    function GetContainerFormat(var pguidContainerFormat: TGUID): HRESULT; stdcall;

    function GetDecoderInfo(
      out ppIDecoderInfo: IWICBitmapDecoderInfo): HRESULT; stdcall;

    function CopyPalette(pIPalette: IWICPalette): HRESULT; stdcall;

    function GetMetadataQueryReader(
      out ppIMetadataQueryReader: IWICMetadataQueryReader): HRESULT; stdcall;

    function GetPreview(out ppIBitmapSource: IWICBitmapSource): HRESULT; stdcall;

    function GetColorContexts(cCount: UINT;
      ppIColorContexts: PIWICColorContext;
      var pcActualCount : UINT): HRESULT; stdcall;

    function GetThumbnail(out ppIThumbnail: IWICBitmapSource): HRESULT; stdcall;

    function GetFrameCount(var pCount: UINT): HRESULT; stdcall;

    function GetFrame(index: UINT;
      out ppIBitmapFrame: IWICBitmapFrameDecode): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapDecoder}

{ interface IWICBitmapSourceTransform }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapSourceTransform);'}
  IWICBitmapSourceTransform = interface(IUnknown)
    [SID_IWICBitmapSourceTransform]
    function CopyPixels(var prc: WICRect; uiWidth: UINT; uiHeight: UINT;
      var pguidDstFormat: WICPixelFormatGUID;
      dstTransform: WICBitmapTransformOptions; nStride: UINT; cbBufferSize: UINT;
      pbBuffer: PByte): HRESULT; stdcall;

    function GetClosestSize(var puiWidth: UINT;
      var puiHeight: UINT): HRESULT; stdcall;

    function GetClosestPixelFormat(
      var pguidDstFormat: WICPixelFormatGUID): HRESULT; stdcall;

    function DoesSupportTransform(dstTransform: WICBitmapTransformOptions;
      var pfIsSupported: BOOL): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapSourceTransform}

{ interface IWICBitmapFrameDecode }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapFrameDecode);'}
  IWICBitmapFrameDecode = interface(IWICBitmapSource)
    [SID_IWICBitmapFrameDecode]
    function GetMetadataQueryReader(
      out ppIMetadataQueryReader: IWICMetadataQueryReader): HRESULT; stdcall;

    function GetColorContexts(cCount: UINT;
      ppIColorContexts: PIWICColorContext;
      var pcActualCount : UINT): HRESULT; stdcall;

    function GetThumbnail(out ppIThumbnail: IWICBitmapSource): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapFrameDecode}

{ interface IWICProgressiveLevelControl }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICProgressiveLevelControl);'}
  IWICProgressiveLevelControl = interface(IUnknown)
    [SID_IWICProgressiveLevelControl]
    function GetLevelCount(var pcLevels: UINT): HRESULT; stdcall;

    function GetCurrentLevel(var pnLevel: UINT): HRESULT; stdcall;

    function SetCurrentLevel(nLevel: UINT): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICProgressiveLevelControl}

{ interface IWICProgressCallback }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICProgressCallback);'}
  IWICProgressCallback = interface(IUnknown)
    [SID_IWICProgressCallback]
    function Notify(uFrameNum: Cardinal; operation: WICProgressOperation;
      dblProgress: Double): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICProgressCallback}

{ interface IWICBitmapCodecProgressNotification }
  FNProgressNotification = function(pvData: Pointer; uFrameNum: Cardinal;
    operation: WICProgressOperation; dblProgress: Double): HRESULT; stdcall;
  PFNProgressNotification = FNProgressNotification;
{$EXTERNALSYM PFNProgressNotification}

  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapCodecProgressNotification);'}
  IWICBitmapCodecProgressNotification = interface(IUnknown)
    [SID_IWICBitmapCodecProgressNotification]
    function RegisterProgressNotification(
      pfnProgressNotification: PFNProgressNotification; pvData: Pointer;
      dwProgressFlags: DWORD): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapCodecProgressNotification}

{ interface IWICComponentInfo }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICComponentInfo);'}
  IWICComponentInfo = interface(IUnknown)
    [SID_IWICComponentInfo]
    function GetComponentType(var pType: WICComponentType): HRESULT; stdcall;

    function GetCLSID(var pclsid: TGUID): HRESULT; stdcall;

    function GetSigningStatus(var pStatus: DWORD): HRESULT; stdcall;

    function GetAuthor(cchAuthor: UINT;
      wzAuthor: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetVendorGUID(var pguidVendor: TGUID): HRESULT; stdcall;

    function GetVersion(cchVersion: UINT;
      wzVersion: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetSpecVersion(cchSpecVersion: UINT;
      wzSpecVersion: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetFriendlyName(cchFriendlyName: UINT;
      wzFriendlyName: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICComponentInfo}

{ interface IWICFormatConverterInfo }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICFormatConverterInfo);'}
  IWICFormatConverterInfo = interface(IWICComponentInfo)
    [SID_IWICFormatConverterInfo]
    function GetPixelFormats(cFormats: UINT;
      pPixleFormatGUIDs: PWICPixelFormatGUID;
      var pcActual: UINT): HRESULT; stdcall;

    function CreateInstance(
      out ppIConverter: IWICFormatConverter): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICFormatConverterInfo}

{ interface IWICBitmapCodecInfo }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapCodecInfo);'}
  IWICBitmapCodecInfo = interface(IWICComponentInfo)
    [SID_IWICBitmapCodecInfo]
    function GetContainerFormat(var pguidContainerFormat: TGUID): HRESULT; stdcall;

    function GetPixelFormats(cFormats: UINT;
      var guidPixelFormats: PGUID;
      var pcActual: UINT): HRESULT; stdcall;

    function GetColorManagementVersion(cchColorManagementVersion: UINT;
      wzColorManagementVersion: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetDeviceManufacturer(cchDeviceManufacturer: UINT;
      wzDeviceManufacturer: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetDeviceModels(cchDeviceModels: UINT;
      wzDeviceModels: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetMimeTypes(cchMimeTypes: UINT;
      wzMimeTypes: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function GetFileExtensions(cchFileExtensions: UINT;
      wzFileExtensions: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;

    function DoesSupportAnimation(var pfSupportAnimation: BOOL): HRESULT; stdcall;

    function DoesSupportChromakey(var pfSupportChromakey: BOOL): HRESULT; stdcall;

    function DoesSupportLossless(var pfSupportLossless: BOOL): HRESULT; stdcall;

    function DoesSupportMultiframe(
      var pfSupportMultiframe: BOOL): HRESULT; stdcall;

    function MatchesMimeType(wzMimeType: LPCWSTR;
      var pfMatches: BOOL): HRESULT; stdcall;

  end;
  {$EXTERNALSYM IWICBitmapCodecInfo}

{ interface IWICBitmapEncoderInfo }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapEncoderInfo);'}
  IWICBitmapEncoderInfo = interface(IWICBitmapCodecInfo)
    [SID_IWICBitmapEncoderInfo]
    function CreateInstance(
      out ppIBitmapEncoder: IWICBitmapEncoder): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapEncoderInfo}

{ interface IWICBitmapDecoderInfo }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICBitmapDecoderInfo);'}
  IWICBitmapDecoderInfo = interface(IWICBitmapCodecInfo)
    [SID_IWICBitmapDecoderInfo]
    function GetPatterns(cbSizePatterns: UINT; pPatterns: PWICBitmapPattern;
      var pcPatterns: UINT; var pcbPatternsActual: UINT): HRESULT; stdcall;

    function MatchesPattern(pIStream: IStream;
      var pfMatches: BOOL): HRESULT; stdcall;

    function CreateInstance(
      out ppIBitmapDecoder: IWICBitmapDecoder): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICBitmapDecoderInfo}

{ interface IWICPixelFormatInfo }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICPixelFormatInfo);'}
  IWICPixelFormatInfo = interface(IWICComponentInfo)
    [SID_IWICPixelFormatInfo]
    function GetFormatGUID(var pFormat: TGUID): HRESULT; stdcall;

    function GetColorContext(
      out ppIColorContext: IWICColorContext): HRESULT; stdcall;

    function GetBitsPerPixel(var puiBitsPerPixel: UINT): HRESULT; stdcall;

    function GetChannelCount(var puiChannelCount: UINT): HRESULT; stdcall;

    function GetChannelMask(uiChannelIndex: UINT; cbMaskBuffer: UINT;
      pbMaskBuffer: PBYTE; var pcbActual: UINT): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICPixelFormatInfo}

{ interface IWICPixelFormatInfo2 }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICPixelFormatInfo2);'}
  IWICPixelFormatInfo2 = interface(IWICPixelFormatInfo)
    [SID_IWICPixelFormatInfo2]
    function SupportsTransparency(
      var pfSupportsTransparency: BOOL): HRESULT; stdcall;

    function GetNumericRepresentation(
      var pNumericRepresentation: WICPixelFormatNumericRepresentation): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICPixelFormatInfo2}

{ interface IWICImagingFactory }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICImagingFactory);'}
  IWICImagingFactory = interface(IUnknown)
    [SID_IWICImagingFactory]
    function CreateDecoderFromFilename(wzFilename: LPCWSTR; pguidVendor :PGUID {const pguidVendor: TGUID};
      dwDesiredAccess: DWORD; metadataOptions: WICDecodeOptions;
      out ppIDecoder: IWICBitmapDecoder): HRESULT; stdcall;

    function CreateDecoderFromStream(pIStream: IStream; const pguidVendor: TGUID;
      metadataOptions: WICDecodeOptions;
      out ppIDecoder: IWICBitmapDecoder): HRESULT; stdcall;

    function CreateDecoderFromFileHandle(hFile: ULONG_PTR; const pguidVendor: TGUID;
      metadataOptions: WICDecodeOptions;
      out ppIDecoder: IWICBitmapDecoder): HRESULT; stdcall;

    function CreateComponentInfo(const clsidComponent: TGUID;
      out ppIInfo: IWICComponentInfo): HRESULT; stdcall;

    function CreateDecoder(const guidContainerFormat: TGuid; const pguidVendor: TGUID;
      out ppIDecoder: IWICBitmapDecoder): HRESULT; stdcall;

    function CreateEncoder(const guidContainerFormat: TGuid; const pguidVendor: TGUID;
      out ppIEncoder: IWICBitmapEncoder): HRESULT; stdcall;

    function CreatePalette(out ppIPalette: IWICPalette): HRESULT; stdcall;

    function CreateFormatConverter(
      out ppIFormatConverter: IWICFormatConverter): HRESULT; stdcall;

    function CreateBitmapScaler(
      out ppIBitmapScaler: IWICBitmapScaler): HRESULT; stdcall;

    function CreateBitmapClipper(
      out ppIBitmapClipper: IWICBitmapClipper): HRESULT; stdcall;

    function CreateBitmapFlipRotator(
      out ppIBitmapFlipRotator: IWICBitmapFlipRotator): HRESULT; stdcall;

    function CreateStream(out ppIWICStream: IWICStream): HRESULT; stdcall;

    function CreateColorContext(
      out ppIWICColorContext: IWICColorContext): HRESULT; stdcall;

    function CreateColorTransformer(
      out ppIWICColorTransform: IWICColorTransform): HRESULT; stdcall;

    function CreateBitmap(uiWidth: UINT; uiHeight: UINT;
      pixelFormat: REFWICPixelFormatGUID; option: WICBitmapCreateCacheOption;
      out ppIBitmap: IWICBitmap): HRESULT; stdcall;

    function CreateBitmapFromSource(pIBitmapSource: IWICBitmapSource;
      option: WICBitmapCreateCacheOption;
      out ppIBitmap: IWICBitmap): HRESULT; stdcall;

    function CreateBitmapFromSourceRect(pIBitmapSource: IWICBitmapSource;
      x: UINT; y: UINT; width: UINT; height: UINT;
      out ppIBitmap: IWICBitmap): HRESULT; stdcall;

    function CreateBitmapFromMemory(uiWidth: UINT; uiHeight: UINT;
      const pixelFormat: WICPixelFormatGUID; cbStride: UINT; cbBufferSize: UINT;
      pbBuffer: PByte; out ppIBitmap: IWICBitmap): HRESULT; stdcall;

    function CreateBitmapFromHBITMAP(hBitmap: HBITMAP; hPalette: HPALETTE;
      options: WICBitmapAlphaChannelOption;
      out ppIBitmap: IWICBitmap): HRESULT; stdcall;

    function CreateBitmapFromHICON(hIcon: HICON;
      out ppIBitmap: IWICBitmap): HRESULT; stdcall;

    function CreateComponentEnumerator(componentTypes: DWORD; options: DWORD;
      out ppIEnumUnknown: IEnumUnknown): HRESULT; stdcall;

    function CreateFastMetadataEncoderFromDecoder(pIDecoder: IWICBitmapDecoder;
      out ppIFastEncoder: IWICFastMetadataEncoder): HRESULT; stdcall;

    function CreateFastMetadataEncoderFromFrameDecode(
      pIFrameDecoder: IWICBitmapFrameDecode;
      out ppIFastEncoder: IWICFastMetadataEncoder): HRESULT; stdcall;

    function CreateQueryWriter(const guidMetadataFormat: TGuid;
      const pguidVendor: TGUID;
      out ppIQueryWriter: IWICMetadataQueryWriter): HRESULT; stdcall;

    function CreateQueryWriterFromReader(pIQueryReader: IWICMetadataQueryReader;
      const pguidVendor: TGUID;
      out ppIQueryWriter: IWICMetadataQueryWriter): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICImagingFactory}


function WICConvertBitmapSource(const dstFormat: WICPixelFormatGUID;
  pISrc: IWICBitmapSource; out ppIDst: IWICBitmapSource): HRESULT; stdcall;
{$EXTERNALSYM WICConvertBitmapSource}
function WICCreateBitmapFromSection(width: UINT; height: UINT;
  const pixelFormat: WICPixelFormatGUID; hSection: THandle; stride: UINT;
  offset: UINT; out ppIBitmap: IWICBitmap): HRESULT; stdcall;
{$EXTERNALSYM WICCreateBitmapFromSection}
function WICCreateBitmapFromSectionEx(width: UINT; height: UINT;
  const pixelFormat: WICPixelFormatGUID; hSection: THandle; stride: UINT;
  offset: UINT; desiredAccessLevel: WICSectionAccessLevel;
  out ppIBitmap: IWICBitmap): HRESULT; stdcall;
{$EXTERNALSYM WICCreateBitmapFromSectionEx}
function WICMapGuidToShortName(const guid: TGuid; cchName: UINT;
  wzName: PWCHAR; var pcchActual: UINT): HRESULT; stdcall;
{$EXTERNALSYM WICMapGuidToShortName}
function WICMapShortNameToGuid(wzName: PWCHAR; var pguid: TGUID): HRESULT; stdcall;
{$EXTERNALSYM WICMapShortNameToGuid}
function WICMapSchemaToName(const guidMetadataFormat: TGuid; pwzSchema: LPWSTR;
  cchName: UINT; var wzName: WCHAR; var pcchActual: UINT): HRESULT; stdcall;
{$EXTERNALSYM WICMapSchemaToName}


const
  FACILITY_WINCODEC_ERR = $898;
  {$EXTERNALSYM FACILITY_WINCODEC_ERR}
  WINCODEC_ERR_BASE = $2000;
  {$EXTERNALSYM WINCODEC_ERR_BASE}

  WINCODEC_ERR_GENERIC_ERROR                    = E_FAIL;
  {$EXTERNALSYM WINCODEC_ERR_GENERIC_ERROR}
  WINCODEC_ERR_INVALIDPARAMETER                 = E_INVALIDARG;
  {$EXTERNALSYM WINCODEC_ERR_INVALIDPARAMETER}
  WINCODEC_ERR_OUTOFMEMORY                      = E_OUTOFMEMORY;
  {$EXTERNALSYM WINCODEC_ERR_OUTOFMEMORY}
  WINCODEC_ERR_NOTIMPLEMENTED                   = E_NOTIMPL;
  {$EXTERNALSYM WINCODEC_ERR_NOTIMPLEMENTED}
  WINCODEC_ERR_ABORTED                          = E_ABORT;
  {$EXTERNALSYM WINCODEC_ERR_ABORTED}
  WINCODEC_ERR_ACCESSDENIED                     = E_ACCESSDENIED;
  {$EXTERNALSYM WINCODEC_ERR_ACCESSDENIED}
  WINCODEC_ERR_VALUEOVERFLOW                    = $80070216; //INTSAFE_E_ARITHMETIC_OVERFLOW;
  {$EXTERNALSYM WINCODEC_ERR_VALUEOVERFLOW}
  WINCODEC_ERR_WRONGSTATE                       = $88982f04;
  {$EXTERNALSYM WINCODEC_ERR_WRONGSTATE}
  WINCODEC_ERR_VALUEOUTOFRANGE                  = $88982f05;
  {$EXTERNALSYM WINCODEC_ERR_VALUEOUTOFRANGE}
  WINCODEC_ERR_UNKNOWNIMAGEFORMAT               = $88982f07;
  {$EXTERNALSYM WINCODEC_ERR_UNKNOWNIMAGEFORMAT}
  WINCODEC_ERR_UNSUPPORTEDVERSION               = $88982f0B;
  {$EXTERNALSYM WINCODEC_ERR_UNSUPPORTEDVERSION}
  WINCODEC_ERR_NOTINITIALIZED                   = $88982f0C;
  {$EXTERNALSYM WINCODEC_ERR_NOTINITIALIZED}
  WINCODEC_ERR_ALREADYLOCKED                    = $88982f0D;
  {$EXTERNALSYM WINCODEC_ERR_ALREADYLOCKED}
  WINCODEC_ERR_PROPERTYNOTFOUND                 = $88982f40;
  {$EXTERNALSYM WINCODEC_ERR_PROPERTYNOTFOUND}
  WINCODEC_ERR_PROPERTYNOTSUPPORTED             = $88982f41;
  {$EXTERNALSYM WINCODEC_ERR_PROPERTYNOTSUPPORTED}
  WINCODEC_ERR_PROPERTYSIZE                     = $88982f42;
  {$EXTERNALSYM WINCODEC_ERR_PROPERTYSIZE}
  WINCODEC_ERR_CODECPRESENT                     = $88982f43;
  {$EXTERNALSYM WINCODEC_ERR_CODECPRESENT}
  WINCODEC_ERR_CODECNOTHUMBNAIL                 = $88982f44;
  {$EXTERNALSYM WINCODEC_ERR_CODECNOTHUMBNAIL}
  WINCODEC_ERR_PALETTEUNAVAILABLE               = $88982f45;
  {$EXTERNALSYM WINCODEC_ERR_PALETTEUNAVAILABLE}
  WINCODEC_ERR_CODECTOOMANYSCANLINES            = $88982f46;
  {$EXTERNALSYM WINCODEC_ERR_CODECTOOMANYSCANLINES}
  WINCODEC_ERR_INTERNALERROR                    = $88982f48;
  {$EXTERNALSYM WINCODEC_ERR_INTERNALERROR}
  WINCODEC_ERR_SOURCERECTDOESNOTMATCHDIMENSIONS = $88982f49;
  {$EXTERNALSYM WINCODEC_ERR_SOURCERECTDOESNOTMATCHDIMENSIONS}
  WINCODEC_ERR_COMPONENTNOTFOUND                = $88982f50;
  {$EXTERNALSYM WINCODEC_ERR_COMPONENTNOTFOUND}
  WINCODEC_ERR_IMAGESIZEOUTOFRANGE              = $88982f51;
  {$EXTERNALSYM WINCODEC_ERR_IMAGESIZEOUTOFRANGE}
  WINCODEC_ERR_TOOMUCHMETADATA                  = $88982f52;
  {$EXTERNALSYM WINCODEC_ERR_TOOMUCHMETADATA}
  WINCODEC_ERR_BADIMAGE                         = $88982f60;
  {$EXTERNALSYM WINCODEC_ERR_BADIMAGE}
  WINCODEC_ERR_BADHEADER                        = $88982f61;
  {$EXTERNALSYM WINCODEC_ERR_BADHEADER}
  WINCODEC_ERR_FRAMEMISSING                     = $88982f62;
  {$EXTERNALSYM WINCODEC_ERR_FRAMEMISSING}
  WINCODEC_ERR_BADMETADATAHEADER                = $88982f63;
  {$EXTERNALSYM WINCODEC_ERR_BADMETADATAHEADER}
  WINCODEC_ERR_BADSTREAMDATA                    = $88982f70;
  {$EXTERNALSYM WINCODEC_ERR_BADSTREAMDATA}
  WINCODEC_ERR_STREAMWRITE                      = $88982f71;
  {$EXTERNALSYM WINCODEC_ERR_STREAMWRITE}
  WINCODEC_ERR_STREAMREAD                       = $88982f72;
  {$EXTERNALSYM WINCODEC_ERR_STREAMREAD}
  WINCODEC_ERR_STREAMNOTAVAILABLE               = $88982f73;
  {$EXTERNALSYM WINCODEC_ERR_STREAMNOTAVAILABLE}
  WINCODEC_ERR_UNSUPPORTEDPIXELFORMAT           = $88982f80;
  {$EXTERNALSYM WINCODEC_ERR_UNSUPPORTEDPIXELFORMAT}
  WINCODEC_ERR_UNSUPPORTEDOPERATION             = $88982f81;
  {$EXTERNALSYM WINCODEC_ERR_UNSUPPORTEDOPERATION}
  WINCODEC_ERR_INVALIDREGISTRATION              = $88982f8A;
  {$EXTERNALSYM WINCODEC_ERR_INVALIDREGISTRATION}
  WINCODEC_ERR_COMPONENTINITIALIZEFAILURE       = $88982f8B;
  {$EXTERNALSYM WINCODEC_ERR_COMPONENTINITIALIZEFAILURE}
  WINCODEC_ERR_INSUFFICIENTBUFFER               = $88982f8C;
  {$EXTERNALSYM WINCODEC_ERR_INSUFFICIENTBUFFER}
  WINCODEC_ERR_DUPLICATEMETADATAPRESENT         = $88982f8D;
  {$EXTERNALSYM WINCODEC_ERR_DUPLICATEMETADATAPRESENT}
  WINCODEC_ERR_PROPERTYUNEXPECTEDTYPE           = $88982f8E;
  {$EXTERNALSYM WINCODEC_ERR_PROPERTYUNEXPECTEDTYPE}
  WINCODEC_ERR_UNEXPECTEDSIZE                   = $88982f8F;
  {$EXTERNALSYM WINCODEC_ERR_UNEXPECTEDSIZE}
  WINCODEC_ERR_INVALIDQUERYREQUEST              = $88982f90;
  {$EXTERNALSYM WINCODEC_ERR_INVALIDQUERYREQUEST}
  WINCODEC_ERR_UNEXPECTEDMETADATATYPE           = $88982f91;
  {$EXTERNALSYM WINCODEC_ERR_UNEXPECTEDMETADATATYPE}
  WINCODEC_ERR_REQUESTONLYVALIDATMETADATAROOT   = $88982f92;
  {$EXTERNALSYM WINCODEC_ERR_REQUESTONLYVALIDATMETADATAROOT}
  WINCODEC_ERR_INVALIDQUERYCHARACTER            = $88982f93;
  {$EXTERNALSYM WINCODEC_ERR_INVALIDQUERYCHARACTER}
  WINCODEC_ERR_WIN32ERROR                       = $88982f94;
  {$EXTERNALSYM WINCODEC_ERR_WIN32ERROR}
  WINCODEC_ERR_INVALIDPROGRESSIVELEVEL          = $88982f95;
  {$EXTERNALSYM WINCODEC_ERR_INVALIDPROGRESSIVELEVEL}

type
  WICTiffCompressionOption = type Integer; 
  {$EXTERNALSYM WICTiffCompressionOption}
const
  WICTiffCompressionDontCare           = 0; 
  {$EXTERNALSYM WICTiffCompressionDontCare}
  WICTiffCompressionNone               = $1; 
  {$EXTERNALSYM WICTiffCompressionNone}
  WICTiffCompressionCCITT3             = $2; 
  {$EXTERNALSYM WICTiffCompressionCCITT3}
  WICTiffCompressionCCITT4             = $3; 
  {$EXTERNALSYM WICTiffCompressionCCITT4}
  WICTiffCompressionLZW                = $4; 
  {$EXTERNALSYM WICTiffCompressionLZW}
  WICTiffCompressionRLE                = $5; 
  {$EXTERNALSYM WICTiffCompressionRLE}
  WICTiffCompressionZIP                = $6; 
  {$EXTERNALSYM WICTiffCompressionZIP}
  WICTiffCompressionLZWHDifferencing   = $7; 
  {$EXTERNALSYM WICTiffCompressionLZWHDifferencing}
  WICTIFFCOMPRESSIONOPTION_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICTIFFCOMPRESSIONOPTION_FORCE_DWORD}

type
  WICJpegYCrCbSubsamplingOption = type Integer; 
  {$EXTERNALSYM WICJpegYCrCbSubsamplingOption}
const
  WICJpegYCrCbSubsamplingDefault      = 0;
  {$EXTERNALSYM WICJpegYCrCbSubsamplingDefault}
  WICJpegYCrCbSubsampling420          = $1; 
  {$EXTERNALSYM WICJpegYCrCbSubsampling420}
  WICJpegYCrCbSubsampling422          = $2; 
  {$EXTERNALSYM WICJpegYCrCbSubsampling422}
  WICJpegYCrCbSubsampling444          = $3; 
  {$EXTERNALSYM WICJpegYCrCbSubsampling444}
  WICJPEGYCRCBSUBSAMPLING_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICJPEGYCRCBSUBSAMPLING_FORCE_DWORD}

type
  WICPngFilterOption = type Integer; 
  {$EXTERNALSYM WICPngFilterOption}
const
  WICPngFilterUnspecified        = 0; 
  {$EXTERNALSYM WICPngFilterUnspecified}
  WICPngFilterNone               = $1; 
  {$EXTERNALSYM WICPngFilterNone}
  WICPngFilterSub                = $2; 
  {$EXTERNALSYM WICPngFilterSub}
  WICPngFilterUp                 = $3; 
  {$EXTERNALSYM WICPngFilterUp}
  WICPngFilterAverage            = $4; 
  {$EXTERNALSYM WICPngFilterAverage}
  WICPngFilterPaeth              = $5; 
  {$EXTERNALSYM WICPngFilterPaeth}
  WICPngFilterAdaptive           = $6; 
  {$EXTERNALSYM WICPngFilterAdaptive}
  WICPNGFILTEROPTION_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICPNGFILTEROPTION_FORCE_DWORD}

type
  WICNamedWhitePoint = type Integer;
  {$EXTERNALSYM WICNamedWhitePoint}
const
  WICWhitePointDefault           = $1; 
  {$EXTERNALSYM WICWhitePointDefault}
  WICWhitePointDaylight          = $2; 
  {$EXTERNALSYM WICWhitePointDaylight}
  WICWhitePointCloudy            = $4; 
  {$EXTERNALSYM WICWhitePointCloudy}
  WICWhitePointShade             = $8; 
  {$EXTERNALSYM WICWhitePointShade}
  WICWhitePointTungsten          = $10; 
  {$EXTERNALSYM WICWhitePointTungsten}
  WICWhitePointFluorescent       = $20; 
  {$EXTERNALSYM WICWhitePointFluorescent}
  WICWhitePointFlash             = $40; 
  {$EXTERNALSYM WICWhitePointFlash}
  WICWhitePointUnderwater        = $80; 
  {$EXTERNALSYM WICWhitePointUnderwater}
  WICWhitePointCustom            = $100; 
  {$EXTERNALSYM WICWhitePointCustom}
  WICWhitePointAutoWhiteBalance  = $200; 
  {$EXTERNALSYM WICWhitePointAutoWhiteBalance}
  WICWhitePointAsShot            = WICWHITEPOINTDEFAULT; 
  {$EXTERNALSYM WICWhitePointAsShot}
  WICNAMEDWHITEPOINT_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICNAMEDWHITEPOINT_FORCE_DWORD}

type
  WICRawCapabilities = type Integer; 
  {$EXTERNALSYM WICRawCapabilities}
const
  WICRawCapabilityNotSupported   = 0; 
  {$EXTERNALSYM WICRawCapabilityNotSupported}
  WICRawCapabilityGetSupported   = $1; 
  {$EXTERNALSYM WICRawCapabilityGetSupported}
  WICRawCapabilityFullySupported = $2; 
  {$EXTERNALSYM WICRawCapabilityFullySupported}
  WICRAWCAPABILITIES_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICRAWCAPABILITIES_FORCE_DWORD}

type
  WICRawRotationCapabilities = type Integer; 
  {$EXTERNALSYM WICRawRotationCapabilities}
const
  WICRawRotationCapabilityNotSupported           = 0; 
  {$EXTERNALSYM WICRawRotationCapabilityNotSupported}
  WICRawRotationCapabilityGetSupported           = $1; 
  {$EXTERNALSYM WICRawRotationCapabilityGetSupported}
  WICRawRotationCapabilityNinetyDegreesSupported = $2; 
  {$EXTERNALSYM WICRawRotationCapabilityNinetyDegreesSupported}
  WICRawRotationCapabilityFullySupported         = $3; 
  {$EXTERNALSYM WICRawRotationCapabilityFullySupported}
  WICRAWROTATIONCAPABILITIES_FORCE_DWORD         = $7FFFFFFF; 
  {$EXTERNALSYM WICRAWROTATIONCAPABILITIES_FORCE_DWORD}

type
  WICRawCapabilitiesInfo = record
    cbSize: UINT;
    CodecMajorVersion: UINT;
    CodecMinorVersion: UINT;
    ExposureCompensationSupport: WICRawCapabilities;
    ContrastSupport: WICRawCapabilities;
    RGBWhitePointSupport: WICRawCapabilities;
    NamedWhitePointSupport: WICRawCapabilities;
    NamedWhitePointSupportMask: UINT;
    KelvinWhitePointSupport: WICRawCapabilities;
    GammaSupport: WICRawCapabilities;
    TintSupport: WICRawCapabilities;
    SaturationSupport: WICRawCapabilities;
    SharpnessSupport: WICRawCapabilities;
    NoiseReductionSupport: WICRawCapabilities;
    DestinationColorProfileSupport: WICRawCapabilities;
    ToneCurveSupport: WICRawCapabilities;
    RotationSupport: WICRawRotationCapabilities;
    RenderModeSupport: WICRawCapabilities;
  end;
  {$EXTERNALSYM WICRawCapabilitiesInfo}

type
  WICRawParameterSet = type Integer; 
  {$EXTERNALSYM WICRawParameterSet}
const
  WICAsShotParameterSet          = $1; 
  {$EXTERNALSYM WICAsShotParameterSet}
  WICUserAdjustedParameterSet    = $2; 
  {$EXTERNALSYM WICUserAdjustedParameterSet}
  WICAutoAdjustedParameterSet    = $3; 
  {$EXTERNALSYM WICAutoAdjustedParameterSet}
  WICRAWPARAMETERSET_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICRAWPARAMETERSET_FORCE_DWORD}

type
  WICRawRenderMode = type Integer; 
  {$EXTERNALSYM WICRawRenderMode}
const
  WICRawRenderModeDraft        = $1; 
  {$EXTERNALSYM WICRawRenderModeDraft}
  WICRawRenderModeNormal       = $2; 
  {$EXTERNALSYM WICRawRenderModeNormal}
  WICRawRenderModeBestQuality  = $3; 
  {$EXTERNALSYM WICRawRenderModeBestQuality}
  WICRAWRENDERMODE_FORCE_DWORD = $7FFFFFFF; 
  {$EXTERNALSYM WICRAWRENDERMODE_FORCE_DWORD}

type
  WICRawToneCurvePoint = record
    Input: Double;
    Output: Double;
  end;
  {$EXTERNALSYM WICRawToneCurvePoint}

  WICRawToneCurve = record
    cPoints: UINT;
    apoints: array[0..0] of WICRawToneCurvePoint;
  end;
  {$EXTERNALSYM WICRawToneCurve}
  TWICRawToneCurve = WICRawToneCurve;
  PWICRawToneCurve = ^TWICRawToneCurve;

const
  WICRawChangeNotification_ExposureCompensation    = $00000001;
  {$EXTERNALSYM WICRawChangeNotification_ExposureCompensation}
  WICRawChangeNotification_NamedWhitePoint         = $00000002;
  {$EXTERNALSYM WICRawChangeNotification_NamedWhitePoint}
  WICRawChangeNotification_KelvinWhitePoint        = $00000004;
  {$EXTERNALSYM WICRawChangeNotification_KelvinWhitePoint}
  WICRawChangeNotification_RGBWhitePoint           = $00000008;
  {$EXTERNALSYM WICRawChangeNotification_RGBWhitePoint}
  WICRawChangeNotification_Contrast                = $00000010;
  {$EXTERNALSYM WICRawChangeNotification_Contrast}
  WICRawChangeNotification_Gamma                   = $00000020;
  {$EXTERNALSYM WICRawChangeNotification_Gamma}
  WICRawChangeNotification_Sharpness               = $00000040;
  {$EXTERNALSYM WICRawChangeNotification_Sharpness}
  WICRawChangeNotification_Saturation              = $00000080;
  {$EXTERNALSYM WICRawChangeNotification_Saturation}
  WICRawChangeNotification_Tint                    = $00000100;
  {$EXTERNALSYM WICRawChangeNotification_Tint}
  WICRawChangeNotification_NoiseReduction          = $00000200;
  {$EXTERNALSYM WICRawChangeNotification_NoiseReduction}
  WICRawChangeNotification_DestinationColorContext = $00000400;
  {$EXTERNALSYM WICRawChangeNotification_DestinationColorContext}
  WICRawChangeNotification_ToneCurve               = $00000800;
  {$EXTERNALSYM WICRawChangeNotification_ToneCurve}
  WICRawChangeNotification_Rotation                = $00001000;
  {$EXTERNALSYM WICRawChangeNotification_Rotation}
  WICRawChangeNotification_RenderMode              = $00002000;
  {$EXTERNALSYM WICRawChangeNotification_RenderMode}

{ interface IWICDevelopRawNotificationCallback }
type
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICDevelopRawNotificationCallback);'}
  IWICDevelopRawNotificationCallback = interface(IUnknown)
    [SID_IWICDevelopRawNotificationCallback]
    function Notify(NotificationMask: UINT): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICDevelopRawNotificationCallback}

{ interface IWICDevelopRaw }
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IWICDevelopRaw);'}
  IWICDevelopRaw = interface(IWICBitmapFrameDecode)
    [SID_IWICDevelopRaw]
    function QueryRawCapabilitiesInfo(
      var pInfo: WICRawCapabilitiesInfo): HRESULT; stdcall;

    function LoadParameterSet(ParameterSet: WICRawParameterSet): HRESULT; stdcall;

    function GetCurrentParameterSet(
      out ppCurrentParameterSet: IPropertyBag2): HRESULT; stdcall;

    function SetExposureCompensation(ev: Double): HRESULT; stdcall;

    function GetExposureCompensation(var pEV: Double): HRESULT; stdcall;

    function SetWhitePointRGB(Red: UINT; Green: UINT;
      Blue: UINT): HRESULT; stdcall;

    function GetWhitePointRGB(var pRed: UINT; var pGreen: UINT;
      var pBlue: UINT): HRESULT; stdcall;

    function SetNamedWhitePoint(WhitePoint: WICNamedWhitePoint): HRESULT; stdcall;

    function GetNamedWhitePoint(
      var pWhitePoint: WICNamedWhitePoint): HRESULT; stdcall;

    function SetWhitePointKelvin(WhitePointKelvin: UINT): HRESULT; stdcall;

    function GetWhitePointKelvin(var pWhitePointKelvin: UINT): HRESULT; stdcall;

    function GetKelvinRangeInfo(var pMinKelvinTemp: UINT; var pMaxKelvinTemp: UINT;
      var pKelvinTempStepValue: UINT): HRESULT; stdcall;

    function SetContrast(Contrast: Double): HRESULT; stdcall;

    function GetContrast(var pContrast: Double): HRESULT; stdcall;

    function SetGamma(Gamma: Double): HRESULT; stdcall;

    function GetGamma(var pGamma: Double): HRESULT; stdcall;

    function SetSharpness(Sharpness: Double): HRESULT; stdcall;

    function GetSharpness(var pSharpness: Double): HRESULT; stdcall;

    function SetSaturation(Saturation: Double): HRESULT; stdcall;

    function GetSaturation(var pSaturation: Double): HRESULT; stdcall;

    function SetTint(Tint: Double): HRESULT; stdcall;

    function GetTint(var pTint: Double): HRESULT; stdcall;

    function SetNoiseReduction(NoiseReduction: Double): HRESULT; stdcall;

    function GetNoiseReduction(var pNoiseReduction: Double): HRESULT; stdcall;

    function SetDestinationColorContext(
      pColorContext: IWICColorContext): HRESULT; stdcall;

    function SetToneCurve(cbToneCurveSize: UINT;
      pToneCurve: PWICRawToneCurve): HRESULT; stdcall;

    function GetToneCurve(cbToneCurveBufferSize: UINT;
      pToneCurve: PWICRawToneCurve;
      var pcbActualToneCurveBufferSize: UINT): HRESULT; stdcall;

    function SetRotation(Rotation: Double): HRESULT; stdcall;

    function GetRotation(var pRotation: Double): HRESULT; stdcall;

    function SetRenderMode(RenderMode: WICRawRenderMode): HRESULT; stdcall;

    function GetRenderMode(var pRenderMode: WICRawRenderMode): HRESULT; stdcall;

    function SetNotificationCallback(
      pCallback: IWICDevelopRawNotificationCallback): HRESULT; stdcall;
  end;
  {$EXTERNALSYM IWICDevelopRaw}


implementation

const
  WincodecLib = 'windowscodecs.dll';


function WICConvertBitmapSource; external WincodecLib name 'WICConvertBitmapSource' {$ifdef bDelayed}delayed{$endif};
function WICCreateBitmapFromSection; external WincodecLib name 'WICCreateBitmapFromSection' {$ifdef bDelayed}delayed{$endif};
function WICCreateBitmapFromSectionEx; external WincodecLib name 'WICCreateBitmapFromSectionEx' {$ifdef bDelayed}delayed{$endif};
function WICMapGuidToShortName; external WincodecLib name 'WICMapGuidToShortName' {$ifdef bDelayed}delayed{$endif};
function WICMapShortNameToGuid; external WincodecLib name 'WICMapShortNameToGuid' {$ifdef bDelayed}delayed{$endif};
function WICMapSchemaToName; external WincodecLib name 'WICMapSchemaToName' {$ifdef bDelayed}delayed{$endif};


end.

{$I Defines.inc}

unit ReviewGDI;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2014, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    GDIPAPI,
    GDIPOBJ,
    GDIImageUtil,
    PVApi,

    ReviewConst,
    ReviewDecoders;


  const
    cWMFFormats = 'EMF,WMF';


  type
    TReviewWMFDecoder = class(TReviewDecoder)
    public
      constructor Create; override;
      destructor Destroy; override;

      function NeedPrecache :boolean; override;
      procedure ResetSettings; override;
      function GetState :TDecoderState; override;
      function CanWork(aLoad :Boolean) :boolean; override;

      function pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; override;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; override;
      function pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
        const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; override;
      procedure pvdPageFree(AImage :TReviewImageRec); override;
      procedure pvdFileClose(AImage :TReviewImageRec); override;

      function pvdDisplayPaint(AWnd :THandle; ADC :HDC; AImage :TReviewImageRec; const AImageRect, ADisplayRect, AFullDisplayRect :TRect; AColor :DWORD) :Boolean; override;
      function pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  { Aldus Placeable Metafiles header }

  const
    cAPMSignature = $9AC6CDD7;

  type
    PAPMHeader = ^TAPMHeader;
    TAPMHeader = packed record
      dwKey      :DWORD;       { Magic number (always 9AC6CDD7h) }
      hmf        :WORD;        { Metafile HANDLE number (always 0) }
      bbox       :TSmallRect;  { Coordinate in metafile units }
      wInch      :Word;        { Number of metafile units per inch }
      dwReserved :DWORD;       { Reserved (always 0) }
      wCheckSum  :Word;        { Checksum value for previous 10 WORDs }
    end;


  function LoadOldMetafile(ABufSize :Integer; ABuffer :Pointer) :THandle;
  var
    vDC :HDC;
    vHead :PAPMHeader;
    vInfo :TMETAFILEPICT;
  begin
    Result := 0;
    vHead := ABuffer;
    if vHead.dwKey = cAPMSignature then begin
      FillZero(vInfo, SizeOf(vInfo));
      vInfo.mm := MM_ANISOTROPIC;
      with vHead.bbox do begin
        vInfo.xExt := MulDiv(Right - Left, 2540, vHead.wInch);
        vInfo.yExt := MulDiv(Bottom - Top, 2540, vHead.wInch);
      end;

      Dec( ABufSize, SizeOf(TAPMHeader) );
      Inc( Pointer1(ABuffer), SizeOf(TAPMHeader) );

      vDC := GetDC(0);
      Result := SetWinMetaFileBits(ABufSize, ABuffer, vDC, vInfo);
      ReleaseDC(0, vDC);
    end;
  end;



  function GetDescriptionStr(AHandle :HENHMETAFILE) :TString;
  var
    vLen :Integer;
    vStr :TString;
  begin
    Result := '';
    vLen := GetEnhMetaFileDescription(AHandle, 0, nil);
    if vLen > 0 then begin
      SetLength(vStr, vLen);
      GetEnhMetaFileDescription(AHandle, vLen, PTChar(vStr));
      Result := Trim(PTChar(vStr));
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TView                                                                       }
 {-----------------------------------------------------------------------------}

  type
    TEMFView = class(TComBasis)
    public
      destructor Destroy; override;
      class function CreateByFile(const AName :TString; ABuf :Pointer; ABufSize :Integer) :TEMFView;

      function LoadFile :Boolean;

    private
      FFileName    :TString;
      FBuffer      :Pointer;
      FBufSize     :Integer;
      FEnhanced    :Boolean;
      FHandle      :HENHMETAFILE;
      FDescription :TString;
      FSize        :TSize;
      FRecords     :Integer;
    end;


  class function TEMFView.CreateByFile(const AName :TString; ABuf :Pointer; ABufSize :Integer) :TEMFView;
  begin
    Result := TEMFView.Create;
    Result.FFileName := AName;
    Result.FBuffer := ABuf;
    Result.FBufSize := ABufSize;
    if Result.LoadFile then
      {}
    else
      FreeObj(Result);
  end;


  destructor TEMFView.Destroy; {override;}
  begin
    if FHandle <> 0 then
      DeleteEnhMetaFile(FHandle);
    inherited Destroy;
  end;


  function TEMFView.LoadFile :Boolean;
  var
    vSize :Cardinal;
    vHeader :PEnhMetaHeader;
    vDC :HDC;
    vPPIX, vPPIY :Integer;
  begin
    Result := False;

   {$ifdef bTrace}
    TraceF('WMI Load: "%s"...', [FFileName]);
   {$endif bTrace}
    if FBuffer = nil then
      Exit;

//  FHandle := GetEnhMetaFile(PTChar(FFileName));
    FHandle := SetEnhMetaFileBits(FBufSize, FBuffer);
    FEnhanced := FHandle <> 0;

    if FHandle = 0 then
      FHandle := LoadOldMetafile(FBufSize, FBuffer);

    if FHandle = 0 then begin
     {$ifdef bTrace}
      TraceF('  Error, Code=%x', [GetLastError]);
     {$endif bTrace}
      Exit;
    end;

   {$ifdef bTrace}
    Trace('  OK');
   {$endif bTrace}

    vSize := GetEnhMetaFileHeader(FHandle, 0, nil);
    if vSize = 0 then
      Exit;

    vHeader := MemAllocZero(vSize);
    try
      if GetEnhMetaFileHeader(FHandle, vSize, vHeader) = 0 then
        Exit;

//    Trace('Version=%x, Records=%d, PalEntries=%d', [vHeader.nVersion, vHeader.nRecords, vHeader.nPalEntries]);

      FDescription := GetDescriptionStr(FHandle);

      vDC := GetDC(0);
      vPPIX := GetDeviceCaps(vDC, LOGPIXELSX);
      vPPIY := GetDeviceCaps(vDC, LOGPIXELSY);
      ReleaseDC(0, vDC);

      with vHeader.rclFrame do begin
        FSize.CX := MulDiv( Right - Left, vPPIX, 2540);
        FSize.CY := MulDiv( Bottom - Top, vPPIY, 2540);
      end;

      FRecords := vHeader.nRecords;

      Result := True;
    finally
      MemFree(vHeader);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewWMFDecoder                                                           }
 {-----------------------------------------------------------------------------}

  constructor TReviewWMFDecoder.Create; {override;}
  begin
    inherited Create;
    FInitState := 1;
    FName := 'WMF';
    FTitle := FName;
    FPriority := MaxInt - 1;
    ResetSettings;
  end;


  destructor TReviewWMFDecoder.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  function TReviewWMFDecoder.NeedPrecache :boolean; {override;}
  begin
//  Result := False;
    Result := True;
  end;


  procedure TReviewWMFDecoder.ResetSettings; {override;}
  begin
    SetExtensions(cWMFFormats, '');
  end;


  function TReviewWMFDecoder.GetState :TDecoderState; {override;}
  begin
    Result := rdsInternal;
  end;


  function TReviewWMFDecoder.CanWork(aLoad :Boolean) :Boolean; {virtual;}
  begin
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  function TReviewWMFDecoder.pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; {override;}
  var
    vView :TEMFView;
  begin
    Result := False;
    vView := TEMFView.CreateByFile(AFileName, AImage.FCacheBuf, AImage.FCacheSize);

    if vView <> nil then begin
      AImage.FFormat    := StrIf(vView.FEnhanced, 'EMF', 'WMF');
//    AImage.FDescr     := vView.FDescription;
      AImage.FWidth     := vView.FSize.cx;
      AImage.FHeight    := vView.FSize.cy;
      AImage.FBPP       := 24; {???}
      AImage.FPages     := 1; //vView.FRecords + 1;
      AImage.FTransparent := True;

      AImage.FSelfdraw  := True;
      AImage.FSelfpaint := True;

      AImage.FContext   := vView;
      vView._AddRef;

      Result := True;
    end;
  end;


  function TReviewWMFDecoder.pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; {override;}
  begin
//  with TEMFView( AImage.FContext ) do
//    SetCurRecord(AImage.FPage);
    Result := True;
  end;


  function TReviewWMFDecoder.pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
    const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TReviewWMFDecoder.pvdPageFree(AImage :TReviewImageRec); {override;}
  begin
  end;


  procedure TReviewWMFDecoder.pvdFileClose(AImage :TReviewImageRec); {override;}
  begin
    if AImage.FContext <> nil then
      TEMFView(AImage.FContext)._Release;
  end;


 {-----------------------------------------------------------------------------}

  function MyEnumProc(ADC :HDC; ATable :PHandleTable; ARec :PEnhMetaRecord; nObj :Integer; AData :Pointer) :Integer; stdcall;
  var
    vSize :PSize;
  begin
    vSize := AData;
    if vSize.CX = vSize.CY then begin
      PlayEnhMetaFileRecord(ADC, ATable, ARec, nObj);
      Result := 0;
    end else
    begin
      Inc(vSize.CX);
      Result := 1;
    end;
  end;


  procedure PlayOneRecord(aHandle :HENHMETAFILE; aIndex :Integer; ADC :HDC; const ARect :TRect);
  var
    vSize :TSize;
  begin
    vSize.CX := 0;
    vSize.CY := aIndex;
    EnumEnhMetaFile(ADC, aHandle, @MyEnumProc, @vSize, @ARect);
  end;


  function TReviewWMFDecoder.pvdDisplayPaint(AWnd :THandle; ADC :HDC; AImage :TReviewImageRec; const AImageRect, ADisplayRect, AFullDisplayRect :TRect; AColor :DWORD) :Boolean; {override;}
  begin
    with TEMFView( AImage.FContext ) do
//    if AImage.FPage = 0 then
        PlayEnhMetaFile(ADC, FHandle, AFullDisplayRect);
//    else
//      PlayOneRecord(FHandle, AImage.FPage - 1, ADC, AFullDisplayRect);
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  function TReviewWMFDecoder.pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; {override;}
  begin
    with TEMFView( AImage.FContext ) do begin
      Result := True;
      aType := PVD_TagType_Str;
      case aCode of
        PVD_Tag_Description  : aValue := PTChar(FDescription);
//      PVD_Tag_Software     : {};
      else
        Result := False;
      end;
    end;
  end;


end.


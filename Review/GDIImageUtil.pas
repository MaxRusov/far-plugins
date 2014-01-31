{$I Defines.inc}

{-$Define bBMPv5}

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
    PVApi,
    GDIPAPI,
    GDIPOBJ;


  var
    optSmoothMode  :Integer = InterpolationModeDefault; //InterpolationModeHighQuality;


  type
    RGBRec = packed record
      Red, Green, Blue, Dummy :Byte;
    end;


    TMemDC = class(TObject)
    public
      constructor Create(W, H :Integer);
      destructor Destroy; override;

      function ReleaseBitmap :HBitmap;

    private
      FDC :HDC;
      FBMP, FBMP0 :HBitmap;
      FWidth, FHeight :Integer;

    public
      property DC :HDC read FDC;
      property Width :Integer read FWidth;
      property Height :Integer read FHeight;
    end;


    TReviewBitmap = class(TObject)
    public
      constructor Create1(aBMP :HBitmap; AOwn :Boolean);
      constructor CreateEx(aWidth, aHeight, aBPP, aRowBytes :Integer; aData, aPalette :Pointer; aModel :byte; aTransp :DWORD);
      destructor Destroy; override;

      procedure Transform(AOrient :Integer);

    private
      FDC    :HDC;
      FBMP   :HBitmap;
      FBMP0  :HBitmap;
      FSize  :TSize;
      FOwn   :Boolean;

    public
      property DC :HDC read FDC;
      property BMP :HBitmap read FBMP;
      property Size :TSize read FSize;
    end;


  function ScreenBitPerPixel :Integer;
  function GetBitmapSize(ABmp :THandle) :TSize;

  procedure GDIAlhaBlend(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; ASrcAlpha :Boolean = True; ATransp :Integer = 255);
  procedure GDIBitBlt(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; Alpha :Boolean);
//procedure GDIStretchDraw(ADC :HDC; const ADstRect :TGPRect; ASrcDC :TMemDC; const ASrcRect :TGPRect; ASmooth :Boolean = True);
  procedure GDIStretchDraw(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; Alpha :Boolean; ASmooth :Boolean);
  procedure GpStretchDraw(ADC :HDC; const ADstRect :TRect; ASrcBmp :HBitmap; const ASrcRect :TRect; Alpha :Boolean; ASmooth :Boolean);

  procedure GdiFillRect(ADC :HDC; const ARect :TRect; AColor :COLORREF);
  procedure GdiFillRectTransp(ADC :HDC; const ARect :TRect; AColor :COLORREF; ATransp :Integer = 255);
  procedure GpFillRectTransp(ADC :HDC; const ARect :TRect; AColor :COLORREF; ATransp :Integer = 255);

  procedure GradientFillRect(AHandle :THandle; const ARect :TRect; AColor1, AColor2 :DWORD; AVert :Boolean);

  function GDIPlusErrorMessage(AStatus :TStatus) :TString;
  procedure GDICheck(ARes :TStatus);

  function GetEncoderClsid(const AFormat :WideString; out pClsid: TGUID) :Integer;

  function GetImgFmtName(AGUID :TGUID) :TString;
  function GetImagePropName(id :ULONG) :TString;

  function GetTagValueAsStr(AImage :TGPImage; AID :ULONG; var AValue :TString) :Boolean;
  function GetTagValueAsInt(AImage :TGPImage; AID :ULONG; var AValue :Integer) :Boolean;
  function GetTagValueAsInt64(AImage :TGPImage; AID :ULONG; var AValue :Int64) :Boolean;
  procedure SetTagValueInt(AImage :TGPImage; AID :ULONG; AValue :Word);

  function GetFrameCount(AImage :TGPImage; ADimID :PGUID; ADelays :PPointer {^PPropertyItem}; ADelCount :PInteger) :Integer;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function ScreenBitPerPixel :Integer;
  var
    vDC :HDC;
  begin
    vDC := GetDC(0);
    try
      Result := GetDeviceCaps(vDC, BITSPIXEL) {* GetDeviceCaps(vDC, PLANES)} {???};
    finally
      ReleaseDC(0, vDC);
    end;
  end;


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


 {-----------------------------------------------------------------------------}

  function RealignBits(aData :Pointer; aHeight, aRowBytes :Integer) :Pointer;
  var
    I, vAlignedBytes :Integer;
    vSrc, vDst :Pointer1;
  begin
    vAlignedBytes := (aRowBytes + 3) div 4 * 4;

    Result := MemAlloc( aHeight * vAlignedBytes );

    vSrc := aData;
    vDst := Result;
    for I := 0 to aHeight - 1 do begin
      Move(vSrc^, vDst^, aRowBytes);
      Inc(vSrc, aRowBytes);
      Inc(vDst, vAlignedBytes);
    end;
  end;


  procedure ScaleAlpha(aData :Pointer; aWidth, aHeight :Integer);
  var
    I, J :Integer;
    vSrc :PRGBQuad;
  begin
    vSrc := aData;
    for J := 0 to aWidth - 1 do begin
      for I := 0 to aHeight - 1 do begin
        with vSrc^ do begin
          rgbRed := rgbRed * rgbReserved div 255;
          rgbBlue := rgbBlue * rgbReserved div 255;
          rgbGreen := rgbGreen * rgbReserved div 255;
        end;
        Inc(PAnsiChar(vSrc), SizeOf(vSrc^));
      end;
    end;
  end;


  function CreateBitmapAs(aWidth, aHeight, aBPP, aRowBytes :Integer; aData, aPalette :Pointer; aModel :byte; aTransp :DWORD) :HBitmap;
  var
    vBMP :HBitmap;
    vInfo :PBitmapInfo;
    vPalSize :Integer;
    vTmpBuf :Pointer;
  begin
    Result := 0;

    if ((aModel <> PVD_CM_BGR) and (aModel <> PVD_CM_BGRA)) or ((aModel = PVD_CM_BGRA) and (aBPP <> 32)) then
      AppError('Unsupported color model');
    if (aBPP < 1) or (aBPP > 32) or ((aBPP <= 8) and (aPalette = nil)) {or (aBPP = 16) ???} then
      AppErrorFmt('Unsupported format: BPP=%d %s', [aBPP, StrIf(aPalette = nil, 'Palette=nil', '') ]);

    vInfo := nil; vTmpBuf := nil;
    if aRowBytes mod 4 <> 0 then begin
      { The scan lines must be aligned on a DWORD... }
      vTmpBuf := RealignBits(aData, aHeight, aRowBytes);
      aData := vTmpBuf;
    end;

    vBMP := 0;
    try
      if aModel = PVD_CM_BGRA then
        { Premultiplied alpha }
        ScaleAlpha(aData, aWidth, aHeight);

      vBMP := CreateScreenCompatibleBitmap(aWidth, aHeight);
      ApiCheck(vBMP <> 0);

      vPalSize := 0;
      if aBPP <= 8 then
        vPalSize := (1 shl aBPP) * SizeOf(TRGBQuad);

      vInfo := MemAllocZero( SizeOf(TBitmapInfoHeader) + vPalSize );
      with vInfo.bmiHeader do begin
        biSize := sizeof(TBitmapInfoHeader);
        biWidth := aWidth;
        biHeight := IntIf(aRowBytes > 0, -aHeight, aHeight);
        biPlanes := 1;
        biBitCount := aBPP;
        biCompression := BI_RGB;
      end;

      if aBPP <= 8 then
        Move(aPalette^, vInfo.bmiColors, vPalSize);

      if SetDIBits(0, vBMP, 0, aHeight, aData, vInfo^, DIB_RGB_COLORS) = 0 then
        ApiCheck(False);

      Result := vBMP;

    finally
      MemFree(vInfo);
      if vTmpBuf <> nil then
        MemFree(vTmpBuf);
      if (Result = 0) and (vBMP <> 0) then
        DeleteObject(vBMP);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TMemDC                                                                      }
 {-----------------------------------------------------------------------------}

  constructor TMemDC.Create(W, H :Integer);
  begin
    FBMP := CreateScreenCompatibleBitmap(W, H);
    FWidth := W;
    FHeight := H;

    FDC := CreateCompatibleDC(0);
    FBMP0 := SelectObject(FDC, FBmp);
  end;

  destructor TMemDC.Destroy; {override;}
  begin
    if FBMP0 <> 0 then
      SelectObject(FDC, FBMP0);
    if FBMP <> 0 then
      DeleteObject(FBMP);
    if FDC <> 0 then
      DeleteDC(FDC);
  end;


  function TMemDC.ReleaseBitmap :HBitmap;
  begin
    if FBMP0 <> 0 then
      SelectObject(FDC, FBMP0);
    Result := FBMP;
    FBMP0 := 0;
    FBMP := 0;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewBitmap                                                               }
 {-----------------------------------------------------------------------------}

  constructor TReviewBitmap.Create1(aBMP :THandle; AOwn :Boolean);
  begin
    FBMP := aBMP;
    FOwn := AOwn;
    FSize := GetBitmapSize(aBMP);

    FDC := CreateCompatibleDC(0);
    FBMP0 := SelectObject(FDC, FBMP);
  end;


  constructor TReviewBitmap.CreateEx(aWidth, aHeight, aBPP, aRowBytes :Integer; aData :Pointer; aPalette :Pointer; aModel :byte; aTransp :DWORD);
  begin
    FBMP := CreateBitmapAs(aWidth, aHeight, aBPP, aRowBytes, aData, aPalette, aModel, aTransp);
    FOwn := True;

    FSize.CX := aWidth;
    FSize.CY := aHeight;

    FDC := CreateCompatibleDC(0);
    FBMP0 := SelectObject(FDC, FBMP);
  end;


  destructor TReviewBitmap.Destroy; {override;}
  begin
    if FBMP0 <> 0 then
      SelectObject(FDC, FBMP0);
    if FOwn and (FBMP <> 0) then
      DeleteObject(FBMP);
    if FDC <> 0 then
      DeleteDC(FDC);
    inherited Destroy;
  end;


  procedure TReviewBitmap.Transform(AOrient :Integer);
  var
    I, J, vSize, vWidth1, vHeight1 :Integer;
    vInfo :TBitmapInfo;
    vPtr, vNew :Pointer;
    vSrc :PRGBQuad;
    vNewBmp :HBitmap;
  begin
    if AOrient <= 1 then
      Exit;

    vSize := FSize.CX * FSize.CY * 4;
    vPtr := MemAlloc(vSize);
    try
      FillChar(vInfo, SizeOf(vInfo), 0);
      with vInfo.bmiHeader do begin
        biSize := sizeof(vInfo.bmiHeader);
        biWidth := FSize.CX;
        biHeight := FSize.CY;
        biPlanes := 1;
        biBitCount := 32;
        biCompression := BI_RGB;
      end;
      if GetDIBits(FDC, FBMP, 0, FSize.CY, vPtr, vInfo, DIB_RGB_COLORS) = 0 then
        ApiCheck(False);

      vNew := MemAlloc(vSize);
      try
        vSrc := vPtr;

        for J := 0 to FSize.CY - 1 do begin
          for I := 0 to FSize.CX - 1 do begin
            case AOrient of
              2: PRGBQuad(PAnsiChar(vNew) + (J * FSize.CX * 4) + ((FSize.CX - I - 1) * 4))^ := vSrc^;                  {X}
              3: PRGBQuad(PAnsiChar(vNew) + ((FSize.CY - J - 1) * FSize.CX * 4) + ((FSize.CX - I - 1) * 4))^ := vSrc^; {LL: 180 }
              4: PRGBQuad(PAnsiChar(vNew) + ((FSize.CY - J - 1) * FSize.CX * 4) + (I * 4))^ := vSrc^;                  {Y}

              5: PRGBQuad(PAnsiChar(vNew) + ((FSize.CX - I - 1) * FSize.CY * 4) + ((FSize.CY - J - 1) * 4))^ := vSrc^;
              6: PRGBQuad(PAnsiChar(vNew) + ((FSize.CX - I - 1) * FSize.CY * 4) + (J * 4))^ := vSrc^;                  {R: 90 }
              7: PRGBQuad(PAnsiChar(vNew) + (I * FSize.CY * 4) + (J * 4))^ := vSrc^;
              8: PRGBQuad(PAnsiChar(vNew) + (I * FSize.CY * 4) + ((FSize.CY - J - 1) * 4))^ := vSrc^;                  {L: -90 }
            end;
            Inc(PAnsiChar(vSrc), SizeOf(vSrc^));
          end;
        end;

        if AOrient in [5,6,7,8] then begin
          vWidth1 := FSize.CY;
          vHeight1 := FSize.CX;
        end else
        begin
          vWidth1 := FSize.CX;
          vHeight1 := FSize.CY;
        end;

        MemFree(vPtr);

        vNewBmp := CreateScreenCompatibleBitmap(vWidth1, vHeight1);
        if SelectObject(FDC, vNewBmp) <> 0 then begin
          DeleteObject(FBMP);
          FBMP := vNewBmp;

          with vInfo.bmiHeader do begin
            biSize := sizeof(vInfo.bmiHeader);
            biWidth := vWidth1;
            biHeight := vHeight1;
            biPlanes := 1;
            biBitCount := 32;
            biCompression := BI_RGB;
          end;
          SetDIBits(FDC, FBMP, 0, vHeight1, vNew, vInfo, DIB_RGB_COLORS);

          FSize.CX := vWidth1;
          FSize.CY := vHeight1;
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

  function GetBitmapSize(ABmp :THandle) :TSize;
  var
    vBuf :TBitmap;
  begin
    if GetObject(ABmp, SizeOf(vBuf), @vBuf) = SizeOf(vBuf) then
      Result := Size(vBuf.bmWidth, vBuf.bmHeight)
    else
      Result := Size(0,0);
  end;


  procedure GDIAlhaBlend(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; ASrcAlpha :Boolean = True; ATransp :Integer = 255);
  const
    AC_SRC_ALPHA = 1;
  var
    vBlend :TBlendFunction;
  begin
    FillZero(vBlend, SizeOf(vBlend));
    vBlend.BlendOp := AC_SRC_OVER;
    vBlend.SourceConstantAlpha := ATransp;
    if ASrcAlpha then
      vBlend.AlphaFormat := AC_SRC_ALPHA;
    AlphaBlend(
      ADC,
      ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top,
      ASrcDC,
      ASrcRect.Left, ASrcRect.Top, ASrcRect.Right - ASrcRect.Left, ASrcRect.Bottom - ASrcRect.Top,
      vBlend );
  end;


  procedure GDIBitBlt(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; Alpha :Boolean);
  begin
    if Alpha then
      GDIAlhaBlend(ADC, ADstRect, ASrcDC, ASrcRect)
    else
      BitBlt(
        ADC,
        ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top,
        ASrcDC,
        ASrcRect.Left, ASrcRect.Top,
        SRCCOPY);
  end;


  procedure GDIStretchDraw(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; Alpha :Boolean; ASmooth :Boolean);
  begin
//  if ASmooth then
//    TraceBeg('GDIStretchDraw...');
//    TraceBegF('GDIStretchDraw. Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d...',
//      [ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height,
//       ADstRect.X, ADstRect.Y, ADstRect.Width, ADstRect.Height]);

    if ASmooth then
      SetStretchBltMode(ADC, HALFTONE)
    else
      SetStretchBltMode(ADC, COLORONCOLOR);

    if Alpha then
      GDIAlhaBlend(ADC, ADstRect, ASrcDC, ASrcRect)
    else
      StretchBlt(
        ADC,
        ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top,
        ASrcDC,
        ASrcRect.Left, ASrcRect.Top, ASrcRect.Right - ASrcRect.Left, ASrcRect.Bottom - ASrcRect.Top,
        SRCCOPY);

//  if ASmooth then
//    TraceEnd('  done');
  end;


  function GpCreateBitmap(ABmp :HBitmap) :TGPBitmap;
  const
    ImageLockModeWrite = 2;
  var
    vInfo :TBitmap;
    vData :TBitmapData;
    vBuf :Pointer;
    vSize :Integer;
  begin
    Result := nil;
    if GetObject(ABmp, SizeOf(TBitmap), @vInfo) = SizeOf(TBitmap) then begin
      if vInfo.bmBitsPixel <> 32 then
        Exit;
      vSize := vInfo.bmWidth * vInfo.bmHeight * 4;
      vBuf := MemAllocZero( vSize );
      try
        if GetBitmapBits(ABmp, vSize, vBuf) <> 0 then begin
          Result := TGPBitmap.Create(vInfo.bmWidth, vInfo.bmHeight, PixelFormat32bppPARGB);
          Result.LockBits(MakeRect(0, 0, vInfo.bmWidth, vInfo.bmHeight), ImageLockModeWrite, PixelFormat32bppPARGB, vData);
          try
            Move(vBuf^, vData.Scan0^, vInfo.bmWidth * 4 * vInfo.bmHeight);
          finally
            Result.UnlockBits(vData);
          end;
        end;
      finally
        MemFree(vBuf);
      end;
    end;
  end;


  procedure GpStretchDraw(ADC :HDC; const ADstRect :TRect; ASrcBmp :HBitmap; const ASrcRect :TRect; Alpha :Boolean; ASmooth :Boolean);
  var
    vBmp :TGPBitmap;
    vGraphics :TGPGraphics;
    vDstRect :TGPRect;
  begin
//  if ASmooth then
//    TraceBeg('GDI+StretchDraw...');
//    TraceBegF('GDIPlusStretchDraw. Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d...',
//      [ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height,
//       ADstRect.X, ADstRect.Y, ADstRect.Width, ADstRect.Height]);

    if Alpha then begin
      { Иначе не сохраняется Alpha-канал...}
      vBmp := GpCreateBitmap(ASrcBmp);
      if vBmp = nil then
        vBmp := TGPBitmap.Create(ASrcBMP, 0);
    end else
      vBmp := TGPBitmap.Create(ASrcBMP, 0);
    try
      if vBmp <> nil then begin
        vGraphics := TGPGraphics.Create(ADC);
        try
//        vGraphics.SetSmoothingMode(SmoothingModeHighQuality);
//        vGraphics.SetCompositingQuality(CompositingQualityHighQuality);
          if ASmooth then
            vGraphics.SetInterpolationMode(optSmoothMode)
          else
            vGraphics.SetInterpolationMode(InterpolationModeLowQuality);

          vDstRect := MakeRect(ADstRect);
//        Inc(vDstRect.X); Inc(vDstRect.Y);
          with ASrcRect do
            vGraphics.DrawImage(vBmp, vDstRect, Left, Top, Right - Left, Bottom - Top, UnitPixel);
        finally
          FreeObj(vGraphics);
        end;
      end;
    finally
      FreeObj(vBmp);
    end;

//  if ASmooth then
//    TraceEnd('  done');
  end;



(*
  procedure GDIPlusStretchDraw(ADC :HDC; const ADstRect :TRect; ASrcBmp :HBitmap; const ASrcRect :TRect; ASmooth :Boolean = True);
  var
    vBmp :TGPBitmap;
    vGraphics :TGPGraphics;
  begin
//  TraceBegF('GDIPlusStretchDraw. Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d...',
//    [ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height,
//     ADstRect.X, ADstRect.Y, ADstRect.Width, ADstRect.Height]);

    vBmp := TGPBitmap.Create(ASrcBMP, 0);
    try
      vGraphics := TGPGraphics.Create(ADC);
      try
        with ASrcRect do
          vGraphics.DrawImage(vBmp, MakeRect(ADstRect), Left, Top, Right - Left, Bottom - Top, UnitPixel);
      finally
        FreeObj(vGraphics);
      end;
    finally
      FreeObj(vBmp);
    end;

//  TraceEnd('  done');
  end;



  procedure GDIPlusStretchDrawAlpha(ADC :HDC; const ADstRect :TRect; ASrcDC :HDC; const ASrcRect :TRect; ASmooth :Boolean = True);
  var
    vBmp :TGPBitmap;
    vGraBmp, vGraDst :TGPGraphics;
    vDC :HDC;
    vSize :TSize;
    vBrush :TGPSolidBrush;
  begin
    vBmp := nil; vGraBmp := nil; vGraDst := nil;
    try
      vSize := RectSize(ASrcRect);

      vBmp := TGPBitmap.Create(vSize.CX, vSize.CY, PixelFormat32bppPARGB{PixelFormat32bppARGB});
      vGraBmp := TGPGraphics.Create(vBmp);
      vGraBmp.SetCompositingMode(CompositingModeSourceOver{CompositingModeSourceCopy});

      vBrush := TGPSolidBrush.Create(MakeColor(128, 255, 0, 0));
      vGraBmp.FillEllipse(vBrush, 0, 0, vSize.CX, vSize.CY);

      vDC := vGraBmp.GetHDC;
      try
        GDIAlhaBlend(vDC, Rect(0, 0, vSize.CX, vSize.CY), ASrcDC, ASrcRect);
      finally
        vGraBmp.ReleaseHDC(vDC);
      end;

      vGraDst := TGPGraphics.Create(ADC);
//    vGraDst.SetCompositingMode(CompositingModeSourceOver);
//    vGraDst.SetCompositingQuality(CompositingQualityAssumeLinear);

      with ASrcRect do
        vGraDst.DrawImage(vBmp, MakeRect(ADstRect), Left, Top, Right - Left, Bottom - Top, UnitPixel);

    finally
      FreeObj(vBrush);
      FreeObj(vGraDst);
      FreeObj(vGraBmp);
      FreeObj(vBmp);
    end;
  end;
*)


(*
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
{*      if not ASmooth then begin
          vGraphics.SetCompositingMode(CompositingModeSourceCopy);
          vGraphics.SetCompositingQuality(CompositingQualityHighSpeed);
          vGraphics.SetSmoothingMode(SmoothingModeHighSpeed);
          vGraphics.SetInterpolationMode(InterpolationModeLowQuality);
        end else
        begin
          vGraphics.SetSmoothingMode(SmoothingModeHighQuality);
        end; *}

        vGraphics.DrawImage(vBmp, ADstRect, ASrcRect.X, ASrcRect.Y, ASrcRect.Width, ASrcRect.Height, UnitPixel);

      finally
        FreeObj(vGraphics);
      end;
    finally
      FreeObj(vBmp);
    end;

//  TraceEnd('  done');
  end;
*)


  procedure GdiFillRect(ADC :HDC; const ARect :TRect; AColor :COLORREF);
  var
    vBrush :HBrush;
  begin
    vBrush := CreateSolidBrush(AColor);
    if vBrush = 0 then
      Exit;
    try
      FillRect(ADC, ARect, vBrush);
    finally
      DeleteObject(vBrush);
    end;
  end;


  procedure GDIFillRectTransp(ADC :HDC; const ARect :TRect; AColor :COLORREF; ATransp :Integer = 255);
  var
    vRect :TRect;
    vMemDC :TMemDC;
  begin
    vRect := ARect;
    RectMove(vRect, -vRect.Left, -vRect.Top);
    vMemDC := TMemDC.Create(vRect.Right, vRect.Bottom);
    try
      GDIFillRect(vMemDC.DC, vRect, AColor);
//    GDIBitBlt(ADC, ARect, vMemDC.DC, vRect, False);
      GDIAlhaBlend(ADC, ARect, vMemDC.DC, vRect, False, ATransp);
    finally
      FreeObj(vMemDC);
    end;
  end;


  function MakeGpColor(AColor :COLORREF; ATransp :Integer = 255) :TGpColor;
  begin
    Result := MakeColor(aTransp, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor));
  end;


  procedure GpFillRectTransp(ADC :HDC; const ARect :TRect; AColor :COLORREF; ATransp :Integer = 255);
  var
    vGraphics :TGPGraphics;
    vBrush :TGPSolidBrush;
  begin
    vGraphics := TGPGraphics.Create(ADC);
    try
      vBrush := TGPSolidBrush.Create( MakeGpColor(AColor, ATransp) );
      try
        vGraphics.FillRectangle(vBrush, MakeRect(ARect) );
      finally
        FreeObj(vBrush);
      end;
    finally
      FreeObj(vGraphics);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

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
    GradientFill(AHandle, @VA[0], 2, @GR, 1, FillFlag[AVert]);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}


  function GDIPlusErrorMessage(AStatus :TStatus) :TString;
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


  function GetImgFmtName(AGUID :TGUID) :TString;
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



  function GetImagePropName(id :ULONG) :TString;
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

  function GetTagValueAsStr(AImage :TGPImage; AID :ULONG; var AValue :TString) :Boolean;
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
          if vItem.type_ = PropertyTagTypeASCII then
            AValue := PAnsiChar(vItem.value)
          else
            Result := False;
        end;
      finally
        MemFree(vItem);
      end;
    end;
  end;


  function GetTagValueAsInt64(AImage :TGPImage; AID :ULONG; var AValue :Int64) :Boolean;
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
          if vItem.type_ = PropertyTagTypeRational then
            AValue := Int64(vItem.value^)
          else
            Result := False;
        end;
      finally
        MemFree(vItem);
      end;
    end;
  end;


  function GetTagValueAsInt(AImage :TGPImage; AID :ULONG; var AValue :Integer) :Boolean;
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


  procedure SetTagValueInt(AImage :TGPImage; AID :ULONG; AValue :Word);
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

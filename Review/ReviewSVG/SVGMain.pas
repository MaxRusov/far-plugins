{$I Defines.inc}

unit SVGMain;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* SVG                                                                        *}
{******************************************************************************}

interface

  uses
    Windows,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWin,

    System.SysUtils,
    System.Classes,

    BVE.SVG2Intf,
    BVE.SVG2Types,
    BVE.SVG2SaxParser,
    BVE.SVG2Elements,
    BVE.SVG2ELements.VCL,
    BVE.RenderContextDirect2D.VCL,

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

  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


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


  procedure Fill(ADC :HDC; const ARect :WIndows.TRect; AColor :TColor);
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


  procedure GetBitmapData(aDC :HDC; aBMP :HBitmap; var aData :Pointer);
  var
    vSize :Integer;
    vBitmap :TBitmap;
    vInfo :TBitmapInfo;
    vCX, vCY :Integer;
  begin
    if GetObject(ABmp, SizeOf(vBitmap), @vBitmap) <> SizeOf(vBitmap) then
      ApiCheck(False);

    vCX := vBitmap.bmWidth;
    vCY := vBitmap.bmHeight;

    vSize := vCX * vCY * 4;
    aData := MemAllocZero(vSize);
    try
      FillChar(vInfo, SizeOf(vInfo), 0);
      vInfo.bmiHeader.biSize := sizeof(vInfo.bmiHeader);
      vInfo.bmiHeader.biWidth := vCX;
      vInfo.bmiHeader.biHeight := -vCY;
      vInfo.bmiHeader.biPlanes := 1;
      vInfo.bmiHeader.biBitCount := 32;

      if GetDIBits(aDC, aBMP, 0, vCY, aData, vInfo, DIB_RGB_COLORS) = 0 then
        ApiCheck(False);

    except
      MemFree(aData);
      raise;
    end;
  end;


 {-----------------------------------------------------------------------------}


  type
    TManager = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;
    end;


  constructor TManager.Create; {override;}
  begin
    inherited Create;
  end;


  destructor TManager.Destroy; {override;}
  begin
    TSVGRenderContextVclD2D.DestroySharedResources;
    inherited Destroy;
  end;


 {-----------------------------------------------------------------------------}


  type
    TView = class(TComBasis)
    public
      destructor Destroy; override;
      class function CreateByFile(AManager :TManager; const AName :TString; ABuf :Pointer; ABufSize :Integer) :TView;
      function LoadFile :Boolean;

      procedure Render(aCX, aCY :Integer);
      procedure FreePage;

    private
      FFileName   :TString;

      FSVGParser  :TSVGSaxParser;
      FSVGRoot    :ISVGRoot;

      FSize       :TSize;

      FBuffer     :Pointer;
      FBmpSize    :TSize;
      FRowSize    :Integer;      { Количество байт на строку (FSize2.CX * 3 или 4) }
    end;



  destructor TView.Destroy; {override;}
  begin
    FreePage;
    FreeObj(FSVGParser);
    FreeIntf(FSVGRoot);
    inherited Destroy;
  end;


  class function TView.CreateByFile(AManager :TManager; const AName :TString; ABuf :Pointer; ABufSize :Integer) :TView;
  begin
    Result := TView.Create;
    try
      Result.FFileName := AName;
      if Result.LoadFile then
        {}
      else
        FreeObj(Result);
    except
      FreeObj(Result);
      raise;
    end;
  end;


  function TView.LoadFile :Boolean;
  var
    vStream :System.Classes.TStream;
    vContext :ISVGRenderContext;
    vDC :HDC;
  begin
    FSVGRoot := TSVGRootVCL.Create;
    FSVGParser := TSVGSaxParser.Create(nil);

   {$ifdef bTrace}
    TraceBeg('SVG Parse...');
   {$endif bTrace}

//  FSVGParser.Parse(FFileName, FSVGRoot);

    vStream := System.Classes.TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    try
      FSVGParser.Parse(vStream, FSVGRoot, NIL);
    finally
      FreeObj(vStream);
    end;


    vDC := GetDC(0);
    try
//    vContext := TSVGRenderContextManager.CreateRenderContextDC(0, 0, 0);
      vContext := TSVGRenderContextManager.CreateRenderContextDC(vDC, 0, 0);

      with FSVGRoot.CalcIntrinsicSize(vContext, SVGRect(0,0,100,100)).Round do begin
        FSize.cx := Width;
        FSize.cy := Height;
      end;

    finally
      FreeIntf(vContext);
      ReleaseDC(0, vDC);
    end;

   {$ifdef bTrace}
    TraceEnd('  done');
   {$endif bTrace}

    Result := (FSize.cx > 0) and (FSize.cy > 0);
  end;



  procedure TView.Render(aCX, aCY :Integer);
  var
    vDC :HDC;
    vBMP, vOld :HBitmap;
    vContext :ISVGRenderContext;
  begin
    if (aCX = 0) or (aCY = 0) then begin
      aCX := FSize.cx;
      aCY := FSize.cy;
    end;

    vDC := CreateCompatibleDC(0);
    vBMP := CreateScreenCompatibleBitmap(aCX, aCY);
    if vBmp = 0 then
      ApiCheck(False);
    vOld := SelectObject(vDC, vBmp);
    try
     {$ifdef bTrace}
      TraceBegF('SVG Render  (%d x %d, %s, %d K)...', [aCX, aCY, (aCX * aCY * 4) div 1024]);
     {$endif bTrace}

      vContext := TSVGRenderContextManager.CreateRenderContextDC(vDC, aCX, aCY);
      vContext.BeginScene;
      try
        SVGRenderToRenderContext(FSVGRoot, vContext, aCX, aCY);
      finally
        vContext.EndScene;
      end;
      FreeIntf(vContext);

     {$ifdef bTrace}
      TraceEnd('  done');
     {$endif bTrace}

      GetBitmapData(vDC, vBMP, FBuffer);
      FBmpSize.CX := aCX;
      FBmpSize.CY := aCY;
      FRowSize := aCX * 4;

    finally
      SelectObject(vDC, vOld);
      DeleteDC(vDC);
      DeleteObject(vBMP)
    end;
  end;


  procedure TView.FreePage;
  begin
    MemFree(FBuffer);
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
      on E :System.SysUtils.Exception do begin
        FLastError := E.Message;
        Result := 0;
      end;
    end;
  end;

  procedure pvdExit2(pContext :Pointer); stdcall;
  begin
    if pContext <> nil then
      FreeObj(pContext);
    FLastError := '';
  end;


  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  begin
    pPluginInfo.pName := 'SVG';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2018-21, Maxim Rusov';
    pPluginInfo.Flags := PVD_IP_DECODE or PVD_IP_NEEDFILE;

    pPluginInfo.Priority := $0F02;
  end;


  procedure pvdReloadConfig2(pContext :Pointer); stdcall;
  begin
  end;


  procedure pvdGetFormats2(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  begin
    with TManager(pContext) do begin
      pFormats.pSupported := 'svg';
//    pFormats.pIgnored := '';
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

        pImageInfo.pFormatName := 'SVG';
//      pImageInfo.pComments := PTChar(vView.FDescr);
        pImageInfo.nPages := 1;  //vView.FFrames;

        pImageInfo.Flags := PVD_IIF_VECTOR;

//      if (vView.FFrames > 1) and (vView.FDelay <> 0) then
//        pImageInfo.Flags := pImageInfo.Flags or PVD_IIF_ANIMATED;

        pImageInfo.pImageContext := vView;
        vView._AddRef;

        Result := True;
      end;

    except
      on E :System.SysUtils.Exception do begin
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

      pPageInfo.lWidth := vView.FSize.cx;
      pPageInfo.lHeight := vView.FSize.cy;
      pPageInfo.nBPP := 32;  //vView.FPixBPP;
      Result := True;

    except
      on E :System.SysUtils.Exception do begin
        FLastError := E.Message;
        pPageInfo.nErrNumber := DWORD(-1);
      end;
    end;
  end;


  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  var
    vView :TView;
  begin
    Result := False; FLastError := '';
    try
      vView := pImageContext;

      vView.Render(pDecodeInfo.lWidth, pDecodeInfo.lHeight);

      pDecodeInfo.lWidth := vView.FBmpSize.cx;
      pDecodeInfo.lHeight := vView.FBmpSize.cy;
      pDecodeInfo.nBPP := 32;
      pDecodeInfo.Flags := PVD_IDF_ALPHA;
      pDecodeInfo.ColorModel := PVD_CM_BGRA;
      pDecodeInfo.lImagePitch := vView.FRowSize;
      pDecodeInfo.pImage := vView.FBuffer;
      pDecodeInfo.pPalette := nil;

      Result := True;
    except
      on E :System.SysUtils.Exception do begin
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


  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;
  begin
    StrPLCopy(pErrInfo, FLastError, nBufLen);
    Result := True;
  end;


end.


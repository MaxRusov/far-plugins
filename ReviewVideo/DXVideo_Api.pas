{$I Defines.inc}

unit DXVideo_Api;

interface

uses
  Windows,
  Messages,
  ActiveX,
  DirectShow9,

  MFIdl,
  MFObjects,
  MFTransform,
  Evr,

  MixTypes,
  MixUtils,
  MixClasses,
  MixStrings;

  const
    WM_GRAPH_EVENT = WM_APP + 1;

  type
    TRendererClass = class of TRenderer;

    TRenderer = class(TBasis)
    public
      constructor CreateEx(const aGraph :IGraphBuilder); virtual; abstract;
      procedure GetVideoSize(var aWidth, aHeight :Integer); virtual; abstract;
      procedure SetWindow(aWnd :HWND); virtual; abstract;
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect); virtual; abstract;
      procedure Repaint(aWnd :HWND; aDC :HDC); virtual; abstract;
      procedure FinalizeGraph(const aGraph :IGraphBuilder); virtual; abstract;

    private
      FInited :Boolean;
    end;


    TMedia = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function Load(const aFileName :TString; aWnd :HWND) :Boolean;

//    procedure SetWindow(aWnd :HWND);
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect);
      procedure Repaint(aWnd :HWND; aDC :HDC);

      procedure GetVideoSize(var aWidth, aHeight :Integer);
      function GetLength :Double;
      function GetPosition :Double;
      procedure SetPosition(aPos :Double);

      procedure Play;
      procedure Stop;
      procedure Pause;

      procedure SetVolume(aValue :Double);

      procedure HandleEvents(aCallback :Pointer);

    private
      { DirectShow interfaces }
      FGraph    :IGraphBuilder;
      FControl  :IMediaControl;
      FEvent    :IMediaEventEx;

      FMP       :IMediaPosition;
      FBA       :IBasicAudio;

      FRenderer :TRenderer;

      FLoaded   :Boolean;
      FIsVideo  :Boolean;
//    FState    :TPlaybackState;

      procedure RenderStream(const aSrc :IBaseFilter; aWnd :HWND);
      procedure CreateVideoRenderer;

    public
      property IsVideo :Boolean read FIsVideo;
    end;


  function OpenMediaFile(const aFileName :TString; aWindow :HWND; aFlags :DWORD = 0) :TMedia;


implementation

  uses
    MixDebug;


  const
    CLSID_EnhancedVideoRenderer :TGuid = '{FA10746C-9B63-4B6C-BC49-FC300EA5F256}';


  threadvar
    LastResult :HResult;

  function xOk(aRes :HResult) :Boolean;
  begin
    LastResult := aRes;
    Result := Succeeded(aRes);
  end;


  procedure OleError(ErrorCode: HResult);
  begin
    raise EOleSysError.Create('', ErrorCode, 0);
  end;


  procedure OleCheck(Result: HResult);
  begin
    if not Succeeded(Result) then
      OleError(Result);
  end;


  function AddFilterByCLSID(const aGraph :IGraphBuilder; const clsid :TGUID; var aFilter :IBaseFilter; const aName :PWideChar) :HResult;
  begin
    Result := CoCreateInstance(clsid, nil, CLSCTX_INPROC_SERVER, IID_IBaseFilter, aFilter);
    if not Succeeded(Result) then
      Exit;

    Result := aGraph.AddFilter(aFilter, aName);
    if not Succeeded(Result) then
      begin; aFilter := nil; Exit; end;
  end;


(*
  function IsPinConnected(const aPin :IPin; var aRes :Boolean) :HResult;
  var
    vTmp :IPin;
  begin
    Result := aPin.ConnectedTo(vTmp);
    aRes := Succeeded(Result);
    if Result = VFW_E_NOT_CONNECTED then
      Result := S_OK;
  end;


  function IsPinDirection(const aPin :IPin; aDir :PIN_DIRECTION; var aRes :Boolean) :HResult;
  var
    vDir :TPinDirection;
  begin
    Result := aPin.QueryDirection(vDir);
    if Succeeded(Result) then
      aRes := vDir = aDir;
  end;

  function FindConnectedPin(const aFilter :IBaseFilter; aDir :PIN_DIRECTION; var aPin :IPin) :HResult;
  var
    vEnum :IEnumPins;
    vPin :IPin;
  begin
    aPin := nil;

    Result := aFilter.EnumPins(vEnum);
    if not Succeeded(Result) then
      Exit;

    while vEnum.Next(1, vPin, nil) = S_OK do
      if IsPinConnected(vPin) and IsPinDirection(vPin, aDir) then begin
        aPin := vPin;
        Exit;
      end;

    Result := VFW_E_NOT_FOUND;
  end;
*)

  function IsPinConnected(const aPin :IPin) :Boolean;
  var
    vTmp :IPin;
  begin
    Result := Succeeded(aPin.ConnectedTo(vTmp));
  end;


  function IsPinDirection(const aPin :IPin; aDir :PIN_DIRECTION) :Boolean;
  var
    vDir :TPinDirection;
  begin
    Result := Succeeded(aPin.QueryDirection(vDir)) and (vDir = aDir);
  end;


  function FindConnectedPin(const aFilter :IBaseFilter; aDir :PIN_DIRECTION; var aPin :IPin) :Boolean;
  var
    vEnum :IEnumPins;
    vPin :IPin;
  begin
    aPin := nil;
    OleCheck( aFilter.EnumPins(vEnum) );
    while vEnum.Next(1, vPin, nil) = S_OK do
      if IsPinConnected(vPin) and IsPinDirection(vPin, aDir) then begin
        aPin := vPin;
        Result := True;
        Exit;
      end;
    Result := False;
  end;


  function RemoveUnconnectedRenderer(const aGraph :IGraphBuilder; const aRenderer :IBaseFilter) :Boolean;
  var
    vPin :IPin;
  begin
    Result := False;
    if not FindConnectedPin(aRenderer, PINDIR_INPUT, vPin) then begin
      OleCheck( aGraph.RemoveFilter(aRenderer) );
      Result := True;
    end;
  end;


 {-----------------------------------------------------------------------------}

  type
    TVMR7Renderer = class(TRenderer)
    public
      constructor CreateEx(const aGraph :IGraphBuilder); override;
      procedure GetVideoSize(var aWidth, aHeight :Integer); override;
      procedure SetWindow(aWnd :HWND); override;
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect); override;
      procedure Repaint(aWnd :HWND; aDC :HDC); override;
      procedure FinalizeGraph(const aGraph :IGraphBuilder); override;

    private
      FWLC :IVMRWindowlessControl;
    end;

    TVMR9Renderer = class(TRenderer)
    public
      constructor CreateEx(const aGraph :IGraphBuilder); override;
      procedure GetVideoSize(var aWidth, aHeight :Integer); override;
      procedure SetWindow(aWnd :HWND); override;
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect); override;
      procedure Repaint(aWnd :HWND; aDC :HDC); override;
      procedure FinalizeGraph(const aGraph :IGraphBuilder); override;

    private
      FWLC :IVMRWindowlessControl9;
    end;

    TEVRRenderer = class(TRenderer)
    public
      constructor CreateEx(const aGraph :IGraphBuilder); override;
      procedure GetVideoSize(var aWidth, aHeight :Integer); override;
      procedure SetWindow(aWnd :HWND); override;
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect); override;
      procedure Repaint(aWnd :HWND; aDC :HDC); override;
      procedure FinalizeGraph(const aGraph :IGraphBuilder); override;

    private
      FEVR  :IBaseFilter;
      FVDC  :IMFVideoDisplayControl;
    end;


 {-----------------------------------------------------------------------------}

  constructor TVMR7Renderer.CreateEx(const aGraph :IGraphBuilder);
  var
    vVMR :IBaseFilter;
    vConfig :IVMRFilterConfig;
  begin
    if not Succeeded(AddFilterByCLSID(aGraph, CLSID_VideoMixingRenderer, vVMR, 'VMR-7')) then
      Exit;

    OleCheck(vVMR.QueryInterface(IID_IVMRFilterConfig, vConfig));
    OleCheck(vConfig.SetRenderingMode(VMRMode_Windowless));

    OleCheck(vVMR.QueryInterface(IID_IVMRWindowlessControl, FWLC));

    FInited := True;
  end;


  procedure TVMR7Renderer.FinalizeGraph(const aGraph :IGraphBuilder); {override;}
  var
    vFilter :IBaseFilter;
  begin
    OleCheck(FWLC.QueryInterface(IID_IBaseFilter, vFilter));
    if RemoveUnconnectedRenderer(aGraph, vFilter) then begin
      FreeIntf(FWLC);
      FInited := False;
    end;
  end;


  procedure TVMR7Renderer.GetVideoSize(var aWidth, aHeight :Integer); {override;}
  var
    vARWidth, vARHeight :Integer;
  begin
    FWLC.GetNativeVideoSize(aWidth, aHeight, vARWidth, vARHeight);
  end;


  procedure TVMR7Renderer.SetWindow(aWnd :HWND); {override;}
  begin
    OleCheck(FWLC.SetVideoClippingWindow(aWnd));
    OleCheck(FWLC.SetAspectRatioMode(VMR_ARMODE_LETTER_BOX));
  end;


  procedure TVMR7Renderer.ResizeWindow(aWnd :HWND; const aRect :TRect); {override;}
  begin
    FWLC.SetVideoPosition(nil, @aRect);
  end;


  procedure TVMR7Renderer.Repaint(aWnd :HWND; aDC :HDC); {override;}
  begin
    FWLC.RepaintVideo(aWnd, aDC);
  end;

 {-----------------------------------------------------------------------------}

  constructor TVMR9Renderer.CreateEx(const aGraph :IGraphBuilder);
  var
    vVMR :IBaseFilter;
    vConfig :IVMRFilterConfig9;
  begin
    if not Succeeded(AddFilterByCLSID(aGraph, CLSID_VideoMixingRenderer9, vVMR, 'VMR-9')) then
      Exit;

    OleCheck(vVMR.QueryInterface(IID_IVMRFilterConfig9, vConfig));
    OleCheck(vConfig.SetRenderingMode(VMR9Mode_Windowless));

    OleCheck(vVMR.QueryInterface(IID_IVMRWindowlessControl9, FWLC));

    FInited := True;
  end;


  procedure TVMR9Renderer.FinalizeGraph(const aGraph :IGraphBuilder); {override;}
  var
    vFilter :IBaseFilter;
  begin
    OleCheck(FWLC.QueryInterface(IID_IBaseFilter, vFilter));
    if RemoveUnconnectedRenderer(aGraph, vFilter) then begin
      FreeIntf(FWLC);
      FInited := False;
    end;
  end;


  procedure TVMR9Renderer.GetVideoSize(var aWidth, aHeight :Integer); {override;}
  var
    vARWidth, vARHeight :Integer;
  begin
    FWLC.GetNativeVideoSize(aWidth, aHeight, vARWidth, vARHeight);
  end;


  procedure TVMR9Renderer.SetWindow(aWnd :HWND); {override;}
  begin
    OleCheck(FWLC.SetVideoClippingWindow(aWnd));
    OleCheck(FWLC.SetAspectRatioMode(VMR9ARMODE_LETTERBOX));
  end;


  procedure TVMR9Renderer.ResizeWindow(aWnd :HWND; const aRect :TRect); {override;}
  begin
    FWLC.SetVideoPosition(nil, @aRect);
  end;


  procedure TVMR9Renderer.Repaint(aWnd :HWND; aDC :HDC); {override;}
  begin
    FWLC.RepaintVideo(aWnd, aDC);
  end;


 {-----------------------------------------------------------------------------}

  constructor TEVRRenderer.CreateEx(const aGraph :IGraphBuilder);
  var
    vVMR :IBaseFilter;
    vGS :IMFGetService;
  begin
    if not Succeeded(AddFilterByCLSID(aGraph, CLSID_EnhancedVideoRenderer, vVMR, 'EVR')) then
      Exit;

    OleCheck(vVMR.QueryInterface(IID_IMFGetService, vGS));
    OleCheck(vGS.GetService(MR_VIDEO_RENDER_SERVICE, IID_IMFVideoDisplayControl, FVDC));

    // Note: Because IMFVideoDisplayControl is a service interface,
    // you cannot QI the pointer to get back the IBaseFilter pointer.
    // Therefore, we need to cache the IBaseFilter pointer.

    FEVR := vVMR;

    FInited := True;
  end;


  procedure TEVRRenderer.FinalizeGraph(const aGraph :IGraphBuilder); {override;}
  begin
    if RemoveUnconnectedRenderer(aGraph, FEVR) then begin
      FreeIntf(FEVR);
      FreeIntf(FVDC);
      FInited := False;
    end;
  end;


  procedure TEVRRenderer.GetVideoSize(var aWidth, aHeight :Integer); {override;}
  var
    vSize, vARSize :TSize;
  begin
    FVDC.GetNativeVideoSize(vSize, vARSize);
    aWidth := vSize.cx;
    aHeight := vSize.cy;
  end;


  procedure TEVRRenderer.SetWindow(aWnd :HWND); {override;}
  begin
    OleCheck(FVDC.SetVideoWindow(aWnd));
    OleCheck(FVDC.SetAspectRatioMode(MFVideoARMode_PreservePicture));
//  OleCheck(FVDC.SetAspectRatioMode(MFVideoARMode_NonLinearStretch));
  end;


  procedure TEVRRenderer.ResizeWindow(aWnd :HWND; const aRect :TRect); {override;}
  begin
    FVDC.SetVideoPosition(nil, aRect);
  end;


  procedure TEVRRenderer.Repaint(aWnd :HWND; aDC :HDC); {override;}
  begin
    FVDC.RepaintVideo;
  end;

 {-----------------------------------------------------------------------------}

  function CreateRenderer(aClass :TRendererClass; const aGraph :IGraphBuilder) :TRenderer;
  begin
    Result := nil;
    try
      Result := aClass.CreateEx(aGraph);
      if not Result.Finited then
        FreeObj(Result);
    except
      FreeObj(Result);
    end;
  end;


 {-----------------------------------------------------------------------------}

  constructor TMedia.Create; {override;}
  begin
    inherited Create;

    OleCheck(CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER, IID_IGraphBuilder, FGraph));
    OleCheck(FGraph.QueryInterface(IID_IMediaControl, FControl));
    OleCheck(FGraph.QueryInterface(IID_IMediaEventEx, FEvent));
    OleCheck(FGraph.QueryInterface(IID_IMediaPosition, FMP));
    OleCheck(FGraph.QueryInterface(IID_IBasicAudio, FBA));
  end;


  destructor TMedia.Destroy; {override;}
  begin
    if FEvent <> nil then
      FEvent.SetNotifyWindow(0, 0, 0);

    FreeObj(FRenderer);
    FreeIntf(FEvent);
    FreeIntf(FControl);
    FreeIntf(FGraph);

    inherited Destroy;
  end;


  function TMedia.Load(const aFileName :TString; aWnd :HWND) :Boolean;
  var
    vSrc :IBaseFilter;
    vRes :HResult;
  begin
   {$ifdef bTrace}
    TraceF('RenderFile %s...', [aFileName]);
   {$endif bTrace}

    vRes := FGraph.AddSourceFilter(PTChar(aFileName), nil, vSrc);

   {$ifdef bTrace}
//  TraceF('  Res=%x (%s)', [vRes, SysErrorMessage(vRes)]);
   {$endif bTrace}

    if Succeeded(vRes) then
      RenderStream(vSrc, aWnd);

    if FLoaded then
      FIsVideo := FRenderer.FInited;

    Result := FLoaded;
  end;


  procedure TMedia.RenderStream(const aSrc :IBaseFilter; aWnd :HWND);
  var
    vGraph2 :IFilterGraph2;
    vAudio :IBaseFilter;
    vEnum :IEnumPins;
    vPin :IPin;
  begin
    OleCheck(FGraph.QueryInterface(IID_IFilterGraph2, vGraph2));

    CreateVideoRenderer;
    if FRenderer = nil then
      Exit;

    if aWnd <> 0 then begin
      FEvent.SetNotifyWindow(aWnd, WM_GRAPH_EVENT, 0);
      FRenderer.SetWindow(aWnd);
    end;

    OleCheck(AddFilterByCLSID(FGraph, CLSID_DSoundRender, vAudio, 'Audio Renderer'));

    { Enumerate the pins on the source filter. }
    OleCheck(aSrc.EnumPins(vEnum));
    while vEnum.Next(1, vPin, nil) = S_OK do begin
      { Try to render this pin. It's OK if we fail some pins, if at least one pin renders. }
      if Succeeded( vGraph2.RenderEx(vPin, AM_RENDEREX_RENDERTOEXISTINGRENDERERS, nil) ) then
        FLoaded := True;
      FreeIntf(vPin);
    end;

    FRenderer.FinalizeGraph(FGraph);

    { Remove the audio renderer, if not used. }
    RemoveUnconnectedRenderer(FGraph, vAudio);
  end;


  procedure TMedia.CreateVideoRenderer;
  begin
    FRenderer := CreateRenderer(TEVRRenderer, FGraph);
    if FRenderer <> nil then
      Exit;

    FRenderer := CreateRenderer(TVMR9Renderer, FGraph);
    if FRenderer <> nil then
      Exit;  

    FRenderer := CreateRenderer(TVMR7Renderer, FGraph);
    if FRenderer <> nil then
      Exit;
  end;


  procedure TMedia.ResizeWindow(aWnd :HWND; const aRect :TRect);
  begin
    if FIsVideo then
      FRenderer.ResizeWindow(aWnd, aRect);
  end;


  procedure TMedia.Repaint(aWnd :HWND; aDC :HDC);
  begin
    if FIsVideo then
      FRenderer.Repaint(aWnd, aDC);
  end;


  procedure TMedia.GetVideoSize(var aWidth, aHeight :Integer);
  begin
    aWidth := 0; aHeight := 0;
    if FIsVideo then
      FRenderer.GetVideoSize(aWidth, aHeight);
  end;

  function TMedia.GetLength :Double;
  begin
    FMP.get_Duration(Result);
  end;


  function TMedia.GetPosition :Double;
  begin
    FMP.get_CurrentPosition(Result);
  end;


  procedure TMedia.SetPosition(aPos :Double);
  begin
    OleCheck(FMP.put_CurrentPosition(aPos));
  end;


  procedure TMedia.Play;
  begin
    OleCheck(FControl.Run);
  end;

  procedure TMedia.Stop;
  begin
    OleCheck(FControl.Stop);
  end;

  procedure TMedia.Pause;
  begin
    OleCheck(FControl.Pause);
  end;

  procedure TMedia.SetVolume(aValue :Double);
  var
    vVol :Integer;
  begin
    { Vol: -10000 - 0 }
    vVol := -Round(sqr(100 - RangeLimitF(aValue, 0, 100)));
    OleCheck(FBA.put_Volume( vVol ));
  end;


  procedure TMedia.HandleEvents(aCallback :Pointer);
  var
    vCode :Integer;
    vParam1, vParam2 :LONG_PTR;
  begin
    while Succeeded( FEvent.GetEvent(vCode, vParam1, vParam2, 0)) do begin
      if Assigned(aCallback) then
        {};
      if not Succeeded(FEvent.FreeEventParams(vCOde, vParam1, vParam2)) then
        break;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function OpenMediaFile(const aFileName :TString; aWindow :HWND; aFlags :DWORD = 0) :TMedia;
  var
    vMedia :TMedia;
  begin
    vMedia := nil;
    try
      vMedia := TMedia.Create;

      if vMedia.Load(aFileName, aWindow) then begin
//      if (aWindow <> 0) and vMedia.FIsVideo then
//        vMedia.SetWindow(aWindow);
      end else
        FreeObj(vMedia);

    except
      FreeObj(vMedia);
    end;

    Result := vMedia;
  end;


end.

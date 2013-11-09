{$I Defines.inc}

unit DXVideo_Api;

interface

uses
  Windows,
  ActiveX,
  DirectShow9,

  MixTypes,
  MixUtils,
  MixClasses,
  MixStrings;

  type
    HSTREAM = THandle;

  const
    xVideo_ATTRIB_VOL    = 1;    //used to set Audio Volume


  function  xVideo_Init(handle: HWND;flags: DWORD) :BOOL;
  function  xVideo_Free(): BOOL;

  function  xVideo_ErrorGetCode(): DWORD;

  function  xVideo_StreamCreateFile(aFileName :PTChar; aPos: DWORD; aWindow :HWND; aFlags :DWORD) :HSTREAM;
  function  xVideo_StreamFree(chan: HStream): bool;

  function  xVideo_ChannelPlay(chan: HSTREAM):BOOL;
  function  xVideo_ChannelPause(chan: HSTREAM):bool;
  function  xVideo_ChannelStop(chan: HStream): bool;

  procedure xVideo_ChannelGetInfo(chan: HSTREAM; var aWidth, aHeight :Integer);
  function  xVideo_ChannelGetLength(chan: HSTREAM;mode: DWORD): Double;
  function  xVideo_ChannelSetPosition(chan: HSTREAM;pos: Double;mode: DWORD): BOOL;
  function  xVideo_ChannelGetPosition(chan: HSTREAM;mode: DWORD): Double;

  procedure xVideo_ChannelResizeWindow(chan: HSTREAM; hVideo :DWORD; left, top, width, height :integer);
  procedure xVideo_ChannelSetAttribute(chan: HSTREAM;option: DWORD; value :TFLOAT);


implementation

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


  type
    TVideo = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function Load(aFileName :PTChar) :Boolean;

    private
      { DirectShow interfaces }
      FGB :IGraphBuilder;
      FMC :IMediaControl;
      FME :IMediaEventEx;
      FVW :IVideoWindow;
      FMS :IMediaSeeking;
      FMP :IMediaPosition;
//    FFS :IVideoFrameStep;
      FBA :IBasicAudio;
      FBV :IBasicVideo;

      FLoaded :Boolean;
      FIsVideo :Boolean;
    end;


  constructor TVideo.Create; {override;}
  begin
    inherited Create;

    { Get the interface for DirectShow's GraphBuilder }
    OleCheck(CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER, IID_IGraphBuilder, FGB));

    { QueryInterface for DirectShow interfaces }
    OleCheck(FGB.QueryInterface(IID_IMediaControl, FMC));
    OleCheck(FGB.QueryInterface(IID_IMediaEventEx, FME));
    OleCheck(FGB.QueryInterface(IID_IMediaSeeking, FMS));
    OleCheck(FGB.QueryInterface(IID_IMediaPosition, FMP));
    OleCheck(FGB.QueryInterface(IID_IVideoWindow, FVW));
    OleCheck(FGB.QueryInterface(IID_IBasicAudio, FBA));
    OleCheck(FGB.QueryInterface(IID_IBasicVideo, FBV));
  end;


  destructor TVideo.Destroy; {override;}
  begin
//  if FLoaded then
//    FVW.put_Owner(0);
    inherited Destroy;
  end;


  function TVideo.Load(aFileName :PTChar) :Boolean;
  var
    vRes :HResult;
    vVisible :Longbool;
  begin
   {$ifdef bTrace}
    TraceF('RenderFile %s...', [aFileName]);
   {$endif bTrace}

    vRes := FGB.RenderFile(aFileName, nil);

   {$ifdef bTrace}
    TraceF('  Res=%x (%s)', [vRes, SysErrorMessage(vRes)]);
   {$endif bTrace}

//  OleCheck(vRes);
    FLoaded := Succeeded(vRes);
    if FLoaded then
      FIsVideo := Succeeded(FVW.get_Visible(vVisible));
    Result := FLoaded;
  end;



  threadvar
    LastResult :HResult;

  function xOk(aRes :HResult) :Boolean;
  begin
    LastResult := aRes;
    Result := Succeeded(aRes);
  end;

 {-----------------------------------------------------------------------------}

  function xVideo_Init(handle: HWND;flags: DWORD) :BOOL;
  begin
    Result := True;
  end;

  function xVideo_Free(): BOOL;
  begin
    Result := True;
  end;

  function xVideo_ErrorGetCode(): DWORD;
  begin
    Result := LastResult;
    LastResult := 0;
  end;


  function xVideo_StreamCreateFile(aFileName :PTChar; aPos: DWORD; aWindow :HWND; aFlags :DWORD) :HSTREAM;
  var
    vVideo :TVideo;
  begin
    vVideo := nil;
    try
      vVideo := TVideo.Create;

      if vVideo.Load(aFileName) then begin
        if (aWindow <> 0) and vVideo.FIsVideo then begin
          vVideo.FVW.put_Owner(aWindow);
          vVideo.FVW.put_MessageDrain(aWindow);
          vVideo.FVW.put_WindowStyle(WS_CHILD);
        end;
      end else
        FreeObj(vVideo);

    except
      FreeObj(vVideo);
    end;

    Result := HSTream(vVideo)
  end;


  function xVideo_StreamFree(chan :HStream) :BOOL;
  begin
    TVideo(chan).Free;
    Result := True;
  end;


  function xVideo_ChannelPlay(chan: HSTREAM) :BOOL;
  begin
    Result := xOk(TVideo(chan).FMC.Run);
  end;

  function xVideo_ChannelPause(chan: HSTREAM) :BOOL;
  begin
    Result := xOk(TVideo(chan).FMC.Pause);
  end;

  function xVideo_ChannelStop(chan: HStream) :BOOL;
  begin
    Result := xOk(TVideo(chan).FMC.Stop);
  end;

  procedure xVideo_ChannelGetInfo(chan: HSTREAM; var aWidth, aHeight :Integer);
  begin
    aWidth := 0; aHeight := 0;
    TVideo(chan).FBV.GetVideoSize( aWidth, aHeight );
  end;

  function xVideo_ChannelGetLength(chan: HSTREAM;mode: DWORD): Double;
  begin
    TVideo(chan).FMP.get_Duration(Result);
  end;

  function xVideo_ChannelGetPosition(chan: HSTREAM;mode: DWORD): Double;
  begin
    TVideo(chan).FMP.get_CurrentPosition(Result);
  end;

  function xVideo_ChannelSetPosition(chan: HSTREAM;pos: Double;mode: DWORD) :BOOL;
  begin
    Result := xOk(TVideo(chan).FMP.put_CurrentPosition(pos));
  end;

  procedure xVideo_ChannelResizeWindow(chan: HSTREAM; hVideo :DWORD; left, top, width, height :integer);
  begin
    TVideo(chan).FVW.SetWindowPosition( left, top, width, height );
  end;

  procedure xVideo_ChannelSetAttribute(chan :HSTREAM; option :DWORD; value :TFLOAT);
  var
    vVol :Integer;
  begin
    { Vol: -10000 - 0 }
    vVol := -Round(sqr(100 - RangeLimitF(Value, 0, 100)));
    TVideo(chan).FBA.put_Volume( vVol );
  end;

end.

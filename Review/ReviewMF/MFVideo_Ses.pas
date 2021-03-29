{$I Defines.inc}

unit MFVideo_Ses;

interface

uses
  Windows,
  Messages,
  ActiveX,

  Win32.MFPlay,
  Win32.MFObjects,
  Win32.MFAPI,
  Win32.MFIdl,
  Win32.MFError,
  CMC.EVR,

  MixTypes,
  MixUtils,
  MixClasses,
  MixStrings;


  const
    WM_APP_PLAYER_EVENT = WM_APP + 1;

  type
     TPlayerState =
      (
          Closed,         // No session.
          Ready,          // Session was created, ready to open a file.
          OpenPending,    // Session is opening a file.
          Started,        // Session is playing a file.
          Paused,         // Session is paused.
          Stopped,        // Session is stopped (ready to play).
          Closing         // Application has closed the session, but is waiting for MESessionClosed.
      );

    TMFPlatform = class
    public
      constructor Create;
      destructor Destroy; override;

    private
      FInited :Boolean
    end;


    TPlayer = class(TInterfacedObject, IMFAsyncCallback)
    public
      constructor Create;
      destructor Destroy; override;
      procedure BeforeDestruction; override;

      procedure OpenFile(const aFileName :TString);

      function StartPlayback :HResult;

      function Play :HResult;
      function Pause :HResult;
      function Stop :HResult;

      function GetPosition(out aPos :Double) :HResult;
      function SetPosition(aPos :Double) :HResult;
      function SetVolume(aVal :Double) :HResult;

      function ResizeVideo(aWidth, aHeight :Integer) :HResult;
      function Repaint :HResult;

      function HandleEvent(aEvent :WPARAM) :HResult;

    private
      FState      :TPlayerState;
      FCloseEvent :THandle;

      FWindow     :HWND;
      FAppWnd     :HWND;

      FSession    :IMFMediaSession;
      FSource     :IMFMediaSource;
      FDisplay    :IMFVideoDisplayControl;
      FVolCtrl    :IMFSimpleAudioVolume;
      FClock      :IMFPresentationClock;

      FLength     :Double;
      FSeekTo     :Double;
      FNewSeekTo  :Double;

      FPlayRequest :Boolean;

      procedure CreateSession;
      function CloseSession :HResult;

      function GetParameters(out pdwFlags: DWORD; out pdwQueue: DWORD): HResult; stdcall;
      function Invoke(aRes :IMFAsyncResult) :HResult; stdcall;

      function OnTopologyStatus(const aEvent :IMFMediaEvent) :HResult;
      function OnPresentationEnded(const aEvent :IMFMediaEvent) :HResult;
    end;


    TMedia = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function Load(const aFileName :TString; aAppWnd, aVideoWnd :HWND) :Boolean;

//    procedure SetWindow(aWnd :HWND);
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect);
      function Repaint(aWnd :HWND; aDC :HDC) :Boolean;

      procedure GetVideoSize(var aWidth, aHeight :Integer);
      function GetLength :Double;
      function GetPosition :Double;
      procedure SetPosition(aPos :Double);

      procedure Play;
      procedure Stop;
      procedure Pause;

      procedure SetVolume(aValue :Double);

      procedure HandleEvents(aWParam :WParam);

    private
      FPlayer   :TPlayer;
      FVolume   :Double;

      function GetIsVideo :Boolean;

    public
      property IsVideo :Boolean read GetIsVideo;
      property Volume :Double read FVolume;
    end;


  function OpenMediaFile(const aFileName :TString; aAppWnd, aVideoWnd :HWND; aFlags :DWORD = 0) :TMedia;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TMFPlatform                                                                 }
 {-----------------------------------------------------------------------------}

   constructor TMFPlatform.Create;
   begin
     inherited Create;
     OleCheck(MFStartup(MF_VERSION));
     FInited := True;
   end;


   destructor TMFPlatform.Destroy;
   begin
     if FInited  then
       MFShutdown;
     inherited Destroy;
   end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetStrAttr(const aAttrs :IMFAttributes; const aKey :TGUID) :TString;
  var
    vLen :UINT32;
  begin
    Result := '';
    if Failed(aAttrs.GetStringLength(aKey, vLen)) then
      Exit;
    SetLength(Result, vLen);
    if Failed(aAttrs.GetString(aKey, PTChar(Result), vLen + 1, vLen)) then
      Result := '';
  end;


  function CreateMediaSource(const aFileName :TString; out aSource :IMFMediaSource) :HResult;
  var
    vResolver :IMFSourceResolver;
    vSource :IUnknown;
    vObjectType :TMF_OBJECT_TYPE;
  begin
    // Create the source resolver.
    Result := MFCreateSourceResolver(vResolver);
    if Failed(Result) then
      Exit;

    // Use the source resolver to create the media source.
    // ToDO: use BeginCreateObjectFromURL?...
    Result := vResolver.CreateObjectFromURL(
      PTChar(aFileName),          // URL of the source.
      MF_RESOLUTION_MEDIASOURCE,  // Create a source object.
      nil,                        // Optional property store.
      vObjectType,                // Receives the created object type.
      vSource                     // Receives a pointer to the media source.
     );
    if Failed(Result) then
      Exit;

    aSource := vSource as IMFMediaSource;
  end;



  function CreateMediaSinkActivate(const aSourceSD :IMFStreamDescriptor; aWindow :HWND; out aActivate :IMFActivate) :HResult;
  var
    vHandler :IMFMediaTypeHandler;
    vMajorType :TGUID;
    vActivate :IMFActivate;
  begin
    // Get the media type handler for the stream.
    Result := aSourceSD.GetMediaTypeHandler(vHandler);
    if Failed(Result) then
      Exit;

    // Get the major media type.
    Result := vHandler.GetMajorType(vMajorType);
    if Failed(Result) then
      Exit;

    // Create an IMFActivate object for the renderer, based on the media type.
    if vMajorType = MFMediaType_Audio then
      // Create the audio renderer.
      Result := MFCreateAudioRendererActivate(vActivate)
    else
    if vMajorType = MFMediaType_Video then
      // Create the video renderer.
      Result := MFCreateVideoRendererActivate(aWindow, vActivate)
    else
      // Unknown stream type.
      Result := E_FAIL; // Optionally, you could deselect this stream instead of failing.
    if Failed(Result) then
      Exit;
    aActivate := vActivate;
  end;


  function AddSourceNode(const aTopology :IMFTopology; const aSource :IMFMediaSource; const aPD :IMFPresentationDescriptor; const aSD :IMFStreamDescriptor; out aNode :IMFTopologyNode) :HResult;
  var
    vNode :IMFTopologyNode;
  begin
    // Create the node.
    Result := MFCreateTopologyNode(MF_TOPOLOGY_SOURCESTREAM_NODE, vNode);
    if Failed(Result) then
      Exit;

    // Set the attributes.
    Result := vNode.SetUnknown(MF_TOPONODE_SOURCE, aSource);
    if Failed(Result) then
      Exit;

    Result := vNode.SetUnknown(MF_TOPONODE_PRESENTATION_DESCRIPTOR, aPD);
    if Failed(Result) then
      Exit;

    Result := vNode.SetUnknown(MF_TOPONODE_STREAM_DESCRIPTOR, aSD);
    if Failed(Result) then
      Exit;

    // Add the node to the topology.
    Result := aTopology.AddNode(vNode);
    if Failed(Result) then
      Exit;

    aNode := vNode;
  end;


  function AddOutputNode(const aTopology :IMFTopology; const aActivate :IMFActivate; aId :DWORD; out aNode :IMFTopologyNode) :HResult;
  var
    vNode :IMFTopologyNode;
  begin
    // Create the node.
    Result := MFCreateTopologyNode(MF_TOPOLOGY_OUTPUT_NODE, vNode);
    if Failed(Result) then
      Exit;

    // Set the object pointer.
    Result := vNode.SetObject(aActivate);
    if Failed(Result) then
      Exit;

    // Set the stream sink ID attribute.
    Result := vNode.SetUINT32(MF_TOPONODE_STREAMID, aId);
    if Failed(Result) then
      Exit;

    Result := vNode.SetUINT32(MF_TOPONODE_NOSHUTDOWN_ON_REMOVE, 0{FALSE});
    if Failed(Result) then
      Exit;

    // Add the node to the topology.
    Result := aTopology.AddNode(vNode);
    if Failed(Result) then
      Exit;

    aNode := vNode;
  end;


  function AddBranchToPartialTopology(const aTopology :IMFTopology; const aSource :IMFMediaSource; const aPD :IMFPresentationDescriptor; aStreamIdx :DWORD; aWindow :HWND) :HResult;
  var
    vSelected :BOOL;
    vSD :IMFStreamDescriptor;
    vSinkActivate :IMFActivate;
    vSourceNode, vOutputNode :IMFTopologyNode;
  begin
    Result := aPD.GetStreamDescriptorByIndex(aStreamIdx, vSelected, vSD);
    if Failed(Result) then
      Exit;

   {$ifdef bTrace}
    Trace('Stream: %s, Selected: %d', [GetStrAttr(vSD, MF_SD_STREAM_NAME), Integer(vSelected)]);
   {$endif bTrace}

    if vSelected then begin
      // Create the media sink activation object.
      Result := CreateMediaSinkActivate(vSD, aWindow, vSinkActivate);
      if Failed(Result) then
        Exit;

      // Add a source node for this stream.
      Result := AddSourceNode(aTopology, aSource, aPD, vSD, vSourceNode);
      if Failed(Result) then
        Exit;

      // Create the output node for the renderer.
      Result := AddOutputNode(aTopology, vSinkActivate, 0, vOutputNode);
      if Failed(Result) then
        Exit;

      // Connect the source node to the output node.
      Result := vSourceNode.ConnectOutput(0, vOutputNode, 0);
    end;
    // else: If not selected, don't add the branch.
  end;


  function CreatePlaybackTopology(const aSource :IMFMediaSource; const aPD :IMFPresentationDescriptor; aWindow :HWND; out aTopology :IMFTopology) :HResult;
  var
    i :Integer;
    vTopology :IMFTopology;
    vStreamCount :DWORD;
  begin
    // Create a new topology.
    Result := MFCreateTopology(vTopology);
    if Failed(Result) then
      Exit;

    // Get the number of streams in the media source.
    Result := aPD.GetStreamDescriptorCount(vStreamCount);
    if Failed(Result) then
      Exit;

    // For each stream, create the topology nodes and add them to the topology.
    for i := 0 to Integer(vStreamCount) - 1 do begin
      Result := AddBranchToPartialTopology(vTopology, aSource, aPD, i, aWindow);
      if Failed(Result) then
        Exit;
    end;

    aTopology := vTopology;
  end;


 {-----------------------------------------------------------------------------}
 { TPlayer                                                                     }
 {-----------------------------------------------------------------------------}

  constructor TPlayer.Create; {override;}
  begin
    inherited Create;
    FCloseEvent := CreateEvent(nil, False, False, nil);
  end;


  destructor TPlayer.Destroy; {override;}
  begin
    if FCloseEvent <> 0 then
      CloseHandle(FCloseEvent);
    inherited Destroy;
  end;


  procedure TPlayer.BeforeDestruction; {override;}
  begin
    Inc(FRefCount);
    CloseSession;
    Dec(FRefCount);
    inherited BeforeDestruction;
  end;


  procedure TPlayer.CreateSession;
  begin
    OleCheck(CloseSession);
    OleCheck(MFCreateMediaSession(nil, FSession));
    OleCheck(FSession.BeginGetEvent(Self, nil));
    FState := Ready;
  end;


  function TPlayer.CloseSession :HResult;
  begin
    Result := S_OK;
    FreeIntf(FClock);
    FreeIntf(FDisplay);

    // First close the media session.
    if FSession <> nil then begin
      FState := Closing;
      Result := FSession.Close;
      // Wait for the close operation to complete
      if Succeeded(Result) then begin
        if WaitForSingleObject(FCloseEvent, 5000) = WAIT_TIMEOUT then
          Assert(False);{???}
        // Now there will be no more events from this session.
      end;
    end;

    // Complete shutdown operations.
    if Succeeded(Result) then begin
      // Shut down the media source. (Synchronous operation, no events.)
      if FSource <> nil then
        FSource.Shutdown;
      // Shut down the media session. (Synchronous operation, no events.)
      if FSession <> nil then
        FSession.Shutdown;
    end;

    FreeIntf(FSource);
    FreeIntf(FSession);
    FState := Closed;
  end;


  procedure TPlayer.OpenFile(const aFileName :TString);
  var
    vSourcePD :IMFPresentationDescriptor;
    vTopology :IMFTopology;
    vDuration :UINT64;
    vClock :IMFClock;
  begin
    CreateSession;
    OleCheck(CreateMediaSource(aFileName, FSource));
    OleCheck(FSource.CreatePresentationDescriptor(vSourcePD));
    OleCheck(CreatePlaybackTopology(FSource, vSourcePD, FWindow, vTopology));
    OleCheck(FSession.SetTopology(0, vTopology));

    vDuration := 0;
    OleCheck(vSourcePD.GetUINT64(MF_PD_DURATION, vDuration));
    FLength := vDuration / 10000000;

    if Succeeded( FSession.GetClock(vClock) ) then
      FClock := vClock as IMFPresentationClock;

    FState := OpenPending;
  end;


  function TPlayer.GetParameters(out pdwFlags: DWORD; out pdwQueue: DWORD): HResult;
  begin
    Result := E_NOTIMPL;
  end;


  function TPlayer.Invoke(aRes :IMFAsyncResult) :HResult;
    //  Callback for the asynchronous BeginGetEvent method.
  var
    vEvent :IMFMediaEvent;
    vType :TMediaEventType;
  begin
//  Trace('Invoke...');

    // Get the event from the event queue.
    Result := FSession.EndGetEvent(aRes, vEvent);
    if Failed(Result) then
      Exit;

    // Get the event type.
    Result := vEvent.GetType(vType);
    if Failed(Result) then
      Exit;

    if vType = MESessionClosed then begin
      // The session was closed.
      // The application is waiting on the m_hCloseEvent event handle.
      SetEvent(FCloseEvent);
    end else
    begin
      // For all other events, get the next event in the queue.
      Result := FSession.BeginGetEvent(Self, nil);
      if Failed(Result) then
        Exit;
    end;

    if FState <> Closing then begin
      vEvent._AddRef;
      PostMessage(FAppWnd, WM_APP_PLAYER_EVENT, WPARAM(vEvent), LPARAM(vType));
    end;
  end;


  function TPlayer.ResizeVideo(aWidth, aHeight :Integer) :HResult;
  var
    vRect :TRect;
  begin
    Result := S_FALSE;
    if FDisplay <> nil then begin
      vRect := Bounds(0, 0, aWidth, aHeight);
      Result := FDisplay.SetVideoPosition(nil, @vRect);
    end;
  end;


  function TPlayer.Repaint :HResult;
  begin
    Result := S_FALSE;
    if FDisplay <> nil then
      Result := FDisplay.RepaintVideo;
  end;



  function TPlayer.HandleEvent(aEvent :WPARAM) :HResult;
  var
    vEvent :IMFMediaEvent;
    vType :TMediaEventType;
    vStatus :HResult;
  begin
    vEvent := IMFMediaEvent(aEvent);
    if vEvent = nil then
      Exit(E_POINTER);

    vEvent._Release;

    // Get the event type.
    Result := vEvent.GetType(vType);
//  TraceF('HandleEvent: Res=%x (%s), Type=%d', [Result, SysErrorMessage(Result), byte(vType)]);
    if Failed(Result) then
      Exit;

    // Get the event status. If the operation that triggered the event
    // did not succeed, the status is a failure code.
    Result := vEvent.GetStatus(vStatus);
    if Succeeded(Result) and Failed(vStatus) then
      Result := vStatus;
    if Failed(Result) then
      Exit;

    Result := S_OK;
    case vType of
      MESessionTopologyStatus:
        if FState = OpenPending then
          Result := OnTopologyStatus(vEvent);
      MEEndOfPresentation:
        Result := OnPresentationEnded(vEvent);
      MENewPresentation:
        {  hr = OnNewPresentation(pEvent)}
        NOP;

      MESessionStarted:
        begin
//        Trace('SessionStarted');
          FSeekTo := 0;
          if FNewSeekTo <> 0 then begin
            SetPosition(FNewSeekTo);
            FNewSeekTo := 0;
          end;
        end;
      MESessionStopped:
        NOP;
      MESessionPaused:
        NOP;
      MESessionRateChanged:
        NOP;
    end;
  end;


  function TPlayer.OnTopologyStatus(const aEvent :IMFMediaEvent) :HResult;
  var
    vStatus :UINT32;
  begin
    Result := aEvent.GetUINT32(MF_EVENT_TOPOLOGY_STATUS, vStatus);
    if Succeeded(Result) and (TMF_TOPOSTATUS(vStatus) = MF_TOPOSTATUS_READY) then begin
      FreeIntf(FDisplay);
      FreeIntf(FVolCtrl);
      // Get the IMFVideoDisplayControl interface from EVR. This call is
      // expected to fail if the media file does not have a video stream.
      MFGetService(FSession, MR_VIDEO_RENDER_SERVICE, IMFVideoDisplayControl, Pointer(FDisplay));
      MFGetService(FSession, MR_POLICY_VOLUME_SERVICE, IMFSimpleAudioVolume, Pointer(FVolCtrl));

      FState := Stopped;
      if FPlayRequest then
        Result := StartPlayback;
    end;
  end;


  function TPlayer.OnPresentationEnded(const aEvent :IMFMediaEvent) :HResult;
  begin
    Result := Stop;
//    FState := Stopped;
//    Result := S_OK;
  end;


  function TPlayer.StartPlayback :HResult;
  var
    vStartPos :TPropVariant;
  begin
    FillZero(vStartPos, SizeOf(vStartPos));
    Result := FSession.Start(GUID_NULL, vStartPos);
    if Succeeded(Result) then
      FState := Started;
  end;


  function TPlayer.Play :HResult;
  begin
//  Trace('Play...');
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    Result := S_OK;
    if FState = OpenPending then
      FPlayRequest := True
    else
    if FState in [Paused, Stopped] then
      Result := StartPlayback;
  end;


  function TPlayer.Pause :HResult;
  begin
    if FState <> Started then
      Exit(MF_E_INVALIDREQUEST);
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    Result := FSession.Pause();
    if Succeeded(Result) then
      FState := Paused;
  end;


  function TPlayer.Stop :HResult;
  begin
    if (FState <> Started) and (FState <> Paused) then
      Exit(MF_E_INVALIDREQUEST);
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    Result := FSession.Stop();
    if Succeeded(Result) then
      FState := Stopped;
  end;



  function TPlayer.GetPosition(out aPos :Double) :HResult;
  var
    vTime :Int64;
  begin
    if (FSession = nil) or not (FState in [Started,Paused]) then
      Exit(MF_E_INVALIDREQUEST);

    if FClock <> nil then begin
      if FNewSeekTo <> 0 then
        aPos := FNewSeekTo
      else
      if FSeekTo <> 0 then
        aPos := FSeekTo
      else begin
        Result := FClock.GetTime(vTime);
        if Failed(Result) then begin
//        TraceF('GetPosition: Res=%x (%s)', [Result, SysErrorMessage(Result)]);
          Exit;
        end;
        aPos := vTime / 10000000;
      end;
    end;
    Result := S_OK;
  end;



  function TPlayer.SetPosition(aPos :Double) :HResult;
  var
    vStartPos :TPropVariant;
  begin
    if (FSession = nil) or not (FState in [Started,Paused]) then
      Exit(MF_E_INVALIDREQUEST);

    if FSeekTo <> 0 then
      FNewSeekTo := aPos
    else begin
      vStartPos.vt := VT_I8;
      vStartPos.hVal.QuadPart := Round(aPos * 10000000);

      Result := FSession.Start(GUID_NULL, vStartPos);
      if Failed(Result) then
        Exit;

      FSeekTo := aPos;
      FState := Started;
    end;
    Result := S_OK;
  end;


  function TPlayer.SetVolume(aVal :Double) :HResult;
  begin
    if FVolCtrl = nil then
      Exit(MF_E_INVALIDREQUEST);
    FVolCtrl.SetMasterVolume(aVal / 100);
    Result := S_OK;
  end;



 {-----------------------------------------------------------------------------}
 { TMedia                                                                      }
 {-----------------------------------------------------------------------------}

  constructor TMedia.Create; {override;}
  begin
    inherited Create;
    FPlayer := TPlayer.Create;
    FVolume := 100;
  end;


  destructor TMedia.Destroy; {override;}
  begin
    FreeObj(FPlayer);
    inherited Destroy;
  end;


  function TMedia.Load(const aFileName :TString; aAppWnd, aVideoWnd :HWND) :Boolean;
  begin
    FPlayer.FAppWnd := aAppWnd;
    FPlayer.FWindow := aVideoWnd;

   {$ifdef bTrace}
    TraceBeg('OpenFile %s...', [aFileName]);
   {$endif bTrace}
    FPlayer.OpenFile(aFileName);
   {$ifdef bTrace}
    TraceEnd('  done');
   {$endif bTrace}

    Result := True;
  end;


  procedure TMedia.ResizeWindow(aWnd :HWND; const aRect :TRect);
  begin
    FPlayer.ResizeVideo(aRect.Right, aRect.Bottom);
  end;


  function TMedia.Repaint(aWnd :HWND; aDC :HDC) :Boolean;
  begin
    Result := FPlayer.Repaint = S_OK;
  end;


  procedure TMedia.GetVideoSize(var aWidth, aHeight :Integer);
  begin
  end;


  function TMedia.GetLength :Double;
  begin
    Result := FPlayer.FLength;
  end;


  function TMedia.GetPosition :Double;
  begin
    Result := 0;
    FPlayer.GetPosition(Result);
  end;


  procedure TMedia.SetPosition(aPos :Double);
  begin
    FPlayer.SetPosition(aPos);
  end;


  procedure TMedia.Play;
  begin
    FPlayer.Play;
  end;


  procedure TMedia.Stop;
  begin
    FPlayer.Stop;
  end;


  procedure TMedia.Pause;
  begin
    FPlayer.Pause;
  end;


  procedure TMedia.SetVolume(aValue :Double);
  begin
    FPlayer.SetVolume(aValue);
    FVolume := aValue;
  end;


  procedure TMedia.HandleEvents(aWParam :WPARAM);
  begin
    FPlayer.HandleEvent(aWParam);
  end;


  function TMedia.GetIsVideo :Boolean;
  begin
    Result := FPlayer.FDisplay <> nil;
  end;


 {-----------------------------------------------------------------------------}

  function OpenMediaFile(const aFileName :TString; aAppWnd, aVideoWnd :HWND; aFlags :DWORD = 0) :TMedia;
  var
    vMedia :TMedia;
  begin
    vMedia := nil;
    try
      vMedia := TMedia.Create;

      if vMedia.Load(aFileName, aAppWnd, aVideoWnd) then begin
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

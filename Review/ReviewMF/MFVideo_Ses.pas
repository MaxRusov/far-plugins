{$I Defines.inc}

{
  Based on MSDN Sample:
  https://docs.microsoft.com/en-us/windows/win32/medfound/media-session-playback-example
}

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
        Closed,
        Ready,
        OpenPending,
        StartPending,
        Started,
        PausePending,
        Paused,
        StopPending,
        Stopped,
        Closing
    );

    TMFPlatform = class
    public
      constructor Create;
      destructor Destroy; override;

    private
      FInited :Boolean
    end;


    TStreamType = (
      VideoStream,
      AudioStream,
      OtherStream
    );


    TStreamInfo = class(TBasis)
    private
      FIdx   :Integer;
      FID    :DWORD;
      FType  :TStreamType;
      FName  :TString;
      FLang  :TString;
    end;


    TPlayer = class(TInterfacedObject, IMFAsyncCallback)
    public
      constructor Create(aWnd :HWND);
      destructor Destroy; override;
       procedure BeforeDestruction; override;

      procedure OpenFile(const aFileName :TString);

      function StartPlayback :HResult;

      function Play :HResult;
      function Pause :HResult;
      function Stop :HResult;

      function GetPosition(out aPos :Double) :HResult;
      function SetPosition(aPos :Double) :HResult;
      function SetVolume(aVal :Integer) :HResult;

      function ResizeVideo(aWidth, aHeight :Integer) :HResult;
      function Repaint :HResult;

      function SelectAudioStream(aIdx :Integer) :HResult;

      function HandleEvent(aEvent :WPARAM) :HResult;

    private
      FState      :TPlayerState;
      FCloseEvent :THandle;

      FWindow     :HWND;
      FAppWnd     :HWND;

      FSession    :IMFMediaSession;
      FSource     :IMFMediaSource;
      FPresent    :IMFPresentationDescriptor;
      FDisplay    :IMFVideoDisplayControl;
      FVolCtrl    :IMFSimpleAudioVolume;
      FClock      :IMFPresentationClock;

      FLength     :Double;
      FSeekTo     :Double;
      FNewSeekTo  :Double;

      FIsVideo    :Boolean;
      FVideoSize  :TSize;

      FPlayRequest :Boolean;
      FVolumeRequest :Integer;

      FTopologyReady :Boolean;

      FVideoStreams :TObjList;
      FAudioStreams :TObjList;

      FAudioStreamIdx :Integer;

      procedure CreateSession;
      function CloseSession :HResult;
      procedure FillStreamsInfo;

      function GetParameters(out pdwFlags: DWORD; out pdwQueue: DWORD): HResult; stdcall;
      function Invoke(aRes :IMFAsyncResult) :HResult; stdcall;

      function OnTopologyStatus(const aEvent :IMFMediaEvent) :HResult;

      procedure DispatchEvents;


    public
      property State :TPlayerState read FState;
      property IsVideo :Boolean read FIsVideo;
      property VideoSize :TSize read FVideoSize;
      property Length :Double read FLength;

      property VideoStreams :TObjList read FVideoStreams;
      property AudioStreams :TObjList read FAudioStreams;
      property AudioStreamIdx :Integer read FAudioStreamIdx;
    end;



{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;



  function NameOfMFEvent(aEvent :TMediaEventType) :TString;
  begin
    Result := '';
    case aEvent of
      MEExtendedType : Result := 'MEExtendedType';
      MESessionUnknown : Result := 'MESessionUnknown';
      MESessionTopologySet : Result := 'MESessionTopologySet';
      MESessionTopologiesCleared : Result := 'MESessionTopologiesCleared';
      MESessionStarted : Result := 'MESessionStarted';
      MESessionPaused : Result := 'MESessionPaused';
      MESessionStopped : Result := 'MESessionStopped';
      MESessionClosed : Result := 'MESessionClosed';
      MESessionEnded : Result := 'MESessionEnded';
      MESessionRateChanged : Result := 'MESessionRateChanged';
      MESessionScrubSampleComplete : Result := 'MESessionScrubSampleComplete';
      MESessionCapabilitiesChanged : Result := 'MESessionCapabilitiesChanged';
      MESessionTopologyStatus : Result := 'MESessionTopologyStatus';
      MESessionNotifyPresentationTime : Result := 'MESessionNotifyPresentationTime';
      MENewPresentation : Result := 'MENewPresentation';
      MELicenseAcquisitionStart : Result := 'MELicenseAcquisitionStart';
      MELicenseAcquisitionCompleted : Result := 'MELicenseAcquisitionCompleted';
      MEIndividualizationStart : Result := 'MEIndividualizationStart';
      MEIndividualizationCompleted : Result := 'MEIndividualizationCompleted';
      MEEnablerProgress : Result := 'MEEnablerProgress';
      MEEnablerCompleted : Result := 'MEEnablerCompleted';
      MEPolicyError : Result := 'MEPolicyError';
      MEPolicyReport : Result := 'MEPolicyReport';
      MEBufferingStarted : Result := 'MEBufferingStarted';
      MEBufferingStopped : Result := 'MEBufferingStopped';
      MEConnectStart : Result := 'MEConnectStart';
      MEConnectEnd : Result := 'MEConnectEnd';
      MEReconnectStart : Result := 'MEReconnectStart';
      MEReconnectEnd : Result := 'MEReconnectEnd';
      MERendererEvent : Result := 'MERendererEvent';
      MESessionStreamSinkFormatChanged : Result := 'MESessionStreamSinkFormatChanged';
      MESourceUnknown : Result := 'MESourceUnknown';
      MESourceStarted : Result := 'MESourceStarted';
      MEStreamStarted : Result := 'MEStreamStarted';
      MESourceSeeked : Result := 'MESourceSeeked';
      MEStreamSeeked : Result := 'MEStreamSeeked';
      MENewStream : Result := 'MENewStream';
      MEUpdatedStream : Result := 'MEUpdatedStream';
      MESourceStopped : Result := 'MESourceStopped';
      MEStreamStopped : Result := 'MEStreamStopped';
      MESourcePaused : Result := 'MESourcePaused';
      MEStreamPaused : Result := 'MEStreamPaused';
      MEEndOfPresentation : Result := 'MEEndOfPresentation';
      MEEndOfStream : Result := 'MEEndOfStream';
      MEMediaSample : Result := 'MEMediaSample';
      MEStreamTick : Result := 'MEStreamTick';
      MEStreamThinMode : Result := 'MEStreamThinMode';
      MEStreamFormatChanged : Result := 'MEStreamFormatChanged';
      MESourceRateChanged : Result := 'MESourceRateChanged';
      MEEndOfPresentationSegment : Result := 'MEEndOfPresentationSegment';
      MESourceCharacteristicsChanged : Result := 'MESourceCharacteristicsChanged';
      MESourceRateChangeRequested : Result := 'MESourceRateChangeRequested';
      MESourceMetadataChanged : Result := 'MESourceMetadataChanged';
    end;
  end;


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

// {$ifdef bTrace}
//  Trace('Stream: %s, Selected: %d', [GetStrAttr(vSD, MF_SD_STREAM_NAME), Integer(vSelected)]);
// {$endif bTrace}

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

  constructor TPlayer.Create(aWnd :HWND); {override;}
  begin
    inherited Create;
    FCloseEvent := CreateEvent(nil, False, False, nil);
    FVolumeRequest := -1;
    FWindow := aWnd;
    FAppWnd := aWnd;

    FVideoStreams := TObjList.Create;
    FAudioStreams := TObjList.Create;

    FAudioStreamIdx := -1;
  end;


  destructor TPlayer.Destroy; {override;}
  begin
    FreeObj(FVideoStreams);
    FreeObj(FAudioStreams);
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
    FreeIntf(FVolCtrl);
    FreeIntf(FPresent);

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
    vTopology :IMFTopology;
    vDuration :UINT64;
  begin
    CreateSession;
    OleCheck(CreateMediaSource(aFileName, FSource));
    OleCheck(FSource.CreatePresentationDescriptor(FPresent));

    FillStreamsInfo;

    OleCheck(CreatePlaybackTopology(FSource, FPresent, FWindow, vTopology));
    OleCheck(FSession.SetTopology(0, vTopology));

    vDuration := 0;
    OleCheck(FPresent.GetUINT64(MF_PD_DURATION, vDuration));
    FLength := vDuration / 10000000;

    FState := OpenPending;
  end;


  function TPlayer.GetParameters(out pdwFlags: DWORD; out pdwQueue: DWORD): HResult;
  begin
    Result := E_NOTIMPL;
  end;


  function TPlayer.Invoke(aRes :IMFAsyncResult) :HResult;
    // Callback for the asynchronous BeginGetEvent method.
  var
    vEvent :IMFMediaEvent;
    vType :TMediaEventType;
  begin
    // Get the event from the event queue.
    Result := FSession.EndGetEvent(aRes, vEvent);
    if Failed(Result) then
      Exit;

    // Get the event type.
    Result := vEvent.GetType(vType);
    if Failed(Result) then
      Exit;

//  Trace('Invoke %d, %s', [byte(vType), NameOfMFEvent(vType)]);

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
    if Failed(Result) then
      Exit;

//  Trace('HandleEvent: %d, %s', [byte(vType), NameOfMFEvent(vType)]);

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
        OnTopologyStatus(vEvent);
//    MESessionTopologiesCleared:
//      {};
//    MENewPresentation:
//      {???};
      MESessionStarted:
        begin
//        Trace('SessionStarted');
          FState := Started;
          FSeekTo := 0;
          if FNewSeekTo <> 0 then begin
            SetPosition(FNewSeekTo);
            FNewSeekTo := 0;
          end;
        end;
      MESessionPaused:
        FState := Paused;
      MESessionStopped:
        FState := Stopped;
      MEEndOfPresentation:
        FState := Stopped;
    end;
  end;


  function TPlayer.OnTopologyStatus(const aEvent :IMFMediaEvent) :HResult;
  var
    vClock :IMFClock;
    vStatus :UINT32;
  begin
    Result := aEvent.GetUINT32(MF_EVENT_TOPOLOGY_STATUS, vStatus);
//  Trace('OnTopologyStatus: Status=%d', [vStatus]);
    if Failed(Result) then
      Exit;

    if (TMF_TOPOSTATUS(vStatus) = MF_TOPOSTATUS_READY) and not FTopologyReady then begin
      FreeIntf(FClock);
      FreeIntf(FDisplay);
      FreeIntf(FVolCtrl);

      // Get the IMFVideoDisplayControl interface from EVR. This call is
      // expected to fail if the media file does not have a video stream.
      MFGetService(FSession, MR_VIDEO_RENDER_SERVICE, IMFVideoDisplayControl, Pointer(FDisplay));
      MFGetService(FSession, MR_POLICY_VOLUME_SERVICE, IMFSimpleAudioVolume, Pointer(FVolCtrl));

      if FDisplay <> nil then begin
        FDisplay.GetNativeVideoSize(@FVideoSize, nil);
        FIsVideo := True;
      end;

      if Succeeded( FSession.GetClock(vClock) ) then
        FClock := vClock as IMFPresentationClock;

      FTopologyReady := True;

      if FState = OpenPending then begin
        FState := Stopped;
        if FPlayRequest then begin
          Result := StartPlayback;
          FPlayRequest := False;
        end;
        if FVolumeRequest > 0 then
          SetVolume(FVolumeRequest);
        FVolumeRequest := -1;
      end;
    end;
  end;


  function TPlayer.StartPlayback :HResult;
  var
    vStartPos :TPropVariant;
  begin
    FillZero(vStartPos, SizeOf(vStartPos));
    Result := FSession.Start(GUID_NULL, vStartPos);
    if Succeeded(Result) then
      FState := StartPending;
  end;


  function TPlayer.Play :HResult;
  begin
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    Result := S_OK;
    if FState = OpenPending then
      FPlayRequest := True
    else
    if FState in [Paused,Stopped] then
      Result := StartPlayback;
  end;


  function TPlayer.Pause :HResult;
  begin
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    if FState <> Started then
      Exit(MF_E_INVALIDREQUEST);
    Result := FSession.Pause();
    if Succeeded(Result) then
      FState := PausePending;
  end;


  function TPlayer.Stop :HResult;
  begin
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    if not (FState in [Started, Paused]) then
      Exit(MF_E_INVALIDREQUEST);
    Result := FSession.Stop();
    if Succeeded(Result) then
      FState := StopPending;
  end;


  function TPlayer.GetPosition(out aPos :Double) :HResult;
  var
    vTime :Int64;
  begin
    if FSession = nil then
      Exit(E_UNEXPECTED);

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
    if FSession = nil then
      Exit(E_UNEXPECTED);

    if FSeekTo <> 0 then
      FNewSeekTo := aPos
    else begin
      vStartPos.vt := VT_I8;
      vStartPos.hVal.QuadPart := Round(aPos * 10000000);

      Result := FSession.Start(GUID_NULL, vStartPos);
      if Failed(Result) then
        Exit;

      FSeekTo := aPos;
      FState := StartPending;
    end;
    Result := S_OK;
  end;


  function TPlayer.SetVolume(aVal :Integer) :HResult;
  begin
    if (FSession = nil) or (FSource = nil) then
      Exit(E_UNEXPECTED);
    Result := S_OK;
    if FState = OpenPending then
      FVolumeRequest := aVal
    else begin
      if FVolCtrl = nil then
        Exit(MF_E_INVALIDREQUEST);
      Result := FVolCtrl.SetMasterVolume(aVal / 100);
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

 {-----------------------------------------------------------------------------}

  function MajorTypeToStreamType(const aMajorType :TGUID) :TStreamType;
  begin
   if aMajorType = MFMediaType_Video then
     Result := VideoStream
   else
   if aMajorType = MFMediaType_Audio then
     Result := AudioStream
   else
     Result := OtherStream
  end;


  procedure TPlayer.FillStreamsInfo;
  var
    i :Integer;
    vStreamCount :DWORD;
    vSelected :BOOL;
    vStream :IMFStreamDescriptor;
    vHandler :IMFMediaTypeHandler;
    vMajorType :TGUID;
    vInfo :TStreamInfo;
  begin
    FAudioStreamIdx := -1;
    OleCheck(FPresent.GetStreamDescriptorCount(vStreamCount));
    for i := 0 to Integer(vStreamCount) - 1 do begin
      vInfo := TStreamInfo.Create;
      try
        vInfo.FIdx := i;
        OleCheck(FPresent.GetStreamDescriptorByIndex(i, vSelected, vStream));

        OleCheck(vStream.GetStreamIdentifier(vInfo.FID));
        vInfo.FName := GetStrAttr(vStream, MF_SD_STREAM_NAME);
        vInfo.FLang := GetStrAttr(vStream, MF_SD_LANGUAGE);

        OleCheck(vStream.GetMediaTypeHandler(vHandler));
        OleCheck(vHandler.GetMajorType(vMajorType));

        vInfo.FType := MajorTypeToStreamType(vMajorType);

        if vInfo.FType = AudioStream then begin
          FAudioStreams.Add(vInfo);
          if vSelected then
            FAudioStreamIdx := FAudioStreams.Count - 1;
        end else
        if vInfo.FType = VideoStream then begin
          FVideoStreams.Add(vInfo);
//        if vSelected then
//           FVideoStreamIdx := FVideoStreams.Count - 1;
        end else
          FreeObj(vInfo);

      except
        FreeObj(vInfo);
        raise;
      end;
    end;
  end;


  function TPlayer.SelectAudioStream(aIdx :Integer) :HResult;
  var
    vPos :Double;
    vTopology :IMFTopology;
    vInfo :TStreamInfo;
  begin
    if FAudioStreamIdx <> aIdx then begin
      Result := GetPosition(vPos);
      if Failed(Result) then
        Exit;

      if FAudioStreamIdx <> -1 then begin
        vInfo := FAudioStreams[FAudioStreamIdx];
        Result := FPresent.DeselectStream( vInfo.FIdx );
        if Failed(Result) then
          Exit;
      end;
      if aIdx <> -1 then begin
        vInfo := FAudioStreams[aIdx];
        Result := FPresent.SelectStream( vInfo.FIdx );
        if Failed(Result) then
          Exit;
//      Trace('Audio stream: %d, %s, %s', [vInfo.FIdx, vInfo.FLang, vInfo.FName]);
      end;

      Result := CreatePlaybackTopology(FSource, FPresent, FWindow, vTopology);
      if Failed(Result) then
        Exit;

      Result := Stop;
      if Failed(Result) then
        Exit;
      while FState <> Stopped do
        DispatchEvents;

      FTopologyReady := False;
      Result := FSession.SetTopology(DWORD(MFSESSION_SETTOPOLOGY_IMMEDIATE), vTopology);
      if Failed(Result) then
        Exit;

      Result := Play;
      if Failed(Result) then
        Exit;
      while not FTopologyReady do
        DispatchEvents;

      SetPosition(vPos);

      FAudioStreamIdx := aIdx;
    end else
      Result := MF_E_INVALIDREQUEST;
  end;



  procedure TPlayer.DispatchEvents;
  var
    vMsg :Windows.TMsg;
  begin
    while PeekMessage(vMsg, 0 {FWindow.Handle}, 0, 0, PM_REMOVE) do begin
      TranslateMessage(vMsg);
      DispatchMessage(vMsg);
    end;
  end;



end.

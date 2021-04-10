{$I Defines.inc}

{-$Define bTracePVD}

unit MFVideoMain;

{******************************************************************************}
{* (c) 2021 Max Rusov                                                         *}
{*                                                                            *}
{* MFVideo                                                                    *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWin,
    MFVideo_Ses,
    PVApi;


  const
    cVideoFormats = '3GP,AVI,FLV,MKV,MOV,MP4,MPG,MPEG,MTS,WEBM,WMV,HEVC';



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

  function pvdDisplayInit2(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;
  function pvdDisplayAttach2(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;
  function pvdDisplayCreate2(pContext :Pointer; pDisplayCreate :PPVDInfoDisplayCreate2) :BOOL; stdcall;
  function pvdDisplayPaint2(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;
  procedure pvdDisplayClose2(pContext :Pointer; pDisplayContext :Pointer); stdcall;
  procedure pvdDisplayExit2(pContext :Pointer); stdcall;

  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;
  function pvdPlayControl(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; pInfo :Pointer) :Integer; stdcall;

  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  var
    ReviewWindow :THandle;

  const
    CM_LoadVideo  = $B000;
    CM_GotoPos    = $B001;
    CM_SetVolume  = $B002;
    CM_Command    = $B003;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TView = class;

    TPlayerWindow = class(TMSWindow)
    public
      constructor CreateEx(AOwner :TView);
      destructor Destroy; override;

      procedure DefaultHandler(var Mess); override;

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure ErrorHandler(E :Exception); override;

      procedure WMAppPlayerEvent(var Mess :TMessage); message WM_APP_PLAYER_EVENT;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMPaint(var Mess :TWMPaint); message WM_Paint;
      procedure WMWindowPosChanged(var Mess :TWMWindowPosChanged); message WM_WindowPosChanged;
      procedure CMLoadVideo(var Mess :TMessage); message CM_LoadVideo;
      procedure CMGotoPos(var Mess :TMessage); message CM_GotoPos;
      procedure CMSetVolume(var Mess :TMessage); message CM_SetVolume;
      procedure CMCommand(var Mess :TMessage); message CM_Command;

    private
      FOwner      :TView;

      FLastState  :Integer;  { 0-Stopped 1-Play, 2-Pause, 3-Finished }
      FLastLen    :Integer;
      FLastTime   :Integer;
      FLastVolume :Integer;
      FLastSize   :TSize;

      function Idle :Boolean;
    end;


    TPlayerThread = class(TThread)
    public
      constructor Create(AOwner :TView);
      procedure Execute; override;

    private
      FOwner :TView;
      FWindow :TPlayerWindow;
      FError :Boolean
    end;


    TView = class(TComBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function LoadFile(const AName :TString) :Boolean;
      procedure FreeStream;
      procedure Play;
      procedure Stop;
      procedure Pause;
      function GetState :Integer;
      function GetLenMS :Integer;
      function GetPosMS :Integer;
      procedure GotoPosMS(aPos :Integer);
      function GetVolume :Integer;
      procedure SetVolume(aVolume :Integer);
      procedure SetAudioStream(aIndex :Integer);

      function TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

      procedure Activate;
      procedure Deactivate;

    private
      FSrcName     :TString;
      FPlayer      :TPlayer;
      FFmtName     :TString;
      FLength      :Integer;
      FVolume      :Integer;
      FColor       :DWORD;

      FFormThrd    :TPlayerThread;
      FWindow      :TPlayerWindow;

      FStrTag      :TString;
      FDblTag      :Double;

      procedure DoLoadFile;
      procedure DoResize({const} ARect :TRect);
    end;


 {-----------------------------------------------------------------------------}
 { TPlayerWindow                                                               }
 {-----------------------------------------------------------------------------}

  constructor TPlayerWindow.CreateEx(AOwner :TView);
  begin
    Create;
    FOwner := AOwner;
    FLastState := 0;
    FLastVolume := 100;
  end;


  destructor TPlayerWindow.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  procedure TPlayerWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams); {CreateWindowEx}
//  with AParams.WindowClass do
//    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
    AParams.WndParent := GetDesktopWindow;
    AParams.Style := WS_CHILD {or WS_CLIPCHILDREN};
  end;


  procedure TPlayerWindow.DefaultHandler(var Mess); {override;}
  begin
    with TMessage(Mess) do
      if (Msg >= WM_MOUSEFIRST) and (Msg <= WM_MOUSELAST) then begin
        Result := SendMessage(ReviewWindow, Msg, WParam, LParam);
        Exit;
      end;
    inherited;
  end;


  procedure TPlayerWindow.WMAppPlayerEvent(var Mess :TMessage); {message WM_APP_PLAYER_EVENT;}
  begin
    if FOwner.FPlayer <> nil then
      FOwner.FPlayer.HandleEvent(Mess.wParam);
  end;


  procedure TPlayerWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
    if (FOwner = nil) or (FOwner.FPlayer = nil) or not FOwner.FPlayer.IsVideo then
      FillRect(Mess.DC, ClientRect, COLOR_WINDOWTEXT + 1);
    Mess.Result := 1;
  end;


  procedure TPlayerWindow.WMPaint(var Mess :TWMPaint); {message WM_Paint;}
  var
    DC :HDC;
    PS :TPaintStruct;
  begin
    DC := Mess.DC;
    if DC = 0 then
      DC := BeginPaint(Handle, PS);
    try
      if (FOwner = nil) or (FOwner.FPlayer = nil) or
        (FOwner.FPlayer.Repaint <> S_OK)   // Не Failed, т.к. если не Video - возвращает S_False
      then
        FillRect(DC, ClientRect, COLOR_WINDOWTEXT + 1);
    finally
      if Mess.DC = 0 then
        EndPaint(Handle, PS);
    end;
  end;


  procedure TPlayerWindow.WMWindowPosChanged(var Mess :TWMWindowPosChanged); {message WM_WindowPosChanged;}
  var
    vRect :TRect;
  begin
    inherited;
    vRect := ClientRect;
    if FOwner <> nil then
      FOwner.DoResize(vRect);
  end;


  procedure TPlayerWindow.CMLoadVideo(var Mess :TMessage); {message CM_LoadVideo;}
  begin
    FOwner.DoLoadFile;
  end;


  procedure TPlayerWindow.CMGotoPos(var Mess :TMessage); {message CM_GotoPos;}
  begin
    FOwner.GotoPosMS(Mess.wParam);
  end;


  procedure TPlayerWindow.CMSetVolume(var Mess :TMessage); {message CM_SetVolume;}
  begin
    FOwner.SetVolume(Mess.wParam);
  end;


  procedure TPlayerWindow.CMCommand(var Mess :TMessage); {message CM_Command;}
  begin
    case Mess.wParam of
      PVD_PC_Play:
        FOwner.Play;
      PVD_PC_Pause:
        FOwner.Pause;
      PVD_PC_Stop:
        FOwner.Stop;
      PVD_PC_SetAudioStream:
        FOwner.SetAudioStream(Mess.LParam);
    end;
  end;


  procedure TPlayerWindow.ErrorHandler(E :Exception); {override;}
  begin
    Beep;
  end;


  function TPlayerWindow.Idle :Boolean;
  begin
    FLastState := FOwner.GetState;
    FLastTime := FOwner.GetPosMS;
    FLastVolume := FOwner.GetVolume;

    FLastLen := FOwner.GetLenMS;
    if FOwner.FPlayer <> nil then
      FLastSize := FOwner.FPlayer.VideoSize;

    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 { TPlayerThread                                                               }
 {-----------------------------------------------------------------------------}

  constructor TPlayerThread.Create(AOwner :TView);
  begin
    inherited Create(False);
    FOwner := AOwner;
  end;


  procedure TPlayerThread.Execute; {override;}
  var
    vMsg :Windows.TMsg;
  begin
    PeekMessage(vMsg, 0, WM_USER, WM_USER, PM_NOREMOVE); { Create message queue }

    try
      CoInitialize(nil);
      FWindow := TPlayerWindow.CreateEx(FOwner);
      try
        while not Terminated and (FWindow.Handle <> 0) do begin
          while PeekMessage(vMsg, 0 {FWindow.Handle}, 0, 0, PM_REMOVE) do begin
            TranslateMessage(vMsg);
            DispatchMessage(vMsg);
          end;
          if FWindow.Idle then
            Sleep(10);
        end;
//      FWindow.HideWindow;
      finally
        FreeObj(FWindow);
        CoUninitialize;
      end;
    except
      FError := True;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TView                                                                       }
 {-----------------------------------------------------------------------------}

  constructor TView.Create; {override;}
  begin
    inherited Create;
    FFormThrd := TPlayerThread.Create(Self);
    while (FFormThrd.FWindow = nil) and not FFormThrd.FError do
      Sleep(1);
    FWindow := FFormThrd.FWindow;
  end;


  destructor TView.Destroy; {override;}
  begin
    FreeStream;
    FreeObj(FFormThrd);
    inherited Destroy;
  end;


  procedure TView.FreeStream;
  var
    vPLayer :TPlayer;
  begin
    if FPlayer <> nil then begin
      vPLayer := FPlayer;
      FPlayer := nil;
      vPLayer.Destroy;
    end;
  end;


  procedure TView.DoLoadFile;
  begin
    FPlayer := TPlayer.Create(FWindow.Handle);
    try
     {$ifdef bTrace}
      TraceBeg('OpenFile %s...', [FSrcName]);
     {$endif bTrace}

      FPlayer.OpenFile(FSrcName);

     {$ifdef bTrace}
      TraceEnd('  done');
     {$endif bTrace}

//    FFmtName := 'Video?';

      GetLenMS;
    except
      FreeObj(FPlayer);
    end;
  end;


  function TView.LoadFile(const AName :TString) :Boolean;
  begin
    FSrcName := AName;
    SendMessage(FWindow.Handle, CM_LoadVideo, 0, 0);
    Result := FPlayer <> nil;
  end;


  procedure TView.DoResize({const} ARect :TRect);
  begin
    if FPlayer <> nil then
      FPlayer.ResizeVideo(aRect.Right - aRect.Left, aRect.Bottom - aRect.Top);
  end;


  procedure TView.Play;
  begin
    FPlayer.Play;
  end;


  procedure TView.Stop;
  begin
    FPlayer.Stop;
  end;


  procedure TView.Pause;
   begin
    if GetLenMS = GetPosMS then
      GotoPosMS(0)
    else
    if GetState = 1 then
      FPlayer.Pause
    else
      FPlayer.Play;
  end;


  function TView.GetState :Integer;
  begin
    Result := 0;
    if FPlayer <> nil then begin
      case FPlayer.State of
        StartPending, Started : Result := 1;
        PausePending, Paused  : Result := 2;
      end;
    end;
  end;


  function TView.GetLenMS :Integer;
  begin
    if (FLength = 0) and (FPlayer <> nil) then
      FLength := Round(FPlayer.Length * 1000);
    Result := FLength;
  end;


  function TView.GetPosMS :Integer;
  var
    vPos :Double;
  begin
    Result := 0;
    if FPlayer = nil then
      Exit;
    vPos := 0;
    FPlayer.GetPosition(vPos);
    Result := Round(vPos * 1000);
  end;


  procedure TView.GotoPosMS(aPos :Integer);
  begin
    aPos := RangeLimit(aPos, 0, GetLenMS);
    FPlayer.SetPosition(aPos / 1000);
  end;


  function TView.GetVolume :Integer;
  begin
    Result := FVolume;
  end;

  procedure TView.SetVolume(aVolume :Integer);
  begin
    aVolume := RangeLimit(aVolume, 0, 100);
    FPlayer.SetVolume(aVolume);
    FVolume := aVolume;
  end;


  procedure TView.SetAudioStream(aIndex :Integer);
  begin
    FPlayer.SelectAudioStream(aIndex)
  end;


  procedure TView.Activate;
  var
    vRect :TRect;
  begin
    if FPlayer = nil then
      SendMessage(FWindow.Handle, CM_LoadVideo, 0, 0);

    SetParent(FWindow.Handle, ReviewWindow);

    GetClientRect(ReviewWindow, vRect);
    FWindow.SetBounds(vRect, 0);

    FWindow.Show(SW_SHOWNA);

    try
      { В потоке Player'а?... }
      Play;
    except
    end;
  end;


  procedure TView.Deactivate;
  begin
    Stop;
    FWindow.Show(SW_HIDE);
    SetParent(FWindow.Handle, GetDesktopWindow);
    FreeStream;
  end;


 {-----------------------------------------------------------------------------}

  function TView.TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

    procedure LocIntTag(aVal :Integer);
    begin
      aValue := Pointer(TIntPtr(aVal));
      aType := PVD_TagType_Int;
      Result := True;
    end;

    procedure LocDblTag(const aVal :Double);
    begin
      FDblTag := aVal;
      aValue := Pointer(@FDblTag);
      aType := PVD_TagType_Double;
      Result := True;
    end;

    procedure LocStrTag(const aVal :TString);
    begin
      FStrTag := aVal;
      aValue := PTChar(FStrTag);
      aType := PVD_TagType_Str;
      Result := True;
    end;

  var
    vAStream :TStreamInfo;
    vVStream :TStreamInfo;
  begin
    Result := False;

    case aCode of
      PVD_Tag_Description  : LocStrTag('');

//      PVD_Tag_Time         : LocStrTag(vIFD + 'exif/{ushort=36867}');  // '{ushort=36867}'
//      PVD_Tag_EquipMake    : LocStrTag(vIFD + '{ushort=271}');
//      PVD_Tag_EquipModel   : LocStrTag(vIFD + '{ushort=272}');
//      PVD_Tag_Software     : LocStrTag(vIFD + '{ushort=305}');
//      PVD_Tag_Author       : LocStrTag(vIFD + '{ushort=315}');
//      PVD_Tag_Copyright    : LocStrTag(vIFD + '{ushort=33432}');
    end;

    vVStream := nil;
    if (FPlayer.VideoStreamIdx >= 0) and (FPlayer.VideoStreamIdx < FPlayer.VideoStreams.Count) then
      vVStream := FPlayer.VideoStreams[FPlayer.VideoStreamIdx];

    if vVStream <> nil then begin
      case aCode of
        PVD_Tag_Video_Name      : LocStrTag(vVStream.FName);
        PVD_Tag_Video_Lang      : LocStrTag(vVStream.FLang);
        PVD_Tag_Video_Format    : LocStrTag(vVStream.FFmt);
        PVD_Tag_Video_Bitrate   : LocIntTag(vVStream.FBitrate);
        PVD_Tag_Video_FrameRate : LocDblTag(vVStream.FFRamerate);
      end;
    end;

    vAStream := nil;
    if (FPlayer.AudioStreamIdx >= 0) and (FPlayer.AudioStreamIdx < FPlayer.AudioStreams.Count) then
      vAStream := FPlayer.AudioStreams[FPlayer.AudioStreamIdx];

    if vAStream <> nil then begin
      case aCode of
        PVD_Tag_Audio_Name    : LocStrTag(vAStream.FName);
        PVD_Tag_Audio_Lang    : LocStrTag(vAStream.FLang);
        PVD_Tag_Audio_Format  : LocStrTag(vAStream.FFmt);
        PVD_Tag_Audio_Bitrate : LocIntTag(vAStream.FBitrate);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function CreateView(const AName :TString) :TView;
  begin
    Result := TView.Create;
    if (Result.FWindow <> nil) and Result.LoadFile(AName) then
      {}
    else
      FreeObj(Result);
  end;


  var
    ActiveView :TView;

  procedure SetActiveView(AView :TView);
  begin
    if ActiveView <> AView then begin
      if ActiveView <> nil then
        ActiveView.Deactivate;
      ActiveView := AView;
      if AView <> nil then
        ActiveView.Activate;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TWndProc = function(HWindow :HWnd; Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT; stdcall;

  var
    FDefProc :TWndProc;


  function MyWndProc(HWindow :HWnd; Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT; stdcall;
  var
    vDefProc :TWndProc;
    vWnd :HWnd;
    vRect :TRect;
  begin
//  TraceF('MyWndProc: Msg=%d', [Msg]);
    vDefProc := FDefProc;

    case Msg of
      WM_NCDestroy:
        ReviewWindow := 0;

      WM_SIZE:
        begin
          vWnd := GetTopWindow(HWindow);
          if vWnd <> 0 then begin
            GetClientRect(HWindow, vRect);
            with vRect do
              SetWindowPos(vWnd, 0, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOZORDER);
          end;
        end;
    end;

    Result := vDefProc(HWindow, Msg, WParam, LParam);
  end;


  procedure SetWindowHook(AWnd :THandle);
  begin
    FDefProc := Pointer(GetWindowLongPtr(AWnd, GWL_WNDPROC));
    SetWindowLongPtr(AWnd, GWL_WNDPROC, TIntPtr(@MyWndProc));
    ReviewWindow := AWnd;
  end;


  procedure ReleaseWindowHook;
  begin
    if ReviewWindow <> 0 then begin
      SetWindowLongPtr(ReviewWindow, GWL_WNDPROC, TIntPtr(@FDefProc));
      ReviewWindow := 0;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые функции                                                      }
 {-----------------------------------------------------------------------------}


  threadvar
    FLastError :TString;


  function pvdInit2(pInit :PPVDInitPlugin2) :integer; stdcall;
  var
    vManager :TMFPlatform;
  begin
    FLastError := '';
    try
      vManager := TMFPlatform.Create;
      pInit.pContext := vManager;
      Result := PVD_UNICODE_INTERFACE_VERSION;
    except
      on E :Exception do begin
        FLastError := E.Message;
        Result := 0;
      end;
    end;
  end;


  procedure pvdExit2(pContext :Pointer); stdcall;
  begin
    if pContext <> nil then
      FreeObj(pContext);
  end;


  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  begin
    pPluginInfo.pName := 'MFVideo';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2021, Maxim Rusov';
    pPluginInfo.Flags := PVD_IP_DECODE or PVD_IP_DISPLAY or PVD_IP_PRIVATE or PVD_IP_NEEDFILE;
    pPluginInfo.Priority := $0F02;
  end;


  procedure pvdReloadConfig2(pContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdReloadConfig2');
   {$endif bTracePvd}
  end;


  procedure pvdGetFormats2(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdGetFormats2');
   {$endif bTracePvd}
    pFormats.pSupported := cVideoFormats;
    pFormats.pIgnored := '';
  end;


  function pvdFileOpen2(pContext :Pointer; pFileName :PWideChar; lFileSize :TInt64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage2) :BOOL; stdcall;
  var
    vView :TView;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdFileOpen2: %s', [pFileName]);
   {$endif bTracePvd}
    Result := False;

    vView := nil;
    if vView = nil then
      vView := CreateView(pFileName);

    if vView <> nil then begin
      pImageInfo.Flags := PVD_IIF_MEDIA;
      pImageInfo.nPages := vView.FLength;
      pImageInfo.nVideoCount := vView.FPlayer.VideoStreams.Count;
      pImageInfo.nAudioCount := vView.FPlayer.AudioStreams.Count;
      if vView.FFmtName <> '' then
        pImageInfo.pFormatName := PTChar(vView.FFmtName);

      pImageInfo.pImageContext := vView;
      vView._AddRef;

      Result := True;
    end;
  end;


  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  begin
    with TView(pImageContext) do begin
      { Ширина/высота видео в данный момент еще не известны. Они будут запрошены позже, через PVD_PC_GetSize  }

      pPageInfo.lWidth := 0; //FImgSize.cx;
      pPageInfo.lHeight := 0; //FImgSize.cy;

      Result := True;
    end;
  end;


  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdPageDecode2: ImageContext=%p, Frame=%d, Size=%d x %d', [pImageContext, pDecodeInfo.iPage, pDecodeInfo.lWidth, pDecodeInfo.lHeight]);
   {$endif bTracePvd}
    with TView(pImageContext) do begin
      //pDecodeInfo.iPage;
      FColor := pDecodeInfo.nBackgroundColor;

      pDecodeInfo.lWidth := 0; // FImgSize.cx;
      pDecodeInfo.lHeight := 0; // FImgSize.cy;
//    pDecodeInfo.nBPP := FPixels;
      pDecodeInfo.ColorModel := PVD_CM_PRIVATE;

      pDecodeInfo.Flags := PVD_IDF_READONLY or PVD_IDF_PRIVATE_DISPLAY;
      pDecodeInfo.pImage := pImageContext;

      Result := True;
    end;
  end;


  procedure pvdPageFree2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdPageFree2');
   {$endif bTracePvd}
  end;


  procedure pvdFileClose2(pContext :Pointer; pImageContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdFileClose2');
   {$endif bTracePvd}
    if pImageContext <> nil then
      TView(pImageContext)._Release;
  end;


 {-----------------------------------------------------------------------------}

  function pvdDisplayInit2(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdDisplayInit2: Context=%p; hWND=%d', [pContext, pDisplayInit.hWND]);
   {$endif bTracePvd}
    SetWindowHook(pDisplayInit.hWND);
    Result := True;
  end;


  function pvdDisplayAttach2(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdDisplayAttach2: Attach=%d, Wnd=%d', [Byte(pDisplayAttach.bAttach), pDisplayAttach.hWnd]);
   {$endif bTracePvd}
    Result := True;
  end;


  function pvdDisplayCreate2(pContext :Pointer; pDisplayCreate :PPVDInfoDisplayCreate2) :BOOL; stdcall;
  var
    vView :TView;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdDisplayCreate2: Context=%p', [pContext]);
   {$endif bTracePvd}

    vView := pDisplayCreate.pImage.pImage;
    pDisplayCreate.pDisplayContext := vView;
    vView._AddRef;

    SetActiveView(vView);

    Result := True;
  end;


  function pvdDisplayPaint2(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;
  begin
    Result := True;
  end;


  procedure pvdDisplayClose2(pContext :Pointer; pDisplayContext :Pointer); stdcall;
  var
    vView :TView;
  begin
   {$ifdef bTracePvd}
    TraceBeg('pvdDisplayClose2: DisplayContext=%p...', [pDisplayContext]);
   {$endif bTracePvd}
    vView := pDisplayContext;
    if vView <> nil then begin

      if vView = ActiveView then
        SetActiveView(nil);

      vView._Release;
    end;
   {$ifdef bTracePvd}
    TraceEnd('  pvdDisplayClose2 done');
   {$endif bTracePvd}
  end;


  procedure pvdDisplayExit2(pContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdDisplayExit2');
   {$endif bTracePvd}
    ReleaseWindowHook;
  end;


 {-----------------------------------------------------------------------------}

  function pvdTagInfo(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;
  begin
    Result := False;
    try
      with TView(pImageContext) do
        if aCmd = PVD_TagCmd_Get then begin
          aType := 0; aValue := nil;
          Result := TagInfo(aCode, aType, aValue);
        end;
    except
      on E :Exception do
        FLastError := E.Message;
    end;
  end;


  function pvdPlayControl(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; pInfo :Pointer) :Integer; stdcall;
  var
    vView :TView;
  begin
    Result := 0;
    if pImageContext = nil then
      Exit;
    vView := pImageContext;
    case aCmd of
      PVD_PC_Play, PVD_PC_Pause, PVD_PC_Stop:
        SendMessage(vView.FWindow.Handle, CM_Command, aCmd, 0);
      PVD_PC_GetState:
        Result := vView.FWindow.FLastState;
      PVD_PC_GetLen:
        Result := vView.FWindow.FLastLen;
      PVD_PC_GetPos:
        Result := vView.FWindow.FLastTime;
      PVD_PC_SetPos:
        SendMessage(vView.FWindow.Handle, CM_GotoPos, TIntPtr(pInfo), 0);
      PVD_PC_GetVolume:
        Result := vView.FWindow.FLastVolume;
      PVD_PC_SetVolume:
        SendMessage(vView.FWindow.Handle, CM_SetVolume, TIntPtr(pInfo), 0);
      PVD_PC_GetBounds:
        if pInfo <> nil then begin
          PSize(pInfo)^ := vView.FWindow.FLastSize;
          Result := 1;
        end;
      PVD_PC_GetAudioStream:
        Result := vView.FPlayer.AudioStreamIdx;
      PVD_PC_SetAudioStream:
        SendMessage(vView.FWindow.Handle, CM_Command, PVD_PC_SetAudioStream, TIntPtr(pInfo));
      PVD_PC_GetVideoStream:
        Result := vView.FPlayer.VideoStreamIdx;
      PVD_PC_SetVideoStream:
        {Sorry};
    end;
  end;


  function pvdTranslateError2(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;
  begin
    StrPLCopy(pErrInfo, FLastError, nBufLen);
    Result := True;
  end;


end.


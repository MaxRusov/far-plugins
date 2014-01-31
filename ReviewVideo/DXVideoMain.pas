{$I Defines.inc}

{-$Define bTracePVD}

unit DXVideoMain;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* DXVideo                                                                    *}
{******************************************************************************}

interface

  uses
    Windows,
    Commctrl,
    ActiveX,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,
    DXVideo_Api,
    PVApi;

  var
    cColor1  :Integer = $FADAC4; // $E4DAAF;
    cColor2  :Integer = $F5BE9E; // $D6C583;
    cColor3  :Integer = $FEECDD; // $F0EBD5;


  const
    cVideoFormats = '3GP,AVI,FLV,MKV,MOV,MP4,MPG,MPEG,MTS,WMV';

  var
    optVolume :Integer = 100;

    optHideOSDDelay :Integer = 3000;


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

  function pvdPlayControl(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; pInfo :Pointer) :Integer; stdcall;

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

(*
  type
    RGBRec = packed record
      Red, Green, Blue, Dummy :Byte;
    end;


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
*)

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TView = class;

    TScreen = class(TMSWindow)
    public
      constructor CreateEx(AOwner :TMSWindow);
    protected
      procedure CreateParams(var AParams :TCreateParams); override;

    private
      FOwner :TMSWindow;

      procedure WMNCHitTest(var Mess :TWMNCHitTest); message WM_NCHitTest;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMPaint(var Mess :TWMPaint); message WM_Paint;
      procedure WMGraphEvent(var Mess :TMessage); message WM_GRAPH_EVENT;
    end;


    TMyTracker = class(TTracker)
    public
      procedure SetLimit(AValue :Integer);
      procedure SetPos(AValue :Integer);

    protected
      procedure ChangePos(aValue :Integer); virtual;

    private
      FOwner   :TView;
      FLimit   :Integer;
      FDragged :Boolean;

      function XPosToPos(aXPos :Integer) :Integer;
      procedure WMLButtonDown(var Mess :TWMLButtonDown); message WM_LButtonDown;
      procedure WMMouseMove(var Mess :TWMMouseMove); message WM_MouseMove;
      procedure WMLButtonUp(var Mess :TWMLButtonUp); message WM_LButtonUp;
    end;


    TMyVolume = class(TMyTracker)
    protected
      procedure ChangePos(aValue :Integer); override;
    end;


    TPlayerWindow = class(TMSWindow)
    public
      constructor CreateEx(AOwner :TView);
      destructor Destroy; override;

    public
      procedure DefaultHandler(var Mess ); override;

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure ErrorHandler(E :Exception); override;

      procedure WMWindowPosChanged(var Mess :TWMWindowPosChanged); message WM_WindowPosChanged;
      procedure WMCtlColorStatic(var Mess :TWMCtlColorStatic); message WM_CtlColorStatic;
      procedure WMCommand(var Mess :TWMCommand); message WM_Command;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure CMLoadVideo(var Mess :TMessage); message CM_LoadVideo;
      procedure CMGotoPos(var Mess :TMessage); message CM_GotoPos;
      procedure CMSetVolume(var Mess :TMessage); message CM_SetVolume;
      procedure CMCommand(var Mess :TMessage); message CM_Command;

    private
      FOwner    :TView;
//    FColor    :DWORD;
      FBrush    :HBrush;
      FBrush1   :HBrush;
      FBrush2   :HBrush;

      FImages   :HImagelist;
      FScreen   :TScreen;
      FToolbar  :TToolbar;
      FTracker  :TMyTracker;
      FVolCtrl  :TMyVolume;

      FLastState  :Integer;  { 0-Stopped 1-Play, 2-Pause, 3-Finished }
      FLastTime   :Integer;
      FLastVolume :Integer;

      FShowOSD    :Boolean;
      FMouseTime  :DWORD;
      FHideTime   :DWORD;

      procedure SetupControls;
      procedure RealignControls(const aRect :TRect);
//    procedure SetColor(aColor :DWORD);

      function IsFullScreen :Boolean;
      procedure ShowOSD(aShow :Boolean);

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


    TView = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function _AddRef :Integer;
      function _Release :Integer;

      function LoadFile(const AName :TString) :Boolean;
      procedure FreeStream;
      procedure Play;
      procedure Stop;
      procedure Pause;
      function GetLenMS :Integer;
      function GetPosMS :Integer;
      procedure GotoPosMS(aPos :Integer);
      procedure SetVolume(aVolume :Integer);

      procedure Activate;
      procedure Deactivate;

    private
      FRefCount    :Integer;
      FSrcName     :TString;
      FMedia       :TMedia;
      FImgSize     :TSize;
      FLength      :Double;
      FState       :Integer;
      FColor       :DWORD;

      FFormThrd    :TPlayerThread;
      FWindow      :TPlayerWindow;

      procedure DoLoadFile;
      procedure DoResize({const} ARect :TRect);
    end;


 {-----------------------------------------------------------------------------}
 { TScreen                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TScreen.CreateEx(AOwner :TMSWindow);
  begin
    Create;
    FOwner := AOwner;
  end;


  procedure TScreen.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    AParams.Style := WS_CHILD or WS_VISIBLE;
    AParams.WndParent := FOwner.Handle;
  end;


  procedure TScreen.WMNCHitTest(var Mess :TWMNCHitTest); {message WM_NCHitTest;}
  begin
    Mess.Result := HTTRANSPARENT;
  end;


  procedure TScreen.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
    with (FOwner as TPlayerWindow).FOwner do
      if (FMedia <> nil) and not FMedia.IsVideo then
        FillRect(Mess.DC, ClientRect, COLOR_WINDOWTEXT + 1);
    Mess.Result := 1;
  end;


  procedure TScreen.WMPaint(var Mess :TWMPaint); {message WM_Paint;}
  var
    DC :HDC;
    PS :TPaintStruct;
  begin
    DC := Mess.DC;
    if DC = 0 then
      DC := BeginPaint(Handle, PS);
    try
      with (FOwner as TPlayerWindow).FOwner do
        if (FMedia <> nil) and FMedia.IsVideo then
          FMedia.Repaint(Handle, DC);
    finally
      if Mess.DC = 0 then
        EndPaint(Handle, PS);
    end;
  end;


  procedure TScreen.WMGraphEvent(var Mess :TMessage); {message WM_GRAPH_EVENT;}
  begin
    with (FOwner as TPlayerWindow).FOwner do
      if FMedia <> nil then
        FMedia.HandleEvents(nil);
  end;


 {-----------------------------------------------------------------------------}
 { TMyTracker                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TMyTracker.SetLimit(AValue :Integer);
  begin
    FLimit := AValue;
    if FLimit > $7F00 then
      AValue := $7F00;
    Perform(TBM_SETRANGE, 1, MakeLong(0, AValue));
  end;


  procedure TMyTracker.SetPos(AValue :Integer);
  begin
    if FLimit > $7F00 then
      AValue := MulDiv(AValue, $7F00, FLimit);
    Perform(TBM_SETPOS, 1, AValue);
  end;


  function TMyTracker.XPosToPos(aXPos :Integer) :Integer;
  const
    cDelta = 9;
  begin
    Result := RangeLimit(MulDiv(aXPos - cDelta, FLimit, ClientRect.Right - cDelta * 2), 0, FLimit);
  end;


  procedure TMyTracker.WMLButtonDown(var Mess :TWMLButtonDown); {message WM_LButtonDown;}
  begin
//  inherited;
    ChangePos(XPosToPos(Mess.XPos));
    SetCapture(Handle);
    FDragged := True;
    Mess.Result := 0;
  end;


  procedure TMyTracker.WMMouseMove(var Mess :TWMMouseMove); {message WM_MouseMove;}
  begin
    if FDragged then
      ChangePos(XPosToPos(Mess.XPos));
    Mess.Result := 0;
  end;


  procedure TMyTracker.WMLButtonUp(var Mess :TWMLButtonUp); {message WM_LButtonUp;}
  begin
    if FDragged then begin
      ReleaseCapture;
      FDragged := False;
    end;
    Mess.Result := 0;
  end;


  procedure TMyTracker.ChangePos(aValue :Integer); {virtual;}
  begin
    FOwner.GotoPosMS(aValue);
  end;


 {-----------------------------------------------------------------------------}
 { TMyVolume                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyVolume.ChangePos(aValue :Integer); {virtual;}
  begin
    FOwner.SetVolume(aValue);
  end;


 {-----------------------------------------------------------------------------}
 { TPlayerWindow                                                               }
 {-----------------------------------------------------------------------------}

  constructor TPlayerWindow.CreateEx(AOwner :TView);
  begin
    Create;
(*
    if ScreenBitPerPixel <= 8 then begin
      cColor1 := GetSysColor(COLOR_BTNFACE);
      cColor2 := cColor1;
      cColor3 := GetSysColor(COLOR_WINDOW);
    end else
    if not IsWindowsVista then begin
      cColor1 := cColor2;
    end;
*)
    FOwner := AOwner;
    CreateHandle;
    SetupControls;
    FBrush1 := CreateSolidBrush(cColor1);
    FBrush2 := CreateSolidBrush(cColor3);
    FShowOSD := True;
    FLastState := 0;
  end;


  destructor TPlayerWindow.Destroy; {override;}
  begin
    DestroyHandle;
    WidDeleteObject(FBrush);
    WidDeleteObject(FBrush1);
    WidDeleteObject(FBrush2);
    FreeObj(FScreen);
    FreeObj(FTracker);
    FreeObj(FVolCtrl);
    FreeObj(FToolbar);
    inherited Destroy;
  end;


  procedure TPlayerWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams); {CreateWindowEx}
//  with AParams.WindowClass do
//    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
    AParams.WndParent := GetDesktopWindow;
    AParams.Style := WS_CHILD or WS_CLIPCHILDREN;
//  AParams.Style := WS_OVERLAPPEDWINDOW;
  end;


  procedure TPlayerWindow.DefaultHandler(var Mess ); {override;}
  begin
    with TMessage(Mess) do begin
      if (Msg >= WM_MOUSEFIRST) and (Msg <= WM_MOUSELAST) then begin
        if (FHideTime = 0) or (TickCountDiff(GetTickCount, FHideTime) > 500) then
          FMouseTime := GetTickCount;
      end;

      if Msg = WM_LButtonDblClk then begin
        Result := SendMessage(ReviewWindow, Msg, WParam, LParam);
      end else
        inherited;
    end;
  end;


  const
    cDeltaX     =  5;
    cDeltaY     = 10;

    cPanHeight  = 24;
    cTbrHeight  = 22;
    cTbrWidth   = 24;
    cTrkHeight  = 18;
    cButSize    = 16;

    cVolWidth   = 50;

    cButPlay    = 1;

    IdTracker   = 10;
    IdVolume    = 11;


  procedure TPlayerWindow.SetupControls;
  const
    cButtonCount = 1;
    cButtons :array[0..cButtonCount - 1] of TTBButton = (
      (iBitmap:0; idCommand:cButPlay; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON)
//    (iBitmap:2; idCommand:cButStop; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
//    (fsStyle:TBSTYLE_SEP),
    );
  var
    vRect :TRect;
    Y, X, W :Integer;
  begin
    vRect := ClientRect;

    X := cDeltaX;
    Y := vRect.Bottom - ((cPanHeight + cTbrHeight) div 2);

    FScreen := TScreen.CreateEx(Self);

    FToolbar := TToolbar.CreateEx(Self, 0, X, Y, cTbrWidth, cTbrHeight,
      CCS_NORESIZE or CCS_NODIVIDER or TBSTYLE_FLAT, '');
    Inc(X, cTbrWidth);

    FImages := ImageList_LoadBitmap(HInstance, 'Buttons', cButSize, 0, RGB(255,255,255));
    SendMessage(FToolbar.Handle, TB_SETIMAGELIST, 0, FImages);

    SendMessage(FToolbar.Handle, TB_BUTTONSTRUCTSIZE, sizeof(TTBButton), 0);
    SendMessage(FToolbar.Handle, TB_ADDBUTTONS, cButtonCount, TIntPtr(@cButtons));

    Y := vRect.Bottom - ((cPanHeight + cTrkHeight) div 2);
    W := vRect.Right - X - cVolWidth - cDeltaX;
    FTracker := TMyTracker.CreateEx(Self, IdTracker, X, Y, W, cTrkHeight,
      TBS_HORZ or TBS_BOTH or TBS_ENABLESELRANGE or TBS_FIXEDLENGTH or TBS_NOTICKS {or TBS_TRANSPARENTBKGND}, '');
    FTracker.Perform(TBM_SETTHUMBLENGTH, 14, 0);
    FTracker.FOwner := FOwner;

    Inc(X, W);
    FVolCtrl := TMyVolume.CreateEx(Self, IdVolume, X, Y, cVolWidth, cTrkHeight,
      TBS_HORZ or TBS_BOTH or TBS_ENABLESELRANGE or TBS_FIXEDLENGTH or TBS_NOTICKS {or TBS_TRANSPARENTBKGND}, '');
    FVolCtrl.Perform(TBM_SETTHUMBLENGTH, 14, 0);
    FVolCtrl.SetLimit(100);
    FVolCtrl.FOwner := FOwner;
  end;


  procedure TPlayerWindow.RealignControls(const aRect :TRect);
  var
    X, Y, W :Integer;
  begin
    X := cDeltaX;
    if FShowOSD then
      Y := aRect.Bottom - ((cPanHeight + cTbrHeight) div 2)
    else
      Y := aRect.Bottom;

    FScreen.SetBounds(Rect(aRect.Left, aRect.Top, aRect.Right, Y), 0);

    FToolbar.SetBounds(Bounds(X, Y, cTbrWidth, cTbrHeight), 0);
    Inc(X, cTbrWidth);

    Y := aRect.Bottom - ((cPanHeight + cTrkHeight) div 2);
    W := aRect.Right - X - cVolWidth - cDeltaX;
    FTracker.SetBounds(Bounds(X, Y, W, cTrkHeight), 0);

    Inc(X, W);
    FVolCtrl.SetBounds(Bounds(X, Y, cVolWidth, cTrkHeight), 0);

//  Dec(aRect.Bottom, cPanHeight);
  end;


  procedure TPlayerWindow.WMWindowPosChanged(var Mess :TWMWindowPosChanged); {message WM_WindowPosChanged;}
  var
    vRect :TRect;
  begin
    inherited;
    vRect := ClientRect;
    if not RectEmpty(vRect) then begin
      if FTracker <> nil then
        RealignControls(vRect);
      if FOwner <> nil then
        FOwner.DoResize(FScreen.ClientRect);
    end;
  end;


  procedure TPlayerWindow.WMCtlColorStatic(var Mess :TWMCtlColorStatic); {message WM_CtlColorStatic;}
  begin
    if (Mess.ChildWnd = FTracker.Handle) or (Mess.ChildWnd = FVolCtrl.Handle) then begin
      if FBrush1 <> 0 then
        Mess.Result := Integer(FBrush1)
      else
        inherited;
    end else
    begin
      if FBrush2 <> 0 then begin
        SetBkMode(Mess.ChildDC, Transparent);
        Mess.Result := Integer(FBrush2);
      end else
        inherited;
    end;
  end;


  procedure TPlayerWindow.WMCommand(var Mess :TWMCommand); {message WM_COMMAND;}
  begin
    case Mess.ItemID of
      cButPlay:
        FOwner.Pause;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TPlayerWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
    FillRect(Mess.DC, ClientRect, FBrush1);
//  GradientFillRect(Mess.DC, vRect, cColor1, cColor2, True);
    Mess.Result := 1;
  end;


  procedure TPlayerWindow.CMLoadVideo(var Mess :TMessage); {message CM_LoadVideo;}
  begin
    FOwner.DoLoadFile;
    FTracker.SetLimit(FOwner.GetLenMS);
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
    end;
  end;


//procedure TPlayerWindow.SetColor(aColor :DWORD);
//begin
//  if (FBrush = 0) or (FColor <> aColor) then begin
//    WinDeleteObject(FBrush);
//    FColor := aColor;
//    FBrush := CreateSolidBrush(FColor);
//  end;
//end;


  procedure TPlayerWindow.ErrorHandler(E :Exception); {override;}
  begin
    Beep;
  end;


  function TPlayerWindow.IsFullScreen :Boolean;
  const
    cClassName = 'TFullscreenWindow';
  var
    vBuf :array[0..128] of TChar;
  begin
    Result := IsWindowVisible(FHandle) and (GetClassName(GetAncestor(Handle, GA_ROOT), vBuf, High(vBuf)) > 0) and
      (StrLIComp(@vBuf[0], cClassName, length(cClassName)) = 0);
  end;


  procedure TPlayerWindow.ShowOSD(aShow :Boolean);
  begin
    if FShowOSD <> aShow then begin
      FShowOSD := aShow;
      RealignControls(ClientRect);
    end;
  end;


  function TPlayerWindow.Idle :Boolean;
  var
    vPos, vState :Integer;
    vOldShow :Boolean;
    vTick :DWORD;
  begin
    vPos := FOwner.GetPosMS;

    vState := FOwner.FState;
    if (vState = 1) and (vPos = FOwner.GetLenMS) then
      vState := 3;

    if vState <> FLastState then begin
      FToolbar.SetButtonInfo(cButPlay, IntIf(vState = 1, 1, 0), '');
      FLastState := vState;
    end;

    if vPos <> FLastTime then begin
      FTracker.SetPos(vPos);
      FLastTime := vPos;
    end;

    if optVolume <> FLastVolume then begin
      FVolCtrl.SetPos(optVolume);
      FLastVolume := optVolume;
    end;

    vTick := GetTickCount;
    if (optHideOSDDelay <> 0) and (vState = 1) and IsFullScreen and (FOwner.FMedia <> nil) and FOwner.FMedia.IsVideo then begin
//    TraceF('%d', [TickCountDiff(vTick, FMouseTime)]);
      vOldShow := FShowOSD;
      ShowOSD( not (TickCountDiff(vTick, FMouseTime) > optHideOSDDelay) );
      if vOldShow and not FShowOSD then
        FHideTime := vTick;
    end else
    begin
      ShowOSD(True);
      FMouseTime := vTick;
    end;

    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewWinThread                                                            }
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


  function TView._AddRef :Integer;
  begin
    Result := InterlockedIncrement(FRefCount);
  end;

  function TView._Release :Integer;
  begin
    Result := InterlockedDecrement(FRefCount);
    if Result = 0 then
      Destroy;
  end;


  procedure TView.FreeStream;
  var
    vMedia :TMedia;
  begin
    if FMedia <> nil then begin
      vMedia := FMedia;
      FMedia := nil;
      vMedia.Free;
    end;
  end;


  procedure TView.DoLoadFile;
  begin
    FMedia := OpenMediaFile(PWideChar(FSrcName), FWindow.FScreen.Handle);
    if FMedia = nil then
      Exit;

    FMedia.GetVideoSize(FImgSize.CX, FImgSize.CY);
    FLength := FMedia.GetLength;
  end;


  function TView.LoadFile(const AName :TString) :Boolean;
  begin
    FSrcName := AName;
    SendMessage(FWindow.Handle, CM_LoadVideo, 0, 0);
    Result := FMedia <> nil;
  end;


  procedure TView.DoResize({const} ARect :TRect);
  begin
    FMedia.ResizeWindow(0, aRect);
  end;

(*
  procedure TView.DoResize({const} ARect :TRect);
  var
    vWinSize, vVideoSize :TSize;
    vScale :TFloat;
  begin
    vWinSize := RectSize(ARect);
    if (FImgSize.CX > 0) and (FImgSize.CY > 0) then begin
      vScale := FloatMin( vWinSize.CX / FImgSize.CX, vWinSize.cy / FImgSize.CY);
      vVideoSize := Size(Round(FImgSize.CX * vScale), Round(FImgSize.CY * vScale));
      ARect := Bounds( (vWinSize.CX - vVideoSize.CX) div 2, (vWinSize.CY - vVideoSize.CY) div 2, vVideoSize.CX, vVideoSize.CY);
      FMedia.ResizeWindow(0, aRect);
    end;
  end;
*)

  procedure TView.Play;
  begin
    FMedia.Play;
    FState := 1;
  end;


  procedure TView.Stop;
  begin
    FMedia.Stop;
    FState := 0;
  end;


  procedure TView.Pause;
  begin
    if GetLenMS = GetPosMS then begin
      GotoPosMS(0)
    end else
    if FState = 1 then begin
      FMedia.Pause;
      FState := 2;
    end else
    begin
      FMedia.Play;
      FState := 1;
    end;
  end;


  function TView.GetLenMS :Integer;
  begin
    Result := Round(FLength * 1000)
  end;


  function TView.GetPosMS :Integer;
  begin
    Result := 0;
    if FMedia = nil then
      Exit;

    Result := Round(FMedia.GetPosition * 1000);
  end;


  procedure TView.GotoPosMS(aPos :Integer);
  begin
    aPos := RangeLimit(aPos, 0, GetLenMS);
    FMedia.SetPosition(aPos / 1000);
  end;


  procedure TView.SetVolume(aVolume :Integer);
  begin
    aVolume := RangeLimit(aVolume, 0, 100);
    FMedia.SetVolume(aVolume);
    optVolume := aVolume;
  end;


  procedure TView.Activate;
  var
    vRect :TRect;
  begin
//  TraceF('TView.Activate. Visible=%d, Src=%s', [Byte(IsWindowVisible(ReviewWindow)), FSrcName]);
    if FMedia = nil then
      SendMessage(FWindow.Handle, CM_LoadVideo, 0, 0);

    SetParent(FWindow.Handle, ReviewWindow);

    GetClientRect(ReviewWindow, vRect);
    FWindow.SetBounds(vRect, 0);

    FWindow.Show(SW_SHOWNA);

    try
      SetVolume(optVolume);
    except
    end;

    try
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

  function pvdInit2(pInit :PPVDInitPlugin2) :integer; stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdInit2');
   {$endif bTracePvd}
    Result := PVD_UNICODE_INTERFACE_VERSION;

//  if not xVideo_Init(0, 0) then
//    begin pInit.nErrNumber := 1; exit; end;
  end;


  procedure pvdExit2(pContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdExit2');
   {$endif bTracePvd}
//  xVideo_Free;
  end;


  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdPluginInfo2');
   {$endif bTracePvd}
    pPluginInfo.pName := 'DXVideo';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2013, Maxim Rusov';
    pPluginInfo.Flags := PVD_IP_DECODE or PVD_IP_DISPLAY or PVD_IP_PRIVATE or PVD_IP_NEEDFILE;
    pPluginInfo.Priority := $0F01;
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
      pImageInfo.Flags := PVD_IIF_MOVIE;
      pImageInfo.nPages := Round(vView.FLength * 1000);
//    if vView.FFmtName <> '' then
//      pImageInfo.pFormatName := PTChar(vView.FFmtName);

      pImageInfo.pImageContext := vView;
      vView._AddRef;

      Result := True;
    end;
  end;


  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdPageInfo2: ImageContext=%p, Frame=%d', [pImageContext, pPageInfo.iPage]);
   {$endif bTracePvd}
    with TView(pImageContext) do begin

      pPageInfo.lWidth := FImgSize.cx;
      pPageInfo.lHeight := FImgSize.cy;
//    pPageInfo.nBPP := FPixels;
//    TraceF('  pvdPageInfo2 result: Page=%d, Size=%d %d', [pPageInfo.iPage, FImgSize.cx, FImgSize.cy]);

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

      pDecodeInfo.lWidth := FImgSize.cx;
      pDecodeInfo.lHeight := FImgSize.cy;
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

  // Инициализация контекста дисплея. Используется тот pContext, который был получен в pvdInit2
  function pvdDisplayInit2(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdDisplayInit2: Context=%p; hWND=%d', [pContext, pDisplayInit.hWND]);
   {$endif bTracePvd}
    SetWindowHook(pDisplayInit.hWND);
    Result := True;
  end;


  // Прицепиться или отцепиться от окна вывода
  function pvdDisplayAttach2(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdDisplayAttach2: Attach=%d, Wnd=%d', [Byte(pDisplayAttach.bAttach), pDisplayAttach.hWnd]);
   {$endif bTracePvd}
    Result := True;
  end;


  // Создать контекст для отображения картинки в pContext (перенос декодированных данных в видеопамять)
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


  // Закрыть контекст для отображения картинки (освободить видеопамять)
  procedure pvdDisplayClose2(pContext :Pointer; pDisplayContext :Pointer); stdcall;
  var
    vView :TView;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdDisplayClose2: DisplayContext=%p', [pDisplayContext]);
   {$endif bTracePvd}
    vView := pDisplayContext;
    if vView <> nil then begin

      if vView = ActiveView then
        SetActiveView(nil);

      vView._Release;
    end;
  end;

  // Закрыть модуль вывода (освобождение интерфейсов DX, отцепиться от окна)
  procedure pvdDisplayExit2(pContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdDisplayExit2');
   {$endif bTracePvd}

    ReleaseWindowHook;
  end;


 {-----------------------------------------------------------------------------}

  function pvdPlayControl(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; pInfo :Pointer) :Integer; stdcall;
  begin
    Result := 0;
    if pImageContext = ActiveView then begin
      case aCmd of
        PVD_PC_Play, PVD_PC_Pause, PVD_PC_Stop:
          SendMessage(ActiveView.FWindow.Handle, CM_Command, aCmd, 0);
        PVD_PC_GetState:
          Result := ActiveView.FWindow.FLastState;
        PVD_PC_GetPos:
          Result := ActiveView.FWindow.FLastTime;
        PVD_PC_SetPos:
          SendMessage(ActiveView.FWindow.Handle, CM_GotoPos, TIntPtr(pInfo), 0);
        PVD_PC_GetVolume:
          Result := optVolume;
        PVD_PC_SetVolume:
          SendMessage(ActiveView.FWindow.Handle, CM_SetVolume, TIntPtr(pInfo), 0);
//      PVD_PC_Mute      = 9;
      end;
    end;
  end;


end.


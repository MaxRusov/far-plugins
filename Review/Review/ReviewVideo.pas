{$I Defines.inc}

unit ReviewVideo;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2021, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    Commctrl,
    Messages,

    Far_API,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,
    FarMenu,
    FarColorDlg,

    FarCtrl,
    FarConfig;


  var
    optVolume :Integer = 100;

    optHideOSDDelay :Integer = 3000;

  var
    cColor1  :Integer = $FADAC4; // $E4DAAF;
    cColor2  :Integer = $F5BE9E; // $D6C583;
    cColor3  :Integer = $FEECDD; // $F0EBD5;


  const
    cPanHeight  = 24;

 type
    TMyTracker = class;
    TMySeeker = class;
    TMyVolume = class;
    TMyToolbar = class;

    TVideoWindow = class;
    TControlWindow = class;


    TVideoWindow = class(TMSWindow)
    public
      constructor CreateEx(AOwner :TMSWindow);
      destructor Destroy; override;
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMLButtonDblClk(var Mess :TMessage); message WM_LButtonDblClk;
//    procedure WMNCHitTest(var Mess :TWMNCHitTest); message WM_NCHitTest;
//    procedure WMSYSCOMMAND(var Mess :TMessage); message WM_SYSCOMMAND;

      procedure DefaultHandler(var Mess); override;

    private
      FOwner :TMSWindow;
      FCtrl  :TControlWindow;

    public
      property Ctrl :TControlWindow read FCtrl write FCtrl;
    end;


    TControlWindow = class(TMSWindow)
    public
      constructor CreateEx(AOwner :TMSWindow);
      destructor Destroy; override;
      procedure AfterConstruction; override;

      procedure CreateParams(var AParams :TCreateParams); override;

      procedure SetHidden(aHidden :Boolean);
      procedure ActiveAction;

      procedure Idle;

    private
      FOwner    :TMSWindow; {TImageWindow}

      FToolbar  :TMyToolbar;
      FTracker  :TMySeeker;
      FVolCtrl  :TMyVolume;

//    FBrush    :HBrush;
      FBrush1   :HBrush;
      FBrush2   :HBrush;

      FLastState  :Integer;  { 0-Stopped 1-Play, 2-Pause, 3-Finished }
      FLastTime   :Integer;
      FLastVolume :Integer;

      FHidden     :Boolean;
      FHideTime   :DWORD;
      FLastAction :DWORD;

      FLastAlive  :DWORD;

      procedure WMSize(var Mess :TWMSize); message WM_Size;
      procedure WMCtlColorStatic(var Mess :TWMCtlColorStatic); message WM_CtlColorStatic;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMCommand(var Mess :TWMCommand); message WM_COMMAND;
      procedure Realign;

    public
      property Hidden :Boolean read FHidden;
    end;


    TMyTracker = class(TTracker)
    public
      procedure SetLimit(AValue :Integer);
      procedure SetPos(AValue :Integer);

    protected
      procedure StartChangePos; virtual;
      procedure EndChangePos; virtual;
      procedure ChangePos(aValue :Integer); virtual;

    private
      FLimit   :Integer;
      FDragged :Boolean;
      FOwner   :TMSWindow; {TImageWindow}

      function XPosToPos(aXPos :Integer) :Integer;
      procedure WMLButtonDown(var Mess :TWMLButtonDown); message WM_LButtonDown;
      procedure WMMouseMove(var Mess :TWMMouseMove); message WM_MouseMove;
      procedure WMLButtonUp(var Mess :TWMLButtonUp); message WM_LButtonUp;
    end;


    TMySeeker = class(TMyTracker)
    protected
      procedure StartChangePos; override;
      procedure EndChangePos; override;
      procedure ChangePos(aValue :Integer); override;
    end;

    TMyVolume = class(TMyTracker)
    protected
      procedure ChangePos(aValue :Integer); override;
    end;


    TMyToolbar = class(TToolbar)
    public
      procedure AfterConstruction; override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewClasses,
    MixDebug;


  const
    cDeltaX     =  5;
    cDeltaY     = 10;

//  cPanHeight  = 24;
    cTbrHeight  = 22;
    cTbrWidth   = 24;
    cTrkHeight  = 18;

    cVolWidth   = 50;

    IdTracker   = 10;
    IdVolume    = 11;

    cButPlay    = 1;


 {-----------------------------------------------------------------------------}

  type
    EXECUTION_STATE = dword;

  const
    ES_SYSTEM_REQUIRED   = $00000001;
    ES_DISPLAY_REQUIRED  = $00000002;
    ES_USER_PRESENT      = $00000004;
    ES_AWAYMODE_REQUIRED = $00000040;
    ES_CONTINUOUS        = $80000000;

//  function SetThreadExecutionState(esFlags :EXECUTION_STATE) :EXECUTION_STATE; stdcall;
//    external 'kernel32.dll' name 'SetThreadExecutionState';

  var
    SetThreadExecutionState :function(esFlags :EXECUTION_STATE) :EXECUTION_STATE; stdcall;

  procedure InitAPI;
  var
    vKernel :THandle;
  begin
    vKernel := GetModuleHandle(Windows.Kernel32);
    if vKernel <> 0 then
      @SetThreadExecutionState := GetProcAddress(vKernel, 'SetThreadExecutionState');
  end;


 {-----------------------------------------------------------------------------}
 { TVideoWindow                                                                }
 {-----------------------------------------------------------------------------}

  constructor TVideoWindow.CreateEx(AOwner :TMSWindow);
  begin
    Create;
    FOwner := AOwner;
  end;


  destructor TVideoWindow.Destroy; {override;}
  begin
    DestroyHandle;
    inherited Destroy;
  end;


  procedure TVideoWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    AParams.Style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN;
    AParams.WndParent := FOwner.Handle;
  end;


  procedure TVideoWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd}
  begin
    FillRect(Mess.DC, ClientRect, COLOR_WINDOWTEXT + 1);
    Mess.Result := 1;
  end;


  procedure TVideoWindow.WMLButtonDblClk(var Mess :TMessage); {message WM_LButtonDblClk;}
  begin
    Mess.Result := SendMessage(FOwner.Handle, Mess.Msg, Mess.WParam, Mess.LParam);
  end;


//  procedure TVideoWindow.WMSysCommand(var Mess :TMessage); {message WM_SYSCOMMAND;}
//  begin
//    case Mess.WParam of
//      SC_SCREENSAVE: begin
//        Trace('SC_SCREENSAVE...');
//        Mess.Result := 0;
//      end;
//      SC_MONITORPOWER: begin
//        Trace('SC_MONITORPOWER...');
//        Mess.Result := 0;
//      end
//    else
//      inherited;
//    end;
//  end;



//procedure TVideoWindow.WMNCHitTest(var Mess :TWMNCHitTest); {message WM_NCHitTest;}
//begin
//  Mess.Result := HTTRANSPARENT;
//end;


  procedure TVideoWindow.DefaultHandler(var Mess ); {override;}
  begin
    with TMessage(Mess) do
      if (Msg >= WM_MOUSEFIRST) and (Msg <= WM_MOUSELAST) then
        if FCtrl <> nil then
          FCtrl.ActiveAction;
    inherited;
  end;


 {-----------------------------------------------------------------------------}
 { TControlWindow                                                              }
 {-----------------------------------------------------------------------------}

  constructor TControlWindow.CreateEx(AOwner :TMSWindow);
  begin
    Create;
    Assert(AOwner is TImageWindow);
    FOwner := AOwner;

    FBrush1 := CreateSolidBrush(cColor1);
    FBrush2 := CreateSolidBrush(cColor3);
  end;


  destructor TControlWindow.Destroy; {override;}
  begin
    DestroyHandle;

    FreeObj(FTracker);
    FreeObj(FVolCtrl);
    FreeObj(FToolbar);

//  WinDeleteObject(FBrush);
    WinDeleteObject(FBrush1);
    WinDeleteObject(FBrush2);

    inherited Destroy;
  end;


  procedure TControlWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    AParams.Style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN;
    AParams.WndParent := FOwner.Handle;
  end;



  procedure TControlWindow.AfterConstruction; {override;}
  var
    vRect :TRect;
    Y, X, W :Integer;
  begin
    inherited AfterConstruction;

    vRect := ClientRect;

    X := cDeltaX;
    Y := vRect.Bottom - ((cPanHeight + cTbrHeight) div 2);

    FToolbar := TMyToolbar.CreateEx(Self, 0, X, Y, cTbrWidth, cTbrHeight,
      CCS_NORESIZE or CCS_NODIVIDER or TBSTYLE_FLAT, '');
    Inc(X, cTbrWidth);

    Y := vRect.Bottom - ((cPanHeight + cTrkHeight) div 2);
    W := vRect.Right - X - cVolWidth - cDeltaX;
    FTracker := TMySeeker.CreateEx(Self, IdTracker, X, Y, W, cTrkHeight,
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


  procedure TControlWindow.Realign;
  var
    aRect :TRect;
    X, Y, W :Integer;
  begin
    aRect := ClientRect;

    X := cDeltaX;
    if True {FShowOSD} then
      Y := aRect.Bottom - ((cPanHeight + cTbrHeight) div 2)
    else
      Y := aRect.Bottom;

    FToolbar.SetBounds(Bounds(X, Y, cTbrWidth, cTbrHeight), 0);
    Inc(X, cTbrWidth);

    Y := aRect.Bottom - ((cPanHeight + cTrkHeight) div 2);
    W := aRect.Right - X - cVolWidth - cDeltaX;
    FTracker.SetBounds(Bounds(X, Y, W, cTrkHeight), 0);

    Inc(X, W);
    FVolCtrl.SetBounds(Bounds(X, Y, cVolWidth, cTrkHeight), 0);
  end;


  procedure TControlWindow.WMSize(var Mess :TWMSize); {message WM_Size;}
  begin
    inherited;
    if FVolCtrl <> nil then
      Realign;
  end;


  procedure TControlWindow.WMCtlColorStatic(var Mess :TWMCtlColorStatic); {message WM_CtlColorStatic;}
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


  procedure TControlWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
    FillRect(Mess.DC, ClientRect, FBrush1);
//  GradientFillRect(Mess.DC, vRect, cColor1, cColor2, True);
    Mess.Result := 1;
  end;


  procedure TControlWindow.WMCommand(var Mess :TWMCommand); {message WM_COMMAND;}
  begin
    case Mess.ItemID of
      cButPlay:
        TImageWindow(FOwner).PlayPause;
    end;
  end;


  procedure TControlWindow.Idle;

    function MouseInMyBounds :Boolean;
    var
      vPoint :TPoint;
    begin
      Windows.GetCursorPos(vPoint);
      ScreenToClient(Handle, vPoint);
      Result := RectContainsXY(ClientRect, vPoint.X, vPoint.Y);
    end;

  var
    vLen, vPos, vState, vVol :Integer;
    vOwner :TImageWindow;
  begin
    vOwner := TImageWindow(FOwner);

    vState := vOwner .GetMediaState;
    vLen := vOwner.GetMediaLen;
    vPos := vOwner.GetMediaPos;

    if (vState = 1) and (vPos = vLen) then
      vState := 3;

    if vState <> FLastState then begin
      FToolbar.SetButtonInfo(cButPlay, IntIf(vState = 1, 1, 0), '');
      FLastState := vState;
    end;

    if vPos <> FLastTime then begin
//    Trace('SetPos: %d', [vPos]);
      FTracker.SetLimit(vLen);
      FTracker.SetPos(vPos);
      FLastTime := vPos;
    end;

    if not FTracker.FDragged then
      vVol := vOwner.GetMediaVolume
    else
      vVol := FLastVolume;

    if vVol <> FLastVolume then begin
      FVolCtrl.SetPos(vVol);
      FLastVolume := vVol;
    end;

    if (vState = 1) and (TickCountDiff(GetTickCount, FLastAlive) > 1000) and Assigned(SetThreadExecutionState) then begin
//    Trace('SetThreadExecutionState......');
      SetThreadExecutionState(ES_DISPLAY_REQUIRED);
      FLastAlive := GetTickCount;
    end;

    if (vState = 1) and (vOwner.WinMode = wmFullscreen) and vOwner.GetMediaIsVideo then begin
      if MouseInMyBounds then
        ActiveAction;
      if (FLastAction <> 0) and (TickCountDiff(GetTickCount, FLastAction) > optHideOSDDelay) then begin
        SetHidden(True);
        FLastAction := 0;
      end;
    end else
    begin
      SetHidden(False);
      FLastAction := 0;
    end;
  end;


  procedure TControlWindow.SetHidden(aHidden :Boolean);
  begin
    if FHidden <> aHidden then begin
//    Trace('SetHidden: %d', [byte(aHidden)]);
      FHidden := aHidden;
      if FHidden then
        FHideTime := GetTickCount
      else
        FHideTime := 0;
      TImageWindow(FOwner).RealignOSD;
    end;
  end;


  procedure TControlWindow.ActiveAction;
  begin
    if (FHideTime <> 0) and (TickCountDiff(GetTickCount, FHideTime) < 100) then
      Exit;
    SetHidden(False);
    FLastAction := GetTickCount;
  end;


 {-----------------------------------------------------------------------------}
 { TMyTracker                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TMyTracker.SetLimit(AValue :Integer);
  begin
    if aValue <> FLimit then begin
      FLimit := AValue;
      if FLimit > $7F00 then
        AValue := $7F00;
      Perform(TBM_SETRANGE, 1, MakeLong(0, AValue));
    end;
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
    StartChangePos;
    ChangePos(XPosToPos(Mess.XPos));
    SetCapture(Handle);
    FDragged := True;
    Mess.Result := 0;
  end;


  procedure TMyTracker.WMMouseMove(var Mess :TWMMouseMove); {message WM_MouseMove;}
  var
    vPos :Integer;
  begin
    if FDragged then begin
      vPos := XPosToPos(Mess.XPos);
      ChangePos(vPos);
      SetPos(vPos);
    end;
    Mess.Result := 0;
  end;


  procedure TMyTracker.WMLButtonUp(var Mess :TWMLButtonUp); {message WM_LButtonUp;}
  begin
    if FDragged then begin
      EndChangePos;
      ReleaseCapture;
      FDragged := False;
    end;
    Mess.Result := 0;
  end;


  procedure TMyTracker.StartChangePos; {virtual;}
  begin
  end;

  procedure TMyTracker.EndChangePos; {virtual;}
  begin
  end;

  procedure TMyTracker.ChangePos(aValue :Integer); {virtual;}
  begin
  end;


 {-----------------------------------------------------------------------------}
 { TMySeeker                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMySeeker.StartChangePos; {override;}
  begin
    TImageWindow(FOwner).SetMediaVolume(0);
  end;

  procedure TMySeeker.EndChangePos; {override;}
  begin
    TImageWindow(FOwner).SetMediaVolume(optVolume);
  end;


  procedure TMySeeker.ChangePos(aValue :Integer); {override;}
  begin
    TImageWindow(FOwner).SetMediaPos(aValue);
  end;


 {-----------------------------------------------------------------------------}
 { TMyVolume                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyVolume.ChangePos(aValue :Integer); {override;}
  begin
    TImageWindow(FOwner).SetMediaVolume(aValue);
    optVolume := aValue;
  end;


 {-----------------------------------------------------------------------------}
 { TMyToolbar                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyToolbar.AfterConstruction; {override;}
  const
    cButSize = 16;
    cButtonCount = 1;
    cButtons :array[0..cButtonCount - 1] of TTBButton = (
      (iBitmap:0; idCommand:cButPlay; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON)
//    (iBitmap:2; idCommand:cButStop; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
//    (fsStyle:TBSTYLE_SEP),
    );
  var
    vImages  :HImagelist;
  begin
    inherited AfterConstruction;

    vImages := ImageList_LoadBitmap(HInstance, 'Buttons', cButSize, 0, RGB(255,255,255));
    SendMessage(FHandle, TB_SETIMAGELIST, 0, vImages);
    SendMessage(FHandle, TB_BUTTONSTRUCTSIZE, sizeof(TTBButton), 0);
    SendMessage(FHandle, TB_ADDBUTTONS, cButtonCount, TIntPtr(@cButtons));
  end;


initialization
  InitAPI;
end.

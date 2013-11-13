{$I Defines.inc}

{$Define bSetClip}

unit ReviewClasses;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* Review                                                                     *}
{* Image Viewer Plugn for Far 2/3                                             *}
{******************************************************************************}

interface

  uses
    Windows,
    MultiMon,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,

    Far_API,
    FarCtrl,
    FarMenu,
    FarPlug,
    FarDlg,
    FarGrid,
    FarListDlg,
    FarColorDlg,
    FarConMan,

    PVAPI,
    GDIImageUtil,
    ReviewConst,
    ReviewDecoders,
    ReviewGDIPlus;

  const
    CM_SetImage   = $B000;
    CM_Transform  = $B001;
    CM_SetWinPos  = $B002;
    CM_SetVisible = $B003;
    CM_SetMode    = $B004;
    CM_Move       = $B005;
    CM_Scale      = $B006;
    CM_Sync       = $B007;
    CM_TempMsg    = $B008;

    cPreCacheLimit = 128 * 1024 * 1024;  //???

  const
    cScaleStep   = 1.01;
    cMoveStep    = 25;
    cMoveStepSec = 10;
    cMoveStep1   = 1;

  type
    TWinMode = (
      wmNormal,
      wmQuickView,
      wmFullscreen
    );

    TScaleMode = (
      smExact,
      smAutoFit
    );

    TScaleSetMode = (
      smSetMode,
      smSetScale,
      smDeltaScale,
      smDeltaScaleMouse
    );

    TRedecodeMode = (
      rmSame,
      rmBest,
      rmNext,
      rmPrev
    );

  type
    TReviewWindow = class;
    TReviewWinThread = class;
    TReviewImage = class;
    TReviewManager = class;


    PSetImageRec = ^TSetImageRec;
    TSetImageRec = packed record
      Image   :TReviewImage;
      WinMode :Integer;
      WinRect :TRect;
    end;

    TFullscreenWindow = class(TMSWindow)
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
    private
      procedure HideWindow;
    end;

    TReviewWindow = class(TMSWindow)
    public
      constructor Create; override;
      destructor Destroy; override;

      function Idle :Boolean;

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure CMSetImage(var Mess :TMessage); message CM_SetImage;
      procedure CMTransform(var Mess :TMessage); message CM_Transform;
      procedure CMSetWinPos(var Mess :TMessage); message CM_SetWinPos;
      procedure CMSetVisible(var Mess :TMessage); message CM_SetVisible;
      procedure CMSetMode(var Mess :TMessage); message CM_SetMode;
      procedure CMMove(var Mess :TMessage); message CM_Move;
      procedure CMScale(var Mess :TMessage); message CM_Scale;
      procedure CMSync(var Mess :TMessage); message CM_Sync;
      procedure CMTempMsg(var Mess :TMessage); message CM_TempMsg;
//    procedure WMNCHitTest(var Mess :TWMNCHitTest); message WM_NCHitTest;
      procedure WMMouseActivate(var Mess :TWMMouseActivate); message WM_MouseActivate;
      procedure WMSize(var Mess :TWMSize); message WM_Size;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMPaint(var Mess :TWMPaint); message WM_Paint;
      procedure WMKeyDown(var Mess :TWMKeyDown); message WM_KeyDown;
      procedure WMLButtonDown(var Mess :TWMLButtonDown); message WM_LButtonDown;
      procedure WMMouseMove(var Mess :TWMMouseMove); message WM_MouseMove;
      procedure WMLButtonUp(var Mess :TWMLButtonUp); message WM_LButtonUp;
      procedure WMLButtonDblClk(var Mess :TWMLButtonDblClk); message WM_LButtonDblClk;

    private
      FWinMode      :TWinMode;
      FWinRect      :TRect;
      FWinBPP       :Integer;
      FImage        :TReviewImage;

      FColor        :Integer;
      FBrush        :HBrush;
      FMsgBrush     :HBrush;

      FDecoder      :TReviewDecoder;  { "Attached" decoder }
      FImageOk      :Boolean;

      FMode         :TScaleMode;      {  }
      FLnScale      :TFloat;          { Логарифмический масштаб }
      FScale        :TFloat;          { Масштаб }
      FDelta        :TPoint;          { Смещение (центра картинки от центра экрана) }
      FDeltaScale   :TFloat;          { Масштаб смещения }
      FMouseLock    :Integer;         { Масштабирование по позиции мыши }

      FSrcRect      :TRect;
      FDstRect      :TRect;

      FDragged      :Boolean;
      FMousePos     :TPoint;

      FParentRect   :TRect;
      FLastArea     :Integer;
      FClipped      :Boolean;

      FAnimate      :Boolean;
      FPageStart    :TUns32;

      FTempMsg      :TString;
      FMsgStart     :TUns32;
      FMsgDelay     :Integer;

      FHiQual       :Boolean;
      FDraftMode    :Boolean;
      FDraftStart   :DWORD;
      FClipStart    :DWORD;

      FNeedSync     :Boolean;
      FSyncStart    :TUns32;
      FSyncCmd      :Integer;
      FSyncDelay    :Integer;

      procedure CreateBrushes;
      function CalcWinRect :TRect;
      procedure RecalcRects;
      function GetMousePos :TPoint;
      procedure MoveImage(DX, DY :Integer);
      procedure SetFullscreen(AOn :Boolean);
      procedure SetWinMode(AMode :TWinMode);
      procedure SetScale(aMode :TScaleMode; aLnScale, aScale :TFloat);
      procedure SetPage(aPage :Integer);
      procedure SetTempMsg(const AMsg :TString);
      procedure InvalidateMsgRect;
      procedure PaintWindow(DC :HDC);
      procedure DrawTempText(DC :HDC; const AStr :TString);

      procedure ShowWindow;
      procedure HideWindow;
      procedure SetWindowBounds(const aRect :TRect);

      procedure ReleaseDecoder;
      procedure ReleaseImage;
      procedure AttachDecoder(ADecoder :TReviewDecoder);

    public
      property WinMode :TWinMode read FWinMode;
      property Scale :TFloat read FScale;
      property ScaleMode :TScaleMode read FMode;
    end;


    TReviewWinThread = class(TThread)
    public
      constructor Create;
      procedure Execute; override;

    private
      FWindow :TReviewWindow;

    public
      property Window :TReviewWindow read FWindow;
    end;


    TReviewImage = class(TReviewImageRec)
    public
      constructor CreateEx(const aName :TString);
      destructor Destroy; override;

      function TryOpenBy(ADecoder :TReviewDecoder; AForce :Boolean) :Boolean;
      function TryOpen(AForce :Boolean) :Boolean;
      procedure DecodePage(ASize :TSize; ACache :Boolean);
      procedure UpdateBitmap;
      procedure Rotate(ARotate :Integer);
      procedure OrientBitmap(AOrient :Integer);

    private
      FDecoder     :TReviewDecoder;    { Выбранный декодер }
      FBitmap      :TReviewBitmap;     { Bitmap (только для не Selfdraw) }
      FIsThumbnail :Boolean;
      FSelected    :Integer;

      FOpenTime    :Integer;
      FDecodeTime  :Integer;

      FMapFile     :THandle;
      FMapHandle   :THandle;

      function PrecacheFile :Boolean;
      procedure ReleaseCache;

    public
      property Page :Integer read FPage;
      property Pages :Integer read FPages;
      property Orient :Integer read FOrient;
      property Decoder :TReviewDecoder read FDecoder;
    end;


    TReviewManager = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure InitSubplugins;
      procedure LoadBackground;

      function CanShowImage(const AFileName :TString) :Boolean;
      function ShowImage(const AFileName :TString; AMode :Integer; AForce :Boolean = False) :Boolean;
      procedure DisplayImage(aImage :TReviewImage; AMode :Integer);
      procedure SetImagePage(aPage :Integer);
      procedure Navigate(AOrig :Integer; AForward :Boolean);
      procedure Redecode(AMode :TRedecodeMode = rmSame; aShowInfo :Boolean = True);
      procedure Rotate(ARotate :Integer);
      procedure Orient(AOrient :Integer);
      function Save(const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;
      procedure SetFullscreen(aOn :Boolean);
      procedure ChangeVolume(aDeltaVolume, aVolume :Integer);
      procedure SetTempMsg(const AMsg :TString);
      procedure UpdateWindowPos;
      procedure SyncDelayed(aCmd, aDelay :Integer);
      procedure SyncWindow;
      procedure CacheNeighbor(ANext :Boolean);
      function IsQViewMode :Boolean;
      procedure CloseWindow;
      function GetWindowTitle :TString;

      function ProcessKey(AKey :Integer) :Boolean;
      function ProcessWheel(ADelta :Integer) :Boolean;
      function ProcessCommand :Boolean;
      procedure PluginSetup;

      procedure SetScale(aSetMode :TScaleSetMode; aScaleMode :TScaleMode; AValue :TFloat);

    private
      FDecoders   :TObjList;           { Список декодеров }
      FWinThread  :TReviewWinThread;
      FWindow     :TReviewWindow;
      FCommand    :Integer;            { Для навигации по плагинным панелям }
      FCmdFile    :TString;            { -/-/- }
      FCache      :TObjList;           { Закэшированные изображения }
      FFavDecoder :TReviewDecoder;     { Предпочитаемый декодер }

      FBackBmp    :TReviewBitmap;
      FShowInfo   :Boolean;

      procedure CreateWinThread;
      procedure CacheImage(aImage :TReviewImage);
      function FindInCache(const aFileName :TString) :TReviewImage;
      procedure ClearCache;
      procedure ShowDecoderInfo;
      function CalcWinRectAs(AMode :Integer) :TRect;
      function CalcWinSize(AMode :Integer = -1) :TSize;

      function GetImage :TReviewImage;

    public
      property Decoders :TObjList read FDecoders;
      property CurImage :TReviewImage read GetImage;
      property Window :TReviewWindow read FWindow;
    end;


  var Review :TReviewManager;


  { Модальное состояние... }

  type
    TViewModalDlg = class(TFarDialog)
    public
      procedure UpdateTitle;
      procedure SetTitle(const aTitle :TString);

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FQuick     :Boolean;
      FErrorStr  :TString;
      FPostKey   :Integer;
      FHidden    :Boolean;  { Окно изображения временно скрыто... }

      procedure ResizeDialog;
    end;


  var ModalDlg :TViewModalDlg;

  function ViewModalState(AView, AQuick :Boolean) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewDlgDecoders,
    ReviewDlgGeneral,
    ReviewDlgSaveAs,
    MixDebug;


  const
    WS_EX_NOACTIVATE = $08000000;

  var
    hConsoleTopWnd :THandle;

    GLockSync :Integer;


  procedure FreeImage(var aImage :TReviewImage);
  begin
    if aImage <> nil then begin
      aImage._Release;
      aImage := nil;
    end;
  end;


  procedure IntSwap(var A, B :Integer);
  var
    T :Integer;
  begin
    T := A;
    A := B;
    B := T;
  end;


  function RectContainsRect(const ARect, AIntRect :TRect) :Boolean;
  begin
    with AIntRect do
      Result := RectContainsXY(ARect, Left, Top) and RectContainsXY(ARect, Right - 1, Bottom - 1);
  end;


  function RectIntersects(const R1, R2 :TRect) :Boolean;
  begin
    Result :=
      (R2.Left < R1.Right) and (R2.Right > R1.Left) and
      (R2.Top < R1.Bottom) and (R2.Bottom > R1.Top);
  end;


  function FarKeyToName(AKey :Integer) :TString;
 {$ifdef Far3}
  var
    vInput :INPUT_RECORD;
    vLen :Integer;
  begin
    Result := '';
    if FarKeyToInputRecord(AKey, vInput) then begin
      vLen := FARSTD.FarInputRecordToName(vInput, nil, 0);
      if vLen > 0 then begin
        SetLength(Result, vLen - 1);
        FARSTD.FarInputRecordToName(vInput, PTChar(Result), vLen);
      end;
    end;
 {$else}
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FARSTD.FarKeyToName(AKey, nil, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen - 1);
      FARSTD.FarKeyToName(AKey, PTChar(Result), vLen);
    end;
 {$endif Far3}
  end;


  function ConsolePosToClientPoint(AX, AY :Integer) :TPoint;
    { Пересчитываем консольные координаты в координаты клиентской области окна }
  var
    vRect :TRect;
    vInfo :TConsoleScreenBufferInfo;
  begin
    GetClientRect(hFarWindow, vRect);
    GetConsoleScreenBufferInfo(hStdOut, vInfo);
    with vInfo.srWindow do begin
      Result.Y := MulDiv(AY - Top, vRect.Bottom, Bottom - Top + 1);
      Result.X := MulDiv(AX - Left, vRect.Right, Right - Left + 1);
    end;
  end;


  function MonitorRectFromPoint(const APoint :TPoint) :TRect;
  var
    vMonInfo :TMonitorInfo;
    vHM :HMONITOR;
  begin
    FillChar(vMonInfo, SizeOf(vMonInfo), 0);
    vMonInfo.cbSize := SizeOf(vMonInfo);
    vHM := MonitorFromPoint(APoint, MONITOR_DEFAULTTONEAREST);
    if vHM <> 0 then begin
      GetMonitorInfo(vHM, @vMonInfo);
//    Result := vMonInfo.rcWork;
      Result := vMonInfo.rcMonitor;
    end else
      Result := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
  end;


  function GetNormalWinRect(AFullscreen :Boolean) :TRect;
  var
    vPoint :TPoint;
  begin
    Windows.GetClientRect(hFarWindow, Result);
    if AFullscreen then begin
      vPoint := Point((Result.Left + Result.Right) div 2, (Result.Top + Result.Bottom) div 2);
      MapWindowPoints(hFarWindow, 0, vPoint, 1);
      Result := MonitorRectFromPoint(vPoint);
    end;
  end;


  function IsActiveConsole :boolean;
  begin
    Result := WindowIsChildOf(GetConsoleWnd, GetForegroundWindow) and ConManIsActiveConsole;
  end;


 {-----------------------------------------------------------------------------}
 { Диалог модального состояния                                                 }
 {-----------------------------------------------------------------------------}

  procedure TViewModalDlg.Prepare; {override;}
  var
    vTitle :TString;
  begin
    FHelpTopic := 'View';
    FGUID := cViewDlgID;
    FFlags := FDLG_NODRAWSHADOW or FDLG_NODRAWPANEL{???};
    FWidth := 20;
    FHeight := 5;
    vTitle := Review.GetWindowTitle;
    FDialog := CreateDialog(
      [ NewItemApi(DI_DoubleBox, 0,  0, FWidth, FHeight, 0, PTChar(vTitle)) ],
      @FItemCount
    );
  end;


  procedure TViewModalDlg.InitDialog; {override;}
  begin
    ResizeDialog;
  end;


  procedure TViewModalDlg.ResizeDialog;
  var
    vRect :TSmallRect;
  begin
    vRect := FarGetWindowRect;
    vRect.Right := vRect.Left;
    vRect.Bottom := vRect.Top;
    SetDlgPos(0, 0, vRect.Right + 1, vRect.Bottom + 1);
    SendMsg(DM_SETITEMPOSITION, 0, @vRect);
  end;


  procedure TViewModalDlg.UpdateTitle;
  begin
    SetTitle( Review.GetWindowTitle );
  end;


  procedure TViewModalDlg.SetTitle(const aTitle :TString);
  begin
    SetText(0, aTitle);
  end;


  function TViewModalDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    if FQuick then begin

      if AKey <> KEY_Esc then begin
        FarPostMacro('Keys("Esc ' + FarKeyToName(AKey) + '")');
      end else
        Result := inherited KeyDown(AID, AKey);

    end else
    begin
      if Review.ProcessKey(AKey) then
        UpdateTitle  
      else begin
        case AKey of
          KEY_F1 : begin
            Review.SyncDelayed(SyncCmdUpdateWin, 100);
          end;

          KEY_F9 : begin
            Review.SyncDelayed(SyncCmdUpdateWin, 100);
            Review.PluginSetup;
          end;

          KEY_F4..KEY_F8,KEY_F10,KEY_F11: begin
            FPostKey := AKey;
            Close;
          end;
        end;
        Result := inherited KeyDown(AID, AKey);
      end;
    end;
  end;


  function TViewModalDlg.MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; {override;}
  begin
    if AMouse.dwEventFlags and MOUSE_HWHEELED <> 0 then
      Review.Rotate(IntIf(Smallint(LongRec(AMouse.dwButtonState).Hi) > 0, 1, 2))
    else
    if AMouse.dwEventFlags and MOUSE_WHEELED <> 0 then
      Review.ProcessWheel(IntIf(Smallint(LongRec(AMouse.dwButtonState).Hi) > 0, 1, -1));
    Result := inherited MouseEvent(AID, AMouse);
  end;


  function TViewModalDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
//  Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        begin
          ResizeDialog;
          FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
        end;
//    DN_HELP:
//      Review.SyncDelayed(SyncCmdUpdateWin, 100);  *)
      DN_ENTERIDLE:
        begin
          if FHidden then
            Review.UpdateWindowPos;
        end;
    end;
    Result := inherited DialogHandler(Msg, Param1, Param2);
  end;


  procedure TViewModalDlg.ErrorHandler(E :Exception); {override;}
  begin
    FErrorStr := E.Message;
    Close;
  end;


  function ViewModalState(AView, AQuick :Boolean) :Boolean;
  var
    vKeys :TString;
    vOldFullscrren :Boolean;
  begin
    Assert(ModalDlg = nil);
    ModalDlg := TViewModalDlg.Create;
    try
      vOldFullscrren := optFullscreen;

      ModalDlg.FQuick := AQuick;
      Result := ModalDlg.Run = -1;

      if vOldFullscrren <> optFullscreen then
        PluginConfig(True);

      if ModalDlg.FErrorStr <> '' then begin
        Review.CloseWindow;
        ShowMessage(cPluginName, ModalDlg.FErrorStr, FMSG_WARNING or FMSG_MB_OK);
        if AView then
          FarPostMacro('Keys("Esc")');
      end else
      if Review.FCommand = GoCmdNone then begin
        Review.CloseWindow;
        if AView then
          vKeys := 'Esc';
        if ModalDlg.FPostKey <> 0 then
          vKeys := AppendStrCh(vKeys, FarKeyToName(ModalDlg.FPostKey), ' ');
        if vKeys <> '' then
          FarPostMacro('Keys("' + vKeys + '")');
      end else
      begin
        Review.CloseWindow; {???}
        Review.ProcessCommand;
      end;

    finally
      FreeObj(ModalDlg);
    end;
  end;

 {-----------------------------------------------------------------------------}
 { TFullscreenWindow                                                           }
 {-----------------------------------------------------------------------------}

  procedure TFullscreenWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    AParams.WndParent := hFarWindow;
    AParams.Style := WS_POPUP or WS_CLIPCHILDREN;
  end;


  procedure TFullscreenWindow.HideWindow;
  begin
    Show(SW_Hide);
  end;


  var
    FullScreenWin :TFullscreenWindow;


 {-----------------------------------------------------------------------------}
 { TReviewWindow                                                               }
 {-----------------------------------------------------------------------------}

  constructor TReviewWindow.Create; {override;}
  begin
    inherited Create;
    FMsgBrush := CreateSolidBrush(RGB(255, 255, 255));
  end;


  destructor TReviewWindow.Destroy; {override;}
  begin
    ReleaseImage;
    ReleaseDecoder;
    if FBrush <> 0 then
      DeleteObject(FBrush);
    if FMsgBrush <> 0 then
      DeleteObject(FMsgBrush);
    inherited Destroy;
  end;


  procedure TReviewWindow.CreateBrushes;
  var
    vColor :Integer;
  begin
    if FWinMode <> wmQuickView then
      vColor := FarAttrToCOLORREF(GetColorBG(optBkColor1))
    else
      vColor := FarAttrToCOLORREF(GetColorBG(optBkColor2));

    if (FBrush = 0) or (FColor <> vColor) then begin
      if FBrush <> 0 then
        DeleteObject(FBrush);
      FColor := vColor;
      FBrush := CreateSolidBrush(FColor);
    end;
  end;


  procedure TReviewWindow.ReleaseDecoder;
  begin
    if FDecoder <> nil then begin
      FDecoder.pvdDisplayDone(FHandle);
      FDecoder := nil
    end;
  end;


  procedure TReviewWindow.ReleaseImage;
  begin
    if FImage <> nil then begin
      if (FDecoder <> nil) and FImage.FSelfdraw then
        FDecoder.pvdDisplayClose(FImage);
      FreeImage(FImage);
      FImageOk := False;
    end;
  end;


  procedure TReviewWindow.AttachDecoder(ADecoder :TReviewDecoder);
  begin
    if FDecoder <> ADecoder then begin
      ReleaseDecoder;
      if ADecoder.pvdDisplayInit(FHandle) then
        FDecoder := ADecoder;
    end;
  end;


  procedure TReviewWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams); {CreateWindowEx}
    AParams.WndParent := hFarWindow;
    AParams.Style := WS_CHILD or WS_CLIPCHILDREN;
  end;


  procedure TReviewWindow.SetFullscreen(AOn :Boolean);
  begin
    if AOn then
      SetWinMode(wmFullscreen)
    else
      SetWinMode(wmNormal);
  end;


  procedure TReviewWindow.SetWinMode(AMode :TWinMode);
  begin
//  TraceF('TReviewWindow.SetWinMode: %d', [byte(AMode)]);

    if AMode <> FWinMode then begin
      FWinMode := AMode;
      if AMode <> wmQuickView then
        optFullscreen := AMode = wmFullscreen;  

      if FWinMode = wmFullscreen then begin
        Assert(FullScreenWin = nil);

        FullScreenWin := TFullscreenWindow.Create;
        FullScreenWin.SetBounds(CalcWinRect, 0);

        Windows.SetWindowPos(FullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW );
        SetForegroundWindow(hConsoleTopWnd);
        Windows.SetWindowPos(FullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE );

        SetParent(Handle, FullScreenWin.Handle);
        SetBounds(FullScreenWin.ClientRect, 0);
      end else
      begin
        SetParent(Handle, hFarWindow);
        SetWindowBounds(CalcWinRect);
        FreeObj(FullScreenWin);
      end;
    end;
  end;


  procedure TReviewWindow.WMMouseActivate(var Mess :TWMMouseActivate); {message WM_MouseActivate;}
  begin
    if FWinMode = wmFullscreen then begin
      if FullScreenWin <> nil then begin
//      TraceF('Make topmost. FullScreenWin=%x, Console=%x, Msg.TopLevel=%x, Msg.HitTest=%d, Msg.MouseMsg=%d, Msg.Result=%d',
//        [FullScreenWin.Handle, hConsoleTopWnd, Mess.TopLevel, Mess.HitTestCode, Mess.MouseMsg, Mess.Result]);
        Windows.SetWindowPos(FullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE );
        SetForegroundWindow(hConsoleTopWnd);
        Windows.SetWindowPos(FullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE );
      end;
    end else
    begin
//    TraceF('Make active2 %x...', [hConsoleTopWnd]);
      SetForegroundWindow(hConsoleTopWnd);
    end;

    Mess.Result := MA_NoActivate;
  end;


//procedure TReviewWindow.WMNCHitTest(var Mess :TWMNCHitTest); {message WM_NCHitTest;}
//begin
//  Mess.Result := HTTRANSPARENT;
//end;


  procedure TReviewWindow.CMSetImage(var Mess :TMessage); {message CM_SetImage;}
  begin
    with PSetImageRec(Mess.LParam)^ do begin
      ReleaseImage;

      AttachDecoder(Image.FDecoder);

      if WinMode <> -1 then begin
        if WinMode = 1 then
//        SetWinMode(wmQuickView)
          FWinMode := wmQuickView
        else
          SetFullscreen( optFullscreen );
      end;

      FWinRect := WinRect;
      FWinBPP  := ScreenBitPerPixel;

      FLastArea := MACROAREA_SHELL;
      FNeedSync := False;

      FImage := Image;
      FImage._AddRef;

      if FImage.FSelfdraw then
        FImageOk := (FDecoder <> nil) and FDecoder.pvdDisplayShow(FHandle, FImage)
      else
        FImageOk := FImage.FBitmap <> nil;

      if IsWindowVisible(Handle) and optKeepScale then
        {}
      else begin
        FMode := smAutoFit;
        FScale := 1;
        FLnScale := 0;
        FDelta := Point(0, 0);
        FDeltaScale := 1;
      end;

      FDraftMode := False;
      FHiQual := True;

      FAnimate := FImage.FAnimated and (FImage.FPages > 1) {and (FImage.FDelay > 0)};
      FPageStart := GetTickCount;

      FTempMsg := '';

      CreateBrushes;
      RecalcRects;

      if not IsWindowVisible(Handle) then
        ShowWindow
      else
      if FWinMode <> wmFullscreen then
        SetWindowBounds(CalcWinRect);

      Invalidate; 
      FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
    end;
  end;


  procedure TReviewWindow.CMTransform(var Mess :TMessage); {message CM_Transform;}

     procedure LocSetPage(APage :Integer);
     begin
       FAnimate := False;

       APage := RangeLimit(APage, 0, FImage.FPages - 1);
       if APage = FImage.FPage then
         Exit;

       SetPage( APage );
       FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
     end;

     procedure LocRotate(ARotate :Integer);
     begin
       FImage.Rotate(ARotate);
       FHiQual := True;
       FTempMsg := '';
       RecalcRects;
       Invalidate;
       FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
     end;

  begin
    if FImage <> nil then begin
      case Mess.wParam of
        0: LocSetPage(Mess.lParam);
        1: LocRotate(Mess.lParam);
        2: {};
      end;
    end;
  end;


  procedure TReviewWindow.CMSetWinPos(var Mess :TMessage); {message CM_SetWinPos;}
  begin
    with PSetImageRec(Mess.LParam)^ do begin
      FWinRect := WinRect;
      SetWindowBounds(CalcWinRect);
    end;
  end;


  procedure TReviewWindow.CMSetVisible(var Mess :TMessage); {message CM_SetVisible;}
  begin
    if Mess.wParam = 1 then begin
      CreateBrushes;
      if FullscreenWin <> nil then
        FullscreenWin.Show(SW_SHOWNA)
      else
        ShowWindow
    end else
    begin
      if FullscreenWin <> nil then
        FullscreenWin.HideWindow
      else
        HideWindow;
    end;
  end;


  procedure TReviewWindow.CMSetMode(var Mess :TMessage); {message CM_SetMode;}
  begin
    if FWinMode <> wmQuickView then
      SetFullscreen( Mess.wParam = 1 );
  end;


  procedure TReviewWindow.CMMove(var Mess :TMessage); {message CM_Move;}
  begin
    with PPoint(Mess.LParam)^ do
      MoveImage(X, Y);
  end;


  procedure TReviewWindow.CMScale(var Mess :TMessage); {message CM_Scale;}
  begin
    case TScaleSetMode(Mess.wParam) of
      smSetMode:
        SetScale(TScaleMode(Mess.lParam), 0, 1);
      smSetScale:
        SetScale(smExact, 0, PFloat(Pointer(Mess.lParam))^);
      smDeltaScale:
        SetScale(smExact, FLnScale + PFloat(Pointer(Mess.lParam))^, 0 );
      smDeltaScaleMouse:
        begin
          Inc(FMouseLock);
          try
            SetScale(smExact, FLnScale + PFloat(Pointer(Mess.lParam))^, 0 );
          finally
            Dec(FMouseLock);
          end;
        end;
    end;
  end;


  procedure TReviewWindow.CMSync(var Mess :TMessage); {message CM_Sync;}
  begin
    FNeedSync  := True;
    FSyncStart := GetTickCount;
    FSyncCmd   := Mess.wParam;
    FSyncDelay := Mess.lParam;
  end;


  procedure TReviewWindow.CMTempMsg(var Mess :TMessage); {message CM_TempMsg;}
  begin
    SetTempMsg(TString(Mess.lParam));
  end;


  function TReviewWindow.GetMousePos :TPoint;
  begin
    Windows.GetCursorPos(Result);
    ScreenToClient(Handle, Result);
  end;


  procedure TReviewWindow.MoveImage(DX, DY :Integer);

    procedure LocInc(var AVal :Integer; ADelta :Integer);
    begin
      if (ADelta > 0) and (AVal > MaxInt - ADelta) then
        AVal := MaxInt
      else
      if (ADelta < 0) and (AVal < -MaxInt - ADelta) then
        AVal := -MaxInt
      else
        Inc(AVal, ADelta);
    end;

  begin
    LocInc(FDelta.x, DX);
    LocInc(FDelta.y, DY);
    RecalcRects;
    Invalidate;
  end;


  procedure TReviewWindow.SetScale(aMode :TScaleMode; aLnScale, aScale :TFloat);
  begin
    FMode := aMode;
    if FMode = smExact then begin
      if aScale > 0 then begin
        FScale := aScale;
        FLnScale := Ln(FScale) / Ln(cScaleStep)
      end else
      begin
        FScale := Exp( aLnScale * Ln(cScaleStep) );
        FLnScale := aLnScale;
      end;
    end;
    RecalcRects;
    SetTempMsg(Format('Scale: %d%%', [Round(100 * FScale)]));
    Invalidate;
    FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
  end;


  procedure TReviewWindow.SetPage(aPage :Integer);
  begin
    FImage.FPage := RangeLimit(aPage, 0, FImage.FPages);
    FImage.DecodePage(Size(0,0), False);
    FHiQual := True;
    RecalcRects;
    if not FAnimate then
      SetTempMsg(Format('Page: %d / %d', [FImage.FPage + 1, FImage.FPages]));
    Invalidate;
  end;


  procedure TReviewWindow.SetTempMsg(const AMsg :TString);
  begin
    FTempMsg := AMsg;
    FMsgStart := GetTickCount;
    FMsgDelay := optTempMsgDelay;
    InvalidateMsgRect;
  end;


  procedure TReviewWindow.InvalidateMsgRect;
  var
    vRect :TRect;
  begin
    vRect := ClientRect;
    vRect.Top := vRect.Bottom - 18{???};
    InvalidateRect(FHandle, @vRect, True);
  end;



  procedure TReviewWindow.RecalcRects;
  var
    vWinRect :TRect;
    vWinSize, vPicSize, vOldPicSize :TSize;
    vMaxDelta, vOrigDelta, vFocusDelta, vDelta, vMousePos :TPoint;
  begin
    vWinRect := GetClientRect;
    with vWinRect do
      vWinSize := Size(Right - Left, Bottom - Top);

    if FMode = smAutoFit then begin
      if (FImage.FWidth > vWinSize.cx) or (FImage.FHeight > vWinSize.cy) then begin
        { Подберем масштаб, чтобы изображение вписывалось в экран }
        FScale := FloatMin( vWinSize.cx / FImage.FWidth, vWinSize.cy / FImage.FHeight);
        if FScale > 0 then
          FLnScale := Ln(FScale) / Ln( cScaleStep)
        else
          FLnScale := 0;
      end else
      begin
        FScale := 1;
        FLnScale := 0;
      end;
    end;

    vPicSize := Size(
      Round(FImage.FWidth * FScale),
      Round(FImage.FHeight * FScale)
    );

    if FDeltaScale <> FScale then begin
      { Пересчитываем смещение, чтобы не смещалась точка изображения, находящаяся в фокусе - }
      { в центре экрана или под курсором мыши }

      vDelta := Point(0, 0);
      if FMouseLock > 0 then begin
        vMousePos := GetMousePos;
        if RectContainsXY(vWinRect, vMousePos.X, vMousePos.Y) then
          vDelta := Point(
            (vWinSize.cx div 2) - vMousePos.X,
            (vWinSize.cy div 2) - vMousePos.Y
          );
      end;

      vOldPicSize := Size(
        Round(FImage.FWidth * FDeltaScale),
        Round(FImage.FHeight * FDeltaScale)
      );
      vFocusDelta := Point(
        (vOldPicSize.cx div 2) + FDelta.x + vDelta.X,
        (vOldPicSize.cy div 2) + FDelta.y + vDelta.Y
      );
      FDelta := Point(
        MulDiv(vFocusDelta.X, vPicSize.cx, vOldPicSize.cx) - (vPicSize.cx div 2) - vDelta.X,
        MulDiv(vFocusDelta.Y, vPicSize.cy, vOldPicSize.cy) - (vPicSize.cy div 2) - vDelta.Y
      );
      FDeltaScale := FScale;
    end;

    vMaxDelta := Point(
      IntMax(0, (vPicSize.CX - vWinSize.CX) div 2),
      IntMax(0, (vPicSize.CY - vWinSize.CY) div 2)
    );

    FDelta := Point(
      RangeLimit( FDelta.X, -vMaxDelta.X, +vMaxDelta.X),
      RangeLimit( FDelta.Y, -vMaxDelta.Y, +vMaxDelta.Y)
    );

    vOrigDelta := Point(
      ((vWinSize.cx - vPicSize.cx) div 2) + FDelta.x,
      ((vWinSize.cy - vPicSize.cy) div 2) + FDelta.y
    );

    FSrcRect := Rect(
      MulDiv(IntMax(0, -vOrigDelta.X), FImage.FWidth, vPicSize.cx),
      MulDiv(IntMax(0, -vOrigDelta.Y), FImage.FHeight, vPicSize.cy),
      MulDiv(IntMin(vPicSize.cx, vWinSize.cx - vOrigDelta.x), FImage.FWidth, vPicSize.cx),
      MulDiv(IntMin(vPicSize.cy, vWinSize.cy - vOrigDelta.y), FImage.FHeight, vPicSize.cy)
    );

    FDstRect := Rect(
      IntMax(0, vOrigDelta.X),
      IntMax(0, vOrigDelta.Y),
      IntMin(vWinSize.cx, vOrigDelta.X + vPicSize.cx),
      IntMin(vWinSize.cy, vOrigDelta.Y + vPicSize.cy)
    );
  end;


  function TReviewWindow.CalcWinRect :TRect;
  begin
    case FWinMode of
      wmNormal:
        Result := GetNormalWinRect(False);
      wmFullscreen:
        Result := GetNormalWinRect(True);
      wmQuickView:
        Result := FWinRect;
    end;
  end;


  procedure TReviewWindow.ShowWindow;
  begin
    FClipped := GetWindowLong(hFarWindow, GWL_STYLE) and WS_ClipChildren <> 0;
   {$ifdef bSetClip}
    if not FClipped then begin
      SetWindowLong(hFarWindow, GWL_STYLE, GetWindowLong(hFarWindow, GWL_STYLE) or WS_ClipChildren);
      FClipped := GetWindowLong(hFarWindow, GWL_STYLE) and WS_ClipChildren <> 0;
    end;
   {$endif bSetClip}

    Windows.GetClientRect(hFarWindow, FParentRect);

    if FWinMode <> wmFullscreen then
//    SetBounds(CalcWinRect, 0);
      SetWindowBounds(CalcWinRect);

    Show(SW_SHOWNA);
    SetForegroundWindow(hConsoleTopWnd);
  end;


  procedure TReviewWindow.HideWindow;
  begin
    Show(SW_Hide);
//  if GNeedWriteSizeSettings then
//    FarAdvControl(ACTL_SYNCHRO, scmSaveSettings);
//  GNeedWriteSizeSettings := False;
  end;


  procedure TReviewWindow.SetWindowBounds(const aRect :TRect);
  begin
    SetBounds(aRect, 0);

    if not FClipped then
      FClipStart := GetTickCount;
  end;


  procedure TReviewWindow.WMSize(var Mess :TWMSize); {message WM_Size;}
  begin
    inherited;
    if FImage <> nil then
      RecalcRects;
//  Invalidate;
  end;


  procedure TReviewWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
//  FillRect(Mess.DC, ClientRect, FBrush);
    Mess.Result := 1;
  end;


  procedure TReviewWindow.WMPaint(var Mess :TWMPaint); {message WM_Paint;}
  var
    DC :HDC;
    PS :TPaintStruct;
  begin
    DC := Mess.DC;
    if DC = 0 then
      DC := BeginPaint(Handle, PS);
    try
      PaintWindow(DC);
    finally
      if Mess.DC = 0 then
        EndPaint(Handle, PS);
    end;
  end;


  procedure TReviewWindow.PaintWindow(DC :HDC); {override;}
  var
    vTransparent :Boolean;

    function LocScaleX(X :Integer) :Integer;
    begin
      Result := MulDiv(X, FImage.FBitmap.Size.CX, FImage.FWidth);
    end;

    function LocScaleY(Y :Integer) :Integer;
    begin
      Result := MulDiv(Y, FImage.FBitmap.Size.CY, FImage.FHeight);
    end;


    procedure LocFillBackground(ADC :HDC; const aRect :TRect);
    var
      I, J, MI, MJ, X, Y :Integer;
    begin
      if optTranspBack and (Review.FBackBmp <> nil) then begin
        with Review.FBackBmp.Size do begin
          MI := (aRect.Right - aRect.Left + cx - 1) div cx;
          MJ := (aRect.Bottom - aRect.Top + cy - 1) div cy;
          Y := aRect.Top;
          for J := 0 to MJ - 1 do begin
            X := aRect.Left;
            for I := 0 to MI - 1 do begin
              BitBlt(
                ADC,
                X, Y, cx, cy,
                Review.FBackBmp.DC,
                0, 0,
                SRCCOPY);
              Inc(X, cx);
            end;
            Inc(Y, cy);
          end;
        end;
      end else
        FillRect(ADC, aRect, FBrush)
    end;


    procedure LocDraw(ADC :HDC; const ADstRect :TRect);
    var
      vBmpRect :TRect;
      vNeedStretch, vIncrease :Boolean;
    begin
      vBmpRect := FSrcRect;
      if (FImage.FBitmap.Size.CX <> FImage.FWidth) or (FImage.FBitmap.Size.CY <> FImage.FHeight) then
        { Размер декодированного битмапа не равен декларируемому размеру изображения - масштабируем }
        with FSrcRect do
          vBmpRect := Rect(LocScaleX(Left), LocScaleY(Top), LocScaleX(Right), LocScaleY(Bottom));

      vNeedStretch :=
        ((vBmpRect.Right - vBmpRect.Left) <> (ADstRect.Right - ADstRect.Left)) or
        ((vBmpRect.Bottom - vBmpRect.Top) <> (ADstRect.Bottom - ADstRect.Top));

      if vNeedStretch or (vTransparent and (FWinBPP < 32)) then begin
        vIncrease := (vBmpRect.Right - vBmpRect.Left) < (ADstRect.Right - ADstRect.Left);

        if FHiQual then begin
          if not FImage.FIsThumbnail and (vIncrease or vTransparent) {not (GetKeyState(VK_Shift) < 0)} then begin
            if TryLockGDIPlus then begin
              try
                GDIPlusStretchDraw(ADC, ADstRect, FImage.FBitmap.BMP, vBmpRect, vTransparent, True);
              finally
                UnlockGDIPlus;
              end;
            end else
              GDIStretchDraw(ADC, ADstRect, FImage.FBitmap.DC, vBmpRect, vTransparent, True);
          end else
            GDIStretchDraw(ADC, ADstRect, FImage.FBitmap.DC, vBmpRect, vTransparent, True);
          FDraftMode := False;
        end else
        begin
          if vTransparent and (FWinBPP < 32) then
            GDIPlusStretchDraw(ADC, ADstRect, FImage.FBitmap.BMP, vBmpRect, vTransparent, False)
          else
            GDIStretchDraw(ADC, ADstRect, FImage.FBitmap.DC, vBmpRect, vTransparent, False);
          FDraftMode := True;
          FDraftStart := GetTickCount;
        end;
      end else
      begin
        GDIBitBlt(ADC, ADstRect, FImage.FBitmap.DC, vBmpRect, vTransparent);
        FDraftMode := False;
      end;
    end;

  var
    vSize, vPicSize :TSize;
    vClientRect, vClipRect, vTmpRect, vRect :TRect;
    I, J, vTileX, vTileY :Integer;
    vSaveDC :Integer;
    vMemDC :TMemDC;
  begin
    vClientRect := ClientRect;
    try
      GetClipBox(DC, vClipRect);

      if FImageOk then begin
        if FImage.FSelfdraw then
          FDecoder.pvdDisplayPaint(Handle, FImage, FSrcRect, FDstRect, FColor)
        else begin

          vTileX := 0; vTileY := 0;
          if optTileMode then begin
            vPicSize := Size(
              Round(FImage.FWidth * FScale),
              Round(FImage.FHeight * FScale));
            vTileX := IntMax((FDstRect.Left + vPicSize.CX - 1) div vPicSize.CX, 0);
            vTileY := IntMax((FDstRect.Top + vPicSize.CY - 1) div vPicSize.CY, 0);
          end;

          if optTileMode or RectIntersects(FDstRect, vClipRect) then begin
//          with vClipRect do
//            TraceF('Draw. ClipRect=%dx%d-%dx%d', [Left, Top, Right, Bottom]);
            vTransparent := FImage.FTransparent {and (FWinBPP = 32)};

            if vTransparent or (vTileX > 0) or (vTileY > 0) then begin
              vSize := RectSize(FDstRect);
              vMemDC := TMemDC.Create(vSize.CX, vSize.CY);
              try
                vTmpRect := Bounds(0, 0, vSize.CX, vSize.CY);
                if vTransparent then
                  LocFillBackground(vMemDC.DC, vTmpRect);

                LocDraw(vMemDC.DC, vTmpRect);

                if (vTileX > 0) or (vTileY > 0) then begin
                  vRect := FDstRect;
                  RectMove(vRect, -vTileX * vSize.CX, -vTileY * vSize.CY);
                  for J := 0 to vTileY * 2 do begin
                    for I := 0 to vTileX * 2 do begin
                      GDIBitBlt(DC, vRect, vMemDC.DC, vTmpRect, False);
                      RectMove(vRect, vSize.CX, 0);
                    end;
                    RectMove(vRect, -(vTileX*2 + 1) * vSize.CX, vSize.CY);
                  end;
                end else
                  GDIBitBlt(DC, FDstRect, vMemDC.DC, vTmpRect, False);

              finally
                FreeObj(vMemDC);
              end;
            end else
              LocDraw(DC, FDstRect);
          end;

          FHiQual := False;
        end;

        if (FImage.FSelfdraw or not optTileMode) and not RectContainsRect(FDstRect, vClientRect) then begin
          { Заливаем фон, исключая картинку, чтобы не мигала }
          vSaveDC := SaveDC(DC);
          try
            with FDstRect do
              ExcludeClipRect(DC, Left, Top, Right, Bottom);
            FillRect(DC, vClientRect, FBrush);
          finally
            RestoreDC(DC, vSaveDC);
          end;
        end;

      end else
        FillRect(DC, vClientRect, FBrush);

      if FTempMsg <> '' then
        DrawTempText(DC, FTempMsg);

    except
      on E :Exception do begin
        FillRect(DC, vClientRect, FBrush);
        DrawTempText(DC, E.Message);
      end;
    end;
  end;


  procedure TReviewWindow.DrawTempText(DC :HDC; const AStr :TString);
  var
    X, Y :Integer;
    vSize :TSize;
    vRect :TRect;
    vFont, vOldFont :HFont;
  begin
    vFont := GetStockObject(DEFAULT_GUI_FONT);
    vOldFont := SelectObject(DC, vFont);
    if vOldFont = 0 then
      Exit;
    try
      GetTextExtentPoint32(DC, PTChar(AStr), Length(AStr), vSize);
      with GetClientRect do begin
        X := Left; //Right - vSize.CX;
        Y := Bottom - vSize.CY;
        vRect := Bounds(X, Y, vSize.CX, vSize.CY);
      end;

      FillRect(DC, vRect, FMsgBrush);
      SetTextColor(DC, RGB(0, 0, 0));
      TextOut(DC, X, Y, PTChar(AStr), Length(AStr));

    finally
      SelectObject(DC, vOldFont);
    end;
  end;


  procedure TReviewWindow.WMKeyDown(var Mess :TWMKeyDown); {message WM_KeyDown;}
  begin
    Mess.Result := 0;
  end;


  procedure TReviewWindow.WMLButtonDown(var Mess :TWMLButtonDown); {message WM_LButtonDown;}
  begin
    SetCapture(Handle);
    FMousePos := SmallPointToPoint(Mess.Pos);
    FDragged := True;
    Mess.Result := 0;
  end;


  procedure TReviewWindow.WMMouseMove(var Mess :TWMMouseMove); {message WM_MouseMove;}
  begin
    if FDragged then begin
      MoveImage(Mess.Pos.X - FMousePos.X, Mess.Pos.Y - FMousePos.Y);
      FMousePos := SmallPointToPoint(Mess.Pos);
    end;
    Mess.Result := 0;
  end;


  procedure TReviewWindow.WMLButtonUp(var Mess :TWMLButtonUp); {message WM_LButtonUp;}
  begin
    if FDragged then begin
      ReleaseCapture;
      FDragged := False;
    end;
    Mess.Result := 0;
  end;


  procedure TReviewWindow.WMLButtonDblClk(var Mess :TWMLButtonDblClk); {message WM_LButtonDblClk;}
  begin
    if (GetKeyState(VK_Control) < 0) or FImage.FMovie then begin
      if FWinMode <> wmQuickView then
        SetFullscreen( FWinMode = wmNormal )
    end else
    if FMode = smExact then
      SetScale(smAutoFit, 0, 0)
    else
      SetScale(smExact, 0, 1);
    Mess.Result := 0;
  end;


  function TReviewWindow.Idle :Boolean;
  var
    vRect :TRect;
    vArea, vCX, vCY :Integer;
  begin
    Windows.GetClientRect(hFarWindow, vRect);
    if IsWindowVisible(Handle) and not RectEmpty(vRect) and not RectEquals(vRect, FParentRect) then begin
      { Корректируем размер окна изображения, при изменении окна FAR }
      FParentRect := vRect;
      if FWinMode = wmNormal then
        SetWindowBounds(CalcWinRect)
      else
      if FWinMode = wmQuickView then
        FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateWin);
    end;

    if FWinMode = wmQuickView then begin
      vArea := FarGetMacroArea;
      if vArea <> FLastArea then begin
        { Прячем/показываем окно изображения, при изменении MacroArea (для QuickView) }
        FLastArea := vArea;
        if vArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}] then begin
          Show(SW_SHOWNA);
          FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateWin);
        end else
          Show(SW_HIDE);
      end;
    end;

    if FWinMode = wmFullscreen then
      { Делаем FullScreen окно не Topmost, если FAR теряет фокус }
      if not IsActiveConsole and (FullScreenWin <> nil) and (GetWindowLong(FullScreenWin.Handle, GWL_EXSTYLE) and WS_EX_TOPMOST <> 0) then begin
//      TraceF('Make no topmost. FullScreenWin=%x, Console=%x...', [FullScreenWin.Handle, hConsoleTopWnd]);
        Windows.SetWindowPos(FullScreenWin.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      end;

    if FDraftMode and (TickCountDiff(GetTickCount, FDraftStart) > optDraftDelay) and not ScrollKeyPressed{???} then begin
      { Перерисовываем изображение в высоком качестве, после прекращения прокуртки/масштабирования }
      FDraftMode := False;
      FHiQual := True;
      Invalidate;
    end;

    if (FClipStart <> 0) and (TickCountDiff(GetTickCount, FClipStart) > 150) then begin
//    Trace('Clipped redraw...');
      FClipStart := 0;
      FHiQual := not FDraftMode;
      RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
    end;

    if FAnimate and (TickCountDiff(GetTickCount, FPageStart) > FImage.FDelay) then begin
      { Анимация... }
      FPageStart := GetTickCount;
      SetPage( IntIf(FImage.FPage < FImage.FPages - 1, FImage.FPage + 1, 0) );
    end;

    if (FTempMsg <> '') and (TickCountDiff(GetTickCount, FMsgStart) > FMsgDelay) then begin
      { Прячем надпись... }
      FHiQual := not FDraftMode;
      FTempMsg := '';
      InvalidateMsgRect;
    end;

    if FNeedSync and (TickCountDiff(GetTickCount, FSyncStart) > FSyncDelay) and (GLockSync = 0) and not ScrollKeyPressed then begin
      { Асинхронный вызов в главном потоке (для обновления QuickView или для предварительного декодирования)... }
      FNeedSync := False;
      FarAdvControl(ACTL_SYNCHRO, FSyncCmd);
    end;

    if FImage <> nil then begin
      { Даем декодеру возможность улучшить качество изображения, если он сначала вернул эскиз }
      vCX := Round(FImage.FWidth * FScale);
      vCY := Round(FImage.FHeight * FScale);
      if FImage.FOrient in [5,6,7,8] then
        IntSwap(vCX, vCY);
      if FImage.FDecoder.Idle(FImage, vCX, vCY) then begin
        FImage.UpdateBitmap;
        FHiQual := not FDraftMode;
        Invalidate;
      end;
    end;

    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewWinThread                                                            }
 {-----------------------------------------------------------------------------}

  constructor TReviewWinThread.Create;
  begin
    inherited Create(False);
//  FWindow := THintWindow.Create;
//  FreeOnTerminate := True;
  end;


  procedure TReviewWinThread.Execute; {override;}
  var
    vMsg :TMsg;
  begin
    PeekMessage(vMsg, 0, WM_USER, WM_USER, PM_NOREMOVE); { Create message queue }

//  CoInitialize(nil);
    FWindow := TReviewWindow.Create;
    try

      while not Terminated do begin
        while PeekMessage(vMsg, 0 {FWindow.Handle}, 0, 0, PM_REMOVE) do begin
          TranslateMessage(vMsg);
          DispatchMessage(vMsg);
        end;
        if FWindow.Idle then
          Sleep(1);
      end;

      if FullScreenWin <> nil then
        FullScreenWin.HideWindow;
      FWindow.HideWindow;

    finally
      FreeObj(FWindow);
      FreeObj(FullScreenWin);
//    CoUninitialize;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewImage                                                                }
 {-----------------------------------------------------------------------------}

  constructor TReviewImage.CreateEx(const aName :TString);
  begin
    Create;
    FName := aName;
    FSelected := -1;
//  PrecacheFile;
  end;


  destructor TReviewImage.Destroy; {override;}
  begin
    if FDecoder <> nil then begin
      if FDecodeInfo <> nil then
        FDecoder.pvdPageFree(Self);
      FDecoder.pvdFileClose(Self);
    end;
    ReleaseCache;
    FreeObj(FBitmap);
    inherited Destroy;
  end;


(*
  procedure TReviewImage.PrecacheFile;
  var
    vFile :THandle;
  begin
    vFile := CreateFile(PTChar(FName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
       FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0);
    try
      FSize := FileSize(vFile);

      FCacheSize := FSize { cPreCacheLimit !!! };
      if FSize < FCacheSize then
        FCacheSize := FSize;

      FCacheBuf := MemAlloc(FCacheSize);
      FCacheSize := FileRead(vFile, FCacheBuf^, FCacheSize);

    finally
      FileClose(vFile);
    end;
  end;

  procedure TReviewImage.ReleaseCache;
  begin
    MemFree(FCacheBuf);
  end;
*)

  function TReviewImage.PrecacheFile :Boolean;
  begin
    Result := False;
    FMapFile := CreateFile(PTChar(FName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
    if FMapFile = INVALID_HANDLE_VALUE then
      Exit;

    FSize := FileSize(FMapFile);
    if FSize <= 0 then
      begin ReleaseCache; Exit; end;

    FCacheSize := cPreCacheLimit;
    if FSize < FCacheSize then
      FCacheSize := FSize;

    FMapHandle := CreateFileMapping(FMapFile, nil, PAGE_READONLY, 0, FCacheSize, nil);
    if FMapHandle = 0 then
      begin ReleaseCache; Exit; end;

    FCacheBuf := MapViewOfFile(FMapHandle, FILE_MAP_READ, 0, 0, FCacheSize);
    if FCacheBuf = nil then
      begin ReleaseCache; Exit; end;

    Result := True;
  end;


  procedure TReviewImage.ReleaseCache;
  begin
    if FCacheBuf <> nil then
      UnmapViewOfFile(FCacheBuf);
    FCacheBuf := nil;

    if FMapHandle <> 0 then
      FileClose(FMapHandle);
    FMapHandle := 0;

    if (FMapFile <> 0) and (FMapFile <> INVALID_HANDLE_VALUE) then
      FileClose(FMapFile);
    FMapFile := 0;
  end;


  function TReviewImage.TryOpenBy(ADecoder :TReviewDecoder; AForce :Boolean) :Boolean;
  var
    vStart :DWORD;
  begin
    Result := False;
    if ADecoder.Enabled and (ADecoder.SupportedFile(FName) = not AForce) and ADecoder.CanWork(True) then begin
//    TraceF('Try decoding by %s - %s...', [ADecoder.Name, FName]);
      if (FCacheBuf = nil) and ADecoder.NeedPrecache then
        if not PrecacheFile then
          Exit;

      vStart := GetTickCount;
      FOpenTime := 0;
      FContext := nil;
      if ADecoder.pvdFileOpen(Self) then begin
        FOpenTime := TickCountDiff(GetTickCount, vStart);
        FDecoder := ADecoder;
        FPage := 0;
        Result := True;
        Exit;
      end;
    end;
  end;


  function TReviewImage.TryOpen(AForce :Boolean) :Boolean;
  var
    I :Integer;
    vDecoder :TReviewDecoder;
  begin
    Result := False;
    if Review.FFavDecoder <> nil then
      if TryOpenBy( Review.FFavDecoder, False ) then
        begin Result := True; Exit; end;

    for I := 0 to Review.Decoders.Count - 1 do begin
      vDecoder := Review.Decoders[I];
      if (vDecoder <> Review.FFavDecoder) and TryOpenBy(vDecoder, False) then
        begin Result := True; Exit; end;
    end;

    if AForce then begin
      for I := 0 to Review.Decoders.Count - 1 do begin
        vDecoder := Review.Decoders[I];
        if TryOpenBy(vDecoder, True) then
          begin Result := True; Exit; end;
      end;
    end;
  end;


  procedure TReviewImage.DecodePage(ASize :TSize; ACache :Boolean);
  var
    vStart :DWORD;
  begin
    vStart := GetTickCount;
    FDecodeTime := 0;

    if FDecoder.pvdGetPageInfo(Self) then begin

      if FOrient in [5,6,7,8] then
        IntSwap(ASize.CX, ASize.CY);

      { Декодируем... }
      if FDecoder.pvdPageDecode(Self, 0{???}, ASize.CX, ASize.CY, ACache) then begin
        if not FSelfdraw then begin
          try
            { Формируем Bitmap  }
            FreeObj(FBitmap);
            if FBmpBits <> nil then
              FBitmap := TReviewBitmap.CreateEx(FBmpWidth, FBmpHeight, FBmpBPP, FBmpRowBytes, FBmpBits, FBmpPalette, FColorModel, FTranspColor)
            else
              FBitmap := TReviewBitmap.Create1(FDecoder.GetBitmapHandle(Self, FIsThumbnail), True);
            if FOrient > 1 then
              OrientBitmap(FOrient);
          finally
            FDecoder.pvdPageFree(Self);
          end;
        end;
        FDecodeTime := TickCountDiff(GetTickCount, vStart);
      end;
    end;
  end;


  procedure TReviewImage.UpdateBitmap;
  var
    vNewBitmap :HBitmap;
    vIsThumbnail :Boolean;
  begin
    if not FSelfdraw then begin
      vNewBitmap := FDecoder.GetBitmapHandle(Self, vIsThumbnail);
      if vNewBitmap <> 0 then begin
        FreeObj(FBitmap);
        FBitmap := TReviewBitmap.Create1(vNewBitmap, True);
        FIsThumbnail := vIsThumbnail;
        if FOrient > 1 then begin
          if FOrient in [5,6,7,8] then
            IntSwap(FWidth, FHeight);
          OrientBitmap(FOrient);
        end;
      end;
    end;
  end;


  procedure TReviewImage.Rotate(ARotate :Integer);
  const
    cReorient :array[0..8, 0..4] of Integer = (
     (1,6,8,2,4), //
     (1,6,8,2,4), //
     (2,7,5,1,3), // X
     (3,8,6,4,2), // LL = RR
     (4,5,7,3,1), // Y
     (5,2,4,6,8), // XR
     (6,3,1,5,7), // R
     (7,4,2,8,6), // XL
     (8,1,3,7,5)  // L
    );
    cTransform :array[0..4] of Integer =
      (0, 6, 8, 2, 4);
  begin
    if FBitmap <> nil then begin
      FOrient := cReorient[FOrient, ARotate];
      OrientBitmap(cTransform[ARotate]);
    end;
  end;


  procedure TReviewImage.OrientBitmap(AOrient :Integer);
  begin
    if FBitmap <> nil then begin
      FBitmap.Transform(AOrient);
      if AOrient in [5,6,7,8] then
        IntSwap(FWidth, FHeight);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCacheList                                                                  }
 {-----------------------------------------------------------------------------}

  type
    TCacheList = class(TObjList)
    protected
      procedure ItemFree(PItem :Pointer); override;
    end;


  procedure TCacheList.ItemFree(PItem :Pointer); {override;}
  begin
    FreeImage(TReviewImage(PItem^));
  end;


 {-----------------------------------------------------------------------------}
 { TReviewManager                                                              }
 {-----------------------------------------------------------------------------}

  constructor TReviewManager.Create; {override;}
  begin
    inherited Create;
    FDecoders := TObjList.Create;
    FCache := TCacheList.Create;
  end;


  destructor TReviewManager.Destroy; {override;}
  begin
    CloseWindow;
    FreeObj(FCache);
    FreeObj(FDecoders);
    FreeObj(FBackBmp);
    inherited Destroy;
  end;


  procedure TReviewManager.InitSubplugins;
  var
    vPath :TString;
  begin
    vPath := AddFileName(ExtractFilePath(FARAPI.ModuleName), cDefPVDFolder);
    InitDecodersFrom(FDecoders, vPath);
  end;


  procedure TReviewManager.LoadBackground;
  var
    vFileName :TString;
    vBMP :HBitmap;
  begin
    if FBackBmp <> nil then
      Exit;

    vFileName := AddFileName(ExtractFilePath(FARAPI.ModuleName), cBackgroundFile);
    if not WinFileExists(vFileName) then
      Exit;

    vBMP := LoadImage(0, PTChar(vFileName), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE or LR_DEFAULTSIZE);
    if vBMP <> 0 then 
      FBackBmp := TReviewBitmap.Create1(vBmp, True);
  end;


  function TReviewManager.CanShowImage(const AFileName :TString) :Boolean;
  var
    I :Integer;
    vDecoder :TReviewDecoder;
  begin
    Result := False;
    for I := 0 to Review.Decoders.Count - 1 do begin
      vDecoder := Review.Decoders[I];
      if vDecoder.Enabled and vDecoder.SupportedFile(AFileName) and vDecoder.CanWork(False)  then begin
        Result := True;
        Exit;
      end;
    end;
  end;


  function TReviewManager.ShowImage(const AFileName :TString; AMode :Integer; AForce :Boolean = False) :Boolean;

    function LocGetCurrent(aPanel :THandle) :TString;
    begin
      Result := AddFileName(FarPanelGetCurrentDirectory(aPanel), FarPanelItemName(aPanel, FCTL_GETCURRENTPANELITEM, 0));
    end;

  var
    vName :TString;
    vImage :TReviewImage;
  begin
    Result := False;
    inc(GLockSync);
    try
      UpdateConsoleWnd;
//    hConsoleTopWnd := GetTopParent(hFarWindow);
      hConsoleTopWnd := GetAncestor(hFarWindow, GA_ROOT);
//    TraceF('FarWnd=%x, ConsoleWnd=%x', [hFarWindow, hConsoleTopWnd]);

      vName := AFileName;
      if vName = '' then
        vName := LocGetCurrent(PANEL_ACTIVE);

      vImage := FindInCache(vName);
      if vImage = nil then begin
        if not WinFileExists(vName) then
          Exit;

        if ModalDlg <> nil then
          ModalDlg.SetTitle(ExtractFileName(vName) + ' - decoding...');

        vImage := TReviewImage.CreateEx(vName);
        vImage._AddRef;
        try
          if vImage.TryOpen(AForce) then begin
            FCommand := GoCmdNone;
            vImage.DecodePage(CalcWinSize(AMode), {Cache=}False);
            DisplayImage(vImage, AMode);
            CacheImage(vImage);
            Result := True;
          end;
        finally
          vImage._Release;
        end;
      end else
      begin
        if vImage <> FCache.First then
          { Изменилось направление просмотра }
          if CurImage <> nil then
            CacheImage(CurImage);

        FCommand := GoCmdNone;
        vImage.UpdateBitmap;
        DisplayImage(vImage, AMode);
        CacheImage(vImage);
        Result := True;
      end;

    finally
      Dec(GLockSync);
    end;
  end;


  procedure TReviewManager.DisplayImage(aImage :TReviewImage; AMode :Integer);
  var
    vRec :TSetImageRec;
  begin
    if ScreenBitPerPixel < 16 then
      AppError('Unsupported video mode');

    CreateWinThread;

//  TraceF('SetItemToWindow. ACallMode=%d', [Byte(ACallMode)]);
    FillZero(vRec, SizeOf(vRec));
    vRec.Image := aImage;
    vRec.WinMode := AMode;
    vRec.WinRect := CalcWinRectAs(AMode);
    SendMessage(FWindow.Handle, CM_SetImage, 0, LPARAM(@vRec));
  end;


  procedure TReviewManager.Redecode(AMode :TRedecodeMode = rmSame; aShowInfo :Boolean = True);

    function LocNext(AIndex :Integer) :Integer;
    begin
      if AMode = rmNext then
        Result := IntIf(AIndex < FDecoders.Count - 1, AIndex + 1, 0)
      else
        Result := IntIf(AIndex > 0, AIndex - 1, FDecoders.Count - 1);
    end;

  var
    vImage :TReviewImage;
    vIndex, vNewIndex :Integer;
  begin
    if CurImage = nil then
      Exit;

    ClearCache;
    if AMode in [rmNext, rmPrev] then begin

      if ModalDlg <> nil then
        ModalDlg.SetTitle(ExtractFileName(CurImage.FName) + ' - decoding...');

      vImage := TReviewImage.CreateEx(CurImage.FName);
      vImage._AddRef;
      try
        vIndex := FDecoders.IndexOf(CurImage.FDecoder);
        vNewIndex := LocNext(vIndex);
        while vNewIndex <> vIndex do begin
          if vImage.TryOpenBy( FDecoders[vNewIndex], False ) then begin
            vImage.DecodePage(CalcWinSize, {Cache=}False);
            DisplayImage(vImage, -1);
            CacheImage(vImage);
            FFavDecoder := CurImage.FDecoder;
            Break;
          end;
          vNewIndex := LocNext(vNewIndex);
        end;
      finally
        vImage._Release;
      end;

    end else
    begin
      if AMode = rmBest then
        FFavDecoder := nil;
      ShowImage(CurImage.FName, -1);
    end;

    if aShowInfo then
      ShowDecoderInfo;
    FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
  end;


  procedure TReviewManager.ShowDecoderInfo;
  begin
    with CurImage do
      SetTempMsg(Format('Decoder: %s (%d+%d=%d ms)', [FDecoder.Title, FOpenTime, FDecodeTime, FOpenTime + FDecodeTime]));
  end;



  procedure TReviewManager.SetTempMsg(const AMsg :TString);
  begin
    if FWindow <> nil then
      SendMessage(FWindow.Handle, CM_TempMsg, 0, TIntPtr(AMsg));
  end;


  {SyncCmdUpdateWin}
  procedure TReviewManager.UpdateWindowPos;
  var
    vRec :TSetImageRec;
    vWinInfo :TWindowInfo;
  begin
    if IsQViewMode then begin
      FillZero(vRec, SizeOf(vRec));
      vRec.WinRect := CalcWinRectAs(1);
      SendMessage(FWindow.Handle, CM_SetWinPos, 0, LPARAM(@vRec));
    end else
    if (FWindow <> nil) and (ModalDlg <> nil) then begin
      if FarGetWindowInfo(-1, vWinInfo) then begin
        if (vWinInfo.WindowType = WTYPE_DIALOG) and (THandle(vWinInfo.ID) = ModalDlg.Handle) then begin
          SendMessage(FWindow.Handle, CM_SetVisible, 1, 0);
          ModalDlg.FHidden := False;
        end else
        begin
          SendMessage(FWindow.Handle, CM_SetVisible, 0, 0);
          ModalDlg.FHidden := True;
        end;
      end;
    end;
  end;


  function TReviewManager.CalcWinRectAs(AMode :Integer) :TRect;

    function GetQuickViewRect :TRect;
    var
      vInfo :TPanelInfo;
    begin
      FarGetPanelInfo(False, vInfo);
      if IsVisiblePanel(vInfo) then begin
        Result := vInfo.PanelRect;

        with FarGetWindowRect do
          RectMove(Result, Left, Top);

        if optQViewShowFrame  then begin
          Inc(Result.Top);
          Inc(Result.Left);
          Dec(Result.Bottom, 2);
        end else
        begin
          Inc(Result.Right);
          Inc(Result.Bottom);
        end;
      end else
        Result := Rect(0,0,0,0);
    end;

  begin
    if AMode = 0 then
      Result := GetNormalWinRect(optFullscreen)
    else begin
      with GetQuickViewRect do begin
        Result.TopLeft := ConsolePosToClientPoint(Left, Top);
        Result.BottomRight := ConsolePosToClientPoint(Right, Bottom);
      end;
    end;
  end;


  function TReviewManager.CalcWinSize(AMode :Integer = -1) :TSize;
    { Прогнозируем размер... }
  var
    vScaleMode :TScaleMode;
  begin
    vScaleMode := smAutoFit;
    if FWindow <> nil then
      vScaleMode := FWindow.ScaleMode;
    if (vScaleMode <> smAutoFit) and optKeepScale then
      Result := Size(0, 0)
    else begin
      if AMode = -1 then
        AMode := IntIf(IsQViewMode, 1, 0);
      with CalcWinRectAs(AMode) do
        Result := Size(Right - Left, Bottom - Top);
    end;
  end;


  procedure TReviewManager.SyncWindow;
  var
    vShow :Boolean;
    vInfo :TPanelInfo;
    vName :TString;
  begin
    if IsQViewMode then begin
//    Trace('SyncWindow...');

      vShow := False;
      if (FarGetMacroArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}]) and (FarGetWindowType = WTYPE_PANELS) then
        if FarGetPanelInfo(False, vInfo) and IsVisiblePanel(vInfo) and (vInfo.PanelType = PTYPE_QVIEWPANEL) then
          if FarGetPanelInfo(True, vInfo) and IsVisiblePanel(vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) and (PFLAGS_REALNAMES and vInfo.Flags <> 0) then
            vShow := True;

      if vShow then begin

        vName := '';
        if ShowImage(vName, 1) then
          {}
        else
          CloseWindow;

      end else
        CloseWindow;
    end;
  end;


  procedure TReviewManager.SyncDelayed(aCmd, aDelay :Integer);
  begin
    if FWindow <> nil then begin
//    Trace('SyncWindowDelayed...');
      SendMessage(FWindow.Handle, CM_Sync, aCmd, aDelay);
    end;
  end;


  procedure TReviewManager.CreateWinThread;
  begin
    if FWinThread = nil then begin
      LoadBackground;
      FWinThread := TReviewWinThread.Create;
      while FWinThread.Window = nil do
        Sleep(0);
      FWindow := FWinThread.Window;
    end;
  end;


  procedure TReviewManager.CloseWindow;
  begin
    if FWinThread <> nil then begin

      FWinThread.Terminate;

      FWinThread.WaitFor;
      FreeObj(FWinThread);

      FWindow := nil;

      ClearCache;
    end;
  end;


  function TReviewManager.GetWindowTitle :TString;
  const
    vDelim = $2022;
    cOrients :array[0..8] of TString =
      ('0', '1', 'H', '180'#176, 'V', 'H-90'#176, '90'#176, 'H+90'#176, '-90'#176);

    function LengthToStr(ASec :Integer) :TString;
    var
      H, M, S :Integer;
    begin
      M := ASec div 60;
      S := ASec mod 60;
      H := M div 60;
      M := M mod 60;
      if H > 0 then
        Result := IntToStr(H) + ' hour ' + IntToStr(M) + ' min'
      else
      if M > 0 then
        Result := IntToStr(M) + ' min ' + IntToStr(S) + ' sec'
      else
        Result := IntToStr(S) + ' sec'
    end;


    function LocCheckSelected(const aName :TString) :Boolean;
    var
      vItem :PPluginPanelItem;
      vName :TString;
    begin
      Result := False;
      vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0);
      if vItem <> nil then begin
        try
          vName := AddFileName(FarPanelGetCurrentDirectory(PANEL_ACTIVE), vItem.FileName);
          if StrEqual(aName, vName) then
            Result := PPIF_SELECTED and vItem.Flags <> 0;
        finally
          MemFree(vItem);
        end;
      end;
    end;

  var
    vFmt :TString;
    vScale :Integer;
  begin
    Result := '';
    if CurImage <> nil then
      with CurImage do begin
        vFmt := Format('%d x %d', [FWidth, FHeight]);
        if FBPP <> 0 then
          vFmt := vFmt + Format(', %d bit', [FBPP]);

        if FPages > 1 then
          if FWindow.FAnimate then
            vFmt := vFmt + Format(', %d frames', [FPages])
          else
            vFmt := vFmt + Format(', %d/%d', [FPage + 1, FPages]);

        if FMovie then
          vFmt := vFmt + ', ' + LengthToStr(FLength div 1000);

//      Result := Format('%s - %s (%s)', [ExtractFileName(FName), FDecoder.pvdName, vFmt]);
        Result := Format('%s ' + TChar(vDelim) + ' %s', [ExtractFileName(FName), vFmt]);

        if FSelected = -1 then
          FSelected := IntIf(LocCheckSelected(FName), 1, 0);
        if FSelected = 1 then
          Result := '*' + Result;

        if (FOrient > 1) and (FOrient <= 8) then
          Result := Result + ', ' + cOrients[FOrient];

        vScale := Round(100 * FWindow.FScale);
        if (vScale <> 100) and not FMovie then
          Result := Result + ' ' + TChar(vDelim) + ' ' + Int2Str(vScale) + '%';
      end;
  end;


  function TReviewManager.GetImage :TReviewImage;
  begin
    Result := nil;
    if FWindow <> nil then
      Result := FWindow.FImage;
  end;


  function TReviewManager.IsQViewMode :Boolean;
  begin
    Result := (FWindow <> nil) and (FWindow.FWinMode = wmQuickView);
  end;


 {-----------------------------------------------------------------------------}

  procedure TReviewManager.CacheNeighbor(ANext :Boolean);
  var
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
    vImage :TReviewImage;
    vIndex :Integer;
    vPath, vFileName :TString;
  begin
    if (FWindow <> nil) and FarGetPanelInfo(True, vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) and (PFLAGS_REALNAMES and vInfo.Flags <> 0) then begin
//    TraceF('CacheNeighbor: %d', [Byte(ANext)]);
      vPath := FarPanelGetCurrentDirectory(PANEL_ACTIVE);
      vIndex := vInfo.CurrentItem;

      while True do begin

        if ANext then begin
          if vIndex = vInfo.ItemsNumber - 1 then
            Break;
          Inc(vIndex);
        end else
        begin
          if vIndex = 0 then
            Break;
          Dec(vIndex);
        end;

        vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
        if vItem <> nil then begin
          try
            if vItem.FileAttributes and faDirectory = 0 then begin

              vFileName := AddFileName(vPath, vItem.FileName);
              vImage := FindInCache(vFileName);
              if vImage <> nil then begin
                CacheImage(vImage);
                Break;
              end;

              vImage := TReviewImage.CreateEx(vFileName);
              vImage._AddRef;
              try
                if vImage.TryOpen(False) then begin
                  vImage.DecodePage(CalcWinSize, {Cache=}True);
                  CacheImage(vImage);
                  Break;
                end;
              finally
                vImage._Release;
              end;

            end;
          finally
            MemFree(vItem);
          end;
        end;

      end;
    end;
  end;


  procedure TReviewManager.CacheImage(aImage :TReviewImage);
  var
    vIndex :Integer;
  begin
    vIndex := FCache.IndexOf(aImage);
    if vIndex <> -1 then
      FCache.Move(vIndex, 0)
    else begin
      FCache.Insert(0, aImage);
      aImage._AddRef;
      if FCache.Count > optCacheLimit then
        FCache.DeleteRange(optCacheLimit, FCache.Count - optCacheLimit);
    end;
  end;


  function TReviewManager.FindInCache(const aFileName :TString) :TReviewImage;
  var
    I :Integer;
  begin
    for I := 0 to FCache.Count - 1 do begin
      Result := FCache[I];
      if StrEqual(Result.FName, aFileName) then
        Exit;
    end;
    Result := nil;
  end;


  procedure TReviewManager.ClearCache;
  begin
    FCache.FreeAll;
  end;


 {-----------------------------------------------------------------------------}

  procedure TReviewManager.Navigate(AOrig :Integer; AForward :Boolean);
  var
    vInfo :TPanelInfo;
    vIndex :Integer;
    vItem :PPluginPanelItem;
    vRedrawInfo :TPanelRedrawInfo;
    vPath, vFileName :TString;
  begin
    if FarGetPanelInfo(True, vInfo) then begin
      vPath := FarPanelGetCurrentDirectory(PANEL_ACTIVE);

      if AOrig = 0 then
        vIndex := vInfo.CurrentItem
      else
      if AOrig = 1 then begin
        vIndex := -1;
        AForward := True;
      end else
      begin
        vIndex := vInfo.ItemsNumber;
        AForward := False;
      end;

      while True do begin

        if AForward then begin
          if vIndex = vInfo.ItemsNumber - 1 then
            Break;
          Inc(vIndex);
        end else
        begin
          if vIndex = 0 then
            Break;
          Dec(vIndex);
        end;

        if (AOrig <> 0) and (vIndex = vInfo.CurrentItem) then
          Break;

        vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
        if vItem <> nil then begin
          try
            if vItem.FileAttributes and faDirectory = 0 then begin

              if PFLAGS_REALNAMES and vInfo.Flags = 0 then begin
                { Плагинная панель с "виртуальными" файлами, навигируемся через макросы... }
                vFileName := vItem.FileName;
                if CanShowImage(vFileName) then begin
                  FCommand := IntIf(AForward, GoCmdNext, GoCmdPrev);
                  FCmdFile := vFileName;
                  if ModalDlg <> nil then
                    ModalDlg.Close;
                  Exit;
                end;
              end else
              begin
                vFileName := AddFileName(vPath, vItem.FileName);
                if ShowImage(vFileName, 0) then begin
                  if optPrecache then
                    SyncDelayed(IntIf(AForward, SyncCmdCacheNext, SyncCmdCachePrev), optCacheDelay);
                 {$ifdef Far3}
                  vRedrawInfo.StructSize := SizeOf(vRedrawInfo);
                 {$endif Far3}
                  vRedrawInfo.TopPanelItem := vInfo.TopPanelItem;
                  vRedrawInfo.CurrentItem := vIndex;
                  FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, @vRedrawInfo);
                  Exit;
                end;
              end;

            end;
          finally
            MemFree(vItem);
          end;
        end;

      end;
    end;
    Beep;
  end;


  procedure TReviewManager.SetScale(aSetMode :TScaleSetMode; aScaleMode :TScaleMode; AValue :TFloat);
  begin
    if FWinThread <> nil then
      if aSetMode = smSetMode then
        SendMessage(FWindow.Handle, CM_Scale, Byte(aSetMode), byte(aScaleMode))
      else
        SendMessage(FWindow.Handle, CM_Scale, Byte(aSetMode), TIntPtr(@AValue));
  end;


  procedure TReviewManager.SetImagePage(aPage :Integer);
  begin
    if FWindow <> nil then
      SendMessage(FWindow.Handle, CM_Transform, 0, aPage);
  end;


  procedure TReviewManager.Rotate(ARotate :Integer);
  begin
    if FWindow <> nil then begin
      SetTempMsg(GetMsg(strRotate));
      SendMessage(FWindow.Handle, CM_Transform, 1, ARotate);
    end;
  end;


  procedure TReviewManager.Orient(AOrient :Integer);
  begin
    if FWindow <> nil then begin
      SetTempMsg(GetMsg(strRotate));
      SendMessage(FWindow.Handle, CM_Transform, 2, AOrient);
    end;
  end;


  function TReviewManager.Save(const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :boolean;
  var
    vImage :TReviewImage;
  begin
    Result := False;
    if CurImage = nil then
      Exit;
    try
      SetTempMsg(GetMsg(strSave));
      vImage := CurImage;
      Result := vImage.Decoder.Save(vImage, ANewName, AFmtName, aOrient, aQuality, aOptions);
      if Result then begin
        ClearCache;
        ShowImage(ANewName, -1);
      end;
    except
      on E :Exception do begin
        Beep;
        SetTempMsg(E.Message);
      end;
    end;
  end;


  procedure TReviewManager.SetFullscreen(aOn :Boolean);
  begin
    if FWindow <> nil then
      SendMessage(FWindow.Handle, CM_SetMode, IntIf(aOn, 1, 0), 0);
  end;


  procedure TReviewManager.ChangeVolume(aDeltaVolume, aVolume :Integer);
  begin
    if CurImage.Decoder is TReviewDllDecoder2 then
      with TReviewDllDecoder2(CurImage.Decoder) do begin
        if aDeltaVolume <> 0 then begin
          aVolume := pvdPlayControl(CurImage, PVD_PC_GetVolume, 0);
          Inc(aVolume, aDeltaVolume);
        end;
        pvdPlayControl(CurImage, PVD_PC_SetVolume, aVolume);
      end;
  end;


  function TReviewManager.ProcessKey(AKey :Integer) :Boolean;

    procedure LocGotoPage(ADelta :Integer);
    var
      vPage :Integer;
    begin
      vPage := FWindow.FImage.FPage + ADelta;
      if (vPage >= 0) and (vPage < FWindow.FImage.FPages) then
        SetImagePage(vPage)
      else
        Beep;
    end;

    procedure LocMove(ADX, ADY :Integer);
    var
      vRec :TPoint;
    begin
      vRec.x := ADX;
      vRec.Y := ADY;
      SendMessage(FWindow.Handle, CM_Move, 0, LPARAM(@vRec));
    end;

    procedure LocShowInfo;
    begin
      FShowInfo := not FShowInfo;
      ShowDecoderInfo;
    end;

    procedure LocSwitchBack;
    begin
      optTranspBack := not optTranspBack;
      if FWindow <> nil then begin
        FWIndow.FHiQual := True;
        FWindow.Invalidate;
      end;
    end;

    procedure LocSwitchTile;
    begin
      optTileMode := not optTileMode;
      if FWindow <> nil then begin
        FWIndow.FHiQual := True;
        FWindow.Invalidate;
      end;
    end;

    procedure LocSelectCurrent;
    var
      vInfo :TPanelInfo;
      vItem :PPluginPanelItem;
      vName :TString;
      vIndex :Integer;
    begin
      if FarGetPanelInfo(True, vInfo) then begin
        vIndex := vInfo.CurrentItem;
        vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
        if vItem <> nil then begin
          try
            vName := AddFileName(FarPanelGetCurrentDirectory(PANEL_ACTIVE), vItem.FileName);
            if StrEqual(CurImage.FName, vName) then begin

              if PPIF_SELECTED and vItem.Flags <> 0 then
                FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, vIndex, nil )
              else
                FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, vIndex, Pointer(PPIF_SELECTED) );

              CurImage.FSelected := -1;
              FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);

            end else
              Beep;
          finally
            MemFree(vItem);
          end;
        end;
      end;
    end;


    procedure LocGotoPos(aDeltaSec, aPosMS :Integer);
    begin
      if CurImage.Decoder is TReviewDllDecoder2 then
        with TReviewDllDecoder2(CurImage.Decoder) do begin
          if aDeltaSec <> 0 then begin
            aPosMS := pvdPlayControl(CurImage, PVD_PC_GetPos, 0);
            Dec(aPosMS, ADeltaSec * 1000);
          end;
          pvdPlayControl(CurImage, PVD_PC_SetPos, aPosMS);
        end;
    end;


    procedure LocPlayPause;
    var
      vState :Integer;
    begin
      if CurImage.Decoder is TReviewDllDecoder2 then
        with TReviewDllDecoder2(CurImage.Decoder) do begin
          vState := pvdPlayControl(CurImage, PVD_PC_GetState, 0);
          if vState = 1 then
            pvdPlayControl(CurImage, PVD_PC_Pause, 0)
          else
            pvdPlayControl(CurImage, PVD_PC_Play, 0)
        end;
    end;


    function LocStep(aStep :Integer) :Integer;
    begin
      if Key_Shift and AKey = 0 then
        Result := aStep
      else
        Result := IntIf(aStep > 0, 1, -1);
    end;


    procedure LocSaveAs;
    var
      vImage :TReviewImage;
      vFileName, vFmtName :TString;
      vOrient, vQuality :Integer;
      vOptions :TSaveOptions;
    begin
      vImage := CurImage;
      vFileName := vImage.FName;
      vFmtName := vImage.FFormat;
      vOrient := vImage.FOrient;
      vQuality := 0;
      vOptions := [soTransformation];
      SyncDelayed(SyncCmdUpdateWin, 100);
      if SaveAsDlg(vFileName, vFmtName, vOrient, vQuality, vOptions) then begin
        UpdateWindowPos;
        Save(vFileName, vFmtName, vOrient, vQuality, vOptions);
      end;
    end;


  begin
    Result := False;
    if FWinThread <> nil then begin
      case AKey of
        { Смещение }
        Key_Left, Key_ShiftLeft:
          if not CurImage.FMovie then
            LocMove(LocStep(+cMoveStep),  0)
          else
            LocGotoPos(LocStep(+cMoveStepSec), 0);

        Key_Right, Key_ShiftRight:
          if not CurImage.FMovie then
            LocMove(LocStep(-cMoveStep),  0)
          else
            LocGotoPos(LocStep(-cMoveStepSec), 0);

        Key_Up, Key_ShiftUp:
          if not CurImage.FMovie then
            LocMove( 0, LocStep(+cMoveStep))
          else
            ChangeVolume(LocStep(+10), 0);

        Key_Down, Key_ShiftDown:
          if not CurImage.FMovie then
            LocMove( 0, LocStep(-cMoveStep))
          else
            ChangeVolume(LocStep(-10), 0);

        Key_CtrlLeft  :
          if not CurImage.FMovie then
            LocMove(+MaxInt,  0)
          else
            LocGotoPos(0, 0);

        Key_CtrlRight :
          if not CurImage.FMovie then
            LocMove(-MaxInt,  0)
          else
            LocGotoPos(0, MaxInt);

        Key_CtrlUp    :
          if not CurImage.FMovie then
            LocMove( 0, +MaxInt)
          else
            ChangeVolume(0, 100);

        Key_CtrlDown  :
          if not CurImage.FMovie then
            LocMove( 0, -MaxInt)
          else
            ChangeVolume(0, 0);

        { Переключение изображений }
        Key_Home, Key_ShiftHome : Navigate(1, True);
        Key_End, Key_ShiftEnd   : Navigate(2, False);
        Key_PgUp, Key_ShiftPgUp : Navigate(0, False);
        Key_PgDn, Key_ShiftPgDn : Navigate(0, True);

        { Переключение страниц }
        Key_CtrlHome  : SetImagePage(0);
        Key_CtrlEnd   : SetImagePage(MaxInt);
        Key_CtrlPgDn  : LocGotoPage(+1);
        Key_CtrlPgUp  : LocGotoPage(-1);

        { Переключение декодеров }
        Key_AltHome  : Redecode(rmBest);
        Key_AltPgDn  : Redecode(rmNext);
        Key_AltPgUp  : Redecode(rmPrev);

        { Масштабирование }
        KEY_MULTIPLY      :
          if FWindow.ScaleMode = smExact then
            SetScale( smSetMode, smAutoFit, 0  )
          else
            SetScale( smSetScale, smExact, 1  );
        KEY_Add           : SetScale( smDeltaScale, smExact, +5 {Change scale} );
        KEY_Subtract      : SetScale( smDeltaScale, smExact, -5 {Change scale} );
        KEY_ShiftAdd      : SetScale( smDeltaScale, smExact, +1 {Change scale} );
        KEY_ShiftSubtract : SetScale( smDeltaScale, smExact, -1 {Change scale} );

        KEY_CtrlR, Byte('r') : Redecode;
        KEY_CtrlI, Byte('i') : LocShowInfo;
        KEY_CtrlB, Byte('b') : LocSwitchBack;
        KEY_CtrlT, Byte('t') : LocSwitchTile;

        KEY_CtrlF, Byte('f') :
          SetFullscreen(FWindow.FWinMode = wmNormal);

        Byte('.')           : Rotate(1); { > - Поворот по часовой }
        Byte(',')           : Rotate(2); { < - Поворот против часовой }
        Key_Alt + Byte('.') : Rotate(3); { Alt> - X-Flip }
        Key_Alt + Byte(',') : Rotate(4); { Alt< - Y-Flip }

        Key_Ins     : LocSelectCurrent;

        Key_F2      : Save('', '', 0, 0, [soTransformation]);
        Key_CtrlF2  : Save('', '', 0, 0, [soTransformation, soEnableLossy]);
        Key_AltF2   : Save('', '', 0, 0, [soExifRotation]);
        Key_ShiftF2 : LocSaveAs;

        Key_Space   : LocPlayPause;

      else
        Exit;
      end;
      Result := True;
    end;
  end;


  function TReviewManager.ProcessWheel(ADelta :Integer) :Boolean;
  begin
    Result := False;
    if FWinThread <> nil then begin
//    TraceF('ProcessWheel: %d', [ADelta]);
      if GetKeyState(VK_Control) < 0 then
        Navigate(0, ADelta < 0)
      else
      if CurImage.FMovie then begin
        ChangeVolume(ADelta * 5, 0)
      end else
      begin
        if not (GetKeyState(VK_Shift) < 0) then
          ADelta := ADelta * 5;
        SetScale( smDeltaScaleMouse, smExact, ADelta );
      end;
      Result := True;
    end;
  end;


  function TReviewManager.ProcessCommand :Boolean;
  var
    vInfo :TPanelInfo;
  begin
    Result := False;
    if FCommand = GoCmdNone then
      Exit;

    if FarGetPanelInfo(True, vInfo) then begin

      FarPostMacro(
        'Keys("Esc") ' +
        'Panel.SetPos(0, ' + FarStrToMacro(FCmdFile) + ') ' + 
        'Keys("F3")',
        0
      );

    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TReviewManager.PluginSetup;
  var
    vMenu :TFarMenu;
    vDecodersStr :TString;
  begin
    vDecodersStr := Format(GetMsg(strMDecoders), [Review.Decoders.Count]);

    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMOptions),
      PTChar(vDecodersStr),
      GetMsg(strMColors)
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : ReviewConfig;
        1 : DecodersConfig(Review);
        2 : ColorMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


end.


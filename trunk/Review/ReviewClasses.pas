{$I Defines.inc}

{$Define bSetClip}

unit ReviewClasses;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MultiMon,
    Messages,
    MixTypes,
    MixUtils,
    MixFormat,
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
    GDIPAPI,
    GDIImageUtil,
    ReviewConst,
    ReviewDecoders,
    ReviewGDIPlus;

  const
    CM_SetImage     = $B000;
    CM_Transform    = $B001;
    CM_SetWinPos    = $B002;
    CM_SetVisible   = $B003;
    CM_SetMode      = $B004;
    CM_Move         = $B005;
    CM_Scale        = $B006;
    CM_Sync         = $B007;
    CM_TempMsg      = $B008;
    CM_SlideShow    = $B009;
    CM_ReleaseImage = $B00A;

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
      Direct  :Integer;
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
      procedure CMReleaseImage(var Mess :TMessage); message CM_ReleaseImage;
      procedure CMTransform(var Mess :TMessage); message CM_Transform;
      procedure CMSetWinPos(var Mess :TMessage); message CM_SetWinPos;
      procedure CMSetVisible(var Mess :TMessage); message CM_SetVisible;
      procedure CMSetMode(var Mess :TMessage); message CM_SetMode;
      procedure CMMove(var Mess :TMessage); message CM_Move;
      procedure CMScale(var Mess :TMessage); message CM_Scale;
      procedure CMSync(var Mess :TMessage); message CM_Sync;
      procedure CMSlideShow(var Mess :TMessage); message CM_SlideShow;
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

      FSlideStart   :DWORD;
      FSlideDelay   :Integer;

      procedure CreateBrushes;
      function CalcWinRect :TRect;
      procedure RecalcRects;
      function GetMousePos :TPoint;
      procedure MoveImage(DX, DY :Integer);
      procedure SetFullscreen(AOn :Boolean);
      procedure SetWinMode(AMode :TWinMode);
      procedure SetScale(aMode :TScaleMode; aLnScale, aScale :TFloat);
      procedure SetPage(aPage :Integer);
      procedure SetTempMsg(const AMsg :TString; aInvalidate :Boolean = True);
      procedure InvalidateMsgRect;
      procedure PaintWindow(DC :HDC);
      procedure SlideEffect(aOldImage :TReviewImage; const AOldSrcRect, AOldDstRect :TRect; ADirect :Integer);
      procedure DrawImage(DC :HDC; aImage :TReviewImage; const ASrcRect, ADstRect :TRect; ABuffered :Boolean);
      procedure DrawTempText(DC :HDC; const AStr :TString);
      procedure DrawAddInfo(DC :HDC);

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
      property SlideDelay :Integer read FSlideDelay;
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


    TReviewTags = record
      Time         :TString;
      Description  :TString;
      EquipMake    :TString;
      EquipModel   :TString;
      Software     :TString;
      Author       :TString;
      Copyright    :TString;

      ExposureTime :Int64;
      FNumber      :Int64;
      FocalLength  :Int64;
      ISO          :Integer;
      Flash        :Integer;
      XResolution  :Integer;
      YResolution  :Integer;

//    Title        :TString;
//    Artist       :TString;
//    Album        :TString;
//    Year         :TString;
//    Genre        :TString;
    end;


    TReviewImage = class(TReviewImageRec)
    public
      constructor CreateEx(const aName :TString);
      destructor Destroy; override;

      function TryOpenBy(ADecoder :TReviewDecoder; AForce :Boolean) :Boolean;
      function TryOpen(AForce :Boolean) :Boolean;
      procedure DecodePage(ASize :TSize; AFastScroll :Boolean = False);
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

      FTags        :TReviewTags;
      FInfoInited  :Boolean;

      procedure CollectInfo;
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
      function ShowImage(const AFileName :TString; AMode :Integer; AForce :Boolean = False; ADirect :Integer = 0) :Boolean;
      procedure DisplayImage(aImage :TReviewImage; AMode :Integer; ADirect :Integer = 0);
      procedure InvalidateImage;
      procedure SetImagePage(aPage :Integer);
      function Navigate(AOrig :Integer; AForward :Boolean; ASlideShow :Boolean = False) :Boolean;
      function NavigateTo(const AFileName :TString{; AForward :Boolean; ASlideShow :Boolean = False}) :Boolean;
      procedure Redecode(AMode :TRedecodeMode = rmSame; aShowInfo :Boolean = True);
      procedure Rotate(ARotate :Integer);
      procedure Orient(AOrient :Integer);
      function Save(const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;
      procedure SetFullscreen(aOn :Boolean);
      procedure SlideShow(AMode :Integer; aShowInfo :Boolean = True);
      procedure SlideShowQueryDelay;
      procedure GoNextSlide;
      procedure ChangeVolume(aDeltaVolume, aVolume :Integer);
      procedure SetTempMsg(const AMsg :TString; aInvalidate :Boolean = True);
      procedure UpdateWindowPos;
      procedure SyncDelayed(aCmd, aDelay :Integer);
      procedure SyncWindow;
      procedure CacheNeighbor(ANext :Boolean);
      function IsQViewMode :Boolean;
      procedure CloseWindow;
      procedure CloseWindowDelayed(ADelay :Integer);
      function GetWindowTitle :TString;

      function ProcessKey(AKey :Integer) :Boolean;
      function ProcessWheel(ADelta :Integer) :Boolean;
      function ProcessCommand :Boolean;
      procedure PluginSetup;

      procedure SetScale(aSetMode :TScaleSetMode; aScaleMode :TScaleMode; AValue :TFloat);

      procedure SetForceFile(const aName :TString; aMode :Integer);

    private
      FDecoders   :TObjList;           { Список декодеров }
      FWinThread  :TReviewWinThread;
      FWindow     :TReviewWindow;
      FCommand    :Integer;            { Для навигации по плагинным панелям }
      FCmdFile    :TString;            { -/-/- }
      FCache      :TObjList;           { Закэшированные изображения }
      FFavDecoder :TReviewDecoder;     { Предпочитаемый декодер }

      FBackBmp    :TReviewBitmap;

      FForceFile  :TString;            { Файл для принудительной обработки в ViewerEvent }
      FForceMode  :Integer;

      FLastDecode :DWORD;              { Для быстрой прокрутки }

      function NavigateLow(AInfo :TPanelInfo; AIndex :Integer; const AFileName :TString; ASlideDirect, ACacheDirect :Integer) :Boolean;
      function CheckSync(const aName :TString; var ASelected :Boolean) :Boolean;

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
      property ForceFile :TString read FForceFile;
      property ForceMode :Integer read FForceMode;
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
      FQuick     :Boolean;  { QuickView. Не используется. }
      FErrorStr  :TString;
      FPostKey   :Integer;
      FHidden    :Boolean;  { Окно изображения временно скрыто... }

      procedure ResizeDialog;
    end;


  var ModalDlg :TViewModalDlg;

  function ViewModalState(AView, AQuick :Boolean) :Boolean;

  function FarPanelCurrentFileName(aPanel :THandle = PANEL_ACTIVE) :TString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewDlgDecoders,
    ReviewDlgGeneral,
    ReviewDlgSaveAs,
    ReviewDlgSlideShow,
    MixDebug;


  const
    WS_EX_NOACTIVATE = $08000000;

  var
    hConsoleTopWnd :THandle;

    GLockSync :Integer;

  const
    cOrients :array[0..8] of TString =
      ('0', '1', 'H', '180'#176, 'V', 'H-90'#176, '90'#176, 'H+90'#176, '-90'#176);


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


  function FarPanelCurrentFileName(aPanel :THandle = PANEL_ACTIVE) :TString;
  begin
    Result := AddFileName(FarPanelGetCurrentDirectory(aPanel), FarPanelItemName(aPanel, FCTL_GETCURRENTPANELITEM, 0));
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

    {xxx}
//  Result.Top := Result.Bottom div 2;
//  Result.Left := Result.Right div 2;

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
 { Диалог запроса числового значения                                           }
 {-----------------------------------------------------------------------------}

  type
    TNumQueryDlg = class(TFarDialog)
    public
      constructor CreateEx(const aTitle :TString);

    protected
      procedure Prepare; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;

    private
      FTitle :TString;
      FRes   :Integer;
    end;


  constructor TNumQueryDlg.CreateEx(const aTitle :TString); 
  begin
    FTitle := aTitle;
    Create;
  end;


  procedure TNumQueryDlg.Prepare; {override;}
  begin
    FWidth := 20;
    FHeight := 5;
    FDialog := CreateDialog(
      [ NewItemApi(DI_DoubleBox, 0,  0, FWidth, FHeight, 0, PTChar(FTitle)) ],
      @FItemCount
    );
  end;


  function TNumQueryDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      byte('0')..byte('9'): begin
        FRes := AKey - byte('0');
        Close;
      end;
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function NumQuery(const aTitle :TString) :Integer;
  var
    vDlg :TNumQueryDlg;
  begin
    vDlg := TNumQueryDlg.CreateEx(aTitle);
    try
      if vDlg.Run <> -1 then
        Result := vDlg.FRes
      else
        Result := -1;
    finally
      FreeObj(vDlg);
    end;
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
    vSize :TSize;
    vRect :TSmallRect;
  begin
    vSize := FarGetWindowSize;
    vSize.CY := 1;
    SetDlgPos(0, 0, vSize.CX, vSize.CY);

    vRect := SBounds(0, 0, vSize.CX, vSize.CY);
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
          KEY_F1 :
            Review.SyncDelayed(SyncCmdUpdateWin, 100);

          Key_F3, KEY_F10, Key_NumPad5: begin
            Close;
            Result := True;
            Exit;
          end;

          KEY_F9 : begin
            Review.SyncDelayed(SyncCmdUpdateWin, 100);
            Review.PluginSetup;
          end;

          KEY_F4..KEY_F8{,KEY_F10},KEY_F11: begin
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
        if AView then
          Review.CloseWindowDelayed(100) 
        else
          Review.CloseWindow;
        if AView then
          vKeys := 'Esc';
        if ModalDlg.FPostKey <> 0 then
          vKeys := AppendStrCh(vKeys, FarKeyToName(ModalDlg.FPostKey), ' ');
        if vKeys <> '' then
          FarPostMacro('Keys("' + vKeys + '")');
      end else
      begin
        Review.CloseWindowDelayed(1000);
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
  end;


  destructor TReviewWindow.Destroy; {override;}
  begin
    ReleaseImage;
    ReleaseDecoder;
    if FBrush <> 0 then
      DeleteObject(FBrush);
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


//procedure TReviewWindow.WMNCHitTest(var Mess :TWMNCHitTest); {message WM_NCHitTest;}
//begin
//  Mess.Result := HTTRANSPARENT;
//end;


  procedure TReviewWindow.WMMouseActivate(var Mess :TWMMouseActivate); {message WM_MouseActivate;}
  begin
    inherited;

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


  procedure TReviewWindow.CMSetImage(var Mess :TMessage); {message CM_SetImage;}
  var
    vOldImage :TReviewImage;
    vOldSrcRect, vOldDstRect :TRect;
  begin
    with PSetImageRec(Mess.LParam)^ do begin

      vOldImage := nil;
      if FImage <> nil then begin
        if (optEffectType = 0) or (Direct = 0) or FImage.FSelfdraw or Image.FSelfdraw then
          ReleaseImage
        else begin
          vOldImage := FImage;
          vOldSrcRect := FSrcRect;
          vOldDstRect := FDstRect;
          FImage := nil;
          FImageOk := False;
        end;
      end;

      try
        AttachDecoder(Image.FDecoder);

        if WinMode <> -1 then begin
          if WinMode = 1 then
//          SetWinMode(wmQuickView)
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

        FSlideStart := 0;
        FSlideDelay := 0;

        FTempMsg := '';

        CreateBrushes;
        RecalcRects;

        if not IsWindowVisible(Handle) then
          ShowWindow
        else
        if FWinMode <> wmFullscreen then
          SetWindowBounds(CalcWinRect);

        if vOldImage <> nil then
          SlideEffect(vOldImage, vOldSrcRect, vOldDstRect, Direct)
        else
          Invalidate;

        FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);

      finally
        if vOldImage <> nil then
          FreeImage(vOldImage);
      end;
    end;
  end;


  procedure TReviewWindow.CMReleaseImage(var Mess :TMessage); {message CM_ReleaseImage;}
  begin
    ReleaseImage;
//  Invalidate;
  end;


  const
    cmtInvalidate = 0;
    cmtSetPage    = 1;
    cmtRotate     = 2;
    cmtOrient     = 3;

  procedure TReviewWindow.CMTransform(var Mess :TMessage); {message CM_Transform;}

     procedure LocInvalidate;
     begin
       FHiQual := True;
       Invalidate;
     end;

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
       FTempMsg := '';
       RecalcRects;
       LocInvalidate;
       FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
     end;

  begin
    if FImage <> nil then begin
      case Mess.wParam of
        cmtInvalidate : LocInvalidate;
        cmtSetPage    : LocSetPage(Mess.lParam);
        cmtRotate     : LocRotate(Mess.lParam);
        cmtOrient     : {};
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


  procedure TReviewWindow.CMSlideShow(var Mess :TMessage); {message CM_SlideShow;}
  begin
    if Mess.wParam = 1 then begin
      FSlideStart := GetTickCount;
      FSlideDelay := optSlideDelay;
    end else
    begin
      FSlideStart := 0;
      FSlideDelay := 0;
    end;
  end;


  procedure TReviewWindow.CMTempMsg(var Mess :TMessage); {message CM_TempMsg;}
  begin
    SetTempMsg(TString(Mess.lParam), Mess.WParam = 1);
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
    SetTempMsg(Format('Scale: %d%%', [Round(100 * FScale)]));  {!Localize}
    Invalidate;
    FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
  end;


  procedure TReviewWindow.SetPage(aPage :Integer);
  begin
    FImage.FPage := RangeLimit(aPage, 0, FImage.FPages);
    FImage.DecodePage(Size(0,0));
    FHiQual := True;
    RecalcRects;
    if not FAnimate then
      SetTempMsg(Format('Page: %d / %d', [FImage.FPage + 1, FImage.FPages])); {!Localize}
    Invalidate;
  end;


  procedure TReviewWindow.SetTempMsg(const AMsg :TString; aInvalidate :Boolean = True);
  begin
    FTempMsg := AMsg;
    FMsgStart := GetTickCount;
    FMsgDelay := optTempMsgDelay;
    if aInvalidate then
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
      if (FImage.FWidth <> 0) and (FImage.FHeight <> 0) then begin
        { Подберем масштаб, чтобы изображение вписывалось в экран }
        FScale := FloatMin( vWinSize.cx / FImage.FWidth, vWinSize.cy / FImage.FHeight);
        if FScale > (optInitialScale / 100) then
          FScale := (optInitialScale / 100);
      end else
        FScale := 1;

      if FScale > 0 then
        FLnScale := Ln(FScale) / Ln( cScaleStep)
      else
        FLnScale := 0;
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


 {-----------------------------------------------------------------------------}

  procedure TReviewWindow.PaintWindow(DC :HDC);
  var
    vClientRect, vClipRect :TRect;
    vMemDC :TMemDC;
    vSaveDC :Integer;
    vSize :TSize;
    vTmpRect :TRect;
    vFillAll :Boolean;
  begin
//  Trace('PaintWindow...');
    vClientRect := ClientRect;
    try
      GetClipBox(DC, vClipRect);

      if FImageOk then begin
        { Картинка заполняет весь экран }
        vFillAll := (optTileMode and not FImage.FSelfdraw) or RectContainsRect(FDstRect, vClientRect);

        if (optShowInfo <> 0) and not FImage.FSelfdraw then begin

          vSize := RectSize(vClientRect);
          vMemDC := TMemDC.Create(vSize.CX, vSize.CY);
          try
            if not vFillAll then
              FillRect(vMemDC.DC, vClientRect, FBrush);

            if (optTileMode and not FImage.FSelfdraw) or RectIntersects(FDstRect, vClipRect) then
              DrawImage(vMemDC.DC, FImage, FSrcRect, FDstRect, True);
              
            if optShowInfo <> 0 then
              DrawAddInfo(vMemDC.DC);

            vTmpRect := Bounds(0, 0, vSize.CX, vSize.CY);
            GDIBitBlt(DC, vTmpRect, vMemDC.DC, vTmpRect, False);
          finally
            FreeObj(vMemDC);
          end;

        end else
        begin
          if (optTileMode and not FImage.FSelfdraw) or RectIntersects(FDstRect, vClipRect) then
            DrawImage(DC, FImage, FSrcRect, FDstRect, False);

          if not vFillAll then begin
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

          if optShowInfo <> 0 then
            DrawAddInfo(DC);
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


  procedure TReviewWindow.SlideEffect(aOldImage :TReviewImage; const AOldSrcRect, AOldDstRect :TRect; ADirect :Integer);
  var
    i, j, m, a1, a2, dx, dy :Integer;
    vDC :HDC;
    vClientRect :TRect;
    vMemDC, vImage1DC, vImage2DC :TMemDC;
    vSize :TSize;
    vRect, vRect1 :TRect;
    vTime :DWORD;
    vPeriod :Integer;
  begin
//  Trace('Slide...');
    try
      vDC := GetDC(Handle);
      ApiCheck(vDC <> 0);
      try
        vClientRect := ClientRect;
        vSize := RectSize(vClientRect);
        vMemDC := nil; vImage1DC := nil; vImage2DC := nil;
        try
          vMemDC := TMemDC.Create(vSize.CX, vSize.CY);
          vImage1DC := TMemDC.Create(vSize.CX, vSize.CY);
          vImage2DC := TMemDC.Create(vSize.CX, vSize.CY);

          vRect := Bounds(0, 0, vSize.CX, vSize.CY);

          FillRect(vImage1DC.DC, vRect, FBrush);
          FillRect(vImage2DC.DC, vRect, FBrush);

          DrawImage(vImage1DC.DC, aOldImage, AOldSrcRect, AOldDstRect, False);
          DrawImage(vImage2DC.DC, FImage, FSrcRect, FDstRect, False);

          i := 1;
          m := 255;
          vTime := GetTickCount;
          while (TickCountDiff(GetTickCount, vTime) < optEffectPeriod) and (i <= m) do begin
            a1 := MulDiv(m - i, 255, m);
            a2 := MulDiv(i, 255, m);

//          TraceF('i=%d, a1=%d, a2=%d', [i, a1, a2]);
//          if i > 128 then
//            NOP;

            FillRect(vMemDC.DC, vRect, FBrush);

            if optEffectType = 1 then begin
              GDIAlhaBlend(vMemDC.DC, vRect, vImage1DC.DC, vRect, False, a1);
              GDIAlhaBlend(vMemDC.DC, vRect, vImage2DC.DC, vRect, False, a2);
            end else
            if optEffectType in [2, 3] then begin
              dx := MulDiv(i, vSize.CX div 3, m);
              dy := MulDiv(i, vSize.CY div 3, m);

              vRect1 := vRect;
              RectGrow(vRect1, -dx, -dy);
              if optEffectType = 2 then
                RectMove(vRect1, ADirect * (-MulDiv(i, vSize.CX div 2, m)), 0)
              else
                RectMove(vRect1, 0, ADirect * (-MulDiv(i, vSize.CY div 2, m)));
              GDIAlhaBlend(vMemDC.DC, vRect1, vImage1DC.DC, vRect, False, a1);

              dx := MulDiv(m - i, vSize.CX div 3, m);
              dy := MulDiv(m - i, vSize.CY div 3, m);

              vRect1 := vRect;
              RectGrow(vRect1, -dx, -dy);
              if optEffectType = 2 then
                RectMove(vRect1, ADirect * ((vSize.CX div 2) - MulDiv(i, vSize.CX div 2, m)), 0)
              else
                RectMove(vRect1, 0, ADirect * ((vSize.CY div 2) - MulDiv(i, vSize.CY div 2, m)));
              GDIAlhaBlend(vMemDC.DC, vRect1, vImage2DC.DC, vRect, False, a2);
            end;

            if optShowInfo <> 0 then
              DrawAddInfo(vMemDC.DC);
            GDIBitBlt(vDC, vRect, vMemDC.DC, vRect, False);

            j := i;
            while True do begin
              vPeriod := TickCountDiff(GetTickCount, vTime);
              i := MulDiv(vPeriod, m, optEffectPeriod);
              if i > j then
                Break;
//            Trace('Sleep.');
              Sleep(1);
            end;
          end;

          Invalidate;

        finally
          FreeObj(vImage1DC);
          FreeObj(vImage2DC);
          FreeObj(vMemDC);
        end;
      finally
        ReleaseDC(Handle, vDC);
      end;
    except
      Invalidate;
    end;
//  Trace('...done slide');
  end;


  procedure TReviewWindow.DrawImage(DC :HDC; aImage :TReviewImage; const ASrcRect, ADstRect :TRect; ABuffered :Boolean);
  var
    vTransparent :Boolean;

    function LocScaleX(X :Integer) :Integer;
    begin
      Result := MulDiv(X, aImage.FBitmap.Size.CX, aImage.FWidth);
    end;

    function LocScaleY(Y :Integer) :Integer;
    begin
      Result := MulDiv(Y, aImage.FBitmap.Size.CY, aImage.FHeight);
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
      vNeedStretch, vIncrease, vSmooth :Boolean;
    begin
      vBmpRect := ASrcRect;
      if (aImage.FBitmap.Size.CX <> aImage.FWidth) or (aImage.FBitmap.Size.CY <> aImage.FHeight) then
        { Размер декодированного битмапа не равен декларируемому размеру изображения - масштабируем }
        with ASrcRect do
          vBmpRect := Rect(LocScaleX(Left), LocScaleY(Top), LocScaleX(Right), LocScaleY(Bottom));

      vNeedStretch :=
        ((vBmpRect.Right - vBmpRect.Left) <> (ADstRect.Right - ADstRect.Left)) or
        ((vBmpRect.Bottom - vBmpRect.Top) <> (ADstRect.Bottom - ADstRect.Top));

      if vNeedStretch or (vTransparent and (FWinBPP < 32)) then begin
        vIncrease := (vBmpRect.Right - vBmpRect.Left) < (ADstRect.Right - ADstRect.Left);

        if FHiQual then begin
          { При уменьшении сглаживаем всегда, а при увеличении - только если включена опция optSmoothScale }
          vSmooth := not vIncrease or (vIncrease and optSmoothScale);

          if not aImage.FIsThumbnail and ((vIncrease and vSmooth) or (vTransparent and not vIncrease)) then begin
            if TryLockGDIPlus then begin
              try
                GpStretchDraw(ADC, ADstRect, aImage.FBitmap.BMP, vBmpRect, vTransparent, vSmooth);
              finally
                UnlockGDIPlus;
              end;
            end else
              GDIStretchDraw(ADC, ADstRect, aImage.FBitmap.DC, vBmpRect, vTransparent, vSmooth);
          end else
            GDIStretchDraw(ADC, ADstRect, aImage.FBitmap.DC, vBmpRect, vTransparent, vSmooth);

          FDraftMode := False;
        end else
        begin
          { Быстрый вывод - без сглаживания }
          if vTransparent and (FWinBPP < 32) then
            GpStretchDraw(ADC, ADstRect, aImage.FBitmap.BMP, vBmpRect, vTransparent, False)
          else
            GDIStretchDraw(ADC, ADstRect, aImage.FBitmap.DC, vBmpRect, vTransparent, False);
          FDraftMode := True;
          FDraftStart := GetTickCount;
        end;

      end else
      begin
        GDIBitBlt(ADC, ADstRect, aImage.FBitmap.DC, vBmpRect, vTransparent);
        FDraftMode := False;
      end;
    end;

  var
    I, J, vTileX, vTileY :Integer;
    vSize, vPicSize :TSize;
    vTmpRect, vRect :TRect;
    vMemDC :TMemDC;
  begin
//  with ADstRect do
//    TraceF('Draw. DstRect=%dx%d-%dx%d', [Left, Top, Right, Bottom]);

    if aImage.FSelfdraw then begin

//    if aImage.FTransparent then begin
//      LocFillBackground(ADC, ADstRect);
        FDecoder.pvdDisplayPaint(Handle, aImage, ASrcRect, ADstRect, FColor)
//    end else
//      FDecoder.pvdDisplayPaint(Handle, aImage, ASrcRect, ADstRect, FColor)

    end else
    begin
      vTileX := 0; vTileY := 0;
      if optTileMode then begin
        vPicSize := Size(
          Round(aImage.FWidth * FScale),
          Round(aImage.FHeight * FScale));
        vTileX := IntMax((ADstRect.Left + vPicSize.CX - 1) div vPicSize.CX, 0);
        vTileY := IntMax((ADstRect.Top + vPicSize.CY - 1) div vPicSize.CY, 0);
      end;

      vTransparent := aImage.FTransparent {and (FWinBPP = 32)};

      if vTransparent or (vTileX > 0) or (vTileY > 0) then begin
        vSize := RectSize(ADstRect);
        vMemDC := TMemDC.Create(vSize.CX, vSize.CY);
        try
          vTmpRect := Bounds(0, 0, vSize.CX, vSize.CY);
          if vTransparent then
            LocFillBackground(vMemDC.DC, vTmpRect);

          LocDraw(vMemDC.DC, vTmpRect);

          if (vTileX > 0) or (vTileY > 0) then begin
            vRect := ADstRect;
            RectMove(vRect, -vTileX * vSize.CX, -vTileY * vSize.CY);
            for J := 0 to vTileY * 2 do begin
              for I := 0 to vTileX * 2 do begin
                GDIBitBlt(DC, vRect, vMemDC.DC, vTmpRect, False);
                RectMove(vRect, vSize.CX, 0);
              end;
              RectMove(vRect, -(vTileX*2 + 1) * vSize.CX, vSize.CY);
            end;
          end else
            GDIBitBlt(DC, ADstRect, vMemDC.DC, vTmpRect, False);

        finally
          FreeObj(vMemDC);
        end;
      end else
        LocDraw(DC, ADstRect);

      FHiQual := False;
    end;
  end;


  procedure TReviewWindow.DrawTempText(DC :HDC; const AStr :TString);
  var
    X, Y :Integer;
    vSize :TSize;
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
      end;

      SetBkMode(DC, OPAQUE);
      SetBkColor(DC, FarAttrToCOLORREF(GetColorBG(optHintColor)));
      SetTextColor(DC, FarAttrToCOLORREF(GetColorFG(optHintColor)));
      TextOut(DC, X, Y, PTChar(AStr), Length(AStr));

    finally
      SelectObject(DC, vOldFont);
    end;
  end;


  procedure TReviewWindow.DrawAddInfo(DC :HDC);
  const
    cDeltaL = 5;
    cDeltaT = 5;
    cDeltaR = 5;
    cDeltaB = 5;
  const
    cNameWidth = 80;
  var
    vStrs :TStrList;

    function GrayColor(aColor :COLORREF) :Byte;
    begin
      with RGBRec(aColor) do
        Result := (Red + Green + Blue) div 3;
    end;

    function TranspBetween(aColor1, aColor2 :COLORREF) :Integer;
    var
      vColor1, vColor2 :Byte;
    begin
      vColor1 := GrayColor(aColor1);
      vColor2 := GrayColor(aColor2);
      Result := Abs(vColor1 - vColor2);
    end;


    function Div2Str(aVal :Int64; aPrec :Integer) :TString;
    begin
      with Int64Rec(aVal) do
        Result := FloatToStrF(Lo / Hi, ffGeneral, 0, aPrec);
    end;

    function Frac2Str(aVal :Int64) :TString;
    begin
      with Int64Rec(aVal) do
        Result := '1/' + FloatToStrF(Hi / Lo, ffGeneral, 0, 0);
    end;

    procedure Add1(const APrompt, AValue :TString);
    begin
      vStrs.Add(APrompt);
      vStrs.Add(AValue);
    end;

    procedure Add(APrompt :TMessages; const AValue :TString);
    begin
      vStrs.Add(GetMsg(APrompt));
      vStrs.Add(AValue);
    end;

  var
    I, X, Y, CY, CX1, CX2, vHeight, vMaxWidth2 :Integer;
    vFont, vOldFont :HFont;
    vSize :TSize;
    vRect :TRect;
    vStr :TString;
    vColor1, vColor2, vPromptColor1, vPromptColor2 :COLORREF;
  begin
    vStrs := TStrList.Create;
    try
      FImage.CollectInfo;

      Add(strIName,   ExtractFileName(FImage.FName));
      Add(strISize,   Int64ToStrEx(FImage.FSize));
      Add(strITime,   DateTimeToStr(FileDateToDateTime(FImage.FTime)));

      Add1('', '');

//    Add(strIFormat,      FImage.FFormat);
      vStr := FImage.FFormat;
      if FImage.FCompress <> '' then
        vStr := vStr + ' / ' + FImage.FCompress;
      Add(strIFormat,      vStr);

      if FImage.FDescr <> '' then
        Add(strIDescription, FImage.FDescr);

      Add(strIDimension,   IntToStr(FImage.FWidth) + ' x ' + IntToStr(FImage.FHeight));
      Add(strIColors,      IntToStr(FImage.FBPP) + ' ' + GetMsg(strBPP));

      if (FImage.FTags.XResolution <> 0) or (FImage.FTags.YResolution <> 0) then
        if FImage.FTags.XResolution = FImage.FTags.YResolution then
          Add(strIDensity, Int2Str(FImage.FTags.XResolution) + ' ' + GetMsg(strDPI))
        else
          Add(strIDensity, Int2Str(FImage.FTags.XResolution) + ' x ' + Int2Str(FImage.FTags.YResolution) + ' ' + GetMsg(strDPI));

      if FImage.FPages > 1 then
        Add(strIPages, IntToStr(FImage.FPage + 1) + ' / ' + IntToStr(FImage.FPages));
      if FImage.FAnimated then
        Add(strIDelay, IntToStr(FImage.FDelay) + ' ' + GetMsg(strMS) );
      if FImage.FOrient > 1 then
        Add(strIOrientation, cOrients[FImage.FOrient]);

      Add1('', '');

      Add(strIDecoder,     FImage.FDecoder.Title);
      Add(strIDecodeTime,  IntToStr(FImage.FOpenTime + FImage.FDecodeTime) + ' ' + GetMsg(strMS));

      Add1('', '');

      if FImage.FTags.Time <> '' then
        Add(strIImageTime,  FImage.FTags.Time);
      if FImage.FTags.Description <> '' then
        Add(strIDescription,  FImage.FTags.Description);
      if FImage.FTags.EquipModel <> '' then
        Add(strICamera,  FImage.FTags.EquipModel);
      if FImage.FTags.EquipMake <> '' then
        Add(strIManufacturer,  FImage.FTags.EquipMake);
      if FImage.FTags.Software <> '' then
        Add(strISoftware,  FImage.FTags.Software);
      if FImage.FTags.Author <> '' then
        Add(strIAuthor,  FImage.FTags.Author);
      if FImage.FTags.Copyright <> '' then
        Add(strICopyright,  FImage.FTags.Copyright);

      Add1('', '');

      if FImage.FTags.ExposureTime <> 0 then
        Add(strIExposureTime,  Frac2Str(FImage.FTags.ExposureTime) + ' ' + GetMsg(strSec1));
      if FImage.FTags.FNumber <> 0 then
        Add(strIFNumber,  Div2Str(FImage.FTags.FNumber, 1));
      if FImage.FTags.FocalLength <> 0 then
        Add(strIFocalLength,  Div2Str(FImage.FTags.FocalLength, 0) + ' ' + GetMsg(strMM));
      if FImage.FTags.ISO <> 0 then
        Add(strIISO,  Int2Str(FImage.FTags.ISO));
      if FImage.FTags.Flash <> 0 then
        Add(strIFlash,  Int2Str(FImage.FTags.Flash));

      vFont := GetStockObject(DEFAULT_GUI_FONT);
      vOldFont := SelectObject(DC, vFont);
      if vOldFont = 0 then
        Exit;
      try
        GetTextExtentPoint32(DC, '1', 1, vSize);

        for I := (vStrs.Count div 2) - 1 downto 0 do
          if vStrs[I * 2] = '' then
            vStrs.DeleteRange(I * 2, 2)
          else
            Break;

        vMaxWidth2 := IntMax(cNameWidth, ClientRect.Right div 2 - cNameWidth);

        CY  := 0;
        CX1 := cNameWidth;
        CX2 := 0;
        for I := 0 to (vStrs.Count div 2) - 1 do begin
          vStr := vStrs[I * 2];
          if vStr = '' then
            Inc(CY, vSize.cy div 2)
          else begin
            vStr := vStrs[I * 2 + 1];
            if vStr = '' then
              Inc(CY, vSize.cy + 2)
            else begin
              vRect := Bounds(0, 0, vMaxWidth2, 0);
              vHeight := DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_WORDBREAK or DT_CALCRECT);

              CX2 := IntMax(CX2, vRect.Right - vRect.Left);
              Inc(CY, vHeight + 2);
            end;
          end;
        end;

        vRect := Bounds(0, 0, CX1 + CX2 + cDeltaL + cDeltaR, CY + cDeltaT + cDeltaB);

        vColor1 := FarAttrToCOLORREF(GetColorBG(optPanelColor));  // On black
        vColor2 := FarAttrToCOLORREF(GetColorFG(optPanelColor));

        GDIFillRectTransp(DC, vRect, vColor1, optPanelTransp);
        GDIFillRectTransp(DC, vRect, vColor2, optPanelTransp);

        vPromptColor1 := FarAttrToCOLORREF(GetColorBG(optPromptColor));
        vPromptColor2 := FarAttrToCOLORREF(GetColorFG(optPromptColor));
        vColor1 := FarAttrToCOLORREF(GetColorBG(optInfoColor));
        vColor2 := FarAttrToCOLORREF(GetColorFG(optInfoColor));

        SetBkMode(DC, TRANSPARENT);

        X  := cDeltaL; Y := cDeltaT;
        for I := 0 to (vStrs.Count div 2) - 1 do begin
          vStr := vStrs[I * 2];
          if vStr = '' then
            Inc(Y, vSize.cy div 2)
          else begin
            if vPromptColor1 <> vPromptColor2 then begin
              SetTextColor(DC, vPromptColor1);
              TextOut(DC, X+1, Y+1, PTChar(vStr), Length(vStr));
            end;

            SetTextColor(DC, vPromptColor2);
            TextOut(DC, X, Y, PTChar(vStr), Length(vStr));

            vStr := vStrs[I * 2 + 1];
            if vStr = '' then
              Inc(Y, vSize.cy + 2)
            else begin
              vRect := Bounds(X + CX1, Y, CX2, 0);

              if vColor1 <> vColor2 then begin
                SetTextColor(DC, vColor1);
                RectMove(vRect, +1, +1);
                {vHeight :=} DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_WORDBREAK);
                RectMove(vRect, -1, -1);
              end;

              SetTextColor(DC, vColor2);
              vHeight := DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_WORDBREAK);

              Inc(Y, vHeight + 2);
            end;
          end;
        end;

      finally
        SelectObject(DC, vOldFont);
      end;

    finally
      FreeObj(vStrs);
    end;
  end;


 {-----------------------------------------------------------------------------}

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
    vArea, vCX, vCY, vDelay :Integer;
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

    if (FImage <> nil) and FAnimate then begin
      { Анимация... }
      vDelay := FImage.FDelay;
      if vDelay = 0 then
        vDelay := cDefAnimationStep;
      if TickCountDiff(GetTickCount, FPageStart) > vDelay then begin
        FPageStart := GetTickCount;
        SetPage( IntIf(FImage.FPage < FImage.FPages - 1, FImage.FPage + 1, 0) );
      end;
    end;

    if (FSlideDelay <> 0) and (TickCountDiff(GetTickCount, FSlideStart) > FSlideDelay) and IsWindowVisible(Handle) then begin
      { SlideShow }
      FSlideStart := 0;
      FSlideDelay := 0;
      FarAdvControl(ACTL_SYNCHRO, SyncCmdNextSlide);  { Вызов GoNextSlide в главном потоке }
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

  function GetFileInfo(const FileName :TString; var aTime :Integer; var aSize :TInt64) :Boolean;
  var
    Handle: THandle;
    FindData: TWin32FindData;
  begin
    Handle := FindFirstFile(PTChar(FileName), FindData);
    if Handle <> INVALID_HANDLE_VALUE then begin
      Windows.FindClose(Handle);
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
        aTime := FileTimeToDosFileDate(FindData.ftLastWriteTime);
        aSize := MakeInt64(FindData.nFileSizeLow, FindData.nFileSizeHigh);
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;



  procedure TReviewImage.CollectInfo;

    procedure LocGetInt(aCode :Integer; var aValue :Integer);
    var
      vType :Integer;
      vValue :Pointer;
    begin
      if FDecoder.pvdTagInfo(Self, aCode, vType, vValue) and (vType = PVD_TagType_Int) then
        aValue := TIntPtr(vValue);
    end;

    procedure LocGetInt64(aCode :Integer; var aValue :Int64);
    var
      vType :Integer;
      vValue :Pointer;
    begin
      if FDecoder.pvdTagInfo(Self, aCode, vType, vValue) and (vType = PVD_TagType_Int64) then
        aValue := PInt64(vValue)^;
    end;

    procedure LocGetStr(aCode :Integer; var aValue :TString);
    var
      vType :Integer;
      vValue :Pointer;
    begin
      if FDecoder.pvdTagInfo(Self, aCode, vType, vValue) and (vType = PVD_TagType_Str) then
        aValue := Trim(PTChar(vValue));
    end;

  var
    vTime :TDateTime;
  begin
    if FInfoInited then
      Exit;

    GetFileInfo(FName, FTime, FSize);

    if FDecoder <> nil then begin
      LocGetStr(PVD_Tag_Description, FTags.Description);
      LocGetStr(PVD_Tag_Time,        FTags.Time);
      LocGetStr(PVD_Tag_EquipMake,   FTags.EquipMake);
      LocGetStr(PVD_Tag_EquipModel,  FTags.EquipModel);
      LocGetStr(PVD_Tag_Software,    FTags.Software);
      LocGetStr(PVD_Tag_Author,      FTags.Author);
      LocGetStr(PVD_Tag_Copyright,   FTags.Copyright);

      LocGetInt64(PVD_Tag_ExposureTime, FTags.ExposureTime);
      LocGetInt64(PVD_Tag_FNumber,      FTags.FNumber);
      LocGetInt64(PVD_Tag_FocalLength,  FTags.FocalLength);
      LocGetInt(PVD_Tag_ISO,            FTags.ISO);
      LocGetInt(PVD_Tag_Flash,          FTags.Flash);
      LocGetInt(PVD_Tag_XResolution,    FTags.XResolution);
      LocGetInt(PVD_Tag_YResolution,    FTags.YResolution);

      vTime := YMDStrToDateTime(FTags.Time);
      if vTime <> 0 then
        FTags.Time := DateTimeToStr(vTime);
    end;

    FInfoInited := True;
  end;


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


  procedure TReviewImage.DecodePage(ASize :TSize; AFastScroll :Boolean = False);
  var
    vStart :DWORD;
  begin
    vStart := GetTickCount;
    FDecodeTime := 0;

    if FDecoder.pvdGetPageInfo(Self) then begin

      if FOrient in [5,6,7,8] then
        IntSwap(ASize.CX, ASize.CY);

      { Декодируем... }
      if FDecoder.pvdPageDecode(Self, 0{???}, ASize.CX, ASize.CY, AFastScroll) then begin
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


  function TReviewManager.ShowImage(const AFileName :TString; AMode :Integer; AForce :Boolean = False; ADirect :Integer = 0) :Boolean;
  var
    vName :TString;
    vImage :TReviewImage;
    vFastScroll :Boolean;
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
        vName := FarPanelCurrentFileName;

      vFastScroll := TickCountDiff(GetTickCount, FLastDecode) < FastListDelay;
      if vFastScroll then
        { Отключаем эффект перехода }
        ADirect := 0;

      vImage := FindInCache(vName);
      if vImage = nil then begin
        if not WinFileExists(vName) then
          Exit;

        if ModalDlg <> nil then
          ModalDlg.SetTitle(ExtractFileName(vName) + ' - decoding...');  {!Localize}

        vImage := TReviewImage.CreateEx(vName);
        vImage._AddRef;
        try
          if vImage.TryOpen(AForce) then begin
            FCommand := GoCmdNone;
            vImage.DecodePage(CalcWinSize(AMode), vFastScroll);
            DisplayImage(vImage, AMode, ADirect);
            CacheImage(vImage);
            Result := True;
          end else
          begin
            if AForce then
              AppErrorId(strFormatError);
            FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
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
        DisplayImage(vImage, AMode, ADirect);
        CacheImage(vImage);
        Result := True;
      end;
      
      if Result then
        FLastDecode := GetTickCount;

    finally
      Dec(GLockSync);
    end;
  end;


  procedure TReviewManager.DisplayImage(aImage :TReviewImage; AMode :Integer; ADirect :Integer = 0);
  var
    vRec :TSetImageRec;
  begin
    if ScreenBitPerPixel < 16 then
      AppErrorId(strBadVideoModeError);

    CreateWinThread;

//  TraceF('SetItemToWindow. ACallMode=%d', [Byte(ACallMode)]);
    FillZero(vRec, SizeOf(vRec));
    vRec.Image := aImage;
    vRec.WinMode := AMode;
    vRec.WinRect := CalcWinRectAs(AMode);
    vRec.Direct  := ADirect;
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
        ModalDlg.SetTitle(ExtractFileName(CurImage.FName) + ' - decoding...');  {!Localize}

      vImage := TReviewImage.CreateEx(CurImage.FName);
      vImage._AddRef;
      try
        vIndex := FDecoders.IndexOf(CurImage.FDecoder);
        vNewIndex := LocNext(vIndex);
        while vNewIndex <> vIndex do begin
          if vImage.TryOpenBy( FDecoders[vNewIndex], False ) then begin
            vImage.DecodePage(CalcWinSize);
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
      SetTempMsg(Format('Decoder: %s (%d+%d=%d ms)', [FDecoder.Title, FOpenTime, FDecodeTime, FOpenTime + FDecodeTime]));  {!Localize}
  end;



  procedure TReviewManager.SetTempMsg(const AMsg :TString; aInvalidate :Boolean = True);
  begin
    if FWindow <> nil then
      SendMessage(FWindow.Handle, CM_TempMsg, Byte(aInvalidate), TIntPtr(AMsg));
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


  procedure TReviewManager.CloseWindowDelayed(ADelay :Integer);
  begin
    if FWinThread <> nil then begin
      SendMessage(FWindow.Handle, CM_ReleaseImage, 0, 0);
      Review.SyncDelayed(SyncCmdClose, ADelay);
      ClearCache;
    end;
  end;


  function TReviewManager.CheckSync(const aName :TString; var ASelected :Boolean) :Boolean;
  var
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
    vName :TString;
  begin
    Result := False;
    if FarGetPanelInfo(True, vInfo) then begin
      vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0);
      if vItem <> nil then begin
        try
          vName := vItem.FileName;
          if PFLAGS_REALNAMES and vInfo.Flags = 0 then begin
            vName := ExtractFileName(vName);
            Result := StrEqual(ExtractFileName(aName), vName);
          end else
          begin
            vName := AddFileName(FarPanelGetCurrentDirectory, vName);
            Result := StrEqual(aName, vName);
          end;
          if Result then
            ASelected := PPIF_SELECTED and vItem.Flags <> 0;
        finally
          MemFree(vItem);
        end;
      end;
    end;
  end;


  function TReviewManager.GetWindowTitle :TString;
  const
    vDelim = $2022;

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

  var
    vFmt :TString;
    vScale :Integer;
    vSelected :Boolean;
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
          FSelected := IntIf(CheckSync(FName, vSelected) and vSelected, 1, 0);
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
      vPath := FarPanelGetCurrentDirectory;
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
                  vImage.DecodePage(CalcWinSize);
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

  procedure TReviewManager.SlideShow(AMode :Integer; aShowInfo :Boolean = True);
  begin
    if FWindow <> nil then begin
      if AMode = -1 then
        AMode := IntIf(FWindow.FSlideDelay = 0, 1, 0);
      SendMessage(FWindow.Handle, CM_SlideShow, IntIf(AMode = 1, 1, 0), 0);
      if aShowInfo then begin
        if AMode = 1 then
          SetTempMsg(GetMsg(strSlideShow) + ': ' + GetMsg(strOn) + ' (' + FloatToStrF(optSlideDelay / 1000, ffGeneral, 0, 1) + ' ' + GetMsg(strSec) + ')')
        else
          SetTempMsg(GetMsg(strSlideShow) + ': ' + GetMsg(strOff));
      end;    
      if optPrecache then
        SyncDelayed(SyncCmdCacheNext, optCacheDelay)
    end;
  end;


  procedure TReviewManager.SlideShowQueryDelay;
  var
    vNum :Integer;
  begin
    if FWindow <> nil then begin
      SendMessage(FWindow.Handle, CM_SlideShow, 0, 0);
      SetTempMsg(GetMsg(strSlideShowDelay) + ' = ');
      FWindow.FMsgDelay := MaxInt;

      vNum := NumQuery(GetMsg(strSlideShowDelay));
      if (vNum >= 1) and (vNum <= 9) then begin
        optSlideDelay := vNum * 1000;
        SlideShow(1);
      end else
        SetTempMsg('');
    end;
  end;


  procedure TReviewManager.GoNextSlide;
  begin
    if Navigate(0, True, True) then begin
      if Review.FCommand = GoCmdNone then
        SendMessage(FWindow.Handle, CM_SlideShow, 1, 0)
      else
        Review.FCommand := GoCmdNextSlide;
    end else
      SetTempMsg(GetMsg(strSlideShow) + ': ' + GetMsg(strFinish));
  end;


 {-----------------------------------------------------------------------------}

  function TReviewManager.Navigate(AOrig :Integer; AForward :Boolean; ASlideShow :Boolean = False) :Boolean;
  var
    vInfo :TPanelInfo;
    vIndex, vDirect :Integer;
    vItem :PPluginPanelItem;
    vPath, vFileName :TString;
  begin
    Result := False;
    if FarGetPanelInfo(True, vInfo) then begin
      vDirect := 0;
      if ASlideShow then
        vDirect := IntIf((AOrig = 2) or ((AOrig = 0) and AForward), 1, -1);
      vPath := FarPanelGetCurrentDirectory;

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
              vFileName := vItem.FileName;
              if PFLAGS_REALNAMES and vInfo.Flags <> 0 then
                vFileName := AddFileName(vPath, vItem.FileName);
              if NavigateLow(vInfo, vIndex, vFileName, vDirect, IntIf(AForward, 1, -1)) then begin
                Result := True;
                Exit;
              end;
            end;
          finally
            MemFree(vItem);
          end;
        end;
      end;
    end;
  end;


  function TReviewManager.NavigateTo(const AFileName :TString) :Boolean;
  var
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
    vIndex :Integer;
    vPath, vFileName :TString;
  begin
    Result := False;
    if FarGetPanelInfo(True, vInfo) then begin
      vPath := FarPanelGetCurrentDirectory;
      vIndex := 0;
      while vIndex < vInfo.ItemsNumber do begin
        vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
        if vItem <> nil then begin
          try
            if vItem.FileAttributes and faDirectory = 0 then begin
              vFileName := vItem.FileName;
              if StrEqual(vFileName, AFileName) then begin
                if PFLAGS_REALNAMES and vInfo.Flags <> 0 then
                  vFileName := AddFileName(vPath, vItem.FileName);
                Result := NavigateLow(vInfo, vIndex, vFileName, 0, 0);
                Exit;
              end;
            end;
          finally
            MemFree(vItem);
          end;
        end;
        Inc(vIndex);
      end;
    end;
  end;


  function TReviewManager.NavigateLow(AInfo :TPanelInfo; AIndex :Integer; const AFileName :TString; ASlideDirect, ACacheDirect :Integer) :Boolean;
  var
    vRedrawInfo :TPanelRedrawInfo;
  begin
    Result := False;
    if PFLAGS_REALNAMES and AInfo.Flags = 0 then begin
      { Плагинная панель с "виртуальными" файлами, навигируемся через макросы... }
      if CanShowImage(AFileName) then begin
        FCommand := IntIf(ASlideDirect >= 2, GoCmdNext, GoCmdPrev);
        FCmdFile := AFileName;
        if ModalDlg <> nil then
          ModalDlg.Close;
        Result := True;
      end;
    end else
    begin
      if ShowImage(AFileName, 0, False, ASlideDirect) then begin
        if optPrecache and (ACacheDirect <> 0) then
          SyncDelayed(IntIf(ACacheDirect > 0, SyncCmdCacheNext, SyncCmdCachePrev), optCacheDelay);
       {$ifdef Far3}
        vRedrawInfo.StructSize := SizeOf(vRedrawInfo);
       {$endif Far3}
        vRedrawInfo.TopPanelItem := AInfo.TopPanelItem;
        vRedrawInfo.CurrentItem := AIndex;
        FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, @vRedrawInfo);
        Result := True;
      end;
    end;
  end;


  procedure TReviewManager.SetScale(aSetMode :TScaleSetMode; aScaleMode :TScaleMode; AValue :TFloat);
  begin
    if FWinThread <> nil then
      if aSetMode = smSetMode then
        SendMessage(FWindow.Handle, CM_Scale, Byte(aSetMode), byte(aScaleMode))
      else
        SendMessage(FWindow.Handle, CM_Scale, Byte(aSetMode), TIntPtr(@AValue));
  end;


  procedure TReviewManager.InvalidateImage;
  begin
    if FWindow <> nil then
      SendMessage(FWindow.Handle, CM_Transform, cmtInvalidate, 0);
  end;


  procedure TReviewManager.SetImagePage(aPage :Integer);
  begin
    if FWindow <> nil then
      SendMessage(FWindow.Handle, CM_Transform, cmtSetPage, aPage);
  end;


  procedure TReviewManager.Rotate(ARotate :Integer);
  begin
    if FWindow <> nil then begin
      SetTempMsg(GetMsg(strRotate));
      SendMessage(FWindow.Handle, CM_Transform, cmtRotate, ARotate);
    end;
  end;


  procedure TReviewManager.Orient(AOrient :Integer);
  begin
    if FWindow <> nil then begin
      SetTempMsg(GetMsg(strRotate));
      SendMessage(FWindow.Handle, CM_Transform, cmtOrient, AOrient);
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

    procedure LocNavigate(AOrig :Integer; AForward :Boolean);
    begin
      if not Navigate(AOrig, AForward, optEffectOnManual) then
        Beep;
    end;

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

    procedure LocMovePage(ADX, ADY :Integer);
    begin
      if not CurImage.FMovie then begin
        with Window.ClientRect do begin
          ADX := ADX * (Right - Left);
          ADY := ADY * (Bottom - Top);
        end;
        LocMove(ADX, ADY);
      end;
    end;

    procedure LocShowInfo;
    begin
      optShowInfo := 1 - optShowInfo;
//    ShowDecoderInfo;
      InvalidateImage;
      PluginConfig(True)
    end;

    procedure LocSwitchBack;
    begin
      optTranspBack := not optTranspBack;
      InvalidateImage;
    end;

    procedure LocSwitchTile;
    begin
      optTileMode := not optTileMode;
      InvalidateImage;
    end;

    procedure LocSwitchSmooth;
    begin
      optSmoothScale := not optSmoothScale;
      SetTempMsg('Smooth mode: ' + StrIf(optSmoothScale, 'On', 'Off'), False);  {!Localize}
      InvalidateImage;
    end;

    procedure LocSetSmoothMode(aMode :Integer);
    const
      cModeNames :array[0..7] of TSTring =
        ('Default', 'Low', 'High', 'Bilinear', 'Bicubic', 'Nearest', 'HQBilinear', 'HQBicubic');
    begin
      optSmoothScale := True;
      optSmoothMode := aMode;
      SetTempMsg('Smooth mode: ' + Int2Str(optSmoothMode) + ' - ' + cModeNames[optSmoothMode], False);  {!Localize}
      InvalidateImage;
    end;


    procedure LocSwitchSmoothMode;
    var
      vNewMode :Integer;
    begin
      vNewMode := IntIf(optSmoothMode < InterpolationModeHighQualityBicubic, optSmoothMode + 1, InterpolationModeBilinear);
      if vNewMode = InterpolationModeNearestNeighbor then
        Inc(vNewMode);
      LocSetSmoothMode( vNewMode );
    end;


    procedure LocSelectCurrent(AMode :Integer);
    var
      vInfo :TPanelInfo;
      vIndex :Integer;
      vSelected :Boolean;
    begin
      if CheckSync(CurImage.FName, vSelected) then begin
        if FarGetPanelInfo(True, vInfo) then begin
          vIndex := vInfo.CurrentItem;
          if (AMode = 1) or ((AMode = -1) and not vSelected) then
            FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, vIndex, Pointer(PPIF_SELECTED) )
          else
            FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, vIndex, nil );
          CurImage.FSelected := -1;
          FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
        end;
      end else
        Beep;
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
      if (AKey >= byte('A')) and (AKey <= byte('Z')) then
        AKey := AKey + 32;

      case AKey of
        { Смещение }
        Key_Left, Key_ShiftLeft, Key_NumPad4, Key_ShiftNumPad4:
          if not CurImage.FMovie then
            LocMove(LocStep(+cMoveStep),  0)
          else
            LocGotoPos(LocStep(+cMoveStepSec), 0);

        Key_Right, Key_ShiftRight, Key_NumPad6, Key_ShiftNumPad6:
          if not CurImage.FMovie then
            LocMove(LocStep(-cMoveStep),  0)
          else
            LocGotoPos(LocStep(-cMoveStepSec), 0);

        Key_Up, Key_ShiftUp, Key_NumPad8, Key_ShiftNumPad8:
          if not CurImage.FMovie then
            LocMove( 0, LocStep(+cMoveStep))
          else
            ChangeVolume(LocStep(+10), 0);

        Key_Down, Key_ShiftDown, Key_NumPad2, Key_ShiftNumPad2:
          if not CurImage.FMovie then
            LocMove( 0, LocStep(-cMoveStep))
          else
            ChangeVolume(LocStep(-10), 0);

        Key_CtrlLeft, Key_CtrlNumPad4:
          if not CurImage.FMovie then
            LocMove(+MaxInt,  0)
          else
            LocGotoPos(0, 0);

        Key_CtrlRight, Key_CtrlNumPad6:
          if not CurImage.FMovie then
            LocMove(-MaxInt,  0)
          else
            LocGotoPos(0, MaxInt);

        Key_CtrlUp, Key_CtrlNumPad8:
          if not CurImage.FMovie then
            LocMove( 0, +MaxInt)
          else
            ChangeVolume(0, 100);

        Key_CtrlDown, Key_CtrlNumPad2:
          if not CurImage.FMovie then
            LocMove( 0, -MaxInt)
          else
            ChangeVolume(0, 0);

        Key_AltLeft   : LocMovePage(+1,  0);
        Key_AltRight  : LocMovePage(-1,  0);
        Key_AltUp     : LocMovePage( 0, +1);
        Key_ALtDown   : LocMovePage( 0, -1);

        { Переключение изображений }
        Key_Home, Key_ShiftHome, Key_NumPad7 : LocNavigate(1, True);
        Key_End, Key_ShiftEnd, Key_NumPad1   : LocNavigate(2, False);
        Key_PgDn, Key_ShiftPgDn, Key_NumPad3 : LocNavigate(0, True);
        Key_PgUp, Key_ShiftPgUp, Key_NumPad9 : LocNavigate(0, False);

        { Переключение страниц }
        Key_CtrlHome, Key_CtrlNumPad7 : SetImagePage(0);
        Key_CtrlEnd, Key_CtrlNumPad1  : SetImagePage(MaxInt);
        Key_CtrlPgDn, Key_CtrlNumPad3 : LocGotoPage(+1);
        Key_CtrlPgUp, Key_CtrlNumPad9 : LocGotoPage(-1);

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
        KEY_CtrlS, Byte('s') : SlideShow(-1);
        KEY_AltS             : SlideShowQueryDelay;
        KEY_CtrlI, Byte('i') : LocShowInfo;
        KEY_CtrlB, Byte('b') : LocSwitchBack;
        KEY_CtrlT, Byte('t') : LocSwitchTile;
        KEY_CtrlQ, Byte('q') : LocSwitchSmooth;
        KEY_AltQ             : LocSwitchSmoothMode;
        KEY_ALT0..KEY_ALT7   : LocSetSmoothMode(AKey - KEY_ALT0);

        KEY_CtrlF, Byte('f') :
          SetFullscreen(FWindow.FWinMode = wmNormal);

        Byte('.')           : Rotate(1); { > - Поворот по часовой }
        Byte(',')           : Rotate(2); { < - Поворот против часовой }
        Key_Alt + Byte('.') : Rotate(3); { Alt> - X-Flip }
        Key_Alt + Byte(',') : Rotate(4); { Alt< - Y-Flip }

        Key_Ins     : LocSelectCurrent(-1);
        Key_Del     : LocSelectCurrent(0);

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
        Navigate(0, ADelta < 0, optEffectOnManual)
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


  procedure TReviewManager.SetForceFile(const aName :TString; aMode :Integer);
  begin
    FForceFile := aName;
    FForceMode := aMode;
  end;


  function TReviewManager.ProcessCommand :Boolean;
  var
    vInfo :TPanelInfo;
    vStr :TString;
  begin
    Result := False;
    if FCommand = GoCmdNone then
      Exit;

    if FarGetPanelInfo(True, vInfo) then begin

      SetForceFile(FCmdFile, 1);

      vStr :=
        'Keys("Esc") ' +
        'Panel.SetPos(0, ' + FarStrToMacro(FCmdFile) + ') ' +
        'Keys("F3")';
      if FCommand = GoCmdNextSlide then
        vStr := vStr + ' Plugin.Call("' + PlugIdToStr(cPluginID) + '", "SlideShow", 1)';

      FarPostMacro(vStr, 0);
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
      GetMsg(strMSlideShow),
      PTChar(vDecodersStr),
      GetMsg(strMColors)
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : ReviewConfig;
        1 : SlideShowConfig;
        2 : DecodersConfig(Review);
        3 : ColorMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


end.


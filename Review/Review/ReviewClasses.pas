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
    ActiveX,
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
    ReviewTags,
    ReviewVideo,
    ReviewDecoders,
    ReviewGDIPlus;

  const
    CM_SetImage     = $B000;
    CM_Transform    = $B001;
    CM_SetPage      = $B002; { ������ ������������ ���������������� ����������� }
    CM_SetWinPos    = $B003;
    CM_SetVisible   = $B004;
    CM_SetMode      = $B005;
    CM_Move         = $B006;
    CM_Scale        = $B007;
    CM_Sync         = $B008;
    CM_TempMsg      = $B009;
    CM_SlideShow    = $B00A;
    CM_ReleaseImage = $B00B;
    CM_RenderImage  = $B00C;  {Thumbs: ��������� ���������� ������ (ThumbThread -> ThumbsWindow) }
    CM_Select       = $B00D;  {Thumbs: ��������� �����������}
    CM_ShowInfo     = $B00E;
    CM_SetAudio     = $B00F;

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
    TImageWindow = class;
    TReviewWinThread = class;
    TReviewImage = class;
    TReviewManager = class;

    TReviewWindow = class;
    TReviewWindowClass = class of TReviewWindow;


    PSetImageRec = ^TSetImageRec;
    TSetImageRec = packed record
      Image   :TReviewImage;
      WinMode :Integer;
      WinRect :TRect;
      Direct  :Integer;
    end;

    TCmdObject = class(TStrList)
    public
      constructor Create(ACmd :Integer; const AStr :TString); overload;
      procedure Execute; virtual; abstract;

    protected
      FCommand  :Integer;
    end;

    TReviewWinThread = class(TThread)
    public
      constructor Create(aClass :TReviewWindowClass);
      procedure Execute; override;

    private
      FWinClass :TReviewWindowClass;
      FWindow   :TReviewWindow;

    public
      property Window :TReviewWindow read FWindow;
    end;


    TFullscreenWindow = class(TMSWindow)
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
    private
      procedure HideWindow;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
    end;

    { ������� ����� ��� TImageWindow � TThumbsWindow}

    TReviewWindow = class(TCustomWindow)
    public
      destructor Destroy; override;

      procedure ShowWindow;
      procedure HideWindow;
      procedure SetWindowBounds(const aRect :TRect);

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      function Idle :Boolean; virtual;
      function WndIdle :Boolean;
      procedure ErrorHandler(E :Exception); override;

    protected
      FWinBPP       :Integer;
      FWinMode      :TWinMode;
      FWinRect      :TRect;

      FColor        :Integer;
      FBrush        :HBrush;

      FParentRect   :TRect;
      FLastArea     :Integer;
      FClipped      :Boolean;
      FClipStart    :DWORD;

      FNeedSync     :Boolean;
      FSyncStart    :DWORD;
      FSyncCmd      :Integer;
      FSyncDelay    :Integer;

      FTempMsg      :TString;
      FMsgStart     :DWORD;
      FMsgDelay     :Integer;

      FFullScreenWin :TFullscreenWindow;

      procedure SetColor(AColor :Integer);
      function CalcWinRect :TRect;
      procedure SetWinMode(AMode :TWinMode);
      procedure SetFullscreen(AOn :Boolean);
      function GetMousePos :TPoint;
      procedure SetTempMsg(const AMsg :TString; aInvalidate :Boolean = True);
      procedure InvalidateMsgRect;
      procedure DrawTempText(DC :HDC; const AStr :TString);

//    procedure WMNCHitTest(var Mess :TWMNCHitTest); message WM_NCHitTest;
      procedure WMMouseActivate(var Mess :TWMMouseActivate); message WM_MouseActivate;
      procedure WMMouseWheel(var Mess :TWMMouseWheel); message WM_MouseWheel;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure CMSetMode(var Mess :TMessage); message CM_SetMode;
      procedure CMSetWinPos(var Mess :TMessage); message CM_SetWinPos;
      procedure CMSetVisible(var Mess :TMessage); message CM_SetVisible;
      procedure CMTempMsg(var Mess :TMessage); message CM_TempMsg;
      procedure CMSync(var Mess :TMessage); message CM_Sync;

    public
      property WinMode :TWinMode read FWinMode;
    end;


    TImageWindow = class(TReviewWindow)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure PlayPause;
      function IsMedia :Boolean;
      function IsVideo :Boolean;
      function GetMediaState :Integer;
      function GetMediaLen :Integer;
      function GetMediaPos :Integer;
      procedure SetMediaPos(aMS :Integer);
      function GetMediaVolume :Integer;
      procedure SetMediaVolume(aVal :Integer);
      function GetAudioStream :Integer;
      function GetMediaSize :TSize;

      procedure RealignOSD;

    protected
      procedure PaintWindow(DC :HDC); override;
      function Idle :Boolean; override;

      procedure CMSetImage(var Mess :TMessage); message CM_SetImage;
      procedure CMReleaseImage(var Mess :TMessage); message CM_ReleaseImage;
      procedure CMTransform(var Mess :TMessage); message CM_Transform;
      procedure CMSetPage(var Mess :TMessage); message CM_SetPage;
      procedure CMMove(var Mess :TMessage); message CM_Move;
      procedure CMScale(var Mess :TMessage); message CM_Scale;
      procedure CMSlideShow(var Mess :TMessage); message CM_SlideShow;
      procedure CMShowInfo(var Mess :TMessage); message CM_ShowInfo;
      procedure CMSetAudio(var Mess :TMessage); message CM_SetAudio;
      procedure WMShowWindow(var Mess :TWMShowWindow); message WM_ShowWindow;
      procedure WMSize(var Mess :TWMSize); message WM_Size;
      procedure WMKeyDown(var Mess :TWMKeyDown); message WM_KeyDown;
      procedure WMLButtonDown(var Mess :TWMLButtonDown); message WM_LButtonDown;
      procedure WMRButtonDown(var Mess :TWMLButtonDown); message WM_RButtonDown;
      procedure WMRButtonUp(var Mess :TWMLButtonDown); message WM_RButtonUp;
      procedure WMMouseMove(var Mess :TWMMouseMove); message WM_MouseMove;
      procedure WMLButtonUp(var Mess :TWMLButtonUp); message WM_LButtonUp;
      procedure WMLButtonDblClk(var Mess :TWMLButtonDblClk); message WM_LButtonDblClk;

    private
      FImage        :TReviewImage;

      FDecoder      :TReviewDecoder;  { "Attached" decoder }
      FImageOk      :Boolean;

      FMode         :TScaleMode;      {  }
      FLnScale      :TFloat;          { ��������������� ������� }
      FScale        :TFloat;          { ������� }
      FDelta        :TPoint;          { �������� (������ �������� �� ������ ������) }
      FDeltaScale   :TFloat;          { ������� �������� }
      FMouseLock    :Integer;         { ��������������� �� ������� ���� }

      FSrcRect      :TRect;           { ������� ��������, ������� �� ������ (�.�. ������ ��������) }
      FDstRect      :TRect;           { ������� ������, ������������ �������� (�.�. ������ ������, �� �� ������) }
      FDstRect0     :TRect;           { ����������� ������������� ���� �������� �� ������ (�.�. ������ ��� ������ ������) }

      FDragged      :Boolean;
      FMousePos     :TPoint;

      FAnimate      :Boolean;
      FPageStart    :DWORD;

      FHiQual       :Boolean;
      FDraftMode    :Boolean;
      FDraftStart   :DWORD;

      FSlideStart   :DWORD;
      FSlideDelay   :Integer;

      FThumbStart   :DWORD;           { ��� ��������� �������� ������������� ��� ������� �������� }
      FResizeStart  :DWORD;           { ��� ��������� �������� ������������� ��� ��������������� }
      FResizeSize   :TSize;

      FUseWinSize   :Boolean;

      FVideoWin     :TVideoWindow;
      FInfoWin      :TInfoWindow;
     {$ifdef bVideoOSD}
      FControlWin   :TControlWindow;
     {$endif bVideoOSD}

      procedure RecalcRects;
      procedure MoveImage(DX, DY :Integer);
      procedure SetScale(aMode :TScaleMode; aLnScale, aScale :TFloat);
      procedure SetPage(aPage :Integer; ASize :PSize = nil);
      procedure SlideEffect(aOldImage :TReviewImage; const AOldSrcRect, AOldDstRect :TRect; ADirect :Integer);
      procedure DrawImage(DC :HDC; aImage :TReviewImage; const ASrcRect, ADstRect :TRect; ABuffered :Boolean);
      procedure DrawAddInfo(DC :HDC);

      procedure ReleaseDecoder;
      procedure ReleaseImage;
      procedure AttachDecoder(ADecoder :TReviewDecoder; aHandle :THandle);
      function AsyncDecode :Boolean;

      procedure SetOSD(aOn :Boolean);
      procedure UpdateInfoWin;

    public
      property Image :TReviewImage read FImage;
      property Scale :TFloat read FScale;
      property ScaleMode :TScaleMode read FMode;
      property SlideDelay :Integer read FSlideDelay;
    end;


    TTaskState = (
      tsNew,
      tsProceed,
      tsReady,
      tsCancelled
    );

    TTask = class(TBasis)
    public
      constructor CreateEx(AImage :TReviewImage; AFrame :Integer; const ASize :TSize);
      destructor Destroy; override;

      function _AddRef :Integer;
      function _Release :Integer;

    private
      FRefCount   :Integer;
      FImage      :TReviewImage;
      FFrame      :Integer;
      FSize       :TSize;
      FDecodeTime :Integer;
      FThumb      :HBitmap;
      FState      :TTaskState;
      FError      :TString;
      FOnTask     :TNotifyEvent;
      FNext       :TTask;
    end;


    TReviewImage = class(TReviewImageRec)
    public
      constructor CreateEx(const aName :TString);
      destructor Destroy; override;

      function TryOpen(AForce :Boolean) :Boolean;
      function TryOpenBy(ADecoder :TReviewDecoder; AForce :Boolean) :Boolean;
      procedure DecodePage(ASize :TSize; AFirstOpen :Boolean; AFastScroll :Boolean = False);
      procedure UpdateBitmap;
      function LockSource :Boolean;
      procedure UnLockSource;
      function CanReleaseSource :Boolean;
      procedure ReleaseSource;

    private
//    FDecoder     :TReviewDecoder;    { ��������� ������� }
//    FBitmap      :TReviewBitmap;     { Bitmap (������ ��� �� Selfdraw) }
      FIsThumbnail :Boolean;
      FSelected    :Integer;

      FOpened      :Boolean;
      FSrcLock     :Integer;
      FOpenTime    :Integer;
      FDecodeTime  :Integer;
      FDecodeError :TString;

      FTags        :TReviewTags;
      FInfoInited  :Boolean;

      FAsyncTask   :TTask;

      procedure SetAsyncTask(const ASize :TSize);
      function CheckAsyncTask :Boolean;
      procedure CancelTask;

      procedure CollectInfo;

    public
      property Tags :TReviewTags read FTags;
      property Page :Integer read FPage;
      property Pages :Integer read FPages;
      property Orient :Integer read FOrient;
      property Decoder :TReviewDecoder read FDecoder;
      property OpenTime :Integer read FOpenTime;
      property DecodeTime  :Integer read FDecodeTime;
    end;


    TReviewManager = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure InitSubplugins;
      procedure LoadBackground;

      function ShowImage(const AFileName :TString; AMode :Integer; AForce :Boolean = False; ADirect :Integer = 0) :Boolean;
      procedure InvalidateImage;
      procedure SetImagePage(aPage :Integer);
      function Navigate(AOrig :Integer; AForward :Boolean; ASlideShow :Boolean = False) :Boolean;
      function NavigateTo(const AFileName :TString{; AForward :Boolean; ASlideShow :Boolean = False}) :Boolean;
      procedure Redecode(AMode :TRedecodeMode = rmSame; aShowInfo :Boolean = True);
      procedure Rotate(ARotate :Integer);
      procedure Orient(AOrient :Integer);
      function Save(const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;
      procedure SetFullscreen(aMode :Integer);
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

      function ProcessCommand :Boolean;
      procedure PluginSetup;

      function MouseWheel(ADelta :Integer) :Boolean;
      procedure SetScale(aSetMode :TScaleSetMode; aScaleMode :TScaleMode; AValue :TFloat);

      procedure SetForceFile(const aName :TString; aMode :Integer);

     {$ifdef bThumbs}
      procedure OpenThumbsView;
      function ShowThumbs(const AFolder, ACurFile :TString) :Boolean;
      procedure CloseThumbWindow;
      procedure ThumbSyncDelayed(aCmd, aDelay :Integer);
      procedure ThumbChangePath(const APath, ACurFile :TString; aSyncPanel :Boolean);
      procedure ThumbView(const AFileName :TString);
      function ThumbRedecode(AMode :TRedecodeMode; ADecoder :TReviewDecoder; const AFileName :TString) :Boolean;
      procedure ThumbSetSize(aSize :Integer);
     {$endif bThumbs}

      procedure MediaSeek(aOrigin :TSeekOrigin; aValue :Integer);
      procedure ChangeAudioStream(aOrigin :TSeekOrigin; aValue :Integer);

    private
      FDecoders     :TObjList;           { ������ ��������� }
      FWinThread    :TReviewWinThread;
      FWindow       :TImageWindow;
      FCommand      :Integer;            { ��� ��������� �� ��������� ������� }
      FCmdFile      :TString;            { -/-/- }
      FCache        :TObjList;           { �������������� ����������� }
      FFavDecoder   :TReviewDecoder;     { �������������� ������� }

      FBackBmp      :TReviewBitmap;

      FForceFile    :TString;            { ���� ��� �������������� ��������� � ViewerEvent }
      FForceMode    :Integer;

      FLastDecode   :DWORD;              { ��� ������� ��������� }

//    FScreen        :THandle;
//    FCursor        :HCursor;
      FOldTitle      :TString;
      FDecodeStart   :DWORD;
      FDecodeStep    :Integer;
      FDecodeFile    :TString;

     {$ifdef bThumbs}
      FThumbsThread  :TReviewWinThread;
      FThumbsWindow  :TReviewWindow;     { TThumbsWindow }
     {$endif bThumbs}

      function CanShowImage(const AFileName :TString) :Boolean;
      procedure DisplayImage(aImage :TReviewImage; AMode :Integer; ADirect :Integer = 0);
      function NavigateLow(AInfo :TPanelInfo; AIndex :Integer; const AFileName :TString; ASlideDirect, ACacheDirect :Integer) :Boolean;
      function CheckSync(const aName :TString; var ASelected :Boolean) :Boolean;

      procedure DecodeImage(aImage :TReviewImage; const ASize :TSize; AFastScroll :Boolean = False; APrecache :Boolean = False);
      procedure CacheImage(aImage :TReviewImage);
      function FindInCache(const aFileName :TString) :TReviewImage;
      procedure ClearCache;
      procedure ShowDecoderInfo;
      function CalcWinRectAs(AMode :Integer) :TRect;
      function CalcWinSize(AMode :Integer = -1) :TSize;

//    procedure WaitCursor(ASet :Boolean);
      procedure ShowDecodeProgress(ADecoder :TReviewDecoder; APercent :Integer);
      procedure MyDecodeCallback(ASender :Pointer; APercent :Integer; var AContinue :Boolean);

      function GetImage :TReviewImage;

    public
      property Decoders :TObjList read FDecoders;
      property CurImage :TReviewImage read GetImage;
      property Window :TImageWindow read FWindow;
      property ForceFile :TString read FForceFile;
      property ForceMode :Integer read FForceMode;
      property FavDecoder :TReviewDecoder read FFavDecoder;
     {$ifdef bThumbs}
      property ThumbWindow :TReviewWindow read FThumbsWindow;
     {$endif bThumbs}
    end; {TReviewManager}


  var Review :TReviewManager;


  { ��������� ���������... }

  type
    TModalStateDlg = class(TFarDialog)
    public
      procedure UpdateWindowVisible(AWin :TReviewWindow);
      procedure SetError(const aMess :TString);
      procedure SetTitle(const aTitle :TString);

    protected
      procedure InitDialog; override;
      procedure ErrorHandler(E :Exception); override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    protected
      FErrorStr  :TString;
      FPostKey   :Integer;
      FHidden    :Boolean;  { ���� ����������� �������� ������... }

      procedure ResizeDialog;
    end;


    TViewModalDlg = class(TModalStateDlg)
    public
      procedure UpdateTitle;

    protected
      procedure Prepare; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; override;

    private
      FQuick     :Boolean;  { QuickView. �� ������������. }
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
   {$ifdef bThumbs}
    ReviewThumbs,
    ReviewDlgThumb,
   {$endif bThumbs}
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


  function FarPanelCurrentFileName(aPanel :THandle = PANEL_ACTIVE) :TString;
  begin
    Result := AddFileName(FarPanelGetCurrentDirectory(aPanel), FarPanelItemName(aPanel, FCTL_GETCURRENTPANELITEM, 0));
  end;


  function ConsolePosToClientPoint(AX, AY :Integer) :TPoint;
    { ������������� ���������� ���������� � ���������� ���������� ������� ���� }
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


  procedure ShowProgress(const ATitle, AName :TString; APercent :Integer);
  const
    cWidth = 60;
  var
    vMess :TString;
  begin
    vMess := AName;
    if Length(vMess) > cWidth then
      vMess := Copy(vMess, 1, cWidth);
    if APercent <> -1 then
      vMess := vMess + #10 + GetProgressStr(cWidth, APercent);
    ShowMessage(aTitle, vMess, 0);
  end;



  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..1024] of TChar;
  begin
    FillZero(vBuf, SizeOf(vBuf));
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;
  end;


  procedure SetConsoleTitleStr(const ATitle :TString);
  begin
    SetConsoleTitle(PTChar(ATitle));
  end;


 {-----------------------------------------------------------------------------}
 { TRenderThread                                                               }
 {-----------------------------------------------------------------------------}

  constructor TTask.CreateEx(AImage :TReviewImage; AFrame :Integer; const ASize :TSize);
  begin
    inherited Create;
    FImage := AImage;
    FFrame := AFrame;
    FSize  := ASize;
  end;


  destructor TTask.Destroy; {override;}
  begin
    if FThumb <> 0 then
      DeleteObject(FThumb);
    inherited Destroy;
  end;


  function TTask._AddRef :Integer;
  begin
    Result := InterlockedIncrement(FRefCount);
  end;


  function TTask._Release :Integer;
  begin
    Result := InterlockedDecrement(FRefCount);
    if Result = 0 then
      Destroy;
  end;


  type
    TRenderThread = class(TThread)
    public
      constructor Create;
      destructor Destroy; override;

      procedure Execute; override;

      procedure AddTask(ATask :TTask);
      function CheckTask(ATask :TTask) :Boolean;
      procedure CancelTask(ATask :TTask);

    private
      FEvent   :THandle;
      FTaskCS  :TRTLCriticalSection;
      FTask    :TTask;

      function DoTask :Boolean;
      procedure NextTask;
      procedure Render(ATask :TTask);
      procedure MyDecodeCallback(ASender :Pointer; APercent :Integer; var AContinue :Boolean);
    end;


  constructor TRenderThread.Create;
  begin
    FEvent := CreateEvent(nil, True, False, nil);
    InitializeCriticalSection(FTaskCS);
    inherited Create(False);
  end;


  destructor TRenderThread.Destroy; {override;}
  begin
    while FTask <> nil do
      NextTask;
    CloseHandle(FEvent);
    DeleteCriticalSection(FTaskCS);
    inherited Destroy;
  end;


  procedure TRenderThread.Execute;
  var
    vRes :DWORD;
  begin
    CoInitialize(nil);
    try
      while not Terminated do begin
        vRes := WaitForSingleObject(FEvent, 5000);
//      TraceF('WaitRes = %d', [Byte(vRes)]);
        if Terminated then
          break;

        if vRes = WAIT_OBJECT_0 then begin
          ResetEvent(FEvent);
          while DoTask do;
        end;
      end;
    finally
      CoUninitialize;
    end;
  end;


  function TRenderThread.DoTask :Boolean;
  begin
    Result := False;

    EnterCriticalSection(FTaskCS);
    try
      while (FTask <> nil) and (FTask.FState = tsCancelled) do
        NextTask;
      if FTask = nil then
        Exit;
      FTask.FState := tsProceed;
      FTask.FImage._AddRef;
      if Assigned(FTask.FOnTask) then
        FTask.FOnTask(nil);
    finally
      LeaveCriticalSection(FTaskCS);
    end;

    Render(FTask);

    EnterCriticalSection(FTaskCS);
    try
      FTask.FImage._Release;
      FTask.FState := tsReady;
      if Assigned(FTask.FOnTask) then
        FTask.FOnTask(nil);
      NextTask;
    finally
      LeaveCriticalSection(FTaskCS);
    end;

    Result := True;
  end;


  procedure TRenderThread.NextTask;
  var
    vTask :TTask;
  begin
    vTask := FTask;
    FTask := vTask.FNext;
    vTask.FNext := nil;
    vTask._Release;
  end;


  procedure TRenderThread.MyDecodeCallback(ASender :Pointer; APercent :Integer; var AContinue :Boolean);
  begin
    AContinue := TTask(ASender).FState <> tsCancelled;
  end;


  procedure TRenderThread.Render(ATask :TTask);
  var
    vImage :TReviewImage;
    vStart :DWORD;
    vIsThumbnail :Boolean;
  begin
    try
      vImage := ATask.FImage;
      vImage.LockSource;
      try
        vStart := GetTickCount;
        if vImage.FDecoder.pvdPageDecode(vImage, ATask.FSize.CX, ATask.FSize.CY, dmImage, MyDecodeCallback, ATask) then
          try
            ATask.FThumb := vImage.FDecoder.GetBitmapHandle(vImage, vIsThumbnail);
          finally
            vImage.FDecoder.pvdPageFree(vImage);
          end;
        ATask.FDecodeTime := TickCountDiff(GetTickCount, vStart);
      finally
        vImage.UnLockSource;
      end;
    except
      on E :Exception do
        ATask.FError := E.Message;
    end;
  end;


  procedure TRenderThread.AddTask(ATask :TTask);
  var
    vTask :TTask;
  begin
    EnterCriticalSection(FTaskCS);
    try
      if FTask = nil then
        FTask := ATask
      else begin
        vTask := FTask;
        while vTask.FNext <> nil do
          vTask := vTask.FNext;
        vTask.FNext := ATask;
      end;
      ATask._AddRef;
    finally
      LeaveCriticalSection(FTaskCS);
    end;

    SetEvent(FEvent);
  end;


  function TRenderThread.CheckTask(ATask :TTask) :Boolean;
  begin
    EnterCriticalSection(FTaskCS);
    try
      Result := ATask.FState = tsReady;
    finally
      LeaveCriticalSection(FTaskCS);
    end;
  end;


  procedure TRenderThread.CancelTask(ATask :TTask);
  begin
    EnterCriticalSection(FTaskCS);
    try
      ATask.FState := tsCancelled;
      ATask.FOnTask := nil;
    finally
      LeaveCriticalSection(FTaskCS);
    end;
  end;


  var
    GRenderThread :TRenderThread;


  procedure InitRenderThread;
  begin
    if GRenderThread = nil then
      GRenderThread := TRenderThread.Create;
  end;


  procedure DoneRenderThread;
  begin
    if GRenderThread <> nil then begin
      GRenderThread.Terminate;
      SetEvent(GRenderThread.FEvent);
      GRenderThread.WaitFor;
      FreeObj(GRenderThread);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { ������ ������� ��������� ��������                                           }
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
 { ������ ���������� ���������                                                 }
 {-----------------------------------------------------------------------------}

  procedure TModalStateDlg.InitDialog; {override;}
  begin
    ResizeDialog;
  end;


  procedure TModalStateDlg.ResizeDialog;
  var
    vSize :TSize;
    vRect :TSmallRect;
  begin
    vSize := FarGetWindowSize;
    vSize.CY := 1; vSize.CX := 1;
    SetDlgPos(0, 0, vSize.CX, vSize.CY);

    vRect := SBounds(0, 0, vSize.CX, vSize.CY);
    SendMsg(DM_SETITEMPOSITION, 0, @vRect);
  end;


  procedure TModalStateDlg.SetTitle(const aTitle :TString);
  begin
    SetText(0, aTitle);
  end;


  procedure TModalStateDlg.SetError(const aMess :TString);
  begin
    FErrorStr := aMess;
    Close;
  end;


  procedure TModalStateDlg.ErrorHandler(E :Exception); {override;}
  begin
    SetError( E.Message );
  end;


  function TModalStateDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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


  procedure TModalStateDlg.UpdateWindowVisible(AWin :TReviewWindow);
  var
    vWinInfo :TWindowInfo;
  begin
    if FarGetWindowInfo(-1, vWinInfo) then begin
      if (vWinInfo.WindowType = WTYPE_DIALOG) and (THandle(vWinInfo.ID) = Handle) then begin
        SendMessage(AWin.Handle, CM_SetVisible, 1, 0);
        FHidden := False;
      end else
      begin
        SendMessage(AWin.Handle, CM_SetVisible, 0, 0);
        FHidden := True;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCmdObject                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TCmdObject.Create(ACmd :Integer; const AStr :TString);
  begin
    inherited Create;
    FCommand := ACmd;
    if AStr <> '' then
      Add(AStr);
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


  procedure TFullscreenWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
//  FillRect(Mess.DC, ClientRect, FBrush);
    Mess.Result := 1;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewWinThread                                                            }
 {-----------------------------------------------------------------------------}

  constructor TReviewWinThread.Create(aClass :TReviewWindowClass);
  begin
    inherited Create(False);
    FWinClass := aClass;
  end;


  procedure TReviewWinThread.Execute; {override;}
  var
    vMsg :TMsg;
  begin
    PeekMessage(vMsg, 0, WM_USER, WM_USER, PM_NOREMOVE); { Create message queue }

    CoInitialize(nil);
    FWindow := FWinClass.Create;
    try

      while not Terminated do begin
        while PeekMessage(vMsg, 0 {FWindow.Handle}, 0, 0, PM_REMOVE) do begin
          TranslateMessage(vMsg);
          DispatchMessage(vMsg);
        end;
        if FWindow.WndIdle then
          Sleep(1);
      end;

      if FWindow.FFullScreenWin <> nil then
        FWindow.FFullScreenWin.HideWindow;
      FWindow.HideWindow;

    finally
      FreeObj(FWindow);
      CoUninitialize;
    end;
  end;

 {-----------------------------------------------------------------------------}
 { TReviewWindow                                                               }
 {-----------------------------------------------------------------------------}

  destructor TReviewWindow.Destroy; {override;}
  begin
    FreeObj(FFullScreenWin);
    if FBrush <> 0 then
      DeleteObject(FBrush);
    inherited Destroy;
  end;


  procedure TReviewWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams); {CreateWindowEx}
    AParams.WndParent := hFarWindow;
    AParams.Style := WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
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
//  Show(SW_SHOW);
    Windows.SetWindowPos(FHandle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);

    SetForegroundWindow(hConsoleTopWnd);
  end;


  procedure TReviewWindow.HideWindow;
  begin
    Show(SW_Hide);
//  if GNeedWriteSizeSettings then
//    FarAdvControl(ACTL_SYNCHRO, scmSaveSettings);
//  GNeedWriteSizeSettings := False;
  end;


  procedure TReviewWindow.SetColor(AColor :Integer);
  begin
    if (FBrush = 0) or (FColor <> AColor) then begin
      if FBrush <> 0 then
        DeleteObject(FBrush);
      FColor := AColor;
      FBrush := CreateSolidBrush(FColor);
    end;
  end;


  procedure TReviewWindow.SetWindowBounds(const aRect :TRect);
  begin
//  Trace('%s SetWindowBounds...', [ClassName]);
    SetBounds(aRect, 0);
    if not FClipped then
      FClipStart := GetTickCount;
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


  procedure TReviewWindow.SetWinMode(AMode :TWinMode);
  begin
//  TraceF('TImageWindow.SetWinMode: %d', [byte(AMode)]);

    if AMode <> FWinMode then begin
      FWinMode := AMode;
//    if AMode <> wmQuickView then begin
//      optFullscreen := AMode = wmFullscreen;
//      InterlockedIncrement(OptionsRevision);
//    end;

      if FWinMode = wmFullscreen then begin
        Assert(FFullScreenWin = nil);

        FFullScreenWin := TFullscreenWindow.Create;
        FFullScreenWin.SetBounds(CalcWinRect, 0);

        Windows.SetWindowPos(FFullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW );
        SetForegroundWindow(hConsoleTopWnd);
        Windows.SetWindowPos(FFullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE );

        SetParent(Handle, FFullScreenWin.Handle);
        SetBounds(FFullScreenWin.ClientRect, 0);
      end else
      begin
        SetParent(Handle, hFarWindow);
        SetWindowBounds(CalcWinRect);
        FreeObj(FFullScreenWin);
      end;
    end;
  end;


  procedure TReviewWindow.SetFullscreen(AOn :Boolean);
  begin
    if AOn then
      SetWinMode(wmFullscreen)
    else
      SetWinMode(wmNormal);
  end;


  function TReviewWindow.GetMousePos :TPoint;
  begin
    Windows.GetCursorPos(Result);
    ScreenToClient(Handle, Result);
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


//procedure TImageWindow.WMNCHitTest(var Mess :TWMNCHitTest); {message WM_NCHitTest;}
//begin
//  Mess.Result := HTTRANSPARENT;
//end;


  procedure TReviewWindow.WMMouseActivate(var Mess :TWMMouseActivate); {message WM_MouseActivate;}
  begin
    inherited;

    if FWinMode = wmFullscreen then begin
      if FFullScreenWin <> nil then begin
//      TraceF('Make topmost. FullScreenWin=%x, Console=%x, Msg.TopLevel=%x, Msg.HitTest=%d, Msg.MouseMsg=%d, Msg.Result=%d',
//        [FullScreenWin.Handle, hConsoleTopWnd, Mess.TopLevel, Mess.HitTestCode, Mess.MouseMsg, Mess.Result]);
        Windows.SetWindowPos(FFullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE );
        SetForegroundWindow(hConsoleTopWnd);
        Windows.SetWindowPos(FFullScreenWin.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE );
      end;
    end else
    begin
//    TraceF('Make active2 %x...', [hConsoleTopWnd]);
      SetForegroundWindow(hConsoleTopWnd);
    end;

    Mess.Result := MA_NoActivate;
  end;



  procedure TReviewWindow.WMMouseWheel(var Mess :TWMMouseWheel); {message WM_MouseWheel;}
  begin
    inherited;
   {$ifdef bWinWheel}
    Review.MouseWheel(IntIf(Mess.WheelDelta > 0, 1, -1));
   {$endif bWinWheel}
  end;


  procedure TReviewWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
//  FillRect(Mess.DC, ClientRect, FBrush);
    Mess.Result := 1;
  end;


  procedure TReviewWindow.CMSetMode(var Mess :TMessage); {message CM_SetMode;}
  begin
    if FWinMode <> wmQuickView then
      SetFullscreen( Mess.wParam = 1 );
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
      if FFullscreenWin <> nil then
        FFullscreenWin.Show(SW_SHOWNA)
      else
        ShowWindow
    end else
    begin
      if FFullscreenWin <> nil then
        FFullscreenWin.HideWindow
      else
        HideWindow;
    end;
  end;


  procedure TReviewWindow.CMTempMsg(var Mess :TMessage); {message CM_TempMsg;}
  begin
    SetTempMsg(TString(Mess.lParam), Mess.WParam = 1);
  end;


  procedure TReviewWindow.CMSync(var Mess :TMessage); {message CM_Sync;}
  begin
    FNeedSync  := True;
    FSyncStart := GetTickCount;
    FSyncCmd   := Mess.wParam;
    FSyncDelay := Mess.lParam;
  end;


  procedure TReviewWindow.ErrorHandler(E :Exception); {override;}
  begin
    SetTempMsg(E.Message);
    Beep;
  end;


  function TReviewWindow.WndIdle :Boolean;
  begin
    try
      Result := Idle;
    except
      on E :Exception do begin
        ErrorHandler(E);
        Result := True;
      end;  
    end;
  end;


  function TReviewWindow.Idle :Boolean;
  var
    vRect :TRect;
    vArea :Integer;
  begin
    Windows.GetClientRect(hFarWindow, vRect);
    if IsWindowVisible(Handle) and not RectEquals(vRect, FParentRect) then begin
      { ������������ ������ ����, ��� ��������� ���� FAR }
      FParentRect := vRect;
      if not RectEmpty(vRect) then begin
        if FWinMode = wmNormal then
          SetWindowBounds(CalcWinRect)
        else
        if FWinMode = wmQuickView then
          FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateWin);
      end;    
    end;

    if FWinMode = wmQuickView then begin
      vArea := FarGetMacroArea;
      if vArea <> FLastArea then begin
        { ������/���������� ���� �����������, ��� ��������� MacroArea (��� QuickView) }
        FLastArea := vArea;
        if vArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}] then begin
          Show(SW_SHOWNA);
          FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateWin);
        end else
          Show(SW_HIDE);
      end;
    end;

    if FWinMode = wmFullscreen then
      { ������ FullScreen ���� �� Topmost, ���� FAR ������ ����� }
      if not IsActiveConsole and (FFullScreenWin <> nil) and (GetWindowLong(FFullScreenWin.Handle, GWL_EXSTYLE) and WS_EX_TOPMOST <> 0) then begin
//      TraceF('Make no topmost. FullScreenWin=%x, Console=%x...', [FullScreenWin.Handle, hConsoleTopWnd]);
        Windows.SetWindowPos(FFullScreenWin.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      end;

    if FNeedSync and (TickCountDiff(GetTickCount, FSyncStart) > FSyncDelay) and (GLockSync = 0) and not ScrollKeyPressed then begin
      { ����������� ����� � ������� ������ (��� ���������� QuickView ��� ��� ���������������� �������������)... }
      FNeedSync := False;
      FarAdvControl(ACTL_SYNCHRO, FSyncCmd);
    end;

    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 { TImageWindow                                                                }
 {-----------------------------------------------------------------------------}

  constructor TImageWindow.Create; {override;}
  begin
    inherited Create;
  end;


  destructor TImageWindow.Destroy; {override;}
  begin
   {$ifdef bVideoOSD}
    FreeObj(FControlWin);
   {$endif bVideoOSD}
    FreeObj(FVideoWin);
    FreeObj(FInfoWin);

    ReleaseImage;
    ReleaseDecoder;
    inherited Destroy;
  end;


  procedure TImageWindow.ReleaseDecoder;
  begin
    if FDecoder <> nil then begin
      FDecoder.pvdDisplayDone(FHandle);
      FDecoder := nil
    end;
  end;


  procedure TImageWindow.ReleaseImage;
  begin
    if FImage <> nil then begin
      FImage.CancelTask;
      if (FDecoder <> nil) and FImage.FSelfdraw then
        FDecoder.pvdDisplayClose(FImage);
      FreeImage(FImage);
      FImageOk := False;
    end;
  end;


  procedure TImageWindow.AttachDecoder(ADecoder :TReviewDecoder; aHandle :THandle);
  begin
    if FDecoder <> ADecoder then begin
      ReleaseDecoder;
      if ADecoder.pvdDisplayInit(aHandle) then
        FDecoder := ADecoder;
    end;
  end;


  procedure TImageWindow.WMShowWindow(var Mess :TWMShowWindow); {message WM_ShowWindow;}
  var
    vColor :Integer;
  begin
    inherited;
    if Mess.Show then begin
      if FWinMode <> wmQuickView then
        vColor := FarAttrToCOLORREF(GetColorBG(optBkColor1))
      else
        vColor := FarAttrToCOLORREF(GetColorBG(optBkColor2));
      SetColor(vColor);
    end;
  end;


  procedure TImageWindow.CMSetImage(var Mess :TMessage); {message CM_SetImage;}
  var
    vOldImage :TReviewImage;
    vOldSrcRect, vOldDstRect :TRect;
    vAttachWnd :THandle;
  begin
    with PSetImageRec(Mess.LParam)^ do begin
//    Trace('CMSetImage...');

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
        SetOSD(Image.FMedia);

        if FVideoWin <> nil then
          vAttachWnd := FVideoWin.Handle
        else
          vAttachWnd := FHandle;

        AttachDecoder(Image.FDecoder, vAttachWnd);

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
          FImageOk := (FDecoder <> nil) and FDecoder.pvdDisplayShow(vAttachWnd, FImage)
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

        FResizeStart := 0;
        FResizeSize := Size(0, 0);

        if optShowInfo <> 0 then
          FImage.CollectInfo;

        FThumbStart := 0;
        if FImage.FIsThumbnail then
          FThumbStart := GetTickCount;

        FTempMsg := '';
        FUseWinSize := optUseWinSize;

        RecalcRects;

//      Trace('Show window...');
        if not IsWindowVisible(Handle) then
          ShowWindow
        else
        if FWinMode <> wmFullscreen then
          SetWindowBounds(CalcWinRect);

        if vOldImage <> nil then
          SlideEffect(vOldImage, vOldSrcRect, vOldDstRect, Direct)
        else
          Invalidate;

        if FVideoWin <> nil then
          UpdateInfoWin;

        FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);

        SetMediaVolume(optVolume);

      finally
        if vOldImage <> nil then
          FreeImage(vOldImage);
      end;
    end;
  end;


  procedure TImageWindow.CMReleaseImage(var Mess :TMessage); {message CM_ReleaseImage;}
  begin
    ReleaseImage;
//  Invalidate;
  end;


  procedure TImageWindow.CMTransform(var Mess :TMessage); {message CM_Transform;}

     procedure LocInvalidate;
     begin
       FHiQual := True;
       Invalidate;
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
        cmtRotate     : LocRotate(Mess.lParam);
        cmtOrient     : {};
      end;
    end;
  end;


  procedure TImageWindow.CMSetPage(var Mess :TMessage); {message CM_SetPage;}
  var
    vPage :Integer;
  begin
    FAnimate := False;

    vPage := RangeLimit(Mess.WParam, 0, FImage.FPages - 1);
    if vPage = FImage.FPage then
      Exit;

    SetPage( vPage, Pointer(Mess.LParam) );
    FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
  end;


  procedure TImageWindow.CMMove(var Mess :TMessage); {message CM_Move;}
  begin
    with PPoint(Mess.LParam)^ do
      MoveImage(X, Y);
  end;


  procedure TImageWindow.CMScale(var Mess :TMessage); {message CM_Scale;}
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


  procedure TImageWindow.CMSlideShow(var Mess :TMessage); {message CM_SlideShow;}
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


  procedure TImageWindow.CMShowInfo(var Mess :TMessage); {message CM_ShowInfo;}
  begin
    if optShowInfo <> 0 then
      FImage.CollectInfo;
    if FVideoWin <> nil then
      UpdateInfoWin
    else begin
      FHiQual := True;
      Invalidate;
    end;
  end;


  procedure TImageWindow.MoveImage(DX, DY :Integer);

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


  procedure TImageWindow.SetScale(aMode :TScaleMode; aLnScale, aScale :TFloat);
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


  procedure TImageWindow.SetPage(aPage :Integer; ASize :PSize = nil);
  var
    vSize :TSize;
  begin
    try
      if ASize <> nil then
        vSize := ASize^
      else
        vSize := Size(0, 0);
      FImage.FPage := RangeLimit(aPage, 0, FImage.FPages);
      FImage.DecodePage(vSize, False);
      FHiQual := True;
      RecalcRects;
      if not FAnimate then
        SetTempMsg(Format('Page: %d / %d', [FImage.FPage + 1, FImage.FPages])); {!Localize}
      Invalidate;
    except
      FAnimate := False;
      raise;
    end;
  end;


  procedure TImageWindow.RecalcRects;
  var
    vWinRect :TRect;
    vWinSize, vImgSize, vPicSize, vOldPicSize :TSize;
    vMaxDelta, vOrigDelta, vFocusDelta, vDelta, vMousePos :TPoint;
  begin
    vWinRect := GetClientRect;
    vWinSize := RectSize(vWinRect);

    vImgSize := Size(FImage.FWidth, FImage.FHeight);
    if FImage.FOrient in [5,6,7,8] then
      IntSwap(vImgSize.cx, vImgSize.cy);

    if FMode = smAutoFit then begin
      if (vImgSize.CX <> 0) and (vImgSize.CY <> 0) then begin
        { �������� �������, ����� ����������� ����������� � ����� }
        FScale := FloatMin( vWinSize.cx / vImgSize.cx, vWinSize.cy / vImgSize.cy);
        if FScale > (optInitialScale / 100) then
          FScale := (optInitialScale / 100);
      end else
        FScale := 1;

      if FScale > 0 then
        FLnScale := Ln(FScale) / Ln( cScaleStep)
      else
        FLnScale := 0;
    end;

    { ������ ������������������ �������� }
    vPicSize := Size(
      Round(vImgSize.cx * FScale),
      Round(vImgSize.cy * FScale)
    );

    if FDeltaScale <> FScale then begin
      { ������������� ��������, ����� �� ��������� ����� �����������, ����������� � ������ - }
      { � ������ ������ ��� ��� �������� ���� }

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
        Round(vImgSize.cx * FDeltaScale),
        Round(vImgSize.cy * FDeltaScale)
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

    FDstRect0 := Bounds( vOrigDelta.X, vOrigDelta.Y, vPicSize.cx, vPicSize.cy);

    FDstRect := Rect(
      IntMax(0, vOrigDelta.X),
      IntMax(0, vOrigDelta.Y),
      IntMin(vWinSize.cx, vOrigDelta.X + vPicSize.cx),
      IntMin(vWinSize.cy, vOrigDelta.Y + vPicSize.cy)
    );

    FSrcRect := Rect(
      MulDiv(IntMax(0, -vOrigDelta.X), vImgSize.cx, vPicSize.cx),
      MulDiv(IntMax(0, -vOrigDelta.Y), vImgSize.cy, vPicSize.cy),
      MulDiv(IntMin(vPicSize.cx, vWinSize.cx - vOrigDelta.x), vImgSize.cx, vPicSize.cx),
      MulDiv(IntMin(vPicSize.cy, vWinSize.cy - vOrigDelta.y), vImgSize.cy, vPicSize.cy)
    );
  end;


  procedure TImageWindow.WMSize(var Mess :TWMSize); {message WM_Size;}
  begin
    inherited;
    if FImage <> nil then
      RecalcRects;
    if FVideoWin <> nil then
      RealignOSD;
//  Invalidate;
  end;


 {-----------------------------------------------------------------------------}

  procedure TImageWindow.PaintWindow(DC :HDC);
  var
    vClientRect, vClipRect :TRect;
    vMemDC :TMemDC;
    vSaveDC :Integer;
    vSize :TSize;
    vTmpRect :TRect;
    vOwnDC, vTileMode, vFillAll :Boolean;
  begin
//  TraceBegF('%s PaintWindow (HiQual=%d)...', [ClassName, Byte(FHiQual)]);

    vClientRect := ClientRect;
    try
      GetClipBox(DC, vClipRect);

      if FImageOk then begin
        { ������� ������ ���-�� � ����� ���� }
        vOwnDC := FImage.FSelfdraw and not FImage.FSelfPaint;
        { ����� ������, ������ �� ��� Self-Draw}
        vTileMode := optTileMode and not vOwnDC;
        { �������� ��������� ���� ����� }
        vFillAll := vTileMode or RectContainsRect(FDstRect, vClientRect);

        if (optShowInfo <> 0) and not vOwnDC then begin

          vSize := RectSize(vClientRect);
          vMemDC := TMemDC.Create(vSize.CX, vSize.CY);
          try
            if not vFillAll then
              FillRect(vMemDC.DC, vClientRect, FBrush);

            if vTileMode or RectIntersects(FDstRect, vClipRect) then
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
          if vTileMode or RectIntersects(FDstRect, vClipRect) then
            DrawImage(DC, FImage, FSrcRect, FDstRect, False);

          if not vFillAll then begin
            { �������� ���, �������� ��������, ����� �� ������ }
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
    FHiQual := False;

//  TraceEnd('done');
  end;


  procedure TImageWindow.SlideEffect(aOldImage :TReviewImage; const AOldSrcRect, AOldDstRect :TRect; ADirect :Integer);
  var
    i, l, m, a1, a2, dx, dy :Integer;
    vDC :HDC;
    vClientRect :TRect;
    vMemDC, vImage1DC, vImage2DC :TMemDC;
    vSize :TSize;
    vRect, vRect1 :TRect;
    vTime :DWORD;
    vPeriod :Integer;
//  n :Integer;
  begin
//  n := 0;
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

          l := -1;
          m := 255*1000;
          vTime := GetTickCount;
          while True do begin
            vPeriod := TickCountDiff(GetTickCount, vTime);
            if vPeriod > optEffectPeriod then
              Break;

            i := MulDiv(m, vPeriod, optEffectPeriod);
            if i = l then begin
//            Trace('Skip...');
              Sleep(1);
              Continue;
            end;
            l := i;

            a1 := MulDiv(m - i, 255, m);
            a2 := MulDiv(i, 255, m);
//          TraceF('i=%d, a1=%d, a2=%d', [i, a1, a2]);

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
//          GdiFlush;
//          Inc(n);
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
//  Trace('...done. %d steps', [n]);
  end;



  procedure TImageWindow.DrawImage(DC :HDC; aImage :TReviewImage; const ASrcRect, ADstRect :TRect; ABuffered :Boolean);
  var
    vImgSize :TSize;
    vTransparent :Boolean;

    function LocScaleX(X :Integer) :Integer;
    begin
      Result := MulDiv(X, aImage.FBitmap.Size.CX, vImgSize.cx);
    end;

    function LocScaleY(Y :Integer) :Integer;
    begin
      Result := MulDiv(Y, aImage.FBitmap.Size.CY, vImgSize.cy);
    end;


    procedure LocFillBackground(ADC :HDC; const aRect :TRect);
    var
      I, J, MI, MJ, X, Y :Integer;
    begin
      if optTranspBack and (Review.FBackBmp <> nil) then begin
        with Review.FBackBmp.Size do begin
          MI := (aRect.Width + cx - 1) div cx;
          MJ := (aRect.Height + cy - 1) div cy;
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


    procedure LocDraw(ADC :HDC; const ADstRect, ADstRect0 :TRect);
    var
      vBmpRect :TRect;
      vNeedStretch, vIncrease, vSmooth :Boolean;
    begin
      if AImage.FSelfPaint then
        FDecoder.pvdDisplayPaint(Handle, ADC, aImage, ASrcRect, ADstRect, ADstRect0, FColor)
      else begin
        vBmpRect := ASrcRect;
        if (aImage.FBitmap.Size.CX <> vImgSize.cx) or (aImage.FBitmap.Size.CY <> vImgSize.cy) then
          { ������ ��������������� ������� �� ����� �������������� ������� ����������� - ������������ }
          with ASrcRect do
            vBmpRect := Rect(LocScaleX(Left), LocScaleY(Top), LocScaleX(Right), LocScaleY(Bottom));

        vNeedStretch :=
          ((vBmpRect.Right - vBmpRect.Left) <> (ADstRect.Right - ADstRect.Left)) or
          ((vBmpRect.Bottom - vBmpRect.Top) <> (ADstRect.Bottom - ADstRect.Top));

        if vNeedStretch or (vTransparent and (FWinBPP < 32)) then begin
//        Trace('Stretch...');

          vIncrease := (vBmpRect.Right - vBmpRect.Left) < (ADstRect.Right - ADstRect.Left);
          if FHiQual then begin
            { ��� ���������� ���������� ������, � ��� ���������� - ������ ���� �������� ����� optSmoothScale }
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
            { ������� ����� - ��� ����������� }
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
    end;

  var
    I, J, vTileX, vTileY :Integer;
    vSize, vPicSize :TSize;
    vTmpRect, vTmpRect1, vRect :TRect;
    vMemDC :TMemDC;
  begin
//  with ADstRect do
//    TraceF('Draw. DstRect=%dx%d-%dx%d', [Left, Top, Right, Bottom]);

    vImgSize := Size(AImage.FWidth, AImage.FHeight);
    if AImage.FOrient in [5,6,7,8] then
      IntSwap(vImgSize.cx, vImgSize.cy);

    if AImage.FSelfdraw and not AImage.FSelfPaint then
      FDecoder.pvdDisplayPaint(Handle, DC, aImage, ASrcRect, ADstRect, FDstRect0, FColor)
    else begin
      vTileX := 0; vTileY := 0;
      if optTileMode then begin
        vPicSize := Size(
          Round(vImgSize.cx * FScale),
          Round(vImgSize.cy * FScale));
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

          vTmpRect1 := FDstRect0;
          RectMove(vTmpRect1, -ADstRect.Left, -ADstRect.Top);

          LocDraw(vMemDC.DC, vTmpRect, vTmpRect1);

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
        LocDraw(DC, ADstRect, FDstRect0);
    end;
  end;


  procedure TImageWindow.DrawAddInfo(DC :HDC);
  begin
    DrawInfoOn(DC, FImage, ClientRect.Width div 2);
  end;


 {-----------------------------------------------------------------------------}

  procedure TImageWindow.WMKeyDown(var Mess :TWMKeyDown); {message WM_KeyDown;}
  begin
    Mess.Result := 0;
  end;


  procedure TImageWindow.WMLButtonDown(var Mess :TWMLButtonDown); {message WM_LButtonDown;}
  begin
    SetCapture(Handle);
    FMousePos := SmallPointToPoint(Mess.Pos);
    FDragged := True;
    Mess.Result := 0;
  end;


  procedure TImageWindow.WMRButtonDown(var Mess :TWMLButtonDown); {message WM_LRuttonDown;}
  begin
//  FarAdvControl(ACTL_SYNCHRO, SyncCmdThumbView);
    Mess.Result := 0;
  end;


  procedure TImageWindow.WMRButtonUp(var Mess :TWMLButtonDown); {message WM_RButtonDown;}
  begin
    FarAdvControl(ACTL_SYNCHRO, SyncCmdThumbView);
    Mess.Result := 0;
  end;


  procedure TImageWindow.WMMouseMove(var Mess :TWMMouseMove); {message WM_MouseMove;}
  begin
    if FDragged then begin
      MoveImage(Mess.Pos.X - FMousePos.X, Mess.Pos.Y - FMousePos.Y);
      FMousePos := SmallPointToPoint(Mess.Pos);
    end;
    Mess.Result := 0;
  end;


  procedure TImageWindow.WMLButtonUp(var Mess :TWMLButtonUp); {message WM_LButtonUp;}
  begin
    if FDragged then begin
      ReleaseCapture;
      FDragged := False;
    end;
    Mess.Result := 0;
  end;


  procedure TImageWindow.WMLButtonDblClk(var Mess :TWMLButtonDblClk); {message WM_LButtonDblClk;}
  begin
    if (GetKeyState(VK_Control) < 0) or FImage.FMedia then begin
      if FWinMode <> wmQuickView then
//      SetFullscreen( FWinMode = wmNormal )
        FarAdvControl(ACTL_SYNCHRO, SyncCmdFullscreen);
    end else
    if FMode = smExact then
      SetScale(smAutoFit, 0, 0)
    else
      SetScale(smExact, 0, 1);
    Mess.Result := 0;
  end;


  function TImageWindow.Idle :Boolean;
  var
    vDelay :Integer;
    vSize :TSize;
  begin
    Result := inherited Idle;

    if FDraftMode and (TickCountDiff(GetTickCount, FDraftStart) > optDraftDelay) and not ScrollKeyPressed{???} then begin
      { �������������� ����������� � ������� ��������, ����� ����������� ���������/��������������� }
      FDraftMode := False;
      FHiQual := True;
      Invalidate;  
    end;

    if (FClipStart <> 0) and (TickCountDiff(GetTickCount, FClipStart) > 150) then begin
//    Trace('Clipped redraw...');
      FHiQual := not FDraftMode;
      FClipStart := 0;
      RedrawWindow(Handle, nil, 0, {RDW_ERASE??? or} RDW_INVALIDATE or RDW_ALLCHILDREN);
    end;

    if (FTempMsg <> '') and (TickCountDiff(GetTickCount, FMsgStart) > FMsgDelay) then begin
      { ������ �������... }
      FHiQual := not FDraftMode;
      FTempMsg := '';
      InvalidateMsgRect;
    end;

    if (FImage <> nil) and FAnimate then begin
      { ��������... }
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
      FarAdvControl(ACTL_SYNCHRO, SyncCmdNextSlide);  { ����� GoNextSlide � ������� ������ }
    end;

    if (FImage <> nil) and (Fimage.FBitmap <> nil) then begin
      { ���� �������� ����������� �������� �������� �����������, ���� �� ������� ������ ����� }
      if AsyncDecode then begin
        RecalcRects;
        FHiQual := not FDraftMode;
        if FImage.FDecodeError <> '' then
          SetTempMsg(FImage.FDecodeError, False);
        Invalidate;
      end;
    end;

    if (FImage <> nil) and ((FImage.FWidth = 0) or (FImage.FHeight = 0)) and FImage.FMedia then begin
      { ������� Video �� ������ ����� ���� ���������� ����� ��� ��������... }
      vSize := GetMediaSize;
      if (vSize.CX > 0) and (vSize.CY > 0) then begin
        FImage.FWidth := vSize.CX;
        FImage.FHeight := vSize.CY;
        UpdateInfoWin;
        FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
      end;
    end;

   {$ifdef bVideoOSD}
    if FControlWin <> nil then
      FControlWin.Idle;
   {$endif bVideoOSD}
  end;



  function TImageWindow.AsyncDecode :Boolean;
  var
    vBestSize, vBmpSize :TSize;
  begin
    if FImage.FAsyncTask <> nil then
      Result := FImage.CheckAsyncTask
    else begin
      if FImage.FVector then begin
        vBestSize := Size(
          Round(FImage.FWidth * FScale),
          Round(FImage.FHeight * FScale)
        );
      end else
      if FUseWinSize then begin
        vBestSize := Size(
          Round(FImage.FWidth * FloatMin(FScale, 1.0)),
          Round(FImage.FHeight * FloatMin(FScale, 1.0))
        );
      end else
        vBestSize := Size(FImage.FWidth, FImage.FHeight);

      vBmpSize := FImage.FBitmap.Size;
      if FImage.FOrient in [5,6,7,8] then
        IntSwap(vBmpSize.cx, vBmpSize.cy);

      if (vBestSize.CX <> FResizeSize.CX) or (vBestSize.CY <> FResizeSize.CY) then begin
        if not FImage.FIsThumbnail and ((vBestSize.CX > vBmpSize.CX) or (vBestSize.CY > vBmpSize.CY)) then
          FResizeStart := GetTickCount;
        FResizeSize := vBestSize;
      end;

      if (FResizeStart <> 0) and (TickCountDiff(GetTickCount, FResizeStart) > StretchDelay) then begin
        FResizeStart := 0;
        if (vBestSize.CX > vBmpSize.CX) or (vBestSize.CY > vBmpSize.CY) then
          FImage.SetAsyncTask(vBestSize);
      end;

      if (FThumbStart <> 0) and (TickCountDiff(GetTickCount, FThumbStart) > ThumbDelay) and not ScrollKeyPressed then begin
        { ���� � ��������� ������ ������������ ����� (� �� ������������ ������� ��������), �� ��������� ������� �� �������������, ���� ��� ��� }
        FThumbStart := 0;
        if FImage.FIsThumbnail then
          FImage.SetAsyncTask(vBestSize);
      end;

      Result := False;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TImageWindow.SetOSD(aOn :Boolean);
  begin
    if (FVideoWin <> nil) = aOn then
      Exit;

    if aOn then begin
      FVideoWin := TVideoWindow.CreateEx(Self);
     {$ifdef bVideoOSD}
      FControlWin := TControlWindow.CreateEx(Self);
      FVideoWin.Ctrl := FControlWin;
      FControlWin.Video := FVideoWin;
     {$endif bVideoOSD}
      RealignOSD;
    end else
    begin
      FreeObj(FInfoWin);
     {$ifdef bVideoOSD}
      FVideoWin.Ctrl := nil;
      FreeObj(FControlWin);
     {$endif bVideoOSD}
      FreeObj(FVideoWin);
    end;
  end;


  procedure TImageWindow.RealignOSD;
  var
    vRect :TRect;
    Y :Integer;
  begin
    vRect := ClientRect;

    Y := vRect.Bottom;
   {$ifdef bVideoOSD}
    if not FControlWin.Hidden then begin
      Y := Y - cPanHeight;
      FVideoWin.SetBounds(Rect(vRect.Left, vRect.Top, vRect.Right, Y), 0);
      FControlWin.SetBounds(Rect(vRect.Left, Y, vRect.Right, Y + cPanHeight), 0);
    end else
    begin
      FControlWin.SetBounds(Rect(vRect.Left, Y, vRect.Right, Y + cPanHeight), 0);
      FVideoWin.SetBounds(Rect(vRect.Left, vRect.Top, vRect.Right, Y), 0);
    end;
   {$else}
    FVideoWin.SetBounds(Rect(vRect.Left, vRect.Top, vRect.Right, Y), 0);
   {$endif bVideoOSD}

    if FInfoWin <> nil then begin
      vRect := FInfoWin.GetBoundsRect;
      FInfoWin.SetBounds(Bounds(0, 0, vRect.Width, vRect.Height), 0);
//    Windows.SetWindowPos(FInfoWin.Handle, HWND_TOP, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);
    end;
  end;


  procedure TImageWindow.UpdateInfoWin;
  var
    vSize :TSize;
  begin
    if (FImage <> nil) and (FVideoWin <> nil) and (optShowInfo <> 0) then begin
      if FInfoWin = nil then
        FInfoWin := TInfoWindow.CreateEx(Self);
      CalcInfoBounds(FImage, ClientRect.Width div 2, vSize);
      Inc(vSize.CX, cDeltaH*2);
      Inc(vSize.CY, cDeltaV*2);
      FInfoWin.SetBounds(Bounds(0, 0, vSize.CX, vSize.CY), 0);
//    Windows.SetWindowPos(FInfoWin.Handle, HWND_TOP, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);
      if not IsWindowVisible(FInfoWin.Handle) then
        FInfoWin.Show
      else
        FInfoWin.Invalidate;
    end else
      FreeObj(FInfoWin);
  end;


  function TImageWindow.IsMedia :Boolean;
  begin
    Result := (FImage <> nil) and FImage.FMedia;
  end;


  function TImageWindow.IsVideo :Boolean;
  begin
    Result := IsMedia {and ... }
  end;


  procedure TImageWindow.PlayPause;
  var
    vState :Integer;
  begin
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do begin
        vState := pvdPlayControl(FImage, PVD_PC_GetState, 0);
        if vState = 1 then
          pvdPlayControl(FImage, PVD_PC_Pause, 0)
        else
          pvdPlayControl(FImage, PVD_PC_Play, 0);

       {$ifdef bVideoOSD}
        if (FControlWin <> nil) and (vState <> 1) then
          FControlWin.ActiveAction;
       {$endif bVideoOSD}
      end;
  end;


  function TImageWindow.GetMediaSize :TSize;
  begin
    Result := Size(0, 0);
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        pvdPlayControl(FImage, PVD_PC_GetBounds, TIntPtr(@Result));
  end;


  function TImageWindow.GetMediaState :Integer;
  begin
    Result := 0;
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        Result := pvdPlayControl(FImage, PVD_PC_GetState, 0);
  end;


  function TImageWindow.GetMediaLen :Integer;
  begin
    Result := 0;
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        Result := pvdPlayControl(FImage, PVD_PC_GetLen, 0);
  end;


  function TImageWindow.GetMediaPos :Integer;
  begin
    Result := 0;
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        Result := pvdPlayControl(FImage, PVD_PC_GetPos, 0);
  end;


  procedure TImageWindow.SetMediaPos(aMS :Integer);
  begin
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then begin
      with TReviewDllDecoder2(FImage.Decoder) do
        pvdPlayControl(FImage, PVD_PC_SetPos, aMS);
    {$ifdef bVideoOSD}
     if FControlWin <> nil then
       FControlWin.ActiveAction;
    {$endif bVideoOSD}
    end;
  end;


  function TImageWindow.GetMediaVolume :Integer;
  begin
    Result := 0;
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        Result := pvdPlayControl(FImage, PVD_PC_GetVolume, 0);
  end;


  procedure TImageWindow.SetMediaVolume(aVal :Integer);
  begin
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        pvdPlayControl(FImage, PVD_PC_SetVolume, aVal);
  end;


  function TImageWindow.GetAudioStream :Integer;
  begin
    Result := 0;
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do
        Result := pvdPlayControl(FImage, PVD_PC_GetAudioStream, 0);
  end;


  procedure TImageWindow.CMSetAudio(var Mess :TMessage); {message CM_SetAudio;}
  begin
    if (FImage <> nil) and (FImage.Decoder is TReviewDllDecoder2) then
      with TReviewDllDecoder2(FImage.Decoder) do begin
        pvdPlayControl(FImage, PVD_PC_SetAudioStream, Mess.WParam);
        FImage.FAudioIndex := GetAudioStream;

        FImage.FInfoInited := False;
        FImage.CollectInfo;
        UpdateInfoWin;
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
    CancelTask;
    ReleaseSource;
    inherited Destroy;
  end;


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

    procedure LocGetDouble(aCode :Integer; var aValue :Double);
    var
      vType :Integer;
      vValue :Pointer;
    begin
      if FDecoder.pvdTagInfo(Self, aCode, vType, vValue) and (vType = PVD_TagType_Double) then
        aValue := PDouble(vValue)^;
    end;

    procedure LocGetStr(aCode :Integer; var aValue :TString);
    var
      vType :Integer;
      vValue :Pointer;
    begin
      if FDecoder.pvdTagInfo(Self, aCode, vType, vValue) and (vType = PVD_TagType_Str) then begin
        aValue := Trim(PTChar(vValue));
//      aValue := UTF8ToWide(Trim(PTChar(vValue)));
      end;
    end;

  var
    vTime :TDateTime;
  begin
    if FInfoInited then
      Exit;

    if not GetFileInfo(FName, FTime, FSize) then
      { ���� ��� ������?... }
      Exit;

    if (FAsyncTask <> nil) or FIsThumbnail then
      { ���� ���� ������������� � ��������� ������ - �� ����������� Tag'�, }
      { ��� �������� ���� � ������, ���� � ��������... }
      Exit;

    if LockSource then begin
      try
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

        if FVideoCount > 0 then begin
          LocGetStr(PVD_Tag_Video_Name, FTags.FVideoName);
          LocGetStr(PVD_Tag_Video_Lang, FTags.FVideoLang);
          LocGetStr(PVD_Tag_Video_Format, FTags.FVideoFormat);
          LocGetInt(PVD_Tag_Video_Bitrate, FTags.FVideoBitrate);
          LocGetDouble(PVD_Tag_Video_Framerate, FTags.FVideoFramerate);
        end;

        if FAudioCount > 0 then begin
          LocGetStr(PVD_Tag_Audio_Name, FTags.FAudioName);
          LocGetStr(PVD_Tag_Audio_Lang, FTags.FAudioLang);
          LocGetStr(PVD_Tag_Audio_Format, FTags.FAudioFormat);
          LocGetInt(PVD_Tag_Audio_Bitrate, FTags.FAudioBitrate);
        end;

        FInfoInited := True;

      finally
        UnlockSource;
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


  function TReviewImage.TryOpenBy(ADecoder :TReviewDecoder; AForce :Boolean) :Boolean;
  var
    vStart :DWORD;
  begin
    Result := False;
    if ADecoder.Enabled and (ADecoder.SupportedFile(FName) = not AForce) and ADecoder.CanWork(True) then begin
//    TraceF('Try decoding by %s - %s...', [ADecoder.Name, FName]);

      if (FCacheBuf = nil) and ADecoder.NeedPrecache then
        if not PrecacheFile(FName) then
          Exit;

      vStart := GetTickCount;
      FOpenTime := 0;
      FContext := nil;
      if ADecoder.pvdFileOpen(FName, Self) then begin
        FPage := 0;
        FOpenTime := TickCountDiff(GetTickCount, vStart);
        FDecoder := ADecoder;
        FOpened := True;
        Result := True;
        Exit;
      end;
    end;
  end;


  procedure TReviewImage.DecodePage(ASize :TSize; AFirstOpen :Boolean; AFastScroll :Boolean = False);

    procedure LocDecodeError;
    begin
      AppError(AppendStrCh(FDecoder.Name + ': Decode error.', FDecoder.LastError, charLF));
    end;

  var
    vStart :DWORD;
    vMode :TDecodeMode;
    vSize :TSize;
    vWaitDelay :Integer;
  begin
    if not LockSource then
      AppErrorId(strFileLoadError);
    try
      vStart := GetTickCount;
      FDecodeTime := 0;

      if not FDecoder.pvdGetPageInfo(Self) then
        LocDecodeError;

      if AFirstOpen and optRotateOnEXIF then
        FOrient := FOrient0;

      if optUseWinSize then begin
        if FOrient in [5,6,7,8] then
          IntSwap(ASize.CX, ASize.CY);
        vSize := Size(FWidth, FHeight);
        CorrectBoundEx(vSize, ASize);
      end else
        vSize := Size(0, 0);

      { ����������... }
      if optUseThumbnail = not (GetKeyState(VK_Shift) < 0) then
        vMode := dmThumbnailOrImage
      else
        vMode := dmImage;

      if not FDecoder.pvdPageDecode(Self, vSize.CX, vSize.CY, vMode, Review.MyDecodeCallback, FDecoder) then
        LocDecodeError;
      if AFirstOpen and optRotateOnEXIF then
        FOrient := FOrient0;

      FDecodeTime := TickCountDiff(GetTickCount, vStart);

//    if (optShowInfo <> 0) and not AFastScroll then
//      CollectInfo;

      if not FSelfdraw then begin
        try
          { ��������� Bitmap  }
          FreeObj(FBitmap);
          FBitmap := TReviewBitmap.Create1(FDecoder.GetBitmapHandle(Self, FIsThumbnail), True);
          if FOrient > 1 then
            OrientBitmap(FOrient);
        finally
          FDecoder.pvdPageFree(Self);
        end;

        if FIsThumbnail and not AFastScroll then begin
          SetAsyncTask(vSize);
          vStart := GetTickCount;
          FDecodeTime := 0;

          vWaitDelay := 0;
//        Trace('Image: %d', [FWidth * FHeight * 4 div (1024 * 1024)]);
          if (FWidth * FHeight * 4 div (1024 * 1024)) < optBigImageLimit then
            vWaitDelay := DecodeWaitDelay;

          while not CheckAsyncTask and (TickCountDiff(GetTickCount, vStart) < vWaitDelay) do
            Sleep(1);
        end;

        if (optShowInfo <> 0) and not FIsThumbnail then
          CollectInfo;
      end;

    finally
      UnlockSource;
    end;
  end;


  procedure TReviewImage.SetAsyncTask(const ASize :TSize);
  begin
    if not LockSource then
      AppErrorId(strFileLoadError);

    InitRenderThread;
//  TraceF('SetAsyncTask %s...', [ExtractFileName(FSrcName)]);

    FAsyncTask := TTask.CreateEx(Self, FPage, ASize);
//  if FHasAlpha then
//    FAsyncTask.FBackColor := FBkColor;
//  FAsyncTask.FOnTask := TaskEvent;
    FAsyncTask._AddRef;

    GRenderThread.AddTask(FAsyncTask);
  end;


  function TReviewImage.CheckAsyncTask :Boolean;
  begin
    Result := False;
    if FAsyncTask <> nil then begin
      if GRenderThread.CheckTask(FAsyncTask) then begin
        if FAsyncTask.FThumb <> 0 then begin
          FreeObj(FBitmap);
          FBitmap := TReviewBitmap.Create1(FAsyncTask.FThumb, True);
          if FOrient > 1 then
            OrientBitmap(FOrient);
          FDecodeTime := FAsyncTask.FDecodeTime;
          FIsThumbnail := False;
        end;
        FDecodeError := FAsyncTask.FError;
        FAsyncTask.FThumb := 0;
        FAsyncTask._Release;
        FAsyncTask := nil;

        if optShowInfo <> 0 then
          CollectInfo;

        UnlockSource;
        Result := True;
      end;
    end;
  end;


  procedure TReviewImage.CancelTask;
  begin
    Assert(ValidInstance);
    if FAsyncTask <> nil then begin
//    TraceF('CancelTask %s...', [FSrcName]);
      GRenderThread.CancelTask(FAsyncTask);
      FAsyncTask._Release;
      FAsyncTask := nil;
      UnlockSource;
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
        if FOrient > 1 then
          OrientBitmap(FOrient);
      end;
    end;
  end;


  function TReviewImage.LockSource :Boolean;
  begin
    Result := False;
    if not FOpened then begin
      if (FCacheBuf = nil) and FDecoder.NeedPrecache then
        if not PrecacheFile(FName) then
          Exit;
      FContext := nil;
      if not FDecoder.pvdFileOpen(FName, Self) then
        Exit;
//    FPage := 0;
      FOpened := True;
    end;
    InterlockedIncrement(FSrcLock);
    Result := True;
  end;


  procedure TReviewImage.UnLockSource;
  begin
    InterlockedDecrement(FSrcLock);
    if FSrcLock = 0 then
      if optUnlockFile and CanReleaseSource then
        ReleaseSource;
  end;


  function TReviewImage.CanReleaseSource :Boolean;
  begin
    Result := not (FAnimated or FMedia or FSelfPaint) and (FPages = 1);
  end;


  procedure TReviewImage.ReleaseSource;
  begin
    if FOpened then begin
      if FDecodeInfo <> nil then
        FDecoder.pvdPageFree(Self);
      FDecoder.pvdFileClose(Self);
      FContext := nil;
      ReleaseCache;
      FOpened := False;
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
   {$ifdef bThumbs}
    CloseThumbWindow;
   {$endif bThumbs}

    try
      if NeedStoreCache then
        SaveDecodersInfo(FDecoders);
    except
      {Nothing}
    end;

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
//  vTimer :DWORD;
  begin
   {$ifdef bTrace}
//  Trace('ShowImage...');
//  vTimer := GetTickCount;
   {$endif bTrace}

    Result := False;
    inc(GLockSync);
    try
      if ScreenBitPerPixel < 16 then
        AppErrorId(strBadVideoModeError);
      UpdateConsoleWnd;
//    hConsoleTopWnd := GetTopParent(hFarWindow);
      hConsoleTopWnd := GetAncestor(hFarWindow, GA_ROOT);
//    TraceF('FarWnd=%x, ConsoleWnd=%x', [hFarWindow, hConsoleTopWnd]);

      vName := AFileName;
      if vName = '' then
        vName := FarPanelCurrentFileName;

      vFastScroll := TickCountDiff(GetTickCount, FLastDecode) < FastListDelay;
      if vFastScroll then
        { ��������� ������ �������� }
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
            DecodeImage(vImage, CalcWinSize(AMode), vFastScroll);
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
          { ���������� ����������� ��������� }
          if CurImage <> nil then
            CacheImage(CurImage);

        FCommand := GoCmdNone;
//      vImage.UpdateBitmap;  ???
        DisplayImage(vImage, AMode, ADirect);
        CacheImage(vImage);
        Result := True;
      end;

      if Result then
        FLastDecode := GetTickCount;

    finally
      Dec(GLockSync);
    end;

   {$ifdef bTrace}
//  Trace('ShowImage Done (%d)...', [TickCountDiff(GetTickCount, vTimer)]);
   {$endif bTrace}
  end;


  procedure TReviewManager.DisplayImage(aImage :TReviewImage; AMode :Integer; ADirect :Integer = 0);

    procedure CreateWinThread;
    begin
      if FWinThread = nil then begin
        LoadBackground;
        FWinThread := TReviewWinThread.Create(TImageWindow);
        while FWinThread.Window = nil do
          Sleep(0);
        FWindow := FWinThread.Window as TImageWindow;
      end;
    end;

  var
    vRec :TSetImageRec;
  begin
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
            DecodeImage(vImage, CalcWinSize);
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
      SendMessage(FWindow.Handle, CM_TempMsg, Byte(aInvalidate), TIntPtr(AMsg))
   {$ifdef bThumbs}
    else
    if FThumbsWindow <> nil then
      SendMessage(FThumbsWindow.Handle, CM_TempMsg, Byte(aInvalidate), TIntPtr(AMsg));
   {$endif bThumbs}
  end;


  {SyncCmdUpdateWin}
  procedure TReviewManager.UpdateWindowPos;
  var
    vRec :TSetImageRec;
  begin
    if IsQViewMode then begin
      FillZero(vRec, SizeOf(vRec));
      vRec.WinRect := CalcWinRectAs(1);
      SendMessage(FWindow.Handle, CM_SetWinPos, 0, LPARAM(@vRec));
    end else
    begin
      if (FWindow <> nil) and (ModalDlg <> nil) then
        ModalDlg.UpdateWindowVisible(FWindow);
     {$ifdef bThumbs}
      if (FThumbsWindow <> nil) and (ThumbsModalDlg <> nil) then
        ThumbsModalDlg.UpdateWindowVisible(FThumbsWindow);
     {$endif bThumbs}
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
    { ������������ ������... }
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
//    SendMessage(FWindow.Handle, CM_Sync, aCmd, aDelay);
      PostMessage(FWindow.Handle, CM_Sync, aCmd, aDelay);
    end;
  end;


  procedure TReviewManager.CloseWindow;
  begin
    if FWinThread <> nil then begin
      FreeObj(FWinThread);
      FWindow := nil;
      ClearCache;
    end;
    DoneRenderThread;
  end;


  procedure TReviewManager.CloseWindowDelayed(ADelay :Integer);
  begin
    if FWinThread <> nil then begin
      { �����, ����� �� ���������� ������ � Temp, ��� ��������� ������ � ������ }
      SendMessage(FWindow.Handle, CM_ReleaseImage, 0, 0);
      { � ���������, ����� �� ����������� Viewer }
      SyncDelayed(SyncCmdClose, ADelay);
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

        if FMedia then
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
        if (vScale <> 100) and not FMedia then
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
//    Trace('CacheNeighbor: %d...', [Byte(ANext)]);
      try
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
                    DecodeImage(vImage, CalcWinSize, {FastScroll=}False, {Precache=}True);
                    CacheImage(vImage);
                    FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
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

      except
        FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
      end;
    end;
  end;


//procedure TReviewImage.WaitCursor(ASet :Boolean);
//begin
//  if ASet then begin
//    if FCursor = 0 then
//      FCursor := LoadCursor(0, IDC_WAIT);
//    if FCursor <> 0 then
//      SetCursor(FCursor);
//  end else
//  begin
//  end;
//end;


  procedure TReviewManager.ShowDecodeProgress(ADecoder :TReviewDecoder; APercent :Integer);
  var
    vStr :TString;
  begin
    vStr :=
      FDecodeFile + ' - ' + ADecoder.Title + ' decoding' +
      StrIf(APercent > 0, ' ' + Int2Str(APercent) + '%', '') +
      '...';

    if (Window <> nil) and (Window.WinMode = wmFullscreen) then
      SetTempMsg(vStr)
    else
    if ModalDlg <> nil then
      ModalDlg.SetTitle(vStr)
    else begin
      if FOldTitle = '' then
        FOldTitle := GetConsoleTitleStr;
      SetConsoleTitleStr(vStr);
    end;
  end;


  procedure TReviewManager.MyDecodeCallback(ASender :Pointer; APercent :Integer; var AContinue :Boolean);
  begin
    if GetCurrentThreadID <> MainThreadID then
      { DecodePage ���������� �� ������ ���� ��� ������������� �����������... }
      begin NOP; Exit; end;

    if (FDecodeStart <> 0) and (TickCountDiff(GetTickCount, FDecodeStart) > FDecodeStep) then begin
      ShowDecodeProgress(TReviewDecoder(ASender), APercent);

      if CheckForEsc then
        AContinue := False;

      FDecodeStart := GetTickCount;
      FDecodeStep := 100;
    end;
  end;

  
  procedure TReviewManager.DecodeImage(aImage :TReviewImage; const ASize :TSize; AFastScroll :Boolean = False; APrecache :Boolean = False);
  begin
//  WaitCursor(True);
//  FScreen := 0;
    FOldTitle := '';

    if not APrecache then begin
      FDecodeFile := ExtractFileName(aImage.FName);
      FDecodeStart := GetTickCount;
      FDecodeStep := 500;

      if not AFastScroll{???} then
        ShowDecodeProgress(aImage.FDecoder, 0);
    end;

    try
      aImage.DecodePage(ASize, True, AFastScroll);
    finally
//    WaitCursor(False);
//    if FScreen <> 0 then
//      FARAPI.RestoreScreen(FScreen);
//    FScreen := 0;

      if FOldTitle <> '' then
        SetConsoleTitleStr(FOldTitle);
      FOldTitle := '';

      FDecodeFile := '';
      FDecodeStart := 0;
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
  begin
    Result := False;
    if PFLAGS_REALNAMES and AInfo.Flags = 0 then begin
      { ��������� ������ � "������������" �������, ������������ ����� �������... }
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
        FarPanelSetCurrentItem(True, AIndex);
       {$ifdef bThumbs}
        if FThumbsWindow <> nil then
          SendMessage(FThumbsWindow.Handle, CM_Move, cmMoveByName, TIntPtr(pointer(AFileName)));
       {$endif bThumbs}
        Result := True;
      end;
    end;
  end;


  function TReviewManager.MouseWheel(ADelta :Integer) :Boolean; {override;}
  var
    vImage :TReviewImage;
  begin
    Result := False;
    vImage := CurImage;
    if vImage <> nil then begin
//    TraceF('ProcessWheel: %d', [ADelta]);
      if GetKeyState(VK_Control) < 0 then
        Navigate(0, ADelta < 0, optEffectOnManual)
      else
      if vImage.FMedia then
        ChangeVolume(ADelta * 5, 0)
      else begin
        if not (GetKeyState(VK_Shift) < 0) then
          ADelta := ADelta * 5;
        SetScale( smDeltaScaleMouse, smExact, ADelta );
      end;
      Result := True;
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
  var
    vSize :TSize;
  begin
    if FWindow <> nil then begin
      vSize := CalcWinSize;
      SendMessage(FWindow.Handle, CM_SetPage, aPage, TIntPtr(@vSize));
    end;
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
    vImage := CurImage;
    if vImage = nil then
      Exit;
    try
      if not vImage.CanReleaseSource then
        AppErrorId(strSaveFormatError);

//    vImage.ReleaseSource;



      SetTempMsg(GetMsg(strSave));

      if aOrient = 0 then
        aOrient := vImage.Orient;

      Result := GDISaveAs(vImage.Name, ANewName, AFmtName, aOrient, aQuality, aOptions);

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


  procedure TReviewManager.SetFullscreen(aMode :Integer);
  begin
    if aMode = -1 then begin
      if (FWindow <> nil) and (FWindow.WinMode <> wmQuickView) then
        aMode := IntIf(FWindow.WinMode = wmFullscreen, 0, 1)
     {$ifdef bThumbs}
      else
      if FThumbsWindow <> nil then
        aMode := IntIf(FThumbsWindow.WinMode = wmFullscreen, 0, 1);
     {$endif bThumbs}
    end;

   {$ifdef bThumbs}
    if (FThumbsWindow <> nil) and ((FWindow = nil) or (FWindow.WinMode = wmQuickView) or (aMode = 0)) then begin
      SendMessage(FThumbsWindow.Handle, CM_SetMode, aMode, 0);
      optThumbFullscreen := aMode = 1;
      InterlockedIncrement(OptionsRevision);
    end;
   {$endif bThumbs}
    if FWindow <> nil then begin
      SendMessage(FWindow.Handle, CM_SetMode, aMode, 0);
      optFullscreen := aMode = 1;
      InterlockedIncrement(OptionsRevision);
    end;
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

 {$ifdef bThumbs}

  procedure TReviewManager.OpenThumbsView;
  begin
    if ModalDlg <> nil then begin
      if ThumbWindow = nil then
        FCommand := GoCmdThumbs;
      ModalDlg.Close;
    end else
    if ThumbWindow = nil then begin
      if Review.ShowThumbs('', '') then
        ThumbModalState
    end else
      Beep;
  end;


  function TReviewManager.ShowThumbs(const AFolder, ACurFile :TString) :Boolean;
  var
    vThumbs :TThumbList;
    vRec :TSetThumbsRec;
    vPath, vCurFile :TString;
  begin
    Result := False;

    if ScreenBitPerPixel < 16 then
      AppErrorId(strBadVideoModeError);
    UpdateConsoleWnd;
//  hConsoleTopWnd := GetTopParent(hFarWindow);
    hConsoleTopWnd := GetAncestor(hFarWindow, GA_ROOT);
//  TraceF('FarWnd=%x, ConsoleWnd=%x', [hFarWindow, hConsoleTopWnd]);

    if AFolder = '' then begin
      vPath := FarPanelGetCurrentDirectory;
      vCurFile := ACurFile;
      if ACurFile <> cKeepCurrent then
        vCurFile := FarPanelItemName(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0);
      vThumbs := CollectThumb('');
    end else
    begin
      vPath := RemoveBackSlash(AFolder);
      vCurFile := ACurFile;
      vThumbs := CollectThumb(vPath);
    end;

    try
//    if vThumbs.Count = 0 then
//      begin Beep; FreeObj(vThumbs); exit; end;
      if vThumbs = nil then
        begin Beep; exit; end;

      ChooseDecoders(vThumbs);

      if FThumbsThread = nil then begin
        FThumbsThread := TReviewWinThread.Create(TThumbsWindow);
        while FThumbsThread.Window = nil do
          Sleep(0);
        FThumbsWindow := FThumbsThread.Window;
      end;

      FillZero(vRec, SizeOf(vRec));
      vRec.Thumbs := vThumbs;
      vRec.Path := vPath;
      vRec.CurFile := vCurFile;
//    vRec.WinMode := AMode;
      vRec.WinRect := CalcWinRectAs(0{AMode});
      vRec.SyncPanel := AFolder = '';
      SendMessage(FThumbsWindow.Handle, CM_SetImage, 0, LPARAM(@vRec));

      Result := True;

    except
      FreeObj(vThumbs);
      raise;
    end;
  end;


  procedure TReviewManager.CloseThumbWindow;
  begin
    if FThumbsThread <> nil then begin
      FreeObj(FThumbsThread);
      FThumbsWindow := nil;
//    ClearThumbsCache?;
    end;
  end;


  procedure TReviewManager.ThumbSyncDelayed(aCmd, aDelay :Integer);
  begin
    if FThumbsWindow <> nil then begin
//    Trace('ThumbSyncDelayed...');
      SendMessage(FThumbsWindow.Handle, CM_Sync, aCmd, aDelay);
    end;
  end;


  procedure TReviewManager.ThumbChangePath(const APath, ACurFile :TString; aSyncPanel :Boolean);
  begin
    if aSyncPanel then begin
      FarPanelSetDir(True, APath);
      if ACurFile <> '' then
        FarPanelSetCurrentItem(True, ACurFile);
      ShowThumbs('', '');
    end else
      ShowThumbs(APath, ACurFile);
    if ThumbsModalDlg <> nil then
      ThumbsModalDlg.UpdateTitle;
  end;


  procedure TReviewManager.ThumbView(const AFileName :TString);
  begin
    if ThumbWindow.WinMode = wmFullscreen then
      optFullscreen := True;
    if ShowImage( AFileName, 0) then
      ViewModalState(False, False);
  end;


  procedure TReviewManager.ThumbSetSize(aSize :Integer);
  begin
    if FThumbsWindow <> nil then
      SendMessage(FThumbsWindow.Handle, CM_Scale, 0, aSize);
  end;


  function TReviewManager.ThumbRedecode(AMode :TRedecodeMode; ADecoder :TReviewDecoder; const AFileName :TString) :Boolean;

    function LocNext(AIndex :Integer) :Integer;
    begin
      if AMode = rmNext then
        Result := IntIf(AIndex < FDecoders.Count - 1, AIndex + 1, 0)
      else
        Result := IntIf(AIndex > 0, AIndex - 1, FDecoders.Count - 1);
    end;

  var
    vIndex, vNewIndex :Integer;
  begin
    Result := True;
    if AMode = rmBest then
      FFavDecoder := nil
    else
    if AMode in [rmNext, rmPrev] then begin
      Result := False;
      vIndex := FDecoders.IndexOf(ADecoder);
      if vIndex = -1 then
        vIndex := 0;
      vNewIndex := LocNext(vIndex);
      while True do begin
        if TReviewDecoder(FDecoders[vNewIndex]).CanShowThumbFor(AFileName) then begin
          FFavDecoder := FDecoders[vNewIndex];
          Result := True;
          Exit;
        end;
        if vNewIndex = vIndex then
          Break;
        vNewIndex := LocNext(vNewIndex);
      end;
    end;
  end;

 {$endif bThumbs}


 {-----------------------------------------------------------------------------}

  procedure TReviewManager.MediaSeek(aOrigin :TSeekOrigin; aValue :Integer);
  var
    vPos :Integer;
  begin
    if FWindow = nil then
      Exit;
    vPos := aValue;
    case aOrigin of
//    soBeginning:
//      vPos := aValue;
      soCurrent:
        vPos := FWindow.GetMediaPos + aValue;
      soEnd:
        vPos := FWindow.GetMediaLen + aValue;
    end;
    FWindow.SetMediaPos(vPos);
  end;


  procedure TReviewManager.ChangeAudioStream(aOrigin :TSeekOrigin; aValue :Integer);
  var
    vCount, vIdx :Integer;
  begin
    if FWindow = nil then
      Exit;
    vCount := FWindow.FImage.FAudioCount;
    vIdx := FWindow.GetAudioStream;
    case aOrigin of
      soBeginning:
        vIdx := aValue;
      soCurrent: begin
        vIdx := vIdx + aValue;
        if vIdx >= vCount then
          vIdx := 0
        else
        if vIdx < 0 then
          vIdx := vCount -1;
      end;
      soEnd:
        vIdx := vCount + aValue;
    end;
    if (vIdx >= 0) and (vIdx < vCount) then
      SendMessage(FWindow.Handle, CM_SetAudio, vIdx, 0);
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
      GetMsg(strMThumbnails),
      PTChar(vDecodersStr),
      GetMsg(strMColors)
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : ReviewConfig;
        1 : SlideShowConfig;
       {$ifdef bThumbs}
        2 : ThumbConfig;
       {$else}
        2 : Sorry;
       {$endif bThumbs}
        3 : DecodersConfig(Review);
        4 : ColorMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { ������ ���������� ���������                                                 }
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


  procedure TViewModalDlg.UpdateTitle;
  begin
    SetTitle( Review.GetWindowTitle );
  end;


  function TViewModalDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  var
    vImage :TReviewImage;

    procedure LocNavigate(AOrig :Integer; AForward :Boolean);
    begin
      if not Review.Navigate(AOrig, AForward, optEffectOnManual) then
        Beep;
    end;

    procedure LocGotoPage(ADelta :Integer);
    var
      vPage :Integer;
    begin
      vPage := vImage.FPage + ADelta;
      if (vPage >= 0) and (vPage < vImage.FPages) then
        Review.SetImagePage(vPage)
      else
        Beep;
    end;

    procedure LocMove(ADX, ADY :Integer);
    var
      vRec :TPoint;
    begin
      vRec.x := ADX;
      vRec.Y := ADY;
      SendMessage(Review.Window.Handle, CM_Move, 0, LPARAM(@vRec));
    end;

    procedure LocMovePage(ADX, ADY :Integer);
    begin
      if not vImage.FMedia then begin
        with Review.Window.ClientRect do begin
          ADX := ADX * (Right - Left);
          ADY := ADY * (Bottom - Top);
        end;
        LocMove(ADX, ADY);
      end;
    end;

    procedure LocShowInfo;
    begin
      optShowInfo := 1 - optShowInfo;
      InterlockedIncrement(OptionsRevision);
      SendMessage(Review.Window.Handle, CM_ShowInfo, 0, 0);
    end;

    procedure LocSwitchBack;
    begin
      optTranspBack := not optTranspBack;
      Review.InvalidateImage;
    end;

    procedure LocSwitchTile;
    begin
      optTileMode := not optTileMode;
      Review.InvalidateImage;
    end;

    procedure LocSwitchWinSize;
    begin
      optUseWinSize := not optUseWinSize;
//    Review.InvalidateImage;
      Review.Redecode(rmSame, False);
      Review.SetTempMsg('Decode to screen size: ' + StrIf(optUseWinSize, 'On', 'Off'));  {!Localize}
    end;

    procedure LocSwitchSmooth;
    begin
      optSmoothScale := not optSmoothScale;
      Review.SetTempMsg('Smooth mode: ' + StrIf(optSmoothScale, 'On', 'Off'), False);  {!Localize}
      Review.InvalidateImage;
    end;

    procedure LocSetSmoothMode(aMode :Integer);
    const
      cModeNames :array[0..7] of TSTring =
        ('Default', 'Low', 'High', 'Bilinear', 'Bicubic', 'Nearest', 'HQBilinear', 'HQBicubic');
    begin
      optSmoothScale := True;
      optSmoothMode := aMode;
      Review.SetTempMsg('Smooth mode: ' + Int2Str(optSmoothMode) + ' - ' + cModeNames[optSmoothMode], False);  {!Localize}
      Review.InvalidateImage;
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
      if Review.CheckSync(vImage.FName, vSelected) then begin
        if FarGetPanelInfo(True, vInfo) then begin
          vIndex := vInfo.CurrentItem;
          vSelected := (AMode = 1) or ((AMode = -1) and not vSelected);
          FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, vIndex, Pointer( TIntPtr(IntIf(vSelected, PPIF_SELECTED, 0)) ));
          vImage.FSelected := -1;
          FarAdvControl(ACTL_SYNCHRO, SyncCmdUpdateTitle);
         {$ifdef bThumbs}
          if Review.FThumbsWindow <> nil then
            SendMessage(Review.FThumbsWindow.Handle, CM_Select, IntIf(vSelected, cmSelSetName,cmSelClrName), TIntPtr(pointer(vImage.FName)));
         {$endif bThumbs}
        end;
      end else
        Beep;
    end;


    function LocStep(aStep :Integer) :Integer;
    begin
      if Key_Shift and AKey = 0 then
        Result := aStep
      else
        Result := IntIf(aStep > 0, 1, -1);
      Result := Result * 1000;
    end;


    procedure LocSaveAs;
    var
      vFileName, vFmtName :TString;
      vOrient, vQuality :Integer;
      vOptions :TSaveOptions;
    begin
      vFileName := vImage.FName;
      vFmtName := vImage.FFormat;
      vOrient := vImage.FOrient;
      vQuality := 0;
      vOptions := [soTransformation];
      Review.SyncDelayed(SyncCmdUpdateWin, 100);
      if SaveAsDlg(vFileName, vFmtName, vOrient, vQuality, vOptions) then begin
        Review.UpdateWindowPos;
        Review.Save(vFileName, vFmtName, vOrient, vQuality, vOptions);
      end;
    end;

  begin
    Result := True;
    if FQuick then begin

      if AKey <> KEY_Esc then begin
        FarPostMacro('Keys("Esc ' + FarKeyToName(AKey) + '")');
      end else
        Result := inherited KeyDown(AID, AKey);

    end else
    begin
      vImage := Review.CurImage;

      if (AKey >= byte('A')) and (AKey <= byte('Z')) then
        AKey := AKey + 32;

      case AKey of
        KEY_F1 : begin
          Review.SyncDelayed(SyncCmdUpdateWin, 100);
          Result := inherited KeyDown(AID, AKey);
        end;

        Key_F3, KEY_F10, Key_NumPad5:
          Close;

        KEY_F9 : begin
          Review.SyncDelayed(SyncCmdUpdateWin, 100);
          Review.PluginSetup;
        end;

        KEY_F4..KEY_F8{,KEY_F10},KEY_F11,
        KEY_SHIFTF3..KEY_SHIFTF8,
        KEY_ALTF3,KEY_ALTF4:
        begin
          FPostKey := AKey;
          Close;
        end;
       {$ifdef bThumbs}
        Key_F12: Review.OpenThumbsView;
       {$endif bThumbs}

        { �������� }
        Key_Left, Key_ShiftLeft, Key_NumPad4, Key_ShiftNumPad4:
          if not vImage.FMedia then
            LocMove(LocStep(+cMoveStep),  0)
          else
            Review.MediaSeek(soCurrent, LocStep(-cMoveStepSec));

        Key_Right, Key_ShiftRight, Key_NumPad6, Key_ShiftNumPad6:
          if not vImage.FMedia then
            LocMove(LocStep(-cMoveStep),  0)
          else
            Review.MediaSeek(soCurrent, LocStep(+cMoveStepSec));

        Key_Up, Key_ShiftUp, Key_NumPad8, Key_ShiftNumPad8:
          if not vImage.FMedia then
            LocMove( 0, LocStep(+cMoveStep))
          else
            Review.ChangeVolume(LocStep(+10), 0);

        Key_Down, Key_ShiftDown, Key_NumPad2, Key_ShiftNumPad2:
          if not vImage.FMedia then
            LocMove( 0, LocStep(-cMoveStep))
          else
            Review.ChangeVolume(LocStep(-10), 0);

        Key_CtrlLeft, Key_CtrlNumPad4:
          if not vImage.FMedia then
            LocMove(+MaxInt,  0)
          else
            Review.MediaSeek(soBeginning, 0);

        Key_CtrlRight, Key_CtrlNumPad6:
          if not vImage.FMedia then
            LocMove(-MaxInt,  0)
          else
            Review.MediaSeek(soEnd, 0);

        Key_CtrlUp, Key_CtrlNumPad8:
          if not vImage.FMedia then
            LocMove( 0, +MaxInt)
          else
            Review.ChangeVolume(0, 100);

        Key_CtrlDown, Key_CtrlNumPad2:
          if not vImage.FMedia then
            LocMove( 0, -MaxInt)
          else
            Review.ChangeVolume(0, 0);

        Key_AltLeft   : LocMovePage(+1,  0);
        Key_AltRight  : LocMovePage(-1,  0);
        Key_AltUp     : LocMovePage( 0, +1);
        Key_ALtDown   : LocMovePage( 0, -1);

        { ������������ ����������� }
        Key_Home, Key_ShiftHome, Key_NumPad7 : LocNavigate(1, True);
        Key_End, Key_ShiftEnd, Key_NumPad1   : LocNavigate(2, False);
        Key_PgDn, Key_ShiftPgDn, Key_NumPad3 : LocNavigate(0, True);
        Key_PgUp, Key_ShiftPgUp, Key_NumPad9 : LocNavigate(0, False);

        { ������������ ������� }
        Key_CtrlHome, Key_CtrlNumPad7 : Review.SetImagePage(0);
        Key_CtrlEnd, Key_CtrlNumPad1  : Review.SetImagePage(MaxInt);
        Key_CtrlPgDn, Key_CtrlNumPad3 : LocGotoPage(+1);
        Key_CtrlPgUp, Key_CtrlNumPad9 : LocGotoPage(-1);

        { ������������ ��������� }
        Key_AltHome  : Review.Redecode(rmBest);
        Key_AltPgDn  : Review.Redecode(rmNext);
        Key_AltPgUp  : Review.Redecode(rmPrev);

        { ��������������� }
        KEY_MULTIPLY      :
          if Review.Window.ScaleMode = smExact then
            Review.SetScale( smSetMode, smAutoFit, 0  )
          else
            Review.SetScale( smSetScale, smExact, 1  );
        KEY_Add           : Review.SetScale( smDeltaScale, smExact, +5 {Change scale} );
        KEY_Subtract      : Review.SetScale( smDeltaScale, smExact, -5 {Change scale} );
        KEY_ShiftAdd      : Review.SetScale( smDeltaScale, smExact, +1 {Change scale} );
        KEY_ShiftSubtract : Review.SetScale( smDeltaScale, smExact, -1 {Change scale} );

        KEY_CtrlR, Byte('r') : Review.Redecode;
        KEY_CtrlS, Byte('s') : Review.SlideShow(-1);
        KEY_AltS             : Review.SlideShowQueryDelay;
        KEY_CtrlI, Byte('i') : LocShowInfo;
        KEY_CtrlB, Byte('b') : LocSwitchBack;
        KEY_CtrlT, Byte('t') : LocSwitchTile;
        KEY_CtrlQ, Byte('q') : LocSwitchSmooth;
        KEY_CtrlW, Byte('w') : LocSwitchWinSize;
        KEY_AltQ             : LocSwitchSmoothMode;
        KEY_ALT0..KEY_ALT7   : LocSetSmoothMode(AKey - KEY_ALT0);

        KEY_CtrlA, Byte('a') : Review.ChangeAudioStream(soCurrent, 1);
        KEY_CtrlShiftA       : Review.ChangeAudioStream(soCurrent, -1);

        KEY_CtrlF, Byte('f') :
//        Review.SetFullscreen(Review.Window.FWinMode = wmNormal);
          Review.SetFullscreen(-1);

        Byte('.')           : Review.Rotate(1); { > - ������� �� ������� }
        Byte(',')           : Review.Rotate(2); { < - ������� ������ ������� }
        Key_Alt + Byte('.') : Review.Rotate(3); { Alt> - X-Flip }
        Key_Alt + Byte(',') : Review.Rotate(4); { Alt< - Y-Flip }

        Key_Ins     : LocSelectCurrent(-1);
        Key_Del     : LocSelectCurrent(0);

        Key_F2      : Review.Save('', '', 0, 0, [soTransformation]);
        Key_CtrlF2  : Review.Save('', '', 0, 0, [soTransformation, soEnableLossy]);
        Key_AltF2   : Review.Save('', '', 0, 0, [soExifRotation]);
        Key_ShiftF2 : LocSaveAs;

        Key_Space   : Review.Window.PlayPause;

       {$ifdef bDebug}
        KEY_AltX : Sorry;
       {$endif bDebug}
       
      else
        Result := inherited KeyDown(AID, AKey);
      end;
    end;
  end;


  function TViewModalDlg.MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; {override;}
  begin
   {$ifdef bWinWheel}
   {$else}
    if AMouse.dwEventFlags and MOUSE_HWHEELED <> 0 then
      Review.Rotate(IntIf(Smallint(LongRec(AMouse.dwButtonState).Hi) > 0, 1, 2))
    else
    if AMouse.dwEventFlags and MOUSE_WHEELED <> 0 then
      Review.MouseWheel(IntIf(Smallint(LongRec(AMouse.dwButtonState).Hi) > 0, 1, -1));
   {$endif bWinWheel}
    Result := inherited MouseEvent(AID, AMouse);
  end;


  function ViewModalState(AView, AQuick :Boolean) :Boolean;
  var
    vKeys :TString;
    vRevision :Integer;
  begin
    Assert(ModalDlg = nil);
    ModalDlg := TViewModalDlg.Create;
    try
      vRevision := OptionsRevision;

      ModalDlg.FQuick := AQuick;
      Result := ModalDlg.Run = -1;

      if vRevision <> OptionsRevision then
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
     {$ifdef bThumbs}
      if Review.FCommand = GoCmdThumbs then begin
        if Review.Window <> nil then
          optThumbFullscreen := Review.Window.WinMode = wmFullscreen;
        if AView then
          Review.CloseWindowDelayed(100)
        else
          Review.CloseWindow;
        vKeys := '';
        if AView then
          vKeys := 'Keys("Esc")';
        FarPostMacro(vKeys +
          ' Plugin.Call("' + PlugIdToStr(cPluginID) + '", "Thumbs", 1)');
      end else
     {$endif bThumbs}
      begin
        Review.CloseWindowDelayed(1000);
        Review.ProcessCommand;
      end;

    finally
      FreeObj(ModalDlg);
    end;
  end;


end.


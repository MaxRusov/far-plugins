{$I Defines.inc}

unit GDIPlusMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDIPlus Main                                                               *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    GDIPAPI,
    GDIPOBJ,
//  GDIImageUtil,
    PVApi;

  const
    cUseThumbnailRegKey   = 'UseThumbnail';
    cDecodeOnReduceRegKey = 'DecodeOnReduce';

  const
    cAnimationStep     = 100;          {ms }
    cThumbSize         = 128;          { Размер извлекаемого эскиза }
    cRescalePerc       = 5;

  var
    WaitDelay        :Integer = 1000;  { Сколько ждем декодирование, презде чем показать эскиз. Только при первом открытии. }
    DraftDelay       :Integer = 125;   { Задержка для аккурaтной перерисовки }
    StretchDelay     :Integer = 500;   { Задержка для масштабирования }
    PrecacheDelay    :Integer = 100;   { Задержка для предварительного масштабирования }

    FastListDelay    :Integer = 500;
    ThumbDelay       :Integer = 250;   { Задержка до начала декодирования при перелистывании }

    UseThumbnail     :Boolean = True;
    DecodeOnReduce   :Boolean = False;
    RotateOnEXIF     :Boolean = False;


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

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function RectEquals(const AR, R :TRect) :Boolean;
  begin
    Result :=
      (AR.Left = R.Left) and (AR.Top = R.Top) and
      (AR.Right = R.Right) and (AR.Bottom = R.Bottom);
  end;


  procedure CorrectBound(var ASize :TSize; ALimit :Integer);
  begin
    if (ASize.cx > ALimit) or (ASize.CY > ALimit) then begin
      if ASize.cx > ASize.cy then begin
        ASize.cy := MulDiv(ASize.cy, ALimit, ASize.cx);
        ASize.cx := ALimit;
      end else
      begin
        ASize.cx := MulDiv(ASize.cx, ALimit, ASize.cy);
        ASize.cy := ALimit;
      end;
    end;
  end;


  procedure CorrectBoundEx(var ASize :TSize; const ALimit :TSize);
  begin
    if (ASize.cx > ALimit.cx) or (ASize.cy > ALimit.cy) then begin
      if (ASize.cx - ALimit.cx) > (ASize.cy - ALimit.cy) then begin
        ASize.cy := MulDiv(ASize.cy, ALimit.cx, ASize.cx);
        ASize.cx := ALimit.cx;
      end else
      begin
        ASize.cx := MulDiv(ASize.cx, ALimit.cy, ASize.cy);
        ASize.cy := ALimit.cy;
      end;
    end;
  end;


  function GetFrameCount(AImage :TGPImage; var ADimID :TGUID; var ADelays :PPropertyItem; var ADelCount :Integer) :Integer;
  var
    vCount, vSize :Integer;
    vDims :PGUID;
  begin
    Result := 0;
    ADelays := nil;
    ADelCount := 0;
    vCount := AImage.GetFrameDimensionsCount;
    if vCount > 0 then begin
      GetMem(vDims, vCount * SizeOf(TGUID));
      try
        AImage.GetFrameDimensionsList(vDims, vCount);

        ADimID := vDims^;
        Result := AImage.GetFrameCount(ADimID);

        if Result > 1 then begin
          vSize := AImage.GetPropertyItemSize(PropertyTagFrameDelay);
          if vSize > SizeOf(TPropertyItem) then begin
            GetMem(ADelays, vSize);
            AImage.GetPropertyItem(PropertyTagFrameDelay, vSize, ADelays);
            ADelCount := (vSize - SizeOf(TPropertyItem)) div SizeOf(Integer);
          end;
        end;

      finally
        FreeMem(vDims);
      end;
    end;
  end;

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
    GradientFill(AHandle, VA[0], 2, @GR, 1, FillFlag[AVert]);
  end;


  function RandomColor :DWORD;
  begin
    Result := RGB(Random(256), Random(256), Random(256));
  end;


 {-----------------------------------------------------------------------------}

(*
  procedure TraceExifProps(AImage :TGPImage);
  var
    I :Integer;
    vSize, vCount :Cardinal;
    vBuffer, vItem :PPropertyItem;
    vName, vValue :TString;
  begin
    AImage.GetPropertySize(vSize, vCount);
    if vCount > 0 then begin
      GetMem(vBuffer, vSize);
      ZeroMemory(vBuffer, vSize);
      try
        AImage.GetAllPropertyItems(vSize, vCount, vBuffer);

        vItem := vBuffer;
        for i := 0 to Integer(vCount) - 1 do begin
          vName := GetImagePropName(vItem.id);
          if vName = '' then
            vName := Format('Prop%d', [vItem.id]);

          vValue := '';
          if vItem.type_ = PropertyTagTypeASCII then
            vValue := PChar(vItem.value)
          else
          if vItem.type_ = PropertyTagTypeByte then
            vValue := Int2Str(Byte(vItem.value^))
          else
          if vItem.type_ = PropertyTagTypeShort then
            vValue := Int2Str(Word(vItem.value^))
          else
          if vItem.type_ in [PropertyTagTypeLong, PropertyTagTypeSLONG] then
            vValue := Int2Str(Integer(vItem.value^))
          else
          if vItem.type_ in [PropertyTagTypeRational, PropertyTagTypeSRational] then
            vValue := '???';

          if (vName <> '') {and (vValue <> '')} then
            TraceF('Prop: %s = %s', [ vName, vValue ]);

          Inc(PChar(vItem), SizeOf(TPropertyItem));
        end;

      finally
        FreeMem(vBuffer);
      end;
    end;
  end;
*)

  function GetExifTagValueAsInt(AImage :TGPImage; AID :ULONG; var AValue :Integer) :Boolean;
  var
    vSize :UINT;
    vItem :PPropertyItem;
  begin
    Result := False;
    vSize := AImage.GetPropertyItemSize(AID);
    if vSize > 0 then begin
      vItem := MemAlloc(vSIze);
      try
        Result := True;
        AImage.GetPropertyItem(AID, vSIze, vItem);
        if vItem.type_ = PropertyTagTypeByte then
          AValue := Byte(vItem.value^)
        else
        if vItem.type_ = PropertyTagTypeShort then
          AValue := Word(vItem.value^)
        else
        if vItem.type_ in [PropertyTagTypeLong, PropertyTagTypeSLONG] then
          AValue := Integer(vItem.value^)
        else
          Result := False;
      finally
        MemFree(vItem);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    GRegPath :TString;


  procedure RegWriteBinByte(AKey :HKey; const AName :TString; AValue :Byte);
  begin
    ApiCheckCode( RegSetValueEx(AKey, PTChar(AName), 0, REG_BINARY, @AValue, SizeOf(Byte) ));
  end;


  function RegQueryBinByte(AKey :HKey; const AName :TString; var AValue :Byte) :Boolean;
  var
    vDataType, vLen :DWORD;
    vValue :Byte;
  begin
    vDataType := REG_BINARY;
    vLen := SizeOf(Byte);
    Result := RegQueryValueEx(AKey, PTChar(AName), nil, @vDataType, PByte(@vValue), @vLen) = ERROR_SUCCESS;
    if Result then
      AValue := vValue;
  end;


  procedure ReadSettings(const APath :TString);
  var
    vStr :TString;
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, APath, vKey);
    try
      if not RegQueryBinByte(vKey, cUseThumbnailRegKey, Byte(UseThumbnail)) then
        RegWriteBinByte(vKey, cUseThumbnailRegKey, Byte(UseThumbnail));

      if not RegQueryBinByte(vKey, cDecodeOnReduceRegKey, Byte(DecodeOnReduce)) then
        RegWriteBinByte(vKey, cDecodeOnReduceRegKey, Byte(DecodeOnReduce));
    finally
      RegCloseKey(vKey);
    end;

    vStr := APath + '\Description';
    RegOpenWrite(HKCU, vStr, vKey);
    try
      RegWriteStr(vKey, cUseThumbnailRegKey, 'bool;Use Thumbnail');
      RegWriteStr(vKey, cDecodeOnReduceRegKey, 'bool;Decode on Reduce');
    finally
      RegCloseKey(vKey);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TGPImageEx = class(TGPImage)
    public
      function _AddRef :Integer;
      function _Release :Integer;

    private
      FRefCount :Integer;
    end;


  function TGPImageEx._AddRef :Integer;
  begin
    Result := InterlockedIncrement(FRefCount);
  end;


  function TGPImageEx._Release :Integer;
  begin
    Result := InterlockedDecrement(FRefCount);
    if Result = 0 then
      Destroy;
  end;

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TMemDC = class(TObject)
    public
      constructor Create(ADC :HDC; W, H :Integer);
      destructor Destroy; override;

      procedure Clear;

    private
      FDC :HDC;
      FWidth, FHeight :Integer;
      FBMP, FOldBmp :HBitmap;
      FBrush, FOldBrush :HBrush;
    end;


  constructor TMemDC.Create(ADC :HDC; W, H :Integer);
  var
    vDC :HDC;
  begin
    FWidth := W;
    FHeight := H;

    vDC := GetDC(0);
    try
      FBMP := CreateCompatibleBitmap(vDC, W, H);
      ApiCheck(FBMP <> 0);
    finally
      ReleaseDC(0, vDC);
    end;

    FDC := CreateCompatibleDC(0);
    FOldBmp := SelectObject(FDC, FBmp);

    if ADC <> 0 then begin
      FBrush := GetCurrentObject(ADC, OBJ_BRUSH);
      FOldBrush := SelectObject(FDC, FBrush);
      Clear;
    end;
  end;

  destructor TMemDC.Destroy; {override;}
  begin
    if FOldBrush <> 0 then
      SelectObject(FDC, FOldBrush);
    if FOldBmp <> 0 then
      SelectObject(FDC, FOldBmp);
    if FBMP <> 0 then
      DeleteObject(FBMP);
    if FDC <> 0 then
      DeleteDC(FDC);
  end;


  procedure TMemDC.Clear;
  begin
    FillRect(FDC, Bounds(0, 0, FWIdth, FHeight), FBrush);
  end;


 {-----------------------------------------------------------------------------}
 { TThumbnailThread                                                            }
 {-----------------------------------------------------------------------------}

  type
    TTaskState = (
      tsNew,
      tsProceed,
      tsReady,
      tsCancelled
    );

    TTask = class(TBasis)
    public
      constructor CreateEx(const AName :TString; AFrame :Integer; const ASize :TSize);
      destructor Destroy; override;

      function _AddRef :Integer;
      function _Release :Integer;

    private
      FRefCount   :Integer;
      FName       :TString;
      FFrame      :Integer;
      FSize       :TSize;
      FThumb      :TMemDC;
      FState      :TTaskState;
      FError      :TString;
      FOnTask     :TNotifyEvent;
      FNext       :TTask;
    end;


  constructor TTask.CreateEx(const AName :TString; AFrame :Integer; const ASize :TSize);
  begin
    inherited Create;
    FName  := AName;
    FFrame := AFrame;
    FSize  := ASize;
  end;


  destructor TTask.Destroy; {override;}
  begin
    FreeObj(FThumb);
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
    TThumbnailThread = class(TThread)
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
    end;


  constructor TThumbnailThread.Create;
  begin
    FEvent := CreateEvent(nil, True, False, nil);
    InitializeCriticalSection(FTaskCS);
    inherited Create(False);
  end;


  destructor TThumbnailThread.Destroy; {override;}
  begin
    while FTask <> nil do
      NextTask;
    CloseHandle(FEvent);
    DeleteCriticalSection(FTaskCS);
    inherited Destroy;
  end;


  procedure TThumbnailThread.Execute;
  var
    vRes :DWORD;
  begin
    while not Terminated do begin
      vRes := WaitForSingleObject(FEvent, 5000);
//    TraceF('WaitRes = %d', [Byte(vRes)]);
      if Terminated then
        break;

      if vRes = WAIT_OBJECT_0 then begin
        ResetEvent(FEvent);
        while DoTask do;
      end;
    end;
  end;


  function TThumbnailThread.DoTask :Boolean;
  begin
    Result := False;

    EnterCriticalSection(FTaskCS);
    try
      while (FTask <> nil) and (FTask.FState = tsCancelled) do
        NextTask;
      if FTask = nil then
        Exit;
      FTask.FState := tsProceed;
      if Assigned(FTask.FOnTask) then
        FTask.FOnTask(nil);
    finally
      LeaveCriticalSection(FTaskCS);
    end;

    Render(FTask);

    EnterCriticalSection(FTaskCS);
    try
      FTask.FState := tsReady;
      if Assigned(FTask.FOnTask) then
        FTask.FOnTask(nil);
      NextTask;
    finally
      LeaveCriticalSection(FTaskCS);
    end;

    Result := True;
  end;


  procedure TThumbnailThread.NextTask;
  var
    vTask :TTask;
  begin
    vTask := FTask;
    FTask := vTask.FNext;
    vTask.FNext := nil;
    vTask._Release;
  end;


  function ImageAbort(AData :Pointer) :BOOL; stdcall;
  begin
//  TraceF('ImageAbort. State: %d', [Byte(TTask(AData).FState)]);
    Result := TTask(AData).FState = tsCancelled;
   {$ifdef bTrace}
    if Result then
      Trace('!Canceled');
   {$endif bTrace}
  end;


  procedure TThumbnailThread.Render(ATask :TTask);
  var
    vImage    :TGPImage;
    vSize     :TSize;
    vThumb    :TMemDC;
    vGraphics :TGPGraphics;
    vDimID    :TGUID;
   {$ifdef bTrace}
    vTime     :DWORD;
   {$endif bTrace}
  begin
    try
      vThumb := nil;
      vSize := ATask.FSize;
      vImage := TGPImageEx.Create(ATask.FName);
      try
        if vImage.GetLastStatus = Ok then begin

          if ATask.FFrame > 0 then begin
            FillChar(vDimID, SizeOf(vDimID), 0);
            if vImage.GetFrameDimensionsList(@vDimID, 1) = Ok then
              vImage.SelectActiveFrame(vDimID, ATask.FFrame);
          end;

          vThumb := TMemDC.Create(0, vSize.CX, vSize.CY);
//        GradientFillRect(vThumb.FDC, Rect(0, 0, vSize.CX, vSize.CY), RandomColor, RandomColor, True);

          vGraphics := TGPGraphics.Create(vThumb.FDC);
          try
//          vGraphics.SetCompositingMode(CompositingModeSourceCopy);
//          vGraphics.SetCompositingQuality(CompositingQualityHighSpeed);
//          vGraphics.SetSmoothingMode(SmoothingModeHighSpeed);
//          vGraphics.SetInterpolationMode(InterpolationModeLowQuality);

           {$ifdef bTrace}
            vTime := GetTickCount;
            TraceF('Render %s, %d x %d...', [ATask.FName, vSize.CX, vSize.CY]);
           {$endif bTrace}

            vGraphics.DrawImage(vImage, MakeRect(0, 0, vSize.CX, vSize.CY), 0, 0, vImage.GetWidth, vImage.GetHeight, UnitPixel, nil, ImageAbort, ATask);

           {$ifdef bTrace}
            TraceF('  Ready (%d). %d ms', [Byte(vGraphics.GetLastStatus), TickCountDiff(GetTickCount, vTime)]);
           {$endif bTrace}

          finally
            FreeObj(vGraphics);
          end;

        end;
      finally
        FreeObj(vImage);
      end;

      ATask.FThumb := vThumb;

    except
      on E :Exception do
        ATask.FError := E.Message;
    end;
  end;


  procedure TThumbnailThread.AddTask(ATask :TTask);
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


  function TThumbnailThread.CheckTask(ATask :TTask) :Boolean;
  begin
    EnterCriticalSection(FTaskCS);
    try
      Result := ATask.FState = tsReady;
    finally
      LeaveCriticalSection(FTaskCS);
    end;
  end;


  procedure TThumbnailThread.CancelTask(ATask :TTask);
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
    GThumbThread :TThumbnailThread;


  procedure InitThumbnailThread;
  begin
    if GThumbThread = nil then
      GThumbThread := TThumbnailThread.Create;
  end;


  procedure DoneThumbnailThread;
  begin
    if GThumbThread <> nil then begin
      GThumbThread.Terminate;
      SetEvent(GThumbThread.FEvent);
      GThumbThread.WaitFor;
      FreeObj(GThumbThread);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TIdleThread                                                                 }
 {-----------------------------------------------------------------------------}

  type
    PIdles = ^TIdles;
    TIdles = array[0..999] of TMethod;

    TIdleThread = class(TThread)
    public
      FIdleCS   :TRTLCriticalSection;
      FIdles    :PIdles;
      FCount    :Integer;
      FCapacity :Integer;

      constructor Create;
      destructor Destroy; override;
      procedure Execute; override;
      procedure AddIdle(const AOnIdle :TNotifyEvent);
      procedure DeleteIdle(const AOnIdle :TNotifyEvent);
    end;


  constructor TIdleThread.Create;
  begin
    InitializeCriticalSection(FIdleCS);
    inherited Create(False);
  end;


  destructor TIdleThread.Destroy; {override;}
  begin
    DeleteCriticalSection(FIdleCS);
    MemFree(FIdles);
    inherited Destroy;
  end;


  procedure TIdleThread.Execute;
  var
    I :Integer;
  begin
    while not Terminated do begin
      EnterCriticalSection(FIdleCS);
      try
        for I := 0 to FCount - 1 do
          TNotifyEvent(FIdles[I])(Self);
      finally
        LeaveCriticalSection(FIdleCS);
      end;
      Sleep(1);
    end;
  end;

  procedure TIdleThread.AddIdle(const AOnIdle :TNotifyEvent);
  begin
    EnterCriticalSection(FIdleCS);
    try
      if FCount = FCapacity then begin
        ReallocMem(FIdles, (FCapacity + 1) * SizeOf(TNotifyEvent));
        Inc(FCapacity);
      end;

      FIdles[FCount] := TMethod(AOnIdle);
      Inc(Fcount);

    finally
      LeaveCriticalSection(FIdleCS);
    end;
  end;

  procedure TIdleThread.DeleteIdle(const AOnIdle :TNotifyEvent);
  var
    I :Integer;
    P :TMethod;
  begin
    EnterCriticalSection(FIdleCS);
    try
      P := TMethod(AOnIdle);
      for I := 0 to FCount - 1 do
        if MemCompare(@FIdles[I], @P, SizeOf(TNotifyEvent)) = SizeOf(TNotifyEvent) then begin
          if I < FCount - 1 then
            Move(FIdles[I + 1], FIdles[I], (FCount - I - 1) * SizeOf(TNotifyEvent));
          Dec(FCount);
          Break;
        end;
    finally
      LeaveCriticalSection(FIdleCS);
    end;
  end;



  var
    GIdleThread :TIdleThread;

  procedure InitIdleThread;
  begin
    if GIdleThread = nil then
      GIdleThread := TIdleThread.Create;
  end;


  procedure DoneIdleThread;
  begin
    FreeObj(GIdleThread);
  end;


 {-----------------------------------------------------------------------------}
 { TView                                                                       }
 {-----------------------------------------------------------------------------}

  var
    GViewID        :Integer;

  var
    GLastID        :Integer;
    GLastPaint     :DWORD;
    GLastPaint1    :DWORD;
    GWinSize       :TSize;

  type
    PDelays = ^TDelays;
    TDelays = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;

    TViewQuality = (
      vqAuto,
      vqLo,
      vqHi
    );

    TView = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure SetSrcImage(AImage :TGPImageEx);
      procedure SetFrame(AIndex :Integer);

      function _AddRef :Integer;
      function _Release :Integer;

      procedure BeginDraw(AWnd :HWnd);
      procedure EndDraw(AWnd :HWnd);
      procedure Deactivate;

      procedure FillBack(const ARect :TRect; AColor :DWORD);
      procedure DrawImage(const ASrcRect, ADstRect :TRect; AColor :DWORD);
      procedure DrawText(X, Y :Integer; const AStr :TString);
      function InitThumbnail(ADX, ADY :Integer) :Boolean;

    private
      FRefCount    :Integer;

      FID          :Integer;      { Уникальный идентификатор }
      FSrcName     :TString;      { Имя файла }
      FSrcImage    :TGPImageEx;   { Исходное изображение }
      FImgSize     :TSize;        { Оригинальный размер картинки (текущей страницы) }
      FPixels      :Integer;      { Цветность (BPP) }
      FDirectDraw  :Boolean;      { Полупрозрачное или анимированное изображение, не используем preview'шки }
      FOrientation :Integer;

      FThumbImage  :TMemDC;       { Изображение, буферизированное как Bitmap }
      FThumbSize   :TSize;        { Размер Preview'шки }
      FIsThumbnail :Boolean;      { Это превью (thumbnail) }
      FErrorMess   :TString;

      FViewStart   :DWORD;        { Для поддержки предварительного декодирования }

      FResizeStart :DWORD;        { Для поддержки фонового декодирования (при масштабировании или быстрой прокрутке) }
      FResizeSize  :TSize;

      FDraftStart  :DWORD;
      FFirstDraw   :Boolean;
      FHiQual      :Boolean;
      FPrevSrcRect :TRect;
      FPrevDstRect :TRect;

      { Для поддержки анимированных изображений... }
      FFrames      :Integer;
      FFrame       :Integer;
      FDelCount    :Integer;
      FDelays      :PPropertyItem;
      FDimID       :TGUID;

      { Поддержка фоновой декомпрессии картинок }
      FAsyncTask   :TTask;

      { Рисование }
      FWnd          :HWND;
      FDC           :HDC;
//    FPaintStruct  :TPaintStruct;

      FDrawCS       :TRTLCriticalSection;

      procedure SetAsyncTask(const ASize :TSize);
      function CheckAsyncTask :Boolean;
      procedure CancelTask;
      procedure TaskEvent(ASender :Tobject);
      procedure Idle(ASender :Tobject);
    end;


  constructor TView.Create; {override;}
  begin
    inherited Create;
    InitializeCriticalSection(FDrawCS);

    InitIdleThread;
    GIdleThread.AddIdle(Idle);

    Inc(GViewID);
    FID := GViewID;
  end;


  destructor TView.Destroy; {override;}
  begin
//  TraceF('%p TView.Destroy', [Pointer(Self)]);
    if GIdleThread <> nil then
      GIdleThread.DeleteIdle(Idle);

    DeleteCriticalSection(FDrawCS);

    CancelTask;
    FreeObj(FThumbImage);

    FSrcImage._Release;
    FSrcImage := nil;

    if FDelays <> nil then begin
      FreeMem(FDelays);
      FDelays := nil;
    end;

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


  procedure TView.SetSrcImage(AImage :TGPImageEx);
  var
    vHahAlpha :Boolean;
  begin
    FSrcImage := AImage;
    FSrcImage._AddRef;

    FImgSize.cx := FSrcImage.GetWidth;
    FImgSize.cy := FSrcImage.GetHeight;
    FPixels     := GetPixelFormatSize(FSrcImage.GetPixelFormat);

    vHahAlpha   := ImageFlagsHasAlpha and FSrcImage.GetFlags <> 0;

    { Подсчитываем количество фреймов в анимированном/многостраничном изображении }
    FFrames := GetFrameCount(FSrcImage, FDimID, FDelays, FDelCount);

//  TraceExifProps(FSrcImage);
    if RotateOnEXIF then
      if GetExifTagValueAsInt(FSrcImage, PropertyTagOrientation, FOrientation) then begin
//      TraceF('!!! EXIF: Orientation=%d', [FOrientation]);
      end;    

    FDirectDraw := vHahAlpha or (FDelays <> nil);
//  FDirectDraw := False;
  end;


  procedure TView.SetFrame(AIndex :Integer);
  var
    vTmp :Integer;
  begin
    if (FFrames > 1) and (AIndex < FFrames) then begin
      FSrcImage.SelectActiveFrame(FDimID, AIndex);
      FFrame := AIndex;
    end;

    FImgSize.cx := FSrcImage.GetWidth;
    FImgSize.cy := FSrcImage.GetHeight;
    FPixels     := GetPixelFormatSize(FSrcImage.GetPixelFormat);

    if RotateOnEXIF and (FOrientation <> 0) then
      if (FOrientation = 6) or (FOrientation = 8) then begin
        vTmp := FImgSize.cx;
        FImgSize.cx := FImgSize.cy;
        FImgSize.cy := vTmp;
      end;

    CancelTask;
    FreeObj(FThumbImage);
    FErrorMess := '';
  end;


  procedure TView.BeginDraw(AWnd :HWnd);
  begin
    EnterCriticalSection(FDrawCS);
    try
      FWnd := AWnd;
//    FDC := BeginPaint(AWnd, FPaintStruct);
      FDC := GetDC(AWnd);
    finally
      LeaveCriticalSection(FDrawCS);
    end;
  end;


  procedure TView.EndDraw(AWnd :HWnd);
  begin
    EnterCriticalSection(FDrawCS);
    try
      if FDC <> 0 then begin
//      EndPaint(AWnd, FPaintStruct);
        ReleaseDC(FWnd, FDC);
        FDC := 0;
      end;
    finally
      LeaveCriticalSection(FDrawCS);
    end;
  end;


  procedure TView.Deactivate;
  begin
    EnterCriticalSection(FDrawCS);
    try
//    TraceF('TView.DisplayClose: %s', [FSrcName]);
      FWnd := 0;
      FViewStart := 0;
    finally
      LeaveCriticalSection(FDrawCS);
    end;
    CancelTask;
  end;


  procedure TView.FillBack(const ARect :TRect; AColor :DWORD);
  begin
    if FDC <> 0 then begin
      GradientFillRect(FDC, ARect, AColor, AColor, True);
//    GradientFillRect(FDC, ARect, RGB(255,0,0), AColor, True);
    end;
  end;


  procedure TView.DrawText(X, Y :Integer; const AStr :TString);
  var
    vFont, vOldFont :HFont;
  begin
    vFont := GetStockObject(DEFAULT_GUI_FONT);
    vOldFont := SelectObject(FDC, vFont);
    if vOldFont = 0 then
      Exit;
    try

      TextOut(FDC, X, Y, PTChar(AStr), Length(AStr));

    finally
      SelectObject(FDC, vOldFont);
    end;
  end;


  procedure TView.DrawImage(const ASrcRect, ADstRect :TRect; AColor :DWORD);

    procedure LocDirectDraw;
    var
      vGraphics :TGPGraphics;
      vImage :TMemDC;
      vDstRect :TGPRect;
    begin
      with ADstRect do
        vDstRect := MakeRect(0, 0, Right - Left, Bottom - Top);

      vImage := TMemDC.Create(0, vDstRect.Width, vDstRect.Height);
      try
        GradientFillRect(vImage.FDC, Rect(0, 0, vDstRect.Width, vDstRect.Height), AColor, AColor, True);

        vGraphics := TGPGraphics.Create(vImage.FDC);
        try
          with ASrcRect do
            vGraphics.DrawImage(FSrcImage, vDstRect, Left, Top, Right - Left, Bottom - Top, UnitPixel);
        finally
          vGraphics.Free;
        end;

        with ADstRect do
          BitBlt(FDC, Left, Top, Right - Left, Bottom - Top, vImage.FDC, 0, 0, SRCCOPY);

      finally
        FreeObj(vImage);
      end;
    end;

    function LocThumbSize(ImgSize, SrcSize, DispSize :Integer) :Integer;
    begin
      if SrcSize = ImgSize then
        Result := DispSize
      else
        Result := MulDiv(ImgSize, DispSize, SrcSize);
      if Result > ImgSize then
        Result := ImgSize;
    end;

    function LocCalcScale(ADX, ADY :Integer) :Integer;
    begin
      Result := IntMax(MulDiv(ADX, 100, FImgSize.cx), MulDiv(ADY, 100, FImgSize.cy));
    end;

    function LocScaleX(X :Integer) :Integer;
    begin
      Result := MulDiv(X, FThumbImage.FWidth, FImgSize.cx);
    end;

    function LocScaleY(Y :Integer) :Integer;
    begin
      Result := MulDiv(Y, FThumbImage.FHeight, FImgSize.cy);
    end;

    function LocNeedResize(N1, N2 :Integer) :Boolean;
    var
      vDelta :Integer;
    begin
      Result := False;
      if (N1 > N2) or DecodeOnReduce then begin
        vDelta := Abs(N1 - N2);
        Result := vDelta > MulDiv(IntMax(N1, N2), cRescalePerc, 100);
      end;
    end;

  var
    vSize :TSize;
    vScale :Integer;
    vRect :TRect;
    vStart :DWORD;
    vSaveDC :Integer;
    vFastScroll :Boolean;
   {$ifdef bTrace}
//  vTime :DWORD;
   {$endif bTrace}
  begin
    if FDC = 0 then
      Exit;

   {$ifdef bTrace}
//  vTime := GetTickCount;
//  TraceF('Paint (%p) %s...', [Pointer(FThumbImage), ExtractFileName(FSrcName)]);
   {$endif bTrace}

//  TraceF('Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d',
//    [ASrcRect.Left, ASrcRect.Top, ASrcRect.Right - ASrcRect.Left, ASrcRect.Bottom - ASrcRect.Top,
//     ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top]);

    if FDirectDraw then
      LocDirectDraw
    else begin
      vSize.cx := LocThumbSize(FImgSize.cx, ASrcRect.Right - ASrcRect.Left, ADstRect.Right - ADstRect.Left);
      vSize.cy := LocThumbSize(FImgSize.cy, ASrcRect.Bottom - ASrcRect.Top, ADstRect.Bottom - ADstRect.Top);

      if (FThumbImage = nil) or (FIsThumbnail and (FAsyncTask = nil)) then begin

        { Определяем режим "быстрой прокрутки"}
        vFastScroll := {(GLastID <> FID) and} (TickCountDiff(GetTickCount, GLastPaint) < FastListDelay);
        if vFastScroll then begin
//        Trace('!!!FastScroll???');
          GLastPaint1 := GetTickCount;
        end;

        vScale := LocCalcScale(vSize.cx, vSize.cy);
        if vScale > 90 then
          { Выгоднее уже декодировать 100% }
          vSize := FImgSize;

        if (FThumbImage = nil) or not vFastScroll then begin
          { Запускаем фоновый декодер и ждем результата (но не долше, чем WaitDelay)}
          if FAsyncTask = nil then
            SetAsyncTask(vSize);
          vStart := GetTickCount;
          while (FAsyncTask <> nil) and (TickCountDiff(GetTickCount, vStart) < WaitDelay) do begin
            if CheckAsyncTask then begin
              FHiQual := not vFastScroll;
              FDraftStart := 0;
              Break;
            end;
            Sleep(1);
          end;
        end else
        begin
          { "Быстрая прокрутка". Показываем превью, декодер отработает в фоне. }
          FResizeStart := GetTickCount - DWORD(StretchDelay) + DWORD(ThumbDelay);
          FResizeSize := vSize;
        end;
      end;

      if FAsyncTask <> nil then
        if CheckAsyncTask then
          FHiQual := True;

      if (FAsyncTask = nil) and (LocNeedResize(vSize.cx, FThumbSize.CX) or LocNeedResize(vSize.cy, FThumbSize.CY)) then begin
        if (FResizeStart = 0) or (FResizeSize.cx <> vSize.cx) or (FResizeSize.cy <> vSize.cy) then begin
//        TraceF('Need resize! %d x %d', [FThumbSize.cx - vDX, FThumbSize.cy - vDY]);
          if FFirstDraw then
            { Ошиблись с прогнозом при опрежающем декодировании. }
            SetAsyncTask(vSize)
          else begin
            FResizeStart := GetTickCount;
            FResizeSize := vSize;
          end;
        end;
      end else
        FResizeStart := 0;

      if FThumbImage <> nil then begin

        with ASrcRect do
          vRect := Rect(LocScaleX(Left), LocScaleY(Top), LocScaleX(Right), LocScaleY(Bottom));

        if FHiQual and not FIsThumbnail and not FFirstDraw then
          if not RectEquals(FPrevSrcRect, ASrcRect) or not RectEquals(FPrevDstRect, ADstRect) then
            FHiQual := False;

        FPrevSrcRect := ASrcRect;
        FPrevDstRect := ADstRect;

        if (ADstRect.Right - ADstRect.Left = vRect.Right - vRect.Left) and (ADstRect.Bottom - ADstRect.Top = vRect.Bottom - vRect.Top) then begin
         {$ifdef bTrace}
          TraceF('BitBlt. Thumb=%d', [Byte(FIsThumbnail)]);
         {$endif bTrace}
          BitBlt(
            FDC,
            ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top,
            FThumbImage.FDC,
            vRect.Left, vRect.Top,
            SRCCOPY);
          FDraftStart := 0;
        end else
        begin
          if FHiQual and not FIsThumbnail then
            { Аккуратный, но медленный }
            SetStretchBltMode(FDC, HALFTONE)
          else begin
            { Быстрый, но не аккуратный }
            SetStretchBltMode(FDC, COLORONCOLOR);
            if not FIsThumbnail then
              FDraftStart := GetTickCount;
          end;

         {$ifdef bTrace}
          TraceF('StretchBlt. Thumb=%d, Qual=%s', [Byte(FIsThumbnail), StrIf(FHiQual, 'Hi', 'Lo')]);
         {$endif bTrace}
          StretchBlt(
            FDC,
            ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top,
            FThumbImage.FDC,
            vRect.Left, vRect.Top, vRect.Right - vRect.Left, vRect.Bottom - vRect.Top,
            SRCCOPY);
        end;

        FFirstDraw := False;

      end else
        GradientFillRect(FDC, ADstRect, AColor, AColor, True);
    end;

    { Заливаем фон, исключая картинку, чтобы не мигала }
    vSaveDC := SaveDC(FDC);
    try
      with ADstRect do
        ExcludeClipRect(FDC, Left, Top, Right, Bottom);
      GetClientRect(FWnd, vRect);
      FillBack(vRect, AColor);
      with vRect do
        GWinSize := Size(Right - Left, Bottom - Top);
    finally
      RestoreDC(FDC, vSaveDC);
    end;

    if FAsyncTask <> nil then
      DrawText(vRect.Left, vRect.Top, 'Decoding...')
    else
    if FErrorMess <> '' then
      DrawText(vRect.Left, vRect.Top, FErrorMess);

    if GLastID <> FID then begin
      GLastPaint := GetTickCount;
      GLastID := FID;
    end;

   {$ifdef bTrace}
//  TraceF('  Done paint. %d ms', [TickCountDiff(GetTickCount, vTime)]);
   {$endif bTrace}
  end;



  function TView.InitThumbnail(ADX, ADY :Integer) :Boolean;
  var
    vThmImage :TGPImage;
    vGraphics :TGPGraphics;
   {$ifdef bTrace}
//  vTime :Cardinal;
   {$endif bTrace}
  begin
//  TraceF('UpdateThumbnail: %d x %d', [ADX, ADY]);
    Result := False;

   {$ifdef bTrace}
//  vTime := GetTickCount;
   {$endif bTrace}
    vThmImage := FSrcImage.GetThumbnailImage(ADX, ADY, nil, nil);
   {$ifdef bTrace}
//  TraceF('GetThumbnail time: %d ms (%d x %d)', [TickCountDiff(GetTickCount, vTime), vThmImage.GetWidth, vThmImage.GetHeight]);
   {$endif bTrace}
    if (vThmImage = nil) or (vThmImage.GetLastStatus <> Ok) then begin
      FreeObj(vThmImage);
      Exit;
    end;

    try
      FThumbSize.cx := vThmImage.GetWidth;
      FThumbSize.cy := vThmImage.GetHeight;
      FIsThumbnail := True;

     {$ifdef bTrace}
//    vTime := GetTickCount;
//    TraceF('Thumb Render %d x %d...', [FThumbSize.cx, FThumbSize.cy]);
     {$endif bTrace}
      FThumbImage := TMemDC.Create(0, FThumbSize.cx, FThumbSize.cy);
      vGraphics := TGPGraphics.Create(FThumbImage.FDC);
      try
        vGraphics.DrawImage(vThmImage, 0, 0, FThumbSize.cx, FThumbSize.cy);
      finally
        vGraphics.Free;
      end;
     {$ifdef bTrace}
//    TraceF('  Ready. %d ms', [TickCountDiff(GetTickCount, vTime)]);
     {$endif bTrace}

      Result := True;

    finally
      FreeObj(vThmImage);
    end;
  end;


  procedure TView.SetAsyncTask(const ASize :TSize);
  begin
    InitThumbnailThread;
//  TraceF('SetAsyncTask %s...', [ExtractFileName(FSrcName)]);

    FAsyncTask := TTask.CreateEx(FSrcName, FFrame, ASize);
    FAsyncTask.FOnTask := TaskEvent;
    FAsyncTask._AddRef;

    GThumbThread.AddTask(FAsyncTask);
  end;


  function TView.CheckAsyncTask :Boolean;
  begin
    Result := False;
    if FAsyncTask <> nil then begin
      if GThumbThread.CheckTask(FAsyncTask) then begin
        FreeObj(FThumbImage);

        FThumbImage  := FAsyncTask.FThumb;
        FThumbSize   := FAsyncTask.FSize;
        FErrorMess   := FAsyncTask.FError;
        FIsThumbnail := False;

        FAsyncTask.FThumb := nil;
        FAsyncTask._Release;
        FAsyncTask := nil;
        Result := True;
      end;
    end;
  end;


  procedure TView.CancelTask;
  begin
    Assert(ValidInstance);
    if FAsyncTask <> nil then begin
//    TraceF('CancelTask %s...', [FSrcName]);
      GThumbThread.CancelTask(FAsyncTask);
      FAsyncTask._Release;
      FAsyncTask := nil;
    end;
  end;


  procedure TView.TaskEvent(ASender :Tobject);
  begin
//  TraceF('TaskEvent %d...', [Byte(FAsyncTask.FState)]);
    FDraftStart := GetTickCount - DWORD(DraftDelay);
  end;


  procedure TView.Idle(ASender :Tobject);
  var
    vSize :TSize;
  begin
    EnterCriticalSection(FDrawCS);
    try
      if FDirectDraw then
        Exit;

      if (FWnd <> 0) and (FDC = 0) then begin
        if (FResizeStart <> 0) and (TickCountDiff(GetTickCount, FResizeStart) > StretchDelay) then begin
          { Асинхронное декодирование при масштабировании }
          FResizeStart := 0;
          SetAsyncTask(FResizeSize);
        end;

        if (FDraftStart <> 0) and (TickCountDiff(GetTickCount, FDraftStart) > DraftDelay) then begin
//        TraceF('%p.InvalidateRect FWnd=%d', [Pointer(Self), FWnd]);
          FDraftStart := 0;
          FHiQual := True;
          InvalidateRect(FWnd, nil, False);
        end;
      end;

      if (FWnd = 0) and ((FThumbImage = nil) or FIsThumbnail) and (TickCountDiff(GetTickCount, GLastPaint1) > FastListDelay) then begin
        if (FViewStart <> 0) and (TickCountDiff(GetTickCount, FViewStart) > PrecacheDelay) then begin
          { Опережающее декодировани (размере эскиза прогнозируем из расчета того что он вписывается в экран...) }
          FViewStart := 0;
          vSize := FImgSize;
          CorrectBoundEx(vSize, GWinSize);
          SetAsyncTask(vSize);
        end;
      end;

    finally
      LeaveCriticalSection(FDrawCS);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function CreateView(const AName :TString) :TView;
  var
    vImage :TGPImageEx;
  begin
    Result := nil;
//  TraceF('TGPImageEx.Create: %s...', [AName]);
    vImage := TGPImageEx.Create(AName);
//  TraceF('  Done. Status=%d', [Byte(vImage.GetLastStatus)]);
    if vImage.GetLastStatus = Ok then begin
      Result := TView.Create;
      Result.SetSrcImage(vImage);
      Result.FSrcName := AName;
    end else
      FreeObj(vImage);
  end;


  var
    ActiveView :TView;

  procedure SetActiveView(AView :TView);
  begin
    if ActiveView <> AView then begin
      if ActiveView <> nil then
        ActiveView.Deactivate;
      ActiveView := AView;
      if AView <> nil then begin
        AView.FFirstDraw := True;
        AView.FHiQual := True;  {???}
        AView.FDraftStart := 0;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые функции                                                      }
 {-----------------------------------------------------------------------------}

  function pvdInit2(pInit :PPVDInitPlugin2) :integer; stdcall;
  begin
//  Trace('pvdInit2');
    GRegPath := pInit.pRegKey;
    ReadSettings(GRegPath);
    Result := PVD_UNICODE_INTERFACE_VERSION;
  end;


  procedure pvdExit2(pContext :Pointer); stdcall;
  begin
//  Trace('pvdExit2');
    DoneIdleThread;
    DoneThumbnailThread;
  end;


  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  begin
//  Trace('pvdPluginInfo2');
    pPluginInfo.pName := 'GDIPlus';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2009, Maxim Rusov';
    pPluginInfo.Flags := PVD_IP_DECODE or PVD_IP_DISPLAY or PVD_IP_PRIVATE;
    pPluginInfo.Priority := $0F00;
  end;


  procedure pvdReloadConfig2(pContext :Pointer); stdcall;
  begin
//  Trace('pvdReloadConfig2');
    ReadSettings(GRegPath);
  end;


  procedure pvdGetFormats2(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  begin
//  Trace('pvdGetFormats2');
    pFormats.pSupported := 'JPG,JPEG,JPE,PNG,GIF,TIF,TIFF,EXIF,BMP,DIB,EMF,WMF';
//  pFormats.pSupported := '*';
    pFormats.pIgnored := '';
  end;


  function pvdFileOpen2(pContext :Pointer; pFileName :PWideChar; lFileSize :TInt64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage2) :BOOL; stdcall;
  var
    vView :TView;
  begin
//  TraceF('pvdFileOpen2: %s', [pFileName]);
    Result := False;
//  if StrEqual(ExtractFileName(pFileName), 'CMYK.png') then
//    Exit;

    vView := CreateView(pFileName);
    if vView <> nil then begin

      pImageInfo.nPages := vView.FFrames;
      if vView.FFrames > 1 then
        if vView.FDelays <> nil then
          pImageInfo.Flags := PVD_IIF_ANIMATED
        else
          {pImageInfo.Flags := PVD_IIF_MAGAZINE};

      pImageInfo.pImageContext := vView;
      vView._AddRef;
//    TraceF('  pvdFileOpen2 result: Pages=%d, Size=%d %d', [vView.FFrames, vView.FImgSize.cx, vView.FImgSize.cy]);

      Result := True;
    end;
  end;


  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  begin
//  TraceF('pvdPageInfo2: ImageContext=%p', [pImageContext]);
    with TView(pImageContext) do begin

      SetFrame(pPageInfo.iPage);

      if FFrames > 1 then begin
        if (FDelays <> nil) and (FFrame < FDelCount) then
          pPageInfo.lFrameTime := PDelays(FDelays.Value)[FFrame] * 10;
        if pPageInfo.lFrameTime = 0 then
          pPageInfo.lFrameTime := cAnimationStep;
      end;

      pPageInfo.lWidth := FImgSize.cx;
      pPageInfo.lHeight := FImgSize.cy;
      pPageInfo.nBPP := FPixels;
//    TraceF('  pvdPageInfo2 result: Page=%d, Size=%d %d', [pPageInfo.iPage, FImgSize.cx, FImgSize.cy]);

      Result := True;
    end;
  end;


  function pvdPageDecode2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  begin
//  TraceF('pvdPageDecode2: ImageContext=%p; Size=%d x %d', [pImageContext, pDecodeInfo.lWidth, pDecodeInfo.lHeight]);
    with TView(pImageContext) do begin
//    TraceF('pvdPageDecode2: %s', [FSrcName]);

      if UseThumbnail = not (GetKeyState(VK_Shift) < 0) then
        if not FDirectDraw and (FFrames = 1) then
          InitThumbnail(0, 0 {cThumbSize, cThumbSize} );

//    if (FFrames = 1) {???} then
        FViewStart := GetTickCount;

      pDecodeInfo.lWidth := FImgSize.cx;
      pDecodeInfo.lHeight := FImgSize.cy;
      pDecodeInfo.nBPP := FPixels;
      pDecodeInfo.ColorModel := PVD_CM_PRIVATE;

      pDecodeInfo.Flags := PVD_IDF_READONLY or PVD_IDF_PRIVATE_DISPLAY;
      pDecodeInfo.pImage := pImageContext;
      Result := True;
    end;
  end;


  procedure pvdPageFree2(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2); stdcall;
  begin
//  Trace('pvdPageFree2');
  end;


  procedure pvdFileClose2(pContext :Pointer; pImageContext :Pointer); stdcall;
  begin
//  Trace('pvdFileClose2');
    if pImageContext <> nil then
      TView(pImageContext)._Release;
  end;


 {-----------------------------------------------------------------------------}

  // Инициализация контекста дисплея. Используется тот pContext, который был получен в pvdInit2
  function pvdDisplayInit2(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;
  begin
//  TraceF('pvdDisplayInit2: Context=%p; hWND=%d', [pContext, pDisplayInit.hWND]);
    Result := True;
  end;


  // Прицепиться или отцепиться от окна вывода
  function pvdDisplayAttach2(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;
  begin
//  TraceF('pvdDisplayAttach2: Attach=%d, Wnd=%d', [Byte(pDisplayAttach.bAttach), pDisplayAttach.hWnd]);
    Result := True;
  end;


  // Создать контекст для отображения картинки в pContext (перенос декодированных данных в видеопамять)
  function pvdDisplayCreate2(pContext :Pointer; pDisplayCreate :PPVDInfoDisplayCreate2) :BOOL; stdcall;
  var
    vView :TView;
  begin
//  TraceF('pvdDisplayCreate2: Context=%p', [pContext]);
    vView := pDisplayCreate.pImage.pImage;
    pDisplayCreate.pDisplayContext := vView;
    vView._AddRef;
    Result := True;
  end;


  // Собственно отрисовка. Функция должна при необходимости выполнять "Stretch"
  function pvdDisplayPaint2(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;
  var
    vView :TView;
  begin
//  TraceF('pvdDisplayPaint2: DisplayContext=%p, hWnd=%d, Operation=%d', [pDisplayContext, pDisplayPaint.hWnd, pDisplayPaint.Operation]);
    vView := pDisplayContext;
    SetActiveView(vView);
    case pDisplayPaint.Operation of
      PVD_IDP_BEGIN:
        vView.BeginDraw(pDisplayPaint.hWnd);
//    PVD_IDP_COLORFILL:
//      if vView.FDirectDraw then
//        vView.FillBack(pDisplayPaint.DisplayRect, pDisplayPaint.nBackColor);
      PVD_IDP_PAINT:
        vView.DrawImage(pDisplayPaint.ImageRect, pDisplayPaint.DisplayRect, pDisplayPaint.nBackColor);
      PVD_IDP_COMMIT:
        vView.EndDraw(pDisplayPaint.hWnd);
    end;
    Result := True;
  end;


  // Закрыть контекст для отображения картинки (освободить видеопамять)
  procedure pvdDisplayClose2(pContext :Pointer; pDisplayContext :Pointer); stdcall;
  var
    vView :TView;
  begin
//  TraceF('pvdDisplayClose2: DisplayContext=%p', [pDisplayContext]);
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
//  Trace('pvdDisplayExit2');
    DoneIdleThread;
  end;


end.


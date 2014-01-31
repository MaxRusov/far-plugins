{$I Defines.inc}

{-$Define bShareImage}
{$Define bHookWindow}
{$Define bOwnRotate}
{-$Define bTracePvd}


unit GDIPlusMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDIPlus Main                                                               *}
{******************************************************************************}

{
TODO:

Требуется:
  + Улучшение вида сообщений.
  + Удаление сообщений об ошибках
  + Более подробные сообщения об ошибках rendering'а

  + Запрет поворотов анимированных GIF'ов (или реализация?)
  + Запрет сохранения многостраничных изображений (или реализация)

  + Публикация настроек

Желательно:
  + Заменить StretchBlt на вывод через GDI+?
  
  - Сохранение даты при сохранении изображений
  - Не блокировать файл для многостраничных изображений
  - Анализировать наличие эскизов

На будущее:
  + Не рендерится большое повернутое изображение
  + Оптимизация поворотов (без повторного рендеринга)
  - Оптимизация для рендеринга многостраничных TIF'ов
  - Оптимизация поворотов для многостраничных TIF'ов
  - Анимация поворотов
  - Настройка кнопок
  - Copy to clipboard
}

interface

  uses
    Windows,
    ActiveX,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    GDIPAPI,
    GDIPOBJ,
    GDIImageUtil,
    PVApi;

  const
    cUseThumbnailRegKey   = 'UseThumbnail';
    cDecodeOnReduceRegKey = 'DecodeOnReduce';
    cRotateOnEXIFRegKey   = 'RotateOnEXIF';
    cEnableHookRegKey     = 'EnableHook';
    cEXIFRotationRegKey   = 'EXIFRotation';

  const
    cAnimationStep     = 100;          {ms }
    cThumbSize         = 128;          { Размер извлекаемого эскиза }
    cRescalePerc       = 5;

    { Увеличение размера эскиза больше размера оригинального изображения }
    { Полезно, так как получается лучшее качество, чем при StretchBlt }

    cOverscaleK        = 1.0;          { Максимальный коэффициент увеличинного эскиза }
    cOverscaleLimit    = 132;          { Ограничение размера увеличинного эскиза, в M }

  var
    WaitDelay        :Integer = 1000;  { Сколько ждем декодирование, прежде чем показать эскиз. Только при первом открытии. }
    DraftDelay       :Integer = 125;   { Задержка для аккурaтной перерисовки }
    StretchDelay     :Integer = 500;   { Задержка для масштабирования }
    PrecacheDelay    :Integer = 100;   { Задержка для предварительного масштабирования }
    TmpMessageDelay  :Integer = 1500;

    FastListDelay    :Integer = 500;
    ThumbDelay       :Integer = 250;   { Задержка до начала декодирования при перелистывании }

    UseThumbnail     :Boolean = True;
    DecodeOnReduce   :Boolean = False;
    RotateOnEXIF     :Boolean = True;
    EnableHook       :Boolean = True;
    QuickRotate      :Boolean = True;   { Поворот без повторного декодирования }
    SaveRotateEXIF   :Boolean = False;  { При сохранении повернутого изображения производится только коррекция EXIF заголовка }


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


  const
    strFileNotFound       = 'File not found: %s';
    strNoEncoderFor       = 'No encoder for %s';
    strReadImageError     = 'Read image error';
    strLossyRotation      = 'Rotation is a lossy. Shift+F2 to confirm.';
    strCantSaveFrames     = 'Can''t save mutliframe image';
    strCantRotateAnimated = 'Can''t rotate animated image';


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


  procedure RotateImage(AImage :TGPImage; AOrient :Integer);
  begin
    if AOrient <> 0 then begin
      case AOrient of
        3: AImage.RotateFlip(Rotate180FlipNone);
        6: AImage.RotateFlip(Rotate90FlipNone);
        8: AImage.RotateFlip(Rotate270FlipNone);

        2: AImage.RotateFlip(RotateNoneFlipX);
        4: AImage.RotateFlip(RotateNoneFlipY);
        5: AImage.RotateFlip(Rotate90FlipX);
        7: AImage.RotateFlip(Rotate270FlipX);
      end;
    end;
  end;


  function RandomColor :DWORD;
  begin
    Result := RGB(Random(256), Random(256), Random(256));
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
      if not RegQueryBinByte(vKey, cRotateOnEXIFRegKey, Byte(RotateOnEXIF)) then
        RegWriteBinByte(vKey, cRotateOnEXIFRegKey, Byte(RotateOnEXIF));
      if not RegQueryBinByte(vKey, cEnableHookRegKey, Byte(EnableHook)) then
        RegWriteBinByte(vKey, cEnableHookRegKey, Byte(EnableHook));
      if not RegQueryBinByte(vKey, cEXIFRotationRegKey, Byte(SaveRotateEXIF)) then
        RegWriteBinByte(vKey, cEXIFRotationRegKey, Byte(SaveRotateEXIF));
    finally
      RegCloseKey(vKey);
    end;

    vStr := APath + '\Description';
    RegOpenWrite(HKCU, vStr, vKey);
    try
      RegWriteStr(vKey, cUseThumbnailRegKey, 'bool;Use Thumbnail');
      RegWriteStr(vKey, cDecodeOnReduceRegKey, 'bool;Decode on Reduce');
      RegWriteStr(vKey, cRotateOnEXIFRegKey, 'bool;Autorotate On EXIF');
      RegWriteStr(vKey, cEnableHookRegKey, 'bool;Enable manual rotation');
      RegWriteStr(vKey, cEXIFRotationRegKey, 'bool;EXIF correction on save');
    finally
      RegCloseKey(vKey);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TGPImageEx = class(TGPImage)
//  TGPImageEx = class(TGPBitmap)
    public
      function _AddRef :Integer;
      function _Release :Integer;

      function GetImageSize :TSize;

      function Clone :TGPImageEx;

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


  function TGPImageEx.GetImageSize :TSize;
  begin
    Result := Size(GetWidth, GetHeight);
  end;


  function TGPImageEx.Clone :TGPImageEx;
  var
    cloneimage: GpImage;
  begin
    cloneimage := nil;
    SetStatus(GdipCloneImage(nativeImage, cloneimage));
    result := TGPImageEx.Create(cloneimage, lastResult);
  end;


 {-----------------------------------------------------------------------------}
 { TThumbnailThread                                                            }
 {-----------------------------------------------------------------------------}

  var
    { GDIPlus не поддерживает многопоточную работу. Используем критическую секцию, }
    { чтобы, по возможности, избежать блокировок... }
    GDIPlusCS :TRTLCriticalSection;


  type
    TTaskState = (
      tsNew,
      tsProceed,
      tsReady,
      tsCancelled
    );

    TTask = class(TBasis)
    public
      constructor CreateEx({$ifdef bShareImage}AImage :TGPImageEx;{$endif bShareImage} const AName :TString; AFrame :Integer; const ASize :TSize);
      destructor Destroy; override;

      function _AddRef :Integer;
      function _Release :Integer;

    private
      FRefCount   :Integer;
     {$ifdef bShareImage}
      FImage      :TGPImageEx;
     {$endif bShareImage}
      FName       :TString;
      FFrame      :Integer;
      FSize       :TSize;
      FOrient     :Integer;
      FBackColor  :Integer;
      FThumb      :TMemDC;
      FState      :TTaskState;
      FError      :TString;
      FOnTask     :TNotifyEvent;
      FNext       :TTask;
    end;


  constructor TTask.CreateEx({$ifdef bShareImage}AImage :TGPImageEx;{$endif bShareImage} const AName :TString; AFrame :Integer; const ASize :TSize);
  begin
    inherited Create;
   {$ifdef bShareImage}
    FImage := AImage;
    FImage._AddRef;
   {$endif bShareImage}
    FName  := AName;
    FFrame := AFrame;
    FSize  := ASize;
    FBackColor := -1;
  end;


  destructor TTask.Destroy; {override;}
  begin
   {$ifdef bShareImage}
    if FImage <> nil then begin
      FImage._Release;
      FImage := nil;
    end;
   {$endif bShareImage}
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


  function ImageAbortProc(AData :Pointer) :BOOL; stdcall;
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
    vImage    :TGPImageEx;
    vSize     :TSize;
    vThumb    :TMemDC;
    vGraphics :TGPGraphics;
    vDimID    :TGUID;
    vCallback :Pointer;
  begin
    try
      EnterCriticalSection(GDIPlusCS);
      try
        vThumb := nil;
        vSize := ATask.FSize;
       {$ifdef bShareImage}
        vImage := ATask.FImage;
       {$else}
        vImage := TGPImageEx.Create(ATask.FName);
       {$endif bShareImage}
        try
          if vImage.GetLastStatus <> OK then
            AppError(strReadImageError);

          if ATask.FFrame > 0 then begin
            FillChar(vDimID, SizeOf(vDimID), 0);
            if vImage.GetFrameDimensionsList(@vDimID, 1) = Ok then
              vImage.SelectActiveFrame(vDimID, ATask.FFrame);
          end;

         {$ifdef bOwnRotate}
          if ATask.FOrient in [5,6,7,8] then
            vSize := Size(vSize.CY, vSize.CX);
         {$endif bOwnRotate}

          vThumb := TMemDC.Create(0, vSize.CX, vSize.CY);

//        GradientFillRect(vThumb.FDC, Rect(0, 0, vSize.CX, vSize.CY), RandomColor, RandomColor, True);
          if ATask.FBackColor <> -1 then
            GradientFillRect(vThumb.DC, Rect(0, 0, vSize.CX, vSize.CY), ATask.FBackColor, ATask.FBackColor, True);

          vGraphics := TGPGraphics.Create(vThumb.DC);
          try
            GDICheck(vGraphics.GetLastStatus);
//          vGraphics.SetCompositingMode(CompositingModeSourceCopy);
//          vGraphics.SetCompositingQuality(CompositingQualityHighSpeed);
//          vGraphics.SetSmoothingMode(SmoothingModeHighQuality);
            if ATask.FFrame > 0 then 
              vGraphics.SetInterpolationMode(InterpolationModeHighQuality);

           {$ifdef bTrace}
            TraceBegF('Render %s, %d x %d (%d M)...', [ATask.FName, vSize.CX, vSize.CY, (vSize.CX * vSize.CY * 4) div (1024 * 1024)]);
           {$endif bTrace}

           {$ifdef bOwnRotate}
           {$else}
            if ATask.FOrient <> 0 then begin
              RotateImage(vImage, ATask.FOrient);
              GDICheck(vImage.GetLastStatus);
            end;
           {$endif bOwnRotate}

            vCallback := @ImageAbortProc;
            vGraphics.DrawImage(vImage, MakeRect(0, 0, vSize.CX, vSize.CY), 0, 0, vImage.GetWidth, vImage.GetHeight, UnitPixel, nil, ImageAbort(vCallback), ATask);
            GDICheck(vGraphics.GetLastStatus);

           {$ifdef bTrace}
            TraceEnd('  Ready');
           {$endif bTrace}

          finally
            FreeObj(vGraphics);
          end;

         {$ifdef bOwnRotate}
          if ATask.FOrient <> 0 then
            vThumb.Transform(ATask.FOrient);
         {$endif bOwnRotate}

          ATask.FThumb := vThumb;
          vThumb := nil;

        finally
         {$ifdef bShareImage}
         {$else}
          FreeObj(vImage);
         {$endif bShareImage}
          FreeObj(vThumb);
        end;
      finally
        LeaveCriticalSection(GDIPlusCS);
      end;

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
    GBackColor     :DWORD;
    GWinSize       :TSize;

  var
    GSmoothMode    :Boolean;      { Сглаженный вывод (переключается по Ctrl-T) }

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
      procedure ReinitImage;
      procedure SetSrcImage(AImage :TGPImageEx);
      procedure ReleaseSrcImage;
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
      function Rotate(ARotate :Integer) :Boolean;
      function Save(AWnd :HWnd; AExif, ALossy :Boolean) :Boolean;

      procedure SetSmoothMode(AOn :Boolean);
      procedure SetTmpMess(const AMess :TString);

    private
      FRefCount    :Integer;

      FID          :Integer;      { Уникальный идентификатор }
      FSrcName     :TString;      { Имя файла }
      FSrcImage    :TGPImageEx;   { Исходное изображение }
      FOrient0     :Integer;      { Исходная ориентация }
      FOrient      :Integer;      { Текущая ориентация }
      FImgSize0    :TSize;        { Исходный размер картинки (текущей страницы) }
      FImgSize     :TSize;        { Размер картинки с учетом ориентации }
      FPixels      :Integer;      { Цветность (BPP) }
      FFmtID       :TGUID;
      FFmtName     :TString;
      FHasAlpha    :Boolean;      { Полупрозрачное изображение }
      FDirectDraw  :Boolean;      { Анимированное изображение, не используем preview'шки }
//    FSmoothMode  :Boolean;      { Сглаженный вывод (переключается по Ctrl-T) }
      FOverscaleK  :Double;       { Коэффициент максимального превышения масштаба эскиза }

      FThumbImage  :TMemDC;       { Изображение, буферизированное как Bitmap }
      FThumbSize   :TSize;        { Размер Preview'шки }
      FIsThumbnail :Boolean;      { Это превью (thumbnail) }
      FErrorMess   :TString;
      FTmpMess     :TString;
      FTmpTime     :DWORD;        { Время удаления временного сообщения }

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

      procedure InitImageInfo;
      procedure SetAsyncTask(const ASize :TSize);
      function CheckAsyncTask :Boolean;
      procedure CancelTask;
      procedure TaskEvent(ASender :Tobject);
      procedure Idle(ASender :Tobject);
    end;


  constructor TView.Create; {override;}
  var
    vFirst :Boolean;
  begin
    inherited Create;
    InitializeCriticalSection(FDrawCS);

    vFirst := GIdleThread = nil;
    InitIdleThread;
    GIdleThread.AddIdle(Idle);

    Inc(GViewID);
    FID := GViewID;
    FFrame := -1;

    if vFirst then begin
      GSmoothMode := True;
    end;
  end;


  destructor TView.Destroy; {override;}
  begin
//  TraceF('%p TView.Destroy', [Pointer(Self)]);

    if GIdleThread <> nil then
      GIdleThread.DeleteIdle(Idle);

    DeleteCriticalSection(FDrawCS);

    CancelTask;
    FreeObj(FThumbImage);
    MemFree(FDelays);

    ReleaseSrcImage;
    inherited Destroy;
  end;


  procedure TView.ReleaseSrcImage;
  begin
    if FSrcImage <> nil then begin
      FSrcImage._Release;
      FSrcImage := nil;
    end;
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
    vOrient :Integer;
  begin
    FSrcImage := AImage;
    FSrcImage._AddRef;

//  TraceExifProps(FSrcImage);

    FOrient0 := 0;
    if RotateOnEXIF then
      if GetExifTagValueAsInt(FSrcImage, PropertyTagOrientation, vOrient) and (vOrient >= 1) and (vOrient <= 8) then begin
//      TraceF('EXIF Orientation: %d', [vOrient]);
        FOrient0 := vOrient;
      end;
    FOrient := FOrient0;

    InitImageInfo;
  end;


(*
  procedure TView.ReinitImage;
  begin
    ReleaseSrcImage;
    MemFree(FDelays);

    FSrcImage := TGPImageEx.Create(FSrcName);
    FSrcImage._AddRef;

    InitImageInfo;
  end;
*)

  procedure TView.ReinitImage;
  begin
    if FDirectDraw or not QuickRotate then begin
      ReleaseSrcImage;
      MemFree(FDelays);

      FSrcImage := TGPImageEx.Create(FSrcName);
      FSrcImage._AddRef;

      FFrame := -1;
      InitImageInfo;
    end else
    begin
    end;
  end;


  procedure TView.InitImageInfo;
  begin
    FImgSize0 := FSrcImage.GetImageSize;
    FImgSize := FImgSize0;
    if FOrient in [5,6,7,8] then
      FImgSize := Size(FImgSize.CY, FImgSize.CX);

    FPixels   := GetPixelFormatSize(FSrcImage.GetPixelFormat);

    FSrcImage.GetRawFormat(FFmtID);
    FFmtName := GetImgFmtName(FFmtID);

    { Изображение полупрозрачное }
    FHasAlpha := UINT(ImageFlagsHasAlpha) and FSrcImage.GetFlags <> 0;

    { Подсчитываем количество фреймов в анимированном/многостраничном изображении }
    FFrames := GetFrameCount(FSrcImage, @FDimID, @Pointer(FDelays), @FDelCount);

    FDirectDraw := {FHasAlpha or} (FDelays <> nil);

    FOverscaleK := sqrt( cOverscaleLimit * 1024 * 1024 / (FImgSize.CX * FImgSize.CY * 4) );
    if FOverscaleK < 1 then
      FOverscaleK := 1
    else
    if FOverscaleK > cOverscaleK then
      FOverscaleK := cOverscaleK;
  end;


  procedure TView.SetFrame(AIndex :Integer);
  begin
    AIndex := RangeLimit(AIndex, 0, FFrames - 1);
    if AIndex <> FFrame then begin
      if (FFrames > 1) and (AIndex < FFrames) then
        FSrcImage.SelectActiveFrame(FDimID, AIndex);

      FImgSize := FSrcImage.GetImageSize;
      if FOrient in [5,6,7,8] then
        FImgSize := Size(FImgSize.CY, FImgSize.CX);

      FPixels  := GetPixelFormatSize(FSrcImage.GetPixelFormat);

      CancelTask;
      FreeObj(FThumbImage);
      FErrorMess := '';

      FFrame := AIndex;
    end;
  end;


  function TView.InitThumbnail(ADX, ADY :Integer) :Boolean;
  var
    vThmImage :TGPImage;
    vGraphics :TGPGraphics;
  begin
//  TraceF('UpdateThumbnail: %d x %d', [ADX, ADY]);
    Result := False;

   if not IsEqualGUID(FFmtID, ImageFormatJPEG) then
     { Эскизы поддерживаются только(?) для JPEG... }
     Exit;

   {$ifdef bTrace}
    TraceBegF('GetThumbnail: %d x %d', [ADX, ADY]);
   {$endif bTrace}
    vThmImage := FSrcImage.GetThumbnailImage(ADX, ADY, nil, nil);
   {$ifdef bTrace}
    TraceEnd('  Ready');
   {$endif bTrace}
    if (vThmImage = nil) or (vThmImage.GetLastStatus <> Ok) then begin
      FreeObj(vThmImage);
      Exit;
    end;

    try
      if FOrient <> 0 then
        RotateImage(vThmImage, FOrient);

      FThumbSize.cx := vThmImage.GetWidth;
      FThumbSize.cy := vThmImage.GetHeight;
      FIsThumbnail := True;

     {$ifdef bTrace}
      TraceBegF('Thumb Render %d x %d...', [FThumbSize.cx, FThumbSize.cy]);
     {$endif bTrace}
      FThumbImage := TMemDC.Create(0, FThumbSize.cx, FThumbSize.cy);
      vGraphics := TGPGraphics.Create(FThumbImage.DC);
      try
        vGraphics.DrawImage(vThmImage, 0, 0, FThumbSize.cx, FThumbSize.cy);
      finally
        vGraphics.Free;
      end;
     {$ifdef bTrace}
      TraceEnd('  Ready');
     {$endif bTrace}

      Result := True;

    finally
      FreeObj(vThmImage);
    end;
  end;


  function TView.Rotate(ARotate :Integer) :Boolean;
  const
    cReorient :array[0..8, 0..4] of Integer = (
     (0,6,8,2,4), //
     (1,6,8,2,4), //
     (2,7,5,0,3), // X
     (3,8,6,4,2), // LL = RR
     (4,5,7,3,0), // Y
     (5,2,4,6,8), // XR
     (6,3,0,5,7), // R
     (7,4,2,8,6), // XL
     (8,0,3,7,5)  // L
    );
    cTransform :array[0..4] of Integer =
      (0, 6, 8, 2, 4);
  begin
    Result := False;
    try
      if not FDirectDraw and QuickRotate then begin
        { Поворачиваем уже декодированный эскиз }
        FThumbImage.Transform(cTransform[ARotate]);

        if ARotate in [1, 2] then
          FThumbSize := Size(FThumbSize.CY, FThumbSize.CX);

        if ARotate in [1, 2] then
          FImgSize := Size(FImgSize.CY, FImgSize.CX);
      end;

      FOrient := cReorient[FOrient, ARotate];

      Result := True;

    except
      on E :Exception do begin
        SetTmpMess( E.Message );
        Beep;
      end;
    end;
  end;


  procedure ReplaceFile(const ATmpName, AOrigName :TString);
  begin
    if WinFileExists(AOrigName) then
      ApiCheck(DeleteFile(AOrigName));
    ApiCheck(RenameFile(ATmpName, AOrigName));
  end;


  function TView.Save(AWnd :HWnd; AExif, ALossy :Boolean) :Boolean;
  const
    cTransform :array[0..8] of EncoderValue =
    (
      EncoderValue(0),
      EncoderValue(0),
      EncoderValueTransformFlipHorizontal,
      EncoderValueTransformRotate180,
      EncoderValueTransformFlipVertical,
      EncoderValueTransformRotate270,  {!!!}
      EncoderValueTransformRotate90,
      EncoderValueTransformRotate90, {!!!}
      EncoderValueTransformRotate270
    );
  var
    vMimeType, vNewName :TString;
    vEncoderID :TGUID;
    vImage :TGPImage;
    vTransf :TEncoderValue;
    vParams :TEncoderParameters;
    vPParams :PEncoderParameters;
  begin
    Result := False;
    try
      FTmpMess := 'Save...';
      FTmpTime := 0;
      InvalidateRect(AWnd, nil, False);
      UpdateWindow(AWnd);

      if not WinFileExists(FSrcName) then
        AppErrorFmt(strFileNotFound, [FSrcName]);

      vNewName := ChangeFileExtension(FSrcName, '$$$');
      if WinFileExists(vNewName) then
        DeleteFile(vNewName);

      vMimeType := 'image/' + StrLoCase(FFmtName);
      if GetEncoderClsid(vMimeType, vEncoderID) = -1 then
        AppErrorFmt(strNoEncoderFor, [FFmtName]);

      vImage := TGPImage.Create(FSrcName);
      try
//      GDICheck(vImage.GetLastStatus);
        if vImage.GetLastStatus <> OK then
          AppError(strReadImageError);

        if GetFrameCount(vImage, nil, nil, nil) > 1 then
          AppError(strCantSaveFrames);

       {$ifdef bTrace}
        TraceBeg('Save...');
       {$endif bTrace}

        vPParams := nil;

        if AExif and (IsEqualGUID(FFmtID, ImageFormatJPEG) or IsEqualGUID(FFmtID, ImageFormatTIFF)) then begin

          { Поворот путем коррекции EXIF заголовка - loseless }
          if FOrient0 <> FOrient then
            SetExifTagValueInt(vImage, PropertyTagOrientation, FOrient);

        end else
        if IsEqualGUID(FFmtID, ImageFormatJPEG) then begin
          { Поворт путем трансформации - может приводить к потерям... }

          vTransf := cTransform[FOrient];
          if vTransf <> EncoderValue(0) then begin
            vParams.Count := 1;
            vParams.Parameter[0].Guid := EncoderTransformation;
            vParams.Parameter[0].Type_ := EncoderParameterValueTypeLong;
            vParams.Parameter[0].NumberOfValues := 1;
            vParams.Parameter[0].Value := @vTransf;
            vPParams := @vParams;
          end;

          if not ALossy and (vPParams <> nil) and (((vImage.GetWidth mod 16) <> 0) or ((vImage.GetHeight mod 16) <> 0)) then
            AppError(strLossyRotation);

          if (FOrient0 <> 0) and (FOrient0 <> 1) then
            SetExifTagValueInt(vImage, PropertyTagOrientation, 1);

        end else
        begin
          RotateImage(vImage, FOrient);
          GDICheck(vImage.GetLastStatus);
        end;

        vImage.Save(vNewName, vEncoderID, vPParams);
        GDICheck(vImage.GetLastStatus);

       {$ifdef bTrace}
        TraceEnd('  Ready');
       {$endif bTrace}

      finally
        FreeObj(vImage);
      end;

      ReplaceFile(vNewName, FSrcName);

      FTmpMess := '';
      InvalidateRect(AWnd, nil, False);
      UpdateWindow(AWnd);

      Result := True;

    except
      on E :Exception do begin
        SetTmpMess( E.Message );
        Beep;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

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
      SetBkMode(FDC, Transparent);

      SetTextColor(FDC, RGB(0, 0, 0));
      TextOut(FDC, X, Y, PTChar(AStr), Length(AStr));
      SetTextColor(FDC, RGB(255, 255, 255));
      TextOut(FDC, X+1, Y+1, PTChar(AStr), Length(AStr));

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
        GradientFillRect(vImage.DC, Rect(0, 0, vDstRect.Width, vDstRect.Height), AColor, AColor, True);

        vGraphics := TGPGraphics.Create(vImage.DC);
        try
          with ASrcRect do
            vGraphics.DrawImage(FSrcImage, vDstRect, Left, Top, Right - Left, Bottom - Top, UnitPixel);
        finally
          vGraphics.Free;
        end;

        with ADstRect do
          BitBlt(FDC, Left, Top, Right - Left, Bottom - Top, vImage.DC, 0, 0, SRCCOPY);

      finally
        FreeObj(vImage);
      end;
    end;
(*
    procedure LocDirectDraw;
    var
      vGraphics :TGPGraphics;
      vImage :TMemDC;
      vRect :TGPRect;
    begin
      if GSmoothMode then begin
        with ADstRect do
          vRect := MakeRect(0, 0, Right - Left, Bottom - Top);
      end else
        vRect := MakeRect(0, 0, FImgSize.cx, FImgSize.cy);

      vImage := TMemDC.Create(0, vRect.Width, vRect.Height);
      try
        GradientFillRect(vImage.FDC, Rect(0, 0, vRect.Width, vRect.Height), AColor, AColor, True);

        vGraphics := TGPGraphics.Create(vImage.FDC);
        try
          with ASrcRect do
            vGraphics.DrawImage(FSrcImage, vRect, Left, Top, Right - Left, Bottom - Top, UnitPixel);
        finally
          vGraphics.Free;
        end;

        with ADstRect do
          BitBlt(FDC, Left, Top, Right - Left, Bottom - Top, vImage.FDC, 0, 0, SRCCOPY);

      finally
        FreeObj(vImage);
      end;
    end;
*)

    function LocThumbSize(ImgSize, SrcSize, DispSize :Integer) :Integer;
    begin
      if SrcSize = ImgSize then
        Result := DispSize
      else
        Result := MulDiv(ImgSize, DispSize, SrcSize);

      if Result > ImgSize then
        if GSmoothMode then
          { Разрешаем декодирование с повышенным разрешением}
          Result := IntMin(Result, Round(ImgSize * FOverscaleK))
        else
          Result := ImgSize;
    end;

    function LocCalcScale(ADX, ADY :Integer) :Integer;
    begin
      Result := IntMax(MulDiv(ADX, 100, FImgSize.cx), MulDiv(ADY, 100, FImgSize.cy));
    end;


    function LocScaleX(X :Integer) :Integer;
    begin
      Result := MulDiv(X, FThumbImage.Width, FImgSize.cx);
    end;

    function LocScaleY(Y :Integer) :Integer;
    begin
      Result := MulDiv(Y, FThumbImage.Height, FImgSize.cy);
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

      if not Result and not GSmoothMode then
        { Был overscale, который стал нежелательным, из за выключения SmoothMode... }
        Result := (FThumbSize.CX > FImgSize.CX) or (FThumbSize.CY > FImgSize.CY);
    end;

  var
    vSize :TSize;
    vScale :Integer;
    vStart :DWORD;
    vSaveDC :Integer;
    vFastScroll, vNeedSmooth, vGDILocked, vDecrease :Boolean;
    vDstRect, vSrcRect, vThmRect :TGPRect;
    vRect :TRect;
  begin
    if FDC = 0 then
      Exit;

    { Запоминаем настройки отображения в глобальных переменных, для использования }
    { во вспомогательных потоках. Не thread-safe'но, но не страшно... }
    GBackColor := AColor;

    vSrcRect := MakeRect(ASrcRect);
    vDstRect := MakeRect(ADstRect);

   {$ifdef bTrace}
//  TraceBegF('Paint (%p) %s...', [Pointer(FThumbImage), ExtractFileName(FSrcName)]);
   {$endif bTrace}

//  TraceF('Src: %d, %d, %d, %d. Dst: %d, %d, %d, %d',
//    [vSrcRect.X, vSrcRect.Y, vSrcRect.Width, vSrcRect.Height,
//     vDstRect.X, vDstRect.Y, vDstRect.Width, vDstRect.Height]);

    if FDirectDraw then
      LocDirectDraw
    else begin
      vSize.cx := LocThumbSize(FImgSize.cx, vSrcRect.Width, vDstRect.Width);
      vSize.cy := LocThumbSize(FImgSize.cy, vSrcRect.Height, vDstRect.Height);

      if (FThumbImage = nil) or (FIsThumbnail and (FAsyncTask = nil)) then begin

        { Определяем режим "быстрой прокрутки"}
        vFastScroll := (TickCountDiff(GetTickCount, GLastPaint) < FastListDelay);
        if vFastScroll then
          GLastPaint1 := GetTickCount;

        vScale := LocCalcScale(vSize.cx, vSize.cy);
        if (vScale > 90) and (vScale <= 100) then
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
          vThmRect := MakeRect(Rect(LocScaleX(Left), LocScaleY(Top), LocScaleX(Right), LocScaleY(Bottom)));

        if FHiQual and not FIsThumbnail and not FFirstDraw then
          if not RectEquals(FPrevSrcRect, ASrcRect) or not RectEquals(FPrevDstRect, ADstRect) then
            FHiQual := False;

        FPrevSrcRect := ASrcRect;
        FPrevDstRect := ADstRect;

        { Возможна погрешность масштабирования в рдин пиксел, учтем, чтобы не делать лишний Stretch }
        if (Abs(vDstRect.Width - vThmRect.Width) <= 1) and (Abs(vDstRect.Height - vThmRect.Height) <= 1) then begin
         {$ifdef bTrace}
//        TraceF('BitBlt. Thumb=%d', [Byte(FIsThumbnail)]);
         {$endif bTrace}
          BitBlt(
            FDC,
            vDstRect.X, vDstRect.Y, vDstRect.Width, vDstRect.Height,
            FThumbImage.DC,
            vThmRect.X, vThmRect.Y,
            SRCCOPY);
          FDraftStart := 0;
        end else
        begin
          { Масштабирование с уменьшением }
          vDecrease := vDstRect.Width < vThmRect.Width;

          { При уменьшении масштаба всегда делаем сглаживание }
          vNeedSmooth := (GSmoothMode or vDecrease) and not FIsThumbnail;

          vGDILocked := False;
          if FHiQual and vNeedSmooth then
            vGDILocked := TryEnterCriticalSection(GDIPlusCS);
          try

            if FHiQual and vNeedSmooth and vGDILocked then begin
              { Аккуратный, но медленный - режим масштабирования со сглаживанием }
              { Уменьшаем при помощи GDI а увеличиваем - при помощи GDI+ }
              { Так достигается оптимальное качество масштабирования }
              { (выяснено экспериментальным путем) }
              if vDecrease then
                GDIStretchDraw(FDC, vDstRect, FThumbImage, vThmRect, True)
              else
                GDIPlusStretchDraw(FDC, vDstRect, FThumbImage, vThmRect, True);
            end else
            begin
              { Быстрый, но не аккуратный }
              GDIStretchDraw(FDC, vDstRect, FThumbImage, vThmRect, False);

              { Аккуратная перерисовка - с небольшой задержкой }
              if vNeedSmooth then
                FDraftStart := GetTickCount;
            end;

          finally
            if vGDILocked then
              LeaveCriticalSection(GDIPlusCS);
          end;
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
        GWinSize := MixStrings.Size(Right - Left, Bottom - Top);
    finally
      RestoreDC(FDC, vSaveDC);
    end;

    if FAsyncTask <> nil then begin
      DrawText(vRect.Left, vRect.Top, 'Decoding...');
      FTmpMess := ''; FTmpTime := 0;
    end else
    if FErrorMess <> '' then begin
      DrawText(vRect.Left, vRect.Top, FErrorMess);
      FTmpMess := ''; FTmpTime := 0;
    end else
    if FTmpMess <> '' then begin
      if (FTmpTime <> 0) and (TickCountDiff(GetTickCount, FTmpTime) > TmpMessageDelay) then begin
        FTmpMess := '';
        FTmpTime := 0;
      end else
        DrawText(vRect.Left, vRect.Top, FTmpMess);
    end;

    if GLastID <> FID then begin
      GLastPaint := GetTickCount;
      GLastID := FID;
    end;

   {$ifdef bTrace}
//  TraceEnd('  Done paint');
   {$endif bTrace}
  end; {DrawImage;}



  procedure TView.SetAsyncTask(const ASize :TSize);
  begin
    InitThumbnailThread;
//  TraceF('SetAsyncTask %s...', [ExtractFileName(FSrcName)]);

    FAsyncTask := TTask.CreateEx({$ifdef bShareImage}FSrcImage,{$endif bShareImage} FSrcName, FFrame, ASize);
    FAsyncTask.FOrient := FOrient;
    if FHasAlpha then
      FAsyncTask.FBackColor := GBackColor;
    FAsyncTask.FOnTask := TaskEvent;
    FAsyncTask._AddRef;

    GThumbThread.AddTask(FAsyncTask);
  end;


  function TView.CheckAsyncTask :Boolean;
  begin
    Result := False;
    if FAsyncTask <> nil then begin
      if GThumbThread.CheckTask(FAsyncTask) then begin

        if FAsyncTask.FThumb <> nil then begin
          FreeObj(FThumbImage);
          FThumbImage  := FAsyncTask.FThumb;
        end;
        
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
          if TryEnterCriticalSection(GDIPlusCS) then begin
            try
//            TraceF('%p.InvalidateRect FWnd=%d', [Pointer(Self), FWnd]);
              FDraftStart := 0;
              FHiQual := True;
              InvalidateRect(FWnd, nil, False);
            finally
              LeaveCriticalSection(GDIPlusCS);
            end;
          end;
        end;

        if (FTmpTime <> 0) and (TickCountDiff(GetTickCount, FTmpTime) > TmpMessageDelay) then begin
          InvalidateRect(FWnd, nil, False);
        end;
      end;

      if (FWnd = 0) and ((FThumbImage = nil) or FIsThumbnail) and (TickCountDiff(GetTickCount, GLastPaint1) > FastListDelay) then begin
        if (FViewStart <> 0) and (TickCountDiff(GetTickCount, FViewStart) > PrecacheDelay) then begin
          { Опережающее декодировани (размер эскиза прогнозируем из расчета того что он вписывается в экран...) }
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


  procedure TView.SetSmoothMode(AOn :Boolean);
  begin
    GSmoothMode := AOn;
    SetTmpMess( 'Smooth mode: ' + StrIf(AOn, 'On', 'Off') );
    FFirstDraw := True;
  end;


  procedure TView.SetTmpMess(const AMess :TString);
  begin
    FTmpMess := AMess;
    FTmpTime := GetTickCount;
    if FWnd <> 0 then
      InvalidateRect(FWnd, nil, False);
  end;



 {-----------------------------------------------------------------------------}
 {                                                                             }
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
//    TraceF('%p TView.Create: %s', [Pointer(Result), AName]);
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
 { Hook                                                                        }
 {-----------------------------------------------------------------------------}

 {$ifdef bHookWindow}

  var
    ModifiedView :TView;

  procedure SetModifiewdView(AView :TView);
  begin
    if ModifiedView <> AView then begin
      if ModifiedView <> nil then
        ModifiedView._Release;
      ModifiedView := AView;
      if ModifiedView <> nil then
        ModifiedView._AddRef;
    end;
  end;


  const
    DMSG_KEYBOARD = WM_APP;

  type
    TWndProc = function(HWindow :HWnd; Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT; stdcall;

  var
    FWindow :THandle;
    FDefProc :TWndProc;



  function MyWndProc(HWindow :HWnd; Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT; stdcall;

    procedure LocRotate(AOrient :Integer);
    begin
      if not ActiveView.FDirectDraw then begin
        if ActiveView.Rotate(AOrient) then begin
          SetModifiewdView(ActiveView);
          PostMessage(HWindow, DMSG_KEYBOARD, VK_F5, 0);
        end;  
      end else
      begin
        ActiveView.SetTmpMess( strCantRotateAnimated );
        Beep;
      end;
    end;

    procedure LocSave(Alt :Boolean);
    var
      vExif :Boolean;
    begin
      vExif := SaveRotateEXIF;
      if Alt then
        vExif := not vExif;
      if ActiveView.Save(HWindow, vExif, SHIFT_PRESSED and LParam <> 0) then begin
        SetModifiewdView(nil);
        PostMessage(HWindow, DMSG_KEYBOARD, VK_F5, 0);
      end;
    end;

  var
    vDefProc :TWndProc;
  begin
    vDefProc := FDefProc;

    if (Msg = DMSG_KEYBOARD) and (ActiveView <> nil) then begin
//    TraceF('Key: %d', [WParam]);

      if (RIGHT_CTRL_PRESSED + LEFT_CTRL_PRESSED) and LParam <> 0 then begin
        case WParam of
          VK_Insert, byte('C'):
            Beep;
          byte('T'):
            ActiveView.SetSmoothMode(not GSmoothMode);
//        190 : LocRotate(1); { > - Поворот по часовой }
//        188 : LocRotate(2); { < - Поворот против часовой }
          190 : LocRotate(3); { [ - X-Flip }
          188 : LocRotate(4); { ] - Y-Flip }
        end;

      end else
      if (RIGHT_ALT_PRESSED + LEFT_ALT_PRESSED) and LParam <> 0 then begin

        case WParam of
          VK_F2:
            LocSave(True);
        end;

      end else
      if (RIGHT_CTRL_PRESSED + LEFT_CTRL_PRESSED + RIGHT_ALT_PRESSED + LEFT_ALT_PRESSED) and LParam = 0 then begin

        case WParam of
          VK_F2:
            LocSave(False);
          190 : LocRotate(1); { > - Поворот по часовой }
          188 : LocRotate(2); { < - Поворот против часовой }
        end;

      end;

    end else
    if Msg = WM_NCDestroy then begin
//    Trace('WM_NCDestroy...');
      FWindow := 0;
    end;

    Result := vDefProc(HWindow, Msg, WParam, LParam);
  end;


  procedure SetWindowHook(AWnd :THandle);
  begin
    FDefProc := Pointer(GetWindowLongPtr(AWnd, GWL_WNDPROC));
    SetWindowLongPtr(AWnd, GWL_WNDPROC, TIntPtr(@MyWndProc));
    FWindow := AWnd;
  end;


  procedure ReleaseWindowHook;
  begin
    if FWindow <> 0 then begin
      SetWindowLongPtr(FWindow, GWL_WNDPROC, TIntPtr(@FDefProc));
      FWindow := 0;
    end;
  end;

 {$endif bHookWindow}


 {-----------------------------------------------------------------------------}
 { Экспортируемые функции                                                      }
 {-----------------------------------------------------------------------------}

  function pvdInit2(pInit :PPVDInitPlugin2) :integer; stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdInit2');
   {$endif bTracePvd}
    GRegPath := pInit.pRegKey;
    ReadSettings(GRegPath);
    Result := PVD_UNICODE_INTERFACE_VERSION;
  end;


  procedure pvdExit2(pContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdExit2');
   {$endif bTracePvd}
    DoneIdleThread;
    DoneThumbnailThread;
  end;


  procedure pvdPluginInfo2(pPluginInfo :PPVDInfoPlugin2); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdPluginInfo2');
   {$endif bTracePvd}
    pPluginInfo.pName := 'GDIPlus';
    pPluginInfo.pVersion := '1.0';
    pPluginInfo.pComments := '(c) 2009, Maxim Rusov';
    pPluginInfo.Flags := PVD_IP_DECODE or PVD_IP_DISPLAY or PVD_IP_PRIVATE or PVD_IP_CANREFINE{???};
    pPluginInfo.Priority := $0F00;
  end;


  procedure pvdReloadConfig2(pContext :Pointer); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdReloadConfig2');
   {$endif bTracePvd}
    ReadSettings(GRegPath);
  end;


  procedure pvdGetFormats2(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  begin
   {$ifdef bTracePvd}
    Trace('pvdGetFormats2');
   {$endif bTracePvd}
    pFormats.pSupported := 'JPG,JPEG,JPE,PNG,GIF,TIF,TIFF,EXIF,BMP,DIB,EMF,WMF'; // '*';
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
   {$ifdef bHookWindow}
    if (ModifiedView <> nil) and StrEqual(ModifiedView.FSrcName, pFileName) then begin
      vView := ModifiedView;
      vView.ReinitImage;
    end;
   {$endif bHookWindow}

    if vView = nil then
      vView := CreateView(pFileName);

    if vView <> nil then begin

      pImageInfo.nPages := vView.FFrames;
      if vView.FFrames > 1 then
        if vView.FDelays <> nil then
          pImageInfo.Flags := PVD_IIF_ANIMATED
        else
          {pImageInfo.Flags := PVD_IIF_MAGAZINE};

      if vView.FFmtName <> '' then
        pImageInfo.pFormatName := PTChar(vView.FFmtName);

      pImageInfo.pImageContext := vView;
      vView._AddRef;
//    TraceF('  pvdFileOpen2 result: Pages=%d, Size=%d %d', [vView.FFrames, vView.FImgSize.cx, vView.FImgSize.cy]);

      Result := True;
    end;
  end;


  function pvdPageInfo2(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  begin
   {$ifdef bTracePvd}
    TraceF('pvdPageInfo2: ImageContext=%p, Frame=%d', [pImageContext, pPageInfo.iPage]);
   {$endif bTracePvd}
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
   {$ifdef bTracePvd}
    TraceF('pvdPageDecode2: ImageContext=%p, Frame=%d, Size=%d x %d', [pImageContext, pDecodeInfo.iPage, pDecodeInfo.lWidth, pDecodeInfo.lHeight]);
   {$endif bTracePvd}
    with TView(pImageContext) do begin
//    TraceF('pvdPageDecode2: %s', [FSrcName]);

      if UseThumbnail = not (GetKeyState(VK_Shift) < 0) then
        if not FDirectDraw and (FFrames = 1) and (FThumbImage = nil) then
          InitThumbnail(0, 0 {cThumbSize, cThumbSize} );

//    if (FFrames = 1) {???} then
        FViewStart := GetTickCount;

      pDecodeInfo.lWidth := FImgSize.cx;
      pDecodeInfo.lHeight := FImgSize.cy;
      pDecodeInfo.nBPP := FPixels;
      pDecodeInfo.ColorModel := PVD_CM_PRIVATE;

      pDecodeInfo.Flags := PVD_IDF_READONLY or PVD_IDF_PRIVATE_DISPLAY;
      pDecodeInfo.pImage := pImageContext;

      if not FDirectDraw and (FFrames = 1) then
        ReleaseSrcImage { Больше не понадобится... }
      else
        { FullCache... };

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
   {$ifdef bHookWindow}
    if EnableHook then
      SetWindowHook(pDisplayInit.hWND);
   {$endif bHookWindow}
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
    Result := True;
  end;


  // Собственно отрисовка. Функция должна при необходимости выполнять "Stretch"
  function pvdDisplayPaint2(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;
  var
    vView :TView;
  begin
   {$ifdef bTracePvd}
//  TraceF('pvdDisplayPaint2: DisplayContext=%p, hWnd=%d, Operation=%d', [pDisplayContext, pDisplayPaint.hWnd, pDisplayPaint.Operation]);
   {$endif bTracePvd}
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
//  Trace('..pvdDisplayPaint2 done');
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
   {$ifdef bHookWindow}
    ReleaseWindowHook;
    SetModifiewdView(nil);
   {$endif bHookWindow}
    DoneIdleThread;
  end;


initialization
  InitializeCriticalSection(GDIPlusCS);

finalization
  DeleteCriticalSection(GDIPlusCS);
end.


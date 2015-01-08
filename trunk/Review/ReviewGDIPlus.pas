{$I Defines.inc}

{$ifndef bAsync}
 {$Define bGDIAsync}
{$endif bAsync}

unit ReviewGDIPlus;

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
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    GDIPAPI,
    GDIPOBJ,
    GDIImageUtil,
    PVApi,

    ReviewConst,
    ReviewDecoders;


  const
    cGDIPlusFormats = 'JPG,JPEG,JPE,PNG,GIF,TIF,TIFF,EXIF,BMP,DIB'; // EMF,WMF;

//const
//  cThumbSize = 128;           { Размер извлекаемого эскиза }


  type
    TReviewGDIDecoder = class(TReviewDecoder)
    public
      constructor Create; override;
      destructor Destroy; override;

      function NeedPrecache :boolean; override;
      procedure ResetSettings; override;
      function GetState :TDecoderState; override;
      function CanWork(aLoad :Boolean) :boolean; override;

      { Функции декодирования }
      function pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; override;
      function pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; override;
      function pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
        const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; override;
      procedure pvdPageFree(AImage :TReviewImageRec); override;
      procedure pvdFileClose(AImage :TReviewImageRec); override;

      function pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; override;

      { Эксклюзивные функции }
      function GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; override;
      function Save(AImage :TReviewImageRec; const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean; override;
     {$ifdef bGDIAsync}
      function Idle(AImage :TReviewImageRec; ACX, ACY :Integer) :boolean; override;
     {$endif bGDIAsync}
    end;


  function TryLockGDIPlus :Boolean;
  procedure LockGDIPlus;
  procedure UnlockGDIPlus;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  const
    strFileNotFound       = 'File not found: %s';
    strNoEncoderFor       = 'No encoder for %s';
    strReadImageError     = 'Read image error';
    strLossyRotation      = 'Rotation is a lossy. Ctrl+F2 to confirm.';
    strCantSaveFrames     = 'Can''t save mutliframe image';



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


 {-----------------------------------------------------------------------------}
 { TGPImageEx                                                                  }
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
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    { GDIPlus не поддерживает многопоточную работу. Используем критическую секцию, }
    { чтобы, по возможности, избежать блокировок... }
    GDIPlusCS :TRTLCriticalSection;


  function TryLockGDIPlus :Boolean;
  begin
    Result := TryEnterCriticalSection(GDIPlusCS);
  end;

  procedure LockGDIPlus;
  begin
    EnterCriticalSection(GDIPlusCS);
  end;

  procedure UnlockGDIPlus;
  begin
    LeaveCriticalSection(GDIPlusCS);
  end;



(*
  function GDIRender(const AName :TString; AImage :TGPImageEx; const ASize :TSize; ACallback :Pointer = nil; ACallbackData :Pointer = nil) :TMemDC;
  var
    vThumb    :TMemDC;
    vGraphics :TGPGraphics;
//  vDimID    :TGUID;
  begin
    vThumb := nil;
    try
//    if ATask.FFrame > 0 then begin
//      FillChar(vDimID, SizeOf(vDimID), 0);
//      if vImage.GetFrameDimensionsList(@vDimID, 1) = Ok then
//        vImage.SelectActiveFrame(vDimID, ATask.FFrame);
//    end;

      vThumb := TMemDC.Create(ASize.CX, ASize.CY);

//    GradientFillRect(vThumb.FDC, Rect(0, 0, vSize.CX, vSize.CY), RandomColor, RandomColor, True);
//    if ATask.FBackColor <> -1 then
//      GradientFillRect(vThumb.DC, Rect(0, 0, vSize.CX, vSize.CY), ATask.FBackColor, ATask.FBackColor, True);

      vGraphics := TGPGraphics.Create(vThumb.DC);
      try
        GDICheck(vGraphics.GetLastStatus);
//      vGraphics.SetCompositingMode(CompositingModeSourceCopy);
//      vGraphics.SetCompositingQuality(CompositingQualityHighSpeed);
//      vGraphics.SetSmoothingMode(SmoothingModeHighQuality);

//      if ATask.FFrame > 0 then
//        vGraphics.SetInterpolationMode(InterpolationModeHighQuality);  ???

       {$ifdef bTrace}
        TraceBegF('Render %s, %d x %d (%d M)...', [AName, ASize.CX, ASize.CY, (ASize.CX * ASize.CY * 4) div (1024 * 1024)]);
       {$endif bTrace}

        vGraphics.DrawImage(AImage, MakeRect(0, 0, ASize.CX, ASize.CY), 0, 0, AImage.GetWidth, AImage.GetHeight, UnitPixel, nil, ACallback, ACallbackData);
        GDICheck(vGraphics.GetLastStatus);

       {$ifdef bTrace}
        TraceEnd('  Ready');
       {$endif bTrace}

      finally
        FreeObj(vGraphics);
      end;

      Result := vThumb;
      vThumb := nil;

    finally
      FreeObj(vThumb);
    end;
  end;
*)


  type
    PContextRec = ^TContextRec;
    TContextRec = record
      Callback :TDecodeCallback;
      Data :Pointer;
    end;


  function MyGDIPlusCallback(AData :Pointer) :BOOL; stdcall;
  var
    vContinue :Boolean;
  begin
    vContinue := True;
    with PContextRec(AData)^ do
      if Assigned(Callback) then
        Callback(Data, 0, vContinue);
    Result := not vContinue;
   {$ifdef bTrace}
    if Result then
      Trace('!Canceled');
   {$endif bTrace}
  end;


  function GDIRender(const AName :TString; AImage :TGPImageEx; const ASize :TSize; const ACallback :TDecodeCallback; ACallbackData :Pointer) :TMemDC;
  var
    vThumb    :TMemDC;
    vGraphics :TGPGraphics;
//  vDimID    :TGUID;
    vContext :TContextRec;
  begin
    vThumb := nil;
    try
//    if ATask.FFrame > 0 then begin
//      FillChar(vDimID, SizeOf(vDimID), 0);
//      if vImage.GetFrameDimensionsList(@vDimID, 1) = Ok then
//        vImage.SelectActiveFrame(vDimID, ATask.FFrame);
//    end;

      vThumb := TMemDC.Create(ASize.CX, ASize.CY);

//    GradientFillRect(vThumb.FDC, Rect(0, 0, vSize.CX, vSize.CY), RandomColor, RandomColor, True);
//    if ATask.FBackColor <> -1 then
//      GradientFillRect(vThumb.DC, Rect(0, 0, vSize.CX, vSize.CY), ATask.FBackColor, ATask.FBackColor, True);

      vGraphics := TGPGraphics.Create(vThumb.DC);
      try
        GDICheck(vGraphics.GetLastStatus);
//      vGraphics.SetCompositingMode(CompositingModeSourceCopy);
//      vGraphics.SetCompositingQuality(CompositingQualityHighSpeed);
//      vGraphics.SetSmoothingMode(SmoothingModeHighQuality);

//      if ATask.FFrame > 0 then
//        vGraphics.SetInterpolationMode(InterpolationModeHighQuality);  ???

       {$ifdef bTrace}
        TraceBegF('Render %s, %d x %d (%d M)...', [AName, ASize.CX, ASize.CY, (ASize.CX * ASize.CY * 4) div (1024 * 1024)]);
       {$endif bTrace}

        vContext.Callback := ACallback;
        vContext.Data := ACallbackData;

        vGraphics.DrawImage(AImage, MakeRect(0, 0, ASize.CX, ASize.CY), 0, 0, AImage.GetWidth, AImage.GetHeight, UnitPixel, nil, MyGDIPlusCallback, @vContext);
        GDICheck(vGraphics.GetLastStatus);

       {$ifdef bTrace}
        TraceEnd('  Ready');
       {$endif bTrace}

      finally
        FreeObj(vGraphics);
      end;

      Result := vThumb;
      vThumb := nil;

    finally
      FreeObj(vThumb);
    end;
  end;

 {-----------------------------------------------------------------------------}
 { TRenderThread                                                               }
 {-----------------------------------------------------------------------------}

 {$ifdef bGDIAsync}
  type
    TTaskState = (
      tsNew,
      tsProceed,
      tsReady,
      tsCancelled
    );

    TTask = class(TBasis)
    public
      constructor CreateEx(AImage :TGPImageEx; const AName :TString; AFrame :Integer; const ASize :TSize);
      destructor Destroy; override;

      function _AddRef :Integer;
      function _Release :Integer;

    private
      FRefCount   :Integer;
      FImage      :TGPImageEx;
      FName       :TString;
      FFrame      :Integer;
      FSize       :TSize;
      FThumb      :TMemDC;
      FState      :TTaskState;
      FError      :TString;
      FOnTask     :TNotifyEvent;
      FNext       :TTask;
    end;


  constructor TTask.CreateEx(AImage :TGPImageEx; const AName :TString; AFrame :Integer; const ASize :TSize);
  begin
    inherited Create;
    FImage := AImage;
    if FImage <> nil then
      FImage._AddRef;  
    FName  := AName;
    FFrame := AFrame;
    FSize  := ASize;
  end;


  destructor TTask.Destroy; {override;}
  begin
    if FImage <> nil then begin
      FImage._Release;
      FImage := nil;
    end;
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


  procedure TRenderThread.NextTask;
  var
    vTask :TTask;
  begin
    vTask := FTask;
    FTask := vTask.FNext;
    vTask.FNext := nil;
    vTask._Release;
  end;


(*
  function ImageAbortProc(AData :Pointer) :BOOL; stdcall;
  begin
//  TraceF('ImageAbort. State: %d', [Byte(TTask(AData).FState)]);
    Result := TTask(AData).FState = tsCancelled;
   {$ifdef bTrace}
    if Result then
      Trace('!Canceled');
   {$endif bTrace}
  end;
*)

  procedure TRenderThread.MyDecodeCallback(ASender :Pointer; APercent :Integer; var AContinue :Boolean);
  begin
    AContinue := TTask(ASender).FState <> tsCancelled;
  end;


  procedure TRenderThread.Render(ATask :TTask);
  var
    vImage :TGPImageEx;
  begin
    try
      LockGDIPlus;
      try
        vImage := ATask.FImage;
        try
          if vImage = nil then begin
            { Файл был освобожден (ReleaseSrcImage). Сейчас - не используется. }
            vImage := TGPImageEx.Create(ATask.FName);
            if vImage.GetLastStatus <> OK then
              AppError(strReadImageError);
          end;

          ATask.FThumb := GDIRender(ATask.FName, vImage, ATask.FSize, MyDecodeCallback, ATask);

        finally
          if vImage <> ATask.FImage then
            FreeObj(vImage);
        end;
      finally
        UnLockGDIPlus;
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
 {$endif bGDIAsync}


 {-----------------------------------------------------------------------------}
 { TView                                                                       }
 {-----------------------------------------------------------------------------}

  type
    PDelays = ^TDelays;
    TDelays = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;

    TView = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure SetSrcImage(AImage :TGPImageEx);
      procedure ReleaseSrcImage;
      procedure SetFrame(AIndex :Integer);

      function _AddRef :Integer;
      function _Release :Integer;

      function InitThumbnail(ADX, ADY :Integer) :Boolean;
      procedure DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer);
     {$ifdef bGDIAsync}
      procedure DecodeImageAsync(ADX, ADY :Integer; ATimeout :Integer);
     {$endif bGDIAsync}
      function SaveAs({const} ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;

    private
      FRefCount    :Integer;

      FSrcName     :TString;      { Имя файла }
      FSrcImage    :TGPImageEx;   { Исходное изображение }
      FOrient0     :Integer;      { Исходная ориентация }
      FImgSize0    :TSize;        { Исходный размер картинки (текущей страницы) }
      FImgSize     :TSize;        { Размер картинки с учетом ориентации }
      FPixels      :Integer;      { Цветность (BPP) }
      FFmtID       :TGUID;
      FFmtName     :TString;
      FHasAlpha    :Boolean;      { Полупрозрачное изображение }
      FDirectDraw  :Boolean;      { Анимированное изображение, не используем preview'шки }
      FBkColor     :Integer;

      FThumbImage  :TMemDC;       { Изображение, буферизированное как Bitmap }
      FThumbSize   :TSize;        { Размер Preview'шки }
      FIsThumbnail :Boolean;      { Это превью (thumbnail) }

      { Для поддержки анимированных изображений... }
      FFrames      :Integer;
      FFrame       :Integer;
      FDelCount    :Integer;
      FDelays      :PPropertyItem;
      FDimID       :TGUID;

     {$ifdef bGDIAsync}
      { Поддержка фоновой декомпрессии картинок }
      FAsyncTask   :TTask;
      FFirstShow   :DWORD;
      FErrorMess   :TString;

      FResizeStart :DWORD;        { Для поддержки фонового декодирования при масштабировании }
      FResizeSize  :TSize;
     {$endif bGDIAsync}

      { Для поддержки Tag-ов }
      FStrTag      :TString;
      FInt64Tag    :Int64;

      procedure InitImageInfo;
      procedure SetThumbnail(AThumb :TMemDC);
     {$ifdef bGDIAsync}
      procedure SetAsyncTask(const ASize :TSize);
      function CheckAsyncTask :Boolean;
      procedure CancelTask;
      procedure TaskEvent(ASender :Tobject);
      function Idle(ACX, ACY :Integer) :Boolean;
     {$endif bGDIAsync}
      function TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;
    end;


  constructor TView.Create; {override;}
  begin
    inherited Create;
    FFrame := -1;
  end;


  destructor TView.Destroy; {override;}
  begin
//  TraceF('%p TView.Destroy', [Pointer(Self)]);

   {$ifdef bGDIAsync}
    CancelTask;
   {$endif bGDIAsync}
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
    if optRotateOnEXIF then
      if GetTagValueAsInt(FSrcImage, PropertyTagOrientation, vOrient) and (vOrient >= 1) and (vOrient <= 8) then begin
//      TraceF('EXIF Orientation: %d', [vOrient]);
        FOrient0 := vOrient;
      end;

    InitImageInfo;
  end;


  procedure TView.InitImageInfo;
  begin
    FImgSize0 := FSrcImage.GetImageSize;
    FImgSize := FImgSize0;
    FPixels := GetPixelFormatSize(FSrcImage.GetPixelFormat);

    FSrcImage.GetRawFormat(FFmtID);
    FFmtName := GetImgFmtName(FFmtID);

    { Изображение полупрозрачное }
    FHasAlpha := UINT(ImageFlagsHasAlpha) and FSrcImage.GetFlags <> 0;

    { Подсчитываем количество фреймов в анимированном/многостраничном изображении }
    FFrames := GetFrameCount(FSrcImage, @FDimID, @Pointer(FDelays), @FDelCount);
    FSrcImage.getLastStatus;

    FDirectDraw := {FHasAlpha or} (FDelays <> nil);
  end;


  procedure TView.SetFrame(AIndex :Integer);
  begin
    AIndex := RangeLimit(AIndex, 0, FFrames - 1);
    if AIndex <> FFrame then begin
      if (FFrames > 1) and (AIndex < FFrames) then
        FSrcImage.SelectActiveFrame(FDimID, AIndex);

      FImgSize := FSrcImage.GetImageSize;
      FPixels  := GetPixelFormatSize(FSrcImage.GetPixelFormat);

     {$ifdef bGDIAsync}
      CancelTask;
      FreeObj(FThumbImage);
      FErrorMess := '';
     {$endif bGDIAsync}

      FFrame := AIndex;
    end;
  end;


  procedure TView.SetThumbnail(AThumb :TMemDC);
  begin
    if FThumbImage <> AThumb then begin
      FreeObj(FThumbImage);
      FThumbImage := AThumb;
      if AThumb <> nil then begin
        FThumbSize.cx := AThumb.Width;
        FThumbSize.cy := AThumb.Height;
      end;
    end;
  end;


  function TView.InitThumbnail(ADX, ADY :Integer) :Boolean;
  var
    vThmImage :TGPImage;
    vGraphics :TGPGraphics;
    vThumb :TMemDC;
  begin
    Result := False;
    if not IsEqualGUID(FFmtID, ImageFormatJPEG) then
      { Эскизы поддерживаются только(?) для JPEG... }
      Exit;

    if FSrcImage.GetPropertyItemSize(PropertyTagThumbnailData) = 0 then
      Exit; {Нет эскиза}

   {$ifdef bTrace}
    TraceBegF('GetThumbnail: %d x %d', [ADX, ADY]);
   {$endif bTrace}

    vThmImage := FSrcImage.GetThumbnailImage(ADX, ADY, nil, nil);
    if (vThmImage = nil) or (vThmImage.GetLastStatus <> Ok) then begin
      FreeObj(vThmImage);
      Exit;
    end;

    try
      vThumb := TMemDC.Create(vThmImage.GetWidth, vThmImage.GetHeight);
      try
        vGraphics := TGPGraphics.Create(vThumb.DC);
        try
          vGraphics.DrawImage(vThmImage, 0, 0, vThumb.Width, vThumb.Height);
        finally
          vGraphics.Free;
        end;

        SetThumbnail(vThumb);
        FIsThumbnail := True;
        Result := True;

      except
        vThumb.Free;
        raise;
      end;
    finally
      vThmImage.Free;
    end;

   {$ifdef bTrace}
    TraceEnd('  Ready');
   {$endif bTrace}
  end;


  procedure TView.DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer);
  var
    vSize :TSize;
    vThumb :TMemDC;
  begin
    vSize := FImgSize;
    if (ADX > 0) and (ADY > 0) {and optUseWinSize При вызове} then
//    CorrectBoundEx(vSize, Size(ADX, ADY));
      vSize := Size(ADX, ADY);

    LockGDIPlus;
    try
      vThumb := GDIRender(FSrcName, FSrcImage, vSize, ACallback, ACallbackData);
    finally
      UnlockGDIPlus;
    end;

    if vThumb <> nil then begin
      SetThumbnail(vThumb);
      FIsThumbnail := False;
    end;
  end;

 {-----------------------------------------------------------------------------}

 {$ifdef bGDIAsync}
  procedure TView.DecodeImageAsync(ADX, ADY :Integer; ATimeout :Integer);
  var
    vSize :TSize;
    vStart :DWORD;
  begin
    vSize := FImgSize;
    if (ADX > 0) and (ADY > 0) {and optUseWinSize При вызове} then
//    CorrectBoundEx(vSize, Size(ADX, ADY));
      vSize := Size(ADX, ADY);

    SetAsyncTask(vSize);

    vStart := GetTickCount;
    while not CheckAsyncTask and (TickCountDiff(GetTickCount, vStart) < ATimeout) do
      Sleep(1);
  end;


  procedure TView.SetAsyncTask(const ASize :TSize);
  begin
    InitRenderThread;
//  TraceF('SetAsyncTask %s...', [ExtractFileName(FSrcName)]);

    FAsyncTask := TTask.CreateEx(FSrcImage, FSrcName, FFrame, ASize);
(*  if FHasAlpha then
      FAsyncTask.FBackColor := FBkColor;  *)
    FAsyncTask.FOnTask := TaskEvent;
    FAsyncTask._AddRef;

    GRenderThread.AddTask(FAsyncTask);
  end;


  function TView.CheckAsyncTask :Boolean;
  begin
    Result := False;
    if FAsyncTask <> nil then begin
      if GRenderThread.CheckTask(FAsyncTask) then begin
        if FAsyncTask.FThumb <> nil then begin
          SetThumbnail(FAsyncTask.FThumb);
          FIsThumbnail := False;
        end;
        FErrorMess   := FAsyncTask.FError;
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
      GRenderThread.CancelTask(FAsyncTask);
      FAsyncTask._Release;
      FAsyncTask := nil;
    end;
  end;


  procedure TView.TaskEvent(ASender :Tobject);
  begin
//  TraceF('TaskEvent %d...', [Byte(FAsyncTask.FState)]);
  end;
 {$endif bGDIAsync}


 {-----------------------------------------------------------------------------}

  function GetUniqName(const aName, aExt :TString) :TString;
  var
    I :Integer;
  begin
    I := 0;
    Result := ChangeFileExtension(aName, aExt);
    while WinFileExists(Result) do begin
      Inc(I);
      Result := ChangeFileExtension(aName, aExt + Int2Str(I));
    end;
  end;


  function SetFileTimeName(const aName :TString; aAge :Integer {const aTime :TFileTime}) :Boolean;
  var
    vHandle :THandle;
  begin
    Result := False;
    vHandle := FileOpen(aName, fmOpenWrite);
//  vHandle := CreateFile(PTChar(aName), FILE_WRITE_ATTRIBUTES,  0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if vHandle = INVALID_HANDLE_VALUE then
      Exit;
//  Result := SetFileTime(vHandle, nil, nil, @aTime);
    Result := FileSetDate(vHandle, aAge);
    FileClose(vHandle);
  end;



  function TView.SaveAs({const} ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;
  type
    EncoderParameters3 = packed record
      Count     :UINT;
      Parameter :array[0..2] of TEncoderParameter;
    end;
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
    vMimeType, vNewName, vBakName :TString;
    vEncoderID :TGUID;
    vImage :TGPImage;
    vTransf :TEncoderValue;
    vParams :EncoderParameters3;
    vPParams :PEncoderParameters;
    vOrient :Integer;
    vSrcDate :Integer;
  begin
    Result := False;

    if AFmtName = '' then
      AFmtName := FFmtName
    else
    if ANewName = '' then
      ANewName := ChangeFileExtension(FSrcName, AFmtName);
    if ANewName = '' then
      ANewName := FSrcName;

    vNewName := '';
    try
      if not WinFileExists(FSrcName) then
        AppErrorFmt(strFileNotFound, [FSrcName]);

      vMimeType := 'image/' + StrLoCase(AFmtName);
      if GetEncoderClsid(vMimeType, vEncoderID) = -1 then
        AppErrorFmt(strNoEncoderFor, [AFmtName]);

      LockGDIPlus;
      try
        if FFrames = 1 then
          ReleaseSrcImage;

        vImage := TGPImage.Create(FSrcName);
        try
//        GDICheck(vImage.GetLastStatus);
          if vImage.GetLastStatus <> OK then
            AppError(strReadImageError);

          if GetFrameCount(vImage, nil, nil, nil) > 1 then
            AppError(strCantSaveFrames);

          vOrient := 0;
          if not GetTagValueAsInt(vImage, PropertyTagOrientation, vOrient) or (vOrient < 1) or (vOrient > 8) then
            vOrient := 0;

          vParams.Count := 0;

          if aQuality <> 0 then begin
            with vParams.Parameter[vParams.Count] do begin
              Guid := EncoderQuality;
              Type_ := EncoderParameterValueTypeLong;
              NumberOfValues := 1;
              Value := @aQuality;
            end;
            Inc(vParams.Count);
          end;

          if (soExifRotation in aOptions) and (StrEqual(AFmtName, 'jpeg') or StrEqual(AFmtName, 'tiff')) then begin

            { Поворот путем коррекции EXIF заголовка - loseless }
            if aOrient <> vOrient then
              SetTagValueInt(vImage, PropertyTagOrientation, aOrient);

          end else
          if (soTransformation in aOptions) then begin

            if StrEqual(AFmtName, 'jpeg') then begin
              { Поворт путем трансформации - может приводить к потерям... }

              vTransf := cTransform[aOrient];
              if vTransf <> EncoderValue(0) then begin
                if (((vImage.GetWidth mod 16) <> 0) or ((vImage.GetHeight mod 16) <> 0)) and not (soEnableLossy in aOptions) then
                  AppError(strLossyRotation);

                with vParams.Parameter[vParams.Count] do begin
                  Guid := EncoderTransformation;
                  Type_ := EncoderParameterValueTypeLong;
                  NumberOfValues := 1;
                  Value := @vTransf;
                end;
                Inc(vParams.Count);
              end;

            end else
            begin
              RotateImage(vImage, aOrient);
              GDICheck(vImage.GetLastStatus);
            end;

            if (vOrient <> 0) and (vOrient <> 1) then
              SetTagValueInt(vImage, PropertyTagOrientation, 1);
          end else
            Exit;

         {$ifdef bTrace}
          TraceBeg('Save...');
         {$endif bTrace}

          vNewName := GetUniqName(ANewName, '$$$');

          vPParams := nil;
          if vParams.Count > 0 then
            vPParams := Pointer(@vParams);
          vImage.Save(vNewName, vEncoderID, vPParams);
          GDICheck(vImage.GetLastStatus);

         {$ifdef bTrace}
          TraceEnd('  Ready');
         {$endif bTrace}

        finally
          FreeObj(vImage);
        end;

        vSrcDate := 0;
        if optKeepDateOnSave {soKeepDate in aOptions} then
          vSrcDate := FileAge(FSrcName);

        vBakName := GetUniqName(ANewName, '~' + ExtractFileExtension(ANewName) );
        if WinFileExists(ANewName) then
          ApiCheck(RenameFile(ANewName, vBakName));

        ApiCheck(RenameFile(vNewName, ANewName));

        if vSrcDate <> 0 then
          SetFileTimeName(ANewName, vSrcDate);

        DeleteFile(vBakName);

        Result := True;

      finally
        UnLockGDIPlus;
      end;

    except
      on E :Exception do begin
        if (vNewName <> '') and WinFileExists(vNewName) then
          DeleteFile(vNewName);
        Raise;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TView.TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

    procedure LocStrTag(AID :ULONG);
    begin
      Result := GetTagValueAsStr(FSrcImage, AID, FStrTag);
      if Result then begin
        aValue := PTChar(FStrTag);
        aType := PVD_TagType_Str;
      end;
    end;

    procedure LocInt64Tag(AID :ULONG);
    begin
      Result := GetTagValueAsInt64(FSrcImage, AID, FInt64Tag);
      if Result then begin
        aValue := @FInt64Tag;
        aType := PVD_TagType_Int64;
      end;
    end;

    procedure LocIntTag(AID :ULONG);
    var
      vIntTag :Integer;
    begin
      Result := GetTagValueAsInt(FSrcImage, AID, vIntTag);
      if Result then begin
        aValue := Pointer(TIntPtr(vIntTag));
        aType := PVD_TagType_Int;
      end;
    end;

    procedure LocResolutionTag(AID :ULONG);
    var
      vInt :Integer;
      vRes :Single;
    begin
      Result := False;
//    if FSrcImage.GetFlags and ImageFlagsHasRealDPI <> 0 then begin
      if IsEqualGUID(FFmtID, ImageFormatJPEG) or IsEqualGUID(FFmtID, ImageFormatTIFF) then begin
        if AID = PropertyTagXResolution then
          vRes := FSrcImage.GetHorizontalResolution
        else
          vRes := FSrcImage.GetVerticalResolution;
        Result := (FSrcImage.GetLastStatus = OK) and (vRes > 0);
        if Result then begin
          vInt := Trunc(vRes);
          aValue := Pointer(TIntPtr(vInt));
          aType := PVD_TagType_Int;
        end;
      end;
    end;

  begin
    Result := False;
    if FSrcImage = nil then begin
      {!!!}
      Exit;
    end;

    case aCode of
      PVD_Tag_Description  : LocStrTag(PropertyTagImageDescription);
      PVD_Tag_Time         : LocStrTag(PropertyTagExifDTOrig);  //PropertyTagDateTime
      PVD_Tag_EquipMake    : LocStrTag(PropertyTagEquipMake);
      PVD_Tag_EquipModel   : LocStrTag(PropertyTagEquipModel);
      PVD_Tag_Software     : LocStrTag(PropertyTagSoftwareUsed);
      PVD_Tag_Author       : LocStrTag(PropertyTagArtist);
      PVD_Tag_Copyright    : LocStrTag(PropertyTagCopyright);

      PVD_Tag_ExposureTime : LocInt64Tag(PropertyTagExifExposureTime);
      PVD_Tag_FNumber      : LocInt64Tag(PropertyTagExifFNumber);
      PVD_Tag_FocalLength  : LocInt64Tag(PropertyTagExifFocalLength);
      PVD_Tag_ISO          : LocIntTag(PropertyTagExifISOSpeed);
      PVD_Tag_Flash        : LocIntTag(PropertyTagExifFlash);
      PVD_Tag_XResolution  : LocResolutionTag(PropertyTagXResolution);
      PVD_Tag_YResolution  : LocResolutionTag(PropertyTagYResolution);
    end;
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bGDIAsync}
  function TView.Idle(ACX, ACY :Integer) :Boolean;
  begin
    Result := False;
    if FFirstShow = 0 then
      FFirstShow := GetTickCount;

    if CheckAsyncTask then begin
      Result := True;
      Exit;
    end;

    ACX := IntMin(ACX, FImgSize.CX);
    ACY := IntMin(ACY, FImgSize.CY);
    if not FIsThumbnail and ((ACX > FThumbSize.CX) or (ACY > FThumbSize.CY)) then begin
      if (FResizeStart = 0) or (FResizeSize.CX <> ACX) or (FResizeSize.CY <> ACY) then begin
        FResizeStart := GetTickCount;
        FResizeSize := Size(ACX, ACY);
      end;
    end;


    if (FResizeStart <> 0) and (FAsyncTask = nil) and (TickCountDiff(GetTickCount, FResizeStart) > StretchDelay) then begin
      FResizeStart := 0;
      if (ACX > FThumbSize.CX) or (ACY > FThumbSize.CY) then
        SetAsyncTask( Size(ACX, ACY) );
    end;

    if FIsThumbnail and (FAsyncTask = nil) and (TickCountDiff(GetTickCount, FFirstShow) > ThumbDelay) and not ScrollKeyPressed then
      { Если в настоящий момент показывается эскиз (и не продолжается быстрое листание), то запускаем задание на декодирование, если еще нет }
      SetAsyncTask( Size(ACX, ACY) );
  end;
 {$endif bGDIAsync}


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


 {-----------------------------------------------------------------------------}
 { TReviewGDIDecoder                                                           }
 {-----------------------------------------------------------------------------}

  constructor TReviewGDIDecoder.Create; {override;}
  begin
    inherited Create;
    FInitState := 1;
    FName := cDefGDIDecoderName;
    FTitle := cDefGDIDecoderTitle;
    FPriority := MaxInt;
    ResetSettings;
  end;


  destructor TReviewGDIDecoder.Destroy; {override;}
  begin
   {$ifdef bGDIAsync}
    DoneRenderThread;
   {$endif bGDIAsync}
    inherited Destroy;
  end;


  function TReviewGDIDecoder.NeedPrecache :boolean; {override;}
  begin
    Result := False;
  end;


  procedure TReviewGDIDecoder.ResetSettings; {override;}
  begin
    SetExtensions(cGDIPlusFormats, '');
  end;


  function TReviewGDIDecoder.GetState :TDecoderState; {override;}
  begin
    Result := rdsInternal;
  end;


  function TReviewGDIDecoder.CanWork(aLoad :Boolean) :Boolean; {virtual;}
  begin
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  function TReviewGDIDecoder.pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; {override;}
  var
    vView :TView;
  begin
    Result := False;

    vView := CreateView(AFileName);

    if vView <> nil then begin
      AImage.FFormat := vView.FFmtName;
      AImage.FPages := vView.FFrames;
      AImage.FAnimated := (vView.FFrames > 1) and (vView.FDelays <> nil);
      AImage.FOrient := vView.FOrient0;

      AImage.FContext := vView;
      vView._AddRef;

      Result := True;
    end;
  end;


  function TReviewGDIDecoder.pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; {override;}
  begin
    with TView(AImage.FContext) do begin
      SetFrame(AImage.FPage);

      AImage.FWidth  := FImgSize.cx;
      AImage.FHeight := FImgSize.cy;
      AImage.FBPP    := FPixels;

      if FFrames > 1 then begin
        if (FDelays <> nil) and (FFrame < FDelCount) then
          AImage.FDelay := PDelays(FDelays.Value)[FFrame] * 10;
//      if AImage.FDelay = 0 then
//        AImage.FDelay := cAnimationStep;  Перенес в ReviewClasses
      end;

      Result := True;
    end;
  end;


  function TReviewGDIDecoder.pvdPageDecode(AImage :TReviewImageRec; AWidth, AHeight :Integer; AMode :TDecodeMode;
    const ACallback :TDecodeCallback = nil; ACallbackData :Pointer = nil) :Boolean; {override;}
  begin
    with TView(AImage.FContext) do begin
      Result := False;

      FBkColor  := 0 {ABkColor};
      if AMode <> dmImage then
        InitThumbnail(0, 0 {cThumbSize, cThumbSize} );
      if (FThumbImage = nil) and (AMode = dmThumbnail) then
        Exit;

      if FThumbImage = nil then
        DecodeImage(AWidth, AHeight, ACallback, ACallbackData)
     {$ifdef bGDIAsync}
      else
        if AMode = doAsyncExtract then
          DecodeImageAsync(AWidth, AHeight, DecodeWaitDelay)
     {$endif bGDIAsync};

      AImage.FWidth := FImgSize.cx;
      AImage.FHeight := FImgSize.cy;
      AImage.FBPP := FPixels;
      AImage.FSelfdraw := False;
      AImage.FTransparent := FHasAlpha;
//    AImage.FOrient := FOrient0;

//    if FFrames = 1 then
//      { Освобождаем файл. При необходимости повторного декодирования он откроется заново. }
//      ReleaseSrcImage;

     {$ifdef bGDIAsync}
      FFirstShow  := 0;
     {$endif bGDIAsync}
      Result := FThumbImage <> nil;
    end;
  end;


  function TReviewGDIDecoder.GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; {override;}
  begin
    with TView(AImage.FContext) do begin
     {$ifdef bGDIAsync}
      CheckAsyncTask;
     {$endif bGDIAsync}
      Result := 0;
      if FThumbImage <> nil then
        Result := FThumbImage.ReleaseBitmap;
      FreeObj(FThumbImage);
      aIsThumbnail := FIsThumbnail;
    end;
  end;



  procedure TReviewGDIDecoder.pvdPageFree(AImage :TReviewImageRec); {override;}
  begin
  end;


  procedure TReviewGDIDecoder.pvdFileClose(AImage :TReviewImageRec); {override;}
  begin
    if AImage.FContext <> nil then
      TView(AImage.FContext)._Release;
  end;


 {-----------------------------------------------------------------------------}

  function TReviewGDIDecoder.pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; {override;}
  begin
    with TView(AImage.FContext) do begin
      aType := 0; aValue := nil;
      Result := TagInfo(aCode, aType, aValue);
    end;
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bGDIAsync}
  function TReviewGDIDecoder.Idle(AImage :TReviewImageRec; ACX, ACY :Integer) :Boolean; {override;}
  begin
    Result := TView(AImage.FContext).Idle(ACX, ACY);
  end;
 {$endif bGDIAsync}


  function TReviewGDIDecoder.Save(AImage :TReviewImageRec; const ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean; {override;}
  begin
    if aOrient = 0 then
      aOrient := AImage.FOrient;
    Result := TView(AImage.FContext).SaveAs(ANewName, AFmtName, aOrient, aQuality, aOptions);
  end;



initialization
  InitializeCriticalSection(GDIPlusCS);

finalization
  DeleteCriticalSection(GDIPlusCS);
end.


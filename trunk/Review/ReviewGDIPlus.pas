{$I Defines.inc}

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
    PDelays = ^TDelays;
    TDelays = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;


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


    TGPView = class(TBasis)
    public
      class function CreateView(const AName :TString; ABuf :Pointer; ABufSize :Integer) :TGPView; 

      constructor Create; override;
      destructor Destroy; override;
      procedure SetSrcImage(AImage :TGPImageEx);
      procedure ReleaseSrcImage;
      procedure SetFrame(AIndex :Integer);

      function _AddRef :Integer;
      function _Release :Integer;

      function InitThumbnail(ADX, ADY :Integer) :Boolean;
      procedure DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer); virtual;

    protected
      FRefCount    :Integer;

      FSrcName     :TString;      { Имя файла }
      FSrcBuf      :Pointer;      { Буфер файла, может быть nil, если файл слишком большой ( > cPreCacheLimit = 128 M ) }
      FSrcSize     :Integer;
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

      FThumbBMP    :HBitmap;      { Изображение, буферизированное как Bitmap }
      FThumbSize   :TSize;        { Размер Preview'шки }
      FIsThumbnail :Boolean;      { Это превью (thumbnail) }

      { Для поддержки анимированных изображений... }
      FFrames      :Integer;
      FFrame       :Integer;
      FDelCount    :Integer;
      FDelays      :PPropertyItem;
      FDimID       :TGUID;

      { Для поддержки Tag-ов }
      FStrTag      :TString;
      FInt64Tag    :Int64;

      procedure InitImageInfo;
      procedure SetThumbnail(AThumb :HBitmap);
      function TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;
    end;


    TReviewGDIDecoder = class(TReviewDecoder)
    public
      constructor Create; override;
      destructor Destroy; override;

      function NeedPrecache :boolean; override;
      procedure ResetSettings; override;
      function GetState :TDecoderState; override;
      function CanWork(aLoad :Boolean) :boolean; override;
      function CreateView(const AFileName :TString; ABuf :Pointer; ABufSize :Integer) :TGPView; virtual;

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
    end;


  function GDISaveAs({const} AFileName, ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;

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


  procedure WinDeleteObject(var AHandle :HGDIOBJ);
  begin
    if AHandle <> 0 then begin
      DeleteObject(AHandle);
      AHandle := 0;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TGPImageEx                                                                  }
 {-----------------------------------------------------------------------------}

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


 {-----------------------------------------------------------------------------}
 {                                                                             }
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


  function GDISaveAs({const} AFileName, ANewName, AFmtName :TString; aOrient, aQuality :Integer; aOptions :TSaveOptions) :Boolean;
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
    vImage :TGPImageEx;
    vMimeType, vTmpName, vBakName :TString;
    vFmtID, vEncoderID :TGUID;
    vTransf :TEncoderValue;
    vParams :EncoderParameters;
    vPParams :PEncoderParameters;
    vOrient :Integer;
    vSrcDate :Integer;
  begin
    Result := False;

    vTmpName := '';
    try
      vImage := nil;
      LockGDIPlus;
      try
        vImage := TGPImageEx.Create(AFileName);
//      GDICheck( vImage.GetLastStatus );
        if vImage.GetLastStatus <> Ok then
          AppErrorId(strSaveFormatError);

        vImage.GetRawFormat(vFmtID);

        if AFmtName = '' then
          AFmtName := GetImgFmtName(vFmtID)
        else
        if ANewName = '' then
          ANewName := ChangeFileExtension(AFileName, AFmtName);
        if ANewName = '' then
          ANewName := AFileName;

        if GetFrameCount(vImage, nil, nil, nil) > 1 then
          AppErrorId(strSaveFormatError);

        vMimeType := 'image/' + StrLoCase(AFmtName);
        if GetEncoderClsid(vMimeType, vEncoderID) = -1 then
//        AppErrorFmt(strNoEncoderFor, [AFmtName]);
          AppErrorId(strSaveFormatError);

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
                AppErrorId(strSaveLossyPrompt);

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

        vTmpName := GetUniqName(ANewName, '$$$');

        vPParams := nil;
        if vParams.Count > 0 then
          vPParams := Pointer(@vParams);

       {$ifdef bTrace}
        TraceBegF('Save %s...', [vTmpName]);
       {$endif bTrace}

        vImage.Save(vTmpName, vEncoderID, vPParams);
        GDICheck(vImage.GetLastStatus);

       {$ifdef bTrace}
        TraceEnd('  Ready');
       {$endif bTrace}

      finally
        FreeObj(vImage);
        UnLockGDIPlus;
      end;

      vSrcDate := 0;
      if optKeepDateOnSave {soKeepDate in aOptions} then
        vSrcDate := FileAge(AFileName);

//    Небезопасно. DeleteFile не удаляет открытые файлы сразу, а помечает как удаленные...
//    if WinFileExists(ANewName) then
//      ApiCheck(DeleteFile(ANewName));
//    ApiCheck(RenameFile(vTmpName, ANewName));

//    ApiCheck(MoveFileEx(PTChar(vTmpName), PTChar(ANewName), MOVEFILE_REPLACE_EXISTING));
      if not MoveFileEx(PTChar(vTmpName), PTChar(ANewName), MOVEFILE_REPLACE_EXISTING) then begin
        { Файл в режиме просмтора не может быть переописан, но может быть переименован }
        vBakName := GetUniqName(ANewName, '~' + ExtractFileExtension(ANewName));
        ApiCheck(RenameFile(ANewName, vBakName));
        ApiCheck(RenameFile(vTmpName, ANewName));
        DeleteFile(vBakName);
      end;

      if vSrcDate <> 0 then
        SetFileTimeName(ANewName, vSrcDate);

      Result := True;

    except
      on E :Exception do begin
        if (vTmpName <> '') and WinFileExists(vTmpName) then
          DeleteFile(vTmpName);
        Raise;
      end;
    end;
  end;

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

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


  function GDIRender(const AName :TString; AImage :TGPImageEx; const ASize :TSize; const ACallback :TDecodeCallback; ACallbackData :Pointer) :HBitmap;
  var
    vThumb    :TMemDC;
    vGraphics :TGPGraphics;
//  vDimID    :TGUID;
    vContext :TContextRec;
    vRes :TStatus;
  begin
   {$ifdef bTrace}
    TraceBegF('GPImange Render %s, %d x %d (%d M)...', [AName, ASize.CX, ASize.CY, (ASize.CX * ASize.CY * 4) div (1024 * 1024)]);
   {$endif bTrace}

    vThumb := TMemDC.Create(ASize.CX, ASize.CY);
    try

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

        vContext.Callback := ACallback;
        vContext.Data := ACallbackData;

        //GdipDrawImageRectRectI
        vGraphics.DrawImage(AImage, MakeRect(0, 0, ASize.CX, ASize.CY), 0, 0, AImage.GetWidth, AImage.GetHeight, UnitPixel, nil, MyGDIPlusCallback, @vContext);
        vRes := vGraphics.GetLastStatus;
        if vRes = Win32Error then begin
         {$ifdef bTrace}
          Trace('OOPS. Win32 Error.');
         {$endif bTrace}
          vGraphics.DrawImage(AImage, MakeRect(0, 0, ASize.CX, ASize.CY), 0, 0, AImage.GetWidth, AImage.GetHeight, UnitPixel, nil, MyGDIPlusCallback, @vContext);
          vRes := vGraphics.GetLastStatus;
        end;
        GDICheck(vRes);

      finally
        FreeObj(vGraphics);
      end;

      Result := vThumb.ReleaseBitmap

    finally
      FreeObj(vThumb);
    end;

   {$ifdef bTrace}
    TraceEnd('  Ready');
   {$endif bTrace}
  end;


 {-----------------------------------------------------------------------------}
 { TGPView                                                                       }
 {-----------------------------------------------------------------------------}

  class function TGPView.CreateView(const AName :TString; ABuf :Pointer; ABufSize :Integer) :TGPView; 
  var
    vImage :TGPImageEx;
    vStatus :TStatus;
  begin
    Result := nil;

   {$ifdef bTrace}
    Trace('GPImage Create: %s...', [AName]);
   {$endif bTrace}

    vImage := TGPImageEx.Create(AName);
    vStatus := vImage.GetLastStatus;

   {$ifdef bTrace}
    Trace('  Done. Status=%d', [Byte(vStatus)]);
   {$endif bTrace}

    if vStatus = Ok then begin
      Result := Create;
//    TraceF('%p TGPView.Create: %s', [Pointer(Result), AName]);
      Result.SetSrcImage(vImage);
      Result.FSrcName := AName;
      Result.FSrcBuf  := ABuf;
      Result.FSrcSize := ABufSize;
    end else
      FreeObj(vImage);
  end;



  constructor TGPView.Create; {override;}
  begin
    inherited Create;
    FFrame := -1;
  end;


  destructor TGPView.Destroy; {override;}
  begin
//  TraceF('%p TGPView.Destroy', [Pointer(Self)]);

    WinDeleteObject(FThumbBmp);
    MemFree(FDelays);

    ReleaseSrcImage;
    inherited Destroy;
  end;


  procedure TGPView.ReleaseSrcImage;
  begin
    if FSrcImage <> nil then begin
     {$ifdef bTrace}
      Trace('GPImage Close %s', [FSrcName]);
     {$endif bTrace}
      FSrcImage._Release;
      FSrcImage := nil;
    end;
  end;


  function TGPView._AddRef :Integer;
  begin
    Result := InterlockedIncrement(FRefCount);
  end;


  function TGPView._Release :Integer;
  begin
    Result := InterlockedDecrement(FRefCount);
    if Result = 0 then
      Destroy;
  end;


  procedure TGPView.SetSrcImage(AImage :TGPImageEx);
  var
    vOrient :Integer;
  begin
    FSrcImage := AImage;
    FSrcImage._AddRef;

//  TraceExifProps(FSrcImage);

    FOrient0 := 0;
    if GetTagValueAsInt(FSrcImage, PropertyTagOrientation, vOrient) and (vOrient >= 1) and (vOrient <= 8) then begin
//    TraceF('EXIF Orientation: %d', [vOrient]);
      FOrient0 := vOrient;
    end;

    InitImageInfo;
  end;


  procedure TGPView.InitImageInfo;
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


  procedure TGPView.SetFrame(AIndex :Integer);
  begin
    AIndex := RangeLimit(AIndex, 0, FFrames - 1);
    if AIndex <> FFrame then begin

      if (FFrames > 1) and (AIndex < FFrames) then begin
       {$ifdef bTrace}
        TraceBegF('GPImange SetFrame %d...', [AIndex]);
       {$endif bTrace}

        FSrcImage.SelectActiveFrame(FDimID, AIndex);

       {$ifdef bTrace}
        TraceEnd('  done');
       {$endif bTrace}
      end;

      FImgSize := FSrcImage.GetImageSize;
      FPixels  := GetPixelFormatSize(FSrcImage.GetPixelFormat);

      FFrame := AIndex;
    end;
  end;


  procedure TGPView.SetThumbnail(AThumb :HBitmap);
  begin
    if FThumbBMP <> AThumb then begin
      WinDeleteObject(FThumbBMP);
      FThumbBMP := AThumb;
      if FThumbBMP <> 0 then
        FThumbSize := GetBitmapSize(FThumbBMP);
    end;
  end;


  function TGPView.InitThumbnail(ADX, ADY :Integer) :Boolean;
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

        SetThumbnail(vThumb.ReleaseBitmap);
        FIsThumbnail := True;
        Result := True;

      finally
        vThumb.Free;
      end;
    finally
      vThmImage.Free;
    end;

   {$ifdef bTrace}
    TraceEnd('  Ready');
   {$endif bTrace}
  end;


  procedure TGPView.DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer);
  var
    vSize :TSize;
    vThumb :HBitmap;
  begin
    vSize := FImgSize;
    if (ADX > 0) and (ADY > 0) {and optUseWinSize При вызове} then
//    CorrectBoundEx(vSize, Size(ADX, ADY));
      vSize := Size(ADX, ADY);

    vThumb := 0;
(*
   {$ifdef bUseLibJPEG}
    if optUseLibJPEG and IsEqualGUID(FFmtID, ImageFormatJPEG) and (FSrcBuf <> nil) then
      vThumb := JPEGRender(FSrcName, FSrcBuf, FSrcSize, vSize, ACallback, ACallbackData);
   {$endif bUseLibJPEG}
*)
    if vThumb = 0 then begin
      LockGDIPlus;
      try
        vThumb := GDIRender(FSrcName, FSrcImage, vSize, ACallback, ACallbackData);
      finally
        UnlockGDIPlus;
      end;
    end;

    if vThumb <> 0 then begin
      SetThumbnail(vThumb);
      FIsThumbnail := False;
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TGPView.TagInfo(aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean;

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
 { TReviewGDIDecoder                                                           }
 {-----------------------------------------------------------------------------}

  constructor TReviewGDIDecoder.Create; {override;}
  begin
    inherited Create;
    FInitState := 1;
    FName := cDefGDIDecoderName;
    FTitle := cDefGDIDecoderTitle;
    FPriority := MaxInt-1;
    ResetSettings;
  end;


  destructor TReviewGDIDecoder.Destroy; {override;}
  begin
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


  function TReviewGDIDecoder.CreateView(const AFileName :TString; ABuf :Pointer; ABufSize :Integer) :TGPView; {virtual;}
  begin
    Result := TGPView.CreateView(AFileName, ABuf, ABufSize)
  end;


 {-----------------------------------------------------------------------------}

  function TReviewGDIDecoder.pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; {override;}
  var
    vView :TGPView;
  begin
    Result := False;

    if AImage.FSize <= AImage.FCacheSize then
      vView := CreateView(AFileName, AImage.FCacheBuf, AImage.FCacheSize)
    else
      vView := CreateView(AFileName, nil, 0);

    if vView <> nil then begin
      AImage.FFormat := vView.FFmtName;
      AImage.FPages := vView.FFrames;
      AImage.FAnimated := (vView.FFrames > 1) and (vView.FDelays <> nil);
      AImage.FOrient0 := vView.FOrient0;

      AImage.FContext := vView;
      vView._AddRef;

      Result := True;
    end;
  end;


  function TReviewGDIDecoder.pvdGetPageInfo(AImage :TReviewImageRec) :Boolean; {override;}
  begin
    with TGPView(AImage.FContext) do begin
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
    with TGPView(AImage.FContext) do begin
      Result := False;

      FBkColor  := 0 {ABkColor};
      if AMode <> dmImage then
        InitThumbnail(0, 0 {cThumbSize, cThumbSize} );
      if (FThumbBMP = 0) and (AMode = dmThumbnail) then
        Exit;

      if FThumbBMP = 0 then
        DecodeImage(AWidth, AHeight, ACallback, ACallbackData);

      AImage.FWidth := FImgSize.cx;
      AImage.FHeight := FImgSize.cy;
      AImage.FBPP := FPixels;
      AImage.FSelfdraw := False;
      AImage.FTransparent := FHasAlpha;
//    AImage.FOrient0 := FOrient0;

      Result := FThumbBMP <> 0;
    end;
  end;


  function TReviewGDIDecoder.GetBitmapHandle(AImage :TReviewImageRec; var aIsThumbnail :Boolean) :HBitmap; {override;}
  begin
    with TGPView(AImage.FContext) do begin
      Result := FThumbBmp;
      FThumbBmp := 0;
      aIsThumbnail := FIsThumbnail;
      if aIsThumbnail and optCorrectThumb then
        Result := AImage.CorrectThumbnail(Result);
    end;
  end;



  procedure TReviewGDIDecoder.pvdPageFree(AImage :TReviewImageRec); {override;}
  begin
  end;


  procedure TReviewGDIDecoder.pvdFileClose(AImage :TReviewImageRec); {override;}
  begin
    if AImage.FContext <> nil then begin
      TGPView(AImage.FContext)._Release;
      AImage.FContext := nil;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TReviewGDIDecoder.pvdTagInfo(AImage :TReviewImageRec; aCode :Integer; var aType :Integer; var aValue :Pointer) :Boolean; {override;}
  begin
    with TGPView(AImage.FContext) do begin
      aType := 0; aValue := nil;
      Result := TagInfo(aCode, aType, aValue);
    end;
  end;



initialization
  InitializeCriticalSection(GDIPlusCS);

finalization
  DeleteCriticalSection(GDIPlusCS);
end.


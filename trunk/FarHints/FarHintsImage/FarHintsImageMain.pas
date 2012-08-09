{$I Defines.inc}
{$Align On}

unit FarHintsImageMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    FarHintsAPI,
    GDIPAPI,
    GDIPOBJ,
    FarHintsImageUtil;


  const
    cAnimationStep     = 100;   {ms, }

    cThumbSize         = 128;   { Размер извлекаемого эскиза }
    cThumbMinSize      = 32;
    cRescalePerc       = 10;

  var
    StretchDelay     :Cardinal = 250;   {ms, }
    AsyncRenderDelay :Cardinal = 250;   {ms, Задержка фонового извлечения эскиза (чтобы не делать лишнюю работу при быстром пермещении хинта) }
    ThreadIdlePeriod :Cardinal = 5000;  {ms, Период простоя, после которого фоновый поток завершает работу }

    MaxViewSize      :Integer = 128;
    UseThumbnail     :Boolean = True;
    ShowAnimation    :Boolean = True;
    ShowProps        :Boolean = True;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  type
    TStrMessage = (
      strName,
      strType,
      strModified,
      strSize,
      strDimensions
    );


  function Bounds(ALeft, ATop, AWidth, AHeight :Integer) :TRect;
  begin
    with Result do begin
      Left := ALeft;
      Top := ATop;
      Right := ALeft + AWidth;
      Bottom :=  ATop + AHeight;
    end;
  end;


  procedure FreeObj(var Obj {:TObject});
  var
    vTmp :TObject;
  begin
    if TObject(Obj) <> nil then begin
      vTmp := TObject(Obj);
      TObject(Obj) := nil;
      vTmp.Destroy;
    end;
  end;


  function IntMax(L1, L2 :Integer) :Integer;
  begin
    if L1 > L2 then
      Result := L1
    else
      Result := L2;
  end;


  function IntMin(L1, L2 :Integer) :Integer;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;


  function TickCountDiff(AValue1, AValue2 :Cardinal) :Cardinal;
  begin
    if AValue1 >= AValue2 then
      Result := AValue1 - AValue2
    else
      Result := ($FFFFFFFF - AValue2) + aValue1;
  end;


  function GetImagePropStr(AImage :TGPImage; AProp :Cardinal) :TString;
  var
    vSize :Integer;
    vItem :PPropertyItem;
  begin
    Result := '';
    vSize := AImage.GetPropertyItemSize(AProp);
    if vSize > 0 then begin
      GetMem(vItem, vSize);
      try
        AImage.GetPropertyItem(AProp, vSize, vItem);
        if vItem.type_ = PropertyTagTypeASCII then
          Result := PChar(vItem.value);
      finally
        FreeMem(vItem);
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
    FBMP := CreateCompatibleBitmap(vDC, W, H);
    ReleaseDC(0, vDC);

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
    SelectObject(FDC, FOldBmp);
    DeleteObject(FBMP);
    DeleteDC(FDC);
  end;


  procedure TMemDC.Clear;
  begin
    FillRect(FDC, Bounds(0, 0, FWIdth, FHeight), FBrush);
  end;


 {-----------------------------------------------------------------------------}

  type
    PDelays = ^TDelays;
    TDelays = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;

    TTaskState = (
      tsNone,
      tsWait,
      tsProceed,
      tsComplete
    );

    TPluginObject = class(TInterfacedObject, IHintPlugin, IHintPluginDraw, IHintPluginIdle, IHintPluginCommand)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

      {IHintPluginIdle}
      function Idle(const AItem :IFarItem) :Boolean; stdcall;

      {IHintPluginCommand}
      procedure RunCommand(const AItem :IFarItem; ACommand :Integer); stdcall;

    private
      FAPI         :IFarHintsApi;
      FInited      :Boolean;
      FNeedWrite   :Boolean;
      FImgSize     :TSize;        { Оригинальный размер картинки }
      FViewSize    :TSize;        { Размер отображаемой области }
      FThumbSize   :TSize;        { Размер Preview'шки }
      FDirectDraw  :Boolean;      { Полупрозрачное или анимированное изображение, не используем preview'шки }

      FSrcImage    :TGPImageEx;   { Исходное изображение }
      FThumbImage  :TMemDC;       { Изображение, буферизированное как Bitmap }

      FResizeStart :Cardinal;
      FLowQuality  :Boolean;

      { Для поддержки анимированных изображений... }
      FFrame       :Integer;
      FFrames      :Integer;
      FDelCount    :Integer;
      FDelays      :PPropertyItem;
      FDimID       :TGUID;
      FTime        :Cardinal;

      { Для поддержки фоновой декомпрессии картинок}
      FCSection     :TRTLCriticalSection;
      FHandle       :THandle;
      FThreadID     :THandle;
      FTerminated   :Boolean;
      FThreadGoDown :Boolean;
      FThumbWait    :Boolean;     { Извлечение продолжается }
      FLock         :Integer;

      FTaskImage    :TGPImageEx;  { Исходное изображение }
      FTaskStart    :Cardinal;    { Время постановки задачи }
      FTaskSize     :TSize;
      FTaskState    :TTaskState;
      FResThumb     :TMemDC;

      procedure ReadSettings;
      procedure WriteSettings;

      procedure UpdateThumbnail(const AItem :IFarItem; AFromProcess, AFirstAppear :Boolean);

      procedure SetAsyncTask(ASize :TSize);
      procedure CheckAsyncTask;
      procedure CancelTask;

      procedure StartPluginThread;
      procedure StopPluginThread;
      procedure Execute;
      function ProcessAsyncRequest :Boolean;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
    AInfo.Flags := AInfo.Flags or PF_CanChangeSize;

    InitializeCriticalSection(FCSection);
  end;


  procedure TPluginObject.ReadSettings;
  begin
    MaxViewSize := FAPI.GetRegValueInt(INVALID_HANDLE_VALUE, 'Image', 'MaxSize', MaxViewSize);
    UseThumbnail := FAPI.GetRegValueInt(INVALID_HANDLE_VALUE, 'Image', 'UseThumbnail', Byte(UseThumbnail)) <> 0;
    ShowAnimation := FAPI.GetRegValueInt(INVALID_HANDLE_VALUE, 'Image', 'ShowAnimation', Byte(ShowAnimation) ) <> 0;
    FInited := True;
  end;


  procedure TPluginObject.WriteSettings;
  begin
    FAPI.SetRegValueInt(INVALID_HANDLE_VALUE, 'Image', 'MaxSize', MaxViewSize);
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
    if FNeedWrite then
      WriteSettings;
    StopPluginThread;
    DeleteCriticalSection(FCSection);
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}

    function GetMsg(AIndex :TStrMessage) :WideString;
    begin
      Result := FAPI.GetMsg(Self, Byte(AIndex));
    end;
(*
    procedure LocAddProps;
    var
      I, vInt :Integer;
      vSize, vCount :Cardinal;
      vBuffer, vItem :PPropertyItem;
      vName, vValue :TString;
    begin
      AItem.AddStringInfo( ' ', '' );

      FImage.GetPropertySize(vSize, vCount);
      if vCount > 0 then begin
        GetMem(vBuffer, vSize);
        ZeroMemory(vBuffer, vSize);
        try
          FImage.GetAllPropertyItems(vSize, vCount, vBuffer);

          vItem := vBuffer;
          for i := 0 to Integer(vCount) - 1 do begin
            vName := GetImagePropName(vItem.id);
            if vName = '' then
              vName := FAPI.Format('Prop%d', [vItem.id]);

            vValue := '';
            if vItem.type_ = PropertyTagTypeASCII then
              vValue := PChar(vItem.value)
            else
            if vItem.type_ = PropertyTagTypeByte then
              vValue := FAPI.IntToStr(Byte(vItem.value^))
            else
            if vItem.type_ = PropertyTagTypeShort then
              vValue := FAPI.IntToStr(Word(vItem.value^))
            else
            if vItem.type_ in [PropertyTagTypeLong, PropertyTagTypeSLONG] then
              vValue := FAPI.IntToStr(Integer(vItem.value^))
            else
            if vItem.type_ in [PropertyTagTypeRational, PropertyTagTypeSRational] then
              vValue := '???';

            if (vName <> '') {and (vValue <> '')} then
              AItem.AddStringInfo( vName, vValue );

            Inc(PChar(vItem), SizeOf(TPropertyItem));
          end;

        finally
          FreeMem(vBuffer);
        end;
      end;
    end;
*)
  var
    vPixels :Integer;
    vHahAlpha :Boolean;
    vFlags :Integer;
//  vTitle :TString;
    vStr :TString;
  begin
    Result := False;
//  TraceF('Process: %s (%d)', [AItem.FullName, AItem.Window]);

    FSrcImage := TGPImageEx.Create(AItem.FullName);
    FSrcImage._AddRef;

    if FSrcImage.GetLastStatus = Ok then begin
//    TraceF('Image: %s', [AItem.Name]);
      if not FInited then
        ReadSettings;

      FImgSize.cx := FSrcImage.GetWidth;
      FImgSize.cy := FSrcImage.GetHeight;
      vPixels     := GetPixelFormatSize(FSrcImage.GetPixelFormat);
      vHahAlpha   := ImageFlagsHasAlpha and FSrcImage.GetFlags <> 0;

      FFrame := 0;
      FFrames := GetFrameCount(FSrcImage, FDimID, FDelays, FDelCount);

      FDirectDraw := vHahAlpha or (FFrames > 1) or (FAPI.CompareStr(FAPI.ExtractFileExt(AItem.Name), 'ico') = 0);

      if (FFrames > 1) or vHahAlpha then
        vFlags := IF_Buffered
      else
        vFlags := IF_Solid;
      AItem.IconFlags := vFlags;

      AItem.AddStringInfo(GetMsg(strName), AItem.Name);
//    AItem.AddStringInfo('Type', FAPI.IntToStr( Byte(FSrcImage.GetType) ) );

      vStr := FAPI.Format('%d x %d, %d bpp', [FImgSize.CX, FImgSize.CY, vPixels]);
      if FFrames > 1 then
        vStr := vStr + FAPI.Format(', %d frames', [FFrames]);

      AItem.AddStringInfo(GetMsg(strDimensions), vStr);

(*
      if ShowProps then begin
        vStr := GetImagePropStr(FSrcImage, PropertyTagEquipModel);
        if vStr <> '' then
          AItem.AddStringInfo('Camera', vStr);

        vStr := GetImagePropStr(FSrcImage, PropertyTagExifUserComment);
        if vStr <> '' then
          AItem.AddStringInfo('Comment', vStr);
      end;
*)
(*
      if ShowProps then
        LocAddProps;
*)
      AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
      AItem.AddInt64Info(GetMsg(strSize), AItem.Size);

      FThumbSize.cx := 0;
      FThumbSize.cy := 0;
      FThumbWait := False;
      UpdateThumbnail(AItem, True, not FAPI.IsHintVisible);

      FResizeStart  := 0;
      FLowQuality   := False;

      FTime := GetTickCount;
      Result := True;
    end else
      FreeObj(FSrcImage);
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem);
  begin
    {}
  end;



  procedure TPluginObject.DoneItem(const AItem :IFarItem);
  begin
    CancelTask;

    FreeObj(FThumbImage);
    FSrcImage._Release;
    FSrcImage := nil;

    if FDelays <> nil then begin
      FreeMem(FDelays);
      FDelays := nil;
    end;
  end;


  function TPluginObject.Idle(const AItem :IFarItem) :Boolean;
  var
    vTime :Cardinal;
    vDelay :Cardinal;
  begin
    if FDirectDraw then begin
      if (FFrames > 1) and ShowAnimation then begin
        vTime := GetTickCount;

        vDelay := 0;
        if FFrame < FDelCount then
          vDelay := PDelays(FDelays.Value)[FFrame] * 10;
        if vDelay = 0 then
          vDelay := cAnimationStep;

        if TickCountDiff(vTime, FTime) >= vDelay then begin
          FTime := vTime;
          if FFrame < FFrames - 1 then
            Inc(FFrame)
          else
            FFrame := 0;
          AItem.UpdateHintWindow(uhwInvalidateImage);
        end;
      end;
    end else
    begin
      if FThumbWait then begin
        CheckAsyncTask;
        if not FThumbWait then begin
          AItem.UpdateHintWindow(uhwInvalidateImage);
          { На случай, если эскиз извлекался слишком долго и стал неактуального размера }
          UpdateThumbnail(AItem, False, False);
        end;
      end;

      if FLowQuality and (FResizeStart <> 0) and (TickCountDiff(GetTickCount, FResizeStart) > StretchDelay) then begin
        FLowQuality := False;
        FResizeStart := 0;
        AItem.UpdateHintWindow(uhwInvalidateImage);
      end;
    end;
    Result := True;
  end;


  procedure TPluginObject.RunCommand(const AItem :IFarItem; ACommand :Integer);
  var
    vLimit, vOldSize, vNewSize :Integer;
  begin
//  TraceF('Command: %d', [ACommand]);
    Idle(AItem);

    vLimit := IntMax(FImgSize.cx, FImgSize.cy);
    vOldSize := IntMax(FViewSize.cx, FViewSize.cy);

    if ACommand = 0 then begin
      vNewSize := vOldSize div 16 * 16;
      vNewSize := IntMin(vNewSize + 16, vLimit)
    end else begin
      vNewSize := (((vOldSize - 1) div 16) + 1) * 16;
      vNewSize := IntMax(vNewSize - 16, cThumbMinSize);
    end;

    if vOldSize <> vNewSize then begin
      MaxViewSize := vNewSize;
      if StretchDelay > 0 then begin
        FLowQuality := True;
        FResizeStart := GetTickCount;
      end;
      UpdateThumbnail(AItem, False, False);
      AItem.UpdateHintWindow(uhwResize + uhwInvalidateItems + uhwInvalidateImage);
      FNeedWrite := True;
    end;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem);
  var
    vGraphics :TGPGraphics;
   {$ifdef bTrace}
    vTime :Cardinal;
   {$endif bTrace}
  begin
   {$ifdef bTrace}
    vTime := GetTickCount;
   {$endif bTrace}

    if FThumbImage <> nil then begin
      if (FViewSize.cx = FThumbImage.FWidth) and (FViewSize.cy = FThumbImage.FHeight) then begin
        BitBlt(ADC, ARect.Left, ARect.Top, FViewSize.cx, FViewSize.cy,
          FThumbImage.FDC, 0, 0, SRCCOPY);
      end else
      begin
        if FLowQuality then
          { Быстрый, но не аккуратный }
          SetStretchBltMode(ADC, COLORONCOLOR)
        else
          { Аккуратный, но медленный }
          SetStretchBltMode(ADC, HALFTONE);
        StretchBlt(ADC, ARect.Left, ARect.Top, FViewSize.cx, FViewSize.cy,
          FThumbImage.FDC, 0, 0, FThumbImage.FWidth, FThumbImage.FHeight, SRCCOPY);
      end;
    end else
    begin
      if FFrames > 1 then begin
        FSrcImage.SelectActiveFrame(FDimID, FFrame);
      end;
      vGraphics := TGPGraphics.Create(ADC);
      try
        vGraphics.DrawImage(FSrcImage, ARect.Left, ARect.Top, FViewSize.CX, FViewSize.CY);
      finally
        vGraphics.Free;
      end;
    end;

   {$ifdef bTrace}
    TraceF('Draw time: %d (%d x %d -> %d x %d, %d)', [TickCountDiff(GetTickCount, vTime),
      FThumbSize.CX, FThumbSize.cy, FViewSize.cx, FViewSize.cy, byte(FLowQuality) ]);
   {$endif bTrace}
  end;


 {-----------------------------------------------------------------------------}

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


  procedure TPluginObject.UpdateThumbnail(const AItem :IFarItem; AFromProcess, AFirstAppear :Boolean);
  var
    vThumbLimit, vViewLimit, vViewDelta :Integer;
    vThmImage :TGPImage;
    vGraphics :TGPGraphics;
    vSize :TSize;
   {$ifdef bTrace}
    vTime :Cardinal;
   {$endif bTrace}
  begin
    FViewSize := FImgSize;
    CorrectBound(FViewSize, MaxViewSize);

//  TraceF('Set size: %d x %d', [FViewSize.CX, FViewSize.CY]);
    AItem.IconWidth := FViewSize.CX;
    AItem.IconHeight := FViewSize.CY;

    if not FDirectDraw then begin

      if AFromProcess then begin
        { Уменьшим размер эскиза до некоторого разумного значения... }
        vSize := FViewSize;
        vThmImage := FSrcImage;

        if UseThumbnail and (not AFirstAppear or (IntMax(vSize.cx, vSize.cy) <= cThumbSize)) then begin
          CorrectBound(vSize, cThumbSize);
         {$ifdef bTrace}
          vTime := GetTickCount;
         {$endif bTrace}
          vThmImage := FSrcImage.GetThumbnailImage(vSize.CX, vSize.CY, nil, nil);
         {$ifdef bTrace}
          TraceF('GetThumbnail time: %d ms (%d x %d)', [TickCountDiff(GetTickCount, vTime), vThmImage.GetWidth, vThmImage.GetHeight]);
         {$endif bTrace}
          if (vThmImage = nil) or (vThmImage.GetLastStatus <> Ok) then begin
            FreeObj(vThmImage);
            vThmImage := FSrcImage;
          end;
        end;  

        try
          FThumbSize.cx := vThmImage.GetWidth;
          FThumbSize.cy := vThmImage.GetHeight;
          CorrectBound(FThumbSize, IntMax(FViewSize.cx, FViewSize.cy));

         {$ifdef bTrace}
          vTime := GetTickCount;
         {$endif bTrace}
          if FThumbImage <> nil then
            Assert(FThumbImage <> nil);
          FThumbImage := TMemDC.Create(0, FThumbSize.cx, FThumbSize.cy);
          vGraphics := TGPGraphics.Create(FThumbImage.FDC);
          try
            vGraphics.DrawImage(vThmImage, 0, 0, FThumbSize.cx, FThumbSize.cy);
          finally
            vGraphics.Free;
          end;
         {$ifdef bTrace}
          TraceF('Thumb render time: %d ms (%d x %d)', [TickCountDiff(GetTickCount, vTime), FThumbSize.cx, FThumbSize.cy]);
         {$endif bTrace}

        finally
          if vThmImage <> FSrcImage then
            FreeObj(vThmImage);
        end;
      end;

      { Проверяем размеры эскиза на допустимые размеры, только если предыдущее }
      { задание на декомпрессию уже завершено. В противном случае ждем завершения }
      { задания, даже если извлекаемый эскиз неподходящего размера. }
      { Повторное извлечение будет инициализировано в Idle'е... }
      if not FThumbWait then begin
        vThumbLimit := IntMax(FThumbSize.cx, FThumbSize.cy);
        vViewLimit := IntMax(FViewSize.cx, FViewSize.cy);
        vViewDelta := MulDiv(vViewLimit, cRescalePerc, 100);

        if (vThumbLimit = 0) or (vThumbLimit < vViewLimit - vViewDelta) or (vThumbLimit > vViewLimit + vViewDelta) then
          { Ставим задание на асинхронную декомпрессию }
          SetAsyncTask(FViewSize);
      end;

    end;
  end;


 {-----------------------------------------------------------------------------}
 { Поток для фоновой декомпрессии картинок                                     }

  function ThreadProc(Thread :Pointer) :TIntPtr;
  begin
    Result := 0;
    try
      TPluginObject(Thread).Execute;
    finally
      EndThread(Result);
    end;
  end;


  procedure TPluginObject.StartPluginThread;
  begin
    FTerminated := False;
    FThreadGoDown := False;
    FHandle := BeginThread(nil, 0, ThreadProc, Pointer(Self), 0, FThreadID);  //CreateThread
  end;


  procedure TPluginObject.StopPluginThread;
  begin
    if FHandle <> 0 then begin
      FTerminated := True;
      WaitForSingleObject(FHandle, INFINITE);
      CloseHandle(FHandle);
      FHandle := 0;
    end;
  end;


  procedure TPluginObject.Execute;
  var
    vTime :Cardinal;
  begin
//  Trace('Init thread...');

    vTime := GetTickCount;

    while not FTerminated and not FThreadGoDown do begin

      EnterCriticalSection(FCSection);
      try
        FThreadGoDown := (FLock = 0) and (FTaskState <> tsWait) and (TickCountDiff(GetTickCount, vTime) >= ThreadIdlePeriod);
        if FThreadGoDown then
          Break;
      finally
        LeaveCriticalSection(FCSection);
      end;

      if ProcessAsyncRequest then begin
        vTime := GetTickCount;
      end;

      Sleep(1);
    end;

//  Trace('Done thread...');
  end;


  function TPluginObject.ProcessAsyncRequest :Boolean;
  var
    vImage    :TGPImageEx;
    vSize     :TSize;
    vThumb    :TMemDC;
    vGraphics :TGPGraphics;
   {$ifdef bTrace}
    vTime     :Cardinal;
   {$endif bTrace}
  begin
    Result := False;

    EnterCriticalSection(FCSection);
    try
      if (FTaskState <> tsWait) or (TickCountDiff(GetTickCount, FTaskStart) < AsyncRenderDelay) then
        Exit;

      FreeObj(FResThumb);

      vImage := FTaskImage;
      FTaskImage := nil;

      vSize  := FTaskSize;
      FTaskState := tsProceed;
    finally
      LeaveCriticalSection(FCSection);
    end;

    try
     {$ifdef bTrace}
      vTime := GetTickCount;
     {$endif bTrace}
      vThumb := TMemDC.Create(0, vSize.CX, vSize.CY);
      vGraphics := TGPGraphics.Create(vThumb.FDC);
      try
        vGraphics.DrawImage(vImage, 0, 0, vSize.CX, vSize.CY);
      finally
        vGraphics.Free;
      end;
     {$ifdef bTrace}
      TraceF('Render time: %d ms (%d x %d)', [TickCountDiff(GetTickCount, vTime), vSize.CX, vSize.CY]);
     {$endif bTrace}

    finally
      vImage._Release;
    end;

    EnterCriticalSection(FCSection);
    try
      if FTaskState = tsProceed then begin
        FResThumb := vThumb;
        FTaskState := tsComplete;
      end else
        { Пока эскиз извлекался, была поставлена новая задача, результат никого не интересует }
        FreeObj(vThumb);
    finally
      LeaveCriticalSection(FCSection);
    end;

    Result := True;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TPluginObject.SetAsyncTask(ASize :TSize);
  begin
//  TraceF('SetAsyncTask: %d x %d', [ASize.CX, ASize.CY]);

    EnterCriticalSection(FCSection);
    try
      Inc(FLock);
    finally
      LeaveCriticalSection(FCSection);
    end;

    try
      if (FHandle <> 0) and FThreadGoDown then
        StopPluginThread;
      if FHandle = 0 then
        StartPluginThread;

      EnterCriticalSection(FCSection);
      try
        if FResThumb <> nil then
          FreeObj(FResThumb);

        Assert(FTaskImage = nil);
        FTaskImage := FSrcImage;
        FTaskImage._AddRef;

        FTaskStart := GetTickCount;
        FTaskSize  := ASize;
        FTaskState := tsWait;

      finally
        LeaveCriticalSection(FCSection);
      end;

      FThumbWait := True;

    finally
      EnterCriticalSection(FCSection);
      try
        Dec(FLock);
      finally
        LeaveCriticalSection(FCSection);
      end;
    end;
  end;


  procedure TPluginObject.CheckAsyncTask;
  begin
    EnterCriticalSection(FCSection);
    try
      if FTaskState = tsComplete then begin
        FreeObj(FThumbImage);

        FThumbImage := FResThumb;
        FResThumb := nil;

        FThumbSize.cx := FThumbImage.FWidth;
        FThumbSize.cy := FThumbImage.FHeight;

        FThumbWait := False;
      end;
    finally
      LeaveCriticalSection(FCSection);
    end;
  end;


  procedure TPluginObject.CancelTask;
  begin
    EnterCriticalSection(FCSection);
    try
      if FResThumb <> nil then
        FreeObj(FResThumb);
      if FTaskImage <> nil then begin
        FTaskImage._Release;
        FTaskImage := nil;
      end;
      FTaskState := tsNone;
    finally
      LeaveCriticalSection(FCSection);
    end;
  end;

  
 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.

{$I Defines.inc}

unit ReviewConst;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,

    Far_API,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,
    FarMenu,
    FarColorDlg,

    FarCtrl,
    FarConfig;
    

  {$I Lang.inc}  { Lang.templ -> Doc\ReviewEng.lng + Doc\ReviewRus.lng }


  const
    cPluginName = 'Review';
    cPluginDescr = 'Image Viewer FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{0364224C-A21A-42ED-95FD-34189BA4B204}';
    cMenuID     :TGUID = '{E74543AF-CA5B-4A57-935F-1335B2872C7C}';
    cConfigID   :TGUID = '{F775001B-04F6-4BC8-B807-3F6A73F76DDC}';
   {$else}
    cPluginID       = $424C434D;
   {$endif Far3}

    cViewDlgID :TGUID = '{FAD3BD72-2641-4D00-8F98-5467EEBCE827}';
    cThumbDlgID :TGUID = '{ABDFD3DF-FE59-4714-8068-9F944022EA50}';
    cConfigDlgID :TGUID = '{A69784DA-05AF-49A1-B7EB-853215215B68}';
    cDecoderDlgID :TGUID = '{83F5946C-7BD9-40FA-8FE6-683A215BD1C1}';
    cDecoderListDlgID :TGUID = '{F7476A5F-4795-41C0-AC3D-77A5537558AC}';

    cPluginsMask  = '*.pvd';
    cDefPVDFolder = 'PVD';
    cDefGDIDecoderName = 'GDI+';
    cDefGDIDecoderTitle = 'GDI+';
    cBackgroundFile = 'Background.bmp';

    cRegPath = 'Software\Far Manager\Plugins\Review';  { Для старых субплагинов... }

    cDecodersRegFolder  = 'Decoders';
    cDecoderRegFolder  = 'Decoder';
    cDecodersCount = 'Count';
    cDecoderNameRegKey = 'Name';
    cDecoderKindRegKey = 'Kind';
    cDecoderTitleRegKey = 'Title';
    cDecoderPriorityRegKey = 'Priority';
    cDecoderModifiedRegKey = 'Modified';
    cDecoderEnabledRegKey = 'Enabled';
    cDecoderActiveRegKey = 'ActiveMask';
    cDecoderIgnoreRegKey = 'IgnoreMask';
    cDecoderCustomRegKey = 'CustomMask';

    cMaskHistory      = 'Review.Mask';
    cFileNameHistory  = 'Review.FileName';

  const
    cDefAnimationStep  = 100;           { ms }

  var
    optCmdPrefix      :TString = 'pic';

    optProcessPrefix  :Boolean = True;
    optProcessView    :Boolean = True;
    optProcessQView   :Boolean = True;
    optAsyncQView     :Boolean = True;
    optQViewShowFrame :Boolean = True;
    optPrecache       :Boolean = True;
    optKeepScale      :Boolean = True;        { Сохранять масштаб/позицию при смене изображений }
    optInitialScale   :Integer = 100;         { Начальное увеличение изображений }

    optTranspBack     :Boolean = True;        { Использовать заливку на полупрозрачных картинках }
    optTileMode       :Boolean = False;
    optFullscreen     :Boolean = False;
    optSmoothScale    :Boolean = True;        { Использовать сглаживание при увеличении }
    optShowInfo       :Integer = 1;

    optRotateOnEXIF   :Boolean = True;        { Автоматический поворот на основе информации из EXIF }
    optUseThumbnail   :Boolean = True;        { Использовать эскизы для быстрого листания }
    optCorrectThumb   :Boolean = True;        { Корректируем эскиз, чтобы убрать черные полосы }
    optUseWinSize     :Boolean = True;        { Декодировать под размер окна }
    optKeepDateOnSave :Boolean = True;        { Сохранять дату при декодировании }
    optUnlockFile     :Boolean = True;        { Не блокировать файл, по возможности }

    optDraftDelay     :Integer = 150; {ms}
    optSyncDelay      :Integer = 250; {ms}    { Задержка смены картинки в QuickView (только если включен optAsyncQView) }
    optCacheDelay     :Integer = 100; {ms}
    optTempMsgDelay   :Integer = 2000; {ms}

    optSlideDelay     :Integer = 3000; {ms}   { Задержка SlideShow }
    optEffectType     :Integer = 1;
    optEffectPeriod   :Integer = 250;  {ms}   { Длительность эффекта перехода }
    optEffectOnManual :Boolean = True;        { Использовать эффект перехода при ручном переключении }

   {$ifdef bUseLibJPEG}
    optUseLibJPEG     :Boolean = True;
   {$endif bUseLibJPEG}

    optCacheLimit     :Integer = 4;

    optBkColor1       :TFarColor;
    optBkColor2       :TFarColor;
    optHintColor      :TFarColor;
   {$ifdef bThumbs}
    optBkColor3       :TFarColor;
    optCurColor       :TFarColor;
    optSelColor       :TFarColor;
    optTitleColor     :TFarColor;
   {$endif bThumbs}

    optPanelColor     :TFarColor;
    optPromptColor    :TFarColor;
    optInfoColor      :TFarColor;
    optPanelTransp    :Integer = 128;

   {$ifdef bThumbs}
    optThumbSize       :Integer = 96;
    optThumbFullscreen :Boolean = False;
    optThumbShowTitle  :Boolean = True;    { Показывать имена файлов }
    optThumbFoldTitle  :Boolean = False;   { Сворачивать имена файлов }
    optThumbShowInfo   :Boolean = False;   { Показывать информацию о декодере (для отладки) }
    optZoomThumb       :Boolean = False;   { Масштабировать эскиз по наименьшей размерности (растягивать до "квадрата") }
    optVerticalScroll  :Boolean = True;    { Вертикальная или горизонтальная прокрутка }
    optExtractPriority :Integer = 1;       { 0-Нет, 1-Sys-PVD, 2-Pvd-Sys 3-Sys 4-Pvd }
    optExtractSize     :Boolean = True;    { При извлечении системных эскизов сначала пытаемся получить информацию через pvd }
    optThumbAutoRotate :Boolean = True;    { Автоматический поворот эскизов на основе информации из EXIF }
    optThumbFirst      :Boolean = False;   { Сначала декодировать эскизы, для которых есть preview (быстрое декодирование) }
    optRenderAhead     :Boolean = True;    { Декодировать на экран больше эскизов (в направлении прокрутки) }
    optMouseSelect     :Boolean = False;   { Выделеять мышкой (без Shift) }
    optSmoothScroll    :Boolean = True;
    optScrollPeriod    :Integer = 250;
    optThumbFontSize   :Integer = 8;
    optThumbFontName   :TString = '';

    optHandlesLimit    :Integer = 1000;    { Макс кол-во GDI Handles }
   {$endif bThumbs}

  var
    optBigImageLimit  :Integer = 128;      { Если размер картинки превышает эту величину, DecodeWaitDelay считается = 0 }
    DecodeWaitDelay   :Integer = 1000;     { Сколько ждем декодирование, прежде чем показать эскиз. Только при первом открытии. }
    StretchDelay      :Integer = 500;      { Задержка для масштабирования }
    FastListDelay     :Integer = 250;      { Период между декодированиями, по которому определяется быстрое перелистывание }
    ThumbDelay        :Integer = 250;      { Задержка до начала декодирования при перелистывании }


  var
    FFarExePath      :TString;

    OptionsRevision  :Integer;

  const
    SyncCmdUpdateWin   = 1;
    SyncCmdSyncImage   = 2;
    SyncCmdUpdateTitle = 3;
    SyncCmdCacheNext   = 4;
    SyncCmdCachePrev   = 5;
    SyncCmdNextSlide   = 6;
    SyncCmdClose       = 7;
    SyncCmdFullScreen  = 8;
    SyncCmdThumbView   = 9;

  const
    GoCmdNone      = 0;
    GoCmdNext      = 1;
    GoCmdPrev      = 2;
    GoCmdFirst     = 3;
    GoCmdLast      = 4;
    GoCmdNextSlide = 6;
   {$ifdef bThumbs}
    GoCmdThumbs    = 7;
   {$endif bThumbs}


  const
    { Команды CM_Transform }
    cmtInvalidate = 0;
    cmtRotate     = 1;
    cmtOrient     = 2;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  function PlugIdToStr(const ID :TGUID) :TString;

  function MulDivI32(ANum, AMul, ADiv :Integer) :Integer; stdcall;
  function MulDivU32(ANum, AMul, ADiv :UINT) :UINT; stdcall;
  function MulDivU32R(A, B, C :UINT) :UINT; stdcall;
  function MulDivIU32R(A :Integer; B, C :UINT) :Integer; stdcall;
  function SortExtensions(AStr :PTChar) :Integer; stdcall;

  procedure IntSwap(var A, B :Integer);
  procedure CorrectBoundEx(var ASize :TSize; const ALimit :TSize);
  procedure StretchBounds(var ASize :TSize; const ALimit :TSize);
  function YMDStrToDateTime(const AStr :TString) :TDateTime;
  function ScrollKeyPressed :Boolean;
  function FarKeyToName(AKey :Integer) :TString;

  procedure PluginConfig(AStore :Boolean);
  procedure RestoreDefColor;
  procedure ColorMenu;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewGDIPlus,
    MixDebug;


  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;

  function GetMsgStr(AMess :TMessages) :TString;
  begin
    Result := FarCtrl.GetMsgStr(Integer(AMess));
  end;


  procedure AppErrorId(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;


  function PlugIdToStr(const ID :TGUID) :TString;
  begin
    Result := StrDeleteChars(GUIDToString(ID), ['{', '}']);
  end;


 {-----------------------------------------------------------------------------}

(*
	BOOL (__stdcall* CallSehed)(pvdCallSehedProc2 CalledProc, LONG_PTR Param1, LONG_PTR Param2, LONG_PTR* Result);
	int (__stdcall* SortExtensions)(wchar_t* pszExtensions);
	int (__stdcall* MulDivI32)(int a, int b, int c);  // (__int64)a * b / c;
	UINT (__stdcall* MulDivU32)(UINT a, UINT b, UINT c);  // (uint)((unsigned long long)(a)*(b)/(c))
	UINT (__stdcall* MulDivU32R)(UINT a, UINT b, UINT c);  // (uint)(((unsigned long long)(a)*(b) + (c)/2)/(c))
	int (__stdcall* MulDivIU32R)(int a, UINT b, UINT c);  // (int)(((long long)(a)*(b) + (c)/2)/(c))
  	int (__stdcall* SortExtensions)(wchar_t* pszExtensions);
*)

  function MulDivI32(ANum, AMul, ADiv :Integer) :Integer; stdcall;
  begin
    Result := MulDiv(ANum, AMul, ADiv);
  end;

 {$ifdef b64}
  function MulDivU32(ANum, AMul, ADiv :UINT) :UINT; stdcall;
  begin
    Result := TUnsPtr(ANum) * TUnsPtr(AMul) div TUnsPtr(ADiv);
  end;
 {$else}
  function MulDivU32(ANum, AMul, ADiv :UINT) :UINT; stdcall;
  asm
    mov eax, ANum
    mov edx, AMul
    mul edx         { EDX:EAX := EAX * EDX }

    mov ecx, ADiv
    shr ecx, 1
    add eax, ecx
    adc edx, 00     { EDX:EAX := (ANum * AMul) + ADiv/2 }

    cmp edx, ADiv
    jnb @Error

    div ADiv
    jmp @Ok

  @Error:
    xor eax, eax
    dec eax
  @Ok:
  end;
 {$endif b64}


  function MulDivU32R(A, B, C :UINT) :UINT; stdcall;
  begin
    {!!!}
    Result := (A * B + (C div 2)) div C;
  end;

  function MulDivIU32R(A :Integer; B, C :UINT) :Integer; stdcall;
  begin
    {!!!}
    Result := (Int64(A) * Int64(B) + (C div 2)) div C;
  end;


  function SortExtensions(AStr :PTChar) :Integer; stdcall;
  begin
    Result := 0;
  end;


 {-----------------------------------------------------------------------------}

  procedure IntSwap(var A, B :Integer);
  var
    T :Integer;
  begin
    T := A;
    A := B;
    B := T;
  end;


  procedure CorrectBoundEx(var ASize :TSize; const ALimit :TSize);
  var
    vScale :TFloat;
  begin
    if (ASize.cx > ALimit.cx) or (ASize.cy > ALimit.cy) then begin
      vScale := FloatMin( ALimit.cx / ASize.cx, ALimit.cy / ASize.cy);
      ASize.cx := Round(ASize.cx * vScale);
      ASize.cy := Round(ASize.cy * vScale);
    end;
  end;


  procedure StretchBounds(var ASize :TSize; const ALimit :TSize);
  var
    vScale :TFloat;
  begin
    if (ASize.cx < ALimit.cx) and (ASize.cy < ALimit.cy) then begin
      vScale := FloatMin( ALimit.cx / ASize.cx, ALimit.cy / ASize.cy);
      ASize.cx := Round(ASize.cx * vScale);
      ASize.cy := Round(ASize.cy * vScale);
    end;
  end;


  function YMDStrToDateTime(const AStr :TString) :TDateTime;
  const
    cDel = [' ', ':', '.', '-'];
  var
    vPtr :PTChar;
    Y, M, D, H, N, S :Integer;
    vDate, vTime :TDateTime;
  begin
    Result := 0;
    vPtr := PTChar(AStr);
    Y := Str2IntDef(ExtractNextWord(vPtr, cDel), 0);
    M := Str2IntDef(ExtractNextWord(vPtr, cDel), 0);
    D := Str2IntDef(ExtractNextWord(vPtr, cDel), 0);
    H := Str2IntDef(ExtractNextWord(vPtr, cDel), 0);
    N := Str2IntDef(ExtractNextWord(vPtr, cDel), 0);
    S := Str2IntDef(ExtractNextWord(vPtr, cDel), 0);
    if (Y >= 1000) and (Y <= 9999) then
      if TryEncodeDate(Y, M, D, vDate) and TryEncodeTime(H, N, S, 0, vTime) then
        Result := vDate + vTime;
  end;


  function ScrollKeyPressed :Boolean;
  begin
    Result :=
      (GetKeyState(VK_NEXT) < 0) or (GetKeyState(VK_PRIOR) < 0) or
      (GetKeyState(VK_UP) < 0) or (GetKeyState(VK_DOWN) < 0) or
      (GetKeyState(VK_LEFT) < 0) or (GetKeyState(VK_RIGHT) < 0) or
      (GetKeyState(VK_ADD) < 0) or (GetKeyState(VK_SUBTRACT) < 0);
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


 {-----------------------------------------------------------------------------}

  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

//      if AStore then
//        Beep;

        StrValue('Prefix', optCmdPrefix);

        LogValue('ProcessView', optProcessView);
        LogValue('ProcessQView', optProcessQView);
        LogValue('AsyncQView', optAsyncQView);
        LogValue('FrameQView', optQViewShowFrame);
        LogValue('Precache', optPrecache);
        LogValue('KeepScale', optKeepScale);
        IntValue('InitialScale', optInitialScale);

        LogValue('RotateOnExif', optRotateOnEXIF);
        LogValue('UseThumbnail', optUseThumbnail);
        LogValue('UseWinSize', optUseWinSize);
        LogValue('KeepDateOnSave', optKeepDateOnSave);

        ColorValue('BkColor1', optBkColor1);
        ColorValue('BkColor2', optBkColor2);

        ColorValue('HintColor', optHintColor);
        ColorValue('PanelColor', optPanelColor);
        ColorValue('PromptColor', optPromptColor);
        ColorValue('InfoColor', optInfoColor);

        IntValue('SlideDelay', optSlideDelay);
        IntValue('SlideEffect', optEffectType);
        IntValue('EffectPeriod', optEffectPeriod);
        LogValue('EffectAlways', optEffectOnManual);

        LogValue('Fullscreen', optFullscreen);
        IntValue('ShowInfo', optShowInfo);

       {$ifdef bThumbs}
        IntValue('ThumbSize', optThumbSize);
        LogValue('ThumbShowTitle', optThumbShowTitle);
        LogValue('ThumbVertScroll', optVerticalScroll);
        IntValue('ThumbExtract', optExtractPriority);
        LogValue('ThumbAutoRotate', optThumbAutoRotate);
        LogValue('ThumbFullscreen', optThumbFullscreen);
        LogValue('SmoothScroll', optSmoothScroll);

        ColorValue('BkColor3', optBkColor3);
        ColorValue('TitleColor', optTitleColor);
        ColorValue('CurThumbColor', optCurColor);
        ColorValue('SelThumbColor', optSelColor);
       {$endif bThumbs}
      finally
        Destroy;
      end;
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optBkColor1 := MakeColor(clWhite, clBlack);
    optBkColor2 := FarGetColor(COL_VIEWERTEXT);
    optHintColor := MakeColor(clBlack, clWhite);

    optPanelColor := MakeColor(clBlack, clWhite);
    optPromptColor := MakeColor(clSilver, clBlack);
    optInfoColor := MakeColor(clWhite, clBlack);

   {$ifdef bThumbs}
    optBkColor3 := FarGetColor(COL_PANELTEXT);
    optTitleColor := FarGetColor(COL_PANELTEXT);
    optCurColor := FarGetColor(COL_PANELCURSOR);
    optSelColor := MakeColor(clBlack, clYellow);
   {$endif bThumbs}
  end;


  procedure ColorMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strColors),
    [
      GetMsg(strMViewColor),
      GetMsg(strMQViewColor),
      '',
      GetMsg(strMPanelColor),
      GetMsg(strMPromptColor),
      GetMsg(strMInfoColor),
      GetMsg(strMTextColor),
      '',
     {$ifdef bThumbs}
      GetMsg(strMThumbColor),
      GetMsg(strMThumbCaptionColor),
      GetMsg(strMThumbCurrentColor),
      GetMsg(strMThumbSelectedColor),
      '',
     {$endif bThumbs}
      GetMsg(strMRestoreDefaults)
    ]);
    try
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ColorDlg('', optBkColor1, UndefAttr, 0);
          1: ColorDlg('', optBkColor2, UndefAttr, 0);

          3: ColorDlg('', optPanelColor);
          4: ColorDlg('', optPromptColor);
          5: ColorDlg('', optInfoColor);
          6: ColorDlg('', optHintColor);

         {$ifdef bThumbs}
          8: ColorDlg('', optBkColor3);
          9: ColorDlg('', optTitleColor);
         10: ColorDlg('', optCurColor, UndefAttr, 0);
         11: ColorDlg('', optSelColor, UndefAttr, 0);
         {$endif bThumbs}

        else
          RestoreDefColor;
        end;

//      FarAdvControl(ACTL_REDRAWALL, nil);

        PluginConfig(True);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.

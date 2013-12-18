{$I Defines.inc}

unit ReviewConst;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* Review                                                                     *}
{* Image Viewer Plugn for Far 2/3                                             *}
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

    cMaskHistory      = 'Review.Mask';
    cFileNameHistory  = 'Review.FileName';

  const
    cDefAnimationStep  = 50;           { ms }

  var
    optCmdPrefix      :TString = 'pic';

    optProcessPrefix  :Boolean = True;
    optProcessView    :Boolean = True;
    optProcessQView   :Boolean = True;
    optAsyncQView     :Boolean = True;
    optQViewShowFrame :Boolean = True;
    optPrecache       :Boolean = True;
    optKeepScale      :Boolean = True;        { Сохранять масштаб/позицию при смене изображений }

    optTranspBack     :Boolean = True;        { Использовать заливку на полупрозрачных картинках }
    optTileMode       :Boolean = False;
    optFullscreen     :Boolean = False;
    optSmoothScale    :Boolean = True;        { Использовать сглаживание при увеличении }
    optShowInfo       :Integer = 0;

    optDraftDelay     :Integer = 150; {ms}
    optSyncDelay      :Integer = 250; {ms}    { Задержка смены картинки в QuickView (только если включен optAsyncQView) }
    optCacheDelay     :Integer = 100; {ms}
    optTempMsgDelay   :Integer = 2000; {ms}

    optCacheLimit     :Integer = 4;

    optInitialScale   :Integer = 100;         { Начальное увеличение изображений }

    optBkColor1       :TFarColor;
    optBkColor2       :TFarColor;
    optTextColor      :TFarColor;

  var
    FFarExePath      :TString;

  const
    SyncCmdUpdateWin   = 1;
    SyncCmdSyncImage   = 2;
    SyncCmdUpdateTitle = 3;
    SyncCmdCacheNext   = 4;
    SyncCmdCachePrev   = 5;

  const
    GoCmdNone   = 0;
    GoCmdNext   = 1;
    GoCmdPrev   = 2;
    GoCmdFirst  = 3;
    GoCmdLast   = 4;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  function MulDivI32(ANum, AMul, ADiv :Integer) :Integer; stdcall;
  function MulDivU32(ANum, AMul, ADiv :UINT) :UINT; stdcall;
  function MulDivU32R(A, B, C :UINT) :UINT; stdcall;
  function MulDivIU32R(A :Integer; B, C :UINT) :Integer; stdcall;
  function SortExtensions(AStr :PTChar) :Integer; stdcall;

  function ScrollKeyPressed :Boolean;

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


  function ScrollKeyPressed :Boolean;
  begin
    Result :=
      (GetKeyState(VK_NEXT) < 0) or (GetKeyState(VK_PRIOR) < 0) or
      (GetKeyState(VK_UP) < 0) or (GetKeyState(VK_DOWN) < 0) or
      (GetKeyState(VK_LEFT) < 0) or (GetKeyState(VK_RIGHT) < 0) or
      (GetKeyState(VK_ADD) < 0) or (GetKeyState(VK_SUBTRACT) < 0);
  end;


 {-----------------------------------------------------------------------------}

  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

        StrValue('Prefix', optCmdPrefix);

        LogValue('ProcessView', optProcessView);
        LogValue('ProcessQView', optProcessQView);
        LogValue('AsyncQView', optAsyncQView);
        LogValue('FrameQView', optQViewShowFrame);
        LogValue('Precache', optPrecache);
        LogValue('KeepScale', optKeepScale);

        LogValue('RotateOnExif', optRotateOnEXIF);
        LogValue('UseThumbnail', optUseThumbnail);
        LogValue('UseWinSize', optUseWinSize);
        LogValue('KeepDateOnSave', optKeepDateOnSave);

        ColorValue('BkColor1', optBkColor1);
        ColorValue('BkColor2', optBkColor2);

        LogValue('Fullscreen', optFullscreen);

      finally
        Destroy;
      end;
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optBkColor1  := MakeColor(clWhite, clBlack);
    optBkColor2  := FarGetColor(COL_VIEWERTEXT);
    optTextColor := MakeColor(clWhite, clBlack);
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
      GetMsg(strMTextColor),
      '',
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
          2: ColorDlg('', optTextColor);

          4: RestoreDefColor;
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

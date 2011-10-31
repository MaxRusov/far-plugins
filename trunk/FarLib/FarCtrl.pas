{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Вспомогательные интерфейсные процедуры                                     *}
{******************************************************************************}

{$I Defines.inc}
{$Typedaddress Off}

unit FarCtrl;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarKeysW,
    FarColor
    ;

  type
    TFarStr  = TWideStr;
    PFarStr  = PWideStr;

   {$ifdef Far3}
   {$else}
    StrOemToAnsi = TString;
    StrAnsiToOEM = TString;
   {$endif Far3}

  const
   {$ifdef Far3}
   {$else}
    cFarRegRoot = 'Software\Far2';
   {$endif Far3}

   {$ifdef bUnicodeFar}
    chrVertLine = #$2502;
    chrUpArrow  = #$25B2;
    chrDnArrow  = #$25BC;
    chrHatch    = #$2591;
    chrDkHatch  = #$2593;
    chrBrick    = #$2588;
    chrCheck    = #$FB;
   {$else}
    chrVertLine = #$B3;
    chrUpArrow  = #$1E;
    chrDnArrow  = #$1F;
    chrHatch    = #$B0;
    chrDkHatch  = #$B2;
    chrBrick    = #$DB;
    chrCheck    = #$FB;
   {$endif bUnicodeFar}


  const
    clBlack    = 0;   // Черный
    clNavy     = 1;   // Темно синий
    clGreen    = 2;   // Темно зеленый
    clTeal     = 3;   // Темный циан
    clMaroon   = 4;   // Темно красный
    clPurple   = 5;   // Пурпурный
    clOlive    = 6;   // Темно желтый
    clSilver   = 7;   // Светло серый
    clGray     = 8;   // Темно серый
    clBlue     = 9;   // Голубой
    clLime     = $A;  // Светло зеленый
    clCyan     = $B;  // Aqua
    clRed      = $C;  // Ярко красный
    clMagenta  = $D;  // Fuchsia
    clYellow   = $E;  // Желтый
    clWhite    = $F;  // Белый

   {$ifdef Far3}
   {$else}
    clBkBlack   = clBlack   * $10;
    clBkNavy    = clNavy    * $10;
    clBkGreen   = clGreen   * $10;
    clBkTeal    = clTeal    * $10;
    clBkMaroon  = clMaroon  * $10;
    clBkPurple  = clPurple  * $10;
    clBkOlive   = clOlive   * $10;
    clBkSilver  = clSilver  * $10;
    clBkGray    = clGray    * $10;
    clBkBlue    = clBlue    * $10;
    clBkLime    = clLime    * $10;
    clBkCyan    = clCyan    * $10;
    clBkRed     = clRed     * $10;
    clBkMagenta = clMagenta * $10;
    clBkYellow  = clYellow  * $10;
    clBkWhite   = clWhite   * $10;
   {$endif Far3}


 {-----------------------------------------------------------------------------}

  const
    MIF_CHECKED1 = MIF_CHECKED { or Byte(chrCheck)};

    DI_DefButton = DI_USERCONTROL - 1;

  type
   {$ifdef Far3}
   {$else}
    TFarColor = Integer;
    PFarMenuItem = PFarMenuItemEx;
    TFarMenuItem = TFarMenuItemEx;
   {$endif Far3}

   {$ifdef Far3}
    PFarMenuItemsArray = PFarMenuItemArray;
    TFarMenuItemsArray = TFarMenuItemArray;
   {$else}
    PFarMenuItemsArray = ^TFarMenuItemsArray;
    TFarMenuItemsArray = array[0..MaxInt div SizeOf(TFarMenuItem) - 1] of TFarMenuItem;
   {$endif Far3}

 {-----------------------------------------------------------------------------}

  var
    FARAPI  :TPluginStartupInfo;
    FARSTD  :TFarStandardFunctions;

   {$ifdef Far3}
    PluginID   :TGUID;
   {$else}
    hModule    :INT_PTR;
   {$endif Far3}

    hFarWindow :THandle;
    hStdIn     :THandle;
    hStdOut    :THandle;

  var
    UndefColor :TFarColor;

  function FarChar2Str(AStr :PFarChar) :TString;
  procedure FillFarChar(ABuf :PFarChar; ACount :Integer; AChar :TFarChar);
  procedure SetFarChr(ABuf :PFarChar; ASrc :PTChar; AMaxLen :Integer);
  procedure SetFarStr(ABuf :PFarChar; const AStr :TString; AMaxLen :Integer);

  function GetMsg(MsgId :Integer) :PFarChar;
  function GetMsgStr(MsgId :Integer) :TString;

  procedure AppErrorID(ACode :Integer);
  procedure AppErrorIdFmt(ACode :Integer; const Args: array of const);

  function SetFlag(AFlags, AFlag :DWORD; AOn :Boolean) :DWORD;

  procedure SetMenuItemChr(AItem :PFarMenuItem; AStr :PFarChar; AFlags :DWORD = 0);
  procedure SetMenuItemChrEx(var AItem :PFarMenuItem; AStr :PFarChar; AFlags :DWORD = 0);
  procedure SetMenuItemStr(AItem :PFarMenuItem; const AStr :TString; AFlags :DWORD = 0);
  procedure SetMenuItemStrEx(var AItem :PFarMenuItem; const AStr :TString; AFlags :DWORD = 0);

  procedure SetListItem(AItem :PFarListItem; AStr :PFarChar; AFlags :DWORD);

  function FarCreateMenu(const AItems :array of PFarChar; AItemCount :PInteger = nil) :PFarMenuItemsArray;
 {$ifdef bUnicodeFar}
  procedure CleanupMenu(AItem :PFarMenuItem; ACount :Integer);
  procedure CleanupList(AItem :PFarListItem; ACount :Integer);
 {$endif bUnicodeFar}

  function NewItemApi(AType :Integer; X, Y, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
  function CreateDialog(const AItems :array of TFarDialogItem; AItemCount :PInteger = nil) :PFarDialogItemArray;
  function RunDialog( X1, Y1, DX, DY :Integer; AHelpTopic :PFarChar;
    AItems :PFarDialogItemArray; ACount :Integer; AFlags :DWORD; ADlgProc :TFarApiWindowProc;
   {$ifdef Far3}
    const AID :TGUID;
   {$endif Far3}
    AParam :TIntPtr
    ) :Integer;

  function GetProgressStr(ALen, APerc :Integer) :TString;
  function ShowMessage(const ATitle, AMessage :TString; AFlags :Integer; AButtons :Integer = 0) :Integer;
  function FarInputBox(ATitle, APrompt :PTChar; var AStr :TString; AFlags :DWORD = FIB_BUTTONS or FIB_ENABLEEMPTY;
    AHistory :PTChar = nil; AHelp :PTChar = nil; AMaxLen :Integer = 1024) :Boolean;

  function FarSendDlgMessage(ADlg :THandle; AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr; overload;
  function FarSendDlgMessage(ADlg :THandle; AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr; overload;
  function FarAdvControl(ACommand :Integer; AParam :Pointer) :Integer;
  function FarEditorControl(ACommand :Integer; AParam :Pointer) :Integer;
  function FarViewerControl(ACommand :Integer; AParam :Pointer) :Integer;
  function FarRegexpControl(AHandle :THandle; ACommand :Integer; AParam :Pointer) :Integer;

  function FarGetColor(ASysColor :TPaletteColors) :TFarColor;
  function IsUndefColor(const AColor :TFarColor) :Boolean;
  function MakeColor(AFGColor, ABGColor :DWORD) :TFarColor;
  function EqualColor(AColor1, AColor2 :TFarColor) :Boolean;
  function GetColorFG(const AColor :TFarColor) :DWORD;
  function GetColorBG(const AColor :TFarColor) :DWORD;
  function ChangeFG(const AColor, AFGColor :TFarColor) :TFarColor;
  function ChangeBG(const AColor, ABGColor :TFarColor) :TFarColor;
  function GetOptColor(const AColor :TFarColor; ASysColor :TPaletteColors) :TFarColor;

  function FarPanelItem(AHandle :THandle; ACmd, AIndex :Integer) :PPluginPanelItem;
  function FarPanelItemName(AHandle :THandle; ACmd, AIndex :Integer) :TString;
    { ACmd = FCTL_GETPANELITEM, FCTL_GETSELECTEDPANELITEM, FCTL_GETCURRENTPANELITEM }
  function FarPanelString(AHandle :THandle; ACmd :Integer) :TFarStr;
    { ACmd = FCTL_GETPANELDIR, FCTL_GETPANELFORMAT, FCTL_GETPANELHOSTFILE, FCTL_GETCMDLINE, FCTL_GETCOLUMNTYPES}
  function FarPanelGetCurrentDirectory(AHandle :THandle) :TFarStr;
  function FarGetCurrentDirectory :TFarStr;

  function FarGetPanelInfo(AHandle :THandle; var AInfo :TPanelInfo) :Boolean;
  function FarPanelGetSide :Integer;

  procedure FarPostMacro(const AStr :TFarStr; AFlags :DWORD =
    {$ifdef Far3}
     KMFLAGS_DISABLEOUTPUT or KMFLAGS_NOSENDKEYSTOPLUGINS;
    {$else}
     KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;
    {$endif Far3}
     AKey :DWORD = 0);
  function FarCheckMacro(const AStr :TFarStr; ASilent :Boolean; ACoord :PCoord = nil) :Boolean;
  function FarGetMacroArea :Integer;
  function FarGetMacroState :Integer;

  function FarPluginControl(ACommand :Integer; AParam1 :Integer; AParam2 :Pointer) :Integer;
 {$ifdef Far3}
  function FarGetPluginInfo(AIndex :Integer; var AInfo :PFarPluginInfo; APreallocate :Integer = 1024) :Boolean;
 {$endif Far3}

  procedure FarPanelJumpToPath(Active :Boolean; const APath :TString);
  function FarPanelGetCurrentItem(Active :Boolean) :TString;
  function FarPanelSetCurrentItem(Active :Boolean; const AItem :TString) :Boolean;
  procedure FarPanelGetSelectedItems(Active :Boolean; AItems :TStringList);
  procedure FarPanelSetSelectedItems(Active :Boolean; AItems :TStringList; AClearAll :Boolean = True);

  procedure FarEditorSetColor(ARow, ACol, ALen :Integer; AColor :TFarColor; AWholeTab :Boolean = False);
  procedure FarEditorDelColor(ARow, ACol, ALen :Integer);
  function EditorControlString(ACmd :Integer) :TFarStr;
  procedure FarEditOrView(const AFileName :TString; AEdit :Boolean; AFlags :Integer = 0; ARow :Integer = 0; ACol :Integer = 1);

  function FarGetWindowInfo(APos :Integer; var AInfo :TWindowInfo; AName :PTString = nil; ATypeName :PTString = nil) :boolean;
  function FarExpandFileName(const AFileName :TString) :TString;
  function FarGetWindowRect :TSmallRect;
  function FarGetWindowSize :TSize;

  procedure FarCopyToClipboard(const AStr :TString);

  function FarXLat(AChr :TChar) :TChar;
  function FarXLatStr(const AStr :TString) :TString;

  { Для совместимости к KEY_ кодами FAR2 }
  function KeyEventToFarKey(const AEvent :TKeyEventRecord) :Integer;
  function FarKeyToKeyEvent(AKey :Integer; var AEvent :TKeyEventRecord) :Boolean;
  function MouseEventToFarKey(const AEvent :TMouseEventRecord) :Integer;
  function MouseEventToFarKeyEx(const AEvent :TMouseEventRecord; AOldState :DWORD; var APress, ADouble :Boolean) :Integer;
  function FarKeyToMouseEvent(AKey :Integer; var AEvent :TMouseEventRecord) :Boolean;
  function FarKeyToInputRecord(AKey :Integer; var ARec :INPUT_RECORD) :Boolean;

 {$ifdef Far3}
 {$else}
  procedure EnumFilesEx(const ADir, AMask :TFarStr; const aProc :TMethod);
 {$endif Far3}

  function CheckForEsc :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function FarChar2Str(AStr :PFarChar) :TString;
  begin
    Result := AStr;
  end;


  procedure FillFarChar(ABuf :PFarChar; ACount :Integer; AChar :TFarChar);
  begin
   {$ifdef bUnicodeFar}
    MemFill2(ABuf, ACount, Word(AChar));
   {$else}
    FillChar(ABuf^, ACount, AChar);
   {$endif bUnicodeFar}
  end;


  procedure SetFarChr(ABuf :PFarChar; ASrc :PTChar; AMaxLen :Integer);
  begin
    StrLCopy(ABuf, ASrc, AMaxLen);
  end;

  
  procedure SetFarStr(ABuf :PFarChar; const AStr :TString; AMaxLen :Integer);
  begin
    SetFarChr(ABuf, PTChar(AStr), AMaxLen);
  end;


  function GetMsg(MsgId :Integer) :PFarChar;
  begin
   {$ifdef Far3}
    Result := FARAPI.GetMsg(PluginID, MsgId);;
   {$else}
    Result := FARAPI.GetMsg(FARAPI.ModuleNumber, MsgId);
   {$endif Far3}
  end;


  function GetMsgStr(MsgId :Integer) :TString;
  begin
    Result := GetMsg(MsgId);
  end;


  procedure AppErrorId(ACode :Integer);
  begin
    AppError(GetMsgStr(ACode));
  end;


  procedure AppErrorIdFmt(ACode :Integer; const Args: array of const);
  begin
    AppError(Format(GetMsgStr(ACode), Args));
  end;


  function SetFlag(AFlags, AFlag :DWORD; AOn :Boolean) :DWORD;
  begin
    if AOn then
      Result := AFlags or AFlag
    else
      Result := AFlags and not AFlag;
  end;


  procedure SetMenuItemChr(AItem :PFarMenuItem; AStr :PFarChar; AFlags :DWORD = 0);
  begin
    AItem.TextPtr := AStr;
    AItem.Flags := AFlags;
  end;


  procedure SetMenuItemChrEx(var AItem :PFarMenuItem; AStr :PFarChar; AFlags :DWORD = 0);
  begin
    SetMenuItemChr(AItem, AStr, AFlags);
    Inc(Pointer1(AItem), SizeOf(TFarMenuItem));
  end;


  procedure SetMenuItemStr(AItem :PFarMenuItem; const AStr :TString; AFlags :DWORD = 0);
  begin
    SetMenuItemChr(AItem, StrNewW(PWideChar(AStr)), AFlags);
  end;


  procedure SetMenuItemStrEx(var AItem :PFarMenuItem; const AStr :TString; AFlags :DWORD = 0);
  begin
    SetMenuItemStr(AItem, AStr, AFlags);
    Inc(Pointer1(AItem), SizeOf(TFarMenuItem));
  end;



  procedure SetListItem(AItem :PFarListItem; AStr :PFarChar; AFlags :DWORD);
  begin
    AItem.TextPtr := StrNewW(AStr);
    AItem.Flags := AFlags;
  end;


  function FarCreateMenu(const AItems :array of PFarChar; AItemCount :PInteger = nil) :PFarMenuItemsArray;
  var
    I, vCount :Integer;
    vItem :PFarMenuItem;
  begin
    vCount := High(AItems) + 1;
    Result := MemAllocZero(vCount * SizeOf(TFarMenuItem));
    vItem := @Result[0];
    for I := 0 to vCount - 1 do begin
      if AItems[I]^ <> #0 then
        SetMenuItemChrEx(vItem, AItems[I])
      else
        SetMenuItemChrEx(vItem, '', MIF_SEPARATOR)
    end;
    if AItemCount <> nil then
      AItemCount^ := vCount;
  end;


 {$ifdef bUnicodeFar}
  procedure CleanupMenu(AItem :PFarMenuItem; ACount :Integer);
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do begin
      StrDispose(AItem.TextPtr);
      Inc(Pointer1(AItem), SizeOf(TFarMenuItem));
    end;
  end;

  procedure CleanupList(AItem :PFarListItem; ACount :Integer);
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do begin
      StrDispose(AItem.TextPtr);
      Inc(Pointer1(AItem), SizeOf(TFarListItem));
    end;
  end;
 {$endif bUnicodeFar}


 {-----------------------------------------------------------------------------}

  function GetProgressStr(ALen, APerc :Integer) :TString;
  var
    vFilled :Integer;
  begin
    vFilled := MulDiv(ALen, RangeLimit(APerc, 0, 100), 100);
    Result := StringOfChar(chrBrick, vFilled) + StringOfChar(chrHatch, ALen - vFilled);
  end;


  function ShowMessage(const ATitle, AMessage :TString; AFlags :Integer; AButtons :Integer = 0) :Integer;
  var
    vStr :TFarStr;
   {$ifdef Far3}
    vDlgID :TGUID;
   {$endif Far3}
  begin
    vStr := ATitle + #10 + AMessage;
   {$ifdef Far3}
    FillZero(vDlgID, SizeOf(vDlgID));
   {$endif Far3}
    Result := FARAPI.Message(
     {$ifdef Far3}
      PluginID,
      vDlgID,
     {$else}
      hModule,
     {$endif Far3}
      AFlags or FMSG_ALLINONE, nil, PPCharArray(PFarChar(vStr)), 0, AButtons);
  end;


  function FarInputBox(ATitle, APrompt :PTChar; var AStr :TString; AFlags :DWORD = FIB_BUTTONS or FIB_ENABLEEMPTY;
    AHistory :PTChar = nil; AHelp :PTChar = nil; AMaxLen :Integer = 1024) :Boolean;
  var
    vStr :TString;
   {$ifdef Far3}
    vDlgID :TGUID;
   {$endif Far3}
  begin
    SetLength(vStr, AMaxLen);
   {$ifdef Far3}
    vDlgID := GUID_NULL;
   {$endif Far3}
    Result := FARAPI.InputBox(
     {$ifdef Far3}
      PluginID,
      vDlgID,
     {$endif Far3}
      ATitle, APrompt, AHistory, PTChar(AStr), PTChar(vStr), AMaxLen, AHelp, AFlags) = 1;

    if Result then
      AStr := PTChar(vStr);
  end;


 {-----------------------------------------------------------------------------}

  function NewItemApi(AType :Integer; X, Y, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
  begin
    FillChar(Result, SizeOf(Result), 0);
    with Result do begin
      ItemType := IntIf(AType = DI_DefButton, DI_Button, AType);
      X1 := X;
      Y1 := Y;
      if W >= 0 then
        X2 := X + W - 1;
      if H >= 0 then
        Y2 := Y + H - 1;
      Flags := AFlags;
     {$ifdef Far3}
      Data := AText;
      History := AHist;
      if AType = DI_DefButton then
        Flags := Flags or DIF_DEFAULTBUTTON;
     {$else}
      PtrData := AText;
      Param.History := AHist;
      DefaultButton := IntIf(AType = DI_DefButton, 1, 0);
     {$endif Far3}
    end;
  end;


  function CreateDialog(const AItems :array of TFarDialogItem; AItemCount :PInteger = nil) :PFarDialogItemArray;
  var
    I, vCount :Integer;
    vItem :PFarDialogItem;
  begin
    vCount := High(AItems) + 1;
    Result := MemAllocZero(vCount * SizeOf(TFarDialogItem));
    vItem := @Result[0];
    for I := 0 to vCount - 1 do begin
      Move(AItems[I], vItem^, SizeOf(TFarDialogItem));
      Inc(Pointer1(vItem), SizeOf(TFarDialogItem));
    end;
    if AItemCount <> nil then
      AItemCount^ := vCount;
  end;


  function RunDialog( X1, Y1, DX, DY :Integer; AHelpTopic :PFarChar;
    AItems :PFarDialogItemArray; ACount :Integer; AFlags :DWORD; ADlgProc :TFarApiWindowProc;
   {$ifdef Far3}
    const AID :TGUID;
   {$endif Far3}
    AParam :TIntPtr
    ) :Integer;
  var
    hDlg :THandle;
  begin
    hDlg := FARAPI.DialogInit(
     {$ifdef Far3}
      PluginID,
      AID,
     {$else}
      hModule,
     {$endif Far3}
      X1, Y1, DX, DY, AHelpTopic, AItems, ACount, 0, AFlags, ADlgProc, AParam);
    try
      Result := FARAPI.DialogRun(hDlg);
    finally
      FARAPI.DialogFree(hDlg);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function FarSendDlgMessage(ADlg :THandle; AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr;
  begin
    Result := FARAPI.SendDlgMessage(ADlg, AMsg, AParam1, {$ifdef Far3}Pointer(AParam2){$else}AParam2{$endif});
  end;


  function FarSendDlgMessage(ADlg :THandle; AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr;
  begin
    Result := FARAPI.SendDlgMessage(ADlg, AMsg, AParam1, {$ifdef Far3}AParam2{$else}TIntPtr(AParam2){$endif});
  end;


  function FarAdvControl(ACommand :Integer; AParam :Pointer) :Integer;
  begin
   {$ifdef Far3}
    Result := FARAPI.AdvControl(PluginID, ACommand, 0, AParam);
   {$else}
    Result := FARAPI.AdvControl(hModule, ACommand, AParam);
   {$endif Far3}
  end;


  function FarEditorControl(ACommand :Integer; AParam :Pointer) :Integer;
  begin
   {$ifdef Far3}
    Result := FARAPI.EditorControl(-1, ACommand, 0, AParam);
   {$else}
    Result := FARAPI.EditorControl(ACommand, AParam);
   {$endif Far3}
  end;


  function FarViewerControl(ACommand :Integer; AParam :Pointer) :Integer;
  begin
   {$ifdef Far3}
    Result := FARAPI.ViewerControl(-1, ACommand, 0, AParam);
   {$else}
    Result := FARAPI.ViewerControl(ACommand, AParam);
   {$endif Far3}
  end;


  function FarRegexpControl(AHandle :THandle; ACommand :Integer; AParam :Pointer) :Integer;
  begin
   {$ifdef Far3}
    Result := FARAPI.RegExpControl(AHandle, ACommand, 0, AParam);
   {$else}
    Result := FARAPI.RegExpControl(AHandle, ACommand, AParam);
   {$endif Far3}
  end;


  function FarGetColor(ASysColor :TPaletteColors) :TFarColor;
  begin
   {$ifdef Far3}
    FARAPI.AdvControl(PluginID, ACTL_GETCOLOR, Integer(ASysColor), @Result);
   {$else}
    Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(TIntPtr(ASysColor)));
   {$endif Far3}
  end;


  function IsUndefColor(const AColor :TFarColor) :Boolean;
  begin
   {$ifdef Far3}
    Result := (AColor.ForegroundColor = 0) and (AColor.BackgroundColor = 0);
   {$else}
    Result := AColor = 0;
   {$endif Far3}
  end;


  function MakeColor(AFGColor, ABGColor :Cardinal) :TFarColor;
  begin
   {$ifdef Far3}
    Result.Flags := 0; //FCF_4BITMASK;
    Result.ForegroundColor := AFGColor;
    if AFGColor <= $0F then
      Result.Flags := Result.Flags or FCF_FG_4BIT;
    Result.BackgroundColor := ABGColor;
    if ABGColor <= $0F then
      Result.Flags := Result.Flags or FCF_BG_4BIT;
    Result.Reserved := nil;
   {$else}
    Result := (ABGColor * $10) + AFGColor;
   {$endif Far3}
  end;


  function EqualColor(AColor1, AColor2 :TFarColor) :Boolean;
  begin
   {$ifdef Far3}
    Result := (AColor1.ForegroundColor = AColor2.ForegroundColor) and (AColor1.BackgroundColor = AColor2.BackgroundColor) and (AColor1.Flags = AColor2.Flags);
   {$else}
    Result := AColor1 = AColor2;
   {$endif Far3}
  end;


  function GetColorFG(const AColor :TFarColor) :DWORD;
  begin
   {$ifdef Far3}
    Result := AColor.ForegroundColor;
    if FCF_FG_4BIT and AColor.Flags <> 0 then
      Result := Result and $0F;
   {$else}
    Result := AColor and $0F;
   {$endif Far3}
  end;


  function GetColorBG(const AColor :TFarColor) :DWORD;
  begin
   {$ifdef Far3}
    Result := AColor.BackgroundColor;
    if FCF_BG_4BIT and AColor.Flags <> 0 then
      Result := Result and $0F;
   {$else}
    Result := (AColor and $F0) shr 4;
   {$endif Far3}
  end;


  function ChangeFG(const AColor, AFGColor :TFarColor) :TFarColor;
  begin
   {$ifdef Far3}
    Result := MakeColor(GetColorFG(AFGColor), GetColorBG(AColor));
   {$else}
    Result := (AColor and $F0) or (AFGColor and $0F);
   {$endif Far3}
  end;


  function ChangeBG(const AColor, ABGColor :TFarColor) :TFarColor;
  begin
   {$ifdef Far3}
    Result := MakeColor(GetColorFG(AColor), GetColorBG(ABGColor));
   {$else}
    Result := (AColor and $0F) or (ABGColor and $F0);
   {$endif Far3}
  end;


  function GetOptColor(const AColor :TFarColor; ASysColor :TPaletteColors) :TFarColor;
  begin
    Result := AColor;
    if IsUndefColor(AColor) then
      Result := FarGetColor(ASysColor);
  end;


  function FarGetPanelInfo(AHandle :THandle; var AInfo :TPanelInfo) :Boolean;
  begin
    FillZero(AInfo, SizeOf(AInfo));
   {$ifdef Far3}
    AInfo.StructSize := SizeOf(AInfo);
   {$endif Far3}
    Result := FARAPI.Control(AHandle, FCTL_GetPanelInfo, 0, @AInfo) <> 0;
  end;



  function FarPanelGetSide :Integer;
  var
    vInfo  :TPanelInfo;
  begin
    FarGetPanelInfo(PANEL_ACTIVE, vInfo);
    if PFLAGS_PANELLEFT and vInfo.Flags <> 0 then
      Result := 0  {Left}
    else
      Result := 1; {Right}
  end;


  function FarPanelItem(AHandle :THandle; ACmd, AIndex :Integer) :PPluginPanelItem;
 {$ifdef Far3}
  var
    vSize :Integer;
    vRec :TFarGetPluginPanelItem;
  begin
    Result := nil;
    vSize := FARAPI.Control(AHandle, ACmd, AIndex, nil);
    if vSize > 0 then begin
      Result := MemAlloc( vSize );
      vRec.Size := vSize;
      vRec.Item := Result;
      FARAPI.Control(AHandle, ACmd, AIndex, @vRec);
    end;
 {$else}
  var
    vSize :Integer;
  begin
    Result := nil;
    vSize := FARAPI.Control(AHandle, ACmd, AIndex, nil);
    if vSize > 0 then begin
      Result := MemAlloc( vSize );
      FARAPI.Control(AHandle, ACmd, AIndex, Result);
    end;
 {$endif Far3}
  end;


  function FarPanelItemName(AHandle :THandle; ACmd, AIndex :Integer) :TString;
  var
    vItem :PPluginPanelItem;
  begin
    Result := '';
    vItem := FarPanelItem(AHandle, ACmd, AIndex);
    if vItem <> nil then begin
      try
       {$ifdef Far3}
        Result := vItem.FileName;
       {$else}
        Result := vItem.FindData.cFileName;
       {$endif Far3}
      finally
        MemFree(vItem);
      end;
    end;
  end;


  function FarPanelString(AHandle :THandle; ACmd :Integer) :TFarStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FARAPI.Control(AHandle, ACmd, 0, nil);
    if vLen > 1 then begin
      SetLength(Result, vLen - 1);
      FARAPI.Control(AHandle, ACmd, vLen, PFarChar(Result));
    end;
  end;


  function FarPanelGetCurrentDirectory(AHandle :THandle) :TFarStr;
  begin
    Result := FarPanelString(AHandle, FCTL_GETPANELDIR);
  end;


  function FarGetCurrentDirectory :TFarStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FARSTD.GetCurrentDirectory(0, nil);
    if vLen > 1 then begin
      SetLength(Result, vLen - 1);
      FARSTD.GetCurrentDirectory(vLen, PFarChar(Result));
    end;
  end;


// FCTL_GETCOLUMNTYPES           = 27;
// FCTL_GETCOLUMNWIDTHS          = 28;

 {-----------------------------------------------------------------------------}

(*
   int Info.MacroControl(HANDLE hHandle,int Command,int Param1,INT_PTR Param2)
    hHandle = 0
    Command:
       MCTL_LOADALL
         Param1=0
         Param2=0
         Return=0|1
       MCTL_SAVEALL
         Param1=0
         Param2=0
         Return=0|1
       MCTL_SENDSTRING
         Param1:
           MSSC_POST
             Param2=MacroSendMacroText*
             Return=0|1
           MSSC_EXEC (пока заглужка, не используется)
             Param2=MacroSendMacroText*
             Return=0|1
           MSSC_CHECK
             Param2=MacroCheckMacroText* (Text)
             Return=0|1 в Param2=MacroCheckMacroText* (Check)
       MCTL_GETSTATE
         Param1=0
         Param2=0
         Return=FARMACROSTATE
       MCTL_GETAREA
         Param1=0
         Param2=0
         Return=FARMACROAREA
*)

  procedure FarPostMacro(const AStr :TFarStr; AFlags :DWORD =
   {$ifdef Far3}
    KMFLAGS_DISABLEOUTPUT or KMFLAGS_NOSENDKEYSTOPLUGINS;
   {$else}
    KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;
   {$endif Far3}
    AKey :DWORD = 0);
 {$ifdef Far3}
  var
    vMacro :TMacroSendMacroText;
  begin
   {$ifdef bTrace}
    TraceF('PostMacro: %s', [AStr]);
   {$endif bTrace}
    FillZero(vMacro, SizeOf(vMacro));
    vMacro.StructSize := SizeOf(vMacro);
    vMacro.Flags := AFlags;
    FarKeyToInputRecord(AKey, vMacro.AKey); 
    vMacro.SequenceText := PFarChar(AStr);
    FARAPI.MacroControl(PluginID, MCTL_SENDSTRING, MSSC_POST, @vMacro);
 {$else}
  var
    vMacro :TActlKeyMacro;
  begin
   {$ifdef bTrace}
    TraceF('PostMacro: %s', [AStr]);
   {$endif bTrace}
    vMacro.Command := MCMD_POSTMACROSTRING;
    vMacro.Param.PlainText.SequenceText := PFarChar(AStr);
    vMacro.Param.PlainText.Flags := AFlags;
    vMacro.Param.PlainText.AKey := AKey;
    FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
 {$endif Far3}
  end;


  function FarCheckMacro(const AStr :TFarStr; ASilent :Boolean; ACoord :PCoord = nil) :Boolean;
 {$ifdef Far3}
  var
    vMacro :TMacroCheckMacroText;
  begin
    FillZero(vMacro, SizeOf(vMacro));
    vMacro.Check.Text.StructSize := SizeOf(vMacro);
    vMacro.Check.Text.SequenceText := PTChar(AStr);
    vMacro.Check.Text.Flags := IntIf(ASilent, KMFLAGS_SILENTCHECK, 0);
    FARAPI.MacroControl(PluginID, MCTL_SENDSTRING, MSSC_CHECK, @vMacro);
    Result := vMacro.Check.Result.ErrCode = MPEC_SUCCESS;
    if not Result and (ACoord <> nil) then
      ACoord^ := vMacro.Check.Result.ErrPos;
 {$else}
  var
    vMacro :TActlKeyMacro;
  begin
    vMacro.Command := MCMD_CHECKMACRO;
    vMacro.Param.PlainText.SequenceText := PFarChar(AStr);
    vMacro.Param.PlainText.Flags := IntIf(ASilent, KSFLAGS_SILENTCHECK, 0);
    FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
    Result := vMacro.Param.MacroResult.ErrCode = MPEC_SUCCESS;
    if not Result and (ACoord <> nil) then
      ACoord^ := vMacro.Param.MacroResult.ErrPos;
 {$endif Far3}
  end;


  function FarGetMacroState :Integer;
 {$ifdef Far3}
  begin
    Result := FARAPI.MacroControl(PluginID, MCTL_GETSTATE, 0, nil);
 {$else}
  var
    vMacro :TActlKeyMacro;
  begin
    vMacro.Command := MCMD_GETSTATE;
    Result := FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
 {$endif Far3}
  end;


  function FarGetMacroArea :Integer;
 {$ifdef Far3}
  begin
    Result := FARAPI.MacroControl(PluginID, MCTL_GETAREA, 0, nil);
 {$else}
  var
    vMacro :TActlKeyMacro;
  begin
    vMacro.Command := MCMD_GETAREA;
    Result := FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
 {$endif Far3}
  end;

 {-----------------------------------------------------------------------------}

  function FarPluginControl(ACommand :Integer; AParam1 :Integer; AParam2 :Pointer) :Integer;
  begin
    Result := FARAPI.PluginsControl(INVALID_HANDLE_VALUE, ACommand, AParam1, AParam2);
  end;

 {$ifdef Far3}
  function FarGetPluginInfo(AIndex :Integer; var AInfo :PFarPluginInfo; APreallocate :Integer = 1024) :Boolean;
  var
    vSize :Integer;
  begin
    Result := False;
    if (AInfo = nil) and (APreallocate > 0)  then begin
      vSize := SizeOf(TFarPluginInfo) + APreallocate;
      AInfo := MemAllocZero(vSize);
      AInfo.Size := vSize;
    end;

    vSize := FarPluginControl(PCTL_GETPLUGININFO, AIndex, AInfo);
    if vSize > 0 then begin
      if (AInfo = nil) or (Cardinal(vSize) > AInfo.Size) then begin
        { Зарезервированного места не хватило. Надо увеличить... }
        ReallocMem(AInfo, vSize);
        AInfo.Size := vSize;
        Result := FarPluginControl(PCTL_GETPLUGININFO, AIndex, AInfo) > 0;
      end else
        Result := True;
    end;
  end;
 {$endif Far3}

 {-----------------------------------------------------------------------------}

  procedure FarPanelJumpToPath(Active :Boolean; const APath :TString);
  var
    vStr :TFarStr;
  begin
    if IsFullFilePath(APath) then begin
     {$ifdef bUnicodeFar}
      FARAPI.Control(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_SETPANELDIR, 0, PFarChar(APath));
      FARAPI.Control(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_REDRAWPANEL, 0, nil);
     {$else}
      vStr := StrAnsiToOem(APath);
      FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_SETPANELDIR, FCTL_SETANOTHERPANELDIR), PFarChar(vStr));
      FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_REDRAWPANEL, FCTL_REDRAWANOTHERPANEL), nil);
     {$endif bUnicodeFar}
    end else
    if APath <> '' then begin
     {$ifdef bUnicodeFar}
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(APath));
     {$else}
      vStr := StrAnsiToOem(APath);
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, PFarChar(vStr));
     {$endif bUnicodeFar}

      if Active then
        vStr := 'Enter'
      else
        vStr := 'Tab Enter Tab';
      FarPostMacro(vStr);
    end else
      Beep;
  end;


  function FarPanelGetCurrentItem(Active :Boolean) :TString;
  var
    vInfo :TPanelInfo;
    vIndex :Integer;
   {$ifdef bUnicodeFar}
    vHandle :THandle;
   {$endif bUnicodeFar}
  begin
    Result := '';

    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);
    FARAPI.Control(vHandle, FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_GetPanelInfo, FCTL_GetAnotherPanelInfo), @vInfo);
   {$endif bUnicodeFar}

    if (vInfo.PanelType = PTYPE_FILEPANEL) {and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0))} then begin

      vIndex := vInfo.CurrentItem;
      if (vIndex < 0) or (vIndex >= Integer(vInfo.ItemsNumber) ) then
        Exit;

     {$ifdef bUnicodeFar}
      Result := FarPanelItemName(vHandle, FCTL_GETPANELITEM, vIndex);
     {$else}
      Result := FarChar2Str(vInfo.PanelItems[vIndex].FindData.cFileName);
     {$endif bUnicodeFar}
    end;
  end;


  function FarPanelSetCurrentItem(Active :Boolean; const AItem :TString) :Boolean;
  var
    I :Integer;
    vStr :TString;
    vInfo :TPanelInfo;
    vRedrawInfo :TPanelRedrawInfo;
   {$ifdef bUnicodeFar}
    vHandle :THandle;
   {$endif bUnicodeFar}
  begin
    Result := False;
    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);
    FARAPI.Control(vHandle, FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_GetPanelInfo, FCTL_GetAnotherPanelInfo), @vInfo);
   {$endif bUnicodeFar}

    if (vInfo.PanelType = PTYPE_FILEPANEL) {and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0))} then begin
      vRedrawInfo.TopPanelItem := vInfo.TopPanelItem;
      vRedrawInfo.CurrentItem := vInfo.CurrentItem;

      for I := 0 to vInfo.ItemsNumber - 1 do begin
       {$ifdef bUnicodeFar}
        vStr := FarPanelItemName(vHandle, FCTL_GETPANELITEM, I);
       {$else}
        vStr := FarChar2Str(vInfo.PanelItems[I].FindData.cFileName);
       {$endif bUnicodeFar}

        if StrEqual(vStr, AItem) then begin
//        vRedrawInfo.TopPanelItem := I; {???}
          vRedrawInfo.CurrentItem := I;
          Result := True;
          Break;
        end;
      end;

     {$ifdef bUnicodeFar}
      FARAPI.Control(vHandle, FCTL_REDRAWPANEL, 0, @vRedrawInfo);
     {$else}
      FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_REDRAWPANEL, FCTL_REDRAWANOTHERPANEL), @vRedrawInfo);
     {$endif bUnicodeFar}
    end;
  end;


  procedure FarPanelGetSelectedItems(Active :Boolean; AItems :TStringList);
  var
    I :Integer;
    vStr :TString;
    vInfo :TPanelInfo;
    vHandle :THandle;
    vItem :PPluginPanelItem;
  begin
   {$ifdef bDebug}
    TraceBeg('FarPanelGetSelectedItems...');
   {$endif bDebug}

    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);

    FillChar(vInfo, SizeOf(vInfo), 0);
    FARAPI.Control(vHandle, FCTL_GetPanelInfo, 0, @vInfo);

    if (vInfo.PanelType = PTYPE_FILEPANEL) {and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0))} then begin
      for I := 0 to vInfo.SelectedItemsNumber - 1 do begin
        vItem := FarPanelItem(vHandle, FCTL_GETSELECTEDPANELITEM, I);
        try

          { Требуется проверка флага, потому что даже если не выделено ни одного элемента }
          { SelectedItemsNumber = 1, и возвращает текущий элемент...}
          if PPIF_SELECTED and vItem.Flags <> 0 then begin
           {$ifdef Far3}
            vStr := vItem.FileName;
           {$else}
            vStr := vItem.FindData.cFileName;
           {$endif Far3}
            AItems.Add(vStr)
          end;

        finally
          MemFree(vItem);
        end;
      end;
    end;

   {$ifdef bDebug}
    TraceEnd('   Done');
   {$endif bDebug}
  end;


  procedure FarPanelSetSelectedItems(Active :Boolean; AItems :TStringList; AClearAll :Boolean = True);
  var
    I :Integer;
    vStr :TString;
    vInfo :TPanelInfo;
    vHandle :THandle;
  begin
   {$ifdef bDebug}
    TraceBeg('FarPanelSetSelectedItems...');
   {$endif bDebug}

    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);

    FillChar(vInfo, SizeOf(vInfo), 0);
    FARAPI.Control(vHandle, FCTL_GetPanelInfo, 0, @vInfo);

    if (vInfo.PanelType = PTYPE_FILEPANEL) {and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0))} then begin
      FARAPI.Control(vHandle, FCTL_BEGINSELECTION, 0, nil);
      try
        for I := 0 to vInfo.ItemsNumber - 1 do begin
          vStr := FarPanelItemName(vHandle, FCTL_GETPANELITEM, I);
          if AItems.IndexOf(vStr) <> -1 then
            FARAPI.Control(vHandle, FCTL_SETSELECTION, I, Pointer(PPIF_SELECTED) )
          else
            {};
        end;
      finally
        FARAPI.Control(vHandle, FCTL_ENDSELECTION, 0, nil);
      end;

      FARAPI.Control(vHandle, FCTL_REDRAWPANEL, 0, nil);
    end;

   {$ifdef bDebug}
    TraceEnd('   Done');
   {$endif bDebug}
  end;


 {-----------------------------------------------------------------------------}
 { Editor/Viwer control                                                        }

  procedure FarEditorSetColor(ARow, ACol, ALen :Integer; AColor :TFarColor; AWholeTab :Boolean = False);
  var
    vColor :TEditorColor;
  begin
   {$ifdef Far3}
    vColor.StructSize := SizeOf(vColor);
    vColor.StringNumber := ARow;
    vColor.StartPos := ACol;
    vColor.EndPos := ACol + ALen - 1;
    vColor.ColorItem := 0;
    vColor.Color := AColor;
    vColor.Owner := PluginID;
    vColor.Priority := EDITOR_COLOR_NORMAL_PRIORITY;
    vColor.Flags := IntIf(AWholeTab, 0, ECF_TABMARKFIRST);
   {$else}
    vColor.StringNumber := ARow;
    vColor.StartPos := ACol;
    vColor.EndPos := ACol + ALen - 1;
    vColor.ColorItem := 0;
    vColor.Color := AColor or IntIf(AWholeTab, 0, ECF_TAB1);
   {$endif Far3}
    FarEditorControl(ECTL_ADDCOLOR, @vColor);
  end;


  procedure FarEditorDelColor(ARow, ACol, ALen :Integer);
 {$ifdef Far3}
  var
    vColor :TEditorDeleteColor;
  begin
    vColor.StructSize := SizeOf(vColor);
    vColor.StringNumber := ARow;
    vColor.StartPos := ACol;
    vColor.Owner := PluginID;
    FarEditorControl(ECTL_DELCOLOR, @vColor);
 {$else}
  var
    vColor :TEditorColor;
  begin
    vColor.StringNumber := ARow;
    vColor.ColorItem := 0;
    vColor.StartPos := ACol;
    vColor.EndPos := ACol + ALen - 1;
    vColor.Color := 0;
    FarEditorControl(ECTL_ADDCOLOR, @vColor);
 {$endif Far3}
  end;


  //ECTL_GETFILENAME

  function EditorControlString(ACmd :Integer) :TFarStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FarEditorControl(ACmd, nil);
    if vLen > 1 then begin
      SetLength(Result, vLen - 1);
      FarEditorControl(ACmd, PFarChar(Result));
    end;
  end;



  procedure FarEditOrView(const AFileName :TString; AEdit :Boolean; AFlags :Integer = 0; ARow :Integer = 0; ACol :Integer = 1);
  var
    vName :TFarStr;
  begin
    vName := AFileName;
    if AEdit then
      FARAPI.Editor(PFarChar(vName), nil, 0, 0, -1, -1, AFlags, ARow, ACol, CP_AUTODETECT)
    else
      FARAPI.Viewer(PFarChar(vName), nil, 0, 0, -1, -1, AFlags, CP_AUTODETECT);
  end;



 {-----------------------------------------------------------------------------}


  function FarGetWindowInfo(APos :Integer; var AInfo :TWindowInfo; AName :PTString = nil; ATypeName :PTString = nil) :boolean;
  begin
    Result := False;

    FillZero(AInfo, SizeOf(AInfo));
   {$ifdef Far3}
    AInfo.StructSize := SizeOf(AInfo);
   {$endif Far3}
    AInfo.Pos := APos;

    if FarAdvControl(ACTL_GETWINDOWINFO, @AInfo) <> 0 then begin

      if (AName <> nil) and (AInfo.NameSize > 1) then begin
        SetString(AName^, nil, AInfo.NameSize - 1);
        AInfo.Name := PTChar(AName^);
      end;

      if (ATypeName <> nil) and (AInfo.TypeNameSize > 1) then begin
        SetString(ATypeName^, nil, AInfo.TypeNameSize - 1);
        AInfo.TypeName := PTChar(ATypeName^);
      end;

      if (AInfo.Name <> nil) or (AInfo.TypeName <> nil) then
        FarAdvControl(ACTL_GETWINDOWINFO, @AInfo);

      Result := True;
    end;
  end;


  function FarExpandFileName(const AFileName :TString) :TString;
  var
    vLen :Integer;
  begin
    Result := '';
    if AFileName <> '' then begin
      vLen := FARSTD.ConvertPath(CPM_FULL, PTChar(AFileName), nil, 0);
      if vLen > 0 then begin
        SetLength(Result, vLen - 1);
        FARSTD.ConvertPath(CPM_FULL, PTChar(AFileName), PTChar(Result), vLen);
      end;
    end;
  end;


  function FarGetWindowRect :TSmallRect;
  begin
    FillChar(Result, SizeOf(Result), 0);
    FarAdvControl(ACTL_GETFARRECT, @Result);
  end;


  function FarGetWindowSize :TSize;
  begin
    with FarGetWindowRect do
      Result := Size(Right - Left + 1, Bottom - Top + 1);
  end;


  procedure FarCopyToClipboard(const AStr :TString);
  begin
    FARSTD.CopyToClipboard(PTChar(AStr));
  end;


  function FarXLat(AChr :TChar) :TChar;
  var
    vBuf :array[0..1] of TChar;
  begin
    vBuf[0] := AChr;
    vBuf[1] := #0;
    Result := FARSTD.XLat(@vBuf[0], 0, 1, 0)^;
  end;


  function FarXLatStr(const AStr :TString) :TString;
  begin
    SetString(Result, PTChar(AStr), Length(AStr));
    FARSTD.XLat(PTChar(Result), 0, Length(AStr), 0);
  end;


 {-----------------------------------------------------------------------------}

  function ShiftStateToFarKeyState(AShift :Integer) :Integer;
  begin
    Result := 0;
    if AShift and SHIFT_PRESSED <> 0 then
      Result := Result or KEY_SHIFT;
    if AShift and LEFT_CTRL_PRESSED <> 0 then
      Result := Result or KEY_CTRL;
    if AShift and RIGHT_CTRL_PRESSED <> 0 then
      Result := Result or KEY_RCTRL;
    if AShift and LEFT_ALT_PRESSED <> 0 then
      Result := Result or KEY_ALT;
    if AShift and RIGHT_ALT_PRESSED <> 0 then
      Result := Result or KEY_RALT;
  end;


  function FarKeyStateToShiftState(AKey :Integer) :Integer;
  begin
    Result := 0;
    if AKey and KEY_SHIFT <> 0 then
      Result := Result or SHIFT_PRESSED;
    if AKey and KEY_CTRL <> 0 then
      Result := Result or LEFT_CTRL_PRESSED;
    if AKey and KEY_RCTRL <> 0 then
      Result := Result or RIGHT_CTRL_PRESSED;
    if AKey and KEY_ALT <> 0 then
      Result := Result or LEFT_ALT_PRESSED;
    if AKey and KEY_RALT <> 0 then
      Result := Result or RIGHT_ALT_PRESSED;
  end;


  function KeyEventToFarKey(const AEvent :TKeyEventRecord) :Integer;
  var
    vKey :Integer;
  begin
    vKey := AEvent.wVirtualKeyCode;

    case vKey of
      0   : vKey := Word(AEvent.UnicodeChar);

      $C0 : vKey := $60;              { ` }

      $BA : vKey := $3B;              { ; }
      $BB : vKey := $3D;              { = }
      $BC : vKey := $2C;              { , }
      $BD : vKey := $2D;              { - }
      $BE : vKey := KEY_DOT;          { . }
      $BF : vKey := KEY_SLASH;        { / }

      $DB : vKey := KEY_BRACKET;      { [ }
      $DC : vKey := KEY_BACKSLASH;    { \ }
      $DD : vKey := KEY_BACKBRACKET;  { ] }
      $DE : vKey := $27;              { ' }

      VK_SHIFT, VK_CONTROL, VK_MENU:
        vKey := 0;

      VK_BACK, VK_TAB, VK_RETURN, VK_ESCAPE, VK_SPACE,
      Byte('0')..Byte('9'),
      Byte('A')..Byte('Z'):
        {vKey := vKey};
    else
      Inc(vKey, EXTENDED_KEY_BASE);
    end;

    Result := vKey or ShiftStateToFarKeyState(AEvent.dwControlKeyState);
  end;


  function FarKeyToKeyEvent(AKey :Integer; var AEvent :TKeyEventRecord) :Boolean;
  var
    vShift, vVKey :Integer;
  begin
    FillZero(AEvent, SizeOf(AEvent));
    vShift := FarKeyStateToShiftState(AKey);
    AKey := AKey and not KEY_CTRLMASK;
    if AKey < EXTENDED_KEY_BASE then begin
      vVKey := 0;
      case AKey of
        0:
        if vShift <> 0 then begin
          if vShift and (LEFT_ALT_PRESSED + RIGHT_ALT_PRESSED) <> 0 then
            vVKey := VK_MENU;
          if vShift and (LEFT_CTRL_PRESSED + RIGHT_CTRL_PRESSED) <> 0 then
            vVKey := VK_CONTROL;
          if vShift and SHIFT_PRESSED <> 0 then
            vVKey := VK_SHIFT;
        end;

        $60 : vVKey := $C0;              { ` }

        $3B : vVKey := $BA;              { ; }
        $3D : vVKey := $BB;              { = }
        $2C : vVKey := $BC;              { , }
        $2D : vVKey := $BD;              { - }
        KEY_DOT : vVKey := $BE;          { . }
        KEY_SLASH : vVKey := $BF;        { / }

        KEY_BRACKET : vVKey := $DB;      { [ }
        KEY_BACKSLASH : vVKey := $DC;    { \ }
        KEY_BACKBRACKET : vVKey := $DD;  { ] }
        $27 : vVKey := $DE;              { ' }

        VK_SHIFT, VK_CONTROL, VK_MENU,
        VK_BACK, VK_TAB, VK_RETURN, VK_ESCAPE, VK_SPACE,
        Byte('0')..Byte('9'),
        Byte('A')..Byte('Z'):
          vVKey := AKey;
      end;
      if vVKey <> 0 then begin
        AEvent.wVirtualKeyCode := vVKey;
        if (AKey >= 32) and (AKey < $FFFF) then
          AEvent.UnicodeChar := WChar(AKey);
        AEvent.dwControlKeyState := vShift;
//      AEvent.wRepeatCount := 1;
        AEvent.bKeyDown := True;
      end  
    end else
    if AKey < INTERNAL_KEY_BASE then begin
      AEvent.wVirtualKeyCode := AKey - EXTENDED_KEY_BASE;
      AEvent.dwControlKeyState := vShift or ENHANCED_KEY;
//    AEvent.wRepeatCount := 1;
      AEvent.bKeyDown := True;
    end;
    Result := AEvent.bKeyDown;
  end;


  function MouseEventToFarKey(const AEvent :TMouseEventRecord) :Integer;
  var
    vPress, vDouble :Boolean;
  begin
    Result := MouseEventToFarKeyEx(AEvent, 0, vPress, vDouble);
  end;


  function MouseEventToFarKeyEx(const AEvent :TMouseEventRecord; AOldState :DWORD; var APress, ADouble :Boolean) :Integer;
  var
    vKey :Integer;

    procedure LocCheckButton(AButton :DWORD; AKey :Integer);
    var
      vPress, vOldPress :Boolean;
    begin
      vPress := AEvent.dwButtonState and AButton <> 0;
      vOldPress := AOldState and AButton <> 0;
      if vPress <> vOldPress then begin
        vKey := AKey;
        APress := vPress;
      end;
    end;

  begin
    vKey := 0;
    APress := True;
    ADouble := False;

    if (AEvent.dwEventFlags = 0) or (AEvent.dwEventFlags and DOUBLE_CLICK <> 0) then begin
      LocCheckButton(FROM_LEFT_1ST_BUTTON_PRESSED, KEY_MSLCLICK);
      LocCheckButton(RIGHTMOST_BUTTON_PRESSED,     KEY_MSRCLICK);
      LocCheckButton(FROM_LEFT_2ND_BUTTON_PRESSED, KEY_MSM3CLICK);
      if APress and (AEvent.dwEventFlags and DOUBLE_CLICK <> 0) then
        ADouble := True;
    end else
    if AEvent.dwEventFlags and MOUSE_WHEELED <> 0 then begin
      if Integer(AEvent.dwButtonState) > 0 then
        vKey := KEY_MSWHEEL_UP
      else
      if Integer(AEvent.dwButtonState) < 0 then
        vKey := KEY_MSWHEEL_DOWN;
    end else
    if AEvent.dwEventFlags and MOUSE_HWHEELED <> 0 then begin
      if Integer(AEvent.dwButtonState) > 0 then
        vKey := KEY_MSWHEEL_RIGHT
      else
      if Integer(AEvent.dwButtonState) < 0 then
        vKey := KEY_MSWHEEL_LEFT;
    end;

    Result := vKey or ShiftStateToFarKeyState(AEvent.dwControlKeyState);
  end;


  function FarKeyToMouseEvent(AKey :Integer; var AEvent :TMouseEventRecord) :Boolean;
  var
    vFlag, vState :DWORD;
  begin
    Result := False;
    FillZero(AEvent, SizeOf(AEvent));
    vFlag := 0; 
    case AKey and not KEY_CTRLMASK of
      KEY_MSLCLICK: vState := FROM_LEFT_1ST_BUTTON_PRESSED;
      KEY_MSRCLICK: vState := RIGHTMOST_BUTTON_PRESSED;
      KEY_MSM3CLICK: vState := FROM_LEFT_2ND_BUTTON_PRESSED;
      KEY_MSWHEEL_UP: begin vFlag := MOUSE_WHEELED; vState := $00780000; end;
      KEY_MSWHEEL_DOWN: begin vFlag := MOUSE_WHEELED; vState := $FF880000; end;
      KEY_MSWHEEL_RIGHT: begin vFlag := MOUSE_HWHEELED; vState := $00780000; end;
      KEY_MSWHEEL_LEFT: begin vFlag := MOUSE_HWHEELED; vState := $FF880000; end;
    else
      Exit;
    end;
    AEvent.dwEventFlags := vFlag;
    AEvent.dwButtonState := vState;
    AEvent.dwControlKeyState := FarKeyStateToShiftState(AKey);
    Result := True;
  end;


  function FarKeyToInputRecord(AKey :Integer; var ARec :INPUT_RECORD) :Boolean;
  begin
    Result := False;
    FillZero(ARec, SizeOf(ARec));
    if FarKeyToKeyEvent(AKey, ARec.Event.KeyEvent) then
      ARec.EventType := KEY_EVENT
    else
    if FarKeyToMouseEvent(AKey, ARec.Event.MouseEvent) then
      ARec.EventType := _MOUSE_EVENT
    else
      Exit;
    Result := True;
  end;



 {-----------------------------------------------------------------------------}

 {$ifdef Far3}

(*
  function EnumFilesProc(const Item :TPluginPanelItem; FullName :PFarChar; Param: pointer) :integer; stdcall;
  var
    vStr :TString;
    vTmp :TMethod;
  begin
    vStr := FullName;
    vTmp := TMethod(Param^);

   {$ifdef bOldLocalCall}
    asm push vTmp.Data; end;
    Result := TEnumFilesProc(vTmp.Code)(vStr, FindData^);
    asm pop ECX; end;
   {$else}
    Result := TEnumFilesProc(vTmp)(vStr, FindData^);
   {$endif bOldLocalCall}
  end;

  procedure EnumFilesEx(const ADir, AMask :TFarStr; const aProc :TMethod);
  begin
    FARSTD.FarRecursiveSearch(PFarChar(ADir), PFarChar(AMask), EnumFilesProc, FRS_RECUR, @aProc);
  end;
*)

 {$else}

  type
    TEnumFilesProc = function(const AFileName :TString; const ARec :TFarFindData) :Integer
      {$ifndef bOldLocalCall}of object{$endif bOldLocalCall};


  function EnumFilesProc(const FindData :PFarFindData; const FullName :PFarChar; Param :Pointer) :Integer; stdcall;
  var
    vStr :TString;
    vTmp :TMethod;
  begin
    vStr := FullName;
    vTmp := TMethod(Param^);
   {$ifdef bOldLocalCall}
    asm push vTmp.Data; end;
    Result := TEnumFilesProc(vTmp.Code)(vStr, FindData^);
    asm pop ECX; end;
   {$else}
    Result := TEnumFilesProc(vTmp)(vStr, FindData^);
   {$endif bOldLocalCall}
  end;

  procedure EnumFilesEx(const ADir, AMask :TFarStr; const aProc :TMethod);
  begin
    FARSTD.FarRecursiveSearch(PFarChar(ADir), PFarChar(AMask), EnumFilesProc, FRS_RECUR, @aProc);
  end;

 {$endif Far3}


  function CheckForEsc :Boolean;
  var
    vCount :Integer;
    vRec :Windows.TInputRecord;
  begin
    Result := False;
    if hStdIn = 0 then
      hStdIn := GetStdHandle(STD_INPUT_HANDLE);
    while True do begin
      if not PeekConsoleInput(hStdIn, vRec, 1, DWORD(vCount)) or (vCount = 0) then
        Break;
      ReadConsoleInput(hStdIn, vRec, 1, DWORD(vCount));
      if (vRec.EventType = KEY_EVENT) and (vRec.Event.KeyEvent.wVirtualKeyCode = VK_ESCAPE) and vRec.Event.KeyEvent.bKeyDown then
        Result := True;
    end;
  end;


end.



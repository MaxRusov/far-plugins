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

    Far_API,
    FarConMan;

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
    MOUSE_WHEELED = 4;
    MOUSE_HWHEELED = 8;

  const
    MIF_CHECKED1 = MIF_CHECKED { or Byte(chrCheck)};

    DI_DefButton = DI_USERCONTROL - 1;

   {$ifdef Far3}
   {$else}
    CP_DEFAULT   = CP_AUTODETECT;
   {$endif Far3}

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

  function NewItem(AType :Integer; DX, DY, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
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
  function ShowMessage(const ATitle, AMessage :TString; AFlags :Integer = FMSG_MB_OK; AButtons :Integer = 0) :Integer; 
  function ShowMessageBut(const ATitle, AMessage :TString; const AButtons :array of TString; AFlags :Integer = 0) :Integer;
  function FarInputBox(ATitle, APrompt :PTChar; var AStr :TString; AFlags :DWORD = FIB_BUTTONS or FIB_ENABLEEMPTY;
    AHistory :PTChar = nil; AHelp :PTChar = nil; AMaxLen :Integer = 1024) :Boolean;

  function FarSendDlgMessage(ADlg :THandle; AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr; overload;
  function FarSendDlgMessage(ADlg :THandle; AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr; overload;
  function FarAdvControl(ACommand :Integer; AParam :Pointer) :Integer; overload;
  function FarAdvControl(ACommand :Integer; AParam :TIntPtr) :Integer; overload;
  function FarEditorControl(ACommand :Integer; AParam :Pointer) :Integer;
  function FarViewerControl(ACommand :Integer; AParam :Pointer) :Integer;
  function FarRegexpControl(AHandle :THandle; ACommand :Integer; AParam :Pointer) :Integer;

  function IsUndefColor(const AColor :TFarColor) :Boolean;
  function MakeColor(AFGColor, ABGColor :DWORD) :TFarColor;
  function EqualColor(AColor1, AColor2 :TFarColor) :Boolean;
  function GetColorFG(const AColor :TFarColor) :DWORD;
  function GetColorBG(const AColor :TFarColor) :DWORD;
  function ChangeFG(const AColor, AFGColor :TFarColor) :TFarColor;
  function ChangeBG(const AColor, ABGColor :TFarColor) :TFarColor;
  function ColorIf(ACond :Boolean; const AColor1, AColor2 :TFarColor) :TFarColor;
  function FarGetColor(ASysColor :TPaletteColors) :TFarColor;
  function GetOptColor(const AColor :TFarColor; ASysColor :TPaletteColors) :TFarColor;

  function FarPanelItem(AHandle :THandle; ACmd, AIndex :Integer) :PPluginPanelItem;
  function FarPanelItemName(AHandle :THandle; ACmd, AIndex :Integer) :TString;
    { ACmd = FCTL_GETPANELITEM, FCTL_GETSELECTEDPANELITEM, FCTL_GETCURRENTPANELITEM }
  function FarPanelString(AHandle :THandle; ACmd :Integer) :TFarStr;
    { ACmd = FCTL_GETPANELDIR, FCTL_GETPANELFORMAT, FCTL_GETPANELHOSTFILE, FCTL_GETCMDLINE, FCTL_GETCOLUMNTYPES}
  function FarPanelGetCurrentDirectory(AHandle :THandle = PANEL_ACTIVE) :TFarStr;
  function FarGetCurrentDirectory :TFarStr;

  function IsVisiblePanel(const AInfo :TPanelInfo) :Boolean;
  function IsPluginPanel(const AInfo :TPanelInfo) :Boolean;
  function FarGetPanelInfo(Active :Boolean; var AInfo :TPanelInfo) :Boolean; overload;
  function FarGetPanelInfo(AHandle :THandle; var AInfo :TPanelInfo) :Boolean; overload;
  function FarPanelGetSide :Integer;

  function FarKeyToMacro(const AKeys :TString) :TString;
  function FarStrToMacro(const AStr :TString) :TString;
  procedure FarPostMacro(const AStr :TFarStr; AFlags :DWORD =
    {$ifdef Far3}
     KMFLAGS_NOSENDKEYSTOPLUGINS;
    {$else}
     KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;
    {$endif Far3}
     AKey :DWORD = 0);
 {$ifdef Far3}
  function FarExecMacroEx(const AStr :TFarStr; const Args :array of const; var ACount :Integer; var ARes :PFarMacroValueArray;
    AFlags :DWORD = KMFLAGS_NOSENDKEYSTOPLUGINS or KMFLAGS_LUA) :boolean;
  function FarExecMacro(const AStr :TFarStr; const Args :array of const;
    AFlags :DWORD = KMFLAGS_NOSENDKEYSTOPLUGINS or KMFLAGS_LUA) :boolean; 
 {$endif Far3}
  function FarCheckMacro(const AStr :TFarStr; ASilent :Boolean; ACoord :PCoord = nil; AMess :PTString = nil) :Boolean;
  function FarGetMacroArea :Integer;
  function FarGetMacroState :Integer;
 {$ifdef Far3}
  function FarValueToStr(const Value :TFarMacroValue) :TString;
  function FarValueIsInteger(const AValue :TFarMacroValue; var AInt :Integer) :Boolean;
  function FarValuesToInt(AValues :PFarMacroValueArray; ACount, AIndex :Integer; ADef :Integer = 0) :Integer;
  function FarValuesToFloat(AValues :PFarMacroValueArray; ACount, AIndex :Integer; const ADef :TFloat = 0) :TFloat;
  function FarValuesToStr(AValues :PFarMacroValueArray; ACount, AIndex :Integer; const ADef :TString = '') :TString;
  function FarReturnValues(const Args :array of const) :TIntPtr;
 {$endif Far3}

  function FarPluginControl(ACommand :Integer; AParam1 :Integer; AParam2 :Pointer) :INT_PTR;
 {$ifdef Far3}
  function FarGetPluginInfo(AHandle :THandle; var AInfo :PFarGetPluginInformation; ASize :PInteger = nil) :Boolean;
 {$endif Far3}

  procedure FarPanelSetDir(AHandle :THandle; const APath :TString); overload;
  procedure FarPanelSetDir(Active :Boolean; const APath :TString); overload;
  procedure FarPanelJumpToPath(Active :Boolean; const APath :TString);
  function FarPanelGetCurrentItem(Active :Boolean) :TString;
  function FarPanelFindItemByName(Active :Boolean; const AName :TString) :Integer;
  procedure FarPanelSetCurrentItem(Active :Boolean; AIndex :Integer); overload;
  function FarPanelSetCurrentItem(Active :Boolean; const AItem :TString) :Boolean; overload;
  procedure FarPanelGetSelectedItems(Active :Boolean; AItems :TStringList);
  procedure FarPanelSetSelectedItems(Active :Boolean; AItems :TStringList; AClearAll :Boolean = True);

  procedure FarEditorSetColor(ARow, ACol, ALen :Integer; AColor :TFarColor; AWholeTab :Boolean = False);
  procedure FarEditorDelColor(ARow, ACol, ALen :Integer);
  function EditorControlString(ACmd :Integer) :TFarStr;
 {$ifdef Far3}
  function ViewerControlString(ACmd :Integer) :TFarStr;
 {$endif Far3}
  procedure FarEditOrView(const AFileName :TString; AEdit :Boolean; AFlags :Integer = 0; ARow :Integer = -1; ACol :Integer = -1);
 {$ifdef Far3}
  procedure FarEditorSubscribeChangeEvent(AEditorID :TIntPtr; ASubscribe :Boolean);
 {$endif Far3}

  function FarGetWindowType :Integer;
  function FarGetWindowInfo(APos :Integer; var AInfo :TWindowInfo; AName :PTString = nil; ATypeName :PTString = nil) :boolean;
  function FarExpandFileName(const AFileName :TString) :TString;
  function FarGetWindowRect :TSmallRect;
  function FarGetWindowSize :TSize;

  procedure FarCopyToClipboard(const AStr :TString);
  function FarPasteFromClipboard :TString;

  function FarXLat(AChr :TChar) :TChar;
  function FarXLatStr(const AStr :TString) :TString;
  function FarMaskStr(const AStr :TString) :TString;

  { Для совместимости к KEY_ кодами FAR2 }
  function KeyEventToFarKey(const AEvent :TKeyEventRecord) :Integer;
  function KeyEventToFarKeyDlg(const AEvent :TKeyEventRecord) :Integer;
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

  procedure UpdateConsoleWnd;
  function GetConsoleWnd :THandle;
  function GetConsoleMousePos(AWnd :THandle = 0) :TPoint;
    { Вычисляем позицию мыши в консольных координатах }

  procedure FarAddToHistory(const AHist, AStr :TString);

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


  function ShowMessage(const ATitle, AMessage :TString; AFlags :Integer = FMSG_MB_OK; AButtons :Integer = 0) :Integer;
  var
    vStr :TFarStr;
   {$ifdef Far3}
    vDlgID :TGUID;
   {$endif Far3}
  begin
    vStr := ATitle + #10 + AMessage;
   {$ifdef Far3}
    vDlgID := GUID_NULL;
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


  function ShowMessageBut(const ATitle, AMessage :TString; const AButtons :array of TString; AFlags :Integer = 0) :Integer;
  var
    I :Integer;
    vMess :TString;
  begin
    vMess := AMessage;
    for I := 0 to High(AButtons) do
      vMess := vMess + #10 + AButtons[I];
    Result := ShowMessage(ATitle, vMess, AFlags, High(AButtons) + 1);
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

  var
    LastX, LastY :Integer;


  function NewItem(AType :Integer; DX, DY, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
  begin
    FillChar(Result, SizeOf(Result), 0);
    with Result do begin
      ItemType := IntIf(AType = DI_DefButton, DI_Button, AType);
      if DY < 0 then
        Y1 := -DY
      else
        Y1 := LastY + DY;

      if DX < 0 then
        X1 := -DX
      else
        X1 := LastX + DX;

      if W > 0 then begin
        X2 := X1 + W - 1;
        LastX := X2 + 1;
      end else
      begin
        LastX := X1;
        if AText <> nil then
          Inc(LastX, strlen(AText) - IntIf(StrScan(AText, '&') = nil, 0, 1));
        if AType in [DI_CheckBox, DI_RADIOBUTTON] then
          Inc(LastX, 4);
      end;

      if H > 0 then begin
        Y2 := Y1 + H - 1;
        LastY := Y2;
      end else
        LastY := Y1;

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


  function NewItemApi(AType :Integer; X, Y, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
  begin
    LastX := 0; LastY := 0;
    Result := NewItem(AType, X, Y, W, H, AFlags, AText, AHist);
  end;

(*
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
*)

  function CreateDialog(const AItems :array of TFarDialogItem; AItemCount :PInteger = nil) :PFarDialogItemArray;
  var
    I, vCount :Integer;
    vItem :PFarDialogItem;
  begin
    LastX := 0; LastY := 0;
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

(*
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
*)

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


  function FarAdvControl(ACommand :Integer; AParam :TIntPtr) :Integer;
  begin
    Result := FarAdvControl(ACommand, Pointer(AParam));
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


 {-----------------------------------------------------------------------------}


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


  function ColorIf(ACond :Boolean; const AColor1, AColor2 :TFarColor) :TFarColor;
  begin
    if ACond then
      Result := AColor1
    else
      Result := AColor2;
  end;


  function FarGetColor(ASysColor :TPaletteColors) :TFarColor;
  begin
   {$ifdef Far3}
    FARAPI.AdvControl(PluginID, ACTL_GETCOLOR, Integer(ASysColor), @Result);
   {$else}
    Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(TIntPtr(ASysColor)));
   {$endif Far3}
  end;


  function GetOptColor(const AColor :TFarColor; ASysColor :TPaletteColors) :TFarColor;
  begin
    Result := AColor;
    if IsUndefColor(AColor) then
      Result := FarGetColor(ASysColor);
  end;


 {-----------------------------------------------------------------------------}

  function IsVisiblePanel(const AInfo :TPanelInfo) :Boolean;
  begin
    Result := {$ifdef Far3}PFLAGS_VISIBLE and AInfo.Flags <> 0{$else}AInfo.Visible <> 0{$endif};
  end;

  function IsPluginPanel(const AInfo :TPanelInfo) :Boolean;
  begin
    Result := {$ifdef Far3}PFLAGS_PLUGIN and AInfo.Flags <> 0{$else}AInfo.Plugin <> 0{$endif};
  end;


  function FarGetPanelInfo(Active :Boolean; var AInfo :TPanelInfo) :Boolean;
  begin
    Result := FarGetPanelInfo(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), AInfo);
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
      vRec.StructSize := SizeOf(vRec);
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
      Result := MemAllocZero( vSize );
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


  function FarPanelGetCurrentDirectory(AHandle :THandle = PANEL_ACTIVE) :TFarStr;
 {$ifdef Far3}
  var
    vSize :Integer;
    vInfo :PFarPanelDirectory;
  begin
    Result := '';
    vSize := FARAPI.Control(AHandle, FCTL_GETPANELDIRECTORY, 0, nil);
    if vSize > 0 then begin
      vInfo := MemAllocZero(vSize);
      try
        vInfo.StructSize := SizeOf(TFarPanelDirectory);
        FARAPI.Control(AHandle, FCTL_GETPANELDIRECTORY, vSize, vInfo);
        Result := vInfo.Name;
      finally
        FreeMem(vInfo);
      end;
    end;
 {$else}
  begin
    Result := FarPanelString(AHandle, FCTL_GETPANELDIR);
 {$endif Far3}
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
           MSSC_EXEC (пока заглушка, не используется)
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


  function FarKeyToMacro(const AKeys :TString) :TString;
  begin
   {$ifdef Far3}
    Result := 'Keys("' + AKeys + '")';
   {$else}
    Result := AKeys;
   {$endif Far3}
  end;


  function FarStrToMacro(const AStr :TString) :TString;
  begin
   {$ifdef Far3}
    Result := '"' + FarMaskStr(AStr) + '"';
   {$else}
    Result := '@"' + AStr + '"';
   {$endif Far3}
  end;


  procedure FarPostMacro;
 {$ifdef Far3}
  var
    vMacro :TMacroSendMacroText;
    vRes :TIntPtr;
  begin
   {$ifdef bTrace}
    TraceF('PostMacro: %s', [AStr]);
   {$endif bTrace}
    FillZero(vMacro, SizeOf(vMacro));
    vMacro.StructSize := SizeOf(vMacro);
    vMacro.Flags := AFlags;
    FarKeyToInputRecord(AKey, vMacro.AKey);
    vMacro.SequenceText := PFarChar(AStr);
    vRes := FARAPI.MacroControl(PluginID, MCTL_SENDSTRING, MSSC_POST, @vMacro);
    if vRes = 0 then
      NOP{Error};
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


  function FarCheckMacro(const AStr :TFarStr; ASilent :Boolean; ACoord :PCoord = nil; AMess :PTString = nil) :Boolean;
 {$ifdef Far3}
(*
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
*)
(*
1. Мелкое изменение в API:
   MacroCheckMacroText больше нет, MSSC_CHECK ожидает MacroSendMacroText.
   И новая команда, MCTL_GETLASTERROR ->  Param1=размер, Param2=MacroParseResult*.
   Возвращает требуемый размер.
*)
  var
    vMacro :TMacroSendMacroText;
    vParseRes :PMacroParseResult;
    vSize :Integer;
  begin
    FillZero(vMacro, SizeOf(vMacro));
    vMacro.StructSize := SizeOf(TMacroSendMacroText);
    vMacro.SequenceText := PTChar(AStr);
    vMacro.Flags := IntIf(ASilent, KMFLAGS_SILENTCHECK, 0);
    Result := FARAPI.MacroControl(PluginID, MCTL_SENDSTRING, MSSC_CHECK, @vMacro) <> 0;
    if not Result then begin
      vSize := FARAPI.MacroControl(PluginID, MCTL_GETLASTERROR, 0, nil);
      if vSize > 0 then begin
        vParseRes := MemAllocZero(vSize);
        try
          vParseRes.StructSize := SizeOf(TMacroParseResult);
          FARAPI.MacroControl(PluginID, MCTL_GETLASTERROR, vSize, vParseRes);
          if ACoord <> nil then
            ACoord^ := vParseRes.ErrPos;
          if AMess <> nil then
            AMess^ := vParseRes.ErrSrc;
        finally
          MemFree(vParseRes);
        end;
      end;
    end;
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


 {$ifdef Far3}
  function FarValueToStr(const Value :TFarMacroValue) :TString;
  begin
    Result := '';
    case Value.fType of
      FMVT_INTEGER : Result := Int2Str(Value.Value.fInteger);
      FMVT_STRING  : Result := Value.Value.fString;
      FMVT_DOUBLE  : Result := Float2Str(Value.Value.fDouble);
      FMVT_BOOLEAN : Result := Int2Str(Value.Value.fInteger);
      FMVT_BINARY  : Result := '(' + Int2Str(Value.Value.fBinary.Size) + ')';
    end;
  end;


  function FarValueIsInteger(const AValue :TFarMacroValue; var AInt :Integer) :Boolean;
  begin
    Result := True;
    if AValue.fType in [FMVT_INTEGER, FMVT_BOOLEAN] then
      AInt := AValue.Value.fInteger
    else
    if (AValue.fType = FMVT_DOUBLE) and (Frac(AValue.Value.fDouble) = 0) then
      AInt := Trunc(AValue.Value.fDouble)
    else
      Result := False;
  end;


  function FarValuesToInt(AValues :PFarMacroValueArray; ACount, AIndex :Integer; ADef :Integer = 0) :Integer;
  begin
    if (AIndex < ACount) and FarValueIsInteger(AValues[AIndex], Result) then
      {Ok}
    else
      Result := ADef;
  end;


  function FarValuesToFloat(AValues :PFarMacroValueArray; ACount, AIndex :Integer; const ADef :TFloat = 0) :TFloat;
  begin
    if (AIndex < ACount) and (AValues[AIndex].fType = FMVT_DOUBLE) then
      Result := AValues[AIndex].Value.fDouble
    else
      Result := ADef;
  end;


  function FarValuesToStr(AValues :PFarMacroValueArray; ACount, AIndex :Integer; const ADef :TString = '') :TString;
  begin
    if (AIndex < ACount) and (AValues[AIndex].fType = FMVT_STRING) then
      Result := AValues[AIndex].Value.fString
    else
      Result := ADef;
  end;


  function InitFarValues(const Args :array of const) :PFarMacroValueArray;
  var
    I, vCount :Integer;
  begin
    vCount := High(Args) + 1;
    Result := MemAllocZero(SizeOf(TFarMacroValue) * vCount);
    for I := 0 to vCount - 1 do
      with Result[I] do begin
        case Args[I].VType of
          vtBoolean: begin
            fType := FMVT_BOOLEAN; //FMVT_INTEGER;
            Value.fInteger := IntIf(Args[I].VBoolean, 1, 0);
          end;
          vtInteger: begin
            fType := FMVT_INTEGER;
            Value.fInteger := Args[I].VInteger;
          end;
          vtInt64: begin
            fType := FMVT_INTEGER;
            Value.fInteger := Args[I].VInt64^;
          end;
          vtExtended: begin
            fType := FMVT_DOUBLE;
            Value.fDouble := Args[I].VExtended^;
          end;
          vtAnsiString: begin
            fType := FMVT_STRING;
            Value.fString := StrNew(AnsiString(Args[I].VAnsiString));
          end;
          vtWideString: begin
            fType := FMVT_STRING;
            Value.fString := StrNew(WideString(Args[I].VWideString));
          end;
        end;
      end;
  end;


  procedure DoneFarValues(aValues :PFarMacroValueArray; aCount :Integer);
  var
    I :Integer;
  begin
    for I := 0 to aCount - 1 do
      if aValues[I].fType = FMVT_STRING then
        StrDisposeW(aValues[I].Value.fString);
    MemFree(aValues);
  end;


  procedure FarReturnValuesCallback(CallbackData :Pointer; Values :PFarMacroValueArray; Count :size_t); stdcall;
  begin
//  TraceF('FarReturnValuesCallback: %s, %d', [FarValueToStr(Values[0]), Count]);
    DoneFarValues(Values, Count);
    MemFree(CallbackData);
  end;


  function FarReturnValues(const Args :array of const) :TIntPtr;
  var
    vRes :PFarMacroCall;
  begin
    vRes := MemAllocZero(SizeOf(TFarMacroCall));
    vRes.StructSize := SizeOf(TFarMacroCall);
    vRes.Count := High(Args) + 1;
    if vRes.Count > 0 then
      vRes.Values := InitFarValues(Args);
    vRes.Callback := FarReturnValuesCallback;
    vRes.CallbackData := vRes;
    Result := TIntPtr(vRes);
  end;

  
  function FarExecMacroEx(const AStr :TFarStr; const Args :array of const; var ACount :Integer; var ARes :PFarMacroValueArray;
    AFlags :DWORD = KMFLAGS_NOSENDKEYSTOPLUGINS or KMFLAGS_LUA) :boolean;
  var
    vMacro :TMacroExecuteString;
  begin
   {$ifdef bTrace}
    TraceF('ExecMacro: %s', [AStr]);
   {$endif bTrace}

    FillZero(vMacro, SizeOf(vMacro));
    vMacro.StructSize := SizeOf(vMacro);
    vMacro.SequenceText := PFarChar(AStr);
    vMacro.Flags := AFlags;

    vMacro.InCount := High(Args) + 1;
    if vMacro.InCount > 0 then
      vMacro.InValues := InitFarValues(Args);
    try
      Result := FARAPI.MacroControl(PluginID, MCTL_EXECSTRING, 0, @vMacro) <> 0;

      ACount := vMacro.OutCount;
      ARes := vMacro.OutValues;

    finally
      if vMacro.InCount > 0 then
        DoneFarValues(vMacro.InValues, vMacro.InCount);
    end;
  end;


  function FarExecMacro(const AStr :TFarStr; const Args :array of const;
    AFlags :DWORD = KMFLAGS_NOSENDKEYSTOPLUGINS or KMFLAGS_LUA) :boolean;
  var
    vCount :Integer;
    vRes :PFarMacroValueArray;
  begin
    Result := FarExecMacroEx(AStr, Args, vCount, vRes, AFlags);
  end;
 {$endif Far3}


 {-----------------------------------------------------------------------------}

  function FarPluginControl(ACommand :Integer; AParam1 :Integer; AParam2 :Pointer) :INT_PTR;
  begin
    Result := FARAPI.PluginsControl(INVALID_HANDLE_VALUE, ACommand, AParam1, AParam2);
  end;

 {$ifdef Far3}
  function FarGetPluginInfo(AHandle :THandle; var AInfo :PFarGetPluginInformation; ASize :PInteger = nil) :Boolean;
  const
    cPreallocate = 1024;
  var
    vSize0, vSize :Integer;
  begin
    Result := False;
    vSize0 := 0;
    if ASize <> nil then
      vSize0 := ASize^;

    if (AInfo = nil) or (vSize0 = 0) then begin
      vSize0 := SizeOf(TFarGetPluginInformation) + cPreallocate;
      AInfo := MemAllocZero(vSize0);
      AInfo.StructSize := SizeOf(TFarGetPluginInformation);
    end;

    vSize := FARAPI.PluginsControl(AHandle, PCTL_GETPLUGININFORMATION, vSize0, AInfo);
    if vSize > 0 then begin
      if vSize > vSize0 then begin
        { Зарезервированного места не хватило. Надо увеличить... }
        ReallocMem(AInfo, vSize);
        vSize0 := vSize;
        Result := FARAPI.PluginsControl(AHandle, PCTL_GETPLUGININFORMATION, vSize0, AInfo) > 0;
      end else
        Result := True;
    end;
    
    if ASize <> nil then
      ASize^ := vSize0;
  end;
 {$endif Far3}


 {-----------------------------------------------------------------------------}

  procedure FarPanelSetDir(AHandle :THandle; const APath :TString); {overload;}
 {$ifdef Far3}
  var
    vInfo :TFarPanelDirectory;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.StructSize := SizeOf(vInfo);
    vInfo.Name := PFarChar(APath);
    FARAPI.Control(AHandle, FCTL_SETPANELDIRECTORY, 0, @vInfo);
 {$else}
  begin
    FARAPI.Control(AHandle, FCTL_SETPANELDIR, 0, PFarChar(APath));
 {$endif Far3}
  end;


  procedure FarPanelSetDir(Active :Boolean; const APath :TString); {overload;}
  begin
    FarPanelSetDir(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), APath);
  end;


  procedure FarPanelJumpToPath(Active :Boolean; const APath :TString);
  var
    vHandle :THandle;
    vStr :TFarStr;
  begin
    if IsFullFilePath(APath) then begin
      vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);
      FarPanelSetDir(vHandle, APath);
      FARAPI.Control(vHandle, FCTL_REDRAWPANEL, 0, nil);
    end else
    if APath <> '' then begin
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(APath));
      if Active then
        vStr := 'Enter'
      else
        vStr := 'Tab Enter Tab';
      FarPostMacro(FarKeyToMacro(vStr));
    end else
      Beep;
  end;


  function FarPanelGetCurrentItem(Active :Boolean) :TString;
  var
    vInfo :TPanelInfo;
    vIndex :Integer;
    vHandle :THandle;
  begin
    Result := '';

    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);
    if not FarGetPanelInfo(vHandle, vInfo) then
      Exit;

    if (vInfo.PanelType = PTYPE_FILEPANEL) {and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0))} then begin

      vIndex := vInfo.CurrentItem;
      if (vIndex < 0) or (vIndex >= Integer(vInfo.ItemsNumber) ) then
        Exit;

      Result := FarPanelItemName(vHandle, FCTL_GETPANELITEM, vIndex);
    end;
  end;


  function FarPanelFindItemByName(Active :Boolean; const AName :TString) :Integer;
  var
    I :Integer;
    vStr :TString;
    vInfo :TPanelInfo;
    vHandle :THandle;
  begin
    Result := -1;
    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);
    if FarGetPanelInfo(vHandle, vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) {and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0))} then begin
      for I := 0 to vInfo.ItemsNumber - 1 do begin
        vStr := FarPanelItemName(vHandle, FCTL_GETPANELITEM, I);
        if StrEqual(vStr, AName) then begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;


  procedure FarPanelSetCurrentItem(Active :Boolean; AIndex :Integer);
  var
    vInfo :TPanelInfo;
    vRedrawInfo :TPanelRedrawInfo;
  begin
    if FarGetPanelInfo(Active, vInfo) and (vInfo.PanelType = PTYPE_FILEPANEL) then begin
     {$ifdef Far3}
      vRedrawInfo.StructSize := SizeOf(vRedrawInfo);
     {$endif Far3}
      vRedrawInfo.CurrentItem := AIndex;
      vRedrawInfo.TopPanelItem := vInfo.TopPanelItem;
      FARAPI.Control(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_REDRAWPANEL, 0, @vRedrawInfo);
    end;
  end;


  function FarPanelSetCurrentItem(Active :Boolean; const AItem :TString) :Boolean;
  var
    vIdx :Integer;
  begin
    Result := False;
    vIdx := FarPanelFindItemByName(Active, AItem);
    if vIdx <> -1 then begin
      FarPanelSetCurrentItem(Active, vIdx);
      Result := True;
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
    if not FarGetPanelInfo(vHandle, vInfo) then
      Exit;

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
    if not FarGetPanelInfo(vHandle, vInfo) then
      Exit;

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
    FillZero(vColor, SizeOf(vColor));
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
     {$ifdef Far3}
      FARAPI.EditorControl(-1, ACmd, vLen, PFarChar(Result));
     {$else}
      FarEditorControl(ACmd, PFarChar(Result));
     {$endif Far3}
    end;
  end;

 {$ifdef Far3}
  //VCTL_GETFILENAME
  function ViewerControlString(ACmd :Integer) :TFarStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FarViewerControl(ACmd, nil);
    if vLen > 1 then begin
      SetLength(Result, vLen - 1);
      FARAPI.ViewerControl(-1, ACmd, vLen, PFarChar(Result));
    end;
  end;
 {$endif Far3}


  procedure FarEditOrView(const AFileName :TString; AEdit :Boolean; AFlags :Integer = 0; ARow :Integer = -1; ACol :Integer = -1);
  var
    vName :TFarStr;
  begin
    vName := AFileName;
    if AEdit then
      FARAPI.Editor(PFarChar(vName), nil, 0, 0, -1, -1, AFlags, ARow, ACol, CP_DEFAULT)
    else
      FARAPI.Viewer(PFarChar(vName), nil, 0, 0, -1, -1, AFlags, CP_DEFAULT);
  end;

 {$ifdef Far3}
  procedure FarEditorSubscribeChangeEvent(AEditorID :TIntPtr; ASubscribe :Boolean);
  var
    vRec :TEditorSubscribeChangeEvent;
  begin
    vRec.StructSize := SizeOf(vRec);
    vRec.PluginId := PluginID;
//  FarEditorControl(IntIf(ASubscribe, ECTL_SUBSCRIBECHANGEEVENT, ECTL_UNSUBSCRIBECHANGEEVENT), @vRec);
    FARAPI.EditorControl(AEditorID, IntIf(ASubscribe, ECTL_SUBSCRIBECHANGEEVENT, ECTL_UNSUBSCRIBECHANGEEVENT), 0, @vRec);
  end;
 {$endif Far3}


 {-----------------------------------------------------------------------------}

  function FarGetWindowType :Integer;
 {$ifdef Far3}
  var
    vInfo :TWindowType;
  begin
    Result := -1;
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.StructSize := SizeOf(vInfo);
    if FarAdvControl(ACTL_GETWINDOWTYPE, @vInfo) <> 0 then
      Result := vInfo.fType;
 {$else}
  var
    vInfo :TWindowInfo;
  begin
    Result := -1;
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.Pos := -1;
    if FarAdvControl(ACTL_GETSHORTWINDOWINFO, @vInfo) <> 0 then
      Result := vInfo.WindowType;
 {$endif Far3}
  end;


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
   {$ifdef Far3}
    FARSTD.CopyToClipboard(FCT_STREAM, PTChar(AStr));
   {$else}
    FARSTD.CopyToClipboard(PTChar(AStr));
   {$endif Far3}
  end;

  function FarPasteFromClipboard :TString;
 {$ifdef Far3}
  var
    vSize :Integer;
  begin
    Result := '';
    vSize := FARSTD.PasteFromClipboard(FCT_ANY, nil, 0);
    if vSize > 1 then begin
      SetLength(Result, vSize - 1);
      FARSTD.PasteFromClipboard(FCT_ANY, PTChar(Result), vSize);
    end;
 {$else}
  begin
    Result := FARSTD.PasteFromClipboard;
 {$endif Far3}
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


  function FarMaskStr(const AStr :TString) :TString;
    {...Оптимизировать}
  var
    I :Integer;
    C :TChar;
  begin
    Result := '';
    for I := 1 to length(AStr) do begin
      C := AStr[I];
      if (Ord(C) < $20) or (C = '"') or (C = '\') then
       {$ifdef Far3}
        Result := Result + '\' + C
       {$else}
//      Result := Result + '\' + Int2Str(Ord(c))
        Result := Result + '\x' + Format('%.2x', [Ord(c)])
       {$endif Far3}
      else
        Result := Result + C;
    end;
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

      $0C : vKey := KEY_Clear;

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


(*
  function KeyEventToFarKey1(const AEvent :TKeyEventRecord) :Integer;
  begin
    if (word(AEvent.UnicodeChar) >= 32) and ((LEFT_CTRL_PRESSED + RIGHT_CTRL_PRESSED + LEFT_ALT_PRESSED + RIGHT_ALT_PRESSED) and AEvent.dwControlKeyState = 0) then
      Result := Word(AEvent.UnicodeChar)
    else
      Result := KeyEventToFarKey(AEvent);
  end;
*)

  function KeyEventToFarKeyDlg(const AEvent :TKeyEventRecord) :Integer;
  var
    vEvent :TKeyEventRecord;
  begin
    if (word(AEvent.UnicodeChar) >= 32) and ((LEFT_CTRL_PRESSED + RIGHT_CTRL_PRESSED + LEFT_ALT_PRESSED + RIGHT_ALT_PRESSED) and AEvent.dwControlKeyState = 0) then
      Result := Word(AEvent.UnicodeChar)
    else begin
      vEvent := AEvent;
      if not (vEvent.wVirtualKeyCode in [VK_SHIFT, VK_CONTROL, VK_MENU]) then begin
        { Игнорируем различия между правыми и левыми шифтами }
        if vEvent.dwControlKeyState and RIGHT_CTRL_PRESSED <> 0 then
          vEvent.dwControlKeyState := (vEvent.dwControlKeyState or LEFT_CTRL_PRESSED) and not RIGHT_CTRL_PRESSED;
        if vEvent.dwControlKeyState and RIGHT_ALT_PRESSED <> 0 then
          vEvent.dwControlKeyState := (vEvent.dwControlKeyState or LEFT_ALT_PRESSED) and not RIGHT_ALT_PRESSED;
      end;
      Result := KeyEventToFarKey(vEvent);
    end;
//  TraceF('KeyEventToFarKey1: %x', [Result]);
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
      end else
      if (AKey >= 32) and (AKey < $FFFF) then begin
        AEvent.UnicodeChar := WChar(AKey);
        AEvent.dwControlKeyState := vShift;
//      AEvent.wRepeatCount := 1;
        AEvent.bKeyDown := True;
      end;
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


  var
    hConEmuWnd  :THandle = THandle(-1);


  function GetConsoleWnd :THandle;
  var
    hWnd :THandle;
  begin
    if (hFarWindow = 0) or not IsWindow(hFarWindow) then
      hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);

    Result := hFarWindow;

    if not IsWindowVisible(hFarWindow) then begin
      { Запущено из-под ConEmu?... }
      hWnd := GetAncestor(hFarWindow, GA_PARENT);

      if (hWnd = 0) or (hWnd = GetDesktopWindow) then begin
        { Новая версия ConEmu не делает SetParent... }
        if hConEmuWnd = THandle(-1) then
          hConEmuWnd := CheckConEmuWnd;
        hWnd := hConEmuWnd;
      end;

      if hWnd <> 0 then
        Result := hWnd;
    end;
  end;


  procedure UpdateConsoleWnd;
  begin
    hFarWindow := 0;
    GetConsoleWnd;
  end;


  function MulDivTrunc(ANum, AMul, ADiv :Integer) :Integer;
  begin
    if ADiv = 0 then
      Result := 0
    else
      Result := ANum * AMul div ADiv;
  end;


  function GetConsoleMousePos(AWnd :THandle) :TPoint;
    { Вычисляем позицию мыши в консольных координатах }
  var
    vPos  :TPoint;
    vRect :TRect;
    vInfo :TConsoleScreenBufferInfo;
  begin
    if AWnd = 0 then
      AWnd := GetConsoleWnd;
    if hStdOut = 0 then
      hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    GetCursorPos(vPos);

    ScreenToClient(AWnd, vPos);
    GetClientRect(AWnd, vRect);
    GetConsoleScreenBufferInfo(hStdOut, vInfo);

    with vInfo.srWindow do begin
//    TraceF('%d, %d - %d, %d', [Left, Top, Right, Bottom]);
      Result.Y := Top + MulDivTrunc(vPos.Y, Bottom - Top + 1, vRect.Bottom - vRect.Top);
      Result.X := Left + MulDivTrunc(vPos.X, Right - Left + 1, vRect.Right - vRect.Left);
    end;

    { Коррекция для режима "большого буфера" (/w) }
    with FarGetWindowRect do begin
//    TraceF('FWR: %d-%d, %d-%d', [Top, Bottom, Left, Right]);
      Dec(Result.Y, Top);
      Dec(Result.X, Left);
    end;
  end;


 {-----------------------------------------------------------------------------}


 {$ifdef Far3}
  function HelperDlgProc(hDlg :THandle; Msg :TIntPtr; Param1 :TIntPtr; Param2 :TIntPtr) :TIntPtr; stdcall;
  begin
    if Msg = DN_INITDIALOG then begin
      FARAPI.SendDlgMessage(hDlg, DM_ADDHISTORY, 0, PTChar(Param2));
      FarSendDlgMessage(hDlg, DM_CLOSE, 0, 0);
    end;
    Result := FARAPI.DefDlgProc(hDlg, Msg, Param1, Param2);
  end;
 {$endif Far3}


  procedure FarAddToHistory(const AHist, AStr :TString);
 {$ifdef Far3}
  var
    hDlg :THandle;
    vItems :array[0..0] of TFarDialogItem;
  begin
    vItems[0] := NewItemApi(DI_Edit, 0, 0, 5, -1, DIF_HISTORY, '', PTChar(AHist) );
    hDlg := FARAPI.DialogInit(PluginID, GUID_NULL, -1, -1, 9, 2, nil, Pointer(@vItems), 1, 0, 0, HelperDlgProc, TIntPtr(AStr));
    try
      FARAPI.DialogRun(hDlg);
    finally
      FARAPI.DialogFree(hDlg);
    end;
 {$else}
  var
    hDlg :THandle;
    vItems :array[0..0] of TFarDialogItem;
  begin
    vItems[0] := NewItemApi(DI_Edit, 0, 0, 5, -1, DIF_HISTORY, '', PTChar(AHist) );
    hDlg := FARAPI.DialogInit(hModule, -1, -1, 9, 2, nil, Pointer(@vItems), 1, 0, 0, nil, 0);
    try
      FARAPI.SendDlgMessage(hDlg, DM_ADDHISTORY, 0, TIntPtr(PTChar(AStr)));
    finally
      FARAPI.DialogFree(hDlg);
    end;
 {$endif Far3}
  end;


end.

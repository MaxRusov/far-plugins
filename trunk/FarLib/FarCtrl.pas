{$I Defines.inc}
{$Typedaddress Off}

unit FarCtrl;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Вспомогательные интерфейсные процедуры                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
   {$ifdef bUnicodeFar}
    PluginW
   {$else}
    Plugin
   {$endif bUnicodeFar}
    ;


 {$ifdef bUnicodeFar}

  type
    TFarStr  = TWideStr;
    PFarStr  = PWideStr;

  type
    StrOemToAnsi = TString;
    StrAnsiToOEM = TString;
//const
//  StrOemToAnsi = nil;
//  StrAnsiToOEM = nil;

 {$else}

  type
    TFarChar = AnsiChar;
    PFarChar = PAnsiChar;

    TFarStr  = TAnsiStr;
    PFarStr  = PAnsiStr;

  const
    PF_DIALOG = $0020;
    OPEN_DIALOG  = 8;

 {$endif bUnicodeFar}


  const
   {$ifdef bUnicodeFar}
    cFarRegRoot = 'Software\Far2';
   {$else}
    cFarRegRoot = 'Software\Far';
   {$endif bUnicodeFar}


  const
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

 {-----------------------------------------------------------------------------}

  const
    MIF_CHECKED1 = MIF_CHECKED (* or Byte(chrCheck) *);

  type
    PFarMenuItemsArray = ^TFarMenuItemsArray;
    TFarMenuItemsArray = array[0..MaxInt div SizeOf(TFarMenuItemEx) - 1] of TFarMenuItemEx;

 {-----------------------------------------------------------------------------}

  var
    FARAPI  :TPluginStartupInfo;
    FARSTD  :TFarStandardFunctions;

    hModule      :Integer;
    hFarWindow   :THandle;
    hStdIn       :THandle;
    hStdOut      :THandle;

  type
    PMouseEventRecord = ^TMouseEventRecord;
    TMouseEventRecord = packed record
      dwMousePosition :COORD;
      dwButtonState :DWORD;
      dwControlKeyState :DWORD;
      dwEventFlags :DWORD;
    end;


  function FarChar2Str(AStr :PFarChar) :TString;
  procedure FillFarChar(ABuf :PFarChar; ACount :Integer; AChar :TFarChar);
  procedure SetFarChr(ABuf :PFarChar; ASrc :PTChar; AMaxLen :Integer);
  procedure SetFarStr(ABuf :PFarChar; const AStr :TString; AMaxLen :Integer);

  function GetMsg(MsgId :Integer) :PFarChar;
  function GetMsgStr(MsgId :Integer) :TString;

  procedure AppErrorID(ACode :Integer);
  procedure AppErrorIdFmt(ACode :Integer; const Args: array of const);

  function SetFlag(AFlags, AFlag :DWORD; AOn :Boolean) :DWORD;

  procedure SetMenuItemChr(AItem :PFarMenuItemEx; AStr :PFarChar; AFlags :DWORD = 0);
  procedure SetMenuItemChrEx(var AItem :PFarMenuItemEx; AStr :PFarChar; AFlags :DWORD = 0);
  procedure SetMenuItemStr(AItem :PFarMenuItemEx; const AStr :TString; AFlags :DWORD = 0);
  procedure SetMenuItemStrEx(var AItem :PFarMenuItemEx; const AStr :TString; AFlags :DWORD = 0);

  procedure SetListItem(AItem :PFarListItem; AStr :PFarChar; AFlags :DWORD);

 {$ifdef bUnicodeFar}
  procedure CleanupMenu(AItem :PFarMenuItemEx; ACount :Integer);
  procedure CleanupList(AItem :PFarListItem; ACount :Integer);
 {$endif bUnicodeFar}

  function NewItemApi(AType :Integer; X, Y, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
  function CreateDialog(const AItems :array of TFarDialogItem) :PFarDialogItemArray;
  function RunDialog( APluginNumber :Integer; X1, Y1, DX, DY :Integer; AHelpTopic :PFarChar;
    AItems :PFarDialogItemArray; ACount :Integer; AFlags :DWORD; ADlgProc :TFarApiWindowProc; AParam :Integer) :Integer;

  function StrRightAjust(const AStr :TString; ALen :Integer) :TString;
  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;
  function GetProgressStr(ALen, APerc :Integer) :TString;
  function GetOptColor(AColor, ASysColor :Integer) :Integer;
  function ShowMessage(const ATitle, AMessage :TString; AFlags :Integer; AButtons :Integer = 0) :Integer;
  procedure EnumFilesEx(const ADir, AMask :TFarStr; const aProc :TMethod);

  function CheckForEsc :Boolean;

 {$ifdef bUnicodeFar}
  function FarPanelItem(AHandle :THandle; ACmd, AIndex :Integer) :PPluginPanelItem;
    { ACmd = FCTL_GETPANELITEM, FCTL_GETSELECTEDPANELITEM, FCTL_GETCURRENTPANELITEM }
  function FarPanelString(AHandle :THandle; ACmd :Integer) :TFarStr;
  function FarPanelGetCurrentDirectory(AHandle :THandle) :TFarStr;
  function EditorControlString(ACmd :Integer) :TFarStr;
 {$endif bUnicodeFar}

  procedure FarGetWindowInfo(APos :Integer; var AInfo :TWindowInfo; AName, ATypeName :PTString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


 {$ifdef bTrace}
  uses
    MixDebug;
 {$endif bTrace}


  function FarChar2Str(AStr :PFarChar) :TString;
 {$ifdef bUnicodeFar}
 {$else}
 {$ifdef bUnicode}
 {$else}
  var
    vLen :Integer;
 {$endif bUnicode}
 {$endif bUnicodeFar}
  begin
   {$ifdef bUnicodeFar}
    Result := AStr;
   {$else}

   {$ifdef bUnicode}
    Result := StrOEMToAnsi(AStr);
   {$else}
    vLen := 0;
    if AStr <> nil then
      vLen := StrLenA(AStr);
    SetString(Result, nil, vLen);
    if vLen > 0 then
      {Windows.}OemToCharBuffA(AStr, Pointer(Result), vLen);
   {$endif bUnicode}

   {$endif bUnicodeFar}
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
 {$ifdef bUnicodeFar}
 {$else}
  var
    vLen :Integer;
 {$endif bUnicodeFar}
  begin
   {$ifdef bUnicodeFar}
    StrLCopy(ABuf, ASrc, AMaxLen);
   {$else}

    vLen := StrLen(ASrc);
    if AMaxLen < vLen then
      vLen := AMaxLen;
   {$ifdef bUnicode}
    vLen := WideCharToMultiByte(CP_ACP, 0, ASrc, vLen, ABuf, AMaxLen, nil, nil);
   {$else}
    Move(ASrc^, ABuf^, vLen);
   {$endif bUnicode}
    (ABuf + vLen)^ := #0;
    CharToOEMBuffA(ABuf, ABuf, vLen);

   {$endif bUnicodeFar}
  end;


  procedure SetFarStr(ABuf :PFarChar; const AStr :TString; AMaxLen :Integer);
  begin
    SetFarChr(ABuf, PTChar(AStr), AMaxLen);
  end;


  function GetMsg(MsgId :Integer) :PFarChar;
  begin
    Result := FARAPI.GetMsg(FARAPI.ModuleNumber, Byte(MsgId));
  end;


  function GetMsgStr(MsgId :Integer) :TString;
  begin
    Result := FarChar2Str(GetMsg(MsgId));
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


  procedure SetMenuItemChr(AItem :PFarMenuItemEx; AStr :PFarChar; AFlags :DWORD = 0);
  begin
   {$ifdef bUnicodeFar}
    AItem.TextPtr := AStr;
   {$else}
    StrLCopyA(@AItem.Text, AStr, SizeOf(AItem.Text));
   {$endif bUnicodeFar}
    AItem.Flags := AFlags;
  end;


  procedure SetMenuItemChrEx(var AItem :PFarMenuItemEx; AStr :PFarChar; AFlags :DWORD = 0);
  begin
    SetMenuItemChr(AItem, AStr, AFlags);
    Inc(PChar(AItem), SizeOf(TFarMenuItemEx));
  end;


  procedure SetMenuItemStr(AItem :PFarMenuItemEx; const AStr :TString; AFlags :DWORD = 0);
  begin
   {$ifdef bUnicodeFar}
    SetMenuItemChr(AItem, StrNewW(PWideChar(AStr)), AFlags);
   {$else}

   {$ifdef bUnicode}
    {!!!}
   {$else}
    SetMenuItemChr(AItem, PAnsiChar(AStr), AFlags);
   {$endif bUnicode}
    CharToOEMBuffA(@AItem.Text, @AItem.Text, Length(AStr));

   {$endif bUnicodeFar}
  end;


  procedure SetMenuItemStrEx(var AItem :PFarMenuItemEx; const AStr :TString; AFlags :DWORD = 0);
  begin
    SetMenuItemStr(AItem, AStr, AFlags);
    Inc(PChar(AItem), SizeOf(TFarMenuItemEx));
  end;



  procedure SetListItem(AItem :PFarListItem; AStr :PFarChar; AFlags :DWORD);
  begin
   {$ifdef bUnicodeFar}
    AItem.TextPtr := StrNewW(AStr);
   {$else}
    StrLCopyA(@AItem.Text, AStr, SizeOf(AItem.Text));
   {$endif bUnicodeFar}
    AItem.Flags := AFlags;
  end;


 {$ifdef bUnicodeFar}
  procedure CleanupMenu(AItem :PFarMenuItemEx; ACount :Integer);
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do begin
      StrDispose(AItem.TextPtr);
      Inc(PChar(AItem), SizeOf(TFarMenuItemEx));
    end;
  end;

  procedure CleanupList(AItem :PFarListItem; ACount :Integer);
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do begin
      StrDispose(AItem.TextPtr);
      Inc(PChar(AItem), SizeOf(TFarListItem));
    end;
  end;
 {$endif bUnicodeFar}


 {-----------------------------------------------------------------------------}

  function SRect(X, Y, X2, Y2 :Integer) :TSmallRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X2;
      Bottom := Y2;
    end;
  end;


  function SBounds(X, Y, W, H :Integer) :TSmallRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X + W;
      Bottom := Y + H;
    end;
  end;


  procedure SRectGrow(var AR :TSmallRect; ADX, ADY :Integer);
  begin
    dec(AR.Left,   ADX);
    inc(AR.Right,  ADX);
    dec(AR.Top,    ADY);
    inc(AR.Bottom, ADY);
  end;


  function StrRightAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := AStr
    else
      Result := StringOfChar(' ', ALen - vLen) + AStr;
  end;


  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := Copy(AStr, 1, ALen)
    else
      Result := AStr + StringOfChar(' ', ALen - vLen);
  end;


  function GetProgressStr(ALen, APerc :Integer) :TString;
  var
    vFilled :Integer;
  begin
    vFilled := MulDiv(ALen, RangeLimit(APerc, 0, 100), 100);
    Result := StringOfChar(chrBrick, vFilled) + StringOfChar(chrHatch, ALen - vFilled);
  end;


  function GetOptColor(AColor, ASysColor :Integer) :Integer;
  begin
    Result := AColor;
    if Result = 0 then
      Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(ASysColor));
  end;


  function ShowMessage(const ATitle, AMessage :TString; AFlags :Integer; AButtons :Integer = 0) :Integer;
  var
    vStr :TFarStr;
  begin
   {$ifdef bUnicodeFar}
    vStr := ATitle + #10 + AMessage;
   {$else}
    vStr := StrAnsiToOem(ATitle + #10 + AMessage);
   {$endif bUnicodeFar}
    Result := FARAPI.Message(hModule, AFlags or FMSG_ALLINONE, nil, PPCharArray(PFarChar(vStr)), 0, AButtons);
  end;


 {-----------------------------------------------------------------------------}

  function NewItemApi(AType :Integer; X, Y, W, H :Integer; AFlags :DWORD; AText :PFarChar = nil; AHist :PFarChar = nil) :TFarDialogItem;
  begin
    FillChar(Result, SizeOf(Result), 0);
    with Result do begin
      ItemType := AType;
      X1 := X;
      Y1 := Y;
      if W >= 0 then
        X2 := X + W - 1;
      if H >= 0 then
        Y2 := Y + H - 1;
      Flags := AFlags;
      Param.History := AHist;
     {$ifdef bUnicodeFar}
      PtrData := AText;
     {$else}
      if AText <> nil then
        StrLCopyA(Data.Data, AText, 511);
     {$endif bUnicodeFar}
    end;
  end;


  function CreateDialog(const AItems :array of TFarDialogItem) :PFarDialogItemArray;
  var
    I, vCount :Integer;
    vItem :PFarDialogItem;
  begin
    vCount := High(AItems) + 1;
    Result := MemAllocZero(vCount * SizeOf(TFarDialogItem));
    vItem := @Result[0];
    for I := 0 to vCount - 1 do begin
      Move(AItems[I], vItem^, SizeOf(TFarDialogItem));
      Inc(PChar(vItem), SizeOf(TFarDialogItem));
    end;
  end;


  function RunDialog( APluginNumber :Integer; X1, Y1, DX, DY :Integer; AHelpTopic :PFarChar;
    AItems :PFarDialogItemArray; ACount :Integer; AFlags :DWORD; ADlgProc :TFarApiWindowProc; AParam :Integer) :Integer;
 {$ifdef bUnicodeFar}
  var
    hDlg :THandle;
 {$endif bUnicodeFar}
  begin
   {$ifdef bUnicodeFar}
    hDlg := FARAPI.DialogInit(APluginNumber, X1, Y1, DX, DY, AHelpTopic, AItems, ACount, 0, AFlags, ADlgProc, AParam);
    try
      Result := FARAPI.DialogRun(hDlg);
    finally
      FARAPI.DialogFree(hDlg);
    end;
   {$else}
    Result := FARAPI.DialogEx(APluginNumber, X1, Y1, DX, DY, AHelpTopic, AItems, ACount, 0, AFlags, ADlgProc, AParam);
   {$endif bUnicodeFar}
  end;


 {-----------------------------------------------------------------------------}

  type
    TEnumFilesProc = function(const AFileName :TString; const ARec :TFarFindData) :Integer;


  function EnumFilesProc(const FindData :PFarFindData; const FullName :PFarChar; Param: pointer) :integer; stdcall;
  var
    vStr :TString;
    vTmp :TMethod;
  begin
    vStr := FullName;
    vTmp := TMethod(Param^);
    asm push vTmp.Data; end;
    Result := TEnumFilesProc(vTmp.Code)(vStr, FindData^);
    asm pop ECX; end;
  end;

  procedure EnumFilesEx(const ADir, AMask :TFarStr; const aProc :TMethod);
  begin
    FARSTD.FarRecursiveSearch(PFarChar(ADir), PFarChar(AMask), EnumFilesProc, FRS_RECUR, @aProc);
  end;


 {-----------------------------------------------------------------------------}

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


 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}

  function FarPanelItem(AHandle :THandle; ACmd, AIndex :Integer) :PPluginPanelItem;
  var
    vSize :Integer;
  begin
    vSize := FARAPI.Control(AHandle, ACmd, AIndex, nil);
    Result := MemAlloc( vSize );
    FARAPI.Control(AHandle, ACmd, AIndex, Result);
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
    Result := FarPanelString(AHandle, FCTL_GETCURRENTDIRECTORY);
  end;

// FCTL_GETCOLUMNTYPES           = 27;
// FCTL_GETCOLUMNWIDTHS          = 28;


  function EditorControlString(ACmd :Integer) :TFarStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FARAPI.EditorControl(ACmd, nil);
    if vLen > 1 then begin
      SetLength(Result, vLen - 1);
      FARAPI.EditorControl(ACmd, PFarChar(Result));
    end;
  end;

 {$endif bUnicodeFar}



  procedure FarGetWindowInfo(APos :Integer; var AInfo :TWindowInfo; AName, ATypeName :PTString);
  begin
    FillChar(AInfo, SizeOf(AInfo), 0);
    AInfo.Pos := APos;

   {$ifdef bUnicodeFar}
    FARAPI.AdvControl(hModule, ACTL_GETWINDOWINFO_W, @AInfo);
    try
      if (AName <> nil) and (AInfo.NameSize > 0) then
        AInfo.Name := MemAlloc(AInfo.NameSize * SizeOf(TChar));
      if (ATypeName <> nil) and (AInfo.TypeNameSize > 0) then
        AInfo.TypeName := MemAlloc(AInfo.TypeNameSize * SizeOf(TChar));
      if (AInfo.Name <> nil) or (AInfo.TypeName <> nil) then
        FARAPI.AdvControl(hModule, ACTL_GETWINDOWINFO_W, @AInfo);
   {$else}
    FARAPI.AdvControl(hModule, ACTL_GETWINDOWINFO, @AInfo);
   {$endif bUnicodeFar}

    if AName <> nil then
      AName^ := FarChar2Str(AInfo.Name);
    if ATypeName <> nil then
      ATypeName^ := FarChar2Str(AInfo.TypeName);

   {$ifdef bUnicodeFar}
    finally
      MemFree(AInfo.Name);
      MemFree(AInfo.TypeName);
    end;
   {$endif bUnicodeFar}
  end;


end.


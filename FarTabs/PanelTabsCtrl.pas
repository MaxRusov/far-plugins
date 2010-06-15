{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}

unit PanelTabsCtrl;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    FarCtrl,
    FarConMan,
    FarMatch;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strTabs,

      strMAddTab,
      strMEditTabs,
      strMSelectTab,
      strMOptions,

      strOptions,
      strMShowTabs,
      strMShowNumbers,
      strMShowButton,
      strMSeparateTabs,

      strEditTab,
      strAddTab,
      strCaption,
      strFolder,
      strFixed,
      strOk,
      strCancel,
      strDelete,

      strEmptyCaption,
      strUnknownCommand
    );


  const
    cFarTabGUID        = $A91B3F07;
    cFarTabPrefix      = 'tab';

    cTabFileExt        = 'tab';

    cPlugRegFolder     = 'PanelTabs';
    cTabsRegFolder     = 'Tabs';
    cTabRegFolder      = 'Tab';
    cLeftRegFolder     = 'Left';
    cRightRegFolder    = 'Right';
    cCommonRegFolder   = 'Common';
    cCaptionRegKey     = 'Caption';
    cFolderRegKey      = 'Folder';
    cCurrentRegKey     = 'Current';

  var
    optShowTabs        :Boolean = True;
    optShowNumbers     :Boolean = True;
    optShowButton      :Boolean = True;
    optSeparateTabs    :Boolean = True;
    optStoreSelection  :Boolean = True;

    optFixedMark       :TString = '*';
    optNotFixedMark    :TString = '';

    optBkColor         :Integer = 0;
    optActiveTabColor  :Integer = 0;
    optPassiveTabColor :Integer = 0;
    optNumberColor     :Integer = 0;
    optButtonColor     :Integer = 0;

//  optHiddenColor     :Integer = 0;
//  optFoundColor      :Integer = $0A;
//  optSelectedColor   :Integer = $20;

   {$ifdef bUnicodeFar}
   {$else}
    TabKey1            :Word    = 0; {VK_F24 - $87}
    TabShift1          :Word    = 0; {LEFT_ALT_PRESSED or SHIFT_PRESSED}
   {$endif bUnicodeFar}



  var
    FRegRoot  :TString;

  var
    hFarWindow  :THandle = THandle(-1);
    hConEmuWnd  :THandle = THandle(-1);


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  procedure HandleError(AError :Exception);

  function hConsoleWnd :THandle;
  function GetConsoleTitleStr :TString;
  function GetConsoleMousePos :TPoint;
    { Вычисляем позицию мыши в консольных координатах }
  function ReadScreenChar(X, Y :Integer) :TChar;
    { Получаем символ из позиции X, Y }

  function VKeyToIndex(AKey :Integer) :Integer;
  function IndexToChar(AIndex :Integer) :TChar;

  function CurrentPanelIsRight :Boolean;
  function GetPanelDir(Active :Boolean) :TString;
  function PathToCaption(const APath :TString) :TString;

  procedure ReadSetup;
  procedure WriteSetup;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
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


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('PanelTabs', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..1024] of TChar;
  begin
    FillChar(vBuf, SizeOf(vBuf), $00);
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;

    if ConManDetected then
      ConManClearTitle(Result);

//  TraceF('GetConsoleTitleStr: %s', [Result]);
  end;


  function hConsoleWnd :THandle;
  var
    hWnd :THandle;
  begin
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


  function MulDivTrunc(ANum, AMul, ADiv :Integer) :Integer;
  begin
    if ADiv = 0 then
      Result := 0
    else
      Result := ANum * AMul div ADiv;
  end;


  function GetConsoleMousePos :TPoint;
  var
    vWnd  :THandle;
    vPos  :TPoint;
    vRect :TRect;
    vInfo :TConsoleScreenBufferInfo;
  begin
    GetCursorPos(vPos);

    vWnd := hConsoleWnd;
    ScreenToClient(vWnd, vPos);
    GetClientRect(vWnd, vRect);
    GetConsoleScreenBufferInfo(hStdOut, vInfo);

    with vInfo.srWindow do begin
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


  function ReadScreenChar(X, Y :Integer) :TChar;
  var
    vInfo :TConsoleScreenBufferInfo;
    vBuf :array[0..1, 0..1] of TCharInfo;
    vSize, vCoord :TCoord;
    vReadRect :TSmallRect;
  begin
    Result := #0;
    if not GetConsoleScreenBufferInfo(hStdOut, vInfo) then
      Exit;

    { Коррекция для режима "большого буфера" (/w) }
    with FarGetWindowRect do begin
      Inc(Y, Top);
      Inc(X, Left);
    end;

    if (X < vInfo.dwSize.X) and (Y < vInfo.dwSize.Y) then begin
      vSize.X := 1; vSize.Y := 1; vCoord.X := 0; vCoord.Y := 0;
      vReadRect := SBounds(X, Y, 1, 1);
      FillChar(vBuf, SizeOf(vBuf), 0);

//    TraceF('ReadConsoleOutput: %d, %d, %d, %d', [X, Y, vInfo.dwSize.X, vInfo.dwSize.Y]);
      if ReadConsoleOutput(hStdOut, @vBuf, vSize, vCoord, vReadRect) then begin
       {$ifdef bUnicode}
        Result := vBuf[0, 0].UnicodeChar;
       {$else}
        Result := vBuf[0, 0].AsciiChar;
       {$endif bUnicode}
      end else
        {RaiseLastWin32Error};
    end;
  end;

(*
  function ReadScreenChar(X, Y :Integer) :TChar;
  var
    vInfo :TConsoleScreenBufferInfo;
//  vTst1 :Integer;
    vBuf :array[0..128, 0..2] of TCharInfo;
//  vTst2 :Integer;

    vSize, vCoord :TCoord;
    vReadRect :TSmallRect;
  begin
    Result := #0;

//  vTst1 := $12345678;
//  vTst2 := $12345678;

//  Trace('GetConsoleScreenBufferInfo...');
    if not GetConsoleScreenBufferInfo(hStdOut, vInfo) then begin
      NOP;
      Exit;
    end;
//  Trace('Done');

    if (X < vInfo.dwSize.X) and (Y < vInfo.dwSize.Y) then begin

      if (X < 0) or (Y < 0) then
        NOP;

      vSize.X := 1; vSize.Y := 1; vCoord.X := 0; vCoord.Y := 0;
      vReadRect := SBounds(X, Y, 1, 1);
      FillChar(vBuf, SizeOf(vBuf), 0);

//    TraceF('ReadConsoleOutput: %d, %d, %d, %d', [X, Y, vInfo.dwSize.X, vInfo.dwSize.Y]);
      if ReadConsoleOutput(hStdOut, @vBuf, vSize, vCoord, vReadRect) then begin
       {$ifdef bUnicode}
        Result := vBuf[0, 0].UnicodeChar;
       {$else}
        Result := vBuf[0, 0].AsciiChar;
       {$endif bUnicode}
      end else
        RaiseLastWin32Error;
//    Trace('Done');

    end;

//  Assert(vTst1 = $12345678);
//  Assert(vTst2 = $12345678);
  end;
*)

  function CurrentPanelIsRight :Boolean;
  var
    vInfo  :TPanelInfo;
  begin
    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    FARAPI.Control(THandle(PANEL_ACTIVE), FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelShortInfo, @vInfo);
   {$endif bUnicodeFar}
    Result := (PFLAGS_PANELLEFT and vInfo.Flags = 0);
  end;


  function GetPanelDir(Active :Boolean) :TString;
 {$ifdef bUnicodeFar}
 {$else}
  var
    vInfo :TPanelInfo;
 {$endif bUnicodeFar}
  begin
   {$ifdef bUnicodeFar}
    Result := FarPanelGetCurrentDirectory(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE));
   {$else}
    FillChar(vInfo, SizeOf(vInfo), 0);
    FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_GetPanelInfo, FCTL_GetAnotherPanelInfo), @vInfo);
    Result := StrOemToAnsi(vInfo.CurDir);
   {$endif bUnicodeFar}
  end;


  function VKeyToIndex(AKey :Integer) :Integer;
  begin
    Result := -1;
    case AKey of
      Byte('1')..Byte('9'):
        Result := AKey - Byte('1');
      Byte('a')..Byte('z'):
        Result := AKey - Byte('a') + 9;
      Byte('A')..Byte('Z'):
        Result := AKey - Byte('A') + 9;
    end;
  end;


  function IndexToChar(AIndex :Integer) :TChar;
  begin
    if AIndex < 9 then
      Result := TChar(Byte('1') + AIndex)
    else
      Result := TChar(Byte('A') + AIndex - 9);
  end;


  function PathToCaption(const APath :TString) :TString;
  begin
    Result := ExtractFileName(APath);
    if Result = '' then
      Result := APath;
  end;


 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
     {$ifdef bUnicodeFar}
     {$else}
      TabKey1 := RegQueryInt(vKey, 'CallKey', TabKey1);
      TabShift1 := RegQueryInt(vKey, 'CallShift', TabShift1);
     {$endif bUnicodeFar}

      optBkColor := RegQueryInt(vKey, 'TabBkColor', optBkColor);
      optActiveTabColor := RegQueryInt(vKey, 'ActiveTabColor', optActiveTabColor);
      optPassiveTabColor := RegQueryInt(vKey, 'PassiveTabColor', optPassiveTabColor);
      optNumberColor := RegQueryInt(vKey, 'NumberColor', optNumberColor);
      optButtonColor := RegQueryInt(vKey, 'ButtonColor', optButtonColor);

//    optHiddenColor := RegQueryInt(vKey, 'HiddenColor', optHiddenColor);
//    optFoundColor := RegQueryInt(vKey, 'FoundColor', optFoundColor);
//    optSelectedColor := RegQueryInt(vKey, 'SelectedColor', optSelectedColor);

      optFixedMark := RegQueryStr(vKey, 'LockedMark', optFixedMark);
      optNotFixedMark := RegQueryStr(vKey, 'UnlockedMark', optNotFixedMark);

      optShowTabs := RegQueryLog(vKey, 'ShowTabs', optShowTabs);
      optShowNumbers := RegQueryLog(vKey, 'ShowNumbers', optShowNumbers);
//    optShowButton := RegQueryLog(vKey, 'ShowButton', optShowButton);
      optSeparateTabs := RegQueryLog(vKey, 'SeparateTabs', optSeparateTabs);
      optStoreSelection := RegQueryLog(vKey, 'StoreSelection', optStoreSelection);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try

      RegWriteLog(vKey, 'ShowTabs', optShowTabs);
      RegWriteLog(vKey, 'ShowNumbers', optShowNumbers);
//    RegWriteLog(vKey, 'ShowButton', optShowButton);
      RegWriteLog(vKey, 'SeparateTabs', optSeparateTabs);
      RegWriteLog(vKey, 'StoreSelection', optStoreSelection);

    finally
      RegCloseKey(vKey);
    end;
  end;


end.


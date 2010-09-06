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
    FarColor,

    FarCtrl,
    FarConMan,
    FarColorDlg;


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
      strMMouseActions,
      strColors,

      strColorsTitle,
      strColBackground,
      strColInactiveTab,
      strColActiveTab,
      strColAddButton,
      strColShortcut,
      strRestoreDefaults,

      strEditTab,
      strAddTab,
      strCaption,
      strFolder,
      strFixed,
      strOk,
      strCancel,
      strDelete,

      strEmptyCaption,
      strUnknownCommand,

      strMouseActions,
      strEditAction,
      strAddAction,
      strArea,
      strClickType,
      strShift,
      strCtrl,
      strAlt,
      strAction,

      strClickTypeNotDefined,
      strActionNotDefined,
      strActionAlreadyDefined,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,

      strMouseActionBase
    );


  const
    cFarTabGUID        = $A91B3F07;
    cFarTabPrefix      = 'tab';

    cTabFileExt        = 'tab';

    cMacroPrefix       = 'macro:';
    cExecPrefix        = 'exec:';

    cPlugRegFolder     = 'PanelTabs';
    cTabsRegFolder     = 'Tabs';
    cTabRegFolder      = 'Tab';
    cLeftRegFolder     = 'Left';
    cRightRegFolder    = 'Right';
    cCommonRegFolder   = 'Common';
    cCaptionRegKey     = 'Caption';
    cFolderRegKey      = 'Folder';
    cCurrentRegKey     = 'Current';

    cActionsRegFolder  = 'Actions';
    cActionRegFolder   = 'Action';
    cAreaRegKey        = 'Area';
    cClickRegKey       = 'Click';
    cShiftsRegKey      = 'Shifts';
    cActionRegKey      = 'Action';


  const
    { Команды, доступные через префикс tab: }
    cAddCmd            = 'Add';
    cEditCmd           = 'Edit';
    cSaveCmd           = 'Save';
    cLoadCmd           = 'Load';


  var
    optShowTabs        :Boolean = True;
    optShowNumbers     :Boolean = True;
    optShowButton      :Boolean = True;
    optSeparateTabs    :Boolean = True;
    optStoreSelection  :Boolean = True;

    optFixedMark       :TString = '*';
    optNotFixedMark    :TString = '';

    optDblClickDelay   :Integer = 500;

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

  function VKeyToIndex(AKey :Integer) :Integer;
  function IndexToChar(AIndex :Integer) :TChar;

  function GetPanelDir(Active :Boolean) :TString;
  function PathToCaption(const APath :TString) :TString;

  procedure RestoreDefColor;
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

      optShowTabs := RegQueryLog(vKey, 'ShowTabs', optShowTabs);
      optShowNumbers := RegQueryLog(vKey, 'ShowNumbers', optShowNumbers);
//    optShowButton := RegQueryLog(vKey, 'ShowButton', optShowButton);
      optSeparateTabs := RegQueryLog(vKey, 'SeparateTabs', optSeparateTabs);
      optStoreSelection := RegQueryLog(vKey, 'StoreSelection', optStoreSelection);

      optBkColor := RegQueryInt(vKey, 'TabBkColor', optBkColor);
      optActiveTabColor := RegQueryInt(vKey, 'ActiveTabColor', optActiveTabColor);
      optPassiveTabColor := RegQueryInt(vKey, 'PassiveTabColor', optPassiveTabColor);
      optNumberColor := RegQueryInt(vKey, 'NumberColor', optNumberColor);
      optButtonColor := RegQueryInt(vKey, 'ButtonColor', optButtonColor);

      optFixedMark := RegQueryStr(vKey, 'LockedMark', optFixedMark);
      optNotFixedMark := RegQueryStr(vKey, 'UnlockedMark', optNotFixedMark);

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

      RegWriteInt(vKey, 'TabBkColor', optBkColor);
      RegWriteInt(vKey, 'ActiveTabColor', optActiveTabColor);
      RegWriteInt(vKey, 'PassiveTabColor', optPassiveTabColor);
      RegWriteInt(vKey, 'NumberColor', optNumberColor);
      RegWriteInt(vKey, 'ButtonColor', optButtonColor);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure RestoreDefColor;
  begin
    optBkColor         := GetOptColor(0, COL_COMMANDLINE);
    optActiveTabColor  := GetOptColor(0, COL_PANELTEXT);
    optPassiveTabColor := GetOptColor(0, COL_COMMANDLINE);
    optNumberColor     := GetOptColor(0, COL_PANELCOLUMNTITLE);
    optButtonColor     := GetOptColor(0, COL_PANELTEXT);
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


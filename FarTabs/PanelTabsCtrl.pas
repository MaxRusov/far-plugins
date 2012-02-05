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

    Far_API,
    FarCtrl,
    FarConMan,
    FarConfig,
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

      strConfirmation,
//    strFileNotFound,
      strFolderNotFound,
      strNearestFolderIs,
//    strCreateFileBut,
      strCreateFolderBut,
      strGotoNearestBut,
//    strDeleteBut,
      strCannotCreateFolder,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,

      strMouseActionBase
    );


  const
    cPluginName = 'PanelTabs';
    cPluginDescr = 'PanelTabs FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID    :TGUID = '{8E6FEAE8-9078-4FB9-81E8-1A58F4746037}';
    cMenuID      :TGUID = '{8C7FD2E3-EB46-4D00-84E2-83C763DAFEA4}';
    cConfigID    :TGUID = '{412FFADF-5DEA-4805-BBE0-FC1142FAFE01}';
   {$else}
    cPluginID    = $A91B3F07;
   {$endif Far3}

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

    optBkColor         :TFarColor;
    optActiveTabColor  :TFarColor;
    optPassiveTabColor :TFarColor;
    optNumberColor     :TFarColor;
    optButtonColor     :TFarColor;
//  optHiddenColor     :TFarColor;
//  optFoundColor      :TFarColor;
//  optSelectedColor   :TFarColor;

   {$ifdef bUnicodeFar}
   {$else}
    TabKey1            :Word    = 0; {VK_F24 - $87}
    TabShift1          :Word    = 0; {LEFT_ALT_PRESSED or SHIFT_PRESSED}
   {$endif bUnicodeFar}


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

  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if Exists then begin
          LogValue('ShowTabs', optShowTabs);
          LogValue('ShowNumbers', optShowNumbers);
          LogValue('ShowButton', optShowButton);
          LogValue('SeparateTabs', optSeparateTabs);
          LogValue('StoreSelection', optStoreSelection);

          ColorValue('TabBkColor', optBkColor);
          ColorValue('ActiveTabColor', optActiveTabColor);
          ColorValue('PassiveTabColor', optPassiveTabColor);
          ColorValue('NumberColor', optNumberColor);
          ColorValue('ButtonColor', optButtonColor);

          StrValue('LockedMark', optFixedMark);
          StrValue('UnlockedMark', optNotFixedMark);
        end;
      finally
        Destroy;
      end;
  end;


  procedure ReadSetup;
  begin
    PluginConfig(False);
  end;

  procedure WriteSetup;
  begin
    PluginConfig(True);
  end;


  procedure RestoreDefColor;
  begin
    optBkColor         := FarGetColor(COL_COMMANDLINE);
    optActiveTabColor  := FarGetColor(COL_PANELTEXT);
    optPassiveTabColor := FarGetColor(COL_COMMANDLINE);
    optNumberColor     := FarGetColor(COL_PANELCOLUMNTITLE);
    optButtonColor     := FarGetColor(COL_PANELTEXT);
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


{******************************************************************************}
{* (c) 2009-2013 Max Rusov                                                    *}
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

      strOptionsMenuTile,
      strMGeneral,
      strMMouseActions,
      strMColors,

      strOptionsDlgTile,
      strDShowTabs,
      strDShowNumbers,
      strDShowButton,
      strDSeparateTabs,
      strDStoreSelection,
      strDTabFormat,
      strDFixedTabFormat,
      strDTabDelimiter,

      strColorsTitle,
      strColBackground,
      strColInactiveTab,
      strColActiveTab,
      strColAddButton,
      strColShortcut,
      strColDelimiter,
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

    optNormTabFmt      :TString = '%n%s';
    optFixedTabFmt     :TString = '%n*%s';
    optTabDelimiter    :TString = ' ';

    optDblClickDelay   :Integer = 500;

    optBkColor         :TFarColor;
    optActiveTabColor  :TFarColor;
    optPassiveTabColor :TFarColor;
    optNumberColor     :TFarColor;
    optButtonColor     :TFarColor;
    optDelimiterColor  :TFarColor;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  procedure HandleError(AError :Exception);

  function GetConsoleTitleStr :TString;
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
    FillZero(vBuf, SizeOf(vBuf));
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;

    if ConManDetected then
      ConManClearTitle(Result);

//  TraceF('GetConsoleTitleStr: %s', [Result]);
  end;

  
  function GetPanelDir(Active :Boolean) :TString;
  begin
    Result := FarPanelGetCurrentDirectory(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE));
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
          ColorValue('DelimiterColor', optDelimiterColor);

          StrValue('TabFormat', optNormTabFmt);
          StrValue('FixedTabFormat', optFixedTabFmt);
          StrValue('TabDelimiter', optTabDelimiter);
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
    optDelimiterColor  := FarGetColor(COL_COMMANDLINE);
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


{$I Defines.inc}

unit MoreHistoryCtrl;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarColor,
    FarCtrl,
    FarConfig,
    FarColorDlg;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMFoldersHistory,
      strMViewEditHistory,
      strMModifyHistory,
      strMCommandHistory,
      strMPreviousCommand,
      strMNextCommand,
      strMOptions1,

      strFoldersHistoryTitle,
      strViewEditHistoryTitle,
      strModifyHistoryTitle, 
      strCommandHistoryTitle, 

      strConfirmation,
      strDeleteSelectedPrompt,
      strClearSelectedPrompt,
      strMakeTransitPrompt,
      strMakeActualPrompt,

      strFileNotFound,
      strCreateFileBut,
      strDeleteBut,
      strCancel,

      strHintPath,
      strHintFTP,
      strHintPrefix,
      strHintLastVisited,
      strHintVisitCount,

      strCommandsTitle,
      strMOpen,
      strMView,
      strMEdit,
      strMMarkTranzit,
      strMMarkActual,
      strMDelete,
      strMClearHitCount,
      strMOptions,

      strOptionsTitle1,
      strMShowHidden,
      strMGroupBy,
      strMSeparateName,

      strMFullPath,
      strMAccessTime,
      strMHitCount,
      strMOpenCount,
      strMModifyTime,
      strMSaveCount,
      strMSortBy,

      strOptionsTitle2,
      strMShowHints,
      strMFollowMouse,
      strMWrapMode,
      strMHideCurrent,
      strMAutoXLatMask,
      strMRememberLastMask,
      strMFldExclusions,
      strMEdtExclusions,
      strMColors,

      strColorsTitle,
      strMHiddenColor,
      strMGroupColor,
      strMQuickFilter,
      strMSelectedColor,
      strMRestoreDefaults,

      strSortByTitle,
      strMByName,
      strMByAccessTime,
      strMByHitCount,
      strMByModifyTime,
      strMBySaveCount,
      strMUnsorted,

      strFilterTitle,
      strFilterPrompt,

      strFldExclTitle,
      strEdtExclTitle,
      strExclPrompt,

      strToday,
      strYesterday,
      strDaysAgo,
      strDays1,
      strDays2,
      strDays5,
      strDays21,

      strColorDialog
    );


  const
    cPluginName = 'MoreHistory';
    cPluginDescr = 'MoreHistory FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID    :TGUID = '{0AB780BC-36CA-4FDA-B321-70520D875CDE}';
    cMenuID      :TGUID = '{DD417DBF-0F42-4187-9960-7694A6F7A5A3}';
    cConfigID    :TGUID = '{0989445B-AFF6-46AA-9832-0972BBE10730}';
   {$else}
    cPluginID    = $5453484D;  //MHST
   {$endif Far3}

    cFoldersDlgID  :TGUID = '{DDA833F3-3EA1-4B96-B867-590CE29AE6E0}';
    cFilesDlgID    :TGUID = '{EF4E9F0A-56EA-4510-92D9-FC361FE1FA9A}';
   {$ifdef bCmdHistory}
    cCommandsDlgID :TGUID = '{433B0FAD-56A5-46E1-BCFB-462DEAAE35C9}';
   {$endif bCmdHistory}

    cPluginFolder     = 'MoreHistory';
    cFldHistFileName  = 'Folders.dat';
    cEdtHistFileName  = 'Editors.dat';
   {$ifdef bCmdHistory}
    cCmdHistFileName  = 'Commands.dat';
   {$endif bCmdHistory}

    cSignature :array[0..3] of AnsiChar = 'MHSF';
    cFldVersion   = 1;
//  cEdtVersion   = 2;  { +FSaveCount }
    cEdtVersion   = 3;  { +FModCol }
   {$ifdef bCmdHistory}
    cCmdVersion   = 1;
   {$endif bCmdHistory}

    cHilterHistName = 'MoreHistory.Filter';

    cDefHistoryLength = 64;

   {$ifdef bUnicodeFar}
    chrHiddenMark   = #$2022;
    chrMoreFilter   = #$25BA;
   {$else}
    chrHiddenMark   = #$07;
    chrMoreFilter   = #$10;
   {$endif bUnicodeFar}


  const
    hfFinal   = $00000001;
    hfEdit    = $00000001;
    hfDeleted = $80000000;

  type
    THierarchyMode = (
      hmDate,
      hmDomain,
//    hmDateDomain
//    hmDomainDate
      hmModDate
    );

  var
    optShowHidden      :Boolean = False;
    optHierarchical    :Boolean = True;
    optHierarchyMode   :THierarchyMode = hmDate;
    optSortMode        :Integer = 0;

    optSeparateName    :Boolean = True;   { Показвать раздельно имя файла и путь }
    optShowFullPath    :Boolean = True;   { Показывать полный путь }
    optShowDate        :Boolean = True;   { Показвать дату обращения }
    optShowHits        :Boolean = False;  { Показывать количество обращений }
    optShowModify      :Boolean = True;   { Показывать дату модификации }
    optShowSaves       :Boolean = False;  { Показывать количество сохранений }

    optShowGrid        :Boolean = False;
    optShowHints       :Boolean = True;
    optFollowMouse     :Boolean = False;
    optWrapMode        :Boolean = False;
    optNewAtTop        :Boolean = True;
    optHideCurrent     :Boolean = True;
    optXLatMask        :Boolean = True;   { Автоматическое XLAT преобразование при поиске }
    optSaveMask        :Boolean = False;  { Сохранение старой маски при повторном вызове плагина }

    optMidnightHour    :Integer = 0;
    optDateFormat      :Integer = 0;

    optHistoryFolder   :TString = '';
    optHistoryLimit    :Integer = 1000;
    optSkipTransit     :Boolean = True;
    optSkipQuickView   :Boolean = True;

    optFldExclusions   :TString = '';
    optEdtExclusions   :TString = '%TEMP%\*';

    optHiddenColor     :TFarColor;
    optFoundColor      :TFarColor;
    optSelectedColor   :TFarColor;
    optGroupColor      :TFarColor;

  const
    cFldPrefix         = 'mh';
    cEdtPrefix         = 'mhe';
   {$ifdef bCmdHistory}
    cCmdPrefix         = 'mhc';
   {$endif bCmdHistory}

    cPrefixes  =
      cFldPrefix
      + ':' +
      cEdtPrefix
     {$ifdef bCmdHistory}
      + ':' +
      cCmdPrefix
     {$endif bCmdHistory}
      ;


  var
    FRegRoot  :TString;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure HandleError(AError :Exception);

  procedure RestoreDefColor;
  procedure ReadSettings;
  procedure ReadSetup(const AMode :TString);
  procedure WriteSetup(const AMode :TString);
//procedure ChangedSettings;

  function GetHistoryList(const AHistName :TString) :TStrList; 
  procedure AddToHistory(const AHist, AStr :TString);

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

  procedure HandleError(AError :Exception);
  begin
    ShowMessage(GetMsgStr(strError), AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optHiddenColor     := MakeColor(clGray, 0);
    optGroupColor      := MakeColor(clBlue, 0);
    optFoundColor      := MakeColor(clLime, 0);
    optSelectedColor   := MakeColor(0, clGreen);
  end;


 {-----------------------------------------------------------------------------}

  procedure ReadSettings;
  begin
    with TFarConfig.CreateEx(False, cPluginName) do
      try
        if Exists then begin
          StrValue('HistoryFolder', optHistoryFolder);
          IntValue('HistoryLimit', optHistoryLimit);
          StrValue('Exclusions', optFldExclusions);
          StrValue('EdtExclusions', optEdtExclusions);
        end;
      finally
        Destroy;
      end;
  end;


  procedure PluginConfig(AStore :Boolean; const AMode :TString);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if Exists then begin
          LogValue('ShowGrid', optShowGrid);
          LogValue('ShowHints', optShowHints);
          LogValue('FollowMouse', optFollowMouse);
          LogValue('WrapMode', optWrapMode);
          LogValue('NewAtTop', optNewAtTop);
          LogValue('HideCurrent', optHideCurrent);
          LogValue('XLatMask', optXLatMask);
          LogValue('SaveMask', optSaveMask);

          IntValue('MidnightHour', optMidnightHour);

          ColorValue('HiddenColor', optHiddenColor);
          ColorValue('FoundColor', optFoundColor);
          ColorValue('SelectedColor', optSelectedColor);
          ColorValue('GroupColor', optGroupColor);

          if AStore then begin
//          StrValue('HistoryFolder', optHistoryFolder);
//          IntValue('HistoryLimit', optHistoryLimit);
            StrValue('Exclusions', optFldExclusions);
            StrValue('EdtExclusions', optEdtExclusions);
          end;

          if (AMode <> '') and OpenKey('View\' + AMode) then begin

            LogValue('ShowTransit', optShowHidden);
            LogValue('Hierarchical', optHierarchical);
            Byte(optHierarchyMode) := IntValue1('HierarchyMode', Byte(optHierarchyMode));
            IntValue('SortMode', optSortMode);

            LogValue('ShowSeparateName', optSeparateName);
            LogValue('ShowFullPath', optShowFullPath);
            LogValue('ShowDate', optShowDate);
            LogValue('ShowHits', optShowHits);
            LogValue('ShowModify', optShowModify);
            LogValue('ShowSaves', optShowSaves);

          end;
        end;
      finally
        Destroy;
      end;
  end;


  procedure ReadSetup(const AMode :TString);
  begin
    PluginConfig(False, AMode);
  end;


  procedure WriteSetup(const AMode :TString);
  begin
    PluginConfig(True, AMode);
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef Far3}

  function GetHistoryList(const AHistName :TString) :TStrList;
  begin
    {!!!}
    Result := nil;
  end;

  procedure AddToHistory(const AHist, AStr :TString);
  begin
    {!!!}
  end;

 {$else}

  const
    cDlgHistRegRoot = cFarRegRoot + '\SavedDialogHistory';


  function GetHistoryList(const AHistName :TString) :TStrList;
  var
    vKey :HKEY;
    vName, vStr :TString;
    vPtr, vEnd :PTChar;
  begin
    Result := TStrList.Create;
    vName := cDlgHistRegRoot + '\' + AHistName;
    if RegOpenRead(HKCU, vName, vKey) then begin
      try
        vStr := RegQueryStr(vKey, 'Lines', '');
        if vStr <> '' then begin
          vPtr := PTChar(vStr);
          vEnd := vPtr + length(vStr);
          while vPtr < vEnd do begin
            Result.Add(ExtractNextValue(vPtr, [#0]));
            Inc(vPtr);
          end;
        end;
      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure AddToHistory(const AHist, AStr :TString);
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
  end;
 {$endif Far3}


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


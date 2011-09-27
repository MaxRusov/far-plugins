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
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarColorDlg;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMFoldersHistory,
      strMViewEditHistory,
      strMModifyHistory,
      strMOptions1,

      strFoldersHistoryTitle,
      strViewEditHistoryTitle,
      strModifyHistoryTitle, 

      strConfirmation,
      strDeleteSelectedPrompt,
      strClearSelectedPrompt,
      strMakeTransitPrompt,
      strMakeActualPrompt,

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
    cPlugRegFolder    = 'MoreHistory';
    cPluginFolder     = 'MoreHistory';
    cFldHistFileName  = 'Folders.dat';
    cEdtHistFileName  = 'Editors.dat';

    cSignature :array[0..3] of AnsiChar = 'MHSF';
    cFldVersion   = 1;
//  cEdtVersion   = 2;  { +FSaveCount }
    cEdtVersion   = 3;  { +FModCol }

    cDlgHistRegRoot = cFarRegRoot + '\SavedDialogHistory';
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

    optHiddenColor     :Integer;
    optFoundColor      :Integer;
    optSelectedColor   :Integer;
    optGroupColor      :Integer;

  const
    cFldPrefix         = 'mh';
    cEdtPrefix         = 'mhe';
    cPrefixes          :TFarStr = cFldPrefix + ':' + cEdtPrefix;


  var
    FRegRoot  :TString;

  var
    FLastFilter :TString;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure HandleError(AError :Exception);

  procedure RestoreDefColor;
  procedure ReadSettings;
  procedure ReadSetup(const AMode :TString);
  procedure WriteSetup(const AMode :TString);

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
    optHiddenColor     := clGray;
    optGroupColor      := clBlue;
    optFoundColor      := clLime;
    optSelectedColor   := clBkGreen;
  end;


 {-----------------------------------------------------------------------------}

  procedure ReadSettings;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optHistoryFolder := RegQueryStr(vKey, 'HistoryFolder', optHistoryFolder);
      optHistoryLimit  := RegQueryInt(vKey, 'HistoryLimit', optHistoryLimit);
      optFldExclusions := RegQueryStr(vKey, 'Exclusions', optFldExclusions);
      optEdtExclusions := RegQueryStr(vKey, 'EdtExclusions', optEdtExclusions);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure ReadSetup(const AMode :TString);
  var
    vKey :HKEY;
  begin
    if RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder + StrIf(AMode <> '', '\View\' + AMode, ''), vKey) then begin
      try
        optShowHidden := RegQueryLog(vKey, 'ShowTransit', optShowHidden);
        optHierarchical := RegQueryLog(vKey, 'Hierarchical', optHierarchical);
        Byte(optHierarchyMode) := RegQueryInt(vKey, 'HierarchyMode', Byte(optHierarchyMode));
        optSortMode  := RegQueryInt(vKey, 'SortMode', optSortMode);

        optSeparateName := RegQueryLog(vKey, 'ShowSeparateName', optSeparateName);
        optShowFullPath := RegQueryLog(vKey, 'ShowFullPath', optShowFullPath);
        optShowDate := RegQueryLog(vKey, 'ShowDate', optShowDate);
        optShowHits := RegQueryLog(vKey, 'ShowHits', optShowHits);
        optShowModify := RegQueryLog(vKey, 'ShowModify', optShowModify);
        optShowSaves := RegQueryLog(vKey, 'ShowSaves', optShowSaves);
      finally
        RegCloseKey(vKey);
      end;
    end;

    if RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then begin
      try
        optShowGrid := RegQueryLog(vKey, 'ShowGrid', optShowGrid);
        optShowHints := RegQueryLog(vKey, 'ShowHints', optShowHints);
        optFollowMouse := RegQueryLog(vKey, 'FollowMouse', optFollowMouse);
        optWrapMode := RegQueryLog(vKey, 'WrapMode', optWrapMode);
        optNewAtTop := RegQueryLog(vKey, 'NewAtTop', optNewAtTop);
        optHideCurrent := RegQueryLog(vKey, 'HideCurrent', optHideCurrent);
        optXLatMask := RegQueryLog(vKey, 'XLatMask', optXLatMask);
        optSaveMask := RegQueryLog(vKey, 'SaveMask', optSaveMask);

        optMidnightHour := RegQueryInt(vKey, 'MidnightHour', optMidnightHour);

        optHiddenColor := RegQueryInt(vKey, 'HiddenColor', optHiddenColor);
        optFoundColor := RegQueryInt(vKey, 'FoundColor', optFoundColor);
        optSelectedColor := RegQueryInt(vKey, 'SelectedColor', optSelectedColor);
        optGroupColor := RegQueryInt(vKey, 'GroupColor', optGroupColor);

      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure WriteSetup(const AMode :TString);
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder + StrIf(AMode <> '', '\View\' + AMode, ''), vKey);
    try
      RegWriteLog(vKey, 'ShowTransit', optShowHidden);
      RegWriteLog(vKey, 'Hierarchical', optHierarchical);
      RegWriteInt(vKey, 'HierarchyMode', Byte(optHierarchyMode));
      RegWriteInt(vKey, 'SortMode', optSortMode);

      RegWriteLog(vKey, 'ShowSeparateName', optSeparateName);
      RegWriteLog(vKey, 'ShowFullPath', optShowFullPath);
      RegWriteLog(vKey, 'ShowDate', optShowDate);
      RegWriteLog(vKey, 'ShowHits', optShowHits);
      RegWriteLog(vKey, 'ShowModify', optShowModify);
      RegWriteLog(vKey, 'ShowSaves', optShowSaves);
    finally
      RegCloseKey(vKey);
    end;

    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'ShowGrid', optShowGrid);
      RegWriteLog(vKey, 'ShowHints', optShowHints);
      RegWriteLog(vKey, 'FollowMouse', optFollowMouse);
      RegWriteLog(vKey, 'WrapMode', optWrapMode);
      RegWriteLog(vKey, 'NewAtTop', optNewAtTop);
      RegWriteLog(vKey, 'HideCurrent', optHideCurrent);
      RegWriteLog(vKey, 'XLatMask', optXLatMask);
      RegWriteLog(vKey, 'SaveMask', optSaveMask);

      RegWriteInt(vKey, 'HiddenColor', optHiddenColor);
      RegWriteInt(vKey, 'GroupColor', optGroupColor);
      RegWriteInt(vKey, 'FoundColor', optFoundColor);
      RegWriteInt(vKey, 'SelectedColor', optSelectedColor);

      RegWriteStr(vKey, 'Exclusions', optFldExclusions);
      RegWriteStr(vKey, 'EdtExclusions', optEdtExclusions);

    finally
      RegCloseKey(vKey);
    end;
  end;


 {-----------------------------------------------------------------------------}

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


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


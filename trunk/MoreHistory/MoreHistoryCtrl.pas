{$I Defines.inc}

unit MoreHistoryCtrl;

{******************************************************************************}
{* (c) 2009-2011, Max Rusov                                                   *}
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
    MixFormat,

    Far_API,
    FarCtrl,
    FarConfig,
    FarMenu,
    FarColorDlg;


  type
    TMessages = (
      strLang,

      strTitle,
      strError,

      strOk,
      strCancel,

      strMFoldersHistory,
      strMActFoldersHistory,
      strMViewEditHistory,
      strMModifyHistory,
      strMCommandHistory,
      strMPreviousCommand,
      strMNextCommand,
      strMOptions1,

      strFoldersHistoryTitle,
      strActFoldersHistoryTitle,
      strViewEditHistoryTitle,
      strModifyHistoryTitle,
      strCommandHistoryTitle,

      strConfirmation,
      strDeleteSelectedPrompt,
      strClearSelectedPrompt,
      strMakeTransitPrompt,
      strMakeActualPrompt,

      strFileNotFound,
      strFolderNotFound,
      strNearestFolderIs,
      strCreateFileBut,
      strCreateFolderBut,
      strGotoNearestBut,
      strDeleteBut,

      strHintPath,
      strHintFTP,
      strHintPrefix,
      strHintAccessTime,
      strHintActionTime,
      strHintAccessCount,
      strHintActionCount,

      strHintFile,
      strHintFolder,
      strHintLastOpen,
      strHintLastSave,

      strHintCommand,
      strHintLastRun,
      strHintRunCount,

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
      strMGroupBy,
      strMShowUnavail,
      strMShowViewed,
      strMSeparateName,

      strMFullPath,
      strMAccessTime,
      strMHitCount,
      strMOpenCount,
      strMActionTime,
      strMModifyTime,
      strMActionCount,
      strMSaveCount,
      strMSortBy,

      strOptionsTitle2,
      strMGeneralOptions,
      strMFldExclusions,
      strMEdtExclusions,
      strMCmdExclusions,
      strMColors,

      strColorsTitle,
      strMHiddenColor,
      strMGroupColor,
      strMGroupCountColor,
      strMQuickFilter,
      strMSelectedColor,
      strMUnavailColor,
      strMRestoreDefaults,

      strSortByTitle,
      strMByName,
      strMByAccessTime,
      strMByHitCount,
      strMByActionTime,
      strMByModifyTime,
      strMByActionCount,
      strMBySaveCount,
      strMUnsorted,

      strGroupByTitle,
      strMGroupByPeriod,
      strMGroupByDate,
      strMGroupByFolder,
      strMGroupNone,

      strGeneralOptionsTitle,
      strHistoryLimit,
      strHideCurrent,
      strCaseSensCmdHist,
      strExcludeFilesCmdHist,

      strWrapMode,
      strFollowMouse,
      strShowHints,
      strHighlightUnavail,

      strFilterByWord,
      strAutoXLatMask,
      strRememberLastMask,
      
      strMidnightHour,
      strValidRangeError,

      strFilterTitle,
      strFilterPrompt,

      strFldExclTitle,
      strEdtExclTitle,
      strCmdExclTitle,
      strExclPrompt,

      strToday,
      strYesterday,
      strThisWeek,
      strThisMonth,
      strThisYear,
      strPastYears,
      strFuture,
      strNever,
      strDaysAgo,
      strDaysForward,
      strDays1,
      strDays2,
      strDays5,
      strDays21,

      strCannotCreateFolder,

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
    cFldHistFileName  = 'Folders2.dat';
    cFldHistFileName1 = 'Folders.dat';
    cEdtHistFileName  = 'Editors.dat';
   {$ifdef bCmdHistory}
    cCmdHistFileName  = 'Commands.dat';
   {$endif bCmdHistory}

    cSignature :array[0..3] of AnsiChar = 'MHSF';
//  cFldVersion   = 1;
    cFldVersion   = 2;  { +FActTime }
//  cEdtVersion   = 2;  { +FSaveCount }
    cEdtVersion   = 3;  { +FModCol }
   {$ifdef bCmdHistory}
    cCmdVersion   = 1;
   {$endif bCmdHistory}

    cMinHistoryLimit  = 64;
    cMaxHistoryLimit  = 9999;
    cDefHistoryLimit  = 1000;

    cHilterHistName = 'MoreHistory.Filter';

   {$ifdef bUnicodeFar}
    chrHiddenMark   = #$2022;
    chrMoreFilter   = #$25BA;
   {$else}
    chrHiddenMark   = #$07;
    chrMoreFilter   = #$10;
   {$endif bUnicodeFar}


  const
    hfFinal_Old = $00000001;
    hfEdit      = $00000001;
    hfDeleted   = $80000000;

  type
    THierarchyMode = (
      hmPeriod,
      hmDate,
      hmDomain
//    hmDateDomain
//    hmDomainDate
//    hmModDate
    );

  var
    { Настройки, зависящие от режима}
    optShowUnavail     :Boolean = True;   { Показывать недоступные файлы/каталоги }
    optShowView        :Boolean = False;  { Показывать просматриваемые файлы }
    optHierarchical    :Boolean = True;   { Иерархическое представление (зависит от упорядочивания) }
    optSortMode        :Integer = 0;      {}

    optSeparateName    :Boolean = True;   { Показывать раздельно имя файла и путь }
    optShowFullPath    :Boolean = True;   { Показывать полный путь }
    optShowDate        :Boolean = True;   { Показывать дату обращения }
    optShowHits        :Boolean = False;  { Показывать количество обращений }
    optShowModify      :Boolean = True;   { Показывать дату модификации }
    optShowSaves       :Boolean = False;  { Показывать количество сохранений }

    { Настройки, не зависящие от режима}
    optShowGrid        :Boolean = False;
    optNewAtTop        :Boolean = True;
    optHideCurrent     :Boolean = True;   { Скпывать текущую папку в истории папок }
    optHilightUnavail  :Boolean = True;   { Подсвечивать недоступные пути }

    optShowHints       :Boolean = True;   { Показывать подсказки через FarHints }
    optFollowMouse     :Boolean = False;  { Курсор бегает за мышкой (как в меню) }
    optWrapMode        :Boolean = False;  { Курсор бегает по кругу }
    optXLatMask        :Boolean = True;   { Автоматическое XLAT преобразование при поиске }
    optMaskByWord      :Boolean = True;   { Поиск с начала слов }
    optSaveMask        :Boolean = False;  { Сохранение старой маски при повторном вызове плагина }

    optMidnightHour    :Integer = 0;      { Время (час), начала нового дня (для группировки по времени) }
    optDateFormat      :Integer = 0;
    opdGroupByPeriod   :Boolean = True;   { Группировка по времени - по периодам (сегодня, вчера ... ), а не по датам }

    optHistoryFolder   :TString = '';
    optHistoryLimit    :Integer = cDefHistoryLimit;
//  optSkipTransit     :Boolean = True;
    optSkipQuickView   :Boolean = True;
    optCaseSensCmdHist :Integer = 0;      { Регистро-чувствительная история команд (2 - только аргументы)}
    optCmdExcludeFile  :Boolean = False;  { Исключать из истории файлы, запускаемые по ассоциации }

    optFldExclusions   :TString = '';
    optEdtExclusions   :TString = '%TEMP%\*';
    optCmdExclusions   :TString = '';

    optHiddenColor     :TFarColor;
    optUnavailColor    :TFarColor;
    optFoundColor      :TFarColor;
    optSelectedColor   :TFarColor;
    optGroupColor      :TFarColor;
    optCountColor      :TFarColor;

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

  function DayOfWeek(ADateTime :TDateTime) :Integer;
  function FirstDayOfMonth(ADateTime :TDateTime) :TDateTime;
  function FileTimeToDateTime(const AFileTime :TFileTime) :TDateTime;
  procedure InsertText(const AStr :TString);
  function GetNearestExistFolder(const APath :TString) :TString;
  function CreateFolders(const APath :TString) :Boolean;

  procedure RestoreDefColor;
  procedure ColorMenu;
  procedure ReadSettings;
  procedure ReadSetup(const AMode :TString);
  procedure WriteSetup(const AMode :TString);
//procedure ChangedSettings;

  function GetHistoryList(const AHistName :TString) :TStrList;
(*rocedure AddToHistory(const AHist, AStr :TString); *)

  
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

  function DayOfWeek(ADateTime :TDateTime) :Integer;
  begin
    Result := (Trunc(ADateTime) + DateDelta - 1) mod 7 + 1;
  end;


  function FirstDayOfMonth(ADateTime :TDateTime) :TDateTime;
  var
    vYear, vMonth, vDay :Word;
  begin
    DecodeDate(ADateTime, vYear, vMonth, vDay);
    Result := EncodeDate(vYear, vMonth, 1);
  end;


  function FileTimeToDateTime(const AFileTime :TFileTime) :TDateTime;
  var
    vDosTime :Integer;
  begin
    Result := 0;
    vDosTime := FileTimeToDosFileDate(AFileTime);
    if vDosTime <> -1 then
      Result := FileDateToDateTime(vDosTime);
  end;


  procedure InsertText(const AStr :TString);
  var
    vStr :TString;
  begin
    vStr := 'print("' + FarMaskStr(AStr) + '")';
    FarPostMacro(vStr);
  end;


  function GetNearestExistFolder(const APath :TString) :TString;
  var
    vDrive, vPath :TString;
  begin
    Result := '';
    if FileNameIsLocal(APath) then begin
      vDrive := AddBackSlash(ExtractFileDrive(APath));
      if WinFolderExists(vDrive) then begin
        vPath := RemoveBackSlash(APath);
        while Length(vPath) > 3 do begin
          if WinFolderExists(vPath) then begin
            Result := vPath;
            Exit;
          end;
          vPath := RemoveBackSlash(ExtractFilePath(vPath));
        end;
        Result := vDrive;
      end;
    end;
  end;

  
  function CreateFolders(const APath :TString) :Boolean;
  var
    vDrive :TString;

    function LocCreate(const APath :TString) :Boolean;
    begin
      Result := True;
      if (APath = '') or (vDrive = APath) or WinFolderExists(APath) then
        Exit;
      Result := LocCreate(RemoveBackSlash(ExtractFilePath(APath)));
      if Result then
        Result := CreateDir(APath);
    end;

  begin
    Result := False;
    vDrive := ExtractFileDrive(APath);
    if FileNameIsLocal(APath) then
      vDrive := AddBackSlash(vDrive);
    if (vDrive = '') or WinFolderExists(vDrive) then
      Result := LocCreate(APath);
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optHiddenColor     := MakeColor(clGray, 0);
    optUnavailColor    := MakeColor(clRed, 0);
    optFoundColor      := MakeColor(clLime, 0);
    optSelectedColor   := MakeColor(0, clGreen);

    optGroupColor      := MakeColor(clBlue, 0);
    optCountColor      := MakeColor(clGray, 0);
  end;


  procedure ColorMenu;
  var
    vMenu :TFarMenu;
    vBkColor :DWORD;
    vOk, vChanged :Boolean;
  begin
    vBkColor := GetColorBG(FarGetColor(COL_MENUTEXT));

    vMenu := TFarMenu.CreateEx(
      GetMsg(strColorsTitle),
    [
      GetMsg(strMHiddenColor),
      GetMsg(strMGroupColor),
      GetMsg(strMGroupCountColor),
      GetMsg(strMQuickFilter),
      GetMsg(strMSelectedColor),
      GetMsg(strMUnavailColor),
      '',
      GetMsg(strMRestoreDefaults)
    ]);
    try
      vChanged := False;

      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0: vOk := ColorDlg('', optHiddenColor, vBkColor);
          1: vOk := ColorDlg('', optGroupColor, vBkColor);
          2: vOk := ColorDlg('', optCountColor, vBkColor);
          3: vOk := ColorDlg('', optFoundColor, vBkColor);
          4: vOk := ColorDlg('', optSelectedColor);
          5: vOk := ColorDlg('', optUnavailColor, vBkColor);
        else
          RestoreDefColor;
          vOk := True;
        end;

        if vOk then begin
//        FARAPI.EditorControl(ECTL_REDRAW, nil);
          FarAdvControl(ACTL_REDRAWALL, nil);
          vChanged := True;
        end;
      end;

      if vChanged then
        WriteSetup('');

    finally
      FreeObj(vMenu);
    end;
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
          StrValue('CmdExclusions', optCmdExclusions);
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
          LogValue('NewAtTop', optNewAtTop);
          LogValue('HideCurrent', optHideCurrent);
          LogValue('HilightUnavail', optHilightUnavail);

          LogValue('ShowHints', optShowHints);
          LogValue('FollowMouse', optFollowMouse);
          LogValue('WrapMode', optWrapMode);
          LogValue('XLatMask', optXLatMask);
          LogValue('MaskByWord', optMaskByWord);
          LogValue('SaveMask', optSaveMask);

          IntValue('MidnightHour', optMidnightHour);
          IntValue('CaseSensCmdHist', optCaseSensCmdHist);
          LogValue('CmdExcludeFiles', optCmdExcludeFile);

          ColorValue('HiddenColor', optHiddenColor);
          ColorValue('UnavailColor', optUnavailColor);
          ColorValue('FoundColor', optFoundColor);
          ColorValue('SelectedColor', optSelectedColor);
          ColorValue('GroupColor', optGroupColor);
          ColorValue('CountColor', optCountColor);

          if AStore then begin
//          StrValue('HistoryFolder', optHistoryFolder);
            IntValue('HistoryLimit', optHistoryLimit);
            StrValue('Exclusions', optFldExclusions);
            StrValue('EdtExclusions', optEdtExclusions);
            StrValue('CmdExclusions', optCmdExclusions);
          end;

          if (AMode <> '') and OpenKey('View\' + AMode) then begin

            LogValue('ShowUnavail', optShowUnavail);
            LogValue('ShowView', optShowView);
            LogValue('Hierarchical', optHierarchical);
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

(*
  procedure AddToHistory(const AHist, AStr :TString);
  begin
    {!!!}
  end;
*)

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

(*
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
*)
 {$endif Far3}


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.



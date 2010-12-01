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
    FarMenu,
    FarColorDlg;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strAllHist,
      strFoldersHist,
      strRegistryHist,
      strFTPHist,

      strListTitle,

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
      strMShowHidden,
      strMGroupBy,
      strMAccessTime,
      strMHitCount,
      strMSortBy,
      strMOptions,

      strOptionsTitle,
      strMShowHints,
      strMFollowMouse,
      strMWrapMode,
      strMHideCurrent,
      strMAutoXLatMask,
      strMRememberLastMask,
      strMExclusions,
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
      strMUnsorted,

      strFilterTitle,
      strFilterPrompt,

      strExclTitle,
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
    cPlugRegFolder  = 'MoreHistory';
    cPluginFolder   = 'MoreHistory';
    cHistFileName   = 'Folders.dat';
    cBackupFileName = 'Folders.~dat';
    cTempFileName   = 'Folders.$$$';

    cSignature :array[0..3] of AnsiChar = 'MHSF';
    cVersion   :Byte = 1;

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
    hfDeleted = $80000000;

  type
    THierarchyMode = (
      hmDate,
      hmDomain
//    hmDateDomain
//    hmDomainDate
    );

  var
    optShowHidden      :Boolean = False;
    optHierarchical    :Boolean = True;
    optHierarchyMode   :THierarchyMode = hmDate;

    optShowDate        :Boolean = True;
    optShowHits        :Boolean = False;
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

    optSortMode        :Integer = 0;

    optHistoryFolder   :TString = '';
    optHistoryLimit    :Integer = 1000;
    optSkipTransit     :Boolean = True;

    optExclusions      :TString = '';

    MoreHistoryPrefix  :TFarStr = 'mh';

    optHiddenColor     :Integer;
    optFoundColor      :Integer;
    optSelectedColor   :Integer;
    optGroupColor      :Integer;


  var
    FRegRoot  :TString;

  var
    FLastFilter :TString;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

  procedure RestoreDefColor;
  procedure ReadSettings;
  procedure ReadSetup(const AMode :TString);
  procedure WriteSetup(const AMode :TString);

  function GetHistoryList(const AHistName :TString) :TStrList;
  procedure AddToHistory(const AHist, AStr :TString);

  procedure OptionsMenu;

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

 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optHiddenColor     := clGray;
    optGroupColor      := clBlue;
    optFoundColor      := clLime;
    optSelectedColor   := clBkGreen;
  end;


  procedure ColorMenu;
  var
    vMenu :TFarMenu;
    vBkColor :Integer;
  begin
    vBkColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

    vMenu := TFarMenu.CreateEx(
      GetMsg(strColorsTitle),
    [
      GetMsg(strMHiddenColor),
      GetMsg(strMGroupColor),
      GetMsg(strMQuickFilter),
      GetMsg(strMSelectedColor),
      '',
      GetMsg(strMRestoreDefaults)
    ]);
    try
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ColorDlg('', optHiddenColor, vBkColor);
          1: ColorDlg('', optGroupColor, vBkColor);
          2: ColorDlg('', optFoundColor, vBkColor);
          3: ColorDlg('', optSelectedColor);

          5: RestoreDefColor;
        end;

//      FARAPI.EditorControl(ECTL_REDRAW, nil);
        FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);

        WriteSetup('');
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCommandsTitle),
    [
      GetMsg(strMShowHints),
      GetMsg(strMFollowMouse),
      GetMsg(strMWrapMode),
      GetMsg(strMHideCurrent),
      GetMsg(strMAutoXLatMask),
      GetMsg(strMRememberLastMask),
      '',
      GetMsg(strMExclusions),
      GetMsg(strMColors)
    ]);
    try
      vMenu.Help := 'Options';
      while True do begin
        vMenu.Checked[0] := optShowHints;
        vMenu.Checked[1] := optFollowMouse;
        vMenu.Checked[2] := optWrapMode;
        vMenu.Checked[3] := optHideCurrent;
        vMenu.Checked[4] := optXLatMask;
        vMenu.Checked[5] := optSaveMask;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: optShowHints := not optShowHints;
          1: optFollowMouse := not optFollowMouse;
          2: optWrapMode := not optWrapMode;
          3: optHideCurrent := not optHideCurrent;
          4: optXLatMask := not optXLatMask;
          5: optSaveMask := not optSaveMask;

          7: FarInputBox(GetMsg(strExclTitle), GetMsg(strExclPrompt), optExclusions);
          8: ColorMenu;
        end;

        WriteSetup('');
      end;

    finally
      FreeObj(vMenu);
    end;
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
      optExclusions    := RegQueryStr(vKey, 'Exclusions', optExclusions);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure ReadSetup(const AMode :TString);
  var
    vKey :HKEY;
  begin
    optShowHidden := False;
    optHierarchical := True;
    if (AMode = '') or StrEqual(AMode, 'Folders') then
      optHierarchyMode := hmDate
    else
      optHierarchyMode := hmDomain;

    if RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder + StrIf(AMode <> '', '\View\' + AMode, ''), vKey) then begin
      try
        optShowHidden := RegQueryLog(vKey, 'ShowTransit', optShowHidden);
        optHierarchical := RegQueryLog(vKey, 'Hierarchical', optHierarchical);
        Byte(optHierarchyMode) := RegQueryInt(vKey, 'HierarchyMode', Byte(optHierarchyMode));
//      PluginSortMode     := RegQueryInt(vKey, 'SortMode', PluginSortMode);
      finally
        RegCloseKey(vKey);
      end;
    end;

    if RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then begin
      try
        optShowDate := RegQueryLog(vKey, 'ShowDate', optShowDate);
        optShowHits := RegQueryLog(vKey, 'ShowHits', optShowHits);
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
//    RegWriteInt(vKey, 'SortMode', PluginSortMode);
    finally
      RegCloseKey(vKey);
    end;

    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'ShowDate', optShowDate);
      RegWriteLog(vKey, 'ShowHits', optShowHits);
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

      RegWriteStr(vKey, 'Exclusions', optExclusions);

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


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
    FarCtrl,
    FarMatch;


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

      strOptionsTitle,
      strMShowHidden,
      strMGroupBy,
      strMAccessTime,
      strMHitCount,
      strMSortBy,
      strMShowHints,
      strMFollowMouse,
      strMWrapMode,
      strMHideCurrent,

      strSortByTitle,
      strMByName,
      strMByAccessTime,
      strMByHitCount,
      strMUnsorted,

      strToday,
      strYesterday,
      strDaysAgo,
      strDays1,
      strDays2,
      strDays5,
      strDays21
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

    optMidnightHour    :Integer = 0;
    optDateFormat      :Integer = 0;

    optSortMode        :Integer = 0;

    optHistoryFolder   :TString = '';
    optHistoryLimit    :Integer = 1000;
    optSkipTransit     :Boolean = True;

    optExclusions      :TString = '';

    MoreHistoryPrefix  :TFarStr = 'mh';

    optHiddenColor     :Integer = 0;
    optFoundColor      :Integer = $0A;
    optSelectedColor   :Integer = $20;
    optGroupColor      :Integer = $0B; //???


  var
    FRegRoot  :TString;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

  procedure CopyToClipboard(const AStr :TString);

  procedure ReadSettings;

  procedure ReadSetup(const AMode :TString);
  procedure WriteSetup(const AMode :TString);

  function GetHistoryList(const AHistName :TString) :TStrList;
  procedure AddStrInHistory(const AHistName, AStr :TString);


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

  procedure CopyToClipboard(const AStr :TString);
 {$ifdef bUnicodeFar}
  begin
    FARSTD.CopyToClipboard(PTChar(AStr));
 {$else}
  var
    vStr :TFarStr;
  begin
    vStr := StrAnsiToOEM(AStr);
    FARSTD.CopyToClipboard(PFarChar(vStr));
 {$endif bUnicodeFar}
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

    finally
      RegCloseKey(vKey);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GetHistoryList(const AHistName :TString) :TStrList;
  var
    I :Integer;
    vKey: HKEY;
    vName, vStr :TString;
  begin
    Result := TStrList.Create;

    vName := cDlgHistRegRoot + '\' + AHistName;
    if RegOpenRead(HKCU, vName, vKey) then begin
      try
        I := 0;
        while True do begin
          vStr := RegQueryStr(vKey, 'Line' + Int2Str(I), '');
          if vStr = '' then
            Exit;
          Result.Add( vStr );
          Inc(I);
        end;
      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure WriteHistoryList(const AHistName :TString; AList :TStrList);
  var
    I :Integer;
    vKey: HKEY;
    vName :TString;
  begin
    vName := cDlgHistRegRoot + '\' + AHistName;
    RegOpenWrite(HKCU, vName, vKey);
    try
      for I := 0 to AList.Count - 1 do
        RegWriteStr(vKey, 'Line' + Int2Str(I), AList[I]);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure AddStrInHistory(const AHistName, AStr :TString);
  var
    I, vLimit :Integer;
    vList :TStrList;
  begin
    vList := GetHistoryList(AHistName);
    try
      vLimit := RegGetIntValue(HKCU, cDlgHistRegRoot, 'HistoryCount', cDefHistoryLength);

      I := vList.IndexOf(AStr);
      if I = -1 then begin
        vList.Insert(0, AStr);
        if vList.Count > vLimit then
          vList.Delete(vList.Count - 1);
      end else
        vList.Move(I, 0);
      WriteHistoryList(AHistName, vList);
    finally
      FreeObj(vList);
    end;
  end;


end.


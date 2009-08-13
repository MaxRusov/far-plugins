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
    FarCtrl,
    FarMatch;


  const
    strLang                 = 0;
    strTitle                = 1;
    strError                = 2;

    strAllHist              = 3;
    strFoldersHist          = 4;
    strRegistryHist         = 5;
    strFTPHist              = 6;

    strListTitle            = 7;

    strConfirmation         = 8;
    strDeleteSelectedPrompt = 9;
    strClearSelectedPrompt  = 10;
    strMakeTransitPrompt    = 11;
    strMakeActualPrompt     = 12;

    strHintPath             = 13;
    strHintFTP              = 14;
    strHintPrefix           = 15;
    strHintLastVisited      = 16;
    strHintVisitCount       = 17;


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

  var
    optNewAtTop        :Boolean = True;
    optShowHidden      :Boolean = False;
    optHierarchical    :Boolean = True;

    optShowDate        :Boolean = True;
    optShowHits        :Boolean = False;
    optShowGrid        :Boolean = False;
    optShowHints       :Boolean = True;

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
    optGroupColor      :Integer = 0;


  var
    FRegRoot  :TString;


  procedure CopyToClipboard(const AStr :TString);

  procedure ReadSettings;

  procedure ReadSetup;
  procedure WriteSetup;

  function GetHistoryList(const AHistName :TString) :TStrList;
  procedure AddStrInHistory(const AHistName, AStr :TString);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


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


  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optNewAtTop := RegQueryLog(vKey, 'NewAtTop', optNewAtTop);

      optShowHidden := RegQueryLog(vKey, 'ShowTransit', optShowHidden);
      optHierarchical := RegQueryLog(vKey, 'Hierarchical', optHierarchical);

      optShowDate  := RegQueryLog(vKey, 'ShowDate', optShowDate);
      optShowHits  := RegQueryLog(vKey, 'ShowHits', optShowHits);
      optShowGrid  := RegQueryLog(vKey, 'ShowGrid', optShowGrid);
      optShowHints := RegQueryLog(vKey, 'ShowHints', optShowHints);

//    PluginSortMode     := RegQueryInt(vKey, 'SortMode', PluginSortMode);

      optHiddenColor := RegQueryInt(vKey, 'HiddenColor', optHiddenColor);
      optFoundColor := RegQueryInt(vKey, 'FoundColor', optFoundColor);
      optSelectedColor := RegQueryInt(vKey, 'SelectedColor', optSelectedColor);
      optGroupColor := RegQueryInt(vKey, 'GroupColor', optGroupColor);

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
      RegWriteLog(vKey, 'NewAtTop', optNewAtTop);

      RegWriteLog(vKey, 'ShowTransit', optShowHidden);
      RegWriteLog(vKey, 'Hierarchical', optHierarchical);

      RegWriteLog(vKey, 'ShowDate', optShowDate);
      RegWriteLog(vKey, 'ShowHits', optShowHits);
      RegWriteLog(vKey, 'ShowGrid', optShowGrid);
      RegWriteLog(vKey, 'ShowHints', optShowHints);

//    RegWriteInt(vKey, 'SortMode', PluginSortMode);

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


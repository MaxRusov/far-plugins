{$I Defines.inc}

unit EdtFindCtrl;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    PluginW,
    FarColorW,
    FarCtrl,
    FarMatch;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMFind,
      strMFindAt,
      strMReplace,
      strMReplaceAt,
      strMFindNext,
      strMFindPrev,
      strMFindWordNext,
      strMFindWordPrev,
      strMFindPickWord,
      strMOptions,

      strSearchFor,
      strReplaceWith,
      strCaseSens,
      strWholeWords,
      strRegExp,
      strPromptOnReplace,
      strSearchBut,
      strCancelBut,
      strFromBegBut,
      strOptionsBut,

      strMSelectFound,
      strMCursorAtEnd,
      strMCenterAlways,
      strMLoopSearch,
      strMShowAllFound,
      strMShowProgress,
      strMGroupUndo,
      strMFoundColor,
      strMMatchColor,

      strFind,
      strReplace,
      strFindFor,
      strFoundReplaced,
      strNotFound,
      strBadRegexp,

      strConfirm,
      strReplaceWith1,
      strReplaceBut,
      strAllBut,
      strSkipBut,
      strCancelBut1,

      strContinueFromBegin,
      strContinueFromEnd,

      strInterrupt,
      strInterruptPrompt,
      strYes,
      strNo
    );


 {-----------------------------------------------------------------------------}

  const
    cDefaultLang   = 'English';
    cPlugRegFolder = 'EdtFind';

    cPluginGUID    = $444E4645;

    cFindHistory   = 'SearchText';
    cReplHistory   = 'ReplaceText';

  var
    optSelectFound   :Boolean = True;
    optCursorAtEnd   :Boolean = False;
    optCenterAlways  :Boolean = False;
    optLoopSearch    :Boolean = True;
    optShowAllFound  :Boolean = True;
    optShowProgress  :Boolean = True;

    optGroupUndo     :Boolean = True;

    optCurFindColor  :Integer = $2F;
    optMatchColor    :Integer = $F0;

  type
    TFindOption = (
      foRegexp,
      foCaseSensitive,
      foWholeWords,
      foPromptOnReplace
//    foSelectedOnly
    );
    TFindOptions = set of TFindOption;

  var
    gStrFind :TString;
    gStrRepl :TString;
    gOptions :TFindOptions = [foPromptOnReplace];

    gLastIsReplace :Boolean;

  var
    FRegRoot :TString;

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  procedure HandleError(AError :Exception);

  procedure SetFindOptions(var AOptions :TFindOptions; AOption :TFindOption; AOn :Boolean);
  function RegexpQuote(const AExpr :TString) :TString;
  function CheckRegexp(const AStr :TString) :Boolean;

  procedure AddToHistory(const AHist, AStr :TString);
  function GetLastHistory(const AHist :TString) :TString;

  procedure SyncFindStr;

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

  procedure AppErrorID(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;



  procedure HandleError(AError :Exception);
  begin
    ShowMessage('EdtFind', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


  procedure SetFindOptions(var AOptions :TFindOptions; AOption :TFindOption; AOn :Boolean);
  begin
    if AOn then
      Include(AOptions, AOption)
    else
      Exclude(AOptions, AOption)
  end;


  function RegexpQuote(const AExpr :TString) :TString;
  begin
    if (AExpr <> '') and (AExpr[1] <> '/') then
      Result := '/' + AExpr + '/'
    else
      Result := AExpr;
  end;


  function CheckRegexp(const AStr :TString) :Boolean;
  var
    vRegExp :THandle;
    vStr :TString;
  begin
    if FARAPI.RegExpControl(0, RECTL_CREATE, @vRegExp) = 0 then
      Wrong;
    try
      vStr := RegexpQuote(AStr);
      Result := FARAPI.RegExpControl(vRegExp, RECTL_COMPILE, PTChar(vStr)) <> 0;
    finally
      FARAPI.RegExpControl(vRegExp, RECTL_FREE, nil);
    end;
  end;


 {-----------------------------------------------------------------------------}

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

(*
  function DlgGetText(ADlg :THandle; AItemID :Integer) :TFarStr;
  var
    vLen :Integer;
    vData :TFarDialogItemData;
  begin
    Result := '';
    vLen := FARAPI.SendDlgMessage(ADlg, DM_GETTEXTLENGTH, AItemID, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen);
      vData.PtrLength := vLen;
      vData.PtrData := PFarChar(Result);
      FARAPI.SendDlgMessage(ADlg, DM_GETTEXT, AItemID, TIntPtr(@vData));
    end;
  end;


  function GetLastHistory(const AHist :TString) :TString;
  var
    hDlg :THandle;
    vItems :array[0..0] of TFarDialogItem;
  begin
    vItems[0] := NewItemApi(DI_Edit, 0, 0, 5, -1, DIF_HISTORY or DIF_USELASTHISTORY, '', PTChar(AHist) );
    hDlg := FARAPI.DialogInit(hModule, -1, -1, 9, 2, nil, Pointer(@vItems), 1, 0, 0, nil, 0);
    try
      Result := DlgGetText(hDlg, 0);
    finally
      FARAPI.DialogFree(hDlg);
    end;
  end;
*)


  function GetLastHistory(const AHist :TString) :TString;
  var
    vPath, vStr :TString;
    vKey :HKEY;
  begin
    vPath := ExtractFilePath(FRegRoot) + 'SavedDialogHistory\' + AHist;
    if RegOpenRead(HKCU, vPath, vKey) then begin
      try
        vStr := RegQueryStr(vKey, 'Lines', '');
        Result := PTChar(vStr);
      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure SyncFindStr;
  begin
    if gStrFind = '' then
      gStrFind := GetLastHistory(cFindHistory);
  end;


 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      SetFindOptions(gOptions, foCaseSensitive, RegQueryLog(vKey, 'CaseSensitive', foCaseSensitive in gOptions));
      SetFindOptions(gOptions, foWholeWords, RegQueryLog(vKey, 'WholeWords', foWholeWords in gOptions));
      SetFindOptions(gOptions, foRegexp, RegQueryLog(vKey, 'Regexp', foRegexp in gOptions));
      SetFindOptions(gOptions, foPromptOnReplace, RegQueryLog(vKey, 'PromptOnReplace', foPromptOnReplace in gOptions));

      optSelectFound := RegQueryLog(vKey, 'SelectFound', optSelectFound);
      optCursorAtEnd := RegQueryLog(vKey, 'CursorAtEnd', optCursorAtEnd);
      optCenterAlways := RegQueryLog(vKey, 'CenterAlways', optCenterAlways);
      optLoopSearch := RegQueryLog(vKey, 'LoopSearch', optLoopSearch);
      optShowAllFound := RegQueryLog(vKey, 'ShowAllFound', optShowAllFound);
      optShowProgress := RegQueryLog(vKey, 'ShowProgress', optShowProgress);

      optGroupUndo := RegQueryLog(vKey, 'GroupUndo', optGroupUndo);

      optCurFindColor := RegQueryInt(vKey, 'FindColor', optCurFindColor);
      optMatchColor := RegQueryInt(vKey, 'MatchColor', optMatchColor);

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
      RegWriteLog(vKey, 'CaseSensitive', foCaseSensitive in gOptions);
      RegWriteLog(vKey, 'WholeWords', foWholeWords in gOptions);
      RegWriteLog(vKey, 'Regexp', foRegexp in gOptions);
      RegWriteLog(vKey, 'PromptOnReplace', foPromptOnReplace in gOptions);

      RegWriteLog(vKey, 'SelectFound', optSelectFound);
      RegWriteLog(vKey, 'CursorAtEnd', optCursorAtEnd);
      RegWriteLog(vKey, 'CenterAlways', optCenterAlways);
      RegWriteLog(vKey, 'LoopSearch', optLoopSearch);
      RegWriteLog(vKey, 'ShowAllFound', optShowAllFound);
      RegWriteLog(vKey, 'ShowProgress', optShowProgress);

      RegWriteLog(vKey, 'GroupUndo', optGroupUndo);

      RegWriteInt(vKey, 'FindColor', optCurFindColor);
      RegWriteInt(vKey, 'MatchColor', optMatchColor);
    finally
      RegCloseKey(vKey);
    end;
  end;


end.


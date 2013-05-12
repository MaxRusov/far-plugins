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

    Far_API,
    FarCtrl,
    FarMatch,
    FarMenu,
    FarConfig,
    FarColorDlg;


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
      strMFindPickWord,
      strMRemoveHilight,
      strMOptions,

      strSearchFor,
      strReplaceWith,
      strInsRegexp,
      strCaseSens,
      strSubstring,
      strWholeWords,
      strRegExp,
      strReverse,
      strPromptOnReplace,
      strSearchBut,
      strEntireBut,
      strShowAllBut,
      strCountBut,
      strCancelBut,
      strOptionsBut,

      strOptions,
      strMSelectFound,
      strMCursorAtEnd,
      strMCenterAlways,
      strMLoopSearch,
      strMShowAllFound,
      strMPersistMatch,
      strMarkWholeTab,
      strMShowProgress,
      strMGroupUndo,
      strAutoXLATMask,
      strMColors,

      strMShowNumbers,
      strMShowMatches,
      strMTrimSpaces,
      strMAutoSync,
      strMShowHints,

      strSortBy,
      strLineNumber,
      strWholeRow,
      strFoundMatch,
      strFoundMatchNum,

      strMFoundColor,
      strMMatchColor,
      strMSearchResult,
      strMGrepNumColor,
      strMGrepFoundColor,
      strMRestoreDefaults,

      strFind,
      strReplace,
      strFindFor,
      strFoundCount,
      strFoundReplaced,
      strCountResult,
      strNotFound,
      strBadRegexp,

      strSearchResult,

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
      strNo,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,

      strRegexpTitle,
      strRegaexpBase
    );


 {-----------------------------------------------------------------------------}

  const
    cPluginName = 'EdtFind';
    cPluginDescr = 'EdtFind FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{E4ABD267-C2F9-4158-818F-B0E040A2AB9F}';
    cMenuID     :TGUID = '{66E82FF0-8DAA-4504-9745-7690DE0483CB}';
    cConfigID   :TGUID = '{61E52218-E3EC-410A-AEED-BB6B41D7CA90}';
   {$else}
    cPluginID    = $444E4645;
   {$endif Far3}

    cFindDlgID    :TGUID = '{A0562FC4-25FA-48DC-BA5E-48EFA639865F}';
    cReplaceDlgID :TGUID = '{070544C7-E2F6-4E7B-B348-7583685B5647}';
    cGrepDlgID    :TGUID = '{39BE672E-9303-4F06-A38A-ECC35ABD98B6}';

    cFindHistory   = 'SearchText';
    cReplHistory   = 'ReplaceText';
    cFileHistory   = 'Masks';


  var
    optSelectFound    :Boolean = True;
    optCursorAtEnd    :Boolean = False;
    optCenterAlways   :Boolean = False;
    optLoopSearch     :Boolean = True;
    optShowAllFound   :Boolean = True;
    optPersistMatch   :Boolean = False;
    optMarkWholeTab   :Boolean = True;
    optShowProgress   :Boolean = True;
    optNoModalMess    :Boolean = False;
    optGroupUndo      :Boolean = True;

    optGrepShowLines  :Boolean = True;
    optGrepTrimSpaces :Boolean = True;
    oprGrepShowMatch  :Boolean = True;
    optGrepAutoSync   :Boolean = True;
    optGrepShowHints  :Boolean = True;
    optGrepMaximized  :Boolean = False;
    optGrepSortMode   :Integer = 1;

    optXLatMask       :Boolean = True;   { Автоматическое XLAT преобразование при поиске }

    optCurFindColor   :TFarColor;
    optMatchColor     :TFarColor;

    optGrepNumColor   :TFarColor;
    optGrepFoundColor :TFarColor;


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

    gReverse :Boolean;

    gLastIsReplace :Boolean;
    gLastReplEmpty :Boolean;  { Затычка, чтобы диалог замены запоминал пустую строку замены }

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
  procedure InsertText(const AStr :TString);

  procedure RestoreDefColor;
  procedure ColorMenu;

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
    if FarRegExpControl(0, RECTL_CREATE, @vRegExp) = 0 then
      Wrong;
    try
      vStr := RegexpQuote(AStr);
      Result := FarRegExpControl(vRegExp, RECTL_COMPILE, PTChar(vStr)) <> 0;
    finally
      FarRegExpControl(vRegExp, RECTL_FREE, nil);
    end;
  end;


  procedure InsertText(const AStr :TString);
  var
    vStr :TString;
  begin
    vStr := 'print("' + FarMaskStr(AStr) + '")';
    FarPostMacro(vStr);
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optCurFindColor   := MakeColor(clWhite, clGreen);
    optMatchColor     := MakeColor(clBlack, clWhite);
    optGrepNumColor   := MakeColor(clGray, 0);
    optGrepFoundColor := MakeColor(clLime, 0);
  end;


  procedure ColorMenu;
  var
    vMenu :TFarMenu;
    vBkColor :DWORD;
  begin
    vBkColor := GetColorBG(FarGetColor(COL_MENUTEXT));

    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptions),
    [
      GetMsg(strMFoundColor),
      GetMsg(strMMatchColor),
      GetMsg(strMSearchResult),
      GetMsg(strMGrepNumColor),
      GetMsg(strMGrepFoundColor),
      '',
      GetMsg(strMRestoreDefaults)
    ]);
    try
      vMenu.Items[2].Flags := MIF_SEPARATOR;
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ColorDlg('', optCurFindColor);
          1: ColorDlg('', optMatchColor);
          2: {};
          3: ColorDlg('', optGrepNumColor, vBkColor);
          4: ColorDlg('', optGrepFoundColor, vBkColor);
          5: {};
          6: RestoreDefColor;
        end;

//      FARAPI.EditorControl(ECTL_REDRAW, nil);
        FarAdvControl(ACTL_REDRAWALL, nil);

        WriteSetup;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure PluginConfig(AStore :Boolean);
  var
    vConfig :TFarConfig;

    procedure LocOpt(const AName :TString; AOpt :TFindOption);
    var
      vValue :Boolean;
    begin
      vValue := AOpt in gOptions;
      vConfig.LogValue(AName, vValue);
      if not AStore then
        SetFindOptions(gOptions, AOpt, vValue);
    end;

  begin
    vConfig := TFarConfig.CreateEx(AStore, cPluginName);
    try
      with vConfig do begin
        if not Exists then
          Exit;

        LocOpt('CaseSensitive', foCaseSensitive);
        LocOpt('WholeWords', foWholeWords);
        LocOpt('Regexp', foRegexp);
        LocOpt('PromptOnReplace', foPromptOnReplace);

        LogValue('SelectFound', optSelectFound);
        LogValue('CursorAtEnd', optCursorAtEnd);
        LogValue('CenterAlways', optCenterAlways);
        LogValue('LoopSearch', optLoopSearch);
        LogValue('ShowAllFound', optShowAllFound);
        LogValue('PersistentMatches', optPersistMatch);
        LogValue('MarkWholeTab', optMarkWholeTab);
        LogValue('ShowProgress', optShowProgress);

        LogValue('GroupUndo', optGroupUndo);

        LogValue('GrepShowLines', optGrepShowLines);
        LogValue('GrepTrimSpaces', optGrepTrimSpaces);
        LogValue('GrepShowMatch', oprGrepShowMatch);
        LogValue('GrepAutoSync', optGrepAutoSync);
        LogValue('GrepShowHints', optGrepShowHints);
        LogValue('GrepMaximized', optGrepMaximized);

        LogValue('XLatMask', optXLatMask);

        ColorValue('FindColor', optCurFindColor);
        ColorValue('MatchColor', optMatchColor);
        ColorValue('GrepNumColor', optGrepNumColor);
        ColorValue('GrepFoundColor', optGrepFoundColor);
      end;

    finally
      vConfig.Destroy;
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


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


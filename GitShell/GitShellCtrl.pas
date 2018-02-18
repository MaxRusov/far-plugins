{$I Defines.inc}

unit GitShellCtrl;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixFormat,

    Far_API,
    FarCtrl,
    FarMatch,
    FarMenu,
    FarConfig,
    FarColorDlg;


  {$I Lang.inc}  { Lang.templ -> Doc\GitShell_en.lng + Doc\GitShell_ru.lng }

 {-----------------------------------------------------------------------------}

  const
    cPluginName = 'GitShell';
    cPluginDescr = 'GitShell Far plugin';
    cPluginAuthor = 'Max Rusov';

    cPluginPrefix = 'git';

    cPluginID  :TGUID = '{BE0B1498-4234-4BE1-B257-7653CAF4F091}';
    cMenuID    :TGUID = '{0B7813BD-DEC1-4866-B20E-F5C49FF4AFA0}';
    cConfigID  :TGUID = '{00918F72-00F9-421A-988F-6CD9A0F9BD1A}';

    cHistDlgID     :TGUID = '{51ECCEBF-D6F4-4B9F-9DAC-CDF69F74175F}';
    cBranchesDlgID :TGUID = '{6204962D-3F32-4D81-A39C-79D0E9315328}';
    cChangesDlgID  :TGUID = '{5CA77CA6-0BF6-4CE2-985A-452B723B3C7D}';

  const
    cGitRoot = 'GIT:';
    cWorkRoot = 'Work:';
    cTmpFolder = 'FarGitShell';

    cBranchNameHistory = 'GitShell.BranchName';
    cDiffNamesHistory = 'GitShell.DiffNames';
    cCommitMessageHistory = 'GitShell.CommitMessage';

  var
    optHistSortMode  :Integer = 0;

    optShowTitles    :Boolean = True;

    optShowDate      :Integer = 1;
    optShowMessage   :Integer = 1;
    optShowAuthor    :Integer = 1;
    optShowEmail     :Integer = 0;
    optShowID        :Integer = 0;

    optCommitGroups  :boolean = True;

//  optDlgColor      :TFarColor;
//  optCurColor      :TFarColor;

    optTitleColor    :TFarColor;
    optGroupColor    :TFarColor;
    optSelectedColor :TFarColor;
    optFoundColor    :TFarColor;

    optModColor      :TFarColor;
    optAddColor      :TFarColor;
    optDelColor      :TFarColor;

    optXLatMask      :Boolean = True;   { јвтоматическое XLAT преобразование при поиске }

    optDateFmt       :TString = 'dd.MM.yy';
    optTimeFmt       :TString = 'HH:mm';



  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  procedure HandleError(AError :Exception);

  function CommitDateToStr(aDate :TDateTime; aShowTime :Boolean) :TString;

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
    ShowMessage('GitShell', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


  function CommitDateToStr(aDate :TDateTime; aShowTime :Boolean) :TString;
  begin
    Result := FormatDate(optDateFmt, aDate);
    if aShowTime then
      Result := Result + ' ' + FormatTime(optTimeFmt, aDate)
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
//  optDlgColor    := UndefColor;
//  optCurColor    := UndefColor;

//  optHiddenColor   := MakeColor(clGray, 0);
    optFoundColor    := MakeColor(clLime, 0);
    optGroupColor    := MakeColor(clYellow, 0);
    optSelectedColor := UndefColor;

    optModColor      := MakeColor(clMaroon, 0);
    optAddColor      := MakeColor(clLime, 0);
    optDelColor      := MakeColor(clBlue, 0);

    optTitleColor    := UndefColor;
  end;


  procedure PluginConfig(AStore :Boolean);
  var
    vConfig :TFarConfig;
  begin
    vConfig := TFarConfig.CreateEx(AStore, cPluginName);
    try
      with vConfig do begin
        if not Exists then
          Exit;

        IntValue('ShowDate', optShowDate);
        IntValue('ShowMessage', optShowMessage);
        IntValue('ShowAuthor', optShowAuthor);
        IntValue('ShowEmail', optShowEmail);
        IntValue('ShowID', optShowID);

        LogValue('CommitGroups', optCommitGroups);

        ColorValue('TitleColor', optTitleColor);
        ColorValue('GroupColor', optGroupColor);
        ColorValue('SelectedColor', optSelectedColor);
        ColorValue('FoundColor', optFoundColor);
        ColorValue('ModifiedfColor', optModColor);
        ColorValue('AddedColor', optAddColor);
        ColorValue('DeletedColor', optDelColor);
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


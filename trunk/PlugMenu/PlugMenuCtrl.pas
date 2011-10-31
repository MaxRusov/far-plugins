{$I Defines.inc}

unit PlugMenuCtrl;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* PlugMenu Far plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    MixTypes,
    MixUtils,
    MixWinUtils,
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarColor,
    FarCtrl,
    FarConfig,
    FarMenu,
    FarColorDlg;



  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strEditDlgTitle,
      strEditDlgPrompt,
      strHideCommand,

      strUnloadTitle,
      strUnloadPropmt,

      strBadIdea,
      strSelfUnloadHint,

      strFileNotFound,
      strPluginLoadError,
      strPluginUnloadError,

      strOptionsTitle,
      strShowHidden,
      strLoadedMark,
      strAnsiMark,
      strFileName,
      strModificationTime,
      strAccessTime,
      strPluginFlags,
      strSortBy,

      strSortByTitle,
      strSortByName,
      strSortByFileName,
      strSortByModificationTime,
      strSortByAccessTime,
      strSortByPluginFlags,
      strSortByUnsorted,

      strOptionsTitle2,
      strAutoHotkey,
      strShowHints,
      strFollowMouse,
      strWrapMode,
      strColors,

      strColorsTitle,
      strMHiddenColor,
      strMQuickFilter,
      strMRestoreDefaults,

      strPlugInfoTitle,
      strInfoFileName,
      strInfoFolder,
      strInfoModified,
      strInfoDescr,
      strInfoCopyright,
      strInfoVersion,
      strInfoEncoding,
      strInfoFlags,
      strInfoPrefixes,

      strButClose,
      strButProps,

      strLoadDlgTitle,
      strLoadDlgPrompt,
      strButOk,
      strButCancel,
      strButSelect,

      strOpenFileDialog,
      strDialogToolNotInstalled,

      strColorDialog
    );

 {-----------------------------------------------------------------------------}

  const
    cPluginName = 'PlugMenu';
    cPluginDescr = 'Extended Plugin Menu for FAR manager';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID    :TGUID = '{AB9578B3-3107-4E28-BB00-3C13D47382AC}';
    cMenuID      :TGUID = '{FABF7469-F4EC-4BDE-9D27-21AE224B3BF8}';
    cConfigID    :TGUID = '{4C1E461A-1437-4178-8CB9-2F84A39BD63C}';
   {$else}
   {$endif Far3}

    cPlugListID  :TGUID = '{7B1DFACF-37B2-4726-9710-0792822D5AFF}';
    cPlugInfoID  :TGUID = '{A39D546A-9A8F-441D-9627-920DED96BDF6}';
    cPlugEditID  :TGUID = '{A1C05907-9B14-4CCD-B38E-6B5A3E36958B}';

    cPlugMenuPrefix = 'PlugMenu';
    cPlugLoadPrefix = 'PlugLoad';
    cPlugUnloadPrefix = 'PlugUnload';

   {$ifdef Far3}
   {$else}
    cPlugRegFolder = 'PlugMenu';
    cAccessedRegFolder = 'LastAccess';
    cHiddenRegFolder = 'Hidden';

    cRegHotkeyKey = 'PluginHotkeys';
    cRegCacheKey = 'PluginsCache';
    cRegSystemKey = 'System';

    cRegPersPlugPathValue = 'PersonalPluginsPath';

    cRegCacheDllValue = 'Name';
    cRegCacheMenuValue = 'PluginMenuString';
    cRegCacheConfigValue = 'PluginConfigString';

    cUnderscoreCachePath = 'The Underscore\PluginCache';
    cUnderscoreDllValue = 'ModuleName';
    cUnderscoreMenuValue = 'MenuString';
    cUnderscoreConfigValue = 'ConfigString';
   {$endif Far3}


  const
   {$ifdef bUnicode}
    chrHiddenMark       :TChar = #$2022;
    chrUnaccessibleMark :TChar = #9632 { $25AC };
    chrUpMark           :TChar = #$18; { $1E }
    chrDnMark           :TChar = #$19; { $1F }
   {$else}
    chrHiddenMark       :TChar = #$07;
    chrUnaccessibleMark :TChar = #$16;
    chrUpMark           :TChar = #$18; { $1E }
    chrDnMark           :TChar = #$19; { $1F }
   {$endif bUnicode}

    chrLoadedMark       :TChar = '*';
    chrUnregisteredMark :TChar = 'x';

  var
    FModulePath        :TString;
    FFarExePath        :TString;

   {$ifdef Far3}
   {$else}
    FPluginsPath       :TString;
    FAddPluginsPaths   :TString;

    FFarRegRoot        :TString;  { Software\FarX  ���  Software\FarX\Users\��� }
    FRegRoot           :TString;  { Software\FarX\Plugins  ���  Software\FarX\Users\���\Plugins }
    FCacheRoot         :TString;
    FHotkeysRoot       :TString;
    FCacheDllValue     :TString;
    FCacheMenuValue    :TString;
    FCacheConfigValue  :TString;

    FSkipAddPaths      :Boolean;
   {$endif Far3}


  var
    PluginAutoShortcut :Boolean = True;

    PluginShowLoaded   :Boolean = True;
    PluginShowAnsi     :Boolean = True;
    PluginShowFileName :Integer = 0;
    PluginShowFlags    :Boolean = False;
    PluginShowDate     :Integer = 0;
    PluginShowUseDate  :Integer = 0;

    PluginShowHidden   :Integer = 0;

    PluginSortMode     :Integer = 0;
    PluginSortGroup    :Boolean = False;

    optXLatMask        :Boolean = True;   { �������������� XLAT �������������� ��� ������ }
    optShowHints       :Boolean = True;
    optFollowMouse     :Boolean = True;
    optWrapMode        :Boolean = True;

    optHiddenColor     :TFarColor;
    optFoundColor      :TFarColor;
//  optGroupColor      :TFarColor;
//  optSelectedColor   :TFarColor;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  function GUIDToString(const ClassID: TGUID): TString;

  procedure ConfigDlg;
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


 {-----------------------------------------------------------------------------}

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
      GetMsg(strMQuickFilter),
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
          1: vOk := ColorDlg('', optFoundColor, vBkColor);
        else
          RestoreDefColor;
          vOk := True;
        end;

        if vOk then begin
          FarAdvControl(ACTL_REDRAWALL, nil);
          vChanged := True;
        end;
      end;

      if vChanged then
        WriteSetup;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure ConfigDlg;
  var
    vMenu :TFarMenu;
    vChanged :Boolean;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle),
    [
      GetMsg(strAutoHotkey),
      GetMsg(strShowHints),
      GetMsg(strFollowMouse),
      GetMsg(strWrapMode),
      '',
      GetMsg(strColors)
    ]);
    try
      vChanged := False;
      vMenu.Help := 'Options';

      while True do begin
        vMenu.Checked[0] := PluginAutoShortcut;
        vMenu.Checked[1] := optShowHints;
        vMenu.Checked[2] := optFollowMouse;
        vMenu.Checked[3] := optWrapMode;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0: PluginAutoShortcut := not PluginAutoShortcut;
          1: optShowHints := not optShowHints;
          2: optFollowMouse := not optFollowMouse;
          3: optWrapMode := not optWrapMode;

          5: ColorMenu;
        end;

        vChanged := True;
      end;

      if vChanged then
        WriteSetup;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GUIDToString(const ClassID: TGUID): TString;
  var
    P: PWideChar;
  begin
    Result := '';
    if Succeeded(StringFromCLSID(ClassID, P)) then begin
      Result := P;
      CoTaskMemFree(P);
    end;
  end;


  procedure RestoreDefColor;
  begin
//  optHiddenColor := FarGetColor(COL_MENUDISABLEDTEXT);
//  optFoundColor := FarGetColor(COL_MENUHIGHLIGHT);

    optHiddenColor  := MakeColor(clGray, 0);
    optFoundColor   := MakeColor(clLime, 0);
//  optGroupColor   := MakeColor(clBlue, 0);
  end;


  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

//      LogValue('ShowGrid', optShowGrid);

        LogValue('AutoHotkey',  PluginAutoShortcut);
        IntValue('ShowHidden',  PluginShowHidden);

        LogValue('XLatMask',    optXLatMask);
        LogValue('ShowHints',   optShowHints);
        LogValue('FollowMouse', optFollowMouse);
        LogValue('WrapMode',    optWrapMode);

        LogValue('ShowLoadedMark', PluginShowLoaded);
        LogValue('ShowAnsiMark', PluginShowAnsi);

        IntValue('ShowFileName', PluginShowFileName);
        LogValue('ShowFlags', PluginShowFlags);
        IntValue('ShowModifyTime', PluginShowDate);
        IntValue('ShowAccessTime', PluginShowUseDate);

        IntValue('SortMode', PluginSortMode);

        ColorValue('HiddenColor', optHiddenColor);
        ColorValue('FoundColor', optFoundColor);
//      ColorValue('SelectedColor', optSelectedColor);

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


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


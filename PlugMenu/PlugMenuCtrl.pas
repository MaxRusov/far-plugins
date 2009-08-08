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
    MixTypes,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl;


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
      strAutoHotkey,
      strShowHints,
      strFollowMouse,
      strWrapMode,

      StrSortByTitle,
      StrSortByName,
      StrSortByFileName,
      StrSortByModificationTime,
      StrSortByAccessTime,
      StrSortByPluginFlags,
      StrSortByUnsorted,

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
      strDialogToolNotInstalled
    );

 {-----------------------------------------------------------------------------}

  const
    cDefaultLang   = 'English';
    cMenuFileMask  = '*.mnu';

    cPlugMenuPrefix = 'PlugMenu';
   {$ifdef bUnicode}
    cPlugLoadPrefix = 'PlugLoad';
    cPlugUnloadPrefix = 'PlugUnload';
   {$endif bUnicode}

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


  var
    FModulePath       :TString;
    FFarExePath       :TString;
    FPluginsPath      :TString;
    FAddPluginsPaths  :TString;

    FFarRegRoot       :TString;  { Software\FarX  или  Software\FarX\Users\Имя }
    FRegRoot          :TString;  { Software\FarX\Plugins  или  Software\FarX\Users\Имя\Plugins }
    FCacheRoot        :TString;
    FHotkeysRoot      :TString;
    FCacheDllValue    :TString;
    FCacheMenuValue   :TString;
    FCacheConfigValue :TString;

    FSkipAddPaths     :Boolean;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

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

end.


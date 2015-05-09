{$I Defines.inc}

unit FarPlayCtrl;

{******************************************************************************}
{* Noisy - Noisy Player Far plugin                                            *}
{* 2008-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{* Процедуры взаимодействия с плеером                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,

    Far_API,
    FarCtrl;

  const
    cPluginName = 'Noisy';
    cPluginDescr = 'Noisy Player FAR plugin';
    cPluginAuthor = 'Max Rusov';

    cPluginID      :TGUID = '{298208DF-2031-4DD8-A461-E3DD80C72F46}';
    cMenuID        :TGUID = '{2E21B566-8C05-46C4-8B55-9271AEC376F4}';
    cConfigID      :TGUID = '{FAB58FBD-535B-4CE8-A71C-21118D85F3CC}';

    cPlayerDlgID   :TGUID = '{7CD402AF-982E-4396-ACDF-C4F8DF0F34F8}';
    cPlaylistDlgID :TGUID = '{B851CDF7-D364-4C5D-B1FF-AAFEE5FA702D}';

  const
    chrPlay     = '>'; {#$10;}
    chrPause    = '#'; {#$2551;}
    chrStop     = '*'; {#$16;}


  type
    TMessages = (
      strLang,
      strTitle,
      strPlaylistTitle,
      strInfoTitle,

      strTrack,
      strVolume,
      strList,
      strPlay,
      strPause,
      strStop,
      strConfig,
      strAbout,

      strConfigTitle,
      strRepeatMode,
      strSuffleMode,
      strShowIcon,
      strShowTooltips,
      strUseHotkeys,

      strLoadedPlugins,
      strSupportedFormats,

      strOk,
      strFormats,
      strVersions,

      strEmpty,

      strError,
      strFileNotFound,
      strPLaylistIsEmpty,
      strPlayerNotRunning
    );


 {-----------------------------------------------------------------------------}

  const
    cDefaultLang   = 'English';
    cMenuFileMask  = '*.mnu';
    cMenuFileName  = 'Noisy.mnu';

    cFarPlayPrefix = 'np';
    cOpenCmd       = 'Open';
    cAddCmd        = 'Add';
    cPlaylist      = 'Playlist';
    cInfo          = 'Info';
    cAbout         = 'About';

  var
    optFoundColor    :TFarColor;
//  optHiddenColor   :TFarColor;
//  optTitleColor    :TFarColor;

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);

  procedure RestoreDefColor;

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

  procedure RestoreDefColor;
  begin
//  optHiddenColor := MakeColor(clGray, 0);
    optFoundColor  := MakeColor(clLime, 0);
//  optTitleColor  := UndefColor;
  end;


end.


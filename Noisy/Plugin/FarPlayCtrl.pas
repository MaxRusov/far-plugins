{$I Defines.inc}
{$Typedaddress Off}

unit FarPlayCtrl;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{* Процедуры взаимодействия с плеером                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,

    Far_API,
    FarCtrl;


  const
   {$ifdef bUnicodeFar}
    chrPlay     = '>'; {#$10;}
    chrPause    = '#'; {#$2551;}
    chrStop     = '*'; {#$16;}
   {$else}
    chrPlay     = '>'; {#$10;}
    chrPause    = '#'; {#$BA;}
    chrStop     = '*'; {#$16;}
   {$endif bUnicodeFar}


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


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);

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


end.


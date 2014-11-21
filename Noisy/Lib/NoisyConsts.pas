{$I Defines.inc}
{$Typedaddress Off}

unit NoisyConsts;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{******************************************************************************}

interface

  uses
    Windows;


  const
    nSendCmd = $1F2E3D4B;

  const
    WndClassName = 'BASSPLAYERWND@003';
    MutexName = 'BASSPLAYER@003';

    InfoMemName = 'BASSPLAYERINFO@003';
    PlaylistMemName = 'BASSPLAYERPLAYLIST@003';

  const
    cMaxFileSize = 512;
    cMaxTitleSize = 256;
    cMaxPluginNameSize = 64;
    cMaxFormatNameSize = 128;

  type
    TPlayerState = (
      psEmpty,
      psPlayed,
      psPaused,
      psStopped
    );

    TStreamType = (
      stNormal,
      stMusic,
      stStream,
      stShoutcast
    );


  type
    PPlayerInfo = ^TPlayerInfo;
    TPlayerInfo = packed record
      FStructSize   :Integer;
      FBassVersion  :Cardinal;
      FState        :TPlayerState;
      FRepeat       :Boolean;
      FShuffle      :Boolean;
      FSystray      :Boolean;
      FTooltips     :Boolean;
      FHotkeys      :Boolean;
      FPlayedFile   :array[0..cMaxFileSize-1] of WideChar;
      FTrackTitle   :array[0..cMaxTitleSize-1] of WideChar;
      FTrackArtist  :array[0..cMaxTitleSize-1] of WideChar;
      FTrackAlbum   :array[0..cMaxTitleSize-1] of WideChar;
      FTrackCount   :Integer;
      FTrackIndex   :Integer;
      FTrackLength  :Single;
      FTrackBPS     :Integer;
      FTrackFreq    :Integer;
      FTrackChans   :Integer;
      FTrackType    :Integer;
      FTrackBytes   :Integer;
      FTrackLoaded  :Integer;
      FStreamType   :TStreamType;
      FPlayTime     :Single;
      FVolume       :Single;
      FMute         :Boolean;
      FPlaylistRev  :Integer;
      FPlugins      :Integer;
      FFormats      :Integer;
    end;

    PBassPluginInfo = ^TBassPluginInfo;
    TBassPluginInfo = packed record
      FVersion :Cardinal;
      FName    :array[0..cMaxPluginNameSize] of AnsiChar;
    end;

    PAudioFormatInfo = ^TAudioFormatInfo;
    TAudioFormatInfo = packed record
      FCode    :Cardinal;
      FName    :array[0..cMaxFormatNameSize] of AnsiChar;
      FExts    :array[0..cMaxFormatNameSize] of AnsiChar;
    end;


  const
    VK_BROWSER_BACK = 166;
    VK_BROWSER_FORWARD = 167;
    VK_BROWSER_REFRESH = 168;
    VK_BROWSER_STOP = 169;
    VK_BROWSER_SEARCH = 170;
    VK_BROWSER_FAVORITES = 171;
    VK_BROWSER_HOME = 172;
    VK_VOLUME_MUTE = 173;
    VK_VOLUME_DOWN = 174;
    VK_VOLUME_UP = 175;
    VK_MEDIA_NEXT_TRACK = 176;
    VK_MEDIA_PREV_TRACK = 177;
    VK_MEDIA_STOP = 178;
    VK_MEDIA_PLAY_PAUSE = 179;
    VK_LAUNCH_MAIL = 180;
    VK_LAUNCH_MEDIA_SELECT = 181;
    VK_LAUNCH_APP1 = 182;
    VK_LAUNCH_APP2 = 183;


  const
    CmdInfo        = '/Info';
    CmdLock        = '/Lock';
    CmdUnlock      = '/Unlock';
    CmdRepeat      = '/Repeat';
    CmdShuffle     = '/Shuffle';
    CmdSystray     = '/Systray';
    CmdTooltip     = '/Tooltip';
    CmdNoTooltip   = '/NoTooltip';
    CmdAsync       = '/Async';
    CmdHotkeys     = '/Hotkeys';
    CmdNext        = '/Next';
    CmdPrev        = '/Prev';
    CmdStop        = '/Stop';
    CmdPlayPause   = '/PlayPause';
    CmdVolumeDec   = '/Volume=-5';
    CmdVolumeInc   = '/Volume=+5';
    CmdVolumeMute  = '/Mute=5';
    CmdOpen        = '/Open';

    CmdVolume1     = '/Volume=%d';
    CmdSeek1       = '/Seek=%d';
    CmdGoto1       = '/Goto=%d';
    CmdDelete1     = '/Delete=%d';
    CmdMoveTrack1  = '/MoveTrack=%d;%d';

    CmdSafe = CmdAsync + ' ' + CmdNoTooltip;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

end.

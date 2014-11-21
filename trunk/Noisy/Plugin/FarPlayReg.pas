{$I Defines.inc}

unit FarPlayReg;

{******************************************************************************}
{* Noisy - Noisy Player Far plugin                                            *}
{* 2008-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings;


  var
    PlaylistShowNumber   :Boolean  =  True;
    PlaylistShowTitle    :Boolean  =  True;
    PlaylistShowTime     :Boolean  =  True;


  procedure ReadSettings(const APath :TString);
  procedure WriteSettings(const APath :TString);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  procedure ReadSettings(const APath :TString);
(*  var
    vPath :TString;
    vKey :HKEY;
    vPeriodSec :Integer;
  begin
    vPath := RegPath;
    if RegOpenKeyEx(HKEY_CURRENT_USER, PTChar(vPath), 0, KEY_QUERY_VALUE, vKey) <> ERROR_SUCCESS then
      Exit;
    try
      BassPlugins := RegQueryStr(vKey, 'BASSPlugins', '');

      LastRepeat  := RegQueryLog(vKey, 'Repeat',  LastRepeat);
      LastShuffle := RegQueryLog(vKey, 'Shuffle', LastShuffle);
      LastTooltip := RegQueryLog(vKey, 'Tooltip', LastTooltip);
      LastSystray := RegQueryLog(vKey, 'Systray', LastSystray);
      vPeriodSec := RegQueryInt(vKey, 'TooltipPeriod', 0);
      if vPeriodSec <> 0 then
        TooltipPeriod := vPeriodSec * 1000;

      SmoothFadePeriod := RegQueryInt(vKey, 'FadePeriod', SmoothFadePeriod);
      IdleShutdownPeriod := RegQueryInt(vKey, 'IdlePeriod', IdleShutdownPeriod div 1000) * 1000;

      LastVolume := RegQueryInt(vKey, 'Volume', LastVolume);
      LastTrack := RegQueryStr(vKey, 'TrackName', '');
      LastTrackPos := RegQueryInt(vKey, 'TrackPos', 0);

    finally
      RegCloseKey(vKey);
    end;
*)
  begin
    {}
  end;


  procedure WriteSettings(const APath :TString);
(*
  var
    vPath :TString;
    vKey :HKEY;
    vDisposition :Cardinal;
  begin
    vPath := RegPath;
    if RegCreateKeyEx(HKEY_CURRENT_USER, PTChar(vPath), 0, '', REG_OPTION_NON_VOLATILE, KEY_READ or KEY_WRITE, nil, vKey, @vDisposition) <> ERROR_SUCCESS then
      Exit;
    try
      RegStoreLog(vKey, 'Repeat',  LastRepeat);
      RegStoreLog(vKey, 'Shuffle', LastShuffle);
      RegStoreLog(vKey, 'Tooltip', LastTooltip);
      RegStoreLog(vKey, 'Systray', LastSystray);
      RegStoreInt(vKey, 'Volume', LastVolume);
      RegStoreStr(vKey, 'TrackName', LastTrack);
      RegStoreInt(vKey, 'TrackPos', LastTrackPos);
    finally
      RegCloseKey(vKey);
    end;
*)
  begin
    {}
  end;


end.

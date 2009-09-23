{$I Defines.inc}

unit PlayerReg;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Player registry                                                      *}
{******************************************************************************}

interface

  uses
    Windows,
    
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    NoisyConsts,
    NoisyUtil,
    PlayerWin;


  const
    RegPath    = 'Software\Noisy';
    RegHotkeys = 'Hotkeys';

  var
    LastRepeat          :Boolean  = False;
    LastShuffle         :Boolean  = False;
    LastSystray         :Boolean  = True;
    LastTooltip         :Boolean  = True;
    LastHotkeys         :Boolean  = True;
    LastVolume          :Integer  = 100;
    LastBalance         :Integer  = 0;
    LastTrack           :TString  = '';
    LastTrackPos        :Integer  = 0;

    GestrudeEnabled     :Boolean  =  True;

    SmoothFadePeriod    :Integer  =   300;
    StatusUpdatePeriod  :Integer  =  1000;
    PlaylistUpdateDelay :Integer  =    10;   { Период между изменением playlista (добавление/удаление трека) и его публикацией }
    PlaylistInfoDelay   :Integer  =   500;   { Период периодической публикации playlistа во время фонового извлечения тегов }
    IdleShutdownPeriod  :Integer  = 30000;
    TooltipPeriod       :Integer  =  3000;
    ResyncPeriod        :Integer  =   500;   { Задержка синхронизация Shoutcast потока (на всякий случай) }
    AsyncSeekPeriod     :Integer  =   500;   { Задержка при асинхронном Seek'е }

    BassPlugins         :TString  = '';
    HistoryLength       :Integer  = 100;


  procedure ReadSettings;
  procedure WriteSettings;

  function ReadHotkeysFromReg(AList :TStringList) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  procedure ReadSettings;
  var
    vPath :TString;
    vKey :HKEY;
    vPeriodSec :Integer;
  begin
    vPath := RegPath;
    if RegOpenKeyEx(HKEY_CURRENT_USER, PTChar(vPath), 0, KEY_QUERY_VALUE, vKey) <> ERROR_SUCCESS then
      Exit;
    try
      BassPlugins := RegQueryStr(vKey, 'BASSPlugins', '');
      HistoryLength := RegQueryInt(vKey, 'HistoryLength', HistoryLength);

      LastRepeat  := RegQueryLog(vKey, 'Repeat',  LastRepeat);
      LastShuffle := RegQueryLog(vKey, 'Shuffle', LastShuffle);
      LastTooltip := RegQueryLog(vKey, 'Tooltip', LastTooltip);
      LastSystray := RegQueryLog(vKey, 'Systray', LastSystray);
      LastHotkeys := RegQueryLog(vKey, 'Hotkeys', LastHotkeys);
      vPeriodSec := RegQueryInt(vKey, 'TooltipPeriod', 0);
      if vPeriodSec <> 0 then
        TooltipPeriod := vPeriodSec * 1000;

      SmoothFadePeriod := RegQueryInt(vKey, 'FadePeriod', SmoothFadePeriod);
      IdleShutdownPeriod := RegQueryInt(vKey, 'IdlePeriod', IdleShutdownPeriod div 1000) * 1000;

      LastVolume := RegQueryInt(vKey, 'Volume', LastVolume);
      LastBalance := RegQueryInt(vKey, 'Balance', LastBalance);
      LastTrack := RegQueryStr(vKey, 'TrackName', '');
      LastTrackPos := RegQueryInt(vKey, 'TrackPos', 0);

      LastFolder := RegQueryStr(vKey, 'Folder', '');

      DialogRect.Left := RegQueryInt(vKey, 'DlgLeft', 0);
      DialogRect.Top := RegQueryInt(vKey, 'DlgTop', 0);
      DialogRect.Right := RegQueryInt(vKey, 'DlgRight', 0);
      DialogRect.Bottom := RegQueryInt(vKey, 'DlgBottom', 0);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSettings;
  var
    vPath :TString;
    vKey :HKEY;
    vDisposition :Cardinal;
  begin
    vPath := RegPath;
    if RegCreateKeyEx(HKEY_CURRENT_USER, PTChar(vPath), 0, '', REG_OPTION_NON_VOLATILE, KEY_READ or KEY_WRITE, nil, vKey, @vDisposition) <> ERROR_SUCCESS then
      Exit;
    try
      RegWriteLog(vKey, 'Repeat',  LastRepeat);
      RegWriteLog(vKey, 'Shuffle', LastShuffle);
      RegWriteLog(vKey, 'Tooltip', LastTooltip);
      RegWriteLog(vKey, 'Systray', LastSystray);
      RegWriteLog(vKey, 'Hotkeys', LastHotkeys);
      RegWriteInt(vKey, 'Volume', LastVolume);
      RegWriteInt(vKey, 'Balance', LastBalance);
      RegWriteStr(vKey, 'TrackName', LastTrack);
      RegWriteInt(vKey, 'TrackPos', LastTrackPos);

      RegWriteStr(vKey, 'Folder', LastFolder);

      RegWriteInt(vKey, 'DlgLeft', DialogRect.Left);
      RegWriteInt(vKey, 'DlgTop', DialogRect.Top);
      RegWriteInt(vKey, 'DlgRight', DialogRect.Right);
      RegWriteInt(vKey, 'DlgBottom', DialogRect.Bottom);
      
    finally
      RegCloseKey(vKey);
    end;
  end;


  function ReadHotkeysFromReg(AList :TStringList) :Boolean;
  var
    I :Integer;
    vPath :TString;
    vKey :HKEY;
    vHotkey :Integer;
    vCommand :TString;
  begin
    Result := False;
    vPath := RegPath + '\' + RegHotkeys;
    if RegOpenKeyEx(HKEY_CURRENT_USER, PTChar(vPath), 0, KEY_QUERY_VALUE, vKey) <> ERROR_SUCCESS then
      Exit;
    try
      I := 1;
      while True do begin
        vHotkey := RegQueryInt(vKey, 'Hotkey' + Int2Str(I), -1);
        vCommand := RegQueryStr(vKey, 'Command' + Int2Str(I), '');
        if (vHotkey = -1) and (vCommand = '') then
          Break;
        AList.AddObject(vCommand, Pointer(vHotkey));
        Inc(I);
      end;
      Result := True;
    finally
      RegCloseKey(vKey);
    end;
  end;


end.

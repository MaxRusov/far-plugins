{$I Defines.inc}

unit WinNoisyCtrl;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{*                                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    CommCtrl,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    NoisyConsts,
    NoisyUtil;

  const
    RegPath    = 'Software\Noisy\WinNoisy';


  var
    MainWinPos :TPoint;
    PlaylistRect :TRect;
    LastShowPlaylist :Boolean;


  const
    LVS_EX_DOUBLEBUFFER           = $00010000;
    LVS_EX_SINGLEROW              = $00040000;
    LVS_EX_SNAPTOGRID             = $00080000;
    LVS_EX_SIMPLESELECT           = $00100000;
    LVS_EX_JUSTIFYCOLUMNS         = $00200000;
    LVS_EX_TRANSPARENTBKGND       = $00400000;
    LVS_EX_TRANSPARENTSHADOWTEXT  = $00800000;
    LVS_EX_AUTOAUTOARRANGE        = $01000000;
    LVS_EX_HEADERINALLVIEWS       = $02000000;
    LVS_EX_AUTOCHECKSELECT        = $08000000;
    LVS_EX_AUTOSIZECOLUMNS        = $10000000;
    LVS_EX_COLUMNSNAPPOINTS       = $40000000;


  procedure ReadSettings;
  procedure WriteSettings;

  
{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure ReadSettings;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, RegPath, vKey) then
      Exit;
    try
      LastShowPlaylist := RegQueryLog(vKey, 'ShowPlaylist', LastShowPlaylist);

      MainWinPos.X := RegQueryInt(vKey, 'MainWinLeft', 0);
      MainWinPos.Y := RegQueryInt(vKey, 'MainWinTop', 0);

      PlaylistRect.Left   := RegQueryInt(vKey, 'PlaylistLeft',   0);
      PlaylistRect.Top    := RegQueryInt(vKey, 'PlaylistTop',    0);
      PlaylistRect.Right  := RegQueryInt(vKey, 'PlaylistRight',  0);
      PlaylistRect.Bottom := RegQueryInt(vKey, 'PlaylistBottom', 0);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSettings;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, RegPath, vKey);
    try
      RegWriteLog(vKey, 'ShowPlaylist', LastShowPlaylist);

      RegWriteInt(vKey, 'MainWinLeft', MainWinPos.X);
      RegWriteInt(vKey, 'MainWinTop',  MainWinPos.Y);

      RegWriteInt(vKey, 'PlaylistLeft',   PlaylistRect.Left);
      RegWriteInt(vKey, 'PlaylistTop',    PlaylistRect.Top);
      RegWriteInt(vKey, 'PlaylistRight',  PlaylistRect.Right);
      RegWriteInt(vKey, 'PlaylistBottom', PlaylistRect.Bottom);

    finally
      RegCloseKey(vKey);
    end;
  end;


end.

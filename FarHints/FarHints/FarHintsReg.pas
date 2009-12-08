{$I Defines.inc}

unit FarHintsReg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixWinUtils,
    FarHintsConst;


  procedure ReadSetup(const APath :TString);
    { Основные настройки, считываются один раз, при загрузке плагина }
  procedure ReadSettings(const APath :TString);
    { Дополнительные настройки. Считываются перед каждым появлением хинта }
    
  procedure WriteSizeSettings(const APath :TString);
  procedure WriteSomeSettings(const APath :TString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;

 
  procedure ReadSetup(const APath :TString);
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, APath + '\' + RegFolder, vKey) then
      Exit;
    try
      FarHintsEnabled := RegQueryLog(vKey, 'Enabled', FarHintsEnabled);
      FarHintsAutoKey := RegQueryLog(vKey, 'AutoKey', FarHintsAutoKey);
      FarHintsAutoMouse := RegQueryLog(vKey, 'AutoMouse', FarHintsAutoMouse);
      FarHintsInPanel := RegQueryLog(vKey, 'HintInPanel', FarHintsInPanel);
      FarHintsInDialog := RegQueryLog(vKey, 'HintInDialog', FarHintsInDialog);

      ShowHintFirstDelay := RegQueryInt(vKey, 'FirstDelay', ShowHintFirstDelay);
      ShowHintNextDelay := RegQueryInt(vKey, 'NextDelay', ShowHintNextDelay);

      FarHintForceKey := RegQueryInt(vKey, 'ForceKey', FarHintForceKey);

     {$ifdef bSynchroCall}
     {$else}
      FarHintsKey := RegQueryInt(vKey, 'CallKey', FarHintsKey);
      FarHintsShift := RegQueryInt(vKey, 'CallShift', FarHintsShift);
     {$endif bSynchroCall}

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure ReadSettings(const APath :TString);
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, APath + '\' + RegFolder, vKey) then
      Exit;
    try
      FarHintShowIcon := RegQueryLog(vKey, 'ShowIcon', FarHintShowIcon);
      FarHintShowPrompt := RegQueryLog(vKey, 'ShowPrompt', FarHintShowPrompt);

      FarHintUseThumbnail := RegQueryLog(vKey, 'UseThumbnail', FarHintUseThumbnail);
      FarHintIconOnThumb := RegQueryLog(vKey, 'IconOnThumbnail', FarHintIconOnThumb);

      FarHintThumbSize1 := RegQueryInt(vKey, 'MaxThumbnailSize', FarHintThumbSize1);
      FarHintThumbSize2 := RegQueryInt(vKey, 'MaxFolderThumbnailSize', FarHintThumbSize2);

      FarHintsShowPeriod := RegQueryInt(vKey, 'ShowPeriod', FarHintsShowPeriod);
      FarHintSmothSteps := RegQueryInt(vKey, 'SmoothStep', FarHintSmothSteps);

      FarHintColor := RegQueryInt(vKey, 'Color', FarHintColor);
      FarHintColor2 := RegQueryInt(vKey, 'Color2', FarHintColor2);
      FarHintColorFade := RegQueryInt(vKey, 'ColorFade', FarHintColorFade);
      FarHintTransp := RegQueryInt(vKey, 'Transparency', FarHintTransp);

      FarHintFontName := RegQueryStr(vKey, 'FontName', FarHintFontName);
      FarHintFontSize := RegQueryInt(vKey, 'FontSize', FarHintFontSize);
      FarHintFontColor := RegQueryInt(vKey, 'FontColor', FarHintFontColor);
      Byte(FarHintFontStyle) := RegQueryInt(vKey, 'FontStyle', Byte(FarHintFontStyle));

      FarHintFontName2 := RegQueryStr(vKey, 'FontName2', FarHintFontName2);
      FarHintFontSize2 := RegQueryInt(vKey, 'FontSize2', FarHintFontSize2);
      FarHintFontColor2 := RegQueryInt(vKey, 'FontColor2', FarHintFontColor2);
      Byte(FarHintFontStyle2) := RegQueryInt(vKey, 'FontStyle2', Byte(FarHintFontStyle2));

      FarHintsDateFormat := RegQueryStr(vKey, 'DateFormat', FarHintsDateFormat);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSizeSettings(const APath :TString);
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, APath + '\' + RegFolder, vKey);
    try
      RegWriteInt(vKey, 'MaxThumbnailSize', FarHintThumbSize1);
      RegWriteInt(vKey, 'MaxFolderThumbnailSize', FarHintThumbSize2);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSomeSettings(const APath :TString);
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, APath + '\' + RegFolder, vKey);
    try
      RegWriteLog(vKey, 'AutoKey', FarHintsAutoKey);
      RegWriteLog(vKey, 'AutoMouse', FarHintsAutoMouse);
      RegWriteLog(vKey, 'HintInPanel', FarHintsInPanel);
      RegWriteLog(vKey, 'HintInDialog', FarHintsInDialog);

      RegWriteLog(vKey, 'UseThumbnail', FarHintUseThumbnail);
      RegWriteLog(vKey, 'IconOnThumbnail', FarHintIconOnThumb);
    finally
      RegCloseKey(vKey);
    end;
  end;


end.

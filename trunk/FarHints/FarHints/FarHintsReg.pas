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
    FarHintsConst,
    FarConfig;


  var
    GNeedWriteSizeSettings :Boolean = False;


  procedure ReadSetup;
    { Основные настройки, считываются один раз, при загрузке плагина }
  procedure ReadSettings;
    { Дополнительные настройки. Считываются перед каждым появлением хинта }
    
  procedure WriteSizeSettings;
  procedure WriteSomeSettings;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  type
    TConfigMode = (
      cmReadOne,
      cmReadMore,
      cmWriteSize,
      cmWriteMore
    );


  procedure PluginConfig(AStore :Boolean; AMode :TConfigMode);
  var
    vConfig :TFarConfig;
  begin
   {$ifdef bTrace1}
//  TraceF('PluginConfig %d-%d...', [byte(AStore), byte(AMode)]);
   {$endif bTrace1}

    vConfig := TFarConfig.CreateEx(AStore, cPluginName);
    try
      with vConfig do begin
        if not Exists then
          Exit;

        if AMode = cmReadOne then begin
          LogValue('Enabled', FarHintsEnabled);
          IntValue('FirstDelay', ShowHintFirstDelay);
          IntValue('NextDelay', ShowHintNextDelay);
          FarHintForceKey := ReadInt('ForceKey', FarHintForceKey);

         {$ifdef bSynchroCall}
         {$else}
          FarHintsKey := ReadInt('CallKey', FarHintsKey);
          FarHintsShift := ReadInt('CallShift', FarHintsShift);
         {$endif bSynchroCall}
        end;

        if AMode in [cmReadOne, cmWriteMore] then begin
          LogValue('AutoKey', FarHintsAutoKey);
          LogValue('AutoMouse', FarHintsAutoMouse);
          LogValue('HintInPanel', FarHintsInPanel);
          LogValue('FarHintsInDialog', FarHintsInDialog);
        end;

        if AMode in [cmReadMore, cmWriteMore] then begin
          LogValue('ShowIcon', FarHintShowIcon);
          LogValue('UseThumbnail', FarHintUseThumbnail);
          LogValue('IconOnThumbnail', FarHintIconOnThumb);
        end;

        if AMode in [cmReadMore, cmWriteSize] then begin
          IntValue('MaxThumbnailSize', FarHintThumbSize1);
          IntValue('MaxFolderThumbnailSize', FarHintThumbSize2);
        end;

        if AMode in [cmReadMore] then begin
          LogValue('ShowPrompt', FarHintShowPrompt);

          IntValue('ShowPeriod', FarHintsShowPeriod);
          IntValue('SmoothStep', FarHintSmothSteps);

          IntValue('Color', FarHintColor);
          IntValue('Color2', FarHintColor2);
          IntValue('ColorFade', FarHintColorFade);
          IntValue('Transparency', FarHintTransp);

          StrValue('FontName', FarHintFontName);
          IntValue('FontSize', FarHintFontSize);
          IntValue('FontColor', FarHintFontColor);
          byte(FarHintFontStyle) := ReadInt('FontStyle', byte(FarHintFontStyle));

          StrValue('FontName2', FarHintFontName2);
          IntValue('FontSize2', FarHintFontSize2);
          IntValue('FontColor2', FarHintFontColor2);
          byte(FarHintFontStyle) := ReadInt('FontStyle2', byte(FarHintFontStyle2));

          StrValue('DateFormat', FarHintsDateFormat);
        end
      end;

    finally
      vConfig.Destroy;
    end;
  end;


  procedure ReadSetup;
  begin
    PluginConfig(False, cmReadOne);
  end;

  procedure ReadSettings;
  begin
    PluginConfig(False, cmReadMore);
  end;

  procedure WriteSizeSettings;
  begin
    PluginConfig(True, cmWriteSize);
  end;

  procedure WriteSomeSettings;
  begin
    PluginConfig(True, cmWriteMore);
  end;


end.

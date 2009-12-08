{$I Defines.inc}

unit FarHintsConst;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixWin;


  const
    strLang             = 0;
    strError            = 1;
    strTitle            = 2;
    strCommandsTitle    = 3;
    strOptionsTitle     = 4;
    strMouseHint        = 5;
    strCurItemHint      = 6;
    strPermanentHint    = 7;
    strHintCommands     = 8;
    strOptions          = 9;
    strAutoMouse        = 10;
    strAutoKey          = 11;
    strHintInPanel      = 12;
    strHintInDialog     = 13;
    strShellThumbnail   = 14;
    strIconOnThumbnail  = 15;
    strName             = 16;
    strType             = 17;
    strDescription      = 18;
    strModified         = 19;
    strSize             = 20;
    strPackedSize       = 21;


  const
    HMargin = 3;
    VMargin = 2;
    HSplit1 = 4;  { Щель между картинкой и надписью }
    HSplit2 = 4;  { Щель между prompt'ом и строкой }

    cPluginGUID       = $87654321;

    RegFolder         = 'FarHints';
    RegPluginsFolder  = 'Plugins';
    DefaultLang       = 'English';

  var
    ShowHintFirstDelay  :Integer = 500;   {ms}    { Задержка появления мышиного хинта }
    ShowHintNextDelay   :Integer = 500;   {ms}

    ShowHintFirstDelay1 :Integer = 1000;  {ms}    { Задержка появления клавиатурного хинта }

    HideHintDelay       :Cardinal = 100; {ms}    { Чтобы успела отработать макрокоманда хинта }  {???}
    HideHindAgeLock     :Cardinal = 100; {ms}    { "Молодой" хинт не закрывается от нажатий }

  var
    FarHintColor        :TColor = $FFFFFF; {clInfoBk;} { $80FFFF }
    FarHintColor2       :TColor = -1;                  { $E5E5F0 }
    FarHintColorFade    :Integer = -48;
    FarHintsMaxWidth    :Integer = 512;

    FarHintFontName     :TString = 'Microsoft Sans Serif';
    FarHintFontSize     :Integer = 8;
    FarHintFontColor    :Integer = TColor($000000); //Black
    FarHintFontStyle    :TFontStyles = [];

    FarHintFontName2    :TString = 'Microsoft Sans Serif';
    FarHintFontSize2    :Integer = 7;
    FarHintFontColor2   :Integer = TColor($808080); //Gray
    FarHintFontStyle2   :TFontStyles = [];

    FarHintsEnabled     :Boolean = True;
    FarHintsAutoMouse   :Boolean = True;
    FarHintsAutoKey     :Boolean = False;
    FarHintsPermanent   :Boolean = False;
    FarHintsInPanel     :Boolean = True;
    FarHintsInDialog    :Boolean = True;
    FarHintShowIcon     :Boolean = True;
    FarHintShowPrompt   :Boolean = True;

    FarHintUseThumbnail :Boolean = True;   { Использовать Shell Thumbnail вместо иконок }
    FarHintThumbSize1   :Integer = 128;    { Размер Thumbnail'ов для файлов  }
    FarHintThumbSize2   :Integer = 96;     { Размер Thumbnail'ов для папок  }
    FarHintIconOnThumb  :Boolean = True;   { Накладывать иконку на Thumbnail }

    FarHintsDateFormat  :TString = 'c';

    FarHintsShowPeriod  :Integer = 100;    { Желаемое время плавного прявления (исчезания) хинта }
    FarHintSmothSteps   :Integer = 0;
    FarHintTransp       :Integer = 255;

    FarHintForceKey     :Word    = VK_Shift;

   {$ifdef bSynchroCall}
   {$else}
    FarHintsKey         :Word    = 0; { VK_F23 - $86 } { $31 - '1' }
    FarHintsShift       :Word    = 0; { LEFT_CTRL_PRESSED or LEFT_ALT_PRESSED or SHIFT_PRESSED; }
   {$endif bSynchroCall}


  type
    { Режим вызова хинта: от мыши, от клавиатуры... }
    THintCallMode = (
      hcmNone,
      hcmMouse,
      hcmCurrent
    );

    { Контекст вызова хинта: панель, диалог... }
    THintCallContext = (
      hccNone,
      hccPanel,
      hccEditor,
      hccViewer,
      hccDialog
    );
    
  var
    FRegRoot    :TString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

end.

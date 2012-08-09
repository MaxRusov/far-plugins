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
    MixWin,
    Far_API,
    FarCtrl;


  type
    TMessages = (
      strLang,
      strError,
      strTitle,
      strCommandsTitle,
      strOptionsTitle,
      strMouseHint,
      strCurItemHint,
      strPermanentHint,
      strHintCommands,
      strOptions,
      strAutoMouse,
      strAutoKey,
      strHintInPanel,
      strHintInDialog,
      strShowIcons,
      strShellThumbnail,
      strIconOnThumbnail,
      strName,
      strType,
      strDescription,
      strModified,
      strSize,
      strPackedSize
    );


  const
    cPluginName = 'FarHints';
    cPluginDescr = 'FarHints FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{CDF48DA0-0334-4169-8453-69048DD3B51C}';
    cMenuID     :TGUID = '{56B7CFB2-3450-4B4C-BF2C-93917033CBD8}';
    cConfigID   :TGUID = '{C54F0F2E-87AD-453C-A962-4E95CB2EEE73}';
   {$else}
    cPluginID   = $544e4948;
   {$endif Far3}

  const
    HMargin = 3;
    VMargin = 2;
    HSplit1 = 4;  { Щель между картинкой и надписью }
    HSplit2 = 4;  { Щель между prompt'ом и строкой }

    RegFolder         = 'FarHints';
    RegPluginsFolder  = 'Plugins';
    DefaultLang       = 'English';

  var
    ShowHintFirstDelay  :Integer = 500;   {ms}    { Задержка появления мышиного хинта }
    ShowHintNextDelay   :Integer = 500;   {ms}

    ShowHintFirstDelay1 :Integer = 1000;  {ms}    { Задержка появления клавиатурного хинта }

    HideHintDelay       :Integer = 100;   {ms}    { Чтобы успела отработать макрокоманда хинта }  {???}
    HideHindAgeLock     :Integer = 100;   {ms}    { "Молодой" хинт не закрывается от нажатий }

    InfoHintPeriod      :Integer  = 3000; {ms}    { Время показа информационного хинта }

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

    FarHintsShowPeriod  :Integer = 150;    { Желаемое время плавного прявления (исчезания) хинта }
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
      hcmCurrent,
      hcmInfo
    );

    { Контекст вызова хинта: панель, диалог... }
    THintCallContext = (
      hccNone,
      hccPanel,
      hccEditor,
      hccViewer,
      hccDialog
    );

  const
    scmInitSubPlugins = Pointer(1);
    scmSaveSettings   = Pointer(2);
    scmHideHint       = Pointer(3);

  const
    cmhResize      = 1;
    cmhColor       = 2;
    cmhFontColor   = 3;
    cmhFontSize    = 4;
    cmhTransparent = 5;

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;

  function GetMsgStr(AMess :TMessages) :TString;
  begin
    Result := FarCtrl.GetMsgStr(Integer(AMess));
  end;

end.

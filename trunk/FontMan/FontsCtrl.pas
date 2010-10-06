{$I Defines.inc}

unit FontsCtrl;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* FontMan Far plugin                                                         *}
{******************************************************************************}

interface

  uses
    MixTypes,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strCopyTitle,
      strMoveTitle,
      strCopyBut,
      strMoveBut,
      strCancelBut,
      strPathNotAbsolute,

      strCopyPrompt,
      strMovePrompt,
      strCopyPromptN,
      strMovePromptN,
      strCopying,
      strMoving,

      strInstall,
      strInstallPrompt,
      strInstallPromptN,
      strInstallBut,
      strScanning,
      strInstalling,
      strNoTrueTypeFonts,

      strDelete,
      strDeletePrompt,
      strDeletePromptN,
      strDeleteBut,
      strDeleting,

      strWarning,
      strFileExists,
      strFontExists,
      strOverwriteBut,
      strAllBut,
      strSkipBut,
      strSkipAllBut,

      strInterrupt,
      strInterruptPrompt,
      strYes,
      strNo,

      strFont,
      strFamily,
      strStyle,
      strSize,
      strSizes,
      strType,
      strPitch,
      strCharsets,
      strCopyright,
      strFileName,
      strFileNames,
      strFileSize,
      strFilesSize,
      strModified,

      strFontManager,
      strGroupMode_,
      strFilterByType_,
      strFilterByCharset_,

      strGroupMode,
      strNone,
      strByFamily,
      strGroupAllFonts,

      strFilterByType,
      strTrueType,
      strOpenType,
      strVector,
      strRaster,
      strVariablePitch,
      strFixedPitch,

      strFilterByCharset
   );

 {-----------------------------------------------------------------------------}

  const
    cDefaultLang   = 'English';
    cMenuFileMask  = '*.mnu';

    cFontsPrefix   = 'Fonts';

    cPlugRegFolder = 'FontMan';
    cHintFontSizeRegValue = 'HintFontSize';

  const
    BOM_UTF16_LE :array[0..1] of byte = ($FF, $FE);

  var
    FRegRoot     :TString;
    FModuleName  :TString;

    
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


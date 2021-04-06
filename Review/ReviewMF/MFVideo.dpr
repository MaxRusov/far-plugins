library MFVideo;

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $41150000}
{$endif Debug}

{$ifdef bDelphi}
 {$E pvd}
{$endif bDelphi}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  MFVideoMain;

exports
  pvdInit2,
  pvdExit2,
  pvdPluginInfo2,
  pvdReloadConfig2,
  pvdGetFormats2,

  pvdFileOpen2,
  pvdPageInfo2,
  pvdPageDecode2,
  pvdPageFree2,
  pvdFileClose2,

  pvdDisplayInit2,
  pvdDisplayAttach2,
  pvdDisplayCreate2,
  pvdDisplayPaint2,
  pvdDisplayClose2,
  pvdDisplayExit2,
  pvdTranslateError2,

  pvdTagInfo,
  pvdPlayControl;

{$R MFVideoW.res}

end.

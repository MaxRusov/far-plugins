{$I Defines.inc}

{$APPTYPE CONSOLE}
{-$ImageBase $41000000}

{$ifdef bDelphi}
 {$E pvd}
{$endif bDelphi}

library GDIPlus;

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  GDIPlusMain;

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
  pvdDisplayExit2;

{$R GDIPlus.res}

end.

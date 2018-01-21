library WIC;

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $41130000}
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
  WICMain;

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

  pvdTagInfo,
  pvdTranslateError2;

{$R WIC.res}

end.

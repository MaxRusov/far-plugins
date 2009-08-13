{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40500000}
{$endif bDelphi}

library PlugMenu;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  PlugMenuMain;

exports
 {$ifdef bUnicode}
  SetStartupInfoW,
  GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ExitFARW;
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  ExitFAR;
 {$endif bUnicode}


 {$ifdef bUnicode}
  {$R PlugMenuW.res}
 {$else}
  {$R PlugMenuA.res}
 {$endif bUnicode}


end.

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40500000}

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
  {$R PlugMenu.res}
 {$endif bUnicode}


end.

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40B00000}
{$endif bDelphi}

library PanelTabs;  

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  PanelTabsMain;

exports
 {$ifdef bUnicodeFar}
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  ConfigureW,
  ProcessSynchroEventW,
  ExitFARW;
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  Configure,
  ExitFAR;
 {$endif bUnicodeFar}

 {$ifdef bUnicode}
  {$R PanelTabsW.res}
 {$else}
  {$R PanelTabsA.res}
 {$endif bUnicode}

end.

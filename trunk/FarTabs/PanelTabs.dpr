{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40B00000}
{$endif Debug}

library PanelTabs;  

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  MixFormat,
  PanelTabsMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$else}
  GetMinFarVersionW,
 {$endif Far3}

  SetStartupInfoW,
  GetPluginInfoW,
  
 {$ifdef Far3}
  OpenW,
 {$else}
  OpenPluginW,
 {$endif Far3}

  ProcessSynchroEventW,
 {$ifdef bUseProcessConsoleInput}
  ProcessConsoleInputW,
 {$endif bUseProcessConsoleInput}

  ConfigureW,
  ExitFARW;

 {$ifdef bUnicode}
  {$R PanelTabsW.res}
 {$else}
  {$R PanelTabsA.res}
 {$endif bUnicode}

begin
  Plug := TPanelTabsPlug.Create;
end.

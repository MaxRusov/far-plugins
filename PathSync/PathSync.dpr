{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40C00000}
{$endif Debug}

library PathSync;

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  PathSyncMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$else}
  GetMinFarVersionW,
 {$endif Far3}
  SetStartupInfoW,
  GetPluginInfoW,
  ProcessSynchroEventW,
  ConfigureW,
  ExitFARW;

{$R PathSync.res}

begin
  Plug := TPathSyncPlug.Create;
end.

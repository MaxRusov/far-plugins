{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40300000}

library FarHints;

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  FarHintsMain;

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
 {$ifdef bSynchroCall}
  ProcessSynchroEventW,
 {$endif bSynchroCall}
  ConfigureW,
  ExitFARW,

  GetFarHinstAPI;
  

 {$ifdef Unicode}
  {$R FarHintsW.res}
 {$else}
  {$R FarHintsA.res}
 {$endif Unicode}

begin
  Plug := TFarHinstPlug.Create;
end.

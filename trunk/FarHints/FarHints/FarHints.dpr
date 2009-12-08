{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40300000}

library FarHints;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsMain;

exports
 {$ifdef bUnicodeFar}
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,    
 {$ifdef bSynchroCall}
  ProcessSynchroEventW,
 {$endif bSynchroCall}
  ExitFARW,
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  ExitFAR,
 {$endif bUnicodeFar}

  GetFarHinstAPI;
  

 {$ifdef Unicode}
  {$R FarHintsW.res}
 {$else}
  {$R FarHintsA.res}
 {$endif Unicode}


end.

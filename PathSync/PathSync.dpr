{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40C00000}

library PathSync;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  PathSyncMain;

exports
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  ProcessSynchroEventW,
  ConfigureW,
  ExitFARW;

// {$R PathSyncW.res}

end.

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40500000}
{$endif bDelphi}

library NoisyFar;

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  FarPlayMain;

exports
 {$ifdef bUnicodeFar}
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  ExitFarW;
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  ExitFar;
 {$endif bUnicodeFar}

 {$ifdef bUnicodeFar}
  {$R NoisyFarW.res}
 {$else}
  {$R NoisyFar.res}
 {$endif bUnicodeFar}

end.

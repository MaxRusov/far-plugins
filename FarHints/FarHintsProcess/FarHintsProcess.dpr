{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ImageBase $403B0000}

library FarHintsProcess;

{$I Defines1.inc}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsProcessMain;

exports
  GetPluginInterface;

{$R FarHintsProcess.res}

end.

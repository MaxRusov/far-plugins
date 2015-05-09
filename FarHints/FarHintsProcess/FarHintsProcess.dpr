{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $403B0000}
{$endif Debug}

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

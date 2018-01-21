library FarHintsProcess;

{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $403B0000}
{$endif Debug}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsProcessMain;

exports
  GetPluginInterface;

{$R FarHintsProcess.res}

end.

{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $40350000}
{$endif Debug}

library FarHintsVerInfo;

{$I Defines1.inc}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsVerInfoMain;

exports
  GetPluginInterface;

{$R FarHintsVerInfo.res}

end.

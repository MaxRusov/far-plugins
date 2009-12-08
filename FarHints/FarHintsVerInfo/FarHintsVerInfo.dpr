{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ImageBase $40350000}

library FarHintsVerInfo;

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsVerInfoMain;

exports
  GetPluginInterface;

{$R FarHintsVerInfo.res}

end.

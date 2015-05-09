{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $40390000}
{$endif Debug}

library FarHintsMP3;

{$I Defines1.inc}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsMP3Main;

exports
  GetPluginInterface;

{$R FarHintsMP3.res}

end.

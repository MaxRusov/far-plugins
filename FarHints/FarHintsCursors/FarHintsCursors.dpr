library FarHintsCursors;

{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $403A0000}
{$endif Debug}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsCursorsMain;

exports
  GetPluginInterface;

{$R FarHintsCursors.res}

end.

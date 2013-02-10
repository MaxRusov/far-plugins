{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ImageBase $403A0000}

library FarHintsCursors;

{$I Defines1.inc}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsCursorsMain;

exports
  GetPluginInterface;

{$R FarHintsCursors.res}

end.

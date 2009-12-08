{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ImageBase $40380000}

library FarHintsImage;

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsImageMain;

exports
  GetPluginInterface;

{$R FarHintsImage.res}

end.

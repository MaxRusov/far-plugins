library FarHintsImage;

{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $40380000}
{$endif Debug}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsImageMain;

exports
  GetPluginInterface;

{$R FarHintsImage.res}

end.

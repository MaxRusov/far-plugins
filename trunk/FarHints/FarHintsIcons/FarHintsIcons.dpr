{$I Defines.inc} { см. также \App\MaxTest\FarHintsIcons\DefApp.Pas }

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ImageBase $40360000}

library FarHintsIcons;

uses
 {$ifdef bTrace}
  MSCheck,
 {$endif bTrace}
  FarHintsIconsMain;

exports
  GetPluginInterface;

 {$ifdef False}
  {$R *.RES}
 {$else}
  {$R \WrkDcu\FarHintsIcons.res}
 {$endif False}

end.

{$I Defines.inc}

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ifdef Debug}
 {$ImageBase $40370000}
{$endif Debug}

library FarHintsFolders;

{$I Defines1.inc}

uses
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarHintsFoldersMain;

exports
  GetPluginInterface;

{$R FarHintsFolders.res}

end.

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40E00000}

library DlgSelect;

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  DlgSelectMain;

exports
  SetStartupInfoW,
  ProcessDialogEventW;

{$R DlgSelect.res}

end.

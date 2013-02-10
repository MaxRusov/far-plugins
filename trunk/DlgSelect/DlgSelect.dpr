{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40E00000}
{$endif Debug}

library DlgSelect;

{$I Defines1.inc}

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  DlgSelectMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$endif Far3}
  SetStartupInfoW,
  ProcessDialogEventW;

{$R DlgSelect.res}

begin
  Plug := TDlgSelectPlug.Create;
end.

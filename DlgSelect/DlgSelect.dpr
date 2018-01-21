{******************************************************************************}
{* (c) Max Rusov                                                              *}
{* DlgSelect                                                                  *}
{* License: WTFPL                                                             *}
{* Home: https://github.com/MaxRusov/far-plugins                              *}
{******************************************************************************}

library DlgSelect;

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40E00000}
{$endif Debug}

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

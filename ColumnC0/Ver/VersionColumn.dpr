{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40E00000}
{$endif Debug}

library VersionColumn;

{******************************************************************************}
{* VersionColumn Far Plugin                                                   *}
{* 2010-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  VersionColumn_Main;

exports
  GetGlobalInfoW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenW,
  GetCustomDataW,
  FreeCustomDataW,
  ExitFARW;

{$R VersionColumn.res}


begin
  Plug := TVersionColumn.Create;
end.

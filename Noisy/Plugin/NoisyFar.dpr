{******************************************************************************}
{* Noisy - Noisy Player Far plugin                                            *}
{* 2008-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

library NoisyFar;

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40500000}
{$endif Debug}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  FarPlug,
  FarPlayMain;

exports
  GetGlobalInfoW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenW,
  ConfigureW,
  ExitFARW;

{$R NoisyFar.res}

begin
  Plug := TNoisyPlug.Create;
end.

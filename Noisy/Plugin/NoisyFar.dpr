{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40500000}
{$endif Debug}

library NoisyFar;

{$I Defines1.inc}

{******************************************************************************}
{* Noisy - Noisy Player Far plugin                                            *}
{* 2008-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

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

{******************************************************************************}
{* (c) 2008-2014 Max Rusov                                                    *}
{* PlugMenu Far Plugin                                                        *}
{* License: WTFPL                                                             *}
{* Home: https://github.com/MaxRusov/far-plugins                              *}
{******************************************************************************}

library PlugMenu;

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
  FarPlug,
  PlugMenuMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$endif Far3}
  SetStartupInfoW,
  GetPluginInfoW,
 {$ifdef Far3}
  OpenW,
 {$else}
  OpenPluginW,
 {$endif Far3}
  ConfigureW,
  ProcessSynchroEventW,
  ExitFARW;

{$R PlugMenuW.res}

begin
  Plug := TPlugMenuPlug.Create;
end.

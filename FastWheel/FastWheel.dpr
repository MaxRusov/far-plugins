{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{* Editor Whell Extender                                                      *}
{* License: WTFPL                                                             *}
{* Home: https://github.com/MaxRusov/far-plugins                              *}
{******************************************************************************}

library FastWheel;

{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40E00000}
{$endif Debug}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  FastWheelMain;

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
  ProcessEditorInputW,
  ProcessEditorEventW,
  ProcessSynchroEventW,
 {$ifdef bUseProcessConsoleInput}
  ProcessConsoleInputW,
 {$endif bUseProcessConsoleInput}
  ConfigureW,
  ExitFARW;

{$R FastWheel.res}

begin
  Plug := TFastWheelPlug.Create;
end.


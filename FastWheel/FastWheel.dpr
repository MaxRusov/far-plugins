{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40E00000}
{$endif Debug}

library FastWheel;

{$I Defines1.inc}

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Editor Whell Extender                                                      *}
{******************************************************************************}

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


{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ImageBase $40E00000}


library FastWheel;

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
  ConfigureW,
  ExitFARW;

{$R FastWheel.res}

begin
  Plug := TFastWheelPlug.Create;
end.

{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40F00000}
{$endif Debug}

library MacroLib;

{$I Defines1.inc}

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* MacroLib                                                                   *}
{******************************************************************************}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  MacroLibMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$else}
  GetMinFarVersionW,
 {$endif Far3}
  SetStartupInfoW,
  GetPluginInfoW,
 {$ifdef Far3}
  OpenW,
 {$else}
  OpenPluginW,
 {$endif Far3}
  ProcessSynchroEventW,
  ProcessDialogEventW,
  ProcessEditorEventW,
  ProcessViewerEventW,
 {$ifdef bUseProcessConsoleInput}
  ProcessConsoleInputW,
 {$endif bUseProcessConsoleInput}

  ConfigureW,
  ExitFARW;

{$R MacroLib.res}

begin
  Plug := TMacroLibPlug.Create;
end.

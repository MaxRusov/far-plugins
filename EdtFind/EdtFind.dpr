{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40C00000}
{$endif Debug}

library EdtFind;

{$I Defines1.inc}

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{******************************************************************************}

uses
//  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  EdtFindMain;

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
  ConfigureW,
  ProcessSynchroEventW,
 {$ifdef bAdvSelect}
  ProcessEditorInputW,
  ProcessEditorEventW,
 {$endif bAdvSelect}
  ExitFARW;

{$R EdtFindW.res}

begin
  Plug := TEdtFindPlug.Create;
end.

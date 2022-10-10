{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{* Edtitor Find Shell                                                         *}
{* License: WTFPL                                                             *}
{* Home: https://github.com/MaxRusov/far-plugins                              *}
{******************************************************************************}

library EdtFind;

{$I Defines.inc} { ��. ����� DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40C00000}
{$endif Debug}

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

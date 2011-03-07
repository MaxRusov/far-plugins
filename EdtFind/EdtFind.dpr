{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40C00000}
{$endif bDelphi}

library EdtFind;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{******************************************************************************}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  EdtFindMain;

exports
  SetStartupInfoW,
  GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ConfigureW,
  ProcessSynchroEventW,
 {$ifdef bAdvSelect}
  ProcessEditorInputW,
  ProcessEditorEventW,
 {$endif bAdvSelect}
  ExitFARW;

{$R EdtFindW.res}

end.

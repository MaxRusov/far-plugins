{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ImageBase $40F00000}


library MacroLib;

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
  MacroLibMain;

exports
  SetStartupInfoW,
  GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ProcessSynchroEventW,
  ProcessDialogEventW,
  ConfigureW,
  ExitFARW;

{$R MacroLib.res}

end.

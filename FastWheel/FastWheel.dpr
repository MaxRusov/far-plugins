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
  FastWheelMain;

exports
  SetStartupInfoW,
//GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ProcessEditorInputW,
  ProcessEditorEventW,
  ProcessSynchroEventW,
  ConfigureW,
  ExitFARW;

{$R FastWheel.res}

end.

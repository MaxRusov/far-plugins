{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40A00000}
{$endif bDelphi}

library FarDebug;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{******************************************************************************}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarDebugMain;

exports
  SetStartupInfoW,
  GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ConfigureW,
  ProcessEditorEventW,
  ExitFARW;

 {$R FarDebugW.res}


begin
//  asm db $CC end;
end.

{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40A00000}
{$endif bDelphi}

library FarDebug;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
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
 {$ifdef bUnicodeFar}
  SetStartupInfoW,
  GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ProcessEditorEventW,
  ExitFARW;
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  ProcessEditorEvent,
  ExitFAR;
 {$endif bUnicodeFar}

{$ifdef bUnicodeFar}
 {$R FarDebugW.res}
{$else}
 {$R FarDebugA.res}
{$endif bUnicodeFar}

end.

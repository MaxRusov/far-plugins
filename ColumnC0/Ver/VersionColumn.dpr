{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40E00000}

library VersionColumn;

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  VersionColumn_Main;

exports
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  GetCustomDataW,
  FreeCustomDataW,
  ExitFARW;

{$R VersionColumn.res}

end.

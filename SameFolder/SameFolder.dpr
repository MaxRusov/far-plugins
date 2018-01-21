{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40D00000}
{$endif Debug}

library SameFolder;

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  SameFolderMain;

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
  ProcessConsoleInputW,
 {$else}
  OpenPluginW,
 {$endif Far3}
  ConfigureW,
  ProcessSynchroEventW,
  ExitFARW;

{$R SameFolder.res}

begin
  Plug := TSameFolderPlug.Create;
end.

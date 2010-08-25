{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40D00000}

library SameFolder;

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  SameFolderMain;

exports
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  ConfigureW,
  ProcessSynchroEventW,
  ExitFARW;

{$R SameFolder.res}

end.

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40800000}
{$endif bDelphi}

library MoreHistory;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MoreHistoryMain;

exports
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  OpenFilePluginW,
  ConfigureW,
  ProcessEditorEventW,
  ProcessViewerEventW,
  ProcessSynchroEventW,
  ExitFARW;

{$R MoreHistoryW.res}

end.

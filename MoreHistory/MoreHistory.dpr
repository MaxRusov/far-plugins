{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40800000}
{$endif Debug}

library MoreHistory;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,  
 {$endif bTrace}
  FarPlug,
  MoreHistoryMain;

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
  AnalyseW,
 {$else}
  OpenPluginW,
  OpenFilePluginW,
 {$endif Far3}
  ConfigureW,
  ProcessEditorEventW,
  ProcessViewerEventW,
  ProcessSynchroEventW,
  ExitFARW;

{$R MoreHistoryW.res}

begin
  Plug := TMoreHistoryPlug.Create;
end.

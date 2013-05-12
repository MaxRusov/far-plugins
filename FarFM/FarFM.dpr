{$I Defines.inc}

{$AppType Console}
{$ifdef Debug}
 {$ImageBase $40000000}
{$endif Debug}

library FarFM;

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  FarPlug,
  FarFMMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$endif Far3}

  SetStartupInfoW,
  GetPluginInfoW,

 {$ifdef Far3}
  OpenW,
  ClosePanelW,
  GetOpenPanelInfoW,
 {$else}
  OpenPluginW,
  ClosePluginW,
  GetOpenPluginInfoW,
 {$endif Far3}
  GetFindDataW,
  FreeFindDataW,
  SetDirectoryW,
  MakeDirectoryW,
  GetFilesW,
  PutFilesW,
  DeleteFilesW,

 {$ifdef Far3}
  ProcessPanelInputW,
 {$else}
  ProcessKeyW,
 {$endif Far3}
//ProcessEventW,

  ProcessSynchroEventW,

  ConfigureW,
  ExitFARW;


{$R FarFM.res}

begin
  Plug := TFarFMPlug.Create;
end.

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40700000}
{$endif bDelphi}

library FontMan;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FontsMain;

exports
 {$ifdef bUnicodeFar}
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  ClosePluginW,
  GetOpenPluginInfoW,
  GetFindDataW,
  FreeFindDataW,
  SetDirectoryW,
  GetFilesW,
  PutFilesW,
  DeleteFilesW,
  ProcessKeyW,
  ProcessEventW;
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  ClosePlugin,
  GetOpenPluginInfo,
  GetFindData,
  FreeFindData,
  SetDirectory,
  GetFiles,
  PutFiles,
  DeleteFiles,
  ProcessKey,
  ProcessEvent;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  {$R FontManW.res}
 {$else}
  {$R FontManA.res}
 {$endif bUnicodeFar}


begin
end.

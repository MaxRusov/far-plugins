{$I Defines.inc} 

{$APPTYPE CONSOLE}
{$ImageBase $40A00000}

library VisComp;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  VisCompMain;

exports
 {$ifdef bUnicodeFar}
  SetStartupInfoW,
  GetMinFarVersionW,
  GetPluginInfoW,
  OpenPluginW,
  ProcessEditorEventW,
  ExitFARW,
 {$else}
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin,
  ExitFAR,
 {$endif bUnicodeFar}

  CompareFiles;
  
 {$ifdef bUnicodeFar}
  {$R VisCompW.res}   
 {$else}
  {$R VisCompA.res}
 {$endif bUnicodeFar}


end.

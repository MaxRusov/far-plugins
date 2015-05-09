{$I Defines.inc} 

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40A00000}
{$endif Debug}

library VisComp;

{$I Defines1.inc}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  VisCompMain;

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
 {$else}
  OpenPluginW,
 {$endif Far3}

  ProcessEditorEventW,
  ConfigureW,
  ExitFARW,

  CompareFiles;
  
 {$ifdef bUnicodeFar}
  {$R VisCompW.res}   
 {$else}
  {$R VisCompA.res}
 {$endif bUnicodeFar}


begin
  Plug := TVisCompPlug.Create;
end.

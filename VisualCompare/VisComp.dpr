{******************************************************************************}
{* (c) Max Rusov                                                              *}
{* Visual Compare                                                             *}
{* License: WTFPL                                                             *}
{* Home: https://github.com/MaxRusov/far-plugins                              *}
{******************************************************************************}

library VisComp;

{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $40A00000}
{$endif Debug}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
 {$ifdef bIntegrationAPI}
  VisCompIntegration,
 {$endif bIntegrationAPI}
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

 {$ifdef bIntegrationAPI}
  GetVisCompAPI,
 {$endif bIntegrationAPI}
  CompareFiles;
  
 {$ifdef bUnicodeFar}
  {$R VisCompW.res}   
 {$else}
  {$R VisCompA.res}
 {$endif bUnicodeFar}


begin
  Plug := TVisCompPlug.Create;
end.

{$I Defines.inc}

{$AppType Console}
{$ifdef Debug}
 {$ImageBase $40000000}
{$endif Debug}

library ApiDemo;

uses
//MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  ApiDemoMain;

exports
 {$ifdef Far3}
  GetGlobalInfoW,
 {$endif Far3}
  SetStartupInfoW,
  GetPluginInfoW,
 {$ifdef Far3}
  OpenW;
 {$else}
  OpenPluginW;
 {$endif Far3}


begin
  Plug := TDemoPlug.Create;
end.

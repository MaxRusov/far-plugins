
library GitShell;

{$I Defines.inc}

{$AppType Console}
{$ifdef Debug}
 {$ImageBase $40000000}
{$endif Debug}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  GitShellMain;


exports
  GetGlobalInfoW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenW,
  ConfigureW,
  ExitFARW;

{$R GitShell.res}

begin
  Plug := TGitShellPlug.Create;
end.


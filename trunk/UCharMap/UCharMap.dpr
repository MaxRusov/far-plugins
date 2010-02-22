{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ifdef bDelphi}
 {$ImageBase $40900000}
{$endif bDelphi}

library UCharMap;

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  UCharMapMain;

exports
  GetMinFarVersionW,
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW,
  ExitFARW;

{$R UCharMapW.res}

end.

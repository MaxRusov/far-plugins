{$I Defines.inc}

{$APPTYPE CONSOLE}
{$ImageBase $40900000}

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

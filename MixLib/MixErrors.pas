{$I Defines.inc}

{$ifndef bTrace} {$undef bTraceError} {$endif}

unit MixErrors;

interface

uses
  Windows,
  MixTypes,
  MixUtils;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

uses
  MixConsts,
  MixDebug;


{$ifdef FPC}

 {$I FPC\MixErrors.inc}

{$else}

 {$ifdef bDelphi16}
  {$I BDXE\MixErrors.inc}
 {$else}
  {$I BD5\MixErrors.inc}
 {$endif}

{$endif FPC}



initialization
  InitExceptions;
finalization
  DoneExceptions;
end.


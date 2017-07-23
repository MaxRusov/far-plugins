{$I Defines.inc}

{-$Align On}
{$RangeChecks Off}

{$ifdef FPC}
 {$PACKRECORDS C}
{$endif FPC}

unit Far_Api;

interface

uses Windows;

{$Define FarAPI}

{$Define ApiIntf}

{$ifdef Far3}
 {$I Plugin3.pas}
{$else}
 {$I PluginW.pas}
{$endif Far3}

{$I FarKeysW.pas}
{$I FarColor.pas}

implementation

{$UnDef ApiIntf}
{$Define ApiImpl}

{$ifdef Far3}
 {$I Plugin3.pas}
{$else}
 {$I PluginW.pas}
{$endif Far3}

end.


{******************************************************************************}
{* (c) 2012-2022 Max Rusov                                                    *}
{* Color Setup                                                                *}
{* License: WTFPL                                                             *}
{* Home: https://github.com/MaxRusov/far-plugins                              *}
{******************************************************************************}

library ColorSet;

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
  ColorSetMain;


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
  Plug := TColorSetPlug.Create;
end.

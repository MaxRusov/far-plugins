{$I Defines.inc} { см. также DefApp.inc }

{$APPTYPE CONSOLE}
{$ifdef Debug}
 {$ImageBase $41100000}  
{$endif Debug}

library Review;

{$I Defines1.inc}

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

uses
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  FarPlug,
  ReviewMain;

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
  ProcessSynchroEventW,
//ProcessDialogEventW,
//ProcessEditorEventW,
  ProcessViewerEventW,
//ProcessConsoleInputW,

  ConfigureW,
  ExitFARW;

{$R Review.res}

begin
  Plug := TReviewPlug.Create;
end.

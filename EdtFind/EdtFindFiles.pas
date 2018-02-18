{$I Defines.inc}

{$ifdef Far3}
{$else}
 {$Define bPreciseMatch}
{$endif Far3}

unit EdtFindFiles;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Editor Find Shell                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,

    Far_API,
    FarCtrl,

    EdtFindCtrl,
    EdtFinder,
    EdtFindFilesDlg,
    EdtFindGrep;


(*
  var
    gLastOpt     :TFindOptions;
    gLastBracket :Integer;
    gMatchStr    :TString;
*)

  procedure FindFiles;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


(*
 {$ifdef bFileFind}
  procedure FindFilesDlg;
  var
    vMode :TFindMode;
  begin
//  if not FileFindDlg then
//    Exit;

    gLastOpt := gOptions;
    gLastIsReplace := False;
    FindStr(gStrFind, gLastOpt, vMode = efmEntire, False, not gReverse);
  end;
 {$endif bFileFind}
*)


  procedure FindFiles;
//var
//  vMode :TFindMode;
  begin
//  SyncFindStr;
    if not FileFindDlg then
      Exit;

   Sorry;
(*
   {$ifdef bAdvSelect}
    EdtClearMark;
   {$endif bAdvSelect}
    gLastOpt := gOptions;
    gLastBracket := gBracket;
    gLastIsReplace := False;
    if vMode = efmCount then
      CountStr(gStrFind, gLastOpt)
    else
    if vMode = efmGrep then
      GrepStr(gStrFind, gLastOpt, gLastBracket)
    else
      FindStr(gStrFind, gLastOpt, gLastBracket, vMode = efmEntire, False, not gReverse);
*)
  end;



end.


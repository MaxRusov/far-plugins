{$I Defines.inc}
{$Typedaddress Off}

unit VisCompMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,

    VisCompCtrl,
    VisCompFiles,
    VisCompPromptDlg,
    VisCompFilesDlg;


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  procedure ExitFAR; stdcall;
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := $02F40200; { Need 2.0.756 }
    Result := $03150200; { Need 2.0.789 }
  end;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

(*  ReadSetup;  *)
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;


 {$ifdef bUnicodeFar}
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
 {$else}
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= 0 {PF_EDITOR or PF_VIEWER or PF_DIALOG};

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := @PluginMenuStrings;
    pi.CommandPrefix := cPlugMenuPrefix;
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
//  Trace('ExitFAR');
  end;


  var
    vPluginLock :Integer;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}
  var
    vPath1, vPath2 :TString;
    vList :TCmpFolder;
    vSide  :Integer;
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
    if vPluginLock > 0 then
      Exit;

    try
      Inc(vPluginLock);
     {$ifndef bUnicodeFar}
      SetFileApisToAnsi;
     {$endif bUnicodeFar}
      try
        ReadSetup;

        vSide  := CurrentPanelSide;
        vPath1 := GetPanelDir(vSide = 0);
        vPath2 := GetPanelDir(vSide <> 0);

        if not CompareDlg(vPath1, vPath2) then
          Exit;

        vList := CompareFolders(vPath1, vPath2);
        try
          ShowFilesDlg(vList);
        finally
          FreeObj(vList);
        end

      finally
       {$ifndef bUnicodeFar}
        SetFileApisToOEM;
       {$endif bUnicodeFar}
        Dec(vPluginLock);
      end;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


end.

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}
{$Typedaddress Off}

unit VisCompMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,

    VisCompCtrl,
    VisCompFiles,
    VisCompTexts,
    VisCompPromptDlg,
    VisCompFilesDlg,
    VisCompTextsDlg,
    VisCompOptionsDlg;


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  procedure ExitFAR; stdcall;
  function OpenPlugin(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function Configure(Item: integer) :Integer; stdcall;
 {$endif bUnicodeFar}


  function CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer; stdcall;
    { Ёкспорт, дл€ межплагинного взаимодействи€... }

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer;
    { Ёкспорт, дл€ межплагинного взаимодействи€... }
  begin
    try
      CompareTexts(AFileName1, AFileName2);
    except
      on E :Exception do
        HandleError(E);
    end;
    Result := 0;
  end;


  function MakeProvider(const AFolder :TString; ASide :Integer) :TDataProvider;
  begin
    if UpCompareSubStr(cSVNFakeDrive, AFolder) = 0 then
      Result := TSVNProvider.CreateEx(AFolder)
    else
    if UpCompareSubStr(cPlugFakeDrive, AFolder) = 0 then
      Result := TPluginProvider.CreateEx(AFolder, ASide)
    else
      Result := TFileProvider.CreateEx(AFolder);
  end;


  procedure CompareFolders2(const AFolder1, AFolder2 :TString);
  var
    vPath1, vPath2 :TString;
    vSource1, vSource2 :TDataProvider;
    vComp :TComparator;
    vSide :Integer;
  begin
    vSide  := CurrentPanelSide;

    vPath1 := RemoveBackSlash(AFolder1);
    if vPath1 = '' then
      vPath1 := GetPanelDir(vSide = 0);

    vPath2 := RemoveBackSlash(AFolder2);
    if vPath2 = '' then
      vPath2 := GetPanelDir(vSide <> 0);

    if not CompareDlg(vPath1, vPath2) then
      Exit;

    vSource1 := nil; vSource2 := nil; vComp := nil;
    try
      vSource1 := MakeProvider(vPath1, 0);
      vSource2 := MakeProvider(vPath2, 1);

      vComp := TComparator.CreateEx(vSource1, vSource2);
      vComp.CompareFolders;

      ShowFilesDlg(vComp);

    finally
      FreeObj(vComp);
      FreeObj(vSource1);
      FreeObj(vSource2);
    end
  end;


  procedure OpenCmdLine(const AStr :TString);
  var
    vPtr :PTChar;
    vStr1, vStr2 :TString;
  begin
    if AStr <> '' then begin
      vPtr := PTChar(AStr);
      vStr1 := FarExpandFileNameEx(ExtractParamStr(vPtr));
      vStr2 := FarExpandFileNameEx(ExtractParamStr(vPtr));

      if (vStr1 <> '') and WinFileExists(vStr1) and (vStr2 <> '') and WinFileExists(vStr2) then
        CompareTexts(vStr1, vStr2)
      else
        CompareFolders2(vStr1, vStr2);

    end else
      CompareFolders2('', '');
  end;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
    Result := MakeFarVersion(2, 0, 1573);   { ACTL_GETFARRECT }
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

    RestoreDefFilesColor;
    RestoreDefTextColor;
    
(*  ReadSetup;  *)
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;
    ConfigMenuStrings: array[0..0] of PFarChar;


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
    pi.PluginMenuStrings := @PluginMenuStrings;
    pi.PluginMenuStringsNumber := 1;

    ConfigMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginConfigStrings := @ConfigMenuStrings;
    pi.PluginConfigStringsNumber := 1;

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
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$endif bUnicodeFar}
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
        ReadSetupColors;

        if OpenFrom = OPEN_COMMANDLINE then
          OpenCmdLine(FarChar2Str(PFarChar(Item)))
        else
          CompareFolders2('', '');

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


  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  var
    vPos :TEditorSetPosition;
  begin
//  TraceF('ProcessEditorEvent: %d, %x', [AEvent, TIntPtr(AParam)]);
    Result := 0;
    case AEvent of
      EE_READ:
        if GEditorTopRow <> -1 then begin
          vPos.TopScreenLine := GEditorTopRow;
          vPos.CurLine := -1; vPos.CurPos := -1; vPos.CurTabPos := -1; vPos.LeftPos := -1; vPos.Overtype := -1;
          FARAPI.EditorControl(ECTL_SETPOSITION, @vPos);
          GEditorTopRow := -1;
        end;
    end;
  end;


 {$ifdef bUnicodeFar}
  function ConfigureW(Item: integer) :Integer; stdcall;
 {$else}
  function Configure(Item: integer) :Integer; stdcall;
 {$endif bUnicodeFar}
  begin
    Result := 1;
    try
      OptionsDlg;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


end.

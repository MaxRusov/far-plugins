{$I Defines.inc}
{$Typedaddress Off}

unit PathSyncMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PathSync plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,

    PluginW,
    FarColorW,
    FarCtrl;

  const
    cPlugRegFolder = 'PathSync';

  var
    optSyncFolder  :Boolean = True;
    optNotifyError :Boolean = True;

    optNormColor   :Integer = $00;
    optErrorColor  :Integer = $0C;


  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
  procedure ExitFARW; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  var
    FRegRoot  :TString;

  var
    FLastPath  :TString;
    FLastColor :Integer = -1;

 {-----------------------------------------------------------------------------}

  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..1024] of TChar;
  begin
    FillChar(vBuf, SizeOf(vBuf), $00);
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;
  end;


  procedure FarSetColor(AIndex :Integer; AColor :Byte);
  var
    vInfo :TFarSetColors;
  begin
    vInfo.Flags := FCLR_REDRAW;
    vInfo.StartIndex := AIndex;
    vInfo.ColorCount := 1;
    vInfo.Colors := @AColor;
    FARAPI.AdvControl(hModule, ACTL_SETARRAYCOLOR, @vInfo);
  end;


  procedure UpdateColor(ANorm :Boolean);
  begin
    if not optNotifyError then
      Exit;

    if FLastColor <> Byte(ANorm) then begin
      if ANorm then
        FarSetColor(COL_COMMANDLINEPREFIX, optNormColor)
      else
        FarSetColor(COL_COMMANDLINEPREFIX, optErrorColor);
      FLastColor := Byte(ANorm);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure ReadSettings;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optSyncFolder := RegQueryLog(vKey, 'SyncFolder', optSyncFolder);
      optNotifyError := RegQueryLog(vKey, 'NotifyError', optNotifyError);

      optNormColor := RegQueryInt(vKey, 'NormColor', optNormColor);
      optErrorColor := RegQueryInt(vKey, 'ErrorColor', optErrorColor);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSettings;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'SyncFolder', optSyncFolder);
      RegWriteLog(vKey, 'NotifyError', optNotifyError);

      RegWriteInt(vKey, 'NormColor', optNormColor);
      RegWriteInt(vKey, 'ErrorColor', optErrorColor);
    finally
      RegCloseKey(vKey);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCheckThread                                                                }
 {-----------------------------------------------------------------------------}

  type
    TCheckThread = class(TThread)
    public
      procedure Execute; override;
    end;


  procedure TCheckThread.Execute; {override;}
  var
    vLastTitle, vStr :TString;
  begin
    vLastTitle := '';
    while not Terminated do begin
      vStr := GetConsoleTitleStr;
      if vStr <> vLastTitle then begin
        vLastTitle := vStr;
        if optSyncFolder then
          FARAPI.AdvControl(hModule, ACTL_SYNCHRO, nil);
      end;
      Sleep(10);
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    CheckThread :TCheckThread;

  procedure SetCheckThread(AOn :Boolean);
  begin
    if AOn <> (CheckThread <> nil) then begin
      if AOn then begin
        CheckThread := TCheckThread.Create(False);
      end else
      begin
        CheckThread.Terminate;
        CheckThread.WaitFor;
        FreeObj(CheckThread);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  var
    vItems :array[0..1] of TFarMenuItemEx;
    vRes :Integer;
  begin
    FillChar(vItems, SizeOf(vItems), 0);

    SetMenuItemChr(@vItems[0], 'Sync folder');
    if optSyncFolder then
      vItems[0].Flags := MIF_CHECKED;

    SetMenuItemChr(@vItems[1], 'Notify error');
    if optSyncFolder and optNotifyError then
      vItems[1].Flags := MIF_CHECKED;

    vRes := FARAPI.Menu(hModule, -1, -1, 0,
      FMENU_WRAPMODE or FMENU_USEEXT,
      'Options',
      '',
      '',
      nil, nil,
      @vItems,
      High(vItems)+1);
    if vRes = -1 then
      Exit;

    case vRes of
      0: optSyncFolder := not optSyncFolder;
      1: optNotifyError := not optNotifyError;
    end;

    WriteSettings;
  end;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  function GetMinFarVersionW :Integer; stdcall;
  begin
    Result := MakeFarVersion(2, 0, 1148);
  end;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));
    FRegRoot := psi.RootKey;

    ReadSettings;
    if optNormColor = 0 then begin
      optNormColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_COMMANDLINEPREFIX));
      WriteSettings;
    end;

    SetCheckThread(True);
    UpdateColor(True);
  end;


  var
    ConfigMenuStrings: array[0..0] of PFarChar;

  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_PRELOAD;

    ConfigMenuStrings[0]:= 'Path Synchonizer';
    pi.PluginConfigStrings := @ConfigMenuStrings;
    pi.PluginConfigStringsNumber := 1;
  end;


  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  var
    vPath  :TString;
    vSetOk :Boolean;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);
    Result := 0;
    if Event <> SE_COMMONSYNCHRO then
      Exit;

    vPath := FarGetCurrentDirectory;
    if vPath <> FLastPath then begin
//    TraceF('Len=%d, Path=%s', [Length(vPath), vPath]);
      vSetOk := SetCurrentDir(vPath);
      if vSetOk then
        vSetOk := StrEqual(vPath, GetCurrentDir);
      UpdateColor(vSetOk);
      FLastPath := vPath;
    end;
  end;

(*
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  var
    vInfo  :TPanelInfo;
    vPath  :TString;
    vSetOk :Boolean;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);
    Result := 0;
    if Event <> SE_COMMONSYNCHRO then
      Exit;

    FillChar(vInfo, SizeOf(vInfo), 0);
    FARAPI.Control(THandle(PANEL_ACTIVE), FCTL_GetPanelInfo, 0, @vInfo);

    if (vInfo.PanelType = PTYPE_FILEPANEL) and (vInfo.Plugin = 0) then begin
      vPath := FarPanelGetCurrentDirectory(THandle(PANEL_ACTIVE));
      if vPath <> FLastPath then begin
//      TraceF('Len=%d, Path=%s', [Length(vPath), vPath]);
        vSetOk := SetCurrentDir(vPath);
        if vSetOk then
          vSetOk := StrEqual(vPath, GetCurrentDir);
        UpdateColor(vSetOk);
        FLastPath := vPath;
      end;
    end else
    begin
      UpdateColor(True);
      FLastPath := '';
    end;
  end;
*)


  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    OptionsMenu;
    Result := 1;
  end;


  procedure ExitFARW; stdcall;
  begin
    UpdateColor(True);
    SetCheckThread(False);
  end;


initialization
finalization
  FreeObj(CheckThread);
end.


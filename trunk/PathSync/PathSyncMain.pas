{$I Defines.inc}

unit PathSyncMain;

{******************************************************************************}
{* (c) 2009-2012 Max Rusov                                                    *}
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

    FAR_API,
    FarCtrl,
    FarMenu,
    FarConfig,
    FarPlug;


  const
    cPluginName = 'PathSync';
    cPluginDescr = 'PathSync FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{D627DF7C-6F58-4E6B-88A3-DDD7102DEC99}';
//  cMenuID     :TGUID = '{3A0DD20B-6B24-442A-BB0D-3122E935CEAD}';
    cConfigID   :TGUID = '{6F42D34A-3C9A-4B5B-A44D-B064ED21305B}';
   {$else}
   {$endif Far3}

  const
    cPlugRegFolder = 'PathSync';

  var
    optSyncFolder  :Boolean = True;
    optNotifyError :Boolean = True;
    optStoreFolder :Boolean = True;

    optNormColor   :TFarColor; // = $00;
    optErrorColor  :TFarColor; // = $0C;


  type
    TPathSyncPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      procedure SynchroEvent(AParam :Pointer); override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

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


  procedure FarSetColor(AIndex :TPaletteColors; AColor :TFarColor);
  var
    vInfo :TFarSetColors;
  begin
    FillZero(vInfo, SizeOf(vInfo));
   {$ifdef Far3}
    vInfo.Flags := FSETCLR_REDRAW;
   {$else}
    vInfo.Flags := FCLR_REDRAW;
   {$endif Far3}
    vInfo.StartIndex := Byte(AIndex);
    vInfo.ColorCount := 1;
    vInfo.Colors := Pointer(@AColor);
    FarAdvControl(ACTL_SETARRAYCOLOR, @vInfo);
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

  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

        LogValue('SyncFolder', optSyncFolder);
        LogValue('NotifyError', optNotifyError);
        LogValue('StoreFolder', optStoreFolder);

        ColorValue('NormColor', optNormColor);
        ColorValue('ErrorColor', optErrorColor);

      finally
        Destroy;
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
        FarAdvControl(ACTL_SYNCHRO, nil);
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
      if AOn then
        CheckThread := TCheckThread.Create(False)
      else
        FreeObj(CheckThread);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      'Options',
    [
      'Sync folder',
      'Notify error',
      'Store folder'
    ]);
    try
      vMenu.Checked[0] := optSyncFolder;
      vMenu.Checked[1] := optSyncFolder and optNotifyError;
      vMenu.Checked[2] := optStoreFolder;

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: optSyncFolder := not optSyncFolder;
        1: optNotifyError := not optNotifyError;
        2: optStoreFolder := not optStoreFolder;
      end;

      PluginConfig(True);

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TPathSyncPlug                                                               }
 {-----------------------------------------------------------------------------}

  procedure TPathSyncPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
//  FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
//  FMinFarVer := MakeVersion(3, 0, ....);
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1180);  {GetCurrentDirectory}
   {$endif Far3}
  end;


  procedure TPathSyncPlug.Startup; {override;}
  begin
    optErrorColor := MakeColor(clRed, clBlack);

    PluginConfig(False);
    if IsUndefColor(optNormColor) then begin
      optNormColor := FarGetColor(COL_COMMANDLINEPREFIX);
      PluginConfig(True);
    end;

    SetCheckThread(True);
    UpdateColor(True);
  end;


  procedure TPathSyncPlug.ExitFar; {override;}
  begin
    UpdateColor(True);
    SetCheckThread(False);
  end;


  procedure TPathSyncPlug.GetInfo; {override;}
  begin
    FFlags:= PF_PRELOAD;

    FConfigStr := 'Path Synchonizer';
   {$ifdef Far3}
    FConfigID := cConfigID;
   {$endif Far3}
  end;


  procedure TPathSyncPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  procedure TPathSyncPlug.SynchroEvent(AParam :Pointer); {override;}
  var
    vPath  :TString;
    vSetOk :Boolean;
  begin
    vPath := FarGetCurrentDirectory;
    if vPath <> FLastPath then begin
     {$ifdef bTrace}
      TraceF('Len=%d, Path=%s', [Length(vPath), vPath]);
     {$endif bTrace}

      if optSyncFolder then begin
        vSetOk := SetCurrentDir(vPath);
        if vSetOk then
          vSetOk := StrEqual(vPath, GetCurrentDir);
        UpdateColor(vSetOk);
        FLastPath := vPath;
      end;

      if optStoreFolder then
        RegSetStrValue(HKCU, 'Software\Far2\Panel', 'CurrentFolder', vPath);
    end;
  end;


initialization
finalization
  FreeObj(CheckThread);
end.


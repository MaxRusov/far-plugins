{$I Defines.inc}

{$Define bSyncThread}

unit SameFolderMain;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Same Folder Plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    Far_API,
    FarCtrl,
    FarConfig,
    FarMenu,
    FarPlug;

  type
    TMessages = (
      strSameFolder,

      strMSameFolder,
      strMFolderUnderCursor,
      strMSameAsPassive,
      strMAutofollowMode,

      strAddPlugMenu,
      strAddDiskMenu
    );

  const
    cPluginName = 'SameFolderPlus';
    cPluginDescr = 'SameFolder+ FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{483AC82A-5FBB-45D9-8330-2BE2FAB568F7}';
    cMenuID     :TGUID = '{85AC9691-5049-4924-A148-1E2877E35A02}';
    cDiskID     :TGUID = '{69DD2403-F52B-47A4-8320-2F17EA9750DC}';
    cConfigID   :TGUID = '{E0CB07DF-FCE9-4CE9-95E3-568BD661AE3D}';
   {$else}
    cPluginID   = $44464D53;  //SMFD
   {$endif Far3}

    cSyncDelay  = 100;

    
  var
    optShowInPluginMenu :Boolean = True;
    optShowInDiskMenu   :Boolean = False;

  var
    AutofollwMode :Boolean;


  type
    TSameFolderPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure GetInfo; override;
      procedure ExitFar; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
     {$ifdef Far3}
      function ConsoleInput(const ARec :TInputRecord) :Integer; override;
     {$endif Far3}
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;

 {$ifdef Far3}
  function GetPluginPath(AHandle :THandle) :TString;
  var
    vFrmt, vPrefix, vPath, vHost :TString;
  begin
    Result := '';

    vFrmt := FarPanelString(AHandle, FCTL_GETPANELFORMAT);
    vPrefix := FarPanelString(AHandle, FCTL_GETPANELPREFIX);
    vHost := FarPanelString(AHandle, FCTL_GETPANELHOSTFILE);
    vPath := FarPanelGetCurrentDirectory(AHandle);
   {$ifdef bTrace}
    TraceF('Format=%s, Prefix=%s, Path=%s, Host=%s', [vFrmt, vPrefix, vPath, vHost]);
   {$endif bTrace}

    if StrEqual(vPrefix, 'FTP') then begin
      if UpCompareSubStr('//Hosts', vFrmt) = 0 then
        Exit;
      Result := 'FTP:' + vFrmt;
      if Result[length(Result)] <> '/' then
        Result := Result + '/';
    end else
    if UpCompareSubStr('NetBox', vPrefix) = 0 then begin
      if StrEqual('NetBox', vFrmt) then
        Exit;
      Result := 'Netbox:' + vFrmt + vPath;
    end else
    if StrEqual(vFrmt, 'Network') then begin
      if (vPath = '') or (vPath[1] <> '\') then
        Exit;
      Result := 'NET:' + vPath;
    end else
    if (vPrefix <> '') and ((vHost <> '') or (vPath <> '')) then begin
      {Reg: Arc: Observe: SQLite:}
      Result := vPrefix;
      if vHost <> '' then
        Result := Result + ':' + vHost;
      if vPath <> '' then
        Result := Result + ':' + vPath;
    end;
  end;

 {$else}

  function GetPluginPath(AHandle :THandle) :TString;
  var
    vFrmt, vPath, vHost :TString;
  begin
    Result := '';

    vFrmt := FarPanelString(AHandle, FCTL_GETPANELFORMAT);
    vHost := FarPanelString(AHandle, FCTL_GETPANELHOSTFILE);
    vPath := FarPanelGetCurrentDirectory(AHandle);

   {$ifdef bTrace}
    TraceF('Format=%s, Path=%s, Host=%s', [vFrmt, vPath, vHost]);
   {$endif bTrace}

    if UpCompareSubStr('//', vFrmt) = 0  then begin
      {FTP плагин}

      if UpCompareSubStr('//Hosts', vFrmt) = 0 then
        Exit;

      Result := 'FTP:' + vFrmt;
      if Result[length(Result)] <> '/' then
        Result := Result + '/';

    end else
    if StrEqual(vFrmt, 'NETWORK') then begin

      if (vPath = '') or (vPath[1] <> '\') then
        Exit;
      Result := 'NET:' + vPath;

    end else
    if (vFrmt <> '') and (vHost = '')
//    StrEqual(vFrmt, 'REG') or
//    StrEqual(vFrmt, 'REG2') or
//    StrEqual(vFrmt, 'PDA') or
//    StrEqual(vFrmt, 'PPC')
    then
      { "Правильные" плагины }
      Result := vFrmt + ':' + vPath;
  end;
 {$endif Far3}


  procedure FarPanelSetPath(AHandle :THandle; const APath, AItem :TString);
  var
    vOldPath :TFarStr;
  begin
    vOldPath := FarPanelGetCurrentDirectory(AHandle);
    if not StrEqual(vOldPath, APath) then begin
     {$ifdef bTrace}
//    TraceF('SePath=%s', [APath]);
     {$endif bTrace}
      FarPanelSetDir(AHandle, APath);
      if AItem = '' then
        FARAPI.Control(AHandle, FCTL_REDRAWPANEL, 0, nil);
    end;

    if AItem <> '' then
      FarPanelSetCurrentItem(AHandle = PANEL_ACTIVE, AItem)
  end;


  procedure SameFolder(ASetPassive, AddCurrent, AutoFollow :Boolean);
  var
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
    vPath, vFile, vMacro, vStr :TString;
    vVisible, vPlugin, vFolder, vRealFolder, vProceedFile :Boolean;
    vSrcPanel, vDstPanel :THandle;
  begin
    vSrcPanel := HandleIf(ASetPassive, PANEL_ACTIVE, PANEL_PASSIVE);
    vDstPanel := HandleIf(ASetPassive, PANEL_PASSIVE, PANEL_ACTIVE);

    FarGetPanelInfo(vSrcPanel, vInfo);

    vVisible := IsVisiblePanel(vInfo);
    vPlugin := IsPluginPanel(vInfo);

    if (vInfo.PanelType <> PTYPE_FILEPANEL) or not vVisible then
      begin beep; exit; end;

    vProceedFile := True;
    vRealFolder := not vPlugin or (PFLAGS_REALNAMES and vInfo.Flags <> 0);

    if vRealFolder then begin
      vPath := FarPanelGetCurrentDirectory(vSrcPanel);

      if vPlugin and FileNameIsUNC(vPath) and (LastDelimiter('\', vPath) <= 2) then begin
        { Исключение для плагина Network }
//      vPath := ConvertPluginPath(ClearTitle(GetConsoleTitleStr));
        vPath := GetPluginPath(vSrcPanel);

        vRealFolder := False;
        AddCurrent := False;
      end;

    end else
    begin
      { За неимением подходящего API - анализируем заголовок консоли}
//    vPath := ConvertPluginPath(ClearTitle(GetConsoleTitleStr));

      { А вот и API подоспело... }
      vPath := GetPluginPath(vSrcPanel);

      if vPath = '' then begin
        { Неподдерживаемый плагин. Устанавливаем текущий путь _под_ плагинной панелью }
        vPath := FarGetCurrentDirectory;
        vFile := ExtractFileName(FarPanelString(vSrcPanel, FCTL_GETPANELHOSTFILE));
        vRealFolder := True;
        vProceedFile := False;
      end;
    end;

    if vProceedFile and (Integer(vInfo.CurrentItem) >= 0) and (vInfo.CurrentItem < vInfo.ItemsNumber) then begin
//    vFile := FarPanelItemName(PANEL_ACTIVE, FCTL_GETPANELITEM, vInfo.CurrentItem);
      vItem := FarPanelItem(vSrcPanel, FCTL_GETPANELITEM, vInfo.CurrentItem);
      if vItem <> nil then begin
        try
          vFile := vItem.FileName;
          vFolder := faDirectory and vItem.FileAttributes <> 0;

          if vFile <> '..' then begin
            if vRealFolder and (vPath = '') then begin
              vPath := RemoveBackSlash(ExtractFilePath(vFile));
              vFile := ExtractFileName(vFile);
            end;

            if AddCurrent and vFolder then begin
              vPath := AddFileName(vPath, vFile);
              vFile := '';
            end;
          end else
          begin
            if AddCurrent then
              vPath := RemoveBackSlash(ExtractFilePath(vPath));
          end;
        finally
          MemFree(vItem);
        end;
      end;
    end;

   {$ifdef bTrace}
    TraceF('Path=%s, File=%s', [vPath, vFile]);
   {$endif bTrace}

    if vPath <> '' then begin

      FarGetPanelInfo(vDstPanel, vInfo);
     {$ifdef Far3}
      vVisible := PFLAGS_VISIBLE and vInfo.Flags <> 0;
     {$else}
      vVisible := vInfo.Visible <> 0;
     {$endif Far3}

      vMacro := '';
      case vInfo.PanelType of
        PTYPE_FILEPANEL:
          if not vVisible then
            vMacro := FarKeyToMacro('CtrlP');
        PTYPE_TREEPANEL:
          vMacro := FarKeyToMacro('CtrlT');
        PTYPE_QVIEWPANEL:
          vMacro := FarKeyToMacro('CtrlQ');
        PTYPE_INFOPANEL:
          vMacro := FarKeyToMacro('CtrlL');
      end;

      if AutoFollow and (vMacro <> '') then
        Exit;

      if vRealFolder and (vMacro = '') then
        { Установка каталога и файла через API }
        FarPanelSetPath(vDstPanel, vPath, vFile)
      else begin
        { ...или через макрос }
        if vMacro <> '' then
          vMacro := vMacro + ' ';

        if vRealFolder then begin
          vMacro := vMacro +
            'Panel.SetPath('  +
            StrIf(ASetPassive, '1', '0') + ', ' +
            FarStrToMacro(vPath) +
            StrIf(vFile <> '', ', ' + FarStrToMacro(vFile), '') +
            ')';
        end else
        begin
          vStr := '';
          FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(vStr));
          vMacro := vMacro +
           {$ifdef Far3}
            'Far.DisableHistory(1) ' +
           {$endif Far3}
            'print(' + FarStrToMacro(vPath) + ') ' + FarKeyToMacro('Enter');
          if ASetPassive then
            vMacro := FarKeyToMacro('Tab') + ' ' + vMacro + ' ' + FarKeyToMacro('Tab');
          if vFile <> '' then
            vMacro := vMacro +
              ' Panel.SetPos(' + StrIf(ASetPassive, '1', '0') + ', ' + FarStrToMacro(vFile) + ')';
        end;

        FarPostMacro(vMacro);
      end;
    end;
  end; {SameFolder}


 {-----------------------------------------------------------------------------}

  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

        LogValue('ShowInPluginMenu', optShowInPluginMenu);
        LogValue('ShowInDiskMenu', optShowInDiskMenu);

      finally
        Destroy;
      end;
  end;


  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strSameFolder),
    [
      GetMsg(strAddPlugMenu),
      GetMsg(strAddDiskMenu)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optShowInPluginMenu;
        vMenu.Checked[1] := optShowInDiskMenu;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: optShowInPluginMenu := not optShowInPluginMenu;
          1: optShowInDiskMenu := not optShowInDiskMenu;
        end;
        PluginConfig(True);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCheckThread                                                                }
 {-----------------------------------------------------------------------------}

 {$ifdef bSyncThread}

  function AlertableSleep(APeriod :Cardinal) :Boolean;
  begin
//  TraceF('Sleep: %d', [APeriod]);
//  Sleep(APeriod);
    Result := WaitForSingleObject(hStdin, APeriod) <> WAIT_TIMEOUT;
  end;


  function CheckInput :Boolean;
  var
    I, vCount :Integer;
    vBuf :array[0..16] of Windows.TInputRecord;
  begin
    Result := False;
    if PeekConsoleInput(hStdin, vBuf[0], High(vBuf), DWORD(vCount)) then begin
      for I := 0 to vCount - 1 do
        with vBuf[I] do
          if (EventType = KEY_EVENT) or (EventType = _MOUSE_EVENT) then begin
            Result := True;
            Exit;
          end;
    end;
  end;


  type
    TSyncThread = class(TThread)
    public
      procedure Execute; override;
    end;


  procedure TSyncThread.Execute; {override;}
  var
    vWasInput :Boolean;
    vStartTime :DWORD;
  begin
    vStartTime := 0;
    while not Terminated do begin
      vWasInput := CheckInput;
      if vWasInput then
        vStartTime := GetTickCount;

      if (vStartTime <> 0) and (TickCountDiff(GetTickCount, vStartTime) > cSyncDelay) then begin
        vStartTime := 0;
        FarAdvControl(ACTL_SYNCHRO, nil);
      end;

      if vWasInput then
        Sleep(1)
      else
        AlertableSleep(100);
    end;
  end;


  var
    SyncThread :TSyncThread;

  procedure SetSyncThread(AOn :Boolean);
  begin
    if AOn <> (SyncThread <> nil) then begin
      if AOn then
        SyncThread := TSyncThread.Create(False)
      else
        FreeObj(SyncThread);
      AutofollwMode := AOn;
    end;
  end;

 {$else}

  procedure SetSyncThread(AOn :Boolean);
  begin
    AutofollwMode := AOn;
  end;

 {$endif bSyncThread}


 {-----------------------------------------------------------------------------}

  var
    LockedSide   :Integer;
    LockedFolder :TString;
    LastFile     :TString;


  procedure SetAutofollowMode;
  begin
    LockedSide := FarPanelGetSide;
    LockedFolder := FarPanelGetCurrentDirectory(PANEL_ACTIVE);
    LastFile := FarPanelItemName(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0);
    SetSyncThread(True);
  end;


  procedure CheckAutofollow;
  var
    vWinInfo :TWindowInfo;
    vSide :Integer;
    vFile :TString;
//  vFolder :TString;
  begin
    FarGetWindowInfo(-1, vWinInfo);
    if vWinInfo.WindowType <> WTYPE_PANELS then
      Exit;

    vSide := FarPanelGetSide;
//  vFolder := FarPanelGetCurrentDirectory(PANEL_ACTIVE);
    if (vSide = LockedSide) {and StrEqual(vFolder, LockedFolder)} then begin
      vFile := FarPanelItemName(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0);
      if not StrEqual(vFile, LastFile) then begin
        SameFolder(True, True, True);
        LastFile := vFile;
      end;
    end else
      {SetSyncThread(False)};
  end;


  procedure ToggleAutofollow;
  begin
    if not AutofollwMode then begin
      SameFolder(True, True, False);
      SetAutofollowMode;
    end else
      SetSyncThread(False);
  end;


  procedure PluginCmd(ACmd :Integer);
  begin
    case ACmd of
      0: SameFolder(True, False, False);
      1: SameFolder(True, True, False);
      2: SameFolder(False, False, False);
      3: ToggleAutofollow;
    end;
  end;



  procedure MainMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strSameFolder),
    [
      GetMsg(strMSameFolder),
      GetMsg(strMFolderUnderCursor),
      GetMsg(strMSameAsPassive),
      '',
      GetMsg(strMAutofollowMode)
    ]);
    try
      vMenu.Checked[4] := AutofollwMode;

      if not vMenu.Run then
        Exit;

      if vMenu.ResIdx = 4 then
        PluginCmd(3)
      else
        PluginCmd(vMenu.ResIdx)

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TSameFolderPlug                                                             }
 {-----------------------------------------------------------------------------}

  procedure TSameFolderPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
    FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
//  FMinFarVer := MakeVersion(3, 0, 2343);   { FCTL_GETPANELDIRECTORY/FCTL_SETPANELDIRECTORY }
//  FMinFarVer := MakeVersion(3, 0, 2460);   { OPEN_FROMMACRO }
//  FMinFarVer := MakeVersion(3, 0, 2572);   { Api changes }
    FMinFarVer := MakeVersion(3, 0, 3000);
   {$else}
//  FMinFarVer := MakeVersion(2, 0, 1652);   { "verbatim string" }
    FMinFarVer := MakeVersion(2, 0, 1657);   { FCTL_GETPANELFORMAT }
   {$endif Far3}

    hStdin := GetStdHandle(STD_INPUT_HANDLE);
  end;


  procedure TSameFolderPlug.GetInfo; {override;}
  begin
    PluginConfig(False);

    FConfigStr := GetMsg(strSameFolder);

    FMenuStr := '';
    if optShowInPluginMenu then
      FMenuStr := FConfigStr;

    FDiskStr := '';
    if optShowInDiskMenu then
      FDiskStr := FConfigStr;

   {$ifdef Far3}
    FMenuID    := cMenuID;
    FDiskID    := cDiskID;
    FConfigID  := cConfigID;
   {$endif Far3}
  end;


  procedure TSameFolderPlug.ExitFar; {override;}
  begin
    SetSyncThread(False);
  end;


  procedure TSameFolderPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  function TSameFolderPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  var
    vSetPassive :Boolean;
  begin
    Result:= INVALID_HANDLE_VALUE;
    if AFrom in [OPEN_DISKMENU {$ifdef Far3}, OPEN_RIGHTDISKMENU {$endif Far3}] then begin
     {$ifdef Far3}
      vSetPassive := (FarPanelGetSide = 0{Left}) = (AFrom = OPEN_RIGHTDISKMENU);
     {$else}
      vSetPassive := True;
     {$endif Far3}
      SameFolder(vSetPassive, False, False);
    end else
      MainMenu;
  end;


  function TSameFolderPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;
    if AInt >= 0 then begin
      PluginCmd(AInt);
      Exit;
    end;
    MainMenu;
  end;


  procedure TSameFolderPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
    CheckAutofollow;
  end;


 {$ifdef Far3}
  function TSameFolderPlug.ConsoleInput(const ARec :TInputRecord) :Integer; {override;}
  begin
    Result := 0;
    if AutofollwMode then begin
//    TraceF('ConsoleInput: %d', [ARec.EventType]);
      if (ARec.EventType = KEY_EVENT) or (ARec.EventType = _MOUSE_EVENT) then
        {};
    end;
  end;
 {$endif Far3}


initialization
finalization
 {$ifdef bSyncThread}
  FreeObj(SyncThread);
 {$endif bSyncThread}
end.

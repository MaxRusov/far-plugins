{$I Defines.inc}

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

    PluginW,
    FarCtrl;

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
    cPluginGUID     = $44464D53;    //SMFD

    cSyncDelay      = 100;

  const
    cPlugRegFolder    :TString = 'SameFolder';
    cShowInPluginMenu :TString = 'ShowInPluginMenu';
    cShowInDiskMenu   :TString = 'ShowInDiskMenu';


  var
    optShowInPluginMenu :Boolean = True;
    optShowInDiskMenu   :Boolean = False;

  var
    FRegRoot :TString;

  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  procedure ExitFARW; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;


(*
  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..1024] of TChar;
  begin
    FillChar(vBuf, SizeOf(vBuf), $00);
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;
  end;


  function ClearTitle(const AStr :TString) :TString;
  var
    vPos :Integer;
  begin
    Result := '';
    if (AStr <> '') and (AStr[1] = '{') then begin
      vPos := ChrsLastPos(['}'], AStr);
      if vPos <> 0 then
        Result := Copy(AStr, 2, vPos - 2);
    end;
  end;


  function ConvertPluginPath(const APath :TString) :TString;
  var
    vFolder :TString;
    vPos :Integer;
  begin
    if UpCompareSubStr('FTP:', APath) = 0 then begin
      Result := '';

      vFolder := Trim(ExtractWords(2, MaxInt, APath, [':']));
      if (vFolder = '') or (vFolder[1] = '\') then
        Exit;

      vPos := ChrPos('@', vFolder);
      if vPos <> 0 then
        vFolder := Copy(vFolder, vPos + 1, MaxInt);

      Result := 'FTP://' + vFolder;
      if Result[Length(Result)] <> '/' then
        Result := Result + '/';

    end else
    if UpCompareSubStr('NETWORK:', APath) = 0 then begin
      Result := '';

      vFolder := Trim(ExtractWords(2, MaxInt, APath, [':']));
      if (vFolder = '') or (vFolder[1] <> '\') then
        Exit;

      Result := 'NET:' + vFolder;

    end else
    if (UpCompareSubStr('PDA:', APath) = 0) or
      (UpCompareSubStr('КПК:', APath) = 0) then
    begin
      { Убираем размер свободного места, который может выводится в заголовке... }
      Result := 'PDA:' + ExtractWord(2, APath, [':']);
    end else
    if (UpCompareSubStr('FILES:', APath) = 0) or
      (UpCompareSubStr('REGISTRY:', APath) = 0) then
    begin
      Result := 'PPC:' + APath;
    end else
    if (UpCompareSubStr('REG:', APath) = 0) or
      (UpCompareSubStr('REG2:', APath) = 0)
    then
      Result := APath
    else
      { Unknown plugin }
      Result := '';
  end;
*)


  function GetPluginPath(AHandle :THandle) :TString;
  var
    vFrmt, vPath, vHost :TString;
  begin
    Result := '';

    vFrmt := FarPanelString(AHandle, FCTL_GETPANELFORMAT);
    vPath := FarPanelString(AHandle, FCTL_GETPANELDIR);
    vHost := FarPanelString(AHandle, FCTL_GETPANELHOSTFILE);

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


  procedure FarPanelSetPath(AHandle :THandle; const APath, AItem :TString);
  var
    vOldPath :TFarStr;
  begin
    vOldPath := FarPanelGetCurrentDirectory(AHandle);
    if not StrEqual(vOldPath, APath) then begin
     {$ifdef bTrace}
//    TraceF('SePath=%s', [APath]);
     {$endif bTrace}
      FARAPI.Control(AHandle, FCTL_SETPANELDIR, 0, PFarChar(APath));
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
    vRealFolder, vProceedFile :Boolean;
    vSrcPanel, vDstPanel :THandle;
  begin
    vSrcPanel := HandleIf(ASetPassive, PANEL_ACTIVE, PANEL_PASSIVE);
    vDstPanel := HandleIf(ASetPassive, PANEL_PASSIVE, PANEL_ACTIVE);

    FillChar(vInfo, SizeOf(vInfo), 0);
    FARAPI.Control(vSrcPanel, FCTL_GetPanelInfo, 0, @vInfo);

    if (vInfo.PanelType <> PTYPE_FILEPANEL) or (vInfo.Visible = 0) then
      begin beep; exit; end;

    vProceedFile := True;
    vRealFolder := (vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0);

    if vRealFolder then begin
      vPath := FarPanelGetCurrentDirectory(vSrcPanel);

      if (vInfo.Plugin = 1) and FileNameIsUNC(vPath) and (LastDelimiter('\', vPath) <= 2) then begin
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

    if vProceedFile and (vInfo.CurrentItem >= 0) and (vInfo.CurrentItem < vInfo.ItemsNumber) then begin
//    vFile := FarPanelItemName(PANEL_ACTIVE, FCTL_GETPANELITEM, vInfo.CurrentItem);
      vItem := FarPanelItem(vSrcPanel, FCTL_GETPANELITEM, vInfo.CurrentItem);
      if vItem <> nil then begin
        try
          vFile := vItem.FindData.cFileName;
          if vFile <> '..' then begin
            if vRealFolder and (vPath = '') then begin
              vPath := RemoveBackSlash(ExtractFilePath(vFile));
              vFile := ExtractFileName(vFile);
            end;

            if AddCurrent and (faDirectory and vItem.FindData.dwFileAttributes <> 0) then begin
              vPath := AddFileName(vPath, vFile);
              vFile := '';
            end;
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

      FillChar(vInfo, SizeOf(vInfo), 0);
      FARAPI.Control(vDstPanel, FCTL_GetPanelInfo, 0, @vInfo);

      vMacro := '';
      case vInfo.PanelType of
        PTYPE_FILEPANEL:
          if vInfo.Visible = 0 then
            vMacro := 'CtrlP';
        PTYPE_TREEPANEL:
          vMacro := 'CtrlT';
        PTYPE_QVIEWPANEL:
          vMacro := 'CtrlQ';
        PTYPE_INFOPANEL:
          vMacro := 'CtrlL';
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
            'panel.setpath('  + StrIf(ASetPassive, '1', '0') + ', @"' + vPath + '"' +
            StrIf(vFile <> '', ', @"' + vFile + '"', '') +
            ')';
        end else
        begin
          vStr := '';
          FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(vStr));
          vMacro := vMacro +
            'print(@"' + vPath + '") Enter';
          if ASetPassive then
            vMacro := 'Tab ' + vMacro + ' Tab';
          if vFile <> '' then
            vMacro := vMacro +
              ' panel.setpos(' + StrIf(ASetPassive, '1', '0') + ', @"' + vFile + '")';
        end;

        FarPostMacro(vMacro);
      end;
    end;

  end; {SameFolder}


 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optShowInPluginMenu := RegQueryLog(vKey, cShowInPluginMenu, optShowInPluginMenu);
      optShowInDiskMenu := RegQueryLog(vKey, cShowInDiskMenu, optShowInDiskMenu);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, cShowInPluginMenu, optShowInPluginMenu);
      RegWriteLog(vKey, cShowInDiskMenu, optShowInDiskMenu);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure OptionsMenu;
  var
    I, N, vRes :Integer;
    vItems :PFarMenuItemsArray;
  begin
    vItems := FarCreateMenu([
      GetMsg(strAddPlugMenu),
      GetMsg(strAddDiskMenu)
    ], @N);
    try
      vRes := 0;
      while True do begin
        vItems[0].Flags  := SetFlag(0, MIF_CHECKED1, optShowInPluginMenu);
        vItems[1].Flags  := SetFlag(0, MIF_CHECKED1, optShowInDiskMenu);

        for I := 0 to N - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strSameFolder),
          '',
          '',
          nil, nil,
          Pointer(vItems),
          N);

        if vRes = -1 then
          Exit;

        case vRes of
          0:  optShowInPluginMenu := not optShowInPluginMenu;
          1:  optShowInDiskMenu := not optShowInDiskMenu;
        end;
        WriteSetup;
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCheckThread                                                                }
 {-----------------------------------------------------------------------------}

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
        FARAPI.AdvControl(hModule, ACTL_SYNCHRO, nil);
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
    end;
  end;


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
    if SyncThread = nil then begin
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
    N, vRes :Integer;
    vItems :PFarMenuItemsArray;
  begin
    vItems := FarCreateMenu([
      GetMsg(strMSameFolder),
      GetMsg(strMFolderUnderCursor),
      GetMsg(strMSameAsPassive),
      '',
      GetMsg(strMAutofollowMode)
    ], @N);
    try
      vItems[4].Flags  := SetFlag(0, MIF_CHECKED1, SyncThread <> nil);

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(strSameFolder),
        '',
        '',
        nil, nil,
        Pointer(vItems),
        N);

      if vRes <> -1 then begin
        if vRes = 4 then
          vRes := 3;
        PluginCmd(vRes);
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := MakeFarVersion(2, 0, 1652);   { "verbatim string" }
    Result := MakeFarVersion(2, 0, 1657);   { FCTL_GETPANELFORMAT }
  end;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    FRegRoot := psi.RootKey;
    ReadSetup;
  end;


  var
    PluginMenuStrings : array[0..0] of PFarChar;
    DiskMenuStrings   : array[0..0] of PFarChar;
    ConfigMenuStrings : array[0..0] of PFarChar;


  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= 0;

    if optShowInPluginMenu then begin
      PluginMenuStrings[0] := GetMsg(strSameFolder);
      pi.PluginMenuStrings := Pointer(@PluginMenuStrings);
      pi.PluginMenuStringsNumber := 1;
    end;

    if optShowInDiskMenu then begin
      DiskMenuStrings[0] := GetMsg(strSameFolder);
      pi.DiskMenuStrings := Pointer(@DiskMenuStrings);
      pi.DiskMenuStringsNumber := 1;
    end;

    ConfigMenuStrings[0]:= GetMsg(strSameFolder);
    pi.PluginConfigStrings := Pointer(@ConfigMenuStrings);
    pi.PluginConfigStringsNumber := 1;

    pi.Reserved := cPluginGUID;
  end;


  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);

    if OpenFrom and OPEN_FROMMACRO <> 0 then
      PluginCmd(Item)
    else
    if OpenFrom = OPEN_DISKMENU then begin
      PluginCmd(0)
    end else
      MainMenu;
  end;


  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);
    Result := 0;
    if Event <> SE_COMMONSYNCHRO then
      Exit;
    CheckAutofollow;
  end;


  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    OptionsMenu;
    Result := 1;
  end;


  procedure ExitFARW; stdcall;
  begin
    SetSyncThread(False);
  end;


initialization
finalization
  FreeObj(SyncThread);
end.

{$I Defines.inc}       
{$Typedaddress Off}

unit MoreHistoryMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarConMan,
    MoreHistoryCtrl,
    MoreHistoryClasses,
    MoreHistoryDlg;


 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  procedure ExitFAR; stdcall;
  function OpenPlugin(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$endif bUnicodeFar}

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}

  var
    hFarWindow  :THandle = THandle(-1);
    hConEmuWnd  :THandle = THandle(-1);


  function hConsoleWnd :THandle;
  var
    hWnd :THandle;
  begin
    Result := hFarWindow;
    if not IsWindowVisible(hFarWindow) then begin
      { Запущено из-под ConEmu?... }
      hWnd := GetAncestor(hFarWindow, GA_PARENT);

      if (hWnd = 0) or (hWnd = GetDesktopWindow) then begin
        { Новая версия ConEmu не делает SetParent... }
        if hConEmuWnd = THandle(-1) then
          hConEmuWnd := CheckConEmuWnd;
        hWnd := hConEmuWnd;
      end;

      if hWnd <> 0 then
        Result := hWnd;
    end;
  end;


  function IsActiveConsole :boolean;
  begin
    Result := WindowIsChildOf(hConsoleWnd, GetForegroundWindow) and ConManIsActiveConsole;
  end;


 {-----------------------------------------------------------------------------}
 { THistThread                                                                 }
 {-----------------------------------------------------------------------------}

  type
    THistThread = class(TThread)
    public
      procedure Execute; override;
    end;


  procedure THistThread.Execute; {override;}
  var
    vLastTitle, vLastPath, vStr :TString;
    vActive, vLastActive :Boolean;
  begin
    vLastActive := False;

    vLastTitle := '';
    vLastPath := '';
//  FarHistory.RestoreHistory;

    while not Terminated do begin

//    if CanCheckWindow then
//      { Контролируем смену консольного окна (на случай Detach'а консоли) }
//      hFarWindow := GetConsoleWindow;

      vActive := IsActiveConsole;
      if vActive <> vLastActive then begin
        if vActive then begin
//        Trace('Far Active Now...');
          vLastActive := True;
        end else
        begin
//        Trace('Go sleep...');
          if FarHistory.TryLockHistory then begin
            try
              try
                FarHistory.StoreModifiedHistory;
              except
              end;
              vLastActive := False;
            finally
              FarHistory.UnlockHistory;
            end;
          end;
        end;
      end;

      if vActive then begin
        vStr := GetConsoleTitleStr;
        if vStr <> vLastTitle then begin

          if FarHistory.TryLockHistory then begin
            try
              vLastTitle := vStr;
              vStr := ClearTitle(vStr);

              try
                FarHistory.LoadModifiedHistory;
              except
              end;

              if (vLastPath <> '') and (vStr = '') then begin
                try
                  FarHistory.AddHistory(vLastPath, True);
                except
                end;
              end;

              if vStr <> '' then begin
                vLastPath := vStr;
                try
                  FarHistory.AddHistory(vStr, False);
                except
                end;
              end;

            finally
              FarHistory.UnlockHistory;
            end;
          end;

        end;
      end;

      Sleep(100);
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    HistThread :THistThread;

  procedure SetHistoryWatcher(AOn :Boolean);
  begin
    if AOn <> (HistThread <> nil) then begin
      if AOn then 
        HistThread := THistThread.Create(False)
      else
        FreeObj(HistThread);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CheckPanelExists :Boolean;
  var
    vWinInfo :TWindowInfo;
  begin
    Result := False;
   {$ifdef bUnicodeFar}
    if FARAPI.Control(hModule, FCTL_CHECKPANELSEXIST, 0, nil) = 0 then
   {$else}
    if FARAPI.Control(hModule, FCTL_CHECKPANELSEXIST, nil) = 0 then
   {$endif bUnicodeFar}
      { Нет панелей... }
      Exit;

    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
//  FARAPI.AdvControl(hModule, ACTL_GETWINDOWINFO, @vWinInfo);
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO , @vWinInfo);
    if vWinInfo.WindowType <> WTYPE_PANELS then
      { Активное окно - не панель }
      Exit;

    Result := True;
  end;

                      
 {-----------------------------------------------------------------------------}

  procedure OpenMenu;
  var
    vItems :array[0..3] of TFarMenuItemEx;
    vRes :Integer;
  begin
    FillChar(vItems, SizeOf(vItems), 0);
    SetMenuItemChr(@vItems[0], GetMsg(strAllHist));
    SetMenuItemChr(@vItems[1], GetMsg(strFoldersHist));
    SetMenuItemChr(@vItems[2], GetMsg(strRegistryHist));
    SetMenuItemChr(@vItems[3], GetMsg(strFTPHist));

    vRes := FARAPI.Menu(hModule, -1, -1, 0,
      FMENU_WRAPMODE or FMENU_USEEXT,
      GetMsg(strTitle),
      '',
      'Contents',
      nil, nil,
      @vItems,
      High(vItems)+1);

    case vRes of
      0: OpenHistoryDlg('', 0, '');
      1: OpenHistoryDlg('Folders', 1, '');
      2: OpenHistoryDlg('Registry', 2, '');
      3: OpenHistoryDlg('FTP', 3, '');
    end;
  end;


  procedure OpenCmdLine(const AStr :TString);
  begin
    OpenHistoryDlg('', 0, AStr);
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
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

    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

    { Получаем Handle консоли Far'а }
    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);

//  InitConsoleProc;
//  hConWindow := GetConsoleWindow;
//  CanCheckWindow := GetConsoleWindow = hFarWindow;

    ReadSettings;

    FarHistory := TFarHistory.Create;
    SetHistoryWatcher(True);
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
    pi.Flags:= PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginMenuStrings:= @PluginMenuStrings;
    pi.PluginMenuStringsNumber:= 1;

    pi.CommandPrefix := PFarChar(MoreHistoryPrefix);

    FarHistory.AddCurrentToHistory;
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
//  Trace('ExitFAR');
    FarHistory.StoreModifiedHistory;
    SetHistoryWatcher(False);
    FreeObj(FarHistory);
  end;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: TIntPtr): THandle; stdcall;
 {$endif bUnicodeFar}
  begin
    Result:= INVALID_HANDLE_VALUE;
    try
//    TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);

      if OpenFrom = OPEN_COMMANDLINE then
        OpenCmdLine(StrOEMToAnsi(PFarChar(Item)))
      else
        OpenMenu;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


initialization
finalization
  FreeObj(HistThread);
end.


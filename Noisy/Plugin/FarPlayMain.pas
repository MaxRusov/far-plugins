{$I Defines.inc}
{$Typedaddress Off}

unit FarPlayMain;

{******************************************************************************}
{* Noisy - Noisy Player Far plugin                                            *}
{* 2008-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,

    Far_API,
    FarCtrl,
    FarPlug,
    FarMenu,

    FarPlayCtrl,
    FarPlayInfoDlg,
    FarPlayPlaylistDlg;


  type
    TNoisyPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
      procedure Configure; override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  var
    FMenuLang   :TString;
    FMenuConfig :TObjStrings;


  procedure ParseMenuConfig;

    procedure LocParse(AList :TStringList);

      procedure LocParseLevel(ASrcList :TStringList; var AIndex :Integer; ADstList :TStringList);
      var
        vStr :TString;
        vChr :TChar;
        vList :TStringList;
      begin
        while AIndex < AList.Count do begin
          vStr := Trim(ASrcList[AIndex]);
          Inc(AIndex);
          if vStr <> '' then begin
            vChr := vStr[1];
            if vChr = '{' then begin
              vList := TObjStrings.Create;
              LocParseLevel(ASrcList, AIndex, vList);
              ADstList.Objects[ADstList.Count - 1] := vList;
            end else
            if vChr = '}' then begin
              Exit;
            end else
            if (vChr <> '.') and (vChr <> ';') then
              ADstList.Add( vStr );
          end;
        end;
      end;

    var
      I :Integer;
    begin
      I := 0;
      LocParseLevel(AList, I, FMenuConfig);
    end;


    function LocLoadLang(const ALang :TString) :Boolean;
    var
      vList :TStringList;
      vFound :Boolean;

      procedure ReadStrings(const AFileName :TString; AList :TStringList);
      begin
        AList.LoadFromFile(AFileName);
      end;

      function CheckLang(const ALang :TString) :Boolean;
      var
        I :Integer;
        vStr :TString;
      begin
        Result := True;
        for I := 0 to vList.Count - 1 do begin
          vStr := vList[I];
          if StrEqual( ExtractWord(1, vStr, ['=']), '.Language') then begin
            Result := StrEqual(ExtractWord(2, vStr, ['=', ',']), ALang);
            Exit;
          end;
        end;
      end;

      function LocEnumMenuFile(const APath :TString; const ARec :TWin32FindData) :Boolean;
      begin
//      Trace(AFileName);
        ReadStrings(AddFileName(APath, ARec.cFileName), vList);
        if (ALang = '') or CheckLang(ALang) then begin
          LocParse(vList);
          vFound := True;
          Result := False;
        end else
          Result := True;
      end;

    begin
      vList := TStringList.Create;
      try
        vFound := False;
        WinEnumFiles(FModulePath, cMenuFileMask, faEnumFiles,  LocalAddr(@LocEnumMenuFile));

        Result := vFound;
      finally
        FreeObj(vList);
      end;
    end;

  var
    vLang :TString;
  begin
    if FMenuConfig = nil then
      FMenuConfig := TObjStrings.Create;

    vLang := GetMsgStr(strLang);
    if StrEqual(vLang, FMenuLang) then
      Exit;

    FMenuConfig.FreeAll;

    if not LocLoadLang(vLang) then
      if not LocLoadLang(cDefaultLang) then
        if not LocLoadLang('') then
          AppError(GetMsgStr(strFileNotFound) + AddFileName(FModulePath, cMenuFileName));

    FMenuLang := vLang;
  end;


 {-----------------------------------------------------------------------------}

  procedure ExecAddCommand(const AFileName :TString; Add :Boolean; AFolder :Boolean);
  var
    vStr :TString;
  begin
    vStr := AFileName;
    if AFolder then
      vStr := AddFileName(vStr, '*');
    vStr := '"' + vStr + '"';
    if AFolder then
      vStr := '/Recursive ' + vStr;
    if Add then
      vStr := '/Add ' + vStr;
    ExecCommand(vStr);
  end;


  procedure ProcessSelected(Add :Boolean);
  var
    vFolder, vName :TString;
    vIsFolder :Boolean;
    vSave :THandle;
    vLast :Cardinal;

    procedure LocShowMessage(APercent :Integer);
    const
      cWidth = 40;
    var
      vMess :TString;
      vTick :Cardinal;
    begin
      vTick := GetTickCount;
      if not vIsFolder and (TickCountDiff(vTick, vLast) < 50) then
        Exit;
      vLast := vTick;
      if vSave = 0 then
        vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      vMess := ExtractFileName(vName);
      if APercent <> -1 then begin
        if Length(vMess) > 10 then
          vMess := Copy(vMess, 1, 40);
        vMess := vMess + #10 + GetProgressStr(cWidth, APercent);
      end;
      ShowMessage('Adding', vMess, 0);
      Sleep(100);
      Assert(cTrue);
    end;

  var
    I, N, vIndex :Integer;
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
  begin
    if not FarGetPanelInfo(True, vInfo) then
      Exit;

    if vInfo.PanelType = PTYPE_FILEPANEL then begin

      vSave := 0;
      vLast := GetTickCount;
      try
        if not IsPluginPanel(vInfo) or (PFLAGS_REALNAMES and vInfo.Flags <> 0) then begin
          vFolder := FarPanelGetCurrentDirectory;

          if vInfo.SelectedItemsNumber <= 1 then begin
            vIndex := vInfo.CurrentItem;
            if (vIndex < 0) or (vIndex >= vInfo.ItemsNumber) then
              Exit;

            vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
            try
              vName := AddFileName(vFolder, vItem.FileName);
              vIsFolder := faDirectory and vItem.FileAttributes <> 0;
              if vIsFolder then
                LocShowMessage(-1);
              ExecAddCommand(vName, Add, vIsFolder);
            finally
              MemFree(vItem);
            end;

          end else
          if vInfo.SelectedItemsNumber > 1 then begin
            if vFolder <> '' then
              ExecCommand('"/CurPath=' + vFolder + '"');

            N := vInfo.SelectedItemsNumber;
            for I := 0 to N - 1 do begin
              vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETSELECTEDPANELITEM, I);
              try
                vName := vItem.FileName;
                vIsFolder := faDirectory and vItem.FileAttributes <> 0;
                LocShowMessage((100 * I) div N);
                ExecAddCommand(vName, Add, vIsFolder);
                Add := True;
              finally
                MemFree(vItem);
              end;
            end;
          end;

        end else
        if IsPluginPanel(vInfo) {and FTP Plugin...} then begin

          vFolder := ExtractWord(1, StrOEMToAnsi(GetConsoleTitleStr), ['{', '}']);

          if UpCompareSubStr('FTP:', vFolder) = 0 then begin
            vFolder := ExtractWords(2, MaxInt, vFolder, [':']);
            N := ChrPos('@', vFolder);
            if N <> 0 then
              vFolder := Copy(vFolder, N + 1, MaxInt);
            vFolder := 'FTP://' + vFolder;

            if vInfo.SelectedItemsNumber <= 1 then begin
              vIndex := vInfo.CurrentItem;
              if (vIndex < 0) or (vIndex >= vInfo.ItemsNumber) then
                Exit;

              vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETPANELITEM, vIndex);
              try
                if faDirectory and vItem.FileAttributes = 0 then begin
                  vName := vFolder + '/' + vItem.FileName;
                  ExecAddCommand(vName, Add, False);
                end;
              finally
                MemFree(vItem);
              end;

            end else
            if vInfo.SelectedItemsNumber > 1 then begin
              N := vInfo.SelectedItemsNumber;
              for I := 0 to N - 1 do begin
                vItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETSELECTEDPANELITEM, I);
                try
                  LocShowMessage((100 * I) div N);
                  if faDirectory and vItem.FileAttributes = 0 then begin
                    vName := vFolder + '/' + vItem.FileName;
                    ExecAddCommand(vName, Add, False);
                    Add := True;
                  end;
                finally
                  MemFree(vItem);
                end;
              end;
            end;

          end;
        end;

      finally
        if vSave <> 0 then
          FARAPI.RestoreScreen(vSave);
      end;
    end;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure RunPluginCommand(const AStr :TString);
  begin
    if StrEqual(AStr, cOpenCmd) then
      ProcessSelected(False)
    else
    if StrEqual(AStr, cAddCmd) then
      ProcessSelected(True)
    else
    if StrEqual(AStr, cPlaylist) then
      OpenPlaylist
    else
    if StrEqual(AStr, cInfo) then
      OpenInfoDialog
    else
    if StrEqual(AStr, cAbout) then
      OpenAboutDialog;
  end;


  procedure RunPlayerCommand(const AStr :TString; ASetFolder :Boolean);
  var
    vCurPath :TString;
  begin
    if ASetFolder then begin
//    vCurPath := GetCurrentDir;
      vCurPath := FarPanelGetCurrentDirectory;
      if vCurPath <> '' then
        ExecCommand('"/CurPath=' + vCurPath + '"');
    end;
    ExecCommand(AStr);
  end;


  procedure OpenCmdLineEx(const AStr :TString);
  var
    vStr :PTChar;
    vCmd, vParamStr :TString;
    vSetFolder :Boolean;
  begin
    vParamStr := '';
    vSetFolder := True;

    vStr := PTChar(AStr);
    while vStr^ <> #0 do begin
      vCmd := ExtractParamStr(vStr);
      if vCmd <> '' then begin
        if (Length(vCmd) >= 2) and (((vCmd[1] = '/') and (vCmd[2] = '/')) or ((vCmd[1] = '-') and (vCmd[2] = '-'))) then begin
          { Команда плагина }
          if vParamStr <> '' then begin
            RunPlayerCommand(vParamStr, vSetFolder);
            vSetFolder := False;
            vParamStr := '';
          end;
          Delete(vCmd, 1, 2);
          RunPluginCommand(vCmd);
        end else
          { Команда проигрывателя }
          vParamStr := AppendStrCh(vParamStr, '"' + vCmd + '"', ' ');
      end;
    end;

    if vParamStr <> '' then
      RunPlayerCommand(vParamStr, vSetFolder);
  end;


  procedure InputCommand;
  var
    vStr :TString;
  begin
    if FarInputBox( GetMsg(strTitle), 'Command:', vStr) then
      OpenCmdLineEx(vStr);
  end;


  function OpenMenuEx(AList :TStringList) :Boolean;
  const
    cPrefix = cFarPlayPrefix + ':';
  var
    I :Integer;
    vMenu :TFarMenu;
    vStr :TString;
    vRes :Integer;
    vSubList :TStringList;
  begin
    Result := False;

    vRes := 0;
    while True do begin
      Result := False;

      vMenu := TFarMenu.Create;
      try
        vMenu.Help := 'MainMenu';
        vMenu.SetBreakKeys([VK_TAB {Byte('/')} ]);

        for I := 0 to AList.Count - 1 do begin
          vStr := AList[I];
          if vStr = '-' then
            vMenu.AddItem('', MIF_SEPARATOR)
          else
            vMenu.AddItem(Trim(ExtractWord(1, vStr, ['#'])));
        end;

        vMenu.SetSelected(vRes);

        if not vMenu.Run then
          Exit;

        vRes := vMenu.ResIdx;

        if vMenu.BreakIdx = 0 then begin
          InputCommand;
          Result := True;
          Break;
        end;

      finally
        FreeObj(vMenu);
      end;

      vSubList := AList.Objects[vRes] as TStringList;
      if vSubList <> nil then begin
        Result := OpenMenuEx(vSubList);
        if Result then
          Break;
      end else
      begin
        vStr := AList[vRes];
        vStr := Trim(ExtractWords(2, MaxInt, vStr, ['#']));

        Result := not ((vStr <> '') and (vStr[1] = '+'));
        if not Result then
          vStr := Trim(Copy(vStr, 2, MaxInt));

        if UpCompareSubStr(cPrefix, vStr) = 0 then begin
          vStr := Trim(Copy(vStr, length(cPrefix) + 1, MaxInt));
          OpenCmdLineEx(vStr);
        end;

        if Result then
          Break;
      end;
    end;
  end;


  function OpenMenu :THandle;
  begin
    ParseMenuConfig;
    OpenMenuEx(FMenuConfig);
    Result := INVALID_HANDLE_VALUE;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  procedure TNoisyPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison;
    FGUID := cPluginID;

    FMinFarVer := MakeVersion(3, 0, 3000);
  end;


  procedure TNoisyPlug.Startup; {override;}
  begin
//  hStdin := GetStdHandle(STD_INPUT_HANDLE);
//  hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    FModulePath := RemoveBackSlash(ExtractFilePath(FARAPI.ModuleName));

    RestoreDefColor;
//  PluginConfig(False);
  end;


  procedure TNoisyPlug.ExitFar; {override;}
  begin
    {...}
  end;


  procedure TNoisyPlug.GetInfo; {override;}
  begin
    FFlags:= {PF_PRELOAD or} PF_EDITOR or PF_VIEWER or PF_DIALOG;

    FMenuStr := GetMsg(strTitle);
    FMenuID := cMenuID;
    
    FConfigStr := FMenuStr;
    FConfigID := cConfigID;

    FPrefix := cFarPlayPrefix;
  end;



  function TNoisyPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;
    if AFrom in [OPEN_PLUGINSMENU, OPEN_EDITOR, OPEN_VIEWER, OPEN_DIALOG] then
      Result := OpenMenu;
  end;


  function TNoisyPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;
    OpenCmdLineEx(AStr);
  end;


  function TNoisyPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;
    OpenCmdLineEx(AStr);
  end;


  procedure TNoisyPlug.Configure; {override;}
  begin
    OpenConfig;
  end;



initialization

finalization
  FreeObj(FMenuConfig);
end.

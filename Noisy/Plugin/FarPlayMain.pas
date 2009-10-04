{$I Defines.inc}
{$Typedaddress Off}

unit FarPlayMain;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,

    FarCtrl,
    FarPlayCtrl,
    FarPlayInfoDlg,
    FarPlayPlaylistDlg;


 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
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

      function LocEnumMenuFile(const AFileName :TString; const ARec :TFarFindData) :Integer;
      begin
//      Trace(AFileName);
        ReadStrings(AFileName, vList);
        if (ALang = '') or CheckLang(ALang) then begin
          LocParse(vList);
          vFound := True;
          Result := 0;
        end else
          Result := 1;
      end;

    begin
      vList := TStringList.Create;
      try
        vFound := False;
        EnumFilesEx(FModulePath, cMenuFileMask, LocalAddr(@LocEnumMenuFile));
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
      vMess := StrAnsiToOEM(ExtractFileName(vName));
      if APercent <> -1 then begin
        if Length(vMess) > 10 then
          vMess := Copy(vMess, 1, 40);
        vMess := vMess + #10 + GetProgressStr(cWidth, APercent);
      end;
      vMess := 'Adding' + #10 + vMess;
      FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PTChar(vMess)), 0, 0);
      Assert(cTrue);
    end;

  var
    I, N, vIndex :Integer;
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
  begin
    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicode}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, @vInfo);
   {$endif bUnicode}

    if vInfo.PanelType = PTYPE_FILEPANEL then begin

      vSave := 0;
      vLast := GetTickCount;
      try
        if (vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0) then begin
         {$ifdef bUnicode}
          vFolder := FarPanelGetCurrentDirectory(INVALID_HANDLE_VALUE);
         {$else}
          vFolder := FarChar2Str(vInfo.CurDir);
         {$endif bUnicode}

          if vInfo.SelectedItemsNumber <= 1 then begin
            vIndex := vInfo.CurrentItem;
            if (vIndex < 0) or (vIndex >= vInfo.ItemsNumber) then
              Exit;

           {$ifdef bUnicode}
            vItem := FarPanelItem(INVALID_HANDLE_VALUE, FCTL_GETPANELITEM, vIndex);
            try
           {$else}
            vItem := @vInfo.PanelItems[vIndex];
           {$endif bUnicode}

            vName := AddFileName(vFolder, FarChar2Str(vItem.FindData.cFileName));
            vIsFolder := faDirectory and vItem.FindData.dwFileAttributes <> 0;
            if vIsFolder then
              LocShowMessage(-1);
            ExecAddCommand(vName, Add, vIsFolder);

           {$ifdef bUnicode}
            finally
              MemFree(vItem);
            end;
           {$endif bUnicode}
          end else
          if vInfo.SelectedItemsNumber > 1 then begin
            if vFolder <> '' then
              ExecCommand('"/CurPath=' + vFolder + '"');

            N := vInfo.SelectedItemsNumber;
            for I := 0 to N - 1 do begin
             {$ifdef bUnicode}
              vItem := FarPanelItem(INVALID_HANDLE_VALUE, FCTL_GETSELECTEDPANELITEM, I);
              try
             {$else}
              vItem := @vInfo.SelectedItems[I];
             {$endif bUnicode}

              vName := FarChar2Str(vItem.FindData.cFileName);
              vIsFolder := faDirectory and vItem.FindData.dwFileAttributes <> 0;
              LocShowMessage((100 * I) div N);
              ExecAddCommand(vName, Add, vIsFolder);
              Add := True;

             {$ifdef bUnicode}
              finally
                MemFree(vItem);
              end;
             {$endif bUnicode}
            end;
          end;

        end else
        if (vInfo.Plugin = 1) {and FTP Plugin...} then begin

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

             {$ifdef bUnicode}
              vItem := FarPanelItem(INVALID_HANDLE_VALUE, FCTL_GETPANELITEM, vIndex);
              try
             {$else}
              vItem := @vInfo.PanelItems[vIndex];
             {$endif bUnicode}

              vName := vFolder + '/' + FarChar2Str(vItem.FindData.cFileName);
              ExecAddCommand(vName, Add, vIsFolder);

             {$ifdef bUnicode}
              finally
                MemFree(vItem);
              end;
             {$endif bUnicode}

            end else
            if vInfo.SelectedItemsNumber > 1 then begin
              N := vInfo.SelectedItemsNumber;
              for I := 0 to N - 1 do begin
               {$ifdef bUnicode}
                vItem := FarPanelItem(INVALID_HANDLE_VALUE, FCTL_GETSELECTEDPANELITEM, I);
                try
               {$else}
                vItem := @vInfo.SelectedItems[I];
               {$endif bUnicode}

                vName := vFolder + '/' + FarChar2Str(vItem.FindData.cFileName);
                LocShowMessage((100 * I) div N);
                ExecAddCommand(vName, Add, vIsFolder);
                Add := True;

               {$ifdef bUnicode}
                finally
                  MemFree(vItem);
                end;
               {$endif bUnicode}
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
      vCurPath := GetCurrentDir;
      ExecCommand('"/CurPath=' + vCurPath + '"');
    end;
    ExecCommand(AStr);
  end;


  procedure OpenCmdLine(const AStr :TString);
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

(*
  procedure OpenCmdLine(const AStr :TString);
  var
    vCurPath :TString;
  begin
    vCurPath := GetCurrentDir;
//  ExecCommand('"/CurPath=' + vCurPath + '" ' + AStr)
    ExecCommand('"/CurPath=' + vCurPath + '"');
    ExecCommand(AStr);
  end;
*)

 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
    { Need 2.0.756 }
//  Result := $02F40200;
    { Need 2.0.789 }
    Result := $03150200;
  end;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
 {$endif bUnicodeFar}
//var
//  vStr :TString;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

//  vRes := FARAPI.AdvControl(hModule, ACTL_GETFARVERSION, nil);

    { Получаем Handle консоли Far'а }
//  hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
//  hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
//  hMainThread := GetCurrentThreadID;

    FModulePath := RemoveBackSlash(ExtractFilePath(psi.ModuleName));

 (*
    FarHints := TFarHintsMain.Create;
    FarHints.RegRoot := psi.RootKey;

    ReadSetup(FarHints.RegRoot);
*)
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
    pi.Flags:= PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := @PluginMenuStrings;
    pi.CommandPrefix := cFarPlayPrefix;
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
//  Trace('ExitFAR');
  end;


  procedure InputCommand;
  var
    vRes :Integer;
    vStr :array[0..1024] of TChar;
  begin
    FillChar(vStr, SizeOf(vStr), 0);
    vRes := FARAPI.InputBox(
      GetMsg(strTitle),
      'Command:',
      nil,
      '',
      @vStr[0],
      1024,
      nil,
      FIB_BUTTONS);
    if vRes = 1 then
      OpenCmdLine(vStr);
  end;


  function OpenMenuEx(AList :TStringList) :Boolean;
  const
    cPrefix = cFarPlayPrefix + ':';
  var
    I :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
    vStr :TString;
    vRes :Integer;
    vSubList :TStringList;
    vBreakKey, vBreakCode :Integer;
  begin
    Result := False;
    
    vBreakKey := VK_TAB; (*Byte('/')*)
    vBreakCode := -2;

    vRes := 0;
    while True do begin
      Result := False;

      vItems := MemAllocZero(AList.Count * SizeOf(TFarMenuItemEx));
      try
        vItem := @vItems[0];
        for I := 0 to AList.Count - 1 do begin
          vStr := AList[I];
          if vStr = '-' then
            vItem.Flags := MIF_SEPARATOR
          else
            SetMenuItemStr(vItem, Trim(ExtractWord(1, vStr, ['#'])));
          Inc(PChar(vItem), SizeOf(TFarMenuItemEx));
        end;

        for I := 0 to AList.Count - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strTitle),
          '',
          'MainMenu',
          @vBreakKey,
          @vBreakCode,
          Pointer(vItems),
          AList.Count);
//      FARAPI.AdvControl(hModule, ACTL_COMMIT, 0);

      finally
       {$ifdef bUnicodeFar}
        CleanupMenu(@vItems[0], AList.Count);
       {$endif bUnicodeFar}
        MemFree(vItems);
      end;

      if vBreakCode = 0 then begin
        InputCommand;
        Result := True;
        Break;
      end;

      if vRes = -1 then
        Break;

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
          OpenCmdLine(vStr);
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


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);

    try
     {$ifndef bUnicode}
      SetFileApisToAnsi;
      try
     {$endif bUnicode}

        if OpenFrom = OPEN_COMMANDLINE then
          OpenCmdLine(FarChar2Str(PFarChar(Item)))
        else
        if OpenFrom in [OPEN_PLUGINSMENU, OPEN_EDITOR, OPEN_VIEWER, OPEN_DIALOG] then
          Result := OpenMenu;

     {$ifndef bUnicode}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicode} 

    except
      on E :Exception do
        ShowMessage(GetMsgStr(strError), E.Message, FMSG_WARNING or FMSG_MB_OK);
    end;
  end;


initialization

finalization
  FreeObj(FMenuConfig);
end.

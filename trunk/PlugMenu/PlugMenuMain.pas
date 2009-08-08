{$I Defines.inc}

unit PlugMenuMain;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* PlugMenu Far plugin                                                        *}
{* Экспортируемые функции                                                     *}
{******************************************************************************}

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

    PlugMenuCtrl,
    PlugMenuPlugs,
    PlugListDlg;


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


  function GetPluginsPath :TString;
  var
    vPtr :PTChar;
    vStr :TString;
  begin
    Result := '';

    vPtr := GetCommandLineStr;
    while vPtr^ <> #0 do begin
      vStr := ExtractParamStr(vPtr);
      if (Length(vStr) >= 2) and (vStr[1] = '/') and (CharUpCase(vStr[2]) = 'P') then begin
        Result := Copy(vStr, 3, MaxInt);
        FSkipAddPaths := True;
        Break;
      end;
    end;

    if Result = '' then begin
      vStr := GetExeModuleFileName;
      Result := AddFileName(ExtractFilePath(vStr), 'Plugins');
    end;
  end;


  function GetPluginsPathEx :TString;
  var
    vStr :TString;
    vHandle :THandle;
  begin
    Result := '';

//  vHandle := 0;
    vHandle := GetModuleHandle('Underscore.dll');

    if vHandle <> 0 then begin
      { Под Underscore не смотрим на командную строку... }

      vStr := GetExeModuleFileName;
      Result := AddFileName(ExtractFilePath(vStr), 'Plugins');

      FCacheRoot := AddFilename(FRegRoot, cUnderscoreCachePath);
      FCacheDllValue := cUnderscoreDllValue;
      FCacheMenuValue := cUnderscoreMenuValue;
      FCacheConfigValue := cUnderscoreConfigValue;

    end else
      Result := GetPluginsPath;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure OpenCmdLine(const AStr :TString; AWinType :Integer);
  var
    vStr :TString;
  begin
    vStr := ExtractWords(2, MaxInt, AStr, [':']);
    if UpCompareSubStr(cPlugMenuPrefix, AStr) = 0 then begin
      OpenMenu(AWinType, vStr);
      Exit;
    end;
   {$ifdef bUnicode}
    if UpCompareSubStr(cPlugLoadPrefix, AStr) = 0 then begin
      if (vStr <> '') and (vStr[1] = '"') and (vStr[Length(vStr)] = '"') then
        vStr := Trim(Copy(vStr, 2, length(vStr) - 2));
      vStr := ExpandFileName(vStr);
      LoadNewPlugin(vStr);
    end else
    if UpCompareSubStr(cPlugUnloadPrefix, AStr) = 0 then begin
      if (vStr <> '') and (vStr[1] = '"') and (vStr[Length(vStr)] = '"') then
        vStr := Trim(Copy(vStr, 2, length(vStr) - 2));
      vStr := ExpandFileName(vStr);
      UnloadPlugin(vStr);
    end;
   {$endif bUnicode}
  end;

 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := $02F40200;  { Need 2.0.756 }
//  Result := $03150200;  { Need 2.0.789 }
//  Result := $03550200;  { Need 2.0.853 }
//  Result := $038E0200;  { Need 2.0.910 }   { Новый формат кэша плагинов. }
    Result := $03E30200;  { Need 2.0.995 }   { Изменена TWindowInfo }
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

    FModulePath := RemoveBackSlash(ExtractFilePath(psi.ModuleName));
    FFarExePath := RemoveBackSlash(ExtractFilePath(GetExeModuleFileName));

    FRegRoot := psi.RootKey;
    FFarRegRoot := RemoveBackSlash(ExtractFilePath(FRegRoot));
    FCacheRoot := AddFileName(FFarRegRoot, cRegCacheKey);
    FHotkeysRoot := AddFileName(FFarRegRoot, cRegHotkeyKey);

    FCacheDllValue := cRegCacheDllValue;
    FCacheMenuValue := cRegCacheMenuValue;
    FCacheConfigValue := cRegCacheConfigValue;

    FPluginsPath := RemoveBackSlash(GetPluginsPathEx);

    if not FSkipAddPaths then
      FAddPluginsPaths := RegGetStrValue(HKCU, AddFileName(FFarRegRoot, cRegSystemKey), cRegPersPlugPathValue, '');

    ReadSetup;
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
    pi.Flags:= PF_EDITOR or PF_VIEWER or PF_DIALOG or PF_FULLCMDLINE;

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := Pointer(@PluginMenuStrings);
   {$ifdef bUnicode}
    pi.CommandPrefix := cPlugMenuPrefix + ':' + cPlugLoadPrefix + ':' + cPlugUnloadPrefix;
   {$else}
    pi.CommandPrefix := cPlugMenuPrefix;
   {$endif bUnicode}
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
//  Trace('ExitFAR');
  end;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}
  var
    vWinInfo :TWindowInfo;
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);

    try
     {$ifndef bUnicode}
      SetFileApisToAnsi;
      try
     {$endif bUnicode}
        InitFarPluginsList;

        FillChar(vWinInfo, SizeOf(vWinInfo), 0);
        vWinInfo.Pos := -1;
        FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO , @vWinInfo);

        if OpenFrom = OPEN_COMMANDLINE then
          OpenCmdLine(FarChar2Str(PFarChar(Item)), vWinInfo.WindowType)
        else
        if OpenFrom in [OPEN_PLUGINSMENU, OPEN_EDITOR, OPEN_VIEWER, OPEN_DIALOG] then
          OpenMenu(vWinInfo.WindowType);

     {$ifndef bUnicode}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicode}

    except
      on E :Exception do
        ShowMessage('PlugMenu', E.Message, FMSG_WARNING or FMSG_MB_OK);
    end;
  end;


end.

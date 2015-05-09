{$I Defines.inc}

unit PlugMenuMain;

{******************************************************************************}
{* (c) 2008-2012 Max Rusov                                                    *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Экспортируемые функции                                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarPlug,

    PlugMenuCtrl,
    PlugMenuPlugs,
    PlugListDlg;

    
  type
    TPlugMenuPlug = class(TFarPlug)
    public
      destructor Destroy; override;
      procedure Init; override;
      procedure Startup; override;
      procedure Configure; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
      function OpenCmdLine(AStr :PFarChar) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {$ifdef Far3}
 {$else}
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
 {$endif Far3}


 {-----------------------------------------------------------------------------}
 { TPlugMenuPlug                                                               }
 {-----------------------------------------------------------------------------}

  destructor TPlugMenuPlug.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  procedure TPlugMenuPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
   {$endif Far3}

   {$ifdef Far3}
//  FMinFarVer := MakeVersion(3, 0, 2415);   { PCTL_GETPLUGINS/PCTL_FINDPLUGIN }
//  FMinFarVer := MakeVersion(3, 0, 2572);   { Api changes }
//  FMinFarVer := MakeVersion(3, 0, 2851);   { LUA }
//  FMinFarVer := MakeVersion(3, 0, 2927);   { Release }
    FMinFarVer := MakeVersion(3, 0, 3600);   { Instance }
   {$else}
//  FMinFarVer := MakeVersion(2, 0, 910);    { Новый формат кэша плагинов. }
//  FMinFarVer := MakeVersion(2, 0, 995);    { Изменена TWindowInfo }
//  FMinFarVer := MakeVersion(2, 0, 1148);   { ConvertPath }
    FMinFarVer := MakeVersion(2, 0, 1573);   { ACTL_GETFARRECT }
   {$endif Far3}
  end;


  procedure TPlugMenuPlug.Startup; {override;}
  begin
    hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    FModulePath := RemoveBackSlash(ExtractFilePath(FARAPI.ModuleName));
    FFarExePath := RemoveBackSlash(ExtractFilePath(GetExeModuleFileName));

   {$ifdef Far3}
   {$else}
    FRegRoot := FARAPI.RootKey;
    FFarRegRoot := RemoveBackSlash(ExtractFilePath(FRegRoot));
    FCacheRoot := AddFileName(FFarRegRoot, cRegCacheKey);
    FHotkeysRoot := AddFileName(FFarRegRoot, cRegHotkeyKey);

    FCacheDllValue := cRegCacheDllValue;
    FCacheMenuValue := cRegCacheMenuValue;
    FCacheConfigValue := cRegCacheConfigValue;

    FPluginsPath := RemoveBackSlash(GetPluginsPathEx);
    if not FSkipAddPaths then
      FAddPluginsPaths := RegGetStrValue(HKCU, AddFileName(FFarRegRoot, cRegSystemKey), cRegPersPlugPathValue, '');
   {$endif Far3}

    RestoreDefColor;
    ReadSetup;
  end;


  procedure TPlugMenuPlug.GetInfo; {override;}
  begin
    FFlags := PF_EDITOR or PF_VIEWER or PF_DIALOG or PF_FULLCMDLINE;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    FPrefix := cPlugMenuPrefix + ':' + cPlugLoadPrefix + ':' + cPlugUnloadPrefix;
  end;


  procedure TPlugMenuPlug.Configure; {override;}
  begin
    ConfigDlg;
  end;


  function TPlugMenuPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  var
    vWinInfo :TWindowInfo;
  begin
    Result := INVALID_HANDLE_VALUE;
    InitFarPluginsList;
    FarGetWindowInfo(-1, vWinInfo);
    OpenMenu(vWinInfo.WindowType);
  end;


  function TPlugMenuPlug.OpenCmdLine(AStr :PFarChar) :THandle; {override;}
  var
    vStr :TString;
    vWinInfo :TWindowInfo;
  begin
    Result := INVALID_HANDLE_VALUE;

    InitFarPluginsList;
    FarGetWindowInfo(-1, vWinInfo);

    vStr := ExtractWords(2, MaxInt, AStr, [':']);
    if UpCompareSubStr(cPlugMenuPrefix, AStr) = 0 then begin
      OpenMenu(vWinInfo.WindowType, vStr);
      Exit;
    end;
   {$ifdef bUnicode}
    if UpCompareSubStr(cPlugLoadPrefix, AStr) = 0 then begin
      if (vStr <> '') and (vStr[1] = '"') and (vStr[Length(vStr)] = '"') then
        vStr := Trim(Copy(vStr, 2, length(vStr) - 2));
      vStr := FarExpandFileName(vStr);
      LoadNewPlugin(vStr);
    end else
    if UpCompareSubStr(cPlugUnloadPrefix, AStr) = 0 then begin
      if (vStr <> '') and (vStr[1] = '"') and (vStr[Length(vStr)] = '"') then
        vStr := Trim(Copy(vStr, 2, length(vStr) - 2));
      vStr := FarExpandFileName(vStr);
      UnloadPlugin(vStr);
    end;
   {$endif bUnicode}
  end;


  function TPlugMenuPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    InitFarPluginsList;
// {$ifdef Far3}
//  SynchroEvent(nil);
// {$else}
    FarAdvControl(ACTL_SYNCHRO, nil);
// {$endif Far3}
  end;


  procedure TPlugMenuPlug.SynchroEvent(AParam :Pointer); {override;}
  var
    vWinInfo :TWindowInfo;
  begin
    FarGetWindowInfo(-1, vWinInfo);
    OpenMenu(vWinInfo.WindowType);
  end;


end.

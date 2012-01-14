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

   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
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
      procedure SynchroEvent(AParam :Pointer); override;
      procedure ErrorHandler(E :Exception); override;

    private
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

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
   {$endif Far3}

   {$ifdef Far3}
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

    if AFrom and OPEN_FROMMACRO <> 0 then begin
      if AFrom and OPEN_FROMMACROSTRING <> 0 then
        {}
      else
        FarAdvControl(ACTL_SYNCHRO, Pointer(AParam))
    end else
    begin
      FarGetWindowInfo(-1, vWinInfo);
      if AFrom = OPEN_COMMANDLINE then
        OpenCmdLine(FarChar2Str(PFarChar(AParam)), vWinInfo.WindowType)
      else
      if AFrom in [OPEN_PLUGINSMENU, OPEN_EDITOR, OPEN_VIEWER, OPEN_DIALOG] then
        OpenMenu(vWinInfo.WindowType);
    end;
  end;


  procedure TPlugMenuPlug.SynchroEvent(AParam :Pointer); {override;}
  var
    vWinInfo :TWindowInfo;
  begin
    FarGetWindowInfo(-1, vWinInfo);
    OpenMenu(vWinInfo.WindowType);
  end;


  procedure TPlugMenuPlug.ErrorHandler(E :Exception); {override;}
  begin
    ShowMessage('PlugMenu', E.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


end.

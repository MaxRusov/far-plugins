{$I Defines.inc}

unit PlugMenuPlugs;

{******************************************************************************}
{* (c) 2008-2012 Max Rusov                                                    *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Работа с плагинами                                                         *}
{******************************************************************************}

{$ifdef CPUX86_64}
 {$PACKRECORDS C}
{$endif CPUX86_64}

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,

    FarConfig,
    Plugring,
    PlugMenuCtrl;


  type
    TPluginCategory = (
      pcUniversal,
      pcFile,
      pcEditor,
      pcViewer,
      pcDialog,
      pcNone
    );

    TFarPlugin = class;


    TFarPluginCmd = class(TNamedObject)
    public
      constructor CreateEx(APlugin :TFarPlugin; AIndex :Integer; const AName :TString
       {$ifdef Far3}
        ; const AGUID  :TGUID
       {$endif Far3}
      );

      function GetOrigTitle :TString;
      function GetMenuTitle :TString;

      procedure SetHotkey(AHotkey :TChar);
      procedure SetNewName(const ANewName :TString);
      procedure SetHidden(AHidden :Boolean);

      procedure UpdateLastAccess;
      procedure MarkAccessed;

    private
      FVisName      :TString;
     {$ifdef Far3}
      FGUID         :TGUID;
     {$endif Far3}
      FPlugin       :TFarPlugin;
      FIndex        :Integer;
      FHotkey       :TChar;
      FPerfHotkey   :TChar;
      FAutoHotkey   :TChar;
      FAccessDate   :TDateTime;
      FHidden       :Boolean;
      FNewName      :TString;

     {$ifdef Far3}
      procedure SaveSettings;
     {$endif Far3}
      procedure RestoreSettings;

    public
//    property VisName :TString read FVisName;
     {$ifdef Far3}
      property GUID :TGUID read FGUID;
     {$endif Far3}
      property Plugin :TFarPlugin read FPlugin;
      property Hotkey :TChar read FHotkey;
      property AutoHotkey :TChar read FAutoHotkey;
      property PerfHotkey :TChar read FPerfHotkey;
      property AccessDate :TDateTime read FAccessDate;
      property Hidden :Boolean read FHidden;
      property NewName :TString read FNewName;
    end;


    TFarPlugin = class(TBasis)
    public

      constructor CreateEx(
       {$ifdef Far3}
        const AInfo :TFarGetPluginInformation
       {$else}
        const ADllName, ARegPath :TString; AHandle :THandle
       {$endif Far3}
      );
      destructor Destroy; override;

      procedure UpdatePluginInfo(
       {$ifdef Far3}
        const AInfo :TFarGetPluginInformation
       {$else}
        const ARegPath :TString; AHandle :THandle
       {$endif Far3}
      );
      procedure UpdateLoaded;
      procedure UpdateSettings;

      function GetPluginModuleHandle :THandle;
      function GetFileName(AMode :Integer) :TString;
      function GetFlagsStr :TString;
      function GetFlagsStrEx :TString;
      function GetCategory :TPluginCategory;
      function AccessibleInContext(AWinType :Integer) :Boolean;

      procedure PluginLoad;
      procedure PluginUnload(AUnregister :Boolean);
      function PluginSetup :boolean;
      procedure PluginHelp;
      procedure UpdateVerInfo;
      procedure GotoPluring;

    public
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

    private
      FFileName     :TString;
      FCommands     :TObjList;
      FConfigString :TString;
      FPrefixes     :TString;
      FFileDate     :TDateTime;
      FPreload      :Boolean;
      FFlags        :Integer;
      FLoaded       :Boolean;
      FHasCommands  :Boolean;
      FUnregistered :Boolean;
      FUnicode      :Boolean;

     {$ifdef Far3}
      FGUID         :TGUID;
      FConfGUID     :TGUID;
      FPlugVer      :TVersionInfo;
      FPlugTitle    :TString;
      FPlugDescr    :TString;
      FPlugAuthor   :TString;
     {$endif Far3}

      FDescription  :TString;
      FCopyright    :TString;
      FVersion      :TString;

     {$ifdef Far3}
      function GetPluginKey :TString;
      function GetPlugVerStr :TString;
     {$else}
      function GetRegDllKey :TString;
      function FindRegCachePath :TString;
      procedure MarkAsPreload(AOn :Boolean);
     {$endif Far3}

      function GetPluginRelativePath :TString;
      function GetCommand(AIndex :Integer) :TFarPluginCmd;

    public
      property FileName :TString read FFileName;
      property Commands :TObjList read FCommands;
      property Command[I :Integer] :TFarPluginCmd read GetCommand;
      property ConfigString :TString read FConfigString;
      property Prefixes :TString read FPrefixes;
      property FileDate :TDateTime read FFileDate;
      property Flags :Integer read FFlags;
      property Loaded :Boolean read FLoaded;
      property Unregistered :Boolean read FUnregistered;
      property Unicode :Boolean read FUnicode;
     {$ifdef Far3}
      property PlugTitle :TString read FPlugTitle;
      property PlugDescr :TString read FPlugDescr;
      property PlugAuthor :TString read FPlugAuthor;
      property PlugVer :TVersionInfo read FPlugVer;
      property PlugVerStr :TString read GetPlugVerStr;
      property GUID :TGUID read FGUID;
     {$endif Far3}
      property Description :TString read FDescription;
      property Copyright :TString read FCopyright;
      property Version :TString read FVersion;
    end;


  var
    FPlugins  :TObjList;

  procedure InitFarPluginsList;
  procedure UpdatePluginList;
  procedure AssignAutoHotkeys(AWinType :Integer);

  function LoadNewPlugin(const AFileName :TString) :TFarPlugin;
  procedure UnLoadPlugin(const AFileName :TString);

  function FindPlugin(const AFileName :TString) :TFarPlugin;

  function CheckWinType(AWinType :Integer; APlugin :TFarPlugin) :Boolean;
  function GetPluginComman(ACommandIndex :Integer) :TFarPluginCmd;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {$ifdef Far3}
  var
    gConfig :TFarConfig;
 {$endif Far3}


  function ValidHandle(AHandle :THandle) :Boolean;
  begin
    Result := (AHandle <> 0) and (AHandle <> INVALID_HANDLE_VALUE);
  end;


  function FarPluginUnloadByName(const AFileName :TString) :Boolean;
 {$ifdef Far3}
  var
    vHandle :THandle;
  begin
    Result := False;
    vHandle := THandle(FarPluginControl(PCTL_FINDPLUGIN, PFM_MODULENAME, PFarChar(AFileName)));
    if ValidHandle(vHandle) then
      Result := FARAPI.PluginsControl(vHandle, PCTL_UNLOADPLUGIN, 0, nil) <> 0;
 {$else}
  begin
    Result := FarPluginControl(PCTL_UNLOADPLUGIN, PLT_PATH, PFarChar(AFileName)) <> 0;
 {$endif Far3}
  end;


 {-----------------------------------------------------------------------------}
 { TFarPluginCmd                                                               }
 {-----------------------------------------------------------------------------}

  constructor TFarPluginCmd.CreateEx(APlugin :TFarPlugin; AIndex :Integer; const AName :TString
   {$ifdef Far3}
    ; const AGUID  :TGUID
   {$endif Far3}
  );
  var
    vPos :Integer;
  begin
    CreateName(AName);

    FVisName := AName;
    FPlugin := APlugin;
    FIndex := AIndex;
   {$ifdef Far3}
    FGUID := AGUID;
   {$endif Far3}

    vPos := ChrPos('&', FName);
    if (vPos > 0) and (vPos < Length(FName)) then begin
      FPerfHotkey := FName[vPos + 1];
      Delete(FVisName, vPos, 1);
    end;

   {$ifdef Far3}
   {$else}
    UpdateLastAccess;
   {$endif Far3}
  end;


  function TFarPluginCmd.GetOrigTitle :TString;
  begin
    Result := FVisName;
    if Result = '' then
      Result := FPlugin.FConfigString;
    if Result = '' then
      Result := ExtractFileName(FPlugin.FFileName);
  end;


  function TFarPluginCmd.GetMenuTitle :TString;
  begin
    if (FNewName <> '') and not optShowOrigName then
      Result := FNewName
    else
      Result := GetOrigTitle;
  end;


  procedure TFarPluginCmd.SetNewName(const ANewName :TString);
  begin
    if ANewName <> FNewName then begin
      FNewName := ANewName;
     {$ifdef Far3}
      SaveSettings;
     {$else}
      {!!!}
     {$endif Far3}
    end;
  end;


  procedure TFarPluginCmd.SetHotkey(AHotkey :TChar);
 {$ifdef Far3}
  begin
    if FHotkey <> AHotkey then begin
      FHotkey := AHotkey;
      SaveSettings;
    end;
 {$else}
  var
    vPath :TString;
    vKey :HKey;
  begin
    vPath := AddFileName(FHotkeysRoot, FPlugin.GetRegDllKey);
    if FIndex <> 0 then
      vPath := vPath + '%' + Int2Str(FIndex);

    if AHotkey = #0 then begin
      if RegHasKey(HKCU, vPath) then begin
        RegOpenWrite(HKCU, vPath, vKey);
        try
          RegDeleteValue(vKey, 'Hotkey');
        finally
          RegCloseKey(vKey);
        end;
      end;
    end else
    begin
      RegOpenWrite(HKCU, vPath, vKey);
      try
        RegWriteStr(vKey, 'Hotkey', AHotkey);
      finally
        RegCloseKey(vKey);
      end;
    end;

    FHotkey := AHotkey;
 {$endif Far3}
  end;


  procedure TFarPluginCmd.SetHidden(AHidden :Boolean);
 {$ifdef Far3}
  begin
    if FHidden <> AHidden then begin
      FHidden := AHidden;
      SaveSettings;
    end;
 {$else}
  var
    vName :TString;
  begin
    if FHidden <> AHidden then begin
      FHidden := AHidden;
      vName := FPlugin.GetRegDllKey;
      if FIndex <> 0 then
        vName := vName + '%' + Int2Str(FIndex);
      RegSetIntValue(HKCU, FRegRoot + '\' + cPlugRegFolder + '\' + cHiddenRegFolder, vName, Byte(FHidden));
    end;
 {$endif Far3}
  end;


 {$ifdef Far3}
  procedure TFarPluginCmd.SaveSettings;
  var
    vPath, vStr :TString;
  begin
    vPath := FPlugin.GetPluginKey;
    if FIndex <> 0 then
      vPath := vPath + '%' + Int2Str(FIndex);

    with TFarConfig.CreateEx(True, cPluginName) do
      try
        if OpenKey('Plugins\' + vPath) then begin
          vStr := '';
          if FHotkey <> #0 then
            vStr := FHotkey;
          StrValue('Hotkey', vStr);
          LogValue('Hidden', FHidden);
          StrValue('NewName', FNewName);
         {$ifdef bAccessTime}
          WriteInt('LastAccess', DateTimeToFileDate(FAccessDate));
         {$endif bAccessTime}
        end;
      finally
        Destroy;
      end;
  end;


  procedure TFarPluginCmd.RestoreSettings;
  var
    vPath, vStr :TString;
    vConfig :TFarConfig;
   {$ifdef bAccessTime}
    vTime :Integer;
   {$endif bAccessTime}
  begin
//  TraceF('RestoreSettings: %d, %s', [Byte(gConfig <> nil), FName]);

    FHotkey := #0;
    FHidden := False;

    vPath := FPlugin.GetPluginKey;
    if FIndex <> 0 then
      vPath := vPath + '%' + Int2Str(FIndex);

    vConfig := gConfig;
    if gConfig = nil then
      vConfig := TFarConfig.CreateEx(False, cPluginName);
    try
      with vConfig do begin
        if OpenKey('Plugins\' + vPath) then begin
          vStr := '';
          StrValue('Hotkey', vStr);
          if vStr <> '' then
            FHotkey := vStr[1];

          LogValue('Hidden', FHidden);
          StrValue('NewName', FNewName);

         {$ifdef bAccessTime}
          vTime := ReadInt('LastAccess');
          FAccessDate := 0;
          if vTime <> 0 then
            FAccessDate := FileDateToDateTime(vTime)
         {$endif bAccessTime}
        end;
      end;
    finally
      if gConfig = nil then
        vConfig.Destroy;
    end;
  end;

 {$else}

  procedure TFarPluginCmd.RestoreSettings;
  var
    vPath, vStr :TString;
    vHotkey :TChar;
  begin
    vPath := AddFileName(FHotkeysRoot, FPlugin.GetRegDllKey);
    if FIndex <> 0 then
      vPath := vPath + '%' + Int2Str(FIndex);

    vStr := RegGetStrValue(HKCU, vPath, 'Hotkey', '');
    vHotkey := #0;
    if vStr <> '' then
      vHotkey := vStr[1];
    FHotkey := vHotkey;
  end;
 {$endif Far3}



 {$ifdef Far3}
  procedure TFarPluginCmd.MarkAccessed;
  begin
   {$ifdef bAccessTime}
    FAccessDate := Now;
    SaveSettings;
   {$endif bAccessTime}
  end;

  procedure TFarPluginCmd.UpdateLastAccess;
  begin
  end;

 {$else}

  procedure TFarPluginCmd.MarkAccessed;
  var
    vName :TString;
  begin
    FAccessDate := Now;
    vName := FPlugin.GetRegDllKey;
    if FIndex <> 0 then
      vName := vName + '%' + Int2Str(FIndex);
    RegSetIntValue(HKCU, FRegRoot + '\' + cPlugRegFolder + '\' + cAccessedRegFolder, vName, DateTimeToFileDate(FAccessDate));
  end;

  procedure TFarPluginCmd.UpdateLastAccess;
  var
    vName :TString;
    vTime :Integer;
  begin
    vName := FPlugin.GetRegDllKey;
    if FIndex <> 0 then
      vName := vName + '%' + Int2Str(FIndex);

    vTime := RegGetIntValue(HKCU, FRegRoot + '\' + cPlugRegFolder + '\' + cAccessedRegFolder, vName, 0);
    FAccessDate := 0;
    if vTime <> 0 then
      FAccessDate := FileDateToDateTime(vTime);

    FHidden := RegGetIntValue(HKCU, FRegRoot + '\' + cPlugRegFolder + '\' + cHiddenRegFolder, vName, 0) <> 0;
  end;
 {$endif Far3}


 {-----------------------------------------------------------------------------}
 { TFarPlugin                                                                  }
 {-----------------------------------------------------------------------------}

  type
   {$ifdef Far3}
   {$else}
    PPCharArrayA = ^TPCharArrayA;
    TPCharArrayA = packed array[0..Pred(MaxLongint div SizeOf(PAnsiChar))] of PAnsiChar;

    PPluginInfoA = ^TPluginInfoA;
    TPluginInfoA = record
      StructSize : Integer;
      Flags : DWORD;
      DiskMenuStrings : PPCharArrayA;
      DiskMenuNumbers : PIntegerArray;
      DiskMenuStringsNumber : Integer;
      PluginMenuStrings : PPCharArrayA;
      PluginMenuStringsNumber : Integer;
      PluginConfigStrings : PPCharArrayA;
      PluginConfigStringsNumber : Integer;
      CommandPrefix : PAnsiChar;
      Reserved : DWORD;
    end;

    TGetPluginInfo = procedure(var AInfo :TPluginInfo); stdcall;
    TGetPluginInfoA = procedure(var AInfo :TPluginInfoA); stdcall;
   {$endif Far3}

   {$ifdef Far3}
    TConfigure = function(const AInfo :TConfigureInfo) :Integer; stdcall;
   {$else}
    TConfigure = function(ANumber :Integer) :Integer; stdcall;
   {$endif Far3}
    TConfigureA = function(ANumber :Integer) :Integer; stdcall;


  constructor TFarPlugin.CreateEx(
    {$ifdef Far3}
     const AInfo :TFarGetPluginInformation
    {$else}
     const ADllName, ARegPath :TString; AHandle :THandle
    {$endif Far3}
  );
  var
    vFileAge :Integer;
  begin
    inherited Create;
    FCommands := TObjList.Create;

   {$ifdef Far3}
    FFileName := AInfo.ModuleName;
   {$else}
    FFileName := ADllName;
   {$endif Far3}

    FFileDate := 0;
    vFileAge := FileAge(FFileName);
    if vFileAge <> -1 then
      FFileDate := FileDateToDateTime(vFileAge);

   {$ifdef Far3}
    UpdatePluginInfo(AInfo);
   {$else}
    UpdatePluginInfo(ARegPath, AHandle);
   {$endif Far3}
  end;


  destructor TFarPlugin.Destroy; {override;}
  begin
    FreeObj(FCommands);
    inherited Destroy;
  end;


  procedure TFarPlugin.UpdatePluginInfo(
   {$ifdef Far3}
    const AInfo :TFarGetPluginInformation
   {$else}
    const ARegPath :TString; AHandle :THandle
   {$endif Far3}
  );
 {$ifdef Far3}
  var
    I :Integer;
  begin
    FGUID := AInfo.GInfo.Guid;
    FPlugVer := AInfo.GInfo.Version;
    FPlugTitle := AInfo.GInfo.Title;
    FPlugDescr := AInfo.GInfo.Description;
    FPlugAuthor := AInfo.GInfo.Author;

    FFlags := AInfo.PInfo.Flags;
    FPreload := PF_PRELOAD and FFlags <> 0;

    FUnicode := FPF_ANSI and AInfo.Flags = 0;

    FCommands.FreeAll;
    for I := 0 to AInfo.PInfo.PluginMenu.Count - 1 do
      FCommands.Add(
        TFarPluginCmd.CreateEx(Self, I, AInfo.PInfo.PluginMenu.Strings[I], AInfo.PInfo.PluginMenu.Guids[I]));

    FHasCommands := FCommands.Count > 0;
    if not FHasCommands then
      { Добавляем одну фиктивную команду }
      FCommands.Add( TFarPluginCmd.CreateEx(Self, 0, '', GUID_NULL) );

    FConfigString := '';
    if AInfo.PInfo.PluginConfig.Count > 0 then begin
      FConfigString := AInfo.PInfo.PluginConfig.Strings[0];
      FConfGUID := AInfo.PInfo.PluginConfig.Guids[0];
    end;
//  FConfigString := StrDeleteChars(FConfigString, ['&']); ???

    FPrefixes := AInfo.PInfo.CommandPrefix;

 {$else}

  var
    I :Integer;
    vStr :TString;
    vGetPluginInfo :TGetPluginInfo;
    vInfo :TPluginInfo;
    vGetPluginInfoA :TGetPluginInfoA;
    vInfoA :TPluginInfoA;
  begin
//  TraceF('UpdatePluginInfo: %s, %s', [FFileName, ARegPath]);

    FCommands.FreeAll;
    FConfigString := '';
    FPrefixes := '';
    FUnicode := True;

    if ARegPath <> '' then begin
      { Считаем информацию из кэша в реестре }
      FPreload := RegGetIntValue(HKCU, ARegPath, 'Preload', 0) = 1;
      if not FPreload then begin
        FFlags := RegGetIntValue(HKCU, ARegPath, 'Flags', 0);

        I := 0;
        while True do begin
          vStr := RegGetStrValue(HKCU, ARegPath, FCacheMenuValue + Int2Str(I), '');
          if vStr = '' then
            Break;
          FCommands.Add( TFarPluginCmd.CreateEx(Self, I, vStr) );
          Inc(I);
        end;

        FConfigString := RegGetStrValue(HKCU, ARegPath, FCacheConfigValue + '0', '');
        FPrefixes := RegGetStrValue(HKCU, ARegPath, 'CommandPrefix', '');

        if RegGetIntValue(HKCU, AddFileName(ARegPath, 'Exports'), 'OpenPlugin', -1) <> -1 then
          FUnicode := False;
      end else
        AHandle := GetPluginModuleHandle;
    end;

    if AHandle <> 0 then begin
      { Плугин уже загружен, спросим у него самого }
      vGetPluginInfo := GetProcAddress( AHandle, 'GetPluginInfoW' );
      if Assigned(vGetPluginInfo) then begin
        FillChar(vInfo, SizeOf(vInfo), 0);
        vGetPluginInfo(vInfo);

        FFlags := vInfo.Flags;
        FPreload := PF_PRELOAD and vInfo.Flags <> 0;

        for I := 0 to vInfo.PluginMenuStringsNumber - 1 do begin
          vStr := FarChar2Str(vInfo.PluginMenuStrings[I]);
          FCommands.Add( TFarPluginCmd.CreateEx(Self, I, vStr) );
        end;

        if vInfo.PluginConfigStringsNumber > 0 then
          FConfigString := FarChar2Str(vInfo.PluginConfigStrings[0]);

        if vInfo.CommandPrefix <> nil then
          FPrefixes := FarChar2Str(vInfo.CommandPrefix);
      end;

      if not Assigned(vGetPluginInfo) then begin
        { Возможно, это ансишный плагин... }
        vGetPluginInfoA := GetProcAddress( AHandle, 'GetPluginInfo' );
        if Assigned(vGetPluginInfoA) then begin
          FUnicode := False;

          FillChar(vInfoA, SizeOf(vInfoA), 0);
          vGetPluginInfoA(vInfoA);

          FFlags := vInfoA.Flags;
          FPreload := PF_PRELOAD and vInfoA.Flags <> 0;

          for I := 0 to vInfoA.PluginMenuStringsNumber - 1 do begin
            vStr := MixStrings.StrOemToAnsi(vInfoA.PluginMenuStrings[I]);
            FCommands.Add( TFarPluginCmd.CreateEx(Self, I, vStr) );
          end;

          if vInfoA.PluginConfigStringsNumber > 0 then
            FConfigString := MixStrings.StrOemToAnsi(vInfoA.PluginConfigStrings[0]);

          if vInfoA.CommandPrefix <> nil then
            FPrefixes := MixStrings.StrOemToAnsi(vInfoA.CommandPrefix);
        end;
      end;
    end;

    FHasCommands := FCommands.Count > 0;
    if not FHasCommands then
      { Добавляем одну фиктивную команду }
      FCommands.Add( TFarPluginCmd.CreateEx(Self, 0, '') );

    FConfigString := StrDeleteChars(FConfigString, ['&']);
 {$endif Far3}
  end;


  procedure TFarPlugin.UpdateLoaded;
 {$ifdef Far3}
  var
    vHandle :THandle;
    vPlugInfo :PFarGetPluginInformation;
  begin
    FLoaded := GetPluginModuleHandle <> 0;
    if FLoaded then begin
      vHandle := THandle(FarPluginControl(PCTL_FINDPLUGIN, PFM_GUID, @FGUID));
      if ValidHandle(vHandle) then begin
        vPlugInfo := nil;
        try
          if FarGetPluginInfo(vHandle, vPlugInfo) then begin
            UpdatePluginInfo(vPlugInfo^);
            UpdateSettings;  // Без этого пропадают настройки команды после F9.
            FUnregistered := False;
          end;
        finally
          MemFree(vPlugInfo);
        end;
      end;
    end;
 {$else}
  var
    vHandle :THandle;
  begin
    vHandle := GetPluginModuleHandle;
    FLoaded := vHandle <> 0;
    if FLoaded then begin
      UpdatePluginInfo('', vHandle);
      UpdateSettings;
      FUnregistered := False;
    end;
 {$endif Far3}
  end;


  procedure TFarPlugin.UpdateSettings;
  var
    I :Integer;
  begin
//  TraceF('UpdateSettings: %s', [FFileName]);
    if FHasCommands then
      for I := 0 to FCommands.Count - 1 do
        Command[I].RestoreSettings;
  end;


  function TFarPlugin.GetCommand(AIndex :Integer) :TFarPluginCmd;
  begin
    Result := FCommands[AIndex];
  end;


//function TFarPlugin.GetPluginModuleHandle :THandle;
//var
//  vStr :TString;
//begin
//  vStr := ExtractFileName(FFileName);
//  Result := GetModuleHandle(PTChar(vStr));
//end;

  function TFarPlugin.GetPluginModuleHandle :THandle;
  begin
    Result := GetModuleHandle(PTChar(FFileName));
  end;


  function TFarPlugin.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(Command[0].GetMenuTitle, TFarPlugin(Another).Command[0].GetMenuTitle);
  end;


  function TFarPlugin.GetFileName(AMode :Integer) :TString;
  begin
    Result := FFileName;
    if AMode <= 1 then
      Result := ExtractFileName(FFileName)
    else
    if AMode = 2 then
//    Result := ExtractRelativePath(AddBackSlash(FPluginsPath), FFileName)
      Result := GetPluginRelativePath;
  end;



  function TFarPlugin.GetPluginRelativePath :TString;
  var
    vFarPath :TString;
  begin
    vFarPath := AddBackSlash(FFarExePath);
    if UpCompareSubStr(vFarPath, FFileName) = 0 then
      Result := ExtractRelativePath(vFarPath, FFileName)
    else
      Result := FFileName;
  end;


  function TFarPlugin.GetFlagsStr :TString;
  var
    vChr :array[0..5] of TChar;
  begin
    MemFillChar(@vChr, High(vChr) + 1, '.');
    vChr[5] := #0;
    if FPreload {PF_PRELOAD and FFlags <> 0} then
      vChr[0] := 'P';
    if not (PF_DISABLEPANELS and FFlags <> 0) then
      vChr[1] := 'F';
    if PF_EDITOR and FFlags <> 0 then
      vChr[2] := 'E';
    if PF_VIEWER and FFlags <> 0 then
      vChr[3] := 'V';
    if PF_DIALOG and FFlags <> 0 then
      vChr[4] := 'D';
    Result := vChr;
  end;


  function TFarPlugin.GetFlagsStrEx :TString;
  begin
    Result := '';
    if FPreload {PF_PRELOAD and FFlags <> 0} then
      Result := 'Preload';
    if not (PF_DISABLEPANELS and FFlags <> 0) then
      Result := AppendStrCh(Result, 'File', ', ');
    if PF_EDITOR and FFlags <> 0 then
      Result := AppendStrCh(Result, 'Editor', ', ');
    if PF_VIEWER and FFlags <> 0 then
      Result := AppendStrCh(Result, 'Viewer', ', ');
    if PF_DIALOG and FFlags <> 0 then
      Result := AppendStrCh(Result, 'Dialog', ', ');
  end;


  function TFarPlugin.GetCategory :TPluginCategory;
  begin
    if PF_DISABLEPANELS and FFlags = 0 then begin
      if ((PF_EDITOR {+ PF_VIEWER}) and FFlags <> 0) then
        Result := pcUniversal
      else
        Result := pcFile
    end else
    begin
      if PF_EDITOR and FFlags <> 0 then
        Result := pcEditor
      else
      if PF_VIEWER and FFlags <> 0 then
        Result := pcViewer
      else
      if PF_DIALOG and FFlags <> 0 then
        Result := pcDialog
      else
        Result := pcNone
    end;
  end;


  function TFarPlugin.AccessibleInContext(AWinType :Integer) :Boolean;
  begin
    if not FHasCommands then
      Result := False
    else begin
      case AWinType of
        WTYPE_PANELS:
          Result :=  PF_DISABLEPANELS and FFlags = 0;
        WTYPE_VIEWER:
          Result :=  PF_VIEWER and FFlags <> 0;
        WTYPE_EDITOR:
          Result :=  PF_EDITOR and FFlags <> 0;
        WTYPE_DIALOG:
          Result :=  PF_DIALOG and FFlags <> 0;
        else
          Result := True;
      end;
    end;
  end;


 {$ifdef Far3}
  function TFarPlugin.GetPluginKey :TString;
  begin
    if FUnicode then
      Result := GUIDToString(FGUID)
    else
      {ANSI-плагины не обладают устойчивым GUID. Он меняется после очистки кэша}
      Result := StrReplaceChars(GetPluginRelativePath, ['\'], '/');
  end;

  function TFarPlugin.GetPlugVerStr :TString;
  begin
    Result := '';
    if (FPlugVer.Major <> 0) or (FPlugVer.Minor <> 0) or (FPlugVer.Revision <> 0) or (FPlugVer.Build <> 0) then begin
      Result := Format('%d.%d', [FPlugVer.Major, FPlugVer.Minor]);
      if (FPlugVer.Revision <> 0) or (FPlugVer.Build <> 0) then
        Result := Result + '.' + Int2Str(FPlugVer.Revision);
      if (FPlugVer.Build <> 0) then
        Result := Result + '.' + Int2Str(FPlugVer.Build);
    end;
  end;

 {$else}

  function TFarPlugin.GetRegDllKey :TString;
  begin
    Result := StrReplaceChars(GetPluginRelativePath, ['\'], '/');
  end;


  function TFarPlugin.FindRegCachePath :TString;
  begin
    { Новый формат кэша плагинов Far/2 build 910+ }
    Result := AddFileName(FCacheRoot, StrReplaceChars(FFileName, ['\'], '/'));
  end;


  procedure TFarPlugin.MarkAsPreload(AOn :Boolean);
  var
    vRegPath :TString;
  begin
    vRegPath := FindRegCachePath;
    if vRegPath <> '' then
      RegSetIntValue(HKCU, vRegPath, 'Preload', IntIf(AOn, 1, 0));
  end;
 {$endif Far3}


  procedure TFarPlugin.PluginLoad;
 {$ifdef Far3}
  var
    vHandle :THandle;
  begin
    vHandle := GetPluginModuleHandle;
    if vHandle = 0 then begin
      FarPluginControl(PCTL_FORCEDLOADPLUGIN, PLT_PATH, PFarChar(FFileName));
      UpdateLoaded;
    end;
    FUnregistered := False;
 {$else}
  var
    vHandle :THandle;
  begin
    vHandle := GetPluginModuleHandle;
    if vHandle = 0 then begin
      { Принуждаем FAR загрузит плагин в память }
      FarPluginControl(PCTL_UNLOADPLUGIN, PLT_PATH, PFarChar(FFileName));
      MarkAsPreload(True);
      FarPluginControl(PCTL_LOADPLUGIN, PLT_PATH, PFarChar(FFileName));
      UpdateLoaded;
    end;
    FUnregistered := False;
 {$endif Far3}
  end;



  procedure TFarPlugin.PluginUnload(AUnregister :Boolean);
  var
    vHandle :THandle;
  begin
    vHandle := GetPluginModuleHandle;
    if vHandle = HInstance then begin
      ShowMessage(GetMsgStr(strBadIdea), GetMsgStr(strSelfUnloadHint), FMSG_WARNING or FMSG_MB_OK);
      Exit;
    end;

    FarPluginUnloadByName(FFileName);

//  if not AUnregister then begin
//    MarkAsPreload(False);
//    FarPluginControl(PCTL_LOADPLUGIN, PLT_PATH, PFarChar(FFileName));
//    FUnregistered := False;
//  end else

      FUnregistered := True;

    UpdateLoaded;
  end;


  function TFarPlugin.PluginSetup :boolean;
  var
    vHandle :THandle;
    vConfigure :TConfigure;
    vConfigureA :TConfigureA;
   {$ifdef Far3}
    vInfo :TConfigureInfo;
   {$endif Far3}
  begin
    Result := False;
    vHandle := GetPluginModuleHandle;

    if vHandle = 0 then begin
      PluginLoad;
      vHandle := GetPluginModuleHandle;
    end;

    if vHandle <> 0 then begin
       vConfigure := GetProcAddress( vHandle, 'ConfigureW' );
       if Assigned(vConfigure) then begin
        {$ifdef Far3}
         FillZero(vInfo, SizeOf(vInfo));
         vInfo.StructSize := SizeOf(vInfo);
         vInfo.GUID := @FConfGuid;
         vInfo.Instance := Pointer(vHandle);
         vConfigure(vInfo);
        {$else}
         vConfigure(0);
        {$endif Far3}
         UpdateLoaded;
         Result := True;
       end;

       if not Result then begin
         { Возможно, это ансишный плагин... }
         vConfigureA := GetProcAddress( vHandle, 'Configure' );
         if Assigned(vConfigureA) then begin
           vConfigureA(0);
           UpdateLoaded;
           Result := True;
         end;
       end;
    end;
  end;


  procedure TFarPlugin.PluginHelp;
  begin
    FARAPI.ShowHelp(PTChar(FFileName), nil,  0);
  end;


  procedure TFarPlugin.GotoPluring;
 {$ifdef Far3}
  var
    vURL :TString;
  begin
    vURL := PlugringFindURL(FGUID);
    if vURL = '' then
      AppErrorId(strNotFoundOnPlugring);
    ShellOpen(vURL);
 {$else}
  begin
    Sorry;
 {$endif Far3}
  end;


 {-----------------------------------------------------------------------------}

  type
    LANGANDCODEPAGE = packed record
      wLanguage :Word;
      wCodePage :Word;
    end;

  procedure TFarPlugin.UpdateVerInfo;
  var
    vBuf :PWideChar;
    vSize :DWORD;
    vLang :TString;

    procedure LocDetectLang;
    const
      cStrInfo = 'StringFileInfo';
    var
      vLen :UINT;
      vCP  :^LANGANDCODEPAGE;
(*    vPtr, vEnd :PWideChar;  *)
    begin
(*
      { Ищем сканированием, потому что иногда Translation не совпадает с StringInfo }
      vPtr := vBuf;
      vEnd := vBuf + (vSize div SizeOf(WideChar)) - Length(cStrInfo) - 4 - 8;
      while vPtr < vEnd do begin
        if StrLICompW(vPtr, cStrInfo, Length(cStrInfo)) = 0 then begin
          Inc(vPtr, Length(cStrInfo) + 4);
          SetString(vLang, vPtr, 8);
          Exit;
        end;
        Inc(vPtr);
      end;
*)
      { Не нашли сканированием (возможно 16-ти разрядная программа), попробуем через Translation}
      if VerQueryValue(vBuf, '\VarFileInfo\Translation', Pointer(vCP), vLen) then
        vLang := Format('%.4x%.4x', [vCP.wLanguage, vCP.wCodePage]);
    end;

    function LocGet(const AKey :TString) :TString;
    var
      vKey :TString;
      vStr :PTChar;
      vLen :UINT;
    begin
      Result := '';
      vKey := '\StringFileInfo\' + vLang + '\' + AKey;
      if VerQueryValue(vBuf, PTChar(vKey), Pointer(vStr), vLen) then
        Result := vStr;
    end;

  var
    vTemp :DWORD;
  begin
    vSize := GetFileVersionInfoSize( PTChar(FFileName), vTemp);
    if vSize > 0 then begin
      GetMem(vBuf, vSize);
      try
        GetFileVersionInfo( PTChar(FFileName), vTemp, vSize, vBuf);
        LocDetectLang;

        if vLang <> '' then begin
          FDescription := LocGet('FileDescription');
          FCopyright := LocGet('LegalCopyright');
          FVersion := LocGet('FileVersion');
//        LocAdd('CompanyName');
//        LocAdd('OriginalFilename');
//        LocAdd('InternalName');
//        LocAdd('ProductName');
//        LocAdd('ProductVersion');
        end;

      finally
        FreeMem(vBuf);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetPluginComman(ACommandIndex :Integer) :TFarPluginCmd;
  var
    I, K :Integer;
  begin
    I := ACommandIndex and $FFFF0000 shr 16;
    K := ACommandIndex and $0000FFFF;
    Result := TFarPlugin(FPlugins[I]).Command[K];
  end;


  function CheckWinType(AWinType :Integer; APlugin :TFarPlugin) :Boolean;
  begin
    Result := not APlugin.Unregistered and APlugin.AccessibleInContext(AWinType);
  end;


  procedure AssignAutoHotkeys(AWinType :Integer);
  var
    I, J, K :Integer;
    vChr :TChar;
    vStr :TString;
    vHotkeys :TStrList;
    vPlugin :TFarPlugin;
    vCommand :TFarPluginCmd;
  begin
    vHotkeys := TStrList.Create;
    try
      for I := 0 to FPlugins.Count - 1 do begin
        vPlugin := FPlugins[I];
        for J := 0 to vPlugin.Commands.Count - 1 do begin
          vCommand := vPlugin.Command[J];
          vCommand.FAutoHotkey := #0;
          if CheckWinType(AWinType, vPlugin) then begin
            if vCommand.Hotkey <> #0 then
              vHotkeys.Add(vCommand.Hotkey)
            else
            if vCommand.FPerfHotkey <> #0 then begin
              vHotkeys.Add(vCommand.FPerfHotkey);
              vCommand.FAutoHotkey := vCommand.FPerfHotkey;
            end;
          end;
        end;
      end;

      for I := 0 to FPlugins.Count - 1 do begin
        vPlugin := FPlugins[I];
        for J := 0 to vPlugin.Commands.Count - 1 do begin
          vCommand := vPlugin.Command[J];
          if CheckWinType(AWinType, vPlugin) and (vCommand.Hotkey = #0) and (vCommand.AutoHotkey = #0) then begin
            vStr := vCommand.GetMenuTitle;
            for K := 1 to Length(vStr) do begin
              vChr := vStr[K];
              if IsCharAlphaNumeric(vChr) then
                if vHotkeys.IndexOf(vChr) = -1 then begin
                  vCommand.FAutoHotkey := vChr;
                  vHotkeys.Add(vChr);
                  Break;
                end;
            end;
          end;

        end;
      end;
    finally
      FreeObj(vHotkeys);
    end;
  end;


  procedure UpdatePluginList;
  var
    I :Integer;
  begin
   {$ifdef Far3}
    gConfig := TFarConfig.CreateEx(False, cPluginName);
    try
   {$endif Far3}
      for I := 0 to FPlugins.Count - 1 do
        with TFarPlugin(FPlugins[I]) do begin
          UpdateLoaded;
          if not Loaded then
            UpdateSettings;
        end;
   {$ifdef Far3}
    finally
      FreeObj(gConfig);
    end;
   {$endif Far3}
  end;


  function FindPlugin(const AFileName :TString) :TFarPlugin;
  var
    I :Integer;
    vPlugin :TFarPlugin;
  begin
    for I := 0 to FPlugins.Count - 1 do begin
      vPlugin := FPlugins[I];
      if StrEqual(vPlugin.FileName, AFileName) then begin
        Result := vPlugin;
        Exit;
      end;
    end;
    Result := nil;
  end;


 {-----------------------------------------------------------------------------}

  function StrExpandEnvironment(const AStr :TString) :TString;
  var
    vBuf :Array[0..1024] of TChar;
    vLen :Integer;
  begin
    Result := '';
    vLen := ExpandEnvironmentStrings(PTChar(AStr), PTChar(@vBuf), High(vBuf));
    if vLen > 0 then
      SetString(Result, PTChar(@vBuf), vLen - 1);
  end;


  procedure FirstInitFarPluginsList;
 {$ifdef Far3}
  var
    I, vCount, vSize :Integer;
    vHandles :array of THandle;
    vPlugInfo :PFarGetPluginInformation;
  begin
    FPlugins.FreeAll;

    vCount := FarPluginControl(PCTL_GETPLUGINS, 0, nil);
    if vCount = 0 then
      Exit;

    SetLength(vHandles, vCount);
    FarPluginControl(PCTL_GETPLUGINS, vCount, vHandles);

    vPlugInfo := nil; vSize := 0;
    try
      for I := 0 to vCount - 1 do begin
        if FarGetPluginInfo(vHandles[I], vPlugInfo, @vSize) then
          FPlugins.Add( TFarPlugin.CreateEx(vPlugInfo^) );
      end;
    finally
      MemFree(vPlugInfo);
    end;

    FPlugins.SortList(True, 0);

 {$else}

  var
    vDlls :TStrList;

    procedure LocSearchOnPath(const APath :TString);

      function LocEnumPlugins(const AFileName :TString; const ARec :TFarFindData) :Integer;
      begin
        vDlls.Add(AFileName);
        Result := 1;
      end;

    var
      I :Integer;
      vPath :TString;
    begin
      for I := 1 to WordCount(APath, [';', ',']) do begin
        vPath := Trim(ExtractWord(I, APath, [';', ',']));
        if (vPath <> '') and (vPath[1] = '"') and (vPath[length(vPath)] = '"') then
          vPath := Trim(Copy(vPath, 2, length(vPath) - 2));
        vPath := StrExpandEnvironment(vPath);
        vPath := ExpandFileName(vPath);
        if WinFolderExists(vPath) then
          EnumFilesEx(vPath, '*.dll', LocalAddr(@LocEnumPlugins));
      end;
    end;

  var
    I, J, vRes :Integer;
    vKey :HKey;
    vLen :DWORD;
    vStr :array[0..256] of TChar;
    vDllName, vName, vPath :TString;
    vHandle :THandle;
    vCache :TObjList;
  begin
//  Trace('FirstInitFarPluginsList');
    FPlugins.FreeAll;

    vDlls := nil; vCache := nil;
    try
      vDlls := TStrList.Create;
      vCache := TObjList.Create;

      { Просканируем каталог плагинов (ищем все *.dll) }
      LocSearchOnPath(FPluginsPath);

      if FAddPluginsPaths <> '' then
        LocSearchOnPath(FAddPluginsPaths);

      { Просканируем кэш плагинов в реестре}
      if RegOpenKey(HKCU, PTChar(FCacheRoot), vKey) = 0 then begin
        try
          I := 0;
          while True do begin
            vLen := High(vStr);
            vRes := RegEnumKeyEx(vKey, I, PTChar(@vStr), vLen, nil, nil, nil, nil);
            if vRes <> 0 then
              Break;
            SetString(vName, PTChar(@vStr), vLen);
            vPath := AddFileName(FCacheRoot, vName);

            { Новый формат кэша плагинов Far/2 build 910+ }
            vDllName := StrReplaceChars(vName, ['/'], '\');

            vCache.AddSorted( TDescrObject.CreateEx(vDllName, vPath), 0, dupIgnore );
            Inc(I);
          end;
        finally
          RegCloseKey(vKey);
        end;
      end;

      { Пытаемся определить, какие из dll являются плагинами }
      for I := 0 to vDlls.Count - 1 do begin
        vDllName := vDlls[I];
//      TraceF('DLL: %s', [vDllName]);

        { Сначала проверим, есть ли DLL в кэше }
        if vCache.FindKey(Pointer(vDllName), 0, [foBinary], J) then begin
          vPath := TDescrObject(vCache[J]).Descr;
          FPlugins.Add( TFarPlugin.CreateEx(vDllName, vPath, 0) );
        end else
        begin
          { Если нет - посмотрим, может dll уже загружена? }
          vName := ExtractFileName(vDllName);
          vHandle := GetModuleHandle(PTChar(vName));
          if vHandle <> 0 then begin
            if Assigned( GetProcAddress( vHandle, 'SetStartupInfo' ) ) or Assigned( GetProcAddress( vHandle, 'SetStartupInfoW' ) ) then begin
              FPlugins.Add( TFarPlugin.CreateEx(vDllName, '', vHandle) );
            end;
          end;
        end;
      end;

    finally
      FreeObj(vDlls);
      FreeObj(vCache);
    end;

    FPlugins.SortList(True, 0);
 {$endif Far3}
  end;



  function LoadNewPlugin(const AFileName :TString) :TFarPlugin;
 {$ifdef Far3}
  var
    vHandle :THandle;
    vPlugin :TFarPlugin;
    vPlugInfo :PFarGetPluginInformation;
  begin
    Result := nil;

    vHandle := THandle(FarPluginControl(PCTL_LOADPLUGIN, PLT_PATH, PFarChar(AFileName)));
    if not ValidHandle(vHandle) then
      AppErrorId(strPluginLoadError);

    vPlugInfo := nil; 
    try
      if not FarGetPluginInfo(vHandle, vPlugInfo) then
        Exit;

      vPlugin := FindPlugin(AFileName);
      if vPlugin = nil then begin
        vPlugin := TFarPlugin.CreateEx(vPlugInfo^);
        FPlugins.Add( vPlugin );
      end else
      begin
        vPlugin.UpdatePluginInfo(vPlugInfo^);
        vPlugin.FUnregistered := False;
      end;

      FPlugins.SortList(True, 0);
      Result := vPlugin;

    finally
      MemFree(vPlugInfo);
    end;

 {$else}

  var
    vRes :Integer;
    vPlugin :TFarPlugin;
  begin
    vRes := FarPluginControl(PCTL_LOADPLUGIN, PLT_PATH, PFarChar(AFileName));
    if vRes = 0 then
      AppErrorId(strPluginLoadError);

    vPlugin := FindPlugin(AFileName);
    if vPlugin = nil then begin
      vPlugin := TFarPlugin.CreateEx(AFileName, '', 0);
      FPlugins.Add( vPlugin );
    end;

    vPlugin.FUnregistered := False;
    vPlugin.UpdatePluginInfo( vPlugin.FindRegCachePath, 0 );
    FPlugins.SortList(True, 0);

    Result := vPlugin;
 {$endif Far3}
  end;


  procedure UnLoadPlugin(const AFileName :TString);
  var
    vPlugin :TFarPlugin;
  begin
    vPlugin := FindPlugin(AFileName);
    if vPlugin <> nil then
      vPlugin.PluginUnload(True)
    else begin
      if not FarPluginUnloadByName(AFileName) then
        AppErrorId(strPluginUnloadError);
    end;
  end;


  var
    gLang :TString;

  procedure InitFarPluginsList;
  var
    vLang :TString;
  begin
    vLang := GetMsgStr(strLang);
    if FPlugins = nil then begin
      FPlugins := TObjList.Create;
      FirstInitFarPluginsList;
      gLang := vLang;
    end else
    if vLang <> gLang then begin
      { Обновление списка плагинов, после смены языка }
      UpdatePluginList;
      FPlugins.SortList(True, 0);
      gLang := vLang;
    end;
  end;



initialization

finalization
  FreeObj(FPlugins);
end.




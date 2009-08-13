{$I Defines.inc}

unit PlugMenuPlugs;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* PlugMenu Far plugin                                                        *}
{* Работа с плагинами                                                         *}
{******************************************************************************}

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

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,

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
      constructor CreateEx(APlugin :TFarPlugin; AIndex :Integer; const AName :TString);

      function GetMenuTitle :TString;

      procedure SetHotkey(AHotkey :TChar);
      procedure SetHidden(AHidden :Boolean);

      procedure UpdateLastAccess;
      procedure MarkAccessed;

    private
      FVisName      :TString;
      FPlugin       :TFarPlugin;
      FIndex        :Integer;
      FHotkey       :TChar;
      FPerfHotkey   :TChar;
      FAutoHotkey   :TChar;
      FAccessDate   :TDateTime;
      FHidden       :Boolean;

    public
      property VisName :TString read FVisName;
      property Plugin :TFarPlugin read FPlugin;
      property Hotkey :TChar read FHotkey;
      property AutoHotkey :TChar read FAutoHotkey;
      property PerfHotkey :TChar read FPerfHotkey;
      property AccessDate :TDateTime read FAccessDate;
      property Hidden :Boolean read FHidden;
    end;


    TFarPlugin = class(TBasis)
    public
      constructor CreateEx(const ADllName, ARegPath :TString; AHandle :THandle);
      destructor Destroy; override;

      procedure UpdatePluginInfo(const ARegPath :TString; AHandle :THandle);
      procedure UpdateLoaded;
      procedure UpdateHotkey;

      function GetPluginModuleHandle :THandle;
      function GetFileName(AMode :Integer) :TString;
      function GetFlagsStr :TString;
      function GetFlagsStrEx :TString;
      function GetCategory :TPluginCategory;
      function AccessibleInContext(AWinType :Integer) :Boolean;

      procedure MarkAsPreload(AOn :Boolean);
     {$ifdef bUnicode}
      procedure PluginLoad;
      procedure PluginUnload(AUnregister :Boolean);
     {$endif bUnicode}
      function PluginSetup :boolean;
      procedure PluginHelp;
      procedure UpdateVerInfo;

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

      FDescription  :TString;
      FCopyright    :TString;
      FVersion      :TString;

      function GetRegDllKey :TString;
      function GetPluginRelativePath :TString;
      function FindRegCachePath :TString;
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

      property Description :TString read FDescription;
      property Copyright :TString read FCopyright;
      property Version :TString read FVersion;
    end;


  var
    FPlugins  :TObjList;

  procedure InitFarPluginsList;

  procedure UpdateLoadedPlugins;
  procedure UpdatePluginHotkeys;
  procedure AssignAutoHotkeys(AWinType :Integer);

 {$ifdef bUnicode}
  function LoadNewPlugin(const AFileName :TString) :TFarPlugin;
  procedure UnLoadPlugin(const AFileName :TString);
 {$endif bUnicode}

  function FindPlugin(const AFileName :TString) :TFarPlugin;

  function CheckWinType(AWinType :Integer; APlugin :TFarPlugin) :Boolean;
  function GetPluginComman(ACommandIndex :Integer) :TFarPluginCmd;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFarPluginCmd                                                               }
 {-----------------------------------------------------------------------------}

  constructor TFarPluginCmd.CreateEx(APlugin :TFarPlugin; AIndex :Integer; const AName :TString);
  var
    vPos :Integer;
  begin
    CreateName(AName);

    FVisName := AName;
    FPlugin := APlugin;
    FIndex := AIndex;

    vPos := ChrPos('&', FName);
    if (vPos > 0) and (vPos < Length(FName)) then begin
      FPerfHotkey := FName[vPos + 1];
      Delete(FVisName, vPos, 1);
    end;

    UpdateLastAccess;
  end;


  function TFarPluginCmd.GetMenuTitle :TString;
  begin
    Result := FVisName;
    if Result = '' then
      Result := FPlugin.FConfigString;
    if Result = '' then
      Result := ExtractFileName(FPlugin.FFileName);
  end;



  procedure TFarPluginCmd.SetHotkey(AHotkey :TChar);
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
       {$ifdef bUnicode}
        RegWriteStr(vKey, 'Hotkey', AHotkey);
       {$else}
        RegWriteStr(vKey, 'Hotkey', StrAnsiToOem(AHotkey));
       {$endif bUnicode}
      finally
        RegCloseKey(vKey);
      end;
    end;

    FHotkey := AHotkey;
  end;


  procedure TFarPluginCmd.SetHidden(AHidden :Boolean);
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
  end;


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


 {-----------------------------------------------------------------------------}
 { TFarPlugin                                                                  }
 {-----------------------------------------------------------------------------}

  type
   {$ifdef bUnicode}
    PPCharArrayA = ^TPCharArrayA;
    TPCharArrayA = packed array[0..Pred(MaxLongint div SizeOf(PAnsiChar))] of PAnsiChar;

    PPluginInfoA = ^TPluginInfoA;
    TPluginInfoA = packed record
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
   {$endif bUnicode}

    TGetPluginInfo = procedure(var AInfo :TPluginInfo); stdcall;
   {$ifdef bUnicode}
    TGetPluginInfoA = procedure(var AInfo :TPluginInfoA); stdcall;
   {$endif bUnicode}

    TConfigure = function(ANumber :Integer) :Integer; stdcall;
   {$ifdef bUnicode}
    TConfigureA = function(ANumber :Integer) :Integer; stdcall;
   {$endif bUnicode}


  constructor TFarPlugin.CreateEx(const ADllName, ARegPath :TString; AHandle :THandle);
  var
    vFileAge :Integer;
  begin
    inherited Create;
    FCommands := TObjList.Create;

    FFileName := ADllName;

    FFileDate := 0;
    vFileAge := FileAge(FFileName);
    if vFileAge <> -1 then
      FFileDate := FileDateToDateTime(vFileAge);

    UpdatePluginInfo(ARegPath, AHandle);
  end;


  destructor TFarPlugin.Destroy; {override;}
  begin
    FreeObj(FCommands);
    inherited Destroy;
  end;


  procedure TFarPlugin.UpdatePluginInfo(const ARegPath :TString; AHandle :THandle);
  var
    I :Integer;
    vStr :TString;
    vGetPluginInfo :TGetPluginInfo;
    vInfo :TPluginInfo;
   {$ifdef bUnicode}
    vGetPluginInfoA :TGetPluginInfoA;
    vInfoA :TPluginInfoA;
   {$endif bUnicode}
  begin
    FCommands.FreeAll;
    FConfigString := '';
    FPrefixes := '';
   {$ifdef bUnicode}
    FUnicode := True;
   {$else}
    FUnicode := False;
   {$endif bUnicode}

    if ARegPath <> '' then begin
      { Считаем информацию из кэша в реестре }
      FPreload := RegGetIntValue(HKCU, ARegPath, 'Preload', 0) = 1;
      if not FPreload then begin
        FFlags := RegGetIntValue(HKCU, ARegPath, 'Flags', 0);

        I := 0;
        while True do begin
          vStr := StrOemToAnsi(RegGetStrValue(HKCU, ARegPath, FCacheMenuValue + Int2Str(I), ''));
          if vStr = '' then
            Break;
          FCommands.Add( TFarPluginCmd.CreateEx(Self, I, vStr) );
          Inc(I);
        end;

        FConfigString := StrOemToAnsi(RegGetStrValue(HKCU, ARegPath, FCacheConfigValue + '0', ''));
        FPrefixes := StrOemToAnsi(RegGetStrValue(HKCU, ARegPath, 'CommandPrefix', ''));

       {$ifdef bUnicode}
        if RegGetIntValue(HKCU, AddFileName(ARegPath, 'Exports'), 'OpenPlugin', -1) <> -1 then
          FUnicode := False;
       {$endif bUnicode}
      end else
        AHandle := GetPluginModuleHandle;
    end;

    if AHandle <> 0 then begin
      { Плугин уже загружен, спросим у него самого }
     {$ifdef bUnicode}
      vGetPluginInfo := GetProcAddress( AHandle, 'GetPluginInfoW' );
     {$else}
      vGetPluginInfo := GetProcAddress( AHandle, 'GetPluginInfo' );
     {$endif bUnicode}
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

     {$ifdef bUnicode}
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
//          vStr := StrOemToAnsi(vInfoA.PluginMenuStrings[I]) + ' [A]';
            vStr := StrOemToAnsi(vInfoA.PluginMenuStrings[I]);
            FCommands.Add( TFarPluginCmd.CreateEx(Self, I, vStr) );
          end;

          if vInfoA.PluginConfigStringsNumber > 0 then
//          FConfigString := StrOemToAnsi(vInfoA.PluginConfigStrings[0]) + ' [A]';
            FConfigString := StrOemToAnsi(vInfoA.PluginConfigStrings[0]);

          if vInfoA.CommandPrefix <> nil then
            FPrefixes := StrOemToAnsi(vInfoA.CommandPrefix);
        end;
      end;
     {$endif bUnicode}
    end;

    FHasCommands := FCommands.Count > 0;
    if not FHasCommands then
      { Добавляем одну фиктивную команду }
      FCommands.Add( TFarPluginCmd.CreateEx(Self, 0, '') );

    FConfigString := StrDeleteChars(FConfigString, ['&']);
  end;


  procedure TFarPlugin.UpdateLoaded;
  var
    vHandle :THandle;
  begin
    vHandle := GetPluginModuleHandle;
    FLoaded := vHandle <> 0;
    if FLoaded then begin
      UpdatePluginInfo('', vHandle);
      UpdateHotkey;
      FUnregistered := False;
    end;
  end;


  procedure TFarPlugin.UpdateHotkey;
  var
    I :Integer;
    vPath, vPath1, vStr :TString;
    vHotkey :TChar;
  begin
    if FHasCommands then begin
      vPath := AddFileName(FHotkeysRoot, GetRegDllKey);
      for I := 0 to FCommands.Count - 1 do begin
        vPath1 := vPath;
        if I > 0 then
          vPath1 := vPath + '%' + Int2Str(I);
        vStr := StrOemToAnsi(RegGetStrValue(HKCU, vPath1, 'Hotkey', ''));
        vHotkey := #0;
        if vStr <> '' then
          vHotkey := vStr[1];
        Command[I].FHotkey := vHotkey;
      end;
    end;
  end;


  function TFarPlugin.GetCommand(AIndex :Integer) :TFarPluginCmd;
  begin
    Result := FCommands[AIndex];
  end;


  function TFarPlugin.GetPluginModuleHandle :THandle;
  var
    vStr :TString;
  begin
    vStr := ExtractFileName(FFileName);
    Result := GetModuleHandle(PTChar(vStr));
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


  function TFarPlugin.GetRegDllKey :TString;
  begin
    Result := StrReplaceChars(GetPluginRelativePath, ['\'], '/');
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


  function TFarPlugin.FindRegCachePath :TString;
 {$ifdef bUnicode}
  begin
    { Новый формат кэша плагинов Far/2 build 910+ }
    Result := AddFileName(FCacheRoot, StrReplaceChars(FFileName, ['\'], '/'));
 {$else}
  { Вообще говоря, функция используется только в Far/2. Но, оставим, для общности... }
  var
    I :Integer;
    vDllName, vPath :TString;
  begin
    I := 0;
    while True do begin
      vPath := AddFileName(FCacheRoot, 'Plugin' + Int2Str(I));
      if not RegHasKey(HKCU, vPath) then
        Break;
      vDllName := RegGetStrValue(HKCU, vPath, FCacheDllValue, '');
      if StrEqual(vDllName, FFileName) then begin
        Result := vPath;
        Exit;
      end;
      Inc(I);
    end;
 {$endif bUnicode}
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


  procedure TFarPlugin.MarkAsPreload(AOn :Boolean);
  var
    vRegPath :TString;
  begin
    vRegPath := FindRegCachePath;
    if vRegPath <> '' then
      RegSetIntValue(HKCU, vRegPath, 'Preload', IntIf(AOn, 1, 0));
  end;


 {$ifdef bUnicode}
  procedure TFarPlugin.PluginLoad;
  var
    vHandle :THandle;
  begin
    vHandle := GetPluginModuleHandle;
    if vHandle = 0 then begin
      { Принуждаем FAR загрузит плагин в память }
      FARAPI.PluginsControl(INVALID_HANDLE_VALUE, PCTL_UNLOADPLUGIN, PLT_PATH, PFarChar(FFileName));
      MarkAsPreload(True);
      FARAPI.PluginsControl(INVALID_HANDLE_VALUE, PCTL_LOADPLUGIN, PLT_PATH, PFarChar(FFileName));
      UpdateLoaded;
    end;
    FUnregistered := False;
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

    FARAPI.PluginsControl(INVALID_HANDLE_VALUE, PCTL_UNLOADPLUGIN, PLT_PATH, PFarChar(FFileName));
(*
    if not AUnregister then begin
      {!!!}
//    MarkAsPreload(False);

      FARAPI.PluginsControl(INVALID_HANDLE_VALUE, PCTL_LOADPLUGIN, PLT_PATH, PFarChar(FFileName));
      FUnregistered := False;
    end else
*)
      FUnregistered := True;

    UpdateLoaded;
  end;
 {$endif bUnicode}


  function TFarPlugin.PluginSetup :boolean;
  var
    vHandle :THandle;
    vConfigure :TConfigure;
   {$ifdef bUnicode}
    vConfigureA :TConfigureA;
   {$endif bUnicode}
  begin
    Result := False;
    vHandle := GetPluginModuleHandle;
   {$ifdef bUnicode}
    if vHandle = 0 then begin
      PluginLoad;
      vHandle := GetPluginModuleHandle;
    end;
   {$endif bUnicode}

    if vHandle <> 0 then begin
      {$ifdef bUnicode}
       vConfigure := GetProcAddress( vHandle, 'ConfigureW' );
      {$else}
       vConfigure := GetProcAddress( vHandle, 'Configure' );
      {$endif bUnicode}
       if Assigned(vConfigure) then begin
         vConfigure(0);
         UpdateLoaded;
         Result := True;
       end;

      {$ifdef bUnicode}
       if not Result then begin
         { Возможно, это ансишный плагин... }
         vConfigureA := GetProcAddress( vHandle, 'Configure' );
         if Assigned(vConfigureA) then begin
           vConfigureA(0);
           UpdateLoaded;
           Result := True;
         end;
       end;
      {$endif bUnicode}
    end;
  end;


  procedure TFarPlugin.PluginHelp;
  begin
    FARAPI.ShowHelp(PTChar(FFileName), nil,  0);
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


  procedure UpdateLoadedPlugins;
  var
    I :Integer;
  begin
    for I := 0 to FPlugins.Count - 1 do begin
//    try
        TFarPlugin(FPlugins[I]).UpdateLoaded;
//    except
//      {!!!}
//    end;
    end;
  end;


  procedure UpdatePluginHotkeys;
  var
    I :Integer;
  begin
    for I := 0 to FPlugins.Count - 1 do
      TFarPlugin(FPlugins[I]).UpdateHotkey;
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
  var
    vDlls :TStrList;

    function LocEnumPlugins(const AFileName :TString; const ARec :TFarFindData) :Integer;
    begin
      vDlls.Add(AFileName);
      Result := 1;
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
      EnumFilesEx(FPluginsPath, '*.dll', LocalAddr(@LocEnumPlugins));

      if FAddPluginsPaths <> '' then begin
        for I := 1 to WordCount(FAddPluginsPaths, [';', ',']) do begin
          vPath := Trim(ExtractWord(I, FAddPluginsPaths, [';', ',']));
          if (vPath <> '') and (vPath[1] = '"') and (vPath[length(vPath)] = '"') then
            vPath := Trim(Copy(vPath, 2, length(vPath) - 2));
          vPath := StrExpandEnvironment(vPath);
          vPath := ExpandFileName(vPath);
          if WinFolderExists(vPath) then
            EnumFilesEx(vPath, '*.dll', LocalAddr(@LocEnumPlugins));
        end;
      end;

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

           {$ifdef bUnicode}
            { Новый формат кэша плагинов Far/2 build 910+ }
            vDllName := StrReplaceChars(vName, ['/'], '\');
           {$else}
            vDllName := RegGetStrValue(HKCU, vPath, FCacheDllValue, '');
           {$endif bUnicode}

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
           {$ifdef bUnicode}
            if Assigned( GetProcAddress( vHandle, 'SetStartupInfo' ) ) or Assigned( GetProcAddress( vHandle, 'SetStartupInfoW' ) ) then begin
           {$else}
            if Assigned( GetProcAddress( vHandle, 'SetStartupInfo' ) ) then begin
           {$endif bUnicode}
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
  end;


  procedure ReInitFarPluginsList;
  begin
    { Обновление списка плагинов, после смены языка }
    UpdateLoadedPlugins;
    FPlugins.SortList(True, 0);
  end;


 {$ifdef bUnicode}
  function LoadNewPlugin(const AFileName :TString) :TFarPlugin;
  var
    vRes :Integer;
    vPlugin :TFarPlugin;
  begin
    vRes := FARAPI.PluginsControl(INVALID_HANDLE_VALUE, PCTL_LOADPLUGIN, PLT_PATH, PFarChar(AFileName));
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
  end;


  procedure UnLoadPlugin(const AFileName :TString);
  var
    vRes :Integer;
    vPlugin :TFarPlugin;
  begin
    vPlugin := FindPlugin(AFileName);
    if vPlugin <> nil then
      vPlugin.PluginUnload(True)
    else begin
      vRes := FARAPI.PluginsControl(INVALID_HANDLE_VALUE, PCTL_UNLOADPLUGIN, PLT_PATH, PFarChar(AFileName));
      if vRes = 0 then
        AppErrorId(strPluginUnloadError);
    end;
  end;
 {$endif bUnicode}


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
      ReInitFarPluginsList;
      gLang := vLang;
    end;
  end;



initialization

finalization
  FreeObj(FPlugins);
end.




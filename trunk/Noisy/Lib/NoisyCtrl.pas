{$I Defines.inc}
{$Typedaddress Off}

unit NoisyCtrl;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{* Процедуры взаимодействия с плеером                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    NoisyConsts,
    NoisyUtil;


  const
    cPlayerName    = 'Noisy.exe';
    cWaitTimeout   = 2000;

  var
    FModulePath :TString;


  type
    TBassPlugin = class(TObject)
    public
      constructor CreateEx(const AName :TString; AVersion :Cardinal);
    private
      FName    :TString;
      FVersion :Cardinal;
    public
      property Name :TString read FName;
      property Version :Cardinal read FVersion;
    end;

    TBassFormat = class(TBasis)
    public
      constructor CreateEx(const AName, AExts :TString; ACode :Cardinal);
      function GetShortName :TString;
    private
      FCode    :Cardinal;
      FName    :TString;
      FExts    :TString;
    public
      property Name :TString read FName;
      property Exts :TString read FExts;
    end;

  var
    FPlugins  :TObjList;
    FFormats  :TObjList;


  function ExecCommand(const AStr :TString) :THandle;
  function ExecCommandFmt(const AStr :TString; const Args :array of const) :THandle;

  procedure LockPlayer;
  procedure UnLockPlayer;

  function GetPlayerInfo(var AInfo :TPlayerInfo; AUpdateFormats :Boolean) :Boolean;
  function GetPlaylist :TString;

  function GetFormatByCode(ACode :Cardinal) :TBassFormat;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  constructor TBassPlugin.CreateEx(const AName :TString; AVersion :Cardinal);
  begin
    FName := AName;
    FVersion := AVersion;
  end;


  constructor TBassFormat.CreateEx(const AName, AExts :TString; ACode :Cardinal);
  begin
    FName := AName;
    FExts := AExts;
    FCode := ACode;
  end;


  function TBassFormat.GetShortName :TString;
  begin
    Result := '';
    if FExts <> '' then
      Result := StrUpCase(ExtractWord(1, FExts, [';', ',', '.', '*']));
    if Result = '' then
      Result := FName;
  end;



  function GetFormatByCode(ACode :Cardinal) :TBassFormat;
  var
    I :Integer;
    vFormat :TBassFormat;
  begin
    for I := 0 to FFormats.Count - 1 do begin
      vFormat := FFormats[I];
      if vFormat.FCode = ACode then begin
        Result := vFormat;
        exit;
      end;
    end;
    Result := nil;
  end;

 {-----------------------------------------------------------------------------}

  procedure SendStrTo(AWnd :THandle; const AStr :TString);
  var
    vStruct :CopyDataStruct;
   {$ifdef bUnicode}
   {$else}
    vStr :TWideStr;
   {$endif bUnicode}
  begin
    vStruct.dwData := nSendCmd;
   {$ifdef bUnicode}
    vStruct.cbData := Length(AStr) * SizeOf(WideChar);
    vStruct.lpData := PWideChar(AStr);
   {$else}
    vStr := AStr;
    vStruct.cbData := Length(vStr) * SizeOf(WideChar);
    vStruct.lpData := PWideChar(vStr);
   {$endif bUnicode}
    SendMessage(AWnd, WM_CopyData, 0, TIntPtr(@vStruct));
  end;



  function ExecCommand(const AStr :TString) :THandle;
  var
    vWnd :THandle;
    vPlayerName :TString;
    vStart :Cardinal;
  begin
    Result := INVALID_HANDLE_VALUE;
    vWnd := FindWindow(WndClassName, nil);
    if vWnd = 0 then begin
      vPlayerName := AddFileName(FModulePath, cPlayerName);
      if not WinFileExists(vPlayerName) then
        AppErrorFmt('Not found:'#13'%s', [vPlayerName]);

      if ShellOpen(0, vPlayerName, AStr) then begin
        { Подождем пока player не запустится...}
        vStart := GetTickCount;
        vWnd := FindWindow(WndClassName, nil);
        while (vWnd = 0) and (TickCountDiff(GetTickCount, vStart) < cWaitTimeout) do begin
          Sleep(1);
          vWnd := FindWindow(WndClassName, nil);
        end;
      end;

    end else
      SendStrTo(vWnd, AStr);
  end;


  function ExecCommandFmt(const AStr :TString; const Args :array of const) :THandle;
  begin
    Result := ExecCommand(Format(AStr, Args));
  end;


 {-----------------------------------------------------------------------------}

  var
    FLocked :Integer;


  procedure LockPlayer;
  begin
    if FLocked = 0 then
      ExecCommand(CmdLock);
    Inc(FLocked);
  end;


  procedure UnLockPlayer;
  begin
    if FLocked  > 0 then begin
      Dec(FLocked);
      if FLocked = 0 then begin
        if FindWindow(WndClassName, nil) <> 0 then
          ExecCommand(CmdUnlock);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GetPlayerInfo(var AInfo :TPlayerInfo; AUpdateFormats :Boolean) :Boolean;
  var
    I :Integer;
    vHandle :THandle;
    vPtr :PChar;
    vPluginInfo :PBassPluginInfo;
    vFormatInfo :PAudioFormatInfo;
  begin
    Result := False;
    {!!! Синхронизация }
    vHandle := OpenFileMapping(FILE_MAP_READ, False, InfoMemName);
//  Trace('OpenFileMapping Handle=%p', [Pointer(vHandle)]);
    if vHandle = 0 then
      Exit;
    try
      vPtr := MapMemory(vHandle, False);
//    Trace('Memory=%p', [Pointer(vPtr)]);
      try
        {!!!Смотреть на размер структуры в памяти}
        CopyMemory(@AInfo, vPtr, SizeOf(TPlayerInfo));

        if AUpdateFormats then begin
          FPlugins.FreeAll;
          FFormats.FreeAll;

          vPluginInfo := Pointer(PChar(vPtr) + SizeOf(TPlayerInfo));
          for I := 0 to AInfo.FPlugins - 1 do begin
            FPlugins.Add(TBassPlugin.CreateEx(StrFromChrA(vPluginInfo.FName, cMaxPluginNameSize), vPluginInfo.FVersion));
            Inc(PChar(vPluginInfo), SizeOf(TBassPluginInfo));
          end;

          vFormatInfo := Pointer(vPluginInfo);
          for I := 0 to AInfo.FFormats - 1 do begin
            FFormats.Add(TBassFormat.CreateEx(StrFromChrA(vFormatInfo.FName, cMaxFormatNameSize), StrFromChrA(vFormatInfo.FExts, cMaxFormatNameSize), vFormatInfo.FCode));
            Inc(PChar(vFormatInfo), SizeOf(TAudioFormatInfo));
          end;
        end;

        Result := True;
      finally
        UnmapViewOfFile(vPtr);
      end;
    finally
      CloseHandle(vHandle);
    end;
  end;


  function GetPlaylist :TString;
  var
    vHandle :THandle;
    vPtr :PChar;
    vLen :Integer;
  begin
    Result := '';
    {!!! Синхронизация }
    vHandle := OpenFileMapping(FILE_MAP_READ, False, PlaylistMemName);
    if vHandle = 0 then
      Exit {AppErrorID(strPlaylistIsEmpty)} ;
    try
      vPtr := MapMemory(vHandle, False);
      try
        CopyMemory(@vLen, vPtr, SizeOf(Integer));
       {$ifdef bUnicode}
        SetString(Result, nil, vLen);
        CopyMemory(PTChar(Result), vPtr + SizeOf(Integer), vLen * SizeOf(TChar));
       {$else}
        SetString(Result, nil, vLen);
        WideCharToMultiByte(CP_ACP, 0, PWideChar(vPtr + SizeOf(Integer)), vLen, PTChar(Result), vLen, nil, nil);
       {$endif bUnicode}

      finally
        UnmapViewOfFile(vPtr);
      end;
    finally
      CloseHandle(vHandle);
    end;
  end;


initialization
//Trace('SizeOf(TPlayerInfo)=%d', [SizeOf(TPlayerInfo)]);

  FPlugins  := TObjList.Create;
  FFormats  := TObjList.Create;

finalization
  FreeObj(FPlugins);
  FreeObj(FFormats);
end.


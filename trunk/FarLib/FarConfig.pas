{$I Defines.inc}

unit FarConfig;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Объектная обертка хранения настроек                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,
    MixStrings,
    MixWinUtils,
    Far_API,
    FarCtrl;


  type
    TFarConfig = class(TBasis)
    public
      constructor CreateEx(AStore :Boolean; const AName :TString);
      destructor Destroy; override;

      function OpenKey(const AName :TString) :Boolean;
      function DeleteKey(const AName :TString) :Boolean;

      function ReadStr(const AName :TString; const ADefault :TString = '') :TString;
      procedure WriteStr(const AName :TString; const AValue :TString);
      function ReadInt(const AName :TString; ADefault :Integer = 0) :Integer;
      procedure WriteInt(const AName :TString; AValue :Integer);
      function ReadLog(const AName :TString; ADefault :Boolean = False) :Boolean;
      procedure WriteLog(const AName :TString; AValue :Boolean);

      procedure StrValue(const AName :TString; var AValue :TString);
      procedure IntValue(const AName :TString; var AValue :Integer);
      procedure LogValue(const AName :TString; var AValue :Boolean);
      procedure ColorValue(const AName :TString; var AValue :TFarColor);
      function IntValue1(const AName :TString; AValue :Integer) :Integer;

    private
      FStore   :Boolean;
     {$ifdef Far3}
      FHandle  :THandle;
      FCurKey  :THandle;
     {$else}
      FPath    :TString;
      FRootKey :HKEY;
      FCurKey  :HKEY;
     {$endif Far3}
      FExists  :Boolean;

    public
      property Exists :Boolean read FExists;
    end;


 {$ifdef Far3}
  function FarOpenSetings(const APluginID :TGUID) :THandle;
  function FarOpenKey(AHandle, AKey :THandle; const AName :TString) :THandle;
  function FarCreateKey(AHandle, AKey :THandle; const AName :TString) :THandle;
  function FarSetValue(AHandle, AKey :THandle; const AName :TString; AType :Integer; AInt :Int64; AStr :PFarChar) :Boolean;
  function FarGetValueInt(AHandle, AKey :THandle; const AName :TString; ADefault :Int64) :Int64;
  function FarGetValueStr(AHandle, AKey :THandle; const AName :TString; const ADefault :TString) :TString;

  function FarGetSetting(ARoot :Cardinal; const AName :TString) :Int64;
    { См. Plugin3.pas - FSSF_xxx }
 {$endif Far3}

  function FarConfigGetStrValue(const APlugName, APath, AName, ADefault :TString) :TString;
  function FarConfigGetIntValue(const APlugName, APath, AName :TString; ADefault :Integer) :Integer;
  procedure FarConfigSetStrValue(const APlugName, APath, AName, AValue :TString);
  procedure FarConfigSetIntValue(const APlugName, APath, AName :TString; AValue :Integer);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


(*
API для хранения настроек:

   int WINAPI SettingsControl(HANDLE hHandle, int Command, int Param1, INT_PTR Param2)

   Command:

   SCTL_CREATE            - hHandle - INVALID_HANDLE_VALUE.
                            Param2 - FarSettingsCreate, на входе guid плагина, на выходе - хэндл настроек.
                            При неудаче вернёт FALSE.

   SCTL_FREE              - hHandle - HANDLE, который вернул SCTL_CREATE.

   SCTL_SET               - hHandle - HANDLE, который вернул SCTL_CREATE.
                            Param2 - указатель на FarSettingsItem.
                            Root - задаёт место сохранения настроек. 0 - корень для плагина. подключи получаются при помощи SCTL_SUBKEY.
                            Name - имя сохраняемого значения.
                            Type - тип.
                            Value - само значение.

   SCTL_GET               - hHandle - HANDLE, который вернул SCTL_CREATE.
                            Param2 - указатель на FarSettingsItem.
                            Value заполняет фар, остальное - плагин.

   SCTL_CREATESUBKEY, SCTL_OPENSUBKEY (было SCTL_SUBKEY)
                            - hHandle - HANDLE, который вернул SCTL_CREATE.
                            Param2 - указатель на FarSettingsValue.
                            возвращает описатель подключа с именем Value для ключа с описателем Root.

   SCTL_ENUM              - получить спиок подключей и значений.
                            hHandle - HANDLE, который вернул SCTL_CREATE.
                            Param2 - указатель на FarSettingsEnum.
                            Root - описатель ключа, откуда брать информацию.
                            Count - количество возвращаемых элементов.
                            Items - элементы.

   SCTL_DELETE            - удалить подключ или значение.
                            hHandle - HANDLE, который вернул SCTL_CREATE.
                            Param2 - указатель на FarSettingsValue.
                            Root - описатель ключа, в котором находится удаляемое.
                            Value - имя подключа или значения, которое надо удалить.
*)


 {$ifdef Far3}
  function FarOpenSetings(const APluginID :TGUID) :THandle;
  var
    vCreate :TFarSettingsCreate;
  begin
    Result := 0;
    vCreate.StructSize := SizeOf(vCreate);
    vCreate.Guid := APluginID;
    vCreate.Handle := 0;
    if FARAPI.SettingsControl(INVALID_HANDLE_VALUE, SCTL_CREATE, 0, @vCreate) <> 0 then
      Result := vCreate.Handle;
  end;


  function FarOpenKey(AHandle, AKey :THandle; const AName :TString) :THandle;
  var
    vItem :TFarSettingsValue;
  begin
    vItem.StructSize := SizeOf(vItem);
    vItem.Root := AKey;
    vItem.Value := PFarChar(AName);
    Result := THandle(FARAPI.SettingsControl(AHandle, SCTL_OPENSUBKEY, 0, @vItem));
  end;


  function FarCreateKey(AHandle, AKey :THandle; const AName :TString) :THandle;
  var
    vItem :TFarSettingsValue;
  begin
    vItem.StructSize := SizeOf(vItem);
    vItem.Root := AKey;
    vItem.Value := PFarChar(AName);
    Result := THandle(FARAPI.SettingsControl(AHandle, SCTL_CREATESUBKEY, 0, @vItem));
  end;


  function FarDeleteKey(AHandle, AKey :THandle; const AName :TString) :Boolean;
  var
    vItem :TFarSettingsValue;
    vKey :THandle;
  begin
    Result := False;
    vKey := FarOpenKey(AHandle, AKey, AName);
    if vKey <> 0 then begin
      vItem.StructSize := SizeOf(vItem);
      vItem.Root := vKey;
      vItem.Value := nil;
      Result := FARAPI.SettingsControl(AHandle, SCTL_DELETE, 0, @vItem) <> 0;
    end;
  end;

(*
  function FarDeleteKey(AHandle, AKey :THandle; const AName :TString) :Boolean;
  var
    vItem :TFarSettingsValue;
  begin
    Result := False;
    if FarOpenKey(AHandle, AKey, AName) <> 0 then begin
      vItem.Root := AKey;
      vItem.Value := PFarChar(AName);
      Result := FARAPI.SettingsControl(AHandle, SCTL_DELETE, 0, @vItem) <> 0;
    end;
  end;

  function FarDeleteKey(AHandle, AKey :THandle; const AName :TString) :Boolean;
  var
    vItem :TFarSettingsValue;
  begin
    vItem.Root := AKey;
    vItem.Value := PFarChar(AName);
    Result := FARAPI.SettingsControl(AHandle, SCTL_DELETE, 0, @vItem) <> 0;
  end;
*)

  function FarSetValue(AHandle, AKey :THandle; const AName :TString; AType :Integer; AInt :Int64; AStr :PFarChar) :Boolean;
  var
    vItem :TFarSettingsItem;
  begin
    vItem.StructSize := SizeOf(vItem);
    vItem.Root := AKey;
    vItem.Name := PFarChar(AName);
    vItem.FType := AType;
    case AType of
      FST_QWORD:
        vItem.Value.Number := AInt;
      FST_STRING:
        vItem.Value.Str := AStr;
      FST_DATA: begin
        vItem.Value.Data.Size := AInt;
        vItem.Value.Data.Data := AStr;
      end;
    end;
    Result := FARAPI.SettingsControl(AHandle, SCTL_SET, 0, @vItem) <> 0;
  end;


  function FarGetValueInt(AHandle, AKey :THandle; const AName :TString; ADefault :Int64) :Int64;
  var
    vItem :TFarSettingsItem;
  begin
    FillZero(vItem, SizeOf(vItem));
    vItem.StructSize := SizeOf(vItem);
    vItem.Root := AKey;
    vItem.Name := PFarChar(AName);
    vItem.FType := FST_QWORD;
    if FARAPI.SettingsControl(AHandle, SCTL_GET, 0, @vItem) <> 0 then
      Result := vItem.Value.Number
    else
      Result := ADefault;
  end;


  function FarGetValueStr(AHandle, AKey :THandle; const AName :TString; const ADefault :TString) :TString;
  var
    vItem :TFarSettingsItem;
  begin
    FillZero(vItem, SizeOf(vItem));
    vItem.StructSize := SizeOf(vItem);
    vItem.Root := AKey;
    vItem.Name := PFarChar(AName);
    vItem.FType := FST_STRING;
    if FARAPI.SettingsControl(AHandle, SCTL_GET, 0, @vItem) <> 0 then
      Result := vItem.Value.Str
    else
      Result := ADefault;
  end;


  function FarGetSetting(ARoot :Cardinal; const AName :TString) :Int64;
  var
    vHandle :THandle;
  begin
    Result := 0;
    vHandle := FarOpenSetings(GUID_NULL);
    if vHandle = 0 then
      Exit;
    try
      Result := FarGetValueInt(vHandle, ARoot, AName, 0);
    finally
      FARAPI.SettingsControl(vHandle, SCTL_FREE, 0, nil);
    end;
  end;
 {$endif Far3}


 {-----------------------------------------------------------------------------}
 { TFarConfig                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TFarConfig.CreateEx(AStore :Boolean; const AName :TString);
  begin
    Create;
    FStore := AStore;
   {$ifdef Far3}
    FHandle := FarOpenSetings(PluginID);
    FExists := FHandle <> 0;
    FCurKey := 0;
   {$else}
    FPath := TString(FARAPI.RootKey) + '\' + AName;
    if AStore then begin
      RegOpenWrite(HKCU, FPath, FRootKey);
      FExists := True;
    end else
      FExists := RegOpenRead(HKCU, FPath, FRootKey);
    FCurKey := FRootKey;
   {$endif Far3}
  end;


  destructor TFarConfig.Destroy; {override;}
  begin
   {$ifdef Far3}
    if FHandle <> 0 then
      FARAPI.SettingsControl(FHandle, SCTL_FREE, 0, nil);
   {$else}
    if (FCurKey <> 0) and (FCurKey <> FRootKey) then
      RegCloseKey(FCurKey);
    if FRootKey <> 0 then
      RegCloseKey(FRootKey);
   {$endif Far3}
    inherited Destroy;
  end;


  function TFarConfig.OpenKey(const AName :TString) :Boolean;
  var
    vName :TString;
   {$ifdef Far3}
    vPtr :PTChar;
   {$endif Far3}
  begin
   {$ifdef Far3}
    FCurKey := 0;
    Result := True;
    if AName <> '' then begin
      vPtr := PTChar(AName);
      while (vPtr^ <> #0) and (Result) do begin
        vName := ExtractNextWord(vPtr, ['\']);
        if FStore then
          FCurKey := FarCreateKey(FHandle, FCurKey, vName)
        else
          FCurKey := FarOpenKey(FHandle, FCurKey, vName);
        Result := FCurKey <> 0;
      end;
    end;
   {$else}
    if AName = '' then begin
      if (FCurKey <> 0) and (FCurKey <> FRootKey) then
        RegCloseKey(FCurKey);
      FCurKey := FRootKey;
      Result := True;
    end else
    begin
      vName := FPath + '\' + AName;
      if FStore then begin
        RegOpenWrite(HKCU, vName, FCurKey);
        Result := True;
      end else
        Result := RegOpenRead(HKCU, vName, FCurKey);
    end
   {$endif Far3}
  end;


  function TFarConfig.DeleteKey(const AName :TString) :Boolean;
  begin
   {$ifdef Far3}
    Result := FarDeleteKey(FHandle, FCurKey, AName);
   {$else}
    Result := RegDeleteKey(FCurKey, PTChar(AName)) = ERROR_SUCCESS;
   {$endif Far3}
  end;


  function TFarConfig.ReadStr(const AName :TString; const ADefault :TString = '') :TString;
  begin
   {$ifdef Far3}
    Result := FarGetValueStr(FHandle, FCurKey, AName, ADefault)
   {$else}
    Result := RegQueryStr(FCurKey, AName, ADefault);
   {$endif Far3}
  end;


  procedure TFarConfig.WriteStr(const AName :TString; const AValue :TString);
  begin
   {$ifdef Far3}
    FarSetValue(FHandle, FCurKey, AName, FST_STRING, 0, PTChar(AValue))
   {$else}
    RegWriteStr(FCurKey, AName, AValue)
   {$endif Far3}
  end;


  procedure TFarConfig.StrValue(const AName :TString; var AValue :TString);
  begin
    if FStore then
      WriteStr(AName, AValue)
    else
      AValue := ReadStr(AName, AValue);
  end;



  function TFarConfig.ReadInt(const AName :TString; ADefault :Integer = 0) :Integer;
  begin
   {$ifdef Far3}
    Result := FarGetValueInt(FHandle, FCurKey, AName, ADefault);
   {$else}
    Result := RegQueryInt(FCurKey, AName, ADefault);
   {$endif Far3}
  end;


  procedure TFarConfig.WriteInt(const AName :TString; AValue :Integer);
  begin
   {$ifdef Far3}
    FarSetValue(FHandle, FCurKey, AName, FST_QWORD, AValue, nil);
   {$else}
    RegWriteInt(FCurKey, AName, AValue);
   {$endif Far3}
  end;


  function TFarConfig.ReadLog(const AName :TString; ADefault :Boolean = False) :Boolean;
  begin
    Result := ReadInt(AName, byte(ADefault)) <> 0;
  end;


  procedure TFarConfig.WriteLog(const AName :TString; AValue :Boolean);
  begin
    WriteInt(AName, Byte(AValue));
  end;



  procedure TFarConfig.IntValue(const AName :TString; var AValue :Integer);
  begin
    if FStore then
      WriteInt(AName, AValue)
    else
      AValue := ReadInt(AName, AValue);
  end;



  function TFarConfig.IntValue1(const AName :TString; AValue :Integer) :Integer;
  begin
    IntValue(AName, AValue);
    Result := AValue;
  end;


  procedure TFarConfig.LogValue(const AName :TString; var AValue :Boolean);
  var
    vInt :Integer;
  begin
    vInt := Byte(AValue);
    IntValue(AName, vInt);
    AValue := vInt <> 0;
  end;


  procedure TFarConfig.ColorValue(const AName :TString; var AValue :TFarColor);
 {$ifdef Far3}
  var
    vInt :Int64;
  begin
    vInt := MakeInt64(GetColorFG(AValue), GetColorBG(AValue));
    if FStore then
      FarSetValue(FHandle, FCurKey, AName, FST_QWORD, vInt, nil)
    else begin
      vInt := FarGetValueInt(FHandle, FCurKey, AName, vInt);
      AValue := MakeColor(Int64Rec(vInt).Lo, Int64Rec(vInt).Hi);
    end;
 {$else}
  begin
    IntValue(AName, Integer(AValue));
 {$endif Far3}
  end;


 {-----------------------------------------------------------------------------}

  function FarConfigGetStrValue(const APlugName, APath, AName, ADefault :TString) :TString;
  begin
    Result := ADefault;
    with TFarConfig.CreateEx(False, APlugName) do
      try
        if Exists then begin
          if (APath <> '') and not OpenKey(APath) then
            Exit;
          Result := ReadStr(AName, ADefault);
        end;
      finally
        Destroy;
      end;
  end;

  function FarConfigGetIntValue(const APlugName, APath, AName :TString; ADefault :Integer) :Integer;
  begin
    Result := ADefault;
    with TFarConfig.CreateEx(False, APlugName) do
      try
        if Exists then begin
          if (APath <> '') and not OpenKey(APath) then
            Exit;
          Result := ReadInt(AName, ADefault);
        end;
      finally
        Destroy;
      end;
  end;

  procedure FarConfigSetStrValue(const APlugName, APath, AName, AValue :TString);
  begin
    with TFarConfig.CreateEx(True, APlugName) do
      try
        if (APath <> '') and not OpenKey(APath) then
          Exit;
        WriteStr(AName, AValue);
      finally
        Destroy;
      end;
  end;


  procedure FarConfigSetIntValue(const APlugName, APath, AName :TString; AValue :Integer);
  begin
    with TFarConfig.CreateEx(True, APlugName) do
      try
        if (APath <> '') and not OpenKey(APath) then
          Exit;
        WriteInt(AName, AValue);
      finally
        Destroy;
      end;
  end;

end.

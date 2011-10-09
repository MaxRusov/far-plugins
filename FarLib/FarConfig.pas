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
    MixWinUtils,
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarCtrl;


  type
    TFarConfig = class(TBasis)
    public
      constructor CreateEx(AStore :Boolean; const AName :TString);
      destructor Destroy; override;

      procedure StrValue(const AName :TString; var AValue :TString);
      procedure IntValue(const AName :TString; var AValue :Integer);
      procedure LogValue(const AName :TString; var AValue :Boolean);
      procedure ColorValue(const AName :TString; var AValue :TFarColor);

    private
      FStore   :Boolean;
     {$ifdef Far3}
      FHandle  :THandle;
     {$else}
      FRootKey :HKEY;
     {$endif Far3}
      FExists  :Boolean;

    public
      property Exists :Boolean read FExists;
    end;


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

   SCTL_SUBKEY            - hHandle - HANDLE, который вернул SCTL_CREATE.
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
    vCreate.Guid := PluginID;
    vCreate.Handle := 0;
    if FARAPI.SettingsControl(INVALID_HANDLE_VALUE, SCTL_CREATE, 0, @vCreate) <> 0 then
      Result := vCreate.Handle;
  end;


  function FarSetValue(AHandle :THandle; const AName :TString; AType :Integer; AInt :Int64; AStr :PFarChar) :Boolean;
  var
    vItem :TFarSettingsItem;
  begin
    vItem.Root := 0;
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


  function FarGetValueInt(AHandle :THandle; const AName :TString; ADefault :Int64) :Int64;
  var
    vItem :TFarSettingsItem;
  begin
    FillZero(vItem, SIzeOf(vItem));
    vItem.Root := 0;
    vItem.Name := PFarChar(AName);
    vItem.FType := FST_QWORD;
    if FARAPI.SettingsControl(AHandle, SCTL_GET, 0, @vItem) <> 0 then
      Result := vItem.Value.Number
    else
      Result := ADefault;
  end;


  function FarGetValueStr(AHandle :THandle; const AName :TString; var AStr :TString) :Boolean;
  var
    vItem :TFarSettingsItem;
  begin
    FillZero(vItem, SIzeOf(vItem));
    vItem.Root := 0;
    vItem.Name := PFarChar(AName);
    vItem.FType := FST_STRING;
    Result := FARAPI.SettingsControl(AHandle, SCTL_GET, 0, @vItem) <> 0;
    if Result then
      AStr := vItem.Value.Str;
  end;
 {$endif Far3}


 {-----------------------------------------------------------------------------}
 { TFarConfig                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TFarConfig.CreateEx(AStore :Boolean; const AName :TString);
 {$ifndef Far3}
  var
    vPath :TString;
 {$endif Far3}
  begin
    Create;
    FStore := AStore;
   {$ifdef Far3}
    FHandle := FarOpenSetings(PluginID);
    FExists := FHandle <> 0;
   {$else}
    vPath := TString(FARAPI.RootKey) + '\' + AName;
    if AStore then begin
      RegOpenWrite(HKCU, vPath, FRootKey);
      FExists := True;
    end else
      FExists := RegOpenRead(HKCU, vPath, FRootKey);
   {$endif Far3}
  end;


  destructor TFarConfig.Destroy; {override;}
  begin
   {$ifdef Far3}
    if FHandle <> 0 then
      FARAPI.SettingsControl(FHandle, SCTL_FREE, 0, nil);
   {$else}
    if FRootKey <> 0 then
      RegCloseKey(FRootKey);
   {$endif Far3}
    inherited Destroy;
  end;


  procedure TFarConfig.StrValue(const AName :TString; var AValue :TString);
  begin
   {$ifdef Far3}
    if FStore then
      FarSetValue(FHandle, AName, FST_STRING, 0, PTChar(AValue))
    else
      FarGetValueStr(FHandle, AName, AValue);
   {$else}
    if FStore then
      RegWriteStr(FRootKey, AName, AValue)
    else
      AValue := RegQueryStr(FRootKey, AName, AValue);
   {$endif Far3}
  end;


  procedure TFarConfig.IntValue(const AName :TString; var AValue :Integer);
  begin
   {$ifdef Far3}
    if FStore then
      FarSetValue(FHandle, AName, FST_QWORD, AValue, nil)
    else
      AValue := FarGetValueInt(FHandle, AName, AValue);
   {$else}
    if FStore then
      RegWriteInt(FRootKey, AName, AValue)
    else
      AValue := RegQueryInt(FRootKey, AName, AValue);
   {$endif Far3}
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
      FarSetValue(FHandle, AName, FST_QWORD, vInt, nil)
    else begin
      vInt := FarGetValueInt(FHandle, AName, vInt);
      AValue := MakeColor(Int64Rec(vInt).Lo, Int64Rec(vInt).Hi);
    end;
 {$else}
  begin
    IntValue(AName, Integer(AValue));
 {$endif Far3}
  end;



end.

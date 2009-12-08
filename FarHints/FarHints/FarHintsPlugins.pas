{$I Defines.inc}

unit FarHintsPlugins;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    FarCtrl,
    FarHintsConst,
    FarHintsAPI;

  const
    cPluginsFolder     = 'Plugins';
    cPluginsMask       = '*.hll';
    cLangFileMask      = '*.lng';
    cPluginExportProc  = 'GetPluginInterface';


  type
    TPlugin = class(TNamedObject)
    public
      constructor CreateEx(const AName :TString);
      constructor CreateEmbedded(const AInterface :IEmbeddedHintPlugin);
      destructor Destroy; override;

      function CanProcess(const AItem :IFarItem) :Boolean;

      function GetMsg(AIndex :Integer) :TString;

    private
//    FName :TString;
      FHandle :THandle;
      FInfo :IHintPluginInfo;
      FInterface :IHintPlugin;
      FInited :Boolean;
      FEmbedded :Boolean;

      FLang :AnsiString;
      FMessages :TStringList;

      procedure InitPlugin;
      procedure DonePlugin;
      procedure UnloadNotify;

    public
      property Inited :Boolean read FInited;
      property Plugin :IHintPlugin read FInterface;
      property Info :IHintPluginInfo read FInfo;
    end;


    TPlugins = class(TObjList)
    public
      procedure ScanPlugins(const APath :TString);
      function FindPlugin(const AInterface :IHintPlugin) :TPlugin;
      procedure UnloadNotify;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    FarHintsClasses,
    MixDebug;


  function FolderExists(const aFolderName :TString) :Boolean;
  var
    vCode :Integer;
  begin
    vCode := Integer(MixUtils.FileGetAttr(RemoveBackSlash(aFolderName)));
    Result := (vCode <> -1) and (vCode and FILE_ATTRIBUTE_DIRECTORY <> 0);
  end;


  function StrUnquote(const AStr :TString; AQuote :TChar) :TString;
  var
    L :Integer;
    vChr :TChar;
    vDst, vSrc, vEnd :PTChar;
  begin
    if (AStr <> '') and (AStr[1] = AQuote) then begin
      L := Length(AStr) - 1;
      if AStr[L + 1] = AQuote then
        Dec(L);
      SetString(Result, nil, L);
      if L > 0 then begin
        vDst := Pointer(Result);
        vSrc := @AStr[2];
        vEnd := vSrc + L;
        while vSrc < vEnd do begin
          vChr := vSrc^;
          if vChr = '\' then begin
            Inc(vSrc);
            if vSrc = vEnd then
              Break;
            vChr := vSrc^;
            if vChr = 'n' then
              vChr := #13;
          end;
          vDst^ := vChr;
          Inc(vDst);
          Inc(vSrc);
        end;
        if vDst < PTChar(Pointer(Result)) + L then
          SetLength(Result, vDst - PTChar(Pointer(Result)));
      end;
    end else
      Result := AStr;
  end;


 {-----------------------------------------------------------------------------}
 { TPlugin                                                                     }
 {-----------------------------------------------------------------------------}

  constructor TPlugin.CreateEx(const AName :TString);
  begin
    Create;
    FName := AName;
    FInfo := THintPluginInfo.CreateEx(ExtractFileTitle(AName));
    InitPlugin;
  end;


  constructor TPlugin.CreateEmbedded(const AInterface :IEmbeddedHintPlugin);
  begin
    Create;
    FInterface := AInterface;
    FInfo := THintPluginInfo.CreateEx('');
    FInterface.InitPlugin(FarHints, FInfo);
    FEmbedded := True;
    FInited := True;
  end;


  destructor TPlugin.Destroy; {override;}
  begin
    DonePlugin;
    FreeIntf(FInfo);
    FreeObj(FMessages);
    inherited Destroy;
  end;


  procedure TPlugin.InitPlugin;
  var
    vMainProc :TGetPluginInterface;
  begin
    try
      FHandle := LoadLibraryEx(FName);

      vMainProc := GetProcAddressEx(FHandle, cPluginExportProc);

      FInterface := vMainProc;
      if FInterface = nil then
        AppError('Plugin interface not created');

      FInterface.InitPlugin(FarHints, FInfo);

      FInited := True;

    except
      FInited := False;
    end;
  end;



  procedure TPlugin.DonePlugin;

    procedure LocDone;
    begin
      if FInited then begin
        try
          FInterface.DonePlugin;
        except
          {};
        end;
        FInited := False;
      end;
      FreeIntf(FInterface);
    end;

  begin
    LocDone;
    if FHandle <> 0 then begin
      FreeLibrarySafe(FHandle);
      FHandle := 0;
    end;
  end;


  procedure TPlugin.UnloadNotify;
  begin
    IEmbeddedHintPlugin(FInterface).UnloadFarHints;
  end;



  function TPlugin.CanProcess(const AItem :IFarItem) :Boolean;
  begin
    if AItem.Name = '' then
      { Hint для диалога }
      Result := PF_ProcessDialog and FInfo.Flags <> 0
    else
      Result :=
        (AItem.IsPlugin and (PF_ProcessPluginItems and FInfo.Flags <> 0)) or
        (not AItem.IsPlugin and (PF_ProcessRealNames and FInfo.Flags <> 0));
  end;



  function TPlugin.GetMsg(AIndex :Integer) :TString;

    function LocLoadLang(const ALang :TString) :Boolean;
    var
      vMessages :TStringList;

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
        for I := 0 to vMessages.Count - 1 do begin
          vStr := vMessages[I];
          if StrEqual( ExtractWord(1, vStr, ['=']), '.Language') then begin
            Result := StrEqual(ExtractWord(2, vStr, ['=', ',']), ALang);
            Exit;
          end;
        end;
      end;

      function LocEnumLangFile(const AFileName :TString; const ARec :TFarFindData) :Integer;
      var
        I :Integer;
        vStr :TString;
      begin
//      Trace(AFileName);
        ReadStrings(AFileName, vMessages);
        if (ALang = '') or CheckLang(ALang) then begin

          for I := 0 to vMessages.Count - 1 do begin
            vStr := vMessages[I];
            if (vStr <> '') and (vStr[1] <> '.') and (vStr[1] <> '/') and (vStr[1] <> ';') then
              FMessages.Add( StrUnquote(vStr, '"') );
          end;

          Result := 0;
        end else
          Result := 1;
      end;

    var
      vFolderName :TString;
    begin
      vMessages := TStringList.Create;
      try
        vFolderName := RemoveBackSlash(ExtractFilePath(FName));
        EnumFilesEx(vFolderName, cLangFileMask, LocalAddr(@LocEnumLangFile));
        Result := FMessages.Count > 0;
      finally
        FreeObj(vMessages);
      end;
    end;

    procedure LocInitStrings;
    var
      vLang :TString;
    begin
      if FMessages = nil then
        FMessages := TStringList.Create;

      vLang := GetMsgStr(strLang);
      if StrEqual(vLang, FLang) then
        Exit;

      FMessages.Clear;
      if not LocLoadLang(vLang) then
        if not LocLoadLang(DefaultLang) then
          LocLoadLang('');

      FLang := vLang;
    end;

  begin
    LocInitStrings;
    if AIndex < FMessages.Count then
      Result := FMessages[AIndex]
    else
      Result := '';
  end;


 {-----------------------------------------------------------------------------}
 { TPlugins                                                                    }
 {-----------------------------------------------------------------------------}

  procedure TPlugins.ScanPlugins(const APath :TString);

    function LocEnumPlugin(const AFileName :TString; const ARec :TFarFindData) :Integer;
    begin
      AddSorted( TPlugin.CreateEx(AFileName), 0, dupAccept );
      Result := 1;
    end;

  var
    vFolderName :TString;
  begin
    vFolderName := APath;
    if vFolderName = '' then
      vFolderName := AddFileName(ExtractFilePath(ParamStr(0)), cPluginsFolder);
    if not FolderExists(vFolderName) then
      Exit;
    EnumFilesEx(vFolderName, cPluginsMask,  LocalAddr(@LocEnumPlugin));
  end;


  function TPlugins.FindPlugin(const AInterface :IHintPlugin) :TPlugin;
  var
    I :Integer;
  begin
    for I := 0 to Count - 1 do begin
      Result := Items[I];
      if Result.FInterface = AInterface then
        Exit;
    end;
    Result := nil;
  end;


  procedure TPlugins.UnloadNotify;
  var
    I :Integer;
    vPlugin :TPlugin;
  begin
    for I := Count - 1 downto 0 do begin
      vPlugin := Items[I];
      if vPlugin.FEmbedded then begin
        Remove(I);
        try
          vPlugin.UnloadNotify;
        finally
          FreeObj(vPlugin);
        end;
      end;
    end;
  end;


end.

{$I Defines.inc}

unit ColorSetMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,
    MixStrings,
    MixWinUtils,
    MixFormat,

    Far_API,
    FarCtrl,
    FarPlug,

    ColorSetConst,
    ColorSetList;



  type
    TColorSetPlug = class(TFarPlug)
    public
      destructor Destroy; override;
      procedure Init; override;
      procedure Startup; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;

    private
      FLibrary :TColorsLib;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TColorSetPlug                                                               }
 {-----------------------------------------------------------------------------}

  destructor TColorSetPlug.Destroy; {override;}
  begin
    FreeObj(FLibrary);
    inherited Destroy;
  end;


  procedure TColorSetPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
    FMinFarVer := MakeVersion(3, 0, 300);   { LUA }
   {$else}
   {$endif Far3}
  end;


  procedure TColorSetPlug.Startup; {override;}
  var
    vFileName :TString;
  begin
    FLibrary := TColorsLib.Create;

    vFileName := AddFileName(ExtractFilePath(FARAPI.ModuleName), cColorDefs);
    if WinFileExists(vFileName) then
      FLibrary.ReadColors(vFileName);

    RestoreDefColor;
    PluginConfig(False);

    if optDefaultPalette <> '' then
      {FLibrary.ReStorePalette(optDefaultPalette)};
  end;


  procedure TColorSetPlug.GetInfo; {override;}
  begin
    FFlags := PF_EDITOR or PF_VIEWER or PF_DIALOG or PF_PRELOAD;

    FMenuStr := GetMsg(sTitle);
   {$ifdef Far3}
    FMenuID  := cMenuID;
   {$endif Far3}

    FPrefix := cPrefix;
  end;


  function TColorSetPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    ColorListDlg(FLibrary);
  end;


  function TColorSetPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}

    procedure RunCommand(const ACmd :TString);
    var
      vPos :Integer;
      vCmd, vParam, vFileName :TString;
    begin
      vCmd := ACmd;
      vPos := ChrPos('=', ACmd);
      if vPos <> 0 then begin
        vCmd := Copy(ACmd, 1, vPos - 1);
        vParam := Copy(ACmd, vPos + 1, MaxInt);
      end;

      vFileName := SafeChangeFileExtension(FarExpandFileName(StrExpandEnvironment(vParam)), cPalFileExt);

      if StrEqual(vCmd, cSaveCmd) then
        FLibrary.StorePalette(vFileName)
      else
      if StrEqual(vCmd, cLoadCmd) then
        FLibrary.ReStorePalette(vFileName)
      else
        AppErrorIdFmt(strUnknownCommand, [ACmd]);
    end;

  var
    vCmd :TString;
  begin
    Result := INVALID_HANDLE_VALUE;
    if AStr <> nil then begin
      while AStr^ <> #0 do begin
        vCmd := ExtractParamStr(AStr);
        if vCmd <> '' then begin
          if (vCmd[1] = '/') or (vCmd[1] = '-') then begin
            Delete(vCmd, 1, 1);
            RunCommand(vCmd);
          end;
        end;
      end;
    end else
      ColorListDlg(FLibrary);
  end;


end.

{$I Defines.inc}

unit PlugMenuHints;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{* Интеграция с FAR Hints                                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarHintsAPI,

    PlugMenuCtrl,
    PlugMenuPlugs;



  type
    THintPluginObject = class(TInterfacedObject, IEmbeddedHintPlugin)
    public
      constructor CreateEx(AOwner :TFarDialog);

      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IEmbeddedHintPlugin}
      procedure UnloadFarHints; stdcall;

    private
      FAPI       :IFarHintsApi;
      FOwner     :TFarDialog;
    end;


  procedure RegisterHints(AOwner :TFarDialog);
  procedure UnRegisterHints;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    PlugListDlg,
    MixDebug;

  
 {-----------------------------------------------------------------------------}
 { THintPluginObject                                                           }
 {-----------------------------------------------------------------------------}

  constructor THintPluginObject.CreateEx(AOwner :TFarDialog);
  begin
    Create;
    FOwner := AOwner;
  end;


  procedure THintPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
    AInfo.Flags := PF_ProcessDialog or PF_CanChangeSize;
//  ReadSetup;
  end;


  procedure THintPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function THintPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vWinInfo :TWindowInfo;
    vGrid :TFarGrid;
    vTitle :TString;
    X, Y, vCol, vRow :Integer;
    vCommand :TFarPluginCmd;
  begin
    Result := False;
    if not optShowHints then
      Exit;

    FarGetWindowInfo(-1, vWinInfo, @vTitle, nil);
    if not (vWinInfo.WindowType in [WTYPE_DIALOG]) or (UpCompareSubStr(GetMsgStr(strTitle), vTitle) <> 0) then
      Exit;

    vGrid := (FOwner as TMenuDlg).Grid;

    X := AItem.MouseX;
    Y := AItem.MouseY;

    with FOwner.GetDlgRect do begin
      Dec(X, Left + vGrid.Left);
      Dec(Y, Top + vGrid.Top);
    end;

    if vGrid.HitTest(X, Y, vCol, vRow) <> ghsCell then
      Exit;

//  D := 0;
//  if vGrid.CalcColByDelta(X - 1) = vCol then
//    D := -1;

//  vRect := Bounds(AItem.MouseX + D, AItem.MouseY, 3, 1);
//  AItem.SetItemRect(vRect);

    vCommand := TMenuDlg(FOwner).GetCommand(vRow);

    vCommand.Plugin.UpdateVerInfo;
    AItem.AddStringInfo(GetMsgStr(strInfoFileName), ExtractFileName(vCommand.Plugin.FileName));
    AItem.AddStringInfo(GetMsgStr(strInfoFolder), RemoveBackSlash(ExtractFilePath(vCommand.Plugin.FileName)));

    if vCommand.Plugin.Description <> '' then
      AItem.AddStringInfo(GetMsgStr(strInfoDescr), vCommand.Plugin.Description);
    if vCommand.Plugin.Copyright <> '' then
      AItem.AddStringInfo(GetMsgStr(strInfoCopyright), vCommand.Plugin.Copyright);
    if vCommand.Plugin.Version <> '' then
      AItem.AddStringInfo(GetMsgStr(strInfoVersion), vCommand.Plugin.Version);

// {$ifdef Far3}
//  AItem.AddStringInfo('Command GUID', GUIDToString(vCommand.GUID));
// {$endif Far3}

    AItem.AddDateInfo(GetMsgStr(strInfoModified), vCommand.Plugin.FileDate);

    Result := True;
  end;


  procedure THintPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;


  procedure THintPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
  end;


  procedure THintPluginObject.UnloadFarHints; {stdcall;}
  begin
    UnRegisterHints;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}


  var
    FHintRegistered :Boolean;
    FIntegrationAPI :IFarHintsIntegrationAPI;
    FHintObject :IEmbeddedHintPlugin;


  procedure RegisterHints(AOwner :TFarDialog);
  var
    vHandle :THandle;
    vGetApiProc :TGetFarHinstAPI;
    vFarHintsApi :IFarHintsAPI;
  begin
    if not FHintRegistered then begin
      try
        vHandle := GetModuleHandle('FarHints.dll');
        if vHandle = 0 then
          Exit; {FarHints не установлен}

        vGetApiProc := GetProcAddress( vHandle, 'GetFarHinstAPI' );
        if not Assigned(vGetApiProc) then
          Exit; {FarHints неподходящей версии }

        vFarHintsApi := IFarHintsAPI(vGetApiProc);
        if vFarHintsApi = nil then
          Exit;

        vFarHintsAPI.QueryInterface(IFarHintsIntegrationAPI, FIntegrationAPI);
        if not Assigned(FIntegrationAPI) then
          Exit; {FarHints неподходящей версии }

        FHintObject := THintPluginObject.CreateEx(AOwner);
        FIntegrationAPI.RegisterEmbeddedPlugin(FHintObject);

        FHintRegistered := True;

      except
        FIntegrationAPI := nil;
        FHintObject := nil;
        raise;
      end;
    end;  
  end;


  procedure UnRegisterHints;
  begin
    if FHintRegistered then begin
      FIntegrationAPI.UnregisterEmbeddedPlugin(FHintObject);
      FHintObject := nil;
      FIntegrationAPI := nil;
      FHintRegistered := False;
    end;
  end;


initialization
finalization
  { Чтобы не было AV при закрытии по "крестику" }
  FHintRegistered := False;
  Pointer(FIntegrationAPI) := nil;
  pointer(FHintObject) := nil;
end.


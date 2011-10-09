{$I Defines.inc}

unit EdtFindHints;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{* Интеграция с FAR Hints                                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}

    FarCtrl,
    FarDlg,
    FarGrid,
    FarHintsAPI,

    EdtFindCtrl;



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
    EdtFindGrep,
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
    X, Y, vCol, vRow, vEdtRow :Integer;
    vWinInfo :TWindowInfo;
    vGrid :TFarGrid;
    vStr :TString;
  begin
    Result := False;
    if not optGrepShowHints then
      Exit;

    FarGetWindowInfo(-1, vWinInfo, @vStr, nil);
    if not (vWinInfo.WindowType in [WTYPE_DIALOG]) or (UpCompareSubStr(FOwner.GetText(0), vStr) <> 0) then
      Exit;

    vGrid := (FOwner as TGrepDlg).Grid;

    X := AItem.MouseX;
    Y := AItem.MouseY;

    with FOwner.GetDlgRect do begin
      Dec(X, Left + vGrid.Left);
      Dec(Y, Top + vGrid.Top);
    end;

    if vGrid.HitTest(X, Y, vCol, vRow) <> ghsCell then
      Exit;

    vStr := (FOwner as TGrepDlg).GetStringForHint(vRow, vEdtRow);
    if vStr <> '' then begin
      AItem.AddStringInfo(Int2Str(vEdtRow + 1), vStr);
      Result := True;
    end;
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

        vFarHintsApi := vGetApiProc;

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


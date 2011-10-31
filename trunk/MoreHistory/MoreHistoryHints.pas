{$I Defines.inc}

unit MoreHistoryHints;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{* Интеграция с FAR Hints                                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,

   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}

    FarCtrl,
    FarDlg,
    FarGrid,
    FarHintsAPI,

    MoreHistoryCtrl,
    MoreHistoryClasses;



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
    MoreHistoryDlg,
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
    X, Y, vCol, vRow :Integer;
    vHist :TFldHistoryEntry;
    vDomain, vStr :TString;
  begin
    Result := False;
    if not optShowHints then
      Exit;

    FarGetWindowInfo(-1, vWinInfo, @vStr, nil);
    if not (vWinInfo.WindowType in [WTYPE_DIALOG]) or (UpCompareSubStr(FOwner.GetText(0), vStr) <> 0) then
      Exit;

    vGrid := (FOwner as TFldMenuDlg).Grid;

    X := AItem.MouseX;
    Y := AItem.MouseY;

    with FOwner.GetDlgRect do begin
      Dec(X, Left + vGrid.Left);
      Dec(Y, Top + vGrid.Top);
    end;

    if vGrid.HitTest(X, Y, vCol, vRow) <> ghsCell then
      Exit;

    {!!!}
    vHist := TFldMenuDlg(FOwner).GetHistoryEntry(vRow) as TFldHistoryEntry;
    if vHist = nil then
      Exit;

    vStr := vHist.Path;
    if TFldMenuDlg(FOwner).DlgItemFlag(vRow) and 2 <> 0 then
      vStr := vHist.GetDomain;

    if vHist.GetMode = 1 then
      AItem.AddStringInfo(GetMsgStr(strHintPath), vStr)
    else
    if UpCompareSubStr('FTP:', vHist.Path) = 0 then begin
      vDomain := vHist.GetDomain;
      vStr := Copy(vStr, Length(vDomain) + 1, MaxInt);
      if (Length(vStr) > 2) and (vStr[Length(vStr)] = '/') then
        Delete(vStr, Length(vStr), 1);
      vDomain := ExtractWord(2, vDomain, [':', '/']);

      AItem.AddStringInfo(GetMsgStr(strHintFTP), vDomain);
      if vStr <> '' then
        AItem.AddStringInfo(GetMsgStr(strHintPath), vStr);
    end else
    begin
      vDomain := vHist.GetDomain;
      vStr := Copy(vStr, Length(vDomain) + 1, MaxInt);

      AItem.AddStringInfo(GetMsgStr(strHintPrefix), vDomain);
      if vStr <> '' then
        AItem.AddStringInfo(GetMsgStr(strHintPath), vStr);
    end;

    AItem.AddDateInfo(GetMsgStr(strHintLastVisited), vHist.Time);
    AItem.AddIntInfo(GetMsgStr(strHintVisitCount), vHist.Hits);

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


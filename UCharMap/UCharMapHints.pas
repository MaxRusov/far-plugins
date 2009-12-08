{$I Defines.inc}

unit UCharMapHints;

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
    MixUtils,
    MixStrings,
    MixClasses,

    PluginW,

    FarCtrl,
    FarDlg,
    FarGrid,
    FarHintsAPI,

    UCharMapCtrl;


  const
    cMaxFontSize  = 72;
    cMinFontSize  = 8;


  type
    THintPluginObject = class(TInterfacedObject, IEmbeddedHintPlugin, IHintPluginDraw, IHintPluginCommand)
    public
      constructor CreateEx(AOwner :TFarDialog);

      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

      {IHintPluginCommand}
      procedure RunCommand(const AItem :IFarItem; ACommand :Integer); stdcall;

      {IEmbeddedHintPlugin}
      procedure UnloadFarHints; stdcall;

    private
      FAPI       :IFarHintsApi;
      FOwner     :TFarDialog;

      FChar      :TString;

      FFont      :HFont;
      FSize      :Integer;

      procedure UpdateFontPreview(const AItem :IFarItem);
    end;


  procedure RegisterHints(AOwner :TFarDialog);
  procedure UnRegisterHints;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    UCharMapDlg,
    MixDebug;


  function TextSize(AFont :HFont; const AText :TWideStr) :TSize;
  var
    vDC :HDC;
    vOld :THandle;
  begin
    vDC := CreateCompatibleDC(0);
    vOld := SelectObject(vDC, AFont);
    try
      GetTextExtentPoint32(vDC, PWideChar(AText), Length(AText), Result);
    finally
      SelectObject(vDC, vOld);
      DeleteDC(vDC);
    end;
  end;


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
    ReadSetup;
  end;


  procedure THintPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function THintPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vWinInfo :TWindowInfo;
    vRect :TRect;
    vGrid :TFarGrid;
    X, Y, vCol, vRow, D :Integer;
    vCode :Integer;
    vStr :TString;
  begin
    Result := False;

    FarGetWindowInfo(-1, vWinInfo, @vStr, nil);
    if not (vWinInfo.WindowType in [WTYPE_DIALOG]) or (vStr <> GetMsgStr(strTitle)) then
      Exit;

    vGrid := (FOwner as TCharMapDlg).Grid;

    X := AItem.MouseX;
    Y := AItem.MouseY;

    with FOwner.GetDlgRect do begin
      Dec(X, Left + vGrid.Left);
      Dec(Y, Top + vGrid.Top);
    end;

    if (vGrid.HitTest(X, Y, vCol, vRow) <> ghsCell) or (vCol = 0) or (vCol > 16) then
      Exit;

    D := 0;
    if vGrid.CalcColByDelta(X - 1) = vCol then
      D := -1;

    vRect := Bounds(AItem.MouseX + D, AItem.MouseY, 3, 1);
    AItem.SetItemRect(vRect);

    vCode := Word(TCharMapDlg(FOwner).GetCharAt(vCol, vRow));

    vStr := NameOfChar(vCode);
    if vStr <> '' then
      AItem.AddStringInfo(GetMsgStr(strSymbol), vStr);

    vStr := NameOfRange(vCode);
    if vStr <> '' then
      AItem.AddStringInfo(GetMsgStr(strRange), vStr);

    AItem.AddStringInfo(GetMsgStr(strCode), Format('$%.4x (%d)', [vCode, vCode]));

    FChar := '';
    if TCharMapDlg(FOwner).CharMapped(TChar(vCode)) then
      FChar := TChar(vCode);

    FSize := FontSize;

    AItem.IconFlags := IF_Buffered or IF_HideSizeLabel;
    UpdateFontPreview(AItem);

    Result := True;
  end;


  procedure THintPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
    {}
  end;


  procedure THintPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
    if FFont <> 0 then begin
      DeleteObject(FFont);
      FFont := 0;
    end;
  end;


  procedure THintPluginObject.RunCommand(const AItem :IFarItem; ACommand :Integer); {stdcall;}
  var
    vNewSize :Integer;
  begin
    if ACommand = 0 then
      vNewSize := IntMin(FSize + 2, cMaxFontSize)
    else
      vNewSize := IntMax(FSize - 2, cMinFontSize);

    if FSize <> vNewSize then begin
      if FFont <> 0 then begin
        DeleteObject(FFont);
        FFont := 0;
      end;

      FSize := vNewSize;
      UpdateFontPreview(AItem);

      FontSize := FSize;
      AItem.UpdateHintWindow(uhwResize + uhwInvalidateItems + uhwInvalidateImage);
      WriteSetup;
    end;
  end;


  procedure THintPluginObject.UpdateFontPreview(const AItem :IFarItem);
  var
    vViewSize :TSize;
  begin
    FFont := 0;
    if FSize <> 0 then
      FFont := GetFont(FontName, FSize, DEFAULT_PITCH{FInfo.Pitch}, FW_Normal{FInfo.Weight}, False {FInfo.Italic});

    vViewSize := Size(0, 0);
    if (FChar <> '') and (FFont <> 0) then
      vViewSize := TextSize(FFont, FChar);

    if (vViewSize.cx > 0) and (vViewSize.cy > 0) then begin
      AItem.IconWidth := vViewSize.cx + 5;
      AItem.IconHeight := vViewSize.cy;
    end else
    begin
      AItem.IconWidth := 0;
      AItem.IconHeight := 0;
    end;
  end;


  procedure THintPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); {stdcall;}
  var
    vOld :THandle;
    vRect :TRect;
  begin
    vOld := SelectObject(ADC, FFont);
    vRect := ARect;
    SetBkMode(ADC, Transparent);
    DrawText(ADC, PTChar(FChar), Length(FChar), vRect, DT_NOPREFIX);
    SelectObject(ADC, vOld);
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


end.


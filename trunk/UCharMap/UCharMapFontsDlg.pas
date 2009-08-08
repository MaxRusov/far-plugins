{$I Defines.inc}

unit UCharMapFontsDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

    PluginW,
    FarKeysW,
    FarColor,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,

    UCharMapCtrl,
    UCharListBase;


  function OpenFontsDlg(var AName :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFontsDlg                                                                   }
 {-----------------------------------------------------------------------------}

  type
    TFontsDlg = class(TListBase)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitListControl; override;
      procedure ReinitAndSaveCurrent; override;

      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;

    private
      FResName   :TString;

      procedure GotoFont(const AName :TString);
      function FontNameToDlgIndex(const AName :TString) :Integer;
      function GetFont(ADlgIndex :Integer) :TString;
    end;



  procedure TFontsDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := 'FontList';
    FGrid.Columns.FreeAll;
//  FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 6, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 2) );
  end;


  procedure TFontsDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
    GotoFont(FResName);
  end;


  procedure TFontsDlg.SelectItem(ACode :Integer); {override;}
  begin
    if FGrid.RowCount > 0 then begin
      FResName := GetFont(FGrid.CurRow);
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;
  

  procedure TFontsDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strFonts);

    if FFilterMask = '' then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);
  end;


  procedure TFontsDlg.ReinitListControl; {override;}
  var
    I, vPos, vLen, vMaxLen :Integer;
    vName, vMask :TString;
    vHasMask :Boolean;
  begin
    FFilter.Clear;
    vMaxLen := 0;
    FTotalCount := 0;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    for I := 0 to FontNames.Count - 1 do begin
      vName := FontNames[I];

      Inc(FTotalCount);
      vPos := 0; vLen := 0;
      if vMask <> '' then
        if not CheckMask(vMask, vName, vHasMask, vPos, vLen) then
          Continue;

      FFilter.Add(I, vPos, vLen);
      vMaxLen := IntMax(vMaxLen, Length(vName));
    end;

    FMenuMaxWidth := vMaxLen + 9;

    FGrid.ResetSize;
    FGrid.RowCount := FFilter.Count;

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TFontsDlg.ReinitAndSaveCurrent;
  var
    vName :TString;
  begin
    vName := '';
    if (FGrid.CurRow >= 0) and (FGrid.CurRow < FGrid.RowCount) then
      vName := GetFont(FGrid.CurRow);
    ReinitListControl;
    GotoFont(vName);
  end;


  function TFontsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < FFilter.Count then
      Result := GetFont(ARow)
    else
      Result := '';
  end;


 {-----------------------------------------------------------------------------}

  procedure TFontsDlg.GotoFont(const AName :TString);
  var
    vIndex :Integer;
  begin
    vIndex := FontNameToDlgIndex(AName);
    if vIndex < 0 then
      vIndex := 0;
    SetCurrent( vIndex, lmCenter );
  end;


  function TFontsDlg.FontNameToDlgIndex(const AName :TString) :Integer;
  var
    I :Integer;
  begin
    Result := -1;
    for I := 0 to FFilter.Count - 1 do
      if GetFont(I) = AName then begin
        Result := I;
        Exit;
      end;
  end;


  function TFontsDlg.GetFont(ADlgIndex :Integer) :TString;
  begin
    Result := FontNames[FFilter[ADlgIndex]];
  end;



 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function OpenFontsDlg(var AName :TString) :Boolean;
  var
    vDlg :TFontsDlg;
  begin
    Result := False;
    vDlg := TFontsDlg.Create;
    try
      vDlg.FResName := AName;

      if vDlg.Run = -1 then
        Exit;

      AName  := vDlg.FResName;
      Result := True;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


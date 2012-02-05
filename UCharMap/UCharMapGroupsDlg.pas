{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{$I Defines.inc}

unit UCharMapGroupsDlg;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    Far_API,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,
    FarListDlg,

    UCharMapCtrl,
    UCharListBase;


  function OpenGroupsDlg(var AChar :TChar) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TGroupsDlg                                                                  }
 {-----------------------------------------------------------------------------}

  type
    TGroupsDlg = class(TListBase)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;

    private
      FResChr  :TChar;

      procedure GotoCode(ACode :Integer);
      function GetGroup(ADlgIndex :Integer) :TUnicodeGroup;
    end;


  procedure TGroupsDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := 'GroupsList';
    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 6, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 2) );
  end;


  procedure TGroupsDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
    GotoCode(Word(FResChr));
  end;


  procedure TGroupsDlg.SelectItem(ACode :Integer); {override;}
  begin
    if FGrid.RowCount > 0 then begin
      FResChr := TChar(GetGroup(FGrid.CurRow).Code1);
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TGroupsDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strGroups);

    if FFilterMask = '' then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);
  end;


  procedure TGroupsDlg.ReinitGrid; {override;}
  var
    I, vPos, vLen, vMaxLen :Integer;
    vMask :TString;
    vGroup :TUnicodeGroup;
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

    for I := 0 to GroupNames.Count - 1 do begin
      vGroup := GroupNames[I];

      Inc(FTotalCount);
      vPos := 0; vLen := 0;
      if vMask <> '' then
        if not CheckMask(vMask, vGroup.Name, vHasMask, vPos, vLen) then
          Continue;

      FFilter.Add(I, vPos, vLen);
      vMaxLen := IntMax(vMaxLen, Length(vGroup.Name));
    end;

    FMenuMaxWidth := vMaxLen + 9;

    FGrid.ResetSize;
    FGrid.RowCount := FFilter.Count;

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TGroupsDlg.ReinitAndSaveCurrent; {override;}
  var
    vCode, vIndex :Integer;
  begin
    vCode := 0;
    vIndex := FGrid.CurRow;
    if (vIndex >= 0) and (vIndex < FGrid.RowCount) then
      vCode := GetGroup(vIndex).Code1;
    ReinitGrid;
    GotoCode( vCode );
  end;


  function TGroupsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < FFilter.Count then begin
      with GetGroup(ARow) do
        case FGrid.Column[ACol].Tag of
          1 : Result := Format('%.4x', [Code1]);
          2 : Result := Name;
        end;
    end else
      Result := '';
  end;


 {-----------------------------------------------------------------------------}

  procedure TGroupsDlg.GotoCode(ACode :Integer);
  var
    vIndex :Integer;
  begin
    vIndex := 0;
    while (vIndex < FFilter.Count - 1) and (GetGroup(vIndex + 1).Code1 <= ACode) do
      Inc(vIndex);
    SetCurrent( vIndex, lmCenter );
  end;


  function TGroupsDlg.GetGroup(ADlgIndex :Integer) :TUnicodeGroup;
  begin
    Result := GroupNames[FFilter[ADlgIndex]];
  end;

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function OpenGroupsDlg(var AChar :TChar) :Boolean;
  var
    vDlg :TGroupsDlg;
  begin
    Result := False;
    vDlg := TGroupsDlg.Create;
    try
      vDlg.FGUID := cGroupDlgID;
      vDlg.FResChr := AChar;

      if vDlg.Run = -1 then
        Exit;

      AChar  := vDlg.FResChr;
      Result := True;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


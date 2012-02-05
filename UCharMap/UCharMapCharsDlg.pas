{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{$I Defines.inc}

unit UCharMapCharsDlg;

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


  type
    TCharsDlg = class(TListBase)
    public
      function GetCode(ADlgIndex :Integer) :Integer;

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
    end;


  function OpenCharsDlg(var AChar :TChar) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TGroupsDlg                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TCharsDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := 'CharsList';
    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 6, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 3, taLeftJustify, [coColMargin], 2) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 3) );
  end;


  procedure TCharsDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
    GotoCode(Word(FResChr));
  end;


  procedure TCharsDlg.SelectItem(ACode :Integer); {override;}
  var
    vCode :Integer;
  begin
    vCode := GetCode(FGrid.CurRow);
    if vCode >= 0 then begin
      FResChr := TChar(vCode);
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TCharsDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    {!!!Localize}
    vTitle := 'Chars' {GetMsgStr(strGroups)};

    if FFilterMask = '' then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);
  end;


  procedure TCharsDlg.ReinitGrid; {override;}
  var
    I, vPos, vLen, vMaxLen :Integer;
    vMask :TString;
    vName :PTString;
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

    for I := 0 to CharNames.Count - 1 do begin
      vName := CharNames.PStrings[I];
      if vName^ = '' then
        Continue;

      Inc(FTotalCount);
      vPos := 0; vLen := 0;
      if vMask <> '' then
        if not CheckMask(vMask, vName^, vHasMask, vPos, vLen) then
          Continue;

      FFilter.Add(I, vPos, vLen);
      vMaxLen := IntMax(vMaxLen, Length(vName^));
    end;

    FMenuMaxWidth := vMaxLen + 13;

    FGrid.ResetSize;
    FGrid.RowCount := FFilter.Count;

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TCharsDlg.ReinitAndSaveCurrent; {override;}
  var
    vCode :Integer;
  begin
    vCode := GetCode(FGrid.CurRow);
    ReinitGrid;
    if vCode <> -1 then
      GotoCode( vCode );
  end;


  function TCharsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vCode :Integer;
  begin
    vCode := GetCode(ARow);
    if vCode <> -1 then begin
      case FGrid.Column[ACol].Tag of
        1 : Result := Format('%.4x', [vCode]);
        2 : Result := TChar(vCode);
        3 : Result := NameOfChar(vCode);
      end;
    end else
      Result := '';
  end;


 {-----------------------------------------------------------------------------}

  procedure TCharsDlg.GotoCode(ACode :Integer);
  var
    I, vIndex :Integer;
  begin
    vIndex := 0;
    for I := 0 to FFilter.Count - 1 do
      if FFilter[I] = ACode then begin
        vIndex := I;
        Break;
      end;
    SetCurrent( vIndex, lmCenter );
  end;


  function TCharsDlg.GetCode(ADlgIndex :Integer) :Integer;
  begin
    Result := -1;
    if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then
      Result := FFilter[ADlgIndex];
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function OpenCharsDlg(var AChar :TChar) :Boolean;
  var
    vDlg :TCharsDlg;
    vOld :TFarDialog;
  begin
    Result := False;

    vOld := TopDlg;
    vDlg := TCharsDlg.Create;
    try
      TopDlg := vDlg;
      vDlg.FGUID := cCharDlgID;
      vDlg.FResChr := AChar;

      if vDlg.Run = -1 then
        Exit;

      AChar  := vDlg.FResChr;
      Result := True;

    finally
      TopDlg := vOld;
      FreeObj(vDlg);
    end;
  end;


end.


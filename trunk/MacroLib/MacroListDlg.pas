{$I Defines.inc}

unit MacroListDlg;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* MacroLib                                                                   *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,
    MixStrings,

    PluginW,
    FarKeysW,
    FarColor,

    FarCtrl,
    FarDlg,
    FarGrid,
    FarMatch,
    FarListDlg,

    MacroLibConst,
    MacroLibClasses;


  type
    TMacroList = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReInitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); override;

    protected
      FMacroses    :TExList;

      FResInd      :Integer;
      FResCmd      :Integer;

      function GetMacro(ARow :Integer) :TMacro;
      function FindMacro(AMacro :TMacro) :Integer;
    end;


  function ListMacrosesDlg(AMacroses :TExList; var AIndex :Integer) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TMacroList                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TMacroList.Create; {override;}
  begin
    inherited Create;
    FDrawBuf := TDrawBuf.Create;
  end;


  destructor TMacroList.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  procedure TMacroList.Prepare; {override;}
  begin
    inherited Prepare;
//  FHelpTopic := 'List';
    FGrid.Options := [goRowSelect, goWrapMode, goFollowMouse];
  end;


  procedure TMacroList.InitDialog; {override;}
  begin
    inherited InitDialog;
    if FResInd <> -1 then
      SetCurrent(FResInd);
  end;


  procedure TMacroList.UpdateHeader; {override;}
  var
    vTitle :TString;
  begin
    vTitle := GetMsg(strMacrosesTitle);

    if FFilter = nil then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);
    SetText(IdFrame, vTitle);

    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;
  end;


  procedure TMacroList.ReInitGrid; {virtual;}
  var
    I, vCount, vPos, vFndLen, vMaxLen1, vMaxLen2, vMaxLen3, vMaxLen4, vMaxLen5 :Integer;
    vMacro :TMacro;
    vMask, vXMask :TString;
    vHasMask :Boolean;
  begin
    FTotalCount := FMacroses.Count;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    vCount := 0;
    FreeObj(FFilter);
    if vMask <> '' then begin
      FFilter := TListFilter.Create;
      if optXLatMask then
        vXMask := FarXLatStr(vMask);
    end;

    vMaxLen1 := 2; vMaxLen2 := 2; vMaxLen3 := 2; vMaxLen4 := 2; vMaxLen5 := 2;

    for I := 0 to FMacroses.Count - 1 do begin
      vMacro := FMacroses[I];

      vPos := 0; vFndLen := 0;
      if vMask <> '' then begin
        {!!!}
        if not ChrCheckXMask(vMask, vXMask, PTChar(vMacro.Descr), vHasMask, vPos, vFndLen) then
          Continue;

        FFilter.Add(I, vPos, vFndLen);
      end;

      vMaxLen1 := IntMax(vMaxLen1, Length(vMacro.Name));
      vMaxLen2 := IntMax(vMaxLen2, Length(vMacro.Descr));
      vMaxLen3 := IntMax(vMaxLen3, Length(vMacro.BindStr));
      vMaxLen4 := IntMax(vMaxLen4, Length(vMacro.AreaStr));
      vMaxLen5 := IntMax(vMaxLen5, Length(ExtractFileName(vMacro.FileName)));

      Inc(vCount);
    end;

    FGrid.ResetSize;

    FGrid.Columns.FreeAll;
//  if optShowName then
//    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen1+2, taLeftJustify, [coColMargin{, coOwnerDraw}], 0) );
//  if optShowDescr then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen2+2, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    if optShowBind then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen3+2, taLeftJustify, [coColMargin{, coOwnerDraw}], 2) );
    if optShowArea then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen4+2, taLeftJustify, [coColMargin{, coOwnerDraw}], 3) );
    if optShowFile then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen5+2, taLeftJustify, [coColMargin{, coOwnerDraw}], 4) );

    FMenuMaxWidth := 0;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
    Dec(FMenuMaxWidth);

    FGrid.RowCount := vCount;

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TMacroList.ReinitAndSaveCurrent; {override;}
  var
    vMacro :TMacro;
  begin
    vMacro := GetMacro(FGrid.CurRow);
    ReinitGrid;
    if vMacro <> nil then
      SetCurrent(FindMacro(vMacro), lmCenter);
  end;


  function TMacroList.GetMacro(ARow :Integer) :TMacro;
  var
    vIdx :Integer;
  begin
    Result := nil;
    vIdx := RowToIdx(ARow);
    if (vIdx >= 0) and (vIdx < FMacroses.Count) then
      Result := FMacroses[vIdx];
  end;


  function TMacroList.FindMacro(AMacro :TMacro) :Integer;
  var
    I :Integer;
  begin
    for I := 0 to FGrid.RowCount - 1 do
      if GetMacro(I) = AMacro then begin
        Result := I;
        Exit;
      end;
    Result := -1;
  end;


  function TMacroList.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vMacro :TMacro;
  begin
    Result := '';
    vMacro := GetMacro(ARow);
    if vMacro <> nil then begin
      case FGrid.Column[ACol].Tag of
        0: Result := vMacro.Name;
        1: Result := vMacro.Descr;
        2: Result := vMacro.BindStr;
        3: Result := vMacro.AreaStr;
        4: Result := ExtractFileName(vMacro.FileName);
      end;
    end;
  end;


  procedure TMacroList.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {override;}
  var
    vMacro :TMacro;
    vRec :PFilterRec;
  begin
    vMacro := GetMacro(ARow);
    if vMacro <> nil then begin
      FDrawBuf.Clear;

      FDrawBuf.AddStrExpandTabsEx(PTChar(vMacro.Descr), length(vMacro.Descr), AColor);

      if FFilter <> nil then begin
        vRec := PFilterRec(FFilter.PItems[ARow]);
        FDrawBuf.FillLoAttr(vRec.FPos, vRec.FLen, optFoundColor);
      end;

      FDrawBuf.Paint(X, Y, 0, AWidth);
    end;
  end;


  procedure TMacroList.SelectItem(ACode :Integer); {override;}
  begin
    if FGrid.CurRow < FGrid.RowCount then begin
      FResInd := RowToIdx(FGrid.CurRow);
      FResCmd := ACode;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  function TMacroList.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocToggleOption(var AOption :Boolean);
    begin
      ToggleOption( AOption );
      ReInitGrid;
    end;

  begin
    Result := 1;
    case Msg of
      DN_KEY: begin
        case Param2 of
          KEY_ENTER:
            SelectItem(1);
          KEY_F4:
            SelectItem(2);

          KEY_CTRL2:
            LocToggleOption(optShowBind);
          KEY_CTRL3:
            LocToggleOption(optShowArea);
          KEY_CTRL4:
            LocToggleOption(optShowFile);

        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure EditMacro(AMacro :TMacro);
  begin
    OpenEditor(AMacro.FileName, AMacro.Row + 1, AMacro.Col + 1);
  end;


  function ListMacrosesDlg(AMacroses :TExList; var AIndex :Integer) :Boolean;
  var
    vDlg :TMacroList;
  begin
    Result := False;
    vDlg := TMacroList.Create;
    try
      vDlg.FMacroses := AMacroses;
      vDlg.FResInd   := AIndex;

      if vDlg.Run = -1 then
        Exit;

      AIndex := vDlg.FResInd;
      Result := vDlg.FResCmd = 1;

      case vDlg.FResCmd of
        1: {};
        2: EditMacro(AMacroses[AIndex]);
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


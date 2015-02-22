{$I Defines.inc}

unit MacroListDlg;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Macro Library                                                          *}
{* Диалог - список макросов                                                   *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarMatch,
    FarMenu,
    FarListDlg,
    FarColorDlg,

    MacroLibConst,
    MacroLibClasses;



  type
    TMacroList = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetMacro(ARow :Integer) :TMacro;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      procedure GridTitleClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

      function ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; override;

    protected
      FMacroses    :TExList;

      FResInd      :Integer;
      FResCmd      :Integer;

      procedure UpdateMacroses;
      procedure EditCurrent;

      procedure SetOrder(AOrder :Integer);
      function GetColumStr(AMacro :TMacro; AColTag :Integer) :TString;
      function FindMacro(AMacro :TMacro) :Integer;
      function FindMacroByLink(const ALink :TString) :Integer;
    end;


  var
    LastRevision :Integer;
    LastLink     :TString;

    MacroLock    :Integer;

  procedure OptionsMenu;
  
  function ListMacrosesDlg(AMacroses :TExList; var AIndex :Integer) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MacroLibHints,
    MixDebug;


 {-----------------------------------------------------------------------------}

  procedure ColorMenu;
  var
    vMenu :TFarMenu;
    vBkColor :DWORD;
    vOk, vChanged :Boolean;
  begin
    vBkColor := GetColorBG(FarGetColor(COL_MENUTEXT));

    vMenu := TFarMenu.CreateEx(
      GetMsg(strColorsTitle),
    [
      GetMsg(strMHiddenColor),
      GetMsg(strMQuickFilter),
      GetMsg(strMColumnTitle),
      '',
      GetMsg(strMRestoreDefaults)
    ]);
    try
      vChanged := False;

      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0: vOk := ColorDlg('', optHiddenColor, vBkColor);
          1: vOk := ColorDlg('', optFoundColor, vBkColor);
          2: vOk := ColorDlg('', optTitleColor);
        else
          RestoreDefColor;
          vOk := True;
        end;

        if vOk then begin
          FarAdvControl(ACTL_REDRAWALL, nil);
          vChanged := True;
        end;
      end;

      if vChanged then
        PluginConfig(True);

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMProcessHotkeys),
      GetMsg(strMProcessMouse),
      GetMsg(strMExtendMacroKey),
      GetMsg(strMMacroPaths),
     {$ifdef bUseInject}
      GetMsg(strMUseInjecting),
     {$endif bUseInject}
      '',
      GetMsg(strMColors)
    ]);
    try
      vMenu.Help := 'Options';

      while True do begin
        vMenu.Checked[0] := optProcessHotkey;
        vMenu.Checked[1] := optProcessMouse;
        vMenu.Checked[2] := optExtendFarKey;
       {$ifdef bUseInject}
        vMenu.Checked[4] := optUseInject;
       {$endif bUseInject}
        vMenu.Enabled[3] := MacroLock = 0;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOption(optProcessHotkey);
          1 : ToggleOption(optProcessMouse);
          2 :
            begin
              ToggleOption(optExtendFarKey);
              MacroLibrary.Reindex;
            end;
          3 :
            if FarInputBox(GetMsg(strMacroPathsTitle), GetMsg(strMacroPathsPrompt), optMacroPaths, FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY, cMacroPathName) then begin
              PluginConfig(True);
              MacroLibrary.RescanMacroses(True);
            end;
         {$ifdef bUseInject}
          4 : ToggleOption(optUseInject);
         {$endif bUseInject}

          6 : ColorMenu;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TMacroList                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TMacroList.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FFilter := TListFilter.Create;
    FFilter.Owner := Self;
  end;


  destructor TMacroList.Destroy; {override;}
  begin
    UnRegisterHints;
    inherited Destroy;
  end;


  procedure TMacroList.Prepare; {override;}
  begin
    inherited Prepare;
    FGUID := cMacroListDlgID;
    FHelpTopic := 'List';
    FGrid.OnTitleClick := GridTitleClick;    
    FGrid.Options := [{goRowSelect,} goWrapMode {, goFollowMouse}];
  end;


  procedure TMacroList.InitDialog; {override;}
  begin
    inherited InitDialog;

    if (FResInd = -1) and (LastLink <> '') then
      FResInd := FindMacroByLink(LastLink);

    if FResInd <> -1 then
      SetCurrent(FResInd);
  end;


  procedure TMacroList.UpdateHeader; {override;}
  var
    vTitle :TString;
  begin
    vTitle := GetMsg(strMacrosesTitle);

    if FFilterMask = '' then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);
    SetText(IdFrame, vTitle);

    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;
  end;


  function TMacroList.GetColumStr(AMacro :TMacro; AColTag :Integer) :TString;
  begin
    case AColTag of
      0: Result := AMacro.Name;
      1: Result := AMacro.Descr;
      2: Result := AMacro.GetBindAsStr(optShowBind);
      3: Result := AMacro.GetAreaAsStr(optShowArea);
      4: Result := AMacro.GetFileTitle(optShowFile);
    end;
  end;


  function TMacroList.ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; {override;}
  var
    vMacro1, vMacro2 :TMacro;
  begin
    vMacro1 := FMacroses[AIndex1];
    vMacro2 := FMacroses[AIndex2];

    Result := 0;
    case Abs(Context) of
      1: Result := UpCompareStr(vMacro1.Descr, vMacro2.Descr);
      2: Result := UpCompareStr(vMacro1.GetBindAsStr(optShowBind), vMacro2.GetBindAsStr(optShowBind));
      3: Result := UpCompareStr(vMacro1.GetAreaAsStr(optShowArea), vMacro2.GetAreaAsStr(optShowArea));
      4: Result := UpCompareStr(vMacro1.GetFileTitle(optShowFile), vMacro2.GetFileTitle(optShowFile));
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(AIndex1, AIndex2);
  end;


  procedure TMacroList.ReInitGrid; {virtual;}
  var
    I, vCount, vPos, vFndLen, vMaxLen1, vMaxLen2, vMaxLen3, vMaxLen4, vMaxLen5 :Integer;
    vMacro :TMacro;
    vStr, vMask, vXMask :TString;
    vHasMask :Boolean;
  begin
//  FTotalCount := FMacroses.Count;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin

      if (FFilterColumn = 3) and (optShowArea = 2) and (vMask[1] <> '*') then
        { Фильтрация по областям в виде флагов - всегда по вхождению }
        vMask := '*' + vMask;

      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    vCount := 0;
    FFilter.Clear;
    if vMask <> '' then begin
      if optXLatMask then
        vXMask := FarXLatStr(vMask);
    end;

    vMaxLen1 := 2;
    vMaxLen2 := length(GetMsgStr(strDescription));
    vMaxLen3 := length(GetMsgStr(strKeys));
    vMaxLen4 := length(GetMsgStr(strAreas));
    vMaxLen5 := length(GetMsgStr(strFileName));

    FTotalCount := 0;
    for I := 0 to FMacroses.Count - 1 do begin
      vMacro := FMacroses[I];

      if not optShowHidden and vMacro.Hidden then
        Continue;

      Inc(FTotalCount);

      vPos := 0; vFndLen := 0;
      if vMask <> '' then begin
        vStr := GetColumStr(vMacro, FFilterColumn);
        if not ChrCheckXMask(vMask, vXMask, PTChar(vStr), vHasMask, vPos, vFndLen) then
          Continue;
      end;

      FFilter.Add(I, vPos, vFndLen);

      vMaxLen1 := IntMax(vMaxLen1, Length(vMacro.Name));
      vMaxLen2 := IntMax(vMaxLen2, Length(vMacro.Descr));
      if optShowBind > 0 then
        vMaxLen3 := IntMax(vMaxLen3, Length(vMacro.GetBindAsStr(optShowBind)));
      if optShowArea > 0 then
        vMaxLen4 := IntMax(vMaxLen4, Length(vMacro.GetAreaAsStr(optShowArea)));
      if optShowFile > 0 then
        vMaxLen5 := IntMax(vMaxLen5, Length(vMacro.GetFileTitle(optShowFile)));

      Inc(vCount);
    end;

    if optSortMode <> 0 then
      FFilter.SortList(True, optSortMode);

    FGrid.ResetSize;

    FGrid.Columns.FreeAll;
//  if optShowName then
//    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen1+2, taLeftJustify, [coColMargin{, coOwnerDraw}], 0) );
    if True {optShowDescr} then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strDescription), vMaxLen2+2, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    if optShowBind > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strKeys), vMaxLen3+2, taLeftJustify, [coColMargin, coOwnerDraw], 2) );
    if optShowArea > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strAreas), vMaxLen4+2, taLeftJustify, [coColMargin, coOwnerDraw], 3) );
    if optShowFile > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strFileName), vMaxLen5+2, taLeftJustify, [coColMargin, coOwnerDraw], 4) );

    FGrid.Column[0].MinWidth := IntMin(vMaxLen2, 15);
    for I := 1 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        MinWidth := IntMin(Width, 6);

    FGrid.ReduceColumns(FarGetWindowSize.CX - (10 + FGrid.Columns.Count));

    if optShowTitles then
      FGrid.Options := FGrid.Options + [goShowTitle]
    else
      FGrid.Options := FGrid.Options - [goShowTitle];
    FGrid.TitleColor  := GetOptColor(optTitleColor, COL_MENUHIGHLIGHT);

    FMenuMaxWidth := 0;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then begin
          if optShowTitles and (Abs(optSortMode) = Tag) then
            Header := StrIf(optSortMode > 0, chrUpMark, chrDnMark) + Header;
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
        end;
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


  function TMacroList.FindMacroByLink(const ALink :TString) :Integer;
  var
    I :Integer;
  begin
    for I := 0 to FGrid.RowCount - 1 do
      if GetMacro(I).GetSrcLink = ALink then begin
        Result := I;
        Exit;
      end;
    Result := -1;
  end;


  procedure TMacroList.GridTitleClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  var
    vTag :Integer;
  begin
    if AButton = 1 then begin
      if ACol < FGrid.Columns.Count then begin
        vTag := FGrid.Column[ACol].Tag;
//      if vTag in cDescSort then
//        vTag := -vTag;
        SetOrder(vTag);
      end;  
    end else
      Beep;
  end;


  function TMacroList.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vMacro :TMacro;
  begin
    Result := '';
    vMacro := GetMacro(ARow);
    if vMacro <> nil then
      Result := GetColumStr(vMacro, FGrid.Column[ACol].Tag);
  end;


  procedure TMacroList.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
  var
    vMacro :TMacro;
  begin
    if ARow < FFilter.Count then begin
      vMacro := GetMacro(ARow);

      if ACol = -1 then begin
        AColor := FGrid.NormColor;
        if (FGrid.CurRow = ARow) and (FGrid.CurCol = 0) then
          AColor := FGrid.SelColor;
      end else
      begin
        if optShowHidden and vMacro.Hidden then
          AColor := ChangeFG(AColor, optHiddenColor);
      end;
    end;
  end;


  procedure TMacroList.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vMacro :TMacro;
    vTag :Integer;
    vStr :TString;
    vRec :PFilterRec;
  begin
    vMacro := GetMacro(ARow);
    if vMacro <> nil then begin

      vTag := FGrid.Column[ACol].Tag;
      vStr := GetColumStr(vMacro, vTag);

      vRec := nil;
      if (FFilterMask <> '') and (FFilterColumn = vTag) then
        vRec := PFilterRec(FFilter.PItems[ARow]);

      if vRec <> nil then
        FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(AColor, optFoundColor))
      else
        FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
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


 {-----------------------------------------------------------------------------}

  procedure TMacroList.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optSortMode then
      optSortMode := AOrder
    else
      optSortMode := -AOrder;

//  LocReinitAndSaveCurrent;
    ReinitGrid;
    PluginConfig(True);
  end;


 {-----------------------------------------------------------------------------}

  procedure TMacroList.UpdateMacroses;
  var
    vMacro :TMacro;
    vIndex :Integer;
  begin
    if FMacroses <> MacroLibrary.AllMacroses then
      begin Beep; Exit; end;

    LastRevision := MacroLibrary.Revision;
    LastLink := '';

    vMacro := GetMacro(FGrid.CurRow);
    if vMacro <> nil then
      LastLink := vMacro.GetSrcLink;

    MacroLibrary.RescanMacroses(True);

    if LastRevision <> MacroLibrary.Revision then begin
      FMacroses := MacroLibrary.AllMacroses;
      ReinitGrid;

      vIndex := -1;
      if LastLink <> '' then
        vIndex := FindMacroByLink(LastLink);
      if vIndex <> -1 then begin
        SetCurrent(vIndex, lmCenter);

        LastRevision := MacroLibrary.Revision;
        LastLink := GetMacro(vIndex).GetSrcLink;
      end;
    end;
  end;


  procedure TMacroList.EditCurrent;
  var
    vMacro :TMacro;
    vSave :THandle;
    vFull :Boolean;
    vIndex :Integer;
  begin
    vMacro := GetMacro(FGrid.CurRow);
    if vMacro = nil then
      begin beep; exit; end;

    { Глючит, если в процессе просмотра/редактирования файла изменить размер консоли...}
    SendMsg(DM_ShowDialog, 0, 0);
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    vFull := FMacroses = MacroLibrary.AllMacroses;
    if vFull then
      Dec(MacroLock);
    try
      LastRevision := MacroLibrary.Revision;
      LastLink := vMacro.GetSrcLink;

      FarEditOrView(vMacro.FileName, True, 0, vMacro.Row + 1, vMacro.Col + 1);

      if LastRevision <> MacroLibrary.Revision then begin
        FMacroses := MacroLibrary.AllMacroses;
        ReinitGrid;

        vIndex := -1;
        if LastLink <> '' then
          vIndex := FindMacroByLink(LastLink);
        if vIndex <> -1 then
          SetCurrent(vIndex, lmCenter);
      end;

    finally
      if vFull then
        Inc(MacroLock);
      FARAPI.RestoreScreen(vSave);
      SendMsg(DM_ShowDialog, 1, 0);
    end;
  end;


  function TMacroList.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocToggleOption(var AOption :Boolean);
    begin
      ToggleOption( AOption );
      ReInitGrid;
    end;

    procedure LocToggleOptionInt(var AOption :Integer; ANewValue :Integer);
    begin
      AOption  := ANewValue;
      PluginConfig(True);
      ReInitGrid;
    end;

  begin
    Result := True;
    case AKey of
      KEY_ENTER:
        SelectItem(1);
      KEY_CTRLPGDN:
        SelectItem(2);

      KEY_F4:
        SelectItem(3);
      KEY_ALTF4:
        EditCurrent;
      KEY_F5:
        UpdateMacroses;

      KEY_CTRLH:
        LocToggleOption(optSHowHidden);

      KEY_CTRL2:
        LocToggleOptionInt(optShowBind, IntIf(optShowBind < 2, optShowBind + 1, 0));
      KEY_CTRL3:
        LocToggleOptionInt(optShowArea, IntIf(optShowArea < 2, optShowArea + 1, 0));
      KEY_CTRL4:
        LocToggleOptionInt(optShowFile, IntIf(optShowFile < 2, optShowFile + 1, 0));

      KEY_CTRLF1, KEY_CTRLSHIFTF1:
        SetOrder(1);
      KEY_CTRLF2, KEY_CTRLSHIFTF2:
        SetOrder(2);
      KEY_CTRLF3, KEY_CTRLSHIFTF3:
        SetOrder(3);
      KEY_CTRLF4, KEY_CTRLSHIFTF4:
        SetOrder(4);
      KEY_CTRLF11:
        SetOrder(0);
//    KEY_CTRLF12:
//      SortByDlg;
      KEY_ALTF12:
        SetOrder(FGrid.CurCol + 1);

      KEY_ShiftF9:
        OptionsMenu;

    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TMacroList.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        begin
          ReinitAndSaveCurrent;
//        SetCurrent(FGrid.CurRow);
        end;
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure GotoFile(Active :Boolean; const AFileName :TString);
  begin
    FarPanelSetDir(Active, RemoveBackSlash(ExtractFilePath(AFileName)));
    FarPanelSetCurrentItem(Active, ExtractFileName(AFileName))
  end;


  procedure EditMacro(AMacro :TMacro);
  begin
    OpenEditor(AMacro.FileName, AMacro.Row + 1, AMacro.Col + 1);
  end;


  function ListMacrosesDlg(AMacroses :TExList; var AIndex :Integer) :Boolean;
  var
    vDlg :TMacroList;
    vMacro :TMacro;
  begin
    Result := False;
    if MacroLock > 0 then
      Exit;

    Inc(MacroLock);
    vDlg := TMacroList.Create;
    try
      vDlg.FMacroses := AMacroses;
      vDlg.FResInd   := AIndex;

      if vDlg.Run = -1 then
        Exit;

      AIndex := vDlg.FResInd;

      if (AIndex >= 0) and (AIndex < vDlg.FMacroses.Count) then begin
        vMacro := vDlg.FMacroses[AIndex];

        LastRevision := MacroLibrary.Revision;
        LastLink := vMacro.GetSrcLink;

        case vDlg.FResCmd of
          1: Result := True;
          2: GotoFile(True, vMacro.FileName);
          3: EditMacro(vMacro);
        end;
      end;

    finally
      FreeObj(vDlg);
      Dec(MacroLock);
    end;
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


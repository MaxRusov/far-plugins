{$I Defines.inc}

unit GitShellHistory;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,

    Far_API,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,
    FarMenu,
    FarDraw,
    FarListDlg,

    GitShellClasses,
    GitShellCtrl;


  type
    THistDlg = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      procedure GridPosChange(ASender :TFarGrid); override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FRepo      :TGitRepository;
      FHistory   :TExList;

      procedure ShowInfo;
      procedure ShowDiff(AFull :Boolean);
      procedure ShowDiffWith;
      procedure CheckoutCurrent;
      function GetColumStr(ACommit :TGitCommit; AColTag :Integer) :TString;
      function FindSelItem(AItem :TGitCommit) :Integer;
      function GetCommit(ARow :Integer) :TGitCommit;
//    procedure ToggleOption(var AOption :Boolean);
      procedure OptionsMenu;
      procedure SetOrder(AOrder :Integer);
      procedure SortByDlg;

    public
      property Grid :TFarGrid read FGrid;
    end;


//  function HistDlg(ARepo :TGitRepository; AHistory :TExList) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { THistDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor THistDlg.Create; {override;}
  begin
    inherited Create;
//  RegisterHints(Self);
    FFilter := TListFilter.Create;
    FFilter.Owner := Self;
  end;


  destructor THistDlg.Destroy; {override;}
  begin
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure THistDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FGUID := cHistDlgID;
    FHelpTopic := 'History';
//  FGrid.OnTitleClick := GridTitleClick;
    FGrid.Options := [{goRowSelect,} goWrapMode {, goFollowMouse}];
  end;


  procedure THistDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
  end;


  procedure THistDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strHistoryTitle);

    if FFilter = nil then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);

    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;
  end;


  function THistDlg.GetColumStr(ACommit :TGitCommit; AColTag :Integer) :TString;
  begin
    case AColTag of
      1: Result := CommitDateToStr(ACommit.Date, optShowDate = 2);
      2: Result := ACommit.Message1;
      3: Result := ACommit.Author;
      4: Result := ACommit.EMail;
      5: Result := ACommit.IDStr;
//    5: Result := Int2Str(ACommit.Parents);
    end;
  end;


  function THistDlg.ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; {override;}
  var
    vCommit1, vCommit2 :TGitCommit;
  begin
    vCommit1 := FHistory[AIndex1];
    vCommit2 := FHistory[AIndex2];

    Result := 0;
    case Abs(Context) of
      1: Result := DateTimeCompare(vCommit1.Date, vCommit2.Date);
      2: Result := UpCompareStr(vCommit1.Message1, vCommit2.Message1);
      3: Result := UpCompareStr(vCommit1.Author, vCommit2.Author);
      4: Result := UpCompareStr(vCommit1.EMail, vCommit2.EMail);
      5: Result := UpCompareStr(vCommit1.IDStr, vCommit2.IDStr);
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(AIndex1, AIndex2);
  end;



  procedure THistDlg.ReInitGrid; {virtual;}
  var
    I, vCount, vPos, vFndLen, vMaxLen1, vMaxLen2, vMaxLen3, vMaxLen4, vMaxLen5 :Integer;
    vCommit :TGitCommit;
    vStr, vMask, vXMask :TString;
    vHasMask :Boolean;
  begin
    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
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

    vMaxLen1 := length(GetMsgStr(strDate));
    vMaxLen2 := length(GetMsgStr(strMessage));
    vMaxLen3 := length(GetMsgStr(strAuthor));
    vMaxLen4 := length(GetMsgStr(strEmail));
    vMaxLen5 := length(GetMsgStr(strID));

    FTotalCount := 0;

    if FFilterColumn = 1 then
      FFilterColumn := 2;
    for I := 0 to FHistory.Count - 1 do begin
      vCommit := FHistory[I];

//    if not optShowHidden and vCommit.Hidden then
//      Continue;

      Inc(FTotalCount);

      vPos := 0; vFndLen := 0;
      if vMask <> '' then begin
        vStr := GetColumStr(vCommit, FFilterColumn);
        if not ChrCheckXMask(vMask, vXMask, PTChar(vStr), vHasMask, vPos, vFndLen) then
          Continue;
      end;

      FFilter.Add(I, vPos, vFndLen);

      if optShowDate > 0 then
        vMaxLen1 := IntMax(vMaxLen1, Length(CommitDateToStr(vCommit.Date, optShowDate = 2)));
      if optShowMessage > 0 then
        vMaxLen2 := IntMax(vMaxLen2, Length(vCommit.Message1));
      if optShowAuthor > 0 then
        vMaxLen3 := IntMax(vMaxLen3, Length(vCommit.Author));
      if optShowEmail > 0 then
        vMaxLen4 := IntMax(vMaxLen4, Length(vCommit.EMail));
      if optShowID > 0 then
        vMaxLen5 := IntMax(vMaxLen5, Length(vCommit.IDStr));

      Inc(vCount);
    end;

    if optHistSortMode <> 0 then
      FFilter.SortList(True, optHistSortMode);

    FGrid.ResetSize;

    FGrid.Columns.FreeAll;
    if optShowDate > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strDate), vMaxLen1+2, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    if optShowMessage > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strMessage), vMaxLen2+2, taLeftJustify, [coColMargin, coOwnerDraw], 2) );
    if optShowAuthor > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strAuthor), vMaxLen3+2, taLeftJustify, [coColMargin, coOwnerDraw], 3) );
    if optShowEmail > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strEMail), vMaxLen4+2, taLeftJustify, [coColMargin, coOwnerDraw], 4) );
    if optShowID > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strID), vMaxLen5+2, taLeftJustify, [coColMargin, coOwnerDraw], 5) );

//  FGrid.Column[0].MinWidth := IntMin(vMaxLen2, 15);
    for I := 0 to FGrid.Columns.Count - 1 do
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
          if optShowTitles and (Abs(optHistSortMode) = Tag) then
            Header := StrIf(optHistSortMode > 0, chrUpMark, chrDnMark) + Header;
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
        end;
    Dec(FMenuMaxWidth);

    FGrid.RowCount := vCount;

    UpdateHeader;
    ResizeDialog;
  end;



  procedure THistDlg.ReinitAndSaveCurrent; {override;}
  var
    vSel :TGitCommit;
  begin
    vSel := GetCommit(FGrid.CurRow);
    ReinitGrid;
    if vSel <> nil then
      SetCurrent(FindSelItem(vSel), lmCenter);
  end;


  procedure THistDlg.GridPosChange(ASender :TFarGrid); {override;}
  begin
    {}
  end;


  function THistDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vCommit :TGitCommit;
  begin
    Result := '';
    vCommit := GetCommit(ARow);
    if vCommit <> nil then
      Result := GetColumStr(vCommit, FGrid.Column[ACol].Tag);
  end;


  procedure THistDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
//var
//  vCommit :TGitCommit;
  begin
    if ARow < FFilter.Count then begin
//    vCommit := GetCommit(ARow);

      if ACol = -1 then begin
        AColor := FGrid.NormColor;
        if (FGrid.CurRow = ARow) and (FGrid.CurCol = 0) then
          AColor := FGrid.SelColor;
      end else
      begin
//      if optShowHidden and vCommit.Hidden then
//        AColor := ChangeFG(AColor, optHiddenColor);
      end;
    end;
  end;


  procedure THistDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vCommit :TGitCommit;
    vTag :Integer;
    vStr :TString;
    vRec :PFilterRec;
  begin
    vCommit := GetCommit(ARow);
    if vCommit <> nil then begin

      vTag := FGrid.Column[ACol].Tag;
      vStr := GetColumStr(vCommit, vTag);

      vRec := nil;
      if (FFilterMask <> '') and (FFilterColumn = vTag) then
        vRec := PFilterRec(FFilter.PItems[ARow]);

      if vRec <> nil then
        FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(AColor, optFoundColor))
      else
        FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
    end;
  end;


  function THistDlg.GetCommit(ARow :Integer) :TGitCommit;
  var
    vIdx :Integer;
  begin
    Result := nil;
    vIdx := RowToIdx(ARow);
    if (vIdx >= 0) and (vIdx < FHistory.Count) then
      Result := FHistory[vIdx];
  end;


  function THistDlg.FindSelItem(AItem :TGitCommit) :Integer;
  var
    I :Integer;
  begin
    for I := 0 to FGrid.RowCount - 1 do
      if FHistory[RowToIdx(I)] = AItem then begin
        Result := I;
        Exit;
      end;
    Result := -1;
  end;


  function THistDlg.GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;
//  var
//    vIdx, vLen :Integer;
//    vStr :PTChar;
//    vSel :TGitCommit;
  begin
//    vIdx := RowToIdx(ARow);
//    vStr := GetEdtStr(vIdx, vLen);
//    if vLen > 0 then begin
//      vSel := FHistory.PItems[vIdx];
//      AEdtRow := vSel.FRow;
//      StrTrimFirst(vStr, vLen);
//      Result := StrExpandTabs(vStr);
//    end;
  end;


 {-----------------------------------------------------------------------------}
 { Поддержка сортировки                                                        }

  procedure THistDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optHistSortMode then
      optHistSortMode := AOrder
    else
      optHistSortMode := -AOrder;

//  LocReinitAndSaveCurrent;
    ReinitGrid;
//  WriteSetup;;
  end;


  procedure THistDlg.SortByDlg;
//  var
//    vMenu :TFarMenu;
//    vRes :Integer;
//    vChr :TChar;
  begin
    Sorry;

//    vMenu := TFarMenu.CreateEx(
//      GetMsg(strSortBy),
//    [
//      GetMsg(strLineNumber),
//      GetMsg(strWholeRow),
//      GetMsg(strFoundMatch),
//      GetMsg(strFoundMatchNum)
//    ]);
//    try
//      vRes := Abs(optGrepSortMode) - 1;
//      if vRes = -1 then
//        vRes := 0;
//      vChr := '+';
//      if optGrepSortMode < 0 then
//        vChr := '-';
//      vMenu.Items[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);
//
//      if not vMenu.Run then
//        Exit;
//
//      vRes := vMenu.ResIdx;
//      if vRes <> -1 then
//        SetOrder(vRes + 1);
//
//    finally
//      FreeObj(vMenu);
//    end;
  end;


 {-----------------------------------------------------------------------------}

//  procedure THistDlg.ToggleOption(var AOption :Boolean);
//  begin
//    AOption := not AOption;
//    ReinitGrid;
//    WriteSetup;
//  end;


  procedure THistDlg.OptionsMenu;
//var
//  vMenu :TFarMenu;
  begin
//    vMenu := TFarMenu.CreateEx(
//      GetMsg(strOptions),
//    [
//      GetMsg(strMShowNumbers),
//      GetMsg(strMShowMatches),
//      GetMsg(strMTrimSpaces),
//      GetMsg(strMAutoSync),
//      GetMsg(strMShowHints),
//      '',
//      GetMsg(strMColors)
//    ]);
//    try
//      while True do begin
//        vMenu.Checked[0] := optGrepShowLines;
//        vMenu.Checked[1] := oprGrepShowMatch;
//        vMenu.Checked[2] := optGrepTrimSpaces;
//        vMenu.Checked[3] := optGrepAutoSync;
//        vMenu.Checked[4] := optGrepShowHints;
//
//        vMenu.SetSelected(vMenu.ResIdx);
//
//        if not vMenu.Run then
//          Exit;
//
//        case vMenu.ResIdx of
//          0: ToggleOption(optGrepShowLines);
//          1: ToggleOption(oprGrepShowMatch);
//          2: ToggleOption(optGrepTrimSpaces);
//          3: ToggleOption(optGrepAutoSync);
//          4: ToggleOption(optGrepShowHints);
//          5: {};
//          6: ColorMenu
//        end;
//      end;
//
//    finally
//      FreeObj(vMenu);
//    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure THistDlg.ShowInfo;
  var
    vCommit :TGitCommit;
  begin
    vCommit := GetCommit(FGrid.CurRow);
    if vCommit <> nil then begin
      ShowInfoDlg(FRepo,
        GetMsgStr(strCommitInfoTitle),
      [
        GetMsgStr(strDate), CommitDateToStr(vCommit.Date, True),
        GetMsgStr(strAuthor), vCommit.GetAuthorAndEmail,
        GetMsgStr(strID), vCommit.IDStr,
        '', ' ' + GetMsgStr(strMessage) + ' ',
        ' ', AppendStrCh(vCommit.Message1, vCommit.Message2, #13)
      ]);
    end;
  end;


  procedure THistDlg.ShowDiff(AFull :Boolean);
  var
    vCommit :TGitCommit;
  begin
    vCommit := GetCommit(FGrid.CurRow);
    if vCommit <> nil then
      FRepo.ShowCommitDiff(vCommit.ID, AFull);
  end;


  procedure THistDlg.ShowDiffWith;
  var
    vCommit :TGitCommit;
  begin
    vCommit := GetCommit(FGrid.CurRow);
    if vCommit <> nil then
      FRepo.ShowDiff(vCommit.IDStr + ' ' + FRepo.GetCurrentBranchName);
  end;



  procedure THistDlg.CheckoutCurrent;
  var
    vCommit :TGitCommit;
  begin
    vCommit := GetCommit(FGrid.CurRow);
    if vCommit <> nil then
      FRepo.Checkout(vCommit.IDStr);
    SendMsg(DM_CLOSE, -1, 0);
  end;


  procedure THistDlg.SelectItem(ACode :Integer); {override;}
  begin
    if ACode = 2 then
      ShowDiff(False);
  end;


  function THistDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocToggleOptionInt(var AOption :Integer; ANewValue :Integer);
    begin
      AOption  := ANewValue;
      WriteSetup;
      ReInitGrid;
    end;


  begin
    Result := True;
    case AKey of

      KEY_CTRLENTER:
        ShowDiff(True);

      KEY_F3:
        ShowInfo;
      KEY_ALTF3:
        ShowDiffWith;

      KEY_ALTF4:
        CheckoutCurrent;

      KEY_CTRL1:
        LocToggleOptionInt(optShowDate, IntIf(optShowDate < 2, optShowDate + 1, 0));
//    KEY_CTRL2:
//      LocToggleOptionInt(optShowBind, IntIf(optShowBind < 2, optShowBind + 1, 0));
      KEY_CTRL3:
        LocToggleOptionInt(optShowAuthor, IntIf(optShowAuthor < 1, optShowAuthor + 1, 0));
      KEY_CTRL4:
        LocToggleOptionInt(optShowEmail, IntIf(optShowEmail < 1, optShowEmail + 1, 0));
      KEY_CTRL5:
        LocToggleOptionInt(optShowID, IntIf(optShowID < 2, optShowID + 1, 0));

      KEY_CTRLF1, KEY_CTRLSHIFTF1:
        SetOrder(1);
      KEY_CTRLF2, KEY_CTRLSHIFTF2:
        SetOrder(2);
      KEY_CTRLF3, KEY_CTRLSHIFTF3:
        SetOrder(3);
      KEY_CTRLF4, KEY_CTRLSHIFTF4:
        SetOrder(4);
      KEY_CTRLF5, KEY_CTRLSHIFTF5:
        SetOrder(5);
      KEY_CTRLF11:
        SetOrder(0);
      KEY_CTRLF12:
        SortByDlg;

      KEY_F9:
        OptionsMenu;
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function THistDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        ReinitAndSaveCurrent;
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function HistDlg(ARepo :TGitRepository; AHistory :TExList) :Boolean;
  var
    vDlg :THistDlg;
  begin
    Result := False;
    vDlg := THistDlg.Create;
    try
      vDlg.FRepo := ARepo;
      vDlg.FHistory := AHistory;
      if vDlg.Run = -1 then
        Exit;
      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


initialization
  ShowHistDlg := HistDlg;
end.


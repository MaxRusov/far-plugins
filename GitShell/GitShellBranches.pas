{$I Defines.inc}

unit GitShellBranches;

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

    GitLibAPI,
    GitShellClasses,
    GitShellCtrl;


  type
    TBranchesDlg = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

//    function GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; override;

      procedure SelectItem(ACode :Integer); override;
      procedure ShowDiffWith;
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
      FRepo       :TGitRepository;
      FBranches   :TExList;

      FExpKind    :TBranchKind;

      FCurBranch  :TGitBranch;
      FCurrent    :Integer;

      FShowTitles :Boolean;

      function GetColumStr(ABranch :TGitBranch; AColTag :Integer) :TString;
      function FindSelItem(AItem :TGitBranch) :Integer;
      function GetBranch(ARow :Integer; IsGroup :PBoolean = nil; aRaise :boolean = False) :TGitBranch;
//    procedure ToggleOption(var AOption :Boolean);
      procedure OptionsMenu;
      procedure SetOrder(AOrder :Integer);
      procedure SortByDlg;
      procedure CreateBranch;
      procedure RenameBranch;
      procedure DeleteBranch;

    public
      property Grid :TFarGrid read FGrid;
    end;



{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TBranchesDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TBranchesDlg.Create; {override;}
  begin
    inherited Create;
//  RegisterHints(Self);
    FFilter := TListFilter.Create;
    FFilter.Owner := Self;
    FCurrent := -1;
  end;


  destructor TBranchesDlg.Destroy; {override;}
  begin
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TBranchesDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FGUID := cBranchesDlgID;
    FHelpTopic := 'Branches';
//  FGrid.OnTitleClick := GridTitleClick;
    FGrid.Options := [{goRowSelect,} goWrapMode {, goFollowMouse}];
  end;


  procedure TBranchesDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
    FExpKind := bkLocal;
    if FCurrent <> -1 then begin
      FCurBranch := FBranches[FCurrent];
      SetCurrent(FindSelItem(FCurBranch), lmCenter);
    end;
  end;


  procedure TBranchesDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strBranchesTitle);

    if FFilter = nil then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);

    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;
  end;


  function TBranchesDlg.GetColumStr(ABranch :TGitBranch; AColTag :Integer) :TString;
  begin
    case AColTag of
      1: Result := ABranch.Name;
      2: Result := ABranch.IDStr;
    end;
  end;


  function TBranchesDlg.ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; {override;}
  var
    vBranch1, vBranch2 :TGitBranch;
  begin
    vBranch1 := FBranches[AIndex1];
    vBranch2 := FBranches[AIndex2];

    Result := 0;
    case Abs(Context) of
      1: Result := UpCompareStr(vBranch1.Name, vBranch2.Name);
      2: Result := UpCompareStr(vBranch1.IDStr, vBranch2.IDStr);
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(AIndex1, AIndex2);
  end;


  procedure TBranchesDlg.ReInitGrid; {virtual;}
  var
    I, vCount, vPos, vFndLen, vMaxLen1, vMaxLen2 :Integer;
    vBranch :TGitBranch;
    vStr, vMask, vXMask :TString;
    vHasMask :Boolean;
    vLastKind :TBranchKind;
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

    vMaxLen1 := length(GetMsgStr(strName));
    vMaxLen2 := length(GetMsgStr(strID));

    vLastKind := bkLocal;

    FTotalCount := 0;
    for I := 0 to FBranches.Count - 1 do begin
      vBranch := FBranches[I];

//    if not optShowHidden and vBranch.Hidden then
//      Continue;

      Inc(FTotalCount);

      vPos := 0; vFndLen := 0;
      if vMask <> '' then begin
        vStr := GetColumStr(vBranch, FFilterColumn);
        if not ChrCheckXMask(vMask, vXMask, PTChar(vStr), vHasMask, vPos, vFndLen) then
          Continue;
      end;

      if (vLastKind <> vBranch.Kind) or (vCount = 0) then begin
        FFilter.Add(I, $FFFF, 0);
        vLastKind := vBranch.Kind;
        Inc(vCount);
      end;

      if (vMask = '') and (vBranch.Kind <> FExpKind) then
        Continue;

      FFilter.Add(I, vPos, vFndLen);

      vMaxLen1 := IntMax(vMaxLen1, Length(vBranch.Name) + 2);
      if optShowID > 0 then
        vMaxLen2 := IntMax(vMaxLen2, Length(vBranch.IDStr));

      Inc(vCount);
    end;

    if optHistSortMode <> 0 then
      FFilter.SortList(True, optHistSortMode);

    FGrid.ResetSize;

    FGrid.Columns.FreeAll;
    if True then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strName), vMaxLen1+2, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    if optShowID > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strID), vMaxLen2+2, taLeftJustify, [coColMargin, coOwnerDraw], 2) );

//  FGrid.Column[0].MinWidth := IntMin(vMaxLen2, 15);
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        MinWidth := IntMin(Width, 6);

    FGrid.ReduceColumns(FarGetWindowSize.CX - (10 + FGrid.Columns.Count));

    if FShowTitles then
      FGrid.Options := FGrid.Options + [goShowTitle]
    else
      FGrid.Options := FGrid.Options - [goShowTitle];
    FGrid.TitleColor  := GetOptColor(optTitleColor, COL_MENUHIGHLIGHT);

    FMenuMaxWidth := 0;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then begin
          if FShowTitles and (Abs(optHistSortMode) = Tag) then
            Header := StrIf(optHistSortMode > 0, chrUpMark, chrDnMark) + Header;
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
        end;
    Dec(FMenuMaxWidth);
    FGrid.Column[0].Width := 0;

    FGrid.RowCount := vCount;
    FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);

    UpdateHeader;
    ResizeDialog;
  end;



  procedure TBranchesDlg.ReinitAndSaveCurrent; {override;}
  var
    vSel :TGitBranch;
  begin
    vSel := GetBranch(FGrid.CurRow);
    ReinitGrid;
    if vSel <> nil then
      SetCurrent(FindSelItem(vSel), lmCenter);
  end;


  procedure TBranchesDlg.GridPosChange(ASender :TFarGrid); {override;}
  begin
    {}
  end;


  function TBranchesDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vBranch :TGitBranch;
  begin
    Result := '';
    vBranch := GetBranch(ARow);
    if vBranch <> nil then
      Result := GetColumStr(vBranch, FGrid.Column[ACol].Tag);
  end;


  procedure TBranchesDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
  var
    vBranch :TGitBranch;
    vIsGroup :Boolean;
  begin
    vBranch := GetBranch(ARow, @vIsGroup);
    if vBranch <> nil then begin
      if ACol = -1 then begin
        AColor := FGrid.NormColor;
        if (FGrid.CurRow = ARow) and ((FGrid.CurCol = 0) or vIsGroup) then
          AColor := FGrid.SelColor;
      end else
      begin
//      if optShowHidden and vBranch.Hidden then
//        AColor := ChangeFG(AColor, optHiddenColor);
      end;
    end;
  end;


  procedure TBranchesDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vBranch :TGitBranch;
    vTag :Integer;
    vStr :TString;
    vRec :PFilterRec;
    vIsGroup :Boolean;
  begin
    vBranch := GetBranch(ARow, @vIsGroup);
    if vBranch <> nil then begin
      vTag := FGrid.Column[ACol].Tag;
      if vIsGroup then begin
        if vTag <> 1 then
          Exit;

        case vBranch.Kind of
          bkLocal  : vStr := 'local';
          bkRemote : vStr := 'remote';
          bkTag    : vStr := 'tag';
        end;
        if ARow <> FGrid.CurRow then
          AColor := ChangeFG(AColor, optGroupColor);
        FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);

      end else
      begin
        vStr := GetColumStr(vBranch, vTag);

        if vTag = 1 then begin
          if vBranch = FCurBranch then
            FGrid.DrawChr(X, Y, '*', 1, AColor);
          Inc(X, 2);
          Dec(AWidth, 2);
        end;

        vRec := nil;
        if (FFilterMask <> '') and (FFilterColumn = vTag) then
          vRec := PFilterRec(FFilter.PItems[ARow]);

        if vRec <> nil then
          FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(AColor, optFoundColor))
        else
          FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
      end;
    end;
  end;


  function TBranchesDlg.GetBranch(ARow :Integer; IsGroup :PBoolean = nil; aRaise :boolean = False) :TGitBranch;
  var
    vRec :PFilterRec;
    vIsGroup :Boolean;
  begin
    Result := nil;
    if (ARow >= 0) and (ARow < FFilter.Count) then begin
      vRec := PFilterRec(FFilter.PItems[ARow]);
      vIsGroup := vRec.FPos = $FFFF;
      if not vIsGroup or (IsGroup <> nil) then
        Result := FBranches[vRec.FIdx];
      if IsGroup <> nil then
        IsGroup^ := vIsGroup;
    end;
    if (Result = nil) and aRaise then
      AppError('No current branch');
  end;


  function TBranchesDlg.FindSelItem(AItem :TGitBranch) :Integer;
  var
    i :Integer;
    vRec :PFilterRec;
  begin
    for I := 0 to FFilter.Count - 1 do begin
      vRec := PFilterRec(FFilter.PItems[i]);
      if (FBranches[vRec.FIdx] = AItem) and (vRec.FPos <> $FFFF) then
        Exit(i);
    end;
    Result := -1;
  end;


 {-----------------------------------------------------------------------------}
 { Поддержка сортировки                                                        }

  procedure TBranchesDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optHistSortMode then
      optHistSortMode := AOrder
    else
      optHistSortMode := -AOrder;

//  LocReinitAndSaveCurrent;
    ReinitGrid;
//  PluginConfig(True);
  end;


  procedure TBranchesDlg.SortByDlg;
  begin
    Sorry;
  end;


 {-----------------------------------------------------------------------------}

//  procedure TBranchesDlg.ToggleOption(var AOption :Boolean);
//  begin
//    AOption := not AOption;
//    ReinitGrid;
//    WriteSetup;
//  end;


  procedure TBranchesDlg.OptionsMenu;
  begin
    Sorry;
  end;


 {-----------------------------------------------------------------------------}

(*
  procedure TBranchesDlg.SelectItem(ACode :Integer); {override;}
  var
    vBranch :TGitBranch;
  begin
    vBranch := GetBranch(FGrid.CurRow);
    if vBranch <> nil then
      FRepo.Checkout(vBranch.Name);
    SendMsg(DM_CLOSE, -1, 0);
  end;
*)

  procedure TBranchesDlg.SelectItem(ACode :Integer); {override;}
  var
    vBranch :TGitBranch;
    vIsGroup :Boolean;
  begin
    vBranch := GetBranch(FGrid.CurRow, @vIsGroup);
    if vBranch <> nil then begin
      if not vIsGroup then begin
        if ACode = 2 then begin
          { Запрос? }
          FRepo.Checkout(vBranch.Name);
          SendMsg(DM_CLOSE, -1, 0);
        end;
      end else
      if FFilterMask = '' then begin
        FExpKind := vBranch.Kind;
        ReinitGrid;
        SetCurrent(FindSelItem(vBranch), lmSafe);
      end;
    end;
  end;


  procedure TBranchesDlg.ShowDiffWith;
  var
    vBranch :TGitBranch;
  begin
    vBranch := GetBranch(FGrid.CurRow, nil, True);
//  FRepo.ShowDiff(vBranch.IDStr + ' ' + FRepo.GetCurrentBranchName);
    FRepo.ShowDiff(vBranch.Name + ' ' + FRepo.GetCurrentBranchName);
  end;


  procedure TBranchesDlg.CreateBranch;
  var
    vName :TString;
    vIdx :Integer;
    vBranch, vNewBranch :TGitBranch;
    vID :TGitOid;
  begin
    vBranch := GetBranch(FGrid.CurRow, nil, True);

    vName := '';
    if FarInputBox(GetMsg(strCreateBranchTitle), GetMsg(strBranchNamePrompt), vName, FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY, cBranchNameHistory) then begin

      FRepo.CreateBranch(vName, vBranch.Name, vID);

      vIdx := RowToIdx(FGrid.CurRow);
      vNewBranch := TGitBranch.Create(@vID, vName, bkLocal);

      FBranches.Insert( vIdx + 1, vNewBranch );
      ReInitGrid;

      SetCurrent(FindSelItem(vNewBranch), lmSafe);
    end;
  end;


  procedure TBranchesDlg.RenameBranch;
  var
    vName :TString;
    vBranch :TGitBranch;
  begin
    vBranch := GetBranch(FGrid.CurRow, nil, True);

    vName := vBranch.Name;
    if FarInputBox(GetMsg(strRenameBranchTitle), GetMsg(strBranchNamePrompt), vName, FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY, cBranchNameHistory) then begin

      FRepo.RenameBranch(vBranch.Name, vName);
      vBranch.Name := vName;

      ReInitGrid;
      SetCurrent(FindSelItem(vBranch), lmSafe);
    end;
  end;


  procedure TBranchesDlg.DeleteBranch;
  var
    vBranch :TGitBranch;
  begin
    vBranch := GetBranch(FGrid.CurRow, nil, True);
    if ShowMessageBut(GetMsgStr(strDeleteTitle), Format(GetMsgStr(strDeleteBranch), [vBranch.Name]), [GetMsgStr(strDeleteBut),  GetMsgStr(strCancel)], FMSG_WARNING) <> 0 then
      Exit;

    FRepo.DeleteBranch(vBranch.Name);

    FBranches.RemoveItem(vBranch);
    FreeObj(vBranch);
    ReInitGrid;
  end;



  function TBranchesDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocToggleOptionInt(var AOption :Integer; ANewValue :Integer);
    begin
      AOption  := ANewValue;
      WriteSetup;
      ReInitGrid;
    end;


  begin
    Result := True;
    case AKey of

      KEY_F3:
        {ShowInfo};
      KEY_ALTF3:
        ShowDiffWith;

      KEY_F6:
        RenameBranch;
      KEY_F7:
        CreateBranch;
      KEY_F8:
        DeleteBranch;

      KEY_CTRL2:
        LocToggleOptionInt(optShowID, IntIf(optShowID < 2, optShowID + 1, 0));

//    KEY_CTRLF1, KEY_CTRLSHIFTF1:
//      SetOrder(1);
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


  function TBranchesDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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

  function BranchesDlg(ARepo :TGitRepository; ABranches :TExList; aCur :Integer) :Boolean;
  var
    vDlg :TBranchesDlg;
  begin
    Result := False;
    vDlg := TBranchesDlg.Create;
    try
      vDlg.FRepo := ARepo;
      vDlg.FBranches := ABranches;
      vDlg.FCurrent := aCur;
      if vDlg.Run = -1 then
        Exit;
      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


initialization
  ShowBranchesDlg := BranchesDlg;
end.


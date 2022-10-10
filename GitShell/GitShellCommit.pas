{$I Defines.inc}

unit GitShellCommit;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixFormat,

    Far_API,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,
    FarMenu,
    FarDraw,
    FarListDlg,

    VisCompAPI,

    GitLibAPI,
    GitShellCtrl,
    GitShellClasses,
    GitShellCommitDlg;


  type
    TCommitListDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

//    function GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;

//    procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader;
      procedure ReinitGrid;
      procedure ReinitAndSaveCurrent;

      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FGrid       :array[1..2] of TFarGrid;
      FFilter     :array[1..2] of TListFilter;

      FRepo       :TGitRepository;
      FStatus     :TGitWorkdirStatus;

//    FShowTitles :Boolean;

      FMenuMaxHeight :Integer;
      FMenuMaxWidth  :Integer;

      procedure ResizeDialog;

      function GetCurGridN :Integer;
      function GetCurGrid :TFarGrid;
      function GetColumStr(ADiff :TGitDiffFile; AColTag :Integer) :TString;
      function GetDiff(ASender :TFarGrid; ARow :Integer; IsGroup :PBoolean = nil; aRaise :boolean = False) :TGitDiffFile;
//    function FindSelItem(AItem :TGitBranch) :Integer;
      procedure ToggleOption(var AOption :Boolean);
      procedure OptionsMenu;

      procedure Commit;
      procedure GotoFile(aClose :Boolean);
      procedure ShowDiff(AEdit :Boolean);
      procedure StageUnstage;
      procedure Revert;
      procedure ReRead;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  const
    cDlgMinWidth  = 40;
    cDlgMinHeight = 5;

    IdFrame  = 0;
    IdHead1  = 1;
    IdHead2  = 2;
    IdList1  = 3;
    IdLineV  = 4;
    IdList2  = 5;


 {-----------------------------------------------------------------------------}
 { TCommitListDlg                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TCommitListDlg.Create; {override;}
  begin
    inherited Create;
    FFilter[1] := TListFilter.Create;
    FFilter[2] := TListFilter.Create;
  end;


  destructor TCommitListDlg.Destroy; {override;}
  begin
    FreeObj(FGrid[1]);
    FreeObj(FGrid[2]);
    FreeObj(FFilter[1]);
    FreeObj(FFilter[2]);
    inherited Destroy;
  end;


  procedure TCommitListDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FGUID := cChangesDlgID;
    FHelpTopic := 'Commit';
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_Text,        3, 2, DX div 2, 1, DIF_SHOWAMPERSAND, '...'),
        NewItemApi(DI_Text,        DX div 2 + 1, 2, DX - 6, 1, DIF_SHOWAMPERSAND, '...'),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0 ),
        NewItemApi(DI_SINGLEBOX,   0, 0, 0, 0, 0),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0 )
      ],
      @FItemCount
    );

    FGrid[1] := TFarGrid.CreateEx(Self, IdList1);
    FGrid[1].Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid[1].OnGetCellText := GridGetDlgText;
    FGrid[1].OnGetCellColor := GridGetCellColor;
    FGrid[1].OnPaintCell := GridPaintCell;

    FGrid[2] := TFarGrid.CreateEx(Self, IdList2);
    FGrid[2].Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid[2].OnGetCellText := GridGetDlgText;
    FGrid[2].OnGetCellColor := GridGetCellColor;
    FGrid[2].OnPaintCell := GridPaintCell;
  end;


  procedure TCommitListDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);

//    FGrid1.NormColor := GetOptColor(optDlgColor, COL_MENUTEXT);
//    FGrid1.SelColor  := GetOptColor(optCurColor, COL_MENUSELECTEDTEXT);
//    FGrid2.NormColor := FGrid1.NormColor;
//    FGrid2.SelColor  := FGrid1.SelColor;

    ReinitGrid;
  end;


  procedure TCommitListDlg.ResizeDialog;
  var
    vWidth, vHeight, vCenter :Integer;
    vRect, vRect1 :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vSize.CX - 4 then
      vWidth := vSize.CX - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    FMenuMaxHeight := IntMax(FMenuMaxHeight, IntMax(FGrid[1].RowCount, FGrid[2].RowCount));

    vHeight := IntMax(FMenuMaxHeight, 1) + 5;
    if vHeight > vSize.CY - 2 then
      vHeight := vSize.CY - 2;
    vHeight := IntMax(vHeight, cDlgMinHeight);

    vRect := SBounds(0, 0, vWidth-1, vHeight-1);
    RectGrow(vRect, -2, -1);
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    RectGrow(vRect, -1, -1);

    vCenter := vRect.Left + (vRect.Right - vRect.Left) div 2;

    vRect1 := SRect(vRect.Left, vRect.Top, vCenter - 1, vRect.Top);
    SendMsg(DM_SETITEMPOSITION, IdHead1, @vRect1);

    vRect1 := SRect(vCenter + 1, vRect.Top, vRect.Right, vRect.Top);
    SendMsg(DM_SETITEMPOSITION, IdHead2, @vRect1);

    vRect1 := SRect(vRect.Left, vRect.Top + 1, vCenter - 1, vRect.Bottom);
    SendMsg(DM_SETITEMPOSITION, IdList1, @vRect1);
    FGrid[1].UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := SRect(vCenter + 1, vRect.Top + 1, vRect.Right, vRect1.Bottom);
    SendMsg(DM_SETITEMPOSITION, IdList2, @vRect1);
    FGrid[2].UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := SRect(vCenter, vRect.Top + 1, vCenter, vRect1.Bottom);
    SendMsg(DM_SETITEMPOSITION, IdLineV, @vRect1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


  procedure TCommitListDlg.UpdateHeader; {override;}
  var
    vTitle, vStatus1, vStatus2 :TFarStr;
  begin
    vTitle := GetMsgStr(strChangesTitle);

//    if FFilter = nil then
//      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
//    else
//      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);
//
    SetText(IdFrame, vTitle);
    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;

    vStatus1 := Format(' %s (%d)', [GetMsgStr(strUnstaged), FStatus.Unstaged.Count]);
    vStatus2 := Format(' %s (%d)', [GetMsgStr(strStaged), FStatus.Staged.Count]);

    SetText(IdHead1, vStatus1);
    SetText(IdHead2, vStatus2);

    FMenuMaxWidth := IntMax(FMenuMaxWidth, length(vStatus1) + length(vStatus1) + 3 );
  end;


  function TCommitListDlg.GetColumStr(ADiff :TGitDiffFile; AColTag :Integer) :TString;
  begin
    case AColTag of
      1:
        if optCommitGroups then
          Result := ADiff.Name
        else
          Result := ADiff.FileName;
//    2: Result := ABranch.IDStr;
    end;
  end;


  procedure TCommitListDlg.ReInitGrid; {virtual;}
  var
    vMaxLen1 :Integer;

    procedure LocFilter(aFilter :TListFilter; aList :TObjList);
    var
      i, vCount :Integer;
      vDiff :TGitDiffFile;
      vLastFolder :TString;
    begin
      aFilter.Clear;
      vLastFolder := ''; vCount := 0;

      for I := 0 to aList.Count - 1 do begin
        vDiff := aList[I];

//        vPos := 0; vFndLen := 0;
//        if vMask <> '' then begin
//          vStr := GetColumStr(vBranch, FFilterColumn);
//          if not ChrCheckXMask(vMask, vXMask, PTChar(vStr), vHasMask, vPos, vFndLen) then
//            Continue;
//        end;

        if optCommitGroups then
          if (vDiff.Path <> vLastFolder) or (vCount = 0) then begin
            vMaxLen1 := IntMax(vMaxLen1, Length(vDiff.Path));
            aFilter.Add(I, 0, 0, cSelGroup);
            vLastFolder := vDiff.Path;
            Inc(vCount);
          end;

//        if (vMask = '') and (vBranch.Kind <> FExpKind) then
//          Continue;

        aFilter.Add(I, 0{vPos}, 0{vFndLen});

        if optCommitGroups then
          vMaxLen1 := IntMax(vMaxLen1, Length(vDiff.Name) + 2)
        else
          vMaxLen1 := IntMax(vMaxLen1, Length(vDiff.FileName) + 2);

//        if optShowID > 0 then
//          vMaxLen2 := IntMax(vMaxLen2, Length(vBranch.IDStr));

        Inc(vCount);
      end;
    end;

  begin
    vMaxLen1 := 0;

    LocFilter(FFilter[1], FStatus.Unstaged);
    LocFilter(FFilter[2], FStatus.Staged);

//    if optHistSortMode <> 0 then
//      FFilter.SortList(True, optHistSortMode);

    FGrid[1].ResetSize;
    FGrid[1].Columns.FreeAll;
    if True then
      FGrid[1].Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strName), 0{vMaxLen1+2}, taLeftJustify, [coColMargin, coOwnerDraw], 1) );

    FGrid[2].ResetSize;
    FGrid[2].Columns.FreeAll;
    if True then
      FGrid[2].Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strName), 0{vMaxLen1+2}, taLeftJustify, [coColMargin, coOwnerDraw], 1) );

////  FGrid.Column[0].MinWidth := IntMin(vMaxLen2, 15);
//    for I := 0 to FGrid.Columns.Count - 1 do
//      with FGrid.Column[I] do
//        MinWidth := IntMin(Width, 6);
//
//    FGrid.ReduceColumns(FarGetWindowSize.CX - (10 + FGrid.Columns.Count));
//
//    if FShowTitles then
//      FGrid.Options := FGrid.Options + [goShowTitle]
//    else
//      FGrid.Options := FGrid.Options - [goShowTitle];
//    FGrid.TitleColor  := GetOptColor(optTitleColor, COL_MENUHIGHLIGHT);
//
//    FMenuMaxWidth := 0;
//    for I := 0 to FGrid.Columns.Count - 1 do
//      with FGrid.Column[I] do
//        if Width <> 0 then begin
//          if FShowTitles and (Abs(optHistSortMode) = Tag) then
//            Header := StrIf(optHistSortMode > 0, chrUpMark, chrDnMark) + Header;
//          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
//        end;
//    Dec(FMenuMaxWidth);
//    FGrid.Column[0].Width := 0;

    FMenuMaxWidth := (vMaxLen1 + 2) * 2  + 1;

    FGrid[1].RowCount := FFilter[1].Count;
    FGrid[1].GotoLocation(FGrid[1].CurCol, FGrid[1].CurRow, lmScroll);

    FGrid[2].RowCount := FFilter[2].Count;
    FGrid[2].GotoLocation(FGrid[2].CurCol, FGrid[2].CurRow, lmScroll);

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      UpdateHeader;
//    UpdateFooter;
      ResizeDialog;
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;



  procedure TCommitListDlg.ReinitAndSaveCurrent; {override;}
//  var
//    vSel :TGitBranch;
  begin
//    vSel := GetBranch(FGrid.CurRow);
//    ReinitGrid;
//    if vSel <> nil then
//      SetCurrent(FindSelItem(vSel), lmCenter);
  end;


  function TCommitListDlg.GetCurGridN :Integer;
  begin
    if SendMsg(DM_GETFOCUS, 0, 0) = IDList1 then
      Result := 1
    else
      Result := 2;
  end;


  function TCommitListDlg.GetCurGrid :TFarGrid;
  begin
    Result := FGrid[GetCurGridN];
  end;


  function TCommitListDlg.GetDiff(ASender :TFarGrid; ARow :Integer; IsGroup :PBoolean = nil; aRaise :boolean = False) :TGitDiffFile;
  var
    vRec :PFilterRec;
    vIsGroup :Boolean;
    vList :TObjList;
    vFilter :TListFilter;
  begin
    if ASender = FGrid[1] then begin
      vList := FStatus.Unstaged;
      vFilter := FFilter[1];
    end else
    begin
      vList := FStatus.Staged;
      vFilter := FFilter[2];
    end;

    Result := nil;
    if (ARow >= 0) and (ARow < vFilter.Count) then begin
      vRec := PFilterRec(vFilter.PItems[ARow]);
      vIsGroup := vRec.FSel and cSelGroup <> 0;
      if not vIsGroup or (IsGroup <> nil) then
        Result := vList[vRec.FIdx];
      if IsGroup <> nil then
        IsGroup^ := vIsGroup;
    end;
    if (Result = nil) and aRaise then
      AppErrorId(strNoCurrentFile);
  end;


  function TCommitListDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vDiff :TGitDiffFile;
  begin
    Result := '';
    vDiff := GetDiff(ASender, ARow);
    if vDiff <> nil then
      Result := GetColumStr(vDiff, ASender.Column[ACol].Tag);
  end;


  procedure TCommitListDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
  var
    vGrid :Integer;
    vRec :PFilterRec;
  begin
    if ASender = GetCurGrid then begin
      vGrid := IntIf(ASender = FGrid[1], 1, 2);
      if ARow < FFilter[vGrid].Count then begin
        vRec := FFilter[vGrid].PItems[ARow];
        if ACol = -1 then begin
          AColor := ASender.NormColor;
          if vRec.FSel and cSelSeleted <> 0 then
            AColor := optSelectedColor;
          if (ASender.CurRow = ARow) and (ASender.CurCol = 0) then
            AColor := ASender.SelColor;
        end;
      end;
    end else
      AColor := ASender.NormColor;
  end;


  procedure TCommitListDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vDiff :TGitDiffFile;
    vTag :Integer;
    vStr :TString;
    vRec :PFilterRec;
    vIsGroup :Boolean;
    vColor :TFarColor;
  begin
    vDiff := GetDiff(ASender, ARow, @vIsGroup);
    if vDiff <> nil then begin
      vTag := ASender.Column[ACol].Tag;
      if vIsGroup then begin
        if vTag <> 1 then
          Exit;

        if (ARow <> ASender.CurRow) or (ASender <> GetCurGrid) then
          AColor := ChangeFG(AColor, optGroupColor);

        vStr := vDiff.Path;
        if vStr = '' then
          vStr := '\';
        ASender.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
      end else
      begin
        vColor := AColor;
        case vDiff.Status of
          dfChanged : vColor := ChangeFG(vColor, optModColor);
          dfAdded   : vColor := ChangeFG(vColor, optAddColor);
          dfDeleted : vColor := ChangeFG(vColor, optDelColor);
        end;

        vStr := '';
        case vDiff.Status of
          dfChanged : vStr := '*';
          dfAdded   : vStr := '+';
          dfDeleted : vStr := '-';
          dfRenamed : vStr := '>';
        end;
        ASender.DrawChr(X, Y, PTChar(vStr), 1, vColor);

        vStr := GetColumStr(vDiff, vTag);

        vRec := nil;
//      if (FFilterMask <> '') and (FFilterColumn = vTag) then
//        vRec := PFilterRec(FFilter.PItems[ARow]);

        if vRec <> nil then
          ASender.DrawChrEx(X + 2, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(vColor, optFoundColor))
        else
          ASender.DrawChr(X + 2, Y, PTChar(vStr), AWidth, vColor);
      end;
    end;
  end;


//  function TCommitListDlg.FindSelItem(AItem :TGitBranch) :Integer;
//  var
//    i :Integer;
//    vRec :PFilterRec;
//  begin
//    for I := 0 to FFilter.Count - 1 do begin
//      vRec := PFilterRec(FFilter.PItems[i]);
//      if (FBranches[vRec.FIdx] = AItem) and (vRec.FPos <> $FFFF) then
//        Exit(i);
//    end;
//    Result := -1;
//  end;


 {-----------------------------------------------------------------------------}

  procedure TCommitListDlg.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    FMenuMaxHeight := 0;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TCommitListDlg.OptionsMenu;
  begin
  end;


 {-----------------------------------------------------------------------------}

  procedure TCommitListDlg.Commit;
  var
    vMessage, vAuthor, vEmail :TString;
    vAmend :Boolean;
  begin
    if FStatus.Staged.Count = 0 then
      AppErrorId(strNothingToCommit);

    if CommitDlg(FRepo, vMessage, vAuthor, vEmail, vAmend) then begin
      if vAmend then
        FRepo.AmendCommit(vMessage, vAuthor, vEmail)
      else
        FRepo.Commit(vMessage, vAuthor, vEmail);
      ReRead;
    end;
  end;


  procedure TCommitListDlg.GotoFile(aClose :Boolean);
  var
    vGrid :TFarGrid;
    vDiff :TGitDiffFile;
    vIsGroup :Boolean;
    vName, vPath :TString;
  begin
    vGrid := GetCurGrid;
    vDiff := GetDiff(vGrid, vGrid.CurRow, @vIsGroup);
    if vDiff <> nil then begin
      vName := AddFileName(FRepo.WorkDir, vDiff.FileName);
      vPath := ExtractFilePath(vName, True);
      if WinFolderExists(vPath) then begin
        FarPanelJumpToPath(True, vPath);
        if not vIsGroup and (vDiff.Status <> dfDeleted) then
          FarPanelSetCurrentItem(True, ExtractFileName(vName));
        if aClose then begin
          CloseMainMenu := True;
          Close;
        end;
      end else
        Beep;
    end else
      Beep;
  end;



  procedure TCommitListDlg.ShowDiff(AEdit :Boolean);
  var
    vGrid :TFarGrid;
    vDiff :TGitDiffFile;
    vIsGroup :Boolean;
    vVCAPI :IVisCompAPI;
    vFileName1, vFileName2 :TString;
  begin
    vGrid := GetCurGrid;
    vDiff := GetDiff(vGrid, vGrid.CurRow, @vIsGroup);
    if vDiff <> nil then begin
      if not vIsGroup then begin
        if vDiff.Status = dfChanged then begin
          vVCAPI := GetVisualCompareAPI;

          vFileName1 := AddFileName('HEAD:', vDiff.FileName);
          vFileName1 := FRepo.GetFileRevision(vFileName1);

          vFileName2 := AddFileName(FRepo.WorkDir, vDiff.FileName);

          vVCAPI.CompareFiles(PWideChar(vFileName1), PWideChar(vFileName2), 0);
        end else
        if vDiff.Status = dfAdded then begin
          vFileName2 := AddFileName(FRepo.WorkDir, vDiff.FileName);
          FarEditOrView(vFileName2, AEdit);
        end else
        if vDiff.Status = dfDeleted then begin
          vFileName1 := AddFileName('HEAD:', vDiff.FileName);
          vFileName1 := FRepo.GetFileRevision(vFileName1);
          FarEditOrView(vFileName1, AEdit);
        end else
          Beep;
      end else
        Beep;
    end;
  end;


  procedure TCommitListDlg.StageUnstage;
  var
    vGrid :TFarGrid;
    vDiff :TGitDiffFile;
    vIsGroup :Boolean;
    vName :TString;
  begin
    vGrid := GetCurGrid;
    vDiff := GetDiff(vGrid, vGrid.CurRow, @vIsGroup);

    if vDiff <> nil then begin
      if vIsGroup then
        vName := AddFileName(vDiff.Path, '*')
      else
        vName := vDiff.FileName;

      if vGrid = FGrid[1] then
        FRepo.IndexAddAll(vName)
      else
        FRepo.IndexReset(vName);

      ReRead;
    end;
  end;



  procedure TCommitListDlg.Revert;
  var
    vGrid :TFarGrid;
    vDiff :TGitDiffFile;
    vIsGroup :Boolean;
    vRevName, vName :TString;
  begin
    vGrid := GetCurGrid;
    vDiff := GetDiff(vGrid, vGrid.CurRow, @vIsGroup);
    if (vDiff <> nil) and (vGrid = FGrid[1]) then begin
      if vIsGroup then
        Sorry;

      if vDiff.Status = dfAdded then begin
        if ShowMessageBut(GetMsgStr(strDeleteTitle), Format(GetMsgStr(strDeleteFile), [vDiff.FileName]), [GetMsgStr(strDeleteBut),  GetMsgStr(strCancel)], FMSG_WARNING) <> 0 then
          Exit;

        vName := AddFileName(FRepo.WorkDir, vDiff.FileName);
        DeleteFile(vName, True);
      end else
      if vDiff.Status = dfChanged then begin
        if ShowMessageBut(GetMsgStr(strRestoreTitle), Format(GetMsgStr(strRestoreFile), [vDiff.FileName]), [GetMsgStr(strRestoreBut),  GetMsgStr(strCancel)], FMSG_WARNING) <> 0 then
          Exit;

        vRevName := AddFileName('HEAD:', vDiff.FileName);
        vName := AddFileName(FRepo.WorkDir, vDiff.FileName);
        FRepo.WriteFileRevisionTo(vRevName, vName, False);
      end else
      if vDiff.Status = dfDeleted then begin
        if ShowMessageBut(GetMsgStr(strRestoreTitle), Format(GetMsgStr(strRestoreFile), [vDiff.FileName]), [GetMsgStr(strRestoreBut),  GetMsgStr(strCancel)], FMSG_WARNING) <> 0 then
          Exit;

        vRevName := AddFileName('HEAD:', vDiff.FileName);
        vName := AddFileName(FRepo.WorkDir, vDiff.FileName);
        FRepo.WriteFileRevisionTo(vRevName, vName, True);
      end;
      ReRead;
    end else
      Beep;
  end;


  procedure TCommitListDlg.ReRead;
  var
    vDirStatus :TGitWorkdirStatus;
  begin
    vDirStatus := FRepo.GetWorkdirStatus(FStatus.Folder);
    try
      PtrExchange(vDirStatus, FStatus);
      ReInitGrid;
    finally
      FreeObj(vDirStatus);
    end;
  end;


  function TCommitListDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocSetCheck(aGrid, aIndex :Integer; ASetOn :Integer);
    var
      vRec :PFilterRec;
      vOldOn :Boolean;
    begin
      vRec := FFilter[aGrid].PItems[AIndex];
      if (vRec.FIdx < 0) or (vRec.FSel and cSelGroup <> 0) then
        Exit;

      vOldOn := vRec.FSel and cSelSeleted <> 0;
      if ASetOn = -1 then
        ASetOn := IntIf(vOldOn, 0, 1);
      if ASetOn = 1 then
        vRec.FSel := vRec.FSel or cSelSeleted
      else
        vRec.FSel := vRec.FSel and not cSelSeleted;
(*    if vOldOn then
        Dec(FSelCount);
      if ASetOn = 1 then
        Inc(FSelCount); *)
    end;


    procedure LocSelectCurrent;
    var
      vGrid, vIndex :Integer;
    begin
      vGrid := GetCurGridN;
      vIndex := FGrid[vGrid].CurRow;
      if vIndex = -1 then
        Exit;
      LocSetCheck(vGrid, vIndex, -1);
      if vIndex < FGrid[vGrid].RowCount - 1 then
        FGrid[vGrid].GotoLocation(FGrid[vGrid].CurCol, vIndex + 1, lmScroll);
      UpdateHeader;
    end;


    procedure LocSelectAll(AFrom :Integer; ASetOn :Integer);
    var
      I, vGrid :Integer;
    begin
      vGrid := GetCurGridN;
      for I := AFrom to FGrid[vGrid].RowCount - 1 do
        LocSetCheck(vGrid, I, ASetOn);
      UpdateHeader;
      SendMsg(DM_REDRAW, 0, 0);
    end;


  begin
    Result := True;
    try
      case AKey of
        KEY_ENTER:
          Commit;

        KEY_INS:
          LocSelectCurrent;
        KEY_CTRLADD, KEY_CTRLA:
          LocSelectAll(0, 1);
        KEY_CTRLSUBTRACT:
          LocSelectAll(0, 0);
        KEY_CTRLMULTIPLY:
          LocSelectAll(0, -1);

        KEY_CTRLPGDN:
          GotoFile(True);
        KEY_CTRLSHIFTPGDN:
          GotoFile(False);

        KEY_CTRLR:
          ReRead;
        KEY_CTRLG:
          ToggleOption(optCommitGroups);

        KEY_F3:
          ShowDiff(False);
        KEY_F4:
          ShowDiff(True);
        KEY_F5:
          StageUnstage;
        KEY_F8:
          Revert;

        KEY_F9:
          OptionsMenu;
      else
        Result := inherited KeyDown(AID, AKey);
      end;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function TCommitListDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
//    DN_GOTFOCUS:
//      Trace('%d', [Param1]);

      DN_CTLCOLORDIALOG:
        PFarColor(Param2)^ := FarGetColor(COL_MENUTEXT);

      DN_CTLCOLORDLGITEM:
        if Param1 in [IdFrame, IdLineV] then
          CtrlPalette1([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX], PFarDialogItemColors(Param2)^)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_RESIZECONSOLE: begin
        ResizeDialog;
        FGrid[1].GotoLocation(FGrid[1].CurCol, FGrid[1].CurRow, lmScroll);
        FGrid[2].GotoLocation(FGrid[2].CurCol, FGrid[2].CurRow, lmScroll);
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CommitDlg(ARepo :TGitRepository; var ADirStatus :TGitWorkdirStatus) :Boolean;
  var
    vDlg :TCommitListDlg;
  begin
    Result := False;
    vDlg := TCommitListDlg.Create;
    try
      vDlg.FRepo := ARepo;
      vDlg.FStatus := ADirStatus;
      if vDlg.Run = -1 then
        Exit;
      Result := True;
    finally
      ADirStatus := vDlg.FStatus;
      FreeObj(vDlg);
    end;
  end;


initialization
  ShowCommitDlg := CommitDlg;
end.


{$I Defines.inc}

unit GitShellCommit;

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

    VisCompAPI,

    GitLibAPI,
    GitShellClasses,
    GitShellCtrl;


  type
    TCommitDlg = class(TFarDialog)
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
      FGrid1      :TFarGrid;
      FGrid2      :TFarGrid;

      FFilter1    :TListFilter;
      FFilter2    :TListFilter;

      FRepo       :TGitRepository;
      FStatus     :TGitWorkdirStatus;

//    FShowTitles :Boolean;

      FMenuMaxHeight :Integer;
      FMenuMaxWidth  :Integer;

      procedure ResizeDialog;

      function GetCurGrid :TFarGrid;
      function GetColumStr(ADiff :TGitDiffFile; AColTag :Integer) :TString;
      function GetDiff(ASender :TFarGrid; ARow :Integer; IsGroup :PBoolean = nil; aRaise :boolean = False) :TGitDiffFile;
//    function FindSelItem(AItem :TGitBranch) :Integer;
      procedure ToggleOption(var AOption :Boolean);
      procedure OptionsMenu;

      procedure Commit;
      procedure ShowDiff(AEdit :Boolean);
      procedure StageUnstage;
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
 { TCommitDlg                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TCommitDlg.Create; {override;}
  begin
    inherited Create;
    FFilter1 := TListFilter.Create;
    FFilter2 := TListFilter.Create;
  end;


  destructor TCommitDlg.Destroy; {override;}
  begin
    FreeObj(FGrid1);
    FreeObj(FGrid2);
    FreeObj(FFilter1);
    FreeObj(FFilter2);
    inherited Destroy;
  end;


  procedure TCommitDlg.Prepare; {override;}
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

    FGrid1 := TFarGrid.CreateEx(Self, IdList1);
    FGrid1.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid1.OnGetCellText := GridGetDlgText;
    FGrid1.OnGetCellColor := GridGetCellColor;
    FGrid1.OnPaintCell := GridPaintCell;

    FGrid2 := TFarGrid.CreateEx(Self, IdList2);
    FGrid2.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid2.OnGetCellText := GridGetDlgText;
    FGrid2.OnGetCellColor := GridGetCellColor;
    FGrid2.OnPaintCell := GridPaintCell;
  end;


  procedure TCommitDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);

//    FGrid1.NormColor := GetOptColor(optDlgColor, COL_MENUTEXT);
//    FGrid1.SelColor  := GetOptColor(optCurColor, COL_MENUSELECTEDTEXT);
//    FGrid2.NormColor := FGrid1.NormColor;
//    FGrid2.SelColor  := FGrid1.SelColor;

    ReinitGrid;
  end;


  procedure TCommitDlg.ResizeDialog;
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

    FMenuMaxHeight := IntMax(FMenuMaxHeight, IntMax(FGrid1.RowCount, FGrid2.RowCount));

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
    FGrid1.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := SRect(vCenter + 1, vRect.Top + 1, vRect.Right, vRect1.Bottom);
    SendMsg(DM_SETITEMPOSITION, IdList2, @vRect1);
    FGrid2.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := SRect(vCenter, vRect.Top + 1, vCenter, vRect1.Bottom);
    SendMsg(DM_SETITEMPOSITION, IdLineV, @vRect1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


  procedure TCommitDlg.UpdateHeader; {override;}
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


  function TCommitDlg.GetColumStr(ADiff :TGitDiffFile; AColTag :Integer) :TString;
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


  procedure TCommitDlg.ReInitGrid; {virtual;}
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
            aFilter.Add(I, $FFFF, 0);
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

    LocFilter(FFilter1, FStatus.Unstaged);
    LocFilter(FFilter2, FStatus.Staged);

//    if optHistSortMode <> 0 then
//      FFilter.SortList(True, optHistSortMode);

    FGrid1.ResetSize;
    FGrid1.Columns.FreeAll;
    if True then
      FGrid1.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strName), 0{vMaxLen1+2}, taLeftJustify, [coColMargin, coOwnerDraw], 1) );

    FGrid2.ResetSize;
    FGrid2.Columns.FreeAll;
    if True then
      FGrid2.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strName), 0{vMaxLen1+2}, taLeftJustify, [coColMargin, coOwnerDraw], 1) );

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

    FGrid1.RowCount := FFilter1.Count;
    FGrid1.GotoLocation(FGrid1.CurCol, FGrid1.CurRow, lmScroll);

    FGrid2.RowCount := FFilter2.Count;
    FGrid2.GotoLocation(FGrid2.CurCol, FGrid2.CurRow, lmScroll);

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      UpdateHeader;
//    UpdateFooter;
      ResizeDialog;
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;



  procedure TCommitDlg.ReinitAndSaveCurrent; {override;}
//  var
//    vSel :TGitBranch;
  begin
//    vSel := GetBranch(FGrid.CurRow);
//    ReinitGrid;
//    if vSel <> nil then
//      SetCurrent(FindSelItem(vSel), lmCenter);
  end;


  function TCommitDlg.GetCurGrid :TFarGrid;
  begin
    Result := nil;
    case SendMsg(DM_GETFOCUS, 0, 0) of
      IDList1: Result := FGrid1;
      IDList2: Result := FGrid2;
    end;
  end;


  function TCommitDlg.GetDiff(ASender :TFarGrid; ARow :Integer; IsGroup :PBoolean = nil; aRaise :boolean = False) :TGitDiffFile;
  var
    vRec :PFilterRec;
    vIsGroup :Boolean;
    vList :TObjList;
    vFilter :TListFilter;
  begin
    if ASender = FGrid1 then begin
      vList := FStatus.Unstaged;
      vFilter := FFilter1;
    end else
    begin
      vList := FStatus.Staged;
      vFilter := FFilter2;
    end;

    Result := nil;
    if (ARow >= 0) and (ARow < vFilter.Count) then begin
      vRec := PFilterRec(vFilter.PItems[ARow]);
      vIsGroup := vRec.FPos = $FFFF;
      if not vIsGroup or (IsGroup <> nil) then
        Result := vList[vRec.FIdx];
      if IsGroup <> nil then
        IsGroup^ := vIsGroup;
    end;
    if (Result = nil) and aRaise then
      AppErrorId(strNoCurrentFile);
  end;


  function TCommitDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vDiff :TGitDiffFile;
  begin
    Result := '';
    vDiff := GetDiff(ASender, ARow);
    if vDiff <> nil then
      Result := GetColumStr(vDiff, ASender.Column[ACol].Tag);
  end;


  procedure TCommitDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
  begin
    if ASender = GetCurGrid then
      {}
    else
      AColor := ASender.NormColor;
  end;


  procedure TCommitDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
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


//  function TCommitDlg.FindSelItem(AItem :TGitBranch) :Integer;
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

  procedure TCommitDlg.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    FMenuMaxHeight := 0;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TCommitDlg.OptionsMenu;
  begin
  end;


 {-----------------------------------------------------------------------------}

  procedure TCommitDlg.Commit;
  var
    vMessage :TString;
  begin
    if FStatus.Staged.Count = 0 then
      AppErrorId(strNothingToCommit);

    vMessage := '';
    if FarInputBox(GetMsg(strCommitTitle), GetMsg(strCommitMessage), vMessage, FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY, cCommitMessageHistory) then begin
      FRepo.Commit(vMessage);
      ReRead;
    end;
  end;


  procedure TCommitDlg.ShowDiff(AEdit :Boolean);
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

          vFileName1 := AddFileName(AddFileName('HEAD:', vDiff.Path), vDiff.Name);
          vFileName1 := FRepo.GetFileRevision(vFileName1);

          vFileName2 := AddFileName(AddFileName(FRepo.WorkDir, vDiff.Path), vDiff.Name);

          vVCAPI.CompareFiles(PWideChar(vFileName1), PWideChar(vFileName2), 0);
        end else
        if vDiff.Status = dfAdded then begin
          vFileName2 := AddFileName(AddFileName(FRepo.WorkDir, vDiff.Path), vDiff.Name);
          FarEditOrView(vFileName2, AEdit);
        end else
        if vDiff.Status = dfDeleted then begin
          vFileName1 := AddFileName(AddFileName('HEAD:', vDiff.Path), vDiff.Name);
          vFileName1 := FRepo.GetFileRevision(vFileName1);
          FarEditOrView(vFileName1, AEdit);
        end else
          Beep;
      end else
        Beep;
    end;
  end;


  procedure TCommitDlg.StageUnstage;
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

      if vGrid = FGrid1 then
        FRepo.IndexAddAll(vName)
      else
        FRepo.IndexReset(vName);

      ReRead;
    end;
  end;


  procedure TCommitDlg.ReRead;
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


  function TCommitDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    try
      case AKey of
        KEY_ENTER:
          Commit;

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

  //      KEY_F6:
  //        RenameBranch;
  //      KEY_F7:
  //        CreateBranch;
  //      KEY_F8:
  //        DeleteBranch;

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


  function TCommitDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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
        FGrid1.GotoLocation(FGrid1.CurCol, FGrid1.CurRow, lmScroll);
        FGrid2.GotoLocation(FGrid2.CurCol, FGrid2.CurRow, lmScroll);
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
    vDlg :TCommitDlg;
  begin
    Result := False;
    vDlg := TCommitDlg.Create;
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


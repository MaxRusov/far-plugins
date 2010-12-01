{$I Defines.inc}

unit MoreHistoryDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

   {$ifdef bUnicodeFar}
    PluginW,
    FarKeysW,
   {$else}
    Plugin,
    FarKeys,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarMenu,
    FarGrid,
    FarListDlg,

    MoreHistoryCtrl,
    MoreHistoryClasses,
    MoreHistoryListBase,
    MoreHistoryHints;


  type
    TMenuDlg = class(TFarListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetFilter :TString;
      procedure SetFilter(const AFilter :TString);

      function GetHistoryEntry(ADlgIndex :Integer; AOnlyItem :Boolean = False) :THistoryEntry;
      function DlgItemFlag(AIndex :Integer) :Byte;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FMode           :Integer;
      FModeName       :TString;
      FFilter         :TMyFilter;
//    FFilterMode     :Boolean;
      FMaskStack      :TStrList;
      FTotalCount     :Integer;     { Общее число элементов истории (с учетом Mode и ShowHidden) }
      FShowCount      :Integer;     { Число элементов, попавшее под фильтр }
      FFixedCount     :Integer;
      FFilterMask     :TString;
      FSelectedCount  :Integer;

      FFilterHist     :TStrList;
      FHistIndex      :Integer;

      FReversed       :Boolean;
      FHierarchical   :Boolean;

      FDomain         :TString;

      FResStr         :TString;
      FResCmd         :Integer;

      procedure SelectItem(ACode :Integer);

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure UpdateHeader;
      procedure ReinitGrid;
      procedure ReinitAndSaveCurrent;
      function HistToDlgIndex(AHist :THistoryEntry) :Integer;

      procedure ToggleOption(var AOption :Boolean);
      procedure ChangeHierarchMode;
      procedure SetOrder(AOrder :Integer);
      procedure PrevFilter(APrev :Boolean);
      procedure QueryFilter;

      function CurrentHistPath :TString;
      function DlgItemSelected(AIndex :Integer) :Boolean;

      procedure CommandsMenu;
      procedure SortByMenu;

    public
      property Grid :TFarGrid read FGrid;
    end;


  procedure OpenHistoryDlg(const AModeName :TString; AMode :Integer; const AFilter :TString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  function Date2StrMode(ADate :TDateTime; AMode :Integer; ATimeGroup :Boolean) :TString;
  begin
    if AMode = 0 then begin
      if (Trunc(ADate) = Date) or ATimeGroup then
        Result := FormatTime('H:mm', ADate)
      else begin
        Result := FormatDate('ddd,dd', ADate);
      end;
    end else
      Result := FormatDate('dd.MM.yy', ADate) + ' ' + FormatTime('HH:mm', ADate); //FormatDateTime('dd/mm/yy hh:nn', ADate);
    if ADate = 0 then
      Result := StringOfChar(' ', Length(Result));
  end;


  function Date2StrLen(AMode :Integer) :Integer;
  begin
    if AMode = 0 then
      Result := 5
    else
      Result := 14;
  end;



 {-----------------------------------------------------------------------------}
 { TMenuDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TMenuDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));
    FMaskStack := TStrList.Create;
  end;


  destructor TMenuDlg.Destroy; {override;}
  begin
    FreeObj(FFilterHist);
    FreeObj(FMaskStack);
    FreeObj(FFilter);
    UnregisterHints;
    inherited Destroy;
  end;


  procedure TMenuDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := 'HistoryList';

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [{goRowSelect} {,goFollowMouse} {,goWheelMovePos}];
  end;


  procedure TMenuDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);

    FDomain := #0;
    ReinitGrid;

    if FReversed then
      SetCurrent(FFilter.Count - 1, lmSafe)
    else begin
      if FHierarchical then
        SetCurrent(1, lmSafe)
    end;
  end;


  function TMenuDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vStr :TString;
  begin
    vStr := GetFilter;
    if vStr <> '' then
      AddToHistory(cHilterHistName, vStr);
    FLastFilter := vStr;
    Result := True;
  end;


  procedure TMenuDlg.UpdateHeader;
//const
//  cSorMarks :array[0..5] of TChar = (' ', 'N', 'F', 'M', 'A', 'P');
  var
    I :Integer;
    vMask :TString;
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strListTitle);

    if (FMaskStack.Count = 0) and (FFilterMask = '') then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else begin
      vMask := '';
      for I := FFixedCount to FMaskStack.Count - 1 do
        vMask := vMask + FMaskStack[I] + ' ' + chrMoreFilter + ' ';
      vMask := vMask + FFilterMask;
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, vMask, FShowCount, FTotalCount ]);
    end;

    SetText(IdFrame, vTitle);
  end;


  procedure TMenuDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if (AButton = 1) {and ADouble} then
      SelectItem(1);
  end;


  function TMenuDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vRec :PFilterRec;
  begin
    Result := '';
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      if vRec.FIdx < 0 then
        Exit;
        
      if (vRec.FSel and 2 <> 0) and (vRec.FSel and 4 <> 0) then
        Exit;

      with FarHistory[vRec.FIdx] do
        case FGrid.Column[ACol].Tag of
          1 : Result := Path;
          2 : Result := Date2StrMode(Time, optDateFormat, optHierarchical and (optHierarchyMode <> hmDomain));
          3 : Result := Int2Str(Hits);
        end;
    end;
  end;


  procedure TMenuDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  var
    vRec :PFilterRec;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      if vRec.FIdx < 0 then
        Exit;

      with FarHistory[vRec.FIdx] do begin

        if ACol = -1 then begin
          AColor := FGrid.NormColor;
          if vRec.FSel and 1 <> 0 then
            AColor := optSelectedColor;
          if (FGrid.CurRow = ARow) and (FGrid.CurCol = 0) then
            AColor := FGrid.SelColor;
        end else
        begin
          if (vRec.FSel and 2 <> 0) then begin
            if AColor <> FGrid.SelColor then
              AColor := (AColor and not $0F) or (optGroupColor and $0F)
          end else
          if not IsFinal {and not vRec.FSel} then
            AColor := (AColor and not $0F) or (optHiddenColor and $0F)
        end;

      end;
    end;
  end;


  procedure TMenuDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

    procedure LocDrawPart(var AChr :PTChar; var ARest :Integer; ALen :Integer; AColor :Integer);
    begin
      if ARest > 0 then begin
        if ALen > ARest then
          ALen := ARest;
        SetFarChr(FGrid.RowBuf, AChr, ALen);
        FARAPI.Text(X, Y, AColor, FGrid.RowBuf);
        Dec(ARest, ALen);
        Inc(AChr, ALen);
        Inc(X, ALen);
      end;
    end;

    procedure LocPaintEx(AChr :PTChar; APos, ALen :Integer);
    begin
      if (FFilterMask = '') or (ALen = 0) or (APos < 0) then
        LocDrawPart(AChr, AWidth, AWidth, AColor)
      else begin
        LocDrawPart(AChr, AWidth, APos, AColor);
        LocDrawPart(AChr, AWidth, ALen, (AColor and not $0F) or (optFoundColor and $0F) );
        LocDrawPart(AChr, AWidth, AWidth, AColor);
      end;
    end;

  var
    vRec :PFilterRec;
    vItem :THistoryEntry;
    vDelta :Integer;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      if vRec.FIdx < 0 then
        Exit;

      vItem := FarHistory[vRec.FIdx];

      if FHierarchical then begin

        if vRec.FSel and 2 <> 0 then begin
          SetFarStr(FGrid.RowBuf, vItem.GetGroup, AWidth);
          FARAPI.Text(X, Y, AColor, FGrid.RowBuf);
        end else
        if optHierarchyMode = hmDate then begin
          Inc(X, 1); Dec(AWidth, 1);
          LocPaintEx(PTChar(vItem.Path), vRec.FPos, vRec.FLen);
        end else
        begin
          Inc(X, 1); Dec(AWidth, 1);
          vDelta := length(vItem.GetDomain);
          if vDelta > length(vItem.Path) then
            vDelta := Length(vItem.Path);
          LocPaintEx(PTChar(vItem.Path) + vDelta, vRec.FPos - vDelta, vRec.FLen);
        end;

      end else
        LocPaintEx(PTChar(vItem.Path), vRec.FPos, vRec.FLen);
    end;
  end;


  procedure TMenuDlg.ReinitGrid;
  var
    vFilters :TObjList;
    vMaxLen, vMaxHits, vDateLen, vHitsLen :Integer;


    procedure LocPrepareFilters;

      procedure LocPrepare(const AMask :TString);
      begin
        vFilters.Add(TFilterMask.CreateEx(AMask, optXLatMask, False));
      end;

    var
      I :Integer;
    begin
      for I := 0 to FMaskStack.Count - 1 do
        LocPrepare( FMaskStack[I] );
      if FFilterMask <> '' then
        LocPrepare(FFilterMask);
    end;


    function CheckFilters(const AStr :TString; var APos, ALen :Integer) :Boolean;
    var
      I :Integer;
    begin
      for I := 0 to vFilters.Count - 1 do
        if not TFilterMask(vFilters[I]).Check(AStr, APos, ALen) then begin
          Result := False;
          Exit;
        end;
      Result := True;
    end;


    procedure LocLinear;
    var
      I, J, vPos, vLen :Integer;
      vHist :THistoryEntry;
    begin
      for I := FarHistory.History.Count - 1 downto 0 do begin
        J := I;
        if FReversed then
          J := FarHistory.History.Count - I - 1;
        vHist := FarHistory[J];
        if (FMode <> 0) and (vHist.GetMode <> FMode) then
          Continue;
        if not optShowHidden and not vHist.IsFinal then
          Continue;
        if optHideCurrent and StrEqual(GLastAdded, vHist.Path) then
          Continue;

        Inc(FTotalCount);
        vPos := 0; vLen := 0;
        if vFilters.Count > 0 then
          if not CheckFilters(vHist.Path, vPos, vLen) then
            Continue;

        FFilter.Add(J, vPos, vLen);
        Inc(FShowCount);

        vMaxLen := IntMax(vMaxLen, Length(vHist.Path));
        vMaxHits := IntMax(vMaxHits, vHist.Hits);
      end;

      if optSortMode <> 0 then
        FFilter.SortList(not FReversed, optSortMode);
    end;


    procedure LocHierarchical;
    var
      I, J, vPos, vLen :Integer;
      vGroups :TObjList;
      vGroup :TMyFilter;
      vHist :THistoryEntry;
      vGroupName :TString;
      vExpanded, vPrevExpanded :Boolean;
    begin
      vGroups := TObjList.Create;
      try
        for I := FarHistory.History.Count - 1 downto 0 do begin
          vHist := FarHistory[I];
          if (FMode <> 0) and (vHist.GetMode <> FMode) then
            Continue;
          if not optShowHidden and not vHist.IsFinal then
            Continue;
          if optHideCurrent and StrEqual(GLastAdded, vHist.Path) then
            Continue;

          Inc(FTotalCount);
          vPos := 0; vLen := 0;
          if vFilters.Count > 0 then
            if not CheckFilters(vHist.Path, vPos, vLen) then
              Continue;

          vGroupName := vHist.GetGroup;
          if vGroups.FindKey(Pointer(vGroupName), 0, [], J) then
            vGroup := vGroups[J]
          else begin
            vGroup := TMyFilter.CreateSize(SizeOf(TFilterRec));
            vGroup.Name := vGroupName;
            vGroup.Domain := vHist.GetDomain;
            vGroups.Add(vGroup);
          end;

          vGroup.Add(I, vPos, vLen);
          Inc(FShowCount);
        end;

        if (FDomain = #0) and (vGroups.Count > 0) then
          { Автоматически раскрываем первую группу }
          FDomain := TMyFilter(vGroups[0]).Name;

        vPrevExpanded := False;
        for I := 0 to vGroups.Count - 1 do begin
          vGroup := vGroups[I];
          vExpanded := (vFilters.Count > 0) or StrEqual(vGroup.Name, FDomain);

          with PFilterRec(vGroup.PItems[0])^ do begin
            if vPrevExpanded or (vExpanded and (I > 0)) then
//          if vPrevExpanded and vExpanded then
              FFilter.Add(-1, 0, 0);

            FFilter.AddGroup(FIdx, vExpanded);

            vMaxLen := IntMax(vMaxLen, Length(vGroup.Name));
          end;

          if vExpanded then begin
            if optSortMode <> 0 then
              vGroup.SortList(True, optSortMode);

            for J := 0 to vGroup.Count - 1 do
              with PFilterRec(vGroup.PItems[J])^ do begin
                vHist := FarHistory[FIdx];
                if (optHierarchyMode <> hmDate) and StrEqual(vGroup.Domain, vHist.Path) then
                  Continue;

                FFilter.Add(FIdx, FPos, FLen);

                vLen := Length(vHist.Path) + 1;
                if optHierarchyMode <> hmDate then
                  Dec(vLen, Length(vGroup.Name));
                vMaxLen := IntMax(vMaxLen, vLen);
                vMaxHits := IntMax(vMaxHits, vHist.Hits);
              end;
          end;
          vPrevExpanded := vExpanded;
        end;

      finally
        FreeObj(vGroups);
      end;
    end;

  var
    vOpt :TColOptions;
  begin
//  Trace('ReinitGrid...');
    vFilters := TObjList.Create;
    try
      LocPrepareFilters;

      FFilter.Clear;
      vMaxLen := 0;
      vMaxHits := 0;
      FTotalCount := 0;
      FShowCount := 0;

      FHierarchical := optHierarchical;
      FReversed := not optNewAtTop and not optHierarchical;

      if not FHierarchical then
        LocLinear
      else
        LocHierarchical;

    finally
      FreeObj(vFilters);
    end;

    FMenuMaxWidth := vMaxLen + 2;
    vDateLen := Date2StrLen(optDateFormat);
    vHitsLen := Length(Int2Str(vMaxHits));

    if optShowDate then
      Inc(FMenuMaxWidth, vDateLen + 3);
    if optShowHits then
      Inc(FMenuMaxWidth, vHitsLen + 3);

    vOpt := [coColMargin];
    if not optShowGrid then
      vOpt := vOpt + [coNoVertLine];

    FGrid.ResetSize;
    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], 1) );
    if optShowDate then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vDateLen + 2, taRightJustify, vOpt, 2) );
    if optShowHits then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vHitsLen + 2, taRightJustify, vOpt, 3) );

    FSelectedCount := 0;
    FGrid.RowCount := FFilter.Count;

    if optFollowMouse then
      FGrid.Options := FGrid.Options + [goFollowMouse]
    else
      FGrid.Options := FGrid.Options - [goFollowMouse];

    if optWrapMode then
      FGrid.Options := FGrid.Options + [goWrapMode]
    else
      FGrid.Options := FGrid.Options - [goWrapMode];

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TMenuDlg.ReinitAndSaveCurrent;
  var
    vHist :THistoryEntry;
    vIndex :Integer;
  begin
//  SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      vHist := nil;
      vIndex := FGrid.CurRow;
      if (vIndex >= 0) and (vIndex < FGrid.RowCount) then
        vHist := GetHistoryEntry(vIndex);
      if optHierarchical then begin
        if vHist <> nil then
          FDomain := vHist.GetGroup
        else
          FDomain := #0;
      end;

      ReinitGrid;

      vIndex := -1;
      if vHist <> nil then
        vIndex := HistToDlgIndex(vHist);
      if vIndex < 0 then begin
        vIndex := 0;
        if FReversed then
          vIndex := FFilter.Count - 1;
      end;
      SetCurrent( vIndex, lmCenter );
//    UpdateHeader; { Чтобы не стирался SortMark}
    finally
//    SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TMenuDlg.HistToDlgIndex(AHist :THistoryEntry) :Integer;
  var
    I :Integer;
  begin
    Result := -1;
    for I := 0 to FFilter.Count - 1 do
      if GetHistoryEntry(I) = AHist then begin
        Result := I;
        Exit;
      end;
  end;


  function TMenuDlg.DlgItemFlag(AIndex :Integer) :Byte;
  begin
    Result := PFilterRec(FFilter.PItems[AIndex]).FSel
  end;


  function TMenuDlg.DlgItemSelected(AIndex :Integer) :Boolean;
  begin
    Result := DlgItemFlag(AIndex) and 1 <> 0;
  end;


  function TMenuDlg.GetHistoryEntry(ADlgIndex :Integer; AOnlyItem :Boolean = False) :THistoryEntry;
  var
    vRec :PFilterRec;
  begin
    Result := nil;
    if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then begin
      vRec := FFilter.PItems[ADlgIndex];
      if (vRec.FIdx >= 0) and (not AOnlyItem or (vRec.FSel and 2 = 0)) then
        Result := FarHistory[vRec.FIdx];
    end;
  end;


  function TMenuDlg.CurrentHistPath :TString;
  var
    vItem :THistoryEntry;
  begin
    Result := '';
    vItem := GetHistoryEntry(FGrid.CurRow);
    if vItem <> nil then
      Result := vItem.Path;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.ChangeHierarchMode;
  begin
    if not optHierarchical then begin
      optHierarchical := True;
      optHierarchyMode := Low(optHierarchyMode)
    end else
    if optHierarchyMode < High(optHierarchyMode) then begin
      optHierarchyMode := Succ(optHierarchyMode)
    end else
      optHierarchical := False;
    ReinitAndSaveCurrent;
    WriteSetup(FModeName);
  end;


  procedure TMenuDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optSortMode then
      optSortMode := AOrder
    else
      optSortMode := -AOrder;
//  LocReinitAndSaveCurrent;
    ReinitGrid;
//  WriteSetup;
  end;


  function TMenuDlg.GetFilter :TString;
  var
    I :Integer;
  begin
    Result := '';
    for I := FFixedCount to FMaskStack.Count - 1 do
      Result := Result + FMaskStack[I] + '>';
    Result := Result + FFilterMask;
  end;


  procedure TMenuDlg.SetFilter(const AFilter :TString);
  var
    vPos :Integer;
    vStr, vMask :TString;
  begin
    if FMaskStack.Count > 0 then
      FMaskStack.DeleteRange(FFixedCount, FMaskStack.Count - FFixedCount);
      
    vStr := AFilter;
    vPos := ChrPos('>', vStr);
    if vPos > 0 then begin
      repeat
        vMask := Copy(vStr, 1, vPos - 1);
        if vMask <> '' then
          FMaskStack.Add( vMask )
        else
        if FFixedCount = 0 then
          FFixedCount := FMaskStack.Count;
        vStr := Copy(vStr, vPos + 1, MaxInt);
        vPos := ChrPos('>', vStr);
      until vPos = 0;
    end;
    FFilterMask := vStr;
  end;


  procedure TMenuDlg.PrevFilter(APrev :Boolean);
  begin
    if FFilterHist = nil then begin
      FFilterHist := GetHistoryList(cHilterHistName);
      FHistIndex := -1;
    end;

    if APrev then begin
      if FHistIndex < FFilterHist.Count - 1 then
        Inc(FHistIndex)
      else begin
        Beep;
        Exit;
      end;
    end else
    begin
      if FHistIndex > 0 then
        Dec(FHistIndex)
      else begin
        Beep;
        Exit;
      end;
    end;

    SetFilter(FFilterHist[FHistIndex]);
    ReinitAndSaveCurrent;
  end;


  procedure TMenuDlg.QueryFilter;
  var
    vFilter :TFarStr;
  begin
    vFilter := GetFilter;
    if FarInputBox(GetMsg(strFilterTitle), GetMsg(strFilterPrompt), vFilter, FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY, cHilterHistName) then begin
      SetFilter(vFilter);
      ReinitAndSaveCurrent;
      FreeObj(FFilterHist);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.CommandsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCommandsTitle),
    [
      GetMsg(strMShowHidden),
      GetMsg(strMGroupBy),
      '',
      GetMsg(strMAccessTime),
      GetMsg(strMHitCount),
      '',
      GetMsg(strMSortBy),
      GetMsg(strMOptions)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optShowHidden;
        vMenu.Checked[1] := optHierarchical;

        vMenu.Checked[3] := optShowDate;
        vMenu.Checked[4] := optShowHits;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOption(optShowHidden);
          1 : ChangeHierarchMode; {ToggleOption(optHierarchical);}

          3 : ToggleOption(optShowDate);
          4 : ToggleOption(optShowHits);

          6 : SortByMenu;
          7 :
          begin
            OptionsMenu;
            ReinitAndSaveCurrent;
          end;  
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TMenuDlg.SortByMenu;
  var
    vMenu :TFarMenu;
    vRes :Integer;
    vChr :TChar;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strSortByTitle),
    [
      GetMsg(strMByName),
      GetMsg(strMByAccessTime),
      GetMsg(strMByHitCount),
      GetMsg(strMUnsorted)
    ]);

    try
      vRes := Abs(optSortMode) - 1;
      if vRes = -1 then
        vRes := 3;
      vChr := '+';
      if optSortMode < 0 then
        vChr := '-';
      vMenu.Items[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);

      if not vMenu.Run then
        Exit;

      vRes := vMenu.ResIdx;
      Inc(vRes);
      if vRes = 4 then
        vRes := 0;
      if vRes >= 2 then
        vRes := -vRes;
      SetOrder(vRes);

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.SelectItem(ACode :Integer);
  var
    vStr :TString;
    vFlags :Byte;
  begin
    vStr := CurrentHistPath;
    if vStr <> '' then begin

      vFlags := DlgItemFlag(FGrid.CurRow);
      if vFlags and 2 <> 0 then begin
        vStr := GetHistoryEntry(FGrid.CurRow).GetGroup;
        if (ACode = 1) and (vFlags and 4 = 0) then begin
          FDomain := vStr;
          ReinitAndSaveCurrent;
          Exit;
        end;

        if optHierarchyMode = hmDate then
          Exit;

        vStr := GetHistoryEntry(FGrid.CurRow).GetDomain;
      end;

      FResStr := vStr;
      FResCmd := ACode;
      SendMsg(DM_CLOSE, -1, 0);

    end else
      Beep;
  end;


  procedure TMenuDlg.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    ReinitAndSaveCurrent;
    WriteSetup(FModeName);
  end;


  function TMenuDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}

    procedure LocCopySelected;
    var
      I :Integer;
      vStr :TString;
    begin
      if FSelectedCount = 0 then
        FarCopyToClipboard(CurrentHistPath)
      else begin
        vStr := '';
        for I := 0 to FGrid.RowCount - 1 do begin
          if DlgItemSelected(I) then
            with GetHistoryEntry(I) do
              vStr := AppendStrCh(vStr, Path, #13#10);
        end;
        FarCopyToClipboard(vStr);
      end;
    end;


    procedure LocDeleteSelected;
    var
      I :Integer;
      vItem :THistoryEntry;
    begin
      if FSelectedCount = 0 then begin
        vItem := GetHistoryEntry(FGrid.CurRow, True);
        if vItem = nil then
          Exit;
        vItem.SetFlags(vItem.Flags or hfDeleted);
      end else
      begin
        if ShowMessage(GetMsgStr(strConfirmation), GetMsgStr(strDeleteSelectedPrompt), FMSG_MB_YESNO) <> 0 then
          Exit;
        for I := 0 to FGrid.RowCount - 1 do
          if DlgItemSelected(I) then
             with GetHistoryEntry(I) do
               SetFlags(Flags or hfDeleted);
      end;

      for I := FarHistory.History.Count - 1 downto 0 do
        if FarHistory[I].Flags and hfDeleted <> 0 then
          FarHistory.DeleteAt(I);

      ReinitGrid;
      FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
    end;


    procedure LocDeleteHits;
    var
      I :Integer;
      vItem :THistoryEntry;
    begin
      if FSelectedCount = 0 then begin
        vItem := GetHistoryEntry(FGrid.CurRow, True);
        if vItem = nil then
          Exit;
        vItem.HitInfoClear;
      end else
      begin
        if ShowMessage(GetMsgStr(strConfirmation), GetMsgStr(strClearSelectedPrompt), FMSG_MB_YESNO) <> 0 then
          Exit;
        for I := 0 to FGrid.RowCount - 1 do
          if DlgItemSelected(I) then
             with GetHistoryEntry(I) do
               HitInfoClear;
      end;
      FarHistory.SetModified;
      ReinitGrid;
    end;


    procedure LocMarkActual(Actual :Boolean);
    var
      I :Integer;
      vItem :THistoryEntry;
      vStr :TString;
    begin
      if FSelectedCount = 0 then begin
        vItem := GetHistoryEntry(FGrid.CurRow, True);
        if vItem = nil then
          Exit;
        vItem.SetFinal(Actual);
      end else
      begin
        if Actual then
          vStr := GetMsgStr(strMakeActualPrompt)
        else
          vStr := GetMsgStr(strMakeTransitPrompt);
        if ShowMessage(GetMsgStr(strConfirmation), vStr, FMSG_MB_YESNO) <> 0 then
          Exit;
        for I := 0 to FGrid.RowCount - 1 do
          if DlgItemSelected(I) then
            with GetHistoryEntry(I) do
              SetFinal(Actual);
      end;
      FarHistory.SetModified;
      ReinitGrid;
      FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
    end;


    procedure LocSetCheck(AIndex :Integer; ASetOn :Integer);
    var
      vRec :PFilterRec;
      vOldOn :Boolean;
    begin
      vRec := FFilter.PItems[AIndex];
      if (vRec.FIdx < 0) or (vRec.FSel and 2 <> 0) then
        Exit;

      vOldOn := vRec.FSel and 1 <> 0;
      if ASetOn = -1 then
        ASetOn := IntIf(vOldOn, 0, 1);
      if ASetOn = 1 then
        vRec.FSel := vRec.FSel or 1
      else
        vRec.FSel := vRec.FSel and not 1;
      if vOldOn then
        Dec(FSelectedCount);
      if ASetOn = 1 then
        Inc(FSelectedCount);
    end;


    procedure LocSelectCurrent;
    var
      vIndex :Integer;
    begin
      vIndex := FGrid.CurRow;
      if vIndex = -1 then
        Exit;
      LocSetCheck(vIndex, -1);
      if vIndex < FGrid.RowCount - 1 then
        SetCurrent(vIndex + 1, lmScroll);
    end;


    procedure LocSelectAll(AFrom :Integer; ASetOn :Integer);
    var
      I :Integer;
    begin
      for I := AFrom to FGrid.RowCount - 1 do
        LocSetCheck(I, ASetOn);
      SendMsg(DM_REDRAW, 0, 0);
    end;


    procedure LocSetFilter(const ANewFilter :TString);
    begin
      if ANewFilter <> FFilterMask then begin
//      TraceF('Mask: %s', [ANewFilter]);
//      FFilterMode := ANewFilter <> '';
        FFilterMask := ANewFilter;
        ReinitAndSaveCurrent;
        FreeObj(FFilterHist);
      end;
    end;


    procedure PushFilter;
    begin
      if FFilterMask <> '' then begin
        FMaskStack.Add(FFilterMask);
        FFilterMask := '';
        ReinitAndSaveCurrent;
        FreeObj(FFilterHist);
      end else
        Beep;
    end;


    procedure PopFilter;
    begin
      if FMaskStack.Count > FFixedCount then begin
        FMaskStack.Delete(FMaskStack.Count - 1);
        FFilterMask := '';
        ReinitAndSaveCurrent;
        FreeObj(FFilterHist);
      end else
        Beep;
    end;


    procedure LocNextGroup(ANext :Boolean);
    var
      vRow :Integer;
      vRec :PFilterRec;
      vItem :THistoryEntry;
    begin
      if FHierarchical and (FFilter.Count > 0) then begin
        vRec := FFilter.PItems[FGrid.CurRow];
        if vRec.FIdx < 0 then begin
          if ANext then
            SetCurrent(FGrid.CurRow + 1, lmScroll)
          else
            SetCurrent(FGrid.CurRow - 1, lmScroll);
          vRec := FFilter.PItems[FGrid.CurRow];
        end;

        if vRec.FIdx >= 0 then begin
          vItem := FarHistory[vRec.FIdx];
          if StrEqual(vItem.GetGroup, FDomain) then begin
            vRow := FGrid.CurRow;
            repeat
              if ANext then
                Inc(vRow)
              else
                Dec(vRow);
              if (vRow < 0) or (vRow >= FFilter.Count) then
                Exit;

              vItem := GetHistoryEntry(vRow);
              if (vItem <> nil) and not StrEqual(vItem.GetGroup, FDomain) then begin
                SetCurrent(vRow, lmSimple);
                Break;
              end;
            until False;
          end;

          FDomain := vItem.GetGroup;
          ReinitAndSaveCurrent;

        end else
          Beep;
      end;
    end;


  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER, KEY_NUMENTER:
            SelectItem(1);
          KEY_CTRLENTER, KEY_CTRL + KEY_NUMENTER:
            SelectItem(2);

          KEY_F2:
            CommandsMenu;
          KEY_F9: begin
            OptionsMenu;
            ReinitAndSaveCurrent;
          end;

          { Выделение }
          KEY_INS:
            LocSelectCurrent;
          KEY_CTRLADD:
            LocSelectAll(0, 1);
          KEY_CTRLSUBTRACT:
            LocSelectAll(0, 0);
          KEY_CTRLMULTIPLY:
            LocSelectAll(0, -1);
          KEY_ALTADD:
            LocSelectAll(FGrid.CurRow, 1);

          { Операции над выделенными }
          KEY_CTRLINS:
            LocCopySelected;
          KEY_CTRLDEL, KEY_F8:
            LocDeleteSelected;
          KEY_SHIFTF8:
            LocDeleteHits;

          KEY_F5:
            LocMarkActual(False);
          KEY_SHIFTF5:
            LocMarkActual(True);

          { Управление отображением }
          KEY_CTRLH:
            ToggleOption(optShowHidden);

          KEY_CTRLG:
            ChangeHierarchMode; {ToggleOption(optHierarchical);}
          KEY_CTRLI:
            ToggleOption(optNewAtTop);
          KEY_CTRLF:
            QueryFilter;
          KEY_CTRLLEFT:
            PrevFilter(True);
          KEY_CTRLRIGHT:
            PrevFilter(False);
          KEY_CTRLDOWN:
            LocNextGroup(True);
          KEY_CTRLUP:
            LocNextGroup(False);

          KEY_CTRL2:
            ToggleOption(optShowDate);
          KEY_CTRL3:
            ToggleOption(optShowHits);
          KEY_CTRL0:
            ToggleOption(optShowGrid);

          { Сортировка }
          KEY_CTRLF1, KEY_CTRLSHIFTF1:
            SetOrder(1);
          KEY_CTRLF2, KEY_CTRLSHIFTF2:
            SetOrder(-2);
          KEY_CTRLF3, KEY_CTRLSHIFTF3:
            SetOrder(-3);
          KEY_CTRLF11:
            SetOrder(0);
          KEY_CTRLF12:
            SortByMenu;

          { Фильтрация }
          KEY_DEL, KEY_ALT, KEY_RALT:
            LocSetFilter('');
          KEY_BS:
            if FFilterMask <> '' then
              LocSetFilter( Copy(FFilterMask, 1, Length(FFilterMask) - 1));

          KEY_ADD      : LocSetFilter( FFilterMask + '+' );
          KEY_SUBTRACT : LocSetFilter( FFilterMask + '-' );
          KEY_DIVIDE   : LocSetFilter( FFilterMask + '/' );
          KEY_MULTIPLY : LocSetFilter( FFilterMask + '*' );

          KEY_TAB:
            PushFilter;
          KEY_CTRLBS:
            PopFilter;

        else
//        TraceF('Key: %d', [Param2]);
         {$ifdef bUnicodeFar}
          if (Param2 >= 32) and (Param2 < $FFFF) then
         {$else}
          if (Param2 >= 32) and (Param2 <= $FF) then
         {$endif bUnicodeFar}
          begin
           {$ifdef bUnicodeFar}
            LocSetFilter(FFilterMask + WideChar(Param2));
           {$else}
            LocSetFilter(FFilterMask + StrOEMToAnsi(AnsiChar(Param2)));
           {$endif bUnicodeFar}
          end else
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

  var
    vMenuLock :Integer;


  procedure OpenHistoryDlg(const AModeName :TString; AMode :Integer; const AFilter :TString);
  var
    vDlg :TMenuDlg;
    vFinish :Boolean;
    vFilter :TString;
  begin
    if vMenuLock > 0 then
      Exit;

    ReadSetup(AModeName);

    Inc(vMenuLock);
    FarHistory.LockHistory;
    vDlg := TMenuDlg.Create;
    try
      vDlg.FMode := AMode;
      vDlg.FModeName := AModeName;

      vFilter := AFilter;
      if (vFilter = '') and optSaveMask then
        vFilter := FLastFilter;
      vDlg.SetFilter(vFilter);

      FarHistory.LoadModifiedHistory;
      FarHistory.AddCurrentToHistory;

      vFinish := False;
      while not vFinish do begin
        if vDlg.Run = -1 then
          Exit;

        case vDlg.FResCmd of
          1: FarHistory.JumpToPath(vDlg.FResStr);
          2: FarHistory.InsertStr(vDlg.FResStr);
        end;
        vFinish := True;
      end;

    finally
      FreeObj(vDlg);
      FarHistory.UnlockHistory;
      Dec(vMenuLock);
    end;
  end;


end.


{$I Defines.inc}

unit MoreHistoryListBase;

{******************************************************************************}
{* (c) 2009-2011, Max Rusov                                                   *}
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

    Far_API,
    FarCtrl,
    FarGrid,
    FarDlg,
    FarListDlg,
    FarMenu,

    MoreHistoryCtrl,
    MoreHistoryClasses;


  type
    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FIdx :Integer; { Индекс записи истории (для группы - индекс первой записи группы) }
      FPos :Word;    { Позиция быстрого фильтра (для группы - число элементов в группе) }
      FLen :Byte;    { Длина быстрого фильтра }
      FSel :Byte;    { 1 - Selected, 2 - Group, 4 - Expanded Group }
    end;

    TMyFilter = class(TExList)
    public
      constructor Create; override;

      procedure Add(AIndex, APos, ALen :Integer);
      procedure AddGroup(AIndex :Integer; AExpanded :Boolean; ACount :Integer);

    public
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;

    private
      FHistory   :THistory;
      FName      :TString;
      FDomain    :TString;
      FExpanded  :Boolean;
      FItemCount :Integer;

      function GetItems(AIndex :Integer) :Integer;

    public
      property History :THistory read FHistory write FHistory;
      property Name :TString read FName;
      property Domain :TString read FDomain;
      property Items[AIndex :Integer] :Integer read GetItems; default;
    end;


  type
    TMenuBaseDlg = class(TFarListDlg)
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
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;

    protected
      function AcceptSelected(AItem :THistoryEntry; ACode :Integer) :Boolean; virtual;

      function ItemVisible(AItem :THistoryEntry) :Boolean; virtual;
      procedure AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); virtual;
      procedure ReinitColumns; virtual;
      procedure ReinitGrid; virtual;

      function GroupByDomain :Boolean; virtual;
      function ItemMarkUnavailable(ACol :Integer; AItem :THistoryEntry) :Boolean; virtual;
      function ItemMarkHidden(AItem :THistoryEntry) :Boolean; virtual;
      function GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; virtual;

    protected
      FCaption        :TString;
      FModeName       :TString;
      FHistory        :THistory;
      FFilter         :TMyFilter;
//    FFilterMode     :Boolean;
      FMaskStack      :TStrList;
      FTotalCount     :Integer;     { Общее число элементов истории (с учетом Mode и ShowHidden) }
      FShowCount      :Integer;     { Число элементов, попавшее под фильтр }
      FFixedCount     :Integer;
      FFilterMask     :TString;
      FSelectedCount  :Integer;
      FFilterChanged  :Boolean;

      FFilterHist     :TStrList;
      FHistIndex      :Integer;

      FReversed       :Boolean;
      FHierarchical   :Boolean;

      FDomain         :TString;

      FResItem        :THistoryEntry;
      FResStr         :TString;
      FResCmd         :Integer;

      FSetChanged     :Boolean;
      FDrives         :DWORD;
      FTmpDrives      :DWORD;

      function DriveType(const APath :TString) :Integer;

      procedure SelectItem(ACode :Integer);
      procedure DeleteSelected;

      procedure DrawTextEx(X, Y, AWidth :Integer; AChr :PTChar; APos, ALen :Integer; AColor :TFarColor);

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); virtual;

      procedure UpdateHeader;
      procedure ReinitAndSaveCurrent(AItem :THistoryEntry = nil);
      function HistToDlgIndex(AHist :THistoryEntry) :Integer;

      procedure ToggleOption(var AOption :Boolean);
      procedure SetOrder(AOrder :Integer);
      procedure PrevFilter(APrev :Boolean);
      procedure QueryFilter;

      function CurrentHistPath :TString;
      function DlgItemSelected(AIndex :Integer) :Boolean;

    public
      property Grid :TFarGrid read FGrid;
    end;


  function GetBaseTime(ATime :TDateTime) :TDateTime;
  function Date2StrBase(ADate :TDateTime; AMode :Integer; ABase :TDateTime) :TString;
  function Date2StrMode(ADate :TDateTime; AMode :Integer; AOnlyTime :Boolean) :TString;
  function Date2StrLen(AMode :Integer) :Integer;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}

  function GetBaseTime(ATime :TDateTime) :TDateTime;
  var
    vYestaday :TDateTime;
  begin
    Result := Trunc(ATime - EncodeTime(optMidnightHour, 0, 0, 0));
    if opdGroupByPeriod then begin
      vYestaday := Trunc(Now - EncodeTime(optMidnightHour, 0, 0, 0)) - 1;
      if (Result < vYestaday) or (Result - vYestaday >= 2) then
        Result := 0;
    end;
    if Result <> 0 then
      Result := Result + EncodeTime(optMidnightHour, 0, 0, 0);
  end;


  function Date2StrBase(ADate :TDateTime; AMode :Integer; ABase :TDateTime) :TString;
  begin
    if AMode = 0 then begin
      if (ADate >= ABase) and (ADate - ABase < 1) then
        Result := FormatTime('H:mm', ADate)
      else begin
        if ADate > FirstDayOfMonth(Date) then
          Result := FormatDate('ddd,dd', ADate)
        else
          Result := FormatDate('dd/MM', ADate);
//        Result := FormatDate('dd MMM', ADate);
      end;
    end else
      Result := FormatDate('dd.MM.yy', ADate) + ' ' + FormatTime('HH:mm', ADate); //FormatDateTime('dd/mm/yy hh:nn', ADate);
    if ADate = 0 then
      Result := StringOfChar(' ', Length(Result));
  end;


  function Date2StrMode(ADate :TDateTime; AMode :Integer; AOnlyTime :Boolean) :TString;
  begin
    if AMode = 0 then begin
      if AOnlyTime or (Trunc(ADate) = Date) then
        Result := FormatTime('H:mm', ADate)
      else begin
        if ADate > FirstDayOfMonth(Date) then
          Result := FormatDate('ddd,dd', ADate)
        else
          Result := FormatDate('dd/MM', ADate);
//        Result := FormatDate('dd MMM', ADate);
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
//    Result := 6
    else
      Result := 14;
  end;


 {-----------------------------------------------------------------------------}
 { TMyFilter                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TMyFilter.Create; {override;}
  begin
    inherited Create;
    FItemSize  := SizeOf(TFilterRec);
    FItemLimit := MaxInt div FItemSize;
  end;


  procedure TMyFilter.Add(AIndex, APos, ALen :Integer);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := Word(APos);
    vRec.FLen := Byte(ALen);
    vRec.FSel := 0;
    AddData(vRec);
  end;


  procedure TMyFilter.AddGroup(AIndex :Integer; AExpanded :Boolean; ACount :Integer);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := Word(ACount);
    vRec.FLen := 0;
    vRec.FSel := 2;
    if AExpanded then
      vRec.FSel := vRec.FSel or 4;
    AddData(vRec);
  end;


  function TMyFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


  function TMyFilter.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FName, TString(Key));
  end;


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vHst1, vHst2 :THistoryEntry;
  begin
    vHst1 := FHistory[PFilterRec(PItem).FIdx];
    vHst2 := FHistory[PFilterRec(PAnother).FIdx];

    Result := vHst1.CompareObj(vHst2, Abs(Context));

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
  end;


 {-----------------------------------------------------------------------------}
 { TMenuBaseDlg                                                                }
 {-----------------------------------------------------------------------------}

  constructor TMenuBaseDlg.Create; {override;}
  begin
    inherited Create;
    FFilter := TMyFilter.Create;
    FMaskStack := TStrList.Create;
  end;


  destructor TMenuBaseDlg.Destroy; {override;}
  begin
    FreeObj(FFilterHist);
    FreeObj(FMaskStack);
    FreeObj(FFilter);
    inherited Destroy;
  end;


  procedure TMenuBaseDlg.Prepare; {override;}
  begin
    inherited Prepare;

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [{goRowSelect} {,goFollowMouse} {,goWheelMovePos}];
  end;


  procedure TMenuBaseDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);

    FHistory.ClearAvail;

    FDomain := #0;
    ReinitGrid;

    if FReversed then
      SetCurrent(FFilter.Count - 1, lmSafe)
    else begin
      if FHierarchical then
        SetCurrent(1, lmSafe)
    end;
  end;


  function TMenuBaseDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vStr :TString;
  begin
    if FSetChanged then
      WriteSetup(FModeName);
      
    vStr := GetFilter;
    if vStr <> '' then
      FarAddToHistory(cHilterHistName, vStr);
//  FLastFilter := vStr;
    Result := True;
  end;


  procedure TMenuBaseDlg.UpdateHeader;
//const
//  cSorMarks :array[0..5] of TChar = (' ', 'N', 'F', 'M', 'A', 'P');
  var
    I :Integer;
    vMask :TString;
    vTitle :TFarStr;
  begin
    vTitle := FCaption;
    if vTitle = '' then
      vTitle := GetMsgStr(strTitle);

    if (FMaskStack.Count = 0) and (FFilterMask = '') then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else begin
      vMask := '';
      for I := FFixedCount to FMaskStack.Count - 1 do
        vMask := vMask + FMaskStack[I] + ' ' + chrMoreFilter + ' ';
      vMask := vMask + FFilterMask;
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, vMask, FShowCount, FTotalCount ]);
    end;

    if length(vTitle)+2 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle)+2;

    SetText(IdFrame, vTitle);

    vTitle := '';
    if FSelectedCount > 0 then
      vTitle := Int2Str(FSelectedCount);
    SetFooter(vTitle);
  end;


  procedure TMenuBaseDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if (AButton = 1) {and ADouble} then
      SelectItem(1);
  end;


  function TMenuBaseDlg.GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; {virtual;}
  begin
    case AColTag of
//    1 : Result := AItem.Path;
      2 :
        Result := Date2StrMode(AItem.Time, optDateFormat, False);
    else
      Result := '';
    end;
  end;


  function TMenuBaseDlg.ItemMarkUnavailable(ACol :Integer; AItem :THistoryEntry) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TMenuBaseDlg.ItemMarkHidden(AItem :THistoryEntry) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TMenuBaseDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vRec :PFilterRec;
  begin
    Result := '';
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      if vRec.FIdx < 0 then
        Exit;

      if (vRec.FSel and 2 <> 0) and (ACol > 0) {and (vRec.FSel and 4 <> 0)} then
        Exit;

      Result := GetEntryStr(FHistory[vRec.FIdx], FGrid.Column[ACol].Tag)
    end;
  end;


  procedure TMenuBaseDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
  var
    vRec :PFilterRec;
    vItem :THistoryEntry;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];

      if ACol = -1 then begin
        AColor := FGrid.NormColor;
        if vRec.FSel and 1 <> 0 then
          AColor := optSelectedColor;
        if (FGrid.CurRow = ARow) and (FGrid.CurCol = 0) then
          AColor := FGrid.SelColor;
      end else
      begin
        if vRec.FIdx < 0 then
          Exit;

        vItem := FHistory[vRec.FIdx];
        if (vRec.FSel and 2 <> 0) then begin
          if not EqualColor(AColor, FGrid.SelColor) then
            AColor := ChangeFG(AColor, optGroupColor)
        end else
        if optHilightUnavail and ItemMarkUnavailable(ACol, vItem) then
          AColor := ChangeFG(AColor, optUnavailColor)
        else
        if ItemMarkHidden(vItem) {and not vRec.FSel} then
          AColor := ChangeFG(AColor, optHiddenColor)
      end;
    end;
  end;


  procedure TMenuBaseDlg.DrawTextEx(X, Y, AWidth :Integer; AChr :PTChar; APos, ALen :Integer; AColor :TFarColor);

    procedure LocDrawPart(var AChr :PTChar; var ARest :Integer; ALen :Integer; AColor :TFarColor);
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

  begin
    if APos < 0 then begin
      Dec(ALen, -APos);
      APos := 0;
    end;
    if (FFilterMask = '') or (ALen <= 0) then
      LocDrawPart(AChr, AWidth, AWidth, AColor)
    else begin
      LocDrawPart(AChr, AWidth, APos, AColor);
      LocDrawPart(AChr, AWidth, ALen, ChangeFG(AColor, optFoundColor) );
      LocDrawPart(AChr, AWidth, AWidth, AColor);
    end;
  end;


  procedure TMenuBaseDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);
  var
    vRec :PFilterRec;
    vItem :THistoryEntry;
    vStr :TString;
    vDelta :Integer;
  begin
    if (ARow < FFilter.Count) and (FGrid.Column[ACol].Tag = 1) then begin
      vRec := FFilter.PItems[ARow];
      if vRec.FIdx < 0 then
        Exit;

      vItem := FHistory[vRec.FIdx];

      if FHierarchical then begin
        if vRec.FSel and 2 <> 0 then begin

          vStr := vItem.GetGroup(optSortMode);
          FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
          Inc(X, length(vStr)); Dec(AWidth, length(vStr));

          vStr := ' (' + Int2Str(vRec.FPos) + ')';
          if AWidth >= length(vStr) then
            FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, ChangeFG(AColor, optCountColor));

        end else
        if not GroupByDomain then begin
          Inc(X, 1); Dec(AWidth, 1);
          DrawTextEx(X, Y, AWidth, PTChar(vItem.Path), vRec.FPos, vRec.FLen, AColor);
        end else
        begin
          Inc(X, 1); Dec(AWidth, 1);
          vStr := vItem.GetNameWithoutDomain(vDelta);
          DrawTextEx(X, Y, AWidth, PTChar(vStr), vRec.FPos - vDelta, vRec.FLen, AColor);
        end;
      end else
        DrawTextEx(X, Y, AWidth, PTChar(vItem.Path), vRec.FPos, vRec.FLen, AColor);
    end;
  end;


  function TMenuBaseDlg.ItemVisible(AItem :THistoryEntry) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  procedure TMenuBaseDlg.AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); {virtual;}
  var
    vLen, vDelta :Integer;
  begin
    vLen := Length(AItem.Path);
    if AGroup <> nil then begin
      if GroupByDomain then
        vLen := length(AItem.GetNameWithoutDomain(vDelta));
      Inc(vLen); { Отступ в группе }
    end;
    FMenuMaxWidth := IntMax(FMenuMaxWidth, vLen)
  end;


  procedure TMenuBaseDlg.ReinitColumns; {virtual;}
  begin
  end;


  procedure TMenuBaseDlg.ReinitGrid;
  var
    vFilters :TObjList;

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


    procedure LocLinear(AFilter :TMyFilter);
    var
      I, J, vPos, vLen :Integer;
      vHist :THistoryEntry;
    begin
      AFilter.FHistory := FHistory;
      for I := FHistory.History.Count - 1 downto 0 do begin
        J := I;
        if FReversed then
          J := FHistory.History.Count - I - 1;

        vHist := FHistory[J];
        if not ItemVisible(vHist) then
          Continue;

        Inc(FTotalCount);
        vPos := 0; vLen := 0;
        if vFilters.Count > 0 then
          if not CheckFilters(vHist.Path, vPos, vLen) then
            Continue;

        if AFilter = FFilter then
          AcceptItem(vHist, nil);
        AFilter.Add(J, vPos, vLen);
        Inc(FShowCount);
      end;

      if optSortMode <> 0 then
        AFilter.SortList(not FReversed, optSortMode);
    end;


    procedure LocHierarchical;
    var
      I, J :Integer;
      vFilter :TMyFilter;
      vGroups :TObjList;
      vGroup :TMyFilter;
      vHist :THistoryEntry;
      vGroupName :TString;
      vPrevExpanded :Boolean;
    begin
      vFilter := TMyFilter.Create;
      vGroups := TObjList.Create;
      try
        LocLinear(vFilter);

        for I := 0 to vFilter.Count - 1 do begin
          with PFilterRec(vFilter.PItems[I])^ do begin
            vHist := FHistory[FIdx];

            vGroupName := vHist.GetGroup(optSortMode);
            if vGroups.FindKey(Pointer(vGroupName), 0, [], J) then
              vGroup := vGroups[J]
            else begin
              vGroup := TMyFilter.Create;
              vGroup.FHistory := FHistory;
              vGroup.FName := vGroupName;
              vGroup.FDomain := vHist.GetDomain;
              vGroups.Add(vGroup);
              if FDomain = #0 then
                { Автоматически раскрываем первую группу }
                FDomain := vGroupName;
              vGroup.FExpanded := (vFilters.Count > 0) or StrEqual(vGroupName, FDomain);
            end;

            if vGroup.FExpanded or (vGroup.Count = 0) then
              vGroup.Add(FIdx, FPos, FLen);
            Inc(vGroup.FItemCount);
          end;
        end;

        { Больше не нужен - освободим память. }
        FreeObj(vFilter);

        vPrevExpanded := False;
        for I := 0 to vGroups.Count - 1 do begin
          vGroup := vGroups[I];

          with PFilterRec(vGroup.PItems[0])^ do begin
            if vPrevExpanded or (vGroup.FExpanded and (I > 0)) then
              FFilter.Add(-1, 0, 0);
            FFilter.AddGroup(FIdx, vGroup.FExpanded, vGroup.FItemCount);
            FMenuMaxWidth := IntMax(FMenuMaxWidth, Length(vGroup.Name) + Int2StrLen(vGroup.FItemCount) + 3);
          end;

          if vGroup.FExpanded then begin
            for J := 0 to vGroup.Count - 1 do
              with PFilterRec(vGroup.PItems[J])^ do begin
                vHist := FHistory[FIdx];
                if GroupByDomain and False {StrEqual(vGroup.Domain, vHist.Path)} then
                  Continue;
                AcceptItem(vHist, vGroup);
                FFilter.Add(FIdx, FPos, FLen);
              end;
          end;
          vPrevExpanded := vGroup.FExpanded;
        end;

      finally
        FreeObj(vFilter);
        FreeObj(vGroups);
      end;
    end;


  var
    I :Integer;
  begin
//  Trace('ReinitGrid...');
    vFilters := TObjList.Create;
    try
      LocPrepareFilters;

      FFilter.Clear;
      FMenuMaxWidth := 0;
      FTotalCount := 0;
      FShowCount := 0;

      FHierarchical := optHierarchical;
      FReversed := not optNewAtTop and not optHierarchical;

      if not FHierarchical then
        LocLinear(FFilter)
      else
        LocHierarchical;

    finally
      FreeObj(vFilters);
    end;

    FGrid.ResetSize;
    ReinitColumns;

    Inc(FMenuMaxWidth, 2);
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );

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
  end; {ReinitGrid}



  procedure TMenuBaseDlg.ReinitAndSaveCurrent(AItem :THistoryEntry = nil);
  var
    vIndex :Integer;
  begin
    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      if AItem = nil then begin
        vIndex := FGrid.CurRow;
        if (vIndex >= 0) and (vIndex < FGrid.RowCount) then
          AItem := GetHistoryEntry(vIndex);
      end;

      if optHierarchical then begin
        if AItem <> nil then
          FDomain := AItem.GetGroup(optSortMode)
        else
          FDomain := #0;
      end;

      ReinitGrid;

      vIndex := -1;
      if AItem <> nil then
        vIndex := HistToDlgIndex(AItem);
      if vIndex < 0 then begin
        vIndex := 0;
        if FReversed then
          vIndex := FFilter.Count - 1;
      end;
      SetCurrent( vIndex, lmCenter );
//    UpdateHeader; { Чтобы не стирался SortMark}
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TMenuBaseDlg.HistToDlgIndex(AHist :THistoryEntry) :Integer;
  var
    I :Integer;
  begin
    Result := -1;
    for I := 0 to FFilter.Count - 1 do
      if GetHistoryEntry(I, not GroupByDomain) = AHist then begin
        Result := I;
        Exit;
      end;
  end;


  function TMenuBaseDlg.DlgItemFlag(AIndex :Integer) :Byte;
  begin
    Result := PFilterRec(FFilter.PItems[AIndex]).FSel
  end;


  function TMenuBaseDlg.DlgItemSelected(AIndex :Integer) :Boolean;
  begin
    Result := DlgItemFlag(AIndex) and 1 <> 0;
  end;


  function TMenuBaseDlg.GetHistoryEntry(ADlgIndex :Integer; AOnlyItem :Boolean = False) :THistoryEntry;
  var
    vRec :PFilterRec;
  begin
    Result := nil;
    if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then begin
      vRec := FFilter.PItems[ADlgIndex];
      if (vRec.FIdx >= 0) and (not AOnlyItem or (vRec.FSel and 2 = 0)) then
        Result := FHistory[vRec.FIdx];
    end;
  end;


  function TMenuBaseDlg.CurrentHistPath :TString;
  var
    vItem :THistoryEntry;
  begin
    Result := '';
    vItem := GetHistoryEntry(FGrid.CurRow);
    if vItem <> nil then
      Result := vItem.Path;
  end;


 {-----------------------------------------------------------------------------}

  function TMenuBaseDlg.GroupByDomain :Boolean; {virtual;}
  begin
    Result := False;
  end;


(*
  procedure TMenuBaseDlg.ChangeHierarchMode; {virtual;}
  var
    vMenu :TFarMenu;
    vMode :THierarchyMode;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strGroupByTitle),
    [
      GetMsg(strMGroupByPeriod),
      GetMsg(strMGroupByDate),
      GetMsg(strMGroupByFolder),
      '',
      GetMsg(strMGroupNone)
    ]);
    try
      while True do begin
        for vMode := Low(THierarchyMode) to High(THierarchyMode) do
          vMenu.Checked[byte(vMode)] := optHierarchical and (vMode = optHierarchyMode);
        vMenu.Checked[4] := not optHierarchical;
        vMenu.SetSelected(IntIf(optHierarchical, Integer(optHierarchyMode), 4));

        if not vMenu.Run then
          Break;

        if vMenu.ResIdx = 4 then begin
          if optHierarchical then begin
            optHierarchical := False;
            ReinitAndSaveCurrent;
            FSetChanged := True;
          end;
        end else
        begin
          vMode := THierarchyMode(vMenu.ResIdx);
          if (vMode <> optHierarchyMode) or not optHierarchical then begin
            optHierarchical := True;
            optHierarchyMode := vMode;
            ReinitAndSaveCurrent;
            FSetChanged := True;
          end;
        end;
      end;
    finally
      FreeObj(vMenu);
    end;
  end;
*)

  procedure TMenuBaseDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optSortMode then
      optSortMode := AOrder
    else
      optSortMode := -AOrder;
    FDomain := #0;
//  LocReinitAndSaveCurrent;
    ReinitGrid;
    FSetChanged := True;
  end;


  function TMenuBaseDlg.GetFilter :TString;
  var
    I :Integer;
  begin
    Result := '';
    for I := FFixedCount to FMaskStack.Count - 1 do
      Result := Result + FMaskStack[I] + '>';
    Result := Result + FFilterMask;
  end;


  procedure TMenuBaseDlg.SetFilter(const AFilter :TString);
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


  procedure TMenuBaseDlg.PrevFilter(APrev :Boolean);
  begin
   {$ifdef Far3}
    {!!!}
   {$else}
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
   {$endif Far3}
  end;


  procedure TMenuBaseDlg.QueryFilter;
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

  procedure TMenuBaseDlg.SelectItem(ACode :Integer);
  var
    vItem :THistoryEntry;
    vStr :TString;
    vFlags :Byte;
  begin
    vItem := GetHistoryEntry(FGrid.CurRow);
    if vItem <> nil then begin

      vFlags := DlgItemFlag(FGrid.CurRow);
      if vFlags and 2 <> 0 then begin
        vStr := vItem.GetGroup(optSortMode);
        if (ACode = 1) and (vFlags and 4 = 0) then begin
          FDomain := vStr;
          ReinitAndSaveCurrent;
          Exit;
        end;
        if not GroupByDomain then
          Exit;
      end;

      try
        if AcceptSelected(vItem, ACode) then
          SendMsg(DM_CLOSE, -1, 0);
      except
        on E :Exception do
          ErrorHandler(E);
      end;

    end else
      Beep;
  end;


  function TMenuBaseDlg.AcceptSelected(AItem :THistoryEntry; ACode :Integer) :Boolean; {virtual;}
  begin
    FResItem := AItem;
    FResStr := AItem.Path;
    FResCmd := ACode;
    Result := True;
  end;


  procedure TMenuBaseDlg.DeleteSelected;
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

    for I := FHistory.History.Count - 1 downto 0 do
      if FHistory[I].Flags and hfDeleted <> 0 then
        FHistory.DeleteAt(I);

    ReinitGrid;
    FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
  end;


  function TMenuBaseDlg.DriveType(const APath :TString) :Integer;
  const
    cMaxDrives = 26; { a..z }
  var
    i :Integer;
    vDType :UINT;
    vDrives :DWORD;
    vDriveStr :array[0..3] of TChar;
  begin
    Result := 0;
    if APath = '' then
      Exit;

    if FDrives = 0 then begin
      StrPCopy(@vDriveStr[0], '?:\');
      FTmpDrives := 0;
      vDrives := GetLogicalDrives;
      for I := 0 to cMaxDrives - 1 do
        if (1 shl I) and vDrives <> 0 then begin
          FDrives := FDrives or (1 shl I);
          vDriveStr[0] := TChar(Ord('A') + I);
          vDType := GetDriveType(@vDriveStr[0]);
          if vDType in [DRIVE_REMOVABLE, DRIVE_CDROM {, DRIVE_REMOTE} ] then
            FTmpDrives := FTmpDrives or (1 shl I);
        end;
    end;

    i := Ord(CharUpCase(APath[1])) - Ord('A');
    if (i >= 0) and (i < cMaxDrives) then
      if (1 shl i) and FDrives <> 0 then
        if (1 shl i) and FTmpDrives <> 0 then
          Result := 2 { Не проверяем }
        else
          Result := 1;
  end;


  procedure TMenuBaseDlg.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    ReinitAndSaveCurrent;
    FSetChanged := True;
  end;


  function TMenuBaseDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

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
      UpdateHeader;
    end;


    procedure LocSelectAll(AFrom :Integer; ASetOn :Integer);
    var
      I :Integer;
    begin
      for I := AFrom to FGrid.RowCount - 1 do
        LocSetCheck(I, ASetOn);
      UpdateHeader;
      SendMsg(DM_REDRAW, 0, 0);
    end;


    procedure LocSelectUnavail;
    var
      I :Integer;
      vItem :THistoryEntry;
    begin
      for I := 0 to FGrid.RowCount - 1 do
        if DlgItemFlag(I) and 2 = 0 then begin
          vItem := GetHistoryEntry(I);
          if (vItem <> nil) and ItemMarkUnavailable(-1, vItem) then
            LocSetCheck(I, 1);
        end;
      UpdateHeader;
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
        FFilterMask := FMaskStack[FMaskStack.Count - 1];
        FMaskStack.Delete(FMaskStack.Count - 1);
        ReinitAndSaveCurrent;
        FreeObj(FFilterHist);
      end else
      if FFilterMask <> '' then
        LocSetFilter('')
      else
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
          vItem := FHistory[vRec.FIdx];
          if StrEqual(vItem.GetGroup(optSortMode), FDomain) then begin
            vRow := FGrid.CurRow;
            repeat
              if ANext then
                Inc(vRow)
              else
                Dec(vRow);
              if (vRow < 0) or (vRow >= FFilter.Count) then
                Exit;

              vItem := GetHistoryEntry(vRow);
              if (vItem <> nil) and not StrEqual(vItem.GetGroup(optSortMode), FDomain) then begin
                SetCurrent(vRow, lmSimple);
                Break;
              end;
            until False;
          end;

          FDomain := vItem.GetGroup(optSortMode);
          ReinitAndSaveCurrent;

        end else
          Beep;
      end;
    end;

  begin
    Result := True;

    case AKey of
      KEY_BS, KEY_ADD, KEY_SUBTRACT, KEY_DIVIDE, KEY_MULTIPLY, 32..$FFFF:
        if not FFilterChanged then begin
          FFilterMask := '';
          if AKey = KEY_BS then
            FFilterMask := '?';
          FFilterChanged := True;
        end;
    end;

    case AKey of
      KEY_ENTER, KEY_NUMENTER:
        SelectItem(1);
      KEY_CTRLENTER, KEY_CTRL + KEY_NUMENTER:
        SelectItem(2);
      KEY_CTRLPGDN:
        SelectItem(3);

      KEY_SHIFTF9: begin
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
      KEY_ALTSUBTRACT:
        LocSelectAll(FGrid.CurRow, 0);
      KEY_CTRL+KEY_DIVIDE:
        LocSelectUnavail;

      { Операции над выделенными... }
      KEY_CTRLINS:
        LocCopySelected;
      KEY_CTRLDEL, KEY_F8:
        DeleteSelected;

      { Управление отображением }
      KEY_CTRLH:
        ToggleOption(optShowUnavail);

      KEY_CTRLG:
//      ChangeHierarchMode;
        ToggleOption(optHierarchical);
      KEY_CTRLSHIFTG:
        ToggleOption(optHierarchical);
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
//      TraceF('Key: %d', [Param2]);
        if (AKey >= 32) and (AKey < $FFFF) then
          LocSetFilter(FFilterMask + WideChar(AKey))
        else
          Result := inherited KeyDown(AID, AKey);
    end;
  end;


end.


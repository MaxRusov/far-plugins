{$I Defines.inc}

unit MoreHistoryDlg;

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
    MixWinUtils,
    
    Far_API,
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
    TFldMenuDlg = class(TMenuBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      function AcceptSelected(AItem :THistoryEntry; ACode :Integer) :Boolean; override;
      function ItemVisible(AItem :THistoryEntry) :Boolean; override;
      procedure AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); override;
      procedure ReinitColumns; override;
      procedure ReinitGrid; override;

      function GroupByDomain :Boolean; override;
      function ItemMarkUnavailable(ACol :Integer; AItem :THistoryEntry) :Boolean; override;
      function GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;

    private
      FMode     :Integer;
      FMaxHits  :Integer;
      FMaxHits2 :Integer;
      FResStr2  :TString;

      function CheckFolderExists(var AName :TString) :Boolean;

      procedure ClearSelectedHits;
      procedure MarkSelected(Actual :Boolean);

      procedure CommandsMenu;
      procedure ProfileMenu;
      procedure SortByMenu;
    end;


  var
    FFolderLastFilter :TString;

  procedure JumpToPathBy(AItem :TFldHistoryEntry; ASetPassive :Boolean = False; AddHistory :Boolean = True);

  function HistDlgOpened :Boolean;

  procedure OpenHistoryDlg1(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString = '';
    AGroupMode :Integer = MaxInt; ASortMode :Integer = MaxInt; AShowHidden :Integer = MaxInt);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFldMenuDlg                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFldMenuDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FGUID := cFoldersDlgID;
    FHelpTopic := 'HistoryList';
  end;


  destructor TFldMenuDlg.Destroy; {override;}
  begin
    UnregisterHints;
    inherited Destroy;
  end;


  function TFldMenuDlg.AcceptSelected(AItem :THistoryEntry; ACode :Integer) :Boolean; {override;}
  var
    vName :TString;
  begin
    Result := False;
    vName := AItem.Path;
    if ACode <> 2 then
      if IsFullFilePath(vName) then
        if not CheckFolderExists(vName) then
          Exit;

    Result := inherited AcceptSelected(AItem, ACode);

    if StrEqual(FResStr, vName) then
      FResStr2 := (AItem as TFldHistoryEntry).ItemName
    else
      FResStr := vName;
  end;


  function TFldMenuDlg.CheckFolderExists(var AName :TString) :Boolean;
  var
    vRes :Integer;
    vFolder :TString;
  begin
    Result := True;
    if not WinFolderExists(AName) then begin

      vFolder := GetNearestExistFolder(AName);

      if vFolder <> '' then begin

        vRes := ShowMessageBut(GetMsgStr(strConfirmation),
          GetMsgStr(strFolderNotFound) + #10 + AName + #10 +
          GetMsgStr(strNearestFolderIs) + #10 + vFolder,
          [GetMsgStr(strGotoNearestBut), GetMsgStr(strCreateFolderBut), GetMsgStr(strDeleteBut), GetMsgStr(strCancel)],
          FMSG_WARNING);

        case vRes of
          0: AName := vFolder;
          1:
          begin
            if not CreateFolders(AName) then
              AppError(GetMsgStr(strCannotCreateFolder) + #10 + AName);
          end;
          2:
          begin
            Result := False;
            DeleteSelected;
          end;
        else
          Result := False;
        end;

      end else
      begin

        vRes := ShowMessageBut(GetMsgStr(strConfirmation),
          GetMsgStr(strFolderNotFound) + #10 + AName,
          [GetMsgStr(strDeleteBut), GetMsgStr(strCancel)],
          FMSG_WARNING);

        case vRes of
          0:
          begin
            Result := False;
            DeleteSelected;
          end;
        else
          Result := False;
        end;
      end;

    end;
  end;



  function TFldMenuDlg.ItemVisible(AItem :THistoryEntry) :Boolean; {override;}
  var
    vItem :TFldHistoryEntry;
  begin
    Result := False;
    vItem := AItem as TFldHistoryEntry;
    if (FMode = 1) and not vItem.IsActive then
      Exit;
    if optHideCurrent and StrEqual(GLastAdded, vItem.Path) then
      Exit;
    if not optShowUnavail then
      if ItemMarkUnavailable(0, AItem) then
        Exit;
    Result := True;
  end;


  procedure TFldMenuDlg.AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); {override;}
  begin
    Assert(AItem is TFldHistoryEntry);
    inherited AcceptItem(AItem, AGroup);
    FMaxHits := IntMax(FMaxHits, TFldHistoryEntry(AItem).Hits);
    FMaxHits2 := IntMax(FMaxHits2, TFldHistoryEntry(AItem).ActCount);
  end;


  procedure TFldMenuDlg.ReinitColumns; {override;}
  var
    vOpt :TColOptions;
    vDateLen, vHitsLen, vHits2Len :Integer;
  begin
    vDateLen := Date2StrLen(optDateFormat);
    vHitsLen := Int2StrLen(FMaxHits);
    vHits2Len := Int2StrLen(FMaxHits2);

    vOpt := [coColMargin];
    if not optShowGrid then
      vOpt := vOpt + [coNoVertLine];

    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], 1) );
    if optShowDate then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vDateLen + 2, taRightJustify, vOpt, 2) );
    if optShowHits then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vHitsLen + 2, taRightJustify, vOpt, 3) );
    if optShowModify then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vDateLen + 2, taRightJustify, vOpt, 4) );
    if optShowSaves then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vHits2Len + 2, taRightJustify, vOpt, 5) );
  end;


  procedure TFldMenuDlg.ReinitGrid; {override;}
  begin
    FMaxHits := 0;
    FMaxHits2 := 0;
    inherited ReinitGrid;
  end;


 {-----------------------------------------------------------------------------}

  function TFldMenuDlg.GroupByDomain :Boolean; {override;}
  begin
    Result := optHierarchical and (Abs(optSortMode) = 1);
  end;



  function TFldMenuDlg.ItemMarkUnavailable(ACol :Integer; AItem :THistoryEntry) :Boolean; {override;}
  var
    vType :Integer;
  begin
    if (ACol = -1) or (ACol = 0) then begin
      if AItem.Avail = 0 then begin
        AItem.Avail := 1;
        if FileNameIsLocal(AItem.Path) {IsFullFilePath(vItem.Path)} then begin
          vType := DriveType(AItem.Path);
          if vType = 0 then
            { Отсутствует }
            AItem.Avail := 2
          else
          if vType = 2 then
            { Не проверяем }
            AItem.Avail := 1
          else begin
            if not WinFolderExists(AItem.Path) then begin
//            Trace(AItem.Path);
              AItem.Avail := 2;
            end;
          end;
        end;
      end;
      Result := AItem.Avail = 2;
    end else
      Result := False;
  end;


  function TFldMenuDlg.GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; {override;}
  var
    vItem :TFldHistoryEntry;

    function LocGetBaseTime :TDateTime;
    begin
      Result := Date;
      if optHierarchical then
        case Abs(optSortMode) of
          0, 2 : Result := GetBaseTime(vItem.Time);
          4    : Result := GetBaseTime(vItem.ActTime);
        end;
    end;

  begin
    vItem := AItem as TFldHistoryEntry;
    case AColTag of
      2: Result := Date2StrBase(vItem.Time, optDateFormat, LocGetBaseTime);
      3: Result := Int2Str(vItem.Hits);
      4: Result := Date2StrBase(vItem.ActTime, optDateFormat, LocGetBaseTime);
      5: Result := Int2Str(vItem.ActCount);
    else
      Result := inherited GetEntryStr(AItem, AColTag);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFldMenuDlg.CommandsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCommandsTitle),
    [
      GetMsg(strMOpen),
      '',
      GetMsg(strMMarkTranzit),
      GetMsg(strMMarkActual),
      '',
      GetMsg(strMDelete),
      GetMsg(strMClearHitCount),
      '',
      GetMsg(strMOptions)
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : SelectItem(1);

        2 : MarkSelected(False);
        3 : MarkSelected(True);

        5 : DeleteSelected;
        6 : ClearSelectedHits;

        8 : ProfileMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TFldMenuDlg.ProfileMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle1),
    [
      GetMsg(strMGroupBy),
      GetMsg(strMShowUnavail),
      '',
      GetMsg(strMAccessTime),
      GetMsg(strMHitCount),
      GetMsg(strMActionTime),
      GetMsg(strMActionCount),
      '',
      GetMsg(strMSortBy)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optHierarchical;
        vMenu.Checked[1] := optShowUnavail;

        vMenu.Checked[3] := optShowDate;
        vMenu.Checked[4] := optShowHits;
        vMenu.Checked[5] := optShowModify;
        vMenu.Checked[6] := optShowSaves;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOption(optHierarchical); 
          1 : ToggleOption(optShowUnavail);

          3 : ToggleOption(optShowDate);
          4 : ToggleOption(optShowHits);
          5 : ToggleOption(optShowModify);
          6 : ToggleOption(optShowSaves);

          8 : SortByMenu;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TFldMenuDlg.SortByMenu;
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
      GetMsg(strMByActionTime),
      GetMsg(strMByActionCount),
      GetMsg(strMUnsorted)
    ]);

    try
      vRes := Abs(optSortMode) - 1;
      if vRes = -1 then
        vRes := vMenu.Count - 1;
      vChr := '+';
      if optSortMode < 0 then
        vChr := '-';
      vMenu.Items[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);

      if not vMenu.Run then
        Exit;

      vRes := vMenu.ResIdx;
      Inc(vRes);
      if vRes = vMenu.Count then
        vRes := 0;
      if vRes >= 2 then
        vRes := -vRes;
      SetOrder(vRes);

    finally
      FreeObj(vMenu);
    end;
  end;

 {-----------------------------------------------------------------------------}

  procedure TFldMenuDlg.ClearSelectedHits;
  var
    I :Integer;
    vItem :TFldHistoryEntry;
  begin
    if FSelectedCount = 0 then begin
      vItem := GetHistoryEntry(FGrid.CurRow, True) as TFldHistoryEntry;
      if vItem = nil then
        Exit;
      vItem.HitInfoClear;
    end else
    begin
      if ShowMessage(GetMsgStr(strConfirmation), GetMsgStr(strClearSelectedPrompt), FMSG_MB_YESNO) <> 0 then
        Exit;
      for I := 0 to FGrid.RowCount - 1 do
        if DlgItemSelected(I) then
           with GetHistoryEntry(I) as TFldHistoryEntry do
             HitInfoClear;
    end;
    FldHistory.SetModified;
    ReinitGrid;
  end;


  procedure TFldMenuDlg.MarkSelected(Actual :Boolean);
  var
    I :Integer;
    vItem :TFldHistoryEntry;
    vStr :TString;
  begin
    if FSelectedCount = 0 then begin
      vItem := GetHistoryEntry(FGrid.CurRow, True) as TFldHistoryEntry;
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
          with GetHistoryEntry(I) as TFldHistoryEntry do
            SetFinal(Actual);
    end;
    FldHistory.SetModified;
    ReinitGrid;
    FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
  end;


  function TFldMenuDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      KEY_F2:
        CommandsMenu;
      KEY_F9:
        ProfileMenu;
      KEY_CTRLF12:
        SortByMenu;

      KEY_SHIFTF8:
        ClearSelectedHits;

      KEY_F5:
        MarkSelected(False);
      KEY_SHIFTF5:
        MarkSelected(True);

      KEY_CTRL2:
        ToggleOption(optShowDate);
      KEY_CTRL3:
        ToggleOption(optShowHits);
      KEY_CTRL4:
        ToggleOption(optShowModify);
      KEY_CTRL5:
        ToggleOption(optShowSaves);

      { Сортировка }
      KEY_CTRLF4, KEY_CTRLSHIFTF4:
        SetOrder(-4);
      KEY_CTRLF5, KEY_CTRLSHIFTF5:
        SetOrder(-5);
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure JumpToPathBy(AItem :TFldHistoryEntry; ASetPassive :Boolean = False; AddHistory :Boolean = True);
  begin
    JumpToPath(AItem.Path, AItem.ItemName, ASetPassive, AddHistory);
  end;


  var
    vMenuLock :Integer;


  function HistDlgOpened :Boolean;
  begin
    Result := vMenuLock > 0;
  end;


  procedure OpenHistoryDlg1(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString = '';
    AGroupMode :Integer = MaxInt; ASortMode :Integer = MaxInt; AShowHidden :Integer = MaxInt);
  var
    vDlg :TFldMenuDlg;
    vFinish :Boolean;
    vFilter :TString;
  begin
    if vMenuLock > 0 then
      Exit;

    FldHistory.AddCurrentToHistory;

    optShowUnavail  := True;
    optSeparateName := False;
    optShowFullPath := True;
    optHierarchical := True;
    if AMode = 0 then begin
      optShowDate    := True;
      optShowHits    := False;
      optShowModify  := True;
      optShowSaves   := False;
      optSortMode    := 0; {Default}
    end else
    begin
      optShowDate    := False;
      optShowHits    := False;
      optShowModify  := True;
      optShowSaves   := False;
      optSortMode    := -4; {By ActTime}
      ReadSetup(AModeName);
    end;

    ReadSetup(AModeName);

    Inc(vMenuLock);
    FldHistory.LockHistory;
    vDlg := TFldMenuDlg.Create;
    try
      vDlg.FCaption := ACaption;
      vDlg.FHistory := FldHistory;
      vDlg.FMode := AMode;
      vDlg.FModeName := AModeName;

      vFilter := AFilter;
      if (vFilter = '') and optSaveMask then
        vFilter := FFolderLastFilter;
      if vFilter = #0 then
        vFilter := '';
      vDlg.SetFilter(vFilter);

      if AGroupMode <> MaxInt then begin
        optHierarchical := AGroupMode in [1..3];
(*      if optHierarchical then
          optHierarchyMode := THierarchyMode(AGroupMode - 1);  *)
      end;

      if ASortMode <> MaxInt then
        optSortMode := ASortMode;
(*
      if AShowHidden <> MaxInt then
        optShowHidden := AShowHidden <> 0;
*)
      vFinish := False;
      while not vFinish do begin
        if vDlg.Run = -1 then
          Exit;

        case vDlg.FResCmd of
//        1: JumpToPathBy(vDlg.FResItem as TFldHistoryEntry);
          1: JumpToPath(vDlg.FResStr, vDlg.FResStr2, False, True);  { Может быть FResStr <> AItem.Path, если каталог не существует... }
          2: InsertText(vDlg.FResStr);
          3: JumpToPath(RemoveBackSlash(ExtractFilePath(vDlg.FResStr)), ExtractFileName(vDlg.FResStr), False);
        end;
        vFinish := True;
      end;

    finally
      FFolderLastFilter := vDlg.GetFilter;
      FreeObj(vDlg);
      FldHistory.UnlockHistory;
      Dec(vMenuLock);
    end;
  end;


end.




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
    PluginW,
    FarKeysW,
    
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

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
    TFldMenuDlg = class(TMenuBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      function ItemVisible(AItem :THistoryEntry) :Boolean; override;
      procedure AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); override;
      procedure ReinitColumns; override;
      procedure ReinitGrid; override;

      function ItemMarkHidden(AItem :THistoryEntry) :Boolean; override;
      function GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; override;

      procedure ChangeHierarchMode; override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FMode    :Integer;
      FMaxHits :Integer;

      procedure ClearSelectedHits;
      procedure MarkSelected(Actual :Boolean);

      procedure CommandsMenu;
      procedure ProfileMenu;
      procedure SortByMenu;
    end;


  function HistDlgOpened :Boolean;

  procedure OpenHistoryDlg(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString);

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
  end;


  destructor TFldMenuDlg.Destroy; {override;}
  begin
    UnregisterHints;
    inherited Destroy;
  end;


  function TFldMenuDlg.ItemVisible(AItem :THistoryEntry) :Boolean; {override;}
  var
    vItem :TFldHistoryEntry;
  begin
    Result := False;
    vItem := AItem as TFldHistoryEntry;
    if (FMode <> 0) and (vItem.GetMode <> FMode) then
      Exit;
    if not optShowHidden and not vItem.IsFinal then
      Exit;
    if optHideCurrent and StrEqual(GLastAdded, vItem.Path) then
      Exit;
    Result := True;
  end;


  procedure TFldMenuDlg.AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); {override;}
  begin
    inherited AcceptItem(AItem, AGroup);
    FMaxHits := IntMax(FMaxHits, (AItem as TFldHistoryEntry).Hits);
  end;


  procedure TFldMenuDlg.ReinitColumns; {override;}
  var
    vOpt :TColOptions;
    vDateLen, vHitsLen :Integer;
  begin
    vDateLen := Date2StrLen(optDateFormat);
    vHitsLen := Length(Int2Str(FMaxHits));

    vOpt := [coColMargin];
    if not optShowGrid then
      vOpt := vOpt + [coNoVertLine];

    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], 1) );
    if optShowDate then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vDateLen + 2, taRightJustify, vOpt, 2) );
    if optShowHits then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vHitsLen + 2, taRightJustify, vOpt, 3) );
  end;


  procedure TFldMenuDlg.ReinitGrid; {override;}
  begin
    FMaxHits := 0;
    inherited ReinitGrid;
  end;


 {-----------------------------------------------------------------------------}

  function TFldMenuDlg.ItemMarkHidden(AItem :THistoryEntry) :Boolean; {override;}
  begin
    Result := not (AItem as TFldHistoryEntry).IsFinal;
  end;


  function TFldMenuDlg.GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; {override;}
  begin
    if AColTag = 3 then
      Result := Int2Str((AItem as TFldHistoryEntry).Hits)
    else
      Result := inherited GetEntryStr(AItem, AColTag);
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
      GetMsg(strMShowHidden),
      '',
      GetMsg(strMAccessTime),
      GetMsg(strMHitCount),
      '',
      GetMsg(strMSortBy)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optHierarchical;
        vMenu.Checked[1] := optShowHidden;

        vMenu.Checked[3] := optShowDate;
        vMenu.Checked[4] := optShowHits;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ChangeHierarchMode;
          1 : ToggleOption(optShowHidden);

          3 : ToggleOption(optShowDate);
          4 : ToggleOption(optShowHits);

          6 : SortByMenu;
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

  procedure TFldMenuDlg.ChangeHierarchMode; {override;}
  begin
    if not optHierarchical then begin
      optHierarchical := True;
      optHierarchyMode := hmDate;
    end else
    if optHierarchyMode <> hmDomain then begin
      optHierarchyMode := hmDomain
    end else
      optHierarchical := False;
    ReinitAndSaveCurrent;
    WriteSetup(FModeName);
  end;


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


  function TFldMenuDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_KEY: begin
        case Param2 of
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

  var
    vMenuLock :Integer;

    
  function HistDlgOpened :Boolean;
  begin
    Result := vMenuLock > 0;
  end;


  procedure OpenHistoryDlg(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString);
  var
    vDlg :TFldMenuDlg;
    vFinish :Boolean;
    vFilter :TString;
  begin
    if vMenuLock > 0 then
      Exit;

    optShowHidden := False;
    optSeparateName := False;
    optShowFullPath := True;
    optHierarchical := True;
    optHierarchyMode := hmDate;
    optShowDate := True;
    optShowHits := False;
    optSortMode := 0;

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
        vFilter := FLastFilter;
      vDlg.SetFilter(vFilter);

      FldHistory.AddCurrentToHistory;

      vFinish := False;
      while not vFinish do begin
        if vDlg.Run = -1 then
          Exit;

        case vDlg.FResCmd of
          1: JumpToPath(vDlg.FResStr, '');
          2: InsertText(vDlg.FResStr);
          3: JumpToPath(ExtractFilePath(vDlg.FResStr), ExtractFileName(vDlg.FResStr));
        end;
        vFinish := True;
      end;

    finally
      FreeObj(vDlg);
      FldHistory.UnlockHistory;
      Dec(vMenuLock);
    end;
  end;


end.


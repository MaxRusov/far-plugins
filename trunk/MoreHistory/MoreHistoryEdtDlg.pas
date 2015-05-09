{$I Defines.inc}

unit MoreHistoryEdtDlg;

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
    TEdtMenuDlg = class(TMenuBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      function AcceptSelected(AItem :THistoryEntry; ACode :Integer) :Boolean; override;
      function ItemVisible(AItem :THistoryEntry) :Boolean; override;
      procedure AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); override;
      procedure ReinitColumns; override;
      procedure ReinitGrid; override;

      function ItemMarkUnavailable(ACol :Integer; AItem :THistoryEntry) :Boolean; override;
      function ItemMarkHidden(AItem :THistoryEntry) :Boolean; override;
      function GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;

    private
      FMode       :Integer;
      FMaxHits    :Integer;
      FMaxSaves   :Integer;
      FMaxFileLen :Integer;
      FMaxPathLen :Integer;

      function CheckFileExists(const AFileName :TString) :Boolean;
      procedure ViewOrEditCurrent(AEdit :Boolean);

      procedure CommandsMenu;
      procedure ProfileMenu;
      procedure SortByMenu;
    end;


  var
    FFilesLastFilter :TString;

  procedure OpenEditorBy(AItem :TEdtHistoryEntry; AModified :Boolean);

  procedure OpenEdtHistoryDlg1(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString = '';
    AGroupMode :Integer = MaxInt; ASortMode :Integer = MaxInt; AShowHidden :Integer = MaxInt);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TEdtMenuDlg                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TEdtMenuDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FGUID := cFilesDlgID;
    FHelpTopic := 'EdtHistoryList';
  end;


  destructor TEdtMenuDlg.Destroy; {override;}
  begin
    UnregisterHints;
    inherited Destroy;
  end;


  function TEdtMenuDlg.AcceptSelected(AItem :THistoryEntry; ACode :Integer) :Boolean; {override;}
  begin
    Result := False;
    if ACode <> 2 then
      if not CheckFileExists(AItem.Path) then
        Exit;

    Result := inherited AcceptSelected(AItem, ACode);
  end;


  function TEdtMenuDlg.ItemVisible(AItem :THistoryEntry) :Boolean; {override;}
  begin
    Result :=
      ((FMode = 0) or ((AItem as TEdtHistoryEntry).EdtTime <> 0)) and
      ((optShowView) or (AItem.Flags and hfEdit <> 0));

    if Result and not optShowUnavail then
      if ItemMarkUnavailable(-1, AItem) then
        Result := False;
  end;


  procedure TEdtMenuDlg.AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); {override;}
  var
    vPos :Integer;
  begin
    if optSeparateName or not optShowFullPath then begin
      vPos := LastDelimiter('\:', AItem.Path);
      FMaxFileLen := IntMax(FMaxFileLen, length(AItem.Path) - vPos);
      FMaxPathLen := IntMax(FMaxPathLen, vPos);
    end else
      inherited AcceptItem(AItem, AGroup);

    FMaxHits := IntMax(FMaxHits, TEdtHistoryEntry(AItem).Hits);
    FMaxSaves := IntMax(FMaxSaves, TEdtHistoryEntry(AItem).SaveCount);
  end;


  procedure TEdtMenuDlg.ReinitColumns; {override;}
  var
    vOpt, vOpt1 :TColOptions;
    vDateLen, vHitsLen, vSavesLen :Integer;
  begin
    vDateLen := Date2StrLen(optDateFormat);
    vHitsLen := Int2StrLen(FMaxHits);
    vSavesLen := Int2StrLen(FMaxSaves);

    vOpt := [coColMargin];
    if not optShowGrid then
      vOpt := vOpt + [coNoVertLine];

    FGrid.Columns.Clear;

    if not optShowFullPath then begin
      if FHierarchical then
        Inc(FMaxFileLen);
      FMenuMaxWidth := IntMax(FMenuMaxWidth, FMaxFileLen);
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], 1) );
    end else
    begin
      if not optSeparateName then begin
        if FHierarchical then
          Inc(FMaxPathLen);
        FMenuMaxWidth := IntMax(FMenuMaxWidth, FMaxPathLen);
        FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], 1) );
      end else
      begin
        if FHierarchical then
          Inc(FMaxFileLen);
        FMenuMaxWidth := IntMax(FMenuMaxWidth, FMaxPathLen);
        vOpt1 := vOpt;
        if FHierarchical then
          vOpt1 := vOpt1 + [coNoVertLine];
        FGrid.Columns.Add( TColumnFormat.CreateEx('', '', FMaxFileLen + 2, taLeftJustify, vOpt1 + [coOwnerDraw], 1) );
        FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], 11) );
      end;
    end;

    if optShowDate then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vDateLen + 2, taRightJustify, vOpt, 2) );
    if optShowHits then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vHitsLen + 2, taRightJustify, vOpt, 3) );
    if optShowModify then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vDateLen + 2, taRightJustify, vOpt, 4) );
    if optShowSaves then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vSavesLen + 2, taRightJustify, vOpt, 5) );
  end;


  procedure TEdtMenuDlg.ReinitGrid; {override;}
  begin
    FMaxFileLen := 0;
    FMaxPathLen := 0;
    FMaxHits := 0;
    FMaxSaves := 0;
    inherited ReinitGrid;
  end;


 {-----------------------------------------------------------------------------}

  function TEdtMenuDlg.ItemMarkHidden(AItem :THistoryEntry) :Boolean; {override;}
  begin
    Result := AItem.Flags and hfEdit = 0;
  end;


  function TEdtMenuDlg.ItemMarkUnavailable(ACol :Integer; AItem :THistoryEntry) :Boolean; {override;}
  var
    vType :Integer;
  begin
    if (ACol = -1) or (FGrid.Column[ACol].Tag in [1, 11]) then begin
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
            if not WinFileExists(AItem.Path) then begin
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


  function TEdtMenuDlg.GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; {override;}

    function LocGetBaseTime :TDateTime;
    begin
      Result := Date;
      if optHierarchical then
        case Abs(optSortMode) of
          0, 2 : Result := GetBaseTime(AItem.Time);
          4    : Result := GetBaseTime(TEdtHistoryEntry(AItem).EdtTime);
        end;
    end;

  begin
    case AColTag of
//    1: Result := ExtractFileName(AItem.Path);
//   11: Result := ExtractFilePath(AItem.Path);

      2: Result := Date2StrBase(AItem.Time, optDateFormat, LocGetBaseTime);
      3: Result := Int2Str((AItem as TEdtHistoryEntry).Hits);
      4: Result := Date2StrBase(TEdtHistoryEntry(AItem).EdtTime, optDateFormat, LocGetBaseTime);
      5: Result := Int2Str((AItem as TEdtHistoryEntry).SaveCount);

    else
      Result := inherited GetEntryStr(AItem, AColTag);
    end;
  end;

  
  procedure TEdtMenuDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vRec :PFilterRec;
    vItem :THistoryEntry;
    vPos, vDelta :Integer;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      if vRec.FIdx < 0 then
        Exit;

      vItem := FHistory[vRec.FIdx];
      if optSeparateName or not optShowFullPath then begin

        if FHierarchical and (vRec.FSel and 2 <> 0) then begin
          { Группа }
          if ACol = 1 then begin
            vDelta := FGrid.Column[0].RealWidth;
//          if optShowGrid then
//            Inc(vDelta);
            Dec(X, vDelta); Inc(AWidth, vDelta);
          end;
          inherited GridPaintCell(ASender, X, Y, AWidth, 0, ARow, AColor);
        end else
        begin
          vPos := LastDelimiter('\:', vItem.Path);

          if FGrid.Column[ACol].Tag = 1 then begin
            if FHierarchical then begin
              Inc(X); Dec(AWidth);
            end;

            DrawTextEx(X, Y, AWidth, PTChar(vItem.Path) + vPos, vRec.FPos - vPos, vRec.FLen, AColor);
          end else
          begin

            DrawTextEx(X, Y, IntMin(AWidth, vPos), PTChar(vItem.Path), vRec.FPos, vRec.FLen, AColor);
          end;
        end;

      end else
        inherited GridPaintCell(ASender, X, Y, AWidth, ACol, ARow, AColor);
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TEdtMenuDlg.CheckFileExists(const AFileName :TString) :Boolean;
  var
    vRes :Integer;
  begin
    Result := True;
    if not WinFileExists(AFileName) then begin

      vRes := ShowMessageBut(GetMsgStr(strConfirmation), GetMsgStr(strFileNotFound) + #10 + AFileName,
        [GetMsgStr(strCreateFileBut), GetMsgStr(strDeleteBut), GetMsgStr(strCancel)],
        FMSG_WARNING);

      case vRes of
        0: {};
        1:
        begin
          Result := False;
          DeleteSelected;
        end;
      else
        Result := False;
      end;
    end;
  end;


  procedure TEdtMenuDlg.ViewOrEditCurrent(AEdit :Boolean);
  var
    vSave :THandle;
    vItem :THistoryEntry;
  begin
    vItem := GetHistoryEntry(FGrid.CurRow);
    if (vItem <> nil) and (DlgItemFlag(FGrid.CurRow) and 2 = 0) then begin

      if not CheckFileExists(vItem.Path) then
        Exit;

      { Глючит, если в процессе просмотра/редактирования файла изменить размер консоли...}
      SendMsg(DM_ShowDialog, 0, 0);
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      try
        {!!! Проверить, что файл уже открыт на редактирование }
        FarEditOrView(vItem.Path, AEdit, EF_ENABLE_F6);
      finally
        FARAPI.RestoreScreen(vSave);
        SendMsg(DM_ShowDialog, 1, 0);
      end;

      ReinitAndSaveCurrent(vItem);

    end else
      Beep;
  end;


  procedure TEdtMenuDlg.CommandsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCommandsTitle),
    [
      GetMsg(strMOpen),
      '',
      GetMsg(strMView),
      GetMsg(strMEdit),
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

        2 : ViewOrEditCurrent(False);
        3 : ViewOrEditCurrent(True);

        5 : DeleteSelected;
        6 : Sorry;

        8 : ProfileMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TEdtMenuDlg.ProfileMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle1),
    [
      GetMsg(strMGroupBy),
      GetMsg(strMShowUnavail),
      GetMsg(strMShowViewed),
      GetMsg(strMSeparateName),
      '',
      GetMsg(strMFullPath),
      GetMsg(strMAccessTime),
      GetMsg(strMOpenCount),
      GetMsg(strMModifyTime),
      GetMsg(strMSaveCount),
      '',
      GetMsg(strMSortBy)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optHierarchical;
        vMenu.Checked[1] := optShowUnavail;
        vMenu.Checked[2] := optShowView;
        vMenu.Checked[3] := optSeparateName;

        vMenu.Checked[5] := optShowFullPath;
        vMenu.Checked[6] := optShowDate;
        vMenu.Checked[7] := optShowHits;
        vMenu.Checked[8] := optShowModify;
        vMenu.Checked[9] := optShowSaves;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOption(optHierarchical);
          1 : ToggleOption(optShowUnavail);
          2 : ToggleOption(optShowView);
          3 : ToggleOption(optSeparateName);

          5 : ToggleOption(optShowFullPath);
          6 : ToggleOption(optShowDate);
          7 : ToggleOption(optShowHits);
          8 : ToggleOption(optShowModify);
          9 : ToggleOption(optShowSaves);

         11 : SortByMenu;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TEdtMenuDlg.SortByMenu;
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
      GetMsg(strMByModifyTime),
      GetMsg(strMBySaveCount),
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


  function TEdtMenuDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of

      KEY_F2:
        CommandsMenu;
      KEY_F9:
        ProfileMenu;
      KEY_CTRLF12:
        SortByMenu;

      KEY_F3:
        ViewOrEditCurrent(False);
      KEY_F4:
        ViewOrEditCurrent(True);

      KEY_CTRLV:
        ToggleOption(optShowView);
      KEY_CTRLN:
        ToggleOption(optSeparateName);
      KEY_CTRL1:
        ToggleOption(optShowFullPath);
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

  function EditorFile(AWindow :Integer) :TString;
  var
    vWinInfo :TWindowInfo;
    vName :TString;
  begin
    Result := '';
    FarGetWindowInfo(AWindow, vWinInfo, @vName, nil);
    if vWinInfo.WindowType in [WTYPE_EDITOR, WTYPE_VIEWER] then
      Result := vName;
  end;


  function GetCurrentEditorPos :Integer;
  var
    vInfo :TEditorInfo;
  begin
    Result := 0;
   {$ifdef Far3}
    vInfo.StructSize := SizeOf(vInfo);
   {$endif Far3}
    if FarEditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      Result := vInfo.CurLine + 1;
    end;
  end;


  procedure GotoPosition(ARow, ACol :Integer; ATopLine :Integer = 0);
  var
    vNewTop, vHeight :Integer;
    vPos :TEditorSetPosition;
    vInfo :TEditorInfo;
  begin
    Dec(ARow); Dec(ACol);
    vNewTop := -1;
   {$ifdef Far3}
    vInfo.StructSize := SizeOf(vInfo);
   {$endif Far3}
    if FarEditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      if ATopLine = 0 then
        vHeight := vInfo.WindowSizeY
      else
        vHeight := ATopLine - 1{Строка состояния редактора};
      if (ARow < vInfo.TopScreenLine) or (ARow >= vInfo.TopScreenLine + vHeight) then
        vNewTop := RangeLimit(ARow - (vHeight div 2), 0, MaxInt{???});
    end;
   {$ifdef Far3}
    vPos.StructSize := SizeOf(vPos);
   {$endif Far3}
    vPos.TopScreenLine := vNewTop;
    vPos.CurLine := ARow;
    vPos.CurPos := ACol;
    vPos.CurTabPos := -1;
    vPos.LeftPos := -1;
    vPos.Overtype := -1;
    FarEditorControl(ECTL_SETPOSITION, @vPos);
  end;


  procedure OpenEditor(const AFileName :TString; AEdit :Boolean; ARow :Integer = -1; ACol :Integer = -1; ATopLine :Integer = 0);
  var
    I, vCount :Integer;
    vFileName :TString;
    vFound :Boolean;
  begin
    vFileName := EditorFile(-1);
    vFound := StrEqual(vFileName, AFileName);
    if not vFound then begin
      vCount := FarAdvControl(ACTL_GETWINDOWCOUNT, nil);
      for I := 0 to vCount - 1 do begin
        vFileName := EditorFile(I);
        vFound := StrEqual(vFileName, AFileName);
        if vFound then begin
         {$ifdef Far3}
          FARAPI.AdvControl(PluginID, ACTL_SETCURRENTWINDOW_, I, nil);
         {$else}
          FarAdvControl(ACTL_SETCURRENTWINDOW, Pointer(TIntPtr(I)));
         {$endif Far3}
          FarAdvControl(ACTL_COMMIT, nil);
          Break;
        end;
      end;
    end;

    if vFound then begin
      if ARow > 0 then
        GotoPosition(ARow, ACol, ATopLine)
    end else
    begin
      {!!!Кодировка???}
      if AEdit then begin
        FARAPI.Editor(PFarChar(AFileName), nil, 0, 0, -1, -1, EF_NONMODAL or EF_IMMEDIATERETURN or EF_ENABLE_F6, ARow, ACol, CP_DEFAULT);
        if ATopLine <> 0 then
          GotoPosition(ARow, ACol, ATopLine);
      end else
      begin
        FARAPI.Viewer(PFarChar(AFileName), '', 0, 0, -1, -1, VF_NONMODAL or VF_IMMEDIATERETURN or VF_ENABLE_F6, CP_DEFAULT);
      end;
    end;
  end;


  procedure OpenEditorBy(AItem :TEdtHistoryEntry; AModified :Boolean);
  begin
    if AModified then
      OpenEditor(AItem.Path, True, AItem.ModRow, AItem.ModCol)
    else
      OpenEditor(AItem.Path, AItem.Flags and hfEdit <> 0);
  end;


  var
    vMenuLock :Integer;


  procedure OpenEdtHistoryDlg1(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString = '';
    AGroupMode :Integer = MaxInt; ASortMode :Integer = MaxInt; AShowHidden :Integer = MaxInt);
  var
    vDlg :TEdtMenuDlg;
    vFinish :Boolean;
    vFilter :TString;
  begin
    if vMenuLock > 0 then
      Exit;

    optShowView     := False;
    optShowUnavail  := True;
    optSeparateName := True;
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
      optSortMode    := -4; {By ModTime}
    end;

    ReadSetup(AModeName);

    Inc(vMenuLock);
    EdtHistory.LockHistory;
    try
      EdtHistory.LoadModifiedHistory;

      vDlg := TEdtMenuDlg.Create;
      try
        vDlg.FCaption := ACaption;
        vDlg.FHistory := EdtHistory;
        vDlg.FMode := AMode;
        vDlg.FModeName := AModeName;

        vFilter := AFilter;
        if (vFilter = '') and optSaveMask then
          vFilter := FFilesLastFilter;
        if vFilter = #0 then
          vFilter := '';
        vDlg.SetFilter(vFilter);

        if AGroupMode <> MaxInt then begin
          optHierarchical := AGroupMode in [1..3];
(*          if optHierarchical then
            optHierarchyMode := THierarchyMode(AGroupMode - 1);  *)
        end;

        if ASortMode <> MaxInt then
          optSortMode := ASortMode;

(*      if AShowHidden <> MaxInt then
          optShowHidden := AShowHidden <> 0;  *)

        vFinish := False;
        while not vFinish do begin
          if vDlg.Run = -1 then
            Exit;
          case vDlg.FResCmd of
            1: OpenEditorBy(vDlg.FResItem as TEdtHistoryEntry, AMode = 1);
            2: InsertText(vDlg.FResStr);
            3: JumpToPath(RemoveBackSlash(ExtractFilePath(vDlg.FResStr)), ExtractFileName(vDlg.FResStr), False);
          end;
          vFinish := True;
        end;

      finally
        FFilesLastFilter := vDlg.GetFilter;
        FreeObj(vDlg);
      end;

    finally
      EdtHistory.UnlockHistory;
      Dec(vMenuLock);
    end;
  end;


end.


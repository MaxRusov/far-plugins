{$I Defines.inc}

unit MoreHistoryEdtDlg;

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

   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarKeysW,

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

      function ItemMarkHidden(AItem :THistoryEntry) :Boolean; override;
      function GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

      procedure ChangeHierarchMode; override;

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


  procedure OpenEdtHistoryDlg(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString);


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
//  RegisterHints(Self);  !!!
    FGUID := cFilesDlgID;
    FHelpTopic := 'EdtHistoryList';
  end;


  destructor TEdtMenuDlg.Destroy; {override;}
  begin
//  UnregisterHints;
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
      ((optShowHidden) or (AItem.Flags and hfEdit <> 0));
  end;


  procedure TEdtMenuDlg.AcceptItem(AItem :THistoryEntry; AGroup :TMyFilter); {override;}
  var
    vPos :Integer;
  begin
//  inherited AcceptItem(AItem, AGroup);
    if not optSeparateName and optShowFullPath then
      FMaxPathLen := IntMax(FMaxPathLen, length(AItem.Path))
    else begin
      vPos := LastDelimiter('\:', AItem.Path);
      FMaxFileLen := IntMax(FMaxFileLen, length(AItem.Path) - vPos);
      FMaxPathLen := IntMax(FMaxPathLen, vPos);
    end;
    FMaxHits := IntMax(FMaxHits, TEdtHistoryEntry(AItem).Hits);
    FMaxSaves := IntMax(FMaxSaves, TEdtHistoryEntry(AItem).SaveCount);
  end;


  procedure TEdtMenuDlg.ReinitColumns; {override;}
  var
    vOpt, vOpt1 :TColOptions;
    vDateLen, vHitsLen, vSavesLen :Integer;
  begin
    vDateLen := Date2StrLen(optDateFormat);
    vHitsLen := Length(Int2Str(FMaxHits));
    vSavesLen := Length(Int2Str(FMaxSaves));

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


  function TEdtMenuDlg.GetEntryStr(AItem :THistoryEntry; AColTag :Integer) :TString; {override;}
  begin
    case AColTag of
//    1: Result := ExtractFileName(AItem.Path);
//   11: Result := ExtractFilePath(AItem.Path);

      2: Result := Date2StrMode(AItem.Time, optDateFormat, optHierarchical and (optHierarchyMode = hmDate));
      3: Result := Int2Str((AItem as TEdtHistoryEntry).Hits);

      4: Result := Date2StrMode((AItem as TEdtHistoryEntry).EdtTime, optDateFormat, optHierarchical and (optHierarchyMode = hmModDate));
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

      vRes := ShowMessage(GetMsgStr(strConfirmation), GetMsgStr(strFileNotFound) + #10 + AFileName + #10 +
        GetMsgStr(strCreateFileBut) + #10 + GetMsgStr(strDeleteBut) + #10 + GetMsgStr(strCancel),
        FMSG_WARNING, 3);

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
        vMenu.Checked[1] := optSeparateName;

        vMenu.Checked[3] := optShowFullPath;
        vMenu.Checked[4] := optShowDate;
        vMenu.Checked[5] := optShowHits;
        vMenu.Checked[6] := optShowModify;
        vMenu.Checked[7] := optShowSaves;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ChangeHierarchMode;
          1 : ToggleOption(optSeparateName);

          3 : ToggleOption(optShowFullPath);
          4 : ToggleOption(optShowDate);
          5 : ToggleOption(optShowHits);
          6 : ToggleOption(optShowModify);
          7 : ToggleOption(optShowSaves);

          9 : SortByMenu;
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


  procedure TEdtMenuDlg.ChangeHierarchMode; {override;}
  begin
    if not optHierarchical then begin
      optHierarchical := True;
      if FMode = 0 then
        optHierarchyMode := hmDate
      else
        optHierarchyMode := hmModDate
    end else
    if optHierarchyMode <> hmDomain then begin
      optHierarchyMode := hmDomain
    end else
      optHierarchical := False;
    ReinitAndSaveCurrent;
    FSetChanged := True;
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
    if FarEditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      if ATopLine = 0 then
        vHeight := vInfo.WindowSizeY
      else
        vHeight := ATopLine - 1{Строка состояния редактора};
      if (ARow < vInfo.TopScreenLine) or (ARow >= vInfo.TopScreenLine + vHeight) then
        vNewTop := RangeLimit(ARow - (vHeight div 2), 0, MaxInt{???});
    end;
    vPos.TopScreenLine := vNewTop;
    vPos.CurLine := ARow;
    vPos.CurPos := ACol;
    vPos.CurTabPos := -1;
    vPos.LeftPos := -1;
    vPos.Overtype := -1;
    FarEditorControl(ECTL_SETPOSITION, @vPos);
  end;


  procedure OpenEditor(const AFileName :TString; AEdit :Boolean; ARow, ACol :Integer; ATopLine :Integer = 0);
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
//    if ARow > 0 then
//      GotoPosition(ARow, ACol, ATopLine)
    end else
    begin
      if ARow = 0 then begin
        ARow := -1;
        ACol := -1;
      end;

      {!!!Кодировка???}
      if AEdit then begin
        FARAPI.Editor(PFarChar(AFileName), nil, 0, 0, -1, -1, EF_NONMODAL or EF_IMMEDIATERETURN or EF_ENABLE_F6, ARow, ACol, CP_AUTODETECT);
        if ATopLine <> 0 then
          GotoPosition(ARow, ACol, ATopLine);
      end else
      begin
        FARAPI.Viewer(PFarChar(AFileName), '', 0, 0, -1, -1, VF_NONMODAL or VF_IMMEDIATERETURN or VF_ENABLE_F6, CP_AUTODETECT);
      end;
    end;
  end;



  var
    vMenuLock :Integer;


  procedure OpenEdtHistoryDlg(const ACaption, AModeName :TString; AMode :Integer; const AFilter :TString);
  var
    vDlg :TEdtMenuDlg;
    vFinish :Boolean;
    vFilter :TString;
  begin
    if vMenuLock > 0 then
      Exit;

    optShowHidden := False;
    optSeparateName := True;
    optShowFullPath := True;
    optHierarchical := True;
    if AMode = 0 then begin
      optHierarchyMode := hmDate;
      optShowDate   := True;
      optShowHits   := True;
      optShowModify := False;
      optShowSaves  := False;
      optSortMode   := 0; {Default}
    end else
    begin
      optHierarchyMode := hmModDate;
      optShowDate   := False;
      optShowHits   := False;
      optShowModify := True;
      optShowSaves  := True;
      optSortMode   := -4; {By ModTime}
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
        vDlg.SetFilter(vFilter);

        vFinish := False;
        while not vFinish do begin
          if vDlg.Run = -1 then
            Exit;
          case vDlg.FResCmd of
            1:
            begin
              if AMode = 1 then begin
                with vDlg.FResItem as TEdtHistoryEntry do
                  OpenEditor(vDlg.FResStr, True, ModRow, ModCol);
              end else
                OpenEditor(vDlg.FResStr, vDlg.FResItem.Flags and hfEdit <> 0, 0, 0);
            end;
            2: InsertText(vDlg.FResStr);
            3: JumpToPath(ExtractFilePath(vDlg.FResStr), ExtractFileName(vDlg.FResStr));
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


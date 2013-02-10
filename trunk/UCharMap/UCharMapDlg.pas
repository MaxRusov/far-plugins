{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{$I Defines.inc}

unit UCharMapDlg;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarMenu,

   {$ifdef bUseHint}
    UCharMapHints,
   {$endif bUseHint}

    UCharMapCtrl,
    UCharListBase,
    UCharMapFontsDlg,
    UCharMapGroupsDlg,
    UCharMapCharsDlg;


  var
    vDlgLock  :Integer;
    vLastChar :TChar;


  const
    cDlgWidth  = 44;
    cDlgHeight = 27;

    IdFrame   = 0;
    IdIcon    = 1;
    IdFont    = 2;
    IdFrame1  = 3;
    IdMap     = 4;
    IdFrame2  = 5;
    IdEdit    = 6;
    IdStatus  = 7;
    IdChrName = 8;
    IdGrpName = 9;

    cMaximizedIcon = '['#$12']';
    cNormalIcon = '['#$18']';


  type
    TCharMapDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetCharAt(ACol, ARow :Integer) :TChar;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FGrid        :TFarGrid;
      FFilter      :TIntList;
      FHiddenColor :TFarColor;
      FRes         :TString;

      procedure ResizeDialog(ANeedLock :Boolean);
      procedure ReinitFilter;
      procedure ReinitAndSaveCurrent;

      function RowToCode(ARow :Integer) :Integer;
      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
      function GridPaintRow(ASender :TFarGrid; X, Y, AWidth :Integer; ARow :Integer; AColor :TFarColor) :Boolean;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);
      procedure GridPosChange(ASender :TFarGrid);
      function GetCurChar(AUseGroup :Boolean = False) :TChar;
      function GetGroupAt(ARow :Integer) :TUnicodeGroup;
      function GetCurGroup :TUnicodeGroup;

      procedure CommandMenu(X :Integer = -1; Y :Integer = -1);
      procedure AppendCurrent;
      procedure CopyToClipboard;
      procedure GotoChar(AChar :TChar);
      procedure SelectFont;
      procedure SelectGroup;
      procedure SelectChar;
      procedure ReturnChar;
      procedure Maximize;

      procedure CollapseGroup;
      procedure ExpandGroup;
      procedure ExpandAllGroup(AExpand :Boolean);
      procedure ExpandCollapseGroup(ARow :Integer; AGroup :TUnicodeGroup; AExpand :Boolean);

    public
      property Grid :TFarGrid read FGrid;
    end;


  procedure OpenDlg;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TCharMapDlg                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TCharMapDlg.Create; {override;}
  begin
    inherited Create;
   {$ifdef bUseHint}
    RegisterHints(Self);
   {$endif bUseHint}
    FHiddenColor := GetOptColor(optHiddenColor, COL_DIALOGDISABLED);
  end;


  destructor TCharMapDlg.Destroy; {override;}
  begin
   {$ifdef bUseHint}
    UnRegisterHints;
   {$endif bUseHint}
    FreeObj(FGrid);
    FreeObj(FFilter);
    inherited Destroy;
  end;


  procedure TCharMapDlg.Prepare; {override;}
  const
    DX = cDlgWidth;
    DY = cDlgHeight;
  begin
    FHelpTopic := 'UCharMap';
    FGUID := cMainDlgID;
    FWidth := cDlgWidth;
    FHeight := cDlgHeight;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, GetMsg(strTitle)),
        NewItemApi(DI_Text,        DX-7, 1, 3, 1, 0, cNormalIcon),
        NewItemApi(DI_Text,        3, 2, DX - 6, 1, 0, ''),
        NewItemApi(DI_SingleBox,   3, 3, DX - 6, 1, 0, ''),
        NewItemApi(DI_UserControl, 3, 4, DX - 5, 16, 0, ''),
        NewItemApi(DI_SingleBox,   3, 20, DX - 6, 1, 0, ''),
        NewItemApi(DI_Edit,        3, 21, DX - 6, 1, 0, ''),
        NewItemApi(DI_Text,        3, 22, DX - 6, 1, 0, ''),
        NewItemApi(DI_Text,        3, 23, DX - 6, 1, 0, ''),
        NewItemApi(DI_Text,        3, 24, DX - 6, 1, 0, '')
      ], @FItemCount
    );

    FGrid := TFarGrid.CreateEx(Self, IdMap);
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintRow := GridPaintRow;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.OnPosChange := GridPosChange;
    FGrid.Options := [{goRowSelect} {goFollowMouse} {,goWheelMovePos}];
    FGrid.NormColor := FarGetColor(COL_DIALOGTEXT);
    FGrid.SelColor := GetOptColor(optCurrColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid.RowCount := $1000;
    FGrid.UpdateSize(3, 2, DX - 5, 16);
  end;


  procedure TCharMapDlg.InitDialog; {override;}
  begin
    ReinitFilter;
    ResizeDialog(False);
    GotoChar(vLastChar);
    SetText(IdFont, FontName);
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    UpdateFontRange;
  end;


  procedure TCharMapDlg.ResizeDialog(ANeedLock :Boolean);
  var
    vHeight, vAddHeight, vWidth :Integer;
    vRect :TSmallRect;
    vSize :TSize;
  begin
    if ANeedLock then
      SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      vSize := FarGetWindowSize;

      vWidth := cDlgWidth;
      if not optShowNumbers then
        Dec(vWidth, 5);

      vAddHeight := 9;
      if optShowGroupName then
        Inc(vAddHeight);
      if optShowCharName then
        Inc(vAddHeight);
      if optGroupBy and (GroupNames <> nil) then
        Inc(vAddHeight, 4);

      vHeight := 16 + vAddHeight;

      if optMaximized then begin
        vHeight := FGrid.RowCount + 10;
        if vHeight > vSize.CY - 4 then
          vHeight := vSize.CY - 4;
        vHeight := IntMax(vHeight, cDlgHeight);
      end;

      SetDlgPos(-1, -1, vWidth, vHeight);

      vRect.Left := 2;
      vRect.Top := 1;
      vRect.Right := vWidth - 3;
      vRect.Bottom := vHeight - 2;
      SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);

      Inc(vRect.Left); Dec(vRect.Right);
      vRect.Top := vRect.Bottom - 1; vRect.Bottom := vRect.Top;

      SendMsg(DM_SHOWITEM, IdGrpName, Byte(optShowGroupName));
      if optShowGroupName then begin
        SendMsg(DM_SETITEMPOSITION, IdGrpName, @vRect);
        Dec(vRect.Top); Dec(vRect.Bottom);
      end;

      SendMsg(DM_SHOWITEM, IdChrName, Byte(optShowCharName));
      if optShowCharName then begin
        SendMsg(DM_SETITEMPOSITION, IdChrName, @vRect);
        Dec(vRect.Top); Dec(vRect.Bottom);
      end;

      SendMsg(DM_SETITEMPOSITION, IdStatus, @vRect);
      Dec(vRect.Top); Dec(vRect.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdEdit, @vRect);
      Dec(vRect.Top); Dec(vRect.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdFrame2, @vRect);

      vRect.Top := 4; Dec(vRect.Bottom); Inc(vRect.Right);
      SendMsg(DM_SETITEMPOSITION, IdMap, @vRect);
      FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);

      vRect.Top := 3; vRect.Bottom := vRect.Top; Dec(vRect.Right);
      SendMsg(DM_SETITEMPOSITION, IdFrame1, @vRect);


      vRect.Top := 1; vRect.Bottom := 1; vRect.Left := vWidth - 7; vRect.Right := vRect.Left + 2;
      SendMsg(DM_SETITEMPOSITION, IdIcon, @vRect);

      if optMaximized then
        SetText(IdIcon, cMaximizedIcon)
      else
        SetText(IdIcon, cNormalIcon);

    finally
      if ANeedLock then
        SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TCharMapDlg.ReinitFilter;
  var
    I, vGIndex, vNext :Integer;
    vGroup :TUnicodeGroup;
    vPtr :Pointer;
  begin
    vPtr := nil;
    if not optShowHidden and (FontRange <> nil) then
      vPtr := FontRange.BitsPtr;

    if optGroupBy and (GroupNames <> nil) then begin
      if FFilter = nil then
        FFilter := TIntList.Create;
      FFilter.Clear;

      vGIndex := 0;
      vGroup := nil;
      vNext := TUnicodeGroup(GroupNames[vGIndex]).Code1;

      for I := 0 to $FFF do begin

        if I * 16 >= vNext then begin
          vGroup := TUnicodeGroup(GroupNames[vGIndex]);

          Inc(vGIndex);
          if vGIndex < GroupNames.Count then
            vNext := TUnicodeGroup(GroupNames[vGIndex]).Code1
          else
            vNext := $10000;

          FFilter.Add(-vGIndex);
        end;

        if (vGroup <> nil) and not vGroup.Closed then
          if (vPtr = nil) or (Word(vPtr^) <> 0) then
            FFilter.Add(I);
        if vPtr <> nil then
          Inc(Pointer1(vPtr), 2);
      end;

    end else
    begin
      if vPtr <> nil then begin
        if FFilter = nil then
          FFilter := TIntList.Create;
        FFilter.Clear;

        for I := 0 to $FFF do begin
          if Word(vPtr^) <> 0 then
            FFilter.Add(I);
          Inc(Pointer1(vPtr), 2);
        end;

      end else
        FreeObj(FFilter);
    end;

    FGrid.Columns.FreeAll;
    if optShowNumbers then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 4, taRightJustify, [], 0) );
    for I := 0 to 15 do
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 2, taLeftJustify, [{coColMargin,} coNoVertLine, coOwnerDraw], 0) );

    FGrid.FixedCol := IntIf(optShowNumbers, 1, 0);

    FGrid.ResetSize;
    if FFilter <> nil then
      FGrid.RowCount := FFilter.Count
    else
      FGrid.RowCount := $1000;
  end;


  procedure TCharMapDlg.ReinitAndSaveCurrent;
  var
    vChar :TChar;
  begin
    vChar := GetCurChar(True);
    ReinitFilter;
    ResizeDialog(False);
    GotoChar(vChar);
  end;


  function TCharMapDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    vLastChar := GetCurChar;
    Result := True;
  end;


  procedure TCharMapDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  var
    vGroup :TUnicodeGroup;
  begin
    if AButton = 2 then begin
//    with GetConsoleMousePos do
//      CommandMenu(X, Y);
      AppendCurrent;
    end else
    if ADouble then begin
      vGroup := GetGroupAt(ARow);
      if vGroup <> nil then
        ExpandCollapseGroup(ARow, vGroup, {Expand:}vGroup.Closed)
      else
        ReturnChar;
    end;
  end;


  function TCharMapDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ACol = 0 then
      Result := Format('%.4x', [RowToCode(ARow)])
    else
      Result := '';
  end;


  procedure TCharMapDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
  begin
    if (ARow = FGrid.CurRow) and (ACol = FGrid.CurCol + 1) and (ACol > FGrid.FixedCol) then
      AColor := FGrid.SelColor;
  end;


  function TCharMapDlg.GridPaintRow(ASender :TFarGrid; X, Y, AWidth :Integer; ARow :Integer; AColor :TFarColor) :Boolean;
  var
    vGroup :TUnicodeGroup;
  begin
    vGroup := GetGroupAt(ARow);
    if vGroup <> nil then begin

      Inc(X, 1);
      if optShowNumbers then
        Inc(X, 5);

      if ARow = FGrid.CurRow then
        AColor := FGrid.SelColor
      else
        AColor := ChangeFG(AColor, optDelimColor);

      FGrid.DrawChr(X, Y, PTChar(vGroup.Name), length(vGroup.Name), AColor);

      Result := True;
    end else
      Result := False;
  end;


  procedure TCharMapDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);
  var
    vBuf :array[0..3] of TChar;
    vCode :Integer;
    vColor :TFarColor;
  begin
    vCode := RowToCode(ARow);
    if vCode <> -1 then begin
      vCode := vCode + ACol - FGrid.FixedCol;
      FillFarChar(vBuf, 3, ' ');
      vBuf[1] := TChar(vCode);
      vBuf[3] := #0;
      if (ARow = FGrid.CurRow) and (ACol = FGrid.CurCol) then
        FARAPI.Text(X, Y, FGrid.SelColor, @vBuf[0])
      else begin
        vColor := FGrid.NormColor;
        if not CharMapped(TChar(vCode)) then
          vColor := ChangeFG(vColor, FHiddenColor);  // vColor := FHiddenColor;
        FARAPI.Text(X + 1, Y, vColor, @vBuf[1])
      end;
    end;
  end;


  procedure TCharMapDlg.GridPosChange(ASender :TFarGrid);
  var
    vChr :TChar;
    vStr :TString;
  begin
    vChr := GetCurChar;
    vStr := vChr;
    if vChr = #0 then
      vStr := ' ';
    vStr := Format('Char: %s  Hex: %.4x  Dec: %d', [vStr, Word(vChr), Word(vChr)]);
    SetText(IdStatus, vStr);

    if optShowCharName then begin
      vStr := NameOfChar(Word(vChr));
      if (vStr = '') and not optShowGroupName then begin
        vStr := NameOfRange(Word(vChr));
        if vStr <> '' then
          vStr := '<' + vStr + '>';
      end;
      SetText(IdChrName, vStr);
    end;

    if optShowGroupName then
      SetText(IdGrpName, NameOfRange(Word(vChr)));
  end;



  function TCharMapDlg.GetGroupAt(ARow :Integer) :TUnicodeGroup;
  var
    vIdx :Integer;
  begin
    Result := nil;
    if (FFilter <> nil) and (ARow < FFilter.Count) then begin
      vIdx := FFilter[ARow];
      if vIdx < 0 then
        Result := GroupNames[-vIdx - 1]
    end;
  end;

  function TCharMapDlg.GetCurGroup :TUnicodeGroup;
  begin
    Result := GetGroupAt(FGrid.CurRow);
    if Result = nil then
      Result := GroupByCode( RowToCode(FGrid.CurRow) )
  end;


  function TCharMapDlg.RowToCode(ARow :Integer) :Integer;
  var
    vCode :Integer;
  begin
    if FFilter = nil then
      Result := ARow * 16
    else begin
      Result := -1;
      if ARow < FFilter.Count then begin
        vCode := FFilter[ARow];
        if vCode >= 0 then
          Result := vCode * 16;
      end;
    end;
  end;


  function TCharMapDlg.GetCharAt(ACol, ARow :Integer) :TChar;
  var
    vCode :Integer;
  begin
    Result := #0;
    vCode := RowToCode(ARow);
    if vCode >= 0 then
      Result := TChar(vCode + ACol - FGrid.FixedCol);
  end;


  function TCharMapDlg.GetCurChar(AUseGroup :Boolean = False) :TChar;
  var
    vGroup :TUnicodeGroup;
  begin
    vGroup := GetGroupAt(FGrid.CurRow);
    if vGroup = nil then
      Result := GetCharAt(FGrid.CurCol, FGrid.CurRow)
    else
    if AUseGroup then
      Result := TChar(vGroup.Code1)
    else
      Result := #0;
  end;


  procedure TCharMapDlg.GotoChar(AChar :TChar);
  var
    I, vIdx, vCod, vCod0, vCol, vRow :Integer;
    vGroup :TUnicodeGroup;
  begin
    vCod := Word(AChar);
    vRow := -1; vCol := 0;
    if FFilter = nil then begin
      vRow := vCod div 16;
      vCol := vCod mod 16;
    end else
    begin
      for I := 0 to FFilter.Count - 1 do begin
        vIdx := FFilter[I];
        if vIdx < 0 then begin
          vGroup := GroupNames[-vIdx - 1];
          if vGroup.Closed and (vCod >= vGroup.Code1) and (vCod < vGroup.Code2) then begin
            vRow := I;
            Break;
          end;
        end else
        begin
          vCod0 := vIdx * 16;
          if (vCod >= vCod0) and (vCod < vCod0 + 16) then begin
            vRow := I;
            if vCod >= vCod0 then
              vCol := vCod mod 16;
            Break;
          end;
        end;
      end;
    end;
    if vRow <> -1 then
      FGrid.GotoLocation(vCol + FGrid.FixedCol, vRow, lmSafe);
  end;


  procedure TCharMapDlg.AppendCurrent;
  var
    vCh :TChar;
  begin
    vCh := GetCurChar;
    if vCh <> #0 then
      SetText(IdEdit, GetText(IdEdit) + vCh);
  end;


  procedure TCharMapDlg.CopyToClipboard;
  var
    vStr :TString;
  begin
    vStr := GetText(IdEdit);
    if vStr = '' then
      vStr := GetCurChar;
    FarCopyToClipboard(vStr);
  end;



  procedure TCharMapDlg.SelectFont;
  var
    vName :TString;
  begin
    vName := FontName;
    InitFontList;
    if OpenFontsDlg(vName) then begin
      FontName := vName;
      UpdateFontRange;
      SetText(IdFont, FontName);
      ReinitAndSaveCurrent;
      PluginConfig(True);
    end;
  end;


  procedure TCharMapDlg.SelectGroup;
  var
    vChr :TChar;
  begin
    if GroupNames <> nil then begin
      vChr := GetCurChar(True);
      if OpenGroupsDlg(vChr) then
        GotoChar(vChr);
    end else
      AppError('GroupList.txt not found');
  end;


  procedure TCharMapDlg.SelectChar;
  var
    vChr :TChar;
  begin
    if CharNames <> nil then begin
      vChr := GetCurChar(True);
      if OpenCharsDlg(vChr) then
        GotoChar(vChr);
    end else
      AppError('NamesList.txt not found. Download from: '#10'http://unicode.org/Public/UNIDATA/NamesList.txt');
  end;


  procedure TCharMapDlg.Maximize;
  begin
    optMaximized := not optMaximized;
    ResizeDialog(True);
    FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
    PluginConfig(True);
  end;


  procedure TCharMapDlg.ReturnChar;
  var
    vChr :TChar;
  begin
    FRes := GetText(IdEdit);
    if FRes = '' then begin
      vChr := GetCurChar;
      if vChr <> #0 then
        FRes := GetCurChar;
    end;
    SendMsg(DM_CLOSE, -1, 0);
  end;


  procedure TCharMapDlg.CollapseGroup;
  var
    vGroup :TUnicodeGroup;
  begin
    vGroup := GetCurGroup;
    if optGroupBy and (vGroup <> nil) then begin
      if not vGroup.Closed then
        ExpandCollapseGroup(-1, vGroup, False)
    end else
      Beep;
  end;


  procedure TCharMapDlg.ExpandGroup;
  var
    vGroup :TUnicodeGroup;
  begin
    vGroup := GetCurGroup;
    if optGroupBy and (vGroup <> nil) then begin
      if vGroup.Closed then
        ExpandCollapseGroup(FGrid.CurRow, vGroup, True)
    end else
      Beep;
  end;


  procedure TCharMapDlg.ExpandCollapseGroup(ARow :Integer; AGroup :TUnicodeGroup; AExpand :Boolean);
  begin
    AGroup.Closed := not AExpand;
    if ARow = -1 then
      ReinitAndSaveCurrent
    else begin
      ReinitFilter;
      ResizeDialog(False);
      FGrid.GotoLocation(FGrid.FixedCol, ARow, lmScroll);
      if AExpand then
        FGrid.EnsureOnScreen(FGrid.CurCol, ARow, ARow + (AGroup.Code2 - AGroup.Code1) div 16 + 1, lmScroll);
    end;
  end;


  procedure TCharMapDlg.ExpandAllGroup(AExpand :Boolean);
  var
    I :Integer;
  begin
    if optGroupBy and (GroupNames <> nil) then begin
      for I := 0 to GroupNames.Count - 1 do
        TUnicodeGroup(GroupNames[I]).Closed := not AExpand;
      ReinitAndSaveCurrent;
    end else
      Beep;
  end;


  procedure TCharMapDlg.CommandMenu(X :Integer = -1; Y :Integer = -1);
  var
    vMenu :TFarMenu;
  begin
    {!!!Localize}
    vMenu := TFarMenu.CreateEx(
      'Commands', //GetMsg(strCommandsTitle),
    [
      'Select &Font    Ctrl-F',
      'Select &Group   Ctrl-R',
      'Select &Char    Ctrl-S',
      '',
      '&Options        F9'
    ]);
    try
      vMenu.X := X;
      vMenu.Y := Y;

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: SelectFont;
        1: SelectGroup;
        2: SelectChar;

        4: ConfigMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  function TCharMapDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocGotoNext;
    var
      vRow :Integer;
    begin
      if FGrid.CurCol < FGrid.Columns.Count - 1 then
        FGrid.GotoLocation(FGrid.CurCol + 1, FGrid.CurRow, lmScroll)
      else
      if FGrid.CurRow < FGrid.RowCount - 1 then begin
        vRow := FGrid.CurRow + 1;
        while (vRow < FGrid.RowCount) and (GetGroupAt(vRow) <> nil) do
          Inc(vRow);
        if vRow < FGrid.RowCount then
          FGrid.GotoLocation(FGrid.FixedCol, vRow, lmScroll);
      end;
    end;

    procedure LocGotoPrev;
    var
      vRow :Integer;
    begin
      if FGrid.CurCol > FGrid.FixedCol then
        FGrid.GotoLocation(FGrid.CurCol - 1, FGrid.CurRow, lmScroll)
      else
      if FGrid.CurRow > 0 then begin
        vRow := FGrid.CurRow - 1;
        while (vRow > 0) and (GetGroupAt(vRow) <> nil) do
          Dec(vRow);
        if vRow > 0 then
          FGrid.GotoLocation(FGrid.Columns.Count - 1, vRow, lmScroll);
      end;
    end;

    procedure LocBackLast;
    var
      vStr :TString;
    begin
      vStr := GetText(IdEdit);
      if vStr <> '' then begin
        Delete(vStr, Length(vStr), 1);
        SetText(IdEdit, vStr);
      end;
    end;

    procedure LocGotoFromClipboard;
    var
      vStr :TString;
    begin
      vStr := FarPasteFromClipboard;
      if vStr <> '' then
        GotoChar(vStr[1]);
    end;

    procedure LocToggleOption(var AOption :Boolean);
    begin
      AOption := not AOption;
      ReinitAndSaveCurrent;
      GridPosChange(nil);
      PluginConfig(True);
    end;
  
  begin
    Result := True;
    case AKey of
      KEY_ENTER, KEY_NUMENTER:
        ReturnChar;

    else
      if AID = IdMap then begin
        case AKey of
          KEY_CTRLPGUP, KEY_CTRLHOME, KEY_CTRLNUMPAD9, KEY_CTRLNUMPAD7:
            FGrid.GotoLocation(0, 0, lmScroll);
          KEY_CTRLPGDN, KEY_CTRLEND, KEY_CTRLNUMPAD3, KEY_CTRLNUMPAD1:
            FGrid.GotoLocation(0, MaxInt, lmScroll);
          KEY_RIGHT, KEY_NUMPAD6:
            LocGotoNext;
          KEY_LEFT, KEY_NUMPAD4:
            LocGotoPrev;

          KEY_HOME, KEY_NUMPAD7:
            FGrid.GotoLocation(0, FGrid.CurRow, lmScroll);
          KEY_END, KEY_NUMPAD1:
            FGrid.GotoLocation(MaxInt, FGrid.CurRow, lmScroll);

          KEY_INS:
            if GetGroupAt(FGrid.CurRow) = nil then begin
              AppendCurrent;
              LocGotoNext;
            end else
              Beep;
          KEY_BS:
            LocBackLast;
          KEY_DEL:
            SetText(IdEdit, '');

          KEY_SHIFTINS, KEY_CTRLV:
            LocGotoFromClipboard;
          KEY_CTRLINS, KEY_CTRLC:
            CopyToClipboard;

          KEY_F2:
            CommandMenu;
          KEY_F9:
            ConfigMenu;

          KEY_CTRLF:
            SelectFont;
          KEY_CTRLR:
            SelectGroup;
          KEY_CTRLS:
            SelectChar;
          KEY_CTRLM:
            Maximize;

          KEY_ADD:
            ExpandGroup;
          KEY_SUBTRACT:
            CollapseGroup;
          KEY_CTRLADD:
            ExpandAllGroup(True);
          KEY_CTRLSUBTRACT:
            ExpandAllGroup(False);

          KEY_CTRLH:
            LocToggleOption(optSHowHidden);
          KEY_CTRLG:
            LocToggleOption(optGroupBy);
          KEY_CTRL1:
            LocToggleOption(optShowNumbers);
          KEY_CTRL2:
            LocToggleOption(optShowCharName);
          KEY_CTRL3:
            LocToggleOption(optShowGroupName);

          else
            if (AKey >= 32) and (AKey <= $FFFF) then
              GotoChar(TChar(AKey))
            else
              Result := inherited KeyDown(AID, AKey);
        end;
      end else
        Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TCharMapDlg.MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; {virtual;}
  begin
    Result := False;
    case AID of
      IdFont:
        SelectFont;
      IdStatus:
        SelectChar;
      IdChrName, IdGrpName:
        SelectGroup;
      IdIcon:
        Maximize;
      else
        Result := inherited MouseEvent(AID, AMouse);
    end;
  end;


  function TCharMapDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        begin
          ReinitAndSaveCurrent;
        end;
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure InsertText(const AStr :TString);
  var
    vStr :TString;
  begin
    vStr := 'print("' + FarMaskStr(AStr) + '")';
    FarPostMacro(vStr);
  end;


  procedure OpenDlg;
  var
    vDlg :TCharMapDlg;
    vOld :TFarDialog;
  begin
    if vDlgLock > 0 then
      Exit;

    InitCharGroups;
    InitCharNames;
    PluginConfig(False);

    Inc(vDlgLock);
    vOld := TopDlg;
    vDlg := TCharMapDlg.Create;
    try
      TopDlg := vDlg;
      if vDlg.Run = -1 then
        Exit;

      if vDlg.FRes <> '' then
        InsertText(vDlg.FRes);

    finally
      TopDlg := vOld;
      FreeObj(vDlg);
      Dec(vDlgLock);
    end;
  end;


end.


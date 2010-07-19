{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}

unit VisCompTextsDlg;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

   {$ifdef bUnicodeFar}
    PluginW,
    FarKeysW,
   {$else}
    Plugin,
    FarKeys,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarColorDlg,

    VisCompCtrl,
    VisCompTexts;


  type
    TTextsDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FGrid           :TFarGrid;

      FDiff           :TTextDiff;
(*
      FFilter         :TMyFilter;
      FFilterMode     :Boolean;
      FFilterMask     :TString;
      FFilterColumn   :Integer;
      FTotalCount     :Integer;
      FSelectedCount  :array[0..1] of Integer;
*)
      FMenuMaxWidth   :Integer;
      FHeadWidth1     :Integer;
      FHeadWidth2     :Integer;

      FCurSide        :Integer;
      FStrDelta       :Integer;

      FResCmd         :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure InitColors;
      procedure ResizeDialog;
      procedure UpdateHeader;
      procedure UpdateFooter;
      procedure ReinitGrid;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode);
//    function GetCurSide :Integer;

      function FindItem(const AItem :TRowsPair) :Integer;
      function GetItemAt(ADlgIndex :Integer) :TRowsPair;
//    function GetCurrentItem :TRowsPair;
      function GetNearestPresentRow(AVer, ARow :Integer) :Integer;

      procedure ReinitAndSaveCurrent(ANeedRecompare :Boolean = False);
      procedure ToggleOption(var AOption :Boolean; ANeedRecompare :Boolean = False);

      procedure SelectCurrent(ACommand :Integer);

      procedure GotoNextDiff(AForward :Boolean);
      procedure ViewOrEditCurrent(AEdit :Boolean);
      procedure ChangeFileFormat;
      function GetFileFormat(var AFormat :TStrFileFormat) :Boolean;
      procedure MainMenu;
      procedure OptionsMenu;
      procedure ColorsMenu;

    public
      property Grid :TFarGrid read FGrid;
    end;


  var
    GEditorTopRow :Integer = -1;


  procedure ShowTextsDlg(ADiff :TTextDiff);

  procedure CompareTexts(const AFileName1, AFileName2 :TString);
  procedure CompareTextsEx(const AFileName1, AFileName2, AViewName1, AViewName2 :TString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  function ChrExpandTabsEx(AStr :PTChar; ALen :Integer; ATabLen :Integer = DefTabSize) :TString;
  var
    vEnd, vDst :PTChar;
    vPos, vDstLen, vSize :Integer;
  begin
    vDstLen := ChrExpandTabsLen(AStr, ALen, ATabLen);
    SetString(Result, nil, vDstLen);
    vDst := PTChar(Result);
    vEnd := AStr + ALen;
    vPos := 0;
    while AStr < vEnd do begin
      if AStr^ <> charTab then begin
        Assert(vPos < vDstLen);
        if (AStr^ = ' ') and optShowSpaces then
          vDst^ := optSpaceChar
        else
          vDst^ := AStr^;
        Inc(vDst);
        Inc(vPos);
      end else
      begin
        vSize := ATabLen - (vPos mod ATabLen);
        Assert(vPos + vSize <= vDstLen);
        if optShowSpaces then begin
          vDst^ := optTabChar;
          if vSize > 1 then
            MemFillChar(vDst + 1, vSize - 1, optTabSpaceChar);
        end else
          MemFillChar(vDst, vSize, ' ');
        Inc(vDst, vSize);
        Inc(vPos, vSize);
      end;
      Inc(AStr);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TTextsDlg                                                                   }
 {-----------------------------------------------------------------------------}

  const
    cDlgMinWidth  = 40;
    cDlgMinHeight = 5;

    IdFrame  = 0;
    IdHead1  = 1;
    IdHead2  = 2;
    IdList   = 3;
//  IdStatus = 4;


  constructor TTextsDlg.Create; {override;}
  begin
    inherited Create;
(*  FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec)); *)
  end;


  destructor TTextsDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
(*  FreeObj(FFilter); *)
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TTextsDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FHelpTopic := 'CompareTexts';
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_Text,        3, 2, DX div 2, 1, DIF_SHOWAMPERSAND, '...'),
        NewItemApi(DI_Text,        DX div 2 + 1, 2, DX - 6, 1, DIF_SHOWAMPERSAND, '...'),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0, '' )
      ],
      @FItemCount
    );

    FGrid := TFarGrid.CreateEx(Self, IdList);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
  end;


  procedure TTextsDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
    InitColors;
  end;


  procedure TTextsDlg.InitColors;
  begin
    FGrid.NormColor := GetOptColor(optTextColor, COL_DIALOGTEXT);
    FGrid.SelColor  := GetOptColor(optTextSelColor, COL_DIALOGLISTSELECTEDTEXT);

    SetItemFlags(IdHead1, DIF_SETCOLOR or DIF_SHOWAMPERSAND or optTextHeadColor);
    SetItemFlags(IdHead2, DIF_SETCOLOR or DIF_SHOWAMPERSAND or optTextHeadColor);
  end;


  procedure TTextsDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect, vRect1 :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := vSize.CX;
    vHeight := vSize.CY;

    vRect := SBounds(0, 0, vWidth-1, vHeight-1);
    SendMsg(DM_SHOWITEM, IdFrame, 0);

    vRect1 := vRect;
    Inc(vRect1.Top);
    SendMsg(DM_SETITEMPOSITION, IdList, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := SRect(vRect.Left, vRect.Top, vRect.Left + (vRect.Right - vRect.Left) div 2 - 1, 1);
    SendMsg(DM_SETITEMPOSITION, IdHead1, @vRect1);
    FHeadWidth1 := vRect1.Right - vRect1.Left;

    vRect1 := SRect(vRect1.Right + 2, vRect.Top, vRect.Right, 1);
    SendMsg(DM_SETITEMPOSITION, IdHead2, @vRect1);
    FHeadWidth2 := vRect1.Right - vRect1.Left;

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


  procedure TTextsDlg.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  procedure TTextsDlg.UpdateHeader;
  var
    vStr :TString;
  begin
    vStr := GetMsgStr(strTitle);
(*  if not FFilterMode then
      vStr := Format('%s (%d)', [ vStr, FTotalCount ])
    else
      vStr := Format('%s [%s] (%d/%d)', [vStr, FFilterMask, FFilter.Count, FTotalCount ]); *)

    if length(vStr)+2 > FMenuMaxWidth then
      FMenuMaxWidth := length(vStr)+2;

    SetText(IdFrame, vStr);

    vStr := FDiff.Text[0].ViewName;
    if vStr = '' then
      vStr := FDiff.Text[0].Name;
    vStr := ReduceFileName(vStr, FHeadWidth1 - 1);
    SetText(IdHead1, ' ' + vStr);

    vStr := FDiff.Text[1].ViewName;
    if vStr = '' then
      vStr := FDiff.Text[1].Name;
    vStr := ReduceFileName(vStr, FHeadWidth2 - 1);
    SetText(IdHead2, ' ' + vStr);
  end;


  procedure TTextsDlg.UpdateFooter;
  begin
    {...}
  end;


  procedure TTextsDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if ADouble then
      SelectCurrent(1);
  end;


  procedure TTextsDlg.GridPosChange(ASender :TFarGrid);
  begin
    { Обновляем status-line }
    UpdateFooter;
  end;


  function TTextsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vItem :PCmpTextRow;
    vTag, vVer, vRow :Integer;
//  vPtr :PTString;
  begin
    Result := '';
    if ARow < FDiff.DiffCount then begin
      vItem := FDiff[ARow];

      vTag := FGrid.Column[ACol].Tag;
      vVer := (vTag and $00FF) - 1;
      vTag := (vTag and $FF00) shr 8;

      vRow := vItem.FRow[vVer];

      case vTag of
//      1:
//        if vRow <> -1 then begin
//          vPtr := FDiff.Text[vVer].PStrings[vRow];
//          Result := ChrExpandTabsEx(PTChar(vPtr^), Length(vPtr^));
//        end;
        2:
          if vRow <> -1 then
            Result := Int2Str(vRow + 1) + ' ';
      end;
    end;
  end;


  procedure TTextsDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  var
    vItem :PCmpTextRow;
    vTag :Integer;
  begin
    if ARow < FDiff.DiffCount then begin
      vItem := FDiff[ARow];

      if ACol < 0 then begin

(*
        if (ARow = FGrid.CurRow) {and (ACol = FGrid.CurCol)} then
          {}
        else
*)        
//      if (vItem.FRow[0] = -1) or (vItem.FRow[1] = -1) then
        if vItem.FFlags = 0 then
          AColor := FGrid.NormColor
        else
          AColor := optTextDiffColor;

      end else
      begin
        vTag := FGrid.Column[ACol].Tag;
        vTag := (vTag and $FF00) shr 8;

        case vTag of
          2:
            AColor := (AColor and $F0) or (optTextNumColor and $0F)
        end;

      end;
    end;
  end;


  procedure TTextsDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  var
    vItem :PCmpTextRow;
    vTag, vVer, vRow :Integer;
    vPtr :PTString;
    vStr :TString;
  begin
    if ARow < FDiff.DiffCount then begin
      vItem := FDiff[ARow];
      vTag := FGrid.Column[ACol].Tag;
      vVer := (vTag and $00FF) - 1;
      vRow := vItem.FRow[vVer];

      if vRow <> -1 then begin
        vPtr := FDiff.Text[vVer].PStrings[vRow];
        vStr := ChrExpandTabsEx(PTChar(vPtr^), Length(vPtr^));

        if length(vStr) > FStrDelta then begin
          if (ARow = FGrid.CurRow) and (vVer = FCurSide) then
            FGrid.DrawChrEx(X, Y, PTChar(vStr) + FStrDelta, length(vStr) - FStrDelta, 0, 1, AColor, FGrid.SelColor)
          else
            FGrid.DrawChr(X, Y, PTChar(vStr) + FStrDelta, length(vStr) - FStrDelta, AColor);
          Exit;
        end;
      end;

      if (ARow = FGrid.CurRow) and (vVer = FCurSide) then
        FGrid.DrawChrEx(X, Y, ' ', 1, 0, 1, AColor, FGrid.SelColor)
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.ReinitGrid;
  var
    I, vRow, vMaxLen1, vMaxLen2, vMaxRow1, vMaxRow2 :Integer;
    vItem :PCmpTextRow;
(*
    vOpt :TColOptions;
    vMaxLen, vMaxLen2, vMaxLen3, vMaxLen4 :Integer;
    vMask :TString;
    vMaxSize :Int64;
    vHasMask :Boolean;
*)
  begin
//  Trace('ReinitGrid...');
(*
    FFilter.Clear;
    vMaxLen := 0;
    vMaxSize := 0;
    FTotalCount := 0;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(vMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    if not FUnfold then begin
      LocAddList(FFilter, FItems);
      FFilter.SortList(True, 0);
      if FRootItems <> FItems then
        { Элемент ".." для выхода из группы }
        FFilter.Add(nil, 0, 0, 0);
    end else
      LocAddUnfold(nil, FItems);
*)

    vMaxLen1 := 0; vMaxLen2 := 0;
    vMaxRow1 := 0; vMaxRow2 := 0;
    for I := 0 to FDiff.DiffCount - 1 do begin
      vItem := FDiff[I];

      vRow := vItem.FRow[0];
      vMaxRow1 := IntMax(vMaxRow1, vRow + 1);
      if vRow <> -1 then
        vMaxLen1 := IntMax(vMaxLen1, Length( FDiff.Text[0].PStrings[vRow]^ ));

      vRow := vItem.FRow[1];
      vMaxRow2 := IntMax(vMaxRow2, vRow + 1);
      if vRow <> -1 then
        vMaxLen2 := IntMax(vMaxLen2, Length( FDiff.Text[1].PStrings[vRow]^ ));
    end;

    FMenuMaxWidth := vMaxLen1 + vMaxlen2 + 1;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;
    if optShowLinesNumber then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Int2Str(vMaxRow1))+1, taRightJustify, [coNoVertLine], $0201) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coOwnerDraw], $0101) );
    if optShowLinesNumber then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Int2Str(vMaxRow2))+1, taRightJustify, [coNoVertLine], $0202) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coOwnerDraw], $0102) );

(*  FSelectedCount[0] := 0;
    FSelectedCount[1] := 0;  *)
    FGrid.RowCount := FDiff.DiffCount;

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
      UpdateHeader;
      UpdateFooter;
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;

    Assert(cTrue);
  end;


 {-----------------------------------------------------------------------------}

  function TTextsDlg.FindItem(const AItem :TRowsPair) :Integer;
  var
    I :Integer;
    vItem :TRowsPair;
  begin
    Result := -1;
    for I := 0 to FGrid.RowCount - 1 do begin
      vItem := GetItemAt(I);
      if ((AItem[0] <> -1) and (AItem[0] = vItem[0])) or
        ((AItem[1] <> -1) and (AItem[1] = vItem[1])) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;


  function TTextsDlg.GetItemAt(ADlgIndex :Integer) :TRowsPair;
  begin
    Result[0] := -1; Result[1] := -1;

//  if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then
//    Result := PFilterRec(FFilter.PItems[ADlgIndex]).FItem;

    if (ADlgIndex >= 0) and (ADlgIndex < FDiff.DiffCount) then
      Result := FDiff[ADlgIndex].FRow;
  end;


//function TTextsDlg.GetCurrentItem :TRowsPair;
//begin
//  Result := GetItemAt( FGrid.CurRow );
//end;



//function TTextsDlg.GetCurSide :Integer;
//begin
//  if FWholeLine then
//    Result := -1
//  else begin
//    if FGrid.CurCol < FGrid.Columns.Count div 2 then
//      Result := 0
//    else
//      Result := 1;
//  end;
//end;


 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.ReinitAndSaveCurrent(ANeedRecompare :Boolean = False);
  var
    vTopItem, vCurItem :TRowsPair;
    vIndex :Integer;
  begin
    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      vTopItem := GetItemAt( FGrid.DeltaY );
      vCurItem := GetItemAt( FGrid.CurRow );
      if ANeedRecompare then
        FDiff.Compare;
      ReinitGrid;
      vIndex := FindItem(vTopItem);
      if vIndex <> -1 then
        FGrid.ScrollTo(FGrid.DeltaY, vIndex);
      vIndex := FindItem(vCurItem);
      if vIndex <> -1 then
        FGrid.GotoLocation(FGrid.CurCol, vIndex, lmSimple );
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TTextsDlg.ToggleOption(var AOption :Boolean; ANeedRecompare :Boolean = False);
  begin
    AOption := not AOption;
    ReinitAndSaveCurrent(ANeedRecompare);
    WriteSetup;
  end;


  procedure TTextsDlg.SelectCurrent(ACommand :Integer);
(*var
    vItem :TCmpFileItem; *)
  begin
(*
    vItem := GetCurrentItem;
    if vItem <> nil then begin
      if vItem.Subs <> nil then begin
        FItems := vItem.Subs;
        ReinitGrid;
        SetCurrent( 0, lmScroll );
      end else
        CompareCurrent(ACommand = 2)
    end else
      LeaveGroup;
*)
  end;


  procedure TTextsDlg.GotoNextDiff(AForward :Boolean);
  var
    vRow :Integer;
  begin
    vRow := FGrid.CurRow;
    if AForward then begin
      while (vRow < FDiff.DiffCount) and (FDiff[vRow].FFlags <> 0) do
        Inc(vRow);
      while (vRow < FDiff.DiffCount) and (FDiff[vRow].FFlags = 0) do
        Inc(vRow);
      if vRow = FDiff.DiffCount then
        vRow := -1;
    end else
    begin
      Dec(vRow);
      while (vRow >= 0) and (FDiff[vRow].FFlags = 0) do
        Dec(vRow);
      if vRow >= 0 then begin
        while (vRow >= 0) and (FDiff[vRow].FFlags <> 0) do
          Dec(vRow);
        Inc(vRow);
      end;
    end;

    if vRow <> -1 then
      SetCurrent(vRow, lmSafe)
    else
      Beep;
  end;


  procedure TTextsDlg.ViewOrEditCurrent(AEdit :Boolean);
  var
    vRow :Integer;
    vSave :THandle;
  begin
    { Глючит, если в процессе просмотра/редактирования файла изменить размер консоли...}
//  SendMsg(DM_ShowDialog, 0, 0);
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      GEditorTopRow := GetNearestPresentRow(FCurSide, FGrid.DeltaY);
      vRow := GetNearestPresentRow(FCurSide, FGrid.CurRow);

      FarEditOrView(FDiff.Text[FCurSide].Name, AEdit, EF_ENABLE_F6, vRow + 1);

      if AEdit then begin
        FDiff.ReloadAndCompare;
        ReinitGrid;
      end;

    finally
      GEditorTopRow := -1;
      FARAPI.RestoreScreen(vSave);
//    SendMsg(DM_ShowDialog, 1, 0);
    end;

    ResizeDialog;
  end;


  function TTextsDlg.GetNearestPresentRow(AVer, ARow :Integer) :Integer;
  var
    I :Integer;
    vItem :TRowsPair;
  begin
    for I := ARow to FGrid.RowCount - 1 do begin
      vItem := GetItemAt(I);
      Result := vItem[AVer];
      if Result <> -1 then
        Exit;
    end;
    for I := ARow - 1 downto 0 do begin
      vItem := GetItemAt(I);
      Result := vItem[AVer];
      if Result <> -1 then
        Exit;
    end;
    Result := -1;
  end;


  procedure TTextsDlg.ChangeFileFormat;
  const
    cFormatNames :array[TStrFileFormat] of TString = ('Ansi', 'OEM', 'Unicode', 'UTF8', '');
  var
    N, vRes :Integer;
    vItems :PFarMenuItemsArray;
    vText :TText;
    vStr :TFarStr;
  begin
    vText := FDiff.Text[FCurSide];

    vStr := GetMsgStr(strMDefault) + ' ' + cFormatNames[optDefaultFormat];

    vItems := FarCreateMenu([
      GetMsg(StrMAnsi),
      GetMsg(StrMOEM),
      GetMsg(StrMUnicode),
      GetMsg(StrMUTF8),
      '',
      PFarChar(vStr)
    ], @N);
    try
      if Byte(vText.Format) <= 3 then
        vItems[Byte(vText.Format)].Flags := MIF_SELECTED;

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(StrCodePages),
        '',
        '',
        nil, nil,
        Pointer(vItems),
        N);

      if vRes = -1 then
        Exit;

      if vRes = 5 then begin
        if GetFileFormat(optDefaultFormat) then
          WriteSetup;
      end else
      if vRes <> Byte(vText.Format) then begin
        vText.LoadFile(TStrFileFormat(vRes));
        ReinitAndSaveCurrent(True);
      end;

    finally
      MemFree(vItems);
    end;
  end;


  function TTextsDlg.GetFileFormat(var AFormat :TStrFileFormat) :Boolean;
  var
    N, vRes :Integer;
    vItems :PFarMenuItemsArray;
  begin
    vItems := FarCreateMenu([
      GetMsg(StrMAnsi),
      GetMsg(StrMOEM),
      GetMsg(StrMUnicode),
      GetMsg(StrMUTF8)
    ], @N);
    try
      if Byte(AFormat) <= 3 then
        vItems[Byte(AFormat)].Flags := MIF_SELECTED;

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(StrCodePages),
        '',
        '',
        nil, nil,
        Pointer(vItems),
        N);

      Result := vRes <> -1;

      if Result then
        Byte(AFormat) := vRes;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.MainMenu;
  var
    I, N, vRes :Integer;
    vItems :PFarMenuItemsArray;
  begin
    vItems := FarCreateMenu([
      GetMsg(StrMNextDiff),
      GetMsg(StrMPrevDiff),
      '',
      GetMsg(StrMView2),
      GetMsg(StrMEdit2),
      GetMsg(strMCodePage),
      '',
      GetMsg(StrMOptions2)
    ], @N);
    try
      vRes := 0;
      while True do begin
        for I := 0 to N - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strCompTextsTitle),
          '',
          '',
          nil, nil,
          Pointer(vItems),
          N);

        if vRes = -1 then
          Exit;

        case vRes of
          0: GotoNextDiff(True);
          1: GotoNextDiff(False);
          2: {};
          3: ViewOrEditCurrent(False);
          4: ViewOrEditCurrent(True);
          5: ChangeFileFormat;
          6: {};
          7: OptionsMenu;
        end;

        Exit;
      end;

    finally
      MemFree(vItems);
    end;
  end;


  procedure TTextsDlg.OptionsMenu;
  var
    I, N, vRes :Integer;
    vItems :PFarMenuItemsArray;
  begin
    vItems := FarCreateMenu([
      GetMsg(StrMIgnoreEmptyLines),
      GetMsg(StrMIgnoreSpaces),
      GetMsg(StrMIgnoreCase),
      '',
      GetMsg(StrMShowLineNumbers),
      GetMsg(StrMShowSpaces),
      '',
      GetMsg(StrMColors2)
    ], @N);
    try
      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, optTextIgnoreEmptyLine);
        vItems[1].Flags := SetFlag(0, MIF_CHECKED1, optTextIgnoreSpace);
        vItems[2].Flags := SetFlag(0, MIF_CHECKED1, optTextIgnoreCase);

        vItems[4].Flags := SetFlag(0, MIF_CHECKED1, optShowLinesNumber);
        vItems[5].Flags := SetFlag(0, MIF_CHECKED1, optShowSpaces);

        for I := 0 to N - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strOptionsTitle2),
          '',
          '',
          nil, nil,
          Pointer(vItems),
          N);

        if vRes = -1 then
          Exit;

        case vRes of
          0: ToggleOption(optTextIgnoreEmptyLine, True);
          1: ToggleOption(optTextIgnoreSpace, True);
          2: ToggleOption(optTextIgnoreCase, True);
          3: {};
          4: ToggleOption(optShowLinesNumber);
          5: ToggleOption(optShowSpaces);
          6: {};
          7: ColorsMenu;
        end;
      end;

    finally
      MemFree(vItems);
    end;
  end;


  procedure TTextsDlg.ColorsMenu;
  var
    I, N, vRes :Integer;
    vItems :PFarMenuItemsArray;
  begin
    vItems := FarCreateMenu([
      GetMsg(strClNormalText),
      GetMsg(strClSelectedText),
      GetMsg(strClDifference),
      GetMsg(strClLineNumbers),
      GetMsg(strClCaption2),
      '',
      GetMsg(strRestoreDefaults)
    ], @N);
    try
      vRes := 0;
      while True do begin
        for I := 0 to N - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strColorsTitle),
          '',
          '',
          nil, nil,
          Pointer(vItems),
          N);

        if vRes = -1 then
          Exit;

        case vRes of
          0: ColorDlg('', optTextColor);
          1: ColorDlg('', optTextSelColor);
          2: ColorDlg('', optTextDiffColor);
          3: ColorDlg('', optTextNumColor, FGrid.NormColor);
          4: ColorDlg('', optTextHeadColor);
          5: {};
          6: RestoreDefTextColor;
        end;

        WriteSetupColors;
        InitColors;
        SendMsg(DM_REDRAW, 0, 0);
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TTextsDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}
  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE: begin
        ResizeDialog;
        UpdateHeader;
        UpdateFooter; { Чтобы центрировался status-line }
        SetCurrent(FGrid.CurRow, lmScroll);
      end;

      DN_MOUSECLICK:
        if (Param1 = IdHead1) or (Param1 = IdHead2) then
          NOP
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectCurrent(1);
          KEY_SHIFTENTER:
            SelectCurrent(2);

          KEY_CTRLPGUP:
            FGrid.GotoLocation(FGrid.CurCol, 0, lmScroll);
          KEY_CTRLPGDN:
            FGrid.GotoLocation(FGrid.CurCol, FGrid.RowCount - 1, lmScroll);

          KEY_ALTUP:
            GotoNextDiff(False);
          KEY_ALTDOWN:
            GotoNextDiff(True);
          KEY_LEFT:
            if FStrDelta > 0 then begin
              Dec(FStrDelta);
              SendMsg(DM_REDRAW, 0, 0);
            end;
          KEY_RIGHT:
            if FStrDelta < MaxInt {???} then begin
              Inc(FStrDelta);
              SendMsg(DM_REDRAW, 0, 0);
            end;
          KEY_TAB:
            begin
              FCurSide := 1 - FCurSide;
              SendMsg(DM_REDRAW, 0, 0);
            end;
(*
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
            LocSelectSameColor(0, 1);
          KEY_ALTSUBTRACT:
            LocSelectSameColor(0, -1);
*)
          KEY_F2:
            MainMenu;
          KEY_F3:
            ViewOrEditCurrent(False);
          KEY_F4:
            ViewOrEditCurrent(True);
          KEY_F8:
            ChangeFileFormat;
          KEY_F9:
            OptionsMenu;

          KEY_CTRL1:
            ToggleOption(optShowLinesNumber);
          KEY_CTRL2:
            ToggleOption(optShowSpaces);

(*
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
*)
        else
//        TraceF('Key: %d', [Param2]);
(*
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
*)
            Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  procedure TTextsDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ShowTextsDlg(ADiff :TTextDiff);
  var
    vDlg :TTextsDlg;
  begin
    vDlg := TTextsDlg.Create;
    try
      vDlg.FDiff := ADiff;

      vDlg.FResCmd := 0;
      if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
        Exit;

    finally
      FreeObj(vDlg);
    end;
  end;


  procedure CompareTexts(const AFileName1, AFileName2 :TString);
  begin
    CompareTextsEx(AFileName1, AFileName2, '', '');
  end;


  procedure CompareTextsEx(const AFileName1, AFileName2, AViewName1, AViewName2 :TString);
  var
    vDiff :TTextDiff;
  begin
    vDiff := GetTextDiffs(AFileName1, AFileName2);
    try
      vDiff.Text[0].ViewName := AViewName1;
      vDiff.Text[1].ViewName := AViewName2;
      ShowTextsDlg(vDiff);
    finally
      FreeObj(vDiff);
    end;
  end;


end.


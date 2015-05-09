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

    Far_API,
    FarCtrl,
    FarDlg,
    FarMenu,
    FarGrid,
    FarEdit,
    FarDraw,
    FarColorDlg,


    VisCompCtrl,
    VisCompTexts;


  type
    TDrawBufEx = class(TDrawBuf)
    public
      procedure PadFillAttr(APos, ACount :Integer; AColor1, AColor2 :Byte);
      procedure AddStrExpandTabsWithBits(AStr :PTChar; ALen :Integer; AModBits :TBits; AColor1, AColor2, AColor3 :Byte);
    end;

    TTextsDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FGrid1          :TFarEdit;
      FGrid2          :TFarEdit;
      FRowDiff        :TFarGrid;

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
      FNeedSetCursor  :Boolean;

      FDrawBuf        :TDrawBufEx;

      FResCmd         :Integer;

      FSetChanged     :Boolean;


      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);

      function RowDiffGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure RowDiffGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
      procedure RowDiffPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);

      procedure InitColors;
      procedure ResizeDialog;
      procedure UpdateHeader;
      procedure UpdateFooter;
      procedure ReinitGrid;
      procedure SyncGrids(AGrid :TFarEdit);
      procedure SetCurrent(AGrid :TFarEdit; AIndex :Integer; AMode :TLocationMode);
      function GetCurSide :Integer;
      function GetCurGrid :TFarEdit;

      function FindItem(const AItem :TRowsPair) :Integer;
      function GetItemAt(ADlgIndex :Integer) :TRowsPair;
      function GetNearestPresentRow(AVer, ARow :Integer) :Integer;

      procedure ReinitAndSaveCurrent(ANeedRecompare :Boolean = False);
      procedure ToggleOption(var AOption :Boolean; ANeedRecompare :Boolean = False);

      procedure CopySelected;
      procedure GotoNextDiff(AForward :Boolean; AFirst :Boolean = False);
      procedure ViewOrEditCurrent(AEdit :Boolean);
      procedure ChangeFileFormat;
      procedure MainMenu;
      procedure OptionsMenu;
      procedure ColorsMenu;

    public
      property Grid1 :TFarEdit read FGrid1;
      property Grid2 :TFarEdit read FGrid2;
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



  function CorrectPosByTabs(AStr :PTChar; ALen :Integer; APos :Integer; ATabLen :Integer) :Integer;
  var
    vEnd :PTChar;
    vPos, vSize :Integer;
  begin
    Result := 0;
    vEnd := AStr + ALen;
    vPos := 0;
    while (AStr < vEnd) and (APos > 0) do begin
      if AStr^ <> charTab then begin
        Inc(Result);
        Dec(APos);
        Inc(vPos);
      end else
      begin
        vSize := ATabLen - (vPos mod ATabLen);
        Inc(Result);
        Dec(APos, vSize);
        Inc(vPos, vSize);
      end;
      Inc(AStr);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TDrawBufEx                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TDrawBufEx.PadFillAttr(APos, ACount :Integer; AColor1, AColor2 :Byte);
  begin
    if APos + ACount > FCount then begin
      Add(' ', AColor1, APos + ACount - FCount);
      FChars[FCount] := #0;
    end;
    FillAttr(APos, ACount, AColor2);
  end;


  procedure TDrawBufEx.AddStrExpandTabsWithBits(AStr :PTChar; ALen :Integer; AModBits :TBits; AColor1, AColor2, AColor3 :Byte);
  var
    vEnd :PTChar;
    vChr :TChar;
    vAtr, vAtr1 :Byte;
    vSPos, vDPos, vDstLen, vSize :Integer;
  begin
    if not optShowCRLF then
      while (ALen > 0) and CharIsCRLF((AStr + ALen - 1)^) do
        Dec(ALen);

    vDstLen := ChrExpandTabsLen(AStr, ALen, optTabSize);
    if FCount + vDstLen + 1 > FSize then
      SetSize(FCount + vDstLen + 1);

    vEnd := AStr + ALen;
    vSPos := 0; vDPos := 0;
    while AStr < vEnd do begin
      vChr := AStr^;
      vAtr := AColor1;
      vAtr1 := AColor3;
      if (AModBits <> nil) and AModBits[vSPos] then begin
        vAtr := AColor2;
        vAtr1 := AColor2;
      end;

      if vChr <> charTab then begin
        Assert(vDPos < vDstLen);
        if CharIsCRLF(vChr) then
          vAtr := vAtr1;
        if (vChr = ' ') and optShowSpaces then begin
          vChr := optSpaceChar;
          vAtr := vAtr1;
        end;
        Add(vChr, vAtr);
        Inc(vDPos);
      end else
      begin
        vSize := optTabSize - (vDPos mod optTabSize);
        Assert(vDPos + vSize <= vDstLen);
        if optShowSpaces then begin
          Add(optTabChar, vAtr1);
          if vSize > 1 then
            Add(optTabSpaceChar, vAtr1, vSize - 1)
        end else
          Add(' ', vAtr, vSize);
        Inc(vDPos, vSize);
      end;
      Inc(AStr);
      Inc(vSPos);
    end;
    FChars[FCount] := #0;
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
    IdList1  = 3;
    IdLineV  = 4;
    IdList2  = 5;
    IdLineH  = 6;
    IdRows   = 7;
//  IdStatus = 8;


  constructor TTextsDlg.Create; {override;}
  begin
    inherited Create;
(*  FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec)); *)
    FDrawBuf := TDrawBufEx.Create;
  end;


  destructor TTextsDlg.Destroy; {override;}
  begin
    FreeObj(FDrawBuf);

    FreeObj(FGrid1);
    FreeObj(FGrid2);
    FreeObj(FRowDiff);
(*  FreeObj(FFilter); *)
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TTextsDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FGUID := cTextDlgID;
    FHelpTopic := 'CompareTexts';
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_Text,        3, 2, DX div 2, 1, DIF_SHOWAMPERSAND, '...'),
        NewItemApi(DI_Text,        DX div 2 + 1, 2, DX - 6, 1, DIF_SHOWAMPERSAND, '...'),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0 ),
        NewItemApi(DI_SINGLEBOX,   0, 0, 0, 0, 0),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0 ),
        NewItemApi(DI_SINGLEBOX,   0, 0, 0, 0, 0),
        NewItemApi(DI_USERCONTROL, 3, DY - 6, DX - 6, 2, DIF_NOFOCUS )
      ],
      @FItemCount
    );

    FGrid1 := TFarEdit.CreateEx(Self, IdList1);
    FGrid1.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos}, goNoVScroller ];
//  FGrid1.ShowCurrent := not optShowCursor;
    FGrid1.ShowCursor := optShowCursor;

    FGrid1.OnCellClick := GridCellClick;
    FGrid1.OnPosChange := GridPosChange;
    FGrid1.OnDeltaChange := GridPosChange;
    FGrid1.OnGetCellText := GridGetDlgText;
    FGrid1.OnGetCellColor := GridGetCellColor;
    FGrid1.OnPaintCell := GridPaintCell;

    FGrid2 := TFarEdit.CreateEx(Self, IdList2);
    FGrid2.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
//  FGrid2.ShowCurrent := not optShowCursor;
    FGrid2.ShowCursor := optShowCursor;

    FGrid2.OnCellClick := GridCellClick;
    FGrid2.OnPosChange := GridPosChange;
    FGrid2.OnDeltaChange := GridPosChange;
    FGrid2.OnGetCellText := GridGetDlgText;
    FGrid2.OnGetCellColor := GridGetCellColor;
    FGrid2.OnPaintCell := GridPaintCell;

    FRowDiff := TFarGrid.CreateEx(Self, IdRows);
    FRowDiff.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FRowDiff.OnGetCellText := RowDiffGetDlgText;
    FRowDiff.OnGetCellColor := RowDiffGetCellColor;
    FRowDiff.OnPaintCell := RowDiffPaintCell;
    FRowDiff.RowCount := 2;
  end;


  procedure TTextsDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    InitColors;
    ReinitGrid;

    if optEdtAutoscroll then
      GotoNextDiff(True, True);

    SendMsg(DM_SETFOCUS, IdList1, 0);
    FNeedSetCursor := True;
  end;


  function TTextsDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    Result := inherited CloseDialog(ItemID);
    if Result and FSetChanged then
      WriteSetup;
  end;


  procedure TTextsDlg.InitColors;
  begin
    FGrid1.NormColor := GetOptColor(optTextColor, COL_DIALOGTEXT);
    FGrid1.SelColor  := GetOptColor(optTextSelColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid2.NormColor := GetOptColor(optTextColor, COL_DIALOGTEXT);
    FGrid2.SelColor  := GetOptColor(optTextSelColor, COL_DIALOGLISTSELECTEDTEXT);

   {$ifdef Far3}
   {$else}
    SetItemFlags(IdHead1, DIF_SETCOLOR or DIF_SHOWAMPERSAND or optTextHeadColor);
    SetItemFlags(IdHead2, DIF_SETCOLOR or DIF_SHOWAMPERSAND or optTextHeadColor);

    SetItemFlags(IdLineV, DIF_SETCOLOR or FGrid1.NormColor);
    SetItemFlags(IdLineH, DIF_SETCOLOR or FGrid1.NormColor);
   {$endif Far3}
  end;


  procedure TTextsDlg.ResizeDialog;
  var
    vWidth, vHeight, vCenter :Integer;
    vRect, vRect1 :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := vSize.CX;
    vHeight := vSize.CY;

    vRect := SBounds(0, 0, vWidth-1, vHeight-1);
    SendMsg(DM_SHOWITEM, IdFrame, 0);

    if optTextHorzDiv then begin
      { Горизонтальная раскладка }
      vCenter := vRect.Top + (vRect.Bottom - vRect.Top) div 2;
      FHeadWidth1 := vRect.Right - vRect.Left;
      FHeadWidth2 := FHeadWidth1;

      vRect1 := SBounds(vRect.Left, vRect.Top, FHeadWidth1, 1);
      SendMsg(DM_SETITEMPOSITION, IdHead1, @vRect1);

      vRect1 := SBounds(vRect.Left, vCenter, FHeadWidth2, 1);
      SendMsg(DM_SETITEMPOSITION, IdHead2, @vRect1);

      vRect1 := SRect(vRect.Left, vRect.Top + 1, FHeadWidth1, vCenter - 1);
      FGrid1.Options := FGrid1.Options - [goNoVScroller];
      SendMsg(DM_SETITEMPOSITION, IdList1, @vRect1);
      FGrid1.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

      vRect1 := SRect(vRect.Left, vCenter + 1, FHeadWidth2, vRect.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdList2, @vRect1);
      FGrid2.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

      vRect1 := SBounds(vRect.Left, vRect.Bottom + 1, 5, 5);
      SendMsg(DM_SETITEMPOSITION, IdLineV, @vRect1);
      SendMsg(DM_SETITEMPOSITION, IdLineH, @vRect1);
      SendMsg(DM_SETITEMPOSITION, IdRows, @vRect1);
    end else
    begin
      { Вертикальная раскладка }
      vCenter := vRect.Left + (vRect.Right - vRect.Left) div 2;

      vRect1 := SRect(vRect.Left, vRect.Top, vCenter - 1, 1);
      SendMsg(DM_SETITEMPOSITION, IdHead1, @vRect1);
      FHeadWidth1 := vRect1.Right - vRect1.Left;

      vRect1 := SRect(vCenter + 1, vRect.Top, vRect.Right, 1);
      SendMsg(DM_SETITEMPOSITION, IdHead2, @vRect1);
      FHeadWidth2 := vRect1.Right - vRect1.Left;

      vRect1 := SRect(vRect.Left, vRect.Top + 1, vCenter - 1, vRect.Bottom - IntIf(optShowCurrentRows, 3, 0));
      FGrid1.Options := FGrid1.Options + [goNoVScroller];
      SendMsg(DM_SETITEMPOSITION, IdList1, @vRect1);
      FGrid1.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

      vRect1 := SRect(vCenter + 1, vRect.Top + 1, vRect.Right, vRect1.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdList2, @vRect1);
      FGrid2.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

      vRect1 := SRect(vCenter, vRect.Top + 1, vCenter, vRect1.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdLineV, @vRect1);

      vRect1 := SBounds(0, vRect1.Bottom + 1, vWidth-1, 0);
      SendMsg(DM_SETITEMPOSITION, IdLineH, @vRect1);

      vRect1 := SBounds(0, vRect1.Bottom + 1, vWidth-1, 2);
      SendMsg(DM_SETITEMPOSITION, IdRows, @vRect1);
    end;

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


  procedure TTextsDlg.UpdateHeader;
  var
    vStr, vStr2 :TString;
    vLen :Integer;
  begin
    vStr := GetMsgStr(strTitle);
//  if not FFilterMode then
//    vStr := Format('%s (%d)', [ vStr, FTotalCount ])
//  else
//    vStr := Format('%s [%s] (%d/%d)', [vStr, FFilterMask, FFilter.Count, FTotalCount ]);

    if length(vStr)+2 > FMenuMaxWidth then
      FMenuMaxWidth := length(vStr)+2;

    SetText(IdFrame, vStr);

    vStr := FDiff.Text[0].ViewName;
    if vStr = '' then
      vStr := FDiff.Text[0].Name;
    vStr2 := cFormatNames[FDiff.Text[0].Format];
    vLen := FHeadWidth1 - Length(vStr2) - 1 - 2;
    vStr := StrLeftAjust(ReduceFileName(vStr, vLen), vLen + 2);
    SetText(IdHead1, ' ' + vStr + vStr2);

    vStr := FDiff.Text[1].ViewName;
    if vStr = '' then
      vStr := FDiff.Text[1].Name;
    vStr2 := cFormatNames[FDiff.Text[1].Format];
    vLen := FHeadWidth2 - Length(vStr2) - 1 - 2;
    vStr := StrLeftAjust(ReduceFileName(vStr, vLen), vLen + 2);
    SetText(IdHead2, ' ' + vStr + vStr2);
  end;


  procedure TTextsDlg.UpdateFooter;
  begin
    {...}
  end;



  procedure TTextsDlg.SyncGrids(AGrid :TFarEdit);
  var
    vGrid :TFarEdit;
  begin
    if AGrid = FGrid1 then
      vGrid := FGrid2
    else
      vGrid := FGrid1;
    vGrid.ScrollTo(AGrid.DeltaX, AGrid.DeltaY);
    vGrid.GotoLocation(AGrid.CurCol, AGrid.CurRow, lmSimple);
    vGrid.EdtScrollTo(AGrid.EdtDelta);
    vGrid.GotoEdtPos(AGrid.EdtPos, lmSimple);
    vGrid.ClearSelection;
  end;


  procedure TTextsDlg.SetCurrent(AGrid :TFarEdit; AIndex :Integer; AMode :TLocationMode);
  begin
    AGrid.GotoLocation(FGrid1.CurCol, AIndex, AMode);
  end;


 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
  end;


  procedure TTextsDlg.GridPosChange(ASender :TFarGrid);
  begin
    if ASender = GetCurGrid then begin
      SyncGrids(TFarEdit(ASender));
//    if optShowCurrentRows then
//      FRowDiff.Redraw;
      SendMsg(DM_REDRAW, 0, 0);
    end;
  end;


  function TTextsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vItem :PCmpTextRow;
    vTag, vVer, vRow, vLen :Integer;
    vPtr :PTString;
  begin
    Result := '';
    if ARow < FDiff.DiffCount then begin
      vItem := FDiff[ARow];
      vVer := IntIf(ASender = FGrid1, 0, 1);
      vRow := vItem.FRow[vVer];

      if ACol < 0 then begin
        if vRow <> -1 then begin
          vPtr := FDiff.Text[vVer].PStrings[vRow];

          vLen := Length(vPtr^);
          while (vLen > 0) and CharIsCRLF(vPtr^[vLen]) do
            Dec(vLen);

          Result := ChrExpandTabs(PTChar(vPtr^), vLen, optTabSize);
        end;
      end else
      begin
        vTag := ASender.Column[ACol].Tag;
        vTag := (vTag and $FF00) shr 8;

        case vTag of
          1:
            NOP;
          2:
            if vRow <> -1 then
              Result := Int2Str(vRow + 1) + ' ';
        end;
      end;
    end;
  end;


  procedure TTextsDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
  var
    vItem :PCmpTextRow;
    vTag, vVer, vRow :Integer;
    vDiff :TRowDiff;
  begin
    if ARow < FDiff.DiffCount then begin
      vItem := FDiff[ARow];
      vVer := IntIf(ASender = FGrid1, 0, 1);
      vRow := vItem.FRow[vVer];

      if ACol < 0 then begin

        vDiff := nil;
        if optHilightRowsDiff then
          vDiff := FDiff.GetRowDiff(ARow);

        if vDiff <> nil then
          AColor := optTextDiffStrColor1
        else
        if vItem.FFlags = 0 then
          AColor := ASender.NormColor
        else
          AColor := optTextNewColor

      end else
      begin
        vTag := ASender.Column[ACol].Tag;

        if (vItem.FFlags <> 0) and (vRow = -1) then
          AColor := optTextDelColor;

        vTag := (vTag and $FF00) shr 8;
        case vTag of
          2:
            AColor := ChangeFG(AColor, optTextNumColor)
        end;
      end;
    end else
      AColor := ASender.NormColor;
  end;


  procedure TTextsDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);
  var
    vEdit :TFarEdit;
    vItem :PCmpTextRow;
    vVer, vRow :Integer;
    vDiff :TRowDiff;
    vPtr :PTString;
    vBits :TBits;
    vSelBeg, vSelEnd :Integer;
    vActive :Boolean;
  begin
    FDrawBuf.Clear;
    vEdit := TFarEdit(ASender);
    vVer := IntIf(ASender = FGrid1, 0, 1);
    if ARow < FDiff.DiffCount then begin
      vItem := FDiff[ARow];
      vRow := vItem.FRow[vVer];

      FDrawBuf.SetPalette([AColor,
        optTextActCursorColor, optTextPasCursorColor, ASender.SelColor,
        optTextDiffStrColor1, optTextDiffStrColor2,
        ChangeFG(AColor, optTextSpecColor)]);

      if vRow <> -1 then begin
        vPtr := FDiff.Text[vVer].PStrings[vRow];

        vDiff := nil;
        if optHilightRowsDiff then
          vDiff := FDiff.GetRowDiff(ARow);
        vBits := nil;
        if vDiff <> nil then
          vBits := vDiff.GetDiffBits(vVer);

        FDrawBuf.AddStrExpandTabsWithBits(PTChar(vPtr^), Length(vPtr^), vBits, IntIf(vDiff = nil, 0, 4), 5, 6);
      end;

      if vEdit.SelShow and (ARow >= vEdit.SelBeg.Y) and (ARow <= vEdit.SelEnd.Y) then begin
        vSelBeg := IntIf(ARow = vEdit.SelBeg.Y, vEdit.SelBeg.X, 0);
        vSelEnd := IntIf(ARow = vEdit.SelEnd.Y, vEdit.SelEnd.X, AWidth + vEdit.EdtPos);
        FDrawBuf.PadFillAttr(vSelBeg, vSelEnd - vSelBeg, 0, 3);
      end;
    end;

    vActive := vVer = GetCurSide;
    if (ARow = ASender.CurRow) and (vEdit.EdtPos >= vEdit.EdtDelta) and
      ((vActive and not optShowCursor) or (not vActive and not IsUndefColor(optTextPasCursorColor)))
    then
      FDrawBuf.PadFillAttr(vEdit.EdtPos, 1, 0, IntIf(vActive, 1, 2));

    if FDrawBuf.Count > vEdit.EdtDelta then
      FDrawBuf.Paint(X, Y, vEdit.EdtDelta, AWidth);
  end;


 {-----------------------------------------------------------------------------}

  function TTextsDlg.RowDiffGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vDiffRow, vVer, vRow :Integer;
    vItem :PCmpTextRow;
    vGrid :TFarGrid;
  begin
    Result := '';
    vGrid := GetCurGrid;
    if (vGrid = nil) or not optShowCurrentRows then
      Exit;
    vDiffRow := vGrid.CurRow;
    if vDiffRow < FDiff.DiffCount then begin
      vItem := FDiff[vDiffRow];
      vVer := ARow;
      vRow := vItem.FRow[vVer];
      case FRowDiff.Column[ACol].Tag of
        2:
          if vRow <> -1 then
            Result := Int2Str(vRow + 1) + ' ';
      end;
    end;
  end;


  procedure TTextsDlg.RowDiffGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
  var
    vDiffRow, vVer, vRow :Integer;
    vItem :PCmpTextRow;
    vDiff :TRowDiff;
    vGrid :TFarGrid;
  begin
    vGrid := GetCurGrid;
    if (vGrid = nil) or not optShowCurrentRows then
      Exit;
    vDiffRow := vGrid.CurRow;
    if vDiffRow < FDiff.DiffCount then begin
      vItem := FDiff[vDiffRow];

      if ACol < 0 then begin

        vDiff := FDiff.GetRowDiff(vDiffRow);

        if vDiff <> nil then
          AColor := optTextDiffStrColor1
        else
        if vItem.FFlags = 0 then
          AColor := vGrid.NormColor
        else
          AColor := optTextNewColor;
      end else
      begin
        vVer := ARow;
        vRow := vItem.FRow[vVer];

        if (vItem.FFlags <> 0) and (vRow = -1) then
          AColor := optTextDelColor;

        case FRowDiff.Column[ACol].Tag of
          2:
            AColor := ChangeFG(AColor, optTextNumColor)
        end;
      end;
    end else
      AColor := vGrid.NormColor;
  end;


  procedure TTextsDlg.RowDiffPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);
  var
    vDiffRow, vVer, vRow :Integer;
    vItem :PCmpTextRow;
    vDiff :TRowDiff;
    vPtr :PTString;
    vBits :TBits;
    vGrid :TFarGrid;
  begin
    vGrid := GetCurGrid;
    if (vGrid = nil) or not optShowCurrentRows then
      Exit;
    vDiffRow := vGrid.CurRow;
    if vDiffRow < FDiff.DiffCount then begin
      vItem := FDiff[vDiffRow];
      vVer := ARow;
      vRow := vItem.FRow[vVer];
      if vRow <> -1 then begin
        vPtr := FDiff.Text[vVer].PStrings[vRow];

        vDiff := FDiff.GetRowDiff(vDiffRow);
        vBits := nil;
        if vDiff <> nil then
          vBits := vDiff.GetDiffBits(vVer);

        FDrawBuf.Clear;
        FDrawBuf.SetPalette([AColor, optTextDiffStrColor1, optTextDiffStrColor2, ChangeFG(AColor, optTextSpecColor)]);
        FDrawBuf.AddStrExpandTabsWithBits(PTChar(vPtr^), Length(vPtr^), vBits, IntIf(vDiff = nil, 0, 1), 2, 3);
        FDrawBuf.Paint(X, Y, 0, AWidth);
      end;
    end;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.ReinitGrid;
  var
    I, vRow, vMaxLen1, vMaxLen2, vNumLen, vMaxRow1, vMaxRow2 :Integer;
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
    vNumLen := Length(Int2Str(vMaxRow1));

    FGrid1.ResetSize;
    FGrid1.Columns.FreeAll;
    if optShowLinesNumber then
      FGrid1.Columns.Add( TColumnFormat.CreateEx('', '', vNumLen+1, taRightJustify, [coNoVertLine], $0201) );
    FGrid1.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coOwnerDraw], $0101) );
    FGrid1.Margin := IntIf(optShowLinesNumber, vNumLen+1, 0);

    FGrid2.ResetSize;
    FGrid2.Columns.FreeAll;
    if optShowLinesNumber then
      FGrid2.Columns.Add( TColumnFormat.CreateEx('', '', vNumLen+1, taRightJustify, [coNoVertLine], $0202) );
    FGrid2.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coOwnerDraw], $0102) );
    FGrid2.Margin := IntIf(optShowLinesNumber, vNumLen+1, 0);

    FRowDiff.ResetSize;
    FRowDiff.Columns.FreeAll;
    if optShowLinesNumber then
      FRowDiff.Columns.Add( TColumnFormat.CreateEx('', '', vNumLen+1, taRightJustify, [coNoVertLine], 2) );
    FRowDiff.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coOwnerDraw], 1) );

(*  FSelectedCount[0] := 0;
    FSelectedCount[1] := 0;  *)
    FGrid1.RowCount := FDiff.DiffCount + 1;
    FGrid2.RowCount := FDiff.DiffCount + 1;

//  SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
      UpdateHeader;
      UpdateFooter;
    finally
//    SendMsg(DM_ENABLEREDRAW, 1, 0);
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
    {!!!-???}
    for I := 0 to FGrid1.RowCount - 1 do begin
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


  function TTextsDlg.GetCurSide :Integer;
  begin
    Result := -1;
    case SendMsg(DM_GETFOCUS, 0, 0) of
      IDList1: Result := 0;
      IDList2: Result := 1;
    end;
  end;


  function TTextsDlg.GetCurGrid :TFarEdit;
  begin
    Result := nil;
    case SendMsg(DM_GETFOCUS, 0, 0) of
      IDList1: Result := FGrid1;
      IDList2: Result := FGrid2;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.ReinitAndSaveCurrent(ANeedRecompare :Boolean = False);
  var
    vTopItem, vCurItem :TRowsPair;
    vIndex :Integer;
    vGrid :TFarEdit;
  begin
//  SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      vTopItem := GetItemAt( FGrid1.DeltaY );
      vCurItem := GetItemAt( FGrid1.CurRow );
      if ANeedRecompare then
        FDiff.Compare;
      ReinitGrid;
      vIndex := FindItem(vTopItem);
      if vIndex <> -1 then
        FGrid1.ScrollTo(FGrid1.DeltaY, vIndex);
      vIndex := FindItem(vCurItem);
      if vIndex <> -1 then
        FGrid1.GotoLocation(FGrid1.CurCol, vIndex, lmSimple );

      vGrid := GetCurGrid;
      if vGrid <> nil then
        vGrid.MoveCursor;
    finally
//    SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TTextsDlg.ToggleOption(var AOption :Boolean; ANeedRecompare :Boolean = False);
  begin
    AOption := not AOption;
    ReinitAndSaveCurrent(ANeedRecompare);
//  WriteSetup;
    FSetChanged := True;
  end;



  procedure TTextsDlg.ViewOrEditCurrent(AEdit :Boolean);
  var
    vSide, vRow, vCol :Integer;
    vSave :THandle;
    vGrid :TFarEdit;
    vPStr :PTString;
  begin
    vGrid := GetCurGrid;
    vSide := GetCurSide;
    if vSide = -1 then
      begin Beep; Exit; end;

    { Глючит, если в процессе просмотра/редактирования файла изменить размер консоли...}
//  SendMsg(DM_ShowDialog, 0, 0);
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      GEditorTopRow := GetNearestPresentRow(vSide, vGrid.DeltaY);
      vRow := GetNearestPresentRow(vSide, vGrid.CurRow);

      vCol := 0;
      if vRow > 0 then begin
        vPStr := FDiff.Text[vSide].PStrings[vRow];
        vCol := CorrectPosByTabs(PTChar(vPStr^), Length(vPStr^), vGrid.EdtPos, optTabSize);
      end;

      FarEditOrView(FDiff.Text[vSide].Name, AEdit, EF_ENABLE_F6, vRow + 1, vCol + 1);

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
    for I := ARow to FDiff.DiffCount - 1 do begin
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


  procedure TTextsDlg.GotoNextDiff(AForward :Boolean; AFirst :Boolean = False);
  var
    vRow :Integer;
    vGrid :TFarEdit;
  begin
    vGrid := GetCurGrid;
    if vGrid = nil then
      Exit;

    vRow := vGrid.CurRow;
    if AForward then begin
      if AFirst then
        vRow := 0;
      if not AFirst then
        while (vRow < FDiff.DiffCount) and (FDiff[vRow].FFlags <> 0) do
          Inc(vRow);
      while (vRow < FDiff.DiffCount) and (FDiff[vRow].FFlags = 0) do
        Inc(vRow);
      if vRow = FDiff.DiffCount then
        vRow := -1;
    end else
    begin
      if AFirst then
        vRow := FDiff.DiffCount;

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
      SetCurrent(vGrid, vRow, lmSafe)
    else
    if not AFirst then
      Beep;
  end;


  procedure TTextsDlg.CopySelected;
  var
    I, vSide, vRow, vLen, vBeg, vEnd :Integer;
    vItem :TRowsPair;
    vGrid :TFarEdit;
    vRows :TStringList;
    vPStr :PTString;
  begin
    vSide := GetCurSide;
    vGrid := GetCurGrid;
    if (vGrid = nil) or not vGrid.SelShow then
      Exit;

    vRows := TStringList.Create;
    try
      for I := vGrid.SelBeg.y to vGrid.SelEnd.y do begin
        vItem := GetItemAt(I);
        vRow := vItem[vSide];
        if vRow <> -1 then begin

          vPStr := FDiff.Text[vSide].PStrings[vRow];
          vLen := length(vPStr^);

          vBeg := 0;
          if I = vGrid.SelBeg.Y then
            vBeg := CorrectPosByTabs(PTChar(vPStr^), vLen, vGrid.SelBeg.X, optTabSize);

          vEnd := vLen;
          if I = vGrid.SelEnd.Y then
            vEnd := CorrectPosByTabs(PTChar(vPStr^), vLen, vGrid.SelEnd.X, optTabSize);

          if (vBeg = 0) and (vEnd = vLen) then
            vRows.Add(vPStr^)
          else
            vRows.Add(Copy(vPStr^, vBeg + 1, vEnd - vBeg));
        end;
      end;

      FarCopyToClipboard(vRows.GetTextStrEx(''));  //#13#10 - Уже в составе строки

    finally
      FreeObj(vRows);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TTextsDlg.ChangeFileFormat;
  var
    vMenu :TFarMenu;
    vSide :Integer;
    vText :TText;
    vStr :TFarStr;
  begin
    vSide := GetCurSide;
    if vSide = -1 then
      begin Beep; Exit; end;

    vText := FDiff.Text[vSide];

    vStr := GetMsgStr(strMDefault) + ' ' + cFormatNames[optDefaultFormat];

    vMenu := TFarMenu.CreateEx(
      GetMsg(StrCodePages),
    [
      GetMsg(StrMAnsi),
      GetMsg(StrMOEM),
      GetMsg(StrMUnicode),
      GetMsg(StrMUTF8),
      '',
      PFarChar(vStr)
    ]);
    try
      if Byte(vText.Format) <= 3 then
        vMenu.SetSelected(Byte(vText.Format));

      if not vMenu.Run then
        Exit;

      if vMenu.ResIdx = 5 then begin
        if GetCodePage(optDefaultFormat) then begin
//        WriteSetup;
          FSetChanged := True;
        end;
      end else
      if vMenu.ResIdx <> Byte(vText.Format) then begin
        vText.LoadFile(TStrFileFormat(vMenu.ResIdx));
        ReinitAndSaveCurrent(True);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TTextsDlg.MainMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCompTextsTitle),
    [
      GetMsg(StrMNextDiff),
      GetMsg(StrMPrevDiff),
      '',
      GetMsg(StrMView2),
      GetMsg(StrMEdit2),
      GetMsg(strMCodePage),
      '',
      GetMsg(StrMOptions2)
    ]);
    try
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: GotoNextDiff(True);
        1: GotoNextDiff(False);
        2: {};
        3: ViewOrEditCurrent(False);
        4: ViewOrEditCurrent(True);
        5: ChangeFileFormat;
        6: {};
        7: OptionsMenu;
      end;
    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TTextsDlg.OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle2),
    [
      GetMsg(StrMIgnoreEmptyLines),
      GetMsg(StrMIgnoreSpaces),
      GetMsg(StrMIgnoreCase),
      GetMsg(StrMIgnoreCRLF),
      '',
      GetMsg(StrMShowLineNumbers),
      GetMsg(strMShowCurrentRows),
      GetMsg(strMHilightRowDiff),
      GetMsg(StrMShowSpaces),
      GetMsg(StrMShowCRLF),
      '',
      GetMsg(strMHorizontalDivide),
      GetMsg(StrMColors2)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optTextIgnoreEmptyLine;
        vMenu.Checked[1] := optTextIgnoreSpace;
        vMenu.Checked[2] := optTextIgnoreCase;
        vMenu.Checked[3] := optTextIgnoreCRLF;

        vMenu.Checked[5] := optShowLinesNumber;
        vMenu.Checked[6] := optShowCurrentRows;
        vMenu.Checked[7] := optHilightRowsDiff;
        vMenu.Checked[8] := optShowSpaces;
        vMenu.Checked[9] := optShowCRLF;

        vMenu.Checked[11] := optTextHorzDiv;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ToggleOption(optTextIgnoreEmptyLine, True);
          1: ToggleOption(optTextIgnoreSpace, True);
          2: ToggleOption(optTextIgnoreCase, True);
          3: ToggleOption(optTextIgnoreCRLF, True);

          5: ToggleOption(optShowLinesNumber);
          6: ToggleOption(optShowCurrentRows);
          7: ToggleOption(optHilightRowsDiff);
          8: ToggleOption(optShowSpaces);
          9: ToggleOption(optShowCRLF);

         11: ToggleOption(optTextHorzDiv);
         12: ColorsMenu;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TTextsDlg.ColorsMenu;
  var
    vMenu :TFarMenu;
    vBkColor :DWORD;
  begin
    vBkColor := GetColorBG(FGrid1.NormColor);

    vMenu := TFarMenu.CreateEx(
      GetMsg(strColorsTitle),
    [
      GetMsg(strClNormalText),
      GetMsg(strClSelectedText),
      GetMsg(strClNewLine),
      GetMsg(strClDelLine),
      GetMsg(strClDiffLine),
      GetMsg(strClDiffChars),
      GetMsg(strClLineNumbers),
      GetMsg(strClCaption2),
      GetMsg(strClCursor),
      GetMsg(strClPCursor),
      GetMsg(strClSpecSymbols),
      '',
      GetMsg(strRestoreDefaults)
    ]);
    try
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ColorDlg('', optTextColor);
          1: ColorDlg('', optTextSelColor);
          2: ColorDlg('', optTextNewColor);
          3: ColorDlg('', optTextDelColor);
          4: ColorDlg('', optTextDiffStrColor1);
          5: ColorDlg('', optTextDiffStrColor2);
          6: ColorDlg('', optTextNumColor, vBkColor);
          7: ColorDlg('', optTextHeadColor);
          8: ColorDlg('', optTextActCursorColor);
          9: ColorDlg('', optTextPasCursorColor);
         10: ColorDlg('', optTextSpecColor, vBkColor);
         11: {};
         12: RestoreDefTextColor;
        end;

        WriteSetupColors;
        InitColors;
        SendMsg(DM_REDRAW, 0, 0);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TTextsDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      KEY_TAB:
        if GetCurSide = 0 then
          SendMsg(DM_SETFOCUS, IdList2, 0)
        else
          SendMsg(DM_SETFOCUS, IdList1, 0);

      KEY_ALTHOME:
        GotoNextDiff(True, True);
      KEY_ALTEND:
        GotoNextDiff(False, True);
      KEY_ALTUP:
        GotoNextDiff(False);
      KEY_ALTDOWN:
        GotoNextDiff(True);

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
        ToggleOption(optShowCurrentRows);
      KEY_CTRL3:
        ToggleOption(optHilightRowsDiff);
      KEY_CTRL4:
        ToggleOption(optShowSpaces);
      KEY_CTRL5:
        ToggleOption(optShowCRLF);

     {$ifdef Debug}
      KEY_CTRL8:
        ToggleOption(optOptimization1, True);
      KEY_CTRL9:
        ToggleOption(optPostOptimization, True);
     {$endif Debug}

      KEY_CTRLINS, KEY_CTRLC:
        CopySelected;

    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TTextsDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}
  var
    vGrid :TFarEdit;
  begin
    Result := 1;
    case Msg of
     {$ifdef Far3}
      DN_CTLCOLORDLGITEM:
        if Param1 in [IdHead1, IdHead2] then
          CtrlPalette([optTextHeadColor], PFarDialogItemColors(Param2)^)
        else
        if Param1 in [IdLineV, IdLineH] then
          CtrlPalette([FGrid1.NormColor, FGrid1.NormColor, FGrid1.NormColor], PFarDialogItemColors(Param2)^)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
     {$endif Far3}

      DN_DRAGGED:
        { Запрещаем перемещение... }
        Result := 0;

      DN_ENTERIDLE:
        if FNeedSetCursor then begin
          vGrid := GetCurGrid;
          if vGrid <> nil then
            vGrid.MoveCursor;
          FNeedSetCursor := False;
        end;

      DN_RESIZECONSOLE: begin
        ResizeDialog;
        UpdateHeader;
        UpdateFooter; { Чтобы центрировался status-line }
        vGrid := GetCurGrid;
        if vGrid <> nil then
          SetCurrent(vGrid, vGrid.CurRow, lmScroll);
        FNeedSetCursor := True;
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


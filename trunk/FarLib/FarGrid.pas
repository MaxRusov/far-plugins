{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* TFarGrid - элемент диалога "таблица"                                       *}
{******************************************************************************}

{$I Defines.inc}

unit FarGrid;

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
    FarDlg;


 const
   MinColWidth = 1;

 type
   TFarGrid = class;

   TColOptions = set of (
     coColMargin,
     coOwnerDraw,
     coNoVertLine
   );

   TGridOptions = set of (
     goRowSelect,
     goWrapMode,
     goFollowMouse,
     goWheelMovePos
   );

   TColumnFormat = class(TBasis)
   public
     constructor CreateEx(const AName, AHeader :TString; AWidth :Integer; Alignment :TAlignment; AOptions :TColOptions; ATag :Integer);

   private
     FName         :TString;
     FHeader       :TString;
//   FFooter       :TString;
//   FHint         :TString;
     FWidth        :Integer;
     FMinWidth     :Integer;
     FRealWidth    :Integer;
     FAlignment    :TAlignment;
     FOptions      :TColOptions;
//   FSortMark     :TColSortMark;
     FTag          :Integer;

   public
     property Width :Integer read FWidth write FWidth;
     property MinWidth :Integer read FMinWidth write FMinWidth;
     property RealWidth :Integer read FRealWidth;
     property Alignment :TAlignment read FAlignment write FAlignment;
     property Options :TColOptions read FOptions write FOptions;
     property Tag :Integer read FTag write FTag;
   end;


   TGridHotSpot = (
     ghsNone,
     ghsCell,
     ghsScrollUp,
     ghsScrollDn,
     ghsScrollPgUp,
     ghsScrollPgDn,
     ghsScrollThumb,
//   ghsColumnSize,
//   ghsColumnHead,
//   ghsColumnFooter,
     ghsRowSelect
   );

   TGridDragWhat = (
     dwNone,
     dwCell,
     dwScrollThumb
//   dwColumnSize,
//   dwHeaderPress,
//   dwFooterPress
   );

   TGetCellText = function(ASender :TFarGrid; ACol, ARow :Integer) :TString of object;
   TGetCellColor = procedure(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer) of object;
   TPaintCell = procedure(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer) of object;
   TCellClick = procedure(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean) of object;
   TPosChange = procedure(ASender :TFarGrid) of object;

   TFarGrid = class(TFarCustomControl)
   public
     constructor Create; override;
     destructor Destroy; override;

     function HitTest(X, Y :Integer; var ACol, ARow :Integer) :TGridHotSpot;
     procedure CoordFromPoint(X, Y :Integer; var ACol, ARow :Integer);
     function CalcColByDelta(ADelta :Integer) :Integer;
     procedure GotoLocation(ACol, ARow :Integer; AMode :TLocationMode);
     procedure EnsureOnScreen(ACol, ARow1, ARow2 :Integer; AMode :TLocationMode);
     procedure ScrollTo(ADeltaX, ADeltaY :Integer);

     procedure ResetSize;
     procedure UpdateSize(ALeft, ATop, AWidth, AHeight :Integer);

     procedure DrawChr(X, Y :Integer; AChr :PTChar; AMaxLen :Integer; AColor :Integer);
     procedure DrawChrEx(X, Y :Integer; AChr :PTChar; AMaxLen, ASelPos, ASelLen :Integer; AColor1, AColor2 :Integer);

   protected
     procedure PosChange; virtual;

     procedure PaintRow(X, Y, AWidth :Integer; ARow :Integer); virtual;
     procedure PaintCell(X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); virtual;
     procedure Paint(const AItem :TFarDialogItem); override;

     function KeyDown(AKey :Integer) :Boolean; override;
     function MouseEvent(var AMouse :TMouseEventRecord) :Boolean; override;
     function MouseClick(const AMouse :TMouseEventRecord) :Boolean; override;

   private
     FNormColor      :Integer;
     FSelColor       :Integer;

     FOptions        :TGridOptions;
     FWheelDY        :Integer;

     FColumns        :TObjList;
     FAllWidth       :Integer;

     FLeft           :Integer;
     FTop            :Integer;
     FWidth          :Integer;
     FHeight         :Integer;
     FDeltaX         :Integer;
     FDeltaY         :Integer;
     FRowCount       :Integer;
     FCurRow         :Integer;
     FCurCol         :Integer;
     FFixedCol       :Integer;

     FDragWhat       :TGridDragWhat;
     FDragButton     :Integer;

     FMousePos       :TCoord;          { Чтобы лучше работал режим goFollowMouse }

     FRowBuf         :PFarChar;
     FRowLen         :Integer;
     FClipX1         :Integer;
     FClipX2         :Integer;

     FOnGetCellText  :TGetCellText;
     FOnGetCellColor :TGetCellColor;
     FOnPaintCell    :TPaintCell;
     FOnCellClick    :TCellClick;
     FOnPosChange    :TPosChange;

     procedure PaintVScroller(X, Y  :Integer);
     procedure DrawBuf(X, Y :Integer; AColor :Integer);

     procedure RecalcSize;
     procedure SetRowCount(ACount :Integer);
     function GetColumn(AIndex :Integer) :TColumnFormat;

   public
     property RowBuf :PFarChar read FRowBuf;

   public
     property Left :Integer read FLeft;
     property Top :Integer read FTop;
     property Width :Integer read FWidth;
     property Height :Integer read FHeight;

     property NormColor :Integer read FNormColor write FNormColor;
     property SelColor :Integer read FSelColor write FSelColor;
     property Options :TGridOptions read FOptions write FOptions;
     property WheelDY :Integer read FWheelDY write FWheelDY;

     property Columns :TObjList read FColumns;
     property Column[I :Integer] :TColumnFormat read GetColumn;
     property FixedCol :Integer read FFixedCol write FFixedCol;

     property RowCount :Integer read FRowCount write SetRowCount;
     property CurCol :Integer read FCurCol;
     property CurRow :Integer read FCurRow;
     property DeltaX :Integer read FDeltaX;
     property DeltaY :Integer read FDeltaY;

     property OnGetCellText :TGetCellText read FOnGetCellText write FOnGetCellText;
     property OnGetCellColor :TGetCellColor read FOnGetCellColor write FOnGetCellColor;
     property OnPaintCell :TPaintCell read FOnPaintCell write FOnPaintCell;
     property OnCellClick :TCellClick read FOnCellClick write FOnCellClick;
     property OnPosChange :TPosChange read FOnPosChange write FOnPosChange;
   end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TColumnFormat                                                               }
 {-----------------------------------------------------------------------------}

  constructor TColumnFormat.CreateEx(const AName, AHeader :TString; AWidth :Integer; Alignment :TAlignment; AOptions :TColOptions; ATag :Integer);
  begin
    Create;
    FName := AName;
    FHeader := AHeader;
    FWidth := AWidth;
    FAlignment := Alignment;
    FOptions := AOptions;
    FTag := ATag;
  end;


 {-----------------------------------------------------------------------------}
 { TFarGrid                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TFarGrid.Create; {override;}
  begin
    inherited Create;
    FColumns := TObjList.Create;
    FColumns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [], 0) );
    FNormColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));
    FSelColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUSELECTEDTEXT));

    FWheelDY := 3;
    FMousePos.X := -1;
  end;


  destructor TFarGrid.Destroy; {override;}
  begin
    MemFree(FRowBuf);
    FreeObj(FColumns);
    inherited Destroy;
  end;


  procedure TFarGrid.PaintVScroller(X, Y  :Integer);
  var
    I, vThumbY :Integer;
  begin
    FARAPI.Text(X, Y, FNormColor, chrUpArrow);
    Inc(Y);

    vThumbY := MulDiv(FDeltaY, FHeight - 3, FRowCount - FHeight);

    for I := 0 to FHeight - 3 do begin
      if I = vThumbY then
        FARAPI.Text(X, Y, FNormColor, chrDkHatch)
      else
        FARAPI.Text(X, Y, FNormColor, chrHatch);
      Inc(Y);
    end;

    FARAPI.Text(X, Y, FNormColor, chrDnArrow);
//  Inc(Y);
  end;


  procedure TFarGrid.DrawBuf(X, Y :Integer; AColor :Integer);
  begin
    if X < FClipX2 then begin
      if FClipX2 - X < FRowLen then
        FRowBuf[FClipX2 - X] := #0;
      FARAPI.Text(X, Y, AColor, FRowBuf);
    end;
  end;


  procedure TFarGrid.DrawChr(X, Y :Integer; AChr :PTChar; AMaxLen :Integer; AColor :Integer);
  begin
    if AMaxLen > FRowLen - 1 then
      AMaxLen := FRowLen - 1;
    SetFarChr(FRowBuf, AChr, AMaxLen);
    DrawBuf(X, Y, AColor);
  end;


  procedure TFarGrid.DrawChrEx(X, Y :Integer; AChr :PTChar; AMaxLen, ASelPos, ASelLen :Integer; AColor1, AColor2 :Integer);

    procedure LocDrawPart(var AChr :PTChar; var ARest :Integer; ALen :Integer; AColor :Integer);
    begin
      if ARest > 0 then begin
        if ALen > ARest then
          ALen := ARest;
        DrawChr(X, Y, AChr, ALen, AColor);
        Dec(ARest, ALen);
        Inc(AChr, ALen);
        Inc(X, ALen);
      end;
    end;

  begin
    if ASelLen = 0 then
      DrawChr(X, Y, AChr, AMaxLen, AColor1)
    else begin
      LocDrawPart(AChr, AMaxLen, ASelPos, AColor1);
      LocDrawPart(AChr, AMaxLen, ASelLen, AColor2);
      LocDrawPart(AChr, AMaxLen, AMaxLen, AColor1);
    end;
  end;


  procedure TFarGrid.PaintCell(X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  var
    vStr :TString;
    vColumn :TColumnFormat;
  begin
    vColumn := FColumns[ACol];

    vStr := '';
    if Assigned(FOnGetCellText) then
      vStr := FOnGetCellText(Self, ACol, ARow);

    SetFarStr(FRowBuf, vStr, AWidth);

    case vColumn.FAlignment of
      taRightJustify : Inc(X, IntMax(0, AWidth - length(vStr)));
      taCenter       : Inc(X, IntMax(0, (AWidth - length(vStr)) div 2));
    end;

    DrawBuf(X, Y, AColor);
  end;


  procedure TFarGrid.PaintRow(X, Y, AWidth :Integer; ARow :Integer);
  var
    I, vWidth :Integer;
    vColumn :TColumnFormat;
    vRowColor, vCellColor :Integer;
  begin
    vRowColor := FNormColor;
    if (ARow = FCurRow) and (goRowSelect in FOptions) then
      vRowColor := FSelColor;
    if Assigned(FOnGetCellColor) then
      FOnGetCellColor(Self, -1, ARow, vRowColor);

    for I := 0 to FColumns.Count - 1 do begin
      vColumn := FColumns[I];
      vWidth := vColumn.FRealWidth;
      if vWidth = 0 then
        vWidth := AWidth;

      vCellColor := vRowColor;
      if (ARow = FCurRow) and (I = FCurCol) then
        vCellColor := FSelColor;

      if Assigned(FOnGetCellColor) then
        FOnGetCellColor(Self, I, ARow, vCellColor);

      FillFarChar(FRowBuf, vWidth, ' ');
      FRowBuf[vWidth] := #0;
      DrawBuf(X, Y, vCellColor);

      if coColMargin in vColumn.FOptions then begin
        Inc(X);
        Dec(vWidth, 2);
      end;

      if vWidth > 0 then begin
        try
          if Assigned(FOnPaintCell) and (coOwnerDraw in vColumn.Options) then
            OnPaintCell(Self, X, Y, vWidth, I, ARow, vCellColor)
          else
            PaintCell(X, Y, vWidth, I, ARow, vCellColor);
        except
          {Nothing}
        end;
      end;

      Inc(X, vWidth);
      if coColMargin in vColumn.FOptions then
        Inc(X);

      if X >= FClipX2 then
        Break;

      if (I < FColumns.Count - 1) and not (coNoVertLine in vColumn.Options) then begin
//      StrLCopy(FRowBuf, chrVertLine, 1);
        FRowBuf[0] := chrVertLine;
        FRowBuf[1] := #0;
        DrawBuf(X, Y, vRowColor);
        Inc(X);
      end;
    end;
  end;


  procedure TFarGrid.Paint(const AItem :TFarDialogItem); {override;}
  var
    X, Y, vRow, vLimit, vWidth, vHeight :Integer;
    vRect :TSmallRect;
  begin
    vWidth := AItem.X2 - AItem.X1 + 1;
    vHeight := AItem.Y2 - AItem.Y1 + 1;

    UpdateSize(AItem.X1, AItem.Y1, vWidth, vHeight);

    if FRowLen < vWidth + 1  then begin
      ReallocMem(FRowBuf, (vWidth + 1) * SizeOf(TFarChar));
      FRowLen := vWidth + 1;
    end;

    vRect := FOwner.GetDlgRect;
    X := vRect.Left + AItem.X1;
    Y := vRect.Top + AItem.Y1;

    FClipX1 := X;
    FClipX2 := X + vWidth;

    vRow := FDeltaY;
    vLimit := IntMin(FRowCount, FDeltaY + vHeight);
    while vRow < vLimit do begin
      PaintRow(X, Y, vWidth, vRow);
      Inc(vRow);
      Inc(Y);
    end;

    if vRow < FDeltaY + vHeight then begin
      FillFarChar(FRowBuf, vWidth, ' ');
      FRowBuf[vWidth] := #0;
      while vRow < FDeltaY + vHeight do begin
        DrawBuf(X, Y, FNormColor);
        Inc(vRow);
        Inc(Y);
      end;
    end;

    if FRowCount > FHeight then
      PaintVScroller(vRect.Left + AItem.X2, vRect.Top + AItem.Y1);
  end;


  function TFarGrid.KeyDown(AKey :Integer) :Boolean; {override;}
  begin
    Result := False;
    case AKey of
      KEY_UP, KEY_NUMPAD8:
        if (goWrapMode in FOptions) and (FCurRow = 0) then
          GotoLocation(FCurCol, FRowCount - 1, lmScroll)
        else
          GotoLocation(FCurCol, FCurRow - 1, lmScroll);

      KEY_DOWN, KEY_NUMPAD2  :
        if (goWrapMode in FOptions) and (FCurRow = FRowCount - 1) then
          GotoLocation(FCurCol, 0, lmScroll)
        else
          GotoLocation(FCurCol, FCurRow + 1, lmScroll);

      KEY_LEFT, KEY_NUMPAD4  : GotoLocation(FCurCol - 1, FCurRow, lmScroll);
      KEY_RIGHT, KEY_NUMPAD6 : GotoLocation(FCurCol + 1, FCurRow, lmScroll);
      KEY_PGUP, KEY_NUMPAD9  : GotoLocation(FCurCol, FCurRow - FHeight, lmScroll);
      KEY_PGDN, KEY_NUMPAD3  : GotoLocation(FCurCol, FCurRow + FHeight, lmScroll);
      KEY_HOME, KEY_NUMPAD7  : GotoLocation(FCurCol, 0, lmScroll);
      KEY_END, KEY_NUMPAD1   : GotoLocation(FCurCol, FRowCount - 1, lmScroll);

      KEY_MSWHEEL_UP, KEY_MSWHEEL_DOWN:
        if goWheelMovePos in FOptions then
          GotoLocation(FCurCol, FCurRow + IntIf(AKey = KEY_MSWHEEL_UP, -1, +1), lmScroll)
        else
          ScrollTo(FDeltaX, FDeltaY + IntIf(AKey = KEY_MSWHEEL_UP, -FWheelDY, +FWheelDY));
    end;
  end;


  function TFarGrid.MouseEvent(var AMouse :TMouseEventRecord) :Boolean; {override;}
  var
    vPos :TCoord;
    vCol, vRow, vButton :Integer;
  begin
    Result := True;
    vPos := AMouse.dwMousePosition;
    with FOwner.GetDlgRect do begin
      Dec(vPos.X, FLeft + Left);
      Dec(vPos.Y, FTop + Top);
    end;

    vButton := 0;
    if AMouse.dwButtonState and FROM_LEFT_1ST_BUTTON_PRESSED <> 0 then
      vButton := 1;
    if AMouse.dwButtonState and RIGHTMOST_BUTTON_PRESSED <> 0 then
      vButton := 2;

//  TraceF('Mouse: Event: %d, Pos: %d x %d', [AMouse.dwEventFlags, vPos.X, vPos.Y]);

    if ((AMouse.dwEventFlags = 0) or (AMouse.dwEventFlags = DOUBLE_CLICK)) and (vButton <> 0) then begin
      { Нажатие }
      case HitTest( vPos.X, vPos.Y, vCol, vRow) of
        ghsCell:
          begin
            GotoLocation(vCol, vRow, lmSimple);
            if AMouse.dwEventFlags = DOUBLE_CLICK then begin
              FDragWhat := dwNone;
              if Assigned(FOnCellClick) then
                FOnCellClick(Self, vCol, vRow, vButton, True);
            end else
            begin
              FDragButton := vButton;
              FDragWhat := dwCell;
            end;
          end;
        ghsScrollUp:
          ScrollTo(FDeltaX, FDeltaY - 1);
        ghsScrollDn:
          ScrollTo(FDeltaX, FDeltaY + 1);
        ghsScrollPgUp:
          ScrollTo(FDeltaX, FDeltaY - FHeight);
        ghsScrollPgDn:
          ScrollTo(FDeltaX, FDeltaY + FHeight);
        ghsScrollThumb:
          begin
            ScrollTo(FDeltaX, vRow);
            FDragWhat := dwScrollThumb;
          end;
      end;
    end else
    if (AMouse.dwEventFlags = 0) and (AMouse.dwButtonState = 0) then begin
      { Отпускание }
      if FDragWhat = dwCell then begin
        FDragWhat := dwNone;
        case HitTest( vPos.X, vPos.Y, vCol, vRow) of
          ghsCell:
            if Assigned(FOnCellClick) then
              FOnCellClick(Self, vCol, vRow, FDragButton, False{!!!});
        end;
      end;
    end else
    if (AMouse.dwEventFlags = MOUSE_MOVED) then begin

      if AMouse.dwButtonState = 0 then
        FDragWhat := dwNone;

      if (FDragWhat = dwCell) and (FDragButton = 1) then begin
        CoordFromPoint(vPos.X, vPos.Y, vCol, vRow);
        GotoLocation(vCol, vRow, lmSimple);
      end else
      if FDragWhat = dwScrollThumb then begin
        vRow := MulDiv(vPos.Y - 1, FRowCount - FHeight, FHeight - 3 );
        ScrollTo(FDeltaX, vRow);
      end else
      if goFollowMouse in FOptions then begin
        if FMousePos.X = -1 then
          FMousePos := vPos;
        if (vPos.X <> FMousePos.X) or (vPos.Y <> FMousePos.Y) then begin
          FMousePos := vPos;
          case HitTest( vPos.X, vPos.Y, vCol, vRow) of
            ghsCell:
              GotoLocation(CurCol{vCol}, vRow, lmSimple);
          end;
        end;  
      end;

    end;
  end;


  function TFarGrid.MouseClick(const AMouse :TMouseEventRecord) :Boolean; {override;}
  begin
    Result := False;
  end;


  function TFarGrid.HitTest(X, Y :Integer; var ACol, ARow :Integer) :TGridHotSpot;
  var
    vThumbY :Integer;
  begin
    Result := ghsNone;
    if (X >= 0) and (X < FWidth) and (Y >= 0) and (Y < FHeight) then begin
      if (FRowCount > FHeight) and (X = FWidth - 1) then begin
        { Скроллер... }
        if Y = 0 then
          Result := ghsScrollUp
        else
        if Y = FHeight - 1 then
          Result := ghsScrollDn
        else begin
          vThumbY := MulDiv(FDeltaY, FHeight - 3, FRowCount - FHeight) + 1;
          if vThumbY = Y then begin
            Result := ghsScrollThumb;
            ARow := FDeltaY;
          end else
          if Y < vThumbY then
            Result := ghsScrollPgUp
          else
            Result := ghsScrollPgDn
        end;
      end else
      if Y < FRowCount - FDeltaY then begin
        ARow := FDeltaY + Y;
        ACol := CalcColByDelta(FDeltaX + X); {!!!-???}
        Result := ghsCell;
      end;
    end;
  end;


  procedure TFarGrid.CoordFromPoint(X, Y :Integer; var ACol, ARow :Integer);
  begin
    ARow := FDeltaY + RangeLimit(Y, 0, FHeight - 1);
    ACol := CalcColByDelta(FDeltaX + X);
  end;


  function TFarGrid.CalcColByDelta(ADelta :Integer) :Integer;
  var
    vCols, vCol, vDX, vWidth :Integer;
    vColumn :TColumnFormat;
  begin
    vCols := FColumns.Count;
    vCol := 0;
    vDX := 0;
    while vCol < vCols { - 1 } { Может вернуть номер клолнки = FColumns.Count } do begin
      vColumn := Column[vCol];
      vWidth := vColumn.FRealWidth;
      if not (coNoVertLine in vColumn.FOptions) then
        Inc(vWidth);
      if vDX + vWidth > ADelta then
        Break;
      inc(vDX, vWidth);
      inc(vCol);
    end;
    Result := vCol;
  end;


  procedure TFarGrid.GotoLocation(ACol, ARow :Integer; AMode :TLocationMode);
  begin
    ARow := RangeLimit(ARow, 0, FRowCount - 1);
    ACol := RangeLimit(ACol, FFixedCol, FColumns.Count - 1);

    if (ARow <> FCurRow) or (ACol <> FCurCol) then begin
//    HideEditor(True);

//    vAllow := True;
//    PosChanging(Col, Row, vAllow);
//    if not vAllow then
//      Exit;

      FCurRow := ARow;
      FCurCol := ACol;
      FOwner.SendMsg(DM_REDRAW, 0, 0);

      PosChange;
    end;

//  if (gloRangeSelect in FOptions) and (glocClearSelection in AOpt) then
//    ClearSelection;

    if (AMode <> lmSimple) and (FHeight > 0) then
      EnsureOnScreen(ACol, ARow, ARow, AMode);

//  if (glocCurrent in AOpt) and (gloAlwaysShowEditor in FOptions) then
//    ShowEditor;
  end;


  procedure TFarGrid.PosChange; {dynamic;}
  begin
//  CancelEditTimer;
//  PosChangeStart;
    if Assigned(FOnPosChange) then
      FOnPosChange(Self);
  end;


  procedure TFarGrid.EnsureOnScreen(ACol, ARow1, ARow2 :Integer; AMode :TLocationMode);
  var
    vDeltaY, vDeltaX :Integer;
    vMinDeltaY :Integer;
//  Ofs1, Ofs2 :Integer;
  begin
    vDeltaY := FDeltaY;
    vDeltaX := FDeltaX;

    vMinDeltaY := ARow2 - FHeight + 1;
    if (vDeltaY < vMinDeltaY) or (vDeltaY > ARow1) or (AMode = lmCenter) then begin
      if AMode in [lmSafe, lmCenter] then
        vDeltaY := IntMax(ARow1 - (FHeight div 2), 0);
      vDeltaY := IntMin(RangeLimit(vDeltaY, vMinDeltaY, ARow1), ARow1);
    end;
(*
   if not Can([gcwRowList]) and (FColumns.Count > 0) and (Col < FColumns.Count) then begin
      Ofs1 := CalcColOffset(Col);
      Ofs2 := CalcColOffset(Col + 1);
      vDeltaX := IntMax(vDeltaX, Ofs2 - FClientRect.Right);
      vDeltaX := IntMin(vDeltaX, Ofs1 - FreezeWidth);
    end;
*)
//  if (vDeltaY <> FDeltaY) or (vDeltaX <> FDeltaX) then
      ScrollTo(vDeltaX, vDeltaY);
  end;


  procedure TFarGrid.ScrollTo(ADeltaX, ADeltaY :Integer);
  begin
    ADeltaX := RangeLimit(ADeltaX, 0, 0 (*FAllWidth - FClientRect.Right!!!*));
    ADeltaY := RangeLimit(ADeltaY, 0, RowCount - FHeight);
    if (ADeltaX = FDeltaX) and (ADeltaY = FDeltaY) then
      Exit;

    FDeltaX := ADeltaX;
    FDeltaY := ADeltaY;

    FOwner.SendMsg(DM_REDRAW, 0, 0);
  end;



  procedure TFarGrid.RecalcSize;
  var
    I, M, K, W :Integer;
    vColumn :TColumnFormat;
  begin
    FAllWidth := 0;
    M := FColumns.Count;
    if M > 0 then begin

      K := 0;
      for I := 0 to M - 1 do begin
        vColumn := Column[I];
        if vColumn.FWidth > 0 then begin
          vColumn.FRealWidth := IntMax(vColumn.FWidth, IntIf(vColumn.FMinWidth > 0, vColumn.FMinWidth, MinColWidth));
          inc(FAllWidth, vColumn.FRealWidth);
          if not (coNoVertLine in vColumn.FOptions) and (I < M - 1) then
            inc(FAllWidth);
        end else
          inc(K);
      end;

      if K > 0 then begin
        W := FWidth - FAllWidth;
        if FRowCount > FHeight then
          Dec(W); { Есть скроллер }

        for I := 0 to M - 1 do begin
          vColumn := Column[I];
          if vColumn.FWidth = 0 then begin
            if not (coNoVertLine in vColumn.FOptions) and (I < M - 1) then begin
              inc(FAllWidth);
              dec(W);
            end;
            vColumn.FRealWidth := IntMax(W div K, IntIf(vColumn.FMinWidth > 0, vColumn.FMinWidth, MinColWidth));
            inc(FAllWidth, vColumn.FRealWidth);
            dec(W, vColumn.FRealWidth);
            dec(K);
          end;
        end;
      end;
    end;

//  if srwHeight in What then begin
//    W := FClientRect.Bottom;
//    dec(W, HeaderSize);
//    dec(W, FooterSize);
//    FRowsOnPage := IntMax(W div RealRowsHeight, 1);
//  end;
//
//  FAreaSize := Size(FAllWidth, RowsCount);
//  FViewSize := Size(FClientRect.Right, FRowsOnPage);
  end;


  procedure TFarGrid.ResetSize;
  begin
    FWidth := 0;
    FHeight := 0;
  end;


  procedure TFarGrid.UpdateSize(ALeft, ATop, AWidth, AHeight :Integer);
  begin
    FLeft := ALeft;
    FTop := ATop;
    if (AWidth <> FWidth) or (AHeight <> FHeight) then begin
      FWidth := AWidth;
      FHeight := AHeight;
      RecalcSize;
    end;
  end;


  procedure TFarGrid.SetRowCount(ACount :Integer);
  begin
    if FRowCount <> ACount then begin
      FRowCount := ACount;
      ResetSize;
    end;
  end;


  function TFarGrid.GetColumn(AIndex :Integer) :TColumnFormat;
  begin
    Result := FColumns[AIndex];
  end;



end.


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
    Far_API,
    FarCtrl,
    FarDlg;


 const
   MinColWidth  = 1;

   cScrollFirstDelay = 500;
   cScrollNextDelay  = 10;

 type
   TFarGrid = class;

   TColOptions = set of (
     coColMargin,
     coOwnerDraw,
     coNoVertLine
   );

   TGridOptions = set of (
     goShowTitle,
     goRowSelect,
     goWrapMode,
     goFollowMouse,
     goWheelMovePos,
     goNoVScroller
   );

   TColumnFormat = class(TBasis)
   public
     constructor CreateEx(const AName, AHeader :TString; AWidth :Integer; Alignment :TAlignment; AOptions :TColOptions; ATag :Integer);
     constructor CreateEx2(const AName, AHeader :TString; AWidth, AMinWidth :Integer; Alignment :TAlignment; AOptions :TColOptions; ATag :Integer);

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
     FTag          :Integer;

   public
     property Header :TString read FHeader write FHeader;
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
     ghsRowSelect,
     ghsTitle
   );

   TGridDragWhat = (
     dwNone,
     dwCell,
     dwScrollThumb,
//   dwColumnSize,
//   dwHeaderPress,
//   dwFooterPress
     dwUser1,
     dwUser2,
     dwUser3
   );

   TGetCellText = function(ASender :TFarGrid; ACol, ARow :Integer) :TString of object;
   TGetCellColor = procedure(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor) of object;
   TPaintRow = function(ASender :TFarGrid; X, Y, AWidth :Integer; ARow :Integer; {const} AColor :TFarColor) :Boolean of object;
   TPaintCell = procedure(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; {const} AColor :TFarColor) of object;
   TCellClick = procedure(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean) of object;
   TPosChange = procedure(ASender :TFarGrid) of object;

   TFarGrid = class(TFarCustomControl)
   public
     constructor Create; override;
     destructor Destroy; override;

     function ClientHeight :Integer;
     function ClientWidth :Integer;
     function HitTest(X, Y :Integer; var ACol, ARow :Integer) :TGridHotSpot;
     procedure CoordFromPoint(X, Y :Integer; var ACol, ARow :Integer);
     function CalcColByDelta(ADelta :Integer) :Integer;
     procedure GotoLocation(ACol, ARow :Integer; AMode :TLocationMode);
     procedure EnsureOnScreen(ACol, ARow1, ARow2 :Integer; AMode :TLocationMode);
     procedure ScrollTo(ADeltaX, ADeltaY :Integer);

     procedure ResetSize;
     procedure UpdateSize(ALeft, ATop, AWidth, AHeight :Integer);

     procedure DrawChr(X, Y :Integer; AChr :PTChar; AMaxLen :Integer; const AColor :TFarColor);
     procedure DrawStr(X, Y :Integer; const AStr :TString; AMaxLen :Integer; const AColor :TFarColor);
     procedure DrawChrEx(X, Y :Integer; AChr :PTChar; AMaxLen, ASelPos, ASelLen :Integer; const AColor1, AColor2 :TFarColor);

     function CalcGridColumnsWidth :Integer;
     procedure ReduceColumns(AMaxWidth :Integer);

     function KeyDown(AKey :Integer) :Boolean; override;

   protected
     procedure PosChange; virtual;
     procedure DeltaChange; virtual;
     procedure ColumnClick(ACol :Integer; AButton :Integer; ADouble :Boolean); virtual;

     procedure PaintTitles(X, Y :Integer);
     procedure PaintTitle(X, Y, AWidth :Integer; ACol :Integer; const AColor :TFarColor); virtual;
     procedure PaintRow(X, Y, AWidth :Integer; ARow :Integer); virtual;
     procedure PaintCell(X, Y, AWidth :Integer; ACol, ARow :Integer; const AColor :TFarColor); virtual;
     procedure Paint(const AItem :TFarDialogItem); override;

     function MouseEvent(const AMouse :TMouseEventRecord) :Boolean; override;
     procedure MouseDown(const APos :TCoord; AButton :Integer; ADouble :Boolean); virtual;
     procedure MouseMove(const APos :TCoord; AButton :Integer); virtual;
     procedure MouseUp(const APos :TCoord; AButton :Integer); virtual;
     function MouseClick(const AMouse :TMouseEventRecord) :Boolean; override;

     function EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; override;

   protected
     FNormColor      :TFarColor;
     FSelColor       :TFarColor;
     FTitleColor     :TFarColor;

     FOptions        :TGridOptions;
     FWheelDY        :Integer;
     FShowCurrent    :Boolean;

     FColumns        :TObjList;
     FAllWidth       :Integer;

     FLeft           :Integer;
     FTop            :Integer;
     FWidth          :Integer;
     FHeight         :Integer;
     FMargins        :TRect;
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
     FOnPaintRow     :TPaintRow;
     FOnPaintCell    :TPaintCell;
     FOnCellClick    :TCellClick;
     FOnTitleClick   :TCellClick;
     FOnPosChange    :TPosChange;
     FOnDeltaChange  :TPosChange;

     procedure PaintVScroller(X, Y  :Integer);
     procedure DrawBuf(X, Y :Integer; const AColor :TFarColor);

     procedure RecalcSize;
     procedure SetOptions(AOptions :TGridOptions);
     procedure SetRowCount(ACount :Integer);
     function GetColumn(AIndex :Integer) :TColumnFormat;

   public
     property RowBuf :PFarChar read FRowBuf;

   public
     property Left :Integer read FLeft;
     property Top :Integer read FTop;
     property Width :Integer read FWidth;
     property Height :Integer read FHeight;
     property Margins :TRect read FMargins;

     property NormColor :TFarColor read FNormColor write FNormColor;
     property SelColor :TFarColor read FSelColor write FSelColor;
     property TitleColor :TFarColor read FTitleColor write FTitleColor;
     property Options :TGridOptions read FOptions write SetOptions;
     property WheelDY :Integer read FWheelDY write FWheelDY;
     property ShowCurrent :Boolean read FShowCurrent write FShowCurrent;

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
     property OnPaintRow :TPaintRow read FOnPaintRow write FOnPaintRow;
     property OnPaintCell :TPaintCell read FOnPaintCell write FOnPaintCell;
     property OnCellClick :TCellClick read FOnCellClick write FOnCellClick;
     property OnTitleClick :TCellClick read FOnTitleClick write FOnTitleClick;
     property OnPosChange :TPosChange read FOnPosChange write FOnPosChange;
     property OnDeltaChange :TPosChange read FOnDeltaChange write FOnDeltaChange;
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

  constructor TColumnFormat.CreateEx2(const AName, AHeader :TString; AWidth, AMinWidth :Integer; Alignment :TAlignment; AOptions :TColOptions; ATag :Integer);
  begin
    CreateEx(AName, AHeader, AWidth, Alignment, AOptions, ATag);
    if AMinWidth > 0 then
      FMinWidth := IntMin(AMinWidth, AWidth);
  end;


 {-----------------------------------------------------------------------------}
 { TFarGrid                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TFarGrid.Create; {override;}
  begin
    inherited Create;
    FColumns := TObjList.Create;
    FColumns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [], 0) );
    FNormColor := FarGetColor(COL_MENUTEXT);
    FSelColor := FarGetColor(COL_MENUSELECTEDTEXT);
    FTitleColor := FarGetColor(COL_MENUHIGHLIGHT {COL_MENUTITLE});

    FWheelDY := 3;
    FMousePos.X := -1;
    FShowCurrent := True;
  end;


  destructor TFarGrid.Destroy; {override;}
  begin
    MemFree(FRowBuf);
    FreeObj(FColumns);
    inherited Destroy;
  end;


  procedure TFarGrid.PaintVScroller(X, Y  :Integer);
  var
    I, vThumbY, vHeight :Integer;
  begin
    FARAPI.Text(X, Y, FNormColor, chrUpArrow);
    Inc(Y);

    vHeight := ClientHeight;
    vThumbY := MulDiv(FDeltaY, vHeight - 3, FRowCount - vHeight);

    for I := 0 to vHeight - 3 do begin
      if I = vThumbY then
        FARAPI.Text(X, Y, FNormColor, chrDkHatch)
      else
        FARAPI.Text(X, Y, FNormColor, chrHatch);
      Inc(Y);
    end;

    FARAPI.Text(X, Y, FNormColor, chrDnArrow);
//  Inc(Y);
  end;


  procedure TFarGrid.DrawBuf(X, Y :Integer; const AColor :TFarColor);
  begin
    if X < FClipX2 then begin
      if FClipX2 - X < FRowLen then
        FRowBuf[FClipX2 - X] := #0;
      FARAPI.Text(X, Y, AColor, FRowBuf);
    end;
  end;


  procedure TFarGrid.DrawChr(X, Y :Integer; AChr :PTChar; AMaxLen :Integer; const AColor :TFarColor);
  begin
    if AMaxLen > FRowLen - 1 then
      AMaxLen := FRowLen - 1;
    SetFarChr(FRowBuf, AChr, AMaxLen);
    DrawBuf(X, Y, AColor);
  end;


  procedure TFarGrid.DrawStr(X, Y :Integer; const AStr :TString; AMaxLen :Integer; const AColor :TFarColor);
  begin
    DrawChr(X, Y, PTChar(AStr), AMaxLen, AColor);
  end;


  procedure TFarGrid.DrawChrEx(X, Y :Integer; AChr :PTChar; AMaxLen, ASelPos, ASelLen :Integer; const AColor1, AColor2 :TFarColor);

    procedure LocDrawPart(var AChr :PTChar; var ARest :Integer; ALen :Integer; const AColor :TFarColor);
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


  procedure TFarGrid.PaintCell(X, Y, AWidth :Integer; ACol, ARow :Integer; const AColor :TFarColor); {virtual;}
  var
    vLen :Integer;
    vStr :TString;
    vColumn :TColumnFormat;
  begin
    vColumn := FColumns[ACol];

    vStr := '';
    if Assigned(FOnGetCellText) then
      vStr := FOnGetCellText(Self, ACol, ARow);

    vLen := IntMin(AWidth, FRowLen - 1);
    SetFarStr(FRowBuf, vStr, vLen);

    case vColumn.FAlignment of
      taRightJustify : Inc(X, IntMax(0, AWidth - length(vStr)));
      taCenter       : Inc(X, IntMax(0, (AWidth - length(vStr)) div 2));
    end;

    DrawBuf(X, Y, AColor);
  end;


  procedure TFarGrid.PaintRow(X, Y, AWidth :Integer; ARow :Integer);
  var
    I, vWidth, vLen :Integer;
    vColumn :TColumnFormat;
    vRowColor, vCellColor :TFarColor;
  begin
    vRowColor := FNormColor;
    if (ARow = FCurRow) and (goRowSelect in FOptions) then
      vRowColor := FSelColor;
    if Assigned(FOnGetCellColor) then
      FOnGetCellColor(Self, -1, ARow, vRowColor);

    if Assigned(FOnPaintRow) then begin
      try
        if FOnPaintRow(Self, X, Y, AWidth, ARow, vRowColor) then
          Exit;
      except
        Exit;
      end;
    end;

    for I := 0 to FColumns.Count - 1 do begin
      vColumn := FColumns[I];
      vWidth := vColumn.FRealWidth;
      if vWidth = 0 then
        vWidth := AWidth;

      vCellColor := vRowColor;
      if (ARow = FCurRow) and (I = FCurCol) and not (goRowSelect in FOptions) then
        vCellColor := FSelColor;

      if Assigned(FOnGetCellColor) then
        FOnGetCellColor(Self, I, ARow, vCellColor);

      vLen := IntMin(vWidth, FRowLen - 1);
      FillFarChar(FRowBuf, vLen, ' ');
      FRowBuf[vLen] := #0;
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
        DrawChr(X, Y, chrVertLine, 1, vRowColor);
        Inc(X);
      end;
    end;
  end;


  procedure TFarGrid.PaintTitle(X, Y, AWidth :Integer; ACol :Integer; const AColor :TFarColor); {virtual;}
  var
    vLen :Integer;
    vStr :TString;
    vColumn :TColumnFormat;
  begin
    vColumn := FColumns[ACol];
    vStr := vColumn.FHeader;

    vLen := IntMin(AWidth, FRowLen - 1);
    SetFarStr(FRowBuf, vStr, vLen);

//  case vColumn.FAlignment of
//    taRightJustify : Inc(X, IntMax(0, AWidth - length(vStr)));
//    taCenter       : Inc(X, IntMax(0, (AWidth - length(vStr)) div 2));
//  end;
    Inc(X, IntMax(0, (AWidth - length(vStr)) div 2));

    DrawBuf(X, Y, AColor);
  end;


  procedure TFarGrid.PaintTitles(X, Y :Integer);
  var
    I, vWidth, vLen :Integer;
    vColumn :TColumnFormat;
  begin
    for I := 0 to FColumns.Count - 1 do begin
      vColumn := FColumns[I];
      vWidth := vColumn.FRealWidth;
      if vWidth = 0 then
//      vWidth := AWidth;  !!! - ???
        Continue;

      vLen := IntMin(vWidth, FRowLen - 1);
      FillFarChar(FRowBuf, vLen, ' ');
      FRowBuf[vLen] := #0;
      DrawBuf(X, Y, FNormColor);

      if coColMargin in vColumn.FOptions then begin
        Inc(X);
        Dec(vWidth, 2);
      end;

      if vWidth > 0 then begin
        try
          PaintTitle(X, Y, vWidth, I, FTitleColor);
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
        DrawChr(X, Y, chrVertLine, 1, FNormColor);
        Inc(X);
      end;
    end;
  end;


  procedure TFarGrid.Paint(const AItem :TFarDialogItem); {override;}
  var
    X, Y, vRow, vLimit, vWidth, vHeight :Integer;
    vRect :TSmallRect;
  begin
//  TraceF('%p Paint', [Pointer(Self)]);
    UpdateSize(AItem.X1, AItem.Y1, AItem.X2 - AItem.X1 + 1, AItem.Y2 - AItem.Y1 + 1);

    vWidth := ClientWidth;
    vHeight := ClientHeight;

    if FRowLen < vWidth + 1  then begin
      ReallocMem(FRowBuf, (vWidth + 1) * SizeOf(TFarChar));
      FRowLen := vWidth + 1;
    end;

    vRect := FOwner.GetDlgRect;
    X := vRect.Left + AItem.X1 + FMargins.Left;
    Y := vRect.Top + AItem.Y1 + FMargins.Top;

    FClipX1 := X;
    FClipX2 := X + vWidth;

    if goShowTitle in FOptions then
      PaintTitles(X, Y - 1);

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

    if (FRowCount > vHeight) and not (goNoVScroller in FOptions) then
      PaintVScroller(vRect.Left + AItem.X2 - FMargins.Right, vRect.Top + AItem.Y1 + FMargins.Top);
  end;


  function TFarGrid.EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; {override;}

   {$ifdef Far3}
    function LocGetValue(var ARec :TFarGetValue) :Integer;
    begin
      Result := 0;
      if ARec.fType in [7, 11] then begin
        ARec.StructSize := SizeOf(ARec);
        ARec.Value.fType := FMVT_INTEGER;
        ARec.Value.Value.fInteger := IntIf(ARec.fType = 7, CurRow + 1, RowCount);
        Result := 1
      end;
    end;
   {$endif Far3}

  begin
    Result := 1;
    case Msg of
      0: {};
     {$ifdef Far3}
      DN_GETVALUE:
        Result := LocGetValue(PFarGetValue(Param2)^);
     {$endif Far3}
    else
      Result := inherited EventHandler(Msg, Param1, Param2);
    end;
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
      KEY_PGUP, KEY_NUMPAD9  : GotoLocation(FCurCol, FCurRow - ClientHeight, lmScroll);
      KEY_PGDN, KEY_NUMPAD3  : GotoLocation(FCurCol, FCurRow + ClientHeight, lmScroll);
      KEY_HOME, KEY_NUMPAD7  : GotoLocation(FCurCol, 0, lmScroll);
      KEY_END, KEY_NUMPAD1   : GotoLocation(FCurCol, FRowCount - 1, lmScroll);

      KEY_MSWHEEL_UP, KEY_MSWHEEL_DOWN:
        if goWheelMovePos in FOptions then
          GotoLocation(FCurCol, FCurRow + IntIf(AKey = KEY_MSWHEEL_UP, -1, +1), lmScroll)
        else
          ScrollTo(FDeltaX, FDeltaY + IntIf(AKey = KEY_MSWHEEL_UP, -FWheelDY, +FWheelDY));
    end;
  end;


  procedure TFarGrid.ColumnClick(ACol :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
    if Assigned(FOnTitleClick) then
      FOnTitleClick(Self, ACol, 0, AButton, ADouble);
  end;


  procedure TFarGrid.MouseDown(const APos :TCoord; AButton :Integer; ADouble :Boolean); {override;}

    procedure LocScrollUntilRelease(ADelta :Integer);
    var
      vTick :DWORD;
      vDelay :Integer;
    begin
      ScrollTo(FDeltaX, FDeltaY + ADelta);
      FARAPI.Text(0, 0, UndefColor, nil);
      vTick := GetTickCount;
      vDelay := cScrollFirstDelay;
      while GetKeyState(VK_LBUTTON) < 0 do begin
        Sleep(1);
        if TickCountDiff(GetTickCount, vTick) >= vDelay then begin
          ScrollTo(FDeltaX, FDeltaY + ADelta);
          FARAPI.Text(0, 0, UndefColor, nil);
          vTick := GetTickCount;
          vDelay := cScrollNextDelay;
        end;
      end;
    end;

  var
    vCol, vRow :Integer;
  begin
    { Нажатие }
    case HitTest( APos.X, APos.Y, vCol, vRow) of
      ghsCell:
        begin
          GotoLocation(vCol, vRow, lmSimple);
          if ADouble then begin
            FDragWhat := dwNone;
            if Assigned(FOnCellClick) then
              FOnCellClick(Self, vCol, vRow, AButton, True);
          end else
          begin
            FDragButton := AButton;
            FDragWhat := dwCell;
          end;
        end;

      ghsScrollUp:   LocScrollUntilRelease(-1);
      ghsScrollDn:   LocScrollUntilRelease(+1);
      ghsScrollPgUp: LocScrollUntilRelease(-ClientHeight);
      ghsScrollPgDn: LocScrollUntilRelease(+ClientHeight);

      ghsScrollThumb:
        begin
          ScrollTo(FDeltaX, vRow);
          FDragWhat := dwScrollThumb;
        end;

      ghsTitle:
        ColumnClick(vCol, AButton, ADouble);
    end;
  end;


  procedure TFarGrid.MouseMove(const APos :TCoord; AButton :Integer); {override;}
  var
    vCol, vRow :Integer;
  begin
    if AButton = 0 then
      FDragWhat := dwNone;

    if (FDragWhat = dwCell) and (FDragButton = 1) then begin
      CoordFromPoint(APos.X, APos.Y, vCol, vRow);
      GotoLocation(vCol, vRow, lmSimple);
    end else
    if FDragWhat = dwScrollThumb then begin
      vRow := MulDiv(APos.Y - FMargins.Top - 1, FRowCount - ClientHeight, ClientHeight - 3 );
      ScrollTo(FDeltaX, vRow);
    end else
    if goFollowMouse in FOptions then begin
      if FMousePos.X = -1 then
        FMousePos := APos;
      if (APos.X <> FMousePos.X) or (APos.Y <> FMousePos.Y) then begin
        FMousePos := APos;
        case HitTest( APos.X, APos.Y, vCol, vRow) of
          ghsCell:
            GotoLocation(CurCol{vCol}, vRow, lmSimple);
        end;
      end;
    end;
  end;


  procedure TFarGrid.MouseUp(const APos :TCoord; AButton :Integer); {override;}
  var
    vCol, vRow :Integer;
  begin
    if FDragWhat = dwCell then begin
      FDragWhat := dwNone;
      case HitTest( APos.X, APos.Y, vCol, vRow) of
        ghsCell:
          if Assigned(FOnCellClick) then
            FOnCellClick(Self, vCol, vRow, FDragButton, False{!!!});
      end;
    end;
  end;


  function TFarGrid.MouseEvent(const AMouse :TMouseEventRecord) :Boolean; {override;}
  var
    vPos :TCoord;
    vButton :Integer;
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

//  TraceF('Mouse: Event: %d, Pos: %d x %d', [AMouse.dwEventFlags, AMouse.dwMousePosition.X, AMouse.dwMousePosition.Y]);
//  TraceF('Mouse: Event: %d, Pos: %d x %d', [AMouse.dwEventFlags, vPos.X, vPos.Y]);
    if AMouse.dwEventFlags = 0 then
      NOP;

    if ((AMouse.dwEventFlags = 0) or (AMouse.dwEventFlags = DOUBLE_CLICK)) and (vButton <> 0) then begin
      { Нажатие }
      MouseDown(vPos, vButton, AMouse.dwEventFlags = DOUBLE_CLICK)
    end else
    if (AMouse.dwEventFlags = 0) and (AMouse.dwButtonState = 0) then begin
      { Отпускание }
      MouseUp(vPos, vButton);
    end else
    if (AMouse.dwEventFlags = MOUSE_MOVED) then begin
      { Перемещение }
      MouseMove(vPos, vButton);
    end;
  end;


  function TFarGrid.MouseClick(const AMouse :TMouseEventRecord) :Boolean; {override;}
  begin
    Result := False;
  end;


  function TFarGrid.HitTest(X, Y :Integer; var ACol, ARow :Integer) :TGridHotSpot;
  var
    vHeight, vThumbY :Integer;
  begin
    Result := ghsNone;
    Dec(X, FMargins.Left); Dec(Y, FMargins.Top);
    if (X >= 0) and (X < CLientWidth) and (Y >= 0) and (Y < ClientHeight) then begin
      vHeight := ClientHeight;
      if (FRowCount > vHeight) and (X = ClientWidth - 1) and not (goNoVScroller in FOptions) then begin
        { Скроллер... }
        if Y = 0 then
          Result := ghsScrollUp
        else
        if Y = vHeight - 1 then
          Result := ghsScrollDn
        else begin
          vThumbY := MulDiv(FDeltaY, vHeight - 3, FRowCount - vHeight) + 1;
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
        ACol := CalcColByDelta(FDeltaX + X);
        Result := ghsCell;
      end;
    end else
    if (X >= 0) and (X < CLientWidth) and (Y = -1) and (goShowTitle in FOptions) then begin
      ACol := CalcColByDelta(FDeltaX + X);
      Result := ghsTitle;
    end;
  end;


  procedure TFarGrid.CoordFromPoint(X, Y :Integer; var ACol, ARow :Integer);
  begin
    Dec(Y, FMargins.Top); Dec(X, FMargins.Left);
    ARow := FDeltaY + RangeLimit(Y, 0, ClientHeight - 1);
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
  var
    vPosChanged :Boolean;
  begin
    ARow := RangeLimit(ARow, 0, FRowCount - 1);
    ACol := RangeLimit(ACol, FFixedCol, FColumns.Count - 1);

    vPosChanged := False;
    if (ARow <> FCurRow) or (ACol <> FCurCol) then begin
//    HideEditor(True);

//    vAllow := True;
//    PosChanging(Col, Row, vAllow);
//    if not vAllow then
//      Exit;

      FCurRow := ARow;
      FCurCol := ACol;
      if FShowCurrent then
        Redraw;

      vPosChanged := True;
    end;

//  if (gloRangeSelect in FOptions) and (glocClearSelection in AOpt) then
//    ClearSelection;

    if (AMode <> lmSimple) and (ClientHeight > 0) then
      EnsureOnScreen(ACol, ARow, ARow, AMode);

    if vPosChanged then
      PosChange;

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

    vMinDeltaY := ARow2 - CLientHeight + 1;
    if (vDeltaY < vMinDeltaY) or (vDeltaY > ARow1) or (AMode = lmCenter) then begin
      if AMode in [lmSafe, lmCenter] then
        vDeltaY := IntMax(ARow1 - (ClientHeight div 2), 0);
      vDeltaY := IntMin(RangeLimit(vDeltaY, vMinDeltaY, ARow1), ARow1);
    end;

// if not Can([gcwRowList]) and (FColumns.Count > 0) and (Col < FColumns.Count) then begin
//    Ofs1 := CalcColOffset(Col);
//    Ofs2 := CalcColOffset(Col + 1);
//    vDeltaX := IntMax(vDeltaX, Ofs2 - FClientRect.Right);
//    vDeltaX := IntMin(vDeltaX, Ofs1 - FreezeWidth);
//  end;

//  if (vDeltaY <> FDeltaY) or (vDeltaX <> FDeltaX) then
      ScrollTo(vDeltaX, vDeltaY);
  end;


  procedure TFarGrid.ScrollTo(ADeltaX, ADeltaY :Integer);
  begin
    ADeltaX := RangeLimit(ADeltaX, 0, 0 {FAllWidth - FClientRect.Right} );
    ADeltaY := RangeLimit(ADeltaY, 0, RowCount - ClientHeight);
    if (ADeltaX = FDeltaX) and (ADeltaY = FDeltaY) then
      Exit;

    FDeltaX := ADeltaX;
    FDeltaY := ADeltaY;

    DeltaChange;
    Redraw;
  end;


  procedure TFarGrid.DeltaChange; {dynamic;}
  begin
    if Assigned(FOnDeltaChange) then
      FOnDeltaChange(Self);
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
        W := ClientWidth - FAllWidth;
        if (FRowCount > ClientHeight) and not (goNoVScroller in FOptions) then
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


  procedure TFarGrid.SetOptions(AOptions :TGridOptions);
  begin
    if FOptions <> AOptions then begin
      FOptions := AOptions;
      FMargins := Bounds(0, 0, 0, 0);
      if goShowTitle in FOptions then
        Inc(FMargins.Top, 1);
      ResetSize;
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


  function TFarGrid.ClientHeight;
  begin
    Result := FHeight - FMargins.Top - FMargins.Bottom;
  end;


  function TFarGrid.ClientWidth;
  begin
    Result := FWidth - FMargins.Left - FMargins.Right;
  end;


 {-----------------------------------------------------------------------------}

  type
    TTabIndex = class(TIntList)
    protected
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;
    end;


  function TTabIndex.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    with TObject(Context) as TIntList do
      Result := IntCompare(Items[PInteger(PItem)^], Items[PInteger(PAnother)^]);
  end;


  procedure ReduceList(AWidths :TIntList; AOversize :Integer);
  var
    vIndex :TTabIndex;

    procedure LocReduce(AIndex :Integer);
    var
      I, vWidth, vNextWidth, vDelta :Integer;
    begin
      Assert(AIndex < vIndex.Count);
      vWidth := AWidths[ vIndex[AIndex] ];
      vNextWidth := 0;
      while AIndex < vIndex.Count do begin
        Inc(AIndex);
        if AIndex < vIndex.Count then begin
          vNextWidth := AWidths[ vIndex[AIndex] ];
          Assert(vNextWidth <= vWidth);
          if vNextWidth < vWidth then
            { Нашли "ступеньку"}
            Break;
        end;
      end;

      if (AIndex < vIndex.Count) and ((vWidth - vNextWidth) * AIndex < AOversize) then begin
        { Стешем вершки... }
        for I := 0 to AIndex - 1 do begin
          vWidth := AWidths[ vIndex[I] ];
          AWidths[ vIndex[I] ] := vNextWidth;
          Dec( AOversize, vWidth - vNextWidth );
        end;
        { И попробуем снова... }
        LocReduce(AIndex);
      end else
      begin
        { Последний "стес" }
        for I := AIndex - 1 downto 0 do begin
          vDelta := AOversize div (I + 1);
          vWidth := AWidths[ vIndex[I] ];
          AWidths[ vIndex[I] ] := vWidth - vDelta;
          Dec( AOversize, vDelta );
        end;
      end;
    end;

  var
    I :Integer;
  begin
    Assert((AWidths <> nil) and (AWidths.Count > 0) and (AOversize >= 0));
    vIndex := TTabIndex.Create;
    try
      for I := 0 to AWidths.Count - 1 do
        vIndex.Add(I);
      vIndex.SortList(False, Integer(AWidths));

      LocReduce(0);

    finally
      FreeObj(vIndex);
    end;
  end;


  procedure TFarGrid.ReduceColumns(AMaxWidth :Integer);
  var
    I, vWidth, vCanReduce :Integer;
    vDeltas :TIntList;
  begin
    vDeltas := TIntList.Create;
    try
      vWidth := 0; vCanReduce := 0;
      for I := 0 to FColumns.Count - 1 do
        with Column[I] do begin
          vDeltas.Add(Width - MinWidth);
          Inc(vCanReduce, Width - MinWidth);
          Inc(vWidth, Width);
        end;

      if (vWidth > AMaxWidth) and (vCanReduce > 0) then begin
        ReduceList(vDeltas, IntMin(vCanReduce, vWidth - AMaxWidth));

        for I := 0 to FColumns.Count - 1 do
          with Column[I] do
            Width := MinWidth + vDeltas[I];
      end;

    finally
      FreeObj(vDeltas);
    end;
  end;


  function TFarGrid.CalcGridColumnsWidth :Integer;
  var
    I :Integer;
  begin
    Result := 0;
    for I := 0 to FColumns.Count - 1 do
      with Column[I] do
        if Width <> 0 then begin
          Inc(Result, Width);
          if (I < FColumns.Count - 1) and not (coNoVertLine in Options) then
            Inc(Result);
        end;
  end;


end.


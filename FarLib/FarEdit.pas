{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* TFarEdit - элемент диалога "редактор"                                      *}
{******************************************************************************}

{$I Defines.inc}

unit FarEdit;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    Far_API,
    FarCtrl,
    FarGrid,
    FarDlg;


  type
    TEdtCommands =
    (
      cmNone,
      cmUp,
      cmDown,
      cmLeft,
      cmRight,
      cmPageUp,
      cmPageDown,
      cmPageBeg,
      cmPageEnd,
      cmTextBeg,
      cmTextEnd,
      cmHome,
      cmEnd,
      cmWordLeft,
      cmWordRight,
      cmScrollUp,
      cmScrollDown,
      cmScrollLeft,
      cmScrollRight,
      cmSelectAll,
      cmCopy
    );

  const
    cmGoFirst = cmUp;
    cmGoLast  = cmWordRight;

  type
    TSelMethod = (
      smNone,
      smKey,
      smMouse
    );

    TFarEdit = class(TFarGrid)
    public
      constructor Create; override;
//    destructor Destroy; override;

      procedure GotoEdtPos(APos :Integer; AMode :TLocationMode);
      procedure EdtScrollTo(ADelta :Integer);
      procedure EdtEnsureOnScreen(APos :Integer; AMode :TLocationMode);
      procedure SetCursor(AOn :Boolean);
      procedure MoveCursor;

      procedure SelectAll;
      procedure SelectWord;
      procedure ClearSelection;
      procedure CopySelection;

      function EdtKeyTranslate(AKey :Integer) :TEdtCommands;
      procedure EdtCommand(ACmd :TEdtCommands; AShift :Boolean);
      
      function KeyDown(AKey :Integer) :Boolean; override;

    protected
      procedure PosChange; override;
      procedure DeltaChange; override;

      procedure MouseDown(const APos :TCoord; AButton :Integer; ADouble :Boolean); override;
      procedure MouseMove(const APos :TCoord; AButton :Integer); override;
      procedure MouseUp(const APos :TCoord; AButton :Integer); override;
      function EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; override;

    private
      FEdtPos     :Integer;    { Позиция курсора в редактируемой колонке }
      FEdtDelta   :Integer;    { Смещение в редактируемой колонке }
      FMargin     :Integer;
      FCursorOn   :Boolean;
      FShowCursor :Boolean;

      FSelBeg     :TPoint;     { Начало выделенного блока }
      FSelEnd     :TPoint;     { Конец выделенного блока }
      FSelShow    :Boolean;    { Виден ли выделенный блок? }
      FSelMethod  :TSelMethod; { Вспомогательная, для процесса выделения }
      FSelStart   :TPoint;     { -/-/- }


      function GetString(ARow :Integer) :TString;

      procedure StartSelection(AMethod :TSelMethod);
      function LockSelection(Method :TSelMethod) :Boolean;
      procedure ContinueSelection;

    public
      property EdtPos :Integer read FEdtPos;
      property EdtDelta :Integer read FEdtDelta;
      property Margin :Integer read FMargin write FMargin;
      property ShowCursor :Boolean read FShowCursor write FShowCursor;

      property SelBeg :TPoint read FSelBeg;
      property SelEnd :TPoint read FSelEnd;
      property SelShow :Boolean read FSelShow;
    end;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TFarEdit                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TFarEdit.Create; {override;}
  begin
    inherited Create;
    FShowCursor := True;
    FShowCurrent := False;
  end;


  procedure TFarEdit.SetCursor(AOn :Boolean);
  var
    vCoord :TCoord;
  begin
    if not FShowCursor then
      AOn := False;
    if FCursorOn <> AOn then begin
      FCursorOn := AOn;
      if AOn then
        MoveCursor
      else begin
        vCoord.X := -1;
        vCoord.Y := -1;
        FOwner.SendMsg(DM_SETCURSORPOS, FControlID, @vCoord);
      end;
    end;
  end;


  procedure TFarEdit.MoveCursor;
  var
    vCoord :TCoord;
  begin
    if FCursorOn then begin
      vCoord.X := FEdtPos - FEdtDelta + FMargin;
      vCoord.Y := FCurRow - FDeltaY;
      FOwner.SendMsg(DM_SETCURSORPOS, FControlID, @vCoord);
      FOwner.SendMsg(DM_SETCURSORSIZE, FControlID, MAKELONG(1, 25));
    end;  
  end;


  procedure TFarEdit.PosChange; {override;}
  begin
    if FCursorOn then
      MoveCursor;
    inherited PosChange;
  end;


  procedure TFarEdit.DeltaChange; {override;}
  begin
    if FCursorOn then
      MoveCursor;
    inherited DeltaChange;
  end;


  procedure TFarEdit.GotoEdtPos(APos :Integer; AMode :TLocationMode);
  var
    vPosChanged :Boolean;
  begin
    APos := RangeLimit(APos, 0, MaxInt);

    vPosChanged := False;
    if APos <> FEdtPos then begin
      FEdtPos  := APos;
      if FShowCurrent then
        Redraw;
      vPosChanged := True;
    end;

    if (AMode <> lmSimple) {and (FHeight > 0)} then
      EdtEnsureOnScreen(APos, AMode);

    if vPosChanged then
      PosChange;
  end;


  procedure TFarEdit.EdtEnsureOnScreen(APos :Integer; AMode :TLocationMode);
  var
    vWidth, vNewDelta :Integer;
  begin
    vWidth := FWidth - FMargin;
    if (FRowCount > FHeight) and not (goNoVScroller in FOptions) then
      Dec(vWidth); { Есть скроллер }
    vNewDelta := RangeLimit(FEdtDelta, APos - vWidth + 1, APos);
    EdtScrollTo(vNewDelta);
  end;


  procedure TFarEdit.EdtScrollTo(ADelta :Integer);
  begin
    ADelta := RangeLimit(ADelta, 0, MaxInt);
    if ADelta = FEdtDelta then
      Exit;

    FEdtDelta  := ADelta;
    DeltaChange;

    Redraw;
  end;


  function TFarEdit.GetString(ARow :Integer) :TString;
  begin
    Result := '';
    if Assigned(FOnGetCellText) then
      Result := FOnGetCellText(Self, -1, ARow);
  end;


  procedure TFarEdit.SelectAll;
  begin
    FSelBeg   := Point(0, 0);
    FSelEnd   := Point(0, FRowCount);
    FSelShow  := FRowCount > 0;
    Redraw;
  end;


  procedure TFarEdit.SelectWord;
  var
    vStr :TString;
    vLen, vPos, vBeg :Integer;
  begin
    vStr := GetString(FCurRow);
    vLen := length(vStr);

    vPos := FEdtPos;
    while (vPos > 0) and ((vPos >= vLen) or not CharIsWordChar(vStr[vPos + 1])) do
      Dec(vPos);

    if (vPos < vLen) and CharIsWordChar(vStr[vPos + 1]) then begin
      while (vPos > 0) and CharIsWordChar(vStr[vPos - 1 + 1]) do
        Dec(vPos);
    end else
    begin
      while (vPos < vLen) and not CharIsWordChar(vStr[vPos + 1]) do
        Inc(vPos);
    end;

    if vPos < vLen then begin
      vBeg := vPos;
      while (vPos < vLen) and CharIsWordChar(vStr[vPos + 1]) do
        Inc(vPos);
      FSelBeg   := Point(vBeg, FCurRow);
      FSelEnd   := Point(vPos, FCurRow);
      FSelShow  := True;
    end;
  end;


  procedure TFarEdit.ClearSelection;
  begin
    if FSelShow then begin
      FSelShow  := False;
      Redraw;
    end;
  end;


  procedure TFarEdit.StartSelection(AMethod :TSelMethod);
  begin
    FSelMethod  := AMethod;
    FSelStart   := Point(FEdtPos, FCurRow);
    FSelBeg     := FSelStart;
    FSelEnd     := FSelStart;
    FSelShow    := False;
  end;


  function TFarEdit.LockSelection(Method :TSelMethod) :Boolean;
  begin
    Result := False;
  end;


  procedure TFarEdit.ContinueSelection;
  begin
    if (FCurRow > FSelStart.Y) or ((FCurRow = FSelStart.Y) and (FEdtPos > FSelStart.X)) then begin
      FSelBeg := FSelStart;
      FSelEnd := Point(FEdtPos, FCurRow);
    end else
    begin
      FSelBeg := Point(FEdtPos, FCurRow);
      FSelEnd := FSelStart;
    end;
    FSelShow := (FSelEnd.Y > FSelBeg.Y) or (FSelEnd.X > FSelBeg.X);
    Redraw;
  end;


  procedure TFarEdit.CopySelection;
  begin
    if not FSelShow then
      Exit;
      
    Beep;
  end;


  procedure TFarEdit.EdtCommand(ACmd :TEdtCommands; AShift :Boolean);

    procedure LocDeltaY(ADelta :Integer);
    begin
      ScrollTo(FDeltaX, FDeltaY + ADelta);
      GotoLocation(FCurCol, FCurRow + ADelta, lmSimple);
    end;

    procedure LocGotoEnd;
    var
      vStr :TString;
    begin
      vStr := GetString(FCurRow);
      GotoEdtPos(length(vStr), lmScroll);
    end;

    procedure LocWordLeft;
    var
      vStr :TString;
      vLen, vPos :Integer;
    begin
      if FEdtPos > 0 then begin
        vStr := GetString(FCurRow);
        vLen := length(vStr);
        vPos := FEdtPos;
        Dec(vPos);
        while (vPos >= 0) and ((vPos >= vLen) or not CharIsWordChar(vStr[vPos + 1])) do
          Dec(vPos);
        while (vPos >= 0) and CharIsWordChar(vStr[vPos + 1]) do
          Dec(vPos);
        Inc(vPos);
        GotoEdtPos(vPos, lmScroll);
      end else
      if FCurRow > 1 then begin
        GotoLocation(FCurCol, FCurRow - 1, lmScroll);
        LocGotoEnd;
      end;
    end;

    procedure LocWordRight;
    var
      vStr :TString;
      vLen, vPos :Integer;
    begin
      vStr := GetString(FCurRow);
      vLen := length(vStr);
      if FEdtPos < vLen then begin
        vPos := FEdtPos;
        while (vPos < vLen) and CharIsWordChar(vStr[vPos + 1]) do
          Inc(vPos);
        while (vPos < vLen) and not CharIsWordChar(vStr[vPos + 1]) do
          Inc(vPos);
        GotoEdtPos(vPos, lmScroll);
      end else
      if FCurRow < FRowCount then begin
        GotoLocation(FCurCol, FCurRow + 1, lmScroll);
        GotoEdtPos(0, lmScroll);
      end;
    end;

    procedure LocStartSelection;
    begin
      if FSelMethod = smNone then
        if not LockSelection(smKey) then
          StartSelection(smKey);
    end;

  begin
    if (ACmd >= cmGoFirst) and (ACmd <= cmGoLast) then begin
      if AShift then
        LocStartSelection
      else begin
        ClearSelection;
        FSelMethod := smNone;
      end;
    end else
      FSelMethod := smNone;

    case ACmd of
      cmUp          : GotoLocation(FCurCol, FCurRow - 1, lmScroll);
      cmDown        : GotoLocation(FCurCol, FCurRow + 1, lmScroll);
      cmLeft        : GotoEdtPos(FEdtPos - 1, lmScroll);
      cmRight       : GotoEdtPos(FEdtPos + 1, lmScroll);
      cmPageUp      : LocDeltaY(-FHeight);
      cmPageDown    : LocDeltaY(+FHeight);
      cmPageBeg     : GotoLocation(FCurCol, FDeltaY, lmScroll);
      cmPageEnd     : GotoLocation(FCurCol, FDeltaY + FHeight - 1, lmScroll);
      cmTextBeg     : GotoLocation(FCurCol, 0, lmScroll);
      cmTextEnd     : GotoLocation(FCurCol, FRowCount - 1, lmScroll);
      cmHome        : GotoEdtPos(0, lmScroll);
      cmEnd         : LocGotoEnd;
      cmWordLeft    : LocWordLeft;
      cmWordRight   : LocWordRight;
      cmScrollUp    : LocDeltaY(-1);
      cmScrollDown  : LocDeltaY(+1);
      cmScrollLeft  : {};
      cmScrollRight : {};
      cmSelectAll   : SelectAll;
      cmCopy        : CopySelection;
    end;

    if FSelMethod <> smNone then
      ContinueSelection;
  end;


  function TFarEdit.EdtKeyTranslate(AKey :Integer) :TEdtCommands;
  begin
    Result := cmNone;
    if KEY_SHIFT and AKey <> 0 then
      AKey := AKey and not KEY_SHIFT;
    case AKey of
      KEY_UP, KEY_NUMPAD8            : Result := cmUp;
      KEY_DOWN, KEY_NUMPAD2          : Result := cmDown;
      KEY_LEFT, KEY_NUMPAD4          : Result := cmLeft;
      KEY_RIGHT, KEY_NUMPAD6         : Result := cmRight;
      KEY_PGUP, KEY_NUMPAD9          : Result := cmPageUp;
      KEY_PGDN, KEY_NUMPAD3          : Result := cmPageDown;
      KEY_CTRLPGUP, KEY_CTRLNUMPAD9,
      KEY_CTRLHOME, KEY_CTRLNUMPAD7  : Result := cmTextBeg;
      KEY_CTRLPGDN, KEY_CTRLNUMPAD3,
      KEY_CTRLEND, KEY_CTRLNUMPAD1   : Result := cmTextEnd;
      KEY_HOME, KEY_NUMPAD7          : Result := cmHome;
      KEY_END, KEY_NUMPAD1           : Result := cmEnd;
      KEY_CTRLLEFT, KEY_CTRLNUMPAD4  : Result := cmWordLeft;
      KEY_CTRLRIGHT, KEY_CTRLNUMPAD6 : Result := cmWordRight;
      KEY_CTRLUP, KEY_CTRLNUMPAD8    : Result := cmScrollUp;
      KEY_CTRLDOWN, KEY_CTRLNUMPAD2  : Result := cmScrollDown;
      KEY_CTRLN                      : Result := cmPageBeg;
      KEY_CTRLE                      : Result := cmPageEnd;
      KEY_CTRLA                      : Result := cmSelectAll;
      KEY_CTRLINS, KEY_CTRLC         : Result := cmCopy;
    end;
  end;


  function TFarEdit.KeyDown(AKey :Integer) :Boolean; {override;}
  var
    vCmd :TEdtCommands;
  begin
    vCmd := EdtKeyTranslate(AKey);
    if vCmd <> cmNone then begin
      EdtCommand(vCmd, KEY_SHIFT and AKey <> 0);
      Result := True;
    end else
      Result := inherited KeyDown(AKey);
  end;


  procedure TFarEdit.MouseDown(const APos :TCoord; AButton :Integer; ADouble :Boolean); {override;}
  var
    vCol, vRow, vPos :Integer;
  begin
    if HitTest( APos.X, APos.Y, vCol, vRow) = ghsCell then begin
      if APos.X < FMargin then begin
        GotoLocation(FCurCol, vRow, lmSimple);
        GotoEdtPos(0, lmSimple);
        if ADouble then
          SelectAll
        else begin
          StartSelection(smMouse);
          FDragButton := AButton;
          FDragWhat := dwUser1;
        end;
      end else
      begin
        vPos := APos.X + FEdtDelta - FMargin;
        GotoLocation(vCol, vRow, lmSimple);
        GotoEdtPos(vPos, lmSimple);
        if ADouble then begin
          SelectWord;
          if FSelShow then
            GotoEdtPos(FSelEnd.X, lmScroll);
//        if Assigned(FOnCellClick) then
//          FOnCellClick(Self, vCol, vRow, AButton, True);
        end else
        begin
          if AButton = 1 then
            StartSelection(smMouse)
          else
            ClearSelection;  
          FDragButton := AButton;
          FDragWhat := dwUser1;
        end;
      end;
    end else
      inherited MouseDown(APos, AButton, ADouble);
  end;


  procedure TFarEdit.MouseMove(const APos :TCoord; AButton :Integer); {override;}
  var
    vCol, vRow, vPos :Integer;
  begin
    if AButton = 0 then
      FDragWhat := dwNone;
    if (FDragWhat = dwUser1) {and (FDragButton = 1)} then begin
      CoordFromPoint(APos.X, APos.Y, vCol, vRow);
      vPos := APos.X + FEdtDelta - FMargin;

      GotoLocation(vCol, vRow, lmSimple);
      GotoEdtPos(vPos, lmSimple);

      if FDragButton = 1 then
        ContinueSelection;
    end else
      inherited MouseMove(APos, AButton);
  end;


  procedure TFarEdit.MouseUp(const APos :TCoord; AButton :Integer); {override;}
  begin
    inherited MouseUp(APos, AButton);
  end;


  function TFarEdit.EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; {override;}
  begin
//  TraceF('EventHandler: Msg=%d, Self=%p', [Msg, pointer(Self)]);

    case Msg of
      DN_GOTFOCUS:
        begin
//        TraceF('DN_GOTFOCUS, Self=%p', [pointer(Self)]);
          SetCursor(True);
          Result := 0;
        end;
      DN_KILLFOCUS:
        begin
//        TraceF('DN_KILLFOCUS, Self=%p', [pointer(Self)]);
          SetCursor(False);
//        ClearSelection;  Так не хорошо, KillFocus зачем-то приходит при клике мышкой...
          Result := -1;
        end;
    else
      Result := inherited EventHandler(Msg, Param1, Param2);
    end;
  end;



end.


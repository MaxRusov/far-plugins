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
   {$ifdef bUnicodeFar}
    PluginW,
    FarKeysW,
   {$else}
    Plugin,
    FarKeys,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarGrid,
    FarDlg;


  type
    TFarEdit = class(TFarGrid)
    public
//    constructor Create; override;
//    destructor Destroy; override;

      procedure GotoEdtPos(APos :Integer; AMode :TLocationMode);
      procedure EdtScrollTo(ADelta :Integer);
      procedure SetCursor(AOn :Boolean);
      procedure MoveCursor;

    protected
      procedure PosChange; override;
      procedure DeltaChange; override;

      function KeyDown(AKey :Integer) :Boolean; override;
      function EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; override;

    private
      FEdtPos    :Integer;   { Позиция курсора в редактируемой колонке }
      FEdtDelta  :Integer;   { Смещение в редактируемой колонке }
      FCursorOn  :Boolean;

    public

    public
      property EdtPos :Integer read FEdtPos;
      property EdtDelta :Integer read FEdtDelta write FEdtDelta;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure TFarEdit.SetCursor(AOn :Boolean);
  var
    vCoord :TCoord;
  begin
    if (FCursorOn <> AOn) and False then begin
      if AOn then
        MoveCursor
      else begin
        vCoord.X := -1;
        vCoord.Y := -1;
        FOwner.SendMsg(DM_SETCURSORPOS, FControlID, @vCoord);
      end;
      FCursorOn := AOn;
    end;
  end;


  procedure TFarEdit.MoveCursor;
  var
    vCoord :TCoord;
  begin
    vCoord.X := 1 + FEdtPos;
    vCoord.Y := 1;
    FOwner.SendMsg(DM_SETCURSORPOS, FControlID, @vCoord);
    FOwner.SendMsg(DM_SETCURSORSIZE, FControlID, MAKELONG(1, 25));
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
      FOwner.SendMsg(DM_REDRAW, 0, 0);

      vPosChanged := True;
    end;

//  if (AMode <> lmSimple) and (FHeight > 0) then
//    EnsureOnScreen(ACol, ARow, ARow, AMode);

    if vPosChanged then begin
      if FCursorOn then
        MoveCursor;
//    EdtPosChange;
    end;
  end;


  procedure TFarEdit.EdtScrollTo(ADelta :Integer);
  begin
    ADelta := RangeLimit(ADelta, 0, MaxInt);
    if ADelta = FEdtDelta then
      Exit;

    FEdtDelta  := ADelta;
    DeltaChange;

    FOwner.SendMsg(DM_REDRAW, 0, 0);
  end;


  function TFarEdit.KeyDown(AKey :Integer) :Boolean; {override;}
  begin
    Result := False;
    case AKey of
(*
          KEY_CTRLPGUP:
            {!!!}
            FGrid1.GotoLocation(FGrid1.CurCol, 0, lmScroll);
          KEY_CTRLPGDN:
            {!!!}
            FGrid1.GotoLocation(FGrid1.CurCol, FGrid1.RowCount - 1, lmScroll);
*)


      KEY_LEFT, KEY_NUMPAD4  : GotoEdtPos(FEdtPos - 1, lmScroll);
      KEY_RIGHT, KEY_NUMPAD6 : GotoEdtPos(FEdtPos + 1, lmScroll);
      
      KEY_CTRLLEFT           : EdtScrollTo(FEdtDelta - 1);
      KEY_CTRLRIGHT          : EdtScrollTo(FEdtDelta + 1);


(*
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

      KEY_PGUP, KEY_NUMPAD9  : GotoLocation(FCurCol, FCurRow - FHeight, lmScroll);
      KEY_PGDN, KEY_NUMPAD3  : GotoLocation(FCurCol, FCurRow + FHeight, lmScroll);
      KEY_HOME, KEY_NUMPAD7  : GotoLocation(FCurCol, 0, lmScroll);
      KEY_END, KEY_NUMPAD1   : GotoLocation(FCurCol, FRowCount - 1, lmScroll);

      KEY_MSWHEEL_UP, KEY_MSWHEEL_DOWN:
        if goWheelMovePos in FOptions then
          GotoLocation(FCurCol, FCurRow + IntIf(AKey = KEY_MSWHEEL_UP, -1, +1), lmScroll)
        else
          ScrollTo(FDeltaX, FDeltaY + IntIf(AKey = KEY_MSWHEEL_UP, -FWheelDY, +FWheelDY));
*)
    else
      Result := inherited KeyDown(AKey);
    end;
  end;


  function TFarEdit.EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; {override;}
  begin
    Result := -1;
    case Msg of
      DN_GOTFOCUS:
        SetCursor(True);
      DN_KILLFOCUS:
        SetCursor(False);
    else
      Result := inherited EventHandler(Msg, Param1, Param2);
    end;
  end;



end.


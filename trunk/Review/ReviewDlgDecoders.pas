{$I Defines.inc}

unit ReviewDlgDecoders;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* Review                                                                     *}
{* Image Viewer Plugn for Far 2/3                                             *}
{******************************************************************************}

interface

  uses
    Windows,
    MultiMon,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,

    Far_API,
    FarCtrl,
    FarPlug,
    FarDlg,
    FarGrid,
    FarListDlg,

    ReviewConst,
    ReviewDecoders,
    ReviewClasses,
    ReviewDlgDecoder;


  type
    TDecodersDlg = class(TFilteredListDlg)
    protected
      procedure Prepare; override;
      procedure ReinitGrid; override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;

    private
      FOwner     :TReviewManager;
      FNeedStore :Boolean;

      procedure SetupDecoder;
    end;


  procedure DecodersConfig(aOwner :TReviewManager);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TDecodersDlg                                                                }
 {-----------------------------------------------------------------------------}

  procedure TDecodersDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FGUID := cDecoderListDlgID;
    FHelpTopic := 'Decoders';
  end;


  procedure TDecodersDlg.ReinitGrid; {override;}
  begin
    SetText(IdFrame, GetMsg(strDecodersTitle));

    FGrid.Options := FGrid.Options + [goRowSelect];

//  FGrid.Column[0].Options := [coColMargin];
    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 15, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0,  taLeftJustify, [coColMargin], 2) );

    FGrid.RowCount := FOwner.Decoders.Count;

    FMenuMaxWidth := FarGetWindowSize.cx - 8;
    FGrid.ResetSize;
    ResizeDialog;
  end;


  function TDecodersDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  const
    cStates :array[TDecoderState] of TChar = (' ', ' ', '*', '!');
  begin
    with TReviewDecoder(FOwner.Decoders[ARow]) do begin
      case ACol of
        0: Result := StrIf(Enabled, cStates[GetState], '-') + ' ' + StrIf(Title <> '', Title, Name);
        1: Result := GetInfoStr;
      end;
    end;
  end;


  procedure TDecodersDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {override;}
  begin
(*
    if (AButton = 1) {and ADouble} then
      SelectItem(1)
    else
*)
    if (AButton = 2) then
      SetupDecoder;
  end;


  procedure TDecodersDlg.SetupDecoder;
  begin
    if FGrid.CurRow < FGrid.RowCount then
      if DecoderConfig(FOwner.Decoders[FGrid.CurRow]) then
        FNeedStore := True;
  end;


  function TDecodersDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocEnable(aOn :Boolean);
    begin
      if FGrid.CurRow < FGrid.RowCount then
        with TReviewDecoder(FOwner.Decoders[FGrid.CurRow]) do begin
          Enabled := aOn;
          FNeedStore := True;
          ReInitGrid;
        end;
    end;

    procedure LocMove(ADelta :Integer);
    begin
      if (FGrid.CurRow < FGrid.RowCount) and (FGrid.CurRow + ADelta >= 0) and (FGrid.CurRow + ADelta < FGrid.RowCount) then begin
        FOwner.Decoders.Move(FGrid.CurRow, FGrid.CurRow + ADelta);
        FNeedStore := True;
        ReInitGrid;
        SetCurrent(FGrid.CurRow + ADelta);
      end else
        Beep;
    end;

  begin
    Result := True;
    case AKey of

      KEY_F4:
        SetupDecoder;

      KEY_INS:
        LocEnable(True);
      KEY_DEL:
        LocEnable(False);

      KEY_CTRLUP:
        LocMove(-1);
      KEY_CTRLDOWN:
        LocMove(+1);

    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure DecodersConfig(aOwner :TReviewManager);
  var
    vDlg :TDecodersDlg;
  begin
    vDlg := TDecodersDlg.Create;
    try
      vDlg.FOwner := aOwner;
      vDlg.Run;
      if vDlg.FNeedStore then
        SaveDecodersInfo(aOwner.Decoders);
    finally
      FreeObj(vDlg);
    end;
  end;


end.


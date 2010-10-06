{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}

unit TabActionsList;

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
    FarCtrl,
    FarDlg,
    FarGrid,
    FarListDlg,

    PanelTabsCtrl,
    PanelTabsClasses,
    TabListDlg,
    EditActionDlg;


  type
    TActionsList = class(TFarListDlg)
    public
      constructor Create; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

      procedure ReInitGrid; virtual;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;

    protected
      FActions  :TClickActions;

      procedure AddNew;
      procedure EditCurrent;
      procedure DeleteCurrent;
    end;


  function ActionsList(AActions :TClickActions) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TActionsList                                                                }
 {-----------------------------------------------------------------------------}

  constructor TActionsList.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TActionsList.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := '';

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.Options := [goRowSelect, goWrapMode {, goFollowMouse} ];
    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 2) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 3) );
  end;


  procedure TActionsList.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    SetText(IdFrame, GetMsg(strMouseActions));
    ReInitGrid;
  end;


  procedure TActionsList.ReInitGrid; {virtual;}
  var
    I, vMaxLen1, vMaxLen2, vMaxLen3 :Integer;
    vAction :TClickAction;
  begin
    vMaxLen1 := 0; vMaxLen2 := 0; vMaxLen3 := 0;
    for I := 0 to FActions.Count - 1 do begin
      vAction := FActions[I];
      vMaxLen1 := IntMax(vMaxLen1, Length(HotSpot2Str(vAction.HotSpot)));
      vMaxLen2 := IntMax(vMaxLen2, Length(vAction.ShiftAndClickAsStr));
      vMaxLen3 := IntMax(vMaxLen3, Length(TabAction2Str(vAction.Action)));
    end;

    FGrid.Column[0].Width := vMaxLen1 + 2;
    FGrid.Column[1].Width := vMaxLen2 + 2;
    FGrid.Column[2].Width := vMaxLen3 + 2;

    FMenuMaxWidth := vMaxLen1 + 2 + vMaxLen2 + 2 + vMaxLen3 + 2 + 2;

    FGrid.ResetSize;
    FGrid.RowCount := FActions.Count;
    SetCurrent(FGrid.CurRow);

    ResizeDialog;
  end;


  procedure TActionsList.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
    EditCurrent;
  end;


  function TActionsList.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  var
    vAction :TClickAction;
  begin
    Result := '';
    if ARow < FActions.Count then begin
      vAction := FActions[ARow];
      case ACol of
        0: Result := HotSpot2Str(vAction.HotSpot);
        1: Result := vAction.ShiftAndClickAsStr;
        2: Result := TabAction2Str(vAction.Action);
      end;
    end;
  end;


  procedure TActionsList.AddNew;
  var
    vIndex :Integer;
  begin
    if NewAction(FActions, vIndex) then begin
      ReInitGrid;
      SetCurrent(vIndex);
      FActions.StoreReg;
    end;
  end;


  procedure TActionsList.EditCurrent;
  var
    vAction :TClickAction;
  begin
    if FGrid.CurRow < FGrid.RowCount then begin
      vAction := FActions[FGrid.CurRow];
      if EditAction(FActions, FGrid.CurRow) then begin
        ReInitGrid;
        SetCurrent(FActions.IndexOf(vAction));
        FActions.StoreReg;
      end;
    end else
      Beep;
  end;


  procedure TActionsList.DeleteCurrent;
  begin
    if FGrid.CurRow < FGrid.RowCount then begin
      FActions.Delete( FGrid.CurRow );
      ReInitGrid;
      FActions.StoreReg;
    end else
      Beep;
  end;


  function TActionsList.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_KEY: begin
        case Param2 of
          KEY_ENTER, KEY_F4:
            EditCurrent;
          KEY_INS:
            AddNew;
          KEY_DEL:
            DeleteCurrent;
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function ActionsList(AActions :TClickActions) :Boolean;
  var
    vDlg :TActionsList;
  begin
    Result := False;
    vDlg := TActionsList.Create;
    try
      vDlg.FActions := AActions;

      if vDlg.Run = -1 then
        Exit;

      Result := True;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


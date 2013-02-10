{******************************************************************************}
{* (c) 2009-2013 Max Rusov                                                    *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}

unit EditActionDlg;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,

    Far_API,
    FarCtrl,
    FarDlg,
    PanelTabsCtrl,
    PanelTabsClasses;


  function EditAction(AActions :TClickActions; AIndex :Integer) :Boolean;
  function NewAction(AActions :TClickActions; var AIndex :Integer) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdFrame         = 0;
    IdEdtArea       = 2;
    IdEdtClick      = 4;
    IdChkShift      = 5;
    IdChkCtrl       = 6;
    IdChkAlt        = 7;
    IdEdtAction     = 9;
    IdCancel        = 12;


  type
    TEditActionDlg = class(TFarDialog)
    public
      constructor Create; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FAction  :TClickAction;
      FIsNew   :Boolean;
    end;


  constructor TEditActionDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TEditActionDlg.Prepare; {override;}
  const
    DX = 60;
    DY = 12;
  begin
    FHelpTopic := '';
    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,  3,    1,   DX-6, DY-2,   0,  GetMsg(strEditAction)),

        NewItemApi(DI_Text,       5,    2,   20,     -1,   0,  GetMsg(strArea)),
        NewItemApi(DI_ComboBox,   5,    3,   20,     -1,   DIF_DROPDOWNLIST),

        NewItemApi(DI_Text,       5,    4,   20,     -1,   0, GetMsg(strClickType)),
        NewItemApi(DI_ComboBox,   5,    5,   20,     -1,   DIF_DROPDOWNLIST),

        NewItemApi(DI_Checkbox,  27,    5,   DX-10,  -1,   0, GetMsg(strShift)),
        NewItemApi(DI_Checkbox,  27+11, 5,   DX-10,  -1,   0, GetMsg(strCtrl)),
        NewItemApi(DI_Checkbox,  27+21, 5,   DX-10,  -1,   0, GetMsg(strAlt)),

        NewItemApi(DI_Text,       5,    6,   DX-10,  -1,   0, GetMsg(strAction)),
        NewItemApi(DI_ComboBox,   5,    7,   DX-10,  -1,   DIF_DROPDOWNLIST),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) )
      ],
      @FItemCount
    );
  end;


  procedure TEditActionDlg.InitDialog; {override;}
  var
    I, N :Integer;
    vStrs :array of TFarStr;
  begin
    SetListItems(IdEdtArea, [
      HotSpot2Str(hsTab),
      HotSpot2Str(hsButtom),
      HotSpot2Str(hsPanel)
    ]);

    SetListItems(IdEdtClick, [
      ClickType2Str(mcLeft)
     ,ClickType2Str(mcDblLeft)
     ,ClickType2Str(mcRight)
     ,ClickType2Str(mcDblRight)
     {$ifdef bUseProcessConsoleInput}
     ,ClickType2Str(mcMiddle)
     ,ClickType2Str(mcDblMiddle)
     {$endif bUseProcessConsoleInput}
    ]);

    N := Byte(High(TTabAction)) + 1;
    SetLength(vStrs, N);
    for I := 0 to N - 1 do
      vStrs[I] := TabAction2Str( TTabAction(I) );
    SetListItems(IdEdtAction, vStrs);

    SetListIndex(IdEdtArea, Byte(FAction.HotSpot) - 1);
    SetText(IdEdtArea, HotSpot2Str(FAction.HotSpot));

    if not FIsNew then begin
      SetListIndex(IdEdtClick, Byte(FAction.ClickType) - 1);
      SetText(IdEdtClick, ClickType2Str(FAction.ClickType));

      SetListIndex(IdEdtAction, Byte(FAction.Action));
      SetText(IdEdtAction, TabAction2Str(FAction.Action));
    end;

    SetChecked(IdChkShift, ksShift in FAction.Shifts );
    SetChecked(IdChkCtrl, ksControl in FAction.Shifts );
    SetChecked(IdChkAlt, ksAlt in FAction.Shifts );

    if FIsNew then
      SetText(IdFrame, GetMsg(strAddAction));
  end;


  function TEditActionDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  var
    vHotSpot :THotSpot;
    vClickType :TClickType;
    vAction :TTabAction;
    vShifts :TKeyShifts;
    vClickAction :TClickAction;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin

      if GetText(IdEdtClick) = '' then
        AppErrorID(strClickTypeNotDefined);
      if GetText(IdEdtAction) = '' then
        AppErrorID(strActionNotDefined);

      vHotSpot := THotSpot( SendMsg(DM_LISTGETCURPOS, IdEdtArea, 0) + 1 );
      vClickType := TClickType( SendMsg(DM_LISTGETCURPOS, IdEdtClick, 0) + 1 );
      vAction := TTabAction( SendMsg(DM_LISTGETCURPOS, IdEdtAction, 0) );

      vShifts := [];
      if GetChecked(IdChkShift) then
        Include(vShifts, ksShift);
      if GetChecked(IdChkCtrl) then
        Include(vShifts, ksControl);
      if GetChecked(IdChkAlt) then
        Include(vShifts, ksAlt);

      vClickAction := TabsManager.FindActions(vHotSpot, vClickType, vShifts);
      if (vClickAction <> nil) and (vClickAction <> FAction) then
        AppErrorID(strActionAlreadyDefined);

      FAction.HotSpot := vHotSpot;
      FAction.ClickType := vClickType;
      FAction.Action := vAction;
      FAction.Shifts := vShifts;

    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function EditAction(AActions :TClickActions; AIndex :Integer) :Boolean;
  var
    vDlg :TEditActionDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TEditActionDlg.Create;
    try
      vDlg.FAction := AActions[AIndex];

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      AActions.SortList(True, 0);
      Result := True;

    finally
      FreeObj(vDlg);
    end;
  end;


  function NewAction(AActions :TClickActions; var AIndex :Integer) :Boolean;
  var
    vDlg :TEditActionDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TEditActionDlg.Create;
    try
      vDlg.FAction := TClickAction.Create;
      vDlg.FAction.HotSpot := hsTab;
      vDlg.FIsNew  := True;

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      AIndex := AActions.AddSorted(vDlg.FAction, 0, dupAccept);
      vDlg.FAction := nil;

      Result := True;

    finally
      FreeObj(vDlg.FAction);
      FreeObj(vDlg);
    end;
  end;


end.


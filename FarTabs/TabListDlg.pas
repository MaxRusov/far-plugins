{$I Defines.inc}

unit TabListDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
   {$ifdef bUnicodeFar}
    PluginW,
    FarKeysW,
   {$else}
    Plugin,
    FarKeys,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,
    PanelTabsCtrl,
    PanelTabsClasses,
    EditTabDlg;


  const
    cDlgMinWidth  = 20;
    cDlgMinHeight = 5;

    IdFrame = 0;
    IdList = 1;

  type
    TTabsList = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

      procedure SelectItem(ACode :Integer); virtual;
      procedure ReinitListControl; virtual;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); virtual;

    protected
      FGrid           :TFarGrid;
      FTabs           :TPanelTabs;
      FHotkeyColor1   :Integer;
      FHotkeyColor2   :Integer;
      FMenuMaxWidth   :Integer;
      FResInd         :Integer;
      FResCmd         :Integer;

      procedure ResizeDialog;
      procedure EditCurrent;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode = lmScroll);
    end;


  function ListTabDlg(ATabs :TPanelTabs; var AIndex :Integer) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TTabsList                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TTabsList.Create; {override;}
  begin
    inherited Create;
    FHotkeyColor1 := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUHIGHLIGHT));
    FHotkeyColor2 := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUSELECTEDHIGHLIGHT));
  end;


  destructor TTabsList.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  procedure TTabsList.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FHelpTopic := 'List';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 2, 1, DX - 4, DY - 2, 0, GetMsg(strTabs)),
        NewItemApi(DI_USERCONTROL, 3, 2, DX - 6, DY - 4, 0, '' )
      ]
    );
    FGrid := TFarGrid.CreateEx(Self, IdList);
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect, goWrapMode, goFollowMouse];
    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coOwnerDraw, coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 2) );
  end;


  procedure TTabsList.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitListControl;
  end;


  procedure TTabsList.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vScreenInfo.dwSize.X - 4 then
      vWidth := vScreenInfo.dwSize.X - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 4;
    if vHeight > vScreenInfo.dwSize.Y - 2 then
      vHeight := vScreenInfo.dwSize.Y - 2;
    vHeight := IntMax(vHeight, cDlgMinHeight);

    SetDlgPos(-1, -1, vWidth, vHeight);

    vRect.Left := 2;
    vRect.Top := 1;
    vRect.Right := vWidth - 3;
    vRect.Bottom := vHeight - 2;
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    SRectGrow(vRect, -1, -1);
    if vRect.Bottom - vRect.Top + 2 <= FGrid.RowCount then
      Inc(vRect.Right);
    SendMsg(DM_SETITEMPOSITION, IdList, @vRect);
    FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);
  end;


  procedure TTabsList.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  procedure TTabsList.ReinitListControl; {virtual;}
  var
    I, vMaxLen1, vMaxLen2 :Integer;
    vTab :TPanelTab;
  begin
    vMaxLen1 := 0; vMaxLen2 := 0;
    for I := 0 to FTabs.Count - 1 do begin
      vTab := FTabs[I];
      vMaxLen1 := IntMax(vMaxLen1, Length(vTab.Caption));
      vMaxLen2 := IntMax(vMaxLen2, Length(vTab.Folder));
    end;

    Inc(vMaxLen1, Length(Int2Str(FTabs.Count)) + 1);

    FGrid.Column[0].Width := vMaxLen1 + 2;
    FGrid.Column[1].Width := vMaxLen2 + 2;

    FMenuMaxWidth := vMaxLen1 + 2 + vMaxLen2 + 2 + 1;

    FGrid.ResetSize;
    FGrid.RowCount := FTabs.Count;
    SetCurrent(FGrid.CurRow);

    ResizeDialog;
  end;


  procedure TTabsList.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
    if (AButton = 1) {and ADouble} then
      SelectItem(1)
    else
    if (AButton = 2) then
      EditCurrent;
  end;


  function TTabsList.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  var
    vTab :TPanelTab;
  begin
    Result := '';
    if ARow < FTabs.Count then begin
      vTab := FTabs[ARow];
      case ACol of
        0: {Result := Format('%d %s', [ARow + 1, vTab.Caption])};
        1: Result := vTab.Folder;
      end;
    end;
  end;


  procedure TTabsList.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {virtual;}
  var
    vTab :TPanelTab;
    vStr :TString;
  begin
    if ARow < FTabs.Count then begin
      vTab := FTabs[ARow];
      vStr := Format('%s %s', [IndexToChar(ARow), vTab.Caption]);
      FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, 0, 1, AColor, IntIf(FGrid.CurRow = ARow, FHotkeyColor2, FHotkeyColor1));
    end;
  end;


  procedure TTabsList.SelectItem(ACode :Integer);  {virtual;}
  begin
    if FGrid.CurRow < FGrid.RowCount then begin
      FResInd := FGrid.CurRow;
      FResCmd := ACode;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TTabsList.EditCurrent;
  begin
    if FGrid.CurRow < FGrid.RowCount then begin
      if EditTab(FTabs, FGrid.CurRow) then begin
        FTabs.StoreReg('');
        ReinitListControl;
      end;
    end else
      Beep;
  end;


  function TTabsList.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocInsert;
    var
      vIndex :Integer;
    begin
      vIndex := FGrid.CurRow;
      if vIndex < FGrid.RowCount then
        Inc(vIndex);
      if NewTab(FTabs, vIndex) then begin
        FTabs.StoreReg('');
        ReinitListControl;
        SetCurrent(vIndex);
      end;
    end;


    procedure LocDelete;
    begin
      if FGrid.CurRow < FGrid.RowCount then begin
        FTabs.FreeAt( FGrid.CurRow );
        FTabs.StoreReg('');
        ReinitListControl;
      end else
        Beep;
    end;

    procedure LocMove(ADelta :Integer);
    begin
      if (FGrid.CurRow < FGrid.RowCount) and (FGrid.CurRow + ADelta >= 0) and (FGrid.CurRow + ADelta < FGrid.RowCount) then begin
        FTabs.Move(FGrid.CurRow, FGrid.CurRow + ADelta);
        FTabs.StoreReg('');
        ReinitListControl;
        SetCurrent(FGrid.CurRow + ADelta);
      end else
        Beep;
    end;

    procedure LocHotkey(AIndex :Integer);
    begin
      if AIndex < FGrid.RowCount then begin
        SetCurrent(AIndex);
        SelectItem(1);
      end else
        Beep;
    end;

  var
    vIndex :Integer;
  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_CTLCOLORDIALOG:
        Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

      DN_CTLCOLORDLGITEM:
        if Param1 = IdFrame then
          Result := CtrlPalette([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX])
        else
          Result := Param2;

      DN_RESIZECONSOLE:
        begin
          ResizeDialog;
          SetCurrent(FGrid.CurRow);
        end;

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectItem(1);

          KEY_F4:
            EditCurrent;
          KEY_INS:
            LocInsert;
          KEY_DEL:
            LocDelete;

          KEY_CTRLUP:
            LocMove(-1);
          KEY_CTRLDOWN:
            LocMove(+1);

        else
          vIndex := VKeyToIndex(Param2);
          if vIndex <> -1 then
            LocHotkey(vIndex)
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

  function ListTabDlg(ATabs :TPanelTabs; var AIndex :Integer) :Boolean;
  var
    vDlg :TTabsList;
  begin
    Result := False;
    vDlg := TTabsList.Create;
    try
      vDlg.FTabs := ATabs;

      if vDlg.Run = -1 then
        Exit;

      case vDlg.FResCmd of
        1: AIndex := vDlg.FResInd;
      end;
      Result := True;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


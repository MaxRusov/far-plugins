{$I Defines.inc}

unit FarDebugBreakpoints;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Breakpoints window                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarMatch,

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB,
    FarDebugDlgBase;


  var
    optBreakShowIndex :Boolean = True;
    optBreakShowAddr  :Boolean = True;
    optBreakShowLoc   :Boolean = True;


  type
    TBreakpointDlg = class(TFarDebugListBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FResCmd     :Integer;
      FResIndex   :Integer;
      FTopLine    :Integer;

//    procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
//    procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
//    procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure ReinitGrid;
      procedure ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
      procedure SelectItem(ACode :Integer);
      function CurrentBreakpoint :TBreakpoint;
    end;


  procedure BreakpointesDlg;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TBreakpointDlg                                                              }
 {-----------------------------------------------------------------------------}

  constructor TBreakpointDlg.Create; {override;}
  begin
    inherited Create;
//  RegisterHints(Self);
  end;


  destructor TBreakpointDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TBreakpointDlg.Prepare; {override;}
  begin
    FGUID := cBreakpointsDlgID;
    FHelpTopic := 'Breakpoints';
    FWidth := cListDlgDefWidth;
    FHeight := cListDlgDefHeight;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, GetMsg(strBreakpoints)),
        NewItemApi(DI_USERCONTROL, 3, 2, FWidth - 6, FHeight - 6, 0)
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];

    FGrid.OnGetCellText := GridGetDlgText;
//  FGrid.OnGetCellColor := GridGetCellColor;
  end;


  procedure TBreakpointDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
    FGrid.GotoLocation(0, FResIndex, lmScroll);
  end;


  function TBreakpointDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vBreak :TBreakpoint;
  begin
    if ARow < Breakpoints.Count then begin
      vBreak := Breakpoints[ARow];
      case FGrid.Column[ACol].Tag of
        1: Result := Int2Str(ARow + 1);
        2: Result := StrIf(vBreak.Enabled, ' ', ' x');
        3: Result := vBreak.Proc;
        4: Result := vBreak.Addr;
        5: Result := Format('%s:%d', [vBreak.Source, vBreak.Line]);
      end;
    end;
  end;


  procedure TBreakpointDlg.ReinitGrid;
  var
    I, vWidth1, vWidth2, vWidth3  :Integer;
  begin
//  Trace('ReinitGrid...');
    vWidth1 := 0; vWidth2 := 0; vWidth3 := 0;
    for I := 0 to Breakpoints.Count - 1 do
      with TBreakpoint(Breakpoints[i]) do begin
        vWidth1 := IntMax(vWidth1, Length(Proc));
        vWidth2 := IntMax(vWidth2, Length(Addr));
        vWidth3 := IntMax(vWidth3, Length(Source + ':' + Int2Str(Line)));
      end;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    if optBreakShowIndex then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Int2Str(Breakpoints.Count)) + 1, taRightJustify, [{coColMargin,} coNoVertLine], 1) );

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 2, taRightJustify, [{coColMargin}], 2) );

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 3) );
    if optBreakShowAddr then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth2+2, taLeftJustify, [coColMargin], 4) );
    if optBreakShowLoc then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth3+2, taLeftJustify, [coColMargin], 5) );

    FMaxWidth := vWidth1 + 2;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then
          Inc(FMaxWidth, Width + 1);

    FGrid.RowCount := Breakpoints.Count;
    SendMsg(DM_REDRAW, 0, 0);

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
      FGrid.GotoLocation(0, 0, lmScroll);
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  function TBreakpointDlg.CurrentBreakpoint :TBreakpoint;
  var
    vIndex :Integer;
  begin
    Result := nil;
    vIndex := FGrid.CurRow;
    if (vIndex >= 0) and (vIndex < Breakpoints.Count) then
      Result := Breakpoints[vIndex];
  end;

 {-----------------------------------------------------------------------------}

  procedure TBreakpointDlg.ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
  begin
    AOption := not AOption;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TBreakpointDlg.SelectItem(ACode :Integer);
  begin
    FResIndex := FGrid.CurRow;
    if (FResIndex >= 0) and (FResIndex < Breakpoints.Count) then begin
      FResCmd := 1;
      FTopLine := GetDlgRect.Top;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  function TBreakpointDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocInsertBreakpoint;
    var
      vStr :TString;
    begin
      vStr := '';

      if not FarInputBox(GetMsg(strAddBreakTitle), GetMsg(strAddBreakPrompt), vStr, FIB_BUTTONS or FIB_NOUSELASTHISTORY, cHistBreakpoint) then
        Exit;

      RedirCall('break ' + vStr);
      UpdateBreakpoints;

      FResCmd := 9;
      SendMsg(DM_CLOSE, -1, 0);
    end;

    procedure LocDeleteCurrent;
    var
      vBreakpoint :TBreakpoint;
    begin
      FResIndex := FGrid.CurRow;
      vBreakpoint := CurrentBreakpoint;
      if vBreakpoint <> nil then begin
        DeleteBreakpoint(vBreakpoint.ID);
        FResCmd := 9;
        SendMsg(DM_CLOSE, -1, 0);
      end;
    end;

    procedure LocDisableCurrent;
    var
      vBreakpoint :TBreakpoint;
    begin
      FResIndex := FGrid.CurRow;
      vBreakpoint := CurrentBreakpoint;
      if vBreakpoint <> nil then begin
        EnableBreakpoint(vBreakpoint.ID, not vBreakpoint.Enabled);
        FResCmd := 9;
        SendMsg(DM_CLOSE, -1, 0);
      end;
    end;

  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        ResizeDialog;

      DN_MOUSECLICK:
        Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectItem(1);

          KEY_INS:
            LocInsertBreakpoint;
          KEY_DEL:
            LocDeleteCurrent;
          KEY_F6:
            LocDisableCurrent;

          KEY_CTRL1:
            ToggleOption(optBreakShowIndex);
          KEY_CTRL2:
            ToggleOption(optBreakShowAddr);
          KEY_CTRL3:
            ToggleOption(optBreakShowLoc);

        else
//        TraceF('Key: %d', [Param2]);
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

  procedure BreakpointesDlg;
  var
    vDlg :TBreakpointDlg;
    vFinish :Boolean;
  begin
    InitGDBDebugger;
    UpdateBreakpoints;

    vDlg := TBreakpointDlg.Create;
    try

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Break;

        case vDlg.FResCmd of
          1: LocateByAddr( TBreakpoint(Breakpoints[vDlg.FResIndex]).Addr, vDlg.FTopLine );
          9: FARAPI.EditorControl(ECTL_REDRAW, nil);
        else
          vFinish := True;
        end
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


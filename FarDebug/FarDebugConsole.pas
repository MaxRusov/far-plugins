{$I Defines.inc}

unit FarDebugConsole;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

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
    FarGrid,

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB;


  type
    THistoryStrs = class(TStringList)
    public
      procedure Add(const AStr :TString; AFlags :DWORD);
      procedure AddText(const AText :TString; AFlags :DWORD);
    end;


    TConsoleDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure RunCommand(const ACmd :TString);

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FGrid           :TFarGrid;
      FMaximized      :Boolean;
      FMenuMaxWidth   :Integer;

      FProcess        :TString;
      FAddr           :TString;
      FRunStart       :DWORD;

      FInitCmd        :TString;
      FResCmd         :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure ResizeDialog;
      procedure UpdateProcessInfo;
      procedure UpdateHeader;
      procedure ReinitGrid;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode);
      procedure ToggleOption(var AOption :Boolean);

    public
      property Grid :TFarGrid read FGrid;
    end;

  procedure AddConsole(const AStr :TString);

  procedure ShowConsoleDlg(const ACmd :TString);

  
{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { THistoryStrs                                                                }
 {-----------------------------------------------------------------------------}

  procedure THistoryStrs.Add(const AStr :TString; AFlags :DWORD);
  begin
    AddObject(AStr, Pointer(TUnsPtr(AFlags)));
  end;


  procedure THistoryStrs.AddText(const AText :TString; AFlags :DWORD);
  var
    vPtr :PTChar;
  begin
    vPtr := PTChar(AText);
    while vPtr^ <> #0 do
      Add( StrExpandTabs(ExtractNextLine(vPtr)), AFlags );
  end;


  var
    GDBStr :THistoryStrs;


  procedure AddConsole(const AStr :TString);
  begin
    if GDBStr = nil then
      GDBStr := THistoryStrs.Create;
    GDBStr.AddText(AStr, 0);
  end;


 {-----------------------------------------------------------------------------}
 { TConsoleDlg                                                                 }
 {-----------------------------------------------------------------------------}

  const
    cDlgMinWidth  = 80;
    cDlgMinHeight = 8;

    IdFrame  = 0;
    IdIcon   = 1;
    IdGrid   = 2;
    IdInput  = 3;


  constructor TConsoleDlg.Create; {override;}
  begin
    inherited Create;
//  RegisterHints(Self);
//  FMaximized := True;
  end;


  destructor TConsoleDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TConsoleDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FGUID := cConsoleDlgID;
    FHelpTopic := 'Console';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 4;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, 'GDB'),
        NewItemApi(DI_Text,        DX-7, 1, 3, 1, 0, cNormalIcon),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0, '' ),
        NewItemApi(DI_Edit,        3, 3, DX - 6, -1, DIF_HISTORY, '', 'FarDebug.Console' )
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid.NormColor := GetOptColor(0, COL_DIALOGTEXT);
//  FGrid.SelColor := GetOptColor(optCurColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
  end;


  procedure TConsoleDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    SendMsg(DM_SETFOCUS, IdInput, 0);
    ReinitGrid;
    UpdateProcessInfo;
    UpdateHeader;
(*
    if FInitCmd <> '' then
      RunCommand(FInitCmd);
*)
  end;


  procedure TConsoleDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect, vRect1 :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    if FMaximized then begin
      vWidth := vSize.CX;
      vHeight := vSize.CY;

      vRect := SBounds(0, 0, vWidth-1, vHeight-1);
      SendMsg(DM_SHOWITEM, IdFrame, 0);

      vRect1 := SBounds(vRect.Right - 2, vRect.Top, 2, 0);
      SendMsg(DM_SETITEMPOSITION, IdIcon, @vRect1);
      SetText(IdIcon, cMaximizedIcon)
    end else
    begin
      vWidth := IntMax(FMenuMaxWidth + 6, cDlgMinWidth);
      if vWidth > vSize.CX - 4 then
        vWidth := vSize.CX - 4;
//    vWidth := IntMax(vWidth, cDlgMinWidth);

      vHeight := IntMax(FGrid.RowCount + 5, cDlgMinHeight);
      if vHeight > vSize.CY - 2 then
        vHeight := vSize.CY - 2;
//    vHeight := IntMax(vHeight, cDlgMinHeight);

      vRect := SBounds(2, 1, vWidth - 5, vHeight - 3);
      SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
      SendMsg(DM_SHOWITEM, IdFrame, 1);

      vRect1 := SBounds(vRect.Right - 4, vRect.Top, 2, 0);
      SendMsg(DM_SETITEMPOSITION, IdIcon, @vRect1);
      SetText(IdIcon, cNormalIcon);

      SRectGrow(vRect, -1, -1);
    end;

    vRect1 := vRect;
    vRect1.Top := vRect1.Bottom;
    Dec(vRect1.Right);
    SendMsg(DM_SETITEMPOSITION, IdInput, @vRect1);

    vRect1 := vRect;
    Dec(vRect1.Bottom);
    vRect1.Top := IntMax(vRect1.Top, vRect1.Bottom - FGrid.RowCount + 1);
    if not FMaximized and (vRect1.Bottom - vRect1.Top + 2 <= FGrid.RowCount) then
      Inc(vRect1.Right);
    SendMsg(DM_SETITEMPOSITION, IdGrid, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


  procedure TConsoleDlg.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  procedure TConsoleDlg.UpdateProcessInfo;
  begin
    FProcess := GetCurrentProcess;
    if FProcess <> '' then
      FAddr := GetCurrentAddr;
  end;


  procedure TConsoleDlg.UpdateHeader;
  var
    vStr :TString;
  begin
    vStr := 'GDB';
    if FProcess <> '' then begin
      vStr := vStr + ':' + ExtractFileName(FProcess);
      if FRunStart <> 0 then
        vStr := vStr + ',' + 'running'
      else
      if FAddr <> '' then
        vStr := vStr + ',' + 'stopped';
    end;

    if FRunStart <> 0 then
      vStr := vStr + ' (' + Int2Str(TickCountDiff(GetTickCount, FRunStart) div 1000) + ')';

    SetText(IdFrame, vStr);
  end;



  procedure TConsoleDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if ADouble then
      NOP;
  end;


  procedure TConsoleDlg.GridPosChange(ASender :TFarGrid);
  begin
    { Обновляем status-line }
  end;


  function TConsoleDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < GDBStr.Count then
      Result := GDBStr[ARow];
  end;


  procedure TConsoleDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  var
    vFlags :DWORD;
  begin
    if SendMsg(DM_GETFOCUS, 0, 0) <> IdGrid then
      AColor := FGrid.NormColor;

    if ARow < GDBStr.Count then begin
      vFlags := DWORD(GDBStr.Objects[ARow]);
      if vFlags <> 0 then
        AColor  := (AColor and not $0F) or (IntIf(vFlags = 1, optTermUserColor, optTermErrorColor) and $0F);
    end;
  end;


  procedure TConsoleDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  begin
    {}
  end;


 {-----------------------------------------------------------------------------}

  procedure TConsoleDlg.ReinitGrid;
  var
    I :Integer;
  begin
//  Trace('ReinitGrid...');
    FMenuMaxWidth := 0;
    if not FMaximized then
      for I := 0 to GDBStr.Count - 1 do
        FMenuMaxWidth := IntMax(FMenuMaxWidth, Length(GDBStr.PStrings[I]^));

    FGrid.RowCount := GDBStr.Count;

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
      SetCurrent(FGrid.RowCount - 1, lmScroll);
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TConsoleDlg.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    ReinitGrid;
//  WriteSetup;
  end;


(*
  procedure TConsoleDlg.RunCommand(const ACmd :TString);
  var
    vRes :TString;
  begin
    try
      RedirCall(ACmd, @vRes);

      GDBStr.Add(cCustomPrompt + ACmd, 1);
      GDBStr.AddText(vRes, 0);

      if RedirInited then begin
        UpdateHeader;
        ReinitGrid;
      end else
        SendMsg(DM_CLOSE, -1, 0);
    except
      on E :Exception do
        HandleError(E);
    end;
  end;
*)


(*
  procedure TConsoleDlg.RunCommand(const ACmd :TString);
  var
    vRes :TString;
  begin
    try
//    GDBStr.Add(cCustomPrompt + ACmd, 1);
//    GDBStr.AddText(vRes, 0);

//    RedirCall(ACmd, @vRes);

      RedirSendCommand(ACmd);
      RedirReadAnswer(@vRes, #0, 0{NoTimeout}{, AEvent, AContext});

      GDBStr.AddText(vRes, 0);

      if RedirInited then begin
        UpdateHeader;
        ReinitGrid;
      end else
        SendMsg(DM_CLOSE, -1, 0);

    except
      on E :Exception do begin
        GDBStr.AddText(E.Message, 2);
        ReinitGrid;
      end;
    end;
  end;
*)


  function ConsoleWaitAnswer(AEvent :TRedirEvent; const AStr :TAnsiStr; AContext :Pointer) :Boolean;
  begin
    with TConsoleDlg(AContext) do begin
      if AEvent = reIdle then begin
        Result := GDBCheckInterrupt;
        if not Result then
          Exit;
        UpdateHeader;
      end else
      begin
        if AEvent = reReadOut then
          GDBStr.AddText(AStr, 0)
        else
          GDBStr.AddText(AStr, 2);
        ReinitGrid;
      end;
    end;
    Result := True;
  end;


  procedure TConsoleDlg.RunCommand(const ACmd :TString);
  begin
    try
//    GDBStr.Add(cCustomPrompt + ACmd, 1);
//    GDBStr.AddText(vRes, 0);

      FRunStart := GetTickCount;
      SendMsg(DM_ENABLE, IdInput, 0);
      try
        RedirSendCommand(ACmd);
        RedirReadAnswer(nil, #0, 0{NoTimeout}, ConsoleWaitAnswer, Self);
      finally
        SendMsg(DM_ENABLE, IdInput, 1);
        FRunStart := 0;
      end;

      if RedirInited then begin
        UpdateProcessInfo;
        UpdateHeader;
        ReinitGrid;
      end else
        SendMsg(DM_CLOSE, -1, 0);

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function TConsoleDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}


    procedure LocInput;
    var
      vCmd :TString;
    begin
      vCmd := GetText(IdInput);
      if vCmd <> '' then begin

        GDBStr.Add(cCustomPrompt + vCmd, 1);

        AddHistory(IdInput, vCmd);
        SetText(IdInput, '');
        ReinitGrid;

        RunCommand(vCmd);

      end else
      if GDBStr.Count <> 0 then begin
        GDBStr.Add(vCmd, 1);
        ReinitGrid;
      end;
    end;


    procedure LocClear;
    begin
      GDBStr.Clear;
      ReinitGrid;
    end;

  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE: begin
        ResizeDialog;
        SetCurrent(FGrid.CurRow, lmScroll);
      end;

      DN_MOUSECLICK:
        if Param1 = IdIcon then
          ToggleOption(FMaximized)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            LocInput;

          KEY_CTRLDEL:
            LocClear;

          KEY_CTRLM:
            ToggleOption(FMaximized);

        else
//        TraceF('Key: %d', [Param2]);
          if SendMsg(DM_GETFOCUS, 0, 0) = IdInput then begin

            case Param2 of
              KEY_UP:
                FGrid.ScrollTo(0, FGrid.DeltaY - 1);
              KEY_DOWN:
                FGrid.ScrollTo(0, FGrid.DeltaY + 1);
              KEY_PgUP:
                FGrid.ScrollTo(0, FGrid.DeltaY - FGrid.Height);
              KEY_PgDn:
                FGrid.ScrollTo(0, FGrid.DeltaY + FGrid.Height);
              KEY_CTRLPGUP:
                FGrid.ScrollTo(0, 0);
              KEY_CTRLPGDN:
                FGrid.ScrollTo(0, MaxInt);
             else
               Result := inherited DialogHandler(Msg, Param1, Param2);
            end;

          end else
            Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  procedure TConsoleDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    vLock :Integer;


  procedure ShowConsoleDlg(const ACmd :TString);
  var
    vDlg :TConsoleDlg;
    vFinish :Boolean;
  begin
    if vLock > 0 then
      Exit;

    InitGDBDebugger;
    if GDBStr = nil then
      GDBStr := THistoryStrs.Create;

    Inc(vLock);
    vDlg := TConsoleDlg.Create;
    try
      vDlg.FInitCmd := ACmd;

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Break;
        vFinish := True;
      end;

      UpdateDebuggerState;

    finally
      FreeObj(vDlg);
      Dec(vLock);
    end;
  end;


initialization

finalization
  FreeObj(GDBStr);
end.


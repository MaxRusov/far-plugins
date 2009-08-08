{$I Defines.inc}

unit FarDebugEvaluate;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Evaluate window                                                            *}
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
    FarDlg,
    FarGrid,

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB,
    FarDebugConsole;


  type
    TEvaluateDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FGrid       :TFarGrid;
      FRes        :THistoryStrs;
      FMaxWidth   :Integer;

      FInitExpr   :TString;
      FResCmd     :Integer;

//    procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
//    procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
//    procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure EvaluateExpr(const AExpr :TString);

      procedure ResizeDialog;
      procedure ReinitGrid;
    end;


  procedure EvaluateDlg;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TEvaluateDlg                                                                }
 {-----------------------------------------------------------------------------}

  const
    cDlgDefWidth  = 50;
    cDlgDefHeight = 10;

    cDlgMinWidth  = 30;
    cDlgMinHeight = 9;

    IdFrame  = 0;
    IdInput  = 1;
    IdResult = 2;


  constructor TEvaluateDlg.Create; {override;}
  begin
    inherited Create;
    FRes := THistoryStrs.CreateSize(SizeOf(THistoryRec));
//  RegisterHints(Self);
  end;


  destructor TEvaluateDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FRes);

//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TEvaluateDlg.Prepare; {override;}
  begin
    FHelpTopic := 'Evaluate';
    FWidth := cDlgDefWidth;
    FHeight := cDlgDefHeight;
    FItemCount := 3;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, GetMsg(strEvaluate)),
        NewItemApi(DI_Edit,        3, 2, FWidth - 7, -1, DIF_HISTORY, '', 'FarDebug.Evaluate' ),
        NewItemApi(DI_USERCONTROL, 3, 4, FWidth - 6, FHeight - 6, 0)
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdResult);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid.NormColor := GetOptColor(0, COL_DIALOGEDIT);
//  FGrid.SelColor := GetOptColor(optCurColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
  end;


  procedure TEvaluateDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    SendMsg(DM_SETFOCUS, IdInput, 0);
    ReinitGrid;
    if FInitExpr <> '' then
      EvaluateExpr(FInitExpr);
  end;


  procedure TEvaluateDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect, vRect1 :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

    vWidth := IntMax(FMaxWidth + 6, cDlgDefWidth);
    if vWidth > vScreenInfo.dwSize.X - 4 then
      vWidth := IntMax(vScreenInfo.dwSize.X - 4, cDlgMinWidth);

    vHeight := IntMax(FGrid.RowCount + 6, cDlgDefHeight);
    if vHeight > vScreenInfo.dwSize.Y - 2 then
      vHeight := IntMax(vScreenInfo.dwSize.Y - 2, cDlgMinHeight);

    vRect := SBounds(2, 1, vWidth - 5, vHeight - 3);
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    SendMsg(DM_SHOWITEM, IdFrame, 1);

    SRectGrow(vRect, -1, -1);

    vRect1 := vRect;
    vRect1.Bottom := vRect1.Top;
    Dec(vRect1.Right);
    SendMsg(DM_SETITEMPOSITION, IdInput, @vRect1);

    vRect1 := vRect;
    Inc(vRect1.Top, 2);
//  if vRect1.Bottom - vRect1.Top + 2 <= FGrid.RowCount then
//    Inc(vRect1.Right);
    SendMsg(DM_SETITEMPOSITION, IdResult, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;



  function TEvaluateDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < FRes.Count then
      Result := TString(PHistoryRec(FRes.PItems[ARow]).FStr);
  end;


  procedure TEvaluateDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  begin
    if SendMsg(DM_GETFOCUS, 0, 0) <> IdResult then
      AColor := FGrid.NormColor;
  end;


  procedure TEvaluateDlg.ReinitGrid;
//var
//  I :Integer;
  begin
//  Trace('ReinitGrid...');
    FMaxWidth := cDlgDefWidth;
//  if not FMaximized then
//    for I := 0 to GDBStr.Count - 1 do
//      FMenuMaxWidth := IntMax(FMenuMaxWidth, Length(TString(PHistoryRec(GDBStr.PItems[I]).FStr)));

    FGrid.RowCount := FRes.Count;
    SendMsg(DM_REDRAW, 0, 0);

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
      FGrid.GotoLocation(0, 0, lmScroll);
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TEvaluateDlg.EvaluateExpr(const AExpr :TString);
  var
    vStr, vRes :TString;
    vSel :TEditorSelect;
  begin
    try
      SetText(IdInput, AExpr);
      vSel.BlockType := BTYPE_STREAM;
      vSel.BlockStartLine := 0;
      vSel.BlockStartPos := 0;
      vSel.BlockWidth := Length(AExpr);
      vSel.BlockHeight := 1;
      SendMsg(DM_SETSELECTION, IdInput, @vSel);
      AddHistory(IdInput, AExpr);

      FRes.Clear;

      vStr := 'output ' + AExpr;
      RedirCall(vStr, @vRes);

      FRes.AddText(vRes, 0);
      ReinitGrid;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function TEvaluateDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

    procedure LocInput;
    var
      vExpr :TString;
    begin
      vExpr := GetText(IdInput);
      if vExpr <> '' then
        EvaluateExpr(vExpr)
      else begin
        FRes.Clear;
        ReinitGrid;
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
            LocInput;

        else
//        TraceF('Key: %d', [Param2]);
          if SendMsg(DM_GETFOCUS, 0, 0) = IdInput then begin

            case Param2 of
              KEY_CTRLPGUP:
                nop;
              KEY_CTRLPGDN:
                nop;
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


  procedure TEvaluateDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetWordUnderCursor :TString;
  var
    vInfo :TEditorInfo;
    vStrInfo :TEditorGetString;
    vStr :TString;
    vPos, vBeg :Integer;
  begin
    Result := '';
    FillChar(vInfo, SizeOf(vInfo), 0);
    if FARAPI.EditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      vStrInfo.StringNumber := -1;
      if FARAPI.EditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
        with vStrInfo do begin
          vStr := StringText;
         {$ifdef bUnicode}
         {$else}
//        if ??? then
//          vStr := StrDos2Win(vStr);
         {$endif bUnicode}

          if SelStart >= 0 then
            Result := Copy(vStr, SelStart + 1, SelEnd - SelStart)
          else begin
            vPos := IntMin(vInfo.CurPos + 1, Length(vStr));
            while (vPos > 0) and (CharIsWordChar(vStr[vPos]) or (vStr[vPos] = '.')) do
              Dec(vPos);
            Inc(vPos);
            vBeg := vPos;
            while (vPos <= Length(vStr)) and (CharIsWordChar(vStr[vPos]) or (vStr[vPos] = '.')) do
              Inc(vPos);
            Result := Copy(vStr, vBeg, vPos - vBeg)
          end;
        end;
      end;
    end;
  end;


  procedure EvaluateDlg;
  var
    vDlg :TEvaluateDlg;
    vFinish :Boolean;
  begin
    InitGDBDebugger;

    vDlg := TEvaluateDlg.Create;
    try
      vDlg.FInitExpr := GetWordUnderCursor;

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Break;
        vFinish := True;
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}

unit FarDebugDisasm;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Addrs list window                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    SysTypes,
    SysUtil,
    SysFmt,
    MSStr,
    MSUtils,
    MSClasses,

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
    FarDebugDlgBase;



  type
    TCodeLineType = (
      clFunc,
      clSource,
      clAsm
    );

    TCodeLine = class(TBasis)
    public
      constructor CreateFunc(const AFuncName :TString; const ASrcFile :TString; ASrcLine :Integer);

    protected
      FType     :TCodeLineType;

      FFuncName :TString;
      FSrcFile  :TString;
      FSrcLine  :Integer;

      FAddr     :TString;
      FAddrN    :TAddr;
      FDelta    :TString;
      FAsmStr   :TString;
    end;


    TDisasmDlg = class(TFarDebugListBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;

    private
      FCode       :TObjList;
      FSrcFile    :TString;
      FSrcLine    :Integer;
      FAddr1      :TAddr;
      FAddr2      :TAddr;

      FResCmd     :Integer;
//    FResIndex   :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;

      procedure ReinitGrid;
      procedure SelectItem(ACode :Integer);
      procedure DlgDebugCommand(const ACmd :TString);
      function FindIndexOfAddr(Addr :TAddr) :Integer;
      procedure GotoAddr(Addr :TAddr);

    end;


  procedure Disassemble;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MSDebug;



  function GetCurrentEditorAddr :TString;
  var
    vFileName :TString;
    vLine :Integer;
  begin
    Result := '';

    vFileName := EditorFile(-1);
    if vFileName = '' then
      Exit;

    vLine := GetCurrentEditorPos;
    if vLine = 0 then
      Exit;

    Result := GetAddrOfLine(vFileName, vLine, True);
  end;



  procedure ParseAsmStr(AList :TObjList; const AStr :TString);
  var
    vPtr, vTmp :PTChar;
    vStr :TString;
    vLine :TCodeLine;
  begin
    vPtr := PTChar(AStr);
    vStr := ExtractNextLine(vPtr); { Пропускаем заголовок }
    while vPtr^ <> #0 do begin
      vStr := ExtractNextLine(vPtr);
      if vPtr^ = #0 then
        Break;

      vTmp := PTChar(vStr);

      vLine := TCodeLine.Create;
      vLine.FType := clAsm;
      vLine.FAddr := ExtractNextWord(vTmp, [' ']);
      vLine.FAddrN := AddrToNum(vLine.FAddr);
      vLine.FDelta := ExtractNextWord(vTmp, [':', #9]);
      vLine.FAsmStr := vTmp;

      AList.Add(vLine);

    end;
  end;



  procedure DisasmAddr(ACode :TObjList; const Addr :TString);
  var
    vFileName, vProc, vAsmStr :TString;
    vLine :Integer;
  begin
    ACode.FreeAll;

    if GetSourceLineAt(Addr, vFileName, vLine, @vProc) then begin
      vProc := ExtractWord(1, vProc, ['+']);
      ACode.Add(TCodeLine.CreateFunc(vProc, vFileName, vLine));

      RedirCall('disas ' + Addr, @vAsmStr);

      ParseAsmStr(ACode, vAsmStr);

    end else
    begin
      vProc := ExtractWord(1, vProc, ['+']);
      ACode.Add(TCodeLine.CreateFunc(vProc, '', 0));

      RedirCall('disas ' + Addr, @vAsmStr);

      ParseAsmStr(ACode, vAsmStr);
    end;
  end;


  procedure PrepareDisasm(ACode :TObjList);
  var
    vAddr :TString;
  begin
    vAddr := GetCurrentEditorAddr;
    if vAddr = '' then
      vAddr := GetCurrentAddr;
    if vAddr = '' then
      AppErrorId(strProgramNotRun);
    DisasmAddr(ACode, vAddr);
  end;


 {-----------------------------------------------------------------------------}
 { TCodeLine                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TCodeLine.CreateFunc(const AFuncName :TString; const ASrcFile :TString; ASrcLine :Integer);
  begin
    Create;
    FType := clFunc;

    FFuncName := AFuncName;
    FSrcFile := ASrcFile;
    FSrcLine := ASrcLine;
  end;


 {-----------------------------------------------------------------------------}
 { TDisasmDlg                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TDisasmDlg.Create; {override;}
  begin
    inherited Create;
    FCode := TObjList.Create
//  RegisterHints(Self);
  end;


  destructor TDisasmDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FCode);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TDisasmDlg.Prepare; {override;}
  begin
    FHelpTopic := 'AddrsList';
    FWidth := cListDlgDefWidth;
    FHeight := cListDlgDefHeight;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, 'Disassemble' ),
        NewItemApi(DI_USERCONTROL, 3, 2, FWidth - 6, FHeight - 6, 0)
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
//  FGrid.NormColor := GetOptColor(0, COL_DIALOGEDIT);
//  FGrid.SelColor := GetOptColor(optCurColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
//  FGrid.OnGetCellColor := GridGetCellColor;
  end;


  procedure TDisasmDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
  end;


  procedure TDisasmDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
    if ADouble then
      SelectItem(1);
  end;


  function TDisasmDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vLine :TCodeLine;
  begin
    if ARow < FCode.Count then begin
      vLine := FCode[ARow];
      if vLine.FType = clAsm then begin

        Result := vLine.FAddr + ' ' + vLine.FAsmStr;

        if vLine.FAddrN = DebugAddrN then
          Result := '> ' + Result;

      end else
      begin

        Result := vLine.FFuncName;
        if vLine.FSrcFile <> '' then
          Result := Result  + ' (' + vLine.FSrcFile + ':' + Int2Str(vLine.FSrcLine) + ')';

      end;
    end;
  end;


  procedure TDisasmDlg.ReinitGrid;
  var
    I  :Integer;
    vLine :TCodeLine;
  begin
//  Trace('ReinitGrid...');
    FSrcFile := DebugSource;
    FSrcLine := DebugLine;

    FAddr1 := 0; FAddr2 := 0;
    for I := 0 to FCode.Count - 1 do begin
      vLine := FCode[I];
      if vLine.FType = clAsm then begin
        if FAddr1 = 0 then
          FAddr1 := vLine.FAddrN;
        FAddr2 := vLine.FAddrN;
      end;
    end;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 1) );
(*
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Int2Str(FList.Count))+2, taRightJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth1+2, taLeftJustify, [coColMargin], 2) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 3) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth3+2, taLeftJustify, [coColMargin], 4) );

    FMaxWidth := vWidth2 + 2;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Tag <> 3 then
          Inc(FMaxWidth, Width + 1);
*)

    FGrid.RowCount := FCode.Count;
    SendMsg(DM_REDRAW, 0, 0);

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
//    FGrid.GotoLocation(0, 0, lmScroll);
      GotoAddr(DebugAddrN);
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  function TDisasmDlg.FindIndexOfAddr(Addr :TAddr) :Integer;
  var
    I :Integer;
    vLine :TCodeLine;
  begin
    Result := -1;
    for I := 0 to FCode.Count - 1 do begin
      vLine := FCode[I];
      if vLine.FType = clAsm then begin
        if Addr >= vLine.FAddrN then
          Result := I;
        if Addr <= vLine.FAddrN then
          Exit;
      end;
    end;
    Result := -1;
  end;


  procedure TDisasmDlg.GotoAddr(Addr :TAddr);
  var
    vIndex :Integer;
  begin
    vIndex := FindIndexOfAddr(DebugAddrN);
    if vIndex = -1 then
      vIndex := 0;
    FGrid.GotoLocation(0, vIndex, lmScroll);
  end;


 {-----------------------------------------------------------------------------}

  procedure TDisasmDlg.SelectItem(ACode :Integer);
  begin
    {};
  end;


  procedure TDisasmDlg.DlgDebugCommand(const ACmd :TString);
  var
    vNeedReinit :Boolean;
  begin
    DebugCommand(ACmd, False);

    vNeedReinit := (DebugAddrN < FAddr1) or (DebugAddrN > FAddr2);
    if vNeedReinit then
      { Перешли на другую процедуру. Дизассемблируем ее. }
      DisasmAddr(FCode, DebugAddr);


    if not StrEqual(FSrcFile, DebugSource) or (FSrcLine <> DebugLine) then begin
      { Переоткроем диалог, чтобы спозиционировать редактор }
      FResCmd := 2;
      SendMsg(DM_CLOSE, -1, 0);
    end else
    begin

      if vNeedReinit then begin
        ReinitGrid;
      end else
      begin
        GotoAddr(DebugAddrN);
        SendMsg(DM_REDRAW, 0, 0);
      end;

    end;
  end;


  function TDisasmDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}
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

          KEY_F7:
            DlgDebugCommand('si');
          KEY_F8:
            DlgDebugCommand('ni');

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

  procedure Disassemble;
  var
    vDlg :TDisasmDlg;
    vFinish :Boolean;
  begin
    vDlg := TDisasmDlg.Create;
    try
      PrepareDisasm(vDlg.FCode);

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Break;

        case vDlg.FResCmd of
          1: {};

          2:
          begin
            if DebugSource <> '' then
              LocateSource(False);
            FARAPI.EditorControl(ECTL_REDRAW, nil);
          end;

        else
          vFinish := True;
        end
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.

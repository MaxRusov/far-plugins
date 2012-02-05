{$I Defines.inc}

unit FarDebugDisasm;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Disassemble window                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,

    Far_API,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarMenu,

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
      constructor CreateSrc(const ASrcFile :TString; ASrcLine :Integer; const ASrcStr :TString);

      function GetAsStr :TString;
      function GetAddrAsStr :TString;
      function GetSrcAsStr :TString;

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
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FCode       :TObjList;
      FSrcFile    :TString;
      FSrcLine    :Integer;
      FAddr1      :TAddr;
      FAddr2      :TAddr;

      FResCmd     :Integer;
//    FResIndex   :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      function GridPaintRow(ASender :TFarGrid; X, Y, AWidth :Integer; ARow :Integer; AColor :Integer) :Boolean;

      procedure ReinitGrid;
      procedure SelectItem(ACode :Integer);
      function FindIndexOfAddr(Addr :TAddr) :Integer;
//    function AddrByIndex(AIndex :Integer; ANearest :Boolean) :TAddr;
      function AddrByIndexS(AIndex :Integer; ANearest :Boolean) :TString;
      procedure GotoAddr(Addr :TAddr);
      procedure ToggleIntOption(var AOption :Integer; AMax :Integer);
      procedure ToggleOption(var AOption :Boolean; ANeedDisasm :Boolean = False);

      procedure DlgDebugCommand(const ACmd :TString);
      procedure RunUntil;
      procedure CommandMenu;
    end;


  procedure Disassemble;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;



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


  procedure ParseAsmStr(AList :TObjList; const AStr :TString; const AFileName :TString; AddSrc :Boolean);
  var
    vPtr, vTmp :PTChar;
    vStr, vFileName, vBegAddr, vEndAddr :TString;
    vItem :TCodeLine;
    vNext :TAddr;
    I, vLine, vLine1, vLine2 :Integer;
    vStrs :TStringList;
  begin
    vNext := 0; vLine1 := MaxInt; vLine2 := 0;
    vPtr := PTChar(AStr);
    vStr := ExtractNextLine(vPtr); { Пропускаем заголовок }
    while vPtr^ <> #0 do begin
      vStr := ExtractNextLine(vPtr);
      if vPtr^ = #0 then
        Break;

      vTmp := PTChar(vStr);

      vItem := TCodeLine.Create;
      vItem.FType := clAsm;
      vItem.FAddr := ExtractNextWord(vTmp, [' ', '=', '>'], True);
      vItem.FAddrN := AddrToNum(vItem.FAddr);
      vItem.FDelta := ExtractNextWord(vTmp, [':', #9]);
      vItem.FAsmStr := vTmp;

      if AddSrc and (vItem.FAddrN >= vNext) then begin
        try
          if GetSourceLineAt(vItem.FAddr, vFileName, vLine, nil, @vBegAddr, @vEndAddr) then begin
            if vLine > 0 then begin
              vLine1 := IntMin(vLine1, vLine);
              vLine2 := IntMax(vLine2, vLine);
            end;
            AList.Add(TCodeLine.CreateSrc(vFileName, vLine, ''));
            if vEndAddr <> '' then
              vNext := AddrToNum(vEndAddr)
            else
              AddSrc := False;
          end else
            AddSrc := False;
        except
          AddSrc := False;
        end;
      end;

      AList.Add(vItem);
    end;

    if vLine2 >= vLine1 then begin
      try
        { Запрашиваем листинг исходного файла }
        RedirCall(Format('list %0:s:%1:d,%0:s:%2:d', [vFileName, vLine1, vLine2]), @vStr);
      except
        on E :Exception do begin
          HandleError(E);
          Exit;
        end;
      end;

      vStrs := TStringList.Create;
      try
        vStrs.Text := vStr;
        for I := 0 to AList.Count - 1 do begin
          vItem := AList[I];
          if vItem.FType = clSource then begin
            vLine := vItem.FSrcLine;
            if (vLine >= vLine1) and (vLine < vLine1 + vStrs.Count) then begin
              vStr := ExtractWords(2, MaxInt, vStrs[vLine - vLine1], [#9, ' ']);
              vItem.FAsmStr := vStr;
            end;
          end;
        end;
      finally
        FreeObj(vStrs);
      end;
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
      ParseAsmStr(ACode, vAsmStr, vFileName, optCPUMixSrc);
    end else
    begin
      vProc := ExtractWord(1, vProc, ['+']);
      ACode.Add(TCodeLine.CreateFunc(vProc, '', 0));

      RedirCall('disas ' + Addr, @vAsmStr);
      ParseAsmStr(ACode, vAsmStr, '', False);
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
//  Create;
    FType := clFunc;

    FFuncName := AFuncName;
    FSrcFile := ASrcFile;
    FSrcLine := ASrcLine;
  end;


  constructor TCodeLine.CreateSrc(const ASrcFile :TString; ASrcLine :Integer; const ASrcStr :TString);
  begin
    FType := clSource;

    FSrcFile := ASrcFile;
    FSrcLine := ASrcLine;

    FAsmStr  := ASrcStr;
  end;


  function TCodeLine.GetAsStr :TString;
  begin
    Result := '';
    if FType = clFunc then begin
      Result := FFuncName;
//    if vLine.FSrcFile <> '' then
//      vStr := vStr  + ' (' + vLine.FSrcFile + ':' + Int2Str(vLine.FSrcLine) + ')';
    end else
    if FType = clSource then
      Result := GetSrcAsStr;
  end;


  function TCodeLine.GetAddrAsStr :TString;
  begin
    Result := '';
    case optCPUShowAddr of
      1: Result := FAddr;
      2: Result := FDelta;
      3: Result := FAddr + ' ' + FDelta;
    end;
  end;


  function TCodeLine.GetSrcAsStr :TString;
  begin
    Result := '';
    case optCPUShowSrc of
      0: Result := FSrcFile + ':' + Int2Str(FSrcLine);
      1: Result := FSrcFile + ':' + Int2Str(FSrcLine) + ': ' + FAsmStr;
      2: Result := Int2Str(FSrcLine) + ': ' + FAsmStr;
      3: Result := FAsmStr;
    end;
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
    FGUID := cDisasmDlgID;
    FHelpTopic := 'Disassemble';
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
    FGrid.OnPaintRow := GridPaintRow;
    FGrid.OnGetCellColor := GridGetCellColor;
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


  procedure TDisasmDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  var
    vLine :TCodeLine;
  begin
    if (ARow < FCode.Count) and (ARow <> FGrid.CurRow) then begin
      vLine := FCode[ARow];
      if vLine.FType <> clAsm then
        AColor := (AColor and $F0) + (optCPUSrcColor and $0F)
      else
      if ACol <> -1 then begin
        case FGrid.Column[ACol].Tag of
          1: {};
          2: AColor := (AColor and $F0) + (optCPUAddrColor and $0F);
          3: AColor := (AColor and $F0) + (optCPUAsmColor and $0F);
        end;
      end;
    end;
  end;


  function TDisasmDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vLine :TCodeLine;
  begin
    Result := '';
    if ARow < FCode.Count then begin
      vLine := FCode[ARow];
      if vLine.FType = clAsm then begin
        case FGrid.Column[ACol].Tag of
          1: if vLine.FAddrN = DebugAddrN then
               Result := optCPUCurChar;
          2: Result := vLine.GetAddrAsStr;
          3: Result := vLine.FAsmStr;
        end;
      end;
    end;
  end;


  function TDisasmDlg.GridPaintRow(ASender :TFarGrid; X, Y, AWidth :Integer; ARow :Integer; AColor :Integer) :Boolean;
  var
    vLine :TCodeLine;
    vStr :TString;
  begin
    Result := False;
    if ARow < FCode.Count then begin
      vLine := FCode[ARow];
      if vLine.FType <> clAsm then begin

        vStr := vLine.GetAsStr;
        FGrid.DrawChr(X, Y, PTChar(vStr), length(vStr), AColor);

        Result := True;
      end;
    end;
  end;


  procedure TDisasmDlg.ReinitGrid;
  var
    I, vWidth, vWidth1, vWidth2 :Integer;
    vLine :TCodeLine;
  begin
    FSrcFile := DebugSource;
    FSrcLine := DebugLine;

    FAddr1 := 0; FAddr2 := 0;

    FMaxWidth := 0; vWidth1 := 0; vWidth2 := 0;
    for I := 0 to FCode.Count - 1 do begin
      vLine := FCode[I];
      if vLine.FType = clAsm then begin
        if FAddr1 = 0 then
          FAddr1 := vLine.FAddrN;
        FAddr2 := vLine.FAddrN;

        if optCPUShowAddr <> 0 then
          vWidth1 := IntMax(vWidth1, length(vLine.GetAddrAsStr));
        vWidth2 := IntMax(vWidth2, length(vLine.FAsmStr));
      end else
        FMaxWidth := IntMax(FMaxWidth, length(vLine.GetAsStr));
    end;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 2, taLeftJustify, [coNoVertLine], 1) );
    if optCPUShowAddr <> 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth1 + 2, taLeftJustify, [coNoVertLine], 2) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth2 + 1, taLeftJustify, [coNoVertLine], 3) );

    vWidth := 0;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then
          Inc(vWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
    FGrid.Column[FGrid.Columns.Count - 1].Width := 0;
    FMaxWidth := IntMax(FMaxWidth, vWidth);

    FGrid.RowCount := FCode.Count;

//  SendMsg(DM_ENABLEREDRAW, 0, 0);
//  try
      ResizeDialog;
      GotoAddr(DebugAddrN);
//  finally
//    SendMsg(DM_ENABLEREDRAW, 1, 0);
//  end;
  end;


(*function TDisasmDlg.AddrByIndex(AIndex :Integer; ANearest :Boolean) :TAddr;
  var
    vLine :TCodeLine;
  begin
    Result := 0;
    if (AIndex >= 0) and (AIndex < FCode.Count) then begin
      vLine := FCode[AIndex];
      if vLine.FType = clAsm then
        Result :=  vLine.FAddrN;
    end;
  end;*)


  function TDisasmDlg.AddrByIndexS(AIndex :Integer; ANearest :Boolean) :TString;
  var
    vLine :TCodeLine;
  begin
    Result := '';
    if (AIndex >= 0) and (AIndex < FCode.Count) then begin
      vLine := FCode[AIndex];
      if vLine.FType = clAsm then
        Result :=  vLine.FAddr;
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
    FGrid.GotoLocation(0, vIndex, lmSafe);
  end;


 {-----------------------------------------------------------------------------}

  procedure TDisasmDlg.SelectItem(ACode :Integer);
  begin
    {};
  end;


  procedure TDisasmDlg.ToggleIntOption(var AOption :Integer; AMax :Integer);
  begin
    if AOption < AMax then
      Inc(AOption)
    else
      AOption := 0;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TDisasmDlg.ToggleOption(var AOption :Boolean; ANeedDisasm :Boolean = False);
  begin
    AOption := not AOption;
    if ANeedDisasm then begin
      FGrid.ScrollTo(0, 0);
      DisasmAddr(FCode, DebugAddr);
    end;
    ReinitGrid;
    WriteSetup;
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
//      SendMsg(DM_REDRAW, 0, 0);
      end;

      FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);
    end;
  end;


  procedure TDisasmDlg.RunUntil;
  var
    vAddr :TString;
  begin
    vAddr := AddrByIndexS(FGrid.CurRow, True);
    if vAddr <> '' then begin

      RedirCall('tbreak *' + vAddr);
      DlgDebugCommand('continue');

    end else
      Beep;
  end;


  procedure TDisasmDlg.CommandMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMStep),
      GetMsg(strMNext),
      GetMsg(strMUntil),
      GetMsg(strMLeave),
      GetMsg(strMRun),
//    GetMsg(strMKill),
      GetMsg(strMLocate),
      '',
      GetMsg(strMAddBreakpoit)

    ]);

    try
      vMenu.Help := 'DisasmMenu';

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: DlgDebugCommand('stepi');
        1: DlgDebugCommand('nexti');
        2: RunUntil;
        3: DlgDebugCommand('finish');
        4: DlgDebugCommand('continue');
        5: GotoAddr(DebugAddrN);
        6: {};
        7: Sorry;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  function TDisasmDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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

          KEY_CTRL1:
            ToggleIntOption(optCPUShowAddr, 3);
          KEY_CTRL2:
            ToggleIntOption(optCPUShowSrc, 3);
          KEY_CTRL3:
            ToggleOption(optCPUMixSrc, True);

          KEY_F2:
            CommandMenu;

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
    InitGDBDebugger;
    
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
//          FARAPI.EditorControl(ECTL_REDRAW, nil);
            FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);
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

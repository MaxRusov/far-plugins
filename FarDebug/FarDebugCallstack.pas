{$I Defines.inc}

unit FarDebugCallstack;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Callstack window                                                           *}
{******************************************************************************}

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
    FarDlg,
    FarGrid,
    FarMatch,

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB,
    FarDebugDlgBase;


  var
    optStackShowIndex :Boolean = True;
    optStackShowAddr  :Boolean = True;
    optStackShowLoc   :Boolean = True;


  type
    TStackItem = class(TBasis)
    private
      FStr  :TString;
      FFunc :TString;
      FAddr :TString;
      FLoc  :TString;
    end;


    TCallstackDlg = class(TFarDebugListBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FStack      :TObjList;

      FResCmd     :Integer;
      FResIndex   :Integer;
      FTopLine    :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;

      procedure ReinitGrid;
      procedure ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
      procedure SelectItem(ACode :Integer);
    end;


  procedure CallstackDlg;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure GetCallstack(AStack :TObjList);
  var
    vRes, vStr, vSrcName :TString;
    vOldWidth, vPos, vLen, vLine :Integer;
    vPtr, vTmp :PTChar;
    vItem :TStackItem;
  begin
    RedirCall('show width', @vRes);
    vOldWidth := Str2IntDef(ExtractBefore(vRes, '*is *', '*.*'), -1);
    RedirCall('set width -1');
    try
      RedirCall('backtrace', @vRes);
      if vRes <> '' then begin
//      TraceF('Stack: %s', [vRes]);

        vPtr := PTChar(vRes);
        while vPtr^ <> #0 do begin
          vStr := ExtractNextLine(vPtr);
          vItem := TStackItem.Create;
          vItem.FStr := vStr;

          vTmp := PTChar(vStr);
          if vTmp^ = '#' then begin
            Inc(vTmp);
            ExtractNextInt(vTmp, [' ']);
            if UpCompareSubPChar('0x', vTmp) = 0 then
              vItem.FAddr := ExtractNextWord(vTmp, [' ']);
            if UpCompareSubPChar('in ', vTmp) = 0 then
              ExtractNextWord(vTmp, [' ']);

            if StringMatch('*) at *', vTmp, vPos, vLen) then begin
              SetString(vItem.FFunc, vTmp, vPos + 1);
              Inc(vTmp, vPos + vLen);
              ExtractLocation(vTmp, vSrcName, vLine);
              vItem.FLoc := vSrcName + ':' + Int2Str(vLine);
            end else
              vItem.FFunc := vTmp;

            AStack.Add(vItem);
          end;
        end;
      end;

      if AStack.Count > 0 then
        with TStackItem(AStack[0]) do
          if FAddr = '' then
            FAddr := GetCurrentAddr;

    finally
      if vOldWidth <> - 1 then
        RedirCall('set width ' + Int2Str(vOldWidth));
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCallstackDlg                                                                }
 {-----------------------------------------------------------------------------}

  constructor TCallstackDlg.Create; {override;}
  begin
    inherited Create;
    FStack := TObjList.Create
//  RegisterHints(Self);
  end;


  destructor TCallstackDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FStack);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TCallstackDlg.Prepare; {override;}
  begin
    FHelpTopic := 'Callstack';
    FWidth := cListDlgDefWidth;
    FHeight := cListDlgDefHeight;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, GetMsg(strCallstack)),
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


  procedure TCallstackDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
    FGrid.GotoLocation(0, FResIndex, lmScroll);
  end;


  procedure TCallstackDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
    if ADouble then
      SelectItem(1);
  end;


  function TCallstackDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < FStack.Count then begin
      case FGrid.Column[ACol].Tag of
        1: Result := Int2Str(ARow + 1);
        2: Result := TStackItem(FStack[ARow]).FFunc;
        3: Result := TStackItem(FStack[ARow]).FAddr;
        4: Result := TStackItem(FStack[ARow]).FLoc;
      end
    end;
  end;


  procedure TCallstackDlg.ReinitGrid;
  var
    I, vWidth1, vWidth2, vWidth3  :Integer;
  begin
//  Trace('ReinitGrid...');
    vWidth1 := 0; vWidth2 := 0; vWidth3 := 0;
    for I := 0 to FStack.Count - 1 do
      with TStackItem(FStack[i]) do begin
        vWidth1 := IntMax(vWidth1, Length(FFunc));
        vWidth2 := IntMax(vWidth2, Length(FAddr));
        vWidth3 := IntMax(vWidth3, Length(FLoc));
      end;


    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    if optStackShowIndex then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Int2Str(FStack.Count))+2, taRightJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 2) );
    if optStackShowAddr then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth2+2, taLeftJustify, [coColMargin], 3) );
    if optStackShowLoc then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth3+2, taLeftJustify, [coColMargin], 4) );

    FMaxWidth := vWidth1 + 2;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Tag <> 2 then
          Inc(FMaxWidth, Width + 1);

          
    FGrid.RowCount := FStack.Count;
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

  procedure TCallstackDlg.ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
  begin
    AOption := not AOption;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TCallstackDlg.SelectItem(ACode :Integer);
  begin
    FResIndex := FGrid.CurRow;
    if (FResIndex >= 0) and (FResIndex < FStack.Count) then begin
      FResCmd := 1;
      FTopLine := GetDlgRect.Top;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  function TCallstackDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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
            ToggleOption(optStackShowIndex);
          KEY_CTRL2:
            ToggleOption(optStackShowAddr);
          KEY_CTRL3:
            ToggleOption(optStackShowLoc);

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

  procedure CallstackDlg;
  var
    vDlg :TCallstackDlg;
    vFinish :Boolean;
  begin
    UpdateDebuggerState;
    if DebugAddr = '' then
      AppErrorId(strProgramNotRun);

    vDlg := TCallstackDlg.Create;
    try
      GetCallstack(vDlg.FStack);

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Break;

        case vDlg.FResCmd of
          1: LocateByAddr( TStackItem(vDlg.FStack[vDlg.FResIndex]).FAddr, vDlg.FTopLine );
        else
          vFinish := True;
        end
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}

unit FarDebugAddrsList;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Addrs list window                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
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

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB,
    FarDebugDlgBase;


  const
    cAddrDelims = [' ', ',', ';', '.', ':', '|', '-', '='];

  type
    TStackItem = class(TBasis)
    private
      FFunc :TString;
      FAddr :TString;
      FLoc  :TString;
    end;


    TAddrsDlg = class(TFarDebugListBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;

    private
      FList       :TObjList;

      FResCmd     :Integer;
      FResIndex   :Integer;
      FTopLine    :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;

      procedure ReinitGrid;
      procedure SelectItem(ACode :Integer);
    end;


  procedure AddrsDlg(const Addrs :TString);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TAddrsDlg                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TAddrsDlg.Create; {override;}
  begin
    inherited Create;
    FList := TObjList.Create
//  RegisterHints(Self);
  end;


  destructor TAddrsDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FList);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TAddrsDlg.Prepare; {override;}
  begin
    FHelpTopic := 'AddrsList';
    FWidth := cListDlgDefWidth;
    FHeight := cListDlgDefHeight;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, GetMsg(strFindAddress) ),
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


  procedure TAddrsDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
    FGrid.GotoLocation(0, FResIndex, lmScroll);
  end;


  procedure TAddrsDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
    if ADouble then
      SelectItem(1);
  end;


  function TAddrsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    Result := '';
    if ARow < FList.Count then begin
      with TStackItem(FList[ARow]) do begin
        case FGrid.Column[ACol].Tag of
          1: Result := Int2Str(ARow + 1);
          2: Result := FAddr;
          3: Result := FFunc;
          4: Result := FLoc;
        end
      end;
    end;
  end;


  procedure TAddrsDlg.ReinitGrid;
  var
    I, vWidth1, vWidth2, vWidth3  :Integer;
  begin
//  Trace('ReinitGrid...');
    vWidth1 := 0; vWidth2 := 0; vWidth3 := 0;
    for I := 0 to FList.Count - 1 do
      with TStackItem(FList[i]) do begin
        vWidth1 := IntMax(vWidth1, Length(FAddr));
        vWidth2 := IntMax(vWidth2, Length(FFunc));
        vWidth3 := IntMax(vWidth3, Length(FLoc));
      end;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Int2Str(FList.Count))+2, taRightJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth1+2, taLeftJustify, [coColMargin], 2) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin], 3) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vWidth3+2, taLeftJustify, [coColMargin], 4) );

    FMaxWidth := vWidth2 + 2;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Tag <> 3 then
          Inc(FMaxWidth, Width + 1);


    FGrid.RowCount := FList.Count;
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

  procedure TAddrsDlg.SelectItem(ACode :Integer);
  begin
    FResIndex := FGrid.CurRow;
    if (FResIndex >= 0) and (FResIndex < FList.Count) then begin
      FResCmd := 1;
      FTopLine := GetDlgRect.Top;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  function TAddrsDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}
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

  procedure ParseAddresses(const Addrs :TString; AList :TObjList);
  var
    I, M, vLine :Integer;
    vAddr, vFileName, vFunc :TString;
    vItem :TStackItem;
  begin
    M := WordCount(Addrs, cAddrDelims);
    for I := 1 to M do begin
      vAddr := ExtractWord(I, Addrs, cAddrDelims);
      if UpCompareSubstr('0x', vAddr) <> 0 then
        vAddr := '0x' + vAddr;
      vFunc := '';
      GetSourceLineAt(vAddr, vFileName, vLine, @vFunc);
      vItem := TStackItem.Create;
      vItem.FAddr := vAddr;
      vItem.FFunc := ExtractWord(1, vFunc, ['+']);
      if vFileName <> '' then
        vItem.FLoc := vFileName + ':' + Int2Str(vLine);
      AList.Add(vItem);
    end;
  end;


  procedure AddrsDlg(const Addrs :TString);
  var
    vDlg :TAddrsDlg;
    vFinish :Boolean;
  begin
    vDlg := TAddrsDlg.Create;
    try
      ParseAddresses(Addrs, vDlg.FList);

      if vDlg.FList.Count = 1 then
        with TStackItem(vDlg.FList[0]) do
          if FLoc <> '' then begin
            { Если адрес один и позиция найдена - сразу перейдем на него... }
            LocateByAddr( FAddr );
            Exit;
          end;

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Break;

        case vDlg.FResCmd of
          1: LocateByAddr( TStackItem(vDlg.FList[vDlg.FResIndex]).FAddr, vDlg.FTopLine );
        else
          vFinish := True;
        end
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.

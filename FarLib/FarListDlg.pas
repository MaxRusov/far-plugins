{$I Defines.inc}

unit FarListDlg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Типовой диалог - список                                                    *}
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
    FarGrid;


  const
    cDlgMinWidth  = 30;
    cDlgMinHeight = 5;

    IdFrame = 0;
    IdList = 1;
    IdStatus = 2;


  type
    TFarListDlg = class(TFarDialog)
    public
      destructor Destroy; override;

      procedure SetFooter(const AStr :TString);

    protected
      procedure Prepare; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    protected
      FGrid           :TFarGrid;
      FMenuMaxWidth   :Integer;
      FMaxHeightPerc  :Integer;   { Ограничитель высоты диалога }
      FBottomAlign    :Boolean;   { Прижимать диалог к нижней части окна }

      procedure ResizeDialog;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode = lmScroll);

    public
      property Grid :TFarGrid read FGrid;
    end;


  type
    TFilteredListDlg = class;

    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FIdx :Integer;
      FPos :Word;
      FLen :Word;
    end;

    TListFilter = class(TExList)
    public
      constructor Create; override;

      procedure Add(AIndex, APos, ALen :Integer);

      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;

    private
      FOwner :TFilteredListDlg;

      function GetItems(AIndex :Integer) :Integer;

    public
      property Owner :TFilteredListDlg read FOwner write FOwner;
      property Items[AIndex :Integer] :Integer read GetItems; default;
    end;


    TFilteredListDlg = class(TFarListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;

      procedure SelectItem(ACode :Integer); virtual;
      procedure UpdateHeader; virtual;
      procedure ReinitGrid; virtual;
      procedure ReinitAndSaveCurrent; virtual;

      procedure GridPosChange(ASender :TFarGrid); virtual;
      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; {const} AColor :TFarColor); virtual;
      
      function ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; virtual;

    protected
      FFilter       :TListFilter;
      FFilterMask   :TString;
      FFilterColumn :Integer;
      FTotalCount   :Integer;

      function RowToIdx(ARow :Integer) :Integer;
    end;



{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TFarListDlg                                                                 }
 {-----------------------------------------------------------------------------}

  destructor TFarListDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    inherited Destroy;
  end;


  procedure TFarListDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_USERCONTROL, 3, 2, DX - 6, DY - 4, 0, '' ),
        NewItemApi(DI_Text,        3, 3, 3, 1, DIF_CENTERTEXT or DIF_HIDDEN, '')
      ],
      @FItemCount
    );
    FGrid := TFarGrid.CreateEx(Self, IdList);
  end;


  procedure TFarListDlg.SetFooter(const AStr :TString);
  var
    vRect :TSmallRect;
  begin
    if AStr <> '' then begin
      SetText(IdStatus, AStr);
      SendMsg(DM_GETITEMPOSITION, IdStatus, @vRect);
      with GetDlgRect do
        vRect.Left := ((Right - Left) - (length(AStr)+1)) div 2;
      vRect.Right := vRect.Left + length(AStr)+1;
      SendMsg(DM_SETITEMPOSITION, IdStatus, @vRect);
      SendMsg(DM_ShowItem, IdStatus, 1);
    end else
      SendMsg(DM_ShowItem, IdStatus, 0);
  end;


  procedure TFarListDlg.ResizeDialog;
  var
    vWidth, vHeight, vMaxHeight, vTop :Integer;
    vRect :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vSize.CX - 4 then
      vWidth := vSize.CX - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + FGrid.Margins.Top + FGrid.Margins.Bottom + 4;
    if vHeight > vSize.CY - 2 then
      vHeight := vSize.CY - 2;

    if FMaxHeightPerc <> 0 then begin
      vMaxHeight := MulDiv(vSize.CY, FMaxHeightPerc, 100);
      if vHeight > vMaxHeight then
        vHeight := vMaxHeight;
    end;

    vHeight := IntMax(vHeight, cDlgMinHeight);

    vTop := -1;
    if FBottomAlign then
      vTop := IntMin(vSize.cy div 2, vSize.cy - vHeight - 2);

    SetDlgPos(-1, vTop, vWidth, vHeight);

    vRect.Left := 2;
    vRect.Top := 1;
    vRect.Right := vWidth - 3;
    vRect.Bottom := vHeight - 2;
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    RectGrow(vRect, -1, -1);
    if vRect.Bottom - vRect.Top + 2 <= FGrid.RowCount then
      Inc(vRect.Right);

    SendMsg(DM_SETITEMPOSITION, IdList, @vRect);
    FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);

    SendMsg(DM_GETITEMPOSITION, IdStatus, @vRect);
    vRect.Top := vHeight - 2; vRect.Bottom := vRect.Top;
    SendMsg(DM_SETITEMPOSITION, IdStatus, @vRect);
  end;


  procedure TFarListDlg.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  function TFarListDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        begin
          ResizeDialog;
          SetCurrent(FGrid.CurRow);
        end;

      DN_CTLCOLORDIALOG:
       {$ifdef Far3}
        PFarColor(Param2)^ := FarGetColor(COL_MENUTEXT);
       {$else}
        Result := FarGetColor(COL_MENUTEXT);
       {$endif Far3}

      DN_CTLCOLORDLGITEM:
        if (Param1 = IdFrame) or (Param1 = IDStatus) then
         {$ifdef Far3}
          CtrlPalette1([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX], PFarDialogItemColors(Param2)^)
         {$else}
          Result := CtrlPalette1([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX])
         {$endif Far3}
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TListFilter                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TListFilter.Create; {override;}
  begin
    inherited Create;
    FItemSize  := SizeOf(TFilterRec);
    FItemLimit := MaxInt div FItemSize;
  end;


  procedure TListFilter.Add(AIndex, APos, ALen :Integer);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := Word(APos);
    vRec.FLen := Word(ALen);
    AddData(vRec);
  end;


  function TListFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


  function TListFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    if FOwner <> nil then
      Result := FOwner.ItemCompare(PInteger(PItem)^, PInteger(PAnother)^, Context)
    else
      Result := inherited ItemCompare(PItem, PAnother, Context);
  end;


 {-----------------------------------------------------------------------------}
 { TFilteredListDlg                                                            }
 {-----------------------------------------------------------------------------}

  constructor TFilteredListDlg.Create; {override;}
  begin
    inherited Create;
//  FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
  end;


  destructor TFilteredListDlg.Destroy; {override;}
  begin
    FreeObj(FFilter);
    inherited Destroy;
  end;


  procedure TFilteredListDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
  end;


  procedure TFilteredListDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
  end;

  
  procedure TFilteredListDlg.UpdateHeader; {virtual;}
  begin
  end;


  procedure TFilteredListDlg.ReinitGrid; {virtual;}
  begin
  end;


  procedure TFilteredListDlg.ReinitAndSaveCurrent; {virtual;}
  begin
  end;


  procedure TFilteredListDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if AButton = 1 then
      SelectItem(IntIf(ADouble, 2, 1));
  end;


  procedure TFilteredListDlg.GridPosChange(ASender :TFarGrid); {virtual;}
  begin
    {Abstract}
  end;


  procedure  TFilteredListDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {virtual;}
  begin
    {Abstract}
  end;


  function TFilteredListDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  begin
    Result := '';
  end;


  procedure TFilteredListDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; {const} AColor :TFarColor); {virtual;}
  begin
    {Abstract}
  end;


  procedure TFilteredListDlg.SelectItem(ACode :Integer);  {virtual;}
  begin
    {Abstract}
  end;


  function TFilteredListDlg.ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; {virtual;}
  begin
    Wrong; Result := 0;
  end;


  function TFilteredListDlg.RowToIdx(ARow :Integer) :Integer;
  begin
    if FFilter = nil then
      Result := ARow
    else begin
      Result := -1;
      if ARow < FFilter.Count then
        Result := FFilter[ARow];
    end;
  end;


  function TFilteredListDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure LocSetFilter(const ANewFilter :TString);
    begin
      if ANewFilter <> FFilterMask then begin
//      TraceF('Mask: %s', [ANewFilter]);
//      FFilterMode := ANewFilter <> '';
        if FFilterMask = '' then
          FFilterColumn := FGrid.Column[FGrid.CurCol].Tag;
        FFilterMask := ANewFilter;
        ReinitAndSaveCurrent;
      end;
    end;

  begin
    Result := True;
    case AKey of
      KEY_ENTER:
        SelectItem(2);

      { Фильтрация }
      KEY_DEL, KEY_ALT, KEY_RALT:
        LocSetFilter('');
      KEY_BS:
        if FFilterMask <> '' then
          LocSetFilter( Copy(FFilterMask, 1, Length(FFilterMask) - 1));

      KEY_ADD      : LocSetFilter( FFilterMask + '+' );
      KEY_SUBTRACT : LocSetFilter( FFilterMask + '-' );
      KEY_DIVIDE   : LocSetFilter( FFilterMask + '/' );
      KEY_MULTIPLY : LocSetFilter( FFilterMask + '*' );

    else
//    TraceF('Key: %d', [Param2]);
      if (AKey >= 32) and (AKey < $FFFF) then
        LocSetFilter(FFilterMask + WideChar(AKey))
      else
        Result := inherited KeyDown(AID, AKey);
    end;
  end;


end.


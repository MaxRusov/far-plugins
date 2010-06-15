{$I Defines.inc}

unit MoreHistoryListBase;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
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
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarKeysW,
    FarColor,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,

    MoreHistoryCtrl,
    MoreHistoryClasses;


  type
    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FIdx :Integer;
      FPos :Word;
      FLen :Byte;
      FSel :Byte;
    end;

    TMyFilter = class(TExList)
    public
      procedure Add(AIndex, APos, ALen :Integer);
      procedure AddGroup(AIndex :Integer; AExpanded :Boolean);

    public
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;

    private
      FName :TString;
      FDomain :TString;

      function GetItems(AIndex :Integer) :Integer;

    public
      property Name :TString read FName write FName;
      property Domain :TString read FDomain write FDomain;
      property Items[AIndex :Integer] :Integer read GetItems; default;
    end;


  const
    cDlgMinWidth  = 50;
    cDlgMinHeight = 5;

    IdFrame = 0;
    IdList = 1;

  type
    TListBase = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

      procedure SelectItem(ACode :Integer); virtual;
      procedure UpdateHeader; virtual;
      procedure ReinitGrid; virtual;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); virtual;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); virtual;

    protected
      FGrid           :TFarGrid;

      FMenuMaxWidth   :Integer;

      FHiddenColor    :Integer;
      FFoundColor     :Integer;
      FSelectedColor  :Integer;
      FGroupColor     :Integer;

      procedure ResizeDialog;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode);

    public
      property Grid :TFarGrid read FGrid;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TMyFilter                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyFilter.Add(AIndex, APos, ALen :Integer);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := Word(APos);
    vRec.FLen := Byte(ALen);
    vRec.FSel := 0;
    AddData(vRec);
  end;


  procedure TMyFilter.AddGroup(AIndex :Integer; AExpanded :Boolean);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := 0;
    vRec.FLen := 0;
    vRec.FSel := 2;
    if AExpanded then
      vRec.FSel := vRec.FSel or 4;
    AddData(vRec);
  end;


  function TMyFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


  function TMyFilter.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FName, TString(Key));
  end;


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vHst1, vHst2 :THistoryEntry;
  begin
    Result := 0;

    vHst1 := FarHistory[PFilterRec(PItem).FIdx];
    vHst2 := FarHistory[PFilterRec(PAnother).FIdx];

    case Abs(Context) of
      1 : Result := UpCompareStr(vHst1.Path, vHst2.Path);
      2 : Result := DateTimeCompare(vHst1.Time, vHst2.Time);
      3 : Result := IntCompare(vHst1.Hits, vHst2.Hits);
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
  end;


 {-----------------------------------------------------------------------------}
 { TListBase                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TListBase.Create; {override;}
  begin
    inherited Create;

    FFoundColor := GetOptColor(optFoundColor, COL_MENUHIGHLIGHT);
    FHiddenColor := GetOptColor(optHiddenColor, COL_MENUDISABLEDTEXT);
    FGroupColor := GetOptColor(optGroupColor, COL_MENUTEXT);
    FSelectedColor := optSelectedColor;
  end;


  destructor TListBase.Destroy; {override;}
  begin
    FreeObj(FGrid);
    inherited Destroy;
  end;


  procedure TListBase.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FWidth := DX;
    FHeight := DY;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_USERCONTROL, 3, 2, DX - 6, DY - 4, 0, '' )
      ]
    );
    FGrid := TFarGrid.CreateEx(Self, IdList);
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect {,goFollowMouse} {,goWheelMovePos}];
  end;


  procedure TListBase.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
  end;


  function TListBase.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TListBase.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vSize.CX - 4 then
      vWidth := vSize.CX - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 4;
    if vHeight > vSize.CY - 2 then
      vHeight := vSize.CY - 2;
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


  procedure TListBase.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  procedure TListBase.UpdateHeader; {virtual;}
  begin
  end;


  procedure TListBase.ReinitGrid; {virtual;}
  begin
  end;



  procedure TListBase.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if (AButton = 1) {and ADouble} then
      SelectItem(1);
  end;


  function TListBase.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  begin
    Result := '';
  end;


  procedure TListBase.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); {override;}
  begin
    {Abstract}
  end;


  procedure TListBase.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {virtual;}
  begin
    {Abstract}
  end;


  procedure TListBase.SelectItem(ACode :Integer);  {virtual;}
  begin
    {Abstract}
  end;


  function TListBase.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}
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
          SetCurrent(FGrid.CurRow, lmScroll);
        end;

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectItem(1);
          KEY_CTRLENTER:
            SelectItem(2);
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;



end.


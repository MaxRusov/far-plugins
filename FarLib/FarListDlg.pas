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
    FarGrid;


  const
    cDlgMinWidth  = 30;
    cDlgMinHeight = 5;

    IdFrame = 0;
    IdList = 1;

  type
    TFarListDlg = class(TFarDialog)
    public
      destructor Destroy; override;

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
    end;


  type
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

    private
      function GetItems(AIndex :Integer) :Integer;

    public
      property Items[AIndex :Integer] :Integer read GetItems; default;
    end;


    TDrawBuf = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure Clear;
      procedure Add(AChr :TChar; Attr :Byte; ACount :Integer = 1);
      procedure AddStrExpandTabsEx(AStr :PTChar; ALen :Integer; AColor :Byte);
      procedure FillAttr(APos, ACount :Integer; AColor :Byte);
      procedure FillLoAttr(APos, ACount :Integer; ALoColor :Byte);

      procedure Paint(X, Y, ADelta, ALimit :Integer);

    private
      FTabSize      :Integer;
      FChars        :PTChar;
      FAttrs        :PByteArray;
      FCount        :Integer;
      FSize         :Integer;

      procedure SetSize(ASize :Integer);

    public
      property Count :Integer read FCount;
    end;


    TFilteredListDlg = class(TFarListDlg)
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
      procedure ReinitAndSaveCurrent; virtual;

      procedure GridPosChange(ASender :TFarGrid); virtual;
      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); virtual;

    protected
      FDrawBuf     :TDrawBuf;
      FFilter      :TListFilter;
      FFilterMask  :TString;
      FTotalCount  :Integer;

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
        NewItemApi(DI_DoubleBox, 2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_USERCONTROL, 3, 2, DX - 6, DY - 4, 0, '' )
      ],
      @FItemCount
    );
    FGrid := TFarGrid.CreateEx(Self, IdList);
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

    vHeight := FGrid.RowCount + 4;
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
    SRectGrow(vRect, -1, -1);
    if vRect.Bottom - vRect.Top + 2 <= FGrid.RowCount then
      Inc(vRect.Right);
    SendMsg(DM_SETITEMPOSITION, IdList, @vRect);
    FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);
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
        Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

      DN_CTLCOLORDLGITEM:
        if Param1 = IdFrame then
          Result := CtrlPalette([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX])
        else
          Result := Param2;
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
    vRec.FLen := Byte(ALen);
    AddData(vRec);
  end;


  function TListFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


 {-----------------------------------------------------------------------------}
 { TDrawBuf                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TDrawBuf.Create; {override;}
  begin
    inherited Create;
    FTabSize := DefTabSize;
  end;


  destructor TDrawBuf.Destroy; {override;}
  begin
    MemFree(FChars);
    MemFree(FAttrs);
    inherited Destroy;
  end;


  procedure TDrawBuf.Clear;
  begin
    FCount := 0;
  end;


  procedure TDrawBuf.Add(AChr :TChar; Attr :Byte; ACount :Integer = 1);
  var
    I :Integer;
  begin
    if FCount + ACount + 1 > FSize then
      SetSize(FCount + ACount + 1);
    for I := 0 to ACount - 1 do begin
      FChars[FCount] := AChr;
      FAttrs[FCount] := Attr;
      Inc(FCount);
    end;
  end;


  procedure TDrawBuf.AddStrExpandTabsEx(AStr :PTChar; ALen :Integer; AColor :Byte);
  var
    vEnd :PTChar;
    vChr :TChar;
    vAtr :Byte;
    vDPos, vDstLen, vSize :Integer;
  begin
    vDstLen := ChrExpandTabsLen(AStr, ALen, FTabSize);
    if FCount + vDstLen + 1 > FSize then
      SetSize(FCount + vDstLen + 1);

    vEnd := AStr + ALen;
    vDPos := 0;
    while AStr < vEnd do begin
      vChr := AStr^;
      vAtr := AColor;

      if vChr <> charTab then begin
        Assert(vDPos < vDstLen);
        Add(vChr, vAtr);
        Inc(vDPos);
      end else
      begin
        vSize := FTabSize - (vDPos mod FTabSize);
        Assert(vDPos + vSize <= vDstLen);
        Add(' ', vAtr, vSize);
        Inc(vDPos, vSize);
      end;
      Inc(AStr);
    end;
    FChars[FCount] := #0;
  end;


  procedure TDrawBuf.FillAttr(APos, ACount :Integer; AColor :Byte);
  begin
    Assert(APos + ACount <= FCount);
    FillChar(FAttrs[APos], ACount, AColor);
  end;


  procedure TDrawBuf.FillLoAttr(APos, ACount :Integer; ALoColor :Byte);
  var
    I :Integer;
  begin
    Assert(APos + ACount <= FCount);
    for I := APos to APos + ACount - 1 do
      FAttrs[I] := (FAttrs[I] and $F0) or (ALoColor and $0F);
  end;


  procedure TDrawBuf.Paint(X, Y, ADelta, ALimit :Integer);
  var
    I, J, vEnd, vPartLen :Integer;
    vAtr :Byte;
    vTmp :TChar;
  begin
    vEnd := FCount;
    if FCount - ADelta > ALimit then
      vEnd := ADelta + ALimit;

    I := ADelta;
    while I < vEnd do begin
      vAtr := FAttrs[I];
      J := I + 1;
      while (J < vEnd) and (FAttrs[J] = vAtr) do
        Inc(J);
      vPartLen := J - I;
      if I + vPartLen = FCount then
        FARAPI.Text(X, Y, vAtr, FChars + I )
      else begin
        vTmp := (FChars + I + vPartLen)^;
        (FChars + I + vPartLen)^ := #0;
        FARAPI.Text(X, Y, vAtr, FChars + I );
        (FChars + I + vPartLen)^ := vTmp;
      end;
      Inc(X, vPartLen);
      Inc(I, vPartLen);
    end;
  end;


  procedure TDrawBuf.SetSize(ASize :Integer);
  begin
    ReallocMem(FChars, ASize * SizeOf(TChar));
    ReallocMem(FAttrs, ASize * SizeOf(Byte));
    FSize := ASize;
  end;


 {-----------------------------------------------------------------------------}
 { TFilteredListDlg                                                            }
 {-----------------------------------------------------------------------------}

  constructor TFilteredListDlg.Create; {override;}
  begin
    inherited Create;
//  FDrawBuf := TDrawBuf.Create;
//  FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
  end;


  destructor TFilteredListDlg.Destroy; {override;}
  begin
    FreeObj(FFilter);
    FreeObj(FDrawBuf);
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


  function TFilteredListDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    Result := True;
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


  procedure  TFilteredListDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); {virtual;}
  begin
    {Abstract}
  end;


  function TFilteredListDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  begin
    Result := '';
  end;


  procedure TFilteredListDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {virtual;}
  begin
    {Abstract}
  end;


  procedure TFilteredListDlg.SelectItem(ACode :Integer);  {virtual;}
  begin
    {Abstract}
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


  function TFilteredListDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocSetFilter(const ANewFilter :TString);
    begin
      if ANewFilter <> FFilterMask then begin
//      TraceF('Mask: %s', [ANewFilter]);
//      FFilterMode := ANewFilter <> '';
        FFilterMask := ANewFilter;
        ReinitAndSaveCurrent;
      end;
    end;

  begin
    Result := 1;
    case Msg of
      DN_KEY: begin
        case Param2 of
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
//        TraceF('Key: %d', [Param2]);
          if (Param2 >= 32) and (Param2 < $FFFF) then
            LocSetFilter(FFilterMask + WideChar(Param2))
          else
            Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


end.


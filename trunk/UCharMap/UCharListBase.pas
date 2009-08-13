{$I Defines.inc}

unit UCharListBase;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    PluginW,
    FarKeysW,
    FarColor,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,

    UCharMapCtrl;


  type
    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FIdx :Integer;
      FPos :Word;
      FLen :Word;
    end;

    TMyFilter = class(TExList)
    public
      procedure Add(AIndex, APos, ALen :Integer);

    private
      function GetItems(AIndex :Integer) :Integer;

    public
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
      procedure ReinitListControl; virtual;
      procedure ReinitAndSaveCurrent; virtual;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); virtual;

    protected
      FGrid           :TFarGrid;

      FFilter         :TMyFilter;
      FFilterMask     :TString;
      FTotalCount     :Integer;
      FMenuMaxWidth   :Integer;

      FFoundColor     :Integer;

      procedure ResizeDialog;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode);
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
    AddData(vRec);
  end;


  function TMyFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


 {-----------------------------------------------------------------------------}
 { TListBase                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TListBase.Create; {override;}
  begin
    inherited Create;
    FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));

    FFoundColor := optFoundColor;
    if FFoundColor = 0 then
      FFoundColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUHIGHLIGHT));
  end;


  destructor TListBase.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FFilter);
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
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
  end;


  procedure TListBase.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitListControl;
  end;


  function TListBase.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TListBase.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vScreenInfo.dwSize.X - 4 then
      vWidth := vScreenInfo.dwSize.X - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 4;
    if vHeight > vScreenInfo.dwSize.Y - 2 then
      vHeight := vScreenInfo.dwSize.Y - 2;
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


  procedure TListBase.ReinitListControl; {virtual;}
  begin
  end;


  procedure TListBase.ReinitAndSaveCurrent; {virtual;}
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


  procedure TListBase.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {virtual;}

    procedure LocDrawPart(var AChr :PTChar; var ARest :Integer; ALen :Integer; AColor :Integer);
    begin
      if ARest > 0 then begin
        if ALen > ARest then
          ALen := ARest;
        SetFarChr(FGrid.RowBuf, AChr, ALen);
        FARAPI.Text(X, Y, AColor, FGrid.RowBuf);
        Dec(ARest, ALen);
        Inc(AChr, ALen);
        Inc(X, ALen);
      end;
    end;

  var
    vRec :PFilterRec;
    vChr :PTChar;
    vStr :TString;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      vStr := GridGetDlgText(ASender, ACol, ARow);
      if FFilterMask = '' then begin
        SetFarStr(FGrid.RowBuf, vStr, AWidth);
        FARAPI.Text(X, Y, AColor, FGrid.RowBuf);
      end else
      begin
        vChr := PTChar(vStr);
        if AWidth > Length(vStr) then
          AWidth := length(vStr);
        LocDrawPart(vChr, AWidth, vRec.FPos, AColor);
        LocDrawPart(vChr, AWidth, vRec.FLen, (AColor and not $0F) or (FFoundColor and $0F) );
        LocDrawPart(vChr, AWidth, AWidth, AColor);
      end;
    end;
  end;


  procedure TListBase.SelectItem(ACode :Integer);  {virtual;}
  begin
    {Abstract}
  end;


  function TListBase.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

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
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_CTLCOLORDIALOG:
        Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

      DN_CTLCOLORDLGLIST:
        if Param1 = IdList then begin
          ChangePalette(PFarListColors(Param2));
          Result := 1;
        end;
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

      DN_LISTCHANGE:
        UpdateHeader;

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectItem(1);
          KEY_CTRLENTER:
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
          if ((Param2 >= 32) and (Param2 <= $7F)) or ((Param2 >= 32) and (Param2 < $FFFF) and IsCharAlpha(TChar(Param2))) then
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


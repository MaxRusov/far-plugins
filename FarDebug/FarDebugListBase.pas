{$I Defines.inc}

unit FarDebugListBase;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Base List Dialog                                                           *}
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
    FarMatch,
    FarDlg,
    FarGrid,

    FarDebugCtrl,
    FarDebugDlgBase;


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


  type
    TFilteredListBase = class(TFarDebugListBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure CreateFilter; virtual;
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;

      procedure SelectItem(ACode :Integer); virtual;
      procedure UpdateHeader; virtual;
      procedure ReinitGrid; virtual;
      procedure ReinitAndSaveCurrent; virtual;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); virtual;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; virtual;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); virtual;

    protected
      FFilter       :TMyFilter;
      FFilterMask   :TString;
      FTotalCount   :Integer;

      FFoundColor   :Integer;

      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode);
      procedure ToggleOption(var AOption :Boolean);
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
 { TListBase                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TFilteredListBase.Create; {override;}
  begin
    inherited Create;
    CreateFilter;

    FFoundColor := optFoundColor;
    if FFoundColor = 0 then
      FFoundColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUHIGHLIGHT));
  end;


  procedure TFilteredListBase.CreateFilter; {virtual;}
  begin
    FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));
  end;


  destructor TFilteredListBase.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FFilter);
    inherited Destroy;
  end;


  procedure TFilteredListBase.Prepare; {override;}
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
    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
  end;


  procedure TFilteredListBase.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
  end;


  function TFilteredListBase.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TFilteredListBase.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  procedure TFilteredListBase.UpdateHeader; {virtual;}
  begin
  end;


  procedure TFilteredListBase.ReinitGrid; {virtual;}
  begin
  end;


  procedure TFilteredListBase.ReinitAndSaveCurrent; {virtual;}
  begin
  end;


  procedure TFilteredListBase.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if (AButton = 1) {and ADouble} then
      SelectItem(1);
  end;


  function TFilteredListBase.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  begin
    Result := '';
  end;


  procedure TFilteredListBase.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {virtual;}

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


  procedure TFilteredListBase.SelectItem(ACode :Integer);  {virtual;}
  begin
    {Abstract}
  end;


  procedure TFilteredListBase.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    ReinitGrid;
    WriteSetup;
  end;


  function TFilteredListBase.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

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
         {$ifdef bUnicodeFar}
          if (Param2 >= 32) and (Param2 < $FFFF) then
         {$else}
          if (Param2 >= 32) and (Param2 <= $FF) then
         {$endif bUnicodeFar}
          begin
           {$ifdef bUnicodeFar}
            LocSetFilter(FFilterMask + WideChar(Param2));
           {$else}
            LocSetFilter(FFilterMask + StrOEMToAnsi(AnsiChar(Param2)));
           {$endif bUnicodeFar}
          end else
            Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


end.


{$I Defines.inc}

unit EdtFindGrep;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{* Grep                                                                       *}
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
    FarMenu,
    FarListDlg,

    EdtFindCtrl,
    EdtFinder,
    EdtFindHints;


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


  type
    TListBase = class(TFarListDlg)
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
      FDrawBuf        :TDrawBuf;
      FFilter         :TMyFilter;
      FFilterMask     :TString;
      FTotalCount     :Integer;
      FFoundColor     :Integer;
    end;


  type
    TGrepDlg = class(TListBase)
    public
      function GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      procedure GridPosChange(ASender :TFarGrid); override;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FMatches  :TExList;
      FNeedSync :Boolean;

      procedure SyncEditor;
      function RowToIdx(ARow :Integer) :Integer;
      function FindSelItem(AItem :PEdtSelection) :Integer;
      function GetSelItem(ARow :Integer) :PEdtSelection;
      function GetEdtStr(AIdx :Integer; var ALen :Integer) :PTChar;
      procedure ToggleOption(var AOption :Boolean);
      procedure SetWindowSize(AMaximized :Boolean);
      procedure OptionsMenu;

    public
      property Grid :TFarGrid read FGrid;
    end;


  function GrepDlg(AMatches :TExList) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    EdtFindMain,
    MixDebug;



  function StrTrimFirst(var AStr :PTChar; var ALen :Integer) :Integer;
  begin
    Result := 0;
    while (ALen > 0) and ((AStr^ = ' ') or (AStr^ = #9)) do begin
      Inc(AStr);
      Dec(ALen);
      Inc(Result);
    end;
  end;


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
 { TListBase                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TListBase.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FDrawBuf := TDrawBuf.Create;
//  FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));
    FFoundColor := GetOptColor(optGrepFoundColor, COL_MENUHIGHLIGHT);
  end;


  destructor TListBase.Destroy; {override;}
  begin
    FreeObj(FFilter);
    FreeObj(FDrawBuf);
    UnregisterHints;
    inherited Destroy;
  end;


  procedure TListBase.Prepare; {override;}
  begin
    inherited Prepare;
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
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


  procedure TListBase.UpdateHeader; {virtual;}
  begin
  end;


  procedure TListBase.ReinitGrid; {virtual;}
  begin
  end;


  procedure TListBase.ReinitAndSaveCurrent; {virtual;}
  begin
  end;


  procedure TListBase.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean); {virtual;}
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if AButton = 1 then
      SelectItem(IntIf(ADouble, 2, 1));
  end;


  procedure TListBase.GridPosChange(ASender :TFarGrid); {virtual;}
  begin
    {Abstract}
  end;


  procedure  TListBase.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); {virtual;}
  begin
    {Abstract}
  end;


  function TListBase.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {virtual;}
  begin
    Result := '';
  end;


  procedure TListBase.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {virtual;}
  begin
    {Abstract}
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


 {-----------------------------------------------------------------------------}
 { TGrepDlg                                                                    }
 {-----------------------------------------------------------------------------}

  procedure TGrepDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := 'Grep';
    SetWindowSize(optGrepMaximized);
  end;


  procedure TGrepDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
    FNeedSync := True;
  end;


  procedure TGrepDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strSearchResult);

    if FFilter = nil then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);

    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;
  end;


  procedure TGrepDlg.ReinitGrid; {override;}
  var
    I, vPos, vStrLen, vFndLen, vCount, vMaxRow, vMaxRowLen, vMaxLen :Integer;
    vStr :PTChar;
    vMask :TString;
    vHasMask :Boolean;
  begin
    vMaxLen := 0;
    FTotalCount := FMatches.Count;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    vCount := 0;
    FreeObj(FFilter);
    if vMask <> '' then
      FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));

    for I := 0 to FMatches.Count - 1 do begin
      vStr := GetEdtStr(I, vStrLen);

      vPos := 0; vFndLen := 0;
      if vMask <> '' then begin
        if not ChrCheckMask(vMask, vStr, vStrLen, vHasMask, vPos, vFndLen) then
          Continue;
        FFilter.Add(I, vPos, vFndLen);
      end;

      if optGrepTrimSpaces then
        StrTrimFirst(vStr, vStrLen);
      vStrLen := ChrExpandTabsLen(vStr, vStrLen);
      vMaxLen := IntMax(vMaxLen, vStrLen);
      Inc(vCount);
    end;

    FMenuMaxWidth := vMaxLen + 4;

    vMaxRowLen := 0;
    if optGrepShowLines then begin
      vMaxRow := 0;
      if vCount > 0 then
        vMaxRow := GetSelItem(vCount - 1).FRow + 1;
      vMaxRowLen := Length(Int2Str(vMaxRow));
      Inc(FMenuMaxWidth, vMaxRowLen + 1);
    end;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;
    if optGrepShowLines then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxRowLen+2, taRightJustify, [coColMargin{coNoVertLine}], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 2) );

    FGrid.RowCount := vCount;

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TGrepDlg.ReinitAndSaveCurrent; {override;}
  var
    vSel :PEdtSelection;
  begin
    vSel := GetSelItem(FGrid.CurRow);
    ReinitGrid;
    if vSel <> nil then
      SetCurrent(FindSelItem(vSel), lmCenter);
    FNeedSync := True;
  end;


  procedure TGrepDlg.SyncEditor;
  var
    vSel :PEdtSelection;
  begin
    vSel := GetSelItem(FGrid.CurRow);
    if vSel <> nil then begin
      with vSel^ do
        GotoFoundPos( FRow, FCol, FLen, True, GetDlgRect.Top );
      FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);
      ResizeDialog;
    end;
  end;


  procedure TGrepDlg.SelectItem(ACode :Integer); {override;}
  begin
    SyncEditor;
    if ACode = 2 then
      SendMsg(DM_CLOSE, -1, 0);
  end;


  procedure TGrepDlg.GridPosChange(ASender :TFarGrid); {override;}
  begin
//  if optGrepAutoSync then
//    SyncEditor;
    FNeedSync := True;
  end;


  procedure TGrepDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer); {override;}
  begin
    if ACol >= 0 then
      case FGrid.Column[ACol].Tag of
        1: AColor := (AColor and $F0) or (optGrepNumColor and $0F)
      end;
  end;


  function TGrepDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vSel :PEdtSelection;
  begin
    Result := '';
    vSel := GetSelItem(ARow);
    if vSel <> nil then begin
      case FGrid.Column[ACol].Tag of
        1: Result := Int2Str(vSel.FRow + 1);
        2: {};
      end;
    end;
  end;


  procedure TGrepDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer); {override;}
  var
    vIdx, vLen, vSkip, vPos, vPos2 :Integer;
    vStr :PTChar;
    vSel :PEdtSelection;
    vRec :PFilterRec;
  begin
    vIdx := RowToIdx(ARow);
    vStr := GetEdtStr(vIdx, vLen);
    if vStr <> nil then begin
      FDrawBuf.Clear;

      vSkip := 0;
      if optGrepTrimSpaces then
        vSkip := StrTrimFirst(vStr, vLen);

      FDrawBuf.AddStrExpandTabsEx(vStr, vLen, AColor);

      if oprGrepShowMatch then begin
        vSel := FMatches.PItems[vIdx];
        vPos := ChrExpandTabsLen(vStr, IntMin(vSel.FCol - vSkip, vLen));
        vPos2 := ChrExpandTabsLen(vStr, IntMin(vSel.FCol + vSel.FLen - vSkip, vLen));
        FDrawBuf.FillAttr(vPos, vPos2 - vPos, optMatchColor);
      end;

      if FFilter <> nil then begin
        vRec := PFilterRec(FFilter.PItems[ARow]);
        vPos := ChrExpandTabsLen(vStr, IntMin(vRec.FPos - vSkip, vLen));
        vPos2 := ChrExpandTabsLen(vStr, IntMin(vRec.FPos + vRec.FLen - vSkip, vLen));
        FDrawBuf.FillLoAttr(vPos, vPos2 - vPos, optGrepFoundColor);
      end;

      FDrawBuf.Paint(X, Y, 0, AWidth);
    end;
  end;



  function TGrepDlg.GetSelItem(ARow :Integer) :PEdtSelection;
  var
    vIdx :Integer;
  begin
    Result := nil;
    vIdx := RowToIdx(ARow);
    if (vIdx >= 0) and (vIdx < FMatches.Count) then
      Result := FMatches.PItems[vIdx];
  end;


  function TGrepDlg.FindSelItem(AItem :PEdtSelection) :Integer;
  var
    I :Integer;
  begin
    for I := 0 to FGrid.RowCount - 1 do
      if FMatches.PItems[RowToIdx(I)] = AItem then begin
        Result := I;
        Exit;
      end;
    Result := -1;
  end;


  function TGrepDlg.RowToIdx(ARow :Integer) :Integer;
  begin
    if FFilter = nil then
      Result := ARow
    else begin
      Result := -1;
      if ARow < FFilter.Count then
        Result := FFilter[ARow];
    end;
  end;


  function TGrepDlg.GetEdtStr(AIdx :Integer; var ALen :Integer) :PTChar;
  var
    vSel :PEdtSelection;
    vStrInfo :TEditorGetString;
  begin
    Result := nil;
    if (AIdx >= 0) and (AIdx < FMatches.Count) then begin
      vSel := FMatches.PItems[AIdx];
      vStrInfo.StringNumber := vSel.FRow;
      if FARAPI.EditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
        ALen := vStrInfo.StringLength;
        Result := vStrInfo.StringText;
      end;
    end;
  end;


  function TGrepDlg.GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;
  var
    vIdx, vLen :Integer;
    vStr :PTChar;
    vSel :PEdtSelection;
  begin
    vIdx := RowToIdx(ARow);
    vStr := GetEdtStr(vIdx, vLen);
    if vLen > 0 then begin
      vSel := FMatches.PItems[vIdx];
      AEdtRow := vSel.FRow;
      StrTrimFirst(vStr, vLen);
      Result := StrExpandTabs(vStr);
    end;
  end;


  procedure TGrepDlg.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TGrepDlg.SetWindowSize(AMaximized :Boolean);
  begin
    if AMaximized then begin
      FMaxHeightPerc := 0;
      FBottomAlign := False;
    end else
    begin
      FMaxHeightPerc := 50;
      FBottomAlign := True;
    end;
  end;


  procedure TGrepDlg.OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptions),
    [
      GetMsg(strMShowNumbers),
      GetMsg(strMShowMatches),
      GetMsg(strMTrimSpaces),
      GetMsg(strMAutoSync),
      GetMsg(strMShowHints),
      '',
      GetMsg(strMColors)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optGrepShowLines;
        vMenu.Checked[1] := oprGrepShowMatch;
        vMenu.Checked[2] := optGrepTrimSpaces;
        vMenu.Checked[3] := optGrepAutoSync;
        vMenu.Checked[4] := optGrepShowHints;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ToggleOption(optGrepShowLines);
          1: ToggleOption(oprGrepShowMatch);
          2: ToggleOption(optGrepTrimSpaces);
          3: ToggleOption(optGrepAutoSync);
          4: ToggleOption(optGrepShowHints);
          5: {};
          6: ColorMenu
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  function TGrepDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

     procedure LocChangeSize;
     begin
       optGrepMaximized := not optGrepMaximized;
       SetWindowSize(optGrepMaximized);
       ResizeDialog;
       SetCurrent(FGrid.CurRow);
     end;

  begin
    Result := 1;
    case Msg of
      DN_ENTERIDLE:
        if FNeedSync then begin
          if optGrepAutoSync then
            SyncEditor;
          FNeedSync := False;
        end;

      DN_KEY: begin
        case Param2 of
          KEY_SHIFTSPACE:
            SyncEditor;

          KEY_SPACE:
            if FFilterMask = '' then
              SyncEditor
            else
              Result := inherited DialogHandler(Msg, Param1, Param2);

          KEY_CTRL1:
            ToggleOption(optGrepShowLines);
          KEY_CTRL2:
            ToggleOption(oprGrepShowMatch);
          KEY_CTRL3:
            ToggleOption(optGrepTrimSpaces);
          KEY_CTRL4:
            ToggleOption(optGrepAutoSync);
          KEY_CTRLM:
            LocChangeSize;

          KEY_F9:
            OptionsMenu;
        else
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


  function GrepDlg(AMatches :TExList) :Boolean;
  var
    vDlg :TGrepDlg;
  begin
    Result := False;
    vDlg := TGrepDlg.Create;
    try
      vDlg.FMatches := AMatches;
      if vDlg.Run = -1 then
        Exit;
      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


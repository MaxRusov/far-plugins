{$I Defines.inc}

unit UCharMapDlg;

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
    MixWinUtils,

    PluginW,
    FarKeysW,
    FarColor,

    FarCtrl,
    FarDlg,
    FarGrid,

   {$ifdef bUseHint}
    UCharMapHints,
   {$endif bUseHint}
   
    UCharMapCtrl,
    UCharMapFontsDlg,
    UCharMapGroupsDlg;


  var
    vDlgLock  :Integer;
    vLastChar :TChar;


  const
    cDlgWidth  = 44;
    cDlgHeight = 26;

    IdFrame   = 0;
    IdIcon    = 1;
    IdFont    = 2;
    IdFrame1  = 3;
    IdMap     = 4;
    IdFrame2  = 5;
    IdEdit    = 6;
    IdStatus  = 7;
    IdChrName = 8;

    cMaximizedIcon = '['#$12']';
    cNormalIcon = '['#$18']';

  type
    TCharMapDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetCharAt(ACol, ARow :Integer) :TChar;
      function CharMapped(AChar :TChar) :Boolean;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;

    private
      FGrid        :TFarGrid;
      FRange       :TBits;
      FFilter      :TIntList;
      FHiddenColor :Integer;
      FRes         :TString;

      procedure ResizeDialog(ANeedLock :Boolean);
      procedure ReinitFilter;
      procedure ReinitAndSaveCurrent;

      function RowToCode(ARow :Integer) :Integer;
      function CodeToRow(ACode :Integer) :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
      procedure GridPosChange(ASender :TFarGrid);
      function GetCurChar :TChar;

      procedure AppendCurrent;
      procedure CopyToClipboard;
      procedure GotoChar(AChar :TChar);
      procedure SelectFont;
      procedure SelectGroup;
      procedure SelectChar;
      procedure Maximize;

    public
      property Grid :TFarGrid read FGrid;
    end;


  procedure OpenDlg;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TCharMapDlg                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TCharMapDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);

    FHiddenColor := optHiddenColor;
    if FHiddenColor = 0 then
      FHiddenColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_DIALOGDISABLED));
  end;


  destructor TCharMapDlg.Destroy; {override;}
  begin
    UnRegisterHints;
    FreeObj(FGrid);
    FreeObj(FFilter);
    FreeObj(FRange);
    inherited Destroy;
  end;


  procedure TCharMapDlg.Prepare; {override;}
  const
    DX = cDlgWidth;
    DY = cDlgHeight;
  var
    I :Integer;
  begin
    FHelpTopic := 'UCharMap';
    FWidth := cDlgWidth;
    FHeight := cDlgHeight;
    FItemCount := 9;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, GetMsg(strTitle)),
        NewItemApi(DI_Text,        DX-7, 1, 3, 1, 0, cNormalIcon),
        NewItemApi(DI_Text,        3, 2, DX - 6, 1, 0, ''),
        NewItemApi(DI_SingleBox,   3, 3, DX - 6, 1, 0, ''),
        NewItemApi(DI_UserControl, 3, 4, DX - 5, 16, 0, ''),
        NewItemApi(DI_SingleBox,   3, 20, DX - 6, 1, 0, ''),
        NewItemApi(DI_Edit,        3, 21, DX - 6, 1, 0, ''),
        NewItemApi(DI_Text,        3, 22, DX - 6, 1, 0, ''),
        NewItemApi(DI_Text,        3, 23, DX - 6, 1, 0, '')
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdMap);
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.OnPosChange := GridPosChange;
    FGrid.Options := [{goRowSelect} {goFollowMouse} {,goWheelMovePos}];
    FGrid.NormColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_DIALOGTEXT));
    FGrid.SelColor := optCurrColor;
    if FGrid.SelColor = 0 then
      FGrid.SelColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_DIALOGLISTSELECTEDTEXT));

    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 4, taRightJustify, [], 0) );
    for I := 0 to 15 do
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 2, taLeftJustify, [{coColMargin,} coNoVertLine, coOwnerDraw], 0) );

    FGrid.FixedCol := 1;
    FGrid.RowCount := $1000;
    FGrid.UpdateSize(3, 2, DX - 5, 16);
  end;


  procedure TCharMapDlg.InitDialog; {override;}
  begin
    FRange := GetFontRange(FontName);
    ReinitFilter;
    ResizeDialog(False);
    GotoChar(vLastChar);
    SetText(IdFont, FontName);
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
  end;


  procedure TCharMapDlg.ResizeDialog(ANeedLock :Boolean);
  var
    vHeight :Integer;
    vRect :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    if ANeedLock then
      SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

      vHeight := cDlgHeight;
      if optMaximized then begin
        vHeight := FGrid.RowCount + 10;
        if vHeight > vScreenInfo.dwSize.Y - 4 then
          vHeight := vScreenInfo.dwSize.Y - 4;
        vHeight := IntMax(vHeight, cDlgHeight);
      end;

      SetDlgPos(-1, -1, cDlgWidth, vHeight);

      vRect.Left := 2;
      vRect.Top := 1;
      vRect.Right := cDlgWidth - 3;
      vRect.Bottom := vHeight - 2;
      SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);

      Inc(vRect.Left); Dec(vRect.Right);
      vRect.Top := vRect.Bottom - 1;
      vRect.Bottom := vRect.Top;
      SendMsg(DM_SETITEMPOSITION, IdChrName, @vRect);
      Dec(vRect.Top); Dec(vRect.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdStatus, @vRect);
      Dec(vRect.Top); Dec(vRect.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdEdit, @vRect);
      Dec(vRect.Top); Dec(vRect.Bottom);
      SendMsg(DM_SETITEMPOSITION, IdFrame2, @vRect);

      vRect.Top := 4; Dec(vRect.Bottom); Inc(vRect.Right);
      SendMsg(DM_SETITEMPOSITION, IdMap, @vRect);
      FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);

      if optMaximized then
        SetTextApi(IdIcon, cMaximizedIcon)
      else
        SetTextApi(IdIcon, cNormalIcon);

    finally
      if ANeedLock then
        SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TCharMapDlg.ReinitFilter;
  var
    I :Integer;
    vPtr :Pointer;
  begin
    if not optShowHidden then begin
      if FFilter = nil then
        FFilter := TIntList.Create;
      FFilter.Clear;

      vPtr := FRange.BitsPtr;
      for I := 0 to $FFF do begin
        if Word(vPtr^) <> 0 then
          FFilter.Add(I);
        Inc(Integer(vPtr), 2);
      end;

    end else
      FreeObj(FFilter);

    FGrid.ResetSize;
    if FFilter <> nil then
      FGrid.RowCount := FFilter.Count
    else
      FGrid.RowCount := $1000;
  end;


  procedure TCharMapDlg.ReinitAndSaveCurrent;
  var
    vChar :TChar;
  begin
    vChar := GetCurChar;
    ReinitFilter;
    ResizeDialog(True);
    GotoChar(vChar);
  end;


  function TCharMapDlg.RowToCode(ARow :Integer) :Integer;
  begin
    if FFilter = nil then
      Result := ARow * 16
    else begin
      Result := -1;
      if (ARow < FFilter.Count) then
        Result := FFilter[ARow] * 16;
    end;
  end;


  function TCharMapDlg.CodeToRow(ACode :Integer) :Integer;
  begin
    if FFilter = nil then
      Result := ACode div 16
    else begin
      ACode := ACode div 16;
      Result := 0;
      while (Result < FFilter.Count) and (FFilter[Result] < ACode) do
        Inc(Result);
    end;
  end;


  function TCharMapDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    vLastChar := GetCurChar;
    Result := True;
  end;


  procedure TCharMapDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
    if AButton = 2 then
      AppendCurrent
    else
    if ADouble then
      SelectChar;
  end;


  function TCharMapDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ACol = 0 then
      Result := Format('%.4x', [RowToCode(ARow)])
    else
      Result := '';
  end;


  procedure TCharMapDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  begin
    if (ARow = FGrid.CurRow) and (ACol = FGrid.CurCol + 1) and (ACol > 1) then
      AColor := FGrid.SelColor;
  end;


  procedure TCharMapDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  var
    vBuf :array[0..3] of TChar;
    vCode, vColor :Integer;
  begin
    vCode := RowToCode(ARow);
    if vCode <> -1 then begin
      vCode := vCode + ACol - 1;
      FillFarChar(vBuf, 3, ' ');
      vBuf[1] := TChar(vCode);
      vBuf[3] := #0;
      if (ARow = FGrid.CurRow) and (ACol = FGrid.CurCol) then
        FARAPI.Text(X, Y, FGrid.SelColor, @vBuf[0])
      else begin
        vColor := FGrid.NormColor;
        if (FRange <> nil) and not FRange[vCode] then
          vColor := FHiddenColor;
        FARAPI.Text(X + 1, Y, vColor, @vBuf[1])
      end;
    end;
  end;


  procedure TCharMapDlg.GridPosChange(ASender :TFarGrid);
  var
    vChr :TChar;
    vStr :TString;
  begin
    vChr := GetCurChar;
    vStr := vChr;
    if vChr = #0 then
      vStr := ' ';
    vStr := Format('Char: %s  Hex: %.4x  Dec: %d', [vStr, Word(vChr), Word(vChr)]);
    SetText(IdStatus, vStr);

    vStr := NameOfChar(Word(vChr));
    if vStr = '' then begin
      vStr := NameOfRange(Word(vChr));
      if vStr <> '' then
        vStr := '<' + vStr + '>';
    end;
    SetText(IdChrName, vStr);
  end;


  function TCharMapDlg.CharMapped(AChar :TChar) :Boolean;
  begin
    Result := True;
    if FRange <> nil then
      Result := FRange[Word(AChar)];
  end;


  function TCharMapDlg.GetCharAt(ACol, ARow :Integer) :TChar;
  var
    vCode :Integer;
  begin
    Result := #0;
    vCode := RowToCode(ARow);
    if vCode <> -1 then
      Result := TChar(vCode + ACol - 1);
  end;


  function TCharMapDlg.GetCurChar :TChar;
  begin
    Result := GetCharAt(FGrid.CurCol, FGrid.CurRow);
  end;


  procedure TCharMapDlg.GotoChar(AChar :TChar);
  var
    vRow, vCol, vCod, vCod0 :Integer;
  begin
    vCod := Word(AChar);
    vRow := CodeToRow(vCod);
    vCol := 0;
    vCod0 := RowToCode(vRow);
    if (vCod >= vCod0) and (vCod <= vCod0 + 15) then
      vCol := (vCod mod 16) + 1;
    FGrid.GotoLocation(vCol, vRow, lmSafe);
  end;


  procedure TCharMapDlg.AppendCurrent;
  var
    vCh :TChar;
  begin
    vCh := GetCurChar;
    if vCh <> #0 then
      SetText(IdEdit, GetText(IdEdit) + vCh);
  end;



  procedure TCharMapDlg.CopyToClipboard;
  var
    vStr :TString;
  begin
    vStr := GetText(IdEdit);
    if vStr = '' then
      vStr := GetCurChar;
    FARSTD.CopyToClipboard(PTChar(vStr));
  end;



  procedure TCharMapDlg.SelectFont;
  var
    vName :TString;
  begin
    vName := FontName;
    InitFontList;
    if OpenFontsDlg(vName) then begin
      FontName := vName;
      SetText(IdFont, FontName);
      FreeObj(FRange);
      FRange := GetFontRange(FontName);
      ReinitAndSaveCurrent;
      WriteSetup;
    end;
  end;


  procedure TCharMapDlg.SelectGroup;
  var
    vChr :TChar;
  begin
    if GroupNames <> nil then begin
      vChr := GetCurChar;
      if OpenGroupsDlg(vChr) then
        GotoChar(vChr);
    end else
      Beep;
  end;


  procedure TCharMapDlg.Maximize;
  begin
    optMaximized := not optMaximized;
    ResizeDialog(True);
    FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
    WriteSetup;
  end;


  procedure TCharMapDlg.SelectChar;
  begin
    FRes := GetText(IdEdit);
    if FRes = '' then
      FRes := GetCurChar;
    SendMsg(DM_CLOSE, -1, 0);
  end;


  function TCharMapDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

    procedure LocGotoNext;
    begin
      if FGrid.CurCol < FGrid.Columns.Count - 1 then
        FGrid.GotoLocation(FGrid.CurCol + 1, FGrid.CurRow, lmScroll)
      else
      if FGrid.CurRow < FGrid.RowCount - 1 then
        FGrid.GotoLocation(0, FGrid.CurRow + 1, lmScroll);
    end;

    procedure LocGotoPrev;
    begin
      if FGrid.CurCol > 1 then
        FGrid.GotoLocation(FGrid.CurCol - 1, FGrid.CurRow, lmScroll)
      else
      if FGrid.CurRow > 0 then
        FGrid.GotoLocation(FGrid.Columns.Count - 1, FGrid.CurRow - 1, lmScroll);
    end;

    procedure LocBackLast;
    var
      vStr :TString;
    begin
      vStr := GetText(IdEdit);
      if vStr <> '' then begin
        Delete(vStr, Length(vStr), 1);
        SetText(IdEdit, vStr);
      end;
    end;

    procedure LocGotoFromClipboard;
    var
      vStr :TString;
    begin
      vStr := FARSTD.PasteFromClipboard;
      if vStr <> '' then
        GotoChar(vStr[1]);
    end;

  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        begin
          ResizeDialog(False);
          FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
        end;

      DN_MOUSECLICK:
        if Param1 = IdFont then
          SelectFont
        else
        if Param1 = IdChrName then
          SelectGroup
        else
        if Param1 = IdIcon then
          Maximize
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectChar;

        else
          if SendMsg(DM_GETFOCUS, 0, 0) = IdMap then begin
            case Param2 of
              KEY_CTRLPGUP, KEY_CTRLHOME:
                FGrid.GotoLocation(0, 0, lmScroll);
              KEY_CTRLPGDN, KEY_CTRLEND:
                FGrid.GotoLocation(0, MaxInt, lmScroll);
              KEY_RIGHT:
                LocGotoNext;
              KEY_LEFT:
                LocGotoPrev;

              KEY_HOME:
                FGrid.GotoLocation(0, FGrid.CurRow, lmScroll);
              KEY_END:
                FGrid.GotoLocation(MaxInt, FGrid.CurRow, lmScroll);

              KEY_INS:
                begin
                  AppendCurrent;
                  LocGotoNext;
                end;
              KEY_BS:
                LocBackLast;
              KEY_DEL:
                SetText(IdEdit, '');

              KEY_SHIFTINS, KEY_CTRLV:
                LocGotoFromClipboard;
              KEY_CTRLINS, KEY_CTRLC:
                CopyToClipboard;

              KEY_CTRLH:
                begin
                  optShowHidden := not optSHowHidden;
                  ReinitAndSaveCurrent;
                  WriteSetup;
                end;

              KEY_CTRLF:
                SelectFont;
              KEY_CTRLG:
                SelectGroup;
              KEY_CTRLM:
                Maximize;

              else
                if (Param2 >= 32) and (Param2 <= $FFFF) then
                  GotoChar(TChar(Param2))
                else
                  Result := inherited DialogHandler(Msg, Param1, Param2);
            end;
          end else
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

  procedure InsertText(const AStr :TString);
  var
    vStr :TFarStr;
    vMacro :TActlKeyMacro;
  begin
    vStr := '$text "' + AStr + '"';
    vMacro.Command := MCMD_POSTMACROSTRING;
    vMacro.Param.PlainText.SequenceText := PFarChar(vStr);
    vMacro.Param.PlainText.Flags := KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;
    FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
  end;


  procedure OpenDlg;
  var
    vDlg :TCharMapDlg;
  begin
    if vDlgLock > 0 then
      Exit;

    InitCharGroups;
    InitCharNames;
    ReadSetup;

    Inc(vDlgLock);
    vDlg := TCharMapDlg.Create;
    try
      if vDlg.Run = -1 then
        Exit;

      if vDlg.FRes <> '' then
        InsertText(vDlg.FRes);

    finally
      FreeObj(vDlg);
      Dec(vDlgLock);
    end;
  end;


end.


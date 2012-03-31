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

    Far_API,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,
    FarMenu,
    FarDraw,
    FarListDlg,

    EdtFindCtrl,
    EdtFinder,
    EdtFindHints;


  type
    TGrepDlg = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      procedure GridPosChange(ASender :TFarGrid); override;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FDrawBuf    :TDrawBuf;
      FMatches    :TExList;
      FNeedSync   :Boolean;

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
    EdtFindEditor,
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
 { TGrepDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TGrepDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FDrawBuf := TDrawBuf.Create;
  end;


  destructor TGrepDlg.Destroy; {override;}
  begin
    FreeObj(FDrawBuf);
    UnregisterHints;
    inherited Destroy;
  end;


  procedure TGrepDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FGUID := cGrepDlgID;
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
    vMask, vXMask :TString;
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
    if vMask <> '' then begin
      FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
      if optXLatMask then
        vXMask := FarXLatStr(vMask);
    end;

    for I := 0 to FMatches.Count - 1 do begin
      vStr := GetEdtStr(I, vStrLen);

      vPos := 0; vFndLen := 0;
      if vMask <> '' then begin
        if not ChrCheckXMask(vMask, vXMask, vStr, vHasMask, vPos, vFndLen) then
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
      FarAdvControl(ACTL_REDRAWALL, nil);
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


  procedure TGrepDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
  begin
    if ACol >= 0 then
      case FGrid.Column[ACol].Tag of
        1: AColor := ChangeFG(AColor, optGrepNumColor);
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


  procedure TGrepDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vIdx, vLen, vSkip, vPos, vPos2 :Integer;
    vStr :PTChar;
    vSel :PEdtSelection;
    vRec :PFilterRec;
    vFoundColor :TFarColor;
  begin
    vIdx := RowToIdx(ARow);
    vStr := GetEdtStr(vIdx, vLen);
    if vStr <> nil then begin
      FDrawBuf.Clear;

      vFoundColor := ChangeFG(AColor, GetOptColor(optGrepFoundColor, COL_MENUHIGHLIGHT));
      FDrawBuf.SetPalette([AColor, optMatchColor, vFoundColor]);

      vSkip := 0;
      if optGrepTrimSpaces then
        vSkip := StrTrimFirst(vStr, vLen);

      FDrawBuf.AddStrExpandTabsEx(vStr, vLen, 0);

      if oprGrepShowMatch then begin
        vSel := FMatches.PItems[vIdx];
        vPos := ChrExpandTabsLen(vStr, IntMin(vSel.FCol - vSkip, vLen));
        vPos2 := ChrExpandTabsLen(vStr, IntMin(vSel.FCol + vSel.FLen - vSkip, vLen));
        FDrawBuf.FillAttr(vPos, vPos2 - vPos, 1);
      end;

      if FFilter <> nil then begin
        vRec := PFilterRec(FFilter.PItems[ARow]);
        vPos := ChrExpandTabsLen(vStr, IntMin(vRec.FPos - vSkip, vLen));
        vPos2 := ChrExpandTabsLen(vStr, IntMin(vRec.FPos + vRec.FLen - vSkip, vLen));
        FDrawBuf.FillAttr(vPos, vPos2 - vPos, 2);
//      FDrawBuf.FillLoAttr(vPos, vPos2 - vPos, 2);
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
      if FarEditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
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


  function TGrepDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

     procedure LocChangeSize;
     begin
       optGrepMaximized := not optGrepMaximized;
       SetWindowSize(optGrepMaximized);
       ResizeDialog;
       SetCurrent(FGrid.CurRow);
     end;

  begin
    Result := True;
    case AKey of
      KEY_SHIFTSPACE:
        SyncEditor;

      KEY_SPACE:
        if FFilterMask = '' then
          SyncEditor
        else
          Result := inherited KeyDown(AID, AKey);

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
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TGrepDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_ENTERIDLE:
        if FNeedSync then begin
          if optGrepAutoSync then
            SyncEditor;
          FNeedSync := False;
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


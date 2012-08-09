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
(*  TValidStates = set of (vsRowCache, vsFilter, vsSort); *) 

    TGrepDlg = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetStringForHint(ARow :Integer; var AEdtRow :Integer) :TString;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; override;

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
      FRowsCache  :TExList;
(*    FLensCache  :TIntList;
      FValid      :TValidStates; *)

      procedure SyncEditor;
      function RowToIdx(ARow :Integer) :Integer;
      function FindSelItem(AItem :PEdtSelection) :Integer;
      function GetSelItem(ARow :Integer) :PEdtSelection;
      function GetEdtStr(AIdx :Integer; var ALen :Integer) :PTChar;
      procedure ToggleOption(var AOption :Boolean);
      procedure SetWindowSize(AMaximized :Boolean);
      procedure OptionsMenu;
      procedure SetOrder(AOrder :Integer);
      procedure SortByDlg;

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

(*
type
  TFloatValue = (fvExtended, fvCurrency);

//var
//  DecimalSeparator: Char;

const
// 8087 status word masks
  mIE = $0001;
  mDE = $0002;
  mZE = $0004;
  mOE = $0008;
  mUE = $0010;
  mPE = $0020;
  mC0 = $0100;
  mC1 = $0200;
  mC2 = $0400;
  mC3 = $4000;

const
  // 1E18 as a 64-bit integer
  Const1E18Lo = $0A7640000;
  Const1E18Hi = $00DE0B6B3;
  FCon1E18: Extended = 1E18;
  DCon10: Integer = 10;


function TextToFloat(Buffer: PChar; var Value; ValueType: TFloatValue): Boolean;
const
// 8087 control word
// Infinity control  = 1 Affine
// Rounding Control  = 0 Round to nearest or even
// Precision Control = 3 64 bits
// All interrupts masked
  CWNear: Word = $133F;
var
  Temp: Integer;
  CtrlWord: Word;
  DecimalSep: Char;
  SaveGOT: Integer;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX

        MOV     SaveGOT,0
        MOV     AL,'.' // DecimalSeparator
        MOV     DecimalSep,AL
        MOV     EBX,ECX

        FSTCW   CtrlWord
        FCLEX
        FLDCW   CWNear

        FLDZ
        CALL    @@SkipBlanks
        MOV     BH, byte ptr [ESI]
        CMP     BH,'+'
        JE      @@1
        CMP     BH,'-'
        JNE     @@2
@@1:    INC     ESI
@@2:    MOV     ECX,ESI
        CALL    @@GetDigitStr
        XOR     EDX,EDX
        MOV     AL,[ESI]
        CMP     AL,DecimalSep
        JNE     @@3
        INC     ESI
        CALL    @@GetDigitStr
        NEG     EDX
@@3:    CMP     ECX,ESI
        JE      @@9
        MOV     AL, byte ptr [ESI]
        AND     AL,0DFH
        CMP     AL,'E'
        JNE     @@4
        INC     ESI
        PUSH    EDX
        CALL    @@GetExponent
        POP     EAX
        ADD     EDX,EAX
@@4:    CALL    @@SkipBlanks
        CMP     BYTE PTR [ESI],0
        JNE     @@9
        MOV     EAX,EDX
        CMP     BL,fvCurrency
        JNE     @@5
        ADD     EAX,4
@@5:    PUSH    EBX
        MOV     EBX,SaveGOT
        CALL    FPower10
        POP     EBX
        CMP     BH,'-'
        JNE     @@6
        FCHS
@@6:    CMP     BL,fvExtended
        JE      @@7
        FISTP   QWORD PTR [EDI]
        JMP     @@8
@@7:    FSTP    TBYTE PTR [EDI]
@@8:    FSTSW   AX
        TEST    AX,mIE+mOE
        JNE     @@10
        MOV     AL,1
        JMP     @@11
@@9:    FSTP    ST(0)
@@10:   XOR     EAX,EAX
@@11:   FCLEX
        FLDCW   CtrlWord
        FWAIT
        JMP     @@Exit

@@SkipBlanks:

@@21:   LODSB
        OR      AL,AL
        JE      @@22
        CMP     AL,' '
        JE      @@21
@@22:   DEC     ESI
        RET

// Process string of digits
// Out EDX = Digit count

@@GetDigitStr:

        XOR     EAX,EAX
        XOR     EDX,EDX
@@31:   LODSB
        SUB     AL,'0'+10
        ADD     AL,10
        JNC     @@32

        FIMUL   DCon10
        MOV     Temp,EAX
        FIADD   Temp
        INC     EDX
        JMP     @@31
@@32:   DEC     ESI
        RET

// Get exponent
// Out EDX = Exponent (-4999..4999)

@@GetExponent:

        XOR     EAX,EAX
        XOR     EDX,EDX
        MOV     CL, byte ptr [ESI]
        CMP     CL,'+'
        JE      @@41
        CMP     CL,'-'
        JNE     @@42
@@41:   INC     ESI
@@42:   MOV     AL, byte ptr [ESI]
        SUB     AL,'0'+10
        ADD     AL,10
        JNC     @@43
        INC     ESI
        IMUL    EDX,10
        ADD     EDX,EAX
        CMP     EDX,500
        JB      @@42
@@43:   CMP     CL,'-'
        JNE     @@44
        NEG     EDX
@@44:   RET

@@Exit:
        POP     EBX
        POP     ESI
        POP     EDI
end;

  function Str2Float(AStr :PTChar; ALen :Integer) :TFloat;
  const
    cMaxLen = 64;
  var
    vLen :Integer;
    vStr :array[0..cMaxLen] of AnsiChar;
  begin
    vLen := 0;
    while (vLen < cMaxLen) and (ALen > 0) do begin
      if (AStr^ < #$FF) and (AnsiChar(AStr^) in ['0'..'9', '.', '-']) then begin
        vStr[vLen] := AnsiChar(AStr^);
        Inc(vLen);
      end;
      Inc(AStr);
      Dec(ALen);
    end;
    vStr[vLen] := #0;

    if not TextToFloat(vStr, Result, fvExtended) then
      Result := -1e99;
  end;
*)


  function Str2Float(AStr :PTChar; ALen :Integer) :TFloat;
  const
    cMaxLen = 64;
  var
    vLen :Integer;
    vStr :array[0..cMaxLen] of TChar;
  begin
    vLen := 0;
    while (vLen < cMaxLen) and (ALen > 0) do begin
      if (AStr^ < #$FF) and (AnsiChar(AStr^) in ['0'..'9', '.', '-']) then begin
        vStr[vLen] := AStr^;
        Inc(vLen);
      end;
      Inc(AStr);
      Dec(ALen);
    end;
    vStr[vLen] := #0;
    if not TryPCharToFloat(vStr, Result) then
      Result := -1e99;
  end;


 {-----------------------------------------------------------------------------}

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
    FRowsCache := TExList.Create;
(*  FLensCache := TIntList.Create; *)
  end;


  destructor TGrepDlg.Destroy; {override;}
  begin
(*  FreeObj(FLensCache);  *)
    FreeObj(FRowsCache);
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
    if (vMask <> '') or ((optGrepSortMode <> 0) and (optGrepSortMode <> 1)) then begin
      FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
      FFilter.Owner := Self;
      if optXLatMask then
        vXMask := FarXLatStr(vMask);
    end;

   {$ifdef bTrace}
    TraceBeg('Filter...');
   {$endif bTrace}

    FRowsCache.Clear;
    FRowsCache.Capacity := FMatches.Count;
    for I := 0 to FMatches.Count - 1 do begin
      vStr := GetEdtStr(I, vStrLen);
      FRowsCache.Add(vStr);

      vPos := 0; vFndLen := 0;
      if FFilter <> nil then begin
        if vMask <> '' then
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

   {$ifdef bTrace}
    TraceEnd('  done');
   {$endif bTrace}

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

    if (optGrepSortMode <> 0) and (optGrepSortMode <> 1) then begin
     {$ifdef bTrace}
      TraceBeg('Sort...');
     {$endif bTrace}

      FFilter.SortList(True, 0);

     {$ifdef bTrace}
      TraceEnd('  done');
     {$endif bTrace}
    end;

    FGrid.RowCount := vCount;

    UpdateHeader;
    ResizeDialog;
  end;


(*
  procedure TGrepDlg.ReinitGrid; {override;}
  var
    I, vPos, vLen, vFndLen, vMaxRow, vMaxRowLen, vMaxLen :Integer;
    vSel :PEdtSelection;
    vStr :PTChar;
    vMask, vXMask :TString;
    vHasMask :Boolean;
  begin
    FTotalCount := FMatches.Count;

    if not (vsRowCache in FValid) then begin
      FRowsCache.Clear;
      FLensCache.Clear;
      FRowsCache.Capacity := FMatches.Count;
      FLensCache.Capacity := FMatches.Count;
      for I := 0 to FMatches.Count - 1 do begin
        vStr := GetEdtStr(I, vLen);
        FRowsCache.Add(vStr);
        FLensCache.Add(vLen);
      end;
      FValid := FValid + [vsRowCache] - [vsFilter, vsSort];
    end;

    if not (vsFilter in FValid) then begin
     {$ifdef bTrace}
      TraceBeg('Filter...');
     {$endif bTrace}

      vHasMask := False;
      vMask := FFilterMask;
      if vMask <> '' then begin
        vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
        if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
          vMask := vMask + '*';
      end;

      FreeObj(FFilter);
      if (vMask <> '') or ((optGrepSortMode <> 0) and (optGrepSortMode <> 1)) then begin
        FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
        FFilter.Owner := Self;
        if optXLatMask then
          vXMask := FarXLatStr(vMask);
      end;

      vMaxLen := 0;
      for I := 0 to FMatches.Count - 1 do begin
        vSel := FMatches.PItems[I];
        vStr := FRowsCache[I];
        vLen := FLensCache[I];

        vPos := 0; vFndLen := 0;
        if FFilter <> nil then begin
          if vMask <> '' then
            if not ChrCheckXMask(vMask, vXMask, vStr, vHasMask, vPos, vFndLen) then
              Continue;
          FFilter.Add(I, vPos, vFndLen);
        end;

        if optGrepTrimSpaces then
          StrTrimFirst(vStr, vLen);
        vLen := ChrExpandTabsLen(vStr, vLen);
        vMaxLen := IntMax(vMaxLen, vLen);
      end;

      FMenuMaxWidth := vMaxLen + 4;

      vMaxRowLen := 0;
      if optGrepShowLines then begin
( *
        vMaxRow := 0;
        if vCount > 0 then
          vMaxRow := GetSelItem(vCount - 1).FRow + 1;
        vMaxRowLen := Length(Int2Str(vMaxRow));
        Inc(FMenuMaxWidth, vMaxRowLen + 1);
* )
      end;

      FValid := FValid + [vsFilter] - [vsSort];
     {$ifdef bTrace}
      TraceEnd('  done');
     {$endif bTrace}
    end;

    if not (vsSort in FValid) then begin
      if (optGrepSortMode <> 0) and (optGrepSortMode <> 1) then begin
       {$ifdef bTrace}
        TraceBeg('Sort...');
       {$endif bTrace}

        FFilter.SortList(True, 0);

       {$ifdef bTrace}
        TraceEnd('  done');
       {$endif bTrace}
      end;
      FValid := FValid + [vsSort];
    end;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;
    if optGrepShowLines then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxRowLen+2, taRightJustify, [coColMargin{coNoVertLine}], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 2) );

    if FFilter <> nil then
      FGrid.RowCount := FFilter.Count
    else
      FGrid.RowCount := FMatches.Count;

    UpdateHeader;
    ResizeDialog;
  end;
*)


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
//  vStr := GetEdtStr(vIdx, vLen);

    vStr := FRowsCache[vIdx];
    vLen := StrLen(vStr);

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


 {-----------------------------------------------------------------------------}
 { Поддержка сортировки                                                        }

  function TGrepDlg.ItemCompare(AIndex1, AIndex2 :Integer; Context :TIntPtr) :Integer; {override;}
  var
    vSel1, vSel2 :PEdtSelection;
    vStr1, vStr2 :PTChar;
    vLen1, vLen2 :Integer;
    vNum1, vNum2 :TFloat;
  begin
    Result := 0;

    vSel1 := FMatches.PItems[AIndex1];
    vSel2 := FMatches.PItems[AIndex2];

    if Abs(optGrepSortMode) = 1 then
      Result := IntCompare(vSel1.FRow, vSel2.FRow)
    else begin
      vStr1 := FRowsCache[AIndex1];
      vStr2 := FRowsCache[AIndex2];

      case Abs(optGrepSortMode) of
        2:
          begin
            if optGrepTrimSpaces then begin
              vLen1 := MaxInt; vLen2 := MaxInt; { Не важно... }
              StrTrimFirst(vStr1, vLen1);
              StrTrimFirst(vStr2, vLen2);
            end;
            Result := UpComparePChar(vStr1, vStr2);
          end;
        3:
          Result := UpCompareBuf((vStr1 + vSel1.FCol)^, (vStr2 + vSel2.FCol)^, vSel1.FLen, vSel2.FLen);
        4:
          begin
            vNum1 := Str2Float(vStr1 + vSel1.FCol, vSel1.FLen);
            vNum2 := Str2Float(vStr2 + vSel2.FCol, vSel2.FLen);
            Result := FloatCompare(vNum1, vNum2);
          end;
      end;
    end;

    if optGrepSortMode < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(AIndex1, AIndex2);
  end;


  procedure TGrepDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optGrepSortMode then
      optGrepSortMode := AOrder
    else
      optGrepSortMode := -AOrder;

//  LocReinitAndSaveCurrent;
    ReinitGrid;
  end;


  procedure TGrepDlg.SortByDlg;
  var
    vMenu :TFarMenu;
    vRes :Integer;
    vChr :TChar;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strSortBy),
    [
      GetMsg(strLineNumber),
      GetMsg(strWholeRow),
      GetMsg(strFoundMatch),
      GetMsg(strFoundMatchNum)
    ]);
    try
      vRes := Abs(optGrepSortMode) - 1;
      if vRes = -1 then
        vRes := 0;
      vChr := '+';
      if optGrepSortMode < 0 then
        vChr := '-';
      vMenu.Items[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);

      if not vMenu.Run then
        Exit;

      vRes := vMenu.ResIdx;
      if vRes <> -1 then
        SetOrder(vRes + 1);

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

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
      KEY_CTRLF12:
        SortByDlg;
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


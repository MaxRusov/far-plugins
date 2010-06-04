{$I Defines.inc}

unit EdtFindMain;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Editor Find Shell                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,
    MixFormat,

    PluginW,
    FarCtrl,

    EdtFindCtrl,
    EdtFindDlg,
    EdtReplaceDlg;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;

 {$ifdef bAdvSelect}
  function ProcessEditorInputW(const ARec :INPUT_RECORD) :Integer; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$endif bAdvSelect}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  type
    PEdtSelection = ^TEdtSelection;
    TEdtSelection = record
      FRow, FCol, FLen :Integer;
    end;


 {-----------------------------------------------------------------------------}

  function ChrCompare(APtr1, APtr2 :PTChar; ACount :Integer) :Integer;
  begin
    Result := 0;
    while (Result < ACount) and ((APtr1 + Result)^ = (APtr2 + Result)^) do
      inc(Result);
  end;


  function ChrScan(Str :PTChar; Count :Integer; Match :TChar) :Integer;
  var
    vBeg, vEnd :PTChar;
  begin
    vBeg := Str;
    vEnd := Str + Count;
    while (Str < vEnd) and (Str^ <> Match) do
      inc(Str);
    Result := Str - vBeg;
  end;


  function ChrScanBack(Str :PTChar; Count :Integer; Match :TChar) :Integer;
  var
    vPtr, vFirst :PTChar;
  begin
    vPtr := Str - 1;
    vFirst := Str - Count;
    while (vPtr >= vFirst) and (vPtr^ <> Match) do
      dec(vPtr);
    Result := Str - vPtr - 1;
  end;


  function MemSearchSample(ABuf :PTChar; ALen :Integer; ASample :PTChar; ASampleLen :Integer) :Integer;
    { Поиск в буфере ABuf^[ALen] подстроки ASample^[ASampleLen].
      Если результат меньше len - подстрока найдена, результат - ее смещение в буфере.
      Если подстрока не найдена, возвращает ALen.}
  var
    vPtr, vEnd :PTChar;
  begin
    Result := ALen;
    vPtr := ABuf;
    vEnd := ABuf + ALen - ASampleLen + 1;
    while vPtr < vEnd do begin
      Inc(vPtr, ChrScan(vPtr, vEnd - vPtr, ASample^));
      if vPtr >= vEnd then
        Exit;
      if ChrCompare(vPtr, ASample, ASampleLen) = ASampleLen then begin
        Result := vPtr - ABuf;
        Exit;
      end;
      Inc(vPtr);
    end;
  end;


  function SearchChars(Chars :PTChar; CharsLen :Integer; Match :PTChar; MatchLen :Integer; var Delta :Integer) :Boolean;
  begin
    Assert((Delta >= 0) and (Delta < CharsLen) and (MatchLen > 0));
    inc(Delta, MemSearchSample(Chars + Delta, CharsLen - Delta, Match, MatchLen));
    Result := Delta < CharsLen;
  end;


  function MemSearchSampleBack(ABuf :PTChar; ALen :Integer; ASample :PTChar; ASampleLen :Integer) :Integer;
  var
    vPtr, vFirst :PTChar;
  begin
    Result := ALen;
    vPtr := ABuf;
    vFirst := ABuf - ALen;
    while vPtr > vFirst do begin
      Dec(vPtr, ChrScanBack(vPtr, vPtr - vFirst, ASample^));
      if vPtr = vFirst then
        Exit;
      if ChrCompare(vPtr - 1, ASample, ASampleLen) = ASampleLen then begin
        Result := ABuf - vPtr;
        Exit;
      end;
      Dec(vPtr);
    end;
  end;


  function SearchCharsBack(Chars :PTChar; CharsLen :Integer; Match :PTChar; MatchLen :Integer; var Delta :Integer) :Boolean;
  begin
    Assert((Delta >= 0) and (Delta < CharsLen) and (MatchLen > 0));
    if Delta > CharsLen - MatchLen then
      Delta := CharsLen - MatchLen;
    dec(Delta, MemSearchSampleBack(Chars + Delta + 1, Delta + 1, Match, MatchLen));
    Result := Delta >= 0;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TFinder = class(TBasis)
    public
      constructor CreateEx(const AExpr :TString; AOpt :TFindOptions);
      destructor Destroy; override;

      function Find(AStr :PTChar; ALen :Integer; AForward :Boolean; var ADelta, AFindLen :Integer) :Boolean;

    private
      FOpt      :TFindOptions;
      FExpr     :TString;
      FExprLen  :Integer;

      FTmpBuf   :PTChar;
      FTmpLen   :Integer;

      FRegExp   :THandle;
      FBrackets :Integer;
      FMatches  :PRegExpMatch;
    end;


  constructor TFinder.CreateEx(const AExpr :TString; AOpt :TFindOptions);
  begin
    FOpt := AOpt;

    if not (foRegexp in AOpt) then begin
      if not (foCaseSensitive in AOpt) then
        FExpr := StrUpCase(AExpr)
      else
        FExpr := AExpr;
      FExprLen := length(AExpr);
    end else
    begin
      FExpr := RegexpQuote(AExpr);
      if not (foCaseSensitive in AOpt) then
        FExpr := FExpr + 'i';

      if FARAPI.RegExpControl(0, RECTL_CREATE, @FRegExp) = 0 then
        Wrong;
      if FARAPI.RegExpControl(FRegExp, RECTL_COMPILE, PTChar(FExpr)) = 0 then
        AppErrorId(strBadRegexp);
      FARAPI.RegExpControl(FRegExp, RECTL_OPTIMIZE, nil);

      FBrackets := FARAPI.RegExpControl(FRegExp, RECTL_BRACKETSCOUNT, nil);
      if FBrackets <= 0 then
        Wrong;

      FMatches := MemAllocZero(FBrackets * SizeOf(TRegExpMatch));
    end;
  end;


  destructor TFinder.Destroy; {override;}
  begin
    MemFree(FTmpBuf);
    MemFree(FMatches);
    if FRegExp <> 0 then
      FARAPI.RegExpControl(FRegExp, RECTL_FREE, nil);
  end;


  function TFinder.Find(AStr :PTChar; ALen :Integer; AForward :Boolean; var ADelta, AFindLen :Integer) :Boolean;
  var
    vStr :PTChar;
    vExprLen :Integer;
    vRegExp :TRegExpSearch;
  begin
    Result := False;

    if foRegexp in FOpt then
      vExprLen := 1
    else
      vExprLen := FExprLen;

    if AForward then begin
      if ADelta < 0 then
        ADelta := 0;
      if ADelta + vExprLen > ALen then
        Exit;
    end else
    begin
      if ADelta > ALen - 1 then
        ADelta := ALen - 1;
      if ADelta < 0 then
        Exit;
    end;

    if foRegexp in FOpt then begin
      { Поиск по регулярным варажениям }

      vRegExp.Text := AStr;
      vRegExp.Position := ADelta;
      vRegExp.Length := ALen;
      vRegExp.Match := FMatches;
      vRegExp.Count := FBrackets;
      vRegExp.Reserved := nil;

      if AForward then begin
        if FARAPI.RegExpControl(FRegExp, RECTL_SEARCHEX, @vRegExp) = 1 then begin
          ADelta := FMatches.Start;
          AFindLen := FMatches.EndPos - FMatches.Start;
          Result := True;
        end;
      end else
      begin
        while True do begin
          vRegExp.Position := ADelta;

          if FARAPI.RegExpControl(FRegExp, RECTL_MATCHEX, @vRegExp) = 1 then begin
            ADelta := FMatches.Start;
            AFindLen := FMatches.EndPos - FMatches.Start;
            Result := True;
            Break;
          end;

          Dec(ADelta);
          if ADelta < 0 then
            Exit;
        end;
      end;

    end else
    begin

      if foCaseSensitive in FOpt then
        vStr := AStr
      else begin
        if ALen > FTmpLen then begin
          MemFree(FTmpBuf);
          FTmpLen := 0;

          FTmpBuf := MemAlloc(ALen * SizeOf(TChar));
          FTmpLen := ALen;
        end;

        Move(AStr^, FTmpBuf^, ALen * SizeOf(TChar));
        CharUpperBuff(FTmpBuf, ALen);

        vStr := FTmpBuf;
      end;

      if not (foWholeWords in FOpt) then begin
        { Простой поиск }
        if AForward then
          Result := SearchChars(vStr, ALen, PTChar(FExpr), FExprLen, ADelta)
        else
          Result := SearchCharsBack(vStr, ALen, PTChar(FExpr), FExprLen, ADelta);
      end else
      begin
        { Поиск по словам }
        while True do begin
          if AForward then
            Result := SearchChars(vStr, ALen, PTChar(FExpr), FExprLen, ADelta)
          else
            Result := SearchCharsBack(vStr, ALen, PTChar(FExpr), FExprLen, ADelta);
          if not Result then
            Break;

          { Это слово?...}
          Result := ((ADelta = 0) or not CharIsWordChar((vStr + ADelta - 1)^)) and
            ((ADelta + FExprLen >= ALen) or not CharIsWordChar((vStr + ADelta + FExprLen)^));
          if Result then
            Break;

          if AForward then begin
            Inc(ADelta);
            if ADelta + vExprLen > ALen then
              Exit;
          end else
          begin
            Dec(ADelta);
            if ADelta < 0 then
              Exit;
          end;
        end;
      end;
      AFindLen := FExprLen;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    ECtrlBreak = class(TException);


  procedure CtrlBreakException;
  begin
//  raise ECtrlBreak.Create('');
    raise ECtrlBreak.Create('');
  end;


  procedure CheckInterrupt;
  begin
    if CheckForEsc then
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt) + #10#10 + GetMsgStr(strYes) + #10 + GetMsgStr(strNo), FMSG_WARNING, 2) = 0 then
        CtrlBreakException
  end;


  var
    gProgressLast :DWORD;
    gProgressTitle :TString;
    gProgressAdd :TString;
    gFoundCount :Integer;
    gReplCount :Integer;
    gScrSave :THandle;

  procedure LocShowMessage(const AStr :TString; APercent :Integer);
  var
    vMess :TString;
    vTick :Cardinal;
    vLen  :Integer;
  begin
    vTick := GetTickCount;
    if TickCountDiff(vTick, gProgressLast) < 50 then
      Exit;
    gProgressLast := vTick;
    if gScrSave = 0 then
      gScrSave := FARAPI.SaveScreen(0, 0, -1, -1);
    vMess := AStr;
    vLen := RangeLimit( Length(vMess), 40, 70);
    if Length(vMess) > vLen then
      vMess := Copy(vMess, 1, vLen - 3) + '...';
    vMess := GetMsgStr(strFindFor) + #10 + vMess;
    if gProgressAdd <> '' then
      vMess := vMess + #10 + Format(gProgressAdd, [gFoundCount, gReplCount]);
    if APercent <> -1 then
      vMess := vMess + #10 + GetProgressStr(vLen, APercent);
    vMess := gProgressTitle + #10 + vMess;
    FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PTChar(vMess)), 0, 0);
    CheckInterrupt;
  end;


  procedure RestoreOldPos(const AEdtInfo :TEditorInfo);
  var
    vPosInfo :TEditorSetPosition;
  begin
    vPosInfo.CurLine := AEdtInfo.CurLine;
    vPosInfo.CurPos := AEdtInfo.CurPos;
    vPosInfo.LeftPos := AEdtInfo.LeftPos;
    vPosInfo.TopScreenLine := AEdtInfo.TopScreenLine;
    vPosInfo.Overtype := -1;
    vPosInfo.CurTabPos := -1;
    FARAPI.EditorControl(ECTL_SETPOSITION, @vPosInfo);
  end;


  type
    TEdtFindOptions = set of (
      efoProgress,
      efoChangePos,
      efoCalcCount
    );

  function EditorFind(const AStr :TString; AOpt :TFindOptions; var ARow, ACol, AFindLen :Integer; AForward :Boolean; AddOpt :TEdtFindOptions;
    ARow1, ARow2 :Integer; AResults :TExList = nil) :Boolean;
  var
    vFinder :TFinder;
    vEdtInfo :TEditorInfo;
    vPosInfo :TEditorSetPosition;
    vStrInfo :TEditorGetString;
    vRow, vCol, vLen, vBegRow, vEndRow, vCol1, vCol2, vDelta :Integer;
    vSel :TEdtSelection;
    vLocalProgress :Boolean;
  begin
    Result := False;

    FillChar(vEdtInfo, SizeOf(vEdtInfo), 0);
    if FARAPI.EditorControl(ECTL_GETINFO, @vEdtInfo) <> 1 then
      Exit;

   {$ifdef bTrace}
    if AResults <> nil then
      TraceF('Find matches: %d-%d', [ARow1, ARow2]);
   {$endif bTrace}

    vLocalProgress := gProgressLast = 0;
    if vLocalProgress then
      gProgressLast := GetTickCount;

    vFinder := TFinder.CreateEx(AStr, AOpt);
    try
      vPosInfo.CurPos := -1;
      vPosInfo.LeftPos := -1;
      vPosInfo.TopScreenLine := -1;
      vPosInfo.Overtype := -1;
      vPosInfo.CurTabPos := -1;

      if ARow2 > ARow1 then begin
        vBegRow := ARow1;
        vEndRow := IntMin(ARow2, vEdtInfo.TotalLines);
      end else
//    if foSelectedOnly in AOpt then begin
//      if not FBlock.Show then
//        Exit;
//      if AForward then begin
//        if Loc.Comp(FBlock.A) < 0 then
//          Loc := FBlock.A;
//      end else
//      begin
//        if Loc.Comp(FBlock.B) > 0 then
//          Loc := FBlock.B;
//      end;
//      BegRow := FBlock.A.Row;
//      EndRow := FBlock.B.Row;
//    end else
      begin
        vBegRow := 0;
        vEndRow := vEdtInfo.TotalLines;
      end;

      vRow := ARow;
      vCol := ACol;

      while True do begin
        if AForward then begin
          if vRow >= vEndRow then
            Break;
        end else
        begin
          if vRow < vBegRow then
            Break;
        end;

        if (efoProgress in AddOpt) and optShowProgress then
          LocShowMessage(AStr, (100 * vRow) div vEdtInfo.TotalLines);
//        LocShowMessage(AStr, (100 * (vRow - vBegRow)) div (vEndRow - vBegRow));

        vPosInfo.CurLine := vRow;
        FARAPI.EditorControl(ECTL_SETPOSITION, @vPosInfo);

        vStrInfo.StringNumber := -1;
        if FARAPI.EditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
//        if soSelectedOnly in Options then begin
//          FBlock.ColRange(Loc.Row, Col1, Col2);
//          MaxLimit(Col2, ERow.Len + 1);
//        end else
          begin
            vCol1 := 0;
            vCol2 := vStrInfo.StringLength;
          end;

          if vCol2 > vCol1 then begin
            vDelta := vCol - vCol1; { Может быть меньше 0 и больше (Col2 - Col1) - так и задумано. }
            if vFinder.Find(vStrInfo.StringText + vCol1, vCol2 - vCol1, AForward, vDelta, vLen) then begin
              if AResults <> nil then begin
                vSel.FRow := vRow;
                vSel.FCol := vCol1 + vDelta;
                vSel.FLen := vLen;
                AResults.AddData(vSel);
                vCol := vSel.FCol + 1;
                Result := True;
                Continue;
              end else
              if efoCalcCount in AddOpt then begin
                Inc(gFoundCount);
                vCol := vCol1 + vDelta + 1;
                Result := True;
                Continue;
              end else
              begin
                ARow := vRow;
                ACol := vCol1 + vDelta;
                AFindLen := vLen;
                Result := True;
                Break;
              end;
            end;
          end;
        end;

        if AForward then begin
          vCol := 0;
          inc(vRow);
        end else
        begin
          vCol := MaxInt;
          dec(vRow);
        end;
      end;

    finally
      if Result and (efoChangePos in AddOpt) then
        { Сохраним найденную позицию текущей }
      else
        { восстановим старую позицию }
        RestoreOldPos(vEdtInfo);

      if vLocalProgress then begin
        gProgressLast := 0;
        if gScrSave <> 0 then begin
          FARAPI.RestoreScreen(gScrSave);
          gScrSave := 0;
        end;
      end;

      FreeObj(vFinder);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

 {$ifdef bAdvSelect}

  type
    TEdtHelper = class(TBasis)
    public
      constructor CreateEx(AId :Integer);
      destructor Destroy; override;

      procedure AddFound(const ASel :TEdtSelection);

      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FID :Integer;
      FFound :TEdtSelection;
      FAllFound :TExList;
    end;


  constructor TEdtHelper.CreateEx(AId :Integer);
  begin
    Create;
    FId := AId;
    FAllFound := TExList.CreateSize(SizeOf(TEdtSelection));
  end;


  destructor TEdtHelper.Destroy; {override;}
  begin
    FreeObj(FAllFound);
    inherited Destroy;
  end;


  function TEdtHelper.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := IntCompare(FID, TIntPtr(Key));
  end;


  procedure TEdtHelper.AddFound(const ASel :TEdtSelection);
  begin
    FAllFound.AddData(ASel);
  end;


  var
    gEdtHelpers :TObjList;

  function FindEdtHelper(AId :Integer; ACreate :Boolean) :TEdtHelper;
  var
    vIndex :Integer;
  begin
    Result := nil;
    if gEdtHelpers.FindKey(Pointer(TIntPtr(AID)), 0, [foBinary], vIndex) then
      Result := gEdtHelpers[vIndex]
    else if ACreate then begin
      Result := TEdtHelper.CreateEx(AID);
      gEdtHelpers.Insert(vIndex, Result);
    end;
  end;


  procedure DeleteEdtHelper(AId :Integer);
  var
    vIndex :Integer;
  begin
    if gEdtHelpers.FindKey(Pointer(TIntPtr(AID)), 0, [foBinary], vIndex) then
      gEdtHelpers.FreeAt(vIndex);
  end;



  var
    gEdtID     :Integer        = -1;
    gFound     :TEdtSelection;

    gMatchStr  :TString;
    gMatchOpt  :TFindOptions;

    gMatches   :TExList;
    gMatchRow1 :Integer;
    gMatchRow2 :Integer;


  procedure EdtMark(ARow, ACol, ALen :Integer);
  begin
    gFound.FRow := ARow;
    gFound.FCol := ACol;
    gFound.FLen := ALen;
  end;


  procedure EdtClearMark(AClearMatches :Boolean = True; ARedraw :Boolean = True);
  begin
    if (gFound.FLen > 0) or (gMatches <> nil) then begin
      if AClearMatches then
        gEdtID := -1;

      EdtMark(0, 0, 0);

      if AClearMatches then begin
        gMatchStr := '';
        FreeObj(gMatches);
      end;

      if ARedraw then
        FARAPI.EditorControl(ECTL_REDRAW, nil);
    end;
  end;


  procedure ShowAllMatch(const AStr :TString; AOpt :TFindOptions);
  begin
    gMatchStr  := AStr;
    gMatchOpt  := AOpt;
    gMatchRow1 := 0;
    gMatchRow2 := 0;
  end;


  procedure UpdateMatches(const AInfo :TEditorInfo);
  var
    i, vRow1, vRow2, vRow, vCol, vFindLen, vCount :Integer;
  begin
    vRow1 := AInfo.TopScreenLine;
    vRow2 := vRow1 + AInfo.WindowSizeY;

    if (vRow1 <> gMatchRow1) or (vRow2 <> gMatchRow2) then begin
      if gMatches = nil then
        gMatches := TExList.CreateSize(SizeOf(TEdtSelection));

      if (vRow1 >= gMatchRow2) or (vRow2 < gMatchRow1) then begin

        gMatches.Clear;
        gMatchRow1 := 0;
        gMatchRow2 := 0;

        vCol := 0;
        EditorFind(gMatchStr, gMatchOpt, vRow1, vCol, vFindLen, {Forward:}True, [], vRow1, vRow2, gMatches);

        gMatchRow1 := vRow1;
        gMatchRow2 := vRow2;

      end else
      begin
        if gMatchRow1 < vRow1 then begin
          { Обрезание сверху }
          I := 0;
          while (I < gMatches.Count) and (PEdtSelection(gMatches.PItems[I]).FRow < vRow1) do
            Inc(I);
          if I > 0 then
            gMatches.DeleteRange(0, I);
          gMatchRow1 := vRow1;
        end;

        if gMatchRow2 > vRow2 then begin
          { Обрезание снизу }
          I := 0;
          while (I < gMatches.Count) and (PEdtSelection(gMatches.PItems[gMatches.Count - I - 1]).FRow >= vRow2) do
            Inc(I);
          if I > 0 then
            gMatches.DeleteRange(gMatches.Count - I, I);
          gMatchRow2 := vRow2;
        end;

        if vRow2 > gMatchRow2 then begin
          { Дополнение снизу }
          vRow := gMatchRow2;
          vCol := 0;
          EditorFind(gMatchStr, gMatchOpt, vRow, vCol, vFindLen, {Forward:}True, [], gMatchRow2, vRow2, gMatches);
          gMatchRow2 := vRow2;
        end;

        if vRow1 < gMatchRow1 then begin
          { Дополнение сверху }
          vCount := gMatches.Count;

          vRow := vRow1;
          vCol := 0;
          EditorFind(gMatchStr, gMatchOpt, vRow, vCol, vFindLen, {Forward:}True, [], vRow1, gMatchRow1, gMatches);

          if gMatches.Count > vCount then
            gMatches.Move(vCount, 0, gMatches.Count - vCount);

          gMatchRow1 := vRow1;
        end;
      end;

//    TraceF('Known matches: %d (%d-%d)', [gMatches.Count, gMatchRow1, gMatchRow2]);
    end;
  end;

 {$endif bAdvSelect}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure GoNext(var ACol :Integer; AForward :Boolean);
  begin
    if optCursorAtEnd then begin
      if AForward then
        {}
      else
        Dec(ACol);
    end else
    begin
      if AForward then
        Inc(ACol)
      else
        Dec(ACol);
    end;
  end;


  procedure GotoPosition(ARow, ACol1, ACol2, ACol :Integer; ACenter :Boolean; ATopLine :Integer = 0);
  var
    vNewTop, vHeight, vNewLeft, vWidth :Integer;
    vPos :TEditorSetPosition;
    vInfo :TEditorInfo;
  begin
    vNewTop := -1; vNewLeft := -1;
    if (ACol1 <> -1) and (FARAPI.EditorControl(ECTL_GETINFO, @vInfo) = 1) then begin
      if ATopLine = 0 then
        vHeight := vInfo.WindowSizeY
      else
        vHeight := ATopLine - 1{Строка состояния редактора};
      if ACenter or ((ARow < vInfo.TopScreenLine) or (ARow >= vInfo.TopScreenLine + vHeight)) then
        vNewTop := RangeLimit(ARow - (vHeight div 3), 0, vInfo.TotalLines - vInfo.WindowSizeY );

      vWidth := vInfo.WindowSizeX - 1{ScrollBar};
      if (ACol1 < vInfo.LeftPos) or (ACol2 > vInfo.LeftPos + vWidth) then
        vNewLeft := RangeLimit(vInfo.LeftPos, (ACol2 + 3) - vWidth, IntMax(ACol1 - 3, 0));
    end;
    vPos.CurLine := ARow;
    vPos.CurPos := ACol;
    vPos.TopScreenLine := vNewTop;
    vPos.LeftPos := vNewLeft;
    vPos.CurTabPos := -1;
    vPos.Overtype := -1;
    FARAPI.EditorControl(ECTL_SETPOSITION, @vPos);
  end;


  procedure SelectFound(ARow, ACol, ALen :Integer);
  var
    vSel :TEditorSelect;
  begin
    vSel.BlockType := BTYPE_STREAM;
    vSel.BlockStartLine := ARow;
    vSel.BlockStartPos := ACol;
    vSel.BlockWidth := ALen;
    vSel.BlockHeight := 1;
    FARAPI.EditorControl(ECTL_SELECT, @vSel);
  end;


  procedure SelectClear;
  var
    vSel :TEditorSelect;
  begin
    FillChar(vSel, SizeOf(vSel), 0);
    vSel.BlockType := BTYPE_NONE;
    FARAPI.EditorControl(ECTL_SELECT, @vSel);
  end;


  function LoopPrompt(const AStr :TString; AForward :Boolean) :Boolean;
  begin
   Result := ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr + #10 +
     GetMsgStr(TMessages(IntIf(AForward, Byte(strContinueFromBegin), Byte(strContinueFromEnd)))),
     FMSG_MB_YESNO, 0) = 0;
  end;


  procedure FindStr(const AStr :TString; AOpt :TFindOptions; AEntire, ANext, AForward :Boolean);
  var
    vEdtInfo :TEditorInfo;
    vRow, vCol, vFindLen :Integer;
    vStartRow, vRow1, vRow2 :Integer;
    vFound, vLoop :Boolean;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
    if AStr = '' then
      Exit;

    FillChar(vEdtInfo, SizeOf(vEdtInfo), 0);
    if FARAPI.EditorControl(ECTL_GETINFO, @vEdtInfo) <> 1 then
      Exit;

    if AEntire then begin
      if AForward then begin
        vRow := 0;
        vCol := 0;
      end else
      begin
        vRow := vEdtInfo.TotalLines - 1;
        vCol := MaxInt;
      end;
    end else
    begin
      vRow := vEdtInfo.CurLine;
      vCol := vEdtInfo.CurPos;
    end;

    if ANext then
      GoNext(vCol, AForward);

    vLoop := AEntire or (AForward and (vRow = 0) and (vCol = 0));

    gScrSave := 0;
    gProgressLast := 0;
    gFoundCount := 0;
    gReplCount := 0;
    gProgressTitle := GetMsgStr(strFind);
    gProgressAdd := '';

    vRow1 := 0; vRow2 := 0;
    vStartRow := vRow;
    while True do begin

     {$ifdef bTrace}
      Trace('Search...');
      vStart := GetTickCount;
     {$endif bTrace}

      vFound := EditorFind(AStr, AOpt, vRow, vCol, vFindLen, AForward, [efoProgress], vRow1, vRow2);

     {$ifdef bTrace}
      TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
     {$endif bTrace}

      if vFound then begin

        GotoPosition(vRow, vCol, vCol + vFindLen,
          IntIf(optCursorAtEnd and AForward, vCol + vFindLen, vCol), optCenterAlways);

        if optSelectFound then
          SelectFound(vRow, vCol, vFindLen);

       {$ifdef bAdvSelect}
        gEdtID := vEdtInfo.EditorID;
        if not optSelectFound then
          EdtMark(vRow, vCol, vFindLen);
        if optShowAllFound then
          ShowAllMatch(AStr, AOpt);
       {$endif bAdvSelect}

        FARAPI.EditorControl(ECTL_REDRAW, nil);
      end else
      begin
        if optSelectFound then
          SelectClear;
       {$ifdef bAdvSelect}
        EdtClearMark(False);
       {$endif bAdvSelect}

        if optLoopSearch and not vLoop then begin

          if LoopPrompt(AStr, AForward) then begin
            if AForward then begin
              vRow := 0;
              vCol := 0;
              vRow1 := 0;
              vRow2 := vStartRow + 1;
            end else
            begin
              vRow := vEdtInfo.TotalLines - 1;
              vCol := MaxInt;
              vRow1 := vStartRow;
              vRow2 := vEdtInfo.TotalLines;
            end;
            vLoop := True;
            Continue;
          end;

        end else
          ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr,
            FMSG_WARNING or FMSG_MB_OK);
      end;

      Break;
    end;
  end;


  procedure CountStr(const AStr :TString; AOpt :TFindOptions);
  var
    vRow, vCol, vLen :Integer;
    vFound :Boolean;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
   {$ifdef bTrace}
    Trace('Count...');
    vStart := GetTickCount;
   {$endif bTrace}

    gScrSave := 0;
    gProgressLast := 0;
    gFoundCount := 0;
    gReplCount := 0;
    gProgressTitle := GetMsgStr(strFind);
    gProgressAdd := GetMsgStr(strFoundCount);

    vRow := 0; vCol := 0; vLen := 0;
    vFound := EditorFind(AStr, AOpt, vRow, vCol, vLen, True, [efoProgress, efoCalcCount], 0, 0);

   {$ifdef bTrace}
    TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
   {$endif bTrace}

    if vFound then
      ShowMessage(gProgressTitle, Format(GetMsgStr(strCountResult), [AStr, gFoundCount]), FMSG_MB_OK)
    else
      ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr, FMSG_WARNING or FMSG_MB_OK);
  end;


  procedure Find(APickWord :Boolean);
  var
    vEntire, vCount :Boolean;
  begin
    SyncFindStr;
    if not FindDlg(APickWord, vEntire, vCount) then
      Exit;
   {$ifdef bAdvSelect}
    EdtClearMark;
   {$endif bAdvSelect}
    gLastIsReplace := False;
    if vCount then
      CountStr(gStrFind, gOptions)
    else
      FindStr(gStrFind, gOptions, vEntire, False, not gReverse);
  end;


  procedure FindWord(AForward :Boolean);
  var
    vStr :TString;
  begin
    vStr := GetWordUnderCursor(nil, False);
    if vStr <> '' then begin
      gStrFind := vStr;
      gOptions := gOptions + [foWholeWords] - [foRegexp];
      AddToHistory(cFindHistory, gStrFind);
      FindStr(gStrFind, gOptions, False, True, AForward)
    end else
      Beep;
  end;


  procedure PickWord;
  var
    vStr :TString;
    vCol :Integer;
  begin
    vCol := -1;
    vStr := GetWordUnderCursor(@vCol, False);
    if vStr <> '' then begin
      gStrFind := vStr;
      gOptions := gOptions + [foWholeWords] - [foRegexp];
      AddToHistory(cFindHistory, gStrFind);
      GotoPosition(-1, -1, -1, vCol, False);
      FindStr(gStrFind, gOptions, False, False, True);
    end else
      Beep;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ReplaceStr(const AFindStr, AReplStr :TString; AOpt :TFindOptions; AEntire, ANext, AForward :Boolean);
  var
    vEdtInfo :TEditorInfo;

    procedure LocShow(ARow, ACol, ALen :Integer);
    begin
      if optSelectFound then
        if ALen > 0 then
          SelectFound(ARow, ACol, ALen)
        else
          SelectClear;
     {$ifdef bAdvSelect}
      gEdtID := vEdtInfo.EditorID;
      if not optSelectFound then
        if ALen > 0 then
          EdtMark(ARow, ACol, ALen)
        else
          EdtClearMark(False);
      if optShowAllFound then
        ShowAllMatch(AFindStr, AOpt);
     {$endif bAdvSelect}
      FARAPI.EditorControl(ECTL_REDRAW, nil);
    end;

  var
    vStr :TString;
    vRow, vCol, vFindLen, vReplLen, vRowLen, vRes :Integer;
    vStartRow, vRow1, vRow2 :Integer;
    vFound, vPrompt, vReplace, vLoop :Boolean;
    vStrInfo :TEditorGetString;
    vStrSet :TEditorSetString;
    vUndoRec :TEditorUndoRedo;
    vTmpBuf :PTChar;
    vTmpLen :Integer;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
    if AFindStr = '' then
      Exit;

    FillChar(vEdtInfo, SizeOf(vEdtInfo), 0);
    if FARAPI.EditorControl(ECTL_GETINFO, @vEdtInfo) <> 1 then
      Exit;

    if AEntire then begin
      if AForward then begin
        vRow := 0;
        vCol := 0;
      end else
      begin
        vRow := vEdtInfo.TotalLines - 1;
        vCol := MaxInt;
      end;
    end else
    begin
      vRow := vEdtInfo.CurLine;
      vCol := vEdtInfo.CurPos;
    end;

    if ANext then
      GoNext(vCol, AForward);

    vLoop := AEntire or (AForward and (vRow = 0) and (vCol = 0));

    if optGroupUndo then begin
      vUndoRec.Command := EUR_BEGIN;
      FARAPI.EditorControl(ECTL_UNDOREDO, @vUndoRec);
    end;

    vPrompt := foPromptOnReplace in AOpt;

    vTmpBuf := nil;
    vTmpLen := 0;
    try
      vReplLen := length(AReplStr);

      gScrSave := 0;
      gProgressLast := 0;
      gFoundCount := 0;
      gReplCount := 0;
      gProgressTitle := GetMsgStr(strReplace);
      gProgressAdd := GetMsgStr(strFoundReplaced);

      vRow1 := 0; vRow2 := 0;
      vStartRow := vRow;

     {$ifdef bTrace}
      vStart := 0;
     {$endif bTrace}

      while True do begin

        if not vPrompt and (gProgressLast = 0) then
          { Инициализируем сквозной прогресс-индикатор }
          gProgressLast := GetTickCount;

       {$ifdef bTrace}
        if vStart = 0 then begin
          Trace('Replace...');
          vStart := GetTickCount;
        end;
       {$endif bTrace}

        vFound := False;
        try
          vFound := EditorFind(AFindStr, AOpt, vRow, vCol, vFindLen, AForward, [efoProgress, efoChangePos], vRow1, vRow2);
        finally
          if not vFound and (gScrSave <> 0) then begin
            FARAPI.RestoreScreen(gScrSave);
            gScrSave := 0;
          end;
        end;

       {$ifdef bTrace}
        if not vFound then
          TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
       {$endif bTrace}

        if vFound then begin

          Inc(gFoundCount);

          vStrInfo.StringNumber := -1{vRow};
          if FARAPI.EditorControl(ECTL_GETSTRING, @vStrInfo) <> 1 then
            Wrong;
          if vStrInfo.StringLength < vCol + vFindLen then
            Wrong;

          vReplace := True;
          if vPrompt then begin
            { Спрашиваем... }
            GotoPosition(vRow, vCol, vCol + vFindLen, vCol, {ACenter:}True {optCenterAlways}, vEdtInfo.WindowSizeY * 2 div 3);
            LocShow(vRow, vCol, vFindLen);

            SetString(vStr, vStrInfo.StringText + vCol, vFindLen);
            vRes := ShowMessage(GetMsgStr(strConfirm), Format(GetMsgStr(strReplaceWith1), [vStr, AReplStr]) + #10 +
              GetMsgStr(strReplaceBut) + #10 + GetMsgStr(strAllBut) + #10 + GetMsgStr(strSkipBut) + #10 + GetMsgStr(strCancelBut1),
              0 {FMSG_WARNING} {or FMSG_MB_OK}, 4);

            case vRes of
              0: {};
              1: vPrompt := False;
              2: vReplace := False;
            else
              Exit;
            end;

           {$ifdef bTrace}
            vStart := 0;
           {$endif bTrace}
          end else
            { Иначе просто позиционируемся, чтобы лучше работало Undo... }
            GotoPosition(vRow, -1, -1, vCol, False);

          if vReplace then begin
            { Заменяем... }
            vRowLen := vStrInfo.StringLength - vFindLen + vReplLen;
            if vRowLen > vTmpLen then begin
              MemFree(vTmpBuf);
              vTmpBuf := MemAlloc(vRowLen * SizeOf(TChar));
              vTmpLen := vRowLen;
            end;

            StrMove(vTmpBuf, vStrInfo.StringText, vCol);
            StrMove(vTmpBuf + vCol, PTChar(AReplStr), vReplLen);
            StrMove(vTmpBuf + vCol + vReplLen, vStrInfo.StringText + vCol + vFindLen, vStrInfo.StringLength - vCol - vFindLen);

            vStrSet.StringNumber := -1 {vRow};
            vStrSet.StringText := vTmpBuf;
            vStrSet.StringLength := vRowLen;
            vStrSet.StringEOL := vStrInfo.StringEOL;

            FARAPI.EditorControl(ECTL_SETSTRING, @vStrSet);
            if vPrompt then begin
              if optSelectFound then
                SelectClear;
              FARAPI.EditorControl(ECTL_REDRAW, nil);
            end;

            Inc(gReplCount);

            if AForward then
              Inc(vCol, vReplLen)
            else
              Dec(vCol);
          end else
          begin
            { Пропускаем... }
            if AForward then
              Inc(vCol)
            else
              Dec(vCol);
          end

        end else
        begin
          { Вхождение не найдено. Начинаем сначала, или прекращаем поиск... }
          if optLoopSearch and not vLoop then begin

            if gFoundCount > 0 then begin
              if not vPrompt then
                GotoPosition(vRow, vCol, vCol + vFindLen, vCol, {ACenter:}True);
              LocShow(vRow, vCol, -1);
            end;

            if LoopPrompt(AFindStr, AForward) then begin
              if AForward then begin
                vRow := 0;
                vCol := 0;
                vRow1 := 0;
                vRow2 := vStartRow + 1;
              end else
              begin
                vRow := vEdtInfo.TotalLines - 1;
                vCol := MaxInt;
                vRow1 := vStartRow;
                vRow2 := vEdtInfo.TotalLines;
              end;
              gProgressLast := 0;
             {$ifdef bTrace}
              vStart := 0;
             {$endif bTrace}
              vLoop := True;
              Continue;
            end;

          end;

          Break;
        end;

      end {while};

    finally
      if gFoundCount > 0 then begin
        if not vPrompt then
          GotoPosition(vRow, vCol, vCol + vFindLen,
            IntIf(optCursorAtEnd and AForward, vCol + vFindLen, vCol), {ACenter:}True);
        LocShow(vRow, vCol, -1);
      end;

      if optGroupUndo then begin
        vUndoRec.Command := EUR_END;
        FARAPI.EditorControl(ECTL_UNDOREDO, @vUndoRec);
      end;

      MemFree(vTmpBuf);
    end;

    if gFoundCount > 0 then
      ShowMessage(gProgressTitle, Format(gProgressAdd, [gFoundCount, gReplCount]), FMSG_MB_OK)
    else
      ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AFindStr, FMSG_WARNING or FMSG_MB_OK);
  end;


  procedure Replace(APickWord :Boolean);
  var
    vEntire :Boolean;
  begin
    SyncFindStr;
    if not ReplaceDlg(APickWord, vEntire) then
      Exit;
   {$ifdef bAdvSelect}
    EdtClearMark;
   {$endif bAdvSelect}
    gLastIsReplace := True;
    ReplaceStr(gStrFind, gStrRepl, gOptions, vEntire, False, not gReverse);
  end;


  procedure RepeatLast(AForward :Boolean);
  begin
    SyncFindStr;
    if gStrFind = '' then
      Find(False)
    else
    if gLastIsReplace then
      ReplaceStr(gStrFind, gStrRepl, gOptions, False, True, AForward)
    else
      FindStr(gStrFind, gOptions, False, True, AForward);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure RunCommand(ACmd :Integer);
  begin
    case ACmd of
      1: Find(False);
      2: Find(True);
      3: Replace(False);
      4: Replace(True);
      5: RepeatLast(True);
      6: RepeatLast(False);
      7: FindWord(True);
      8: FindWord(False);
      9: PickWord;
     10: EdtClearMark;
    end;
  end;


  procedure OpenMenu;
  const
    cMenuCount = 12;
  var
    vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strMFind));
      SetMenuItemChrEx(vItem, GetMsg(strMFindAt));
      SetMenuItemChrEx(vItem, GetMsg(strMReplace));
      SetMenuItemChrEx(vItem, GetMsg(strMReplaceAt));
      SetMenuItemChrEx(vItem, GetMsg(strMFindNext));
      SetMenuItemChrEx(vItem, GetMsg(strMFindPrev));
      SetMenuItemChrEx(vItem, GetMsg(strMFindWordNext));
      SetMenuItemChrEx(vItem, GetMsg(strMFindWordPrev));
      SetMenuItemChrEx(vItem, GetMsg(strMFindPickWord));
      SetMenuItemChrEx(vItem, GetMsg(strMRemoveHilight), IntIf(gMatchStr <> '', 0, MIF_DISABLE));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strMOptions));

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(strTitle),
        '',
        'MainMenu',
        nil, nil,
        Pointer(vItems),
        cMenuCount);

      if vRes = -1 then
        Exit;

      case vRes of
        0..9:
          RunCommand(vRes + 1);

        11: OptionsMenu;
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
    { Need 2.0.789 }
    Result := $03150200;
  end;
 {$endif bUnicodeFar}


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

//  hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
//  hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

    ReadSetup;
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;
    ConfigMenuStrings: array[0..0] of PFarChar;


  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_DISABLEPANELS or PF_EDITOR {or PF_VIEWER or PF_DIALOG};

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := Pointer(@PluginMenuStrings);

    ConfigMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginConfigStrings := Pointer(@ConfigMenuStrings);
    pi.PluginConfigStringsNumber := 1;

    pi.Reserved := cPluginGUID;
  end;


  procedure ExitFARW; stdcall;
  begin
//  Trace('ExitFAR');
    WriteSetup;
  end;


  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
    try

      if OpenFrom and OPEN_FROMMACRO <> 0 then
        RunCommand(Item and not OPEN_FROMMACRO)
      else
      if OpenFrom in [OPEN_EDITOR] then
        OpenMenu;

    except
      on E :ECtrlBreak do
        {Nothing};
      on E :Exception do
        HandleError(E);
    end;
  end;


  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    Result := 1;
    try
      OptionsMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bAdvSelect}

  function ProcessEditorInputW(const ARec :INPUT_RECORD) :Integer; stdcall;
  begin
//  TraceF('ProcessEditorInputW: Event=%d', [ARec.EventType]);
    if ARec.EventType = 0 then begin
      {???}
    end else
    if ARec.EventType = KEY_EVENT then begin
      with ARec.Event.KeyEvent do begin
        if bKeyDown and not (wVirtualKeyCode in [0, VK_SHIFT, VK_CONTROL, VK_MENU]) then begin
//        TraceF('ProcessEditorInputW (KEY_EVENT): Press=%d, Key=%d', [Byte(bKeyDown), wVirtualKeyCode]);
          EdtClearMark(not optPersistMatch);
        end;
      end;
    end else
    if ARec.EventType = _MOUSE_EVENT then begin
      with ARec.Event.MouseEvent do
        if MOUSE_MOVED and dwEventFlags = 0 then begin
//        TraceF('ProcessEditorInputW (MOUSE_EVENT): Flags=%d', [dwEventFlags]);
          EdtClearMark(not optPersistMatch);
        end
    end;
    Result := 0;
  end;


  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  var
    vChangePos :Boolean;

    procedure EdtSetColor(const ASel :TEdtSelection; AColor :Integer);
    var
      vColor :TEditorColor;
    begin
      if ASel.FLen > 0 then begin

        { Оптимизация, аналогичная установке текущей позиции при поиске.}
        { Без этого тормозит удаление раскраски при "длинных" перескоках, например, с конца в начало. }
        vChangePos := True;
        GotoPosition(ASel.FRow, -1, -1, -1, False);

        vColor.StringNumber := ASel.FRow;
        vColor.ColorItem := 0;
        if AColor <> -1 then begin
          vColor.StartPos := ASel.FCol;
          vColor.EndPos := ASel.FCol + ASel.FLen - 1;
          vColor.Color := AColor or ECF_TAB1;
        end else
        begin
          vColor.StartPos := ASel.FCol;
          vColor.EndPos := ASel.FCol + ASel.FLen - 1;
          vColor.Color := 0;
        end;
        FARAPI.EditorControl(ECTL_ADDCOLOR, @vColor);
      end;
    end;

  var
    I :Integer;
    vInfo :TEditorInfo;
    vHelper :TEdtHelper;
  begin
//  TraceF('ProcessEditorEvent: %d, %x', [AEvent, TIntPtr(AParam)]);
    Result := 0;

    case AEvent of
      EE_CLOSE: begin
        DeleteEdtHelper(Integer(AParam^));
        { Чтобы при следующем поиске отработал SyncFindStr, синхронизируя }
        { поиск в редакторе с файловым поиском }
        gStrFind := '';
      end;

      EE_KILLFOCUS:
        EdtClearMark;

      EE_REDRAW:
        begin
//        TraceF('ProcessEditorEventW: Redraw. What=%d', [TIntPtr(AParam)]);
          if AParam = EEREDRAW_LINE then
            Exit;

          vChangePos := False;
          FARAPI.EditorControl(ECTL_GETINFO, @vInfo);
          vHelper := FindEdtHelper(vInfo.EditorID, False);
          try

            if vHelper <> nil then begin
              if vHelper.FFound.FLen > 0 then begin
                EdtSetColor(vHelper.FFound, -1);
                vHelper.FFound.FLen := 0;
              end;
              if vHelper.FAllFound.Count > 0 then begin
                for I := 0 to vHelper.FAllFound.Count - 1 do
                  EdtSetColor(PEdtSelection(vHelper.FAllFound.PItems[I])^, -1);
                vHelper.FAllFound.Clear;
              end;
            end;

            if AParam = EEREDRAW_CHANGE then begin
//            EdtClearMark({ClearMatches=}True, {Redraw=}False);  { Сбросить }
              gMatchRow2 := 0;  { Поддерживать }
            end;

            if vInfo.EditorID = gEdtID then begin
              if gMatchStr <> '' then
                UpdateMatches(vInfo);

              if (gFound.FLen > 0) or (gMatches <> nil) then begin
                if vHelper = nil then
                  vHelper := FindEdtHelper(vInfo.EditorID, True);

                if gMatches <> nil then
                  for I := 0 to gMatches.Count - 1 do begin
                    EdtSetColor(PEdtSelection(gMatches.PItems[I])^, optMatchColor);
                    vHelper.AddFound(PEdtSelection(gMatches.PItems[I])^);
                  end;

                if gFound.FLen > 0 then begin
                  EdtSetColor(gFound, optCurFindColor);
                  vHelper.FFound := gFound;
                end;
              end;
            end;

          finally
            if vChangePos then
              RestoreOldPos(vInfo);
          end;

        end;
    end;
  end;

 {$endif bAdvSelect}


{$ifdef bAdvSelect}
initialization
  gEdtHelpers := TObjList.Create;

finalization
  FreeObj(gEdtHelpers);
  FreeObj(gMatches);
{$endif bAdvSelect}
end.


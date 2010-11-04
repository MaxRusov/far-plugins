{$I Defines.inc}

unit EdtFinder;

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

    EdtFindCtrl;

  type
    PEdtSelection = ^TEdtSelection;
    TEdtSelection = record
      FRow, FCol, FLen :Integer;
    end;

    PRepPart = ^TRepPart;
    TRepPart = record
      FStr :PTChar;     { указатель на строку замены или nil в случае макроподстановки }
      FLen :Integer;    { Длина строки замены или индекс макроподстановки }
    end;

    TEdtFindOptions = set of (
      efoProgress,      { Показывать прогресс-индикатор во время поиска }
      efoCalcCount,     { Подсчитываем количество вхождений }
      efoOnePerRow      { Ищем только одно вхождение на строку (для grep'а) }
    );

    TFinder = class(TBasis)
    public
      constructor CreateEx(const AExpr :TString; AOpt :TFindOptions);
      destructor Destroy; override;

      function Find(AStr :PTChar; ALen :Integer; AForward :Boolean; var ADelta, AFindLen :Integer) :Boolean;

      function EdtFind(var ARow, ACol, AFindLen :Integer; AForward :Boolean; AddOpt :TEdtFindOptions;
        ARow1, ARow2 :Integer; AResults :TExList = nil) :Boolean;

      procedure PrepareReplace(const ARepStr :TString);
      procedure Replace(ASrcStr :PTChar; ASrcLen :Integer; const ARepStr :TString);

    private
      FOpt       :TFindOptions;
      FOrig      :TString;
      FExpr      :TString;
      FExprLen   :Integer;

      FTmpBuf    :PTChar;
      FTmpLen    :Integer;

      FRegExp    :THandle;
      FBrackets  :Integer;
      FMatches   :array of TRegExpMatch;

      { Поддержка замены }
      FRepExpr   :TString;
      FRepList   :TExList;

      FRepBeg    :Integer;    { Начальная позиция заменяющего фрагмента }
      FRepLen    :Integer;    { Длина заменяющего фрагмента }
      FResStrLen :Integer;    { Длина итоговой строки }

      FRepBuf    :PTChar;
      FRepBufLen :Integer;

    public
      property RepBuf :PTChar read FRepBuf;
      property RepBeg :Integer read FRepBeg;
      property RepLen :Integer read FRepLen;
      property ResStrLen :Integer read FResStrLen;
    end;


  var
    gProgressTitle :TString;
    gProgressLast :DWORD;
    gProgressAdd :TString;
    gFoundCount :Integer;
    gReplCount :Integer;
    gScrSave :THandle;


  procedure InitFind(const ATitle, AAddStr :TString);

  function EditorFind(const AStr :TString; AOpt :TFindOptions; var ARow, ACol, AFindLen :Integer; AForward :Boolean; AddOpt :TEdtFindOptions;
    ARow1, ARow2 :Integer; AResults :TExList = nil) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


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

  constructor TFinder.CreateEx(const AExpr :TString; AOpt :TFindOptions);
  begin
//  TRaceF('TFinder.CreateEx: %s', [AExpr]);
    
    FOrig := AExpr;
    FOpt := AOpt;

    if not (foRegexp in AOpt) then begin
      if not (foCaseSensitive in AOpt) then
        FExpr := StrUpCase(AExpr)
      else
        FExpr := AExpr;
      FExprLen := length(AExpr);
      FBrackets := 1;
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
    end;

    SetLength(FMatches, FBrackets);
  end;


  destructor TFinder.Destroy; {override;}
  begin
    MemFree(FTmpBuf);
    MemFree(FRepBuf);
    FreeObj(FRepList);
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
      vExprLen := 0
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
      vRegExp.Match := @FMatches[0];
      vRegExp.Count := FBrackets;
      vRegExp.Reserved := nil;

      if AForward then begin
        if FARAPI.RegExpControl(FRegExp, RECTL_SEARCHEX, @vRegExp) = 1 then begin
          ADelta := FMatches[0].Start;
          AFindLen := FMatches[0].EndPos - FMatches[0].Start;
          Result := True;
        end;
      end else
      begin
        while True do begin
          vRegExp.Position := ADelta;

          if FARAPI.RegExpControl(FRegExp, RECTL_MATCHEX, @vRegExp) = 1 then begin
            ADelta := FMatches[0].Start;
            AFindLen := FMatches[0].EndPos - FMatches[0].Start;
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

      if Result then begin
        { Заполняем FMatches, чтобы "прозрачно" работало Replace }
        FMatches[0].Start := ADelta;
        FMatches[0].EndPos := ADelta + FExprLen;
        AFindLen := FExprLen;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure CheckInterrupt;
  begin
    if CheckForEsc then
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt) + #10#10 + GetMsgStr(strYes) + #10 + GetMsgStr(strNo), FMSG_WARNING, 2) = 0 then
        CtrlBreakException
  end;


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


  function TFinder.EdtFind(var ARow, ACol, AFindLen :Integer; AForward :Boolean; AddOpt :TEdtFindOptions;
    ARow1, ARow2 :Integer; AResults :TExList = nil) :Boolean;
  var
    vEdtInfo :TEditorInfo;
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

    try
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
          LocShowMessage(FOrig, (100 * vRow) div vEdtInfo.TotalLines);
//        LocShowMessage(FOrig, (100 * (vRow - vBegRow)) div (vEndRow - vBegRow));

        vStrInfo.StringNumber := vRow;
        if FARAPI.EditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
//        if soSelectedOnly in Options then begin
//          FBlock.ColRange(Loc.Row, Col1, Col2);
//          MaxLimit(Col2, ERow.Len + 1);
//        end else
          begin
            vCol1 := 0;
            vCol2 := vStrInfo.StringLength;
          end;

          if vCol2 >= vCol1 then begin
            vDelta := vCol - vCol1; { Может быть меньше 0 и больше (Col2 - Col1) - так и задумано. }
            if Find(vStrInfo.StringText + vCol1, vCol2 - vCol1, AForward, vDelta, vLen) then begin
              if AResults <> nil then begin
                if efoCalcCount in AddOpt then
                  Inc(gFoundCount);
                vSel.FRow := vRow;
                vSel.FCol := vCol1 + vDelta;
                vSel.FLen := vLen;
                AResults.AddData(vSel);
                if efoOnePerRow in AddOpt then begin
                  vCol := 0;
                  Inc(vRow);
                end else
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
      if vLocalProgress then begin
        gProgressLast := 0;
        if gScrSave <> 0 then begin
          FARAPI.RestoreScreen(gScrSave);
          gScrSave := 0;
        end;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFinder.PrepareReplace(const ARepStr :TString);

    procedure LocAdd(AStr :PTChar; ALen :Integer);
    begin
      with PRepPart(FRepList.NewItem(FRepList.Count))^ do begin
        FStr := AStr;
        FLen := ALen
      end;
    end;

  var
    vPtr, vBeg :PTChar;
  begin
    FRepExpr := ARepStr;
    if FRepList = nil then
      FRepList := TExList.CreateSize(SizeOf(TRepPart));

    vPtr := PTChar(FRepExpr);
    vBeg := vPtr;
    while vPtr^ <> #0 do begin
      if vPtr^ = '$' then begin
        if vPtr > vBeg then
          LocAdd(vBeg, vPtr - vBeg);
        Inc(vPtr);
        if vPtr^ <> #0 then begin
          case vPtr^ of
            '0'..'9':
              LocAdd(nil, Ord(vPtr^) - Ord('0'));
          else
            LocAdd(vPtr, 1);
          end;
          Inc(vPtr);
          vBeg := vPtr;
        end;
      end else
        inc(vPtr);
    end;

    if vPtr > vBeg then
      LocAdd(vBeg, vPtr - vBeg);
  end;


  procedure TFinder.Replace(ASrcStr :PTChar; ASrcLen :Integer; const ARepStr :TString);

    procedure LocAdd(AStr :PTChar; ALen :Integer);
    begin
      if ALen > 0 then begin
        if FResStrLen + ALen > FRepBufLen then begin
          ReallocMem(FRepBuf, (FResStrLen + ALen) * SizeOf(TChar));
          FRepBufLen := FResStrLen + ALen;
        end;

        StrMove(FRepBuf + FResStrLen, AStr, ALen);
        Inc(FResStrLen, ALen);
      end;
    end;

  var
    I :Integer;
  begin
    if ASrcLen < FMatches[0].EndPos then
      Wrong;

    FResStrLen := 0;

    LocAdd(ASrcStr, FMatches[0].Start);
    FRepBeg := FResStrLen;

    if foRegexp in FOpt then begin
      for I := 0 to FRepList.Count - 1 do
        with PRepPart(FRepList.PItems[I])^ do
          if FStr = nil then begin
            if FLen < FBrackets then
              LocAdd(ASrcStr + FMatches[FLen].Start, FMatches[FLen].EndPos - FMatches[FLen].Start);
          end else
            LocAdd(FStr, FLen);
      FRepLen := FResStrLen - FRepBeg;
    end else
    begin
      FRepLen := length(ARepStr);
      LocAdd(PTChar(ARepStr), FRepLen);
    end;

    LocAdd(ASrcStr + FMatches[0].EndPos, ASrcLen - FMatches[0].EndPos);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure InitFind(const ATitle, AAddStr :TString);
  begin
    gScrSave := 0;
    gProgressLast := 0;
    gFoundCount := 0;
    gReplCount := 0;
    gProgressTitle := ATitle;
    gProgressAdd := AAddStr;
  end;


  function EditorFind(const AStr :TString; AOpt :TFindOptions; var ARow, ACol, AFindLen :Integer; AForward :Boolean; AddOpt :TEdtFindOptions;
    ARow1, ARow2 :Integer; AResults :TExList = nil) :Boolean;
  var
    vFinder :TFinder;
  begin
    vFinder := TFinder.CreateEx(AStr, AOpt);
    try
      Result := vFinder.EdtFind(ARow, ACol, AFindLen, AForward, AddOpt, ARow1, ARow2, AResults);
    finally
      FreeObj(vFinder);
    end;
  end;


end.


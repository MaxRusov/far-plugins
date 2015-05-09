{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}

{$Define bFastCompare}

{$Define bFastCompareRow}
{-$Define bSpaceSync}

unit VisCompTexts;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
   {$ifdef bFastCompare}
    MixCRC,
   {$endif bFastCompare}

    VisCompCtrl;


  const
//  cTextBegFactor = 16;  // 16..8..4..2..1
    cTextBegFactor =  8;  // 8..4..2..1
    cTextMinFactor =  1;

    cStrBegFactor  = 8;   // 8..4..2..1
    cStrMinFactor  = 1;

//  cStrBegFactor  = 12;  // 12..6..3
//  cStrMinFactor  = 3;


  type
    TText = class;
    TRowDiff = class;

    TRowsPair = array[0..1] of Integer;
    TTextsPair = array[0..1] of TText;

    PCmpTextRow = ^TCmpTextRow;
    TCmpTextRow = packed record
      FRow     :TRowsPair;
      FFlags   :Integer;
      FRowDiff :TRowDiff;
    end;


    TText = class(TStrList)
    public
      constructor CreateEx(const AName :TString);
      constructor CreateStr(const AStr :TString; ADummy :Integer);
      procedure LoadFile(AForceFormat :TStrFileFormat);

    private
      FName     :TString;
      FViewName :TString;
      FFormat   :TStrFileFormat;
      FWasZero  :Boolean;

      procedure StrToText(const AStr :TString);

    public
      property Name :TString read FName;
      property ViewName :TString read FViewName write FViewName;
      property Format :TStrFileFormat read FFormat;
    end;

    TStrCompareRes = (
      scrEqual,      { Строки совпадают }
      scrSimilar,    { Строки различаются только пробелами или регистром }
      scrDiff        { Строки различаюися }
    );

    TTextDiff = class(TBasis)
    public
      constructor CreateEx(const AName1, AName2 :TString);
      destructor Destroy; override;

      procedure Compare;
      procedure Optimization;
      procedure ReloadAndCompare;

      function GetRowDiff(I :Integer) :TRowDiff;

    private
      FDiff   :TExList;
      FText   :TTextsPair;

     {$ifdef bFastCompare}
      FTextCRCs1, FTextCRCs2 :TIntList;
      FIndexes1, FIndexes2 :TIntList;
     {$endif bFastCompare}

     {$ifdef bTrace}
      FRowCompare :Integer;
     {$endif bTrace}

      function CompareRows(ARow1, ARow2, AEndRow1, AEndRow2, ACount :Integer) :Boolean;

     {$ifdef bFastCompare}
      procedure CalcCRCs;
      procedure ReindexCRCs;
      function CalcStrCRC(AStr :PTChar) :TCRC;
     {$endif bFastCompare}

      function GetDiffCount :Integer;
      function GetCmpItems(I :Integer) :PCmpTextRow;

    public
      property DiffCount :Integer read GetDiffCount;
      property CmpItems[I :Integer] :PCmpTextRow read GetCmpItems; default;
      property Text :TTextsPair read FText;
    end;


    TRowDiff = class(TBasis)
    public
      constructor CreateEx(AStr1, AStr2 :PTChar);
      destructor Destroy; override;

      procedure Compare(AAStr1, AAStr2 :PTChar);

      function GetDiffBits(AVer :Integer) :TBits;

    private
      FDiff1 :TBits;
      FDiff2 :TBits;

     {$ifdef bFastCompareRow}
      FUpStr1, FUpStr2 :PTChar;
      FIndexes1, FIndexes2 :TIntList;

      procedure Reindex(ASrc :PTChar; ALen :Integer; var AUpStr :PTChar; var AIndex :TIntList);
     {$endif bFastCompareRow}

      function CompareChars(AStr1, AStr2, AEnd1, AEnd2 :PTChar; AFactor :Integer) :Boolean;
      function CompareChrEx(AChr1, AChr2 :TChar) :TStrCompareRes;
    end;


  function RowIsEmpty(AStr :PTChar) :Boolean;
  function CompareStrEx(AStr1, AStr2 :PTChar) :TStrCompareRes;

  function CharIsSpace(AChr :TChar) :Boolean;
  function CharIsCRLF(AChr :TChar) :Boolean;
  function GetTextDiffs(const AName1, AName2 :TString) :TTextDiff;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function CharIsSpace(AChr :TChar) :Boolean;
  begin
    Result := (AChr = ' ') or (AChr = #9);
  end;


  function CharIsCRLF(AChr :TChar) :Boolean;
  begin
    Result := (AChr = #13) or (AChr = #10);
  end;


  function CharIsEmpty(AChr :TChar) :Boolean;
  begin
    Result := (AChr = ' ') or (AChr = #9) or (AChr = #13) or (AChr = #10);
  end;


  function RowIsEmpty(AStr :PTChar) :Boolean;
  begin
    while CharIsEmpty(AStr^) do
      Inc(AStr);
    Result := AStr^ = #0;
  end;


  function CompareStrEx(AStr1, AStr2 :PTChar) :TStrCompareRes;
  begin
    Result := scrEqual;
    while (AStr1^ <> #0) or (AStr2^ <> #0) do begin
      if AStr1^ = AStr2^ then begin
        Inc(AStr1);
        Inc(AStr2);
      end else
      begin
        if CharIsSpace(AStr1^) or CharIsSpace(AStr2^) then begin
          while CharIsSpace(AStr1^) do
            Inc(AStr1);
          while CharIsSpace(AStr2^) do
            Inc(AStr2);
          if not optTextIgnoreSpace then
            Result := scrSimilar;
        end else
        if CharIsCRLF(AStr1^) or CharIsCRLF(AStr2^) then begin
          while CharIsCRLF(AStr1^) do
            Inc(AStr1);
          while CharIsCRLF(AStr2^) do
            Inc(AStr2);
          if not optTextIgnoreCRLF then
            Result := scrSimilar;
        end else
        begin
          if CharUpCase(AStr1^) = CharUpCase(AStr2^) then begin
            Inc(AStr1);
            Inc(AStr2);
            if not optTextIgnoreCase then
              Result := scrSimilar;
          end else
          begin
            Result := scrDiff;
            Exit;
          end;
        end;
      end;
    end;
  end;


  function StrZeroToSpace(var AStr :TString) :Boolean;
  var
    I :Integer;
  begin
    Result := False;
    for I := 1 to Length(AStr) do
      if AStr[I] = #0 then begin
        AStr[I] := ' ';
        Result := True;
      end;
  end;


  procedure LocCorrectFactor(var AFactor :Integer; ADelta1, ADelta2 :Integer);
    { Фактор не может превышать размеры максимальной сравниваемой области }
  var
    vMin :Integer;
  begin
    vMin := IntMin(ADelta1, ADelta2);
    if vMin = 0 then
      Exit;
    while (AFactor > 1) and (AFactor > vMin) do
      AFactor := AFactor div 2;
  end;

 {-----------------------------------------------------------------------------}
 { TText                                                                       }
 {-----------------------------------------------------------------------------}

  constructor TText.CreateEx(const AName :TString);
  begin
    Create;
    FName := AName;
    LoadFile(sffAuto);
  end;


  constructor TText.CreateStr(const AStr :TString; ADummy :Integer);
  begin
    Create;
    StrToText(AStr);
  end;

  
  procedure TText.LoadFile(AForceFormat :TStrFileFormat);
  var
    vStr :TString;
  begin
    FFormat := AForceFormat;
    if FFormat = sffAuto then begin
      FFormat := StrDetectFormat(FName);
      if FFormat = sffAnsi then
        FFormat := optDefaultFormat;
    end;

    vStr := StrFromFile(FName, FFormat, AForceFormat = sffAuto);

    FWasZero := StrZeroToSpace(vStr);

    StrToText(vStr);
  end;


  procedure TText.StrToText(const AStr :TString);
  var
    vPtr, vBeg :PTChar;
    vStr :TString;
  begin
    Clear;
    vPtr := PTChar(AStr);
    while vPtr^ <> #0 do begin
      vBeg := vPtr;
      while (vPtr^ <> #0) and (vPtr^ <> #10) and (vPtr^ <> #13) do
        Inc(vPtr);
      if vPtr^ = #13 then
        Inc(vPtr);
      if vPtr^ = #10 then
        Inc(vPtr);
      SetString(vStr, vBeg, vPtr - vBeg);
      Add(vStr);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TDiffList                                                                   }
 {-----------------------------------------------------------------------------}

 type
   TDiffList = class(TExList)
   public
     constructor Create; override;
   protected
      procedure ItemFree(PItem :Pointer); override;
   end;


  constructor TDiffList.Create; {override;}
  begin
    inherited Create;
    FItemSize  := SizeOf(TCmpTextRow);
    FItemLimit := MaxInt div FItemSize;
    FOptions := [loItemFree];
  end;


  procedure TDiffList.ItemFree(PItem :Pointer); {override;}
  begin
    FreeObj(PCmpTextRow(PItem).FRowDiff);
  end;


 {-----------------------------------------------------------------------------}
 { TTextIndex                                                                  }
 {-----------------------------------------------------------------------------}

 {$ifdef bFastCompare}
  type
    TTextIndex = class(TIntList)
    public
      constructor CreateEx(ATextCRCs :TIntList);
      function FindFirst(AKey :TInt32; AFirstRow :Integer) :Integer;

    protected
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;
      function ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FTextCRCs :TIntList
    end;


  constructor TTextIndex.CreateEx(ATextCRCs :TIntList);
  begin
    Create;
    FTextCRCs := ATextCRCs;
  end;


  function TTextIndex.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vRow1, vRow2 :Integer;
  begin
    vRow1 := PIntPtr(PItem)^;
    vRow2 := PIntPtr(PAnother)^;
    Result := IntCompare( FTextCRCs[vRow1], FTextCRCs[vRow2] );
    if Result = 0 then
      Result := IntCompare( vRow1, vRow2 );
  end;


  function TTextIndex.ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vRow :Integer;
  begin
    vRow := PIntPtr(PItem)^;
    Result := IntCompare( FTextCRCs[vRow], PPoint(Key).x );
    if Result = 0 then
      Result := IntCompare( vRow, PPoint(Key).y );
  end;


  function TTextIndex.FindFirst(AKey :TInt32; AFirstRow :Integer) :Integer;
  var
    vIndex, vRow :Integer;
    vKey :TPoint;
  begin
    Result := -1;
    vKey.x := AKey;
    vKey.y := AFirstRow;
    FindKey(@vKey, 0, [foBinary], vIndex);
    if vIndex < Count then begin
      vRow := Items[vIndex];
      if (FTextCRCs[vRow] = AKey) and (vRow >= AFirstRow) then
        Result := vIndex;
    end;
  end;
 {$endif bFastCompare}


 {-----------------------------------------------------------------------------}
 { TRowIndex                                                                   }
 {-----------------------------------------------------------------------------}

 {$ifdef bFastCompareRow}
  type
    TRowIndex = class(TIntList)
    public
      constructor CreateEx(ARowStr :PTChar);
      function FindFirst(AChr :TChar; AFirstPos :Integer) :Integer;

    protected
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;
      function ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FRowStr :PTChar;
    end;


  constructor TRowIndex.CreateEx(ARowStr :PTChar);
  begin
    Create;
    FRowStr := ARowStr;
  end;


  function TRowIndex.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vPos1, vPos2 :Integer;
  begin
    vPos1 := PIntPtr(PItem)^;
    vPos2 := PIntPtr(PAnother)^;
    Result := IntCompare( Word((FRowStr + vPos1)^), Word((FRowStr + vPos2)^) );
    if Result = 0 then
      Result := IntCompare( vPos1, vPos2 );
  end;


  function TRowIndex.ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vPos :Integer;
  begin
    vPos := PIntPtr(PItem)^;
    Result := IntCompare( Word((FRowStr + vPos)^), PPoint(Key).x );
    if Result = 0 then
      Result := IntCompare( vPos, PPoint(Key).y );
  end;


  function TRowIndex.FindFirst(AChr :TChar; AFirstPos :Integer) :Integer;
  var
    vIndex, vPos :Integer;
    vKey :TPoint;
  begin
    Result := -1;
    vKey.x := Word(AChr);
    vKey.y := AFirstPos;
    FindKey(@vKey, 0, [foBinary], vIndex);
    if vIndex < Count then begin
      vPos := Items[vIndex];
      if ((FRowStr + vPos)^ = AChr) and (vPos >= AFirstPos) then
        Result := vIndex;
    end;
  end;
 {$endif bFastCompareRow}


 {-----------------------------------------------------------------------------}
 { TTextDiff                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TTextDiff.CreateEx(const AName1, AName2 :TString);
  begin
    Create;
    FText[0] := TText.CreateEx(AName1);
    FText[1] := TText.CreateEx(AName2);
    FDiff := TDiffList.Create;
   {$ifdef bFastCompare}
    FTextCRCs1 := TIntList.Create;
    FTextCRCs2 := TIntList.Create;
    FIndexes1 := TTextIndex.CreateEx(FTextCRCs1);
    FIndexes2 := TTextIndex.CreateEx(FTextCRCs2);
   {$endif bFastCompare}
    Compare;
  end;


  destructor TTextDiff.Destroy; {override;}
  begin
   {$ifdef bFastCompare}
    FreeObj(FTextCRCs1);
    FreeObj(FTextCRCs2);
    FreeObj(FIndexes1);
    FreeObj(FIndexes2);
   {$endif bFastCompare}
    FreeObj(FText[0]);
    FreeObj(FText[1]);
    FreeObj(FDiff);
    inherited Destroy;
  end;


  procedure TTextDiff.ReloadAndCompare;
  begin
    FText[0].LoadFile(FText[0].FFormat);
    FText[1].LoadFile(FText[1].FFormat);
    Compare;
  end;


  procedure TTextDiff.Compare;

    procedure AppedRows(ARow1, ARow2, ACount :Integer; AFlags :Integer = 1);
    var
      I :Integer;
    begin
      for I := 0 to ACount - 1 do
        with PCmpTextRow(FDiff.NewItem(FDiff.Count))^ do begin
          FRow[0] := IntIf(ARow1 <> -1, ARow1 + I, -1);
          FRow[1] := IntIf(ARow2 <> -1, ARow2 + I, -1);
          FFlags := AFlags;
          FRowDiff := nil;
        end;
    end;


    procedure ComparePart(ABegRow1, ABegRow2, AEndRow1, AEndRow2 :Integer; AFactor :Integer);


      procedure LocAddDiffs(var ARow1, ARow2 :Integer; ACount1, ACount2 :Integer);
      var
        I, vAdd1, vAdd2 :Integer;
        vMinRows, vMaxRows :Integer;
      begin
        vMinRows := IntMin( ACount1, ACount2 );
        vMaxRows := IntMax( ACount1, ACount2 );

        if (AFactor > cTextMinFactor) and (vMinRows > 0) and (vMaxRows > 1) then begin
          { Рекурсивно попробуем с меньшим фактором... }
          ComparePart(ARow1, ARow2, ARow1 + ACount1, ARow2 + ACount2, AFactor div 2);
          Inc(ARow1, ACount1);
          Inc(ARow2, ACount2);
        end else
        begin
          if optOptimization1 then begin
            while (ACount1 > 0) and (RowIsEmpty(FText[0].StrPtrs[ARow1])) do begin
              AppedRows(ARow1, -1, 1, IntIf(optTextIgnoreEmptyLine, 0, 1));
              Inc(ARow1);
              Dec(ACount1);
            end;
            while (ACount2 > 0) and (RowIsEmpty(FText[1].StrPtrs[ARow2])) do begin
              AppedRows(-1, ARow2, 1, IntIf(optTextIgnoreEmptyLine, 0, 1));
              Inc(ARow2);
              Dec(ACount2);
            end;
          end;

          vAdd1 := 0; vAdd2 := 0;
          if optOptimization2 then begin
            while (ACount1 > 0) and (RowIsEmpty(FText[0].StrPtrs[ARow1 + ACount1 - 1])) do begin
              Inc(vAdd1);
              Dec(ACount1);
            end;
            while (ACount2 > 0) and (RowIsEmpty(FText[1].StrPtrs[ARow2 + ACount2 - 1])) do begin
              Inc(vAdd2);
              Dec(ACount2);
            end;
          end;

          vMinRows := IntMin( ACount1, ACount2 );

          if (ACount1 > 0) and (ACount2 > 0) then begin
            AppedRows(ARow1, ARow2, vMinRows);
            Inc(ARow1, vMinRows); Dec(ACount1, vMinRows);
            Inc(ARow2, vMinRows); Dec(ACount2, vMinRows);
          end;
          if ACount1 > 0 then begin
            AppedRows(ARow1, -1, ACount1);
            Inc(ARow1, ACount1);
          end;
          if ACount2 > 0 then begin
            AppedRows(-1, ARow2, ACount2);
            Inc(ARow2, ACount2);
          end;

          if optOptimization2 then begin
            for I := 0 to vAdd1 - 1 do begin
              AppedRows(ARow1, -1, 1, IntIf(optTextIgnoreEmptyLine, 0, 1));
              Inc(ARow1);
            end;
            for I := 0 to vAdd2 - 1 do begin
              AppedRows(-1, ARow2, 1, IntIf(optTextIgnoreEmptyLine, 0, 1));
              Inc(ARow2);
            end;
          end;
        end;
      end;


     {$ifdef bFastCompare}

      { Двоичный взаимный поиск. }

      function LocResync(ARow1, ARow2 :Integer; var ADelta1, ADelta2 :Integer) :Boolean;
      var
        vBest :Integer;

        procedure LocFind(AVer :Integer; ABaseDelta, ASrcRow :Integer; AKey :TInt32; AIndex :TTextIndex; ABegRow, AEndRow :Integer);
        var
          vIndex, vRow, vRow1, vRow2, vDelta :Integer;
        begin
          if AKey = 0 then
            Exit; { Пустая строка }

//        TraceF('%d. %d: %s', [AVer, ASrcRow, FText[AVer][ASrcRow]]);

          vIndex := AIndex.FindFirst(AKey, ABegRow);
          if vIndex <> -1 then begin

            vRow1 := ASrcRow;
            vRow2 := ASrcRow;

            vRow := AIndex[vIndex];
            while True do begin
              if vRow >= AEndRow then
                Break;
              if ABaseDelta + vRow - ABegRow >= vBest then
                Break; { Лучше уже не будет... }

              if AVer = 0 then
                vRow2 := vRow
              else
                vRow1 := vRow;

              { Найденная по CRC строка сравнивается повторно, так как CRC мог совпасть случайно... }
              if CompareRows(vRow1, vRow2, AEndRow1, AEndRow2, AFactor) then begin

                while (vRow1 > ARow1) and (vRow2 > ARow2) and (FTextCRCs1[vRow1 - 1] = 0) and (FTextCRCs2[vRow2 - 1] = 0) do begin
                  Dec(vRow1);
                  Dec(vRow2);
                end;

                vDelta := ABaseDelta + vRow - ABegRow;
                if vDelta < vBest then begin
                  vBest := vDelta;
                  ADelta1 := vRow1 - ARow1;
                  ADelta2 := vRow2 - ARow2;
                  Result := True;
                  Break;
                end;
              end;

              if vIndex >= AIndex.Count - 1 then
                Break;
              Inc(vIndex);
              vRow := AIndex[vIndex];
              if AIndex.FTextCRCs[vRow] <> AKey then
                Break;
            end;

          end;
        end;

      var
        I :Integer;
      begin
//      TraceF('Resync: %d %d, Factor: %d', [ARow1, ARow2, AFactor]);
        Result := False;

        vBest := MaxInt;
        for I := 0 to IntMin(AEndRow1 - ARow1, AEndRow2 - ARow2) - 1 do begin
          if I > vBest then
            Break; { Лучше уже не будет... }
          if ARow1 + I < AEndRow1 then
            LocFind( 0, I, ARow1 + I, FTextCRCs1[ARow1 + I], TTextIndex(FIndexes2), ARow2 + I, AEndRow2 );
          if ARow2 + I < AEndRow2 then
            LocFind( 1, I, ARow2 + I, FTextCRCs2[ARow2 + I], TTextIndex(FIndexes1), ARow1 + I, AEndRow1 );
        end;
      end;

     {$else}

      { Линейный взаимный поиск. Очень тормозит на больших разрывах. }

      function LocResync(ARow1, ARow2 :Integer; var ADelta1, ADelta2 :Integer) :Boolean;

        function LocCompare(AD1, AD2 :Integer) :Boolean;
        begin
          Result := CompareRows(ARow1 + AD1, ARow2 + AD2, AEndRow1, AEndRow2, AFactor);
          if Result then begin
            ADelta1 := AD1;
            ADelta2 := AD2;
          end;
        end;

      var
        I, J :Integer;
      begin
        Result := True;
        for I := 1 to IntMax(AEndRow1 - ARow1, AEndRow2 - ARow2) do begin
          for J := 0 to I - 1 do begin
            if LocCompare(J, I) then
              Exit;
            if LocCompare(I, J) then
              Exit;
          end;
          if LocCompare(I, I) then
            Exit;
        end;
        Result := False;
      end;

     {$endif bFastCompare}

    var
      vRow1, vRow2, vDelta1, vDelta2 :Integer;
      vRes :TStrCompareRes;
      vPtr1, vPtr2 :PTChar;
    begin
      LocCorrectFactor(AFactor, AEndRow1 - ABegRow1, AEndRow2 - ABegRow2);
//    TraceF('Compare: %d(%d) x %d(%d), Factor=%d', [ABegRow1, AEndRow1-ABegRow1, ABegRow2, AEndRow2-ABegRow2, AFactor]);

      vRow1 := ABegRow1;
      vRow2 := ABegRow2;
      while True do begin
        if (vRow1 >= AEndRow1) or (vRow2 >= AEndRow2) then
          Break;

        vPtr1 := FText[0].StrPtrs[vRow1];
        vPtr2 := FText[1].StrPtrs[vRow2];

       {$ifdef bTrace}
        Inc(FRowCompare);
       {$endif bTrace}
        vRes := CompareStrEx(vPtr1, vPtr2);

        if vRes in [scrEqual, scrSimilar] then begin
          AppedRows(vRow1, vRow2, 1, IntIf(vRes = scrSimilar, 1, 0));
          Inc(vRow1);
          Inc(vRow2);
        end else
        begin
          { Пробуем восстановить синхронизацию с фактором совпадения AFactor }
          { Используем взаимный поиск... }
          if not LocResync(vRow1, vRow2, vDelta1, vDelta2) then
            Break;

          { Добавляем несовпадающий диапазон }
          LocAddDiffs(vRow1, vRow2, vDelta1, vDelta2);
        end;
      end;

      { Добавляем хвосты, как несовпадающий диапазон }
      LocAddDiffs(vRow1, vRow2, AEndRow1 - vRow1, AEndRow2 - vRow2);
    end;

 {$ifdef bTrace}
  var
    vStart :DWORD;
 {$endif bTrace}
  begin
   {$ifdef bTrace}
    Trace('Compare...');
    vStart := GetTickCount;
   {$endif bTrace}

    FDiff.Clear;
   {$ifdef bFastCompare}
    CalcCrcs;
    ReindexCRCs;
   {$endif bFastCompare}

    ComparePart(0, 0, FText[0].Count, FText[1].Count, cTextBegFactor);
//  OptimizeEmptyLines;

    if optPostOptimization then
      Optimization;

   {$ifdef bTrace}
    TraceF('  done: %d compares, %d ms', [FRowCompare, TickCountDiff(GetTickCount, vStart)]);
   {$endif bTrace}
  end;



  function TTextDiff.CompareRows(ARow1, ARow2, AEndRow1, AEndRow2, ACount :Integer) :Boolean;
  var
    vPtr1, vPtr2 :PTChar;
  begin
    Result := False;
    while ACount > 0 do begin
      if (ARow1 >= AEndRow1) or (ARow2 >= AEndRow2) then
        Exit;
      vPtr1 := FText[0].StrPtrs[ARow1];
      vPtr2 := FText[1].StrPtrs[ARow2];

     {$ifdef bTrace}
      Inc(FRowCompare);
     {$endif bTrace}
      if CompareStrEx(vPtr1, vPtr2) = scrDiff then begin

        if RowIsEmpty(vPtr1) then begin
          Inc(ARow1);
          Continue;
        end;
        if RowIsEmpty(vPtr2) then begin
          Inc(ARow2);
          Continue;
        end;

        Result := False;
        Exit;
      end;
      Inc(ARow1);
      Inc(ARow2);
      if not RowIsEmpty(vPtr1) then
        Dec(ACount);
    end;
    Result := True;
  end;


  function TTextDiff.GetDiffCount :Integer;
  begin
    Result := FDiff.Count;
  end;


  function TTextDiff.GetCmpItems(I :Integer) :PCmpTextRow;
  begin
    Result := FDiff.PItems[I];
  end;


  function TTextDiff.GetRowDiff(I :Integer) :TRowDiff;
  var
    vItem :PCmpTextRow;
  begin
    Result := nil;
    vItem := GetCmpItems(I);
    if (vItem.FRow[0] <> -1) and (vItem.FRow[1] <> -1) and (vItem.FFlags <> 0) then begin

      if vItem.FRowDiff = nil then
        vItem.FRowDiff := TRowDiff.CreateEx( FText[0].StrPtrs[vItem.FRow[0]], FText[1].StrPtrs[vItem.FRow[1]] );

      Result := vItem.FRowDiff;
    end;
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bFastCompare}
  function TTextDiff.CalcStrCRC(AStr :PTChar) :TCRC;
    { При подсчете CRC строки приводятся к верхнему регистру и выбрасываются все пробельные символы }
  const
    cBufSize = 256;
  var
    vBuf :Array[0..cBufSize - 1] of TChar;
    vPart :Integer;

    procedure LocAddCRC;
    begin
      CharUpperBuff(@vBuf[0], vPart);
      Result := CalcCRC32(@vBuf, vPart * SizeOf(TChar), Result);
    end;

  begin
    while CharIsEmpty(AStr^) do
      Inc(AStr);

    if AStr^ = #0 then begin
      Result := 0;
      Exit;
    end;

    Result := TCRC(-1);
    vPart := 0;
    while AStr^ <> #0 do begin

      if CharIsEmpty(AStr^) then begin
        while CharIsEmpty(AStr^) do
          Inc(AStr);
        if AStr^ = #0 then
          Break;
//      vBuf[vPart] := ' ';
//      Inc(vPart);
      end else
      begin
        vBuf[vPart] := AStr^;
        Inc(vPart);
        Inc(AStr);
      end;

      if vPart = cBufSize then begin
        LocAddCRC;
        vPart := 0;
      end;
    end;

    if vPart > 0 then
      LocAddCRC;

    if Result = 0 then
      Result := TCRC(-1); { Чтобы случайно не совпало с пустой строкой }
  end;


  procedure TTextDiff.CalcCrcs;

    procedure LocCalc(AText :TText; ACRCs :TIntList);
    var
      I :Integer;
      vCRC :TCRC;
    begin
      ACRCs.Clear;
      ACRCs.Capacity := AText.Count;
      for I := 0 to AText.Count - 1 do begin
        vCRC := CalcStrCRC(AText.StrPtrs[I]);
//      if vCRC <> 0 then
          ACRCs.Add( Integer(vCRC) );
      end;
    end;

  begin
//  Trace('Calc CRCs...');

    LocCalc(FText[0], FTextCRCs1);
    LocCalc(FText[1], FTextCRCs2);

//  Trace('...done');
  end;


  procedure TTextDiff.ReindexCRCs;

    procedure LocReindex(AIndex :TIntList; ACRCs :TIntList);
    var
      I :Integer;
    begin
      AIndex.Clear;
      AIndex.Capacity := ACRCs.Count;
      for I := 0 to ACRCs.Count - 1 do
        AIndex.Add( I );
      AIndex.SortList(True, 0);
    end;

  begin
//  Trace('Reindex CRCs...');

    LocReindex(FIndexes1, FTextCRCs1);
    LocReindex(FIndexes2, FTextCRCs2);

//  Trace('...done');
  end;
 {$endif bFastCompare}


 {-----------------------------------------------------------------------------}

  procedure TTextDiff.Optimization;


    function TryMoveForward(aSide :Integer; aIdx1, aIdx2 :Integer) :Integer;
    var
      vCmp1, vCmp2 :PCmpTextRow;
      vPtr1, vPtr2 :PTChar;
      vRes :TStrCompareRes;
    begin
//    TraceF('TryMoveForward: %d, %d-%d', [aSide, aIdx1+1, aIdx2+1]);
      Result := 0;
      while aIdx2 < FDiff.Count do begin
        vCmp1 := FDiff.PItems[aIdx1];
        vCmp2 := FDiff.PItems[aIdx2];
        if {(vCmp2.FFlags <> 0) or} (vCmp2.FRow[aSide] = -1) then
          Break;

        vPtr1 := FText[aSide].StrPtrs[vCmp1.FRow[aSide]];
        vPtr2 := FText[aSide].StrPtrs[vCmp2.FRow[aSide]];

        vRes := CompareStrEx(vPtr1, vPtr2);

        if vRes <> scrDiff then begin
          vCmp1.FRow[1-aSide] := vCmp2.FRow[1-aSide];
          vCmp1.FFlags := IntIf(vRes = scrEqual, 0, 1);

          vCmp2.FRow[1-aSide] := -1;
          vCmp2.FFlags := 1;

          Inc(aIdx1);
          Inc(aIdx2);
          Inc(Result);
        end else
          Break;
      end;
    end;


  var
    vIdx, vBeg, vCount1, vCount2 :Integer;
    vCmp :PCmpTextRow;
  begin
    vIdx := 0;
    while vIdx < FDiff.Count do begin
      vCmp := FDiff.PItems[vIdx];
      if vCmp.FFlags <> 0 then begin
        vBeg := vIdx;
        vCount1 := 0; vCount2 := 0;
        while vCmp.FFlags <> 0 do begin
          if vCmp.FRow[0] <> -1 then
            Inc(vCount1);
          if vCmp.FRow[1] <> -1 then
            Inc(vCount2);
          Inc(vIdx);
          if vIdx = FDiff.Count then
            Break;
          vCmp := FDiff.PItems[vIdx];
        end;

        if (vCount1 = 0) or (vCount2 = 0) then begin
          { Вставка }
          if vIdx < FDiff.Count then
            Inc(vIdx, TryMoveForward(IntIf(vCount1 <> 0, 0, 1), vBeg, vIdx));
        end else
        begin
          { Правка }

        end;

        if vIdx < FDiff.Count then
          Inc(vIdx);
      end else
        Inc(vIdx);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TRowDiff                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TRowDiff.CreateEx(AStr1, AStr2 :PTChar);
  begin
    Create;
    FDiff1 := TBits.Create;
    FDiff2 := TBits.Create;
    Compare(AStr1, AStr2);
  end;

  destructor TRowDiff.Destroy; {override;}
  begin
   {$ifdef bFastCompareRow}
    FreeMem(FUpStr1);
    FreeMem(FUpStr2);
    FreeObj(FIndexes1);
    FreeObj(FIndexes2);
   {$endif bFastCompareRow}
    FreeObj(FDiff1);
    FreeObj(FDiff2);
    inherited Destroy;
  end;


  procedure TRowDiff.Compare(AAStr1, AAStr2 :PTChar);

    procedure MarkStr(AStr1, AStr2 :PTChar; ACount :Integer; ADiff :Boolean = True);
    var
      I :Integer;
    begin
      for I := 0 to ACount - 1 do begin
        if AStr1 <> nil then
          FDiff1[AStr1 - AAStr1 + I] := ADiff;
        if AStr2 <> nil then
          FDiff2[AStr2 - AAStr2 + I] := ADiff;
      end;
    end;


    procedure ComparePart(ABegStr1, ABegStr2, AEndStr1, AEndStr2 :PTChar; AFactor :Integer);

      procedure LocAddDiffs(var AStr1, AStr2 :PTChar; ACount1, ACount2 :Integer);

        procedure LocCheckSpace(var AStr :PTChar; var ACount :Integer);
        begin
//        while (ACount > 0) and CharIsSpace(AStr^) do begin
//          Inc(AStr);
//          Dec(ACount);
//        end;

          if optTextIgnoreSpace then
            while (ACount > 0) and CharIsSpace((AStr + ACount - 1)^) do
              Dec(ACount);
        end;

      var
        vMin, vMax :Integer;
        vStr1, vStr2 :PTChar;
      begin
        vMin := IntMin( ACount1, ACount2 );
        vMax := IntMax( ACount1, ACount2 );
        if (AFactor > cStrMinFactor) and (vMin > 0) and (vMax > 1) then begin
          { Рекурсивно попробуем с меньшим фактором... }
          ComparePart(AStr1, AStr2, AStr1 + ACount1, AStr2 + ACount2, AFactor div 2);
          Inc(AStr1, ACount1);
          Inc(AStr2, ACount2);
        end else
        begin
          vStr1 := AStr1;
          Inc(AStr1, ACount1);

          vStr2 := AStr2;
          Inc(AStr2, ACount2);

          LocCheckSpace(vStr1, ACount1);
          LocCheckSpace(vStr2, ACount2);

          MarkStr(vStr1, nil, ACount1);
          MarkStr(nil, vStr2, ACount2);
        end;
      end;

     {$ifdef bFastCompareRow}

      { Двоичный взаимный поиск }

      function LocResync(AStr1, AStr2 :PTChar; var ADelta1, ADelta2 :Integer) :Boolean;
      var
        vAPos1, vAPos2 :Integer;
        vBest :Integer;

        procedure LocFind(AVer :Integer; ABaseDelta, ASrcPos :Integer; AKey :TChar; AIndex :TRowIndex; ABegPos, AEndPos :Integer);
        var
          vIndex, vPos, vPos1, vPos2, vDelta :Integer;
        begin
         {$ifdef bSpaceSync }
         {$else}
          if CharIsSpace(AKey) then
            Exit;
         {$endif bSpaceSync }

          vIndex := AIndex.FindFirst(AKey, ABegPos);
          if vIndex <> -1 then begin

            vPos1 := ASrcPos;
            vPos2 := ASrcPos;

            vPos := AIndex[vIndex];
            while True do begin
              if vPos >= AEndPos then
                Break;
              if ABaseDelta + vPos - ABegPos >= vBest then
                Break; { Лучше уже не будет... }

              if AVer = 0 then
                vPos2 := vPos
              else
                vPos1 := vPos;

              if CompareChars(AAStr1 + vPos1, AAStr2 + vPos2, AEndStr1, AEndStr2, AFactor) then begin
                while (vPos1 > vAPos1) and (vPos2 > vAPos2) and CharIsSpace((FUpStr1 + vPos1 - 1)^) and CharIsSpace((FUpStr2 + vPos2 - 1)^) do begin
                  Dec(vPos1);
                  Dec(vPos2);
                end;

                vDelta := ABaseDelta + vPos - ABegPos;
                if vDelta < vBest then begin
                  vBest := vDelta;
                  ADelta1 := vPos1 - vAPos1;
                  ADelta2 := vPos2 - vAPos2;
                  Result := True;
                  Break;
                end;
              end;

              if vIndex >= AIndex.Count - 1 then
                Break;
              Inc(vIndex);
              vPos := AIndex[vIndex];
              if (AIndex.FRowStr + vPos)^ <> AKey then
                Break;
            end;
          end;
        end;

      var
        I :Integer;
      begin
        Result := False;

        vAPos1 := AStr1 - AAStr1;
        vAPos2 := AStr2 - AAStr2;

        vBest := MaxInt;
        for I := 0 to IntMin(AEndStr1 - AStr1, AEndStr2 - AStr2) - 1 do begin
          if I > vBest then
            Break; { Лучше уже не будет... }
          if AStr1 + I < AEndStr1 then
            LocFind( 0, I, vAPos1 + I, (FUpStr1 + vAPos1 + I)^, TRowIndex(FIndexes2), vAPos2 + I, AEndStr2 - AAStr2 );
          if AStr2 + I < AEndStr2 then
            LocFind( 1, I, vAPos2 + I, (FUpStr2 + vAPos2 + I)^, TRowIndex(FIndexes1), vAPos1 + I, AEndStr1 - AAStr1 );
        end;
      end;

     {$else}

      { Линейный взаимный поиск (тормозит) }

      function LocResync(AStr1, AStr2 :PTChar; var ADelta1, ADelta2 :Integer) :Boolean;

        function LocCompare(AD1, AD2 :Integer) :Boolean;
        begin
          Result := CompareChars(AStr1 + AD1, AStr2 + AD2, AEndStr1, AEndStr2, AFactor);
          if Result then begin
            ADelta1 := AD1;
            ADelta2 := AD2;
          end;
        end;

      var
        I, J :Integer;
      begin
        Result := True;
        for I := 1 to IntMax(AEndStr1 - AStr1, AEndStr2 - AStr2) do begin
          for J := 0 to I - 1 do begin
            if LocCompare(J, I) then
              Exit;
            if LocCompare(I, J) then
              Exit;
          end;
          if LocCompare(I, I) then
            Exit;
        end;
        Result := False;
      end;

     {$endif bFastCompareRow}


    var
      vStr1, vStr2 :PTChar;
      vDelta1, vDelta2 :Integer;
      vRes :TStrCompareRes;
    begin
      LocCorrectFactor(AFactor, AEndStr1 - ABegStr1, AEndStr2 - ABegStr2);

      vStr1 := ABegStr1;
      vStr2 := ABegStr2;
      while True do begin
        if (vStr1 >= AEndStr1) or (vStr2 >= AEndStr2) then
          Break;

        vRes := CompareChrEx(vStr1^, vStr2^);

        if vRes in [scrEqual, scrSimilar] then begin
          if vRes <> scrEqual then
            { Разный регистр или Space/Tab}
            MarkStr(vStr1, vStr2, 1);
          Inc(vStr1);
          Inc(vStr2);
        end else
        begin
          if CharIsSpace(vStr1^) then begin
            if not optTextIgnoreSpace then
              MarkStr(vStr1, nil, 1);
            Inc(vStr1);
            Continue;
          end;
          if CharIsSpace(vStr2^) then begin
            if not optTextIgnoreSpace then
              MarkStr(nil, vStr2, 1);
            Inc(vStr2);
            Continue;
          end;

          { Пробуем восстановить синхронизацию с фактором совпадения AFactor (взаимный поиск)... }
          if not LocResync(vStr1, vStr2, vDelta1, vDelta2) then
            Break;

          { Добавляем несовпадающий диапазон }
          LocAddDiffs(vStr1, vStr2, vDelta1, vDelta2);
        end;
      end;

      { Добавляем хвосты, как несовпадающий диапазон }
      LocAddDiffs(vStr1, vStr2, AEndStr1 - vStr1, AEndStr2 - vStr2);
    end;


    procedure LocCompareRowBreak(var ALen1, ALen2 :Integer);
    var
      vEqual :Boolean;
      vStr1, vStr2 :PTChar;
    begin
      vStr1 := AAStr1 + ALen1 - 1;
      vStr2 := AAStr2 + ALen2 - 1;
      while (vStr1 >= AAStr1) and (vStr2 >= AAStr2) and (vStr1^ = vStr2^) and CharIsCRLF(vStr1^) do begin
        Dec(vStr1);
        Dec(vStr2);
      end;
      vEqual := not ((vStr1 >= AAStr1) and CharIsCRLF(vStr1^)) and not ((vStr2 >= AAStr2) and CharIsCRLF(vStr2^));

      while (ALen1 > 0) and CharIsCRLF((AAStr1 + ALen1 - 1)^) do begin
        if not vEqual and not optTextIgnoreCRLF then
          FDiff1[ALen1 - 1] := True;
        Dec(ALen1);
      end;

      while (ALen2 > 0) and CharIsCRLF((AAStr2 + ALen2 - 1)^) do begin
        if not vEqual and not optTextIgnoreCRLF then
          FDiff2[ALen2 - 1] := True;
        Dec(ALen2);
      end;
    end;


  var
    vLen1, vLen2 :Integer;
  begin
    vLen1 := StrLen(AAStr1);
    vLen2 := StrLen(AAStr2);

    FDiff1.Size := vLen1;
    FDiff2.Size := vLen2;

    LocCompareRowBreak(vLen1, vLen2);

   {$ifdef bFastCompareRow}
    Reindex(AAStr1, vLen1, FUpStr1, FIndexes1);
    Reindex(AAStr2, vLen2, FUpStr2, FIndexes2);
   {$endif bFastCompareRow}

    ComparePart(AAStr1, AAStr2, AAStr1 + vLen1, AAStr2 + vLen2, cStrBegFactor);
  end;


 {-----------------------------------------------------------------------------}

  function TRowDiff.CompareChars(AStr1, AStr2, AEnd1, AEnd2 :PTChar; AFactor :Integer) :Boolean;

    function CharWeight(AChr :TChar) :TFloat;
    begin
      if CharIsSpace(AChr) then begin
       {$ifdef bSpaceSync}
        Result := 0.34;
       {$else}
        Result := 0;
       {$endif bSpaceSync}
        exit;
      end;

      if CharIsWordChar(AChr) then begin
        Result := 0.34; { Три совпадающих символа подряд восстанавливают синхронизацию }
        exit;
      end;

      Result := 1;
    end;

  var
    vFactor :TFloat;
  begin
    Result := False;
    vFactor := AFactor;
    while vFactor > 0 do begin
      if (AStr1 >= AEnd1) or (AStr2 >= AEnd2) then
        Exit;

      if CompareChrEx(AStr1^, AStr2^) = scrDiff then begin

        if CharIsSpace(AStr1^) then begin
          Inc(AStr1);
          Continue;
        end;
        if CharIsSpace(AStr2^) then begin
          Inc(AStr2);
          Continue;
        end;

        Result := False;
        Exit;
      end;

      vFactor := vFactor - CharWeight(AStr1^);

      Inc(AStr1);
      Inc(AStr2);
    end;
    Result := True;
  end;


  function TRowDiff.CompareChrEx(AChr1, AChr2 :TChar) :TStrCompareRes;
  begin
    Result := scrEqual;
    if AChr1 <> AChr2 then begin
      if CharIsSpace(AChr1) and CharIsSpace(AChr2) then begin
        if not optTextIgnoreSpace then
          Result := scrSimilar;
      end else
      begin
        if CharUpCase(AChr1) = CharUpCase(AChr2) then begin
          if not optTextIgnoreCase then
            Result := scrSimilar;
        end else
          Result := scrDiff;
      end;
    end;
  end;


  function TRowDiff.GetDiffBits(AVer :Integer) :TBits;
  begin
    if AVer = 0 then
      Result := FDiff1
    else
      Result := FDiff2;
  end;


 {$ifdef bFastCompareRow}
  procedure TRowDiff.Reindex(ASrc :PTChar; ALen :Integer; var AUpStr :PTChar; var AIndex :TIntList);
  var
    I :Integer;
  begin
    AUpStr := MemAlloc((ALen + 1) * SizeOf(TChar));
    StrMove(AUpStr, ASrc, ALen);
    (AUpStr + ALen)^ := #0;

    CharUpperBuff(AUpStr, ALen);

    AIndex := TRowIndex.CreateEx(AUpStr);
    for I := 0 to ALen - 1 do begin
     {$ifdef bSpaceSync }
      if CharIsSpace((AUpStr + I)^) then
        (AUpStr + I)^ := ' ';
      AIndex.Add(I);
     {$else}
      if not CharIsSpace( (AUpStr + I)^ ) then
        AIndex.Add(I);
     {$endif bSpaceSync }
    end;

    AIndex.SortList(True, 0);
  end;
 {$endif bFastCompareRow}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetTextDiffs(const AName1, AName2 :TString) :TTextDiff;
  begin
    Result := TTextDiff.CreateEx(AName1, AName2);
  end;


end.


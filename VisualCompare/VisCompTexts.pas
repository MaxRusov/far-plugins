{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}

{$Define bFastCompare}

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
    cTextEqualFactor = 8;  // 8..4..2..1
    cStrEqualFactor = 12;  // 12..6..3


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


    {!!!-Переделать на TStrList}
    TText = class(TStringList)
    public
      constructor CreateEx(const AName :TString);
      procedure LoadFile(AForceFormat :TStrFileFormat);

    private
      FName     :TString;
      FViewName :TString;
      FFormat   :TStrFileFormat;

    public
      property Name :TString read FName;
      property ViewName :TString read FViewName write FViewName;
      property Format :TStrFileFormat read FFormat;
    end;

    TStrCompareRes = (
      strEqual,      { Строки совпадают }
      strSimilar,    { Строки различаются только пробелами или регистром }
      strDiff        { Строки различаюися }
    );

    TTextDiff = class(TBasis)
    public
      constructor CreateEx(const AName1, AName2 :TString);
      destructor Destroy; override;

      procedure Compare;
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
      function CompareStrEx(AStr1, AStr2 :PTChar) :TStrCompareRes;

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

      function CompareChars(AStr1, AStr2, AEnd1, AEnd2 :PTChar; ACount :Integer) :Boolean;
      function CompareChrEx(AChr1, AChr2 :TChar) :TStrCompareRes;
    end;



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


  function RowIsEmpty(AStr :PTChar) :Boolean;
  begin
    while CharIsSpace(AStr^) do
      Inc(AStr);
    Result := AStr^ = #0;
  end;


  procedure StrZeroToSpace(var AStr :TString);
  var
    I :Integer;
  begin
    for I := 1 to Length(AStr) do
      if AStr[I] = #0 then
        AStr[I] := ' ';
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

    vStr := StrFromFile(FName, FFormat);

    StrZeroToSpace(vStr);
    Text := vStr;
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
    CalcCrcs;
    ReindexCRCs;
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
    FText[1].LoadFile(FText[0].FFormat);
   {$ifdef bFastCompare}
    CalcCrcs;
    ReindexCRCs;
   {$endif bFastCompare}
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

        if (AFactor > 1) and (vMinRows > 0) and (vMaxRows > 1) then begin
          { Рекурсивно попробуем с меньшим фактором... }
          ComparePart(ARow1, ARow2, ARow1 + ACount1, ARow2 + ACount2, AFactor div 2);
          Inc(ARow1, ACount1);
          Inc(ARow2, ACount2);
        end else
        begin

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

          vAdd1 := 0;
          while (ACount1 > 0) and (RowIsEmpty(FText[0].StrPtrs[ARow1 + ACount1 - 1])) do begin
            Inc(vAdd1);
            Dec(ACount1);
          end;

          vAdd2 := 0;
          while (ACount2 > 0) and (RowIsEmpty(FText[1].StrPtrs[ARow2 + ACount2 - 1])) do begin
            Inc(vAdd2);
            Dec(ACount2);
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


      procedure LocCorrectFactor;
        { Фактор не может превышать размеры максимальной сравниваемой области }
      var
        vMin :Integer;
      begin
        vMin := IntMin(AEndRow1 - ABegRow1, AEndRow2 - ABegRow2);
        if vMin = 0 then
          Exit;
        while (AFactor > 1) and (AFactor > vMin) do
          AFactor := AFactor div 2;
      end;

    var
      vRow1, vRow2, vDelta1, vDelta2 :Integer;
      vRes :TStrCompareRes;
      vPtr1, vPtr2 :PTChar;
    begin
      LocCorrectFactor;
//    TraceF('Compare: %d(%d) x %d(%d), Factor=%d', [ABegRow1, AEndRow1-ABegRow1, ABegRow2, AEndRow2-ABegRow2, AFactor]);

      vRow1 := ABegRow1;
      vRow2 := ABegRow2;
      while True do begin
        if (vRow1 >= AEndRow1) or (vRow2 >= AEndRow2) then
          Break;

        vPtr1 := FText[0].StrPtrs[vRow1];
        vPtr2 := FText[1].StrPtrs[vRow2];

        vRes := CompareStrEx(vPtr1, vPtr2);

        if vRes in [strEqual, strSimilar] then begin
          AppedRows(vRow1, vRow2, 1, IntIf(vRes = strSimilar, 1, 0));
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
    ComparePart(0, 0, FText[0].Count, FText[1].Count, cTextEqualFactor);
//  OptimizeEmptyLines;

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
      if CompareStrEx(vPtr1, vPtr2) = strDiff then begin

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


  function TTextDiff.CompareStrEx(AStr1, AStr2 :PTChar) :TStrCompareRes;
  begin
    Result := strEqual;
   {$ifdef bTrace}
    Inc(FRowCompare);
   {$endif bTrace}
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
            Result := strSimilar;
        end else
        begin
          if CharUpCase(AStr1^) = CharUpCase(AStr2^) then begin
            Inc(AStr1);
            Inc(AStr2);
            if not optTextIgnoreCase then
              Result := strSimilar;
          end else
          begin
            Result := strDiff;
            Exit;
          end;
        end;
      end;
    end;
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
    while CharIsSpace(AStr^) do
      Inc(AStr);

    if AStr^ = #0 then begin
      Result := 0;
      Exit;
    end;

    Result := TCRC(-1);
    vPart := 0;
    while AStr^ <> #0 do begin

      if CharIsSpace(AStr^) then begin
        while CharIsSpace(AStr^) do
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


    procedure ComparePart(AStr1, AStr2 :PTChar; AEnd1, AEnd2 :PTChar; AFactor :Integer);

      procedure LocAddDiffs(var AStr1, AStr2 :PTChar; ACount, ACount1, ACount2 :Integer);
      begin
        if (AFactor > 3) and (ACount > 0) then begin
          { Рекурсивно попробуем с меньшим фактором... }
          ComparePart(AStr1, AStr2, AStr1 + ACount + ACount1, AStr2 + ACount + ACount2, AFactor div 2);
          Inc(AStr1, ACount + ACount1);
          Inc(AStr2, ACount + ACount2);
        end else
        begin
          if ACount > 0 then begin
            MarkStr(AStr1, AStr2, ACount);
            Inc(AStr1, ACount);
            Inc(AStr2, ACount);
          end;
          if ACount1 > 0 then begin
            MarkStr(AStr1, nil, ACount1);
            Inc(AStr1, ACount1);
          end;
          if ACount2 > 0 then begin
            MarkStr(nil, AStr2, ACount2);
            Inc(AStr2, ACount2);
          end;
        end;
      end;

    var
      I, vDelta, vMaxDelta :Integer;
      vRes :TStrCompareRes;
      vFound :Boolean;
    begin
      while True do begin
        if (AStr1 >= AEnd1) or (AStr2 >= AEnd2) then
          Break;

        vRes := CompareChrEx(AStr1^, AStr2^);
        if vRes in [strEqual, strSimilar] then begin
          if vRes <> strEqual then
            MarkStr(AStr1, AStr2, 1);
          Inc(AStr1);
          Inc(AStr2);
        end else
        begin

          if CharIsSpace(AStr1^) then begin
            if not optTextIgnoreSpace then
              MarkStr(AStr1, nil, 1);
            Inc(AStr1);
            Continue;
          end;
          if CharIsSpace(AStr2^) then begin
            if not optTextIgnoreSpace then
              MarkStr(nil, AStr2, 1);
            Inc(AStr2);
            Continue;
          end;

          vDelta := 1;
          vMaxDelta := IntMax(AEnd1 - AStr1, AEnd2 - AStr2);
          vFound := False;
          while vDelta < vMaxDelta do begin
            for I := 0 to vDelta do begin
              if CompareChars(AStr1 + I, AStr2 + vDelta, AEnd1, AEnd2, AFactor) then begin
                LocAddDiffs(AStr1, AStr2, I, 0, vDelta - I);
                vFound := True;
                Break;
              end;
              if CompareChars(AStr1 + vDelta, AStr2 + I, AEnd1, AEnd2, AFactor) then begin
                LocAddDiffs(AStr1, AStr2, I, vDelta - I, 0);
                vFound := True;
                Break;
              end
            end;
            if vFound then
              Break;

            Inc(vDelta);
          end;
          if not vFound then
            Break;

        end;
      end;

      I := IntMin(AEnd1 - AStr1, AEnd2 - AStr2);
      LocAddDiffs(AStr1, AStr2, I, AEnd1 - AStr1 - I, AEnd2 - AStr2 - I);
    end;

  var
    vLen1, vLen2 :Integer;
  begin
    vLen1 := StrLen(AAStr1);
    vLen2 := StrLen(AAStr2);
    FDiff1.Size := vLen1;
    FDiff2.Size := vLen2;
    ComparePart(AAStr1, AAStr2, AAStr1 + vLen1, AAStr2 + vLen2, cStrEqualFactor);
  end;



  function TRowDiff.CompareChars(AStr1, AStr2, AEnd1, AEnd2 :PTChar; ACount :Integer) :Boolean;
  begin
    Result := False;
    while ACount > 0 do begin
      if (AStr1 >= AEnd1) or (AStr2 >= AEnd2) then
        Exit;
      if CompareChrEx(AStr1^, AStr2^) = strDiff then begin

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
      Inc(AStr1);
      Inc(AStr2);
      if not CharIsSpace(AStr1^) then
        Dec(ACount);
    end;
    Result := True;
  end;


  function TRowDiff.CompareChrEx(AChr1, AChr2 :TChar) :TStrCompareRes;
  begin
    Result := strEqual;
    if AChr1 <> AChr2 then begin
      if CharIsSpace(AChr1) and CharIsSpace(AChr2) then begin
        if not optTextIgnoreSpace then
          Result := strSimilar;
      end else
      begin
        if CharUpCase(AChr1) = CharUpCase(AChr2) then begin
          if not optTextIgnoreCase then
            Result := strSimilar;
        end else
          Result := strDiff;
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


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetTextDiffs(const AName1, AName2 :TString) :TTextDiff;
  begin
    Result := TTextDiff.CreateEx(AName1, AName2);
  end;


end.


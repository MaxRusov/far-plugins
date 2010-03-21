{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}

unit VisCompTexts;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    VisCompCtrl;


  const
    cEqualFactor = 3;


  type
    TText = class;

    TRowsPair = array[0..1] of Integer;
    TTextsPair = array[0..1] of TText;

    PCmpTextRow = ^TCmpTextRow;
    TCmpTextRow = packed record
      FRow   :TRowsPair;
      FFlags :Integer;
    end;


    {!!!-Переделать на TStrList}
    TText = class(TStringList)
    public
      constructor CreateEx(const AName :TString);
      procedure LoadFile;

    private
      FName :TString;

    public
      property Name :TString read FName;
    end;


    TTextDiff = class(TBasis)
    public
      constructor CreateEx(const AName1, AName2 :TString);
      destructor Destroy; override;

      procedure Compare;
      procedure ReloadAndCompare;

    private
      FDiff   :TExList;
      FText   :TTextsPair;

      function CompareRows(ARow1, ARow2, AEndRow1, AEndRow2, ACount :Integer) :Boolean;
      function CompareStr(AStr1, AStr2 :PTChar) :Boolean;
      function RowIsEmpty(AStr :PTChar) :Boolean;
      procedure AppedRows(ARow1, ARow2, ACount :Integer; AFlags :Integer = 1);

      function GetDiffCount :Integer;
      function GetCmpItems(I :Integer) :PCmpTextRow;

//    procedure OptimizeEmptyLines;

    public
      property DiffCount :Integer read GetDiffCount;
      property CmpItems[I :Integer] :PCmpTextRow read GetCmpItems; default;
      property Text :TTextsPair read FText;
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


 {-----------------------------------------------------------------------------}
 { TText                                                                       }
 {-----------------------------------------------------------------------------}

  constructor TText.CreateEx(const AName :TString);
  begin
    Create;
    FName := AName;
    LoadFile;
  end;


  procedure TText.LoadFile;
  var
    vStr :TString;
  begin
    vStr := StrFromFile(FName);
    Text := vStr;
  end;


 {-----------------------------------------------------------------------------}
 { TTextDiff                                                            }
 {-----------------------------------------------------------------------------}

  constructor TTextDiff.CreateEx(const AName1, AName2 :TString);
  begin
    Create;
    FText[0] := TText.CreateEx(AName1);
    FText[1] := TText.CreateEx(AName2);
    FDiff := TExList.CreateSize(SizeOf(TCmpTextRow));
    Compare;
  end;


  destructor TTextDiff.Destroy; {override;}
  begin
    FreeObj(FText[0]);
    FreeObj(FText[1]);
    FreeObj(FDiff);
    inherited Destroy;
  end;


  procedure TTextDiff.ReloadAndCompare;
  begin
    FText[0].LoadFile;
    FText[1].LoadFile;
    Compare;
  end;


(*
  procedure TTextDiff.Compare;

    procedure ComparePart(ABegRow1, ABegRow2, AEndRow1, AEndRow2 :Integer; AFactor :Integer);

      procedure LocAddDiffs(var ARow1, ARow2 :Integer; ACount, ACount1, ACount2 :Integer);
      begin
        if (AFactor > 1) and (ACount > 0) then begin
          { Рекурсивно попробуем с меньшим фактором... }
          ComparePart(ARow1, ARow2, ARow1 + ACount + ACount1, ARow2 + ACount + ACount2, 1);
          Inc(ARow1, ACount + ACount1);
          Inc(ARow2, ACount + ACount2);
        end else
        begin
          if ACount > 0 then begin
            AppedRows(ARow1, ARow2, ACount);
            Inc(ARow1, ACount);
            Inc(ARow2, ACount);
          end;
          if ACount1 > 0 then begin
            AppedRows(ARow1, -1, ACount1);
            Inc(ARow1, ACount1);
          end;
          if ACount2 > 0 then begin
            AppedRows(-1, ARow2, ACount2);
            Inc(ARow2, ACount2);
          end;
        end;
      end;

    var
      I, vRow1, vRow2, vDelta, vMaxDelta :Integer;
      vPtr1, vPtr2 :PTChar;
      vEmpty1, vEmpty2, vFound :Boolean;
    begin
      vRow1 := ABegRow1;
      vRow2 := ABegRow2;
      while True do begin
        if (vRow1 >= AEndRow1) or (vRow2 >= AEndRow2) then
          Break;

        vPtr1 := FText[0].StrPtrs[vRow1];
        vPtr2 := FText[1].StrPtrs[vRow2];

        if optTextIgnoreEmptyLine then begin
          vEmpty1 := RowIsEmpty(vPtr1);
          vEmpty2 := RowIsEmpty(vPtr2);
          if vEmpty1 or vEmpty2 then begin
            if vEmpty1 and vEmpty2 then begin
              AppedRows(vRow1, vRow2, 1, 0);
              Inc(vRow1);
              Inc(vRow2);
            end else
            if vEmpty1 then begin
              AppedRows(vRow1, -1, 1, 0);
              Inc(vRow1);
            end else
            begin
              AppedRows(-1, vRow2, 1, 0);
              Inc(vRow2);
            end;
            Continue;
          end;
        end;

        if CompareStr(vPtr1, vPtr2) then begin
          AppedRows(vRow1, vRow2, 1, 0);
          Inc(vRow1);
          Inc(vRow2);
        end else
        begin
          vDelta := 1;
          vMaxDelta := IntMax(AEndRow1 - vRow1, AEndRow2 - vRow2);
          vFound := False;
          while vDelta < vMaxDelta do begin
            for I := 0 to vDelta do begin
              if CompareRows(vRow1 + I, vRow2 + vDelta, AEndRow1, AEndRow2, AFactor) then begin
                LocAddDiffs(vRow1, vRow2, I, 0, vDelta - I);
                vFound := True;
                Break;
              end;
              if CompareRows(vRow1 + vDelta, vRow2 + I, AEndRow1, AEndRow2, AFactor) then begin
                LocAddDiffs(vRow1, vRow2, I, vDelta - I, 0);
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

      I := IntMin(AEndRow1 - vRow1, AEndRow2 - vRow2);
      LocAddDiffs(vRow1, vRow2, I, AEndRow1 - vRow1 - I, AEndRow2 - vRow2 - I);
    end;

  begin
    FDiff.Clear;
    ComparePart(0, 0, FText[0].Count, FText[1].Count, cEqualFactor)
  end;
*)


  procedure TTextDiff.Compare;

    procedure ComparePart(ABegRow1, ABegRow2, AEndRow1, AEndRow2 :Integer; AFactor :Integer);

      procedure LocAddDiffs(var ARow1, ARow2 :Integer; ACount, ACount1, ACount2 :Integer);
      begin
        if (AFactor > 1) and (ACount > 0) then begin
          { Рекурсивно попробуем с меньшим фактором... }
          ComparePart(ARow1, ARow2, ARow1 + ACount + ACount1, ARow2 + ACount + ACount2, 1 {!!!});
          Inc(ARow1, ACount + ACount1);
          Inc(ARow2, ACount + ACount2);
        end else
        begin
          if ACount > 0 then begin
            AppedRows(ARow1, ARow2, ACount);
            Inc(ARow1, ACount);
            Inc(ARow2, ACount);
          end;
          if ACount1 > 0 then begin
            AppedRows(ARow1, -1, ACount1);
            Inc(ARow1, ACount1);
          end;
          if ACount2 > 0 then begin
            AppedRows(-1, ARow2, ACount2);
            Inc(ARow2, ACount2);
          end;
        end;
      end;

    var
      I, vRow1, vRow2, vDelta, vMaxDelta, vFlags :Integer;
      vPtr1, vPtr2 :PTChar;
      vEmpty1, vEmpty2, vFound :Boolean;
    begin
      vRow1 := ABegRow1;
      vRow2 := ABegRow2;
      while True do begin
        if (vRow1 >= AEndRow1) or (vRow2 >= AEndRow2) then
          Break;

        vPtr1 := FText[0].StrPtrs[vRow1];
        vPtr2 := FText[1].StrPtrs[vRow2];

        if CompareStr(vPtr1, vPtr2) then begin
          AppedRows(vRow1, vRow2, 1, 0);
          Inc(vRow1);
          Inc(vRow2);
        end else
        begin
          vEmpty1 := RowIsEmpty(vPtr1);
          vEmpty2 := RowIsEmpty(vPtr2);
          if vEmpty1 or vEmpty2 then begin
            vFlags := IntIf(optTextIgnoreEmptyLine, 0, 1);
            if vEmpty1 and vEmpty2 then begin
              AppedRows(vRow1, vRow2, 1, vFlags);
              Inc(vRow1);
              Inc(vRow2);
            end else
            if vEmpty1 then begin
              AppedRows(vRow1, -1, 1, vFlags);
              Inc(vRow1);
            end else
            begin
              AppedRows(-1, vRow2, 1, vFlags);
              Inc(vRow2);
            end;
            Continue;
          end;

          vDelta := 1;
          vMaxDelta := IntMax(AEndRow1 - vRow1, AEndRow2 - vRow2);
          vFound := False;
          while vDelta < vMaxDelta do begin
            for I := 0 to vDelta do begin
              if CompareRows(vRow1 + I, vRow2 + vDelta, AEndRow1, AEndRow2, AFactor) then begin
                LocAddDiffs(vRow1, vRow2, I, 0, vDelta - I);
                vFound := True;
                Break;
              end;
              if CompareRows(vRow1 + vDelta, vRow2 + I, AEndRow1, AEndRow2, AFactor) then begin
                LocAddDiffs(vRow1, vRow2, I, vDelta - I, 0);
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

      I := IntMin(AEndRow1 - vRow1, AEndRow2 - vRow2);
      LocAddDiffs(vRow1, vRow2, I, AEndRow1 - vRow1 - I, AEndRow2 - vRow2 - I);
    end;

  begin
    FDiff.Clear;
    ComparePart(0, 0, FText[0].Count, FText[1].Count, cEqualFactor);
(*  OptimizeEmptyLines;  *)
  end;


(*
  procedure TTextDiff.OptimizeEmptyLines;
  var
    vItem :PCmpTextRow;

    procedure LocOptimize(var I :Integer; AVer :Integer);
    var
      vItem1 :PCmpTextRow;
    begin
      vItem1 := FDiff.PItems[I - 1];
      if (vItem1.FRow[1 - AVer] = -1) and
      (
        RowIsEmpty(FText[AVer].StrPtrs[vItem1.FRow[AVer]]) or
        RowIsEmpty(FText[1 - AVer].StrPtrs[vItem.FRow[1 - AVer]])
      )
      then begin

        vItem1.FRow[1 - AVer] := vItem.FRow[1 - AVer];
        FDiff.Delete(I);
        Dec(I);

      end else
        Dec(I);
    end;

  var
    I :Integer;
  begin
    I := FDiff.Count - 1;
    while I > 0 do begin
      vItem := FDiff.PItems[I];
      if vItem.FRow[0] = -1 then
        LocOptimize(I, 0)
      else
      if vItem.FRow[1] = -1 then
        LocOptimize(I, 1)
      else
        Dec(I);
    end;
  end;
*)

(*
  procedure TTextDiff.OptimizeEmptyLines;

    procedure LocOptimize(var I :Integer; AVer :Integer);
    var
      vItem1 :PCmpTextRow;
    begin
      Dec(I);
    end;

  var
    I :Integer;
  begin
    I := FDiff.Count - 1;
    while I > 0 do begin
      with PCmpTextRow(FDiff.PItems[I])^ do begin
        if FRow[0] = -1 then
          LocOptimize(I, 0)
        else
        if FRow[1] = -1 then
          LocOptimize(I, 1)
        else
          Inc(I);
      end;
    end;
  end;


  procedure TTextDiff.OptimizeEmptyLines;

    procedure LocOptimize(var I :Integer; AVer :Integer);
    begin
      Inc(I);
    end;

  var
    I :Integer;
  begin
    I := 0;
    while I < FDiff.Count - 1 do begin
      with PCmpTextRow(FDiff.PItems[I])^ do begin
        if FRow[0] = -1 then
          LocOptimize(I, 0)
        else
        if FRow[1] = -1 then
          LocOptimize(I, 1)
        else
          Inc(I);
      end;
    end;
  end;
*)

  procedure TTextDiff.AppedRows(ARow1, ARow2, ACount :Integer; AFlags :Integer = 1);
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do
      with PCmpTextRow(FDiff.NewItem(FDiff.Count))^ do begin
        FRow[0] := IntIf(ARow1 <> -1, ARow1 + I, -1);
        FRow[1] := IntIf(ARow2 <> -1, ARow2 + I, -1);
        FFlags := AFlags;
      end;
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
      if not CompareStr(vPtr1, vPtr2) then begin

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


  function TTextDiff.CompareStr(AStr1, AStr2 :PTChar) :Boolean;
  begin
    Result := True;
    while (AStr1^ <> #0) or (AStr2^ <> #0) do begin
      if AStr1^ = AStr2^ then begin
        Inc(AStr1);
        Inc(AStr2);
      end else
      begin
        if optTextIgnoreSpace and (CharIsSpace(AStr1^) or CharIsSpace(AStr2^)) then begin
          while CharIsSpace(AStr1^) do
            Inc(AStr1);
          while CharIsSpace(AStr2^) do
            Inc(AStr2);
        end else
        begin
          if optTextIgnoreCase and (CharUpCase(AStr1^) = CharUpCase(AStr2^)) then begin
            Inc(AStr1);
            Inc(AStr2);
          end else
          begin
            Result := False;
            Exit;
          end;
        end;
      end;
    end;
  end;


  function TTextDiff.RowIsEmpty(AStr :PTChar) :Boolean;
  begin
    while CharIsSpace(AStr^) do
      Inc(AStr);
    Result := AStr^ = #0;
  end;

  function TTextDiff.GetDiffCount :Integer;
  begin
    Result := FDiff.Count;
  end;


  function TTextDiff.GetCmpItems(I :Integer) :PCmpTextRow;
  begin
    Result := FDiff.PItems[I];
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function GetTextDiffs(const AName1, AName2 :TString) :TTextDiff;
  begin
    Result := TTextDiff.CreateEx(AName1, AName2);
  end;


end.


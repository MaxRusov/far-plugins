{$I Defines.inc}

{$ifdef bFreePascal}{$ImplicitExceptions off}{$endif}

unit MixStrings;

interface

  uses
    Windows,
    MixTypes,
    MixUtils;

  const
    charTAB = #09;

  type
    TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

  function IntIf(Cond :Boolean; L1, L2 :TInteger) :TInteger;
  function StrIf(Cond :Boolean; const S1, S2 :TString) :TString;
  function IntMin(L1, L2 :TInteger) :TInteger;
  function IntMax(L1, L2 :TInteger) :TInteger;
  function RangeLimit(V :TInteger; LMin, LMax :TInteger) :TInteger;
  function LogCompare(L1, L2 :Boolean) :TInteger;
  function IntCompare(L1, L2 :TInteger) :TInteger;
  function UnsCompare(L1, L2 :TCardinal) :TInteger;
  function PtrCompare(P1, P2 :Pointer) :TInteger;
  function FloatCompare(const E1, E2 :TFloat) :TInteger;
  function DateTimeCompare(const aD1, aD2 :TDateTime) :TInteger;

  procedure MemFill2(PBuf :Pointer; ACount :TInteger; AFiller :Word);
  procedure MemFillChar(pBuf :Pointer; ACount :TInteger; AChar :TChar);
  function MemSearch(Str :PAnsiChar; Count :TInteger; Match :Char) :TInteger;

  function Point(AX, AY: Integer): TPoint;
  function SmallPoint(AX, AY: SmallInt): TSmallPoint;
  function Size(ACX, ACY :TInt32) :TSize;
  function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
  function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;
  function SBounds(X, Y, W, H :TInt32) :TSmallRect;
  procedure SRectGrow(var AR :TSmallRect; ADX, ADY :TInt32);
  function RectEmpty(const AR :TRect) :Boolean;
  function RectContainsXY(const AR :TRect; X, Y :TInt32) :Boolean;

  function ChrInSet(ACh :TChar; const AChars :TAnsiCharSet) :Boolean;
  function ChrPos(Ch :TChar; const Str :TString) :TInteger;
  function ChrsPos(const Chars :TAnsiCharSet; const Str :TString) :TInteger;
  function ChrsLastPos(const Chars :TAnsiCharSet; const Str :TString) :TInteger;
  function CharIsWordChar(Chr :TChar) :Boolean;
  function StrUpPos(const Substr, Str :TString) :TInteger;
  function LastDelimiter(const Delimiters, S :TString): Integer;

  function CharUpCase(AChr :TChar) :TChar;
  function CharLoCase(AChr :TChar) :TChar;
  function StrUpCase(const Str :TString) :TString;
  function StrLoCase(const Str :TString) :TString;

  function UpCompareStr(const Str1, Str2 :TString) :TInteger;
  function UpCompareSubStr(const SubStr, Str :TString) :TInteger;
  function UpComparePChar(const Str1, Str2 :PTChar) :TInteger;
  function StrEqual(const Str1, Str2 :TString) :Boolean;

  procedure ChrOemToAnsi(var Chars; Count :TInteger);
  procedure ChrAnsiToOem(var Chars; Count :TInteger);
  function StrOemToAnsi(const Str :TAnsiStr) :TAnsiStr;
  function StrAnsiToOEM(const Str :TAnsiStr) :TAnsiStr;

  function Int2Str(Num :TInteger) :TString;
  function Int2StrEx(Num :TInteger) :TString;
  function Int64ToStr(Num :TInt64) :TString;
  function Int64ToStrEx(Num :TInt64) :TString;
  function Str2IntDef(const Str :TString; Def :TInteger) :TInteger;
  function Str2Int(const Str :TString) :TInteger;
  function Hex2Int64(const AHexStr :TString) :TInt64;

  function AppendStrCh(const AStr, AAdd, ADel :TString) :TString;
  function StrDeleteChars(const Str :TString; const Chars :TAnsiCharSet) :TString;
  function StrReplaceChars(const Str :TString; const Chars :TAnsiCharSet; Chr :TChar) :TString;
  function StrReplace(const S, OldPattern, NewPattern :TString; Flags :TReplaceFlags) :TString;
  function StrExpandTabs(s :TString) :TString;

  function WordCount(const S :TString; const Del :TAnsiCharSet) :TInteger;
  function ExtractWordsPos(Number, Count :TInteger; const S :TString; const Del :TAnsiCharSet; var B :TInteger) :TString;
  function ExtractWords(Number, Count :TInteger; const S :TString; const Del :TAnsiCharSet) :TString;
  function ExtractWord(Number :TInteger; const S :TString; const Del :TAnsiCharSet) :TString;

  function ExtractNextWord(var Str :PTChar; const Del :TAnsiCharSet) :TString;
  function ExtractNextValue(var Str :PTChar; const Del :TAnsiCharSet) :TString;
  function ExtractNextInt(var Str :PTChar; const Del :TAnsiCharSet) :TInteger;

  function AddBackSlash(const Path :TString) :TString;
  function RemoveBackSlash(const Path :TString) :TString;
  function AddFileName(const Path, FileName :TString) :TString;
  function CombineFileName(const Path, FileName :TString) :TString;
  function ExpandFileName(const FileName :TString) :TString;
  function ExtractFileName(const FileName :TString) :TString;
  function ExtractFilePath(const FileName :TString) :TString;
  function ExtractFileDrive(const FileName :TString) :TString;
  function SafeChangeFileExtension(const FileName, Extension :TString) :TString;
  function ExtractRelativePath(const BaseName, DestName :TString) :TString;

  function FileNameIsLocal(const FileName :TString) :Boolean;
  function FileNameIsUNC(const FileName :TString) :Boolean;
  function IsFullFilePath(const APath :TString) :Boolean;
  
  function GetCommandLineStr :PTChar;
  function ExtractParamStr(var AStr :PTChar) :TString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function IntIf(Cond :Boolean; L1, L2 :TInteger) :TInteger;
  begin
    if Cond then
      Result := L1
    else
      Result := L2;
  end;


  function StrIf(Cond :Boolean; const S1, S2 :TString) :TString;
  begin
    if Cond then
      Result := S1
    else
      Result := S2;
  end;


  function IntMin(L1, L2 :TInteger) :TInteger;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;


  function IntMax(L1, L2 :TInteger) :TInteger;
  begin
    if L1 > L2 then
      Result := L1
    else
      Result := L2;
  end;


  function RangeLimit(V :TInteger; LMin, LMax :TInteger) :TInteger;
  begin
    if V > LMax then
      V := LMax;
    if V < LMin then
      V := LMin;
    Result := V;
  end;


  function LogCompare(L1, L2 :Boolean) :TInteger;
  begin
    if L1 > L2 then
      Result := 1
    else
    if L1 < L2 then
      Result := -1
    else
      Result := 0;
  end;


  function IntCompare(L1, L2 :TInteger) :TInteger;
  begin
    if L1 > L2 then
      Result := 1
    else
    if L1 < L2 then
      Result := -1
    else
      Result := 0;
  end;


  function UnsCompare(L1, L2 :TCardinal) :TInteger;
  begin
    if L1 > L2 then
      Result := 1
    else
    if L1 < L2 then
      Result := -1
    else
      Result := 0;
  end;


  function PtrCompare(P1, P2 :Pointer) :TInteger;
  begin
    if Pointer1(P1) > Pointer1(P2) then
      Result := 1
    else
    if Pointer1(P1) < Pointer1(P2) then
      Result := -1
    else
      Result := 0;
  end;


  function FloatCompare(const E1, E2 :TFloat) :TInteger;
  begin
    if E1 > E2 then
      Result := 1
    else
    if E1 < E2 then
      Result := -1
    else
      Result := 0;
  end;


  function DateTimeCompare(const aD1, aD2 :TDateTime) :TInteger;
  begin
    if aD1 > aD2 then
      Result := 1
    else
    if aD1 < aD2 then
      Result := -1
    else
      Result := 0;
  end;



  procedure MemFill2(PBuf :Pointer; ACount :TInteger; AFiller :Word);
  var
    vPtr :PWord;
  begin
    vPtr := PBuf;
    while ACount > 0 DO begin
      vPtr^ := AFiller;
      Inc(vPtr);
      Dec(ACount);
    end;
  end;


  procedure MemFillChar(pBuf :Pointer; ACount :TInteger; AChar :TChar);
  begin
   {$ifdef bUnicode}
    MemFill2(pBuf, ACount, Word(AChar));
   {$else}
    FillChar(pBuf^, ACount, AChar);
   {$endif bUnicode}
  end;


  function MemSearch(Str :PAnsiChar; Count :TInteger; Match :Char) :TInteger;
  var
    vPtr, vLast :PAnsiChar;
  begin
    vPtr := Str;
    vLast := Str + Count;
    while (vPtr < vLast) and (vPtr^ <> Match) do
      inc(vPtr);
    Result := vPtr - Str;
  end;


  function Point(AX, AY: Integer): TPoint;
  begin
    with Result do begin
      X := AX;
      Y := AY;
    end;
  end;

  function SmallPoint(AX, AY: SmallInt): TSmallPoint;
  begin
    with Result do begin
      X := AX;
      Y := AY;
    end;
  end;


  function Size(ACX, ACY :TInt32) :TSize;
  begin
    with Result do begin
      CX := ACX;
      CY := ACY;
    end;
  end;


  function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
  begin
    with Result do begin
      Left := ALeft;
      Top := ATop;
      Right := ARight;
      Bottom := ABottom;
    end;
  end;

  function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;
  begin
    with Result do begin
      Left := ALeft;
      Top := ATop;
      Right := ALeft + AWidth;
      Bottom :=  ATop + AHeight;
    end;
  end;


  function SBounds(X, Y, W, H :TInt32) :TSmallRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X + W;
      Bottom := Y + H;
    end;
  end;


  procedure SRectGrow(var AR :TSmallRect; ADX, ADY :TInt32);
  begin
    dec(AR.Left,   ADX);
    inc(AR.Right,  ADX);
    dec(AR.Top,    ADY);
    inc(AR.Bottom, ADY);
  end;


  function RectEmpty(const AR :TRect) :Boolean;
  begin
    Result := (AR.Left = 0) and (AR.Top = 0) and (AR.Right = 0) and (AR.Bottom = 0);
  end;


  function RectContainsXY(const AR :TRect; X, Y :TInt32) :Boolean;
  begin
    Result :=
      (X >= AR.Left) and (X < AR.Right) and
      (Y >= AR.Top)  and (Y < AR.Bottom);
  end;


  function ChrInSet(ACh :TChar; const AChars :TAnsiCharSet) :Boolean;
  begin
   {$ifdef bUnicode}
    Result := (Word(ACh) <= $FF) and (AnsiChar(ACh) in AChars);
   {$else}
    Result := ACh in AChars;
   {$endif bUnicode}
  end;


  function ChrPos(Ch :TChar; const Str :TString) :TInteger;
  var
    I, L :TInteger;
  begin
    L := Length(Str);
    if L > 0 then
      for I := 1 to L do
        if Str[I] = Ch then begin
          Result := I;
          Exit;
        end;
    Result := 0;
  end;


  function ChrsPos(const Chars :TAnsiCharSet; const Str :TString) :TInteger;
  var
    I, L :TInteger;
  begin
    L := Length(Str);
    if L > 0 then
      for I := 1 to L do
       {$ifdef bUnicode}
        if ChrInSet(Str[I], Chars) then begin
       {$else}
        if Str[I] in Chars then begin
       {$endif bUnicode}
          Result := I;
          Exit;
        end;
    Result := 0;
  end;


  function ChrsLastPos(const Chars :TAnsiCharSet; const Str :TString) :TInteger;
  var
    I, L :TInteger;
  begin
    L := Length(Str);
    if L > 0 then
      for I := L downto 1 do
       {$ifdef bUnicode}
        if ChrInSet(Str[I], Chars) then begin
       {$else}
        if Str[I] in Chars then begin
       {$endif bUnicode}
          Result := I;
          Exit;
        end;
    Result := 0;
  end;


  function CharIsWordChar(Chr :TChar) :Boolean;
  begin
    Result := {Windows.}IsCharAlphaNumeric(Chr) or (Chr = '_');
  end;


  function StrUpPos(const Substr, Str :TString) :TInteger;
  begin
    {!!! - Повысить эффективность}
    Result := Pos( StrUpCase(SubStr), StrUpCase(Str) );
  end;


  function LastDelimiter(const Delimiters, S :TString): Integer;
  var
    P :PTChar;
  begin
    Result := Length(S);
    P := PTChar(Delimiters);
    while Result > 0 do begin
      if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
        Exit;
      Dec(Result);
    end;
  end;


  function CharUpCase(AChr :TChar) :TChar;
  begin
    Result := TChar(TCardinal({Windows.}CharUpper(Pointer(TCardinal(AChr)))));
  end;


  function CharLoCase(AChr :TChar) :TChar;
  begin
    Result := TChar(TCardinal({Windows.}CharLower(Pointer(TCardinal(AChr)))));
  end;


  function StrUnique(const Str :TString) :TString;
  begin
   {$ifdef bUnicode}
    Result := Str;
   {$else}
    SetString(Result, PChar(Str), Length(Str));
   {$endif bUnicode}
  end;


  function StrUpCase(const Str :TString) :TString;
  var
    vLen :TInteger;
  begin
    Result := StrUnique(Str);
    vLen := Length(Result);
    if vLen > 0 then
      {Windows.}CharUpperBuff(Pointer(Result), vLen);
  end;


  function StrLoCase(const Str :TString) :TString;
  var
    vLen :TInteger;
  begin
    Result := StrUnique(Str);
    vLen := Length(Result);
    if vLen > 0 then
      {Windows.}CharLowerBuff(Pointer(Result), vLen);
  end;


  function UpCompareBuf(const Buf1; const Buf2; Len1 :TInteger; Len2 :TInteger) :TInteger;
  begin
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, @Buf1, Len1, @Buf2, Len2) - 2;
  end;


  function UpCompareStr(const Str1, Str2 :TString) :TInteger;
  begin
    if Pointer(Str1) = Pointer(Str2) then
      Result := 0
    else
      Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PTChar(Str1), Length(Str1), PTChar(Str2), Length(Str2)) - 2;
  end;


  function UpCompareSubStr(const SubStr, Str :TString) :TInteger;
  var
    vLen :TInteger;
  begin
    vLen := Length(SubStr);
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PTChar(SubStr), vLen, PTChar(Str), IntMin(vLen, Length(Str))) - 2;
  end;


  function UpComparePChar(const Str1, Str2 :PTChar) :TInteger;
  begin
    if Str1 = Str2 then
      Result := 0
    else
      Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, Str1, -1, Str2, -1) - 2;
  end;


  function StrEqual(const Str1, Str2 :TString) :Boolean;
  var
    vLen :TInteger;
  begin
    if Pointer(Str1) = Pointer(Str2) then
      Result := True
    else begin
      vLen := Length(Str1);
      if vLen <> Length(Str2) then
        Result := False
      else
        Result := (vLen = 0) or (UpCompareBuf(Pointer(Str1)^, Pointer(Str2)^, vLen, vLen) = 0);
    end
  end;


  procedure ChrOemToAnsi(var Chars; Count :TInteger);
  begin
    {Windows.}OemToCharBuffA(PAnsiChar(@Chars), PAnsiChar(@Chars), Count);
  end;


  procedure ChrAnsiToOem(var Chars; Count :TInteger);
  begin
    {Windows.}CharToOemBuffA(PAnsiChar(@Chars), PAnsiChar(@Chars), Count);
  end;


  function StrOemToAnsi(const Str :TAnsiStr) :TAnsiStr;
  var
    vLen :TInteger;
  begin
    vLen := Length(Str);
    SetString(Result, nil, vLen);
    {Windows.}OemToCharBuffA(PAnsiChar(Str), PAnsiChar(Result), vLen);
  end;


  function StrAnsiToOEM(const Str :TAnsiStr) :TAnsiStr;
  var
    vLen :TInteger;
  begin
    vLen := Length(Str);
    SetString(Result, nil, vLen);
    {Windows.}CharToOemBuffA(PAnsiChar(Str), PAnsiChar(Result), vLen);
  end;


 {-----------------------------------------------------------------------------}

  procedure SetStringBackLight(var AStr :TString; ABuf :PAnsiChar; ALen :TInteger);
  var
    vSrc :PAnsiChar;
    vPtr :PTChar;
  begin
    SetString(AStr, nil, ALen);
    vPtr := PTChar(AStr);
    vSrc := ABuf + ALen - 1;
    while ALen > 0 do begin
      vPtr^ := TChar(vSrc^);
      Inc(vPtr);
      Dec(vSrc);
      Dec(ALen);
    end;
  end;


  function Int32ToString(Num :TInt32; AGroup :TInteger) :TString;
  var
    I, R :TInteger;
    Dig :Byte;
    Neg :Boolean;
    Str :array[0..32] of AnsiChar; {-2'147'483'648..2'147'483'647}
  begin
    Neg := Num < 0;
    I := 0; R := 0;
    repeat
      Dig := Abs(Num mod 10);
      Num := Num div 10;
      Str[I] := AnsiChar(Byte('0') + Dig);
      Inc(I);
      Inc(R);
      if (R = AGroup) and (Num <> 0) then begin
        Str[I] := '''';
        Inc(I);
        R := 0;
      end;
    until Num = 0;
    if Neg then begin
      Str[I] := '-';
      Inc(I);
    end;
    SetStringBackLight(Result, @Str[0], I);
  end;


  function Int64ToString(Num :TInt64; AGroup :TInteger) :TString;
  var
    I, R :TInteger;
    Dig :Byte;
    Neg :Boolean;
    Str :array[0..32] of AnsiChar; {-9'223'372'036'854'775'808..9'223'372'036'854'775'807}
  begin
    Neg := Num < 0;
    I := 0; R := 0;
    repeat
      Dig := Abs(Num mod 10);
      Num := Num div 10;
      Str[I] := AnsiChar(Byte('0') + Dig);
      Inc(I);
      Inc(R);
      if (R = AGroup) and (Num <> 0) then begin
        Str[I] := '''';
        Inc(I);
        R := 0;
      end;
    until Num = 0;
    if Neg then begin
      Str[I] := '-';
      Inc(I);
    end;
    SetStringBackLight(Result, @Str[0], I);
  end;


  function CardinalToString(Num :TCardinal; AGroup :TInteger) :TString;
  var
    I, R :TInteger;
    Dig :Byte;
    Str :array[0..32] of AnsiChar; {0..4'294'967'295}   {0..18'446'744'073'709'551'615}
  begin
    I := 0; R := 0;
    repeat
      Dig := Num mod 10;
      Num := Num div 10;
      Str[I] := AnsiChar(Byte('0') + Dig);
      Inc(I);
      Inc(R);
      if (R = AGroup) and (Num <> 0) then begin
        Str[I] := '''';
        Inc(I);
        R := 0;
      end;
    until Num = 0;
    SetStringBackLight(Result, @Str[0], I);
  end;


  function Int2Str(Num :TInteger) :TString;
  begin
   {$ifdef b64}
    Result := Int64ToString(Num, 0);
   {$else}
    Result := Int32ToString(Num, 0);
   {$endif b64}
  end;


  function Int2StrEx(Num :TInteger) :TString;
  begin
   {$ifdef b64}
    Result := Int64ToString(Num, 3);
   {$else}
    Result := Int32ToString(Num, 3);
   {$endif b64}
  end;


  function Int64ToStr(Num :TInt64) :TString;
  begin
    Result := Int64ToString(Num, 0);
  end;


  function Int64ToStrEx(Num :TInt64) :TString;
  begin
    Result := Int64ToString(Num, 3);
  end;


  function Str2IntDef(const Str :TString; Def :TInteger) :TInteger;
  var
    Err :TInteger;
  begin
    Val(Str, Result, Err);
    if Err <> 0 then
      Result := Def;
  end;


  function Str2Int(const Str :TString) :TInteger;
  var
    Err :TInteger;
  begin
    Val(Str, Result, Err);
(*
    if Err <> 0 then
      AppError('!!!');
*)
  end;


  function Hex2Int64(const AHexStr :TString) :TInt64;
  begin
    {!!!}
  end;
(*
  function Hex2Int64(const AHexStr :TString) :TInt64;
 {$ifdef bInt64}
  var
    I, vLen, vShift :TInteger;
 {$endif bInt64}
  begin
   {$ifdef bInt64}
    vLen := Length(AHexStr);
    if vLen > SizeOf(Result)*2 then
      AppErrorFmt('Неверное шестнадцатеричное число: %s', [AHexStr]);
    Result := Zero64;
    vShift := 0;
    for I := vLen downto 1 do begin
      Result := Result or (TInt64(HexChar2Byte(AHexStr[I])) shl vShift);
      Inc(vShift, 4);
    end;
   {$else !bInt64}
    Sorry;
   {$endif bInt64}
  end;
*)

 {-----------------------------------------------------------------------------}

  function AppendStrCh(const AStr, AAdd, ADel :TString) :TString;
  begin
    if AStr = '' then
      Result := AAdd
    else
    if AAdd = '' then
      Result := AStr
    else
      Result := AStr + ADel + AAdd;
  end;


  function StrDeleteChars(const Str :TString; const Chars :TAnsiCharSet) :TString;
  var
    I, J, L :TInteger;
  begin
    Result := '';

    L := Length(Str);
    I := 1;
    while I <= L do begin
      J := I;
      while (I <= L) and not ChrInSet(Str[I], Chars) do
        Inc(I);

      if I > J then
        Result := Result + Copy(Str, J, I - J);

      while (I <= L) and ChrInSet(Str[I], Chars) do
        Inc(I);
    end;
  end;


  function StrReplaceChars(const Str :TString; const Chars :TAnsiCharSet; Chr :TChar) :TString;
  var
    I : TInteger;
  begin
    Result := Str;
    for I := 1 to Length(Str) do
      if ChrInSet(Result[I], Chars) then
        Result[I] := Chr;
  end;


  function StrReplace(const S, OldPattern, NewPattern :TString; Flags :TReplaceFlags) :TString;
  var
    SearchStr, Patt, NewStr: TString;
    Offset: TInteger;
  begin
    if rfIgnoreCase in Flags then begin
      SearchStr := StrUpCase(S);
      Patt := StrUpCase(OldPattern);
    end else
    begin
      SearchStr := S;
      Patt := OldPattern;
    end;
    NewStr := S;
    Result := '';
    while SearchStr <> '' do begin
      Offset := {Ansi}Pos(Patt, SearchStr);
      if Offset = 0 then begin
        Result := Result + NewStr;
        Break;
      end;
      Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
      NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
      if not (rfReplaceAll in Flags) then begin
        Result := Result + NewStr;
        Break;
      end;
      SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
    end;
  end;


  function StrExpandTabs(s :TString) :TString;
  var
    ix :TInteger;
  begin
    Result := '';
    while TRUE do begin
      ix := Pos(charTab, s);
      if ix <= 0 then begin
        Result := Result + s;
        Exit;
      end else
      if ix = 1 then begin
        Result := Result + StringOfChar(' ', 8 - (Length(Result) mod 8));
        s := System.Copy(s, 2, Length(s)-1);
      end else
      if ix = Length(s) then begin
        Result := Result + System.Copy(s, 1, Length(s)-1);
        Result := Result + StringOfChar(' ', 8 - (Length(Result) mod 8));
        s := '';
      end else begin
        Result := Result + System.Copy(s, 1, ix-1);
        Result := Result + StringOfChar(' ', 8 - (Length(Result) mod 8));
        s := System.Copy(s, ix+1, Length(s)-ix);
      end;
    end;
  end;



  function WordCount(const S :TString; const Del :TAnsiCharSet) :TInteger;
  var
    L, I :TInteger;
  begin
    Result := 0;
    if S <> '' then begin
      L := length(S);
      I := 1;
      while I <= L do begin
        while (I <= L) and {$ifdef bUnicode} ChrInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
          Inc(I);
        if I <= L then
          Inc(Result);
        while (I <= L) and not {$ifdef bUnicode} ChrInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
          Inc(I);
      end;
    end;
  end;


  function ExtractWordsPos(Number, Count :TInteger; const S :TString; const Del :TAnsiCharSet; var B :TInteger) :TString;
  var
    N2, L, I, W :TInteger;
  begin
    Result := '';
    B := MaxInt;

    if Number < 1 then begin
      Dec(Count, 1 - Number);
      Number := 1;
    end;

    Dec(Count);
    if Count > MaxInt - Number then
      Count := MaxInt - Number;
    N2 := Number + Count;

    if (N2 >= Number) and (S <> '') then begin
      L := length(S);

      I := 1;
      while (I <= L) and {$ifdef bUnicode} ChrInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
        Inc(I);

      W := 1;
      while I <= L do begin
        if W = Number then
          B := I;
        while (I <= L) and not {$ifdef bUnicode} ChrInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
          Inc(I);

        if W < N2 then begin
          Inc(W);
          while (I <= L) and {$ifdef bUnicode} ChrInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
            Inc(I);
        end else
          Break;
      end;

      if I > B then
        Result := Copy(S, B, I - B);
    end;
  end;


  function ExtractWords(Number, Count :TInteger; const S :TString; const Del :TAnsiCharSet) :TString;
  var
    P :TInteger;
  begin
    Result := ExtractWordsPos(Number, Count, S, Del, P);
  end;


  function ExtractWord(Number :TInteger; const S :TString; const Del :TAnsiCharSet) :TString;
  begin
    Result := ExtractWords(Number, 1, S, Del);
  end;


  function ExtractNextWord(var Str :PTChar; const Del :TAnsiCharSet) :TString;
  var
    P :PTChar;
  begin
    P := Str;
    while (P^ <> #0) and not ChrInSet(P^, Del) do
      Inc(P);
    Result := Copy(Str, 1, P - Str);
    while (P^ <> #0) and ChrInSet(P^, Del) do
      Inc(P);
    Str := P;
  end;


  function ExtractNextValue(var Str :PTChar; const Del :TAnsiCharSet) :TString;
  var
    P :PTChar;
  begin
    P := Str;
    while (P^ <> #0) and not ChrInSet(P^, Del) do
      Inc(P);
    Result := Copy(Str, 1, P - Str);
    if P^ <> #0 then
      Inc(P);
    Str := P;
  end;


  function ExtractNextInt(var Str :PTChar; const Del :TAnsiCharSet) :TInteger;
  var
    vStr :TString;
  begin
    vStr := ExtractNextWord(Str, Del);
    Result := Str2Int(vStr);
  end;


 {-----------------------------------------------------------------------------}

  function AddBackSlash(const Path :TString) :TString;
  begin
    if (Path <> '') and (Path[Length(Path)] <> '\') then
      Result := Path + TString('\')
    else
      Result := Path;
  end;


  function RemoveBackSlash(const Path :TString) :TString;
  var
    L, L2 :TInteger;
  begin
    L := Length(Path);
    L2 := L;
    while (L > 0) and (Path[L] = '\') and not ((L = 3) and (Path[L-1] = ':')) do
      dec(L);
    if L2 = L then
      Result := Path
    else
      SetString(Result, PTChar(Path), L);
  end;


  function ExtractFileName(const FileName :TString) :TString;
  var
    I: Integer;
  begin
    I := LastDelimiter('\:', FileName);
    Result := Copy(FileName, I + 1, MaxInt);
  end;


  function ExtractFilePath(const FileName :TString) :TString;
  var
    I: Integer;
  begin
    I := LastDelimiter('\:', FileName);
    Result := Copy(FileName, 1, I);
  end;


  function ExtractFileDrive(const FileName :TString) :TString;
  var
    I, J: Integer;
  begin
    if (Length(FileName) >= 2) and (FileName[2] = ':') then
      Result := Copy(FileName, 1, 2)
    else if (Length(FileName) >= 2) and (FileName[1] = '\') and
      (FileName[2] = '\') then
    begin
      J := 0;
      I := 3;
      While (I < Length(FileName)) and (J < 2) do
      begin
        if FileName[I] = '\' then Inc(J);
        if J < 2 then Inc(I);
      end;
      if FileName[I] = '\' then Dec(I);
      Result := Copy(FileName, 1, I);
    end else Result := '';
  end;


  function AddFileName(const Path, FileName :TString) :TString;
  var
    Ch :TChar;
  begin
    if Path = '' then
      Result := FileName
    else
    if FileName = '' then
      Result := Path
    else begin
      Ch := Path[Length(Path)];
      if (Ch <> '\') and (Ch <> ':') then
        Result := Path + '\' + FileName
      else
        Result := Path + FileName;
    end;
  end;


  function CombineFileName(const Path, FileName :TString) :TString;
  begin
    if IsFullFilePath(FileName) then begin
      { FileName содержит абсолютный путь }
      Result := FileName;
    end else begin
      { FileName содержит относительный путь }
      Result := AddFileName(Path, FileName);
    end;
  end;


  function ExpandFileName(const FileName :TString) :TString;
  var
    FName :PTChar;
    Buffer :array[0..MAX_PATH - 1] of TChar;
  begin
    SetString(Result, Buffer, GetFullPathName(PTChar(FileName), MAX_PATH, Buffer, FName));
  end;


  function SafeChangeFileExtension(const FileName, Extension: TString) :TString;
  var
    I: TInteger;
  begin
    Result := FileName;
    if FileName <> '' then begin
      I := ChrsLastPos(['.', '\', ':'], Filename);
      if (I = 0) or ((FileName[I] <> '.') and (I < Length(FileName))) then
        Result := FileName + '.' + Extension;
    end;
  end;


  function FileNameIsLocal(const FileName :TString) :Boolean;
  begin
    Result := (Length(FileName) >= 3) and (FileName[2] = ':') and (FileName[3] = '\') {and (UpCase(APath[1]) in ['A'..'Z'])};
  end;


  function FileNameIsUNC(const FileName :TString) :Boolean;
  begin
    Result := (Length(FileName) > 2) and (FileName[1] = '\') and (FileName[2] = '\');
  end;


  function IsFullFilePath(const APath :TString) :Boolean;
  begin
    Result := FileNameIsLocal(APath) or FileNameIsUNC(APath);
  end;


  function ExtractRelativePath(const BaseName, DestName :TString) :TString;
  var
    BasePath, DestPath :TString;
    BaseDirs, DestDirs :array[0..129] of PTChar;
    BaseDirCount, DestDirCount: Integer;
    I, J: Integer;

    function ExtractFilePathNoDrive(const FileName :TString) :TString;
    begin
      Result := ExtractFilePath(FileName);
      Result := Copy(Result, Length(ExtractFileDrive(FileName)) + 1, 32767);
    end;

    procedure SplitDirs(var Path :TString; var Dirs :array of PTChar; var DirCount: Integer);
    var
      I, J: Integer;
    begin
      I := 1;
      J := 0;
      while I <= Length(Path) do
      begin
  //    if Path[I] in LeadBytes then
  //      Inc(I)
  //    else
        if Path[I] = '\' then             { Do not localize }
        begin
          Path[I] := #0;
          Dirs[J] := @Path[I + 1];
          Inc(J);
        end;
        Inc(I);
      end;
      DirCount := J - 1;
    end;

  begin
    if StrEqual(ExtractFileDrive(BaseName), ExtractFileDrive(DestName)) then begin
      BasePath := ExtractFilePathNoDrive(BaseName);
      DestPath := ExtractFilePathNoDrive(DestName);
      SplitDirs(BasePath, BaseDirs, BaseDirCount);
      SplitDirs(DestPath, DestDirs, DestDirCount);
      I := 0;
      while (I < BaseDirCount) and (I < DestDirCount) do begin
        if UpComparePChar(BaseDirs[I], DestDirs[I]) = 0 then
          Inc(I)
        else
          Break;
      end;
      Result := '';
      for J := I to BaseDirCount - 1 do
        Result := Result + '..\';
      for J := I to DestDirCount - 1 do
       {$ifdef bUnicode}
        {!!!-???}
        Result := Result + TString(DestDirs[J]) + '\';
       {$else}
        Result := Result + DestDirs[J] + '\';
       {$endif bUnicode}
      Result := Result + ExtractFileName(DestName);
    end else
      Result := DestName;
  end;


  function GetCommandLineStr :PTChar;
  var
    vPtr :PTChar;
  begin
    Result := '';
    vPtr := GetCommandLine;
    if vPtr <> nil then begin
      if vPtr^ = '"' then begin
        Inc(vPtr);
        while (vPtr^ <> #0) and (vPtr^ <> '"') do
          Inc(vPtr);
        if vPtr^ <> #0 then
          Inc(vPtr);
      end else
      begin
        while (vPtr^ <> #0) and (vPtr^ <> ' ') do
          Inc(vPtr);
      end;

      while (vPtr^ <> #0) and (vPtr^ = ' ') do
        Inc(vPtr);

      if vPtr^ <> #0 then
        Result := vPtr;
    end;
  end;


  function ExtractParamStr(var AStr :PTChar) :TString;

    function LocStr(AChr :PTChar; ALen :TInteger) :TString;
    begin
      SetString(Result, AChr, ALen);
    end;

  var
    vPtr, vBeg :PTChar;
  begin
    Result := '';

    vPtr := AStr;
    while (vPtr^ <> #0) and (vPtr^ <= ' ') do
      Inc(vPtr);

    vBeg := vPtr;
    while (vPtr^ <> #0) and (vPtr^ <> ' ') do begin
      if vPtr^ = '"' then begin
        if vPtr > vBeg then
          Result := Result + LocStr(vBeg, vPtr - vBeg);

        Inc(vPtr);
        vBeg := vPtr;
        while (vPtr^ <> #0) and (vPtr^ <> '"') do
          Inc(vPtr);
        Result := Result + LocStr(vBeg, vPtr - vBeg);
        if vPtr^ <> #0 then
          Inc(vPtr);

        vBeg := vPtr;
      end else
        Inc(vPtr);
    end;

    if vPtr > vBeg then
      Result := Result + LocStr(vBeg, vPtr - vBeg);

    AStr := vPtr;
  end;


end.

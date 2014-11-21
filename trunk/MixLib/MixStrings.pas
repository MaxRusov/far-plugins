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
    charLF  = #10;
    charCR  = #13;

    DefTabSize = 8;

  type
    TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

  function IntIf(Cond :Boolean; L1, L2 :Integer) :Integer;
  function StrIf(Cond :Boolean; const S1, S2 :TString) :TString;
  function PCharIf(Cond :Boolean; S1, S2 :PTChar) :PTChar;
  function HandleIf(Cond :Boolean; H1, H2 :THandle) :THandle;
  function IntMin(L1, L2 :Integer) :Integer;
  function IntMax(L1, L2 :Integer) :Integer;
  function Int64Max(const N1, N2 :TInt64) :TInt64;
  function FloatMin(L1, L2 :TFloat) :TFloat;
  function FloatMax(L1, L2 :TFloat) :TFloat;
  function RangeLimit(V :Integer; LMin, LMax :Integer) :Integer;
  function RangeLimitF(V :TFloat; LMin, LMax :TFloat) :TFloat; 
  function LogCompare(L1, L2 :Boolean) :Integer;
  function IntCompare(L1, L2 :Integer) :Integer;
  function Int64Compare(const N1, N2 :TInt64) :Integer;
  function UnsCompare(L1, L2 :TUnsPtr) :Integer;
  function PtrCompare(P1, P2 :Pointer) :Integer;
  function FloatCompare(const E1, E2 :TFloat) :Integer;
  function DateTimeCompare(const aD1, aD2 :TDateTime) :Integer;

  function Point(X, Y: Integer) :TPoint;
  function SmallPoint(X, Y :SmallInt) :TSmallPoint;
  function Size(CX, CY :Integer) :TSize;
  function MakeCoord(X, Y :Integer) :TCoord;
  function Rect(X, Y, X2, Y2 :Integer) :TRect;
  function Bounds(X, Y, W, H :Integer) :TRect;
  function SRect(X, Y, X2, Y2 :Integer) :TSmallRect;
  function SBounds(X, Y, W, H :Integer) :TSmallRect;

  procedure RectGrow(var AR :TRect; ADX, ADY :Integer); overload;
  procedure RectGrow(var AR :TSmallRect; ADX, ADY :Integer); overload;
  procedure RectMove(var AR :TRect; ADX, ADY :Integer); overload;
  procedure RectMove(var AR :TSmallRect; ADX, ADY :Integer); overload;
  function RectEquals(const AR, R :TRect) :Boolean;
  function RectEmpty(const AR :TRect) :Boolean;
  function RectSize(const AR :TRect) :TSize;
  function RectContainsXY(const AR :TRect; X, Y :Integer) :Boolean; overload;
  function RectContainsXY(const AR :TSmallRect; X, Y :Integer) :Boolean; overload;
  function RectCenter(const ARect :TRect; AWidth, AHeight :Integer) :TRect;

  function Chr2StrL(Str :PTChar; ALen :Integer) :TString;
  function CharInSet(ACh :TChar; const AChars :TAnsiCharSet) :Boolean;
  function ChrPos(Ch :TChar; const Str :TString) :Integer;
  function ChrLastPos(Ch :TChar; const Str :TString) :Integer;
  function ChrsPos(const Chars :TAnsiCharSet; const Str :TString) :Integer;
  function ChrsLastPos(const Chars :TAnsiCharSet; const Str :TString) :Integer;
  function CharIsWordChar(Chr :TChar) :Boolean;
  function StrUpPos(const Substr, Str :TString) :Integer;
  function LastDelimiter(const Delimiters, S :TString): Integer;

  function CharUpCase(AChr :TChar) :TChar;
  function CharLoCase(AChr :TChar) :TChar;
  function StrUpCase(const Str :TString) :TString;
  function StrLoCase(const Str :TString) :TString;

  function CompareStr(const Str1, Str2 :TString) :Integer;
  function UpCompareBuf(const Buf1; const Buf2; Len1 :Integer; Len2 :Integer) :Integer;
  function UpCompareStr(const Str1, Str2 :TString) :Integer;
  function UpCompareSubStr(const SubStr, Str :TString) :Integer;
  function UpComparePChar(const Str1, Str2 :PTChar) :Integer;
  function StrEqual(const Str1, Str2 :TString) :Boolean;
  function StrIsEmpty(const Str :TString) :Boolean;

  procedure ChrOemToAnsi(var Chars; Count :Integer);
  procedure ChrAnsiToOem(var Chars; Count :Integer);
  function StrOemToAnsi(const Str :TAnsiStr) :TAnsiStr;
  function StrAnsiToOEM(const Str :TAnsiStr) :TAnsiStr;

  function Int2Str(Num :Integer) :TString;
  function Int2StrEx(Num :Integer) :TString;
  function Int64ToStr(Num :TInt64) :TString;
  function Int64ToStrEx(Num :TInt64) :TString;
  function Int2StrLen(Num :Integer) :Integer;

  function TryStrToInt(const Str :TString; var Num :Integer) :Boolean;
  function Str2IntDef(const Str :TString; Def :Integer) :Integer;
  function Str2Int(const Str :TString) :Integer;
  function TryHex2Uns(const AHexStr :TString; var Num :Cardinal) :Boolean;
  function TryHex2Int64(const AHexStr :TString; var Num :TInt64) :Boolean;
  function Hex2Int64(const AHexStr :TString) :TInt64;

  function Float2Str(Value :TFloat) :TString;
  function TryPCharToFloat(Str :PTChar; var Value :TFloat) :Boolean;
  function TryStrToFloat(const Str :TString; var Value :TFloat) :Boolean;
  function StrToFloatDef(const Str :TString; const Def :TFloat) :TFloat;

  function AppendStrCh(const AStr, AAdd, ADel :TString) :TString;
  function StrRightAjust(const AStr :TString; ALen :Integer) :TString;
  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;
  function StrDeleteChars(const Str :TString; const Chars :TAnsiCharSet) :TString;
  function StrReplaceChars(const Str :TString; const Chars :TAnsiCharSet; Chr :TChar) :TString;
  function StrReplace(const S, OldPattern, NewPattern :TString; Flags :TReplaceFlags) :TString;
  function ChrExpandTabsLen(AStr :PTChar; ALen :Integer; ATabLen :Integer = DefTabSize) :Integer;
  function ChrExpandTabs(AStr :PTChar; ALen :Integer; ATabLen :Integer = DefTabSize) :TString;
  function StrExpandTabs(const AStr :TString; ATabLen :Integer = DefTabSize) :TString;

  function WordCount(const S :TString; const Del :TAnsiCharSet) :Integer;
  function ExtractWordsPos(Number, Count :Integer; const S :TString; const Del :TAnsiCharSet; var B :Integer) :TString;
  function ExtractWords(Number, Count :Integer; const S :TString; const Del :TAnsiCharSet) :TString;
  function ExtractWord(Number :Integer; const S :TString; const Del :TAnsiCharSet) :TString;
  function ExtractLastWord(const AStr, ADelimiters :TString) :TString;

  function ExtractNextWord(var Str :PTChar; const Del :TAnsiCharSet; ASkipFirst :Boolean = False) :TString;
  function ExtractNextValue(var Str :PTChar; const Del :TAnsiCharSet) :TString;
  function ExtractNextInt(var Str :PTChar; const Del :TAnsiCharSet) :Integer;

  function AddBackSlash(const Path :TString) :TString;
  function RemoveBackSlash(const Path :TString) :TString;
  function AddFileName(const Path, FileName :TString) :TString;
  function CombineFileName(const Path, FileName :TString) :TString;
  function ExpandFileName(const FileName :TString) :TString;
  function ClearFileExt(const FileName :TString) :TString;
  function ExtractFileTitle(const FileName :TString) :TString;
  function ExtractFileExtension(const FileName :TString) :TString;
  function ExtractFileName(const FileName :TString) :TString;
  function ExtractFilePath(const FileName :TString) :TString;
  function ExtractFileDrive(const FileName :TString) :TString;
  function ChangeFileExtension(const FileName, Extension :TString) :TString;
  function SafeChangeFileExtension(const FileName, Extension :TString) :TString;
  function ExtractRelativePath(const BaseName, DestName :TString) :TString;

  function FileNameHasMask(const FileName :TString) :Boolean;
  function FileNameIsLocal(const FileName :TString) :Boolean;
  function FileNameIsUNC(const FileName :TString) :Boolean;
  function IsFullFilePath(const APath :TString) :Boolean;

  function GetCommandLineStr :PTChar;
  function ExtractParamStr(var AStr :PTChar) :TString;

  function WideToUTF8(const AStr :TWideStr) :TAnsiStr;
  function UTF8ToWide(const AStr :TAnsiStr) :TWideStr;

  type
    TStrFileFormat = (
      sffAnsi,
      sffOEM,
      sffUnicode,
      sffUTF8,
      sffAuto
    );

  var
    BOM_UTF16   :ShortString = #$FF#$FE;
    BOM_UTF16BE :ShortString = #$FE#$FF;
    BOM_UTF8    :ShortString = #$EF#$BB#$BF;

    CRLF :array[1..2] of TChar = (charCR, charLF);

  function StrDetectFormat(const AFileName :TString) :TStrFileFormat;
  function StrFromFile(const AFileName :TString; AMode :TStrFileFormat = sffAuto; ACheckBOM :Boolean = True) :TString;
  procedure StrToFile(const AFileName :TString; const AStr :TString; AMode :TStrFileFormat = sffAuto);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixConsts,
    MixDebug;


  function IntIf(Cond :Boolean; L1, L2 :Integer) :Integer;
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


  function PCharIf(Cond :Boolean; S1, S2 :PTChar) :PTChar;
  begin
    if Cond then
      Result := S1
    else
      Result := S2;
  end;


  function HandleIf(Cond :Boolean; H1, H2 :THandle) :THandle;
  begin
    if Cond then
      Result := H1
    else
      Result := H2;
  end;


  function IntMin(L1, L2 :Integer) :Integer;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;


  function IntMax(L1, L2 :Integer) :Integer;
  begin
    if L1 > L2 then
      Result := L1
    else
      Result := L2;
  end;


  function Int64Max(const N1, N2 :TInt64) :TInt64;
  begin
    if N1 > N2 then
      Result := N1
    else
      Result := N2;
  end;


  function FloatMin(L1, L2 :TFloat) :TFloat;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;


  function FloatMax(L1, L2 :TFloat) :TFloat;
  begin
    if L1 > L2 then
      Result := L1
    else
      Result := L2;
  end;


  function RangeLimit(V :Integer; LMin, LMax :Integer) :Integer;
  begin
    if V > LMax then
      V := LMax;
    if V < LMin then
      V := LMin;
    Result := V;
  end;


  function RangeLimitF(V :TFloat; LMin, LMax :TFloat) :TFloat;
  begin
    if V > LMax then
      V := LMax;
    if V < LMin then
      V := LMin;
    Result := V;
  end;


  function LogCompare(L1, L2 :Boolean) :Integer;
  begin
    if L1 > L2 then
      Result := 1
    else
    if L1 < L2 then
      Result := -1
    else
      Result := 0;
  end;


  function IntCompare(L1, L2 :Integer) :Integer;
  begin
    if L1 > L2 then
      Result := 1
    else
    if L1 < L2 then
      Result := -1
    else
      Result := 0;
  end;


  function Int64Compare(const N1, N2 :TInt64) :Integer;
  begin
    if N1 > N2 then
      Result := 1
    else
    if N1 < N2 then
      Result := -1
    else
      Result := 0;
  end;


  function UnsCompare(L1, L2 :TUnsPtr) :Integer;
  begin
    if L1 > L2 then
      Result := 1
    else
    if L1 < L2 then
      Result := -1
    else
      Result := 0;
  end;


  function PtrCompare(P1, P2 :Pointer) :Integer;
  begin
    if TUnsPtr(P1) > TUnsPtr(P2) then
      Result := 1
    else
    if TUnsPtr(P1) < TUnsPtr(P2) then
      Result := -1
    else
      Result := 0;
  end;


  function FloatCompare(const E1, E2 :TFloat) :Integer;
  begin
    if E1 > E2 then
      Result := 1
    else
    if E1 < E2 then
      Result := -1
    else
      Result := 0;
  end;


  function DateTimeCompare(const aD1, aD2 :TDateTime) :Integer;
  begin
    if aD1 > aD2 then
      Result := 1
    else
    if aD1 < aD2 then
      Result := -1
    else
      Result := 0;
  end;


  function Point(X, Y: Integer) :TPoint;
  begin
    Result.X := X;
    Result.Y := Y;
  end;

  function SmallPoint(X, Y :SmallInt) :TSmallPoint;
  begin
    Result.X := X;
    Result.Y := Y;
  end;

  function Size(CX, CY :Integer) :TSize;
  begin
    Result.CX := CX;
    Result.CY := CY;
  end;

  function MakeCoord(X, Y :Integer) :TCoord;
  begin
    Result.X := X;
    Result.Y := Y;
  end;


  function Rect(X, Y, X2, Y2 :Integer) :TRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X2;
      Bottom := Y2;
    end;
  end;

  function Bounds(X, Y, W, H :Integer) :TRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X + W;
      Bottom := Y + H;
    end;
  end;


  function SRect(X, Y, X2, Y2 :Integer) :TSmallRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X2;
      Bottom := Y2;
    end;
  end;


  function SBounds(X, Y, W, H :Integer) :TSmallRect;
  begin
    with Result do begin
      Left := X;
      Top := Y;
      Right := X + W;
      Bottom := Y + H;
    end;
  end;


  procedure RectGrow(var AR :TRect; ADX, ADY :Integer);
  begin
    Dec(AR.Left,   ADX);
    Inc(AR.Right,  ADX);
    Dec(AR.Top,    ADY);
    Inc(AR.Bottom, ADY);
  end;


  procedure RectGrow(var AR :TSmallRect; ADX, ADY :Integer);
  begin
    Dec(AR.Left,   ADX);
    Inc(AR.Right,  ADX);
    Dec(AR.Top,    ADY);
    Inc(AR.Bottom, ADY);
  end;


  procedure RectMove(var AR :TRect; ADX, ADY :Integer);
  begin
    Inc(AR.Left,   ADX);
    Inc(AR.Right,  ADX);
    Inc(AR.Top,    ADY);
    Inc(AR.Bottom, ADY);
  end;


  procedure RectMove(var AR :TSmallRect; ADX, ADY :Integer);
  begin
    Inc(AR.Left,   ADX);
    Inc(AR.Right,  ADX);
    Inc(AR.Top,    ADY);
    Inc(AR.Bottom, ADY);
  end;


  function RectEquals(const AR, R :TRect) :Boolean;
  begin
    Result :=
      (AR.Left = R.Left) and (AR.Top = R.Top) and
      (AR.Right = R.Right) and (AR.Bottom = R.Bottom);
  end;


  function RectEmpty(const AR :TRect) :Boolean;
  begin
    Result := (AR.Left = 0) and (AR.Top = 0) and (AR.Right = 0) and (AR.Bottom = 0);
  end;

  function RectSize(const AR :TRect) :TSize;
  begin
    Result.cx := AR.Right - AR.Left;
    Result.cy := AR.Bottom - AR.Top;
  end;


  function RectContainsXY(const AR :TRect; X, Y :Integer) :Boolean;
  begin
    Result :=
      (X >= AR.Left) and (X < AR.Right) and
      (Y >= AR.Top)  and (Y < AR.Bottom);
  end;


  function RectContainsXY(const AR :TSmallRect; X, Y :Integer) :Boolean;
  begin
    Result :=
      (X >= AR.Left) and (X < AR.Right) and
      (Y >= AR.Top)  and (Y < AR.Bottom);
  end;


  function RectCenter(const ARect :TRect; AWidth, AHeight :Integer) :TRect;
  begin
    Result := Bounds(
      (ARect.Left + ARect.Right - AWidth) div 2,
      (ARect.Bottom + ARect.Top - AHeight) div 2,
      AWidth, AHeight);
  end;


  function CharInSet(ACh :TChar; const AChars :TAnsiCharSet) :Boolean;
  begin
   {$ifdef bUnicode}
    Result := (Word(ACh) <= $FF) and (AnsiChar(ACh) in AChars);
   {$else}
    Result := ACh in AChars;
   {$endif bUnicode}
  end;


  function ChrPos(Ch :TChar; const Str :TString) :Integer;
  var
    I, L :Integer;
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


  function ChrLastPos(Ch :TChar; const Str :TString) :Integer;
  var
    I, L :Integer;
  begin
    L := Length(Str);
    if L > 0 then
      for I := L downto 1 do
        if Str[I] = Ch then begin
          Result := I;
          Exit;
        end;
    Result := 0;
  end;



  function ChrsPos(const Chars :TAnsiCharSet; const Str :TString) :Integer;
  var
    I, L :Integer;
  begin
    L := Length(Str);
    if L > 0 then
      for I := 1 to L do
       {$ifdef bUnicode}
        if CharInSet(Str[I], Chars) then begin
       {$else}
        if Str[I] in Chars then begin
       {$endif bUnicode}
          Result := I;
          Exit;
        end;
    Result := 0;
  end;


  function ChrsLastPos(const Chars :TAnsiCharSet; const Str :TString) :Integer;
  var
    I, L :Integer;
  begin
    L := Length(Str);
    if L > 0 then
      for I := L downto 1 do
       {$ifdef bUnicode}
        if CharInSet(Str[I], Chars) then begin
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


  function StrUpPos(const Substr, Str :TString) :Integer;
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


  function ExtractLastWord(const AStr, ADelimiters :TString) :TString;
  var
    I: Integer;
  begin
    I := LastDelimiter(ADelimiters, AStr);
    Result := Copy(AStr, I + 1, MaxInt);
  end;


  function CharUpCase(AChr :TChar) :TChar;
  begin
    Result := TChar(TUnsPtr({Windows.}CharUpper(Pointer(TUnsPtr(AChr)))));
  end;


  function CharLoCase(AChr :TChar) :TChar;
  begin
    Result := TChar(TUnsPtr({Windows.}CharLower(Pointer(TUnsPtr(AChr)))));
  end;


(*
  function StrUnique(const Str :TString) :TString;
  begin
   {$ifdef bUnicode}
    Result := Str;
   {$else}
    SetString(Result, PChar(Str), Length(Str));
   {$endif bUnicode}
  end;
*)

  function StrUnique(const Str :TString) :TString;
  begin
    SetString(Result, PTChar(Str), Length(Str));
  end;


  function StrUpCase(const Str :TString) :TString;
  var
    vLen :Integer;
  begin
    Result := StrUnique(Str);
    vLen := Length(Result);
    if vLen > 0 then
      {Windows.}CharUpperBuff(Pointer(Result), vLen);
  end;


  function StrLoCase(const Str :TString) :TString;
  var
    vLen :Integer;
  begin
    Result := StrUnique(Str);
    vLen := Length(Result);
    if vLen > 0 then
      {Windows.}CharLowerBuff(Pointer(Result), vLen);
  end;


  function CompareStr(const Str1, Str2 :TString) :Integer;
  begin
    if Pointer(Str1) = Pointer(Str2) then
      Result := 0
    else
      Result := CompareString(LOCALE_USER_DEFAULT, 0, PTChar(Str1), Length(Str1), PTChar(Str2), Length(Str2)) - 2;
  end;


  function UpCompareBuf(const Buf1; const Buf2; Len1 :Integer; Len2 :Integer) :Integer;
  begin
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, @Buf1, Len1, @Buf2, Len2) - 2;
  end;


  function UpCompareStr(const Str1, Str2 :TString) :Integer;
  begin
    if Pointer(Str1) = Pointer(Str2) then
      Result := 0
    else
      Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PTChar(Str1), Length(Str1), PTChar(Str2), Length(Str2)) - 2;
  end;


  function UpCompareSubStr(const SubStr, Str :TString) :Integer;
  var
    vLen :Integer;
  begin
    vLen := Length(SubStr);
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PTChar(SubStr), vLen, PTChar(Str), IntMin(vLen, Length(Str))) - 2;
  end;


  function UpComparePChar(const Str1, Str2 :PTChar) :Integer;
  begin
    if Str1 = Str2 then
      Result := 0
    else
      Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, Str1, -1, Str2, -1) - 2;
  end;


  function StrEqual(const Str1, Str2 :TString) :Boolean;
  var
    vLen :Integer;
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

  function StrIsEmpty(const Str :TString) :Boolean;
  var
    I :Integer;
  begin
    for I := 1 to Length(Str) do
      if Str[I] <> ' ' then begin
        Result := False;
        Exit;
      end;
    Result := True;
  end;


  procedure ChrOemToAnsi(var Chars; Count :Integer);
  begin
    {Windows.}OemToCharBuffA(PAnsiChar(@Chars), PAnsiChar(@Chars), Count);
  end;


  procedure ChrAnsiToOem(var Chars; Count :Integer);
  begin
    {Windows.}CharToOemBuffA(PAnsiChar(@Chars), PAnsiChar(@Chars), Count);
  end;


  function StrOemToAnsi(const Str :TAnsiStr) :TAnsiStr;
  var
    vLen :Integer;
  begin
    vLen := Length(Str);
    SetString(Result, nil, vLen);
    {Windows.}OemToCharBuffA(PAnsiChar(Str), PAnsiChar(Result), vLen);
  end;


  function StrAnsiToOEM(const Str :TAnsiStr) :TAnsiStr;
  var
    vLen :Integer;
  begin
    vLen := Length(Str);
    SetString(Result, nil, vLen);
    {Windows.}CharToOemBuffA(PAnsiChar(Str), PAnsiChar(Result), vLen);
  end;


 {-----------------------------------------------------------------------------}

  procedure SetStringBackLight(var AStr :TString; ABuf :PAnsiChar; ALen :Integer);
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


  function Int32ToString(Num :TInt32; AGroup :Integer) :TString;
  var
    I, R :Integer;
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


  function Int64ToString(Num :TInt64; AGroup :Integer) :TString;
  var
    I, R :Integer;
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


(*
  function CardinalToString(Num :TUnsPtr; AGroup :Integer) :TString;
  var
    I, R :Integer;
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
*)

  function Int2Str(Num :Integer) :TString;
  begin
    Result := Int32ToString(Num, 0);
  end;


  function Int2StrEx(Num :Integer) :TString;
  begin
    Result := Int32ToString(Num, 3);
  end;


  function Int64ToStr(Num :TInt64) :TString;
  begin
    Result := Int64ToString(Num, 0);
  end;


  function Int64ToStrEx(Num :TInt64) :TString;
  begin
    Result := Int64ToString(Num, 3);
  end;


  function Int2StrLen(Num :Integer) :Integer;
  begin
    {!!!Оптимизировать}
    Result := Length(Int2Str(Num));
  end;


  function TryStrToInt(const Str :TString; var Num :Integer) :Boolean;
  var
    vErr :Integer;
  begin
    Val(Str, Num, vErr);
    Result := vErr = 0;
  end;


  function Str2IntDef(const Str :TString; Def :Integer) :Integer;
  begin
    if not TryStrToInt(Str, Result) then
      Result := Def;
  end;


  function Str2Int(const Str :TString) :Integer;
  begin
    if not TryStrToInt(Str, Result) then
      AppErrorResFmt(@SInvalidInteger, [Str]);
  end;


  function TryHex2Uns(const AHexStr :TString; var Num :Cardinal) :Boolean;
  var
    vErr :Integer;
  begin
    Val('$' + AHexStr, Num, vErr);
    Result := vErr = 0;
  end;


  function TryHex2Int64(const AHexStr :TString; var Num :TInt64) :Boolean;
  var
    vErr :Integer;
  begin
    Val('$' + AHexStr, Num, vErr);
    Result := vErr = 0;
  end;


  function Hex2Int64(const AHexStr :TString) :TInt64;
  begin
    if not TryHex2Int64(AHexStr, Result) then
      AppErrorResFmt(@SInvalidInteger, [AHexStr]);
  end;

 {-----------------------------------------------------------------------------}

  function Float2Str(Value :TFloat) :TString;
  var
    vStr :Shortstring;
  begin
    Str(Value, vStr);
    Result := TString(vStr);
  end;


(*
  function InternalTextToFloat(AStr :PTChar; var AValue :TFloat) :Boolean;
  const
   {$IFDEF b64}
    CMaxExponent = 1024;
   {$ELSE}
    CMaxExponent = 4999;
   {$ENDIF b64}
    CWNear: Word = $133F;
    CDecimalSeparator = '.';
    CExponent = 'E';
    CPlus = '+';
    CMinus = '-';
  var
    LPower :Integer;
    LSign :SmallInt;
    LResult :Extended;
    LCurrChar :TChar;

    procedure NextChar;
    begin
      LCurrChar := AStr^;
      Inc(AStr);
    end;

    procedure SkipWhitespace();
    begin
      while LCurrChar = ' ' do
        NextChar;
    end;

    function ReadSign() :SmallInt;
    begin
      Result := 1;
      if LCurrChar = CPlus then
        NextChar()
      else
      if LCurrChar = CMinus then begin
        NextChar();
        Result := -1;
      end;
    end;

    function ReadNumber(var AOut: Extended): Integer;
    begin
      Result := 0;
      while CharInSet(LCurrChar, ['0'..'9']) do begin
        AOut := AOut * 10;
        AOut := AOut + Ord(LCurrChar) - Ord('0');
        NextChar();
        Inc(Result);
      end;
    end;

    function ReadExponent: SmallInt;
    var
      LSign: SmallInt;
    begin
      LSign := ReadSign();
      Result := 0;
      while CharInSet(LCurrChar, ['0'..'9']) do begin
        Result := Result * 10;
        Result := Result + Ord(LCurrChar) - Ord('0');
        NextChar();
      end;
      if Result > CMaxExponent then
        Result := CMaxExponent;
      Result := Result * LSign;
    end;

  var
   {$ifdef b64}
    LSavedMXCSR :TUns32;
   {$else}
    LSavedCtrlWord :Word;
   {$endif b64}
  begin
    { Prepare }
    Result := False;

    { Prepare the FPU }
   {$ifdef b64}
//  LSavedMXCSR := GetMXCSR;
    TestAndClearSSEExceptions(0);
    SetMXCSR(MXCSRNear);
   {$else}
//  LSavedCtrlWord := Get8087CW();
//  TestAndClearFPUExceptions(0);
    Set8087CW(CWNear);
   {$endif CPUX86}

    NextChar();
    SkipWhitespace();

    if LCurrChar <> #0 then begin
      LSign := ReadSign();
      if LCurrChar <> #0 then begin
        LResult := 0;

        { Read the integer and fractionary parts }
        ReadNumber(LResult);
        if LCurrChar = CDecimalSeparator then begin
          NextChar();
          LPower := -ReadNumber(LResult);
        end else
          LPower := 0;

        { Read the exponent and adjust the power }
        if Char(Word(LCurrChar) and $FFDF) = CExponent then begin
          NextChar();
          Inc(LPower, ReadExponent());
        end;

        SkipWhitespace();

        { Continue only if the buffer is depleted }
        if LCurrChar = #0 then  begin
          { Calculate the final number }
//        LResult := Power10(LResult, LPower) * LSign;

          AValue := LResult;

          { Final check that everything went OK }
         {$ifdef b64}
//        Result := TestAndClearSSEExceptions(mIE + mOE);
         {$else}
//        Result := TestAndClearFPUExceptions(mIE + mOE);
         {$endif b64}
        end;
      end;
    end;

   {$ifdef b64}
//  SetMXCSR(LSavedMXCSR);
   {$else}
    Set8087CW(LSavedCtrlWord);
   {$endif b64}
  end;
*)


(*
  function InternalTextToFloat(AStr :PTChar; var AValue :TFloat) :Boolean;
  const

   {$IFDEF b64}
    CMaxExponent = 1024;
   {$ELSE}
    CMaxExponent = 4999;
   {$ENDIF b64}
    CWNear: Word = $133F;

    CDecimalSeparator = '.';
    CPlus = '+';
    CMinus = '-';

    function ReadNumber(var AOut :Extended) :Integer;
    begin
      Result := 0;
      while (AStr^ >= '0') and (AStr^ <= '9') do begin
        AOut := AOut * 10;
        AOut := AOut + Ord(AStr^) - Ord('0');
        Inc(AStr);
        Inc(Result);
      end;
    end;

    function ReadExponent: SmallInt;
    var
      LSign: SmallInt;
    begin
      LSign := ReadSign();
      Result := 0;
      while CharInSet(LCurrChar, ['0'..'9']) do begin
        Result := Result * 10;
        Result := Result + Ord(LCurrChar) - Ord('0');
        NextChar();
      end;
      if Result > CMaxExponent then
        Result := CMaxExponent;
      Result := Result * LSign;
    end;

  var
    vResult :Extended;
    vPower :Integer;
    vNegative :Boolean;
  begin
    { Prepare }
    Result := False;

    while AStr^ = ' ' do
      Inc(AStr);

    if AStr^ <> #0 then begin
      vNegative := AStr^ = '-';
      if (AStr^ = '-') or (AStr^ = '+') then
        Inc(AStr);

      if AStr^ <> #0 then begin
        vResult := 0;
        vPower := 0;

        ReadNumber(vResult);
        if AStr^ = CDecimalSeparator then begin
          Inc(AStr);
          vPower := -ReadNumber(vResult);
        end;

        while AStr^ = ' ' do
          Inc(AStr);

        if AStr^ = #0 then  begin
          { Calculate the final number }
          vResult := FPower10(vResult, vPower);
          if vNegative then
            vResult := -vResult;
          AValue := vResult;
          Result := True;
        end;
      end;
    end;
  end;
*)


  function TryPCharToFloat(Str :PTChar; var Value :TFloat) :Boolean;
  var
    vErr :Integer;
  begin
    Val(Str, Value, vErr);
    Result := vErr = 0;
  end;


  function TryStrToFloat(const Str :TString; var Value :TFloat) :Boolean;
  var
    vErr :Integer;
  begin
    Val(Str, Value, vErr);
    Result := vErr = 0;
  end;


  function StrToFloatDef(const Str :TString; const Def :TFloat) :TFloat;
  begin
    if not TryStrToFloat(Str, Result) then
      Result := Def;
  end;


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


  function StrRightAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := AStr
    else
      Result := StringOfChar(' ', ALen - vLen) + AStr;
  end;


  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := Copy(AStr, 1, ALen)
    else
      Result := AStr + StringOfChar(' ', ALen - vLen);
  end;


  function StrDeleteChars(const Str :TString; const Chars :TAnsiCharSet) :TString;
  var
    I, J, L :Integer;
  begin
    Result := '';

    L := Length(Str);
    I := 1;
    while I <= L do begin
      J := I;
      while (I <= L) and not CharInSet(Str[I], Chars) do
        Inc(I);

      if I > J then
        Result := Result + Copy(Str, J, I - J);

      while (I <= L) and CharInSet(Str[I], Chars) do
        Inc(I);
    end;
  end;


  function StrReplaceChars(const Str :TString; const Chars :TAnsiCharSet; Chr :TChar) :TString;
  var
    I : Integer;
  begin
    Result := Str;
    for I := 1 to Length(Str) do
      if CharInSet(Result[I], Chars) then
        Result[I] := Chr;
  end;


  function StrReplace(const S, OldPattern, NewPattern :TString; Flags :TReplaceFlags) :TString;
  var
    SearchStr, Patt, NewStr: TString;
    Offset: Integer;
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


  function ChrExpandTabsLen(AStr :PTChar; ALen :Integer; ATabLen :Integer = DefTabSize) :Integer;
  var
    vEnd :PTChar;
  begin
    Result := 0;
    vEnd := AStr + ALen;
    while AStr < vEnd do begin
      if AStr^ <> charTab then
        Inc(Result)
      else
        Inc(Result, ATabLen - (Result mod ATabLen));
      Inc(AStr);
    end;
  end;


  function ChrExpandTabs(AStr :PTChar; ALen :Integer; ATabLen :Integer = DefTabSize) :TString;
  var
    vEnd, vDst :PTChar;
    vPos, vDstLen, vSize :Integer;
  begin
    vDstLen := ChrExpandTabsLen(AStr, ALen, ATabLen);
    SetString(Result, nil, vDstLen);
    vDst := PTChar(Result);
    vEnd := AStr + ALen;
    vPos := 0;
    while AStr < vEnd do begin
      if AStr^ <> charTab then begin
        Assert(vPos < vDstLen);
        vDst^ := AStr^;
        Inc(vDst);
        Inc(vPos);
      end else
      begin
        vSize := ATabLen - (vPos mod ATabLen);
        Assert(vPos + vSize <= vDstLen);
        MemFillChar(vDst, vSize, ' ');
        Inc(vDst, vSize);
        Inc(vPos, vSize);
      end;
      Inc(AStr);
    end;
  end;


  function StrExpandTabs(const AStr :TString; ATabLen :Integer = DefTabSize) :TString;
  begin
    Result := ChrExpandTabs(PTChar(AStr), Length(AStr), ATabLen)
  end;


  function WordCount(const S :TString; const Del :TAnsiCharSet) :Integer;
  var
    L, I :Integer;
  begin
    Result := 0;
    if S <> '' then begin
      L := length(S);
      I := 1;
      while I <= L do begin
        while (I <= L) and {$ifdef bUnicode} CharInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
          Inc(I);
        if I <= L then
          Inc(Result);
        while (I <= L) and not {$ifdef bUnicode} CharInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
          Inc(I);
      end;
    end;
  end;


  function ExtractWordsPos(Number, Count :Integer; const S :TString; const Del :TAnsiCharSet; var B :Integer) :TString;
  var
    N2, L, I, W :Integer;
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
      while (I <= L) and {$ifdef bUnicode} CharInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
        Inc(I);

      W := 1;
      while I <= L do begin
        if W = Number then
          B := I;
        while (I <= L) and not {$ifdef bUnicode} CharInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
          Inc(I);

        if W < N2 then begin
          Inc(W);
          while (I <= L) and {$ifdef bUnicode} CharInSet(S[I], Del) {$else} (S[I] in Del) {$endif} do
            Inc(I);
        end else
          Break;
      end;

      if I > B then
        Result := Copy(S, B, I - B);
    end;
  end;


  function ExtractWords(Number, Count :Integer; const S :TString; const Del :TAnsiCharSet) :TString;
  var
    P :Integer;
  begin
    Result := ExtractWordsPos(Number, Count, S, Del, P);
  end;


  function ExtractWord(Number :Integer; const S :TString; const Del :TAnsiCharSet) :TString;
  begin
    Result := ExtractWords(Number, 1, S, Del);
  end;


  function Chr2StrL(Str :PTChar; ALen :Integer) :TString;
  begin
    SetString(Result, Str, ALen);
  end;


  function ExtractNextWord(var Str :PTChar; const Del :TAnsiCharSet; ASkipFirst :Boolean = False) :TString;
  var
    P :PTChar;
  begin
    P := Str;
    if ASkipFirst then begin
      while (P^ <> #0) and CharInSet(P^, Del) do
        Inc(P);
      Str := P;
    end;
    while (P^ <> #0) and not CharInSet(P^, Del) do
      Inc(P);
    Result := Chr2StrL(Str, P - Str);
    while (P^ <> #0) and CharInSet(P^, Del) do
      Inc(P);
    Str := P;
  end;


  function ExtractNextValue(var Str :PTChar; const Del :TAnsiCharSet) :TString;
  var
    P :PTChar;
  begin
    P := Str;
    while (P^ <> #0) and not CharInSet(P^, Del) do
      Inc(P);
    Result := Chr2StrL(Str, P - Str);
    if P^ <> #0 then
      Inc(P);
    Str := P;
  end;


  function ExtractNextInt(var Str :PTChar; const Del :TAnsiCharSet) :Integer;
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
    L, L2 :Integer;
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


  function ClearFileExt(const FileName :TString) :TString;
  var
    I :Integer;
  begin
    I := LastDelimiter('.', FileName);
    if I > 0 then
      Result := Copy(FileName, 1, I - 1)
    else
      Result := FileName;
  end;


  function ExtractFileTitle(const FileName :TString) :TString;
  begin
    Result := ClearFileExt(ExtractFileName(FileName));
  end;


  function ExtractFileExtension(const FileName :TString) :TString;
  var
    I :Integer;
  begin
    I := LastDelimiter('.\:', FileName);
    if (I > 0) and (FileName[I] = '.') then
      Result := Copy(FileName, I + 1, MaxInt)
    else
      Result := '';
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
    else
    if (Length(FileName) >= 2) and (FileName[1] = '\') and (FileName[2] = '\') then begin
      J := 0;
      I := 3;
      while (I < Length(FileName)) and (J < 2) do begin
        if FileName[I] = '\' then
          Inc(J);
        if J < 2 then
          Inc(I);
      end;
      if FileName[I] = '\' then
        Dec(I);
      Result := Copy(FileName, 1, I);
    end else
      Result := '';
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


  function ChangeFileExtension(const FileName, Extension :TString) :TString;
  var
    I :Integer;
  begin
    Result := FileName;
    if FileName <> '' then begin
      I := ChrsLastPos(['.', '\', ':'], Filename);
      if (I = 0) or (FileName[I] <> '.') then
        I := MaxInt;
      if Extension <> '' then
        Result := Copy(FileName, 1, I - 1) + '.' + Extension
      else
        Result := Copy(FileName, 1, I - 1);
    end;
  end;


  function SafeChangeFileExtension(const FileName, Extension: TString) :TString;
  var
    I: Integer;
  begin
    Result := FileName;
    if FileName <> '' then begin
      I := ChrsLastPos(['.', '\', ':'], Filename);
      if (I = 0) or ((FileName[I] <> '.') and (I < Length(FileName))) then
        Result := FileName + '.' + Extension;
    end;
  end;


  function FileNameHasMask(const FileName :TString) :Boolean;
  begin
    Result := LastDelimiter('*?', FileName) <> 0;
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
  type
    TDirsArray = array[0..129] of PTChar;

    function ExtractFilePathNoDrive(const FileName :TString) :TString;
    begin
      Result := ExtractFilePath(FileName);
      Result := Copy(Result, Length(ExtractFileDrive(FileName)) + 1, 32767);
    end;

    procedure SplitDirs(var Path :TString; var Dirs :TDirsArray; var DirCount: Integer);
    var
      I, J: Integer;
    begin
      I := 1;
      J := 0;
      while I <= Length(Path) do
      begin
        if Path[I] = '\' then begin
          Path[I] := #0;
          Dirs[J] := PTChar(Path) + I;
//        Dirs[J] := @Path[I + 1];
          Inc(J);
        end;
        Inc(I);
      end;
      DirCount := J - 1;
    end;

  var
    I, J: Integer;
    BasePath, DestPath :TString;
    BaseDirs, DestDirs :TDirsArray;
    BaseDirCount, DestDirCount: Integer;
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
        Result := Result + DestDirs[J] + '\';

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
          Result := Result + Chr2StrL(vBeg, vPtr - vBeg);

        Inc(vPtr);
        vBeg := vPtr;
        while (vPtr^ <> #0) and (vPtr^ <> '"') do
          Inc(vPtr);
        Result := Result + Chr2StrL(vBeg, vPtr - vBeg);
        if vPtr^ <> #0 then
          Inc(vPtr);

        vBeg := vPtr;
      end else
        Inc(vPtr);
    end;

    if vPtr > vBeg then
      Result := Result + Chr2StrL(vBeg, vPtr - vBeg);

    AStr := vPtr;
  end;


 {-----------------------------------------------------------------------------}

  function WideToUTF8(const AStr :TWideStr) :TAnsiStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := WideCharToMultiByte(CP_UTF8, 0, PWideChar(AStr), length(AStr), nil, 0, nil, nil);
    if vLen > 0 then begin
      SetLength(Result, vLen);
      WideCharToMultiByte(CP_UTF8, 0, PWideChar(AStr), length(AStr), PAnsiChar(Result), vLen, nil, nil);
    end;
  end;


  function UTF8ToWide(const AStr :TAnsiStr) :TWideStr;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(AStr), length(AStr), nil, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen);
      MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(AStr), length(AStr), PWideChar(Result), vLen);
    end;
  end;


  function ReadAnsiStr(AFile :THandle; ASize :Integer; AMode :TStrFileFormat) :TAnsiStr;
  begin
    SetString(Result, nil, ASize);
    FileRead(AFile, PAnsiChar(Result)^, ASize);
    if AMode = sffOEM then
      {Windows.}OemToCharBuffA(PAnsiChar(Result), PAnsiChar(Result), ASize);
  end;


  function ReadUnicodeStr(AFile :THandle; ASize :Integer) :TWideStr;
  begin
    SetString(Result, nil, (ASize + 1) div 2);
    FileRead(AFile, PWideChar(Result)^, ASize);
  end;


  function ReadUTF8Str(AFile :THandle; ASize :Integer) :TWideStr;
  var
    vAStr :TAnsiStr;
  begin
    SetString(vAStr, nil, ASize);
    FileRead(AFile, PAnsiChar(vAStr)^, ASize);
    Result := UTF8ToWide(vAStr);
  end;


  function CheckBOM(AFile :THandle; const aHeader :ShortString) :Boolean;
  var
    vHeader :String[10];
  begin
    Byte(vHeader[0]) := FileRead(AFile, vHeader[1], Length(aHeader));
    Result := aHeader = vHeader;
    if not Result then
      FileSeek(AFile, 0, 0);
  end;


  function StrDetectFormat(const AFileName :TString) :TStrFileFormat;
  var
    vFile :THandle;
  begin
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile = INVALID_HANDLE_VALUE then
      ApiCheck(False);
    try
      if CheckBOM(vFile, BOM_UTF16) then
        Result := sffUnicode
      else
      if CheckBOM(vFile, BOM_UTF8) then
        Result := sffUTF8
      else
        Result := sffAnsi;
    finally
      FileClose(vFile);
    end;
  end;


  function StrFromFile(const AFileName :TString; AMode :TStrFileFormat = sffAuto; ACheckBOM :Boolean = True) :TString;
  var
    vFile :THandle;
    vSize :Integer;
  begin
    Result := '';
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile = INVALID_HANDLE_VALUE then
      ApiCheck(False);
    try
      vSize := GetFileSize(vFile, nil);

      if ((AMode = sffAuto) or (AMode = sffUnicode) or ACheckBOM) and CheckBOM(vFile, BOM_UTF16) then begin
        AMode := sffUnicode;
        Dec(vSize, Length(BOM_UTF16));
      end else
      if ((AMode = sffAuto) or (AMode = sffUTF8) or ACheckBOM) and CheckBOM(vFile, BOM_UTF8) then begin
        AMode := sffUTF8;
        Dec(vSize, Length(BOM_UTF8));
      end else
      if AMode = sffAuto then
        AMode := sffAnsi;

      if vSize > 0 then begin
        case AMode of
          sffAnsi,sffOEM:
            Result := TString(ReadAnsiStr(vFile, vSize, AMode));
          sffUnicode:
            Result := ReadUnicodeStr(vFile, vSize);
          sffUTF8:
            Result := ReadUTF8Str(vFile, vSize);
        end;
      end;

    finally
      FileClose(vFile);
    end;
  end;


  procedure StrToFile(const AFileName :TString; const AStr :TString; AMode :TStrFileFormat = sffAuto);
  var
    vFile :THandle;

    procedure LocWriteAnsi(const AStr :TAnsiStr);
    begin
      FileWrite(vFile, PAnsiChar(AStr)^, Length(AStr));
    end;

    procedure LocWriteUnicode(const AStr :TWideStr);
    begin
      FileWrite(vFile, BOM_UTF16[1], length(BOM_UTF16));
      FileWrite(vFile, PWideChar(AStr)^, Length(AStr) * SizeOf(WideChar));
    end;

    procedure LocWriteUTF8(const AStr :TWideStr);
    var
      vAStr :TAnsiStr;
    begin
      vAStr := WideToUTF8(AStr);
      FileWrite(vFile, BOM_UTF8[1], length(BOM_UTF8));
      FileWrite(vFile, PAnsiChar(vAStr)^, Length(vAStr));
    end;

  begin
    if AMode = sffAuto then
     {$ifdef bUnicode}
      AMode := sffUnicode;
     {$else}
      AMode := sffAnsi;
     {$endif bUnicode}

    vFile := FileCreate(AFileName);
    if vFile = INVALID_HANDLE_VALUE then
      ApiCheck(False);
    try
      case AMode of
        sffAnsi,sffOEM:
          LocWriteAnsi(TAnsiStr(AStr));
        sffUnicode:
          LocWriteUnicode(AStr);
        sffUTF8:
          LocWriteUTF8(AStr);
      end;
    finally
      FileClose(vFile);
    end;
  end;


end.

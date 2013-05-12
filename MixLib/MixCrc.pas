{$I Defines.inc}

{$OverflowChecks Off}
{$RangeChecks Off}

unit MixCrc;

interface

uses
  Windows,
  MixTypes,
  MixUtils;

 {-----------------------------------------------------------------------------}
 { CRC32                                                                       }
 {-----------------------------------------------------------------------------}

  type
    TCRC = TUns32;

  function CalcCRC32(p :Pointer; Count :Integer; InitCRC :TCRC): TCRC;
  function CalcCRC32Str(const AStr :TString) :TCRC;
  function CalcCRC32UpStr(const AStr :TString) :TCRC;

  procedure AddCRC(var ACRC: TCRC; const ABuffer; ACount :Integer);
  procedure AddCRCByte(var ACRC: TCRC; AVal: Byte);
  procedure AddCRCBoolean(var ACRC: TCRC; AVal: Boolean);
  procedure AddCRCInt32(var ACRC: TCRC; AVal :TInt32);
  procedure AddCRCInt64(var ACRC: TCRC; AVal :TInt64);
  procedure AddCRCFloat(var ACRC: TCRC; AVal :TFloat);
  procedure AddCRCStr(var ACRC: TCRC; const AVal: TString);
  procedure AddCRCUpStr(var ACRC: TCRC; const AVal: TString);

  function CRC2Str(ACRC :TCRC) :TString;

 {-----------------------------------------------------------------------------}
 { CRC64                                                                       }
 {-----------------------------------------------------------------------------}

  type
    TCRC64 = TInt64;

  function CalcCRC64(AData :Pointer; ACount :Integer; AInitCRC :TCRC64) :TCRC64;
  procedure AddCRC64(var ACRC :TCRC64; const ABuffer; ACount :Integer);
  procedure AddCRC64Str(var ACRC :TCRC64; const AVal :TString);

  function CRC64ToStr(ACRC :TCRC64) :TString;

 {-----------------------------------------------------------------------------}
 { MD5                                                                         }
 {-----------------------------------------------------------------------------}

  type
    TMD5Context = record
      State: array[0..3] of TInt32;
      Count: array[0..1] of TInt32;
      case byte of
      0: (BufChar: array[0..63] of Byte);
      1: (BufLong: array[0..15] of TInt32);
    end;
    TMD5Digest = array[0..15] of AnsiChar;

  procedure MD5Init(var MD5Context: TMD5Context);
  procedure MD5Transform(var Buf: array of TInt32; const Data: array of TInt32);
  procedure MD5UpdateBuffer(var MD5Context: TMD5Context; Buffer: Pointer; ACount :Integer);
  procedure MD5Final(var Digest: TMD5Digest; var MD5Context: TMD5Context);
  function MD5MakeDidgest(var MD5Context :TMD5Context) :TMD5Digest;

  function GetMD5(Buffer :Pointer; BufSize :Integer): TString;
  function StrMD5(const AStr :TString) :TString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { CRC32                                                                       }
 {-----------------------------------------------------------------------------}

  var
    cCRC32Table :array[0..255] of TUns32 = (
      $00000000, $77073096, $EE0E612C, $990951BA,
      $076DC419, $706AF48F, $E963A535, $9E6495A3,
      $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
      $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
      $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
      $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
      $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
      $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
      $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
      $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
      $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
      $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
      $26D930AC, $51DE003A, $C8D75180, $BFD06116,
      $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
      $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
      $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
      $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
      $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
      $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
      $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
      $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
      $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
      $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
      $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
      $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
      $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
      $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
      $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
      $5005713C, $270241AA, $BE0B1010, $C90C2086,
      $5768B525, $206F85B3, $B966D409, $CE61E49F,
      $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
      $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
      $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
      $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
      $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
      $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
      $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
      $F762575D, $806567CB, $196C3671, $6E6B06E7,
      $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
      $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
      $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
      $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
      $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
      $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
      $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
      $CC0C7795, $BB0B4703, $220216B9, $5505262F,
      $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
      $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
      $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
      $9C0906A9, $EB0E363F, $72076785, $05005713,
      $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
      $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
      $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
      $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
      $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
      $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
      $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
      $A7672661, $D06016F7, $4969474D, $3E6E77DB,
      $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
      $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
      $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
      $BAD03605, $CDD70693, $54DE5729, $23D967BF,
      $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
      $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);


  function CalcCRC32(p :Pointer; Count :Integer; InitCRC :TCRC): TCRC;
  var
    i :Integer;
  begin
    Result := InitCRC;
    for i := 1 to Count do begin
      Result := (Result shr 8) xor cCRC32Table[ Byte(P^) xor (Result and $000000FF) ];
      Inc(Pointer1(P));
    end;
  end;


  procedure AddCRC(var ACRC: TCRC; const ABuffer; ACount :Integer);
  begin
    ACRC := CalcCRC32(@ABuffer, ACount, ACRC);
  end;

  procedure AddCRCByte(var ACRC: TCRC; AVal: Byte);
  begin
    TUns32(ACRC) := (ACRC shr 8) xor cCRC32Table[AVal xor (ACRC and $000000FF)];
  end;

  procedure AddCRCBoolean(var ACRC: TCRC; AVal: Boolean);
  begin
    TUns32(ACRC) := (ACRC shr 8) xor cCRC32Table[Byte(AVal) xor (ACRC and $000000FF)];
  end;


  procedure AddCRCInt32(var ACRC: TCRC; AVal :TInt32);
  begin
    ACRC := CalcCRC32(@AVal, SizeOf(AVal), ACRC);
  end;

  procedure AddCRCInt64(var ACRC: TCRC; AVal :TInt64);
  begin
    ACRC := CalcCRC32(@AVal, SizeOf(AVal), ACRC);
  end;


  procedure AddCRCFloat(var ACRC: TCRC; AVal: TFloat);
  begin
    ACRC := CalcCRC32(@AVal, SizeOf(AVal), ACRC);
  end;

  procedure AddCRCStr(var ACRC: TCRC; const AVal: TString);
  begin
    ACRC := CalcCRC32(PTChar(AVal), Length(AVal) * SizeOf(TChar), ACRC);
  end;



  procedure AddCRCUpStr(var ACRC: TCRC; const AVal: TString);
  const
    cBufSize = 256;
  var
    vBuf :Array[0..cBufSize - 1] of TChar;
    vLen, vPart :Integer;
    vChr :PTChar;
  begin
    vLen := Length(AVal);
    vChr := PTChar(AVal);
    while vLen > 0 do begin
      vPart := vLen;
      if vPart > cBufSize then
        vPart := cBufSize;                                           
//    FastMove1(vChr, @vBuf, vPart * SizeOf(TChar));
      Move(vChr^, vBuf, vPart * SizeOf(TChar));
      CharUpperBuff(@vBuf[0], vPart);
      ACRC := CalcCRC32(@vBuf, vPart * SizeOf(TChar), ACRC);
      Inc(vChr, vPart);
      Dec(vLen, vPart);
    end;
  end;



  function CalcCRC32Str(const AStr :TString): TCRC;
  begin
    Result := CalcCRC32(PTChar(AStr), Length(AStr) * SizeOf(TChar), 0);
  end;


  function CalcCRC32UpStr(const AStr :TString): TCRC;
  begin
    Result := 0;
    AddCRCUpStr(Result, AStr);
  end;


  function CRC2Str(ACRC: TCRC): TString;
  begin
    Result := HexStr(ACRC, 8);
  end;


 {-----------------------------------------------------------------------------}
 { CRC64                                                                       }
 {-----------------------------------------------------------------------------}

  var
    FCRC64Table :array[0..255] of TInt64;
    FCRC64TableInited :Boolean = False;

  procedure InitCRC64Table;
  var
    I, J :Byte;
    vValue :TInt64;
  begin
    for I := Low(FCRC64Table) to High(FCRC64Table) do begin
      vValue := I;
      for J := 1 to 8 do
        if Odd(vValue) then
          vValue := vValue shr 1 xor $C96C5795D7870F42 {образующий полином}
        else
          vValue := vValue shr 1;
      FCRC64Table[I] := vValue;
    end;
    FCRC64TableInited := True;
  end;


  function CalcCRC64(AData :Pointer; ACount :Integer; AInitCRC :TCRC64) :TCRC64;
  var
    I :Integer;
    vMyCRC64 :TInt64;
    vData :PByte absolute AData;
  begin
    if not FCRC64TableInited then
      InitCRC64Table;
    vMyCRC64 := AInitCRC; {в цикле - не var-переменная: так быстрее}
    for I := 1 to ACount do begin
      { Кастинг в Cardinal ускоряет код - нет расширения $FF до Int64. Кстати, }
      { кастинг в Byte замедляет код, несмотря на то, что тогда можно убрать }
      { "and $FF" - очевидно, "уменьшительный" кастинг не оптимизируется. }
      vMyCRC64 := vMyCRC64 shr 8 xor FCRC64Table[TUns32(vMyCRC64) and $FF xor vData^];
      Inc(vData);
    end;
    Result := vMyCRC64;
  end;


  procedure AddCRC64(var ACRC :TCRC64; const ABuffer; ACount :Integer);
  begin
    ACRC := CalcCRC64(@ABuffer, ACount, ACRC);
  end;


  procedure AddCRC64Str(var ACRC :TCRC64; const AVal :TString);
  begin
    ACRC := CalcCRC64(PTChar(AVal), Length(AVal) * SizeOf(TChar), ACRC);
  end;


  function CRC64ToStr(ACRC :TCRC64) :TString;
  begin
    Result := HexStr(ACRC, 16);
  end;


 {-----------------------------------------------------------------------------}
 { MD5                                                                         }
 {-----------------------------------------------------------------------------}

  const
    MaxBufSize = 16384;

  type
    PMD5Buffer = ^TMD5Buffer;
    TMD5Buffer = array[0..(MaxBufSize - 1)] of Char;


  { MD5 initialization. Begins an MD5 operation, writing a new context.         }
  procedure MD5Init(var MD5Context: TMD5Context);
  begin
    FillChar(MD5Context, SizeOf(TMD5Context), #0);
    with MD5Context do begin
      { Load magic initialization constants. }
      State[0] := TInt32($67452301);
      State[1] := TInt32($EFCDAB89);
      State[2] := TInt32($98BADCFE);
      State[3] := TInt32($10325476);
    end
  end;


  { MD5 block update operation. Continues an MD5 message-digest operation,      }
  { processing another message block, and updating the context.                 }
  procedure MD5Update( var MD5Context: TMD5Context; const Data; Len :TInt32);
  type
    TByteArray = array[0..MaxInt - 1] of Byte;
  var
    Index: Word;
    T :TInt32;
  begin
    with MD5Context do begin
      T := Count[0];
      Inc(Count[0], Len shl 3);
      if Count[0] < T then
        Inc(Count[1]);
      Inc(Count[1], Len shr 29);
      T := (T shr 3) and $3F;
      Index := 0;
      if T <> 0 then begin
        Index := T;
        T := 64 - T;
        if Len < T then begin
          Move(Data, BufChar[Index], Len);
          Exit;
        end;
        Move(Data, BufChar[Index], T);
        MD5Transform(State, BufLong);
        Dec(Len, T);
        Index := T;  { Wolfgang Klein, 05/06/99 }
      end;
      while Len >= 64 do begin
        Move(TByteArray(Data)[Index], BufChar, 64);
        MD5Transform(State, BufLong);
        Inc(Index, 64);
        Dec(Len, 64);
      end;
      Move(TByteArray(Data)[Index], BufChar, Len);
    end
  end;


  { MD5 finalization. Ends an MD5 message-digest operation, writing the message }
  { digest and zeroizing the context.                                           }
  procedure MD5Final(var Digest: TMD5Digest; var MD5Context: TMD5Context);
  var
    Cnt : Word;
    P   : Byte;
  begin
    with MD5Context do begin
      Cnt := (Count[0] shr 3) and $3F;
      P := Cnt;
      BufChar[P] := $80;
      Inc(P);
      Cnt := 64 - 1 - Cnt;
      if Cnt < 8 then begin
        FillChar(BufChar[P], Cnt, #0);
        MD5Transform(State, BufLong);
        FillChar(BufChar, 56, #0);
      end else
        FillChar(BufChar[P], Cnt - 8, #0);
      BufLong[14] := Count[0];
      BufLong[15] := Count[1];
      MD5Transform(State, BufLong);
      Move(State, Digest, 16)
    end;
    FillChar(MD5Context, SizeOf(TMD5Context), #0)
  end;


  { MD5 basic transformation. Transforms state based on block.                  }
  procedure MD5Transform( var Buf: array of TInt32; const Data: array of TInt32);
  var
    A, B, C, D: TInt32;

    procedure Round1(var W: TInt32; X, Y, Z, Data: TInt32; S: Byte);
    begin
      Inc(W, (Z xor (X and (Y xor Z))) + Data);
      W := (W shl S) or (W shr (32 - S));
      Inc(W, X)
    end;

    procedure Round2(var W: TInt32; X, Y, Z, Data: TInt32; S: Byte);
    begin
      Inc(W, (Y xor (Z and (X xor Y))) + Data);
      W := (W shl S) or (W shr (32 - S));
      Inc(W, X)
    end;

    procedure Round3(var W: TInt32; X, Y, Z, Data: TInt32; S: Byte);
    begin
      Inc(W, (X xor Y xor Z) + Data);
      W := (W shl S) or (W shr (32 - S));
      Inc(W, X)
    end;

    procedure Round4(var W: TInt32; X, Y, Z, Data: TInt32; S: Byte);
    begin
      Inc(W, (Y xor (X or not Z)) + Data);
      W := (W shl S) or (W shr (32 - S));
      Inc(W, X)
    end;

  begin
    A := Buf[0];
    B := Buf[1];
    C := Buf[2];
    D := Buf[3];

    Round1(A, B, C, D, Data[ 0] + TInt32($d76aa478),  7);
    Round1(D, A, B, C, Data[ 1] + TInt32($e8c7b756), 12);
    Round1(C, D, A, B, Data[ 2] + TInt32($242070db), 17);
    Round1(B, C, D, A, Data[ 3] + TInt32($c1bdceee), 22);
    Round1(A, B, C, D, Data[ 4] + TInt32($f57c0faf),  7);
    Round1(D, A, B, C, Data[ 5] + TInt32($4787c62a), 12);
    Round1(C, D, A, B, Data[ 6] + TInt32($a8304613), 17);
    Round1(B, C, D, A, Data[ 7] + TInt32($fd469501), 22);
    Round1(A, B, C, D, Data[ 8] + TInt32($698098d8),  7);
    Round1(D, A, B, C, Data[ 9] + TInt32($8b44f7af), 12);
    Round1(C, D, A, B, Data[10] + TInt32($ffff5bb1), 17);
    Round1(B, C, D, A, Data[11] + TInt32($895cd7be), 22);
    Round1(A, B, C, D, Data[12] + TInt32($6b901122),  7);
    Round1(D, A, B, C, Data[13] + TInt32($fd987193), 12);
    Round1(C, D, A, B, Data[14] + TInt32($a679438e), 17);
    Round1(B, C, D, A, Data[15] + TInt32($49b40821), 22);

    Round2(A, B, C, D, Data[ 1] + TInt32($f61e2562),  5);
    Round2(D, A, B, C, Data[ 6] + TInt32($c040b340),  9);
    Round2(C, D, A, B, Data[11] + TInt32($265e5a51), 14);
    Round2(B, C, D, A, Data[ 0] + TInt32($e9b6c7aa), 20);
    Round2(A, B, C, D, Data[ 5] + TInt32($d62f105d),  5);
    Round2(D, A, B, C, Data[10] + TInt32($02441453),  9);
    Round2(C, D, A, B, Data[15] + TInt32($d8a1e681), 14);
    Round2(B, C, D, A, Data[ 4] + TInt32($e7d3fbc8), 20);
    Round2(A, B, C, D, Data[ 9] + TInt32($21e1cde6),  5);
    Round2(D, A, B, C, Data[14] + TInt32($c33707d6),  9);
    Round2(C, D, A, B, Data[ 3] + TInt32($f4d50d87), 14);
    Round2(B, C, D, A, Data[ 8] + TInt32($455a14ed), 20);
    Round2(A, B, C, D, Data[13] + TInt32($a9e3e905),  5);
    Round2(D, A, B, C, Data[ 2] + TInt32($fcefa3f8),  9);
    Round2(C, D, A, B, Data[ 7] + TInt32($676f02d9), 14);
    Round2(B, C, D, A, Data[12] + TInt32($8d2a4c8a), 20);

    Round3(A, B, C, D, Data[ 5] + TInt32($fffa3942),  4);
    Round3(D, A, B, C, Data[ 8] + TInt32($8771f681), 11);
    Round3(C, D, A, B, Data[11] + TInt32($6d9d6122), 16);
    Round3(B, C, D, A, Data[14] + TInt32($fde5380c), 23);
    Round3(A, B, C, D, Data[ 1] + TInt32($a4beea44),  4);
    Round3(D, A, B, C, Data[ 4] + TInt32($4bdecfa9), 11);
    Round3(C, D, A, B, Data[ 7] + TInt32($f6bb4b60), 16);
    Round3(B, C, D, A, Data[10] + TInt32($bebfbc70), 23);
    Round3(A, B, C, D, Data[13] + TInt32($289b7ec6),  4);
    Round3(D, A, B, C, Data[ 0] + TInt32($eaa127fa), 11);
    Round3(C, D, A, B, Data[ 3] + TInt32($d4ef3085), 16);
    Round3(B, C, D, A, Data[ 6] + TInt32($04881d05), 23);
    Round3(A, B, C, D, Data[ 9] + TInt32($d9d4d039),  4);
    Round3(D, A, B, C, Data[12] + TInt32($e6db99e5), 11);
    Round3(C, D, A, B, Data[15] + TInt32($1fa27cf8), 16);
    Round3(B, C, D, A, Data[ 2] + TInt32($c4ac5665), 23);

    Round4(A, B, C, D, Data[ 0] + TInt32($f4292244),  6);
    Round4(D, A, B, C, Data[ 7] + TInt32($432aff97), 10);
    Round4(C, D, A, B, Data[14] + TInt32($ab9423a7), 15);
    Round4(B, C, D, A, Data[ 5] + TInt32($fc93a039), 21);
    Round4(A, B, C, D, Data[12] + TInt32($655b59c3),  6);
    Round4(D, A, B, C, Data[ 3] + TInt32($8f0ccc92), 10);
    Round4(C, D, A, B, Data[10] + TInt32($ffeff47d), 15);
    Round4(B, C, D, A, Data[ 1] + TInt32($85845dd1), 21);
    Round4(A, B, C, D, Data[ 8] + TInt32($6fa87e4f),  6);
    Round4(D, A, B, C, Data[15] + TInt32($fe2ce6e0), 10);
    Round4(C, D, A, B, Data[ 6] + TInt32($a3014314), 15);
    Round4(B, C, D, A, Data[13] + TInt32($4e0811a1), 21);
    Round4(A, B, C, D, Data[ 4] + TInt32($f7537e82),  6);
    Round4(D, A, B, C, Data[11] + TInt32($bd3af235), 10);
    Round4(C, D, A, B, Data[ 2] + TInt32($2ad7d2bb), 15);
    Round4(B, C, D, A, Data[ 9] + TInt32($eb86d391), 21);

    Inc(Buf[0], A);
    Inc(Buf[1], B);
    Inc(Buf[2], C);
    Inc(Buf[3], D);
  end;


  procedure MD5UpdateBuffer(var MD5Context: TMD5Context; Buffer: Pointer; ACount :Integer);
  var
    vPtr :Pointer1;
    vPart :Integer;
  begin
    vPtr := Buffer;
    while ACount > 0 do begin
      vPart := ACount;
      if vPart > MaxBufSize then
        vPart := MaxBufSize;
      MD5Update(MD5Context, vPtr^, TInt32(vPart));
      Inc(vPtr, vPart);
      Dec(ACount, vPart);
    end;
  end;


  function MD5MakeDidgest(var MD5Context :TMD5Context) :TMD5Digest;
  var
    I :Integer;
  begin
    for I := 0 to 15 do
      Byte(Result[I]) := I + 1;
    MD5Final(Result, MD5Context);
  end;


  function GetMD5(Buffer: Pointer; BufSize :Integer) :TString;
  var
    MD5Context :TMD5Context;
    MD5Digest :TMD5Digest;
  begin
    MD5Init(MD5Context);
    MD5UpdateBuffer(MD5Context, Buffer, BufSize);
    MD5Digest := MD5MakeDidgest(MD5Context);

    Result := BinToHexStr(@MD5Digest, SizeOf(MD5Digest));
  end;


  function StrMD5(const AStr :TString) :TString;
  begin
    Result := GetMD5(PTChar(AStr), Length(AStr) * SizeOf(TChar));
  end;

end.

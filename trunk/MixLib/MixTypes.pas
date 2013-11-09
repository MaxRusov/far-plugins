{$I Defines.inc}

unit MixTypes;

interface

  type
    { Платформонезависимые целые }

    TInt32 = longint;
    PInt32 = ^TInt32;

    TUns32 = LongWord;
    PUns32 = ^TUns32;

    TInt64 = int64;
//  PInt64 = ^TInt64;

   {$ifdef bDelphi}
    qword = Int64;
   {$endif bDelphi}

    TUns64 = qword;
    PUns64 = ^TUns64;

    { Платформозависимые целые }

   {$ifdef bFreePascal}
    TIntPtr = PtrInt;
    TUnsPtr = PtrUInt;
   {$else}

   {$ifdef b64}
    TIntPtr = IntPtr;
    TUnsPtr = UIntPtr;
   {$else}
    TIntPtr = Integer;
    TUnsPtr = Cardinal;
   {$endif b64}

   {$endif bFreePascal}

    PIntPtr = ^TIntPtr;
    PUnsPtr = ^TUnsPtr;

    
  type
   {$ifdef bFloatIsDouble}
    TFloat = Double;
   {$else}
    TFloat = Extended;
   {$endif bFloatIsDouble}
    PFloat = ^TFloat;

  type
   {$ifdef bUnicode}
    TChar = WideChar;
    PTChar = PWideChar;
   {$else}
    TChar = AnsiChar;
    PTChar = PAnsiChar;
   {$endif bUnicode}

    TAnsiStr = AnsiString;
    PAnsiStr = PAnsiString;
   {$ifdef bUnicodeStr}
    TWideStr = UnicodeString;
    PWideStr = PUnicodeString;
   {$else}
    TWideStr = WideString;
    PWideStr = PWideString;
   {$endif bUnicodeStr}
    TAutoStr = WideString;
    PAutoStr = ^WideString;

   {$ifdef bUnicode}
    TString = TWideStr;
   {$else}
    TString = TAnsiStr;
   {$endif bUnicode}
    PTString = ^TString;

  type
   {$ifdef bUnicodeRTL}
    TRTLChar = WideChar;
    PRTLChar = PWideChar;
    TRTLStr = TWideStr;
    PRTLStr = PWideStr;
   {$else}
    TRTLChar = AnsiChar;
    PRTLChar = PAnsiChar;
    TRTLStr = TAnsiStr;
    PRTLStr = PAnsiStr;
   {$endif bUnicodeRTL}

   {$ifdef bUnicodeRTL}
    TSysStr = TString;
   {$else}
    TSysStr = ShortString;
   {$endif bUnicodeRTL}

  const
   {$ifdef bUnicode}
    _X = 'W';
   {$else}
    _X = 'A';
   {$endif bUnicode}


  type
   {$ifdef bDelphi15}
    Pointer1 = PByte;
   {$else}
    Pointer1 = PAnsiChar;
   {$endif bDelphi15}

   {$ifdef bDelphi}
    PPointer = ^Pointer;
   {$endif bDelphi}

    TAnsiCharSet = set of AnsiChar;


 {-----------------------------------------------------------------------------}
 { Типы, не рекомендуемые к использованию                                      }

  type
    TUnusedType = packed record end;

//var
//  string :TUnusedType;
//  pstring :TUnusedType;

//  char :TUnusedType;
//  pchar :TUnusedType;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


end.




























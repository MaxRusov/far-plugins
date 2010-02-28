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

   {$ifdef b64}
    TUns64 = qword;
    PUns64 = ^TUns64;
   {$endif b64}

    { Платформозависимые целые }

   {$ifdef bFreePascal}
    TIntPtr = PtrInt;
    TUnsPtr = PtrUInt;
   {$else}

   {$ifdef b64}
    // Delphi 64...
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
    Pointer1 = PAnsiChar;
   {$ifdef bDelphi}
    LONG = TInt32;
    PPointer = ^Pointer;
   {$endif bDelphi}

    TAnsiCharSet = set of AnsiChar;


  procedure NOP;

  function GetStackFrame :Pointer;
  function GetStackFrame2 :Pointer;
  function ReturnAddr :Pointer;
  function ReturnAddr2 :Pointer;
  function ReturnAddr3 :Pointer;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  procedure NOP;
  begin
  end;


 {$ifdef b64}
  function GetStackFrame :Pointer; assembler; nostackframe;
  asm
    MOV  RAX, RBP
  end;

  function GetStackFrame2 :Pointer; assembler; nostackframe;
  asm
    MOV  RAX, RBP
    MOV  RAX, [RAX]
  end;

  function ReturnAddr :Pointer; assembler; nostackframe;
  asm
    MOV  RAX, RBP
    MOV  RAX, [RAX + 8]
  end;

  function ReturnAddr2 :Pointer; assembler; nostackframe;
  asm
    MOV  RAX, [RBP]
    MOV  RAX, [RAX + 8]
  end;

  function ReturnAddr3 :Pointer; assembler; nostackframe;
  asm
    MOV  RAX, [RBP]
    MOV  RAX, [RAX]
    MOV  RAX, [RAX + 8]
  end;

 {$else}

  function GetStackFrame :Pointer;
  asm
    MOV  EAX, EBP
  end;

  function GetStackFrame2 :Pointer;
  asm
    MOV  EAX, EBP
    MOV  EAX, [EAX]
  end;

  function ReturnAddr :Pointer;
  asm
    MOV  EAX, EBP
    MOV  EAX, [EAX + 4]
  end;

  function ReturnAddr2 :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX + 4]
  end;

  function ReturnAddr3 :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX]
    MOV  EAX, [EAX + 4]
  end;

 {$endif b64}


end.











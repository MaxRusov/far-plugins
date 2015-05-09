{$I Defines.inc}

unit MixDebug;

interface

  uses
    Windows,
    MixTypes,
    MixUtils;


  var
    cTrue :Boolean = True;

  procedure NOP;

 {$ifdef bStackX64}
  function CaptureStackBackTrace(FramesToSkip :TUns32{ULONG}; FramesToCapture :TUns32{ULONG}; BackTrace :Pointer; BackTraceHash :PUns32{PULONG}) :Word{USHORT}; stdcall;
  function ReturnAddr :Pointer; overload;
  function ReturnAddr2 :Pointer;
  function ReturnAddr(ASkip :Integer) :Pointer; overload;
 {$else}
  function GetStackFrame :Pointer;
  function GetStackFrame2 :Pointer;
  function ReturnAddr :Pointer;
  function ReturnAddr2 :Pointer;
  function ReturnAddr3 :Pointer;
 {$endif bStackX64}

  function GetAllocAddr :Pointer;
  procedure SetAllocAddr(Addr :Pointer);
  function GetAndClearAllocAddr :Pointer;

  function GetAllocFrame :Pointer;
  procedure SetAllocFrame(Frame :Pointer);
  function GetAndClearAllocFrame :Pointer;

  procedure SetReturnAddr;
  procedure SetReturnAddrNewInstance;
  procedure SetErrorAddress(aAddr :Pointer);
  procedure TraceException(AAddr :Pointer; const AClass :TSysStr; const AMessage :TString);

 {$ifdef bTrace}
  procedure TraceStr(AMsg :PTChar);
  procedure TraceStrA(AMsg :PAnsiChar);
  procedure TraceStrW(AMsg :PWideChar);

  procedure TraceStrF(AMsg :PTChar; const Args: array of const);
  procedure TraceStrFA(AMsg :PAnsiChar; const Args: array of const);
  procedure TraceStrFW(AMsg :PWideChar; const Args: array of const);

  procedure Trace(const AMsg :TString); overload;
  procedure TraceA(const AMsg :TAnsiStr); overload;
  procedure TraceW(const AMsg :TWideStr); overload;

  procedure Trace(const AMsg :TString; const Args: array of const); overload;
  procedure TraceA(const AMsg :TAnsiStr; const Args: array of const); overload;
  procedure TraceW(const AMsg :TWideStr; const Args: array of const); overload;

  procedure TraceF(const AMsg :TString; const Args: array of const);
  procedure TraceFA(const AMsg :TAnsiStr; const Args: array of const);
  procedure TraceFW(const AMsg :TWideStr; const Args: array of const);

  procedure TraceBeg(const AMsg :TString);
  procedure TraceBegF(const AMsg :TString; const Args: array of const);
  procedure TraceEnd(const AMsg :TString);
 {$endif bTrace}

  procedure DebugBreak(AMess :PTChar);

  function B2S(const Data {:Pointer}; Size :Integer) :AnsiString;
  function P2S(Data :Pointer; Size :Integer) :AnsiString;
  function B2H(const Data {:Pointer}; Size :Integer) :AnsiString;
  function P2H(Data :Pointer; Size :Integer) :AnsiString;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

 {$ifdef bTrace}
  uses
    MixFormat;
 {$endif bTrace}


  procedure NOP;
  begin
  end;


  function ChrCopyShortStr(Dest :PTChar; const Source :ShortString) :PTChar;
  var
    vLen :Integer;
  begin
    vLen := Length(Source);
    if vLen > 0 then
     {$ifdef bUnicode}
      MultiByteToWideChar(CP_ACP, 0, @Source[1], vLen, Dest, vLen);
     {$else}
      Move(Source[1], Dest^, vLen);
     {$endif bUnicode}
    (Dest + vLen)^ := #0;
    Result := Dest + vLen;
  end;


  function ChrCopyL(Dest, Source :PTChar; Len, BufLen :Integer) :PTChar;
  begin
    if Len > BufLen - 1 then
      Len := BufLen - 1;
    if Len > 0 then
      Move(Source^, Dest^, Len * SizeOf(TChar));
    (Dest + Len)^ := #0;
    Result := Dest + Len;
  end;


  function ChrCopy(Dest, Source :PTChar; Len :Integer) :PTChar;
  begin
    Result := ChrCopyL(Dest, Source, Len, Len + 1);
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bStackX64}
  function CaptureStackBackTrace; external 'kernel32.dll' name 'RtlCaptureStackBackTrace';


  function ReturnAddr :Pointer;
  begin
    if CaptureStackBackTrace(2, 1, @Result, nil) = 0 then
      Result := nil;
  end;


  function ReturnAddr2 :Pointer;
  begin
    if CaptureStackBackTrace(3, 1, @Result, nil) = 0 then
      Result := nil;
  end;


  function ReturnAddr(ASkip :Integer) :Pointer;
  begin
    if CaptureStackBackTrace(ASkip + 1, 1, @Result, nil) = 0 then
      Result := nil;
  end;

 {$else}

 {$ifdef b64}
  function GetStackFrame :Pointer; assembler; {$ifdef bFreePascal}nostackframe;{$endif}
  asm
    MOV  RAX, RBP
  end;

  function GetStackFrame2 :Pointer; assembler; {$ifdef bFreePascal}nostackframe;{$endif}
  asm
    MOV  RAX, RBP
    MOV  RAX, [RAX]
  end;

  function ReturnAddr :Pointer; assembler; {$ifdef bFreePascal}nostackframe;{$endif}
  asm
    MOV  RAX, RBP
    MOV  RAX, [RAX + 8]
  end;

  function ReturnAddr2 :Pointer; assembler; {$ifdef bFreePascal}nostackframe;{$endif}
  asm
    MOV  RAX, [RBP]
    MOV  RAX, [RAX + 8]
  end;

  function ReturnAddr3 :Pointer; assembler; {$ifdef bFreePascal}nostackframe;{$endif}
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
 {$endif bStackX64}


 {-----------------------------------------------------------------------------}

  threadvar
    AllocAddr :Pointer;


  procedure SetAllocAddr(Addr :Pointer);
  begin
    AllocAddr := Addr;
  end;

  function GetAllocAddr :Pointer;
  begin
    Result := AllocAddr;
  end;

  function GetAndClearAllocAddr :Pointer;
  var
    vPtr :PPointer;
  begin
    vPtr := @AllocAddr;
    Result := vPtr^;
    if Result <> nil then
      vPtr^ := nil;
  end;


  threadvar
    AllocFrame :Pointer;

  procedure SetAllocFrame(Frame :Pointer);
  begin
    AllocFrame := Frame;
  end;

  function GetAllocFrame :Pointer;
  begin
    Result := AllocFrame;
  end;

  function GetAndClearAllocFrame :Pointer;
  var
    vPtr :PPointer;
  begin
    vPtr := @AllocFrame;
    Result := vPtr^;
    if Result <> nil then
      vPtr^ := nil;
  end;


  procedure SetReturnAddr;
  begin
   {$ifdef bStackX64}
    if GetAllocAddr = nil then
      SetAllocAddr( ReturnAddr(2) );
   {$else}

   {$ifdef bFreePascal}
    if GetAllocFrame = nil then
      SetAllocFrame( GetStackFrame2 );
   {$else}
    if GetAllocAddr = nil then
      SetAllocAddr( ReturnAddr2 );
   {$endif bFreePascal}

   {$endif bStackX64}
  end;


  procedure SetReturnAddrNewInstance;
  begin
   {$ifdef bStackX64}
    if GetAllocAddr = nil then
      SetAllocAddr( ReturnAddr(4) );
   {$else}

   {$ifdef bFreePascal}
    if GetAllocFrame = nil then
      SetAllocFrame( GetStackFrame2 );
   {$else}
    if GetAllocAddr = nil then
      SetAllocAddr( ReturnAddr3 );
   {$endif bFreePascal}

   {$endif bStackX64}
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bTrace}

  function ConvertAddr(Address :Pointer) :Pointer;
  begin
//  if (PChar(Address) > PChar($1)) and (PChar(Address) < PChar($10000000)) then
//    Result := Pointer1(Address) - $00400000
//  else
      Result := Address;
  end;


  procedure TraceCallstack(AAddr :Pointer);
 {$ifdef bStackX64}
  const
    { Windows Server 2003 and Windows XP:  The sum of the FramesToSkip and FramesToCapture parameters must be less than 63. }
    { http://msdn.microsoft.com/en-us/library/windows/desktop/bb204633%28v=vs.85%29.aspx }
    MaxStackLen = 60;
  var
    I, vCount :Integer;
    vChr :PTChar;
    vStack :array[0..MaxStackLen] of Pointer;
    vStr :array[0..MaxStackLen * (SizeOf(Pointer)*2 + 3)] of TChar;
  begin
    try
     {$ifdef bDebug}
      FillChar(vStack, SizeOf(vStack), 0);
     {$endif bDebug}
      vCount := CaptureStackBackTrace(1, MaxStackLen, @vStack, nil);
    except
      vCount := 0;
    end;

    vChr := @vStr[0];
    if vCount > 0 then begin
      for I := 0 to vCount - 1 do begin
        vChr := ChrCopy(vChr, ' : ', 3);
        vChr := ChrCopyPtr(vChr, vStack[I]);
      end;
    end else
      vChr := ChrCopy(vChr, ' : !!!', 6);

    vChr^ := #0;
    TraceStr(@vStr[0]);
 {$else}
  const
    MaxStackLen = 60;
  var
    vCount :Integer;
    vPtr :Pointer;
    vChr :PTChar;
    vProcess :THandle;
    vRead :SIZE_T;
    vBuf :array[0..1] of Pointer;
    vStr :array[0..MaxStackLen * (SizeOf(Pointer)*2 + 3)] of TChar;
  begin
    vPtr := GetStackFrame;
    vProcess := GetCurrentProcess;

    vCount := 0;
    vChr := @vStr[0];
    while (vCount < MaxStackLen) and (vPtr <> nil) and ReadProcessMemory(vProcess, vPtr, @vBuf, SizeOf(vBuf), vRead) and (vRead = SizeOf(vBuf)) do begin
      vChr := ChrCopy(vChr, ' : ', 3);
      vChr := StrCopyPtr(vChr, vBuf[1]);

      vPtr := vBuf[0];
      Inc(vCount);
    end;

    vChr^ := #0;
    TraceStr(@vStr[0]);
 {$endif bStackX64}
  end;

 {$endif bTrace}

 {-----------------------------------------------------------------------------}

  threadvar
//  debSkipNextError :Boolean {= False};
    debErrorAddress :Pointer {= nil};


  procedure SetErrorAddress(aAddr :Pointer);
  begin
    if debErrorAddress = nil then
      debErrorAddress := aAddr;
  end;


  procedure TraceException(AAddr :Pointer; const AClass :TSysStr; const AMessage :TString);
 {$ifdef bTrace}
  const
    MaxErrorLen = 4096;
  var
    vAddr :Pointer;
    vStr  :array[0..MaxErrorLen] of TChar;
    vPtr :PTChar;
  begin
//  if debSkipNextError then begin
//    debSkipNextError := False;
//    Exit;
//  end;

    vAddr := debErrorAddress;
    if vAddr = nil then
      vAddr := AAddr
    else
      debErrorAddress := nil;
    if vAddr = nil then
      vAddr := ReturnAddr2;

    FillChar(vStr, SizeOf(vStr), '.');
    vPtr := @vStr[0];
    vPtr := ChrCopy(vPtr, 'Error at ', 9);
    vPtr := StrCopyPtr(vPtr, vAddr);
    vPtr := ChrCopy(vPtr, ', ', 2);

   {$ifdef bUnicodeRTL}
    vPtr := ChrCopy(vPtr, PTChar(AClass), Length(AClass));
   {$else}
    vPtr := ChrCopyShortStr(vPtr, AClass);
   {$endif bUnicodeRTL}

    vPtr := ChrCopy(vPtr, ': ', 2);
   {vPtr :=}ChrCopyL(vPtr, PTChar(AMessage), length(AMessage), MaxErrorLen - (vPtr - @vStr[0]));

    TraceStr(@vStr[0]);

//  if not IsDebuggerPresent then
      TraceCallstack(AAddr);
 {$else}
  begin
 {$endif bTrace}
  end;



 {$ifdef bTrace}
  const
   {$ifdef bDelphi}
   {$ifdef b64}
    cTraceDll = 'MSTraceLib64.dll';
   {$else}
    cTraceDll = 'MSTraceLib.dll';
   {$endif b64}
   {$else}
   {$ifdef b64}
    cTraceDll = 'MSTraceLib64.dll';
   {$else}
    cTraceDll = 'MSTraceLib32.dll';
   {$endif b64}
   {$endif bDelphi}


  procedure dllTraceA(AInst :THandle; AMsg :PAnsiChar) stdcall;
    external cTraceDll name 'TraceA';
  procedure dllTraceW(AInst :THandle; AMsg :PWideChar) stdcall;
    external cTraceDll name 'TraceW';

  procedure dllTraceFmtA(AInst :THandle; AMsg :PAnsiChar; const Args: array of const); stdcall;
    external cTraceDll name 'TraceFmtA';
  procedure dllTraceFmtW(AInst :THandle; AMsg :PWideChar; const Args: array of const); stdcall;
    external cTraceDll name 'TraceFmtW';


  procedure TraceStr(AMsg :PTChar);
  begin
   {$ifdef bUnicode}
    dllTraceW(HInstance, AMsg);
   {$else}
    dllTraceA(HInstance, AMsg);
   {$endif bUnicode}
  end;

  procedure TraceStrA(AMsg :PAnsiChar);
  begin
    dllTraceA(HInstance, AMsg);
  end;

  procedure TraceStrW(AMsg :PWideChar);
  begin
    dllTraceW(HInstance, AMsg);
  end;


  procedure TraceStrF(AMsg :PTChar; const Args: array of const);
  begin
   {$ifdef bUnicode}
    dllTraceFmtW(HInstance, AMsg, Args);
   {$else}
    dllTraceFmtA(HInstance, AMsg, Args);
   {$endif bUnicode}
  end;

  procedure TraceStrFA(AMsg :PAnsiChar; const Args: array of const);
  begin
    dllTraceFmtA(HInstance, AMsg, Args);
  end;

  procedure TraceStrFW(AMsg :PWideChar; const Args: array of const);
  begin
    dllTraceFmtW(HInstance, AMsg, Args);
  end;


  procedure Trace(const AMsg :TString);
  begin
   {$ifdef bUnicode}
    TraceW(AMsg);
   {$else}
    TraceA(AMsg);
   {$endif bUnicode}
  end;

  procedure TraceA(const AMsg :TAnsiStr);
  begin
    dllTraceA(HInstance, PAnsiChar(AMsg));
  end;

  procedure TraceW(const AMsg :TWideStr);
  begin
    dllTraceW(HInstance, PWideChar(AMsg));
  end;


  procedure Trace(const AMsg :TString; const Args: array of const);
  begin
   {$ifdef bUnicode}
    TraceW(AMsg, Args);
   {$else}
    TraceA(AMsg, Args);
   {$endif bUnicode}
  end;

  procedure TraceA(const AMsg :TAnsiStr; const Args: array of const);
  begin
    dllTraceFmtA(HInstance, PAnsiChar(AMsg), Args);
  end;

  procedure TraceW(const AMsg :TWideStr; const Args: array of const);
  begin
    dllTraceFmtW(HInstance, PWideChar(AMsg), Args);
  end;


  procedure TraceF(const AMsg :TString; const Args: array of const);
  begin
   {$ifdef bUnicode}
    TraceFW(AMsg, Args);
   {$else}
    TraceFA(AMsg, Args);
   {$endif bUnicode}
  end;

  procedure TraceFA(const AMsg :TAnsiStr; const Args: array of const);
  begin
    dllTraceFmtA(HInstance, PAnsiChar(AMsg), Args);
  end;

  procedure TraceFW(const AMsg :TWideStr; const Args: array of const);
  begin
    dllTraceFmtW(HInstance, PWideChar(AMsg), Args);
  end;



  threadvar
    gStart :DWORD;
    gStart1 :DWORD;

  procedure TraceBeg(const AMsg :TString);
  begin
    Trace(AMsg);
    gStart1 := gStart;
    gStart := GetTickCount;
  end;

  procedure TraceBegF(const AMsg :TString; const Args: array of const);
  begin
    TraceF(AMsg, Args);
    gStart1 := gStart;
    gStart := GetTickCount;
  end;

  procedure TraceEnd(const AMsg :TString);
  begin
    TraceF('%s (%d ms)', [AMsg, TickCountDiff(GetTickCount, gStart)]);
    gStart := gStart1
  end;
 {$endif bTrace}



  procedure DebugBreak(AMess :PTChar);
  begin
    try
      raise EDebugRaise.Create(AMess)
       {$ifopt W+} at ReturnAddr {$endif W+};
    except
      NOP;
    end;
  end;


  function B2S(const Data {:Pointer}; Size :Integer) :AnsiString;
  var
    I :Integer;
  begin
    SetString(Result, PAnsiChar(@Data), Size);
    for I := 1 to Size do
      if Result[I] < ' ' then
        Result[I] := '.';
  end;

  function P2S(Data :Pointer; Size :Integer) :AnsiString;
  begin
    Result := B2S(Data^, Size);
  end;



  function B2H(const Data {:Pointer}; Size :Integer) :AnsiString;
  const
    A :array[0..$F] of AnsiChar = '0123456789ABCDEF';
  var
    I :Integer;
    P, S :PAnsiChar;
  begin
    SetLength(Result, Size * 3 - 1);
    P := @Data;
    S := PAnsiChar(Result);
    for I := 1 to Size do begin
      S^ := A[(Byte(P^) and $F0) shr 4];
      Inc(S);
      S^ := A[(Byte(P^) and $0F)];
      Inc(S);
      if I < Size then begin
        S^ := ' ';
        Inc(S);
        Inc(P);
      end;
    end;
  end;

(*
  function B2Hr(const Data {:Pointer}; Size :Integer) :AnsiString;
  const
    A :array[0..$F] of AnsiChar = '0123456789ABCDEF';
  var
    I :TInteger;
    P, S :PAnsiChar;
  begin
    SetLength(Result, Size * 3 - 1);
    P := PAnsiChar(@Data) + Size - 1;
    S := PAnsiChar(Result);
    for I := 1 to Size do begin
      S^ := A[(Byte(P^) and $F0) shr 4];
      Inc(S);
      S^ := A[(Byte(P^) and $0F)];
      Inc(S);
      if I < Size then begin
        S^ := ' ';
        Inc(S);
        Dec(P);
      end;
    end;
  end;
*)

  function P2H(Data :Pointer; Size :Integer) :AnsiString;
  begin
    Result := B2H(Data^, Size);
  end;


{$ifdef bDebug}
initialization
  Assert( @P2S <> nil );
  Assert( @P2H <> nil );
{$endif bDebug}
end.

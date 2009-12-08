{$I Defines.inc}

unit MixDebug;

interface

  uses
    Windows,
    MixTypes,
    MixUtils;

  procedure DebugBreak(AMess :PTChar);

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

  procedure Trace(const AMsg :TString);
  procedure TraceA(const AMsg :TAnsiStr);
  procedure TraceW(const AMsg :TWideStr);
  
  procedure TraceF(const AMsg :TString; const Args: array of const);
  procedure TraceFA(const AMsg :TAnsiStr; const Args: array of const);
  procedure TraceFW(const AMsg :TWideStr; const Args: array of const);
 {$endif bTrace}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

 {$ifdef bTrace}
  uses
    MixFormat;
 {$endif bTrace}


  function IntMin(L1, L2 :Integer) :Integer;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;

  
  function ChrCopyPtrA(Dest :PAnsiChar; APtr :Pointer) :PAnsiChar;
  const
    HexChars :array[0..15] of AnsiChar = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
  var
    I :Integer;
    N :TUnsPtr;
    D :Byte;
  begin
    N := TUnsPtr(APtr);
    for I := SizeOf(Pointer) * 2 - 1 downto 0 do begin
      D := N and $F;
      N := N shr 4;
      (Dest + I)^ := HexChars[D];
    end;
    Result := Dest + SizeOf(Pointer) * 2;
  end;


  function ChrCopyShortStr(Dest :PAnsiChar; const Source :ShortString) :PAnsiChar;
  var
    vLen :Integer;
  begin
    vLen := Length(Source);
    if vLen > 0 then
      Move(Source[1], Dest^, vLen);
    (Dest + vLen)^ := #0;
    Result := Dest + vLen;
  end;


  function ChrCopyAL(Dest, Source :PAnsiChar; Len, BufLen :Integer) :PAnsiChar;
  begin
    if Len > BufLen - 1 then
      Len := BufLen - 1;
    if Len > 0 then
      Move(Source^, Dest^, Len * SizeOf(AnsiChar));
    (Dest + Len)^ := #0;
    Result := Dest + Len;
  end;


  function ChrCopyA(Dest, Source :PAnsiChar; Len :Integer) :PAnsiChar;
  begin
    Result := ChrCopyAL(Dest, Source, Len, Len + 1);
  end;


  procedure DebugBreak(AMess :PTChar);
  begin
    try
      raise EDebugRaise.Create(AMess)
       {$ifopt W+} at ReturnAddr {$endif W+};
    except
      NOP;
    end;
  end;

 {-----------------------------------------------------------------------------}

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
   {$ifdef bFreePascal}
    if GetAllocFrame = nil then
      SetAllocFrame( GetStackFrame2 );
   {$else}
    if GetAllocAddr = nil then
      SetAllocAddr( ReturnAddr2 );
   {$endif bFreePascal}
  end;


  procedure SetReturnAddrNewInstance;
  begin
   {$ifdef bFreePascal}
    if GetAllocFrame = nil then
      SetAllocFrame( GetStackFrame2 );
   {$else}
    if GetAllocAddr = nil then
      SetAllocAddr( ReturnAddr3 );
   {$endif bFreePascal}
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

 {$ifdef bLinux}
  function IsBadWritePtr(AAddr :Pointer; ALen :TInteger) :Boolean;
  begin
    Result := False;
  end;
 {$endif bLinux}

  procedure TraceCallstack(AAddr :Pointer);
  const
    MaxStackLen = 50;
  var
    I, J :Integer;
    vPtr :Pointer;
    vAdr :Pointer;
    vStr :array[0..MaxStackLen * (SizeOf(Pointer)*2 + 3)] of AnsiChar;
  begin
    asm
     {$ifdef b64}
      MOV  vPtr, RBP
     {$else}
      MOV  vPtr, EBP
     {$endif b64}
    end;

    I := 0;
    J := 0;
    while (vPtr <> nil) and not IsBadReadPtr(vPtr, SizeOf(Pointer)*2) and (J < MaxStackLen) do begin
      vAdr := ConvertAddr(PPointer(Pointer1(vPtr) + SizeOf(Pointer))^);

      lstrcpya(@vStr[I], ' : ');
      Inc(I, 3);

      ChrCopyPtrA(@vStr[I], vAdr);
      Inc(I, SizeOf(Pointer)*2);

      vPtr := PPointer(vPtr)^;
      Inc(J);
    end;

    vStr[I] := #0;
    TraceStrA(@vStr[0]);
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
    vStr  :array[0..MaxErrorLen] of AnsiChar;
//  vName :ShortString;
    vPtr :PAnsiChar;
    vLen :Integer;
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

//  vName := GetThreadName;

    FillChar(vStr, SizeOf(vStr), '.');
    vPtr := @vStr[0];
    vPtr := ChrCopyA(vPtr, 'Error at ', 9);
    vPtr := ChrCopyPtrA(vPtr, vAddr);
    vPtr := ChrCopyA(vPtr, ', ', 2);
//  vPtr := ChrCopyShortStr(vPtr, vName);
//  vPtr := ChrCopy(vPtr, ', ', 2);
    {!Unicode}
    vPtr := ChrCopyShortStr(vPtr, AClass);
    vPtr := ChrCopyA(vPtr, ': ', 2);
   {$ifdef bUnicode}
    vLen := IntMin(length(AMessage), MaxErrorLen - (vPtr - @vStr[0]));
    Inc(vPtr, WideCharToMultiByte(CP_ACP, 0, PTChar(AMessage), vLen, vPtr, vLen, nil, nil));
    vPtr^ := #0;
   {$else}
    vLen := MaxErrorLen - (vPtr - @vStr[0]);
    ChrCopyAL(vPtr, PTChar(AMessage), length(AMessage), vLen);
   {$endif bUnicode}

    TraceStrA(@vStr[0]);

//  if not IsDebuggerPresent then
      TraceCallstack(AAddr);
 {$else}
  begin
 {$endif bTrace}
  end;


 {$ifdef bTrace}
  const
   {$ifdef bDelphi}
    cTraceDll = 'MSTraceLib.dll';
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
 {$endif bTrace}


end.

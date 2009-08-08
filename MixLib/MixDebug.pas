{$I Defines.inc}

unit MixDebug;

interface

  uses
    Windows,
    MixTypes;


  procedure SetReturnAddr;
  procedure SetReturnAddrNewInstance;
  procedure SetErrorAddress(aAddr :Pointer);
  procedure TraceException(AAddr :Pointer; const AClass :ShortString; const AMessage :TString);

 {$ifdef bTrace}
  procedure TraceStr(AMsg :PAnsiChar);
  procedure TraceStrF(AMsg :PAnsiChar; const Args: array of const);
  procedure Trace(const AMsg :TAnsiStr);
  procedure TraceF(const AMsg :TAnsiStr; const Args: array of const);
 {$endif bTrace}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  function IntMin(L1, L2 :TInteger) :TInteger;
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
    I :TInteger;
    N :TCardinal;
    D :Byte;
  begin
    N := TCardinal(APtr);
    for I := SizeOf(Pointer) * 2 - 1 downto 0 do begin
      D := N and $F;
      N := N shr 4;
      (Dest + I)^ := HexChars[D];
    end;
    Result := Dest + SizeOf(Pointer) * 2;
  end;


  function ChrCopyShortStr(Dest :PAnsiChar; const Source :ShortString) :PAnsiChar;
  var
    vLen :TInteger;
  begin
    vLen := Length(Source);
    if vLen > 0 then
      Move(Source[1], Dest^, vLen);
    (Dest + vLen)^ := #0;
    Result := Dest + vLen;
  end;


  function ChrCopyAL(Dest, Source :PAnsiChar; Len, BufLen :TInteger) :PAnsiChar;
  begin
    if Len > BufLen - 1 then
      Len := BufLen - 1;
    if Len > 0 then
      Move(Source^, Dest^, Len * SizeOf(AnsiChar));
    (Dest + Len)^ := #0;
    Result := Dest + Len;
  end;


  function ChrCopyA(Dest, Source :PAnsiChar; Len :TInteger) :PAnsiChar;
  begin
    Result := ChrCopyAL(Dest, Source, Len, Len + 1);
  end;


 {-----------------------------------------------------------------------------}

  procedure SetReturnAddr;
  begin
    {!!!}
  end;


  procedure SetReturnAddrNewInstance;
  begin
    {!!!}
  end;


 {-----------------------------------------------------------------------------}

  threadvar
//  debSkipNextError :Boolean {= False};
    debErrorAddress :Pointer {= nil};


  procedure SetErrorAddress(aAddr :Pointer);
  begin
    if debErrorAddress = nil then
      debErrorAddress := aAddr;
  end;


  procedure TraceException(AAddr :Pointer; const AClass :ShortString; const AMessage :TString);
 {$ifdef bTrace}
  const
    MaxErrorLen = 4096;
  var
    vAddr :Pointer;
    vStr  :array[0..MaxErrorLen] of AnsiChar;
//  vName :ShortString;
    vPtr :PAnsiChar;
    vLen :TInteger;
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

    TraceStr(@vStr[0]);

//  if not IsDebuggerPresent then
//    TraceCallstack(AAddr);
 {$else}
  begin
 {$endif bTrace}
  end;


 {$ifdef bTrace}
  const
   {$ifdef b64}
    cTraceDll = 'MSTraceLib64';
   {$else}
    cTraceDll = 'MSTraceLib';
   {$endif b64}


  procedure dllTrace(AInst :THandle; AMsg :PAnsiChar) stdcall;
    external cTraceDll name 'Trace';
  procedure dllTraceFmt(AInst :THandle; AMsg :PAnsiChar; const Args: array of const); stdcall;
    external cTraceDll name 'TraceFmt';


  procedure TraceStr(AMsg :PAnsiChar);
  begin
    dllTrace(HInstance, AMsg);
  end;

  procedure TraceStrF(AMsg :PAnsiChar; const Args: array of const);
  begin
    dllTraceFmt(HInstance, AMsg, Args);
  end;

  procedure Trace(const AMsg :TAnsiStr);
  begin
    dllTrace(HInstance, PAnsiChar(AMsg));
  end;

  procedure TraceF(const AMsg :TAnsiStr; const Args: array of const);
  begin
    dllTraceFmt(HInstance, PAnsiChar(AMsg), Args);
  end;
 {$endif bTrace}


end.

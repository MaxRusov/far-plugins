{$I Defines.inc}

{$ifndef bTrace} {$undef bTraceError} {$endif}

unit MixUtils;

interface

uses
  Windows,
  MixTypes;


const
  { File open modes }

  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;
  fmShareCompat    = $0000;
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead  = $0030;
  fmShareDenyNone  = $0040;

  { File attribute constants }

  faReadOnly  = $00000001;
  faHidden    = $00000002;
  faSysFile   = $00000004;
  faVolumeID  = $00000008;
  faDirectory = $00000010;
  faArchive   = $00000020;
  faAnyFile   = $0000003F;


type
{ General arrays }

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

  PWordArray = ^TWordArray;
  TWordArray = array[0..16383] of Word;

{ Type conversion records }

  WordRec = packed record
    Lo, Hi: Byte;
  end;

  LongRec = packed record
    Lo, Hi: Word;
  end;

  Int64Rec = packed record
    Lo, Hi: DWORD;
  end;

  TMethod = record
    Code, Data: Pointer;
  end;


type
  ExceptClass = class of Exception;

  Exception = class(TObject)
  public
    constructor Create(const msg :TString);
    constructor CreateFmt(const msg :TString; const args : array of const);
    constructor CreateRes(ResString :PString);
    constructor CreateResFmt(ResString :PString; const Args: array of const);
    constructor CreateHelp(const Msg :TString; AHelpContext: Integer);
    constructor CreateFmtHelp(const Msg :TString; const Args: array of const; AHelpContext: Integer);
    constructor CreateResHelp(ResString :PString; AHelpContext: Integer);
    constructor CreateResFmtHelp(ResString :PString; const Args: array of const; AHelpContext: Integer);
  private
    FMessage :TString;
    FHelpContext :TInteger;
  public
    property HelpContext :TInteger read FHelpContext write FHelpContext;
    property Message :TString read FMessage write FMessage;
  end;

  EConvertError = class(Exception);
  EFormatError = class(Exception);
  EAssertionFailed = class(Exception);
  EAbstractError = class(Exception);

  EWin32Error = class(Exception)
  public
    ErrorCode: DWORD;
  end;

  EExternal = class(Exception)
  public
    ExceptionRecord: PExceptionRecord;
  end;

  EAbort = class(Exception);

procedure Abort;

var
  FormatFunc :Function(const Fmt :TString; const Args : Array of const) :TString;

Function Format(const Fmt :TString; const Args : Array of const) :TString;

function LoadStr(Ident: Integer) :TString;
function FmtLoadStr(Ident: Integer; const Args: array of const) :TString;

function StrLen(const Str: PTChar) :Cardinal;
function StrLenA(const Str: PAnsiChar) :Cardinal;
function StrLenW(const Str: PWideChar) :Cardinal;

function StrLCopy(Dest: PTChar; const Source: PTChar; MaxLen: Cardinal): PTChar;
function StrLCopyA(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar;
function StrLCopyW(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;

function StrPCopy(Dest :PTChar; const Source :TString): PTChar;
function StrPCopyA(Dest :PAnsiChar; const Source :TAnsiStr): PAnsiChar;
function StrPCopyW(Dest :PWideChar; const Source :TWideStr): PWideChar;

function StrPLCopy(Dest :PTChar; const Source :TString; MaxLen :Cardinal) :PTChar;
function StrPLCopyA(Dest :PAnsiChar; const Source :TAnsiStr; MaxLen :Cardinal) :PAnsiChar;
function StrPLCopyW(Dest :PWideChar; const Source :TWideStr; MaxLen :Cardinal) :PWideChar;

function StrMove(Dest: PTChar; const Source: PTChar; Count: Cardinal): PTChar;
function StrMoveA(Dest: PAnsiChar; const Source: PAnsiChar; Count: Cardinal): PAnsiChar;
function StrMoveW(Dest: PWideChar; const Source: PWideChar; Count: Cardinal): PWideChar;

function StrScan(const Str :PTChar; Chr :TChar) :PTChar;
function StrScanA(const Str :PAnsiChar; Chr :AnsiChar) :PAnsiChar;
function StrScanW(const Str :PWideChar; Chr :WideChar) :PWideChar;

function StrEnd(const Str: PTChar): PTChar;
function StrEndA(const Str: PAnsiChar): PAnsiChar;
function StrEndW(const Str: PWideChar): PWideChar;

function StrLIComp(const Str1, Str2 :PTChar; MaxLen :Cardinal) :Integer;
function StrLICompA(const Str1, Str2 :PAnsiChar; MaxLen :Cardinal) :Integer;
function StrLICompW(const Str1, Str2 :PWideChar; MaxLen :Cardinal) :Integer;

function StrAlloc(Size: Cardinal) :PTChar;
function StrAllocA(Size: Cardinal) :PAnsiChar;
function StrAllocW(Size: Cardinal): PWideChar;

function StrNew(const Str :PTChar) :PTChar;
function StrNewA(const Str :PAnsiChar) :PAnsiChar;
function StrNewW(const Str :PWideChar) :PWideChar;

procedure StrDispose(Str :PTChar);
procedure StrDisposeA(Str :PAnsiChar);
procedure StrDisposeW(Str :PWideChar);

function Trim(const S :TString) :TString;
function TrimLeft(const S :TString) :TString;
function TrimRight(const S :TString) :TString;

function AnsiStrLIComp(S1, S2 :PTChar; MaxLen: Cardinal): Integer;
function AnsiQuotedStr(const S :TString; Quote :TChar) :TString;
function AnsiExtractQuotedStr(var Src :PTChar; Quote :TChar) :TString;

function SysErrorMessage(ErrorCode: Integer) :TString;
function Win32Check(RetVal: BOOL): BOOL;
procedure RaiseLastWin32Error;

function FileOpen(const FileName :TString; Mode: LongWord): Integer;
function FileCreate(const FileName :TString): Integer;
function FileRead(Handle: Integer; var Buffer; Count: LongWord): Integer;
function FileWrite(Handle: Integer; const Buffer; Count: LongWord): Integer;
function FileSeek(Handle, Offset, Origin: Integer): Integer; overload;
function FileSeek(Handle: Integer; const Offset: Int64; Origin: Integer): Int64; overload;
procedure FileClose(Handle: Integer);
function FileAge(const FileName :TString): Integer;
function FileGetAttr(const FileName :TString): Integer;
function FileSetAttr(const FileName :TString; Attr: Integer): Integer;

procedure Beep;

{$ifdef bFreePascal}
var
  MainThreadID :THandle;
{$endif bFreePascal}

{------------------------------------------------------------------------------}

  type
    TException = class(Exception)
    end;

    EAppError = class(TException);

    EDebugRaise = class(TException);
    EUnderConstruction = class(TException);

  procedure FreeObj(var Obj {:TObject});

  function MemAlloc(Size :TInteger) :Pointer;
  function MemAllocZero(Size :TInteger) :Pointer;
  procedure MemFree(var P {:Pointer});

  procedure AppError(const ErrorStr :TString);
  procedure AppErrorFmt(const ErrorStr :TString; const Args: array of const);
  procedure AppErrorRes(ResString :PString);
  procedure AppErrorResFmt(ResString :PString; const Args: array of const);
  procedure RaiseError(aClass :ExceptClass; const ErrorStr :TString);

  procedure ApiCheck(ARes :Boolean);
  procedure ApiCheckCode(Code :TInteger);

  procedure Sorry;
  procedure Wrong;
  procedure AbstractError;

  function LocalAddr(Proc :Pointer) :TMethod;

  function TickCountDiff(AValue1, AValue2 :DWORD) :TInteger;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixConsts,
    MixDebug;

  {------------------------------------------------------------------------------}
  { Exception                                                                    }
  {------------------------------------------------------------------------------}

  constructor Exception.Create(const msg :TString);
  begin
    inherited create;
    FMessage := msg;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateFmt(const msg :TString; const args : array of const);
  begin
    inherited create;
    FMessage := Format(msg,args);
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateRes(ResString :PString);
  begin
    inherited create;
    FMessage := ResString^;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateResFmt(ResString :PString; const Args: array of const);
  begin
    inherited create;
    FMessage := Format(ResString^,args);
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateHelp(const Msg:TString; AHelpContext: Integer);
  begin
    inherited create;
    FMessage := Msg;
    FHelpContext := AHelpContext;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateFmtHelp(const Msg:TString; const Args: array of const; AHelpContext: Integer);
  begin
    inherited create;
    FMessage := Format(Msg,args);
    FHelpContext := AHelpContext;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateResHelp(ResString :PString; AHelpContext: Integer);
  begin
    inherited create;
    FMessage := ResString^;
    FHelpContext := AHelpContext;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateResFmtHelp(ResString :PString; const Args: array of const; AHelpContext: Integer);
  begin
    inherited create;
    FMessage := Format(ResString^,args);
    FHelpContext := AHelpContext;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  procedure Abort;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAbort.CreateRes(@SAbortError) at ReturnAddr;
  end;


  {------------------------------------------------------------------------------}
  {                                                                              }
  {------------------------------------------------------------------------------}

  Function Format(const Fmt :TString; const Args : Array of const) :TString;
  begin
    if Assigned(FormatFunc) then
      Result := FormatFunc(Fmt, Args)
    else
      raise Exception.CreateRes(@SNotImplemented);
  end;


  function LoadStr(Ident :Integer) :TString;
  var
    vBuf :array[0..1024] of TChar;
    vLen :TInteger;
  begin
    Result := '';
    vLen := LoadString(HInstance, Ident, @vBuf[0], High(vBuf));
    if vLen > 0 then
      SetString(Result, vBuf, vLen);
  end;


  function FmtLoadStr(Ident: Integer; const Args: array of const) :TString;
  begin
    Result := Format(LoadStr(Ident), Args);
  end;


  function StrLen(const Str :PTChar) :Cardinal;
  begin
   {$ifdef bUnicode}
    Result := StrLenW(Str);
   {$else}
    Result := StrLenA(Str);
   {$endif bUnicode}
  end;

  function StrLenA(const Str :PAnsiChar) :Cardinal; assembler;
  asm
          MOV     EDX,EDI
          MOV     EDI,EAX
          MOV     ECX,0FFFFFFFFH
          XOR     AL,AL
          REPNE   SCASB
          MOV     EAX,0FFFFFFFEH
          SUB     EAX,ECX
          MOV     EDI,EDX
  end;

  function StrLenW(const Str :PWideChar) :Cardinal;
  begin
    Result := {Windows.}lstrlenw(Str);
  end;


  function StrLCopy(Dest: PTChar; const Source: PTChar; MaxLen: Cardinal): PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrLCopyW(Dest, Source, MaxLen);
   {$else}
    Result := StrLCopyA(Dest, Source, MaxLen);
   {$endif bUnicode}
  end;


  function StrLCopyA(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar; assembler;
  asm
    PUSH    EDI
    PUSH    ESI
    PUSH    EBX
    MOV     ESI,EAX
    MOV     EDI,EDX
    MOV     EBX,ECX
    XOR     AL,AL
    TEST    ECX,ECX
    JZ      @@1
    REPNE   SCASB
    JNE     @@1
    INC     ECX
  @@1:
    SUB     EBX,ECX
    MOV     EDI,ESI
    MOV     ESI,EDX
    MOV     EDX,EDI
    MOV     ECX,EBX
    SHR     ECX,2
    REP     MOVSD
    MOV     ECX,EBX
    AND     ECX,3
    REP     MOVSB
    STOSB
    MOV     EAX,EDX
    POP     EBX
    POP     ESI
    POP     EDI
  end;


  function StrLCopyW(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar; assembler;
  asm
    PUSH    EDI
    PUSH    ESI
    PUSH    EBX
    MOV     ESI,EAX
    MOV     EDI,EDX
    MOV     EBX,ECX
    XOR     AX,AX
    TEST    ECX,ECX
    JZ      @@1
    REPNE   SCASW
    JNE     @@1
    INC     ECX
  @@1:
    SUB     EBX,ECX
    MOV     EDI,ESI
    MOV     ESI,EDX
    MOV     EDX,EDI
    MOV     ECX,EBX
    SHR     ECX,1
    REP     MOVSD
    MOV     ECX,EBX
    AND     ECX,1
    REP     MOVSW
    STOSW
    MOV     EAX,EDX
    POP     EBX
    POP     ESI
    POP     EDI
  end;



  function StrPCopy(Dest :PTChar; const Source :TString) :PTChar;
  begin
    Result := StrLCopy(Dest, PTChar(Source), Length(Source));
  end;

  function StrPCopyA(Dest :PAnsiChar; const Source :TAnsiStr): PAnsiChar;
  begin
    Result := StrLCopyA(Dest, PAnsiChar(Source), Length(Source));
  end;

  function StrPCopyW(Dest :PWideChar; const Source :TWideStr): PWideChar;
  begin
    Result := StrLCopyW(Dest, PWideChar(Source), Length(Source));
  end;


  function StrPLCopy(Dest :PTChar; const Source :TString; MaxLen :Cardinal) :PTChar;
  begin
    Result := StrLCopy(Dest, PTChar(Source), MaxLen);
  end;

  function StrPLCopyA(Dest :PAnsiChar; const Source :TAnsiStr; MaxLen :Cardinal) :PAnsiChar;
  begin
    Result := StrLCopyA(Dest, PAnsiChar(Source), MaxLen);
  end;

  function StrPLCopyW(Dest :PWideChar; const Source :TWideStr; MaxLen :Cardinal) :PWideChar;
  begin
    Result := StrLCopyW(Dest, PWideChar(Source), MaxLen);
  end;


  function StrMove(Dest: PTChar; const Source: PTChar; Count: Cardinal): PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrMoveW(Dest, Source, Count);
   {$else}
    Result := StrMoveA(Dest, Source, Count);
   {$endif bUnicode}
  end;

  function StrMoveW(Dest: PWideChar; const Source: PWideChar; Count: Cardinal): PWideChar;
  begin
    Result := Dest;
    Move(Source^, Dest^, Count * SizeOf(WideChar));
  end;

  function StrMoveA(Dest: PAnsiChar; const Source: PAnsiChar; Count: Cardinal): PAnsiChar; assembler;
  asm
          PUSH    ESI
          PUSH    EDI
          MOV     ESI,EDX
          MOV     EDI,EAX
          MOV     EDX,ECX
          CMP     EDI,ESI
          JA      @@1
          JE      @@2
          SHR     ECX,2
          REP     MOVSD
          MOV     ECX,EDX
          AND     ECX,3
          REP     MOVSB
          JMP     @@2
  @@1:    LEA     ESI,[ESI+ECX-1]
          LEA     EDI,[EDI+ECX-1]
          AND     ECX,3
          STD
          REP     MOVSB
          SUB     ESI,3
          SUB     EDI,3
          MOV     ECX,EDX
          SHR     ECX,2
          REP     MOVSD
          CLD
  @@2:    POP     EDI
          POP     ESI
  end;


  function StrScan(const Str :PTChar; Chr :TChar) :PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrScanW(Str, Chr);
   {$else}
    Result := StrScanA(Str, Chr);
   {$endif bUnicode}
  end;

  function StrScanA(const Str :PAnsiChar; Chr :AnsiChar) :PAnsiChar; assembler;
  asm
          PUSH    EDI
          PUSH    EAX
          MOV     EDI,Str
          MOV     ECX,0FFFFFFFFH
          XOR     AL,AL
          REPNE   SCASB
          NOT     ECX
          POP     EDI
          MOV     AL,Chr
          REPNE   SCASB
          MOV     EAX,0
          JNE     @@1
          MOV     EAX,EDI
          DEC     EAX
  @@1:    POP     EDI
  end;

  function StrScanW(const Str :PWideChar; Chr :WideChar) :PWideChar; assembler;
  asm
          PUSH    EDI
          PUSH    EAX
          MOV     EDI,Str
          MOV     ECX,0FFFFFFFFH
          XOR     AX,AX
          REPNE   SCASW
          NOT     ECX
          POP     EDI
          MOV     AX,Chr
          REPNE   SCASW
          MOV     EAX,0
          JNE     @@1
          MOV     EAX,EDI
          DEC     EAX
          DEC     EAX
  @@1:    POP     EDI
  end;


  function StrEnd(const Str: PTChar): PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrEndW(Str);
   {$else}
    Result := StrEndA(Str);
   {$endif bUnicode}
  end;

  function StrEndA(const Str :PAnsiChar) :PAnsiChar; assembler;
  asm
          MOV     EDX,EDI
          MOV     EDI,EAX
          MOV     ECX,0FFFFFFFFH
          XOR     AL,AL
          REPNE   SCASB
          LEA     EAX,[EDI-1]
          MOV     EDI,EDX
  end;

  function StrEndW(const Str: PWideChar): PWideChar; assembler;
  asm
          MOV     EDX,EDI
          MOV     EDI,EAX
          MOV     ECX,0FFFFFFFFH
          XOR     AX,AX
          REPNE   SCASW
          LEA     EAX,[EDI-2]
          MOV     EDI,EDX
  end;


  function StrLIComp(const Str1, Str2 :PTChar; MaxLen :Cardinal) :Integer;
  begin
   {$ifdef bUnicode}
    Result := StrLICompW(Str1, Str2, MaxLen);
   {$else}
    Result := StrLICompA(Str1, Str2, MaxLen);
   {$endif bUnicode}
  end;

  function StrLICompA(const Str1, Str2 :PAnsiChar; MaxLen :Cardinal) :Integer; assembler;
  asm
          PUSH    EDI
          PUSH    ESI
          PUSH    EBX
          MOV     EDI,EDX
          MOV     ESI,EAX
          MOV     EBX,ECX
          XOR     EAX,EAX
          OR      ECX,ECX
          JE      @@4
          REPNE   SCASB
          SUB     EBX,ECX
          MOV     ECX,EBX
          MOV     EDI,EDX
          XOR     EDX,EDX
  @@1:    REPE    CMPSB
          JE      @@4
          MOV     AL,[ESI-1]
          CMP     AL,'a'
          JB      @@2
          CMP     AL,'z'
          JA      @@2
          SUB     AL,20H
  @@2:    MOV     DL,[EDI-1]
          CMP     DL,'a'
          JB      @@3
          CMP     DL,'z'
          JA      @@3
          SUB     DL,20H
  @@3:    SUB     EAX,EDX
          JE      @@1
  @@4:    POP     EBX
          POP     ESI
          POP     EDI
  end;

  function StrLICompW(const Str1, Str2 :PWideChar; MaxLen :Cardinal) :Integer;
  begin
    Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, Str1, MaxLen, Str2, MaxLen) - 2;
  end;


  function StrAlloc(Size: Cardinal) :PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrAllocW(Size);
   {$else}
    Result := StrAllocA(Size);
   {$endif bUnicode}
  end;

  function StrAllocA(Size :Cardinal) :PAnsiChar;
  begin
    GetMem(Result, Size + SizeOf(Cardinal));
    Cardinal(Pointer(Result)^) := Size;
    Inc(PChar(Result), SizeOf(Cardinal));
  end;

  function StrAllocW(Size :Cardinal) :PWideChar;
  begin
    GetMem(Result, Size * 2 + SizeOf(Cardinal));
    Cardinal(Pointer(Result)^) := Size;
    Inc(PChar(Result), SizeOf(Cardinal));
  end;


  function StrNew(const Str :PTChar) :PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrNewW(Str);
   {$else}
    Result := StrNewA(Str);
   {$endif bUnicode}
  end;

  function StrNewA(const Str :PAnsiChar) :PAnsiChar;
  var
    Size :Cardinal;
  begin
    if Str = nil then
      Result := nil
    else begin
      Size := StrLenA(Str) + 1;
      Result := StrMoveA(StrAllocA(Size), Str, Size);
    end;
  end;

  function StrNewW(const Str :PWideChar) :PWideChar;
  var
    Size :Cardinal;
  begin
    if Str = nil then
      Result := nil
    else begin
      Size := StrLenW(Str) + 1;
      Result := StrMoveW(StrAllocW(Size), Str, Size);
    end;
  end;


  procedure StrDispose(Str :PTChar);
  begin
   {$ifdef bUnicode}
    StrDisposeW(Str);
   {$else}
    StrDisposeA(Str);
   {$endif bUnicode}
  end;

  procedure StrDisposeA(Str :PAnsiChar);
  begin
    if Str <> nil then begin
      Dec(PChar(Str), SizeOf(Cardinal));
      FreeMem(Str);
    end;
  end;

  procedure StrDisposeW(Str :PWideChar);
  begin
    if Str <> nil then begin
      Dec(PChar(Str), SizeOf(Cardinal));
      FreeMem(Str);
    end;
  end;


  function Trim(const S :TString) :TString;
  var
    I, L: Integer;
  begin
    L := Length(S);
    I := 1;
    while (I <= L) and (S[I] <= ' ') do
      Inc(I);
    if I > L then
      Result := ''
    else begin
      while S[L] <= ' ' do
        Dec(L);
      Result := Copy(S, I, L - I + 1);
    end;
  end;

  function TrimLeft(const S :TString) :TString;
  var
    I, L: Integer;
  begin
    L := Length(S);
    I := 1;
    while (I <= L) and (S[I] <= ' ') do
      Inc(I);
    Result := Copy(S, I, Maxint);
  end;

  function TrimRight(const S :TString) :TString;
  var
    I: Integer;
  begin
    I := Length(S);
    while (I > 0) and (S[I] <= ' ') do
      Dec(I);
    Result := Copy(S, 1, I);
  end;

  function AnsiStrLIComp(S1, S2 :PTChar; MaxLen: Cardinal): Integer;
  begin
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, MaxLen, S2, MaxLen) - 2;
  end;

  function AnsiQuotedStr(const S :TString; Quote :TChar) :TString;
  var
    P, Src, Dest :PTChar;
    AddCount: Integer;
  begin
    AddCount := 0;
    P := StrScan(PTChar(S), Quote);
    while P <> nil do begin
      Inc(P);
      Inc(AddCount);
      P := StrScan(P, Quote);
    end;
    if AddCount = 0 then begin
      Result := TString(Quote) + S + TString(Quote);
      Exit;
    end;
    SetLength(Result, Length(S) + AddCount + 2);
    Dest := Pointer(Result);
    Dest^ := Quote;
    Inc(Dest);
    Src := Pointer(S);
    P := StrScan(Src, Quote);
    repeat
      Inc(P);
      StrMove(Dest, Src, P - Src);
      Inc(Dest, P - Src);
      Dest^ := Quote;
      Inc(Dest);
      Src := P;
      P := StrScan(Src, Quote);
    until P = nil;
    P := StrEnd(Src);
    StrMove(Dest, Src, P - Src);
    Inc(Dest, P - Src);
    Dest^ := Quote;
  end;


  function AnsiExtractQuotedStr(var Src :PTChar; Quote :TChar) :TString;
  var
    P, Dest :PTChar;
    DropCount: Integer;
  begin
    Result := '';
    if (Src = nil) or (Src^ <> Quote) then
      Exit;
    Inc(Src);
    DropCount := 1;
    P := Src;
    Src := StrScan(Src, Quote);
    while Src <> nil do  begin
      Inc(Src);
      if Src^ <> Quote then
        Break;
      Inc(Src);
      Inc(DropCount);
      Src := StrScan(Src, Quote);
    end;
    if Src = nil then
      Src := StrEnd(P);
    if ((Src - P) <= 1) then
      Exit;
    if DropCount = 1 then
      SetString(Result, P, Src - P - 1)
    else begin
      SetLength(Result, Src - P - DropCount);
      Dest := PTChar(Result);
      Src := StrScan(P, Quote);
      while Src <> nil do begin
        Inc(Src);
        if Src^ <> Quote then
          Break;
        StrMove(Dest, P, Src - P);
        Inc(Dest, Src - P);
        Inc(Src);
        P := Src;
        Src := StrScan(Src, Quote);
      end;
      if Src = nil then
        Src := StrEnd(P);
      StrMove(Dest, P, Src - P - 1);
    end;
  end;


  function SysErrorMessage(ErrorCode: Integer) :TString;
  const
    cMaxLen = 255;
  var
    Len: Integer;
    Buffer: array[0..cMaxLen] of TChar;
  begin
    Len := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, ErrorCode, 0, Buffer, cMaxLen, nil);
    while (Len > 0) and ((Buffer[Len - 1] <= #32) or (Buffer[Len - 1] = '.')) do
      Dec(Len);
    if Len > 0 then
      SetString(Result, Buffer, Len)
    else
      Result := Format(SUnknownErrorCode, [ErrorCode]);
  end;


  procedure RaiseLastWin32Error;
  var
    LastError: DWORD;
    Error: EWin32Error;
  begin
    LastError := GetLastError;
    if LastError <> ERROR_SUCCESS then
      Error := EWin32Error.CreateResFmt(@SOSError, [LastError,  SysErrorMessage(LastError)])
    else
      Error := EWin32Error.CreateRes(@SUnkOSError);
    Error.ErrorCode := LastError;
    raise Error;
  end;


  function Win32Check(RetVal: BOOL): BOOL;
  begin
    if not RetVal then RaiseLastWin32Error;
    Result := RetVal;
  end;


  procedure Beep;
  begin
    MessageBeep(0);
  end;

  {------------------------------------------------------------------------------}

  function FileOpen(const FileName :TString; Mode: LongWord): Integer;
  const
    AccessMode: array[0..2] of LongWord = (
      GENERIC_READ,
      GENERIC_WRITE,
      GENERIC_READ or GENERIC_WRITE);
    ShareMode: array[0..4] of LongWord = (
      0,
      0,
      FILE_SHARE_READ,
      FILE_SHARE_WRITE,
      FILE_SHARE_READ or FILE_SHARE_WRITE);
  begin
    Result := Integer(CreateFile(PTChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0));
  end;

  function FileCreate(const FileName :TString): Integer;
  begin
    Result := Integer(CreateFile(PTChar(FileName), GENERIC_READ or GENERIC_WRITE,
      0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0));
  end;

  function FileRead(Handle: Integer; var Buffer; Count: LongWord): Integer;
  begin
    if not ReadFile(THandle(Handle), Buffer, Count, LongWord(Result), nil) then
      Result := -1;
  end;

  function FileWrite(Handle: Integer; const Buffer; Count: LongWord): Integer;
  begin
    if not WriteFile(THandle(Handle), Buffer, Count, LongWord(Result), nil) then
      Result := -1;
  end;

  function FileSeek(Handle, Offset, Origin: Integer): Integer;
  begin
    Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
  end;

  function FileSeek(Handle: Integer; const Offset: Int64; Origin: Integer): Int64;
  begin
    Result := Offset;
    Int64Rec(Result).Lo := SetFilePointer(THandle(Handle), Int64Rec(Result).Lo,
      @Int64Rec(Result).Hi, Origin);
  end;

  procedure FileClose(Handle: Integer);
  begin
    CloseHandle(THandle(Handle));
  end;

  function FileAge(const FileName :TString): Integer;
  var
    Handle: THandle;
    FindData: TWin32FindData;
    LocalFileTime: TFileTime;
  begin
    Handle := FindFirstFile(PTChar(FileName), FindData);
    if Handle <> INVALID_HANDLE_VALUE then
    begin
      Windows.FindClose(Handle);
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      begin
        FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
        if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
          LongRec(Result).Lo) then Exit;
      end;
    end;
    Result := -1;
  end;

  function FileGetAttr(const FileName :TString): Integer;
  begin
    Result := GetFileAttributes(PTChar(FileName));
  end;

  function FileSetAttr(const FileName :TString; Attr: Integer): Integer;
  begin
    Result := 0;
    if not SetFileAttributes(PTChar(FileName), Attr) then
      Result := GetLastError;
  end;

{------------------------------------------------------------------------------}


  procedure FreeObj(var Obj {:TObject});
  var
    vTmp :TObject;
  begin
    if TObject(Obj) <> nil then begin
      vTmp := TObject(Obj);
      TObject(Obj) := nil;
      vTmp.Destroy;
    end;
  end;


  function MemAlloc(Size :TInteger) :Pointer;
  begin
    Result := nil;
    if Size <> 0 then begin
     {$ifdef bDebug}
      SetReturnAddr;
     {$endif bDebug}
      GetMem(Result, Size);
    end;
  end;


  function MemAllocZero(Size :TInteger) :Pointer;
  begin
    Result := nil;
    if Size <> 0 then begin
     {$ifdef bDebug}
      SetReturnAddr;
     {$endif bDebug}
      Result := MemAlloc(Size);
      FillChar(Result^, Size, 0);
    end;
  end;


  procedure MemFree(var P {:Pointer});
  begin
    if Pointer(P) <> nil then begin
      FreeMem(Pointer(P));
      Pointer(P) := nil;
    end;
  end;


  procedure AppError(const ErrorStr :TString);
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAppError.Create(ErrorStr)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure AppErrorFmt(const ErrorStr :TString; const Args: array of const);
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAppError.CreateFmt(ErrorStr, Args)
      {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure AppErrorRes(ResString :PString);
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAppError.CreateRes(ResString)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure AppErrorResFmt(ResString :PString; const Args: array of const);
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAppError.CreateResFmt(ResString, Args)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure RaiseError(aClass :ExceptClass; const ErrorStr :TString);
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise aClass.Create(ErrorStr)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure ApiCheck(ARes :Boolean);
  var
    vLastError :TInteger;
  begin
    if not ARes then begin
      vLastError := GetLastError;
     {$ifdef bTraceError}
      SetErrorAddress(ReturnAddr);
     {$endif bTraceError}
      AppError(SysErrorMessage(vLastError));
    end;
  end;


  procedure ApiCheckCode(Code :TInteger);
  begin
    if Code <> ERROR_SUCCESS then begin
     {$ifdef bTraceError}
      SetErrorAddress(ReturnAddr);
     {$endif bTraceError}
      AppError(SysErrorMessage(Code));
    end;
  end;


  procedure WrongError(const Mess :String; Addr :Pointer);
  begin
    raise EDebugRaise.CreateFmt(Mess + #10 + 'Адрес %p', [Addr])
     {$ifopt W+} at Addr {$endif W+};
  end;


  procedure Sorry;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EUnderConstruction.Create('К сожалению, данная процедура пока не реализована')
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;

  procedure Wrong;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    WrongError('Внутренняя ошибка приложения.', ReturnAddr);
  end;

  procedure AbstractError;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    WrongError('Вызов абстрактного метода.', ReturnAddr);
  end;


 {$ifdef b64}

 {$ifdef Ver2_3}
  function LocalAddr({rcx:@Result;} {rdx}Proc :Pointer) :TMethod; assembler; nostackframe;
  asm
    mov [rcx + 8], rbp
    mov [rcx], rdx
  end;
 {$else}
  function LocalAddr({rcx:}Proc :Pointer {rdx:@Result}) :TMethod; assembler; nostackframe;
  asm
    mov [rdx + 8], rbp
    mov [rdx], rcx
  end;
 {$endif Ver2_3}

 {$else}

  function LocalAddr(Proc :Pointer) :TMethod; assembler;
  asm
    mov [edx + 4], EBP
    mov [edx].DWORD, Proc
  end;

 {$endif b64}


  function TickCountDiff(AValue1, AValue2 :DWORD) :TInteger;
  var
    vTmp :DWORD;
  begin
    if AValue1 >= AValue2 then
      vTmp := AValue1 - AValue2
    else
      vTmp := ($FFFFFFFF - AValue2) + aValue1;
   {$ifndef b64}
    if vTmp > DWORD(MaxInt) then
      vTmp := MaxInt;
   {$endif b64}
    Result := vTmp;
  end;





{$ifdef bFreePascal}
initialization
  MainThreadID := GetCurrentThreadID;
{$endif bFreePascal}
end.


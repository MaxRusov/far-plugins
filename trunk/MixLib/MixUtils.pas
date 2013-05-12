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


  const
    GUID_NULL :TGUID = '{00000000-0000-0000-0000-000000000000}';


  type
  { General arrays }

    PByteArray = ^TByteArray;
    TByteArray = array[0..32767] of Byte;

    PWordArray = ^TWordArray;
    TWordArray = array[0..16383] of Word;

    PIntegerArray = ^TIntegerArray;
    TIntegerArray = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;

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
      constructor CreateRes(ResString :Pointer{PResStringRec});
      constructor CreateResFmt(ResString :Pointer{PResStringRec}; const Args: array of const);
      constructor CreateHelp(const Msg :TString; AHelpContext: Integer);
      constructor CreateFmtHelp(const Msg :TString; const Args: array of const; AHelpContext: Integer);
      constructor CreateResHelp(ResString :Pointer{PResStringRec}; AHelpContext: Integer);
      constructor CreateResFmtHelp(ResString :Pointer{PResStringRec}; const Args: array of const; AHelpContext: Integer);
      procedure AfterConstruction; override;
    private
     {$ifdef bDebug}
     {$ifndef bUnicodeRTL}
      FMessage0 :TAnsiStr;  { Чтобы не глючил отладчик }
     {$endif bUnicodeRTL}
     {$endif bDebug}
      FMessage :TString;
      FHelpContext :Integer;
    public
      property HelpContext :Integer read FHelpContext write FHelpContext;
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

    EOleError = class(Exception);

    EOleSysError = class(EOleError)
    public
      constructor Create(const msg :TString; ErrorCode: HRESULT; HelpContext: Integer);
    private
      FErrorCode :HRESULT;
    public
      property ErrorCode: HRESULT read FErrorCode write FErrorCode;
    end;


  procedure Abort;

  var
    FormatFunc :Function(const Fmt :TString; const Args : Array of const) :TString;

  Function Format(const Fmt :TString; const Args : Array of const) :TString;

  function MakeInt64(ALo, AHi :DWORD) :TInt64;
  function IntToStr(AInt :Integer) :TString;
  function Int64ToStr(AInt :Int64) :TString;

  function HexStr(AVal :Int64; ACount :Integer) :TString;
  procedure BinToHex(ASrc :Pointer; ACount :Integer; ADst :PTChar);
  function BinToHexStr(ASrc :Pointer; ACount :Integer) :TString;

  function LoadStr(Ident: Integer) :TString;
  function FmtLoadStr(Ident: Integer; const Args: array of const) :TString;

  function StrLen(const Str: PTChar) :Integer;
  function StrLenA(const Str: PAnsiChar) :Integer;
  function StrLenW(const Str: PWideChar) :Integer;

  function StrCopy(Dest :PTChar; const Source :PTChar) :PTChar;
  function StrCopyA(Dest :PAnsiChar; const Source :PAnsiChar) :PAnsiChar;
  function StrCopyW(Dest :PWideChar; const Source :PWideChar) :PWideChar;

  function StrECopy(Dest :PTChar; const Source :PTChar) :PTChar;
  function StrECopyA(Dest :PAnsiChar; const Source :PAnsiChar) :PAnsiChar;
  function StrECopyW(Dest :PWideChar; const Source :PWideChar) :PWideChar;

  function StrLCopy(Dest: PTChar; Source: PTChar; MaxLen :Integer): PTChar;
  function StrLCopyA(Dest: PAnsiChar; Source: PAnsiChar; MaxLen :Integer): PAnsiChar;
  function StrLCopyW(Dest: PWideChar; Source: PWideChar; MaxLen :Integer): PWideChar;

  function StrPCopy(Dest :PTChar; const Source :TString): PTChar;
  function StrPCopyA(Dest :PAnsiChar; const Source :TAnsiStr): PAnsiChar;
  function StrPCopyW(Dest :PWideChar; const Source :TWideStr): PWideChar;

  function StrPLCopy(Dest :PTChar; const Source :TString; MaxLen :Integer) :PTChar;
  function StrPLCopyA(Dest :PAnsiChar; const Source :TAnsiStr; MaxLen :Integer) :PAnsiChar;
  function StrPLCopyW(Dest :PWideChar; const Source :TWideStr; MaxLen :Integer) :PWideChar;

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

  function StrNew(const Str :TString) :PTChar; overload;
  function StrNew(Str :PTChar) :PTChar; overload;
  function StrNewA(Str :PAnsiChar) :PAnsiChar;
  function StrNewW(Str :PWideChar) :PWideChar;

  procedure StrDispose(Str :PTChar);
  procedure StrDisposeA(Str :PAnsiChar);
  procedure StrDisposeW(Str :PWideChar);

  function Trim(const S :TString) :TString;
  function TrimLeft(const S :TString) :TString;
  function TrimRight(const S :TString) :TString;

  function AnsiStrLIComp(S1, S2 :PTChar; MaxLen: Cardinal): Integer;
  function AnsiQuotedStr(const S :TString; Quote :TChar) :TString;
  function AnsiExtractQuotedStr(var Src :PTChar; Quote :TChar) :TString;

  function StringOfChar(AChr :TChar; ALen :Integer) :TString;

  procedure FillZero(var ABuf; ACount :Integer);
  procedure MemFill2(PBuf :Pointer; ACount :Integer; AFiller :Word);
  procedure MemFillChar(pBuf :Pointer; ACount :Integer; AChar :TChar);
  function MemSearch(Str :PAnsiChar; Count :Integer; Match :AnsiChar) :Integer;
  function MemCompare(APtr1, APtr2 :Pointer; ASize :Integer) :Integer;
  procedure MemExchange(APtr1, APtr2 :Pointer; ASize :Integer);

  function SysErrorMessage(ErrorCode: Integer) :TString;
  function Win32Check(RetVal: BOOL): BOOL;
  procedure RaiseLastWin32Error;

  function FileOpen(const FileName :TString; Mode: LongWord) :THandle;
  function FileCreate(const FileName :TString) :THandle;
  function FileRead(Handle :THandle; var Buffer; Count: LongWord): Integer;
  function FileWrite(Handle :THandle; const Buffer; Count: LongWord): Integer;
  function FileSeek(Handle :THandle; Offset, Origin: Integer): Integer; overload;
  function FileSeek(Handle :THandle; const Offset: Int64; Origin: Integer): Int64; overload;
  procedure FileClose(Handle :THandle);
  function FileTimeToDosFileDate(const AFileTime :TFileTime) :Integer;
  function FileSize(AHandle :THandle) :TInt64;
  function FileAge(const FileName :TString): Integer;
  function FileGetAttr(const FileName :TString): Integer;
  function FileSetAttr(const FileName :TString; Attr: Integer): Integer;
  function DeleteFile(const FileName :TString): Boolean;
  function RenameFile(const OldName, NewName :TString): Boolean;
  function CreateDir(const Dir :TString): Boolean;
  function RemoveDir(const Dir :TString): Boolean;
  function GetCurrentDir :TString;
  function SetCurrentDir(const Dir :TString): Boolean;

  function LoadLibraryEx(const AName :TString; ARaise :Boolean = True) :THandle;
  procedure FreeLibrarySafe(AModule :THandle);
  function GetProcAddressEx(hDLL :THandle; const AProcName :TAnsiStr; ARaise :Boolean = True) :Pointer;

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

    ECtrlBreak = class(TException);

  procedure FreeObj(var Obj {:TObject});
  procedure FreeIntf(var Intf {:IUnknown});

  function MemAlloc(Size :Integer) :Pointer;
  function MemAllocZero(Size :Integer) :Pointer;
  procedure MemFree(var P {:Pointer});

  procedure AppError(const ErrorStr :TString);
  procedure AppErrorFmt(const ErrorStr :TString; const Args: array of const);
  procedure AppErrorRes(ResString :Pointer{PResStringRec});
  procedure AppErrorResFmt(ResString :Pointer{PResStringRec}; const Args: array of const);
  procedure RaiseError(aClass :ExceptClass; const ErrorStr :TString);
  procedure RaiseErrorRes(aClass :ExceptClass; ResString :Pointer{PResStringRec});

  procedure ApiCheck(ARes :Boolean);
  procedure ApiCheckCode(Code :Integer);

  procedure Sorry;
  procedure Wrong;
  procedure AbstractError;
  procedure CtrlBreakException;

  function LocalAddr(Proc :Pointer) :TMethod;

  function TickCountDiff(AValue1, AValue2 :DWORD) :Integer;


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


  constructor Exception.CreateRes(ResString :Pointer{PResStringRec});
  begin
    inherited create;
    FMessage := LoadResString(ResString);
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateResFmt(ResString :Pointer{PResStringRec}; const Args: array of const);
  begin
    inherited create;
    FMessage := Format(LoadResString(ResString), args);
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


  constructor Exception.CreateResHelp(ResString :Pointer{PResStringRec}; AHelpContext: Integer);
  begin
    inherited create;
    FMessage := LoadResString(ResString);
    FHelpContext := AHelpContext;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  constructor Exception.CreateResFmtHelp(ResString :Pointer{PResStringRec}; const Args: array of const; AHelpContext: Integer);
  begin
    inherited create;
    FMessage := Format(LoadResString(ResString), args);
    FHelpContext := AHelpContext;
   {$ifdef bTraceError}
    TraceException(nil, ClassName, FMessage);
   {$endif bTraceError}
  end;


  procedure Exception.AfterConstruction; {override;}
  begin
   {$ifdef bDebug}
   {$ifndef bUnicodeRTL}
    FMessage0 := FMessage;
   {$endif bUnicodeRTL}
   {$endif bDebug}
  end;


  constructor EOleSysError.Create(const msg :TString; ErrorCode: HRESULT; HelpContext: Integer);
  var
    S :TString;
  begin
    S := msg;
    if S = '' then begin
      S := SysErrorMessage(ErrorCode);
      if S = '' then
        {S := Format(SOleError, [ErrorCode])};
    end;
    inherited CreateHelp(S, HelpContext);
    FErrorCode := ErrorCode;
  end;


  procedure Abort;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAbort.CreateRes(@SAbortError) at ReturnAddr;
  end;





 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  Function Format(const Fmt :TString; const Args : Array of const) :TString;
  begin
    if Assigned(FormatFunc) then
      Result := FormatFunc(Fmt, Args)
    else
      raise Exception.CreateRes(@SNotImplemented);
  end;


  function MakeInt64(ALo, AHi :DWORD) :TInt64;
  begin
    Int64Rec(Result).Lo := ALo;
    Int64Rec(Result).Hi := AHi;
  end;


  function IntToStr(AInt :Integer) :TString;
  {$ifdef bDelphi12}
  var
    vTmp :ShortString;
  begin
    Str(AInt, vTmp);
    Result := TString(vTmp);
  {$else}
  begin
    Str(AInt, Result);
  {$endif bDelphi12}
  end;


  function Int64ToStr(AInt :Int64) :TString;
  {$ifdef bDelphi12}
  var
    vTmp :ShortString;
  begin
    Str(AInt, vTmp);
    Result := TString(vTmp);
  {$else}
  begin
    Str(AInt, Result);
  {$endif bDelphi12}
  end;


  const
    HexChars :array[0..15] of TChar = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

  function HexStr(AVal :Int64; ACount :Integer) :TString;
  var
    i :Integer;
  begin
    SetString(Result, nil, ACount);
    for i := ACount downto 1 do begin
      Result[i] := HexChars[AVal and $f];
      AVal := AVal shr 4;
    end;
  end;


  procedure BinToHex(ASrc :Pointer; ACount :Integer; ADst :PTChar);
  var
    i :Integer;
    vSrc :PByte;
  begin
    vSrc := ASrc;
    for I := 0 to ACount - 1 do begin
      ADst^ := HexChars[(vSrc^ and $F0) shr 4];
      Inc(ADst);
      ADst^ := HexChars[vSrc^ and $0F];
      Inc(ADst);
      Inc(vSrc);
    end;
  end;


  function BinToHexStr(ASrc :Pointer; ACount :Integer) :TString;
  begin
    SetString(Result, nil, 2 * ACount);
    BinToHex(ASrc, ACount, PTChar(Result));
  end;



  function LoadStr(Ident :Integer) :TString;
  var
    vBuf :array[0..1024] of TChar;
    vLen :Integer;
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


  function StrLen(const Str :PTChar) :Integer;
  begin
   {$ifdef bUnicode}
    Result := StrLenW(Str);
   {$else}
    Result := StrLenA(Str);
   {$endif bUnicode}
  end;

  function StrLenA(const Str :PAnsiChar) :Integer;
  begin
    Result := {Windows.}lstrlena(Str);
  end;

  function StrLenW(const Str :PWideChar) :Integer;
  begin
    Result := {Windows.}lstrlenw(Str);
  end;


  function StrCopy(Dest :PTChar; const Source :PTChar) :PTChar;
  begin
    Result := StrLCopy(Dest, Source, MaxInt);
  end;

  function StrCopyA(Dest :PAnsiChar; const Source :PAnsiChar) :PAnsiChar;
  begin
    Result := StrLCopyA(Dest, Source, MaxInt);
  end;

  function StrCopyW(Dest :PWideChar; const Source :PWideChar) :PWideChar;
  begin
    Result := StrLCopyW(Dest, Source, MaxInt);
  end;


  function StrECopy(Dest :PTChar; const Source :PTChar) :PTChar;
  begin
    Result := StrEnd(StrCopy(Dest, Source));
  end;

  function StrECopyA(Dest :PAnsiChar; const Source :PAnsiChar) :PAnsiChar;
  begin
    Result := StrEndA(StrCopyA(Dest, Source));
  end;

  function StrECopyW(Dest :PWideChar; const Source :PWideChar) :PWideChar;
  begin
    Result := StrEndW(StrCopyW(Dest, Source));
  end;


  function StrLCopy(Dest: PTChar; Source: PTChar; MaxLen :Integer): PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrLCopyW(Dest, Source, MaxLen);
   {$else}
    Result := StrLCopyA(Dest, Source, MaxLen);
   {$endif bUnicode}
  end;

  function StrLCopyA(Dest: PAnsiChar; Source: PAnsiChar; MaxLen :Integer): PAnsiChar;
  begin
    Result := Dest;
    while (MaxLen > 0) and (Source^ <> #0) do begin
      Dest^ := Source^;
      Inc(Source);
      Inc(Dest);
      Dec(MaxLen);
    end;
    Dest^ := #0;
  end;

  function StrLCopyW(Dest: PWideChar; Source: PWideChar; MaxLen :Integer): PWideChar;
  begin
    Result := Dest;
    while (MaxLen > 0) and (Source^ <> #0) do begin
      Dest^ := Source^;
      Inc(Source);
      Inc(Dest);
      Dec(MaxLen);
    end;
    Dest^ := #0;
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


  function StrPLCopy(Dest :PTChar; const Source :TString; MaxLen :Integer) :PTChar;
  begin
    Result := StrLCopy(Dest, PTChar(Source), MaxLen);
  end;

  function StrPLCopyA(Dest :PAnsiChar; const Source :TAnsiStr; MaxLen :Integer) :PAnsiChar;
  begin
    Result := StrLCopyA(Dest, PAnsiChar(Source), MaxLen);
  end;

  function StrPLCopyW(Dest :PWideChar; const Source :TWideStr; MaxLen :Integer) :PWideChar;
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
    Move(Source^, Dest^, Count * SizeOf(WideChar));
    Result := Dest;
  end;

  function StrMoveA(Dest: PAnsiChar; const Source: PAnsiChar; Count: Cardinal): PAnsiChar;
  begin
    Move(Source^, Dest^, Count * SizeOf(AnsiChar));
    Result := Dest;
  end;


  function StrScan(const Str :PTChar; Chr :TChar) :PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrScanW(Str, Chr);
   {$else}
    Result := StrScanA(Str, Chr);
   {$endif bUnicode}
  end;

  function StrScanA(const Str :PAnsiChar; Chr :AnsiChar) :PAnsiChar;
  begin
    Result := Str;
    while (Result^ <> #0) and (Result^ <> Chr) do
      Inc(Result);
    if (Result^ = #0) and (Chr <> #0) then
      Result := nil;
  end;

  function StrScanW(const Str :PWideChar; Chr :WideChar) :PWideChar;
  begin
    Result := Str;
    while (Result^ <> #0) and (Result^ <> Chr) do
      Inc(Result);
    if (Result^ = #0) and (Chr <> #0) then
      Result := nil
  end;


  function StrEnd(const Str: PTChar): PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrEndW(Str);
   {$else}
    Result := StrEndA(Str);
   {$endif bUnicode}
  end;

 {$ifdef b64}
  function StrEndA(const Str :PAnsiChar) :PAnsiChar;
  begin
    Result := Str + StrLenA(Str);
  end;

  function StrEndW(const Str: PWideChar): PWideChar;
  begin
    Result := Str + StrLenW(Str);
  end;

 {$else}

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
 {$endif b64}

 
  function StrLIComp(const Str1, Str2 :PTChar; MaxLen :Cardinal) :Integer;
  begin
   {$ifdef bUnicode}
    Result := StrLICompW(Str1, Str2, MaxLen);
   {$else}
    Result := StrLICompA(Str1, Str2, MaxLen);
   {$endif bUnicode}
  end;

 {$ifdef b64}
  function StrLICompA(const Str1, Str2 :PAnsiChar; MaxLen :Cardinal) :Integer;
  begin
    Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE, Str1, MaxLen, Str2, MaxLen) - 2;
  end;

  function StrLICompW(const Str1, Str2 :PWideChar; MaxLen :Cardinal) :Integer;
  begin
    Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, Str1, MaxLen, Str2, MaxLen) - 2;
  end;

 {$else}

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
 {$endif b64}


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
    Inc(Pointer1(Result), SizeOf(Cardinal));
  end;

  function StrAllocW(Size :Cardinal) :PWideChar;
  begin
    GetMem(Result, Size * 2 + SizeOf(Cardinal));
    Cardinal(Pointer(Result)^) := Size;
    Inc(Pointer1(Result), SizeOf(Cardinal));
  end;


  function StrNew(const Str :TString) :PTChar;
  begin
    Result := StrNew(PTChar(Str));
  end;


  function StrNew(Str :PTChar) :PTChar;
  begin
   {$ifdef bUnicode}
    Result := StrNewW(Str);
   {$else}
    Result := StrNewA(Str);
   {$endif bUnicode}
  end;


  function StrNewA(Str :PAnsiChar) :PAnsiChar;
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

  function StrNewW(Str :PWideChar) :PWideChar;
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
      Dec(Pointer1(Str), SizeOf(Cardinal));
      FreeMem(Str);
    end;
  end;

  procedure StrDisposeW(Str :PWideChar);
  begin
    if Str <> nil then begin
      Dec(Pointer1(Str), SizeOf(Cardinal));
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


  function StringOfChar(AChr :TChar; ALen :Integer) :TString;
  begin
    Result := '';
    if ALen > 0 then begin
      SetLength(Result, ALen);
      MemFillChar(PTChar(Result), ALen, AChr);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure FillZero(var ABuf; ACount :Integer);
  begin
    FillChar(ABuf, ACount, 0);
  end;


  procedure MemFill2(PBuf :Pointer; ACount :Integer; AFiller :Word);
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


  procedure MemFillChar(pBuf :Pointer; ACount :Integer; AChar :TChar);
  begin
   {$ifdef bUnicode}
    MemFill2(pBuf, ACount, Word(AChar));
   {$else}
    FillChar(pBuf^, ACount, AChar);
   {$endif bUnicode}
  end;


  function MemSearch(Str :PAnsiChar; Count :Integer; Match :AnsiChar) :Integer;
  var
    vPtr, vLast :PAnsiChar;
  begin
    vPtr := Str;
    vLast := Str + Count;
    while (vPtr < vLast) and (vPtr^ <> Match) do
      inc(vPtr);
    Result := vPtr - Str;
  end;


  function MemCompare(APtr1, APtr2 :Pointer; ASize :Integer) :Integer;
  const
    cPtrSize = SizeOf(Pointer);
  begin
    Result := ASize;
    while (ASize >= cPtrSize) and (TUnsPtr(APtr1^) = TUnsPtr(APtr2^)) do begin
      Inc(TUnsPtr(APtr1), cPtrSize);
      Inc(TUnsPtr(APtr2), cPtrSize);
      Dec(ASize, cPtrSize);
    end;
    while (ASize > 0) and (Byte(APtr1^) = Byte(APtr2^)) do begin
      Inc(TUnsPtr(APtr1));
      Inc(TUnsPtr(APtr2));
      Dec(ASize);
    end;
    Dec(Result, ASize);
  end;


  procedure MemExchange(APtr1, APtr2 :Pointer; ASize :Integer);
  const
    cPtrSize = SizeOf(Pointer);
  var
    vInt :TUnsPtr;
    vByte :Byte;
  begin
    while ASize >= cPtrSize do begin
      vInt := TUnsPtr(APtr1^);
      TUnsPtr(APtr1^) := TUnsPtr(APtr2^);
      TUnsPtr(APtr2^) := vInt;
      Inc(TUnsPtr(APtr1), cPtrSize);
      Inc(TUnsPtr(APtr2), cPtrSize);
      Dec(ASize, cPtrSize);
    end;
    while ASize >=1 do begin
      vByte := Byte(APtr1^);
      Byte(APtr1^) := Byte(APtr2^);
      Byte(APtr2^) := vByte;
      Inc(TUnsPtr(APtr1));
      Inc(TUnsPtr(APtr2));
      Dec(ASize);
    end;
  end;

 {-----------------------------------------------------------------------------}

  function SysErrorMessage(ErrorCode: Integer) :TString;
  const
    cMaxLen = 255;
  var
    Len: Integer;
    Buffer: array[0..cMaxLen] of TChar;
  begin
    Len := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, DWORD(ErrorCode), 0, Buffer, cMaxLen, nil);
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
    if not RetVal then
      RaiseLastWin32Error;
    Result := RetVal;
  end;


  procedure Beep;
  begin
    MessageBeep(0);
  end;

 {-----------------------------------------------------------------------------}

  function FileOpen(const FileName :TString; Mode: LongWord) :THandle;
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
    Result := CreateFile(PTChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0);
  end;

  function FileCreate(const FileName :TString) :THandle;
  begin
    Result := CreateFile(PTChar(FileName), GENERIC_READ or GENERIC_WRITE,
      0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  end;

  function FileRead(Handle :THandle; var Buffer; Count: LongWord): Integer;
  begin
    if not ReadFile(Handle, Buffer, Count, LongWord(Result), nil) then
      Result := -1;
  end;

  function FileWrite(Handle :THandle; const Buffer; Count: LongWord): Integer;
  begin
    if not WriteFile(Handle, Buffer, Count, LongWord(Result), nil) then
      Result := -1;
  end;

  function FileSeek(Handle :THandle; Offset, Origin: Integer): Integer;
  begin
    Result := SetFilePointer(Handle, Offset, nil, Origin);
  end;

  function FileSeek(Handle :THandle; const Offset: Int64; Origin: Integer): Int64;
  begin
    Result := Offset;
    Int64Rec(Result).Lo := SetFilePointer(Handle, Int64Rec(Result).Lo,
      @Int64Rec(Result).Hi, Origin);
  end;

  procedure FileClose(Handle :THandle);
  begin
    CloseHandle(Handle);
  end;


  function FileTimeToDosFileDate(const AFileTime :TFileTime) :Integer;
  var
    vLocalTime :TFileTime;
  begin
    FileTimeToLocalFileTime(@AFileTime, vLocalTime);
    if not FileTimeToDosDateTime(@vLocalTime, LongRec(Result).Hi, LongRec(Result).Lo) then
      Result := -1;
  end;


  function FileSize(AHandle :THandle) :TInt64;
  var
    vSizeLo, vSizeHi :DWORD;
  begin
    vSizeLo := GetFileSize(AHandle, @vSizeHi);
    Result := MakeInt64(vSizeLo, vSizeHi);
  end;


  function FileAge(const FileName :TString) :Integer;
  var
    Handle: THandle;
    FindData: TWin32FindData;
  begin
    Handle := FindFirstFile(PTChar(FileName), FindData);
    if Handle <> INVALID_HANDLE_VALUE then begin
      Windows.FindClose(Handle);
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
        Result := FileTimeToDosFileDate(FindData.ftLastWriteTime);
        Exit;
      end;
    end;
    Result := -1;
  end;


  function FileGetAttr(const FileName :TString): Integer;
  begin
    Result := Integer(GetFileAttributes(PTChar(FileName)));
  end;

  function FileSetAttr(const FileName :TString; Attr: Integer): Integer;
  begin
    Result := 0;
    if not SetFileAttributes(PTChar(FileName), Attr) then
      Result := GetLastError;
  end;


  function DeleteFile(const FileName :TString): Boolean;
  begin
    Result := Windows.DeleteFile(PTChar(FileName));
  end;

  function RenameFile(const OldName, NewName :TString): Boolean;
  begin
    Result := MoveFile(PTChar(OldName), PTChar(NewName));
  end;


  function CreateDir(const Dir :TString): Boolean;
  begin
    Result := CreateDirectory(PTChar(Dir), nil);
  end;

  function RemoveDir(const Dir :TString): Boolean;
  begin
    Result := RemoveDirectory(PTChar(Dir));
  end;


  function GetCurrentDir :TString;
  var
    Buffer: array[0..MAX_PATH - 1] of TChar;
  begin
    SetString(Result, Buffer, GetCurrentDirectory(MAX_PATH, Buffer));
  end;

  function SetCurrentDir(const Dir :TString): Boolean;
  begin
    Result := SetCurrentDirectory(PTChar(Dir));
  end;


{------------------------------------------------------------------------------}

  function LoadLibraryEx(const AName :TString; ARaise :Boolean = True) :THandle;
//var
//  vTmp :Word;
  begin
//  asm
//    FNSTCW vTmp
//  end;
//  try
      Result := LoadLibrary(PTChar(AName));
//  finally
//    asm
//      FNCLEX
//      FLDCW vTmp
//    end;
//  end;

    if (Result = 0) and ARaise then
      RaiseLastWin32Error;
  end;


  procedure FreeLibrarySafe(AModule :THandle);
//var
//  vTmp :Word;
  begin
//  asm
//    FNSTCW vTmp
//  end;
//  try
      FreeLibrary(AModule);
//  finally
//    asm
//      FNCLEX
//      FLDCW vTmp
//    end;
//  end;
  end;


  function GetProcAddressEx(hDLL :THandle; const AProcName :TAnsiStr; ARaise :Boolean = True) :Pointer;
  begin
    Result := GetProcAddress(hDLL, PAnsiChar(AProcName));
    if (Result = nil) and ARaise then
      RaiseLastWin32Error;
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


  procedure FreeIntf(var Intf {:IUnknown});
  var
    vTmp :Pointer;
  begin
    if Pointer(Intf) <> nil then begin
      vTmp := Pointer(Intf);
      Pointer(Intf) := nil;
      IUnknown(vTmp)._Release;
    end;
  end;


  function MemAlloc(Size :Integer) :Pointer;
  begin
    Result := nil;
    if Size <> 0 then begin
     {$ifdef bDebug}
      SetReturnAddr;
     {$endif bDebug}
      GetMem(Result, Size);
    end;
  end;


  function MemAllocZero(Size :Integer) :Pointer;
  begin
    Result := nil;
    if Size <> 0 then begin
     {$ifdef bDebug}
      SetReturnAddr;
     {$endif bDebug}
      Result := MemAlloc(Size);
      FillZero(Result^, Size);
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


  procedure AppErrorRes(ResString :Pointer{PResStringRec});
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EAppError.CreateRes(ResString)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure AppErrorResFmt(ResString :Pointer{PResStringRec}; const Args: array of const);
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


  procedure RaiseErrorRes(aClass :ExceptClass; ResString :Pointer{PResStringRec});
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise aClass.CreateRes(ResString)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure ApiCheck(ARes :Boolean);
  var
    vLastError :Integer;
  begin
    if not ARes then begin
      vLastError := GetLastError;
     {$ifdef bTraceError}
      SetErrorAddress(ReturnAddr);
     {$endif bTraceError}
      AppError(SysErrorMessage(vLastError));
    end;
  end;


  procedure ApiCheckCode(Code :Integer);
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
    raise EDebugRaise.CreateFmt(Mess + #10 + 'At %p', [Addr])
     {$ifopt W+} at Addr {$endif W+};
  end;


  procedure Sorry;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    raise EUnderConstruction.CreateRes(@SNotImplemented)
     {$ifopt W+} at ReturnAddr {$endif W+};
  end;


  procedure Wrong;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    WrongError('Internal application error.', ReturnAddr);
  end;


  procedure AbstractError;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr);
   {$endif bTraceError}
    WrongError('Abstract method called.', ReturnAddr);
  end;


  procedure CtrlBreakException;
  begin
//  raise ECtrlBreak.Create('');
    raise ECtrlBreak.Create('');
  end;


 {$ifdef b64}
  function LocalAddr({rcx:@Result;} {rdx}Proc :Pointer) :TMethod; assembler; {$ifdef bFreePascal}nostackframe;{$endif bFreePascal}
  asm
    mov [rcx + 8], rbp
    mov [rcx], rdx
  end;
 {$else}
  function LocalAddr(Proc :Pointer) :TMethod; assembler;
  asm
    mov [edx + 4], EBP
    mov [edx].DWORD, Proc
  end;
 {$endif b64}


  function TickCountDiff(AValue1, AValue2 :DWORD) :Integer;
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


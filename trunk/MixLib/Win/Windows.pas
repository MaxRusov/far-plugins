{******************************************************* }
{                                                        } 
{       Borland Delphi Run-time Library                  }
{       Win32 API Interface Unit                         }
{                                                        }
{       Copyright (c) 1985-1999, Microsoft Corporation   }
{                                                        }
{       Translator: Inprise Corporation                  }
{                                                        }
{******************************************************* }

{$I Defines.inc}

unit Windows;

{$ALIGN ON}
{$MINENUMSIZE 4}
{$WEAKPACKAGEUNIT}

{$ifdef bFreePascal}
 {$PACKRECORDS C}
{$endif bFreePascal}

interface

uses
  MixTypes;

type
{ Translated from WINDEF.H }

  WCHAR = WideChar;
  PWChar = PWideChar;

  LPSTR = PAnsiChar;
  PLPSTR = ^LPSTR;
  LPCSTR = PAnsiChar;
  LPCTSTR = PTChar;
  LPTSTR = PTChar;
  LPWSTR = PWideChar;
  PLPWSTR = ^LPWSTR;
  LPCWSTR = PWideChar;

  DWORD = LongWord;
  BOOL = LongBool;
  PBOOL = ^BOOL;
  PByte = ^Byte;
  PINT = ^Integer;
  PSingle = ^Single;
  PWORD = ^Word;
  PDWORD = ^DWORD;
  LPDWORD = PDWORD;

  UINT8 = BYTE;
  UINT32 = LongWord;

  LONG = TInt32;
  UCHAR = Byte;
  PUCHAR = ^Byte;
  SHORT = Smallint;
  UINT = LongWord;
  PUINT = ^UINT;
  ULONG = Cardinal;
  PULONG = ^ULONG;
  PLongint = ^Longint;
  PInteger = ^Integer;
  PLongWord = ^LongWord;
  PSmallInt = ^Smallint;
  PDouble = ^Double;
  PShortInt = ^ShortInt;

  LCID = DWORD;
  LANGID = Word;

  SIZE_T = TUnsPtr;

  THandle = TUnsPtr;
  PHandle = ^THandle;
 {$ifndef bFreePascal}
 {$ifndef bDelphi15}
  TThreadID = THandle;
 {$endif bDelphi15}
 {$endif bFreePascal}

  // From BaseTsd.h
  IntPtr = TIntPtr;
  INT_PTR = TIntPtr;
  LONG_PTR = TIntPtr;
  UIntPtr = TUnsPtr;
  UINT_PTR = TUnsPtr;
  ULONG_PTR = TUnsPtr;
  DWORD_PTR = TUnsPtr;
  HANDLE_PTR = TUnsPtr;

  UInt64 = TUns64;

const
  MAX_PATH = 260;


{ Translated from WINNT.H (only things needed for API calls) }

{line 190}
type
  LONGLONG = Int64;
  PSID = Pointer;
  PLargeInteger = ^TLargeInteger;
  _LARGE_INTEGER = record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: Longint);
    1: (
      QuadPart: LONGLONG);
  end;
  TLargeInteger = Int64;
  LARGE_INTEGER = _LARGE_INTEGER;

  DWORDLONG = UInt64;
  ULONGLONG = UInt64;
  ULARGE_INTEGER = record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: DWORD);
    1: (
      QuadPart: LONGLONG);
  end;
  PULargeInteger = ^TULargeInteger;
  TULargeInteger = ULARGE_INTEGER;

{line 450}
  PListEntry = ^TListEntry;
  _LIST_ENTRY = record
    Flink: PListEntry;
    Blink: PListEntry;
  end;
  TListEntry = _LIST_ENTRY;
  LIST_ENTRY = _LIST_ENTRY;

{line 490}
const
  MINCHAR = $80;
  MAXCHAR = 127;
  MINSHORT = $8000;
  MAXSHORT = 32767;
  MINLONG = DWORD($80000000);
  MAXLONG = $7FFFFFFF;
  MAXBYTE = 255;
  MAXWORD = 65535;
  MAXDWORD = DWORD($FFFFFFFF);

{line 510}
(*
 *  Language IDs.
 *
 *  The following two combinations of primary language ID and
 *  sublanguage ID have special semantics:
 *
 *    Primary Language ID   Sublanguage ID      Result
 *    -------------------   ---------------     ------------------------
 *    LANG_NEUTRAL          SUBLANG_NEUTRAL     Language neutral
 *    LANG_NEUTRAL          SUBLANG_DEFAULT     User default language
 *    LANG_NEUTRAL          SUBLANG_SYS_DEFAULT System default language
 *)

const
{ Primary language IDs. }

  LANG_NEUTRAL                         = $00;

  LANG_AFRIKAANS                       = $36;
  LANG_ALBANIAN                        = $1c;
  LANG_ARABIC                          = $01;
  LANG_BASQUE                          = $2d;
  LANG_BELARUSIAN                      = $23;
  LANG_BULGARIAN                       = $02;
  LANG_CATALAN                         = $03;
  LANG_CHINESE                         = $04;
  LANG_CROATIAN                        = $1a;
  LANG_CZECH                           = $05;
  LANG_DANISH                          = $06;
  LANG_DUTCH                           = $13;
  LANG_ENGLISH                         = $09;
  LANG_ESTONIAN                        = $25;
  LANG_FAEROESE                        = $38;
  LANG_FARSI                           = $29;
  LANG_FINNISH                         = $0b;
  LANG_FRENCH                          = $0c;
  LANG_GERMAN                          = $07;
  LANG_GREEK                           = $08;
  LANG_HEBREW                          = $0d;
  LANG_HUNGARIAN                       = $0e;
  LANG_ICELANDIC                       = $0f;
  LANG_INDONESIAN                      = $21;
  LANG_ITALIAN                         = $10;
  LANG_JAPANESE                        = $11;
  LANG_KOREAN                          = $12;
  LANG_LATVIAN                         = $26;
  LANG_LITHUANIAN                      = $27;
  LANG_NORWEGIAN                       = $14;
  LANG_POLISH                          = $15;
  LANG_PORTUGUESE                      = $16;
  LANG_ROMANIAN                        = $18;
  LANG_RUSSIAN                         = $19;
  LANG_SERBIAN                         = $1a;
  LANG_SLOVAK                          = $1b;
  LANG_SLOVENIAN                       = $24;
  LANG_SPANISH                         = $0a;
  LANG_SWEDISH                         = $1d;
  LANG_THAI                            = $1e;
  LANG_TURKISH                         = $1f;
  LANG_UKRAINIAN                       = $22;
  LANG_VIETNAMESE                      = $2a;


{ Sublanguage IDs. }

  { The name immediately following SUBLANG_ dictates which primary
    language ID that sublanguage ID can be combined with to form a
    valid language ID. }

  SUBLANG_NEUTRAL                      = $00;    { language neutral }
  SUBLANG_DEFAULT                      = $01;    { user default }
  SUBLANG_SYS_DEFAULT                  = $02;    { system default }

  SUBLANG_ARABIC_SAUDI_ARABIA          = $01;    { Arabic (Saudi Arabia) }
  SUBLANG_ARABIC_IRAQ                  = $02;    { Arabic (Iraq) }
  SUBLANG_ARABIC_EGYPT                 = $03;    { Arabic (Egypt) }
  SUBLANG_ARABIC_LIBYA                 = $04;    { Arabic (Libya) }
  SUBLANG_ARABIC_ALGERIA               = $05;    { Arabic (Algeria) }
  SUBLANG_ARABIC_MOROCCO               = $06;    { Arabic (Morocco) }
  SUBLANG_ARABIC_TUNISIA               = $07;    { Arabic (Tunisia) }
  SUBLANG_ARABIC_OMAN                  = $08;    { Arabic (Oman) }
  SUBLANG_ARABIC_YEMEN                 = $09;    { Arabic (Yemen) }
  SUBLANG_ARABIC_SYRIA                 = $0a;    { Arabic (Syria) }
  SUBLANG_ARABIC_JORDAN                = $0b;    { Arabic (Jordan) }
  SUBLANG_ARABIC_LEBANON               = $0c;    { Arabic (Lebanon) }
  SUBLANG_ARABIC_KUWAIT                = $0d;    { Arabic (Kuwait) }
  SUBLANG_ARABIC_UAE                   = $0e;    { Arabic (U.A.E) }
  SUBLANG_ARABIC_BAHRAIN               = $0f;    { Arabic (Bahrain) }
  SUBLANG_ARABIC_QATAR                 = $10;    { Arabic (Qatar) }
  SUBLANG_CHINESE_TRADITIONAL          = $01;    { Chinese (Taiwan) }
  SUBLANG_CHINESE_SIMPLIFIED           = $02;    { Chinese (PR China) }
  SUBLANG_CHINESE_HONGKONG             = $03;    { Chinese (Hong Kong) }
  SUBLANG_CHINESE_SINGAPORE            = $04;    { Chinese (Singapore) }
  SUBLANG_DUTCH                        = $01;    { Dutch }
  SUBLANG_DUTCH_BELGIAN                = $02;    { Dutch (Belgian) }
  SUBLANG_ENGLISH_US                   = $01;    { English (USA) }
  SUBLANG_ENGLISH_UK                   = $02;    { English (UK) }
  SUBLANG_ENGLISH_AUS                  = $03;    { English (Australian) }
  SUBLANG_ENGLISH_CAN                  = $04;    { English (Canadian) }
  SUBLANG_ENGLISH_NZ                   = $05;    { English (New Zealand) }
  SUBLANG_ENGLISH_EIRE                 = $06;    { English (Irish) }
  SUBLANG_ENGLISH_SOUTH_AFRICA         = $07;    { English (South Africa) }
  SUBLANG_ENGLISH_JAMAICA              = $08;    { English (Jamaica) }
  SUBLANG_ENGLISH_CARIBBEAN            = $09;    { English (Caribbean) }
  SUBLANG_ENGLISH_BELIZE               = $0a;    { English (Belize) }
  SUBLANG_ENGLISH_TRINIDAD             = $0b;    { English (Trinidad) }
  SUBLANG_FRENCH                       = $01;    { French }
  SUBLANG_FRENCH_BELGIAN               = $02;    { French (Belgian) }
  SUBLANG_FRENCH_CANADIAN              = $03;    { French (Canadian) }
  SUBLANG_FRENCH_SWISS                 = $04;    { French (Swiss) }
  SUBLANG_FRENCH_LUXEMBOURG            = $05;    { French (Luxembourg) }
  SUBLANG_GERMAN                       = $01;    { German }
  SUBLANG_GERMAN_SWISS                 = $02;    { German (Swiss) }
  SUBLANG_GERMAN_AUSTRIAN              = $03;    { German (Austrian) }
  SUBLANG_GERMAN_LUXEMBOURG            = $04;    { German (Luxembourg) }
  SUBLANG_GERMAN_LIECHTENSTEIN         = $05;    { German (Liechtenstein) }
  SUBLANG_ITALIAN                      = $01;    { Italian }
  SUBLANG_ITALIAN_SWISS                = $02;    { Italian (Swiss) }
  SUBLANG_KOREAN                       = $01;    { Korean (Extended Wansung) }
  SUBLANG_KOREAN_JOHAB                 = $02;    { Korean (Johab) }
  SUBLANG_NORWEGIAN_BOKMAL             = $01;    { Norwegian (Bokmal) }
  SUBLANG_NORWEGIAN_NYNORSK            = $02;    { Norwegian (Nynorsk) }
  SUBLANG_PORTUGUESE                   = $02;    { Portuguese }
  SUBLANG_PORTUGUESE_BRAZILIAN         = $01;    { Portuguese (Brazilian) }
  SUBLANG_SERBIAN_LATIN                = $02;    { Serbian (Latin) }
  SUBLANG_SERBIAN_CYRILLIC             = $03;    { Serbian (Cyrillic) }
  SUBLANG_SPANISH                      = $01;    { Spanish (Castilian) }
  SUBLANG_SPANISH_MEXICAN              = $02;    { Spanish (Mexican) }
  SUBLANG_SPANISH_MODERN               = $03;    { Spanish (Modern) }
  SUBLANG_SPANISH_GUATEMALA            = $04;    { Spanish (Guatemala) }
  SUBLANG_SPANISH_COSTA_RICA           = $05;    { Spanish (Costa Rica) }
  SUBLANG_SPANISH_PANAMA               = $06;    { Spanish (Panama) }
  SUBLANG_SPANISH_DOMINICAN_REPUBLIC     = $07;  { Spanish (Dominican Republic) }
  SUBLANG_SPANISH_VENEZUELA            = $08;    { Spanish (Venezuela) }
  SUBLANG_SPANISH_COLOMBIA             = $09;    { Spanish (Colombia) }
  SUBLANG_SPANISH_PERU                 = $0a;    { Spanish (Peru) }
  SUBLANG_SPANISH_ARGENTINA            = $0b;    { Spanish (Argentina) }
  SUBLANG_SPANISH_ECUADOR              = $0c;    { Spanish (Ecuador) }
  SUBLANG_SPANISH_CHILE                = $0d;    { Spanish (Chile) }
  SUBLANG_SPANISH_URUGUAY              = $0e;    { Spanish (Uruguay) }
  SUBLANG_SPANISH_PARAGUAY             = $0f;    { Spanish (Paraguay) }
  SUBLANG_SPANISH_BOLIVIA              = $10;    { Spanish (Bolivia) }
  SUBLANG_SPANISH_EL_SALVADOR          = $11;    { Spanish (El Salvador) }
  SUBLANG_SPANISH_HONDURAS             = $12;    { Spanish (Honduras) }
  SUBLANG_SPANISH_NICARAGUA            = $13;    { Spanish (Nicaragua) }
  SUBLANG_SPANISH_PUERTO_RICO          = $14;    { Spanish (Puerto Rico) }
  SUBLANG_SWEDISH                      = $01;    { Swedish }
  SUBLANG_SWEDISH_FINLAND              = $02;    { Swedish (Finland) }


{ Sorting IDs. }

  SORT_DEFAULT                         = $0;     { sorting default }

  SORT_JAPANESE_XJIS                   = $0;     { Japanese XJIS order }
  SORT_JAPANESE_UNICODE                = $1;     { Japanese Unicode order }

  SORT_CHINESE_BIG5                    = $0;     { Chinese BIG5 order }
  SORT_CHINESE_PRCP                    = $0;     { PRC Chinese Phonetic order }
  SORT_CHINESE_UNICODE                 = $1;     { Chinese Unicode order }
  SORT_CHINESE_PRC                     = $2;     { PRC Chinese Stroke Count order }

  SORT_KOREAN_KSC                      = $0;     { Korean KSC order }
  SORT_KOREAN_UNICODE                  = $1;     { Korean Unicode order }

  SORT_GERMAN_PHONE_BOOK               = $1;     { German Phone Book order }


(*
 *  A language ID is a 16 bit value which is the combination of a
 *  primary language ID and a secondary language ID.  The bits are
 *  allocated as follows:
 *
 *       +-----------------------+-------------------------+
 *       |     Sublanguage ID    |   Primary Language ID   |
 *       +-----------------------+-------------------------+
 *        15                   10 9                       0   bit
 *
 *
 *
 *  A locale ID is a 32 bit value which is the combination of a
 *  language ID, a sort ID, and a reserved area.  The bits are
 *  allocated as follows:
 *
 *       +-------------+---------+-------------------------+
 *       |   Reserved  | Sort ID |      Language ID        |
 *       +-------------+---------+-------------------------+
 *        31         20 19     16 15                      0   bit
 *
 *)

{ Default System and User IDs for language and locale. }

  LANG_SYSTEM_DEFAULT   = (SUBLANG_SYS_DEFAULT shl 10) or LANG_NEUTRAL;
  LANG_USER_DEFAULT     = (SUBLANG_DEFAULT shl 10) or LANG_NEUTRAL;

  LOCALE_SYSTEM_DEFAULT = (SORT_DEFAULT shl 16) or LANG_SYSTEM_DEFAULT;
  LOCALE_USER_DEFAULT   = (SORT_DEFAULT shl 16) or LANG_USER_DEFAULT;


{line 724}
  STATUS_WAIT_0                   = $00000000;
  STATUS_ABANDONED_WAIT_0         = $00000080;
  STATUS_USER_APC                 = $000000C0;
  STATUS_TIMEOUT                  = $00000102;
  STATUS_PENDING                  = $00000103;
  STATUS_SEGMENT_NOTIFICATION     = $40000005;
  STATUS_GUARD_PAGE_VIOLATION     = DWORD($80000001);
  STATUS_DATATYPE_MISALIGNMENT    = DWORD($80000002);
  STATUS_BREAKPOINT               = DWORD($80000003);
  STATUS_SINGLE_STEP              = DWORD($80000004);
  STATUS_ACCESS_VIOLATION         = DWORD($C0000005);
  STATUS_IN_PAGE_ERROR            = DWORD($C0000006);
  STATUS_INVALID_HANDLE           = DWORD($C0000008);
  STATUS_NO_MEMORY                = DWORD($C0000017);
  STATUS_ILLEGAL_INSTRUCTION      = DWORD($C000001D);
  STATUS_NONCONTINUABLE_EXCEPTION = DWORD($C0000025);
  STATUS_INVALID_DISPOSITION      = DWORD($C0000026);
  STATUS_ARRAY_BOUNDS_EXCEEDED    = DWORD($C000008C);
  STATUS_FLOAT_DENORMAL_OPERAND   = DWORD($C000008D);
  STATUS_FLOAT_DIVIDE_BY_ZERO     = DWORD($C000008E);
  STATUS_FLOAT_INEXACT_RESULT     = DWORD($C000008F);
  STATUS_FLOAT_INVALID_OPERATION  = DWORD($C0000090);
  STATUS_FLOAT_OVERFLOW           = DWORD($C0000091);
  STATUS_FLOAT_STACK_CHECK        = DWORD($C0000092);
  STATUS_FLOAT_UNDERFLOW          = DWORD($C0000093);
  STATUS_INTEGER_DIVIDE_BY_ZERO   = DWORD($C0000094);
  STATUS_INTEGER_OVERFLOW         = DWORD($C0000095);
  STATUS_PRIVILEGED_INSTRUCTION   = DWORD($C0000096);
  STATUS_STACK_OVERFLOW           = DWORD($C00000FD);
  STATUS_CONTROL_C_EXIT           = DWORD($C000013A);

  MAXIMUM_WAIT_OBJECTS = 64;

{line 1280}
  SIZE_OF_80387_REGISTERS = 80;

  { The following flags control the contents of the CONTEXT structure. }

  CONTEXT_i386 = $10000;     { this assumes that i386 and }
  CONTEXT_i486 = $10000;     { i486 have identical context records }

  CONTEXT_CONTROL         = (CONTEXT_i386 or $00000001); { SS:SP, CS:IP, FLAGS, BP }
  CONTEXT_INTEGER         = (CONTEXT_i386 or $00000002); { AX, BX, CX, DX, SI, DI }
  CONTEXT_SEGMENTS        = (CONTEXT_i386 or $00000004); { DS, ES, FS, GS }
  CONTEXT_FLOATING_POINT  = (CONTEXT_i386 or $00000008); { 387 state }
  CONTEXT_DEBUG_REGISTERS = (CONTEXT_i386 or $00000010); { DB 0-3,6,7 }
  CONTEXT_FULL = (CONTEXT_CONTROL or CONTEXT_INTEGER or CONTEXT_SEGMENTS);

type
  PFloatingSaveArea = ^TFloatingSaveArea;
  _FLOATING_SAVE_AREA = record
    ControlWord: DWORD;
    StatusWord: DWORD;
    TagWord: DWORD;
    ErrorOffset: DWORD;
    ErrorSelector: DWORD;
    DataOffset: DWORD;
    DataSelector: DWORD;
    RegisterArea: array[0..SIZE_OF_80387_REGISTERS - 1] of Byte;
    Cr0NpxState: DWORD;
  end;
  TFloatingSaveArea = _FLOATING_SAVE_AREA;
  FLOATING_SAVE_AREA = _FLOATING_SAVE_AREA;

{ This frame has a several purposes: 1) it is used as an argument to
  NtContinue, 2) is is used to constuct a call frame for APC delivery,
  and 3) it is used in the user level thread creation routines.
  The layout of the record conforms to a standard call frame. }

  PContext = ^TContext;
  _CONTEXT = record

  { The flags values within this flag control the contents of
    a CONTEXT record.

    If the context record is used as an input parameter, then
    for each portion of the context record controlled by a flag
    whose value is set, it is assumed that that portion of the
    context record contains valid context. If the context record
    is being used to modify a threads context, then only that
    portion of the threads context will be modified.

    If the context record is used as an IN OUT parameter to capture
    the context of a thread, then only those portions of the thread's
    context corresponding to set flags will be returned.

    The context record is never used as an OUT only parameter. }

    ContextFlags: DWORD;

  { This section is specified/returned if CONTEXT_DEBUG_REGISTERS is
    set in ContextFlags.  Note that CONTEXT_DEBUG_REGISTERS is NOT
    included in CONTEXT_FULL. }

    Dr0: DWORD;
    Dr1: DWORD;
    Dr2: DWORD;
    Dr3: DWORD;
    Dr6: DWORD;
    Dr7: DWORD;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_FLOATING_POINT. }

    FloatSave: TFloatingSaveArea;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_SEGMENTS. }

    SegGs: DWORD;
    SegFs: DWORD;
    SegEs: DWORD;
    SegDs: DWORD;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_INTEGER. }

    Edi: DWORD;
    Esi: DWORD;
    Ebx: DWORD;
    Edx: DWORD;
    Ecx: DWORD;
    Eax: DWORD;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_CONTROL. }

    Ebp: DWORD;
    Eip: DWORD;
    SegCs: DWORD;
    EFlags: DWORD;
    Esp: DWORD;
    SegSs: DWORD;
  end;
  TContext = _CONTEXT;
  CONTEXT = _CONTEXT;

const
  { bitfield constants for Flags field of TLDTEntry }

  LDTF_BASEMID      = DWORD($FF000000);  {8}
  LDTF_TYPE_8       = $00F80000;  {5}
  LDTF_DPL          = $00060000;  {2}
  LDTF_PRES         = $00010000;  {1}
  LDTF_LIMITHI      = $0000F000;  {4}
  LDTF_SYS          = $00000800;  {1}
  LDTF_RESERVED_0   = $00000400;  {1}
  LDTF_DEFAULT_BIG  = $00000200;  {1}
  LDTF_GRANULARITY  = $00000100;  {1}
  LDTF_BASEHI       = $000000FF;  {8}


type
  PLDTEntry = ^TLDTEntry;
  _LDT_ENTRY = record
    LimitLow: Word;
    BaseLow: Word;
    case Integer of
      0: (
        BaseMid: Byte;
        Flags1: Byte;
        Flags2: Byte;
        BaseHi: Byte);
      1: (
        Flags: Longint);
  end;
  TLDTEntry = _LDT_ENTRY;
  LDT_ENTRY = _LDT_ENTRY;

{line 2030}
const
  EXCEPTION_NONCONTINUABLE     = 1;    { Noncontinuable exception }
  EXCEPTION_MAXIMUM_PARAMETERS = 15;   { maximum number of exception parameters }

type
  PExceptionRecord = ^TExceptionRecord;
  _EXCEPTION_RECORD = record
    ExceptionCode: DWORD;
    ExceptionFlags: DWORD;
    ExceptionRecord: PExceptionRecord;
    ExceptionAddress: Pointer;
    NumberParameters: DWORD;
    ExceptionInformation: array[0..EXCEPTION_MAXIMUM_PARAMETERS - 1] of DWORD;
  end;
  TExceptionRecord = _EXCEPTION_RECORD;
  EXCEPTION_RECORD = _EXCEPTION_RECORD;

{ Typedef for pointer returned by exception_info() }

  _EXCEPTION_POINTERS = record
    ExceptionRecord : PExceptionRecord;
    ContextRecord : PContext;
  end;
  TExceptionPointers = _EXCEPTION_POINTERS;
  EXCEPTION_POINTERS = _EXCEPTION_POINTERS;

{line 2100}
const
  THREAD_BASE_PRIORITY_LOWRT = 15;  { value that gets a thread to LowRealtime-1 }
  THREAD_BASE_PRIORITY_MAX = 2;     { maximum thread base priority boost }
  THREAD_BASE_PRIORITY_MIN = -2;    { minimum thread base priority boost }
  THREAD_BASE_PRIORITY_IDLE = -15;  { value that gets a thread to idle }

  SYNCHRONIZE = $00100000;
  STANDARD_RIGHTS_REQUIRED = $000F0000;
  EVENT_MODIFY_STATE = $0002;
  EVENT_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $3);
  MUTANT_QUERY_STATE = $0001;
  MUTANT_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or MUTANT_QUERY_STATE);

  PROCESS_TERMINATE         = $0001;
  PROCESS_CREATE_THREAD     = $0002;
  PROCESS_VM_OPERATION      = $0008;
  PROCESS_VM_READ           = $0010;
  PROCESS_VM_WRITE          = $0020;
  PROCESS_DUP_HANDLE        = $0040;
  PROCESS_CREATE_PROCESS    = $0080;
  PROCESS_SET_QUOTA         = $0100;
  PROCESS_SET_INFORMATION   = $0200;
  PROCESS_QUERY_INFORMATION = $0400;
  PROCESS_ALL_ACCESS        = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $FFF);

{line 2150}
type
  PMemoryBasicInformation = ^TMemoryBasicInformation;
  _MEMORY_BASIC_INFORMATION = record
    BaseAddress : Pointer;
    AllocationBase : Pointer;
    AllocationProtect : DWORD;
    RegionSize : SIZE_T;
    State : DWORD;
    Protect : DWORD;
    Type_9 : DWORD;
  end;
  TMemoryBasicInformation = _MEMORY_BASIC_INFORMATION;
  MEMORY_BASIC_INFORMATION = _MEMORY_BASIC_INFORMATION;

const
  SECTION_QUERY = 1;
  SECTION_MAP_WRITE = 2;
  SECTION_MAP_READ = 4;
  SECTION_MAP_EXECUTE = 8;
  SECTION_EXTEND_SIZE = $10;
  SECTION_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SECTION_QUERY or
    SECTION_MAP_WRITE or SECTION_MAP_READ or SECTION_MAP_EXECUTE or SECTION_EXTEND_SIZE);

  PAGE_NOACCESS = 1;
  PAGE_READONLY = 2;
  PAGE_READWRITE = 4;
  PAGE_WRITECOPY = 8;
  PAGE_EXECUTE = $10;
  PAGE_EXECUTE_READ = $20;
  PAGE_EXECUTE_READWRITE = $40;
  PAGE_EXECUTE_WRITECOPY = $80;
  PAGE_GUARD = $100;
  PAGE_NOCACHE = $200;
  MEM_COMMIT = $1000;
  MEM_RESERVE = $2000;
  MEM_DECOMMIT = $4000;
  MEM_RELEASE = $8000;
  MEM_FREE = $10000;
  MEM_PRIVATE = $20000;
  MEM_MAPPED = $40000;
  MEM_RESET = $80000;
  MEM_TOP_DOWN = $100000;
  SEC_FILE = $800000;
  SEC_IMAGE = $1000000;
  SEC_RESERVE = $4000000;
  SEC_COMMIT = $8000000;
  SEC_NOCACHE = $10000000;
  MEM_IMAGE = SEC_IMAGE;


{line 2250}
  FILE_SHARE_READ                     = $00000001;
  FILE_SHARE_WRITE                    = $00000002;
  FILE_SHARE_DELETE                   = $00000004;
  FILE_ATTRIBUTE_READONLY             = $00000001;
  FILE_ATTRIBUTE_HIDDEN               = $00000002;
  FILE_ATTRIBUTE_SYSTEM               = $00000004;
  FILE_ATTRIBUTE_DIRECTORY            = $00000010;
  FILE_ATTRIBUTE_ARCHIVE              = $00000020;
  FILE_ATTRIBUTE_NORMAL               = $00000080;
  FILE_ATTRIBUTE_TEMPORARY            = $00000100;
  FILE_ATTRIBUTE_COMPRESSED           = $00000800;
  FILE_ATTRIBUTE_OFFLINE              = $00001000;
  FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;
  FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;
  FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;
  FILE_NOTIFY_CHANGE_SIZE             = $00000008;
  FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;
  FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;
  FILE_NOTIFY_CHANGE_CREATION         = $00000040;
  FILE_NOTIFY_CHANGE_SECURITY         = $00000100;
  FILE_ACTION_ADDED                   = $00000001;
  FILE_ACTION_REMOVED                 = $00000002;
  FILE_ACTION_MODIFIED                = $00000003;
  FILE_ACTION_RENAMED_OLD_NAME        = $00000004;
  FILE_ACTION_RENAMED_NEW_NAME        = $00000005;
  MAILSLOT_NO_MESSAGE                 = LongWord(-1);
  MAILSLOT_WAIT_FOREVER               = LongWord(-1);
  FILE_CASE_SENSITIVE_SEARCH          = $00000001;
  FILE_CASE_PRESERVED_NAMES           = $00000002;
  FILE_UNICODE_ON_DISK                = $00000004;
  FILE_PERSISTENT_ACLS                = $00000008;
  FILE_FILE_COMPRESSION               = $00000010;
  FILE_VOLUME_IS_COMPRESSED           = $00008000;


{line 2300}
const
  IO_COMPLETION_MODIFY_STATE = $0002;
  IO_COMPLETION_ALL_ACCESS   = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or 3);
  DUPLICATE_CLOSE_SOURCE     = $00000001;
  DUPLICATE_SAME_ACCESS      = $00000002;

type
  PSECURITY_DESCRIPTOR = Pointer;

  ACCESS_MASK = DWORD;
  PACCESS_MASK = ^ACCESS_MASK;

const
  { The following are masks for the predefined standard access types }

  _DELETE                  = $00010000; { Renamed from DELETE }
  READ_CONTROL             = $00020000;
  WRITE_DAC                = $00040000;
  WRITE_OWNER              = $00080000;
{ SYNCHRONIZE              = $00100000; defined above }
{ STANDARD_RIGHTS_REQUIRED = $000F0000; defined above }
  STANDARD_RIGHTS_READ     = READ_CONTROL;
  STANDARD_RIGHTS_WRITE    = READ_CONTROL;
  STANDARD_RIGHTS_EXECUTE  = READ_CONTROL;
  STANDARD_RIGHTS_ALL      = $001F0000;
  SPECIFIC_RIGHTS_ALL      = $0000FFFF;
  ACCESS_SYSTEM_SECURITY   = $01000000;
  MAXIMUM_ALLOWED          = $02000000;
  GENERIC_READ             = DWORD($80000000);
  GENERIC_WRITE            = $40000000;
  GENERIC_EXECUTE          = $20000000;
  GENERIC_ALL              = $10000000;

type
  { Define the generic mapping array.  This is used to denote the
    mapping of each generic access right to a specific access mask. }

  PGenericMapping = ^TGenericMapping;
  _GENERIC_MAPPING = record
    GenericRead: ACCESS_MASK;
    GenericWrite: ACCESS_MASK;
    GenericExecute: ACCESS_MASK;
    GenericAll: ACCESS_MASK;
  end;
  TGenericMapping = _GENERIC_MAPPING;
  GENERIC_MAPPING = _GENERIC_MAPPING;

  PLUIDAndAttributes = ^TLUIDAndAttributes;
  _LUID_AND_ATTRIBUTES = packed record
    Luid: TLargeInteger;
    Attributes: DWORD;
  end;
  TLUIDAndAttributes = _LUID_AND_ATTRIBUTES;
  LUID_AND_ATTRIBUTES = _LUID_AND_ATTRIBUTES;

{ ////////////////////////////////////////////////////////////////////// }
{                                                                    // }
{              Security Id     (SID)                                 // }
{                                                                    // }
{ ////////////////////////////////////////////////////////////////////// }


{ Pictorially the structure of an SID is as follows: }

{         1   1   1   1   1   1 }
{         5   4   3   2   1   0   9   8   7   6   5   4   3   2   1   0 }
{      +---------------------------------------------------------------+ }
{      |      SubAuthorityCount        |Reserved1 (SBZ)|   Revision    | }
{      +---------------------------------------------------------------+ }
{      |                   IdentifierAuthority[0]                      | }
{      +---------------------------------------------------------------+ }
{      |                   IdentifierAuthority[1]                      | }
{      +---------------------------------------------------------------+ }
{      |                   IdentifierAuthority[2]                      | }
{      +---------------------------------------------------------------+ }
{      |                                                               | }
{      +- -  -  -  -  -  -  -  SubAuthority[]  -  -  -  -  -  -  -  - -+ }
{      |                                                               | }
{      +---------------------------------------------------------------+ }

  PSIDIdentifierAuthority = ^TSIDIdentifierAuthority;
  _SID_IDENTIFIER_AUTHORITY = record
    Value: array[0..5] of Byte;
  end;
  TSIDIdentifierAuthority = _SID_IDENTIFIER_AUTHORITY;
  SID_IDENTIFIER_AUTHORITY = _SID_IDENTIFIER_AUTHORITY;

const
  SidTypeUser = 1;
  SidTypeGroup = 2;
  SidTypeDomain = 3;
  SidTypeAlias = 4;
  SidTypeWellKnownGroup = 5;
  SidTypeDeletedAccount = 6;
  SidTypeInvalid = 7;
  SidTypeUnknown = 8;
type
  SID_NAME_USE = DWORD;

  PSIDAndAttributes = ^TSIDAndAttributes;
  _SID_AND_ATTRIBUTES = record
    Sid: PSID;
    Attributes: DWORD;
  end;
  TSIDAndAttributes = _SID_AND_ATTRIBUTES;
  SID_AND_ATTRIBUTES = _SID_AND_ATTRIBUTES;

{line 2700}
  PACL = ^TACL;
  _ACL = record
    AclRevision: Byte;
    Sbz1: Byte;
    AclSize: Word;
    AceCount: Word;
    Sbz2: Word;
  end;
  TACL = _ACL;
  ACL = _ACL;

{line 2850}
  { The following declarations are used for setting and querying information
    about and ACL.  First are the various information classes available to
    the user. }

  TAclInformationClass = (AclInfoPad, AclRevisionInformation, AclSizeInformation);

{line 2900}
{ Security Descriptor and related data types. }

const
  SECURITY_DESCRIPTOR_REVISION = 1;
  SECURITY_DESCRIPTOR_REVISION1 = 1;
  SECURITY_DESCRIPTOR_MIN_LENGTH = 20;
  SE_OWNER_DEFAULTED = $0001;
  SE_GROUP_DEFAULTED = $0002;
  SE_DACL_PRESENT    = $0004;
  SE_DACL_DEFAULTED  = $0008;
  SE_SACL_PRESENT    = $0010;
  SE_SACL_DEFAULTED  = $0020;
  SE_DACL_AUTO_INHERIT_REQ = $0100;
  SE_SACL_AUTO_INHERIT_REQ = $0200;
  SE_DACL_AUTO_INHERITED = $0400;
  SE_SACL_AUTO_INHERITED = $0800;
  SE_DACL_PROTECTED = $1000;
  SE_SACL_PROTECTED = $2000;

  SE_SELF_RELATIVE   = $8000;

{  Where: }

{      SE_OWNER_DEFAULTED - This boolean flag, when set, indicates that the }
{          SID pointed to by the Owner field was provided by a }
{          defaulting mechanism rather than explicitly provided by the }
{          original provider of the security descriptor.  This may }
{          affect the treatment of the SID with respect to inheritence }
{          of an owner. }

{      SE_GROUP_DEFAULTED - This boolean flag, when set, indicates that the }
{          SID in the Group field was provided by a defaulting mechanism }
{          rather than explicitly provided by the original provider of }
{          the security descriptor.  This may affect the treatment of }
{          the SID with respect to inheritence of a primary group. }

{      SE_DACL_PRESENT - This boolean flag, when set, indicates that the }
{          security descriptor contains a discretionary ACL.  If this }
{          flag is set and the Dacl field of the SECURITY_DESCRIPTOR is }
{          null, then a null ACL is explicitly being specified. }

{      SE_DACL_DEFAULTED - This boolean flag, when set, indicates that the }
{          ACL pointed to by the Dacl field was provided by a defaulting }
{          mechanism rather than explicitly provided by the original }
{          provider of the security descriptor.  This may affect the }
{          treatment of the ACL with respect to inheritence of an ACL. }
{          This flag is ignored if the DaclPresent flag is not set. }

{      SE_SACL_PRESENT - This boolean flag, when set,  indicates that the }
{          security descriptor contains a system ACL pointed to by the }
{          Sacl field.  If this flag is set and the Sacl field of the }
{          SECURITY_DESCRIPTOR is null, then an empty (but present) }
{          ACL is being specified. }

{      SE_SACL_DEFAULTED - This boolean flag, when set, indicates that the }
{          ACL pointed to by the Sacl field was provided by a defaulting }
{          mechanism rather than explicitly provided by the original }
{          provider of the security descriptor.  This may affect the }
{          treatment of the ACL with respect to inheritence of an ACL. }
{          This flag is ignored if the SaclPresent flag is not set. }

{      SE_SELF_RELATIVE - This boolean flag, when set, indicates that the }
{          security descriptor is in self-relative form.  In this form, }
{          all fields of the security descriptor are contiguous in memory }
{          and all pointer fields are expressed as offsets from the }
{          beginning of the security descriptor.  This form is useful }
{          for treating security descriptors as opaque data structures }
{          for transmission in communication protocol or for storage on }
{          secondary media. }



{ Pictorially the structure of a security descriptor is as follows: }

{       3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 }
{       1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 }
{      +---------------------------------------------------------------+ }
{      |            Control            |Reserved1 (SBZ)|   Revision    | }
{      +---------------------------------------------------------------+ }
{      |                            Owner                              | }
{      +---------------------------------------------------------------+ }
{      |                            Group                              | }
{      +---------------------------------------------------------------+ }
{      |                            Sacl                               | }
{      +---------------------------------------------------------------+ }
{      |                            Dacl                               | }
{      +---------------------------------------------------------------+ }

{ In general, this data structure should be treated opaquely to ensure future }
{ compatibility. }


type
  SECURITY_DESCRIPTOR_CONTROL = Word;
  PSECURITY_DESCRIPTOR_CONTROL = ^WORD;

  { In general, this data structure should be treated opaquely
    to ensure future compatibility. }

  PSecurityDescriptor = ^TSecurityDescriptor;
  _SECURITY_DESCRIPTOR = record
    Revision: Byte;
    Sbz1: Byte;
    Control: SECURITY_DESCRIPTOR_CONTROL;
    Owner: PSID;
    Group: PSID;
    Sacl: PACL;
    Dacl: PACL;
  end;
  TSecurityDescriptor = _SECURITY_DESCRIPTOR;
  SECURITY_DESCRIPTOR = _SECURITY_DESCRIPTOR;

  PObjectTypeList = ^TObjectTypeList;
  _OBJECT_TYPE_LIST = record
    Level: WORD;
    Sbz: WORD;
    ObjectType: PGUID;
  end;
  TObjectTypeList = _OBJECT_TYPE_LIST;
  OBJECT_TYPE_LIST = _OBJECT_TYPE_LIST;

const
  { DS values for Level }
  ACCESS_OBJECT_GUID = 0;
  ACCESS_PROPERTY_SET_GUID = 1;
  ACCESS_PROPERTY_GUID = 2;

  ACCESS_MAX_LEVEL = 4;

type
  AUDIT_EVENT_TYPE = DWORD;

const
  AUDIT_ALLOW_NO_PRIVILEGE = $1;


{ Privilege Related Data Structures }

const
  { Privilege attributes }

  SE_PRIVILEGE_ENABLED_BY_DEFAULT = $00000001;
  SE_PRIVILEGE_ENABLED            = $00000002;
  SE_PRIVILEGE_USED_FOR_ACCESS    = DWORD($80000000);

  { Privilege Set Control flags }

  PRIVILEGE_SET_ALL_NECESSARY = 1;

  {  Privilege Set - This is defined for a privilege set of one.
                   If more than one privilege is needed, then this structure
                   will need to be allocated with more space.}
  {  Note: don't change this structure without fixing the INITIAL_PRIVILEGE_SET}

type
  PPrivilegeSet = ^TPrivilegeSet;
  _PRIVILEGE_SET = record
    PrivilegeCount: DWORD;
    Control: DWORD;
    Privilege: array[0..0] of TLUIDAndAttributes;
  end;
  TPrivilegeSet = _PRIVILEGE_SET;
  PRIVILEGE_SET = _PRIVILEGE_SET;

{ line 3130 }
  TSecurityImpersonationLevel = (SecurityAnonymous,
    SecurityIdentification, SecurityImpersonation, SecurityDelegation);

const
  SECURITY_MAX_IMPERSONATION_LEVEL     = SecurityDelegation;
  DEFAULT_IMPERSONATION_LEVEL     = SecurityImpersonation;

const
  TOKEN_ASSIGN_PRIMARY = $0001;
  TOKEN_DUPLICATE = $0002;
  TOKEN_IMPERSONATE = $0004;
  TOKEN_QUERY = $0008;
  TOKEN_QUERY_SOURCE = $0010;
  TOKEN_ADJUST_PRIVILEGES = $0020;
  TOKEN_ADJUST_GROUPS = $0040;
  TOKEN_ADJUST_DEFAULT = $0080;
  TOKEN_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or TOKEN_ASSIGN_PRIMARY or
    TOKEN_DUPLICATE or TOKEN_IMPERSONATE or TOKEN_QUERY or
    TOKEN_QUERY_SOURCE or TOKEN_ADJUST_PRIVILEGES or TOKEN_ADJUST_GROUPS or
    TOKEN_ADJUST_DEFAULT);
  TOKEN_READ = (STANDARD_RIGHTS_READ or TOKEN_QUERY);
  TOKEN_WRITE = (STANDARD_RIGHTS_WRITE or TOKEN_ADJUST_PRIVILEGES or
    TOKEN_ADJUST_GROUPS or TOKEN_ADJUST_DEFAULT);
  TOKEN_EXECUTE = STANDARD_RIGHTS_EXECUTE;

type
  TTokenType = (TokenTPad, TokenPrimary, TokenImpersonation);

  TTokenInformationClass = (TokenICPad, TokenUser, TokenGroups, TokenPrivileges,
    TokenOwner, TokenPrimaryGroup, TokenDefaultDacl, TokenSource, TokenType,
    TokenImpersonationLevel, TokenStatistics);

  PTokenGroups = ^TTokenGroups;
  _TOKEN_GROUPS = record
    GroupCount: DWORD;
    Groups: array[0..0] of TSIDAndAttributes;
  end;
  TTokenGroups = _TOKEN_GROUPS;
  TOKEN_GROUPS = _TOKEN_GROUPS;

  PTokenPrivileges = ^TTokenPrivileges;
  _TOKEN_PRIVILEGES = record
    PrivilegeCount: DWORD;
    Privileges: array[0..0] of TLUIDAndAttributes;
  end;
  TTokenPrivileges = _TOKEN_PRIVILEGES;
  TOKEN_PRIVILEGES = _TOKEN_PRIVILEGES;

const
  SECURITY_DYNAMIC_TRACKING = True;
  SECURITY_STATIC_TRACKING  = False;

type
  SECURITY_CONTEXT_TRACKING_MODE = Boolean;

  PSecurityQualityOfService = ^TSecurityQualityOfService;
  _SECURITY_QUALITY_OF_SERVICE = record
    Length: DWORD;
    ImpersonationLevel: TSecurityImpersonationLevel;
    ContextTrackingMode: SECURITY_CONTEXT_TRACKING_MODE;
    EffectiveOnly: Boolean;
  end;
  TSecurityQualityOfService = _SECURITY_QUALITY_OF_SERVICE;
  SECURITY_QUALITY_OF_SERVICE = _SECURITY_QUALITY_OF_SERVICE;

{line 3320}
  SECURITY_INFORMATION = DWORD;
  PSECURITY_INFORMATION = ^DWORD;

const
  OWNER_SECURITY_INFORMATION =  $00000001;
  GROUP_SECURITY_INFORMATION =  $00000002;
  DACL_SECURITY_INFORMATION  =  $00000004;
  SACL_SECURITY_INFORMATION  =  $00000008;

type
  TThreadStartRoutine = function(lpThreadParameter: Pointer): Integer stdcall;

{line 3337}
const
  IMAGE_DOS_SIGNATURE                     = $5A4D;      { MZ }
  IMAGE_OS2_SIGNATURE                     = $454E;      { NE }
  IMAGE_OS2_SIGNATURE_LE                  = $454C;      { LE }
  IMAGE_VXD_SIGNATURE                     = $454C;      { LE }
  IMAGE_NT_SIGNATURE                      = $00004550;  { PE00 }

{line 3457}
{ File header format. }

type
  PImageDosHeader = ^TImageDosHeader;
    {EXTERNALSYM _IMAGE_DOS_HEADER}
  _IMAGE_DOS_HEADER = packed record      { DOS .EXE header                  }
      e_magic: Word;                     { Magic number                     }
      e_cblp: Word;                      { Bytes on last page of file       }
      e_cp: Word;                        { Pages in file                    }
      e_crlc: Word;                      { Relocations                      }
      e_cparhdr: Word;                   { Size of header in paragraphs     }
      e_minalloc: Word;                  { Minimum extra paragraphs needed  }
      e_maxalloc: Word;                  { Maximum extra paragraphs needed  }
      e_ss: Word;                        { Initial (relative) SS value      }
      e_sp: Word;                        { Initial SP value                 }
      e_csum: Word;                      { Checksum                         }
      e_ip: Word;                        { Initial IP value                 }
      e_cs: Word;                        { Initial (relative) CS value      }
      e_lfarlc: Word;                    { File address of relocation table }
      e_ovno: Word;                      { Overlay number                   }
      e_res: array [0..3] of Word;       { Reserved words                   }
      e_oemid: Word;                     { OEM identifier (for e_oeminfo)   }
      e_oeminfo: Word;                   { OEM information; e_oemid specific}
      e_res2: array [0..9] of Word;      { Reserved words                   }
      _lfanew: LongInt;                  { File address of new exe header   }
  end;
  TImageDosHeader = _IMAGE_DOS_HEADER;
  IMAGE_DOS_HEADER = _IMAGE_DOS_HEADER;


  PImageFileHeader = ^TImageFileHeader;
  _IMAGE_FILE_HEADER = packed record
    Machine: Word;
    NumberOfSections: Word;
    TimeDateStamp: DWORD;
    PointerToSymbolTable: DWORD;
    NumberOfSymbols: DWORD;
    SizeOfOptionalHeader: Word;
    Characteristics: Word;
  end;
  TImageFileHeader = _IMAGE_FILE_HEADER;
  IMAGE_FILE_HEADER = _IMAGE_FILE_HEADER;

  PImageExportDirectory = ^TImageExportDirectory;
  _IMAGE_EXPORT_DIRECTORY = packed record
      Characteristics: DWord;
      TimeDateStamp: DWord;
      MajorVersion: Word;
      MinorVersion: Word;
      Name: DWord;
      Base: DWord;
      NumberOfFunctions: DWord;
      NumberOfNames: DWord;
      AddressOfFunctions: ^PDWORD;
      AddressOfNames: ^PDWORD;
      AddressOfNameOrdinals: ^PWord;
  end;
  TImageExportDirectory = _IMAGE_EXPORT_DIRECTORY;
  IMAGE_EXPORT_DIRECTORY = _IMAGE_EXPORT_DIRECTORY;

  { Import Format }

  _IMAGE_IMPORT_BY_NAME = packed record
    Hint: Word;
    Name: array[0..0] of Byte;
  end;
  IMAGE_IMPORT_BY_NAME = _IMAGE_IMPORT_BY_NAME;
  TImageImportByName = _IMAGE_IMPORT_BY_NAME;
  PIMAGE_IMPORT_BY_NAME = ^_IMAGE_IMPORT_BY_NAME;
  PImageImportByName = ^_IMAGE_IMPORT_BY_NAME;

  { #include "pshpack8.h"                       // Use align 8 for the 64-bit IAT. }

  _IMAGE_THUNK_DATA64 = record
    case Byte of
      0: (ForwarderString: ULONGLONG); // PBYTE
      1: (_Function: ULONGLONG);       // PDWORD Function -> _Function
      2: (Ordinal: ULONGLONG);
      3: (AddressOfData: ULONGLONG);   // PIMAGE_IMPORT_BY_NAME
  end;
  IMAGE_THUNK_DATA64 = _IMAGE_THUNK_DATA64;
  TImageThunkData64 = _IMAGE_THUNK_DATA64;
  PIMAGE_THUNK_DATA64 = ^_IMAGE_THUNK_DATA64;
  PImageThunkData64 = ^_IMAGE_THUNK_DATA64;

  { #include "poppack.h"                        // Back to 4 byte packing  }

  _IMAGE_THUNK_DATA32 = record
    case Byte of
      0: (ForwarderString: DWORD); // PBYTE
      1: (_Function: DWORD);       // PDWORD Function -> _Function
      2: (Ordinal: DWORD);
      3: (AddressOfData: DWORD);   // PIMAGE_IMPORT_BY_NAME
  end;
  IMAGE_THUNK_DATA32 = _IMAGE_THUNK_DATA32;
  TImageThunkData32 = _IMAGE_THUNK_DATA32;
  PIMAGE_THUNK_DATA32 = ^_IMAGE_THUNK_DATA32;
  PImageThunkData32 = ^_IMAGE_THUNK_DATA32;

const
  IMAGE_ORDINAL_FLAG64 = UInt64($8000000000000000);
  IMAGE_ORDINAL_FLAG32 = LongWord($80000000);
//  IMAGE_ORDINAL64(Ordinal) (Ordinal & 0xffff)
//  IMAGE_ORDINAL32(Ordinal) (Ordinal & 0xffff)
//  IMAGE_SNAP_BY_ORDINAL64(Ordinal) ((Ordinal & IMAGE_ORDINAL_FLAG64) != 0)
//  IMAGE_SNAP_BY_ORDINAL32(Ordinal) ((Ordinal & IMAGE_ORDINAL_FLAG32) != 0)

type
  { Thread Local Storage }

  PIMAGE_TLS_CALLBACK = procedure (DllHandle: Pointer; Reason: DWORD; Reserved: Pointer) stdcall;
  TImageTLSCallback = PIMAGE_TLS_CALLBACK;

  _IMAGE_TLS_DIRECTORY64 = record
    StartAddressOfRawData: ULONGLONG;
    EndAddressOfRawData: ULONGLONG;
    AddressOfIndex: ULONGLONG;         // PDWORD
    AddressOfCallBacks: ULONGLONG;     // PIMAGE_TLS_CALLBACK *;
    SizeOfZeroFill: DWORD;
    Characteristics: DWORD;
  end;
  IMAGE_TLS_DIRECTORY64 = _IMAGE_TLS_DIRECTORY64;
  TImageTLSDirectory64 = _IMAGE_TLS_DIRECTORY64;
  PIMAGE_TLS_DIRECTORY64 = ^_IMAGE_TLS_DIRECTORY64;
  PImageTLSDirectory64 = ^_IMAGE_TLS_DIRECTORY64;

  _IMAGE_TLS_DIRECTORY32 = record
    StartAddressOfRawData: DWORD;
    EndAddressOfRawData: DWORD;
    AddressOfIndex: DWORD;         // PDWORD
    AddressOfCallBacks: DWORD;     // PIMAGE_TLS_CALLBACK *;
    SizeOfZeroFill: DWORD;
    Characteristics: DWORD;
  end;
  IMAGE_TLS_DIRECTORY32 = _IMAGE_TLS_DIRECTORY32;
  TImageTLSDirectory32 = _IMAGE_TLS_DIRECTORY32;
  PIMAGE_TLS_DIRECTORY32 = ^_IMAGE_TLS_DIRECTORY32;
  PImageTLSDirectory32 = ^_IMAGE_TLS_DIRECTORY32;

const
  IMAGE_ORDINAL_FLAG              = IMAGE_ORDINAL_FLAG32;
  //IMAGE_ORDINAL(Ordinal)          IMAGE_ORDINAL32(Ordinal)
  //IMAGE_SNAP_BY_ORDINAL(Ordinal)  IMAGE_SNAP_BY_ORDINAL32(Ordinal)

type
  IMAGE_THUNK_DATA              = {$ifdef b64}IMAGE_THUNK_DATA64{$else}IMAGE_THUNK_DATA32{$endif b64};
  PIMAGE_THUNK_DATA             = {$ifdef b64}PIMAGE_THUNK_DATA64{$else}PIMAGE_THUNK_DATA32{$endif b64};
  IMAGE_TLS_DIRECTORY           = {$ifdef b64}IMAGE_TLS_DIRECTORY64{$else}IMAGE_TLS_DIRECTORY32{$endif b64};
  PIMAGE_TLS_DIRECTORY          = {$ifdef b64}PIMAGE_TLS_DIRECTORY64{$else}PIMAGE_TLS_DIRECTORY32{$endif b64};

type
  _IMAGE_IMPORT_DESCRIPTOR = record
    case Byte of
      0: (Characteristics: DWORD);          // 0 for terminating null import descriptor
      1: (OriginalFirstThunk: DWORD;        // RVA to original unbound IAT (PIMAGE_THUNK_DATA)
          TimeDateStamp: DWORD;             // 0 if not bound,
                                            // -1 if bound, and real date\time stamp
                                            //     in IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT (new BIND)
                                            // O.W. date/time stamp of DLL bound to (Old BIND)

          ForwarderChain: DWORD;            // -1 if no forwarders
          Name: DWORD;
          FirstThunk: DWORD);                // RVA to IAT (if bound this IAT has actual addresses)
  end;
  IMAGE_IMPORT_DESCRIPTOR = _IMAGE_IMPORT_DESCRIPTOR;
  TImageImportDescriptor = _IMAGE_IMPORT_DESCRIPTOR;
  PIMAGE_IMPORT_DESCRIPTOR = ^_IMAGE_IMPORT_DESCRIPTOR;
  PImageImportDescriptor = ^_IMAGE_IMPORT_DESCRIPTOR;

  { New format import descriptors pointed to by DataDirectory[ IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT ] }

  _IMAGE_BOUND_IMPORT_DESCRIPTOR = record
    TimeDateStamp: DWORD;
    OffsetModuleName: Word;
    NumberOfModuleForwarderRefs: Word;
    // Array of zero or more IMAGE_BOUND_FORWARDER_REF follows
  end;
  IMAGE_BOUND_IMPORT_DESCRIPTOR = _IMAGE_BOUND_IMPORT_DESCRIPTOR;
  TImageBoundImportDescriptor = _IMAGE_BOUND_IMPORT_DESCRIPTOR;
  PIMAGE_BOUND_IMPORT_DESCRIPTOR = ^_IMAGE_BOUND_IMPORT_DESCRIPTOR;
  PImageBountImportDescriptor = ^_IMAGE_BOUND_IMPORT_DESCRIPTOR;

  _IMAGE_BOUND_FORWARDER_REF = record
    TimeDateStamp: DWORD;
    OffsetModuleName: Word;
    Reserved: Word;
  end;
  IMAGE_BOUND_FORWARDER_REF = _IMAGE_BOUND_FORWARDER_REF;
  TImageBoundForwarderRef = _IMAGE_BOUND_FORWARDER_REF;
  PIMAGE_BOUND_FORWARDER_REF = ^_IMAGE_BOUND_FORWARDER_REF;
  PImageBoundForwarderRef = ^_IMAGE_BOUND_FORWARDER_REF;


const
  IMAGE_SIZEOF_FILE_HEADER                 = 20;

  IMAGE_FILE_RELOCS_STRIPPED               = $0001;  { Relocation info stripped from file. }
  IMAGE_FILE_EXECUTABLE_IMAGE              = $0002;  { File is executable  (i.e. no unresolved externel references). }
  IMAGE_FILE_LINE_NUMS_STRIPPED            = $0004;  { Line nunbers stripped from file. }
  IMAGE_FILE_LOCAL_SYMS_STRIPPED           = $0008;  { Local symbols stripped from file. }
  IMAGE_FILE_AGGRESIVE_WS_TRIM             = $0010;  { Agressively trim working set }
  IMAGE_FILE_LARGE_ADDRESS_AWARE           = $0020;  { App can handle >2gb addresses }
  IMAGE_FILE_BYTES_REVERSED_LO             = $0080;  { Bytes of machine word are reversed. }
  IMAGE_FILE_32BIT_MACHINE                 = $0100;  { 32 bit word machine. }
  IMAGE_FILE_DEBUG_STRIPPED                = $0200;  { Debugging info stripped from file in .DBG file }
  IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP       = $0400;  { If Image is on removable media, copy and run from the swap file. }
  IMAGE_FILE_NET_RUN_FROM_SWAP             = $0800;  { If Image is on Net, copy and run from the swap file. }
  IMAGE_FILE_SYSTEM                        = $1000;  { System File. }
  IMAGE_FILE_DLL                           = $2000;  { File is a DLL. }
  IMAGE_FILE_UP_SYSTEM_ONLY                = $4000;  { File should only be run on a UP machine }
  IMAGE_FILE_BYTES_REVERSED_HI             = $8000;  { Bytes of machine word are reversed. }

  IMAGE_FILE_MACHINE_UNKNOWN               = 0;
  IMAGE_FILE_MACHINE_I386                  = $14c;   { Intel 386. }
  IMAGE_FILE_MACHINE_R3000                 = $162;   { MIPS little-endian, 0x160 big-endian }
  IMAGE_FILE_MACHINE_R4000                 = $166;   { MIPS little-endian }
  IMAGE_FILE_MACHINE_R10000                = $168;   { MIPS little-endian }
  IMAGE_FILE_MACHINE_ALPHA                 = $184;   { Alpha_AXP }
  IMAGE_FILE_MACHINE_POWERPC               = $1F0;   { IBM PowerPC Little-Endian }

{ Directory format. }

type
  PImageDataDirectory = ^TImageDataDirectory;
  _IMAGE_DATA_DIRECTORY = record
    VirtualAddress: DWORD;
    Size: DWORD;
  end;
  TImageDataDirectory = _IMAGE_DATA_DIRECTORY;
  IMAGE_DATA_DIRECTORY = _IMAGE_DATA_DIRECTORY;

const
  IMAGE_NUMBEROF_DIRECTORY_ENTRIES        = 16;

{ Optional header format. }

type
  PImageOptionalHeader = ^TImageOptionalHeader;
  _IMAGE_OPTIONAL_HEADER = packed record
    { Standard fields. }
    Magic: Word;
    MajorLinkerVersion: Byte;
    MinorLinkerVersion: Byte;
    SizeOfCode: DWORD;
    SizeOfInitializedData: DWORD;
    SizeOfUninitializedData: DWORD;
    AddressOfEntryPoint: DWORD;
    BaseOfCode: DWORD;
    BaseOfData: DWORD;
    { NT additional fields. }
    ImageBase: DWORD;
    SectionAlignment: DWORD;
    FileAlignment: DWORD;
    MajorOperatingSystemVersion: Word;
    MinorOperatingSystemVersion: Word;
    MajorImageVersion: Word;
    MinorImageVersion: Word;
    MajorSubsystemVersion: Word;
    MinorSubsystemVersion: Word;
    Win32VersionValue: DWORD;
    SizeOfImage: DWORD;
    SizeOfHeaders: DWORD;
    CheckSum: DWORD;
    Subsystem: Word;
    DllCharacteristics: Word;
    SizeOfStackReserve: DWORD;
    SizeOfStackCommit: DWORD;
    SizeOfHeapReserve: DWORD;
    SizeOfHeapCommit: DWORD;
    LoaderFlags: DWORD;
    NumberOfRvaAndSizes: DWORD;
    DataDirectory: packed array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1] of TImageDataDirectory;
  end;
  TImageOptionalHeader = _IMAGE_OPTIONAL_HEADER;
  IMAGE_OPTIONAL_HEADER = _IMAGE_OPTIONAL_HEADER;

  PImageRomOptionalHeader = ^TImageRomOptionalHeader;
  _IMAGE_ROM_OPTIONAL_HEADER = packed record
    Magic: Word;
    MajorLinkerVersion: Byte;
    MinorLinkerVersion: Byte;
    SizeOfCode: DWORD;
    SizeOfInitializedData: DWORD;
    SizeOfUninitializedData: DWORD;
    AddressOfEntryPoint: DWORD;
    BaseOfCode: DWORD;
    BaseOfData: DWORD;
    BaseOfBss: DWORD;
    GprMask: DWORD;
    CprMask: packed array[0..3] of DWORD;
    GpValue: DWORD;
  end;
  TImageRomOptionalHeader = _IMAGE_ROM_OPTIONAL_HEADER;
  IMAGE_ROM_OPTIONAL_HEADER = _IMAGE_ROM_OPTIONAL_HEADER;


const
  IMAGE_SIZEOF_ROM_OPTIONAL_HEADER       = 56;
  IMAGE_SIZEOF_STD_OPTIONAL_HEADER       = 28;
  IMAGE_SIZEOF_NT_OPTIONAL_HEADER        = 224;

  IMAGE_NT_OPTIONAL_HDR_MAGIC            = $010B;
  IMAGE_ROM_OPTIONAL_HDR_MAGIC           = $0107;

type
  PImageNtHeaders = ^TImageNtHeaders;
  _IMAGE_NT_HEADERS = packed record
    Signature: DWORD;
    FileHeader: TImageFileHeader;
    OptionalHeader: TImageOptionalHeader;
  end;
  TImageNtHeaders = _IMAGE_NT_HEADERS;
  IMAGE_NT_HEADERS = _IMAGE_NT_HEADERS;


  PImageRomHeaders = ^TImageRomHeaders;
  _IMAGE_ROM_HEADERS = packed record
    FileHeader: TImageFileHeader;
    OptionalHeader: TImageRomOptionalHeader;
  end;
  TImageRomHeaders = _IMAGE_ROM_HEADERS;
  IMAGE_ROM_HEADERS = _IMAGE_ROM_HEADERS;


{ Subsystem Values }

const
  IMAGE_SUBSYSTEM_UNKNOWN                  = 0;  { Unknown subsystem. }
  IMAGE_SUBSYSTEM_NATIVE                   = 1;  { Image doesn't require a subsystem. }
  IMAGE_SUBSYSTEM_WINDOWS_GUI              = 2;  { Image runs in the Windows GUI subsystem. }
  IMAGE_SUBSYSTEM_WINDOWS_CUI              = 3;  { Image runs in the Windows character subsystem. }
  IMAGE_SUBSYSTEM_OS2_CUI                  = 5;  { image runs in the OS/2 character subsystem. }
  IMAGE_SUBSYSTEM_POSIX_CUI                = 7;  { image run  in the Posix character subsystem. }
  IMAGE_SUBSYSTEM_RESERVED8                = 8;  { image run  in the 8 subsystem. }


{ Directory Entries }

  IMAGE_DIRECTORY_ENTRY_EXPORT             = 0;  { Export Directory }
  IMAGE_DIRECTORY_ENTRY_IMPORT             = 1;  { Import Directory }
  IMAGE_DIRECTORY_ENTRY_RESOURCE           = 2;  { Resource Directory }
  IMAGE_DIRECTORY_ENTRY_EXCEPTION          = 3;  { Exception Directory }
  IMAGE_DIRECTORY_ENTRY_SECURITY           = 4;  { Security Directory }
  IMAGE_DIRECTORY_ENTRY_BASERELOC          = 5;  { Base Relocation Table }
  IMAGE_DIRECTORY_ENTRY_DEBUG              = 6;  { Debug Directory }
  IMAGE_DIRECTORY_ENTRY_COPYRIGHT          = 7;  { Description String }
  IMAGE_DIRECTORY_ENTRY_GLOBALPTR          = 8;  { Machine Value (MIPS GP) }
  IMAGE_DIRECTORY_ENTRY_TLS                = 9;  { TLS Directory }
  IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG       = 10;  { Load Configuration Directory }
  IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT      = 11;  { Bound Import Directory in headers }
  IMAGE_DIRECTORY_ENTRY_IAT               = 12;  { Import Address Table }

{ Section header format. }

  IMAGE_SIZEOF_SHORT_NAME                  = 8;

type
  TISHMisc = packed record
    case Integer of
      0: (PhysicalAddress: DWORD);
      1: (VirtualSize: DWORD);
  end;

  PImageSectionHeader = ^TImageSectionHeader;
  _IMAGE_SECTION_HEADER = packed record
    Name: packed array[0..IMAGE_SIZEOF_SHORT_NAME-1] of Byte;
    Misc: TISHMisc;
    VirtualAddress: DWORD;
    SizeOfRawData: DWORD;
    PointerToRawData: DWORD;
    PointerToRelocations: DWORD;
    PointerToLinenumbers: DWORD;
    NumberOfRelocations: Word;
    NumberOfLinenumbers: Word;
    Characteristics: DWORD;
  end;
  TImageSectionHeader = _IMAGE_SECTION_HEADER;
  IMAGE_SECTION_HEADER = _IMAGE_SECTION_HEADER;


const
  IMAGE_SIZEOF_SECTION_HEADER              = 40;


{ Section characteristics. }

{      IMAGE_SCN_TYPE_REG                   0x00000000  // Reserved. }
{      IMAGE_SCN_TYPE_DSECT                 0x00000001  // Reserved. }
{      IMAGE_SCN_TYPE_NOLOAD                0x00000002  // Reserved. }
{      IMAGE_SCN_TYPE_GROUP                 0x00000004  // Reserved. }
  IMAGE_SCN_TYPE_NO_PAD                    = $00000008;  { Reserved. }
{      IMAGE_SCN_TYPE_COPY                  0x00000010  // Reserved. }

  IMAGE_SCN_CNT_CODE                       = $00000020;  { Section contains code. }
  IMAGE_SCN_CNT_INITIALIZED_DATA           = $00000040;  { Section contains initialized data. }
  IMAGE_SCN_CNT_UNINITIALIZED_DATA         = $00000080;  { Section contains uninitialized data. }

  IMAGE_SCN_LNK_OTHER                      = $00000100;  { Reserved. }
  IMAGE_SCN_LNK_INFO                       = $00000200;  { Section contains comments or some other type of information. }
{      IMAGE_SCN_TYPE_OVER                  0x00000400  // Reserved. }
  IMAGE_SCN_LNK_REMOVE                     = $00000800;  { Section contents will not become part of image. }
  IMAGE_SCN_LNK_COMDAT                     = $00001000;  { Section contents comdat. }
{                                           0x00002000  // Reserved. }

{      IMAGE_SCN_MEM_PROTECTED - Obsolete   0x00004000 }
  IMAGE_SCN_MEM_FARDATA                    = $00008000;
{      IMAGE_SCN_MEM_SYSHEAP  - Obsolete    0x00010000 }
  IMAGE_SCN_MEM_PURGEABLE                  = $00020000;
  IMAGE_SCN_MEM_16BIT                      = $00020000;
  IMAGE_SCN_MEM_LOCKED                     = $00040000;
  IMAGE_SCN_MEM_PRELOAD                    = $00080000;

  IMAGE_SCN_ALIGN_1BYTES                   = $00100000;
  IMAGE_SCN_ALIGN_2BYTES                   = $00200000;
  IMAGE_SCN_ALIGN_4BYTES                   = $00300000;
  IMAGE_SCN_ALIGN_8BYTES                   = $00400000;
  IMAGE_SCN_ALIGN_16BYTES                  = $00500000;  { Default alignment if no others are specified. }
  IMAGE_SCN_ALIGN_32BYTES                  = $00600000;
  IMAGE_SCN_ALIGN_64BYTES                  = $00700000;
{ Unused                                    0x00800000 }

  IMAGE_SCN_LNK_NRELOC_OVFL                = $01000000;  { Section contains extended relocations. }
  IMAGE_SCN_MEM_DISCARDABLE                = $02000000;  { Section can be discarded. }
  IMAGE_SCN_MEM_NOT_CACHED                 = $04000000;  { Section is not cachable. }
  IMAGE_SCN_MEM_NOT_PAGED                  = $08000000;  { Section is not pageable. }
  IMAGE_SCN_MEM_SHARED                     = $10000000;  { Section is shareable. }
  IMAGE_SCN_MEM_EXECUTE                    = $20000000;  { Section is executable. }
  IMAGE_SCN_MEM_READ                       = $40000000;  { Section is readable. }
  IMAGE_SCN_MEM_WRITE                      = DWORD($80000000);  { Section is writeable. }


{line 4281}
type
  PImageLoadConfigDirectory = ^TImageLoadConfigDirectory;
  IMAGE_LOAD_CONFIG_DIRECTORY = packed record
    Characteristics: DWORD;
    TimeDateStamp: DWORD;
    MajorVersion: Word;
    MinorVersion: Word;
    GlobalFlagsClear: DWORD;
    GlobalFlagsSet: DWORD;
    CriticalSectionDefaultTimeout: DWORD;
    DeCommitFreeBlockThreshold: DWORD;
    DeCommitTotalFreeThreshold: DWORD;
    LockPrefixTable: Pointer;
    MaximumAllocationSize: DWORD;
    VirtualMemoryThreshold: DWORD;
    ProcessHeapFlags: DWORD;
    ProcessAffinityMask: DWORD;
    Reserved: array[0..2] of DWORD;
  end;
  TImageLoadConfigDirectory = IMAGE_LOAD_CONFIG_DIRECTORY;
//  IMAGE_LOAD_CONFIG_DIRECTORY = _IMAGE_LOAD_CONFIG_DIRECTORY;


// Function table entry format for MIPS/ALPHA images.  Function table is
// pointed to by the IMAGE_DIRECTORY_ENTRY_EXCEPTION directory entry.
// This definition duplicates ones in ntmips.h and ntalpha.h for use
// by portable image file mungers.

  PImageRuntimeFunctionEntry = ^TImageRuntimeFunctionEntry;
  IMAGE_RUNTIME_FUNCTION_ENTRY = record
    BeginAddress: DWORD;
    EndAddress: DWORD;
    ExceptionHandler: Pointer;
    HandlerData: Pointer;
    PrologEndAddress: DWORD;
  end;
  TImageRuntimeFunctionEntry = IMAGE_RUNTIME_FUNCTION_ENTRY;
// IMAGE_RUNTIME_FUNCTION_ENTRY = _IMAGE_RUNTIME_FUNCTION_ENTRY;


//
// Debug Format
//

  PImageDebugDirectory = ^TImageDebugDirectory;
  _IMAGE_DEBUG_DIRECTORY = packed record
    Characteristics: DWORD;
    TimeDateStamp: DWORD;
    MajorVersion: Word;
    MinorVersion: Word;
    _Type: DWORD;
    SizeOfData: DWORD;
    AddressOfRawData: DWORD;
    PointerToRawData: DWORD;
  end;
  TImageDebugDirectory = _IMAGE_DEBUG_DIRECTORY;
  IMAGE_DEBUG_DIRECTORY = _IMAGE_DEBUG_DIRECTORY;


const
  IMAGE_DEBUG_TYPE_UNKNOWN          = 0;
  IMAGE_DEBUG_TYPE_COFF             = 1;
  IMAGE_DEBUG_TYPE_CODEVIEW         = 2;
  IMAGE_DEBUG_TYPE_FPO              = 3;
  IMAGE_DEBUG_TYPE_MISC             = 4;
  IMAGE_DEBUG_TYPE_EXCEPTION        = 5;
  IMAGE_DEBUG_TYPE_FIXUP            = 6;
  IMAGE_DEBUG_TYPE_OMAP_TO_SRC      = 7;
  IMAGE_DEBUG_TYPE_OMAP_FROM_SRC    = 8;

type
  PImageCOFFSymbolsHeader = ^TImageCOFFSymbolsHeader;
  _IMAGE_COFF_SYMBOLS_HEADER = record
    NumberOfSymbols: DWORD;
    LvaToFirstSymbol: DWORD;
    NumberOfLinenumbers: DWORD;
    LvaToFirstLinenumber: DWORD;
    RvaToFirstByteOfCode: DWORD;
    RvaToLastByteOfCode: DWORD;
    RvaToFirstByteOfData: DWORD;
    RvaToLastByteOfData: DWORD;
  end;
  TImageCOFFSymbolsHeader = _IMAGE_COFF_SYMBOLS_HEADER;
  IMAGE_COFF_SYMBOLS_HEADER = _IMAGE_COFF_SYMBOLS_HEADER;


const
  FRAME_FPO       = 0;
  FRAME_TRAP      = 1;
  FRAME_TSS       = 2;
  FRAME_NONFPO    = 3;

type
  PFpoData = ^TFpoData;
  _FPO_DATA = packed record
    ulOffStart: DWORD;             // offset 1st byte of function code
    cbProcSize: DWORD;             // # bytes in function
    cdwLocals: DWORD;              // # bytes in locals/4
    cdwParams: Word;              // # bytes in params/4
{    WORD        cbProlog : 8;           // # bytes in prolog
     WORD        cbRegs   : 3;           // # regs saved
     WORD        fHasSEH  : 1;           // TRUE if SEH in func
     WORD        fUseBP   : 1;           // TRUE if EBP has been allocated
     WORD        reserved : 1;           // reserved for future use
     WORD        cbFrame  : 2;}           // frame type
     cbProlog: Byte;
     OtherStuff: Byte;
  end;
  TFpoData = _FPO_DATA;
  FPO_DATA = _FPO_DATA;


const
  SIZEOF_RFPO_DATA         = 16;
  IMAGE_DEBUG_MISC_EXENAME = 1;

type
  PImageDebugMisc = ^TImageDebugMisc;
  _IMAGE_DEBUG_MISC = packed record
    DataType: DWORD;               // type of misc data, see defines
    Length: DWORD;                 // total length of record, rounded to four
                                   // byte multiple.
    Unicode: ByteBool;             // TRUE if data is unicode string
    Reserved: array[0..2] of Byte;
    Data: array[0..0] of Byte;     // Actual data
  end;
  TImageDebugMisc = _IMAGE_DEBUG_MISC;
  IMAGE_DEBUG_MISC = _IMAGE_DEBUG_MISC;


//
// Function table extracted from MIPS/ALPHA images.  Does not contain
// information needed only for runtime support.  Just those fields for
// each entry needed by a debugger.
//
  PImageFunctionEntry = ^TImageFunctionEntry;
  _IMAGE_FUNCTION_ENTRY = record
    StartingAddress: DWORD;
    EndingAddress: DWORD;
    EndOfPrologue: DWORD;
  end;
  TImageFunctionEntry = _IMAGE_FUNCTION_ENTRY;
  IMAGE_FUNCTION_ENTRY = _IMAGE_FUNCTION_ENTRY;


{line 4587}
type
  PRTLCriticalSection = ^TRTLCriticalSection;
  PRTLCriticalSectionDebug = ^TRTLCriticalSectionDebug;
  _RTL_CRITICAL_SECTION_DEBUG = record
    Type_18: Word;
    CreatorBackTraceIndex: Word;
    CriticalSection: PRTLCriticalSection;
    ProcessLocksList: TListEntry;
    EntryCount: DWORD;
    ContentionCount: DWORD;
    Spare: array[0..1] of DWORD;
  end;
  TRTLCriticalSectionDebug = _RTL_CRITICAL_SECTION_DEBUG;
  RTL_CRITICAL_SECTION_DEBUG = _RTL_CRITICAL_SECTION_DEBUG;

  _RTL_CRITICAL_SECTION = record
    DebugInfo: PRTLCriticalSectionDebug;
    LockCount: Longint;
    RecursionCount: Longint;
    OwningThread: THandle;
    LockSemaphore: THandle;
    SpinCount: ULONG_PTR;
  end;
  TRTLCriticalSection = _RTL_CRITICAL_SECTION;
  RTL_CRITICAL_SECTION = _RTL_CRITICAL_SECTION;

const
  RTL_CRITSECT_TYPE = 0;
  RTL_RESOURCE_TYPE = 1;


  DLL_PROCESS_ATTACH = 1;
  DLL_THREAD_ATTACH = 2;
  DLL_THREAD_DETACH = 3;
  DLL_PROCESS_DETACH = 0;

{line 4630}

{ The types of events that can be logged. }

  EVENTLOG_SUCCESS          = $0000;
  EVENTLOG_ERROR_TYPE       = $0001;
  EVENTLOG_WARNING_TYPE     = $0002;
  EVENTLOG_INFORMATION_TYPE = $0004;
  EVENTLOG_AUDIT_SUCCESS    = $0008;
  EVENTLOG_AUDIT_FAILURE    = $0010;

{line 4700}

{ Registry Specific Access Rights. }

  KEY_QUERY_VALUE    = $0001;
  KEY_SET_VALUE      = $0002;
  KEY_CREATE_SUB_KEY = $0004;
  KEY_ENUMERATE_SUB_KEYS = $0008;
  KEY_NOTIFY         = $0010;
  KEY_CREATE_LINK    = $0020;


  KEY_READ           = (STANDARD_RIGHTS_READ or
                        KEY_QUERY_VALUE or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY) and not
                        SYNCHRONIZE;



  KEY_WRITE          = (STANDARD_RIGHTS_WRITE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY) and not
                        SYNCHRONIZE;

  KEY_EXECUTE        =  KEY_READ and not SYNCHRONIZE;


  KEY_ALL_ACCESS     = (STANDARD_RIGHTS_ALL or
                        KEY_QUERY_VALUE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY or
                        KEY_CREATE_LINK) and not
                        SYNCHRONIZE;

  { Registry Open/Create Options }

  REG_OPTION_RESERVED     = ($00000000);    { Parameter is reserved }

  REG_OPTION_NON_VOLATILE = ($00000000);    { Key is preserved }
                                            { when system is rebooted }

  REG_OPTION_VOLATILE     = ($00000001);    { Key is not preserved }
                                            { when system is rebooted }

  REG_OPTION_CREATE_LINK  = ($00000002);    { Created key is a }
                                            { symbolic link }

  REG_OPTION_BACKUP_RESTORE = ($00000004);  { open for backup or restore }
                                            { special access rules }
                                            { privilege required   }

  REG_LEGAL_OPTION  = (REG_OPTION_RESERVED or
                       REG_OPTION_NON_VOLATILE or
                       REG_OPTION_VOLATILE or
                       REG_OPTION_CREATE_LINK or
                       REG_OPTION_BACKUP_RESTORE);

  { Registry Key creation/open disposition }

  REG_CREATED_NEW_KEY     = ($00000001);    { New Registry Key created }
  REG_OPENED_EXISTING_KEY = ($00000002);    { Existing Key opened }

  { Registry Key restore flags }

  REG_WHOLE_HIVE_VOLATILE = ($00000001);    { Restore whole hive volatile }
  REG_REFRESH_HIVE        = ($00000002);    { Unwind changes to last flush }

  { Registry Notify filter values }

  REG_NOTIFY_CHANGE_NAME       = ($00000001); { Create or delete (child) }
  REG_NOTIFY_CHANGE_ATTRIBUTES = ($00000002);
  REG_NOTIFY_CHANGE_LAST_SET   = ($00000004); { time stamp }
  REG_NOTIFY_CHANGE_SECURITY   = ($00000008);

  REG_LEGAL_CHANGE_FILTER = (REG_OPTION_RESERVED or
                             REG_NOTIFY_CHANGE_NAME or
                             REG_NOTIFY_CHANGE_ATTRIBUTES or
                             REG_NOTIFY_CHANGE_LAST_SET or
                             REG_NOTIFY_CHANGE_SECURITY);

  { Registry Predefined Value Types }

  REG_NONE                    = 0;
  REG_SZ                      = 1;
  REG_EXPAND_SZ               = 2;
  REG_BINARY                  = 3;
  REG_DWORD                   = 4;
  REG_DWORD_LITTLE_ENDIAN     = 4;
  REG_DWORD_BIG_ENDIAN        = 5;
  REG_LINK                    = 6;
  REG_MULTI_SZ                = 7;
  REG_RESOURCE_LIST           = 8;
  REG_FULL_RESOURCE_DESCRIPTOR = 9;
  REG_RESOURCE_REQUIREMENTS_LIST = 10;

{ END Translated from WINNT.H }

type
  WPARAM = TIntPtr;
  LPARAM = TIntPtr;
  LRESULT = TIntPtr;

function MakeWord(a, b: Byte): Word;
function MakeLong(a, b: Word): Longint;

type
  LOWORD = Word;

function HiWord(l: DWORD): Word;

type
  LOBYTE = Byte;

function HiByte(W: Word): Byte;

type
  HWND = THandle;
  HHOOK = THandle;

  ATOM = Word;
  TAtom = ATOM;

  FARPROC = Pointer;
  TFarProc = FARPROC;
  HGLOBAL = THandle;
  HLOCAL = THandle;
  HGDIOBJ = THandle;
  HACCEL = THandle;
  HBITMAP = THandle;
  HBRUSH = THandle;
  HCOLORSPACE = THandle;
  HDC = THandle;
  HGLRC = THandle;
  HDESK = THandle;
  HENHMETAFILE = THandle;
  HFONT = THandle;
  HICON = THandle;
  HMENU = THandle;
  HMETAFILE = THandle;
  HINST = THandle;
  HMODULE = HINST;              { HMODULEs can be used in place of HINSTs }
  HPALETTE = THandle;
  HPEN = THandle;
  HRGN = THandle;
  HRSRC = THandle;
  HSTR = THandle;
  HTASK = THandle;
  HWINSTA = THandle;
  HKL = THandle;

  HFILE = THandle;
  HCURSOR = HICON;              { HICONs & HCURSORs are polymorphic }

  COLORREF = DWORD;
  TColorRef = DWORD;

const
  HFILE_ERROR = HFILE(-1);

type
  PPoint = ^TPoint;
  TPoint = record
    x: Longint;
    y: Longint;
  end;
  tagPOINT = TPoint;

  PRect = ^TRect;

  TRect = record
    case Integer of
      0: (Left, Top, Right, Bottom: Integer);
      1: (TopLeft, BottomRight: TPoint);
  end;

  _POINTL = packed record      { ptl }
    x: Longint;
    y: Longint;
  end;
  PPointL = ^TPointL;
  TPointL = _POINTL;

  PSize = ^TSize;
  tagSIZE = record
    cx: Longint;
    cy: Longint;
  end;
  TSize = tagSIZE;
  SIZE = tagSIZE;

  PSmallPoint = ^TSmallPoint;
  TSmallPoint = packed record
    x: SHORT;
    y: SHORT;
  end;

{ Translated from WINBASE.H }

{ Compatiblity functions and procedures }

function DefineHandleTable(Offset: Word): Bool;
procedure LimitEmsPages(Kbytes: Longint);
function SetSwapAreaSize(Size: Word): Longint;
procedure LockSegment(Segment: THandle);
procedure UnlockSegment(Segment: THandle);
function GetCurrentTime: Longint;
function Yield: Bool;

const
  INVALID_HANDLE_VALUE = THandle(-1);
  INVALID_FILE_SIZE = DWORD($FFFFFFFF);

  FILE_BEGIN = 0;
  FILE_CURRENT = 1;
  FILE_END = 2;

  TIME_ZONE_ID_INVALID = DWORD($FFFFFFFF);
  TIME_ZONE_ID_UNKNOWN  = 0;
  TIME_ZONE_ID_STANDARD = 1;
  TIME_ZONE_ID_DAYLIGHT = 2;


  WAIT_FAILED  = DWORD($FFFFFFFF);
  WAIT_OBJECT_0 = ((STATUS_WAIT_0 ) + 0 );

  WAIT_ABANDONED = ((STATUS_ABANDONED_WAIT_0 ) + 0 );
  WAIT_ABANDONED_0 = ((STATUS_ABANDONED_WAIT_0 ) + 0 );

  WAIT_TIMEOUT = STATUS_TIMEOUT;
  WAIT_IO_COMPLETION = STATUS_USER_APC;
  STILL_ACTIVE = STATUS_PENDING;
  EXCEPTION_ACCESS_VIOLATION = STATUS_ACCESS_VIOLATION;
  EXCEPTION_DATATYPE_MISALIGNMENT = STATUS_DATATYPE_MISALIGNMENT;
  EXCEPTION_BREAKPOINT = STATUS_BREAKPOINT;
  EXCEPTION_SINGLE_STEP = STATUS_SINGLE_STEP;
  EXCEPTION_ARRAY_BOUNDS_EXCEEDED = STATUS_ARRAY_BOUNDS_EXCEEDED;
  EXCEPTION_FLT_DENORMAL_OPERAND = STATUS_FLOAT_DENORMAL_OPERAND;
  EXCEPTION_FLT_DIVIDE_BY_ZERO = STATUS_FLOAT_DIVIDE_BY_ZERO;
  EXCEPTION_FLT_INEXACT_RESULT = STATUS_FLOAT_INEXACT_RESULT;
  EXCEPTION_FLT_INVALID_OPERATION = STATUS_FLOAT_INVALID_OPERATION;
  EXCEPTION_FLT_OVERFLOW = STATUS_FLOAT_OVERFLOW;
  EXCEPTION_FLT_STACK_CHECK = STATUS_FLOAT_STACK_CHECK;
  EXCEPTION_FLT_UNDERFLOW = STATUS_FLOAT_UNDERFLOW;
  EXCEPTION_INT_DIVIDE_BY_ZERO = STATUS_INTEGER_DIVIDE_BY_ZERO;
  EXCEPTION_INT_OVERFLOW = STATUS_INTEGER_OVERFLOW;
  EXCEPTION_PRIV_INSTRUCTION = STATUS_PRIVILEGED_INSTRUCTION;
  EXCEPTION_IN_PAGE_ERROR = STATUS_IN_PAGE_ERROR;
  EXCEPTION_ILLEGAL_INSTRUCTION = STATUS_ILLEGAL_INSTRUCTION;
  EXCEPTION_NONCONTINUABLE_EXCEPTION = STATUS_NONCONTINUABLE_EXCEPTION;
  EXCEPTION_STACK_OVERFLOW = STATUS_STACK_OVERFLOW;
  EXCEPTION_INVALID_DISPOSITION = STATUS_INVALID_DISPOSITION;
  EXCEPTION_GUARD_PAGE = STATUS_GUARD_PAGE_VIOLATION;
  EXCEPTION_INVALID_HANDLE = STATUS_INVALID_HANDLE;
  CONTROL_C_EXIT = STATUS_CONTROL_C_EXIT;

procedure MoveMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
procedure FillMemory(Destination: Pointer; Length: DWORD; Fill: Byte);
procedure ZeroMemory(Destination: Pointer; Length: DWORD);

const
  { File creation flags must start at the high end since they }
  { are combined with the attributes}

  FILE_FLAG_WRITE_THROUGH = DWORD($80000000);
  FILE_FLAG_OVERLAPPED = $40000000;
  FILE_FLAG_NO_BUFFERING = $20000000;
  FILE_FLAG_RANDOM_ACCESS = $10000000;
  FILE_FLAG_SEQUENTIAL_SCAN = $8000000;
  FILE_FLAG_DELETE_ON_CLOSE = $4000000;
  FILE_FLAG_BACKUP_SEMANTICS = $2000000;
  FILE_FLAG_POSIX_SEMANTICS = $1000000;

  CREATE_NEW = 1;
  CREATE_ALWAYS = 2;
  OPEN_EXISTING = 3;
  OPEN_ALWAYS = 4;
  TRUNCATE_EXISTING = 5;


{ Define possible return codes from the CopyFileEx callback routine }

  PROGRESS_CONTINUE = 0;
  PROGRESS_CANCEL = 1;
  PROGRESS_STOP = 2;
  PROGRESS_QUIET = 3;


{ Define CopyFileEx callback routine state change values }

  CALLBACK_CHUNK_FINISHED = $00000000;
  CALLBACK_STREAM_SWITCH = $00000001;


{ Define CopyFileEx option flags }

  COPY_FILE_FAIL_IF_EXISTS = $00000001;
  COPY_FILE_RESTARTABLE = $00000002;


{ Define the NamedPipe definitions}

  { Define the dwOpenMode values for CreateNamedPipe }

  PIPE_ACCESS_INBOUND = 1;
  PIPE_ACCESS_OUTBOUND = 2;
  PIPE_ACCESS_DUPLEX = 3;

  { Define the Named Pipe End flags for GetNamedPipeInfo }

  PIPE_CLIENT_END = 0;
  PIPE_SERVER_END = 1;

  { Define the dwPipeMode values for CreateNamedPipe }

  PIPE_WAIT = 0;
  PIPE_NOWAIT = 1;
  PIPE_READMODE_BYTE = 0;
  PIPE_READMODE_MESSAGE = 2;
  PIPE_TYPE_BYTE = 0;
  PIPE_TYPE_MESSAGE = 4;

  { Define the well known values for CreateNamedPipe nMaxInstances }

  PIPE_UNLIMITED_INSTANCES = 255;

  { Define the Security Quality of Service bits to be passed into CreateFile }

  SECURITY_ANONYMOUS = (Ord(SecurityAnonymous) shl 16);
  SECURITY_IDENTIFICATION = (Ord(SecurityIdentification) shl 16);
  SECURITY_IMPERSONATION = (Ord(SecurityImpersonation) shl 16);
  SECURITY_DELEGATION = (Ord(SecurityDelegation) shl 16);

  SECURITY_CONTEXT_TRACKING = $40000;
  SECURITY_EFFECTIVE_ONLY = $80000;

  SECURITY_SQOS_PRESENT = $100000;
  SECURITY_VALID_SQOS_FLAGS = $1F0000;

{ File structures }

type
  POverlapped = ^TOverlapped;
  _OVERLAPPED = record
    Internal: DWORD;
    InternalHigh: DWORD;
    Offset: DWORD;
    OffsetHigh: DWORD;
    hEvent: THandle;
  end;
  TOverlapped = _OVERLAPPED;
  OVERLAPPED = _OVERLAPPED;

  PSecurityAttributes = ^TSecurityAttributes;
  _SECURITY_ATTRIBUTES = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;
  TSecurityAttributes = _SECURITY_ATTRIBUTES;
  SECURITY_ATTRIBUTES = _SECURITY_ATTRIBUTES;

  PProcessInformation = ^TProcessInformation;
  _PROCESS_INFORMATION = record
    hProcess: THandle;
    hThread: THandle;
    dwProcessId: DWORD;
    dwThreadId: DWORD;
  end;
  TProcessInformation = _PROCESS_INFORMATION;
  PROCESS_INFORMATION = _PROCESS_INFORMATION;

  { File System time stamps are represented with the following structure: }
  PFileTime = ^TFileTime;
  _FILETIME = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;
  TFileTime = _FILETIME;
  FILETIME = _FILETIME;

  { System time is represented with the following structure: }
  PSystemTime = ^TSystemTime;
  _SYSTEMTIME = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  TSystemTime = _SYSTEMTIME;
  SYSTEMTIME = _SYSTEMTIME;





  TFNThreadStartRoutine = TFarProc;
  TFNFiberStartRoutine = TFarProc;


const
  MUTEX_MODIFY_STATE = MUTANT_QUERY_STATE;
  MUTEX_ALL_ACCESS = MUTANT_ALL_ACCESS;

  { Serial provider type. }

  SP_SERIALCOMM = $00000001;

  { Provider SubTypes }

  PST_UNSPECIFIED = $00000000;
  PST_RS232 = $00000001;
  PST_PARALLELPORT = $00000002;
  PST_RS422 = $00000003;
  PST_RS423 = $00000004;
  PST_RS449 = $00000005;
  PST_MODEM = $00000006;
  PST_FAX = $00000021;
  PST_SCANNER = $00000022;
  PST_NETWORK_BRIDGE = $00000100;
  PST_LAT = $00000101;
  PST_TCPIP_TELNET = $00000102;
  PST_X25 = $00000103;

  { Provider capabilities flags. }

  PCF_DTRDSR = $0001;
  PCF_RTSCTS = $0002;
  PCF_RLSD = $0004;
  PCF_PARITY_CHECK = $0008;
  PCF_XONXOFF = $0010;
  PCF_SETXCHAR = $0020;
  PCF_TOTALTIMEOUTS = $0040;
  PCF_INTTIMEOUTS = $0080;
  PCF_SPECIALCHARS = $0100;
  PCF_16BITMODE = $0200;

  { Comm provider settable parameters. }

  SP_PARITY = $0001;
  SP_BAUD = $0002;
  SP_DATABITS = $0004;
  SP_STOPBITS = $0008;
  SP_HANDSHAKING = $0010;
  SP_PARITY_CHECK = $0020;
  SP_RLSD = $0040;

  { Settable baud rates in the provider. }

  BAUD_075 = $00000001;
  BAUD_110 = $00000002;
  BAUD_134_5 = $00000004;
  BAUD_150 = $00000008;
  BAUD_300 = $00000010;
  BAUD_600 = $00000020;
  BAUD_1200 = $00000040;
  BAUD_1800 = $00000080;
  BAUD_2400 = $00000100;
  BAUD_4800 = $00000200;
  BAUD_7200 = $00000400;
  BAUD_9600 = $00000800;
  BAUD_14400 = $00001000;
  BAUD_19200 = $00002000;
  BAUD_38400 = $00004000;
  BAUD_56K = $00008000;
  BAUD_128K = $00010000;
  BAUD_115200 = $00020000;
  BAUD_57600 = $00040000;
  BAUD_USER = $10000000;

  { Settable Data Bits }

  DATABITS_5 = $0001;
  DATABITS_6 = $0002;
  DATABITS_7 = $0004;
  DATABITS_8 = $0008;
  DATABITS_16 = $0010;
  DATABITS_16X = $0020;

  { Settable Stop and Parity bits. }

  STOPBITS_10 = $0001;
  STOPBITS_15 = $0002;
  STOPBITS_20 = $0004;
  PARITY_NONE = $0100;
  PARITY_ODD = $0200;
  PARITY_EVEN = $0400;
  PARITY_MARK = $0800;
  PARITY_SPACE = $1000;

type
  PCommProp = ^TCommProp;
  _COMMPROP = record
    wPacketLength: Word;
    wPacketVersion: Word;
    dwServiceMask: DWORD;
    dwReserved1: DWORD;
    dwMaxTxQueue: DWORD;
    dwMaxRxQueue: DWORD;
    dwMaxBaud: DWORD;
    dwProvSubType: DWORD;
    dwProvCapabilities: DWORD;
    dwSettableParams: DWORD;
    dwSettableBaud: DWORD;
    wSettableData: Word;
    wSettableStopParity: Word;
    dwCurrentTxQueue: DWORD;
    dwCurrentRxQueue: DWORD;
    dwProvSpec1: DWORD;
    dwProvSpec2: DWORD;
    wcProvChar: array[0..0] of WCHAR;
  end;
  TCommProp = _COMMPROP;
  COMMPROP = _COMMPROP;

  { Set dwProvSpec1 to COMMPROP_INITIALIZED to indicate that wPacketLength
    is valid before a call to GetCommProperties(). }
const
  COMMPROP_INITIALIZED = DWORD($E73CF52E);

type
  TComStateFlag = (fCtlHold, fDsrHold, fRlsHold, fXoffHold, fXOffSent, fEof,
    fTxim);  // not in Windows Headers
  TComStateFlags = set of TComStateFlag;
  _COMSTAT = record
    Flags: TComStateFlags;
    Reserved: array[0..2] of Byte;
    cbInQue: DWORD;
    cbOutQue: DWORD;
  end;
  TComStat = _COMSTAT;
  COMSTAT = _COMSTAT;
  PComStat = ^TComStat;

const
  { DTR Control Flow Values. }
  DTR_CONTROL_DISABLE = 0;
  DTR_CONTROL_ENABLE = 1;
  DTR_CONTROL_HANDSHAKE = 2;

  { RTS Control Flow Values}
  RTS_CONTROL_DISABLE = 0;
  RTS_CONTROL_ENABLE = 1;
  RTS_CONTROL_HANDSHAKE = 2;
  RTS_CONTROL_TOGGLE = 3;

type
  _DCB = packed record
    DCBlength: DWORD;
    BaudRate: DWORD;
    Flags: Longint;
    wReserved: Word;
    XonLim: Word;
    XoffLim: Word;
    ByteSize: Byte;
    Parity: Byte;
    StopBits: Byte;
    XonChar: AnsiChar;
    XoffChar: AnsiChar;
    ErrorChar: AnsiChar;
    EofChar: AnsiChar;
    EvtChar: AnsiChar;
    wReserved1: Word;
  end;
  TDCB = _DCB;
  DCB = _DCB;
  PDCB = ^TDCB;

  PCommTimeouts = ^TCommTimeouts;
  _COMMTIMEOUTS = record
    ReadIntervalTimeout: DWORD;
    ReadTotalTimeoutMultiplier: DWORD;
    ReadTotalTimeoutConstant: DWORD;
    WriteTotalTimeoutMultiplier: DWORD;
    WriteTotalTimeoutConstant: DWORD;
  end;
  TCommTimeouts = _COMMTIMEOUTS;
  COMMTIMEOUTS = _COMMTIMEOUTS;

  PCommConfig = ^TCommConfig;
  _COMMCONFIG = record
    dwSize: DWORD;
    wVersion: Word;
    wReserved: Word;
    dcb: TDCB;
    dwProviderSubType: DWORD;
    dwProviderOffset: DWORD;
    dwProviderSize: DWORD;
    wcProviderData: array[0..0] of WCHAR;
  end;
  TCommConfig = _COMMCONFIG;
  COMMCONFIG = _COMMCONFIG;

  PSystemInfo = ^TSystemInfo;
  _SYSTEM_INFO = record
    case Integer of
      0: (
        dwOemId: DWORD);
      1: (
        wProcessorArchitecture: Word;
        wReserved: Word;
        dwPageSize: DWORD;
        lpMinimumApplicationAddress: Pointer;
        lpMaximumApplicationAddress: Pointer;
        dwActiveProcessorMask: DWORD;
        dwNumberOfProcessors: DWORD;
        dwProcessorType: DWORD;
        dwAllocationGranularity: DWORD;
        wProcessorLevel: Word;
        wProcessorRevision: Word);
  end;
  TSystemInfo = _SYSTEM_INFO;
  SYSTEM_INFO = _SYSTEM_INFO;

function FreeModule(var hLibModule: HINST): BOOL;
function MakeProcInstance(Proc: FARPROC; Instance: THandle): FARPROC;
procedure FreeProcInstance(Proc: FARPROC);


const
  { Global Memory Flags }

  GMEM_FIXED = 0;
  GMEM_MOVEABLE = 2;
  GMEM_NOCOMPACT = $10;
  GMEM_NODISCARD = $20;
  GMEM_ZEROINIT = $40;
  GMEM_MODIFY = $80;
  GMEM_DISCARDABLE = $100;
  GMEM_NOT_BANKED = $1000;
  GMEM_SHARE = $2000;
  GMEM_DDESHARE = $2000;
  GMEM_NOTIFY = $4000;
  GMEM_LOWER = GMEM_NOT_BANKED;
  GMEM_VALID_FLAGS = 32626;
  GMEM_INVALID_HANDLE = $8000;

  GHND = GMEM_MOVEABLE or GMEM_ZEROINIT;
  GPTR = GMEM_FIXED or GMEM_ZEROINIT;

function GlobalLRUNewest(h: THandle): THandle;
function GlobalLRUOldest(h: THandle): THandle;
function GlobalDiscard(h: THandle): THandle;

function GlobalAllocPtr(Flags: Integer; Bytes: Longint): Pointer;
function GlobalReAllocPtr(P: Pointer; Bytes: Longint; Flags: Integer): Pointer;
function GlobalFreePtr(P: Pointer): THandle;

const
  { Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE) }
  GMEM_DISCARDED = $4000;
  GMEM_LOCKCOUNT = 255;

type
  PMemoryStatus = ^TMemoryStatus;
  _MEMORYSTATUS = record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    dwTotalPhys: DWORD;
    dwAvailPhys: DWORD;
    dwTotalPageFile: DWORD;
    dwAvailPageFile: DWORD;
    dwTotalVirtual: DWORD;
    dwAvailVirtual: DWORD;
  end;
  TMemoryStatus = _MEMORYSTATUS;
  MEMORYSTATUS = _MEMORYSTATUS;

const
  { Local Memory Flags }

  LMEM_FIXED = 0;
  LMEM_MOVEABLE = 2;
  LMEM_NOCOMPACT = $10;
  LMEM_NODISCARD = $20;
  LMEM_ZEROINIT = $40;
  LMEM_MODIFY = $80;
  LMEM_DISCARDABLE = $F00;
  LMEM_VALID_FLAGS = $F72;
  LMEM_INVALID_HANDLE = $8000;

  LHND = LMEM_MOVEABLE or LMEM_ZEROINIT;
  LPTR = LMEM_FIXED or LMEM_ZEROINIT;

  NONZEROLPTR = LMEM_FIXED;


function LocalDiscard(h: THandle): THandle;

const
  { Flags returned by LocalFlags (in addition to LMEM_DISCARDABLE) }

  LMEM_DISCARDED = $4000;
  LMEM_LOCKCOUNT = 255;

  { dwCreationFlag values }

{ dwCreationFlag values }


  DEBUG_PROCESS                   = $00000001;
  DEBUG_ONLY_THIS_PROCESS         = $00000002;

  CREATE_SUSPENDED                = $00000004;

  DETACHED_PROCESS                = $00000008;

  CREATE_NEW_CONSOLE              = $00000010;

  NORMAL_PRIORITY_CLASS           = $00000020;
  IDLE_PRIORITY_CLASS             = $00000040;
  HIGH_PRIORITY_CLASS             = $00000080;
  REALTIME_PRIORITY_CLASS         = $00000100;

  CREATE_NEW_PROCESS_GROUP        = $00000200;
  CREATE_UNICODE_ENVIRONMENT      = $00000400;

  CREATE_SEPARATE_WOW_VDM         = $00000800;
  CREATE_SHARED_WOW_VDM           = $00001000;
  CREATE_FORCEDOS                 = $00002000;

  CREATE_DEFAULT_ERROR_MODE       = $04000000;
  CREATE_NO_WINDOW                = $08000000;

  PROFILE_USER                    = $10000000;
  PROFILE_KERNEL                  = $20000000;
  PROFILE_SERVER                  = $40000000;

  THREAD_PRIORITY_LOWEST              = THREAD_BASE_PRIORITY_MIN;
  THREAD_PRIORITY_BELOW_NORMAL        = THREAD_PRIORITY_LOWEST + 1;
  THREAD_PRIORITY_NORMAL              = 0;
  THREAD_PRIORITY_HIGHEST             = THREAD_BASE_PRIORITY_MAX;
  THREAD_PRIORITY_ABOVE_NORMAL        = THREAD_PRIORITY_HIGHEST - 1;
  THREAD_PRIORITY_ERROR_RETURN        = MAXLONG;

  THREAD_PRIORITY_TIME_CRITICAL       = THREAD_BASE_PRIORITY_LOWRT;
  THREAD_PRIORITY_IDLE                = THREAD_BASE_PRIORITY_IDLE;

{ Debug APIs }

  DBG_CONTINUE               = $00010002;
  DBG_TERMINATE_THREAD       = $40010003;
  DBG_TERMINATE_PROCESS      = $40010004;
  DBG_CONTROL_C              = $40010005;
  DBG_CONTROL_BREAK          = $40010008;
  DBG_EXCEPTION_NOT_HANDLED  = $80010001;

  EXCEPTION_DEBUG_EVENT = 1;
  CREATE_THREAD_DEBUG_EVENT = 2;
  CREATE_PROCESS_DEBUG_EVENT = 3;
  EXIT_THREAD_DEBUG_EVENT = 4;
  EXIT_PROCESS_DEBUG_EVENT = 5;
  LOAD_DLL_DEBUG_EVENT = 6;
  UNLOAD_DLL_DEBUG_EVENT = 7;
  OUTPUT_DEBUG_STRING_EVENT = 8;
  RIP_EVENT = 9;

type
  PExceptionDebugInfo = ^TExceptionDebugInfo;
  _EXCEPTION_DEBUG_INFO = record
    ExceptionRecord: TExceptionRecord;
    dwFirstChance: DWORD;
  end;
  TExceptionDebugInfo = _EXCEPTION_DEBUG_INFO;
  EXCEPTION_DEBUG_INFO = _EXCEPTION_DEBUG_INFO;

  PCreateThreadDebugInfo = ^TCreateThreadDebugInfo;
  _CREATE_THREAD_DEBUG_INFO = record
    hThread: THandle;
    lpThreadLocalBase: Pointer;
    lpStartAddress: TFNThreadStartRoutine;
  end;
  TCreateThreadDebugInfo = _CREATE_THREAD_DEBUG_INFO;
  CREATE_THREAD_DEBUG_INFO = _CREATE_THREAD_DEBUG_INFO;

  PCreateProcessDebugInfo = ^TCreateProcessDebugInfo;
  _CREATE_PROCESS_DEBUG_INFO = record
    hFile: THandle;
    hProcess: THandle;
    hThread: THandle;
    lpBaseOfImage: Pointer;
    dwDebugInfoFileOffset: DWORD;
    nDebugInfoSize: DWORD;
    lpThreadLocalBase: Pointer;
    lpStartAddress: TFNThreadStartRoutine;
    lpImageName: Pointer;
    fUnicode: Word;
  end;
  TCreateProcessDebugInfo = _CREATE_PROCESS_DEBUG_INFO;
  CREATE_PROCESS_DEBUG_INFO = _CREATE_PROCESS_DEBUG_INFO;

  PExitThreadDebugInfo = ^TExitThreadDebugInfo;
  _EXIT_THREAD_DEBUG_INFO = record
    dwExitCode: DWORD;
  end;
  TExitThreadDebugInfo = _EXIT_THREAD_DEBUG_INFO;
  EXIT_THREAD_DEBUG_INFO = _EXIT_THREAD_DEBUG_INFO;

  PExitProcessDebugInfo = ^TExitProcessDebugInfo;
  _EXIT_PROCESS_DEBUG_INFO = record
    dwExitCode: DWORD;
  end;
  TExitProcessDebugInfo = _EXIT_PROCESS_DEBUG_INFO;
  EXIT_PROCESS_DEBUG_INFO = _EXIT_PROCESS_DEBUG_INFO;

  PLoadDLLDebugInfo = ^TLoadDLLDebugInfo;
  _LOAD_DLL_DEBUG_INFO = record
    hFile: THandle;
    lpBaseOfDll: Pointer;
    dwDebugInfoFileOffset: DWORD;
    nDebugInfoSize: DWORD;
    lpImageName: Pointer;
    fUnicode: Word;
  end;
  TLoadDLLDebugInfo = _LOAD_DLL_DEBUG_INFO;
  LOAD_DLL_DEBUG_INFO = _LOAD_DLL_DEBUG_INFO;

  PUnloadDLLDebugInfo = ^TUnloadDLLDebugInfo;
  _UNLOAD_DLL_DEBUG_INFO = record
    lpBaseOfDll: Pointer;
  end;
  TUnloadDLLDebugInfo = _UNLOAD_DLL_DEBUG_INFO;
  UNLOAD_DLL_DEBUG_INFO = _UNLOAD_DLL_DEBUG_INFO;

  POutputDebugStringInfo = ^TOutputDebugStringInfo;
  _OUTPUT_DEBUG_STRING_INFO = record
    lpDebugStringData: LPSTR;
    fUnicode: Word;
    nDebugStringLength: Word;
  end;
  TOutputDebugStringInfo = _OUTPUT_DEBUG_STRING_INFO;
  OUTPUT_DEBUG_STRING_INFO = _OUTPUT_DEBUG_STRING_INFO;

  PRIPInfo = ^TRIPInfo;
  _RIP_INFO = record
    dwError: DWORD;
    dwType: DWORD;
  end;
  TRIPInfo = _RIP_INFO;
  RIP_INFO = _RIP_INFO;

  PDebugEvent = ^TDebugEvent;
  _DEBUG_EVENT = record
    dwDebugEventCode: DWORD;
    dwProcessId: DWORD;
    dwThreadId: DWORD;
    case Integer of
      0: (Exception: TExceptionDebugInfo);
      1: (CreateThread: TCreateThreadDebugInfo);
      2: (CreateProcessInfo: TCreateProcessDebugInfo);
      3: (ExitThread: TExitThreadDebugInfo);
      4: (ExitProcess: TExitThreadDebugInfo);
      5: (LoadDll: TLoadDLLDebugInfo);
      6: (UnloadDll: TUnloadDLLDebugInfo);
      7: (DebugString: TOutputDebugStringInfo);
      8: (RipInfo: TRIPInfo);
  end;
  TDebugEvent = _DEBUG_EVENT;
  DEBUG_EVENT = _DEBUG_EVENT;

const
  DRIVE_UNKNOWN = 0;
  DRIVE_NO_ROOT_DIR = 1;
  DRIVE_REMOVABLE = 2;
  DRIVE_FIXED = 3;
  DRIVE_REMOTE = 4;
  DRIVE_CDROM = 5;
  DRIVE_RAMDISK = 6;

function GetFreeSpace(w: Word): DWORD;

const
  FILE_TYPE_UNKNOWN = 0;
  FILE_TYPE_DISK = 1;
  FILE_TYPE_CHAR = 2;
  FILE_TYPE_PIPE = 3;
  FILE_TYPE_REMOTE = $8000;

  STD_INPUT_HANDLE = DWORD(-10);
  STD_OUTPUT_HANDLE = DWORD(-11);
  STD_ERROR_HANDLE = DWORD(-12);

  NOPARITY = 0;
  ODDPARITY = 1;
  EVENPARITY = 2;
  MARKPARITY = 3;
  SPACEPARITY = 4;

  ONESTOPBIT = 0;
  ONE5STOPBITS = 1;
  TWOSTOPBITS = 2;

  IGNORE = 0;               { Ignore signal }
  INFINITE = DWORD($FFFFFFFF);     { Infinite timeout }

  { Baud rates at which the communication device operates }

  CBR_110 = 110;
  CBR_300 = 300;
  CBR_600 = 600;
  CBR_1200 = 1200;
  CBR_2400 = 2400;
  CBR_4800 = 4800;
  CBR_9600 = 9600;
  CBR_14400 = 14400;
  CBR_19200 = 19200;
  CBR_38400 = 38400;
  CBR_56000 = 56000;
  CBR_57600 = 57600;
  CBR_115200 = $1C200;
  CBR_128000 = $1F400;
  CBR_256000 = $3E800;

  { Error Flags }

  CE_RXOVER = 1;        { Receive Queue overflow }
  CE_OVERRUN = 2;       { Receive Overrun Error }
  CE_RXPARITY = 4;      { Receive Parity Error }
  CE_FRAME = 8;         { Receive Framing error }
  CE_BREAK = $10;       { Break Detected }
  CE_TXFULL = $100;     { TX Queue is full }
  CE_PTO = $200;        { LPTx Timeout }
  CE_IOE = $400;        { LPTx I/O Error }
  CE_DNS = $800;        { LPTx Device not selected }
  CE_OOP = $1000;       { LPTx Out-Of-Paper }
  CE_MODE = $8000;      { Requested mode unsupported }

  IE_BADID = LongWord(-1);        { Invalid or unsupported id }
  IE_OPEN = LongWord(-2);         { Device Already Open }
  IE_NOPEN = LongWord(-3);        { Device Not Open }
  IE_MEMORY = LongWord(-4);       { Unable to allocate queues }
  IE_DEFAULT = LongWord(-5);      { Error in default parameters }
  IE_HARDWARE = LongWord(-10);    { Hardware Not Present }
  IE_BYTESIZE = LongWord(-11);    { Illegal Byte Size }
  IE_BAUDRATE = LongWord(-12);    { Unsupported BaudRate }

  { Events }

  EV_RXCHAR = 1;        { Any Character received }
  EV_RXFLAG = 2;        { Received certain character }
  EV_TXEMPTY = 4;       { Transmitt Queue Empty }
  EV_CTS = 8;           { CTS changed state }
  EV_DSR = $10;         { DSR changed state }
  EV_RLSD = $20;        { RLSD changed state }
  EV_BREAK = $40;       { BREAK received }
  EV_ERR = $80;         { Line status error occurred }
  EV_RING = $100;       { Ring signal detected }
  EV_PERR = $200;       { Printer error occured }
  EV_RX80FULL = $400;   { Receive buffer is 80 percent full }
  EV_EVENT1 = $800;     { Provider specific event 1 }
  EV_EVENT2 = $1000;    { Provider specific event 2 }

  { Escape functions }

  SETXOFF = 1;    { Simulate XOFF received }
  SETXON = 2;     { Simulate XON received }
  SETRTS = 3;     { Set RTS high }
  CLRRTS = 4;     { Set RTS low }
  SETDTR = 5;     { Set DTR high }
  CLRDTR = 6;     { Set DTR low }
  RESETDEV = 7;   { Reset device if possible }
  SETBREAK = 8;   { Set the device break line. }
  CLRBREAK = 9;   { Clear the device break line. }

  { PURGE function flags. }

  PURGE_TXABORT = 1;     { Kill the pending/current writes to the comm port. }
  PURGE_RXABORT = 2;     { Kill the pending/current reads to the comm port. }
  PURGE_TXCLEAR = 4;     { Kill the transmit queue if there. }
  PURGE_RXCLEAR = 8;     { Kill the typeahead buffer if there. }

  LPTx = $80;     { Set if ID is for LPT device }

  { Modem Status Flags }

  MS_CTS_ON = DWORD($0010);
  MS_DSR_ON = DWORD($0020);
  MS_RING_ON = DWORD($0040);
  MS_RLSD_ON = DWORD($0080);

  { WaitSoundState() Constants }

  S_QUEUEEMPTY = 0;
  S_THRESHOLD = 1;
  S_ALLTHRESHOLD = 2;

  { Accent Modes }

  S_NORMAL = 0;
  S_LEGATO = 1;
  S_STACCATO = 2;

  { SetSoundNoise() Sources }

  S_PERIOD512 = 0;     { Freq = N/512 high pitch, less coarse hiss }
  S_PERIOD1024 = 1;    { Freq = N/1024 }
  S_PERIOD2048 = 2;    { Freq = N/2048 low pitch, more coarse hiss }
  S_PERIODVOICE = 3;   { Source is frequency from voice channel (3) }
  S_WHITE512 = 4;      { Freq = N/512 high pitch, less coarse hiss }
  S_WHITE1024 = 5;     { Freq = N/1024 }
  S_WHITE2048 = 6;     { Freq = N/2048 low pitch, more coarse hiss }
  S_WHITEVOICE = 7;    { Source is frequency from voice channel (3) }

  S_SERDVNA = LongWord(-1);     { Device not available  }
  S_SEROFM = LongWord(-2);      { Out of memory }
  S_SERMACT = LongWord(-3);     { Music active }
  S_SERQFUL = LongWord(-4);     { Queue full }
  S_SERBDNT = LongWord(-5);     { Invalid note }
  S_SERDLN = LongWord(-6);      { Invalid note length }
  S_SERDCC = LongWord(-7);      { Invalid note count }
  S_SERDTP = LongWord(-8);      { Invalid tempo }
  S_SERDVL = LongWord(-9);      { Invalid volume }
  S_SERDMD = LongWord(-10);     { Invalid mode }
  S_SERDSH = LongWord(-11);     { Invalid shape }
  S_SERDPT = LongWord(-12);     { Invalid pitch }
  S_SERDFQ = LongWord(-13);     { Invalid frequency }
  S_SERDDR = LongWord(-14);     { Invalid duration }
  S_SERDSR = LongWord(-15);     { Invalid source }
  S_SERDST = LongWord(-16);     { Invalid state }

  NMPWAIT_WAIT_FOREVER = DWORD($FFFFFFFF);
  NMPWAIT_NOWAIT = 1;
  NMPWAIT_USE_DEFAULT_WAIT = 0;

  FS_CASE_IS_PRESERVED = FILE_CASE_PRESERVED_NAMES;
  FS_CASE_SENSITIVE = FILE_CASE_SENSITIVE_SEARCH;
  FS_UNICODE_STORED_ON_DISK = FILE_UNICODE_ON_DISK;
  FS_PERSISTENT_ACLS = FILE_PERSISTENT_ACLS;
  FS_VOL_IS_COMPRESSED = FILE_VOLUME_IS_COMPRESSED;
  FS_FILE_COMPRESSION = FILE_FILE_COMPRESSION;

  FILE_MAP_COPY = SECTION_QUERY;
  FILE_MAP_WRITE = SECTION_MAP_WRITE;
  FILE_MAP_READ = SECTION_MAP_READ;
  FILE_MAP_ALL_ACCESS = SECTION_ALL_ACCESS;

  OF_READ = 0;
  OF_WRITE = 1;
  OF_READWRITE = 2;
  OF_SHARE_COMPAT = 0;
  OF_SHARE_EXCLUSIVE = $10;
  OF_SHARE_DENY_WRITE = $20;
  OF_SHARE_DENY_READ = 48;
  OF_SHARE_DENY_NONE = $40;
  OF_PARSE = $100;
  OF_DELETE = $200;
  OF_VERIFY = $400;
  OF_CANCEL = $800;
  OF_CREATE = $1000;
  OF_PROMPT = $2000;
  OF_EXIST = $4000;
  OF_REOPEN = $8000;

  OFS_MAXPATHNAME = 128;
type
  POFStruct = ^TOFStruct;
  _OFSTRUCT = record
    cBytes: Byte;
    fFixedDisk: Byte;
    nErrCode: Word;
    Reserved1: Word;
    Reserved2: Word;
    szPathName: array[0..OFS_MAXPATHNAME-1] of AnsiChar;
  end;
  TOFStruct = _OFSTRUCT;
  OFSTRUCT = _OFSTRUCT;

{$ifdef b64}
{$ifdef bFreePascal}
{$else}
function InterlockedIncrement(var Addend: Integer): Integer;
function InterlockedDecrement(var Addend: Integer): Integer;
{$endif bFreePascal}
{$else}
function InterlockedIncrement(var Addend: Integer): Integer; stdcall;
function InterlockedDecrement(var Addend: Integer): Integer; stdcall;
function InterlockedExchange(var Target: Integer; Value: Integer): Integer; stdcall;
function InterlockedCompareExchange(var Destination: Pointer; Exchange: Pointer; Comperand: Pointer): Pointer stdcall;
function InterlockedExchangeAdd(Addend: PLongint; Value: Longint): Longint stdcall;
{$endif b64}

function FreeResource(hResData: HGLOBAL): BOOL; stdcall;
function LockResource(hResData: HGLOBAL): Pointer; stdcall;
function UnlockResource(hResData: THandle): BOOL;

const
  MAXINTATOM = $C000;
  INVALID_ATOM = 0;

type
  MakeIntAtomA = PAnsiChar;
  MakeIntAtomW = PWideChar;
  MakeIntAtom = {$ifdef bUnicode}MakeIntAtomW{$else}MakeIntAtomA{$endif bUnicode};

function FreeLibrary(hLibModule: HMODULE): BOOL; stdcall;
procedure FreeLibraryAndExitThread(hLibModule: HMODULE; dwExitCode: DWORD); stdcall;
function DisableThreadLibraryCalls(hLibModule: HMODULE): BOOL; stdcall;
function GetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;
function GetVersion: DWORD; stdcall;
function GlobalAlloc(uFlags: UINT; dwBytes: DWORD): HGLOBAL; stdcall;
function GlobalReAlloc(hMem: HGLOBAL; dwBytes: DWORD; uFlags: UINT): HGLOBAL; stdcall;
function GlobalSize(hMem: HGLOBAL): DWORD; stdcall;
function GlobalFlags(hMem: HGLOBAL): UINT; stdcall;
function GlobalLock(hMem: HGLOBAL): Pointer; stdcall;
function GlobalHandle(Mem: Pointer): HGLOBAL; stdcall;
function GlobalUnlock(hMem: HGLOBAL): BOOL; stdcall;
function GlobalFree(hMem: HGLOBAL): HGLOBAL; stdcall;
function GlobalCompact(dwMinFree: DWORD): UINT; stdcall;
procedure GlobalFix(hMem: HGLOBAL); stdcall;
procedure GlobalUnfix(hMem: HGLOBAL); stdcall;
function GlobalWire(hMem: HGLOBAL): Pointer; stdcall;
function GlobalUnWire(hMem: HGLOBAL): BOOL; stdcall;
procedure GlobalMemoryStatus(var lpBuffer: TMemoryStatus); stdcall;
function LocalAlloc(uFlags, uBytes: UINT): HLOCAL; stdcall;
function LocalReAlloc(hMem: HLOCAL; uBytes, uFlags: UINT): HLOCAL; stdcall;
function LocalLock(hMem: HLOCAL): Pointer; stdcall;
function LocalUnlock(hMem: HLOCAL): BOOL; stdcall;
function LocalSize(hMem: HLOCAL): UINT; stdcall;
function LocalFlags(hMem: HLOCAL): UINT; stdcall;
function LocalFree(hMem: HLOCAL): HLOCAL; stdcall;
function LocalShrink(hMem: HLOCAL; cbNewSize: UINT): UINT; stdcall;
function LocalCompact(uMinFree: UINT): UINT; stdcall;
function FlushInstructionCache(hProcess: THandle; const lpBaseAddress: Pointer; dwSize: DWORD): BOOL; stdcall;
function VirtualAlloc(lpvAddress: Pointer; dwSize, flAllocationType, flProtect: DWORD): Pointer; stdcall;
function VirtualFree(lpAddress: Pointer; dwSize, dwFreeType: DWORD): BOOL; stdcall;
function VirtualProtect(lpAddress: Pointer; dwSize, flNewProtect: DWORD;
  lpflOldProtect: Pointer): BOOL; stdcall; {$ifdef bDelphi5} overload;
function VirtualProtect(lpAddress: Pointer; dwSize, flNewProtect: DWORD;
  var OldProtect: DWORD): BOOL; stdcall; overload; {$endif bDelphi5}
function VirtualQuery(lpAddress: Pointer;
  var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;
function VirtualAllocEx(hProcess: THandle; lpAddress: Pointer;
  dwSize, flAllocationType: DWORD; flProtect: DWORD): Pointer; stdcall;
function VirtualFreeEx(hProcess: THandle; lpAddress: Pointer;
        dwSize, dwFreeType: DWORD): Pointer; stdcall;
function VirtualProtectEx(hProcess: THandle; lpAddress: Pointer;
  dwSize, flNewProtect: DWORD; lpflOldProtect: Pointer): BOOL; stdcall; {$ifdef bDelphi5} overload;
function VirtualProtectEx(hProcess: THandle; lpAddress: Pointer;
  dwSize, flNewProtect: DWORD; var OldProtect: DWORD): BOOL; stdcall; overload; {$endif bDelphi5}
function VirtualQueryEx(hProcess: THandle; lpAddress: Pointer;
  var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;
function HeapCreate(flOptions, dwInitialSize, dwMaximumSize: DWORD): THandle; stdcall;
function HeapDestroy(hHeap: THandle): BOOL; stdcall;
function HeapAlloc(hHeap: THandle; dwFlags, dwBytes: DWORD): Pointer; stdcall;
function HeapReAlloc(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer; dwBytes: DWORD): Pointer; stdcall;
function HeapFree(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): BOOL; stdcall;
function HeapSize(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): DWORD; stdcall;
function HeapValidate(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): BOOL; stdcall;
function HeapCompact(hHeap: THandle; dwFlags: DWORD): UINT; stdcall;
function GetProcessHeap: THandle; stdcall;
function GetProcessHeaps(NumberOfHeaps: DWORD; var ProcessHeaps: THandle): DWORD; stdcall;

type
  PProcessHeapEntry = ^TProcessHeapEntry;
  _PROCESS_HEAP_ENTRY = record
    lpData: Pointer;
    cbData: DWORD;
    cbOverhead: Byte;
    iRegionIndex: Byte;
    wFlags: Word;
    case Integer of
      0: (
        hMem: THandle);
      1: (
        dwCommittedSize: DWORD;
        dwUnCommittedSize: DWORD;
        lpFirstBlock: Pointer;
        lpLastBlock: Pointer);
  end;
  TProcessHeapEntry = _PROCESS_HEAP_ENTRY;
  PROCESS_HEAP_ENTRY = _PROCESS_HEAP_ENTRY;

const
  PROCESS_HEAP_REGION = 1;
  PROCESS_HEAP_UNCOMMITTED_RANGE = 2;
  PROCESS_HEAP_ENTRY_BUSY = 4;
  PROCESS_HEAP_ENTRY_MOVEABLE = $10;
  PROCESS_HEAP_ENTRY_DDESHARE = $20;

function HeapLock(hHeap: THandle): BOOL; stdcall;
function HeapUnlock(hHeap: THandle): BOOL; stdcall;
function HeapWalk(hHeap: THandle; var lpEntry: TProcessHeapEntry): BOOL; stdcall;


{ GetBinaryType return values.}

const
  SCS_32BIT_BINARY = 0;
  SCS_DOS_BINARY = 1;
  SCS_WOW_BINARY = 2;
  SCS_PIF_BINARY = 3;
  SCS_POSIX_BINARY = 4;
  SCS_OS216_BINARY = 5;

function GetBinaryTypeA(lpApplicationName: PAnsiChar; var lpBinaryType: DWORD): BOOL; stdcall;
function GetBinaryTypeW(lpApplicationName: PWideChar; var lpBinaryType: DWORD): BOOL; stdcall;
function GetBinaryType(lpApplicationName: PTChar; var lpBinaryType: DWORD): BOOL; stdcall;
function GetShortPathNameA(lpszLongPath: PAnsiChar; lpszShortPath: PAnsiChar;
  cchBuffer: DWORD): DWORD; stdcall;
function GetShortPathNameW(lpszLongPath: PWideChar; lpszShortPath: PWideChar;
  cchBuffer: DWORD): DWORD; stdcall;
function GetShortPathName(lpszLongPath: PTChar; lpszShortPath: PTChar;
  cchBuffer: DWORD): DWORD; stdcall;
function GetProcessAffinityMask(hProcess: THandle;
  var lpProcessAffinityMask, lpSystemAffinityMask: DWORD): BOOL; stdcall;
function SetProcessAffinityMask(hProcess: THandle;
  dwProcessAffinityMask: DWORD): BOOL; stdcall;
function GetProcessTimes(hProcess: THandle;
  var lpCreationTime, lpExitTime, lpKernelTime, lpUserTime: TFileTime): BOOL; stdcall;
function GetProcessWorkingSetSize(hProcess: THandle;
  var lpMinimumWorkingSetSize, lpMaximumWorkingSetSize: DWORD): BOOL; stdcall;
function SetProcessWorkingSetSize(hProcess: THandle;
  dwMinimumWorkingSetSize, dwMaximumWorkingSetSize: DWORD): BOOL; stdcall;
function OpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
function GetCurrentProcess: THandle; stdcall;
function GetCurrentProcessId: DWORD; stdcall;
procedure ExitProcess(uExitCode: UINT); stdcall;
function TerminateProcess(hProcess: THandle; uExitCode: UINT): BOOL; stdcall;
function GetExitCodeProcess(hProcess: THandle; var lpExitCode: DWORD): BOOL; stdcall;
procedure FatalExit(ExitCode: Integer); stdcall;
function GetEnvironmentStringsA: PAnsiChar; stdcall;
function GetEnvironmentStringsW: PWideChar; stdcall;
function GetEnvironmentStrings: PTChar; stdcall;
function FreeEnvironmentStringsA(p1: PAnsiChar): BOOL; stdcall;
function FreeEnvironmentStringsW(p1: PWideChar): BOOL; stdcall;
function FreeEnvironmentStrings(p1: PTChar): BOOL; stdcall;
procedure RaiseException(dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD;
  lpArguments: PDWORD); stdcall;
function UnhandledExceptionFilter(const ExceptionInfo: TExceptionPointers): Longint; stdcall;
function CreateFiber(dwStackSize: DWORD; lpStartAddress: TFNFiberStartRoutine;
  lpParameter: Pointer): BOOL; stdcall;
function DeleteFiber(lpFiber: Pointer): BOOL; stdcall;
function ConvertThreadToFiber(lpParameter: Pointer): BOOL; stdcall;
function SwitchToFiber(lpFiber: Pointer): BOOL; stdcall;
function SwitchToThread: BOOL; stdcall;

type



  TFNTopLevelExceptionFilter = TFarProc;


function SetUnhandledExceptionFilter(lpTopLevelExceptionFilter: TFNTopLevelExceptionFilter):
  TFNTopLevelExceptionFilter; stdcall;
function CreateThread(lpThreadAttributes: Pointer;
  dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine;
  lpParameter: Pointer; dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall;
function CreateRemoteThread(hProcess: THandle; lpThreadAttributes: Pointer;
  dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer;
  dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall;
function GetCurrentThread: THandle; stdcall;
function GetCurrentThreadId: DWORD; stdcall;
function SetThreadAffinityMask(hThread: THandle; dwThreadAffinityMask: DWORD): DWORD; stdcall;
function SetThreadIdealProcessor(hThread: THandle; dwIdealProcessor: DWORD): BOOL; stdcall;
function SetProcessPriorityBoost(hThread: THandle; DisablePriorityBoost: Bool): BOOL; stdcall;
function GetProcessPriorityBoost(hThread: THandle; var DisablePriorityBoost: Bool): BOOL; stdcall;
function SetThreadPriority(hThread: THandle; nPriority: Integer): BOOL; stdcall;
function GetThreadPriority(hThread: THandle): Integer; stdcall;
function SetThreadPriorityBoost(hThread: THandle; DisablePriorityBoost: Bool): BOOL; stdcall;
function GetThreadPriorityBoost(hThread: THandle; var DisablePriorityBoost: Bool): BOOL; stdcall;
function GetThreadTimes(hThread: THandle;
  var lpCreationTime, lpExitTime, lpKernelTime, lpUserTime: TFileTime): BOOL; stdcall;
procedure ExitThread(dwExitCode: DWORD); stdcall;
function TerminateThread(hThread: THandle; dwExitCode: DWORD): BOOL; stdcall;
function GetExitCodeThread(hThread: THandle; var lpExitCode: DWORD): BOOL; stdcall;
function GetThreadSelectorEntry(hThread: THandle; dwSelector: DWORD;
  var lpSelectorEntry: TLDTEntry): BOOL; stdcall;
function GetLastError: DWORD; stdcall;
procedure SetLastError(dwErrCode: DWORD); stdcall;
function GetOverlappedResult(hFile: THandle; const lpOverlapped: TOverlapped;
  var lpNumberOfBytesTransferred: DWORD; bWait: BOOL): BOOL; stdcall;
function CreateIoCompletionPort(FileHandle, ExistingCompletionPort: THandle;
  CompletionKey, NumberOfConcurrentThreads: DWORD): THandle; stdcall;
function GetQueuedCompletionStatus(CompletionPort: THandle;
  var lpNumberOfBytesTransferred, lpCompletionKey: DWORD;
  var lpOverlapped: POverlapped; dwMilliseconds: DWORD): BOOL; stdcall;
function PostQueuedCompletionStatus(CompletionPort: THandle; dwNumberOfBytesTransferred: DWORD;
  dwCompletionKey: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;

const
  SEM_FAILCRITICALERRORS = 1;
  SEM_NOGPFAULTERRORBOX = 2;
  SEM_NOALIGNMENTFAULTEXCEPT = 4;
  SEM_NOOPENFILEERRORBOX = $8000;

function SetErrorMode(uMode: UINT): UINT; stdcall;
function ReadProcessMemory(hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
  nSize: SIZE_T; var lpNumberOfBytesRead :SIZE_T): BOOL; stdcall;
function WriteProcessMemory(hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
  nSize: SIZE_T; var lpNumberOfBytesWritten: SIZE_T): BOOL; stdcall;
function GetThreadContext(hThread: THandle; var lpContext: TContext): BOOL; stdcall;
function SetThreadContext(hThread: THandle; const lpContext: TContext): BOOL; stdcall;
function SuspendThread(hThread: THandle): DWORD; stdcall;
function ResumeThread(hThread: THandle): DWORD; stdcall;

type



  TFNAPCProc = TFarProc;


function QueueUserAPC(pfnAPC: TFNAPCProc; hThread: THandle; dwData: DWORD): BOOL; stdcall;
procedure DebugBreak; stdcall;
function WaitForDebugEvent(var lpDebugEvent: TDebugEvent; dwMilliseconds: DWORD): BOOL; stdcall;
function ContinueDebugEvent(dwProcessId, dwThreadId, dwContinueStatus: DWORD): BOOL; stdcall;
function DebugActiveProcess(dwProcessId: DWORD): BOOL; stdcall;
procedure InitializeCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall;
procedure EnterCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall;
procedure LeaveCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall;
function InitializeCriticalSectionAndSpinCount(var lpCriticalSection: TRTLCriticalSection; dwSpinCount: DWORD): BOOL; stdcall;
function SetCriticalSectionSpinCount(var lpCriticalSection: TRTLCriticalSection; dwSpinCount: DWORD): DWORD; stdcall;
function TryEnterCriticalSection(var lpCriticalSection: TRTLCriticalSection): BOOL; stdcall;
procedure DeleteCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall;
function SetEvent(hEvent: THandle): BOOL; stdcall;
function ResetEvent(hEvent: THandle): BOOL; stdcall;
function PulseEvent(hEvent: THandle): BOOL; stdcall;
function ReleaseSemaphore(hSemaphore: THandle; lReleaseCount: Longint;
  lpPreviousCount: Pointer): BOOL; stdcall;
function ReleaseMutex(hMutex: THandle): BOOL; stdcall;
function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD; stdcall;

type
  TWOHandleArray = array[0..MAXIMUM_WAIT_OBJECTS - 1] of THandle;
  PWOHandleArray = ^TWOHandleArray;

function WaitForMultipleObjects(nCount: DWORD; lpHandles: PWOHandleArray;
  bWaitAll: BOOL; dwMilliseconds: DWORD): DWORD; stdcall;
procedure Sleep(dwMilliseconds: DWORD); stdcall;
function LoadResource(hModule: HINST; hResInfo: HRSRC): HGLOBAL; stdcall;
function SizeofResource(hModule: HINST; hResInfo: HRSRC): DWORD; stdcall;
function GlobalDeleteAtom(nAtom: ATOM): ATOM; stdcall;
function InitAtomTable(nSize: DWORD): BOOL; stdcall;
function DeleteAtom(nAtom: ATOM): ATOM; stdcall;
function SetHandleCount(uNumber: UINT): UINT; stdcall;
function GetLogicalDrives: DWORD; stdcall;
function LockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD;
  nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: DWORD): BOOL; stdcall;
function UnlockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD;
  nNumberOfBytesToUnlockLow, nNumberOfBytesToUnlockHigh: DWORD): BOOL; stdcall;
function LockFileEx(hFile: THandle; dwFlags, dwReserved: DWORD;
  nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: DWORD;
  const lpOverlapped: TOverlapped): BOOL; stdcall;

const
  LOCKFILE_FAIL_IMMEDIATELY = 1;
  LOCKFILE_EXCLUSIVE_LOCK = 2;

function UnlockFileEx(hFile: THandle; dwReserved, nNumberOfBytesToUnlockLow: DWORD;
  nNumberOfBytesToUnlockHigh: DWORD; const lpOverlapped: TOverlapped): BOOL; stdcall;

type
  PByHandleFileInformation = ^TByHandleFileInformation;
  _BY_HANDLE_FILE_INFORMATION = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    dwVolumeSerialNumber: DWORD;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    nNumberOfLinks: DWORD;
    nFileIndexHigh: DWORD;
    nFileIndexLow: DWORD;
  end;
  TByHandleFileInformation = _BY_HANDLE_FILE_INFORMATION;
  BY_HANDLE_FILE_INFORMATION = _BY_HANDLE_FILE_INFORMATION;

function GetFileInformationByHandle(hFile: THandle; var lpFileInformation: TByHandleFileInformation): BOOL; stdcall;
function GetFileType(hFile: THandle): DWORD; stdcall;
function GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall;
function GetStdHandle(nStdHandle: DWORD): THandle; stdcall;
function SetStdHandle(nStdHandle: DWORD; hHandle: THandle): BOOL; stdcall;
function WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;
  var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
function FlushFileBuffers(hFile: THandle): BOOL; stdcall;
function DeviceIoControl(hDevice: THandle; dwIoControlCode: DWORD; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  var lpBytesReturned: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
function SetEndOfFile(hFile: THandle): BOOL; stdcall;
function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
function FindClose(hFindFile: THandle): BOOL; stdcall;
function GetFileTime(hFile: THandle;
  lpCreationTime, lpLastAccessTime, lpLastWriteTime: PFileTime): BOOL; stdcall;
function SetFileTime(hFile: THandle;
  lpCreationTime, lpLastAccessTime, lpLastWriteTime: PFileTime): BOOL; stdcall;
function CloseHandle(hObject: THandle): BOOL; stdcall;
function DuplicateHandle(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle: THandle;
  lpTargetHandle: PHandle; dwDesiredAccess: DWORD;
  bInheritHandle: BOOL; dwOptions: DWORD): BOOL; stdcall;
function GetHandleInformation(hObject: THandle; var lpdwFlags: DWORD): BOOL; stdcall;
function SetHandleInformation(hObject: THandle; dwMask: DWORD; dwFlags: DWORD): BOOL; stdcall;

const
  HANDLE_FLAG_INHERIT = 1;
  HANDLE_FLAG_PROTECT_FROM_CLOSE = 2;
  HINSTANCE_ERROR = $20;

function LoadModule(lpModuleName: LPCSTR; lpParameterBlock: Pointer): DWORD; stdcall;
function WinExec(lpCmdLine: LPCSTR; uCmdShow: UINT): UINT; stdcall;
function ClearCommBreak(hFile: THandle): BOOL; stdcall;
function ClearCommError(hFile: THandle; var lpErrors: DWORD; lpStat: PComStat): BOOL; stdcall;
function SetupComm(hFile: THandle; dwInQueue, dwOutQueue: DWORD): BOOL; stdcall;
function EscapeCommFunction(hFile: THandle; dwFunc: DWORD): BOOL; stdcall;
function GetCommConfig(hCommDev: THandle; var lpCC: TCommConfig; var lpdwSize: DWORD): BOOL; stdcall;
function GetCommMask(hFile: THandle; var lpEvtMask: DWORD): BOOL; stdcall;
function GetCommProperties(hFile: THandle; var lpCommProp: TCommProp): BOOL; stdcall;
function GetCommModemStatus(hFile: THandle; var lpModemStat: DWORD): BOOL; stdcall;
function GetCommState(hFile: THandle; var lpDCB: TDCB): BOOL; stdcall;
function GetCommTimeouts(hFile: THandle; var lpCommTimeouts: TCommTimeouts): BOOL; stdcall;
function PurgeComm(hFile: THandle; dwFlags: DWORD): BOOL; stdcall;
function SetCommBreak(hFile: THandle): BOOL; stdcall;
function SetCommConfig(hCommDev: THandle; const lpCC: TCommConfig; dwSize: DWORD): BOOL; stdcall;
function SetCommMask(hFile: THandle; dwEvtMask: DWORD): BOOL; stdcall;
function SetCommState(hFile: THandle; const lpDCB: TDCB): BOOL; stdcall;
function SetCommTimeouts(hFile: THandle; const lpCommTimeouts: TCommTimeouts): BOOL; stdcall;
function TransmitCommChar(hFile: THandle; cChar: AnsiChar): BOOL; stdcall;
function WaitCommEvent(hFile: THandle; var lpEvtMask: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
function SetTapePosition(hDevice: THandle; dwPositionMethod, dwPartition: DWORD;
  dwOffsetLow, dwOffsetHigh: DWORD; bImmediate: BOOL): DWORD; stdcall;
function GetTapePosition(hDevice: THandle; dwPositionType: DWORD;
  var lpdwPartition, lpdwOffsetLow: DWORD; lpdwOffsetHigh: Pointer): DWORD; stdcall;
function PrepareTape(hDevice: THandle; dwOperation: DWORD; bImmediate: BOOL): DWORD; stdcall;
function EraseTape(hDevice: THandle; dwEraseType: DWORD; bImmediate: BOOL): DWORD; stdcall;
function CreateTapePartition(hDevice: THandle; dwPartitionMethod, dwCount, dwSize: DWORD): DWORD; stdcall;
function WriteTapemark(hDevice: THandle;
  dwTapemarkType, dwTapemarkCount: DWORD; bImmediate: BOOL): DWORD; stdcall;
function GetTapeStatus(hDevice: THandle): DWORD; stdcall;
function GetTapeParameters(hDevice: THandle; dwOperation: DWORD;
  var lpdwSize: DWORD; lpTapeInformation: Pointer): DWORD; stdcall;

const
  GET_TAPE_MEDIA_INFORMATION = 0;
  GET_TAPE_DRIVE_INFORMATION = 1;

function SetTapeParameters(hDevice: THandle; dwOperation: DWORD; lpTapeInformation: Pointer): DWORD; stdcall;

const
  SET_TAPE_MEDIA_INFORMATION = 0;
  SET_TAPE_DRIVE_INFORMATION = 1;

function Beep(dwFreq, dwDuration: DWORD): BOOL; stdcall;
function MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer; stdcall;
procedure GetSystemTime(var lpSystemTime: TSystemTime); stdcall;
procedure GetSystemTimeAsFileTime(var lpSystemTimeAsFileTime: TFileTime); stdcall;
function SetSystemTime(const lpSystemTime: TSystemTime): BOOL; stdcall;
procedure GetLocalTime(var lpSystemTime: TSystemTime); stdcall;
function SetLocalTime(const lpSystemTime: TSystemTime): BOOL; stdcall;
procedure GetSystemInfo(var lpSystemInfo: TSystemInfo); stdcall;
function IsProcessorFeaturePresent(ProcessorFeature: DWORD): BOOL; stdcall;


type
  PTimeZoneInformation = ^TTimeZoneInformation;
  _TIME_ZONE_INFORMATION = record
    Bias: Longint;
    StandardName: array[0..31] of WCHAR;
    StandardDate: TSystemTime;
    StandardBias: Longint;
    DaylightName: array[0..31] of WCHAR;
    DaylightDate: TSystemTime;
    DaylightBias: Longint;
  end;
  TTimeZoneInformation = _TIME_ZONE_INFORMATION;
  TIME_ZONE_INFORMATION = _TIME_ZONE_INFORMATION;

function SystemTimeToTzSpecificLocalTime(lpTimeZoneInformation: PTimeZoneInformation;
  var lpUniversalTime, lpLocalTime: TSystemTime): BOOL; stdcall;
function GetTimeZoneInformation(var lpTimeZoneInformation: TTimeZoneInformation): DWORD; stdcall;
function SetTimeZoneInformation(const lpTimeZoneInformation: TTimeZoneInformation): BOOL; stdcall;

{ Routines to convert back and forth between system time and file time }

function SystemTimeToFileTime(const lpSystemTime: TSystemTime; var lpFileTime: TFileTime): BOOL; stdcall;

//function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall;
function FileTimeToLocalFileTime(lpFileTime :PFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall;

//function LocalFileTimeToFileTime(const lpLocalFileTime: TFileTime; var lpFileTime: TFileTime): BOOL; stdcall;
function LocalFileTimeToFileTime(lpLocalFileTime :PFileTime; var lpFileTime: TFileTime): BOOL; stdcall;

//function FileTimeToSystemTime(const lpFileTime: TFileTime; var lpSystemTime: TSystemTime): BOOL; stdcall;
function FileTimeToSystemTime(lpFileTime :PFileTime; var lpSystemTime: TSystemTime): BOOL; stdcall;

//function CompareFileTime(const lpFileTime1, lpFileTime2: TFileTime): Longint; stdcall;
function CompareFileTime(lpFileTime1, lpFileTime2 :PFileTime): Longint; stdcall;

//function FileTimeToDosDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL; stdcall;
function FileTimeToDosDateTime(lpFileTime :PFileTime; var lpFatDate, lpFatTime: Word): BOOL; stdcall;

function DosDateTimeToFileTime(wFatDate, wFatTime: Word; var lpFileTime: TFileTime): BOOL; stdcall;

function GetTickCount: DWORD; stdcall;
function SetSystemTimeAdjustment(dwTimeAdjustment: DWORD; bTimeAdjustmentDisabled: BOOL): BOOL; stdcall;
function GetSystemTimeAdjustment(var lpTimeAdjustment, lpTimeIncrement: DWORD;
  var lpTimeAdjustmentDisabled: BOOL): BOOL; stdcall;
function FormatMessageA(dwFlags: DWORD; lpSource: Pointer; dwMessageId: DWORD; dwLanguageId: DWORD;
  lpBuffer: PAnsiChar; nSize: DWORD; Arguments: Pointer): DWORD; stdcall;
function FormatMessageW(dwFlags: DWORD; lpSource: Pointer; dwMessageId: DWORD; dwLanguageId: DWORD;
  lpBuffer: PWideChar; nSize: DWORD; Arguments: Pointer): DWORD; stdcall;
function FormatMessage(dwFlags: DWORD; lpSource: Pointer; dwMessageId: DWORD; dwLanguageId: DWORD;
  lpBuffer: PTChar; nSize: DWORD; Arguments: Pointer): DWORD; stdcall;

const
  FORMAT_MESSAGE_ALLOCATE_BUFFER = $100;
  FORMAT_MESSAGE_IGNORE_INSERTS = $200;
  FORMAT_MESSAGE_FROM_STRING = $400;
  FORMAT_MESSAGE_FROM_HMODULE = $800;
  FORMAT_MESSAGE_FROM_SYSTEM = $1000;
  FORMAT_MESSAGE_ARGUMENT_ARRAY = $2000;
  FORMAT_MESSAGE_MAX_WIDTH_MASK = 255;

function CreatePipe(var hReadPipe, hWritePipe: THandle;
  lpPipeAttributes: PSecurityAttributes; nSize: DWORD): BOOL; stdcall;
function ConnectNamedPipe(hNamedPipe: THandle; lpOverlapped: POverlapped): BOOL; stdcall;
function DisconnectNamedPipe(hNamedPipe: THandle): BOOL; stdcall;
function SetNamedPipeHandleState(hNamedPipe: THandle; var lpMode: DWORD;
  lpMaxCollectionCount, lpCollectDataTimeout: Pointer): BOOL; stdcall;
function GetNamedPipeInfo(hNamedPipe: THandle; var lpFlags: DWORD;
  lpOutBufferSize, lpInBufferSize, lpMaxInstances: Pointer): BOOL; stdcall;
function PeekNamedPipe(hNamedPipe: THandle; lpBuffer: Pointer; nBufferSize: DWORD;
  lpBytesRead, lpTotalBytesAvail, lpBytesLeftThisMessage: Pointer): BOOL; stdcall;
function TransactNamedPipe(hNamedPipe: THandle; lpInBuffer: Pointer; nInBufferSize: DWORD;
  lpOutBuffer: Pointer; nOutBufferSize: DWORD; var lpBytesRead: DWORD;
  lpOverlapped: POverlapped): BOOL; stdcall;

function CreateMailslotA(lpName: PAnsiChar; nMaxMessageSize: DWORD;
  lReadTimeout: DWORD; lpSecurityAttributes: PSecurityAttributes): THandle; stdcall;
function CreateMailslotW(lpName: PWideChar; nMaxMessageSize: DWORD;
  lReadTimeout: DWORD; lpSecurityAttributes: PSecurityAttributes): THandle; stdcall;
function CreateMailslot(lpName: PTChar; nMaxMessageSize: DWORD;
  lReadTimeout: DWORD; lpSecurityAttributes: PSecurityAttributes): THandle; stdcall;
function GetMailslotInfo(hMailslot: THandle; lpMaxMessageSize: Pointer;
  var lpNextSize: DWORD; lpMessageCount, lpReadTimeout: Pointer): BOOL; stdcall;
function SetMailslotInfo(hMailslot: THandle; lReadTimeout: DWORD): BOOL; stdcall;
function MapViewOfFile(hFileMappingObject: THandle; dwDesiredAccess: DWORD;
  dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer; stdcall;
function FlushViewOfFile(const lpBaseAddress: Pointer; dwNumberOfBytesToFlush: DWORD): BOOL; stdcall;
function UnmapViewOfFile(lpBaseAddress: Pointer): BOOL; stdcall;
function EncryptFileA(lpFilename: PAnsiChar): BOOL; stdcall;
function EncryptFileW(lpFilename: PWideChar): BOOL; stdcall;
function EncryptFile(lpFilename: PTChar): BOOL; stdcall;
function DecryptFileA(lpFilename: PAnsiChar; dwReserved: DWORD): BOOL; stdcall;
function DecryptFileW(lpFilename: PWideChar; dwReserved: DWORD): BOOL; stdcall;
function DecryptFile(lpFilename: PTChar; dwReserved: DWORD): BOOL; stdcall;

const
  { Currently defined recovery flags }
  EFS_USE_RECOVERY_KEYS = $1;

type
  TFNExportFunc = function (pbData, pvCallbackContext: Pointer; ulLength: ULONG): DWORD; stdcall;
  TFNImportFunc = function (pbData, pvCallbackContext: Pointer; ulLength: ULONG): DWORD; stdcall;

const
  { OpenRaw flag values }
  CREATE_FOR_IMPORT = 1;
  CREATE_FOR_DIR = 2;

function OpenRawA(lpFilename: PAnsiChar; ulFlags: ULONG; pvContext: Pointer): DWORD; stdcall;
function OpenRawW(lpFilename: PWideChar; ulFlags: ULONG; pvContext: Pointer): DWORD; stdcall;
function OpenRaw(lpFilename: PTChar; ulFlags: ULONG; pvContext: Pointer): DWORD; stdcall;
function ReadRaw(pfExportCallback: TFNExportFunc; pvCallbackContext, pvContext: Pointer): DWORD; stdcall;
function WriteRaw(pfExportCallback: TFNImportFunc; pvCallbackContext, pvContext: Pointer): DWORD; stdcall;
procedure CloseRaw(pvContext: Pointer); stdcall;

type
  PRecoveryAgentInformationA = ^TRecoveryAgentInformationA;
  PRecoveryAgentInformationW = ^TRecoveryAgentInformationW;
  PRecoveryAgentInformation = PRecoveryAgentInformationA;
  _RECOVERY_AGENT_INFORMATIONA = record
    NextEntryOffset: DWORD;
    AgentNameLength: DWORD;
    AgentInformation: array[0..0] of AnsiChar;
  end;
  _RECOVERY_AGENT_INFORMATIONW = record
    NextEntryOffset: DWORD;
    AgentNameLength: DWORD;
    AgentInformation: array[0..0] of WideChar;
  end;
  _RECOVERY_AGENT_INFORMATION = _RECOVERY_AGENT_INFORMATIONA;
  TRecoveryAgentInformationA = _RECOVERY_AGENT_INFORMATIONA;
  TRecoveryAgentInformationW = _RECOVERY_AGENT_INFORMATIONW;
  TRecoveryAgentInformation = TRecoveryAgentInformationA;
  RECOVERY_AGENT_INFORMATIONA = _RECOVERY_AGENT_INFORMATIONA;
  RECOVERY_AGENT_INFORMATIONW = _RECOVERY_AGENT_INFORMATIONW;
  RECOVERY_AGENT_INFORMATION = RECOVERY_AGENT_INFORMATIONA;

function QueryRecoveryAgentsA(p1: PAnsiChar; var p2: Pointer; var p3: TRecoveryAgentInformationA): DWORD; stdcall;
function QueryRecoveryAgentsW(p1: PWideChar; var p2: Pointer; var p3: TRecoveryAgentInformationW): DWORD; stdcall;
function QueryRecoveryAgents(p1: PTChar; var p2: Pointer; var p3: TRecoveryAgentInformation): DWORD; stdcall;

{ _l Compat Functions }

function lstrcmpA(lpString1, lpString2: PAnsiChar): Integer; stdcall;
function lstrcmpW(lpString1, lpString2: PWideChar): Integer; stdcall;
function lstrcmp(lpString1, lpString2: PTChar): Integer; stdcall;
function lstrcmpiA(lpString1, lpString2: PAnsiChar): Integer; stdcall;
function lstrcmpiW(lpString1, lpString2: PWideChar): Integer; stdcall;
function lstrcmpi(lpString1, lpString2: PTChar): Integer; stdcall;
function lstrcpynA(lpString1, lpString2: PAnsiChar; iMaxLength: Integer): PAnsiChar; stdcall;
function lstrcpynW(lpString1, lpString2: PWideChar; iMaxLength: Integer): PWideChar; stdcall;
function lstrcpyn(lpString1, lpString2: PTChar; iMaxLength: Integer): PTChar; stdcall;
function lstrcpyA(lpString1, lpString2: PAnsiChar): PAnsiChar; stdcall;
function lstrcpyW(lpString1, lpString2: PWideChar): PWideChar; stdcall;
function lstrcpy(lpString1, lpString2: PTChar): PTChar; stdcall;
function lstrcatA(lpString1, lpString2: PAnsiChar): PAnsiChar; stdcall;
function lstrcatW(lpString1, lpString2: PWideChar): PWideChar; stdcall;
function lstrcat(lpString1, lpString2: PTChar): PTChar; stdcall;
function lstrlenA(lpString: PAnsiChar): Integer; stdcall;
function lstrlenW(lpString: PWideChar): Integer; stdcall;
function lstrlen(lpString: PTChar): Integer; stdcall;

function OpenFile(const lpFileName: LPCSTR; var lpReOpenBuff: TOFStruct; uStyle: UINT): HFILE; stdcall;
function _lopen(const lpPathName: LPCSTR; iReadWrite: Integer): HFILE; stdcall;
function _lcreat(const lpPathName: LPCSTR; iAttribute: Integer): HFILE; stdcall;
function _lread(hFile: HFILE; lpBuffer: Pointer; uBytes: UINT): UINT; stdcall;
function _lwrite(hFile: HFILE; const lpBuffer: LPCSTR; uBytes: UINT): UINT; stdcall;
function _hread(hFile: HFILE; lpBuffer: Pointer; lBytes: Longint): Longint; stdcall;
function _hwrite(hFile: HFILE; lpBuffer: LPCSTR; lBytes: Longint): Longint; stdcall;
function _lclose(hFile: HFILE): HFILE; stdcall;
function _llseek(hFile: HFILE; lOffset: Longint; iOrigin: Integer): Longint; stdcall;
function IsTextUnicode(lpBuffer: Pointer; cb: Integer; lpi: PINT): BOOL; stdcall;
function TlsAlloc: DWORD; stdcall;

const
  TLS_OUT_OF_INDEXES = DWORD($FFFFFFFF);

function TlsGetValue(dwTlsIndex: DWORD): Pointer; stdcall;
function TlsSetValue(dwTlsIndex: DWORD; lpTlsValue: Pointer): BOOL; stdcall;
function TlsFree(dwTlsIndex: DWORD): BOOL; stdcall;

type
  TPROverlappedCompletionRoutine = TFarProc;


function SleepEx(dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall;
function WaitForSingleObjectEx(hHandle: THandle; dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall;
function WaitForMultipleObjectsEx(nCount: DWORD; lpHandles: PWOHandleArray;
  bWaitAll: BOOL; dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall;
function SignalObjectAndWait(hObjectToSignal: THandle; hObjectToWaitOn: THandle;
  dwMilliseconds: DWORD; bAlertable: BOOL): BOOL; stdcall;
function ReadFileEx(hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD;
  lpOverlapped: POverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;
function WriteFileEx(hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToWrite: DWORD;
  const lpOverlapped: TOverlapped; lpCompletionRoutine: FARPROC): BOOL; stdcall;
function BackupRead(hFile: THandle; lpBuffer: PByte; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; bAbort: BOOL;
  bProcessSecurity: BOOL; var lpContext: Pointer): BOOL; stdcall;
function BackupSeek(hFile: THandle; dwLowBytesToSeek, dwHighBytesToSeek: DWORD;
  var lpdwLowByteSeeked, lpdwHighByteSeeked: DWORD; lpContext: Pointer): BOOL; stdcall;
function BackupWrite(hFile: THandle; lpBuffer: PByte; nNumberOfBytesToWrite: DWORD;
  var lpNumberOfBytesWritten: DWORD; bAbort, bProcessSecurity: BOOL; var lpContext: Pointer): BOOL; stdcall;

type
  PWIN32StreamID = ^TWIN32StreamID;
  _WIN32_STREAM_ID = record
    dwStreamId: DWORD;
    dwStreamAttributes: DWORD;
    Size: TLargeInteger;
    dwStreamNameSize: DWORD;
    cStreamName: array[0..0] of WCHAR;
  end;
  TWIN32StreamID = _WIN32_STREAM_ID;
  WIN32_STREAM_ID = _WIN32_STREAM_ID;

const
  { Stream IDs }
  BACKUP_INVALID = 0;
  BACKUP_DATA = 1;
  BACKUP_EA_DATA = 2;
  BACKUP_SECURITY_DATA = 3;
  BACKUP_ALTERNATE_DATA = 4;
  BACKUP_LINK = 5;
  BACKUP_PROPERTY_DATA = 6;

  { Stream Attributes}
  STREAM_NORMAL_ATTRIBUTE = 0;
  STREAM_MODIFIED_WHEN_READ = 1;
  STREAM_CONTAINS_SECURITY = 2;
  STREAM_CONTAINS_PROPERTIES = 4;

  { Dual Mode API below this line. Dual Mode Structures also included. }
  STARTF_USESHOWWINDOW = 1;
  STARTF_USESIZE = 2;
  STARTF_USEPOSITION = 4;
  STARTF_USECOUNTCHARS = 8;
  STARTF_USEFILLATTRIBUTE = $10;
  STARTF_RUNFULLSCREEN = $20;  { ignored for non-x86 platforms }
  STARTF_FORCEONFEEDBACK = $40;
  STARTF_FORCEOFFFEEDBACK = $80;
  STARTF_USESTDHANDLES = $100;
  STARTF_USEHOTKEY = $200;

type
  PStartupInfo = ^TStartupInfo;
  _STARTUPINFOA = record
    cb: DWORD;
    lpReserved: Pointer;
    lpDesktop: Pointer;
    lpTitle: Pointer;
    dwX: DWORD;
    dwY: DWORD;
    dwXSize: DWORD;
    dwYSize: DWORD;
    dwXCountChars: DWORD;
    dwYCountChars: DWORD;
    dwFillAttribute: DWORD;
    dwFlags: DWORD;
    wShowWindow: Word;
    cbReserved2: Word;
    lpReserved2: PByte;
    hStdInput: THandle;
    hStdOutput: THandle;
    hStdError: THandle;
  end;
  TStartupInfo = _STARTUPINFOA;
  STARTUPINFO = _STARTUPINFOA;

const
  SHUTDOWN_NORETRY = 1;

type
  PWin32FindDataA = ^TWin32FindDataA;
  PWin32FindDataW = ^TWin32FindDataW;
  PWin32FindData = {$ifdef bUnicode}PWin32FindDataW{$else}PWin32FindDataA{$endif bUnicode};

  _WIN32_FIND_DATAA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of AnsiChar;
    cAlternateFileName: array[0..13] of AnsiChar;
  end;
  _WIN32_FIND_DATAW = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of WideChar;
    cAlternateFileName: array[0..13] of WideChar;
  end;
  _WIN32_FIND_DATA = {$ifdef bUnicode}_WIN32_FIND_DATAW{$else}_WIN32_FIND_DATAA{$endif bUnicode};

  TWin32FindDataA = _WIN32_FIND_DATAA;
  TWin32FindDataW = _WIN32_FIND_DATAW;
  TWin32FindData = {$ifdef bUnicode}TWin32FindDataW{$else}TWin32FindDataA{$endif bUnicode};

  WIN32_FIND_DATAA = _WIN32_FIND_DATAA;
  WIN32_FIND_DATAW = _WIN32_FIND_DATAW;
  WIN32_FIND_DATA = {$ifdef bUnicode}WIN32_FIND_DATAW{$else}WIN32_FIND_DATAA{$endif bUnicode};

  PWin32FileAttributeData = ^TWin32FileAttributeData;
  _WIN32_FILE_ATTRIBUTE_DATA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
  end;
  TWin32FileAttributeData = _WIN32_FILE_ATTRIBUTE_DATA;
  WIN32_FILE_ATTRIBUTE_DATA = _WIN32_FILE_ATTRIBUTE_DATA;

function CreateMutexA(lpMutexAttributes: PSecurityAttributes; bInitialOwner: BOOL; lpName: PAnsiChar): THandle; stdcall;
function CreateMutexW(lpMutexAttributes: PSecurityAttributes; bInitialOwner: BOOL; lpName: PWideChar): THandle; stdcall;
function CreateMutex(lpMutexAttributes: PSecurityAttributes; bInitialOwner: BOOL; lpName: PTChar): THandle; stdcall;
function OpenMutexA(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PAnsiChar): THandle; stdcall;
function OpenMutexW(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PWideChar): THandle; stdcall;
function OpenMutex(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PTChar): THandle; stdcall;
function CreateEventA(lpEventAttributes: PSecurityAttributes;
  bManualReset, bInitialState: BOOL; lpName: PAnsiChar): THandle; stdcall;
function CreateEventW(lpEventAttributes: PSecurityAttributes;
  bManualReset, bInitialState: BOOL; lpName: PWideChar): THandle; stdcall;
function CreateEvent(lpEventAttributes: PSecurityAttributes;
  bManualReset, bInitialState: BOOL; lpName: PTChar): THandle; stdcall;
function OpenEventA(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PAnsiChar): THandle; stdcall;
function OpenEventW(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PWideChar): THandle; stdcall;
function OpenEvent(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PTChar): THandle; stdcall;
function CreateSemaphoreA(lpSemaphoreAttributes: PSecurityAttributes;
  lInitialCount, lMaximumCount: Longint; lpName: PAnsiChar): THandle; stdcall;
function CreateSemaphoreW(lpSemaphoreAttributes: PSecurityAttributes;
  lInitialCount, lMaximumCount: Longint; lpName: PWideChar): THandle; stdcall;
function CreateSemaphore(lpSemaphoreAttributes: PSecurityAttributes;
  lInitialCount, lMaximumCount: Longint; lpName: PTChar): THandle; stdcall;
function OpenSemaphoreA(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PAnsiChar): THandle; stdcall;
function OpenSemaphoreW(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PWideChar): THandle; stdcall;
function OpenSemaphore(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PTChar): THandle; stdcall;

type




  TFNTimerAPCRoutine = TFarProc;


function CreateWaitableTimerA(lpTimerAttributes: PSecurityAttributes; bManualReset: BOOL; lpTimerName: PAnsiChar): THandle; stdcall;
function CreateWaitableTimerW(lpTimerAttributes: PSecurityAttributes; bManualReset: BOOL; lpTimerName: PWideChar): THandle; stdcall;
function CreateWaitableTimer(lpTimerAttributes: PSecurityAttributes; bManualReset: BOOL; lpTimerName: PTChar): THandle; stdcall;
function OpenWaitableTimerA(dwDesiredAccess: DWORD; bInheritHandle: BOOL;
  lpTimerName: PAnsiChar): THandle; stdcall;
function OpenWaitableTimerW(dwDesiredAccess: DWORD; bInheritHandle: BOOL;
  lpTimerName: PWideChar): THandle; stdcall;
function OpenWaitableTimer(dwDesiredAccess: DWORD; bInheritHandle: BOOL;
  lpTimerName: PTChar): THandle; stdcall;
function SetWaitableTimer(hTimer: THandle; var lpDueTime: TLargeInteger;
  lPeriod: Longint; pfnCompletionRoutine: TFNTimerAPCRoutine;
  lpArgToCompletionRoutine: Pointer; fResume: BOOL): BOOL; stdcall;
function CancelWaitableTimer(hTimer: THandle): BOOL; stdcall;
function CreateFileMappingA(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
  flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PAnsiChar): THandle; stdcall;
function CreateFileMappingW(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
  flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PWideChar): THandle; stdcall;
function CreateFileMapping(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
  flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PTChar): THandle; stdcall;
function OpenFileMappingA(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PAnsiChar): THandle; stdcall;
function OpenFileMappingW(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PWideChar): THandle; stdcall;
function OpenFileMapping(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PTChar): THandle; stdcall;
function GetLogicalDriveStringsA(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall;
function GetLogicalDriveStringsW(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall;
function GetLogicalDriveStrings(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall;
function LoadLibraryA(lpLibFileName: PAnsiChar): HMODULE; stdcall;
function LoadLibraryW(lpLibFileName: PWideChar): HMODULE; stdcall;
function LoadLibrary(lpLibFileName: PTChar): HMODULE; stdcall;
function LoadLibraryExA(lpLibFileName: PAnsiChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
function LoadLibraryExW(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
function LoadLibraryEx(lpLibFileName: PTChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;

const
  DONT_RESOLVE_DLL_REFERENCES = 1;
  LOAD_LIBRARY_AS_DATAFILE = 2;
  LOAD_WITH_ALTERED_SEARCH_PATH = 8;

function GetModuleFileNameA(hModule: HINST; lpFilename: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function GetModuleFileNameW(hModule: HINST; lpFilename: PWideChar; nSize: DWORD): DWORD; stdcall;
function GetModuleFileName(hModule: HINST; lpFilename: PTChar; nSize: DWORD): DWORD; stdcall;
function GetModuleHandleA(lpModuleName: PAnsiChar): HMODULE; stdcall;
function GetModuleHandleW(lpModuleName: PWideChar): HMODULE; stdcall;
function GetModuleHandle(lpModuleName: PTChar): HMODULE; stdcall;
function CreateProcessA(lpApplicationName: PAnsiChar; lpCommandLine: PAnsiChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PAnsiChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;
function CreateProcessW(lpApplicationName: PWideChar; lpCommandLine: PWideChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;
function CreateProcess(lpApplicationName: PTChar; lpCommandLine: PTChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PTChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;
function SetProcessShutdownParameters(dwLevel, dwFlags: DWORD): BOOL; stdcall;
function GetProcessShutdownParameters(var lpdwLevel, lpdwFlags: DWORD): BOOL; stdcall;
function GetProcessVersion(ProcessId: DWORD): DWORD; stdcall;
procedure FatalAppExitA(uAction: UINT; lpMessageText: PAnsiChar); stdcall;
procedure FatalAppExitW(uAction: UINT; lpMessageText: PWideChar); stdcall;
procedure FatalAppExit(uAction: UINT; lpMessageText: PTChar); stdcall;
procedure GetStartupInfoA(var lpStartupInfo: TStartupInfo); stdcall;
procedure GetStartupInfoW(var lpStartupInfo: TStartupInfo); stdcall;
procedure GetStartupInfo(var lpStartupInfo: TStartupInfo); stdcall;
function GetCommandLineA: PAnsiChar; stdcall;
function GetCommandLineW: PWideChar; stdcall;
function GetCommandLine: PTChar; stdcall;
function GetEnvironmentVariableA(lpName: PAnsiChar; lpBuffer: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function GetEnvironmentVariableW(lpName: PWideChar; lpBuffer: PWideChar; nSize: DWORD): DWORD; stdcall;
function GetEnvironmentVariable(lpName: PTChar; lpBuffer: PTChar; nSize: DWORD): DWORD; stdcall;
function SetEnvironmentVariableA(lpName, lpValue: PAnsiChar): BOOL; stdcall;
function SetEnvironmentVariableW(lpName, lpValue: PWideChar): BOOL; stdcall;
function SetEnvironmentVariable(lpName, lpValue: PTChar): BOOL; stdcall;
function ExpandEnvironmentStringsA(lpSrc: PAnsiChar; lpDst: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function ExpandEnvironmentStringsW(lpSrc: PWideChar; lpDst: PWideChar; nSize: DWORD): DWORD; stdcall;
function ExpandEnvironmentStrings(lpSrc: PTChar; lpDst: PTChar; nSize: DWORD): DWORD; stdcall;
procedure OutputDebugStringA(lpOutputString: PAnsiChar); stdcall;
procedure OutputDebugStringW(lpOutputString: PWideChar); stdcall;
procedure OutputDebugString(lpOutputString: PTChar); stdcall;
function FindResourceA(hModule: HMODULE; lpName, lpType: PAnsiChar): HRSRC; stdcall;
function FindResourceW(hModule: HMODULE; lpName, lpType: PWideChar): HRSRC; stdcall;
function FindResource(hModule: HMODULE; lpName, lpType: PTChar): HRSRC; stdcall;
function FindResourceExA(hModule: HMODULE; lpType, lpName: PAnsiChar; wLanguage: Word): HRSRC; stdcall;
function FindResourceExW(hModule: HMODULE; lpType, lpName: PWideChar; wLanguage: Word): HRSRC; stdcall;
function FindResourceEx(hModule: HMODULE; lpType, lpName: PTChar; wLanguage: Word): HRSRC; stdcall;

type
  ENUMRESTYPEPROC = FARPROC;
  ENUMRESNAMEPROC = FARPROC;
  ENUMRESLANGPROC = FARPROC;

function EnumResourceTypesA(hModule: HMODULE; lpEnumFunc: ENUMRESTYPEPROC;
  lParam: Longint): BOOL; stdcall;
function EnumResourceTypesW(hModule: HMODULE; lpEnumFunc: ENUMRESTYPEPROC;
  lParam: Longint): BOOL; stdcall;
function EnumResourceTypes(hModule: HMODULE; lpEnumFunc: ENUMRESTYPEPROC;
  lParam: Longint): BOOL; stdcall;
function EnumResourceNamesA(hModule: HMODULE; lpType: PAnsiChar;
  lpEnumFunc: ENUMRESNAMEPROC; lParam: Longint): BOOL; stdcall;
function EnumResourceNamesW(hModule: HMODULE; lpType: PWideChar;
  lpEnumFunc: ENUMRESNAMEPROC; lParam: Longint): BOOL; stdcall;
function EnumResourceNames(hModule: HMODULE; lpType: PTChar;
  lpEnumFunc: ENUMRESNAMEPROC; lParam: Longint): BOOL; stdcall;
function EnumResourceLanguagesA(hModule: HMODULE; lpType, lpName: PAnsiChar;
  lpEnumFunc: ENUMRESLANGPROC; lParam: Longint): BOOL; stdcall;
function EnumResourceLanguagesW(hModule: HMODULE; lpType, lpName: PWideChar;
  lpEnumFunc: ENUMRESLANGPROC; lParam: Longint): BOOL; stdcall;
function EnumResourceLanguages(hModule: HMODULE; lpType, lpName: PTChar;
  lpEnumFunc: ENUMRESLANGPROC; lParam: Longint): BOOL; stdcall;
function BeginUpdateResourceA(pFileName: PAnsiChar; bDeleteExistingResources: BOOL): THandle; stdcall;
function BeginUpdateResourceW(pFileName: PWideChar; bDeleteExistingResources: BOOL): THandle; stdcall;
function BeginUpdateResource(pFileName: PTChar; bDeleteExistingResources: BOOL): THandle; stdcall;
function UpdateResourceA(hUpdate: THandle; lpType, lpName: PAnsiChar;
  wLanguage: Word; lpData: Pointer; cbData: DWORD): BOOL; stdcall;
function UpdateResourceW(hUpdate: THandle; lpType, lpName: PWideChar;
  wLanguage: Word; lpData: Pointer; cbData: DWORD): BOOL; stdcall;
function UpdateResource(hUpdate: THandle; lpType, lpName: PTChar;
  wLanguage: Word; lpData: Pointer; cbData: DWORD): BOOL; stdcall;
function EndUpdateResourceA(hUpdate: THandle; fDiscard: BOOL): BOOL; stdcall;
function EndUpdateResourceW(hUpdate: THandle; fDiscard: BOOL): BOOL; stdcall;
function EndUpdateResource(hUpdate: THandle; fDiscard: BOOL): BOOL; stdcall;
function GlobalAddAtomA(lpString: PAnsiChar): ATOM; stdcall;
function GlobalAddAtomW(lpString: PWideChar): ATOM; stdcall;
function GlobalAddAtom(lpString: PTChar): ATOM; stdcall;
function GlobalFindAtomA(lpString: PAnsiChar): ATOM; stdcall;
function GlobalFindAtomW(lpString: PWideChar): ATOM; stdcall;
function GlobalFindAtom(lpString: PTChar): ATOM; stdcall;
function GlobalGetAtomNameA(nAtom: ATOM; lpBuffer: PAnsiChar; nSize: Integer): UINT; stdcall;
function GlobalGetAtomNameW(nAtom: ATOM; lpBuffer: PWideChar; nSize: Integer): UINT; stdcall;
function GlobalGetAtomName(nAtom: ATOM; lpBuffer: PTChar; nSize: Integer): UINT; stdcall;
function AddAtomA(lpString: PAnsiChar): ATOM; stdcall;
function AddAtomW(lpString: PWideChar): ATOM; stdcall;
function AddAtom(lpString: PTChar): ATOM; stdcall;
function FindAtomA(lpString: PAnsiChar): ATOM; stdcall;
function FindAtomW(lpString: PWideChar): ATOM; stdcall;
function FindAtom(lpString: PTChar): ATOM; stdcall;
function GetAtomNameA(nAtom: ATOM; lpBuffer: PAnsiChar; nSize: Integer): UINT; stdcall;
function GetAtomNameW(nAtom: ATOM; lpBuffer: PWideChar; nSize: Integer): UINT; stdcall;
function GetAtomName(nAtom: ATOM; lpBuffer: PTChar; nSize: Integer): UINT; stdcall;
function GetProfileIntA(lpAppName, lpKeyName: PAnsiChar; nDefault: Integer): UINT; stdcall;
function GetProfileIntW(lpAppName, lpKeyName: PWideChar; nDefault: Integer): UINT; stdcall;
function GetProfileInt(lpAppName, lpKeyName: PTChar; nDefault: Integer): UINT; stdcall;
function GetProfileStringA(lpAppName, lpKeyName, lpDefault: PAnsiChar;
  lpReturnedString: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function GetProfileStringW(lpAppName, lpKeyName, lpDefault: PWideChar;
  lpReturnedString: PWideChar; nSize: DWORD): DWORD; stdcall;
function GetProfileString(lpAppName, lpKeyName, lpDefault: PTChar;
  lpReturnedString: PTChar; nSize: DWORD): DWORD; stdcall;
function WriteProfileStringA(lpAppName, lpKeyName, lpString: PAnsiChar): BOOL; stdcall;
function WriteProfileStringW(lpAppName, lpKeyName, lpString: PWideChar): BOOL; stdcall;
function WriteProfileString(lpAppName, lpKeyName, lpString: PTChar): BOOL; stdcall;
function GetProfileSectionA(lpAppName: PAnsiChar; lpReturnedString: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function GetProfileSectionW(lpAppName: PWideChar; lpReturnedString: PWideChar; nSize: DWORD): DWORD; stdcall;
function GetProfileSection(lpAppName: PTChar; lpReturnedString: PTChar; nSize: DWORD): DWORD; stdcall;
function WriteProfileSectionA(lpAppName, lpString: PAnsiChar): BOOL; stdcall;
function WriteProfileSectionW(lpAppName, lpString: PWideChar): BOOL; stdcall;
function WriteProfileSection(lpAppName, lpString: PTChar): BOOL; stdcall;
function GetPrivateProfileIntA(lpAppName, lpKeyName: PAnsiChar; nDefault: Integer; lpFileName: PAnsiChar): UINT; stdcall;
function GetPrivateProfileIntW(lpAppName, lpKeyName: PWideChar; nDefault: Integer; lpFileName: PWideChar): UINT; stdcall;
function GetPrivateProfileInt(lpAppName, lpKeyName: PTChar; nDefault: Integer; lpFileName: PTChar): UINT; stdcall;
function GetPrivateProfileStringA(lpAppName, lpKeyName, lpDefault: PAnsiChar;
  lpReturnedString: PAnsiChar; nSize: DWORD; lpFileName: PAnsiChar): DWORD; stdcall;
function GetPrivateProfileStringW(lpAppName, lpKeyName, lpDefault: PWideChar;
  lpReturnedString: PWideChar; nSize: DWORD; lpFileName: PWideChar): DWORD; stdcall;
function GetPrivateProfileString(lpAppName, lpKeyName, lpDefault: PTChar;
  lpReturnedString: PTChar; nSize: DWORD; lpFileName: PTChar): DWORD; stdcall;
function WritePrivateProfileStringA(lpAppName, lpKeyName, lpString, lpFileName: PAnsiChar): BOOL; stdcall;
function WritePrivateProfileStringW(lpAppName, lpKeyName, lpString, lpFileName: PWideChar): BOOL; stdcall;
function WritePrivateProfileString(lpAppName, lpKeyName, lpString, lpFileName: PTChar): BOOL; stdcall;
function GetPrivateProfileSectionA(lpAppName: PAnsiChar; lpReturnedString: PAnsiChar; nSize: DWORD; lpFileName: PAnsiChar): DWORD; stdcall;
function GetPrivateProfileSectionW(lpAppName: PWideChar; lpReturnedString: PWideChar; nSize: DWORD; lpFileName: PWideChar): DWORD; stdcall;
function GetPrivateProfileSection(lpAppName: PTChar; lpReturnedString: PTChar; nSize: DWORD; lpFileName: PTChar): DWORD; stdcall;
function WritePrivateProfileSectionA(lpAppName, lpString, lpFileName: PAnsiChar): BOOL; stdcall;
function WritePrivateProfileSectionW(lpAppName, lpString, lpFileName: PWideChar): BOOL; stdcall;
function WritePrivateProfileSection(lpAppName, lpString, lpFileName: PTChar): BOOL; stdcall;
function GetPrivateProfileSectionNamesA(lpszReturnBuffer: PAnsiChar; nSize: DWORD; lpFileName: PAnsiChar): DWORD; stdcall;
function GetPrivateProfileSectionNamesW(lpszReturnBuffer: PWideChar; nSize: DWORD; lpFileName: PWideChar): DWORD; stdcall;
function GetPrivateProfileSectionNames(lpszReturnBuffer: PTChar; nSize: DWORD; lpFileName: PTChar): DWORD; stdcall;
function GetPrivateProfileStructA(lpszSection, lpszKey: PAnsiChar;
  lpStruct: Pointer; uSizeStruct: UINT; szFile: PAnsiChar): BOOL; stdcall;
function GetPrivateProfileStructW(lpszSection, lpszKey: PWideChar;
  lpStruct: Pointer; uSizeStruct: UINT; szFile: PWideChar): BOOL; stdcall;
function GetPrivateProfileStruct(lpszSection, lpszKey: PTChar;
  lpStruct: Pointer; uSizeStruct: UINT; szFile: PTChar): BOOL; stdcall;
function WritePrivateProfileStructA(lpszSection, lpszKey: PAnsiChar;
  lpStruct: Pointer; uSizeStruct: UINT; szFile: PAnsiChar): BOOL; stdcall;
function WritePrivateProfileStructW(lpszSection, lpszKey: PWideChar;
  lpStruct: Pointer; uSizeStruct: UINT; szFile: PWideChar): BOOL; stdcall;
function WritePrivateProfileStruct(lpszSection, lpszKey: PTChar;
  lpStruct: Pointer; uSizeStruct: UINT; szFile: PTChar): BOOL; stdcall;
function GetDriveTypeA(lpRootPathName: PAnsiChar): UINT; stdcall;
function GetDriveTypeW(lpRootPathName: PWideChar): UINT; stdcall;
function GetDriveType(lpRootPathName: PTChar): UINT; stdcall;
function GetSystemDirectoryA(lpBuffer: PAnsiChar; uSize: UINT): UINT; stdcall;
function GetSystemDirectoryW(lpBuffer: PWideChar; uSize: UINT): UINT; stdcall;
function GetSystemDirectory(lpBuffer: PTChar; uSize: UINT): UINT; stdcall;
function GetTempPathA(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall;
function GetTempPathW(nBufferLength: DWORD; lpBuffer: PWideChar): DWORD; stdcall;
function GetTempPath(nBufferLength: DWORD; lpBuffer: PTChar): DWORD; stdcall;
function GetTempFileNameA(lpPathName, lpPrefixString: PAnsiChar;
  uUnique: UINT; lpTempFileName: PAnsiChar): UINT; stdcall;
function GetTempFileNameW(lpPathName, lpPrefixString: PWideChar;
  uUnique: UINT; lpTempFileName: PWideChar): UINT; stdcall;
function GetTempFileName(lpPathName, lpPrefixString: PTChar;
  uUnique: UINT; lpTempFileName: PTChar): UINT; stdcall;
function GetWindowsDirectoryA(lpBuffer: PAnsiChar; uSize: UINT): UINT; stdcall;
function GetWindowsDirectoryW(lpBuffer: PWideChar; uSize: UINT): UINT; stdcall;
function GetWindowsDirectory(lpBuffer: PTChar; uSize: UINT): UINT; stdcall;
function SetCurrentDirectoryA(lpPathName: PAnsiChar): BOOL; stdcall;
function SetCurrentDirectoryW(lpPathName: PWideChar): BOOL; stdcall;
function SetCurrentDirectory(lpPathName: PTChar): BOOL; stdcall;
function GetCurrentDirectoryA(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall;
function GetCurrentDirectoryW(nBufferLength: DWORD; lpBuffer: PWideChar): DWORD; stdcall;
function GetCurrentDirectory(nBufferLength: DWORD; lpBuffer: PTChar): DWORD; stdcall;
function GetDiskFreeSpaceA(lpRootPathName: PAnsiChar;
  var lpSectorsPerCluster, lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters: DWORD): BOOL; stdcall;
function GetDiskFreeSpaceW(lpRootPathName: PWideChar;
  var lpSectorsPerCluster, lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters: DWORD): BOOL; stdcall;
function GetDiskFreeSpace(lpRootPathName: PTChar;
  var lpSectorsPerCluster, lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters: DWORD): BOOL; stdcall;
function GetDiskFreeSpaceExA(lpDirectoryName: PAnsiChar;
  var lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes; lpTotalNumberOfFreeBytes: PLargeInteger): BOOL; stdcall;
function GetDiskFreeSpaceExW(lpDirectoryName: PWideChar;
  var lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes; lpTotalNumberOfFreeBytes: PLargeInteger): BOOL; stdcall;
function GetDiskFreeSpaceEx(lpDirectoryName: PTChar;
  var lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes; lpTotalNumberOfFreeBytes: PLargeInteger): BOOL; stdcall;
function CreateDirectoryA(lpPathName: PAnsiChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateDirectoryW(lpPathName: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateDirectory(lpPathName: PTChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateDirectoryExA(lpTemplateDirectory, lpNewDirectory: PAnsiChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateDirectoryExW(lpTemplateDirectory, lpNewDirectory: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateDirectoryEx(lpTemplateDirectory, lpNewDirectory: PTChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function RemoveDirectoryA(lpPathName: PAnsiChar): BOOL; stdcall;
function RemoveDirectoryW(lpPathName: PWideChar): BOOL; stdcall;
function RemoveDirectory(lpPathName: PTChar): BOOL; stdcall;
function GetFullPathNameA(lpFileName: PAnsiChar; nBufferLength: DWORD;
  lpBuffer: PAnsiChar; var lpFilePart: PAnsiChar): DWORD; stdcall;
function GetFullPathNameW(lpFileName: PWideChar; nBufferLength: DWORD;
  lpBuffer: PWideChar; var lpFilePart: PWideChar): DWORD; stdcall;
function GetFullPathName(lpFileName: PTChar; nBufferLength: DWORD;
  lpBuffer: PTChar; var lpFilePart: PTChar): DWORD; stdcall;

const
  DDD_RAW_TARGET_PATH             = $00000001;
  DDD_REMOVE_DEFINITION           = $00000002;
  DDD_EXACT_MATCH_ON_REMOVE       = $00000004;
  DDD_NO_BROADCAST_SYSTEM         = $00000008;

function DefineDosDeviceA(dwFlags: DWORD; lpDeviceName, lpTargetPath: PAnsiChar): BOOL; stdcall;
function DefineDosDeviceW(dwFlags: DWORD; lpDeviceName, lpTargetPath: PWideChar): BOOL; stdcall;
function DefineDosDevice(dwFlags: DWORD; lpDeviceName, lpTargetPath: PTChar): BOOL; stdcall;
function QueryDosDeviceA(lpDeviceName: PAnsiChar; lpTargetPath: PAnsiChar; ucchMax: DWORD): DWORD; stdcall;
function QueryDosDeviceW(lpDeviceName: PWideChar; lpTargetPath: PWideChar; ucchMax: DWORD): DWORD; stdcall;
function QueryDosDevice(lpDeviceName: PTChar; lpTargetPath: PTChar; ucchMax: DWORD): DWORD; stdcall;
function CreateFileA(lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
function CreateFileW(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
function CreateFile(lpFileName: PTChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
function SetFileAttributesA(lpFileName: PAnsiChar; dwFileAttributes: DWORD): BOOL; stdcall;
function SetFileAttributesW(lpFileName: PWideChar; dwFileAttributes: DWORD): BOOL; stdcall;
function SetFileAttributes(lpFileName: PTChar; dwFileAttributes: DWORD): BOOL; stdcall;
function GetFileAttributesA(lpFileName: PAnsiChar): DWORD; stdcall;
function GetFileAttributesW(lpFileName: PWideChar): DWORD; stdcall;
function GetFileAttributes(lpFileName: PTChar): DWORD; stdcall;
type
  _GET_FILEEX_INFO_LEVELS = (GetFileExInfoStandard, GetFileExMaxInfoLevel);
  TGetFileExInfoLevels = _GET_FILEEX_INFO_LEVELS;
  GET_FILEEX_INFO_LEVELS = _GET_FILEEX_INFO_LEVELS;
function GetFileAttributesExA(lpFileName: PAnsiChar;
  fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
function GetFileAttributesExW(lpFileName: PWideChar;
  fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
function GetFileAttributesEx(lpFileName: PTChar;
  fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
function GetCompressedFileSizeA(lpFileName: PAnsiChar; lpFileSizeHigh: PDWORD): DWORD; stdcall;
function GetCompressedFileSizeW(lpFileName: PWideChar; lpFileSizeHigh: PDWORD): DWORD; stdcall;
function GetCompressedFileSize(lpFileName: PTChar; lpFileSizeHigh: PDWORD): DWORD; stdcall;
function DeleteFileA(lpFileName: PAnsiChar): BOOL; stdcall;
function DeleteFileW(lpFileName: PWideChar): BOOL; stdcall;
function DeleteFile(lpFileName: PTChar): BOOL; stdcall;
type
  _FINDEX_INFO_LEVELS = (FindExInfoStandard, FindExInfoMaxInfoLevel);
  TFindexInfoLevels = _FINDEX_INFO_LEVELS;
  FINDEX_INFO_LEVELS = _FINDEX_INFO_LEVELS;

  _FINDEX_SEARCH_OPS = (FindExSearchNameMatch, FindExSearchLimitToDirectories,
    FindExSearchLimitToDevices, FindExSearchMaxSearchOp);
  TFindexSearchOps = _FINDEX_SEARCH_OPS;
  FINDEX_SEARCH_OPS = _FINDEX_SEARCH_OPS;
const
  FIND_FIRST_EX_CASE_SENSITIVE = $00000001;

function FindFirstFileExA(lpFileName: PAnsiChar; fInfoLevelId: TFindexInfoLevels;
  lpFindFileData: Pointer; fSearchOp: TFindexSearchOps; lpSearchFilter: Pointer;
  dwAdditionalFlags: DWORD): BOOL; stdcall;
function FindFirstFileExW(lpFileName: PWideChar; fInfoLevelId: TFindexInfoLevels;
  lpFindFileData: Pointer; fSearchOp: TFindexSearchOps; lpSearchFilter: Pointer;
  dwAdditionalFlags: DWORD): BOOL; stdcall;
function FindFirstFileEx(lpFileName: PTChar; fInfoLevelId: TFindexInfoLevels;
  lpFindFileData: Pointer; fSearchOp: TFindexSearchOps; lpSearchFilter: Pointer;
  dwAdditionalFlags: DWORD): BOOL; stdcall;
function FindFirstFileA(lpFileName: PAnsiChar; var lpFindFileData: TWIN32FindDataA): THandle; stdcall;
function FindFirstFileW(lpFileName: PWideChar; var lpFindFileData: TWIN32FindDataW): THandle; stdcall;
function FindFirstFile(lpFileName: PTChar; var lpFindFileData: TWIN32FindData): THandle; stdcall;
function FindNextFileA(hFindFile: THandle; var lpFindFileData: TWIN32FindDataA): BOOL; stdcall;
function FindNextFileW(hFindFile: THandle; var lpFindFileData: TWIN32FindDataW): BOOL; stdcall;
function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall;
function SearchPathA(lpPath, lpFileName, lpExtension: PAnsiChar;
  nBufferLength: DWORD; lpBuffer: PAnsiChar; var lpFilePart: PAnsiChar): DWORD; stdcall;
function SearchPathW(lpPath, lpFileName, lpExtension: PWideChar;
  nBufferLength: DWORD; lpBuffer: PWideChar; var lpFilePart: PWideChar): DWORD; stdcall;
function SearchPath(lpPath, lpFileName, lpExtension: PTChar;
  nBufferLength: DWORD; lpBuffer: PTChar; var lpFilePart: PTChar): DWORD; stdcall;
function CopyFileA(lpExistingFileName, lpNewFileName: PAnsiChar; bFailIfExists: BOOL): BOOL; stdcall;
function CopyFileW(lpExistingFileName, lpNewFileName: PWideChar; bFailIfExists: BOOL): BOOL; stdcall;
function CopyFile(lpExistingFileName, lpNewFileName: PTChar; bFailIfExists: BOOL): BOOL; stdcall;

type
  TFNProgressRoutine = TFarProc;


function CopyFileExA(lpExistingFileName, lpNewFileName: PAnsiChar;
  lpProgressRoutine: TFNProgressRoutine; lpData: Pointer; pbCancel: PBool;
  dwCopyFlags: DWORD): BOOL; stdcall;
function CopyFileExW(lpExistingFileName, lpNewFileName: PWideChar;
  lpProgressRoutine: TFNProgressRoutine; lpData: Pointer; pbCancel: PBool;
  dwCopyFlags: DWORD): BOOL; stdcall;
function CopyFileEx(lpExistingFileName, lpNewFileName: PTChar;
  lpProgressRoutine: TFNProgressRoutine; lpData: Pointer; pbCancel: PBool;
  dwCopyFlags: DWORD): BOOL; stdcall;
function MoveFileA(lpExistingFileName, lpNewFileName: PAnsiChar): BOOL; stdcall;
function MoveFileW(lpExistingFileName, lpNewFileName: PWideChar): BOOL; stdcall;
function MoveFile(lpExistingFileName, lpNewFileName: PTChar): BOOL; stdcall;
function MoveFileExA(lpExistingFileName, lpNewFileName: PAnsiChar; dwFlags: DWORD): BOOL; stdcall;
function MoveFileExW(lpExistingFileName, lpNewFileName: PWideChar; dwFlags: DWORD): BOOL; stdcall;
function MoveFileEx(lpExistingFileName, lpNewFileName: PTChar; dwFlags: DWORD): BOOL; stdcall;
function MoveFileWithProgressA(lpExistingFileName, lpNewFileName: PAnsiChar; lpProgressRoutine: TFNProgressRoutine;
  lpData: Pointer; dwFlags: DWORD): BOOL; stdcall;
function MoveFileWithProgressW(lpExistingFileName, lpNewFileName: PWideChar; lpProgressRoutine: TFNProgressRoutine;
  lpData: Pointer; dwFlags: DWORD): BOOL; stdcall;
function MoveFileWithProgress(lpExistingFileName, lpNewFileName: PTChar; lpProgressRoutine: TFNProgressRoutine;
  lpData: Pointer; dwFlags: DWORD): BOOL; stdcall;

const
  MOVEFILE_REPLACE_EXISTING       = $00000001;
  MOVEFILE_COPY_ALLOWED           = $00000002;
  MOVEFILE_DELAY_UNTIL_REBOOT     = $00000004;
  MOVEFILE_WRITE_THROUGH          = $00000008;
  MOVEFILE_CREATE_HARDLINK        = $00000010;
  MOVEFILE_FAIL_IF_NOT_TRACKABLE  = $00000020;

function CreateHardLinkA(lpFileName, lpExistingFileName: PAnsiChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateHardLinkW(lpFileName, lpExistingFileName: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateHardLink(lpFileName, lpExistingFileName: PTChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CreateNamedPipeA(lpName: PAnsiChar;
  dwOpenMode, dwPipeMode, nMaxInstances, nOutBufferSize, nInBufferSize, nDefaultTimeOut: DWORD;
  lpSecurityAttributes: PSecurityAttributes): THandle; stdcall;
function CreateNamedPipeW(lpName: PWideChar;
  dwOpenMode, dwPipeMode, nMaxInstances, nOutBufferSize, nInBufferSize, nDefaultTimeOut: DWORD;
  lpSecurityAttributes: PSecurityAttributes): THandle; stdcall;
function CreateNamedPipe(lpName: PTChar;
  dwOpenMode, dwPipeMode, nMaxInstances, nOutBufferSize, nInBufferSize, nDefaultTimeOut: DWORD;
  lpSecurityAttributes: PSecurityAttributes): THandle; stdcall;
function GetNamedPipeHandleStateA(hNamedPipe: THandle;
  lpState, lpCurInstances, lpMaxCollectionCount, lpCollectDataTimeout: PDWORD;
  lpUserName: PAnsiChar; nMaxUserNameSize: DWORD): BOOL; stdcall;
function GetNamedPipeHandleStateW(hNamedPipe: THandle;
  lpState, lpCurInstances, lpMaxCollectionCount, lpCollectDataTimeout: PDWORD;
  lpUserName: PWideChar; nMaxUserNameSize: DWORD): BOOL; stdcall;
function GetNamedPipeHandleState(hNamedPipe: THandle;
  lpState, lpCurInstances, lpMaxCollectionCount, lpCollectDataTimeout: PDWORD;
  lpUserName: PTChar; nMaxUserNameSize: DWORD): BOOL; stdcall;
function CallNamedPipeA(lpNamedPipeName: PAnsiChar; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  var lpBytesRead: DWORD; nTimeOut: DWORD): BOOL; stdcall;
function CallNamedPipeW(lpNamedPipeName: PWideChar; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  var lpBytesRead: DWORD; nTimeOut: DWORD): BOOL; stdcall;
function CallNamedPipe(lpNamedPipeName: PTChar; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  var lpBytesRead: DWORD; nTimeOut: DWORD): BOOL; stdcall;
function WaitNamedPipeA(lpNamedPipeName: PAnsiChar; nTimeOut: DWORD): BOOL; stdcall;
function WaitNamedPipeW(lpNamedPipeName: PWideChar; nTimeOut: DWORD): BOOL; stdcall;
function WaitNamedPipe(lpNamedPipeName: PTChar; nTimeOut: DWORD): BOOL; stdcall;
function SetVolumeLabelA(lpRootPathName: PAnsiChar; lpVolumeName: PAnsiChar): BOOL; stdcall;
function SetVolumeLabelW(lpRootPathName: PWideChar; lpVolumeName: PAnsiChar): BOOL; stdcall;
function SetVolumeLabel(lpRootPathName: PTChar; lpVolumeName: PAnsiChar): BOOL; stdcall;
procedure SetFileApisToOEM; stdcall;
procedure SetFileApisToANSI; stdcall;
function AreFileApisANSI: BOOL; stdcall;
function GetVolumeInformationA(lpRootPathName: PAnsiChar;
  lpVolumeNameBuffer: PAnsiChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PAnsiChar; nFileSystemNameSize: DWORD): BOOL; stdcall;
function GetVolumeInformationW(lpRootPathName: PWideChar;
  lpVolumeNameBuffer: PWideChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PWideChar; nFileSystemNameSize: DWORD): BOOL; stdcall;
function GetVolumeInformation(lpRootPathName: PTChar;
  lpVolumeNameBuffer: PTChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PTChar; nFileSystemNameSize: DWORD): BOOL; stdcall;

function CancelIo(hFile: THandle): BOOL; stdcall;

{ Event logging APIs }

function ClearEventLogA(hEventLog: THandle; lpBackupFileName: PAnsiChar): BOOL; stdcall;
function ClearEventLogW(hEventLog: THandle; lpBackupFileName: PWideChar): BOOL; stdcall;
function ClearEventLog(hEventLog: THandle; lpBackupFileName: PTChar): BOOL; stdcall;
function BackupEventLogA(hEventLog: THandle; lpBackupFileName: PAnsiChar): BOOL; stdcall;
function BackupEventLogW(hEventLog: THandle; lpBackupFileName: PWideChar): BOOL; stdcall;
function BackupEventLog(hEventLog: THandle; lpBackupFileName: PTChar): BOOL; stdcall;
function CloseEventLog(hEventLog: THandle): BOOL; stdcall;
function DeregisterEventSource(hEventLog: THandle): BOOL; stdcall;
function NotifyChangeEventLog(hEventLog, hEvent: THandle): BOOL; stdcall;
function GetNumberOfEventLogRecords(hEventLog: THandle; var NumberOfRecords: DWORD): BOOL; stdcall;
function GetOldestEventLogRecord(hEventLog: THandle; var OldestRecord: DWORD): BOOL; stdcall;
function OpenEventLogA(lpUNCServerName, lpSourceName: PAnsiChar): THandle; stdcall;
function OpenEventLogW(lpUNCServerName, lpSourceName: PWideChar): THandle; stdcall;
function OpenEventLog(lpUNCServerName, lpSourceName: PTChar): THandle; stdcall;
function RegisterEventSourceA(lpUNCServerName, lpSourceName: PAnsiChar): THandle; stdcall;
function RegisterEventSourceW(lpUNCServerName, lpSourceName: PWideChar): THandle; stdcall;
function RegisterEventSource(lpUNCServerName, lpSourceName: PTChar): THandle; stdcall;
function OpenBackupEventLogA(lpUNCServerName, lpFileName: PAnsiChar): THandle; stdcall;
function OpenBackupEventLogW(lpUNCServerName, lpFileName: PWideChar): THandle; stdcall;
function OpenBackupEventLog(lpUNCServerName, lpFileName: PTChar): THandle; stdcall;
function ReadEventLogA(hEventLog: THandle; dwReadFlags, dwRecordOffset: DWORD;
  lpBuffer: Pointer; nNumberOfBytesToRead: DWORD;
  var pnBytesRead, pnMinNumberOfBytesNeeded: DWORD): BOOL; stdcall;
function ReadEventLogW(hEventLog: THandle; dwReadFlags, dwRecordOffset: DWORD;
  lpBuffer: Pointer; nNumberOfBytesToRead: DWORD;
  var pnBytesRead, pnMinNumberOfBytesNeeded: DWORD): BOOL; stdcall;
function ReadEventLog(hEventLog: THandle; dwReadFlags, dwRecordOffset: DWORD;
  lpBuffer: Pointer; nNumberOfBytesToRead: DWORD;
  var pnBytesRead, pnMinNumberOfBytesNeeded: DWORD): BOOL; stdcall;
function ReportEventA(hEventLog: THandle; wType, wCategory: Word;
  dwEventID: DWORD; lpUserSid: Pointer; wNumStrings: Word;
  dwDataSize: DWORD; lpStrings, lpRawData: Pointer): BOOL; stdcall;
function ReportEventW(hEventLog: THandle; wType, wCategory: Word;
  dwEventID: DWORD; lpUserSid: Pointer; wNumStrings: Word;
  dwDataSize: DWORD; lpStrings, lpRawData: Pointer): BOOL; stdcall;
function ReportEvent(hEventLog: THandle; wType, wCategory: Word;
  dwEventID: DWORD; lpUserSid: Pointer; wNumStrings: Word;
  dwDataSize: DWORD; lpStrings, lpRawData: Pointer): BOOL; stdcall;

{ Security APIs }

function DuplicateToken(ExistingTokenHandle: THandle;
  ImpersonationLevel: TSecurityImpersonationLevel; DuplicateTokenHandle: PHandle): BOOL; stdcall;
function GetKernelObjectSecurity(Handle: THandle; RequestedInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor; nLength: DWORD;
  var lpnLengthNeeded: DWORD): BOOL; stdcall;
function ImpersonateNamedPipeClient(hNamedPipe: THandle): BOOL; stdcall;
function ImpersonateSelf(ImpersonationLevel: TSecurityImpersonationLevel): BOOL; stdcall;
function RevertToSelf: BOOL; stdcall;
function SetThreadToken(Thread: PHandle; Token: THandle): BOOL; stdcall;
function AccessCheck(pSecurityDescriptor: PSecurityDescriptor;
  ClientToken: THandle; DesiredAccess: DWORD; const GenericMapping: TGenericMapping;
  var PrivilegeSet: TPrivilegeSet; var PrivilegeSetLength: DWORD;
  var GrantedAccess: DWORD; var AccessStatus: BOOL): BOOL; stdcall;
function AccessCheckByType(pSecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID;
  ClientToken: THandle; DesiredAccess: DWORD; ObjectTypeList: PObjectTypeList;
  const GenericMapping: TGenericMapping; ObjectTypeListLength: DWORD;
  var PrivilegeSet: TPrivilegeSet; var PrivilegeSetLength: DWORD;
  var GrantedAccess: DWORD; var AccessStatus: BOOL): BOOL; stdcall;
function AccessCheckByTypeResultList(pSecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID;
  ClientToken: THandle; DesiredAccess: DWORD; ObjectTypeList: PObjectTypeList;
  const GenericMapping: TGenericMapping; ObjectTypeListLength: DWORD;
  var PrivilegeSet: TPrivilegeSet; var PrivilegeSetLength: DWORD;
  var GrantedAccess: DWORD; var AccessStatusList: DWORD): BOOL; stdcall;
function OpenProcessToken(ProcessHandle: THandle; DesiredAccess: DWORD;
  var TokenHandle: THandle): BOOL; stdcall;
function OpenThreadToken(ThreadHandle: THandle; DesiredAccess: DWORD;
  OpenAsSelf: BOOL; var TokenHandle: THandle): BOOL; stdcall;
function GetTokenInformation(TokenHandle: THandle;
  TokenInformationClass: TTokenInformationClass; TokenInformation: Pointer;
  TokenInformationLength: DWORD; var ReturnLength: DWORD): BOOL; stdcall;
function SetTokenInformation(TokenHandle: THandle;
  TokenInformationClass: TTokenInformationClass; TokenInformation: Pointer;
  TokenInformationLength: DWORD): BOOL; stdcall;
function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  var PreviousState: TTokenPrivileges; var ReturnLength: DWORD): BOOL; stdcall; {$ifdef bDelphi5} overload;
function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  PreviousState: PTokenPrivileges; var ReturnLength: DWORD): BOOL; stdcall; overload; {$endif bDelphi5}
function AdjustTokenGroups(TokenHandle: THandle; ResetToDefault: BOOL;
  const NewState: TTokenGroups; BufferLength: DWORD;
  var PreviousState: TTokenGroups; var ReturnLength: DWORD): BOOL; stdcall;
function PrivilegeCheck(ClientToken: THandle; const RequiredPrivileges: TPrivilegeSet;
  var pfResult: BOOL): BOOL; stdcall;
function AccessCheckAndAuditAlarmA(SubsystemName: PAnsiChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PAnsiChar;
  SecurityDescriptor: PSecurityDescriptor; DesiredAccess: DWORD;
  const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatus, pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckAndAuditAlarmW(SubsystemName: PWideChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PWideChar;
  SecurityDescriptor: PSecurityDescriptor; DesiredAccess: DWORD;
  const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatus, pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckAndAuditAlarm(SubsystemName: PTChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PTChar;
  SecurityDescriptor: PSecurityDescriptor; DesiredAccess: DWORD;
  const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatus, pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckByTypeAndAuditAlarmA(SubsystemName: PAnsiChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PAnsiChar;
  SecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID; DesiredAccess: DWORD;
  AuditType: AUDIT_EVENT_TYPE; Flags: DWORD; ObjectTypeList: PObjectTypeList;
  ObjectTypeListLength: DWORD; const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatus, pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckByTypeAndAuditAlarmW(SubsystemName: PWideChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PWideChar;
  SecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID; DesiredAccess: DWORD;
  AuditType: AUDIT_EVENT_TYPE; Flags: DWORD; ObjectTypeList: PObjectTypeList;
  ObjectTypeListLength: DWORD; const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatus, pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckByTypeAndAuditAlarm(SubsystemName: PTChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PTChar;
  SecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID; DesiredAccess: DWORD;
  AuditType: AUDIT_EVENT_TYPE; Flags: DWORD; ObjectTypeList: PObjectTypeList;
  ObjectTypeListLength: DWORD; const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatus, pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckByTypeResultListAndAuditAlarmA(SubsystemName: PAnsiChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PAnsiChar;
  SecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID; DesiredAccess: DWORD;
  AuditType: AUDIT_EVENT_TYPE; Flags: DWORD; ObjectTypeList: PObjectTypeList;
  ObjectTypeListLength: DWORD; const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatusList: DWORD; var pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckByTypeResultListAndAuditAlarmW(SubsystemName: PWideChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PWideChar;
  SecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID; DesiredAccess: DWORD;
  AuditType: AUDIT_EVENT_TYPE; Flags: DWORD; ObjectTypeList: PObjectTypeList;
  ObjectTypeListLength: DWORD; const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatusList: DWORD; var pfGenerateOnClose: BOOL): BOOL; stdcall;
function AccessCheckByTypeResultListAndAuditAlarm(SubsystemName: PTChar;
  HandleId: Pointer; ObjectTypeName, ObjectName: PTChar;
  SecurityDescriptor: PSecurityDescriptor; PrincipalSelfSid: PSID; DesiredAccess: DWORD;
  AuditType: AUDIT_EVENT_TYPE; Flags: DWORD; ObjectTypeList: PObjectTypeList;
  ObjectTypeListLength: DWORD; const GenericMapping: TGenericMapping;  ObjectCreation: BOOL;
  var GrantedAccess: DWORD; var AccessStatusList: DWORD; var pfGenerateOnClose: BOOL): BOOL; stdcall;
function ObjectOpenAuditAlarmA(SubsystemName: PAnsiChar; HandleId: Pointer;
  ObjectTypeName: PAnsiChar; ObjectName: PAnsiChar; pSecurityDescriptor: PSecurityDescriptor;
  ClientToken: THandle; DesiredAccess, GrantedAccess: DWORD;
  var Privileges: TPrivilegeSet; ObjectCreation, AccessGranted: BOOL;
  var GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectOpenAuditAlarmW(SubsystemName: PWideChar; HandleId: Pointer;
  ObjectTypeName: PWideChar; ObjectName: PWideChar; pSecurityDescriptor: PSecurityDescriptor;
  ClientToken: THandle; DesiredAccess, GrantedAccess: DWORD;
  var Privileges: TPrivilegeSet; ObjectCreation, AccessGranted: BOOL;
  var GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectOpenAuditAlarm(SubsystemName: PTChar; HandleId: Pointer;
  ObjectTypeName: PTChar; ObjectName: PTChar; pSecurityDescriptor: PSecurityDescriptor;
  ClientToken: THandle; DesiredAccess, GrantedAccess: DWORD;
  var Privileges: TPrivilegeSet; ObjectCreation, AccessGranted: BOOL;
  var GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectPrivilegeAuditAlarmA(SubsystemName: PAnsiChar;
  HandleId: Pointer; ClientToken: THandle; DesiredAccess: DWORD;
  var Privileges: TPrivilegeSet; AccessGranted: BOOL): BOOL; stdcall;
function ObjectPrivilegeAuditAlarmW(SubsystemName: PWideChar;
  HandleId: Pointer; ClientToken: THandle; DesiredAccess: DWORD;
  var Privileges: TPrivilegeSet; AccessGranted: BOOL): BOOL; stdcall;
function ObjectPrivilegeAuditAlarm(SubsystemName: PTChar;
  HandleId: Pointer; ClientToken: THandle; DesiredAccess: DWORD;
  var Privileges: TPrivilegeSet; AccessGranted: BOOL): BOOL; stdcall;
function ObjectCloseAuditAlarmA(SubsystemName: PAnsiChar;
  HandleId: Pointer; GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectCloseAuditAlarmW(SubsystemName: PWideChar;
  HandleId: Pointer; GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectCloseAuditAlarm(SubsystemName: PTChar;
  HandleId: Pointer; GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectDeleteAuditAlarmA(SubsystemName: PAnsiChar;
  HandleId: Pointer; GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectDeleteAuditAlarmW(SubsystemName: PWideChar;
  HandleId: Pointer; GenerateOnClose: BOOL): BOOL; stdcall;
function ObjectDeleteAuditAlarm(SubsystemName: PTChar;
  HandleId: Pointer; GenerateOnClose: BOOL): BOOL; stdcall;
function PrivilegedServiceAuditAlarmA(SubsystemName, ServiceName: PAnsiChar;
  ClientToken: THandle; var Privileges: TPrivilegeSet; AccessGranted: BOOL): BOOL; stdcall;
function PrivilegedServiceAuditAlarmW(SubsystemName, ServiceName: PWideChar;
  ClientToken: THandle; var Privileges: TPrivilegeSet; AccessGranted: BOOL): BOOL; stdcall;
function PrivilegedServiceAuditAlarm(SubsystemName, ServiceName: PTChar;
  ClientToken: THandle; var Privileges: TPrivilegeSet; AccessGranted: BOOL): BOOL; stdcall;
function IsValidSid(pSid: Pointer): BOOL; stdcall;
function EqualSid(pSid1, pSid2: Pointer): BOOL; stdcall;
function EqualPrefixSid(pSid1, pSid2: Pointer): BOOL; stdcall;
function GetSidLengthRequired(nSubAuthorityCount: UCHAR): DWORD; stdcall;
function AllocateAndInitializeSid(const pIdentifierAuthority: TSIDIdentifierAuthority;
  nSubAuthorityCount: Byte; nSubAuthority0, nSubAuthority1: DWORD;
  nSubAuthority2, nSubAuthority3, nSubAuthority4: DWORD;
  nSubAuthority5, nSubAuthority6, nSubAuthority7: DWORD;
  var pSid: Pointer): BOOL; stdcall;
function FreeSid(pSid: Pointer): Pointer; stdcall;
function InitializeSid(Sid: Pointer; const pIdentifierAuthority: TSIDIdentifierAuthority;
  nSubAuthorityCount: Byte): BOOL; stdcall;
function GetSidIdentifierAuthority(pSid: Pointer): PSIDIdentifierAuthority; stdcall;
function GetSidSubAuthority(pSid: Pointer; nSubAuthority: DWORD): PDWORD; stdcall;
function GetSidSubAuthorityCount(pSid: Pointer): PUCHAR; stdcall;
function GetLengthSid(pSid: Pointer): DWORD; stdcall;
function CopySid(nDestinationSidLength: DWORD;
  pDestinationSid, pSourceSid: Pointer): BOOL; stdcall;
function AreAllAccessesGranted(GrantedAccess, DesiredAccess: DWORD): BOOL; stdcall;
function AreAnyAccessesGranted(GrantedAccess, DesiredAccess: DWORD): BOOL; stdcall;
procedure MapGenericMask(var AccessMask: DWORD; const GenericMapping: TGenericMapping); stdcall;
function IsValidAcl(const pAcl: TACL): BOOL; stdcall;
function InitializeAcl(var pAcl: TACL; nAclLength, dwAclRevision: DWORD): BOOL; stdcall;
function GetAclInformation(const pAcl: TACL; pAclInformation: Pointer;
  nAclInformationLength: DWORD; dwAclInformationClass: TAclInformationClass): BOOL; stdcall;
function SetAclInformation(var pAcl: TACL; pAclInformation: Pointer;
  nAclInformationLength: DWORD; dwAclInformationClass: TAclInformationClass): BOOL; stdcall;
function AddAce(var pAcl: TACL; dwAceRevision, dwStartingAceIndex: DWORD; pAceList: Pointer;
  nAceListLength: DWORD): BOOL; stdcall;
function DeleteAce(var pAcl: TACL; dwAceIndex: DWORD): BOOL; stdcall;
function GetAce(const pAcl: TACL; dwAceIndex: DWORD; var pAce: Pointer): BOOL; stdcall;
function AddAccessAllowedAce(var pAcl: TACL; dwAceRevision: DWORD;
  AccessMask: DWORD; pSid: PSID): BOOL; stdcall;
function AddAccessAllowedAceEx(var pAcl: TACL; dwAceRevision: DWORD;
  AceFlags: DWORD; AccessMask: DWORD; pSid: PSID): BOOL; stdcall;
function AddAccessDeniedAce(var pAcl: TACL; dwAceRevision: DWORD;
  AccessMask: DWORD; pSid: PSID): BOOL; stdcall;
function AddAccessDeniedAceEx(var pAcl: TACL; dwAceRevision: DWORD;
  ACEFlags: DWORD; AccessMask: DWORD; pSid: PSID): BOOL; stdcall;
function AddAuditAccessAce(var pAcl: TACL; dwAceRevision: DWORD;
  dwAccessMask: DWORD; pSid: Pointer; bAuditSuccess, bAuditFailure: BOOL): BOOL; stdcall;
function AddAuditAccessAceEx(var pAcl: TACL; dwAceRevision: DWORD;
  AceFlags: DWORD; dwAccessMask: DWORD; pSid: Pointer; bAuditSuccess, bAuditFailure: BOOL): BOOL; stdcall;
function AddAccessAllowedObjectAce(var pAcl: TACL; dwAceRevision: DWORD;
  AceFlags: DWORD; AccessMask: DWORD; ObjectTypeGuid, InheritedObjectTypeGuid: PGuid; pSid: Pointer): BOOL; stdcall;
function AddAccessDeniedObjectAce(var pAcl: TACL; dwAceRevision: DWORD;
  AceFlags: DWORD; AccessMask: DWORD; ObjectTypeGuid, InheritedObjectTypeGuid: PGuid; pSid: Pointer): BOOL; stdcall;
function AddAuditAccessObjectAce(var pAcl: TACL; dwAceRevision: DWORD;
  AceFlags: DWORD; AccessMask: DWORD; ObjectTypeGuid, InheritedObjectTypeGuid: PGuid; pSid: Pointer; bAuditSuccess, bAuditFailure: BOOL): BOOL; stdcall;
function FindFirstFreeAce(var pAcl: TACL; var pAce: Pointer): BOOL; stdcall;
function InitializeSecurityDescriptor(pSecurityDescriptor: PSecurityDescriptor;
  dwRevision: DWORD): BOOL; stdcall;
function IsValidSecurityDescriptor(pSecurityDescriptor: PSecurityDescriptor): BOOL; stdcall;
function GetSecurityDescriptorLength(pSecurityDescriptor: PSecurityDescriptor): DWORD; stdcall;
function GetSecurityDescriptorControl(pSecurityDescriptor: PSecurityDescriptor;
  var pControl: SECURITY_DESCRIPTOR_CONTROL; var lpdwRevision: DWORD): BOOL; stdcall;
function SetSecurityDescriptorControl(pSecurityDescriptor: PSecurityDescriptor;
  ControlBitsOfInterest, ControlBitsToSet: SECURITY_DESCRIPTOR_CONTROL): BOOL; stdcall;
function SetSecurityDescriptorDacl(pSecurityDescriptor: PSecurityDescriptor;
  bDaclPresent: BOOL; pDacl: PACL; bDaclDefaulted: BOOL): BOOL; stdcall;
function GetSecurityDescriptorDacl(pSecurityDescriptor: PSecurityDescriptor;
  var lpbDaclPresent: BOOL; var pDacl: PACL; var lpbDaclDefaulted: BOOL): BOOL; stdcall;
function SetSecurityDescriptorSacl(pSecurityDescriptor: PSecurityDescriptor;
  bSaclPresent: BOOL; pSacl: PACL; bSaclDefaulted: BOOL): BOOL; stdcall;
function GetSecurityDescriptorSacl(pSecurityDescriptor: PSecurityDescriptor;
  var lpbSaclPresent: BOOL; var pSacl: PACL; var lpbSaclDefaulted: BOOL): BOOL; stdcall;
function SetSecurityDescriptorOwner(pSecurityDescriptor: PSecurityDescriptor;
  pOwner: PSID; bOwnerDefaulted: BOOL): BOOL; stdcall;
function GetSecurityDescriptorOwner(pSecurityDescriptor: PSecurityDescriptor;
  var pOwner: PSID; var lpbOwnerDefaulted: BOOL): BOOL; stdcall;
function SetSecurityDescriptorGroup(pSecurityDescriptor: PSecurityDescriptor;
  pGroup: PSID; bGroupDefaulted: BOOL): BOOL; stdcall;
function GetSecurityDescriptorGroup(pSecurityDescriptor: PSecurityDescriptor;
  var pGroup: PSID; var lpbGroupDefaulted: BOOL): BOOL; stdcall;
function CreatePrivateObjectSecurity(ParentDescriptor, CreatorDescriptor: PSecurityDescriptor;
  var NewDescriptor: PSecurityDescriptor; IsDirectoryObject: BOOL;
  Token: THandle; const GenericMapping: TGenericMapping): BOOL; stdcall;
function ConvertToAutoInheritPrivateObjectSecurity(ParentDescriptor, CurrentSecurityDescriptor: PSecurityDescriptor;
  var NewDescriptor: PSecurityDescriptor; ObjectType: PGUID;
  IsDirectoryObject: BOOL; const GenericMapping: TGenericMapping): BOOL; stdcall;
function CreatePrivateObjectSecurityEx(ParentDescriptor, CreatorDescriptor: PSecurityDescriptor;
  var NewDescriptor: PSecurityDescriptor; ObjectType: PGUID; IsContainerObject: BOOL;
  AutoInheritFlags: ULONG; Token: THandle; const GenericMapping: TGenericMapping): BOOL; stdcall;
function SetPrivateObjectSecurity(SecurityInformation: SECURITY_INFORMATION;
  ModificationDescriptor: PSecurityDescriptor; var ObjectsSecurityDescriptor: PSecurityDescriptor;
  const GenericMapping: TGenericMapping; Token: THandle): BOOL; stdcall;
function SetPrivateObjectSecurityEx(SecurityInformation: SECURITY_INFORMATION;
  ModificationDescriptor: PSecurityDescriptor; var ObjectsSecurityDescriptor: PSecurityDescriptor;
  AutoInheritFlags: ULONG; const GenericMapping: TGenericMapping; Token: THandle): BOOL; stdcall;
function GetPrivateObjectSecurity(ObjectDescriptor: PSecurityDescriptor;
  SecurityInformation: SECURITY_INFORMATION; ResultantDescriptor: PSecurityDescriptor;
  DescriptorLength: DWORD; var ReturnLength: DWORD): BOOL; stdcall;
function DestroyPrivateObjectSecurity(var ObjectDescriptor: PSecurityDescriptor): BOOL; stdcall;
function MakeSelfRelativeSD(pAbsoluteSecurityDescriptor: PSecurityDescriptor;
  pSelfRelativeSecurityDescriptor: PSecurityDescriptor; var lpdwBufferLength: DWORD): BOOL; stdcall;
function MakeAbsoluteSD(pSelfRelativeSecurityDescriptor: PSecurityDescriptor;
  pAbsoluteSecurityDescriptor: PSecurityDescriptor; var lpdwAbsoluteSecurityDescriptorSi: DWORD;
  var pDacl: TACL; var lpdwDaclSize: DWORD; var pSacl: TACL;
  var lpdwSaclSize: DWORD; pOwner: PSID; var lpdwOwnerSize: DWORD;
  pPrimaryGroup: Pointer; var lpdwPrimaryGroupSize: DWORD): BOOL; stdcall;

function SetFileSecurityA(lpFileName: PAnsiChar; SecurityInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor): BOOL; stdcall;
function SetFileSecurityW(lpFileName: PWideChar; SecurityInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor): BOOL; stdcall;
function SetFileSecurity(lpFileName: PTChar; SecurityInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor): BOOL; stdcall;
function GetFileSecurityA(lpFileName: PAnsiChar; RequestedInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor; nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function GetFileSecurityW(lpFileName: PWideChar; RequestedInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor; nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function GetFileSecurity(lpFileName: PTChar; RequestedInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor; nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function SetKernelObjectSecurity(Handle: THandle; SecurityInformation: SECURITY_INFORMATION;
  SecurityDescriptor: PSecurityDescriptor): BOOL; stdcall;
function FindFirstChangeNotificationA(lpPathName: PAnsiChar;
  bWatchSubtree: BOOL; dwNotifyFilter: DWORD): THandle; stdcall;
function FindFirstChangeNotificationW(lpPathName: PWideChar;
  bWatchSubtree: BOOL; dwNotifyFilter: DWORD): THandle; stdcall;
function FindFirstChangeNotification(lpPathName: PTChar;
  bWatchSubtree: BOOL; dwNotifyFilter: DWORD): THandle; stdcall;
function FindNextChangeNotification(hChangeHandle: THandle): BOOL; stdcall;
function FindCloseChangeNotification(hChangeHandle: THandle): BOOL; stdcall;
function ReadDirectoryChanges(hDirectory: THandle; lpBuffer: Pointer;
  nBufferLength: DWORD; bWatchSubtree: Bool; dwNotifyFilter: DWORD;
  lpBytesReturned: LPDWORD; lpOverlapped: POverlapped;
  lpCompletionRoutine: FARPROC): BOOL; stdcall;
function ReadDirectoryChangesW(hDirectory: THandle; lpBuffer: Pointer;
  nBufferLength: DWORD; bWatchSubtree: Bool; dwNotifyFilter: DWORD;
  lpBytesReturned: LPDWORD; lpOverlapped: POverlapped;
  lpCompletionRoutine: FARPROC): BOOL; stdcall;
function VirtualLock(lpAddress: Pointer; dwSize: DWORD): BOOL; stdcall;
function VirtualUnlock(lpAddress: Pointer; dwSize: DWORD): BOOL; stdcall;
function MapViewOfFileEx(hFileMappingObject: THandle;
  dwDesiredAccess, dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD;
  lpBaseAddress: Pointer): Pointer; stdcall;
function SetPriorityClass(hProcess: THandle; dwPriorityClass: DWORD): BOOL; stdcall;
function GetPriorityClass(hProcess: THandle): DWORD; stdcall;
function IsBadReadPtr(lp: Pointer; ucb: UINT): BOOL; stdcall;
function IsBadWritePtr(lp: Pointer; ucb: UINT): BOOL; stdcall;
function IsBadHugeReadPtr(lp: Pointer; ucb: UINT): BOOL; stdcall;
function IsBadHugeWritePtr(lp: Pointer; ucb: UINT): BOOL; stdcall;
function IsBadCodePtr(lpfn: FARPROC): BOOL; stdcall;
function IsBadStringPtrA(lpsz: PAnsiChar; ucchMax: UINT): BOOL; stdcall;
function IsBadStringPtrW(lpsz: PWideChar; ucchMax: UINT): BOOL; stdcall;
function IsBadStringPtr(lpsz: PTChar; ucchMax: UINT): BOOL; stdcall;
function LookupAccountSidA(lpSystemName: PAnsiChar; Sid: PSID;
  Name: PAnsiChar; var cbName: DWORD; ReferencedDomainName: PAnsiChar;
  var cbReferencedDomainName: DWORD; var peUse: SID_NAME_USE): BOOL; stdcall;
function LookupAccountSidW(lpSystemName: PWideChar; Sid: PSID;
  Name: PWideChar; var cbName: DWORD; ReferencedDomainName: PWideChar;
  var cbReferencedDomainName: DWORD; var peUse: SID_NAME_USE): BOOL; stdcall;
function LookupAccountSid(lpSystemName: PTChar; Sid: PSID;
  Name: PTChar; var cbName: DWORD; ReferencedDomainName: PTChar;
  var cbReferencedDomainName: DWORD; var peUse: SID_NAME_USE): BOOL; stdcall;
function LookupAccountNameA(lpSystemName, lpAccountName: PAnsiChar;
  Sid: PSID; var cbSid: DWORD; ReferencedDomainName: PAnsiChar;
  var cbReferencedDomainName: DWORD; var peUse: SID_NAME_USE): BOOL; stdcall;
function LookupAccountNameW(lpSystemName, lpAccountName: PWideChar;
  Sid: PSID; var cbSid: DWORD; ReferencedDomainName: PWideChar;
  var cbReferencedDomainName: DWORD; var peUse: SID_NAME_USE): BOOL; stdcall;
function LookupAccountName(lpSystemName, lpAccountName: PTChar;
  Sid: PSID; var cbSid: DWORD; ReferencedDomainName: PTChar;
  var cbReferencedDomainName: DWORD; var peUse: SID_NAME_USE): BOOL; stdcall;
function LookupPrivilegeValueA(lpSystemName, lpName: PAnsiChar;
  var lpLuid: TLargeInteger): BOOL; stdcall;
function LookupPrivilegeValueW(lpSystemName, lpName: PWideChar;
  var lpLuid: TLargeInteger): BOOL; stdcall;
function LookupPrivilegeValue(lpSystemName, lpName: PTChar;
  var lpLuid: TLargeInteger): BOOL; stdcall;
function LookupPrivilegeNameA(lpSystemName: PAnsiChar;
  var lpLuid: TLargeInteger; lpName: PAnsiChar; var cbName: DWORD): BOOL; stdcall;
function LookupPrivilegeNameW(lpSystemName: PWideChar;
  var lpLuid: TLargeInteger; lpName: PWideChar; var cbName: DWORD): BOOL; stdcall;
function LookupPrivilegeName(lpSystemName: PTChar;
  var lpLuid: TLargeInteger; lpName: PTChar; var cbName: DWORD): BOOL; stdcall;
function LookupPrivilegeDisplayNameA(lpSystemName, lpName: PAnsiChar;
  lpDisplayName: PAnsiChar; var cbDisplayName, lpLanguageId: DWORD): BOOL; stdcall;
function LookupPrivilegeDisplayNameW(lpSystemName, lpName: PAnsiChar;
  lpDisplayName: PWideChar; var cbDisplayName, lpLanguageId: DWORD): BOOL; stdcall;
function LookupPrivilegeDisplayName(lpSystemName, lpName: PAnsiChar;
  lpDisplayName: PTChar; var cbDisplayName, lpLanguageId: DWORD): BOOL; stdcall;
function AllocateLocallyUniqueId(var Luid: TLargeInteger): BOOL; stdcall;
function BuildCommDCBA(lpDef: PAnsiChar; var lpDCB: TDCB): BOOL; stdcall;
function BuildCommDCBW(lpDef: PWideChar; var lpDCB: TDCB): BOOL; stdcall;
function BuildCommDCB(lpDef: PTChar; var lpDCB: TDCB): BOOL; stdcall;
function BuildCommDCBAndTimeoutsA(lpDef: PAnsiChar; var lpDCB: TDCB;
  var lpCommTimeouts: TCommTimeouts): BOOL; stdcall;
function BuildCommDCBAndTimeoutsW(lpDef: PWideChar; var lpDCB: TDCB;
  var lpCommTimeouts: TCommTimeouts): BOOL; stdcall;
function BuildCommDCBAndTimeouts(lpDef: PTChar; var lpDCB: TDCB;
  var lpCommTimeouts: TCommTimeouts): BOOL; stdcall;
function CommConfigDialogA(lpszName: PAnsiChar; hWnd: HWND; var lpCC: TCommConfig): BOOL; stdcall;
function CommConfigDialogW(lpszName: PWideChar; hWnd: HWND; var lpCC: TCommConfig): BOOL; stdcall;
function CommConfigDialog(lpszName: PTChar; hWnd: HWND; var lpCC: TCommConfig): BOOL; stdcall;
function GetDefaultCommConfigA(lpszName: PAnsiChar;
  var lpCC: TCommConfig; var lpdwSize: DWORD): BOOL; stdcall;
function GetDefaultCommConfigW(lpszName: PWideChar;
  var lpCC: TCommConfig; var lpdwSize: DWORD): BOOL; stdcall;
function GetDefaultCommConfig(lpszName: PTChar;
  var lpCC: TCommConfig; var lpdwSize: DWORD): BOOL; stdcall;
function SetDefaultCommConfigA(lpszName: PAnsiChar; lpCC: PCommConfig; dwSize: DWORD): BOOL; stdcall;
function SetDefaultCommConfigW(lpszName: PWideChar; lpCC: PCommConfig; dwSize: DWORD): BOOL; stdcall;
function SetDefaultCommConfig(lpszName: PTChar; lpCC: PCommConfig; dwSize: DWORD): BOOL; stdcall;

const
  MAX_COMPUTERNAME_LENGTH = 15;

function GetComputerNameA(lpBuffer: PAnsiChar; var nSize: DWORD): BOOL; stdcall;
function GetComputerNameW(lpBuffer: PWideChar; var nSize: DWORD): BOOL; stdcall;
function GetComputerName(lpBuffer: PTChar; var nSize: DWORD): BOOL; stdcall;
function SetComputerNameA(lpComputerName: PAnsiChar): BOOL; stdcall;
function SetComputerNameW(lpComputerName: PWideChar): BOOL; stdcall;
function SetComputerName(lpComputerName: PTChar): BOOL; stdcall;
function GetUserNameA(lpBuffer: PAnsiChar; var nSize: DWORD): BOOL; stdcall;
function GetUserNameW(lpBuffer: PWideChar; var nSize: DWORD): BOOL; stdcall;
function GetUserName(lpBuffer: PTChar; var nSize: DWORD): BOOL; stdcall;

{ Logon Support APIs }

const
  LOGON32_LOGON_INTERACTIVE = 2;
  LOGON32_LOGON_NETWORK = 3;
  LOGON32_LOGON_BATCH = 4;
  LOGON32_LOGON_SERVICE = 5;

  LOGON32_PROVIDER_DEFAULT = 0;
  LOGON32_PROVIDER_WINNT35 = 1;
  LOGON32_PROVIDER_WINNT40 = 2;
  LOGON32_PROVIDER_WINNT50 = 3;

function LogonUserA(lpszUsername, lpszDomain, lpszPassword: PAnsiChar;
  dwLogonType, dwLogonProvider: DWORD; var phToken: THandle): BOOL; stdcall;
function LogonUserW(lpszUsername, lpszDomain, lpszPassword: PWideChar;
  dwLogonType, dwLogonProvider: DWORD; var phToken: THandle): BOOL; stdcall;
function LogonUser(lpszUsername, lpszDomain, lpszPassword: PTChar;
  dwLogonType, dwLogonProvider: DWORD; var phToken: THandle): BOOL; stdcall;
function ImpersonateLoggedOnUser(hToken: THandle): BOOL; stdcall;
function CreateProcessAsUserA(hToken: THandle; lpApplicationName: PAnsiChar;
  lpCommandLine: PAnsiChar; lpProcessAttributes: PSecurityAttributes;
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL;
  dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PAnsiChar;
  const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
function CreateProcessAsUserW(hToken: THandle; lpApplicationName: PWideChar;
  lpCommandLine: PWideChar; lpProcessAttributes: PSecurityAttributes;
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL;
  dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PWideChar;
  const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
function CreateProcessAsUser(hToken: THandle; lpApplicationName: PTChar;
  lpCommandLine: PTChar; lpProcessAttributes: PSecurityAttributes;
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL;
  dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PTChar;
  const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation): BOOL; stdcall;

function DuplicateTokenEx(hExistingToken: THandle; dwDesiredAccess: DWORD;
  lpTokenAttributes: PSecurityAttributes;
  ImpersonationLevel: TSecurityImpersonationLevel; TokenType: TTokenType;
  var phNewToken: THandle): BOOL; stdcall;

{ Plug-and-Play API's }
const
  HW_PROFILE_GUIDLEN = 39;                 { 36-characters plus NULL terminator }
  MAX_PROFILE_LEN = 80;

  DOCKINFO_UNDOCKED = $1;
  DOCKINFO_DOCKED = $2;
  DOCKINFO_USER_SUPPLIED = $4;
  DOCKINFO_USER_UNDOCKED = DOCKINFO_USER_SUPPLIED or DOCKINFO_UNDOCKED;
  DOCKINFO_USER_DOCKED = DOCKINFO_USER_SUPPLIED or DOCKINFO_DOCKED;

type
  PHWProfileInfoA = ^THWProfileInfoA;
  PHWProfileInfoW = ^THWProfileInfoW;
  PHWProfileInfo = PHWProfileInfoA;
  tagHW_PROFILE_INFOA = packed record
    dwDockInfo: DWORD;
    szHwProfileGuid: packed array[0..HW_PROFILE_GUIDLEN-1] of AnsiChar;
    szHwProfileName: packed array[0..MAX_PROFILE_LEN-1] of AnsiChar;
  end;
  tagHW_PROFILE_INFOW = packed record
    dwDockInfo: DWORD;
    szHwProfileGuid: packed array[0..HW_PROFILE_GUIDLEN-1] of WideChar;
    szHwProfileName: packed array[0..MAX_PROFILE_LEN-1] of WideChar;
  end;
  tagHW_PROFILE_INFO = tagHW_PROFILE_INFOA;
  THWProfileInfoA = tagHW_PROFILE_INFOA;
  THWProfileInfoW = tagHW_PROFILE_INFOW;
  THWProfileInfo = THWProfileInfoA;
  HW_PROFILE_INFOA = tagHW_PROFILE_INFOA;
  HW_PROFILE_INFOW = tagHW_PROFILE_INFOW;
  HW_PROFILE_INFO = HW_PROFILE_INFOA;

function GetCurrentHwProfileA(var lpHwProfileInfo: THWProfileInfoA): BOOL; stdcall;
function GetCurrentHwProfileW(var lpHwProfileInfo: THWProfileInfoW): BOOL; stdcall;
function GetCurrentHwProfile(var lpHwProfileInfo: THWProfileInfo): BOOL; stdcall;

{ Performance counter API's }

function QueryPerformanceCounter(var lpPerformanceCount: TLargeInteger): BOOL; stdcall;
function QueryPerformanceFrequency(var lpFrequency: TLargeInteger): BOOL; stdcall;

type
  POSVersionInfoA = ^TOSVersionInfoA;
  POSVersionInfoW = ^TOSVersionInfoW;
  POSVersionInfo = {$ifdef bUnicode}POSVersionInfoW{$else}POSVersionInfoA{$endif bUnicode};

  _OSVERSIONINFOA = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of AnsiChar; { Maintenance string for PSS usage }
  end;
  _OSVERSIONINFOW = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of WideChar; { Maintenance string for PSS usage }
  end;
  _OSVERSIONINFO = {$ifdef bUnicode}_OSVERSIONINFOW{$else}_OSVERSIONINFOA{$endif bUnicode};

  TOSVersionInfoA = _OSVERSIONINFOA;
  TOSVersionInfoW = _OSVERSIONINFOW;
  TOSVersionInfo = {$ifdef bUnicode}TOSVersionInfoW{$else}TOSVersionInfoA{$endif bUnicode};

  OSVERSIONINFOA = _OSVERSIONINFOA;
  OSVERSIONINFOW = _OSVERSIONINFOW;
  OSVERSIONINFO = {$ifdef bUnicode}OSVERSIONINFOW{$else}OSVERSIONINFOA{$endif bUnicode};

{ dwPlatformId defines }
const
  VER_PLATFORM_WIN32s = 0;
  VER_PLATFORM_WIN32_WINDOWS = 1;
  VER_PLATFORM_WIN32_NT = 2;

function GetVersionExA(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall;
function GetVersionExW(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall;
function GetVersionEx(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall;

{ DOS and OS/2 Compatible Error Code definitions returned by the Win32 Base
  API functions. }


{ Translated from WINERROR.H }
{ Error code definitions for the Win32 API functions }

(*
  Values are 32 bit values layed out as follows:
   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
  +---+-+-+-----------------------+-------------------------------+
  |Sev|C|R|     Facility          |               Code            |
  +---+-+-+-----------------------+-------------------------------+

  where
      Sev - is the severity code
          00 - Success
          01 - Informational
          10 - Warning
          11 - Error

      C - is the Customer code flag
      R - is a reserved bit
      Facility - is the facility code
      Code - is the facility's status code
*)

{ Define the facility codes }

const
  FACILITY_WINDOWS                     = 8;
  FACILITY_STORAGE                     = 3;
  FACILITY_RPC                         = 1;
  FACILITY_SSPI                        = 9;
  FACILITY_WIN32                       = 7;
  FACILITY_CONTROL                     = 10;
  FACILITY_NULL                        = 0;
  FACILITY_INTERNET                    = 12;
  FACILITY_ITF                         = 4;
  FACILITY_DISPATCH                    = 2;
  FACILITY_CERT                        = 11;


{ Define the severity codes }

  { The operation completed successfully. }
  ERROR_SUCCESS = 0;
  NO_ERROR = 0;   { dderror }

  { Incorrect function. }
  ERROR_INVALID_FUNCTION = 1;   { dderror }

  { The system cannot find the file specified. }
  ERROR_FILE_NOT_FOUND = 2;

  { The system cannot find the path specified. }
  ERROR_PATH_NOT_FOUND = 3;

  { The system cannot open the file. }
  ERROR_TOO_MANY_OPEN_FILES = 4;

  { Access is denied. }
  ERROR_ACCESS_DENIED = 5;

  { The handle is invalid. }
  ERROR_INVALID_HANDLE = 6;

  { The storage control blocks were destroyed. }
  ERROR_ARENA_TRASHED = 7;

  { Not enough storage is available to process this command. }
  ERROR_NOT_ENOUGH_MEMORY = 8;   { dderror }

  { The storage control block address is invalid. }
  ERROR_INVALID_BLOCK = 9;

  { The environment is incorrect. }
  ERROR_BAD_ENVIRONMENT = 10;

  { An attempt was made to load a program with an incorrect format. }
  ERROR_BAD_FORMAT = 11;

  { The access code is invalid. }
  ERROR_INVALID_ACCESS = 12;

  { The data is invalid. }
  ERROR_INVALID_DATA = 13;

  { Not enough storage is available to complete this operation. }
  ERROR_OUTOFMEMORY = 14;

  { The system cannot find the drive specified. }
  ERROR_INVALID_DRIVE = 15;

  { The directory cannot be removed. }
  ERROR_CURRENT_DIRECTORY = $10;

  { The system cannot move the file }
  { to a different disk drive. }
  ERROR_NOT_SAME_DEVICE = 17;

  { There are no more files. }
  ERROR_NO_MORE_FILES = 18;

  { The media is write protected. }
  ERROR_WRITE_PROTECT = 19;

  { The system cannot find the device specified. }
  ERROR_BAD_UNIT = 20;

  { The device is not ready. }
  ERROR_NOT_READY = 21;

  { The device does not recognize the command. }
  ERROR_BAD_COMMAND = 22;

  { Data error (cyclic redundancy check) }
  ERROR_CRC = 23;

  { The program issued a command but the command length is incorrect. }
  ERROR_BAD_LENGTH = 24;

  { The drive cannot locate a specific area or track on the disk. }
  ERROR_SEEK = 25;

  { The specified disk or diskette cannot be accessed. }
  ERROR_NOT_DOS_DISK = 26;

  { The drive cannot find the sector requested. }
  ERROR_SECTOR_NOT_FOUND = 27;

  { The printer is out of paper. }
  ERROR_OUT_OF_PAPER = 28;

  { The system cannot write to the specified device. }
  ERROR_WRITE_FAULT = 29;

  { The system cannot read from the specified device. }
  ERROR_READ_FAULT = 30;

  { A device attached to the system is not functioning. }
  ERROR_GEN_FAILURE = 31;

  { The process cannot access the file because it is being used by another process. }
  ERROR_SHARING_VIOLATION = $20;

  { The process cannot access the file because }
  { another process has locked a portion of the file. }
  ERROR_LOCK_VIOLATION = 33;

  { The wrong diskette is in the drive. Insert %2 (Volume Serial Number: %3) }
  { into drive %1. }
  ERROR_WRONG_DISK = 34;

  { Too many files opened for sharing. }
  ERROR_SHARING_BUFFER_EXCEEDED = 36;

  { Reached end of file. }
  ERROR_HANDLE_EOF = 38;

  { The disk is full. }
  ERROR_HANDLE_DISK_FULL = 39;

  { The network request is not supported. }
  ERROR_NOT_SUPPORTED = 50;

  { The remote computer is not available. }
  ERROR_REM_NOT_LIST = 51;

  { A duplicate name exists on the network. }
  ERROR_DUP_NAME = 52;

  { The network path was not found. }
  ERROR_BAD_NETPATH = 53;

  { The network is busy. }
  ERROR_NETWORK_BUSY = 54;

  { The specified network resource or device is no longer }
  { available. }
  ERROR_DEV_NOT_EXIST = 55;   { dderror }

  { The network BIOS command limit has been reached. }
  ERROR_TOO_MANY_CMDS = 56;

  { A network adapter hardware error occurred. }
  ERROR_ADAP_HDW_ERR = 57;

  { The specified server cannot perform the requested }
  { operation. }
  ERROR_BAD_NET_RESP = 58;

  { An unexpected network error occurred. }
  ERROR_UNEXP_NET_ERR = 59;

  { The remote adapter is not compatible. }
  ERROR_BAD_REM_ADAP = 60;

  { The printer queue is full. }
  ERROR_PRINTQ_FULL = 61;

  { Space to store the file waiting to be printed is }
  { not available on the server. }
  ERROR_NO_SPOOL_SPACE = 62;

  { Your file waiting to be printed was deleted. }
  ERROR_PRINT_CANCELLED = 63;

  { The specified network name is no longer available. }
  ERROR_NETNAME_DELETED = $40;

  { Network access is denied. }
  ERROR_NETWORK_ACCESS_DENIED = 65;

  { The network resource type is not correct. }
  ERROR_BAD_DEV_TYPE = 66;

  { The network name cannot be found. }
  ERROR_BAD_NET_NAME = 67;

  { The name limit for the local computer network }
  { adapter card was exceeded. }
  ERROR_TOO_MANY_NAMES = 68;

  { The network BIOS session limit was exceeded. }
  ERROR_TOO_MANY_SESS = 69;

  { The remote server has been paused or is in the }
  { process of being started. }
  ERROR_SHARING_PAUSED = 70;

  { No more connections can be made to this remote computer at this time }
  { because there are already as many connections as the computer can accept. }
  ERROR_REQ_NOT_ACCEP = 71;

  { The specified printer or disk device has been paused. }
  ERROR_REDIR_PAUSED = 72;

  { The file exists. }
  ERROR_FILE_EXISTS = 80;

  { The directory or file cannot be created. }
  ERROR_CANNOT_MAKE = 82;

  { Fail on INT 24 }
  ERROR_FAIL_I24 = 83;

  { Storage to process this request is not available. }
  ERROR_OUT_OF_STRUCTURES = 84;

  { The local device name is already in use. }
  ERROR_ALREADY_ASSIGNED = 85;

  { The specified network password is not correct. }
  ERROR_INVALID_PASSWORD = 86;

  { The parameter is incorrect. }
  ERROR_INVALID_PARAMETER = 87;   { dderror }

  { A write fault occurred on the network. }
  ERROR_NET_WRITE_FAULT = 88;

  { The system cannot start another process at }
  { this time. }
  ERROR_NO_PROC_SLOTS = 89;

  { Cannot create another system semaphore. }
  ERROR_TOO_MANY_SEMAPHORES = 100;

  { The exclusive semaphore is owned by another process. }
  ERROR_EXCL_SEM_ALREADY_OWNED = 101;

  { The semaphore is set and cannot be closed. }
  ERROR_SEM_IS_SET = 102;

  { The semaphore cannot be set again. }
  ERROR_TOO_MANY_SEM_REQUESTS = 103;

  { Cannot request exclusive semaphores at interrupt time. }
  ERROR_INVALID_AT_INTERRUPT_TIME = 104;

  { The previous ownership of this semaphore has ended. }
  ERROR_SEM_OWNER_DIED = 105;

  { Insert the diskette for drive %1. }
  ERROR_SEM_USER_LIMIT = 106;

  { Program stopped because alternate diskette was not inserted. }
  ERROR_DISK_CHANGE = 107;

  { The disk is in use or locked by }
  { another process. }
  ERROR_DRIVE_LOCKED = 108;

  { The pipe has been ended. }
  ERROR_BROKEN_PIPE = 109;

  { The system cannot open the device or file specified. }
  ERROR_OPEN_FAILED = 110;

  { The file name is too long. }
  ERROR_BUFFER_OVERFLOW = 111;

  { There is not enough space on the disk. }
  ERROR_DISK_FULL = 112;

  { No more internal file identifiers available. }
  ERROR_NO_MORE_SEARCH_HANDLES = 113;

  { The target internal file identifier is incorrect. }
  ERROR_INVALID_TARGET_HANDLE = 114;

  { The IOCTL call made by the application program is not correct. }
  ERROR_INVALID_CATEGORY = 117;

  { The verify-on-write switch parameter value is not correct. }
  ERROR_INVALID_VERIFY_SWITCH = 118;

  { The system does not support the command requested. }
  ERROR_BAD_DRIVER_LEVEL = 119;

  { This function is only valid in Windows NT mode. }
  ERROR_CALL_NOT_IMPLEMENTED = 120;

  { The semaphore timeout period has expired. }
  ERROR_SEM_TIMEOUT = 121;

  { The data area passed to a system call is too small. }
  ERROR_INSUFFICIENT_BUFFER = 122;   { dderror }

  { The filename, directory name, or volume label syntax is incorrect. }
  ERROR_INVALID_NAME = 123;

  { The system call level is not correct. }
  ERROR_INVALID_LEVEL = 124;

  { The disk has no volume label. }
  ERROR_NO_VOLUME_LABEL = 125;

  { The specified module could not be found. }
  ERROR_MOD_NOT_FOUND = 126;

  { The specified procedure could not be found. }
  ERROR_PROC_NOT_FOUND = 127;

  { There are no child processes to wait for. }
  ERROR_WAIT_NO_CHILDREN = $80;

  { The %1 application cannot be run in Windows NT mode. }
  ERROR_CHILD_NOT_COMPLETE = 129;

  { Attempt to use a file handle to an open disk partition for an }
  { operation other than raw disk I/O. }
  ERROR_DIRECT_ACCESS_HANDLE = 130;

  { An attempt was made to move the file pointer before the beginning of the file. }
  ERROR_NEGATIVE_SEEK = 131;

  { The file pointer cannot be set on the specified device or file. }
  ERROR_SEEK_ON_DEVICE = 132;

  { A JOIN or SUBST command }
  { cannot be used for a drive that }
  { contains previously joined drives. }
  ERROR_IS_JOIN_TARGET = 133;

  { An attempt was made to use a }
  { JOIN or SUBST command on a drive that has }
  { already been joined. }
  ERROR_IS_JOINED = 134;

  { An attempt was made to use a }
  { JOIN or SUBST command on a drive that has }
  { already been substituted. }
  ERROR_IS_SUBSTED = 135;

  { The system tried to delete }
  { the JOIN of a drive that is not joined. }
  ERROR_NOT_JOINED = 136;

  { The system tried to delete the }
  { substitution of a drive that is not substituted. }
  ERROR_NOT_SUBSTED = 137;

  { The system tried to join a drive to a directory on a joined drive. }
  ERROR_JOIN_TO_JOIN = 138;

  { The system tried to substitute a drive to a directory on a substituted drive. }
  ERROR_SUBST_TO_SUBST = 139;

  { The system tried to join a drive to a directory on a substituted drive. }
  ERROR_JOIN_TO_SUBST = 140;

  { The system tried to SUBST a drive to a directory on a joined drive. }
  ERROR_SUBST_TO_JOIN = 141;

  { The system cannot perform a JOIN or SUBST at this time. }
  ERROR_BUSY_DRIVE = 142;

  { The system cannot join or substitute a }
  { drive to or for a directory on the same drive. }
  ERROR_SAME_DRIVE = 143;

  { The directory is not a subdirectory of the root directory. }
  ERROR_DIR_NOT_ROOT = 144;

  { The directory is not empty. }
  ERROR_DIR_NOT_EMPTY = 145;

  { The path specified is being used in a substitute. }
  ERROR_IS_SUBST_PATH = 146;

  { Not enough resources are available to process this command. }
  ERROR_IS_JOIN_PATH = 147;

  { The path specified cannot be used at this time. }
  ERROR_PATH_BUSY = 148;

  { An attempt was made to join or substitute a drive for which a directory }
  { on the drive is the target of a previous substitute. }
  ERROR_IS_SUBST_TARGET = 149;

  { System trace information was not specified in your }
  { CONFIG.SYS file, or tracing is disallowed. }
  ERROR_SYSTEM_TRACE = 150;

  { The number of specified semaphore events for }
  { DosMuxSemWait is not correct. }
  ERROR_INVALID_EVENT_COUNT = 151;

  { DosMuxSemWait did not execute; too many semaphores }
  { are already set. }
  ERROR_TOO_MANY_MUXWAITERS = 152;

  { The DosMuxSemWait list is not correct. }
  ERROR_INVALID_LIST_FORMAT = 153;

  {  The volume label you entered exceeds the label character }
  {  limit of the target file system. }
  ERROR_LABEL_TOO_LONG = 154;

  { Cannot create another thread. }
  ERROR_TOO_MANY_TCBS = 155;

  { The recipient process has refused the signal. }
  ERROR_SIGNAL_REFUSED = 156;

  { The segment is already discarded and cannot be locked. }
  ERROR_DISCARDED = 157;

  { The segment is already unlocked. }
  ERROR_NOT_LOCKED = 158;

  { The address for the thread ID is not correct. }
  ERROR_BAD_THREADID_ADDR = 159;

  { The argument string passed to DosExecPgm is not correct. }
  ERROR_BAD_ARGUMENTS = 160;

  { The specified path is invalid. }
  ERROR_BAD_PATHNAME = 161;

  { A signal is already pending. }
  ERROR_SIGNAL_PENDING = 162;

  { No more threads can be created in the system. }
  ERROR_MAX_THRDS_REACHED = 164;

  { Unable to lock a region of a file. }
  ERROR_LOCK_FAILED = 167;

  { The requested resource is in use. }
  ERROR_BUSY = 170;

  { A lock request was not outstanding for the supplied cancel region. }
  ERROR_CANCEL_VIOLATION = 173;

  { The file system does not support atomic changes to the lock type. }
  ERROR_ATOMIC_LOCKS_NOT_SUPPORTED = 174;

  { The system detected a segment number that was not correct. }
  ERROR_INVALID_SEGMENT_NUMBER = 180;

  { The operating system cannot run %1. }
  ERROR_INVALID_ORDINAL = 182;

  { Cannot create a file when that file already exists. }
  ERROR_ALREADY_EXISTS = 183;

  { The flag passed is not correct. }
  ERROR_INVALID_FLAG_NUMBER = 186;

  { The specified system semaphore name was not found. }
  ERROR_SEM_NOT_FOUND = 187;

  { The operating system cannot run %1. }
  ERROR_INVALID_STARTING_CODESEG = 188;

  { The operating system cannot run %1. }
  ERROR_INVALID_STACKSEG = 189;

  { The operating system cannot run %1. }
  ERROR_INVALID_MODULETYPE = 190;

  { Cannot run %1 in Windows NT mode. }
  ERROR_INVALID_EXE_SIGNATURE = 191;

  { The operating system cannot run %1. }
  ERROR_EXE_MARKED_INVALID = 192;

  { %1 is not a valid Windows NT application. }
  ERROR_BAD_EXE_FORMAT = 193;

  { The operating system cannot run %1. }
  ERROR_ITERATED_DATA_EXCEEDS_64k = 194;

  { The operating system cannot run %1. }
  ERROR_INVALID_MINALLOCSIZE = 195;

  { The operating system cannot run this application program. }
  ERROR_DYNLINK_FROM_INVALID_RING = 196;

  { The operating system is not presently configured to run this application. }
  ERROR_IOPL_NOT_ENABLED = 197;

  { The operating system cannot run %1. }
  ERROR_INVALID_SEGDPL = 198;

  { The operating system cannot run this }
  { application program. }
  ERROR_AUTODATASEG_EXCEEDS_64k = 199;

  { The code segment cannot be greater than or equal to 64KB. }
  ERROR_RING2SEG_MUST_BE_MOVABLE = 200;

  { The operating system cannot run %1. }
  ERROR_RELOC_CHAIN_XEEDS_SEGLIM = 201;

  { The operating system cannot run %1. }
  ERROR_INFLOOP_IN_RELOC_CHAIN = 202;

  { The system could not find the environment option that was entered. }
  ERROR_ENVVAR_NOT_FOUND = 203;

  { No process in the command subtree has a signal handler. }
  ERROR_NO_SIGNAL_SENT = 205;

  { The filename or extension is too long. }
  ERROR_FILENAME_EXCED_RANGE = 206;

  { The ring 2 stack is in use. }
  ERROR_RING2_STACK_IN_USE = 207;

  { The global filename characters, * or ?, are entered }
  { incorrectly or too many global filename characters are specified. }
  ERROR_META_EXPANSION_TOO_LONG = 208;

  { The signal being posted is not correct. }
  ERROR_INVALID_SIGNAL_NUMBER = 209;

  { The signal handler cannot be set. }
  ERROR_THREAD_1_INACTIVE = 210;

  { The segment is locked and cannot be reallocated. }
  ERROR_LOCKED = 212;

  { Too many dynamic link modules are attached to this }
  { program or dynamic link module. }
  ERROR_TOO_MANY_MODULES = 214;

  { Can't nest calls to LoadModule. }
  ERROR_NESTING_NOT_ALLOWED = 215;

  {  The image file %1 is valid, but is for a machine type other }
  {  than the current machine. }
  ERROR_EXE_MACHINE_TYPE_MISMATCH = 216;

  { The pipe state is invalid. }
  ERROR_BAD_PIPE = 230;

  { All pipe instances are busy. }
  ERROR_PIPE_BUSY = 231;

  { The pipe is being closed. }
  ERROR_NO_DATA = 232;

  { No process is on the other end of the pipe. }
  ERROR_PIPE_NOT_CONNECTED = 233;

  { More data is available. }
  ERROR_MORE_DATA = 234;   { dderror }

  { The session was cancelled. }
  ERROR_VC_DISCONNECTED = 240;

  { The specified extended attribute name was invalid. }
  ERROR_INVALID_EA_NAME = 254;

  { The extended attributes are inconsistent. }
  ERROR_EA_LIST_INCONSISTENT = 255;

  { No more data is available. }
  ERROR_NO_MORE_ITEMS = 259;

  { The Copy API cannot be used. }
  ERROR_CANNOT_COPY = 266;

  { The directory name is invalid. }
  ERROR_DIRECTORY = 267;

  { The extended attributes did not fit in the buffer. }
  ERROR_EAS_DIDNT_FIT = 275;

  { The extended attribute file on the mounted file system is corrupt. }
  ERROR_EA_FILE_CORRUPT = 276;

  { The extended attribute table file is full. }
  ERROR_EA_TABLE_FULL = 277;

  { The specified extended attribute handle is invalid. }
  ERROR_INVALID_EA_HANDLE = 278;

  { The mounted file system does not support extended attributes. }
  ERROR_EAS_NOT_SUPPORTED = 282;

  { Attempt to release mutex not owned by caller. }
  ERROR_NOT_OWNER = 288;

  { Too many posts were made to a semaphore. }
  ERROR_TOO_MANY_POSTS = 298;

  { Only part of a Read/WriteProcessMemory request was completed. }
  ERROR_PARTIAL_COPY = 299;

  { The system cannot find message for message number $%1 }
  { in message file for %2. }
  ERROR_MR_MID_NOT_FOUND = 317;

  { Attempt to access invalid address. }
  ERROR_INVALID_ADDRESS = 487;

  { Arithmetic result exceeded 32 bits. }
  ERROR_ARITHMETIC_OVERFLOW = 534;

  { There is a process on other end of the pipe. }
  ERROR_PIPE_CONNECTED = 535;

  { Waiting for a process to open the other end of the pipe. }
  ERROR_PIPE_LISTENING = 536;

  { Access to the extended attribute was denied. }
  ERROR_EA_ACCESS_DENIED = 994;

  { The I/O operation has been aborted because of either a thread exit }
  { or an application request. }
  ERROR_OPERATION_ABORTED = 995;

  { Overlapped I/O event is not in a signalled state. }
  ERROR_IO_INCOMPLETE = 996;

  { Overlapped I/O operation is in progress. }
  ERROR_IO_PENDING = 997;   { dderror }

  { Invalid access to memory location. }
  ERROR_NOACCESS = 998;

  { Error performing inpage operation. }
  ERROR_SWAPERROR = 999;

  { Recursion too deep, stack overflowed. }
  ERROR_STACK_OVERFLOW = 1001;

  { The window cannot act on the sent message. }
  ERROR_INVALID_MESSAGE = 1002;

  { Cannot complete this function. }
  ERROR_CAN_NOT_COMPLETE = 1003;

  { Invalid flags. }
  ERROR_INVALID_FLAGS = 1004;

  { The volume does not contain a recognized file system. }
  { Please make sure that all required file system drivers are loaded and that the }
  { volume is not corrupt. }
  ERROR_UNRECOGNIZED_VOLUME = 1005;

  { The volume for a file has been externally altered such that the }
  { opened file is no longer valid. }
  ERROR_FILE_INVALID = 1006;

  { The requested operation cannot be performed in full-screen mode. }
  ERROR_FULLSCREEN_MODE = 1007;

  { An attempt was made to reference a token that does not exist. }
  ERROR_NO_TOKEN = 1008;

  { The configuration registry database is corrupt. }
  ERROR_BADDB = 1009;

  { The configuration registry key is invalid. }
  ERROR_BADKEY = 1010;

  { The configuration registry key could not be opened. }
  ERROR_CANTOPEN = 1011;

  { The configuration registry key could not be read. }
  ERROR_CANTREAD = 1012;

  { The configuration registry key could not be written. }
  ERROR_CANTWRITE = 1013;

  { One of the files in the Registry database had to be recovered }
  { by use of a log or alternate copy.  The recovery was successful. }
  ERROR_REGISTRY_RECOVERED = 1014;

  { The Registry is corrupt. The structure of one of the files that contains }
  { Registry data is corrupt, or the system's image of the file in memory }
  { is corrupt, or the file could not be recovered because the alternate }
  { copy or log was absent or corrupt. }
  ERROR_REGISTRY_CORRUPT = 1015;

  { An I/O operation initiated by the Registry failed unrecoverably. }
  { The Registry could not read in, or write out, or flush, one of the files }
  { that contain the system's image of the Registry. }
  ERROR_REGISTRY_IO_FAILED = 1016;

  { The system has attempted to load or restore a file into the Registry, but the }
  { specified file is not in a Registry file format. }
  ERROR_NOT_REGISTRY_FILE = 1017;

  { Illegal operation attempted on a Registry key which has been marked for deletion. }
  ERROR_KEY_DELETED = 1018;

  { System could not allocate the required space in a Registry log. }
  ERROR_NO_LOG_SPACE = 1019;

  { Cannot create a symbolic link in a Registry key that already }
  { has subkeys or values. }
  ERROR_KEY_HAS_CHILDREN = 1020;

  { Cannot create a stable subkey under a volatile parent key. }
  ERROR_CHILD_MUST_BE_VOLATILE = 1021;

  { A notify change request is being completed and the information }
  { is not being returned in the caller's buffer. The caller now }
  { needs to enumerate the files to find the changes. }
  ERROR_NOTIFY_ENUM_DIR = 1022;

  { A stop control has been sent to a service which other running services }
  { are dependent on. }
  ERROR_DEPENDENT_SERVICES_RUNNING = 1051;

  { The requested control is not valid for this service }
  ERROR_INVALID_SERVICE_CONTROL = 1052;

  { The service did not respond to the start or control request in a timely }
  { fashion. }
  ERROR_SERVICE_REQUEST_TIMEOUT = 1053;

  { A thread could not be created for the service. }
  ERROR_SERVICE_NO_THREAD = 1054;

  { The service database is locked. }
  ERROR_SERVICE_DATABASE_LOCKED = 1055;

  { An instance of the service is already running. }
  ERROR_SERVICE_ALREADY_RUNNING = 1056;

  { The account name is invalid or does not exist. }
  ERROR_INVALID_SERVICE_ACCOUNT = 1057;

  { The specified service is disabled and cannot be started. }
  ERROR_SERVICE_DISABLED = 1058;

  { Circular service dependency was specified. }
  ERROR_CIRCULAR_DEPENDENCY = 1059;

  { The specified service does not exist as an installed service. }
  ERROR_SERVICE_DOES_NOT_EXIST = 1060;

  { The service cannot accept control messages at this time. }
  ERROR_SERVICE_CANNOT_ACCEPT_CTRL = 1061;

  { The service has not been started. }
  ERROR_SERVICE_NOT_ACTIVE = 1062;

  { The service process could not connect to the service controller. }
  ERROR_FAILED_SERVICE_CONTROLLER_ = 1063;

  { An exception occurred in the service when handling the control request. }
  ERROR_EXCEPTION_IN_SERVICE = 1064;

  { The database specified does not exist. }
  ERROR_DATABASE_DOES_NOT_EXIST = 1065;

  { The service has returned a service-specific error code. }
  ERROR_SERVICE_SPECIFIC_ERROR = 1066;

  { The process terminated unexpectedly. }
  ERROR_PROCESS_ABORTED = 1067;

  { The dependency service or group failed to start. }
  ERROR_SERVICE_DEPENDENCY_FAIL = 1068;

  { The service did not start due to a logon failure. }
  ERROR_SERVICE_LOGON_FAILED = 1069;

  { After starting, the service hung in a start-pending state. }
  ERROR_SERVICE_START_HANG = 1070;

  { The specified service database lock is invalid. }
  ERROR_INVALID_SERVICE_LOCK = 1071;

  { The specified service has been marked for deletion. }
  ERROR_SERVICE_MARKED_FOR_DELETE = 1072;

  { The specified service already exists. }
  ERROR_SERVICE_EXISTS = 1073;

  { The system is currently running with the last-known-good configuration. }
  ERROR_ALREADY_RUNNING_LKG = 1074;

  { The dependency service does not exist or has been marked for }
  { deletion. }
  ERROR_SERVICE_DEPENDENCY_DELETED = 1075;

  { The current boot has already been accepted for use as the }
  { last-known-good control set. }
  ERROR_BOOT_ALREADY_ACCEPTED = 1076;

  { No attempts to start the service have been made since the last boot. }
  ERROR_SERVICE_NEVER_STARTED = 1077;

  { The name is already in use as either a service name or a service display }
  { name. }
  ERROR_DUPLICATE_SERVICE_NAME = 1078;

  {  The account specified for this service is different from the account }
  {  specified for other services running in the same process. }
  ERROR_DIFFERENT_SERVICE_ACCOUNT = 1079;

  { The physical end of the tape has been reached. }
  ERROR_END_OF_MEDIA = 1100;

  { A tape access reached a filemark. }
  ERROR_FILEMARK_DETECTED = 1101;

  { Beginning of tape or partition was encountered. }
  ERROR_BEGINNING_OF_MEDIA = 1102;

  { A tape access reached the end of a set of files. }
  ERROR_SETMARK_DETECTED = 1103;

  { No more data is on the tape. }
  ERROR_NO_DATA_DETECTED = 1104;

  { Tape could not be partitioned. }
  ERROR_PARTITION_FAILURE = 1105;

  { When accessing a new tape of a multivolume partition, the current }
  { blocksize is incorrect. }
  ERROR_INVALID_BLOCK_LENGTH = 1106;

  { Tape partition information could not be found when loading a tape. }
  ERROR_DEVICE_NOT_PARTITIONED = 1107;

  { Unable to lock the media eject mechanism. }
  ERROR_UNABLE_TO_LOCK_MEDIA = 1108;

  { Unable to unload the media. }
  ERROR_UNABLE_TO_UNLOAD_MEDIA = 1109;

  { Media in drive may have changed. }
  ERROR_MEDIA_CHANGED = 1110;

  { The I/O bus was reset. }
  ERROR_BUS_RESET = 1111;

  { No media in drive. }
  ERROR_NO_MEDIA_IN_DRIVE = 1112;

  { No mapping for the Unicode character exists in the target multi-byte code page. }
  ERROR_NO_UNICODE_TRANSLATION = 1113;

  { A dynamic link library (DLL) initialization routine failed. }
  ERROR_DLL_INIT_FAILED = 1114;

  { A system shutdown is in progress. }
  ERROR_SHUTDOWN_IN_PROGRESS = 1115;

  { Unable to abort the system shutdown because no shutdown was in progress. }
  ERROR_NO_SHUTDOWN_IN_PROGRESS = 1116;

  { The request could not be performed because of an I/O device error. }
  ERROR_IO_DEVICE = 1117;

  { No serial device was successfully initialized.  The serial driver will unload. }
  ERROR_SERIAL_NO_DEVICE = 1118;

  { Unable to open a device that was sharing an interrupt request (IRQ) }
  { with other devices. At least one other device that uses that IRQ }
  { was already opened. }
  ERROR_IRQ_BUSY = 1119;

  { A serial I/O operation was completed by another write to the serial port. }
  { (The IOCTL_SERIAL_XOFF_COUNTER reached zero.) }
  ERROR_MORE_WRITES = 1120;

  { A serial I/O operation completed because the time-out period expired. }
  { (The IOCTL_SERIAL_XOFF_COUNTER did not reach zero.) }
  ERROR_COUNTER_TIMEOUT = 1121;

  { No ID address mark was found on the floppy disk. }
  ERROR_FLOPPY_ID_MARK_NOT_FOUND = 1122;

  { Mismatch between the floppy disk sector ID field and the floppy disk }
  { controller track address. }
  ERROR_FLOPPY_WRONG_CYLINDER = 1123;

  { The floppy disk controller reported an error that is not recognized }
  { by the floppy disk driver. }
  ERROR_FLOPPY_UNKNOWN_ERROR = 1124;

  { The floppy disk controller returned inconsistent results in its registers. }
  ERROR_FLOPPY_BAD_REGISTERS = 1125;

  { While accessing the hard disk, a recalibrate operation failed, even after retries. }
  ERROR_DISK_RECALIBRATE_FAILED = 1126;

  { While accessing the hard disk, a disk operation failed even after retries. }
  ERROR_DISK_OPERATION_FAILED = 1127;

  { While accessing the hard disk, a disk controller reset was needed, but }
  { even that failed. }
  ERROR_DISK_RESET_FAILED = 1128;

  { Physical end of tape encountered. }
  ERROR_EOM_OVERFLOW = 1129;

  { Not enough server storage is available to process this command. }
  ERROR_NOT_ENOUGH_SERVER_MEMORY = 1130;

  { A potential deadlock condition has been detected. }
  ERROR_POSSIBLE_DEADLOCK = 1131;

  { The base address or the file offset specified does not have the proper }
  { alignment. }
  ERROR_MAPPED_ALIGNMENT = 1132;

  { An attempt to change the system power state was vetoed by another }
  { application or driver. }
  ERROR_SET_POWER_STATE_VETOED = 1140;

  { The system BIOS failed an attempt to change the system power state. }
  ERROR_SET_POWER_STATE_FAILED = 1141;

  {  An attempt was made to create more links on a file than }
  {  the file system supports. }
  ERROR_TOO_MANY_LINKS = 1142;

  { The specified program requires a newer version of Windows. }
  ERROR_OLD_WIN_VERSION = 1150;

  { The specified program is not a Windows or MS-DOS program. }
  ERROR_APP_WRONG_OS = 1151;

  { Cannot start more than one instance of the specified program. }
  ERROR_SINGLE_INSTANCE_APP = 1152;

  {  The specified program was written for an older version of Windows. }
  ERROR_RMODE_APP = 1153;

  { One of the library files needed to run this application is damaged. }
  ERROR_INVALID_DLL = 1154;

  { No application is associated with the specified file for this operation. }
  ERROR_NO_ASSOCIATION = 1155;

  { An error occurred in sending the command to the application. }
  ERROR_DDE_FAIL = 1156;

  { One of the library files needed to run this application cannot be found. }
  ERROR_DLL_NOT_FOUND = 1157;


{ Winnet32 Status Codes }

  { The specified username is invalid. }
  ERROR_BAD_USERNAME = 2202;

  { This network connection does not exist. }
  ERROR_NOT_CONNECTED = 2250;

  { This network connection has files open or requests pending. }
  ERROR_OPEN_FILES = 2401;

  { Active connections still exist. }
  ERROR_ACTIVE_CONNECTIONS = 2402;

  { The device is in use by an active process and cannot be disconnected. }
  ERROR_DEVICE_IN_USE = 2404;

  { The specified device name is invalid. }
  ERROR_BAD_DEVICE = 1200;

  { The device is not currently connected but it is a remembered connection. }
  ERROR_CONNECTION_UNAVAIL = 1201;

  { An attempt was made to remember a device that had previously been remembered. }
  ERROR_DEVICE_ALREADY_REMEMBERED = 1202;

  { No network provider accepted the given network path. }
  ERROR_NO_NET_OR_BAD_PATH = 1203;

  { The specified network provider name is invalid. }
  ERROR_BAD_PROVIDER = 1204;

  { Unable to open the network connection profile. }
  ERROR_CANNOT_OPEN_PROFILE = 1205;

  { The network connection profile is corrupt. }
  ERROR_BAD_PROFILE = 1206;

  { Cannot enumerate a non-container. }
  ERROR_NOT_CONTAINER = 1207;

  { An extended error has occurred. }
  ERROR_EXTENDED_ERROR = 1208;

  { The format of the specified group name is invalid. }
  ERROR_INVALID_GROUPNAME = 1209;

  { The format of the specified computer name is invalid. }
  ERROR_INVALID_COMPUTERNAME = 1210;

  { The format of the specified event name is invalid. }
  ERROR_INVALID_EVENTNAME = 1211;

  { The format of the specified domain name is invalid. }
  ERROR_INVALID_DOMAINNAME = 1212;

  { The format of the specified service name is invalid. }
  ERROR_INVALID_SERVICENAME = 1213;

  { The format of the specified network name is invalid. }
  ERROR_INVALID_NETNAME = 1214;

  { The format of the specified share name is invalid. }
  ERROR_INVALID_SHARENAME = 1215;

  { The format of the specified password is invalid. }
  ERROR_INVALID_PASSWORDNAME = 1216;

  { The format of the specified message name is invalid. }
  ERROR_INVALID_MESSAGENAME = 1217;

  { The format of the specified message destination is invalid. }
  ERROR_INVALID_MESSAGEDEST = 1218;

  { The credentials supplied conflict with an existing set of credentials. }
  ERROR_SESSION_CREDENTIAL_CONFLICT = 1219;

  { An attempt was made to establish a session to a network server, but there }
  { are already too many sessions established to that server. }
  ERROR_REMOTE_SESSION_LIMIT_EXCEEDED = 1220;

  { The workgroup or domain name is already in use by another computer on the }
  { network. }
  ERROR_DUP_DOMAINNAME = 1221;

  { The network is not present or not started. }
  ERROR_NO_NETWORK = 1222;

  { The operation was cancelled by the user. }
  ERROR_CANCELLED = 1223;

  { The requested operation cannot be performed on a file with a user mapped section open. }
  ERROR_USER_MAPPED_FILE = 1224;

  { The remote system refused the network connection. }
  ERROR_CONNECTION_REFUSED = 1225;

  { The network connection was gracefully closed. }
  ERROR_GRACEFUL_DISCONNECT = 1226;

  { The network transport endpoint already has an address associated with it. }
  ERROR_ADDRESS_ALREADY_ASSOCIATED = 1227;

  { An address has not yet been associated with the network endpoint. }
  ERROR_ADDRESS_NOT_ASSOCIATED = 1228;

  { An operation was attempted on a non-existent network connection. }
  ERROR_CONNECTION_INVALID = 1229;

  { An invalid operation was attempted on an active network connection. }
  ERROR_CONNECTION_ACTIVE = 1230;

  { The remote network is not reachable by the transport. }
  ERROR_NETWORK_UNREACHABLE = 1231;

  { The remote system is not reachable by the transport. }
  ERROR_HOST_UNREACHABLE = 1232;

  { The remote system does not support the transport protocol. }
  ERROR_PROTOCOL_UNREACHABLE = 1233;

  { No service is operating at the destination network endpoint }
  { on the remote system. }
  ERROR_PORT_UNREACHABLE = 1234;

  { The request was aborted. }
  ERROR_REQUEST_ABORTED = 1235;

  { The network connection was aborted by the local system. }
  ERROR_CONNECTION_ABORTED = 1236;

  { The operation could not be completed.  A retry should be performed. }
  ERROR_RETRY = 1237;

  { A connection to the server could not be made because the limit on the number of }
  { concurrent connections for this account has been reached. }
  ERROR_CONNECTION_COUNT_LIMIT = 1238;

  { Attempting to login during an unauthorized time of day for this account. }
  ERROR_LOGIN_TIME_RESTRICTION = 1239;

  { The account is not authorized to login from this station. }
  ERROR_LOGIN_WKSTA_RESTRICTION = 1240;

  { The network address could not be used for the operation requested. }
  ERROR_INCORRECT_ADDRESS = 1241;

  { The service is already registered. }
  ERROR_ALREADY_REGISTERED = 1242;

  { The specified service does not exist. }
  ERROR_SERVICE_NOT_FOUND = 1243;

  { The operation being requested was not performed because the user }
  { has not been authenticated. }
  ERROR_NOT_AUTHENTICATED = 1244;

  { The operation being requested was not performed because the user }
  { has not logged on to the network. }
  { The specified service does not exist. }
  ERROR_NOT_LOGGED_ON = 1245;

  { Return that wants caller to continue with work in progress. }
  ERROR_CONTINUE = 1246;

  { An attempt was made to perform an initialization operation when }
  { initialization has already been completed. }
  ERROR_ALREADY_INITIALIZED = 1247;

  { No more local devices. }
  ERROR_NO_MORE_DEVICES = 1248;


{ Security Status Codes }

  { Not all privileges referenced are assigned to the caller. }
  ERROR_NOT_ALL_ASSIGNED = 1300;

  { Some mapping between account names and security IDs was not done. }
  ERROR_SOME_NOT_MAPPED = 1301;

  { No system quota limits are specifically set for this account. }
  ERROR_NO_QUOTAS_FOR_ACCOUNT = 1302;

  { No encryption key is available.  A well-known encryption key was returned. }
  ERROR_LOCAL_USER_SESSION_KEY = 1303;

  { The NT password is too complex to be converted to a LAN Manager }
  { password.  The LAN Manager password returned is a NULL string. }
  ERROR_NULL_LM_PASSWORD = 1304;

  { The revision level is unknown. }
  ERROR_UNKNOWN_REVISION = 1305;

  { Indicates two revision levels are incompatible. }
  ERROR_REVISION_MISMATCH = 1306;

  { This security ID may not be assigned as the owner of this object. }
  ERROR_INVALID_OWNER = 1307;

  { This security ID may not be assigned as the primary group of an object. }
  ERROR_INVALID_PRIMARY_GROUP = 1308;

  { An attempt has been made to operate on an impersonation token }

  { by a thread that is not currently impersonating a client. }
  ERROR_NO_IMPERSONATION_TOKEN = 1309;

  { The group may not be disabled. }
  ERROR_CANT_DISABLE_MANDATORY = 1310;

  { There are currently no logon servers available to service the logon }
  { request. }
  ERROR_NO_LOGON_SERVERS = 1311;

  {  A specified logon session does not exist.  It may already have }
  {  been terminated. }
  ERROR_NO_SUCH_LOGON_SESSION = 1312;

  {  A specified privilege does not exist. }
  ERROR_NO_SUCH_PRIVILEGE = 1313;

  {  A required privilege is not held by the client. }
  ERROR_PRIVILEGE_NOT_HELD = 1314;

  { The name provided is not a properly formed account name. }
  ERROR_INVALID_ACCOUNT_NAME = 1315;

  { The specified user already exists. }
  ERROR_USER_EXISTS = 1316;

  { The specified user does not exist. }
  ERROR_NO_SUCH_USER = 1317;

  { The specified group already exists. }
  ERROR_GROUP_EXISTS = 1318;

  { The specified group does not exist. }
  ERROR_NO_SUCH_GROUP = 1319;

  { Either the specified user account is already a member of the specified }
  { group, or the specified group cannot be deleted because it contains }
  { a member. }
  ERROR_MEMBER_IN_GROUP = 1320;

  { The specified user account is not a member of the specified group account. }
  ERROR_MEMBER_NOT_IN_GROUP = 1321;

  { The last remaining administration account cannot be disabled }
  { or deleted. }
  ERROR_LAST_ADMIN = 1322;

  { Unable to update the password.  The value provided as the current }
  { password is incorrect. }
  ERROR_WRONG_PASSWORD = 1323;

  { Unable to update the password.  The value provided for the new password }
  { contains values that are not allowed in passwords. }
  ERROR_ILL_FORMED_PASSWORD = 1324;

  { Unable to update the password because a password update rule has been }
  { violated. }
  ERROR_PASSWORD_RESTRICTION = 1325;

  { Logon failure: unknown user name or bad password. }
  ERROR_LOGON_FAILURE = 1326;

  { Logon failure: user account restriction. }
  ERROR_ACCOUNT_RESTRICTION = 1327;

  { Logon failure: account logon time restriction violation. }
  ERROR_INVALID_LOGON_HOURS = 1328;

  { Logon failure: user not allowed to log on to this computer. }
  ERROR_INVALID_WORKSTATION = 1329;

  { Logon failure: the specified account password has expired. }
  ERROR_PASSWORD_EXPIRED = 1330;

  { Logon failure: account currently disabled. }
  ERROR_ACCOUNT_DISABLED = 1331;

  { No mapping between account names and security IDs was done. }
  ERROR_NONE_MAPPED = 1332;

  { Too many local user identifiers (LUIDs) were requested at one time. }
  ERROR_TOO_MANY_LUIDS_REQUESTED = 1333;

  { No more local user identifiers (LUIDs) are available. }
  ERROR_LUIDS_EXHAUSTED = 1334;

  { The subauthority part of a security ID is invalid for this particular use. }
  ERROR_INVALID_SUB_AUTHORITY = 1335;

  { The access control list (ACL) structure is invalid. }
  ERROR_INVALID_ACL = 1336;

  { The security ID structure is invalid. }
  ERROR_INVALID_SID = 1337;

  { The security descriptor structure is invalid. }
  ERROR_INVALID_SECURITY_DESCR = 1338;

  { The inherited access control list (ACL) or access control entry (ACE) }
  { could not be built. }
  ERROR_BAD_INHERITANCE_ACL = 1340;

  { The server is currently disabled. }
  ERROR_SERVER_DISABLED = 1341;

  { The server is currently enabled. }
  ERROR_SERVER_NOT_DISABLED = 1342;

  { The value provided was an invalid value for an identifier authority. }
  ERROR_INVALID_ID_AUTHORITY = 1343;

  { No more memory is available for security information updates. }
  ERROR_ALLOTTED_SPACE_EXCEEDED = 1344;

  { The specified attributes are invalid, or incompatible with the }

  { attributes for the group as a whole. }
  ERROR_INVALID_GROUP_ATTRIBUTES = 1345;

  { Either a required impersonation level was not provided, or the }
  { provided impersonation level is invalid. }
  ERROR_BAD_IMPERSONATION_LEVEL = 1346;

  { Cannot open an anonymous level security token. }
  ERROR_CANT_OPEN_ANONYMOUS = 1347;

  { The validation information class requested was invalid. }
  ERROR_BAD_VALIDATION_CLASS = 1348;

  { The type of the token is inappropriate for its attempted use. }
  ERROR_BAD_TOKEN_TYPE = 1349;

  { Unable to perform a security operation on an object }
  { which has no associated security. }
  ERROR_NO_SECURITY_ON_OBJECT = 1350;

  { Indicates a Windows NT Server could not be contacted or that }
  { objects within the domain are protected such that necessary }
  { information could not be retrieved. }
  ERROR_CANT_ACCESS_DOMAIN_INFO = 1351;

  { The security account manager (SAM) or local security }
  { authority (LSA) server was in the wrong state to perform }
  { the security operation. }
  ERROR_INVALID_SERVER_STATE = 1352;

  { The domain was in the wrong state to perform the security operation. }
  ERROR_INVALID_DOMAIN_STATE = 1353;

  { This operation is only allowed for the Primary Domain Controller of the domain. }
  ERROR_INVALID_DOMAIN_ROLE = 1354;

  { The specified domain did not exist. }
  ERROR_NO_SUCH_DOMAIN = 1355;

  { The specified domain already exists. }
  ERROR_DOMAIN_EXISTS = 1356;

  { An attempt was made to exceed the limit on the number of domains per server. }
  ERROR_DOMAIN_LIMIT_EXCEEDED = 1357;

  { Unable to complete the requested operation because of either a }
  { catastrophic media failure or a data structure corruption on the disk. }
  ERROR_INTERNAL_DB_CORRUPTION = 1358;

  { The security account database contains an internal inconsistency. }
  ERROR_INTERNAL_ERROR = 1359;

  { Generic access types were contained in an access mask which should }
  { already be mapped to non-generic types. }
  ERROR_GENERIC_NOT_MAPPED = 1360;

  { A security descriptor is not in the right format (absolute or self-relative). }
  ERROR_BAD_DESCRIPTOR_FORMAT = 1361;

  { The requested action is restricted for use by logon processes }
  { only.  The calling process has not registered as a logon process. }
  ERROR_NOT_LOGON_PROCESS = 1362;

  { Cannot start a new logon session with an ID that is already in use. }
  ERROR_LOGON_SESSION_EXISTS = 1363;

  { A specified authentication package is unknown. }
  ERROR_NO_SUCH_PACKAGE = 1364;

  { The logon session is not in a state that is consistent with the }
  { requested operation. }
  ERROR_BAD_LOGON_SESSION_STATE = 1365;

  { The logon session ID is already in use. }
  ERROR_LOGON_SESSION_COLLISION = 1366;

  { A logon request contained an invalid logon type value. }
  ERROR_INVALID_LOGON_TYPE = 1367;

  { Unable to impersonate via a named pipe until data has been read }
  { from that pipe. }
  ERROR_CANNOT_IMPERSONATE = 1368;

  { The transaction state of a Registry subtree is incompatible with the }
  { requested operation. }
  ERROR_RXACT_INVALID_STATE = 1369;

  { An internal security database corruption has been encountered. }
  ERROR_RXACT_COMMIT_FAILURE = 1370;

  { Cannot perform this operation on built-in accounts. }
  ERROR_SPECIAL_ACCOUNT = 1371;

  { Cannot perform this operation on this built-in special group. }
  ERROR_SPECIAL_GROUP = 1372;

  { Cannot perform this operation on this built-in special user. }
  ERROR_SPECIAL_USER = 1373;

  { The user cannot be removed from a group because the group }
  { is currently the user's primary group. }
  ERROR_MEMBERS_PRIMARY_GROUP = 1374;

  { The token is already in use as a primary token. }
  ERROR_TOKEN_ALREADY_IN_USE = 1375;

  { The specified local group does not exist. }
  ERROR_NO_SUCH_ALIAS = 1376;

  { The specified account name is not a member of the local group. }
  ERROR_MEMBER_NOT_IN_ALIAS = 1377;

  { The specified account name is already a member of the local group. }
  ERROR_MEMBER_IN_ALIAS = 1378;

  { The specified local group already exists. }
  ERROR_ALIAS_EXISTS = 1379;

  { Logon failure: the user has not been granted the requested }
  { logon type at this computer. }
  ERROR_LOGON_NOT_GRANTED = 1380;

  { The maximum number of secrets that may be stored in a single system has been }
  { exceeded. }
  ERROR_TOO_MANY_SECRETS = 1381;

  { The length of a secret exceeds the maximum length allowed. }
  ERROR_SECRET_TOO_LONG = 1382;

  { The local security authority database contains an internal inconsistency. }
  ERROR_INTERNAL_DB_ERROR = 1383;

  { During a logon attempt, the user's security context accumulated too many }
  { security IDs. }
  ERROR_TOO_MANY_CONTEXT_IDS = 1384;

  { Logon failure: the user has not been granted the requested logon type }
  { at this computer. }
  ERROR_LOGON_TYPE_NOT_GRANTED = 1385;

  { A cross-encrypted password is necessary to change a user password. }
  ERROR_NT_CROSS_ENCRYPTION_REQUIRED = 1386;

  { A new member could not be added to a local group because the member does }
  { not exist. }
  ERROR_NO_SUCH_MEMBER = 1387;

  { A new member could not be added to a local group because the member has the }
  { wrong account type. }
  ERROR_INVALID_MEMBER = 1388;

  { Too many security IDs have been specified. }
  ERROR_TOO_MANY_SIDS = 1389;

  { A cross-encrypted password is necessary to change this user password. }
  ERROR_LM_CROSS_ENCRYPTION_REQUIRED = 1390;

  { Indicates an TACL contains no inheritable components }
  ERROR_NO_INHERITANCE = 1391;

  { The file or directory is corrupt and non-readable. }
  ERROR_FILE_CORRUPT = 1392;

  { The disk structure is corrupt and non-readable. }
  ERROR_DISK_CORRUPT = 1393;

  { There is no user session key for the specified logon session. }
  ERROR_NO_USER_SESSION_KEY = 1394;

  { The service being accessed is licensed for a particular number of connections. }
  { No more connections can be made to the service at this time }
  { because there are already as many connections as the service can accept. }
  ERROR_LICENSE_QUOTA_EXCEEDED = 1395;


{ WinUser Error Codes }

  { Invalid window handle. }
  ERROR_INVALID_WINDOW_HANDLE = 1400;

  { Invalid menu handle. }
  ERROR_INVALID_MENU_HANDLE = 1401;

  { Invalid cursor handle. }
  ERROR_INVALID_CURSOR_HANDLE = 1402;

  { Invalid accelerator table handle. }
  ERROR_INVALID_ACCEL_HANDLE = 1403;

  { Invalid hook handle. }
  ERROR_INVALID_HOOK_HANDLE = 1404;

  { Invalid handle to a multiple-window position structure. }
  ERROR_INVALID_DWP_HANDLE = 1405;

  { Cannot create a top-level child window. }
  ERROR_TLW_WITH_WSCHILD = 1406;

  { Cannot find window class. }
  ERROR_CANNOT_FIND_WND_CLASS = 1407;

  { Invalid window, belongs to other thread. }
  ERROR_WINDOW_OF_OTHER_THREAD = 1408;

  { Hot key is already registered. }
  ERROR_HOTKEY_ALREADY_REGISTERED = 1409;

  { Class already exists. }
  ERROR_CLASS_ALREADY_EXISTS = 1410;

  { Class does not exist. }
  ERROR_CLASS_DOES_NOT_EXIST = 1411;

  { Class still has open windows. }
  ERROR_CLASS_HAS_WINDOWS = 1412;

  { Invalid index. }
  ERROR_INVALID_INDEX = 1413;

  { Invalid icon handle. }
  ERROR_INVALID_ICON_HANDLE = 1414;

  { Using private DIALOG window words. }
  ERROR_PRIVATE_DIALOG_INDEX = 1415;

  { The listbox identifier was not found. }
  ERROR_LISTBOX_ID_NOT_FOUND = 1416;

  { No wildcards were found. }
  ERROR_NO_WILDCARD_CHARACTERS = 1417;

  { Thread does not have a clipboard open. }
  ERROR_CLIPBOARD_NOT_OPEN = 1418;

  { Hot key is not registered. }
  ERROR_HOTKEY_NOT_REGISTERED = 1419;

  { The window is not a valid dialog window. }
  ERROR_WINDOW_NOT_DIALOG = 1420;

  { Control ID not found. }
  ERROR_CONTROL_ID_NOT_FOUND = 1421;

  { Invalid message for a combo box because it does not have an edit control. }
  ERROR_INVALID_COMBOBOX_MESSAGE = 1422;

  { The window is not a combo box. }
  ERROR_WINDOW_NOT_COMBOBOX = 1423;

  { Height must be less than 256. }
  ERROR_INVALID_EDIT_HEIGHT = 1424;

  { Invalid device context (DC) handle. }
  ERROR_DC_NOT_FOUND = 1425;

  { Invalid hook procedure type. }
  ERROR_INVALID_HOOK_FILTER = 1426;

  { Invalid hook procedure. }
  ERROR_INVALID_FILTER_PROC = 1427;

  { Cannot set non-local hook without a module handle. }
  ERROR_HOOK_NEEDS_HMOD = 1428;

  { This hook procedure can only be set globally. }
  ERROR_GLOBAL_ONLY_HOOK = 1429;

  { The journal hook procedure is already installed. }
  ERROR_JOURNAL_HOOK_SET = 1430;

  { The hook procedure is not installed. }
  ERROR_HOOK_NOT_INSTALLED = 1431;

  { Invalid message for single-selection listbox. }
  ERROR_INVALID_LB_MESSAGE = 1432;

  { LB_SETCOUNT sent to non-lazy listbox. }
  ERROR_SETCOUNT_ON_BAD_LB = 1433;

  { This list box does not support tab stops. }
  ERROR_LB_WITHOUT_TABSTOPS = 1434;

  { Cannot destroy object created by another thread. }
  ERROR_DESTROY_OBJECT_OF_OTHER_THREAD = 1435;

  { Child windows cannot have menus. }
  ERROR_CHILD_WINDOW_MENU = 1436;

  { The window does not have a system menu. }
  ERROR_NO_SYSTEM_MENU = 1437;

  { Invalid message box style. }
  ERROR_INVALID_MSGBOX_STYLE = 1438;

  { Invalid system-wide (SPI_*) parameter. }
  ERROR_INVALID_SPI_VALUE = 1439;

  { Screen already locked. }
  ERROR_SCREEN_ALREADY_LOCKED = 1440;

  { All handles to windows in a multiple-window position structure must }
  { have the same parent. }
  ERROR_HWNDS_HAVE_DIFF_PARENT = 1441;

  { The window is not a child window. }
  ERROR_NOT_CHILD_WINDOW = 1442;

  { Invalid GW_* command. }
  ERROR_INVALID_GW_COMMAND = 1443;

  { Invalid thread identifier. }
  ERROR_INVALID_THREAD_ID = 1444;

  { Cannot process a message from a window that is not a multiple document }
  { interface (MDI) window. }
  ERROR_NON_MDICHILD_WINDOW = 1445;

  { Popup menu already active. }
  ERROR_POPUP_ALREADY_ACTIVE = 1446;

  { The window does not have scroll bars. }
  ERROR_NO_SCROLLBARS = 1447;

  { Scroll bar range cannot be greater than $7FFF. }
  ERROR_INVALID_SCROLLBAR_RANGE = 1448;

  { Cannot show or remove the window in the way specified. }
  ERROR_INVALID_SHOWWIN_COMMAND = 1449;

  { Insufficient system resources exist to complete the requested service. }
  ERROR_NO_SYSTEM_RESOURCES = 1450;

  { Insufficient system resources exist to complete the requested service. }
  ERROR_NONPAGED_SYSTEM_RESOURCES = 1451;

  { Insufficient system resources exist to complete the requested service. }
  ERROR_PAGED_SYSTEM_RESOURCES = 1452;

  { Insufficient quota to complete the requested service. }
  ERROR_WORKING_SET_QUOTA = 1453;

  { Insufficient quota to complete the requested service. }
  ERROR_PAGEFILE_QUOTA = 1454;

  { The paging file is too small for this operation to complete. }
  ERROR_COMMITMENT_LIMIT = 1455;

  { A menu item was not found. }
  ERROR_MENU_ITEM_NOT_FOUND = 1456;

  { Invalid keyboard layout handle. }
  ERROR_INVALID_KEYBOARD_HANDLE = 1457;

  { Hook type not allowed. }
  ERROR_HOOK_TYPE_NOT_ALLOWED = 1458;

  { This operation requires an interactive windowstation. }
  ERROR_REQUIRES_INTERACTIVE_WINDOWSTATION = 1459;

  { This operation returned because the timeout period expired. }
  ERROR_TIMEOUT = 1460;


{ Eventlog Status Codes }

  { The event log file is corrupt. }
  ERROR_EVENTLOG_FILE_CORRUPT = 1500;

  { No event log file could be opened, so the event logging service did not start. }
  ERROR_EVENTLOG_CANT_START = 1501;

  { The event log file is full. }
  ERROR_LOG_FILE_FULL = 1502;

  { The event log file has changed between reads. }
  ERROR_EVENTLOG_FILE_CHANGED = 1503;


{ RPC Status Codes }

  { The string binding is invalid. }
  RPC_S_INVALID_STRING_BINDING = 1700;

  { The binding handle is not the correct type. }
  RPC_S_WRONG_KIND_OF_BINDING = 1701;

  { The binding handle is invalid. }
  RPC_S_INVALID_BINDING = 1702;

  { The RPC protocol sequence is not supported. }
  RPC_S_PROTSEQ_NOT_SUPPORTED = 1703;

  { The RPC protocol sequence is invalid. }
  RPC_S_INVALID_RPC_PROTSEQ = 1704;

  { The string universal unique identifier (UUID) is invalid. }
  RPC_S_INVALID_STRING_UUID = 1705;

  { The endpoint format is invalid. }
  RPC_S_INVALID_ENDPOINT_FORMAT = 1706;

  { The network address is invalid. }
  RPC_S_INVALID_NET_ADDR = 1707;

  { No endpoint was found. }
  RPC_S_NO_ENDPOINT_FOUND = 1708;

  { The timeout value is invalid. }
  RPC_S_INVALID_TIMEOUT = 1709;

  { The object universal unique identifier (UUID) was not found. }
  RPC_S_OBJECT_NOT_FOUND = 1710;

  { The object universal unique identifier (UUID) has already been registered. }
  RPC_S_ALREADY_REGISTERED = 1711;

  { The type universal unique identifier (UUID) has already been registered. }
  RPC_S_TYPE_ALREADY_REGISTERED = 1712;

  { The RPC server is already listening. }
  RPC_S_ALREADY_LISTENING = 1713;

  { No protocol sequences have been registered. }
  RPC_S_NO_PROTSEQS_REGISTERED = 1714;

  { The RPC server is not listening. }
  RPC_S_NOT_LISTENING = 1715;

  { The manager type is unknown. }
  RPC_S_UNKNOWN_MGR_TYPE = 1716;

  { The interface is unknown. }
  RPC_S_UNKNOWN_IF = 1717;

  { There are no bindings. }
  RPC_S_NO_BINDINGS = 1718;

  { There are no protocol sequences. }
  RPC_S_NO_PROTSEQS = 1719;

  { The endpoint cannot be created. }
  RPC_S_CANT_CREATE_ENDPOINT = 1720;

  { Not enough resources are available to complete this operation. }
  RPC_S_OUT_OF_RESOURCES = 1721;

  { The RPC server is unavailable. }
  RPC_S_SERVER_UNAVAILABLE = 1722;

  { The RPC server is too busy to complete this operation. }
  RPC_S_SERVER_TOO_BUSY = 1723;

  { The network options are invalid. }
  RPC_S_INVALID_NETWORK_OPTIONS = 1724;

  { There is not a remote procedure call active in this thread. }
  RPC_S_NO_CALL_ACTIVE = 1725;

  { The remote procedure call failed. }
  RPC_S_CALL_FAILED = 1726;

  { The remote procedure call failed and did not execute. }
  RPC_S_CALL_FAILED_DNE = 1727;

  { A remote procedure call (RPC) protocol error occurred. }
  RPC_S_PROTOCOL_ERROR = 1728;

  { The transfer syntax is not supported by the RPC server. }
  RPC_S_UNSUPPORTED_TRANS_SYN = 1730;

  { The universal unique identifier (UUID) type is not supported. }
  RPC_S_UNSUPPORTED_TYPE = 1732;

  { The tag is invalid. }
  RPC_S_INVALID_TAG = 1733;

  { The array bounds are invalid. }
  RPC_S_INVALID_BOUND = 1734;

  { The binding does not contain an entry name. }
  RPC_S_NO_ENTRY_NAME = 1735;

  { The name syntax is invalid. }
  RPC_S_INVALID_NAME_SYNTAX = 1736;

  { The name syntax is not supported. }
  RPC_S_UNSUPPORTED_NAME_SYNTAX = 1737;

  { No network address is available to use to construct a universal }

  { unique identifier (UUID). }
  RPC_S_UUID_NO_ADDRESS = 1739;

  { The endpoint is a duplicate. }
  RPC_S_DUPLICATE_ENDPOINT = 1740;

  { The authentication type is unknown. }
  RPC_S_UNKNOWN_AUTHN_TYPE = 1741;

  { The maximum number of calls is too small. }
  RPC_S_MAX_CALLS_TOO_SMALL = 1742;

  { The string is too long. }
  RPC_S_STRING_TOO_LONG = 1743;

  { The RPC protocol sequence was not found. }
  RPC_S_PROTSEQ_NOT_FOUND = 1744;

  { The procedure number is out of range. }
  RPC_S_PROCNUM_OUT_OF_RANGE = 1745;

  { The binding does not contain any authentication information. }
  RPC_S_BINDING_HAS_NO_AUTH = 1746;

  { The authentication service is unknown. }
  RPC_S_UNKNOWN_AUTHN_SERVICE = 1747;

  { The authentication level is unknown. }
  RPC_S_UNKNOWN_AUTHN_LEVEL = 1748;

  { The security context is invalid. }
  RPC_S_INVALID_AUTH_IDENTITY = 1749;

  { The authorization service is unknown. }
  RPC_S_UNKNOWN_AUTHZ_SERVICE = 1750;

  { The entry is invalid. }
  EPT_S_INVALID_ENTRY = 1751;

  { The server endpoint cannot perform the operation. }
  EPT_S_CANT_PERFORM_OP = 1752;

  { There are no more endpoints available from the endpoint mapper. }
  EPT_S_NOT_REGISTERED = 1753;

  { No interfaces have been exported. }
  RPC_S_NOTHING_TO_EXPORT = 1754;

  { The entry name is incomplete. }
  RPC_S_INCOMPLETE_NAME = 1755;

  { The version option is invalid. }
  RPC_S_INVALID_VERS_OPTION = 1756;

  { There are no more members. }
  RPC_S_NO_MORE_MEMBERS = 1757;

  { There is nothing to unexport. }
  RPC_S_NOT_ALL_OBJS_UNEXPORTED = 1758;

  { The interface was not found. }
  RPC_S_INTERFACE_NOT_FOUND = 1759;

  { The entry already exists. }
  RPC_S_ENTRY_ALREADY_EXISTS = 1760;

  { The entry is not found. }
  RPC_S_ENTRY_NOT_FOUND = 1761;

  { The name service is unavailable. }
  RPC_S_NAME_SERVICE_UNAVAILABLE = 1762;

  { The network address family is invalid. }
  RPC_S_INVALID_NAF_ID = 1763;

  { The requested operation is not supported. }
  RPC_S_CANNOT_SUPPORT = 1764;

  { No security context is available to allow impersonation. }
  RPC_S_NO_CONTEXT_AVAILABLE = 1765;

  { An internal error occurred in a remote procedure call (RPC). }
  RPC_S_INTERNAL_ERROR = 1766;

  { The RPC server attempted an integer division by zero. }
  RPC_S_ZERO_DIVIDE = 1767;

  { An addressing error occurred in the RPC server. }
  RPC_S_ADDRESS_ERROR = 1768;

  { A floating-point operation at the RPC server caused a division by zero. }
  RPC_S_FP_DIV_ZERO = 1769;

  { A floating-point underflow occurred at the RPC server. }
  RPC_S_FP_UNDERFLOW = 1770;

  { A floating-point overflow occurred at the RPC server. }
  RPC_S_FP_OVERFLOW = 1771;

  { The list of RPC servers available for the binding of auto handles }
  { has been exhausted. }
  RPC_X_NO_MORE_ENTRIES = 1772;

  { Unable to open the character translation table file. }
  RPC_X_SS_CHAR_TRANS_OPEN_FAIL = 1773;

  { The file containing the character translation table has fewer than }
  { 512 bytes. }
  RPC_X_SS_CHAR_TRANS_SHORT_FILE = 1774;

  { A null context handle was passed from the client to the host during }
  { a remote procedure call. }
  RPC_X_SS_IN_NULL_CONTEXT = 1775;

  { The context handle changed during a remote procedure call. }
  RPC_X_SS_CONTEXT_DAMAGED = 1777;

  { The binding handles passed to a remote procedure call do not match. }
  RPC_X_SS_HANDLES_MISMATCH = 1778;

  { The stub is unable to get the remote procedure call handle. }
  RPC_X_SS_CANNOT_GET_CALL_HANDLE = 1779;

  { A null reference pointer was passed to the stub. }
  RPC_X_NULL_REF_POINTER = 1780;

  { The enumeration value is out of range. }
  RPC_X_ENUM_VALUE_OUT_OF_RANGE = 1781;

  { The byte count is too small. }
  RPC_X_BYTE_COUNT_TOO_SMALL = 1782;

  { The stub received bad data. }
  RPC_X_BAD_STUB_DATA = 1783;

  { The supplied user buffer is not valid for the requested operation. }
  ERROR_INVALID_USER_BUFFER = 1784;

  { The disk media is not recognized.  It may not be formatted. }
  ERROR_UNRECOGNIZED_MEDIA = 1785;

  { The workstation does not have a trust secret. }
  ERROR_NO_TRUST_LSA_SECRET = 1786;

  { The SAM database on the Windows NT Server does not have a computer }
  { account for this workstation trust relationship. }
  ERROR_NO_TRUST_SAM_ACCOUNT = 1787;

  { The trust relationship between the primary domain and the trusted }
  { domain failed. }
  ERROR_TRUSTED_DOMAIN_FAILURE = 1788;

  { The trust relationship between this workstation and the primary }
  { domain failed. }
  ERROR_TRUSTED_RELATIONSHIP_FAILURE = 1789;

  { The network logon failed. }
  ERROR_TRUST_FAILURE = 1790;

  { A remote procedure call is already in progress for this thread. }
  RPC_S_CALL_IN_PROGRESS = 1791;

  { An attempt was made to logon, but the network logon service was not started. }
  ERROR_NETLOGON_NOT_STARTED = 1792;

  { The user's account has expired. }
  ERROR_ACCOUNT_EXPIRED = 1793;

  { The redirector is in use and cannot be unloaded. }
  ERROR_REDIRECTOR_HAS_OPEN_HANDLES = 1794;

  { The specified printer driver is already installed. }
  ERROR_PRINTER_DRIVER_ALREADY_INSTALLED = 1795;

  { The specified port is unknown. }
  ERROR_UNKNOWN_PORT = 1796;

  { The printer driver is unknown. }
  ERROR_UNKNOWN_PRINTER_DRIVER = 1797;

  { The print processor is unknown. }
  ERROR_UNKNOWN_PRINTPROCESSOR = 1798;

  { The specified separator file is invalid. }
  ERROR_INVALID_SEPARATOR_FILE = 1799;

  { The specified priority is invalid. }
  ERROR_INVALID_PRIORITY = 1800;

  { The printer name is invalid. }
  ERROR_INVALID_PRINTER_NAME = 1801;

  { The printer already exists. }
  ERROR_PRINTER_ALREADY_EXISTS = 1802;

  { The printer command is invalid. }
  ERROR_INVALID_PRINTER_COMMAND = 1803;

  { The specified datatype is invalid. }
  ERROR_INVALID_DATATYPE = 1804;

  { The Environment specified is invalid. }
  ERROR_INVALID_ENVIRONMENT = 1805;

  { There are no more bindings. }
  RPC_S_NO_MORE_BINDINGS = 1806;

  { The account used is an interdomain trust account.  Use your global user account or local user account to access this server. }
  ERROR_NOLOGON_INTERDOMAIN_TRUST_ACCOUNT = 1807;

  { The account used is a Computer Account.  Use your global user account or local user account to access this server. }
  ERROR_NOLOGON_WORKSTATION_TRUST_ACCOUNT = 1808;

  { The account used is an server trust account.  Use your global user account or local user account to access this server. }
  ERROR_NOLOGON_SERVER_TRUST_ACCOUNT = 1809;

  { The name or security ID (SID) of the domain specified is inconsistent }
  { with the trust information for that domain. }
  ERROR_DOMAIN_TRUST_INCONSISTENT = 1810;

  { The server is in use and cannot be unloaded. }
  ERROR_SERVER_HAS_OPEN_HANDLES = 1811;

  { The specified image file did not contain a resource section. }
  ERROR_RESOURCE_DATA_NOT_FOUND = 1812;

  { The specified resource type can not be found in the image file. }
  ERROR_RESOURCE_TYPE_NOT_FOUND = 1813;

  { The specified resource name can not be found in the image file. }
  ERROR_RESOURCE_NAME_NOT_FOUND = 1814;

  { The specified resource language ID cannot be found in the image file. }
  ERROR_RESOURCE_LANG_NOT_FOUND = 1815;

  { Not enough quota is available to process this command. }
  ERROR_NOT_ENOUGH_QUOTA = 1816;

  { No interfaces have been registered. }
  RPC_S_NO_INTERFACES = 1817;

  { The server was altered while processing this call. }
  RPC_S_CALL_CANCELLED = 1818;

  { The binding handle does not contain all required information. }
  RPC_S_BINDING_INCOMPLETE = 1819;

  { Communications failure. }
  RPC_S_COMM_FAILURE = 1820;

  { The requested authentication level is not supported. }
  RPC_S_UNSUPPORTED_AUTHN_LEVEL = 1821;

  { No principal name registered. }
  RPC_S_NO_PRINC_NAME = 1822;

  { The error specified is not a valid Windows NT RPC error code. }
  RPC_S_NOT_RPC_ERROR = 1823;

  { A UUID that is valid only on this computer has been allocated. }
  RPC_S_UUID_LOCAL_ONLY = 1824;

  { A security package specific error occurred. }
  RPC_S_SEC_PKG_ERROR = 1825;

  { Thread is not cancelled. }
  RPC_S_NOT_CANCELLED = 1826;

  { Invalid operation on the encoding/decoding handle. }
  RPC_X_INVALID_ES_ACTION = 1827;

  { Incompatible version of the serializing package. }
  RPC_X_WRONG_ES_VERSION = 1828;

  { Incompatible version of the RPC stub. }
  RPC_X_WRONG_STUB_VERSION = 1829;

  { The idl pipe object is invalid or corrupted. }
  RPC_X_INVALID_PIPE_OBJECT = 1830;

  { The operation is invalid for a given idl pipe object. }
  RPC_X_INVALID_PIPE_OPERATION = 1831;

  { The idl pipe version is not supported. }
  RPC_X_WRONG_PIPE_VERSION = 1832;

  { The group member was not found. }
  RPC_S_GROUP_MEMBER_NOT_FOUND = 1898;

  { The endpoint mapper database could not be created. }
  EPT_S_CANT_CREATE = 1899;

  { The object universal unique identifier (UUID) is the nil UUID. }
  RPC_S_INVALID_OBJECT = 1900;

  { The specified time is invalid. }
  ERROR_INVALID_TIME = 1901;

  { The specified Form name is invalid. }
  ERROR_INVALID_FORM_NAME = 1902;

  { The specified Form size is invalid }
  ERROR_INVALID_FORM_SIZE = 1903;

  { The specified Printer handle is already being waited on }
  ERROR_ALREADY_WAITING = 1904;

  { The specified Printer has been deleted }
  ERROR_PRINTER_DELETED = 1905;

  { The state of the Printer is invalid }
  ERROR_INVALID_PRINTER_STATE = 1906;

  { The user must change his password before he logs on the first time. }
  ERROR_PASSWORD_MUST_CHANGE = 1907;

  { Could not find the domain controller for this domain. }
  ERROR_DOMAIN_CONTROLLER_NOT_FOUND = 1908;

  { The referenced account is currently locked out and may not be logged on to. }
  ERROR_ACCOUNT_LOCKED_OUT = 1909;

  { The object exporter specified was not found. }
  OR_INVALID_OXID = 1910;

  { The object specified was not found. }
  OR_INVALID_OID = 1911;

  { The object resolver set specified was not found. }
  OR_INVALID_SET = 1912;

  { Some data remains to be sent in the request buffer. }
  RPC_S_SEND_INCOMPLETE = 1913;

  { The list of servers for this workgroup is not currently available }
  ERROR_NO_BROWSER_SERVERS_FOUND = 6118;


{ OpenGL Error Code }

  { The pixel format is invalid. }
  ERROR_INVALID_PIXEL_FORMAT = 2000;

  { The specified driver is invalid. }
  ERROR_BAD_DRIVER = 2001;

  { The window style or class attribute is invalid for this operation. }
  ERROR_INVALID_WINDOW_STYLE = 2002;

  { The requested metafile operation is not supported. }
  ERROR_METAFILE_NOT_SUPPORTED = 2003;

  { The requested transformation operation is not supported. }
  ERROR_TRANSFORM_NOT_SUPPORTED = 2004;

  { The requested clipping operation is not supported. }
  ERROR_CLIPPING_NOT_SUPPORTED = 2005;


{ Win32 Spooler Error Codes }

  { The specified print monitor is unknown. }
  ERROR_UNKNOWN_PRINT_MONITOR = 3000;

  { The specified printer driver is currently in use. }
  ERROR_PRINTER_DRIVER_IN_USE = 3001;

  { The spool file was not found. }
  ERROR_SPOOL_FILE_NOT_FOUND = 3002;

  { A StartDocPrinter call was not issued. }
  ERROR_SPL_NO_STARTDOC = 3003;

  { An AddJob call was not issued. }
  ERROR_SPL_NO_ADDJOB = 3004;

  { The specified print processor has already been installed. }
  ERROR_PRINT_PROCESSOR_ALREADY_INSTALLED = 3005;

  { The specified print monitor has already been installed. }
  ERROR_PRINT_MONITOR_ALREADY_INSTALLED = 3006;

  { The specified print monitor does not have the required functions. }
  ERROR_INVALID_PRINT_MONITOR = 3007;

  { The specified print monitor is currently in use. }
  ERROR_PRINT_MONITOR_IN_USE = 3008;

  { The requested operation is not allowed when there are jobs queued to the printer. }
  ERROR_PRINTER_HAS_JOBS_QUEUED = 3009;

  { The requested operation is successful.  Changes will not be effective until the system is rebooted. }
  ERROR_SUCCESS_REBOOT_REQUIRED = 3010;

  { The requested operation is successful.  Changes will not be effective until the service is restarted. }
  ERROR_SUCCESS_RESTART_REQUIRED = 3011;


{ Wins Error Codes }

  { WINS encountered an error while processing the command. }
  ERROR_WINS_INTERNAL = 4000;

  { The local WINS can not be deleted. }
  ERROR_CAN_NOT_DEL_LOCAL_WINS = 4001;

  { The importation from the file failed. }
  ERROR_STATIC_INIT = 4002;

  { The backup Failed.  Was a full backup done before ? }
  ERROR_INC_BACKUP = 4003;

  { The backup Failed.  Check the directory that you are backing the database to. }
  ERROR_FULL_BACKUP = 4004;

  { The name does not exist in the WINS database. }
  ERROR_REC_NON_EXISTENT = 4005;

  { Replication with a non-configured partner is not allowed. }
  ERROR_RPL_NOT_ALLOWED = 4006;


{------------------------------}
{     OLE Error Codes          }
{------------------------------}

(*
  The return value of OLE APIs and methods is an HRESULT.
  This is not a handle to anything, but is merely a 32-bit value
  with several fields encoded in the value.  The parts of an
  HRESULT are shown below.

  HRESULTs are 32 bit values layed out as follows:

   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
  +-+-+-+-+-+---------------------+-------------------------------+
  |S|R|C|N|r|    Facility         |               Code            |
  +-+-+-+-+-+---------------------+-------------------------------+

  where

      S - Severity - indicates success/fail
          0 - Success
          1 - Fail (COERROR)

      R - reserved portion of the facility code, corresponds to NT's
              second severity bit.

      C - reserved portion of the facility code, corresponds to NT's
              C field.

      N - reserved portion of the facility code. Used to indicate a
              mapped NT status value.

      r - reserved portion of the facility code. Reserved for internal
              use. Used to indicate HRESULT values that are not status
              values, but are instead message ids for display strings.

      Facility - is the facility code

      Code - is the facility's status code
*)

const
  { Severity values }
  SEVERITY_SUCCESS = 0;
  SEVERITY_ERROR = 1;

function Succeeded(Status: HRESULT): BOOL;

{ and the inverse }
function Failed(Status: HRESULT): BOOL;

{ Generic test for error on any status value. }
function IsError(Status: HRESULT): BOOL;

{ Return the code }
function HResultCode(hr: HRESULT): Integer;

{ Return the facility }
function HResultFacility(hr: HRESULT): Integer;

{ Return the severity }
function HResultSeverity(hr: HRESULT): Integer;

{ Create an HRESULT value from component pieces }
function MakeResult(sev, fac, code: Integer): HResult;

{ Map a WIN32 error value into a HRESULT }
{ Note: This assumes that WIN32 errors fall in the range -32k to 32k. }
const
  { Define bits here so macros are guaranteed to work }
  FACILITY_NT_BIT = $10000000;
function HResultFromWin32(x: Integer): HRESULT;

{ Map an NT status value into a HRESULT }
function HResultFromNT(x: Integer): HRESULT;

const
  { HRESULT value definitions }
  { Codes $4000-$40ff are reserved for OLE }

  { Success codes }
  S_OK    = $00000000;
  S_FALSE = $00000001;

  NOERROR = 0;

  { Catastrophic failure }
  E_UNEXPECTED = HRESULT($8000FFFF);

  { Not implemented }
  E_NOTIMPL = HRESULT($80004001);

  { Ran out of memory }
  E_OUTOFMEMORY = HRESULT($8007000E);

  { One or more arguments are invalid }
  E_INVALIDARG = HRESULT($80070057);

  { No such interface supported }
  E_NOINTERFACE = HRESULT($80004002);

  { Invalid pointer }
  E_POINTER = HRESULT($80004003);

  { Invalid handle }
  E_HANDLE = HRESULT($80070006);

  { Operation aborted }
  E_ABORT = HRESULT($80004004);

  { Unspecified error }
  E_FAIL = HRESULT($80004005);

  { General access denied error }
  E_ACCESSDENIED = HRESULT($80070005);

  { The data necessary to complete this operation is not yet available. }
  E_PENDING = HRESULT($8000000A);

  { Thread local storage failure }
  CO_E_INIT_TLS = HRESULT($80004006);

  { Get shared memory allocator failure }
  CO_E_INIT_SHARED_ALLOCATOR = HRESULT($80004007);

  { Get memory allocator failure }
  CO_E_INIT_MEMORY_ALLOCATOR = HRESULT($80004008);

  { Unable to initialize class cache }
  CO_E_INIT_CLASS_CACHE = HRESULT($80004009);

  { Unable to initialize RPC services }
  CO_E_INIT_RPC_CHANNEL = HRESULT($8000400A);

  { Cannot set thread local storage channel control }
  CO_E_INIT_TLS_SET_CHANNEL_CONTROL = HRESULT($8000400B);

  { Could not allocate thread local storage channel control }
  CO_E_INIT_TLS_CHANNEL_CONTROL = HRESULT($8000400C);

  { The user supplied memory allocator is unacceptable }
  CO_E_INIT_UNACCEPTED_USER_ALLOCATOR = HRESULT($8000400D);

  { The OLE service mutex already exists }
  CO_E_INIT_SCM_MUTEX_EXISTS = HRESULT($8000400E);

  { The OLE service file mapping already exists }
  CO_E_INIT_SCM_FILE_MAPPING_EXISTS = HRESULT($8000400F);

  { Unable to map view of file for OLE service }
  CO_E_INIT_SCM_MAP_VIEW_OF_FILE = HRESULT($80004010);

  { Failure attempting to launch OLE service }
  CO_E_INIT_SCM_EXEC_FAILURE = HRESULT($80004011);

  { There was an attempt to call CoInitialize a second time while single threaded }
  CO_E_INIT_ONLY_SINGLE_THREADED = HRESULT($80004012);

  { A Remote activation was necessary but was not allowed }
  CO_E_CANT_REMOTE = HRESULT($80004013);

  { A Remote activation was necessary but the server name provided was invalid }
  CO_E_BAD_SERVER_NAME = HRESULT($80004014);

  { The class is configured to run as a security id different from the caller }
  CO_E_WRONG_SERVER_IDENTITY = HRESULT($80004015);

  { Use of Ole1 services requiring DDE windows is disabled }
  CO_E_OLE1DDE_DISABLED = HRESULT($80004016);

  { A RunAs specification must be <domain name>\<user name> or simply <user name> }
  CO_E_RUNAS_SYNTAX = HRESULT($80004017);

  { The server process could not be started.  The pathname may be incorrect. }
  CO_E_CREATEPROCESS_FAILURE = HRESULT($80004018);

  { The server process could not be started as the configured identity.  The pathname may be incorrect or unavailable. }
  CO_E_RUNAS_CREATEPROCESS_FAILURE = HRESULT($80004019);

  { The server process could not be started because the configured identity is incorrect.  Check the username and password. }
  CO_E_RUNAS_LOGON_FAILURE = HRESULT($8000401A);

  { The client is not allowed to launch this server. }
  CO_E_LAUNCH_PERMSSION_DENIED = HRESULT($8000401B);

  { The service providing this server could not be started. }
  CO_E_START_SERVICE_FAILURE = HRESULT($8000401C);

  { This computer was unable to communicate with the computer providing the server. }
  CO_E_REMOTE_COMMUNICATION_FAILURE = HRESULT($8000401D);

  { The server did not respond after being launched. }
  CO_E_SERVER_START_TIMEOUT = HRESULT($8000401E);

  { The registration information for this server is inconsistent or incomplete. }
  CO_E_CLSREG_INCONSISTENT = HRESULT($8000401F);

  { The registration information for this interface is inconsistent or incomplete. }
  CO_E_IIDREG_INCONSISTENT = HRESULT($80004020);

  { The operation attempted is not supported. }
  CO_E_NOT_SUPPORTED = HRESULT($80004021);


  { FACILITY_ITF }
  { Codes $0-$01ff are reserved for the OLE group of }

  { Generic OLE errors that may be returned by many inerfaces}
  OLE_E_FIRST = HRESULT($80040000);
  OLE_E_LAST  = HRESULT($800400FF);
  OLE_S_FIRST = $40000;
  OLE_S_LAST  = $400FF;

  { Invalid OLEVERB structure }
  OLE_E_OLEVERB = HRESULT($80040000);

  { Invalid advise flags }
  OLE_E_ADVF = HRESULT($80040001);

  { Can't enumerate any more, because the associated data is missing }
  OLE_E_ENUM_NOMORE = HRESULT($80040002);

  { This implementation doesn't take advises }
  OLE_E_ADVISENOTSUPPORTED = HRESULT($80040003);

  { There is no connection for this connection ID }
  OLE_E_NOCONNECTION = HRESULT($80040004);

  { Need to run the object to perform this operation }
  OLE_E_NOTRUNNING = HRESULT($80040005);

  { There is no cache to operate on }
  OLE_E_NOCACHE = HRESULT($80040006);

  { Uninitialized object }
  OLE_E_BLANK = HRESULT($80040007);

  { Linked object's source class has changed }
  OLE_E_CLASSDIFF = HRESULT($80040008);

  { Not able to get the moniker of the object }
  OLE_E_CANT_GETMONIKER = HRESULT($80040009);

  { Not able to bind to the source }
  OLE_E_CANT_BINDTOSOURCE = HRESULT($8004000A);

  { Object is static; operation not allowed }
  OLE_E_STATIC = HRESULT($8004000B);

  { User cancelled out of save dialog }
  OLE_E_PROMPTSAVECANCELLED = HRESULT($8004000C);

  { Invalid rectangle }
  OLE_E_INVALIDRECT = HRESULT($8004000D);

  { compobj.dll is too old for the ole2.dll initialized }
  OLE_E_WRONGCOMPOBJ = HRESULT($8004000E);

  { Invalid window handle }
  OLE_E_INVALIDHWND = HRESULT($8004000F);

  { Object is not in any of the inplace active states }
  OLE_E_NOT_INPLACEACTIVE = HRESULT($80040010);

  { Not able to convert object }
  OLE_E_CANTCONVERT = HRESULT($80040011);

  OLE_E_NOSTORAGE = HRESULT($80040012);

  { Invalid FORMATETC structure }
  DV_E_FORMATETC = HRESULT($80040064);

  { Invalid DVTARGETDEVICE structure }
  DV_E_DVTARGETDEVICE = HRESULT($80040065);

  { Invalid STDGMEDIUM structure }
  DV_E_STGMEDIUM = HRESULT($80040066);

  { Invalid STATDATA structure }
  DV_E_STATDATA = HRESULT($80040067);

  { Invalid lindex }
  DV_E_LINDEX = HRESULT($80040068);

  { Invalid tymed }
  DV_E_TYMED = HRESULT($80040069);

  { Invalid clipboard format }
  DV_E_CLIPFORMAT = HRESULT($8004006A);

  { Invalid aspect(s) }
  DV_E_DVASPECT = HRESULT($8004006B);

  { tdSize parameter of the DVTARGETDEVICE structure is invalid }
  DV_E_DVTARGETDEVICE_SIZE = HRESULT($8004006C);

  { Object doesn't support IViewObject interface }
  DV_E_NOIVIEWOBJECT = HRESULT($8004006D);

  DRAGDROP_E_FIRST = HRESULT($80040100);
  DRAGDROP_E_LAST  = HRESULT($8004010F);
  DRAGDROP_S_FIRST = $40100;

  { Trying to revoke a drop target that has not been registered }
  DRAGDROP_E_NOTREGISTERED = HRESULT($80040100);

  { This window has already been registered as a drop target }
  DRAGDROP_E_ALREADYREGISTERED = HRESULT($80040101);

  { Invalid window handle }
  DRAGDROP_E_INVALIDHWND = HRESULT($80040102);

  CLASSFACTORY_E_FIRST = HRESULT($80040110);
  CLASSFACTORY_E_LAST  = HRESULT($8004011F);
  CLASSFACTORY_S_FIRST = $40110;

  { Class does not support aggregation (or class object is remote) }
  CLASS_E_NOAGGREGATION = HRESULT($80040110);

  { ClassFactory cannot supply requested class }
  CLASS_E_CLASSNOTAVAILABLE = HRESULT($80040111);

  MARSHAL_E_FIRST = HRESULT($80040120);
  MARSHAL_E_LAST  = HRESULT($8004012F);
  MARSHAL_S_FIRST = $40120;
  MARSHAL_S_LAST  = $4012F;
  DATA_E_FIRST    = HRESULT($80040130);
  DATA_E_LAST     = HRESULT($8004013F);
  DATA_S_FIRST    = $40130;
  DATA_S_LAST     = $4013F;
  VIEW_E_FIRST    = HRESULT($80040140);
  VIEW_E_LAST     = HRESULT($8004014F);
  VIEW_S_FIRST    = $40140;

  { Error drawing view }
  VIEW_E_DRAW = HRESULT($80040140);

  REGDB_E_FIRST = HRESULT($80040150);
  REGDB_E_LAST  = HRESULT($8004015F);
  REGDB_S_FIRST = $40150;

  { Could not read key from registry }
  REGDB_E_READREGDB = HRESULT($80040150);

  { Could not write key to registry }
  REGDB_E_WRITEREGDB = HRESULT($80040151);

  { Could not find the key in the registry }
  REGDB_E_KEYMISSING = HRESULT($80040152);

  { Invalid value for registry }
  REGDB_E_INVALIDVALUE = HRESULT($80040153);

  { Class not registered }
  REGDB_E_CLASSNOTREG = HRESULT($80040154);

  { Interface not registered }
  REGDB_E_IIDNOTREG = HRESULT($80040155);

  CACHE_E_FIRST = HRESULT($80040170);
  CACHE_E_LAST  = HRESULT($8004017F);
  CACHE_S_FIRST = $40170;

  { Cache not updated }
  CACHE_E_NOCACHE_UPDATED = HRESULT($80040170);

  OLEOBJ_E_FIRST = HRESULT($80040180);
  OLEOBJ_E_LAST  = HRESULT($8004018F);
  OLEOBJ_S_FIRST = $40180;

  { No verbs for OLE object }
  OLEOBJ_E_NOVERBS = HRESULT($80040180);

  { Invalid verb for OLE object }
  OLEOBJ_E_INVALIDVERB = HRESULT($80040181);

  CLIENTSITE_E_FIRST = HRESULT($80040190);
  CLIENTSITE_E_LAST = HRESULT($8004019F);
  CLIENTSITE_S_FIRST = $40190;

  { Undo is not available }
  INPLACE_E_NOTUNDOABLE = HRESULT($800401A0);

  { Space for tools is not available }
  INPLACE_E_NOTOOLSPACE = HRESULT($800401A1);

  INPLACE_E_FIRST = HRESULT($800401A0);
  INPLACE_E_LAST  = HRESULT($800401AF);
  INPLACE_S_FIRST = $401A0;
  INPLACE_S_LAST  = $401AF;
  ENUM_E_FIRST = HRESULT($800401B0);
  ENUM_E_LAST  = HRESULT($800401BF);
  ENUM_S_FIRST = $401B0;
  ENUM_S_LAST  = $401BF;
  CONVERT10_E_FIRST = HRESULT($800401C0);
  CONVERT10_E_LAST  = HRESULT($800401CF);
  CONVERT10_S_FIRST = $401C0;

  { OLESTREAM Get method failed }
  CONVERT10_E_OLESTREAM_GET = HRESULT($800401C0);

  { OLESTREAM Put method failed }
  CONVERT10_E_OLESTREAM_PUT = HRESULT($800401C1);

  { Contents of the OLESTREAM not in correct format }
  CONVERT10_E_OLESTREAM_FMT = HRESULT($800401C2);

  { There was an error in a Windows GDI call while converting the bitmap to a DIB }
  CONVERT10_E_OLESTREAM_BITMAP_TO_DIB = HRESULT($800401C3);

  { Contents of the IStorage not in correct format }
  CONVERT10_E_STG_FMT = HRESULT($800401C4);

  { Contents of IStorage is missing one of the standard streams }
  CONVERT10_E_STG_NO_STD_STREAM = HRESULT($800401C5);

  CONVERT10_E_STG_DIB_TO_BITMAP = HRESULT($800401C6);

  CLIPBRD_E_FIRST = HRESULT($800401D0);
  CLIPBRD_E_LAST  = HRESULT($800401DF);
  CLIPBRD_S_FIRST = $401D0;

  { OpenClipboard Failed }
  CLIPBRD_E_CANT_OPEN = HRESULT($800401D0);

  { EmptyClipboard Failed }
  CLIPBRD_E_CANT_EMPTY = HRESULT($800401D1);

  { SetClipboard Failed }
  CLIPBRD_E_CANT_SET = HRESULT($800401D2);

  { Data on clipboard is invalid }
  CLIPBRD_E_BAD_DATA = HRESULT($800401D3);

  { CloseClipboard Failed }
  CLIPBRD_E_CANT_CLOSE = HRESULT($800401D4);

  MK_E_FIRST = HRESULT($800401E0);
  MK_E_LAST  = HRESULT($800401EF);
  MK_S_FIRST = $401E0;

  { Moniker needs to be connected manually }
  MK_E_CONNECTMANUALLY = HRESULT($800401E0);

  { Operation exceeded deadline }
  MK_E_EXCEEDEDDEADLINE = HRESULT($800401E1);

  { Moniker needs to be generic }
  MK_E_NEEDGENERIC = HRESULT($800401E2);

  { Operation unavailable }
  MK_E_UNAVAILABLE = HRESULT($800401E3);

  { Invalid syntax }
  MK_E_SYNTAX = HRESULT($800401E4);

  { No object for moniker }
  MK_E_NOOBJECT = HRESULT($800401E5);

  { Bad extension for file }
  MK_E_INVALIDEXTENSION = HRESULT($800401E6);

  { Intermediate operation failed }
  MK_E_INTERMEDIATEINTERFACENOTSUPPORTED = HRESULT($800401E7);

  { Moniker is not bindable }
  MK_E_NOTBINDABLE = HRESULT($800401E8);

  { Moniker is not bound }
  MK_E_NOTBOUND = HRESULT($800401E9);

  { Moniker cannot open file }
  MK_E_CANTOPENFILE = HRESULT($800401EA);

  { User input required for operation to succeed }
  MK_E_MUSTBOTHERUSER = HRESULT($800401EB);

  { Moniker class has no inverse }
  MK_E_NOINVERSE = HRESULT($800401EC);

  { Moniker does not refer to storage }
  MK_E_NOSTORAGE = HRESULT($800401ED);

  { No common prefix }
  MK_E_NOPREFIX = HRESULT($800401EE);

  { Moniker could not be enumerated }
  MK_E_ENUMERATION_FAILED = HRESULT($800401EF);

  CO_E_FIRST = HRESULT($800401F0);
  CO_E_LAST  = HRESULT($800401FF);
  CO_S_FIRST = $401F0;

  { CoInitialize has not been called. }
  CO_E_NOTINITIALIZED = HRESULT($800401F0);

  { CoInitialize has already been called. }
  CO_E_ALREADYINITIALIZED = HRESULT($800401F1);

  { Class of object cannot be determined }
  CO_E_CANTDETERMINECLASS = HRESULT($800401F2);

  { Invalid class string }
  CO_E_CLASSSTRING = HRESULT($800401F3);

  { Invalid interface string }
  CO_E_IIDSTRING = HRESULT($800401F4);

  { Application not found }
  CO_E_APPNOTFOUND = HRESULT($800401F5);

  { Application cannot be run more than once }
  CO_E_APPSINGLEUSE = HRESULT($800401F6);

  { Some error in application program }
  CO_E_ERRORINAPP = HRESULT($800401F7);

  { DLL for class not found }
  CO_E_DLLNOTFOUND = HRESULT($800401F8);

  { Error in the DLL }
  CO_E_ERRORINDLL = HRESULT($800401F9);

  { Wrong OS or OS version for application }
  CO_E_WRONGOSFORAPP = HRESULT($800401FA);

  { Object is not registered }
  CO_E_OBJNOTREG = HRESULT($800401FB);

  { Object is already registered }
  CO_E_OBJISREG = HRESULT($800401FC);

  { Object is not connected to server }
  CO_E_OBJNOTCONNECTED = HRESULT($800401FD);

  { Application was launched but it didn't register a class factory }
  CO_E_APPDIDNTREG = HRESULT($800401FE);

  { Object has been released }
  CO_E_RELEASED = HRESULT($800401FF);

  { Use the registry database to provide the requested information }
  OLE_S_USEREG = $40000;

  { Success, but static }
  OLE_S_STATIC = $40001;

  { Macintosh clipboard format }
  OLE_S_MAC_CLIPFORMAT = $40002;

  { Successful drop took place }
  DRAGDROP_S_DROP = $40100;

  { Drag-drop operation canceled }
  DRAGDROP_S_CANCEL = $40101;

  { Use the default cursor }
  DRAGDROP_S_USEDEFAULTCURSORS = $40102;

  { Data has same FORMATETC }
  DATA_S_SAMEFORMATETC = $40130;

  { View is already frozen }
  VIEW_S_ALREADY_FROZEN = $40140;

  { FORMATETC not supported }
  CACHE_S_FORMATETC_NOTSUPPORTED = $40170;

  { Same cache }
  CACHE_S_SAMECACHE = $40171;

  { Some cache(s) not updated }
  CACHE_S_SOMECACHES_NOTUPDATED = $40172;

  { Invalid verb for OLE object }
  OLEOBJ_S_INVALIDVERB = $40180;

  { Verb number is valid but verb cannot be done now }
  OLEOBJ_S_CANNOT_DOVERB_NOW = $40181;

  { Invalid window handle passed }
  OLEOBJ_S_INVALIDHWND = $40182;

  { Message is too long; some of it had to be truncated before displaying }
  INPLACE_S_TRUNCATED = $401A0;

  { Unable to convert OLESTREAM to IStorage }
  CONVERT10_S_NO_PRESENTATION = $401C0;

  { Moniker reduced to itself }
  MK_S_REDUCED_TO_SELF = $401E2;

  { Common prefix is this moniker }
  MK_S_ME = $401E4;

  { Common prefix is input moniker }
  MK_S_HIM = $401E5;

  { Common prefix is both monikers }
  MK_S_US = $401E6;

  { Moniker is already registered in running object table }
  MK_S_MONIKERALREADYREGISTERED = $401E7;


  { FACILITY_WINDOWS }
  { Codes $0-$01ff are reserved for the OLE group of}

  { Attempt to create a class object failed }
  CO_E_CLASS_CREATE_FAILED = HRESULT($80080001);

  { OLE service could not bind object }
  CO_E_SCM_ERROR = HRESULT($80080002);

  { RPC communication failed with OLE service }
  CO_E_SCM_RPC_FAILURE = HRESULT($80080003);

  { Bad path to object }
  CO_E_BAD_PATH = HRESULT($80080004);

  { Server execution failed }
  CO_E_SERVER_EXEC_FAILURE = HRESULT($80080005);

  { OLE service could not communicate with the object server }
  CO_E_OBJSRV_RPC_FAILURE = HRESULT($80080006);

  { Moniker path could not be normalized }
  MK_E_NO_NORMALIZED = HRESULT($80080007);

  { Object server is stopping when OLE service contacts it }
  CO_E_SERVER_STOPPING = HRESULT($80080008);

  { An invalid root block pointer was specified }
  MEM_E_INVALID_ROOT = HRESULT($80080009);

  { An allocation chain contained an invalid link pointer }
  MEM_E_INVALID_LINK = HRESULT($80080010);

  { The requested allocation size was too large }
  MEM_E_INVALID_SIZE = HRESULT($80080011);

  { Not all the requested interfaces were available }
  CO_S_NOTALLINTERFACES = $00080012;


  { FACILITY_DISPATCH }

  { Unknown interface. }
  DISP_E_UNKNOWNINTERFACE = HRESULT($80020001);

  { Member not found. }
  DISP_E_MEMBERNOTFOUND = HRESULT($80020003);

  { Parameter not found. }
  DISP_E_PARAMNOTFOUND = HRESULT($80020004);

  { Type mismatch. }
  DISP_E_TYPEMISMATCH = HRESULT($80020005);

  { Unknown name. }
  DISP_E_UNKNOWNNAME = HRESULT($80020006);

  { No named arguments. }
  DISP_E_NONAMEDARGS = HRESULT($80020007);

  { Bad variable type. }
  DISP_E_BADVARTYPE = HRESULT($80020008);

  { Exception occurred. }
  DISP_E_EXCEPTION = HRESULT($80020009);

  { Out of present range. }
  DISP_E_OVERFLOW = HRESULT($8002000A);

  { Invalid index. }
  DISP_E_BADINDEX = HRESULT($8002000B);

  { Unknown language. }
  DISP_E_UNKNOWNLCID = HRESULT($8002000C);

  { Memory is locked. }
  DISP_E_ARRAYISLOCKED = HRESULT($8002000D);

  { Invalid number of parameters. }
  DISP_E_BADPARAMCOUNT = HRESULT($8002000E);

  { Parameter not optional. }
  DISP_E_PARAMNOTOPTIONAL = HRESULT($8002000F);

  { Invalid callee. }
  DISP_E_BADCALLEE = HRESULT($80020010);

  { Does not support a collection. }
  DISP_E_NOTACOLLECTION = HRESULT($80020011);

  { Buffer too small. }
  TYPE_E_BUFFERTOOSMALL = HRESULT($80028016);

  { Old format or invalid type library. }
  TYPE_E_INVDATAREAD = HRESULT($80028018);

  { Old format or invalid type library. }
  TYPE_E_UNSUPFORMAT = HRESULT($80028019);

  { Error accessing the OLE registry. }
  TYPE_E_REGISTRYACCESS = HRESULT($8002801C);

  { Library not registered. }
  TYPE_E_LIBNOTREGISTERED = HRESULT($8002801D);

  { Bound to unknown type. }
  TYPE_E_UNDEFINEDTYPE = HRESULT($80028027);

  { Qualified name disallowed. }
  TYPE_E_QUALIFIEDNAMEDISALLOWED = HRESULT($80028028);

  { Invalid forward reference, or reference to uncompiled type. }
  TYPE_E_INVALIDSTATE = HRESULT($80028029);

  { Type mismatch. }
  TYPE_E_WRONGTYPEKIND = HRESULT($8002802A);

  { Element not found. }
  TYPE_E_ELEMENTNOTFOUND = HRESULT($8002802B);

  { Ambiguous name. }
  TYPE_E_AMBIGUOUSNAME = HRESULT($8002802C);

  { Name already exists in the library. }
  TYPE_E_NAMECONFLICT = HRESULT($8002802D);

  { Unknown LCID. }
  TYPE_E_UNKNOWNLCID = HRESULT($8002802E);

  { Function not defined in specified DLL. }
  TYPE_E_DLLFUNCTIONNOTFOUND = HRESULT($8002802F);

  { Wrong module kind for the operation. }
  TYPE_E_BADMODULEKIND = HRESULT($800288BD);

  { Size may not exceed 64K. }
  TYPE_E_SIZETOOBIG = HRESULT($800288C5);

  { Duplicate ID in inheritance hierarchy. }
  TYPE_E_DUPLICATEID = HRESULT($800288C6);

  { Incorrect inheritance depth in standard OLE hmember. }
  TYPE_E_INVALIDID = HRESULT($800288CF);

  { Type mismatch. }
  TYPE_E_TYPEMISMATCH = HRESULT($80028CA0);

  { Invalid number of arguments. }
  TYPE_E_OUTOFBOUNDS = HRESULT($80028CA1);

  { I/O Error. }
  TYPE_E_IOERROR = HRESULT($80028CA2);

  { Error creating unique tmp file. }
  TYPE_E_CANTCREATETMPFILE = HRESULT($80028CA3);

  { Error loading type library/DLL. }
  TYPE_E_CANTLOADLIBRARY = HRESULT($80029C4A);

  { Inconsistent property functions. }
  TYPE_E_INCONSISTENTPROPFUNCS = HRESULT($80029C83);

  { Circular dependency between types/modules. }
  TYPE_E_CIRCULARTYPE = HRESULT($80029C84);


  { FACILITY_STORAGE }

  { Unable to perform requested operation. }
  STG_E_INVALIDFUNCTION = HRESULT($80030001);

  { %l could not be found. }
  STG_E_FILENOTFOUND = HRESULT($80030002);

  { The path %l could not be found. }
  STG_E_PATHNOTFOUND = HRESULT($80030003);

  { There are insufficient resources to open another file. }
  STG_E_TOOMANYOPENFILES = HRESULT($80030004);

  { Access Denied. }
  STG_E_ACCESSDENIED = HRESULT($80030005);

  { Attempted an operation on an invalid object. }
  STG_E_INVALIDHANDLE = HRESULT($80030006);

  { There is insufficient memory available to complete operation. }
  STG_E_INSUFFICIENTMEMORY = HRESULT($80030008);

  { Invalid pointer error. }
  STG_E_INVALIDPOINTER = HRESULT($80030009);

  { There are no more entries to return. }
  STG_E_NOMOREFILES = HRESULT($80030012);

  { Disk is write-protected. }
  STG_E_DISKISWRITEPROTECTED = HRESULT($80030013);

  { An error occurred during a seek operation. }
  STG_E_SEEKERROR = HRESULT($80030019);

  { A disk error occurred during a write operation. }
  STG_E_WRITEFAULT = HRESULT($8003001D);

  { A disk error occurred during a read operation. }
  STG_E_READFAULT = HRESULT($8003001E);

  { A share violation has occurred. }
  STG_E_SHAREVIOLATION = HRESULT($80030020);

  { A lock violation has occurred. }
  STG_E_LOCKVIOLATION = HRESULT($80030021);

  { %l already exists. }
  STG_E_FILEALREADYEXISTS = HRESULT($80030050);

  { Invalid parameter error. }
  STG_E_INVALIDPARAMETER = HRESULT($80030057);

  { There is insufficient disk space to complete operation. }
  STG_E_MEDIUMFULL = HRESULT($80030070);

  { Illegal write of non-simple property to simple property set. }
  STG_E_PROPSETMISMATCHED = HRESULT($800300F0);

  { An API call exited abnormally. }
  STG_E_ABNORMALAPIEXIT = HRESULT($800300FA);

  { The file %l is not a valid compound file. }
  STG_E_INVALIDHEADER = HRESULT($800300FB);

  { The name %l is not valid. }
  STG_E_INVALIDNAME = HRESULT($800300FC);

  { An unexpected error occurred. }
  STG_E_UNKNOWN = HRESULT($800300FD);

  { That function is not implemented. }
  STG_E_UNIMPLEMENTEDFUNCTION = HRESULT($800300FE);

  { Invalid flag error. }
  STG_E_INVALIDFLAG = HRESULT($800300FF);

  { Attempted to use an object that is busy. }
  STG_E_INUSE = HRESULT($80030100);

  { The storage has been changed since the last commit. }
  STG_E_NOTCURRENT = HRESULT($80030101);

  { Attempted to use an object that has ceased to exist. }
  STG_E_REVERTED = HRESULT($80030102);

  { Can't save. }
  STG_E_CANTSAVE = HRESULT($80030103);

  { The compound file %l was produced with an incompatible version of storage. }
  STG_E_OLDFORMAT = HRESULT($80030104);

  { The compound file %l was produced with a newer version of storage. }
  STG_E_OLDDLL = HRESULT($80030105);

  { Share.exe or equivalent is required for operation. }
  STG_E_SHAREREQUIRED = HRESULT($80030106);

  { Illegal operation called on non-file based storage. }
  STG_E_NOTFILEBASEDSTORAGE = HRESULT($80030107);

  { Illegal operation called on object with extant marshallings. }
  STG_E_EXTANTMARSHALLINGS = HRESULT($80030108);

  { The docfile has been corrupted. }
  STG_E_DOCFILECORRUPT = HRESULT($80030109);

  { OLE32.DLL has been loaded at the wrong address. }
  STG_E_BADBASEADDRESS = HRESULT($80030110);

  { The file download was aborted abnormally.  The file is incomplete. }
  STG_E_INCOMPLETE = HRESULT($80030201);

  { The file download has been terminated. }
  STG_E_TERMINATED = HRESULT($80030202);

  { The underlying file was converted to compound file format. }
  STG_S_CONVERTED = $00030200;

  { The storage operation should block until more data is available. }
  STG_S_BLOCK = $00030201;

  { The storage operation should retry immediately. }
  STG_S_RETRYNOW = $00030202;

  { The notified event sink will not influence the storage operation. }
  STG_S_MONITORING = $00030203;


  { FACILITY_RPC }

  { Call was rejected by callee. }
  RPC_E_CALL_REJECTED = HRESULT($80010001);

  { Call was canceled by the message filter. }
  RPC_E_CALL_CANCELED = HRESULT($80010002);

  { The caller is dispatching an intertask SendMessage call and }
  { cannot call out via PostMessage. }
  RPC_E_CANTPOST_INSENDCALL = HRESULT($80010003);

  { The caller is dispatching an asynchronous call and cannot }
  { make an outgoing call on behalf of this call. }
  RPC_E_CANTCALLOUT_INASYNCCALL = HRESULT($80010004);

  { It is illegal to call out while inside message filter. }
  RPC_E_CANTCALLOUT_INEXTERNALCALL = HRESULT($80010005);

  { The connection terminated or is in a bogus state }
  { and cannot be used any more. Other connections }
  { are still valid. }
  RPC_E_CONNECTION_TERMINATED = HRESULT($80010006);

  { The callee (server [not server application]) is not available }
  { and disappeared; all connections are invalid.  The call may }
  { have executed. }
  RPC_E_SERVER_DIED = HRESULT($80010007);

  { The caller (client) disappeared while the callee (server) was }
  { processing a call. }
  RPC_E_CLIENT_DIED = HRESULT($80010008);

  { The data packet with the marshalled parameter data is incorrect. }
  RPC_E_INVALID_DATAPACKET = HRESULT($80010009);

  { The call was not transmitted properly; the message queue }
  { was full and was not emptied after yielding. }
  RPC_E_CANTTRANSMIT_CALL = HRESULT($8001000A);

  { The client (caller) cannot marshall the parameter data - low memory, etc. }
  RPC_E_CLIENT_CANTMARSHAL_DATA = HRESULT($8001000B);

  { The client (caller) cannot unmarshall the return data - low memory, etc. }
  RPC_E_CLIENT_CANTUNMARSHAL_DATA = HRESULT($8001000C);

  { The server (callee) cannot marshall the return data - low memory, etc. }
  RPC_E_SERVER_CANTMARSHAL_DATA = HRESULT($8001000D);

  { The server (callee) cannot unmarshall the parameter data - low memory, etc. }
  RPC_E_SERVER_CANTUNMARSHAL_DATA = HRESULT($8001000E);

  { Received data is invalid; could be server or client data. }
  RPC_E_INVALID_DATA = HRESULT($8001000F);

  { A particular parameter is invalid and cannot be (un)marshalled. }
  RPC_E_INVALID_PARAMETER = HRESULT($80010010);

  { There is no second outgoing call on same channel in DDE conversation. }
  RPC_E_CANTCALLOUT_AGAIN = HRESULT($80010011);

  { The callee (server [not server application]) is not available }
  { and disappeared; all connections are invalid.  The call did not execute. }
  RPC_E_SERVER_DIED_DNE = HRESULT($80010012);

  { System call failed. }
  RPC_E_SYS_CALL_FAILED = HRESULT($80010100);

  { Could not allocate some required resource (memory, events, ...) }
  RPC_E_OUT_OF_RESOURCES = HRESULT($80010101);

  { Attempted to make calls on more than one thread in single threaded mode. }
  RPC_E_ATTEMPTED_MULTITHREAD = HRESULT($80010102);

  { The requested interface is not registered on the server object. }
  RPC_E_NOT_REGISTERED = HRESULT($80010103);

  { RPC could not call the server or could not return the results of calling the server. }
  RPC_E_FAULT = HRESULT($80010104);

  { The server threw an exception. }
  RPC_E_SERVERFAULT = HRESULT($80010105);

  { Cannot change thread mode after it is set. }
  RPC_E_CHANGED_MODE = HRESULT($80010106);

  { The method called does not exist on the server. }
  RPC_E_INVALIDMETHOD = HRESULT($80010107);

  { The object invoked has disconnected from its clients. }
  RPC_E_DISCONNECTED = HRESULT($80010108);

  { The object invoked chose not to process the call now.  Try again later. }
  RPC_E_RETRY = HRESULT($80010109);

  { The message filter indicated that the application is busy. }
  RPC_E_SERVERCALL_RETRYLATER = HRESULT($8001010A);

  { The message filter rejected the call. }
  RPC_E_SERVERCALL_REJECTED = HRESULT($8001010B);

  { A call control interfaces was called with invalid data. }
  RPC_E_INVALID_CALLDATA = HRESULT($8001010C);

  { An outgoing call cannot be made since the application is dispatching an input-synchronous call. }
  RPC_E_CANTCALLOUT_ININPUTSYNCCALL = HRESULT($8001010D);

  { The application called an interface that was marshalled for a different thread. }
  RPC_E_WRONG_THREAD = HRESULT($8001010E);

  { CoInitialize has not been called on the current thread. }
  RPC_E_THREAD_NOT_INIT = HRESULT($8001010F);

  { The version of OLE on the client and server machines does not match. }
  RPC_E_VERSION_MISMATCH = HRESULT($80010110);

  { OLE received a packet with an invalid header. }
  RPC_E_INVALID_HEADER = HRESULT($80010111);

  { OLE received a packet with an invalid extension. }
  RPC_E_INVALID_EXTENSION = HRESULT($80010112);

  { The requested object or interface does not exist. }
  RPC_E_INVALID_IPID = HRESULT($80010113);

  { The requested object does not exist. }
  RPC_E_INVALID_OBJECT = HRESULT($80010114);

  { OLE has sent a request and is waiting for a reply. }
  RPC_S_CALLPENDING = HRESULT($80010115);

  { OLE is waiting before retrying a request. }
  RPC_S_WAITONTIMER = HRESULT($80010116);

  { Call context cannot be accessed after call completed. }
  RPC_E_CALL_COMPLETE = HRESULT($80010117);

  { Impersonate on unsecure calls is not supported. }
  RPC_E_UNSECURE_CALL = HRESULT($80010118);

  { Security must be initialized before any interfaces are marshalled or }
  RPC_E_TOO_LATE = HRESULT($80010119);

  { No security packages are installed on this machine or the user is not logged }
  RPC_E_NO_GOOD_SECURITY_PACKAGES = HRESULT($8001011A);

  { Access is denied. }
  RPC_E_ACCESS_DENIED = HRESULT($8001011B);

  { Remote calls are not allowed for this process. }
  RPC_E_REMOTE_DISABLED = HRESULT($8001011C);

  { The marshaled interface data packet (OBJREF) has an invalid or unknown format. }
  RPC_E_INVALID_OBJREF = HRESULT($8001011D);

  { An internal error occurred. }
  RPC_E_UNEXPECTED = HRESULT($8001FFFF);


{ FACILITY_SSPI }

  { Bad UID. }
  NTE_BAD_UID = HRESULT($80090001);

  { Bad Hash. }
  NTE_BAD_HASH = HRESULT($80090002);

  { Bad Key. }
  NTE_BAD_KEY = HRESULT($80090003);

  { Bad Length. }
  NTE_BAD_LEN = HRESULT($80090004);

  { Bad Data. }
  NTE_BAD_DATA = HRESULT($80090005);

  { Invalid Signature. }
  NTE_BAD_SIGNATURE = HRESULT($80090006);

  { Bad Version of provider. }
  NTE_BAD_VER = HRESULT($80090007);

  { Invalid algorithm specified. }
  NTE_BAD_ALGID = HRESULT($80090008);

  { Invalid flags specified. }
  NTE_BAD_FLAGS = HRESULT($80090009);

  { Invalid type specified. }
  NTE_BAD_TYPE = HRESULT($8009000A);

  { Key not valid for use in specified state. }
  NTE_BAD_KEY_STATE = HRESULT($8009000B);

  { Hash not valid for use in specified state. }
  NTE_BAD_HASH_STATE = HRESULT($8009000C);

  { Key does not exist. }
  NTE_NO_KEY = HRESULT($8009000D);

  { Insufficient memory available for the operation. }
  NTE_NO_MEMORY = HRESULT($8009000E);

  { Object already exists. }
  NTE_EXISTS = HRESULT($8009000F);

  { Access denied. }
  NTE_PERM = HRESULT($80090010);

  { Object was not found. }
  NTE_NOT_FOUND = HRESULT($80090011);

  { Data already encrypted. }
  NTE_DOUBLE_ENCRYPT = HRESULT($80090012);

  { Invalid provider specified. }
  NTE_BAD_PROVIDER = HRESULT($80090013);

  { Invalid provider type specified. }
  NTE_BAD_PROV_TYPE = HRESULT($80090014);

  { Provider's public key is invalid. }
  NTE_BAD_PUBLIC_KEY = HRESULT($80090015);

  { Keyset does not exist }
  NTE_BAD_KEYSET = HRESULT($80090016);

  { Provider type not defined. }
  NTE_PROV_TYPE_NOT_DEF = HRESULT($80090017);

  { Provider type as registered is invalid. }
  NTE_PROV_TYPE_ENTRY_BAD = HRESULT($80090018);

  { The keyset is not defined. }
  NTE_KEYSET_NOT_DEF = HRESULT($80090019);

  { Keyset as registered is invalid. }
  NTE_KEYSET_ENTRY_BAD = HRESULT($8009001A);

  { Provider type does not match registered value. }
  NTE_PROV_TYPE_NO_MATCH = HRESULT($8009001B);

  { The digital signature file is corrupt. }
  NTE_SIGNATURE_FILE_BAD = HRESULT($8009001C);

  { Provider DLL failed to initialize correctly. }
  NTE_PROVIDER_DLL_FAIL = HRESULT($8009001D);

  { Provider DLL could not be found. }
  NTE_PROV_DLL_NOT_FOUND = HRESULT($8009001E);

  { The Keyset parameter is invalid. }
  NTE_BAD_KEYSET_PARAM = HRESULT($8009001F);

  { An internal error occurred. }
  NTE_FAIL = HRESULT($80090020);

  { A base error occurred. }
  NTE_SYS_ERR = HRESULT($80090021);

  NTE_OP_OK = 0;

{ FACILITY_CERT }

  { The specified trust provider is not known on this system. }
  TRUST_E_PROVIDER_UNKNOWN = HRESULT($800B0001);

  { The trust verification action specified is not supported by the specified trust provider. }
  TRUST_E_ACTION_UNKNOWN = HRESULT($800B0002);

  { The form specified for the subject is not one supported or known by the specified trust provider. }
  TRUST_E_SUBJECT_FORM_UNKNOWN = HRESULT($800B0003);

  { The subject is not trusted for the specified action. }
  TRUST_E_SUBJECT_NOT_TRUSTED = HRESULT($800B0004);

  { Error due to problem in ASN.1 encoding process. }
  DIGSIG_E_ENCODE = HRESULT($800B0005);

  { Error due to problem in ASN.1 decoding process. }
  DIGSIG_E_DECODE = HRESULT($800B0006);

  { Reading / writing Extensions where Attributes are appropriate, and visa versa. }
  DIGSIG_E_EXTENSIBILITY = HRESULT($800B0007);

  { Unspecified cryptographic failure. }
  DIGSIG_E_CRYPTO = HRESULT($800B0008);

  { The size of the data could not be determined. }
  PERSIST_E_SIZEDEFINITE = HRESULT($800B0009);

  { The size of the indefinite-sized data could not be determined. }
  PERSIST_E_SIZEINDEFINITE = HRESULT($800B000A);

  { This object does not read and write self-sizing data. }
  PERSIST_E_NOTSELFSIZING = HRESULT($800B000B);

  { No signature was present in the subject. }
  TRUST_E_NOSIGNATURE = HRESULT($800B0100);

  { A required certificate is not within its validity period. }
  CERT_E_EXPIRED = HRESULT($800B0101);

  { The validity periods of the certification chain do not nest correctly. }
  CERT_E_VALIDIYPERIODNESTING = HRESULT($800B0102);

  { A certificate that can only be used as an end-entity is being used as a CA or visa versa. }
  CERT_E_ROLE = HRESULT($800B0103);

  { A path length constraint in the certification chain has been violated. }
  CERT_E_PATHLENCONST = HRESULT($800B0104);

  { An extension of unknown type that is labeled 'critical' is present in a certificate. }
  CERT_E_CRITICAL = HRESULT($800B0105);

  { A certificate is being used for a purpose other than that for which it is permitted. }
  CERT_E_PURPOSE = HRESULT($800B0106);

  { A parent of a given certificate in fact did not issue that child certificate. }
  CERT_E_ISSUERCHAINING = HRESULT($800B0107);

  { A certificate is missing or has an empty value for an important field, such as a subject or issuer name. }
  CERT_E_MALFORMED = HRESULT($800B0108);

  { A certification chain processed correctly, but terminated in a root certificate which isn't trusted by the trust provider. }
  CERT_E_UNTRUSTEDROOT = HRESULT($800B0109);

  { A chain of certs didn't chain as they should in a certain application of chaining. }
  CERT_E_CHAINING = HRESULT($800B010A);

{ End WINERROR.H }


  { Abnormal termination codes }

  TC_NORMAL = 0;
  TC_HARDERR = 1;
  TC_GP_TRAP = 2;
  TC_SIGNAL = 3;

  { Power Management APIs }

  AC_LINE_OFFLINE = 0;
  AC_LINE_ONLINE = 1;
  AC_LINE_BACKUP_POWER = 2;
  AC_LINE_UNKNOWN = 255;

  BATTERY_FLAG_HIGH = 1;
  BATTERY_FLAG_LOW = 2;
  BATTERY_FLAG_CRITICAL = 4;
  BATTERY_FLAG_CHARGING = 8;
  BATTERY_FLAG_NO_BATTERY = $80;
  BATTERY_FLAG_UNKNOWN = 255;
  BATTERY_PERCENTAGE_UNKNOWN = 255;
  BATTERY_LIFE_UNKNOWN = DWORD($FFFFFFFF);

type
  PSystemPowerStatus = ^TSystemPowerStatus;
  _SYSTEM_POWER_STATUS = packed record
    ACLineStatus : Byte;
    BatteryFlag : Byte;
    BatteryLifePercent : Byte;
    Reserved1 : Byte;
    BatteryLifeTime : DWORD;
    BatteryFullLifeTime : DWORD;
  end;
  TSystemPowerStatus = _SYSTEM_POWER_STATUS;
  SYSTEM_POWER_STATUS = _SYSTEM_POWER_STATUS;

function GetSystemPowerStatus(var lpSystemPowerStatus: TSystemPowerStatus): BOOL; stdcall;
function SetSystemPowerState(fSuspend, fForce: BOOL): BOOL; stdcall;


{ Win Certificate API and Structures }

{ Structures }
type
  PWinCertificate = ^TWinCertificate;
  _WIN_CERTIFICATE = packed record
    dwLength: DWORD;
    wRevision: Word;
    wCertificateType: Word;         { WIN_CERT_TYPE_xxx }
    bCertificate: packed array[0..0] of Byte;
  end;
  TWinCertificate = _WIN_CERTIFICATE;
  WIN_CERTIFICATE = _WIN_CERTIFICATE;

{ Currently, the only defined certificate revision is WIN_CERT_REVISION_1_0 }

const
  WIN_CERT_REVISION_1_0 = $0100;

{ Possible certificate types are specified by the following values }

  WIN_CERT_TYPE_X509 = $0001;                        { bCertificate contains an X.509 Certificate }
  WIN_CERT_TYPE_PKCS_SIGNED_DATA = $0002;            { bCertificate contains a PKCS SignedData structure }
  WIN_CERT_TYPE_RESERVED_1 = $0003;                  { Reserved }

{ API }

function WinSubmitCertificate(var lpCertificate: TWinCertificate): BOOL; stdcall;

{ Trust API and Structures }

function WinVerifyTrust(hwnd: HWND; const ActionID: TGUID; ActionData: Pointer): Longint; stdcall;
function WinLoadTrustProvider(ActionID: PGUID): BOOL; stdcall;

{ Common Trust API Data Structures }

{ Data type commonly used in ActionData structures }

type
  TWinTrustSubject = Pointer;

{ Two commonly used ActionData structures }

  PWinTrustActdataContextWithSubject = ^TWinTrustActdataContextWithSubject;
  _WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT = record
    hClientToken: THandle;
    SubjectType: PGUID;
    Subject: TWinTrustSubject;
  end;
  TWinTrustActdataContextWithSubject = _WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT;
  WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT = _WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT;


  PWinTrustActdataSubjectOnly = ^TWinTrustActdataSubjectOnly;
  _WIN_TRUST_ACTDATA_SUBJECT_ONLY = record
    SubjectType: PGUID;
    Subject: TWinTrustSubject;
  end;
  TWinTrustActdataSubjectOnly = _WIN_TRUST_ACTDATA_SUBJECT_ONLY;
  WIN_TRUST_ACTDATA_SUBJECT_ONLY = _WIN_TRUST_ACTDATA_SUBJECT_ONLY;


{ SUBJECT FORM DEFINITIONS }

{ Currently defined Subject Type Identifiers.  All of the below
  use the WIN_TRUST_SUBJECT_FILE subject form, defined below. }

const
{ RawFile = 959dc450-8d9e-11cf-8736-00aa00a485eb }
  WIN_TRUST_SUBJTYPE_RAW_FILE: TGUID =
    '{959dc450-8d9e-11cf-8736-00aa00a485eb}';

{ PeImage = 43c9a1e0-8da0-11cf-8736-00aa00a485eb }
  WIN_TRUST_SUBJTYPE_PE_IMAGE: TGUID =
    '{43c9a1e0-8da0-11cf-8736-00aa00a485eb}';

{ JavaClass = 08ad3990-8da1-11cf-8736-00aa00a485eb }
  WIN_TRUST_SUBJTYPE_JAVA_CLASS: TGUID =
    '{08ad3990-8da1-11cf-8736-00aa00a485eb}';

{ Cabinet = d17c5374-a392-11cf-9df5-00aa00c184e0 }
  WIN_TRUST_SUBJTYPE_CABINET: TGUID =
    '{d17c5374-a392-11cf-9df5-00aa00c184e0}';

{ Associated Subject Data Structure: }


type
  PWinTrustSubjectFile = ^TWinTrustSubjectFile;
  _WIN_TRUST_SUBJECT_FILE = record
    hFile: THandle;
    lpPath: PWideChar;
  end;
  TWinTrustSubjectFile = _WIN_TRUST_SUBJECT_FILE;
  WIN_TRUST_SUBJECT_FILE = _WIN_TRUST_SUBJECT_FILE;

{ The following subject types use the
  WIN_TRUST_SUBJECT_FILE_AND_DISPLAY subject type, defined
  below. }

const
  WIN_TRUST_SUBJTYPE_RAW_FILEEX: TGUID = (
          D1:$6f458110; D2:$c2f1; D3:$11cf; D4:($8a, $69, $0, $aa, $0, $6c, $37, $6 ));

  WIN_TRUST_SUBJTYPE_PE_IMAGEEX: TGUID = (
          D1:$6f458111; D2:$c2f1; D3:$11cf; D4:($8a, $69, $0, $aa, $0, $6c, $37, $6 ));

  WIN_TRUST_SUBJTYPE_JAVA_CLASSEX: TGUID = (
          D1:$6f458113; D2:$c2f1; D3:$11cf; D4:($8a, $69, $0, $aa, $0, $6c, $37, $6 ));

  WIN_TRUST_SUBJTYPE_CABINETEX: TGUID = (
          D1:$6f458114; D2:$c2f1; D3:$11cf; D4:($8a, $69, $0, $aa, $0, $6c, $37, $6 ));


{ Associated Subject Data Structure: }

type
  PWinTrustSubjectFileAndDisplay = ^TWinTrustSubjectFileAndDisplay;
  _WIN_TRUST_SUBJECT_FILE_AND_DISPLAY = record
    hFile: THandle;              { handle to the open file if you got it }
    lpPath: PWideString;         { the path to open if you don't }
    lpDisplayName: PWideString;  { (optional) display name to show to user }
                                 {      in place of path }
  end;
  TWinTrustSubjectFileAndDisplay = _WIN_TRUST_SUBJECT_FILE_AND_DISPLAY;
  WIN_TRUST_SUBJECT_FILE_AND_DISPLAY = _WIN_TRUST_SUBJECT_FILE_AND_DISPLAY;

{ Other subject types: }

const
{ OleStorage == c257e740-8da0-11cf-8736-00aa00a485eb }
WIN_TRUST_SUBJTYPE_OLE_STORAGE: TGUID = (
          D1:$c257e740; D2:$8da0; D3:$11cf; D4:($87, $36, $00, $aa, $00, $a4, $85, $eb));


{ TRUST PROVIDER SPECIFIC DEFINITIONS

      Each trust provider will have the following
      sections defined:

      Actions - What actions are supported by the trust
          provider.
      SubjectForms - Subjects that may be evaluated by this
          trust provider.
                     and
      Data structures to support the subject forms. }


{ Software Publisher Trust Provider }

{ Actions: }

{ TrustedPublisher == 66426730-8da1-11cf-8736-00aa00a485eb }
  WIN_SPUB_ACTION_TRUSTED_PUBLISHER: TGUID = (
          D1:$66426730; D2:$8da1; D3:$11cf; D4:($87, $36, $00, $aa, $00, $a4, $85, $eb));

{ NtActivateImage == 8bc96b00-8da1-11cf-8736-00aa00a485eb }
  WIN_SPUB_ACTION_NT_ACTIVATE_IMAGE: TGUID = (
          D1:$8bc96b00; D2:$8da1; D3:$11cf; D4:($87, $36, $00, $aa, $00, $a4, $85, $eb));

{ PublishedSoftware == 64b9d180-8da2-11cf-8736-00aa00a485eb }
  WIN_SPUB_ACTION_PUBLISHED_SOFTWARE: TGUID = (
          D1:$64b9d180; D2:$8da2; D3:$11cf; D4:($87, $36, $00, $aa, $00, $a4, $85, $eb));

{ Data Structures: }

{ WIN_SPUB_ACTION_TRUSTED_PUBLISHER:
      Uses WIN_SPUB_TRUSTED_PUBLISHER_DATA }

{ WIN_SPUB_ACTION_NT_ACTIVATE_IMAGE:
      Uses WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT }

{ WIN_SPUB_ACTION_PUBLISHED_SOFTWARE:
      Uses WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT }

type
  PWinSpubTrustedPublisherData = ^TWinSpubTrustedPublisherData;
  _WIN_SPUB_TRUSTED_PUBLISHER_DATA = record
    hClientToken: THandle;
    lpCertificate: PWinCertificate;
  end;
  TWinSpubTrustedPublisherData = _WIN_SPUB_TRUSTED_PUBLISHER_DATA;
  WIN_SPUB_TRUSTED_PUBLISHER_DATA = _WIN_SPUB_TRUSTED_PUBLISHER_DATA;

{ Translated from WINGDI.H }

const
  { Binary raster ops }
  R2_BLACK       = 1;     {  0   }
  R2_NOTMERGEPEN = 2;     { DPon }
  R2_MASKNOTPEN  = 3;     { DPna }
  R2_NOTCOPYPEN  = 4;     { PN   }
  R2_MASKPENNOT  = 5;     { PDna }
  R2_NOT         = 6;     { Dn   }
  R2_XORPEN      = 7;     { DPx  }
  R2_NOTMASKPEN  = 8;     { DPan }
  R2_MASKPEN     = 9;     { DPa  }
  R2_NOTXORPEN   = 10;    { DPxn }
  R2_NOP         = 11;    { D    }
  R2_MERGENOTPEN = 12;    { DPno }
  R2_COPYPEN     = 13;    { P    }
  R2_MERGEPENNOT = 14;    { PDno }
  R2_MERGEPEN    = 15;    { DPo  }
  R2_WHITE       = $10;   {  1   }
  R2_LAST        = $10;


  { Ternary raster operations }
  SRCCOPY     = $00CC0020;     { dest = source                    }
  SRCPAINT    = $00EE0086;     { dest = source OR dest            }
  SRCAND      = $008800C6;     { dest = source AND dest           }
  SRCINVERT   = $00660046;     { dest = source XOR dest           }
  SRCERASE    = $00440328;     { dest = source AND (NOT dest )    }
  NOTSRCCOPY  = $00330008;     { dest = (NOT source)              }
  NOTSRCERASE = $001100A6;     { dest = (NOT src) AND (NOT dest)  }
  MERGECOPY   = $00C000CA;     { dest = (source AND pattern)      }
  MERGEPAINT  = $00BB0226;     { dest = (NOT source) OR dest      }
  PATCOPY     = $00F00021;     { dest = pattern                   }
  PATPAINT    = $00FB0A09;     { dest = DPSnoo                    }
  PATINVERT   = $005A0049;     { dest = pattern XOR dest          }
  DSTINVERT   = $00550009;     { dest = (NOT dest)                }
  BLACKNESS   = $00000042;     { dest = BLACK                     }
  WHITENESS   = $00FF0062;     { dest = WHITE                     }


{ Quaternary raster codes }

function MakeROP4(fore,back: DWORD): DWORD;

const
  GDI_ERROR = DWORD($FFFFFFFF);
  HGDI_ERROR = DWORD($FFFFFFFF);


  { Region Flags }
  ERROR = 0;
  NULLREGION = 1;
  SIMPLEREGION = 2;
  COMPLEXREGION = 3;
  RGN_ERROR = ERROR;


  { CombineRgn() Styles }
  RGN_AND = 1;
  RGN_OR = 2;
  RGN_XOR = 3;
  RGN_DIFF = 4;
  RGN_COPY = 5;
  RGN_MIN = RGN_AND;
  RGN_MAX = RGN_COPY;

  { StretchBlt() Modes }
  BLACKONWHITE = 1;
  WHITEONBLACK = 2;
  COLORONCOLOR = 3;
  HALFTONE = 4;
  MAXSTRETCHBLTMODE = 4;


  { New StretchBlt() Modes }
  STRETCH_ANDSCANS = BLACKONWHITE;
  STRETCH_ORSCANS = WHITEONBLACK;
  STRETCH_DELETESCANS = COLORONCOLOR;
  STRETCH_HALFTONE = HALFTONE;


  { PolyFill() Modes }
  ALTERNATE = 1;
  WINDING = 2;
  POLYFILL_LAST = 2;


  { Text Alignment Options }
  TA_NOUPDATECP = 0;
  TA_UPDATECP = 1;
  TA_LEFT = 0;
  TA_RIGHT = 2;
  TA_CENTER = 6;
  TA_TOP = 0;
  TA_BOTTOM = 8;
  TA_BASELINE = 24;
  TA_RTLREADING = $100;
  TA_MASK =  (TA_BASELINE+TA_CENTER+TA_UPDATECP+TA_RTLREADING);

  VTA_BASELINE = TA_BASELINE;
  VTA_LEFT = TA_BOTTOM;
  VTA_RIGHT = TA_TOP;
  VTA_CENTER = TA_CENTER;
  VTA_BOTTOM = TA_RIGHT;
  VTA_TOP = TA_LEFT;

  ETO_OPAQUE = 2;
  ETO_CLIPPED = 4;
  ETO_GLYPH_INDEX = $10;
  ETO_RTLREADING = $80;
  ETO_NUMERICSLOCAL = $400;
  ETO_NUMERICSLATIN = $800;
  ETO_IGNORELANGUAGE = $1000;
  ETO_PDY = $2000;

  ASPECT_FILTERING = 1;


  { Bounds Accumulation APIs }
  DCB_RESET = 1;
  DCB_ACCUMULATE = 2;
  DCB_DIRTY = DCB_ACCUMULATE;
  DCB_SET = (DCB_RESET or DCB_ACCUMULATE);
  DCB_ENABLE = 4;
  DCB_DISABLE = 8;

  { Metafile Functions }
  META_SETBKCOLOR = 513;
  META_SETBKMODE = 258;
  META_SETMAPMODE = 259;
  META_SETROP2 = 260;
  META_SETRELABS = 261;
  META_SETPOLYFILLMODE = 262;
  META_SETSTRETCHBLTMODE = 263;
  META_SETTEXTCHAREXTRA = 264;
  META_SETTEXTCOLOR = 521;
  META_SETTEXTJUSTIFICATION = 522;
  META_SETWINDOWORG = 523;
  META_SETWINDOWEXT = 524;
  META_SETVIEWPORTORG = 525;
  META_SETVIEWPORTEXT = 526;
  META_OFFSETWINDOWORG = 527;
  META_SCALEWINDOWEXT = 1040;
  META_OFFSETVIEWPORTORG = 529;
  META_SCALEVIEWPORTEXT = 1042;
  META_LINETO = 531;
  META_MOVETO = 532;
  META_EXCLUDECLIPRECT = 1045;
  META_INTERSECTCLIPRECT = 1046;
  META_ARC = 2071;
  META_ELLIPSE = 1048;
  META_FLOODFILL = 1049;
  META_PIE = 2074;
  META_RECTANGLE = 1051;
  META_ROUNDRECT = 1564;
  META_PATBLT = 1565;
  META_SAVEDC = 30;
  META_SETPIXEL = 1055;
  META_OFFSETCLIPRGN = 544;
  META_TEXTOUT = 1313;
  META_BITBLT = 2338;
  META_STRETCHBLT = 2851;
  META_POLYGON = 804;
  META_POLYLINE = 805;
  META_ESCAPE = 1574;
  META_RESTOREDC = 295;
  META_FILLREGION = 552;
  META_FRAMEREGION = 1065;
  META_INVERTREGION = 298;
  META_PAINTREGION = 299;
  META_SELECTCLIPREGION = 300;
  META_SELECTOBJECT = 301;
  META_SETTEXTALIGN = 302;
  META_CHORD = 2096;
  META_SETMAPPERFLAGS = 561;
  META_EXTTEXTOUT = 2610;
  META_SETDIBTODEV = 3379;
  META_SELECTPALETTE = 564;
  META_REALIZEPALETTE = 53;
  META_ANIMATEPALETTE = 1078;
  META_SETPALENTRIES = 55;
  META_POLYPOLYGON = 1336;
  META_RESIZEPALETTE = 313;
  META_DIBBITBLT = 2368;
  META_DIBSTRETCHBLT = 2881;
  META_DIBCREATEPATTERNBRUSH = 322;
  META_STRETCHDIB = 3907;
  META_EXTFLOODFILL = 1352;
  META_DELETEOBJECT = 496;
  META_CREATEPALETTE = 247;
  META_CREATEPATTERNBRUSH = 505;
  META_CREATEPENINDIRECT = 762;
  META_CREATEFONTINDIRECT = 763;
  META_CREATEBRUSHINDIRECT = 764;
  META_CREATEREGION = 1791;


  { GDI Escapes }
  NEWFRAME = 1;
  _ABORTDOC = 2; { Renamed }
  NEXTBAND = 3;
  SETCOLORTABLE = 4;
  GETCOLORTABLE = 5;
  FLUSHOUTPUT = 6;
  DRAFTMODE = 7;
  QUERYESCSUPPORT = 8;
  _SETABORTPROC = 9; { Renamed }
  _STARTDOC = 10; { Renamed }
  _ENDDOC = 11; { Renamed }
  GETPHYSPAGESIZE = 12;
  GETPRINTINGOFFSET = 13;
  GETSCALINGFACTOR = 14;
  MFCOMMENT = 15;
  GETPENWIDTH = $10;
  SETCOPYCOUNT = 17;
  SELECTPAPERSOURCE = 18;
  DEVICEDATA = 19;
  PASSTHROUGH = 19;
  GETTECHNOLGY = 20;
  GETTECHNOLOGY = 20;
  SETLINECAP = 21;
  SETLINEJOIN = 22;
  _SETMITERLIMIT = 23; { Renamed }
  BANDINFO = 24;
  DRAWPATTERNRECT = 25;
  GETVECTORPENSIZE = 26;
  GETVECTORBRUSHSIZE = 27;
  ENABLEDUPLEX = 28;
  GETSETPAPERBINS = 29;
  GETSETPRINTORIENT = 30;
  ENUMPAPERBINS = 31;
  SETDIBSCALING = $20;
  EPSPRINTING = 33;
  ENUMPAPERMETRICS = 34;
  GETSETPAPERMETRICS = 35;
  POSTSCRIPT_DATA = 37;
  POSTSCRIPT_IGNORE = 38;
  MOUSETRAILS = 39;
  GETDEVICEUNITS = 42;

  GETEXTENDEDTEXTMETRICS = 256;
  GETEXTENTTABLE = 257;
  GETPAIRKERNTABLE = 258;
  GETTRACKKERNTABLE = 259;
  _EXTTEXTOUT = $200; { Renamed }
  GETFACENAME = 513;
  DOWNLOADFACE = 514;
  ENABLERELATIVEWIDTHS = 768;
  ENABLEPAIRKERNING = 769;
  SETKERNTRACK = 770;
  SETALLJUSTVALUES = 771;
  SETCHARSET = 772;

  _STRETCHBLT = $800; { Renamed }
  GETSETSCREENPARAMS = 3072;
  QUERYDIBSUPPORT = 3073;
  BEGIN_PATH = $1000;
  CLIP_TO_PATH = 4097;
  END_PATH = 4098;
  EXT_DEVICE_CAPS = 4099;
  RESTORE_CTM = 4100;
  SAVE_CTM = 4101;
  SET_ARC_DIRECTION = 4102;
  SET_BACKGROUND_COLOR = 4103;
  SET_POLY_MODE = 4104;
  SET_SCREEN_ANGLE = 4105;
  SET_SPREAD = 4106;
  TRANSFORM_CTM = 4107;
  SET_CLIP_BOX = 4108;
  SET_BOUNDS = 4109;
  SET_MIRROR_MODE = 4110;
  OPENCHANNEL = 4110;
  DOWNLOADHEADER = 4111;
  CLOSECHANNEL = 4112;
  POSTSCRIPT_PASSTHROUGH = 4115;
  ENCAPSULATED_POSTSCRIPT = 4116;

  { Flag returned from QUERYDIBSUPPORT }
  QDI_SETDIBITS = 1;
  QDI_GETDIBITS = 2;
  QDI_DIBTOSCREEN = 4;
  QDI_STRETCHDIB = 8;


  { Spooler Error Codes }
  SP_NOTREPORTED = $4000;
  SP_ERROR = LongWord(-1);
  SP_APPABORT = LongWord(-2);
  SP_USERABORT = LongWord(-3);
  SP_OUTOFDISK = LongWord(-4);
  SP_OUTOFMEMORY = LongWord(-5);

  PR_JOBSTATUS = 0;


  { Object Definitions for EnumObjects() }
  OBJ_PEN = 1;
  OBJ_BRUSH = 2;
  OBJ_DC = 3;
  OBJ_METADC = 4;
  OBJ_PAL = 5;
  OBJ_FONT = 6;
  OBJ_BITMAP = 7;
  OBJ_REGION = 8;
  OBJ_METAFILE = 9;
  OBJ_MEMDC = 10;
  OBJ_EXTPEN = 11;
  OBJ_ENHMETADC = 12;
  OBJ_ENHMETAFILE = 13;


  { xform stuff }
  MWT_IDENTITY = 1;
  MWT_LEFTMULTIPLY = 2;
  MWT_RIGHTMULTIPLY = 3;

  MWT_MIN = MWT_IDENTITY;
  MWT_MAX = MWT_RIGHTMULTIPLY;


type
  PXForm = ^TXForm;
  tagXFORM = packed record
    eM11: Single;
    eM12: Single;
    eM21: Single;
    eM22: Single;
    eDx: Single;
    eDy: Single;
  end;
  TXForm = tagXFORM;
  XFORM = tagXFORM;

{ Bitmap Header Definition }
  PBitmap = ^TBitmap;
  tagBITMAP = record
    bmType: Longint;
    bmWidth: Longint;
    bmHeight: Longint;
    bmWidthBytes: Longint;
    bmPlanes: Word;
    bmBitsPixel: Word;
    bmBits: Pointer;
  end;
  TBitmap = tagBITMAP;
  BITMAP = tagBITMAP;

  PRGBTriple = ^TRGBTriple;
  tagRGBTRIPLE = packed record
    rgbtBlue: Byte;
    rgbtGreen: Byte;
    rgbtRed: Byte;
  end;
  TRGBTriple = tagRGBTRIPLE;
  RGBTRIPLE = tagRGBTRIPLE;

  PRGBQuad = ^TRGBQuad;
  tagRGBQUAD = packed record
    rgbBlue: Byte;
    rgbGreen: Byte;
    rgbRed: Byte;
    rgbReserved: Byte;
  end;
  TRGBQuad = tagRGBQUAD;
  RGBQUAD = tagRGBQUAD;


  { Image Color Matching color definitions }
  LCSCSTYPE = Longint;
const
  LCS_CALIBRATED_RGB = 0;
  LCS_DEVICE_RGB = 1;
  LCS_DEVICE_CMYK = 2;

type
  LCSGAMUTMATCH = Longint;
const
  LCS_GM_BUSINESS = 1;
  LCS_GM_GRAPHICS = 2;
  LCS_GM_IMAGES = 4;


  { ICM Defines for results from CheckColorInGamut() }
  CM_OUT_OF_GAMUT = 255;
  CM_IN_GAMUT = 0;


{ functions to retrieve CMYK values from a COLORREF }

function GetCValue(cmyk: COLORREF): Byte;
function GetMValue(cmyk: COLORREF): Byte;
function GetYValue(cmyk: COLORREF): Byte;
function GetKValue(cmyk: COLORREF): Byte;
function CMYK(c, m, y, k: Byte): COLORREF;

type
  FXPT16DOT16 = Longint;
  LPFXPT16DOT16 = ^Longint;
  FXPT2DOT30 = Longint;
  LPFXPT2DOT30 = ^Longint;


  { ICM Color Definitions }
  { The following two structures are used for defining RGB's in terms of
    CIEXYZ. The values are fixed point 16.16. }

  PCIEXYZ = ^TCIEXYZ;
  tagCIEXYZ = packed record
    ciexyzX: FXPT2DOT30;
    ciexyzY: FXPT2DOT30;
    ciexyzZ: FXPT2DOT30;
  end;
  TCIEXYZ = tagCIEXYZ;
  CIEXYZ = tagCIEXYZ;

  PCIEXYZTriple = ^TCIEXYZTriple;
  tagICEXYZTRIPLE = packed record
    ciexyzRed: TCIEXYZ;
    ciexyzGreen: TCIEXYZ;
    ciexyzBlue: TCIEXYZ;
  end;
  TCIEXYZTriple = tagICEXYZTRIPLE;
  CIEXYZTRIPLE = tagICEXYZTRIPLE;

  { The next structures the logical color space. Unlike pens and brushes,
    but like palettes, there is only one way to create a LogColorSpace.
    A pointer to it must be passed, its elements can't be pushed as
    arguments. }

type
  PLogColorSpaceA = ^TLogColorSpaceA;
  PLogColorSpaceW = ^TLogColorSpaceW;
  PLogColorSpace = PLogColorSpaceA;
  tagLOGCOLORSPACEA = packed record
    lcsSignature: DWORD;
    lcsVersion: DWORD;
    lcsSize: DWORD;
    lcsCSType: LCSCSTYPE;
    lcsIntent: LCSGAMUTMATCH;
    lcsEndpoints: TCIEXYZTriple;
    lcsGammaRed: DWORD;
    lcsGammaGreen: DWORD;
    lcsGammaBlue: DWORD;
    lcsFilename: array[0..259] of AnsiChar;
  end;
  tagLOGCOLORSPACEW = packed record
    lcsSignature: DWORD;
    lcsVersion: DWORD;
    lcsSize: DWORD;
    lcsCSType: LCSCSTYPE;
    lcsIntent: LCSGAMUTMATCH;
    lcsEndpoints: TCIEXYZTriple;
    lcsGammaRed: DWORD;
    lcsGammaGreen: DWORD;
    lcsGammaBlue: DWORD;
    lcsFilename: array[0..259] of WideChar;
  end;
  tagLOGCOLORSPACE = tagLOGCOLORSPACEA;
  TLogColorSpaceA = tagLOGCOLORSPACEA;
  TLogColorSpaceW = tagLOGCOLORSPACEW;
  TLogColorSpace = TLogColorSpaceA;
  LOGCOLORSPACEA = tagLOGCOLORSPACEA;
  LOGCOLORSPACEW = tagLOGCOLORSPACEW;
  LOGCOLORSPACE = LOGCOLORSPACEA;

  { structures for defining DIBs - used to get to color table }
  PBitmapCoreHeader = ^TBitmapCoreHeader;
  tagBITMAPCOREHEADER = packed record
    bcSize: DWORD;
    bcWidth: Word;
    bcHeight: Word;
    bcPlanes: Word;
    bcBitCount: Word;
  end;
  TBitmapCoreHeader = tagBITMAPCOREHEADER;
  BITMAPCOREHEADER = tagBITMAPCOREHEADER;

  PBitmapInfoHeader = ^TBitmapInfoHeader;
  tagBITMAPINFOHEADER = packed record
    biSize: DWORD;
    biWidth: Longint;
    biHeight: Longint;
    biPlanes: Word;
    biBitCount: Word;
    biCompression: DWORD;
    biSizeImage: DWORD;
    biXPelsPerMeter: Longint;
    biYPelsPerMeter: Longint;
    biClrUsed: DWORD;
    biClrImportant: DWORD;
  end;
  TBitmapInfoHeader = tagBITMAPINFOHEADER;
  BITMAPINFOHEADER = tagBITMAPINFOHEADER;

  PBitmapV4Header = ^TBitmapV4Header;
  BITMAPV4HEADER = packed record
    bV4Size: DWORD;
    bV4Width: Longint;
    bV4Height: Longint;
    bV4Planes: Word;
    bV4BitCount: Word;
    bV4V4Compression: DWORD;
    bV4SizeImage: DWORD;
    bV4XPelsPerMeter: Longint;
    bV4YPelsPerMeter: Longint;
    bV4ClrUsed: DWORD;
    bV4ClrImportant: DWORD;
    bV4RedMask: DWORD;
    bV4GreenMask: DWORD;
    bV4BlueMask: DWORD;
    bV4AlphaMask: DWORD;
    bV4CSType: DWORD;
    bV4Endpoints: TCIEXYZTriple;
    bV4GammaRed: DWORD;
    bV4GammaGreen: DWORD;
    bV4GammaBlue: DWORD;
  end;
  TBitmapV4Header = BITMAPV4HEADER;

  PBitmapV5Header = ^TBitmapV5Header;
  BITMAPV5HEADER = packed record
    bV5Size: DWORD;
    bV5Width: Longint;
    bV5Height: Longint;
    bV5Planes: Word;
    bV5BitCount: Word;
    bV5Compression: DWORD;
    bV5SizeImage: DWORD;
    bV5XPelsPerMeter: Longint;
    bV5YPelsPerMeter: Longint;
    bV5ClrUsed: DWORD;
    bV5ClrImportant: DWORD;
    bV5RedMask: DWORD;
    bV5GreenMask: DWORD;
    bV5BlueMask: DWORD;
    bV5AlphaMask: DWORD;
    bV5CSType: DWORD;
    bV5Endpoints: TCIEXYZTriple;
    bV5GammaRed: DWORD;
    bV5GammaGreen: DWORD;
    bV5GammaBlue: DWORD;
    bV5Intent: DWORD;
    bV5ProfileData: DWORD;
    bV5ProfileSize: DWORD;
    bV5Reserved: DWORD;
  end;
  TBitmapV5Header = BITMAPV5HEADER;

const
  { constants for the biCompression field }
  BI_RGB = 0;
  BI_RLE8 = 1;
  BI_RLE4 = 2;
  BI_BITFIELDS = 3;

type
  PBitmapInfo = ^TBitmapInfo;
  tagBITMAPINFO = packed record
    bmiHeader: TBitmapInfoHeader;
    bmiColors: array[0..0] of TRGBQuad;
  end;
  TBitmapInfo = tagBITMAPINFO;
  BITMAPINFO = tagBITMAPINFO;

  PBitmapCoreInfo = ^TBitmapCoreInfo;
  tagBITMAPCOREINFO = record
    bmciHeader: TBitmapCoreHeader;
    bmciColors: array[0..0] of TRGBTriple;
    Reserved: array[0..0] of AnsiChar;
  end;
  TBitmapCoreInfo = tagBITMAPCOREINFO;
  BITMAPCOREINFO = tagBITMAPCOREINFO;

  PBitmapFileHeader = ^TBitmapFileHeader;
  tagBITMAPFILEHEADER = packed record
    bfType: Word;
    bfSize: DWORD;
    bfReserved1: Word;
    bfReserved2: Word;
    bfOffBits: DWORD;
  end;
  TBitmapFileHeader = tagBITMAPFILEHEADER;
  BITMAPFILEHEADER = tagBITMAPFILEHEADER;

  PFontSignature = ^TFontSignature;
  tagFONTSIGNATURE = packed record
    fsUsb: array[0..3] of DWORD;
    fsCsb: array[0..1] of DWORD;
  end;
  TFontSignature = tagFONTSIGNATURE;
  FONTSIGNATURE = tagFONTSIGNATURE;

  PTCharsetInfo = ^TCharsetInfo;
  tagCHARSETINFO = packed record
    ciCharset: UINT;
    ciACP: UINT;
    fs: TFontSignature;
  end;
  TCharsetInfo = tagCHARSETINFO;
  CHARSETINFO = tagCHARSETINFO;

const
  TCI_SRCCHARSET = 1;
  TCI_SRCCODEPAGE = 2;
  TCI_SRCFONTSIG = 3;

type
  PLocaleSignature = ^TLocaleSignature;
  tagLOCALESIGNATURE = packed record
    lsUsb: array[0..3] of DWORD;
    lsCsbDefault: array[0..1] of DWORD;
    lsCsbSupported: array[0..1] of DWORD;
  end;
  TLocaleSignature = tagLOCALESIGNATURE;
  LOCALESIGNATURE = tagLOCALESIGNATURE;

  { Clipboard Metafile Picture Structure }
  PHandleTable = ^THandleTable;
  tagHANDLETABLE = packed record
    objectHandle: array[0..0] of HGDIOBJ;
  end;
  THandleTable = tagHANDLETABLE;
  HANDLETABLE = tagHANDLETABLE;

  PMetaRecord = ^TMetaRecord;
  tagMETARECORD = packed record
    rdSize: DWORD;
    rdFunction: Word;
    rdParm: array[0..0] of Word;
  end;
  TMetaRecord = tagMETARECORD;
  METARECORD = tagMETARECORD;

  PMetafilePict = ^TMetafilePict;
  tagMETAFILEPICT = packed record
    mm: Longint;
    xExt: Longint;
    yExt: Longint;
    hMF: HMETAFILE;
  end;
  TMetafilePict = tagMETAFILEPICT;
  METAFILEPICT = tagMETAFILEPICT;

  PMetaHeader = ^TMetaHeader;
  tagMETAHEADER = packed record
    mtType: Word;
    mtHeaderSize: Word;
    mtVersion: Word;
    mtSize: DWORD;
    mtNoObjects: Word;
    mtMaxRecord: DWORD;
    mtNoParameters: Word;
  end;
  TMetaHeader = tagMETAHEADER;
  METAHEADER = tagMETAHEADER;

  { Enhanced Metafile structures }

  PEnhMetaRecord = ^TEnhMetaRecord;
  tagENHMETARECORD = packed record
    iType: DWORD; { Record type EMR_XXX}
    nSize: DWORD; { Record size in bytes}
    dParm: array[0..0] of DWORD; { Parameters}
  end;
  TEnhMetaRecord = tagENHMETARECORD;
  ENHMETARECORD = tagENHMETARECORD;

  PEnhMetaHeader = ^TEnhMetaHeader;
  tagENHMETAHEADER = packed record
    iType: DWORD;          { Record type EMR_HEADER}
    nSize: DWORD;          { Record size in bytes.  This may be greater
                             than the sizeof(TEnhMetaHeader). }
    rclBounds: TRect;     { Inclusive-inclusive bounds in device units}
    rclFrame: TRect;      { Inclusive-inclusive Picture Frame of metafile in .01 mm units}
    dSignature: DWORD;     { Signature.  Must be ENHMETA_SIGNATURE.}
    nVersion: DWORD;       { Version number}
    nBytes: DWORD;         { Size of the metafile in bytes}
    nRecords: DWORD;       { Number of records in the metafile}
    nHandles: Word;        { Number of handles in the handle table
                             Handle index zero is reserved. }
    sReserved: Word;       { Reserved.  Must be zero.}
    nDescription: DWORD;   { Number of chars in the unicode description string
                             This is 0 if there is no description string }
    offDescription: DWORD; { Offset to the metafile description record. }
                           { This is 0 if there is no description string }
    nPalEntries: DWORD;    { Number of entries in the metafile palette.}
    szlDevice: TSize;      { Size of the reference device in pels}
    szlMillimeters: TSize; { Size of the reference device in millimeters}
    cbPixelFormat: DWORD;  { Size of TPixelFormatDescriptor information }
                           { This is 0 if no pixel format is set }
    offPixelFormat: DWORD; { Offset to TPixelFormatDescriptor }
                           { This is 0 if no pixel format is set }
    bOpenGL: DWORD;        { True if OpenGL commands are present in }
                           { the metafile, otherwise FALSE }
  end;
  TEnhMetaHeader = tagENHMETAHEADER;
  ENHMETAHEADER = tagENHMETAHEADER;

const
  { tmPitchAndFamily flags }
  TMPF_FIXED_PITCH = 1;
  TMPF_VECTOR = 2;
  TMPF_DEVICE = 8;
  TMPF_TRUETYPE = 4;

type
  PTextMetricA = ^TTextMetricA;
  PTextMetricW = ^TTextMetricW;
  PTextMetric = {$ifdef bUnicode}PTextMetricW{$else}PTextMetricA{$endif bUnicode};

  tagTEXTMETRICA = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: AnsiChar;
    tmLastChar: AnsiChar;
    tmDefaultChar: AnsiChar;
    tmBreakChar: AnsiChar;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
  end;
  tagTEXTMETRICW = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: WideChar;
    tmLastChar: WideChar;
    tmDefaultChar: WideChar;
    tmBreakChar: WideChar;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
  end;
  tagTEXTMETRIC = {$ifdef bUnicode}tagTEXTMETRICW{$else}tagTEXTMETRICA{$endif bUnicode};

  TTextMetricA = tagTEXTMETRICA;
  TTextMetricW = tagTEXTMETRICW;
  TTextMetric = {$ifdef bUnicode}TTextMetricW{$else}TTextMetricA{$endif bUnicode};

  TEXTMETRICA = tagTEXTMETRICA;
  TEXTMETRICW = tagTEXTMETRICW;
  TEXTMETRIC = {$ifdef bUnicode}TEXTMETRICW{$else}TEXTMETRICA{$endif bUnicode};

const
  { ntmFlags field flags }
  NTM_REGULAR = $40;
  NTM_BOLD = $20;
  NTM_ITALIC = 1;

type
  PNewTextMetricA = ^TNewTextMetricA;
  PNewTextMetricW = ^TNewTextMetricW;
  PNewTextMetric = {$ifdef bUnicode}PNewTextMetricW{$else}PNewTextMetricA{$endif bUnicode};

  tagNEWTEXTMETRICA = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: AnsiChar;
    tmLastChar: AnsiChar;
    tmDefaultChar: AnsiChar;
    tmBreakChar: AnsiChar;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
    ntmFlags: DWORD;
    ntmSizeEM: UINT;
    ntmCellHeight: UINT;
    ntmAvgWidth: UINT;
  end;
  tagNEWTEXTMETRICW = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: WideChar;
    tmLastChar: WideChar;
    tmDefaultChar: WideChar;
    tmBreakChar: WideChar;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
    ntmFlags: DWORD;
    ntmSizeEM: UINT;
    ntmCellHeight: UINT;
    ntmAvgWidth: UINT;
  end;
  tagNEWTEXTMETRIC = {$ifdef bUnicode}tagNEWTEXTMETRICW{$else}tagNEWTEXTMETRICA{$endif bUnicode};

  TNewTextMetricA = tagNEWTEXTMETRICA;
  TNewTextMetricW = tagNEWTEXTMETRICW;
  TNewTextMetric = {$ifdef bUnicode}TNewTextMetricW{$else}TNewTextMetricA{$endif bUnicode};

  NEWTEXTMETRICA = tagNEWTEXTMETRICA;
  NEWTEXTMETRICW = tagNEWTEXTMETRICW;
  NEWTEXTMETRIC = {$ifdef bUnicode}NEWTEXTMETRICW{$else}NEWTEXTMETRICA{$endif bUnicode};

  PNewTextMetricExA = ^TNewTextMetricExA;
  PNewTextMetricExW = ^TNewTextMetricExW;
  PNewTextMetricEx = {$ifdef bUnicode}PNewTextMetricExW{$else}PNewTextMetricExA{$endif bUnicode};

  tagNEWTEXTMETRICEXA = packed record
    ntmTm: TNewTextMetricA;
    ntmFontSig: TFontSignature;
  end;
  tagNEWTEXTMETRICEXW = packed record
    ntmTm: TNewTextMetricW;
    ntmFontSig: TFontSignature;
  end;

  TNewTextMetricExA = tagNEWTEXTMETRICEXA;
  TNewTextMetricExW = tagNEWTEXTMETRICEXW;
  TNewTextMetricEx = {$ifdef bUnicode}TNewTextMetricExW{$else}TNewTextMetricExA{$endif bUnicode};

  NEWTEXTMETRICEXA = tagNEWTEXTMETRICEXA;
  NEWTEXTMETRICEXW = tagNEWTEXTMETRICEXW;
  NEWTEXTMETRICEX = {$ifdef bUnicode}NEWTEXTMETRICEXW{$else}NEWTEXTMETRICEXA{$endif bUnicode};

{ GDI Logical Objects: }

  { Pel Array }
  PPelArray = ^TPelArray;
  tagPELARRAY = record
    paXCount: Longint;
    paYCount: Longint;
    paXExt: Longint;
    paYExt: Longint;
    paRGBs: Byte;
  end;
  TPelArray = tagPELARRAY;
  PELARRAY = tagPELARRAY;

  { Logical Brush (or Pattern) }
  PLogBrush = ^TLogBrush;
  tagLOGBRUSH = packed record
    lbStyle: UINT;
    lbColor: COLORREF;
    lbHatch: Longint;
  end;
  TLogBrush = tagLOGBRUSH;
  LOGBRUSH = tagLOGBRUSH;

  PPattern = ^TPattern;
  TPattern = TLogBrush;

  { Logical Pen }
  PLogPen = ^TLogPen;
  tagLOGPEN = packed record
    lopnStyle: UINT;
    lopnWidth: TPoint;
    lopnColor: COLORREF;
  end;
  TLogPen = tagLOGPEN;
  LOGPEN = tagLOGPEN;

  PExtLogPen = ^TLogPen;
  tagEXTLOGPEN = packed record
    elpPenStyle: DWORD;
    elpWidth: DWORD;
    elpBrushStyle: UINT;
    elpColor: COLORREF;
    elpHatch: Longint;
    elpNumEntries: DWORD;
    elpStyleEntry: array[0..0] of DWORD;
  end;
  TExtLogPen = tagEXTLOGPEN;
  EXTLOGPEN = tagEXTLOGPEN;

  PPaletteEntry = ^TPaletteEntry;
  tagPALETTEENTRY = packed record
    peRed: Byte;
    peGreen: Byte;
    peBlue: Byte;
    peFlags: Byte;
  end;
  TPaletteEntry = tagPALETTEENTRY;
  PALETTEENTRY = tagPALETTEENTRY;


  { Logical Palette }
  PLogPalette = ^TLogPalette;
  tagLOGPALETTE = packed record
    palVersion: Word;
    palNumEntries: Word;
    palPalEntry: array[0..0] of TPaletteEntry;
  end;
  TLogPalette = tagLOGPALETTE;
  LOGPALETTE = tagLOGPALETTE;

  PMaxLogPalette = ^TMaxLogPalette; // not in Windows Headers
  TMaxLogPalette = packed record
    palVersion: Word;
    palNumEntries: Word;
    palPalEntry: array [Byte] of TPaletteEntry;
  end;

const
  { Logical Font }
  LF_FACESIZE = 32;

type
  PLogFontA = ^TLogFontA;
  PLogFontW = ^TLogFontW;
  PLogFont = {$ifdef bUnicode}PLogFontW{$else}PLogFontA{$endif bUnicode};

  tagLOGFONTA = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of AnsiChar;
  end;
  tagLOGFONTW = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of WideChar;
  end;
  tagLOGFONT = {$ifdef bUnicode}tagLOGFONTW{$else}tagLOGFONTA{$endif bUnicode};

  TLogFontA = tagLOGFONTA;
  TLogFontW = tagLOGFONTW;
  TLogFont = {$ifdef bUnicode}TLogFontW{$else}TLogFontA{$endif bUnicode};

  LOGFONTA = tagLOGFONTA;
  LOGFONTW = tagLOGFONTW;
  LOGFONT = {$ifdef bUnicode}LOGFONTW{$else}LOGFONTA{$endif bUnicode};

const
  LF_FULLFACESIZE = 64;

type
  { Structure passed to FONTENUMPROC }
  PEnumLogFontA = ^TEnumLogFontA;
  PEnumLogFontW = ^TEnumLogFontW;
  PEnumLogFont = {$ifdef bUnicode}PEnumLogFontW{$else}PEnumLogFontA{$endif bUnicode};
  tagENUMLOGFONTA = packed record
    elfLogFont: TLogFontA;
    elfFullName: array[0..LF_FULLFACESIZE - 1] of AnsiChar;
    elfStyle: array[0..LF_FACESIZE - 1] of AnsiChar;
  end;
  tagENUMLOGFONTW = packed record
    elfLogFont: TLogFontW;
    elfFullName: array[0..LF_FULLFACESIZE - 1] of WideChar;
    elfStyle: array[0..LF_FACESIZE - 1] of WideChar;
  end;
  tagENUMLOGFONT = {$ifdef bUnicode}tagENUMLOGFONTW{$else}tagENUMLOGFONTA{$endif bUnicode};

  TEnumLogFontA = tagENUMLOGFONTA;
  TEnumLogFontW = tagENUMLOGFONTW;
  TEnumLogFont = {$ifdef bUnicode}TEnumLogFontW{$else}TEnumLogFontA{$endif bUnicode};

  ENUMLOGFONTA = tagENUMLOGFONTA;
  ENUMLOGFONTW = tagENUMLOGFONTW;
  ENUMLOGFONT = {$ifdef bUnicode}ENUMLOGFONTW{$else}ENUMLOGFONTA{$endif bUnicode};

  PEnumLogFontExA = ^TEnumLogFontExA;
  PEnumLogFontExW = ^TEnumLogFontExW;
  PEnumLogFontEx = {$ifdef bUnicode}PEnumLogFontExW{$else}PEnumLogFontExA{$endif bUnicode};

  tagENUMLOGFONTEXA = packed record
    elfLogFont: TLogFontA;
    elfFullName: array[0..LF_FULLFACESIZE - 1] of AnsiChar;
    elfStyle: array[0..LF_FACESIZE - 1] of AnsiChar;
    elfScript: array[0..LF_FACESIZE - 1] of AnsiChar;
  end;
  tagENUMLOGFONTEXW = packed record
    elfLogFont: TLogFontW;
    elfFullName: array[0..LF_FULLFACESIZE - 1] of WideChar;
    elfStyle: array[0..LF_FACESIZE - 1] of WideChar;
    elfScript: array[0..LF_FACESIZE - 1] of WideChar;
  end;
  tagENUMLOGFONTEX = {$ifdef bUnicode}tagENUMLOGFONTEXW{$else}tagENUMLOGFONTEXA{$endif bUnicode};

  TEnumLogFontExA = tagENUMLOGFONTEXA;
  TEnumLogFontExW = tagENUMLOGFONTEXW;
  TEnumLogFontEx = {$ifdef bUnicode}TEnumLogFontExW{$else}TEnumLogFontExA{$endif bUnicode};

  ENUMLOGFONTEXA = tagENUMLOGFONTEXA;
  ENUMLOGFONTEXW = tagENUMLOGFONTEXW;
  ENUMLOGFONTEX = {$ifdef bUnicode}ENUMLOGFONTEXW{$else}ENUMLOGFONTEXA{$endif bUnicode};

const
  OUT_DEFAULT_PRECIS = 0;
  OUT_STRING_PRECIS = 1;
  OUT_CHARACTER_PRECIS = 2;
  OUT_STROKE_PRECIS = 3;
  OUT_TT_PRECIS = 4;
  OUT_DEVICE_PRECIS = 5;
  OUT_RASTER_PRECIS = 6;
  OUT_TT_ONLY_PRECIS = 7;
  OUT_OUTLINE_PRECIS = 8;
  OUT_SCREEN_OUTLINE_PRECIS = 9;

  CLIP_DEFAULT_PRECIS = 0;
  CLIP_CHARACTER_PRECIS = 1;
  CLIP_STROKE_PRECIS = 2;
  CLIP_MASK = 15;
  CLIP_LH_ANGLES = (1 shl 4);
  CLIP_TT_ALWAYS = (2 shl 4);
  CLIP_EMBEDDED  = (8 shl 4);

  DEFAULT_QUALITY = 0;
  DRAFT_QUALITY = 1;
  PROOF_QUALITY = 2;
  NONANTIALIASED_QUALITY = 3;
  ANTIALIASED_QUALITY = 4;

  DEFAULT_PITCH = 0;
  FIXED_PITCH = 1;
  VARIABLE_PITCH = 2;
  MONO_FONT = 8;

  ANSI_CHARSET = 0;
  DEFAULT_CHARSET = 1;
  SYMBOL_CHARSET = 2;
  SHIFTJIS_CHARSET = $80;
  HANGEUL_CHARSET = 129;
  GB2312_CHARSET = 134;
  CHINESEBIG5_CHARSET = 136;
  OEM_CHARSET = 255;
  JOHAB_CHARSET = 130;
  HEBREW_CHARSET = 177;
  ARABIC_CHARSET = 178;
  GREEK_CHARSET = 161;
  TURKISH_CHARSET = 162;
  VIETNAMESE_CHARSET = 163;
  THAI_CHARSET = 222;
  EASTEUROPE_CHARSET = 238;
  RUSSIAN_CHARSET = 204;

  MAC_CHARSET = 77;
  BALTIC_CHARSET = 186;

  FS_LATIN1 = 1;
  FS_LATIN2 = 2;
  FS_CYRILLIC = 4;
  FS_GREEK = 8;
  FS_TURKISH = $10;
  FS_HEBREW = $20;
  FS_ARABIC = $40;
  FS_BALTIC = $80;
  FS_VIETNAMESE = $00000100;
  FS_THAI = $10000;
  FS_JISJAPAN = $20000;
  FS_CHINESESIMP = $40000;
  FS_WANSUNG = $80000;
  FS_CHINESETRAD = $100000;
  FS_JOHAB = $200000;
  FS_SYMBOL = DWORD($80000000);

  { Font Families }
  FF_DONTCARE   = (0 shl 4);     { Don't care or don't know. }
  FF_ROMAN      = (1 shl 4);     { Variable stroke width, serifed. }
                                 { Times Roman, Century Schoolbook, etc. }
  FF_SWISS      = (2 shl 4);     { Variable stroke width, sans-serifed. }
                                 { Helvetica, Swiss, etc. }
  FF_MODERN     = (3 shl 4);     { Constant stroke width, serifed or sans-serifed. }
                                 { Pica, Elite, Courier, etc. }
  FF_SCRIPT     = (4 shl 4);     { Cursive, etc. }
  FF_DECORATIVE = (5 shl 4);     { Old English, etc. }

  { Font Weights }
  FW_DONTCARE = 0;
  FW_THIN = 100;
  FW_EXTRALIGHT = 200;
  FW_LIGHT = 300;
  FW_NORMAL = 400;
  FW_MEDIUM = 500;
  FW_SEMIBOLD = 600;
  FW_BOLD = 700;
  FW_EXTRABOLD = 800;
  FW_HEAVY = 900;
  FW_ULTRALIGHT = FW_EXTRALIGHT;
  FW_REGULAR = FW_NORMAL;
  FW_DEMIBOLD = FW_SEMIBOLD;
  FW_ULTRABOLD = FW_EXTRABOLD;
  FW_BLACK = FW_HEAVY;

  PANOSE_COUNT = 10;
  PAN_FAMILYTYPE_INDEX = 0;
  PAN_SERIFSTYLE_INDEX = 1;
  PAN_WEIGHT_INDEX = 2;
  PAN_PROPORTION_INDEX = 3;
  PAN_CONTRAST_INDEX = 4;
  PAN_STROKEVARIATION_INDEX = 5;
  PAN_ARMSTYLE_INDEX = 6;
  PAN_LETTERFORM_INDEX = 7;
  PAN_MIDLINE_INDEX = 8;
  PAN_XHEIGHT_INDEX = 9;

  PAN_CULTURE_LATIN = 0;

type
  PPanose = ^TPanose;
  tagPANOSE = packed record
    bFamilyType: Byte;
    bSerifStyle: Byte;
    bWeight: Byte;
    bProportion: Byte;
    bContrast: Byte;
    bStrokeVariation: Byte;
    bArmStyle: Byte;
    bLetterform: Byte;
    bMidline: Byte;
    bXHeight: Byte;
  end;
  TPanose = tagPANOSE;
  PANOSE = tagPANOSE;

const
  PAN_ANY = 0;
  PAN_NO_FIT = 1;

  PAN_FAMILY_TEXT_DISPLAY = 2;
  PAN_FAMILY_SCRIPT = 3;
  PAN_FAMILY_DECORATIVE = 4;
  PAN_FAMILY_PICTORIAL = 5;

  PAN_SERIF_COVE = 2;
  PAN_SERIF_OBTUSE_COVE = 3;
  PAN_SERIF_SQUARE_COVE = 4;
  PAN_SERIF_OBTUSE_SQUARE_COVE = 5;
  PAN_SERIF_SQUARE = 6;
  PAN_SERIF_THIN = 7;
  PAN_SERIF_BONE = 8;
  PAN_SERIF_EXAGGERATED = 9;
  PAN_SERIF_TRIANGLE = 10;
  PAN_SERIF_NORMAL_SANS = 11;
  PAN_SERIF_OBTUSE_SANS = 12;
  PAN_SERIF_PERP_SANS = 13;
  PAN_SERIF_FLARED = 14;
  PAN_SERIF_ROUNDED = 15;

  PAN_WEIGHT_VERY_LIGHT = 2;
  PAN_WEIGHT_LIGHT = 3;
  PAN_WEIGHT_THIN = 4;
  PAN_WEIGHT_BOOK = 5;
  PAN_WEIGHT_MEDIUM = 6;
  PAN_WEIGHT_DEMI = 7;
  PAN_WEIGHT_BOLD = 8;
  PAN_WEIGHT_HEAVY = 9;
  PAN_WEIGHT_BLACK = 10;
  PAN_WEIGHT_NORD = 11;

  PAN_PROP_OLD_STYLE = 2;
  PAN_PROP_MODERN = 3;
  PAN_PROP_EVEN_WIDTH = 4;
  PAN_PROP_EXPANDED = 5;
  PAN_PROP_CONDENSED = 6;
  PAN_PROP_VERY_EXPANDED = 7;
  PAN_PROP_VERY_CONDENSED = 8;
  PAN_PROP_MONOSPACED = 9;

  PAN_CONTRAST_NONE = 2;
  PAN_CONTRAST_VERY_LOW = 3;
  PAN_CONTRAST_LOW = 4;
  PAN_CONTRAST_MEDIUM_LOW = 5;
  PAN_CONTRAST_MEDIUM = 6;
  PAN_CONTRAST_MEDIUM_HIGH = 7;
  PAN_CONTRAST_HIGH = 8;
  PAN_CONTRAST_VERY_HIGH = 9;

  PAN_STROKE_GRADUAL_DIAG = 2;
  PAN_STROKE_GRADUAL_TRAN = 3;
  PAN_STROKE_GRADUAL_VERT = 4;
  PAN_STROKE_GRADUAL_HORZ = 5;
  PAN_STROKE_RAPID_VERT = 6;
  PAN_STROKE_RAPID_HORZ = 7;
  PAN_STROKE_INSTANT_VERT = 8;

  PAN_STRAIGHT_ARMS_HORZ = 2;
  PAN_STRAIGHT_ARMS_WEDGE = 3;
  PAN_STRAIGHT_ARMS_VERT = 4;
  PAN_STRAIGHT_ARMS_SINGLE_SERIF = 5;
  PAN_STRAIGHT_ARMS_DOUBLE_SERIF = 6;
  PAN_BENT_ARMS_HORZ = 7;
  PAN_BENT_ARMS_WEDGE = 8;
  PAN_BENT_ARMS_VERT = 9;
  PAN_BENT_ARMS_SINGLE_SERIF = 10;
  PAN_BENT_ARMS_DOUBLE_SERIF = 11;

  PAN_LETT_NORMAL_CONTACT = 2;
  PAN_LETT_NORMAL_WEIGHTED = 3;
  PAN_LETT_NORMAL_BOXED = 4;
  PAN_LETT_NORMAL_FLATTENED = 5;
  PAN_LETT_NORMAL_ROUNDED = 6;
  PAN_LETT_NORMAL_OFF_CENTER = 7;
  PAN_LETT_NORMAL_SQUARE = 8;
  PAN_LETT_OBLIQUE_CONTACT = 9;
  PAN_LETT_OBLIQUE_WEIGHTED = 10;
  PAN_LETT_OBLIQUE_BOXED = 11;
  PAN_LETT_OBLIQUE_FLATTENED = 12;
  PAN_LETT_OBLIQUE_ROUNDED = 13;
  PAN_LETT_OBLIQUE_OFF_CENTER = 14;
  PAN_LETT_OBLIQUE_SQUARE = 15;

  PAN_MIDLINE_STANDARD_TRIMMED = 2;
  PAN_MIDLINE_STANDARD_POINTED = 3;
  PAN_MIDLINE_STANDARD_SERIFED = 4;
  PAN_MIDLINE_HIGH_TRIMMED = 5;
  PAN_MIDLINE_HIGH_POINTED = 6;
  PAN_MIDLINE_HIGH_SERIFED = 7;
  PAN_MIDLINE_CONSTANT_TRIMMED = 8;
  PAN_MIDLINE_CONSTANT_POINTED = 9;
  PAN_MIDLINE_CONSTANT_SERIFED = 10;
  PAN_MIDLINE_LOW_TRIMMED = 11;
  PAN_MIDLINE_LOW_POINTED = 12;
  PAN_MIDLINE_LOW_SERIFED = 13;

  PAN_XHEIGHT_CONSTANT_SMALL = 2;
  PAN_XHEIGHT_CONSTANT_STD = 3;
  PAN_XHEIGHT_CONSTANT_LARGE = 4;
  PAN_XHEIGHT_DUCKING_SMALL = 5;
  PAN_XHEIGHT_DUCKING_STD = 6;
  PAN_XHEIGHT_DUCKING_LARGE = 7;

  ELF_VENDOR_SIZE = 4;

{ The extended logical font       }
{ An extension of the ENUMLOGFONT }

type
  PExtLogFontA = ^TExtLogFontA;
  PExtLogFontW = ^TExtLogFontW;
  PExtLogFont = PExtLogFontA;
  tagEXTLOGFONTA = record
    elfLogFont: TLogFontA;
    elfFullName: array[0..LF_FULLFACESIZE - 1] of AnsiChar;
    elfStyle: array[0..LF_FACESIZE - 1] of AnsiChar;
    elfVersion: DWORD;     { 0 for the first release of NT }
    elfStyleSize: DWORD;
    elfMatch: DWORD;
    elfReserved: DWORD;
    elfVendorId: array[0..ELF_VENDOR_SIZE - 1] of Byte;
    elfCulture: DWORD;     { 0 for Latin }
    elfPanose: TPanose;
  end;
  tagEXTLOGFONTW = record
    elfLogFont: TLogFontW;
    elfFullName: array[0..LF_FULLFACESIZE - 1] of WideChar;
    elfStyle: array[0..LF_FACESIZE - 1] of WideChar;
    elfVersion: DWORD;     { 0 for the first release of NT }
    elfStyleSize: DWORD;
    elfMatch: DWORD;
    elfReserved: DWORD;
    elfVendorId: array[0..ELF_VENDOR_SIZE - 1] of Byte;
    elfCulture: DWORD;     { 0 for Latin }
    elfPanose: TPanose;
  end;
  tagEXTLOGFONT = tagEXTLOGFONTA;
  TExtLogFontA = tagEXTLOGFONTA;
  TExtLogFontW = tagEXTLOGFONTW;
  TExtLogFont = TExtLogFontA;
  EXTLOGFONTA = tagEXTLOGFONTA;
  EXTLOGFONTW = tagEXTLOGFONTW;
  EXTLOGFONT = EXTLOGFONTA;

const
  ELF_VERSION = 0;
  ELF_CULTURE_LATIN = 0;


  { EnumFonts Masks }
  RASTER_FONTTYPE = 1;
  DEVICE_FONTTYPE = 2;
  TRUETYPE_FONTTYPE = 4;

function RGB(r, g, b: Byte): COLORREF;
function PaletteRGB(r, g, b: Byte): COLORREF;
function PaletteIndex(i: Word): COLORREF;

const
  { palette entry flags }
  PC_RESERVED = 1;     { palette index used for animation }
  PC_EXPLICIT = 2;     { palette index is explicit to device }
  PC_NOCOLLAPSE = 4;   { do not match color to system palette }

function GetRValue(rgb: DWORD): Byte;
function GetGValue(rgb: DWORD): Byte;
function GetBValue(rgb: DWORD): Byte;

const
  { Background Modes }
  TRANSPARENT = 1;
  OPAQUE = 2;
  BKMODE_LAST = 2;

  { Graphics Modes }
  GM_COMPATIBLE = 1;
  GM_ADVANCED = 2;
  GM_LAST = 2;

  { PolyDraw and GetPath point types }
  PT_CLOSEFIGURE = 1;
  PT_LINETO = 2;
  PT_BEZIERTO = 4;
  PT_MOVETO = 6;

  { Mapping Modes }
  MM_TEXT = 1;
  MM_LOMETRIC = 2;
  MM_HIMETRIC = 3;
  MM_LOENGLISH = 4;
  MM_HIENGLISH = 5;
  MM_TWIPS = 6;
  MM_ISOTROPIC = 7;
  MM_ANISOTROPIC = 8;

  { Min and Max Mapping Mode values }
  MM_MIN = MM_TEXT;
  MM_MAX = MM_ANISOTROPIC;
  MM_MAX_FIXEDSCALE = MM_TWIPS;

  { Coordinate Modes }
  ABSOLUTE = 1;
  RELATIVE = 2;

  { Stock Logical Objects }
  WHITE_BRUSH = 0;
  LTGRAY_BRUSH = 1;
  GRAY_BRUSH = 2;
  DKGRAY_BRUSH = 3;
  BLACK_BRUSH = 4;
  NULL_BRUSH = 5;
  HOLLOW_BRUSH = NULL_BRUSH;
  WHITE_PEN = 6;
  BLACK_PEN = 7;
  NULL_PEN = 8;
  OEM_FIXED_FONT = 10;
  ANSI_FIXED_FONT = 11;
  ANSI_VAR_FONT = 12;
  SYSTEM_FONT = 13;
  DEVICE_DEFAULT_FONT = 14;
  DEFAULT_PALETTE = 15;
  SYSTEM_FIXED_FONT = $10;
  DEFAULT_GUI_FONT = 17;
  DC_BRUSH = 18;
  DC_PEN = 19;
  STOCK_LAST = 19;

  CLR_INVALID = DWORD($FFFFFFFF);

  { Brush Styles }
  BS_SOLID                = 0;
  BS_NULL                 = 1;
  BS_HOLLOW               = BS_NULL;
  BS_HATCHED              = 2;
  BS_PATTERN              = 3;
  BS_INDEXED              = 4;
  BS_DIBPATTERN           = 5;
  BS_DIBPATTERNPT         = 6;
  BS_PATTERN8X8           = 7;
  BS_DIBPATTERN8X8        = 8;
  BS_MONOPATTERN          = 9;

  { Hatch Styles }
  HS_HORIZONTAL = 0;       { ----- }
  HS_VERTICAL   = 1;       { ||||| }
  HS_FDIAGONAL  = 2;       { ///// }
  HS_BDIAGONAL  = 3;       { \\\\\ }
  HS_CROSS      = 4;       { +++++ }
  HS_DIAGCROSS  = 5;       { xxxxx }


  { Pen Styles }
  PS_SOLID       = 0;
  PS_DASH        = 1;      { ------- }
  PS_DOT         = 2;      { ....... }
  PS_DASHDOT     = 3;      { _._._._ }
  PS_DASHDOTDOT  = 4;      { _.._.._ }
  PS_NULL = 5;
  PS_INSIDEFRAME = 6;
  PS_USERSTYLE = 7;
  PS_ALTERNATE = 8;
  PS_STYLE_MASK = 15;

  PS_ENDCAP_ROUND = 0;
  PS_ENDCAP_SQUARE = $100;
  PS_ENDCAP_FLAT = $200;
  PS_ENDCAP_MASK = 3840;

  PS_JOIN_ROUND = 0;
  PS_JOIN_BEVEL = $1000;
  PS_JOIN_MITER = $2000;
  PS_JOIN_MASK = 61440;

  PS_COSMETIC = 0;
  PS_GEOMETRIC = $10000;
  PS_TYPE_MASK = $F0000;

  AD_COUNTERCLOCKWISE = 1;
  AD_CLOCKWISE = 2;

  { Device Parameters for GetDeviceCaps() }
  DRIVERVERSION = 0;     { Device driver version                     }
  TECHNOLOGY    = 2;     { Device classification                     }
  HORZSIZE      = 4;     { Horizontal size in millimeters            }
  VERTSIZE      = 6;     { Vertical size in millimeters              }
  HORZRES       = 8;     { Horizontal width in pixels                }
  VERTRES       = 10;    { Vertical height in pixels                 }
  BITSPIXEL     = 12;    { Number of bits per pixel                  }
  PLANES        = 14;    { Number of planes                          }
  NUMBRUSHES    = $10;   { Number of brushes the device has          }
  NUMPENS       = 18;    { Number of pens the device has             }
  NUMMARKERS    = 20;    { Number of markers the device has          }
  NUMFONTS      = 22;    { Number of fonts the device has            }
  NUMCOLORS     = 24;    { Number of colors the device supports      }
  PDEVICESIZE   = 26;    { Size required for device descriptor       }
  CURVECAPS     = 28;    { Curve capabilities                        }
  LINECAPS      = 30;    { Line capabilities                         }
  POLYGONALCAPS = $20;   { Polygonal capabilities                    }
  TEXTCAPS      = 34;    { Text capabilities                         }
  CLIPCAPS      = 36;    { Clipping capabilities                     }
  RASTERCAPS    = 38;    { Bitblt capabilities                       }
  ASPECTX       = 40;    { Length of the X leg                       }
  ASPECTY       = 42;    { Length of the Y leg                       }
  ASPECTXY      = 44;    { Length of the hypotenuse                  }
  SHADEBLENDCAPS = 45;   { Shading and Blending caps                 }

  LOGPIXELSX    = 88;    { Logical pixelsinch in X                  }
  LOGPIXELSY    = 90;    { Logical pixelsinch in Y                  }

  SIZEPALETTE   = 104;   { Number of entries in physical palette     }
  NUMRESERVED   = 106;   { Number of reserved entries in palette     }
  COLORRES      = 108;   { Actual color resolution                   }

  { Printing related DeviceCaps. These replace the appropriate Escapes }
  PHYSICALWIDTH   = 110;     { Physical Width in device units            }
  PHYSICALHEIGHT  = 111;     { Physical Height in device units           }
  PHYSICALOFFSETX = 112;     { Physical Printable Area x margin          }
  PHYSICALOFFSETY = 113;     { Physical Printable Area y margin          }
  SCALINGFACTORX  = 114;     { Scaling factor x                          }
  SCALINGFACTORY  = 115;     { Scaling factor y                          }


  { Display driver specific}
  VREFRESH       = 116;     { Current vertical refresh rate of the     }
                            { display device (for displays only) in Hz}
  DESKTOPVERTRES = 117;     { Horizontal width of entire desktop in    }
                            { pixels                                  }
  DESKTOPHORZRES = 118;     { Vertical height of entire desktop in     }
                            { pixels                                  }
  BLTALIGNMENT   = 119;     { Preferred blt alignment                  }


{ Device Capability Masks: }

{ Device Technologies }

  DT_PLOTTER    = 0;     { Vector plotter                    }
  DT_RASDISPLAY = 1;     { Raster display                    }
  DT_RASPRINTER = 2;     { Raster printer                    }
  DT_RASCAMERA  = 3;     { Raster camera                     }
  DT_CHARSTREAM = 4;     { Character-stream, PLP             }
  DT_METAFILE   = 5;     { Metafile, VDM                     }
  DT_DISPFILE   = 6;     { Display-file                      }

{ Curve Capabilities }

  CC_NONE       = 0;     { Curves not supported              }
  CC_CIRCLES    = 1;     { Can do circles                    }
  CC_PIE        = 2;     { Can do pie wedges                 }
  CC_CHORD      = 4;     { Can do chord arcs                 }
  CC_ELLIPSES   = 8;     { Can do ellipese                   }
  CC_WIDE       = $10;   { Can do wide lines                 }
  CC_STYLED     = $20;   { Can do styled lines               }
  CC_WIDESTYLED = $40;   { Can do wide styled lines          }
  CC_INTERIORS  = $80;   { Can do interiors                  }
  CC_ROUNDRECT  = $100;

{ Line Capabilities }

  LC_NONE       = 0;     { Lines not supported               }
  LC_POLYLINE   = 2;     { Can do polylines                  }
  LC_MARKER     = 4;     { Can do markers                    }
  LC_POLYMARKER = 8;     { Can do polymarkers                }
  LC_WIDE       = $10;   { Can do wide lines                 }
  LC_STYLED     = $20;   { Can do styled lines               }
  LC_WIDESTYLED = $40;   { Can do wide styled lines          }
  LC_INTERIORS  = $80;   { Can do interiors                  }

{ Polygonal Capabilities }

  PC_NONE        = 0;     { Polygonals not supported          }
  PC_POLYGON     = 1;     { Can do polygons                   }
  PC_RECTANGLE   = 2;     { Can do rectangles                 }
  PC_WINDPOLYGON = 4;     { Can do winding polygons           }
  PC_TRAPEZOID   = 4;     { Can do trapezoids                 }
  PC_SCANLINE    = 8;     { Can do scanlines                  }
  PC_WIDE        = $10;   { Can do wide borders               }
  PC_STYLED      = $20;   { Can do styled borders             }
  PC_WIDESTYLED  = $40;   { Can do wide styled borders        }
  PC_INTERIORS   = $80;   { Can do interiors                  }
  PC_POLYPOLYGON = $100;  { Can do polypolygons               }
  PC_PATHS       = $200;  { Can do paths                      }

{ Clipping Capabilities }

  CP_NONE      = 0;     { No clipping of output             }
  CP_RECTANGLE = 1;     { Output clipped to rects           }
  CP_REGION    = 2;     { obsolete                          }

{ Text Capabilities }

  TC_OP_CHARACTER = 1;      { Can do OutputPrecision   CHARACTER       }
  TC_OP_STROKE    = 2;      { Can do OutputPrecision   STROKE          }
  TC_CP_STROKE    = 4;      { Can do ClipPrecision     STROKE          }
  TC_CR_90        = 8;      { Can do CharRotAbility    90              }
  TC_CR_ANY       = $10;    { Can do CharRotAbility    ANY             }
  TC_SF_X_YINDEP  = $20;    { Can do ScaleFreedom      X_YINDEPENDENT  }
  TC_SA_DOUBLE    = $40;    { Can do ScaleAbility      DOUBLE          }
  TC_SA_INTEGER   = $80;    { Can do ScaleAbility      INTEGER         }
  TC_SA_CONTIN    = $100;   { Can do ScaleAbility      CONTINUOUS      }
  TC_EA_DOUBLE    = $200;   { Can do EmboldenAbility   DOUBLE          }
  TC_IA_ABLE      = $400;   { Can do ItalisizeAbility  ABLE            }
  TC_UA_ABLE      = $800;   { Can do UnderlineAbility  ABLE            }
  TC_SO_ABLE      = $1000;  { Can do StrikeOutAbility  ABLE            }
  TC_RA_ABLE      = $2000;  { Can do RasterFontAble    ABLE            }
  TC_VA_ABLE      = $4000;  { Can do VectorFontAble    ABLE            }
  TC_RESERVED     = $8000;
  TC_SCROLLBLT    = $10000; { Don't do text scroll with blt            }

{ Raster Capabilities }

  RC_BITBLT       = 1;     { Can do standard BLT.              }
  RC_BANDING      = 2;     { Device requires banding support   }
  RC_SCALING      = 4;     { Device requires scaling support   }
  RC_BITMAP64     = 8;     { Device can support >64K bitmap    }
  RC_GDI20_OUTPUT = $10;   { has 2.0 output calls          }
  RC_GDI20_STATE  = $20;
  RC_SAVEBITMAP   = $40;
  RC_DI_BITMAP    = $80;   { supports DIB to memory        }
  RC_PALETTE      = $100;  { supports a palette            }
  RC_DIBTODEV     = $200;  { supports DIBitsToDevice       }
  RC_BIGFONT      = $400;  { supports >64K fonts           }
  RC_STRETCHBLT   = $800;  { supports StretchBlt           }
  RC_FLOODFILL    = $1000; { supports FloodFill            }
  RC_STRETCHDIB   = $2000; { supports StretchDIBits        }
  RC_OP_DX_OUTPUT = $4000;
  RC_DEVBITS      = $8000;

{ Shading and blending caps }
  SB_NONE = 0;
  SB_CONST_ALPHA = 1;
  SB_PIXEL_ALPHA = 2;
  SB_PREMULT_ALPHA = 4;
  SB_GRAD_RECT = $10;
  SB_GRAD_TRI = $20;

{ DIB color table identifiers }

  DIB_RGB_COLORS = 0;     { color table in RGBs  }
  DIB_PAL_COLORS = 1;     { color table in palette indices  }

{ constants for GetSetSystemPaletteUse() }

  SYSPAL_ERROR = 0;
  SYSPAL_STATIC = 1;
  SYSPAL_NOSTATIC = 2;

{ constants for CreateDIBitmap }

  CBM_INIT = 4;     { initialize bitmap  }

{ ExtFloodFill style flags }

  FLOODFILLBORDER = 0;
  FLOODFILLSURFACE = 1;

  CCHDEVICENAME = 32;     { size of a device name string  }
  CCHFORMNAME   = 32;     { size of a form name string  }

type
  PDeviceModeA = ^TDeviceModeA;
  PDeviceModeW = ^TDeviceModeW;
  PDeviceMode = PDeviceModeA;
  _devicemodeA = packed record
    dmDeviceName: array[0..CCHDEVICENAME - 1] of AnsiChar;
    dmSpecVersion: Word;
    dmDriverVersion: Word;
    dmSize: Word;
    dmDriverExtra: Word;
    dmFields: DWORD;
    dmOrientation: SHORT;
    dmPaperSize: SHORT;
    dmPaperLength: SHORT;
    dmPaperWidth: SHORT;
    dmScale: SHORT;
    dmCopies: SHORT;
    dmDefaultSource: SHORT;
    dmPrintQuality: SHORT;
    dmColor: SHORT;
    dmDuplex: SHORT;
    dmYResolution: SHORT;
    dmTTOption: SHORT;
    dmCollate: SHORT;
    dmFormName: array[0..CCHFORMNAME - 1] of AnsiChar;
    dmLogPixels: Word;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDisplayFlags: DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmICCManufacturer: DWORD;
    dmICCModel: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;
  _devicemodeW = packed record
    dmDeviceName: array[0..CCHDEVICENAME - 1] of WideChar;
    dmSpecVersion: Word;
    dmDriverVersion: Word;
    dmSize: Word;
    dmDriverExtra: Word;
    dmFields: DWORD;
    dmOrientation: SHORT;
    dmPaperSize: SHORT;
    dmPaperLength: SHORT;
    dmPaperWidth: SHORT;
    dmScale: SHORT;
    dmCopies: SHORT;
    dmDefaultSource: SHORT;
    dmPrintQuality: SHORT;
    dmColor: SHORT;
    dmDuplex: SHORT;
    dmYResolution: SHORT;
    dmTTOption: SHORT;
    dmCollate: SHORT;
    dmFormName: array[0..CCHFORMNAME - 1] of WideChar;
    dmLogPixels: Word;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDisplayFlags: DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmICCManufacturer: DWORD;
    dmICCModel: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;
  _devicemode = _devicemodeA;
  TDeviceModeA = _devicemodeA;
  TDeviceModeW = _devicemodeW;
  TDeviceMode = TDeviceModeA;
  DEVMODEA = _devicemodeA;
  DEVMODEW = _devicemodeW;
  DEVMODE = DEVMODEA;

  PDevMode = PDeviceMode;  {compatibility with Delphi 1.0}
  TDevMode = TDeviceMode;  {compatibility with Delphi 1.0}

const
  DM_SPECVERSION = $401;  { current version of specification }

{ field selection bits }

  DM_ORIENTATION = 1;
  DM_PAPERSIZE = 2;
  DM_PAPERLENGTH = 4;
  DM_PAPERWIDTH = 8;
  DM_SCALE = $10;
  DM_POSITION = $20;
  DM_COPIES = $100;
  DM_DEFAULTSOURCE = $200;
  DM_PRINTQUALITY = $400;
  DM_COLOR = $800;
  DM_DUPLEX = $1000;
  DM_YRESOLUTION = $2000;
  DM_TTOPTION = $4000;
  DM_COLLATE = $8000;
  DM_FORMNAME = $10000;
  DM_LOGPIXELS = $20000;
  DM_BITSPERPEL = $40000;
  DM_PELSWIDTH = $80000;
  DM_PELSHEIGHT = $100000;
  DM_DISPLAYFLAGS = $200000;
  DM_DISPLAYFREQUENCY = $400000;
  DM_PANNINGWIDTH = $00800000;
  DM_PANNINGHEIGHT = $01000000;
  DM_ICMMETHOD = $2000000;
  DM_ICMINTENT = $4000000;
  DM_MEDIATYPE = $8000000;
  DM_DITHERTYPE = $10000000;
  DM_ICCMANUFACTURER = $20000000;
  DM_ICCMODEL = $40000000;

{ orientation selections }

  DMORIENT_PORTRAIT = 1;
  DMORIENT_LANDSCAPE = 2;

{ paper selections }

  DMPAPER_LETTER      = 1;  { Letter 8 12 x 11 in               }
  DMPAPER_FIRST       = DMPAPER_LETTER;
  DMPAPER_LETTERSMALL = 2;  { Letter Small 8 12 x 11 in         }
  DMPAPER_TABLOID     = 3;  { Tabloid 11 x 17 in                }
  DMPAPER_LEDGER      = 4;  { Ledger 17 x 11 in                 }
  DMPAPER_LEGAL       = 5;  { Legal 8 12 x 14 in                }
  DMPAPER_STATEMENT   = 6;  { Statement 5 12 x 8 12 in          }
  DMPAPER_EXECUTIVE   = 7;  { Executive 7 14 x 10 12 in         }
  DMPAPER_A3      = 8;      { A3 297 x 420 mm                     }
  DMPAPER_A4      = 9;      { A4 210 x 297 mm                     }
  DMPAPER_A4SMALL = 10;     { A4 Small 210 x 297 mm               }
  DMPAPER_A5      = 11;     { A5 148 x 210 mm                     }
  DMPAPER_B4      = 12;     { B4 (JIS) 250 x 354                  }
  DMPAPER_B5      = 13;     { B5 (JIS) 182 x 257 mm               }
  DMPAPER_FOLIO   = 14;     { Folio 8 12 x 13 in                  }
  DMPAPER_QUARTO  = 15;     { Quarto 215 x 275 mm                 }
  DMPAPER_10X14   = 16;     { 10x14 in                            }
  DMPAPER_11X17   = 17;     { 11x17 in                            }
  DMPAPER_NOTE    = 18;     { Note 8 12 x 11 in                   }
  DMPAPER_ENV_9   = 19;     { Envelope #9 3 78 x 8 78             }
  DMPAPER_ENV_10  = 20;     { Envelope #10 4 18 x 9 12            }
  DMPAPER_ENV_11  = 21;     { Envelope #11 4 12 x 10 38           }
  DMPAPER_ENV_12  = 22;     { Envelope #12 4 \276 x 11            }
  DMPAPER_ENV_14  = 23;     { Envelope #14 5 x 11 12              }
  DMPAPER_CSHEET  = 24;     { C size sheet                        }
  DMPAPER_DSHEET  = 25;     { D size sheet                        }
  DMPAPER_ESHEET  = 26;     { E size sheet                        }
  DMPAPER_ENV_DL  = 27;     { Envelope DL 110 x 220mm             }
  DMPAPER_ENV_C5  = 28;     { Envelope C5 162 x 229 mm            }
  DMPAPER_ENV_C3  = 29;     { Envelope C3  324 x 458 mm           }
  DMPAPER_ENV_C4  = 30;     { Envelope C4  229 x 324 mm           }
  DMPAPER_ENV_C6  = 31;     { Envelope C6  114 x 162 mm           }
  DMPAPER_ENV_C65  = 32;    { Envelope C65 114 x 229 mm           }
  DMPAPER_ENV_B4   = 33;    { Envelope B4  250 x 353 mm           }
  DMPAPER_ENV_B5   = 34;    { Envelope B5  176 x 250 mm           }
  DMPAPER_ENV_B6   = 35;    { Envelope B6  176 x 125 mm           }
  DMPAPER_ENV_ITALY          = 36;  { Envelope 110 x 230 mm               }
  DMPAPER_ENV_MONARCH        = 37;  { Envelope Monarch 3.875 x 7.5 in     }
  DMPAPER_ENV_PERSONAL       = 38;  { 6 34 Envelope 3 58 x 6 12 in        }
  DMPAPER_FANFOLD_US         = 39;  { US Std Fanfold 14 78 x 11 in        }
  DMPAPER_FANFOLD_STD_GERMAN = 40;  { German Std Fanfold 8 12 x 12 in    }
  DMPAPER_FANFOLD_LGL_GERMAN = 41;  { German Legal Fanfold 8 12 x 13 in  }
  DMPAPER_ISO_B4             = 42;  { B4 (ISO) 250 x 353 mm               }
  DMPAPER_JAPANESE_POSTCARD  = 43;  { Japanese Postcard 100 x 148 mm      }
  DMPAPER_9X11               = 44;  { 9 x 11 in                           }
  DMPAPER_10X11              = 45;  { 10 x 11 in                          }
  DMPAPER_15X11              = 46;  { 15 x 11 in                          }
  DMPAPER_ENV_INVITE         = 47;  { Envelope Invite 220 x 220 mm        }
  DMPAPER_RESERVED_48        = 48;  { RESERVED--DO NOT USE                }
  DMPAPER_RESERVED_49        = 49;  { RESERVED--DO NOT USE                }
  DMPAPER_LETTER_EXTRA       = 50;  { Letter Extra 9 \275 x 12 in         }
  DMPAPER_LEGAL_EXTRA        = 51;  { Legal Extra 9 \275 x 15 in          }
  DMPAPER_TABLOID_EXTRA      = 52;  { Tabloid Extra 11.69 x 18 in         }
  DMPAPER_A4_EXTRA           = 53;  { A4 Extra 9.27 x 12.69 in            }
  DMPAPER_LETTER_TRANSVERSE  = 54;  { Letter Transverse 8 \275 x 11 in    }
  DMPAPER_A4_TRANSVERSE      = 55;  { A4 Transverse 210 x 297 mm          }
  DMPAPER_LETTER_EXTRA_TRANSVERSE = 56;     { Letter Extra Transverse 9\275 x 12 in  }
  DMPAPER_A_PLUS        = 57;     { SuperASuperAA4 227 x 356 mm       }
  DMPAPER_B_PLUS        = 58;     { SuperBSuperBA3 305 x 487 mm       }
  DMPAPER_LETTER_PLUS   = 59;     { Letter Plus 8.5 x 12.69 in          }
  DMPAPER_A4_PLUS       = 60;     { A4 Plus 210 x 330 mm                }
  DMPAPER_A5_TRANSVERSE = 61;     { A5 Transverse 148 x 210 mm          }
  DMPAPER_B5_TRANSVERSE = 62;     { B5 (JIS) Transverse 182 x 257 mm    }
  DMPAPER_A3_EXTRA      = 63;     { A3 Extra 322 x 445 mm               }
  DMPAPER_A5_EXTRA      = $40;    { A5 Extra 174 x 235 mm               }
  DMPAPER_B5_EXTRA      = 65;     { B5 (ISO) Extra 201 x 276 mm         }
  DMPAPER_A2            = 66;     { A2 420 x 594 mm                     }
  DMPAPER_A3_TRANSVERSE = 67;     { A3 Transverse 297 x 420 mm          }
  DMPAPER_A3_EXTRA_TRANSVERSE = 68;     { A3 Extra Transverse 322 x 445 mm    }
{
 ** the following sizes are reserved for the Far East version of Win95.
 ** Rotated papers rotate the physical page but not the logical page.
}
  DMPAPER_DBL_JAPANESE_POSTCARD = 69; { Japanese Double Postcard 200 x 148 mm }

  DMPAPER_A6                  = 70;  { A6 105 x 148 mm                 }

  DMPAPER_JENV_KAKU2          = 71;  { Japanese Envelope Kaku #2       }
  DMPAPER_JENV_KAKU3          = 72;  { Japanese Envelope Kaku #3       }
  DMPAPER_JENV_CHOU3          = 73;  { Japanese Envelope Chou #3       }
  DMPAPER_JENV_CHOU4          = 74;  { Japanese Envelope Chou #4       }
  DMPAPER_LETTER_ROTATED      = 75;  { Letter Rotated 11 x 8 1/2 11 in }
  DMPAPER_A3_ROTATED          = 76;  { A3 Rotated 420 x 297 mm         }
  DMPAPER_A4_ROTATED          = 77;  { A4 Rotated 297 x 210 mm         }
  DMPAPER_A5_ROTATED          = 78;  { A5 Rotated 210 x 148 mm         }
  DMPAPER_B4_JIS_ROTATED      = 79;  { B4 (JIS) Rotated 364 x 257 mm   }
  DMPAPER_B5_JIS_ROTATED      = 80;  { B5 (JIS) Rotated 257 x 182 mm   }
  DMPAPER_JAPANESE_POSTCARD_ROTATED = 81; { Japanese Postcard Rotated 148 x 100 mm }
  DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED = 82; { Double Japanese Postcard Rotated 148 x 200 mm }
  DMPAPER_A6_ROTATED          = 83;  { A6 Rotated 148 x 105 mm         }
  DMPAPER_JENV_KAKU2_ROTATED  = 84;  { Japanese Envelope Kaku #2 Rotated}
  DMPAPER_JENV_KAKU3_ROTATED  = 85;  { Japanese Envelope Kaku #3 Rotated}
  DMPAPER_JENV_CHOU3_ROTATED  = 86;  { Japanese Envelope Chou #3 Rotated}
  DMPAPER_JENV_CHOU4_ROTATED  = 87;  { Japanese Envelope Chou #4 Rotated}
  DMPAPER_B6_JIS              = 88;  { B6 (JIS) 128 x 182 mm           }
  DMPAPER_B6_JIS_ROTATED      = 89;  { B6 (JIS) Rotated 182 x 128 mm   }
  DMPAPER_12X11               = 90;  { 12 x 11 in                      }
  DMPAPER_JENV_YOU4           = 91;  { Japanese Envelope You #4        }
  DMPAPER_JENV_YOU4_ROTATED   = 92;  { Japanese Envelope You #4 Rotated}
  DMPAPER_P16K                = 93;  { PRC 16K 146 x 215 mm            }
  DMPAPER_P32K                = 94;  { PRC 32K 97 x 151 mm             }
  DMPAPER_P32KBIG             = 95;  { PRC 32K(Big) 97 x 151 mm        }
  DMPAPER_PENV_1              = 96;  { PRC Envelope #1 102 x 165 mm    }
  DMPAPER_PENV_2              = 97;  { PRC Envelope #2 102 x 176 mm    }
  DMPAPER_PENV_3              = 98;  { PRC Envelope #3 125 x 176 mm    }
  DMPAPER_PENV_4              = 99;  { PRC Envelope #4 110 x 208 mm    }
  DMPAPER_PENV_5              = 100; { PRC Envelope #5 110 x 220 mm    }
  DMPAPER_PENV_6              = 101; { PRC Envelope #6 120 x 230 mm    }
  DMPAPER_PENV_7              = 102; { PRC Envelope #7 160 x 230 mm    }
  DMPAPER_PENV_8              = 103; { PRC Envelope #8 120 x 309 mm    }
  DMPAPER_PENV_9              = 104; { PRC Envelope #9 229 x 324 mm    }
  DMPAPER_PENV_10             = 105; { PRC Envelope #10 324 x 458 mm   }
  DMPAPER_P16K_ROTATED        = 106; { PRC 16K Rotated                 }
  DMPAPER_P32K_ROTATED        = 107; { PRC 32K Rotated                 }
  DMPAPER_P32KBIG_ROTATED     = 108; { PRC 32K(Big) Rotated            }
  DMPAPER_PENV_1_ROTATED      = 109; { PRC Envelope #1 Rotated 165 x 102 mm}
  DMPAPER_PENV_2_ROTATED      = 110; { PRC Envelope #2 Rotated 176 x 102 mm}
  DMPAPER_PENV_3_ROTATED      = 111; { PRC Envelope #3 Rotated 176 x 125 mm}
  DMPAPER_PENV_4_ROTATED      = 112; { PRC Envelope #4 Rotated 208 x 110 mm}
  DMPAPER_PENV_5_ROTATED      = 113; { PRC Envelope #5 Rotated 220 x 110 mm}
  DMPAPER_PENV_6_ROTATED      = 114; { PRC Envelope #6 Rotated 230 x 120 mm}
  DMPAPER_PENV_7_ROTATED      = 115; { PRC Envelope #7 Rotated 230 x 160 mm}
  DMPAPER_PENV_8_ROTATED      = 116; { PRC Envelope #8 Rotated 309 x 120 mm}
  DMPAPER_PENV_9_ROTATED      = 117; { PRC Envelope #9 Rotated 324 x 229 mm}
  DMPAPER_PENV_10_ROTATED     = 118; { PRC Envelope #10 Rotated 458 x 324 mm }
  DMPAPER_LAST                = DMPAPER_PENV_10_ROTATED;
  DMPAPER_USER                = $100;

{ bin selections }

  DMBIN_UPPER = 1;
  DMBIN_FIRST = DMBIN_UPPER;
  DMBIN_ONLYONE = 1;
  DMBIN_LOWER = 2;
  DMBIN_MIDDLE = 3;
  DMBIN_MANUAL = 4;
  DMBIN_ENVELOPE = 5;
  DMBIN_ENVMANUAL = 6;
  DMBIN_AUTO = 7;
  DMBIN_TRACTOR = 8;
  DMBIN_SMALLFMT = 9;
  DMBIN_LARGEFMT = 10;
  DMBIN_LARGECAPACITY = 11;
  DMBIN_CASSETTE = 14;
  DMBIN_FORMSOURCE = 15;
  DMBIN_LAST = DMBIN_FORMSOURCE;
  DMBIN_USER = $100;   { device specific bins start here }

  { print qualities }
  DMRES_DRAFT = LongWord(-1);
  DMRES_LOW = LongWord(-2);
  DMRES_MEDIUM = LongWord(-3);
  DMRES_HIGH = LongWord(-4);

  { color enabledisable for color printers }
  DMCOLOR_MONOCHROME = 1;
  DMCOLOR_COLOR = 2;

  { duplex enable }
  DMDUP_SIMPLEX = 1;
  DMDUP_VERTICAL = 2;
  DMDUP_HORIZONTAL = 3;

  { TrueType options }
  DMTT_BITMAP           = 1;     { print TT fonts as graphics  }
  DMTT_DOWNLOAD         = 2;     { download TT fonts as soft fonts  }
  DMTT_SUBDEV           = 3;     { substitute device fonts for TT fonts  }
  DMTT_DOWNLOAD_OUTLINE = 4;     { download TT fonts as outline soft fonts  }

  { Collation selections }
  DMCOLLATE_FALSE = 0;
  DMCOLLATE_TRUE = 1;

  { DEVMODE dmDisplayFlags flags }
  DM_GRAYSCALE = $00000001;  { removed in 4.0 SDK }
  DM_INTERLACED = $00000002; { removed in 4.0 SDK }
  DM_TEXTMODE = $00000004;   { removed in 4.0 SDK }
  DMDISPLAYFLAGS_TEXTMODE     = $00000004;

  { ICM methods }
  DMICMMETHOD_NONE   = 1;     { ICM disabled  }
  DMICMMETHOD_SYSTEM = 2;     { ICM handled by system  }
  DMICMMETHOD_DRIVER = 3;     { ICM handled by driver  }
  DMICMMETHOD_DEVICE = 4;     { ICM handled by device  }

  DMICMMETHOD_USER = $100;    { Device-specific methods start here  }

  { ICM Intents }
  DMICM_SATURATE    = 1;     { Maximize color saturation  }
  DMICM_CONTRAST    = 2;     { Maximize color contrast  }
  DMICM_COLORMETRIC = 3;     { Use specific color metric  }

  DMICM_USER = $100;     { Device-specific intents start here  }


  { Media types }
  DMMEDIA_STANDARD     = 1;     { Standard paper  }
  DMMEDIA_TRANSPARENCY = 2;     { Transparency  }
  DMMEDIA_GLOSSY       = 3;     { Glossy paper  }

  DMMEDIA_USER = $100;     { Device-specific media start here  }


  { Dither types }
  DMDITHER_NONE      = 1;     { No dithering  }
  DMDITHER_COARSE    = 2;     { Dither with a coarse brush  }
  DMDITHER_FINE      = 3;     { Dither with a fine brush  }
  DMDITHER_LINEART   = 4;     { LineArt dithering  }
  DMDITHER_ERRORDIFFUSION = 5; { LineArt dithering }
  DMDITHER_RESERVED6 = 6;      { LineArt dithering }
  DMDITHER_RESERVED7 = 7;      { LineArt dithering }
  DMDITHER_RESERVED8 = 8;      { LineArt dithering }
  DMDITHER_RESERVED9 = 9;      { LineArt dithering }
  DMDITHER_GRAYSCALE = 10;     { Device does grayscaling  }

  DMDITHER_USER = 256;        { Device-specific dithers start here  }

type
  PDisplayDeviceA = ^TDisplayDeviceA;
  PDisplayDeviceW = ^TDisplayDeviceW;
  PDisplayDevice = PDisplayDeviceA;
  _DISPLAY_DEVICEA = packed record
    cb: DWORD;
    DeviceName: array[0..31] of AnsiChar;
    DeviceString: array[0..127] of AnsiChar;
    StateFlags: DWORD;
  end;
  _DISPLAY_DEVICEW = packed record
    cb: DWORD;
    DeviceName: array[0..31] of WideChar;
    DeviceString: array[0..127] of WideChar;
    StateFlags: DWORD;
  end;
  _DISPLAY_DEVICE = _DISPLAY_DEVICEA;
  TDisplayDeviceA = _DISPLAY_DEVICEA;
  TDisplayDeviceW = _DISPLAY_DEVICEW;
  TDisplayDevice = TDisplayDeviceA;

const
  DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = $00000001;
  DISPLAY_DEVICE_MULTI_DRIVER = $00000002;
  DISPLAY_DEVICE_PRIMARY_DEVICE = $00000004;
  DISPLAY_DEVICE_MIRRORING_DRIVER = $00000008;
  DISPLAY_DEVICE_VGA_COMPATIBLE = $00000010;

{ GetRegionData / ExtCreateRegion }

  RDH_RECTANGLES = 1;

type
  PRgnDataHeader = ^TRgnDataHeader;
  _RGNDATAHEADER = packed record
    dwSize: DWORD;
    iType: DWORD;
    nCount: DWORD;
    nRgnSize: DWORD;
    rcBound: TRect;
  end;
  TRgnDataHeader = _RGNDATAHEADER;
  RGNDATAHEADER = _RGNDATAHEADER;

  PRgnData = ^TRgnData;
  _RGNDATA = record
    rdh: TRgnDataHeader;
    Buffer: array[0..0] of AnsiChar;
    Reserved: array[0..2] of AnsiChar;
  end;
  TRgnData = _RGNDATA;
  RGNDATA = _RGNDATA;

  PABC = ^TABC;
  _ABC = packed record
    abcA: Integer;
    abcB: UINT;
    abcC: Integer;
  end;
  TABC = _ABC;
  ABC = _ABC;

  PABCFloat = ^TABCFloat;
  _ABCFLOAT = packed record
    abcfA: Single;
    abcfB: Single;
    abcfC: Single;
  end;
  TABCFloat = _ABCFLOAT;
  ABCFLOAT = _ABCFLOAT;

  POutlineTextmetricA = ^TOutlineTextmetricA;
  POutlineTextmetricW = ^TOutlineTextmetricW;
  POutlineTextmetric = POutlineTextmetricA;
  _OUTLINETEXTMETRICA = record
    otmSize: UINT;
    otmTextMetrics: TTextMetricA;
    otmFiller: Byte;
    otmPanoseNumber: TPanose;
    otmfsSelection: UINT;
    otmfsType: UINT;
    otmsCharSlopeRise: Integer;
    otmsCharSlopeRun: Integer;
    otmItalicAngle: Integer;
    otmEMSquare: UINT;
    otmAscent: Integer;
    otmDescent: Integer;
    otmLineGap: UINT;
    otmsCapEmHeight: UINT;
    otmsXHeight: UINT;
    otmrcFontBox: TRect;
    otmMacAscent: Integer;
    otmMacDescent: Integer;
    otmMacLineGap: UINT;
    otmusMinimumPPEM: UINT;
    otmptSubscriptSize: TPoint;
    otmptSubscriptOffset: TPoint;
    otmptSuperscriptSize: TPoint;
    otmptSuperscriptOffset: TPoint;
    otmsStrikeoutSize: UINT;
    otmsStrikeoutPosition: Integer;
    otmsUnderscoreSize: Integer;
    otmsUnderscorePosition: Integer;
    otmpFamilyName: PAnsiChar;
    otmpFaceName: PAnsiChar;
    otmpStyleName: PAnsiChar;
    otmpFullName: PAnsiChar;
  end;
  _OUTLINETEXTMETRICW = record
    otmSize: UINT;
    otmTextMetrics: TTextMetricW;
    otmFiller: Byte;
    otmPanoseNumber: TPanose;
    otmfsSelection: UINT;
    otmfsType: UINT;
    otmsCharSlopeRise: Integer;
    otmsCharSlopeRun: Integer;
    otmItalicAngle: Integer;
    otmEMSquare: UINT;
    otmAscent: Integer;
    otmDescent: Integer;
    otmLineGap: UINT;
    otmsCapEmHeight: UINT;
    otmsXHeight: UINT;
    otmrcFontBox: TRect;
    otmMacAscent: Integer;
    otmMacDescent: Integer;
    otmMacLineGap: UINT;
    otmusMinimumPPEM: UINT;
    otmptSubscriptSize: TPoint;
    otmptSubscriptOffset: TPoint;
    otmptSuperscriptSize: TPoint;
    otmptSuperscriptOffset: TPoint;
    otmsStrikeoutSize: UINT;
    otmsStrikeoutPosition: Integer;
    otmsUnderscoreSize: Integer;
    otmsUnderscorePosition: Integer;
    otmpFamilyName: PWideChar;
    otmpFaceName: PWideChar;
    otmpStyleName: PWideChar;
    otmpFullName: PWideChar;
  end;
  _OUTLINETEXTMETRIC = _OUTLINETEXTMETRICA;
  TOutlineTextmetricA = _OUTLINETEXTMETRICA;
  TOutlineTextmetricW = _OUTLINETEXTMETRICW;
  TOutlineTextmetric = TOutlineTextmetricA;
  OUTLINETEXTMETRICA = _OUTLINETEXTMETRICA;
  OUTLINETEXTMETRICW = _OUTLINETEXTMETRICW;
  OUTLINETEXTMETRIC = OUTLINETEXTMETRICA;

type
  PPolyTextA = ^TPolyTextA;
  PPolyTextW = ^TPolyTextW;
  PPolyText = PPolyTextA;
  tagPOLYTEXTA = packed record
    x: Integer;
    y: Integer;
    n: UINT;
    PAnsiChar: PAnsiChar;
    uiFlags: UINT;
    rcl: TRect;
    pdx: PINT;
  end;
  tagPOLYTEXTW = packed record
    x: Integer;
    y: Integer;
    n: UINT;
    PAnsiChar: PWideChar;
    uiFlags: UINT;
    rcl: TRect;
    pdx: PINT;
  end;
  tagPOLYTEXT = tagPOLYTEXTA;
  TPolyTextA = tagPOLYTEXTA;
  TPolyTextW = tagPOLYTEXTW;
  TPolyText = TPolyTextA;
  POLYTEXTA = tagPOLYTEXTA;
  POLYTEXTW = tagPOLYTEXTW;
  POLYTEXT = POLYTEXTA;

  _FIXED = packed record
    fract: Word;
    value: SHORT;
  end;
  TFixed = _FIXED;
  FIXED = _FIXED;

  PMat2 = ^TMat2;
  _MAT2 = packed record
    eM11: TFixed;
    eM12: TFixed;
    eM21: TFixed;
    eM22: TFixed;
  end;
  TMat2 = _MAT2;
  MAT2 = _MAT2;

  PGlyphMetrics = ^TGlyphMetrics;
  _GLYPHMETRICS = packed record
    gmBlackBoxX: UINT;
    gmBlackBoxY: UINT;
    gmptGlyphOrigin: TPoint;
    gmCellIncX: SHORT;
    gmCellIncY: SHORT;
  end;
  TGlyphMetrics = _GLYPHMETRICS;
  GLYPHMETRICS = _GLYPHMETRICS;

const
  { GetGlyphOutline constants }
  GGO_METRICS = 0;
  GGO_BITMAP = 1;
  GGO_NATIVE = 2;

  GGO_GRAY2_BITMAP = 4;
  GGO_GRAY4_BITMAP = 5;
  GGO_GRAY8_BITMAP = 6;
  GGO_GLYPH_INDEX = $80;

  TT_POLYGON_TYPE = 24;
  TT_PRIM_LINE = 1;
  TT_PRIM_QSPLINE = 2;

type
  PPointfx = ^TPointfx;
  tagPOINTFX = packed record
    x: TFixed;
    y: TFixed;
  end;
  TPointfx = tagPOINTFX;
  POINTFX = tagPOINTFX;

  PTTPolyCurve = ^TTTPolyCurve;
  tagTTPOLYCURVE = packed record
    wType: Word;
    cpfx: Word;
    apfx: array[0..0] of TPointFX;
  end;
  TTTPolyCurve = tagTTPOLYCURVE;
  TTPOLYCURVE = tagTTPOLYCURVE;

  PTTPolygonHeader = ^TTTPolygonHeader;
  tagTTPOLYGONHEADER = packed record
    cb: DWORD;
    dwType: DWORD;
    pfxStart: TPointFX;
  end;
  TTTPolygonHeader = tagTTPOLYGONHEADER;
  TTPOLYGONHEADER = tagTTPOLYGONHEADER;

const
  GCP_DBCS = 1;
  GCP_REORDER = 2;
  GCP_USEKERNING = 8;
  GCP_GLYPHSHAPE = $10;
  GCP_LIGATE = 32;
  GCP_GLYPHINDEXING = $0080; // commented out in Windows Headers

  GCP_DIACRITIC = $100;
  GCP_KASHIDA = $400;
  GCP_ERROR = $8000;
  FLI_MASK = 4155;

  GCP_JUSTIFY = $10000;
  GCP_NODIACRITICS = $00020000; // commented out in Windows Headers

  FLI_GLYPHS = $40000;
  GCP_CLASSIN = $80000;
  GCP_MAXEXTENT = $100000;
  GCP_JUSTIFYIN = $200000;
  GCP_DISPLAYZWG = $400000;
  GCP_SYMSWAPOFF = $800000;
  GCP_NUMERICOVERRIDE = $1000000;
  GCP_NEUTRALOVERRIDE = $2000000;
  GCP_NUMERICSLATIN = $4000000;
  GCP_NUMERICSLOCAL = $8000000;

  GCPCLASS_LATIN = 1;
  GCPCLASS_HEBREW = 2;
  GCPCLASS_ARABIC = 2;
  GCPCLASS_NEUTRAL = 3;
  GCPCLASS_LOCALNUMBER = 4;
  GCPCLASS_LATINNUMBER = 5;
  GCPCLASS_LATINNUMERICTERMINATOR = 6;
  GCPCLASS_LATINNUMERICSEPARATOR = 7;
  GCPCLASS_NUMERICSEPARATOR = 8;
  GCPCLASS_PREBOUNDRTL = $80;
  GCPCLASS_PREBOUNDLTR = $40;
  GCPCLASS_POSTBOUNDLTR        = $20;
  GCPCLASS_POSTBOUNDRTL        = $10;

  GCPGLYPH_LINKBEFORE          = $8000;
  GCPGLYPH_LINKAFTER           = $4000;


type
  PGCPResultsA = ^TGCPResultsA;
  PGCPResultsW = ^TGCPResultsW;
  PGCPResults = PGCPResultsA;
  tagGCP_RESULTSA = packed record
    lStructSize: DWORD;
    lpOutString: PAnsiChar;
    lpOrder: PUINT;
    lpDx: PINT;
    lpCaretPos: PINT;
    lpClass: PAnsiChar;
    lpGlyphs: PUINT;
    nGlyphs: UINT;
    nMaxFit: Integer;
  end;
  tagGCP_RESULTSW = packed record
    lStructSize: DWORD;
    lpOutString: PWideChar;
    lpOrder: PUINT;
    lpDx: PINT;
    lpCaretPos: PINT;
    lpClass: PWideChar;
    lpGlyphs: PUINT;
    nGlyphs: UINT;
    nMaxFit: Integer;
  end;
  tagGCP_RESULTS = tagGCP_RESULTSA;
  TGCPResultsA = tagGCP_RESULTSA;
  TGCPResultsW = tagGCP_RESULTSW;
  TGCPResults = TGCPResultsA;
  GCP_RESULTSA = tagGCP_RESULTSA;
  GCP_RESULTSW = tagGCP_RESULTSW;
  GCP_RESULTS = GCP_RESULTSA;

  PRasterizerStatus = ^TRasterizerStatus;
  _RASTERIZER_STATUS = packed record
    nSize: SHORT;
    wFlags: SHORT;
    nLanguageID: SHORT;
  end;
  TRasterizerStatus = _RASTERIZER_STATUS;
  RASTERIZER_STATUS = _RASTERIZER_STATUS;

const
  { bits defined in wFlags of RASTERIZER_STATUS }
  TT_AVAILABLE = 1;
  TT_ENABLED = 2;

type
  { Pixel format descriptor }
  PPixelFormatDescriptor = ^TPixelFormatDescriptor;
  tagPIXELFORMATDESCRIPTOR = packed record
    nSize: Word;
    nVersion: Word;
    dwFlags: DWORD;
    iPixelType: Byte;
    cColorBits: Byte;
    cRedBits: Byte;
    cRedShift: Byte;
    cGreenBits: Byte;
    cGreenShift: Byte;
    cBlueBits: Byte;
    cBlueShift: Byte;
    cAlphaBits: Byte;
    cAlphaShift: Byte;
    cAccumBits: Byte;
    cAccumRedBits: Byte;
    cAccumGreenBits: Byte;
    cAccumBlueBits: Byte;
    cAccumAlphaBits: Byte;
    cDepthBits: Byte;
    cStencilBits: Byte;
    cAuxBuffers: Byte;
    iLayerType: Byte;
    bReserved: Byte;
    dwLayerMask: DWORD;
    dwVisibleMask: DWORD;
    dwDamageMask: DWORD;
  end;
  TPixelFormatDescriptor = tagPIXELFORMATDESCRIPTOR;
  PIXELFORMATDESCRIPTOR = tagPIXELFORMATDESCRIPTOR;

const
  { pixel types }
  PFD_TYPE_RGBA = 0;
  PFD_TYPE_COLORINDEX = 1;

  { layer types }
  PFD_MAIN_PLANE = 0;
  PFD_OVERLAY_PLANE = 1;
  PFD_UNDERLAY_PLANE = LongWord(-1);

  { TPixelFormatDescriptor flags }
  PFD_DOUBLEBUFFER                = $00000001;
  PFD_STEREO                      = $00000002;
  PFD_DRAW_TO_WINDOW              = $00000004;
  PFD_DRAW_TO_BITMAP              = $00000008;
  PFD_SUPPORT_GDI                 = $00000010;
  PFD_SUPPORT_OPENGL              = $00000020;
  PFD_GENERIC_FORMAT              = $00000040;
  PFD_NEED_PALETTE                = $00000080;
  PFD_NEED_SYSTEM_PALETTE         = $00000100;
  PFD_SWAP_EXCHANGE               = $00000200;
  PFD_SWAP_COPY                   = $00000400;
  PFD_SWAP_LAYER_BUFFERS          = $00000800;
  PFD_GENERIC_ACCELERATED         = $00001000;

  { TPixelFormatDescriptor flags for use in ChoosePixelFormat only }
  PFD_DEPTH_DONTCARE              = $20000000;
  PFD_DOUBLEBUFFER_DONTCARE       = $40000000;
  PFD_STEREO_DONTCARE             = DWORD($80000000);

type
  TFNOldFontEnumProcA = TFarProc;
  TFNOldFontEnumProcW = TFarProc;
  TFNOldFontEnumProc = TFNOldFontEnumProcA;
  TFNGObjEnumProc = TFarProc;
  TFNLineDDAProc = TFarProc;
  TFNFontEnumProcA = TFarProc;
  TFNFontEnumProcW = TFarProc;
  TFNFontEnumProc = TFNFontEnumProcA;




function AddFontResourceA(p1: PAnsiChar): Integer; stdcall;
function AddFontResourceW(p1: PWideChar): Integer; stdcall;
function AddFontResource(p1: PTChar): Integer; stdcall;
function AnimatePalette(p1: HPALETTE; p2, p3: UINT; p4: PPaletteEntry): BOOL; stdcall;
function Arc(hDC: HDC; left, top, right, bottom, startX, startY, endX, endY: Integer): BOOL; stdcall;
function BitBlt(DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC;
  XSrc, YSrc: Integer; Rop: DWORD): BOOL; stdcall;
function CancelDC(DC: HDC): BOOL; stdcall;
function Chord(DC: HDC; X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer): BOOL; stdcall;
function ChoosePixelFormat(DC: HDC; p2: PPixelFormatDescriptor): Integer; stdcall;
function CloseMetaFile(DC: HDC): HMETAFILE; stdcall;
function CombineRgn(p1, p2, p3: HRGN; p4: Integer): Integer; stdcall;
function CopyMetaFileA(p1: HMETAFILE; p2: PAnsiChar): HMETAFILE; stdcall;
function CopyMetaFileW(p1: HMETAFILE; p2: PWideChar): HMETAFILE; stdcall;
function CopyMetaFile(p1: HMETAFILE; p2: PTChar): HMETAFILE; stdcall;
function CreateBitmap(Width, Height: Integer; Planes, BitCount: Longint;
  Bits: Pointer): HBITMAP; stdcall;
function CreateBitmapIndirect(const p1: TBitmap): HBITMAP; stdcall;
function CreateBrushIndirect(const p1: TLogBrush): HBRUSH; stdcall;
function CreateCompatibleBitmap(DC: HDC; Width, Height: Integer): HBITMAP; stdcall;
function CreateDiscardableBitmap(DC: HDC; p2, p3: Integer): HBITMAP; stdcall;
function CreateCompatibleDC(DC: HDC): HDC; stdcall;
function CreateDCA(lpszDriver, lpszDevice, lpszOutput: PAnsiChar;
  lpdvmInit: PDeviceModeA): HDC; stdcall;
function CreateDCW(lpszDriver, lpszDevice, lpszOutput: PWideChar;
  lpdvmInit: PDeviceModeW): HDC; stdcall;
function CreateDC(lpszDriver, lpszDevice, lpszOutput: PTChar;
  lpdvmInit: PDeviceMode): HDC; stdcall;
function CreateDIBitmap(DC: HDC; var InfoHeader: TBitmapInfoHeader;
  dwUsage: DWORD; InitBits: PTChar; var InitInfo: TBitmapInfo;
  wUsage: UINT): HBITMAP; stdcall;
function CreateDIBPatternBrush(p1: HGLOBAL; p2: UINT): HBRUSH; stdcall;
function CreateDIBPatternBrushPt(const p1: Pointer; p2: UINT): HBRUSH; stdcall;
function CreateEllipticRgn(p1, p2, p3, p4: Integer): HRGN; stdcall;
function CreateEllipticRgnIndirect(const p1: TRect): HRGN; stdcall;
function CreateFontIndirectA(const p1: TLogFontA): HFONT; stdcall;
function CreateFontIndirectW(const p1: TLogFontW): HFONT; stdcall;
function CreateFontIndirect(const p1: TLogFont): HFONT; stdcall;
function CreateFontA(nHeight, nWidth, nEscapement, nOrientaion, fnWeight: Integer;
  fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision,
  fdwClipPrecision, fdwQuality, fdwPitchAndFamily: DWORD; lpszFace: PAnsiChar): HFONT; stdcall;
function CreateFontW(nHeight, nWidth, nEscapement, nOrientaion, fnWeight: Integer;
  fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision,
  fdwClipPrecision, fdwQuality, fdwPitchAndFamily: DWORD; lpszFace: PWideChar): HFONT; stdcall;
function CreateFont(nHeight, nWidth, nEscapement, nOrientaion, fnWeight: Integer;
  fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision,
  fdwClipPrecision, fdwQuality, fdwPitchAndFamily: DWORD; lpszFace: PTChar): HFONT; stdcall;
function CreateHatchBrush(p1: Integer; p2: COLORREF): HBRUSH; stdcall;
function CreateICA(lpszDriver, lpszDevice, lpszOutput: PAnsiChar; lpdvmInit: PDeviceModeA): HDC; stdcall;
function CreateICW(lpszDriver, lpszDevice, lpszOutput: PWideChar; lpdvmInit: PDeviceModeW): HDC; stdcall;
function CreateIC(lpszDriver, lpszDevice, lpszOutput: PTChar; lpdvmInit: PDeviceMode): HDC; stdcall;
function CreateMetaFileA(p1: PAnsiChar): HDC; stdcall;
function CreateMetaFileW(p1: PWideChar): HDC; stdcall;
function CreateMetaFile(p1: PTChar): HDC; stdcall;
function CreatePalette(const LogPalette: TLogPalette): HPalette; stdcall;
function CreatePen(Style, Width: Integer; Color: COLORREF): HPEN; stdcall;
function CreatePenIndirect(const LogPen: TLogPen): HPEN; stdcall;
function CreatePolyPolygonRgn(const pPtStructs; const pIntArray; p3, p4: Integer): HRGN; stdcall;
function CreatePatternBrush(Bitmap: HBITMAP): HBRUSH; stdcall;
function CreateRectRgn(p1, p2, p3, p4: Integer): HRGN; stdcall;
function CreateRectRgnIndirect(const p1: TRect): HRGN; stdcall;
function CreateRoundRectRgn(p1, p2, p3, p4, p5, p6: Integer): HRGN; stdcall;
function CreateScalableFontResourceA(p1: DWORD; p2, p3, p4: PAnsiChar): BOOL; stdcall;
function CreateScalableFontResourceW(p1: DWORD; p2, p3, p4: PWideChar): BOOL; stdcall;
function CreateScalableFontResource(p1: DWORD; p2, p3, p4: PTChar): BOOL; stdcall;
function CreateSolidBrush(p1: COLORREF): HBRUSH; stdcall;
function DeleteDC(DC: HDC): BOOL; stdcall;
function DeleteMetaFile(p1: HMETAFILE): BOOL; stdcall;
function DeleteObject(p1: HGDIOBJ): BOOL; stdcall;
function DescribePixelFormat(DC: HDC; p2: Integer; p3: UINT; var p4: TPixelFormatDescriptor): BOOL; stdcall;

{ define types of pointers to ExtDeviceMode() and DeviceCapabilities()
  functions for Win 3.1 compatibility }

type
  TFNDevMode = TFarProc;
  TFNDevCaps = TFarProc;


const
  { mode selections for the device mode function }
  DM_UPDATE = 1;
  DM_COPY = 2;
  DM_PROMPT = 4;
  DM_MODIFY = 8;

  DM_IN_BUFFER = DM_MODIFY;
  DM_IN_PROMPT = DM_PROMPT;
  DM_OUT_BUFFER = DM_COPY;
  DM_OUT_DEFAULT = DM_UPDATE;

  { device capabilities indices }
  DC_FIELDS = 1;
  DC_PAPERS = 2;
  DC_PAPERSIZE = 3;
  DC_MINEXTENT = 4;
  DC_MAXEXTENT = 5;
  DC_BINS = 6;
  DC_DUPLEX = 7;
  DC_SIZE = 8;
  DC_EXTRA = 9;
  DC_VERSION = 10;
  DC_DRIVER = 11;
  DC_BINNAMES = 12;
  DC_ENUMRESOLUTIONS = 13;
  DC_FILEDEPENDENCIES = 14;
  DC_TRUETYPE = 15;
  DC_PAPERNAMES = 16;
  DC_ORIENTATION = 17;
  DC_COPIES = 18;
  DC_BINADJUST = 19;
  DC_EMF_COMPLIANT = 20;
  DC_DATATYPE_PRODUCED = 21;
  DC_COLLATE = 22;
  DC_MANUFACTURER = 23;
  DC_MODEL = 24;
  DC_COLORDEVICE = 23;
  DC_NUP = 24;
  DC_PERSONALITY = 25;
  DC_PRINTRATE = 26;
  DC_PRINTRATEUNIT = 27;
  PRINTRATEUNIT_PPM = 1;
  PRINTRATEUNIT_CPS = 2;
  PRINTRATEUNIT_LPM = 3;
  PRINTRATEUNIT_IPM = 4;
  DC_PRINTERMEM = 28;
  DC_MEDIAREADY = 29;


  { bit fields of the return value (DWORD) for DC_TRUETYPE }
  DCTT_BITMAP = 1;
  DCTT_DOWNLOAD = 2;
  DCTT_SUBDEV = 4;
  DCTT_DOWNLOAD_OUTLINE = 8;


  { return values for DC_BINADJUST }
  DCBA_FACEUPNONE = 0;
  DCBA_FACEUPCENTER = 1;
  DCBA_FACEUPLEFT = 2;
  DCBA_FACEUPRIGHT = 3;
  DCBA_FACEDOWNNONE = $100;
  DCBA_FACEDOWNCENTER = 257;
  DCBA_FACEDOWNLEFT = 258;
  DCBA_FACEDOWNRIGHT = 259;


function DeviceCapabilitiesA(pDriverName, pDeviceName, pPort: PAnsiChar;
  iIndex: Integer; pOutput: PAnsiChar; DevMode: PDeviceModeA): Integer; stdcall;
function DeviceCapabilitiesW(pDriverName, pDeviceName, pPort: PWideChar;
  iIndex: Integer; pOutput: PWideChar; DevMode: PDeviceModeW): Integer; stdcall;
function DeviceCapabilities(pDriverName, pDeviceName, pPort: PTChar;
  iIndex: Integer; pOutput: PTChar; DevMode: PDeviceMode): Integer; stdcall;

function DrawEscape(DC: HDC; p2, p3: Integer; p4: LPCSTR): BOOL; stdcall;
function Ellipse(DC: HDC; X1, Y1, X2, Y2: Integer): BOOL; stdcall;
function EnumFontFamiliesExA(DC: HDC; var p2: TLogFontA;
  p3: TFNFontEnumProcA; p4: LPARAM; p5: DWORD): BOOL; stdcall;
function EnumFontFamiliesExW(DC: HDC; var p2: TLogFontW;
  p3: TFNFontEnumProcW; p4: LPARAM; p5: DWORD): BOOL; stdcall;
function EnumFontFamiliesEx(DC: HDC; var p2: TLogFont;
  p3: TFNFontEnumProc; p4: LPARAM; p5: DWORD): BOOL; stdcall;
function EnumFontFamiliesA(DC: HDC; p2: PAnsiChar; p3: TFNFontEnumProcA; p4: LPARAM): BOOL; stdcall;
function EnumFontFamiliesW(DC: HDC; p2: PWideChar; p3: TFNFontEnumProcW; p4: LPARAM): BOOL; stdcall;
function EnumFontFamilies(DC: HDC; p2: PTChar; p3: TFNFontEnumProc; p4: LPARAM): BOOL; stdcall;
function EnumFontsA(DC: HDC; lpszFace: PAnsiChar; fntenmprc: TFNFontEnumProcA;
  lpszData: PTChar): Integer; stdcall;
function EnumFontsW(DC: HDC; lpszFace: PWideChar; fntenmprc: TFNFontEnumProcW;
  lpszData: PTChar): Integer; stdcall;
function EnumFonts(DC: HDC; lpszFace: PTChar; fntenmprc: TFNFontEnumProc;
  lpszData: PTChar): Integer; stdcall;
function EnumObjects(DC: HDC; p2: Integer; p3: TFNGObjEnumProc; p4: LPARAM): Integer; stdcall;
function EqualRgn(p1, p2: HRGN): BOOL; stdcall;
function Escape(DC: HDC; p2, p3: Integer; p4: LPCSTR; p5: Pointer): Integer; stdcall;
function ExtEscape(DC: HDC; p2, p3: Integer;
  const p4: LPCSTR; p5: Integer; p6: LPSTR): Integer; stdcall;
function ExcludeClipRect(DC: HDC; p2, p3, p4, p5: Integer): Integer; stdcall;
function ExtCreateRegion(p1: PXForm; p2: DWORD; const p3: TRgnData): HRGN; stdcall;
function ExtFloodFill(DC: HDC; X, Y: Integer; Color: COLORREF; FillType: UINT): BOOL; stdcall;
function FillRgn(DC: HDC; p2: HRGN; p3: HBRUSH): BOOL; stdcall;
function FloodFill(DC: HDC; nXStart, nYStart: Integer; crFill: COLORREF): BOOL; stdcall;
function FrameRgn(DC: HDC; p2: HRGN; p3: HBRUSH; p4, p5: Integer): BOOL; stdcall;
function GetROP2(DC: HDC): Integer; stdcall;
function GetAspectRatioFilterEx(DC: HDC; var p2: TSize): BOOL; stdcall;
function GetBkColor(hDC: HDC): COLORREF; stdcall;
function GetDCBrushColor(DC: HDC): COLORREF; stdcall;
function GetDCPenColor(DC: HDC): COLORREF; stdcall;
function GetBkMode(hDC: HDC): Integer; stdcall;
function GetBitmapBits(Bitmap: HBITMAP; Count: Longint;
  Bits: Pointer): Longint; stdcall;
function GetBitmapDimensionEx(p1: HBITMAP; var p2: TSize): BOOL; stdcall;
function GetBoundsRect(DC: HDC; var p2: TRect; p3: UINT): UINT; stdcall;
function GetBrushOrgEx(DC: HDC; var p2: TPoint): BOOL; stdcall;
function GetCharWidthA(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidthW(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidth(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidth32A(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidth32W(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidth32(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidthFloatA(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidthFloatW(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharWidthFloat(DC: HDC; p2, p3: UINT; const Widths): BOOL; stdcall;
function GetCharABCWidthsA(DC: HDC; p2, p3: UINT; const ABCStructs): BOOL; stdcall;
function GetCharABCWidthsW(DC: HDC; p2, p3: UINT; const ABCStructs): BOOL; stdcall;
function GetCharABCWidths(DC: HDC; p2, p3: UINT; const ABCStructs): BOOL; stdcall;
function GetCharABCWidthsFloatA(DC: HDC; p2, p3: UINT; const ABCFloatSturcts): BOOL; stdcall;
function GetCharABCWidthsFloatW(DC: HDC; p2, p3: UINT; const ABCFloatSturcts): BOOL; stdcall;
function GetCharABCWidthsFloat(DC: HDC; p2, p3: UINT; const ABCFloatSturcts): BOOL; stdcall;
function GetClipBox(DC: HDC; var Rect: TRect): Integer; stdcall;
function GetClipRgn(DC: HDC; rgn: HRGN): Integer; stdcall;
function GetMetaRgn(DC: HDC; rgn: HRGN): Integer; stdcall;
function GetCurrentObject(DC: HDC; p2: UINT): HGDIOBJ; stdcall;
function GetCurrentPositionEx(DC: HDC; Point: PPoint): BOOL; stdcall;
function GetDeviceCaps(DC: HDC; Index: Integer): Integer; stdcall;
function GetDIBits(DC: HDC; Bitmap: HBitmap; StartScan, NumScans: UINT;
  Bits: Pointer; var BitInfo: TBitmapInfo; Usage: UINT): Integer; stdcall;
function GetFontData(DC: HDC; p2, p3: DWORD; p4: Pointer; p5: DWORD): DWORD; stdcall;
function GetGlyphOutlineA(DC: HDC; p2, p3: UINT;
  const p4: TGlyphMetrics; p5: DWORD; p6: Pointer; const p7: TMat2): DWORD; stdcall;
function GetGlyphOutlineW(DC: HDC; p2, p3: UINT;
  const p4: TGlyphMetrics; p5: DWORD; p6: Pointer; const p7: TMat2): DWORD; stdcall;
function GetGlyphOutline(DC: HDC; p2, p3: UINT;
  const p4: TGlyphMetrics; p5: DWORD; p6: Pointer; const p7: TMat2): DWORD; stdcall;
function GetGraphicsMode(DC: HDC): Integer; stdcall;
function GetMapMode(DC: HDC): Integer; stdcall;
function GetMetaFileBitsEx(p1: HMETAFILE; p2: UINT; p3: Pointer): UINT; stdcall;
function GetMetaFileA(p1: PAnsiChar): HMETAFILE; stdcall;
function GetMetaFileW(p1: PWideChar): HMETAFILE; stdcall;
function GetMetaFile(p1: PTChar): HMETAFILE; stdcall;
function GetNearestColor(DC: HDC; p2: COLORREF): COLORREF; stdcall;
function GetNearestPaletteIndex(p1: HPALETTE; p2: COLORREF): UINT; stdcall;
function GetObjectType(h: HGDIOBJ): DWORD; stdcall;
function GetOutlineTextMetricsA(DC: HDC; p2: UINT; OTMetricStructs: Pointer): UINT; stdcall;
function GetOutlineTextMetricsW(DC: HDC; p2: UINT; OTMetricStructs: Pointer): UINT; stdcall;
function GetOutlineTextMetrics(DC: HDC; p2: UINT; OTMetricStructs: Pointer): UINT; stdcall;
function GetPaletteEntries(Palette: HPALETTE; StartIndex, NumEntries: UINT;
  var PaletteEntries): UINT; stdcall;
function GetPixel(DC: HDC; X, Y: Integer): COLORREF; stdcall;
function GetPixelFormat(DC: HDC): Integer; stdcall;
function GetPolyFillMode(DC: HDC): Integer; stdcall;
function GetRasterizerCaps(var p1: TRasterizerStatus; p2: UINT): BOOL; stdcall;
function GetRegionData(RGN: HRGN; p2: DWORD; p3: PRgnData): DWORD; stdcall;
function GetRgnBox(RGN: HRGN; var p2: TRect): Integer; stdcall;
function GetStockObject(Index: Integer): HGDIOBJ; stdcall;
function GetStretchBltMode(DC: HDC): Integer; stdcall;
function GetSystemPaletteEntries(DC: HDC; StartIndex, NumEntries: UINT;
  var PaletteEntries): UINT; stdcall;
function GetSystemPaletteUse(DC: HDC): UINT; stdcall;
function GetTextCharacterExtra(DC: HDC): Integer; stdcall;
function GetTextAlign(DC: HDC): UINT; stdcall;
function GetTextColor(DC: HDC): COLORREF; stdcall;
function GetTextExtentPointA(DC: HDC; Str: PAnsiChar; Count: Integer;
  var Size: TSize): BOOL; stdcall;
function GetTextExtentPointW(DC: HDC; Str: PWideChar; Count: Integer;
  var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint(DC: HDC; Str: PTChar; Count: Integer;
  var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint32A(DC: HDC; Str: PAnsiChar; Count: Integer;
  var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint32W(DC: HDC; Str: PWideChar; Count: Integer;
  var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint32(DC: HDC; Str: PTChar; Count: Integer;
  var Size: TSize): BOOL; stdcall;
function GetTextExtentExPointA(DC: HDC; p2: PAnsiChar;
  p3, p4: Integer; p5, p6: PInteger; var p7: TSize): BOOL; stdcall;
function GetTextExtentExPointW(DC: HDC; p2: PWideChar;
  p3, p4: Integer; p5, p6: PInteger; var p7: TSize): BOOL; stdcall;
function GetTextExtentExPoint(DC: HDC; p2: PTChar;
  p3, p4: Integer; p5, p6: PInteger; var p7: TSize): BOOL; stdcall;
function GetTextCharset(hdc: HDC): Integer; stdcall;
function GetTextCharsetInfo(hdc: HDC; lpSig: PFontSignature; dwFlags: DWORD): BOOL; stdcall;
function TranslateCharsetInfo(var lpSrc: DWORD; var lpCs: TCharsetInfo; dwFlags: DWORD): BOOL; stdcall;
function GetFontLanguageInfo(DC: HDC): DWORD; stdcall;
function GetCharacterPlacementA(DC: HDC; p2: PAnsiChar; p3, p4: BOOL;
  var p5: TGCPResults; p6: DWORD): DWORD; stdcall;
function GetCharacterPlacementW(DC: HDC; p2: PWideChar; p3, p4: BOOL;
  var p5: TGCPResults; p6: DWORD): DWORD; stdcall;
function GetCharacterPlacement(DC: HDC; p2: PTChar; p3, p4: BOOL;
  var p5: TGCPResults; p6: DWORD): DWORD; stdcall;

type
  PWCRange = ^TWCRange;
  tagWCRANGE = packed record
    wcLow: WCHAR;
    cGlyphs: SHORT;
  end;
  TWCRange = tagWCRANGE;

  PGlyphSet = ^TGlyphSet;
  tagGLYPHSET = packed record
    cbThis: DWORD;
    flAccel: DWORD;
    cGlyphsSupported: DWORD;
    cRanges: DWORD;
    ranges: array[0..0] of TWCRange;
  end;
  TGlyphSet = tagGLYPHSET;

const
  { flAccel flags for the TGlyphSet structure above }
  GS_8BIT_INDICES = 1;
  { flags for GetGlyphIndices }
  GGI_MARK_NONEXISTING_GLYPHS = 1;

function GetFontUnicodeRanges(DC: HDC; lpgs: PGlyphSet): DWORD; stdcall;
function GetGlyphIndicesA(DC: HDC; p2: PAnsiChar; p3: Integer; p4: PWORD; p5: DWORD): DWORD; stdcall;
function GetGlyphIndicesW(DC: HDC; p2: PAnsiChar; p3: Integer; p4: PWORD; p5: DWORD): DWORD; stdcall;
function GetGlyphIndices(DC: HDC; p2: PAnsiChar; p3: Integer; p4: PWORD; p5: DWORD): DWORD; stdcall;
function GetTextExtentPointI(DC: HDC; p2: PWORD; p3: Integer; var p4: TSize): BOOL; stdcall;
function GetTextExtentExPointI(DC: HDC; p2: PWORD; p3, p4: Integer; p5, p6: PINT; var p7: TSize): BOOL; stdcall;
function GetCharWidthI(DC: HDC; p2, p3: UINT; p4: PWORD; const Widths): BOOL; stdcall;
function GetCharABCWidthsI(DC: HDC; p2, p3: UINT; p4: PWORD; const Widths): BOOL; stdcall;

const
  STAMP_DESIGNVECTOR = $80000000 + Ord('d') + (Ord('v') shl 8);
  STAMP_AXESLIST = $80000000 + Ord('a') + (Ord('l') shl 8);
  MM_MAX_NUMAXES = 16;

type
  PDesignVector = ^TDesignVector;
  tagDESIGNVECTOR = packed record
    dvReserved: DWORD;
    dvNumAxes: DWORD;
    dvValues: array[0..MM_MAX_NUMAXES-1] of Longint;
  end;
  TDesignVector = tagDESIGNVECTOR;

function AddFontResourceExA(p1: PAnsiChar; p2: DWORD; p3: PDesignVector): Integer; stdcall;
function AddFontResourceExW(p1: PAnsiChar; p2: DWORD; p3: PDesignVector): Integer; stdcall;
function AddFontResourceEx(p1: PAnsiChar; p2: DWORD; p3: PDesignVector): Integer; stdcall;
function RemoveFontResourceExA(p1: PAnsiChar; p2: DWORD; p3: PDesignVector): BOOL; stdcall;
function RemoveFontResourceExW(p1: PAnsiChar; p2: DWORD; p3: PDesignVector): BOOL; stdcall;
function RemoveFontResourceEx(p1: PAnsiChar; p2: DWORD; p3: PDesignVector): BOOL; stdcall;

function AddFontMemResourceEx(p1: Pointer; p2: DWORD; p3: PDesignVector; p4: LPDWORD): THandle; stdcall;
function RemoveFontMemResourceEx(p1: THandle): BOOL; stdcall;

const
  FR_PRIVATE = $10;
  FR_NOT_ENUM = $20;
  MM_MAX_AXES_NAMELEN = 16;

type
  PAxisInfoA = ^TAxisInfoA;
  tagAXISINFOA = packed record
    axMinValue: Longint;
    axMaxValue: Longint;
    axAxisName: array[0..MM_MAX_AXES_NAMELEN-1] of AnsiChar;
  end;
  TAxisInfoA = tagAXISINFOA;
  PAxisInfoW = ^TAxisInfoW;
  tagAXISINFOW = packed record
    axMinValue: Longint;
    axMaxValue: Longint;
    axAxisName: array[0..MM_MAX_AXES_NAMELEN-1] of WideChar;
  end;
  TAxisInfoW = tagAXISINFOW;
  PAxisInfo = PAxisInfoA;

  PAxesListA = ^TAxesListA;
  tagAXESLISTA = packed record
    axlReserved: DWORD;
    axlNumAxes: DWORD;
    axlAxisInfo: array[0..MM_MAX_NUMAXES-1] of TAxisInfoA;
  end;
  TAxesListA = tagAXESLISTA;
  PAxesListW = ^TAxesListW;
  tagAXESLISTW = packed record
    axlReserved: DWORD;
    axlNumAxes: DWORD;
    axlAxisInfo: array[0..MM_MAX_NUMAXES-1] of TAxisInfoW;
  end;
  TAxesListW = tagAXESLISTW;
  PAxesList = PAxesListA;

  PEnumLogFontExDVA = ^TEnumLogFontExDVA;
  tagENUMLOGFONTEXDVA = packed record
    elfEnumLogfontEx: TEnumLogFontExA;
    elfDesignVector: TDesignVector;
  end;
  TEnumLogFontExDVA = tagENUMLOGFONTEXDVA;
  PEnumLogFontExDVW = ^TEnumLogFontExDVW;
  tagENUMLOGFONTEXDVW = packed record
    elfEnumLogfontEx: TEnumLogFontExW;
    elfDesignVector: TDesignVector;
  end;
  TEnumLogFontExDVW = tagENUMLOGFONTEXDVW;
  PEnumLogFontExDV = PEnumLogFontExDVA;

function CreateFontIndirectExA(const p1: PEnumLogFontExDVA): HFONT; stdcall;
function CreateFontIndirectExW(const p1: PEnumLogFontExDVW): HFONT; stdcall;
function CreateFontIndirectEx(const p1: PEnumLogFontExDV): HFONT; stdcall;

type
  PEnumTextMetricA = ^TEnumTextMetricA;
  tagENUMTEXTMETRICA = packed record
    etmNewTextMetricEx: TNewTextMetricExA;
    etmAxesList: TAxesListA;
  end;
  TEnumTextMetricA = tagENUMTEXTMETRICA;
  PEnumTextMetricW = ^TEnumTextMetricW;
  tagENUMTEXTMETRICW = packed record
    etmNewTextMetricEx: TNewTextMetricExW;
    etmAxesList: TAxesListW;
  end;
  TEnumTextMetricW = tagENUMTEXTMETRICW;
  PEnumTextMetric = PEnumTextMetricA;

function GetViewportExtEx(DC: HDC; var Size: TSize): BOOL; stdcall;
function GetViewportOrgEx(DC: HDC; var Point: TPoint): BOOL; stdcall;
function GetWindowExtEx(DC: HDC; var Size: TSize): BOOL; stdcall;
function GetWindowOrgEx(DC: HDC; var Point: TPoint): BOOL; stdcall;
function IntersectClipRect(DC: HDC; X1, Y1, X2, Y2: Integer): Integer; stdcall;
function InvertRgn(DC: HDC; p2: HRGN): BOOL; stdcall;
function LineDDA(p1, p2, p3, p4: Integer; p5: TFNLineDDAProc; p6: LPARAM): BOOL; stdcall;
function LineTo(DC: HDC; X, Y: Integer): BOOL; stdcall;
function MaskBlt(DC: HDC; p2, p3, p4, p5: Integer; p6: HDC;
  p7, p8: Integer; p9: HBITMAP; p10, p11: Integer; p12: DWORD): BOOL; stdcall;
function PlgBlt(DC: HDC; const PointsArray; p3: HDC;
  p4, p5, p6, p7: Integer; p8: HBITMAP; p9, p10: Integer): BOOL; stdcall;
function OffsetClipRgn(DC: HDC; p2, p3: Integer): Integer; stdcall;
function OffsetRgn(RGN: HRGN; p2, p3: Integer): Integer; stdcall;
function PatBlt(DC: HDC; X, Y, Width, Height: Integer; Rop: DWORD): BOOL; stdcall;
function Pie(DC: HDC; X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer): BOOL; stdcall;
function PlayMetaFile(DC: HDC; MF: HMETAFILE): BOOL; stdcall;
function PaintRgn(DC: HDC; RGN: HRGN): BOOL; stdcall;
function PolyPolygon(DC: HDC; var Points; var nPoints; p4: Integer): BOOL; stdcall;
function PtInRegion(RGN: HRGN; p2, p3: Integer): BOOL; stdcall;
function PtVisible(DC: HDC; p2, p3: Integer): BOOL; stdcall;
function RectInRegion(RGN: HRGN; const p2: TRect): BOOL; stdcall;
function RectVisible(DC: HDC; const Rect: TRect): BOOL; stdcall;
function Rectangle(DC: HDC; X1, Y1, X2, Y2: Integer): BOOL; stdcall;
function RestoreDC(DC: HDC; SavedDC: Integer): BOOL; stdcall;
function ResetDCA(DC: HDC; const p2: TDeviceModeA): HDC; stdcall;
function ResetDCW(DC: HDC; const p2: TDeviceModeW): HDC; stdcall;
function ResetDC(DC: HDC; const p2: TDeviceMode): HDC; stdcall;
function RealizePalette(DC: HDC): UINT; stdcall;
function RemoveFontResourceA(p1: PAnsiChar): BOOL; stdcall;
function RemoveFontResourceW(p1: PWideChar): BOOL; stdcall;
function RemoveFontResource(p1: PTChar): BOOL; stdcall;
function RoundRect(DC: HDC; X1, Y1, X2, Y2, X3, Y3: Integer): BOOL; stdcall;
function ResizePalette(p1: HPALETTE; p2: UINT): BOOL; stdcall;
function SaveDC(DC: HDC): Integer; stdcall;
function SelectClipRgn(DC: HDC; p2: HRGN): Integer; stdcall;
function ExtSelectClipRgn(DC: HDC; p2: HRGN; p3: Integer): Integer; stdcall;
function SetMetaRgn(DC: HDC): Integer; stdcall;
function SelectObject(DC: HDC; p2: HGDIOBJ): HGDIOBJ; stdcall;
function SelectPalette(DC: HDC; Palette: HPALETTE;
  ForceBackground: Bool): HPALETTE; stdcall;
function SetBkColor(DC: HDC; Color: COLORREF): COLORREF; stdcall;
function SetDCBrushColor(DC: HDC; Color: COLORREF): COLORREF; stdcall;
function SetDCPenColor(DC: HDC; Color: COLORREF): COLORREF; stdcall;
function SetBkMode(DC: HDC; BkMode: Integer): Integer; stdcall;
function SetBitmapBits(p1: HBITMAP; p2: DWORD; bits: Pointer): Longint; stdcall;
function SetBoundsRect(DC: HDC; p2: PRect; p3: UINT): UINT; stdcall;
function SetDIBits(DC: HDC; Bitmap: HBITMAP; StartScan, NumScans: UINT;
  Bits: Pointer; var BitsInfo: TBitmapInfo; Usage: UINT): Integer; stdcall;
function SetDIBitsToDevice(DC: HDC; DestX, DestY: Integer; Width, Height: DWORD;
  SrcX, SrcY: Integer; nStartScan, NumScans: UINT; Bits: Pointer;
  var BitsInfo: TBitmapInfo; Usage: UINT): Integer; stdcall;
function SetMapperFlags(DC: HDC; Flag: DWORD): DWORD; stdcall;
function SetGraphicsMode(hdc: HDC; iMode: Integer): Integer; stdcall;
function SetMapMode(DC: HDC; p2: Integer): Integer; stdcall;
function SetMetaFileBitsEx(p1: UINT; const p2: PTChar): HMETAFILE; stdcall;
function SetPaletteEntries(Palette: HPALETTE; StartIndex, NumEntries: UINT;
  var PaletteEntries): UINT; stdcall;
function SetPixel(DC: HDC; X, Y: Integer; Color: COLORREF): COLORREF; stdcall;
function SetPixelV(DC: HDC; X, Y: Integer; Color: COLORREF): BOOL; stdcall;
function SetPixelFormat(DC: HDC; p2: Integer; p3: PPixelFormatDescriptor): BOOL; stdcall;
function SetPolyFillMode(DC: HDC; PolyFillMode: Integer): Integer; stdcall;
function StretchBlt(DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC;
  XSrc, YSrc, SrcWidth, SrcHeight: Integer; Rop: DWORD): BOOL; stdcall;
function SetRectRgn(Rgn: HRgn; X1, Y1, X2, Y2: Integer): BOOL; stdcall;
function StretchDIBits(DC: HDC; DestX, DestY, DestWidth, DestHegiht, SrcX,
  SrcY, SrcWidth, SrcHeight: Integer; Bits: Pointer; var BitsInfo: TBitmapInfo;
  Usage: UINT; Rop: DWORD): Integer; stdcall;
function SetROP2(DC: HDC; p2: Integer): Integer; stdcall;
function SetStretchBltMode(DC: HDC; p2: Integer): Integer; stdcall;
function SetSystemPaletteUse(DC: HDC; p2: UINT): UINT; stdcall;
function SetTextCharacterExtra(DC: HDC; CharExtra: Integer): Integer; stdcall;
function SetTextColor(DC: HDC; Color: COLORREF): COLORREF; stdcall;
function SetTextAlign(DC: HDC; Flags: UINT): UINT; stdcall;
function SetTextJustification(DC: HDC; BreakExtra, BreakCount: Integer): Integer; stdcall;
function UpdateColors(DC: HDC): BOOL; stdcall;

type
  COLOR16 = Word;

  PTriVertex = ^TTriVertex;
  _TRIVERTEX = packed record
    x: Longint;
    y: Longint;
    Red: COLOR16;
    Green: COLOR16;
    Blue: COLOR16;
    Alpha: COLOR16;
  end;
  TTriVertex = _TRIVERTEX;
  TRIVERTEX = _TRIVERTEX;

  PGradientTriangle = ^TGradientTriangle;
  _GRADIENT_TRIANGLE = packed record
    Vertex1: ULONG;
    Vertex2: ULONG;
    Vertex3: ULONG;
  end;
  TGradientTriangle = _GRADIENT_TRIANGLE;
  GRADIENT_TRIANGLE = _GRADIENT_TRIANGLE;

  PGradientRect = ^TGradientRect;
  _GRADIENT_RECT = packed record
    UpperLeft: ULONG;
    LowerRight: ULONG;
  end;
  TGradientRect = _GRADIENT_RECT;
  GRADIENT_RECT = _GRADIENT_RECT;

  PBlendFunction = ^TBlendFunction;
  _BLENDFUNCTION = packed record
    BlendOp: BYTE;
    BlendFlags: BYTE;
    SourceConstantAlpha: BYTE;
    AlphaFormat: BYTE;
  end;
  TBlendFunction = _BLENDFUNCTION;
  BLENDFUNCTION = _BLENDFUNCTION;

const
  { currentlly defined blend function }
  AC_SRC_OVER = $00;

  { alpha format flags }
  AC_SRC_NO_PREMULT_ALPHA = $01;
  AC_SRC_NO_ALPHA = $02;
  AC_DST_NO_PREMULT_ALPHA = $10;
  AC_DST_NO_ALPHA = $20;

function AlphaBlend(DC: HDC; p2, p3, p4, p5: Integer; DC6: HDC; p7, p8, p9, p10: Integer; p11: TBlendFunction): BOOL; stdcall;
function AlphaDIBBlend(DC: HDC; p2, p3, p4, p5: Integer; const p6: Pointer;
        const p7: PBitmapInfo; p8: UINT; p9, p10, p11, p12: Integer; p13: TBlendFunction): BOOL; stdcall;
function TransparentBlt(DC: HDC; p2, p3, p4, p5: Integer; DC6: HDC; p7, p8, p9, p10: Integer; p11: UINT): BOOL; stdcall;
function TransparentDIBits(DC: HDC; p2, p3, p4, p5: Integer; const p6: Pointer;
        const p7: PBitmapInfo; p8: UINT; p9, p10, p11, p12: Integer; p13: UINT): BOOL; stdcall;

const
  { gradient drawing modes }
  GRADIENT_FILL_RECT_H = $00000000;
  GRADIENT_FILL_RECT_V = $00000001;
  GRADIENT_FILL_TRIANGLE = $00000002;
  GRADIENT_FILL_OP_FLAG = $000000ff;

//function GradientFill(DC: HDC; var p2: TTriVertex; p3: ULONG; p4: Pointer; p5, p6: ULONG): BOOL; stdcall;
function GradientFill(DC: HDC; Vertex: PTriVertex; NumVertex: ULONG; Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;

function PlayMetaFileRecord(DC: HDC; const p2: THandleTable; const p3: TMetaRecord; p4: UINT): BOOL; stdcall;

type
  TFNMFEnumProc = TFarProc;
  TFNEnhMFEnumProc = TFarProc;


function EnumMetaFile(DC: HDC; p2: HMETAFILE; p3: TFNMFEnumProc; p4: LPARAM): BOOL; stdcall;

{ Enhanced Metafile Function Declarations }

function CloseEnhMetaFile(DC: HDC): HENHMETAFILE; stdcall;
function CopyEnhMetaFileA(p1: HENHMETAFILE; p2: PAnsiChar): HENHMETAFILE; stdcall;
function CopyEnhMetaFileW(p1: HENHMETAFILE; p2: PWideChar): HENHMETAFILE; stdcall;
function CopyEnhMetaFile(p1: HENHMETAFILE; p2: PTChar): HENHMETAFILE; stdcall;
function CreateEnhMetaFileA(DC: HDC; p2: PAnsiChar; p3: PRect; p4: PAnsiChar): HDC; stdcall;
function CreateEnhMetaFileW(DC: HDC; p2: PWideChar; p3: PRect; p4: PWideChar): HDC; stdcall;
function CreateEnhMetaFile(DC: HDC; p2: PTChar; p3: PRect; p4: PTChar): HDC; stdcall;
function DeleteEnhMetaFile(p1: HENHMETAFILE): BOOL; stdcall;
function EnumEnhMetaFile(DC: HDC; p2: HENHMETAFILE; p3: TFNEnhMFEnumProc; p4: Pointer; const p5: TRect): BOOL; stdcall;
function GetEnhMetaFileA(p1: PAnsiChar): HENHMETAFILE; stdcall;
function GetEnhMetaFileW(p1: PWideChar): HENHMETAFILE; stdcall;
function GetEnhMetaFile(p1: PTChar): HENHMETAFILE; stdcall;
function GetEnhMetaFileBits(p1: HENHMETAFILE; p2: UINT; p3: PByte): UINT; stdcall;
function GetEnhMetaFileDescriptionA(p1: HENHMETAFILE; p2: UINT; p3: PAnsiChar): UINT; stdcall;
function GetEnhMetaFileDescriptionW(p1: HENHMETAFILE; p2: UINT; p3: PWideChar): UINT; stdcall;
function GetEnhMetaFileDescription(p1: HENHMETAFILE; p2: UINT; p3: PTChar): UINT; stdcall;
function GetEnhMetaFileHeader(p1: HENHMETAFILE; p2: UINT; p3: PEnhMetaHeader): UINT; stdcall;
function GetEnhMetaFilePaletteEntries(p1: HENHMETAFILE; p2: UINT; p3: Pointer): UINT; stdcall;
function GetEnhMetaFilePixelFormat(p1: HENHMETAFILE; p2: Cardinal;  var p3: TPixelFormatDescriptor): UINT; stdcall;
function GetWinMetaFileBits(p1: HENHMETAFILE; p2: UINT; p3: PByte; p4: Integer; p5: HDC): UINT; stdcall;
function PlayEnhMetaFile(DC: HDC; p2: HENHMETAFILE; const p3: TRect): BOOL; stdcall;
function PlayEnhMetaFileRecord(DC: HDC; var p2: THandleTable; const p3: TEnhMetaRecord; p4: UINT): BOOL; stdcall;
function SetEnhMetaFileBits(cbBuffer :UINT; lpData :Pointer): HENHMETAFILE; stdcall;
function SetWinMetaFileBits(cbBuffer: UINT; lpbBuffer :Pointer; hdcRef :HDC; const lpmfp :TMetaFilePict): HENHMETAFILE; stdcall;
function GdiComment(DC: HDC; p2: UINT; p3: Pointer): BOOL; stdcall;
function GetTextMetricsA(DC: HDC; var TM: TTextMetricA): BOOL; stdcall;
function GetTextMetricsW(DC: HDC; var TM: TTextMetricW): BOOL; stdcall;
function GetTextMetrics(DC: HDC; var TM: TTextMetric): BOOL; stdcall;

{ new GDI }

type
  PDIBSection = ^TDIBSection;
  tagDIBSECTION = packed record
    dsBm: TBitmap;
    dsBmih: TBitmapInfoHeader;
    dsBitfields: array[0..2] of DWORD;
    dshSection: THandle;
    dsOffset: DWORD;
  end;
  TDIBSection = tagDIBSECTION;
  DIBSECTION = tagDIBSECTION;

function AngleArc(DC: HDC; p2, p3: Integer; p4: DWORD; p5, p6: Single): BOOL; stdcall;
function PolyPolyline(DC: HDC; const PointStructs; const Points; p4: DWORD): BOOL; stdcall;
function GetWorldTransform(DC: HDC; var p2: TXForm): BOOL; stdcall;
function SetWorldTransform(DC: HDC; const p2: TXForm): BOOL; stdcall;
function ModifyWorldTransform(DC: HDC; const p2: TXForm; p3: DWORD): BOOL; stdcall;
function CombineTransform(var p1: TXForm; const p2, p3: TXForm): BOOL; stdcall;
function CreateDIBSection(DC: HDC; const p2: TBitmapInfo; p3: UINT;
  var p4: Pointer; p5: THandle; p6: DWORD): HBITMAP; stdcall;
function GetDIBColorTable(DC: HDC; p2, p3: UINT; var RGBQuadStructs): UINT; stdcall;
function SetDIBColorTable(DC: HDC; p2, p3: UINT; var RGBQuadSTructs): UINT; stdcall;

const
  { Flags value for COLORADJUSTMENT }
  CA_NEGATIVE = 1;
  CA_LOG_FILTER = 2;

  { IlluminantIndex values }
  ILLUMINANT_DEVICE_DEFAULT = 0;
  ILLUMINANT_A = 1;
  ILLUMINANT_B = 2;
  ILLUMINANT_C = 3;
  ILLUMINANT_D50 = 4;
  ILLUMINANT_D55 = 5;
  ILLUMINANT_D65 = 6;
  ILLUMINANT_D75 = 7;
  ILLUMINANT_F2 = 8;

  ILLUMINANT_MAX_INDEX = ILLUMINANT_F2;
  ILLUMINANT_TUNGSTEN = ILLUMINANT_A;
  ILLUMINANT_DAYLIGHT = ILLUMINANT_C;
  ILLUMINANT_FLUORESCENT = ILLUMINANT_F2;
  ILLUMINANT_NTSC = ILLUMINANT_C;

  { Min and max for RedGamma, GreenGamma, BlueGamma }
  RGB_GAMMA_MIN = 02500;
  RGB_GAMMA_MAX = 65000;

  { Min and max for ReferenceBlack and ReferenceWhite }
  REFERENCE_WHITE_MIN = 6000;
  REFERENCE_WHITE_MAX = 10000;
  REFERENCE_BLACK_MIN = 0;
  REFERENCE_BLACK_MAX = 4000;

  { Min and max for Contrast, Brightness, Colorfulness, RedGreenTint }
  COLOR_ADJ_MIN = -100;
  COLOR_ADJ_MAX = 100;

type
  PColorAdjustment = ^TColorAdjustment;
  tagCOLORADJUSTMENT = packed record
    caSize: Word;
    caFlags: Word;
    caIlluminantIndex: Word;
    caRedGamma: Word;
    caGreenGamma: Word;
    caBlueGamma: Word;
    caReferenceBlack: Word;
    caReferenceWhite: Word;
    caContrast: SHORT;
    caBrightness: SHORT;
    caColorfulness: SHORT;
    caRedGreenTint: SHORT;
  end;
  TColorAdjustment = tagCOLORADJUSTMENT;
  COLORADJUSTMENT = tagCOLORADJUSTMENT;

function SetColorAdjustment(DC: HDC; const p2: TColorAdjustment): BOOL; stdcall;
function GetColorAdjustment(DC: HDC; var p2: TColorAdjustment): BOOL; stdcall;
function CreateHalftonePalette(DC: HDC): HPALETTE; stdcall;

type
  TFNAbortProc = function (DC: HDC; p2: Integer): BOOL stdcall;

  PDocInfoA = ^TDocInfoA;
  PDocInfoW = ^TDocInfoW;
  PDocInfo = {$ifdef bUnicode}PDocInfoW{$else}PDocInfoA{$endif bUnicode};

  _DOCINFOA = packed record
    cbSize: Integer;
    lpszDocName: PAnsiChar;
    lpszOutput: PAnsiChar;
    lpszDatatype: PAnsiChar;
    fwType: DWORD;
  end;
  _DOCINFOW = packed record
    cbSize: Integer;
    lpszDocName: PWideChar;
    lpszOutput: PWideChar;
    lpszDatatype: PWideChar;
    fwType: DWORD;
  end;
  _DOCINFO = {$ifdef bUnicode}_DOCINFOW{$else}_DOCINFOA{$endif bUnicode};

  TDocInfoA = _DOCINFOA;
  TDocInfoW = _DOCINFOW;
  TDocInfo = {$ifdef bUnicode}TDocInfoW{$else}TDocInfoA{$endif bUnicode};

  DOCINFOA = _DOCINFOA;
  DOCINFOW = _DOCINFOW;
  DOCINFO = {$ifdef bUnicode}DOCINFOW{$else}DOCINFOA{$endif bUnicode};

const
  DI_APPBANDING = 1;

function StartDocA(DC: HDC; const p2: TDocInfoA): Integer; stdcall;
function StartDocW(DC: HDC; const p2: TDocInfoW): Integer; stdcall;
function StartDoc(DC: HDC; const p2: TDocInfo): Integer; stdcall;
function EndDoc(DC: HDC): Integer; stdcall;
function StartPage(DC: HDC): Integer; stdcall;
function EndPage(DC: HDC): Integer; stdcall;
function AbortDoc(DC: HDC): Integer; stdcall;
function SetAbortProc(DC: HDC; lpAbortProc: TFNAbortProc): Integer; stdcall;
function AbortPath(DC: HDC): BOOL; stdcall;
function ArcTo(DC: HDC; RLeft, RTop, RRight, RBottom: Integer;
  X1, Y1, X2, Y2: Integer): BOOL; stdcall;
function BeginPath(DC: HDC): BOOL; stdcall;
function CloseFigure(DC: HDC): BOOL; stdcall;
function EndPath(DC: HDC): BOOL; stdcall;
function FillPath(DC: HDC): BOOL; stdcall;
function FlattenPath(DC: HDC): BOOL; stdcall;
function GetPath(DC: HDC; var Points, Types; nSize: Integer): Integer; stdcall;
function PathToRegion(DC: HDC): HRGN; stdcall;
function PolyDraw(DC: HDC; const Points, Types; cCount: Integer): BOOL; stdcall;
function SelectClipPath(DC: HDC; Mode: Integer): BOOL; stdcall;
function SetArcDirection(DC: HDC; Direction: Integer): Integer; stdcall;
function SetMiterLimit(DC: HDC; NewLimit: Single; OldLimit: PSingle): BOOL; stdcall;
function StrokeAndFillPath(DC: HDC): BOOL; stdcall;
function StrokePath(DC: HDC): BOOL; stdcall;
function WidenPath(DC: HDC): BOOL; stdcall;
function ExtCreatePen(PenStyle, Width: DWORD; const Brush: TLogBrush;
  StyleCount: DWORD; Style: Pointer): HPEN; stdcall;
function GetMiterLimit(DC: HDC; var Limit: Single): BOOL; stdcall;
function GetArcDirection(DC: HDC): Integer; stdcall;
function GetObjectA(p1: HGDIOBJ; p2: Integer; p3: Pointer): Integer; stdcall;
function GetObjectW(p1: HGDIOBJ; p2: Integer; p3: Pointer): Integer; stdcall;
function GetObject(p1: HGDIOBJ; p2: Integer; p3: Pointer): Integer; stdcall;
function MoveToEx(DC: HDC; p2, p3: Integer; p4: PPoint): BOOL; stdcall;
function TextOutA(DC: HDC; X, Y: Integer; Str: PAnsiChar; Count: Integer): BOOL; stdcall;
function TextOutW(DC: HDC; X, Y: Integer; Str: PWideChar; Count: Integer): BOOL; stdcall;
function TextOut(DC: HDC; X, Y: Integer; Str: PTChar; Count: Integer): BOOL; stdcall;
function ExtTextOutA(DC: HDC; X, Y: Integer; Options: Longint;
  Rect: PRect; Str: PAnsiChar; Count: Longint; Dx: PInteger): BOOL; stdcall;
function ExtTextOutW(DC: HDC; X, Y: Integer; Options: Longint;
  Rect: PRect; Str: PWideChar; Count: Longint; Dx: PInteger): BOOL; stdcall;
function ExtTextOut(DC: HDC; X, Y: Integer; Options: Longint;
  Rect: PRect; Str: PTChar; Count: Longint; Dx: PInteger): BOOL; stdcall;
function PolyTextOutA(DC: HDC; const PolyTextArray; Strings: Integer): BOOL; stdcall;
function PolyTextOutW(DC: HDC; const PolyTextArray; Strings: Integer): BOOL; stdcall;
function PolyTextOut(DC: HDC; const PolyTextArray; Strings: Integer): BOOL; stdcall;
function CreatePolygonRgn(const Points; Count, FillMode: Integer): HRGN; stdcall;
function DPtoLP(DC: HDC; var Points; Count: Integer): BOOL; stdcall;
function LPtoDP(DC: HDC; var Points; Count: Integer): BOOL; stdcall;
function Polygon(DC: HDC; var Points; Count: Integer): BOOL; stdcall;
function Polyline(DC: HDC; var Points; Count: Integer): BOOL; stdcall;
function PolyBezier(DC: HDC; const Points; Count: DWORD): BOOL; stdcall;
function PolyBezierTo(DC: HDC; const Points; Count: DWORD): BOOL; stdcall;
function PolyLineTo(DC: HDC; const Points; Count: DWORD): BOOL; stdcall;
function SetViewportExtEx(DC: HDC; XExt, YExt: Integer; Size: PSize): BOOL; stdcall;
function SetViewportOrgEx(DC: HDC; X, Y: Integer; Point: PPoint): BOOL; stdcall;
function SetWindowExtEx(DC: HDC; XExt, YExt: Integer; Size: PSize): BOOL; stdcall;
function SetWindowOrgEx(DC: HDC; X, Y: Integer; Point: PPoint): BOOL; stdcall;

function OffsetViewportOrgEx(DC: HDC; X, Y: Integer; var Points): BOOL; stdcall; overload;
function OffsetWindowOrgEx(DC: HDC; X, Y: Integer; var Points): BOOL; stdcall; overload;
function OffsetViewportOrgEx(DC: HDC; X, Y: Integer; Points: PPoint): BOOL; stdcall; overload;
function OffsetWindowOrgEx(DC: HDC; X, Y: Integer; Points: PPoint): BOOL; stdcall; overload;

function ScaleViewportExtEx(DC: HDC; XM, XD, YM, YD: Integer; Size: PSize): BOOL; stdcall;
function ScaleWindowExtEx(DC: HDC; XM, XD, YM, YD: Integer; Size: PSize): BOOL; stdcall;
function SetBitmapDimensionEx(hBitmap: HBITMAP; Width, Height: Integer; Size: PSize): BOOL; stdcall;
function SetBrushOrgEx(DC: HDC; X, Y: Integer; PrevPt: PPoint): BOOL; stdcall;
function GetTextFaceA(DC: HDC; Count: Integer; Buffer: PAnsiChar): Integer; stdcall;
function GetTextFaceW(DC: HDC; Count: Integer; Buffer: PWideChar): Integer; stdcall;
function GetTextFace(DC: HDC; Count: Integer; Buffer: PTChar): Integer; stdcall;

const
  FONTMAPPER_MAX = 10;

type
  PKerningPair = ^TKerningPair;
  tagKERNINGPAIR = packed record
    wFirst: Word;
    wSecond: Word;
    iKernAmount: Integer;
  end;
  TKerningPair = tagKERNINGPAIR;
  KERNINGPAIR = tagKERNINGPAIR;

function GetKerningPairs(DC: HDC; Count: DWORD; var KerningPairs): DWORD; stdcall;
function GetDCOrgEx(DC: HDC; var Origin: TPoint): BOOL; stdcall;
function UnrealizeObject(hGDIObj: HGDIOBJ): BOOL; stdcall;
function GdiFlush: BOOL; stdcall;
function GdiSetBatchLimit(Limit: DWORD): DWORD; stdcall;
function GdiGetBatchLimit: DWORD; stdcall;

const
  ICM_OFF = 1;
  ICM_ON = 2;
  ICM_QUERY = 3;

  ICM_ADDPROFILE = 1; { removed in 4.0 SDK }
  ICM_DELETEPROFILE = 2; { removed in 4.0 SDK }
  ICM_QUERYPROFILE = 3; { removed in 4.0 SDK }
  ICM_SETDEFAULTPROFILE = 4; { removed in 4.0 SDK }
  ICM_REGISTERICMATCHER = 5; { removed in 4.0 SDK }
  ICM_UNREGISTERICMATCHER = 6; { removed in 4.0 SDK }
  ICM_QUERYMATCH = 7; { removed in 4.0 SDK }

function SetICMMode(DC: HDC; Mode: Integer): Integer; stdcall;
function CheckColorsInGamut(DC: HDC; var RGBQuads, Results; Count: DWORD): BOOL; stdcall;
function GetColorSpace(DC: HDC): THandle; stdcall;
function GetLogColorSpaceA(p1: HCOLORSPACE; var ColorSpace: TLogColorSpaceA; Size: DWORD): BOOL; stdcall;
function GetLogColorSpaceW(p1: HCOLORSPACE; var ColorSpace: TLogColorSpaceW; Size: DWORD): BOOL; stdcall;
function GetLogColorSpace(p1: HCOLORSPACE; var ColorSpace: TLogColorSpace; Size: DWORD): BOOL; stdcall;
function CreateColorSpaceA(var ColorSpace: TLogColorSpaceA): HCOLORSPACE; stdcall;
function CreateColorSpaceW(var ColorSpace: TLogColorSpaceW): HCOLORSPACE; stdcall;
function CreateColorSpace(var ColorSpace: TLogColorSpace): HCOLORSPACE; stdcall;
function SetColorSpace(DC: HDC; ColorSpace: HCOLORSPACE): BOOL; stdcall;
function DeleteColorSpace(ColorSpace: HCOLORSPACE): BOOL; stdcall;
function GetICMProfileA(DC: HDC; var Size: DWORD; Name: PAnsiChar): BOOL; stdcall;
function GetICMProfileW(DC: HDC; var Size: DWORD; Name: PWideChar): BOOL; stdcall;
function GetICMProfile(DC: HDC; var Size: DWORD; Name: PTChar): BOOL; stdcall;
function SetICMProfileA(DC: HDC; Name: PAnsiChar): BOOL; stdcall;
function SetICMProfileW(DC: HDC; Name: PWideChar): BOOL; stdcall;
function SetICMProfile(DC: HDC; Name: PTChar): BOOL; stdcall;
function GetDeviceGammaRamp(DC: HDC; var Ramp): BOOL; stdcall;
function SetDeviceGammaRamp(DC: HDC; var Ramp): BOOL; stdcall;
function ColorMatchToTarget(DC: HDC; Target: HDC; Action: DWORD): BOOL; stdcall;

type
  TFNICMEnumProc = TFarProc;


function EnumICMProfilesA(DC: HDC; ICMProc: TFNICMEnumProc; p3: LPARAM): Integer; stdcall;
function EnumICMProfilesW(DC: HDC; ICMProc: TFNICMEnumProc; p3: LPARAM): Integer; stdcall;
function EnumICMProfiles(DC: HDC; ICMProc: TFNICMEnumProc; p3: LPARAM): Integer; stdcall;

function UpdateICMRegKeyA(p1: DWORD; p2, p3: PAnsiChar; p4: UINT): BOOL; stdcall;
function UpdateICMRegKeyW(p1: DWORD; p2, p3: PWideChar; p4: UINT): BOOL; stdcall;
function UpdateICMRegKey(p1: DWORD; p2, p3: PTChar; p4: UINT): BOOL; stdcall;

function ColorCorrectPalette(DC: HDC; p2: HPALETTE; p3, p4: DWORD): BOOL; stdcall;

const
  ENHMETA_SIGNATURE = $464D4520;  { Enhanced metafile constants. }

{ Stock object flag used in the object handle index in the enhanced
  metafile records.
  E.g. The object handle index (META_STOCK_OBJECT or BLACK_BRUSH)
  represents the stock object BLACK_BRUSH. }

  ENHMETA_STOCK_OBJECT = DWORD($80000000);

{ Enhanced metafile record types.}

  EMR_HEADER = 1;
  EMR_POLYBEZIER = 2;
  EMR_POLYGON = 3;
  EMR_POLYLINE = 4;
  EMR_POLYBEZIERTO = 5;
  EMR_POLYLINETO = 6;
  EMR_POLYPOLYLINE = 7;
  EMR_POLYPOLYGON = 8;
  EMR_SETWINDOWEXTEX = 9;
  EMR_SETWINDOWORGEX = 10;
  EMR_SETVIEWPORTEXTEX = 11;
  EMR_SETVIEWPORTORGEX = 12;
  EMR_SETBRUSHORGEX = 13;
  EMR_EOF = 14;
  EMR_SETPIXELV = 15;
  EMR_SETMAPPERFLAGS = $10;
  EMR_SETMAPMODE = 17;
  EMR_SETBKMODE = 18;
  EMR_SETPOLYFILLMODE = 19;
  EMR_SETROP2 = 20;
  EMR_SETSTRETCHBLTMODE = 21;
  EMR_SETTEXTALIGN = 22;
  EMR_SETCOLORADJUSTMENT = 23;
  EMR_SETTEXTCOLOR = 24;
  EMR_SETBKCOLOR = 25;
  EMR_OFFSETCLIPRGN = 26;
  EMR_MOVETOEX = 27;
  EMR_SETMETARGN = 28;
  EMR_EXCLUDECLIPRECT = 29;
  EMR_INTERSECTCLIPRECT = 30;
  EMR_SCALEVIEWPORTEXTEX = 31;
  EMR_SCALEWINDOWEXTEX = 32;
  EMR_SAVEDC = 33;
  EMR_RESTOREDC = 34;
  EMR_SETWORLDTRANSFORM = 35;
  EMR_MODIFYWORLDTRANSFORM = 36;
  EMR_SELECTOBJECT = 37;
  EMR_CREATEPEN = 38;
  EMR_CREATEBRUSHINDIRECT = 39;
  EMR_DELETEOBJECT = 40;
  EMR_ANGLEARC = 41;
  EMR_ELLIPSE = 42;
  EMR_RECTANGLE = 43;
  EMR_ROUNDRECT = 44;
  EMR_ARC = 45;
  EMR_CHORD = 46;
  EMR_PIE = 47;
  EMR_SELECTPALETTE = 48;
  EMR_CREATEPALETTE = 49;
  EMR_SETPALETTEENTRIES = 50;
  EMR_RESIZEPALETTE = 51;
  EMR_REALIZEPALETTE = 52;
  EMR_EXTFLOODFILL = 53;
  EMR_LINETO = 54;
  EMR_ARCTO = 55;
  EMR_POLYDRAW = 56;
  EMR_SETARCDIRECTION = 57;
  EMR_SETMITERLIMIT = 58;
  EMR_BEGINPATH = 59;
  EMR_ENDPATH = 60;
  EMR_CLOSEFIGURE = 61;
  EMR_FILLPATH = 62;
  EMR_STROKEANDFILLPATH = 63;
  EMR_STROKEPATH = $40;
  EMR_FLATTENPATH = 65;
  EMR_WIDENPATH = 66;
  EMR_SELECTCLIPPATH = 67;
  EMR_ABORTPATH = 68;

  EMR_GDICOMMENT = 70;
  EMR_FILLRGN = 71;
  EMR_FRAMERGN = 72;
  EMR_INVERTRGN = 73;
  EMR_PAINTRGN = 74;
  EMR_EXTSELECTCLIPRGN = 75;
  EMR_BITBLT = 76;
  EMR_STRETCHBLT = 77;
  EMR_MASKBLT = 78;
  EMR_PLGBLT = 79;
  EMR_SETDIBITSTODEVICE = 80;
  EMR_STRETCHDIBITS = 81;
  EMR_EXTCREATEFONTINDIRECTW = 82;
  EMR_EXTTEXTOUTA = 83;
  EMR_EXTTEXTOUTW = 84;
  EMR_POLYBEZIER16 = 85;
  EMR_POLYGON16 = 86;
  EMR_POLYLINE16 = 87;
  EMR_POLYBEZIERTO16 = 88;
  EMR_POLYLINETO16 = 89;
  EMR_POLYPOLYLINE16 = 90;
  EMR_POLYPOLYGON16 = 91;
  EMR_POLYDRAW16 = 92;
  EMR_CREATEMONOBRUSH = 93;
  EMR_CREATEDIBPATTERNBRUSHPT = 94;
  EMR_EXTCREATEPEN = 95;
  EMR_POLYTEXTOUTA = 96;
  EMR_POLYTEXTOUTW = 97;
  EMR_SETICMMODE = 98;
  EMR_CREATECOLORSPACE = 99;
  EMR_SETCOLORSPACE = 100;
  EMR_DELETECOLORSPACE = 101;
  EMR_GLSRECORD = 102;
  EMR_GLSBOUNDEDRECORD = 103;
  EMR_PIXELFORMAT = 104;
  EMR_DRAWESCAPE = 105;
  EMR_EXTESCAPE = 106;
  EMR_STARTDOC = 107;
  EMR_SMALLTEXTOUT = 108;
  EMR_FORCEUFIMAPPING = 109;
  EMR_NAMEDESCAPE = 110;
  EMR_COLORCORRECTPALETTE = 111;
  EMR_SETICMPROFILEA = 112;
  EMR_SETICMPROFILEW = 113;
  EMR_ALPHABLEND = 114;
  EMR_ALPHADIBBLEND = 115;
  EMR_TRANSPARENTBLT = 116;
  EMR_TRANSPARENTDIB = 117;
  EMR_GRADIENTFILL = 118;
  EMR_SETLINKEDUFIS = 119;
  EMR_SETTEXTJUSTIFICATION = 120;
  EMR_MAX = 120;
  EMR_MIN = 1;


type
  { Base record type for the enhanced metafile.}
  PEMR = ^TEMR;
  tagEMR = packed record
    iType: DWORD; { Enhanced metafile record type}
    nSize: DWORD; { Length of the record in bytes.}
                  { This must be a multiple of 4.}
  end;
  TEMR = tagEMR;
  EMR = tagEMR;

  { Base text record type for the enhanced metafile.}
  PEMRText = ^TEMRText;
  tagEMRTEXT = packed record
    ptlReference: TPoint;
    nChars: DWORD;
    offString: DWORD; { Offset to the string}
    fOptions: DWORD;
    rcl: TRect;
    offDx: DWORD;     { Offset to the inter-character spacing array.}
                      { This is always given.}
  end;
  TEMRText = tagEMRTEXT;
  EMRTEXT = tagEMRTEXT;


  { Record structures for the enhanced metafile.}
  PAbortPath = ^TAbortPath;
  tagABORTPATH = packed record
    emr: TEMR;
  end;
  TAbortPath = tagABORTPATH;
  EMRABORTPATH = tagABORTPATH;
  TEMRAbortPath = TAbortPath;
  PEMRAbortPath = PAbortPath;
  TEMRBeginPath = TAbortPath;
  PEMRBeginPath = PAbortPath;
  TEMREndPath = TAbortPath;
  PEMREndPath = PAbortPath;
  TEMRCloseFigure = TAbortPath;
  PEMRCloseFigure = PAbortPath;
  TEMRFlattenPath = TAbortPath;
  PEMRFlattenPath = PAbortPath;
  TEMRWidenPath = TAbortPath;
  PEMRWidenPath = PAbortPath;
  TEMRSetMetaRgn = TAbortPath;
  PEMRSetMetaRgn = PAbortPath;
  TEMRSaveDC = TAbortPath;
  PEMRSaveDC = PAbortPath;
  TEMRRealizePalette = TAbortPath;
  PEMRRealizePalette = PAbortPath;

  PEMRSelectclippath = ^TEMRSelectClipPath;
  tagEMRSELECTCLIPPATH = packed record
    emr: TEMR;
    iMode: DWORD;
  end;
  TEMRSelectClipPath = tagEMRSELECTCLIPPATH;
  EMRSELECTCLIPPATH = tagEMRSELECTCLIPPATH;
  TEMRSetBkMode = TEMRSelectClipPath;
  PEMRSetBkMode = PEMRSelectClipPath;
  TEMRSetMapMode = TEMRSelectClipPath;
  PEMRSetMapMode = PEMRSelectClipPath;
  TEMRSetPolyFillMode = TEMRSelectClipPath;
  PEMRSetPolyFillMode = PEMRSelectClipPath;
  TEMRSetRop2 = TEMRSelectClipPath;
  PEMRSetRop2 = PEMRSelectClipPath;
  TEMRSetStretchBltMode = TEMRSelectClipPath;
  PEMRSetStretchBltMode = PEMRSelectClipPath;
  TEMRSetICMMode = TEMRSelectClipPath;
  PEMRSetICMMode = PEMRSelectClipPath;
  TEMRSetTextAlign = TEMRSelectClipPath;
  PEMRSetTextAlign = PEMRSelectClipPath;

  PEMRSetMiterLimit = ^TEMRSetMiterLimit;
  tagEMRSETMITERLIMIT = packed record
    emr: TEMR;
    eMiterLimit: Single;
  end;
  TEMRSetMiterLimit = tagEMRSETMITERLIMIT;
  EMRSETMITERLIMIT = tagEMRSETMITERLIMIT;

  PEMRRestoreDC = ^TEMRRestoreDC;
  tagEMRRESTOREDC = packed record
    emr: TEMR;
    iRelative: Longint;   { Specifies a relative instance}
  end;
  TEMRRestoreDC = tagEMRRESTOREDC;
  EMRRESTOREDC = tagEMRRESTOREDC;

  PEMRSetArcDirection = ^TEMRSetArcDirection;
  tagEMRSETARCDIRECTION = packed record
    emr: TEMR;
    iArcDirection: DWORD; { Specifies the arc direction in the advanced graphics mode.}
  end;
  TEMRSetArcDirection = tagEMRSETARCDIRECTION;
  EMRSETARCDIRECTION = tagEMRSETARCDIRECTION;

  PEMRSetMapperFlags = ^TEMRSetMapperFlags;
  tagEMRSETMAPPERFLAGS = packed record
    emr: TEMR;
    dwFlags: DWORD;
  end;
  TEMRSetMapperFlags = tagEMRSETMAPPERFLAGS;
  EMRSETMAPPERFLAGS = tagEMRSETMAPPERFLAGS;

  PEMRSetTextColor = ^TEMRSetTextColor;
  tagEMRSETTEXTCOLOR = packed record
    emr: TEMR;
    crColor: COLORREF;
  end;
  TEMRSetTextColor = tagEMRSETTEXTCOLOR;
  EMRSETTEXTCOLOR = tagEMRSETTEXTCOLOR;
  TEMRSetBkColor = TEMRSetTextColor;
  PEMRSetBkColor = PEMRSetTextColor;

  PEMRSelectObject = ^TEMRSelectObject;
  tagEMRSELECTOBJECT = packed record
    emr: TEMR;
    ihObject: DWORD;   { Object handle index }
  end;
  TEMRSelectObject = tagEMRSELECTOBJECT;
  EMRSELECTOBJECT = tagEMRSELECTOBJECT;
  EMRDeleteObject = TEMRSelectObject;
  PEMRDeleteObject = PEMRSelectObject;

  PEMRSelectColorSpace = ^TEMRSelectColorSpace;
  tagEMRSETCOLORSPACE = packed record
    emr: TEMR;
    ihCS: DWORD;  { ColorSpace handle index }
  end;
  TEMRSelectColorSpace = tagEMRSETCOLORSPACE;
  EMRSELECTCOLORSPACE = tagEMRSETCOLORSPACE;
  EMRDeleteColorSpace = TEMRSelectColorSpace;
  PEMRDeleteColorSpace = PEMRSelectColorSpace;

  PEMRSelectPalette = ^TEMRSelectPalette;
  tagEMRSELECTPALETTE = packed record
    emr: TEMR;
    ihPal: DWORD;   { Palette handle index, background mode only }
  end;
  TEMRSelectPalette = tagEMRSELECTPALETTE;
  EMRSELECTPALETTE = tagEMRSELECTPALETTE;

  PEMRResizePalette = ^TEMRResizePalette;
  tagEMRRESIZEPALETTE = packed record
    emr: TEMR;
    ihPal: DWORD;   { Palette handle index }
    cEntries: DWORD;
  end;
  TEMRResizePalette = tagEMRRESIZEPALETTE;
  EMRRESIZEPALETTE = tagEMRRESIZEPALETTE;

  PEMRSetPaletteEntries = ^TEMRSetPaletteEntries;
  tagEMRSETPALETTEENTRIES = packed record
    emr: TEMR;
    ihPal: DWORD;      { Palette handle index }
    iStart: DWORD;
    cEntries: DWORD;
    aPalEntries: array[0..0] of TPaletteEntry; { The peFlags fields do not contain any flags }
  end;
  TEMRSetPaletteEntries = tagEMRSETPALETTEENTRIES;
  EMRSETPALETTEENTRIES = tagEMRSETPALETTEENTRIES;

  PEMRSetColorAdjustment = ^TEMRSetColorAdjustment;
  tagEMRSETCOLORADJUSTMENT = packed record
    emr: TEMR;
    ColorAdjustment: TColorAdjustment;
  end;
  TEMRSetColorAdjustment = tagEMRSETCOLORADJUSTMENT;
  EMRSETCOLORADJUSTMENT = tagEMRSETCOLORADJUSTMENT;

  PEMRGDIComment = ^TEMRGDIComment;
  tagEMRGDICOMMENT = record
    emr: TEMR;
    cbData: DWORD;   { Size of data in bytes}
    Data: array[0..0] of Byte;
  end;
  TEMRGDIComment = tagEMRGDICOMMENT;
  EMRGDICOMMENT = tagEMRGDICOMMENT;

  PEMREOF = ^TEMREOF;
  tagEMREOF = packed record
    emr: TEMR;
    nPalEntries: DWORD;   { Number of palette entries }
    offPalEntries: DWORD; { Offset to the palette entries }
    nSizeLast: DWORD;     { Same as nSize and must be the last DWORD }
                          { of the record.  The palette entries, }
                          { if exist, precede this field. }
  end;
  TEMREOF = tagEMREOF;
  EMREOF = tagEMREOF;

  PEMRLineTo = ^TEMRLineTo;
  tagEMRLINETO = packed record
    emr: TEMR;
    ptl: TPoint;
  end;
  TEMRLineTo = tagEMRLINETO;
  EMRLINETO = tagEMRLINETO;
  EMRMoveToEx = TEMRLineTo;
  PEMRMoveToEx = PEMRLineTo;

  PEMROffsetClipRgn = ^TEMROffsetClipRgn;
  tagEMROFFSETCLIPRGN = packed record
    emr: TEMR;
    ptlOffset: TPoint;
  end;
  TEMROffsetClipRgn = tagEMROFFSETCLIPRGN;
  EMROFFSETCLIPRGN = tagEMROFFSETCLIPRGN;

  PEMRFillPath = ^TEMRFillPath;
  tagEMRFILLPATH = packed record
    emr: TEMR;
    rclBounds: TRect; { Inclusive-inclusive bounds in device units}
  end;
  TEMRFillPath = tagEMRFILLPATH;
  EMRFILLPATH = tagEMRFILLPATH;
  EMRStrokeAndFillPath = TEMRFillPath;
  PEMRStrokeAndFillPath = PEMRFillPath;
  EMRStrokePath = TEMRFillPath;
  PEMRStrokePath = PEMRFillPath;

  PEMRExcludeClipRect = ^TEMRExcludeClipRect;
  tagEMREXCLUDECLIPRECT = packed record
    emr: TEMR;
    rclClip: TRect;
  end;
  TEMRExcludeClipRect = tagEMREXCLUDECLIPRECT;
  EMREXCLUDECLIPRECT = tagEMREXCLUDECLIPRECT;
  EMRIntersectClipRect = TEMRExcludeClipRect;
  PEMRIntersectClipRect = PEMRExcludeClipRect;

  PEMRSetViewportOrgEx = ^TEMRSetViewportOrgEx;
  tagEMRSETVIEWPORTORGEX = packed record
    emr: TEMR;
    ptlOrigin: TPoint;
  end;
  TEMRSetViewportOrgEx = tagEMRSETVIEWPORTORGEX;
  EMRSETVIEWPORTORGEX = tagEMRSETVIEWPORTORGEX;
  EMRSetWindowOrgEx = TEMRSetViewportOrgEx;
  PEMRSetWindowOrgEx = PEMRSetViewportOrgEx;
  EMRSetBrushOrgEx = TEMRSetViewportOrgEx;
  PEMRSetBrushOrgEx = PEMRSetViewportOrgEx;

  PEMRSetViewportExtEx = ^TEMRSetViewportExtEx;
  tagEMRSETVIEWPORTEXTEX = packed record
    emr: TEMR;
    szlExtent: TSize;
  end;
  TEMRSetViewportExtEx = tagEMRSETVIEWPORTEXTEX;
  EMRSETVIEWPORTEXTEX = tagEMRSETVIEWPORTEXTEX;
  EMRSetWindowExtEx = TEMRSetViewportExtEx;
  PEMRSetWindowExtEx = PEMRSetViewportExtEx;

  PEMRScaleViewportExtEx = ^TEMRScaleViewportExtEx;
  tagEMRSCALEVIEWPORTEXTEX = packed record
    emr: TEMR;
    xNum: Longint;
    xDenom: Longint;
    yNum: Longint;
    yDenom: Longint;
  end;
  TEMRScaleViewportExtEx = tagEMRSCALEVIEWPORTEXTEX;
  EMRSCALEVIEWPORTEXTEX = tagEMRSCALEVIEWPORTEXTEX;
  EMRScaleWindowExtEx = TEMRScaleViewportExtEx;
  PEMRScaleWindowExtEx = PEMRScaleViewportExtEx;

  PEMRSetWorldTransform = ^TEMRSetWorldTransform;
  tagEMRSETWORLDTRANSFORM = packed record
    emr: TEMR;
    xform: TXForm;
  end;
  TEMRSetWorldTransform = tagEMRSETWORLDTRANSFORM;
  EMRSETWORLDTRANSFORM = tagEMRSETWORLDTRANSFORM;

  PEMRModifyWorldTransform = ^TEMRModifyWorldTransform;
  tagEMRMODIFYWORLDTRANSFORM = packed record
    emr: TEMR;
    xform: TXForm;
    iMode: DWORD;
  end;
  TEMRModifyWorldTransform = tagEMRMODIFYWORLDTRANSFORM;
  EMRMODIFYWORLDTRANSFORM = tagEMRMODIFYWORLDTRANSFORM;

  PEMRSetPixelV = ^TEMRSetPixelV;
  tagEMRSETPIXELV = packed record
    emr: TEMR;
    ptlPixel: TPoint;
    crColor: COLORREF;
  end;
  TEMRSetPixelV = tagEMRSETPIXELV;
  EMRSETPIXELV = tagEMRSETPIXELV;

  PEMRExtFloodFill = ^TEMRExtFloodFill;
  tagEMREXTFLOODFILL = packed record
    emr: TEMR;
    ptlStart: TPoint;
    crColor: COLORREF;
    iMode: DWORD;
  end;
  TEMRExtFloodFill = tagEMREXTFLOODFILL;
  EMREXTFLOODFILL = tagEMREXTFLOODFILL;

  PEMREllipse = ^TEMREllipse;
  tagEMRELLIPSE = packed record
    emr: TEMR;
    rclBox: TRect; { Inclusive-inclusive bounding rectangle}
  end;
  TEMREllipse = tagEMRELLIPSE;
  EMRELLIPSE = tagEMRELLIPSE;
  EMRRectangle = TEMREllipse;
  PEMRRectangle = PEMREllipse;

  PEMRRoundRect = ^TEMRRoundRect;
  tagEMRROUNDRECT = packed record
    emr: TEMR;
    rclBox: TRect;     { Inclusive-inclusive bounding rectangle }
    szlCorner: TSize;
  end;
  TEMRRoundRect = tagEMRROUNDRECT;
  EMRROUNDRECT = tagEMRROUNDRECT;

  PEMRArc = ^TEMRArc;
  tagEMRARC = packed record
    emr: TEMR;
    rclBox: TRect;     { Inclusive-inclusive bounding rectangle }
    ptlStart: TPoint;
    ptlEnd: TPoint;
  end;
  TEMRArc = tagEMRARC;
  EMRARC = tagEMRARC;
  EMRArcTo = TEMRArc;
  PEMRArcTo = PEMRArc;
  EMRChord = TEMRArc;
  PEMRChord = PEMRArc;
  EMRPie = TEMRArc;
  PEMRPie = PEMRArc;

  PEMRAngleArc = ^TEMRAngleArc;
  tagEMRANGLEARC = packed record
    emr: TEMR;
    ptlCenter: TPoint;
    nRadius: DWORD;
    eStartAngle: Single;
    eSweepAngle: Single;
  end;
  TEMRAngleArc = tagEMRANGLEARC;
  EMRANGLEARC = tagEMRANGLEARC;

  PEMRPolyline = ^TEMRPolyline;
  tagEMRPOLYLINE = packed record
    emr: TEMR;
    rclBounds: TRect;    { Inclusive-inclusive bounds in device units }
    cptl: DWORD;
    aptl: array[0..0] of TPoint;
  end;
  TEMRPolyline = tagEMRPOLYLINE;
  EMRPOLYLINE = tagEMRPOLYLINE;
  EMRPolyBezier = TEMRPolyLine;
  PEMRPolyBezier = PEMRPolyLine;
  EMRPolyGON = TEMRPolyLine;
  PEMRPolyGON = PEMRPolyLine;
  EMRPolyBezierTo = TEMRPolyLine;
  PEMRPolyBezierTo = PEMRPolyLine;
  EMRPolyLineTo = TEMRPolyLine;
  PEMRPolyLineTo = PEMRPolyLine;

  PEMRPolyline16 = ^TEMRPolyline16;
  tagEMRPOLYLINE16 = packed record
    emr: TEMR;
    rclBounds: TRect; { Inclusive-inclusive bounds in device units}
    cpts: DWORD;
    apts: array[0..0] of TSmallPoint;
  end;
  TEMRPolyline16 = tagEMRPOLYLINE16;
  EMRPOLYLINE16 = tagEMRPOLYLINE16;
  EMRPolyBezier16 = TEMRPolyLine16;
  PEMRPolyBezier16 = PEMRPolyLine16;
  EMRPolygon16 = TEMRPolyLine16;
  PEMRPolygon16 = PEMRPolyLine16;
  EMRPolyBezierTo16 = TEMRPolyLine16;
  PEMRPolyBezierTo16 = PEMRPolyLine16;
  EMRPolyLineTo16 = TEMRPolyLine16;
  PEMRPolyLineTo16 = PEMRPolyLine16;

  PEMRPolyDraw = ^TEMRPolyDraw;
  tagEMRPOLYDRAW = record
    emr: TEMR;
    rclBounds: TRect;    { Inclusive-inclusive bounds in device units}
    cptl: DWORD;         { Number of points}
    aptl: array[0..0] of TPoint;  { Array of points}
    abTypes: array[0..0] of Byte; { Array of point types}
  end;
  TEMRPolyDraw = tagEMRPOLYDRAW;
  EMRPOLYDRAW = tagEMRPOLYDRAW;

  PEMRPolyDraw16 = ^TEMRPolyDraw16;
  tagEMRPOLYDRAW16 = record
    emr: TEMR;
    rclBounds: TRect;
    cpts: DWORD;
    apts: array[0..0] of TSmallPoint;
    abTypes: array[0..0] of Byte;
  end;
  TEMRPolyDraw16 = tagEMRPOLYDRAW16;
  EMRPOLYDRAW16 = tagEMRPOLYDRAW16;

  PEMRPolyPolyline = ^TEMRPolyPolyline;
  tagEMRPOLYPOLYLINE = packed record
    emr: TEMR;
    rclBounds: TRect; { Inclusive-inclusive bounds in device units}
    nPolys: DWORD;    { Number of polys}
    cptl: DWORD;      { Total number of points in all polys}
    aPolyCounts: array[0..0] of DWORD; { Array of point counts for each poly}
    aptl: array[0..0] of TPoint;       { Array of points}
  end;
  TEMRPolyPolyline = tagEMRPOLYPOLYLINE;
  EMRPOLYPOLYLINE = tagEMRPOLYPOLYLINE;
  EMRPolyPolygon = TEMRPolyPolyline;
  PEMRPolyPolygon = PEMRPolyPolyline;

  PEMRPolyPolyline16 = ^TEMRPolyPolyline16;
  tagEMRPOLYPOLYLINE16 = packed record
    emr: TEMR;
    rclBounds: TRect;
    nPolys: DWORD;
    cpts: DWORD;
    aPolyCounts: array[0..0] of DWORD;
    apts: array[0..0] of TSmallPoint;
  end;
  TEMRPolyPolyline16 = tagEMRPOLYPOLYLINE16;
  EMRPOLYPOLYLINE16 = tagEMRPOLYPOLYLINE16;
  EMRPolyPolygon16 = TEMRPolyPolyline16;
  PEMRPolyPolygon16 = PEMRPolyPolyline16;

  PEMRInvertRgn = ^TEMRInvertRgn;
  tagEMRINVERTRGN = record
    emr: TEMR;
    rclBounds: TRect; { Inclusive-inclusive bounds in device units }
    cbRgnData: DWORD; { Size of region data in bytes}
    RgnData: array[0..0] of Byte;
  end;
  TEMRInvertRgn = tagEMRINVERTRGN;
  EMRINVERTRGN = tagEMRINVERTRGN;
  EMRPaintRgn = TEMRInvertRgn;
  PEMRPaintRgn = PEMRInvertRgn;

  PEMRFillRgn = ^TEMRFillRgn;
  tagEMRFILLRGN = record
    emr: TEMR;
    rclBounds: TRect;  { Inclusive-inclusive bounds in device units}
    cbRgnData: DWORD;  { Size of region data in bytes}
    ihBrush: DWORD;    { Brush handle index }
    RgnData: array[0..0] of Byte;
  end;
  TEMRFillRgn = tagEMRFILLRGN;
  EMRFILLRGN = tagEMRFILLRGN;

  PEMRFrameRgn = ^TEMRFrameRgn;
  tagEMRFRAMERGN = record
    emr: TEMR;
    rclBounds: TRect;   { Inclusive-inclusive bounds in device units}
    cbRgnData: DWORD;   { Size of region data in bytes}
    ihBrush: DWORD;     { Brush handle index}
    szlStroke: TSize;
    RgnData: array[0..0] of Byte;
  end;
  TEMRFrameRgn = tagEMRFRAMERGN;
  EMRFRAMERGN = tagEMRFRAMERGN;

  PEMGradientFill = ^TEMGradientFill;
  tagEMRGRADIENTFILL = record
    emr: TEMR;
    rclBounds: TRect;   { Inclusive-inclusive bounds in device units}
    nVer: DWORD;
    nTri: DWORD;
    ulMode: ULONG;
    Ver: array[0..0] of TTriVertex;
  end;
  TEMGradientFill = tagEMRGRADIENTFILL;
  EMRGRADIENTFILL = tagEMRGRADIENTFILL;

  PEMRExtSelectClipRgn = ^TEMRExtSelectClipRgn;
  tagEMREXTSELECTCLIPRGN = record
    emr: TEMR;
    cbRgnData: DWORD; { Size of region data in bytes}
    iMode: DWORD;
    RgnData: array[0..0] of Byte;
  end;
  TEMRExtSelectClipRgn = tagEMREXTSELECTCLIPRGN;
  EMREXTSELECTCLIPRGN = tagEMREXTSELECTCLIPRGN;

  PEMRExtTextOut = ^TEMRExtTextOut;
  tagEMREXTTEXTOUTA = packed record
    emr: TEMR;
    rclBounds: TRect;     { Inclusive-inclusive bounds in device units}
    iGraphicsMode: DWORD; { Current graphics mode}
    exScale: Single;       { X and Y scales from Page units to .01mm units}
    eyScale: Single;       {   if graphics mode is GM_COMPATIBLE.}
    emrtext: TEMRText;    { This is followed by the string and spacing array}
  end;
  TEMRExtTextOut = tagEMREXTTEXTOUTA;
  EMREXTTEXTOUTA = tagEMREXTTEXTOUTA;

  PEMRPolyTextOut = ^TEMRPolyTextOut;
  tagEMRPOLYTEXTOUTA = packed record
    emr: TEMR;
    rclBounds: TRect;     { Inclusive-inclusive bounds in device units}
    iGraphicsMode: DWORD; { Current graphics mode}
    exScale: Single;       { X and Y scales from Page units to .01mm units}
    eyScale: Single;       {   if graphics mode is GM_COMPATIBLE.}
    cStrings: Longint;
    aemrtext: array[0..0] of TEMRText; { array of TEMRText structures.  This is}
                                       { followed by the strings and spacing arrays.}
  end;
  TEMRPolyTextOut = tagEMRPOLYTEXTOUTA;
  EMRPOLYTEXTOUTA = tagEMRPOLYTEXTOUTA;

  PEMRBitBlt = ^TEMRBitBlt;
  tagEMRBITBLT = packed record
    emr: TEMR;
    rclBounds: TRect;        { Inclusive-inclusive bounds in device units}
    xDest: Longint;
    yDest: Longint;
    cxDest: Longint;
    cyDest: Longint;
    dwRop: DWORD;
    xSrc: Longint;
    ySrc: Longint;
    xformSrc: TXForm;        { Source DC transform}
    crBkColorSrc: COLORREF; { Source DC BkColor in RGB}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
                             { (DIB_RGB_COLORS)}
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
  end;
  TEMRBitBlt = tagEMRBITBLT;
  EMRBITBLT = tagEMRBITBLT;

  PEMRStretchBlt = ^TEMRStretchBlt;
  tagEMRSTRETCHBLT = packed record
    emr: TEMR;
    rclBounds: TRect; { Inclusive-inclusive bounds in device units}
    xDest: Longint;
    yDest: Longint;
    cxDest: Longint;
    cyDest: Longint;
    dwRop: DWORD;
    xSrc: Longint;
    ySrc: Longint;
    xformSrc: TXForm;        { Source DC transform}
    crBkColorSrc: COLORREF; { Source DC BkColor in RGB}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
                             { (DIB_RGB_COLORS)}
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    cxSrc: Longint;
    cySrc: Longint;
  end;
  TEMRStretchBlt = tagEMRSTRETCHBLT;
  EMRSTRETCHBLT = tagEMRSTRETCHBLT;

  PEMRMaskBlt = ^TEMRMaskBlt;
  tagEMRMASKBLT = packed record
    emr: TEMR;
    rclBounds: TRect;        { Inclusive-inclusive bounds in device units}
    xDest: Longint;
    yDest: Longint;
    cxDest: Longint;
    cyDest: Longint;
    dwRop: DWORD;
    xSrc: Longint;
    ySrc: Longint;
    xformSrc: TXForm;        { Source DC transform}
    crBkColorSrc: COLORREF; { Source DC BkColor in RGB}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
                             { (DIB_RGB_COLORS)}
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    xMask: Longint;
    yMask: Longint;
    iUsageMask: DWORD;       { Mask bitmap info color table usage}
    offBmiMask: DWORD;       { Offset to the mask TBitmapInfo structure if any}
    cbBmiMask: DWORD;        { Size of the mask TBitmapInfo structure if any}
    offBitsMask: DWORD;      { Offset to the mask bitmap bits if any}
    cbBitsMask: DWORD;       { Size of the mask bitmap bits if any}
  end;
  TEMRMaskBlt = tagEMRMASKBLT;
  EMRMASKBLT = tagEMRMASKBLT;

  PEMRPLGBlt = ^TEMRPLGBlt;
  tagEMRPLGBLT = packed record
    emr: TEMR;
    rclBounds: TRect;
    aptlDest: array[0..2] of TPoint;
    xSrc: Longint;
    ySrc: Longint;
    cxSrc: Longint;
    cySrc: Longint;
    xformSrc: TXForm;        { Source DC transform}
    crBkColorSrc: COLORREF; { Source DC BkColor in RGB}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
                             { (DIB_RGB_COLORS)}
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    xMask: Longint;
    yMask: Longint;
    iUsageMask: DWORD;       { Mask bitmap info color table usage}
    offBmiMask: DWORD;       { Offset to the mask TBitmapInfo structure if any}
    cbBmiMask: DWORD;        { Size of the mask TBitmapInfo structure if any}
    offBitsMask: DWORD;      { Offset to the mask bitmap bits if any}
    cbBitsMask: DWORD;       { Size of the mask bitmap bits if any}
  end;
  TEMRPLGBlt = tagEMRPLGBLT;
  EMRPLGBLT = tagEMRPLGBLT;

  PEMRSetDIBitsToDevice = ^TEMRSetDIBitsToDevice;
  tagEMRSETDIBITSTODEVICE = packed record
    emr: TEMR;
    rclBounds: TRect;
    xDest: Longint;
    yDest: Longint;
    xSrc: Longint;
    ySrc: Longint;
    cxSrc: Longint;
    cySrc: Longint;
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
    iStartScan: DWORD;
    cScans: DWORD;
  end;
  TEMRSetDIBitsToDevice = tagEMRSETDIBITSTODEVICE;
  EMRSETDIBITSTODEVICE = tagEMRSETDIBITSTODEVICE;

  PEMRStretchDIBits = ^TEMRStretchDIBits;
  tagEMRSTRETCHDIBITS = packed record
    emr: TEMR;
    rclBounds: TRect;
    xDest: Longint;
    yDest: Longint;
    xSrc: Longint;
    ySrc: Longint;
    cxSrc: Longint;
    cySrc: Longint;
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
    dwRop: DWORD;
    cxDest: Longint;
    cyDest: Longint;
  end;
  TEMRStretchDIBits = tagEMRSTRETCHDIBITS;
  EMRSTRETCHDIBITS = tagEMRSTRETCHDIBITS;

  PEMRAlphaBlend = ^TEMRAlphaBlend;
  tagEMRALPHABLEND = packed record
    emr: TEMR;
    rclBounds: TRect;
    xDest: Longint;
    yDest: Longint;
    cxDest: Longint;
    cyDest: Longint;
    dwRop: DWORD;
    xSrc: Longint;
    ySrc: Longint;
    xformSrc: XFORM;         { Source DC transform}
    crBkColorSrc: COLORREF;  { Source DC BkColor in RGB}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    cxSrc: Longint;
    cySrc: Longint;
  end;
  TEMRAlphaBlend = tagEMRALPHABLEND;
  EMRALPHABLEND = tagEMRALPHABLEND;

  PEMRTransparentBLT = ^TEMRTransparentBLT;
  tagEMRTRANSPARENTBLT = packed record
    emr: TEMR;
    rclBounds: TRect;
    xDest: Longint;
    yDest: Longint;
    cxDest: Longint;
    cyDest: Longint;
    dwRop: DWORD;
    xSrc: Longint;
    ySrc: Longint;
    xformSrc: XFORM;         { Source DC transform}
    crBkColorSrc: COLORREF;  { Source DC BkColor in RGB}
    iUsageSrc: DWORD;        { Source bitmap info color table usage}
    offBmiSrc: DWORD;        { Offset to the source TBitmapInfo structure}
    cbBmiSrc: DWORD;         { Size of the source TBitmapInfo structure}
    offBitsSrc: DWORD;       { Offset to the source bitmap bits}
    cbBitsSrc: DWORD;        { Size of the source bitmap bits}
    cxSrc: Longint;
    cySrc: Longint;
  end;
  TEMRTransparentBLT = tagEMRTRANSPARENTBLT;
  EMRTRANSPARENTBLT = tagEMRTRANSPARENTBLT;

  PEMRExtCreateFontIndirect = ^TEMRExtCreateFontIndirect;
  tagEMREXTCREATEFONTINDIRECTW = record
    emr: TEMR;
    ihFont: DWORD;     { Font handle index}
    elfw: TExtLogFontW;
  end;
  TEMRExtCreateFontIndirect = tagEMREXTCREATEFONTINDIRECTW;
  EMREXTCREATEFONTINDIRECTW = tagEMREXTCREATEFONTINDIRECTW;

  PEMRCreatePalette = ^TEMRCreatePalette;
  tagEMRCREATEPALETTE = packed record
    emr: TEMR;
    ihPal: DWORD;        { Palette handle index}
    lgpl: TLogPalette;   { The peFlags fields in the palette entries}
                         { do not contain any flags}
  end;
  TEMRCreatePalette = tagEMRCREATEPALETTE;
  EMRCREATEPALETTE = tagEMRCREATEPALETTE;

  PEMRCreateColorSpace = ^TEMRCreateColorSpace;
  tagEMRCREATECOLORSPACE = packed record
    emr: TEMR;
    ihCS: DWORD;          { ColorSpace handle index}
    lcs: TLogColorSpaceW;
  end;
  TEMRCreateColorSpace = tagEMRCREATECOLORSPACE;
  EMRCREATECOLORSPACE = tagEMRCREATECOLORSPACE;

  PEMRCreatePen = ^TEMRCreatePen;
  tagEMRCREATEPEN = packed record
    emr: TEMR;
    ihPen: DWORD;   { Pen handle index}
    lopn: TLogPen;
  end;
  TEMRCreatePen = tagEMRCREATEPEN;
  EMRCREATEPEN = tagEMRCREATEPEN;

  PEMRExtCreatePen = ^TEMRExtCreatePen;
  tagEMREXTCREATEPEN = packed record
    emr: TEMR;
    ihPen: DWORD;      { Pen handle index}
    offBmi: DWORD;     { Offset to the TBitmapInfo structure if any}
    cbBmi: DWORD;      { Size of the TBitmapInfo structure if any}
                       { The bitmap info is followed by the bitmap}
                       { bits to form a packed DIB.}
    offBits: DWORD;    { Offset to the brush bitmap bits if any}
    cbBits: DWORD;     { Size of the brush bitmap bits if any}
    elp: TExtLogPen;   { The extended pen with the style array.}
  end;
  TEMRExtCreatePen = tagEMREXTCREATEPEN;
  EMREXTCREATEPEN = tagEMREXTCREATEPEN;

  PEMRCreateBrushIndirect = ^TEMRCreateBrushIndirect;
  tagEMRCREATEBRUSHINDIRECT = packed record
    emr: TEMR;
    ihBrush: DWORD; { Brush handle index}
    lb: TLogBrush;  { The style must be BS_SOLID, BS_HOLLOW,}
                    { BS_NULL or BS_HATCHED.}
  end;
  TEMRCreateBrushIndirect = tagEMRCREATEBRUSHINDIRECT;
  EMRCREATEBRUSHINDIRECT = tagEMRCREATEBRUSHINDIRECT;

  PEMRCreateMonoBrush = ^TEMRCreateMonoBrush;
  tagEMRCREATEMONOBRUSH = packed record
    emr: TEMR;
    ihBrush: DWORD; { Brush handle index}
    iUsage: DWORD;  { Bitmap info color table usage}
    offBmi: DWORD;  { Offset to the TBitmapInfo structure}
    cbBmi: DWORD;   { Size of the TBitmapInfo structure if any}
                    { The bitmap info is followed by the bitmap}
                    { bits to form a packed DIB.}
    offBits: DWORD; { Offset to the bitmap bits}
    cbBits: DWORD;  { Size of the bitmap bits}
  end;
  TEMRCreateMonoBrush = tagEMRCREATEMONOBRUSH;
  EMRCREATEMONOBRUSH = tagEMRCREATEMONOBRUSH;

  PEMRCreateDIBPatternBrushPt = ^TEMRCreateDIBPatternBrushPt;
  tagEMRCREATEDIBPATTERNBRUSHPT = packed record
    emr: TEMR;
    ihBrush: DWORD; { Brush handle index}
    iUsage: DWORD;  { Bitmap info color table usage}
    offBmi: DWORD;  { Offset to the TBitmapInfo structure}
    cbBmi: DWORD;   { Size of the TBitmapInfo structure if any}
                    { The bitmap info is followed by the bitmap}
                    { bits to form a packed DIB.}
    offBits: DWORD; { Offset to the bitmap bits}
    cbBits: DWORD;  { Size of the bitmap bits}
  end;
  TEMRCreateDIBPatternBrushPt = tagEMRCREATEDIBPATTERNBRUSHPT;
  EMRCREATEDIBPATTERNBRUSHPT = tagEMRCREATEDIBPATTERNBRUSHPT;

  PEMRFormat = ^TEMRFormat;
  tagEMRFORMAT = packed record
    dSignature: DWORD; { Format signature, e.g. ENHMETA_SIGNATURE.}
    nVersion: DWORD;   { Format version number.}
    cbData: DWORD;     { Size of data in bytes.}
    offData: DWORD;    { Offset to data from GDICOMMENT_IDENTIFIER.}
                       { It must begin at a DWORD offset.}
  end;
  TEMRFormat = tagEMRFORMAT;
  EMRFORMAT = tagEMRFORMAT;

  PEMRGLSRecord = ^TEMRGLSRecord;
  tagEMRGLSRECORD = packed record
    emr: TEMR;
    cbData: DWORD;              { Size of data in bytes }
    Data: packed array[0..0] of Byte;
  end;
  TEMRGLSRecord = tagEMRGLSRECORD;
  EMRGLSRECORD = tagEMRGLSRECORD;


  PEMRGLSBoundedRecord = ^TEMRGLSBoundedRecord;
  tagEMRGLSBOUNDEDRECORD = packed record
    emr: TEMR;
    rclBounds: TRect;           { Bounds in recording coordinates }
    cbData: DWORD;              { Size of data in bytes }
    Data: packed array[0..0] of Byte;
  end;
  TEMRGLSBoundedRecord = tagEMRGLSBOUNDEDRECORD;
  EMRGLSBOUNDEDRECORD = tagEMRGLSBOUNDEDRECORD;

  PEMRPixelFormat = ^TEMRPixelFormat;
  tagEMRPIXELFORMAT = packed record
    emr: TEMR;
    pfd: TPixelFormatDescriptor;
  end;
  TEMRPixelFormat = tagEMRPIXELFORMAT;
  EMRPIXELFORMAT = tagEMRPIXELFORMAT;

const
  GDICOMMENT_IDENTIFIER = $43494447;
  GDICOMMENT_WINDOWS_METAFILE = DWORD($80000001);
  GDICOMMENT_BEGINGROUP = 2;
  GDICOMMENT_ENDGROUP = 3;
  GDICOMMENT_MULTIFORMATS = $40000004;
  EPS_SIGNATURE = $46535045;

{ OpenGL wgl prototypes}

function wglCopyContext(p1: HGLRC; p2: HGLRC; p3: Cardinal): BOOL; stdcall;
function wglCreateContext(DC: HDC): HGLRC; stdcall;
function wglCreateLayerContext(p1: HDC; p2: Integer): HGLRC; stdcall;
function wglDeleteContext(p1: HGLRC): BOOL; stdcall;
function wglGetCurrentContext: HGLRC; stdcall;
function wglGetCurrentDC: HDC; stdcall;
function wglMakeCurrent(DC: HDC; p2: HGLRC): BOOL; stdcall;
function wglShareLists(p1, p2: HGLRC): BOOL; stdcall;
function wglUseFontBitmapsA(DC: HDC; p2, p3, p4: DWORD): BOOL; stdcall;
function wglUseFontBitmapsW(DC: HDC; p2, p3, p4: DWORD): BOOL; stdcall;
function wglUseFontBitmaps(DC: HDC; p2, p3, p4: DWORD): BOOL; stdcall;
function SwapBuffers(DC: HDC): BOOL; stdcall;

type
  PPointFloat = ^TPointFloat;
  _POINTFLOAT = packed record
    x: Single;
    y: Single;
  end;
  TPointFloat = _POINTFLOAT;
  POINTFLOAT = _POINTFLOAT;

  PGlyphMetricsFloat = ^TGlyphMetricsFloat;
  _GLYPHMETRICSFLOAT = packed record
    gmfBlackBoxX: Single;
    gmfBlackBoxY: Single;
    gmfptGlyphOrigin: TPointFloat;
    gmfCellIncX: Single;
    gmfCellIncY: Single;
  end;
  TGlyphMetricsFloat = _GLYPHMETRICSFLOAT;
  GLYPHMETRICSFLOAT = _GLYPHMETRICSFLOAT;

const
  WGL_FONT_LINES = 0;
  WGL_FONT_POLYGONS = 1;

function wglUseFontOutlinesA(p1: HDC; p2, p3, p4: DWORD;
  p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall;
function wglUseFontOutlinesW(p1: HDC; p2, p3, p4: DWORD;
  p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall;
function wglUseFontOutlines(p1: HDC; p2, p3, p4: DWORD;
  p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall;

{ Layer plane descriptor }
type
  PLayerPlaneDescriptor = ^TLayerPlaneDescriptor;
  tagLAYERPLANEDESCRIPTOR = packed record   { lpd }
    nSize: Word;
    nVersion: Word;
    dwFlags: DWORD;
    iPixelType: Byte;
    cColorBits: Byte;
    cRedBits: Byte;
    cRedShift: Byte;
    cGreenBits: Byte;
    cGreenShift: Byte;
    cBlueBits: Byte;
    cBlueShift: Byte;
    cAlphaBits: Byte;
    cAlphaShift: Byte;
    cAccumBits: Byte;
    cAccumRedBits: Byte;
    cAccumGreenBits: Byte;
    cAccumBlueBits: Byte;
    cAccumAlphaBits: Byte;
    cDepthBits: Byte;
    cStencilBits: Byte;
    cAuxBuffers: Byte;
    iLayerPlane: Byte;
    bReserved: Byte;
    crTransparent: COLORREF;
  end;
  TLayerPlaneDescriptor = tagLAYERPLANEDESCRIPTOR;
  LAYERPLANEDESCRIPTOR = tagLAYERPLANEDESCRIPTOR;


{ TLayerPlaneDescriptor flags }
const
  LPD_DOUBLEBUFFER = $00000001;
  LPD_STEREO = $00000002;
  LPD_SUPPORT_GDI = $00000010;
  LPD_SUPPORT_OPENGL = $00000020;
  LPD_SHARE_DEPTH = $00000040;
  LPD_SHARE_STENCIL = $00000080;
  LPD_SHARE_ACCUM = $00000100;
  LPD_SWAP_EXCHANGE = $00000200;
  LPD_SWAP_COPY = $00000400;
  LPD_TRANSPARENT = $00001000;

  LPD_TYPE_RGBA = 0;
  LPD_TYPE_COLORINDEX = 1;

{ wglSwapLayerBuffers flags }
  WGL_SWAP_MAIN_PLANE = $00000001;
  WGL_SWAP_OVERLAY1 = $00000002;
  WGL_SWAP_OVERLAY2 = $00000004;
  WGL_SWAP_OVERLAY3 = $00000008;
  WGL_SWAP_OVERLAY4 = $00000010;
  WGL_SWAP_OVERLAY5 = $00000020;
  WGL_SWAP_OVERLAY6 = $00000040;
  WGL_SWAP_OVERLAY7 = $00000080;
  WGL_SWAP_OVERLAY8 = $00000100;
  WGL_SWAP_OVERLAY9 = $00000200;
  WGL_SWAP_OVERLAY10 = $00000400;
  WGL_SWAP_OVERLAY11 = $00000800;
  WGL_SWAP_OVERLAY12 = $00001000;
  WGL_SWAP_OVERLAY13 = $00002000;
  WGL_SWAP_OVERLAY14 = $00004000;
  WGL_SWAP_OVERLAY15 = $00008000;
  WGL_SWAP_UNDERLAY1 = $00010000;
  WGL_SWAP_UNDERLAY2 = $00020000;
  WGL_SWAP_UNDERLAY3 = $00040000;
  WGL_SWAP_UNDERLAY4 = $00080000;
  WGL_SWAP_UNDERLAY5 = $00100000;
  WGL_SWAP_UNDERLAY6 = $00200000;
  WGL_SWAP_UNDERLAY7 = $00400000;
  WGL_SWAP_UNDERLAY8 = $00800000;
  WGL_SWAP_UNDERLAY9 = $01000000;
  WGL_SWAP_UNDERLAY10 = $02000000;
  WGL_SWAP_UNDERLAY11 = $04000000;
  WGL_SWAP_UNDERLAY12 = $08000000;
  WGL_SWAP_UNDERLAY13 = $10000000;
  WGL_SWAP_UNDERLAY14 = $20000000;
  WGL_SWAP_UNDERLAY15 = $40000000;

function wglDescribeLayerPlane(p1: HDC; p2, p3: Integer; p4: Cardinal;
  var p5: TLayerPlaneDescriptor): BOOL; stdcall;
function wglSetLayerPaletteEntries(p1: HDC; p2, p3, p4: Integer;
  var pcr): Integer; stdcall;
function wglGetLayerPaletteEntries(p1: HDC; p2, p3, p4: Integer;
  var pcr): Integer; stdcall;
function wglRealizeLayerPalette(p1: HDC; p2: Integer; p3: BOOL): BOOL; stdcall;
function wglSwapLayerBuffers(p1: HDC; p2: Cardinal): BOOL; stdcall;

type
  PWGLSwap = ^TWGLSwap;
  _WGLSWAP = packed record
    hdc: HDC;
    uiFlags: UINT;
  end;
  TWGLSwap = _WGLSWAP;
  WGLSWAP = _WGLSWAP;

const
  WGL_SWAPMULTIPLE_MAX = 16;

function wglSwapMultipleBuffers(p1: UINT; const p2: PWGLSwap): DWORD; stdcall;

{ Translated from WINUSER.H }

type
  HDWP = THandle;
  PMENUTEMPLATE = Pointer;
  va_list = PTChar;
  TFNWndProc = TFarProc;
  TFNDlgProc = TFarProc;
  TFNTimerProc = TFarProc;
  TFNGrayStringProc = TFarProc;
  TFNWndEnumProc = TFarProc;
  TFNSendAsyncProc = TFarProc;
  TFNDrawStateProc = TFarProc;


  TFNHookProc = function (code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT stdcall;

type
  TFNPropEnumProc = TFarProc;
  TFNPropEnumProcEx = TFarProc;
  TFNEditWordBreakProc = TFarProc;
  TFNNameEnumProc = TFarProc;

  TFNWinStaEnumProc = TFNNameEnumProc;
  TFNDeskTopEnumProc = TFNNameEnumProc;

  MakeIntResourceA = PAnsiChar;
  MakeIntResourceW = PWideChar;
  MakeIntResource = {$ifdef bUnicode}MakeIntResourceW{$else}MakeIntResourceA{$endif bUnicode};

const
  { Predefined Resource Types }
  RT_CURSOR       = MakeIntResource(1);
  RT_BITMAP       = MakeIntResource(2);
  RT_ICON         = MakeIntResource(3);
  RT_MENU         = MakeIntResource(4);
  RT_DIALOG       = MakeIntResource(5);
  RT_STRING       = MakeIntResource(6);
  RT_FONTDIR      = MakeIntResource(7);
  RT_FONT         = MakeIntResource(8);
  RT_ACCELERATOR  = MakeIntResource(9);
  RT_RCDATA       = MakeIntResource(10);
  RT_MESSAGETABLE = MakeIntResource(11);

  DIFFERENCE = 11;

  RT_GROUP_CURSOR = MakeIntResource(DWORD(RT_CURSOR + DIFFERENCE));
  RT_GROUP_ICON   = MakeIntResource(DWORD(RT_ICON + DIFFERENCE));
  RT_VERSION      = MakeIntResource(16);
  RT_DLGINCLUDE   = MakeIntResource(17);
  RT_PLUGPLAY     = MakeIntResource(19);
  RT_VXD          = MakeIntResource(20);
  RT_ANICURSOR    = MakeIntResource(21);
  RT_ANIICON      = MakeIntResource(22);

function wvsprintfA(Output: PAnsiChar; Format: PAnsiChar; arglist: va_list): Integer; stdcall;
function wvsprintfW(Output: PWideChar; Format: PWideChar; arglist: va_list): Integer; stdcall;
function wvsprintf(Output: PTChar; Format: PTChar; arglist: va_list): Integer; stdcall;
function wsprintfA(Output: PAnsiChar; Format: PAnsiChar): Integer; stdcall;
function wsprintfW(Output: PWideChar; Format: PWideChar): Integer; stdcall;
function wsprintf(Output: PTChar; Format: PTChar): Integer; stdcall;

const
  { Scroll Bar Constants }
  SB_HORZ = 0;
  SB_VERT = 1;
  SB_CTL = 2;
  SB_BOTH = 3;

  { Scroll Bar Commands }
  SB_LINEUP = 0;
  SB_LINELEFT = 0;
  SB_LINEDOWN = 1;
  SB_LINERIGHT = 1;
  SB_PAGEUP = 2;
  SB_PAGELEFT = 2;
  SB_PAGEDOWN = 3;
  SB_PAGERIGHT = 3;
  SB_THUMBPOSITION = 4;
  SB_THUMBTRACK = 5;
  SB_TOP = 6;
  SB_LEFT = 6;
  SB_BOTTOM = 7;
  SB_RIGHT = 7;
  SB_ENDSCROLL = 8;

  { ShowWindow() Commands }
  SW_HIDE = 0;
  SW_SHOWNORMAL = 1;
  SW_NORMAL = 1;
  SW_SHOWMINIMIZED = 2;
  SW_SHOWMAXIMIZED = 3;
  SW_MAXIMIZE = 3;
  SW_SHOWNOACTIVATE = 4;
  SW_SHOW = 5;
  SW_MINIMIZE = 6;
  SW_SHOWMINNOACTIVE = 7;
  SW_SHOWNA = 8;
  SW_RESTORE = 9;
  SW_SHOWDEFAULT = 10;
  SW_MAX = 10;

  { Old ShowWindow() Commands }
  HIDE_WINDOW = 0;
  SHOW_OPENWINDOW = 1;
  SHOW_ICONWINDOW = 2;
  SHOW_FULLSCREEN = 3;
  SHOW_OPENNOACTIVATE = 4;

  { Identifiers for the WM_SHOWWINDOW message }
  SW_PARENTCLOSING = 1;
  SW_OTHERZOOM = 2;
  SW_PARENTOPENING = 3;
  SW_OTHERUNZOOM = 4;

  AW_HOR_POSITIVE = $00000001;
  AW_HOR_NEGATIVE = $00000002;
  AW_VER_POSITIVE = $00000004;
  AW_VER_NEGATIVE = $00000008;
  AW_CENTER = $00000010;
  AW_HIDE = $00010000;
  AW_ACTIVATE = $00020000;
  AW_SLIDE = $00040000;
  AW_BLEND = $00080000;

  { WM_KEYUPDOWNCHAR HiWord(lParam) flags }
  KF_EXTENDED = $100;
  KF_DLGMODE = $800;
  KF_MENUMODE = $1000;
  KF_ALTDOWN = $2000;
  KF_REPEAT = $4000;
  KF_UP = $8000;

  { Virtual Keys, Standard Set }
  VK_LBUTTON = 1;
  VK_RBUTTON = 2;
  VK_CANCEL = 3;
  VK_MBUTTON = 4;  { NOT contiguous with L & RBUTTON }
  VK_BACK = 8;
  VK_TAB = 9;
  VK_CLEAR = 12;
  VK_RETURN = 13;
  VK_SHIFT = $10;
  VK_CONTROL = 17;
  VK_MENU = 18;
  VK_PAUSE = 19;
  VK_CAPITAL = 20;
  VK_KANA = 21;
  VK_HANGUL = 21;
  VK_JUNJA = 23;
  VK_FINAL = 24;
  VK_HANJA = 25;
  VK_KANJI = 25;
  VK_CONVERT = 28;
  VK_NONCONVERT = 29;
  VK_ACCEPT = 30;
  VK_MODECHANGE = 31;
  VK_ESCAPE = 27;
  VK_SPACE = $20;
  VK_PRIOR = 33;
  VK_NEXT = 34;
  VK_END = 35;
  VK_HOME = 36;
  VK_LEFT = 37;
  VK_UP = 38;
  VK_RIGHT = 39;
  VK_DOWN = 40;
  VK_SELECT = 41;
  VK_PRINT = 42;
  VK_EXECUTE = 43;
  VK_SNAPSHOT = 44;
  VK_INSERT = 45;
  VK_DELETE = 46;
  VK_HELP = 47;
{ VK_0 thru VK_9 are the same as ASCII '0' thru '9' ($30 - $39) }
{ VK_A thru VK_Z are the same as ASCII 'A' thru 'Z' ($41 - $5A) }
  VK_LWIN = 91;
  VK_RWIN = 92;
  VK_APPS = 93;
  VK_NUMPAD0 = 96;
  VK_NUMPAD1 = 97;
  VK_NUMPAD2 = 98;
  VK_NUMPAD3 = 99;
  VK_NUMPAD4 = 100;
  VK_NUMPAD5 = 101;
  VK_NUMPAD6 = 102;
  VK_NUMPAD7 = 103;
  VK_NUMPAD8 = 104;
  VK_NUMPAD9 = 105;
  VK_MULTIPLY = 106;
  VK_ADD = 107;
  VK_SEPARATOR = 108;
  VK_SUBTRACT = 109;
  VK_DECIMAL = 110;
  VK_DIVIDE = 111;
  VK_F1 = 112;
  VK_F2 = 113;
  VK_F3 = 114;
  VK_F4 = 115;
  VK_F5 = 116;
  VK_F6 = 117;
  VK_F7 = 118;
  VK_F8 = 119;
  VK_F9 = 120;
  VK_F10 = 121;
  VK_F11 = 122;
  VK_F12 = 123;
  VK_F13 = 124;
  VK_F14 = 125;
  VK_F15 = 126;
  VK_F16 = 127;
  VK_F17 = 128;
  VK_F18 = 129;
  VK_F19 = 130;
  VK_F20 = 131;
  VK_F21 = 132;
  VK_F22 = 133;
  VK_F23 = 134;
  VK_F24 = 135;
  VK_NUMLOCK = 144;
  VK_SCROLL = 145;
{ VK_L & VK_R - left and right Alt, Ctrl and Shift virtual keys.
  Used only as parameters to GetAsyncKeyState() and GetKeyState().
  No other API or message will distinguish left and right keys in this way. }
  VK_LSHIFT = 160;
  VK_RSHIFT = 161;
  VK_LCONTROL = 162;
  VK_RCONTROL = 163;
  VK_LMENU = 164;
  VK_RMENU = 165;
  VK_PROCESSKEY = 229;
  VK_ATTN = 246;
  VK_CRSEL = 247;
  VK_EXSEL = 248;
  VK_EREOF = 249;
  VK_PLAY = 250;
  VK_ZOOM = 251;
  VK_NONAME = 252;
  VK_PA1 = 253;
  VK_OEM_CLEAR = 254;


  { SetWindowsHook() codes }
  WH_MIN = -1;
  WH_MSGFILTER = -1;
  WH_JOURNALRECORD = 0;
  WH_JOURNALPLAYBACK = 1;
  WH_KEYBOARD = 2;
  WH_GETMESSAGE = 3;
  WH_CALLWNDPROC = 4;
  WH_CBT = 5;
  WH_SYSMSGFILTER = 6;
  WH_MOUSE = 7;
  WH_HARDWARE = 8;
  WH_DEBUG = 9;
  WH_SHELL = 10;
  WH_FOREGROUNDIDLE = 11;
  WH_CALLWNDPROCRET = 12;
  WH_MAX = 12;
  WH_MINHOOK = WH_MIN;
  WH_MAXHOOK = WH_MAX;

  { Hook Codes }
  HC_ACTION = 0;
  HC_GETNEXT = 1;
  HC_SKIP = 2;
  HC_NOREMOVE = 3;
  HC_NOREM = HC_NOREMOVE;
  HC_SYSMODALON = 4;
  HC_SYSMODALOFF = 5;

  { CBT Hook Codes }
  HCBT_MOVESIZE = 0;
  HCBT_MINMAX = 1;
  HCBT_QS = 2;
  HCBT_CREATEWND = 3;
  HCBT_DESTROYWND = 4;
  HCBT_ACTIVATE = 5;
  HCBT_CLICKSKIPPED = 6;
  HCBT_KEYSKIPPED = 7;
  HCBT_SYSCOMMAND = 8;
  HCBT_SETFOCUS = 9;


type
  PCreateStructA = ^TCreateStructA;
  PCreateStructW = ^TCreateStructW;
  PCreateStruct = {$ifdef bUnicode}PCreateStructW{$else}PCreateStructA{$endif bUnicode};

  tagCREATESTRUCTA = record
    lpCreateParams: Pointer;
    hInstance: HINST;
    hMenu: HMENU;
    hwndParent: HWND;
    cy: Integer;
    cx: Integer;
    y: Integer;
    x: Integer;
    style: Longint;
    lpszName: PAnsiChar;
    lpszClass: PAnsiChar;
    dwExStyle: DWORD;
  end;
  tagCREATESTRUCTW = record
    lpCreateParams: Pointer;
    hInstance: HINST;
    hMenu: HMENU;
    hwndParent: HWND;
    cy: Integer;
    cx: Integer;
    y: Integer;
    x: Integer;
    style: Longint;
    lpszName: PWideChar;
    lpszClass: PWideChar;
    dwExStyle: DWORD;
  end;
  tagCREATESTRUCT = {$ifdef bUnicode}tagCREATESTRUCTW{$else}tagCREATESTRUCTA{$endif bUnicode};

  TCreateStructA = tagCREATESTRUCTA;
  TCreateStructW = tagCREATESTRUCTW;
  TCreateStruct = {$ifdef bUnicode}TCreateStructW{$else}TCreateStructA{$endif bUnicode};

  CREATESTRUCTA = tagCREATESTRUCTA;
  CREATESTRUCTW = tagCREATESTRUCTW;
  CREATESTRUCT = {$ifdef bUnicode}CREATESTRUCTW{$else}CREATESTRUCTA{$endif bUnicode};

  { HCBT_CREATEWND parameters pointed to by lParam }
  PCBTCreateWnd = ^TCBTCreateWnd;
  tagCBT_CREATEWNDA = packed record
    lpcs: PCreateStruct;
    hwndInsertAfter: HWND;
  end;
  TCBTCreateWnd = tagCBT_CREATEWNDA;
  CBT_CREATEWND = tagCBT_CREATEWNDA;

  { HCBT_ACTIVATE structure pointed to by lParam }
  PCBTActivateStruct = ^TCBTActivateStruct;
  tagCBTACTIVATESTRUCT = packed record
    fMouse: BOOL;
    hWndActive: HWND;
  end;
  TCBTActivateStruct = tagCBTACTIVATESTRUCT;
  CBTACTIVATESTRUCT = tagCBTACTIVATESTRUCT;

const
  { WH_MSGFILTER Filter Proc Codes }
  MSGF_DIALOGBOX = 0;
  MSGF_MESSAGEBOX = 1;
  MSGF_MENU = 2;
  MSGF_MOVE = 3;
  MSGF_SIZE = 4;
  MSGF_SCROLLBAR = 5;
  MSGF_NEXTWINDOW = 6;
  MSGF_MAINLOOP = 8;
  MSGF_MAX = 8;
  MSGF_USER = $1000;

  { Shell support }
  HSHELL_WINDOWCREATED = 1;
  HSHELL_WINDOWDESTROYED = 2;
  HSHELL_ACTIVATESHELLWINDOW = 3;
  HSHELL_WINDOWACTIVATED = 4;
  HSHELL_GETMINRECT = 5;
  HSHELL_REDRAW = 6;
  HSHELL_TASKMAN = 7;
  HSHELL_LANGUAGE = 8;
  HSHELL_ACCESSIBILITYSTATE = 11;
  ACCESS_STICKYKEYS = $0001;
  ACCESS_FILTERKEYS = $0002;
  ACCESS_MOUSEKEYS = $0003;


type
  { Message Structure used in Journaling }
  PEventMsg = ^TEventMsg;
  tagEVENTMSG = packed record
    message: UINT;
    paramL: UINT;
    paramH: UINT;
    time: DWORD;
    hwnd: HWND;
  end;
  TEventMsg = tagEVENTMSG;
  EVENTMSG = tagEVENTMSG;

  { Message structure used by WH_CALLWNDPROC }
  PCWPStruct = ^TCWPStruct;
  tagCWPSTRUCT = packed record
    lParam: LPARAM;
    wParam: WPARAM;
    message: UINT;
    hwnd: HWND;
  end;
  TCWPStruct = tagCWPSTRUCT;
  CWPSTRUCT = tagCWPSTRUCT;

  { Message structure used by WH_CALLWNDPROCRET }
  PCWPRetStruct = ^TCWPRetStruct;
  tagCWPRETSTRUCT = packed record
    lResult: LRESULT;
    lParam: LPARAM;
    wParam: WPARAM;
    message: UINT;
    hwnd: HWND;
  end;
  TCWPRetStruct = tagCWPRETSTRUCT;
  CWPRETSTRUCT = tagCWPRETSTRUCT;

  { Structure used by WH_DEBUG }
  PDebugHookInfo = ^TDebugHookInfo;
  tagDEBUGHOOKINFO = packed record
    idThread: DWORD;
    idThreadInstaller: DWORD;
    lParam: LPARAM;
    wParam: WPARAM;
    code: Integer;
  end;
  TDebugHookInfo = tagDEBUGHOOKINFO;
  DEBUGHOOKINFO = tagDEBUGHOOKINFO;

  { Structure used by WH_MOUSE }
  PMouseHookStruct = ^TMouseHookStruct;
  tagMOUSEHOOKSTRUCT = packed record
    pt: TPoint;
    hwnd: HWND;
    wHitTestCode: UINT;
    dwExtraInfo: DWORD;
  end;
  TMouseHookStruct = tagMOUSEHOOKSTRUCT;
  MOUSEHOOKSTRUCT = tagMOUSEHOOKSTRUCT;

  { Structure used by WH_HARDWARE }
  PHardwareHookStruct = ^THardwareHookStruct;
  tagHARDWAREHOOKSTRUCT = packed record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
  end;
  THardwareHookStruct = tagHARDWAREHOOKSTRUCT;
  HARDWAREHOOKSTRUCT = tagHARDWAREHOOKSTRUCT;

const
  { Keyboard Layout API }
  HKL_PREV = 0;
  HKL_NEXT = 1;

  KLF_ACTIVATE = 1;
  KLF_SUBSTITUTE_OK = 2;
  KLF_UNLOADPREVIOUS = 4;
  KLF_REORDER = 8;
  KLF_REPLACELANG = $10;
  KLF_NOTELLSHELL = 128;

  { Size of KeyboardLayoutName (number of characters), including nul terminator }
  KL_NAMELENGTH = 9;


function LoadKeyboardLayoutA(pwszKLID: PAnsiChar; Flags: UINT): HKL; stdcall;
function LoadKeyboardLayoutW(pwszKLID: PWideChar; Flags: UINT): HKL; stdcall;
function LoadKeyboardLayout(pwszKLID: PTChar; Flags: UINT): HKL; stdcall;
function ActivateKeyboardLayout(hkl: HKL; Flags: UINT): HKL; stdcall;
function UnloadKeyboardLayout(hkl: HKL): BOOL; stdcall;
function ToUnicodeEx(wVirtKey, wScanCode: UINT; lpKeyState: PByte;
  pwszBuff: PWideChar; cchBuff: Integer; wFlags: UINT; dwhkl: HKL): Integer; stdcall;
function GetKeyboardLayoutNameA(pwszKLID: PAnsiChar): BOOL; stdcall;
function GetKeyboardLayoutNameW(pwszKLID: PWideChar): BOOL; stdcall;
function GetKeyboardLayoutName(pwszKLID: PTChar): BOOL; stdcall;
function GetKeyboardLayoutList(nBuff: Integer; var List): UINT; stdcall;
function GetKeyboardLayout(dwLayout: DWORD): HKL; stdcall;

type
  PMouseMovePoint = ^TMouseMovePoint;
  tagMOUSEMOVEPOINT = packed record
    x: Integer;
    y: Integer;
    time: DWORD;
    dwExtraInfo: DWORD;
  end;
  TMouseMovePoint = tagMOUSEMOVEPOINT;
  MOUSEMOVEPOINT = tagMOUSEMOVEPOINT;

const
  { Values for resolution parameter of GetMouseMovePoints }
  GMMP_USE_DISPLAY_POINTS = 1;
  GMMP_USE_DRIVER_POINTS = 2;

function GetMouseMovePoints(cbSize: UINT; var lppt, lpptBuf: TMouseMovePoint; nBufPoints: Integer;
  resolution: DWORD): Integer; stdcall;


const
  { Desktop-specific access flags }
  DESKTOP_READOBJECTS = 1;
  DESKTOP_CREATEWINDOW = 2;
  DESKTOP_CREATEMENU = 4;
  DESKTOP_HOOKCONTROL = 8;
  DESKTOP_JOURNALRECORD = $10;
  DESKTOP_JOURNALPLAYBACK = $20;
  DESKTOP_ENUMERATE = $40;
  DESKTOP_WRITEOBJECTS = 128;
  DESKTOP_SWITCHDESKTOP = $100;

  { Desktop-specific control flags }
  DF_ALLOWOTHERACCOUNTHOOK = 1;


function CreateDesktopA(lpszDesktop, lpszDevice: PAnsiChar;
  pDevmode: PDeviceModeA; dwFlags: DWORD; dwDesiredAccess:
  DWORD; lpsa: PSecurityAttributes): HDESK; stdcall;
function CreateDesktopW(lpszDesktop, lpszDevice: PWideChar;
  pDevmode: PDeviceModeW; dwFlags: DWORD; dwDesiredAccess:
  DWORD; lpsa: PSecurityAttributes): HDESK; stdcall;
function CreateDesktop(lpszDesktop, lpszDevice: PTChar;
  pDevmode: PDeviceMode; dwFlags: DWORD; dwDesiredAccess:
  DWORD; lpsa: PSecurityAttributes): HDESK; stdcall;
function OpenDesktopA(lpszDesktop: PAnsiChar; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: DWORD): HDESK; stdcall;
function OpenDesktopW(lpszDesktop: PWideChar; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: DWORD): HDESK; stdcall;
function OpenDesktop(lpszDesktop: PTChar; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: DWORD): HDESK; stdcall;
function EnumDesktopsA(hwinsta: HWINSTA; lpEnumFunc: TFNDeskTopEnumProc; lParam: LPARAM): BOOL; stdcall;
function EnumDesktopsW(hwinsta: HWINSTA; lpEnumFunc: TFNDeskTopEnumProc; lParam: LPARAM): BOOL; stdcall;
function EnumDesktops(hwinsta: HWINSTA; lpEnumFunc: TFNDeskTopEnumProc; lParam: LPARAM): BOOL; stdcall;
function OpenInputDesktop(dwFlags: DWORD; fInherit: BOOL; dwDesiredAccess: DWORD): HDESK; stdcall;
function EnumDesktopWindows(hDesktop: HDESK; lpfn: TFNWndEnumProc; lParam: LPARAM): BOOL; stdcall;
function SwitchDesktop(hDesktop: HDESK): BOOL; stdcall;
function SetThreadDesktop(hDesktop: HDESK): BOOL; stdcall;
function CloseDesktop(hDesktop: HDESK): BOOL; stdcall;
function GetThreadDesktop(dwThreadId: DWORD): HDESK; stdcall;

const
  { Windowstation-specific access flags }
  WINSTA_ENUMDESKTOPS = 1;
  WINSTA_READATTRIBUTES = 2;
  WINSTA_ACCESSCLIPBOARD = 4;
  WINSTA_CREATEDESKTOP = 8;
  WINSTA_WRITEATTRIBUTES = $10;
  WINSTA_ACCESSGLOBALATOMS = $20;
  WINSTA_EXITWINDOWS = $40;
  WINSTA_ENUMERATE = $100;
  WINSTA_READSCREEN = $200;

  { Windowstation-specific attribute flags }
  WSF_VISIBLE = 1;

function CreateWindowStationA(lpwinsta: PAnsiChar; dwReserved, dwDesiredAccess: DWORD;
  lpsa: PSecurityAttributes): HWINSTA; stdcall;
function CreateWindowStationW(lpwinsta: PWideChar; dwReserved, dwDesiredAccess: DWORD;
  lpsa: PSecurityAttributes): HWINSTA; stdcall;
function CreateWindowStation(lpwinsta: PTChar; dwReserved, dwDesiredAccess: DWORD;
  lpsa: PSecurityAttributes): HWINSTA; stdcall;
function OpenWindowStationA(lpszWinSta: PAnsiChar; fInherit: BOOL;
  dwDesiredAccess: DWORD): HWINSTA; stdcall;
function OpenWindowStationW(lpszWinSta: PWideChar; fInherit: BOOL;
  dwDesiredAccess: DWORD): HWINSTA; stdcall;
function OpenWindowStation(lpszWinSta: PTChar; fInherit: BOOL;
  dwDesiredAccess: DWORD): HWINSTA; stdcall;
function EnumWindowStationsA(lpEnumFunc: TFNWinStaEnumProc; lParam: LPARAM): BOOL; stdcall;
function EnumWindowStationsW(lpEnumFunc: TFNWinStaEnumProc; lParam: LPARAM): BOOL; stdcall;
function EnumWindowStations(lpEnumFunc: TFNWinStaEnumProc; lParam: LPARAM): BOOL; stdcall;
function CloseWindowStation(hWinSta: HWINSTA): BOOL; stdcall;
function SetProcessWindowStation(hWinSta: HWINSTA): BOOL; stdcall;
function GetProcessWindowStation: HWINSTA; stdcall;
function SetUserObjectSecurity(hObj: THandle; var pSIRequested: DWORD;
  pSID: PSecurityDescriptor): BOOL; stdcall;
function GetUserObjectSecurity(hObj: THandle; var pSIRequested: DWORD;
  pSID: PSecurityDescriptor; nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;

const
  UOI_FLAGS = 1;
  UOI_NAME = 2;
  UOI_TYPE = 3;
  UOI_USER_SID = 4;

type
  PUserObjectFlags = ^TUserObjectFlags;
  tagUSEROBJECTFLAGS = packed record
    fInherit: BOOL;
    fReserved: BOOL;
    dwFlags: DWORD;
  end;
  TUserObjectFlags = tagUSEROBJECTFLAGS;
  USEROBJECTFLAGS = tagUSEROBJECTFLAGS;

function GetUserObjectInformationA(hObj: THandle; nIndex: Integer; pvInfo: Pointer;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function GetUserObjectInformationW(hObj: THandle; nIndex: Integer; pvInfo: Pointer;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function GetUserObjectInformation(hObj: THandle; nIndex: Integer; pvInfo: Pointer;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function SetUserObjectInformationA(hObj: THandle; nIndex: Integer;
  pvInfo: Pointer; nLength: DWORD): BOOL; stdcall;
function SetUserObjectInformationW(hObj: THandle; nIndex: Integer;
  pvInfo: Pointer; nLength: DWORD): BOOL; stdcall;
function SetUserObjectInformation(hObj: THandle; nIndex: Integer;
  pvInfo: Pointer; nLength: DWORD): BOOL; stdcall;

type
  PWndClassExA = ^TWndClassExA;
  PWndClassExW = ^TWndClassExW;
  PWndClassEx = {$ifdef bUnicode}PWndClassExW{$else}PWndClassExA{$endif bUnicode};

  tagWNDCLASSEXA = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
    hIconSm: HICON;
  end;
  tagWNDCLASSEXW = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
    hIconSm: HICON;
  end;
  tagWNDCLASSEX = {$ifdef bUnicode}tagWNDCLASSEXW{$else}tagWNDCLASSEXA{$endif bUnicode};

  TWndClassExA = tagWNDCLASSEXA;
  TWndClassExW = tagWNDCLASSEXW;
  TWndClassEx = {$ifdef bUnicode}TWndClassExW{$else}TWndClassExA{$endif bUnicode};

  WNDCLASSEXA = tagWNDCLASSEXA;
  WNDCLASSEXW = tagWNDCLASSEXW;
  WNDCLASSEX = {$ifdef bUnicode}WNDCLASSEXW{$else}WNDCLASSEXA{$endif bUnicode};

  PWndClassA = ^TWndClassA;
  PWndClassW = ^TWndClassW;
  PWndClass = {$ifdef bUnicode}PWndClassW{$else}PWndClassA{$endif bUnicode};

  tagWNDCLASSA = record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
  end;
  tagWNDCLASSW = record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
  end;
  tagWNDCLASS = {$ifdef bUnicode}tagWNDCLASSW{$else}tagWNDCLASSA{$endif bUnicode};

  TWndClassA = tagWNDCLASSA;
  TWndClassW = tagWNDCLASSW;
  TWndClass = {$ifdef bUnicode}TWndClassW{$else}TWndClassA{$endif bUnicode};

  WNDCLASSA = tagWNDCLASSA;
  WNDCLASSW = tagWNDCLASSW;
  WNDCLASS = {$ifdef bUnicode}WNDCLASSW{$else}WNDCLASSA{$endif bUnicode};

{ Message structure }
  PMsg = ^TMsg;
  tagMSG = record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
    time: DWORD;
    pt: TPoint;
  end;
  TMsg = tagMSG;
  MSG = tagMSG;

function SmallPointToPoint(const P: TSmallPoint): TPoint;
function PointToSmallPoint(const P: TPoint): TSmallPoint;
function MakeWParam(l, h: Word): WPARAM;
function MakeLParam(l, h: Word): LPARAM;
function MakeLResult(l, h: Word): LRESULT;


const
{ Window field offsets for GetWindowLong() }

  GWL_WNDPROC = -4;
  GWL_HINSTANCE = -6;
  GWL_HWNDPARENT = -8;
  GWL_STYLE = -16;
  GWL_EXSTYLE = -20;
  GWL_USERDATA = -21;
  GWL_ID = -12;

  { Class field offsets for GetClassLong() }
  GCL_MENUNAME = -8;
  GCL_HBRBACKGROUND = -10;
  GCL_HCURSOR = -12;
  GCL_HICON = -14;
  GCL_HMODULE = -16;
  GCL_CBWNDEXTRA = -18;
  GCL_CBCLSEXTRA = -20;
  GCL_WNDPROC = -24;
  GCL_STYLE = -26;
  GCW_ATOM = -32;
  GCL_HICONSM = -34;

const
  { WM_ACTIVATE state values }
  WA_INACTIVE = 0;
  WA_ACTIVE = 1;
  WA_CLICKACTIVE = 2;

type
  { Struct pointed to by WM_GETMINMAXINFO lParam }
  PMinMaxInfo = ^TMinMaxInfo;
  tagMINMAXINFO = packed record
    ptReserved: TPoint;
    ptMaxSize: TPoint;
    ptMaxPosition: TPoint;
    ptMinTrackSize: TPoint;
    ptMaxTrackSize: TPoint;
  end;
  TMinMaxInfo = tagMINMAXINFO;
  MINMAXINFO = tagMINMAXINFO;

const
  { wParam for WM_POWER window message and DRV_POWER driver notification }
  PWR_OK = 1;
  PWR_FAIL = -1;
  PWR_SUSPENDREQUEST = 1;
  PWR_SUSPENDRESUME = 2;
  PWR_CRITICALRESUME = 3;

type
  { lParam of WM_COPYDATA message points to... }
  PCopyDataStruct = ^TCopyDataStruct;
  tagCOPYDATASTRUCT = packed record
    dwData: DWORD;
    cbData: DWORD;
    lpData: Pointer;
  end;
  TCopyDataStruct = tagCOPYDATASTRUCT;
  COPYDATASTRUCT = tagCOPYDATASTRUCT;

const
  NFR_ANSI = 1;
  NFR_UNICODE = 2;
  NF_QUERY = 3;
  NF_REQUERY = 4;

  WHEEL_DELTA = 120;            { Value for rolling one detent }
  WHEEL_PAGESCROLL = MAXDWORD;  { Scroll one page }

  MENULOOP_WINDOW = 0;
  MENULOOP_POPUP = 1;

type
  PMDINextMenu = ^TMDINextMenu;
  tagMDINEXTMENU = packed record
    hmenuIn: HMENU;
    hmenuNext: HMENU;
    hwndNext: HWND;
  end;
  TMDINextMenu = tagMDINEXTMENU;
  MDINEXTMENU = tagMDINEXTMENU;

const
  { LOWORD(wParam) values in WM_*UISTATE* }
  UIS_SET = 1;
  UIS_CLEAR = 2;
  UIS_INITIALIZE = 3;

  { HIWORD(wParam) values in WM_*UISTATE* }
  UISF_HIDEFOCUS = $1;
  UISF_HIDEACCEL = $2;


const
  { wParam for WM_NOTIFYWOW message  }

  { wParam for WM_SIZING message  }
  WMSZ_LEFT = 1;
  WMSZ_RIGHT = 2;
  WMSZ_TOP = 3;
  WMSZ_TOPLEFT = 4;
  WMSZ_TOPRIGHT = 5;
  WMSZ_BOTTOM = 6;
  WMSZ_BOTTOMLEFT = 7;
  WMSZ_BOTTOMRIGHT = 8;

  { WM_SYNCTASK Commands }
  ST_BEGINSWP = 0;
  ST_ENDSWP = 1;

  { WM_NCHITTEST and MOUSEHOOKSTRUCT Mouse Position Codes }
  HTERROR = -2;
  HTTRANSPARENT = -1;
  HTNOWHERE = 0;
  HTCLIENT = 1;
  HTCAPTION = 2;
  HTSYSMENU = 3;
  HTGROWBOX = 4;
  HTSIZE = HTGROWBOX;
  HTMENU = 5;
  HTHSCROLL = 6;
  HTVSCROLL = 7;
  HTMINBUTTON = 8;
  HTMAXBUTTON = 9;
  HTLEFT = 10;
  HTRIGHT = 11;
  HTTOP = 12;
  HTTOPLEFT = 13;
  HTTOPRIGHT = 14;
  HTBOTTOM = 15;
  HTBOTTOMLEFT = $10;
  HTBOTTOMRIGHT = 17;
  HTBORDER = 18;
  HTREDUCE = HTMINBUTTON;
  HTZOOM = HTMAXBUTTON;
  HTSIZEFIRST = HTLEFT;
  HTSIZELAST = HTBOTTOMRIGHT;
  HTOBJECT = 19;
  HTCLOSE = 20;
  HTHELP = 21;

  { SendMessageTimeout values }
  SMTO_NORMAL = 0;
  SMTO_BLOCK = 1;
  SMTO_ABORTIFHUNG = 2;
  SMTO_NOTIMEOUTIFNOTHUNG = 8;

  { WM_MOUSEACTIVATE Return Codes }
  MA_ACTIVATE = 1;
  MA_ACTIVATEANDEAT = 2;
  MA_NOACTIVATE = 3;
  MA_NOACTIVATEANDEAT = 4;

  { WM_SETICON / WM_GETICON Type Codes }
  ICON_SMALL = 0;
  ICON_BIG = 1;

function RegisterWindowMessageA(lpString: PAnsiChar): UINT; stdcall;
function RegisterWindowMessageW(lpString: PWideChar): UINT; stdcall;
function RegisterWindowMessage(lpString: PTChar): UINT; stdcall;

const
  { WM_SIZE message wParam values }
  SIZE_RESTORED = 0;
  SIZE_MINIMIZED = 1;
  SIZE_MAXIMIZED = 2;
  SIZE_MAXSHOW = 3;
  SIZE_MAXHIDE = 4;

  { Obsolete constant names }
  SIZENORMAL = SIZE_RESTORED;
  SIZEICONIC = SIZE_MINIMIZED;
  SIZEFULLSCREEN = SIZE_MAXIMIZED;
  SIZEZOOMSHOW = SIZE_MAXSHOW;
  SIZEZOOMHIDE = SIZE_MAXHIDE;


type
  { WM_WINDOWPOSCHANGINGCHANGED struct pointed to by lParam }
  PWindowPos = ^TWindowPos;
  tagWINDOWPOS = packed record
    hwnd: HWND;
    hwndInsertAfter: HWND;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    flags: UINT;
  end;
  TWindowPos = tagWINDOWPOS;
  WINDOWPOS = tagWINDOWPOS;

  { WM_NCCALCSIZE parameter structure }
  PNCCalcSizeParams = ^TNCCalcSizeParams;
  tagNCCALCSIZE_PARAMS = packed record
    rgrc: array[0..2] of TRect;
    lppos: PWindowPos;
  end;
  TNCCalcSizeParams = tagNCCALCSIZE_PARAMS;
  NCCALCSIZE_PARAMS = tagNCCALCSIZE_PARAMS;


const
  { WM_NCCALCSIZE "window valid rect" return values }
  WVR_ALIGNTOP = $10;
  WVR_ALIGNLEFT = $20;
  WVR_ALIGNBOTTOM = $40;
  WVR_ALIGNRIGHT = $80;
  WVR_HREDRAW = $100;
  WVR_VREDRAW = $200;
  WVR_REDRAW = (WVR_HREDRAW or WVR_VREDRAW);
  WVR_VALIDRECTS = $400;

  { Key State Masks for Mouse Messages }
  MK_LBUTTON = 1;
  MK_RBUTTON = 2;
  MK_SHIFT = 4;
  MK_CONTROL = 8;
  MK_MBUTTON = $10;

  TME_HOVER           = $00000001;
  TME_LEAVE           = $00000002;
  TME_QUERY           = $40000000;
  TME_CANCEL          = DWORD($80000000);

  HOVER_DEFAULT       = DWORD($FFFFFFFF);

type
  PTrackMouseEvent = ^TTrackMouseEvent;
  tagTRACKMOUSEEVENT = record
    cbSize: DWORD;
    dwFlags: DWORD;
    hwndTrack: HWND;
    dwHoverTime: DWORD;
  end;
  TTrackMouseEvent = tagTRACKMOUSEEVENT;

function TrackMouseEvent(var EventTrack: TTrackMouseEvent): BOOL; stdcall;

const
  { Window Styles }
  WS_OVERLAPPED = 0;
  WS_POPUP = DWORD($80000000);
  WS_CHILD = $40000000;
  WS_MINIMIZE = $20000000;
  WS_VISIBLE = $10000000;
  WS_DISABLED = $8000000;
  WS_CLIPSIBLINGS = $4000000;
  WS_CLIPCHILDREN = $2000000;
  WS_MAXIMIZE = $1000000;
  WS_CAPTION = $C00000;      { WS_BORDER or WS_DLGFRAME  }
  WS_BORDER = $800000;
  WS_DLGFRAME = $400000;
  WS_VSCROLL = $200000;
  WS_HSCROLL = $100000;
  WS_SYSMENU = $80000;
  WS_THICKFRAME = $40000;
  WS_GROUP = $20000;
  WS_TABSTOP = $10000;

  WS_MINIMIZEBOX = $20000;
  WS_MAXIMIZEBOX = $10000;

  WS_TILED = WS_OVERLAPPED;
  WS_ICONIC = WS_MINIMIZE;
  WS_SIZEBOX = WS_THICKFRAME;

  { Common Window Styles }
  WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or
    WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
  WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW;
  WS_POPUPWINDOW = (WS_POPUP or WS_BORDER or WS_SYSMENU);
  WS_CHILDWINDOW = (WS_CHILD);

  { Extended Window Styles }
  WS_EX_DLGMODALFRAME = 1;
  WS_EX_NOPARENTNOTIFY = 4;
  WS_EX_TOPMOST = 8;
  WS_EX_ACCEPTFILES = $10;
  WS_EX_TRANSPARENT = $20;
  WS_EX_MDICHILD = $40;
  WS_EX_TOOLWINDOW = $80;
  WS_EX_WINDOWEDGE = $100;
  WS_EX_CLIENTEDGE = $200;
  WS_EX_CONTEXTHELP = $400;

  WS_EX_RIGHT = $1000;
  WS_EX_LEFT = 0;
  WS_EX_RTLREADING = $2000;
  WS_EX_LTRREADING = 0;
  WS_EX_LEFTSCROLLBAR = $4000;
  WS_EX_RIGHTSCROLLBAR = 0;

  WS_EX_CONTROLPARENT = $10000;
  WS_EX_STATICEDGE = $20000;
  WS_EX_APPWINDOW = $40000;
  WS_EX_OVERLAPPEDWINDOW = (WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE);
  WS_EX_PALETTEWINDOW = (WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW or WS_EX_TOPMOST);

  { Class styles }
  CS_VREDRAW = DWORD(1);
  CS_HREDRAW = DWORD(2);
  CS_KEYCVTWINDOW = 4;
  CS_DBLCLKS = 8;
  CS_OWNDC = $20;
  CS_CLASSDC = $40;
  CS_PARENTDC = $80;
  CS_NOKEYCVT = $100;
  CS_NOCLOSE = $200;
  CS_SAVEBITS = $800;
  CS_BYTEALIGNCLIENT = $1000;
  CS_BYTEALIGNWINDOW = $2000;
  CS_GLOBALCLASS = $4000;
  CS_DROPSHADOW = $20000;

  CS_IME = $10000;

  { WM_PRINT flags }
  PRF_CHECKVISIBLE = 1;
  PRF_NONCLIENT = 2;
  PRF_CLIENT = 4;
  PRF_ERASEBKGND = 8;
  PRF_CHILDREN = $10;
  PRF_OWNED = $20;

  { 3D border styles }
  BDR_RAISEDOUTER = 1;
  BDR_SUNKENOUTER = 2;
  BDR_RAISEDINNER = 4;
  BDR_SUNKENINNER = 8;

  BDR_OUTER = 3;
  BDR_INNER = 12;
  BDR_RAISED = 5;
  BDR_SUNKEN = 10;

  EDGE_RAISED = (BDR_RAISEDOUTER or BDR_RAISEDINNER);
  EDGE_SUNKEN = (BDR_SUNKENOUTER or BDR_SUNKENINNER);
  EDGE_ETCHED = (BDR_SUNKENOUTER or BDR_RAISEDINNER);
  EDGE_BUMP = (BDR_RAISEDOUTER or BDR_SUNKENINNER);

  { Border flags }
  BF_LEFT = 1;
  BF_TOP = 2;
  BF_RIGHT = 4;
  BF_BOTTOM = 8;

  BF_TOPLEFT = (BF_TOP or BF_LEFT);
  BF_TOPRIGHT = (BF_TOP or BF_RIGHT);
  BF_BOTTOMLEFT = (BF_BOTTOM or BF_LEFT);
  BF_BOTTOMRIGHT = (BF_BOTTOM or BF_RIGHT);
  BF_RECT = (BF_LEFT or BF_TOP or BF_RIGHT or BF_BOTTOM);

  BF_DIAGONAL = $10;

  { For diagonal lines, the BF_RECT flags specify the end point of the}
  { vector bounded by the rectangle parameter.}
  BF_DIAGONAL_ENDTOPRIGHT = (BF_DIAGONAL or BF_TOP or BF_RIGHT);
  BF_DIAGONAL_ENDTOPLEFT = (BF_DIAGONAL or BF_TOP or BF_LEFT);
  BF_DIAGONAL_ENDBOTTOMLEFT = (BF_DIAGONAL or BF_BOTTOM or BF_LEFT);
  BF_DIAGONAL_ENDBOTTOMRIGHT = (BF_DIAGONAL or BF_BOTTOM or BF_RIGHT);

  BF_MIDDLE = $800;   { Fill in the middle }
  BF_SOFT = $1000;    { For softer buttons }
  BF_ADJUST = $2000;  { Calculate the space left over }
  BF_FLAT = $4000;    { For flat rather than 3D borders }
  BF_MONO = $8000;    { For monochrome borders }

function DrawEdge(hdc: HDC; var qrc: TRect; edge: UINT; grfFlags: UINT): BOOL; stdcall;

const
  { flags for DrawFrameControl }
  DFC_CAPTION = 1;
  DFC_MENU = 2;
  DFC_SCROLL = 3;
  DFC_BUTTON = 4;
  DFC_POPUPMENU = 5;

  DFCS_CAPTIONCLOSE = 0;
  DFCS_CAPTIONMIN = 1;
  DFCS_CAPTIONMAX = 2;
  DFCS_CAPTIONRESTORE = 3;
  DFCS_CAPTIONHELP = 4;

  DFCS_MENUARROW = 0;
  DFCS_MENUCHECK = 1;
  DFCS_MENUBULLET = 2;
  DFCS_MENUARROWRIGHT = 4;

  DFCS_SCROLLUP = 0;
  DFCS_SCROLLDOWN = 1;
  DFCS_SCROLLLEFT = 2;
  DFCS_SCROLLRIGHT = 3;
  DFCS_SCROLLCOMBOBOX = 5;
  DFCS_SCROLLSIZEGRIP = 8;
  DFCS_SCROLLSIZEGRIPRIGHT = $10;

  DFCS_BUTTONCHECK = 0;
  DFCS_BUTTONRADIOIMAGE = 1;
  DFCS_BUTTONRADIOMASK = 2;
  DFCS_BUTTONRADIO = 4;
  DFCS_BUTTON3STATE = 8;
  DFCS_BUTTONPUSH = $10;

  DFCS_INACTIVE = $100;
  DFCS_PUSHED = $200;
  DFCS_CHECKED = $400;
  DFCS_TRANSPARENT = $800;
  DFCS_HOT = $1000;
  DFCS_ADJUSTRECT = $2000;
  DFCS_FLAT = $4000;
  DFCS_MONO = $8000;

function DrawFrameControl(DC: HDC; const Rect: TRect; uType, uState: UINT): BOOL; stdcall;

const
  { flags for DrawCaption }
  DC_ACTIVE = 1;
  DC_SMALLCAP = 2;
  DC_ICON = 4;
  DC_TEXT = 8;
  DC_INBUTTON = $10;
  DC_GRADIENT = $20;

function DrawCaption(Wnd :HWND; DC :HDC; const Rect :TRect; Flags :UINT) :BOOL; stdcall;

const
  IDANI_OPEN = 1;
  IDANI_CLOSE = 2;
  IDANI_CAPTION = 3;

function DrawAnimatedRects(hwnd: HWND; idAni: Integer; const lprcFrom, lprcTo: TRect): BOOL; stdcall;

const
  { Predefined Clipboard Formats }
  CF_TEXT = 1;
  CF_BITMAP = 2;
  CF_METAFILEPICT = 3;
  CF_SYLK = 4;
  CF_DIF = 5;
  CF_TIFF = 6;
  CF_OEMTEXT = 7;
  CF_DIB = 8;
  CF_PALETTE = 9;
  CF_PENDATA = 10;
  CF_RIFF = 11;
  CF_WAVE = 12;
  CF_UNICODETEXT = 13;
  CF_ENHMETAFILE = 14;
  CF_HDROP = 15;
  CF_LOCALE = $10;
  CF_MAX = 17;

  CF_OWNERDISPLAY = 128;
  CF_DSPTEXT = 129;
  CF_DSPBITMAP = 130;
  CF_DSPMETAFILEPICT = 131;
  CF_DSPENHMETAFILE = 142;

  { "Private" formats don't get GlobalFree()'d }
  CF_PRIVATEFIRST = $200;
  CF_PRIVATELAST = 767;

  { "GDIOBJ" formats do get DeleteObject()'d }
  CF_GDIOBJFIRST = 768;
  CF_GDIOBJLAST = 1023;


  { Defines for the fVirt field of the Accelerator table structure. }
  FVIRTKEY = 1;
  FNOINVERT = 2;
  FSHIFT = 4;
  FCONTROL = 8;
  FALT = $10;

type
  PAccel = ^TAccel;
  tagACCEL = packed record
    fVirt: Word;     { Also called the flags field }
    key: Word;
    cmd: Word;
  end;
  TAccel = tagACCEL;
  ACCEL = tagACCEL;

  PPaintStruct = ^TPaintStruct;
  tagPAINTSTRUCT = record
    hdc: HDC;
    fErase: BOOL;
    rcPaint: TRect;
    fRestore: BOOL;
    fIncUpdate: BOOL;
    rgbReserved: array[0..31] of Byte;
  end;
  TPaintStruct = tagPAINTSTRUCT;
  PAINTSTRUCT = tagPAINTSTRUCT;

  PWindowPlacement = ^TWindowPlacement;
  tagWINDOWPLACEMENT = record
    length: UINT;
    flags: UINT;
    showCmd: UINT;
    ptMinPosition: TPoint;
    ptMaxPosition: TPoint;
    rcNormalPosition: TRect;
  end;
  TWindowPlacement = tagWINDOWPLACEMENT;
  WINDOWPLACEMENT = tagWINDOWPLACEMENT;

const
  WPF_SETMINPOSITION = 1;
  WPF_RESTORETOMAXIMIZED = 2;

type
  PNMHdr = ^TNMHdr;
  tagNMHDR = packed record
    hwndFrom: HWND;
    idFrom: UINT;
    code: Integer;     { NM_ code }
  end;
  TNMHdr = tagNMHDR;
  NMHDR = tagNMHDR;

  PStyleStruct = ^TStyleStruct;
  tagSTYLESTRUCT = packed record
    styleOld: DWORD;
    styleNew: DWORD;
  end;
  TStyleStruct = tagSTYLESTRUCT;
  STYLESTRUCT = tagSTYLESTRUCT;

const
  { Owner draw control types }
  ODT_MENU = 1;
  ODT_LISTBOX = 2;
  ODT_COMBOBOX = 3;
  ODT_BUTTON = 4;
  ODT_STATIC = 5;

  { Owner draw actions }
  ODA_DRAWENTIRE = 1;
  ODA_SELECT = 2;
  ODA_FOCUS = 4;

  { Owner draw state }
  ODS_SELECTED = 1;
  ODS_GRAYED = 2;
  ODS_DISABLED = 4;
  ODS_CHECKED = 8;
  ODS_FOCUS = $10;
  ODS_DEFAULT = $20;
  ODS_COMBOBOXEDIT = $1000;
  ODS_HOTLIGHT = $40;
  ODS_INACTIVE = $80;

type  
  TOwnerDrawState = set of (odSelected, odGrayed, odDisabled, odChecked,
    odFocused, odDefault, odHotLight, odInactive, odNoAccel, odNoFocusRect,
    odReserved1, odReserved2, odComboBoxEdit);

type
  { for ownerdraw }
  PMeasureItemStruct = ^TMeasureItemStruct;
  tagMEASUREITEMSTRUCT = packed record
    CtlType: UINT;
    CtlID: UINT;
    itemID: UINT;
    itemWidth: UINT;
    itemHeight: UINT;
    itemData: DWORD;
  end;
  TMeasureItemStruct = tagMEASUREITEMSTRUCT;
  MEASUREITEMSTRUCT = tagMEASUREITEMSTRUCT;

  { for ownerdraw }
  PDrawItemStruct = ^TDrawItemStruct;
  tagDRAWITEMSTRUCT = packed record
    CtlType: UINT;
    CtlID: UINT;
    itemID: UINT;
    itemAction: UINT;
    itemState: UINT;
    hwndItem: HWND;
    hDC: HDC;
    rcItem: TRect;
    itemData: DWORD;
  end;
  TDrawItemStruct = tagDRAWITEMSTRUCT;
  DRAWITEMSTRUCT = tagDRAWITEMSTRUCT;

  { for ownerdraw }
  PDeleteItemStruct = ^TDeleteItemStruct;
  tagDELETEITEMSTRUCT = packed record
    CtlType: UINT;
    CtlID: UINT;
    itemID: UINT;
    hwndItem: HWND;
    itemData: UINT;
  end;
  TDeleteItemStruct = tagDELETEITEMSTRUCT;
  DELETEITEMSTRUCT = tagDELETEITEMSTRUCT;

  { for ownerdraw sorting }
  PCompareItemStruct = ^TCompareItemStruct;
  tagCOMPAREITEMSTRUCT = packed record
    CtlType: UINT;
    CtlID: UINT;
    hwndItem: HWND;
    itemID1: UINT;
    itemData1: DWORD;
    itemID2: UINT;
    itemData2: DWORD;
    dwLocaleId: DWORD;
  end;
  TCompareItemStruct = tagCOMPAREITEMSTRUCT;
  COMPAREITEMSTRUCT = tagCOMPAREITEMSTRUCT;

{ Message Function Templates }

function GetMessageA(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;
function GetMessageW(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;
function GetMessage(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;
function DispatchMessageA(const lpMsg: TMsg): Longint; stdcall;
function DispatchMessageW(const lpMsg: TMsg): Longint; stdcall;
function DispatchMessage(const lpMsg: TMsg): Longint; stdcall;
function TranslateMessage(const lpMsg: TMsg): BOOL; stdcall;
function SetMessageQueue(cMessagesMax: Integer): BOOL; stdcall;
function PeekMessageA(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
function PeekMessageW(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
function PeekMessage(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;

const
  { PeekMessage() Options }
  PM_NOREMOVE = 0;
  PM_REMOVE = 1;
  PM_NOYIELD = 2;

function RegisterHotKey(hWnd: HWND; id: Integer; fsModifiers, vk: UINT): BOOL; stdcall;
function UnregisterHotKey(hWnd: HWND; id: Integer): BOOL; stdcall;

const
  MOD_ALT = 1;
  MOD_CONTROL = 2;
  MOD_SHIFT = 4;
  MOD_WIN = 8;

  IDHOT_SNAPWINDOW = -1;    { SHIFT-PRINTSCRN  }
  IDHOT_SNAPDESKTOP = -2;   { PRINTSCRN        }

  EW_RESTARTWINDOWS        = $0042;
  EW_REBOOTSYSTEM          = $0043;
  EW_EXITANDEXECAPP        = $0044;

  ENDSESSION_LOGOFF        = DWORD($80000000);

  EWX_LOGOFF = 0;
  EWX_SHUTDOWN = 1;
  EWX_REBOOT = 2;
  EWX_FORCE = 4;
  EWX_POWEROFF = 8;
  EWX_FORCEIFHUNG = $10;


function ExitWindows(dwReserved: DWORD; Code: Word): BOOL;

function ExitWindowsEx(uFlags: UINT; dwReserved: DWORD): BOOL; stdcall;
function SwapMouseButton(fSwap: BOOL): BOOL; stdcall;
function GetMessagePos: DWORD; stdcall;
function GetMessageTime: Longint; stdcall;
function GetMessageExtraInfo: Longint; stdcall;
function SetMessageExtraInfo(lParam: LPARAM): LPARAM; stdcall;

function SendMessageA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function SendMessageW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function SendMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function SendMessageTimeoutA(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM; fuFlags, uTimeout: UINT; var lpdwResult: DWORD): LRESULT; stdcall;
function SendMessageTimeoutW(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM; fuFlags, uTimeout: UINT; var lpdwResult: DWORD): LRESULT; stdcall;
function SendMessageTimeout(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM; fuFlags, uTimeout: UINT; var lpdwResult: DWORD): LRESULT; stdcall;
function SendNotifyMessageA(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
function SendNotifyMessageW(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
function SendNotifyMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
function SendMessageCallbackA(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM; lpResultCallBack: TFNSendAsyncProc; dwData: DWORD): BOOL; stdcall;
function SendMessageCallbackW(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM; lpResultCallBack: TFNSendAsyncProc; dwData: DWORD): BOOL; stdcall;
function SendMessageCallback(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM; lpResultCallBack: TFNSendAsyncProc; dwData: DWORD): BOOL; stdcall;
function BroadcastSystemMessageA(Flags: DWORD; Recipients: PDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
function BroadcastSystemMessageW(Flags: DWORD; Recipients: PDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
function BroadcastSystemMessage(Flags: DWORD; Recipients: PDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;

const
  { Broadcast Special Message Recipient list }
  BSM_ALLCOMPONENTS = $00000000;
  BSM_VXDS = $00000001;
  BSM_NETDRIVER = $00000002;
  BSM_INSTALLABLEDRIVERS = $00000004;
  BSM_APPLICATIONS = $00000008;
  BSM_ALLDESKTOPS = $00000010;

  { Broadcast Special Message Flags }
  BSF_QUERY = $00000001;
  BSF_IGNORECURRENTTASK = $00000002;
  BSF_FLUSHDISK = $00000004;
  BSF_NOHANG = $00000008;
  BSF_POSTMESSAGE = $00000010;
  BSF_FORCEIFHUNG = $00000020;
  BSF_NOTIMEOUTIFNOTHUNG = $00000040;

type
  PBroadcastSysMsg = ^TBroadcastSysMsg;
  tagBROADCASTSYSMSG = packed record
    uiMessage: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
  end;
  TBroadcastSysMsg = tagBROADCASTSYSMSG;
  BROADCASTSYSMSG = tagBROADCASTSYSMSG;

const
  DBWF_LPARAMPOINTER = $8000;

  BROADCAST_QUERY_DENY = $424D5144;  { Return this value to deny a query. }

type
  HDEVNOTIFY = Pointer;
  PHDEVNOTIFY = ^HDEVNOTIFY;

const
  DEVICE_NOTIFY_WINDOW_HANDLE = 0;

function RegisterDeviceNotificationA(hRecipient: THandle; NotificationFilter: Pointer; Flags: DWORD): HDEVNOTIFY; stdcall;
function RegisterDeviceNotificationW(hRecipient: THandle; NotificationFilter: Pointer; Flags: DWORD): HDEVNOTIFY; stdcall;
function RegisterDeviceNotification(hRecipient: THandle; NotificationFilter: Pointer; Flags: DWORD): HDEVNOTIFY; stdcall;
function UnregisterDeviceNotification(Handle: HDEVNOTIFY): BOOL; stdcall;

function PostMessageA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostMessageW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostThreadMessageA(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostThreadMessageW(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostThreadMessage(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostAppMessageA(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
function PostAppMessageW(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
function PostAppMessage(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;

const
  { Special HWND value for use with PostMessage() and SendMessage() }
  HWND_BROADCAST = $FFFF;
  wnd_Broadcast = HWND_BROADCAST;

  HWND_MESSAGE = -3;
  wnd_Message = HWND_MESSAGE;

function AttachThreadInput(idAttach, idAttachTo: DWORD; fAttach: BOOL): BOOL; stdcall;
function ReplyMessage(lResult: LRESULT): BOOL; stdcall;
function WaitMessage: BOOL; stdcall;
function WaitForInputIdle(hProcess: THandle; dwMilliseconds: DWORD): DWORD; stdcall;
function DefWindowProcA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefWindowProcW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function CallWindowProcA(lpPrevWndFunc: TFNWndProc; hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function CallWindowProcW(lpPrevWndFunc: TFNWndProc; hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function CallWindowProc(lpPrevWndFunc: TFNWndProc; hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
procedure PostQuitMessage(nExitCode: Integer); stdcall;
function InSendMessage: BOOL; stdcall;
function InSendMessageEx(lpReserved: Pointer): DWORD; stdcall;

const
  { InSendMessageEx return value }
  ISMEX_NOSEND = 0;
  ISMEX_SEND = 1;
  ISMEX_NOTIFY = 2;
  ISMEX_CALLBACK = 4;
  ISMEX_REPLIED = 8;

function GetDoubleClickTime: UINT; stdcall;
function SetDoubleClickTime(Interval: UINT): BOOL; stdcall;
function RegisterClassA(const lpWndClass: TWndClassA): ATOM; stdcall;
function RegisterClassW(const lpWndClass: TWndClassW): ATOM; stdcall;
function RegisterClass(const lpWndClass: TWndClass): ATOM; stdcall;
function UnregisterClassA(lpClassName: PAnsiChar; hInstance: HINST): BOOL; stdcall;
function UnregisterClassW(lpClassName: PWideChar; hInstance: HINST): BOOL; stdcall;
function UnregisterClass(lpClassName: PTChar; hInstance: HINST): BOOL; stdcall;
function GetClassInfoA(hInstance: HINST; lpClassName: PAnsiChar;
  var lpWndClass: TWndClassA): BOOL; stdcall;
function GetClassInfoW(hInstance: HINST; lpClassName: PWideChar;
  var lpWndClass: TWndClassW): BOOL; stdcall;
function GetClassInfo(hInstance: HINST; lpClassName: PTChar;
  var lpWndClass: TWndClass): BOOL; stdcall;
function RegisterClassExA(const WndClass: TWndClassExA): ATOM; stdcall;
function RegisterClassExW(const WndClass: TWndClassExW): ATOM; stdcall;
function RegisterClassEx(const WndClass: TWndClassEx): ATOM; stdcall;
function GetClassInfoExA(Instance: HINST; Classname: PAnsiChar; var WndClass: TWndClassExA): BOOL; stdcall;
function GetClassInfoExW(Instance: HINST; Classname: PWideChar; var WndClass: TWndClassExW): BOOL; stdcall;
function GetClassInfoEx(Instance: HINST; Classname: PTChar; var WndClass: TWndClassEx): BOOL; stdcall;

const
  CW_USEDEFAULT = DWORD($80000000);

  { Special value for CreateWindow, et al. }
  HWND_DESKTOP = 0;

function CreateWindowExA(dwExStyle: DWORD; lpClassName: PAnsiChar;
  lpWindowName: PAnsiChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND; stdcall;
function CreateWindowExW(dwExStyle: DWORD; lpClassName: PWideChar;
  lpWindowName: PWideChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND; stdcall;
function CreateWindowEx(dwExStyle: DWORD; lpClassName: PTChar;
  lpWindowName: PTChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND; stdcall;
function CreateWindowA(lpClassName: PAnsiChar; lpWindowName: PAnsiChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
function CreateWindowW(lpClassName: PWideChar; lpWindowName: PWideChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
function CreateWindow(lpClassName: PTChar; lpWindowName: PTChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;

function IsWindow(hWnd: HWND): BOOL; stdcall;
function IsMenu(hMenu: HMENU): BOOL; stdcall;
function IsChild(hWndParent, hWnd: HWND): BOOL; stdcall;
function DestroyWindow(hWnd: HWND): BOOL; stdcall;
function ShowWindow(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall;
function AnimateWindow(hWnd: HWND; dwTime: DWORD; dwFlags: DWORD): BOOL; stdcall;
function ShowWindowAsync(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall;
function FlashWindow(hWnd: HWND; bInvert: BOOL): BOOL; stdcall;

type
  FLASHWINFO = record
    cbSize: UINT;
    hwnd: HWND;
    dwFlags: DWORD;
    uCount: UINT;
    dwTimeout: DWORD;
  end;
  PFLASHWINFO = ^FLASHWINFO;
  TFlashWInfo = FLASHWINFO;

function FlashWindowEx(var pfwi: FLASHWINFO): BOOL; stdcall;

const
  FLASHW_STOP = $0;
  FLASHW_CAPTION = $1;
  FLASHW_TRAY = $2;
  FLASHW_ALL = FLASHW_CAPTION or FLASHW_TRAY;
  FLASHW_TIMER = $4;
  FLASHW_TIMERNOFG = $C;

function ShowOwnedPopups(hWnd: HWND; fShow: BOOL): BOOL; stdcall;
function OpenIcon(hWnd: HWND): BOOL; stdcall;
function CloseWindow(hWnd: HWND): BOOL; stdcall;
function MoveWindow(hWnd: HWND; X, Y, nWidth, nHeight: Integer; bRepaint: BOOL): BOOL; stdcall;
function SetWindowPos(hWnd: HWND; hWndInsertAfter: HWND;
  X, Y, cx, cy: Integer; uFlags: UINT): BOOL; stdcall;
function GetWindowPlacement(hWnd: HWND; WindowPlacement: PWindowPlacement): BOOL; stdcall;
function SetWindowPlacement(hWnd: HWND; WindowPlacement: PWindowPlacement): BOOL; stdcall;
function BeginDeferWindowPos(nNumWindows: Integer): HDWP; stdcall;
function DeferWindowPos(hWinPosInfo: HDWP; hWnd: HWND;
  hWndInsertAfter: HWND; x, y, cx, cy: Integer; uFlags: UINT): HDWP; stdcall;
function EndDeferWindowPos(hWinPosInfo: HDWP): BOOL; stdcall;
function IsWindowVisible(hWnd: HWND): BOOL; stdcall;
function IsIconic(hWnd: HWND): BOOL; stdcall;
function AnyPopup: BOOL; stdcall;
function BringWindowToTop(hWnd: HWND): BOOL; stdcall;
function IsZoomed(hWnd: HWND): BOOL; stdcall;


const
  { SetWindowPos Flags }
  SWP_NOSIZE = 1;
  SWP_NOMOVE = 2;
  SWP_NOZORDER = 4;
  SWP_NOREDRAW = 8;
  SWP_NOACTIVATE = $10;
  SWP_FRAMECHANGED = $20;    { The frame changed: send WM_NCCALCSIZE }
  SWP_SHOWWINDOW = $40;
  SWP_HIDEWINDOW = $80;
  SWP_NOCOPYBITS = $100;
  SWP_NOOWNERZORDER = $200;  { Don't do owner Z ordering }
  SWP_NOSENDCHANGING = $400;  { Don't send WM_WINDOWPOSCHANGING }
  SWP_DRAWFRAME = SWP_FRAMECHANGED;
  SWP_NOREPOSITION = SWP_NOOWNERZORDER;
  SWP_DEFERERASE = $2000;
  SWP_ASYNCWINDOWPOS = $4000;

  HWND_TOP = 0;
  HWND_BOTTOM = 1;
  HWND_TOPMOST = HWND(-1);
  HWND_NOTOPMOST = HWND(-2);


type
  PDlgTemplate = ^TDlgTemplate;
  DLGTEMPLATE = packed record
    style: DWORD;
    dwExtendedStyle: DWORD;
    cdit: Word;
    x: SHORT;
    y: SHORT;
    cx: SHORT;
    cy: SHORT;
  end;
  TDlgTemplate = DLGTEMPLATE;

  { 32 bit Dialog item template. }
  PDlgItemTemplate = ^TDlgItemTemplate;
  DLGITEMTEMPLATE = packed record
    style: DWORD;
    dwExtendedStyle: DWORD;
    x: SHORT;
    y: SHORT;
    cx: SHORT;
    cy: SHORT;
    id: Word;
  end;
  TDlgItemTemplate = DLGITEMTEMPLATE;

function CreateDialogParamA(hInstance: HINST; lpTemplateName: PAnsiChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogParamW(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogParam(hInstance: HINST; lpTemplateName: PTChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogIndirectParamA(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogIndirectParamW(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogIndirectParam(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogA(hInstance: HINST; lpTemplateName: PAnsiChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
function CreateDialogW(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
function CreateDialog(hInstance: HINST; lpTemplateName: PTChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
function CreateDialogIndirectA(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
function CreateDialogIndirectW(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
function CreateDialogIndirect(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
function DialogBoxParamA(hInstance: HINST; lpTemplateName: PAnsiChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): Integer; stdcall;
function DialogBoxParamW(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): Integer; stdcall;
function DialogBoxParam(hInstance: HINST; lpTemplateName: PTChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): Integer; stdcall;
function DialogBoxIndirectParamA(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): Integer; stdcall;
function DialogBoxIndirectParamW(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): Integer; stdcall;
function DialogBoxIndirectParam(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc; dwInitParam: LPARAM): Integer; stdcall;
function DialogBoxA(hInstance: HINST; lpTemplate: PAnsiChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
function DialogBoxW(hInstance: HINST; lpTemplate: PWideChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
function DialogBox(hInstance: HINST; lpTemplate: PTChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
function DialogBoxIndirectA(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
function DialogBoxIndirectW(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
function DialogBoxIndirect(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
function EndDialog(hDlg: HWND; nResult: Integer): BOOL; stdcall;
function GetDlgItem(hDlg: HWND; nIDDlgItem: Integer): HWND; stdcall;
function SetDlgItemInt(hDlg: HWND; nIDDlgItem: Integer; uValue: UINT; bSigned: BOOL): BOOL; stdcall;
function GetDlgItemInt(hDlg: HWND; nIDDlgItem: Integer;
  var lpTranslated: BOOL; bSigned: BOOL): UINT; stdcall;
function SetDlgItemTextA(hDlg: HWND; nIDDlgItem: Integer; lpString: PAnsiChar): BOOL; stdcall;
function SetDlgItemTextW(hDlg: HWND; nIDDlgItem: Integer; lpString: PWideChar): BOOL; stdcall;
function SetDlgItemText(hDlg: HWND; nIDDlgItem: Integer; lpString: PTChar): BOOL; stdcall;
function GetDlgItemTextA(hDlg: HWND; nIDDlgItem: Integer;
  lpString: PAnsiChar; nMaxCount: Integer): UINT; stdcall;
function GetDlgItemTextW(hDlg: HWND; nIDDlgItem: Integer;
  lpString: PWideChar; nMaxCount: Integer): UINT; stdcall;
function GetDlgItemText(hDlg: HWND; nIDDlgItem: Integer;
  lpString: PTChar; nMaxCount: Integer): UINT; stdcall;
function CheckDlgButton(hDlg: HWND; nIDButton: Integer; uCheck: UINT): BOOL; stdcall;
function CheckRadioButton(hDlg: HWND; nIDFirstButton, nIDLastButton, nIDCheckButton: Integer): BOOL; stdcall;
function IsDlgButtonChecked(hDlg: HWND; nIDButton: Integer): UINT; stdcall;
function SendDlgItemMessageA(hDlg: HWND; nIDDlgItem: Integer;
  Msg: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
function SendDlgItemMessageW(hDlg: HWND; nIDDlgItem: Integer;
  Msg: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
function SendDlgItemMessage(hDlg: HWND; nIDDlgItem: Integer;
  Msg: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
function GetNextDlgGroupItem(hDlg: HWND; hCtl: HWND; bPrevious: BOOL): HWND; stdcall;
function GetNextDlgTabItem(hDlg: HWND; hCtl: HWND; bPrevious: BOOL): HWND; stdcall;
function GetDlgCtrlID(hWnd: HWND): Integer; stdcall;
function GetDialogBaseUnits: Longint; stdcall;
function DefDlgProcA(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefDlgProcW(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefDlgProc(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

const
  { Window extra byted needed for private dialog classes. }
  DLGWINDOWEXTRA = 30;

function CallMsgFilterA(var lpMsg: TMsg; nCode: Integer): BOOL; stdcall;
function CallMsgFilterW(var lpMsg: TMsg; nCode: Integer): BOOL; stdcall;
function CallMsgFilter(var lpMsg: TMsg; nCode: Integer): BOOL; stdcall;

{ Clipboard Manager Functions }

function OpenClipboard(hWndNewOwner: HWND): BOOL; stdcall;
function CloseClipboard: BOOL; stdcall;
function GetClipboardSequenceNumber: DWORD; stdcall;
function GetClipboardOwner: HWND; stdcall;
function SetClipboardViewer(hWndNewViewer: HWND): HWND; stdcall;
function GetClipboardViewer: HWND; stdcall;
function ChangeClipboardChain(hWndRemove, hWndNewNext: HWND): BOOL; stdcall;
function SetClipboardData(uFormat: UINT; hMem: THandle): THandle; stdcall;
function GetClipboardData(uFormat: UINT): THandle; stdcall;
function RegisterClipboardFormatA(lpszFormat: PAnsiChar): UINT; stdcall;
function RegisterClipboardFormatW(lpszFormat: PWideChar): UINT; stdcall;
function RegisterClipboardFormat(lpszFormat: PTChar): UINT; stdcall;
function CountClipboardFormats: Integer; stdcall;
function EnumClipboardFormats(format: UINT): UINT; stdcall;
function GetClipboardFormatNameA(format: UINT; lpszFormatName: PAnsiChar;
  cchMaxCount: Integer): Integer; stdcall;
function GetClipboardFormatNameW(format: UINT; lpszFormatName: PWideChar;
  cchMaxCount: Integer): Integer; stdcall;
function GetClipboardFormatName(format: UINT; lpszFormatName: PTChar;
  cchMaxCount: Integer): Integer; stdcall;
function EmptyClipboard: BOOL; stdcall;
function IsClipboardFormatAvailable(format: UINT): BOOL; stdcall;
function GetPriorityClipboardFormat(var paFormatPriorityList; cFormats: Integer): Integer; stdcall;
function GetOpenClipboardWindow: HWND; stdcall;

{ Character Translation Routines }

function CharToOemA(lpszSrc: PAnsiChar; lpszDst: PAnsiChar): BOOL; stdcall;
function CharToOemW(lpszSrc: PWideChar; lpszDst: PWideChar): BOOL; stdcall;
function CharToOem(lpszSrc: PTChar; lpszDst: PTChar): BOOL; stdcall;
function OemToCharA(lpszSrc: PAnsiChar; lpszDst: PAnsiChar): BOOL; stdcall;
function OemToCharW(lpszSrc: PWideChar; lpszDst: PWideChar): BOOL; stdcall;
function OemToChar(lpszSrc: PTChar; lpszDst: PTChar): BOOL; stdcall;
function CharToOemBuffA(lpszSrc: PAnsiChar; lpszDst: PAnsiChar; cchDstLength: DWORD): BOOL; stdcall;
function CharToOemBuffW(lpszSrc: PWideChar; lpszDst: PWideChar; cchDstLength: DWORD): BOOL; stdcall;
function CharToOemBuff(lpszSrc: PTChar; lpszDst: PTChar; cchDstLength: DWORD): BOOL; stdcall;
function OemToCharBuffA(lpszSrc: PAnsiChar; lpszDst: PAnsiChar; cchDstLength: DWORD): BOOL; stdcall;
function OemToCharBuffW(lpszSrc: PWideChar; lpszDst: PWideChar; cchDstLength: DWORD): BOOL; stdcall;
function OemToCharBuff(lpszSrc: PTChar; lpszDst: PTChar; cchDstLength: DWORD): BOOL; stdcall;
function CharUpperA(lpsz: PAnsiChar): PAnsiChar; stdcall;
function CharUpperW(lpsz: PWideChar): PWideChar; stdcall;
function CharUpper(lpsz: PTChar): PTChar; stdcall;
function CharUpperBuffA(lpsz: PAnsiChar; cchLength: DWORD): DWORD; stdcall;
function CharUpperBuffW(lpsz: PWideChar; cchLength: DWORD): DWORD; stdcall;
function CharUpperBuff(lpsz: PTChar; cchLength: DWORD): DWORD; stdcall;
function CharLowerA(lpsz: PAnsiChar): PAnsiChar; stdcall;
function CharLowerW(lpsz: PWideChar): PWideChar; stdcall;
function CharLower(lpsz: PTChar): PTChar; stdcall;
function CharLowerBuffA(lpsz: PAnsiChar; cchLength: DWORD): DWORD; stdcall;
function CharLowerBuffW(lpsz: PWideChar; cchLength: DWORD): DWORD; stdcall;
function CharLowerBuff(lpsz: PTChar; cchLength: DWORD): DWORD; stdcall;
function CharNextA(lpsz: PAnsiChar): PAnsiChar; stdcall;
function CharNextW(lpsz: PWideChar): PWideChar; stdcall;
function CharNext(lpsz: PTChar): PTChar; stdcall;
function CharPrevA(lpszStart: PAnsiChar; lpszCurrent: PAnsiChar): PAnsiChar; stdcall;
function CharPrevW(lpszStart: PWideChar; lpszCurrent: PWideChar): PWideChar; stdcall;
function CharPrev(lpszStart: PTChar; lpszCurrent: PTChar): PTChar; stdcall;

function CharNextExA(CodePage: Word; lpCurrentChar: LPCSTR; dwFlags: DWORD): LPSTR; stdcall;
function CharNextEx(CodePage: Word; lpCurrentChar: LPCSTR; dwFlags: DWORD): LPSTR; stdcall;
function CharPrevEx(CodePage: Word; lpStart, lpCurrentChar: LPCSTR; dwFlags: DWORD): LPSTR; stdcall;
function CharPrevExA(CodePage: Word; lpStart, lpCurrentChar: LPCSTR; dwFlags: DWORD): LPSTR; stdcall;

{ Compatibility defines for character translation routines }

function AnsiToOem(const lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL; stdcall;
function OemToAnsi(const lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL; stdcall;
function AnsiToOemBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
function OemToAnsiBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
function AnsiUpper(lpsz: LPSTR): LPSTR; stdcall;
function AnsiUpperBuff(lpsz: LPSTR; cchLength: DWORD): DWORD; stdcall;
function AnsiLower(lpsz: LPSTR): LPSTR; stdcall;
function AnsiLowerBuff(lpsz: LPSTR; cchLength: DWORD): DWORD; stdcall;
function AnsiNext(const lpsz: LPCSTR): LPSTR; stdcall;
function AnsiPrev(const lpszStart: LPCSTR; const lpszCurrent: LPCSTR): LPSTR; stdcall;

{ Language dependent Routines }

function IsCharAlphaA(ch: AnsiChar): BOOL; stdcall;
function IsCharAlphaW(ch: WideChar): BOOL; stdcall;
function IsCharAlpha(ch: TChar): BOOL; stdcall;
function IsCharAlphaNumericA(ch: AnsiChar): BOOL; stdcall;
function IsCharAlphaNumericW(ch: WideChar): BOOL; stdcall;
function IsCharAlphaNumeric(ch: TChar): BOOL; stdcall;
function IsCharUpperA(ch: AnsiChar): BOOL; stdcall;
function IsCharUpperW(ch: WideChar): BOOL; stdcall;
function IsCharUpper(ch: TChar): BOOL; stdcall;
function IsCharLowerA(ch: AnsiChar): BOOL; stdcall;
function IsCharLowerW(ch: WideChar): BOOL; stdcall;
function IsCharLower(ch: TChar): BOOL; stdcall;

function SetFocus(hWnd: HWND): HWND; stdcall;
function GetActiveWindow: HWND; stdcall;
function GetFocus: HWND; stdcall;
function GetKBCodePage: UINT; stdcall;
function GetKeyState(nVirtKey: Integer): SHORT; stdcall;
function GetAsyncKeyState(vKey: Integer): SHORT; stdcall;

type
  PKeyboardState = ^TKeyboardState;
  TKeyboardState = array[0..255] of Byte;

function GetKeyboardState(var KeyState: TKeyboardState): BOOL; stdcall;
function SetKeyboardState(var KeyState: TKeyboardState): BOOL; stdcall;
function GetKeyNameTextA(lParam: Longint; lpString: PAnsiChar; nSize: Integer): Integer; stdcall;
function GetKeyNameTextW(lParam: Longint; lpString: PWideChar; nSize: Integer): Integer; stdcall;
function GetKeyNameText(lParam: Longint; lpString: PTChar; nSize: Integer): Integer; stdcall;
function GetKeyboardType(nTypeFlag: Integer): Integer; stdcall;
function ToAscii(uVirtKey, uScanCode: UINT; const KeyState: TKeyboardState;
  lPTChar: PTChar; uFlags: UINT): Integer; stdcall;
function ToAsciiEx(uVirtKey: UINT; uScanCode: UINT; const KeyState: TKeyboardState;
  lPTChar: PTChar; uFlags: UINT; dwhkl: HKL): Integer; stdcall;
function ToUnicode(wVirtKey, wScanCode: UINT; const KeyState: TKeyboardState;
  var pwszBuff; cchBuff: Integer; wFlags: UINT): Integer; stdcall;
function OemKeyScan(wOemChar: Word): DWORD; stdcall;

function VkKeyScanA(ch: AnsiChar): SHORT; stdcall;
function VkKeyScanW(ch: WideChar): SHORT; stdcall;
function VkKeyScan(ch: TChar): SHORT; stdcall;
function VkKeyScanExA(ch: AnsiChar; dwhkl: HKL): SHORT; stdcall;
function VkKeyScanExW(ch: WideChar; dwhkl: HKL): SHORT; stdcall;
function VkKeyScanEx(ch: TChar; dwhkl: HKL): SHORT; stdcall;

const
  KEYEVENTF_EXTENDEDKEY = 1;
  KEYEVENTF_KEYUP = 2;

procedure keybd_event(bVk: Byte; bScan: Byte; dwFlags, dwExtraInfo: DWORD); stdcall;

const
  MOUSEEVENTF_MOVE            = $0001; { mouse move }
  MOUSEEVENTF_LEFTDOWN        = $0002; { left button down }
  MOUSEEVENTF_LEFTUP          = $0004; { left button up }
  MOUSEEVENTF_RIGHTDOWN       = $0008; { right button down }
  MOUSEEVENTF_RIGHTUP         = $0010; { right button up }
  MOUSEEVENTF_MIDDLEDOWN      = $0020; { middle button down }
  MOUSEEVENTF_MIDDLEUP        = $0040; { middle button up }
  MOUSEEVENTF_WHEEL           = $0800; { wheel button rolled }
  MOUSEEVENTF_ABSOLUTE        = $8000; { absolute move }

procedure mouse_event(dwFlags, dx, dy, dwData, dwExtraInfo: DWORD); stdcall;

type
  PMouseInput = ^TMouseInput;
  tagMOUSEINPUT = packed record
    dx: Longint;
    dy: Longint;
    mouseData: DWORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: DWORD;
  end;
  TMouseInput = tagMOUSEINPUT;

  PKeybdInput = ^TKeybdInput;
  tagKEYBDINPUT = packed record
    wVk: WORD;
    wScan: WORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: DWORD;
  end;
  TKeybdInput = tagKEYBDINPUT;

  PHardwareInput = ^THardwareInput;
  tagHARDWAREINPUT = packed record
    uMsg: DWORD;
    wParamL: WORD;
    wParamH: WORD;
  end;
  THardwareInput = tagHARDWAREINPUT;

const
  INPUT_MOUSE = 0;
  INPUT_KEYBOARD = 1;
  INPUT_HARDWARE = 2;

type
  PInput = ^TInput;
  tagINPUT = packed record
    Itype: DWORD;
    case Integer of
      0: (mi: TMouseInput);
      1: (ki: TKeybdInput);
      2: (hi: THardwareInput);
  end;
  TInput = tagINPUT;

function SendInput(cInputs: UINT; var pInputs: TInput; cbSize: Integer): UINT; stdcall;

type
  PLastInputInfo = ^TLastInputInfo;
  tagLASTINPUTINFO = packed record
    cbSize: UINT;
    dwTime: DWORD;
  end;
  TLastInputInfo = tagLASTINPUTINFO;

function GetLastInputInfo(var plii: TLastInputInfo): BOOL; stdcall;

function MapVirtualKeyA(uCode, uMapType: UINT): UINT; stdcall;
function MapVirtualKeyW(uCode, uMapType: UINT): UINT; stdcall;
function MapVirtualKey(uCode, uMapType: UINT): UINT; stdcall;
function MapVirtualKeyExA(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;
function MapVirtualKeyExW(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;
function MapVirtualKeyEx(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;
function GetInputState: BOOL; stdcall;
function GetQueueStatus(flags: UINT): DWORD; stdcall;
function GetCapture: HWND; stdcall;
function SetCapture(hWnd: HWND): HWND; stdcall;
function ReleaseCapture: BOOL; stdcall;
function MsgWaitForMultipleObjects(nCount: DWORD; var pHandles;
  fWaitAll: BOOL; dwMilliseconds, dwWakeMask: DWORD): DWORD; stdcall;
function MsgWaitForMultipleObjectsEx(nCount: DWORD; var pHandles;
  dwMilliseconds, dwWakeMask, dwFlags: DWORD): DWORD; stdcall;

const
  MWMO_WAITALL = $0001;
  MWMO_ALERTABLE = $0002;

  { Queue status flags for GetQueueStatus() and MsgWaitForMultipleObjects() }
  QS_KEY                  = $0001;
  QS_MOUSEMOVE            = $0002;
  QS_MOUSEBUTTON          = $0004;
  QS_POSTMESSAGE          = $0008;
  QS_TIMER                = $0010;
  QS_PAINT                = $0020;
  QS_SENDMESSAGE          = $0040;
  QS_HOTKEY               = $0080;
  QS_ALLPOSTMESSAGE       = $0100;

  QS_MOUSE = (QS_MOUSEMOVE or QS_MOUSEBUTTON);
  QS_INPUT = (QS_MOUSE or QS_KEY);
  QS_ALLEVENTS = (QS_INPUT or QS_POSTMESSAGE or QS_TIMER or QS_PAINT
    or QS_HOTKEY);
  QS_ALLINPUT = (QS_INPUT or QS_POSTMESSAGE or QS_TIMER or QS_PAINT
    or QS_HOTKEY or QS_SENDMESSAGE);


{ Windows Functions }

function SetTimer(hWnd: HWND; nIDEvent, uElapse: UINT;
  lpTimerFunc: TFNTimerProc): UINT; stdcall;
function KillTimer(hWnd: HWND; uIDEvent: UINT): BOOL; stdcall;
function IsWindowUnicode(hWnd: HWND): BOOL; stdcall;
function EnableWindow(hWnd: HWND; bEnable: BOOL): BOOL; stdcall;
function IsWindowEnabled(hWnd: HWND): BOOL; stdcall;
function LoadAcceleratorsA(hInstance: HINST; lpTableName: PAnsiChar): HACCEL; stdcall;
function LoadAcceleratorsW(hInstance: HINST; lpTableName: PWideChar): HACCEL; stdcall;
function LoadAccelerators(hInstance: HINST; lpTableName: PTChar): HACCEL; stdcall;
function CreateAcceleratorTableA(var Accel; Count: Integer): HACCEL; stdcall;
function CreateAcceleratorTableW(var Accel; Count: Integer): HACCEL; stdcall;
function CreateAcceleratorTable(var Accel; Count: Integer): HACCEL; stdcall;
function CopyAcceleratorTableA(hAccelSrc: HACCEL; var lpAccelDst; cAccelEntries: Integer): Integer; stdcall;
function CopyAcceleratorTableW(hAccelSrc: HACCEL; var lpAccelDst; cAccelEntries: Integer): Integer; stdcall;
function CopyAcceleratorTable(hAccelSrc: HACCEL; var lpAccelDst; cAccelEntries: Integer): Integer; stdcall;
function TranslateAcceleratorA(hWnd: HWND; hAccTable: HACCEL; var lpMsg: TMsg): Integer; stdcall;
function TranslateAcceleratorW(hWnd: HWND; hAccTable: HACCEL; var lpMsg: TMsg): Integer; stdcall;
function TranslateAccelerator(hWnd: HWND; hAccTable: HACCEL; var lpMsg: TMsg): Integer; stdcall;
function DestroyAcceleratorTable(hAccel: HACCEL): BOOL; stdcall;

const
  { GetSystemMetrics() codes }
  SM_CXSCREEN = 0;
  SM_CYSCREEN = 1;
  SM_CXVSCROLL = 2;
  SM_CYHSCROLL = 3;
  SM_CYCAPTION = 4;
  SM_CXBORDER = 5;
  SM_CYBORDER = 6;
  SM_CXDLGFRAME = 7;
  SM_CYDLGFRAME = 8;
  SM_CYVTHUMB = 9;
  SM_CXHTHUMB = 10;
  SM_CXICON = 11;
  SM_CYICON = 12;
  SM_CXCURSOR = 13;
  SM_CYCURSOR = 14;
  SM_CYMENU = 15;
  SM_CXFULLSCREEN = $10;
  SM_CYFULLSCREEN = 17;
  SM_CYKANJIWINDOW = 18;
  SM_MOUSEPRESENT = 19;
  SM_CYVSCROLL = 20;
  SM_CXHSCROLL = 21;
  SM_DEBUG = 22;
  SM_SWAPBUTTON = 23;
  SM_RESERVED1 = 24;
  SM_RESERVED2 = 25;
  SM_RESERVED3 = 26;
  SM_RESERVED4 = 27;
  SM_CXMIN = 28;
  SM_CYMIN = 29;
  SM_CXSIZE = 30;
  SM_CYSIZE = 31;
  SM_CXFRAME = $20;
  SM_CYFRAME = 33;
  SM_CXMINTRACK = 34;
  SM_CYMINTRACK = 35;
  SM_CXDOUBLECLK = 36;
  SM_CYDOUBLECLK = 37;
  SM_CXICONSPACING = 38;
  SM_CYICONSPACING = 39;
  SM_MENUDROPALIGNMENT = 40;
  SM_PENWINDOWS = 41;
  SM_DBCSENABLED = 42;
  SM_CMOUSEBUTTONS = 43;

  SM_CXFIXEDFRAME = SM_CXDLGFRAME; { win40 name change }
  SM_CYFIXEDFRAME = SM_CYDLGFRAME; { win40 name change }
  SM_CXSIZEFRAME = SM_CXFRAME;     { win40 name change }
  SM_CYSIZEFRAME = SM_CYFRAME;     { win40 name change }

  SM_SECURE = 44;
  SM_CXEDGE = 45;
  SM_CYEDGE = 46;
  SM_CXMINSPACING = 47;
  SM_CYMINSPACING = 48;
  SM_CXSMICON = 49;
  SM_CYSMICON = 50;
  SM_CYSMCAPTION = 51;
  SM_CXSMSIZE = 52;
  SM_CYSMSIZE = 53;
  SM_CXMENUSIZE = 54;
  SM_CYMENUSIZE = 55;
  SM_ARRANGE = 56;
  SM_CXMINIMIZED = 57;
  SM_CYMINIMIZED = 58;
  SM_CXMAXTRACK = 59;
  SM_CYMAXTRACK = 60;
  SM_CXMAXIMIZED = 61;
  SM_CYMAXIMIZED = 62;
  SM_NETWORK = 63;
  SM_CLEANBOOT = 67;
  SM_CXDRAG = 68;
  SM_CYDRAG = 69;
  SM_SHOWSOUNDS = 70;
  SM_CXMENUCHECK = 71;     { Use instead of GetMenuCheckMarkDimensions()! }
  SM_CYMENUCHECK = 72;
  SM_SLOWMACHINE = 73;
  SM_MIDEASTENABLED = 74;
  SM_MOUSEWHEELPRESENT = 75;
  SM_CMETRICS = 76;

function GetSystemMetrics(nIndex: Integer): Integer; stdcall;
function LoadMenuA(hInstance: HINST; lpMenuName: PAnsiChar): HMENU; stdcall;
function LoadMenuW(hInstance: HINST; lpMenuName: PAnsiChar): HMENU; stdcall;
function LoadMenu(hInstance: HINST; lpMenuName: PAnsiChar): HMENU; stdcall;
function LoadMenuIndirectA(lpMenuTemplate: Pointer): HMENU; stdcall;
function LoadMenuIndirectW(lpMenuTemplate: Pointer): HMENU; stdcall;
function LoadMenuIndirect(lpMenuTemplate: Pointer): HMENU; stdcall;
function GetMenu(hWnd: HWND): HMENU; stdcall;
function SetMenu(hWnd: HWND; hMenu: HMENU): BOOL; stdcall;
function ChangeMenuA(hMenu: HMENU; cmd: UINT; lpszNewItem: PAnsiChar;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;
function ChangeMenuW(hMenu: HMENU; cmd: UINT; lpszNewItem: PWideChar;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;
function ChangeMenu(hMenu: HMENU; cmd: UINT; lpszNewItem: PTChar;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;
function HiliteMenuItem(hWnd: HWND; hMenu: HMENU; uIDHiliteItem: UINT;
  uHilite: UINT): BOOL; stdcall;
function GetMenuStringA(hMenu: HMENU; uIDItem: UINT; lpString: PAnsiChar;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;
function GetMenuStringW(hMenu: HMENU; uIDItem: UINT; lpString: PWideChar;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;
function GetMenuString(hMenu: HMENU; uIDItem: UINT; lpString: PTChar;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;
function GetMenuState(hMenu: HMENU; uId, uFlags: UINT): UINT; stdcall;
function DrawMenuBar(hWnd: HWND): BOOL; stdcall;
function GetSystemMenu(hWnd: HWND; bRevert: BOOL): HMENU; stdcall;
function CreateMenu: HMENU; stdcall;
function CreatePopupMenu: HMENU; stdcall;
function DestroyMenu(hMenu: HMENU): BOOL; stdcall;
function CheckMenuItem(hMenu: HMENU; uIDCheckItem, uCheck: UINT): DWORD; stdcall;
function EnableMenuItem(hMenu: HMENU; uIDEnableItem, uEnable: UINT): BOOL; stdcall;
function GetSubMenu(hMenu: HMENU; nPos: Integer): HMENU; stdcall;
function GetMenuItemID(hMenu: HMENU; nPos: Integer): UINT; stdcall;
function GetMenuItemCount(hMenu: HMENU): Integer; stdcall;
function InsertMenuA(hMenu: HMENU; uPosition, uFlags, uIDNewItem: UINT;
  lpNewItem: PAnsiChar): BOOL; stdcall;
function InsertMenuW(hMenu: HMENU; uPosition, uFlags, uIDNewItem: UINT;
  lpNewItem: PWideChar): BOOL; stdcall;
function InsertMenu(hMenu: HMENU; uPosition, uFlags, uIDNewItem: UINT;
  lpNewItem: PTChar): BOOL; stdcall;
function AppendMenuA(hMenu: HMENU; uFlags, uIDNewItem: UINT;
  lpNewItem: PAnsiChar): BOOL; stdcall;
function AppendMenuW(hMenu: HMENU; uFlags, uIDNewItem: UINT;
  lpNewItem: PWideChar): BOOL; stdcall;
function AppendMenu(hMenu: HMENU; uFlags, uIDNewItem: UINT;
  lpNewItem: PTChar): BOOL; stdcall;
function ModifyMenuA(hMnu: HMENU; uPosition, uFlags, uIDNewItem: UINT;
  lpNewItem: PAnsiChar): BOOL; stdcall;
function ModifyMenuW(hMnu: HMENU; uPosition, uFlags, uIDNewItem: UINT;
  lpNewItem: PWideChar): BOOL; stdcall;
function ModifyMenu(hMnu: HMENU; uPosition, uFlags, uIDNewItem: UINT;
  lpNewItem: PTChar): BOOL; stdcall;
function RemoveMenu(hMenu: HMENU; uPosition, uFlags: UINT): BOOL; stdcall;
function DeleteMenu(hMenu: HMENU; uPosition, uFlags: UINT): BOOL; stdcall;
function SetMenuItemBitmaps(hMenu: HMENU; uPosition, uFlags: UINT;
  hBitmapUnchecked: HBITMAP; hBitmapChecked: HBITMAP): BOOL; stdcall;
function GetMenuCheckMarkDimensions: Longint; stdcall;
function TrackPopupMenu(hMenu: HMENU; uFlags: UINT; x, y, nReserved: Integer;
  hWnd: HWND; prcRect: PRect): BOOL; stdcall;


const
  { return codes for WM_MENUCHAR }
  MNC_IGNORE = 0;
  MNC_CLOSE = 1;
  MNC_EXECUTE = 2;
  MNC_SELECT = 3;

type
  PTPMParams = ^TTPMParams;
  tagTPMPARAMS = packed record
    cbSize: UINT;     { Size of structure }
    rcExclude: TRect; { Screen coordinates of rectangle to exclude when positioning }
  end;
  TTPMParams = tagTPMPARAMS;
  TPMPARAMS = tagTPMPARAMS;

function TrackPopupMenuEx(hMenu: HMENU; Flags: UINT; x, y: Integer;
  Wnd: HWND; TPMParams: PTPMParams): BOOL; stdcall;

const
  MNS_NOCHECK = $80000000;
  MNS_MODELESS = $40000000;
  MNS_DRAGDROP = $20000000;
  MNS_AUTODISMISS = $10000000;
  MNS_NOTIFYBYPOS = $8000000;
  MNS_CHECKORBMP = $4000000;

  MIM_MAXHEIGHT = 1;
  MIM_BACKGROUND = 2;
  MIM_HELPID = 4;
  MIM_MENUDATA = 8;
  MIM_STYLE = $10;
  MIM_APPLYTOSUBMENUS = $80000000;

type
  PMenuInfo = ^TMenuInfo;
  tagMENUINFO = packed record
    cbSize: DWORD;
    fMask: DWORD;
    dwStyle: DWORD;
    cyMax: UINT;
    hbrBack: HBRUSH;
    dwContextHelpID: DWORD;
    dwMenuData: DWORD;
  end;
  TMenuInfo = tagMENUINFO;

function GetMenuInfo(hMenu: HMENU; var lpmi: TMenuInfo): BOOL; stdcall;
function SetMenuInfo(hMenu: HMENU; const lpcmi: TMenuInfo): BOOL; stdcall;
function EndMenu: BOOL; stdcall;

const
  { WM_MENUDRAG return values }
  MND_CONTINUE = 0;
  MND_ENDMENU = 1;

type
  PMenuGetObjectInfo = ^TMenuGetObjectInfo;
  tagMENUGETOBJECTINFO = packed record
    dwFlags: DWORD;
    uPos: UINT;
    hmenu: HMENU;
    riid: Pointer;
    pvObj: Pointer;
  end;
  TMenuGetObjectInfo = tagMENUGETOBJECTINFO;


const
  { MENUGETOBJECTINFO dwFlags values }
  MNGOF_GAP = 3;

  { MENUGETOBJECT returns values }
  MNGO_NOINTERFACE = 0;
  MNGO_NOERROR = 1;

  MIIM_STATE = 1;
  MIIM_ID = 2;
  MIIM_SUBMENU = 4;
  MIIM_CHECKMARKS = 8;
  MIIM_TYPE = $10;
  MIIM_DATA = $20;
  MIIM_STRING = $40;
  MIIM_BITMAP = $80;
  MIIM_FTYPE = $100;

  HBMMENU_CALLBACK = -1;
  HBMMENU_SYSTEM = 1;
  HBMMENU_MBAR_RESTORE = 2;
  HBMMENU_MBAR_MINIMIZE = 3;
  HBMMENU_MBAR_CLOSE = 5;
  HBMMENU_MBAR_CLOSE_D = 6;
  HBMMENU_MBAR_MINIMIZE_D = 7;
  HBMMENU_POPUP_CLOSE = 8;
  HBMMENU_POPUP_RESTORE = 9;
  HBMMENU_POPUP_MAXIMIZE = 10;
  HBMMENU_POPUP_MINIMIZE = 11;


type
  PMenuItemInfoA = ^TMenuItemInfoA;
  PMenuItemInfoW = ^TMenuItemInfoW;
  PMenuItemInfo = PMenuItemInfoA;
  tagMENUITEMINFOA = packed record
    cbSize: UINT;
    fMask: UINT;
    fType: UINT;             { used if MIIM_TYPE}
    fState: UINT;            { used if MIIM_STATE}
    wID: UINT;               { used if MIIM_ID}
    hSubMenu: HMENU;         { used if MIIM_SUBMENU}
    hbmpChecked: HBITMAP;    { used if MIIM_CHECKMARKS}
    hbmpUnchecked: HBITMAP;  { used if MIIM_CHECKMARKS}
    dwItemData: DWORD;       { used if MIIM_DATA}
    dwTypeData: PAnsiChar;      { used if MIIM_TYPE}
    cch: UINT;               { used if MIIM_TYPE}
    hbmpItem: HBITMAP;       { used if MIIM_BITMAP}
  end;
  tagMENUITEMINFOW = packed record
    cbSize: UINT;
    fMask: UINT;
    fType: UINT;             { used if MIIM_TYPE}
    fState: UINT;            { used if MIIM_STATE}
    wID: UINT;               { used if MIIM_ID}
    hSubMenu: HMENU;         { used if MIIM_SUBMENU}
    hbmpChecked: HBITMAP;    { used if MIIM_CHECKMARKS}
    hbmpUnchecked: HBITMAP;  { used if MIIM_CHECKMARKS}
    dwItemData: DWORD;       { used if MIIM_DATA}
    dwTypeData: PWideChar;      { used if MIIM_TYPE}
    cch: UINT;               { used if MIIM_TYPE}
    hbmpItem: HBITMAP;       { used if MIIM_BITMAP}
  end;
  tagMENUITEMINFO = tagMENUITEMINFOA;
  TMenuItemInfoA = tagMENUITEMINFOA;
  TMenuItemInfoW = tagMENUITEMINFOW;
  TMenuItemInfo = {$ifdef bUnicode}TMenuItemInfoW{$else}TMenuItemInfoA{$endif bUnicode};
  MENUITEMINFOA = tagMENUITEMINFOA;
  MENUITEMINFOW = tagMENUITEMINFOW;
  MENUITEMINFO = MENUITEMINFOA;

function InsertMenuItemA(p1: HMENU; p2: UINT; p3: BOOL; const p4: TMenuItemInfoA): BOOL; stdcall;
function InsertMenuItemW(p1: HMENU; p2: UINT; p3: BOOL; const p4: TMenuItemInfoW): BOOL; stdcall;
function InsertMenuItem(p1: HMENU; p2: UINT; p3: BOOL; const p4: TMenuItemInfo): BOOL; stdcall;
function GetMenuItemInfoA(p1: HMENU; p2: UINT; p3: BOOL; var p4: TMenuItemInfoA): BOOL; stdcall;
function GetMenuItemInfoW(p1: HMENU; p2: UINT; p3: BOOL; var p4: TMenuItemInfoW): BOOL; stdcall;
function GetMenuItemInfo(p1: HMENU; p2: UINT; p3: BOOL; var p4: TMenuItemInfo): BOOL; stdcall;
function SetMenuItemInfoA(p1: HMENU; p2: UINT; p3: BOOL; const p4: TMenuItemInfoA): BOOL; stdcall;
function SetMenuItemInfoW(p1: HMENU; p2: UINT; p3: BOOL; const p4: TMenuItemInfoW): BOOL; stdcall;
function SetMenuItemInfo(p1: HMENU; p2: UINT; p3: BOOL; const p4: TMenuItemInfo): BOOL; stdcall;

const
  GMDI_USEDISABLED = 1;
  GMDI_GOINTOPOPUPS = 2;

function GetMenuDefaultItem(hMenu: HMENU; fByPos, gmdiFlags: UINT): UINT; stdcall;
function SetMenuDefaultItem(hMenu: HMENU; uItem, fByPos: UINT): BOOL; stdcall;
function GetMenuItemRect(hWnd: HWND; hMenu: HMENU; uItem: UINT;
  var lprcItem: TRect): BOOL; stdcall;
function MenuItemFromPoint(hWnd: HWND; hMenu: HMENU; ptScreen: TPoint): BOOL; stdcall;

const
  { Flags for TrackPopupMenu }
  TPM_LEFTBUTTON = 0;
  TPM_RIGHTBUTTON = 2;
  TPM_LEFTALIGN = 0;
  TPM_CENTERALIGN = 4;
  TPM_RIGHTALIGN = 8;
  TPM_TOPALIGN = 0;
  TPM_VCENTERALIGN = $10;
  TPM_BOTTOMALIGN = $20;

  TPM_HORIZONTAL = 0;   { Horz alignment matters more }
  TPM_VERTICAL = $40;   { Vert alignment matters more }
  TPM_NONOTIFY = $80;   { Don't send any notification msgs }
  TPM_RETURNCMD = $100;
  TPM_RECURSE = $1;
  TPM_HORPOSANIMATION = $0400;
  TPM_HORNEGANIMATION = $0800;
  TPM_VERPOSANIMATION = $1000;
  TPM_VERNEGANIMATION = $2000;
  TPM_NOANIMATION     = $4000;


{ Drag-and-drop support }

type
  PDropStruct = ^TDropStruct;
  tagDROPSTRUCT = packed record
    hwndSource: HWND;
    hwndSink: HWND;
    wFmt: DWORD;
    dwData: DWORD;
    ptDrop: TPoint;
    dwControlData: DWORD;
  end;
  TDropStruct = tagDROPSTRUCT;
  DROPSTRUCT = tagDROPSTRUCT;

const
  DOF_EXECUTABLE = 32769;
  DOF_DOCUMENT = 32770;
  DOF_DIRECTORY = 32771;
  DOF_MULTIPLE = 32772;
  DOF_PROGMAN = 1;
  DOF_SHELLDATA = 2;

  DO_DROPFILE = $454C4946;
  DO_PRINTFILE = $544E5250;

function DragObject(p1, p2: HWND; p3: UINT; p4: DWORD;
  p5: HICON): DWORD; stdcall;
function DragDetect(p1: HWND; p2: TPoint): BOOL; stdcall;
function DrawIcon(hDC: HDC; X, Y: Integer; hIcon: HICON): BOOL; stdcall;

const
  { DrawText() Format Flags }
  DT_TOP = 0;
  DT_LEFT = 0;
  DT_CENTER = 1;
  DT_RIGHT = 2;
  DT_VCENTER = 4;
  DT_BOTTOM = 8;
  DT_WORDBREAK = $10;
  DT_SINGLELINE = $20;
  DT_EXPANDTABS = $40;
  DT_TABSTOP = $80;
  DT_NOCLIP = $100;
  DT_EXTERNALLEADING = $200;
  DT_CALCRECT = $400;
  DT_NOPREFIX = $800;
  DT_INTERNAL = $1000;
  DT_HIDEPREFIX = $00100000;
  DT_PREFIXONLY = $00200000;

  DT_EDITCONTROL = $2000;
  DT_PATH_ELLIPSIS = $4000;
  DT_END_ELLIPSIS = $8000;
  DT_MODIFYSTRING = $10000;
  DT_RTLREADING = $20000;
  DT_WORD_ELLIPSIS = $40000;

type
  PDrawTextParams = ^TDrawTextParams;
  tagDRAWTEXTPARAMS = packed record
    cbSize: UINT;
    iTabLength: Integer;
    iLeftMargin: Integer;
    iRightMargin: Integer;
    uiLengthDrawn: UINT;
  end;
  TDrawTextParams = tagDRAWTEXTPARAMS;
  DRAWTEXTPARAMS = tagDRAWTEXTPARAMS;

function DrawTextA(hDC: HDC; lpString: PAnsiChar; nCount: Integer;
  var lpRect: TRect; uFormat: UINT): Integer; stdcall;
function DrawTextW(hDC: HDC; lpString: PWideChar; nCount: Integer;
  var lpRect: TRect; uFormat: UINT): Integer; stdcall;
function DrawText(hDC: HDC; lpString: PTChar; nCount: Integer;
  var lpRect: TRect; uFormat: UINT): Integer; stdcall;
function DrawTextExA(DC: HDC; lpchText: PAnsiChar; cchText: Integer; var p4: TRect;
  dwDTFormat: UINT; DTParams: PDrawTextParams): Integer; stdcall;
function DrawTextExW(DC: HDC; lpchText: PWideChar; cchText: Integer; var p4: TRect;
  dwDTFormat: UINT; DTParams: PDrawTextParams): Integer; stdcall;
function DrawTextEx(DC: HDC; lpchText: PTChar; cchText: Integer; var p4: TRect;
  dwDTFormat: UINT; DTParams: PDrawTextParams): Integer; stdcall;
function GrayStringA(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: TFNGrayStringProc;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;
function GrayStringW(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: TFNGrayStringProc;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;
function GrayString(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: TFNGrayStringProc;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;


{ Monolithic state-drawing routine }

const
  { Image type }
  DST_COMPLEX = 0;
  DST_TEXT = 1;
  DST_PREFIXTEXT = 2;
  DST_ICON = 3;
  DST_BITMAP = 4;

  { State type }
  DSS_NORMAL = 0;
  DSS_UNION = $10;     { Gray string appearance }
  DSS_DISABLED = $20;
  DSS_MONO = $80;
  DSS_RIGHT = $8000;

function DrawStateA(DC: HDC; p2: HBRUSH; p3: TFNDrawStateProc;
  p4: LPARAM; p5: WPARAM; p6, p7, p8, p9: Integer; p10: UINT): BOOL; stdcall;
function DrawStateW(DC: HDC; p2: HBRUSH; p3: TFNDrawStateProc;
  p4: LPARAM; p5: WPARAM; p6, p7, p8, p9: Integer; p10: UINT): BOOL; stdcall;
function DrawState(DC: HDC; p2: HBRUSH; p3: TFNDrawStateProc;
  p4: LPARAM; p5: WPARAM; p6, p7, p8, p9: Integer; p10: UINT): BOOL; stdcall;
function TabbedTextOutA(hDC: HDC; X, Y: Integer; lpString: PAnsiChar; nCount, nTabPositions: Integer;
  var lpnTabStopPositions; nTabOrigin: Integer): Longint; stdcall;
function TabbedTextOutW(hDC: HDC; X, Y: Integer; lpString: PWideChar; nCount, nTabPositions: Integer;
  var lpnTabStopPositions; nTabOrigin: Integer): Longint; stdcall;
function TabbedTextOut(hDC: HDC; X, Y: Integer; lpString: PTChar; nCount, nTabPositions: Integer;
  var lpnTabStopPositions; nTabOrigin: Integer): Longint; stdcall;
function GetTabbedTextExtentA(hDC: HDC; lpString: PAnsiChar;
  nCount, nTabPositions: Integer; var lpnTabStopPositions): DWORD; stdcall;
function GetTabbedTextExtentW(hDC: HDC; lpString: PWideChar;
  nCount, nTabPositions: Integer; var lpnTabStopPositions): DWORD; stdcall;
function GetTabbedTextExtent(hDC: HDC; lpString: PTChar;
  nCount, nTabPositions: Integer; var lpnTabStopPositions): DWORD; stdcall;
function UpdateWindow(hWnd: HWND): BOOL; stdcall;
function SetActiveWindow(hWnd: HWND): HWND; stdcall;
function GetForegroundWindow: HWND; stdcall;
function PaintDesktop(hdc: HDC): BOOL; stdcall;
function SetForegroundWindow(hWnd: HWND): BOOL; stdcall;
function WindowFromDC(hDC: HDC): HWND; stdcall;
function GetDC(hWnd: HWND): HDC; stdcall;
function GetDCEx(hWnd: HWND; hrgnClip: HRGN; flags: DWORD): HDC; stdcall;

const
  { GetDCEx() flags }
  DCX_WINDOW = 1;
  DCX_CACHE = 2;
  DCX_NORESETATTRS = 4;
  DCX_CLIPCHILDREN = 8;
  DCX_CLIPSIBLINGS = $10;
  DCX_PARENTCLIP = $20;
  DCX_EXCLUDERGN = $40;
  DCX_INTERSECTRGN = $80;
  DCX_EXCLUDEUPDATE = $100;
  DCX_INTERSECTUPDATE = $200;
  DCX_LOCKWINDOWUPDATE = $400;
  DCX_VALIDATE = $200000;

function GetWindowDC(hWnd: HWND): HDC; stdcall;
function ReleaseDC(hWnd: HWND; hDC: HDC): Integer; stdcall;
function BeginPaint(hWnd: HWND; var lpPaint: TPaintStruct): HDC; stdcall;
function EndPaint(hWnd: HWND; const lpPaint: TPaintStruct): BOOL; stdcall;
function GetUpdateRect(hWnd: HWND; var lpRect: TRect; bErase: BOOL): BOOL; stdcall;
function GetUpdateRgn(hWnd: HWND; hRgn: HRGN; bErase: BOOL): Integer; stdcall;
function SetWindowRgn(hWnd: HWND; hRgn: HRGN; bRedraw: BOOL): Integer; stdcall;
function GetWindowRgn(hWnd: HWND; hRgn: HRGN): Integer; stdcall;
function ExcludeUpdateRgn(hDC: HDC; hWnd: HWND): Integer; stdcall;
function InvalidateRect(hWnd: HWND; lpRect: PRect; bErase: BOOL): BOOL; stdcall;
function ValidateRect(hWnd: HWND; lpRect: PRect): BOOL; stdcall;
function InvalidateRgn(hWnd: HWND; hRgn: HRGN; bErase: BOOL): BOOL; stdcall;
function ValidateRgn(hWnd: HWND; hRgn: HRGN): BOOL; stdcall;
function RedrawWindow(hWnd: HWND; lprcUpdate: PRect; hrgnUpdate: HRGN; flags: UINT): BOOL; stdcall;

const
  { RedrawWindow() flags }
  RDW_INVALIDATE = 1;
  RDW_INTERNALPAINT = 2;
  RDW_ERASE = 4;
  RDW_VALIDATE = 8;
  RDW_NOINTERNALPAINT = $10;
  RDW_NOERASE = $20;
  RDW_NOCHILDREN = $40;
  RDW_ALLCHILDREN = $80;
  RDW_UPDATENOW = $100;
  RDW_ERASENOW = $200;
  RDW_FRAME = $400;
  RDW_NOFRAME = $800;


{ LockWindowUpdate API }

function LockWindowUpdate(hWndLock: HWND): BOOL; stdcall;
function ScrollWindow(hWnd: HWND; XAmount, YAmount: Integer;
  Rect, ClipRect: PRect): BOOL; stdcall;
function ScrollDC(DC: HDC; DX, DY: Integer; var Scroll, Clip: TRect; Rgn: HRGN;
  Update: PRect): BOOL; stdcall;
function ScrollWindowEx(hWnd: HWND; dx, dy: Integer;
  prcScroll, prcClip: PRect;
  hrgnUpdate: HRGN; prcUpdate: PRect; flags: UINT): BOOL; stdcall;

const
  SW_SCROLLCHILDREN = 1;  { Scroll children within lprcScroll. }
  SW_INVALIDATE = 2;      { Invalidate after scrolling }
  SW_ERASE = 4;           { If SW_INVALIDATE, don't send WM_ERASEBACKGROUND }
  SW_SMOOTHSCROLL = $10;   { Use smooth scrolling }

function SetScrollPos(hWnd: HWND; nBar, nPos: Integer; bRedraw: BOOL): Integer; stdcall;
function GetScrollPos(hWnd: HWND; nBar: Integer): Integer; stdcall;
function SetScrollRange(hWnd: HWND; nBar, nMinPos, nMaxPos: Integer; bRedraw: BOOL): BOOL; stdcall;
function GetScrollRange(hWnd: HWND; nBar: Integer; var lpMinPos, lpMaxPos: Integer): BOOL; stdcall;
function ShowScrollBar(hWnd: HWND; wBar: Integer; bShow: BOOL): BOOL; stdcall;
function EnableScrollBar(hWnd: HWND; wSBflags, wArrows: UINT): BOOL; stdcall;


const
  { EnableScrollBar() flags }
  ESB_ENABLE_BOTH = 0;
  ESB_DISABLE_BOTH = 3;
  ESB_DISABLE_LEFT = 1;
  ESB_DISABLE_RIGHT = 2;
  ESB_DISABLE_UP = 1;
  ESB_DISABLE_DOWN = 2;
  ESB_DISABLE_LTUP = ESB_DISABLE_LEFT;
  ESB_DISABLE_RTDN = ESB_DISABLE_RIGHT;

function SetPropA(hWnd: HWND; lpString: PAnsiChar; hData: THandle): BOOL; stdcall;
function SetPropW(hWnd: HWND; lpString: PWideChar; hData: THandle): BOOL; stdcall;
function SetProp(hWnd: HWND; lpString: PTChar; hData: THandle): BOOL; stdcall;
function GetPropA(hWnd: HWND; lpString: PAnsiChar): THandle; stdcall;
function GetPropW(hWnd: HWND; lpString: PWideChar): THandle; stdcall;
function GetProp(hWnd: HWND; lpString: PTChar): THandle; stdcall;
function RemovePropA(hWnd: HWND; lpString: PAnsiChar): THandle; stdcall;
function RemovePropW(hWnd: HWND; lpString: PWideChar): THandle; stdcall;
function RemoveProp(hWnd: HWND; lpString: PTChar): THandle; stdcall;
function EnumPropsExA(hWnd: HWND; lpEnumFunc: TFNPropEnumProcEx; lParam: LPARAM): Integer; stdcall;
function EnumPropsExW(hWnd: HWND; lpEnumFunc: TFNPropEnumProcEx; lParam: LPARAM): Integer; stdcall;
function EnumPropsEx(hWnd: HWND; lpEnumFunc: TFNPropEnumProcEx; lParam: LPARAM): Integer; stdcall;
function EnumPropsA(hWnd: HWND; lpEnumFunc: TFNPropEnumProc): Integer; stdcall;
function EnumPropsW(hWnd: HWND; lpEnumFunc: TFNPropEnumProc): Integer; stdcall;
function EnumProps(hWnd: HWND; lpEnumFunc: TFNPropEnumProc): Integer; stdcall;
function SetWindowTextA(hWnd: HWND; lpString: PAnsiChar): BOOL; stdcall;
function SetWindowTextW(hWnd: HWND; lpString: PWideChar): BOOL; stdcall;
function SetWindowText(hWnd: HWND; lpString: PTChar): BOOL; stdcall;
function GetWindowTextA(hWnd: HWND; lpString: PAnsiChar; nMaxCount: Integer): Integer; stdcall;
function GetWindowTextW(hWnd: HWND; lpString: PWideChar; nMaxCount: Integer): Integer; stdcall;
function GetWindowText(hWnd: HWND; lpString: PTChar; nMaxCount: Integer): Integer; stdcall;
function GetWindowTextLengthA(hWnd: HWND): Integer; stdcall;
function GetWindowTextLengthW(hWnd: HWND): Integer; stdcall;
function GetWindowTextLength(hWnd: HWND): Integer; stdcall;

function GetClientRect(hWnd: HWND; var lpRect: TRect): BOOL; stdcall;
function GetWindowRect(hWnd: HWND; var lpRect: TRect): BOOL; stdcall;
function AdjustWindowRect(var lpRect: TRect; dwStyle: DWORD; bMenu: BOOL): BOOL; stdcall;
function AdjustWindowRectEx(var lpRect: TRect; dwStyle: DWORD; bMenu: BOOL;
  dwExStyle: DWORD): BOOL; stdcall;

const
  HELPINFO_WINDOW = 1;
  HELPINFO_MENUITEM = 2;
type
  PHelpInfo = ^THelpInfo;
  tagHELPINFO = packed record       { Structure pointed to by lParam of WM_HELP }
    cbSize: UINT;          { Size in bytes of this struct  }
    iContextType: Integer; { Either HELPINFO_WINDOW or HELPINFO_MENUITEM }
    iCtrlId: Integer;      { Control Id or a Menu item Id. }
    hItemHandle: THandle;  { hWnd of control or hMenu.     }
    dwContextId: DWORD;    { Context Id associated with this item }
    MousePos: TPoint;      { Mouse Position in screen co-ordinates }
  end;
  THelpInfo = tagHELPINFO;
  HELPINFO = tagHELPINFO;

function SetWindowContextHelpId(hWnd: HWND; HelpID: DWORD): BOOL; stdcall;
function GetWindowContextHelpId(hWnd: HWND): DWORD; stdcall;
function SetMenuContextHelpId(hMenu: HMENU; HelpID: DWORD): BOOL; stdcall;
function GetMenuContextHelpId(hMenu: HMENU): DWORD; stdcall;

const
  { MessageBox() Flags }
  MB_OK = $00000000;
  MB_OKCANCEL = $00000001;
  MB_ABORTRETRYIGNORE = $00000002;
  MB_YESNOCANCEL = $00000003;
  MB_YESNO = $00000004;
  MB_RETRYCANCEL = $00000005;

  MB_ICONHAND = $00000010;
  MB_ICONQUESTION = $00000020;
  MB_ICONEXCLAMATION = $00000030;
  MB_ICONASTERISK = $00000040;
  MB_USERICON = $00000080;
  MB_ICONWARNING                 = MB_ICONEXCLAMATION;
  MB_ICONERROR                   = MB_ICONHAND;
  MB_ICONINFORMATION             = MB_ICONASTERISK;
  MB_ICONSTOP                    = MB_ICONHAND;

  MB_DEFBUTTON1 = $00000000;
  MB_DEFBUTTON2 = $00000100;
  MB_DEFBUTTON3 = $00000200;
  MB_DEFBUTTON4 = $00000300;

  MB_APPLMODAL = $00000000;
  MB_SYSTEMMODAL = $00001000;
  MB_TASKMODAL = $00002000;
  MB_HELP = $00004000;                          { Help Button }

  MB_NOFOCUS = $00008000;
  MB_SETFOREGROUND = $00010000;
  MB_DEFAULT_DESKTOP_ONLY = $00020000;

  MB_TOPMOST = $00040000;
  MB_RIGHT = $00080000;
  MB_RTLREADING = $00100000;

  MB_SERVICE_NOTIFICATION = $00200000;
  MB_SERVICE_NOTIFICATION_NT3X = $00040000;

  MB_TYPEMASK = $0000000F;
  MB_ICONMASK = $000000F0;
  MB_DEFMASK = $00000F00;
  MB_MODEMASK = $00003000;
  MB_MISCMASK = $0000C000;


function MessageBoxA(hWnd: HWND; lpText, lpCaption: PAnsiChar; uType: UINT): Integer; stdcall;
function MessageBoxW(hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;
function MessageBox(hWnd: HWND; lpText, lpCaption: PTChar; uType: UINT): Integer; stdcall;
function MessageBoxExA(hWnd: HWND; lpText, lpCaption: PAnsiChar;
  uType: UINT; wLanguageId: Word): Integer; stdcall;
function MessageBoxExW(hWnd: HWND; lpText, lpCaption: PWideChar;
  uType: UINT; wLanguageId: Word): Integer; stdcall;
function MessageBoxEx(hWnd: HWND; lpText, lpCaption: PTChar;
  uType: UINT; wLanguageId: Word): Integer; stdcall;

type
  TPRMsgBoxCallback = procedure(var lpHelpInfo: THelpInfo);

  PMsgBoxParamsA = ^TMsgBoxParamsA;
  PMsgBoxParamsW = ^TMsgBoxParamsW;
  PMsgBoxParams = PMsgBoxParamsA;
  tagMSGBOXPARAMSA = packed record
    cbSize: UINT;
    hwndOwner: HWND;
    hInstance: HINST;
    lpszText: PAnsiChar;
    lpszCaption: PAnsiChar;
    dwStyle: DWORD;
    lpszIcon: PAnsiChar;
    dwContextHelpId: DWORD;
    lpfnMsgBoxCallback: TPRMsgBoxCallback;
    dwLanguageId: DWORD;
  end;
  tagMSGBOXPARAMSW = packed record
    cbSize: UINT;
    hwndOwner: HWND;
    hInstance: HINST;
    lpszText: PWideChar;
    lpszCaption: PWideChar;
    dwStyle: DWORD;
    lpszIcon: PWideChar;
    dwContextHelpId: DWORD;
    lpfnMsgBoxCallback: TPRMsgBoxCallback;
    dwLanguageId: DWORD;
  end;
  tagMSGBOXPARAMS = tagMSGBOXPARAMSA;
  TMsgBoxParamsA = tagMSGBOXPARAMSA;
  TMsgBoxParamsW = tagMSGBOXPARAMSW;
  TMsgBoxParams = TMsgBoxParamsA;
  MSGBOXPARAMSA = tagMSGBOXPARAMSA;
  MSGBOXPARAMSW = tagMSGBOXPARAMSW;
  MSGBOXPARAMS = MSGBOXPARAMSA;

function MessageBoxIndirectA(const MsgBoxParams: TMsgBoxParamsA): BOOL; stdcall;
function MessageBoxIndirectW(const MsgBoxParams: TMsgBoxParamsW): BOOL; stdcall;
function MessageBoxIndirect(const MsgBoxParams: TMsgBoxParams): BOOL; stdcall;

function MessageBeep(uType: UINT): BOOL; stdcall;
function ShowCursor(bShow: BOOL): Integer; stdcall;
function SetCursorPos(X, Y: Integer): BOOL; stdcall;
function SetCursor(hCursor: HICON): HCURSOR; stdcall;
function GetCursorPos(var lpPoint: TPoint): BOOL; stdcall;
function ClipCursor(lpRect: PRect): BOOL; stdcall;
function GetClipCursor(var lpRect: TRect): BOOL; stdcall;
function GetCursor: HCURSOR; stdcall;
function CreateCaret(hWnd: HWND; hBitmap: HBITMAP; nWidth, nHeight: Integer): BOOL; stdcall;
function GetCaretBlinkTime: UINT; stdcall;
function SetCaretBlinkTime(uMSeconds: UINT): BOOL; stdcall;
function DestroyCaret: BOOL; stdcall;
function HideCaret(hWnd: HWND): BOOL; stdcall;
function ShowCaret(hWnd: HWND): BOOL; stdcall;
function SetCaretPos(X, Y: Integer): BOOL; stdcall;
function GetCaretPos(var lpPoint: TPoint): BOOL; stdcall;
function ClientToScreen(hWnd: HWND; var lpPoint: TPoint): BOOL; stdcall;
function ScreenToClient(hWnd: HWND; var lpPoint: TPoint): BOOL; stdcall;
function MapWindowPoints(hWndFrom, hWndTo: HWND; var lpPoints; cPoints: UINT): Integer; stdcall;
function WindowFromPoint(Point: TPoint): HWND; stdcall;
function ChildWindowFromPoint(hWndParent: HWND; Point: TPoint): HWND; stdcall;

const
  CWP_ALL = 0;
  CWP_SKIPINVISIBLE = 1;
  CWP_SKIPDISABLED = 2;
  CWP_SKIPTRANSPARENT = 4;

function ChildWindowFromPointEx(hWnd: HWND; Point: TPoint; Flags: UINT): HWND; stdcall;

const
  { Color Types }
  CTLCOLOR_MSGBOX = 0;
  CTLCOLOR_EDIT = 1;
  CTLCOLOR_LISTBOX = 2;
  CTLCOLOR_BTN = 3;
  CTLCOLOR_DLG = 4;
  CTLCOLOR_SCROLLBAR = 5;
  CTLCOLOR_STATIC = 6;
  CTLCOLOR_MAX = 7;

  COLOR_SCROLLBAR = 0;
  COLOR_BACKGROUND = 1;
  COLOR_ACTIVECAPTION = 2;
  COLOR_INACTIVECAPTION = 3;
  COLOR_MENU = 4;
  COLOR_WINDOW = 5;
  COLOR_WINDOWFRAME = 6;
  COLOR_MENUTEXT = 7;
  COLOR_WINDOWTEXT = 8;
  COLOR_CAPTIONTEXT = 9;
  COLOR_ACTIVEBORDER = 10;
  COLOR_INACTIVEBORDER = 11;
  COLOR_APPWORKSPACE = 12;
  COLOR_HIGHLIGHT = 13;
  COLOR_HIGHLIGHTTEXT = 14;
  COLOR_BTNFACE = 15;
  COLOR_BTNSHADOW = $10;
  COLOR_GRAYTEXT = 17;
  COLOR_BTNTEXT = 18;
  COLOR_INACTIVECAPTIONTEXT = 19;
  COLOR_BTNHIGHLIGHT = 20;

  COLOR_3DDKSHADOW = 21;
  COLOR_3DLIGHT = 22;
  COLOR_INFOTEXT = 23;
  COLOR_INFOBK = 24;
  COLOR_HOTLIGHT = 26;
  COLOR_GRADIENTACTIVECAPTION = 27;
  COLOR_GRADIENTINACTIVECAPTION = 28;
  COLOR_ENDCOLORS = COLOR_GRADIENTINACTIVECAPTION;
  COLOR_DESKTOP = COLOR_BACKGROUND;
  COLOR_3DFACE = COLOR_BTNFACE;
  COLOR_3DSHADOW = COLOR_BTNSHADOW;
  COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_3DHILIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_BTNHILIGHT = COLOR_BTNHIGHLIGHT;

function GetSysColor(nIndex: Integer): DWORD; stdcall;
function GetSysColorBrush(nIndex: Integer): HBRUSH; stdcall;
function SetSysColors(cElements: Integer; const lpaElements;
  const lpaRgbValues): BOOL; stdcall;
function DrawFocusRect(hDC: HDC; const lprc: TRect): BOOL; stdcall;
function FillRect(hDC: HDC; const lprc: TRect; hbr: HBRUSH): Integer; stdcall;
function FrameRect(hDC: HDC; const lprc: TRect; hbr: HBRUSH): Integer; stdcall;
function InvertRect(hDC: HDC; const lprc: TRect): BOOL; stdcall;
function SetRect(var lprc: TRect; xLeft, yTop, xRight, yBottom: Integer): BOOL; stdcall;
function SetRectEmpty(var lprc: TRect): BOOL; stdcall;
function CopyRect(var lprcDst: TRect; const lprcSrc: TRect): BOOL; stdcall;
function InflateRect(var lprc: TRect; dx, dy: Integer): BOOL; stdcall;
function IntersectRect(var lprcDst: TRect; const lprcSrc1, lprcSrc2: TRect): BOOL; stdcall;
function UnionRect(var lprcDst: TRect; const lprcSrc1, lprcSrc2: TRect): BOOL; stdcall;
function SubtractRect(var lprcDst: TRect; const lprcSrc1, lprcSrc2: TRect): BOOL; stdcall;
function OffsetRect(var lprc: TRect; dx, dy: Integer): BOOL; stdcall;
function IsRectEmpty(const lprc: TRect): BOOL; stdcall;
function EqualRect(const lprc1, lprc2: TRect): BOOL; stdcall;
function PtInRect(const lprc: TRect; pt: TPoint): BOOL; stdcall;
function GetWindowWord(hWnd: HWND; nIndex: Integer): Word; stdcall;
function SetWindowWord(hWnd: HWND; nIndex: Integer; wNewWord: Word): Word; stdcall;
function GetWindowLongA(hWnd: HWND; nIndex: Integer): Longint; stdcall;
function GetWindowLongW(hWnd: HWND; nIndex: Integer): Longint; stdcall;
function GetWindowLong(hWnd: HWND; nIndex: Integer): Longint; stdcall;
function SetWindowLongA(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint; stdcall;
function SetWindowLongW(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint; stdcall;
function SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint; stdcall;
function GetClassWord(hWnd: HWND; nIndex: Integer): Word; stdcall;
function SetClassWord(hWnd: HWND; nIndex: Integer; wNewWord: Word): Word; stdcall;
function GetClassLongA(hWnd: HWND; nIndex: Integer): DWORD; stdcall;
function GetClassLongW(hWnd: HWND; nIndex: Integer): DWORD; stdcall;
function GetClassLong(hWnd: HWND; nIndex: Integer): DWORD; stdcall;
function SetClassLongA(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): DWORD; stdcall;
function SetClassLongW(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): DWORD; stdcall;
function SetClassLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): DWORD; stdcall;
function GetDesktopWindow: HWND; stdcall;
function GetParent(hWnd: HWND): HWND; stdcall;
function SetParent(hWndChild, hWndNewParent: HWND): HWND; stdcall;
function EnumChildWindows(hWndParent: HWND; lpEnumFunc: TFNWndEnumProc;
  lParam: LPARAM): BOOL; stdcall;
function FindWindowA(lpClassName, lpWindowName: PAnsiChar): HWND; stdcall;
function FindWindowW(lpClassName, lpWindowName: PWideChar): HWND; stdcall;
function FindWindow(lpClassName, lpWindowName: PTChar): HWND; stdcall;
function FindWindowExA(Parent, Child: HWND; ClassName, WindowName: PAnsiChar): HWND; stdcall;
function FindWindowExW(Parent, Child: HWND; ClassName, WindowName: PWideChar): HWND; stdcall;
function FindWindowEx(Parent, Child: HWND; ClassName, WindowName: PTChar): HWND; stdcall;
function EnumWindows(lpEnumFunc: TFNWndEnumProc; lParam: LPARAM): BOOL; stdcall;
function EnumThreadWindows(dwThreadId: DWORD; lpfn: TFNWndEnumProc; lParam: LPARAM): BOOL; stdcall;
function EnumTaskWindows(hTask: THandle; lpfn: FARPROC; lParam: LPARAM): BOOL;
function GetClassNameA(hWnd: HWND; lpClassName: PAnsiChar; nMaxCount: Integer): Integer; stdcall;
function GetClassNameW(hWnd: HWND; lpClassName: PWideChar; nMaxCount: Integer): Integer; stdcall;
function GetClassName(hWnd: HWND; lpClassName: PTChar; nMaxCount: Integer): Integer; stdcall;
function GetTopWindow(hWnd: HWND): HWND; stdcall;
function GetNextWindow(hWnd: HWND; uCmd: UINT): HWND; stdcall;
function GetWindowThreadProcessId(hWnd: HWND; lpdwProcessId: Pointer): DWORD; stdcall;
function GetWindowTask(hWnd: HWND): THandle;
function GetLastActivePopup(hWnd: HWND): HWND; stdcall;

const
  { GetWindow() Constants }
  GW_HWNDFIRST = 0;
  GW_HWNDLAST = 1;
  GW_HWNDNEXT = 2;
  GW_HWNDPREV = 3;
  GW_OWNER = 4;
  GW_CHILD = 5;
  GW_MAX = 5;

function GetWindow(hWnd: HWND; uCmd: UINT): HWND; stdcall;
function SetWindowsHookA(nFilterType: Integer; pfnFilterProc: TFNHookProc): HHOOK; stdcall;
function SetWindowsHookW(nFilterType: Integer; pfnFilterProc: TFNHookProc): HHOOK; stdcall;
function SetWindowsHook(nFilterType: Integer; pfnFilterProc: TFNHookProc): HHOOK; stdcall;
function SetWindowsHookExA(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall;
function SetWindowsHookExW(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall;
function SetWindowsHookEx(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall;
function UnhookWindowsHook(nCode: Integer; pfnFilterProc: TFNHookProc): BOOL; stdcall;
function UnhookWindowsHookEx(hhk: HHOOK): BOOL; stdcall;
function CallNextHookEx(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{ Macros for source-level compatibility with old functions. }

function DefHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM; phhk: FARPROC): LRESULT;

const
{ Menu flags for AddCheckEnableMenuItem() }

  MF_INSERT = 0;
  MF_CHANGE = $80;
  MF_APPEND = $100;
  MF_DELETE = $200;
  MF_REMOVE = $1000;

  MF_BYCOMMAND = 0;
  MF_BYPOSITION = $400;

  MF_SEPARATOR = $800;

  MF_ENABLED = 0;
  MF_GRAYED = 1;
  MF_DISABLED = 2;

  MF_UNCHECKED = 0;
  MF_CHECKED = 8;
  MF_USECHECKBITMAPS = $200;

  MF_STRING = 0;
  MF_BITMAP = 4;
  MF_OWNERDRAW = $100;

  MF_POPUP = $10;
  MF_MENUBARBREAK = $20;
  MF_MENUBREAK = $40;

  MF_UNHILITE = 0;
  MF_HILITE = $80;

  MF_DEFAULT = $1000;
  MF_SYSMENU = $2000;
  MF_HELP = $4000;
  MF_RIGHTJUSTIFY = $4000;

  MF_MOUSESELECT = $8000;
  MF_END = $80;            { Obsolete -- only used by old RES files }

  MFT_STRING = MF_STRING;
  MFT_BITMAP = MF_BITMAP;
  MFT_MENUBARBREAK = MF_MENUBARBREAK;
  MFT_MENUBREAK = MF_MENUBREAK;
  MFT_OWNERDRAW = MF_OWNERDRAW;
  MFT_RADIOCHECK = $200;
  MFT_SEPARATOR = MF_SEPARATOR;
  MFT_RIGHTORDER = $2000;
  MFT_RIGHTJUSTIFY = MF_RIGHTJUSTIFY;

  { Menu flags for AddCheckEnableMenuItem() }
  MFS_GRAYED = 3;
  MFS_DISABLED = MFS_GRAYED;
  MFS_CHECKED = MF_CHECKED;
  MFS_HILITE = MF_HILITE;
  MFS_ENABLED = MF_ENABLED;
  MFS_UNCHECKED = MF_UNCHECKED;
  MFS_UNHILITE = MF_UNHILITE;
  MFS_DEFAULT = MF_DEFAULT;

  MFS_MASK = $108B;
  MFS_HOTTRACKDRAWN = $10000000;
  MFS_CACHEDBMP = $20000000;
  MFS_BOTTOMGAPDROP = $40000000;
  MFS_TOPGAPDROP = $80000000;
  MFS_GAPDROP = $C0000000;

function CheckMenuRadioItem(hMenu: HMENU; First, Last, Check, Flags: UINT): BOOL; stdcall;

type
  { Menu item resource format }
  PMenuItemTemplateHeader = ^TMenuItemTemplateHeader;
  MENUITEMTEMPLATEHEADER = packed record
    versionNumber: Word;
    offset: Word;
  end;
  TMenuItemTemplateHeader = MENUITEMTEMPLATEHEADER;

  PMenuItemTemplate = ^TMenuItemTemplate;
  MENUITEMTEMPLATE = packed record {Version 0}
    mtOption: Word;
    mtID: Word;
    mtString: array[0..0] of WCHAR;
  end;
  TMenuItemTemplate = MENUITEMTEMPLATE;


const
  { System Menu Command Values }
  SC_SIZE = 61440;
  SC_MOVE = 61456;
  SC_MINIMIZE = 61472;
  SC_MAXIMIZE = 61488;
  SC_NEXTWINDOW = 61504;
  SC_PREVWINDOW = 61520;
  SC_CLOSE = 61536;
  SC_VSCROLL = 61552;
  SC_HSCROLL = 61568;
  SC_MOUSEMENU = 61584;
  SC_KEYMENU = 61696;
  SC_ARRANGE = 61712;
  SC_RESTORE = 61728;
  SC_TASKLIST = 61744;
  SC_SCREENSAVE = 61760;
  SC_HOTKEY = 61776;
  SC_DEFAULT = 61792;
  SC_MONITORPOWER = 61808;
  SC_CONTEXTHELP = 61824;
  SC_SEPARATOR = 61455;

  { Obsolete names }
  SC_ICON = SC_MINIMIZE;
  SC_ZOOM = SC_MAXIMIZE;

{ Resource Loading Routines }

function LoadBitmapA(hInstance: HINST; lpBitmapName: PAnsiChar): HBITMAP; stdcall;
function LoadBitmapW(hInstance: HINST; lpBitmapName: PWideChar): HBITMAP; stdcall;
function LoadBitmap(hInstance: HINST; lpBitmapName: PTChar): HBITMAP; stdcall;
function LoadCursorA(hInstance: HINST; lpCursorName: PAnsiChar): HCURSOR; stdcall;
function LoadCursorW(hInstance: HINST; lpCursorName: PWideChar): HCURSOR; stdcall;
function LoadCursor(hInstance: HINST; lpCursorName: PTChar): HCURSOR; stdcall;
function LoadCursorFromFileA(lpFileName: PAnsiChar): HCURSOR; stdcall;
function LoadCursorFromFileW(lpFileName: PWideChar): HCURSOR; stdcall;
function LoadCursorFromFile(lpFileName: PTChar): HCURSOR; stdcall;
function CreateCursor(hInst: HINST; xHotSpot, yHotSpot, nWidth, nHeight: Integer;
  pvANDPlaneter, pvXORPlane: Pointer): HCURSOR; stdcall;
function DestroyCursor(hCursor: HICON): BOOL; stdcall;

const
  { Standard Cursor IDs }
  IDC_ARROW = MakeIntResource(32512);
  IDC_IBEAM = MakeIntResource(32513);
  IDC_WAIT = MakeIntResource(32514);
  IDC_CROSS = MakeIntResource(32515);
  IDC_UPARROW = MakeIntResource(32516);
  IDC_SIZE = MakeIntResource(32640);
  IDC_ICON = MakeIntResource(32641);
  IDC_SIZENWSE = MakeIntResource(32642);
  IDC_SIZENESW = MakeIntResource(32643);
  IDC_SIZEWE = MakeIntResource(32644);
  IDC_SIZENS = MakeIntResource(32645);
  IDC_SIZEALL = MakeIntResource(32646);
  IDC_NO = MakeIntResource(32648);
  IDC_HAND = MakeIntResource(32649);
  IDC_APPSTARTING = MakeIntResource(32650);
  IDC_HELP = MakeIntResource(32651);

function SetSystemCursor(hcur: HICON; id: DWORD): BOOL; stdcall;

type
  PIconInfo = ^TIconInfo;
  _ICONINFO = record
    fIcon: BOOL;
    xHotspot: DWORD;
    yHotspot: DWORD;
    hbmMask: HBITMAP;
    hbmColor: HBITMAP;
  end;
  TIconInfo = _ICONINFO;
  ICONINFO = _ICONINFO;

function LoadIconA(hInstance: HINST; lpIconName: PAnsiChar): HICON; stdcall;
function LoadIconW(hInstance: HINST; lpIconName: PWideChar): HICON; stdcall;
function LoadIcon(hInstance: HINST; lpIconName: PTChar): HICON; stdcall;
function CreateIcon(hInstance: HINST; nWidth, nHeight: Integer;
  cPlanes, cBitsPixel: Byte; lpbANDbits, lpbXORbits: Pointer): HICON; stdcall;
function DestroyIcon(hIcon: HICON): BOOL; stdcall;
function LookupIconIdFromDirectory(presbits: PByte; fIcon: BOOL): Integer; stdcall;
function LookupIconIdFromDirectoryEx(presbits: PByte; fIcon: BOOL;
  cxDesired, cyDesired: Integer; Flags: UINT): Integer; stdcall;
function CreateIconFromResource(presbits: PByte; dwResSize: DWORD;
  fIcon: BOOL; dwVer: DWORD): HICON; stdcall;
function CreateIconFromResourceEx(presbits: PByte; dwResSize: DWORD;
  fIcon: BOOL; dwVer: DWORD; cxDesired, cyDesired: Integer; Flags: UINT): HICON; stdcall;


type
  { IconCursor header }
  PCursorShape = ^TCursorShape;
  tagCURSORSHAPE = record
    xHotSpot: Integer;
    yHotSpot: Integer;
    cx: Integer;
    cy: Integer;
    cbWidth: Integer;
    Planes: Byte;
    BitsPixel: Byte;
  end;
  TCursorShape = tagCURSORSHAPE;
  CURSORSHAPE = tagCURSORSHAPE;

const
  IMAGE_BITMAP = 0;
  IMAGE_ICON = 1;
  IMAGE_CURSOR = 2;
  IMAGE_ENHMETAFILE = 3;

  LR_DEFAULTCOLOR = $0000;
  LR_MONOCHROME = $0001;
  LR_COLOR = $0002;
  LR_COPYRETURNORG = $0004;
  LR_COPYDELETEORG = $0008;
  LR_LOADFROMFILE = $0010;
  LR_LOADTRANSPARENT = $0020;
  LR_DEFAULTSIZE = $0040;
  LR_VGACOLOR = $0080;
  LR_LOADMAP3DCOLORS = $1000;
  LR_CREATEDIBSECTION = $2000;
  LR_COPYFROMRESOURCE = $4000;
  LR_SHARED = $8000;

function LoadImageA(hInst: HINST; ImageName: PAnsiChar; ImageType: UINT; X, Y: Integer; Flags: UINT): THandle; stdcall;
function LoadImageW(hInst: HINST; ImageName: PWideChar; ImageType: UINT; X, Y: Integer; Flags: UINT): THandle; stdcall;
function LoadImage(hInst: HINST; ImageName: PTChar; ImageType: UINT; X, Y: Integer; Flags: UINT): THandle; stdcall;
function CopyImage(hImage: THandle; ImageType: UINT; X, Y: Integer; Flags: UINT): THandle; stdcall;

const
  DI_MASK = 1;
  DI_IMAGE = 2;
  DI_NORMAL = 3;
  DI_COMPAT = 4;
  DI_DEFAULTSIZE = 8;

function DrawIconEx(hdc: HDC; xLeft, yTop: Integer; hIcon: HICON;
  cxWidth, cyWidth: Integer; istepIfAniCur: UINT;
  hbrFlickerFreeDraw: HBRUSH; diFlags: UINT): BOOL; stdcall;
function CreateIconIndirect(var piconinfo: TIconInfo): HICON; stdcall;
function CopyIcon(hIcon: HICON): HICON; stdcall;
function GetIconInfo(hIcon: HICON; var piconinfo: TIconInfo): BOOL; stdcall;

const
  OBM_CLOSE               = 32754;
  OBM_UPARROW             = 32753;
  OBM_DNARROW             = 32752;
  OBM_RGARROW             = 32751;
  OBM_LFARROW             = 32750;
  OBM_REDUCE              = 32749;
  OBM_ZOOM                = 32748;
  OBM_RESTORE             = 32747;
  OBM_REDUCED             = 32746;
  OBM_ZOOMD               = 32745;
  OBM_RESTORED            = 32744;
  OBM_UPARROWD            = 32743;
  OBM_DNARROWD            = 32742;
  OBM_RGARROWD            = 32741;
  OBM_LFARROWD            = 32740;
  OBM_MNARROW             = 32739;
  OBM_COMBO               = 32738;
  OBM_UPARROWI            = 32737;
  OBM_DNARROWI            = 32736;
  OBM_RGARROWI            = 32735;
  OBM_LFARROWI            = 32734;

  OBM_OLD_CLOSE           = 32767;
  OBM_SIZE                = 32766;
  OBM_OLD_UPARROW         = 32765;
  OBM_OLD_DNARROW         = 32764;
  OBM_OLD_RGARROW         = 32763;
  OBM_OLD_LFARROW         = 32762;
  OBM_BTSIZE              = 32761;
  OBM_CHECK               = 32760;
  OBM_CHECKBOXES          = 32759;
  OBM_BTNCORNERS          = 32758;
  OBM_OLD_REDUCE          = 32757;
  OBM_OLD_ZOOM            = 32756;
  OBM_OLD_RESTORE         = 32755;

  OCR_NORMAL              = 32512;
  OCR_IBEAM               = 32513;
  OCR_WAIT                = 32514;
  OCR_CROSS               = 32515;
  OCR_UP                  = 32516;
  OCR_SIZE                = 32640;  { OBSOLETE: use OCR_SIZEALL }
  OCR_ICON                = 32641;  { OBSOLETE: use OCR_NORMAL }
  OCR_SIZENWSE            = 32642;
  OCR_SIZENESW            = 32643;
  OCR_SIZEWE              = 32644;
  OCR_SIZENS              = 32645;
  OCR_SIZEALL             = 32646;
  OCR_ICOCUR              = 32647;  { OBSOLETE: use OIC_WINLOGO }
  OCR_NO                  = 32648;
  OCR_HAND                  = 32649;
  OCR_APPSTARTING         = 32650;

  OIC_SAMPLE              = 32512;
  OIC_HAND                = 32513;
  OIC_QUES                = 32514;
  OIC_BANG                = 32515;
  OIC_NOTE                = 32516;
  OIC_WINLOGO             = 32517;
  OIC_WARNING             = OIC_BANG;
  OIC_ERROR               = OIC_HAND;
  OIC_INFORMATION         = OIC_NOTE;

  RES_ICON = 1;
  RES_CURSOR = 2;

  { The ordinal number for the entry point of language drivers. }
  ORD_LANGDRIVER = 1;

  { Standard Icon IDs }
  IDI_APPLICATION = MakeIntResource(32512);
  IDI_HAND = MakeIntResource(32513);
  IDI_QUESTION = MakeIntResource(32514);
  IDI_EXCLAMATION = MakeIntResource(32515);
  IDI_ASTERISK = MakeIntResource(32516);
  IDI_WINLOGO = MakeIntResource(32517);
  IDI_WARNING = IDI_EXCLAMATION;
  IDI_ERROR = IDI_HAND;
  IDI_INFORMATION = IDI_ASTERISK;

function LoadStringA(hInstance: HINST; uID: UINT; lpBuffer: PAnsiChar; nBufferMax: Integer): Integer; stdcall;
function LoadStringW(hInstance: HINST; uID: UINT; lpBuffer: PWideChar; nBufferMax: Integer): Integer; stdcall;
function LoadString(hInstance: HINST; uID: UINT; lpBuffer: PTChar; nBufferMax: Integer): Integer; stdcall;

const
  { Dialog Box Command IDs }
  IDOK = 1;          ID_OK = IDOK;
  IDCANCEL = 2;      ID_CANCEL = IDCANCEL;
  IDABORT = 3;       ID_ABORT = IDABORT;
  IDRETRY = 4;       ID_RETRY = IDRETRY;
  IDIGNORE = 5;      ID_IGNORE = IDIGNORE;
  IDYES = 6;         ID_YES = IDYES;
  IDNO = 7;          ID_NO = IDNO;
  IDCLOSE = 8;       ID_CLOSE = IDCLOSE;
  IDHELP = 9;        ID_HELP = IDHELP;


{ Control Manager Structures and Definitions }

  { Edit Control Styles }
  ES_LEFT = 0;
  ES_CENTER = 1;
  ES_RIGHT = 2;
  ES_MULTILINE = 4;
  ES_UPPERCASE = 8;
  ES_LOWERCASE = $10;
  ES_PASSWORD = $20;
  ES_AUTOVSCROLL = $40;
  ES_AUTOHSCROLL = $80;
  ES_NOHIDESEL = $100;
  ES_OEMCONVERT = $400;
  ES_READONLY = $800;
  ES_WANTRETURN = $1000;
  ES_NUMBER = $2000;

  { Edit control EM_SETMARGIN parameters }
  EC_LEFTMARGIN = 1;
  EC_RIGHTMARGIN = 2;
  EC_USEFONTINFO = 65535;

  { wParam of EM_GET/SETIMESTATUS }
  EMSIS_COMPOSITIONSTRING = 1;

  { lParam for EMSIS_COMPOSITIONSTRING }
  EIMES_GETCOMPSTRATONCE = 1;
  EIMES_CANCELCOMPSTRINGFOCUS = 2;
  EIMES_COMPLETECOMPSTRKILLFOCUS = 4;

  { TFNEditWordBreakProc code values }
  WB_LEFT = 0;
  WB_RIGHT = 1;
  WB_ISDELIMITER = 2;

  { Button Control Styles }
  BS_PUSHBUTTON = 0;
  BS_DEFPUSHBUTTON = 1;
  BS_CHECKBOX = 2;
  BS_AUTOCHECKBOX = 3;
  BS_RADIOBUTTON = 4;
  BS_3STATE = 5;
  BS_AUTO3STATE = 6;
  BS_GROUPBOX = 7;
  BS_USERBUTTON = 8;
  BS_AUTORADIOBUTTON = 9;
  BS_OWNERDRAW = 11;
  BS_LEFTTEXT = $20;
  BS_TEXT = 0;
  BS_ICON = $40;
  BS_BITMAP = $80;
  BS_LEFT = $100;
  BS_RIGHT = $200;
  BS_CENTER = 768;
  BS_TOP = $400;
  BS_BOTTOM = $800;
  BS_VCENTER = 3072;
  BS_PUSHLIKE = $1000;
  BS_MULTILINE = $2000;
  BS_NOTIFY = $4000;
  BS_FLAT = $8000;
  BS_RIGHTBUTTON = BS_LEFTTEXT;

  BST_UNCHECKED = 0;
  BST_CHECKED = 1;
  BST_INDETERMINATE = 2;
  BST_PUSHED = 4;
  BST_FOCUS = 8;

  { Static Control Constants }
  SS_LEFT = 0;
  SS_CENTER = 1;
  SS_RIGHT = 2;
  SS_ICON = 3;
  SS_BLACKRECT = 4;
  SS_GRAYRECT = 5;
  SS_WHITERECT = 6;
  SS_BLACKFRAME = 7;
  SS_GRAYFRAME = 8;
  SS_WHITEFRAME = 9;
  SS_USERITEM = 10;
  SS_SIMPLE = 11;
  SS_LEFTNOWORDWRAP = 12;
  SS_BITMAP = 14;
  SS_OWNERDRAW = 13;
  SS_ENHMETAFILE = 15;
  SS_ETCHEDHORZ = $10;
  SS_ETCHEDVERT = 17;
  SS_ETCHEDFRAME = 18;
  SS_TYPEMASK = 31;
  SS_NOPREFIX = $80;      { Don't do "&" character translation }
  SS_NOTIFY = $100;
  SS_CENTERIMAGE = $200;
  SS_RIGHTJUST = $400;
  SS_REALSIZEIMAGE = $800;
  SS_SUNKEN = $1000;
  SS_ENDELLIPSIS =  $4000;
  SS_PATHELLIPSIS = $8000;
  SS_WORDELLIPSIS = $C000;
  SS_ELLIPSISMASK = $C000;

  { Static Control Mesages }
  STM_SETICON = 368;
  STM_GETICON = 369;
  STM_SETIMAGE = 370;
  STM_GETIMAGE = 371;
  STN_CLICKED = 0;
  STN_DBLCLK = 1;
  STN_ENABLE = 2;
  STN_DISABLE = 3;
  STM_MSGMAX = 372;

  { Dialog window class }
  WC_DIALOG = MakeIntAtom($8002);

  { GetSetWindowWordLong offsets for use with WC_DIALOG windows }
  DWL_MSGRESULT = 0;
  DWL_DLGPROC = 4;
  DWL_USER = 8;

{ Dialog Manager Routines }

function IsDialogMessageA(hDlg: HWND; var lpMsg: TMsg): BOOL; stdcall;
function IsDialogMessageW(hDlg: HWND; var lpMsg: TMsg): BOOL; stdcall;
function IsDialogMessage(hDlg: HWND; var lpMsg: TMsg): BOOL; stdcall;
function MapDialogRect(hDlg: HWND; var lpRect: TRect): BOOL; stdcall;
function DlgDirListA(hDlg: HWND; lpPathSpec: PAnsiChar;
  nIDListBox, nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;
function DlgDirListW(hDlg: HWND; lpPathSpec: PWideChar;
  nIDListBox, nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;
function DlgDirList(hDlg: HWND; lpPathSpec: PTChar;
  nIDListBox, nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;

const
  { DlgDirList, DlgDirListComboBox flags values }
  DDL_READWRITE = 0;
  DDL_READONLY = 1;
  DDL_HIDDEN = 2;
  DDL_SYSTEM = 4;
  DDL_DIRECTORY = $10;
  DDL_ARCHIVE = $20;

  DDL_POSTMSGS = $2000;
  DDL_DRIVES = $4000;
  DDL_EXCLUSIVE = $8000;

function DlgDirSelectExA(hDlg: HWND; lpString: PAnsiChar; nCount, nIDListBox: Integer): BOOL; stdcall;
function DlgDirSelectExW(hDlg: HWND; lpString: PWideChar; nCount, nIDListBox: Integer): BOOL; stdcall;
function DlgDirSelectEx(hDlg: HWND; lpString: PTChar; nCount, nIDListBox: Integer): BOOL; stdcall;
function DlgDirListComboBoxA(hDlg: HWND; lpPathSpec: PAnsiChar;
  nIDComboBox, nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;
function DlgDirListComboBoxW(hDlg: HWND; lpPathSpec: PWideChar;
  nIDComboBox, nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;
function DlgDirListComboBox(hDlg: HWND; lpPathSpec: PTChar;
  nIDComboBox, nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;
function DlgDirSelectComboBoxExA(hDlg: HWND; lpString: PAnsiChar;
  nCount, nIDComboBox: Integer): BOOL; stdcall;
function DlgDirSelectComboBoxExW(hDlg: HWND; lpString: PWideChar;
  nCount, nIDComboBox: Integer): BOOL; stdcall;
function DlgDirSelectComboBoxEx(hDlg: HWND; lpString: PTChar;
  nCount, nIDComboBox: Integer): BOOL; stdcall;

const
  { Dialog Styles }
  DS_ABSALIGN = 1;
  DS_SYSMODAL = 2;
  DS_LOCALEDIT = $20;         { Edit items get Local storage. }
  DS_SETFONT = $40;           { User specified font for Dlg controls }
  DS_MODALFRAME = $80;        { Can be combined with WS_CAPTION  }
  DS_NOIDLEMSG = $100;        { WM_ENTERIDLE message will not be sent }
  DS_SETFOREGROUND = $200;    { not in win3.1 }

  DS_3DLOOK = 4;
  DS_FIXEDSYS = 8;
  DS_NOFAILCREATE = $10;
  DS_CONTROL = $400;
  DS_CENTER = $800;
  DS_CENTERMOUSE = $1000;
  DS_CONTEXTHELP = $2000;

  PSI_SETACTIVE = 1;
  PSI_KILLACTIVE = 2;
  PSI_APPLY = 3;
  PSI_RESET = 4;
  PSI_HASHELP = 5;
  PSI_HELP = 6;

  PSI_CHANGED = 1;
  PSI_GUISTART = 2;
  PSI_REBOOT = 3;
  PSI_GETSIBLINGS = 4;

  { Returned in HiWord() of DM_GETDEFID result if msg is supported }
  DC_HASDEFID = 21323;

  { Dialog Codes }
  DLGC_WANTARROWS = 1;         { Control wants arrow keys         }
  DLGC_WANTTAB = 2;            { Control wants tab keys           }
  DLGC_WANTALLKEYS = 4;        { Control wants all keys           }
  DLGC_WANTMESSAGE = 4;        { Pass message to control          }
  DLGC_HASSETSEL = 8;          { Understands EM_SETSEL message    }
  DLGC_DEFPUSHBUTTON = $10;    { Default pushbutton               }
  DLGC_UNDEFPUSHBUTTON = $20;  { Non-default pushbutton           }
  DLGC_RADIOBUTTON = $40;      { Radio button                     }
  DLGC_WANTCHARS = $80;        { Want WM_CHAR messages            }
  DLGC_STATIC = $100;          { Static item: don't include       }
  DLGC_BUTTON = $2000;         { Button item: can be checked      }
  LB_CTLCODE = 0;

  { Listbox Return Values }
  LB_OKAY = 0;
  LB_ERR = -1;
  LB_ERRSPACE = -2;

  { Listbox Styles }
  LBS_NOTIFY = 1;
  LBS_SORT = 2;
  LBS_NOREDRAW = 4;
  LBS_MULTIPLESEL = 8;
  LBS_OWNERDRAWFIXED = $10;
  LBS_OWNERDRAWVARIABLE = $20;
  LBS_HASSTRINGS = $40;
  LBS_USETABSTOPS = $80;
  LBS_NOINTEGRALHEIGHT = $100;
  LBS_MULTICOLUMN = $200;
  LBS_WANTKEYBOARDINPUT = $400;
  LBS_EXTENDEDSEL = $800;
  LBS_DISABLENOSCROLL = $1000;
  LBS_NODATA = $2000;
  LBS_NOSEL = $4000;
  LBS_STANDARD = (LBS_NOTIFY or LBS_SORT or WS_VSCROLL or WS_BORDER);

  { Combo Box return Values }
  CB_OKAY = 0;
  CB_ERR = -1;
  CB_ERRSPACE = -2;

  { Combo Box styles }
  CBS_SIMPLE = 1;
  CBS_DROPDOWN = 2;
  CBS_DROPDOWNLIST = 3;
  CBS_OWNERDRAWFIXED = $10;
  CBS_OWNERDRAWVARIABLE = $20;
  CBS_AUTOHSCROLL = $40;
  CBS_OEMCONVERT = $80;
  CBS_SORT = $100;
  CBS_HASSTRINGS = $200;
  CBS_NOINTEGRALHEIGHT = $400;
  CBS_DISABLENOSCROLL = $800;
  CBS_UPPERCASE = $2000;
  CBS_LOWERCASE = $4000;

  { Scroll Bar Styles }
  SBS_HORZ = 0;
  SBS_VERT = 1;
  SBS_TOPALIGN = 2;
  SBS_LEFTALIGN = 2;
  SBS_BOTTOMALIGN = 4;
  SBS_RIGHTALIGN = 4;
  SBS_SIZEBOXTOPLEFTALIGN = 2;
  SBS_SIZEBOXBOTTOMRIGHTALIGN = 4;
  SBS_SIZEBOX = 8;
  SBS_SIZEGRIP = $10;

  SIF_RANGE = 1;
  SIF_PAGE = 2;
  SIF_POS = 4;
  SIF_DISABLENOSCROLL = 8;
  SIF_TRACKPOS = $10;
  SIF_ALL = (SIF_RANGE or SIF_PAGE or SIF_POS or SIF_TRACKPOS);

type
  tagSCROLLINFO = packed record
    cbSize: UINT;
    fMask: UINT;
    nMin: Integer;
    nMax: Integer;
    nPage: UINT;
    nPos: Integer;
    nTrackPos: Integer;
  end;
  PScrollInfo = ^TScrollInfo;
  TScrollInfo = tagSCROLLINFO;
  SCROLLINFO = tagSCROLLINFO;

function SetScrollInfo(hWnd: HWND; BarFlag: Integer; const ScrollInfo: TScrollInfo; Redraw: BOOL): Integer; stdcall;
function GetScrollInfo(hWnd: HWND; BarFlag: Integer; var ScrollInfo: TScrollInfo): BOOL; stdcall;


const
  { MDI client style bits }
  MDIS_ALLCHILDSTYLES = 1;

  { wParam Flags for WM_MDITILE and WM_MDICASCADE messages. }
  MDITILE_VERTICAL = 0;       { not in win3.1  }
  MDITILE_HORIZONTAL = 1;     { not in win3.1  }
  MDITILE_SKIPDISABLED = 2;   { not in win3.1  }

type
  PMDICreateStructA = ^TMDICreateStructA;
  PMDICreateStructW = ^TMDICreateStructW;
  PMDICreateStruct = {$ifdef bUnicode}PMDICreateStructW{$else}PMDICreateStructA{$endif bUnicode};

  tagMDICREATESTRUCTA = packed record
    szClass: PAnsiChar;
    szTitle: PAnsiChar;
    hOwner: THandle;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    style: DWORD;
    lParam: LPARAM;  { app-defined stuff }
  end;
  tagMDICREATESTRUCTW = packed record
    szClass: PWideChar;
    szTitle: PWideChar;
    hOwner: THandle;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    style: DWORD;
    lParam: LPARAM;  { app-defined stuff }
  end;
  tagMDICREATESTRUCT = {$ifdef bUnicode}tagMDICREATESTRUCTW{$else}tagMDICREATESTRUCTA{$endif bUnicode};

  TMDICreateStructA = tagMDICREATESTRUCTA;
  TMDICreateStructW = tagMDICREATESTRUCTW;
  TMDICreateStruct = {$ifdef bUnicode}TMDICreateStructW{$else}TMDICreateStructA{$endif bUnicode};

  MDICREATESTRUCTA = tagMDICREATESTRUCTA;
  MDICREATESTRUCTW = tagMDICREATESTRUCTW;
  MDICREATESTRUCT = {$ifdef bUnicode}MDICREATESTRUCTW{$else}MDICREATESTRUCTA{$endif bUnicode};

  PClientCreateStruct = ^TClientCreateStruct;
  tagCLIENTCREATESTRUCT = packed record
    hWindowMenu: THandle;
    idFirstChild: UINT;
  end;
  TClientCreateStruct = tagCLIENTCREATESTRUCT;
  CLIENTCREATESTRUCT = tagCLIENTCREATESTRUCT;

function DefFrameProcA(hWnd, hWndMDIClient: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefFrameProcW(hWnd, hWndMDIClient: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefFrameProc(hWnd, hWndMDIClient: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefMDIChildProcA(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefMDIChildProcW(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefMDIChildProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function TranslateMDISysAccel(hWndClient: HWND; const lpMsg: TMsg): BOOL; stdcall;
function ArrangeIconicWindows(hWnd: HWND): UINT; stdcall;
function CreateMDIWindowA(lpClassName, lpWindowName: PAnsiChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hInstance: HINST; lParam: LPARAM): HWND; stdcall;
function CreateMDIWindowW(lpClassName, lpWindowName: PWideChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hInstance: HINST; lParam: LPARAM): HWND; stdcall;
function CreateMDIWindow(lpClassName, lpWindowName: PTChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hInstance: HINST; lParam: LPARAM): HWND; stdcall;
function TileWindows(hwndParent: HWND; wHow: UINT; lpRect: PRect; cKids: UINT; lpKids: Pointer): Word; stdcall;
function CascadeWindows(hwndParent: HWND; wHow: UINT; lpRect: PRect; cKids: UINT; lpKids: Pointer): Word; stdcall;


{ IME class support }

const
  { wParam for WM_IME_CONTROL (removed from 4.0 SDK) }
  IMC_GETCANDIDATEPOS = 7;
  IMC_SETCANDIDATEPOS = 8;
  IMC_GETCOMPOSITIONFONT = 9;
  IMC_SETCOMPOSITIONFONT = $0A;
  IMC_GETCOMPOSITIONWINDOW = $0B;
  IMC_SETCOMPOSITIONWINDOW = $0C;
  IMC_GETSTATUSWINDOWPOS = $0F;
  IMC_SETSTATUSWINDOWPOS = $10;
  IMC_CLOSESTATUSWINDOW = $21;
  IMC_OPENSTATUSWINDOW = $22;

  { wParam of report message WM_IME_NOTIFY (removed from 4.0 SDK) }
  IMN_CLOSESTATUSWINDOW = 1;
  IMN_OPENSTATUSWINDOW = 2;
  IMN_CHANGECANDIDATE = 3;
  IMN_CLOSECANDIDATE = 4;
  IMN_OPENCANDIDATE = 5;
  IMN_SETCONVERSIONMODE = 6;
  IMN_SETSENTENCEMODE = 7;
  IMN_SETOPENSTATUS = 8;
  IMN_SETCANDIDATEPOS = 9;
  IMN_SETCOMPOSITIONFONT = 10;
  IMN_SETCOMPOSITIONWINDOW = 11;
  IMN_SETSTATUSWINDOWPOS = 12;
  IMN_GUIDELINE = 13;
  IMN_PRIVATE = 14;

{ Help support }

type
  HELPPOLY = DWORD;
  PMultiKeyHelpA = ^TMultiKeyHelpA;
  PMultiKeyHelpW = ^TMultiKeyHelpW;
  PMultiKeyHelp = PMultiKeyHelpA;
  tagMULTIKEYHELPA = record
    mkSize: DWORD;
    mkKeylist: AnsiChar;
    szKeyphrase: array[0..0] of AnsiChar;
  end;
  tagMULTIKEYHELPW = record
    mkSize: DWORD;
    mkKeylist: WideChar;
    szKeyphrase: array[0..0] of WideChar;
  end;
  tagMULTIKEYHELP = tagMULTIKEYHELPA;
  TMultiKeyHelpA = tagMULTIKEYHELPA;
  TMultiKeyHelpW = tagMULTIKEYHELPW;
  TMultiKeyHelp = TMultiKeyHelpA;
  MULTIKEYHELPA = tagMULTIKEYHELPA;
  MULTIKEYHELPW = tagMULTIKEYHELPW;
  MULTIKEYHELP = MULTIKEYHELPA;

  PHelpWinInfoA = ^THelpWinInfoA;
  PHelpWinInfoW = ^THelpWinInfoW;
  PHelpWinInfo = PHelpWinInfoA;
  tagHELPWININFOA = record
    wStructSize: Integer;
    x: Integer;
    y: Integer;
    dx: Integer;
    dy: Integer;
    wMax: Integer;
    rgchMember: array[0..1] of AnsiChar;
  end;
  tagHELPWININFOW = record
    wStructSize: Integer;
    x: Integer;
    y: Integer;
    dx: Integer;
    dy: Integer;
    wMax: Integer;
    rgchMember: array[0..1] of WideChar;
  end;
  tagHELPWININFO = tagHELPWININFOA;
  THelpWinInfoA = tagHELPWININFOA;
  THelpWinInfoW = tagHELPWININFOW;
  THelpWinInfo = THelpWinInfoA;
  HELPWININFOA = tagHELPWININFOA;
  HELPWININFOW = tagHELPWININFOW;
  HELPWININFO = HELPWININFOA;

const
  { Commands to pass to WinHelp() }
  HELP_CONTEXT = 1;       { Display topic in ulTopic  }
  HELP_QUIT = 2;          { Terminate help  }
  HELP_INDEX = 3;         { Display index  }
  HELP_CONTENTS = 3;
  HELP_HELPONHELP = 4;    { Display help on using help  }
  HELP_SETINDEX = 5;      { Set current Index for multi index help  }
  HELP_SETCONTENTS = 5;
  HELP_CONTEXTPOPUP = 8;
  HELP_FORCEFILE = 9;
  HELP_KEY = 257;         { Display topic for keyword in offabData  }
  HELP_COMMAND = 258;
  HELP_PARTIALKEY = 261;
  HELP_MULTIKEY = 513;
  HELP_SETWINPOS = 515;
  HELP_CONTEXTMENU = 10;
  HELP_FINDER = 11;
  HELP_WM_HELP = 12;
  HELP_SETPOPUP_POS = 13;

  HELP_TCARD = $8000;
  HELP_TCARD_DATA = $10;
  HELP_TCARD_OTHER_CALLER = 17;

  { These are in winhelp.h in Win95. }
  IDH_NO_HELP = 28440;
  IDH_MISSING_CONTEXT = 28441;      { Control doesn't have matching help context }
  IDH_GENERIC_HELP_BUTTON = 28442;  { Property sheet help button }
  IDH_OK = 28443;
  IDH_CANCEL = 28444;
  IDH_HELP = 28445;

function WinHelpA(hWndMain: HWND; lpszHelp: PAnsiChar; uCommand: UINT; dwData: DWORD): BOOL; stdcall;
function WinHelpW(hWndMain: HWND; lpszHelp: PWideChar; uCommand: UINT; dwData: DWORD): BOOL; stdcall;
function WinHelp(hWndMain: HWND; lpszHelp: PTChar; uCommand: UINT; dwData: DWORD): BOOL; stdcall;

const
  GR_GDIOBJECTS = 0;    { Count of GDI objects }
  GR_USEROBJECTS = 1;    { Count of USER objects }

function GetGuiResources(hProcess: THandle; uiFlags: DWORD): DWORD; stdcall;

const
  { Parameter for SystemParametersInfo() }
  SPI_GETBEEP = 1;
  SPI_SETBEEP = 2;
  SPI_GETMOUSE = 3;
  SPI_SETMOUSE = 4;
  SPI_GETBORDER = 5;
  SPI_SETBORDER = 6;
  SPI_GETKEYBOARDSPEED = 10;
  SPI_SETKEYBOARDSPEED = 11;
  SPI_LANGDRIVER = 12;
  SPI_ICONHORIZONTALSPACING = 13;
  SPI_GETSCREENSAVETIMEOUT = 14;
  SPI_SETSCREENSAVETIMEOUT = 15;
  SPI_GETSCREENSAVEACTIVE = $10;
  SPI_SETSCREENSAVEACTIVE = 17;
  SPI_GETGRIDGRANULARITY = 18;
  SPI_SETGRIDGRANULARITY = 19;
  SPI_SETDESKWALLPAPER = 20;
  SPI_SETDESKPATTERN = 21;
  SPI_GETKEYBOARDDELAY = 22;
  SPI_SETKEYBOARDDELAY = 23;
  SPI_ICONVERTICALSPACING = 24;
  SPI_GETICONTITLEWRAP = 25;
  SPI_SETICONTITLEWRAP = 26;
  SPI_GETMENUDROPALIGNMENT = 27;
  SPI_SETMENUDROPALIGNMENT = 28;
  SPI_SETDOUBLECLKWIDTH = 29;
  SPI_SETDOUBLECLKHEIGHT = 30;
  SPI_GETICONTITLELOGFONT = 31;
  SPI_SETDOUBLECLICKTIME = $20;
  SPI_SETMOUSEBUTTONSWAP = 33;
  SPI_SETICONTITLELOGFONT = 34;
  SPI_GETFASTTASKSWITCH = 35;
  SPI_SETFASTTASKSWITCH = 36;
  SPI_SETDRAGFULLWINDOWS = 37;
  SPI_GETDRAGFULLWINDOWS = 38;
  SPI_GETNONCLIENTMETRICS = 41;
  SPI_SETNONCLIENTMETRICS = 42;
  SPI_GETMINIMIZEDMETRICS = 43;
  SPI_SETMINIMIZEDMETRICS = 44;
  SPI_GETICONMETRICS = 45;
  SPI_SETICONMETRICS = 46;
  SPI_SETWORKAREA = 47;
  SPI_GETWORKAREA = 48;
  SPI_SETPENWINDOWS = 49;

  SPI_GETHIGHCONTRAST = 66;
  SPI_SETHIGHCONTRAST = 67;
  SPI_GETKEYBOARDPREF = 68;
  SPI_SETKEYBOARDPREF = 69;
  SPI_GETSCREENREADER = 70;
  SPI_SETSCREENREADER = 71;
  SPI_GETANIMATION = 72;
  SPI_SETANIMATION = 73;
  SPI_GETFONTSMOOTHING = 74;
  SPI_SETFONTSMOOTHING = 75;
  SPI_SETDRAGWIDTH = 76;
  SPI_SETDRAGHEIGHT = 77;
  SPI_SETHANDHELD = 78;
  SPI_GETLOWPOWERTIMEOUT = 79;
  SPI_GETPOWEROFFTIMEOUT = 80;
  SPI_SETLOWPOWERTIMEOUT = 81;
  SPI_SETPOWEROFFTIMEOUT = 82;
  SPI_GETLOWPOWERACTIVE = 83;
  SPI_GETPOWEROFFACTIVE = 84;
  SPI_SETLOWPOWERACTIVE = 85;
  SPI_SETPOWEROFFACTIVE = 86;
  SPI_SETCURSORS = 87;
  SPI_SETICONS = 88;
  SPI_GETDEFAULTINPUTLANG = 89;
  SPI_SETDEFAULTINPUTLANG = 90;
  SPI_SETLANGTOGGLE = 91;
  SPI_GETWINDOWSEXTENSION = 92;
  SPI_SETMOUSETRAILS = 93;
  SPI_GETMOUSETRAILS = 94;
  SPI_SCREENSAVERRUNNING = 97;
  SPI_GETFILTERKEYS = 50;
  SPI_SETFILTERKEYS = 51;
  SPI_GETTOGGLEKEYS = 52;
  SPI_SETTOGGLEKEYS = 53;
  SPI_GETMOUSEKEYS = 54;
  SPI_SETMOUSEKEYS = 55;
  SPI_GETSHOWSOUNDS = 56;
  SPI_SETSHOWSOUNDS = 57;
  SPI_GETSTICKYKEYS = 58;
  SPI_SETSTICKYKEYS = 59;
  SPI_GETACCESSTIMEOUT = 60;
  SPI_SETACCESSTIMEOUT = 61;
  SPI_GETSERIALKEYS = 62;
  SPI_SETSERIALKEYS = 63;
  SPI_GETSOUNDSENTRY = 64;
  SPI_SETSOUNDSENTRY = 65;

  SPI_GETSNAPTODEFBUTTON = 95;
  SPI_SETSNAPTODEFBUTTON = 96;
  SPI_GETMOUSEHOVERWIDTH = 98;
  SPI_SETMOUSEHOVERWIDTH = 99;
  SPI_GETMOUSEHOVERHEIGHT = 100;
  SPI_SETMOUSEHOVERHEIGHT = 101;
  SPI_GETMOUSEHOVERTIME = 102;
  SPI_SETMOUSEHOVERTIME = 103;
  SPI_GETWHEELSCROLLLINES = 104;
  SPI_SETWHEELSCROLLLINES = 105;         // For Win95 and WinNT3.51,
                                         // Mswheel broadcasts the message
                                         // WM_SETTINGCHANGE (equivalent to
                                         // WM_WININICHANGE) when the scroll
                                         // lines has changed.  Applications
                                         // will recieve the WM_SETTINGCHANGE
                                         // message with the wParam set to
                                         // SPI_SETWHEELSCROLLLINES.  When
                                         // this message is recieved the
                                         // application should query Mswheel for
                                         // the new setting.
  SPI_GETSHOWIMEUI = 110;
  SPI_SETSHOWIMEUI = 111;
  SPI_GETMOUSESPEED = 112;
  SPI_SETMOUSESPEED = 113;
  SPI_GETSCREENSAVERRUNNING = 114;

  SPI_GETACTIVEWINDOWTRACKING = $1000;
  SPI_SETACTIVEWINDOWTRACKING = $1001;
  SPI_GETMENUANIMATION = $1002;
  SPI_SETMENUANIMATION = $1003;
  SPI_GETCOMBOBOXANIMATION = $1004;
  SPI_SETCOMBOBOXANIMATION = $1005;
  SPI_GETLISTBOXSMOOTHSCROLLING = $1006;
  SPI_SETLISTBOXSMOOTHSCROLLING = $1007;
  SPI_GETGRADIENTCAPTIONS = $1008;
  SPI_SETGRADIENTCAPTIONS = $1009;
  SPI_GETMENUUNDERLINES = $100A;
  SPI_SETMENUUNDERLINES = $100B;
  SPI_GETACTIVEWNDTRKZORDER = $100C;
  SPI_SETACTIVEWNDTRKZORDER = $100D;
  SPI_GETHOTTRACKING = $100E;
  SPI_SETHOTTRACKING = $100F;
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
  SPI_GETACTIVEWNDTRKTIMEOUT = $2002;
  SPI_SETACTIVEWNDTRKTIMEOUT = $2003;
  SPI_GETFOREGROUNDFLASHCOUNT = $2004;
  SPI_SETFOREGROUNDFLASHCOUNT = $2005;

  { Flags }
  SPIF_UPDATEINIFILE = 1;
  SPIF_SENDWININICHANGE = 2;
  SPIF_SENDCHANGE = SPIF_SENDWININICHANGE;

  METRICS_USEDEFAULT = LongWord(-1);

type
  PNonClientMetricsA = ^TNonClientMetricsA;
  PNonClientMetricsW = ^TNonClientMetricsW;
  PNonClientMetrics = {$ifdef bUnicode}PNonClientMetricsW{$else}PNonClientMetricsA{$endif bUnicode};

  tagNONCLIENTMETRICSA = packed record
    cbSize: UINT;
    iBorderWidth: Integer;
    iScrollWidth: Integer;
    iScrollHeight: Integer;
    iCaptionWidth: Integer;
    iCaptionHeight: Integer;
    lfCaptionFont: TLogFontA;
    iSmCaptionWidth: Integer;
    iSmCaptionHeight: Integer;
    lfSmCaptionFont: TLogFontA;
    iMenuWidth: Integer;
    iMenuHeight: Integer;
    lfMenuFont: TLogFontA;
    lfStatusFont: TLogFontA;
    lfMessageFont: TLogFontA;
  end;
  tagNONCLIENTMETRICSW = packed record
    cbSize: UINT;
    iBorderWidth: Integer;
    iScrollWidth: Integer;
    iScrollHeight: Integer;
    iCaptionWidth: Integer;
    iCaptionHeight: Integer;
    lfCaptionFont: TLogFontW;
    iSmCaptionWidth: Integer;
    iSmCaptionHeight: Integer;
    lfSmCaptionFont: TLogFontW;
    iMenuWidth: Integer;
    iMenuHeight: Integer;
    lfMenuFont: TLogFontW;
    lfStatusFont: TLogFontW;
    lfMessageFont: TLogFontW;
  end;
  tagNONCLIENTMETRICS = {$ifdef bUnicode}tagNONCLIENTMETRICSW{$else}tagNONCLIENTMETRICSA{$endif bUnicode};

  TNonClientMetricsA = tagNONCLIENTMETRICSA;
  TNonClientMetricsW = tagNONCLIENTMETRICSW;
  TNonClientMetrics = {$ifdef bUnicode}TNonClientMetricsW{$else}TNonClientMetricsA{$endif bUnicode};

  NONCLIENTMETRICSA = tagNONCLIENTMETRICSA;
  NONCLIENTMETRICSW = tagNONCLIENTMETRICSW;
  NONCLIENTMETRICS = {$ifdef bUnicode}NONCLIENTMETRICSW{$else}NONCLIENTMETRICSA{$endif bUnicode};

const
  ARW_BOTTOMLEFT = 0;
  ARW_BOTTOMRIGHT = 1;
  ARW_TOPLEFT = 2;
  ARW_TOPRIGHT = 3;
  ARW_STARTMASK = 3;
  ARW_STARTRIGHT = 1;
  ARW_STARTTOP = 2;

  ARW_LEFT = 0;
  ARW_RIGHT = 0;
  ARW_UP = 4;
  ARW_DOWN = 4;
  ARW_HIDE = 8;
  ARW_VALID = 15;

type
  PMinimizedMetrics = ^TMinimizedMetrics;
  tagMINIMIZEDMETRICS = packed record
    cbSize: UINT;
    iWidth: Integer;
    iHorzGap: Integer;
    iVertGap: Integer;
    iArrange: Integer;
  end;
  TMinimizedMetrics = tagMINIMIZEDMETRICS;
  MINIMIZEDMETRICS = tagMINIMIZEDMETRICS;

  PIconMetricsA = ^TIconMetricsA;
  PIconMetricsW = ^TIconMetricsW;
  PIconMetrics = PIconMetricsA;
  tagICONMETRICSA = packed record
    cbSize: UINT;
    iHorzSpacing: Integer;
    iVertSpacing: Integer;
    iTitleWrap: Integer;
    lfFont: TLogFontA;
  end;
  tagICONMETRICSW = packed record
    cbSize: UINT;
    iHorzSpacing: Integer;
    iVertSpacing: Integer;
    iTitleWrap: Integer;
    lfFont: TLogFontW;
  end;
  tagICONMETRICS = tagICONMETRICSA;
  TIconMetricsA = tagICONMETRICSA;
  TIconMetricsW = tagICONMETRICSW;
  TIconMetrics = TIconMetricsA;
  ICONMETRICSA = tagICONMETRICSA;
  ICONMETRICSW = tagICONMETRICSW;
  ICONMETRICS = ICONMETRICSA;

  PAnimationInfo = ^TAnimationInfo;
  tagANIMATIONINFO = packed record
    cbSize: UINT;
    iMinAnimate: Integer;
  end;
  TAnimationInfo = tagANIMATIONINFO;
  ANIMATIONINFO = tagANIMATIONINFO;


type
  PSerialKeysA = ^TSerialKeysA;
  PSerialKeysW = ^TSerialKeysW;
  PSerialKeys = PSerialKeysA;
  tagSERIALKEYSA = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszActivePort: PAnsiChar;
    lpszPort: PAnsiChar;
    iBaudRate: UINT;
    iPortState: UINT;
    iActive: UINT;
  end;
  tagSERIALKEYSW = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszActivePort: PWideChar;
    lpszPort: PWideChar;
    iBaudRate: UINT;
    iPortState: UINT;
    iActive: UINT;
  end;
  tagSERIALKEYS = tagSERIALKEYSA;
  TSerialKeysA = tagSERIALKEYSA;
  TSerialKeysW = tagSERIALKEYSW;
  TSerialKeys = TSerialKeysA;
  SERIALKEYSA = tagSERIALKEYSA;
  SERIALKEYSW = tagSERIALKEYSW;
  SERIALKEYS = SERIALKEYSA;

const
  { flags for SERIALKEYS dwFlags field }
  SERKF_SERIALKEYSON = 1;
  SERKF_AVAILABLE = 2;
  SERKF_INDICATOR = 4;

type
  PHighContrastA = ^THighContrastA;
  PHighContrastW = ^THighContrastW;
  PHighContrast = PHighContrastA;
  tagHIGHCONTRASTA = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszDefaultScheme: PAnsiChar;
  end;
  tagHIGHCONTRASTW = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszDefaultScheme: PWideChar;
  end;
  tagHIGHCONTRAST = tagHIGHCONTRASTA;
  THighContrastA = tagHIGHCONTRASTA;
  THighContrastW = tagHIGHCONTRASTW;
  THighContrast = THighContrastA;
  HIGHCONTRASTA = tagHIGHCONTRASTA;
  HIGHCONTRASTW = tagHIGHCONTRASTW;
  HIGHCONTRAST = HIGHCONTRASTA;


const
  { flags for HIGHCONTRAST dwFlags field }
  HCF_HIGHCONTRASTON      = $00000001;
  HCF_AVAILABLE           = $00000002;
  HCF_HOTKEYACTIVE        = $00000004;
  HCF_CONFIRMHOTKEY       = $00000008;
  HCF_HOTKEYSOUND         = $00000010;
  HCF_INDICATOR           = $00000020;
  HCF_HOTKEYAVAILABLE     = $00000040;

  { Flags for ChangeDisplaySettings }
  CDS_UPDATEREGISTRY      = $00000001;
  CDS_TEST                = $00000002;
  CDS_FULLSCREEN          = $00000004;
  CDS_GLOBAL              = $00000008;
  CDS_SET_PRIMARY         = $00000010;
  CDS_RESET               = $40000000;
  CDS_SETRECT             = $20000000;
  CDS_NORESET             = $10000000;

  { Return values for ChangeDisplaySettings }
  DISP_CHANGE_SUCCESSFUL           = 0;
  DISP_CHANGE_RESTART              = 1;
  DISP_CHANGE_FAILED              = -1;
  DISP_CHANGE_BADMODE             = -2;
  DISP_CHANGE_NOTUPDATED          = -3;
  DISP_CHANGE_BADFLAGS            = -4;
  DISP_CHANGE_BADPARAM            = -5;


function ChangeDisplaySettingsA(var lpDevMode: TDeviceModeA; dwFlags: DWORD): Longint; stdcall;
function ChangeDisplaySettingsW(var lpDevMode: TDeviceModeW; dwFlags: DWORD): Longint; stdcall;
function ChangeDisplaySettings(var lpDevMode: TDeviceMode; dwFlags: DWORD): Longint; stdcall;
function ChangeDisplaySettingsExA(lpszDeviceName: PAnsiChar; var lpDevMode: TDeviceModeA;
        wnd: HWND; dwFlags: DWORD; lParam: Pointer): Longint; stdcall;
function ChangeDisplaySettingsExW(lpszDeviceName: PWideChar; var lpDevMode: TDeviceModeW;
        wnd: HWND; dwFlags: DWORD; lParam: Pointer): Longint; stdcall;
function ChangeDisplaySettingsEx(lpszDeviceName: PTChar; var lpDevMode: TDeviceMode;
        wnd: HWND; dwFlags: DWORD; lParam: Pointer): Longint; stdcall;
function EnumDisplaySettingsA(lpszDeviceName: PAnsiChar; iModeNum: DWORD;
  var lpDevMode: TDeviceModeA): BOOL; stdcall;
function EnumDisplaySettingsW(lpszDeviceName: PWideChar; iModeNum: DWORD;
  var lpDevMode: TDeviceModeW): BOOL; stdcall;
function EnumDisplaySettings(lpszDeviceName: PTChar; iModeNum: DWORD;
  var lpDevMode: TDeviceMode): BOOL; stdcall;
{#END}
function EnumDisplayDevicesA(Unused: Pointer; iDevNum: DWORD;
  var lpDisplayDevice: TDisplayDeviceA; dwFlags: DWORD): BOOL; stdcall;
function EnumDisplayDevicesW(Unused: Pointer; iDevNum: DWORD;
  var lpDisplayDevice: TDisplayDeviceW; dwFlags: DWORD): BOOL; stdcall;
function EnumDisplayDevices(Unused: Pointer; iDevNum: DWORD;
  var lpDisplayDevice: TDisplayDevice; dwFlags: DWORD): BOOL; stdcall;
function SystemParametersInfoA(uiAction, uiParam: UINT;
  pvParam: Pointer; fWinIni: UINT): BOOL; stdcall;
function SystemParametersInfoW(uiAction, uiParam: UINT;
  pvParam: Pointer; fWinIni: UINT): BOOL; stdcall;
function SystemParametersInfo(uiAction, uiParam: UINT;
  pvParam: Pointer; fWinIni: UINT): BOOL; stdcall;

type
  { Accessibility support }
  PFilterKeys = ^TFilterKeys;
  tagFILTERKEYS = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    iWaitMSec: DWORD;       { Acceptance Delay}
    iDelayMSec: DWORD;      { Delay Until Repeat}
    iRepeatMSec: DWORD;     { Repeat Rate}
    iBounceMSec: DWORD;     { Debounce Time}
  end;
  TFilterKeys = tagFILTERKEYS;
  FILTERKEYS = tagFILTERKEYS;


const
  { TFilterKeys dwFlags field }
  FKF_FILTERKEYSON = 1;
  FKF_AVAILABLE = 2;
  FKF_HOTKEYACTIVE = 4;
  FKF_CONFIRMHOTKEY = 8;
  FKF_HOTKEYSOUND = $10;
  FKF_INDICATOR = $20;
  FKF_CLICKON = $40;

type
  PStickyKeys = ^TStickyKeys;
  tagSTICKYKEYS = packed record
    cbSize: UINT;
    dwFlags: DWORD;
  end;
  TStickyKeys = tagSTICKYKEYS;
  STICKYKEYS = tagSTICKYKEYS;

const
  { TStickyKeys dwFlags field }
  SKF_STICKYKEYSON = 1;
  SKF_AVAILABLE = 2;
  SKF_HOTKEYACTIVE = 4;
  SKF_CONFIRMHOTKEY = 8;
  SKF_HOTKEYSOUND = $10;
  SKF_INDICATOR = $20;
  SKF_AUDIBLEFEEDBACK = $40;
  SKF_TRISTATE = $80;
  SKF_TWOKEYSOFF = $100;
  SKF_LALTLATCHED = $10000000;
  SKF_LCTLLATCHED = $04000000;
  SKF_LSHIFTLATCHED = $01000000;
  SKF_RALTLATCHED = $20000000;
  SKF_RCTLLATCHED = $08000000;
  SKF_RSHIFTLATCHED = $02000000;
  SKF_LWINLATCHED = $40000000;
  SKF_RWINLATCHED = $80000000;
  SKF_LALTLOCKED = $00100000;
  SKF_LCTLLOCKED = $00040000;
  SKF_LSHIFTLOCKED = $00010000;
  SKF_RALTLOCKED = $00200000;
  SKF_RCTLLOCKED = $00080000;
  SKF_RSHIFTLOCKED = $00020000;
  SKF_LWINLOCKED = $00400000;
  SKF_RWINLOCKED = $00800000;

type
  PMouseKeys = ^TMouseKeys;
  tagMOUSEKEYS = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    iMaxSpeed: DWORD;
    iTimeToMaxSpeed: DWORD;
    iCtrlSpeed: DWORD;
    dwReserved1: DWORD;
    dwReserved2: DWORD;
  end;
  TMouseKeys = tagMOUSEKEYS;
  MOUSEKEYS = tagMOUSEKEYS;

const
  { TMouseKeys dwFlags field }
  MKF_MOUSEKEYSON = 1;
  MKF_AVAILABLE = 2;
  MKF_HOTKEYACTIVE = 4;
  MKF_CONFIRMHOTKEY = 8;
  MKF_HOTKEYSOUND = $10;
  MKF_INDICATOR = $20;
  MKF_MODIFIERS = $40;
  MKF_REPLACENUMBERS = $80;
  MKF_LEFTBUTTONSEL = $10000000;
  MKF_RIGHTBUTTONSEL = $20000000;
  MKF_LEFTBUTTONDOWN = $01000000;
  MKF_RIGHTBUTTONDOWN = $02000000;
  MKF_MOUSEMODE = $80000000;

type
  PAccessTimeout = ^TAccessTimeout;
  tagACCESSTIMEOUT = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    iTimeOutMSec: DWORD;
  end;
  TAccessTimeout = tagACCESSTIMEOUT;
  ACCESSTIMEOUT = tagACCESSTIMEOUT;

const
  { TAccessTimeout dwFlags field }
  ATF_TIMEOUTON = 1;
  ATF_ONOFFFEEDBACK = 2;

  { values for TSoundsEntry iFSGrafEffect field }
  SSGF_NONE = 0;
  SSGF_DISPLAY = 3;

  { values for TSoundsEntry iFSTextEffect field }
  SSTF_NONE = 0;
  SSTF_CHARS = 1;
  SSTF_BORDER = 2;
  SSTF_DISPLAY = 3;

  { values for TSoundsEntry iWindowsEffect field }
  SSWF_NONE = 0;
  SSWF_TITLE = 1;
  SSWF_WINDOW = 2;
  SSWF_DISPLAY = 3;
  SSWF_CUSTOM = 4;

type
  PSoundsEntryA = ^TSoundsEntryA;
  PSoundsEntryW = ^TSoundsEntryW;
  PSoundsEntry = PSoundsEntryA;
  tagSOUNDSENTRYA = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    iFSTextEffect: DWORD;
    iFSTextEffectMSec: DWORD;
    iFSTextEffectColorBits: DWORD;
    iFSGrafEffect: DWORD;
    iFSGrafEffectMSec: DWORD;
    iFSGrafEffectColor: DWORD;
    iWindowsEffect: DWORD;
    iWindowsEffectMSec: DWORD;
    lpszWindowsEffectDLL: PAnsiChar;
    iWindowsEffectOrdinal: DWORD;
  end;
  tagSOUNDSENTRYW = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    iFSTextEffect: DWORD;
    iFSTextEffectMSec: DWORD;
    iFSTextEffectColorBits: DWORD;
    iFSGrafEffect: DWORD;
    iFSGrafEffectMSec: DWORD;
    iFSGrafEffectColor: DWORD;
    iWindowsEffect: DWORD;
    iWindowsEffectMSec: DWORD;
    lpszWindowsEffectDLL: PWideChar;
    iWindowsEffectOrdinal: DWORD;
  end;
  tagSOUNDSENTRY = tagSOUNDSENTRYA;
  TSoundsEntryA = tagSOUNDSENTRYA;
  TSoundsEntryW = tagSOUNDSENTRYW;
  TSoundsEntry = TSoundsEntryA;
  SOUNDSENTRYA = tagSOUNDSENTRYA;
  SOUNDSENTRYW = tagSOUNDSENTRYW;
  SOUNDSENTRY = SOUNDSENTRYA;

const
  { SOUNDSENTRY dwFlags field }
  SSF_SOUNDSENTRYON = 1;
  SSF_AVAILABLE = 2;
  SSF_INDICATOR = 4;


type
  PToggleKeys = ^TToggleKeys;
  tagTOGGLEKEYS = packed record
    cbSize: UINT;
    dwFlags: DWORD;
  end;
  TToggleKeys = tagTOGGLEKEYS;
  TOGGLEKEYS = tagTOGGLEKEYS;

const
  { TToggleKeys dwFlags field }
  TKF_TOGGLEKEYSON = 1;
  TKF_AVAILABLE = 2;
  TKF_HOTKEYACTIVE = 4;
  TKF_CONFIRMHOTKEY = 8;
  TKF_HOTKEYSOUND = $10;
  TKF_INDICATOR = $20;

procedure SetDebugErrorLevel(dwLevel: DWORD); stdcall;

const
  { SetLastErrorEx() types. }
  SLE_ERROR = 1;
  SLE_MINORERROR = 2;
  SLE_WARNING = 3;

procedure SetLastErrorEx(dwErrCode, dwType: DWORD); stdcall;


{ WinEvents - Active Accessibility hooks }
procedure NotifyWinEvent(event: DWORD; hwnd: HWND; idObject, idChild: Longint);

type
    TFNWinEventProc = procedure (hWinEventHook: THandle; event: DWORD;
    hwnd: HWND; idObject, idChild: Longint; idEventThread, dwmsEventTime: DWORD); stdcall;

const
  CHILDID_SELF = 0;
  INDEXID_OBJECT = 0;
  INDEXID_CONTAINER = 0;

  { Reserved IDs for system objects}
  OBJID_WINDOW = $00000000;
  OBJID_SYSMENU = $FFFFFFFF;
  OBJID_TITLEBAR = $FFFFFFFE;
  OBJID_MENU = $FFFFFFFD;
  OBJID_CLIENT = $FFFFFFFC;
  OBJID_VSCROLL = $FFFFFFFB;
  OBJID_HSCROLL = $FFFFFFFA;
  OBJID_SIZEGRIP = $FFFFFFF9;
  OBJID_CARET = $FFFFFFF8;
  OBJID_CURSOR = $FFFFFFF7;
  OBJID_ALERT = $FFFFFFF6;
  OBJID_SOUND = $FFFFFFF5;

  { EVENT DEFINITION }
  EVENT_MIN = $00000001;
  EVENT_MAX = $7FFFFFFF;

  EVENT_SYSTEM_SOUND = $0001;
  EVENT_SYSTEM_ALERT = $0002;
  EVENT_SYSTEM_FOREGROUND = $0003;
  EVENT_SYSTEM_MENUSTART = $0004;
  EVENT_SYSTEM_MENUEND = $0005;
  EVENT_SYSTEM_MENUPOPUPSTART  = $0006;
  EVENT_SYSTEM_MENUPOPUPEND    = $0007;
  EVENT_SYSTEM_CAPTURESTART    = $0008;
  EVENT_SYSTEM_CAPTUREEND      = $0009;
  EVENT_SYSTEM_MOVESIZESTART   = $000A;
  EVENT_SYSTEM_MOVESIZEEND     = $000B;
  EVENT_SYSTEM_CONTEXTHELPSTART= $000C;
  EVENT_SYSTEM_CONTEXTHELPEND  = $000D;
  EVENT_SYSTEM_DRAGDROPSTART   = $000E;
  EVENT_SYSTEM_DRAGDROPEND     = $000F;
  EVENT_SYSTEM_DIALOGSTART     = $0010;
  EVENT_SYSTEM_DIALOGEND       = $0011;
  EVENT_SYSTEM_SCROLLINGSTART  = $0012;
  EVENT_SYSTEM_SCROLLINGEND    = $0013;
  EVENT_SYSTEM_SWITCHSTART     = $0014;
  EVENT_SYSTEM_SWITCHEND       = $0015;
  EVENT_SYSTEM_MINIMIZESTART   = $0016;
  EVENT_SYSTEM_MINIMIZEEND     = $0017;
  EVENT_OBJECT_CREATE              = $8000;  { hwnd + ID + idChild is created item }
  EVENT_OBJECT_DESTROY             = $8001;  { hwnd + ID + idChild is destroyed item }
  EVENT_OBJECT_SHOW                = $8002;  { hwnd + ID + idChild is shown item }
  EVENT_OBJECT_HIDE                = $8003;  { hwnd + ID + idChild is hidden item }
  EVENT_OBJECT_REORDER             = $8004;  { hwnd + ID + idChild is parent of zordering children }
  EVENT_OBJECT_FOCUS               = $8005;  { hwnd + ID + idChild is focused item }
  EVENT_OBJECT_SELECTION           = $8006;  { hwnd + ID + idChild is selected item (if only one), or idChild is OBJID_WINDOW if complex }
  EVENT_OBJECT_SELECTIONADD        = $8007;  { hwnd + ID + idChild is item added }
  EVENT_OBJECT_SELECTIONREMOVE     = $8008;  { hwnd + ID + idChild is item removed }
  EVENT_OBJECT_SELECTIONWITHIN     = $8009;  { hwnd + ID + idChild is parent of changed selected items }
  EVENT_OBJECT_STATECHANGE         = $800A;  { hwnd + ID + idChild is item w/ state change }
  EVENT_OBJECT_LOCATIONCHANGE      = $800B;  { hwnd + ID + idChild is moved/sized item }
  EVENT_OBJECT_NAMECHANGE          = $800C;  { hwnd + ID + idChild is item w/ name change }
  EVENT_OBJECT_DESCRIPTIONCHANGE   = $800D;  { hwnd + ID + idChild is item w/ desc change }
  EVENT_OBJECT_VALUECHANGE         = $800E;  { hwnd + ID + idChild is item w/ value change }
  EVENT_OBJECT_PARENTCHANGE        = $800F;  { hwnd + ID + idChild is item w/ new parent }
  EVENT_OBJECT_HELPCHANGE          = $8010;  { hwnd + ID + idChild is item w/ help change }
  EVENT_OBJECT_DEFACTIONCHANGE     = $8011;  { hwnd + ID + idChild is item w/ def action change }
  EVENT_OBJECT_ACCELERATORCHANGE   = $8012;  { hwnd + ID + idChild is item w/ keybd accel change }
  SOUND_SYSTEM_STARTUP           = 1;
  SOUND_SYSTEM_SHUTDOWN          = 2;
  SOUND_SYSTEM_BEEP              = 3;
  SOUND_SYSTEM_ERROR             = 4;
  SOUND_SYSTEM_QUESTION          = 5;
  SOUND_SYSTEM_WARNING           = 6;
  SOUND_SYSTEM_INFORMATION       = 7;
  SOUND_SYSTEM_MAXIMIZE          = 8;
  SOUND_SYSTEM_MINIMIZE          = 9;
  SOUND_SYSTEM_RESTOREUP         = 10;
  SOUND_SYSTEM_RESTOREDOWN       = 11;
  SOUND_SYSTEM_APPSTART          = 12;
  SOUND_SYSTEM_FAULT             = 13;
  SOUND_SYSTEM_APPEND            = 14;
  SOUND_SYSTEM_MENUCOMMAND       = 15;
  SOUND_SYSTEM_MENUPOPUP         = 16;
  CSOUND_SYSTEM                  = 16;
  ALERT_SYSTEM_INFORMATIONAL     = 1;       { MB_INFORMATION }
  ALERT_SYSTEM_WARNING           = 2;       { MB_WARNING }
  ALERT_SYSTEM_ERROR             = 3;       { MB_ERROR }
  ALERT_SYSTEM_QUERY             = 4;       { MB_QUESTION }
  ALERT_SYSTEM_CRITICAL          = 5;       { HardSysErrBox }
  CALERT_SYSTEM                  = 6;

function SetWinEventHook (eventMin, eventMax: DWORD; hmodWinEventProc: HMODULE;
  pfnWinEventProc: TFNWinEventProc; idProcess, idThread, dwFlags: DWORD): THandle; stdcall;

function UnhookWinEvent(hWinEventHook: THandle): BOOL; stdcall;

const
  { dwFlags for SetWinEventHook }
  WINEVENT_OUTOFCONTEXT  = $0000;  { Events are ASYNC }
  WINEVENT_SKIPOWNTHREAD = $0001;  { Don't call back for events on installer's thread }
  WINEVENT_SKIPOWNPROCESS = $0002;  { Don't call back for events on installer's process }
  WINEVENT_INCONTEXT = $0004;  { Events are SYNC, this causes your dll to be injected into every process }

type
  PGUIThreadInfo = ^TGUIThreadInfo;
  tagGUITHREADINFO = packed record
    cbSize: DWORD;
    flags: DWORD;
    hwndActive: HWND;
    hwndFocus: HWND;
    hwndCapture: HWND;
    hwndMenuOwner: HWND;
    hwndMoveSize: HWND;
    hwndCaret: HWND;
    rcCaret: TRect;
  end;
  TGUIThreadInfo = tagGUITHREADINFO;

const
  GUI_CARETBLINKING  = $00000001;
  GUI_INMOVESIZE     = $00000002;
  GUI_INMENUMODE     = $00000004;
  GUI_SYSTEMMENUMODE = $00000008;
  GUI_POPUPMENUMODE  = $00000010;

function GetGUIThreadInfo (idThread: DWORD; var pgui: TGUIThreadinfo): BOOL; stdcall;

function GetWindowModuleFileNameA(hwnd: HWND; pszFileName: PAnsiChar; cchFileNameMax: UINT): UINT; stdcall;
function GetWindowModuleFileNameW(hwnd: HWND; pszFileName: PAnsiChar; cchFileNameMax: UINT): UINT; stdcall;
function GetWindowModuleFileName(hwnd: HWND; pszFileName: PAnsiChar; cchFileNameMax: UINT): UINT; stdcall;

const
  STATE_SYSTEM_UNAVAILABLE     = $00000001;  { Disabled }
  STATE_SYSTEM_SELECTED        = $00000002;
  STATE_SYSTEM_FOCUSED         = $00000004;
  STATE_SYSTEM_PRESSED         = $00000008;
  STATE_SYSTEM_CHECKED         = $00000010;
  STATE_SYSTEM_MIXED           = $00000020;  { 3-state checkbox or toolbar button }
  STATE_SYSTEM_READONLY        = $00000040;
  STATE_SYSTEM_HOTTRACKED      = $00000080;
  STATE_SYSTEM_DEFAULT         = $00000100;
  STATE_SYSTEM_EXPANDED        = $00000200;
  STATE_SYSTEM_COLLAPSED       = $00000400;
  STATE_SYSTEM_BUSY            = $00000800;
  STATE_SYSTEM_FLOATING        = $00001000;  { Children "owned" not "contained" by parent }
  STATE_SYSTEM_MARQUEED        = $00002000;
  STATE_SYSTEM_ANIMATED        = $00004000;
  STATE_SYSTEM_INVISIBLE       = $00008000;
  STATE_SYSTEM_OFFSCREEN       = $00010000;
  STATE_SYSTEM_SIZEABLE        = $00020000;
  STATE_SYSTEM_MOVEABLE        = $00040000;
  STATE_SYSTEM_SELFVOICING     = $00080000;
  STATE_SYSTEM_FOCUSABLE       = $00100000;
  STATE_SYSTEM_SELECTABLE      = $00200000;
  STATE_SYSTEM_LINKED          = $00400000;
  STATE_SYSTEM_TRAVERSED       = $00800000;
  STATE_SYSTEM_MULTISELECTABLE = $01000000;  { Supports multiple selection }
  STATE_SYSTEM_EXTSELECTABLE   = $02000000;  { Supports extended selection }
  STATE_SYSTEM_ALERT_LOW       = $04000000;  { This information is of low priority }
  STATE_SYSTEM_ALERT_MEDIUM    = $08000000;  { This information is of medium priority }
  STATE_SYSTEM_ALERT_HIGH      = $10000000;  { This information is of high priority }
  STATE_SYSTEM_VALID           = $1FFFFFFF;

  CCHILDREN_TITLEBAR           =   5;
  CCHILDREN_SCROLLBAR          =   5;

type
  { Information about the global cursor. }
  PCursorInfo = ^TCursorInfo;
  tagCURSORINFO = packed record
    cbSize: DWORD;
    flags: DWORD;
    hCursor: HCURSOR;
    ptScreenPos: TPoint;
  end;
  TCursorInfo = tagCURSORINFO;

const
  CURSOR_SHOWING = $00000001;

function GetCursorInfo(var pci: TCursorInfo): BOOL; stdcall;

type
  { Window information snapshot }
  PWindowInfo = ^TWindowInfo;
  tagWINDOWINFO = packed record
    cbSize: DWORD;
    rcWindow: TRect;
    rcClient: TRect;
    dwStyle: DWORD;
    dwExStyle: DWORD;
    dwOtherStuff: DWORD;
    cxWindowBorders: UINT;
    cyWindowBorders: UINT;
    atomWindowType: TAtom;
    wCreatorVersion: WORD;
  end;
  TWindowInfo = tagWINDOWINFO;

const
  WS_ACTIVECAPTION = $0001;

function GetWindowInfo(hwnd: HWND; var pwi: TWindowInfo): BOOL; stdcall;

type
  { Titlebar information. }
  PTitleBarInfo = ^TTitleBarInfo;
  tagTITLEBARINFO = packed record
    cbSize: DWORD;
    rcTitleBar: TRect;
    rgstate: array [0..CCHILDREN_TITLEBAR] of DWORD;
  end;
  TTitleBarInfo = tagTITLEBARINFO;

function GetTitleBarInfo(hwnd: HWND; var pti: TTitleBarInfo): BOOL; stdcall;

type
  { Menubar information }
  PMenuBarInfo = ^TMenuBarInfo;
  tagMENUBARINFO = packed record
    cbSize: DWORD;
    rcBar: TRect;        { rect of bar, popup, item }
    hMenu: HMENU;        { real menu handle of bar, popup }
    hwndMenu: HWND;      { hwnd of item submenu if one }
{    fBarFocused:1: BOOL;} { bar, popup has the focus }
{    fFocused:1: BOOL; }  { item has the focus }
    FocusedBits: BYTE;
  end;
  TMenuBarInfo = tagMENUBARINFO;

function GetMenuBarInfo(hend: HWND; idObject, idItem: Longint;
  var pmbi: TMenuBarInfo): BOOL; stdcall;

type
  { Scrollbar information }
  PScrollBarInfo = ^TScrollBarInfo;
  tagSCROLLBARINFO = packed record
    cbSize: DWORD;
    rcScrollBar: TRect;
    dxyLineButton: Integer;
    xyThumbTop: Integer;
    xyThumbBottom: Integer;
    bogus: Integer;
    rgstate: array[0..CCHILDREN_SCROLLBAR] of DWORD;
  end;
  TScrollBarInfo = tagSCROLLBARINFO;

Function GetScrollBarInfo(hwnd: HWND; idObject: Longint;
  var psbi: TScrollBarInfo): BOOL; stdcall;

type
  { Combobox information }
  PComboBoxInfo = ^TComboBoxInfo;
  tagCOMBOBOXINFO = packed record
    cbSize: DWORD;
    rcItem: TRect;
    rcButton: TRect;
    stateButton: DWORD;
    hwndCombo: HWND;
    hwndItem: HWND;
    hwndList: HWND;
  end;
  TComboBoxInfo = tagCOMBOBOXINFO;

Function GetComboBoxInfo(hwndCombo: HWND; var pcbi: TComboBoxInfo): BOOL; stdcall;

const
  { The "real" ancestor window }
  GA_MIC       =   1;
  GA_PARENT    =   1;
  GA_ROOT      =   2;
  GA_ROOTOWNER =   3;
  GA_MAC       =   4;

FUNCTION GetAncestor(hwnd: HWND; gaFlags: UINT): HWND; stdcall;

FUNCTION RealChildWindowFromPoint(hwndParent: HWND; ptParentClientCoords: TPoint): HWND; stdcall;

function RealGetWindowClassA(hwnd: HWND; pszType: PAnsiChar; cchType: UINT): UINT; stdcall;
function RealGetWindowClassW(hwnd: HWND; pszType: PWideChar; cchType: UINT): UINT; stdcall;
function RealGetWindowClass(hwnd: HWND; pszType: PTChar; cchType: UINT): UINT; stdcall;

type
  { Alt-Tab Switch window information. }
  PAltTabInfo = ^TAltTabInfo;
  tagALTTABINFO = packed record
    cbSize: DWORD;
    cItems: Integer;
    cColumns: Integer;
    cRows: Integer;
    iColFocus: Integer;
    iRowFocus: Integer;
    cxItem: Integer;
    cyItem: Integer;
    ptStart: TPoint;
  end;
  TAltTabInfo = tagALTTABINFO;

function GetAltTabInfoA(hwnd: HWND; iItem: Integer; var pati: TAltTabInfo;
  pszItemText: PAnsiChar; cchItemText: UINT): BOOL; stdcall;
function GetAltTabInfoW(hwnd: HWND; iItem: Integer; var pati: TAltTabInfo;
  pszItemText: PWideChar; cchItemText: UINT): BOOL; stdcall;
function GetAltTabInfo(hwnd: HWND; iItem: Integer; var pati: TAltTabInfo;
  pszItemText: PTChar; cchItemText: UINT): BOOL; stdcall;

{ Listbox information. Returns the number of items per row. }
function GetListBoxInfo(hwnd: HWND): DWORD; stdcall;
function LockWorkStation: BOOL; stdcall;
function UserHandleGrantAccess(hUserHandle, hJob: THandle): BOOL; stdcall;

{ Translated from WINNLS.H }

const

{ String Length Maximums. }

  MAX_LEADBYTES = 12; { 5 ranges, 2 bytes ea., 0 term. }
  MAX_DEFAULTCHAR = 2; { single or double byte }

{ MBCS and Unicode Translation Flags. }

  MB_PRECOMPOSED = 1; { use precomposed chars }
  MB_COMPOSITE = 2; { use composite chars }
  MB_USEGLYPHCHARS = 4; { use glyph chars, not ctrl chars }

  WC_DEFAULTCHECK = $100; { check for default char }
  WC_COMPOSITECHECK = $200; { convert composite to precomposed }
  WC_DISCARDNS = $10; { discard non-spacing chars }
  WC_SEPTCharS = $20; { generate separate chars }
  WC_DEFAULTCHAR = $40; { replace w default char }

{ Character Type Flags. }

  CT_CTYPE1 = 1; { ctype 1 information }
  CT_CTYPE2 = 2; { ctype 2 information }
  CT_CTYPE3 = 4; { ctype 3 information }

{ CType 1 Flag Bits. }

  C1_UPPER = 1; { upper case }
  C1_LOWER = 2; { lower case }
  C1_DIGIT = 4; { decimal digits }
  C1_SPACE = 8; { spacing characters }
  C1_PUNCT = $10; { punctuation characters }
  C1_CNTRL = $20; { control characters }
  C1_BLANK = $40; { blank characters }
  C1_XDIGIT = $80; { other digits }
  C1_ALPHA = $100; { any letter }

{ CType 2 Flag Bits. }

  C2_LEFTTORIGHT = 1; { left to right }
  C2_RIGHTTOLEFT = 2; { right to left }
  C2_EUROPENUMBER = 3; { European number, digit }
  C2_EUROPESEPARATOR = 4; { European numeric separator }
  C2_EUROPETERMINATOR = 5; { European numeric terminator }
  C2_ARABICNUMBER = 6; { Arabic number }
  C2_COMMONSEPARATOR = 7; { common numeric separator }
  C2_BLOCKSEPARATOR = 8; { block separator }
  C2_SEGMENTSEPARATOR = 9; { segment separator }
  C2_WHITESPACE = 10; { white space }
  C2_OTHERNEUTRAL = 11; { other neutrals }
  C2_NOTAPPLICABLE = 0; { no implicit directionality }

{ CType 3 Flag Bits. }

  C3_NONSPACING = 1; { nonspacing character }
  C3_DIACRITIC = 2; { diacritic mark }
  C3_VOWELMARK = 4; { vowel mark }
  C3_SYMBOL = 8; { symbols }
  C3_KATAKANA = $0010; { katakana character }
  C3_HIRAGANA = $0020; { hiragana character }
  C3_HALFWIDTH = $0040; { half width character }
  C3_FULLWIDTH = $0080; { full width character }
  C3_IDEOGRAPH = $0100; { ideographic character }
  C3_KASHIDA = $0200; { Arabic kashida character }
  C3_LEXICAL = $0400; { lexical character }
  C3_ALPHA = $8000; { any linguistic char (C1_ALPHA) }
  C3_NOTAPPLICABLE = 0; { ctype 3 is not applicable }

{ String Flags. }

  NORM_IGNORECASE = 1; { ignore case }
  NORM_IGNORENONSPACE = 2; { ignore nonspacing chars }
  NORM_IGNORESYMBOLS = 4; { ignore symbols }
  NORM_IGNOREKANATYPE = $10000;
  NORM_IGNOREWIDTH = $20000;

{ Locale Independent Mapping Flags. }

  MAP_FOLDCZONE = $10; { fold compatibility zone chars }
  MAP_PRECOMPOSED = $20; { convert to precomposed chars }
  MAP_COMPOSITE = $40; { convert to composite chars }
  MAP_FOLDDIGITS = $80; { all digits to ASCII 0-9 }

{ Locale Dependent Mapping Flags. }

  LCMAP_LOWERCASE = $00000100;              { lower case letters }
  LCMAP_UPPERCASE = $00000200;              { upper case letters }
  LCMAP_SORTKEY = $00000400;                { WC sort key (normalize) }
  LCMAP_BYTEREV = $00000800;                { byte reversal }

  LCMAP_HIRAGANA = $00100000;               { map katakana to hiragana }
  LCMAP_KATAKANA = $00200000;               { map hiragana to katakana }
  LCMAP_HALFWIDTH = $00400000;              { map double byte to single byte }
  LCMAP_FULLWIDTH = $00800000;              { map single byte to double byte }

  LCMAP_LINGUISTIC_CASING = $01000000;      { use linguistic rules for casing }

  LCMAP_SIMPLIFIED_CHINESE      = $02000000;  { map traditional chinese to simplified chinese }
  LCMAP_TRADITIONAL_CHINESE     = $04000000;  { map simplified chinese to traditional chinese }

{ Locale Enumeration Flags. }

  LCID_INSTALLED          = $00000001;  { installed locale ids }
  LCID_SUPPORTED          = $00000002;  { supported locale ids }

{ Code Page Enumeration Flags. }

  CP_INSTALLED            = $00000001;  { installed code page ids }
  CP_SUPPORTED            = $00000002;  { supported code page ids }


{ Sorting Flags.

     WORD Sort:    culturally correct sort
                   hyphen and apostrophe are special cased
                   example: "coop" and "co-op" will sort together in a list

                         co_op     <-------  underscore (symbol)
                         coat
                         comb
                         coop
                         co-op     <-------  hyphen (punctuation)
                         cork
                         went
                         were
                         we're     <-------  apostrophe (punctuation)


     STRING Sort:  hyphen and apostrophe will sort with all other symbols

                         co-op     <-------  hyphen (punctuation)
                         co_op     <-------  underscore (symbol)
                         coat
                         comb
                         coop
                         cork
                         we're     <-------  apostrophe (punctuation)
                         went
                         were
 }

  SORT_STRINGSORT = $1000; { use string sort method }

{ Code Page Default Values. }

  CP_ACP                   = 0;             { default to ANSI code page }
  CP_OEMCP                 = 1;             { default to OEM  code page }
  CP_MACCP                 = 2;             { default to MAC  code page }

  CP_UTF7                  = 65000;         { UTF-7 translation }
  CP_UTF8                  = 65001;         { UTF-8 translation }

{ Country Codes. }

  CTRY_DEFAULT = 0;
  CTRY_AUSTRALIA = 61; { Australia }
  CTRY_AUSTRIA = 43; { Austria }
  CTRY_BELGIUM = $20; { Belgium }
  CTRY_BRAZIL = 55; { Brazil }
  CTRY_CANADA = 2; { Canada }
  CTRY_DENMARK = 45; { Denmark }
  CTRY_FINLAND = 358; { Finland }
  CTRY_FRANCE = 33; { France }
  CTRY_GERMANY = 49; { Germany }
  CTRY_ICELAND = 354; { Iceland }
  CTRY_IRELAND = 353; { Ireland }
  CTRY_ITALY = 39; { Italy }
  CTRY_JAPAN = 81; { Japan }
  CTRY_MEXICO = 52; { Mexico }
  CTRY_NETHERLANDS = 31; { Netherlands }
  CTRY_NEW_ZEALAND = $40; { New Zealand }
  CTRY_NORWAY = 47; { Norway }
  CTRY_PORTUGAL = 351; { Portugal }
  CTRY_PRCHINA = 86; { PR China }
  CTRY_SOUTH_KOREA = 82; { South Korea }
  CTRY_SPAIN = 34; { Spain }
  CTRY_SWEDEN = 46; { Sweden }
  CTRY_SWITZERLAND = 41; { Switzerland }
  CTRY_TAIWAN = 886; { Taiwan }
  CTRY_UNITED_KINGDOM = 44; { United Kingdom }
  CTRY_UNITED_STATES = 1; { United States }

{ Locale Types.
  These types are used for the GetLocaleInfoW NLS API routine. }

{ LOCALE_NOUSEROVERRIDE is also used in GetTimeFormatW and GetDateFormatW. }

  LOCALE_NOUSEROVERRIDE           = DWORD($80000000);   { do not use user overrides }
  LOCALE_USE_CP_ACP               = $40000000;   { use the system ACP }

  LOCALE_ILANGUAGE                = $00000001;   { language id }
  LOCALE_SLANGUAGE                = $00000002;   { localized name of language }
  LOCALE_SENGLANGUAGE             = $00001001;   { English name of language }
  LOCALE_SABBREVLANGNAME          = $00000003;   { abbreviated language name }
  LOCALE_SNATIVELANGNAME          = $00000004;   { native name of language }

  LOCALE_ICOUNTRY                 = $00000005;   { country code }
  LOCALE_SCOUNTRY                 = $00000006;   { localized name of country }
  LOCALE_SENGCOUNTRY              = $00001002;   { English name of country }
  LOCALE_SABBREVCTRYNAME          = $00000007;   { abbreviated country name }
  LOCALE_SNATIVECTRYNAME          = $00000008;   { native name of country }

  LOCALE_IDEFAULTLANGUAGE         = $00000009;   { default language id }
  LOCALE_IDEFAULTCOUNTRY          = $0000000A;   { default country code }
  LOCALE_IDEFAULTCODEPAGE         = $0000000B;   { default oem code page }
  LOCALE_IDEFAULTANSICODEPAGE     = $00001004;   { default ansi code page }
  LOCALE_IDEFAULTMACCODEPAGE      = $00001011;   { default mac code page }

  LOCALE_SLIST                    = $0000000C;   { list item separator }
  LOCALE_IMEASURE                 = $0000000D;   { 0 = metric, 1 = US }

  LOCALE_SDECIMAL                 = $0000000E;   { decimal separator }
  LOCALE_STHOUSAND                = $0000000F;   { thousand separator }
  LOCALE_SGROUPING                = $00000010;   { digit grouping }
  LOCALE_IDIGITS                  = $00000011;   { number of fractional digits }
  LOCALE_ILZERO                   = $00000012;   { leading zeros for decimal }
  LOCALE_INEGNUMBER               = $00001010;   { negative number mode }
  LOCALE_SNATIVEDIGITS            = $00000013;   { native ascii 0-9 }

  LOCALE_SCURRENCY                = $00000014;   { local monetary symbol }
  LOCALE_SINTLSYMBOL              = $00000015;   { intl monetary symbol }
  LOCALE_SMONDECIMALSEP           = $00000016;   { monetary decimal separator }
  LOCALE_SMONTHOUSANDSEP          = $00000017;   { monetary thousand separator }
  LOCALE_SMONGROUPING             = $00000018;   { monetary grouping }
  LOCALE_ICURRDIGITS              = $00000019;   { # local monetary digits }
  LOCALE_IINTLCURRDIGITS          = $0000001A;   { # intl monetary digits }
  LOCALE_ICURRENCY                = $0000001B;   { positive currency mode }
  LOCALE_INEGCURR                 = $0000001C;   { negative currency mode }

  LOCALE_SDATE                    = $0000001D;   { date separator }
  LOCALE_STIME                    = $0000001E;   { time separator }
  LOCALE_SSHORTDATE               = $0000001F;   { short date format string }
  LOCALE_SLONGDATE                = $00000020;   { long date format string }
  LOCALE_STIMEFORMAT              = $00001003;   { time format string }
  LOCALE_IDATE                    = $00000021;   { short date format ordering }
  LOCALE_ILDATE                   = $00000022;   { long date format ordering }
  LOCALE_ITIME                    = $00000023;   { time format specifier }
  LOCALE_ITIMEMARKPOSN            = $00001005;   { time marker position }
  LOCALE_ICENTURY                 = $00000024;   { century format specifier (short date) }
  LOCALE_ITLZERO                  = $00000025;   { leading zeros in time field }
  LOCALE_IDAYLZERO                = $00000026;   { leading zeros in day field (short date) }
  LOCALE_IMONLZERO                = $00000027;   { leading zeros in month field (short date) }
  LOCALE_S1159                    = $00000028;   { AM designator }
  LOCALE_S2359                    = $00000029;   { PM designator }

  LOCALE_ICALENDARTYPE            = $00001009;   { type of calendar specifier }
  LOCALE_IOPTIONALCALENDAR        = $0000100B;   { additional calendar types specifier }
  LOCALE_IFIRSTDAYOFWEEK          = $0000100C;   { first day of week specifier }
  LOCALE_IFIRSTWEEKOFYEAR         = $0000100D;   { first week of year specifier }

  LOCALE_SDAYNAME1                = $0000002A;   { long name for Monday }
  LOCALE_SDAYNAME2                = $0000002B;   { long name for Tuesday }
  LOCALE_SDAYNAME3                = $0000002C;   { long name for Wednesday }
  LOCALE_SDAYNAME4                = $0000002D;   { long name for Thursday }
  LOCALE_SDAYNAME5                = $0000002E;   { long name for Friday }
  LOCALE_SDAYNAME6                = $0000002F;   { long name for Saturday }
  LOCALE_SDAYNAME7                = $00000030;   { long name for Sunday }
  LOCALE_SABBREVDAYNAME1          = $00000031;   { abbreviated name for Monday }
  LOCALE_SABBREVDAYNAME2          = $00000032;   { abbreviated name for Tuesday }
  LOCALE_SABBREVDAYNAME3          = $00000033;   { abbreviated name for Wednesday }
  LOCALE_SABBREVDAYNAME4          = $00000034;   { abbreviated name for Thursday }
  LOCALE_SABBREVDAYNAME5          = $00000035;   { abbreviated name for Friday }
  LOCALE_SABBREVDAYNAME6          = $00000036;   { abbreviated name for Saturday }
  LOCALE_SABBREVDAYNAME7          = $00000037;   { abbreviated name for Sunday }
  LOCALE_SMONTHNAME1              = $00000038;   { long name for January }
  LOCALE_SMONTHNAME2              = $00000039;   { long name for February }
  LOCALE_SMONTHNAME3              = $0000003A;   { long name for March }
  LOCALE_SMONTHNAME4              = $0000003B;   { long name for April }
  LOCALE_SMONTHNAME5              = $0000003C;   { long name for May }
  LOCALE_SMONTHNAME6              = $0000003D;   { long name for June }
  LOCALE_SMONTHNAME7              = $0000003E;   { long name for July }
  LOCALE_SMONTHNAME8              = $0000003F;   { long name for August }
  LOCALE_SMONTHNAME9              = $00000040;   { long name for September }
  LOCALE_SMONTHNAME10             = $00000041;   { long name for October }
  LOCALE_SMONTHNAME11             = $00000042;   { long name for November }
  LOCALE_SMONTHNAME12             = $00000043;   { long name for December }
  LOCALE_SMONTHNAME13             = $0000100E;   { long name for 13th month (if exists) }
  LOCALE_SABBREVMONTHNAME1        = $00000044;   { abbreviated name for January }
  LOCALE_SABBREVMONTHNAME2        = $00000045;   { abbreviated name for February }
  LOCALE_SABBREVMONTHNAME3        = $00000046;   { abbreviated name for March }
  LOCALE_SABBREVMONTHNAME4        = $00000047;   { abbreviated name for April }
  LOCALE_SABBREVMONTHNAME5        = $00000048;   { abbreviated name for May }
  LOCALE_SABBREVMONTHNAME6        = $00000049;   { abbreviated name for June }
  LOCALE_SABBREVMONTHNAME7        = $0000004A;   { abbreviated name for July }
  LOCALE_SABBREVMONTHNAME8        = $0000004B;   { abbreviated name for August }
  LOCALE_SABBREVMONTHNAME9        = $0000004C;   { abbreviated name for September }
  LOCALE_SABBREVMONTHNAME10       = $0000004D;   { abbreviated name for October }
  LOCALE_SABBREVMONTHNAME11       = $0000004E;   { abbreviated name for November }
  LOCALE_SABBREVMONTHNAME12       = $0000004F;   { abbreviated name for December }
  LOCALE_SABBREVMONTHNAME13       = $0000100F;   { abbreviated name for 13th month (if exists) }

  LOCALE_SPOSITIVESIGN            = $00000050;   { positive sign }
  LOCALE_SNEGATIVESIGN            = $00000051;   { negative sign }
  LOCALE_IPOSSIGNPOSN             = $00000052;   { positive sign position }
  LOCALE_INEGSIGNPOSN             = $00000053;   { negative sign position }
  LOCALE_IPOSSYMPRECEDES          = $00000054;   { mon sym precedes pos amt }
  LOCALE_IPOSSEPBYSPACE           = $00000055;   { mon sym sep by space from pos amt }
  LOCALE_INEGSYMPRECEDES          = $00000056;   { mon sym precedes neg amt }
  LOCALE_INEGSEPBYSPACE           = $00000057;   { mon sym sep by space from neg amt }

  LOCALE_FONTSIGNATURE            = $00000058;   { font signature }
  LOCALE_SISO639LANGNAME          = $00000059;   { ISO abbreviated language name }
  LOCALE_SISO3166CTRYNAME         = $0000005A;   { ISO abbreviated country name }

{ Time Flags for GetTimeFormatW. }

  TIME_NOMINUTESORSECONDS = 1; { do not use minutes or seconds }
  TIME_NOSECONDS = 2; { do not use seconds }
  TIME_NOTIMEMARKER = 4; { do not use time marker }
  TIME_FORCE24HOURFORMAT = 8; { always use 24 hour format }

{ Date Flags for GetDateFormatW. }

  DATE_SHORTDATE = 1; { use short date picture }
  DATE_LONGDATE = 2; { use long date picture }
  DATE_USE_ALT_CALENDAR = 4;   { use alternate calendar (if any) }

{ Calendar Types.
  These types are used for the GetALTCalendarInfoW NLS API routine. }

  CAL_ICALINTVALUE = 1;   { calendar type }
  CAL_SCALNAME = 2;   { native name of calendar }
  CAL_IYEAROFFSETRANGE = 3;   { starting years of eras }
  CAL_SERASTRING = 4;   { era name for IYearOffsetRanges }
  CAL_SSHORTDATE = 5;   { short date format string }
  CAL_SLONGDATE = 6;   { long date format string }
  CAL_SDAYNAME1 = 7;   { native name for Monday }
  CAL_SDAYNAME2 = 8;   { native name for Tuesday }
  CAL_SDAYNAME3 = 9;   { native name for Wednesday }
  CAL_SDAYNAME4 = 10;   { native name for Thursday }
  CAL_SDAYNAME5 = 11;   { native name for Friday }
  CAL_SDAYNAME6 = 12;   { native name for Saturday }
  CAL_SDAYNAME7 = 13;   { native name for Sunday }
  CAL_SABBREVDAYNAME1 = 14;   { abbreviated name for Monday }
  CAL_SABBREVDAYNAME2 = 15;   { abbreviated name for Tuesday }
  CAL_SABBREVDAYNAME3 = $10;   { abbreviated name for Wednesday }
  CAL_SABBREVDAYNAME4 = 17;   { abbreviated name for Thursday }
  CAL_SABBREVDAYNAME5 = 18;   { abbreviated name for Friday }
  CAL_SABBREVDAYNAME6 = 19;   { abbreviated name for Saturday }
  CAL_SABBREVDAYNAME7 = 20;   { abbreviated name for Sunday }
  CAL_SMONTHNAME1 = 21;   { native name for January }
  CAL_SMONTHNAME2 = 22;   { native name for February }
  CAL_SMONTHNAME3 = 23;   { native name for March }
  CAL_SMONTHNAME4 = 24;   { native name for April }
  CAL_SMONTHNAME5 = 25;   { native name for May }
  CAL_SMONTHNAME6 = 26;   { native name for June }
  CAL_SMONTHNAME7 = 27;   { native name for July }
  CAL_SMONTHNAME8 = 28;   { native name for August }
  CAL_SMONTHNAME9 = 29;   { native name for September }
  CAL_SMONTHNAME10 = 30;   { native name for October }
  CAL_SMONTHNAME11 = 31;   { native name for November }
  CAL_SMONTHNAME12 = $20;   { native name for December }
  CAL_SMONTHNAME13 = 33;   { native name for 13th month (if any) }
  CAL_SABBREVMONTHNAME1 = 34;   { abbreviated name for January }
  CAL_SABBREVMONTHNAME2 = 35;   { abbreviated name for February }
  CAL_SABBREVMONTHNAME3 = 36;   { abbreviated name for March }
  CAL_SABBREVMONTHNAME4 = 37;   { abbreviated name for April }
  CAL_SABBREVMONTHNAME5 = 38;   { abbreviated name for May }
  CAL_SABBREVMONTHNAME6 = 39;   { abbreviated name for June }
  CAL_SABBREVMONTHNAME7 = 40;   { abbreviated name for July }
  CAL_SABBREVMONTHNAME8 = 41;   { abbreviated name for August }
  CAL_SABBREVMONTHNAME9 = 42;   { abbreviated name for September }
  CAL_SABBREVMONTHNAME10 = 43;   { abbreviated name for October }
  CAL_SABBREVMONTHNAME11 = 44;   { abbreviated name for November }
  CAL_SABBREVMONTHNAME12 = 45;   { abbreviated name for December }
  CAL_SABBREVMONTHNAME13 = 46;   { abbreviated name for 13th month (if any) }

{ Calendar Enumeration Value. }

  ENUM_ALL_CALENDARS = DWORD($FFFFFFFF);   { enumerate all calendars }

{ Calendar ID Values. }

  CAL_GREGORIAN = 1;           { Gregorian (localized) calendar }
  CAL_GREGORIAN_US = 2;        { Gregorian (U.S.) calendar }
  CAL_JAPAN = 3;               { Japanese Emperor Era calendar }
  CAL_TAIWAN = 4;              { Republic of China Era calendar }
  CAL_KOREA = 5;               { Korean Tangun Era calendar }
  CAL_HIJRI = 6;               { Hijri (Arabic Lunar) calendar }
  CAL_THAI = 7;                { Thai calendar }
  CAL_HEBREW = 8;              { Hebrew calendar }


type
  LCTYPE = DWORD;   { Locale type constant. }
  CALTYPE = DWORD;  { Calendar type constant. }
  CALID = DWORD;    { Calendar ID. }

  PCPInfo = ^TCPInfo;
  _cpinfo = record
    MaxCharSize: UINT;                       { max length (bytes) of a char }
    DefaultChar: array[0..MAX_DEFAULTCHAR - 1] of Byte; { default character }
    LeadByte: array[0..MAX_LEADBYTES - 1] of Byte;      { lead byte ranges }
  end;
  TCPInfo = _cpinfo;
  CPINFO = _cpinfo;

type
  PNumberFmtA = ^TNumberFmtA;
  PNumberFmtW = ^TNumberFmtW;
  PNumberFmt = PNumberFmtA;
  _numberfmtA = packed record
    NumDigits: UINT;        { number of decimal digits }
    LeadingZero: UINT;      { if leading zero in decimal fields }
    Grouping: UINT;         { group size left of decimal }
    lpDecimalSep: PAnsiChar;   { ptr to decimal separator string }
    lpThousandSep: PAnsiChar;  { ptr to thousand separator string }
    NegativeOrder: UINT;    { negative number ordering }
  end;
  _numberfmtW = packed record
    NumDigits: UINT;        { number of decimal digits }
    LeadingZero: UINT;      { if leading zero in decimal fields }
    Grouping: UINT;         { group size left of decimal }
    lpDecimalSep: PWideChar;   { ptr to decimal separator string }
    lpThousandSep: PWideChar;  { ptr to thousand separator string }
    NegativeOrder: UINT;    { negative number ordering }
  end;
  _numberfmt = _numberfmtA;
  TNumberFmtA = _numberfmtA;
  TNumberFmtW = _numberfmtW;
  TNumberFmt = TNumberFmtA;
  NUMBERFMTA = _numberfmtA;
  NUMBERFMTW = _numberfmtW;
  NUMBERFMT = NUMBERFMTA;

  PCurrencyFmtA = ^TCurrencyFmtA;
  PCurrencyFmtW = ^TCurrencyFmtW;
  PCurrencyFmt = PCurrencyFmtA;
  _currencyfmtA = packed record
    NumDigits: UINT;           { number of decimal digits }
    LeadingZero: UINT;         { if leading zero in decimal fields }
    Grouping: UINT;            { group size left of decimal }
    lpDecimalSep: PAnsiChar;      { ptr to decimal separator string }
    lpThousandSep: PAnsiChar;     { ptr to thousand separator string }
    NegativeOrder: UINT;       { negative currency ordering }
    PositiveOrder: UINT;       { positive currency ordering }
    lpCurrencySymbol: PAnsiChar;  { ptr to currency symbol string }
  end;
  _currencyfmtW = packed record
    NumDigits: UINT;           { number of decimal digits }
    LeadingZero: UINT;         { if leading zero in decimal fields }
    Grouping: UINT;            { group size left of decimal }
    lpDecimalSep: PWideChar;      { ptr to decimal separator string }
    lpThousandSep: PWideChar;     { ptr to thousand separator string }
    NegativeOrder: UINT;       { negative currency ordering }
    PositiveOrder: UINT;       { positive currency ordering }
    lpCurrencySymbol: PWideChar;  { ptr to currency symbol string }
  end;
  _currencyfmt = _currencyfmtA;
  TCurrencyFmtA = _currencyfmtA;
  TCurrencyFmtW = _currencyfmtW;
  TCurrencyFmt = TCurrencyFmtA;
  CURRENCYFMTA = _currencyfmtA;
  CURRENCYFMTW = _currencyfmtW;
  CURRENCYFMT = CURRENCYFMTA;

{ Enumeration function constants. }

  TFNLocaleEnumProc = TFarProc;
  TFNCodepageEnumProc = TFarProc;
  TFNDateFmtEnumProc = TFarProc;
  TFNTimeFmtEnumProc = TFarProc;
  TFNCalInfoEnumProc = TFarProc;


{ Code Page Dependent APIs. }

function IsValidCodePage(CodePage: UINT): BOOL; stdcall;
function GetACP: UINT; stdcall;
function GetOEMCP: UINT; stdcall;
function GetCPInfo(CodePage: UINT; var lpCPInfo: TCPInfo): BOOL; stdcall;
function IsDBCSLeadByte(TestChar: Byte): BOOL; stdcall;
function IsDBCSLeadByteEx(CodePage: UINT; TestChar: Byte): BOOL; stdcall;
function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD;
  const lpMultiByteStr: LPCSTR; cchMultiByte: Integer;
  lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer; stdcall;
function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD;
  lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR;
  cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer; stdcall;

{ Locale Dependent APIs. }

function CompareStringA(Locale: LCID; dwCmpFlags: DWORD; lpString1: PAnsiChar;
  cchCount1: Integer; lpString2: PAnsiChar; cchCount2: Integer): Integer; stdcall;
function CompareStringW(Locale: LCID; dwCmpFlags: DWORD; lpString1: PWideChar;
  cchCount1: Integer; lpString2: PWideChar; cchCount2: Integer): Integer; stdcall;
function CompareString(Locale: LCID; dwCmpFlags: DWORD; lpString1: PTChar;
  cchCount1: Integer; lpString2: PTChar; cchCount2: Integer): Integer; stdcall;
function LCMapStringA(Locale: LCID; dwMapFlags: DWORD; lpSrcStr: PAnsiChar;
  cchSrc: Integer; lpDestStr: PAnsiChar; cchDest: Integer): Integer; stdcall;
function LCMapStringW(Locale: LCID; dwMapFlags: DWORD; lpSrcStr: PWideChar;
  cchSrc: Integer; lpDestStr: PWideChar; cchDest: Integer): Integer; stdcall;
function LCMapString(Locale: LCID; dwMapFlags: DWORD; lpSrcStr: PTChar;
  cchSrc: Integer; lpDestStr: PTChar; cchDest: Integer): Integer; stdcall;
function GetLocaleInfoA(Locale: LCID; LCType: LCTYPE; lpLCData: PAnsiChar; cchData: Integer): Integer; stdcall;
function GetLocaleInfoW(Locale: LCID; LCType: LCTYPE; lpLCData: PWideChar; cchData: Integer): Integer; stdcall;
function GetLocaleInfo(Locale: LCID; LCType: LCTYPE; lpLCData: PTChar; cchData: Integer): Integer; stdcall;
function SetLocaleInfoA(Locale: LCID; LCType: LCTYPE; lpLCData: PAnsiChar): BOOL; stdcall;
function SetLocaleInfoW(Locale: LCID; LCType: LCTYPE; lpLCData: PWideChar): BOOL; stdcall;
function SetLocaleInfo(Locale: LCID; LCType: LCTYPE; lpLCData: PTChar): BOOL; stdcall;
function GetTimeFormatA(Locale: LCID; dwFlags: DWORD; lpTime: PSystemTime;
  lpFormat: PAnsiChar; lpTimeStr: PAnsiChar; cchTime: Integer): Integer; stdcall;
function GetTimeFormatW(Locale: LCID; dwFlags: DWORD; lpTime: PSystemTime;
  lpFormat: PWideChar; lpTimeStr: PWideChar; cchTime: Integer): Integer; stdcall;
function GetTimeFormat(Locale: LCID; dwFlags: DWORD; lpTime: PSystemTime;
  lpFormat: PTChar; lpTimeStr: PTChar; cchTime: Integer): Integer; stdcall;
function GetDateFormatA(Locale: LCID; dwFlags: DWORD; lpDate: PSystemTime;
  lpFormat: PAnsiChar; lpDateStr: PAnsiChar; cchDate: Integer): Integer; stdcall;
function GetDateFormatW(Locale: LCID; dwFlags: DWORD; lpDate: PSystemTime;
  lpFormat: PWideChar; lpDateStr: PWideChar; cchDate: Integer): Integer; stdcall;
function GetDateFormat(Locale: LCID; dwFlags: DWORD; lpDate: PSystemTime;
  lpFormat: PTChar; lpDateStr: PTChar; cchDate: Integer): Integer; stdcall;
function GetNumberFormatA(Locale: LCID; dwFlags: DWORD; lpValue: PAnsiChar;
  lpFormat: PNumberFmtA; lpNumberStr: PAnsiChar; cchNumber: Integer): Integer; stdcall;
function GetNumberFormatW(Locale: LCID; dwFlags: DWORD; lpValue: PWideChar;
  lpFormat: PNumberFmtW; lpNumberStr: PWideChar; cchNumber: Integer): Integer; stdcall;
function GetNumberFormat(Locale: LCID; dwFlags: DWORD; lpValue: PTChar;
  lpFormat: PNumberFmt; lpNumberStr: PTChar; cchNumber: Integer): Integer; stdcall;
function GetCurrencyFormatA(Locale: LCID; dwFlags: DWORD; lpValue: PAnsiChar;
  lpFormat: PCurrencyFmtA; lpCurrencyStr: PAnsiChar; cchCurrency: Integer): Integer; stdcall;
function GetCurrencyFormatW(Locale: LCID; dwFlags: DWORD; lpValue: PWideChar;
  lpFormat: PCurrencyFmtW; lpCurrencyStr: PWideChar; cchCurrency: Integer): Integer; stdcall;
function GetCurrencyFormat(Locale: LCID; dwFlags: DWORD; lpValue: PTChar;
  lpFormat: PCurrencyFmt; lpCurrencyStr: PTChar; cchCurrency: Integer): Integer; stdcall;
function EnumCalendarInfoA(lpCalInfoEnumProc: TFNCalInfoEnumProc; Locale: LCID;
  Calendar: CALID; CalType: CALTYPE): BOOL; stdcall;
function EnumCalendarInfoW(lpCalInfoEnumProc: TFNCalInfoEnumProc; Locale: LCID;
  Calendar: CALID; CalType: CALTYPE): BOOL; stdcall;
function EnumCalendarInfo(lpCalInfoEnumProc: TFNCalInfoEnumProc; Locale: LCID;
  Calendar: CALID; CalType: CALTYPE): BOOL; stdcall;
function EnumTimeFormatsA(lpTimeFmtEnumProc: TFNTimeFmtEnumProc;
  Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function EnumTimeFormatsW(lpTimeFmtEnumProc: TFNTimeFmtEnumProc;
  Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function EnumTimeFormats(lpTimeFmtEnumProc: TFNTimeFmtEnumProc;
  Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function EnumDateFormatsA(lpDateFmtEnumProc: TFNDateFmtEnumProc;
  Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function EnumDateFormatsW(lpDateFmtEnumProc: TFNDateFmtEnumProc;
  Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function EnumDateFormats(lpDateFmtEnumProc: TFNDateFmtEnumProc;
  Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function IsValidLocale(Locale: LCID; dwFlags: DWORD): BOOL; stdcall;
function ConvertDefaultLocale(Locale: LCID): LCID; stdcall;
function GetThreadLocale: LCID; stdcall;
function SetThreadLocale(Locale: LCID): BOOL; stdcall;
function GetSystemDefaultLangID: LANGID; stdcall;
function GetUserDefaultLangID: LANGID; stdcall;
function GetSystemDefaultLCID: LCID; stdcall;
function GetUserDefaultLCID: LCID; stdcall;

{ Locale Independent APIs. }

function GetStringTypeExA(Locale: LCID; dwInfoType: DWORD;
  lpSrcStr: PAnsiChar; cchSrc: Integer; var lPTCharType): BOOL; stdcall;
function GetStringTypeExW(Locale: LCID; dwInfoType: DWORD;
  lpSrcStr: PWideChar; cchSrc: Integer; var lPTCharType): BOOL; stdcall;
function GetStringTypeEx(Locale: LCID; dwInfoType: DWORD;
  lpSrcStr: PTChar; cchSrc: Integer; var lPTCharType): BOOL; stdcall;

{  NOTE: The parameters for GetStringTypeA and GetStringTypeW are
         NOT the same.  The W version was shipped in NT 3.1.  The
         A version was then shipped in 16-bit OLE with the wrong
         parameters (ported from Win95).  To be compatible, we
         must break the relationship between the A and W versions
         of GetStringType.  There will be NO function call for the
         generic GetStringType.

         GetStringTypeEx (above) should be used instead. }

function GetStringTypeA(Locale: LCID; dwInfoType: DWORD; const lpSrcStr: LPCSTR; cchSrc: BOOL; var lPTCharType: Word): BOOL;
function GetStringTypeW(dwInfoType: DWORD; const lpSrcStr: WCHAR; cchSrc: BOOL; var lPTCharType: Word): BOOL;

function FoldStringA(dwMapFlags: DWORD; lpSrcStr: PAnsiChar; cchSrc: Integer;
  lpDestStr: PAnsiChar; cchDest: Integer): Integer; stdcall;
function FoldStringW(dwMapFlags: DWORD; lpSrcStr: PWideChar; cchSrc: Integer;
  lpDestStr: PWideChar; cchDest: Integer): Integer; stdcall;
function FoldString(dwMapFlags: DWORD; lpSrcStr: PTChar; cchSrc: Integer;
  lpDestStr: PTChar; cchDest: Integer): Integer; stdcall;
function EnumSystemLocalesA(lpLocaleEnumProc: TFNLocaleEnumProc; dwFlags: DWORD): BOOL; stdcall;
function EnumSystemLocalesW(lpLocaleEnumProc: TFNLocaleEnumProc; dwFlags: DWORD): BOOL; stdcall;
function EnumSystemLocales(lpLocaleEnumProc: TFNLocaleEnumProc; dwFlags: DWORD): BOOL; stdcall;
function EnumSystemCodePagesA(lpCodePageEnumProc: TFNCodepageEnumProc; dwFlags: DWORD): BOOL; stdcall;
function EnumSystemCodePagesW(lpCodePageEnumProc: TFNCodepageEnumProc; dwFlags: DWORD): BOOL; stdcall;
function EnumSystemCodePages(lpCodePageEnumProc: TFNCodepageEnumProc; dwFlags: DWORD): BOOL; stdcall;


{ Translated from WINCON.H }

{ This module contains the public data structures, data types,
    and procedures exported by the NT console subsystem. }

type
  PCoord = ^TCoord;
  _COORD = packed record
    X: SHORT;
    Y: SHORT;
  end;
  TCoord = _COORD;
  COORD = _COORD;

  PSmallRect = ^TSmallRect;
  _SMALL_RECT = packed record
    Left: SHORT;
    Top: SHORT;
    Right: SHORT;
    Bottom: SHORT;
  end;
  TSmallRect = _SMALL_RECT;
  SMALL_RECT = _SMALL_RECT;

  PKeyEventRecord = ^TKeyEventRecord;
  _KEY_EVENT_RECORD = packed record
    bKeyDown: BOOL;
    wRepeatCount: Word;
    wVirtualKeyCode: Word;
    wVirtualScanCode: Word;
    case Integer of
      0: (
        UnicodeChar: WCHAR;
        dwControlKeyState: DWORD);
      1: (
        AsciiChar: AnsiChar);
  end;
  TKeyEventRecord = _KEY_EVENT_RECORD;
  KEY_EVENT_RECORD = _KEY_EVENT_RECORD;

const
{ ControlKeyState flags }

  RIGHT_ALT_PRESSED = 1;     { the right alt key is pressed. }
  LEFT_ALT_PRESSED = 2;     { the left alt key is pressed. }
  RIGHT_CTRL_PRESSED = 4;     { the right ctrl key is pressed. }
  LEFT_CTRL_PRESSED = 8;     { the left ctrl key is pressed. }
  SHIFT_PRESSED = $10;     { the shift key is pressed. }
  NUMLOCK_ON = $20;     { the numlock light is on. }
  SCROLLLOCK_ON = $40;     { the scrolllock light is on. }
  CAPSLOCK_ON = $80;     { the capslock light is on. }
  ENHANCED_KEY = $100;     { the key is enhanced. }

type
  PMouseEventRecord = ^TMouseEventRecord;
  _MOUSE_EVENT_RECORD = record
    dwMousePosition: TCoord;
    dwButtonState: DWORD;
    dwControlKeyState: DWORD;
    dwEventFlags: DWORD;
  end;
  TMouseEventRecord = _MOUSE_EVENT_RECORD;
  MOUSE_EVENT_RECORD = _MOUSE_EVENT_RECORD;

const
{ ButtonState flags }

  FROM_LEFT_1ST_BUTTON_PRESSED = 1;
  RIGHTMOST_BUTTON_PRESSED = 2;
  FROM_LEFT_2ND_BUTTON_PRESSED = 4;
  FROM_LEFT_3RD_BUTTON_PRESSED = 8;
  FROM_LEFT_4TH_BUTTON_PRESSED = $10;

{ EventFlags }

  MOUSE_MOVED = 1;
  DOUBLE_CLICK = 2;
  MOUSE_WHEELED = 4;
  MOUSE_HWHEELED = 8;

type
  PWindowBufferSizeRecord = ^TWindowBufferSizeRecord;
  _WINDOW_BUFFER_SIZE_RECORD = packed record
    dwSize: TCoord;
  end;
  TWindowBufferSizeRecord = _WINDOW_BUFFER_SIZE_RECORD;
  WINDOW_BUFFER_SIZE_RECORD = _WINDOW_BUFFER_SIZE_RECORD;

  PMenuEventRecord = ^TMenuEventRecord;
  _MENU_EVENT_RECORD = packed record
    dwCommandId: UINT;
  end;
  TMenuEventRecord = _MENU_EVENT_RECORD;
  MENU_EVENT_RECORD = _MENU_EVENT_RECORD;

  PFocusEventRecord = ^TFocusEventRecord;
  _FOCUS_EVENT_RECORD = packed record
    bSetFocus: BOOL;
  end;
  TFocusEventRecord = _FOCUS_EVENT_RECORD;
  FOCUS_EVENT_RECORD = _FOCUS_EVENT_RECORD;

  PInputRecord = ^TInputRecord;
  _INPUT_RECORD = record
    EventType: Word;
    Reserved: Word;
    Event: Record case Integer of
      0: (KeyEvent: TKeyEventRecord);
      1: (MouseEvent: TMouseEventRecord);
      2: (WindowBufferSizeEvent: TWindowBufferSizeRecord);
      3: (MenuEvent: TMenuEventRecord);
      4: (FocusEvent: TFocusEventRecord);
    end;
  end;
  TInputRecord = _INPUT_RECORD;
  INPUT_RECORD = _INPUT_RECORD;


const
{  EventType flags: }

  KEY_EVENT = 1;       { Event contains key event record}
  _MOUSE_EVENT = 2;  { Renamed }   { Event contains mouse event record }
  WINDOW_BUFFER_SIZE_EVENT = 4;  { Event contains window change event record }
  MENU_EVENT = 8;     { Event contains menu event record }
  FOCUS_EVENT = $10;  { event contains focus change }

type
  PCharInfo = ^TCharInfo;
  _CHAR_INFO = record
    case Integer of
      0: (
        UnicodeChar: WCHAR;
        Attributes: Word);
      1: (
        AsciiChar: AnsiChar);
  end;
  TCharInfo = _CHAR_INFO;
  CHAR_INFO = _CHAR_INFO;

const
{ Attributes flags:}

  FOREGROUND_BLUE = 1;    { text color contains blue.}
  FOREGROUND_GREEN = 2;     { text color contains green. }
  FOREGROUND_RED = 4;     { text color contains red. }
  FOREGROUND_INTENSITY = 8;     { text color is intensified. }
  BACKGROUND_BLUE = $10;     { background color contains blue. }
  BACKGROUND_GREEN = $20;     { background color contains green. }
  BACKGROUND_RED = $40;     { background color contains red. }
  BACKGROUND_INTENSITY = $80;     { background color is intensified. }

type
  PConsoleScreenBufferInfo = ^TConsoleScreenBufferInfo;
  _CONSOLE_SCREEN_BUFFER_INFO = packed record
    dwSize: TCoord;
    dwCursorPosition: TCoord;
    wAttributes: Word;
    srWindow: TSmallRect;
    dwMaximumWindowSize: TCoord;
  end;
  TConsoleScreenBufferInfo = _CONSOLE_SCREEN_BUFFER_INFO;
  CONSOLE_SCREEN_BUFFER_INFO = _CONSOLE_SCREEN_BUFFER_INFO;

  PConsoleCursorInfo = ^TConsoleCursorInfo;
  _CONSOLE_CURSOR_INFO = packed record
    dwSize: DWORD;
    bVisible: BOOL;
  end;
  TConsoleCursorInfo = _CONSOLE_CURSOR_INFO;
  CONSOLE_CURSOR_INFO = _CONSOLE_CURSOR_INFO;




  TFNHandlerRoutine = TFarProc;


const
  CTRL_C_EVENT = 0;
  CTRL_BREAK_EVENT = 1;
  CTRL_CLOSE_EVENT = 2;
  { 3 is reserved! }
  { 4 is reserved! }

  CTRL_LOGOFF_EVENT = 5;
  CTRL_SHUTDOWN_EVENT = 6;
  ENABLE_PROCESSED_INPUT = 1;     {  Input Mode flags: }
  ENABLE_LINE_INPUT = 2;
  ENABLE_ECHO_INPUT = 4;
  ENABLE_WINDOW_INPUT = 8;
  ENABLE_MOUSE_INPUT = $10;
  ENABLE_PROCESSED_OUTPUT = 1;     { Output Mode flags: }
  ENABLE_WRAP_AT_EOL_OUTPUT = 2;

{ direct API definitions. }
function PeekConsoleInputA(hConsoleInput: THandle; var lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall;
function PeekConsoleInputW(hConsoleInput: THandle; var lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall;
function PeekConsoleInput(hConsoleInput: THandle; var lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall;
function ReadConsoleInputA(hConsoleInput: THandle; var lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall;
function ReadConsoleInputW(hConsoleInput: THandle; var lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall;
function ReadConsoleInput(hConsoleInput: THandle; var lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall;
function WriteConsoleInputA(hConsoleInput: THandle; const lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsWritten: DWORD): BOOL; stdcall;
function WriteConsoleInputW(hConsoleInput: THandle; const lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsWritten: DWORD): BOOL; stdcall;
function WriteConsoleInput(hConsoleInput: THandle; const lpBuffer: TInputRecord;
  nLength: DWORD; var lpNumberOfEventsWritten: DWORD): BOOL; stdcall;
function ReadConsoleOutputA(hConsoleOutput: THandle; lpBuffer: Pointer;
  dwBufferSize, dwBufferCoord: TCoord; var lpReadRegion: TSmallRect): BOOL; stdcall;
function ReadConsoleOutputW(hConsoleOutput: THandle; lpBuffer: Pointer;
  dwBufferSize, dwBufferCoord: TCoord; var lpReadRegion: TSmallRect): BOOL; stdcall;
function ReadConsoleOutput(hConsoleOutput: THandle; lpBuffer: Pointer;
  dwBufferSize, dwBufferCoord: TCoord; var lpReadRegion: TSmallRect): BOOL; stdcall;
function WriteConsoleOutputA(hConsoleOutput: THandle; lpBuffer: Pointer;
  dwBufferSize, dwBufferCoord: TCoord; var lpWriteRegion: TSmallRect): BOOL; stdcall;
function WriteConsoleOutputW(hConsoleOutput: THandle; lpBuffer: Pointer;
  dwBufferSize, dwBufferCoord: TCoord; var lpWriteRegion: TSmallRect): BOOL; stdcall;
function WriteConsoleOutput(hConsoleOutput: THandle; lpBuffer: Pointer;
  dwBufferSize, dwBufferCoord: TCoord; var lpWriteRegion: TSmallRect): BOOL; stdcall;
function ReadConsoleOutputCharacterA(hConsoleOutput: THandle; lPTCharacter: PAnsiChar;
  nLength: DWORD; dwReadCoord: TCoord; var lpNumberOfCharsRead: DWORD): BOOL; stdcall;
function ReadConsoleOutputCharacterW(hConsoleOutput: THandle; lPTCharacter: PAnsiChar;
  nLength: DWORD; dwReadCoord: TCoord; var lpNumberOfCharsRead: DWORD): BOOL; stdcall;
function ReadConsoleOutputCharacter(hConsoleOutput: THandle; lPTCharacter: PAnsiChar;
  nLength: DWORD; dwReadCoord: TCoord; var lpNumberOfCharsRead: DWORD): BOOL; stdcall;
function ReadConsoleOutputAttribute(hConsoleOutput: THandle; lpAttribute: Pointer;
  nLength: DWORD; dwReadCoord: TCoord; var lpNumberOfAttrsRead: DWORD): BOOL; stdcall;
function WriteConsoleOutputCharacterA(hConsoleOutput: THandle;lPTCharacter: PAnsiChar;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall;
function WriteConsoleOutputCharacterW(hConsoleOutput: THandle;lPTCharacter: PWideChar;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall;
function WriteConsoleOutputCharacter(hConsoleOutput: THandle;lPTCharacter: PTChar;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall;
function WriteConsoleOutputAttribute(hConsoleOutput: THandle; lpAttribute: Pointer;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfAttrsWritten: DWORD): BOOL; stdcall;
function FillConsoleOutputCharacterA(hConsoleOutput: THandle; cCharacter: AnsiChar;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall;
function FillConsoleOutputCharacterW(hConsoleOutput: THandle; cCharacter: WideChar;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall;
function FillConsoleOutputCharacter(hConsoleOutput: THandle; cCharacter: TChar;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall;
function FillConsoleOutputAttribute(hConsoleOutput: THandle; wAttribute: Word;
  nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfAttrsWritten: DWORD): BOOL; stdcall;
function GetConsoleMode(hConsoleHandle: THandle; var lpMode: DWORD): BOOL; stdcall;
function GetNumberOfConsoleInputEvents(hConsoleInput: THandle;
  var lpNumberOfEvents: DWORD): BOOL; stdcall;
function GetConsoleScreenBufferInfo(hConsoleOutput: THandle;
  var lpConsoleScreenBufferInfo: TConsoleScreenBufferInfo): BOOL; stdcall;
function GetLargestConsoleWindowSize(hConsoleOutput: THandle): TCoord; stdcall;
function GetConsoleCursorInfo(hConsoleOutput: THandle;
  var lpConsoleCursorInfo: TConsoleCursorInfo): BOOL; stdcall;
function GetNumberOfConsoleMouseButtons(var lpNumberOfMouseButtons: DWORD): BOOL; stdcall;
function SetConsoleMode(hConsoleHandle: THandle; dwMode: DWORD): BOOL; stdcall;
function SetConsoleActiveScreenBuffer(hConsoleOutput: THandle): BOOL; stdcall;
function FlushConsoleInputBuffer(hConsoleInput: THandle): BOOL; stdcall;
function SetConsoleScreenBufferSize(hConsoleOutput: THandle; dwSize: TCoord): BOOL; stdcall;
function SetConsoleCursorPosition(hConsoleOutput: THandle; dwCursorPosition: TCoord): BOOL; stdcall;
function SetConsoleCursorInfo(hConsoleOutput: THandle;
  const lpConsoleCursorInfo: TConsoleCursorInfo): BOOL; stdcall;
function ScrollConsoleScreenBufferA(hConsoleOutput: THandle;
  const lpScrollRectangle: TSmallRect; lpClipRectangle: PSmallRect;
  dwDestinationOrigin: TCoord; var lpFill: TCharInfo): BOOL; stdcall;
function ScrollConsoleScreenBufferW(hConsoleOutput: THandle;
  const lpScrollRectangle: TSmallRect; lpClipRectangle: PSmallRect;
  dwDestinationOrigin: TCoord; var lpFill: TCharInfo): BOOL; stdcall;
function ScrollConsoleScreenBuffer(hConsoleOutput: THandle;
  const lpScrollRectangle: TSmallRect; lpClipRectangle: PSmallRect;
  dwDestinationOrigin: TCoord; var lpFill: TCharInfo): BOOL; stdcall;
function SetConsoleWindowInfo(hConsoleOutput: THandle; bAbsolute: BOOL;
  const lpConsoleWindow: TSmallRect): BOOL; stdcall;
function SetConsoleTextAttribute(hConsoleOutput: THandle; wAttributes: Word): BOOL; stdcall;
function SetConsoleCtrlHandler(HandlerRoutine: TFNHandlerRoutine; Add: BOOL): BOOL; stdcall;
function GenerateConsoleCtrlEvent(dwCtrlEvent: DWORD; dwProcessGroupId: DWORD): BOOL; stdcall;
function AllocConsole: BOOL; stdcall;
function FreeConsole: BOOL; stdcall;
function GetConsoleTitleA(lpConsoleTitle: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function GetConsoleTitleW(lpConsoleTitle: PWideChar; nSize: DWORD): DWORD; stdcall;
function GetConsoleTitle(lpConsoleTitle: PTChar; nSize: DWORD): DWORD; stdcall;
function SetConsoleTitleA(lpConsoleTitle: PAnsiChar): BOOL; stdcall;
function SetConsoleTitleW(lpConsoleTitle: PWideChar): BOOL; stdcall;
function SetConsoleTitle(lpConsoleTitle: PTChar): BOOL; stdcall;
function ReadConsoleA(hConsoleInput: THandle; lpBuffer: Pointer;
  nNumberOfCharsToRead: DWORD; var lpNumberOfCharsRead: DWORD; lpReserved: Pointer): BOOL; stdcall;
function ReadConsoleW(hConsoleInput: THandle; lpBuffer: Pointer;
  nNumberOfCharsToRead: DWORD; var lpNumberOfCharsRead: DWORD; lpReserved: Pointer): BOOL; stdcall;
function ReadConsole(hConsoleInput: THandle; lpBuffer: Pointer;
  nNumberOfCharsToRead: DWORD; var lpNumberOfCharsRead: DWORD; lpReserved: Pointer): BOOL; stdcall;
function WriteConsoleA(hConsoleOutput: THandle; const lpBuffer: Pointer;
  nNumberOfCharsToWrite: DWORD; var lpNumberOfCharsWritten: DWORD; lpReserved: Pointer): BOOL; stdcall;
function WriteConsoleW(hConsoleOutput: THandle; const lpBuffer: Pointer;
  nNumberOfCharsToWrite: DWORD; var lpNumberOfCharsWritten: DWORD; lpReserved: Pointer): BOOL; stdcall;
function WriteConsole(hConsoleOutput: THandle; const lpBuffer: Pointer;
  nNumberOfCharsToWrite: DWORD; var lpNumberOfCharsWritten: DWORD; lpReserved: Pointer): BOOL; stdcall;

const
  CONSOLE_TEXTMODE_BUFFER = 1;

function CreateConsoleScreenBuffer(dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwFlags: DWORD; lpScreenBufferData: Pointer): THandle; stdcall;
function GetConsoleCP: UINT; stdcall;
function SetConsoleCP(wCodePageID: UINT): BOOL; stdcall;
function GetConsoleOutputCP: UINT; stdcall;
function SetConsoleOutputCP(wCodePageID: UINT): BOOL; stdcall;


{ Translated from WINVER.H }

{ Version management functions, types, and definitions
  Include file for VER.DLL.  This library is designed to allow version
  stamping of Windows executable files and of special .VER files for
  DOS executable files. }

const
{ Symbols }

  VS_FILE_INFO = RT_VERSION;
  VS_VERSION_INFO = 1;
  VS_USER_DEFINED = 100;

{ VS_VERSION.dwFileFlags }

  VS_FFI_SIGNATURE = DWORD($FEEF04BD);
  VS_FFI_STRUCVERSION = $10000;
  VS_FFI_FILEFLAGSMASK = 63;

{ VS_VERSION.dwFileFlags }

  VS_FF_DEBUG = 1;
  VS_FF_PRERELEASE = 2;
  VS_FF_PATCHED = 4;
  VS_FF_PRIVATEBUILD = 8;
  VS_FF_INFOINFERRED = $10;
  VS_FF_SPECIALBUILD = $20;

{ VS_VERSION.dwFileOS }

  VOS_UNKNOWN = 0;
  VOS_DOS = $10000;
  VOS_OS216 = $20000;
  VOS_OS232 = $30000;
  VOS_NT = $40000;

  VOS__BASE = 0;
  VOS__WINDOWS16 = 1;
  VOS__PM16 = 2;
  VOS__PM32 = 3;
  VOS__WINDOWS32 = 4;

  VOS_DOS_WINDOWS16 = $10001;
  VOS_DOS_WINDOWS32 = $10004;
  VOS_OS216_PM16 = $20002;
  VOS_OS232_PM32 = $30003;
  VOS_NT_WINDOWS32 = $40004;

{ VS_VERSION.dwFileType }

  VFT_UNKNOWN = 0;
  VFT_APP = 1;
  VFT_DLL = 2;
  VFT_DRV = 3;
  VFT_FONT = 4;
  VFT_VXD = 5;
  VFT_STATIC_LIB = 7;

{ VS_VERSION.dwFileSubtype for VFT_WINDOWS_DRV }

  VFT2_UNKNOWN = 0;
  VFT2_DRV_PRINTER = 1;
  VFT2_DRV_KEYBOARD = 2;
  VFT2_DRV_LANGUAGE = 3;
  VFT2_DRV_DISPLAY = 4;
  VFT2_DRV_MOUSE = 5;
  VFT2_DRV_NETWORK = 6;
  VFT2_DRV_SYSTEM = 7;
  VFT2_DRV_INSTALLABLE = 8;
  VFT2_DRV_SOUND = 9;
  VFT2_DRV_COMM = 10;

{ VS_VERSION.dwFileSubtype for VFT_WINDOWS_FONT }

  VFT2_FONT_RASTER = 1;
  VFT2_FONT_VECTOR = 2;
  VFT2_FONT_TRUETYPE = 3;

{ VerFindFile() flags }

  VFFF_ISSHAREDFILE = 1;

  VFF_CURNEDEST = 1;
  VFF_FILEINUSE = 2;
  VFF_BUFFTOOSMALL = 4;

{ VerInstallFile() flags }

  VIFF_FORCEINSTALL = 1;
  VIFF_DONTDELETEOLD = 2;

  VIF_TEMPFILE = 1;
  VIF_MISMATCH = 2;
  VIF_SRCOLD = 4;

  VIF_DIFFLANG = 8;
  VIF_DIFFCODEPG = $10;
  VIF_DIFFTYPE = $20;

  VIF_WRITEPROT = $40;
  VIF_FILEINUSE = $80;
  VIF_OUTOFSPACE = $100;
  VIF_ACCESSVIOLATION = $200;
  VIF_SHARINGVIOLATION = $400;
  VIF_CANNOTCREATE = $800;
  VIF_CANNOTDELETE = $1000;
  VIF_CANNOTRENAME = $2000;
  VIF_CANNOTDELETECUR = $4000;
  VIF_OUTOFMEMORY = $8000;

  VIF_CANNOTREADSRC = $10000;
  VIF_CANNOTREADDST = $20000;

  VIF_BUFFTOOSMALL = $40000;

type
  PVSFixedFileInfo = ^TVSFixedFileInfo;
  tagVS_FIXEDFILEINFO = packed record
    dwSignature: DWORD;        { e.g. $feef04bd }
    dwStrucVersion: DWORD;     { e.g. $00000042 = "0.42" }
    dwFileVersionMS: DWORD;    { e.g. $00030075 = "3.75" }
    dwFileVersionLS: DWORD;    { e.g. $00000031 = "0.31" }
    dwProductVersionMS: DWORD; { e.g. $00030010 = "3.10" }
    dwProductVersionLS: DWORD; { e.g. $00000031 = "0.31" }
    dwFileFlagsMask: DWORD;    { = $3F for version "0.42" }
    dwFileFlags: DWORD;        { e.g. VFF_DEBUG | VFF_PRERELEASE }
    dwFileOS: DWORD;           { e.g. VOS_DOS_WINDOWS16 }
    dwFileType: DWORD;         { e.g. VFT_DRIVER }
    dwFileSubtype: DWORD;      { e.g. VFT2_DRV_KEYBOARD }
    dwFileDateMS: DWORD;       { e.g. 0 }
    dwFileDateLS: DWORD;       { e.g. 0 }
  end;
  TVSFixedFileInfo = tagVS_FIXEDFILEINFO;
  VS_FIXEDFILEINFO = tagVS_FIXEDFILEINFO;

function VerFindFileA(uFlags: DWORD; szFileName, szWinDir, szAppDir, szCurDir: PAnsiChar;
  var lpuCurDirLen: UINT; szDestDir: PAnsiChar; var lpuDestDirLen: UINT): DWORD; stdcall;
function VerFindFileW(uFlags: DWORD; szFileName, szWinDir, szAppDir, szCurDir: PWideChar;
  var lpuCurDirLen: UINT; szDestDir: PWideChar; var lpuDestDirLen: UINT): DWORD; stdcall;
function VerFindFile(uFlags: DWORD; szFileName, szWinDir, szAppDir, szCurDir: PTChar;
  var lpuCurDirLen: UINT; szDestDir: PTChar; var lpuDestDirLen: UINT): DWORD; stdcall;
function VerInstallFileA(uFlags: DWORD;
  szSrcFileName, szDestFileName, szSrcDir, szDestDir, szCurDir, szTmpFile: PAnsiChar;
  var lpuTmpFileLen: UINT): DWORD; stdcall;
function VerInstallFileW(uFlags: DWORD;
  szSrcFileName, szDestFileName, szSrcDir, szDestDir, szCurDir, szTmpFile: PWideChar;
  var lpuTmpFileLen: UINT): DWORD; stdcall;
function VerInstallFile(uFlags: DWORD;
  szSrcFileName, szDestFileName, szSrcDir, szDestDir, szCurDir, szTmpFile: PTChar;
  var lpuTmpFileLen: UINT): DWORD; stdcall;

function GetFileVersionInfoSizeA(lptstrFilename: PAnsiChar; var lpdwHandle: DWORD): DWORD; stdcall;
function GetFileVersionInfoSizeW(lptstrFilename: PWideChar; var lpdwHandle: DWORD): DWORD; stdcall;
function GetFileVersionInfoSize(lptstrFilename: PTChar; var lpdwHandle: DWORD): DWORD; stdcall;
function GetFileVersionInfoA(lptstrFilename: PAnsiChar; dwHandle, dwLen: DWORD;
  lpData: Pointer): BOOL; stdcall;
function GetFileVersionInfoW(lptstrFilename: PWideChar; dwHandle, dwLen: DWORD;
  lpData: Pointer): BOOL; stdcall;
function GetFileVersionInfo(lptstrFilename: PTChar; dwHandle, dwLen: DWORD;
  lpData: Pointer): BOOL; stdcall;
function VerLanguageNameA(wLang: DWORD; szLang: PAnsiChar; nSize: DWORD): DWORD; stdcall;
function VerLanguageNameW(wLang: DWORD; szLang: PWideChar; nSize: DWORD): DWORD; stdcall;
function VerLanguageName(wLang: DWORD; szLang: PTChar; nSize: DWORD): DWORD; stdcall;
function VerQueryValueA(pBlock: Pointer; lpSubBlock: PAnsiChar;
  var lplpBuffer: Pointer; var puLen: UINT): BOOL; stdcall;
function VerQueryValueW(pBlock: Pointer; lpSubBlock: PWideChar;
  var lplpBuffer: Pointer; var puLen: UINT): BOOL; stdcall;
function VerQueryValue(pBlock: Pointer; lpSubBlock: PTChar;
  var lplpBuffer: Pointer; var puLen: UINT): BOOL; stdcall;


{ Translated from WINREG.H }

{ This module contains the function prototypes and constant, type and
   structure definitions for the Windows 32-Bit Registry API. }

type
  REGSAM = ACCESS_MASK;  { Requested Key access mask type. }

  HKEY = THandle;
  PHKEY = ^HKEY;

const
{ Reserved Key Handles. }

  HKEY_CLASSES_ROOT     = DWORD($80000000);
  HKEY_CURRENT_USER     = DWORD($80000001);
  HKEY_LOCAL_MACHINE    = DWORD($80000002);
  HKEY_USERS            = DWORD($80000003);
  HKEY_PERFORMANCE_DATA = DWORD($80000004);
  HKEY_CURRENT_CONFIG   = DWORD($80000005);
  HKEY_DYN_DATA         = DWORD($80000006);


  PROVIDER_KEEPS_VALUE_LENGTH = 1;

type
  PValContext = ^TValContext;
  val_context = packed record
    valuelen: Integer;       { the total length of this value }
    value_context: Pointer;  { provider's context }
    val_buff_ptr: Pointer;   { where in the ouput buffer the value is }
  end;
  TValContext = val_context;


type
{ Provider supplied value/context.}
  PPValueA = ^TPValueA;
  PPValueW = ^TPValueW;
  PPValue = PPValueA;
  pvalueA = packed record
    pv_valuename: PAnsiChar;           { The value name pointer }
    pv_valuelen: BOOL;
    pv_value_context: Pointer;
    pv_type: DWORD;
  end;
  pvalueW = packed record
    pv_valuename: PWideChar;           { The value name pointer }
    pv_valuelen: BOOL;
    pv_value_context: Pointer;
    pv_type: DWORD;
  end;
  pvalue = pvalueA;
  TPValueA = pvalueA;
  TPValueW = pvalueW;
  TPValue = TPValueA;

  TFNQueryHandler = TFarProc;

  PFNQueryHandler = ^TFNQueryHandler;

  PProviderInfo = ^TProviderInfo;
  provider_info = packed record
    pi_R0_1val: PFNQueryHandler;
    pi_R0_allvals: PFNQueryHandler;
    pi_R3_1val: PFNQueryHandler;
    pi_R3_allvals: PFNQueryHandler;
    pi_flags: DWORD;              { capability flags (none defined yet). }
    pi_key_context: Pointer;
  end;
  TProviderInfo = provider_info;
  REG_PROVIDER = provider_info;
  TRegProvider = TProviderInfo;
  PProvider = PProviderInfo;

  PValueEntA = ^TValueEntA;
  PValueEntW = ^TValueEntW;
  PValueEnt = PValueEntA;
  value_entA = packed record
    ve_valuename: PAnsiChar;
    ve_valuelen: DWORD;
    ve_valueptr: DWORD;
    ve_type: DWORD;
  end;
  value_entW = packed record
    ve_valuename: PWideChar;
    ve_valuelen: DWORD;
    ve_valueptr: DWORD;
    ve_type: DWORD;
  end;
  value_ent = value_entA;
  TValueEntA = value_entA;
  TValueEntW = value_entW;
  TValueEnt = TValueEntA;
  VALENTA = value_entA;
  VALENTW = value_entW;
  VALENT = VALENTA;
  TValEnt = TValueEnt;
  PValEnt = PValueEnt;


{ Default values for parameters that do not exist in the Win 3.1
  compatible APIs. }

function RegCloseKey(hKey: HKEY): Longint; stdcall;

function RegConnectRegistryA(lpMachineName: PAnsiChar; hKey: HKEY;
  var phkResult: HKEY): Longint; stdcall;
function RegConnectRegistryW(lpMachineName: PWideChar; hKey: HKEY;
  var phkResult: HKEY): Longint; stdcall;
function RegConnectRegistry(lpMachineName: PTChar; hKey: HKEY;
  var phkResult: HKEY): Longint; stdcall;
function RegCreateKeyA(hKey: HKEY; lpSubKey: PAnsiChar;
  var phkResult: HKEY): Longint; stdcall;
function RegCreateKeyW(hKey: HKEY; lpSubKey: PWideChar;
  var phkResult: HKEY): Longint; stdcall;
function RegCreateKey(hKey: HKEY; lpSubKey: PTChar;
  var phkResult: HKEY): Longint; stdcall;
function RegCreateKeyExA(hKey: HKEY; lpSubKey: PAnsiChar;
  Reserved: DWORD; lpClass: PAnsiChar; dwOptions: DWORD; samDesired: REGSAM;
  lpSecurityAttributes: PSecurityAttributes; var phkResult: HKEY;
  lpdwDisposition: PDWORD): Longint; stdcall;
function RegCreateKeyExW(hKey: HKEY; lpSubKey: PWideChar;
  Reserved: DWORD; lpClass: PWideChar; dwOptions: DWORD; samDesired: REGSAM;
  lpSecurityAttributes: PSecurityAttributes; var phkResult: HKEY;
  lpdwDisposition: PDWORD): Longint; stdcall;
function RegCreateKeyEx(hKey: HKEY; lpSubKey: PTChar;
  Reserved: DWORD; lpClass: PTChar; dwOptions: DWORD; samDesired: REGSAM;
  lpSecurityAttributes: PSecurityAttributes; var phkResult: HKEY;
  lpdwDisposition: PDWORD): Longint; stdcall;
function RegDeleteKeyA(hKey: HKEY; lpSubKey: PAnsiChar): Longint; stdcall;
function RegDeleteKeyW(hKey: HKEY; lpSubKey: PWideChar): Longint; stdcall;
function RegDeleteKey(hKey: HKEY; lpSubKey: PTChar): Longint; stdcall;
function RegDeleteValueA(hKey: HKEY; lpValueName: PAnsiChar): Longint; stdcall;
function RegDeleteValueW(hKey: HKEY; lpValueName: PWideChar): Longint; stdcall;
function RegDeleteValue(hKey: HKEY; lpValueName: PTChar): Longint; stdcall;
function RegEnumKeyA(hKey: HKEY; dwIndex: DWORD; lpName: PAnsiChar; cbName: DWORD): Longint; stdcall;
function RegEnumKeyW(hKey: HKEY; dwIndex: DWORD; lpName: PWideChar; cbName: DWORD): Longint; stdcall;
function RegEnumKey(hKey: HKEY; dwIndex: DWORD; lpName: PTChar; cbName: DWORD): Longint; stdcall;
function RegEnumKeyExA(hKey: HKEY; dwIndex: DWORD; lpName: PAnsiChar;
  var lpcbName: DWORD; lpReserved: Pointer; lpClass: PAnsiChar;
  lpcbClass: PDWORD; lpftLastWriteTime: PFileTime): Longint; stdcall;
function RegEnumKeyExW(hKey: HKEY; dwIndex: DWORD; lpName: PWideChar;
  var lpcbName: DWORD; lpReserved: Pointer; lpClass: PWideChar;
  lpcbClass: PDWORD; lpftLastWriteTime: PFileTime): Longint; stdcall;
function RegEnumKeyEx(hKey: HKEY; dwIndex: DWORD; lpName: PTChar;
  var lpcbName: DWORD; lpReserved: Pointer; lpClass: PTChar;
  lpcbClass: PDWORD; lpftLastWriteTime: PFileTime): Longint; stdcall;
function RegEnumValueA(hKey: HKEY; dwIndex: DWORD; lpValueName: PTChar;
  var lpcbValueName: DWORD; lpReserved: Pointer; lpType: PDWORD;
  lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
function RegEnumValueW(hKey: HKEY; dwIndex: DWORD; lpValueName: PTChar;
  var lpcbValueName: DWORD; lpReserved: Pointer; lpType: PDWORD;
  lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
function RegEnumValue(hKey: HKEY; dwIndex: DWORD; lpValueName: PTChar;
  var lpcbValueName: DWORD; lpReserved: Pointer; lpType: PDWORD;
  lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
function RegFlushKey(hKey: HKEY): Longint; stdcall;
function RegGetKeySecurity(hKey: HKEY; SecurityInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSecurityDescriptor; var lpcbSecurityDescriptor: DWORD): Longint; stdcall;
function RegLoadKeyA(hKey: HKEY; lpSubKey, lpFile: PAnsiChar): Longint; stdcall;
function RegLoadKeyW(hKey: HKEY; lpSubKey, lpFile: PWideChar): Longint; stdcall;
function RegLoadKey(hKey: HKEY; lpSubKey, lpFile: PTChar): Longint; stdcall;
function RegNotifyChangeKeyValue(hKey: HKEY; bWatchSubtree: BOOL;
  dwNotifyFilter: DWORD; hEvent: THandle; fAsynchronus: BOOL): Longint; stdcall;
function RegOpenKeyA(hKey: HKEY; lpSubKey: PAnsiChar; var phkResult: HKEY): Longint; stdcall;
function RegOpenKeyW(hKey: HKEY; lpSubKey: PWideChar; var phkResult: HKEY): Longint; stdcall;
function RegOpenKey(hKey: HKEY; lpSubKey: PTChar; var phkResult: HKEY): Longint; stdcall;
function RegOpenKeyExA(hKey: HKEY; lpSubKey: PAnsiChar;
  ulOptions: DWORD; samDesired: REGSAM; var phkResult: HKEY): Longint; stdcall;
function RegOpenKeyExW(hKey: HKEY; lpSubKey: PWideChar;
  ulOptions: DWORD; samDesired: REGSAM; var phkResult: HKEY): Longint; stdcall;
function RegOpenKeyEx(hKey: HKEY; lpSubKey: PTChar;
  ulOptions: DWORD; samDesired: REGSAM; var phkResult: HKEY): Longint; stdcall;
function RegQueryInfoKeyA(hKey: HKEY; lpClass: PTChar;
  lpcbClass: PDWORD; lpReserved: Pointer;
  lpcSubKeys, lpcbMaxSubKeyLen, lpcbMaxClassLen, lpcValues,
  lpcbMaxValueNameLen, lpcbMaxValueLen, lpcbSecurityDescriptor: PDWORD;
  lpftLastWriteTime: PFileTime): Longint; stdcall;
function RegQueryInfoKeyW(hKey: HKEY; lpClass: PTChar;
  lpcbClass: PDWORD; lpReserved: Pointer;
  lpcSubKeys, lpcbMaxSubKeyLen, lpcbMaxClassLen, lpcValues,
  lpcbMaxValueNameLen, lpcbMaxValueLen, lpcbSecurityDescriptor: PDWORD;
  lpftLastWriteTime: PFileTime): Longint; stdcall;
function RegQueryInfoKey(hKey: HKEY; lpClass: PTChar;
  lpcbClass: PDWORD; lpReserved: Pointer;
  lpcSubKeys, lpcbMaxSubKeyLen, lpcbMaxClassLen, lpcValues,
  lpcbMaxValueNameLen, lpcbMaxValueLen, lpcbSecurityDescriptor: PDWORD;
  lpftLastWriteTime: PFileTime): Longint; stdcall;
function RegQueryValueA(hKey: HKEY; lpSubKey: PAnsiChar;
  lpValue: PAnsiChar; var lpcbValue: Longint): Longint; stdcall;
function RegQueryValueW(hKey: HKEY; lpSubKey: PWideChar;
  lpValue: PWideChar; var lpcbValue: Longint): Longint; stdcall;
function RegQueryValue(hKey: HKEY; lpSubKey: PTChar;
  lpValue: PTChar; var lpcbValue: Longint): Longint; stdcall;
function RegQueryMultipleValuesA(hKey: HKEY; var ValList;
  NumVals: DWORD; lpValueBuf: PAnsiChar; var ldwTotsize: DWORD): Longint; stdcall;
function RegQueryMultipleValuesW(hKey: HKEY; var ValList;
  NumVals: DWORD; lpValueBuf: PWideChar; var ldwTotsize: DWORD): Longint; stdcall;
function RegQueryMultipleValues(hKey: HKEY; var ValList;
  NumVals: DWORD; lpValueBuf: PTChar; var ldwTotsize: DWORD): Longint; stdcall;
function RegQueryValueExA(hKey: HKEY; lpValueName: PAnsiChar;
  lpReserved: Pointer; lpType: PDWORD; lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
function RegQueryValueExW(hKey: HKEY; lpValueName: PWideChar;
  lpReserved: Pointer; lpType: PDWORD; lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
function RegQueryValueEx(hKey: HKEY; lpValueName: PTChar;
  lpReserved: Pointer; lpType: PDWORD; lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
function RegReplaceKeyA(hKey: HKEY; lpSubKey: PAnsiChar;
   lpNewFile: PAnsiChar; lpOldFile: PAnsiChar): Longint; stdcall;
function RegReplaceKeyW(hKey: HKEY; lpSubKey: PWideChar;
   lpNewFile: PWideChar; lpOldFile: PWideChar): Longint; stdcall;
function RegReplaceKey(hKey: HKEY; lpSubKey: PTChar;
   lpNewFile: PTChar; lpOldFile: PTChar): Longint; stdcall;
function RegRestoreKeyA(hKey: HKEY; lpFile: PAnsiChar; dwFlags: DWORD): Longint; stdcall;
function RegRestoreKeyW(hKey: HKEY; lpFile: PWideChar; dwFlags: DWORD): Longint; stdcall;
function RegRestoreKey(hKey: HKEY; lpFile: PTChar; dwFlags: DWORD): Longint; stdcall;
function RegSaveKeyA(hKey: HKEY; lpFile: PAnsiChar;
  lpSecurityAttributes: PSecurityAttributes): Longint; stdcall;
function RegSaveKeyW(hKey: HKEY; lpFile: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): Longint; stdcall;
function RegSaveKey(hKey: HKEY; lpFile: PTChar;
  lpSecurityAttributes: PSecurityAttributes): Longint; stdcall;
function RegSetKeySecurity(hKey: HKEY; SecurityInformation: SECURITY_INFORMATION;
  pSecurityDescriptor: PSECURITY_DESCRIPTOR): Longint; stdcall;
function RegSetValueA(hKey: HKEY; lpSubKey: PAnsiChar;
  dwType: DWORD; lpData: PAnsiChar; cbData: DWORD): Longint; stdcall;
function RegSetValueW(hKey: HKEY; lpSubKey: PWideChar;
  dwType: DWORD; lpData: PWideChar; cbData: DWORD): Longint; stdcall;
function RegSetValue(hKey: HKEY; lpSubKey: PTChar;
  dwType: DWORD; lpData: PTChar; cbData: DWORD): Longint; stdcall;
function RegSetValueExA(hKey: HKEY; lpValueName: PAnsiChar;
  Reserved: DWORD; dwType: DWORD; lpData: Pointer; cbData: DWORD): Longint; stdcall;
function RegSetValueExW(hKey: HKEY; lpValueName: PWideChar;
  Reserved: DWORD; dwType: DWORD; lpData: Pointer; cbData: DWORD): Longint; stdcall;
function RegSetValueEx(hKey: HKEY; lpValueName: PTChar;
  Reserved: DWORD; dwType: DWORD; lpData: Pointer; cbData: DWORD): Longint; stdcall;
function RegUnLoadKeyA(hKey: HKEY; lpSubKey: PAnsiChar): Longint; stdcall;
function RegUnLoadKeyW(hKey: HKEY; lpSubKey: PWideChar): Longint; stdcall;
function RegUnLoadKey(hKey: HKEY; lpSubKey: PTChar): Longint; stdcall;

{ Remoteable System Shutdown APIs }

function InitiateSystemShutdownA(lpMachineName, lpMessage: PAnsiChar;
  dwTimeout: DWORD; bForceAppsClosed, bRebootAfterShutdown: BOOL): BOOL; stdcall;
function InitiateSystemShutdownW(lpMachineName, lpMessage: PWideChar;
  dwTimeout: DWORD; bForceAppsClosed, bRebootAfterShutdown: BOOL): BOOL; stdcall;
function InitiateSystemShutdown(lpMachineName, lpMessage: PTChar;
  dwTimeout: DWORD; bForceAppsClosed, bRebootAfterShutdown: BOOL): BOOL; stdcall;
function AbortSystemShutdownA(lpMachineName: PAnsiChar): BOOL; stdcall;
function AbortSystemShutdownW(lpMachineName: PWideChar): BOOL; stdcall;
function AbortSystemShutdown(lpMachineName: PTChar): BOOL; stdcall;


{ Translated from WINNETWK.H }

const
{ Network types }

  WNNC_NET_MSNET              = $00010000;
  WNNC_NET_LANMAN             = $00020000;
  WNNC_NET_NETWARE            = $00030000;
  WNNC_NET_VINES              = $00040000;
  WNNC_NET_10NET              = $00050000;
  WNNC_NET_LOCUS              = $00060000;
  WNNC_NET_SUN_PC_NFS         = $00070000;
  WNNC_NET_LANSTEP            = $00080000;
  WNNC_NET_9TILES             = $00090000;
  WNNC_NET_LANTASTIC          = $000A0000;
  WNNC_NET_AS400              = $000B0000;
  WNNC_NET_FTP_NFS            = $000C0000;
  WNNC_NET_PATHWORKS          = $000D0000;
  WNNC_NET_LIFENET            = $000E0000;
  WNNC_NET_POWERLAN           = $000F0000;
  WNNC_NET_BWNFS              = $00100000;
  WNNC_NET_COGENT             = $00110000;
  WNNC_NET_FARALLON           = $00120000;
  WNNC_NET_APPLETALK          = $00130000;
  WNNC_NET_INTERGRAPH         = $00140000;
  WNNC_NET_SYMFONET           = $00150000;
  WNNC_NET_CLEARCASE          = $00160000;

{ Network Resources. }

  RESOURCE_CONNECTED = 1;
  RESOURCE_GLOBALNET = 2;
  RESOURCE_REMEMBERED = 3;
  RESOURCE_RECENT = 4;
  RESOURCE_CONTEXT = 5;

  RESOURCETYPE_ANY = 0;
  RESOURCETYPE_DISK = 1;
  RESOURCETYPE_PRINT = 2;
  RESOURCETYPE_RESERVED = 8;
  RESOURCETYPE_UNKNOWN = DWORD($FFFFFFFF);

  RESOURCEUSAGE_CONNECTABLE = 1;
  RESOURCEUSAGE_CONTAINER = 2;
  RESOURCEUSAGE_NOLOCALDEVICE = 4;
  RESOURCEUSAGE_SIBLING = 8;

  RESOURCEUSAGE_ATTACHED = $00000010;
  RESOURCEUSAGE_ALL = (RESOURCEUSAGE_CONNECTABLE or RESOURCEUSAGE_CONTAINER or RESOURCEUSAGE_ATTACHED);
  RESOURCEUSAGE_RESERVED = DWORD($80000000);

  RESOURCEDISPLAYTYPE_GENERIC            = $00000000;
  RESOURCEDISPLAYTYPE_DOMAIN             = $00000001;
  RESOURCEDISPLAYTYPE_SERVER             = $00000002;
  RESOURCEDISPLAYTYPE_SHARE              = $00000003;
  RESOURCEDISPLAYTYPE_FILE               = $00000004;
  RESOURCEDISPLAYTYPE_GROUP              = $00000005;
  RESOURCEDISPLAYTYPE_NETWORK            = $00000006;
  RESOURCEDISPLAYTYPE_ROOT               = $00000007;
  RESOURCEDISPLAYTYPE_SHAREADMIN         = $00000008;
  RESOURCEDISPLAYTYPE_DIRECTORY          = $00000009;
  RESOURCEDISPLAYTYPE_TREE               = $0000000A;
  RESOURCEDISPLAYTYPE_NDSCONTAINER       = $0000000B;

type
  PNetResourceA = ^TNetResourceA;
  PNetResourceW = ^TNetResourceW;
  PNetResource = {$ifdef bUnicode}PNetResourceW{$else}PNetResourceA{$endif bUnicode};

  _NETRESOURCEA = packed record
    dwScope: DWORD;
    dwType: DWORD;
    dwDisplayType: DWORD;
    dwUsage: DWORD;
    lpLocalName: PAnsiChar;
    lpRemoteName: PAnsiChar;
    lpComment: PAnsiChar;
    lpProvider: PAnsiChar;
  end;
  _NETRESOURCEW = packed record
    dwScope: DWORD;
    dwType: DWORD;
    dwDisplayType: DWORD;
    dwUsage: DWORD;
    lpLocalName: PWideChar;
    lpRemoteName: PWideChar;
    lpComment: PWideChar;
    lpProvider: PWideChar;
  end;
  _NETRESOURCE = {$ifdef bUnicode}_NETRESOURCEW{$else}_NETRESOURCEA{$endif bUnicode};

  TNetResourceA = _NETRESOURCEA;
  TNetResourceW = _NETRESOURCEW;
  TNetResource = {$ifdef bUnicode}TNetResourceW{$else}TNetResourceA{$endif bUnicode};

  NETRESOURCEA = _NETRESOURCEA;
  NETRESOURCEW = _NETRESOURCEW;
  NETRESOURCE = {$ifdef bUnicode}NETRESOURCEW{$else}NETRESOURCEA{$endif bUnicode};

const
{ Network Connections. }

  NETPROPERTY_PERSISTENT = 1;

  CONNECT_UPDATE_PROFILE          = $00000001;
  CONNECT_UPDATE_RECENT           = $00000002;
  CONNECT_TEMPORARY               = $00000004;
  CONNECT_INTERACTIVE             = $00000008;
  CONNECT_PROMPT                  = $00000010;
  CONNECT_NEED_DRIVE              = $00000020;
  CONNECT_REFCOUNT                = $00000040;
  CONNECT_REDIRECT                = $00000080;
  CONNECT_LOCALDRIVE              = $00000100;
  CONNECT_CURRENT_MEDIA           = $00000200;
  CONNECT_DEFERRED                = $00000400;
  CONNECT_RESERVED                = DWORD($FF000000);

function WNetAddConnectionA(lpRemoteName, lpPassword, lpLocalName: PAnsiChar): DWORD; stdcall;
function WNetAddConnectionW(lpRemoteName, lpPassword, lpLocalName: PWideChar): DWORD; stdcall;
function WNetAddConnection(lpRemoteName, lpPassword, lpLocalName: PTChar): DWORD; stdcall;
function WNetAddConnection2A(var lpNetResource: TNetResourceA;
  lpPassword, lpUserName: PAnsiChar; dwFlags: DWORD): DWORD; stdcall;
function WNetAddConnection2W(var lpNetResource: TNetResourceW;
  lpPassword, lpUserName: PWideChar; dwFlags: DWORD): DWORD; stdcall;
function WNetAddConnection2(var lpNetResource: TNetResource;
  lpPassword, lpUserName: PTChar; dwFlags: DWORD): DWORD; stdcall;
function WNetAddConnection3A(hwndOwner: HWND; var lpNetResource: TNetResourceA;
  lpPassword, lpUserName: PAnsiChar; dwFlags: DWORD): DWORD; stdcall;
function WNetAddConnection3W(hwndOwner: HWND; var lpNetResource: TNetResourceW;
  lpPassword, lpUserName: PWideChar; dwFlags: DWORD): DWORD; stdcall;
function WNetAddConnection3(hwndOwner: HWND; var lpNetResource: TNetResource;
  lpPassword, lpUserName: PTChar; dwFlags: DWORD): DWORD; stdcall;
function WNetCancelConnectionA(lpName: PAnsiChar; fForce: BOOL): DWORD; stdcall;
function WNetCancelConnectionW(lpName: PWideChar; fForce: BOOL): DWORD; stdcall;
function WNetCancelConnection(lpName: PTChar; fForce: BOOL): DWORD; stdcall;
function WNetCancelConnection2A(lpName: PAnsiChar; dwFlags: DWORD; fForce: BOOL): DWORD; stdcall;
function WNetCancelConnection2W(lpName: PWideChar; dwFlags: DWORD; fForce: BOOL): DWORD; stdcall;
function WNetCancelConnection2(lpName: PTChar; dwFlags: DWORD; fForce: BOOL): DWORD; stdcall;
function WNetGetConnectionA(lpLocalName: PAnsiChar;
  lpRemoteName: PAnsiChar; var lpnLength: DWORD): DWORD; stdcall;
function WNetGetConnectionW(lpLocalName: PWideChar;
  lpRemoteName: PWideChar; var lpnLength: DWORD): DWORD; stdcall;
function WNetGetConnection(lpLocalName: PTChar;
  lpRemoteName: PTChar; var lpnLength: DWORD): DWORD; stdcall;
function WNetUseConnectionA(hwndOwner: HWND;
  var lpNetResource: TNetResourceA; lpUserID: PAnsiChar;
  lpPassword: PAnsiChar; dwFlags: DWORD; lpAccessName: PAnsiChar;
  var lpBufferSize: DWORD; var lpResult: DWORD): DWORD; stdcall;
function WNetUseConnectionW(hwndOwner: HWND;
  var lpNetResource: TNetResourceW; lpUserID: PWideChar;
  lpPassword: PWideChar; dwFlags: DWORD; lpAccessName: PWideChar;
  var lpBufferSize: DWORD; var lpResult: DWORD): DWORD; stdcall;
function WNetUseConnection(hwndOwner: HWND;
  var lpNetResource: TNetResource; lpUserID: PTChar;
  lpPassword: PTChar; dwFlags: DWORD; lpAccessName: PTChar;
  var lpBufferSize: DWORD; var lpResult: DWORD): DWORD; stdcall;
function WNetSetConnectionA(lpName: PAnsiChar; dwProperties: DWORD; pvValues: Pointer): DWORD; stdcall;
function WNetSetConnectionW(lpName: PWideChar; dwProperties: DWORD; pvValues: Pointer): DWORD; stdcall;
function WNetSetConnection(lpName: PTChar; dwProperties: DWORD; pvValues: Pointer): DWORD; stdcall;

{ Network Connection Dialogs. }

function WNetConnectionDialog(hwnd: HWND; dwType: DWORD): DWORD; stdcall;
function WNetDisconnectDialog(hwnd: HWND; dwType: DWORD): DWORD; stdcall;

type
  PConnectDlgStruct = ^TConnectDlgStruct;
  _CONNECTDLGSTRUCTA = packed record
    cbStructure: DWORD;          { size of this structure in bytes }
    hwndOwner: HWND;             { owner window for the dialog }
    lpConnRes: PNetResource;     { Requested Resource info    }
    dwFlags: DWORD;              { flags (see below) }
    dwDevNum: DWORD;             { number of devices connected to }
  end;
  TConnectDlgStruct = _CONNECTDLGSTRUCTA;
  CONNECTDLGSTRUCT = _CONNECTDLGSTRUCTA;

const
  CONNDLG_RO_PATH = 1;    { Resource path should be read-only     }
  CONNDLG_CONN_POINT = 2; { Netware -style movable connection point enabled  }
  CONNDLG_USE_MRU = 4;    { Use MRU combobox   }
  CONNDLG_HIDE_BOX = 8;   { Hide persistent connect checkbox   }

  { NOTE:  Set at most ONE of the below flags.  If neither flag is set,
           then the persistence is set to whatever the user chose during
           a previous connection }

  CONNDLG_PERSIST = $10;       { Force persistent connection  }
  CONNDLG_NOT_PERSIST = $20;   { Force connection NOT persistent  }

function WNetConnectionDialog1A(var lpConnDlgStruct: TConnectDlgStruct): DWORD; stdcall;
function WNetConnectionDialog1W(var lpConnDlgStruct: TConnectDlgStruct): DWORD; stdcall;
function WNetConnectionDialog1(var lpConnDlgStruct: TConnectDlgStruct): DWORD; stdcall;

type
  PDiscDlgStructA = ^TDiscDlgStructA;
  PDiscDlgStructW = ^TDiscDlgStructW;
  PDiscDlgStruct = PDiscDlgStructA;
  _DISCDLGSTRUCTA = packed record
    cbStructure: DWORD;       { size of this structure in bytes }
    hwndOwner: HWND;          { owner window for the dialog }
    lpLocalName: PAnsiChar;       { local device name }
    lpRemoteName: PAnsiChar;      { network resource name }
    dwFlags: DWORD;
  end;
  _DISCDLGSTRUCTW = packed record
    cbStructure: DWORD;       { size of this structure in bytes }
    hwndOwner: HWND;          { owner window for the dialog }
    lpLocalName: PWideChar;       { local device name }
    lpRemoteName: PWideChar;      { network resource name }
    dwFlags: DWORD;
  end;
  _DISCDLGSTRUCT = _DISCDLGSTRUCTA;
  TDiscDlgStructA = _DISCDLGSTRUCTA;
  TDiscDlgStructW = _DISCDLGSTRUCTW;
  TDiscDlgStruct = TDiscDlgStructA;
  DISCDLGSTRUCTA = _DISCDLGSTRUCTA;
  DISCDLGSTRUCTW = _DISCDLGSTRUCTW;
  DISCDLGSTRUCT = DISCDLGSTRUCTA;

const
  DISC_UPDATE_PROFILE = 1;
  DISC_NO_FORCE = $40;

function WNetDisconnectDialog1A(var lpConnDlgStruct: TDiscDlgStructA): DWORD; stdcall;
function WNetDisconnectDialog1W(var lpConnDlgStruct: TDiscDlgStructW): DWORD; stdcall;
function WNetDisconnectDialog1(var lpConnDlgStruct: TDiscDlgStruct): DWORD; stdcall;

{ Network Browsing. }

function WNetOpenEnumA(dwScope, dwType, dwUsage: DWORD;
  lpNetResource: PNetResourceA; var lphEnum: THandle): DWORD; stdcall;
function WNetOpenEnumW(dwScope, dwType, dwUsage: DWORD;
  lpNetResource: PNetResourceW; var lphEnum: THandle): DWORD; stdcall;
function WNetOpenEnum(dwScope, dwType, dwUsage: DWORD;
  lpNetResource: PNetResource; var lphEnum: THandle): DWORD; stdcall;
function WNetEnumResourceA(hEnum: THandle; var lpcCount: DWORD;
  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
function WNetEnumResourceW(hEnum: THandle; var lpcCount: DWORD;
  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
function WNetEnumResource(hEnum: THandle; var lpcCount: DWORD;
  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
function WNetCloseEnum(hEnum: THandle): DWORD; stdcall;
function WNetGetResourceParentA(lpNetResource: PNetResourceA;
  lpBuffer: Pointer; var cbBuffer: DWORD): DWORD; stdcall;
function WNetGetResourceParentW(lpNetResource: PNetResourceW;
  lpBuffer: Pointer; var cbBuffer: DWORD): DWORD; stdcall;
function WNetGetResourceParent(lpNetResource: PNetResource;
  lpBuffer: Pointer; var cbBuffer: DWORD): DWORD; stdcall;

const
{ Universal Naming. }

  UNIVERSAL_NAME_INFO_LEVEL = 1;
  REMOTE_NAME_INFO_LEVEL = 2;

type
  PUniversalNameInfoA = ^TUniversalNameInfoA;
  PUniversalNameInfoW = ^TUniversalNameInfoW;
  PUniversalNameInfo = PUniversalNameInfoA;
  _UNIVERSAL_NAME_INFOA = packed record
    lpUniversalName: PAnsiChar;
  end;
  _UNIVERSAL_NAME_INFOW = packed record
    lpUniversalName: PWideChar;
  end;
  _UNIVERSAL_NAME_INFO = _UNIVERSAL_NAME_INFOA;
  TUniversalNameInfoA = _UNIVERSAL_NAME_INFOA;
  TUniversalNameInfoW = _UNIVERSAL_NAME_INFOW;
  TUniversalNameInfo = TUniversalNameInfoA;
  UNIVERSAL_NAME_INFOA = _UNIVERSAL_NAME_INFOA;
  UNIVERSAL_NAME_INFOW = _UNIVERSAL_NAME_INFOW;
  UNIVERSAL_NAME_INFO = UNIVERSAL_NAME_INFOA;

  PRemoteNameInfoA = ^TRemoteNameInfoA;
  PRemoteNameInfoW = ^TRemoteNameInfoW;
  PRemoteNameInfo = PRemoteNameInfoA;
  _REMOTE_NAME_INFOA = packed record
    lpUniversalName: PAnsiChar;
    lpConnectionName: PAnsiChar;
    lpRemainingPath: PAnsiChar;
  end;
  _REMOTE_NAME_INFOW = packed record
    lpUniversalName: PWideChar;
    lpConnectionName: PWideChar;
    lpRemainingPath: PWideChar;
  end;
  _REMOTE_NAME_INFO = _REMOTE_NAME_INFOA;
  TRemoteNameInfoA = _REMOTE_NAME_INFOA;
  TRemoteNameInfoW = _REMOTE_NAME_INFOW;
  TRemoteNameInfo = TRemoteNameInfoA;
  REMOTE_NAME_INFOA = _REMOTE_NAME_INFOA;
  REMOTE_NAME_INFOW = _REMOTE_NAME_INFOW;
  REMOTE_NAME_INFO = REMOTE_NAME_INFOA;

function WNetGetUniversalNameA(lpLocalPath: PAnsiChar; dwInfoLevel: DWORD;
  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
function WNetGetUniversalNameW(lpLocalPath: PWideChar; dwInfoLevel: DWORD;
  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
function WNetGetUniversalName(lpLocalPath: PTChar; dwInfoLevel: DWORD;
  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;

{ Authentication and Logon/Logoff }

function WNetGetUserA(lpName: PAnsiChar; lpUserName: PAnsiChar; var lpnLength: DWORD): DWORD; stdcall;
function WNetGetUserW(lpName: PWideChar; lpUserName: PWideChar; var lpnLength: DWORD): DWORD; stdcall;
function WNetGetUser(lpName: PTChar; lpUserName: PTChar; var lpnLength: DWORD): DWORD; stdcall;

const
  WNFMT_MULTILINE = 1;
  WNFMT_ABBREVIATED = 2;
  WNFMT_INENUM = $10;
  WNFMT_CONNECTION = $20;

function WNetGetProviderNameA(dwNetType: DWORD; lpProviderName: PAnsiChar;
  var lpBufferSize: DWORD): DWORD; stdcall;
function WNetGetProviderNameW(dwNetType: DWORD; lpProviderName: PWideChar;
  var lpBufferSize: DWORD): DWORD; stdcall;
function WNetGetProviderName(dwNetType: DWORD; lpProviderName: PTChar;
  var lpBufferSize: DWORD): DWORD; stdcall;

type
  PNetInfoStruct = ^TNetInfoStruct;
  _NETINFOSTRUCT = record
    cbStructure: DWORD;
    dwProviderVersion: DWORD;
    dwStatus: DWORD;
    dwCharacteristics: DWORD;
    dwHandle: DWORD;
    wNetType: Word;
    dwPrinters: DWORD;
    dwDrives: DWORD;
  end;
  TNetInfoStruct = _NETINFOSTRUCT;
  NETINFOSTRUCT = _NETINFOSTRUCT;

const
  NETINFO_DLL16 = 1;      { Provider running as 16 bit Winnet Driver  }
  NETINFO_DISKRED = 4;    { Provider requires disk redirections to connect  }
  NETINFO_PRINTERRED = 8; { Provider requires printer redirections to connect  }

function WNetGetNetworkInformationA(lpProvider: PAnsiChar;
  var lpNetInfoStruct: TNetInfoStruct): DWORD; stdcall;
function WNetGetNetworkInformationW(lpProvider: PWideChar;
  var lpNetInfoStruct: TNetInfoStruct): DWORD; stdcall;
function WNetGetNetworkInformation(lpProvider: PTChar;
  var lpNetInfoStruct: TNetInfoStruct): DWORD; stdcall;

type
{ User Profiles }

  TFNGetProfilePath = TFarProc;
  TFNReconcileProfile = TFarProc;

const
  RP_LOGON = 1;    { if set, do for logon, else for logoff }
  RP_INIFILE = 2;  { if set, reconcile .INI file, else reg. hive }

type
{ Policies }

  TFNProcessPolicies = TFarProc;

const
  PP_DISPLAYERRORS = 1;  { if set, display error messages, else fail silently if error }

{ Error handling }

function WNetGetLastErrorA(var lpError: DWORD; lpErrorBuf: PAnsiChar;
  nErrorBufSize: DWORD; lpNameBuf: PAnsiChar; nNameBufSize: DWORD): DWORD; stdcall;
function WNetGetLastErrorW(var lpError: DWORD; lpErrorBuf: PWideChar;
  nErrorBufSize: DWORD; lpNameBuf: PWideChar; nNameBufSize: DWORD): DWORD; stdcall;
function WNetGetLastError(var lpError: DWORD; lpErrorBuf: PTChar;
  nErrorBufSize: DWORD; lpNameBuf: PTChar; nNameBufSize: DWORD): DWORD; stdcall;


const
{ STATUS CODES }
{ General }

  WN_SUCCESS = NO_ERROR;
  WN_NO_ERROR = NO_ERROR;
  WN_NOT_SUPPORTED = ERROR_NOT_SUPPORTED;
  WN_CANCEL = ERROR_CANCELLED;
  WN_RETRY = ERROR_RETRY;
  WN_NET_ERROR = ERROR_UNEXP_NET_ERR;
  WN_MORE_DATA = ERROR_MORE_DATA;
  WN_BAD_POINTER = ERROR_INVALID_ADDRESS;
  WN_BAD_VALUE = ERROR_INVALID_PARAMETER;
  WN_BAD_USER = ERROR_BAD_USERNAME;
  WN_BAD_PASSWORD = ERROR_INVALID_PASSWORD;
  WN_ACCESS_DENIED = ERROR_ACCESS_DENIED;
  WN_FUNCTION_BUSY = ERROR_BUSY;
  WN_WINDOWS_ERROR = ERROR_UNEXP_NET_ERR;
  WN_OUT_OF_MEMORY = ERROR_NOT_ENOUGH_MEMORY;
  WN_NO_NETWORK = ERROR_NO_NETWORK;
  WN_EXTENDED_ERROR = ERROR_EXTENDED_ERROR;
  WN_BAD_LEVEL = ERROR_INVALID_LEVEL;
  WN_BAD_HANDLE = ERROR_INVALID_HANDLE;
  WN_NOT_INITIALIZING = ERROR_ALREADY_INITIALIZED;
  WN_NO_MORE_DEVICES = ERROR_NO_MORE_DEVICES;

{ Connection }

  WN_NOT_CONNECTED = ERROR_NOT_CONNECTED;
  WN_OPEN_FILES = ERROR_OPEN_FILES;
  WN_DEVICE_IN_USE = ERROR_DEVICE_IN_USE;
  WN_BAD_NETNAME = ERROR_BAD_NET_NAME;
  WN_BAD_LOCALNAME = ERROR_BAD_DEVICE;
  WN_ALREADY_CONNECTED = ERROR_ALREADY_ASSIGNED;
  WN_DEVICE_ERROR = ERROR_GEN_FAILURE;
  WN_CONNECTION_CLOSED = ERROR_CONNECTION_UNAVAIL;
  WN_NO_NET_OR_BAD_PATH = ERROR_NO_NET_OR_BAD_PATH;
  WN_BAD_PROVIDER = ERROR_BAD_PROVIDER;
  WN_CANNOT_OPEN_PROFILE = ERROR_CANNOT_OPEN_PROFILE;
  WN_BAD_PROFILE = ERROR_BAD_PROFILE;
  WN_BAD_DEV_TYPE = ERROR_BAD_DEV_TYPE;
  WN_DEVICE_ALREADY_REMEMBERED = ERROR_DEVICE_ALREADY_REMEMBERED;

{ Enumeration }

  WN_NO_MORE_ENTRIES = ERROR_NO_MORE_ITEMS;
  WN_NOT_CONTAINER = ERROR_NOT_CONTAINER;

{ Authentication }

  WN_NOT_AUTHENTICATED = ERROR_NOT_AUTHENTICATED;
  WN_NOT_LOGGED_ON = ERROR_NOT_LOGGED_ON;
  WN_NOT_VALIDATED = ERROR_NO_LOGON_SERVERS;

type
{ For Shell }
  PNetConnectInfoStruct = ^TNetConnectInfoStruct;
  _NETCONNECTINFOSTRUCT = packed record
    cbStructure: DWORD;
    dwFlags: DWORD;
    dwSpeed: DWORD;
    dwDelay: DWORD;
    dwOptDataSize: DWORD;
  end;
  TNetConnectInfoStruct = _NETCONNECTINFOSTRUCT;
  NETCONNECTINFOSTRUCT = _NETCONNECTINFOSTRUCT;

const
  WNCON_FORNETCARD = 1;
  WNCON_NOTROUTED = 2;
  WNCON_SLOWLINK = 4;
  WNCON_DYNAMIC = 8;

function MultinetGetConnectionPerformanceA(lpNetResource: PNetResourceA;
  lpNetConnectInfoStruc: PNetConnectInfoStruct): DWORD; stdcall;
function MultinetGetConnectionPerformanceW(lpNetResource: PNetResourceW;
  lpNetConnectInfoStruc: PNetConnectInfoStruct): DWORD; stdcall;
function MultinetGetConnectionPerformance(lpNetResource: PNetResource;
  lpNetConnectInfoStruc: PNetConnectInfoStruct): DWORD; stdcall;

{ Translated from DDE.H }

const
  WM_DDE_FIRST      = $03E0;
  WM_DDE_INITIATE   = WM_DDE_FIRST;
  WM_DDE_TERMINATE  = WM_DDE_FIRST+1;
  WM_DDE_ADVISE     = WM_DDE_FIRST+2;
  WM_DDE_UNADVISE   = WM_DDE_FIRST+3;
  WM_DDE_ACK        = WM_DDE_FIRST+4;
  WM_DDE_DATA       = WM_DDE_FIRST+5;
  WM_DDE_REQUEST    = WM_DDE_FIRST+6;
  WM_DDE_POKE       = WM_DDE_FIRST+7;
  WM_DDE_EXECUTE    = WM_DDE_FIRST+8;
  WM_DDE_LAST       = WM_DDE_FIRST+8;

{ Constants used for a WM_DDE_ACK message sent in responce to a WM_DDE_DATA
  WM_DDE_REQUEST, WM_DDE_POKE, WM_DDE_ADVISE, or WM_DDE_UNADVISE message.
  For example
    if lParam and dde_Ack <> 0 then ...
}

type
  PDDEAck = ^TDDEAck;
  DDEACK = packed record
(*
    unsigned bAppReturnCode:8,
             reserved:6,
             fBusy:1,
             fAck:1;
*)
    Flags: Word;
  end;
  TDDEAck = DDEACK;

const
  dde_AppReturnCode = $00FF;
  dde_Busy          = $4000;
  dde_Ack           = $8000;

{ Record for the  WM_DDE_ADVISE Options parameter (LoWord(lParam)) }

type
  PDDEAdvise = ^TDDEAdvise;
  DDEADVISE = packed record
(*
    unsigned reserved:14,
             fDeferUpd:1,
             fAckReq:1;
*)
    Flags: Word;
    cfFormat: SmallInt;
  end;
  TDDEAdvise = DDEADVISE;

const
  dde_DeferUpd     = $4000;
  dde_AckReq       = $8000;

{ Record for the hData parameter of a WM_DDE_DATA message (LoWord(lParam)).
  The actual size of this record depends on the size of the Value
  array. }

type
  PDDEData = ^TDDEData;
  DDEDATA = packed record
(*  unsigned unused:12,
             fResponse:1,
             fRelease:1,
             reserved:1,
             fAckReq:1;
*)
    Flags: Word;
    cfFormat: SmallInt;
    Value: array[0..0] of Byte;
    Reserved: array[0..0] of Byte;
  end;
  TDDEData = DDEDATA;

const
  dde_Response = $1000;
  dde_Release  = $2000;

{ Record for the hData parameter of the WM_DDE_POKE record (LoWord(lParam)).
  The actual size of this record depends on the size of the Value array. }

type
  PDDEPoke = ^TDDEPoke;
  DDEPOKE = packed record
(*  unsigned unused:13,
             fRelease:1,
             fReserved:2;
*)
    Flags: Word;
    cfFormat: SmallInt;
    Value: array[0..0] of Byte;
    Reserved: array[0..0] of Byte;
  end;
  TDDEPoke = DDEPOKE;

{ DDE Security }

function DdeSetQualityOfService(hWndClient: HWnd; const pqosNew: TSecurityQualityOfService;
  pqosPrev: PSecurityQualityOfService): BOOL; stdcall;
function ImpersonateDdeClientWindow(hWndClient: HWnd; hWndServer: HWnd): BOOL; stdcall;

{ DDE message packing APIs }
function PackDDElParam(msg: UINT; uiLo: UINT; uiHi: UINT): Longint; stdcall;
function UnpackDDElParam(msg: UINT; lParam: Longint; puiLo: PUINT; puiHi: PUINT): BOOL; stdcall;
function FreeDDElParam(msg: UINT; lParam: Longint): BOOL; stdcall;
function ReuseDDElParam(lParam: Longint; msgIn: UINT; msgOut: UINT; uiLo: UINT; uiHi: UINT): Longint; stdcall;

{ From zmouse.h }

{ Client Appplication (API) Defines for Wheel rolling }

const
  // Apps need to call RegisterWindowMessage using the constant below to
  // get the message number that is sent to the foreground window
  // when a wheel roll occurs
  MSH_MOUSEWHEEL   = 'MSWHEEL_ROLLMSG';
   // wParam = wheel rotation expressed in multiples of WHEEL_DELTA
   // lParam is the mouse coordinates

{ Client Appplication (API) Defines for
   *  determining if wheel support active
   *  determining # of Scroll Lines }

  // Class name for MSWHEEL.EXE's invisible window
  // use FindWindow to get hwnd to MSWHEEL
  MOUSEZ_CLASSNAME = 'MouseZ';            // wheel window class
  MOUSEZ_TITLE     = 'Magellan MSWHEEL';  // wheel window title

  MSH_WHEELMODULE_CLASS = MOUSEZ_CLASSNAME;
  MSH_WHEELMODULE_TITLE = MOUSEZ_TITLE;

// Apps need to call RegisterWindowMessage using the constants
// below to get the message numbers for:
// 1) the message that can be sent to the MSWHEEL window to
//    query if wheel support is active (MSH_WHEELSUPPORT)>
// 2) the message to query for the number of scroll lines
//    (MSH_SCROLL_LINES)
//
// To send a message to MSWheel window, use FindWindow with the #defines
// for CLASS and TITLE above.  If FindWindow fails to find the MSWHEEL
// window or the return from SendMessage is false, then Wheel support
// is not currently available.

  // MSH_WHEELSUPPORT
  //    wParam - not used
  //  lParam - not used
  //    returns BOOL - TRUE if wheel support is active, FALSE otherwise
  MSH_WHEELSUPPORT = 'MSH_WHEELSUPPORT_MSG';  // name of msg to send
                                              // to query for wheel support
  // MSH_SCROLL_LINES
  //    wParam - not used
  //    lParam - not used
  //    returns int  - number of lines to scroll on a wheel roll
  MSH_SCROLL_LINES = 'MSH_SCROLL_LINES_MSG';

(*********************************************************************
* FUNCTION: HwndMsWheel
* Purpose : Get a reference to MSWheel Window, the registered messages,
*           wheel support active setting, and number of scrollLines
* Params  : puiMsh_MsgMouseWheel - UINT to contain returned registered wheel message
*           puiMsh_Msg3DSupport - UINT to contain wheel support registered message
*           puiMsh_MsgScrollLines - UINT to contain Scroll lines registered message
*           pf3DSupport - BOOL to contain returned flag for wheel support active
*           piScrollLines - Integer to contain returned scroll lines
* Returns : HWND handle to the MsWheel window
* Note    : The return value for pf3DSupport and piScrollLines is dependant
*           on the POINT32 module.  If POINT32 module is not running then
*           the values returned for these parameters will be
*           FALSE and 3, respectively.
*********************************************************************)

function HwndMSWheel(var puiMsh_MsgMouseWheel, puiMsh_Msg3DSupport,
  puiMsh_MsgScrollLines: UINT; var pf3DSupport: BOOL;
  var piScrollLines: Integer): HWND;

//64-Bit longpointer constants

const
  GWLP_WNDPROC = -4;
  GWLP_HINSTANCE = -6;
  GWLP_HWNDPARENT = -8;
  GWLP_USERDATA = -21;
  GWLP_ID = -12;

function GetWindowLongPtr(hWnd: HWND; nIndex: Integer): LONG_PTR; stdcall;
function GetWindowLongPtrA(hWnd: HWND; nIndex: Integer): LONG_PTR; stdcall;
function GetWindowLongPtrW(hWnd: HWND; nIndex: Integer): LONG_PTR; stdcall;

function SetWindowLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR; stdcall;
function SetWindowLongPtrA(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR; stdcall;
function SetWindowLongPtrW(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR; stdcall;


const
  advapi32  = 'advapi32.dll';
  kernel32  = 'kernel32.dll';
  mpr       = 'mpr.dll';
  version   = 'version.dll';
  comctl32  = 'comctl32.dll';
  gdi32     = 'gdi32.dll';
  opengl32  = 'opengl32.dll';
  user32    = 'user32.dll';
  wintrust  = 'wintrust.dll';
  msimg32   = 'msimg32.dll';

implementation

{ Externals from advapi32.dll }

function AbortSystemShutdownA; external advapi32 name 'AbortSystemShutdownA';
function AbortSystemShutdownW; external advapi32 name 'AbortSystemShutdownW';
function AbortSystemShutdown; external advapi32 name 'AbortSystemShutdown'+_X;
function AccessCheck; external advapi32 name 'AccessCheck';
function AccessCheckAndAuditAlarmA; external advapi32 name 'AccessCheckAndAuditAlarmA';
function AccessCheckAndAuditAlarmW; external advapi32 name 'AccessCheckAndAuditAlarmW';
function AccessCheckAndAuditAlarm; external advapi32 name 'AccessCheckAndAuditAlarm'+_X;
function AccessCheckByType; external advapi32 name 'AccessCheckByType';
function AccessCheckByTypeAndAuditAlarmA; external advapi32 name 'AccessCheckByTypeAndAuditAlarmA';
function AccessCheckByTypeAndAuditAlarmW; external advapi32 name 'AccessCheckByTypeAndAuditAlarmW';
function AccessCheckByTypeAndAuditAlarm; external advapi32 name 'AccessCheckByTypeAndAuditAlarm'+_X;
function AccessCheckByTypeResultList; external advapi32 name 'AccessCheckByTypeResultList';
function AccessCheckByTypeResultListAndAuditAlarmA; external advapi32 name 'AccessCheckByTypeResultListAndAuditAlarmA';
function AccessCheckByTypeResultListAndAuditAlarmW; external advapi32 name 'AccessCheckByTypeResultListAndAuditAlarmW';
function AccessCheckByTypeResultListAndAuditAlarm; external advapi32 name 'AccessCheckByTypeResultListAndAuditAlarm'+_X;
function AddAccessAllowedAce; external advapi32 name 'AddAccessAllowedAce';
function AddAccessAllowedAceEx; external advapi32 name 'AddAccessAllowedAceEx';
function AddAccessAllowedObjectAce; external advapi32 name 'AddAccessAllowedObjectAce';
function AddAccessDeniedAce; external advapi32 name 'AddAccessDeniedAce';
function AddAccessDeniedObjectAce; external advapi32 name 'AddAccessDeniedObjectAce';
function AddAccessDeniedAceEx; external advapi32 name 'AddAccessDeniedAceEx';
function AddAce; external advapi32 name 'AddAce';
function AddAuditAccessAce; external advapi32 name 'AddAuditAccessAce';
function AddAuditAccessAceEx; external advapi32 name 'AddAuditAccessAceEx';
function AddAuditAccessObjectAce; external advapi32 name 'AddAuditAccessObjectAce';
function AdjustTokenGroups; external advapi32 name 'AdjustTokenGroups';
function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  var PreviousState: TTokenPrivileges; var ReturnLength: DWORD): BOOL; external advapi32 name 'AdjustTokenPrivileges';
{$ifdef bDelphi5}
function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  PreviousState: PTokenPrivileges; var ReturnLength: DWORD): BOOL; external advapi32 name 'AdjustTokenPrivileges';
{$endif bDelphi5}  
function AllocateAndInitializeSid; external advapi32 name 'AllocateAndInitializeSid';
function AllocateLocallyUniqueId; external advapi32 name 'AllocateLocallyUniqueId';
function AreAllAccessesGranted; external advapi32 name 'AreAllAccessesGranted';
function AreAnyAccessesGranted; external advapi32 name 'AreAnyAccessesGranted';
function BackupEventLogA; external advapi32 name 'BackupEventLogA';
function BackupEventLogW; external advapi32 name 'BackupEventLogW';
function BackupEventLog; external advapi32 name 'BackupEventLog'+_X;
function ClearEventLogA; external advapi32 name 'ClearEventLogA';
function ClearEventLogW; external advapi32 name 'ClearEventLogW';
function ClearEventLog; external advapi32 name 'ClearEventLog'+_X;
function CloseEventLog; external advapi32 name 'CloseEventLog';
function ConvertToAutoInheritPrivateObjectSecurity; external advapi32 name 'ConvertToAutoInheritPrivateObjectSecurity';
function CopySid; external advapi32 name 'CopySid';
function CreatePrivateObjectSecurity; external advapi32 name 'CreatePrivateObjectSecurity';
function CreatePrivateObjectSecurityEx; external advapi32 name 'CreatePrivateObjectSecurityEx';
function CreateProcessAsUserA; external advapi32 name 'CreateProcessAsUserA';
function CreateProcessAsUserW; external advapi32 name 'CreateProcessAsUserW';
function CreateProcessAsUser; external advapi32 name 'CreateProcessAsUser'+_X;
function DeleteAce; external advapi32 name 'DeleteAce';
function DeregisterEventSource; external advapi32 name 'DeregisterEventSource';
function DestroyPrivateObjectSecurity; external advapi32 name 'DestroyPrivateObjectSecurity';
function DuplicateToken; external advapi32 name 'DuplicateToken';
function DuplicateTokenEx; external advapi32 name 'DuplicateTokenEx';
function EqualPrefixSid; external advapi32 name 'EqualPrefixSid';
function EqualSid; external advapi32 name 'EqualSid';
function FindFirstFreeAce; external advapi32 name 'FindFirstFreeAce';
function FreeSid; external advapi32 name 'FreeSid';
function GetAce; external advapi32 name 'GetAce';
function GetAclInformation; external advapi32 name 'GetAclInformation';
function GetCurrentHwProfileA; external advapi32 name 'GetCurrentHwProfileA';
function GetCurrentHwProfileW; external advapi32 name 'GetCurrentHwProfileW';
function GetCurrentHwProfile; external advapi32 name 'GetCurrentHwProfile'+_X;
function GetFileSecurityA; external advapi32 name 'GetFileSecurityA';
function GetFileSecurityW; external advapi32 name 'GetFileSecurityW';
function GetFileSecurity; external advapi32 name 'GetFileSecurity'+_X;
function GetKernelObjectSecurity; external advapi32 name 'GetKernelObjectSecurity';
function GetLengthSid; external advapi32 name 'GetLengthSid';
function GetNumberOfEventLogRecords; external advapi32 name 'GetNumberOfEventLogRecords';
function GetOldestEventLogRecord; external advapi32 name 'GetOldestEventLogRecord';
function GetPrivateObjectSecurity; external advapi32 name 'GetPrivateObjectSecurity';
function GetSecurityDescriptorControl; external advapi32 name 'GetSecurityDescriptorControl';
function GetSecurityDescriptorDacl; external advapi32 name 'GetSecurityDescriptorDacl';
function GetSecurityDescriptorGroup; external advapi32 name 'GetSecurityDescriptorGroup';
function GetSecurityDescriptorLength; external advapi32 name 'GetSecurityDescriptorLength';
function GetSecurityDescriptorOwner; external advapi32 name 'GetSecurityDescriptorOwner';
function GetSecurityDescriptorSacl; external advapi32 name 'GetSecurityDescriptorSacl';
function GetSidIdentifierAuthority; external advapi32 name 'GetSidIdentifierAuthority';
function GetSidLengthRequired; external advapi32 name 'GetSidLengthRequired';
function GetSidSubAuthority; external advapi32 name 'GetSidSubAuthority';
function GetSidSubAuthorityCount; external advapi32 name 'GetSidSubAuthorityCount';
function GetTokenInformation; external advapi32 name 'GetTokenInformation';
function GetUserNameA; external advapi32 name 'GetUserNameA';
function GetUserNameW; external advapi32 name 'GetUserNameW';
function GetUserName; external advapi32 name 'GetUserName'+_X;
function ImpersonateLoggedOnUser; external advapi32 name 'ImpersonateLoggedOnUser';
function ImpersonateNamedPipeClient; external advapi32 name 'ImpersonateNamedPipeClient';
function ImpersonateSelf; external advapi32 name 'ImpersonateSelf';
function InitializeAcl; external advapi32 name 'InitializeAcl';
function InitializeSecurityDescriptor; external advapi32 name 'InitializeSecurityDescriptor';
function InitializeSid; external advapi32 name 'InitializeSid';
function InitiateSystemShutdownA; external advapi32 name 'InitiateSystemShutdownA';
function InitiateSystemShutdownW; external advapi32 name 'InitiateSystemShutdownW';
function InitiateSystemShutdown; external advapi32 name 'InitiateSystemShutdown'+_X;
function IsTextUnicode; external advapi32 name 'IsTextUnicode';
function IsValidAcl; external advapi32 name 'IsValidAcl';
function IsValidSecurityDescriptor; external advapi32 name 'IsValidSecurityDescriptor';
function IsValidSid; external advapi32 name 'IsValidSid';
function LogonUserA; external advapi32 name 'LogonUserA';
function LogonUserW; external advapi32 name 'LogonUserW';
function LogonUser; external advapi32 name 'LogonUser'+_X;
function LookupAccountNameA; external advapi32 name 'LookupAccountNameA';
function LookupAccountNameW; external advapi32 name 'LookupAccountNameW';
function LookupAccountName; external advapi32 name 'LookupAccountName'+_X;
function LookupAccountSidA; external advapi32 name 'LookupAccountSidA';
function LookupAccountSidW; external advapi32 name 'LookupAccountSidW';
function LookupAccountSid; external advapi32 name 'LookupAccountSid'+_X;
function LookupPrivilegeDisplayNameA; external advapi32 name 'LookupPrivilegeDisplayNameA';
function LookupPrivilegeDisplayNameW; external advapi32 name 'LookupPrivilegeDisplayNameW';
function LookupPrivilegeDisplayName; external advapi32 name 'LookupPrivilegeDisplayName'+_X;
function LookupPrivilegeNameA; external advapi32 name 'LookupPrivilegeNameA';
function LookupPrivilegeNameW; external advapi32 name 'LookupPrivilegeNameW';
function LookupPrivilegeName; external advapi32 name 'LookupPrivilegeName'+_X;
function LookupPrivilegeValueA; external advapi32 name 'LookupPrivilegeValueA';
function LookupPrivilegeValueW; external advapi32 name 'LookupPrivilegeValueW';
function LookupPrivilegeValue; external advapi32 name 'LookupPrivilegeValue'+_X;
function MakeAbsoluteSD; external advapi32 name 'MakeAbsoluteSD';
function MakeSelfRelativeSD; external advapi32 name 'MakeSelfRelativeSD';
procedure MapGenericMask; external advapi32 name 'MapGenericMask';
function NotifyChangeEventLog; external advapi32 name 'NotifyChangeEventLog';
function ObjectCloseAuditAlarmA; external advapi32 name 'ObjectCloseAuditAlarmA';
function ObjectCloseAuditAlarmW; external advapi32 name 'ObjectCloseAuditAlarmW';
function ObjectCloseAuditAlarm; external advapi32 name 'ObjectCloseAuditAlarm'+_X;
function ObjectDeleteAuditAlarmA; external advapi32 name 'ObjectDeleteAuditAlarmA';
function ObjectDeleteAuditAlarmW; external advapi32 name 'ObjectDeleteAuditAlarmW';
function ObjectDeleteAuditAlarm; external advapi32 name 'ObjectDeleteAuditAlarm'+_X;
function ObjectOpenAuditAlarmA; external advapi32 name 'ObjectOpenAuditAlarmA';
function ObjectOpenAuditAlarmW; external advapi32 name 'ObjectOpenAuditAlarmW';
function ObjectOpenAuditAlarm; external advapi32 name 'ObjectOpenAuditAlarm'+_X;
function ObjectPrivilegeAuditAlarmA; external advapi32 name 'ObjectPrivilegeAuditAlarmA';
function ObjectPrivilegeAuditAlarmW; external advapi32 name 'ObjectPrivilegeAuditAlarmW';
function ObjectPrivilegeAuditAlarm; external advapi32 name 'ObjectPrivilegeAuditAlarm'+_X;
function OpenBackupEventLogA; external advapi32 name 'OpenBackupEventLogA';
function OpenBackupEventLogW; external advapi32 name 'OpenBackupEventLogW';
function OpenBackupEventLog; external advapi32 name 'OpenBackupEventLog'+_X;
function OpenEventLogA; external advapi32 name 'OpenEventLogA';
function OpenEventLogW; external advapi32 name 'OpenEventLogW';
function OpenEventLog; external advapi32 name 'OpenEventLog'+_X;
function OpenProcessToken; external advapi32 name 'OpenProcessToken';
function OpenThreadToken; external advapi32 name 'OpenThreadToken';
function PrivilegeCheck; external advapi32 name 'PrivilegeCheck';
function PrivilegedServiceAuditAlarmA; external advapi32 name 'PrivilegedServiceAuditAlarmA';
function PrivilegedServiceAuditAlarmW; external advapi32 name 'PrivilegedServiceAuditAlarmW';
function PrivilegedServiceAuditAlarm; external advapi32 name 'PrivilegedServiceAuditAlarm'+_X;
function ReadEventLogA; external advapi32 name 'ReadEventLogA';
function ReadEventLogW; external advapi32 name 'ReadEventLogW';
function ReadEventLog; external advapi32 name 'ReadEventLog'+_X;
function RegCloseKey; external advapi32 name 'RegCloseKey';
function RegConnectRegistryA; external advapi32 name 'RegConnectRegistryA';
function RegConnectRegistryW; external advapi32 name 'RegConnectRegistryW';
function RegConnectRegistry; external advapi32 name 'RegConnectRegistry'+_X;
function RegCreateKeyA; external advapi32 name 'RegCreateKeyA';
function RegCreateKeyW; external advapi32 name 'RegCreateKeyW';
function RegCreateKey; external advapi32 name 'RegCreateKey'+_X;
function RegCreateKeyExA; external advapi32 name 'RegCreateKeyExA';
function RegCreateKeyExW; external advapi32 name 'RegCreateKeyExW';
function RegCreateKeyEx; external advapi32 name 'RegCreateKeyEx'+_X;
function RegDeleteKeyA; external advapi32 name 'RegDeleteKeyA';
function RegDeleteKeyW; external advapi32 name 'RegDeleteKeyW';
function RegDeleteKey; external advapi32 name 'RegDeleteKey'+_X;
function RegDeleteValueA; external advapi32 name 'RegDeleteValueA';
function RegDeleteValueW; external advapi32 name 'RegDeleteValueW';
function RegDeleteValue; external advapi32 name 'RegDeleteValue'+_X;
function RegEnumKeyExA; external advapi32 name 'RegEnumKeyExA';
function RegEnumKeyExW; external advapi32 name 'RegEnumKeyExW';
function RegEnumKeyEx; external advapi32 name 'RegEnumKeyEx'+_X;
function RegEnumKeyA; external advapi32 name 'RegEnumKeyA';
function RegEnumKeyW; external advapi32 name 'RegEnumKeyW';
function RegEnumKey; external advapi32 name 'RegEnumKey'+_X;
function RegEnumValueA; external advapi32 name 'RegEnumValueA';
function RegEnumValueW; external advapi32 name 'RegEnumValueW';
function RegEnumValue; external advapi32 name 'RegEnumValue'+_X;
function RegFlushKey; external advapi32 name 'RegFlushKey';
function RegGetKeySecurity; external advapi32 name 'RegGetKeySecurity';
function RegLoadKeyA; external advapi32 name 'RegLoadKeyA';
function RegLoadKeyW; external advapi32 name 'RegLoadKeyW';
function RegLoadKey; external advapi32 name 'RegLoadKey'+_X;
function RegNotifyChangeKeyValue; external advapi32 name 'RegNotifyChangeKeyValue';
function RegOpenKeyA; external advapi32 name 'RegOpenKeyA';
function RegOpenKeyW; external advapi32 name 'RegOpenKeyW';
function RegOpenKey; external advapi32 name 'RegOpenKey'+_X;
function RegOpenKeyExA; external advapi32 name 'RegOpenKeyExA';
function RegOpenKeyExW; external advapi32 name 'RegOpenKeyExW';
function RegOpenKeyEx; external advapi32 name 'RegOpenKeyEx'+_X;
function RegQueryInfoKeyA; external advapi32 name 'RegQueryInfoKeyA';
function RegQueryInfoKeyW; external advapi32 name 'RegQueryInfoKeyW';
function RegQueryInfoKey; external advapi32 name 'RegQueryInfoKey'+_X;
function RegQueryMultipleValuesA; external advapi32 name 'RegQueryMultipleValuesA';
function RegQueryMultipleValuesW; external advapi32 name 'RegQueryMultipleValuesW';
function RegQueryMultipleValues; external advapi32 name 'RegQueryMultipleValues'+_X;
function RegQueryValueA; external advapi32 name 'RegQueryValueA';
function RegQueryValueW; external advapi32 name 'RegQueryValueW';
function RegQueryValue; external advapi32 name 'RegQueryValue'+_X;
function RegQueryValueExA; external advapi32 name 'RegQueryValueExA';
function RegQueryValueExW; external advapi32 name 'RegQueryValueExW';
function RegQueryValueEx; external advapi32 name 'RegQueryValueEx'+_X;
function RegReplaceKeyA; external advapi32 name 'RegReplaceKeyA';
function RegReplaceKeyW; external advapi32 name 'RegReplaceKeyW';
function RegReplaceKey; external advapi32 name 'RegReplaceKey'+_X;
function RegRestoreKeyA; external advapi32 name 'RegRestoreKeyA';
function RegRestoreKeyW; external advapi32 name 'RegRestoreKeyW';
function RegRestoreKey; external advapi32 name 'RegRestoreKey'+_X;
function RegSaveKeyA; external advapi32 name 'RegSaveKeyA';
function RegSaveKeyW; external advapi32 name 'RegSaveKeyW';
function RegSaveKey; external advapi32 name 'RegSaveKey'+_X;
function RegSetKeySecurity; external advapi32 name 'RegSetKeySecurity';
function RegSetValueA; external advapi32 name 'RegSetValueA';
function RegSetValueW; external advapi32 name 'RegSetValueW';
function RegSetValue; external advapi32 name 'RegSetValue'+_X;
function RegSetValueExA; external advapi32 name 'RegSetValueExA';
function RegSetValueExW; external advapi32 name 'RegSetValueExW';
function RegSetValueEx; external advapi32 name 'RegSetValueEx'+_X;
function RegUnLoadKeyA; external advapi32 name 'RegUnLoadKeyA';
function RegUnLoadKeyW; external advapi32 name 'RegUnLoadKeyW';
function RegUnLoadKey; external advapi32 name 'RegUnLoadKey'+_X;
function RegisterEventSourceA; external advapi32 name 'RegisterEventSourceA';
function RegisterEventSourceW; external advapi32 name 'RegisterEventSourceW';
function RegisterEventSource; external advapi32 name 'RegisterEventSource'+_X;
function ReportEventA; external advapi32 name 'ReportEventA';
function ReportEventW; external advapi32 name 'ReportEventW';
function ReportEvent; external advapi32 name 'ReportEvent'+_X;
function RevertToSelf; external advapi32 name 'RevertToSelf';
function SetAclInformation; external advapi32 name 'SetAclInformation';
function SetFileSecurityA; external advapi32 name 'SetFileSecurityA';
function SetFileSecurityW; external advapi32 name 'SetFileSecurityW';
function SetFileSecurity; external advapi32 name 'SetFileSecurity'+_X;
function SetKernelObjectSecurity; external advapi32 name 'SetKernelObjectSecurity';
function SetPrivateObjectSecurity; external advapi32 name 'SetPrivateObjectSecurity';
function SetPrivateObjectSecurityEx; external advapi32 name 'SetPrivateObjectSecurityEx';
function SetSecurityDescriptorControl; external advapi32 name 'SetSecurityDescriptorControl';
function SetSecurityDescriptorDacl; external advapi32 name 'SetSecurityDescriptorDacl';
function SetSecurityDescriptorGroup; external advapi32 name 'SetSecurityDescriptorGroup';
function SetSecurityDescriptorOwner; external advapi32 name 'SetSecurityDescriptorOwner';
function SetSecurityDescriptorSacl; external advapi32 name 'SetSecurityDescriptorSacl';
function SetThreadToken; external advapi32 name 'SetThreadToken';
function SetTokenInformation; external advapi32 name 'SetTokenInformation';

{ Externals from imaghlp.dll }

{ !!! these fuctions are not yet available in this dll
function WinSubmitCertificate; external imaghlp name 'WinSubmitCertificate';
function WinVerifyTrust; external imaghlp name 'WinVerifyTrust'; }

{ Externals from kernel32.dll }

function AddAtomA; external kernel32 name 'AddAtomA';
function AddAtomW; external kernel32 name 'AddAtomW';
function AddAtom; external kernel32 name 'AddAtom'+_X;
function AllocConsole; external kernel32 name 'AllocConsole';
function AreFileApisANSI; external kernel32 name 'AreFileApisANSI';
function BackupRead; external kernel32 name 'BackupRead';
function BackupSeek; external kernel32 name 'BackupSeek';
function BackupWrite; external kernel32 name 'BackupWrite';
function Beep; external kernel32 name 'Beep';
function BeginUpdateResourceA; external kernel32 name 'BeginUpdateResourceA';
function BeginUpdateResourceW; external kernel32 name 'BeginUpdateResourceW';
function BeginUpdateResource; external kernel32 name 'BeginUpdateResource'+_X;
function BuildCommDCBA; external kernel32 name 'BuildCommDCBA';
function BuildCommDCBW; external kernel32 name 'BuildCommDCBW';
function BuildCommDCB; external kernel32 name 'BuildCommDCB'+_X;
function BuildCommDCBAndTimeoutsA; external kernel32 name 'BuildCommDCBAndTimeoutsA';
function BuildCommDCBAndTimeoutsW; external kernel32 name 'BuildCommDCBAndTimeoutsW';
function BuildCommDCBAndTimeouts; external kernel32 name 'BuildCommDCBAndTimeouts'+_X;
function CallNamedPipeA; external kernel32 name 'CallNamedPipeA';
function CallNamedPipeW; external kernel32 name 'CallNamedPipeW';
function CallNamedPipe; external kernel32 name 'CallNamedPipe'+_X;
function CancelIo; external kernel32 name 'CancelIo';
function CancelWaitableTimer; external kernel32 name 'CancelWaitableTimer';
function ClearCommBreak; external kernel32 name 'ClearCommBreak';
function ClearCommError; external kernel32 name 'ClearCommError';
function CloseHandle; external kernel32 name 'CloseHandle';
procedure CloseRaw; external kernel32 name 'CloseRaw';
function CommConfigDialogA; external kernel32 name 'CommConfigDialogA';
function CommConfigDialogW; external kernel32 name 'CommConfigDialogW';
function CommConfigDialog; external kernel32 name 'CommConfigDialog'+_X;
function CompareFileTime; external kernel32 name 'CompareFileTime';
function CompareStringA; external kernel32 name 'CompareStringA';
function CompareStringW; external kernel32 name 'CompareStringW';
function CompareString; external kernel32 name 'CompareString'+_X;
function ConnectNamedPipe; external kernel32 name 'ConnectNamedPipe';
function ContinueDebugEvent; external kernel32 name 'ContinueDebugEvent';
function ConvertThreadToFiber; external kernel32 name 'ConvertThreadToFiber';
function ConvertDefaultLocale; external kernel32 name 'ConvertDefaultLocale';
function CopyFileA; external kernel32 name 'CopyFileA';
function CopyFileExA; external kernel32 name 'CopyFileExA';
function CopyFileW; external kernel32 name 'CopyFileW';
function CopyFileExW; external kernel32 name 'CopyFileExW';
function CopyFile; external kernel32 name 'CopyFile'+_X;
function CopyFileEx; external kernel32 name 'CopyFileEx'+_X;
function CreateConsoleScreenBuffer; external kernel32 name 'CreateConsoleScreenBuffer';
function CreateDirectoryA; external kernel32 name 'CreateDirectoryA';
function CreateDirectoryW; external kernel32 name 'CreateDirectoryW';
function CreateDirectory; external kernel32 name 'CreateDirectory'+_X;
function CreateDirectoryExA; external kernel32 name 'CreateDirectoryExA';
function CreateDirectoryExW; external kernel32 name 'CreateDirectoryExW';
function CreateDirectoryEx; external kernel32 name 'CreateDirectoryEx'+_X;
function CreateEventA; external kernel32 name 'CreateEventA';
function CreateEventW; external kernel32 name 'CreateEventW';
function CreateEvent; external kernel32 name 'CreateEvent'+_X;
function CreateFiber; external kernel32 name 'CreateFiber';
function CreateFileA; external kernel32 name 'CreateFileA';
function CreateFileW; external kernel32 name 'CreateFileW';
function CreateFile; external kernel32 name 'CreateFile'+_X;
function CreateFileMappingA; external kernel32 name 'CreateFileMappingA';
function CreateFileMappingW; external kernel32 name 'CreateFileMappingW';
function CreateFileMapping; external kernel32 name 'CreateFileMapping'+_X;
function CreateHardLinkA; external kernel32 name 'CreateHardLinkA';
function CreateHardLinkW; external kernel32 name 'CreateHardLinkW';
function CreateHardLink; external kernel32 name 'CreateHardLink'+_X;
function CreateIoCompletionPort; external kernel32 name 'CreateIoCompletionPort';
function CreateMailslotA; external kernel32 name 'CreateMailslotA';
function CreateMailslotW; external kernel32 name 'CreateMailslotW';
function CreateMailslot; external kernel32 name 'CreateMailslot'+_X;
function CreateMutexA; external kernel32 name 'CreateMutexA';
function CreateMutexW; external kernel32 name 'CreateMutexW';
function CreateMutex; external kernel32 name 'CreateMutex'+_X;
function CreateNamedPipeA; external kernel32 name 'CreateNamedPipeA';
function CreateNamedPipeW; external kernel32 name 'CreateNamedPipeW';
function CreateNamedPipe; external kernel32 name 'CreateNamedPipe'+_X;
function CreatePipe; external kernel32 name 'CreatePipe';
function CreateProcessA; external kernel32 name 'CreateProcessA';
function CreateProcessW; external kernel32 name 'CreateProcessW';
function CreateProcess; external kernel32 name 'CreateProcess'+_X;
function CreateRemoteThread; external kernel32 name 'CreateRemoteThread';
function CreateSemaphoreA; external kernel32 name 'CreateSemaphoreA';
function CreateSemaphoreW; external kernel32 name 'CreateSemaphoreW';
function CreateSemaphore; external kernel32 name 'CreateSemaphore'+_X;
function CreateTapePartition; external kernel32 name 'CreateTapePartition';
function CreateThread; external kernel32 name 'CreateThread';
function CreateWaitableTimerA; external kernel32 name 'CreateWaitableTimerA';
function CreateWaitableTimerW; external kernel32 name 'CreateWaitableTimerW';
function CreateWaitableTimer; external kernel32 name 'CreateWaitableTimer'+_X;
function DecryptFileA; external kernel32 name 'DecryptFileA';
function DecryptFileW; external kernel32 name 'DecryptFileW';
function DecryptFile; external kernel32 name 'DecryptFile';
function DebugActiveProcess; external kernel32 name 'DebugActiveProcess';
procedure DebugBreak; external kernel32 name 'DebugBreak';
function DefineDosDeviceA; external kernel32 name 'DefineDosDeviceA';
function DefineDosDeviceW; external kernel32 name 'DefineDosDeviceW';
function DefineDosDevice; external kernel32 name 'DefineDosDevice'+_X;
function DeleteAtom; external kernel32 name 'DeleteAtom';
procedure DeleteCriticalSection; external kernel32 name 'DeleteCriticalSection';
function DeleteFiber; external kernel32 name 'DeleteFiber';
function DeleteFileA; external kernel32 name 'DeleteFileA';
function DeleteFileW; external kernel32 name 'DeleteFileW';
function DeleteFile; external kernel32 name 'DeleteFile'+_X;
function DeviceIoControl; external kernel32 name 'DeviceIoControl';
function DisableThreadLibraryCalls; external kernel32 name 'DisableThreadLibraryCalls';
function DisconnectNamedPipe; external kernel32 name 'DisconnectNamedPipe';
function DosDateTimeToFileTime; external kernel32 name 'DosDateTimeToFileTime';
function DuplicateHandle; external kernel32 name 'DuplicateHandle';
function EncryptFileA; external kernel32 name 'EncryptFileA';
function EncryptFileW; external kernel32 name 'EncryptFileW';
function EncryptFile; external kernel32 name 'EncryptFile';
function EndUpdateResourceA; external kernel32 name 'EndUpdateResourceA';
function EndUpdateResourceW; external kernel32 name 'EndUpdateResourceW';
function EndUpdateResource; external kernel32 name 'EndUpdateResource'+_X;
procedure EnterCriticalSection; external kernel32 name 'EnterCriticalSection';
function EnumCalendarInfoA; external kernel32 name 'EnumCalendarInfoA';
function EnumCalendarInfoW; external kernel32 name 'EnumCalendarInfoW';
function EnumCalendarInfo; external kernel32 name 'EnumCalendarInfo'+_X;
function EnumDateFormatsA; external kernel32 name 'EnumDateFormatsA';
function EnumDateFormatsW; external kernel32 name 'EnumDateFormatsW';
function EnumDateFormats; external kernel32 name 'EnumDateFormats'+_X;
function EnumResourceLanguagesA; external kernel32 name 'EnumResourceLanguagesA';
function EnumResourceLanguagesW; external kernel32 name 'EnumResourceLanguagesW';
function EnumResourceLanguages; external kernel32 name 'EnumResourceLanguages'+_X;
function EnumResourceNamesA; external kernel32 name 'EnumResourceNamesA';
function EnumResourceNamesW; external kernel32 name 'EnumResourceNamesW';
function EnumResourceNames; external kernel32 name 'EnumResourceNames'+_X;
function EnumResourceTypesA; external kernel32 name 'EnumResourceTypesA';
function EnumResourceTypesW; external kernel32 name 'EnumResourceTypesW';
function EnumResourceTypes; external kernel32 name 'EnumResourceTypes'+_X;
function EnumSystemCodePagesA; external kernel32 name 'EnumSystemCodePagesA';
function EnumSystemCodePagesW; external kernel32 name 'EnumSystemCodePagesW';
function EnumSystemCodePages; external kernel32 name 'EnumSystemCodePages'+_X;
function EnumSystemLocalesA; external kernel32 name 'EnumSystemLocalesA';
function EnumSystemLocalesW; external kernel32 name 'EnumSystemLocalesW';
function EnumSystemLocales; external kernel32 name 'EnumSystemLocales'+_X;
function EnumTimeFormatsA; external kernel32 name 'EnumTimeFormatsA';
function EnumTimeFormatsW; external kernel32 name 'EnumTimeFormatsW';
function EnumTimeFormats; external kernel32 name 'EnumTimeFormats'+_X;
function EraseTape; external kernel32 name 'EraseTape';
function EscapeCommFunction; external kernel32 name 'EscapeCommFunction';
procedure ExitProcess; external kernel32 name 'ExitProcess';
procedure ExitThread; external kernel32 name 'ExitThread';
function ExpandEnvironmentStringsA; external kernel32 name 'ExpandEnvironmentStringsA';
function ExpandEnvironmentStringsW; external kernel32 name 'ExpandEnvironmentStringsW';
function ExpandEnvironmentStrings; external kernel32 name 'ExpandEnvironmentStrings'+_X;
procedure FatalAppExitA; external kernel32 name 'FatalAppExitA';
procedure FatalAppExitW; external kernel32 name 'FatalAppExitW';
procedure FatalAppExit; external kernel32 name 'FatalAppExit'+_X;
procedure FatalExit; external kernel32 name 'FatalExit';
function FileTimeToDosDateTime; external kernel32 name 'FileTimeToDosDateTime';
function FileTimeToLocalFileTime; external kernel32 name 'FileTimeToLocalFileTime';
function FileTimeToSystemTime; external kernel32 name 'FileTimeToSystemTime';
function FillConsoleOutputAttribute; external kernel32 name 'FillConsoleOutputAttribute';
function FillConsoleOutputCharacterA; external kernel32 name 'FillConsoleOutputCharacterA';
function FillConsoleOutputCharacterW; external kernel32 name 'FillConsoleOutputCharacterW';
function FillConsoleOutputCharacter; external kernel32 name 'FillConsoleOutputCharacter'+_X;
function FindAtomA; external kernel32 name 'FindAtomA';
function FindAtomW; external kernel32 name 'FindAtomW';
function FindAtom; external kernel32 name 'FindAtom'+_X;
function FindClose; external kernel32 name 'FindClose';
function FindCloseChangeNotification; external kernel32 name 'FindCloseChangeNotification';
function FindFirstChangeNotificationA; external kernel32 name 'FindFirstChangeNotificationA';
function FindFirstChangeNotificationW; external kernel32 name 'FindFirstChangeNotificationW';
function FindFirstChangeNotification; external kernel32 name 'FindFirstChangeNotification'+_X;
function FindFirstFileA; external kernel32 name 'FindFirstFileA';
function FindFirstFileExA; external kernel32 name 'FindFirstFileExA';
function FindFirstFileW; external kernel32 name 'FindFirstFileW';
function FindFirstFileExW; external kernel32 name 'FindFirstFileExW';
function FindFirstFile; external kernel32 name 'FindFirstFile'+_X;
function FindFirstFileEx; external kernel32 name 'FindFirstFileEx'+_X;
function FindNextChangeNotification; external kernel32 name 'FindNextChangeNotification';
function FindNextFileA; external kernel32 name 'FindNextFileA';
function FindNextFileW; external kernel32 name 'FindNextFileW';
function FindNextFile; external kernel32 name 'FindNextFile'+_X;
function FindResourceA; external kernel32 name 'FindResourceA';
function FindResourceW; external kernel32 name 'FindResourceW';
function FindResource; external kernel32 name 'FindResource'+_X;
function FindResourceExA; external kernel32 name 'FindResourceExA';
function FindResourceExW; external kernel32 name 'FindResourceExW';
function FindResourceEx; external kernel32 name 'FindResourceEx'+_X;
function FlushConsoleInputBuffer; external kernel32 name 'FlushConsoleInputBuffer';
function FlushFileBuffers; external kernel32 name 'FlushFileBuffers';
function FlushInstructionCache; external kernel32 name 'FlushInstructionCache';
function FlushViewOfFile; external kernel32 name 'FlushViewOfFile';
function FoldStringA; external kernel32 name 'FoldStringA';
function FoldStringW; external kernel32 name 'FoldStringW';
function FoldString; external kernel32 name 'FoldString'+_X;
function FormatMessageA; external kernel32 name 'FormatMessageA';
function FormatMessageW; external kernel32 name 'FormatMessageW';
function FormatMessage; external kernel32 name 'FormatMessage'+_X;
function FreeConsole; external kernel32 name 'FreeConsole';
function FreeEnvironmentStringsA; external kernel32 name 'FreeEnvironmentStringsA';
function FreeEnvironmentStringsW; external kernel32 name 'FreeEnvironmentStringsW';
function FreeEnvironmentStrings; external kernel32 name 'FreeEnvironmentStrings'+_X;
function FreeLibrary; external kernel32 name 'FreeLibrary';
procedure FreeLibraryAndExitThread; external kernel32 name 'FreeLibraryAndExitThread';
{$ifdef b64}
{$else}
function InterlockedIncrement; external kernel32 name 'InterlockedIncrement';
function InterlockedDecrement; external kernel32 name 'InterlockedDecrement';
function InterlockedExchange; external kernel32 name 'InterlockedExchange';
function InterlockedCompareExchange; external kernel32 name 'InterlockedCompareExchange';
function InterlockedExchangeAdd; external kernel32 name 'InterlockedExchangeAdd';
{$endif b64}
function FreeResource; external kernel32 name 'FreeResource';
function GenerateConsoleCtrlEvent; external kernel32 name 'GenerateConsoleCtrlEvent';
function GetACP; external kernel32 name 'GetACP';
function GetAtomNameA; external kernel32 name 'GetAtomNameA';
function GetAtomNameW; external kernel32 name 'GetAtomNameW';
function GetAtomName; external kernel32 name 'GetAtomName'+_X;
function GetBinaryTypeA; external kernel32 name 'GetBinaryTypeA';
function GetBinaryTypeW; external kernel32 name 'GetBinaryTypeW';
function GetBinaryType; external kernel32 name 'GetBinaryType'+_X;
function GetCPInfo; external kernel32 name 'GetCPInfo';
function GetCommandLineA; external kernel32 name 'GetCommandLineA';
function GetCommandLineW; external kernel32 name 'GetCommandLineW';
function GetCommandLine; external kernel32 name 'GetCommandLine'+_X;
function GetCommConfig; external kernel32 name 'GetCommConfig';
function GetCommMask; external kernel32 name 'GetCommMask';
function GetCommModemStatus; external kernel32 name 'GetCommModemStatus';
function GetCommProperties; external kernel32 name 'GetCommProperties';
function GetCommState; external kernel32 name 'GetCommState';
function GetCommTimeouts; external kernel32 name 'GetCommTimeouts';
function GetCompressedFileSizeA; external kernel32 name 'GetCompressedFileSizeA';
function GetCompressedFileSizeW; external kernel32 name 'GetCompressedFileSizeW';
function GetCompressedFileSize; external kernel32 name 'GetCompressedFileSize'+_X;
function GetComputerNameA; external kernel32 name 'GetComputerNameA';
function GetComputerNameW; external kernel32 name 'GetComputerNameW';
function GetComputerName; external kernel32 name 'GetComputerName'+_X;
function GetConsoleCP; external kernel32 name 'GetConsoleCP';
function GetConsoleCursorInfo; external kernel32 name 'GetConsoleCursorInfo';
function GetConsoleMode; external kernel32 name 'GetConsoleMode';
function GetConsoleOutputCP; external kernel32 name 'GetConsoleOutputCP';
function GetConsoleScreenBufferInfo; external kernel32 name 'GetConsoleScreenBufferInfo';
function GetConsoleTitleA; external kernel32 name 'GetConsoleTitleA';
function GetConsoleTitleW; external kernel32 name 'GetConsoleTitleW';
function GetConsoleTitle; external kernel32 name 'GetConsoleTitle'+_X;
function GetCurrencyFormatA; external kernel32 name 'GetCurrencyFormatA';
function GetCurrencyFormatW; external kernel32 name 'GetCurrencyFormatW';
function GetCurrencyFormat; external kernel32 name 'GetCurrencyFormat'+_X;
function GetCurrentDirectoryA; external kernel32 name 'GetCurrentDirectoryA';
function GetCurrentDirectoryW; external kernel32 name 'GetCurrentDirectoryW';
function GetCurrentDirectory; external kernel32 name 'GetCurrentDirectory'+_X;
function GetCurrentProcess; external kernel32 name 'GetCurrentProcess';
function GetCurrentProcessId; external kernel32 name 'GetCurrentProcessId';
function GetCurrentThread; external kernel32 name 'GetCurrentThread';
function GetCurrentThreadId; external kernel32 name 'GetCurrentThreadId';
function GetDateFormatA; external kernel32 name 'GetDateFormatA';
function GetDateFormatW; external kernel32 name 'GetDateFormatW';
function GetDateFormat; external kernel32 name 'GetDateFormat'+_X;
function GetDefaultCommConfigA; external kernel32 name 'GetDefaultCommConfigA';
function GetDefaultCommConfigW; external kernel32 name 'GetDefaultCommConfigW';
function GetDefaultCommConfig; external kernel32 name 'GetDefaultCommConfig'+_X;
function GetDiskFreeSpaceA; external kernel32 name 'GetDiskFreeSpaceA';
function GetDiskFreeSpaceW; external kernel32 name 'GetDiskFreeSpaceW';
function GetDiskFreeSpace; external kernel32 name 'GetDiskFreeSpace'+_X;
function GetDiskFreeSpaceExA; external kernel32 name 'GetDiskFreeSpaceExA';
function GetDiskFreeSpaceExW; external kernel32 name 'GetDiskFreeSpaceExW';
function GetDiskFreeSpaceEx; external kernel32 name 'GetDiskFreeSpaceEx'+_X;
function GetDriveTypeA; external kernel32 name 'GetDriveTypeA';
function GetDriveTypeW; external kernel32 name 'GetDriveTypeW';
function GetDriveType; external kernel32 name 'GetDriveType'+_X;
function GetEnvironmentStringsA; external kernel32 name 'GetEnvironmentStringsA';
function GetEnvironmentStringsW; external kernel32 name 'GetEnvironmentStringsW';
function GetEnvironmentStrings; external kernel32 name 'GetEnvironmentStrings'+_X;
function GetEnvironmentVariableA; external kernel32 name 'GetEnvironmentVariableA';
function GetEnvironmentVariableW; external kernel32 name 'GetEnvironmentVariableW';
function GetEnvironmentVariable; external kernel32 name 'GetEnvironmentVariable'+_X;
function GetExitCodeProcess; external kernel32 name 'GetExitCodeProcess';
function GetExitCodeThread; external kernel32 name 'GetExitCodeThread';
function GetFileAttributesA; external kernel32 name 'GetFileAttributesA';
function GetFileAttributesW; external kernel32 name 'GetFileAttributesW';
function GetFileAttributes; external kernel32 name 'GetFileAttributes'+_X;
function GetFileAttributesExA; external kernel32 name 'GetFileAttributesExA';
function GetFileAttributesExW; external kernel32 name 'GetFileAttributesExW';
function GetFileAttributesEx; external kernel32 name 'GetFileAttributesEx'+_X;
function GetFileInformationByHandle; external kernel32 name 'GetFileInformationByHandle';
function GetFileSize; external kernel32 name 'GetFileSize';
function GetFileTime; external kernel32 name 'GetFileTime';
function GetFileType; external kernel32 name 'GetFileType';
function GetFullPathNameA; external kernel32 name 'GetFullPathNameA';
function GetFullPathNameW; external kernel32 name 'GetFullPathNameW';
function GetFullPathName; external kernel32 name 'GetFullPathName'+_X;
function GetHandleInformation; external kernel32 name 'GetHandleInformation';
function GetLargestConsoleWindowSize; external kernel32 name 'GetLargestConsoleWindowSize';
function GetLastError; external kernel32 name 'GetLastError';
procedure GetLocalTime; external kernel32 name 'GetLocalTime';
function GetLocaleInfoA; external kernel32 name 'GetLocaleInfoA';
function GetLocaleInfoW; external kernel32 name 'GetLocaleInfoW';
function GetLocaleInfo; external kernel32 name 'GetLocaleInfo'+_X;
function GetLogicalDriveStringsA; external kernel32 name 'GetLogicalDriveStringsA';
function GetLogicalDriveStringsW; external kernel32 name 'GetLogicalDriveStringsW';
function GetLogicalDriveStrings; external kernel32 name 'GetLogicalDriveStrings'+_X;
function GetLogicalDrives; external kernel32 name 'GetLogicalDrives';
function GetMailslotInfo; external kernel32 name 'GetMailslotInfo';
function GetModuleFileNameA; external kernel32 name 'GetModuleFileNameA';
function GetModuleFileNameW; external kernel32 name 'GetModuleFileNameW';
function GetModuleFileName; external kernel32 name 'GetModuleFileName'+_X;
function GetModuleHandleA; external kernel32 name 'GetModuleHandleA';
function GetModuleHandleW; external kernel32 name 'GetModuleHandleW';
function GetModuleHandle; external kernel32 name 'GetModuleHandle'+_X;
function GetNamedPipeHandleStateA; external kernel32 name 'GetNamedPipeHandleStateA';
function GetNamedPipeHandleStateW; external kernel32 name 'GetNamedPipeHandleStateW';
function GetNamedPipeHandleState; external kernel32 name 'GetNamedPipeHandleState'+_X;
function GetNamedPipeInfo; external kernel32 name 'GetNamedPipeInfo';
function GetNumberFormatA; external kernel32 name 'GetNumberFormatA';
function GetNumberFormatW; external kernel32 name 'GetNumberFormatW';
function GetNumberFormat; external kernel32 name 'GetNumberFormat'+_X;
function GetNumberOfConsoleInputEvents; external kernel32 name 'GetNumberOfConsoleInputEvents';
function GetNumberOfConsoleMouseButtons; external kernel32 name 'GetNumberOfConsoleMouseButtons';
function GetOEMCP; external kernel32 name 'GetOEMCP';
function GetOverlappedResult; external kernel32 name 'GetOverlappedResult';
function GetPriorityClass; external kernel32 name 'GetPriorityClass';
function GetPrivateProfileIntA; external kernel32 name 'GetPrivateProfileIntA';
function GetPrivateProfileIntW; external kernel32 name 'GetPrivateProfileIntW';
function GetPrivateProfileInt; external kernel32 name 'GetPrivateProfileInt'+_X;
function GetPrivateProfileSectionA; external kernel32 name 'GetPrivateProfileSectionA';
function GetPrivateProfileSectionW; external kernel32 name 'GetPrivateProfileSectionW';
function GetPrivateProfileSection; external kernel32 name 'GetPrivateProfileSection'+_X;
function GetPrivateProfileSectionNamesA; external kernel32 name 'GetPrivateProfileSectionNamesA';
function GetPrivateProfileSectionNamesW; external kernel32 name 'GetPrivateProfileSectionNamesW';
function GetPrivateProfileSectionNames; external kernel32 name 'GetPrivateProfileSectionNames'+_X;
function GetPrivateProfileStringA; external kernel32 name 'GetPrivateProfileStringA';
function GetPrivateProfileStringW; external kernel32 name 'GetPrivateProfileStringW';
function GetPrivateProfileString; external kernel32 name 'GetPrivateProfileString'+_X;
function GetProcAddress; external kernel32 name 'GetProcAddress';
function GetProcessAffinityMask; external kernel32 name 'GetProcessAffinityMask';
function GetProcessHeap; external kernel32 name 'GetProcessHeap';
function GetProcessHeaps; external kernel32 name 'GetProcessHeaps';
function GetProcessPriorityBoost; external kernel32 name 'GetProcessPriorityBoost';
function GetProcessShutdownParameters; external kernel32 name 'GetProcessShutdownParameters';
function GetProcessTimes; external kernel32 name 'GetProcessTimes';
function GetProcessVersion; external kernel32 name 'GetProcessVersion';
function GetProcessWorkingSetSize; external kernel32 name 'GetProcessWorkingSetSize';
function GetProfileIntA; external kernel32 name 'GetProfileIntA';
function GetProfileIntW; external kernel32 name 'GetProfileIntW';
function GetProfileInt; external kernel32 name 'GetProfileInt'+_X;
function GetProfileSectionA; external kernel32 name 'GetProfileSectionA';
function GetProfileSectionW; external kernel32 name 'GetProfileSectionW';
function GetProfileSection; external kernel32 name 'GetProfileSection'+_X;
function GetProfileStringA; external kernel32 name 'GetProfileStringA';
function GetProfileStringW; external kernel32 name 'GetProfileStringW';
function GetProfileString; external kernel32 name 'GetProfileString'+_X;
function GetQueuedCompletionStatus; external kernel32 name 'GetQueuedCompletionStatus';
function GetShortPathNameA; external kernel32 name 'GetShortPathNameA';
function GetShortPathNameW; external kernel32 name 'GetShortPathNameW';
function GetShortPathName; external kernel32 name 'GetShortPathName'+_X;
procedure GetStartupInfoA; external kernel32 name 'GetStartupInfoA';
procedure GetStartupInfoW; external kernel32 name 'GetStartupInfoW';
procedure GetStartupInfo; external kernel32 name 'GetStartupInfo'+_X;
function GetStdHandle; external kernel32 name 'GetStdHandle';
function GetStringTypeExA; external kernel32 name 'GetStringTypeExA';
function GetStringTypeExW; external kernel32 name 'GetStringTypeExW';
function GetStringTypeEx; external kernel32 name 'GetStringTypeEx'+_X;
function GetStringTypeA; external kernel32 name 'GetStringTypeA';
function GetStringTypeW; external kernel32 name 'GetStringTypeW';
function GetSystemDefaultLCID; external kernel32 name 'GetSystemDefaultLCID';
function GetSystemDefaultLangID; external kernel32 name 'GetSystemDefaultLangID';
function GetSystemDirectoryA; external kernel32 name 'GetSystemDirectoryA';
function GetSystemDirectoryW; external kernel32 name 'GetSystemDirectoryW';
function GetSystemDirectory; external kernel32 name 'GetSystemDirectory'+_X;
procedure GetSystemInfo; external kernel32 name 'GetSystemInfo';
function GetSystemPowerStatus; external kernel32 name 'GetSystemPowerStatus';
procedure GetSystemTime; external kernel32 name 'GetSystemTime';
procedure GetSystemTimeAsFileTime; external kernel32 name 'GetSystemTimeAsFileTime';
function GetSystemTimeAdjustment; external kernel32 name 'GetSystemTimeAdjustment';
function GetTapeParameters; external kernel32 name 'GetTapeParameters';
function GetTapePosition; external kernel32 name 'GetTapePosition';
function GetTapeStatus; external kernel32 name 'GetTapeStatus';
function GetTempFileNameA; external kernel32 name 'GetTempFileNameA';
function GetTempFileNameW; external kernel32 name 'GetTempFileNameW';
function GetTempFileName; external kernel32 name 'GetTempFileName'+_X;
function GetTempPathA; external kernel32 name 'GetTempPathA';
function GetTempPathW; external kernel32 name 'GetTempPathW';
function GetTempPath; external kernel32 name 'GetTempPath'+_X;
function GetThreadContext; external kernel32 name 'GetThreadContext';
function GetThreadLocale; external kernel32 name 'GetThreadLocale';
function GetThreadPriority; external kernel32 name 'GetThreadPriority';
function GetThreadPriorityBoost; external kernel32 name 'GetThreadPriorityBoost';
function GetThreadSelectorEntry; external kernel32 name 'GetThreadSelectorEntry';
function GetThreadTimes; external kernel32 name 'GetThreadTimes';
function GetTickCount; external kernel32 name 'GetTickCount';
function GetTimeFormatA; external kernel32 name 'GetTimeFormatA';
function GetTimeFormatW; external kernel32 name 'GetTimeFormatW';
function GetTimeFormat; external kernel32 name 'GetTimeFormat'+_X;
function GetTimeZoneInformation; external kernel32 name 'GetTimeZoneInformation';
function GetUserDefaultLCID; external kernel32 name 'GetUserDefaultLCID';
function GetUserDefaultLangID; external kernel32 name 'GetUserDefaultLangID';
function GetVersion; external kernel32 name 'GetVersion';
function GetVersionExA; external kernel32 name 'GetVersionExA';
function GetVersionExW; external kernel32 name 'GetVersionExW';
function GetVersionEx; external kernel32 name 'GetVersionEx'+_X;
function GetVolumeInformationA; external kernel32 name 'GetVolumeInformationA';
function GetVolumeInformationW; external kernel32 name 'GetVolumeInformationW';
function GetVolumeInformation; external kernel32 name 'GetVolumeInformation'+_X;
function GetWindowsDirectoryA; external kernel32 name 'GetWindowsDirectoryA';
function GetWindowsDirectoryW; external kernel32 name 'GetWindowsDirectoryW';
function GetWindowsDirectory; external kernel32 name 'GetWindowsDirectory'+_X;
function GlobalAddAtomA; external kernel32 name 'GlobalAddAtomA';
function GlobalAddAtomW; external kernel32 name 'GlobalAddAtomW';
function GlobalAddAtom; external kernel32 name 'GlobalAddAtom'+_X;
function GlobalAlloc; external kernel32 name 'GlobalAlloc';
function GlobalCompact; external kernel32 name 'GlobalCompact';
function GlobalDeleteAtom; external kernel32 name 'GlobalDeleteAtom';
function GlobalFindAtomA; external kernel32 name 'GlobalFindAtomA';
function GlobalFindAtomW; external kernel32 name 'GlobalFindAtomW';
function GlobalFindAtom; external kernel32 name 'GlobalFindAtom'+_X;
procedure GlobalFix; external kernel32 name 'GlobalFix';
function GlobalFlags; external kernel32 name 'GlobalFlags';
function GlobalFree; external kernel32 name 'GlobalFree';
function GlobalGetAtomNameA; external kernel32 name 'GlobalGetAtomNameA';
function GlobalGetAtomNameW; external kernel32 name 'GlobalGetAtomNameW';
function GlobalGetAtomName; external kernel32 name 'GlobalGetAtomName'+_X;
function GlobalLock; external kernel32 name 'GlobalLock';
function GlobalHandle; external kernel32 name 'GlobalHandle';
procedure GlobalMemoryStatus; external kernel32 name 'GlobalMemoryStatus';
function GlobalReAlloc; external kernel32 name 'GlobalReAlloc';
function GlobalSize; external kernel32 name 'GlobalSize';
function GlobalUnWire; external kernel32 name 'GlobalUnWire';
procedure GlobalUnfix; external kernel32 name 'GlobalUnfix';
function GlobalUnlock; external kernel32 name 'GlobalUnlock';
function GlobalWire; external kernel32 name 'GlobalWire';
function HeapAlloc; external kernel32 name 'HeapAlloc';
function HeapCompact; external kernel32 name 'HeapCompact';
function HeapCreate; external kernel32 name 'HeapCreate';
function HeapDestroy; external kernel32 name 'HeapDestroy';
function HeapFree; external kernel32 name 'HeapFree';
function HeapLock; external kernel32 name 'HeapLock';
function HeapReAlloc; external kernel32 name 'HeapReAlloc';
function HeapSize; external kernel32 name 'HeapSize';
function HeapUnlock; external kernel32 name 'HeapUnlock';
function HeapValidate; external kernel32 name 'HeapValidate';
function HeapWalk; external kernel32 name 'HeapWalk';
function InitAtomTable; external kernel32 name 'InitAtomTable';
procedure InitializeCriticalSection; external kernel32 name 'InitializeCriticalSection';
function InitializeCriticalSectionAndSpinCount; external kernel32 name 'InitializeCriticalSectionAndSpinCount';
function IsBadCodePtr; external kernel32 name 'IsBadCodePtr';
function IsBadHugeReadPtr; external kernel32 name 'IsBadHugeReadPtr';
function IsBadHugeWritePtr; external kernel32 name 'IsBadHugeWritePtr';
function IsBadReadPtr; external kernel32 name 'IsBadReadPtr';
function IsBadStringPtrA; external kernel32 name 'IsBadStringPtrA';
function IsBadStringPtrW; external kernel32 name 'IsBadStringPtrW';
function IsBadStringPtr; external kernel32 name 'IsBadStringPtr'+_X;
function IsBadWritePtr; external kernel32 name 'IsBadWritePtr';
function IsDBCSLeadByte; external kernel32 name 'IsDBCSLeadByte';
function IsDBCSLeadByteEx; external kernel32 name 'IsDBCSLeadByteEx';
function IsProcessorFeaturePresent; external kernel32 name 'IsProcessorFeaturePresent';
function IsValidCodePage; external kernel32 name 'IsValidCodePage';
function IsValidLocale; external kernel32 name 'IsValidLocale';
function LCMapStringA; external kernel32 name 'LCMapStringA';
function LCMapStringW; external kernel32 name 'LCMapStringW';
function LCMapString; external kernel32 name 'LCMapString'+_X;
procedure LeaveCriticalSection; external kernel32 name 'LeaveCriticalSection';
function LoadLibraryA; external kernel32 name 'LoadLibraryA';
function LoadLibraryW; external kernel32 name 'LoadLibraryW';
function LoadLibrary; external kernel32 name 'LoadLibrary'+_X;
function LoadLibraryExA; external kernel32 name 'LoadLibraryExA';
function LoadLibraryExW; external kernel32 name 'LoadLibraryExW';
function LoadLibraryEx; external kernel32 name 'LoadLibraryEx'+_X;
function LoadModule; external kernel32 name 'LoadModule';
function LoadResource; external kernel32 name 'LoadResource';
function LocalAlloc; external kernel32 name 'LocalAlloc';
function LocalCompact; external kernel32 name 'LocalCompact';
function LocalFileTimeToFileTime; external kernel32 name 'LocalFileTimeToFileTime';
function LocalFlags; external kernel32 name 'LocalFlags';
function LocalFree; external kernel32 name 'LocalFree';
function LocalLock; external kernel32 name 'LocalLock';
function LocalReAlloc; external kernel32 name 'LocalReAlloc';
function LocalShrink; external kernel32 name 'LocalShrink';
function LocalSize; external kernel32 name 'LocalSize';
function LocalUnlock; external kernel32 name 'LocalUnlock';
function LockFile; external kernel32 name 'LockFile';
function LockFileEx; external kernel32 name 'LockFileEx';
function LockResource; external kernel32 name 'LockResource';
function MapViewOfFile; external kernel32 name 'MapViewOfFile';
function MapViewOfFileEx; external kernel32 name 'MapViewOfFileEx';
function MoveFileA; external kernel32 name 'MoveFileA';
function MoveFileW; external kernel32 name 'MoveFileW';
function MoveFile; external kernel32 name 'MoveFile'+_X;
function MoveFileExA; external kernel32 name 'MoveFileExA';
function MoveFileExW; external kernel32 name 'MoveFileExW';
function MoveFileEx; external kernel32 name 'MoveFileEx'+_X;
function MoveFileWithProgressA; external kernel32 name 'MoveFileWithProgressA';
function MoveFileWithProgressW; external kernel32 name 'MoveFileWithProgressW';
function MoveFileWithProgress; external kernel32 name 'MoveFileWithProgress'+_X;
function MulDiv; external kernel32 name 'MulDiv';
function MultiByteToWideChar; external kernel32 name 'MultiByteToWideChar';
function OpenEventA; external kernel32 name 'OpenEventA';
function OpenEventW; external kernel32 name 'OpenEventW';
function OpenEvent; external kernel32 name 'OpenEvent'+_X;
function OpenFile; external kernel32 name 'OpenFile';
function OpenFileMappingA; external kernel32 name 'OpenFileMappingA';
function OpenFileMappingW; external kernel32 name 'OpenFileMappingW';
function OpenFileMapping; external kernel32 name 'OpenFileMapping'+_X;
function OpenMutexA; external kernel32 name 'OpenMutexA';
function OpenMutexW; external kernel32 name 'OpenMutexW';
function OpenMutex; external kernel32 name 'OpenMutex'+_X;
function OpenProcess; external kernel32 name 'OpenProcess';
function OpenRawA; external kernel32 name 'OpenRawA';
function OpenRawW; external kernel32 name 'OpenRawW';
function OpenRaw; external kernel32 name 'OpenRaw';
function OpenSemaphoreA; external kernel32 name 'OpenSemaphoreA';
function OpenWaitableTimerA; external kernel32 name 'OpenWaitableTimerA';
function OpenSemaphoreW; external kernel32 name 'OpenSemaphoreW';
function OpenWaitableTimerW; external kernel32 name 'OpenWaitableTimerW';
function OpenSemaphore; external kernel32 name 'OpenSemaphore'+_X;
function OpenWaitableTimer; external kernel32 name 'OpenWaitableTimer'+_X;
procedure OutputDebugStringA; external kernel32 name 'OutputDebugStringA';
procedure OutputDebugStringW; external kernel32 name 'OutputDebugStringW';
procedure OutputDebugString; external kernel32 name 'OutputDebugString'+_X;
function PeekConsoleInputA; external kernel32 name 'PeekConsoleInputA';
function PeekConsoleInputW; external kernel32 name 'PeekConsoleInputW';
function PeekConsoleInput; external kernel32 name 'PeekConsoleInput'+_X;
function PeekNamedPipe; external kernel32 name 'PeekNamedPipe';
function PostQueuedCompletionStatus; external kernel32 name 'PostQueuedCompletionStatus';
function PrepareTape; external kernel32 name 'PrepareTape';
function PulseEvent; external kernel32 name 'PulseEvent';
function PurgeComm; external kernel32 name 'PurgeComm';
function QueryDosDeviceA; external kernel32 name 'QueryDosDeviceA';
function QueryDosDeviceW; external kernel32 name 'QueryDosDeviceW';
function QueryDosDevice; external kernel32 name 'QueryDosDevice'+_X;
function QueryPerformanceCounter; external kernel32 name 'QueryPerformanceCounter';
function QueryPerformanceFrequency; external kernel32 name 'QueryPerformanceFrequency';
function QueryRecoveryAgentsA; external kernel32 name 'QueryRecoveryAgentsA';
function QueryRecoveryAgentsW; external kernel32 name 'QueryRecoveryAgentsW';
function QueryRecoveryAgents; external kernel32 name 'QueryRecoveryAgents'+_X;
function QueueUserAPC; external kernel32 name 'QueueUserAPC';
procedure RaiseException; external kernel32 name 'RaiseException';
function ReadConsoleA; external kernel32 name 'ReadConsoleA';
function ReadConsoleW; external kernel32 name 'ReadConsoleW';
function ReadConsole; external kernel32 name 'ReadConsole'+_X;
function ReadConsoleInputA; external kernel32 name 'ReadConsoleInputA';
function ReadConsoleInputW; external kernel32 name 'ReadConsoleInputW';
function ReadConsoleInput; external kernel32 name 'ReadConsoleInput'+_X;
function ReadConsoleOutputA; external kernel32 name 'ReadConsoleOutputA';
function ReadConsoleOutputW; external kernel32 name 'ReadConsoleOutputW';
function ReadConsoleOutput; external kernel32 name 'ReadConsoleOutput'+_X;
function ReadConsoleOutputAttribute; external kernel32 name 'ReadConsoleOutputAttribute';
function ReadConsoleOutputCharacterA; external kernel32 name 'ReadConsoleOutputCharacterA';
function ReadConsoleOutputCharacterW; external kernel32 name 'ReadConsoleOutputCharacterW';
function ReadConsoleOutputCharacter; external kernel32 name 'ReadConsoleOutputCharacter'+_X;
function ReadDirectoryChanges; external kernel32 name 'ReadDirectoryChangesW';
function ReadDirectoryChangesW; external kernel32 name 'ReadDirectoryChangesW';
function ReadFile; external kernel32 name 'ReadFile';
function ReadFileEx; external kernel32 name 'ReadFileEx';
function ReadProcessMemory; external kernel32 name 'ReadProcessMemory';
function ReadRaw; external kernel32 name 'ReadRaw';
function ReleaseMutex; external kernel32 name 'ReleaseMutex';
function ReleaseSemaphore; external kernel32 name 'ReleaseSemaphore';
function RemoveDirectoryA; external kernel32 name 'RemoveDirectoryA';
function RemoveDirectoryW; external kernel32 name 'RemoveDirectoryW';
function RemoveDirectory; external kernel32 name 'RemoveDirectory'+_X;
function ResetEvent; external kernel32 name 'ResetEvent';
function ResumeThread; external kernel32 name 'ResumeThread';
function ScrollConsoleScreenBufferA; external kernel32 name 'ScrollConsoleScreenBufferA';
function ScrollConsoleScreenBufferW; external kernel32 name 'ScrollConsoleScreenBufferW';
function ScrollConsoleScreenBuffer; external kernel32 name 'ScrollConsoleScreenBuffer'+_X;
function SearchPathA; external kernel32 name 'SearchPathA';
function SearchPathW; external kernel32 name 'SearchPathW';
function SearchPath; external kernel32 name 'SearchPath'+_X;
function SetCommBreak; external kernel32 name 'SetCommBreak';
function SetCommConfig; external kernel32 name 'SetCommConfig';
function SetCommMask; external kernel32 name 'SetCommMask';
function SetCommState; external kernel32 name 'SetCommState';
function SetCommTimeouts; external kernel32 name 'SetCommTimeouts';
function SetComputerNameA; external kernel32 name 'SetComputerNameA';
function SetComputerNameW; external kernel32 name 'SetComputerNameW';
function SetComputerName; external kernel32 name 'SetComputerName'+_X;
function SetConsoleActiveScreenBuffer; external kernel32 name 'SetConsoleActiveScreenBuffer';
function SetConsoleCP; external kernel32 name 'SetConsoleCP';
function SetConsoleCtrlHandler; external kernel32 name 'SetConsoleCtrlHandler';
function SetConsoleCursorInfo; external kernel32 name 'SetConsoleCursorInfo';
function SetConsoleCursorPosition; external kernel32 name 'SetConsoleCursorPosition';
function SetConsoleMode; external kernel32 name 'SetConsoleMode';
function SetConsoleOutputCP; external kernel32 name 'SetConsoleOutputCP';
function SetConsoleScreenBufferSize; external kernel32 name 'SetConsoleScreenBufferSize';
function SetConsoleTextAttribute; external kernel32 name 'SetConsoleTextAttribute';
function SetConsoleTitleA; external kernel32 name 'SetConsoleTitleA';
function SetConsoleTitleW; external kernel32 name 'SetConsoleTitleW';
function SetConsoleTitle; external kernel32 name 'SetConsoleTitle'+_X;
function SetConsoleWindowInfo; external kernel32 name 'SetConsoleWindowInfo';
function SetCriticalSectionSpinCount; external kernel32 name 'SetCriticalSectionSpinCount';
function SetCurrentDirectoryA; external kernel32 name 'SetCurrentDirectoryA';
function SetCurrentDirectoryW; external kernel32 name 'SetCurrentDirectoryW';
function SetCurrentDirectory; external kernel32 name 'SetCurrentDirectory'+_X;
function SetDefaultCommConfigA; external kernel32 name 'SetDefaultCommConfigA';
function SetDefaultCommConfigW; external kernel32 name 'SetDefaultCommConfigW';
function SetDefaultCommConfig; external kernel32 name 'SetDefaultCommConfig'+_X;
function SetEndOfFile; external kernel32 name 'SetEndOfFile';
function SetEnvironmentVariableA; external kernel32 name 'SetEnvironmentVariableA';
function SetEnvironmentVariableW; external kernel32 name 'SetEnvironmentVariableW';
function SetEnvironmentVariable; external kernel32 name 'SetEnvironmentVariable'+_X;
function SetErrorMode; external kernel32 name 'SetErrorMode';
function SetEvent; external kernel32 name 'SetEvent';
procedure SetFileApisToANSI; external kernel32 name 'SetFileApisToANSI';
procedure SetFileApisToOEM; external kernel32 name 'SetFileApisToOEM';
function SetFileAttributesA; external kernel32 name 'SetFileAttributesA';
function SetFileAttributesW; external kernel32 name 'SetFileAttributesW';
function SetFileAttributes; external kernel32 name 'SetFileAttributes'+_X;
function SetFilePointer; external kernel32 name 'SetFilePointer';
function SetFileTime; external kernel32 name 'SetFileTime';
function SetHandleCount; external kernel32 name 'SetHandleCount';
function SetHandleInformation; external kernel32 name 'SetHandleInformation';
procedure SetLastError; external kernel32 name 'SetLastError';
function SetLocalTime; external kernel32 name 'SetLocalTime';
function SetLocaleInfoA; external kernel32 name 'SetLocaleInfoA';
function SetLocaleInfoW; external kernel32 name 'SetLocaleInfoW';
function SetLocaleInfo; external kernel32 name 'SetLocaleInfo'+_X;
function SetMailslotInfo; external kernel32 name 'SetMailslotInfo';
function SetNamedPipeHandleState; external kernel32 name 'SetNamedPipeHandleState';
function SetPriorityClass; external kernel32 name 'SetPriorityClass';
function SetProcessAffinityMask; external kernel32 name 'SetProcessAffinityMask';
function SetProcessPriorityBoost; external kernel32 name 'SetProcessPriorityBoost';
function SetProcessShutdownParameters; external kernel32 name 'SetProcessShutdownParameters';
function SetProcessWorkingSetSize; external kernel32 name 'SetProcessWorkingSetSize';
function SetStdHandle; external kernel32 name 'SetStdHandle';
function SetSystemPowerState; external kernel32 name 'SetSystemPowerState';
function SetSystemTime; external kernel32 name 'SetSystemTime';
function SetSystemTimeAdjustment; external kernel32 name 'SetSystemTimeAdjustment';
function SetTapeParameters; external kernel32 name 'SetTapeParameters';
function SetTapePosition; external kernel32 name 'SetTapePosition';
function SetThreadAffinityMask; external kernel32 name 'SetThreadAffinityMask';
function SetThreadContext; external kernel32 name 'SetThreadContext';
function SetThreadIdealProcessor; external kernel32 name 'SetThreadIdealProcessor';
function SetThreadLocale; external kernel32 name 'SetThreadLocale';
function SetThreadPriority; external kernel32 name 'SetThreadPriority';
function SetThreadPriorityBoost; external kernel32 name 'SetThreadPriorityBoost';
function SetTimeZoneInformation; external kernel32 name 'SetTimeZoneInformation';
function SetUnhandledExceptionFilter; external kernel32 name 'SetUnhandledExceptionFilter';
function SetVolumeLabelA; external kernel32 name 'SetVolumeLabelA';
function SetVolumeLabelW; external kernel32 name 'SetVolumeLabelW';
function SetVolumeLabel; external kernel32 name 'SetVolumeLabel'+_X;
function SetWaitableTimer; external kernel32 name 'SetWaitableTimer';
function SetupComm; external kernel32 name 'SetupComm';
function SignalObjectAndWait; external kernel32 name 'SignalObjectAndWait';
function SizeofResource; external kernel32 name 'SizeofResource';
procedure Sleep; external kernel32 name 'Sleep';
function SleepEx; external kernel32 name 'SleepEx';
function SuspendThread; external kernel32 name 'SuspendThread';
function SwitchToFiber; external kernel32 name 'SwitchToFiber';
function SwitchToThread; external kernel32 name 'SwitchToThread';
function SystemTimeToFileTime; external kernel32 name 'SystemTimeToFileTime';
function SystemTimeToTzSpecificLocalTime; external kernel32 name 'SystemTimeToTzSpecificLocalTime';
function TerminateProcess; external kernel32 name 'TerminateProcess';
function TerminateThread; external kernel32 name 'TerminateThread';
function TlsAlloc; external kernel32 name 'TlsAlloc';
function TlsFree; external kernel32 name 'TlsFree';
function TlsGetValue; external kernel32 name 'TlsGetValue';
function TlsSetValue; external kernel32 name 'TlsSetValue';
function TransactNamedPipe; external kernel32 name 'TransactNamedPipe';
function TransmitCommChar; external kernel32 name 'TransmitCommChar';
function TryEnterCriticalSection; external kernel32 name 'TryEnterCriticalSection';
function UnhandledExceptionFilter; external kernel32 name 'UnhandledExceptionFilter';
function UnlockFile; external kernel32 name 'UnlockFile';
function UnlockFileEx; external kernel32 name 'UnlockFileEx';
function UnmapViewOfFile; external kernel32 name 'UnmapViewOfFile';
function UpdateResourceA; external kernel32 name 'UpdateResourceA';
function UpdateResourceW; external kernel32 name 'UpdateResourceW';
function UpdateResource; external kernel32 name 'UpdateResource'+_X;
function VerLanguageNameA; external kernel32 name 'VerLanguageNameA';
function VerLanguageNameW; external kernel32 name 'VerLanguageNameW';
function VerLanguageName; external kernel32 name 'VerLanguageName'+_X;
function VirtualAlloc; external kernel32 name 'VirtualAlloc';
function VirtualAllocEx; external kernel32 name 'VirtualAllocEx';
function VirtualFree; external kernel32 name 'VirtualFree';
function VirtualFreeEx; external kernel32 name 'VirtualFreeEx';
function VirtualLock; external kernel32 name 'VirtualLock';
function VirtualProtect(lpAddress: Pointer; dwSize, flNewProtect: DWORD; lpflOldProtect: Pointer): BOOL; external kernel32 name 'VirtualProtect';
{$ifdef bDelphi5}
function VirtualProtect(lpAddress: Pointer; dwSize, flNewProtect: DWORD; var OldProtect: DWORD): BOOL; external kernel32 name 'VirtualProtect';
{$endif bDelphi5}
function VirtualProtectEx(hProcess: THandle; lpAddress: Pointer; dwSize, flNewProtect: DWORD; lpflOldProtect: Pointer): BOOL; external kernel32 name 'VirtualProtectEx';
{$ifdef bDelphi5}
function VirtualProtectEx(hProcess: THandle; lpAddress: Pointer; dwSize, flNewProtect: DWORD; var OldProtect: DWORD): BOOL; external kernel32 name 'VirtualProtectEx';
{$endif bDelphi5}  
function VirtualQuery; external kernel32 name 'VirtualQuery';
function VirtualQueryEx; external kernel32 name 'VirtualQueryEx';
function VirtualUnlock; external kernel32 name 'VirtualUnlock';
function WaitCommEvent; external kernel32 name 'WaitCommEvent';
function WaitForDebugEvent; external kernel32 name 'WaitForDebugEvent';
function WaitForMultipleObjects; external kernel32 name 'WaitForMultipleObjects';
function WaitForMultipleObjectsEx; external kernel32 name 'WaitForMultipleObjectsEx';
function WaitForSingleObject; external kernel32 name 'WaitForSingleObject';
function WaitForSingleObjectEx; external kernel32 name 'WaitForSingleObjectEx';
function WaitNamedPipeA; external kernel32 name 'WaitNamedPipeA';
function WaitNamedPipeW; external kernel32 name 'WaitNamedPipeW';
function WaitNamedPipe; external kernel32 name 'WaitNamedPipe'+_X;
function WideCharToMultiByte; external kernel32 name 'WideCharToMultiByte';
function WinExec; external kernel32 name 'WinExec';
function WriteConsoleA; external kernel32 name 'WriteConsoleA';
function WriteConsoleW; external kernel32 name 'WriteConsoleW';
function WriteConsole; external kernel32 name 'WriteConsole'+_X;
function WriteConsoleInputA; external kernel32 name 'WriteConsoleInputA';
function WriteConsoleInputW; external kernel32 name 'WriteConsoleInputW';
function WriteConsoleInput; external kernel32 name 'WriteConsoleInput'+_X;
function WriteConsoleOutputA; external kernel32 name 'WriteConsoleOutputA';
function WriteConsoleOutputW; external kernel32 name 'WriteConsoleOutputW';
function WriteConsoleOutput; external kernel32 name 'WriteConsoleOutput'+_X;
function WriteConsoleOutputAttribute; external kernel32 name 'WriteConsoleOutputAttribute';
function WriteConsoleOutputCharacterA; external kernel32 name 'WriteConsoleOutputCharacterA';
function WriteConsoleOutputCharacterW; external kernel32 name 'WriteConsoleOutputCharacterW';
function WriteConsoleOutputCharacter; external kernel32 name 'WriteConsoleOutputCharacter'+_X;
function WriteFile; external kernel32 name 'WriteFile';
function WriteFileEx; external kernel32 name 'WriteFileEx';
function WritePrivateProfileSectionA; external kernel32 name 'WritePrivateProfileSectionA';
function WritePrivateProfileSectionW; external kernel32 name 'WritePrivateProfileSectionW';
function WritePrivateProfileSection; external kernel32 name 'WritePrivateProfileSection'+_X;
function WritePrivateProfileStringA; external kernel32 name 'WritePrivateProfileStringA';
function WritePrivateProfileStringW; external kernel32 name 'WritePrivateProfileStringW';
function WritePrivateProfileString; external kernel32 name 'WritePrivateProfileString'+_X;
function WriteProcessMemory; external kernel32 name 'WriteProcessMemory';
function WriteProfileSectionA; external kernel32 name 'WriteProfileSectionA';
function WriteProfileSectionW; external kernel32 name 'WriteProfileSectionW';
function WriteProfileSection; external kernel32 name 'WriteProfileSection'+_X;
function WriteProfileStringA; external kernel32 name 'WriteProfileStringA';
function WriteProfileStringW; external kernel32 name 'WriteProfileStringW';
function WriteProfileString; external kernel32 name 'WriteProfileString'+_X;
function WriteRaw; external kernel32 name 'WriteRaw';
function WriteTapemark; external kernel32 name 'WriteTapemark';
function _hread; external kernel32 name '_hread';
function _hwrite; external kernel32 name '_hwrite';
function _lclose; external kernel32 name '_lclose';
function _lcreat; external kernel32 name '_lcreat';
function _llseek; external kernel32 name '_llseek';
function _lopen; external kernel32 name '_lopen';
function _lread; external kernel32 name '_lread';
function _lwrite; external kernel32 name '_lwrite';
function lstrcatA; external kernel32 name 'lstrcatA';
function lstrcatW; external kernel32 name 'lstrcatW';
function lstrcat; external kernel32 name 'lstrcat'+_X;
function lstrcmpA; external kernel32 name 'lstrcmpA';
function lstrcmpW; external kernel32 name 'lstrcmpW';
function lstrcmp; external kernel32 name 'lstrcmp'+_X;
function lstrcmpiA; external kernel32 name 'lstrcmpiA';
function lstrcmpiW; external kernel32 name 'lstrcmpiW';
function lstrcmpi; external kernel32 name 'lstrcmpi'+_X;
function lstrcpyA; external kernel32 name 'lstrcpyA';
function lstrcpyW; external kernel32 name 'lstrcpyW';
function lstrcpy; external kernel32 name 'lstrcpy'+_X;
function lstrcpynA; external kernel32 name 'lstrcpynA';
function lstrcpynW; external kernel32 name 'lstrcpynW';
function lstrcpyn; external kernel32 name 'lstrcpyn'+_X;
function lstrlenA; external kernel32 name 'lstrlenA';
function lstrlenW; external kernel32 name 'lstrlenW';
function lstrlen; external kernel32 name 'lstrlen'+_X;


{ Externals from mpr.dll }

function MultinetGetConnectionPerformanceA; external mpr name 'MultinetGetConnectionPerformanceA';
function MultinetGetConnectionPerformanceW; external mpr name 'MultinetGetConnectionPerformanceW';
function MultinetGetConnectionPerformance; external mpr name 'MultinetGetConnectionPerformance'+_X;
function WNetAddConnection2A; external mpr name 'WNetAddConnection2A';
function WNetAddConnection2W; external mpr name 'WNetAddConnection2W';
function WNetAddConnection2; external mpr name 'WNetAddConnection2'+_X;
function WNetAddConnection3A; external mpr name 'WNetAddConnection3A';
function WNetAddConnection3W; external mpr name 'WNetAddConnection3W';
function WNetAddConnection3; external mpr name 'WNetAddConnection3'+_X;
function WNetAddConnectionA; external mpr name 'WNetAddConnectionA';
function WNetAddConnectionW; external mpr name 'WNetAddConnectionW';
function WNetAddConnection; external mpr name 'WNetAddConnection'+_X;
function WNetCancelConnection2A; external mpr name 'WNetCancelConnection2A';
function WNetCancelConnection2W; external mpr name 'WNetCancelConnection2W';
function WNetCancelConnection2; external mpr name 'WNetCancelConnection2'+_X;
function WNetCancelConnectionA; external mpr name 'WNetCancelConnectionA';
function WNetCancelConnectionW; external mpr name 'WNetCancelConnectionW';
function WNetCancelConnection; external mpr name 'WNetCancelConnection'+_X;
function WNetCloseEnum; external mpr name 'WNetCloseEnum';
function WNetConnectionDialog1A; external mpr name 'WNetConnectionDialog1A';
function WNetConnectionDialog1W; external mpr name 'WNetConnectionDialog1W';
function WNetConnectionDialog1; external mpr name 'WNetConnectionDialog1'+_X;
function WNetConnectionDialog; external mpr name 'WNetConnectionDialog';
function WNetDisconnectDialog1A; external mpr name 'WNetDisconnectDialog1A';
function WNetDisconnectDialog1W; external mpr name 'WNetDisconnectDialog1W';
function WNetDisconnectDialog1; external mpr name 'WNetDisconnectDialog1'+_X;
function WNetDisconnectDialog; external mpr name 'WNetDisconnectDialog';
function WNetEnumResourceA; external mpr name 'WNetEnumResourceA';
function WNetEnumResourceW; external mpr name 'WNetEnumResourceW';
function WNetEnumResource; external mpr name 'WNetEnumResource'+_X;
function WNetGetConnectionA; external mpr name 'WNetGetConnectionA';
function WNetGetConnectionW; external mpr name 'WNetGetConnectionW';
function WNetGetConnection; external mpr name 'WNetGetConnection'+_X;
function WNetGetLastErrorA; external mpr name 'WNetGetLastErrorA';
function WNetGetLastErrorW; external mpr name 'WNetGetLastErrorW';
function WNetGetLastError; external mpr name 'WNetGetLastError'+_X;
function WNetGetNetworkInformationA; external mpr name 'WNetGetNetworkInformationA';
function WNetGetNetworkInformationW; external mpr name 'WNetGetNetworkInformationW';
function WNetGetNetworkInformation; external mpr name 'WNetGetNetworkInformation'+_X;
function WNetGetProviderNameA; external mpr name 'WNetGetProviderNameA';
function WNetGetProviderNameW; external mpr name 'WNetGetProviderNameW';
function WNetGetProviderName; external mpr name 'WNetGetProviderName'+_X;
function WNetGetResourceParentA; external mpr name 'WNetGetResourceParentA';
function WNetGetResourceParentW; external mpr name 'WNetGetResourceParentW';
function WNetGetResourceParent; external mpr name 'WNetGetResourceParent'+_X;
function WNetGetUniversalNameA; external mpr name 'WNetGetUniversalNameA';
function WNetGetUniversalNameW; external mpr name 'WNetGetUniversalNameW';
function WNetGetUniversalName; external mpr name 'WNetGetUniversalName'+_X;
function WNetGetUserA; external mpr name 'WNetGetUserA';
function WNetGetUserW; external mpr name 'WNetGetUserW';
function WNetGetUser; external mpr name 'WNetGetUser'+_X;
function WNetOpenEnumA; external mpr name 'WNetOpenEnumA';
function WNetOpenEnumW; external mpr name 'WNetOpenEnumW';
function WNetOpenEnum; external mpr name 'WNetOpenEnum'+_X;
function WNetSetConnectionA; external mpr name 'WNetSetConnectionA';
function WNetSetConnectionW; external mpr name 'WNetSetConnectionW';
function WNetSetConnection; external mpr name 'WNetSetConnection'+_X;
function WNetUseConnectionA; external mpr name 'WNetUseConnectionA';
function WNetUseConnectionW; external mpr name 'WNetUseConnectionW';
function WNetUseConnection; external mpr name 'WNetUseConnection'+_X;


{ Externals from version.dll }

function GetFileVersionInfoA; external version name 'GetFileVersionInfoA';
function GetFileVersionInfoW; external version name 'GetFileVersionInfoW';
function GetFileVersionInfo; external version name 'GetFileVersionInfo'+_X;
function GetFileVersionInfoSizeA; external version name 'GetFileVersionInfoSizeA';
function GetFileVersionInfoSizeW; external version name 'GetFileVersionInfoSizeW';
function GetFileVersionInfoSize; external version name 'GetFileVersionInfoSize'+_X;
function VerFindFileA; external version name 'VerFindFileA';
function VerFindFileW; external version name 'VerFindFileW';
function VerFindFile; external version name 'VerFindFile'+_X;
function VerInstallFileA; external version name 'VerInstallFileA';
function VerInstallFileW; external version name 'VerInstallFileW';
function VerInstallFile; external version name 'VerInstallFile'+_X;
function VerQueryValueA; external version name 'VerQueryValueA';
function VerQueryValueW; external version name 'VerQueryValueW';
function VerQueryValue; external version name 'VerQueryValue'+_X;
function GetPrivateProfileStructA; external kernel32 name 'GetPrivateProfileStructA';
function GetPrivateProfileStructW; external kernel32 name 'GetPrivateProfileStructW';
function GetPrivateProfileStruct; external kernel32 name 'GetPrivateProfileStruct'+_X;
function WritePrivateProfileStructA; external kernel32 name 'WritePrivateProfileStructA';
function WritePrivateProfileStructW; external kernel32 name 'WritePrivateProfileStructW';
function WritePrivateProfileStruct; external kernel32 name 'WritePrivateProfileStruct'+_X;

{ Externals from gdi32.dll }

function AbortDoc; external gdi32 name 'AbortDoc';
function AbortPath; external gdi32 name 'AbortPath';
function AddFontMemResourceEx; external gdi32 name 'AddFontMemResourceEx';
function AddFontResourceA; external gdi32 name 'AddFontResourceA';
function AddFontResourceW; external gdi32 name 'AddFontResourceW';
function AddFontResource; external gdi32 name 'AddFontResource'+_X;
function AddFontResourceExA; external gdi32 name 'AddFontResourceExA';
function AddFontResourceExW; external gdi32 name 'AddFontResourceExW';
function AddFontResourceEx; external gdi32 name 'AddFontResourceEx'+_X;
function AlphaBlend; external msimg32 name 'AlphaBlend';
function AlphaDIBBlend; external msimg32 name 'AlphaDIBBlend';
function AngleArc; external gdi32 name 'AngleArc';
function AnimatePalette; external gdi32 name 'AnimatePalette';
function Arc; external gdi32 name 'Arc';
function ArcTo; external gdi32 name 'ArcTo';
function BeginPath; external gdi32 name 'BeginPath';
function BitBlt; external gdi32 name 'BitBlt';
function CancelDC; external gdi32 name 'CancelDC';
function CheckColorsInGamut; external gdi32 name 'CheckColorsInGamut';
function ChoosePixelFormat; external gdi32 name 'ChoosePixelFormat';
function Chord; external gdi32 name 'Chord';
function CloseEnhMetaFile; external gdi32 name 'CloseEnhMetaFile';
function CloseFigure; external gdi32 name 'CloseFigure';
function CloseMetaFile; external gdi32 name 'CloseMetaFile';
function ColorCorrectPalette; external gdi32 name 'ColorCorrectPalette';
function ColorMatchToTarget; external gdi32 name 'ColorMatchToTarget';
function CombineRgn; external gdi32 name 'CombineRgn';
function CombineTransform; external gdi32 name 'CombineTransform';
function CopyEnhMetaFileA; external gdi32 name 'CopyEnhMetaFileA';
function CopyEnhMetaFileW; external gdi32 name 'CopyEnhMetaFileW';
function CopyEnhMetaFile; external gdi32 name 'CopyEnhMetaFile'+_X;
function CopyMetaFileA; external gdi32 name 'CopyMetaFileA';
function CopyMetaFileW; external gdi32 name 'CopyMetaFileW';
function CopyMetaFile; external gdi32 name 'CopyMetaFile'+_X;
function CreateBitmap; external gdi32 name 'CreateBitmap';
function CreateBitmapIndirect; external gdi32 name 'CreateBitmapIndirect';
function CreateBrushIndirect; external gdi32 name 'CreateBrushIndirect';
function CreateColorSpaceA; external gdi32 name 'CreateColorSpaceA';
function CreateColorSpaceW; external gdi32 name 'CreateColorSpaceW';
function CreateColorSpace; external gdi32 name 'CreateColorSpace'+_X;
function CreateCompatibleBitmap; external gdi32 name 'CreateCompatibleBitmap';
function CreateCompatibleDC; external gdi32 name 'CreateCompatibleDC';
function CreateDCA; external gdi32 name 'CreateDCA';
function CreateDCW; external gdi32 name 'CreateDCW';
function CreateDC; external gdi32 name 'CreateDC'+_X;
function CreateDIBPatternBrush; external gdi32 name 'CreateDIBPatternBrush';
function CreateDIBPatternBrushPt; external gdi32 name 'CreateDIBPatternBrushPt';
function CreateDIBSection; external gdi32 name 'CreateDIBSection';
function CreateDIBitmap; external gdi32 name 'CreateDIBitmap';
function CreateDiscardableBitmap; external gdi32 name 'CreateDiscardableBitmap';
function CreateEllipticRgn; external gdi32 name 'CreateEllipticRgn';
function CreateEllipticRgnIndirect; external gdi32 name 'CreateEllipticRgnIndirect';
function CreateEnhMetaFileA; external gdi32 name 'CreateEnhMetaFileA';
function CreateEnhMetaFileW; external gdi32 name 'CreateEnhMetaFileW';
function CreateEnhMetaFile; external gdi32 name 'CreateEnhMetaFile'+_X;
function CreateFontA; external gdi32 name 'CreateFontA';
function CreateFontW; external gdi32 name 'CreateFontW';
function CreateFont; external gdi32 name 'CreateFont'+_X;
function CreateFontIndirectA; external gdi32 name 'CreateFontIndirectA';
function CreateFontIndirectW; external gdi32 name 'CreateFontIndirectW';
function CreateFontIndirect; external gdi32 name 'CreateFontIndirect'+_X;
function CreateFontIndirectExA; external gdi32 name 'CreateFontIndirectExA';
function CreateFontIndirectExW; external gdi32 name 'CreateFontIndirectExW';
function CreateFontIndirectEx; external gdi32 name 'CreateFontIndirectEx'+_X;
function CreateHalftonePalette; external gdi32 name 'CreateHalftonePalette';
function CreateHatchBrush; external gdi32 name 'CreateHatchBrush';
function CreateICA; external gdi32 name 'CreateICA';
function CreateICW; external gdi32 name 'CreateICW';
function CreateIC; external gdi32 name 'CreateIC'+_X;
function CreateMetaFileA; external gdi32 name 'CreateMetaFileA';
function CreateMetaFileW; external gdi32 name 'CreateMetaFileW';
function CreateMetaFile; external gdi32 name 'CreateMetaFile'+_X;
function CreatePalette; external gdi32 name 'CreatePalette';
function CreatePatternBrush; external gdi32 name 'CreatePatternBrush';
function CreatePen; external gdi32 name 'CreatePen';
function CreatePenIndirect; external gdi32 name 'CreatePenIndirect';
function CreatePolyPolygonRgn; external gdi32 name 'CreatePolyPolygonRgn';
function CreatePolygonRgn; external gdi32 name 'CreatePolygonRgn';
function CreateRectRgn; external gdi32 name 'CreateRectRgn';
function CreateRectRgnIndirect; external gdi32 name 'CreateRectRgnIndirect';
function CreateRoundRectRgn; external gdi32 name 'CreateRoundRectRgn';
function CreateScalableFontResourceA; external gdi32 name 'CreateScalableFontResourceA';
function CreateScalableFontResourceW; external gdi32 name 'CreateScalableFontResourceW';
function CreateScalableFontResource; external gdi32 name 'CreateScalableFontResource'+_X;
function CreateSolidBrush; external gdi32 name 'CreateSolidBrush';
function DPtoLP; external gdi32 name 'DPtoLP';
function DeleteColorSpace; external gdi32 name 'DeleteColorSpace';
function DeleteDC; external gdi32 name 'DeleteDC';
function DeleteEnhMetaFile; external gdi32 name 'DeleteEnhMetaFile';
function DeleteMetaFile; external gdi32 name 'DeleteMetaFile';
function DeleteObject; external gdi32 name 'DeleteObject';
function DescribePixelFormat; external gdi32 name 'DescribePixelFormat';
function DeviceCapabilitiesA; external gdi32 name 'DeviceCapabilitiesA';
function DeviceCapabilitiesW; external gdi32 name 'DeviceCapabilitiesW';
function DeviceCapabilities; external gdi32 name 'DeviceCapabilities'+_X;
{function DeviceCapabilitiesEx; external gdi32 name 'DeviceCapabilities';}
function DrawEscape; external gdi32 name 'DrawEscape';
function Ellipse; external gdi32 name 'Ellipse';
function EndDoc; external gdi32 name 'EndDoc';
function EndPage; external gdi32 name 'EndPage';
function EndPath; external gdi32 name 'EndPath';
function EnumEnhMetaFile; external gdi32 name 'EnumEnhMetaFile';
function EnumFontFamiliesA; external gdi32 name 'EnumFontFamiliesA';
function EnumFontFamiliesW; external gdi32 name 'EnumFontFamiliesW';
function EnumFontFamilies; external gdi32 name 'EnumFontFamilies'+_X;
function EnumFontFamiliesExA; external gdi32 name 'EnumFontFamiliesExA';
function EnumFontFamiliesExW; external gdi32 name 'EnumFontFamiliesExW';
function EnumFontFamiliesEx; external gdi32 name 'EnumFontFamiliesEx'+_X;
function EnumFontsA; external gdi32 name 'EnumFontsA';
function EnumFontsW; external gdi32 name 'EnumFontsW';
function EnumFonts; external gdi32 name 'EnumFonts'+_X;
function EnumICMProfilesA; external gdi32 name 'EnumICMProfilesA';
function EnumICMProfilesW; external gdi32 name 'EnumICMProfilesW';
function EnumICMProfiles; external gdi32 name 'EnumICMProfiles'+_X;
function EnumMetaFile; external gdi32 name 'EnumMetaFile';
function EnumObjects; external gdi32 name 'EnumObjects';
function EqualRgn; external gdi32 name 'EqualRgn';
function Escape; external gdi32 name 'Escape';
function ExcludeClipRect; external gdi32 name 'ExcludeClipRect';
function ExtCreatePen; external gdi32 name 'ExtCreatePen';
function ExtCreateRegion; external gdi32 name 'ExtCreateRegion';
function ExtEscape; external gdi32 name 'ExtEscape';
function ExtFloodFill; external gdi32 name 'ExtFloodFill';
function ExtSelectClipRgn; external gdi32 name 'ExtSelectClipRgn';
function ExtTextOutA; external gdi32 name 'ExtTextOutA';
function ExtTextOutW; external gdi32 name 'ExtTextOutW';
function ExtTextOut; external gdi32 name 'ExtTextOut'+_X;
function FillPath; external gdi32 name 'FillPath';
function FillRgn; external gdi32 name 'FillRgn';
function FlattenPath; external gdi32 name 'FlattenPath';
function FloodFill; external gdi32 name 'FloodFill';
function FrameRgn; external gdi32 name 'FrameRgn';
function GdiComment; external gdi32 name 'GdiComment';
function GdiFlush; external gdi32 name 'GdiFlush';
function GdiGetBatchLimit; external gdi32 name 'GdiGetBatchLimit';
function GdiSetBatchLimit; external gdi32 name 'GdiSetBatchLimit';
function GetArcDirection; external gdi32 name 'GetArcDirection';
function GetAspectRatioFilterEx; external gdi32 name 'GetAspectRatioFilterEx';
function GetBitmapBits; external gdi32 name 'GetBitmapBits';
function GetBitmapDimensionEx; external gdi32 name 'GetBitmapDimensionEx';
function GetBkColor; external gdi32 name 'GetBkColor';
function GetBkMode; external gdi32 name 'GetBkMode';
function GetBoundsRect; external gdi32 name 'GetBoundsRect';
function GetBrushOrgEx; external gdi32 name 'GetBrushOrgEx';
function GetCharABCWidthsA; external gdi32 name 'GetCharABCWidthsA';
function GetCharABCWidthsW; external gdi32 name 'GetCharABCWidthsW';
function GetCharABCWidths; external gdi32 name 'GetCharABCWidths'+_X;
function GetCharABCWidthsI; external gdi32 name 'GetCharABCWidthsI';
function GetCharABCWidthsFloatA; external gdi32 name 'GetCharABCWidthsFloatA';
function GetCharABCWidthsFloatW; external gdi32 name 'GetCharABCWidthsFloatW';
function GetCharABCWidthsFloat; external gdi32 name 'GetCharABCWidthsFloat'+_X;
function GetCharWidth32A; external gdi32 name 'GetCharWidth32A';
function GetCharWidth32W; external gdi32 name 'GetCharWidth32W';
function GetCharWidth32; external gdi32 name 'GetCharWidth32'+_X;
function GetCharWidthA; external gdi32 name 'GetCharWidthA';
function GetCharWidthW; external gdi32 name 'GetCharWidthW';
function GetCharWidth; external gdi32 name 'GetCharWidth'+_X;
function GetCharWidthFloatA; external gdi32 name 'GetCharWidthFloatA';
function GetCharWidthFloatW; external gdi32 name 'GetCharWidthFloatW';
function GetCharWidthFloat; external gdi32 name 'GetCharWidthFloat'+_X;
function GetCharWidthI; external gdi32 name 'GetCharWidthI';
function GetCharacterPlacementA; external gdi32 name 'GetCharacterPlacementA';
function GetCharacterPlacementW; external gdi32 name 'GetCharacterPlacementW';
function GetCharacterPlacement; external gdi32 name 'GetCharacterPlacement'+_X;
function GetClipBox; external gdi32 name 'GetClipBox';
function GetClipRgn; external gdi32 name 'GetClipRgn';
function GetColorAdjustment; external gdi32 name 'GetColorAdjustment';
function GetColorSpace; external gdi32 name 'GetColorSpace';
function GetCurrentObject; external gdi32 name 'GetCurrentObject';
function GetCurrentPositionEx; external gdi32 name 'GetCurrentPositionEx';
function GetDCBrushColor; external gdi32 name 'GetDCBrushColor';
function GetDCPenColor; external gdi32 name 'GetDCPenColor';
function GetDCOrgEx; external gdi32 name 'GetDCOrgEx';
function GetDIBColorTable; external gdi32 name 'GetDIBColorTable';
function GetDIBits; external gdi32 name 'GetDIBits';
function GetDeviceCaps; external gdi32 name 'GetDeviceCaps';
function GetDeviceGammaRamp; external gdi32 name 'GetDeviceGammaRamp';
function GetEnhMetaFileA; external gdi32 name 'GetEnhMetaFileA';
function GetEnhMetaFileW; external gdi32 name 'GetEnhMetaFileW';
function GetEnhMetaFile; external gdi32 name 'GetEnhMetaFile'+_X;
function GetEnhMetaFileBits; external gdi32 name 'GetEnhMetaFileBits';
function GetEnhMetaFileDescriptionA; external gdi32 name 'GetEnhMetaFileDescriptionA';
function GetEnhMetaFileDescriptionW; external gdi32 name 'GetEnhMetaFileDescriptionW';
function GetEnhMetaFileDescription; external gdi32 name 'GetEnhMetaFileDescription'+_X;
function GetEnhMetaFileHeader; external gdi32 name 'GetEnhMetaFileHeader';
function GetEnhMetaFilePaletteEntries; external gdi32 name 'GetEnhMetaFilePaletteEntries';
function GetEnhMetaFilePixelFormat; external gdi32 name 'GetEnhMetaFilePixelFormat';
function GetFontData; external gdi32 name 'GetFontData';
function GetFontLanguageInfo; external gdi32 name 'GetFontLanguageInfo';
function GetFontUnicodeRanges; external gdi32 name 'GetFontUnicodeRanges';
function GetGlyphIndicesA; external gdi32 name 'GetGlyphIndicesA';
function GetGlyphIndicesW; external gdi32 name 'GetGlyphIndicesW';
function GetGlyphIndices; external gdi32 name 'GetGlyphIndices'+_X;
function GetGlyphOutlineA; external gdi32 name 'GetGlyphOutlineA';
function GetGlyphOutlineW; external gdi32 name 'GetGlyphOutlineW';
function GetGlyphOutline; external gdi32 name 'GetGlyphOutline'+_X;
function GetGraphicsMode; external gdi32 name 'GetGraphicsMode';
function GetICMProfileA; external gdi32 name 'GetICMProfileA';
function GetICMProfileW; external gdi32 name 'GetICMProfileW';
function GetICMProfile; external gdi32 name 'GetICMProfile'+_X;
function GetKerningPairs; external gdi32 name 'GetKerningPairs';
function GetLogColorSpaceA; external gdi32 name 'GetLogColorSpaceA';
function GetLogColorSpaceW; external gdi32 name 'GetLogColorSpaceW';
function GetLogColorSpace; external gdi32 name 'GetLogColorSpace'+_X;
function GetMapMode; external gdi32 name 'GetMapMode';
function GetMetaFileA; external gdi32 name 'GetMetaFileA';
function GetMetaFileW; external gdi32 name 'GetMetaFileW';
function GetMetaFile; external gdi32 name 'GetMetaFile'+_X;
function GetMetaFileBitsEx; external gdi32 name 'GetMetaFileBitsEx';
function GetMetaRgn; external gdi32 name 'GetMetaRgn';
function GetMiterLimit; external gdi32 name 'GetMiterLimit';
function GetNearestColor; external gdi32 name 'GetNearestColor';
function GetNearestPaletteIndex; external gdi32 name 'GetNearestPaletteIndex';
function GetObjectA; external gdi32 name 'GetObjectA';
function GetObjectW; external gdi32 name 'GetObjectW';
function GetObject; external gdi32 name 'GetObject'+_X;
function GetObjectType; external gdi32 name 'GetObjectType';
function GetOutlineTextMetricsA; external gdi32 name 'GetOutlineTextMetricsA';
function GetOutlineTextMetricsW; external gdi32 name 'GetOutlineTextMetricsW';
function GetOutlineTextMetrics; external gdi32 name 'GetOutlineTextMetrics'+_X;
function GetPaletteEntries; external gdi32 name 'GetPaletteEntries';
function GetPath; external gdi32 name 'GetPath';
function GetPixel; external gdi32 name 'GetPixel';
function GetPixelFormat; external gdi32 name 'GetPixelFormat';
function GetPolyFillMode; external gdi32 name 'GetPolyFillMode';
function GetROP2; external gdi32 name 'GetROP2';
function GetRasterizerCaps; external gdi32 name 'GetRasterizerCaps';
function GetRegionData; external gdi32 name 'GetRegionData';
function GetRgnBox; external gdi32 name 'GetRgnBox';
function GetStockObject; external gdi32 name 'GetStockObject';
function GetStretchBltMode; external gdi32 name 'GetStretchBltMode';
function GetSystemPaletteEntries; external gdi32 name 'GetSystemPaletteEntries';
function GetSystemPaletteUse; external gdi32 name 'GetSystemPaletteUse';
function GetTextAlign; external gdi32 name 'GetTextAlign';
function GetTextCharacterExtra; external gdi32 name 'GetTextCharacterExtra';
function GetTextCharset; external gdi32 name 'GetTextCharset';
function GetTextCharsetInfo; external gdi32 name 'GetTextCharsetInfo';
function GetTextColor; external gdi32 name 'GetTextColor';
function GetTextExtentExPointA; external gdi32 name 'GetTextExtentExPointA';
function GetTextExtentExPointW; external gdi32 name 'GetTextExtentExPointW';
function GetTextExtentExPoint; external gdi32 name 'GetTextExtentExPoint'+_X;
function GetTextExtentExPointI; external gdi32 name 'GetTextExtentExPointI';
function GetTextExtentPoint32A; external gdi32 name 'GetTextExtentPoint32A';
function GetTextExtentPoint32W; external gdi32 name 'GetTextExtentPoint32W';
function GetTextExtentPoint32; external gdi32 name 'GetTextExtentPoint32'+_X;
function GetTextExtentPointA; external gdi32 name 'GetTextExtentPointA';
function GetTextExtentPointW; external gdi32 name 'GetTextExtentPointW';
function GetTextExtentPoint; external gdi32 name 'GetTextExtentPoint'+_X;
function GetTextExtentPointI; external gdi32 name 'GetTextExtentPointI';
function GetTextFaceA; external gdi32 name 'GetTextFaceA';
function GetTextFaceW; external gdi32 name 'GetTextFaceW';
function GetTextFace; external gdi32 name 'GetTextFace'+_X;
function GetTextMetricsA; external gdi32 name 'GetTextMetricsA';
function GetTextMetricsW; external gdi32 name 'GetTextMetricsW';
function GetTextMetrics; external gdi32 name 'GetTextMetrics'+_X;
function GetViewportExtEx; external gdi32 name 'GetViewportExtEx';
function GetViewportOrgEx; external gdi32 name 'GetViewportOrgEx';
function GetWinMetaFileBits; external gdi32 name 'GetWinMetaFileBits';
function GetWindowExtEx; external gdi32 name 'GetWindowExtEx';
function GetWindowOrgEx; external gdi32 name 'GetWindowOrgEx';
function GetWorldTransform; external gdi32 name 'GetWorldTransform';
function GradientFill; external msimg32 name 'GradientFill';
function IntersectClipRect; external gdi32 name 'IntersectClipRect';
function InvertRgn; external gdi32 name 'InvertRgn';
function LPtoDP; external gdi32 name 'LPtoDP';
function LineDDA; external gdi32 name 'LineDDA';
function LineTo; external gdi32 name 'LineTo';
function MaskBlt; external gdi32 name 'MaskBlt';
function ModifyWorldTransform; external gdi32 name 'ModifyWorldTransform';
function MoveToEx; external gdi32 name 'MoveToEx';
function OffsetClipRgn; external gdi32 name 'OffsetClipRgn';
function OffsetRgn; external gdi32 name 'OffsetRgn';
function OffsetViewportOrgEx(DC: HDC; X, Y: Integer; var Points): BOOL; external gdi32 name 'OffsetViewportOrgEx';
function OffsetWindowOrgEx(DC: HDC; X, Y: Integer; var Points): BOOL; external gdi32 name 'OffsetWindowOrgEx';
function OffsetViewportOrgEx(DC: HDC; X, Y: Integer; Points: PPoint): BOOL; stdcall; external gdi32 name 'OffsetViewportOrgEx';
function OffsetWindowOrgEx(DC: HDC; X, Y: Integer; Points: PPoint): BOOL; stdcall; external gdi32 name 'OffsetWindowOrgEx';
function PaintRgn; external gdi32 name 'PaintRgn';
function PatBlt; external gdi32 name 'PatBlt';
function PathToRegion; external gdi32 name 'PathToRegion';
function Pie; external gdi32 name 'Pie';
function PlayEnhMetaFile; external gdi32 name 'PlayEnhMetaFile';
function PlayEnhMetaFileRecord; external gdi32 name 'PlayEnhMetaFileRecord';
function PlayMetaFile; external gdi32 name 'PlayMetaFile';
function PlayMetaFileRecord; external gdi32 name 'PlayMetaFileRecord';
function PlgBlt; external gdi32 name 'PlgBlt';
function PolyBezier; external gdi32 name 'PolyBezier';
function PolyBezierTo; external gdi32 name 'PolyBezierTo';
function PolyDraw; external gdi32 name 'PolyDraw';
function PolyPolygon; external gdi32 name 'PolyPolygon';
function PolyPolyline; external gdi32 name 'PolyPolyline';
function PolyTextOutA; external gdi32 name 'PolyTextOutA';
function PolyTextOutW; external gdi32 name 'PolyTextOutW';
function PolyTextOut; external gdi32 name 'PolyTextOut'+_X;
function Polygon; external gdi32 name 'Polygon';
function Polyline; external gdi32 name 'Polyline';
function PolylineTo; external gdi32 name 'PolylineTo';
function PtInRegion; external gdi32 name 'PtInRegion';
function PtVisible; external gdi32 name 'PtVisible';
function RealizePalette; external gdi32 name 'RealizePalette';
function RectInRegion; external gdi32 name 'RectInRegion';
function RectVisible; external gdi32 name 'RectVisible';
function Rectangle; external gdi32 name 'Rectangle';
function RemoveFontMemResourceEx; external gdi32 name 'RemoveFontMemResourceEx';
function RemoveFontResourceA; external gdi32 name 'RemoveFontResourceA';
function RemoveFontResourceW; external gdi32 name 'RemoveFontResourceW';
function RemoveFontResource; external gdi32 name 'RemoveFontResource'+_X;
function RemoveFontResourceExA; external gdi32 name 'RemoveFontResourceExA';
function RemoveFontResourceExW; external gdi32 name 'RemoveFontResourceExW';
function RemoveFontResourceEx; external gdi32 name 'RemoveFontResourceEx'+_X;
function ResetDCA; external gdi32 name 'ResetDCA';
function ResetDCW; external gdi32 name 'ResetDCW';
function ResetDC; external gdi32 name 'ResetDC'+_X;
function ResizePalette; external gdi32 name 'ResizePalette';
function RestoreDC; external gdi32 name 'RestoreDC';
function RoundRect; external gdi32 name 'RoundRect';
function SaveDC; external gdi32 name 'SaveDC';
function ScaleViewportExtEx; external gdi32 name 'ScaleViewportExtEx';
function ScaleWindowExtEx; external gdi32 name 'ScaleWindowExtEx';
function SelectClipPath; external gdi32 name 'SelectClipPath';
function SelectClipRgn; external gdi32 name 'SelectClipRgn';
function SelectObject; external gdi32 name 'SelectObject';
function SelectPalette; external gdi32 name 'SelectPalette';
function SetAbortProc; external gdi32 name 'SetAbortProc';
function SetArcDirection; external gdi32 name 'SetArcDirection';
function SetBitmapBits; external gdi32 name 'SetBitmapBits';
function SetBitmapDimensionEx; external gdi32 name 'SetBitmapDimensionEx';
function SetBkColor; external gdi32 name 'SetBkColor';
function SetBkMode; external gdi32 name 'SetBkMode';
function SetBoundsRect; external gdi32 name 'SetBoundsRect';
function SetBrushOrgEx; external gdi32 name 'SetBrushOrgEx';
function SetColorAdjustment; external gdi32 name 'SetColorAdjustment';
function SetColorSpace; external gdi32 name 'SetColorSpace';
function SetDCBrushColor; external gdi32 name 'SetDCBrushColor';
function SetDCPenColor; external gdi32 name 'SetDCPenColor';
function SetDIBColorTable; external gdi32 name 'SetDIBColorTable';
function SetDIBits; external gdi32 name 'SetDIBits';
function SetDIBitsToDevice; external gdi32 name 'SetDIBitsToDevice';
function SetDeviceGammaRamp; external gdi32 name 'SetDeviceGammaRamp';
function SetEnhMetaFileBits; external gdi32 name 'SetEnhMetaFileBits';
function SetGraphicsMode; external gdi32 name 'SetGraphicsMode';
function SetICMMode; external gdi32 name 'SetICMMode';
function SetICMProfileA; external gdi32 name 'SetICMProfileA';
function SetICMProfileW; external gdi32 name 'SetICMProfileW';
function SetICMProfile; external gdi32 name 'SetICMProfile'+_X;
function SetMapMode; external gdi32 name 'SetMapMode';
function SetMapperFlags; external gdi32 name 'SetMapperFlags';
function SetMetaFileBitsEx; external gdi32 name 'SetMetaFileBitsEx';
function SetMetaRgn; external gdi32 name 'SetMetaRgn';
function SetMiterLimit; external gdi32 name 'SetMiterLimit';
function SetPaletteEntries; external gdi32 name 'SetPaletteEntries';
function SetPixel; external gdi32 name 'SetPixel';
function SetPixelFormat; external gdi32 name 'SetPixelFormat';
function SetPixelV; external gdi32 name 'SetPixelV';
function SetPolyFillMode; external gdi32 name 'SetPolyFillMode';
function SetROP2; external gdi32 name 'SetROP2';
function SetRectRgn; external gdi32 name 'SetRectRgn';
function SetStretchBltMode; external gdi32 name 'SetStretchBltMode';
function SetSystemPaletteUse; external gdi32 name 'SetSystemPaletteUse';
function SetTextAlign; external gdi32 name 'SetTextAlign';
function SetTextColor; external gdi32 name 'SetTextColor';
function SetTextCharacterExtra; external gdi32 name 'SetTextCharacterExtra';
function SetTextJustification; external gdi32 name 'SetTextJustification';
function SetViewportExtEx; external gdi32 name 'SetViewportExtEx';
function SetViewportOrgEx; external gdi32 name 'SetViewportOrgEx';
function SetWinMetaFileBits; external gdi32 name 'SetWinMetaFileBits';
function SetWindowExtEx; external gdi32 name 'SetWindowExtEx';
function SetWindowOrgEx; external gdi32 name 'SetWindowOrgEx';
function SetWorldTransform; external gdi32 name 'SetWorldTransform';
function StartDocA; external gdi32 name 'StartDocA';
function StartDocW; external gdi32 name 'StartDocW';
function StartDoc; external gdi32 name 'StartDoc'+_X;
function StartPage; external gdi32 name 'StartPage';
function StretchBlt; external gdi32 name 'StretchBlt';
function StretchDIBits; external gdi32 name 'StretchDIBits';
function StrokeAndFillPath; external gdi32 name 'StrokeAndFillPath';
function StrokePath; external gdi32 name 'StrokePath';
function SwapBuffers; external gdi32 name 'SwapBuffers';
function TextOutA; external gdi32 name 'TextOutA';
function TextOutW; external gdi32 name 'TextOutW';
function TextOut; external gdi32 name 'TextOut'+_X;
function TranslateCharsetInfo; external gdi32 name 'TranslateCharsetInfo';
function TransparentBlt; external msimg32 name 'TransparentBlt';
function TransparentDIBits; external gdi32 name 'TransparentDIBits';
function UnrealizeObject; external gdi32 name 'UnrealizeObject';
function UpdateColors; external gdi32 name 'UpdateColors';
function UpdateICMRegKeyA; external gdi32 name 'UpdateICMRegKeyA';
function UpdateICMRegKeyW; external gdi32 name 'UpdateICMRegKeyW';
function UpdateICMRegKey; external gdi32 name 'UpdateICMRegKey'+_X;
function WidenPath; external gdi32 name 'WidenPath';

{ Externals from opengl32.dll }

function wglCopyContext; external opengl32 name 'wglCopyContext';
function wglCreateContext; external opengl32 name 'wglCreateContext';
function wglCreateLayerContext; external opengl32 name 'wglCreateLayerContext';
function wglDeleteContext; external opengl32 name 'wglDeleteContext';
function wglDescribeLayerPlane; external opengl32 name 'wglDescribeLayerPlane';
function wglGetCurrentContext; external opengl32 name 'wglGetCurrentContext';
function wglGetCurrentDC; external opengl32 name 'wglGetCurrentDC';
function wglGetLayerPaletteEntries; external opengl32 name 'wglGetLayerPaletteEntries';
function wglMakeCurrent; external opengl32 name 'wglMakeCurrent';
function wglRealizeLayerPalette; external opengl32 name 'wglRealizeLayerPalette';
function wglSetLayerPaletteEntries; external opengl32 name 'wglSetLayerPaletteEntries';
function wglShareLists; external opengl32 name 'wglShareLists';
function wglSwapLayerBuffers; external opengl32 name 'wglSwapLayerBuffers';
function wglSwapMultipleBuffers; external opengl32 name 'wglSwapMultipleBuffers';
function wglUseFontBitmapsA; external opengl32 name 'wglUseFontBitmapsA';
function wglUseFontOutlinesA; external opengl32 name 'wglUseFontOutlinesA';
function wglUseFontBitmapsW; external opengl32 name 'wglUseFontBitmapsW';
function wglUseFontOutlinesW; external opengl32 name 'wglUseFontOutlinesW';
function wglUseFontBitmaps; external opengl32 name 'wglUseFontBitmaps'+_X;
function wglUseFontOutlines; external opengl32 name 'wglUseFontOutlines'+_X;


{ Externals from user32.dll }

function ActivateKeyboardLayout; external user32 name 'ActivateKeyboardLayout';
function AdjustWindowRect; external user32 name 'AdjustWindowRect';
function AdjustWindowRectEx; external user32 name 'AdjustWindowRectEx';
function AnsiToOem; external user32 name 'CharToOem'+_X;
function AnsiToOemBuff; external user32 name 'CharToOemBuff'+_X;
function AnsiUpper; external user32 name 'CharUpper'+_X;
function AnsiUpperBuff; external user32 name 'CharUpperBuff'+_X;
function AnsiLower; external user32 name 'CharLower'+_X;
function AnsiLowerBuff; external user32 name 'CharLowerBuff'+_X;
function AnsiNext; external user32 name 'CharNext'+_X;
function AnsiPrev; external user32 name 'CharPrev'+_X;
function AnyPopup; external user32 name 'AnyPopup';
function AppendMenuA; external user32 name 'AppendMenuA';
function AppendMenuW; external user32 name 'AppendMenuW';
function AppendMenu; external user32 name 'AppendMenu'+_X;
function ArrangeIconicWindows; external user32 name 'ArrangeIconicWindows';
function AttachThreadInput; external user32 name 'AttachThreadInput';
function BeginDeferWindowPos; external user32 name 'BeginDeferWindowPos';
function BeginPaint; external user32 name 'BeginPaint';
function BringWindowToTop; external user32 name 'BringWindowToTop';
function BroadcastSystemMessageA; external user32 name 'BroadcastSystemMessageA';
function BroadcastSystemMessageW; external user32 name 'BroadcastSystemMessage'+_X;
function BroadcastSystemMessage; external user32 name 'BroadcastSystemMessage'+_X;
function CallMsgFilterA; external user32 name 'CallMsgFilterA';
function CallMsgFilterW; external user32 name 'CallMsgFilterW';
function CallMsgFilter; external user32 name 'CallMsgFilter'+_X;
function CallNextHookEx; external user32 name 'CallNextHookEx';
function CallWindowProcA; external user32 name 'CallWindowProcA';
function CallWindowProcW; external user32 name 'CallWindowProcW';
function CallWindowProc; external user32 name 'CallWindowProc'+_X;
function CascadeWindows; external user32 name 'CascadeWindows';
function ChangeClipboardChain; external user32 name 'ChangeClipboardChain';
function ChangeDisplaySettingsA; external user32 name 'ChangeDisplaySettingsA';
function ChangeDisplaySettingsW; external user32 name 'ChangeDisplaySettingsW';
function ChangeDisplaySettings; external user32 name 'ChangeDisplaySettings'+_X;
function ChangeDisplaySettingsExA; external user32 name 'ChangeDisplaySettingsExA';
function ChangeDisplaySettingsExW; external user32 name 'ChangeDisplaySettingsExW';
function ChangeDisplaySettingsEx; external user32 name 'ChangeDisplaySettingsEx'+_X;
function ChangeMenuA; external user32 name 'ChangeMenuA';
function ChangeMenuW; external user32 name 'ChangeMenuW';
function ChangeMenu; external user32 name 'ChangeMenu'+_X;
function CharLowerA; external user32 name 'CharLowerA';
function CharLowerW; external user32 name 'CharLowerW';
function CharLower; external user32 name 'CharLower'+_X;
function CharLowerBuffA; external user32 name 'CharLowerBuffA';
function CharLowerBuffW; external user32 name 'CharLowerBuffW';
function CharLowerBuff; external user32 name 'CharLowerBuff'+_X;
function CharNextA; external user32 name 'CharNextA';
function CharNextW; external user32 name 'CharNextW';
function CharNext; external user32 name 'CharNext'+_X;
function CharNextEx; external user32 name 'CharNextEx'+_X;
function CharNextExA; external user32 name 'CharNextExA';
function CharPrevA; external user32 name 'CharPrevA';
function CharPrevW; external user32 name 'CharPrevW';
function CharPrev; external user32 name 'CharPrev'+_X;
function CharPrevEx; external user32 name 'CharPrevEx'+_X;
function CharPrevExA; external user32 name 'CharPrevExA';
function CharToOemA; external user32 name 'CharToOemA';
function CharToOemW; external user32 name 'CharToOemW';
function CharToOem; external user32 name 'CharToOem'+_X;
function CharToOemBuffA; external user32 name 'CharToOemBuffA';
function CharToOemBuffW; external user32 name 'CharToOemBuffW';
function CharToOemBuff; external user32 name 'CharToOemBuff'+_X;
function CharUpperA; external user32 name 'CharUpperA';
function CharUpperW; external user32 name 'CharUpperW';
function CharUpper; external user32 name 'CharUpper'+_X;
function CharUpperBuffA; external user32 name 'CharUpperBuffA';
function CharUpperBuffW; external user32 name 'CharUpperBuffW';
function CharUpperBuff; external user32 name 'CharUpperBuff'+_X;
function CheckDlgButton; external user32 name 'CheckDlgButton';
function CheckMenuItem; external user32 name 'CheckMenuItem';
function CheckMenuRadioItem; external user32 name 'CheckMenuRadioItem';
function CheckRadioButton; external user32 name 'CheckRadioButton';
function ChildWindowFromPoint; external user32 name 'ChildWindowFromPoint';
function ChildWindowFromPointEx; external user32 name 'ChildWindowFromPointEx';
function ClientToScreen; external user32 name 'ClientToScreen';
function ClipCursor; external user32 name 'ClipCursor';
function CloseClipboard; external user32 name 'CloseClipboard';
function CloseDesktop; external user32 name 'CloseDesktop';
function CloseWindow; external user32 name 'CloseWindow';
function CloseWindowStation; external user32 name 'CloseWindowStation';
function CopyAcceleratorTableA; external user32 name 'CopyAcceleratorTableA';
function CopyAcceleratorTableW; external user32 name 'CopyAcceleratorTableW';
function CopyAcceleratorTable; external user32 name 'CopyAcceleratorTable'+_X;
function CopyIcon; external user32 name 'CopyIcon';
function CopyImage; external user32 name 'CopyImage';
function CopyRect; external user32 name 'CopyRect';
function CountClipboardFormats; external user32 name 'CountClipboardFormats';
function CreateAcceleratorTableA; external user32 name 'CreateAcceleratorTableA';
function CreateAcceleratorTableW; external user32 name 'CreateAcceleratorTableW';
function CreateAcceleratorTable; external user32 name 'CreateAcceleratorTable'+_X;
function CreateCaret; external user32 name 'CreateCaret';
function CreateCursor; external user32 name 'CreateCursor';
function CreateDesktopA; external user32 name 'CreateDesktopA';
function CreateDesktopW; external user32 name 'CreateDesktopW';
function CreateDesktop; external user32 name 'CreateDesktop'+_X;
function CreateDialogIndirectParamA; external user32 name 'CreateDialogIndirectParamA';
function CreateDialogIndirectParamW; external user32 name 'CreateDialogIndirectParamW';
function CreateDialogIndirectParam; external user32 name 'CreateDialogIndirectParam'+_X;
function CreateDialogParamA; external user32 name 'CreateDialogParamA';
function CreateDialogParamW; external user32 name 'CreateDialogParamW';
function CreateDialogParam; external user32 name 'CreateDialogParam'+_X;
function CreateIcon; external user32 name 'CreateIcon';
function CreateIconFromResource; external user32 name 'CreateIconFromResource';
function CreateIconFromResourceEx; external user32 name 'CreateIconFromResourceEx';
function CreateIconIndirect; external user32 name 'CreateIconIndirect';
function CreateMDIWindowA; external user32 name 'CreateMDIWindowA';
function CreateMDIWindowW; external user32 name 'CreateMDIWindowW';
function CreateMDIWindow; external user32 name 'CreateMDIWindow'+_X;
function CreateMenu; external user32 name 'CreateMenu';
function CreatePopupMenu; external user32 name 'CreatePopupMenu';
function CreateWindowExA; external user32 name 'CreateWindowExA';
function CreateWindowExW; external user32 name 'CreateWindowExW';
function CreateWindowEx; external user32 name 'CreateWindowEx'+_X;
function CreateWindowStationA; external user32 name 'CreateWindowStationA';
function CreateWindowStationW; external user32 name 'CreateWindowStationW';
function CreateWindowStation; external user32 name 'CreateWindowStation'+_X;
function DdeSetQualityOfService; external user32 name 'DdeSetQualityOfService';
function DefDlgProcA; external user32 name 'DefDlgProcA';
function DefDlgProcW; external user32 name 'DefDlgProcW';
function DefDlgProc; external user32 name 'DefDlgProc'+_X;
function DefFrameProcA; external user32 name 'DefFrameProcA';
function DefFrameProcW; external user32 name 'DefFrameProcW';
function DefFrameProc; external user32 name 'DefFrameProc'+_X;
function DefMDIChildProcA; external user32 name 'DefMDIChildProcA';
function DefMDIChildProcW; external user32 name 'DefMDIChildProcW';
function DefMDIChildProc; external user32 name 'DefMDIChildProc'+_X;
function DefWindowProcA; external user32 name 'DefWindowProcA';
function DefWindowProcW; external user32 name 'DefWindowProcW';
function DefWindowProc; external user32 name 'DefWindowProc'+_X;
function DeferWindowPos; external user32 name 'DeferWindowPos';
function DeleteMenu; external user32 name 'DeleteMenu';
function DestroyAcceleratorTable; external user32 name 'DestroyAcceleratorTable';
function DestroyCaret; external user32 name 'DestroyCaret';
function DestroyCursor; external user32 name 'DestroyCursor';
function DestroyIcon; external user32 name 'DestroyIcon';
function DestroyMenu; external user32 name 'DestroyMenu';
function DestroyWindow; external user32 name 'DestroyWindow';
function DialogBoxIndirectParamA; external user32 name 'DialogBoxIndirectParamA';
function DialogBoxIndirectParamW; external user32 name 'DialogBoxIndirectParamW';
function DialogBoxIndirectParam; external user32 name 'DialogBoxIndirectParam'+_X;
function DialogBoxParamA; external user32 name 'DialogBoxParamA';
function DialogBoxParamW; external user32 name 'DialogBoxParamW';
function DialogBoxParam; external user32 name 'DialogBoxParam'+_X;
function DispatchMessageA; external user32 name 'DispatchMessageA';
function DispatchMessageW; external user32 name 'DispatchMessageW';
function DispatchMessage; external user32 name 'DispatchMessage'+_X;
function DlgDirListA; external user32 name 'DlgDirListA';
function DlgDirListW; external user32 name 'DlgDirListW';
function DlgDirList; external user32 name 'DlgDirList'+_X;
function DlgDirListComboBoxA; external user32 name 'DlgDirListComboBoxA';
function DlgDirListComboBoxW; external user32 name 'DlgDirListComboBoxW';
function DlgDirListComboBox; external user32 name 'DlgDirListComboBox'+_X;
function DlgDirSelectComboBoxExA; external user32 name 'DlgDirSelectComboBoxExA';
function DlgDirSelectComboBoxExW; external user32 name 'DlgDirSelectComboBoxExW';
function DlgDirSelectComboBoxEx; external user32 name 'DlgDirSelectComboBoxEx'+_X;
function DlgDirSelectExA; external user32 name 'DlgDirSelectExA';
function DlgDirSelectExW; external user32 name 'DlgDirSelectExW';
function DlgDirSelectEx; external user32 name 'DlgDirSelectEx'+_X;
function DragDetect; external user32 name 'DragDetect';
function DragObject; external user32 name 'DragObject';
function DrawAnimatedRects; external user32 name 'DrawAnimatedRects';
function DrawCaption; external user32 name 'DrawCaption';
function DrawEdge; external user32 name 'DrawEdge';
function DrawFocusRect; external user32 name 'DrawFocusRect';
function DrawFrameControl; external user32 name 'DrawFrameControl';
function DrawIcon; external user32 name 'DrawIcon';
function DrawIconEx; external user32 name 'DrawIconEx';
function DrawMenuBar; external user32 name 'DrawMenuBar';
function DrawStateA; external user32 name 'DrawStateA';
function DrawStateW; external user32 name 'DrawStateW';
function DrawState; external user32 name 'DrawState'+_X;
function DrawTextA; external user32 name 'DrawTextA';
function DrawTextW; external user32 name 'DrawTextW';
function DrawText; external user32 name 'DrawText'+_X;
function DrawTextExA; external user32 name 'DrawTextExA';
function DrawTextExW; external user32 name 'DrawTextExW';
function DrawTextEx; external user32 name 'DrawTextEx'+_X;
function EmptyClipboard; external user32 name 'EmptyClipboard';
function EnableMenuItem; external user32 name 'EnableMenuItem';
function EnableScrollBar; external user32 name 'EnableScrollBar';
function EnableWindow; external user32 name 'EnableWindow';
function EndDeferWindowPos; external user32 name 'EndDeferWindowPos';
function EndDialog; external user32 name 'EndDialog';
function EndMenu; external user32 name 'EndMenu';
function EndPaint; external user32 name 'EndPaint';
function EnumChildWindows; external user32 name 'EnumChildWindows';
function EnumClipboardFormats; external user32 name 'EnumClipboardFormats';
function EnumDesktopsA; external user32 name 'EnumDesktopsA';
function EnumDesktopsW; external user32 name 'EnumDesktopsW';
function EnumDesktops; external user32 name 'EnumDesktops'+_X;
function EnumDesktopWindows; external user32 name 'EnumDesktopWindows';
function EnumDisplaySettingsA; external user32 name 'EnumDisplaySettingsA';
function EnumDisplaySettingsW; external user32 name 'EnumDisplaySettingsW';
function EnumDisplaySettings; external user32 name 'EnumDisplaySettings'+_X;
function EnumDisplayDevicesA; external user32 name 'EnumDisplayDevicesA';
function EnumDisplayDevicesW; external user32 name 'EnumDisplayDevicesW';
function EnumDisplayDevices; external user32 name 'EnumDisplayDevices'+_X;
function EnumPropsA; external user32 name 'EnumPropsA';
function EnumPropsW; external user32 name 'EnumPropsW';
function EnumProps; external user32 name 'EnumProps'+_X;
function EnumPropsExA; external user32 name 'EnumPropsExA';
function EnumPropsExW; external user32 name 'EnumPropsExW';
function EnumPropsEx; external user32 name 'EnumPropsEx'+_X;
function EnumThreadWindows; external user32 name 'EnumThreadWindows';
function EnumWindowStationsA; external user32 name 'EnumWindowStationsA';
function EnumWindowStationsW; external user32 name 'EnumWindowStationsW';
function EnumWindowStations; external user32 name 'EnumWindowStations'+_X;
function EnumWindows; external user32 name 'EnumWindows';
function EqualRect; external user32 name 'EqualRect';
function ExcludeUpdateRgn; external user32 name 'ExcludeUpdateRgn';
function ExitWindowsEx; external user32 name 'ExitWindowsEx';
function FillRect; external user32 name 'FillRect';
function FindWindowA; external user32 name 'FindWindowA';
function FindWindowW; external user32 name 'FindWindowW';
function FindWindow; external user32 name 'FindWindow'+_X;
function FindWindowExA; external user32 name 'FindWindowExA';
function FindWindowExW; external user32 name 'FindWindowExW';
function FindWindowEx; external user32 name 'FindWindowEx'+_X;
function FlashWindow; external user32 name 'FlashWindow';
function FlashWindowEx; external user32 name 'FlashWindowEx';
function FrameRect; external user32 name 'FrameRect';
function FreeDDElParam; external user32 name 'FreeDDElParam';
function GetActiveWindow; external user32 name 'GetActiveWindow';
function GetAltTabInfoA; external user32 name 'GetAltTabInfoA';
function GetAltTabInfoW; external user32 name 'GetAltTabInfoW';
function GetAltTabInfo; external user32 name 'GetAltTabInfo'+_X;
function GetAncestor; external user32 name 'GetAncestor';
function GetAsyncKeyState; external user32 name 'GetAsyncKeyState';
function GetCapture; external user32 name 'GetCapture';
function GetCaretBlinkTime; external user32 name 'GetCaretBlinkTime';
function GetCaretPos; external user32 name 'GetCaretPos';
function GetClassInfoA; external user32 name 'GetClassInfoA';
function GetClassInfoW; external user32 name 'GetClassInfoW';
function GetClassInfo; external user32 name 'GetClassInfo'+_X;
function GetClassInfoExA; external user32 name 'GetClassInfoExA';
function GetClassInfoExW; external user32 name 'GetClassInfoExW';
function GetClassInfoEx; external user32 name 'GetClassInfoEx'+_X;
function GetClassLongA; external user32 name 'GetClassLongA';
function GetClassLongW; external user32 name 'GetClassLongW';
function GetClassLong; external user32 name 'GetClassLong'+_X;
function GetClassNameA; external user32 name 'GetClassNameA';
function GetClassNameW; external user32 name 'GetClassNameW';
function GetClassName; external user32 name 'GetClassName'+_X;
function GetClassWord; external user32 name 'GetClassWord';
function GetClientRect; external user32 name 'GetClientRect';
function GetClipCursor; external user32 name 'GetClipCursor';
function GetClipboardData; external user32 name 'GetClipboardData';
function GetClipboardFormatNameA; external user32 name 'GetClipboardFormatNameA';
function GetClipboardFormatNameW; external user32 name 'GetClipboardFormatNameW';
function GetClipboardFormatName; external user32 name 'GetClipboardFormatName'+_X;
function GetClipboardSequenceNumber; external user32 name 'GetClipboardSequenceNumber';
function GetClipboardOwner; external user32 name 'GetClipboardOwner';
function GetClipboardViewer; external user32 name 'GetClipboardViewer';
function GetComboBoxInfo; external user32 name 'GetComboBoxInfo';
function GetCursor; external user32 name 'GetCursor';
function GetCursorInfo; external user32 name 'GetCursorInfo';
function GetCursorPos; external user32 name 'GetCursorPos';
function GetDC; external user32 name 'GetDC';
function GetDCEx; external user32 name 'GetDCEx';
function GetDesktopWindow; external user32 name 'GetDesktopWindow';
function GetDialogBaseUnits; external user32 name 'GetDialogBaseUnits';
function GetDlgCtrlID; external user32 name 'GetDlgCtrlID';
function GetDlgItem; external user32 name 'GetDlgItem';
function GetDlgItemInt; external user32 name 'GetDlgItemInt';
function GetDlgItemTextA; external user32 name 'GetDlgItemTextA';
function GetDlgItemTextW; external user32 name 'GetDlgItemTextW';
function GetDlgItemText; external user32 name 'GetDlgItemText'+_X;
function GetDoubleClickTime; external user32 name 'GetDoubleClickTime';
function GetFocus; external user32 name 'GetFocus';
function GetForegroundWindow; external user32 name 'GetForegroundWindow';
function GetGuiResources; external user32 name 'GetGuiResources';
function GetGUIThreadInfo; external user32 name 'GetGUIThreadInfo';
function GetIconInfo; external user32 name 'GetIconInfo';
function GetInputState; external user32 name 'GetInputState';
function GetKBCodePage; external user32 name 'GetKBCodePage';
function GetKeyNameTextA; external user32 name 'GetKeyNameTextA';
function GetKeyNameTextW; external user32 name 'GetKeyNameTextW';
function GetKeyNameText; external user32 name 'GetKeyNameText'+_X;
function GetKeyState; external user32 name 'GetKeyState';
function GetKeyboardLayout; external user32 name 'GetKeyboardLayout';
function GetKeyboardLayoutList; external user32 name 'GetKeyboardLayoutList';
function GetKeyboardLayoutNameA; external user32 name 'GetKeyboardLayoutNameA';
function GetKeyboardLayoutNameW; external user32 name 'GetKeyboardLayoutNameW';
function GetKeyboardLayoutName; external user32 name 'GetKeyboardLayoutName'+_X;
function GetMouseMovePoints; external user32 name 'GetMouseMovePoints';
function GetKeyboardState; external user32 name 'GetKeyboardState';
function GetKeyboardType; external user32 name 'GetKeyboardType';
function GetLastActivePopup; external user32 name 'GetLastActivePopup';
function GetLastInputInfo; external user32 name 'GetLastInputInfo';
function GetListBoxInfo; external user32 name 'GetListBoxInfo';
function GetMenu; external user32 name 'GetMenu';
function GetMenuBarInfo; external user32 name 'GetMenuBarInfo';
function GetMenuCheckMarkDimensions; external user32 name 'GetMenuCheckMarkDimensions';
function GetMenuContextHelpId; external user32 name 'GetMenuContextHelpId';
function GetMenuDefaultItem; external user32 name 'GetMenuDefaultItem';
function GetMenuInfo; external user32 name 'GetMenuInfo';
function GetMenuItemCount; external user32 name 'GetMenuItemCount';
function GetMenuItemID; external user32 name 'GetMenuItemID';
function GetMenuItemInfoA; external user32 name 'GetMenuItemInfoA';
function GetMenuItemInfoW; external user32 name 'GetMenuItemInfoW';
function GetMenuItemInfo; external user32 name 'GetMenuItemInfo'+_X;
function GetMenuItemRect; external user32 name 'GetMenuItemRect';
function GetMenuState; external user32 name 'GetMenuState';
function GetMenuStringA; external user32 name 'GetMenuStringA';
function GetMenuStringW; external user32 name 'GetMenuStringW';
function GetMenuString; external user32 name 'GetMenuString'+_X;
function GetMessageA; external user32 name 'GetMessageA';
function GetMessageW; external user32 name 'GetMessageW';
function GetMessage; external user32 name 'GetMessage'+_X;
function GetMessageExtraInfo; external user32 name 'GetMessageExtraInfo';
function GetMessagePos; external user32 name 'GetMessagePos';
function GetMessageTime; external user32 name 'GetMessageTime';
function GetNextDlgGroupItem; external user32 name 'GetNextDlgGroupItem';
function GetNextDlgTabItem; external user32 name 'GetNextDlgTabItem';
function GetNextWindow; external user32 name 'GetWindow';
function GetOpenClipboardWindow; external user32 name 'GetOpenClipboardWindow';
function GetParent; external user32 name 'GetParent';
function GetPriorityClipboardFormat; external user32 name 'GetPriorityClipboardFormat';
function GetProcessWindowStation; external user32 name 'GetProcessWindowStation';
function GetPropA; external user32 name 'GetPropA';
function GetPropW; external user32 name 'GetPropW';
function GetProp; external user32 name 'GetProp'+_X;
function GetQueueStatus; external user32 name 'GetQueueStatus';
function GetScrollBarInfo; external user32 name 'GetScrollBarInfo';
function GetScrollInfo; external user32 name 'GetScrollInfo';
function GetScrollPos; external user32 name 'GetScrollPos';
function GetScrollRange; external user32 name 'GetScrollRange';
function GetSubMenu; external user32 name 'GetSubMenu';
function GetSysColor; external user32 name 'GetSysColor';
function GetSysColorBrush; external user32 name 'GetSysColorBrush';
function GetSystemMenu; external user32 name 'GetSystemMenu';
function GetSystemMetrics; external user32 name 'GetSystemMetrics';
function GetTabbedTextExtentA; external user32 name 'GetTabbedTextExtentA';
function GetTabbedTextExtentW; external user32 name 'GetTabbedTextExtentW';
function GetTabbedTextExtent; external user32 name 'GetTabbedTextExtent'+_X;
function GetThreadDesktop; external user32 name 'GetThreadDesktop';
function GetTitleBarInfo; external user32 name 'GetTitleInfo';
function GetTopWindow; external user32 name 'GetTopWindow';
function GetUpdateRect; external user32 name 'GetUpdateRect';
function GetUpdateRgn; external user32 name 'GetUpdateRgn';
function GetUserObjectInformationA; external user32 name 'GetUserObjectInformationA';
function GetUserObjectInformationW; external user32 name 'GetUserObjectInformationW';
function GetUserObjectInformation; external user32 name 'GetUserObjectInformation'+_X;
function GetUserObjectSecurity; external user32 name 'GetUserObjectSecurity';
function GetWindow; external user32 name 'GetWindow';
function GetWindowContextHelpId; external user32 name 'GetWindowContextHelpId';
function GetWindowDC; external user32 name 'GetWindowDC';
function GetWindowInfo; external user32 name 'GetWindowInfo';
function GetWindowLongA; external user32 name 'GetWindowLongA';
function GetWindowLongW; external user32 name 'GetWindowLongW';
function GetWindowLong; external user32 name 'GetWindowLong'+_X;
function GetWindowModuleFileNameA; external user32 name 'GetWindowModuleFileNameA';
function GetWindowModuleFileNameW; external user32 name 'GetWindowModuleFileNameW';
function GetWindowModuleFileName; external user32 name 'GetWindowModuleFileName'+_X;
function GetWindowPlacement; external user32 name 'GetWindowPlacement';
function GetWindowRect; external user32 name 'GetWindowRect';
function GetWindowRgn; external user32 name 'GetWindowRgn';
function GetWindowTextA; external user32 name 'GetWindowTextA';
function GetWindowTextW; external user32 name 'GetWindowTextW';
function GetWindowText; external user32 name 'GetWindowText'+_X;
function GetWindowTextLengthA; external user32 name 'GetWindowTextLengthA';
function GetWindowTextLengthW; external user32 name 'GetWindowTextLengthW';
function GetWindowTextLength; external user32 name 'GetWindowTextLength'+_X;
function GetWindowThreadProcessId; external user32 name 'GetWindowThreadProcessId';
function GetWindowWord; external user32 name 'GetWindowWord';
function GrayStringA; external user32 name 'GrayStringA';
function GrayStringW; external user32 name 'GrayStringW';
function GrayString; external user32 name 'GrayString'+_X;
function HideCaret; external user32 name 'HideCaret';
function HiliteMenuItem; external user32 name 'HiliteMenuItem';
function ImpersonateDdeClientWindow; external user32 name 'ImpersonateDdeClientWindow';
function InSendMessage; external user32 name 'InSendMessage';
function InSendMessageeX; external user32 name 'InSendMessageeX';
function InflateRect; external user32 name 'InflateRect';
function InsertMenuA; external user32 name 'InsertMenuA';
function InsertMenuW; external user32 name 'InsertMenuW';
function InsertMenu; external user32 name 'InsertMenu'+_X;
function InsertMenuItemA; external user32 name 'InsertMenuItemA';
function InsertMenuItemW; external user32 name 'InsertMenuItemW';
function InsertMenuItem; external user32 name 'InsertMenuItem'+_X;
function IntersectRect; external user32 name 'IntersectRect';
function InvalidateRect; external user32 name 'InvalidateRect';
function InvalidateRgn; external user32 name 'InvalidateRgn';
function InvertRect; external user32 name 'InvertRect';
function IsCharAlphaA; external user32 name 'IsCharAlphaA';
function IsCharAlphaW; external user32 name 'IsCharAlphaW';
function IsCharAlpha; external user32 name 'IsCharAlpha'+_X;
function IsCharAlphaNumericA; external user32 name 'IsCharAlphaNumericA';
function IsCharAlphaNumericW; external user32 name 'IsCharAlphaNumericW';
function IsCharAlphaNumeric; external user32 name 'IsCharAlphaNumeric'+_X;
function IsCharLowerA; external user32 name 'IsCharLowerA';
function IsCharLowerW; external user32 name 'IsCharLowerW';
function IsCharLower; external user32 name 'IsCharLower'+_X;
function IsCharUpperA; external user32 name 'IsCharUpperA';
function IsCharUpperW; external user32 name 'IsCharUpperW';
function IsCharUpper; external user32 name 'IsCharUpper'+_X;
function IsChild; external user32 name 'IsChild';
function IsClipboardFormatAvailable; external user32 name 'IsClipboardFormatAvailable';
function IsDialogMessageA; external user32 name 'IsDialogMessageA';
function IsDialogMessageW; external user32 name 'IsDialogMessageW';
function IsDialogMessage; external user32 name 'IsDialogMessage'+_X;
function IsDlgButtonChecked; external user32 name 'IsDlgButtonChecked';
function IsIconic; external user32 name 'IsIconic';
function IsMenu; external user32 name 'IsMenu';
function IsRectEmpty; external user32 name 'IsRectEmpty';
function IsWindow; external user32 name 'IsWindow';
function IsWindowEnabled; external user32 name 'IsWindowEnabled';
function IsWindowUnicode; external user32 name 'IsWindowUnicode';
function IsWindowVisible; external user32 name 'IsWindowVisible';
function IsZoomed; external user32 name 'IsZoomed';
function KillTimer; external user32 name 'KillTimer';
function LoadAcceleratorsA; external user32 name 'LoadAcceleratorsA';
function LoadAcceleratorsW; external user32 name 'LoadAcceleratorsW';
function LoadAccelerators; external user32 name 'LoadAccelerators'+_X;
function LoadBitmapA; external user32 name 'LoadBitmapA';
function LoadBitmapW; external user32 name 'LoadBitmapW';
function LoadBitmap; external user32 name 'LoadBitmap'+_X;
function LoadCursorA; external user32 name 'LoadCursorA';
function LoadCursorW; external user32 name 'LoadCursorW';
function LoadCursor; external user32 name 'LoadCursor'+_X;
function LoadCursorFromFileA; external user32 name 'LoadCursorFromFileA';
function LoadCursorFromFileW; external user32 name 'LoadCursorFromFileW';
function LoadCursorFromFile; external user32 name 'LoadCursorFromFile'+_X;
function LoadIconA; external user32 name 'LoadIconA';
function LoadIconW; external user32 name 'LoadIconW';
function LoadIcon; external user32 name 'LoadIcon'+_X;
function LoadImageA; external user32 name 'LoadImageA';
function LoadImageW; external user32 name 'LoadImageW';
function LoadImage; external user32 name 'LoadImage'+_X;
function LoadKeyboardLayoutA; external user32 name 'LoadKeyboardLayoutA';
function LoadKeyboardLayoutW; external user32 name 'LoadKeyboardLayoutW';
function LoadKeyboardLayout; external user32 name 'LoadKeyboardLayout'+_X;
function LoadMenuA; external user32 name 'LoadMenuA';
function LoadMenuW; external user32 name 'LoadMenuW';
function LoadMenu; external user32 name 'LoadMenu'+_X;
function LoadMenuIndirectA; external user32 name 'LoadMenuIndirectA';
function LoadMenuIndirectW; external user32 name 'LoadMenuIndirectW';
function LoadMenuIndirect; external user32 name 'LoadMenuIndirect'+_X;
function LoadStringA; external user32 name 'LoadStringA';
function LoadStringW; external user32 name 'LoadStringW';
function LoadString; external user32 name 'LoadString'+_X;
function LockWindowUpdate; external user32 name 'LockWindowUpdate';
function LockWorkStation; external user32 name 'LockWorkStation';
function LookupIconIdFromDirectory; external user32 name 'LookupIconIdFromDirectory';
function LookupIconIdFromDirectoryEx; external user32 name 'LookupIconIdFromDirectoryEx';
function MapDialogRect; external user32 name 'MapDialogRect';
function MapVirtualKeyA; external user32 name 'MapVirtualKeyA';
function MapVirtualKeyW; external user32 name 'MapVirtualKeyW';
function MapVirtualKey; external user32 name 'MapVirtualKey'+_X;
function MapVirtualKeyExA; external user32 name 'MapVirtualKeyExA';
function MapVirtualKeyExW; external user32 name 'MapVirtualKeyExW';
function MapVirtualKeyEx; external user32 name 'MapVirtualKeyEx'+_X;
function MapWindowPoints; external user32 name 'MapWindowPoints';
function MenuItemFromPoint; external user32 name 'MenuItemFromPoint';
function MessageBeep; external user32 name 'MessageBeep';
function MessageBoxA; external user32 name 'MessageBoxA';
function MessageBoxW; external user32 name 'MessageBoxW';
function MessageBox; external user32 name 'MessageBox'+_X;
function MessageBoxExA; external user32 name 'MessageBoxExA';
function MessageBoxExW; external user32 name 'MessageBoxExW';
function MessageBoxEx; external user32 name 'MessageBoxEx'+_X;
function MessageBoxIndirectA; external user32 name 'MessageBoxIndirectA';
function MessageBoxIndirectW; external user32 name 'MessageBoxIndirectW';
function MessageBoxIndirect; external user32 name 'MessageBoxIndirect'+_X;
function ModifyMenuA; external user32 name 'ModifyMenuA';
function ModifyMenuW; external user32 name 'ModifyMenuW';
function ModifyMenu; external user32 name 'ModifyMenu'+_X;
function MoveWindow; external user32 name 'MoveWindow';
function MsgWaitForMultipleObjects; external user32 name 'MsgWaitForMultipleObjects';
function MsgWaitForMultipleObjectsEx; external user32 name 'MsgWaitForMultipleObjectsEx';
procedure NotifyWinEvent; external user32 name 'NotifyWinEvent';
function OemKeyScan; external user32 name 'OemKeyScan';
function OemToAnsi; external user32 name 'OemToChar'+_X;
function OemToAnsiBuff; external user32 name 'OemToCharBuff'+_X;
function OemToCharA; external user32 name 'OemToCharA';
function OemToCharW; external user32 name 'OemToCharW';
function OemToChar; external user32 name 'OemToChar'+_X;
function OemToCharBuffA; external user32 name 'OemToCharBuffA';
function OemToCharBuffW; external user32 name 'OemToCharBuffW';
function OemToCharBuff; external user32 name 'OemToCharBuff'+_X;
function OffsetRect; external user32 name 'OffsetRect';
function OpenClipboard; external user32 name 'OpenClipboard';
function OpenDesktopA; external user32 name 'OpenDesktopA';
function OpenDesktopW; external user32 name 'OpenDesktopW';
function OpenDesktop; external user32 name 'OpenDesktop'+_X;
function OpenIcon; external user32 name 'OpenIcon';
function OpenInputDesktop; external user32 name 'OpenInputDesktop';
function OpenWindowStationA; external user32 name 'OpenWindowStationA';
function OpenWindowStationW; external user32 name 'OpenWindowStationW';
function OpenWindowStation; external user32 name 'OpenWindowStation'+_X;
function PackDDElParam; external user32 name 'PackDDElParam';
function PaintDesktop; external user32 name 'PaintDesktop';
function PeekMessageA; external user32 name 'PeekMessageA';
function PeekMessageW; external user32 name 'PeekMessageW';
function PeekMessage; external user32 name 'PeekMessage'+_X;
function PostMessageA; external user32 name 'PostMessageA';
function PostMessageW; external user32 name 'PostMessageW';
function PostMessage; external user32 name 'PostMessage'+_X;
procedure PostQuitMessage; external user32 name 'PostQuitMessage';
function PostThreadMessageA; external user32 name 'PostThreadMessageA';
function PostThreadMessageW; external user32 name 'PostThreadMessageW';
function PostThreadMessage; external user32 name 'PostThreadMessage'+_X;
function PtInRect; external user32 name 'PtInRect';
function RealChildWindowFromPoint; external user32 name 'RealChildWindowFromPoint';
function RealGetWindowClassA; external user32 name 'RealGetWindowClassA';
function RealGetWindowClassW; external user32 name 'RealGetWindowClassW';
function RealGetWindowClass; external user32 name 'RealGetWindowClass'+_X;
function RedrawWindow; external user32 name 'RedrawWindow';
function RegisterClassA; external user32 name 'RegisterClassA';
function RegisterClassW; external user32 name 'RegisterClassW';
function RegisterClass; external user32 name 'RegisterClass'+_X;
function RegisterClassExA; external user32 name 'RegisterClassExA';
function RegisterClassExW; external user32 name 'RegisterClassExW';
function RegisterClassEx; external user32 name 'RegisterClassEx'+_X;
function RegisterClipboardFormatA; external user32 name 'RegisterClipboardFormatA';
function RegisterClipboardFormatW; external user32 name 'RegisterClipboardFormatW';
function RegisterClipboardFormat; external user32 name 'RegisterClipboardFormat'+_X;
function RegisterDeviceNotificationA; external user32 name 'RegisterDeviceNotificationA';
function RegisterDeviceNotificationW; external user32 name 'RegisterDeviceNotificationW';
function RegisterDeviceNotification; external user32 name 'RegisterDeviceNotification'+_X;
function RegisterHotKey; external user32 name 'RegisterHotKey';
function RegisterWindowMessageA; external user32 name 'RegisterWindowMessageA';
function RegisterWindowMessageW; external user32 name 'RegisterWindowMessageW';
function RegisterWindowMessage; external user32 name 'RegisterWindowMessage'+_X;
function ReleaseCapture; external user32 name 'ReleaseCapture';
function ReleaseDC; external user32 name 'ReleaseDC';
function RemoveMenu; external user32 name 'RemoveMenu';
function RemovePropA; external user32 name 'RemovePropA';
function RemovePropW; external user32 name 'RemovePropW';
function RemoveProp; external user32 name 'RemoveProp'+_X;
function ReplyMessage; external user32 name 'ReplyMessage';
function ReuseDDElParam; external user32 name 'ReuseDDElParam';
function ScreenToClient; external user32 name 'ScreenToClient';
function ScrollDC; external user32 name 'ScrollDC';
function ScrollWindow; external user32 name 'ScrollWindow';
function ScrollWindowEx; external user32 name 'ScrollWindowEx';
function SendDlgItemMessageA; external user32 name 'SendDlgItemMessageA';
function SendDlgItemMessageW; external user32 name 'SendDlgItemMessageW';
function SendDlgItemMessage; external user32 name 'SendDlgItemMessage'+_X;
function SendInput; external user32 name 'SendInput';
function SendMessageA; external user32 name 'SendMessageA';
function SendMessageW; external user32 name 'SendMessageW';
function SendMessage; external user32 name 'SendMessage'+_X;
function SendMessageCallbackA; external user32 name 'SendMessageCallbackA';
function SendMessageCallbackW; external user32 name 'SendMessageCallbackW';
function SendMessageCallback; external user32 name 'SendMessageCallback'+_X;
function SendMessageTimeoutA; external user32 name 'SendMessageTimeoutA';
function SendMessageTimeoutW; external user32 name 'SendMessageTimeoutW';
function SendMessageTimeout; external user32 name 'SendMessageTimeout'+_X;
function SendNotifyMessageA; external user32 name 'SendNotifyMessageA';
function SendNotifyMessageW; external user32 name 'SendNotifyMessageW';
function SendNotifyMessage; external user32 name 'SendNotifyMessage'+_X;
function SetActiveWindow; external user32 name 'SetActiveWindow';
function SetCapture; external user32 name 'SetCapture';
function SetCaretBlinkTime; external user32 name 'SetCaretBlinkTime';
function SetCaretPos; external user32 name 'SetCaretPos';
function SetClassLongA; external user32 name 'SetClassLongA';
function SetClassLongW; external user32 name 'SetClassLongW';
function SetClassLong; external user32 name 'SetClassLong'+_X;
function SetClassWord; external user32 name 'SetClassWord';
function SetClipboardData; external user32 name 'SetClipboardData';
function SetClipboardViewer; external user32 name 'SetClipboardViewer';
function SetCursor; external user32 name 'SetCursor';
function SetCursorPos; external user32 name 'SetCursorPos';
procedure SetDebugErrorLevel; external user32 name 'SetDebugErrorLevel';
function SetDlgItemInt; external user32 name 'SetDlgItemInt';
function SetDlgItemTextA; external user32 name 'SetDlgItemTextA';
function SetDlgItemTextW; external user32 name 'SetDlgItemTextW';
function SetDlgItemText; external user32 name 'SetDlgItemText'+_X;
function SetDoubleClickTime; external user32 name 'SetDoubleClickTime';
function SetFocus; external user32 name 'SetFocus';
function SetForegroundWindow; external user32 name 'SetForegroundWindow';
function SetKeyboardState; external user32 name 'SetKeyboardState';
procedure SetLastErrorEx; external user32 name 'SetLastErrorEx';
function SetMenu; external user32 name 'SetMenu';
function SetMenuContextHelpId; external user32 name 'SetMenuContextHelpId';
function SetMenuDefaultItem; external user32 name 'SetMenuDefaultItem';
function SetMenuInfo; external user32 name 'SetMenuInfo';
function SetMenuItemBitmaps; external user32 name 'SetMenuItemBitmaps';
function SetMenuItemInfoA; external user32 name 'SetMenuItemInfoA';
function SetMenuItemInfoW; external user32 name 'SetMenuItemInfoW';
function SetMenuItemInfo; external user32 name 'SetMenuItemInfo'+_X;
function SetMessageExtraInfo; external user32 name 'SetMessageExtraInfo';
function SetMessageQueue; external user32 name 'SetMessageQueue';
function SetParent; external user32 name 'SetParent';
function SetProcessWindowStation; external user32 name 'SetProcessWindowStation';
function SetPropA; external user32 name 'SetPropA';
function SetPropW; external user32 name 'SetPropW';
function SetProp; external user32 name 'SetProp'+_X;
function SetRect; external user32 name 'SetRect';
function SetRectEmpty; external user32 name 'SetRectEmpty';
function SetScrollInfo; external user32 name 'SetScrollInfo';
function SetScrollPos; external user32 name 'SetScrollPos';
function SetScrollRange; external user32 name 'SetScrollRange';
function SetSysColors; external user32 name 'SetSysColors';
function SetSystemCursor; external user32 name 'SetSystemCursor';
function SetThreadDesktop; external user32 name 'SetThreadDesktop';
function SetTimer; external user32 name 'SetTimer';
function SetUserObjectInformationA; external user32 name 'SetUserObjectInformationA';
function SetUserObjectInformationW; external user32 name 'SetUserObjectInformationW';
function SetUserObjectInformation; external user32 name 'SetUserObjectInformation'+_X;
function SetUserObjectSecurity; external user32 name 'SetUserObjectSecurity';
function SetWindowContextHelpId; external user32 name 'SetWindowContextHelpId';
function SetWindowLongA; external user32 name 'SetWindowLongA';
function SetWindowLongW; external user32 name 'SetWindowLongW';
function SetWindowLong; external user32 name 'SetWindowLong'+_X;
function SetWindowPlacement; external user32 name 'SetWindowPlacement';
function SetWindowPos; external user32 name 'SetWindowPos';
function SetWindowTextA; external user32 name 'SetWindowTextA';
function SetWindowTextW; external user32 name 'SetWindowTextW';
function SetWindowText; external user32 name 'SetWindowText'+_X;
function SetWindowWord; external user32 name 'SetWindowWord';
function SetWindowsHookA; external user32 name 'SetWindowsHookA';
function SetWindowsHookW; external user32 name 'SetWindowsHookW';
function SetWindowsHook; external user32 name 'SetWindowsHook'+_X;
function SetWindowsHookExA; external user32 name 'SetWindowsHookExA';
function SetWindowsHookExW; external user32 name 'SetWindowsHookExW';
function SetWindowsHookEx; external user32 name 'SetWindowsHookEx'+_X;
function SetWindowRgn; external user32 name 'SetWindowRgn';
function SetWinEventHook; external user32 name 'SetWinEventHook';
function ShowCaret; external user32 name 'ShowCaret';
function ShowCursor; external user32 name 'ShowCursor';
function ShowOwnedPopups; external user32 name 'ShowOwnedPopups';
function ShowScrollBar; external user32 name 'ShowScrollBar';
function ShowWindow; external user32 name 'ShowWindow';
function AnimateWindow; external user32 name 'AnimateWindow';
function ShowWindowAsync; external user32 name 'ShowWindowAsync';
function SubtractRect; external user32 name 'SubtractRect';
function SwapMouseButton; external user32 name 'SwapMouseButton';
function SwitchDesktop; external user32 name 'SwitchDesktop';
function SystemParametersInfoA; external user32 name 'SystemParametersInfoA';
function SystemParametersInfoW; external user32 name 'SystemParametersInfoW';
function SystemParametersInfo; external user32 name 'SystemParametersInfo'+_X;
function TabbedTextOutA; external user32 name 'TabbedTextOutA';
function TabbedTextOutW; external user32 name 'TabbedTextOutW';
function TabbedTextOut; external user32 name 'TabbedTextOut'+_X;
function TileWindows; external user32 name 'TileWindows';
function ToAscii; external user32 name 'ToAscii';
function ToAsciiEx; external user32 name 'ToAsciiEx';
function ToUnicode; external user32 name 'ToUnicode';
function ToUnicodeEx; external user32 name 'ToUnicodeEx';
function TrackMouseEvent; external user32 name 'TrackMouseEvent';
function TrackPopupMenu; external user32 name 'TrackPopupMenu';
function TrackPopupMenuEx; external user32 name 'TrackPopupMenuEx';
function TranslateAcceleratorA; external user32 name 'TranslateAcceleratorA';
function TranslateAcceleratorW; external user32 name 'TranslateAcceleratorW';
function TranslateAccelerator; external user32 name 'TranslateAccelerator'+_X;
function TranslateMDISysAccel; external user32 name 'TranslateMDISysAccel';
function TranslateMessage; external user32 name 'TranslateMessage';
function UnhookWindowsHook; external user32 name 'UnhookWindowsHook';
function UnhookWindowsHookEx; external user32 name 'UnhookWindowsHookEx';
function UnhookWinEvent; external user32 name 'UnhookWinEvent';
function UnionRect; external user32 name 'UnionRect';
function UnloadKeyboardLayout; external user32 name 'UnloadKeyboardLayout';
function UnpackDDElParam; external user32 name 'UnpackDDElParam';
function UnregisterClassA; external user32 name 'UnregisterClassA';
function UnregisterClassW; external user32 name 'UnregisterClassW';
function UnregisterClass; external user32 name 'UnregisterClass'+_X;
function UnregisterDeviceNotification; external user32 name 'UnregisterDeviceNotification';
function UnregisterHotKey; external user32 name 'UnregisterHotKey';
function UpdateWindow; external user32 name 'UpdateWindow';
function UserHandleGrantAccess; external user32 name 'UserHandleGrantAccess';
function ValidateRect; external user32 name 'ValidateRect';
function ValidateRgn; external user32 name 'ValidateRgn';
function VkKeyScanA; external user32 name 'VkKeyScanA';
function VkKeyScanW; external user32 name 'VkKeyScanW';
function VkKeyScan; external user32 name 'VkKeyScan'+_X;
function VkKeyScanExA; external user32 name 'VkKeyScanExA';
function VkKeyScanExW; external user32 name 'VkKeyScanExW';
function VkKeyScanEx; external user32 name 'VkKeyScanEx'+_X;
function WaitForInputIdle; external user32 name 'WaitForInputIdle';
function WaitMessage; external user32 name 'WaitMessage';
function WinHelpA; external user32 name 'WinHelpA';
function WinHelpW; external user32 name 'WinHelpW';
function WinHelp; external user32 name 'WinHelp'+_X;
function WindowFromDC; external user32 name 'WindowFromDC';
function WindowFromPoint; external user32 name 'WindowFromPoint';
procedure keybd_event; external user32 name 'keybd_event';
procedure mouse_event; external user32 name 'mouse_event';
function wsprintfA; external user32 name 'wsprintfA';
function wsprintfW; external user32 name 'wsprintfW';
function wsprintf; external user32 name 'wsprintf'+_X;
function wvsprintfA; external user32 name 'wvsprintfA';
function wvsprintfW; external user32 name 'wvsprintfW';
function wvsprintf; external user32 name 'wvsprintf'+_X;

{ Externals from wintrust.dll }

function WinLoadTrustProvider; external wintrust name 'WinLoadTrustProvider';
function WinSubmitCertificate; external wintrust name 'WinSubmitCertificate';
function WinVerifyTrust; external wintrust name 'WinVerifyTrust';

{$ifdef b64}
function GetWindowLongPtr; external user32 name 'GetWindowLongPtr'+_X;
function GetWindowLongPtrA; external user32 name 'GetWindowLongPtrA';
function GetWindowLongPtrW; external user32 name 'GetWindowLongPtrW';

function SetWindowLongPtr; external user32 name 'SetWindowLongPtr'+_X;
function SetWindowLongPtrA; external user32 name 'SetWindowLongPtrA';
function SetWindowLongPtrW; external user32 name 'SetWindowLongPtrW';

{$else}

function GetWindowLongPtr; external user32 name 'GetWindowLong'+_X;
function GetWindowLongPtrA; external user32 name 'GetWindowLongA';
function GetWindowLongPtrW; external user32 name 'GetWindowLongW';

function SetWindowLongPtr; external user32 name 'SetWindowLong'+_X;
function SetWindowLongPtrA; external user32 name 'SetWindowLongA';
function SetWindowLongPtrW; external user32 name 'SetWindowLongW';
{$endif b64}


{$ifdef b64}
{$ifdef bFreePascal}
{$else}
function InterlockedIncrement(var Addend: Integer): Integer;
asm
  {!!!Pulsar}
end;

function InterlockedDecrement(var Addend: Integer): Integer;
asm
  {!!!Pulsar}
end;
{$endif bFreePascal}
{$endif b64}


{ Translated from WINDEF.H }

function MakeWord(A, B: Byte): Word;
begin
  Result := A or B shl 8;
end;

function MakeLong(A, B: Word): Longint;
begin
  Result := A or B shl 16;
end;

function HiWord(L: DWORD): Word;
begin
  Result := L shr 16;
end;

function HiByte(W: Word): Byte;
begin
  Result := W shr 8;
end;

{ Translated from WINBASE.H }

function DefineHandleTable(Offset: Word): Bool;
begin
  Result := True;
end;

procedure LimitEmsPages(Kbytes: Longint);
begin
end;

function SetSwapAreaSize(Size: Word): Longint;
begin
  Result := Size;
end;

procedure LockSegment(Segment: THandle);
begin
  GlobalFix(Segment);
end;

procedure UnlockSegment(Segment: THandle);
begin
  GlobalUnfix(Segment);
end;

function GetCurrentTime: Longint;
begin
  Result := GetTickCount;
end;

function Yield: Bool;
begin
  Result := True;
end;

procedure MoveMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
begin
  Move(Source^, Destination^, Length);
end;

procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
begin
  Move(Source^, Destination^, Length);
end;

procedure FillMemory(Destination: Pointer; Length: DWORD; Fill: Byte);
begin
  FillChar(Destination^, Length, Fill);
end;

procedure ZeroMemory(Destination: Pointer; Length: DWORD);
begin
  FillChar(Destination^, Length, 0);
end;

function FreeModule(var hLibModule: HINST): BOOL;
begin
  Result := FreeLibrary(hLibModule);
end;

procedure FreeProcInstance(Proc: FARPROC);
begin
end;

function MakeProcInstance(Proc: FARPROC; Instance: THandle): FARPROC;
begin
  Result := Proc;
end;

function GlobalLRUNewest(h: THandle): THandle;
begin
  Result := h;
end;

function GlobalLRUOldest(h: THandle): THandle;
begin
  Result := h;
end;

function GlobalDiscard(h: THandle): THandle;
begin
 Result := GlobalReAlloc(h, 0, GMEM_MOVEABLE);
end;

function LocalDiscard(h: THandle): THandle;
begin
 Result := LocalReAlloc(h, 0, LMEM_MOVEABLE);
end;

function GetFreeSpace(w: Word): DWORD;
begin
  Result := $100000;
end;

function UnlockResource(hResData: THandle): BOOL;
begin
  Result := False;
end;


function GlobalAllocPtr(Flags :Integer; Bytes :Longint) :Pointer;
var
  hMem :HGLOBAL;
begin
  hMem := GlobalAlloc(Flags, Bytes);
  Result := GlobalLock(hMem);
end;

function GlobalReAllocPtr(P :Pointer; Bytes :LongInt; Flags :Integer) :Pointer;
var
  hMem: HGLOBAL;
begin
  hMem := GlobalHandle(P);
  GlobalUnlock(hMem);
  hMem := GlobalReAlloc(hMem, Bytes, Flags);
  Result := GlobalLock(hMem);
end;

function GlobalFreePtr(P: Pointer): THandle;
var
  hMem: HGLOBAL;
begin
  hMem := GlobalHandle(P);
  GlobalUnlock(hMem);
  Result := GlobalFree(hMem);
end;


{ Translated from WINERROR.H }

function Succeeded(Status: HRESULT): BOOL;
begin
  Result := Status and HRESULT($80000000) = 0;
end;

function Failed(Status: HRESULT): BOOL;
begin
  Result := Status and HRESULT($80000000) <> 0;
end;

function IsError(Status: HRESULT): BOOL;
begin
  Result := (Status shr 31) = SEVERITY_ERROR;
end;

function HResultCode(hr: HRESULT): Integer;
begin
  Result := hr and $0000FFFF;
end;

function HResultFacility(hr: HRESULT): Integer;
begin
  Result := (hr shr 16) and $00001FFF;
end;

function HResultSeverity(hr: HRESULT): Integer;
begin
  Result := (hr shr 31) and $00000001;
end;

function MakeResult(sev, fac, code: Integer): HResult;
begin
  Result := (sev shl 31) or (fac shl 16) or code;
end;

function HResultFromWin32(x: Integer): HRESULT;
begin
  Result := x;
  if Result <> 0 then
    Result := ((Result and $0000FFFF) or
      (FACILITY_WIN32 shl 16) or HRESULT($80000000));
end;

function HResultFromNT(x: Integer): HRESULT;
begin
  Result := x or FACILITY_NT_BIT;
end;


{ Translated from WINGDI.H }

function MakeROP4(fore, back: DWORD): DWORD;
begin
  Result := ((back shl 8) and DWORD($FF000000)) or fore;
end;

function GetKValue(cmyk: COLORREF): Byte;
begin
  Result := Byte(cmyk);
end;

function GetYValue(cmyk: COLORREF): Byte;
begin
  Result := Byte(cmyk shr 8);
end;

function GetMValue(cmyk: COLORREF): Byte;
begin
  Result := Byte(cmyk shr 16);
end;

function GetCValue(cmyk: COLORREF): Byte;
begin
  Result := Byte(cmyk shr 24);
end;

function CMYK(c, m, y, k: Byte): COLORREF;
begin
  Result := (k or (y shl 8) or (m shl 16) or (c shl 24));
end;

function RGB(r, g, b: Byte): COLORREF;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

function PaletteRGB(r, g, b: Byte): COLORREF;
begin
  Result := $02000000 or RGB(r,g,b);
end;

function PaletteIndex(i: Word): COLORREF;
begin
  Result := $01000000 or i;
end;

function GetRValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb);
end;

function GetGValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb shr 8);
end;

function GetBValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb shr 16);
end;


{ Translated from WINUSER.H }

function SmallPointToPoint(const P: TSmallPoint): TPoint;
begin
  Result.X := P.X;
  Result.Y := P.Y;
end;

function PointToSmallPoint(const P: TPoint): TSmallPoint;
begin
  Result.X := P.X;
  Result.Y := P.Y;
end;

function MakeWParam(l, h: Word): WPARAM;
begin
  Result := MakeLong(l, h);
end;

function MakeLParam(l, h: Word): LPARAM;
begin
  Result := MakeLong(l, h);
end;

function MakeLResult(l, h: Word): LRESULT;
begin
  Result := MakeLong(l, h);
end;

function ExitWindows(dwReserved: DWORD; Code: Word): BOOL;
begin
  Result := ExitWindowsEx(EWX_LOGOFF, 0);
end;

function PostAppMessageA(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessageA(idThread, Msg, wParam, lParam)
end;
function PostAppMessageW(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessageW(idThread, Msg, wParam, lParam)
end;
function PostAppMessage(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessage(idThread, Msg, wParam, lParam)
end;

function CreateWindowA(lpClassName: PAnsiChar; lpWindowName: PAnsiChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
begin
  Result := CreateWindowExA(0, lpClassName, lpWindowName, dwStyle, X, Y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;
function CreateWindowW(lpClassName: PWideChar; lpWindowName: PWideChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
begin
  Result := CreateWindowExW(0, lpClassName, lpWindowName, dwStyle, X, Y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;
function CreateWindow(lpClassName: PTChar; lpWindowName: PTChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
begin
  Result := CreateWindowEx(0, lpClassName, lpWindowName, dwStyle, X, Y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;

function CreateDialogA(hInstance: HINST; lpTemplateName: PAnsiChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
begin
  Result := CreateDialogParamA(hInstance, lpTemplateName, hWndParent,
    lpDialogFunc, 0);
end;
function CreateDialogW(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
begin
  Result := CreateDialogParamW(hInstance, lpTemplateName, hWndParent,
    lpDialogFunc, 0);
end;
function CreateDialog(hInstance: HINST; lpTemplateName: PTChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
begin
  Result := CreateDialogParam(hInstance, lpTemplateName, hWndParent,
    lpDialogFunc, 0);
end;

function CreateDialogIndirectA(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
begin
  Result := CreateDialogIndirectParamA(hInstance, lpTemplate, hWndParent,
    lpDialogFunc, 0);
end;
function CreateDialogIndirectW(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
begin
  Result := CreateDialogIndirectParamW(hInstance, lpTemplate, hWndParent,
    lpDialogFunc, 0);
end;
function CreateDialogIndirect(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): HWND;
begin
  Result := CreateDialogIndirectParam(hInstance, lpTemplate, hWndParent,
    lpDialogFunc, 0);
end;

function DialogBoxA(hInstance: HINST; lpTemplate: PAnsiChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
begin
  Result := DialogBoxParamA(hInstance, lpTemplate, hWndParent,
    lpDialogFunc, 0);
end;
function DialogBoxW(hInstance: HINST; lpTemplate: PWideChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
begin
  Result := DialogBoxParamW(hInstance, lpTemplate, hWndParent,
    lpDialogFunc, 0);
end;
function DialogBox(hInstance: HINST; lpTemplate: PTChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
begin
  Result := DialogBoxParam(hInstance, lpTemplate, hWndParent,
    lpDialogFunc, 0);
end;

function DialogBoxIndirectA(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
begin
  Result := DialogBoxIndirectParamA(hInstance, lpDialogTemplate, hWndParent,
    lpDialogFunc, 0);
end;
function DialogBoxIndirectW(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
begin
  Result := DialogBoxIndirectParamW(hInstance, lpDialogTemplate, hWndParent,
    lpDialogFunc, 0);
end;
function DialogBoxIndirect(hInstance: HINST; const lpDialogTemplate: TDlgTemplate;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
begin
  Result := DialogBoxIndirectParam(hInstance, lpDialogTemplate, hWndParent,
    lpDialogFunc, 0);
end;

function EnumTaskWindows(hTask: THandle; lpfn: FARPROC; lParam: LPARAM): BOOL;
begin
  Result := EnumThreadWindows(DWORD(hTask), lpfn, lParam);
end;

function GetWindowTask(hWnd: HWND): THandle;
begin
  Result := THandle(GetWindowThreadProcessId(hWnd, nil));
end;

function DefHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM; phhk: FARPROC): LRESULT;
begin
  Result := CallNextHookEx(HHOOK(phhk), nCode, wParam, lParam);
end;

function HwndMSWheel(var puiMsh_MsgMouseWheel, puiMsh_Msg3DSupport,
  puiMsh_MsgScrollLines: UINT; var pf3DSupport: BOOL;
  var piScrollLines: Integer): HWND;
begin
  Result := FindWindow(MSH_WHEELMODULE_CLASS, MSH_WHEELMODULE_TITLE);
  puiMsh_MsgMouseWheel := RegisterWindowMessage(MSH_MOUSEWHEEL);
  puiMsh_Msg3DSupport := RegisterWindowMessage(MSH_WHEELSUPPORT);
  puiMsh_MsgScrollLines := RegisterWindowMessage(MSH_SCROLL_LINES);
  if (puiMsh_Msg3DSupport <> 0) and (Result <> 0) then
    pf3DSupport := BOOL(SendMessage(Result, puiMsh_Msg3DSupport, 0, 0))
  else
    pf3DSupport := False;  // default to FALSE
  if (puiMsh_MsgScrollLines <> 0)  and (Result <> 0) then
    piScrollLines := SendMessage(Result, puiMsh_MsgScrollLines, 0, 0)
  else
    piScrollLines := 3;  // default
end;


end.



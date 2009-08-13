{$I Defines.inc}

{*******************************************************}
{                                                       }
{       Borland Delphi Run-time Library                 }
{       Win32 Shell API Interface Unit                  }
{                                                       }
{       Copyright (c) 1985-1999, Microsoft Corporation  }
{                                                       }
{       Translator: Inprise Corporation                 }
{                                                       }
{*******************************************************}

unit ShellAPI;

{$WEAKPACKAGEUNIT}

{$ifdef bFreePascal}
 {$PACKRECORDS C}
{$endif bFreePascal}

interface

uses MixTypes, Windows;

type
  HDROP = Longint;
  PPWideChar = ^PWideChar;

function DragQueryFileA(Drop: HDROP; FileIndex: UINT; FileName: PAnsiChar; cb: UINT): UINT; stdcall;
function DragQueryFileW(Drop: HDROP; FileIndex: UINT; FileName: PWideChar; cb: UINT): UINT; stdcall;
function DragQueryFile(Drop: HDROP; FileIndex: UINT; FileName: PTChar; cb: UINT): UINT; stdcall;
function DragQueryPoint(Drop: HDROP; var Point: TPoint): BOOL; stdcall;
procedure DragFinish(Drop: HDROP); stdcall;
procedure DragAcceptFiles(Wnd: HWND; Accept: BOOL); stdcall;
function ShellExecuteA(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PAnsiChar; ShowCmd: Integer): HINST; stdcall;
function ShellExecuteW(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PWideChar; ShowCmd: Integer): HINST; stdcall;
function ShellExecute(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PTChar; ShowCmd: Integer): HINST; stdcall;
function FindExecutableA(FileName, Directory: PAnsiChar; Result: PAnsiChar): HINST; stdcall;
function FindExecutableW(FileName, Directory: PWideChar; Result: PWideChar): HINST; stdcall;
function FindExecutable(FileName, Directory: PTChar; Result: PTChar): HINST; stdcall;
function CommandLineToArgvW(lpCmdLine: LPCWSTR; var pNumArgs: Integer): PPWideChar; stdcall;
function ShellAboutA(Wnd: HWND; szApp, szOtherStuff: PAnsiChar; Icon: HICON): Integer; stdcall;
function ShellAboutW(Wnd: HWND; szApp, szOtherStuff: PWideChar; Icon: HICON): Integer; stdcall;
function ShellAbout(Wnd: HWND; szApp, szOtherStuff: PTChar; Icon: HICON): Integer; stdcall;
function DuplicateIcon(hInst: HINST; Icon: HICON): HICON; stdcall;
function ExtractAssociatedIconA(hInst: HINST; lpIconPath: PAnsiChar;
  var lpiIcon: Word): HICON; stdcall;
function ExtractAssociatedIconW(hInst: HINST; lpIconPath: PWideChar;
  var lpiIcon: Word): HICON; stdcall;
function ExtractAssociatedIcon(hInst: HINST; lpIconPath: PTChar;
  var lpiIcon: Word): HICON; stdcall;
function ExtractIconA(hInst: HINST; lpszExeFileName: PAnsiChar;
  nIconIndex: UINT): HICON; stdcall;
function ExtractIconW(hInst: HINST; lpszExeFileName: PWideChar;
  nIconIndex: UINT): HICON; stdcall;
function ExtractIcon(hInst: HINST; lpszExeFileName: PTChar;
  nIconIndex: UINT): HICON; stdcall;

type
  PDragInfoA = ^_DRAGINFOA;
  PDragInfoW = ^_DRAGINFOW;
  PDragInfo = {$ifdef bUnicode}PDragInfoW{$else}PDragInfoA{$endif bUnicode};

  _DRAGINFOA = record
    uSize: UINT;                 { init with SizeOf(DRAGINFO) }
    pt: TPoint;
    fNC: BOOL;
    lpFileList: PAnsiChar;
    grfKeyState: DWORD;
  end;
  _DRAGINFOW = record
    uSize: UINT;                 { init with SizeOf(DRAGINFO) }
    pt: TPoint;
    fNC: BOOL;
    lpFileList: PWideChar;
    grfKeyState: DWORD;
  end;
  _DRAGINFO = {$ifdef bUnicode}_DRAGINFOW{$else}_DRAGINFOA{$endif bUnicode};

  LPDRAGINFOA = PDragInfoA;
  LPDRAGINFOW = PDragInfoW;

  TDragInfoA = _DRAGINFOA;
  TDragInfoW = _DRAGINFOW;

const
{ AppBar stuff }

  ABM_NEW           = $00000000;
  ABM_REMOVE        = $00000001;
  ABM_QUERYPOS      = $00000002;
  ABM_SETPOS        = $00000003;
  ABM_GETSTATE      = $00000004;
  ABM_GETTASKBARPOS = $00000005;
  ABM_ACTIVATE      = $00000006;  { lParam = True/False means activate/deactivate }
  ABM_GETAUTOHIDEBAR = $00000007;
  ABM_SETAUTOHIDEBAR = $00000008;  { this can fail at any time.  MUST check the result
                                     lParam = TRUE/FALSE  Set/Unset
                                     uEdge = what edge }
  ABM_WINDOWPOSCHANGED = $0000009;

{ these are put in the wparam of callback messages }

  ABN_STATECHANGE    = $0000000;
  ABN_POSCHANGED     = $0000001;
  ABN_FULLSCREENAPP  = $0000002;
  ABN_WINDOWARRANGE  = $0000003; { lParam = True means hide }

{ flags for get state }

  ABS_AUTOHIDE    = $0000001;
  ABS_ALWAYSONTOP = $0000002;

  ABE_LEFT        = 0;
  ABE_TOP         = 1;
  ABE_RIGHT       = 2;
  ABE_BOTTOM      = 3;

type
  PAppBarData = ^TAppBarData;
  _AppBarData = record
    cbSize: DWORD;
    hWnd: HWND;
    uCallbackMessage: UINT;
    uEdge: UINT;
    rc: TRect;
    lParam: LPARAM; { message specific }
  end;
  TAppBarData = _AppBarData;
  APPBARDATA = _AppBarData;

function SHAppBarMessage(dwMessage: DWORD; var pData: TAppBarData): UINT; stdcall;


function DoEnvironmentSubstA(szString: PAnsiChar; cbString: UINT): DWORD; stdcall;
function DoEnvironmentSubstW(szString: PWideChar; cbString: UINT): DWORD; stdcall;
function DoEnvironmentSubst(szString: PTChar; cbString: UINT): DWORD; stdcall;
function ExtractIconExA(lpszFile: PAnsiChar; nIconIndex: Integer;
  var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall;
function ExtractIconExW(lpszFile: PWideChar; nIconIndex: Integer;
  var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall;
function ExtractIconEx(lpszFile: PTChar; nIconIndex: Integer;
  var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall;


{ Shell File Operations }

const
  FO_MOVE           = $0001;
  FO_COPY           = $0002;
  FO_DELETE         = $0003;
  FO_RENAME         = $0004;

  FOF_MULTIDESTFILES         = $0001;
  FOF_CONFIRMMOUSE           = $0002;
  FOF_SILENT                 = $0004;  { don't create progress/report }
  FOF_RENAMEONCOLLISION      = $0008;
  FOF_NOCONFIRMATION         = $0010;  { Don't prompt the user. }
  FOF_WANTMAPPINGHANDLE      = $0020;  { Fill in SHFILEOPSTRUCT.hNameMappings
                                         Must be freed using SHFreeNameMappings }
  FOF_ALLOWUNDO              = $0040;
  FOF_FILESONLY              = $0080;  { on *.*, do only files }
  FOF_SIMPLEPROGRESS         = $0100;  { means don't show names of files }
  FOF_NOCONFIRMMKDIR         = $0200;  { don't confirm making any needed dirs }
  FOF_NOERRORUI              = $0400;  { don't put up error UI }

type
  FILEOP_FLAGS = Word;

const
  PO_DELETE       = $0013;  { printer is being deleted }
  PO_RENAME       = $0014;  { printer is being renamed }
  PO_PORTCHANGE   = $0020;  { port this printer connected to is being changed
                              if this id is set, the strings received by
                              the copyhook are a doubly-null terminated
                              list of strings.  The first is the printer
                              name and the second is the printer port. }
  PO_REN_PORT     = $0034;  { PO_RENAME and PO_PORTCHANGE at same time. }

{ no POF_ flags currently defined }

type
  PRINTEROP_FLAGS = Word;

{ implicit parameters are:
      if pFrom or pTo are unqualified names the current directories are
      taken from the global current drive/directory settings managed
      by Get/SetCurrentDrive/Directory

      the global confirmation settings }

  PSHFileOpStructA = ^TSHFileOpStructA;
  PSHFileOpStructW = ^TSHFileOpStructW;
  PSHFileOpStruct = {$ifdef bUnicode}PSHFileOpStructW{$else}PSHFileOpStructA{$endif bUnicode};

  _SHFILEOPSTRUCTA = packed record
    Wnd: HWND;
    wFunc: UINT;
    pFrom: PAnsiChar;
    pTo: PAnsiChar;
    fFlags: FILEOP_FLAGS;
    fAnyOperationsAborted: BOOL;
    hNameMappings: Pointer;
    lpszProgressTitle: PAnsiChar; { only used if FOF_SIMPLEPROGRESS }
  end;
  _SHFILEOPSTRUCTW = packed record
    Wnd: HWND;
    wFunc: UINT;
    pFrom: PWideChar;
    pTo: PWideChar;
    fFlags: FILEOP_FLAGS;
    fAnyOperationsAborted: BOOL;
    hNameMappings: Pointer;
    lpszProgressTitle: PWideChar; { only used if FOF_SIMPLEPROGRESS }
  end;
  _SHFILEOPSTRUCT = {$ifdef bUnicode}_SHFILEOPSTRUCTW{$else}_SHFILEOPSTRUCTA{$endif bUnicode};

  TSHFileOpStructA = _SHFILEOPSTRUCTA;
  TSHFileOpStructW = _SHFILEOPSTRUCTW;
  TSHFileOpStruct = {$ifdef bUnicode}TSHFileOpStructW{$else}TSHFileOpStructA{$endif bUnicode};

  SHFILEOPSTRUCTA = _SHFILEOPSTRUCTA;
  SHFILEOPSTRUCTW = _SHFILEOPSTRUCTW;
  SHFILEOPSTRUCT = {$ifdef bUnicode}SHFILEOPSTRUCTW{$else}SHFILEOPSTRUCTA{$endif bUnicode};

function SHFileOperationA(const lpFileOp: TSHFileOpStructA): Integer; stdcall;
function SHFileOperationW(const lpFileOp: TSHFileOpStructW): Integer; stdcall;
function SHFileOperation(const lpFileOp: TSHFileOpStruct): Integer; stdcall;
procedure SHFreeNameMappings(hNameMappings: THandle); stdcall;

type
  PSHNameMappingA = ^TSHNameMappingA;
  PSHNameMappingW = ^TSHNameMappingW;
  PSHNameMapping = {$ifdef bUnicode}PSHNameMappingW{$else}PSHNameMappingA{$endif bUnicode};

  _SHNAMEMAPPINGA = record
    pszOldPath: PAnsiChar;
    pszNewPath: PAnsiChar;
    cchOldPath: Integer;
    cchNewPath: Integer;
  end;
  _SHNAMEMAPPINGW = record
    pszOldPath: PWideChar;
    pszNewPath: PWideChar;
    cchOldPath: Integer;
    cchNewPath: Integer;
  end;
  _SHNAMEMAPPING = {$ifdef bUnicode}_SHNAMEMAPPINGW{$else}_SHNAMEMAPPINGA{$endif bUnicode};

  TSHNameMappingA = _SHNAMEMAPPINGA;
  TSHNameMappingW = _SHNAMEMAPPINGW;
  TSHNameMapping = {$ifdef bUnicode}TSHNameMappingW{$else}TSHNameMappingA{$endif bUnicode};

  SHNAMEMAPPINGA = _SHNAMEMAPPINGA;
  SHNAMEMAPPINGW = _SHNAMEMAPPINGW;
  SHNAMEMAPPING = {$ifdef bUnicode}SHNAMEMAPPINGW{$else}SHNAMEMAPPINGA{$endif bUnicode};


{ ShellExecute() and ShellExecuteEx() error codes }
const
{ regular WinExec() codes }
  SE_ERR_FNF              = 2;       { file not found }
  SE_ERR_PNF              = 3;       { path not found }
  SE_ERR_ACCESSDENIED     = 5;       { access denied }
  SE_ERR_OOM              = 8;       { out of memory }
  SE_ERR_DLLNOTFOUND      = 32;

{ error values for ShellExecute() beyond the regular WinExec() codes }
  SE_ERR_SHARE                    = 26;
  SE_ERR_ASSOCINCOMPLETE          = 27;
  SE_ERR_DDETIMEOUT               = 28;
  SE_ERR_DDEFAIL                  = 29;
  SE_ERR_DDEBUSY                  = 30;
  SE_ERR_NOASSOC                  = 31;

{ Note CLASSKEY overrides CLASSNAME }
  SEE_MASK_CLASSNAME      = $00000001;
  SEE_MASK_CLASSKEY       = $00000003;
{ Note INVOKEIDLIST overrides IDLIST }
  SEE_MASK_IDLIST         = $00000004;
  SEE_MASK_INVOKEIDLIST   = $0000000c;
  SEE_MASK_ICON           = $00000010;
  SEE_MASK_HOTKEY         = $00000020;
  SEE_MASK_NOCLOSEPROCESS = $00000040;
  SEE_MASK_CONNECTNETDRV  = $00000080;
  SEE_MASK_FLAG_DDEWAIT   = $00000100;
  SEE_MASK_DOENVSUBST     = $00000200;
  SEE_MASK_FLAG_NO_UI     = $00000400;
  SEE_MASK_UNICODE        = $00010000; // !!! changed from previous SDK (was $00004000)
  SEE_MASK_NO_CONSOLE     = $00008000;
  SEE_MASK_ASYNCOK        = $00100000;

type
  PShellExecuteInfoA = ^TShellExecuteInfoA;
  PShellExecuteInfoW = ^TShellExecuteInfoW;
  PShellExecuteInfo = {$ifdef bUnicode}PShellExecuteInfoW{$else}PShellExecuteInfoA{$endif bUnicode};

  _SHELLEXECUTEINFOA = record
    cbSize: DWORD;
    fMask: ULONG;
    Wnd: HWND;
    lpVerb: PAnsiChar;
    lpFile: PAnsiChar;
    lpParameters: PAnsiChar;
    lpDirectory: PAnsiChar;
    nShow: Integer;
    hInstApp: HINST;
    { Optional fields }
    lpIDList: Pointer;
    lpClass: PAnsiChar;
    hkeyClass: HKEY;
    dwHotKey: DWORD;
    hIcon: THandle;
    hProcess: THandle;
  end;
  _SHELLEXECUTEINFOW = record
    cbSize: DWORD;
    fMask: ULONG;
    Wnd: HWND;
    lpVerb: PWideChar;
    lpFile: PWideChar;
    lpParameters: PWideChar;
    lpDirectory: PWideChar;
    nShow: Integer;
    hInstApp: HINST;
    { Optional fields }
    lpIDList: Pointer;
    lpClass: PWideChar;
    hkeyClass: HKEY;
    dwHotKey: DWORD;
    hIcon: THandle;
    hProcess: THandle;
  end;
  _SHELLEXECUTEINFO = {$ifdef bUnicode}_SHELLEXECUTEINFOW{$else}_SHELLEXECUTEINFOA{$endif bUnicode};

  TShellExecuteInfoA = _SHELLEXECUTEINFOA;
  TShellExecuteInfoW = _SHELLEXECUTEINFOW;
  TShellExecuteInfo = {$ifdef bUnicode}TShellExecuteInfoW{$else}TShellExecuteInfoA{$endif bUnicode};

  SHELLEXECUTEINFOA = _SHELLEXECUTEINFOA;
  SHELLEXECUTEINFOW = _SHELLEXECUTEINFOW;
  SHELLEXECUTEINFO = {$ifdef bUnicode}SHELLEXECUTEINFOW{$else}SHELLEXECUTEINFOA{$endif bUnicode};

function ShellExecuteExA(lpExecInfo: PShellExecuteInfoA):BOOL; stdcall;
function ShellExecuteExW(lpExecInfo: PShellExecuteInfoW):BOOL; stdcall;
function ShellExecuteEx(lpExecInfo: PShellExecuteInfo):BOOL; stdcall;

{ Tray notification definitions }

type
  PNotifyIconDataA = ^TNotifyIconDataA;
  PNotifyIconDataW = ^TNotifyIconDataW;
  PNotifyIconData = {$ifdef bUnicode}PNotifyIconDataW{$else}PNotifyIconDataA{$endif bUnicode};

  _NOTIFYICONDATAA = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..63] of AnsiChar;
  end;
  _NOTIFYICONDATAW = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..63] of WideChar;
  end;
  _NOTIFYICONDATA = {$ifdef bUnicode}_NOTIFYICONDATAW{$else}_NOTIFYICONDATAA{$endif bUnicode};

  TNotifyIconDataA = _NOTIFYICONDATAA;
  TNotifyIconDataW = _NOTIFYICONDATAW;
  TNotifyIconData = {$ifdef bUnicode}TNotifyIconDataW{$else}TNotifyIconDataA{$endif bUnicode};

  NOTIFYICONDATAA = _NOTIFYICONDATAA;
  NOTIFYICONDATAW = _NOTIFYICONDATAW;
  NOTIFYICONDATA = {$ifdef bUnicode}NOTIFYICONDATAW{$else}NOTIFYICONDATAA{$endif bUnicode};

const
  NIM_ADD         = $00000000;
  NIM_MODIFY      = $00000001;
  NIM_DELETE      = $00000002;

  NIF_MESSAGE     = $00000001;
  NIF_ICON        = $00000002;
  NIF_TIP         = $00000004;

function Shell_NotifyIconA(dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL; stdcall;
function Shell_NotifyIconW(dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL; stdcall;
function Shell_NotifyIcon(dwMessage: DWORD; lpData: PNotifyIconData): BOOL; stdcall;

{ Begin SHGetFileInfo }

(*
 * The SHGetFileInfo API provides an easy way to get attributes
 * for a file given a pathname.
 *
 *   PARAMETERS
 *
 *     pszPath              file name to get info about
 *     dwFileAttributes     file attribs, only used with SHGFI_USEFILEATTRIBUTES
 *     psfi                 place to return file info
 *     cbFileInfo           size of structure
 *     uFlags               flags
 *
 *   RETURN
 *     TRUE if things worked
 *)

type
  PSHFileInfoA = ^TSHFileInfoA;
  PSHFileInfoW = ^TSHFileInfoW;
  PSHFileInfo = {$ifdef bUnicode}PSHFileInfoW{$else}PSHFileInfoA{$endif bUnicode};

  _SHFILEINFOA = record
    hIcon: HICON;                      { out: icon }
    iIcon: Integer;                    { out: icon index }
    dwAttributes: DWORD;               { out: SFGAO_ flags }
    szDisplayName: array [0..MAX_PATH-1] of  AnsiChar; { out: display name (or path) }
    szTypeName: array [0..79] of AnsiChar;             { out: type name }
  end;
  _SHFILEINFOW = record
    hIcon: HICON;                      { out: icon }
    iIcon: Integer;                    { out: icon index }
    dwAttributes: DWORD;               { out: SFGAO_ flags }
    szDisplayName: array [0..MAX_PATH-1] of  WideChar; { out: display name (or path) }
    szTypeName: array [0..79] of WideChar;             { out: type name }
  end;
  _SHFILEINFO = {$ifdef bUnicode}_SHFILEINFOW{$else}_SHFILEINFOA{$endif bUnicode};

  TSHFileInfoA = _SHFILEINFOA;
  TSHFileInfoW = _SHFILEINFOW;
  TSHFileInfo = {$ifdef bUnicode}TSHFileInfoW{$else}TSHFileInfoA{$endif bUnicode};

  SHFILEINFOA = _SHFILEINFOA;
  SHFILEINFOW = _SHFILEINFOW;
  SHFILEINFO = {$ifdef bUnicode}SHFILEINFOW{$else}SHFILEINFOA{$endif bUnicode};

const
  SHGFI_ICON              = $000000100;     { get icon }
  SHGFI_DISPLAYNAME       = $000000200;     { get display name }
  SHGFI_TYPENAME          = $000000400;     { get type name }
  SHGFI_ATTRIBUTES        = $000000800;     { get attributes }
  SHGFI_ICONLOCATION      = $000001000;     { get icon location }
  SHGFI_EXETYPE           = $000002000;     { return exe type }
  SHGFI_SYSICONINDEX      = $000004000;     { get system icon index }
  SHGFI_LINKOVERLAY       = $000008000;     { put a link overlay on icon }
  SHGFI_SELECTED          = $000010000;     { show icon in selected state }
  SHGFI_LARGEICON         = $000000000;     { get large icon }
  SHGFI_SMALLICON         = $000000001;     { get small icon }
  SHGFI_OPENICON          = $000000002;     { get open icon }
  SHGFI_SHELLICONSIZE     = $000000004;     { get shell size icon }
  SHGFI_PIDL              = $000000008;     { pszPath is a pidl }
  SHGFI_USEFILEATTRIBUTES = $000000010;     { use passed dwFileAttribute }

function SHGetFileInfoA(pszPath: PAnsiChar; dwFileAttributes: DWORD;
  var psfi: TSHFileInfoA; cbFileInfo, uFlags: UINT): DWORD; stdcall;
function SHGetFileInfoW(pszPath: PAnsiChar; dwFileAttributes: DWORD;
  var psfi: TSHFileInfoW; cbFileInfo, uFlags: UINT): DWORD; stdcall;
function SHGetFileInfo(pszPath: PTChar; dwFileAttributes: DWORD;
  var psfi: TSHFileInfo; cbFileInfo, uFlags: UINT): DWORD; stdcall;

const
  SHGNLI_PIDL             = $000000001;     { pszLinkTo is a pidl }
  SHGNLI_PREFIXNAME       = $000000002;     { Make name "Shortcut to xxx" }
  SHGNLI_NOUNIQUE         = $000000004;     { don't do the unique name generation }

  shell32 = 'shell32.dll';

implementation

function CommandLineToArgvW; external shell32 name 'CommandLineToArgvW';
function DoEnvironmentSubstA; external shell32 name 'DoEnvironmentSubstA';
function DoEnvironmentSubstW; external shell32 name 'DoEnvironmentSubstW';
function DoEnvironmentSubst; external shell32 name 'DoEnvironmentSubst'+_X;
procedure DragAcceptFiles; external shell32 name 'DragAcceptFiles';
procedure DragFinish; external shell32 name 'DragFinish';
function DragQueryFileA; external shell32 name 'DragQueryFileA';
function DragQueryFileW; external shell32 name 'DragQueryFileW';
function DragQueryFile; external shell32 name 'DragQueryFile'+_X;
function DragQueryPoint; external shell32 name 'DragQueryPoint';
function DuplicateIcon; external shell32 name 'DuplicateIcon';
function ExtractAssociatedIconA; external shell32 name 'ExtractAssociatedIconA';
function ExtractAssociatedIconW; external shell32 name 'ExtractAssociatedIconW';
function ExtractAssociatedIcon; external shell32 name 'ExtractAssociatedIcon'+_X;
function ExtractIconA; external shell32 name 'ExtractIconA';
function ExtractIconW; external shell32 name 'ExtractIconW';
function ExtractIcon; external shell32 name 'ExtractIcon'+_X;
function ExtractIconExA; external shell32 name 'ExtractIconExA';
function ExtractIconExW; external shell32 name 'ExtractIconExW';
function ExtractIconEx; external shell32 name 'ExtractIconEx'+_X;
function FindExecutableA; external shell32 name 'FindExecutableA';
function FindExecutableW; external shell32 name 'FindExecutableW';
function FindExecutable; external shell32 name 'FindExecutable'+_X;
function SHAppBarMessage; external shell32 name 'SHAppBarMessage';
function SHFileOperationA; external shell32 name 'SHFileOperationA';
function SHFileOperationW; external shell32 name 'SHFileOperationW';
function SHFileOperation; external shell32 name 'SHFileOperation'+_X;
procedure SHFreeNameMappings; external shell32 name 'SHFreeNameMappings';
function SHGetFileInfoA; external shell32 name 'SHGetFileInfoA';
function SHGetFileInfoW; external shell32 name 'SHGetFileInfoW';
function SHGetFileInfo; external shell32 name 'SHGetFileInfo'+_X;
function ShellAboutA; external shell32 name 'ShellAboutA';
function ShellAboutW; external shell32 name 'ShellAboutW';
function ShellAbout; external shell32 name 'ShellAbout'+_X;
function ShellExecuteA; external shell32 name 'ShellExecuteA';
function ShellExecuteW; external shell32 name 'ShellExecuteW';
function ShellExecute; external shell32 name 'ShellExecute'+_X;
function ShellExecuteExA; external shell32 name 'ShellExecuteExA';
function ShellExecuteExW; external shell32 name 'ShellExecuteExW';
function ShellExecuteEx; external shell32 name 'ShellExecuteEx'+_X;
function Shell_NotifyIconA; external shell32 name 'Shell_NotifyIconA';
function Shell_NotifyIconW; external shell32 name 'Shell_NotifyIconW';
function Shell_NotifyIcon; external shell32 name 'Shell_NotifyIcon'+_X;

end.

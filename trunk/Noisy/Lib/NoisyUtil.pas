{$I Defines.inc}
{$Typedaddress Off}

unit NoisyUtil;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    ShellApi,
    SHLObj,

    Bass,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses;


  function CheckMutexExistsEx(const aMutexName :TString; aGlobal :Boolean) :Boolean;
  function CreateMutexEx(const aMutexName :TString; var aMutex :THandle; aGlobal :Boolean) :Boolean;

  function CreateMemoryMapping(const AMemoryName :TString; ASize :Integer) :THandle;
  function MapMemory(AHandle :THandle; AForWrite :Boolean) :Pointer;

  function GetConsoleTitleStr :TString;
  function GetSpecialFolder(FolderType :Integer) :TString;
  function ShellOpen(AWnd :THandle; const FName, Param :TString) :Boolean;

  function Time2Str(ATime :Single) :TString;
  function NameOfCType(AType :Integer) :TString;
  function NameOfChans(AChans :Integer) :TString;

  function StrRightAjust(const AStr :TString; ALen :Integer) :TString;
  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;

  function StrFromChrA(AStr :PAnsiChar; ALen :Integer) :TAnsiStr;
  function StrFromChrW(AStr :PWideChar; ALen :Integer) :TWideStr;

  function FileNameIsURL(const AName :TString) :Boolean;
  function ExtractFileNameEx(const AName :TString) :TString;

  function GetSystrayWindow :THandle;
  function GetSystrayWindowPos :TPoint;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  var
    Win32Platform: Integer = 0;
    Win32MajorVersion: Integer = 0;
//  Win32MinorVersion: Integer = 0;
//  Win32BuildNumber: Integer = 0;


  procedure InitPlatformId;
  var
    OSVersionInfo: TOSVersionInfo;
  begin
    OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
    if GetVersionEx(OSVersionInfo) then
      with OSVersionInfo do begin
        Win32Platform := dwPlatformId;
        Win32MajorVersion := dwMajorVersion;
//      Win32MinorVersion := dwMinorVersion;
//      Win32BuildNumber := dwBuildNumber;
//      Win32CSDVersion := szCSDVersion;
      end;
  end;


 {-----------------------------------------------------------------------------}

  const
    GlobalNamePrefix = 'Global\';


  procedure MakeGlobalName(aBuf :PTChar; const aMutexName :TString; aGlobal :Boolean);
  var
    vChr, vBeg :PTChar;
  begin
    vChr := aBuf;
    if aGlobal and (Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4) then
      vChr := StrECopy(vChr, GlobalNamePrefix);

    vBeg := vChr;
    vChr := StrECopy(vChr, PTChar(aMutexName));
    CharUpperBuff(vBeg, vChr - vBeg);
  end;


  const
    SECURITY_DESCRIPTOR_REVISION = 1;

  var
    FSecurityDescriptor :TSecurityDescriptor;
    FSecurityAttributes :PSecurityAttributes = nil;

  const
    cSecurityAttributes :TSecurityAttributes = (
      nLength: SizeOf(TSecurityAttributes);
      lpSecurityDescriptor: @FSecurityDescriptor;
      bInheritHandle: True;
    );

  function GetSecurityAttributes :PSecurityAttributes;
  begin
    if (FSecurityAttributes = nil) and (Win32Platform = VER_PLATFORM_WIN32_NT) then begin
      Win32Check(InitializeSecurityDescriptor(@FSecurityDescriptor, SECURITY_DESCRIPTOR_REVISION));
      Win32Check(SetSecurityDescriptorDacl(@FSecurityDescriptor, True, nil, True));
      Win32Check(SetSecurityDescriptorGroup(@FSecurityDescriptor, nil, True));
      Win32Check(SetSecurityDescriptorOwner(@FSecurityDescriptor, nil, True));
      FSecurityAttributes := @cSecurityAttributes;
    end;
    Result := FSecurityAttributes;
  end;


  function CheckMutexExistsEx(const aMutexName :TString; aGlobal :Boolean) :Boolean;
  var
    vName  :array[0..Max_Path] of TChar;
    vMutex :THandle;
  begin
    MakeGlobalName(vName, AMutexName, aGlobal);
    vMutex := OpenMutex(SYNCHRONIZE, False, vName);
    Result := vMutex <> 0;
    if Result then
      CloseHandle(vMutex);
  end;


  function CreateMutexEx(const aMutexName :TString; var aMutex :THandle; aGlobal :Boolean) :Boolean;
  var
    vName  :array[0..Max_Path] of TChar;
    vSecurityAttributes :PSecurityAttributes;
  begin
    MakeGlobalName(vName, AMutexName, aGlobal);
    if aGlobal then
      vSecurityAttributes := GetSecurityAttributes
    else
      vSecurityAttributes := nil;
    aMutex := CreateMutex(vSecurityAttributes, True, vName);
    Result := GetLastError = 0{ERROR_ALREADY_EXISTS};
  end;

 {-----------------------------------------------------------------------------}

  function CreateMemoryMapping(const AMemoryName :TString; ASize :Integer) :THandle;
  begin
    Result := CreateFileMapping(THandle($FFFFFFFF), GetSecurityAttributes, PAGE_READWRITE, 0, ASize, PTChar(AMemoryName));
    if (Result = 0) or (GetLastError = ERROR_ALREADY_EXISTS ) then begin
      if Result <> 0 then
        CloseHandle(Result);
      RaiseLastWin32Error;
    end;
  end;


  function MapMemory(AHandle :THandle; AForWrite :Boolean) :Pointer;
  var
    vAccess :Integer;
  begin
    vAccess := FILE_MAP_READ;
    if AForWrite then
      vAccess := vAccess or FILE_MAP_WRITE;
    Result := MapViewOfFile(AHandle, vAccess, 0, 0, 0);
    if Result = nil then
      RaiseLastWin32Error;
  end;


 {-----------------------------------------------------------------------------}

  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..255] of TChar;
  begin
    FillChar(vBuf, SizeOf(vBuf), $00);
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;

//  if ConManDetected then
//    ConManClearTitle(Result);
  end;


  function GetSpecialFolder(FolderType :Integer) :TString;
  var
    pidl :PItemIDList;
    buf  :array[0..MAX_PATH] of TChar;
  begin
    Result := '';
    if SHGetSpecialFolderLocation(0, FolderType, pidl) = NOERROR then begin
      SHGetPathFromIDList(pidl, buf);
      Result := buf;
    end;
  end;


  function ShellOpenEx(AWnd :THandle; const FName, Param :TString; AMask :ULONG;
    AShowMode :Integer; AInfo :PShellExecuteInfo) :Boolean;
  var
    vInfo :TShellExecuteInfo;
  begin
//  Trace(FName);
    if not Assigned(AInfo) then
      AInfo := @vInfo;
    FillChar(AInfo^, SizeOf(AInfo^), 0);
    AInfo.cbSize        := SizeOf(AInfo^);
    AInfo.fMask         := AMask;
    AInfo.Wnd           := AWnd {AppMainForm.Handle};
    AInfo.lpFile        := PTChar(FName);
    AInfo.lpParameters  := PTChar(Param);
    AInfo.nShow         := AShowMode;
    Result := ShellExecuteEx(AInfo);
  end;


  function ShellOpen(AWnd :THandle; const FName, Param :TString) :Boolean;
  begin
    Result := ShellOpenEx(AWnd, FName, Param, 0{ or SEE_MASK_FLAG_NO_UI}, SW_Show, nil);
  end;


  function Time2Str(ATime :Single) :TString;
  var
    vSec :Integer;
  begin
    vSec := Round(ATime);
    Result := Format('%.2d:%.2d', [vSec div 60, vSec mod 60]);
  end;


  function NameOfCType(AType :Integer) :TString;
  begin
    case AType of
      BASS_CTYPE_STREAM_WAV, BASS_CTYPE_STREAM_WAV_PCM..BASS_CTYPE_STREAM_WAV_FLOAT:
        Result := 'WAV';
      BASS_CTYPE_STREAM_MP1:   Result := 'MP1';
      BASS_CTYPE_STREAM_MP2:   Result := 'MP2';
      BASS_CTYPE_STREAM_MP3:   Result := 'MP3';
(*
      BASS_CTYPE_STREAM_OGG:   Result := 'OGG';   {Ogg Vorbis format stream.}
      BASS_CTYPE_STREAM_AIFF:  Result := 'AIFF';  {Audio IFF format stream.}
      BASS_CTYPE_MUSIC_MOD:    Result := 'MOD';   {Generic MOD format music}
      BASS_CTYPE_MUSIC_MTM:    Result := 'MTM';   {MultiTracker format music.}
      BASS_CTYPE_MUSIC_S3M:    Result := 'S3M';   {ScreamTracker 3 format music.}
      BASS_CTYPE_MUSIC_XM:     Result := 'XM';    {FastTracker 2 format music.}
      BASS_CTYPE_MUSIC_IT:     Result := 'IT';    {Impulse Tracker format music.}
*)
    else
      Result := '';
    end;
  end;


  function NameOfChans(AChans :Integer) :TString;
  begin
    case AChans of
      1: Result := 'mono';
      2: Result := 'stereo';
    else
      Result := Format('%d channels', [AChans]);
    end;
  end;


  function StrRightAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := AStr
    else
      Result := StringOfChar(' ', ALen - vLen) + AStr;
  end;


  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := Copy(AStr, 1, ALen)
    else
      Result := AStr + StringOfChar(' ', ALen - vLen);
  end;


  function StrFromChrA(AStr :PAnsiChar; ALen :Integer) :TAnsiStr;
  var
    vStr :PAnsiChar;
  begin
    vStr := AStr;
    while (vStr < AStr + ALen) and (vStr^ <> #0) do
      Inc(vStr);
    while (vStr > AStr) and ((vStr - 1)^ = ' ') do
      Dec(vStr);
    SetString(Result, AStr, vStr - AStr);
  end;


  function StrFromChrW(AStr :PWideChar; ALen :Integer) :TWideStr;
  var
    vStr :PWideChar;
  begin
    vStr := AStr;
    while (vStr < AStr + ALen) and (vStr^ <> #0) do
      Inc(vStr);
    while (vStr > AStr) and ((vStr - 1)^ = ' ') do
      Dec(vStr);
    SetString(Result, AStr, vStr - AStr);
  end;


  function FileNameIsURL(const AName :TString) :Boolean;
  begin
    Result := (UpCompareSubStr('ftp:', AName) = 0) or (UpCompareSubStr('http:', AName) = 0);
  end;


  function ExtractFileNameEx(const AName :TString) :TString;
  var
    I :Integer;
  begin
    if FileNameIsURL(AName) then begin
      I := LastDelimiter('/', AName);
      Result := Copy(AName, I + 1, MaxInt);
//    Result := AName;
    end else
      Result := ExtractFileName(AName);
  end;



  function GetSystrayWindow :THandle;
  begin
    Result := FindWindow('Shell_TrayWnd', '');
    if Result <> 0 then begin
      Result := FindWindowEx(Result, 0, 'TrayNotifyWnd', '');
//    if Result <> 0 then begin
//      Result := FindWindowEx(Result, 0, 'SysPager', '');
//      if Result <> 0 then
//        Result := FindWindowEx(Result, 0, 'ToolbarWindow32', '');
//    end;
    end;
  end;


  function GetSystrayWindowPos :TPoint;
  var
    vWnd :THandle;
    vRect :TRect;
  begin
    vWnd := GetSystrayWindow;
    if vWnd <> 0 then begin
      GetWindowRect(vWnd, vRect);
      Result := vRect.TopLeft;
    end else
      Result := Point(0, 0);
  end;


initialization
  InitPlatformId;
end.

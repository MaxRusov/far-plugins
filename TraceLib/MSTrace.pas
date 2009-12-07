{$I Defines.inc}

{$ifdef bDelphi}
 {-$define DebugInfo}
 {$ifdef DebugInfo} {$D+,L+,Y+} {$else} {$D-} {$endif}
{$endif bDelphi}

unit MSTrace;

interface

  uses
    Windows,
    MixTypes;

  var
    TraceTimout :Integer = 5000;


  function TraceEnabled :Boolean;

  function TraceStrA(AInst :THandle; TraceMsg, TraceClass :PAnsiChar) :Boolean;
  function TraceStrW(AInst :THandle; TraceMsg, TraceClass :PWideChar) :Boolean;
  function TraceStr(AInst :THandle; TraceMsg, TraceClass :PTChar) :Boolean;

  procedure ClearTrace;


{******************************************************************************}
{******************************} IMPLEMENTATION {******************************}
{******************************************************************************}


  function IntMin(L1, L2 :Integer) :Integer;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;


  function StrCopyLA(Dest, Source :PAnsiChar; Len, BufLen :Integer) :PAnsiChar;
  begin
    if Len > BufLen - 1 then
      Len := BufLen - 1;
    if Len > 0 then
      Move(Source^, Dest^, Len);
    (Dest + Len)^ := #0;
    Result := Dest + Len + 1;
  end;

  function StrCopyLWA(Dest :PAnsiChar; Source :PWideChar; Len, BufLen :Integer) :PAnsiChar;
  begin
    if Len > BufLen - 1 then
      Len := BufLen - 1;
    if Len > 0 then
      WideCharToMultiByte(CP_ACP, 0, Source, Len, Dest, Len, nil, nil);
    (Dest + Len)^ := #0;
    Result := Dest + Len + 1;
  end;

 {$ifdef bTraceVer6}
  function StrCopyLW(Dest, Source :PWideChar; Len, BufLen :Integer) :PWideChar;
  begin
    if Len > BufLen - 1 then
      Len := BufLen - 1;
    if Len > 0 then
      Move(Source^, Dest^, Len * 2);
    (Dest + Len)^ := #0;
    Result := Dest + Len + 1;
  end;
 {$endif bTraceVer6}


  function StrCopyA(Dest, Source :PAnsiChar; Len :Integer) :PAnsiChar;
  begin
    Result := StrCopyLA(Dest, Source, Len, Len + 1);
  end;

 {$ifdef bTraceVer6}
  function StrCopyW(Dest, Source :PWideChar; Len :Integer) :PWideChar;
  begin
    Result := StrCopyLW(Dest, Source, Len, Len + 1);
  end;
 {$endif bTraceVer6}


  function IntCopy(Dest :Pointer; Num :TInt32) :Pointer;
  begin
    PInt32(Dest)^ := Num;
    Result := Pointer1(Dest) + 4;
  end;


  function GetProcessNameA(Dest :PAnsiChar) :Integer;
  begin
    Result := GetModuleFileNameA(0, Dest, MAX_PATH);
  end;

  function GetProcessNameW(Dest :PWideChar) :Integer;
  begin
    Result := GetModuleFileNameW(0, Dest, MAX_PATH);
  end;


  function GetModuleNameA(AInst :THandle; Dest :PAnsiChar) :Integer;
  begin
    Result := GetModuleFileNameA(AInst, Dest, MAX_PATH);
  end;

  function GetModuleNameW(AInst :THandle; Dest :PWideChar) :Integer;
  begin
    Result := GetModuleFileNameW(AInst, Dest, MAX_PATH);
  end;

 {-----------------------------------------------------------------------------}
 { Трассировка через Memory Mapped файлы (recommend)                           }
 {-----------------------------------------------------------------------------}

  const
   {$ifdef bTraceVer6}

    TraceMutexName       = 'DbWinOLE6TraceMutex';       { Критическая секция для трассировки }

    TraceEnableFlagName  = 'DbWinOLE6TraceEnabled';     { Поток трассировки работает }
    TraceFilledFlagName  = 'DbWinOLE6TraceFilled';      { Буфер данны заполнен }
    TraceEmptyFlagName   = 'DbWinOLE6TraceEmpty';       { Буфер данных очищен }

    TraceBufferName      = 'DbWinOLE6TraceBuffer';
    TraceBufferSize      = 1024 * 64;

   {$else}

    TraceMutexName       = 'DbWinOLE5TraceMutex';       { Критическая секция для трассировки }

    TraceEnableFlagName  = 'DbWinOLE5TraceEnabled';     { Поток трассировки работает }
    TraceFilledFlagName  = 'DbWinOLE5TraceFilled';      { Буфер данны заполнен }
    TraceEmptyFlagName   = 'DbWinOLE5TraceEmpty';       { Буфер данных очищен }

    TraceBufferName      = 'DbWinOLE5TraceBuffer';
    TraceBufferSize      = 1024 * 8;

   {$endif bTraceVer6}

  const
   {$ifdef bTraceVer6}
    cUnicode = TInt32($8000000);
   {$endif bTraceVer6}
    cMessage = 1;
    cClear   = 2;

  var
    TraceMutex      :THandle  = 0;
    SecDescr        :TSecurityDescriptor;
    SecAttr         :TSecurityAttributes;

    EnableEvent     :THandle  = 0;
    FilledEvent     :THandle  = 0;
    EmptyEvent      :THandle  = 0;

    TraceFileHandle :THandle  = 0;
    TraceBufferPtr  :Pointer  = nil;

    WaitHandles     :array[0..1] of THandle;


  procedure FreeHandle(var AHandle :THandle);
  begin
    if AHandle <> 0 then begin
      CloseHandle(AHandle);
      AHandle := 0;
    end;
  end;


  function IsWindowsNT :Boolean;
  var
    vVerInfo :TOSVersionInfo;
  begin
    FillChar(vVerInfo, SizeOf(vVerInfo), 0);
    vVerInfo.dwOSVersionInfoSize := SizeOf(vVerInfo);
    GetVersionEx(vVerInfo);
    Result := vVerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT;
  end;


  procedure InitTrace;
  var
    vAttr :PSecurityAttributes;
  begin
    vAttr := nil;
    if IsWindowsNT then begin
      InitializeSecurityDescriptor(@SecDescr,  1{SECURITY_DESCRIPTOR_REVISION} );
      SetSecurityDescriptorDacl(@SecDescr, True, nil, False);
      SecAttr.nLength := SizeOf(SecAttr);
      SecAttr.lpSecurityDescriptor := @SecDescr;
      vAttr := @SecAttr;
    end;

    { Создаем именованый mutex для блокировки trace'ов }
    TraceMutex := CreateMutex(vAttr, False, TraceMutexName);

    { Создаем флаги (event) для синхронизации с Debug Window }
    EnableEvent := CreateEvent(vAttr, True, False, TraceEnableFlagName);
    FilledEvent := CreateEvent(vAttr, True, False, TraceFilledFlagName);
    EmptyEvent  := CreateEvent(vAttr, True, True,  TraceEmptyFlagName);

    WaitHandles[0] := TraceMutex;
    WaitHandles[1] := EmptyEvent;
  end;


  procedure InitBuffer;
  begin
    { Создаем разделяемую область памяти }
    TraceFileHandle := OpenFileMapping(FILE_MAP_WRITE, False, TraceBufferName);
    TraceBufferPtr := MapViewOfFile(TraceFileHandle, FILE_MAP_WRITE, 0, 0, TraceBufferSize);
  end;


  procedure DoneTrace;
  begin
    if TraceBufferPtr <> nil then
      UnmapViewOfFile(TraceBufferPtr);
    TraceBufferPtr := nil;
    FreeHandle(TraceFileHandle);
    FreeHandle(EnableEvent);
    FreeHandle(FilledEvent);
    FreeHandle(EmptyEvent);
    FreeHandle(TraceMutex);
  end;


 {$ifdef bTraceVer6}

  procedure PackMessageA(ACmd :Integer; AInst :THandle; TraceMsg, TraceClass :PAnsiChar);
  var
    Dest :PAnsiChar;
    PathBuf1 :array[0..MAX_PATH] of AnsiChar;
    PathBuf2 :array[0..MAX_PATH] of AnsiChar;
    vLen, vLen1, vLen2, vLen3 :Integer;
  begin
    vLen  := lstrlena(TraceMsg);
    vLen1 := IntMin(lstrlena(TraceClass), 255);
    vLen2 := GetProcessNameA(PathBuf1);
    vLen3 := GetModuleNameA(AInst, PathBuf2);

    Dest := PAnsiChar(TraceBufferPtr) + SizeOf(TInt32); {???}

    Dest := IntCopy(Dest, ACmd);
    Dest := IntCopy(Dest, TInt32(GetCurrentProcessID));
    Dest := IntCopy(Dest, TInt32(GetCurrentThreadID));
    Dest := StrCopyA(Dest, PathBuf1, vLen2);
    Dest := StrCopyA(Dest, PathBuf2, vLen3);
    Dest := StrCopyA(Dest, TraceClass, vLen1);
   {Dest :=}StrCopyLA(Dest, TraceMsg, vLen, TraceBufferSize-4*4 - (vLen1+1) - (vLen2+1) - (vLen3+1) );
  end;

  procedure PackMessageW(ACmd :Integer; AInst :THandle; TraceMsg, TraceClass :PWideChar);
  var
    Dest :PWideChar;
    PathBuf1 :array[0..MAX_PATH] of WideChar;
    PathBuf2 :array[0..MAX_PATH] of WideChar;
    vLen, vLen1, vLen2, vLen3 :Integer;
  begin
    vLen  := lstrlenw(TraceMsg);
    vLen1 := IntMin(lstrlenw(TraceClass), 255);
    vLen2 := GetProcessNameW(PathBuf1);
    vLen3 := GetModuleNameW(AInst, PathBuf2);

    Dest := Pointer(PAnsiChar(TraceBufferPtr) + SizeOf(TInt32)); {???}

    Dest := IntCopy(Dest, ACmd or cUnicode);
    Dest := IntCopy(Dest, TInt32(GetCurrentProcessID));
    Dest := IntCopy(Dest, TInt32(GetCurrentThreadID));
    Dest := StrCopyW(Dest, PathBuf1, vLen2);
    Dest := StrCopyW(Dest, PathBuf2, vLen3);
    Dest := StrCopyW(Dest, TraceClass, vLen1);
   {Dest :=}StrCopyLW(Dest, TraceMsg, vLen, ((TraceBufferSize-4*4) div 2) - (vLen1+1) - (vLen2+1) - (vLen3+1) );
  end;

 {$else}

  procedure PackMessageA(ACmd :Integer; TraceMsg, TraceClass :PAnsiChar;
    ABuf1 :PAnsiChar; ALen1 :Integer; ABuf2 :PAnsiChar; ALen2 :Integer);
  var
    Dest :PAnsiChar;
    Len  :Integer;
  begin
    Len  := IntMin(lstrlena(TraceClass), 255);

    Dest := TraceBufferPtr;
    Dest := StrCopyLA(Dest, TraceMsg, lstrlena(TraceMsg), TraceBufferSize - (Len+1) - (ALen1+1) - (ALen2+1) - 4 - 4 - 4);
    Dest := StrCopyA(Dest, TraceClass, Len);
    Dest := StrCopyA(Dest, ABuf1, ALen1);
    Dest := StrCopyA(Dest, ABuf2, ALen2);
    Dest := IntCopy(Dest, TInt32(GetCurrentThreadID));
    Dest := IntCopy(Dest, TInt32(GetCurrentProcessID));
   {Dest :=}IntCopy(Dest, ACmd);
  end;

  procedure PackMessageW(ACmd :Integer; TraceMsg, TraceClass :PWideChar;
    ABuf1 :PWideChar; ALen1 :Integer; ABuf2 :PWideChar; ALen2 :Integer);
  var
    Dest :PAnsiChar;
    Len  :Integer;
  begin
    Len  := IntMin(lstrlenw(TraceClass), 255);

    Dest := TraceBufferPtr;
    Dest := StrCopyLWA(Dest, TraceMsg, lstrlenw(TraceMsg), TraceBufferSize - (Len+1) - (ALen1+1) - (ALen2+1) - 4 - 4 - 4);
    Dest := StrCopyLWA(Dest, TraceClass, Len, Len + 1);
    Dest := StrCopyLWA(Dest, ABuf1, ALen1, ALen1 + 1);
    Dest := StrCopyLWA(Dest, ABuf2, ALen2, ALen2 + 1);
    Dest := IntCopy(Dest, TInt32(GetCurrentThreadID));
    Dest := IntCopy(Dest, TInt32(GetCurrentProcessID));
   {Dest :=}IntCopy(Dest, ACmd);
  end;

 {$endif bTraceVer6}


  function TraceEnabled :Boolean;
  begin
    Result := False;
    if WaitForSingleObject( EnableEvent, 0 ) = WAIT_OBJECT_0 then begin
      if TraceBufferPtr = nil then begin
        InitBuffer;
        Result := TraceBufferPtr <> nil;
      end else
        Result := True;
    end;
  end;


  function TraceExclusive :Boolean;
  var
    vRes :DWORD;
  begin
    Result := False;
    vRes := WaitForMultipleObjects( 2, Pointer(@WaitHandles), True, TraceTimout ); { Wait for Exclusive and Empty }
    if vRes = WAIT_TIMEOUT then
      MessageBeep(UInt(-1))
    else
    if vRes <> WAIT_FAILED then
      Result := True;
  end;


  function TraceStrA(AInst :THandle; TraceMsg, TraceClass :PAnsiChar) :Boolean;
  var
    vCmd :Integer;
    vLen1, vLen2 :Integer;
    vBuf1 :array[0..MAX_PATH] of AnsiChar;
    vBuf2 :array[0..MAX_PATH] of AnsiChar;
  begin
    Result := False;
    if TraceEnabled then begin
      { Этот код пришлось вынести перед TraceExclusive, чтобы не нарушать DllMain restrictions}
      vLen1 := GetModuleNameA(AInst, vBuf1);
      vLen2 := GetProcessNameA(vBuf2);

      if TraceExclusive then begin
        try
          if TraceEnabled then begin
            vCmd := cMessage;
            if AInst = 0 then
              vCmd := cClear;
            PackMessageA(vCmd, TraceMsg, TraceClass, vBuf1, vLen1, vBuf2, vLen2);
            ResetEvent(EmptyEvent);
            SetEvent(FilledEvent);
            Result := True;
          end;
        finally
          ReleaseMutex(TraceMutex);
        end;
      end;
    end;
  end;


  function TraceStrW(AInst :THandle; TraceMsg, TraceClass :PWideChar) :Boolean;
  var
    vLen1, vLen2 :Integer;
    vBuf1 :array[0..MAX_PATH] of WideChar;
    vBuf2 :array[0..MAX_PATH] of WideChar;
  begin
    Result := False;
    if TraceEnabled then begin
      { Этот код пришлось вынести перед TraceExclusive, чтобы не нарушать DllMain restrictions}
      vLen1 := GetModuleNameW(AInst, vBuf1);
      vLen2 := GetProcessNameW(vBuf2);

      if TraceExclusive then begin
        try
          if TraceEnabled then begin
            PackMessageW(cMessage, TraceMsg, TraceClass, vBuf1, vLen1, vBuf2, vLen2);
            ResetEvent(EmptyEvent);
            SetEvent(FilledEvent);
            Result := True;
          end;
        finally
          ReleaseMutex(TraceMutex);
        end;
      end;
    end;
  end;


  function TraceStr(AInst :THandle; TraceMsg, TraceClass :PTChar) :Boolean;
  begin
   {$ifdef bUnicode}
    Result := TraceStrW(AInst, TraceMsg, TraceClass);
   {$else}
    Result := TraceStrA(AInst, TraceMsg, TraceClass);
   {$endif bUnicode}
  end;


  procedure ClearTrace;
  begin
    TraceStrA(0, nil, nil);
  end;



initialization
begin
  InitTrace;
end;

finalization
begin
  DoneTrace;
end;


end.


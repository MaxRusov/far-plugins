{$I Defines.inc}

unit FarDebugIO;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    FarCtrl,
    FarDebugCtrl;

  const
    cTerm = #$10;


  type
    TOnWaitIdle = function :Boolean;

  function RedirInited :Boolean;

  procedure RedirChildProcess(const ACommand :TString);
  procedure RedirSendCommand(const ACommand :TString);
  procedure RedirReadAnswer(var AStr :TString; ATerm :AnsiChar; AOnIdle :TOnWaitIdle);
  procedure RedirCloseHandles;

  procedure RedirCall(const ACommand :TString; PRes :PTString = nil; ATerm :AnsiChar = #0);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  var
    hChildRead   :THandle;
    hParentRead  :THandle;

    hChildWrite  :THandle;
    hParentWrite :THandle;

    hChildError  :THandle;
    hParentError :THandle;

    hProcess     :THandle;


    
  function RedirInited :Boolean;
  begin
    Result := hProcess <> 0;
  end;



  procedure RedirChildProcess(const ACommand :TString);
  var
    vProcess, vTmpPipe :THandle;
    vAttrs :TSecurityAttributes;
    vStartup :TStartupInfo;
    vProcessInfo :TProcessInformation;
    vBuf :Array[0..MAX_PATH] of TChar;
  begin
    vAttrs.nLength := sizeof(vAttrs);
    vAttrs.lpSecurityDescriptor := nil;
    vAttrs.bInheritHandle := TRUE;

    vProcess := GetCurrentProcess;

    { Создаем pipe #1 (Для чтения из stdout дочернего процесса) }
    ApiCheck( CreatePipe(vTmpPipe, hChildWrite, @vAttrs, 0) );
    { Создаем копию pipe, которая не может наследоваться }
    ApiCheck( DuplicateHandle(vProcess, vTmpPipe, vProcess, @hParentRead, 0, False, DUPLICATE_SAME_ACCESS) );
    { Закрываем временный handle, который наследуется }
    CloseHandle(vTmpPipe);

    { Создаем pipe #2(Для записи в stdin дочернего процесса) }
    ApiCheck( CreatePipe(hChildRead, vTmpPipe, @vAttrs, 0) );
    { Создаем копию pipe, которая не может наследоваться }
    ApiCheck( DuplicateHandle(vProcess, vTmpPipe, vProcess, @hParentWrite, 0, False, DUPLICATE_SAME_ACCESS) );
    { Закрываем временный handle, который наследуется }
    CloseHandle(vTmpPipe);

    { Создаем pipe #3 (Для чтения из stderror дочернего процесса) }
    ApiCheck( CreatePipe(vTmpPipe, hChildError, @vAttrs, 0) );
    { Создаем копию pipe, которая не может наследоваться }
    ApiCheck( DuplicateHandle(vProcess, vTmpPipe, vProcess, @hParentError, 0, False, DUPLICATE_SAME_ACCESS) );
    { Закрываем временный handle, который наследуется }
    CloseHandle(vTmpPipe);

    {Заполняем структуру startup info }
    vStartup.cb := sizeof(vStartup);
    GetStartupInfo(vStartup);
    PTChar(vStartup.lpTitle) := 'process';
    vStartup.dwFlags := STARTF_USESTDHANDLES;
    vStartup.dwXCountChars := 0;
    vStartup.dwYCountChars := 0;
    vStartup.hStdInput := hChildRead;
    vStartup.hStdOutput := hChildWrite;
    vStartup.hStdError := hChildError;
//  vStartup.hStdError := hChildErrWrite; {???}

    { Запускаем процесс }
    StrPCopy(@vBuf[0], ACommand);
    ApiCheck( CreateProcess(
      nil,      // pointer to name of executable module
      @vBuf[0],	// pointer to command line string
      nil,	// pointer to process security attributes
      nil,	// pointer to thread security attributes
      TRUE,	// handle inheritance flag
      CREATE_DEFAULT_ERROR_MODE or DETACHED_PROCESS, // creation flags
      nil,	// pointer to new environment block
      nil,	// pointer to current directory name
      vStartup, //startup info
      vProcessInfo)
    );

    hProcess := vProcessInfo.hProcess;
  end;


{------------------------------------------------------------------------------}

  procedure RedirSendCommand(const ACommand :TString);
  var
    vStr :AnsiString;
    vWrite :Integer;
  begin
    vStr := ACommand + #10;
    ApiCheck( WriteFile(hParentWrite, PAnsiChar(vStr)^, length(vStr), DWORD(vWrite), nil));
  end;


{------------------------------------------------------------------------------}

  procedure RedirReadAnswer(var AStr :TString; ATerm :AnsiChar; AOnIdle :TOnWaitIdle);
  var
    vBuf :Array[0..1024] of AnsiChar;
    vRead, vFound, vLen, vTotal :Integer;
    vCode :DWORD;
  begin
    AStr := '';
    while True do begin
      if PeekNamedPipe(hParentRead, nil, 0, nil, @vTotal, nil) then begin
        if vTotal > 0 then begin
          ApiCheck( ReadFile( hParentRead, vBuf, SizeOf(vBuf), DWORD(vRead), nil) );

          vFound := MemSearch(@vBuf[0], vRead, ATerm);
          if vFound > 0 then begin
            vLen := Length(AStr);
            SetLength(AStr, vLen + vFound);
           {$ifdef bUnicode}
            MultiByteToWideChar(CP_ACP, 0, @vBuf[0], vFound, PTChar(AStr) + vLen, vFound);
           {$else}
            Move(vBuf, (PTChar(AStr) + vLen)^, vFound);
           {$endif bUnicode}
          end;

          if vFound < vRead then
            Exit;

        end else
        begin
          if PeekNamedPipe(hParentError, nil, 0, nil, @vTotal, nil) and (vTotal > 0) then begin
            NOP;
            Exit;
          end;

          if not GetExitCodeProcess(hProcess, vCode) or (vCode <> STILL_ACTIVE) then begin
            hProcess := 0;
            RedirCloseHandles;
            Exit;
          end;
          if Assigned(AOnIdle) then
            if not AOnIdle then begin
              Abort;
              Exit;
            end;
          Sleep(1);
        end;
      end else
        Exit;
    end;
  end;


{------------------------------------------------------------------------------}

  procedure ReadInput(AHandle :THandle; var AStr :TString);
  var
    vStr :TString;
    vBuf :Array[0..1024] of AnsiChar;
    vRead, vTotal :Integer;
  begin
    AStr := '';
    while True do begin
      if PeekNamedPipe(AHandle, nil, 0, nil, @vTotal, nil) and (vTotal > 0) then begin
        ApiCheck( ReadFile( AHandle, vBuf, SizeOf(vBuf), DWORD(vRead), nil) );
        if vRead > 0 then begin
          SetLength(vStr, vRead);
         {$ifdef bUnicode}
          MultiByteToWideChar(CP_ACP, 0, @vBuf[0], vRead, PTChar(vStr), vRead);
         {$else}
          Move(vBuf, PTChar(vStr)^, vRead);
         {$endif bUnicode}
          AStr := AStr + vStr;
          Sleep(10); {???}
        end;
      end else
        Exit;
    end;
  end;


  procedure RedirReadError(var AStr :TString);
  begin
    ReadInput(hParentError, AStr);
  end;


{------------------------------------------------------------------------------}

  procedure RedirCloseHandles;

    procedure LocClose(var AHandle :THandle);
    begin
      if AHandle <> 0 then begin
        CloseHandle(AHandle);
        AHandle := 0;
      end;
    end;

  begin
    LocClose(hChildRead);
    LocClose(hParentRead);
    LocClose(hChildWrite);
    LocClose(hParentWrite);
    LocClose(hChildError);
    LocClose(hParentError);
  end;


{------------------------------------------------------------------------------}

  var
    vSave  :Integer;
    vStart :DWORD;
    vLast  :DWORD;



  function ReadIdle :Boolean;
  var
    vTick :DWORD;
    vMess :TString;
    vFarMess :TFarStr;
  begin
    Result := True;
    vTick := GetTickCount;
    if Integer(TickCountDiff(vTick, vLast)) < IntIf(vSave = 0, 300, 100) then
      Exit;

    if CheckForEsc then begin
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt) + #10#10 + GetMsgStr(strYes) + #10 + GetMsgStr(strNo), FMSG_WARNING, 2) = 0 then begin
        Result := False;
        Exit;
      end;
    end;

    if vSave = 0 then
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);

    vMess :=
      'GDB'#10 +
      GetMsgStr(strWaitDebugger) + ' (' + Int2Str(TickCountDiff(vTick, vStart) div 1000) + ')...';

   {$ifdef bUnicodeFar}
    vFarMess := vMess;
   {$else}
    vFarMess := StrAnsiToOEM(vMess);
   {$endif bUnicodeFar}
    FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PFarChar(vFarMess)), 0, 0);
    FARAPI.Text(0, 0, 0, nil);
    vLast := vTick;
  end;


  procedure RedirCall(const ACommand :TString; PRes :PTString = nil; ATerm :AnsiChar = #0);
  var
    vRes, vErr :TString;
  begin
    vSave := 0;
    try
//    TraceF('Send="%s"', [ACommand]);
      RedirSendCommand(ACommand);

      vStart := GetTickCount;
      vLast := vStart;
      if ATerm = #0 then
        ATerm := cTerm;
      RedirReadAnswer(vRes, ATerm, ReadIdle);
//    TraceF('Recv="%s"', [vRes]);
      if PRes <> nil then
        PRes^ := vRes;

      RedirReadError(vErr);
      if vErr <> '' then begin
        { После кучи ошибок GDB может выдать результат 8( }
        ReadInput(hParentRead, vRes);

        RaiseError(EGDBError, vErr);
      end;

    finally
      if vSave <> 0 then
        FARAPI.RestoreScreen(vSave);
    end;
  end;


end.

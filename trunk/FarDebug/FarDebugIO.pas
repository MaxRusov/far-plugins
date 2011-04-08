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
    MixClasses,
    FarDebugCtrl;


  const
    cTmpBufSize     = 1024;
    cDefReadTimeout = 250;
//  cDefWaitTimeout = 0; //3000;

  var
    { Символ-терминатор (признак завершения ожидания ответа) }
    { Глобальный терминатор используется, если не задан явно при вызове ReadAnswer }
    TerminatorChar :AnsiChar = #0;


  type
    TRedirEvent = (
      reReadOut,
      reReadErr,
      reIdle
    );

    TOnRedirEvent = function(AEvent :TRedirEvent; const AStr :TAnsiStr; AContext :Pointer) :Boolean;

    TOnWaitIdle = function :Boolean;

  function RedirInited :Boolean;

  procedure RedirChildProcess(const ACommand :TString);
  procedure RedirSendCommand(const ACommand :TString);

  function DefWaitAnswer(AEvent :TRedirEvent; const AStr :TAnsiStr; AContext :Pointer) :Boolean;
  
  procedure RedirReadAnswer(PRes :PTString = nil; ATerm :AnsiChar = #0; ATimeOut :Integer = 0;
    AEvent :TOnRedirEvent = nil; AContext :Pointer = nil);

  procedure RedirTerminate;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function WinCloseHandle(var AHandle :THandle) :Boolean;
  begin
    Result := True;
    if AHandle <> 0 then begin
      Result := CloseHandle(AHandle);
      AHandle := 0;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    THandleReader = class(TBasis)
    public
      constructor CreateEx(AHandle :THandle);
      destructor Destroy; override;

      function Read(const AStops :TAnsiCharSet = []; ATimeout :Integer = 0) :TAnsiStr;

    private
      FHandle    :THandle;
      FBuffer    :PAnsiChar;
      FBufSize   :Integer;
      FBufPos    :Integer;
      FLoaded    :Integer;

      function ReadPart :Boolean;
      function GetEOF :Boolean;

    public
      property EOF :Boolean read GetEOF;
    end;


  constructor THandleReader.CreateEx(AHandle :THandle);
  begin
    Create;
    FHandle := AHandle;
    FBuffer := MemAllocZero(cTmpBufSize);
    FBufSize := cTmpBufSize;
  end;


  destructor THandleReader.Destroy; {override;}
  begin
    MemFree(FBuffer);
    inherited Destroy;
  end;


  function THandleReader.ReadPart :Boolean;
  var
    vCount :Integer;
  begin
    Result := False;
    vCount := 0;
    if PeekNamedPipe(FHandle, nil, 0, nil, @vCount, nil) then begin
      if vCount > 0 then begin
        if vCount > FBufSize then
          vCount := FBufSize;
        ApiCheck( ReadFile( FHandle, FBuffer^, vCount, DWORD(FLoaded), nil) );
        FBufPos := 0;
        Result := True;
      end;
    end;
  end;


  function THandleReader.Read(const AStops :TAnsiCharSet = []; ATimeout :Integer = 0) :TAnsiStr;
  var
    vLen, vCount :Integer;
    vStart :DWORD;
  begin
    Result := '';
    if not EOF then begin
      vStart := GetTickCount;
      vLen := 0;
      while True do begin
        vCount := FLoaded - FBufPos;
        if vLen = 0 then
          SetString(Result, FBuffer + FBufPos, vCount)
        else begin
          SetLength(Result, vLen + vCount);
          Move((FBuffer + FBufPos)^, (PAnsiChar(Result) + vLen)^, vCount);
        end;
        Inc(FBufPos, vCount);
        Inc(vLen, vCount);

        if not ReadPart then begin
          if Result[length(Result)] in AStops then
            Exit;
          if (ATimeout = 0) or (TickCountDiff(GetTickCount, vStart) > ATimeout) then
            Exit;
          Sleep(1);
        end else
          vStart := GetTickCount;
      end;
    end;
  end;


  function THandleReader.GetEOF :Boolean;
  begin
    Result := (FBufPos = FLoaded) and not ReadPart;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TRedirector = class(TBasis)
    public
      constructor Create; override;
      constructor CreateEx(const ACommand, ACurFolder :TString);
      destructor Destroy; override;

      procedure RunCmd(const ACommand, ACurFolder :TString);
      procedure Send(const AStr :TAnsiStr);
      procedure WaitAnswer(AEvent :TOnRedirEvent; AContext :Pointer);
      procedure Terminate;

    private
      FProcess     :THandle;
      FProcessID   :DWORD;

      FChildRead   :THandle;
      FParentRead  :THandle;

      FChildWrite  :THandle;
      FParentWrite :THandle;

      FChildError  :THandle;
      FParentError :THandle;

      FOutReader   :THandleReader;
      FErrReader   :THandleReader;

      FTimeout     :Integer;
      FTerminator  :AnsiChar;
    end;


  constructor TRedirector.Create; {override;}
  var
    vProcess, vTmpPipe :THandle;
    vAttrs :TSecurityAttributes;
  begin
    inherited Create;

    vAttrs.nLength := sizeof(vAttrs);
    vAttrs.lpSecurityDescriptor := nil;
    vAttrs.bInheritHandle := TRUE;

    vProcess := GetCurrentProcess;

    { Создаем pipe #1 (Для чтения из stdout дочернего процесса) }
    ApiCheck( CreatePipe(vTmpPipe, FChildWrite, @vAttrs, 0) );
    { Создаем копию pipe, которая не может наследоваться }
    ApiCheck( DuplicateHandle(vProcess, vTmpPipe, vProcess, @FParentRead, 0, False, DUPLICATE_SAME_ACCESS) );
    { Закрываем временный handle, который наследуется }
    CloseHandle(vTmpPipe);

    { Создаем pipe #2(Для записи в stdin дочернего процесса) }
    ApiCheck( CreatePipe(FChildRead, vTmpPipe, @vAttrs, 0) );
    { Создаем копию pipe, которая не может наследоваться }
    ApiCheck( DuplicateHandle(vProcess, vTmpPipe, vProcess, @FParentWrite, 0, False, DUPLICATE_SAME_ACCESS) );
    { Закрываем временный handle, который наследуется }
    CloseHandle(vTmpPipe);

    { Создаем pipe #3 (Для чтения из stderror дочернего процесса) }
    ApiCheck( CreatePipe(vTmpPipe, FChildError, @vAttrs, 0) );
    { Создаем копию pipe, которая не может наследоваться }
    ApiCheck( DuplicateHandle(vProcess, vTmpPipe, vProcess, @FParentError, 0, False, DUPLICATE_SAME_ACCESS) );
    { Закрываем временный handle, который наследуется }
    CloseHandle(vTmpPipe);

    FOutReader := THandleReader.CreateEx(FParentRead);
    FErrReader := THandleReader.CreateEx(FParentError);
  end;


  constructor TRedirector.CreateEx(const ACommand, ACurFolder :TString);
  begin
    Create;
    RunCmd(ACommand, ACurFolder);
  end;


  destructor TRedirector.Destroy; {override;}
  begin
    WinCloseHandle(FChildRead);
    WinCloseHandle(FParentRead);
    WinCloseHandle(FChildWrite);
    WinCloseHandle(FParentWrite);
    WinCloseHandle(FChildError);
    WinCloseHandle(FParentError);

    FreeObj(FOutReader);
    FreeObj(FErrReader);
    inherited Destroy;
  end;


  procedure TRedirector.RunCmd(const ACommand, ACurFolder :TString);
  var
    vStartup :TStartupInfo;
    vProcessInfo :TProcessInformation;
    vTmpStr :TString;
  begin
    {Заполняем структуру startup info }
    FillZero(vStartup, sizeof(vStartup));
    vStartup.cb := sizeof(vStartup);
    GetStartupInfo(vStartup);
    PTChar(vStartup.lpTitle) := 'process';
    vStartup.dwFlags := STARTF_USESTDHANDLES;
    vStartup.dwXCountChars := 0;
    vStartup.dwYCountChars := 0;
    vStartup.hStdInput := FChildRead;
    vStartup.hStdOutput := FChildWrite;
    vStartup.hStdError := FChildError;

    SetString(vTmpStr, PTChar(ACommand), length(ACommand));

    { Запускаем процесс }
    ApiCheck( CreateProcess(
      nil,      // pointer to name of executable module
      PTChar(vTmpStr),	// pointer to command line string
      nil,	// pointer to process security attributes
      nil,	// pointer to thread security attributes
      TRUE,	// handle inheritance flag
      CREATE_DEFAULT_ERROR_MODE or DETACHED_PROCESS {or CREATE_NEW_CONSOLE or CREATE_NEW_PROCESS_GROUP or CREATE_NO_WINDOW}, // creation flags
      nil,	// pointer to new environment block
      nil,      // PTChar(ACurFolder), // pointer to current directory name
      vStartup, // startup info
      vProcessInfo)
    );

    FProcess := vProcessInfo.hProcess;
    FProcessID := vProcessInfo.dwProcessId;
  end;


  procedure TRedirector.Terminate;
  begin
    ApiCheck(TerminateProcess(FProcess, 1));
    FProcess := 0;
    FProcessID := 0;
  end;


  procedure TRedirector.Send(const AStr :TAnsiStr);
  var
    vWrite :Integer;
  begin
    ApiCheck( WriteFile(FParentWrite, PAnsiChar(AStr)^, length(AStr), DWORD(vWrite), nil));
  end;


(*
  procedure TRedirector.WaitAnswer(AEvent :TOnRedirEvent; AContext :Pointer);
  var
    vCode :DWORD;
    vStart :DWORD;
    vStr :TAnsiStr;
    vIdle, vFinish :Boolean;
  begin
    Assert(Assigned(AEvent));
    vStart := 0;
    vFinish := False;
    while not vFinish do begin

      vIdle := True;

      while not FErrReader.EOF do begin
        vStr := FErrReader.Read([#13, #10], cDefReadTimeout);
        if not AEvent(reReadErr, vStr, AContext) then
          Exit;
        vIdle := False;
        vStart := 0;
      end;

      while not FOutReader.EOF do begin
        vStr := FOutReader.Read([#13, #10, FTerminator], cDefReadTimeout);
        if (vStr <> '') and (vStr[length(vStr)] = FTerminator) then begin
          vFinish := True;
          Delete(vStr, length(vStr), 1);
        end;
        if not AEvent(reReadOut, vStr, AContext) then
          Exit;
        vIdle := False;
        vStart := 0;
      end;

      if vIdle then
        Sleep(1);

      if not GetExitCodeProcess(FProcess, vCode) or (vCode <> STILL_ACTIVE) then begin
        FProcess := 0;
        FProcessID := 0;
        Exit;
      end;

      if vIdle then begin
        if vStart = 0 then
          vStart := GetTickCount
        else begin
          if (FTimeout <> 0) and (TickCountDiff(GetTickCount, vStart) > FTimeout) then
            Exit;
        end;
        if not AEvent(reIdle, '', AContext) then
          Exit;
      end;
    end;
  end;
*)

  procedure TRedirector.WaitAnswer(AEvent :TOnRedirEvent; AContext :Pointer);
  var
    vCode :DWORD;
    vStart :DWORD;
    vStr :TAnsiStr;
    vIdle, vFinish :Boolean;
  begin
    Assert(Assigned(AEvent));
    vStart := 0;
    vFinish := False;
    while not vFinish do begin

      vIdle := True;

      while not FOutReader.EOF do begin
        vStr := FOutReader.Read([#13, #10, FTerminator], cDefReadTimeout);
        if (vStr <> '') and (vStr[length(vStr)] = FTerminator) then begin
          vFinish := True;
          Delete(vStr, length(vStr), 1);
        end;
        if not AEvent(reReadOut, vStr, AContext) then
          Exit;
        vIdle := False;
        vStart := 0;
      end;

      while not FErrReader.EOF do begin
        vStr := FErrReader.Read([#13, #10], cDefReadTimeout);
        if not AEvent(reReadErr, vStr, AContext) then
          Exit;
        vIdle := False;
        vStart := 0;
      end;

      if vIdle then
        Sleep(1);

      if not GetExitCodeProcess(FProcess, vCode) or (vCode <> STILL_ACTIVE) then begin
        FProcess := 0;
        FProcessID := 0;
        Exit;
      end;

      if vIdle then begin
        if vStart = 0 then
          vStart := GetTickCount
        else begin
          if (FTimeout <> 0) and (TickCountDiff(GetTickCount, vStart) > FTimeout) then
            Exit;
        end;
        if not AEvent(reIdle, '', AContext) then
          Exit;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    Redirector :TRedirector;


  function RedirInited :Boolean;
  begin
    Result := (Redirector <> nil) and (Redirector.FProcess <> 0);
  end;


  procedure RedirChildProcess(const ACommand :TString);
  begin
    if Redirector = nil then
      Redirector := TRedirector.Create;
    if Redirector.FProcess <> 0 then
      AppError('Process already run');
    Redirector.RunCmd(ACommand, '');
  end;


  procedure RedirSendCommand(const ACommand :TString);
  begin
   {$ifdef bDebug}
    TraceF('Send: %s', [ACommand]);
   {$endif bDebug}
    Redirector.Send( ACommand + #10 );
  end;



  var
    ErrStr :TAnsiStr;
    OutStr :TAnsiStr;


  function DefWaitAnswer(AEvent :TRedirEvent; const AStr :TAnsiStr; AContext :Pointer) :Boolean;
  begin
    case AEvent of
      reReadOut : OutStr := OutStr + AStr;
      reReadErr : ErrStr := ErrStr + AStr;
      reIdle    : {};
    end;
    Result := True;
  end;


  procedure RedirReadAnswer(PRes :PTString = nil; ATerm :AnsiChar = #0; ATimeOut :Integer = 0;
    AEvent :TOnRedirEvent = nil; AContext :Pointer = nil);
  begin
    ErrStr := ''; OutStr := '';
    if not assigned(AEvent) then
      AEvent := DefWaitAnswer;
    if ATerm = #0 then
      ATerm := TerminatorChar;

    Redirector.FTimeout := ATimeout;
    Redirector.FTerminator := ATerm;
    Redirector.WaitAnswer(AEvent, AContext);

    if PRes <> nil then
      PRes^ := OutStr;
    if ErrStr <> '' then
      RaiseError(EGDBError, ErrStr);
  end;


  procedure RedirTerminate;
  begin
    Redirector.Terminate;
  end;



initialization

finalization
  FreeObj(Redirector);
end.

{$I Defines.inc}

{$ifndef bTrace} {$undef bTraceError} {$endif}

unit MixErrors;

interface

uses
  Windows,
  MixTypes,
  MixUtils;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

uses
  MixConsts,
  MixDebug;


function GetExceptionClass(P: PExceptionRecord): ExceptClass;
begin
  Result := Exception;
end;


function GetExceptionObject(P: PExceptionRecord): Exception;
begin
 {$ifdef bTraceError}
  SetErrorAddress(P.ExceptionAddress);
 {$endif bTraceError}
  Result := EExternal.CreateFmt(SExternalException, [P.ExceptionCode, P.ExceptionAddress]);
  EExternal(Result).ExceptionRecord := P;
end;


procedure ErrorHandler(ErrorCode: Integer; ErrorAddr: Pointer);
var
  E: Exception;
begin
 {$ifdef bTraceError}
  SetErrorAddress(ErrorAddr);
 {$endif bTraceError}
  E := Exception.CreateFmt(SInternalError, [ErrorCode, ErrorAddr]);
  raise E at ErrorAddr;
end;


function CreateAssertException(const AMessage, AFilename: string; LineNumber: Integer): Exception;
var
  S :string;
begin
  if AMessage <> '' then
    S := AMessage
  else
    S := SAssertionFailed;
  Result := EAssertionFailed.CreateFmt(SAssertError, [S, AFilename, LineNumber]);
end;

procedure RaiseAssertException(const E: Exception; const ErrorAddr, ErrorStack: Pointer);
asm
   MOV     ESP,ECX
   MOV     [ESP],EDX
   MOV     EBP,[EBP]
   JMP     System.@RaiseExcept
end;


procedure AssertErrorHandler(const Message, Filename :string; LineNumber: Integer; ErrorAddr: Pointer);
var
  E: Exception;
begin
 {$ifdef bTraceError}
  SetErrorAddress(ErrorAddr);
 {$endif bTraceError}
  E := CreateAssertException(Message, Filename, LineNumber);
  RaiseAssertException(E, ErrorAddr, Pointer1(@ErrorAddr)+4);
end;


procedure AbstractErrorHandler;
begin
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']);
end;


procedure InitExceptions;
begin
  ErrorProc := @ErrorHandler;
//ExceptProc := @ExceptHandler;
  ExceptionClass := Exception;
  ExceptClsProc := @GetExceptionClass;
  ExceptObjProc := @GetExceptionObject;
  AssertErrorProc := @AssertErrorHandler;
  AbstractErrorProc := @AbstractErrorHandler;
end;


procedure DoneExceptions;
begin
  ErrorProc := nil;
//ExceptProc := nil;
  ExceptionClass := nil;
  ExceptClsProc := nil;
  ExceptObjProc := nil;
  AssertErrorProc := nil;
  AbstractErrorProc := nil;
end;


initialization
  InitExceptions;
finalization
  DoneExceptions;
end.


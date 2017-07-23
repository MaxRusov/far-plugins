
(*
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
*)


procedure AssertErrorHandler(const aMessage, aFilename :TString; aLineNumber: Integer; ErrorAddr: Pointer);
var
  S :TString;
begin
 {$ifdef bTraceError}
  SetErrorAddress(ErrorAddr);
 {$endif bTraceError}
  if aMessage <> '' then
    S := AMessage
  else
    S := SAssertionFailed;
  raise EAssertionFailed.CreateFmt(SAssertError, [S, aFilename, aLineNumber])
    at ErrorAddr;
end;


procedure AbstractErrorHandler;
begin
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']);
end;


procedure InitExceptions;
begin
(*
  ErrorProc := @ErrorHandler;
//ExceptProc := @ExceptHandler;
  ExceptionClass := Exception;
  ExceptClsProc := @GetExceptionClass;
  ExceptObjProc := @GetExceptionObject;
*)
  AssertErrorProc := Pointer(@AssertErrorHandler);
  AbstractErrorProc := Pointer(@AbstractErrorHandler);
end;


procedure DoneExceptions;
begin
(*
  ErrorProc := nil;
//ExceptProc := nil;
  ExceptionClass := nil;
  ExceptClsProc := nil;
  ExceptObjProc := nil;
*)
  AssertErrorProc := nil;
  AbstractErrorProc := nil;
end;


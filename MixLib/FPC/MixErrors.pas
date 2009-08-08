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


  Procedure RunErrorToExcept (ErrNo : Longint; Address,Frame : Pointer);
  Var
    E : Exception;
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ErrorAddr);
   {$endif bTraceError}
    E := Exception.CreateFmt(SInternalError, [ErrNo, Address]);
    Raise E at Address,Frame;
  end;


  procedure AssertErrorHandler(Const AMessage, AFilename :ShortString; LineNo :longint; TheAddr :pointer);
  var
    S :String;
  begin
  //TraceF('AssertErrorHandler... %s, %s', [AMessage, AFileName]);
    If AMessage <> '' then
      S := AMessage
    else
      S := SAssertionFailed;
    Raise EAssertionFailed.Createfmt(SAssertError,[S, AFilename, LineNo])
      at Pointer(theAddr);
  end;


  procedure InitExceptions;
  begin
    AssertErrorProc := @AssertErrorHandler;
    ErrorProc := @RunErrorToExcept;
  end;


  procedure DoneExceptions;
  begin
    AssertErrorProc := nil;
    ErrorProc := nil;
  end;


initialization
  InitExceptions;   
finalization
  DoneExceptions;
end.


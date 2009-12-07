{$I Defines.inc}

unit MSTraceLibMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MSTrace;



  procedure TraceA(AInst :THandle; AMsg :PAnsiChar); stdcall;
  procedure TraceW(AInst :THandle; AMsg :PWideChar); stdcall;

  procedure TraceFmtA(AInst :THandle; AMsg :PAnsiChar; const Args: array of const); stdcall;
  procedure TraceFmtW(AInst :THandle; AMsg :PWideChar; const Args: array of const); stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  procedure TraceA(AInst :THandle; AMsg :PAnsiChar); stdcall;
  begin
    TraceStrA(AInst, AMsg, '');
  end;

  procedure TraceW(AInst :THandle; AMsg :PWideChar); stdcall;
  begin
    TraceStrW(AInst, AMsg, '');
  end;


  procedure TraceFmtA(AInst :THandle; AMsg :PAnsiChar; const Args: array of const); stdcall;
  var
    vTmp :TAnsiStr;
  begin
    vTmp := Format(AMsg, Args);
    TraceStrA(AInst, PAnsiChar(vTmp), '');
  end;


  procedure TraceFmtW(AInst :THandle; AMsg :PWideChar; const Args: array of const); stdcall;
  var
    vTmp :TWideStr;
  begin
    vTmp := Format(AMsg, Args);
    TraceStrW(AInst, PWideChar(vTmp), '');
  end;


end.

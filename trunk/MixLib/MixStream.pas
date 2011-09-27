{$I Defines.inc}

unit MixStream;

interface

  uses
    Windows,
    ActiveX,
    MixTypes,
    MixConsts,
    MixUtils,
    MixClasses;

(*
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;
*)

(*
  type
    TStreamAdapter = class(TInterfacedObject, IStream)
    private
      FStream: TStream;
      FOwnership: TStreamOwnership;
    public
      constructor Create(Stream: TStream; Ownership: TStreamOwnership = soReference);
      destructor Destroy; override;
      function Read(pv: Pointer; cb: Longint;
        pcbRead: PLongint): HResult; virtual; stdcall;
      function Write(pv: Pointer; cb: Longint;
        pcbWritten: PLongint): HResult; virtual; stdcall;
      function Seek(dlibMove: Largeint; dwOrigin: Longint;
        out libNewPosition: Largeint): HResult; virtual; stdcall;
      function SetSize(libNewSize: Largeint): HResult; virtual; stdcall;
      function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
        out cbWritten: Largeint): HResult; virtual; stdcall;
      function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall;
      function Revert: HResult; virtual; stdcall;
      function LockRegion(libOffset: Largeint; cb: Largeint;
        dwLockType: Longint): HResult; virtual; stdcall;
      function UnlockRegion(libOffset: Largeint; cb: Largeint;
        dwLockType: Longint): HResult; virtual; stdcall;
      function Stat(out statstg: TStatStg;
        grfStatFlag: Longint): HResult; virtual; stdcall;
      function Clone(out stm: IStream): HResult; virtual; stdcall;
      property Stream: TStream read FStream;
      property StreamOwnership: TStreamOwnership read FOwnership write FOwnership;
    end;
*)
  type
    TMemStream = class(TComBasis, IStream)
    private
      function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; stdcall;
      function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; stdcall;
      function Seek(dlibMove: Largeint; dwOrigin: Longint; out libNewPosition: Largeint): HResult; stdcall;
      function SetSize(libNewSize: Largeint): HResult; stdcall;
      function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult; stdcall;
      function Commit(grfCommitFlags: Longint): HResult; stdcall;
      function Revert: HResult; stdcall;
      function LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
      function UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
      function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; stdcall;
      function Clone(out stm: IStream): HResult; stdcall;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


(*
{ TStreamAdapter }

constructor TStreamAdapter.Create(Stream: TStream;
  Ownership: TStreamOwnership);
begin
  inherited Create;
  FStream := Stream;
  FOwnership := Ownership;
end;

destructor TStreamAdapter.Destroy;
begin
  if FOwnership = soOwned then
  begin
    FStream.Free;
    FStream := nil;
  end;
  inherited Destroy;
end;

function TStreamAdapter.Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
var
  NumRead: Longint;
begin
  try
    if pv = Nil then
    begin
      Result := STG_E_INVALIDPOINTER;
      Exit;
    end;
    NumRead := FStream.Read(pv^, cb);
    if pcbRead <> Nil then pcbRead^ := NumRead;
    Result := S_OK;
  except
    Result := S_FALSE;
  end;
end;

function TStreamAdapter.Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
var
  NumWritten: Longint;
begin
  try
    if pv = Nil then
    begin
      Result := STG_E_INVALIDPOINTER;
      Exit;
    end;
    NumWritten := FStream.Write(pv^, cb);
    if pcbWritten <> Nil then pcbWritten^ := NumWritten;
    Result := S_OK;
  except
    Result := STG_E_CANTSAVE;
  end;
end;

function TStreamAdapter.Seek(dlibMove: Largeint; dwOrigin: Longint;
  out libNewPosition: Largeint): HResult;
var
  NewPos: Integer;
begin
  try
    if (dwOrigin < STREAM_SEEK_SET) or (dwOrigin > STREAM_SEEK_END) then
    begin
      Result := STG_E_INVALIDFUNCTION;
      Exit;
    end;
    NewPos := FStream.Seek(LongInt(dlibMove), dwOrigin);
    if @libNewPosition <> nil then libNewPosition := NewPos;
    Result := S_OK;
  except
    Result := STG_E_INVALIDPOINTER;
  end;
end;

function TStreamAdapter.SetSize(libNewSize: Largeint): HResult;
begin
  try
    FStream.Size := LongInt(libNewSize);
    if libNewSize <> FStream.Size then
      Result := E_FAIL
    else
      Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TStreamAdapter.CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
  out cbWritten: Largeint): HResult;
const
  MaxBufSize = 1024 * 1024;  // 1mb
var
  Buffer: Pointer;
  BufSize, N, I: Integer;
  BytesRead, BytesWritten, W: LargeInt;
begin
  Result := S_OK;
  BytesRead := 0;
  BytesWritten := 0;
  try
    if cb > MaxBufSize then
      BufSize := MaxBufSize
    else
      BufSize := Integer(cb);
    GetMem(Buffer, BufSize);
    try
      while cb > 0 do
      begin
        if cb > MaxInt then
          I := MaxInt
        else
          I := cb;
        while I > 0 do
        begin
          if I > BufSize then N := BufSize else N := I;
          Inc(BytesRead, FStream.Read(Buffer^, N));
          W := 0;
          Result := stm.Write(Buffer, N, @W);
          Inc(BytesWritten, W);
          if (Result = S_OK) and (Integer(W) <> N) then Result := E_FAIL;
          if Result <> S_OK then Exit;
          Dec(I, N);
        end;
        Dec(cb, I);
      end;
    finally
      FreeMem(Buffer);
      if (@cbWritten <> nil) then cbWritten := BytesWritten;
      if (@cbRead <> nil) then cbRead := BytesRead;
    end;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TStreamAdapter.Commit(grfCommitFlags: Longint): HResult;
begin
  Result := S_OK;
end;

function TStreamAdapter.Revert: HResult;
begin
  Result := STG_E_REVERTED;
end;

function TStreamAdapter.LockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result := STG_E_INVALIDFUNCTION;
end;

function TStreamAdapter.UnlockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result := STG_E_INVALIDFUNCTION;
end;

function TStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
begin
  Result := S_OK;
  try
    if (@statstg <> nil) then
      with statstg do
      begin
        dwType := STGTY_STREAM;
        cbSize := FStream.Size;
        mTime.dwLowDateTime := 0;
        mTime.dwHighDateTime := 0;
        cTime.dwLowDateTime := 0;
        cTime.dwHighDateTime := 0;
        aTime.dwLowDateTime := 0;
        aTime.dwHighDateTime := 0;
        grfLocksSupported := LOCK_WRITE;
      end;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TStreamAdapter.Clone(out stm: IStream): HResult;
begin
  Result := E_NOTIMPL;
end;
*)


  function TMemStream.Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.Seek(dlibMove: Largeint; dwOrigin: Longint; out libNewPosition: Largeint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.SetSize(libNewSize: Largeint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.Commit(grfCommitFlags: Longint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.Revert: HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; {stdcall;}
  begin
    Sorry;
  end;

  function TMemStream.Clone(out stm: IStream): HResult; {stdcall;}
  begin
    Sorry;
  end;



end.

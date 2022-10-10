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


  type
    TStreamAdapter = class(TComBasis, IStream)
    public
      constructor Create(Stream: TStream; Ownership :Boolean = False);
      destructor Destroy; override;

      function Read(pv: Pointer; cb: FixedUInt; pcbRead: PFixedUInt): HResult; virtual; stdcall;
      function Write(pv: Pointer; cb: FixedUInt; pcbWritten: PFixedUInt): HResult; virtual; stdcall;
      function Seek(dlibMove: Largeint; dwOrigin: DWORD; out libNewPosition: LargeUInt): HResult; virtual; stdcall;
      function SetSize(libNewSize: LargeUInt): HResult; virtual; stdcall;
      function CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HResult; virtual; stdcall;
      function Commit(grfCommitFlags: DWORD): HResult; virtual; stdcall;
      function Revert: HResult; virtual; stdcall;
      function LockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult; virtual; stdcall;
      function UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult; virtual; stdcall;
      function Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult; virtual; stdcall;
      function Clone(out stm: IStream): HResult; virtual; stdcall;

    private
      FStream :TStream;
      FOwnership :Boolean;

    public
      property Stream: TStream read FStream;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  constructor TStreamAdapter.Create(Stream: TStream; Ownership :Boolean = False);
  begin
    inherited Create;
    FStream := Stream;
    FOwnership := Ownership;
  end;


  destructor TStreamAdapter.Destroy;
  begin
    if FOwnership then
      FreeObj(FStream);
    inherited Destroy;
  end;


  function TStreamAdapter.Read(pv: Pointer; cb: FixedUInt; pcbRead: PFixedUInt): HResult;
  var
    NumRead: LongInt;
  begin
    try
      if pv = nil then begin
        Result := STG_E_INVALIDPOINTER;
        Exit;
      end;
      NumRead := FStream.Read(pv^, cb);
      if pcbRead <> nil then
        pcbRead^ := NumRead;
      Result := S_OK;
    except
      Result := S_FALSE;
    end;
  end;

  function TStreamAdapter.Write(pv: Pointer; cb: FixedUInt; pcbWritten: PFixedUInt): HResult;
  var
    NumWritten: LongInt;
  begin
    try
      if pv = nil then begin
        Result := STG_E_INVALIDPOINTER;
        Exit;
      end;
      NumWritten := FStream.Write(pv^, cb);
      if pcbWritten <> nil then
        pcbWritten^ := NumWritten;
      Result := S_OK;
    except
      Result := STG_E_CANTSAVE;
    end;
  end;

  function TStreamAdapter.Seek(dlibMove: Largeint; dwOrigin: DWORD; out libNewPosition: LargeUInt): HResult;
  var
    NewPos: LargeUInt;
  begin
    try
      if (Integer(dwOrigin) < STREAM_SEEK_SET) or (dwOrigin > STREAM_SEEK_END) then begin
        Result := STG_E_INVALIDFUNCTION;
        Exit;
      end;
      NewPos := FStream.Seek(dlibMove, TSeekOrigin(dwOrigin));
      if @libNewPosition <> nil then
       libNewPosition := NewPos;
      Result := S_OK;
    except
      Result := STG_E_INVALIDPOINTER;
    end;
  end;

  function TStreamAdapter.SetSize(libNewSize: LargeUInt): HResult;
  var
    LPosition: Int64;
  begin
    try
      LPosition := FStream.Position;
      FStream.Size := libNewSize;
      if FStream.Size < LPosition then
        LPosition := FStream.Size;
      FStream.Position := LPosition;
      if libNewSize <> FStream.Size then
        Result := E_FAIL
      else
        Result := S_OK;
    except
      Result := E_UNEXPECTED;
    end;
  end;

  function TStreamAdapter.CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HResult;
  const
    MaxBufSize = 1024 * 1024;  // 1mb
  var
    Buffer: Pointer;
    BufSize, N, I, R: Integer;
    BytesRead, BytesWritten :LargeUInt;
    W :FixedUInt;
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
        while cb > 0 do begin
          if cb > MaxInt then
            I := MaxInt
          else
            I := cb;
          while I > 0 do begin
            if I > BufSize then
              N := BufSize
            else
              N := I;
            R := FStream.Read(Buffer^, N);
            if R = 0 then
              Exit; // The end of the stream was hit.
            Inc(BytesRead, R);
            W := 0;
            Result := stm.Write(Buffer, R, @W);
            Inc(BytesWritten, W);
            if (Result = S_OK) and (Integer(W) <> R) then
              Result := E_FAIL;
            if Result <> S_OK then
              Exit;
            Dec(I, R);
            Dec(cb, R);
          end;
        end;
      finally
        FreeMem(Buffer);
        if (@cbWritten <> nil) then
          cbWritten := BytesWritten;
        if (@cbRead <> nil) then
          cbRead := BytesRead;
      end;
    except
      Result := E_UNEXPECTED;
    end;
  end;

  function TStreamAdapter.Commit(grfCommitFlags: DWORD): HResult;
  begin
    Result := S_OK;
  end;

  function TStreamAdapter.Revert: HResult;
  begin
    Result := STG_E_REVERTED;
  end;

  function TStreamAdapter.LockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult;
  begin
    Result := STG_E_INVALIDFUNCTION;
  end;

  function TStreamAdapter.UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult;
  begin
    Result := STG_E_INVALIDFUNCTION;
  end;

  function TStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult;
  begin
    Result := S_OK;
    try
      if (@statstg <> nil) then
        begin
          FillChar(statstg, SizeOf(statstg), 0);
          statstg.dwType := STGTY_STREAM;
          statstg.cbSize := FStream.Size;
          statstg.grfLocksSupported := LOCK_WRITE;
        end;
    except
      Result := E_UNEXPECTED;
    end;
  end;

  function TStreamAdapter.Clone(out stm: IStream): HResult;
  begin
    Result := E_NOTIMPL;
  end;


end.

{$I Defines.inc}

{$ifdef bDelphi}
 {$define DebugInfo}
 {$ifdef DebugInfo} {$D+,L+,Y+} {$else} {$D-} {$endif}
{$endif bDelphi}

unit MixMemWin;

interface

  uses
    Windows,
    MixTypes;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  type
   {$ifdef bFreePascal}
   {$ifdef bFPC23}
    TMInteger = TUnsPtr;
   {$else}
    TMInteger = TIntPtr;
   {$endif bFPC23}
   {$else}
    TMInteger = TIntPtr;
   {$endif bFreePascal}


  var
    gHeap :THandle;


  function NewGetMem(DataSize :TMInteger) :Pointer;
  begin
    if DataSize <= 0 then begin
      Result := nil;
      Exit;
    end;

//  Result := Pointer(GlobalAlloc(GMEM_FIXED, DataSize));
    Result := HeapAlloc(gHeap, 0, DataSize);

//  if Result <> nil then begin
//    Inc(AllocMemSize, GlobalSize(HGlobal(Result)));
//    Inc(AllocMemCount);
//  end;
  end;


  function NewFreeMem(DataPtr :Pointer) :TMInteger;
  begin
    if DataPtr = nil then begin
      Result := 0;
      Exit;
    end;

//  Dec(AllocMemSize, GlobalSize(HGlobal(DataPtr)));
//  Dec(AllocMemCount);

//  GlobalFree(HGLOBAL(DataPtr));
    HeapFree(gHeap, 0, DataPtr);


    Result := 0;
  end;


  function NewReallocMem(DataPtr :Pointer; DataSize :TMInteger): Pointer;
  begin
    if (DataPtr = nil) or (DataSize <= 0) then begin
      Result := nil;
      Exit;
    end;

//  Dec(AllocMemSize, GlobalSize(HGlobal(DataPtr)));
//  Dec(AllocMemCount);

//  Result := Pointer(GlobalRealloc(HGLOBAL(DataPtr), DataSize, GMEM_MOVEABLE));
    Result := HeapRealloc(gHeap, 0, DataPtr, DataSize);

//  if Result <> nil then begin
//    Inc(AllocMemSize, GlobalSize(HGlobal(Result)));
//    Inc(AllocMemCount);
//  end;
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bFreePascal}
  function NewReallocMem1(var DataPtr :Pointer; DataSize :TMInteger): Pointer;
  begin
    if DataPtr = nil then
      DataPtr := NewGetMem(DataSize)
    else
    if DataSize = 0 then begin
      NewFreeMem(DataPtr);
      DataPtr := nil;
    end else
      DataPtr := NewReallocMem(DataPtr, DataSize);

    Result := DataPtr;
  end;


  function NewFreememSize(p :pointer; Size :TMInteger) :TMInteger;
  begin
    Result := NewFreeMem(P);
  end;


  function NewAllocMem(Size :TMInteger) :Pointer;
  begin
    Result := NewGetMem(Size);
    if Result <> nil then
      FillChar(Result^, Size, 0);
  end;


  function NewMemSize(p :Pointer) :TMInteger;
  begin
    Result := 0 
  end;


  function NewGetHeapStatus :THeapStatus;
  begin
    FillChar(Result, sizeof(Result), 0);
  end;


  function NewGetFPCHeapStatus :TFPCHeapStatus;
  begin
    FillChar(Result, sizeof(Result), 0);
  end;
 {$endif bFreePascal}


 {-----------------------------------------------------------------------------}

  const
   {$ifdef bFreePascal}
    DebugMemMgr :TMemoryManager = (
      NeedLock     :false;
      GetMem       :NewGetMem;
      FreeMem      :NewFreeMem;
      FreememSize  :NewFreememSize;
      AllocMem     :NewAllocMem;
      ReallocMem   :NewReallocMem1;
      MemSize      :NewMemSize;
     {$ifdef bFPC23}
      InitThread   :nil;
      DoneThread   :nil;
      RelocateHeap :nil;
     {$endif bFPC23}
      GetHeapStatus :NewGetHeapStatus;
      GetFPCHeapStatus :NewGetFPCHeapStatus;	
    );
   {$else}
    DebugMemMgr :TMemoryManager = (
      GetMem     :NewGetMem;
      FreeMem    :NewFreeMem;
      ReallocMem :NewReallocMem
    );
   {$endif bFreePascal}


  var
    OldMemMgr :TMemoryManager;


  var
    ManagerInstalled :Boolean = False;
   {$ifdef bFreePascal}
    AllocMemCount :Integer = 0;
   {$endif bFreePascal}


  procedure InstallMemoryManager;
  begin
    if not ManagerInstalled and (AllocMemCount = 0) then begin

      GetMemoryManager(OldMemMgr);
      SetMemoryManager(DebugMemMgr);

      gHeap := GetProcessHeap;

      ManagerInstalled := True
    end;
  end;


  procedure DeinstallMemoryDebugManager;
  begin
    if ManagerInstalled then begin
      SetMemoryManager(OldMemMgr);
      ManagerInstalled := False;
    end;
  end;


initialization
  InstallMemoryManager;

finalization
  DeinstallMemoryDebugManager;
end.

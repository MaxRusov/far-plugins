{$I Defines.inc}

{$OverflowChecks Off}

{$ifdef bDelphi}
 {$Define DebugInfo}
 {$ifdef DebugInfo} {$D+,L+,Y+} {$else} {$D-} {$endif}
{$endif bDelphi}

{ Эта опция включает ведение статистики по аллокации памяти в течении всего }
{ времени работы программы }

{-$Define bMemReport}

{$ifdef bFreePascal}
 {$Define bMemCallstack}
{$endif bFreePascal}

unit MixMemCheck;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixDebug;

  type
    TMemListSort = (
      ByAddr,
      ByCount,
      BySize
    );

  const
    EmptyFiller = #$11;
    GuardFiller = #$FF;

   {$ifdef b64}
    EmptyFillerPtr = Pointer($1111111111111111);
   {$else}
    EmptyFillerPtr = Pointer($11111111);
   {$endif b64}

  var
    MemAllocSize     :TUnsPtr = 0;
    MemAllocCount    :TIntPtr = 0;
    MemOverrunCount  :TIntPtr = 0;

    MemAllocSizeTop  :TUnsPtr = 0;
    MemAllocCountTop :TIntPtr = 0;
    MaxBlockSize     :TIntPtr = 0;

    MemAllocSizeInc  :TInt64  = 0;
    MemAllocCountInc :TInt64  = 0;

  var
    BreakAddr :Pointer = Pointer(-1);
    BreakPtr  :Pointer = Pointer(-1);

  var
    DebugManagerInstalled :Boolean = False;

  procedure InstallDebugManager;
  procedure DeinstallDebugManager;
  procedure ReportDebugManager;

  function GetStackFrames :Boolean;

  function AllBlocksValid :Boolean;
  function MemReport(ASort :TMemListSort) :Boolean;
 {$ifdef bMemReport}
  function TotalMemReport(ASort :TMemListSort) :Boolean;
 {$endif bMemReport}
  procedure MemIncAllocInfo(var ACount, ASize :TUnsPtr);


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


  const
   {$ifdef bMemCallstack}
    cStackDepth = 3;
   {$else}
    cStackDepth = 1;
   {$endif bMemCallstack}


  type
    TCallstack = array[0..cStackDepth-1] of Pointer;



  const
    cBlockAlign = 16; {???}

  function SizeAlign(ASize :TIntPtr) :TIntPtr;
  begin
//  Result := (ASize + (cBlockAlign - 1)) and not (cBlockAlign - 1)
    Result := ASize;
  end;


{------------------------------------------------------------------------------}

  function IntMin(L1, L2 :TIntPtr) :TIntPtr;
  begin
    if L1 < L2 then
      Result := L1
    else
      Result := L2;
  end;


  function PtrCompare(P1, P2 :Pointer) :Integer;
  begin
    if Pointer1(P1) > Pointer1(P2) then
      Result := 1
    else
    if Pointer1(P1) < Pointer1(P2) then
      Result := -1
    else
      Result := 0;
  end;


  function GetStackFrames :Boolean;
  begin
   {$ifopt W+}
    Result := True;
   {$else}
    Result := False;
   {$endif W+}
  end;


 {-----------------------------------------------------------------------------}

  function StrPtr(Ptr :Pointer) :TString;
  begin
    Result := HexStr(TIntPtr(Ptr), {$ifdef b64}16{$else}8{$endif b64});
  end;


  function StrInt(Num :TInt64) :TString;
  begin
    Result := Int64ToStr(Num);
  end;


  procedure Trace(const TraceMsg :TString);
  begin
    MixDebug.Trace(TraceMsg);
  end;


  function ShowError(const AHeader, AMess :TString; Opt :Integer) :Integer;
  begin
   {$ifdef bWindows}
    Result := MessageBox(0, PTChar(AMess), PTChar(AHeader),
      {MB_Service_Notification MB_ApplModal or} Opt);
   {$else}
    Result := IDOK;
   {$endif bWindows}
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

 {$ifdef bFreePascal}

 {$ifdef b64}

  function DetectAllocAddr :Pointer;
  begin
    Result := ReturnAddr2;
  end;

 {$else}

  function DetectAllocAddr :Pointer;
  begin
    Result := nil
  end;

 {$endif b64}


 {-------------------------------------}
 {$else}

  const
    JumpCode = $25FF;


 {$ifdef bWindows}

  function GetStackFrame3 :Pointer;
  asm
    MOV  EAX, EBP
    MOV  EAX, [EAX]
    MOV  EAX, [EAX]
  end;


  function ReturnAddrGetMem :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX + 2 * 4]
  end;


  function ReturnAddrReallocMem :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX +  3 * 4]
  end;


  function ReturnAddrReallocMem1 :Pointer;
  asm
    MOV  EAX, EBP
    MOV  EAX, [EAX +  3 * 4]
  end;


  function ReturnAddrNewRecord :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX ,[EAX +  4 * 4]
  end;


  function ReturnAddrCreate1 :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX +  8 * 4]
  end;


  function ReturnAddrCreate2 :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX + 13 * 4]
  end;


  function IsGetMem(Addr :Pointer) :Boolean;
  begin
    Result := PWord(PChar(Addr) - 8)^ = $0A74;
  end;

  function IsReallocMem(Addr :Pointer) :Boolean;
  begin
    Result := PWord(PChar(Addr) - 8)^ = $D089;
  end;

  function IsObjSetup(Addr :Pointer) :Boolean;
  begin
   {$ifdef Ver120} {Delphi 4}
    Result := PCardinal(PChar(Addr) - 10)^ = $523674C0;
   {$else}
    Result := PWord(PChar(Addr) - 8)^ = $521E;
   {$endif Ver120}
  end;


  function IsNewAnsiString(Addr :Pointer) :Boolean;
  begin
    Result := PUnsPtr(PChar(Addr) - 9)^ = $09C08350;
  end;


  function IsStrSetLength(Addr :Pointer) :Boolean;
  begin
    Result := PUnsPtr(PChar(Addr) - 9)^ = $E0895009;
  end;

  function IsNewRecord(Addr :Pointer) :Boolean;
  begin
//  procedure _New( size: Longint; typeInfo: Pointer);
//  asm
//    PUSH    EDX             52
//    CALL    _GetMem         E8 xx xx xx xx
//    POP     EDX             5A
//    TEST    EAX,EAX         85 C0
//    JE      @@exit          74 07
//    PUSH    EAX             50
//    CALL    _Initialize     E8 xx xx xx xx
//    POP     EAX             C3
//    @@exit:
//  end;
    Result := PUnsPtr(PChar(Addr))^ = $74C0855A;
  end;

  function IsNewInstance(Addr :Pointer) :Boolean;
  var
    P1, P2 :Pointer;
  begin
    P1 := @TObject.NewInstance;
    if PWord(P1)^ = JumpCode then
      P1 := PPointer(PPointer(PChar(P1) + 2)^)^;

    P2 := @TObject.FreeInstance;
    if PWord(P2)^ = JumpCode then
      P2 := PPointer(PPointer(PChar(P2) + 2)^)^;

    Result := (PChar(Addr) > PChar(P1)) and (PChar(Addr) < PChar(P2));
  end;


//function IsNewInstance(Addr :Pointer) :Boolean;
//begin
//  Result :=
//    (Integer(Addr) > Integer(@TObject.NewInstance)) and
//    (Integer(Addr) < Integer(@TObject.FreeInstance))
//end;


  function IsObjectCreate(Addr :Pointer) :Boolean;
  var
    P1, P2 :Pointer;
  begin
    P1 := @TObject.Create;
    if PWord(P1)^ = JumpCode then
      P1 := PPointer(PPointer(PChar(P1) + 2)^)^;

    P2 := @TObject.Destroy;
    if PWord(P2)^ = JumpCode then
      P2 := PPointer(PPointer(PChar(P2) + 2)^)^;

    Result := (PChar(Addr) > PChar(P1)) and (PChar(Addr) < PChar(P2));
  end;


//function IsObjectCreate(Addr :Pointer) :Boolean;
//begin
//  Result :=
//    (Integer(Addr) > Integer(@TObject.Create)) and
//    (Integer(Addr) < Integer(@TObject.Destroy))
//end;

  function DetectAllocAddr :Pointer;
    { Delphi версия }
  begin
    Result := ReturnAddr2;
    if IsGetMem(Result) then begin
      Result := ReturnAddrGetMem;
      if IsNewInstance(Result) then begin
        Result := ReturnAddrCreate1;
        if IsObjectCreate(Result) then begin
          Result := ReturnAddrCreate2;
        end else begin
          Result := ReturnAddr3;
        end;
      end else
      if IsNewRecord(Result) then begin
        Result := ReturnAddrNewRecord;
      end else
      if IsNewAnsiString(Result) then begin
        Result := Pointer(1); { Для строк не поддерживается... }
//      Result := GetStackFrame3;
//      if Result <> Pointer(1) then
//        Result := ReturnAddr3;
      end;
    end else
    if IsReallocMem(Result) then begin
      Result := ReturnAddrReallocMem;
    end else
    if IsObjSetup(Result) then begin
      Result := ReturnAddr3;
    end else begin
      Result := nil;
    end;
  end;

 {$else}

  function ReturnAddrGetMem :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX+4 + 2*4]
  end;

  function ReturnAddrReallocMem :Pointer;
  asm
    MOV  EAX, [EBP]
    MOV  EAX, [EAX +  5 * 4]
  end;

  function ReturnAddrReallocMem1 :Pointer;
  asm
    MOV  EAX, [EBP +  3 * 4]
  end;


  function IsGetMem(Addr :Pointer) :Boolean;
  begin
    Result :=
      (PCardinal(PChar(Addr) - 10)^ = $157EC085) or  {Release signature}
      (PCardinal(PChar(Addr) - 10)^ = $04438D21);    {Debug Signature}
  end;


  function IsObjSetup(Addr :Pointer) :Boolean;
  begin
    Result := PCardinal(PChar(Addr) - 9)^ = $523574C0;
  end;


  function IsReallocMem(Addr :Pointer) :Boolean;
  begin
    Result := PCardinal(PChar(Addr) - 9)^ = $C28BC35B;
  end;


  function IsNewInstance(Addr :Pointer) :Boolean;
  var
    P1, P2 :Pointer;
  begin
    P1 := @TObject.NewInstance;
    if PWord(P1)^ = JumpCode then
      P1 := PPointer(PPointer(PChar(P1) + 2)^)^;

    P2 := @TObject.FreeInstance;
    if PWord(P2)^ = JumpCode then
      P2 := PPointer(PPointer(PChar(P2) + 2)^)^;

    Result := (PChar(Addr) > PChar(P1)) and (PChar(Addr) < PChar(P2));
  end;


  function DetectAllocAddr :Pointer;
    { Kylix версия }
  begin
    Result := ReturnAddr2;
    if IsGetMem(Result) then begin
      Result := ReturnAddrGetMem;
      if IsNewInstance(Result) then begin
        Result := ReturnAddr3;
      end else
      if IsObjSetup(Result) then begin
        Result := ReturnAddr3;
      end else
      if IsReallocMem(Result) then begin
        Result := ReturnAddrReallocMem;
      end;
    end else
      Result := nil;
  end;

 {$endif bWindows}

 {$endif bFreePascal}

{------------------------------------------------------------------------------}

  function ReadProcessMemory(Process :THandle; Address :Pointer; Dest :Pointer; Size :TUnsPtr; BytesRead :PUnsPtr) :Longbool;
    stdcall; external 'kernel32' name 'ReadProcessMemory';


  procedure DetectCallstack(var AStack :TCallstack; AFrame :Pointer);
  var
    I :Integer;
    vProcess :THandle;
    vRead :SIZE_T;
    vBuf :Array[0..1] of Pointer;
  begin
    vProcess := GetCurrentProcess;
    for I := 0 to cStackDepth - 1 do begin
      if (AFrame = nil) or not ReadProcessMemory(vProcess, AFrame, @vBuf, SizeOf(vBuf), @vRead) or (vRead <> SizeOf(vBuf)) then
        Exit;
      AStack[I] := vBuf[1];
      AFrame := vBuf[0];
    end;
  end;


{------------------------------------------------------------------------------}
{                                                                              }
{------------------------------------------------------------------------------}

  var
    OldMemMgr :TMemoryManager;
    HeapLock  :TRTLCriticalSection;

  type
    PAllocGaurd = ^TAllocGuard;
    TAllocGuard = Pointer {array[1..4] of Char};

    PAllocFrame = ^TAllocFrame;
    TAllocFrame = packed record
      MSize   :TIntPtr;
      MPrev   :PAllocFrame;
      MNext   :PAllocFrame;
      MStack  :TCallstack;
      MGuard  :TAllocGuard;
    end;

  var
    FFirst :PAllocFrame = nil;
    FLast  :PAllocFrame = nil;


  function AddFrame(Frame :PAllocFrame) :Boolean;
  begin
    if FLast = nil then begin
      FFirst := Frame;
      Frame.MPrev := nil;
      Frame.MNext := nil;
      FLast := Frame;
    end else
    begin
      FLast.MNext := Frame;
      Frame.MPrev := FLast;
      Frame.MNext := nil;
      FLast := Frame;
    end;
    Result := True;
  end;


  function DelFrame(Frame :PAllocFrame) :Boolean;
  begin
    Result := False;

    if Frame.MPrev <> nil then begin
      if Frame.MPrev.MNext <> Frame then
        Exit;
      Frame.MPrev.MNext := Frame.MNext;
    end else
    begin
      if FFirst <> Frame then
        Exit;
      FFirst := Frame.MNext;
    end;

    if Frame.MNext <> nil then begin
      if Frame.MNext.MPrev <> Frame then
        Exit;
      Frame.MNext.MPrev := Frame.MPrev;
    end else
    begin
      if FLast <> Frame then
        Exit;
      FLast := Frame.MPrev;
    end;

    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  type
    PMemBlock = ^TMemBlock;
    TMemBlock = record
      Size    :TInt64;
      Count   :TInt64;
      Maximal :TIntPtr;
      Stack   :TCallstack;
      Next    :PMemBlock;
    end;


  function CompStack(const AStack1, AStack2 :TCallstack) :Integer;
 {$ifdef bMemCallstack}
  var
    I :Integer;
  begin
    for I := 0 to cStackDepth - 1 do begin
      Result := PtrCompare(AStack1[I], AStack2[I]);
      if Result <> 0 then
        Exit;
    end;
    Result := 0;
 {$else}
  begin
    Result := PtrCompare(AStack1[0], AStack2[0]);
 {$endif bMemCallstack}
  end;

  function StrStack(const AStack :TCallstack) :TString;
 {$ifdef bMemCallstack}
  var
    I :Integer;
  begin
    Result := '';
    for I := 0 to cStackDepth - 1 do begin
      if I > 0 then
        Result := Result + '-';
      Result := Result + StrPtr(AStack[I]);
    end;
 {$else}
  begin
    Result := StrPtr(AStack[0]);
 {$endif bMemCallstack}
  end;


  procedure AddLeak(var ARoot :PMemBlock; const AStack :TCallstack; ACount, ASize :TInt64; AMaximal :TIntPtr; Detailed :Boolean);
  var
    P :PMemBlock;
    L :PMemBlock;
    N :PMemBlock;
  begin
    P := ARoot;
    L := nil;
    while (P <> nil) and (CompStack(P.Stack, AStack) < 0) do begin
      L := P;
      P := P.Next;
    end;

    if (P <> nil) and (CompStack(P.Stack, AStack) = 0) and not Detailed then begin
      {Accumulate...}
      N := P;
    end else
    begin
      if DebugManagerInstalled then
        N := OldMemMgr.GetMem(SizeOf(TMemBlock))
      else
        GetMem(N, SizeOf(TMemBlock));

      FillChar(N^, SizeOf(N^), 0);

      N.Next := P;
      if L <> nil then
        L.Next := N;

      if L = nil then
        ARoot := N;
    end;

    N.Stack := AStack;
    Inc(N.Size, ASize);
    Inc(N.Count, ACount);
    if AMaximal > N.Maximal then
      N.Maximal := AMaximal;
  end;


  function SortLeakBy(P :PMemBlock; AByWhat :TMemListSort) :PMemBlock;
  var
    T, T0, B, B0, L :PMemBlock;
    M, K :TInt64;
  begin
    Result := nil;

    L := nil;
    while P <> nil do begin
      M := -MaxInt - 1; B := nil; B0 := nil;

      T0 := nil; T := P;
      while T <> nil do begin
        if AByWhat = ByCount then
          K := T.Count
        else
          K := T.Size;
        if K > M then begin
          M := K;
          B0 := T0; B := T;
        end;
        T0 := T; T := T.Next;
      end;

      if B0 <> nil then
        B0.Next := B.Next;
      if B = P then
        P := B.Next;

      if Result = nil then
        Result := B;
      if L <> nil then
        L.Next := B;

      B.Next := nil;
      L := B;
    end;
  end;


  function BuildSortedList(Detailed :Boolean) :PMemBlock;
  var
    P :PAllocFrame;
  begin
    Result := nil;
    P := FFirst;
    while P <> nil do begin
      AddLeak(Result, P.MStack, 1, P.MSize, P.MSize, Detailed);
      P := P.MNext;
    end;
  end;


  procedure PrintLeakList(Detailed :Boolean);
  var
    P, N   :PMemBlock;
  begin
    P := BuildSortedList(Detailed);
    while P <> nil do begin
      if Detailed then begin
        Trace('Leak: ' + StrInt(P.Size) + ' bytes allocated at ' + StrStack(P.Stack));
      end else begin
        Trace('Leak: ' + StrInt(P.Size) + ' bytes in ' + StrInt(P.Count) + ' block(s) allocated at ' + StrStack(P.Stack));
      end;
      N := P.Next;
      Dispose(P);
      P := N;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GuardCheck(P :Pointer; Size :Integer) :Boolean;
  var
    PC :PChar;
    I  :Integer;
  begin
    PC := PChar(P);
    for I := 0 to Size - 1 do begin
      if PC^ <> GuardFiller then begin
        Result := False;
        Exit;
      end;
    end;
    Result := True;
  end;


  function SizeOfData(DataPtr :Pointer) :TIntPtr;
  begin
    with PAllocFrame( PChar(DataPtr) - SizeOf(TAllocFrame) )^ do
      Result := MSize;
  end;


  function MemBlockValid(DataPtr :Pointer; ANotify :Boolean) :Boolean;
  var
    AllocPtr  :PAllocFrame;
    DataSize  :TIntPtr;
    AllocSize :TIntPtr;
  begin
    AllocPtr  := Pointer(PChar(DataPtr) - SizeOf(TAllocFrame));
    DataSize  := AllocPtr.MSize;
    AllocSize := SizeAlign(DataSize) + SizeOf(TAllocFrame) + SizeOf(TAllocGuard);

    { Проверяем, не был ли переописан блок }
    Result :=
      GuardCheck(@PAllocFrame(AllocPtr).MGuard, SizeOf(TAllocGuard)) and
      GuardCheck(PChar(DataPtr) + DataSize, AllocSize - SizeOf(TAllocFrame) - DataSize);

    if not Result and ANotify then 
      Trace('Overrun: ' + StrInt(DataSize) + ' bytes allocated at ' + StrPtr(PAllocFrame(AllocPtr).MStack[0]));
  end;


  function AllBlocksValid :Boolean;
  var
    P :PAllocFrame;
    I, J :TIntPtr;
  begin
    if IsMultiThread then
      EnterCriticalSection(HeapLock);;
    try
      Trace('Checking for ' + StrInt(MemAllocCount) + ' blocks...');
      I := 0; J := 0;
      P := FFirst;
      while (P <> nil) and (P <> EmptyFillerPtr) and (I < MemAllocCount) do begin
        if not MemBlockValid(PChar(P) + SizeOf(TAllocFrame), True) then
          Inc(J);
        P := P.MNext;
        Inc(I);
      end;
      if (I = MemAllocCount) and (P = nil) then begin
        Trace('Checked: ' + StrInt(I) + ' blocks, Overrun: ' + StrInt(J) + ' blocks');
        Result := J = 0;
      end else
      begin
        Trace('Error: memory structure corrupted.');
        Result := False;
      end;
    finally
      if IsMultiThread then
        LeaveCriticalSection(HeapLock);
    end;
  end;


  function MemReport(ASort :TMemListSort) :Boolean;
  var
    P, N :PMemBlock;
    B, S :TInt64;
    I :TIntPtr;
  begin
    if not DebugManagerInstalled then begin
      Trace('Debug Memory Manager not installed.');
      Result := False;
      Exit;
    end;

    if IsMultiThread then
      EnterCriticalSection(HeapLock);;
    try
      Trace('Memory usage summary report:');
      P := BuildSortedList(False);

      if ASort <> ByAddr then
        { Пересортировываем список по размеру }
        P := SortLeakBy(P, ASort);

      I := 0; B := 0; S:= 0;
      while P <> nil do begin
        Inc(I);
        Inc(B, P.Count);
        Inc(S, P.Size);
        Trace('   Addr: ' + StrStack(P.Stack) + ', allocated ' + StrInt(P.Size) + ' bytes, ' + StrInt(P.Count) + ' blocks');
        N := P;
        P := P.Next;
        OldMemMgr.FreeMem(N);
      end;

      Trace('Listed: ' + StrInt(I) + ' adressess, ' + StrInt(S) + ' bytes in ' + StrInt(B) + ' blocks');
      Result := True;
    finally
      if IsMultiThread then
        LeaveCriticalSection(HeapLock);
    end;
  end;


  procedure MemIncAllocInfo(var ACount, ASize :TUnsPtr);
  begin
    ACount := MemAllocCountInc;
    ASize := MemAllocSizeInc;
  end;


 {-----------------------------------------------------------------------------}
 { Ведение статистики по аллокации памяти                                      }
 {-----------------------------------------------------------------------------}

 {$ifdef bMemReport}

  var
    FHash :array[0..$FF] of PMemBlock;

  procedure AddAllocFact(const AStack :TCallstack; ASize :TInteger);
  var
    vBlock :PMemBlock;
    vEnter :Byte;
  begin
    vEnter := Byte(TCardinal(AStack[0]));
    vBlock := FHash[vEnter];
    while (vBlock <> nil) and (CompStack(vBlock.Stack, AStack) <> 0) do
      vBlock := vBlock.Next;
    if vBlock = nil then begin
      if DebugManagerInstalled then
        vBlock := OldMemMgr.GetMem(SizeOf(TMemBlock))
      else
        GetMem(vBlock, SizeOf(TMemBlock));
      vBlock.Size := 0;
      vBlock.Count := 0;
      vBlock.Maximal := 0;
      vBlock.Stack := AStack;
      vBlock.Next := FHash[vEnter];
      FHash[vEnter] := vBlock;
    end;
    Inc(vBlock.Count);
    Inc(vBlock.Size, ASize);
    if ASize > vBlock.Maximal then
      vBlock.Maximal := ASize;
  end;


  procedure ClearAllocFacts;
  var
    I :TInteger;
    vBlock, vTmp :PMemBlock;
  begin
    for I := 0 to $FF do begin
      vBlock := FHash[I];
      while vBlock <> nil do begin
        vTmp := vBlock;
        vBlock := vBlock.Next;
        OldMemMgr.FreeMem(vTmp);
      end;
    end;
  end;


  function TotalMemReport(ASort :TMemListSort) :Boolean;
  var
    vRoot, vTmp :PMemBlock;
    vBlock :PMemBlock;
    B, S :TInt64;
    I :TInteger;
  begin
    if not DebugManagerInstalled then begin
      Trace('Debug Memory Manager not installed.', '');
      Result := False;
      Exit;
    end;

    if IsMultiThread then
      EnterCriticalSection(HeapLock);;
    try
      Trace('Memory allocation summary report:', '');

      vRoot := nil;
      for I := 0 to $FF do begin
        vBlock := FHash[I];
        while vBlock <> nil do begin
          AddLeak(vRoot, vBlock.Stack, vBlock.Count, vBlock.Size, vBlock.Maximal, False);
          vBlock := vBlock.Next;
        end;
      end;

      if ASort <> ByAddr then
        { Пересортировываем список по размеру }
        vRoot := SortLeakBy(vRoot, ASort);

      I := 0; B := 0; S:= 0;
      while vRoot <> nil do begin
        Inc(I);
        Inc(B, vRoot.Count);
        Inc(S, vRoot.Size);
        Trace('   Addr: ' + StrStack(vRoot.Stack) + ', allocated ' + StrInt(vRoot.Size) + ' bytes, ' +
          StrInt(vRoot.Count) + ' blocks, ' + StrInt(vRoot.Maximal) + ' max', '');
        vTmp := vRoot;
        vRoot := vRoot.Next;
        OldMemMgr.FreeMem(vTmp);
      end;

      Trace('Listed: ' + StrInt(I) + ' adressess, ' + StrInt(S) + ' bytes in ' + StrInt(B) + ' blocks', '');
      Result := True;
    finally
      if IsMultiThread then
        LeaveCriticalSection(HeapLock);
    end;
  end;

 {$endif bMemReport}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function NewGetMem(DataSize :TMInteger) :Pointer;
  var
    AllocPtr  :PAllocFrame;
    AllocSize :TIntPtr;
    vStack    :TCallstack;
    vAddr     :Pointer;
  begin
    Result := nil;
    if DataSize = 0 then
      Exit;

//  TraceStrF('NewGetMem %d...', [DataSize]);

    if TIntPtr(DataSize) < 0 then begin
      TraceStr('Invalid Allocation Size');
      Exit;
    end;

    try
      if IsMultiThread then
        EnterCriticalSection(HeapLock);

     {$ifdef bMemCallstack}
      FillChar(vStack, SizeOf(vStack), 0);
      vAddr := GetAndClearAllocFrame;
      if vAddr = nil then
        vAddr := GetStackFrame2;
      { Определение callstack'а вызова, глубиной cStackDepth }
      DetectCallstack(vStack, vAddr);
     {$else}
      vAddr := GetAndClearAllocAddr;
      if vAddr = nil then
        { Определение адреса вызывающей процедуры }
        vAddr := DetectAllocAddr;
      vStack[0] := vAddr;
     {$endif bMemCallstack}

      AllocSize := SizeAlign(DataSize) + SizeOf(TAllocFrame) + SizeOf(TAllocGuard);

      { Вызываем стандартный обработчик }
      AllocPtr := OldMemMgr.GetMem(AllocSize);
      if AllocPtr = nil then
        Exit;

     {$ifdef bMemReport}
      AddAllocFact(vStack, DataSize);
     {$endif bMemReport}

      if vStack[0] = BreakAddr then
        NOP;  { Stop in debugger }
      if AllocPtr = BreakPtr then
        NOP;  { Stop in debugger }

      Result := PChar(AllocPtr) + SizeOf(TAllocFrame);

      FillChar(AllocPtr^, AllocSize, EmptyFiller);
      FillChar(AllocPtr.MGuard, SizeOf(TAllocGuard), GuardFiller);
      FillChar((PChar(Result) + DataSize)^, AllocSize - SizeOf(TAllocFrame) - DataSize, GuardFiller);

      AllocPtr.MSize   := DataSize;
      AllocPtr.MStack  := vStack;

      if MemOverrunCount = 0 then
        { Добавляем в цепочку (только если не было ошибок overrun) }
        AddFrame(AllocPtr);

      Inc(MemAllocSize, DataSize);
      Inc(MemAllocCount);

      Inc(MemAllocSizeInc, DataSize);
      Inc(MemAllocCountInc);

      if MemAllocSize > MemAllocSizeTop then
        MemAllocSizeTop := MemAllocSize;
      if MemAllocCount > MemAllocCountTop then
        MemAllocCountTop := MemAllocCount;

      if DataSize > MaxBlockSize then
        MaxBlockSize := DataSize;

    finally
      if IsMultiThread then
        LeaveCriticalSection(HeapLock);
    end;

//  TraceStrF('  NewGetMem done %p...', [Result]);
  end;


  function NewFreeMem(DataPtr :Pointer) :TIntPtr;
  var
    AllocPtr  :PAllocFrame;
    DataSize  :TIntPtr;
    AllocSize :TIntPtr;
  begin
//  TraceStr('NewFreeMem...');

    if (DataPtr = nil) or (TUnsPtr(DataPtr) and $3 <> 0) then begin
      TraceStr('Invalid FreeMem Call');
      Result := 0;
      Exit;
    end;

    if not MemBlockValid(DataPtr, False) then begin
      TraceStr('Mem block was overrun');
      Inc(MemOverrunCount);
      Result := 0;
      Exit;
    end;

    try
      if IsMultiThread then
        EnterCriticalSection(HeapLock);;

      AllocPtr  := Pointer(PChar(DataPtr) - SizeOf(TAllocFrame));
      DataSize  := AllocPtr.MSize;
      AllocSize := SizeAlign(DataSize) + SizeOf(TAllocFrame) + SizeOf(TAllocGuard);

      if MemOverrunCount = 0 then
        { Удаляем из цепочки (только если не было ошибок overrun) }
        {Ok :=} DelFrame(AllocPtr);

      FillChar(AllocPtr^, AllocSize, EmptyFiller);

      { Вызываем стандартный обработчик }
      Result := OldMemMgr.FreeMem(AllocPtr);

      Dec(MemAllocSize, DataSize);
      Dec(MemAllocCount);

    finally
      if IsMultiThread then
        LeaveCriticalSection(HeapLock);
    end;

//  TraceStr('  NewFreeMem done');
  end;


  function NewReallocMem(DataPtr :Pointer; DataSize :TIntPtr): Pointer;
  begin
//  TraceStr('NewReallocMem...');

    if (DataPtr = nil) or (TUnsPtr(DataPtr) and $3 <> 0) or (DataSize <= 0) then begin
      TraceStr('Invalid ReallocMem Call');
      Result := nil;
      Exit;
    end;

    if not MemBlockValid(DataPtr, False) then begin
      TraceStr('Mem block was overrun');
      Inc(MemOverrunCount);
      Result := nil;
      Exit;
    end;

   {$ifdef bMemCallstack}
   {$else}
    if GetAllocAddr = nil then begin
     {$ifdef bFreePascal}
     {$else}
     {$ifdef bWindows}
      SetAllocAddr( ReturnAddrReallocMem1 );
      if IsStrSetLength(GetAllocAddr) then
        { Для строк не поддерживается... }
        SetAllocAddr( Pointer(1) );
     {$else}
      SetAllocAddr( ReturnAddrReallocMem1 );
     {$endif bWindows}
     {$endif bFreePascal}
    end;
   {$endif bMemCallstack}

    Result := NewGetMem(DataSize);

    if Result <> nil then begin
      Move(DataPtr^, Result^, IntMin( DataSize, SizeOfData(DataPtr) ));
      NewFreeMem(DataPtr);
    end;

//  TraceStr('  NewReallocMem done');
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

 {$ifdef bFreePascal}

  function DebFreeMem(DataPtr :Pointer) :TMInteger;
  begin
    Result := 0;
    if DataPtr <> nil then
      Result := NewFreeMem(DataPtr);
  end;


  function DebFreememSize(p :pointer; Size :TMInteger) :TMInteger;
  begin
    Result := DebFreeMem(P);
  end;


  function DebReallocMem(var DataPtr :Pointer; DataSize :TMInteger): Pointer;
  begin
    if DataSize > 0 then begin
     {$ifdef bMemCallstack}
      if GetAllocFrame = nil then
        SetAllocFrame( GetStackFrame2 );
     {$endif bMemCallstack}
     if DataPtr = nil then
       DataPtr := NewGetMem(DataSize)
     else
       DataPtr := NewReallocMem(DataPtr, DataSize);
    end else
    if DataPtr <> nil then begin
      NewFreeMem(DataPtr);
      DataPtr := nil;
    end;

    Result := DataPtr;
  end;


  function DebAllocMem(Size :TMInteger) :Pointer;
  begin
    Result := nil;
    if Size > 0 then begin
     {$ifdef bMemCallstack}
      if GetAllocFrame = nil then
        SetAllocFrame( GetStackFrame2 );
     {$endif bMemCallstack}
      Result := NewGetMem(Size);
      if Result <> nil then
        FillChar(Result^, Size, 0);
    end;
  end;


  function DebMemSize(p :Pointer) :TMInteger;
  begin
//  Trace('!!!DebMemSize');
    Result := 0
  end;


  function DebGetHeapStatus :THeapStatus;
  begin
//  Trace('!!!DebGetHeapStatus');
    FillChar(Result, sizeof(Result), 0);
  end;


  function DebGetFPCHeapStatus :TFPCHeapStatus;
  begin
//  Trace('!!!DebGetFPCHeapStatus');
    FillChar(Result, sizeof(Result), 0);
  end;


 {$ifdef bFPC23}
  procedure DebInitThread;
  begin
    if Assigned(OldMemMgr.InitThread) then
      OldMemMgr.InitThread;
  end;

  procedure DebDoneThread;
  begin
    if Assigned(OldMemMgr.DoneThread) then
      OldMemMgr.DoneThread;
  end;

  procedure DebRelocateHeap;
  begin
    if Assigned(OldMemMgr.RelocateHeap) then
      OldMemMgr.RelocateHeap;
  end;
 {$endif bFPC23}

 {$endif bFreePascal}



  const
   {$ifdef bFreePascal}
    DebugMemMgr :TMemoryManager = (
      NeedLock     :false;
      GetMem       :NewGetMem;
      FreeMem      :DebFreeMem;
      FreememSize  :DebFreeMemSize;
      AllocMem     :DebAllocMem;
      ReallocMem   :DebReallocMem;
      MemSize      :DebMemSize;
     {$ifdef bFPC23}
      InitThread   :DebInitThread;
      DoneThread   :DebDoneThread;
      RelocateHeap :DebRelocateHeap;
     {$endif bFPC23}
      GetHeapStatus :DebGetHeapStatus;
      GetFPCHeapStatus :DebGetFPCHeapStatus;
    );
   {$else}
    DebugMemMgr :TMemoryManager = (
      GetMem     :NewGetMem;
      FreeMem    :NewFreeMem;
      ReallocMem :NewReallocMem
    );
   {$endif bFreePascal}


  const
    dieAlreadyAllocated = 1;
    dieNoStackFrames    = 2;

  var
    InstallError :Integer = 0;


  procedure InstallDebugManager;
  begin
    if not DebugManagerInstalled and (InstallError = 0) then begin
     {$ifdef bFreePascal}
     {$else}
      if AllocMemCount <> 0 then
        InstallError := dieAlreadyAllocated
      else
      if not GetStackFrames then
        InstallError := dieNoStackFrames
      else
     {$endif bFreePascal}
      begin
        InitializeCriticalSection(HeapLock);

        GetMemoryManager(OldMemMgr);
        SetMemoryManager(DebugMemMgr);

//      SysCom.GAllBlocksValid := MSGuard.AllBlocksValid;
//      SysCom.GMemBlockValid := MSGuard.MemBlockValid;
//      SysCom.GMemReport := MSGuard.MemReport;
//     {$ifdef bMemReport}
//      SysCom.GTotalMemReport := MSGuard.TotalMemReport;
//     {$endif bMemReport}

        DebugManagerInstalled := True
      end;
    end;
  end;


  procedure DeinstallDebugManager;
  var
    Res :Integer;
  begin
    if DebugManagerInstalled then begin
     {$ifdef bMemReport}
      Res := ShowError('Debug', 'Print allocation report?', MB_YESNO or MB_ICONQUESTION);
      if Res = IDYES then begin
        TotalMemReport(ByCount);
//      TotalMemReport(BySize);

//     {$ifdef bDelphi5}
//      ShowError('Debug', 'Search for allocation adresses now...', MB_OK or MB_ICONINFORMATION);
//     {$endif bDelphi5}
      end;
      ClearAllocFacts;
     {$endif bMemReport}

      SetMemoryManager(OldMemMgr);
      DebugManagerInstalled := False;

//    SysCom.GAllBlocksValid := nil;
//    SysCom.GMemBlockValid := nil;
//    SysCom.GMemReport := nil;
//   {$ifdef bMemReport}
//    SysCom.GTotalMemReport := nil;
//   {$endif bMemReport}

      DeleteCriticalSection(HeapLock);

      Trace('Memory usage statistics:');
      Trace('Maximum allocated: ' + StrInt(MemAllocSizeTop) + ' bytes (' +
        StrInt(MemAllocCountTop) + ' blocks)');
      Trace('Totally allocated: ' + StrInt(MemAllocSizeInc) + ' bytes (' +
        StrInt(MemAllocCountInc) + ' blocks)');
      if MemAllocCountInc > 0 then
        Trace('Block sizes: ' + StrInt(MemAllocSizeInc div MemAllocCountInc) + ' bytes average, ' +
          StrInt(MaxBlockSize) + ' bytes maximum');

      if MemAllocCount > 0 then begin
        Res := ShowError('WARNING!', 'Memory Leak: ' + StrInt(MemAllocSize) + ' bytes in ' +
          StrInt(MemAllocCount) + ' block(s).'#13'Print detailed list?', MB_YesNoCancel or MB_IconWarning);

        if Res <> IDCancel then begin
          if MemOverrunCount = 0 then begin
            PrintLeakList(Res = IDYes);
           {$ifdef bDelphi5}
            DebugBreak('Search for leak adresses now...');
           {$endif bDelphi5}
          end else
            Trace('Memory was overrun, can''t print leak list');
        end;
      end;

      if MemOverrunCount > 0 then
        ShowError('WARNING!', StrInt(MemOverrunCount) + ' memory blocks was overrun.', MB_IconWarning);
    end;
  end;


  procedure ReportDebugManager;
  begin
    if not DebugManagerInstalled then begin
      Trace('Warning: Debug Memory Manager NOT installed.');
      if InstallError = dieAlreadyAllocated then
        Trace('Unit MSCheck must be first in USES clause of project.')
      else
      if InstallError = dieNoStackFrames then
        Trace('All units in project must be compiled with Stack Frames.')
    end;
  end;



initialization
begin
  Assert( @AllBlocksValid <> nil );
  Assert( @MemReport <> nil );
 {$ifdef bMemReport}
  Assert( @TotalMemReport <> nil );
 {$endif bMemReport}

  InstallDebugManager;
end


finalization
begin
  DeinstallDebugManager;
end;

end.


{$I Defines.inc}

unit MixClasses;

interface

  uses
    Windows,
    MixTypes,
    MixConsts,
    MixUtils,
    MixStrings;

  type
    TNotifyEvent = procedure(Sender: TObject) of object;

  type
    TBasisClass = class of TBasis;

    PBasis = ^TBasis;
    TBasis = class(TObject)
    public
      constructor Create; virtual;
//    constructor CreateCopy(Source :TBasis);
     {$ifdef bUseStreams}
      constructor CreateStream(Stream :TStream);
     {$endif bUseStreams}
      destructor Destroy; override;

      class function NewInstance :TObject; override;
      procedure FreeInstance; override;

//    function Clone :TBasis;

     {$ifdef bUseStreams}
      procedure WriteToStream(Stream :TStream); virtual;
      procedure ReadFromStream(Stream :TStream); virtual;
     {$endif bUseStreams}

      function CompareObj(Another :TBasis; Context :TInteger) :TInteger; virtual;
      function CompareKey(Key :Pointer; Context :TInteger) :TInteger; virtual;

      function ValidInstanceEx(AClass :TBasisClass) :Boolean;

    protected
     {$ifdef bAsserts}
      { Указатель на класс объекта, для проверки ValidInstance }
      FClass  :{$ifdef bDelphi}TBasisClass;{$else}Pointer;{$endif bDelphi}
     {$endif bAsserts}

      function GetValidInstance :Boolean;

    public
      property ValidInstance :Boolean read GetValidInstance;
    end;


  type
    TDuplicates = (
      dupIgnore,
      dupAccept,
      dupError
    );

    TFindOptions = set of (
      foCompareObj,
      foBinary,
      foSimilary,
      foExceptOnFail
    );

    PPointerList = ^TPointerList;
    TPointerList = array[0..MaxInt div SizeOf(Pointer) - 1] of Pointer;

    TExList = class(TBasis)
    public
      constructor Create; override;
      constructor CreateSize(AItemSize :TInteger);
      destructor Destroy; override;

     {$ifdef bUseStreams}
      procedure WriteToStream(Stream :TStream); override;
      procedure ReadFromStream(Stream :TStream); override;
      procedure AppendFromStream(Stream :TStream); virtual;
        { Для чтения/записи Item'а вызываются ItemToStream/ItemFromStream }
        { Для данного базового класса - абстрактные и генерируют ошибку }
     {$endif bUseStreams}

      procedure Clear;

      function Add(Item: Pointer) :TInteger;
      procedure Insert(Index :TInteger; Item: Pointer);

      function AddSorted(Item :Pointer; Context :TInteger; Duplicates :TDuplicates) :TInteger;
        { Вставляет элемент с сортировкой }

      function AddData(const Item) :TInteger; {virtual;}
      procedure InsertData(Index :TInteger; const Item);

      procedure Delete(AIndex: TInteger);
      procedure DeleteRange(AIndex, ACount :TInteger);
      function Remove(Item: Pointer): TInteger;
      function RemoveData(const Item) :TInteger;

      procedure ReplaceRangeFrom(const ABuffer; AIndex, AOldCount, ANewCount :TInteger);

      function Contain(Item :Pointer) :Boolean;
      function IndexOf(Item :Pointer) :TInteger;
      function IndexOfData(const Item) :TInteger;

      function First: Pointer;
      function Last: Pointer;

      function FindKey(Key :Pointer; Context :TInteger; Opt :TFindOptions; var Index :TInteger) :Boolean; virtual;
        { Альтернативный вариант поиска. Постепенно переходим к нему }
      procedure SortList(Ascend :Boolean; Context :TInteger); {virtual;}
        { Быстрая сортировка списка }

      { Следующие функции работают только для частного случая : FItemSize = 4 }

      procedure Pack;
      procedure Exchange(Index1, Index2: TInteger); virtual;
      procedure Move(CurIndex, NewIndex: TInteger);

    protected
      FItemSize  : TInteger;
      FItemLimit : TInteger;
      FList      : PPointerList;
      FCount     : TInteger;
      FCapacity  : TInteger;

      procedure Grow; virtual;

//    procedure ItemFree(PItem :Pointer); virtual;
//    procedure ItemAssign(PItem, PSource :Pointer); virtual;
      function  ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; virtual;
      function  ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TInteger) :TInteger; virtual;
     {$ifdef bUseStreams}
      procedure ItemToStream(PItem :Pointer; Stream :TStream); virtual;
      procedure ItemFromStream(PItem :Pointer; Stream :TStream); virtual;
     {$endif bUseStreams}

    protected
      function  GetItems(Index: TInteger) :Pointer;
      procedure PutItems(Index: TInteger; Item: Pointer);
      function  GetPItems(Index: TInteger) :Pointer; {virtual;}
      procedure SetCapacity(NewCapacity: TInteger); virtual;
      function  GetCount :TInteger;
      procedure SetCount(NewCount: TInteger);

    public
      property ItemSize :TInteger read FItemSize;
      property Count :TInteger read FCount write SetCount;
      property Capacity :TInteger read FCapacity write SetCapacity;
      property List :PPointerList read FList;

      { Свойство Items работает только для частного случая : FItemSize = 4 }
      property Items[I :TInteger]: Pointer read GetItems write PutItems; default;

      property PItems[I :TInteger]: Pointer read GetPItems;
    end; {TExList}


  type
    TObjList = class(TExList)
    public
      destructor Destroy; override;

//    procedure Assign(Source :TPersistent); override;
     {$ifdef bUseStreams}
      procedure ReadFromStream(Stream :TStream); override;
     {$endif bUseStreams}

      procedure FreeAll;
        { Уничтожает все элементы списка }
      procedure FreeAt(AIndex :TInteger);
        { Уничтожает элемент с номером AIndex }
      procedure FreeRange(AIndex, ACount :TInteger);
        { Уничтожает элементы списка в заданном диапазоне }
      procedure FreeItem(Item :Pointer);
        { Уничтожает элемент Item (даже если его нет в списке!) }
      procedure FreeKey(Key :Pointer; Context :TInteger; Opt :TFindOptions);
        { Уничтожает элемент найденый функцией FindKey }

    protected
      procedure FreeOne(Item :Pointer); virtual;

      function ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; override;
      function ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TInteger) :TInteger; override;
     {$ifdef bUseStreams}
      procedure ItemToStream(PItem :Pointer; Stream :TStream); override;
      procedure ItemFromStream(PItem :Pointer; Stream :TStream); override;
     {$endif bUseStreams}
    end; {TObjList}


  type
    TIntList = class(TExList)
    public
      function Add(Item :TInteger) :TInteger;

    protected
      function ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; override;
      function ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TInteger) :TInteger; override;
     {$ifdef bUseStreams}
      procedure ItemToStream(PItem :Pointer; Stream :TStream); override;
      procedure ItemFromStream(PItem :Pointer; Stream :TStream); override;
     {$endif bUseStreams}

      function  GetIntItems(Index :TInteger) :TInteger;
      procedure PutIntItems(Index, Value :TInteger);

    public
      property Items[I :TInteger] :TInteger read GetIntItems write PutIntItems; default;
    end;

  type
    TStrList = class(TObjList)
    public
      procedure Clear;
      function IndexOf(const AStr :TString) :TInteger;
      function Add(const AStr :TString) :TInteger;
      function AddSorted(const AStr :TString; Context :TInteger; Duplicates :TDuplicates) :TInteger;
      procedure Insert(Index :TInteger; const AStr :TString);
      procedure Delete(AIndex :TInteger);

    protected
      procedure FreeOne(Item :Pointer); override;
      function ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; override;
     {$ifdef bUseStreams}
      procedure ItemToStream(PItem :Pointer; Stream :TStream); override;
      procedure ItemFromStream(PItem :Pointer; Stream :TStream); override;
     {$endif bUseStreams}
      function GetStrItems(Index :TInteger) :TString;
      procedure PutStrItems(Index :TInteger; const Value :TString);

    public
      property Items[I :TInteger] :TString read GetStrItems write PutStrItems; default;
      property Strings[I :TInteger] :TString read GetStrItems write PutStrItems;
    end;


  type
    TNamedObject = class(TBasis)
    public
      constructor CreateName(const AName :TString); virtual;

//    procedure Assign(Source :TPersistent); override;
     {$ifdef bUseStreams}
      procedure WriteToStream(Stream :TStream); override;
      procedure ReadFromStream(Stream :TStream); override;
     {$endif bUseStreams}

      function CompareObj(Another :TBasis; Context :TInteger) :TInteger; override;
      function CompareKey(Key :Pointer; Context :TInteger) :TInteger; override;

    protected
      FName :TString;

    public
      property Name :TString read FName write FName;
    end;


  type
    TDescrObject = class(TNamedObject)
    public
      constructor CreateEx(const AName, ADescr :TString);

//    procedure Assign(Source :TPersistent); override;
     {$ifdef bUseStreams}
      procedure WriteToStream(AStream :TStream); override;
      procedure ReadFromStream(AStream :TStream); override;
     {$endif bUseStreams}

    protected
      FDescr :TString;

    public
      property Descr :TString read FDescr write FDescr;
    end;


  type
    TBits = class
    private
      FSize: Integer;
      FBits: Pointer;
      procedure Error;
      procedure SetSize(Value: Integer);
      procedure SetBit(Index: Integer; Value: Boolean);
      function GetBit(Index: Integer): Boolean;
    public
      destructor Destroy; override;
      function OpenBit: Integer;
      property Bits[Index: Integer]: Boolean read GetBit write SetBit; default;
      property Size: Integer read FSize write SetSize;
    end;


  type
    TThreadPriority = (tpIdle, tpLowest, tpLower, tpNormal, tpHigher, tpHighest, tpTimeCritical);

    TThread = class
    public
      constructor Create(CreateSuspended: Boolean);
      destructor Destroy; override;
      procedure Resume;
      procedure Suspend;
      procedure Terminate;
      function WaitFor: LongWord;
    protected
      procedure DoTerminate; virtual;
      procedure Execute; virtual; abstract;
//    procedure Synchronize(Method: TThreadMethod);
    private
      FHandle: THandle;
      FThreadID: THandle;
      FTerminated: Boolean;
      FSuspended: Boolean;
      FFreeOnTerminate: Boolean;
      FFinished: Boolean;
      FReturnValue: Integer;
//    FOnTerminate: TNotifyEvent;
//    FMethod: TThreadMethod;
//    FSynchronizeException: TObject;
//    procedure CallOnTerminate;
      function GetPriority: TThreadPriority;
      procedure SetPriority(Value: TThreadPriority);
      procedure SetSuspended(Value: Boolean);
    public
      property Handle: THandle read FHandle;
      property ThreadID: THandle read FThreadID;
      property Priority: TThreadPriority read GetPriority write SetPriority;
      property Suspended: Boolean read FSuspended write SetSuspended;
      property FreeOnTerminate: Boolean read FFreeOnTerminate write FFreeOnTerminate;
      property Terminated: Boolean read FTerminated;
      property ReturnValue: Integer read FReturnValue write FReturnValue;
//    property OnTerminate: TNotifyEvent read FOnTerminate write FOnTerminate;
    end;

    
{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TBasis                                                                      }
 {-----------------------------------------------------------------------------}

  constructor TBasis.Create; {virtual;}
  begin
//  inherited Create;
  end;

//constructor TBasis.CreateCopy(Source :TPersistent);
//begin
//  Create;
//  Assign(Source);
//end;

 {$ifdef bUseStreams}
  constructor TBasis.CreateStream(Stream :TStream);
  begin
    Create;
    ReadFromStream(Stream);
  end;
 {$endif bUseStreams}


  destructor TBasis.Destroy; {override;}
  begin
   {$ifdef bAsserts}
    try
      Assert(ValidInstance);
    except
      Nop;
    end;
   {$endif bAsserts}
//  inherited Destroy;
  end;


  class function TBasis.NewInstance :TObject; {override;}
  begin
   {$ifdef bDebug}
    SetReturnAddrNewInstance;
   {$endif bDebug}
    Result := inherited NewInstance;
   {$ifdef bAsserts}
    TBasis(Result).FClass := Self;
   {$endif bAsserts}
  end;


  procedure TBasis.FreeInstance; {override;}
  begin
   {$ifdef bAsserts}
    FClass := nil;
   {$endif bAsserts}
    inherited FreeInstance;
  end;


  function TBasis.GetValidInstance :Boolean;
  begin
   {$ifdef bAsserts}
    Result :=
      (Self <> nil) and (TCardinal(Self) and $3 = 0) and
      (FClass <> nil) and (TCardinal(FClass) and $3 = 0) and
      (FClass = ClassType) and (TObject(Self) is TBasis);
   {$else}
    Result := True;
   {$endif bAsserts}
  end;

  function TBasis.ValidInstanceEx(AClass :TBasisClass) :Boolean;
  begin
   {$ifdef bAsserts}
    Result :=
      (Self <> nil) and (TCardinal(Self) and $3 = 0) and
      (FClass <> nil) and (TCardinal(FClass) and $3 = 0) and
      (FClass = ClassType) and (TObject(Self) is AClass);
   {$else}
    Result := True;
   {$endif bAsserts}
  end;


//function TBasis.Clone :TBasis;
//begin
//  Result := TBasisClass(ClassType).CreateCopy(Self);
//end;


  function TBasis.CompareObj(Another :TBasis; Context :TInteger) :TInteger; {virtual;}
(*
  var
    Str :TString;
  begin
    Result := 0;
    if Another <> nil then
      Str := Another.ClassName
    else
      Str := 'nil';
    {!!!}  
    AppErrorFmt(errComCompareError, [ClassName, Str]); *)
  begin
    Result := 0;
  end;

  function TBasis.CompareKey(Key :Pointer; Context :TInteger) :TInteger; {virtual;}
  begin
    Result := 0;
    {!!!}
(*  InternalErrorResFmt(errComCompareKeyError, [ClassName]); *)
  end;


 {$ifdef bUseStreams}
  procedure TBasis.WriteToStream(Stream :TStream); {virtual;}
  begin
    {Nothing}
  end;

  procedure TBasis.ReadFromStream(Stream :TStream); {virtual;}
  begin
    {Nothing}
  end;
 {$endif bUseStreams}


 {-----------------------------------------------------------------------------}
 { TExList                                                                     }
 {-----------------------------------------------------------------------------}

  const
    errComListOutOfIndex   = 1;   { "Индекс коллекции выходит за допустимые пределы" }
    errComListCountError   = 2;   { "Размер коллекции выходит за допустимые пределы" }
    errComListOverflow     = 3;   { "Размер коллекции выходит за допустимые пределы" }
    errComDuplicateItem    = 4;   { "Коллекция не допускает идентичных элементов" }
    errComListItemNotFound = 5;   { "Элемент коллекции не найден" }


  procedure ListError(ErrCode :TInteger);
  begin
   {$ifdef bTraceError}
    SetErrorAddress(ReturnAddr2);
   {$endif bTraceError}
    raise EAppError.Create(LoadStr(ErrCode))
     {$ifopt W+} at ReturnAddr2 {$endif W+};
  end;


  {!!!}
  function MemCompare (a1, a2 :Pointer; len :TInteger) :TInteger;
  begin
    Result := 0;
    while (Result < len) and ((PAnsiChar(a1)+Result)^ = (PAnsiChar(a2)+Result)^) DO
      inc(Result);
  end;


  constructor TExList.Create; {override;}
  begin
    inherited Create;
    FItemSize  := SizeOf(Pointer);
    FItemLimit := MaxInt div FItemSize;
  end;


  constructor TExList.CreateSize(AItemSize :TInteger);
  begin
    Create;
    FItemSize  := AItemSize;
    FItemLimit := MaxInt div FItemSize;
  end;


  destructor TExList.Destroy; {override;}
  begin
    SetCount(0);
    inherited Destroy;
  end;

  
  procedure TExList.Clear;
  begin
    SetCount(0);
    SetCapacity(0);
  end;


  function TExList.GetItems(Index: TInteger) :Pointer;
  begin
    Assert(ValidInstance);
    if (Index >= 0) and (Index < FCount) then
      Result := FList[Index]
    else begin
      ListError(errComListOutOfIndex);
      Result := nil;
    end;
  end;

  procedure TExList.PutItems(Index :TInteger; Item :Pointer);
  begin
    Assert(ValidInstance);
    if (Index >= 0) and (Index < FCount) then
      FList[Index] := Item
    else
      ListError(errComListOutOfIndex);
  end;


  function TExList.GetPItems(Index: TInteger) :Pointer; {virtual;}
  begin
    Assert(ValidInstance);
    if (Index < 0) or (Index >= FCount) then
      ListError(errComListOutOfIndex);
    if FItemSize = SizeOf(Pointer) then
      Result := @FList[Index]
    else
      Result := Pointer1(FList) + Index * FItemSize;
  end;


  function TExList.First :Pointer;
  begin
    Result := GetItems(0);
  end;

  function TExList.Last :Pointer;
  begin
    Result := GetItems(FCount - 1);
  end;


  function TExList.Add(Item :Pointer) :TInteger;
  begin
    Result := AddData(Item);
  end;

  procedure TExList.Insert(Index :TInteger; Item :Pointer);
  begin
    InsertData(Index, Item);
  end;


  function TExList.AddSorted(Item :Pointer; Context :TInteger; Duplicates :TDuplicates) :TInteger;
  begin
    if FindKey(Item, Context, [foCompareObj, foBinary], Result) then begin
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ListError(errComDuplicateItem);
      end;
    end;
    InsertData(Result, Item);
  end;


  function TExList.AddData(const Item) :TInteger; {virtual;}
  begin
    Assert(ValidInstance);
    Result := FCount;
    if Result = FCapacity then
      Grow;
    if FItemSize = SizeOf(Pointer) then
      FList[Result] := Pointer(Item)
    else
      System.Move(Item, (Pointer1(FList) + Result * FItemSize)^, FItemSize);
    Inc(FCount);
  end;

  
  procedure TExList.InsertData(Index :TInteger; const Item);
  var
    P :Pointer1;
  begin
    Assert(ValidInstance);
    if (Index < 0) or (Index > FCount) then
      ListError(errComListOutOfIndex);
    if FCount = FCapacity then
      Grow;
    if FItemSize = SizeOf(Pointer) then begin
      P := Pointer(@FList[Index]);
      if Index < FCount then
        System.Move(P^, (P + SizeOf(Pointer))^, (FCount - Index) * SizeOf(Pointer));
      PPointer(P)^ := Pointer(Item)
    end else
    begin
      P := Pointer1(FList) + Index * FItemSize;
      if Index < FCount then
        System.Move(P^, (P + FItemSize)^, (FCount - Index) * FItemSize);
      System.Move(Item, P^, FItemSize);
    end;
    Inc(FCount);
  end;


  procedure TExList.Delete(AIndex: TInteger);
  begin
    DeleteRange(AIndex, 1)
  end;


  procedure TExList.DeleteRange(AIndex, ACount :TInteger);
  var
    P :Pointer1;
  begin
    Assert(ValidInstance);
    if (AIndex < 0) or (AIndex + ACount > FCount) then
      ListError(errComListOutOfIndex);
    if AIndex + ACount < FCount then begin
      P := Pointer1(FList) + AIndex * FItemSize;
      System.Move((P + ACount * FItemSize)^, P^, (FCount - AIndex - ACount) * FItemSize);
    end;
    Dec(FCount, ACount);
  end;


  function TExList.Remove(Item :Pointer) :TInteger;
  begin
    Result := RemoveData(Item);
  end;

  function TExList.RemoveData(const Item) :TInteger;
  begin
    Result := IndexOfData(Item);
    if Result <> -1 then
      DeleteRange(Result, 1);
  end;


  procedure TExList.ReplaceRangeFrom(const ABuffer; AIndex, AOldCount, ANewCount :TInteger);
  var
    vNewCount :TInteger;
    P :Pointer1;
  begin
    if (AIndex < 0) or (AIndex + AOldCount > FCount) then
      ListError(errComListOutOfIndex);
    if AOldCount < ANewCount then begin
      vNewCount := FCount + (ANewCount - AOldCount);
      if vNewCount > FCapacity then
        SetCapacity(vNewCount); {!!! Delta....}
      if AIndex + AOldCount < FCount then begin
        P := Pointer1(FList) + (AIndex + AOldCount) * FItemSize;
        System.Move(P^, (P + (ANewCount - AOldCount) * FItemSize)^, (FCount - AIndex - AOldCount) * FItemSize);
      end;
      FCount := vNewCount;
    end else
    if AOldCount > ANewCount then
      DeleteRange(AIndex + ANewCount, AOldCount - ANewCount);
    if ANewCount > 0 then
      System.Move(ABuffer, (Pointer1(FList) + AIndex * FItemSize)^, ANewCount * FItemSize);
  end;


  function TExList.Contain(Item :Pointer) :Boolean;
  begin
    Result := IndexOfData(Item) <> -1;
  end;

  function TExList.IndexOf(Item :Pointer) :TInteger;
  begin
    Result := IndexOfData(Item);
  end;

  function TExList.IndexOfData(const Item) :TInteger;
  var
    I :TInteger;
    P :Pointer1;
    F :Boolean;
  begin
    P := Pointer1(FList);
    for I := 0 to FCount - 1 do begin
      if FItemSize = SizeOf(Pointer) then begin
        F := PPointer(P)^ = Pointer(Item)
      end else begin
        F := MemCompare(P, @Item, FItemSize) = FItemSize;
      end;
      if F then begin
        Result := I;
        Exit;
      end;
      inc(P, FItemSize);
    end;
    Result := -1;
  end;


  procedure TExList.Grow; {virtual;}
  var
    Delta: TInteger;
  begin
    if FCapacity > 64 then
      Delta := FCapacity div 4
    else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
    SetCapacity(FCapacity + Delta);
  end;


  procedure TExList.SetCapacity(NewCapacity: TInteger); {virtual;}
  begin
    if (NewCapacity < FCount) or (NewCapacity > FItemLimit) then
      ListError(errComListOverflow);
    if NewCapacity <> FCapacity then begin
      ReallocMem(FList, NewCapacity * FItemSize);
      FCapacity := NewCapacity;
    end;
  end;


  function  TExList.GetCount :TInteger;
  begin
    Assert(ValidInstance);
    Result := FCount;
  end;


  procedure TExList.SetCount(NewCount: TInteger);
  begin
    Assert(ValidInstance);
    if (NewCount < 0) or (NewCount > FItemLimit) then
      ListError(errComListCountError);
    if NewCount > FCapacity then
      SetCapacity(NewCount);
    if NewCount > FCount then
      FillChar((Pointer1(FList) + FCount * FItemSize)^, (NewCount - FCount) * FItemSize, 0);
    FCount := NewCount;
  end;


 {---------------------------------------------}

 {$ifdef bUseStreams}
  procedure TExList.ItemToStream(PItem :Pointer; Stream :TStream); {virtual;}
  begin
    Wrong;
  end;


  procedure TExList.ItemFromStream(PItem :Pointer; Stream :TStream); {virtual;}
  begin
    Wrong;
  end;


  procedure TExList.WriteToStream(Stream :TStream); {override;}
  var
    I :TInteger;
    P :Pointer1;
  begin
    P := Pointer1(FList);
    for I := 0 to FCount - 1 do begin
      ByteToStream(Stream, 1);
      ItemToStream(P, Stream);
      inc(P, FItemSize);
    end;
    ByteToStream(Stream, 0);
  end;


  procedure TExList.ReadFromStream(Stream :TStream); {override;}
  begin
    Clear;
    AppendFromStream(Stream);
  end;


  procedure TExList.AppendFromStream(Stream :TStream); {virtual;}
  var
    P :Pointer;
  begin
    while ByteFromStream(Stream) = 1 do begin
      if FCount = FCapacity then
        Grow;
      P := Pointer1(FList) + FCount * FItemSize;
      ItemFromStream(P, Stream);
      Inc(FCount);
    end;
  end;
 {$endif bUseStreams}


 {---------------------------------------------}

  function TExList.ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; {virtual;}
  begin
    Wrong; Result := 0;
  end;


  function TExList.ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TInteger) :TInteger; {virtual;}
  begin
    Wrong; Result := 0;
  end;


  function TExList.FindKey(Key :Pointer; Context :TInteger; Opt :TFindOptions; var Index :TInteger) :Boolean; {virtual;}
  var
    I, L, H, C :TInteger;
    P :Pointer;
  begin
    Result := False;

    if not (foBinary in Opt) then begin
      { Поиск простым перебором }

      P := FList;
      for I := 0 to FCount - 1 do begin
        if foCompareObj in Opt then
          C := ItemCompare(P, @Key, Context)
        else
          C := ItemCompareKey(P, Key, Context);
        if C = 0 then begin
          Result := True;
          Index  := I;
          Exit;
        end;
        inc(Pointer1(P), FItemSize);
      end;

      Index := FCount;
    end else
    begin
      { Двоичный поиск. Должны быть уверены, что коллекция отсортирована! }

      L := 0;
      H := FCount - 1;

      while L <= H do begin
        I := (L + H) shr 1;
        P := Pointer1(FList) + I * FItemSize;
        if foCompareObj in Opt then
          C := ItemCompare(P, @Key, Context)
        else
          C := ItemCompareKey(P, Key, Context);
        if C = 0 then begin
          Result := True;
          Index := I;
          Exit;
        end;
        if C < 0 then
          L := I + 1
        else
          H := I - 1;
      end;

      Index := L;
    end;

    if not Result and (foExceptOnFail in Opt) then
      ListError(errComListItemNotFound);
  end;


  procedure TExList.SortList(Ascend :Boolean; Context :TInteger);

    procedure LocQuickSort(L, R :TInteger);
    var
      I, J, P :TInteger;
      vPtr :Pointer;
    begin
      repeat
        I := L;
        J := R;
        P := (L + R) shr 1;
        repeat
          vPtr := PItems[P];

          if Ascend then begin
            while ItemCompare(PItems[I], vPtr, Context) < 0 do
              Inc(I);
            while ItemCompare(PItems[J], vPtr, Context) > 0 do
              Dec(J);
          end else
          begin
            while ItemCompare(PItems[I], vPtr, Context) > 0 do
              Inc(I);
            while ItemCompare(PItems[J], vPtr, Context) < 0 do
              Dec(J);
          end;

          if I <= J then begin
            if I <> J then
              Exchange(I, J);
            if P = I then
              P := J
            else
            if P = J then
              P := I;
            Inc(I);
            Dec(J);
          end;
        until I > J;

        if L < J then
          LocQuickSort(L, J);

        L := I;
      until I >= R;
    end;

  begin
    if Count > 1 then
      LocQuickSort(0, Count - 1)
  end;


 {---------------------------------------------}

  procedure MemExchange(APtr1, APtr2 :Pointer; ASize :TInteger);
  var
    vCnt :TInteger;
    vInt :TCardinal;
    vByte :Byte;
  begin
    vCnt := SizeOf(Pointer);
    while ASize >= vCnt do begin
      vInt := TCardinal(APtr1^);
      TCardinal(APtr1^) := TCardinal(APtr2^);
      TCardinal(APtr2^) := vInt;
      Inc(Pointer1(APtr1), vCnt);
      Inc(Pointer1(APtr2), vCnt);
      Dec(ASize, vCnt);
    end;
    while ASize >=1 do begin
      vByte := Byte(APtr1^);
      Byte(APtr1^) := Byte(APtr2^);
      Byte(APtr2^) := vByte;
      Inc(Pointer1(APtr1));
      Inc(Pointer1(APtr2));
      Dec(ASize);
    end;
  end;


  procedure TExList.Exchange(Index1, Index2: TInteger); {virtual;}
  begin
    if (Index1 >= 0) and (Index1 < FCount) and (Index2 >= 0) and (Index2 < FCount) then
      MemExchange(Pointer1(FList) + Index1 * FItemSize, Pointer1(FList) + Index2 * FItemSize, FItemSize)
    else
      ListError(errComListOutOfIndex);
  end;


  procedure TExList.Move(CurIndex, NewIndex: TInteger);
  var
    Item: Pointer;
  begin
    Assert(FItemSize = SizeOf(Pointer));
    if CurIndex <> NewIndex then begin
      if (NewIndex < 0) or (NewIndex >= FCount) then
        ListError(errComListOutOfIndex);
      Item := GetItems(CurIndex);
      Delete(CurIndex);
      Insert(NewIndex, Item);
    end;
  end;


  procedure TExList.Pack;
  var
    I: TInteger;
  begin
    Assert(FItemSize = SizeOf(Pointer));
    for I := FCount - 1 downto 0 do
      if Items[I] = nil then
        Delete(I);
  end;


 {-----------------------------------------------------------------------------}
 { TObjList                                                                    }
 {-----------------------------------------------------------------------------}

  destructor TObjList.Destroy; {override;}
  begin
    FreeAll;
    inherited Destroy;
  end;


(*
  procedure TObjList.Assign(Source :TPersistent); {overrite;}
  var
    I :TInteger;
  begin
    if Source is TObjList then begin
      FreeAll;
      with TObjList(Source) do
        for I := 0 to Count - 1 do
          Self.Add( (TObject(List[I]) as TBasis).Clone );
    end else
      inherited Assign(Source);
  end;
*)

 {$ifdef bUseStreams}
  procedure TObjList.ReadFromStream(Stream :TStream); {override;}
  begin
    FreeAll;
    AppendFromStream(Stream);
  end;
 {$endif bUseStreams}


  procedure TObjList.FreeOne(Item :Pointer); {virtual;}
  begin
    if Item <> nil then
      TObject(Item).Destroy;
  end;


  procedure TObjList.FreeAll;
  begin
    if FCount > 0 then
      FreeRange(0, FCount);
  end;


  procedure TObjList.FreeAt(AIndex :TInteger);
  begin
    FreeRange(AIndex, 1);
  end;


  procedure TObjList.FreeRange(AIndex, ACount :TInteger);
  var
    I :TInteger;
  begin
    if (ACount < 0) or (AIndex < 0) or (AIndex + ACount > FCount) then
      ListError(errComListOutOfIndex);
    for I := AIndex to AIndex + ACount - 1 do
      FreeOne(FList[I]);
    DeleteRange(AIndex, ACount);
  end;


  procedure TObjList.FreeItem(Item :Pointer);
  begin
    Remove(Item);
    FreeOne(Item);
  end;


  procedure TObjList.FreeKey(Key :Pointer; Context :TInteger; Opt :TFindOptions);
  var
    I :TInteger;
  begin
    if FindKey(Key, Context, Opt, I) then
      FreeRange(I, 1);
  end;


 {-----------------------------------------------------------------------------}

//procedure TObjList.ItemFree(PItem :Pointer); {override;}
//begin
//  FreeObj(PItem^);
//end;


//procedure TObjList.ItemAssign(PItem, PSource :Pointer); {override;}
//begin
//  Assert(TBasis(PSource^).ValidInstance);
//  TBasis(PItem^) := TBasis(PSource^).Clone;
//end;


  function TObjList.ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; {override;}
  begin
    Assert(TBasis(PItem^).ValidInstance and TBasis(PAnother^).ValidInstance);
    Result := TBasis(PItem^).CompareObj(TBasis(PAnother^), Context);
  end;

  function TObjList.ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TInteger) :TInteger; {override;}
  begin
    Assert(TBasis(PItem^).ValidInstance);
    Result := TBasis(PItem^).CompareKey(Key, Context);
  end;


 {$ifdef bUseStreams}
  procedure TObjList.ItemToStream(PItem :Pointer; Stream :TStream); {override;}
  begin
    Assert(TBasis(PItem^).ValidInstance);
    ObjectToStream(Stream, TBasis(PItem^));
  end;

  procedure TObjList.ItemFromStream(PItem :Pointer; Stream :TStream); {override;}
  begin
    TBasis(PItem^) := ObjectFromStream(Stream);
  end;
 {$endif bUseStreams}


 {-----------------------------------------------------------------------------}
 { TIntList                                                                    }
 {-----------------------------------------------------------------------------}

  function TIntList.Add(Item :TInteger) :TInteger;
  begin
    Result := AddData(Item);
  end;


  function TIntList.ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; {override;}
  begin
    Result := IntCompare(PTInteger(PItem)^, PTInteger(PAnother)^);
  end;


  function TIntList.ItemCompareKey(PItem :Pointer; Key :Pointer; Context :TInteger) :TInteger; {override;}
  begin
    Result := IntCompare(PTInteger(PItem)^, TInteger(Key));
  end;


 {$ifdef bUseStreams}
  procedure TIntList.ItemToStream(PItem :Pointer; Stream :TStream); {override;}
  begin
    IntToStream(Stream, TInteger(PItem^));
  end;


  procedure TIntList.ItemFromStream(PItem :Pointer; Stream :TStream); {override;}
  begin
    TInteger(PItem^) := IntFromStream(Stream);
  end;
 {$endif bUseStreams}


  function TIntList.GetIntItems(Index :TInteger) :TInteger;
  begin
    Result := TInteger(inherited GetItems(Index));
  end;


  procedure TIntList.PutIntItems(Index, Value :TInteger);
  begin
    inherited PutItems(Index, Pointer(Value));
  end;


 {-----------------------------------------------------------------------------}
 { TStrList                                                                    }
 {-----------------------------------------------------------------------------}

  procedure TStrList.FreeOne(Item :Pointer); {override;}
  begin
    if Item <> nil then
      TString(Item) := '';
  end;


  function TStrList.ItemCompare(PItem, PAnother :Pointer; Context :TInteger) :TInteger; {override;}
  begin
    Result := UpCompareStr(TString(PItem^), TString(PANother^));
  end;


 {$ifdef bUseStreams}
  procedure TStrList.ItemToStream(PItem :Pointer; Stream :TStream); {override;}
  begin
    StrToStream(Stream, TString(PItem^));
  end;

  procedure TStrList.ItemFromStream(PItem :Pointer; Stream :TStream); {override;}
  begin
    Pointer(PItem^) := nil;
    TString(PItem^) := StrFromStream(Stream);
  end;
 {$endif bUseStreams}


  function TStrList.IndexOf(const AStr :TString) :TInteger;
  var
    I :TInteger;
  begin
    for I := 0 to FCount - 1 do begin
      if StrEqual(TString(FList[I]), AStr) then begin
        Result := I;
        Exit;
      end;
    end;
    Result := -1;
  end;


  function TStrList.Add(const AStr :TString) :TInteger;
  begin
    Result := FCount;
    Insert(FCount, AStr);
  end;

  procedure TStrList.Insert(Index :TInteger; const AStr :TString);
  var
    vTmp :Pointer;
  begin
    vTmp := nil;
    TString(vTmp) := AStr;
    { В InsertData нужно добавлять не AStr, а vTmp, иначе ошибка в Unicode-версии }
    InsertData(Index, vTmp);
  end;


  function TStrList.AddSorted(const AStr :TString; Context :TInteger; Duplicates :TDuplicates) :TInteger;
  begin
    if FindKey(Pointer(AStr), Context, [foCompareObj, foBinary], Result) then begin
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ListError(errComDuplicateItem);
      end;
    end;
    Insert(Result, AStr);
  end;


  procedure TStrList.Delete(AIndex :TInteger);
  begin
    FreeAt(AIndex);
  end;

  procedure TStrList.Clear;
  begin
    FreeAll;
  end;


  function TStrList.GetStrItems(Index :TInteger) :TString;
  begin
    Result := TString(inherited GetItems(Index));
  end;

  procedure TStrList.PutStrItems(Index :TInteger; const Value :TString);
  begin
    Assert(ValidInstance);
    if (Index < 0) or (Index >= FCount) then
      ListError(errComListOutOfIndex);
    TString(FList[Index]) := Value;
  end;


 {-----------------------------------------------------------------------------}
 { TNamedObject                                                                }
 {-----------------------------------------------------------------------------}

  constructor TNamedObject.CreateName(const AName :TString); {virtual;}
  begin
    Create;
    FName := AName;
  end;


(*
  procedure TNamedObject.Assign(Source :TPersistent); {override;}
  begin
    if Source is TNamedObject then
      FName := TNamedObject(Source).Name
    else
      inherited Assign(Source);
  end;
*)

 {$ifdef bUseStreams}
  procedure TNamedObject.WriteToStream (Stream :TStream); {override;}
  begin
    StrToStream(Stream, FName);
  end;


  procedure TNamedObject.ReadFromStream (Stream :TStream); {override;}
  begin
    FName := StrFromStream(Stream);
  end;
 {$endif bUseStreams}


  function TNamedObject.CompareObj(Another :TBasis; Context :TInteger) :TInteger; {override;}
  begin
    if Another is TNamedObject then
      Result := UpCompareStr(FName, TNamedObject(Another).Name)
    else
      Result := inherited CompareObj(Another, Context);
  end;


  function TNamedObject.CompareKey(Key :Pointer; Context :TInteger) :TInteger; {override;}
  begin
    Result := UpCompareStr(FName, TString(Key));
  end;



 {-----------------------------------------------------------------------------}
 { TDescrObject                                                                }
 {-----------------------------------------------------------------------------}

  constructor TDescrObject.CreateEx(const AName, ADescr :TString);
  begin
    Create;
    FName := AName;
    FDescr := ADescr;
  end;

(*
  procedure TDescrObject.Assign(Source :TPersistent); {override;}
  begin
    if Source is TDescrObject then begin
      inherited Assign(Source);
      FDescr := TDescrObject(Source).Descr;
    end else
      inherited Assign(Source);
  end;
*)

 {$ifdef bUseStreams}
  procedure TDescrObject.WriteToStream(AStream :TStream); {override;}
  begin
    inherited WriteToStream(AStream);
    StrToStream(AStream, FDescr);
  end;


  procedure TDescrObject.ReadFromStream(AStream :TStream); {override;}
  begin
    inherited ReadFromStream(AStream);
    FDescr := StrFromStream(AStream);
  end;
 {$endif bUseStreams}


 {-----------------------------------------------------------------------------}
 { TBits                                                                       }
 {-----------------------------------------------------------------------------}

  const
    BitsPerInt = SizeOf(Integer) * 8;

  type
    TBitEnum = 0..BitsPerInt - 1;
    TBitSet = set of TBitEnum;
    PBitArray = ^TBitArray;
    TBitArray = array[0..4096] of TBitSet;

  destructor TBits.Destroy;
  begin
    SetSize(0);
    inherited Destroy;
  end;

  procedure TBits.Error;
  begin
    AppErrorRes(@SBitsIndexError);
  end;

  procedure TBits.SetSize(Value: Integer);
  var
    NewMem: Pointer;
    NewMemSize: Integer;
    OldMemSize: Integer;

    function Min(X, Y: Integer): Integer;
    begin
      Result := X;
      if X > Y then Result := Y;
    end;

  begin
    if Value <> Size then
    begin
      if Value < 0 then Error;
      NewMemSize := ((Value + BitsPerInt - 1) div BitsPerInt) * SizeOf(Integer);
      OldMemSize := ((Size + BitsPerInt - 1) div BitsPerInt) * SizeOf(Integer);
      if NewMemSize <> OldMemSize then
      begin
        NewMem := nil;
        if NewMemSize <> 0 then
        begin
          GetMem(NewMem, NewMemSize);
          FillChar(NewMem^, NewMemSize, 0);
        end;
        if OldMemSize <> 0 then
        begin
          if NewMem <> nil then
            Move(FBits^, NewMem^, Min(OldMemSize, NewMemSize));
          FreeMem(FBits, OldMemSize);
        end;
        FBits := NewMem;
      end;
      FSize := Value;
    end;
  end;

  procedure TBits.SetBit(Index: Integer; Value: Boolean); assembler;
  asm
          CMP     Index,[EAX].FSize
          JAE     @@Size

  @@1:    MOV     EAX,[EAX].FBits
          OR      Value,Value
          JZ      @@2
          BTS     [EAX],Index
          RET

  @@2:    BTR     [EAX],Index
          RET

  @@Size: CMP     Index,0
          JL      TBits.Error
          PUSH    Self
          PUSH    Index
          PUSH    ECX {Value}
          INC     Index
          CALL    TBits.SetSize
          POP     ECX {Value}
          POP     Index
          POP     Self
          JMP     @@1
  end;

  function TBits.GetBit(Index: Integer): Boolean; assembler;
  asm
          CMP     Index,[EAX].FSize
          JAE     TBits.Error
          MOV     EAX,[EAX].FBits
          BT      [EAX],Index
          SBB     EAX,EAX
          AND     EAX,1
  end;

  function TBits.OpenBit: Integer;
  var
    I: Integer;
    B: TBitSet;
    J: TBitEnum;
    E: Integer;
  begin
    E := (Size + BitsPerInt - 1) div BitsPerInt - 1;
    for I := 0 to E do
      if PBitArray(FBits)^[I] <> [0..BitsPerInt - 1] then
      begin
        B := PBitArray(FBits)^[I];
        for J := Low(J) to High(J) do
        begin
          if not (J in B) then
          begin
            Result := I * BitsPerInt + J;
            if Result >= Size then Result := Size;
            Exit;
          end;
        end;
      end;
    Result := Size;
  end;


 {-----------------------------------------------------------------------------}
 { TThread                                                                     }
 {-----------------------------------------------------------------------------}

  function ThreadProc(Thread: TThread): Integer;
  var
    FreeThread :Boolean;
   {$ifdef bTrace}
    vName :TAnsiStr;
   {$endif bTrace}
  begin
    try
     {$ifdef bTrace}
      vName := Thread.ClassName;
     {$endif bTrace}

     {$ifdef bTrace}
      try
     {$endif bTrace}

       {$ifdef bTrace}
        TraceF('Thread begin: %s', [vName]);
       {$endif bTrace}

        Thread.Execute;

       {$ifdef bTrace}
        TraceF('Thread finish: %s', [vName]);
       {$endif bTrace}

     {$ifdef bTrace}
      except
        on E :Exception do begin
          TraceF('Unhandled thread exception. %s, %s: %s', [vName, E.ClassName, E.Message]);
          raise;
        end;
      end;
     {$endif bTrace}

    finally
     {$ifdef bTrace}
      vName := '';
     {$endif bTrace}
      FreeThread := Thread.FFreeOnTerminate;
      Result := Thread.FReturnValue;
      Thread.FFinished := True;
      Thread.DoTerminate;
      if FreeThread then
        Thread.Free;
      EndThread(Result);
    end;
  end;


  constructor TThread.Create(CreateSuspended: Boolean);
  var
    Flags: DWORD;
  begin
    inherited Create;
  //{$ifdef bTrace}
  // TraceExF('ThreadInfo', 'Create thread object: %s', [ClassName]);
  //{$endif bTrace}
   {$ifdef bSynchronize}
  //AddThread;
   {$endif bSynchronize}
    FSuspended := CreateSuspended;
    Flags := 0;
    if CreateSuspended then
      Flags := CREATE_SUSPENDED;
    FHandle := BeginThread(nil, 0, Pointer(@ThreadProc), Pointer(Self), Flags, FThreadID);
  end;

  destructor TThread.Destroy;
  begin
    if not FFinished and not Suspended then begin
      Terminate;
      WaitFor;
    end;
    if FHandle <> 0 then
      CloseHandle(FHandle);
    inherited Destroy;
  //{$ifdef bTrace}
  // TraceExF('ThreadInfo', 'Destroy thread object: %s', [ClassName]);
  //{$endif bTrace}
   {$ifdef bSynchronize}
  //RemoveThread;
   {$endif bSynchronize}
  end;

//procedure TThread.CallOnTerminate;
//begin
//  if Assigned(FOnTerminate) then
//    FOnTerminate(Self);
//end;

  procedure TThread.DoTerminate; {virtual;}
  begin
//  if Assigned(FOnTerminate) then
//    Synchronize(CallOnTerminate);
  end;

  const
    Priorities: array [TThreadPriority] of Integer =
     (THREAD_PRIORITY_IDLE, THREAD_PRIORITY_LOWEST, THREAD_PRIORITY_BELOW_NORMAL,
      THREAD_PRIORITY_NORMAL, THREAD_PRIORITY_ABOVE_NORMAL,
      THREAD_PRIORITY_HIGHEST, THREAD_PRIORITY_TIME_CRITICAL);

  function TThread.GetPriority: TThreadPriority;
  var
    P: Integer;
    I: TThreadPriority;
  begin
    P := GetThreadPriority(FHandle);
    Result := tpNormal;
    for I := Low(TThreadPriority) to High(TThreadPriority) do
      if Priorities[I] = P then Result := I;
  end;

  procedure TThread.SetPriority(Value: TThreadPriority);
  begin
    SetThreadPriority(FHandle, Priorities[Value]);
  end;

//procedure TThread.Synchronize(Method: TThreadMethod);
//begin
//  FSynchronizeException := nil;
//  FMethod := Method;
//end;

  procedure TThread.SetSuspended(Value: Boolean);
  begin
    if Value <> FSuspended then
      if Value then
        Suspend else
        Resume;
  end;

  procedure TThread.Suspend;
  begin
    FSuspended := True;
    SuspendThread(FHandle);
  end;

  procedure TThread.Resume;
  begin
    if ResumeThread(FHandle) = 1 then FSuspended := False;
  end;

  procedure TThread.Terminate;
  begin
    FTerminated := True;
  end;

  function TThread.WaitFor: LongWord;
  var
    Msg: TMsg;
    H: THandle;
  begin
    H := FHandle;
    if GetCurrentThreadID = MainThreadID then
      while MsgWaitForMultipleObjects(1, H, False, INFINITE,
        QS_SENDMESSAGE) = WAIT_OBJECT_0 + 1 do PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE)
    else WaitForSingleObject(H, INFINITE);
    GetExitCodeThread(H, Result);
  end;


end.

{$I Defines.inc}

unit MoreHistoryListBase;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    MoreHistoryCtrl,
    MoreHistoryClasses;


  type
    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FIdx :Integer;
      FPos :Word;
      FLen :Byte;
      FSel :Byte;
    end;

    TMyFilter = class(TExList)
    public
      procedure Add(AIndex, APos, ALen :Integer);
      procedure AddGroup(AIndex :Integer; AExpanded :Boolean);

    public
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;

    private
      FName :TString;
      FDomain :TString;

      function GetItems(AIndex :Integer) :Integer;

    public
      property Name :TString read FName write FName;
      property Domain :TString read FDomain write FDomain;
      property Items[AIndex :Integer] :Integer read GetItems; default;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TMyFilter                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyFilter.Add(AIndex, APos, ALen :Integer);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := Word(APos);
    vRec.FLen := Byte(ALen);
    vRec.FSel := 0;
    AddData(vRec);
  end;


  procedure TMyFilter.AddGroup(AIndex :Integer; AExpanded :Boolean);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := 0;
    vRec.FLen := 0;
    vRec.FSel := 2;
    if AExpanded then
      vRec.FSel := vRec.FSel or 4;
    AddData(vRec);
  end;


  function TMyFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


  function TMyFilter.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FName, TString(Key));
  end;


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vHst1, vHst2 :THistoryEntry;
  begin
    Result := 0;

    vHst1 := FarHistory[PFilterRec(PItem).FIdx];
    vHst2 := FarHistory[PFilterRec(PAnother).FIdx];

    case Abs(Context) of
      1 : Result := UpCompareStr(vHst1.Path, vHst2.Path);
      2 : Result := DateTimeCompare(vHst1.Time, vHst2.Time);
      3 : Result := IntCompare(vHst1.Hits, vHst2.Hits);
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
  end;


end.


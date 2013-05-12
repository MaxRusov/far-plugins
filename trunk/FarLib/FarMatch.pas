{$I Defines.inc}
{$Typedaddress Off}

unit FarMatch;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Поиск подстроки с поддержкой масок                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    FarCtrl;

  type
    TMatchOption = (
      moIgnoreCase,  // Пока игнорируется
      moWilcards,    // Пока игнорируется
      moWithin,
      moWordBegin
    );
    TMatchOptions = set of TMatchOption;


  function StringMatch(const AMask, AXMask :TString; AStr :PTChar; var APos, ALen :Integer; AOpt :TMatchOptions = [moIgnoreCase, moWilcards]) :Boolean;

  function ChrCheckXMask(const AMask, AXMask :TString; AStr :PTChar; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;
  function ChrCheckMask(const AMask :TString; AStr :PTChar; AStrLen :Integer; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;
  function CheckMask(const AMask  :TString; const AStr :TString; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function StringMatch(const AMask, AXMask :TString; AStr :PTChar; var APos, ALen :Integer; AOpt :TMatchOptions = [moIgnoreCase, moWilcards]) :Boolean;

    function ChrMatch(AStrI, AChr1, AChr2 :TChar) :Boolean;
    begin
      Result := (AStrI = AChr1) or (AStrI = AChr2);
      if not Result then begin
        AStrI := CharUpCase(AStrI);
        Result := (AStrI = CharUpCase(AChr1)) or ((AChr1 <> AChr2) and (AStrI = CharUpCase(AChr2)));
      end;
    end;

    function IsBegWord(AStrI :PTChar) :Boolean;
    begin
//    Result := (AStrI = AStr) or (not IsCharAlphaNumeric((AStrI - 1)^) and IsCharAlphaNumeric(AStrI^));
      Result := (AStrI = AStr) or (not IsCharAlphaNumeric((AStrI - 1)^) or not IsCharAlphaNumeric(AStrI^));
    end;

  var
    vMsk, vXMsk, vStr, vMsk1, vXMsk1, vStr1, vBeg :PTChar;
    vChr1, vChr2, vXChr1, vXChr2 :TChar;
    vFromWord :Boolean;
  begin
    Result := False;
    APos := 0; ALen := 0;

    vMsk  := PTChar(AMask);
    if length(AMask) = length(AXMask) then
      vXMsk := PTChar(AXMask)
    else
      vXMsk := vMsk;
    vStr  := AStr;

    if not (moWithin in AOpt) then begin

      { Сравнение с начальной частью маски, не содержащей "*" или "?" }
      while (vMsk^ <> #0) and (vMsk^ <> '*') do begin
        if (vStr^ = #0) or not ((vMsk^ = '?') or ChrMatch(vStr^, vMsk^, vXMsk^)) then
          Exit;
        inc(vMsk);
        inc(vXMsk);
        inc(vStr);
      end;

      if vMsk^ = #0 then begin
        { Маска не содержит wildcard'ов }
        if vStr^ = #0 then begin
          ALen := vStr - PTChar(AStr);
          Result := True;
        end;
        Exit;
      end;

    end;

    vBeg := nil;
    if vStr > AStr then
      vBeg := AStr;

    vFromWord := moWordBegin in AOpt;

    while True do begin
      Assert((vMsk^ = '*') or ((vMsk = PTChar(AMask)) and (moWithin in AOpt)));

      while (vMsk^ <> #0) and (vMsk^ = '*') do begin
        Inc(vMsk);
        Inc(vXMsk);
      end;

      if vMsk^ = #0 then begin
        { Маска закончилась '*' }
        if vBeg = nil then
          vBeg := AStr;
        APos := vBeg - AStr;
        ALen := vStr - vBeg;
        Result := True;
        Exit;
      end;

      while True do begin

        { Ищем совпадение первого символа }
        if vMsk^ <> '?' then begin
          vChr1 := CharUpCase(vMsk^);
          vChr2 := CharLoCase(vMsk^);

          vXChr1 := #0; vXChr2 := #0;
          if vMsk <> vXMsk then begin
            vXChr1 := CharUpCase(vXMsk^);
            vXChr2 := CharLoCase(vXMsk^);
          end;

          while vStr^ <> #0 do begin
            if (vStr^ = vChr1) or (vStr^ = vChr2) or (vStr^ = vXChr1) or (vStr^ = vXChr2) then
              if not vFromWord or IsBegWord(vStr) then
                Break;
            Inc(vStr);
          end;
        end else
        begin
          while vStr^ <> #0 do begin
            if not vFromWord or IsBegWord(vStr) then
              Break;
            Inc(vStr);
          end;
        end;

        if vStr^ = #0 then
          Exit;

        { Нашли первое совпадение, посмотрим дальше... }
        vMsk1  := vMsk + 1;
        vXMsk1 := vXMsk + 1;
        vStr1  := vStr + 1;
        while (vMsk1^ <> #0) and (vMsk1^ <> '*') do begin
          if (vStr1^ = #0) or not ((vMsk1^ = '?') or ChrMatch(vStr1^, vMsk1^, vXMsk1^)) then
            Break;
          inc(vMsk1);
          inc(vXMsk1);
          inc(vStr1);
        end;

        if (vMsk1^ = #0) and ((vStr1^ = #0) or (moWithin in AOpt)) then begin
          { Маска закончилась, полное совпадение}
          if vBeg = nil then
            vBeg := vStr;
          APos := vBeg - AStr;
          ALen := vStr1 - vBeg;
          Result := True;
          Exit;
        end;

        if vMsk1^ = '*' then begin
          vFromWord := False;
          if vBeg = nil then
            vBeg := vStr;
          vMsk := vMsk1;
          vXMsk := vXMsk1;
          vStr := vStr1;
          Break;
        end;

        { Продолжим поиск }
        Inc(vStr);
      end;
    end;

    APos := vBeg - AStr;
    ALen := vStr - vBeg;
  end;



  function ChrCheckXMask(const AMask, AXMask :TString; AStr :PTChar; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;
  var
    vOpt :TMatchOptions;
  begin
    vOpt := [moIgnoreCase];
    if AHasMask then
      vOpt := vOpt + [moWilcards];

    if (AMask <> '') and ((AMask[1] = '*') {or (AMask[1] = '?')}) then
      vOpt := vOpt + [moWithin]
    else
      vOpt := vOpt + [moWithin, moWordBegin];

    Result := StringMatch(AMask, AXMask, AStr, APos, ALen, vOpt)
  end;


  function ChrCheckMask(const AMask :TString; AStr :PTChar; AStrLen :Integer; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;
  begin
    Result := ChrCheckXMask(AMask, '', AStr, AHasMask, APos, ALen)
  end;


  function CheckMask(const AMask, AStr :TString; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;
  begin
    Result := ChrCheckXMask(AMask, '', PTChar(AStr), AHasMask, APos, ALen);
  end;


end.


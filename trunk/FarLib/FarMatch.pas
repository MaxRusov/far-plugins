{$I Defines.inc}
{$Typedaddress Off}

unit FarMatch;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Вспомогательные интерфейсные процедуры                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    FarCtrl;


  function StringMatch(const AMask :TString; AStr :PTChar; var APos, ALen :Integer) :Boolean;

  function CheckMask(const AMask, AStr :TString; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;

  
{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function StringMatch(const AMask :TString; AStr :PTChar; var APos, ALen :Integer) :Boolean;
  var
    vMsk, vStr, vMsk1, vStr1, vBeg :PTChar;
    vChr :TChar;
  begin
    Result := False;
    APos := 0; ALen := 0;

    vMsk := PTChar(AMask);
    vStr := AStr;

    { Сравнение с начальной частью маски, не содержащей "*" или "!" }
    while (vMsk^ <> #0) and (vMsk^ <> '*') do begin
      if (vStr^ = #0) or not {ChrMatch(vMsk^, vStr^)} ((vMsk^ = '?') or (vMsk^ = vStr^) or (CharUpCase(vMsk^) = CharUpCase(vStr^))) then
        Exit;
      inc(vMsk);
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

    vBeg := nil;
    if vStr > AStr then
      vBeg := AStr;

    while True do begin
      Assert(vMsk^ = '*');

      while (vMsk^ <> #0) and (vMsk^ = '*') do
        Inc(vMsk);
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

        if vMsk^ <> '?' then begin
          vChr := CharUpCase(vMsk^);
          while (vStr^ <> #0) and (vChr <> CharUpCase(vStr^)) do
            Inc(vStr);
          if vStr^ = #0 then
            Exit;
        end;

        { Нашли первое совпадение, посмотрим дальше... }
        vMsk1 := vMsk + 1;
        vStr1 := vStr + 1;
        while (vMsk1^ <> #0) and (vMsk1^ <> '*') do begin
          if (vStr1^ = #0) or not {ChrMatch(vMsk^, vStr^)} ((vMsk1^ = '?') or (vMsk1^ = vStr1^) or (CharUpCase(vMsk1^) = CharUpCase(vStr1^))) then
            Break;
          inc(vMsk1);
          inc(vStr1);
        end;

        if (vMsk1^ = #0) and (vStr1^ = #0) then begin
          { Маска закончилась, полное совпадение}
          if vBeg = nil then
            vBeg := vStr;
          APos := vBeg - AStr;
          ALen := vStr1 - vBeg;
          Result := True;
          Exit;
        end;

        if vMsk1^ = '*' then begin
          if vBeg = nil then
            vBeg := vStr;
          vMsk := vMsk1;
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



  function CheckMask(const AMask, AStr :TString; AHasMask :Boolean; var APos, ALen :Integer) :Boolean;
  var
    vCh, vFirstCh :TChar;
    vFirstIsWord, vLastIsDelim, vMatch :Boolean;
    vPtr, vEnd :PTChar;
    vMaskLen :Integer;
  begin
    Result := False;
    APos := 0; ALen := 0;
    if (AMask <> '') and (AStr <> '') then begin
      vFirstCh := AMask[1];
      if (vFirstCh = '*') {or (vFirstCh = '?')} then
        Result := StringMatch(AMask, PTChar(AStr), APos, ALen)
      else begin
        vFirstCh := CharUpCase(vFirstCh);
        vFirstIsWord := IsCharAlphaNumeric(vFirstCh);

        vMaskLen := Length(AMask);

        vPtr := PTChar(AStr);
        vEnd := vPtr + Length(AStr);
        if not AHasMask then
          Dec(vEnd, vMaskLen - 1);

        vLastIsDelim := True;
        while vPtr < vEnd do begin
          vCh := CharUpCase(vPtr^);
          if vFirstIsWord then begin
            if IsCharAlphaNumeric(vCh) then begin
              vMatch := vLastIsDelim and (vCh = vFirstCh);
              vLastIsDelim := False;
            end else
            begin
              vMatch := False;
              vLastIsDelim := True;
            end;
          end else
            vMatch := (vCh = vFirstCh) or (vFirstCh = '?');

          if vMatch then begin
            if AHasMask then begin
              if StringMatch(AMask, vPtr, APos, ALen) then begin
                APos := vPtr - PTChar(AStr);
                Result := True;
                Exit;
              end;
            end else
            begin
              if (vMaskLen = 1) or (AnsiStrLIComp(PTChar(AMask), vPtr, vMaskLen) = 0) then begin
                APos := vPtr - PTChar(AStr);
                ALen := vMaskLen;
                Result := True;
                Exit;
              end;
            end;
          end;
          Inc(vPtr);
        end;
      end;
    end;
  end;



end.


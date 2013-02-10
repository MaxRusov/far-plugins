{$I Defines.inc}

unit FarHintsTags;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* ID3 utils                                                                  *}
{******************************************************************************}

interface

  uses
    Windows,

    MixTypes,
    MixUtils,
    MixStrings;


  type
    TID3Tags = record
      FTitle   :TString;
      FArtist  :TString;
      FAlbum   :TString;
      FYear    :TString;
      FComment :TString;
      FLength  :TString;
    end;


  const
    cID3v1TagID :array[0..2] of AnsiChar = 'TAG';

  type
    PID3v1Tag = ^TID3v1Tag;
    TID3v1Tag = packed record
      cID     :array[0..2] of AnsiChar;
      cTitle  :array[0..29] of AnsiChar;
      cArtist :array[0..29] of AnsiChar;
      cAlbum  :array[0..29] of AnsiChar;
      cYear   :array[0..3] of AnsiChar;
      case Byte of
        0: (
          cComment  :array[0..29] of AnsiChar;
          btGenre   :Byte;
        );
        1: (
          cComment2 :array[0..27] of AnsiChar;
          cZero     :AnsiChar;
          btTrack   :Byte;
//        btGenre   :Byte;
        );
    end;


  const
    cID3v2TagID    :array[0..2] of AnsiChar = 'ID3';

    cFrameTitle2   :array[0..2] of AnsiChar = 'TT2';
    cFrameArtist2  :array[0..2] of AnsiChar = 'TP1';
    cFrameAlbum2   :array[0..2] of AnsiChar = 'TAL';

    cFrameTitle3   :array[0..3] of AnsiChar = 'TIT2';
    cFrameArtist3  :array[0..3] of AnsiChar = 'TPE1';
    cFrameAlbum3   :array[0..3] of AnsiChar = 'TALB';
    cFrameYear3    :array[0..3] of AnsiChar = 'TYER';
    cFrameComment3 :array[0..3] of AnsiChar = 'COMM';
    cFrameLength3  :array[0..3] of AnsiChar = 'TLEN';

  const
    cIDv2Flag_Unsynchronisation = $80;
    cIDv2Flag_ExtHeader         = $40;
    cIDv2Flag_Experimental      = $20;
    cIDv2Flag_HasFooter         = $10;


  type
    PID3v2TagHeader = ^TID3v2TagHeader;
    TID3v2TagHeader = packed record
      cID       :array[0..2] of AnsiChar;
      cVersion  :Byte;
      cRevision :Byte;
      cFlags    :Byte;
      cSize     :DWORD;
    end;

    PID3v2ExtHeader = ^TID3v2FrameHeader;
    TID3v2ExtHeader = packed record
      cSize    :DWORD;
      cCount   :Byte;
      cFlags   :Byte;
    end;

    TSmallSize = array[0..2] of Byte;
    PID3v2_2_FrameHeader = ^TID3v2_2_FrameHeader;
    TID3v2_2_FrameHeader = packed record
      cID      :array[0..2] of AnsiChar;
      cSize    :TSmallSize;
    end;

    PID3v2FrameHeader = ^TID3v2FrameHeader;
    TID3v2FrameHeader = packed record
      cID      :array[0..3] of AnsiChar;
      cSize    :DWORD;
      cFlags   :Word;
    end;

  function ReadID3v1(AFile :THandle; var ATags :TID3Tags) :Boolean;
  function ReadID3v2(AFile :THandle; var ATags :TID3Tags) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function UnsReorder(AVal :Cardinal) :Integer;
  begin
    Result := Integer(
      ((AVal and $000000FF) shl 24) +
      ((AVal and $0000FF00) shl 8)  +
      ((AVal and $00FF0000) shr 8)  +
      ((AVal and $FF000000) shr 24)
    );
  end;


  function UnsInt2Int(AVal :Cardinal) :Integer;
  begin
    AVal := Cardinal( UnsReorder(AVal) );
    Result := Integer(
      ((AVal and $0000007F)) +
      ((AVal and $00007F00) shr 1)  +
      ((AVal and $007F0000) shr 2)  +
      ((AVal and $7F000000) shr 3)
    );
  end;


  function WordReorder(AVal :Word) :Word;
  begin
    Result :=
      ((AVal and $00FF) shl 8)  +
      ((AVal and $FF00) shr 8);
  end;


  function SmallSize2Int(ASize :TSmallSize) :Integer;
  type
    TRec = packed record Hi :Byte; Lo :TSmallSize; end;
  var
    vSize :Cardinal;
  begin
    vSize := 0;
    TRec(vSize).Lo := ASize;
//  Result := UnsInt2Int(vSize);
    Result := UnsReorder(vSize);
  end;


  function StrTrimLenA(AStr :PAnsiChar; ALen :Integer) :Integer;
  var
    vStr :PAnsiChar;
  begin
    vStr := AStr;
    while (vStr < AStr + ALen) and (vStr^ <> #0) do
      Inc(vStr);
    while (vStr > AStr) and ((vStr - 1)^ = ' ') do
      Dec(vStr);
    Result := vStr - AStr;
  end;


  function StrFromChrA(AStr :PAnsiChar; ALen :Integer) :TAnsiStr;
  begin
    ALen := StrTrimLenA(AStr, ALen);
    SetString(Result, AStr, ALen);
  end;


  function StrFromChrW(AStr :PWideChar; ALen :Integer) :TWideStr;
  var
    vStr :PWideChar;
  begin
    vStr := AStr;
    while (vStr < AStr + ALen) and (vStr^ <> #0) do
      Inc(vStr);
    while (vStr > AStr) and ((vStr - 1)^ = ' ') do
      Dec(vStr);
    SetString(Result, AStr, vStr - AStr);
  end;


  function StrFromChrW_BE(AStr :PWideChar; ALen :Integer) :TWideStr;
  var
    I :Integer;
  begin
    for I := 0 to ALen - 1 do
      Word((AStr + I)^) := WordReorder(Word((AStr + I)^));
    Result := StrFromChrW(AStr, ALen);
  end;


  function StrFromChr_UTF8(AStr :PAnsiChar; ALen :Integer) :TWideStr;
  var
    vLen :Integer;
  begin
    ALen := StrTrimLenA(AStr, ALen);
    vLen := MultiByteToWideChar(CP_UTF8, 0, AStr, ALen, nil, 0);
    SetString(Result, nil, vLen);
    if vLen > 0 then
      MultiByteToWideChar(CP_UTF8, 0, AStr, ALen, PWideChar(Result), vLen);
  end;


  function DecodeStr1(APtr :PAnsiChar; AEncoding :Byte; ASize :Integer) :TWideStr;
  var
    vWPtr :PWideChar;
    vBOM :WORD;
  begin
    Result := '';
    case AEncoding of
      0:
        { ISO-8859-1 }
        Result := TString(StrFromChrA(APtr, ASize));
      1: begin
        { UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM }
        { ÿþ - UTF16LE (1200) - Norm }
        { þÿ - UTF16BE (1201) }
        vWPtr := Pointer(APtr);
        vBOM := WORD(vWPtr^);
        Inc(vWPtr);
        if vBOM = PWord(@BOM_UTF16[1])^ then
          Result := StrFromChrW(vWPtr, (ASize div SizeOf(WideChar)) - 1)
        else
        if vBOM = PWord(@BOM_UTF16BE[1])^ then
          Result := StrFromChrW_BE(vWPtr, (ASize div SizeOf(WideChar)) - 1)
      end;
      2:
        { UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM }
        Result := StrFromChrW_BE(Pointer(APtr), (ASize div SizeOf(WideChar)) - 1);
      3:
        { UTF-8 [UTF-8] encoded Unicode [UNICODE] }
        Result := StrFromChr_UTF8(APtr, ASize);
    end;
  end;

  function DecodeStr(APtr :PAnsiChar; ASize :Integer) :TWideStr;
  var
    vEncoding :Byte;
  begin
    vEncoding := Byte(APtr^);
    Inc(APtr);
    Result := DecodeStr1(APtr, vEncoding, ASize - 1)
  end;


  function ParseTagV2_2(ATag :PAnsiChar; AFlags :Byte; ASize :Integer; var ATags :TID3Tags) :Boolean;
  var
    vFrame :PID3v2_2_FrameHeader;
    vTagSize, vSize :Integer;
    vPtr :PAnsiChar;
    vStr :TString;
  begin
    Result := False;
    vTagSize := ASize;

    while (vTagSize >= SizeOf(TID3v2_2_FrameHeader)) and (ATag^ <> #0) do begin
      vFrame := Pointer(ATag);
      vSize := SmallSize2Int(vFrame.cSize);
      if (vSize < 0) or (vSize > vTagSize - SizeOf(TID3v2_2_FrameHeader)) then begin
//      NOP;
        Exit;
      end;

      if (vFrame.cID = cFrameTitle2) or (vFrame.cID = cFrameArtist2) or (vFrame.cID = cFrameAlbum2) then begin
        vPtr := ATag + SizeOf(TID3v2_2_FrameHeader);
        vStr := DecodeStr(vPtr, vSize);

        if (vFrame.cID = cFrameTitle2) and (ATags.FTitle = '') then
          ATags.FTitle := vStr
        else
        if (vFrame.cID = cFrameArtist2) and (ATags.FArtist = '') then
          ATags.FArtist := vStr
        else
        if (vFrame.cID = cFrameAlbum2) and (ATags.FAlbum = '') then
          ATags.FAlbum := vStr;
      end;

//    TraceF('%s = %s', [vFrame.cID, vWStr]);

      Inc(ATag, vSize + SizeOf(TID3v2_2_FrameHeader));
      Dec(vTagSize, vSize + SizeOf(TID3v2_2_FrameHeader));
    end;
    Result := True;
  end;



  function ParseTagV2_3(ATag :PAnsiChar; AFlags :Byte; ASize :Integer; var ATags :TID3Tags) :Boolean;
  var
    vFrameSize :Integer;

    procedure LocStrTag(var AStr :TString);
    var
      vPtr :PAnsiChar;
    begin
      if AStr = '' then begin
        vPtr := ATag + SizeOf(TID3v2FrameHeader);
        AStr := DecodeStr(vPtr, vFrameSize);
      end;
    end;

    procedure LocCommentTag(var AStr :TString);
    var
      vPtr :PAnsiChar;
      vEncoding :Byte;
    begin
      if AStr = '' then begin
        vPtr := ATag + SizeOf(TID3v2FrameHeader);
        vEncoding := Byte(vPtr^);
        Inc(vPtr);
        Inc(vPtr, 3); //Lang
        AStr := DecodeStr1(vPtr, vEncoding, vFrameSize{!!!});
      end;
    end;

  var
    vFrame :PID3v2FrameHeader;
    vHasExtHeader :Boolean;
    vSize :Integer;
  begin
    Result := False;

    vHasExtHeader := cIDv2Flag_ExtHeader and AFlags <> 0;
//  vHasFooter := cIDv2Flag_HasFooter and AFlags <> 0;

    if vHasExtHeader then begin
      vSize := UnsInt2Int(PDWORD(ATag)^) + SizeOf(Integer);
      if (vSize < SizeOf(TID3v2ExtHeader)) or (vSize > ASize - SizeOf(TID3v2FrameHeader)) then
        Exit;
      Inc(ATag, vSize);
      Dec(ASize, vSize);
    end;

    while (ASize >= SizeOf(TID3v2FrameHeader)) and (ATag^ <> #0) do begin
      vFrame := Pointer(ATag);
      vFrameSize := UnsReorder(vFrame.cSize);
      if (vFrameSize < 0) or (vFrameSize > ASize - SizeOf(TID3v2FrameHeader)) then begin
//      NOP;
        Exit;
      end;

      if vFrame.cFlags and $FF00 = 0 then begin

        if vFrame.cID = cFrameTitle3 then
          LocStrTag(ATags.FTitle)
        else
        if vFrame.cID = cFrameArtist3 then
          LocStrTag(ATags.FArtist)
        else
        if vFrame.cID = cFrameAlbum3 then
          LocStrTag(ATags.FAlbum)
        else
        if vFrame.cID = cFrameYear3 then
          LocStrTag(ATags.FYear)
        else
        if vFrame.cID = cFrameLength3 then
          LocStrTag(ATags.FLength);
//      else
//      if vFrame.cID = cFrameComment3 then
//        LocCommentTag(ATags.FComment);

      end else
        NOP;

      Inc(ATag, vFrameSize + SizeOf(TID3v2FrameHeader));
      Dec(ASize, vFrameSize + SizeOf(TID3v2FrameHeader));
    end;
    Result := True;
  end;



  procedure Unsynchronize(APtr :Pointer; var ASize :Integer);
  var
    vSrc, vDst, vEnd :Pointer1;
  begin
    vSrc := APtr;
    vDst := APtr;
    vEnd := vSrc + ASize - 1;
    while vSrc < vEnd do begin
      if PWord(vSrc)^ = $00FF then begin
        if vSrc <> vDst then
          vDst^ := vSrc^;
        inc(vSrc, 2);
        inc(vDst);
      end else
      begin
        if vSrc <> vDst then
          vDst^ := vSrc^;
        inc(vSrc);
        inc(vDst);
      end;
    end;
  end;



  function ReadID3v2(AFile :THandle; var ATags :TID3Tags) :Boolean;
  var
    vHeader :TID3v2TagHeader;
    vRes  :DWORD;
    vSize :Integer;
    vMem  :Pointer;
  begin
    Result := False;
    SetFilePointer(AFile, 0, nil, FILE_BEGIN);
    ReadFile(AFile, vHeader, SizeOf(vHeader), vRes, nil);
    if (vHeader.cID = cID3v2TagID) and (vHeader.cSize and $80808080 = 0) then begin
      vSize := UnsInt2Int(vHeader.cSize);
      if vSize > 0 then begin
        vMem := MemAlloc(vSize);
        try
          ReadFile(AFile, vMem^, vSize, vRes, nil);
          if vRes = DWORD(vSize) then begin

            if vHeader.cFlags and cIDv2Flag_Unsynchronisation <> 0 then
              Unsynchronize(vMem, vSize);

            if vHeader.cVersion = 2 then
              Result := ParseTagV2_2(vMem, vHeader.cFlags, vSize, ATags)
            else
            if (vHeader.cVersion = 3) or (vHeader.cVersion = 4) then
              Result := ParseTagV2_3(vMem, vHeader.cFlags, vSize, ATags)
            else
              {NOP};

            if Result then
              Result := (ATags.FTitle <> '') or (ATags.FArtist <> '');   
          end;
        finally
          MemFree(vMem);
        end;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function ReadID3v1(AFile :THandle; var ATags :TID3Tags) :Boolean;
  var
    vTag  :TID3v1Tag;
    vRes  :DWORD;
  begin
    Result := False;
    SetFilePointer(AFile, -SizeOf(vTag), nil, FILE_END);
    ReadFile(AFile, vTag, SizeOf(vTag), vRes, nil);
    if (vRes = SizeOf(vTag)) and (vTag.cID = 'TAG') then begin

      ATags.FTitle := TString(StrFromChrA(vTag.cTitle, SizeOf(vTag.cTitle)));
      ATags.FArtist := TString(StrFromChrA(vTag.cArtist, SizeOf(vTag.cArtist)));
      ATags.FAlbum := TString(StrFromChrA(vTag.cAlbum, SizeOf(vTag.cAlbum)));
      ATags.FYear := TString(StrFromChrA(vTag.cYear, SizeOf(vTag.cYear)));
      ATags.FComment := TString(StrFromChrA(vTag.cComment, SizeOf(vTag.cComment)));

      Result := True;
    end;
  end;


end.

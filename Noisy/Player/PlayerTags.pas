{$I Defines.inc}

unit PlayerTags;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Player main module                                                         *}
{******************************************************************************}

interface

  uses
    Windows,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    
    Bass,

    NoisyConsts,
    NoisyUtil,
    PlayerReg;


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
    cID3v2TagID   :array[0..2] of AnsiChar = 'ID3';

    cFrameTitle2  :array[0..2] of AnsiChar = 'TT2';
    cFrameArtist2 :array[0..2] of AnsiChar = 'TP1';
    cFrameAlbum2  :array[0..2] of AnsiChar = 'TAL';

    cFrameTitle3  :array[0..3] of AnsiChar = 'TIT2';
    cFrameArtist3 :array[0..3] of AnsiChar = 'TPE1';
    cFrameAlbum3  :array[0..3] of AnsiChar = 'TALB';

  const
    cIDv2Flag_Unsynchronisation = $80;
    cIDv2Flag_ExtHeader         = $40;
    cIDv2Flag_Experimental      = $20;
    cIDv2Flag_HasFooter         = $10;


  type
    PID3v2TagHeader = ^TID3v2TagHeader;
    TID3v2TagHeader = packed record
      cID      :array[0..2] of AnsiChar;
      cVersion :Word;
      cFlags   :byte;
      cSize    :DWORD;
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


  function ParseTagV2(ATag :PAnsiChar; var ATitle, AArtist, AAlbum :TString) :Boolean;

  function ParseOtherTags(AHande :DWORD; var ATitle, AArtist, AAlbum :TString) :Boolean;

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


  function DecodeStr(APtr :PAnsiChar; ASize :Integer) :TWideStr;
  var
    vCode :Integer;
    vWPtr :PWideChar;
  begin
    vCode := Byte(APtr^);
    Inc(APtr);
    if vCode = 0 then
      Result := TWideStr(StrFromChrA(APtr, ASize - 1))
    else
    if vCode = 1 then begin
      vWPtr := Pointer(APtr);
      Inc(vWPtr);
      Result := StrFromChrW(vWPtr, (ASize div SizeOf(WideChar)) - 1)
    end else
    begin
      Result := '';
      Exit;
    end;
  end;


  function ParseTagV2_2(ATag :PAnsiChar; var ATitle, AArtist, AAlbum :TString) :Boolean;
  var
    vHeader :PID3v2TagHeader;
    vFrame :PID3v2_2_FrameHeader;
    vTagSize, vSize :Integer;
    vPtr :PAnsiChar;
    vStr :TString;
  begin
    Result := False;
    vHeader := Pointer(ATag);
    vTagSize := UnsInt2Int(vHeader.cSize);
    if (vTagSize < SizeOf(TID3v2FrameHeader)) {or (vTagSize > ???} then
      Exit;
    Inc(ATag, SizeOf(TID3v2TagHeader));

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

        if (vFrame.cID = cFrameTitle2) and (ATitle = '') then
          ATitle := vStr
        else
        if (vFrame.cID = cFrameArtist2) and (AArtist = '') then
          AArtist := vStr
        else
        if (vFrame.cID = cFrameAlbum2) and (AAlbum = '') then
          AAlbum := vStr;
      end;

//    TraceF('%s = %s', [vFrame.cID, vWStr]);

      Inc(ATag, vSize + SizeOf(TID3v2_2_FrameHeader));
      Dec(vTagSize, vSize + SizeOf(TID3v2_2_FrameHeader));
    end;
    Result := True;
  end;


  function ParseTagV2_3(ATag :PAnsiChar; var ATitle, AArtist, AAlbum :TString) :Boolean;
  var
    vHeader :PID3v2TagHeader;
    vFrame :PID3v2FrameHeader;
    vHasExtHeader, vUnsync :Boolean;
    vTagSize, vSize :Integer;
    vPtr :PAnsiChar;
    vStr :WideString;
  begin
    Result := False;
    vHeader := Pointer(ATag);
    vTagSize := UnsInt2Int(vHeader.cSize);
    if (vTagSize < SizeOf(TID3v2FrameHeader)) {or (vTagSize > ???} then
      Exit;
    vUnsync := cIDv2Flag_Unsynchronisation and vHeader.cFlags <> 0;
    vHasExtHeader := cIDv2Flag_ExtHeader and vHeader.cFlags <> 0;
//  vHasFooter := cIDv2Flag_HasFooter and vHeader.cFlags <> 0;
    Inc(ATag, SizeOf(TID3v2TagHeader));

    if vUnsync then begin
//    Trace('Unsync...');
    end;

    if vHasExtHeader then begin
      vSize := UnsInt2Int(PDWORD(ATag)^) + SizeOf(Integer);
      if (vSize < SizeOf(TID3v2ExtHeader)) or (vSize > vTagSize - SizeOf(TID3v2FrameHeader)) then
        Exit;
      Inc(ATag, vSize);
      Dec(vTagSize, vSize);
    end;

    while (vTagSize >= SizeOf(TID3v2FrameHeader)) and (ATag^ <> #0) do begin
      vFrame := Pointer(ATag);
      vSize := UnsReorder(vFrame.cSize);
      if (vSize < 0) or (vSize > vTagSize - SizeOf(TID3v2FrameHeader)) then begin
//      NOP;
        Exit;
      end;

      if (vFrame.cID = cFrameTitle3) or (vFrame.cID = cFrameArtist3) or (vFrame.cID = cFrameAlbum3) then begin
        vPtr := ATag + SizeOf(TID3v2FrameHeader);
        vStr := DecodeStr(vPtr, vSize);

        if (vFrame.cID = cFrameTitle3) and (ATitle = '') then
          ATitle := vStr
        else
        if (vFrame.cID = cFrameArtist3) and (AArtist = '') then
          AArtist := vStr
        else
        if (vFrame.cID = cFrameAlbum3) and (AAlbum = '') then
          AAlbum := vStr;
      end;

//    SetString(vStr, ATag + SizeOf(TID3v2FrameHeader) + 1, vSize - 1);
//    TraceF('%s = %s', [vFrame.cID, vWStr]);

      Inc(ATag, vSize + SizeOf(TID3v2FrameHeader));
      Dec(vTagSize, vSize + SizeOf(TID3v2FrameHeader));
    end;
    Result := True;
  end;


  function ParseTagV2(ATag :PAnsiChar; var ATitle, AArtist, AAlbum :TString) :Boolean;
  var
    vHeader :PID3v2TagHeader;
  begin
    Result := False;
    ATitle := '';
    AArtist := '';
    AAlbum := '';
    vHeader := Pointer(ATag);
    if (vHeader.cID = cID3v2TagID) and (vHeader.cSize and $80808080 = 0) then begin

      if vHeader.cVersion <= 2 then
        Result := ParseTagV2_2(ATag, ATitle, AArtist, AAlbum)
      else
      if vHeader.cVersion <= 4 then
        Result := ParseTagV2_3(ATag, ATitle, AArtist, AAlbum)
      else
        {NOP};

      if not Result then begin
//      Trace('Error!!!');
      end;

      if Result then
        Result := (ATitle <> '') or (AArtist <> '');
    end;
  end;


 {-----------------------------------------------------------------------------}


  var
    FTagsDLL :THandle;

  var
    TAGS_Read :function(handle: DWORD; const fmt: PAnsiChar): PAnsiChar; stdcall;
//  TAGS_GetVersion :function :DWORD; stdcall;
//  TAGS_GetLastErrorDesc :function : PAnsiChar; stdcall;


  procedure LoadTagsDLL;
  begin
    FTagsDLL := LoadLibrary('tags.dll');
    if FTagsDLL = 0 then begin
      FTagsDLL := INVALID_HANDLE_VALUE;
      Exit;
    end;

    TAGS_Read := GetProcAddress(FTagsDll, 'TAGS_Read');
//  TAGS_GetVersion := GetProcAddress(FTagsDll, 'TAGS_GetVersion');
//  TAGS_GetLastErrorDesc := GetProcAddress(FTagsDll, 'TAGS_GetLastErrorDesc');
  end;


  function ParseOtherTags(AHande :DWORD; var ATitle, AArtist, AAlbum :TString) :Boolean;
  begin
    Result := False;
    if FTagsDLL = 0 then
      LoadTagsDLL;
    if not Assigned(TAGS_Read) then
      Exit;

    ATitle := TString(TAGS_Read(AHande, '%TITL'));
    AArtist := TString(TAGS_Read(AHande, '%ARTI'));
    AAlbum := TString(TAGS_Read(AHande, '%ALBM'));

    Result := (ATitle <> '') or (AArtist <> '');
  end;


end.

{$I Defines.inc}

unit FontsTTF;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* FontMan Far plugin                                                         *}
{* Чтение заголовка TTF файла                                                 *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils;

  const
    cVersion = $00000100;
    cNameTableTag = $656D616E;  { 'name' (reordered) }

  function ReadTTFInfo(const AFileName :TString; var AFamily, ASubFamily, AFullName :TString) :Boolean;
  function ReadTTFNameTable(ABuf :Pointer; ATableSize :Integer; var AFamily, ASubFamily, AFullName, ACopyright :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { Документация                                                                }
 { http://www.microsoft.com/typography/otspec/otff.htm                         }
 {-----------------------------------------------------------------------------}

  type
    PFontHeaderRec = ^TFontHeaderRec;
    TFontHeaderRec = packed record
      Version       :Cardinal;
      Tables        :Word;
      searchRange   :Word;
      entrySelector :Word;
      rangeShift    :Word;
    end;

    PTableDirRec = ^TTableDirRec;
    TTableDirRec = packed record
      Tag          :Cardinal;
      checkSum     :Cardinal;
      offset       :Cardinal;
      length       :Cardinal;
    end;

    PNameTabHeaderRec = ^TNameTabHeaderRec;
    TNameTabHeaderRec = packed record
      Format       :word;
      Count        :word;
      StringOffset :word;
    end;

    PNameRecord = ^TNameRecord;
    TNameRecord = packed record
      PlatformID   :word;
      EncodingID   :word;
      LanguageID   :word;
      NameID       :word;
      Length       :word;
      Offset       :word;
    end;


  function ReorderWord(AVal :Word) :Word;
  begin
    Result := ((AVal and $00FF) shl 8) + ((AVal and $FF00) shr 8);
  end;


  function ReorderLong(AVal :Cardinal) :Integer;
  begin
    Result := Integer(
      ((AVal and $000000FF) shl 24) +
      ((AVal and $0000FF00) shl 8)  +
      ((AVal and $00FF0000) shr 8)  +
      ((AVal and $FF000000) shr 24)
    );
  end;


  procedure ReorderString(var AStr :WideString);
  var
    I :Integer;
    vPtr :PWideChar;
  begin
    vPtr := PWideChar(AStr);
    for I := 1 to Length(AStr) do begin
      Word(vPtr^) := ReorderWord(Word(vPtr^));
      Inc(vPtr);
    end;
  end;


  function ReadTTFInfo(const AFileName :TString; var AFamily, ASubFamily, AFullName :TString) :Boolean;
  var
    I, vSize, vTables, vOffset, vLength :Integer;
    vFile :Integer;
    vFontHeader :TFontHeaderRec;
    vTableDir :PTableDirRec;
    vBuf, vBuf1 :Pointer;
    vCopyright :TString;
  begin
    Result := False;
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile < 0 then
      Exit;
    try
      if FileRead(vFile, vFontHeader, SizeOf(vFontHeader)) <> SizeOf(vFontHeader) then
        Exit;

      if vFontHeader.Version <> cVersion then begin
        NOP;
        Exit;
      end;

      vTables := ReorderWord(vFontHeader.Tables);
      vSize := vTables * SizeOf(TTableDirRec);
      vBuf := MemAllocZero(vSize);
      try
        if FileRead(vFile, vBuf^, vSize) <> vSize then
          Exit;

        vTableDir := vBuf;
        for I := 0 to vTables - 1 do begin
          if vTableDir.Tag = cNameTableTag then begin
            vOffset := ReorderLong(vTableDir.offset);
            vLength := ReorderLong(vTableDir.length);

            vBuf1 := MemAllocZero(vLength);
            try
              FileSeek(vFile, vOffset, 0);
              if FileRead(vFile, vBuf1^, vLength) <> vLength then
                Exit;

              Result := ReadTTFNameTable(vBuf1, vLength, AFamily, ASubFamily, AFullName, vCopyright);

            finally
              MemFree(vBuf1);
            end;

            Break;
          end;

          Inc(TUnsPtr(vTableDir), SizeOf(TTableDirRec));
        end;

      finally
        MemFree(vBuf);
      end;

    finally
      FileClose(vFile);
    end;
  end;



  function ReadTTFNameTable(ABuf :Pointer; ATableSize :Integer; var AFamily, ASubFamily, AFullName, ACopyright :TString) :Boolean;
  var
    vStrOffset :Integer;

    function LocGetStr(ANameRec :PNameRecord) :WideString;
    var
      vLen, vOffs, vPlatform, vEncoding, vLang :Integer;
      vPtr :Pointer;
    begin
      Result := '';
      vPlatform := ReorderWord(ANameRec.platformID);
      vEncoding := ReorderWord(ANameRec.encodingID);
      vLang := ReorderWord(ANameRec.LanguageID);

      vLen := ReorderWord(ANameRec.length);
      vOffs := ReorderWord(ANameRec.offset);
      if vStrOffset + vOffs + vLen > ATableSize then begin
        NOP;
        Exit;
      end;

      vPtr := Pointer(TUnsPtr(ABuf) + TUnsPtr(vStrOffset) + TUnsPtr(vOffs));

      if vPlatform = 1{Macintosh} then begin
//      if (vEncoding = 0{Roman}) and (vLang = 0{English}) then
//        SetString(Result, PAnsiChar(vPtr), vLen)
      end else
      if (vPlatform = 0{Unicode}) or ((vPlatform = 3{Microsoft}) and (vEncoding in [0, 1, 10]) and (vLang = 1033{English})) then begin
        SetString(Result, PWideChar(vPtr), vLen div 2);
        ReorderString(Result);
      end else
        {Unknown};
    end;

    procedure LocSetStr(var AStr :TString; ANameRec :PNameRecord);
    begin
      if AStr <> '' then
        Exit;
      AStr := LocGetStr(ANameRec);
    end;

  var
    I, vCount, vNameID :Integer;
    vNameRec :PNameRecord;
  begin
    Result := False;

    vCount := ReorderWord(PNameTabHeaderRec(ABuf).Count);
    vStrOffset := ReorderWord(PNameTabHeaderRec(ABuf).StringOffset);
    if ((SizeOf(TNameTabHeaderRec) + vCount * SizeOf(TNameRecord)) > vStrOffset) or (vStrOffset > ATableSize) then begin
      NOP;
      Exit;
    end;

    vNameRec := Pointer(TUnsPtr(ABuf) + SizeOf(TNameTabHeaderRec));
    for I := 0 to vCount - 1 do begin
      vNameID := ReorderWord(vNameRec.nameID);
//    TraceF('ID=%d, Enc=%d,%d,%d : %s', [vNameID,
//      ReorderWord(vNameRec.platformID), ReorderWord(vNameRec.encodingID), ReorderWord(vNameRec.languageID), LocGetStr(vNameRec)]);
      case vNameID of
        0: LocSetStr(ACopyright, vNameRec);
        1: LocSetStr(AFamily, vNameRec);
        2: LocSetStr(ASubFamily, vNameRec);
        4: LocSetStr(AFullName, vNameRec);
      end;
      Inc(TUnsPtr(vNameRec), SizeOf(TNameRecord));
    end;

    Result := True;
  end;


end.


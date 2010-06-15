{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{$I Defines.inc}

unit UCharMapCtrl;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    FarCtrl;


  const
    strLang   = 0;
    strTitle  = 1;
    strError  = 2;

    strGroups = 3;
    strFonts  = 4;

    strSymbol = 5;
    strRange  = 6;
    strCode   = 7;


  const
    cPlugRegFolder = 'UCharMap';

    cGroupList     = 'GroupsList.txt';
    cNamesList     = 'NamesList.txt';

  var
    optFoundColor  :Integer = $0A;
    optCurrColor   :Integer = 0;
    optHiddenColor :Integer = 0;

    optShowHidden  :Boolean = True;
    optMaximized   :Boolean = False;

    FontName       :TString = 'Lucida Console';
    FontSize       :Integer = 32;

    CmdPrefix      :TFarStr = 'ucharmap';

  var
    FModuleName    :TString;
    FRegRoot       :TString;


  type
    TUnicodeGroup = class(TBasis)
    public
      constructor CreateEx(ACode1, ACode2 :Integer; const AName :TString);

    private
      FCode1 :Integer;
      FCode2 :Integer;
      FName  :TString;

    public
      property Code1 :Integer read FCode1;
      property Code2 :Integer read FCode2;
      property Name  :TSTring read FName;
    end;

  var
    GroupNames :TObjList;
    CharNames  :TStrList;
    FontNames  :TStrList;

  function NameOfChar(ACode :Integer) :TString;
  function NameOfRange(ACode :Integer) :TString;

  procedure SRectGrow(var AR :TSmallRect; ADX, ADY :Integer);

  procedure ReadSettings;

  procedure ReadSetup;
  procedure WriteSetup;

  procedure InitCharGroups;
  procedure InitCharNames;

  procedure InitFontList;
  function GetFontRange(const AFontName :TString) :TBits;

  function GetFont(const AName :TString; ASize :Integer; APitch, AWeight :Integer; AItalic :Boolean) :HFont;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  constructor TUnicodeGroup.CreateEx(ACode1, ACode2 :Integer; const AName :TString);
  begin
    Create;
    FCode1 := ACode1;
    FCode2 := ACode2;
    FName  := AName;
  end;


 {-----------------------------------------------------------------------------}

  function ReadTextFile(const AFileName :TString; var ASize :Integer) :PAnsiChar;
  var
    vFile :Integer;
  begin
    Result := nil;
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile < 0 then
      Exit;
    try
      ASize := GetFileSize(vFile, nil);
      if ASize <= 0 then
        Exit;

      Result := MemAlloc(ASize);
      FileRead(vFile, Result^, ASize);

    finally
      FileClose(vFile);
    end;
  end;


  function SeekToNextA(var AStr :PAnsiChar; const AChrs :TAnsiCharSet) :PAnsiChar;
  begin
    while (AStr^ <> #0) and not (AStr^ in AChrs) do
      Inc(AStr);
    Result := AStr;
    while (AStr^ <> #0) and (AStr^ in AChrs) do
      Inc(AStr);
  end;


  function HexStr2Int(AStr :PAnsiChar; ADef :Integer) :Integer;
  var
    vDig :Integer;
  begin
    Result := 0;
    vDig := 0;
    while AStr^ <> #0 do begin
      case AStr^ of
        '0'..'9': vDig := Ord(AStr^) - Ord('0');
        'A'..'F': vDig := Ord(AStr^) - (Ord('A') - 10); { Без скобок компилит в две операции (вычитание и сложение) }
        'a'..'f': vDig := Ord(AStr^) - (Ord('a') - 10); { -//- }
      else
        Result := ADef;
        Exit;
      end;

      Result := Result * 16 + vDig;

      Inc(AStr);
    end;
  end;


  procedure InitCharGroups;
  var
    vFileName :TString;
    vSize, vCode1, vCode2 :Integer;
    vBuf, vPtr, vEnd, vStr, vNum, vTmp :PAnsiChar;
  begin
    if GroupNames <> nil then
      Exit;

    vFileName := AddFileName(ExtractFilePath(FModuleName), cGroupList);
    vBuf := ReadTextFile(vFileName, vSize);
    if vBuf = nil then
      Exit;
    try
      GroupNames := TObjList.Create;

      vPtr := vBuf;
      vEnd := vPtr + vSize;
      while vPtr < vEnd do begin
        vStr := vPtr;
        vTmp := SeekToNextA(vPtr, [#10, #13]);
        vTmp^ := #0;
        if (vStr^ = #0) or (vStr^ = '@') or (vStr^ = #9) then
          Continue;

        vNum := vStr;
        vTmp := SeekToNextA(vStr, [#9, ' ']);
        vTmp^ := #0;

        vCode1 := HexStr2Int(vNum, -1);
        if vCode1 = -1 then
          Continue;

        vNum := vStr;
        vTmp := SeekToNextA(vStr, [#9, ' ']);
        vTmp^ := #0;

        vCode2 := HexStr2Int(vNum, -1);
        if vCode2 = -1 then
          Continue;

        GroupNames.Add( TUnicodeGroup.CreateEx(vCode1, vCode2, TString(vStr)) );
      end;

    finally
      MemFree(vBuf);
    end;
  end;


  procedure InitCharNames;
  var
    vFileName :TString;
    vSize, vCode, vMax :Integer;
    vBuf, vPtr, vEnd, vStr, vNum, vTmp :PAnsiChar;
  begin
    if CharNames <> nil then
      Exit;

    vFileName := AddFileName(ExtractFilePath(FModuleName), cNamesList);
    vBuf := ReadTextFile(vFileName, vSize);
    if vBuf = nil then
      Exit;
    try
      CharNames := TStrList.Create;
      CharNames.Count := $10000;
      vMax := -1;

      vPtr := vBuf;
      vEnd := vPtr + vSize;
      while vPtr < vEnd do begin
        vStr := vPtr;
        vTmp := SeekToNextA(vPtr, [#10, #13]);
        vTmp^ := #0;
        if (vStr^ = #0) or (vStr^ = '@') or (vStr^ = #9) then
          Continue;

        vNum := vStr;
        vTmp := SeekToNextA(vStr, [#9, ' ']);
        vTmp^ := #0;

        vCode := HexStr2Int(vNum, -1);
        if vCode = -1 then
          Continue;

//      TraceF('%d - %s', [vCode, vStr]);
        if vCode > $FFFF then
          Break;

        if vCode >= vMax then
          vMax := vCode;

        CharNames[vCode] := TString(vStr);
      end;

      if CharNames.Count > vMax + 1 then
        CharNames.Count := vMax + 1;

    finally
      MemFree(vBuf);
    end;
  end;


  function NameOfRange(ACode :Integer) :TString;
  var
    I :Integer;
  begin
    if GroupNames <> nil then
      for I := 0 to GroupNames.Count - 1 do 
        with TUnicodeGroup(GroupNames[I]) do
          if (ACode >= Code1) and (ACode <= Code2) then begin
            Result := Name;
            Exit;
          end;
    Result := '';
  end;


  function NormalizeStr(const AStr :TString) :TString;
  var
    vPtr :PTChar;
    vFirst :Boolean;
  begin
    SetString(Result, PTChar(AStr), Length(AStr));

    vFirst := True;
    vPtr := PTChar(Result);
    while vPtr^ <> #0 do begin
      if IsCharAlphaNumeric(vPtr^) then begin
        if vFirst then
          vFirst := False
        else
          vPtr^ := CharLoCase(vPtr^);
      end else
        vFirst := True;
      Inc(vPtr);
    end;
  end;


  function NameOfChar(ACode :Integer) :TString;
  begin
    Result := '';
    if (CharNames <> nil) and (ACode < CharNames.Count) then
      Result := NormalizeStr( CharNames[ACode] );
  end;


  procedure SRectGrow(var AR :TSmallRect; ADX, ADY :Integer);
  begin
    dec(AR.Left,   ADX);
    inc(AR.Right,  ADX);
    dec(AR.Top,    ADY);
    inc(AR.Bottom, ADY);
  end;


 {-----------------------------------------------------------------------------}

  function EnumFontsProc(const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricExW; AFontType :Integer; AParam :Pointer): Integer; stdcall;
  var
    vName :TString;
  begin
    Result := 1;
    vName := ALogFont.elfLogFont.lfFaceName;
    if (vName = '') or (vName[1] = '@') then
      Exit;
    TStrList(AParam).AddSorted(vName, 0, dupIgnore);
  end;


  procedure InitFontList;
  var
    vDC :HDC;
    vLogFont :TLogFont;
  begin
    if FontNames <> nil then
      Exit;

    FontNames := TStrList.Create;

    vDC := GetDC(0);
    try
      FillChar(vLogFont, SizeOf(vLogFont), 0);
      vLogFont.lfCharset := DEFAULT_CHARSET;
      EnumFontFamiliesEx(vDC, vLogFont, @EnumFontsProc, Integer(FontNames), 0);
    finally
      ReleaseDC(0, vDC);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GetFont(const AName :TString; ASize :Integer; APitch, AWeight :Integer; AItalic :Boolean) :HFont;
  var
    vDC :HDC;
    vHeight, vPPI :Integer;
  begin
    vDC := CreateCompatibleDC(0);
    vPPI := GetDeviceCaps(vDC, LogPixelsY);
    DeleteDC(vDC);

    vHeight := MulDiv(ASize, vPPI, 72);

    Result := CreateFont(
      {lfHeight}         -vHeight,
      {lfWidth}          0,
      {lfEscapement}     0,
      {lfOrientation}    0,
      {lfWeight}         AWeight, {IntIf(fsBold in AStyle, FW_Bold, FW_Normal)}
      {lfItalic}         IntIf(AItalic, 1, 0),
      {lfUnderline}      0,
      {lfStrikeOut}      0,
      {lfCharSet}        DEFAULT_CHARSET,
      {lfOutPrecision}   OUT_DEFAULT_PRECIS,
      {lfClipPrecision}  CLIP_DEFAULT_PRECIS,
      {lfQuality}        DEFAULT_QUALITY,
      {lfPitchAndFamily} APitch {DEFAULT_PITCH},
      {lfFaceName}       PTChar(AName)
    );
  end;


  function GetFontRange(const AFontName :TString) :TBits;
  var
    vDC :HDC;
    vFont, vOldFont :HFont;
    vInfo :PGlyphSet;
    I, J, vSize :Integer;
  begin
    Result := nil;
    vFont := 0; vOldFont := 0; vInfo := nil;
    vDC := CreateDC('Display', nil, nil, nil);
    if vDC = 0 then
      Exit;
    try
      vFont := GetFont(AFontName, 12, DEFAULT_PITCH{FInfo.Pitch}, FW_Normal{FInfo.Weight}, False{FInfo.Italic});
      if vFont = 0 then
        Exit;

      vOldFont := SelectObject(vDC, vFont);
      if vOldFont = 0 then
        Exit;

      vSize := GetFontUnicodeRanges(vDC, nil);
      if vSize = 0 then
        Exit;

      vInfo := MemAllocZero(vSize);
      GetFontUnicodeRanges(vDC, vInfo);

      {$R-}
//    TraceF('Glyphs: %d, Ranges: %d', [vInfo.cGlyphsSupported, vInfo.cRanges]);
      Result := TBits.Create;
      Result.Size := $10000;
      for I := 0 to vInfo.cRanges - 1 do
        with vInfo.Ranges[I] do
          for J := Word(wcLow) to Word(wcLow) + cGlyphs - 1 do
            Result[J] := True;

    finally
      MemFree(vInfo);
      if vOldFont <> 0 then
        SelectObject(vDC, vOldFont);
      if vFont <> 0 then
        DeleteObject(vFont);
      DeleteDC(vDC);
    end;
  end;



 {-----------------------------------------------------------------------------}

  procedure ReadSettings;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
//    optHistoryFolder := RegQueryStr(vKey, 'HistoryFolder', optHistoryFolder);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optMaximized := RegQueryLog(vKey, 'Maximized', optMaximized);
      optShowHidden := RegQueryLog(vKey, 'ShowHidden', optShowHidden);

      optFoundColor := RegQueryInt(vKey, 'FoundColor', optFoundColor);
      optCurrColor := RegQueryInt(vKey, 'CurrentColor', optCurrColor);
      optHiddenColor := RegQueryInt(vKey, 'HiddenColor', optHiddenColor);

      FontName := RegQueryStr(vKey, 'FontName', FontName);
      FontSize := RegQueryInt(vKey, 'FontSize', FontSize);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'Maximized', optMaximized);
      RegWriteLog(vKey, 'ShowHidden', optShowHidden);

      RegWriteStr(vKey, 'FontName', FontName);
      RegWriteInt(vKey, 'FontSize', FontSize);

    finally
      RegCloseKey(vKey);
    end;
  end;


initialization
finalization
  FreeObj(GroupNames);
  FreeObj(CharNames);
  FreeObj(FontNames);
end.


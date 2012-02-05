{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
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
    Far_API,
    FarCtrl,
    FarConfig;


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
    cPluginName = 'UCharMap';
    cPluginDescr = 'Unicode CharMap FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{59223378-9DCD-45FC-97C9-AD0251A3C53F}';
    cMenuID     :TGUID = '{5D95C31A-A452-4EA4-ACC6-8C371F4F1E8F}';
   {$endif Far3}

    cMainDlgId  :TGUID = '{E1158E5F-8408-4832-8CCD-71DA1DD43BC3}';
    cFontDlgId  :TGUID = '{1EC1FF68-F45D-4AD7-8752-DC18E0D2B498}';
    cGroupDlgId :TGUID = '{E1F79204-8470-4635-BD6A-5DE4CC2F8093}';
    cCharDlgId  :TGUID = '{12045CE0-6113-4413-9975-532E848FB0DC}';

    cGroupList  = 'GroupsList.txt';
    cNamesList  = 'NamesList.txt';

  var
    optFoundColor     :TFarColor;
    optCurrColor      :TFarColor;
    optHiddenColor    :TFarColor;
    optDelimColor     :TFarColor;

    optMaximized      :Boolean = False;
    optShowHidden     :Boolean = True;
    optShowNumbers    :Boolean = True;
    optShowCharName   :Boolean = True;
    optShowGroupName  :Boolean = False;
    optShowHints      :Boolean = True;
    optAutoChooseFont :Boolean = True;
    optGroupBy        :Boolean = True;

    FontName          :TString = 'Lucida Console';
    FontSize          :Integer = 32;

    CmdPrefix         :TFarStr = 'ucharmap';


  type
    TUnicodeGroup = class(TBasis)
    public
      constructor CreateEx(ACode1, ACode2 :Integer; const AName :TString);

    private
      FCode1  :Integer;
      FCode2  :Integer;
      FName   :TString;
      FClosed :Boolean;

    public
      property Code1 :Integer read FCode1;
      property Code2 :Integer read FCode2;
      property Name  :TSTring read FName;
      property Closed :Boolean read FClosed write FClosed;
    end;

  var
    GroupNames :TObjList;
    CharNames  :TStrList;
    FontNames  :TStrList;

    FontRange  :TBits;

  function NameOfChar(ACode :Integer) :TString;
  function NameOfRange(ACode :Integer) :TString;

  procedure SRectGrow(var AR :TSmallRect; ADX, ADY :Integer);

  procedure InitCharGroups;
  procedure InitCharNames;

  procedure InitFontList;
  function GetFont(const AName :TString; ASize :Integer; APitch, AWeight :Integer; AItalic :Boolean) :HFont;
  function GetFontRange(const AFontName :TString) :TBits;

  procedure UpdateFontRange;
  function CharMapped(AChar :TChar) :Boolean;
  function ChooseFontFor(AChar :TChar) :TString;

  procedure RestoreDefColor;
  procedure PluginConfig(AStore :Boolean);

  procedure HandleError(AError :Exception);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('Unicode CharMap', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;

 {-----------------------------------------------------------------------------}

  constructor TUnicodeGroup.CreateEx(ACode1, ACode2 :Integer; const AName :TString);
  begin
    Create;
    FCode1  := ACode1;
    FCode2  := ACode2;
    FName   := AName;
    FClosed := False;
  end;


 {-----------------------------------------------------------------------------}

  function ReadTextFile(const AFileName :TString; var ASize :Integer) :PAnsiChar;
  var
    vFile :THandle;
  begin
    Result := nil;
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile = INVALID_HANDLE_VALUE then
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
   {$ifndef bDelphi64}
    vDig := 0;
   {$endif bDelphi64}
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

    vFileName := AddFileName(ExtractFilePath(FARAPI.ModuleName), cGroupList);
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
    vIsCtrl :Boolean;
  begin
    if CharNames <> nil then
      Exit;

    vFileName := AddFileName(ExtractFilePath(FARAPI.ModuleName), cNamesList);
    vBuf := ReadTextFile(vFileName, vSize);
    if vBuf = nil then
      Exit;

    try
      CharNames := TStrList.Create;
      CharNames.Count := $10000;

      vIsCtrl := False;
      vCode := 0;
      vMax := -1;

      vPtr := vBuf;
      vEnd := vPtr + vSize;
      while vPtr < vEnd do begin
        vStr := vPtr;
        vTmp := SeekToNextA(vPtr, [#10, #13]);
        vTmp^ := #0;
        if (vStr^ = #0) or (vStr^ = '@') then
          Continue;

        if not vIsCtrl then begin
          if vStr^ = #9 then
            Continue;

          vNum := vStr;
          vTmp := SeekToNextA(vStr, [#9, ' ']);
          vTmp^ := #0;

          vCode := HexStr2Int(vNum, -1);
          if vCode = -1 then
            Continue;

//        TraceF('%d - %s', [vCode, vStr]);
          if vCode > $FFFF then
            Break;

          if vCode >= vMax then
            vMax := vCode;

          CharNames[vCode] := TString(vStr);
          vIsCtrl := StrEqual(CharNames[vCode], '<Control>');
        end else
        begin
          while vStr^ in [' ', #9] do
            Inc(vStr);
          if vStr^ = '=' then begin
            Inc(vStr);
            while vStr^ in [' ', #9] do
              Inc(vStr);
            CharNames[vCode] := TString(vStr);
          end;
          vIsCtrl := False;
        end;
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



  procedure UpdateFontRange;
  begin
    FreeObj(FontRange);
    FontRange := GetFontRange(FontName);
  end;


  function CharMapped(AChar :TChar) :Boolean;
  begin
    Result := True;
    if FontRange <> nil then
      Result := FontRange[Word(AChar)];
  end;



  function ChooseFontFor(AChar :TChar) :TString;
  var
    I :Integer;
    vFontName :TString;
    vRange :TBits;
  begin
    Result := '';
    InitFontList;

    for I := 0 to FontNames.Count - 1 do begin
      vFontName := FontNames[I];
      vRange := GetFontRange(vFontName);
      try
        if vRange[Word(AChar)] then begin
//        TraceF('Choose font: %s', [vFontName]);
          Result := vFontName;
          Exit;
        end;
      finally
        FreeObj(vRange);
      end;
    end;
  end;



 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optFoundColor    := MakeColor(clLime, 0);
    optDelimColor    := MakeColor(clWhite, 0);
    optCurrColor     := UndefColor;
    optHiddenColor   := UndefColor; //MakeColor(clOlive, 0);
  end;


  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

         LogValue('Maximized', optMaximized);
         LogValue('ShowHidden', optShowHidden);

         LogValue('ShowNumbers', optShowNumbers);
         LogValue('ShowGroupName', optShowGroupName);
         LogValue('ShowCharName', optShowCharName);
         LogValue('ShowHints', optShowHints);
         LogValue('GroupBy', optGroupBy);

         StrValue('FontName', FontName);
         IntValue('FontSize', FontSize);

      finally
        Destroy;
      end;
  end;


initialization
finalization
  FreeObj(GroupNames);
  FreeObj(CharNames);
  FreeObj(FontNames);
  FreeObj(FontRange);
end.


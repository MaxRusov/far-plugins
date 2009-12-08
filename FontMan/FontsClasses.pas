{$I Defines.inc}

unit FontsClasses;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* FontMan Far plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    ShlObj,
    ShellAPi,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,

    FontsCtrl,
    FontsTTF,
    FontsCopyDlg;


  type
    TFontType = (
      ftUnknown,
      ftVector,
      ftRaster,
      ftTrueType,
      ftOpenType,
      ftType1
    );
    TFontTypes = set of TFontType;

    TFontStyle = (
      fsBold,
      fsItalic
    );
    TFontStyles = set of TFontStyle;

    TPitchType = (
      stMonospace,
      stProportional
    );
    TPitchTypes = set of TPitchType;

    TFontCharsets = set of byte;

    TFontCharset = class(TNamedObject)
    public
      constructor CreateEx(const AName :TString; ACode :Integer);

    public
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FCode :Integer;

    public
      property Code :Integer read FCode;
    end;


    TFontInfo = class(TNamedObject)
    public
      constructor CreateEx(const AName :TString; const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer);
      destructor Destroy; override;

      function GetCharsetsAsStr :TString;

      procedure SetFileName(const AFileName :TString);

    private
      FFontType  :TFontType;
      FPitch     :Integer;
      FWeight    :Integer;
      FItalic    :Boolean;
      FCopyright :TString;
      FFamily    :TString;
      FSubFamily :TString;
      FFullName  :TString;
      FFileName  :TString;
      FRegValue  :TString;
      FSize      :Integer;
      FTime      :TFileTime;
      FCharsets  :TIntList;
      FSizes     :TIntList;

      procedure DetectSizes;
      procedure ReadFontData(const ALogFont :TEnumLogFontEx);

    public
      property Family :TString read FFamily;
      property SubFamily :TString read FSubFamily;
      property FontType :TFontType read FFontType;
      property Pitch :Integer read FPitch;
      property Weight :Integer read FWeight;
      property Italic :Boolean read FItalic;
      property FileName :TString read FFileName;
      property Size :Integer read FSize;
      property Time :TFileTime read FTime;
      property Charsets :TIntList read FCharsets;
      property Sizes :TIntList read FSizes;
    end;


    TFontFamily = class(TNamedObject)
    public
      constructor CreateEx(const AName :TString; const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer);
      destructor Destroy; override;

      function GetTotalSize :Integer;
      function GetLastTime :TFileTime;

    private
      FFontType  :TFontType;
      FPitchType :TPitchType;
      FDescr     :TString;
      FStyles    :TObjList;

    public
      property FontType :TFontType read FFontType;
      property Styles :TObjList read FStyles;
      property Descr :TString read FDescr;
    end;


    TFontsList = class(TObjList)
    public
      constructor Create; override;
      procedure ReRead;

    private
      procedure BuildFontList;
      procedure BuildStylesList;
      procedure ReadRegInfo;
    end;


    TTTFFile = class(TNamedObject)
    public
      constructor CreateEx(const AFileName, AFamily, ASubFamily, AFullName, AFromFolder :TString);

    private
      FFamily     :TString;
      FSubFamily  :TString;
      FFullName   :TString;
      FFromFolder :TString;

      function GetVisName :TString;

    public
      property VisName :TString read GetVisName;
    end;


    TFontsPanel = class(TBasis)
    public
      constructor CreateEx(ANumber :Integer);
      destructor Destroy; override;

      function GetItem(const AName :TString) :TBasis;
      procedure GetItems(var AItems :PPluginPanelItem; var ACount :Integer);
      procedure FreeItems(AItems :PPluginPanelItem; ACount :Integer);
      function SetDirectory(const ADir :TString) :Boolean;
      function GetFontInfo(const AName, AResFileName :TString) :boolean;
      function CopyFontsTo(AItems :PPluginPanelItem; ACount :Integer; const AFolder :TString; AMove, ASilence :Boolean) :Integer;
      function InstallFontsFrom(AItems :PPluginPanelItem; ACount :Integer; AMove :Boolean) :Integer;
      function DeleteFonts(AItems :PPluginPanelItem; ACount :Integer; ASilence :Boolean) :Integer;

      function ClickItem(const AName :TString) :Integer;
      procedure SetGroupMode(AMode :Integer);
      procedure SetGroupAll(AValue :Boolean);
      procedure SetFilterByType(AValue :TFontTypes);
      procedure SetFilterByPitch(AValue :TPitchTypes);
      procedure SetFilterByCharset(const AValue :TFontCharsets);

      procedure ReRead;

    public
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FNumber    :Integer;
      FTitle     :TString;
      FGroupMode :Integer;    { 1-No group. 2-By Family }
      FGroupAll  :Boolean;    { Групировать не TrueType шрифты }
      FPath      :TString;
      FIndex     :TExList;
      FFonts     :TFontsList;

      FFilterByType     :TFontTypes;
      FFilterByPitch    :TPitchTypes;
      FFilterByCharsets :TFontCharsets;

      procedure Reindex;
      procedure Update;

      procedure ShowProgress(const ATitle, AName :TString; APercent :Integer);
      function CheckInterrupt :Boolean;

      procedure LowUninstall(AStyle :TFontInfo);

    public
      property Number :Integer read FNumber;
      property Title :TString read FTitle;
      property Path :TString read FPath;
      property GroupMode :Integer read FGroupMode;
      property GroupAll :Boolean read FGroupAll;
      property FilterByType :TFontTypes read FFilterByType;
      property FilterByPitch :TPitchTypes read FFilterByPitch;
      property FilterByCharsets :TFontCharsets read FFilterByCharsets;
    end;

  var
    DefPanelMode        :Integer = 0;

    DefGroupMode        :Integer = 2;
    DefGroupAll         :Boolean = False;

    DefFilterByType     :TFontTypes = [];
    DefFilterByPitch    :TPitchTypes = [];
    DefFilterByCharsets :TFontCharsets = [];


  var
    LastAccessedPanel :TFontsPanel;

  function Charsets :TObjList;
  function FontTypeAsStr(AFontType :TFontType) :TString;

  function NewFontsPanel :TFontsPanel;
  function FindFontsPanel(ANumber :Integer) :TFontsPanel;
  procedure FreeFontsPanel(APanel :TFontsPanel);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    FontsHints,
    MixDebug;


  const
    NTM_PS_OPENTYPE = $00020000;
    NTM_TT_OPENTYPE = $00040000;
    NTM_TYPE1       = $00100000;


  function StrLeftAjust(const AStr :TString; ALen :Integer) :TString;
  var
    vlen :Integer;
  begin
    vLen := Length(AStr);
    if vLen >= ALen then
      Result := Copy(AStr, 1, ALen)
    else
      Result := AStr + StringOfChar(' ', ALen - vLen);
  end;


  procedure StrToFile(AFile :Integer; const AStr :TString);
  begin
    FileWrite(AFile, PTChar(AStr)^, length(AStr) * SizeOf(TChar));
    FileWrite(AFile, CRLF, 2 * SizeOf(TChar));
  end;


  function GetSpecialFolder(FolderType :Integer) :TString;
  var
    pidl :PItemIDList;
    buf  :array[0..MAX_PATH] of TChar;
  begin
    Result := '';
    if SHGetSpecialFolderLocation(0, FolderType, pidl) = NOERROR then begin
      SHGetPathFromIDList(pidl, buf);
      Result := buf;
    end;
  end;


  function GetFontRegPath :TString;
  begin
    {!!! В зависимости от версии windows... }
    Result := 'Software\Microsoft\Windows NT\CurrentVersion\Fonts';
  end;


  procedure RegDelete(ARoot :HKEY; const APath, AName :TString);
  var
    vKey :HKey;
  begin
    RegOpenWrite(ARoot, APath, vKey);
    try
      RegDeleteValue(vKey, PTChar(AName));
    finally
      RegCloseKey(ARoot);
    end;
  end;


  function ShellOpenEx(AWnd :THandle; const FName, Param :TString; AMask :ULONG;
    AShowMode :Integer; AInfo :PShellExecuteInfo) :Boolean;
  var
    vInfo :TShellExecuteInfo;
  begin
//  Trace(FName);
    if not Assigned(AInfo) then
      AInfo := @vInfo;
    FillChar(AInfo^, SizeOf(AInfo^), 0);
    AInfo.cbSize        := SizeOf(AInfo^);
    AInfo.fMask         := AMask;
    AInfo.Wnd           := AWnd {AppMainForm.Handle};
    AInfo.lpFile        := PTChar(FName);
    AInfo.lpParameters  := PTChar(Param);
    AInfo.nShow         := AShowMode;
    Result := ShellExecuteEx(AInfo);
  end;


  function ShellOpen(AWnd :THandle; const FName, Param :TString) :Boolean;
  begin
    Result := ShellOpenEx(AWnd, FName, Param, 0{ or SEE_MASK_FLAG_NO_UI}, SW_Show, nil);
  end;


  function FolderIsEmpty(const aFolderName :TString) :Boolean; {override;}
  var
    vFileName :TString;
    vHandle :THandle;
    vData :TWIN32FindData;
  begin
    Result := False;
    vFileName := AddFileName(aFolderName, '*.*');
    vHandle := FindFirstFile(PTChar(vFileName), vData);
    if vHandle = INVALID_HANDLE_VALUE then
      Exit;
    while True do begin
      Result := (vData.cFileName[0] = '.') and ((vData.cFileName[1] = #0) or
        ((vData.cFileName[1] = '.') and (vData.cFileName[2] = #0)));
      if not Result then
        Break;
      if not FindNextFile(vHandle, vData) then
        Break;
    end;
    Windows.FindClose(vHandle);
  end;


  procedure DeleteEmptyFolders(const AFromFolder, AToFolder :TString);
  var
    vFolder :TString;
  begin
    vFolder := AFromFolder;
    while UpCompareSubStr(AToFolder, vFolder) = 0 do begin
      vFolder := RemoveBackSlash(vFolder);
      if FolderIsEmpty(vFolder) then begin
        if not RemoveDirectory(PTChar(vFolder)) then
          Break;
      end else
        Break;
      vFolder := ExtractFilePath(vFolder);
    end;
  end;



  var
    GCharsets :TObjList;


  procedure InitCharsets;

    procedure LocAdd(const AName :TString; ACode :Integer);
    begin
      GCharsets.Add(TFontCharset.CreateEx(AName, ACode));
    end;

  begin
    GCharsets := TObjList.Create;
//  LocAdd('Default', DEFAULT_CHARSET);
    LocAdd('Ansi', ANSI_CHARSET);
    LocAdd('Symbol', SYMBOL_CHARSET);
    LocAdd('Greek', GREEK_CHARSET);
    LocAdd('Turkish', TURKISH_CHARSET);
    LocAdd('Vietnamese', VIETNAMESE_CHARSET);
    LocAdd('Hebrew', HEBREW_CHARSET);
    LocAdd('Arabic', ARABIC_CHARSET);
    LocAdd('Baltic', BALTIC_CHARSET);
    LocAdd('Cyrillic', RUSSIAN_CHARSET);
    LocAdd('Thai', THAI_CHARSET);
    LocAdd('European', EASTEUROPE_CHARSET);
    LocAdd('ShiftJIS', SHIFTJIS_CHARSET);
    LocAdd('Hangeul', HANGEUL_CHARSET);
    LocAdd('GB2312', GB2312_CHARSET);
    LocAdd('ChineseBig5', CHINESEBIG5_CHARSET);
    LocAdd('Johab', JOHAB_CHARSET);
    LocAdd('MAC', MAC_CHARSET);
    LocAdd('OEM/DOS', OEM_CHARSET);
  end;


  function Charsets :TObjList;
  begin
    if GCharsets = nil then
      InitCharsets;
    Result := GCharsets;
  end;


  function FontCharsetName(ACharset :Byte) :TString;
  var
    vIndex :Integer;
  begin
    with Charsets do begin
      if FindKey(Pointer(TUnsPtr(ACharset)), 1, [], vIndex) then begin
        with TFontCharset(Items[vIndex]) do
          Result := Name;
      end else
        Result := Format('Charset %d', [ACharset]);
    end;
  end;


  function DetectType(AFontType :Integer; const ATextMetric :TNewTextMetricEx) :TFontType;
  begin
//  Result := ftUnknown;
    if AFontType and RASTER_FONTTYPE <> 0 then
      Result := ftRaster
    else
    if AFontType and TRUETYPE_FONTTYPE = 0 then
      Result := ftVector
    else begin
      Result := ftTrueType;
      if NTM_TYPE1 and ATextMetric.ntmTm.ntmFlags <> 0 then
        Result := ftType1;
      if NTM_TT_OPENTYPE and ATextMetric.ntmTm.ntmFlags <> 0 then
        Result := ftOpenType;
      if NTM_PS_OPENTYPE and ATextMetric.ntmTm.ntmFlags <> 0 then
        Result := ftOpenType;
    end;
  end;


  function FontTypeAsStr(AFontType :TFontType) :TString;
  const
    cTypes :array[TFontType] of TString = (
      'Unknown', 'Vector', 'Raster', 'TrueType', 'OpenType', 'Type1'
    );
  begin
    Result := cTypes[AFontType];
  end;


//const
//  cFontExts = '*.fon,*.ttf,*.ttc';

  var
    GKnownExts :TObjList;

  function KnownExts :TObjList;
  begin
    if GKnownExts = nil then begin
      GKnownExts := TObjList.Create;
//    GKnownExts.Add( TNamedObject.CreateName('fon') );
      GKnownExts.Add( TNamedObject.CreateName('ttf') );
//    GKnownExts.Add( TNamedObject.CreateName('ttc') );
    end;
    Result := GKnownExts;
  end;


//function GetFontExts :TString;
//begin
//end;


  var
    GDisplayDC :HDC;
    GPPI :Integer;

 {-----------------------------------------------------------------------------}
 { TTTFFile                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TTTFFile.CreateEx(const AFileName, AFamily, ASubFamily, AFullName, AFromFolder :TString);
  begin
    CreateName(AFileName);
    FFamily     := AFamily;
    FSubFamily  := ASubFamily;
    FFullName   := AFullName;
    FFromFolder := AFromFolder;
  end;


  function TTTFFile.GetVisName :TString;
  begin
    Result := ExtractFileName(FName);
    if FFullName <> '' then
      Result := FFullName + ' (' + Result + ')';
  end;


 {-----------------------------------------------------------------------------}
 { TFontCharset                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TFontCharset.CreateEx(const AName :TString; ACode :Integer);
  begin
    CreateName(AName);
    FCode := ACode;
  end;


  function TFontCharset.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    if Context = 1 then
      Result := IntCompare(FCode, Integer(TUnsPtr(Key)))
    else
      Result := inherited CompareKey(Key, Context);
  end;


 {-----------------------------------------------------------------------------}
 { TFonsStyle                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TFontInfo.CreateEx(const AName :TString; const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer);
  begin
    CreateName(AName);
    FCharsets := TIntList.Create;
    FFontType := DetectType(AFontType, ATextMetric);

//  if ALogFont.elfLogFont.lfPitchAndFamily and FIXED_PITCH <> 0 then
//    FPitch := stMonospace
//  else
//    FPitch := stProportional;

    FPitch  := ALogFont.elfLogFont.lfPitchAndFamily;
    FWeight := ALogFont.elfLogFont.lfWeight;
    FItalic := ALogFont.elfLogFont.lfItalic <> 0;

    if FFontType = ftRaster then
      DetectSizes
    else
    if AFontType = TRUETYPE_FONTTYPE then
      ReadFontData(ALogFont);
    if FFullName = '' then
      FFullName := AName;
  end;


  destructor TFontInfo.Destroy; {override;}
  begin
    FreeObj(FSizes);
    FreeObj(FCharsets);
    inherited Destroy;
  end;


  procedure TFontInfo.SetFileName(const AFileName :TString);
  var
    vHandle :THandle;
    vData :TWIN32FindData;
  begin
    FFileName := AFileName;

    vHandle := FindFirstFile(PTChar(AFileName), vData);
    if vHandle = INVALID_HANDLE_VALUE then
      Exit;

    FSize := vData.nFileSizeLow;
    FTime := vData.ftLastWriteTime;

    Windows.FindClose(vHandle);
  end;


  function TFontInfo.GetCharsetsAsStr :TString;
  var
    I :Integer;
  begin
    Result := '';
    for I := 0 to FCharsets.Count - 1 do
      Result := AppendStrCh(Result, FontCharsetName(FCharsets[I]), ', ');
  end;


 {-----------------------------------------------------------------------------}

  function EnumSizesProc(const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer; AParam :Pointer): Integer; stdcall;
  var
    vSize :Integer;
  begin
    Result := 1;
    with ATextMetric.ntmTm do
      vSize := MulDiv(tmHeight - tmInternalLeading, 72, GPPI);
//  TraceF('%s, %d', [ALogFont.elfLogFont.lfFaceName, vSize]);
    with TFontInfo(AParam) do
      FSizes.AddSorted(Pointer(TIntPtr(vSize)), 0, dupIgnore);
  end;


  procedure TFontInfo.DetectSizes;
  var
    vLogFont :TLogFont;
  begin
    if FSizes = nil then
      FSizes := TIntList.Create;
    FillChar(vLogFont, SizeOf(vLogFont), 0);
    StrPLCopy(vLogFont.lfFaceName, FName, LF_FACESIZE);
    vLogFont.lfCharset := DEFAULT_CHARSET;
    EnumFontFamiliesEx(GDisplayDC, vLogFont, @EnumSizesProc, Integer(Self), 0);
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TFontInfo.ReadFontData(const ALogFont :TEnumLogFontEx);
  var
    vFont, vOldFont :HFont;
    vTableSize :Integer;
    vBuf :Pointer;
  begin
    vFont := CreateFontIndirect(ALogFont.elfLogFont);
    if vFont = 0 then
      Exit;

    try
      vOldFont := SelectObject(GDisplayDC, vFont);
      if vOldFont = 0 then
        Exit;

      try
        vTableSize := Integer(GetFontData(GDisplayDC, cNameTableTag, 0, nil, 0));
        if vTableSize <= 0 then
          Exit;

        vBuf := MemAllocZero(vTableSize);
        try
          vTableSize := Integer(GetFontData(GDisplayDC, cNameTableTag, 0, vBuf, vTableSize));
          if vTableSize <= 0 then
            Exit;

          ReadTTFNameTable(vBuf, vTableSize, FFamily, FSubFamily, FFullName, FCopyright);

        finally
          MemFree(vBuf);
        end;

      finally
        SelectObject(GDisplayDC, vOldFont);
      end;
    finally
      DeleteObject(vFont);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFontFamily                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TFontFamily.CreateEx(const AName :TString; const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer);
  begin
    CreateName(AName);
    FStyles := TObjList.Create;
    FFontType := DetectType(AFontType, ATextMetric);
    if ALogFont.elfLogFont.lfPitchAndFamily and FIXED_PITCH <> 0 then
      FPitchType := stMonospace
    else
      FPitchType := stProportional;
    FDescr := ALogFont.elfFullName + ', ' + ALogFont.elfStyle + ', ' + ALogFont.elfScript + ', ' + Int2Str(AFontType);
  end;


  destructor TFontFamily.Destroy; {override;}
  begin
    FreeObj(FStyles);
    inherited Destroy;
  end;


  function TFontFamily.GetTotalSize :Integer;
  var
    I :Integer;
  begin
    Result := 0;
    for I := 0 to FStyles.Count - 1 do
      Inc(Result, TFontInfo(FStyles[I]).Size);
  end;


  function TFontFamily.GetLastTime :TFileTime;
  var
    I :Integer;
  begin
    Int64(Result) := 0;
    for I := 0 to FStyles.Count - 1 do
      with TFontInfo(FStyles[I]) do
        if Int64(Time) > Int64(Result) then
          Result := Time;
  end;


 {-----------------------------------------------------------------------------}
 { TFontsList                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TFontsList.Create; {override;}
  begin
    inherited Create;
    ReRead;
  end;


  procedure TFontsList.ReRead;
  begin
    FreeAll;

    GDisplayDC := CreateDC('Display', nil, nil, nil);
    if GDisplayDC = 0 then
      Exit;
    try
      GPPI := GetDeviceCaps(GDisplayDC, LOGPIXELSY);

      BuildFontList;
      BuildStylesList;
      ReadRegInfo;
    finally
      DeleteDC(GDisplayDC);
    end;
  end;


  function EnumFontsProc(const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer; AParam :Pointer): Integer; stdcall;
  var
    vName :TString;
    vFont :TFontFamily;
    vIndex :Integer;
  begin
    Result := 1;
    vName := ALogFont.elfLogFont.lfFaceName;
    if (vName = '') or (vName[1] = '@') then
      Exit;

    with TFontsList(AParam) do begin
      if FindKey(Pointer(vName), 0, [foBinary], vIndex) then
//      vInfo := Items[vIndex]
      else begin
        vFont := TFontFamily.CreateEx(vName, ALogFont, ATextMetric, AFontType);
        Insert(vIndex, vFont);
      end;
    end;
//  vInfo.FCharsets.Add(ALogFont.elfLogFont.lfCharSet);
  end;


  procedure TFontsList.BuildFontList;
  var
    vDC :HDC;
    vLogFont :TLogFont;
  begin
    vDC := GetDC(0);
    try
      FillChar(vLogFont, SizeOf(vLogFont), 0);
      vLogFont.lfCharset := DEFAULT_CHARSET;
      EnumFontFamiliesEx(vDC, vLogFont, @EnumFontsProc, Integer(Self), 0);
    finally
      ReleaseDC(0, vDC);
    end;
  end;


  function EnumStylesProc(const ALogFont :TEnumLogFontEx; const ATextMetric :TNewTextMetricEx; AFontType :Integer; AParam :Pointer): Integer; stdcall;
  var
    vName :TString;
    vStyle :TFontInfo;
    vIndex :Integer;
  begin
    Result := 1;
//  TraceF('%s, %s, %s, %s', [ALogFont.elfLogFont.lfFaceName, ALogFont.elfFullName, ALogFont.elfStyle, ALogFont.elfScript]);
    vName := ALogFont.elfFullName;
    with TFontFamily(AParam).FStyles do begin
      if FindKey(Pointer(vName), 0, [foBinary], vIndex) then
        vStyle := Items[vIndex]
      else begin
        vStyle := TFontInfo.CreateEx(vName, ALogFont, ATextMetric, AFontType);
        Insert(vIndex, vStyle);
      end;
    end;
    vStyle.FCharsets.AddSorted(Pointer(TUnsPtr(ALogFont.elfLogFont.lfCharSet)), 0, dupIgnore);
  end;


  procedure TFontsList.BuildStylesList;
  var
    I :Integer;
    vDC :HDC;
    vLogFont :TLogFont;
    vFont :TFontFamily;
  begin
    vDC := GetDC(0);
    try
      for I := 0 to Count - 1 do begin
        vFont := Items[I];
        FillChar(vLogFont, SizeOf(vLogFont), 0);
        StrPLCopy(vLogFont.lfFaceName, vFont.Name, LF_FACESIZE);
        vLogFont.lfCharset := DEFAULT_CHARSET;
        EnumFontFamiliesEx(vDC, vLogFont, @EnumStylesProc, Integer(vFont), 0);
      end;
    finally
      ReleaseDC(0, vDC);
    end;
  end;


  procedure TFontsList.ReadRegInfo;
  var
    I, J, vIndex, vRes, vPos :Integer;
    vKey :HKEY;
    vType :DWORD;
    vNameBuf :array[0..255] of TChar;
    vDataBuf :array[0..511] of TChar;
    vNameLen, vDataLen :Cardinal;
    vRegName, vFontName, vFileName, vFontRoot :TString;
    vFont :TFontFamily;
    vStyle :TFontInfo;
    vIsFONFile :Boolean;
  begin
    vFontRoot := GetSpecialFolder(CSIDL_FONTS);

    if not RegOpenRead(HKLM, GetFontRegPath, vKey) then
      Exit;
    try

      vIndex := 0;
      while True do begin
        vNameLen := High(vNameBuf) + 1;
        vDataLen := SizeOf(vDataBuf);
        vRes := RegEnumValue(vKey, vIndex, vNameBuf, vNameLen, nil, @vType, Pointer(@vDataBuf), @vDataLen);
        if vRes <> 0 then
          Exit;

        if vType = REG_SZ then begin
          SetString(vRegName, vNameBuf, vNameLen);
          SetString(vFileName, vDataBuf, (vDataLen div SizeOf(TChar)) - 1 );

          vIsFONFile := StrEqual(ExtractFileExtension(vFileName), 'fon');

          vFontName := vRegName;
          if (vNameLen > 0) and (vFontName[vNameLen] = ')') then begin
            vPos := ChrsLastPos(['('], vFontName);  
            if vPos > 0 then
              vFontName := Trim(Copy(vFontName, 1, vPos - 1));
          end;

          for I := 0 to Count - 1 do begin
            vFont := Items[I];
            for J := 0 to vFont.FStyles.Count - 1 do begin
              vStyle := vFont.FStyles[J];
              if StrEqual(vStyle.FFullName, vFontName) then begin
                vFileName := CombineFileName(vFontRoot, vFileName);
                vStyle.SetFileName(vFileName);
                vStyle.FRegValue := vRegName;
              end else
              if vIsFONFile and (UpCompareSubStr(vStyle.FFullName, vFontName) = 0) then begin
                vFileName := CombineFileName(vFontRoot, vFileName);
                vStyle.SetFileName(vFileName);
                vStyle.FRegValue := vRegName;
              end;
            end;
          end;
        end;

        Inc(vIndex);
      end;

    finally
      RegCloseKey(vKey);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    GFontsList :TFontsList;
    GRefCount  :Integer;


  function GetFontsList :TFontsList;
  begin
    if GFontsList = nil then begin
      RegisterFontHints;
      GFontsList := TFontsList.Create;
    end;
    Inc(GRefCount);
    Result := GFontsList;
  end;


  procedure FreeFontsList;
  begin
    Dec(GRefCount);
    if GRefCount = 0 then begin
      FreeObj(GFontsList);
      UnregisterFontHints;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFontsPanel                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFontsPanel.CreateEx(ANumber :Integer);
  begin
    Create;
    FNumber := ANumber;

    FTitle := 'Fonts';
    FPath := '';
    FGroupMode := DefGroupMode;
    FGroupAll := DefGroupAll;
    FFilterByType := DefFilterByType;
    FFilterByPitch := DefFilterByPitch;
    FFilterByCharsets := DefFilterByCharsets;

    FIndex := TObjList.Create;
    FIndex.Options := [];
    FFonts := GetFontsList;
    Reindex;
  end;


  destructor TFontsPanel.Destroy; {override;}
  begin
    FreeObj(FIndex);
    FreeFontsList;
    inherited Destroy;
  end;


  function TFontsPanel.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := IntCompare(FNumber, Integer(TUnsPtr(Key)));
  end;


  procedure TFontsPanel.SetGroupMode(AMode :Integer);
  begin
    if AMode <> FGroupMode then begin
      FGroupMode := AMode;
      SetDirectory('\');
      Update;
    end;
  end;


  procedure TFontsPanel.SetGroupAll(AValue :Boolean);
  begin
    if AValue <> FGroupAll then begin
      FGroupAll := AValue;
      SetDirectory('\');
      Update;
    end;
  end;


  procedure TFontsPanel.SetFilterByType(AValue :TFontTypes);
  begin
    if AValue <> FFilterByType then begin
      FFilterByType := AValue;
      SetDirectory('\');
      Update;
    end;
  end;


  procedure TFontsPanel.SetFilterByPitch(AValue :TPitchTypes);
  begin
    if AValue <> FFilterByPitch then begin
      FFilterByPitch := AValue;
      SetDirectory('\');
      Update;
    end;
  end;


  procedure TFontsPanel.SetFilterByCharset(const AValue :TFontCharsets);
  begin
    if AValue <> FFilterByCharsets then begin
      FFilterByCharsets := AValue;
      SetDirectory('\');
      Update;
    end;
  end;


  procedure TFontsPanel.ReRead;
  begin
    FFonts.ReRead;
    Reindex;
    Update;
  end;


  procedure TFontsPanel.Update;
  begin
   {$ifdef bUnicode}
    FARAPI.Control(FNumber, FCTL_UPDATEPANEL, 0, nil);
    FARAPI.Control(FNumber, FCTL_REDRAWPANEL, 0, nil);
   {$else}
    FARAPI.Control(FNumber, FCTL_UPDATEPANEL, nil);
    FARAPI.Control(FNumber, FCTL_REDRAWPANEL, nil);
   {$endif bUnicode}
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TFontsPanel.Reindex;

    function StyleMatchCharset(AStyle :TFontInfo) :Boolean;
    var
      I :Integer;
    begin
      Result := True;
      if FFilterByCharsets <> [] then begin
        for I := 0 to AStyle.Charsets.Count - 1 do
          if AStyle.Charsets[I] in FFilterByCharsets then
            Exit;
        Result := False;
      end;
    end;

    function FontMatchFilter(AFont :TFontFamily) :Boolean;
    begin
      Result := True;
      if FFilterByType <> [] then
        Result := AFont.FFontType in FFilterByType;
      if FFilterByPitch <> [] then
        Result := AFont.FPitchType in FFilterByPitch;
    end;

    function FontMatchCharset(AFont :TFontFamily) :Boolean;
    var
      I :Integer;
    begin
      Result := True;
      if FFilterByCharsets <> [] then begin
        for I := 0 to AFont.Styles.Count - 1 do
          if StyleMatchCharset(AFont.Styles[I]) then
            Exit;
        Result := False;
      end;
    end;

  var
    I, J :Integer;
    vFont :TFontFamily;
    vStyle :TFontInfo;
  begin
    FIndex.Clear;
    if FGroupMode = 1 then begin
      { Линейный список... }
      if FPath = '' then begin
        for I := 0 to FFonts.Count - 1 do begin
          vFont := FFonts[I];
          if FontMatchFilter(vFont) then
            for J := 0 to vFont.FStyles.Count - 1 do begin
              vStyle := vFont.FStyles[J];
              if StyleMatchCharset(vStyle) then
                FIndex.AddSorted( vStyle, 0, dupIgnore );
            end;
        end;
      end;
    end else
    begin
      { Групировка по фамилиям... }
      if FPath = '' then begin

        for I := 0 to FFonts.Count - 1 do begin
          vFont := FFonts[I];
          if FontMatchFilter(vFont) and FontMatchCharset(vFont) then begin
            if FGroupAll or (vFont.FFontType in [ftTrueType, ftOpenType]) then
              FIndex.AddSorted( vFont, 0, dupIgnore )
            else
            if vFont.FStyles.Count > 0 then
              FIndex.AddSorted( vFont.FStyles[0], 0, dupIgnore )
          end;
        end;

      end else
      begin
        if FFonts.FindKey(Pointer(FPath), 0, [foBinary], I) then  begin
          vFont := FFonts[I];
          for J := 0 to vFont.FStyles.Count - 1 do
            FIndex.AddSorted( vFont.FStyles[J], 0, dupIgnore );
        end;
      end;
    end;
  end;


  function TFontsPanel.SetDirectory(const ADir :TString) :Boolean;
  var
    vIndex :Integer;
  begin
    if ADir = '\' then begin
      FPath := '';
      Result := True;
    end else
    begin
      Result := False;
      if FGroupMode = 2 then begin
        if (FPath <> '') and (ADir = '..') then begin
          FPath := '';
          Result := True;
        end else
        {!!!}
        if (FPath = '') and FFonts.FindKey(Pointer(ADir), 0, [foBinary], vIndex) then begin
          FPath := AppendStrCh(FPath, ADir, '\');
          Result := True;
        end;
      end;
    end;

    if Result then begin
      Reindex;
      FTitle := 'Fonts';
      if FPath <> '' then
        FTitle := FTitle + ':' + FPath;
    end;
  end;


  procedure TFontsPanel.GetItems(var AItems :PPluginPanelItem; var ACount :Integer);

    procedure LocAddFont(AItem :PPluginPanelItem; AFont :TFontFamily);
    begin
     {$ifdef bUnicode}
      AItem.FindData.cFileName := PTChar(AFont.Name);
//    AItem.FindData.nFileSize := AFont.GetTotalSize;
     {$else}
      StrPLCopy(AItem.FindData.cFileName, StrAnsiToOEM(AFont.Name), SizeOf(AItem.FindData.cFileName));
//    AItem.FindData.nFileSizeLow := AFont.GetTotalSize;
     {$endif bUnicode}
      AItem.FindData.ftLastWriteTime := AFont.GetLastTime;
      AItem.FindData.dwFileAttributes := {FILE_ATTRIBUTE_NORMAL or } FILE_ATTRIBUTE_DIRECTORY;
    end;

    procedure LocAddStyle(AItem :PPluginPanelItem; AStyle :TFontInfo);
    begin
     {$ifdef bUnicode}
      AItem.FindData.cFileName := PTChar(AStyle.Name);
      AItem.FindData.nFileSize := AStyle.Size;
     {$else}
      StrPLCopy(AItem.FindData.cFileName, StrAnsiToOEM(AStyle.Name), SizeOf(AItem.FindData.cFileName));
      AItem.FindData.nFileSizeLow := AStyle.Size;
     {$endif bUnicode}
      AItem.FindData.ftLastWriteTime := AStyle.Time;
      AItem.FindData.dwFileAttributes := 0 {FILE_ATTRIBUTE_ARCHIVE or  FILE_ATTRIBUTE_DIRECTORY};
    end;

  var
    I :Integer;
    vObj :TObject;
    vItem :PPluginPanelItem;
  begin
    ACount := FIndex.Count;

    AItems := MemAllocZero(ACount * SizeOf(TPluginPanelItem));

    vItem := AItems;
    for I := 0 to FIndex.Count - 1 do begin
      vObj := FIndex[I];
      if vObj is TFontFamily then
        LocAddFont(vItem, TFontFamily(vObj))
      else
        LocAddStyle(vItem, TFontInfo(vObj));
      Inc(TUnsPtr(vItem), SizeOf(TPluginPanelItem));
    end;
  end;


  procedure TFontsPanel.FreeItems(AItems :PPluginPanelItem; ACount :Integer);
  begin
    MemFree(AItems);
  end;


  function TFontsPanel.GetItem(const AName :TString) :TBasis;
  var
    vIndex :Integer;
  begin
    Result := nil;
    if FIndex.FindKey(Pointer(AName), 0, [foBinary], vIndex) then
      Result := FIndex[vIndex];
  end;


 {-----------------------------------------------------------------------------}

  procedure TFontsPanel.ShowProgress(const ATitle, AName :TString; APercent :Integer);
  const
    cWidth = 60;
  var
    vMess :TString;
  begin
    vMess := AName;
    if Length(vMess) > cWidth then
      vMess := Copy(vMess, 1, cWidth);
   {$ifdef bUnicode}
    vMess := ATitle + #10 + vMess;
   {$else}
    vMess := StrAnsiToOEM(ATitle + #10 + vMess);
   {$endif bUnicode}
    if APercent <> -1 then
      vMess := vMess + #10 + GetProgressStr(cWidth, APercent);
    FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PTChar(vMess)), 0, 0);
  end;


  function TFontsPanel.CheckInterrupt :Boolean;
  begin
    Result := False;
    if CheckForEsc then
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt) + #10#10 + GetMsgStr(strYes) + #10 + GetMsgStr(strNo), FMSG_WARNING, 2) = 0 then
        Result := True;
  end;


  function TFontsPanel.CopyFontsTo(AItems :PPluginPanelItem; ACount :Integer; const AFolder :TString; AMove, ASilence :Boolean) :Integer;
  var
    vMode :Integer; {0 - Prompt; 1 - Overwrite; 2 - Skip; 3 - Cancel}
    vChanged :Boolean;
    vPercent :Integer;


    function LocCopyStyleTo(AStyle :TFontInfo; const ADest :TString) :Boolean;
    var
      vDestFile :TString;
      vRes :Integer;
    begin
      Result := False;
      if CheckInterrupt then begin
        vMode := 3;
        Exit;
      end;

      ShowProgress(FarCtrl.GetMsgStr(IntIf(AMove, Byte(strMoving), Byte(strCopying))), AStyle.FFullName, vPercent);

      if AStyle.FFileName <> '' then begin
        vDestFile := AddFileName(ADest, ExtractFileName(AStyle.FFileName));
        if WinFileExists(vDestFile) then begin
          if vMode = 0 then begin
            vRes := ShowMessage(GetMsgStr(strWarning), GetMsgStr(strFileExists) + #10 + vDestFile + #10#10 +
              GetMsgStr(strOverwriteBut) + #10 + GetMsgStr(strAllBut) + #10 + GetMsgStr(strSkipBut) + #10 + GetMsgStr(strSkipAllBut) + #10 + GetMsgStr(strCancelBut),
              FMSG_WARNING, 5);
            case vRes of
              0: {Overwrite};
              1: vMode := 1; {OverwriteAll}
              2: Exit; {Skip}
              3: vMode := 2; {SkipAll}
            else
              vMode := 3
            end;
          end;
          if vMode in [2, 3] then
            Exit;
        end;

        if not Windows.CopyFile(PTChar(AStyle.FFileName), PTChar(vDestFile), False) then
          RaiseLastWin32Error;

        if AMove then begin
          LowUninstall(AStyle);
          vChanged := True;
        end;

        Result := True;
      end;
    end;


    function LocCopyFontTo(AFont :TFontFamily; const ADest :TString) :Boolean;
    var
      I :Integer;
      vDestFolder :TString;
    begin
      Result := False;
      vDestFolder := AddFileName(ADest, AFont.Name);
      if not WinFolderExists(vDestFolder) then
        if not CreateDir(vDestFolder) then
          RaiseLastWin32Error;
      for I := 0 to AFont.FStyles.Count - 1 do begin
        if LocCopyStyleTo(AFont.FStyles[I], vDestFolder) then
          Result := True;
        if vMode = 3 then
          Exit;
      end;
    end;

  var
    I, vPrompt :Integer;
    vItem :TObject;
    vDest, vName :TString;
    vSave :THandle;
  begin
    Result := -1;
    vDest := AddBackSlash(AFolder);

    if not ASilence then begin
      if AMove then
        vPrompt := IntIf(ACount = 1, Byte(strMovePrompt), Byte(strMovePromptN))
      else
        vPrompt := IntIf(ACount = 1, Byte(strCopyPrompt), Byte(strCopyPromptN));
      if not CopyDlg(AMove, FarCtrl.GetMsgStr(vPrompt), vDest) then
        Exit;
    end;

    vChanged := False;
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      vMode := 0;
      for I := 0 to ACount - 1 do begin
        vPercent := MulDiv(I, 100, ACount);
        vName := FarChar2Str(AItems.FindData.cFileName);
        vItem := GetItem(vName);
        if vItem <> nil then begin
          if vItem is TFontInfo then begin
            if LocCopyStyleTo(TFontInfo(vItem), vDest) then
              AItems.Flags := AItems.Flags and not PPIF_SELECTED;
          end else
          if vItem is TFontFamily then begin
            if LocCopyFontTo(TFontFamily(vItem), vDest) then
              AItems.Flags := AItems.Flags and not PPIF_SELECTED;
          end;
          if vMode = 3 then
            Exit;
        end;
        Inc(TUnsPtr(AItems), SizeOf(TPluginPanelItem));
      end;
      Result := 1;
    finally
      FARAPI.RestoreScreen(vSave);
      if vChanged then begin
        SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
        ReRead;
      end;
    end;
  end;


  function TFontsPanel.InstallFontsFrom(AItems :PPluginPanelItem; ACount :Integer; AMove :Boolean) :Integer;
  var
    vFontRoot, vRegPath :TString;
    vMode :Integer; {0 - Prompt; 1 - Overwrite; 2 - Skip; 3 - Cancel}
    vChanged :Boolean;
    vPercent :Integer;


    procedure LocAddFont(AFonts :TObjList; const AFileName :TString; const AFromFolder :TString);
    var
      vExt, vFamily, vSubFamily, vFullName :TString;
      vIndex :Integer;
    begin
      vExt := ExtractFileExtension(AFileName);
      if KnownExts.FindKey(Pointer(vExt), 0, [], vIndex) then begin
        if ReadTTFInfo(AFileName, vFamily, vSubFamily, vFullName) then begin
//        TraceF('Adding: %s: %s', [AFileName, vFullName]);
          AFonts.Add( TTTFFile.CreateEx(AFileName, vFamily, vSubFamily, vFullName, AFromFolder) );
        end;
      end;
    end;


    procedure LocAddFolder(AFonts :TObjList; var AFolder :TString);

      function LocEnumFile(const AFileName :TString; const ARec :TFarFindData) :Integer;
      begin
        if CheckInterrupt then begin
          vMode := 3;
          Result := 0;
          Exit;
        end;

        if ARec.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0 then
          ShowProgress(GetMsgStr(strScanning), AFileName, vPercent)
        else
          LocAddFont( AFonts, AFileName, AFolder );
        Result := 1;
      end;

    begin
      ShowProgress(GetMsgStr(strScanning), AFolder, vPercent);
      EnumFilesEx(AFolder, '*.*' {cFontExts}, LocalAddr(@LocEnumFile));
    end;


    procedure LocInstall(ATTFFile :TTTFFile);
    var
      vInstalled :Boolean;
      vName, vDestFile :TString;
      vRes :Integer;
    begin
      if CheckInterrupt then begin
        vMode := 3;
        Exit;
      end;

      vName := ExtractFileName(ATTFFile.Name);
      vDestFile := AddFileName(vFontRoot, vName);
      vInstalled := WinFileExists(vDestFile);
      if vInstalled then begin
        if vMode = 0 then begin
          vRes := ShowMessage(GetMsgStr(strWarning), GetMsgStr(strFontExists) + #10 + ATTFFile.VisName + #10#10 +
            GetMsgStr(strOverwriteBut) + #10 + GetMsgStr(strAllBut) + #10 + GetMsgStr(strSkipBut) + #10 + GetMsgStr(strSkipAllBut) + #10 + GetMsgStr(strCancelBut),
            FMSG_WARNING, 5);
          case vRes of
            0: {Overwrite};
            1: vMode := 1; {OverwriteAll}
            2: Exit; {Skip}
            3: vMode := 2; {SkipAll}
          else
            vMode := 3
          end;
        end;
        if vMode in [2, 3] then
          Exit;
      end;

//    TraceF('Src=%s, Dest=%s, API=%s', [AStyle.FFileName, vDestFile, StrIf(AreFileApisANSI, 'Ansi', 'OEM')]);

      if vInstalled then
        if not RemoveFontResource(PTChar(vDestFile)) then
          RaiseLastWin32Error; {???}
      if not Windows.CopyFile(PTChar(ATTFFile.Name), PTChar(vDestFile), False) then
        RaiseLastWin32Error;
      RegSetStrValue(HKLM, vRegPath, ATTFFile.FFullName + ' (TrueType)', vName);
      AddFontResource( PTChar(vDestFile) );
      vChanged := True;

      if AMove then begin
        { Delete source }
        if not Windows.DeleteFile(PTChar(ATTFFile.Name)) then
          RaiseLastWin32Error;
        if ATTFFile.FFromFolder <> '' then
          DeleteEmptyFolders(ExtractFilePath(ATTFFile.Name), AddBackSlash(ATTFFile.FFromFolder));
      end;
    end;

  var
    I :Integer;
    vName, vPrompt :TString;
    vSave :THandle;
    vFonts :TObjList;
    vTTFFile :TTTFFile;
  begin
    Result := -1;
    vFonts := TObjList.Create;
    try
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      try
//      ShowProgress(GetMsgStr(strScanning), '', 0);
        vMode := 0;
        for I := 0 to ACount - 1 do begin
          vPercent := MulDiv(I, 100, ACount);
          vName := FarChar2Str(AItems.FindData.cFileName);
          vName := FarExpandFileName(vName);

          if AItems.FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
            LocAddFont(vFonts, vName, '')
          else
            LocAddFolder(vFonts, vName);
          if vMode = 3 then
            Exit;
          Inc(TUnsPtr(AItems), SizeOf(TPluginPanelItem));
        end;
      finally
        FARAPI.RestoreScreen(vSave);
      end;

      if vFonts.Count = 0 then
        AppErrorID(strNoTrueTypeFonts);

      if vFonts.Count = 1 then
        vPrompt := GetMsgStr(strInstallPrompt) + #10 + TTTFFile(vFonts[0]).VisName
      else
        vPrompt := Format(GetMsgStr(strInstallPromptN), [vFonts.Count]);
      if ShowMessage(GetMsgStr(strInstall), vPrompt + #10#10 + GetMsgStr(strInstallBut) + #10 + GetMsgStr(strCancelBut), 0, 2) <> 0 then
        Exit;

      vChanged := False;
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      try
        vRegPath := GetFontRegPath;
        vFontRoot := GetSpecialFolder(CSIDL_FONTS);
        vMode := 0;
        for I := 0 to vFonts.Count - 1 do begin
          vTTFFile := vFonts[I];
          ShowProgress(GetMsgStr(strInstalling), vTTFFile.VisName, MulDiv(I, 100, ACount));
          LocInstall(vTTFFile);
          if vMode = 3 then
            Exit;
        end;
        Result := 1;

      finally
        FARAPI.RestoreScreen(vSave);
        if vChanged then begin
          SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
          ReRead;
        end;
      end;

    finally
      FreeObj(vFonts);
    end;
  end;


  function TFontsPanel.DeleteFonts(AItems :PPluginPanelItem; ACount :Integer; ASilence :Boolean) :Integer;
  var
    vMode :Integer;
    vChanged :Boolean;
    vPercent :Integer;

    function LocDelete(AStyle :TFontInfo) :Boolean;
    begin
      ShowProgress(GetMsgStr(strDeleting), AStyle.FFullName, vPercent);
      Result := False;
      if AStyle.FFileName <> '' then
        if WinFileExists(AStyle.FFileName) then begin
          LowUninstall(AStyle);
          vChanged := True;
          Result := True;
        end;
    end;


    procedure LocDeleteFont(AFont :TFontFamily);
    var
      I :Integer;
    begin
      for I := 0 to AFont.FStyles.Count - 1 do
        LocDelete(AFont.FStyles[I]);
    end;

  var
    I :Integer;
    vItem :TObject;
    vName, vPrompt :TString;
    vSave :THandle;
  begin
    Result := 0;
    
    if not ASilence then begin
      if ACount = 1 then
        vPrompt := GetMsgStr(strDeletePrompt) + #10 + FarChar2Str(AItems.FindData.cFileName)
      else
        vPrompt := Format(GetMsgStr(strDeletePromptN), [ACount]);    
      if ShowMessage(GetMsgStr(strDelete), vPrompt + #10#10 + GetMsgStr(strDeleteBut) + #10 + GetMsgStr(strCancelBut), 0, 2) <> 0 then
        Exit;
    end;

    vChanged := False;
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      vMode := 0;
      for I := 0 to ACount - 1 do begin
        vPercent := MulDiv(I, 100, ACount);
        vName := FarChar2Str(AItems.FindData.cFileName);
        vItem := GetItem(vName);
        if vItem <> nil then begin
          if vItem is TFontInfo then
            LocDelete(TFontInfo(vItem))
          else
          if vItem is TFontFamily then
            LocDeleteFont(TFontFamily(vItem));
          if vMode = 3 then
            Exit;
        end;
        Inc(TUnsPtr(AItems), SizeOf(TPluginPanelItem));
      end;

      Result := 1;

    finally
      FARAPI.RestoreScreen(vSave);
      if vChanged then begin
        SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
        ReRead;
      end;
    end;
  end;


  procedure TFontsPanel.LowUninstall(AStyle :TFontInfo);
  var
    vRegPath :TString;
  begin
    vRegPath := GetFontRegPath;
    if not RemoveFontResource(PTChar(AStyle.FFileName)) then
      RaiseLastWin32Error;
    if not DeleteFile(AStyle.FFileName) then
      RaiseLastWin32Error;
    if RegHasKey(HKLM, vRegPath) then
      RegDelete(HKLM, vRegPath, AStyle.FRegValue);
  end;


 {-----------------------------------------------------------------------------}


  function TFontsPanel.GetFontInfo(const AName, AResFileName :TString) :boolean;
  const
    cProps1 = 5;
  var
    vItem :TObject;
    vFile :Integer;
    I, vLen :Integer;
    vPrompts :Array[0..cProps1 - 1] of TString;
  begin
    Result := False;
    vItem := GetItem(AName);
    if vItem is TFontInfo then begin
      vPrompts[0] := GetMsgStr(strFont);
      vPrompts[1] := GetMsgStr(strFamily);
      vPrompts[2] := GetMsgStr(strStyle);
      vPrompts[3] := GetMsgStr(strType);
      vPrompts[4] := GetMsgStr(strPitch);
//    vPrompts[5] := GetMsgStr(strCharsets);

      vLen := 0;
      for I := 0 to cProps1 - 1 do
        vLen := IntMax(vLen, length(vPrompts[I]) + 1);

      vFile := FileCreate(AResFileName);
      if vFile < 0 then
        Exit;
      try
       {$ifdef bUnicode}
        FileWrite(vFile, BOM_UTF16_LE, 2);
       {$endif bUnicode}

        with TFontInfo(vItem) do begin
          StrToFile(vFile, StrLeftAjust(vPrompts[0], vLen) +  ': ' + Name);
          StrToFile(vFile, StrLeftAjust(vPrompts[1], vLen) +  ': ' + Family);
          StrToFile(vFile, StrLeftAjust(vPrompts[2], vLen) +  ': ' + SubFamily);
          StrToFile(vFile, StrLeftAjust(vPrompts[3], vLen) +  ': ' + FontTypeAsStr(FontType));
          StrToFile(vFile, StrLeftAjust(vPrompts[4], vLen) +  ': ' + StrIf(Pitch and FIXED_PITCH <> 0, 'Monospace', 'Proportional'));
//        StrToFile(vFile, StrLeftAjust(vPrompts[5], vLen) +  ': ' + GetCharsetsAsStr);

          StrToFile(vFile, '');
          StrToFile(vFile, GetMsgStr(strCharsets) + ':');
          StrToFile(vFile, '  ' + GetCharsetsAsStr);

          StrToFile(vFile, '');
          StrToFile(vFile, GetMsgStr(strFileName) + ':');
          StrToFile(vFile, '  ' + FFileName);

          if FCopyright <> '' then begin
            StrToFile(vFile, '');
            StrToFile(vFile, GetMsgStr(strCopyright) + ':');
            StrToFile(vFile, '  ' + FCopyright);
          end;
        end;

        Result := TRue;
      finally
        FileClose(vFile);
      end;

    end;
  end;


  function TFontsPanel.ClickItem(const AName :TString) :Integer;
  var
    vItem :TObject;
  begin
    Result := 0;
    vItem := GetItem(AName);
    if vItem is TFontInfo then begin
      with TFontInfo(vItem) do
        if FFileName <> '' then
          ShellOpen(0, FFileName, '');
      Result := 1;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    FLastNumber :Integer;
    FInstances :TObjList;


  function Instances :TObjList;
  begin
    if FInstances = nil then
      FInstances := TObjList.Create;
    Result := FInstances;
  end;


  function NewFontsPanel :TFontsPanel;
  begin
    Inc(FLastNumber);
    Result := TFontsPanel.CreateEx(FLastNumber);
    Instances.Add(Result);
  end;


  function FindFontsPanel(ANumber :Integer) :TFontsPanel;
  var
    vIndex :Integer;
  begin
    Result := nil;
    if Instances.FindKey(Pointer(TUnsPtr(ANumber)), 0, [], vIndex) then
      Result := FInstances[vIndex];
  end;


  procedure FreeFontsPanel(APanel :TFontsPanel);
  begin
    Instances.RemoveItem(APanel);
    APanel.Destroy;
  end;

initialization
finalization
  FreeObj(GCharsets);
  FreeObj(GKnownExts);
  FreeObj(FInstances);
end.


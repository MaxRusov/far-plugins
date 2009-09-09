{$I Defines.inc}

unit PanelTabsClasses;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

interface

  uses
    Windows,
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
    FarColor,

    FarCtrl,
    FarMatch,
    FarConMan,

    PanelTabsCtrl;

  const
    cMinTabWidth = 3;

   {$ifdef bUnicodeFar}
    cSide1 = #$2590;
    cSide2 = #$258C;
   {$else}
    cSide1 = #$DE;
    cSide2 = #$DD;
   {$endif bUnicodeFar}


  type
    THotSpot = (
      hsNone,
      hsTab,
      hsPanel,
      hsButtom
    );

    TTabKind = (
      tkLeft,
      tkRight,
      tkCommon
    );


    TPanelTab = class(TBasis)
    public
      constructor CreateEx(const ACaption, AFolder :TString);

      function GetTabCaption :TString;
      function IsFixed :Boolean;
      procedure Fix(AValue :Boolean);

    private
      FCaption  :TString;
      FFolder   :TString;
      FDelta    :Integer;
      FWidth    :Integer;
      FHotkey   :TChar;
      FHotPos   :Integer;

      FCurrent  :TString;    { Текущий Item на данном Tab'е }

    public
      property Caption :TString read FCaption write FCaption;
      property Folder :TString read FFolder write FFolder;
    end;


    TPanelTabs = class(TObjList)
    public
      constructor CreateEx(const AName :TString);

      function FindTab(const AName :TString; AFixedOnly, AByFolder :Boolean) :Integer;
      function FindTabByKey(AKey :TChar) :Integer;
      procedure UpdateHotkeys;
      procedure RealignTabs(ANewWidth :Integer);
      procedure StoreReg(const APath :TString);
      procedure RestoreReg(const APath :TString);
      procedure StoreFile(const AFileName :TString);
      procedure RestoreFile(const AFileName :TString);

    private
      FName     :TString;    { Имя набора = имя ветки реестра}
      FCurrent  :Integer;    { Текущий Tab (для нефиксированных табов) }
      FAllWidth :Integer;    { Ширина панели табов при последнем вызове RealignTabs }
    end;


    TTabsManager = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function HitTest(X, Y :Integer; var APanelKind :TTabKind; var AIndex :Integer) :THotSpot;

      function NeedCheck(var X, Y :Integer) :Boolean;
      function CanPaintTabs(ACheckCursor :Boolean = False) :Boolean;
      procedure PaintTabs(ACheckCursor :Boolean = False);
      procedure RefreshTabs;

      procedure MouseClick;
      procedure AddTab(Active :Boolean);
      procedure DeleteTab(Active :Boolean);
      procedure ListTab(Active :Boolean);
      procedure FixUnfixTab(Active :Boolean);
      procedure SelectTab(Active :Boolean; AIndex :Integer);
      procedure SelectTabByKey(Active :Boolean; AChar :TChar);

      procedure ToggleOption(var AOption :Boolean);
      procedure RunCommand(const ACmd :TString);

      procedure StoreTabs;
      procedure RestoreTabs;

    private
      FRects :array[TTabKind] of TRect;
      FTabs  :array[TTabKind] of TPanelTabs;

      function KindOfTab(Active :Boolean) :TTabKind;
      function GetTabs(Active :Boolean) :TPanelTabs;
      procedure RememberTabState(Active :Boolean; AKind :TTabKind);
      procedure RestoreTabState(Active :Boolean; ATab :TPanelTab);
      procedure DoSelectTab(Active :Boolean; AKind :TTabKind; AOnPassive :Boolean; AIndex :Integer);

      procedure AddTabEx(Active :Boolean; AKind :TTabKind; AFixed :Boolean);
      procedure DeleteTabEx(Active :Boolean; AKind :TTabKind);
      procedure FixUnfixTabEx(Active :Boolean; AKind :TTabKind);
      procedure ListTabEx(Active :Boolean; AKind :TTabKind);
    end;


  var
    TabsManager :TTabsManager;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    EditTabDlg,
    TabListDlg,
    MixDebug;


 {-----------------------------------------------------------------------------}

  var
    BOM_UTF16_LE  :array[1..2] of Byte = ($FF, $FE);

    CRLF :array[1..2] of TChar = (#13, #10);


  function ReadFileAsStr(const AFileName :TString) :TString;
  var
    vFile, vSize :Integer;
    vBOM :Word;
    vWStr :TWideStr;
    vAStr :TAnsiStr;
  begin
    Result := '';
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile < 0 then
      ApiCheck(False);
    try
      vSize := GetFileSize(vFile, nil);
      if (FileRead(vFile, vBOM, SizeOf(vBOM)) = SizeOf(vBOM)) and (vBOM = Word(BOM_UTF16_LE)) then begin
        Dec(vSize, SizeOf(vBOM));
        if vSize > 0 then begin
          SetString(vWStr, nil, (vSize + 1) div SizeOf(WideChar));
          FileRead(vFile, PWideChar(vWStr)^, vSize);
          Result := vWStr;
        end;
      end else
      if vSize > 0 then begin
        SetString(vAStr, nil, vSize);
        FileSeek(vFile, 0, 0);
        FileRead(vFile, PAnsiChar(vAStr)^, vSize);
        Result := vAStr;
      end;
    finally
      FileClose(vFile);
    end;
  end;


  procedure StrToFile(AFile :Integer; const AStr :TString);
  begin
    FileWrite(AFile, PTChar(AStr)^, length(AStr) * SizeOf(TChar));
    FileWrite(AFile, CRLF, 2 * SizeOf(TChar));
  end;


  function SafeMaskStr(const AStr :TString) :TSTring;
  begin
    if LastDelimiter(',"', AStr) <> 0 then
      Result := AnsiQuotedStr(AStr, '"')
    else
      Result := AStr;
  end;


  function ExtractNextLine(var AStr :PTChar) :TString;
  var
    vBeg :PTChar;
  begin
    while (AStr^ <> #0) and ((AStr^ = #13) or (AStr^ = #10)) do
      Inc(AStr);
    vBeg := AStr;
    while (AStr^ <> #0) and (AStr^ <> #13) and (AStr^ <> #10) do
      Inc(AStr);
    SetString(Result, vBeg, AStr - vBeg);
  end;


  function ExtractNextItem(var AStr :PTChar) :TString;
  begin
    if AStr^ = '"' then begin
      Result := AnsiExtractQuotedStr(AStr, '"');
      if AStr^ = ',' then
        Inc(AStr)
      else
        Result := Result + ExtractNextValue(AStr, [',']);
    end else
      Result := ExtractNextValue(AStr, [',']);
  end;



  procedure DrawTextChr(AChr :TChar; X, Y :Integer; AColor :Integer);
  var
    vBuf :array[0..1] of TChar;
  begin
    vBuf[0] := AChr;
    vBuf[1] := #0;
    FARAPI.Text(X, Y, AColor, @vBuf[0]);
  end;


  procedure DrawTextEx(const AStr :TString; X, Y :Integer; AMaxLen, ASelPos, ASelLen :Integer; AColor1, AColor2 :Integer);

    procedure LocDrawPart(var AChr :PTChar; ALen :Integer; var ARest :Integer; AColor :Integer);
    var
      vBuf :Array[0..255] of TChar;
    begin
      if (ARest > 0) and (ALen > 0) then begin
        if ALen > ARest then
          ALen := ARest;
        if ALen > High(vBuf) then
          ALen := High(vBuf);
        StrLCopy(@vBuf[0], AChr, ALen);
        FARAPI.Text(X, Y, AColor, @vBuf[0]);
        Dec(ARest, ALen);
        Inc(AChr, ALen);
        Inc(X, ALen);
      end;
    end;

  var
    vChr :PTChar;
  begin
    vChr := PTChar(AStr);
    if (ASelPos = 0) or (ASelLen = 0) then
      LocDrawPart(vChr, Length(AStr), AMaxLen, AColor1)
    else begin
      LocDrawPart(vChr, ASelPos - 1, AMaxLen, AColor1);
      LocDrawPart(vChr, ASelLen, AMaxLen, AColor2);
      LocDrawPart(vChr, Length(AStr) - ASelPos - ASelLen + 1, AMaxLen, AColor1);
    end;
  end;


  function FarXLat(AChr :TChar) :TChar;
  var
    vBuf :array[0..1] of TChar;
  begin
    vBuf[0] := AChr;
    vBuf[1] := #0;
   {$ifdef bUnicode}
    Result := FARSTD.XLat(@vBuf[0], 0, 1, 0)^;
   {$else}
    CharToOEMBuffA(vBuf, vBuf, 1);
    FARSTD.XLat(@vBuf[0], 0, 1, nil, 0);
    OEMToCharBuffA(vBuf, vBuf, 1);
    Result := vBuf[0];
   {$endif bUnicode}
  end;


 {-----------------------------------------------------------------------------}
 { TPanelTab                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TPanelTab.CreateEx(const ACaption, AFolder :TString);
  begin
    inherited Create;
    FCaption := ACaption;
    FFolder := AFolder;
  end;


  function TPanelTab.IsFixed :Boolean;
  begin
    Result := (FCaption <> '') and (FCaption <> '*');
  end;


  function TPanelTab.GetTabCaption :TString;
  begin
    if IsFixed then
      Result := optFixedMark + FCaption
    else begin
      Result := PathToCaption(FFolder);
      if optNotFixedMark <> '' then
        Result := optNotFixedMark + Result;
    end;
  end;


  procedure TPanelTab.Fix(AValue :Boolean);
  begin
    if AValue then 
      FCaption := PathToCaption(FFolder)
    else
      FCaption := '*';
  end;


 {-----------------------------------------------------------------------------}
 { TPanelTabs                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TPanelTabs.CreateEx(const AName :TString);
  begin
    Create;
    FName := AName;
    FCurrent := -1;
  end;


  function TPanelTabs.FindTab(const AName :TString; AFixedOnly, AByFolder :Boolean) :Integer;
  var
    I :Integer;
    vTab :TPanelTab;
    vStr :TString;
  begin
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      if AFixedOnly and not vTab.IsFixed then
        Continue;
      if not AByFolder then
        vStr := vTab.FCaption
      else
        vStr := RemoveBackSlash(vTab.FFolder);
      if StrEqual(AName, vStr) then begin
        Result := I;
        Exit;
      end;
    end;
    Result := -1;
  end;


  function TPanelTabs.FindTabByKey(AKey :TChar) :Integer;
  var
    I :Integer;
    vKey :TChar;
    vTab :TPanelTab;
  begin
    vKey := CharUpcase(AKey);
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      if vTab.FHotkey = vKey then begin
        Result := I;
        Exit;
      end;
    end;
    Result := -1;
  end;


  procedure TPanelTabs.UpdateHotkeys;
  var
    I, J :Integer;
    vTab :TPanelTab;
    vStr :TString;
    vChr :TChar;
  begin
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      vStr := vTab.GetTabCaption;
      vTab.FHotPos := ChrPos('&', vStr);
      if (vTab.FHotPos > 0) and (vTab.FHotPos < length(vStr)) then
        vTab.FHotkey := CharUpcase(vStr[vTab.FHotPos + 1])
      else
        vTab.FHotkey := #0;
    end;

    J := 0;
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      if vTab.FHotkey = #0 then begin
        repeat
          vChr := IndexToChar(J);
          Inc(J);
        until FindTabByKey(vChr) = -1;
        vTab.FHotkey := vChr;
      end;
    end;
  end;


  procedure TPanelTabs.RealignTabs(ANewWidth :Integer);

    function LocReduceTab :Boolean;
    var
      I, J, L :Integer;
    begin
      Result := False;
      J := -1; L := 0;
      for I := 0 to FCount - 1 do
        with TPanelTab(Items[I]) do
          if FWidth > L then begin
            L := FWidth;
            J := I;
          end;
      with TPanelTab(Items[J]) do begin
        if FWidth <= cMinTabWidth then
          Exit;
        Dec(FWidth);
      end;
      for I := J + 1 to FCount - 1 do
        with TPanelTab(Items[I]) do
          Dec(FDelta);
      Result := True;
    end;

  var
    I, X, L :Integer;
    vTab :TPanelTab;
  begin
    FAllWidth := ANewWidth;
    X := 1;
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];

      L := Length(vTab.GetTabCaption) + 1;
      if vTab.FHotPos > 0 then
        Dec(L)
      else
      if optShowNumbers then
        Inc(L);

      vTab.FDelta := X;
      vTab.FWidth := L;
      Inc(X, L);
    end;

    if optShowButton then
      { Вычитаем размер кнопочки }
      Dec(ANewWidth, 3);

    if X > ANewWidth then begin
      { Алгоритм тормозной, но пока - покатит }
      for I := 0 to X - ANewWidth - 1 do
        if not LocReduceTab then
          Break;
    end;
  end;


  procedure TPanelTabs.StoreReg(const APath :TString);

    procedure LocWriteTab(AKey :HKey; AIndex :Integer; ATab :TPanelTab);
    var
      vKey :HKEY;
    begin
      RegOpenWrite(AKey, Format(cTabRegFolder + '%d', [AIndex]), vKey);
      try
        RegWriteStr(vKey, cCaptionRegKey, ATab.FCaption);
        RegWriteStr(vKey, cFolderRegKey, ATab.FFolder);
      finally
        RegCloseKey(vKey);
      end;
    end;

    function LocDelete(AKey :HKey; AIndex :Integer) :Boolean;
    var
      vKey :HKEY;
      vStr :TString;
    begin
      Result := False;
      vStr := Format(cTabRegFolder + '%d', [AIndex]);
      if not RegOpenRead(AKey, vStr, vKey) then
        Exit;

      ApiCheckCode(RegDeleteKey(AKey, PTChar(vStr)));

      RegCloseKey(vKey);
    end;

  var
    I :Integer;
    vKey :HKEY;
    vPath :TString;
  begin
    vPath := APath;
    if vPath = '' then
      vPath := FRegRoot + '\' + cPlugRegFolder + '\' + cTabsRegFolder + '\' + FName;

    RegOpenWrite(HKCU, vPath, vKey);
    try
      for I := 0 to Count - 1 do
        LocWriteTab(vKey, I, Items[I]);

      {Удаляем лишние папки}
      I := Count;
      while True do begin
        if not LocDelete(vKey, I) then
          Break;
        Inc(I);
      end;

      RegWriteInt(vKey, cCurrentRegKey, FCurrent);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure TPanelTabs.RestoreReg(const APath :TString);

    function LocReadTab(AKey :HKey; AIndex :Integer) :Boolean;
    var
      vKey :HKEY;
      vCaption, vFolder :TString;
    begin
      Result := False;
      if not RegOpenRead(AKey, Format(cTabRegFolder + '%d', [AIndex]), vKey) then
        Exit;
      try
        vCaption := RegQueryStr(vKey, cCaptionRegKey, '');
        if vCaption <> '' then begin
          vFolder := RegQueryStr(vKey, cFolderRegKey, '');
          Add(TPanelTab.CreateEx(vCaption, vFolder));
        end;
        Result := True;
      finally
        RegCloseKey(vKey);
      end;
    end;

  var
    I :Integer;
    vKey :HKEY;
    vPath :TString;
  begin
    vPath := APath;
    if vPath = '' then
      vPath := FRegRoot + '\' + cPlugRegFolder + '\' + cTabsRegFolder + '\' + FName;

    if not RegOpenRead(HKCU, vPath, vKey) then
      Exit;
    try
      I := 0;
      while True do begin
        if not LocReadTab(vKey, I) then
          Break;
        Inc(I);
      end;

      FCurrent := RegQueryInt(vKey, cCurrentRegKey, FCurrent);

      UpdateHotkeys;
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure TPanelTabs.StoreFile(const AFileName :TString);
  var
    I :Integer;
    vFile :Integer;
    vTab :TPanelTab;
    vFileName, vStr :TString;
  begin
    vFileName := SafeChangeFileExtension(ExpandFileName(AFileName), cTabFileExt);
//  TraceF('TPanelTabs.StoreFile: %s', [vFileName]);

    vFile := FileCreate(vFileName);
    if vFile < 0 then
      ApiCheck(False);
    try
     {$ifdef bUnicode}
      FileWrite(vFile, BOM_UTF16_LE, 2);
     {$endif bUnicode}
      for I := 0 to Count - 1 do begin
        vTab := Items[I];
        vStr := SafeMaskStr(vTab.Caption) + ',' + SafeMaskStr(vTab.FFolder);
        StrToFile(vFile, vStr);
      end;

    finally
      FileClose(vFile);
    end;
  end;


  procedure TPanelTabs.RestoreFile(const AFileName :TString);
  var
    vFileName, vStr, vStr1, vCaption, vFolder :TString;
    vPtr, vPtr1 :PTChar;
  begin
    vFileName := SafeChangeFileExtension(ExpandFileName(AFileName), cTabFileExt);
//  TraceF('TPanelTabs.RestoreFile: %s', [vFileName]);

    vStr := ReadFileAsStr(vFileName);

    FreeAll;
    FAllWidth := -1;

    vPtr := PTChar(vStr);
    while vPtr^ <> #0 Do begin
      vStr1 := ExtractNextLine(vPtr);
      if vStr1 <> '' then begin
        vPtr1 := PTChar(vStr1);
        vCaption := ExtractNextItem(vPtr1);
        vFolder := ExtractNextItem(vPtr1);
        Add(TPanelTab.CreateEx(vCaption, vFolder));
      end;
    end;
    UpdateHotkeys;
  end;


 {-----------------------------------------------------------------------------}
 { TTabsManager                                                                }
 {-----------------------------------------------------------------------------}

  constructor TTabsManager.Create; {override;}
  begin
    inherited Create;

    FTabs[tkLeft] := TPanelTabs.CreateEx(cLeftRegFolder);
    FTabs[tkRight] := TPanelTabs.CreateEx(cRightRegFolder);
    FTabs[tkCommon] := TPanelTabs.CreateEx(cCommonRegFolder);

    RestoreTabs;
  end;


  destructor TTabsManager.Destroy; {override;}
  begin
    FreeObj(FTabs[tkLeft]);
    FreeObj(FTabs[tkRight]);
    FreeObj(FTabs[tkCommon]);
    inherited Destroy;
  end;


  procedure TTabsManager.StoreTabs;
  begin
    FTabs[tkLeft].StoreReg('');
    FTabs[tkRight].StoreReg('');
    FTabs[tkCommon].StoreReg('');
  end;


  procedure TTabsManager.RestoreTabs;
  begin
    FTabs[tkLeft].RestoreReg('');
    FTabs[tkRight].RestoreReg('');
    FTabs[tkCommon].RestoreReg('');
  end;


  procedure TTabsManager.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    WriteSetup;
    FTabs[tkLeft].FAllWidth := -1;
    FTabs[tkRight].FAllWidth := -1;
    FTabs[tkCommon].FAllWidth := -1;
    PaintTabs;
  end;


 {-----------------------------------------------------------------------------}

  function TTabsManager.HitTest(X, Y :Integer; var APanelKind :TTabKind; var AIndex :Integer) :THotSpot;

    function LocCheck(AKind :TTabKind) :THotSpot;
    var
      I :Integer;
      vTabs :TPanelTabs;
      vTab :TPanelTab;
      vRect, vRect1 :TRect;
    begin
      Result := hsNone;
      vRect := FRects[AKind];
      if RectContainsXY(vRect, X, Y) then begin
        APanelKind := AKind;

        vTabs := FTabs[AKind];
        for I := 0 to vTabs.Count - 1 do begin
          vTab := vTabs[I];
          vRect1 := Bounds(vRect.Left + vTab.FDelta, vRect.Top, vTab.FWidth, 1);
          if RectContainsXY(vRect1, X, Y) then begin
            Result := hsTab;
            AIndex := I;
            Exit;
          end;
        end;

        if optShowButton then begin
          vRect1 := Bounds(vRect.Right - 2, vRect.Top, 3, 1);
          if RectContainsXY(vRect1, X, Y) then begin
            Result := hsButtom;
            Exit;
          end;
        end;

        Result := hsPanel;
      end;
    end;

  begin
//  TraceF('HitTest: %d, %d', [X, Y]);
    Result := hsNone;
    if not CanPaintTabs then
      Exit;

    if optSeparateTabs then begin
      Result := LocCheck(tkLeft);
      if Result = hsNone then
        Result := LocCheck(tkRight);
    end else
      Result := LocCheck(tkCommon);
  end;


  function TTabsManager.NeedCheck(var X, Y :Integer) :Boolean;

    function LocNeedCheck(AKind :TTabKind) :Boolean;
    begin
      Result := False;
      with FRects[AKind] do
        if Right > Left then begin
          Y := Top;
          X := Right - 2;
          Result := True;
        end;
    end;

  begin
    if optSeparateTabs then begin
      Result := LocNeedCheck(tkLeft);
      if not Result then
        Result := LocNeedCheck(tkRight);
    end else
      Result := LocNeedCheck(tkCommon);
  end;


  function TTabsManager.CanPaintTabs(ACheckCursor :Boolean = False) :Boolean;
  var
    vWinInfo :TWindowInfo;
    vCursorInfo :TConsoleCursorInfo;
  begin
    Result := False;
    if not optShowTabs then
      Exit;
(*
   {$ifdef bUnicodeFar}
    if FARAPI.Control(hModule, FCTL_CHECKPANELSEXIST, 0, nil) = 0 then
   {$else}
    if FARAPI.Control(hModule, FCTL_CHECKPANELSEXIST, nil) = 0 then
   {$endif bUnicodeFar}
      { Нет панелей... }
      Exit;
*)

    FillChar(vWinInfo, SizeOf(vWinInfo), 0);
    vWinInfo.Pos := -1;
    FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);
//  TraceF('WindowType=%d', [vWinInfo.WindowType]);
    if vWinInfo.WindowType = WTYPE_PANELS then begin

      if ACheckCursor then begin
        GetConsoleCursorInfo(hStdOut, vCursorInfo);
//      TraceF('Cursor=%d', [Byte(vCursorInfo.bVisible)]);
        if not vCursorInfo.bVisible then
          { Нет курсора - значит активна не панель. Этой проверкой отсекаем ситуацию, }
          { когда активно меню и т.п., что не определяется с помощью ACTL_GETWINDOWINFO }
          Exit;
      end;
(*
      vStr := GetConsoleTitleStr;
//    TraceF('Title=%s', [vStr]);
      if (vStr = '') or (vStr[1] <> '{') then
        { Этой проверкой отсекаем ситуацию, когда из под Far'а запущена консольная программа }
        Exit;
*)
      Result := True;
    end;
  end;



  procedure TTabsManager.PaintTabs(ACheckCursor :Boolean = False);
  var
    vColor0, vColor1, vColor2, vColor3, vColor4, vColorSide1, vColorSide2 :Integer;
    vWinWidth :Integer;
    vCmdLineY :Integer;
    vFolders :array[TTabKind] of TString;


    procedure DetectPanelSettings;
    var
      vRes :Integer;
      vInfo :TConsoleScreenBufferInfo;
    begin
//    vRes := FARAPI.AdvControl(hModule, ACTL_GETPANELSETTINGS, nil);
      vRes := FARAPI.AdvControl(hModule, ACTL_GETINTERFACESETTINGS, nil);

      GetConsoleScreenBufferInfo(hStdOut, vInfo);
      vCmdLineY := vInfo.dwSize.Y - 1 - IntIf(FIS_SHOWKEYBAR and vRes <> 0, 1, 0);
      vWinWidth := vInfo.dwSize.X;
    end;


    procedure DetectPanelsLayout;

      function LocDetect(Active :Boolean) :Boolean;
      var
        vInfo  :TPanelInfo;
        vKind  :TTabKind;
      begin
        Result := False;
        FillChar(vInfo, SizeOf(vInfo), 0);
       {$ifdef bUnicodeFar}
        FARAPI.Control(THandle(IntIf(Active, PANEL_ACTIVE, PANEL_PASSIVE)), FCTL_GetPanelInfo, 0, @vInfo);
       {$else}
        FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_GetPanelShortInfo, FCTL_GetAnotherPanelShortInfo), @vInfo);
       {$endif bUnicodeFar}
        if (vInfo.Visible = 0) {or not vInfo.Focus} then
          Exit;
        if vInfo.PanelRect.Bottom + 1 >= vCmdLineY then
          { Нет места для табов }
          Exit;
        if PFLAGS_PANELLEFT and vInfo.Flags <> 0 then
          vKind := tkLeft
        else
          vKind := tkRight;
          
        if vInfo.Plugin = 0 then begin
         {$ifdef bUnicodefar}
          vFolders[vKind] := GetPanelDir(Active);
         {$else}
          vFolders[vKind] := FarChar2Str(vInfo.CurDir);
         {$endif bUnicodefar}
        end else
          vFolders[vKind] := '';
        if not optSeparateTabs and Active then
          vFolders[tkCommon] := vFolders[vKind];

        with vInfo.PanelRect do begin
          FRects[vKind] := Rect(Left, Bottom + 1, Right + 1, Bottom + 2);
          { Check fullscreen }
          Result := (Right - Left + 1) = vWinWidth;
        end;
      end;

    begin
      FillChar(FRects, SizeOf(FRects), 0);
      if not LocDetect(True) then
        LocDetect(False);

      if not optSeparateTabs then begin
        if not RectEmpty(FRects[tkLeft]) and not RectEmpty(FRects[tkRight]) then begin
          FRects[tkCommon] := FRects[tkLeft];
          FRects[tkCommon].Right := FRects[tkRight].Right;
        end else
        if not RectEmpty(FRects[tkLeft]) then
          FRects[tkCommon] := FRects[tkLeft]
        else
        if not RectEmpty(FRects[tkRight]) then
          FRects[tkCommon] := FRects[tkRight]
      end;
    end;


    procedure PaintTabsForPanel(AKind :TTabKind);
    var
      I, X, vWidth :Integer;
      vRect :TRect;
      vTabs :TPanelTabs;
      vTab :TPanelTab;
      vStr, vStr1 :TString;
      vHotColor :Integer;
      vCurrentIndex :Integer;
    begin
      vTabs := FTabs[AKind];
      vRect := FRects[AKind];
      if RectEmpty(vRect) then
        Exit;

      vCurrentIndex := -1;
      if vTabs.FCurrent <> -1 then begin
        if vTabs.FCurrent < vTabs.Count then begin
          vTab := vTabs[vTabs.FCurrent];
          if not vTab.IsFixed then begin
            { Таб, следящий за сменой позиции... }
            vCurrentIndex := vTabs.FCurrent;
            if not StrEqual(vTab.FFolder, vFolders[AKind]) then begin
              if vFolders[AKind] <> '' then begin
                vTab.FFolder := vFolders[AKind];
                vTabs.FAllWidth := -1;
              end else
                { Плагин. Пока не поддерживается. }
                vCurrentIndex := -1;
            end;
          end;
        end else
          vTabs.FCurrent := -1;
      end;

      vWidth := vRect.Right - vRect.Left + 1;
      if vTabs.FAllWidth <> vWidth then
        vTabs.RealignTabs(vWidth);

      vStr := StringOfChar(' ', vRect.Right - vRect.Left);
      FARAPI.Text(vRect.Left, vRect.Top, vColor0, PTChar(vStr));

      for I := 0 to vTabs.Count - 1 do begin
        vTab := vTabs[I];
       {$ifdef bUnicodefar}
        vStr := vTab.GetTabCaption;
       {$else}
        vStr := StrAnsiToOem(vTab.GetTabCaption);
       {$endif bUnicodefar}
        X := vRect.Left + vTab.FDelta;

        vStr1 := '';
        vWidth := vTab.FWidth - 1;
        if vTab.FHotPos > 0 then begin
          Delete(vStr, vTab.FHotPos, 1);
        end else
        if optShowNumbers then
          vStr1 := vTab.FHotkey;

        if (vCurrentIndex = -1) and vTab.IsFixed and StrEqual(vFolders[AKind], vTab.FFolder) then
          vCurrentIndex := I;

        if vCurrentIndex = I then begin
          DrawTextChr(cSide2, X-1, vRect.Top, vColorSide1);

          vHotColor := (vColor4 and $0F) or (vColor1 and $F0);
          if vStr1 <> '' then begin
            FARAPI.Text(X, vRect.Top, vHotColor, PTChar(vStr1));
            Dec(vWidth);
            Inc(X);
          end;
          DrawTextEx(vStr, X, vRect.Top, vWidth, vTab.FHotPos, 1, vColor1, vHotColor);
          Inc(X, vWidth);

          DrawTextChr(cSide1, X, vRect.Top, vColorSide1);
        end else
        begin
          vHotColor := (vColor4 and $0F) or (vColor2 and $F0);
          if vStr1 <> '' then begin
            FARAPI.Text(X, vRect.Top, vHotColor, PTChar(vStr1));
            Dec(vWidth);
            Inc(X);
          end;
          DrawTextEx(vStr, X, vRect.Top, vWidth, vTab.FHotPos, 1, vColor2, vHotColor);
        end;
      end;

      if optShowButton then begin
        DrawTextChr(cSide2, vRect.Right - 3, vRect.Top, vColorSide2);
        DrawTextChr('+', vRect.Right - 2, vRect.Top, vColor3);
        DrawTextChr(cSide1, vRect.Right - 1, vRect.Top, vColorSide2);
      end else
      begin
//      vTmp[0] := cSide1;
//      FARAPI.Text(vRect.Right - 1, vRect.Top, vColorSide2, @vTmp[0]);
      end
    end;

  begin
    if not CanPaintTabs(ACheckCursor) then
      Exit;

    vColor0 := GetOptColor(optBkColor, COL_COMMANDLINE);
    vColor1 := GetOptColor(optActiveTabColor, COL_PANELTEXT);
    vColor2 := GetOptColor(optPassiveTabColor, COL_COMMANDLINE);
    vColor3 := GetOptColor(optButtonColor, COL_PANELTEXT);
    vColor4 := GetOptColor(optNumberColor, COL_PANELCOLUMNTITLE);
    vColorSide1 := (vColor1 and $F0) or ((vColor0 and $F0) shr 4);
    vColorSide2 := (vColor3 and $F0) or ((vColor0 and $F0) shr 4);

    DetectPanelSettings;
    DetectPanelsLayout;

    if optSeparateTabs then begin
      PaintTabsForPanel(tkLeft);
      PaintTabsForPanel(tkRight);
    end else
      PaintTabsForPanel(tkCommon);
  end;


  procedure TTabsManager.RefreshTabs;
  var
    X, Y :Integer;
    vCh :TChar;
  begin
    if NeedCheck(X, Y) then begin
      vCh := ReadScreenChar(X, Y);
      if vCh <> '+' then begin
//      Trace('RefreshTabs: Need repaint...');
        PaintTabs(True);
      end;
    end;
  end;


  function TTabsManager.KindOfTab(Active :Boolean) :TTabKind;
  begin
    if optSeparateTabs then begin
      if Active = CurrentPanelIsRight then
        Result := tkRight
      else
        Result := tkLeft;
    end else
      Result := tkCommon;
  end;


  function TTabsManager.GetTabs(Active :Boolean) :TPanelTabs;
  begin
    Result := FTabs[KindOfTab(Active)];
  end;


 {-----------------------------------------------------------------------------}

  procedure TTabsManager.RememberTabState(Active :Boolean; AKind :TTabKind);
  var
    vTabs :TPanelTabs;
    vTab :TPanelTab;
  begin
    vTabs := FTabs[AKind];
    if (vTabs.FCurrent >= 0) and (vTabs.FCurrent < vTabs.FCount) then begin
      vTab := vTabs[vTabs.FCurrent];
      vTab.FCurrent := GetCurrentItem(Active);
    end;
  end;


  procedure TTabsManager.RestoreTabState(Active :Boolean; ATab :TPanelTab);
  begin
    if (ATab.FCurrent <> '') and (ATab.FCurrent <> '..') then begin
      SetCurrentItem(Active, ATab.FCurrent);
    end;
  end;


  procedure TTabsManager.DoSelectTab(Active :Boolean; AKind :TTabKind; AOnPassive :Boolean; AIndex :Integer);
  var
    vTabs :TPanelTabs;
    vTab :TPanelTab;
  begin
    vTabs := FTabs[AKind];
    if (AIndex >= 0) and (AIndex < vTabs.Count)then begin
      vTab := vTabs[AIndex];
      if not AOnPassive then begin
        RememberTabState(Active, AKind);
        JumpToPath(vTab.FFolder, Active);
        RestoreTabState(Active, vTab);
        vTabs.FCurrent := AIndex;
      end else
        JumpToPath(vTab.FFolder, not Active);
      PaintTabs;
    end else
      Beep;
  end;


 {-----------------------------------------------------------------------------}

  procedure TTabsManager.AddTab(Active :Boolean);
  begin
    AddTabEx(Active, KindOfTab(Active), False);
  end;

  procedure TTabsManager.AddTabEx(Active :Boolean; AKind :TTabKind; AFixed :Boolean);
  var
    vPath, vCaption :TString;
    vTabs :TPanelTabs;
  begin
    vPath := GetPanelDir(Active);
    vTabs := FTabs[AKind];
    if not AFixed or (vTabs.FindTab(vPath, True, True) = -1) then begin
      if AFixed then
        vCaption := PathToCaption(vPath)
      else
        vCaption := '*';
      vTabs.Add(TPanelTab.CreateEx(vCaption, vPath));
      vTabs.FCurrent := vTabs.Count - 1;
      vTabs.StoreReg('');
      vTabs.FAllWidth := -1;
      vTabs.UpdateHotkeys;
      PaintTabs;
    end else
      Beep;
  end;


  procedure TTabsManager.DeleteTab(Active :Boolean);
  begin
    DeleteTabEx(Active, KindOfTab(Active));
  end;

  procedure TTabsManager.DeleteTabEx(Active :Boolean; AKind :TTabKind);
  var
    vTabs :TPanelTabs;
  begin
    vTabs := FTabs[AKind];
    if vTabs.FCurrent <> -1 then begin
      vTabs.FreeAt(vTabs.FCurrent);
      vTabs.FCurrent := -1;
      vTabs.StoreReg('');
      vTabs.FAllWidth := -1;
      vTabs.UpdateHotkeys;
      PaintTabs;
    end else
      Beep;
  end;


  procedure TTabsManager.FixUnfixTab(Active :Boolean);
  begin
    FixUnfixTabEx(Active, KindOfTab(Active));
  end;

  procedure TTabsManager.FixUnfixTabEx(Active :Boolean; AKind :TTabKind);
  var
    vTabs :TPanelTabs;
    vTab :TPanelTab;
  begin
    vTabs := FTabs[AKind];
    if vTabs.FCurrent <> -1 then begin
      vTab := vTabs[vTabs.FCurrent];
      vTab.Fix(not vTab.IsFixed);
      vTabs.StoreReg('');
      vTabs.FAllWidth := -1;
      vTabs.UpdateHotkeys;
      PaintTabs;
    end else
      Beep;
  end;


  procedure TTabsManager.ListTab(Active :Boolean);
  begin
    ListTabEx(Active, KindOfTab(Active));
  end;

  procedure TTabsManager.ListTabEx(Active :Boolean; AKind :TTabKind);
  var
    vIndex :Integer;
    vTabs :TPanelTabs;
  begin
    vTabs := FTabs[AKind];
    vIndex := vTabs.FCurrent;
    if ListTabDlg(vTabs, vIndex) then
      DoSelectTab( Active, AKind, False, vIndex );
    vTabs.FAllWidth := -1;
    vTabs.UpdateHotkeys;
    PaintTabs;
  end;


  procedure TTabsManager.SelectTab(Active :Boolean; AIndex :Integer);
  begin
    DoSelectTab( Active, KindOfTab(Active), False, AIndex );
  end;


  procedure TTabsManager.SelectTabByKey(Active :Boolean; AChar :TChar);
  var
    vKind :TTabKind;
    vTabs :TPanelTabs;
    vIndex :Integer;
  begin
    vKind := KindOfTab(Active);

    vTabs := FTabs[vKind];
    vIndex := vTabs.FindTabByKey(AChar);
    if vIndex = -1 then begin
      AChar := FarXLat(AChar);
      vIndex := vTabs.FindTabByKey(AChar);
    end;

    DoSelectTab( Active, vKind, False, vIndex );
  end;


  procedure TTabsManager.MouseClick;

    procedure LocGotoTab(AKind :TTabKind; AIndex :Integer);
    var
      vActive, vOnPassive :Boolean;
    begin
      vActive := True;
      if optSeparateTabs then
        vActive := (AKind = tkRight) = CurrentPanelIsRight;

      vOnPassive := GetKeyState(VK_Shift) < 0;

      DoSelectTab( vActive, AKind, vOnPassive, AIndex );
    end;

    procedure LocAddTab(AKind :TTabKind);
    var
      vActive :Boolean;
      vFixed :Boolean;
    begin
      vActive := True;
      if optSeparateTabs then
        vActive := (AKind = tkRight) = CurrentPanelIsRight;
      vFixed := GetKeyState(VK_Shift) < 0;
      AddTabEx(vActive, AKind, vFixed);
    end;

    procedure LocEditTab(AKind :TTabKind; AIndex :Integer);
    var
      vTabs :TPanelTabs;
    begin
      vTabs := FTabs[AKind];
      if EditTab(vTabs, AIndex) then begin
        vTabs.StoreReg('');
        vTabs.FAllWidth := -1;
        vTabs.UpdateHotkeys;
        PaintTabs;
      end;
    end;

    procedure LocListTab(AKind :TTabKind);
    var
      vActive :Boolean;
    begin
      vActive := True;
      if optSeparateTabs then
        vActive := (AKind = tkRight) = CurrentPanelIsRight;
      ListTabEx(vActive, AKind);
    end;

  var
    vPoint :TPoint;
    vIndex :Integer;
    vKind :TTabKind;
    vHotSpot :THotSpot;
    vButton2 :Boolean;
  begin
    vButton2 := GetKeyState(VK_RBUTTON) < 0;
    while (GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0) do
      Sleep(10);

    { Чтобы выбрать событие отпускания мыши (?)... }
    if vButton2 then
      CheckForEsc;

    vPoint := GetConsoleMousePos;
    vHotSpot := HitTest(vPoint.X, vPoint.Y, vKind, vIndex);
    case vHotSpot of
      hsTab:
        if not vButton2 then
          LocGotoTab(vKind, vIndex)
        else
          LocEditTab(vKind, vIndex);
      hsButtom:
        if not vButton2 then
          LocAddTab(vKind)
        else
          LocListTab(vKind);
      hsPanel:
        {};
    end;
  end;


  const
    cAddCmd  = 'Add';
    cEditCmd = 'Edit';
    cSaveCmd = 'Save';
    cLoadCmd = 'Load';


  procedure TTabsManager.RunCommand(const ACmd :TString);
  var
    vPos :Integer;
    vCmd, vParam :TString;
  begin
    vCmd := ACmd;
    vPos := ChrPos('=', ACmd);
    if vPos <> 0 then begin
      vCmd := Copy(ACmd, 1, vPos - 1);
      vParam := Copy(ACmd, vPos + 1, MaxInt);
    end;

    if StrEqual(vCmd, cAddCmd) then
      AddTab(True)
    else
    if StrEqual(vCmd, cEditCmd) then
      ListTab(True)
    else
    if StrEqual(vCmd, cSaveCmd) then
      GetTabs(True).StoreFile(vParam)
    else
    if StrEqual(vCmd, cLoadCmd) then begin
      with GetTabs(True) do begin
        RestoreFile(vParam);
        StoreReg('');
        PaintTabs;
      end;
    end else
      AppErrorIdFmt(strUnknownCommand, [ACmd]);
  end;

 {-----------------------------------------------------------------------------}

initialization
finalization
  FreeObj(TabsManager);
end.



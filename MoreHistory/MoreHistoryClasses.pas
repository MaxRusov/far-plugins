{$I Defines.inc}

unit MoreHistoryClasses;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    ShlObj,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarMatch,
    FarConMan,
    MoreHistoryCtrl;


  type
    THistoryEntry = class(TBasis)
    public
      constructor CreateEx(const APath :TString);

      procedure HitInfoClear;

      function IsFinal :Boolean;
      procedure SetFinal(AOn :Boolean);
      procedure SetFlags(AFlags :Cardinal);
      function GetMode :Integer;
      function GetDomain :TString;
      function GetDateGroup :TString;
      function GetGroup :TString;

    public
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FPath  :TString;
      FTime  :TDateTime;
      FHits  :Integer;
      FFlags :Cardinal;

    public
      property Path :TString read FPath;
      property Time :TDateTime read FTime;
      property Hits :Integer read FHits;
      property Flags :Cardinal read FFlags;
    end;


    TFilterMask = class(TBasis)
    public
      constructor CreateEx(const AMask :TString; AExact :Boolean);
      destructor Destroy; override;
      function Check(const AStr :TString; var APos, ALen :Integer) :Boolean;

    private
      FSubMasks :TObjList;
      FMask     :TString;
      FExact    :Boolean;
      FRegExp   :Boolean;
      FNot      :Boolean;
    end;


    TFarHistory = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure LockHistory;
      procedure UnlockHistory;
      function TryLockHistory :Boolean;

      procedure AddCurrentToHistory;
      procedure AddHistory(const APath :TString; AFinal :Boolean);
      procedure SetModified;

      procedure JumpToPath(const APath :TString);
      procedure InsertStr(const APath :TString);
      procedure DeleteAt(AIndex :Integer);

      procedure StoreModifiedHistory;
      procedure LoadModifiedHistory;
      function StoreHistory :Boolean;
      function RestoreHistory :Boolean;

(*    procedure ReadExclusionList;  *)
      procedure InitExclusionList;

    private
      FCSLock     :TRTLCriticalSection;
      FHistory    :TObjList;
      FExclusions :TFilterMask;
      FModified   :Boolean;
      FLastTime   :Integer;
      FForceAdd   :Boolean;

      function IsKnownPluginPath(const APath :TString) :Boolean;
      function ConvertPluginPath(const APath :TString) :TString;
      function CheckExclusion(const APath :TString) :Boolean;
      function GetHistoryFolder :TString;
      function GetItems(AIndex :Integer) :THistoryEntry;

    public
      property History :TObjList read FHistory;
      property Items[I :Integer] :THistoryEntry read GetItems; default;
    end;


  function GetConsoleTitleStr :TString;
  function ClearTitle(const AStr :TString) :TString;

  procedure HandleError(AError :Exception);

  var
    GLastAdded :TString;  { Последняя добавленная папка, для опциональной фильтрации }

  var
    FarHistory :TFarHistory;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..1024] of TChar;
  begin
    FillChar(vBuf, SizeOf(vBuf), $00);
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;

    if ConManDetected then
      ConManClearTitle(Result);

//  TraceF('GetConsoleTitleStr: %s', [Result]);
  end;


  function ClearTitle(const AStr :TString) :TString;
  var
    vPos :Integer;
  begin
    Result := '';
    if (AStr <> '') and (AStr[1] = '{') then begin
      vPos := ChrsLastPos(['}'], AStr);
      if vPos <> 0 then
        Result := Copy(AStr, 2, vPos - 2);
    end;
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


  function NameByShortName(const AFolder, AFileName :TString) :TString;
(*
  var
    vRes :Integer;
    vRec :TsearchRec;
  begin
    vRes := FindFirst(AddFileName(AFolder, AFileName), faAnyFile, vRec);
    try
      if vRes = 0 then
        Result := vRec.Name
      else
        Result := AFileName;
    finally
      FindClose(vRec);
    end;
*)
  begin
    Result := '';
  end;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage(GetMsgStr(strError), AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;



  function NumMode(ANum :Integer) :Integer;
    {-Для сопряжения числительных }
  const
    cModes :array[0..9] of Integer = (3, 4, 2, 2, 2, 3, 3, 3, 3, 3);
  begin
    if ANum = 1 then
      Result := 1
    else begin
      ANum := ANum mod 100;
      if (ANum > 10) and (ANum < 20) then
        Result := 3
      else
        Result := cModes[ANum mod 10];
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFarHistory                                                                 }
 {-----------------------------------------------------------------------------}

  constructor THistoryEntry.CreateEx(const APath :TString);
  begin
    Create;
    FPath := APath;
    FTime := Now;
    FHits := 0;
  end;


  function THistoryEntry.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FPath, TString(Key));
  end;


  procedure THistoryEntry.HitInfoClear;
  begin
    FHits := 0;
  end;


  function THistoryEntry.IsFinal :Boolean;
  begin
    Result := FFlags and hfFinal <> 0;
  end;


  procedure THistoryEntry.SetFinal(AOn :Boolean);
  begin
    if AOn then
      FFlags := FFlags or hfFinal
    else
      FFlags := FFlags and not hfFinal;
  end;


  procedure THistoryEntry.SetFlags(AFlags :Cardinal);
  begin
    FFlags := AFlags;
  end;


  function THistoryEntry.GetMode :Integer;
  begin
    Result := 0;
    if IsFullFilePath(FPath) then
      Result := 1
    else
    if UpCompareSubStr('REG:', FPath) = 0 then
      Result := 2
    else
    if UpCompareSubStr('FTP:', FPath) = 0 then
      Result := 3
  end;


  function THistoryEntry.GetDomain :TString;
  begin
    if IsFullFilePath(FPath) then begin
      if UpCompareSubStr('\\', FPath) = 0 then
        Result := ExtractFileDrive(FPath)
      else begin
        Result := ExtractWords(1, 2, FPath, ['\']);
        if StrEqual(Result, FPath) then
          Result := ExtractFileDrive(FPath);
        Result := Result + '\';
      end;
    end else
//  if UpCompareSubStr('REG:', FPath) = 0 then
//    Result := ''
//  else
    if UpCompareSubStr('FTP:', FPath) = 0 then
      Result := ExtractWords(1, 2, FPath, ['/']) {+ '/'}
    else
    if UpCompareSubStr('PPC:', FPath) = 0 then
      Result := ExtractWords(1, 2, FPath, [':']) + ':'
    else
    if UpCompareSubStr('PDA:', FPath) = 0 then
      Result := ExtractWord(1, FPath, [':']) + ':\'
    else
      Result := ExtractWord(1, FPath, [':']) + ':';
  end;


  function THistoryEntry.GetDateGroup :TString;
  const
    cDays :array[1..4] of TMessages = (strDays1, strDays2, strDays5, strDays21);
  var
    vDate0, vDateI, vDays :Integer;
  begin
    vDate0 := Trunc(Date);
    vDateI := Trunc(FTime - EncodeTime(optMidnightHour, 0, 0, 0));

    vDays := vDate0 - vDateI;
    if vDays <= 0 then
      Result := GetMsgStr(strToday)
//  else
//  if vDays = 1 then
//    Result := GetMsgStr(strYesterday)
    else
      Result := Int2Str(vDays) + ' ' + Format(GetMsgStr(strDaysAgo), [GetMsgStr(cDays[NumMode(vDays)])]);
    Result := Result + ', ' + FormatDate('ddd, dd', Trunc(vDateI));
  end;


  function THistoryEntry.GetGroup :TString;
  begin
    case optHierarchyMode of
      hmDate:
        Result := GetDateGroup;
      hmDomain:
        Result := GetDomain;
//    hmDateDomain:
//      Result := GetDateGroup + ', ' + GetDomain;
//    hmDomainDate:
//      Result := GetDomain + ', ' + GetDateGroup;
    else
      Result := '';
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFilterMask                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFilterMask.CreateEx(const AMask :TString; AExact :Boolean);
  var
    vPos :Integer;
    vStr :TString;
  begin
    Create;
    FExact := AExact;
    vPos := ChrPos('|', AMask);
    if vPos = 0 then begin
      FMask := AMask;
      if (FMask <> '') and (FMask[1] = '!') then begin
        FNot := True;
        Delete(FMask, 1, 1);
      end;
      FRegExp := (ChrPos('*', FMask) <> 0) or (ChrPos('?', FMask) <> 0);
      if FRegExp and not AExact and (FMask[Length(FMask)] <> '*') {and (FMask[Length(FMask)] <> '?')} then
        FMask := FMask + '*';
    end else
    begin
      FSubMasks := TObjList.Create;
      vStr := AMask;
      repeat
        FSubMasks.Add( TFilterMask.CreateEx(Copy(vStr, 1, vPos - 1), AExact) );
        vStr := Copy(vStr, vPos + 1, MaxInt);
        vPos := ChrPos('|', vStr);
      until vPos = 0;
      if vStr <> '' then
        FSubMasks.Add( TFilterMask.CreateEx(vStr, AExact) );
    end;
  end;


  destructor TFilterMask.Destroy; {override;}
  begin
    FreeObj(FSubMasks);
    inherited Destroy;
  end;


  function TFilterMask.Check(const AStr :TString; var APos, ALen :Integer) :Boolean;
  var
    I :Integer;
  begin
    if FSubMasks = nil then begin
      if FExact then
        Result := StringMatch(FMask, PWideChar(AStr), APos, ALen)
      else
        Result := CheckMask(FMask, AStr, FREgExp, APos, ALen);
      if FNot then
        Result := not Result;
    end else
    begin
      Result := False;
      for I := 0 to FSubMasks.Count - 1 do
        if TFilterMask(FSubMasks[I]).Check(AStr, APos, ALen) then begin
          Result := True;
          Exit;
        end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFarHistory                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFarHistory.Create; {override;}
  begin
    inherited Create;
    InitializeCriticalSection(FCSLock);
    FHistory := TObjList.Create;
    FLastTime := -1;
    InitExclusionList;
  end;


  destructor TFarHistory.Destroy; {override;}
  begin
    FreeObj(FHistory);
    FreeObj(FExclusions);
    DeleteCriticalSection(FCSLock);
    inherited Destroy;
  end;


  procedure TFarHistory.LockHistory;
  begin
    EnterCriticalSection(FCSLock);
  end;


  procedure TFarHistory.UnlockHistory;
  begin
    LeaveCriticalSection(FCSLock);
  end;


  function TFarHistory.TryLockHistory :Boolean;
  begin
    Result := TryEnterCriticalSection(FCSLock)
  end;


 {-----------------------------------------------------------------------------}

  function TFarHistory.IsKnownPluginPath(const APath :TString) :Boolean;
  begin
    Result :=
      (UpCompareSubStr('NETWORK:', APath) = 0) or
      (UpCompareSubStr('REG:', APath) = 0) or
      (UpCompareSubStr('FTP:', APath) = 0) or
      (UpCompareSubStr('WMI:', APath) = 0) or
      (UpCompareSubStr('PDA:', APath) = 0) or
      (UpCompareSubStr('КПК:', APath) = 0) or
      (UpCompareSubStr('FILES:', APath) = 0) or
      (UpCompareSubStr('REGISTRY:', APath) = 0);
  end;


  function TFarHistory.ConvertPluginPath(const APath :TString) :TString;
  var
    vFolder :TString;
    vPos :Integer;
  begin
    if UpCompareSubStr('FTP:', APath) = 0 then begin
      Result := '';

      vFolder := Trim(ExtractWords(2, MaxInt, APath, [':']));
      if (vFolder = '') or (vFolder[1] = '\') then
        Exit;

      vPos := ChrPos('@', vFolder);
      if vPos <> 0 then
        vFolder := Copy(vFolder, vPos + 1, MaxInt);

      Result := 'FTP://' + vFolder;
      if Result[Length(Result)] <> '/' then
        Result := Result + '/';

    end else
    if UpCompareSubStr('NETWORK:', APath) = 0 then begin
      Result := '';

      vFolder := Trim(ExtractWords(2, MaxInt, APath, [':']));
      if (vFolder = '') or (vFolder[1] <> '\') then
        Exit;

      Result := 'NET:' + vFolder;

    end else
    if (UpCompareSubStr('PDA:', APath) = 0) or
      (UpCompareSubStr('КПК:', APath) = 0) then
    begin

      { Убираем размер свободного места, который может выводится в заголовке... }
      Result := 'PDA:' + ExtractWord(2, APath, [':']);

    end else
    if (UpCompareSubStr('FILES:', APath) = 0) or
      (UpCompareSubStr('REGISTRY:', APath) = 0) then
    begin
      Result := 'PPC:' + APath;
    end else
      Result := APath;
  end;


  procedure TFarHistory.InitExclusionList;
  begin
    if optExclusions <> '' then
      FExclusions := TFilterMask.CreateEx( optExclusions, True );
  end;


  function TFarHistory.CheckExclusion(const APath :TString) :Boolean;
  var
    vPos, vLen :Integer;
  begin
    Result := True;
    if FExclusions <> nil then
      Result := not FExclusions.Check(APath, vPos, vLen);
  end;


  procedure TFarHistory.AddCurrentToHistory;
  begin
    AddHistory( ClearTitle(GetConsoleTitleStr), True);
  end;


  procedure TFarHistory.AddHistory(const APath :TString; AFinal :Boolean);
  var
    vPath :TString;
    vIndex :Integer;
    vEntry :THistoryEntry;
  begin
    GLastAdded := '';
    if not IsFullFilePath(APath) and not IsKnownPluginPath(APath) then
      Exit;

    vPath := ConvertPluginPath(APath);
    if (vPath = '') or not CheckExclusion(vPath) then
      Exit;

    GLastAdded := vPath;

    LockHistory;
    try
//    TraceF('Add history: %s, %d', [APath, Byte(AFinal)]);
      AFinal := AFinal or FForceAdd;
      FForceAdd := False;

      if FHistory.FindKey(Pointer(vPath), 0, [], vIndex) then begin

        if not AFinal and optSkipTransit then
          { Транзитные папки не обновляются в истории...}
          Exit;

        vEntry := FHistory[vIndex];
        if (vIndex <> FHistory.Count - 1) or (AFinal and (vEntry.FFlags and hfFinal = 0)) then begin
          FHistory.Move(vIndex, FHistory.Count - 1);
          if AFinal then begin
            vEntry.FFlags := vEntry.FFlags or hfFinal;
            Inc(vEntry.FHits);
          end;
          vEntry.FTime := Now;
          FModified := True;
        end;

      end else
      begin
        vEntry := THistoryEntry.CreateEx(vPath);
        if AFinal then begin
          vEntry.FFlags := vEntry.FFlags or hfFinal;
          Inc(vEntry.FHits);
        end;
        FHistory.Add(vEntry);
        if FHistory.Count > optHistoryLimit then
          FHistory.DeleteRange(0, FHistory.Count - optHistoryLimit);
        FModified := True;
      end;

    finally
      UnlockHistory;
    end;
  end;


  procedure TFarHistory.DeleteAt(AIndex :Integer);
  begin
    LockHistory;
    try
//    TraceF('Add history: %s', [APath]);

      FHistory.Delete(AIndex);
      FModified := True;

    finally
      UnlockHistory;
    end;
  end;


  procedure TFarHistory.SetModified;
  begin
    FModified := True;
  end;


  function TFarHistory.GetItems(AIndex :Integer) :THistoryEntry;
  begin
    Result := FHistory[AIndex];
  end;


 {-----------------------------------------------------------------------------}

  procedure TFarHistory.JumpToPath(const APath :TString);
  var
    vStr :TFarStr;
    vMacro :TActlKeyMacro;
  begin
    if IsFullFilePath(APath) then begin
     {$ifdef bUnicodeFar}
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETPANELDIR, 0, PFarChar(APath));
     {$else}
      vStr := StrAnsiToOEM(APath);
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETPANELDIR, PFarChar(vStr));
     {$endif bUnicodeFar}

      AddCurrentToHistory;
    end else
    if True {IsKnownPluginPath(APath)} then begin
     {$ifdef bUnicodeFar}
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(APath));
     {$else}
      vStr := StrAnsiToOEM(APath);
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, PFarChar(vStr));
     {$endif bUnicodeFar}

      vStr := 'Enter';
      vMacro.Command := MCMD_POSTMACROSTRING;
      vMacro.Param.PlainText.SequenceText := PFarChar(vStr);
      vMacro.Param.PlainText.Flags := KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;
      FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);

//    AddCurrentToHistory;  { Макрос исполнится только по завершению процедуры }
      FForceAdd := True;
    end;
  end;


  procedure TFarHistory.InsertStr(const APath :TString);
 {$ifdef bUnicodeFar}
 {$else}
  var
    vStr :TFarStr;
 {$endif bUnicodeFar}
  begin
   {$ifdef bUnicodeFar}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_INSERTCMDLINE, 0, PFarChar(APath));
   {$else}
    vStr := StrAnsiToOEM(APath);
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_INSERTCMDLINE, PFarChar(vStr));
   {$endif bUnicodeFar}
  end;


 {-----------------------------------------------------------------------------}

  function TFarHistory.GetHistoryFolder :TString;
  begin
    Result := optHistoryFolder;
    if Result = '' then
      Result := AddFileName(GetSpecialFolder(CSIDL_APPDATA), cPluginFolder);
  end;


  procedure TFarHistory.StoreModifiedHistory;
  begin
    if FModified then begin
      if StoreHistory then
        FModified := False;
    end;
  end;


  procedure TFarHistory.LoadModifiedHistory;
  var
    vFileName :TString;
  begin
    vFileName := AddFileName(GetHistoryFolder, cHistFileName);
    if FileAge(vFileName) <> FLastTime then begin
      RestoreHistory;
    end;
  end;


  function TFarHistory.StoreHistory :Boolean;
  var
    I, vSize, vLen :Integer;
    vFolder, vFileName, vBackupFileName, vTmpFileName :TString;
    vMemory :Pointer;
    vPtr :PAnsiChar;
    vFile :Integer;
  begin
    Result := False;

    vFolder := GetHistoryFolder;
    vFileName := AddFileName(vFolder, cHistFileName);
    vTmpFileName := AddFileName(vFolder, cTempFileName);
    vBackupFileName  := AddFileName(vFolder, cBackupFileName);

   {$ifdef bTrace}
    TraceF('Store history: %s', [vFileName]);
   {$endif bTrace}

    vMemory := nil;
    try
      { Подготавливаем данные к сохранению }

      LockHistory;
      try
        vSize := SizeOf(cSignature) + SizeOf(cVersion) + SizeOf(Integer){Reserved} + SizeOf(Integer){Count};
        for I := 0 to FHistory.Count - 1 do
          with THistoryEntry(FHistory[I]) do
            Inc(vSize, SizeOf(Word) + Length(FPath) * SizeOf(TChar) + SizeOf(TDateTime) + SizeOf(Integer) + Sizeof(Integer));

        vMemory := MemAlloc(vSize);

        vPtr := vMemory;
        PInteger(vPtr)^ := Integer(cSignature);
        Inc(vPtr, SizeOf(Integer));
        PByte(vPtr)^ := cVersion;
        Inc(vPtr, SizeOf(Byte));
        PInteger(vPtr)^ := 0;
        Inc(vPtr, SizeOf(Integer));
        PInteger(vPtr)^ := FHistory.Count;
        Inc(vPtr, SizeOf(Integer));

        for I := 0 to FHistory.Count - 1 do
          with THistoryEntry(FHistory[I]) do begin
            vLen := Length(FPath);
            PWord(vPtr)^ := vLen;
            Inc(vPtr, SizeOf(Word));
            Move(PTChar(FPath)^, vPtr^, vLen * SizeOf(TChar));
            Inc(vPtr, vLen * SizeOf(TChar));
            Move(FTime, vPtr^, SizeOf(TDateTime));
            Inc(vPtr, SizeOf(TDateTime));
            PInteger(vPtr)^ := FHits;
            Inc(vPtr, SizeOf(Integer));
            PInteger(vPtr)^ := FFlags;
            Inc(vPtr, SizeOf(Integer));
          end;

        Assert(vPtr = PAnsiChar(vMemory) + vSize);

      finally
        UnlockHistory;
      end;

      { Сохраняем данные }

      if not WinFolderExists(vFolder) then
        if not CreateDir(vFolder) then
          Exit;

      vFile := FileCreate(vTmpFileName);
      if vFile < 0 then
        Exit;
      try
        try
          FileWrite(vFile, vMemory^, vSize);
        finally
          FileClose(vFile);
        end;

        if WinFileExists(vFileName) then begin
          { Бэкапим старый файл }
          if WinFileExists(vBackupFileName) then
            if not DeleteFile(vBackupFileName) then
              Exit;
          if not RenameFile(vFileName, vBackupFileName) then
            Exit;
        end;

        if RenameFile(vTmpFileName, vFileName) then begin
          FLastTime := FileAge(vFileName);
          Result := True;
        end;

      finally
        if not Result then
          DeleteFile(vTmpFileName);
      end;

    finally
      MemFree(vMemory)
    end;
  end;


  function TFarHistory.RestoreHistory :Boolean;
  var
    I, vSize, vCount, vLen :Integer;
    vFolder, vFileName :TString;
    vPtr :PAnsiChar;
    vFile :Integer;
    vMemory :Pointer;
    vEntry :THistoryEntry;
  begin
    Result := False;
    vFolder := GetHistoryFolder;
    vFileName := AddFileName(vFolder, cHistFileName);
    if not WinFolderExists(vFolder) or not WinFileExists(vFileName) then
      Exit;

   {$ifdef bTrace}
    TraceF('Restore history: %s', [vFileName]);
   {$endif bTrace}

    vMemory := nil;
    try
      vFile := FileOpen(vFileName, fmOpenRead or fmShareDenyWrite);
      if vFile < 0 then
        Exit;
      try
        FLastTime := FileAge(vFileName);
        vSize := GetFileSize(vFile, nil);
        vMemory := MemAlloc(vSize);
        if FileRead(vFile, vMemory^, vSize) <> vSize then
          Exit;
      finally
        FileClose(vFile);
      end;

      vPtr := vMemory;
      if PInteger(vPtr)^ <> Integer(cSignature) then
        Exit;
      Inc(vPtr, SizeOf(Integer));
      if PByte(vPtr)^ <> cVersion then
        Exit;
      Inc(vPtr, SizeOf(Byte));
      Inc(vPtr, SizeOf(Integer));
      vCount := PInteger(vPtr)^;
      Inc(vPtr, SizeOf(Integer));

      FHistory.Clear;
      FHistory.Capacity := vCount;
      for I := 0 to vCount - 1 do begin
        vEntry := THistoryEntry.Create;

        vLen := PWord(vPtr)^;
        Inc(vPtr, SizeOf(Word));

        SetString(vEntry.FPath, PTChar(vPtr), vLen);
        Inc(vPtr, vLen * SizeOf(TChar));

        Move(vPtr^, vEntry.FTime, SizeOf(TDateTime));
        Inc(vPtr, SizeOf(TDateTime));

        vEntry.FHits := PInteger(vPtr)^;
        Inc(vPtr, SizeOf(Integer));

        vEntry.FFlags := PInteger(vPtr)^;
        Inc(vPtr, SizeOf(Integer));

        FHistory.Add(vEntry);
      end;

    finally
      MemFree(vMemory)
    end;
  end;

  

initialization
finalization
  FreeObj(FarHistory);
end.

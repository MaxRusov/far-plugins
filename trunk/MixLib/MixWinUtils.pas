{$I Defines.inc}

unit MixWinUtils;

interface

  uses
    Windows,
    ShellAPI,
    MixTypes,
    MixUtils,
    MixStrings;


  function GetExeModuleFileName :TString;
  function GetModuleFileNameEx :TString;
  function StrGetTempPath :TString;
  function StrGetTempFileName(const APath, APrefix :TString) :TString;

  function GetLocalComputerName :TString;
  function GetLocalUserName :TString;

  function StrExpandEnvironment(const AStr :TString) :TString;

  const
    HKCR = HKEY_CLASSES_ROOT;
    HKCU = HKEY_CURRENT_USER;
    HKLM = HKEY_LOCAL_MACHINE;

  function RegOpenRead(ARoot :HKEY; const APath :TString; var AKey :HKey) :Boolean;
  procedure RegOpenWrite(ARoot :HKEY; const APath :TString; var AKey :HKey);

  function RegQueryStr(AKey :HKey; const AName, ADefault :TString) :TString;
  function RegQueryInt(AKey :HKey; const AName :TString; ADefault :TInt32) :TInt32;
  function RegQueryLog(AKey :HKey; const AName :TString; ADefault :Boolean) :Boolean;

  procedure RegWriteStr(AKey :HKey; const AName, AValue :TString);
  procedure RegWriteInt(AKey :HKey; const AName :TString; AValue :TInt32);
  procedure RegWriteLog(AKey :HKey; const AName :TString; AValue :Boolean);

  function RegGetStrValue(ARoot :HKEY; const APath, AName, ADefault :TString) :TString;
  function RegGetIntValue(ARoot :HKEY; const APath, AName :TString; ADefault :TInt32) :TInt32;

  procedure RegSetStrValue(ARoot :HKEY; const APath, AName, AValue :TString);
  procedure RegSetIntValue(ARoot :HKEY; const APath, AName :TString; AValue :TInt32);

  function RegHasKey(ARoot :HKEY; const APath :TString) :Boolean;

  function WinFileExists(const AFileName :TString) :Boolean;
  function WinFolderExists(const AFolderName :TString) :Boolean;
  function WinFolderNotEmpty(const aFolderName :TString) :Boolean;


 {-----------------------------------------------------------------------------}

  const
    faEnumFiles   = (faDirectory + faVolumeID) * $10000 + 0;
    faEnumFolders = (faDirectory + faVolumeID) * $10000 + (faDirectory);
    faEnumFilesAndFolders = (faVolumeID) * $10000 + 0;

    faSkipHidden  = (faHidden) * $10000 + 0;

  type
    { Тип процедуры перечисления элементов каталога. }
    TEnumFilesFunc = function(const aPath :TString; const aSRec :TWin32FindData) :Boolean
      {$ifndef bOldLocalCall}of object{$endif};

    { Параметры перечисления элементов каталога. }
    TEnumFileOptions = set of (
      efoRecursive,
      efoIncludeDir,
      efoFilesFirst
    );


  function WinEnumFiles(const aFolderName :TString; const aMasks :TString; aAttrs :DWORD; const aProc :TMethod) :Boolean;
  function WinEnumFilesEx(const aFolderName :TString; const aMasks :TString; aAttrs :DWORD; aOptions :TEnumFileOptions; const aProc :TMethod) :Boolean;

  function ShellOpen(const AName :TString; const AParam :TString = '') :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetExeModuleFileName :TString;
  var
    vBuf :array[0..Max_Path] of TChar;
  begin
    SetString(Result, vBuf, {Windows.}GetModuleFileName(0, vBuf, High(vBuf) + 1));
  end;


  function GetModuleFileNameEx :TString;
  var
    vBuf :array[0..Max_Path] of TChar;
  begin
    SetString(Result, vBuf, {Windows.}GetModuleFileName(hInstance, vBuf, High(vBuf) + 1));
  end;


  function StrGetTempPath :TString;
  var
    vBuf :array[0..Max_Path] of TChar;
  begin
    GetTempPath(Max_Path, vBuf);
    Result := vBuf;
  end;


  function StrGetTempFileName(const APath, APrefix :TString) :TString;
  var
    vBuf :array[0..Max_Path] of TChar;
  begin
    GetTempFilename(PTChar(APath), PTChar(APrefix), 0, vBuf);
    Result := vBuf;
  end;


  function GetLocalComputerName :TString;
  var
    vNameBuf  :array[0..MAX_COMPUTERNAME_LENGTH] of TChar;
    vNameLen  :TUns32;
  begin
    vNameLen := MAX_COMPUTERNAME_LENGTH + 1;
    Win32Check(GetComputerName(vNameBuf, vNameLen));
    SetString(Result, vNameBuf, vNameLen);
  end;


  function GetLocalUserName :TString;
  var
    vNameBuf  :array[0..255] of TChar;
    vNameLen  :TUns32;
  begin
    vNameLen := 255;
    Win32Check(GetUserName(vNameBuf, vNameLen));
    SetString(Result, vNameBuf, vNameLen - 1);
  end;


  function StrExpandEnvironment(const AStr :TString) :TString;
  var
    vLen :Integer;
    vTmp :TString;
  begin
    Result := '';
    vLen := ExpandEnvironmentStrings(PTChar(AStr), nil, 0);
    if vLen > 0 then begin
      SetLength(vTmp, vLen + 1);
      vLen := ExpandEnvironmentStrings(PTChar(AStr), PTChar(vTmp), vLen + 1);
      if vLen > 0 then
        SetString(Result, PTChar(vTmp), IntMin(vLen - 1, length(vTmp)));
    end;
  end;


 {-----------------------------------------------------------------------------}

  function RegOpenRead(ARoot :HKEY; const APath :TString; var AKey :HKey) :Boolean;
  begin
    Result := RegOpenKeyEx(ARoot, PTChar(APath), 0, KEY_QUERY_VALUE, AKey) = ERROR_SUCCESS;
  end;


  procedure RegOpenWrite(ARoot :HKEY; const APath :TString; var AKey :HKey);
  var
    vDisposition :TUns32;
  begin
    ApiCheckCode( RegCreateKeyEx(ARoot, PTChar(APath), 0, '', REG_OPTION_NON_VOLATILE, KEY_READ or KEY_WRITE, nil, AKey, @vDisposition) );
  end;


  function RegQueryStr(AKey :HKey; const AName, ADefault :TString) :TString;
  var
    vDataType, vLen :DWORD;
  begin
    vDataType := REG_SZ;
    if (RegQueryValueEx(AKey, PTChar(AName), nil, @vDataType, nil, @vLen) = ERROR_SUCCESS) and (vLen > 0) then begin
     {$ifdef bUnicode}
      SetString(Result, nil, ((vLen + 1) div 2) - 1);
     {$else}
      SetString(Result, nil, vLen - 1);
     {$endif bUnicode}
      RegQueryValueEx(AKey, PTChar(AName), nil, @vDataType, PByte(Result), @vLen);
    end else
      Result := ADefault;
  end;


  function RegQueryInt(AKey :HKey; const AName :TString; ADefault :TInt32) :TInt32;
  var
    vDataType, vLen :DWORD;
  begin
    vDataType := REG_DWORD;
    vLen := SizeOf(Integer);
    if RegQueryValueEx(AKey, PTChar(AName), nil, @vDataType, PByte(@Result), @vLen) <> ERROR_SUCCESS then
      Result := ADefault;
  end;


  function RegQueryLog(AKey :HKey; const AName :TString; ADefault :Boolean) :Boolean;
  begin
    Result := RegQueryInt(AKey, AName, Byte(ADefault)) <> 0;
  end;


  procedure RegWriteStr(AKey :HKey; const AName, AValue :TString);
  begin
    ApiCheckCode( RegSetValueEx(AKey, PTChar(AName), 0, REG_SZ, PTChar(AValue), (Length(AValue) + 1) * SizeOf(TChar)) );
  end;

  procedure RegWriteInt(AKey :HKey; const AName :TString; AValue :TInt32);
  begin
    ApiCheckCode( RegSetValueEx(AKey, PTChar(AName), 0, REG_DWORD, @AValue, SizeOf(AValue) ));
  end;

  procedure RegWriteLog(AKey :HKey; const AName :TString; AValue :Boolean);
  begin
    RegWriteInt(AKey, AName, Byte(AValue));
  end;


  function RegGetStrValue(ARoot :HKEY; const APath, AName, ADefault :TString) :TString;
  var
    vKey: HKEY;
  begin
    if RegOpenRead(ARoot, APath, vKey) then begin
      try
        Result := RegQueryStr(vKey, AName, ADefault);
      finally
        RegCloseKey(vKey);
      end;
    end else
      Result := ADefault;
  end;


  function RegGetIntValue(ARoot :HKEY; const APath, AName :TString; ADefault :TInt32) :TInt32;
  var
    vKey: HKEY;
  begin
    if RegOpenRead(ARoot, APath, vKey) then begin
      try
        Result := RegQueryInt(vKey, AName, ADefault);
      finally
        RegCloseKey(vKey);
      end;
    end else
      Result := ADefault;
  end;


  procedure RegSetStrValue(ARoot :HKEY; const APath, AName, AValue :TString);
  var
    vKey :HKey;
  begin
    RegOpenWrite(ARoot, APath, vKey);
    try
      RegWriteStr(vKey, AName, AValue);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure RegSetIntValue(ARoot :HKEY; const APath, AName :TString; AValue :TInt32);
  var
    vKey :HKey;
  begin
    RegOpenWrite(ARoot, APath, vKey);
    try
      RegWriteInt(vKey, AName, AValue);
    finally
      RegCloseKey(vKey);
    end;
  end;


  function RegHasKey(ARoot :HKEY; const APath :TString) :Boolean;
  var
    vKey :HKEY;
  begin
    Result := False;
    if RegOpenRead(ARoot, APath, vKey) then begin
      RegCloseKey(vKey);
      Result := True;
    end;
  end;


//function IniGetStrValue(const AFile, ASection, AName, ADefault :TString) :TString;
//begin
//  GetPrivateProfileString(ASection, AName, ADefault
//end;


 {-----------------------------------------------------------------------------}

  function WinFileExists(const AFileName :TString) :Boolean;
    { Вариант с FileGetAttr себя дискредитировал... }
  var
    vHandle :THandle;
    vFindData :TWin32FindData;
  begin
    Result := False;
    vHandle := FindFirstFile(PTChar(AFileName), vFindData);
    if vHandle <> INVALID_HANDLE_VALUE then begin
      Windows.FindClose(vHandle);
      Result := vFindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0;
    end;
  end;


  function WinFolderExists(const AFolderName :TString) :Boolean;
  var
    vCode :Integer;
  begin
    vCode := FileGetAttr(aFolderName);
    Result := (vCode <> -1) and (vCode and FILE_ATTRIBUTE_DIRECTORY <> 0);
  end;



  function WinFolderNotEmpty(const aFolderName :TString) :Boolean;
  var
    vMask :TString;
    vHandle :THandle;
    vFindData :TWin32FindData;
  begin
    Result := False;
    if WinFolderExists(aFolderName) then begin
      vMask := AddFileName(aFolderName, '*.*');
      vHandle := FindFirstFile(PTChar(vMask), vFindData);
      if vHandle <> INVALID_HANDLE_VALUE then begin
        try

          while True do begin

            if
              not ((vFindData.cFileName[0] = '.') and (vFindData.cFileName[1] = #0)) and
              not ((vFindData.cFileName[0] = '.') and (vFindData.cFileName[1] = '.') and (vFindData.cFileName[2] = #0))
            then begin
              Result := True;
              Break;
            end;

            if not FindNextFile(vHandle, vFindData) then
              Break;
          end;

        finally
          Windows.FindClose(vHandle);
        end;
      end;
    end;
  end;



 {-----------------------------------------------------------------------------}

  function CallFilesEnum(const AProc :TMethod; const APath :TString; const ARec :TWin32FindData) :Boolean;
 {$ifdef bOldLocalCall}
  var
    vTmp :Pointer;
  begin
    vTmp := aProc.Data;
    asm push vTmp; end;
    Result := TEnumFilesFunc(AProc.Code)(APath, ARec);
    asm pop ECX; end;
 {$else}
  begin
    Result := TEnumFilesFunc(AProc)(aPath, ARec)
 {$endif bOldLocalCall}
  end;


  function WinEnumFiles(const aFolderName :TString; const aMasks :TString; aAttrs :DWORD; const aProc :TMethod) :Boolean;
  var
    I :Integer;
    vHandle :THandle;
    vSRec :TWin32FindData;
    vFileMask :TString;
    vLook, vMask :Word;
  begin
    Result := True;
    vLook := LongRec(aAttrs).Hi;
    vMask := LongRec(aAttrs).Lo and vLook;
    for I := 1 to WordCount(aMasks, [';']) do begin
      vFileMask := AddFileName(aFolderName, ExtractWord(I, aMasks, [';']));
      vHandle := FindFirstFile(PTChar(vFileMask), vSRec);
      if vHandle <> INVALID_HANDLE_VALUE then begin
        try
          while True do begin

            if
              not ((vSRec.cFileName[0] = '.') and (vSRec.cFileName[1] = #0)) and
              not ((vSRec.cFileName[0] = '.') and (vSRec.cFileName[1] = '.') and (vSRec.cFileName[2] = #0)) and
              ((vSRec.dwFileAttributes and vLook) = vMask)
            then begin
              Result := CallFilesEnum(AProc, aFolderName, vSRec);
              if not Result then
                Break;
            end;

            if not FindNextFile(vHandle, vSRec) then
              Break;
          end;
        finally
          FindClose(vHandle);
        end;
      end;
    end;
  end;


  function WinEnumFilesEx(const aFolderName :TString; const aMasks :TString; aAttrs :DWORD; aOptions :TEnumFileOptions; const aProc :TMethod) :Boolean;

    function locEnumFolder(const APath :TString; const ARec :TWin32FindData) :Boolean;
    var
      vPath :TString;
    begin
      Result := False;
      if (efoIncludeDir in aOptions) and not (efoFilesFirst in AOptions) then
        if not CallFilesEnum(AProc, APath, ARec) then
          Exit;

      vPath := AddFileName(APath, ARec.cFileName);
      if not WinEnumFilesEx(vPath, aMasks, aAttrs, aOptions, aProc) then
        Exit;

      if (efoIncludeDir in aOptions) and (efoFilesFirst in AOptions) then
        if not CallFilesEnum(AProc, APath, ARec) then
          Exit;

      Result := True;
    end;

  const
    cDirMask = (faDirectory + faVolumeID) * $10000 + (faDirectory + faVolumeID);
  begin
    Result := False;
    if not (efoFilesFirst in aOptions) then
      if not WinEnumFiles(aFolderName, aMasks, aAttrs, aProc) then
        Exit;
    if efoRecursive in aOptions then
      if not WinEnumFiles(aFolderName, '*.*', (aAttrs and not cDirMask) or faEnumFolders, LocalAddr(@locEnumFolder)) then
        Exit;
    if efoFilesFirst in aOptions then
      if not WinEnumFiles(aFolderName, aMasks, aAttrs, aProc) then
        Exit;
    Result := True;
  end;


  function ShellOpen(const AName :TString; const AParam :TString = '') :Boolean;
  var
    vInfo :TShellExecuteInfo;
  begin
   {$ifdef bTrace}
    TraceF('%s %s', [AName, AParam]);
   {$endif bTrace}
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    vInfo.fMask  := 0;
    vInfo.Wnd    := 0;
    vInfo.lpFile := PTChar(AName);
    if AParam <> '' then
      vInfo.lpParameters := PTChar(AParam);
//  vInfo.lpDirectory := nil;
    vInfo.nShow := SW_Show;
    Result := ShellExecuteEx(@vInfo);
  end;


end.

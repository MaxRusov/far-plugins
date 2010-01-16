{$I Defines.inc}

{-$Define bUseCRC}

unit VisCompFiles;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixFormat,
    MixClasses,
    MixWinUtils,
   {$ifdef bUseCRC}
    MixCRC,
   {$endif bUseCRC}

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    FarCtrl,
    FarMatch,
    VisCompCtrl;


  const
    faPresent  = $1000;
    faError    = $2000;

    faComparedAttrs = faReadOnly or faHidden or faSysFile or faArchive;


  type
    TCompareContent = (
      ccNoCompare,
      ccSame,
      ccDiff
    );


    TCompareResume = (
      crSame,
      crDiff,
      crUncomp,
      crOrphan
    );

    TFolderResume = set of TCompareResume;


  type
    TCmpFileItem = class;

    TCmpFolder = class(TObjList)
    public
      ParentItem   :TCmpFileItem;

      Folder1      :TString;
      Folder2      :TString;

      SameCount    :Integer;
      DiffCount    :Integer;
      UncompCount  :Integer;
      OrphanCount  :array[0..1] of Integer;
    end;


    TCmpFileItem = class(TNamedObject)
    public
      ParentGroup :TCmpFolder;

      Subs    :TCmpFolder;
      Size    :Array[0..1] of Int64;
      Time    :Array[0..1] of Integer;
      Attr    :Array[0..1] of Word;

      Content :TCompareContent;

    public
      destructor Destroy; override;
      procedure SetInfo(AVer :Integer; const aSRec :TWin32FindData);

      function HasAttr(A :Word) :boolean;
      function BothAttr(A :Word) :boolean;
      function IsFolder :Boolean;
      function IsDifferent :Boolean;

      function GetResume :TCompareResume;
      function GetFolderResume :TFolderResume;
      function GetFullFileName(AVer :Integer) :TString;

      function UpdateInfo :Boolean;
      function CompareContents(const AProgressProc :TMethod) :Boolean;
    end;


  function CompareFolders(const ACmpFolder1, ACmpFolder2 :TString) :TCmpFolder;

  procedure CompareFilesContents(const ABaseFolder :TString; AList :TStringList);
  procedure CompareFolderContents(AFolder :TCmpFolder);

  procedure UpdateFolderDidgets(AList :TCmpFolder);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  const
    cTmpBufSize = 1 * 1024 * 1024;

  var
    vTmpBuf1 :Pointer;
    vTmpBuf2 :Pointer;


  type
    ECtrlBreak = class(TException);  


  procedure CtrlBreakException;
  begin
//  raise ECtrlBreak.Create('');
    raise ECtrlBreak.Create('');
  end;


  procedure CheckInterrupt;
  begin
    if CheckForEsc then
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt) + #10#10 + GetMsgStr(strYes) + #10 + GetMsgStr(strNo), FMSG_WARNING, 2) = 0 then
        CtrlBreakException
  end;


  function SafeCheck(var ALast :Cardinal) :Boolean;
  var
    vTick :Cardinal;
  begin
    Result := False;
    vTick := GetTickCount;
    if TickCountDiff(vTick, ALast) < 10 then
      Exit;
    ALast := vTick;
    CheckInterrupt;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  type
    TFilterMask = class(TBasis)
    public
(*    constructor CreateEx(const AMask :TString; AExact :Boolean); *)
      constructor CreateFileMask(const AMask :TString);
      destructor Destroy; override;
      function Check(const AStr :TString; var APos, ALen :Integer) :Boolean;

    private
      FSubMasks :TObjList;
      FMask     :TString;
      FExact    :Boolean;
      FRegExp   :Boolean;
      FNot      :Boolean;
    end;



(*
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
*)

  constructor TFilterMask.CreateFileMask(const AMask :TString);
  var
    vPos :Integer;
    vStr :TString;
  begin
    Create;
    FExact := True;
    FRegExp := True;

    vPos := ChrsPos([',', ';'], AMask);
    if vPos = 0 then
      FMask := AMask
    else begin
      FSubMasks := TObjList.Create;
      vStr := AMask;
      repeat
        FSubMasks.Add( TFilterMask.CreateFileMask(Copy(vStr, 1, vPos - 1)) );
        vStr := Copy(vStr, vPos + 1, MaxInt);
        vPos := ChrsPos([',', ';'], vStr);
      until vPos = 0;
      if vStr <> '' then
        FSubMasks.Add( TFilterMask.CreateFileMask(vStr) );
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
        Result := StringMatch(FMask, PTChar(AStr), APos, ALen)
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
 {                                                                             }
 {-----------------------------------------------------------------------------}

  destructor TCmpFileItem.Destroy; {override;}
  begin
    FreeObj(Subs);
    inherited Destroy;
  end;


  procedure TCmpFileItem.SetInfo(AVer :Integer; const aSRec :TWin32FindData);
  begin
    Size[AVer] := MakeInt64(aSRec.nFileSizeLow, aSRec.nFileSizeHigh);
    Time[AVer] := FileTimeToDosFileDate(aSRec.ftLastWriteTime);
    Attr[AVer] := aSRec.dwFileAttributes or faPresent;
  end;


  function TCmpFileItem.HasAttr(A :Word) :boolean;
  begin
    Result := (A and Attr[0] = A) or (A and Attr[1] = A);
  end;


  function TCmpFileItem.BothAttr(A :Word) :boolean;
  begin
    Result := (A and Attr[0] = A) and (A and Attr[1] = A);
  end;


  function TCmpFileItem.IsFolder :Boolean;
  begin
    Result := HasAttr(faDirectory);
  end;


  function TCmpFileItem.IsDifferent :Boolean;
  begin
    Result :=
      (optCompareTime and (Time[0] <> Time[1])) or
      (optCompareSize and (Size[0] <> Size[1])) or
      (optCompareAttr and (Attr[0] and faComparedAttrs <> Attr[1] and faComparedAttrs)) or
      (optCompareContents and not HasAttr(faDirectory) and (Content = ccDiff));
  end;


  function TCmpFileItem.GetResume :TCompareResume;
  begin
    if BothAttr(faPresent) then begin
      Result := crSame;

      if BothAttr(faDirectory) then begin
        if optCompareFolderAttrs and IsDifferent then
          Result := crDiff
      end else
      begin
        if IsDifferent then
          Result := crDiff
        else
        if optCompareContents and (Content = ccNoCompare) then
          Result := crUncomp;
      end;

    end else
      Result := crOrphan;
  end;


  function TCmpFileItem.GetFolderResume :TFolderResume;
  begin
    Result := [];
    if Subs <> nil then
      with Subs do begin
        if SameCount > 0 then
          Result := Result + [crSame];
        if DiffCount > 0 then
          Result := Result + [crDiff];
        if UncompCount > 0 then
          Result := Result + [crUncomp];
        if OrphanCount[0] > 0 then
          Result := Result + [crOrphan];
        if OrphanCount[1] > 0 then
          Result := Result + [crOrphan];
      end;
  end;

(*
  function TCmpFileItem.GetResume :TCompareResume;
  begin
    if BothAttr(faPresent) then begin
      Result := crSame;

      if BothAttr(faDirectory) then begin

        if Subs <> nil then
          with Subs do begin
            if (DiffCount[0] > 0) or (DiffCount[1] > 0) or (OrphanCount[0] > 0) or (OrphanCount[1] > 0) then
              if (SameCount[0] > 0) or (SameCount[1] > 0) then
                Result := crMixed {Contents}
              else
                Result := crDiff {Contents}
          end;

        if Result <> crMixed then
          if optCompareFolderAttrs and (GetCompFlags <> []) then
            Result := crDiff

      end else
      begin
        if GetCompFlags <> [] then
          Result := crDiff;
      end;

    end else
      Result := crOrphan;
  end;
*)

  function TCmpFileItem.GetFullFileName(AVer :Integer) :TString;
  begin
    if AVer = 0 then
      Result := ParentGroup.Folder1
    else
      Result := ParentGroup.Folder2;
    Result := AddFileName(Result, FName);
  end;


 {-----------------------------------------------------------------------------}

  function TCmpFileItem.UpdateInfo :Boolean;

    procedure LocUpdateInfo(const AFileName :TString; AVer :Integer);
    var
      vHandle :THandle;
      vSRec :TWin32FindData;
    begin
      vHandle := FindFirstFile(PTChar(AFileName), vSRec);
      if vHandle <> INVALID_HANDLE_VALUE then begin
        FindClose(vHandle);

        Size[AVer] := MakeInt64(vSRec.nFileSizeLow, vSRec.nFileSizeHigh);
        Time[AVer] := FileTimeToDosFileDate(vSRec.ftLastWriteTime);
        Attr[AVer] := vSRec.dwFileAttributes or faPresent;
      end else
      begin
        Size[AVer] := 0;
        Time[AVer] := 0;
        Attr[AVer] := 0;
      end;
    end;

  var
    vOldTime :array[0..1] of Integer;
    vOldSize :array[0..1] of Int64;
    vOldAttr :array[0..1] of Word;
  begin
    vOldTime[0] := Time[0]; vOldTime[1] := Time[1];
    vOldSize[0] := Size[0]; vOldSize[1] := Size[1];
    vOldAttr[0] := Attr[0]; vOldAttr[1] := Attr[1];

    if ParentGroup.Folder1 <> '' then
      LocUpdateInfo(GetFullFileName(0), 0);
    if ParentGroup.Folder2 <> '' then
      LocUpdateInfo(GetFullFileName(1), 1);

    Result :=
      ((vOldTime[0] <> Time[0]) or (vOldTime[1] <> Time[1])) or
      ((vOldSize[0] <> Size[0]) or (vOldSize[1] <> Size[1])) or
      ((vOldAttr[0] <> Attr[0]) or (vOldAttr[1] <> Attr[1]));

    if Result then
      Content := ccNoCompare;
  end;


  type
    TProgressProc = procedure(ASize :Int64)
      {$ifdef bFreePascal}of object{$endif bFreePascal};

  procedure CallCallback(const AProc :TMethod; ASize :Int64);
 {$ifdef bDelphi}
  var
    vTmp :Pointer;
  begin
    vTmp := AProc.Data;
    asm push vTmp; end;
    TProgressProc(aProc.Code)(ASize);
    asm pop ECX; end;
 {$else}
  begin
    TProgressProc(aProc)(ASize);
 {$endif bDelphi}
  end;


 {$ifdef bUseCRC}

  function TCmpFileItem.CompareContents(const AProgressProc :TMethod) :Boolean;

    function LocCalc(const AFileName :TString; var ACRC :TCRC) :Boolean;
    var
      vFile :Integer;
      vPart :Integer;
      vSize :Int64;
      vLast :Cardinal;
    begin
      Result := False;

//    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyNone);

      vFile := Integer(CreateFile(PTChar(AFileName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0));

      if vFile < 0 then
        Exit;
      try
        ACRC := CRC0;
        vLast := GetTickCount;
        vSize := Size[0];
        while vSize > 0 do begin
          SafeCheck(vLast);

          vPart := cTmpBufSize;
          if vPart > vSize then
            vPart := vSize;

          if FileRead(vFile, vTmpBuf1^, vPart) <> vPart then
            Exit;

          AddCRC(ACRC, vTmpBuf1^, vPart);

          Dec(vSize, vPart);
        end;
        Result := True;

      finally
        if vFile <> 0 then
          FileClose(vFile);
      end;
    end;

  var
    vFileName1, vFileName2 :TString;
    vCRC1, vCRC2 :TCRC;
  begin
    Result := False;
    if BothAttr(faPresent) and not HasAttr(faDirectory) and (Size[0] = Size[1]) then begin
      vFileName1 := GetFullFileName(0);
      vFileName2 := GetFullFileName(1);
//    TraceF('Compare: %s <-> %s', [ vFileName1, vFileName2 ]);

      if vTmpBuf1 = nil then
//      vTmpBuf1 := GlobalAllocMem(HeapAllocFlags, cTmpBufSize);
        vTmpBuf1 := VirtualAlloc(nil, cTmpBufSize, MEM_COMMIT, PAGE_READWRITE);

      if not LocCalc(vFileName1, vCRC1) then
        Exit;
      if not LocCalc(vFileName2, vCRC2) then
        Exit;

      Result := vCRC1 = vCRC2;
    end;
  end;

 {$else}

  function TCmpFileItem.CompareContents(const AProgressProc :TMethod) :Boolean;
  var
    vFileName1, vFileName2 :TString;
    vFile1, vFile2, vPart :Integer;
    vSize :Int64;
    vLast :Cardinal;
  begin
    Result := False;
    if BothAttr(faPresent) and not HasAttr(faDirectory) and (Size[0] = Size[1]) then begin
      vFileName1 := GetFullFileName(0);
      vFileName2 := GetFullFileName(1);
//    TraceF('Compare: %s <-> %s', [ vFileName1, vFileName2 ]);

      if vTmpBuf1 = nil then begin
        vTmpBuf1 := VirtualAlloc(nil, cTmpBufSize, MEM_COMMIT, PAGE_READWRITE);
        vTmpBuf2 := VirtualAlloc(nil, cTmpBufSize, MEM_COMMIT, PAGE_READWRITE);
      end;

      vFile1 := -1; vFile2 := -1;
      try
//      vFile1 := FileOpen(vFileName1, fmOpenRead or fmShareDenyWrite);
        vFile1 := Integer(CreateFile(PTChar(vFileName1), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
          FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0));
        if vFile1 < 0 then
          Exit;

//      vFile2 := FileOpen(vFileName2, fmOpenRead or fmShareDenyWrite);
        vFile2 := Integer(CreateFile(PTChar(vFileName2), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
          FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0));
        if vFile2 < 0 then
          Exit;

        vLast := GetTickCount;
        vSize := Size[0];
        while vSize > 0 do begin
          if SafeCheck(vLast) and (AProgressProc.Code <> nil) then
            CallCallback(AProgressProc, Size[0] - vSize);

          {!!!}
          vPart := cTmpBufSize;
          if vPart > vSize then
            vPart := vSize;

          if FileRead(vFile1, vTmpBuf1^, vPart) <> vPart then
            Exit;
          if FileRead(vFile2, vTmpBuf2^, vPart) <> vPart then
            Exit;

          if MemCompare(vTmpBuf1, vTmpBuf2, vPart) < vPart then begin
            NOP;
            Exit;
          end;

          Dec(vSize, vPart);
        end;
        Result := True;

      finally
        if vFile1 <> 0 then
          FileClose(vFile1);
        if vFile2 <> 0 then
          FileClose(vFile2);
      end;

    end;
  end;

 {$endif bUseCRC}



 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CompareFolders(const ACmpFolder1, ACmpFolder2 :TString) :TCmpFolder;
  var
    vSave :THandle;
    vStart, vLast :Cardinal;
    vFolders, vFiles :Integer;
    vScnWidth, vWidth :Integer;

    vInclMasks :TFilterMask;
    vExclMasks :TFilterMask;


    procedure InitProgress;
    var
      vScreenInfo :TConsoleScreenBufferInfo;
    begin
      if vSave = 0 then begin
        vSave := FARAPI.SaveScreen(0, 0, -1, -1);
        GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);
        vScnWidth := vScreenInfo.dwSize.X;
        vWidth := IntMin(IntMax(vScnWidth div 2, 50), vScnWidth-2);
      end;
    end;


    procedure UpdateMessage1(const AFolder :TString);
    var
      vMess, vFolder :TFarStr;
    begin
      if vSave = 0 then
        InitProgress;
     {$ifdef bUnicodeFar}
      vFolder := AFolder;
     {$else}
      vFolder := StrAnsiToOEM(AFolder);
     {$endif bUnicodeFar}
      {!!!Localize}
      vMess :=
        'Compare folders'#10 +
        Format('Files: %d   Folders: %d   Time: %d sec', [vFiles, vFolders, TickCountDiff(GetTickCount, vStart) div 1000]) + #10 +
        StrLeftAjust(vFolder, vWidth);
      FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PFarChar(vMess)), 0, 0);
      Assert(cTrue);
    end;


    procedure LocCompare(AList :TCmpFolder; const AFolder1, AFolder2 :TString);
    var
      vVer :Integer;

      procedure LocAddItem(const aPath :TString; const aSRec :TWin32FindData);
      var
        vName :TString;
        vIndex, vPos, vLen :Integer;
        vItem :TCmpFileItem;
        vNeedPoint :Boolean;
      begin
//      TraceF('File: %s %s', [aPath, aSRec.Name]);
        vName := aSRec.cFileName;
        if optNoScanHidden and (faHidden and aSRec.dwFileAttributes <> 0) then
          Exit;

        if faDirectory and ASRec.dwFileAttributes <> 0 then begin
          { Маска каталогов... }
        end else
        begin
          vNeedPoint := ChrPos('.', vName) = 0;
          if vNeedPoint then
            vName := vName + '.'; { Чтобы работали маски, типа "*."}

          if (vInclMasks <> nil) and not vInclMasks.Check(vName, vPos, vLen) then
            Exit;
          if (vExclMasks <> nil) and vExclMasks.Check(vName, vPos, vLen) then
            Exit;

          if vNeedPoint then
            Delete(vName, Length(vName), 1);
        end;

        if faDirectory and ASRec.dwFileAttributes <> 0 then
          vName := vName + '\'
        else
          Inc(vFiles);
        if AList.FindKey(Pointer(vName), 0, [foBinary], vIndex) then
          vItem := AList[vIndex]
        else begin
          vItem := TCmpFileItem.CreateName(vName);
          vItem.ParentGroup := AList;
          AList.Insert(vIndex, vItem);
        end;
        vItem.SetInfo(vVer, aSRec);
      end;

    var
      I :Integer;
      vItem :TCmpFileItem;
      vFolder1, vFolder2 :TString;
    begin
      AList.Folder1 := AFolder1;
      AList.Folder2 := AFolder2;

      vVer := 0;
      if AFolder1 <> '' then begin
        Inc(vFolders);
        if SafeCheck(vLast) then
          UpdateMessage1(AFolder1);
        try
          WinEnumFiles(AFolder1, '*.*', faEnumFilesAndFolders, LocalAddr(@LocAddItem));
        except
          {!!!}
        end;
      end;
      vVer := 1;
      if AFolder2 <> '' then begin
        Inc(vFolders);
        if SafeCheck(vLast) then
          UpdateMessage1(AFolder2);
        try
          WinEnumFiles(AFolder2, '*.*', faEnumFilesAndFolders, LocalAddr(@LocAddItem));
        except
          {!!!}
        end;
      end;

      if optScanRecursive then begin
        for I := 0 to AList.Count - 1 do begin
          vItem := AList[I];
          if vItem.IsFolder then begin
            if optNoScanOrphan and not vItem.BothAttr(faPresent) then
              { Пропускаем непарные каталоги }
              Continue;

            vItem.Subs := TCmpFolder.Create;
            vItem.Subs.ParentItem := vItem;

            vFolder1 := '';
            if faDirectory and vItem.Attr[0] <> 0 then
              vFolder1 := AddFileName(AFolder1, RemoveBackSlash(vItem.Name));
            vFolder2 := '';
            if faDirectory and vItem.Attr[1] <> 0 then
              vFolder2 := AddFileName(AFolder2, RemoveBackSlash(vItem.Name));

            LocCompare(vItem.Subs, vFolder1, vFolder2);
          end;
        end;
      end;
    end;


    procedure InitMasks;
    var
      vStr :TString;
    begin
      vStr := ExtractWord(1, optScanFileMask, ['|']);
      if vStr <> '' then
        vInclMasks := TFilterMask.CreateFileMask(vStr);

      vStr := ExtractWord(2, optScanFileMask, ['|']);
      if vStr <> '' then
        vExclMasks := TFilterMask.CreateFileMask(vStr);
    end;


  begin
    vSave := 0; vInclMasks := nil; vExclMasks := nil;

    InitMasks;
    try
      vFiles := 0;
      vFolders := 0;
      vStart := GetTickCount;

      Result := TCmpFolder.Create;
      try
        LocCompare(Result, ACmpFolder1, ACmpFolder2);

        if optScanContents then
          CompareFolderContents(Result);

      except
        on E :ECtrlBreak do
          {Nothing};
        else begin
          FreeObj(Result);
          raise;
        end;
      end;

    finally
      FreeObj(vInclMasks);
      FreeObj(vExclMasks);

      if vSave <> 0 then
        FARAPI.RestoreScreen(vSave);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function MulDiv64(A, B, C :Int64) :Int64;
  begin
    Result := 0;
    if C > 0 then
      Result := (A * B) div C;
  end;


  procedure CompareFilesContents(const ABaseFolder :TString; AList :TStringList);
  var
    vSave :THandle;
    vStart, vLast :Cardinal;
    vCompFiles, vTotalCompFiles :Integer;
    vCompSize, vTotalCompSize :Int64;
    vScnWidth, vWidth, vBaseLen :Integer;


    procedure InitProgress;
    var
      vScreenInfo :TConsoleScreenBufferInfo;
    begin
      if vSave = 0 then begin
        vSave := FARAPI.SaveScreen(0, 0, -1, -1);
        GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);
        vScnWidth := vScreenInfo.dwSize.X;
        vWidth := IntMin(IntMax(vScnWidth div 2, 50), vScnWidth-2);
      end;
    end;


    procedure UpdateMessage2({AList :TCmpFolder;} AItem :TCmpFileItem; AddSize :Int64);
    var
      vMess, vFileName :TFarStr;
    begin
      if vSave = 0 then
        InitProgress;

      if ABaseFolder = '' then
        vFileName := AItem.FName
      else
        vFileName := Copy(AItem.GetFullFileName(0), vBaseLen + 1, MaxInt);

     {$ifdef bUnicodeFar}
     {$else}
      vFileName := StrAnsiToOEM(vFileName);
     {$endif bUnicodeFar}
      {!!!Localize}
      vMess :=
        'Compare files'#10 +
        Format('Files: %s  Size: %s  Time: %d sec', [Int2StrEx(vCompFiles + 1), Int64ToStrEx(vCompSize + AddSize), TickCountDiff(GetTickCount, vStart) div 1000]) + #10 +
        StrLeftAjust(vFileName, vWidth) + #10 +
        GetProgressStr(vWidth, MulDiv64(vCompSize + AddSize, 100, vTotalCompSize));
//      GetProgressStr(vWidth, MulDiv(vCompFiles, 100, vTotalCompFiles));
      FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PFarChar(vMess)), 0, 0);
      Assert(cTrue);
    end;


    procedure CompareFile(AItem :TCmpFileItem);

      procedure UpdateProgress(ASize :Int64);
      begin
        UpdateMessage2(AItem, ASize);
      end;

    var
      I :Integer;
    begin
      if not AItem.BothAttr(faPresent) then
        Exit;

      if not AItem.HasAttr(faDirectory) then begin
        if AItem.Size[0] <> AItem.Size[1] then
          { Не совпадает размер - незачем сравнивать }
          AItem.Content := ccDiff
        else begin
          if SafeCheck(vLast) or (AItem.Size[0] > 1*1024*1024) then
            UpdateMessage2(AItem, 0);

          if AItem.CompareContents(LocalAddr(@UpdateProgress)) then
            AItem.Content := ccSame
          else
            AItem.Content := ccDiff;

          Inc(vCompFiles);
          Inc(vCompSize, AItem.Size[0]);
        end;

      end;
      if AItem.BothAttr(faDirectory) and (AItem.Subs <> nil) then
        for I := 0 to AItem.Subs.Count - 1 do
          CompareFile(AItem.Subs[I]);
    end;


    procedure CalcFile(AItem :TCmpFileItem; var ACount :Integer; var ASize :Int64);
    var
      I :Integer;
    begin
      if not AItem.BothAttr(faPresent) then
        Exit;
      if not AItem.HasAttr(faDirectory) and (AItem.Size[0] = AItem.Size[1]) then begin
        Inc(ACount);
        Inc(ASize, AItem.Size[0]);
      end;
      if AItem.BothAttr(faDirectory) and (AItem.Subs <> nil) then
        for I := 0 to AItem.Subs.Count - 1 do
          CalcFile(AItem.Subs[I], ACount, ASize);
    end;

  var
    I :Integer;
  begin
    vSave := 0;
    try
      vStart := GetTickCount;

      vBaseLen := Length(ABaseFolder);
      if (vBaseLen > 0) and (ABaseFolder[vBaseLen] <> '\') then
        Inc(vBaseLen);

      vTotalCompFiles := 0; vTotalCompSize := 0;
      for I := 0 to AList.Count - 1 do
        CalcFile(AList.Objects[I] as TCmpFileItem, vTotalCompFiles, vTotalCompSize);

      try
        vCompFiles := 0; vCompSize := 0;
        for I := 0 to AList.Count - 1 do
          CompareFile(AList.Objects[I] as TCmpFileItem);
      except
        on E :ECtrlBreak do
          {Nothing};
        else
          raise;
      end;

    finally
      if vSave <> 0 then
        FARAPI.RestoreScreen(vSave);
    end;
  end;


  procedure CompareFolderContents(AFolder :TCmpFolder);
  var
    I :Integer;
    vList :TStringList;
  begin
    vList := TStringList.Create;
    try
      for I := 0 to AFolder.Count - 1 do
        vList.AddObject('',  AFolder[I]);
      CompareFilesContents(AFolder.Folder1, vList);
    finally
      FreeObj(vList);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure UpdateFolderDidgets(AList :TCmpFolder);
  var
    I :Integer;
    vItem :TCmpFileItem;
  begin
    AList.SameCount := 0;
    AList.DiffCount := 0;
    AList.UncompCount := 0;
    AList.OrphanCount[0] := 0;
    AList.OrphanCount[1] := 0;

    for I := 0 to AList.Count - 1 do begin
      vItem := AList[I];

      if vItem.BothAttr(faPresent) then begin

        if vItem.BothAttr(faDirectory) then begin
          { С обоих сторон каталоги... }
          {...}
        end else
        begin
          { С обоих сторон файлы (смешанный вариант невозможен) }
          if vItem.IsDifferent then
            Inc(AList.DiffCount)
          else begin
            if optCompareContents and (vItem.Content = ccNoCompare) then
              Inc(AList.UncompCount)
            else
              Inc(AList.SameCount)
          end;
        end;

      end else
      begin
        if faPresent and vItem.Attr[0] <> 0 then
          Inc(AList.OrphanCount[0])
        else
          Inc(AList.OrphanCount[1]);
      end;

      if vItem.IsFolder and (vItem.Subs <> nil) then begin
        UpdateFolderDidgets(vItem.Subs);

        Inc(AList.SameCount, vItem.Subs.SameCount);
        Inc(AList.DiffCount, vItem.Subs.DiffCount);
        Inc(AList.UncompCount, vItem.Subs.UncompCount);
        Inc(AList.OrphanCount[0], vItem.Subs.OrphanCount[0]);
        Inc(AList.OrphanCount[1], vItem.Subs.OrphanCount[1]);
      end;
    end;
  end;



initialization

finalization
//GlobalFreeMem(vTmpBuf1);
//GlobalFreeMem(vTmpBuf2);
  if vTmpBuf1 <> nil then
    VirtualFree(vTmpBuf1, cTmpBufSize, MEM_DECOMMIT);
  if vTmpBuf2 <> nil then
    VirtualFree(vTmpBuf2, cTmpBufSize, MEM_DECOMMIT);
end.


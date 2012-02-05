{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}

{-$Define bUseCRC}

unit VisCompFiles;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixFormat,
    MixClasses,
    MixWinUtils,
    MixCRC,

    Far_API,
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
    TComparator = class;

    TCmpFolder = class(TObjList)
    public
      ParentItem   :TCmpFileItem;

      Folder1      :TString;
      Folder2      :TString;

      SameCount    :Integer;
      DiffCount    :Integer;
      UncompCount  :Integer;
      OrphanCount  :array[0..1] of Integer;

    public
      procedure CleanupDeletedItems;
      function GetFolder(AVer :Integer) :TString;
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
      procedure SetInfo(AVer :Integer; AAttr :Word; ASize :Int64; ATime :Integer);

      function HasAttr(A :Word) :boolean;
      function BothAttr(A :Word) :boolean;
      function IsFolder :Boolean;
      function IsDifferent :Boolean;

      function GetResume :TCompareResume;
      function GetFolderResume :TFolderResume;
      function GetFullFileName(AVer :Integer) :TString;
    end;


    TFilterMask = class(TBasis)
    public
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


    TDataProvider = class(TBasis)
    public
      constructor CreateEx(const AFolder :TString);
      procedure Enumerate(const AFolder :TString); virtual; abstract;
      function GetInfo(const AFolder, AFileName :TString; var Attr :Word; var ASize :Int64; var ATime :Integer) :boolean; virtual;

      function MakePath(const AFolder :TString) :TString; virtual;
      function GetRealFileName(const AFolder, AFileName :TString) :TString; virtual;
      function GetViewFileName(const AFolder, AFileName :TString) :TString; virtual;
      function GetPanelTitle(const AFolder :TString) :TString; virtual;

      function CanRecurse :Boolean; virtual;
      function CanGetFile :Boolean; virtual;

    private
      FFolder     :TString;
      FComparator :TComparator;
    end;

    TFileProvider = class(TDataProvider)
    public
      procedure Enumerate(const AFolder :TString); override;
    end;

    TSVNProvider = class(TDataProvider)
    public
      constructor CreateEx(const AFolder :TString);
      procedure Enumerate(const AFolder :TString); override;

      function GetRealFileName(const AFolder, AFileName :TString) :TString; override;
      function GetViewFileName(const AFolder, AFileName :TString) :TString; override;
    end;

    TPluginProvider = class(TDataProvider)
    public
      constructor CreateEx(const AFolder :TString; ASide :Integer);
      procedure Enumerate(const AFolder :TString); override;

      function CanRecurse :Boolean; override;
      function CanGetFile :Boolean; override;
      function GetPanelTitle(const AFolder :TString) :TString; override;

    private
      FSide     :Integer;
      FActive   :Boolean;
      FRealFile :Boolean;
      FTitle    :TString;
    end;


    TComparator = class(TBasis)
    public
      constructor CreateEx(ASource1, ASource2 :TDataProvider);
      destructor Destroy; override;

      procedure CompareFolders; virtual;
      procedure CompareFolderContents(AFolder :TCmpFolder);
      procedure CompareFilesContents(const ABaseFolder :TString; AList :TStringList);

      function CompareContents(const AFileName1, AFileName2 :TString) :Boolean;
      function CompareCRC(const AFileName1, AFileName2 :TString) :Boolean;

      function UpdateItemInfo(AItem :TCmpFileItem) :Boolean;

      function RealFileName(AItem :TCmpFileItem; AVer :Integer) :TString;
      function ViewFileName(AItem :TCmpFileItem; AVer :Integer) :TString; overload;
      function ViewFileName(const AFolder, AName :TString; AVer :Integer) :TString; overload;
      function PanelTitle(const AFolder :TString; AVer :Integer) :TString;

      function CanCompareContents :Boolean;
      function CanGetFile(ASide :Integer) :Boolean;

    private
      FSources   :array[0..1] of TDataProvider;

      FResults   :TCmpFolder;
      FInclMasks :TFilterMask;
      FExclMasks :TFilterMask;

      FSave      :THandle;
      FWidth     :Integer;

      FStart     :Cardinal;
      FLast      :Cardinal;

      FFolders   :Integer;
      FFiles     :Integer;
      FTotFiles  :Integer;
      FSize      :TInt64;
      FTotSize   :TInt64;

      FCurList   :TCmpFolder;
      FCurVer    :Integer;
      FCurFile   :TString;

      procedure InitMasks;
      procedure InitProgress;
      procedure DoneProgress;
      procedure ShowProgress(const AMess :TString; APerc :Integer);
      procedure UpdateProgress2(AddSize :Int64);
      procedure AddItem(const AName :TString; Attr :Word; ASize :Int64; ATime :Integer);

    public
      property Results :TCmpFolder read FResults;
    end;


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


  function MulDiv64(A, B, C :Int64) :Int64;
  begin
    Result := 0;
    if C > 0 then
      Result := (A * B) div C;
  end;


 {-----------------------------------------------------------------------------}
 { TFilterMask                                                                 }
 {-----------------------------------------------------------------------------}

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
        Result := StringMatch(FMask, '', PTChar(AStr), APos, ALen)
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

  procedure TCmpFolder.CleanupDeletedItems;
  var
    I :Integer;
    vItem :TCmpFileItem;
  begin
    for I := Count - 1 downto 0 do begin
      vItem := Items[I];
      if not vItem.HasAttr(faPresent) then
        Delete(I)
      else begin
        if vItem.IsFolder and (vItem.Subs <> nil) then
          vItem.Subs.CleanupDeletedItems;
      end;
    end;
  end;


  function TCmpFolder.GetFolder(AVer :Integer) :TString;
  begin
    if AVer = 0 then
      Result := Folder1
    else
      Result := Folder2;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  destructor TCmpFileItem.Destroy; {override;}
  begin
    FreeObj(Subs);
    inherited Destroy;
  end;


  procedure TCmpFileItem.SetInfo(AVer :Integer; AAttr :Word; ASize :Int64; ATime :Integer);
  begin
    Attr[AVer] := AAttr or faPresent;
    Size[AVer] := ASize;
    Time[AVer] := ATime;
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
    Result := AddFileName(ParentGroup.GetFolder(AVer), FName);
  end;


 {-----------------------------------------------------------------------------}
 { TDataProvider                                                               }
 {-----------------------------------------------------------------------------}

  constructor TDataProvider.CreateEx(const AFolder :TString);
  begin
    Create;
    FFolder := AFolder;
  end;


  function TDataProvider.CanRecurse :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function TDataProvider.CanGetFile :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function TDataProvider.MakePath(const AFolder :TString) :TString; {virtual;}
  begin
    Result := AddFileName(FFolder, AFolder)
  end;


  function TDataProvider.GetRealFileName(const AFolder, AFileName :TString) :TString; {virtual;}
  begin
    Result := AddFileName(AFolder, AFileName);
  end;


  function TDataProvider.GetViewFileName(const AFolder, AFileName :TString) :TString; {virtual;}
  begin
    Result := AddFileName(AFolder, AFileName);
  end;


  function TDataProvider.GetPanelTitle(const AFolder :TString) :TString; {virtual;}
  begin
    Result := GetViewFileName(AFolder, '');
  end;


  function TDataProvider.GetInfo(const AFolder, AFileName :TString; var Attr :Word; var ASize :Int64; var ATime :Integer) :boolean; {virtual;}
  var
    vFileName :TString;
    vHandle :THandle;
    vSRec :TWin32FindData;
  begin
    Result := False;
    vFileName := GetRealFileName(AFolder, AFileName);

    vHandle := FindFirstFile(PTChar(vFileName), vSRec);
    if vHandle <> INVALID_HANDLE_VALUE then begin
      FindClose(vHandle);

      ASize := MakeInt64(vSRec.nFileSizeLow, vSRec.nFileSizeHigh);
      ATime := FileTimeToDosFileDate(vSRec.ftLastWriteTime);
      Attr  := vSRec.dwFileAttributes;

      Result := True;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFileProvider.Enumerate(const AFolder :TString); {override;}

    function LocAddItem(const aPath :TString; const aSRec :TWin32FindData) :Boolean;
    begin
      with aSRec do
        FComparator.AddItem(cFileName, dwFileAttributes, MakeInt64(nFileSizeLow, nFileSizeHigh), FileTimeToDosFileDate(aSRec.ftLastWriteTime));
      Result := True;
    end;

  var
    vFolder :TString;
  begin
    vFolder := MakePath(AFolder);
    WinEnumFiles(vFolder, '*.*', faEnumFilesAndFolders, LocalAddr(@LocAddItem));
  end;

 {-----------------------------------------------------------------------------}

  constructor TSVNProvider.CreateEx(const AFolder :TString);
  var
    vPath :TString;
  begin
    Create;

    vPath := ExtractWords(2, MaxInt, AFolder, [':']);
    if vPath <> '' then
      vPath := FarExpandFileName(vPath)
    else
      vPath := FarGetCurrentDirectory;

    FFolder := vPath;
  end;


  function TSVNProvider.GetRealFileName(const AFolder, AFileName :TString) :TString; {override;}
  begin
    Result := AddFileName(AddFileName(AFolder, '.svn\text-base'), AFileName) + '.svn-base';
  end;


  function TSVNProvider.GetViewFileName(const AFolder, AFileName :TString) :TString; {virtual;}
  begin
    Result := 'SVN:' + AddFileName(AFolder, AFileName);
  end;


  procedure TSVNProvider.Enumerate(const AFolder :TString); {override;}

    function LocAddFolder(const aPath :TString; const aSRec :TWin32FindData) :Boolean;
    var
      vName, vPath :TString;
    begin
      Result := True;
      vName := aSRec.cFileName;
      if StrEqual(vName, '.svn') then
        Exit;

      vPath := AddFileName(AddFileName(APath, vName), '.svn');
      if not WinFolderExists(vPath) then
        Exit;

      with aSRec do
        FComparator.AddItem(vName, dwFileAttributes, 0, 0);
    end;

    function LocAddItem(const aPath :TString; const aSRec :TWin32FindData) :Boolean;
    begin
      with aSRec do
        FComparator.AddItem(ClearFileExt(cFileName), dwFileAttributes, MakeInt64(nFileSizeLow, nFileSizeHigh), FileTimeToDosFileDate(aSRec.ftLastWriteTime));
      Result := True;
    end;

  var
    vFolder :TString;
  begin
    vFolder := MakePath(AFolder);
    WinEnumFiles(vFolder, '*.*', faEnumFolders, LocalAddr(@LocAddFolder));

    vFolder := AddFileName(vFolder, '.svn\text-base');
    WinEnumFiles(vFolder, '*.*', faEnumFiles, LocalAddr(@LocAddItem));
  end;


 {-----------------------------------------------------------------------------}

  constructor TPluginProvider.CreateEx(const AFolder :TString; ASide :Integer); {override;}
  begin
    Create;
    FSide := ASide;
    FActive := FarPanelGetSide = FSide;
    FTitle := FarPanelGetCurrentDirectory(HandleIf(FActive, PANEL_ACTIVE, PANEL_PASSIVE));
  end;


  function TPluginProvider.CanRecurse :Boolean; {override;}
  begin
    Result := False;
  end;


  function TPluginProvider.CanGetFile :Boolean; {override;}
  begin
    Result := FRealFile;
  end;


  function TPluginProvider.GetPanelTitle(const AFolder :TString) :TString; {override;}
  begin
    Result := cPlugFakeDrive + FTitle;
  end;


  procedure TPluginProvider.Enumerate(const AFolder :TString); {override;}
  var
    I :Integer;
    vInfo :TPanelInfo;
    vHandle :THandle;
    vItem :PPluginPanelItem;
    vName :TString;
  begin
    vHandle := HandleIf( FActive, PANEL_ACTIVE, PANEL_PASSIVE );
    FarGetPanelInfo(vHandle, vInfo);

    FRealFile := PFLAGS_REALNAMES and vInfo.Flags <> 0;

    for I := 0 to vInfo.ItemsNumber - 1 do begin
      vItem := FarPanelItem(vHandle, FCTL_GETPANELITEM, I);
      if vItem = nil then
        Break;
      try
       {$ifdef Far3}
        with vItem^ do begin
          vName := FileName;
          if {(vName <> '.') and} (vName <> '..') then
            FComparator.AddItem(vName, FileAttributes, FileSize, FileTimeToDosFileDate(LastWriteTime));
        end;
       {$else}
        with vItem.FindData do begin
          vName := cFileName;
          if {(vName <> '.') and} (vName <> '..') then
            FComparator.AddItem(vName, dwFileAttributes, nFileSize, FileTimeToDosFileDate(ftLastWriteTime));
        end;
       {$endif Far3}
      finally
        MemFree(vItem);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TComparator                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TComparator.CreateEx(ASource1, ASource2 :TDataProvider);
  begin
    inherited Create;

    FSources[0] := ASource1;
    ASource1.FComparator := Self;

    FSources[1] := ASource2;
    ASource2.FComparator := Self;

    FResults := TCmpFolder.Create;

    InitMasks;
  end;


  destructor TComparator.Destroy; {override;}
  begin
    FreeObj(FResults);
    FreeObj(FInclMasks);
    FreeObj(FExclMasks);
    inherited Destroy;
  end;


  procedure TComparator.InitMasks;
  var
    vStr :TString;
  begin
    vStr := ExtractWord(1, optScanFileMask, ['|']);
    if vStr <> '' then
      FInclMasks := TFilterMask.CreateFileMask(vStr);

    vStr := ExtractWord(2, optScanFileMask, ['|']);
    if vStr <> '' then
      FExclMasks := TFilterMask.CreateFileMask(vStr);
  end;


  procedure TComparator.InitProgress;
  var
    vSize :TSize;
  begin
    if FSave = 0 then begin
      FSave := FARAPI.SaveScreen(0, 0, -1, -1);
      vSize := FarGetWindowSize;
      FWidth := IntMin(IntMax(vSize.CX div 2, 50), vSize.CX - 2);
    end;
  end;


  procedure TComparator.DoneProgress;
  begin
    if FSave <> 0 then begin
      FARAPI.RestoreScreen(FSave);
      FSave := 0;
    end;
  end;


  procedure TComparator.ShowProgress(const AMess :TString; APerc :Integer);
  var
    vMess :TFarStr;
  begin
    if FSave = 0 then
      InitProgress;
    if APerc = -1 then
      vMess := AMess
    else
      vMess := AMess + #10 + GetProgressStr(FWidth, APerc);
    ShowMessage(GetMsgStr(strCompareProgress), vMess, 0)
  end;


  procedure TComparator.AddItem(const AName :TString; Attr :Word; ASize :Int64; ATime :Integer);
  var
    vName :TString;
    vNeedPoint :Boolean;
    vIndex, vPos, vLen :Integer;
    vItem :TCmpFileItem;
  begin
//  TraceF('File: %s %s', ['', AName]);
    if optNoScanHidden and (faHidden and Attr <> 0) then
      Exit;

    vName := AName;
    if faDirectory and Attr <> 0 then begin
      { Маска каталогов... }
    end else
    begin
      vNeedPoint := ChrPos('.', vName) = 0;
      if vNeedPoint then
        vName := vName + '.'; { Чтобы работали маски, типа "*."}

      if (FInclMasks <> nil) and not FInclMasks.Check(vName, vPos, vLen) then
        Exit;
      if (FExclMasks <> nil) and FExclMasks.Check(vName, vPos, vLen) then
        Exit;

      if vNeedPoint then
        Delete(vName, Length(vName), 1);
    end;

    if faDirectory and Attr <> 0 then
      vName := vName + '\'
    else
      Inc(FFiles);

    if FCurList.FindKey(Pointer(vName), 0, [foBinary], vIndex) then
      vItem := FCurList[vIndex]
    else begin
      vItem := TCmpFileItem.CreateName(vName);
      vItem.ParentGroup := FCurList;
      FCurList.Insert(vIndex, vItem);
    end;
    vItem.SetInfo(FCurVer, Attr, ASize, ATime);
  end;


  procedure TComparator.CompareFolders; {virtual;}

    procedure UpdateMessage1(const AFolder :TString);
    begin
      ShowProgress(
//      Format('Files: %d   Folders: %d   Time: %d sec', [FFiles, FFolders, TickCountDiff(GetTickCount, FStart) div 1000]) + #10 +
        Format(GetMsgStr(strProgressInfo1), [FFiles, FFolders, TickCountDiff(GetTickCount, FStart) div 1000]) + #10 +
        StrLeftAjust(AFolder, FWidth), -1);
    end;


    procedure LocCompare(AList :TCmpFolder; const AFolder1, AFolder2 :TString);
    var
      I :Integer;
      vItem :TCmpFileItem;
      vFolder1, vFolder2 :TString;
    begin
//    TraceF('"%s" <-> "%s"', [AFolder1, AFolder2]);

      FCurList := AList;

      if AFolder1 <> #1 then begin
        AList.Folder1 := FSources[0].MakePath(AFolder1);
        Inc(FFolders);
        if SafeCheck(FLast) then
          UpdateMessage1(AList.Folder1);
        FCurVer := 0;
        FSources[0].Enumerate(AFolder1);
      end;

      if AFolder2 <> #1 then begin
        AList.Folder2 := FSources[1].MakePath(AFolder2);
        Inc(FFolders);
        if SafeCheck(FLast) then
          UpdateMessage1(AList.Folder2);
        FCurVer := 1;
        FSources[1].Enumerate(AFolder2);
      end;

      if optScanRecursive and FSources[0].CanRecurse and FSources[1].CanRecurse then begin
        for I := 0 to AList.Count - 1 do begin
          vItem := AList[I];
          if vItem.IsFolder then begin
            if optNoScanOrphan and not vItem.BothAttr(faPresent) then
              { Пропускаем непарные каталоги }
              Continue;

            vItem.Subs := TCmpFolder.Create;
            vItem.Subs.ParentItem := vItem;

            vFolder1 := #1;
            if (faDirectory and vItem.Attr[0] <> 0) and FSources[0].CanRecurse then
              vFolder1 := AddFileName(AFolder1, RemoveBackSlash(vItem.Name));
            vFolder2 := #1;
            if (faDirectory and vItem.Attr[1] <> 0) and FSources[1].CanRecurse then
              vFolder2 := AddFileName(AFolder2, RemoveBackSlash(vItem.Name));

            LocCompare(vItem.Subs, vFolder1, vFolder2);
          end;
        end;
      end;
    end;

  begin
    InitProgress;
    try
      FFiles := 0;
      FFolders := 0;
      FStart := GetTickCount;

      try
        LocCompare(FResults, '', '');

        if optScanContents and CanCompareContents then
          CompareFolderContents(FResults);

      except
        on E :ECtrlBreak do
          {Nothing};
        else
          raise;
      end;

    finally
      DoneProgress;
    end;
  end; {CompareFolders}


  function TComparator.CanGetFile(ASide :Integer) :Boolean;
  begin
    Result := FSources[ASide].CanGetFile;
  end;


  function TComparator.CanCompareContents :Boolean;
  begin
    Result := FSources[0].CanGetFile and FSources[1].CanGetFile;
  end;


  procedure TComparator.CompareFolderContents(AFolder :TCmpFolder);
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


  procedure TComparator.UpdateProgress2(AddSize :Int64);
  begin
    ShowProgress(
//    Format('Files: %s  Size: %s  Time: %d sec', [Int2StrEx(FFiles + 1), Int64ToStrEx(FSize + AddSize), TickCountDiff(GetTickCount, FStart) div 1000]) + #10 +
      Format(GetMsgStr(strProgressInfo2), [Int2StrEx(FFiles + 1), Int64ToStrEx(FSize + AddSize), TickCountDiff(GetTickCount, FStart) div 1000]) + #10 +
      StrLeftAjust(FCurFile, FWidth),
      MulDiv64(FSize + AddSize, 100, FTotSize));
  end;


  procedure TComparator.CompareFilesContents(const ABaseFolder :TString; AList :TStringList);
  var
    vBaseLen :Integer;

    procedure CompareFile(AItem :TCmpFileItem);
    var
      I :Integer;
      vFileName1, vFileName2 :TString;
    begin
      if not AItem.BothAttr(faPresent) then
        Exit;

      if not AItem.HasAttr(faDirectory) then begin
        if AItem.Size[0] <> AItem.Size[1] then
          { Не совпадает размер - незачем сравнивать }
          AItem.Content := ccDiff
        else begin
          {!!!}
          if ABaseFolder = '' then
            FCurFile := AItem.FName
          else
            FCurFile := Copy(AItem.GetFullFileName(0), vBaseLen + 1, MaxInt);

          if SafeCheck(FLast) or (AItem.Size[0] > 1*1024*1024) then
            UpdateProgress2(0);

          vFileName1 := RealFileName(AItem, 0);
          vFileName2 := RealFileName(AItem, 1);

          if CompareContents(vFileName1, vFileName2) then
            AItem.Content := ccSame
          else
            AItem.Content := ccDiff;

          Inc(FFiles);
          Inc(FSize, AItem.Size[0]);
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
    InitProgress;
    try
      FStart := GetTickCount;

      vBaseLen := Length(ABaseFolder);
      if (vBaseLen > 0) and (ABaseFolder[vBaseLen] <> '\') then
        Inc(vBaseLen);

      FTotFiles := 0; FTotSize := 0;
      for I := 0 to AList.Count - 1 do
        CalcFile(AList.Objects[I] as TCmpFileItem, FTotFiles, FTotSize);

      try
        FFiles := 0; FSize := 0;
        for I := 0 to AList.Count - 1 do
          CompareFile(AList.Objects[I] as TCmpFileItem);
      except
        on E :ECtrlBreak do
          {Nothing};
        else
          raise;
      end;

    finally
      DoneProgress;
    end;
  end; {CompareFilesContents}


  function TComparator.RealFileName(AItem :TCmpFileItem; AVer :Integer) :TString;
  begin
    Result := FSources[AVer].GetRealFileName(AItem.ParentGroup.GetFolder(AVer), AItem.Name);
  end;

  function TComparator.ViewFileName(AItem :TCmpFileItem; AVer :Integer) :TString;
  begin
    Result := FSources[AVer].GetViewFileName(AItem.ParentGroup.GetFolder(AVer), AItem.Name);
  end;

  function TComparator.ViewFileName(const AFolder, AName :TString; AVer :Integer) :TString;
  begin
    Result := FSources[AVer].GetViewFileName(AFolder, AName);
  end;

  function TComparator.PanelTitle(const AFolder :TString; AVer :Integer) :TString;
  begin
    Result := FSources[AVer].GetPanelTitle(AFolder);
  end;


 {-----------------------------------------------------------------------------}

  function TComparator.CompareContents(const AFileName1, AFileName2 :TString) :Boolean;
  var
    vFile1, vFile2 :THandle;
    vFileSize, vRestSize :Int64;
    vPart :Integer;
    vLast :DWORD;
  begin
    Result := False;
//  TraceF('Compare: %s <-> %s', [ AFileName1, AFileName2 ]);

    if vTmpBuf1 = nil then begin
      vTmpBuf1 := VirtualAlloc(nil, cTmpBufSize, MEM_COMMIT, PAGE_READWRITE);
      vTmpBuf2 := VirtualAlloc(nil, cTmpBufSize, MEM_COMMIT, PAGE_READWRITE);
    end;

    vFile1 := INVALID_HANDLE_VALUE; vFile2 := INVALID_HANDLE_VALUE;
    try
      vFile1 := CreateFile(PTChar(AFileName1), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0);
      if vFile1 = INVALID_HANDLE_VALUE then
        Exit;

      vFile2 := CreateFile(PTChar(AFileName2), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0);
      if vFile2 = INVALID_HANDLE_VALUE then
        Exit;

      vLast := GetTickCount;
      vFileSize := FileSize(vFile1);
      vRestSize := vFileSize;
      while vRestSize > 0 do begin

        if SafeCheck(vLast) then
          UpdateProgress2(vFileSize - vRestSize);

        {!!!}
        vPart := cTmpBufSize;
        if vPart > vRestSize then
          vPart := vRestSize;

        if FileRead(vFile1, vTmpBuf1^, vPart) <> vPart then
          Exit;
        if FileRead(vFile2, vTmpBuf2^, vPart) <> vPart then
          Exit;

        if MemCompare(vTmpBuf1, vTmpBuf2, vPart) < vPart then begin
          NOP;
          Exit;
        end;

        Dec(vRestSize, vPart);
      end;
      Result := True;

    finally
      if vFile1 <> INVALID_HANDLE_VALUE then
        FileClose(vFile1);
      if vFile2 <> INVALID_HANDLE_VALUE then
        FileClose(vFile2);
    end;
  end;


  function TComparator.CompareCRC(const AFileName1, AFileName2 :TString) :Boolean;

    function LocCalc(const AFileName :TString; var ACRC :TCRC) :Boolean;
    var
      vFile :THandle;
      vPart :Integer;
      vSize :Int64;
      vLast :DWORD;
    begin
      Result := False;

      vFile := CreateFile(PTChar(AFileName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN {or FILE_FLAG_NO_BUFFERING}, 0);
      if vFile = INVALID_HANDLE_VALUE then
        Exit;

      try
        ACRC  := 0;
        vLast := GetTickCount;
        vSize := FileSize(vFile);
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
        FileClose(vFile);
      end;
    end;

  var
    vCRC1, vCRC2 :TCRC;
  begin
    Result := False;
//  TraceF('Compare: %s <-> %s', [ AFileName1, AFileName2 ]);

    if vTmpBuf1 = nil then
//    vTmpBuf1 := GlobalAllocMem(HeapAllocFlags, cTmpBufSize);
      vTmpBuf1 := VirtualAlloc(nil, cTmpBufSize, MEM_COMMIT, PAGE_READWRITE);

    if not LocCalc(AFileName1, vCRC1) then
      Exit;
    if not LocCalc(AFileName2, vCRC2) then
      Exit;

    Result := vCRC1 = vCRC2;
  end;


 {-----------------------------------------------------------------------------}

  function TComparator.UpdateItemInfo(AItem :TCmpFileItem) :Boolean;

    procedure LocUpdateInfo(AVer :Integer);
    var
      vPath :TString;
      vAttr :Word;
      vSize :TInt64;
      vTime :Integer;
    begin
      vPath := AItem.ParentGroup.GetFolder(AVer);
      if vPath <> '' then
        if FSources[AVer].GetInfo(vPath, AItem.Name, vAttr, vSize, vTime) then
          AItem.SetInfo(AVer, vAttr, vSize, vTime)
        else begin
          AItem.SetInfo(AVer, 0, 0, 0);
          AItem.Attr[AVer] := 0;
        end;
    end;

  var
    vOldTime :array[0..1] of Integer;
    vOldSize :array[0..1] of Int64;
    vOldAttr :array[0..1] of Word;
  begin
    with AItem do begin
      vOldTime[0] := Time[0]; vOldTime[1] := Time[1];
      vOldSize[0] := Size[0]; vOldSize[1] := Size[1];
      vOldAttr[0] := Attr[0]; vOldAttr[1] := Attr[1];
    end;

    if CanGetFile(0) then
      LocUpdateInfo(0);
    if CanGetFile(1) then
      LocUpdateInfo(1);

    with AItem do begin
      Result :=
        ((vOldTime[0] <> Time[0]) or (vOldTime[1] <> Time[1])) or
        ((vOldSize[0] <> Size[0]) or (vOldSize[1] <> Size[1])) or
        ((vOldAttr[0] <> Attr[0]) or (vOldAttr[1] <> Attr[1]));
    end;

    if Result then
      AItem.Content := ccNoCompare;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
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




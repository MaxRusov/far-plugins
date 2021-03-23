{$I Defines.inc}

unit GitShellClasses;

interface

  uses
    Windows,
//  ShlObj,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMatch,

    GitLibAPI,
    VisCompAPI,

    GitShellCtrl;


  type
    TGitRepository = class;

    TDiffWhat = (
      dwWorkdir,
      dwIndex,
      dwCommit
    );

    TBranchKind = (
      bkLocal,
      bkRemote,
      bkTag
    );


    TWildcard = class(TBasis)
    public
      constructor Create(const aRoot, aMask :TString);
      function Match(const aFilename :TString) :Boolean;

    private
      FMask :TString;
      FIsFile :Boolean;
      FIsWildcard :Boolean;
    end;


    TGitBranch = class(TBasis)
    public
      constructor Create(aPID :PGitOid; const aName :TString; aKind :TBranchKind);

    private
      FID       :TGitOid;
      FName     :TString;
      FKind     :TBranchKind;

      function GetIDStr :TString;

    public
      property IDStr :TString read GetIDStr;
      property Name :TString read FName write FName;
      property Kind :TBranchKind read FKind;
    end;

    TGitCommit = class(TBasis)
    public
      constructor Create(const aID :TGitOid; aParents :Integer; aDate :TDateTime; const aAuthor, aEMail, aMessage :TString);

      function GetAuthorAndEmail :TString;

    private
      FID       :TGitOid;
      FParents  :Integer;
      FDate     :TDateTime;
      FAuthor   :TString;
      FEMail    :TString;
      FMessage1 :TString;
      FMessage2 :TString;

      function GetIDStr :TString;

    public
      property ID :TGitOid read FID;
      property IDStr :TString read GetIDStr;
      property Parents :Integer read FParents;
      property Date :TDateTime read FDate;
      property Message1 :TString read FMessage1;
      property Message2 :TString read FMessage2;
      property Author :TString read FAuthor;
      property EMail :TString read FEMail;
    end;


    TDiffFileStatus = (
      dfUnchanged,
      dfChanged,
      dfAdded,
      dfDeleted,
      dfRenamed
    );

    TGitDiffFile = class(TNamedObject)
    public
      constructor Create(const aName :TSTring; aSize :TInt64; aStatus :TDiffFileStatus); overload;

      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

    private
//    FName   :TString;
      FPath   :TString;
      FSize   :TInt64;
      FStatus :TDiffFileStatus;

      function GetFileName :TString;

    public
      property Path :TString read FPath;
      property FileName :TString read GetFileName;
      property Status :TDiffFileStatus read FStatus;
    end;


    TGitWorkdirStatus = class(TBasis)
    public
      constructor Create(const aFolder :TString); overload;
      destructor Destroy; override;

    private
      FFolder   :TString;
      FUnstaged :TObjList;
      FStaged   :TObjList;

    public
      property Folder :TString read FFolder;
      property Unstaged :TObjList read FUnstaged;
      property Staged :TObjList read FStaged;
    end;


    TGitRepository = class(TBasis)
    public
      constructor Create(const AFolder :TString); overload;
      destructor Destroy; override;

      procedure ShowInfo;
      procedure ShowBranches;
      procedure ShowDiff(const ARevisions :TString);
//    procedure ShowCommit(const AFolder :TString);
      procedure ShowCommitDiff(const aOID :TGitOid; aParentIdx :Integer; const aPath :TString; aFull :Boolean);
      procedure ShowHistory(const aPath :TString);

      function GetWorkdirStatus(const AFolder :TString) :TGitWorkdirStatus;
      procedure PrepareCommit(const AFolder :TString);

      procedure Checkout(const aName :TString);
      procedure CreateBranch(const aNewName, aBaseName :TString; var oID :TGitOid);
      procedure RenameBranch(const aOldName, aNewName :TString);
      procedure DeleteBranch(const aName :TString);

      procedure IndexAddFile(const AFileName :TString);
      procedure IndexRemoveFile(const AFileName :TString);
      procedure IndexAddAll(const AFileName :TString);
      procedure IndexReset(const AFileName :TString);

      procedure Commit(const aMessage, aAuthor, aEMail :TString);
      procedure AmendCommit(const aMessage, aAuthor, aEMail :TString);

      function GetCurrentBranchName :TString;
      function GetTempFolder :TString;

      function WriteFileRevisionTo(const aFileRev, aFileName :TString; aMakeFolder :Boolean) :Boolean;
      function GetFileRevision(const aFileRev :TString) :TString;
      procedure DeleteTempFiles;

      function GetShortIdStr(const aOID :TGitOid) :TString;

    private
      FRepo      :PGitRepository;
      FWorkDir   :TString;
      FTempDir   :TString;

      FDiffList1 :IVCFileList;
      FDiffList2 :IVCFileList;
      FDiffMask  :TWildcard;
      FDiffCount :Integer;
      FDiffFile  :TString;

      FTempFiles :TStrList;

      procedure AddFileDelta(aDelta :PGitDiffDelta; const aList1, aList2 :IVCFileList; const aRootPath :TString);
//    procedure ShowDiffBetween(const aOID1, aOID2 :TGitOid; aFull :Boolean); overload;
      procedure ShowDiffBetween(aCommit1, aCommit2 :PGitCommit; const aPath :TString; aFull :Boolean); overload;
      procedure ShowDiffBetweenEx(aWhat1, aWhat2 :TDiffWhat; aOID1, aOID2 :PGitOid; const aCaption1, aCaption2 :TString; const aPath :TString; aFull :Boolean);

    public
      property Repo :PGitRepository read FRepo;
      property WorkDir :TString read FWorkDir;
    end;


  var
    ShowBranchesDlg :function(ARepo :TGitRepository; ABranches :TExList; aCur :Integer) :Boolean;
    ShowHistDlg :function(ARepo :TGitRepository; const aPath :TString; AHistory :TExList) :Boolean;
    ShowCommitDlg :function(ARepo :TGitRepository; var ADirStatus :TGitWorkdirStatus) :Boolean;
    ShowInfoDlg :function(ARepo :TGitRepository; const ATitle :TString; const AInfo :array of TString) :Boolean;

  var
    CloseMainMenu :Boolean;

  const
    cOIDStrLen = GIT_OID_HEXSZ;
    cHead = 'HEAD';

  procedure GitCheck(aCode :Integer);

  function FindVisualCompareAPI :IVisCompAPI;
  function GetVisualCompareAPI :IVisCompAPI;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
//  GitShellHistory,
    MixDebug;



  procedure GitCheck(aCode :INteger);
  var
    vMess :TString;
  begin
    if aCode = 0 then
      Exit;
    case aCode  of
      GIT_ENOTFOUND     : vMess := 'Requested object could not be found';
      GIT_EEXISTS       : vMess := 'Object exists preventing operation';
      GIT_EAMBIGUOUS    : vMess := 'More than one object matches';
      GIT_EINVALIDSPEC  : vMess := 'Name/ref spec was not in a valid format';
      GIT_ECONFLICT     : vMess := 'Checkout conflicts prevented operation';
      GIT_EINVALID      : vMess := 'Invalid operation or input';
    end;
    vMess := AppendStrCh('GIT Error ' + Int2Str(aCode), vMess, ':'#10);
    AppError(vMess);
  end;


  procedure InitLibGit;
  var
    vPath :TString;
  begin
    try
      vPath := ExtractFilePath(FARAPI.ModuleName, True);
      SetDllDirectory(PTChar(vPath));
      try
        InitLibgit2;
      finally
        SetDllDirectory(nil);
      end;
    except
      on E :Exception do
        AppErrorIdFmt( strDllLoadError, [cGit2Dll, E.Message] );
    end;
  end;


//  function GetSpecialFolder(FolderType :Integer) :TString;
//  var
//    pidl :PItemIDList;
//    buf  :array[0..MAX_PATH] of TChar;
//  begin
//    Result := '';
//    if SHGetSpecialFolderLocation(0, FolderType, pidl) = NOERROR then begin
//      SHGetPathFromIDList(pidl, buf);
//      Result := buf;
//    end;
//  end;


//  procedure FolderNeeded(const aPath :TString);
//  begin
//    if not WinFolderExists(aPath) then
//      if not CreateDir(aPath) then
//        RaiseLastWin32Error;
//  end;



  procedure SaveBuffer(const AFileName :TString; const ABuf; BufSize :TInt64);
  var
    vFile :THandle;
  begin
    vFile := FileCreate(AFileName);
    if vFile = INVALID_HANDLE_VALUE then
      ApiCheck(False);
    try
      FileWrite(vFile, ABuf, BufSize);
    finally
      FileClose(vFile);
    end;
  end;


  function GitTimeToDateTime(aTime :git_time) :TDateTime;
  const
    cUnixStartDate: TDateTime = 25569.0; // 01/01/1970
  begin
    Result := (aTime.time / SecsPerDay) + cUnixStartDate;
  end;


  function GetOIDToStr(const aOID :TGitOid) :TString;
  var
    vBuf :array[0..cOIDStrLen] of AnsiChar;
  begin
    git_oid_tostr(@vBuf[0], SizeOf(vBuf), @aOID);
    Result := TString(vBuf);
  end;


  function FileToGit(const AFileName :TString) :TAnsiStr;
  begin
    Result := WideToUTF8(StrReplaceChars(AFileName, ['\'], '/'));
  end;


  function GitToFile(AGitName :PAnsiChar) :TString;
  begin
    Result := StrReplaceChars(UTF8ToWide(AGitName), ['/'], '\');
  end;


 {-----------------------------------------------------------------------------}


  function FindVisualCompareAPI :IVisCompAPI;
  var
    vHandle :THandle;
    vGetApiProc :TGetVisCompAPI;
  begin
    Result := nil;

    { «агружаем VisualCompare, если он еще не загружен }
    FarExecMacro('Plugin.SyncCall("' +cVisCompGUID + '")', []);

    vHandle := GetModuleHandle('VisComp.dll');
    if vHandle = 0 then
      Exit; {VisualCompare не установлен}

    vGetApiProc := GetProcAddress( vHandle, 'GetVisCompAPI' );
    if not Assigned(vGetApiProc) then
     Exit; {VisualCompare неподход€щей версии }

    Result := vGetApiProc();
  end;


  function GetVisualCompareAPI :IVisCompAPI;
  begin
    Result := FindVisualCompareAPI;
    if Result = nil then
      AppErrorId(strVisualCompareNotFound);
  end;


 {-----------------------------------------------------------------------------}
 { TWildcard                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TWildcard.Create(const aRoot, aMask :TString);
  begin
    FMask := aMask;
    FIsWildcard := FileNameHasMask(aMask);
  end;


  function TWildcard.Match(const aFilename :TString) :Boolean;
  var
    vPos, vLen :Integer;
  begin
    if FIsWildcard then
      Result := StringMatch(FMask, '', PTChar(aFileName), vPos, vLen)
    else
      Result := UpCompareSubStr(FMask, aFilename) = 0
  end;


 {-----------------------------------------------------------------------------}
 { TGitBarnch                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TGitBranch.Create(aPID :PGitOid; const aName :TString; aKind :TBranchKind);
  begin
    if aPID <> nil then
      FID := aPID^;
    FName := aName;
    FKind := aKind;
  end;


  function TGitBranch.GetIDStr :TString;
  begin
    Result := GetOIDToStr(FID);
  end;


 {-----------------------------------------------------------------------------}
 { TGitCommit                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TGitCommit.Create(const aID :TGitOid; aParents :Integer; aDate :TDateTime; const aAuthor, aEMail, aMessage :TString);
  var
    vPtr :PTChar;
  begin
    FID      := aID;
    FParents := aParents;
    FDate    := aDate;
    FAuthor  := aAuthor;
    FEMail   := aEMail;

    vPtr := PTChar(aMessage);
    FMessage1 := ExtractNextWord(vPtr, [charCR, charLF]);
    FMessage2 := vPtr;
  end;


  function TGitCommit.GetIDStr :TString;
  begin
    Result := GetOIDToStr(FID);
  end;


  function TGitCommit.GetAuthorAndEmail :TString;
  begin
    Result := FAuthor;
    if FEMail <> '' then
      Result := Result + ' (' + FEMail + ')';
  end;



 {-----------------------------------------------------------------------------}
 { TContentCallback                                                            }
 {-----------------------------------------------------------------------------}

  type
    TContentCallback = class(TComBasis, IVCContentCallback)
    public
      constructor Create(aRepo :TGitRepository); overload;

    private
      function GetRealFileName(const aList :IVCFileList; aFolder, aFileName :PWChar) :PWChar; stdcall;

    private
      FRepo :TGitRepository;
      FTmpStr :TString;
    end;


  constructor TContentCallback.Create(aRepo :TGitRepository);
  begin
    Create;
    FRepo := aRepo;
  end;


//  function TContentCallback.GetRealFileName(const aList :IVCFileList; aFolder, aFileName :PWChar) :PWChar;
//  var
//    vObj :PGitObject;
//    vTag, vRoot :TString;
//    vSpec :TString;
//    vObjType :Integer;
//    vSize :TInt64;
//    vContent :PAnsiChar;
//  begin
//    vTag := aList.GetTag;
//    vRoot := ExtractWord(2, aList.GetRoot, [':']);
//
//    if vTag = '' then begin
//      FTmpStr := AddFileName(AddFileName(AddFileName(FRepo.FWorkDir, vRoot), aFolder), aFileName);
//      Result := PWChar(FTmpStr);
//    end else
//    begin
//      Result := '';
//      vObj := nil;
//
//      vSpec := vTag + ':' + StrReplaceChars(AddFileName(AddFileName(vRoot, aFolder), aFileName), ['\'], '/');
//      if git_revparse_single(vObj, FRepo.FRepo, PAnsiChar(WideToUTF8(vSpec))) <> 0 then
//        Exit;
//      try
//        vObjType := git_object_type(vObj);
//        if vObjType <> GIT_OBJ_BLOB then
//          Exit;
//
//        vSize := git_blob_rawsize(vObj);
//        vContent := pointer(git_blob_rawcontent(vObj));
//
//        FTmpStr := AddFilename(FRepo.GetTempFolder, vTag);
//        if not WinFolderExists(FTmpStr) then
//          if not CreateDir(FTmpStr) then
//            RaiseLastWin32Error;
//
//        FTmpStr := AddFilename(FTmpStr, aFileName);
//        SaveBuffer(FTmpStr, vContent^, vSize);
//
//        Result := PWChar(FTmpStr);
//      finally
//        git_object_free(vObj);
//      end;
//    end;
//  end;


  function TContentCallback.GetRealFileName(const aList :IVCFileList; aFolder, aFileName :PWChar) :PWChar;
  var
    vTag, vRoot, vFileRev :TString;
  begin
    vTag := aList.GetTag;
    vRoot := ExtractWord(2, aList.GetRoot, [':']);

    if vTag = '' then
      FTmpStr := AddFileName(AddFileName(AddFileName(FRepo.FWorkDir, vRoot), aFolder), aFileName)
    else begin
      vFileRev := AddFileName(AddFileName(vTag + ':' + vRoot, aFolder), aFileName);
      FTmpStr := FRepo.GetFileRevision(vFileRev);
    end;

    Result := PWChar(FTmpStr);
  end;



 {-----------------------------------------------------------------------------}
 { TGitRepository                                                              }
 {-----------------------------------------------------------------------------}

  constructor TGitRepository.Create(const aFolder :TString);
  var
    vAPath :TAnsiStr;
    vRes :Integer;
  begin
    Create;

    InitLibGit;

    vAPath := WideToUTF8('\\?\' + RemoveBackSlash(aFolder));
    vRes := git_repository_open_ext(FRepo, PGitChar(vAPath), 0, nil);

    if (vRes = GIT_ENOTFOUND) and FileNameIsLocal(aFolder) then begin
      { ƒополнительно проверим корень диска... }
      vAPath := WideToUTF8('\\?\' + ExtractFileDrive(aFolder) + '\');
      vRes := git_repository_open(FRepo, PGitChar(vAPath));
    end;

    if vRes = GIT_ENOTFOUND then
      AppErrorId(strRepositoryNotFound);
    GitCheck(vRes);

    FWorkDir := UTF8ToWide(git_repository_workdir(FRepo));
    FWorkDir := AddBackSlash(StrReplaceChars(FWorkDir, ['/'], '\'));
    Assert(FWorkDir <> '');

    FTempFiles := TStrList.Create;
  end;


  destructor TGitRepository.Destroy; {override;}
  begin
    FreeObj(FTempFiles);
    if FRepo <> nil then
      git_repository_free(FRepo);
    inherited Destroy;
  end;


  function TGitRepository.GetShortIdStr(const aOID :TGitOid) :TString;
  var
    vObj :PGitObject;
    vBuf :TGitBuf;
    vAStr :TAnsiStr;
  begin
    Result := '';
    vObj := nil;
    if git_object_lookup(vObj, FRepo, @aOID, GIT_OBJ_ANY) = 0 then begin
      FillZero(vBuf, SizeOf(TGitBuf));
      try
        GitCheck(git_object_short_id(vBuf, vObj));
        SetString(vAStr, PAnsiChar(vBuf.ptr), vBuf.size);
        Result := TString(vAStr);
      finally
        git_object_free(vObj);
        git_buf_free(@vBuf);
      end;
    end;
  end;


  function TGitRepository.GetCurrentBranchName :TString;
  var
    vHead :PGitReference;
    vCom :PGitCommit;
  begin
    Result := '';
//    GitCheck(git_repository_head(vHead, FRepo));
    vCom := nil;
    if git_repository_head(vHead, FRepo) <> 0 then
      Exit;
    try
      if git_repository_head_detached(FRepo) <> 0 then
        Result := 'detached ' + UTF8ToWide(git_reference_name(vHead))
      else
        Result := UTF8ToWide(git_reference_shorthand(vHead))

//      if git_reference_is_branch(vHead) <> 0 then
//        Result := UTF8ToWide(git_reference_shorthand(vHead))
//      else
//      if git_reference_is_tag(vHead) <> 0 then
//        Result := UTF8ToWide(git_reference_shorthand(vHead))
//      else begin
//        Result := UTF8ToWide(git_reference_name(vHead))
////        if git_commit_lookup(vCom, FRepo, git_reference_target(vHead)) = 0 then
//////        Result := UTF8ToWide(git_reference_shorthand(vHead))
////          Result := UTF8ToWide(git_commit_message(vCom))
////        else
////          Result := UTF8ToWide(git_reference_shorthand(vHead))
//      end;

    finally
      if vCom <> nil then
        git_commit_free(vCom);
      git_reference_free(vHead);
    end;
  end;


  function TGitRepository.GetTempFolder :TString;
  begin
    if FTempDir = '' then begin
      FTempDir := AddFileName(StrGetTempPath, cTmpFolder);
      CreateFolders(FTempDir, True);
    end;
    Result := FTempDir;
  end;


  procedure TGitRepository.DeleteTempFiles;
  var
    i :Integer;
    vName :TString;
  begin
    for i := 0 to FTempFiles.Count - 1 do begin
      vName := FTempFiles[i];
      if DeleteFile(vName) then begin
        vName := ExtractFilePath(vName, True);
        if FolderIsEmpty(vName) then
          RemoveDir(vName);
      end;
    end;
    FTempFiles.Clear;

    if FTempDir <> '' then begin
      if FolderIsEmpty(FTempDir) then begin
        RemoveDir(FTempDir);
        FTempDir := '';
      end;
    end;
  end;


(*
  function TGitRepository.WriteFileRevisionTo(const aFileRev, aFileName :TString; aMakeFolder :Boolean) :Boolean;
  var
    vRes :Integer;
    vObj :PGitObject;
    vObjType :Integer;
    vSize :TInt64;
    vContent :PAnsiChar;
  begin
    vRes := git_revparse_single(vObj, FRepo, PAnsiChar(FileToGit(aFileRev)));
    GitCheck(vRes);
//  if vRes <> 0 then
//    Exit;
    try
      vObjType := git_object_type(vObj);
      if vObjType <> GIT_OBJ_BLOB then
        GitCheck(GIT_ENOTFOUND);
//      Exit;

      vSize := git_blob_rawsize(vObj);
      vContent := pointer(git_blob_rawcontent(vObj));

      if aMakeFolder then
        CreateFolders( ExtractFilePath(aFileName, True), True );

      SaveBuffer(aFileName, vContent^, vSize);
      Result := True;
    finally
      git_object_free(vObj);
    end;
  end;
*)
  function TGitRepository.WriteFileRevisionTo(const aFileRev, aFileName :TString; aMakeFolder :Boolean) :Boolean;
  var
    vRes :Integer;
    vBuf :TGitBuf;
    vObj :PGitObject;
    vObjType :Integer;
  begin
    FillZero(vBuf, SizeOf(TGitBuf));
    vRes := git_revparse_single(vObj, FRepo, PAnsiChar(FileToGit(aFileRev)));
    GitCheck(vRes);
    try
      vObjType := git_object_type(vObj);
      if vObjType <> GIT_OBJ_BLOB then
        GitCheck(GIT_ENOTFOUND);

      vRes := git_blob_filtered_content(vBuf, vObj, PAnsiChar(FileToGit(aFileName)), 1);
      GitCheck(vRes);

      if aMakeFolder then
        CreateFolders( ExtractFilePath(aFileName, True), True );

      SaveBuffer(aFileName, vBuf.ptr^, vBuf.size);
      Result := True;
    finally
      git_object_free(vObj);
      git_buf_free(@vBuf);
    end;
  end;


  function TGitRepository.GetFileRevision(const aFileRev :TString) :TString;
  var
    vName :TString;
  begin
    Result := '';

    vName := AddFilename(AddFilename(GetTempFolder, ExtractWord(1, aFileRev, [':'])), ExtractFileName(aFileRev));

    if WriteFileRevisionTo(aFileRev, vName, True) then begin
      FTempFiles.AddSorted(vName, 0, dupIgnore);
      Result := vName;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TGitRepository.ShowInfo;
  var
    i :Integer;
    vRemotes :TGitStrArray;
    vRemote :PGitRemote;
    vSign :PGitSignature;
    vStr, vRemotesStr, vAuthorStr :TString;
  begin
    vRemotesStr := '';
    FillZero(vRemotes, SizeOf(vRemotes));
    GitCheck(git_remote_list(vRemotes, FRepo));
    try
      for i := 0 to vRemotes.count - 1 do begin
        GitCheck(git_remote_lookup(vRemote, FRepo, vRemotes.strings[i]));
        try
          vStr := UTF8ToWide(git_remote_url(vRemote)) + ' (' + UTF8ToWide(vRemotes.strings[i]) + ')';
          vRemotesStr := AppendStrCh(vRemotesStr, vStr, #13);
        finally
          git_remote_free(vRemote);
        end;
      end;
    finally
      git_strarray_free(@vRemotes);
    end;

    if git_signature_default(vSign, FRepo) = 0 then begin
      try
        vAuthorStr := UTF8ToWide(vSign.name);
        if vSign.email <> '' then
          vAuthorStr := vAuthorStr + ' (' + UTF8ToWide(vSign.email) + ')';
      finally
        git_signature_free(vSign);
      end;
    end;

    ShowInfoDlg(FRepo,
      GetMsgStr(strRepoInfoTitle),
    [
      GetMsgStr(strWorkDir), RemoveBackSlash(FWorkDir),
      GetMsgStr(strRemotes), vRemotesStr,
      GetMsgStr(strUserName), vAuthorStr
    ]);

  end;


 {-----------------------------------------------------------------------------}

  function GitTagForeachCallback(name :PAnsiChar; oid :PGitOID; payload :pointer) :integer; cdecl;
  begin
//  Trace('%s', [name]);
    with TObjList(payload) do
      Add( TGitBranch.Create(oid, UTF8ToWide(name), bkTag) );
    Result := 0;
  end;


  procedure TGitRepository.ShowBranches;
  var
    i, vHeadIdx :Integer;
    vIterator :PGitBranchIterator;
    vBranchRef :PGitReference;
    vBranchType :uint;
    vName :PAnsiChar;
    vKind :TBranchKind;
    vBranches :TObjList;
  begin
    vBranches := TObjList.Create;
    try
      GitCheck(git_branch_iterator_new(vIterator, FRepo, GIT_BRANCH_ALL));
      try
        i := 0; vHeadIdx := -1;
        while git_branch_next(vBranchRef, vBranchType, vIterator) = 0 do begin
          try
            git_branch_name(vName, vBranchRef);

            if git_branch_is_head(vBranchRef) <> 0 then
              vHeadIdx := i;

            vKind := bkLocal;
            if git_reference_is_remote(vBranchRef) <> 0 then
              vKind := bkRemote;

            vBranches.Add( TGitBranch.Create(git_reference_target(vBranchRef), UTF8ToWide(vName), vKind) );
            Inc(i);

          finally
            git_reference_free(vBranchRef);
          end;
        end;

      finally
        git_branch_iterator_free(vIterator);
      end;

//    git_tag_foreach(FRepo, GitTagForeachCallback, vBranches);

      Assert(Assigned(ShowBranchesDlg));
      ShowBranchesDlg(Self, vBranches, vHeadIdx);

    finally
      FreeObj(vBranches);
    end;
  end;


  procedure TGitRepository.CreateBranch(const aNewName, aBaseName :TString; var oID :TGitOid);
  var
    vObj :PGitObject;
    vNewBranch :PGitReference;
  begin
    GitCheck( git_revparse_single(vObj, FRepo, PAnsiChar(WideToUTF8(aBaseName))) );
    try
      GitCheck( git_branch_create(vNewBranch, FRepo, PAnsiChar(WideToUTF8(aNewName)), vObj, 0) );
      oID := git_reference_target(vNewBranch)^;
    finally
      git_object_free(vObj);
    end;
  end;


  procedure TGitRepository.RenameBranch(const aOldName, aNewName :TString);
  var
    vBranch, vNewBranch :PGitReference;
  begin
    vBranch := nil; vNewBranch := nil;
    GitCheck( git_reference_lookup(vBranch, FRepo, PAnsiChar(WideToUTF8('refs/heads/' + aOldName))) );
    try
      GitCheck( git_branch_move(vNewBranch, vBranch, PAnsiChar(WideToUTF8(aNewName)), 0));
    finally
      if vNewBranch <> nil then
        git_reference_free(vNewBranch);
      git_reference_free(vBranch);
    end;
  end;


  procedure TGitRepository.DeleteBranch(const aName :TString);
  var
    vBranch :PGitReference;
  begin
    GitCheck( git_reference_lookup(vBranch, FRepo, PAnsiChar(WideToUTF8('refs/heads/' + aName))) );
    try
      GitCheck( git_branch_delete(vBranch));
    finally
      git_reference_free(vBranch);
    end;
  end;


///**
// * Updates files in the index and the working tree to match the content of
// * the commit pointed at by HEAD.
// *
// * Note that this is _not_ the correct mechanism used to switch branches;
// * do not change your `HEAD` and then call this method, that would leave
// * you with checkout conflicts since your working directory would then
// * appear to be dirty.  Instead, checkout the target of the branch and
// * then update `HEAD` using `git_repository_set_head` to point to the
// * branch you checked out.
// *
// * @param repo repository to check out (must be non-bare)
// * @param opts specifies checkout options (may be NULL)
// * @return 0 on success, GIT_EUNBORNBRANCH if HEAD points to a non
// *         existing branch, non-zero value returned by `notify_cb`, or
// *         other error code < 0 (use giterr_last for error details)
// */
//GIT_EXTERN(int) git_checkout_head(
//	git_repository *repo,
//	const git_checkout_options *opts);


///**
// * Updates files in the index and working tree to match the content of the
// * tree pointed at by the treeish.
// *
// * @param repo repository to check out (must be non-bare)
// * @param treeish a commit, tag or tree which content will be used to update
// * the working directory (or NULL to use HEAD)
// * @param opts specifies checkout options (may be NULL)
// * @return 0 on success, non-zero return value from `notify_cb`, or error
// *         code < 0 (use giterr_last for error details)
// */
//GIT_EXTERN(int) git_checkout_tree(
//	git_repository *repo,
//	const git_object *treeish,
//	const git_checkout_options *opts);


///**
// * Make the repository HEAD point to the specified reference.
// *
// * If the provided reference points to a Tree or a Blob, the HEAD is
// * unaltered and -1 is returned.
// *
// * If the provided reference points to a branch, the HEAD will point
// * to that branch, staying attached, or become attached if it isn't yet.
// * If the branch doesn't exist yet, no error will be return. The HEAD
// * will then be attached to an unborn branch.
// *
// * Otherwise, the HEAD will be detached and will directly point to
// * the Commit.
// *
// * @param repo Repository pointer
// * @param refname Canonical name of the reference the HEAD should point at
// * @return 0 on success, or an error code
// */
//GIT_EXTERN(int) git_repository_set_head(
//	git_repository* repo,
//	const char* refname);

  function GitCheckoutNotifyCallback(why :uint; path :PAnsiChar; baseline, target, workdir :PGitDiffFile; payload :pointer) :Integer; cdecl;
  begin
//  Trace('%d, %s', [why, UTF8ToWide(path) ]);
    Result := 0;
  end;


  procedure TGitRepository.Checkout(const aName :TString);
  var
    vObj :PGitObject;
    vRef :PGitReference;
    vCom :PGitAnnotCommit;
    vOpts :TGitCheckoutOptions;
    vOID :TGitOID;
    vBranch :Boolean;
  begin
    vObj := nil; vRef := nil; vCom := nil;
    try
      GitCheck( git_revparse_single(vObj, FRepo, PAnsiChar(WideToUTF8(aName))) );
      GitCheck( git_reference_dwim(vRef, FRepo, PAnsiChar(WideToUTF8(aName))) );

      vBranch := git_reference_is_branch(vRef) <> 0;
      vOID := git_reference_target(vRef)^;

//      FillZero(vOpts, SizeOf(vOpts));
//      vOpts.version := 1;
//      vOpts.notify_cb := GitCheckoutNotifyCallback;
//      GitCheck( git_checkout_tree(FRepo, vObj, @vOpts) );

      FillZero(vOpts, SizeOf(vOpts));
      vOpts.version := 1;
      vOpts.checkout_strategy := GIT_CHECKOUT_SAFE;
      vOpts.notify_cb := GitCheckoutNotifyCallback;

      GitCheck( git_checkout_tree(FRepo, vObj, @vOpts) );

      if vBranch then
        GitCheck( git_repository_set_head(FRepo, PAnsiChar(WideToUTF8('refs/heads/' + aName))) )
      else begin
        if git_annotated_commit_from_ref(vCom, FRepo, vRef) = 0 then
          GitCheck( git_repository_set_head_detached_from_annotated(FRepo, vCom))
        else
          GitCheck( git_repository_set_head_detached(FRepo, @vOID));
      end;

      FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
      FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);

    finally
      if vCom <> nil then
        git_annotated_commit_free(vCom);
      if vObj <> nil then
        git_object_free(vObj);
      if vRef <> nil then
        git_reference_free(vRef);
    end;
  end; {Checkout}


 {-----------------------------------------------------------------------------}

  procedure TGitRepository.ShowDiff(const ARevisions :TString);
  var
    vShowAll :Boolean;

    function GetDiffNames(var aName1, aName2 :TString) :boolean;
    var
      vNames :TString;
    begin
      Result := False;
      vNames := ARevisions;
      vShowAll := False;
      if FarInputBox('Diff' {GetMsg(strRenameBranchTitle)}, 'Revision names:'{GetMsg(strBranchNamePrompt)}, vNames, FIB_BUTTONS {or FIB_NOUSELASTHISTORY} or FIB_ENABLEEMPTY, cDiffNamesHistory) then begin
        aName1 := ExtractWord(1, vNames, [' ']);
        aName2 := ExtractWord(2, vNames, [' ']);
        vShowAll := StrEqual(ExtractWord(3, vNames, [' ']), '-a');
        Result := True;
      end;
    end;


    function LocFind(const aName :TString; var aOID :TGitOid; var aWhat :TDiffWhat) :Boolean;
    var
      vRef :PGitReference;
      vObj :PGitObject;
    begin
      if aName = '.' then begin
        aWhat := dwWorkdir;
        exit( True );
      end;

      if git_reference_lookup(vRef, FRepo, PAnsiChar(WideToUTF8(aName))) = 0 then begin
        aOID := git_reference_target(vRef)^;
        git_reference_free(vRef);
        aWhat := dwCommit;
        exit( True );
      end;

      GitCheck( git_revparse_single(vObj, FRepo, PAnsiChar(WideToUTF8(aName))) );
      try
        aOID := git_object_id(vObj)^;
        aWhat := dwCommit;
        exit( True );
      finally
        git_object_free(vObj);
      end;
    end;


  var
    vName1, vName2 :TString;
    vOID1, vOID2 :TGitOid;
    vWhat1, vWhat2 :TDiffWhat;
  begin
    if not GetDiffNames(vName1, vName2) then
      Exit;

    if not LocFind(vName1, vOID1, vWhat1) or not LocFind(vName2, vOID2, vWhat2) then
      Exit;

    ShowDiffBetweenEx( vWhat1, vWhat2, @vOID1, @vOID2, vName1, vName2, '', vShowAll );
  end;


 {-----------------------------------------------------------------------------}

  procedure TGitRepository.AddFileDelta(aDelta :PGitDiffDelta; const aList1, aList2 :IVCFileList; const aRootPath :TString);
  var
    vFileName1{, vFileName2} :TString;
    vFileSize1, vFileSize2 :TInt64;
  begin
//  Trace('Status=%d, Flags=%d, Files=%d, %s, %s, Size: %d, %d', [aDelta.status, aDelta.flags, aDelta.nfiles, aDelta.old_file.path, aDelta.new_file.path, aDelta.old_file.Size, aDelta.new_file.Size]);

    vFileName1 := UTF8ToWide(aDelta.old_file.path);
//  vFileName2 := UTF8ToWide(aDelta.new_file.path);
    vFileSize1 := aDelta.old_file.size;
    vFileSize2 := aDelta.new_file.size;

    vFileName1 := StrReplaceChars(vFileName1, ['/'], '\');
    if vFileName1 = '' then
      Exit;

    if FDiffMask <> nil then
      if not FDiffMask.Match(vFilename1) then
        Exit;

    if aRootPath <> '' then begin
      if not UpCompareSubStr(aRootPath, vFileName1) = 0 then
        {“акого не должно быть, прверка на вс€кий случай... }
        Exit;
      vFileName1 := Copy(vFileName1, Length(aRootPath) + 1, MaxInt)
    end;

    if aDelta.status = GIT_DELTA_UNMODIFIED then begin
      if vFileSize1 = 0 then
        vFileSize1 := vFileSize2;
      if vFileSize2 = 0 then
        vFileSize2 := vFileSize1;
    end;

    FDiffFile := '';

    if aDelta.status in [GIT_DELTA_ADDED, GIT_DELTA_UNTRACKED] then begin
      aList2.AddFile(PWideChar(vFileName1), 0, vFileSize2, 0, 0);
    end else
    if aDelta.status = GIT_DELTA_DELETED then begin
      aList1.AddFile(PWideChar(vFileName1), 0, vFileSize1, 0, 0);
    end else
    if aDelta.status = GIT_DELTA_RENAMED then begin
      {!!!}
      NOP;
    end else
    begin
      aList1.AddFile(PWideChar(vFileName1), 0, vFileSize1, 0, 0);
      aList2.AddFile(PWideChar(vFileName1), 0, vFileSize2, 0, IntIf(aDelta.status = GIT_DELTA_UNMODIFIED, 0, 1) );

      if FDiffCount = 0 then
        FDiffFile := vFileName1;
    end;

    Inc(FDiffCount);
  end; {AddFileDelta}


//  function GitDiffLineCallback(delta :PGitDiffDelta; hunk :pointer{Pgit_diff_hunk}; line :pointer{Pgit_diff_line}; payload :pointer) :Integer; cdecl;
//  begin
//    Trace('Status=%d, Flags=%d, Files=%d, %s', [delta.status, delta.flags, delta.nfiles, delta.old_file.path]);
//    Result := 0;
//  end;


  function GitDiffFileCallback(aDelta :PGitDiffDelta; aProgress :float; aPayload :pointer) :integer; cdecl;
  begin
    with TGitRepository(aPayload) do
      AddFileDelta(aDelta, FDiffList1, FDiffList2, '');
    Result := 0;
  end;

(*
  procedure TGitRepository.ShowCommitDiff(const aOID :TGitOid; aParentIdx :Integer; const aPath :TString; aFull :Boolean);
  var
    vCommit, vParent :PGitCommit;
    vParents :Integer;
  begin
    vParent := nil;
    GitCheck(git_commit_lookup(vCommit, FRepo, @aOID));
    try
      vParents := git_commit_parentcount(vCommit);
      if vParents = 0 then
        Exit;

      GitCheck(git_commit_parent(vParent, vCommit, aParentIdx));
      ShowDiffBetween(vParent, vCommit, aPath, aFull);

    finally
      if vParent <> nil then
        git_commit_free(vParent);
      git_commit_free(vCommit);
    end;
  end;
*)

  procedure TGitRepository.ShowCommitDiff(const aOID :TGitOid; aParentIdx :Integer; const aPath :TString; aFull :Boolean);
  var
    vCommit, vParent :PGitCommit;
    vParents :Integer;
  begin
    vParent := nil;
    GitCheck(git_commit_lookup(vCommit, FRepo, @aOID));
    try
      vParents := git_commit_parentcount(vCommit);

      if vParents = 0 then
        ShowDiffBetweenEx(dwCommit, dwCommit, nil, git_commit_id(vCommit), '', '', aPath, aFull)
      else begin
        GitCheck(git_commit_parent(vParent, vCommit, aParentIdx));
        ShowDiffBetweenEx(dwCommit, dwCommit, git_commit_id(vParent), git_commit_id(vCommit), '', '', aPath, aFull)
      end;

    finally
      if vParent <> nil then
        git_commit_free(vParent);
      git_commit_free(vCommit);
    end;
  end;


  procedure TGitRepository.ShowDiffBetween(aCommit1, aCommit2 :PGitCommit; const aPath :TString; aFull :Boolean);
  begin
    ShowDiffBetweenEx(dwCommit, dwCommit, git_commit_id(aCommit1), git_commit_id(aCommit2), '', '', aPath, aFull);
  end;



  procedure TGitRepository.ShowDiffBetweenEx(aWhat1, aWhat2 :TDiffWhat; aOID1, aOID2 :PGitOid; const aCaption1, aCaption2 :TString; const aPath :TString; aFull :Boolean);
  var
    vExchanged :Boolean;

    procedure LocExchange;
    var
      vTmp1 :TDiffWhat;
    begin
      vTmp1 := aWhat2;
      aWhat2 := aWhat1;
      aWhat1 := vTmp1;

      PtrExchange(aOID1, aOID2);

      vExchanged := True;
    end;

  var
    vVCAPI :IVisCompAPI;
    vCom1, vCom2 :PGitCommit;
    vTreeA, vTreeB :PGitTree;
    vDiff :PGitDiff;
    vOpts :TGitDiffOptions;
    vContentCallback :IVCContentCallback;
  begin
    vVCAPI := GetVisualCompareAPI;

    FDiffList1 := vVCAPI.CreateFileList;
    FDiffList2 := vVCAPI.CreateFileList;

    vContentCallback := TContentCallback.Create(Self);
    FDiffList1.SetContentCallback(vContentCallback);
    FDiffList2.SetContentCallback(vContentCallback);

    vExchanged := False;
    vCom1 := nil; vCom2 := nil; vTreeA := nil; vTreeB := nil; vDiff := nil;
    try
      FillZero(vOpts, Sizeof(vOpts));
      vOpts.version := 1;
      vOpts.flags := GIT_DIFF_NORMAL or GIT_DIFF_INCLUDE_UNTRACKED or GIT_DIFF_RECURSE_UNTRACKED_DIRS {or GIT_DIFF_INCLUDE_CASECHANGE} or IntIf(aFull, GIT_DIFF_INCLUDE_UNMODIFIED, 0);
      vOpts.ignore_submodules := uint(-1);

      if (aWhat1 = dwWorkdir) or (aWhat2 = dwWorkdir) then begin
        if aWhat1 = dwWorkdir then
          LocExchange;
        if aWhat1 = dwWorkdir then
          Wrong;

        if aWhat1 = dwCommit then begin
          { Commit <> WorkDir }
          GitCheck(git_commit_lookup(vCom1, FRepo, aOID1));
          GitCheck(git_commit_tree(vTreeA, vCom1));

          GitCheck(git_diff_tree_to_workdir(vDiff, FRepo, vTreeA, @vOpts));

          FDiffList1.SetTag(PWideChar(GetOIDToStr(aOID1^)));
          FDiffList2.SetTag('');
        end else
        begin
          { Index <> Workdir }
          Sorry;
        end;

      end else
      if (aWhat1 = dwIndex) or (aWhat2 = dwIndex) then begin
        if (aWhat1 = dwIndex) and (aWhat2 = dwCommit) then
          LocExchange;

        if aWhat1 = dwCommit then begin
          { Commit <> Index }
          Sorry;
        end else
        begin
          { Index <> Index }
          Sorry;
        end;

      end else
      begin
        { Commit <> Commit }
        if aOID1 <> nil then begin
          GitCheck(git_commit_lookup(vCom1, FRepo, aOID1));
          GitCheck(git_commit_tree(vTreeA, vCom1));
        end;

        if aOID2 <> nil then begin
          GitCheck(git_commit_lookup(vCom2, FRepo, aOID2));
          GitCheck(git_commit_tree(vTreeB, vCom2));
        end;

        GitCheck(git_diff_tree_to_tree(vDiff, FRepo, vTreeA, vTreeB, @vOpts));

        FDiffList1.SetTag(PWideChar(GetOIDToStr(aOID1^)));
        FDiffList2.SetTag(PWideChar(GetOIDToStr(aOID2^)));
      end;

      FDiffMask := TWildcard.Create('', aPath);
      try
        FDiffCount := 0;
        FDiffFile := '';

//      GitCheck(git_diff_print(vDiff, GIT_DIFF_FORMAT_PATCH_HEADER, GitDiffLineCallback, Self));
        GitCheck(git_diff_foreach(vDiff, GitDiffFileCallback, nil, nil, nil, Self));

      finally
        FreeObj(FDiffMask);
      end;

    finally
      if vDiff <> nil then
        git_diff_free(vDiff);
      if vTreeA <> nil then
        git_tree_free(vTreeA);
      if vTreeB <> nil then
        git_tree_free(vTreeB);
      if vCom1 <> nil then
        git_commit_free(vCom1);
      if vCom2 <> nil then
        git_commit_free(vCom2);
    end;

    if vExchanged then
      PtrExchange(FDiffList1, FDiffList2);

    if aCaption1 <> '' then
      FDiffList1.SetRoot(PWideChar(aCaption1 + ':'));
    if aCaption2 <> '' then
      FDiffList2.SetRoot(PWideChar(aCaption2 + ':'));

    if (aPath <> '') and (FDiffFile <> '') then
      vVCAPI.CompareFiles( vContentCallback.GetRealFileName(FDiffList1, '', PTChar(FDiffFile)), vContentCallback.GetRealFileName(FDiffList2, '', PTChar(FDiffFile)), 0 )
    else
      vVCAPI.CompareFileLists(FDiffList1, FDiffList2, 0);

    FDiffList1 := nil;
    FDiffList2 := nil;
  end;

 {-----------------------------------------------------------------------------}

(*
  procedure TGitRepository.ShowHistory(const AFolder :TString);
  var
    vOID :TGitOid;
    vWalker :PGitRevwalk;
    vCommit :PGitCommit;
    vParents :Integer;
    vAuthor :PGitSignature;
    vMessage :TString;
    vHistory :TObjList;
  begin
    vHistory := TObjList.Create;
    try
      GitCheck(git_revwalk_new(vWalker, FRepo));
      try
        GitCheck(git_revwalk_push_head(vWalker));

        FillZero(vOID, SizeOf(vOID));
        while git_revwalk_next(@vOID, vWalker) = 0 do begin
          GitCheck(git_commit_lookup(vCommit, FRepo, @vOID));
          try
            vParents := git_commit_parentcount(vCommit);
            vAuthor := git_commit_author(vCommit);
            vMessage := Trim(UTF8ToWide(git_commit_message(vCommit)));

            vHistory.Add( TGitCommit.Create(vOID, vParents, GitTimeToDateTime(vAuthor.when), UTF8ToWide(vAuthor.name), UTF8ToWide(vAuthor.email), vMessage) );
          finally
            git_commit_free(vCommit);
          end;
        end;

      finally
        git_revwalk_free(vWalker);
      end;

      Assert(Assigned(ShowHistDlg));
      ShowHistDlg(Self, vHistory);

    finally
      FreeObj(vHistory);
    end;
  end;
*)

  procedure TGitRepository.ShowHistory(const aPath :TString);
  var
    vOpts :TGitDiffOptions;
    vPathSpec :PGitPathspec;


    function LocMatchSpec(aCommit :PGitCommit) :Boolean;
    var
      vTree :PGitTree;
    begin
      GitCheck(git_commit_tree(vTree, aCommit));
      try
        Result := git_pathspec_match_tree(nil, vTree, GIT_PATHSPEC_NO_MATCH_ERROR, vPathspec) = 0;
      finally
        git_tree_free(vTree);
      end;
    end;


    function LocMatchWithParents(aCommit :PGitCommit; aParentIdx :Integer) :Boolean;
    var
      vParent :PGitCommit;
      vTreeA, vTreeB :PGitTree;
      vDiff :PGitDiff;
    begin
      vParent := nil; vTreeA := nil; vTreeB := nil; vDiff := nil;
      try
        GitCheck(git_commit_parent(vParent, aCommit, aParentIdx));
        GitCheck(git_commit_tree(vTreeA, vParent));
        GitCheck(git_commit_tree(vTreeB, aCommit));

        GitCheck(git_diff_tree_to_tree(vDiff, FRepo, vTreeA, vTreeB, @vOpts));

        Result :=  git_diff_num_deltas(vDiff) > 0;

      finally
        if vDiff <> nil then
          git_diff_free(vDiff);
        if vTreeA <> nil then
          git_tree_free(vTreeA);
        if vTreeB <> nil then
          git_tree_free(vTreeB);
        if vParent <> nil then
          git_commit_free(vParent);
      end;
    end;


    function LocMatchPath(aCommit :PGitCommit; aParents :Integer) :Boolean;
    var
      i :Integer;
    begin
      if aParents = 0 then
        Result := LocMatchSpec(aCommit)
      else begin
        for i := 0 to aParents -1 do
          if LocMatchWithParents(aCommit, i) then
            Exit(True);
        Result := False;
      end;
    end;

  var
    vOID :TGitOid;
    vWalker :PGitRevwalk;
    vPath :TString;
    vAPath :TAnsiStr;
    vPPath :PAnsiChar;
    vCommit :PGitCommit;
    vParents :Integer;
    vAuthor :PGitSignature;
    vMessage :TString;
    vHistory :TObjList;
  begin
    vHistory := TObjList.Create;
    try
      vWalker := nil; vPathSpec := nil;
      try
        FillZero(vOpts, Sizeof(vOpts));
        vOpts.version := 1;
        vOpts.flags := GIT_DIFF_IGNORE_CASE;
        vOpts.ignore_submodules := uint(-1);
        vOpts.context_lines := 3;

        if aPath <> '' then begin
          vPath := Copy(aPath, Length(FWorkDir) + 1, MaxInt);
          if vPath <> '' then begin
            vAPath := FileToGIT(vPath);
            vPPath := PAnsiChar(vAPath);
            vOpts.pathspec.count := 1;
            vOpts.pathspec.strings := Pointer(@vPPath);
            GitCheck(git_pathspec_new(vPathSpec, @vOpts.pathspec));
          end;
        end;

        GitCheck(git_revwalk_new(vWalker, FRepo));
        GitCheck(git_revwalk_push_head(vWalker));

        FillZero(vOID, SizeOf(vOID));
        while git_revwalk_next(@vOID, vWalker) = 0 do begin
          GitCheck(git_commit_lookup(vCommit, FRepo, @vOID));
          try
            vParents := git_commit_parentcount(vCommit);

            if vPathSpec <> nil then
              if not LocMatchPath(vCommit, vParents) then
                Continue;

            vAuthor := git_commit_author(vCommit);
            vMessage := Trim(UTF8ToWide(git_commit_message(vCommit)));

            vHistory.Add( TGitCommit.Create(vOID, vParents, GitTimeToDateTime(vAuthor.when), UTF8ToWide(vAuthor.name), UTF8ToWide(vAuthor.email), vMessage) );
          finally
            git_commit_free(vCommit);
          end;
        end;

      finally
        if vPathSpec <> nil then
          git_pathspec_free(vPathSpec);
        if vWalker <> nil then
          git_revwalk_free(vWalker);
      end;

      Assert(Assigned(ShowHistDlg));
      ShowHistDlg(Self, vPath, vHistory);

    finally
      FreeObj(vHistory);
    end;
  end;


 {-----------------------------------------------------------------------------}

//  procedure TGitRepository.ShowCommit(const AFolder :TString);
//    { ѕоказывает разницу между Head и рабочим каталогом (git status) }
//  var
//    i, n :Integer;
//    vVCAPI :IVisCompAPI;
//    vList1 :IVCFileList;
//    vList2 :IVCFileList;
//    vStatusList :Pointer;
//    vOpts :git_status_options;
//    vPath :TString;
//    vAPath :TAnsiStr;
//    vPPath :PAnsiChar;
//    vItem :PGitStatusEntry;
//    vContentCallback :IVCContentCallback;
//  begin
//    vVCAPI := GetVisualCompareAPI;
//
//    vList1 := vVCAPI.CreateFileList;
//    vList2 := vVCAPI.CreateFileList;
//
//    vContentCallback := TContentCallback.Create(Self);
//    vList1.SetContentCallback(vContentCallback);
//    vList2.SetContentCallback(vContentCallback);
//
//    FillZero(vOpts, SizeOf(vOpts));
//    vOpts.version := 1;
////  vOpts.show := GIT_STATUS_SHOW_INDEX_ONLY; {GIT_STATUS_SHOW_INDEX_ONLY;}
//    vOpts.flags := GIT_STATUS_OPT_INCLUDE_UNTRACKED or GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS or GIT_STATUS_OPT_INCLUDE_UNMODIFIED;
//
//    if AFolder <> '' then begin
//      vPath := Copy(AddBackSlash(AFolder), Length(FWorkDir) + 1, MaxInt);
//      if vPath <> '' then begin
//        vAPath := FileToGIT(RemoveBackSlash(vPath));
//        vPPath := PAnsiChar(vAPath);
//        vOpts.pathspec.count := 1;
//        vOpts.pathspec.strings := Pointer(@vPPath);
//      end;
//    end;
//
//    vList1.SetRoot(PTChar(cGitRoot + vPath));
//    vList2.SetRoot(PTChar(cWorkRoot + vPath));
//
//    vList1.SetTag(cHead);
//    vList2.SetTag('');
//
//    GitCheck(git_status_list_new(vStatusList, FRepo, @vOpts));
//    try
//      n := git_status_list_entrycount(vStatusList);
//      for i := 0 to n - 1 do begin
//        vItem := git_status_byindex(vStatusList, i);
//        if (vItem.head_to_index <> nil) and (vItem.head_to_index.status <> GIT_DELTA_UNMODIFIED) then
//          AddFileDelta(vItem.head_to_index, vList1, vList2, vPath)
//        else
//        if vItem.index_to_workdir <> nil then
//          AddFileDelta(vItem.index_to_workdir, vList1, vList2, vPath);
//      end;
//    finally
//      git_status_list_free(vStatusList);
//    end;
//
//    vVCAPI.CompareFileLists(vList1, vList2, 0);
//
//    vList1 := nil;
//    vList2 := nil;
//  end;


 {-----------------------------------------------------------------------------}

  constructor TGitDiffFile.Create(const aName :TSTring; aSize :TInt64; aStatus :TDiffFileStatus);
  begin
    FName := ExtractFileName(aName);
    FPath := ExtractFilePath(aName);
    FSize := aSize;
    FStatus := aStatus;
  end;


  function TGitDiffFile.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  var
    vDiff2 :TGitDiffFile;
    vPath1, vPath2 :PTChar;
  begin
    vDiff2 := TGitDiffFile(Another);

    vPath1 := PTChar(FPath);
    vPath2 := PTChar(vDiff2.Path);

    Result := 0;
    while (Result = 0) and ((vPath1^ <> #0) or (vPath2^ <> #0)) do
      Result := UpCompareStr(ExtractNextValue(vPath1, ['\']), ExtractNextValue(vPath2, ['\']));

    if Result = 0 then
      Result := UpCompareStr(FName, vDiff2.Name);
  end;


  function TGitDiffFile.GetFileName :TString;
  begin
    Result := AddFileName(FPath, FName);
  end;



  constructor TGitWorkdirStatus.Create(const aFolder :TString);
  begin
    inherited Create;
    FFolder := aFolder;
    FUnstaged := TObjList.Create;
    FStaged := TObjList.Create;
  end;


  destructor TGitWorkdirStatus.Destroy; {override;}
  begin
    FreeObj(FUnstaged);
    FreeObj(FStaged);
    inherited Destroy;
  end;



  function TGitRepository.GetWorkdirStatus(const AFolder :TString) :TGitWorkdirStatus;

    function LocCreateDiff(aDelta :PGitDiffDelta) :TGitDiffFile;
    var
      vName :TString;
      vSize :TInt32;
      vStatus :TDiffFileStatus;
    begin
//    Trace('Status=%d, Flags=%d, Files=%d, %s, %s, Size: %d, %d', [aDelta.status, aDelta.flags, aDelta.nfiles, aDelta.old_file.path, aDelta.new_file.path, aDelta.old_file.Size, aDelta.new_file.Size]);
      vSize := 0; vStatus := dfUnchanged;

      if aDelta.status in [GIT_DELTA_ADDED, GIT_DELTA_UNTRACKED] then begin
        vName := GitToFile(aDelta.new_file.path);
        vSize := aDelta.new_file.size;
        vStatus := dfAdded;
      end else
      if aDelta.status in [GIT_DELTA_DELETED] then begin
        vName := GitToFile(aDelta.old_file.path);
        vSize := aDelta.old_file.size;
        vStatus := dfDeleted;
      end else
      if aDelta.status in [GIT_DELTA_RENAMED] then begin
        Sorry;
      end else
      begin
        vName := GitToFile(aDelta.new_file.path);
        vSize := aDelta.new_file.size;
        vStatus := dfChanged;
      end;

      Result := TGitDiffFile.Create(vName, vSize, vStatus);
    end;

  var
    i, n :Integer;
    vStatusList :Pointer;
    vOpts :git_status_options;
    vPath :TString;
    vAPath :TAnsiStr;
    vPPath :PAnsiChar;
    vItem :PGitStatusEntry;
    vDirStatus :TGitWorkdirStatus;
  begin
    vDirStatus := TGitWorkdirStatus.Create(AFolder);
    try
      FillZero(vOpts, SizeOf(vOpts));
      vOpts.version := 1;
      vOpts.flags := GIT_STATUS_OPT_INCLUDE_UNTRACKED or GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS {or GIT_STATUS_OPT_INCLUDE_UNMODIFIED};

      if AFolder <> '' then begin
        vPath := Copy(AFolder, Length(FWorkDir) + 1, MaxInt);
        if vPath <> '' then begin
          vAPath := FileToGit(vPath);
          vPPath := PAnsiChar(vAPath);
          vOpts.pathspec.count := 1;
          vOpts.pathspec.strings := Pointer(@vPPath);
        end;
      end;

      GitCheck(git_status_list_new(vStatusList, FRepo, @vOpts));
      try
        n := git_status_list_entrycount(vStatusList);
        for i := 0 to n - 1 do begin
          vItem := git_status_byindex(vStatusList, i);
          if vItem.index_to_workdir <> nil then
            vDirStatus.FUnstaged.Add( LocCreateDiff( vItem.index_to_workdir ) );
          if vItem.head_to_index <> nil then
            vDirStatus.FStaged.Add( LocCreateDiff( vItem.head_to_index ) );
        end;
      finally
        git_status_list_free(vStatusList);
      end;

      vDirStatus.Staged.SortList(True, 0);
      vDirStatus.UnStaged.SortList(True, 0);

      Result := vDirStatus;

    except
      FreeObj(vDirStatus);
      raise;
    end;
  end;


  procedure TGitRepository.PrepareCommit(const AFolder :TString);
  var
    vDirStatus :TGitWorkdirStatus;
  begin
    vDirStatus := GetWorkdirStatus(AFolder);
    try
      ShowCommitDlg(Self, vDirStatus);
    finally
      FreeObj(vDirStatus);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TGitRepository.IndexAddFile(const AFileName :TString);
  var
    vIndex :PGitIndex;
  begin
    GitCheck(git_repository_index(vIndex, FRepo));
    try
      GitCheck(git_index_add_bypath(vIndex, PAnsiChar(FileToGit(AFileName))));
      GitCheck(git_index_write(vIndex));
    finally
      git_index_free(vIndex);
    end;
  end;


  procedure TGitRepository.IndexRemoveFile(const AFileName :TString);
  var
    vIndex :PGitIndex;
  begin
    GitCheck(git_repository_index(vIndex, FRepo));
    try
      GitCheck(git_index_remove_bypath(vIndex, PAnsiChar(FileToGit(AFileName))));
      GitCheck(git_index_write(vIndex));
    finally
      git_index_free(vIndex);
    end;
  end;


  procedure TGitRepository.IndexAddAll(const AFileName :TString);
  var
    vIndex :PGitIndex;
    vPathspec :git_strarray;
    vAPath :TAnsiStr;
    vPPath :PAnsiChar;
  begin
    GitCheck(git_repository_index(vIndex, FRepo));
    try
      vAPath := FileToGIT(AFileName);
      vPPath := PAnsiChar(vAPath);
      vPathspec.count := 1;
      vPathspec.strings := Pointer(@vPPath);

      GitCheck(git_index_add_all(vIndex, @vPathspec, 0, nil, nil));
      GitCheck(git_index_write(vIndex));
    finally
      git_index_free(vIndex);
    end;
  end;


  procedure TGitRepository.IndexReset(const AFileName :TString);
  var
    vHead :PGitObject;
    vPathspec :git_strarray;
    vAPath :TAnsiStr;
    vPPath :PAnsiChar;
  begin
    GitCheck(git_revparse_single(vHead, FRepo, cHead));
    try
      vAPath := FileToGIT(AFileName);
      vPPath := PAnsiChar(vAPath);
      vPathspec.count := 1;
      vPathspec.strings := Pointer(@vPPath);

      GitCheck(git_reset_default(FRepo, vHead, @vPathspec));

    finally
      git_object_free(vHead);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TGitRepository.Commit(const aMessage, aAuthor, aEMail :TString);
  var
    vIndex :PGitIndex;
    vTree :PGitTree;
    vParent :PGitCommit;
    vSign :PGitSignature;
    vOID, vParentID, vNewID :TGitOID;
  begin
    vIndex := nil; vTree := nil; vParent := nil; vSign := nil;
    try
      GitCheck(git_repository_index(vIndex, FRepo));

      FillZero(vOID, SizeOf(vOID));
      GitCheck(git_index_write_tree(vOID, vIndex));
      GitCheck(git_tree_lookup(vTree, FRepo, @vOID));

      FillZero(vParentID, SizeOf(vParentID));
      GitCheck(git_reference_name_to_id(vParentID, FRepo, cHead));
      GitCheck(git_commit_lookup(vParent, FRepo, @vParentID));

      if (aAuthor = '') and (aEMail = '') then
        GitCheck(git_signature_default(vSign, FRepo))
      else
        GitCheck(git_signature_now(vSign, PAnsiChar(WideToUTF8(aAuthor)), PAnsiChar(WideToUTF8(aEMail)) ));

      GitCheck(git_commit_create(
        vNewID,
        FRepo,
        cHead,
        vSign,
        vSign,
        nil,
        PAnsiChar(WideToUTF8(aMessage)),
        vTree,
        1,
        @vParent
      ));

    finally
      if vTree <> nil then
        git_tree_free(vTree);
      if vParent <> nil then
        git_commit_free(vParent);
      if vIndex <> nil then
        git_index_free(vIndex);
      if vSign <> nil then
        git_signature_free(vSign);
    end;
  end;


  procedure TGitRepository.AmendCommit(const aMessage, aAuthor, aEMail :TString);
  var
    vIndex :PGitIndex;
    vTree :PGitTree;
    vCommit :PGitCommit;
    vSign :PGitSignature;
    vOID, vCommitID, vNewID :TGitOID;
  begin
    vIndex := nil; vTree := nil; vCommit := nil; vSign := nil;
    try
      GitCheck(git_repository_index(vIndex, FRepo));

      FillZero(vOID, SizeOf(vOID));
      GitCheck(git_index_write_tree(vOID, vIndex));
      GitCheck(git_tree_lookup(vTree, FRepo, @vOID));

      FillZero(vCommitID, SizeOf(vCommitID));
      GitCheck(git_reference_name_to_id(vCommitID, FRepo, cHead));
      GitCheck(git_commit_lookup(vCommit, FRepo, @vCommitID));

      if (aAuthor = '') and (aEMail = '') then
        GitCheck(git_signature_default(vSign, FRepo))
      else
        GitCheck(git_signature_now(vSign, PAnsiChar(WideToUTF8(aAuthor)), PAnsiChar(WideToUTF8(aEMail)) ));

      GitCheck(git_commit_amend(
        vNewID,
        vCommit,
        cHead,
        vSign,
        vSign,
        nil,
        PAnsiChar(WideToUTF8(aMessage)),
        vTree
      ));

    finally
      if vTree <> nil then
        git_tree_free(vTree);
      if vCommit <> nil then
        git_commit_free(vCommit);
      if vIndex <> nil then
        git_index_free(vIndex);
      if vSign <> nil then
        git_signature_free(vSign);
    end;
  end;



end.


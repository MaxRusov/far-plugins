{$I Defines.inc}

unit FarFMClasses;

interface                    

  uses
    Windows,
    ActiveX,
    ShellAPI,
    MSXML,
    SHDocVw,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    Far_API,  //Plugin3.pas
    FarCtrl,
    FarPlug,
    FarMenu,
    FarDlg,
    FarConfig,

    FarFMCtrl,
    FarFmCalls,
    FarFMCopyDlg,
    FarFMFindDlg,
    FarFMLoginDlg;



 {$ifdef Far3}
 {$else}
  const
    PMFLAGS_FULLSCREEN       = $0000000000000001;
    PMFLAGS_DETAILEDSTATUS   = $0000000000000002;
    PMFLAGS_ALIGNEXTENSIONS  = $0000000000000004;
    PMFLAGS_CASECONVERSION   = $0000000000000008;
 {$endif Far3}


  const
    cmAddArtist = 1;
    cmAddUser   = 2;
    cmNextPage  = 3;
    cmUpdate    = 4;

  type
    TFarPanelMode = class(TBasis)
    public
      constructor CreateEx(AFlags :Integer; const ATitles :array of TMessages; const ATypes, AWidths, AStTypes, AStWidths :TString);
      destructor Destroy; override;

    private
      FTitles   :PPCharArray;
      FTypes    :TString;
      FWidths   :TString;
      FStTypes  :TString;
      FStWidths :TString;
      FFlags    :Integer;
    end;

    TFarPanelModes = class(TObjList)
    public
      destructor Destroy; override;
      procedure SetModes(const AModes :array of TFarPanelMode);
      function AllocateModes :PPanelModeArray;

    private
      FModes :PPanelModeArray;
    end;

 {-----------------------------------------------------------------------------}

  type
    TFarPanelLabel = class(TBasis)
    private
      FKey      :Integer;
      FText     :TString;
      FLongText :TString;
    end;

    TFarPanelLabels = class(TObjList)
    public
      destructor Destroy; override;
      procedure SetLabels(const ALabels :array of TFarPanelLabel);
      function AllocateTitles :PKeyBarTitles;
    private
      FTitles :TKeyBarTitles;
    end;


 {-----------------------------------------------------------------------------}

  type
    TFarFmLevel = (
      fflNone,
      fflRoot,

      fflArtists,
      fflArtist,
      fflArtistTracks,
      fflArtistAlbums,
      fflArtistSimilar,
      fflAlbum,

      fflAlbums,

      fflUsers,
      fflUser,
      fflUserPlaylists,
      fflUserPlaylist,
      fflUserArtists,
      fflUserAlbums,
      fflUserTracks,

      fflAccounts
    );

  type
    TFarFmPanel = class;

    TAsyncCommand = class(TBasis)
    public
      constructor CreateEx(APanel :TFarFmPanel; ACmd :Integer; AParam :TIntPtr);

    private
      FPanel    :TFarFmPanel;
      FCmd      :Integer;
      FParam    :TIntPtr;
      FRevision :Integer;

    public
      property Panel :TFarFmPanel read FPanel;
      property Cmd :Integer read FCmd;
      property Param :TIntPtr read FParam;
    end;

    TFarFmPanel = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure GetInfo(var AInfo :TOpenPanelInfo);
      function GetItems(AMode :Integer; var AItems :PPluginPanelItemArray; var ACount :Integer) :boolean;
      procedure FreeItems(AItems :PPluginPanelItemArray; ACount :Integer);
      function SetDirectory(AMode :Integer; ADir :PFarChar) :Boolean;
      function MakeDirectory(AMode :Integer; var ADir :TString) :Boolean;
      function GetFiles(AMode :Integer; AItems :PPluginPanelItem; ACount :Integer; AMove :boolean; var ADestPath :TString) :Boolean;
      function DeleteFiles(AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean;
      function ProcessInput(AKey :Integer) :Boolean;

      procedure Navigate(AMode :Integer; const AFolder :TString);
      function RunCommand(ACmd :Integer; AParam :TIntPtr) :Boolean;

    private
      FLevel   :TFarFmLevel;
      FCurrent :TString;
      FCurInfo :TString;

      FStack   :TStringList;
      FItems   :TObjList;

      FTitle   :TString;
      FPath    :TString;

      FKeyBar  :TFarPanelLabels;
      FModes   :TFarPanelModes;
      FDefMode :Integer;
      FDefSort :Integer;

      FProgressTick :DWORD;
      FProgressTitle :TString;
      FProgressMess :TString;
      FProgressPercent :Integer;

      procedure UpdatePanel(ARefill :Boolean = False);
      procedure FillLevel;
      procedure TrackLoad(APage :Integer);
      procedure AlbumLoad(AList :TObjList; const AArtist, AAlbum :TString);
//    procedure AddImageItem(const AInfo :IXMLDOMDocument; const ANodes, AName :TString; AList :TObjList);
//    procedure AddURLItem(const AInfo :IXMLDOMDocument; const ANode, AName, ALabel :TString; AList :TObjList);

      procedure UserArtistsLoad(APage :Integer);
      procedure UserAlbumsLoad(APage :Integer);
      procedure UserTrackLoad(APage :Integer);

      function DropURLCache :Boolean;
      function AddArtistPrompt(var AName :TString) :Boolean;
      function AddUserPrompt(var AName :TString) :Boolean;
      procedure CopyDownloadCallback(const AURL :TString; ASize :TIntPtr);
      function CopyFilesTo(AItems :PPluginPanelItem; ACount :Integer; const AFolder :TString) :Boolean;
    end;


  type
    TFarFm = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure VKAuthorize;
      function VKCallsBegin :Boolean;
      procedure VKCallsEnd;
      procedure VkCallsProgress(const ATitle, AMess :TString; APercent :Integer);
      function FindTrackURL(const Artist, Track :TString; AForce :Boolean = True) :TString;
      function DropTrackURL(const Artist, Track :TString) :Boolean;

    private
      FArtists  :TStringList;
      FUsers    :TStringList;

      FVKAuth   :Boolean;
      FVKLock   :Integer;
      FScreen   :THandle;

      FTrackCache :TObjList;

      FResolved :Integer;

      procedure SaveLocalList(const AName :TString; AList :TStringList);
      procedure RestoreLocalList(const AName :TString; AList :TStringList);
      procedure SaveTrackCache;
      procedure RestoreTrackCache;
      procedure StoreVkToken(AStore :Boolean);

      procedure ShowProgress(const ATitle, AName :TString; APercent :Integer);
      function CheckInterrupt :Boolean;

    public
      property Artists :TStringList read FArtists;
      property Users :TStringList read FUsers;
    end;


  var
    FarFm :TFarFM;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


(*
  function ShellOpen(const AName :TString) :Boolean;
  var
    vInfo :TShellExecuteInfo;
  begin
    FillChar(vInfo, SizeOf(vInfo), 0);
    vInfo.cbSize        := SizeOf(vInfo);
    vInfo.fMask         := 0;
    vInfo.Wnd           := 0;
    vInfo.lpFile        := PTChar(AName);
    vInfo.lpParameters  := nil;
    vInfo.lpDirectory   := nil;
    vInfo.nShow         := SW_Show;
    Result := ShellExecuteEx(@vInfo);
  end;
*)

  function ExtractURLFileExtension(const AURL :TString) :TString;
  begin
    Result := ExtractFileExtension(ExtractLastWord(AURL, '/'));
  end;


  function TrimDots(const AName :TString) :TString;
  begin
    Result := AName;
    while (Result <> '') and CharInSet(Result[length(Result)], ['.', ' ']) do
      Delete(Result, length(Result), 1);
  end;


  function AddFileExtension(const AName, AExt :TString) :TString;
  begin
    Result := TrimDots(Trim(AName));
    if AExt <> '' then
      Result := Result + '.' + AExt;
  end;


  const
    cWrongFileNameChars = [':', '\', '/', '*', '?', '"', '>', '<', '|'];
//  cWrongFilePathChars = ['/', '*', '?', '"', '>', '<', '|'];

  function CleanFileName(const AFileName :TString; AReplaceChar :TChar = '_') :TString;
  begin
    Result := TrimDots(Trim(StrReplaceChars(AFileName, cWrongFileNameChars, AReplaceChar)));
  end;


  function FormatLength(ASec :Integer) :TString;
  begin
    Result := Format('%2d:%.2d', [ASec div 60, ASec mod 60]);
  end;


  function FormatTrackFileName(const ATrack, AArtist, AAlbum, AExt :TString; AIndex :Integer) :TString;
  begin
    {!!! Настройка}
    Result := Format('%d - %s', [AIndex, ATrack]);
    Result := AddFileExtension(CleanFileName(Result), AExt);
  end;


  function ClearTags(const AStr :TString) :TString;
  var
    I, L, B :Integer;
  begin
    Result := AStr;
    I := 1;
    L := length(Result);
    while I < L do begin
      if Result[I] = '<' then begin
        B := I;
        Inc(I);
        while I < L do begin
          if Result[I] = '>' then begin
            Inc(I);
            Delete(Result, B, I - B);
            L := length(Result);
            I := B;
            Break;
          end else
           Inc(I);
        end;
      end else
      if Result[I] = #10 then begin
        Insert(#13, Result, I);
        Inc(L);
        Inc(I, 2);
      end else
        Inc(I);
    end;
    Result := StrReplace(Result, '&quot;', '"', [rfReplaceAll, rfIgnoreCase]);
  end;

  
 {-----------------------------------------------------------------------------}
 { TFarPanelMode                                                               }
 {-----------------------------------------------------------------------------}

  function NewPanelMode(AFlags :Integer; const ATitles :array of TMessages; const ATypes, AWidths :TString;
    const AStTypes :TString = ''; const AStWidths :TString = '') :TFarPanelMode;
  begin
    Result := TFarPanelMode.CreateEx(AFlags, ATitles, ATypes, AWidths, AStTypes, AStWidths)
  end;


  constructor TFarPanelMode.CreateEx(AFlags :Integer; const ATitles :array of TMessages; const ATypes, AWidths, AStTypes, AStWidths :TString);
  begin
    inherited Create;
    FFlags := AFlags;
    FTypes := ATypes;
    FWidths := AWidths;
    FStTypes := AStTypes;
    FStWidths := AStWidths;
    FTitles := NewStrsI(ATitles);
  end;


  destructor TFarPanelMode.Destroy; {override;}
  begin
    DisposeStrs(FTitles);
    inherited Destroy;
  end;


  destructor TFarPanelModes.Destroy; {override;}
  begin
    MemFree(FModes);
    inherited Destroy;
  end;


  procedure TFarPanelModes.SetModes(const AModes :array of TFarPanelMode);
  var
    I :Integer;
  begin
    FreeAll;
    for I := 0 to High(AModes) do
      Add(AModes[I]);
  end;


  function TFarPanelModes.AllocateModes :PPanelModeArray;
  var
    I :Integer;
  begin
    MemFree(FModes);
    if Count > 0 then begin
      FModes := MemAllocZero(Count * SizeOf(TPanelMode));
      for I := 0 to Count - 1 do
        if Items[I] <> nil then
          with FModes[I], TFarPanelMode(Items[I]) do begin
            ColumnTitles := FTitles;
            ColumnTypes  := PTChar(FTypes);
            ColumnWidths := PTChar(FWidths);
            StatusColumnTypes := PTChar(FStTypes);
            StatusColumnWidths := PTChar(FStWidths);
           {$ifdef Far3}
            Flags := FFlags;
           {$else}
            FullScreen := byte(FFlags and PMFLAGS_FULLSCREEN <> 0);
            DetailedStatus := byte(FFlags and PMFLAGS_DETAILEDSTATUS <> 0);
            AlignExtensions := byte(FFlags and PMFLAGS_ALIGNEXTENSIONS <> 0);
            CaseConversion := byte(FFlags and PMFLAGS_CASECONVERSION <> 0);
           {$endif Far3}
          end;
    end;
    Result := FModes;
  end;


 {-----------------------------------------------------------------------------}
 { TFarPanelLabel                                                              }
 {-----------------------------------------------------------------------------}

  function NewFarLabel(AKey :Integer; const AText :TString = ''; const ALongText :TString = '') :TFarPanelLabel;
  begin
    Result := TFarPanelLabel.Create;
    Result.FKey := AKey;
    Result.FText := AText;
    Result.FLongText := ALongText;
  end;


  destructor TFarPanelLabels.Destroy; {override;}
  begin
   {$ifdef Far3}
    MemFree(FTitles.Labels);
   {$else}
   {$endif Far3}
    inherited Destroy;
  end;

  procedure TFarPanelLabels.SetLabels(const ALabels :array of TFarPanelLabel);
  var
    I :Integer;
  begin
    FreeAll;
    for I := 0 to High(ALabels) do
      Add(ALabels[I]);
  end;


 {$ifdef Far3}
  procedure FarKeyToKeyRec(AKey :Integer; var AKeyRec :TFarKey);
  var
    vEvent :TKeyEventRecord;
  begin
    FillZero(AKeyRec, SizeOf(AKeyRec));
    if FarKeyToKeyEvent(AKey, vEvent) then begin
      AKeyRec.VirtualKeyCode := vEvent.wVirtualKeyCode;
      AKeyRec.ControlKeyState := vEvent.dwControlKeyState;
    end;
  end;
 {$endif Far3}


  function TFarPanelLabels.AllocateTitles :PKeyBarTitles;
 {$ifdef Far3}
  var
    I :Integer;
  begin
    MemFree(FTitles.Labels);
    FTitles.CountLabels := Count;
    if Count > 0 then begin
      FTitles.Labels := MemAllocZero(Count * SizeOf(TKeyBarLabel));
      for I := 0 to Count - 1 do
        with FTitles.Labels[I], TFarPanelLabel(Items[I]) do begin
          FarKeyToKeyRec(FKey, Key);
          Text := PTChar(FText);
          LongText := PTChar(FLongText);
        end;
    end;
    Result := @FTitles;
 {$else}
  var
    I, J :Integer;
  begin
    Result := nil;
    if Count > 0 then begin
      for I := 0 to Count - 1 do
        with TFarPanelLabel(Items[I]) do begin
          J := (FKey and not (KEY_CTRL + KEY_ALT + KEY_SHIFT)) - KEY_F1;
          if (J >= 0) and (J <= 11) then begin
            if FKey and (KEY_CTRL + KEY_ALT + KEY_SHIFT) = 0 then
              FTitles.Titles[J] := PTChar(FText);
            if FKey and (KEY_CTRL + KEY_ALT + KEY_SHIFT) = KEY_CTRL then
              FTitles.CtrlTitles[J] := PTChar(FText);
            if FKey and (KEY_CTRL + KEY_ALT + KEY_SHIFT) = KEY_ALT then
              FTitles.AltTitles[J] := PTChar(FText);
            if FKey and (KEY_CTRL + KEY_ALT + KEY_SHIFT) = KEY_SHIFT then
              FTitles.ShiftTitles[J] := PTChar(FText);
          end;
        end;
      Result := @FTitles;
    end;
 {$endif Far3}
  end;


 {-----------------------------------------------------------------------------}
 { TAsyncCommand                                                               }
 {-----------------------------------------------------------------------------}

  constructor TAsyncCommand.CreateEx(APanel :TFarFmPanel; ACmd :Integer; AParam :TIntPtr);
  begin
    FPanel    := APanel;
    FCmd      := ACmd;
    FParam    := AParam;
    FRevision := 0;
  end;


 {-----------------------------------------------------------------------------}
 { TFarFmItem                                                                  }
 {-----------------------------------------------------------------------------}

  type
    TFarFmItem = class(TNamedObject)
    public
      procedure MakePanelItem(var AItem :TPluginPanelItem); virtual;
      procedure GetFileView(AMode :Integer; var APath :TString); virtual;
      function CanCopy :Boolean; virtual;
      procedure CopyFileTo(const AFileName :TString); virtual;
      function GetFileName :TString; virtual;
    public
      property FileName :TString read GetFileName;
    end;


  procedure TFarFmItem.MakePanelItem(var AItem :TPluginPanelItem); {virtual;}
  begin
    AItem.{$ifdef Far3}FileName{$else}FindData.cFileName{$endif Far3}
      := StrNew(FName);
    Pointer(AItem.UserData) := Self;
  end;


  procedure FreePanelItem(var AItem :TPluginPanelItem);
  begin
    StrDispose(AItem.{$ifdef Far3}FileName{$else}FindData.cFileName{$endif Far3});
    if AItem.CustomColumnData <> nil then
      DisposeStrs(AItem.CustomColumnData);
  end;


  procedure TFarFmItem.GetFileView(AMode :Integer; var APath :TString); {virtual;}
  begin
    Sorry;
  end;


  function TFarFmItem.CanCopy :Boolean; {virtual;}
  begin
    Result := False;
  end;

  procedure TFarFmItem.CopyFileTo(const AFileName :TString); {virtual;}
  begin
    Sorry;
  end;


  function TFarFmItem.GetFileName :TString; {virtual;}
  begin
    Result := CleanFileName(Name);
  end;

 {---------------------------------------}

  type
    TFarFmFolder = class(TFarFmItem)
    public
      constructor CreateEx(const AName, AInfo :TString; ALevel :TFarFmLevel);
      procedure MakePanelItem(var AItem :TPluginPanelItem); override;
    private
      FInfo  :TString;
      FLevel :TFarFmLevel;
    public
      property Info :TString read FInfo;
      property Level :TFarFmLevel read FLevel;
    end;


  constructor TFarFmFolder.CreateEx(const AName, AInfo :TString; ALevel :TFarFmLevel);
  begin
    CreateName(AName);
    FLevel := ALevel;
    FInfo := AInfo;
  end;


  procedure TFarFmFolder.MakePanelItem(var AItem :TPluginPanelItem); {override;}
  begin
    inherited MakePanelItem(AItem);
    AItem.{$ifdef Far3}FileAttributes{$else}FindData.dwFileAttributes{$endif Far3}
     := FILE_ATTRIBUTE_DIRECTORY;
  end;


 {---------------------------------------}

  type
    TFarFmCommand = class(TFarFmItem)
    public
      constructor CreateEx(const AName :TString; ACmd :Integer; AParam :TIntPtr);

    private
      FCmd   :Integer;
      FParam :TIntPtr;
    end;


  constructor TFarFmCommand.CreateEx(const AName :TString; ACmd :Integer; AParam :TIntPtr);
  begin
    CreateName(AName);
    FCmd := ACmd;
    FParam := AParam;
  end;

 {---------------------------------------}

  type
    TFarFmURLItem = class(TFarFmItem)
    public
      constructor CreateEx(const AName, AURL, ALabel :TString);
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;
    public
      FURL   :TString;
      FLabel :TString;
    end;

  constructor TFarFmURLItem.CreateEx(const AName, AURL, ALabel :TString);
  begin
    CreateName(AddFileExtension(AName, cHTMLExt));
    FURL := AURL;
    FLabel := ALabel;
  end;

  procedure TFarFmURLItem.GetFileView(AMode :Integer; var APath :TString); {override;}
  var
    vName :TString;
  begin
    vName := AddFileName(APath, FileName);
    CopyFileTo(vName);
  end;

  function TFarFmURLItem.CanCopy :Boolean; {override;}
  begin
    Result := True;
  end;

  procedure TFarFmURLItem.CopyFileTo(const AFileName :TString); {override;}
  var
    vHTML :TString;
  begin
    vHTML := Format(cRedirectHTML, [FURL, FLabel]);
    StrToFile(AFileName, vHTML);
  end;

 {---------------------------------------}

  type
    TFarInfoItem = class(TFarFmItem)
    public
      constructor CreateEx(const AName, AText :TString);
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;
    public
      FText  :TString;
    end;


  constructor TFarInfoItem.CreateEx(const AName, AText :TString);
  begin
    CreateName(AddFileExtension(AName, cTXTExt));
    FText := AText;
  end;

  procedure TFarInfoItem.GetFileView(AMode :Integer; var APath :TString); {override;}
  var
    vName :TString;
  begin
    vName := AddFileName(APath, FileName);
    CopyFileTo(vName);
  end;

  function TFarInfoItem.CanCopy :Boolean; {override;}
  begin
    Result := True;
  end;

  procedure TFarInfoItem.CopyFileTo(const AFileName :TString); {override;}
  begin
    StrToFile(AFileName, FText);
  end;


 {---------------------------------------}

  type
    TFarFmImageItem = class(TFarFmItem)
    public
      constructor CreateEx(const AName, AURL :TString);
      procedure GetFileView(AMode :Integer; var APath :TString); override;

    public
      FURL :TString;

      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;
    end;


  constructor TFarFmImageItem.CreateEx(const AName, AURL :TString);
  var
    vName :TString;
  begin
    if AName = '' then
      vName := ExtractLastWord(AURL, '/')
    else
      vName := AddFileExtension(AName, ExtractURLFileExtension(AURL));
    CreateName(vName);
    FURL := AURL;
  end;

  procedure TFarFmImageItem.GetFileView(AMode :Integer; var APath :TString); {override;}
  var
    vName :TString;
  begin
    vName := AddFileName(APath, FileName);
    HTTPDownload(FURL, vName);
  end;

  function TFarFmImageItem.CanCopy :Boolean; {override;}
  begin
    Result := True;
  end;

  procedure TFarFmImageItem.CopyFileTo(const AFileName :TString); {override;}
  begin
    HTTPDownload(FURL, AFileName);
  end;


 {---------------------------------------}

  type
    TFarFmAlbum = class(TFarFmFolder)
    public
      constructor CreateEx(const AName, AArtist :TString);
      procedure MakePanelItem(var AItem :TPluginPanelItem); override;
    end;


  constructor TFarFmAlbum.CreateEx(const AName, AArtist :TString);
  begin
    inherited CreateEx(AName, AArtist, fflAlbum);
  end;


  procedure TFarFmAlbum.MakePanelItem(var AItem :TPluginPanelItem); {override;}
  begin
    inherited MakePanelItem(AItem);
    AItem.CustomColumnNumber := 1;
    AItem.CustomColumnData := NewStrs([FInfo]);
  end;


 {---------------------------------------}

  type
    TFarFmPlaylistItem = class(TFarFmItem)
    public
      constructor CreateEx(const AName :TString; const ATracks :TStringArray2);
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;

    public
      FTracks  :TStringArray2;

      procedure ResolveTracks;
      procedure SavePlaylistTo(const AFileName :TString; ALocal :Boolean);
    end;


  constructor TFarFmPlaylistItem.CreateEx(const AName :TString; const ATracks :TStringArray2);
  begin
    CreateName(AddFileExtension(AName, cPlaylistExt));
    FTracks := ATracks;
  end;


  procedure TFarFmPlaylistItem.GetFileView(AMode :Integer; var APath :TString); {override;}
  var
    vName :TString;
  begin
    {!!!CheckMode}
    try
      ResolveTracks;
    except
      on E :ECtrlBreak do
        {Continue};
      on E :Exception do
        raise;
    end;

    vName := AddFileName(APath, FileName);
    SavePlaylistTo(vName, False);
  end;


  function TFarFmPlaylistItem.CanCopy :Boolean; {override;}
  begin
    Result := True;
  end;


  procedure TFarFmPlaylistItem.CopyFileTo(const AFileName :TString); {override;}
  begin
    SavePlaylistTo(AFileName, True);
  end;


  procedure TFarFmPlaylistItem.SavePlaylistTo(const AFileName :TString; ALocal :Boolean);
  var
    I, N, vLen :Integer;
    vList, vURL, vExt :TString;
  begin
    {!!!Unicode}
    vList := cM3UHeader;
    N := length(FTracks);
    for I := 0 to N - 1 do begin
      vURL := FarFm.FindTrackURL(FTracks[I, 1], FTracks[I, 0], False);
      if ALocal then begin
        vExt := ExtractURLFileExtension(vURL);
        if vExt = '' then
          vExt := cMP3Ext;
        vURL := FormatTrackFileName(FTracks[I, 0], FTracks[I, 1], '', vExt, I + 1);
      end;

      vLen := 0;
      if length(FTracks[I]) > 2 then
        vLen := Str2IntDef(FTracks[I, 2], 0);

      vList := AppendStrCh(vList, Format(cM3UExtInfo, [vLen, FTracks[I, 1], FTracks[I, 0]]), CRLF);
      vList := AppendStrCh(vList, vURL, CRLF);
    end;
    StrToFile(AFileName, vList, sffAnsi);
  end;


  procedure TFarFmPlaylistItem.ResolveTracks;
  var
    I, N :Integer;
    vLight :Boolean;
  begin
    FarFm.VKCallsBegin;
    try
      N := length(FTracks);
      vLight := True;
      for I := 0 to N - 1 do begin
        if vLight then
          if FarFm.FindTrackURL(FTracks[I, 1], FTracks[I, 0], False) = '' then begin
            FarFm.VKAuthorize;
            vLight := False;
          end;

        if not vLight then begin
          {!!!Localize}
          FarFm.VkCallsProgress('Find tracks', FTracks[I, 0], MulDiv(I, 100, N));
          if FarFm.CheckInterrupt then
            CtrlBreakException;
          FarFm.FindTrackURL(FTracks[I, 1], FTracks[I, 0], True);
        end;
      end;
    finally
      FarFm.VKCallsEnd;
    end;
  end;


 {---------------------------------------}

  type
    TFarFmTrackItem = class(TFarFmItem)
    public
      constructor CreateEx(const AName, AArtist :TString; ALength :Integer; AIndex :Integer);
      procedure MakePanelItem(var AItem :TPluginPanelItem); override;
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function GetFileName :TString; override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;

      procedure UnResolveTrack;

    private
      FArtist :TString;
      FIndex  :Integer;
      FLength :Integer;
      FURL    :TString;

      procedure ResolveTrack(AForce :Boolean);
    end;


  constructor TFarFmTrackItem.CreateEx(const AName, AArtist :TString; ALength :Integer; AIndex :Integer);
  begin
    CreateName(AName);
    FArtist := AArtist;
    FIndex := AIndex;
    FLength := ALength;
    ResolveTrack(False);
  end;


  procedure TFarFmTrackItem.MakePanelItem(var AItem :TPluginPanelItem); {override;}
  var
    vName :TString;
  begin
//  inherited MakePanelItem(AItem);

    if not opt_ShowResolvedFile or (FURL = '') then
      AItem.{$ifdef Far3}FileName{$else}FindData.cFileName{$endif Far3}
        := StrNew(FName)
    else begin
      vName := AddFileExtension(FName, ExtractFileExtension(FURL));
      AItem.{$ifdef Far3}FileName{$else}FindData.cFileName{$endif Far3}
        := StrNew(vName);
    end;
    Pointer(AItem.UserData) := Self;

    AItem.{$ifdef Far3}FileSize{$else}FindData.nFileSize{$endif Far3}
      := FLength;
    AItem.CustomColumnNumber := 3;
    AItem.CustomColumnData := NewStrs([Int2Str(FIndex), FArtist, FormatLength(FLength)]);
  end;


  procedure TFarFmTrackItem.GetFileView(AMode :Integer; var APath :TString); {override;}
  var
    vName, vList :TString;
  begin
    if FURL = '' then
      ResolveTrack(True);

    vName := AddFileName(APath, CleanFileName(Name)) + '.' + cPlaylistExt;

    vList := cM3UHeader;
    vList := AppendStrCh(vList, Format(cM3UExtInfo, [FLength, FArtist, FName]), CRLF);
    vList := AppendStrCh(vList, FURL, CRLF);

    {!!!Unicode}
    StrToFile(vName, vList, sffAnsi);
  end;


  function TFarFmTrackItem.CanCopy :Boolean; {override;}
  begin
    if FURL = '' then
      ResolveTrack(True);
    Result := FURL <> '';
  end;


  function TFarFmTrackItem.GetFileName :TString; {override;}
  begin
    Result := FormatTrackFileName(Name, FArtist, '', ExtractFileExtension(FURL), FIndex);
  end;


  procedure TFarFmTrackItem.CopyFileTo(const AFileName :TString); {override;}
  begin
    HTTPDownload(FURL, AFileName);
  end;


  procedure TFarFmTrackItem.ResolveTrack(AForce :Boolean);
  begin
    FURL := FarFm.FindTrackURL(FArtist, FName, AForce);
  end;


  procedure TFarFmTrackItem.UnResolveTrack;
  begin
    FarFm.DropTrackURL(FArtist, FName);
  end;



 {-----------------------------------------------------------------------------}
 { TFarFmPanel                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFarFmPanel.Create; {override;}
  begin
    inherited Create;
    FItems := TObjList.Create;
    FStack := TStringList.Create;
    FKeyBar := TFarPanelLabels.Create;
    FModes := TFarPanelModes.Create;
    FLevel := fflRoot;
    Navigate(0, '\');
  end;

  destructor TFarFmPanel.Destroy; {override;}
  begin
    FreeObj(FStack);
    FreeObj(FItems);
    FreeObj(FKeyBar);
    FreeObj(FModes);
    inherited Destroy;
  end;


  procedure TFarFmPanel.GetInfo(var AInfo :TOpenPanelInfo);
  begin
   {$ifdef Far3}
    AInfo.Flags := OPIF_ADDDOTS or OPIF_SHORTCUT;
   {$else}
    AInfo.Flags := OPIF_ADDDOTS or OPIF_USEFILTER or OPIF_USEHIGHLIGHTING {OPIF_USEATTRHIGHLIGHTING};
   {$endif Far3}

    AInfo.CurDir := PTChar(FPath);
//  AInfo.Format := cFarFmPrefix;
    AInfo.PanelTitle := PTChar(FTitle);

    if FKeyBar.Count > 0 then
      AInfo.KeyBar := FKeyBar.AllocateTitles;

    AInfo.PanelModesNumber := FModes.Count;
    if FModes.Count > 0 then begin
      AInfo.PanelModesArray := FModes.AllocateModes;
      AInfo.StartPanelMode := byte('0') + FDefMode;
    end;
    AInfo.StartSortMode := FDefSort;
  end;


  function TFarFmPanel.GetItems(AMode :Integer; var AItems :PPluginPanelItemArray; var ACount :Integer) :boolean;
  var
    I :Integer;
  begin
    AItems := MemAllocZero(FItems.Count * SizeOf(TPluginPanelItem));
    for I := 0 to FItems.Count - 1 do
      TFarFMItem(FItems[I]).MakePanelItem(AItems[I]);
    ACount := FItems.Count;
    Result := True;
  end;


  procedure TFarFmPanel.FreeItems(AItems :PPluginPanelItemArray; ACount :Integer);
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do
      FreePanelItem(AItems[I]);
    MemFree(AItems);
  end;


  function TFarFmPanel.SetDirectory(AMode :Integer; ADir :PFarChar) :Boolean;
  var
    vInitOk :Boolean;
  begin
    vInitOk := Succeeded(CoInitialize(nil));
    try
      Navigate(AMode, ADir);
      Result := True;
    finally
      if vInitOk then
        CoUninitialize;
    end;
  end;


  function TFarFmPanel.MakeDirectory(AMode :Integer; var ADir :TString) :Boolean;
  begin
    Result := False;
    case FLevel of
      fflArtists:
        Result := AddArtistPrompt(ADir);
      fflUsers:
        Result := AddUserPrompt(ADir);
    end;
    if Result then
      FillLevel;
  end;


  function TFarFmPanel.DeleteFiles(AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean;

    procedure LocDelete(const AName :TString; AList :TStringList);
    var
      I, J :Integer;
    begin
      for I := 0 to ACount - 1 do begin
        J := AList.IndexOf(AItems.{$ifdef Far3}FileName{$else}FindData.cFileName{$endif Far3});
        if J <> -1 then
          AList.Delete(J);
        Inc(Pointer1(AItems), SizeOf(TPluginPanelItem));
      end;
      FarFM.SaveLocalList(AName, AList);
      FillLevel;
    end;

  var
    vPrompt :TString;
  begin
    Result := False;
    if FLevel in [fflArtists, fflUsers] then begin

      if OPM_SILENT and AMode = 0 then begin

        if ACount = 1 then
          vPrompt := GetMsgStr(strDeletePrompt) + #10 + AItems.{$ifdef Far3}FileName{$else}FindData.cFileName{$endif Far3}
        else
          vPrompt := Format(GetMsgStr(strDeletePromptN), [ACount]);
        if ShowMessage(GetMsgStr(strDelete), vPrompt + #10 + GetMsgStr(strDeleteBut) + #10 + GetMsgStr(strCancel), 0, 2) <> 0 then
          Exit;
      end;

      case FLevel of
        fflArtists : LocDelete(cArtists, FarFM.Artists);
        fflUsers   : LocDelete(cUsers, FarFM.Users);
      end;
    end;
  end;


  function TFarFmPanel.GetFiles(AMode :Integer; AItems :PPluginPanelItem; ACount :Integer; AMove :boolean; var ADestPath :TString) :Boolean;
  var
    vItem :TFarFmItem;
    vResolved :Integer;
  begin
    Result := False;
    vResolved := FarFM.FResolved;
    try
      if AMode <> 0 then begin
        if FItems.IndexOf(Pointer(AItems.UserData)) = -1 then
          Wrong;
        vItem := Pointer(AItems.UserData);
        if vItem is TFarFmCommand then begin
          if AMode = OPM_VIEW + OPM_SILENT then
            with TFarFmCommand(vItem) do
              FarAdvControl(ACTL_SYNCHRO, TAsyncCommand.CreateEx(Self, FCmd, FParam));
          Result := False;
        end else
        begin
          DownloadCallback := CopyDownloadCallback;
          try
            FProgressTick := 0;
            FProgressTitle := 'Loading';
            FProgressMess := vItem.Name;
            FProgressPercent := -1;
            vItem.GetFileView(AMode, ADestPath);
          finally
            DownloadCallback := nil;
          end;
          Result := True;
        end;
      end else
      begin
        Assert(OPM_SILENT and AMode = 0, 'Silent mode???');
        if FLevel in [fflAlbum, fflArtistTracks, fflArtistAlbums, fflUserTracks, fflUserAlbums] then
          Result := CopyFilesTo(AItems, ACount, ADestPath);
      end;
    finally
      if (vResolved <> FarFM.FResolved) and opt_ShowResolvedFile then
        FarAdvControl(ACTL_SYNCHRO, TAsyncCommand.CreateEx(Self, cmUpdate, 0));
    end;
  end;


  procedure TFarFmPanel.CopyDownloadCallback(const AURL :TString; ASize :TIntPtr);
  var
    vTime :DWORD;
  begin
    vTime := GetTickCount;
    if (FProgressTick = 0) or (TickCountDiff(vTime, FProgressTick) > 100) then begin
      FarFM.VkCallsProgress(FProgressTitle, FProgressMess + ' (' + Int2Str(ASize div 1024) + ' K)', FProgressPercent);
      FProgressTick := vTime;
    end;
    if FarFM.CheckInterrupt then
      CtrlBreakException;
  end;


  function TFarFmPanel.CopyFilesTo(AItems :PPluginPanelItem; ACount :Integer; const AFolder :TString) :Boolean;
  var
    vMode :Integer; {0 - Prompt; 1 - Overwrite; 2 - Skip; 3 - Cancel}
    vPercent2 :Integer;

    function LocCopyFileTo(AItem :TFarFmItem; const ADest :TString) :Boolean;
    var
      vFileName :TString;
      vRes :Integer;
    begin
      Result := False;
      if FarFM.CheckInterrupt then begin
        vMode := 3;
        Exit;
      end;

      if AItem.CanCopy then begin
        FProgressTick := 0;
        FProgressMess := AItem.FileName;
        FarFM.VkCallsProgress(GetMsgStr(strCopying), FProgressMess, FProgressPercent);

        vFileName := AddFileName(ADest, AItem.FileName);
        if WinFileExists(vFileName) then begin
          if vMode = 0 then begin
            vRes := ShowMessage(GetMsgStr(strWarning), GetMsgStr(strFileExists) + #10 + vFileName + #10#10 +
              GetMsgStr(strOverwriteBut) + #10 + GetMsgStr(strAllBut) + #10 + GetMsgStr(strSkipBut) + #10 + GetMsgStr(strSkipAllBut) + #10 + GetMsgStr(strCancel),
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

        AItem.CopyFileTo(vFileName);
        Result := True;
      end;
    end;


    function LocCopyGroupTo(AItem :TFarFmItem; const ADest :TString) :Boolean;
    var
      I, vPercent0 :Integer;
      vDestFolder :TString;
      vAlbumList :TObjList;
    begin
      Result := False;
      if not (AItem is TFarFmAlbum) then
        Sorry;

      FProgressTick := 0;
      FProgressMess := AItem.FileName;
      FarFM.VkCallsProgress(GetMsgStr(strCopying), FProgressMess, FProgressPercent);

      vDestFolder := AddFileName(ADest, AItem.FileName);
      if not WinFolderExists(vDestFolder) then
        if not CreateDir(vDestFolder) then
          RaiseLastWin32Error;

      vAlbumList := TObjList.Create;
      try
        AlbumLoad(vAlbumList, {Artist:}TFarFmAlbum(AItem).FInfo, AItem.Name);
        vPercent0 := FProgressPercent;
//      Inc(vTotal, vAlbumList.Count);
        for I := 0 to vAlbumList.Count - 1 do begin
          FProgressPercent := vPercent0 + MulDiv(I, vPercent2 - vPercent0, vAlbumList.Count);
          if LocCopyFileTo(vAlbumList[I], vDestFolder) then
            Result := True;
          if vMode = 3 then
            Exit;
        end;
      finally
        FreeObj(vAlbumList);
      end;
    end;

  var
    I, J, vPrompt :Integer;
    vItem :TFarFmItem;
    vDest :TString;
  begin
    Result := False;
    vDest := AddBackSlash(AFolder);
    vPrompt := IntIf(ACount = 1, Byte(strCopyPrompt), Byte(strCopyPromptN));
    if not CopyDlg(False, FarCtrl.GetMsgStr(vPrompt), vDest) then
      Exit;

    DownloadCallback := CopyDownloadCallback;
    FarFm.VKCallsBegin;
    try
      FProgressTitle := GetMsgStr(strCopying);
      vMode := 0;
      for I := 0 to ACount - 1 do begin
        FProgressTick := 0;
        FProgressPercent := MulDiv(I, 100, ACount);
        vPercent2 := MulDiv(I + 1, 100, ACount);
        J := FItems.IndexOf(Pointer(AItems.UserData));
        if J <> -1 then begin
          vItem := FItems[J];
          if vItem is TFarFmFolder then begin
            if LocCopyGroupTo(vItem, vDest) then
              AItems.Flags := AItems.Flags and not PPIF_SELECTED;
          end else
          begin
            if LocCopyFileTo(vItem, vDest) then
              AItems.Flags := AItems.Flags and not PPIF_SELECTED;
          end;
          if vMode = 3 then
            Exit;
        end;
        Inc(TUnsPtr(AItems), SizeOf(TPluginPanelItem));
      end;
      Result := False;
    finally
      FarFm.VKCallsEnd;
      DownloadCallback := nil;
    end;
  end;


  function TFarFmPanel.ProcessInput(AKey :Integer) :Boolean;
  begin
    Result := True;
    case AKey of
      KEY_SHIFTF1: Sorry;
      KEY_SHIFTF8: DropURLCache;
    else
      Result := False;
    end;
  end;


  function TFarFmPanel.RunCommand(ACmd :Integer; AParam :TIntPtr) :Boolean;
  var
    I :Integer;
    vName :TString;
    vItem :TFarFmItem;
  begin
    Result := False;
    case ACmd of
      cmAddArtist:
        if AddArtistPrompt(vName) then begin
          UpdatePanel(True);
          FarPanelSetCurrentItem(True, vName);
          Result := True;
        end;
      cmAddUser:
        if AddUserPrompt(vName) then begin
          UpdatePanel(True);
          FarPanelSetCurrentItem(True, vName);
          Result := True;
        end;
      cmNextPage:
        begin
          case FLevel of
            fflArtistTracks : TrackLoad(AParam);
            fflUserArtists  : UserArtistsLoad(AParam);
            fflUserAlbums   : UserAlbumsLoad(AParam);
            fflUserTracks   : UserTrackLoad(AParam);
          else
            Exit;
          end;
          UpdatePanel;
          Result := True;
        end;
      cmUpdate:
        begin
          for I := 0 to FItems.Count - 1 do begin
            vItem := FItems[I];
            if vItem is TFarFmTrackItem then
              TFarFmTrackItem(vItem).ResolveTrack(False);
          end;
          UpdatePanel;
        end;
    else
      Sorry;
    end;
  end;


  function TFarFmPanel.AddArtistPrompt(var AName :TString) :Boolean;
  begin
    Result := False;
    if FindDlg(1, '', AName) then begin
      FarFM.Artists.Add( AName );
      FarFM.SaveLocalList(cArtists, FarFM.Artists);
      Result := True;
    end;
  end;


  function TFarFmPanel.AddUserPrompt(var AName :TString) :Boolean;
  begin
    Result := False;
//  if FindDlg(2, '', AName) then begin
    if FarInputBox(GetMsg(strAddUser), GetMsg(strName), AName) then begin
      FarFM.Users.Add( AName );
      FarFM.SaveLocalList(cUsers, FarFM.Users);
      Result := True;
    end;
  end;


  function TFarFmPanel.DropURLCache :Boolean;

    function LogGetSelected(AIndex :Integer) :TFarFmItem;
    var
      vPanelItem :PPluginPanelItem;
    begin
      Result := nil;
      vPanelItem := FarPanelItem(PANEL_ACTIVE, FCTL_GETSELECTEDPANELITEM, AIndex);
      if vPanelItem <> nil then
        try
          if FItems.IndexOf(Pointer(vPanelItem.UserData)) <> -1 then
            Result := Pointer(vPanelItem.UserData);
        finally
          MemFree(vPanelItem);
        end;
    end;

    procedure LocClearGroup(AItem :TFarFmFolder);
    var
      I :Integer;
      vAlbumList :TObjList;
    begin
      Result := False;
      if not (AItem is TFarFmAlbum) then
        Sorry;
      vAlbumList := TObjList.Create;
      try
        AlbumLoad(vAlbumList, {Artist:}AItem.Info, {Album:}AItem.Name);
        for I := 0 to vAlbumList.Count - 1 do
          if TObject(vAlbumList[I]) is TFarFmTrackItem then
            TFarFmTrackItem(vAlbumList[I]).UnResolveTrack;
      finally
        FreeObj(vAlbumList);
      end;
    end;

  var
    I :Integer;
    vInfo :TPanelInfo;
    vItem :TFarFmItem;
    vStr, vPrompt :TString;
  begin
    Result := False;
    if FLevel in [fflAlbum, fflArtistTracks, fflArtistAlbums, fflUserTracks, fflUserAlbums] then begin

      FarGetPanelInfo(PANEL_ACTIVE, vInfo);
      if vInfo.SelectedItemsNumber <= 1 then begin
        vItem := LogGetSelected(0);
        if not ((vItem is TFarFmFolder) or ((vItem is TFarFmTrackItem) and (TFarFmTrackItem(vItem).FURL <> ''))) then
          Exit;
        vStr := vItem.Name;
      end;

      if vInfo.SelectedItemsNumber <= 1 then
        vPrompt := GetMsgStr(strClearPrompt) + #10 + vStr
      else
        vPrompt := Format(GetMsgStr(strClearPromptN), [vInfo.SelectedItemsNumber]);
      if ShowMessage(GetMsgStr(strClear), vPrompt + #10 + GetMsgStr(strClearBut) + #10 + GetMsgStr(strCancel), 0, 2) <> 0 then
        Exit;

      for I := 0 to vInfo.SelectedItemsNumber - 1 do begin
        vItem := LogGetSelected(I);
        if vItem is TFarFmFolder then
          LocClearGroup(TFarFmFolder(vItem))
        else
        if vItem is TFarFmTrackItem then
          TFarFmTrackItem(vItem).UnResolveTrack;
      end;

      UpdatePanel(True);

      Result := True;
    end;
  end;


  procedure TFarFmPanel.UpdatePanel(ARefill :Boolean = False);
  begin
    if ARefill then
      FillLevel;
    FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
    FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
  end;


  procedure TFarFmPanel.Navigate(AMode :Integer; const AFolder :TString);

    procedure PushStack;
    begin
      FStack.AddObject(FCurrent, Pointer(FLevel));
    end;

    procedure PopStack;
    begin
      FCurrent := FStack[FStack.Count - 1];
      FLevel := TFarFmLevel(FStack.Objects[FStack.Count - 1]);
      FStack.Delete(FStack.Count - 1);
    end;


    procedure LocGotoRoot;
    begin
      FStack.Clear;
      FLevel := fflRoot;
      FCurrent := '';
      FillLevel;
    end;

    procedure LocGoUp;
    begin
      PopStack;
      FillLevel;
    end;

    procedure LocGoInto(ALevel :TFarFmLevel; const AName, AInfo :TString);
    begin
      if (ALevel = fflArtistSimilar) and (AMode and OPM_FIND <> 0) then
        { Во избежании зацикливания поиска... }
        Abort;

      PushStack;
      try
        FLevel := ALevel;
        FCurrent := AName;
        FCurInfo := AInfo;
        FillLevel;
      except
        PopStack;
        raise;
      end;
    end;

  var
    vIndex :Integer;
    vItem :TFarFMItem;
    vPtr :PTChar;
    vStr :TString;
  begin
//  TraceF('Navigate: %s', [AFolder]);
    try
      if (AFolder = '\') or (AFolder = '') then
        LocGotoRoot
      else
      if AFolder = '..' then
        LocGoUp
      else
      if ChrPos('\', AFolder) = 0 then begin
        if not FItems.FindKey(Pointer(AFolder), 0, [], vIndex) then
          Wrong;

        vItem := FItems[vIndex];
        if not (vItem is TFarFmFolder) then
          Abort;

        with TFarFmFolder(vItem) do
          LocGoInto(Level, AFolder, Info);
      end else
      begin
        Navigate(0, '\');
        vPtr := PTChar(AFolder);
        while vPtr^ <> #0 do begin
          vStr := ExtractNextWord(vPtr, ['\']);
          Navigate(0, vStr);
        end;
      end;

    finally
      FPath := FStack.GetTextStrEx('\');
      if FCurrent <> '' then
        FPath := FPath + '\' + FCurrent;
      FTitle := cPluginName + ':' + FPath;
    end;
  end;



  procedure AddImageItem(AList :TObjList; const AInfo :IXMLDOMDocument; const ANodes, AName :TString);
  var
    I, vBest :Integer;
    vImages :TStringArray2;
  begin
    vImages := XMLParseArray(AInfo, ANodes, ['%size', '']);

    vBest := -1;
    for I := length(vImages) - 1 downto 0 do
      if not StrIsEmpty(vImages[I, 1]) then begin
        vBest := I;
        Break;
      end;

    if vBest <> -1 then
      AList.Add( TFarFmImageItem.CreateEx(AName, vImages[vBest, 1]) );
  end;


  procedure AddURLItem(AList :TObjList; const AInfo :IXMLDOMDocument; const ANode, AName, ALabel :TString);
  var
    vURL :TString;
  begin
    vURL := Trim(XMLParseNode(AInfo, ANode));
    if vURL <> '' then
      AList.Add( TFarFmURLItem.CreateEx(AName, vURL, ALabel) );
  end;



  procedure TFarFmPanel.FillLevel;

(*
    procedure LocFillArtist;
    var
      I :Integer;
      vDoc :IXMLDOMDocument;
      vAlbums :TStringArray2;
    begin
      vDoc := LastFMCall('artist.getInfo', ['artist', FCurrent]);
      vAlbums := LastFMCall1('artist.getTopAlbums', ['artist', FCurrent], '/lfm/topalbums/album', ['name', 'url']);

      FItems.FreeAll;
      LocAddImageItem(vDoc, '/lfm/artist/image', FCurrent {'Artist'});
      LocAddURLItem(vDoc, '/lfm/artist/url', FCurrent {'ArtistPage'}, FCurrent);
      FItems.Add( TFarFmItem.CreateEx(cTracks, fflArtistTracks) );
      for I := 0 to length(vAlbums) - 1 do
        FItems.Add( TFarFmItem.CreateEx(vAlbums[I, 0], fflAlbum ));
    end;
*)

    procedure LocFillArtist;
    var
      vDoc :IXMLDOMDocument;
      vInfo :TString;
    begin
      vDoc := LastFMCall('artist.getInfo', ['artist', FCurrent, 'lang', opt_InfoLang]);

      vInfo := XMLParseNode(vDoc, '/lfm/artist/bio/summary');
//    vInfo := XMLParseNode(vDoc, '/lfm/artist/bio/content');
      vInfo := ClearTags(vInfo);

      FItems.FreeAll;
      AddImageItem(FItems, vDoc, '/lfm/artist/image', FCurrent {'Artist'});
      AddURLItem(FItems, vDoc, '/lfm/artist/url', FCurrent {'ArtistPage'}, FCurrent);
      if vInfo <> '' then
        FItems.Add( TFarInfoItem.CreateEx(cInformation, vInfo) );
      FItems.Add( TFarFmFolder.CreateEx(cTracks, '', fflArtistTracks) );
      FItems.Add( TFarFmFolder.CreateEx(cAlbums, '', fflArtistAlbums) );
      FItems.Add( TFarFmFolder.CreateEx(cSimilar, '', fflArtistSimilar) );
    end;


    procedure LocFillArtistAlbums;
    var
      I :Integer;
      vArtist :TString;
      vAlbums :TStringArray2;
    begin
      vArtist := FStack[FStack.Count - 1];
      vAlbums := LastFMCall1('artist.getTopAlbums', ['artist', vArtist], '/lfm/topalbums/album', ['name', 'url']);

      FItems.FreeAll;
      for I := 0 to length(vAlbums) - 1 do
        FItems.Add( TFarFmAlbum.CreateEx(vAlbums[I, 0], vArtist) );
    end;


    procedure LocFillArtistSimilar;
    var
      I :Integer;
      vArtist :TString;
      vArtists :TStringArray2;
    begin
      vArtist := FStack[FStack.Count - 1];
      vArtists := LastFMCall1('artist.getSimilar', ['artist', vArtist], '/lfm/similarartists/artist', ['name', 'url']);
      FItems.FreeAll;
      for I := 0 to length(vArtists) - 1 do
        FItems.Add( TFarFmFolder.CreateEx(vArtists[I, 0], '', fflArtist ));
    end;


    procedure LocFillUser;
    var
      vDoc :IXMLDOMDocument;
      vStr, vInfo :TString;
    begin
      vDoc := LastFMCall('user.getInfo', ['user', FCurrent]);

      vInfo := '';
      vStr := Trim(XMLParseNode(vDoc, '/lfm/user/realname'));
      if vStr <> '' then
        vInfo := vInfo + GetMsgStr(strInfoName) + ' ' + vStr + #13#10;
      vStr := Trim(XMLParseNode(vDoc, '/lfm/user/gender'));
      if (vStr <> '') and (vStr <> 'n') then
        vInfo := vInfo + GetMsgStr(strInfoGender) + ' ' + vStr + #13#10;
      vStr := Trim(XMLParseNode(vDoc, '/lfm/user/age'));
      if vStr <> '' then
        vInfo := vInfo + GetMsgStr(strInfoAge) + ' ' + vStr + #13#10;
      vStr := Trim(XMLParseNode(vDoc, '/lfm/user/country'));
      if vStr <> '' then
        vInfo := vInfo + GetMsgStr(strInfoCountry) + ' ' + vStr + #13#10;
      vStr := Trim(XMLParseNode(vDoc, '/lfm/user/playcount'));
      if vStr <> '' then
        vInfo := vInfo + GetMsgStr(strInfoPlaycount) + ' ' + vStr + #13#10;
      vStr := Trim(XMLParseNode(vDoc, '/lfm/user/registered'));
      if vStr <> '' then
        vInfo := vInfo + GetMsgStr(strInfoRegistered) + ' ' + vStr + #13#10;

      FItems.FreeAll;
      AddImageItem(FItems, vDoc, '/lfm/user/image', FCurrent {'UserImage'});
      AddURLItem(FItems, vDoc, '/lfm/user/url', FCurrent {'UserPage'}, FCurrent);
      if vInfo <> '' then
        FItems.Add( TFarInfoItem.CreateEx(cInformation, vInfo) );
      FItems.Add( TFarFmFolder.CreateEx(cArtists, '', fflUserArtists) );
      FItems.Add( TFarFmFolder.CreateEx(cAlbums, '', fflUserAlbums) );
      FItems.Add( TFarFmFolder.CreateEx(cTracks, '', fflUserTracks) );
//    FItems.Add( TFarFmFolder.CreateEx(cPlaylists, '', fflUserPlaylists) );
    end;

(*
    procedure LocFillUserPlaylists;
    var
      I :Integer;
      vUser :TString;
      vDoc :IXMLDOMDocument;
      vLists :TStringArray2;
    begin
      vUser := ExtractWord(2, FPath, ['\']);
      vDoc := LastFMCall('user.getPlaylists', ['user', vUser]);

      vLists := XMLParseArray(vDoc, '/lfm/playlists/playlist', ['title', 'description', 'size', 'duration']);

      FItems.FreeAll;
      for I := 0 to length(vLists) - 1 do
        FItems.Add( TFarFmFolder.CreateEx(vLists[I, 0], '', fflUserPlaylist) );
    end;
*)

    procedure LocFillUserPlaylist;
    begin
      FItems.FreeAll;
    end;

  var
    I, L :Integer;
  begin
    FDefSort := SM_UNSORTED;

    case FLevel of
      fflRoot: begin
        FItems.FreeAll;
        FItems.Add( TFarFmFolder.CreateEx(cArtists, '', fflArtists) );
//      FItems.Add( TFarFmFolder.CreateEx(cAlbums, '', fflAlbums) );
        FItems.Add( TFarFmFolder.CreateEx(cUsers, '', fflUsers) );
        FItems.Add( TFarFmFolder.CreateEx(cAccount, '', fflAccounts) );
      end;

      fflArtists: begin
        FItems.FreeAll;
        for I := 0 to FarFM.Artists.Count - 1 do
          FItems.Add( TFarFmFolder.CreateEx(FarFM.Artists[I], '', fflArtist) );
        FItems.Add( TFarFmCommand.CreateEx('Add', cmAddArtist, 0) );
      end;

      fflUsers: begin
        FItems.FreeAll;
        for I := 0 to FarFM.Users.Count - 1 do
          FItems.Add( TFarFmFolder.CreateEx(FarFM.Users[I], '', fflUser) );
        FItems.Add( TFarFmCommand.CreateEx('Add', cmAddUser, 0) );
      end;

      fflArtist:
        LocFillArtist;
      fflAlbum:
        AlbumLoad(FItems, {Artist:}FCurInfo, {Album:}FCurrent);
//      AlbumLoad(FItems, {Artist:}FStack[FStack.Count - 2], FCurrent);
//      with FStack.Objects[FStack.Count - 1] as TFarFmAlbumItem do
//        AlbumLoad(FItems, FArtist, FCurrent);
      fflArtistTracks:
        TrackLoad(1);
      fflArtistAlbums:
        LocFillArtistAlbums;
      fflArtistSimilar:
        LocFillArtistSimilar;

      fflUser:
        LocFillUser;
      fflUserArtists:
        UserArtistsLoad(1);
      fflUserAlbums:
        UserAlbumsLoad(1);
      fflUserTracks:
        UserTrackLoad(1);
(*
      fflUserPlaylists:
        LocFillUserPlaylists;
      fflUserPlaylist:
        LocFillUserPlaylist;
*)
(*
      fflAccounts:
        {};
      fflAlbums:
        {};
*)
    else
      Sorry;
    end;

    FModes.FreeAll;
    case FLevel of
      fflAlbum, fflArtistTracks, fflUserTracks:
      begin
        L := length(Int2Str(FItems.Count));
        if FLevel in [fflArtistTracks, fflUserTracks] then
          L := IntMax(L, 3);
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, [strN, strTrack, strArtist, strLength], 'C0,N,C1,C2', Int2Str(L) + ',0,0,5'),
          nil, nil, nil,
          NewPanelMode(0, [strN, strName, strLength], 'C0,N,C2', Int2Str(L) + ',0,5'),
          NewPanelMode(0, [strN, strTrack, strArtist, strLength], 'C0,N,C1,C2', Int2Str(L) + ',0,0,5')
        ]);
        if FLevel = fflUserTracks then
          FModes[3] := NewPanelMode(0, [strN, strTrack, strArtist, strLength], 'C0,N,C1,C2', Int2Str(L) + ',0,0,5')
        else
          FModes[3] := NewPanelMode(0, [strN, strName, strLength], 'C0,N,C2', Int2Str(L) + ',0,5');
      end;

      fflArtistAlbums, fflUserAlbums:
      begin
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, [strAlbum, strArtist], 'N,C0', '0,0'),
          nil, nil, nil,
          NewPanelMode(0, [strName], 'N', '0'),
          NewPanelMode(0, [strAlbum, strArtist], 'N,C0', '0,0')
        ]);
        if FLevel = fflArtistAlbums then
          FModes[3] := NewPanelMode(0, [strName], 'N', '0')
        else
          FModes[3] := NewPanelMode(0, [strAlbum, strArtist], 'N,C0', '0,0');
      end;

    else
      if FModes.Count = 0 then
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, [strName], 'N', '0'),
          nil, nil,
          NewPanelMode(0, [strName], 'N', '0'),
          NewPanelMode(0, [strName], 'N', '0'),
          NewPanelMode(0, [strName], 'N', '0')
        ]);
    end;
    FDefMode := 3;


    FKeyBar.SetLabels([
      NewFarLabel(KEY_F3), NewFarLabel(KEY_F4), NewFarLabel(KEY_F5), NewFarLabel(KEY_F6), NewFarLabel(KEY_F7), NewFarLabel(KEY_F8),
      NewFarLabel(KEY_ShiftF3), NewFarLabel(KEY_ShiftF4), NewFarLabel(KEY_ShiftF5), NewFarLabel(KEY_ShiftF6), NewFarLabel(KEY_ShiftF7), NewFarLabel(KEY_ShiftF8)
    ]);
    case FLevel of
      fflAlbum, fflArtistTracks, fflArtistAlbums, fflUserTracks, fflUserAlbums: begin
        TFarPanelLabel(FKeyBar[2]).FText := GetMsgStr(strCmdCopy);
        TFarPanelLabel(FKeyBar[11]).FText := 'Clear';
      end;
      fflArtists, fflUsers: begin
        TFarPanelLabel(FKeyBar[4]).FText := GetMsgStr(strCmdAdd);
        TFarPanelLabel(FKeyBar[5]).FText := GetMsgStr(strCmdDelete);
      end;
    end;
  end;


  procedure TFarFmPanel.TrackLoad(APage :Integer);
  var
    I, vTotal :Integer;
    vDoc :IXMLDOMDocument;
    vArtist :TString;
    vTracks :TStringArray2;
  begin
    vArtist := FStack[FStack.Count - 1];
    vDoc := LastFMCall('artist.getTopTracks', ['artist', vArtist, 'page', Int2Str(APage)]);
    vTotal := Str2IntDef(XMLParseNode(vDoc, '/lfm/toptracks', 'totalPages'), 1);
    vTracks := XMLParseArray(vDoc, '/lfm/toptracks/track', ['name', 'artist/name', 'duration', '%rank']);

    if APage = 1 then
      FItems.FreeAll
    else
    if TObject(FItems[FItems.Count - 1]) is TFarFmCommand then
      FItems.FreeAt(FItems.Count - 1);
    if length(vTracks) = 0 then
      Exit;

    FItems.Add(TFarFmPlaylistItem.CreateEx( vArtist + ' ' + Int2Str(APage), vTracks ));
    for I := 0 to length(vTracks) - 1 do
      FItems.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vTracks[I, 1], Str2IntDef(vTracks[I, 2], 0), Str2IntDef(vTracks[I, 3], 0)) );
    if APage < vTotal then
      FItems.Add(TFarFmCommand.CreateEx(Format('Page %d/%d', [APage + 1, vTotal]), cmNextPage, APage + 1));
  end;


  procedure TFarFmPanel.AlbumLoad(AList :TObjList; const AArtist, AAlbum :TString);
  var
    I :Integer;
    vDoc :IXMLDOMDocument;
    vTracks :TStringArray2;
  begin
    vDoc := LastFMCall('album.getInfo', ['artist', AArtist, 'album', AAlbum]);

    vTracks := XMLParseArray(vDoc, '/lfm/album/tracks/track', ['name', 'artist/name', 'duration']);

    AList.FreeAll;
    AddImageItem(AList, vDoc, '/lfm/album/image', 'Album');
    AddURLItem(AList, vDoc, '/lfm/album/url', AAlbum, AAlbum);
    if length(vTracks) > 0 then begin
      AList.Add(TFarFmPlaylistItem.CreateEx( AAlbum, vTracks ));
      for I := 0 to length(vTracks) - 1 do
        AList.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vTracks[I, 1], Str2IntDef(vTracks[I, 2], 0), I + 1) );
    end;
  end;


  procedure TFarFmPanel.UserArtistsLoad(APage :Integer);
  var
    I, vTotal :Integer;
    vDoc :IXMLDOMDocument;
    vUser :TString;
    vArtists :TStringArray2;
  begin
    vUser := FStack[FStack.Count - 1];
    vDoc := LastFMCall('user.getTopArtists', ['user', vUser, 'page', Int2Str(APage)]);
    vTotal := Str2IntDef(XMLParseNode(vDoc, '/lfm/topartists', 'totalPages'), 1);
    vArtists := XMLParseArray(vDoc, '/lfm/topartists/artist', ['name', '%rank']);

    if APage = 1 then
      FItems.FreeAll
    else
    if TObject(FItems[FItems.Count - 1]) is TFarFmCommand then
      FItems.FreeAt(FItems.Count - 1);
    if length(vArtists) = 0 then
      Exit;

    for I := 0 to length(vArtists) - 1 do
      FItems.Add( TFarFmFolder.CreateEx(vArtists[I, 0], '', fflArtist) );
    if APage < vTotal then
      FItems.Add(TFarFmCommand.CreateEx(Format('Page %d/%d', [APage + 1, vTotal]), cmNextPage, APage + 1));
  end;


  procedure TFarFmPanel.UserAlbumsLoad(APage :Integer);
  var
    I, vTotal :Integer;
    vDoc :IXMLDOMDocument;
    vUser :TString;
    vAlbums :TStringArray2;
  begin
    vUser := FStack[FStack.Count - 1];
    vDoc := LastFMCall('user.getTopAlbums', ['user', vUser, 'page', Int2Str(APage)]);
    vTotal := Str2IntDef(XMLParseNode(vDoc, '/lfm/topalbums', 'totalPages'), 1);
    vAlbums := XMLParseArray(vDoc, '/lfm/topalbums/album', ['name', 'artist/name', '%rank']);

    if APage = 1 then
      FItems.FreeAll
    else
    if TObject(FItems[FItems.Count - 1]) is TFarFmCommand then
      FItems.FreeAt(FItems.Count - 1);
    if length(vAlbums) = 0 then
      Exit;

    for I := 0 to length(vAlbums) - 1 do
      FItems.Add( TFarFmAlbum.CreateEx(vAlbums[I, 0], vAlbums[I, 1]) );
    if APage < vTotal then
      FItems.Add(TFarFmCommand.CreateEx(Format('Page %d/%d', [APage + 1, vTotal]), cmNextPage, APage + 1));
  end;


  procedure TFarFmPanel.UserTrackLoad(APage :Integer);
  var
    I, vTotal :Integer;
    vDoc :IXMLDOMDocument;
    vUser :TString;
    vTracks :TStringArray2;
  begin
    vUser := FStack[FStack.Count - 1];
    vDoc := LastFMCall('user.getTopTracks', ['user', vUser, 'page', Int2Str(APage)]);
    vTotal := Str2IntDef(XMLParseNode(vDoc, '/lfm/toptracks', 'totalPages'), 1);
    vTracks := XMLParseArray(vDoc, '/lfm/toptracks/track', ['name', 'artist/name', 'duration', '%rank']);

    if APage = 1 then
      FItems.FreeAll
    else
    if TObject(FItems[FItems.Count - 1]) is TFarFmCommand then
      FItems.FreeAt(FItems.Count - 1);
    if length(vTracks) = 0 then
      Exit;

    FItems.Add(TFarFmPlaylistItem.CreateEx( vUser + ' ' + Int2Str(APage), vTracks ));
    for I := 0 to length(vTracks) - 1 do
      FItems.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vTracks[I, 1], Str2IntDef(vTracks[I, 2], 0), Str2IntDef(vTracks[I, 3], 0)) );
    if APage < vTotal then
      FItems.Add(TFarFmCommand.CreateEx(Format('Page %d/%d', [APage + 1, vTotal]), cmNextPage, APage + 1));
  end;



(*
    procedure LocFillArtistTracks;
    var
      I, vPages :Integer;
      vDoc :IXMLDOMDocument;
      vArtist :TString;
      vTracks, vTracks1 :TStringArray2;
      vSave :THandle;
    begin
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      try
        ShowProgress('FarFM', 'Read tracks', 0);

        vArtist := FStack[2];
        vDoc := LastFMCall('artist.getTopTracks', ['artist', vArtist]);
        vPages := Str2IntDef(XMLParseNode(vDoc, '/lfm/toptracks', 'totalPages'), 1);
        vTracks := XMLParseArray(vDoc, '/lfm/toptracks/track', ['name', 'duration']);
        if length(vTracks) = 0 then
          Exit;

        for I := 2 to vPages do begin
          ShowProgress('FarFM', 'Read tracks ' + Int2Str(length(vTracks)), MulDiv(I - 1, 100, vPages));
          if CheckInterrupt then
            Break;

          vDoc := LastFMCall('artist.getTopTracks', ['artist', vArtist, 'page', Int2Str(I)]);
          vTracks1 := XMLParseArray(vDoc, '/lfm/toptracks/track', ['name', 'duration']);
          if length(vTracks1) = 0 then
            Break;
          AppendArray2(vTracks, vTracks1);
        end;
        ShowProgress('FarFM', 'Read tracks ' + Int2Str(length(vTracks)), 100);

        FItems.FreeAll;
        FItems.Add(TFarFmPlaylistItem.CreateEx( vArtist, vArtist, vTracks ));
        for I := 0 to length(vTracks) - 1 do
          FItems.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vArtist, Str2IntDef(vTracks[I, 1], 0), I + 1 ));

      finally
        FARAPI.RestoreScreen(vSave);
      end;
    end;
*)


 {-----------------------------------------------------------------------------}
 { TFarFm                                                                      }
 {-----------------------------------------------------------------------------}

  constructor TFarFm.Create; {override;}
  begin
    inherited Create;
    FArtists := TStringList.Create;
    FArtists.Sorted := True;
    FUsers := TStringList.Create;
    FUsers.Sorted := True;
    FTrackCache := TObjList.Create;
    StoreVkToken(False);
    RestoreLocalList(cArtists, FArtists);
    RestoreLocalList(cUsers, FUsers);
    if opt_CacheTrackURL then
      RestoreTrackCache;
  end;


  destructor TFarFm.Destroy; {override;}
  begin
    if opt_CacheTrackURL and (FResolved > 0) then
      SaveTrackCache;
    FreeObj(FTrackCache);
    FreeObj(FArtists);
    FreeObj(FUsers);
    inherited Destroy;
  end;


  procedure TFarFm.SaveLocalList(const AName :TString; AList :TStringList);
  var
    vFileName :TString;
  begin
    vFileName := StrExpandEnvironment(cLocalConfigPath);
    if not WinFolderExists(vFileName) then
      ApiCheck( CreateDir(vFileName) );
    vFileName := AddFileName(vFileName, AName) + '.' + cConfigExt;
    StrToFile(vFileName, AList.Text);
  end;


  procedure TFarFm.RestoreLocalList(const AName :TString; AList :TStringList);
  var
    vFileName :TString;
  begin
    vFileName := StrExpandEnvironment(cLocalConfigPath);
    vFileName := AddFileName(vFileName, AName) + '.' + cConfigExt;
    if WinFileExists(vFileName) then
      AList.Text := StrFromFile(vFileName);
  end;


  procedure TFarFm.SaveTrackCache;
  var
    vStr, vFileName :TString;
    I, vSize :Integer;
    vPtr :PTChar;
  begin
    vSize := 0;
    for I := 0 to FTrackCache.Count - 1 do
      with TDescrObject(FTrackCache[I]) do
        Inc(vSize, Length(Name) + 1 + Length(Descr) + 2);

    SetLength(vStr, vSize);
    vPtr := PTChar(vStr);
    for I := 0 to FTrackCache.Count - 1 do begin
      with TDescrObject(FTrackCache[I]) do begin
        StrMove(vPtr, PTChar(Name), length(Name));
        Inc(vPtr, length(Name));
        StrMove(vPtr, #9, 2);
        Inc(vPtr);
        StrMove(vPtr, PTChar(Descr), length(Descr));
        Inc(vPtr, length(Descr));
      end;
      StrMove(vPtr, PTChar(@CRLF), 2);
      Inc(vPtr, 2);
    end;

    vFileName := StrExpandEnvironment(cLocalConfigPath);
    if not WinFolderExists(vFileName) then
      ApiCheck( CreateDir(vFileName) );
    vFileName := AddFileName(vFileName, cUrlCacheFileName);
    StrToFile(vFileName, vStr, sffUTF8);
  end;


  procedure TFarFm.RestoreTrackCache;
  var
    vStr, vFileName, vRow :TString;
    vPtr :PTChar;
    vPos :Integer;
  begin
    vFileName := StrExpandEnvironment(cLocalConfigPath);
    vFileName := AddFileName(vFileName, cUrlCacheFileName);
    if WinFileExists(vFileName) then
      vStr := StrFromFile(vFileName);
    vPtr := PTChar(vStr);
    while vPtr^ <> #0 do begin
      vRow := ExtractNextWord(vPtr, [#10, #13], True);
      vPos := ChrLastPos(#9, vRow);
      if vPos > 0 then
        FTrackCache.AddSorted( TDescrObject.CreateEx(Copy(vRow, 1, vPos - 1), Copy(vRow, vPos + 1, MaxInt)), 0, dupIgnore );
    end;
  end;


  procedure TFarFm.StoreVkToken(AStore :Boolean);
  var
    vConfig :TFarConfig;
  begin
    vConfig := TFarConfig.CreateEx(AStore, cPluginName);
    try
      with vConfig do begin
        if not Exists then
          Exit;
        StrValue('VkToken', FVKToken);
      end;
    finally
      vConfig.Destroy;
    end;
  end;


  procedure TFarFm.VKAuthorize;

    function LocGetToken(const AResponse :TString) :TString;
    begin
      Result := Copy(AResponse, Length(cVkAuthRes) + 1, ChrPos('&', AResponse) - Length(cVkAuthRes) - 1);
    end;

    procedure LocAuthorizeAutomatic;
   {$ifdef b64}
    begin
      Sorry;
   {$else}
    var
      vBrowser :InternetExplorer;
      vRequest, vResponse :TString;
      vSave :THandle;
      vStart :DWORD;
    begin
      vRequest := Format(cVkAuthStr, [cVKApiID]);

      vBrowser := CreateComObject(CLASS_InternetExplorer) as InternetExplorer;
      vBrowser.Navigate(vRequest, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
      vBrowser.Visible := True;

      try
        vSave := FARAPI.SaveScreen(0, 0, -1, -1);
        try
          vStart := GetTickCount;
          while True do begin
            ShowMessage(cPluginName, Format(GetMsgStr(strWaitAuth), [TickCountDiff(GetTickCount, vStart) div 1000]), 0);
            if FarFm.CheckInterrupt then
              Abort;
            vResponse := vBrowser.LocationURL;
            if UpCompareSubStr(cVkAuthRes, vResponse) = 0 then
              Break;
            Sleep(250);
          end;

          FVKToken := LocGetToken(vResponse);

//        vBrowser.Visible := False;
          vBrowser.Quit;
        finally
          FARAPI.RestoreScreen(vSave);
        end;

      except
        on E :EAbort do
          raise;
        on E :Exception do
          AppErrorID(strAuthError);
      end;
   {$endif b64}
    end;


    procedure LocAuthorizeManual;
    var
      vRequest, vResponse :TString;
    begin
      vRequest := Format(cVkAuthStr, [cVKApiID]);

//    ShellOpen(vRequest);
      if not LoginDlg(vRequest, vResponse) then
        Abort;

      FVKToken := LocGetToken(vResponse);
    end;

  var
    vRes :Integer;
  begin
    if FVKAuth then
      Exit;

    if FVKToken <> '' then begin
      { Check token... }
      try
        VkCall('getUserSettings', []);
        FVKAuth := True;
        Exit;
      except
        FVKToken := '';
      end;
    end;

    vRes := ShowMessage(GetMsgStr(strWarning), GetMsgStr(strNeedAuthVK) + #10 +
      GetMsgStr(strAutoAuthBut) + #10 + GetMsgStr(strManualAuthBut) + #10 + GetMsgStr(strCancel),
      FMSG_WARNING or FMSG_LEFTALIGN, 3);

    case vRes of
      0: LocAuthorizeAutomatic;
      1: LocAuthorizeManual;
    else
      Abort;
    end;

    StoreVkToken(True);
    FVKAuth := True;
  end;


  procedure TFarFm.ShowProgress(const ATitle, AName :TString; APercent :Integer);
  const
    cWidth = 60;
  var
    vMess :TString;
  begin
    vMess := AName;
    if Length(vMess) > cWidth then
      vMess := Copy(vMess, 1, cWidth);
    if APercent <> -1 then
      vMess := vMess + #10 + GetProgressStr(cWidth, APercent);
    ShowMessage(aTitle, vMess, 0);
  end;


  function TFarFm.CheckInterrupt :Boolean;
  begin
    Result := False;
    if CheckForEsc then
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt) + #10#10 + GetMsgStr(strYes) + #10 + GetMsgStr(strNo), FMSG_WARNING, 2) = 0 then
        Result := True;
  end;


  function TFarFm.VkCallsBegin :Boolean;
  begin
//  if FVkLock = 0 then
//    VKAuthorize;
    Inc(FVkLock);
    Result := True;
  end;


  procedure TFarFm.VkCallsEnd;
  begin
    Dec(FVkLock);
    if FVkLock = 0 then begin
      if FScreen <> 0 then
        FARAPI.RestoreScreen(FScreen);
      FScreen := 0;
    end;
  end;


  procedure TFarFm.VkCallsProgress(const ATitle, AMess :TString; APercent :Integer);
  begin
    if FScreen = 0 then
      FScreen := FARAPI.SaveScreen(0, 0, -1, -1);
    ShowProgress(ATitle, AMess, APercent);
  end;


  function TFarFm.FindTrackURL(const Artist, Track :TString; AForce :Boolean = True) :TString;
  const
    cTryVariants = 3;
  var
    I, vIndex, vScore, vBestScore :Integer;
    vKey :TString;
    vDoc :IXMLDOMDocument;
    vStreams :TStringArray2;
  begin
    Result := '';
    vStreams := nil;

    vKey := Artist + #9 + Track;
    if FTrackCache.FindKey(Pointer(vKey), 0, [foBinary], vIndex) then
      Result := TDescrObject(FTrackCache[vIndex]).Descr
    else begin
      if not AForce then
        Exit;

      VKAuthorize;

      vDoc := VkCall('audio.search', ['q', Artist + ' ' + Track, 'count', Int2Str(cTryVariants)]);
      vStreams := XMLParseArray(vDoc, '/response/audio', ['url', 'artist', 'title']);

      vBestScore := -1;
      for I := 0 to length(vStreams) - 1 do begin
        vScore := byte(UpCompareSubStr(Artist, vStreams[I, 1]) = 0) + byte(UpCompareSubStr(Track, vStreams[I, 2]) = 0);
        if vScore > vBestScore then begin
          Result := vStreams[I, 0];
          vBestScore := vScore;
        end;
        if vScore = 2 then
          Break;
      end;

      if Result <> '' then begin
        FTrackCache.Insert( vIndex, TDescrObject.CreateEx(vKey, Result) );
        Inc(FResolved);
      end;
    end;
  end;


  function TFarFm.DropTrackURL(const Artist, Track :TString) :Boolean;
  var
    vIndex :Integer;
    vKey :TString;
  begin
    Result := False;
    vKey := Artist + #9 + Track;
    if FTrackCache.FindKey(Pointer(vKey), 0, [foBinary], vIndex) then begin
      FTrackCache.FreeAt(vIndex);
      Inc(FResolved);
      Result := True;
    end;
  end;


end.


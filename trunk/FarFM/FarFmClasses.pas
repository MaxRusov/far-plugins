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
      constructor CreateEx(AFlags :Integer; const ATitles :array of TString; const ATypes, AWidths, AStTypes, AStWidths :TString);
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
      function AllocateTitles :{$ifdef Far3}PKeyBarTitles{$else}PKeyBarTitlesArray{$endif Far3};

    private
      FTitles :{$ifdef Far3}TKeyBarTitles{$else}PKeyBarTitlesArray{$endif Far3};
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
      fflAlbum,

      fflAlbums,

      fflUsers,
      fflUser,
      fflUserPlaylists,
      fflUserPlaylist,
      fflUserAlbums,
      fflUserALbum,

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
      property Param :Integer read FParam;
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

      procedure Navigate(const AFolder :TString);
      function RunCommand(ACmd :Integer; AParam :TIntPtr) :Boolean;

    private
      FLevel   :TFarFmLevel;
      FCurrent :TString;

      FStack  :TStringList;
      FItems  :TObjList;

      FTitle  :TString;
      FPath   :TString;

      FKeyBar :TFarPanelLabels;
      FModes  :TFarPanelModes;
      FSort   :Integer;

//    FProgressTick :DWORD;
      FProgressMess :TString;
      FProgressPercent :Integer;

      procedure FillLevel;
      procedure TrackLoad(APage :Integer);
      procedure AlbumLoad(AList :TObjList; const AArtist, AAlbum :TString);
//    procedure AddImageItem(const AInfo :IXMLDOMDocument; const ANodes, AName :TString; AList :TObjList);
//    procedure AddURLItem(const AInfo :IXMLDOMDocument; const ANode, AName, ALabel :TString; AList :TObjList);

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


 {-----------------------------------------------------------------------------}
 { TFarPanelMode                                                               }
 {-----------------------------------------------------------------------------}

  function NewPanelMode(AFlags :Integer; const ATitles :array of TString; const ATypes, AWidths :TString;
    const AStTypes :TString = ''; const AStWidths :TString = '') :TFarPanelMode;
  begin
    Result := TFarPanelMode.CreateEx(AFlags, ATitles, ATypes, AWidths, AStTypes, AStWidths)
  end;


  constructor TFarPanelMode.CreateEx(AFlags :Integer; const ATitles :array of TString; const ATypes, AWidths, AStTypes, AStWidths :TString);
  begin
    inherited Create;
    FFlags := AFlags;
    FTypes := ATypes;
    FWidths := AWidths;
    FStTypes := AStTypes;
    FStWidths := AStWidths;
    FTitles := NewStrs(ATitles);
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
            {!Far2}
           {$endif Far3}
          end;
    end;
    Result := FModes;
  end;


 {-----------------------------------------------------------------------------}
 { TFarPanelLabel                                                              }
 {-----------------------------------------------------------------------------}

  function NewFarLabel(AKey :Integer; const AText :TString; const ALongText :TString = '') :TFarPanelLabel;
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
    MemFree(FTitles);
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


  function TFarPanelLabels.AllocateTitles :{$ifdef Far3}PKeyBarTitles{$else}PKeyBarTitlesArray{$endif};
  var
    I :Integer;
  begin
   {$ifdef Far3}
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
    {!Far2}
    Result := FTitles;
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
      constructor CreateEx(const AName :TString; ALevel :TFarFmLevel; AIsFolder :Boolean = True);
      procedure MakePanelItem(var AItem :TPluginPanelItem); virtual;
      procedure GetFileView(AMode :Integer; var APath :TString); virtual;
      function CanCopy :Boolean; virtual;
      procedure CopyFileTo(const AFileName :TString); virtual;
      function GetFileName :TString; virtual;
    private
      FIsFolder :Boolean;
      FLevel    :TFarFmLevel;
    public
      property IsFolder :Boolean read FIsFolder;
      property Level :TFarFmLevel read FLevel;
      property FileName :TString read GetFileName;
    end;

  constructor TFarFmItem.CreateEx(const AName :TString; ALevel :TFarFmLevel; AIsFolder :Boolean = True);
  begin
    CreateName(AName);
    FLevel := ALevel;
    FIsFolder := AIsFolder;
  end;

  procedure TFarFmItem.MakePanelItem(var AItem :TPluginPanelItem); {virtual;}
  begin
   {$ifdef Far3}
    AItem.FileName := StrNew(FName);
    if IsFolder then
      AItem.FileAttributes := FILE_ATTRIBUTE_DIRECTORY;
   {$else}
    AItem.FindData.cFileName := StrNew(FName);
    if IsFolder then
      AItem.FindData.dwFileAttributes := FILE_ATTRIBUTE_DIRECTORY;
   {$endif Far3}
    Pointer(AItem.UserData) := Self;
  end;


  procedure FreePanelItem(var AItem :TPluginPanelItem);
  begin
   {$ifdef Far3}
    StrDispose(AItem.FileName);
   {$else}
    StrDispose(AItem.FindData.cFileName);
   {$endif Far3}
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
    TFarFmPlaylistItem = class(TFarFmItem)
    public
      constructor CreateEx(const AArtist, AAlbum :TString; const ATracks :TStringArray2);
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;
    public
      FArtist :TString;
      FAlbum  :TString;
      FTracks :TStringArray2;
      procedure ResolveTracks;
      procedure SavePlaylistTo(const AFileName :TString; ALocal :Boolean);
    end;

  constructor TFarFmPlaylistItem.CreateEx(const AArtist, AAlbum :TString; const ATracks :TStringArray2);
  begin
    CreateName(AddFileExtension(AAlbum, cPlaylistExt));
    FArtist := AArtist;
    FAlbum  := AAlbum;
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
    I, N :Integer;
    vList, vURL, vExt :TString;
  begin
    {!!!Unicode}
    vList := cM3UHeader;
    N := length(FTracks);
    for I := 0 to N - 1 do begin
      vURL := FarFm.FindTrackURL(FArtist, FTracks[I, 0], False);
      if ALocal then begin
        vExt := ExtractURLFileExtension(vURL);
        if vExt = '' then
          vExt := cMP3Ext;
        vURL := FormatTrackFileName(FTracks[I, 0], FArtist, '', vExt, I + 1);
      end;
      vList := AppendStrCh(vList, Format(cM3UExtInfo, [Str2IntDef(FTracks[I, 1], 0), FARtist, FTracks[I, 0]]), CRLF);
      vList := AppendStrCh(vList, vURL, CRLF);
    end;
    StrToFile(AFileName, vList, sffAnsi);
  end;


(*
  procedure TFarFmPlaylistItem.ResolveTracks;
  var
    I, N :Integer;
  begin
    FarFm.VKCallsBegin;
    try
      N := length(FTracks);
      for I := 0 to N - 1 do begin
        FarFm.VkCallsProgress('Find tracks', FTracks[I, 0], MulDiv(I, 100, N));
        if FarFm.CheckInterrupt then
          CtrlBreakException;
        FarFm.FindTrackURL(FArtist, FTracks[I, 0], True);
      end;
    finally
      FarFm.VKCallsEnd;
    end;
  end;
*)

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
          if FarFm.FindTrackURL(FArtist, FTracks[I, 0], False) = '' then begin
            FarFm.VKAuthorize;
            vLight := False;
          end;

        if not vLight then begin
          {!!!Localize}
          FarFm.VkCallsProgress('Find tracks', FTracks[I, 0], MulDiv(I, 100, N));
          if FarFm.CheckInterrupt then
            CtrlBreakException;
          FarFm.FindTrackURL(FArtist, FTracks[I, 0], True);
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
      constructor CreateEx(const AName, AArtist :TString; AIndex :Integer; ALength :Integer);
      procedure MakePanelItem(var AItem :TPluginPanelItem); override;
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function GetFileName :TString; override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;

    private
      FArtist :TString;
      FIndex  :Integer;
      FLength :Integer;
      FURL    :TString;

      procedure ResolveTrack(AForce :Boolean);
    end;


  constructor TFarFmTrackItem.CreateEx(const AName, AArtist :TString; AIndex :Integer; ALength :Integer);
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
      AItem.FileName := StrNew(FName)
    else begin
      vName := AddFileExtension(FName, ExtractFileExtension(FURL));
      AItem.FileName := StrNew(vName);
    end;
    Pointer(AItem.UserData) := Self;

   {$ifdef Far3}
    AItem.FileSize := FLength;
   {$else}
    AItem.FindData.nFileSize := FLength;
   {$endif Far3}
    AItem.CustomColumnNumber := 2;
    AItem.CustomColumnData := NewStrs([Int2Str(FIndex), FormatLength(FLength)]);
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
    Navigate('\');
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
    AInfo.Flags := OPIF_ADDDOTS {or OPIF_SHORTCUT};
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
      AInfo.StartPanelMode := byte('0') + 3;
    end;
    AInfo.StartSortMode := FSort;
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
      Navigate(ADir);
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
        J := AList.IndexOf(AItems.FileName);
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
          vPrompt := GetMsgStr(strDeletePrompt) + #10 + AItems.FileName
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
          vItem.GetFileView(AMode, ADestPath);
          Result := True;
        end;
      end else
      begin
        Assert(OPM_SILENT and AMode = 0, 'Silent mode???');
        if FLevel in [fflArtistTracks, fflArtistAlbums, fflAlbum] then
          Result := CopyFilesTo(AItems, ACount, ADestPath);
      end;
    finally
      if (vResolved <> FarFM.FResolved) and opt_ShowResolvedFile then
        FarAdvControl(ACTL_SYNCHRO, TAsyncCommand.CreateEx(Self, cmUpdate, 0));
    end;
  end;


  procedure TFarFmPanel.CopyDownloadCallback(const AURL :TString; ASize :TIntPtr);
  begin
    FarFM.VkCallsProgress(GetMsgStr(strCopying), FProgressMess + ' (' + Int2Str(ASize div 1024) + ' K)', FProgressPercent);
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

      FProgressMess := AItem.FileName;
      FarFM.VkCallsProgress(GetMsgStr(strCopying), FProgressMess, FProgressPercent);

      vDestFolder := AddFileName(ADest, AItem.FileName);
      if not WinFolderExists(vDestFolder) then
        if not CreateDir(vDestFolder) then
          RaiseLastWin32Error;

      vAlbumList := TObjList.Create;
      try
        AlbumLoad(vAlbumList, {Artist:}FStack[2], AItem.Name);
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
      vMode := 0;
      for I := 0 to ACount - 1 do begin
        FProgressPercent := MulDiv(I, 100, ACount);
        vPercent2 := MulDiv(I + 1, 100, ACount);
        J := FItems.IndexOf(AItems.UserData);
        if J <> -1 then begin
          vItem := FItems[J];
          if vItem.IsFolder then begin
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
          FillLevel;
          FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
          FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
          FarPanelSetCurrentItem(True, vName);
          Result := True;
        end;
      cmAddUser:
        if AddUserPrompt(vName) then begin
          FillLevel;
          FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
          FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
          FarPanelSetCurrentItem(True, vName);
          Result := True;
        end;
      cmNextPage:
        if FLevel in [fflArtistTracks] then begin
          TrackLoad(AParam);
          FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
          FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
          Result := True;
        end;
      cmUpdate:
        begin
          for I := 0 to FItems.Count - 1 do begin
            vItem := FItems[I];
            if vItem is TFarFmTrackItem then
              TFarFmTrackItem(vItem).ResolveTrack(False);
          end;
          FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
          FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
        end;
    else
      Sorry;
    end;
  end;

(*
  function TFarFmPanel.AddArtistPrompt(var AName :TString) :Boolean;
  begin
    Result := False;
    {!!!Мастер}
    if FarInputBox('Add artist', 'Name', AName) then begin
      FarFM.Artists.Add( AName );
      FarFM.SaveLocalList(cArtists, FarFM.Artists);
      Result := True;
    end;
  end;
*)
  function TFarFmPanel.AddArtistPrompt(var AName :TString) :Boolean;
  begin
    Result := False;
    {!!!Localize}
    if FindDlg('Add artist', AName) then begin
      FarFM.Artists.Add( AName );
      FarFM.SaveLocalList(cArtists, FarFM.Artists);
      Result := True;
    end;
  end;
  

  function TFarFmPanel.AddUserPrompt(var AName :TString) :Boolean;
  begin
    Result := False;
    {!!!Мастер}
    if FarInputBox('Add user', 'Name', AName) then begin
      FarFM.Users.Add( AName );
      FarFM.SaveLocalList(cUsers, FarFM.Users);
      Result := True;
    end;
  end;


  procedure TFarFmPanel.Navigate(const AFolder :TString);

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

    procedure LocGoInto(ALevel :TFarFmLevel; const AName :TString);
    begin
      PushStack;
      try
        FLevel := ALevel;
        FCurrent := AName;
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
        LocGoInto(vItem.Level, AFolder);
      end else
      begin
        Navigate('\');
        vPtr := PTChar(AFolder);
        while vPtr^ <> #0 do begin
          vStr := ExtractNextWord(vPtr, ['\']);
          Navigate(vStr);
        end;
      end;

    finally
      FPath := AppendStrCh(FStack.GetTextStrEx('\'), FCurrent, '\');
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
    begin
      vDoc := LastFMCall('artist.getInfo', ['artist', FCurrent]);
      FItems.FreeAll;
      AddImageItem(FItems, vDoc, '/lfm/artist/image', FCurrent {'Artist'});
      AddURLItem(FItems, vDoc, '/lfm/artist/url', FCurrent {'ArtistPage'}, FCurrent);
      FItems.Add( TFarFmItem.CreateEx(cTracks, fflArtistTracks) );
      FItems.Add( TFarFmItem.CreateEx(cAlbums, fflArtistAlbums) );
    end;


    procedure LocFillArtistAlbums;
    var
      I :Integer;
      vArtist :TString;
      vAlbums :TStringArray2;
    begin
      vArtist := FStack[2];
      vAlbums := LastFMCall1('artist.getTopAlbums', ['artist', vArtist], '/lfm/topalbums/album', ['name', 'url']);

      FItems.FreeAll;
      for I := 0 to length(vAlbums) - 1 do
        FItems.Add( TFarFmItem.CreateEx(vAlbums[I, 0], fflAlbum ));
    end;


    procedure LocFillUser;
    var
      vDoc :IXMLDOMDocument;
    begin
      vDoc := LastFMCall('user.getInfo', ['user', FCurrent]);

      FItems.FreeAll;
      AddImageItem(FItems, vDoc, '/lfm/user/image', FCurrent {'UserImage'});
      AddURLItem(FItems, vDoc, '/lfm/user/url', FCurrent {'UserPage'}, FCurrent);
      FItems.Add( TFarFmItem.CreateEx(cPlaylists, fflUserPlaylists) );
      FItems.Add( TFarFmItem.CreateEx(cAlbums, fflUserAlbums) );
    end;


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
        FItems.Add( TFarFmItem.CreateEx(vLists[I, 0], fflUserPlaylist) );
    end;

    procedure LocFillUserPlaylist;
    begin
      FItems.FreeAll;
    end;


    procedure LocFillUserAlbums;
    var
      I :Integer;
      vUser :TString;
      vDoc :IXMLDOMDocument;
      vLists :TStringArray2;
    begin
      vUser := ExtractWord(2, FPath, ['\']);
      vDoc := LastFMCall('library.getAlbums', ['user', vUser]);

      vLists := XMLParseArray(vDoc, '/lfm/albums/album', ['name']);

      FItems.FreeAll;
      for I := 0 to length(vLists) - 1 do
        FItems.Add( TFarFmItem.CreateEx(vLists[I, 0], fflUserAlbum) );
    end;

  var
    I, L :Integer;
  begin
    FSort := SM_UNSORTED;

    case FLevel of
      fflRoot: begin
        FItems.FreeAll;
        FItems.Add( TFarFmItem.CreateEx(cArtists, fflArtists) );
//      FItems.Add( TFarFmItem.CreateEx(cAlbums, fflAlbums) );
        FItems.Add( TFarFmItem.CreateEx(cUsers, fflUsers) );
        FItems.Add( TFarFmItem.CreateEx(cAccount, fflAccounts) );
      end;

      fflArtists: begin
        FItems.FreeAll;
        for I := 0 to FarFM.Artists.Count - 1 do
          FItems.Add( TFarFmItem.CreateEx(FarFM.Artists[I], fflArtist) );
        FItems.Add( TFarFmCommand.CreateEx('Add', cmAddArtist, 0) );
      end;
(*
      fflUsers: begin
        FItems.FreeAll;
        for I := 0 to FarFM.Users.Count - 1 do
          FItems.Add( TFarFmItem.CreateEx(FarFM.Users[I], fflUser) );
        FItems.Add( TFarFmCommand.CreateEx('Add', cmAddUser, 0) );
      end;
*)
      fflArtist:
        LocFillArtist;
      fflALbum:
        AlbumLoad(FItems, {Artist:}FStack[2], FCurrent);
      fflArtistTracks:
        TrackLoad(1);
      fflArtistALbums:
        LocFillArtistAlbums;

(*
      fflUser:
        LocFillUser;
      fflUserPlaylists:
        LocFillUserPlaylists;
      fflUserPlaylist:
        LocFillUserPlaylist;
      fflUserAlbums:
        LocFillUserAlbums;
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
      fflALbum, fflArtistTracks:
      begin
        L := length(Int2Str(FItems.Count));
        if FLevel = fflArtistTracks then
          L := IntMax(L, 3);
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, ['N', 'Name', 'Length'], 'C0,N,C1', Int2Str(L) + ',0,5'),
          nil,
          nil,
          NewPanelMode(PMFLAGS_ALIGNEXTENSIONS, ['N', 'Name', 'Length'], 'C0,N,C1', Int2Str(L) + ',0,5')
        ]);
      end;
    else
      if FModes.Count = 0 then
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, ['Name'], 'N', '0'),
          nil,
          nil,
          NewPanelMode(PMFLAGS_ALIGNEXTENSIONS, ['Name'], 'N', '0')
        ]);
    end;

    case FLevel of
      fflArtists, fflUsers:
      begin
        FKeyBar.SetLabels([NewFarLabel(KEY_F3, ''), NewFarLabel(KEY_F4, ''),NewFarLabel(KEY_F5, ''), NewFarLabel(KEY_F6, ''),
          NewFarLabel(KEY_F7, 'Add'),
          NewFarLabel(KEY_F8, 'Delete')
        ]);
      end;
    else
      FKeyBar.SetLabels([NewFarLabel(KEY_F3, ''), NewFarLabel(KEY_F4, ''),NewFarLabel(KEY_F5, ''), NewFarLabel(KEY_F6, ''), NewFarLabel(KEY_F7, ''), NewFarLabel(KEY_F8, '')]);
    end;
  end;


  procedure TFarFmPanel.TrackLoad(APage :Integer);
  var
    I, vTotal :Integer;
    vDoc :IXMLDOMDocument;
    vArtist :TString;
    vTracks :TStringArray2;
  begin
    vArtist := FStack[2];
    vDoc := LastFMCall('artist.getTopTracks', ['artist', vArtist, 'page', Int2Str(APage)]);
    vTotal := Str2IntDef(XMLParseNode(vDoc, '/lfm/toptracks', 'totalPages'), 1);
    vTracks := XMLParseArray(vDoc, '/lfm/toptracks/track', ['name', 'duration', '%rank']);
    if length(vTracks) = 0 then
      Exit;

    if APage = 1 then
      FItems.FreeAll
    else
    if TObject(FItems[FItems.Count - 1]) is TFarFmCommand then
      FItems.FreeAt(FItems.Count - 1);

    FItems.Add(TFarFmPlaylistItem.CreateEx( vArtist, vArtist + ' ' + Int2Str(APage), vTracks ));
    for I := 0 to length(vTracks) - 1 do
      FItems.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vArtist, Str2IntDef(vTracks[I, 2], 0), Str2IntDef(vTracks[I, 1], 0) ));
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

    vTracks := XMLParseArray(vDoc, '/lfm/album/tracks/track', ['name', 'duration']);

    AList.FreeAll;
    AddImageItem(AList, vDoc, '/lfm/album/image', 'Album');
    AddURLItem(AList, vDoc, '/lfm/album/url', AAlbum, AAlbum);
    if length(vTracks) > 0 then begin
      AList.Add(TFarFmPlaylistItem.CreateEx( AArtist, AAlbum, vTracks ));
      for I := 0 to length(vTracks) - 1 do
        AList.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], AArtist, I + 1, Str2IntDef(vTracks[I, 1], 0) ));
    end;
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
          FItems.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vArtist, I + 1, Str2IntDef(vTracks[I, 1], 0) ));

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


end.


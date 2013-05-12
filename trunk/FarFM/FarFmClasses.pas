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
    cmAddArtist      = 1;
    cmAddUser        = 2;
    cmNextPage       = 3;
    cmUpdate         = 4;
    cmAddArtistToLib = 5;

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

      fflMyAccount,
      fflMyArtists,
      fflMyAlbums,
      fflMyTracks,

      fflMyArtist,
      fflMyFrends,
      fflMyFavorites
    );

    TCommand = (
      cmCopy,        { F5 }
      cmAdd,         { F7 }
      cmDelete,      { F8 }
      cmHide,        { F8 }
      cmDropCache,   { ShiftF8 }
      cmFindURL,     { Ctrl-A }
      cmAddFavorite
    );
    TCommands = set of TCommand;

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
      FLevel    :TFarFmLevel;
      FCurrent  :TString;
      FCurInfo  :TString;
      FCommands :TCommands;

      FStack    :TStringList;
      FItems    :TObjList;

      FTitle    :TString;
      FPath     :TString;

      FKeyBar   :TFarPanelLabels;
      FModes    :TFarPanelModes;
      FDefMode  :Integer;
      FDefSort  :Integer;

      FProgressTick :DWORD;
      FProgressTitle :TString;
      FProgressMess :TString;
      FProgressPercent :Integer;

      function GetPassivePanel :TFarFmPanel;
      function GetPanelItem(AIndex :Integer; ASelected :Boolean = True) :TFarFmItem;
//    function GetSelectedList(AIndex :Integer) :TExList;
      procedure DeselectList(AList :TExList);
      procedure UpdatePanel(ARefill :Boolean = False; AHandle :THandle = PANEL_ACTIVE);

      procedure FillLevel;
      procedure TrackLoad(APage :Integer);
      procedure AlbumLoad(AList :TObjList; const AArtist, AAlbum :TString);
//    procedure AddImageItem(const AInfo :IXMLDOMDocument; const ANodes, AName :TString; AList :TObjList);
//    procedure AddURLItem(const AInfo :IXMLDOMDocument; const ANode, AName, ALabel :TString; AList :TObjList);

      procedure ContextMenu;
      procedure UserArtistsLoad(APage :Integer);
      procedure UserAlbumsLoad(APage :Integer);
      procedure UserTrackLoad(APage :Integer);

      procedure LibAlbumsLoad(const AUser, Artist :TString);
      procedure LibTracksLoad(const AUser, Artist :TString; AClear :Boolean = True);

      function DeleteItems(AItems :PPluginPanelItem; ACount :Integer) :Boolean;
      function HideItems(AItems :PPluginPanelItem; ACount :Integer) :Boolean;

      function AddToLibrary :Boolean;
      function FindURLPrompt :Boolean;
      function DropURLCache :Boolean;
      function AddArtistPrompt(var AName :TString) :Boolean;
      function AddUserPrompt(var AName :TString) :Boolean;
      function AddArtistToLibPrompt(var AName :TString) :Boolean;
      procedure CopyDownloadCallback(const AURL :TString; ASize :TIntPtr);
      function CopyFilesTo(AItems :PPluginPanelItem; ACount :Integer; const AFolder :TString) :Boolean;
    end;


  type
    TFarFm = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure LastFMAuthorize;
      procedure LastFMLogout;

      procedure VKAuthorize;
      procedure VkLogout;

      function VKCallsBegin :Boolean;
      procedure VKCallsEnd;
      procedure VkCallsProgress(const ATitle, AMess :TString; APercent :Integer);

      function FindTrackURL(const Artist, Track :TString; AForce :Boolean = True) :TString;
      function SetTrackURL(const Artist, Track, AURL :TString) :Boolean;
      function DropTrackURL(const Artist, Track :TString) :Boolean;
      function FindTrackLirics(const Artist, Track :TString) :TString;

    private
      FArtists    :TStringList;
      FUsers      :TStringList;
      FHideAlbums :TStringList;
      FHideTracks :TStringList;

      FLFMAuth    :Boolean;
      FVKAuth     :Boolean;
      FVKLock     :Integer;
      FScreen     :THandle;

      FTrackCache :TObjList;

      FResolved   :Integer;

      procedure SaveLocalList(const AName :TString; AList :TStringList);
      procedure RestoreLocalList(const AName :TString; AList :TStringList);
      procedure SaveTrackCache;
      procedure RestoreTrackCache;
      procedure StoreTokens(AStore :Boolean; AWhat :Integer = 3);
      function VkFindTrackURL(const Artist, Track :TString; ALiric :Boolean) :TString;

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
    Result := Format('%d) %s', [AIndex, ATrack]);
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
    Result := StrReplace(Result, '&amp;', '&', [rfReplaceAll, rfIgnoreCase]);
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
 { TTmpItem                                                                    }
 {-----------------------------------------------------------------------------}

  type
    TTmpItem = class(TBasis)
    public
      constructor CreateEx(const aArtist, aName :TString; aLength :Integer);
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;
    private
      FArtist :TString;
      FName   :TString;
      FLength :Integer;
    end;

  constructor TTmpItem.CreateEx(const aArtist, aName :TString; aLength :Integer);
  begin
    FArtist := aArtist;
    FName   := aName;
    FLength := aLength;
  end;

  function TTmpItem.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FArtist, TTmpItem(Another).FArtist);
    if Result = 0 then
      Result := UpCompareStr(FName, TTmpItem(Another).FName);
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

  procedure TFarFmItem.MakePanelItem(var AItem :TPluginPanelItem); {virtual;}
  begin
    AItem.FileName := StrNew(FName);
    Pointer(AItem.UserData) := Self;
  end;


  procedure FreePanelItem(var AItem :TPluginPanelItem);
  begin
    StrDispose(AItem.FileName);
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
    AItem.FileAttributes := FILE_ATTRIBUTE_DIRECTORY;
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
      constructor CreateEx(const ATitle, AArtist, AAlbum :TString);
      procedure MakePanelItem(var AItem :TPluginPanelItem); override;

    private
      FArtist :TString;
      FAlbum  :TString;

    public
      property Artist :TString read FArtist;
      property Album :TString read FAlbum;
    end;


  constructor TFarFmAlbum.CreateEx(const ATitle, AArtist, AAlbum :TString);
  begin
    inherited CreateEx(ATitle, AArtist + #9 + AAlbum, fflAlbum);
    FArtist := AArtist;
    FAlbum := AAlbum;
  end;


  procedure TFarFmAlbum.MakePanelItem(var AItem :TPluginPanelItem); {override;}
  begin
    inherited MakePanelItem(AItem);

    if FarFm.FHideAlbums.IndexOf(FInfo) <> -1 then
      AItem.FileAttributes := AItem.FileAttributes or FILE_ATTRIBUTE_HIDDEN;

    AItem.CustomColumnNumber := 2;
    AItem.CustomColumnData := NewStrs([FArtist, FAlbum]);
  end;

 {---------------------------------------}

  type
    TFarFmPlaylistItem = class(TFarFmItem)
    public
      constructor CreateEx(const AName :TString; const ATracks :TStringArray2);
      constructor CreateEx2(const AName :TString; ATracks :TExList);
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


  constructor TFarFmPlaylistItem.CreateEx2(const AName :TString; ATracks :TExList);
  var
    i :Integer;
  begin
    CreateName(AddFileExtension(AName, cPlaylistExt));
    SetLength(FTracks, ATracks.Count, 3);
    for i := 0 to ATracks.Count - 1 do
      with TTmpItem(ATracks[i]) do begin
        FTracks[i, 0] := FName;
        FTracks[i, 1] := FArtist;
        FTracks[i, 2] := Int2Str(FLength);
      end;
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
      if FarFm.FHideTracks.IndexOf(FTracks[I, 1] + #9 + FTracks[I, 0]) <> -1 then
        Continue;

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
        if FarFm.FHideTracks.IndexOf(FTracks[I, 1] + #9 + FTracks[I, 0]) <> -1 then
          Continue;

        if vLight then
          if FarFm.FindTrackURL(FTracks[I, 1], FTracks[I, 0], False) = '' then begin
            FarFm.VKAuthorize;
            vLight := False;
          end;

        if not vLight then begin
          FarFm.VkCallsProgress(GetMsgStr(strFindTracks), FTracks[I, 0], MulDiv(I, 100, N));
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
      constructor CreateEx(const ATitle, AArtist, ATrack :TString; ALength :Integer; AIndex :Integer);
      procedure MakePanelItem(var AItem :TPluginPanelItem); override;
      procedure GetFileView(AMode :Integer; var APath :TString); override;
      function GetFileName :TString; override;
      function CanCopy :Boolean; override;
      procedure CopyFileTo(const AFileName :TString); override;

      procedure UnResolveTrack;

    private
      FArtist :TString;
      FTrack  :TString;
      FIndex  :Integer;
      FLength :Integer;
      FURL    :TString;

      procedure ResolveTrack(AForce :Boolean);

    public
      property Artist :TString read FArtist;
      property Track :TString read FTrack;
    end;


  constructor TFarFmTrackItem.CreateEx(const ATitle, AArtist, ATrack :TString; ALength :Integer; AIndex :Integer);
  begin
    CreateName(ATitle);
    FArtist := AArtist;
    FTrack := ATrack;
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

    if FarFm.FHideTracks.IndexOf(FArtist + #9 + FTrack) <> -1 then
      AItem.FileAttributes := AItem.FileAttributes or FILE_ATTRIBUTE_HIDDEN;

    AItem.FileSize := FLength;
    AItem.CustomColumnNumber := 4;
    AItem.CustomColumnData := NewStrs([Int2Str(FIndex), FArtist, FTrack, FormatLength(FLength)]);
  end;


  procedure TFarFmTrackItem.GetFileView(AMode :Integer; var APath :TString); {override;}
  var
    vName, vList :TString;
  begin
    if OPM_EDIT and AMode <> 0 then begin
      vList := FarFM.FindTrackLirics(FArtist, FTrack);
      vName := AddFileName(APath, CleanFileName(FName)) + '.' + cTXTExt;
      StrToFile(vName, vList);
    end else
    begin
      if FURL = '' then
        ResolveTrack(True);

      vName := AddFileName(APath, CleanFileName(FName)) + '.' + cPlaylistExt;

      vList := cM3UHeader;
      vList := AppendStrCh(vList, Format(cM3UExtInfo, [FLength, FArtist, FTrack]), CRLF);
      vList := AppendStrCh(vList, FURL, CRLF);

      {!!!Unicode}
      StrToFile(vName, vList, sffAnsi);
    end;
  end;


  function TFarFmTrackItem.CanCopy :Boolean; {override;}
  begin
    if FURL = '' then
      ResolveTrack(True);
    Result := FURL <> '';
  end;


  function TFarFmTrackItem.GetFileName :TString; {override;}
  begin
//  Result := FormatTrackFileName(FTrack, FArtist, '', ExtractFileExtension(FURL), FIndex);
    Result := FormatTrackFileName(FName, '', '', ExtractFileExtension(FURL), FIndex);
  end;


  procedure TFarFmTrackItem.CopyFileTo(const AFileName :TString); {override;}
  begin
    HTTPDownload(FURL, AFileName);
  end;


  procedure TFarFmTrackItem.ResolveTrack(AForce :Boolean);
  begin
    FURL := FarFm.FindTrackURL(FArtist, FTrack, AForce);
  end;


  procedure TFarFmTrackItem.UnResolveTrack;
  begin
    FarFm.DropTrackURL(FArtist, FTrack);
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
    if not (cmAdd in FCommands) then
      Exit;
    case FLevel of
      fflArtists:
        Result := AddArtistPrompt(ADir);
      fflUsers:
        Result := AddUserPrompt(ADir);
      fflMyArtists:
        Result := AddArtistToLibPrompt(ADir);
    end;
    if Result then
      FillLevel;
  end;


  function TFarFmPanel.DeleteFiles(AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean;
  begin
    Result := False;
    Assert(OPM_SILENT and AMode = 0, 'Silent mode???');
    if cmDelete in FCommands then
      Result := DeleteItems(AItems, ACount)
    else
    if cmHide in FCommands then
      Result := HideItems(AItems, ACount)
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
        if cmCopy in FCommands then
          Result := CopyFilesTo(AItems, ACount, ADestPath);
      end;
    finally
      if (vResolved <> FarFM.FResolved) and opt_ShowResolvedFile then
        FarAdvControl(ACTL_SYNCHRO, TAsyncCommand.CreateEx(Self, cmUpdate, 0));
    end;
  end;


  function TFarFmPanel.ProcessInput(AKey :Integer) :Boolean;
  begin
    Result := True;
    case AKey of
      KEY_F5:
        if (cmAddFavorite in FCommands) and (GetPassivePanel <> nil) then
          AddToLibrary
        else
          Result := False;
    
      KEY_SHIFTF1 : ContextMenu;
      KEY_SHIFTF5 : AddToLibrary;
      KEY_SHIFTF8 : DropURLCache;
      KEY_CTRLA   : FindURLPrompt;
    else
      Result := False;
    end;
  end;

  procedure TFarFmPanel.ContextMenu;

    procedure LocLFMLogin;
    begin
      if FLFM_SK = '' then
        FarFM.LastFMAuthorize
      else
        FarFM.LastFMLogout
    end;

    procedure LocVKLogin;
    begin
      if FVKToken = '' then
        FarFM.VKAuthorize
      else
        FarFM.VkLogout
    end;

  var
    vMenu :TFarMenu;
    vStr1, vStr2 :TString;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMAdd),
      GetMsg(strMDelete),
      '',
      GetMsg(strMCopy),
      GetMsg(strMAddToLib),
      '',
      GetMsg(strMFindURL),
      GetMsg(strMClearCache),
      '',
      GetMsg(strMAuthLFM),
      GetMsg(strMAuthVK)
    ]);
    try
      vStr1 := vMenu.Items[9].TextPtr + StrIf(FLFM_SK  = '', 'Login', 'Logout ' + FLFMUser);
      vStr2 := vMenu.Items[10].TextPtr + StrIf(FVKToken = '', 'Login', 'Logout ' + FVKUser);

      vMenu.Enabled[0] := cmAdd in FCommands;
      vMenu.Enabled[1] := (cmDelete in FCommands) or (cmHide in FCommands);
      vMenu.Enabled[3] := cmCopy in FCommands;
      vMenu.Enabled[4] := cmAddFavorite in FCommands;
      vMenu.Enabled[6] := cmFindURL in FCommands;
      vMenu.Enabled[7] := cmDropCache in FCommands;

      vMenu.Items[9].TextPtr := PTChar(vStr1);
      vMenu.Items[10].TextPtr := PTChar(vStr2);

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: FarPostMacro(FarKeyToMacro('F7'));
        1: FarPostMacro(FarKeyToMacro('F8'));

        3: FarPostMacro(FarKeyToMacro('F5'));
        4: AddToLibrary;

        6: FindURLPrompt;
        7: DropURLCache;

        9: LocLFMLogin;
       10: LocVKLogin;
      end;

    finally
      FreeObj(vMenu);
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
      cmAddArtistToLib:
        if AddArtistToLibPrompt(vName) then begin
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
    if FindDlg('', AName) then begin
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


  function TFarFmPanel.AddArtistToLibPrompt(var AName :TString) :Boolean;
  begin
    Result := False;
    if FindDlg('', AName) then begin
      LastFmPost('library.addArtist', ['artist', AName]);
      Result := True;
    end;
  end;


  function TFarFmPanel.DeleteItems(AItems :PPluginPanelItem; ACount :Integer) :Boolean;

    procedure LocDelete(AList :TStringList; AItem :TFarFmItem);
    var
      J :Integer;
    begin
      J := AList.IndexOf(AItem.Name);
      if J <> -1 then
        AList.Delete(J);
    end;

    procedure LocDeleteArtistFromLib(AItem :TFarFmItem);
    begin
      LastFmPost('library.removeArtist', ['artist', AItems.FileName]);
    end;

    procedure LocDeleteAlbumFromLib(AItem :TFarFmItem);
    begin
      if AItem is TFarFmAlbum then
        LastFmPost('library.removeAlbum', ['artist', TFarFmAlbum(AItem).Artist, 'album', TFarFmAlbum(AItem).Album]);
    end;

    procedure LocDeleteTracksFromLib(AItem :TFarFmItem);
    begin
      if AItem is TFarFmTrackItem then
        LastFmPost('library.removeTrack', ['artist', TFarFmTrackItem(AItem).Artist, 'track', TFarFmTrackItem(AItem).Track]);
    end;

  var
    i, j :Integer;
    vPrompt :TString;
    vItem :TFarFmItem;
  begin
    Result := False;

    if ACount = 1 then begin
      vItem := Pointer(AItems.UserData);
      if (vItem = nil) or (vItem is TFarFmCommand) then
        Exit;
    end;

    if ACount = 1 then
      vPrompt := GetMsgStr(strDeletePrompt) + #10 + AItems.FileName
    else
      vPrompt := Format(GetMsgStr(strDeletePromptN), [ACount]);
    if ShowMessageBut(GetMsgStr(strDelete), vPrompt, [GetMsgStr(strDeleteBut), GetMsgStr(strCancel)]) <> 0 then
      Exit;

    FarFm.VKCallsBegin;
    try
      try
        for i := 0 to ACount - 1 do begin
          j := FItems.IndexOf(Pointer(AItems.UserData));
          if J <> -1 then begin
            vItem := FItems[j];

            FarFm.VkCallsProgress(GetMsgStr(strDelete), vItem.Name, MulDiv(i, 100, ACount));
            if FarFm.CheckInterrupt then
              CtrlBreakException;

            case FLevel of
              fflArtists     : LocDelete(FarFM.Artists, vItem);
              fflUsers       : LocDelete(FarFM.Users, vItem);
              fflMyArtists   : LocDeleteArtistFromLib(vItem);
              fflMyAlbums    : LocDeleteAlbumFromLib(vItem);
              fflMyTracks    : LocDeleteTracksFromLib(vItem);
              fflMyFavorites :
                if vItem is TFarFmAlbum then
                  LocDeleteAlbumFromLib(vItem)
                else
                  LocDeleteTracksFromLib(vItem);
            end;
          end;
          Inc(Pointer1(AItems), SizeOf(TPluginPanelItem));
        end;

      finally
        case FLevel of
          fflArtists : FarFM.SaveLocalList(cArtists, FarFM.Artists);
          fflUsers   : FarFM.SaveLocalList(cUsers, FarFM.Users);
        end;

        FarFm.VkCallsProgress(GetMsgStr(strDelete), GetMsgStr(strRefreshPanel), -1);
        FillLevel;
      end;

    finally
      FarFm.VKCallsEnd;
    end;
  end;


  function TFarFmPanel.HideItems(AItems :PPluginPanelItem; ACount :Integer) :Boolean;
  var
    vHide :Boolean;

    function LocMsg(AMess :TMessages) :TString;
    begin
      if not vHide then
        Inc(AMess);
      Result := GetMsgStr(AMess);
    end;

    procedure LocHide(const AName :TString; AList :TStringList);
    var
      I, J :Integer;
      vItem :TFarFmItem;
      vKey :TString;
    begin
      for I := 0 to ACount - 1 do begin
        if FItems.IndexOf(Pointer(AItems.UserData)) <> -1 then begin
          vItem := Pointer(AItems.UserData);
          vKey := '';
          if vItem is TFarFmAlbum then
            vKey := TFarFmAlbum(vItem).Artist + #9 + TFarFmAlbum(vItem).Album
          else
          if vItem is TFarFmTrackItem then
            vKey := TFarFmTrackItem(vItem).Artist + #9 + TFarFmTrackItem(vItem).Track;
          if vKey <> '' then begin
            J := AList.IndexOf(vKey);
            if vHide and (J = -1) then
              AList.Add(vKey)
            else
            if not vHide and (J <> -1) then
              AList.Delete(J);
          end;
        end;
        Inc(Pointer1(AItems), SizeOf(TPluginPanelItem));
      end;
      FarFM.SaveLocalList(AName, AList);
//    FillLevel;
      UpdatePanel(True);
    end;

  var
    vPrompt :TString;
    vItem :TFarFmItem;
  begin
    Result := False;

    if (ACount = 1) then begin
      vItem := Pointer(AItems.UserData);
      if not ((vItem is TFarFmAlbum) or (vItem is TFarFmTrackItem)) then
        Exit;
    end;

    vHide := AItems.FileAttributes and FILE_ATTRIBUTE_HIDDEN = 0;

    if ACount = 1 then
      vPrompt := LocMsg(strHidePrompt) + #10 + AItems.FileName
    else
      vPrompt := Format(LocMsg(strHidePromptN), [ACount]);
    if ShowMessageBut(LocMsg(strHide), vPrompt, [LocMsg(strHideBut), GetMsgStr(strCancel)]) <> 0 then
      Exit;

    case FLevel of
      fflArtistAlbums, fflUserAlbums:
        LocHide(cHiddenAlbums, FarFM.FHideAlbums);
      fflAlbum, fflArtistTracks, fflUserTracks:
        LocHide(cHiddenTracks, FarFM.FHideTracks);
    end;

    Result := True;
  end;


  function TFarFmPanel.DropURLCache :Boolean;

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
        AlbumLoad(vAlbumList, {Artist:}TFarFmAlbum(AItem).Artist, {Album:}TFarFmAlbum(AItem).Album);
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
    if not (cmDropCache in FCommands) then
      Exit;

    FarGetPanelInfo(PANEL_ACTIVE, vInfo);
    if vInfo.SelectedItemsNumber <= 1 then begin
      vItem := GetPanelItem(0);
      if not ((vItem is TFarFmFolder) or ((vItem is TFarFmTrackItem) and (TFarFmTrackItem(vItem).FURL <> ''))) then
        Exit;
      vStr := vItem.Name;
    end;

    if vInfo.SelectedItemsNumber <= 1 then
      vPrompt := GetMsgStr(strClearPrompt) + #10 + vStr
    else
      vPrompt := Format(GetMsgStr(strClearPromptN), [vInfo.SelectedItemsNumber]);
    if ShowMessageBut(GetMsgStr(strClear), vPrompt, [GetMsgStr(strClearBut), GetMsgStr(strCancel)]) <> 0 then
      Exit;

    for I := 0 to vInfo.SelectedItemsNumber - 1 do begin
      vItem := GetPanelItem(I);
      if vItem is TFarFmFolder then
        LocClearGroup(TFarFmFolder(vItem))
      else
      if vItem is TFarFmTrackItem then
        TFarFmTrackItem(vItem).UnResolveTrack;
    end;

    UpdatePanel(True);
    Result := True;
  end;


  function TFarFmPanel.FindURLPrompt :Boolean;
  var
    vInfo :TPanelInfo;
    vItem :TFarFmItem;
    vKey, vNewURL :TString;
  begin
    Result := False;
    try
      if not (cmFindURL in FCommands) then
        Exit;

      if not FarGetPanelInfo(PANEL_ACTIVE, vInfo) then
        Abort;
      if vInfo.SelectedItemsNumber > 1 then
        Abort;
      vItem := GetPanelItem(0);
      if not (vItem is TFarFmTrackItem) then
        Abort;

      FarFm.VKAuthorize;
      with TFarFmTrackItem(vItem) do begin
        vKey := Artist + ' ' + Track;
        if FindUrlDlg(vKey, FURL, vNewURL) then begin
          FarFM.SetTrackURL(Artist, Name, vNewURL);
          FURL := vNewURL;
          UpdatePanel(False);
        end;
      end;

    except
      on E :Exception do begin
        if E is EAbort then
          Beep;
        raise;
      end;
    end;
  end;


  function TFarFmPanel.AddToLibrary :Boolean;

    procedure LocAddArtist(AItem :TFarFmItem);
    begin
      if (AItem is TFarFmFolder) and (TFarFmFolder(AItem).Level = fflArtist) then begin
        LastFmPost('library.addArtist', ['artist', AItem.Name]);
      end;
    end;

    procedure LocAddAlbum(AItem :TFarFmItem);
    begin
      if AItem is TFarFmAlbum then begin
        LastFmPost('library.addAlbum', ['artist', TFarFmAlbum(AItem).Artist, 'album', TFarFmAlbum(AItem).Album]);
      end;
    end;

    procedure LocAddTrack(AItem :TFarFmItem);
    begin
      if AItem is TFarFmTrackItem then begin
        LastFmPost('library.addTrack', ['artist', TFarFmTrackItem(AItem).Artist, 'track', TFarFmTrackItem(AItem).Track]);
      end;
    end;

  var
    I, vCount :Integer;
    vInfo :TPanelInfo;
    vItem :TFarFmItem;
    vStr, vPrompt :TString;
    vPanel :TFarFmPanel;
    vList :TExList;
  begin
    Result := False;
    if not (cmAddFavorite in FCommands) then
      Exit;

    FarGetPanelInfo(PANEL_ACTIVE, vInfo);
    vCount := vInfo.SelectedItemsNumber;
    if vCount <= 1 then begin
      vItem := GetPanelItem(0);
      if not ((vItem is TFarFmFolder) or (vItem is TFarFmTrackItem)) then
        Exit;
      vStr := vItem.Name;
    end;

    if vCount <= 1 then
      vPrompt := GetMsgStr(strAddToLibPrompt) + #10 + vStr
    else
      vPrompt := Format(GetMsgStr(strAddToLibPromptN), [vCount]);
    if ShowMessageBut(GetMsgStr(strAddToLib), vPrompt, [GetMsgStr(strAddToLibBut), GetMsgStr(strCancel)]) <> 0 then
      Exit;

    { Обновляем пассивную панель, если на ней FarFM }
    vPanel := GetPassivePanel;
    vList := TExList.Create;
    try
      FarFm.VKCallsBegin;
      try
        try
          for I := 0 to vCount - 1 do begin
            vItem := GetPanelItem(I);

            FarFm.VkCallsProgress(GetMsgStr(strAddToLib), vItem.Name, MulDiv(i, 100, vCount));
            if FarFm.CheckInterrupt then
              CtrlBreakException;

            case FLevel of
              fflArtists, fflUserArtists, fflArtistSimilar:
                LocAddArtist(vItem);
              fflArtistAlbums, fflUserAlbums:
                LocAddAlbum(vItem);
              fflAlbum, fflArtistTracks, fflUserTracks:
                LocAddTrack(vItem);
            end;

            vList.Add( vItem );
          end;

        finally
          if vPanel <> nil then begin
            FarFm.VkCallsProgress(GetMsgStr(strAddToLib), GetMsgStr(strRefreshPanel), -1);
            vPanel.FillLevel; //UpdatePanel(True, PANEL_PASSIVE);
          end;
        end;

      finally
        FarFm.VKCallsEnd;
      end;

    finally
      DeselectList(vList);
      FreeObj(vList);
      if vPanel <> nil then
        vPanel.UpdatePanel(False, PANEL_PASSIVE);
    end;
  end;


 {-----------------------------------------------------------------------------}

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
            vRes := ShowMessageBut(GetMsgStr(strWarning), GetMsgStr(strFileExists) + #10 + vFileName,
              [GetMsgStr(strOverwriteBut), GetMsgStr(strAllBut), GetMsgStr(strSkipBut), GetMsgStr(strSkipAllBut), GetMsgStr(strCancel)],
              FMSG_WARNING);
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
        AlbumLoad(vAlbumList, TFarFmAlbum(AItem).Artist, TFarFmAlbum(AItem).Album);
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


 {-----------------------------------------------------------------------------}

  function TFarFmPanel.GetPassivePanel :TFarFmPanel;
 {$ifdef Far3}
  var
    vInfo :TPanelInfo;
  begin
    Result := nil;
    if FarGetPanelInfo(PANEL_PASSIVE, vInfo) then
      if IsEqualGUID(vInfo.OwnerGuid, cPluginID) then begin
        Assert( TObject(vInfo.PluginHandle) is TFarFmPanel );
        Result := TFarFmPanel(vInfo.PluginHandle);
      end;
 {$else}
  begin
    Result := nil;
 {$endif Far3}
  end;


  function TFarFmPanel.GetPanelItem(AIndex :Integer; ASelected :Boolean = True) :TFarFmItem;
  var
    vPanelItem :PPluginPanelItem;
  begin
    Result := nil;
    vPanelItem := FarPanelItem(PANEL_ACTIVE, IntIf(ASelected, FCTL_GETSELECTEDPANELITEM, FCTL_GETPANELITEM), AIndex);
    if vPanelItem <> nil then
      try
        if FItems.IndexOf(Pointer(vPanelItem.UserData)) <> -1 then
          Result := Pointer(vPanelItem.UserData);
      finally
        MemFree(vPanelItem);
      end;
  end;


  procedure TFarFmPanel.DeselectList(AList :TExList);
  var
    i :Integer;
    vInfo :TPanelInfo;
    vHandle :THandle;
  begin
    vHandle := PANEL_ACTIVE;
    FARAPI.Control(vHandle, FCTL_BEGINSELECTION, 0, nil);
    try
      if FarGetPanelInfo(vHandle, vInfo) then begin
        for i := 0 to vInfo.ItemsNumber - 1 do
          if AList.IndexOf( GetPanelItem(i, False) ) <> -1 then
            FARAPI.Control(vHandle, FCTL_SETSELECTION, i, nil )
      end;
    finally
      FARAPI.Control(vHandle, FCTL_ENDSELECTION, 0, nil);
      FARAPI.Control(vHandle, FCTL_REDRAWPANEL, 0, nil);
    end;
  end;

(*
  procedure TFarFmPanel.DeselectList(AList :TIntList);
  var
    i :Integer;
  begin
    FARAPI.Control(PANEL_ACTIVE, FCTL_BEGINSELECTION, 0, nil);
    try
      for i := 0 to AList.Count - 1 do
        if AList[i] <> -1 then
          FARAPI.Control(PANEL_ACTIVE, FCTL_SETSELECTION, AList[i], nil)
    finally
      FARAPI.Control(PANEL_ACTIVE, FCTL_ENDSELECTION, 0, nil);
      FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);
    end;
  end;
*)

(*
  function TFarFmPanel.GetSelectedList(AIndex :Integer) :TExList;
  var
    I :Integer;
    vInfo :TPanelInfo;
    vItem :TFarFmItem;
  begin
    Result := TExList.Create;
    try
      FarGetPanelInfo(PANEL_ACTIVE, vInfo);
      for I := 0 to vInfo.SelectedItemsNumber - 1 do begin
        vItem := GetPanelItem(I);
        if vItem <> nil then
          Result.Add(vItem);
      end;
    except
      FreeObj(Result);
      raise;
    end;
  end;
*)

  procedure TFarFmPanel.UpdatePanel(ARefill :Boolean = False; AHandle :THandle = PANEL_ACTIVE);
  begin
    if ARefill then
      FillLevel;
    FARAPI.Control(AHandle, FCTL_UPDATEPANEL, 0, nil);
    FARAPI.Control(AHandle, FCTL_REDRAWPANEL, 0, nil);
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
          AppErrorFmt('Unknown folder name:'#10'%s', [AFolder]);

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
      FTitle := StrReplace(FTitle, '\' + cAccount, '\' + FLFMUser, []);  
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

    procedure LocFillArtist(AddFavorites :Boolean);
    var
      vDoc :IXMLDOMDocument;
      vInfo :TString;
    begin
      vDoc := LastFMCall('artist.getInfo', ['artist', FCurrent, 'lang', opt_InfoLang]);

      vInfo := ClearTags(XMLParseNode(vDoc, '/lfm/artist/bio/summary'));
//    vInfo := ClearTags(XMLParseNode(vDoc, '/lfm/artist/bio/content'));

      FItems.FreeAll;
      AddImageItem(FItems, vDoc, '/lfm/artist/image', FCurrent {'Artist'});
      AddURLItem(FItems, vDoc, '/lfm/artist/url', FCurrent {'ArtistPage'}, FCurrent);
      if vInfo <> '' then
        FItems.Add( TFarInfoItem.CreateEx(cInformation, vInfo) );
      if AddFavorites then
        FItems.Add( TFarFmFolder.CreateEx(cFavorites, '', fflMyFavorites) );
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
        FItems.Add( TFarFmAlbum.CreateEx(vAlbums[I, 0], vArtist, vAlbums[I, 0]) );
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


    procedure LocFillUserInfo(const AName :TString);
    var
      vDoc :IXMLDOMDocument;
      vStr, vInfo :TString;
    begin
      vDoc := LastFMCall('user.getInfo', ['user', AName]);

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
      AddImageItem(FItems, vDoc, '/lfm/user/image', AName {'UserImage'});
      AddURLItem(FItems, vDoc, '/lfm/user/url', AName {'UserPage'}, FCurrent);
      if vInfo <> '' then
        FItems.Add( TFarInfoItem.CreateEx(cInformation, vInfo) );
    end;


    procedure LocFillUser;
    begin
      LocFillUserInfo(FCurrent);
      FItems.Add( TFarFmFolder.CreateEx(cArtists, '', fflUserArtists) );
      FItems.Add( TFarFmFolder.CreateEx(cAlbums, '', fflUserAlbums) );
      FItems.Add( TFarFmFolder.CreateEx(cTracks, '', fflUserTracks) );
//    FItems.Add( TFarFmFolder.CreateEx(cPlaylists, '', fflUserPlaylists) );
    end;


    procedure LocFillMyArtists;
    var
      I :Integer;
      vArtists :TStringArray2;
      vList :TStringList;
    begin
      vArtists := LastFMCall1('library.getArtists', ['user', FLFMUser, 'limit', '1000'], '/lfm/artists/artist', ['name', 'playcount']);

      vList := TStringList.Create;
      try
        vList.Sorted := True;
        for I := 0 to length(vArtists) - 1 do
          vList.Add( vArtists[I, 0] );

        FItems.FreeAll;
        for I := 0 to vList.Count - 1 do
          FItems.Add( TFarFmFolder.CreateEx(vList[I], '', fflMyArtist) );

        FItems.Add( TFarFmCommand.CreateEx('Add', cmAddArtistToLib, 0) );
      finally
        FreeObj(vList);
      end;
    end;


    procedure LocFillArtistFavorites;
    var
      vArtist :TString;
    begin
      vArtist := FStack[FStack.Count - 1];
      LibAlbumsLoad(FLFMUser, vArtist);
      LibTracksLoad(FLFMUser, vArtist, False);
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
        FItems.Add( TFarFmFolder.CreateEx(cAccount, '', fflMyAccount) );
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
        LocFillArtist(False);
      fflArtistTracks:
        TrackLoad(1);
      fflArtistAlbums:
        LocFillArtistAlbums;
      fflArtistSimilar:
        LocFillArtistSimilar;
      fflAlbum:
        AlbumLoad(FItems, {Artist:}ExtractWord(1, FCurInfo, [#9]), {Album:}ExtractWord(2, FCurInfo, [#9]));

      fflUser:
        LocFillUser;
      fflUserArtists:
        UserArtistsLoad(1);
      fflUserAlbums:
        UserAlbumsLoad(1);
      fflUserTracks:
        UserTrackLoad(1);
//      LibTracksLoad(FStack[FStack.Count - 1], '');

      fflMyAccount:
        begin
          FarFM.LastFMAuthorize;
          LocFillUserInfo(FLFMUser);
          FItems.Add( TFarFmFolder.CreateEx(cArtists, '', fflMyArtists) );
          FItems.Add( TFarFmFolder.CreateEx(cAlbums, '', fflMyAlbums) );
          FItems.Add( TFarFmFolder.CreateEx(cTracks, '', fflMyTracks) );
        end;
      fflMyArtists:
        LocFillMyArtists;
      fflMyAlbums:
        LibAlbumsLoad(FLFMUser, '');
      fflMyTracks:
        LibTracksLoad(FLFMUser, '');
      fflMyArtist:
        LocFillArtist(True);

      fflMyFavorites:
        LocFillArtistFavorites;
    else
      Sorry;
    end;

    FCommands := [];
    case FLevel of
      fflArtists        : FCommands := [cmAdd, cmDelete, cmAddFavorite];
      fflUsers          : FCommands := [cmAdd, cmDelete];
      fflArtistAlbums   : FCommands := [cmCopy, cmHide, cmDropCache, cmAddFavorite];
      fflArtistTracks   : FCommands := [cmCopy, cmHide, cmDropCache, cmFindURL, cmAddFavorite ];
      fflArtistSimilar  : FCommands := [cmAddFavorite];
      fflAlbum          : FCommands := [cmCopy, cmHide, cmDropCache, cmFindURL, cmAddFavorite ];
      fflUserArtists    : FCommands := [cmAddFavorite];
      fflUserAlbums     : FCommands := [cmCopy, cmHide, cmDropCache, cmAddFavorite];
      fflUserTracks     : FCommands := [cmCopy, cmHide, cmDropCache, cmFindURL, cmAddFavorite ];

      fflMyArtists      : FCommands := [cmAdd, cmDelete];
      fflMyAlbums       : FCommands := [{cmAdd,} cmDelete, cmCopy, cmDropCache];
      fflMyTracks       : FCommands := [{cmAdd,} cmDelete, cmCopy, cmDropCache, cmFindURL];

      fflMyFavorites    : FCommands := [{cmAdd,} cmDelete, cmCopy, cmDropCache{, cmFindURL}];

//    fflRoot, fflArtist, fflMyArtist, fflUser, fflAccounts
    end;

    FModes.FreeAll;
    case FLevel of
      fflAlbum, fflArtistTracks, fflUserTracks, fflMyTracks:
      begin
        L := length(Int2Str(FItems.Count));
        if FLevel <> fflAlbum then
          L := IntMax(L, 3);
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, [strN, strArtist, strTrack, strLength], 'C0,C1,C2,C3', Int2Str(L) + ',0,0,5'),
          nil, nil,
          NewPanelMode(0, [strN, strName, strLength], 'C0,N,C3', Int2Str(L) + ',0,5'),
          NewPanelMode(0, [strN, strTrack, strArtist, strLength], 'C0,C2,C1,C3', Int2Str(L) + ',0,0,5'),
          NewPanelMode(0, [strN, strArtist, strTrack, strLength], 'C0,C1,C2,C3', Int2Str(L) + ',0,0,5')
        ]);
      end;

      fflArtistAlbums, fflUserAlbums, fflMyAlbums:
      begin
        FModes.SetModes([
          NewPanelMode(PMFLAGS_FULLSCREEN, [strArtist, strAlbum], 'C0,C1', '0,0'),
          nil, nil,
          NewPanelMode(0, [strName], 'N', '0'),
          NewPanelMode(0, [strAlbum, strArtist], 'C1,C0', '0,0'),
          NewPanelMode(0, [strArtist, strAlbum], 'C0,C1', '0,0')
        ]);
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
      NewFarLabel(KEY_ShiftF3), NewFarLabel(KEY_ShiftF4), NewFarLabel(KEY_ShiftF5), NewFarLabel(KEY_ShiftF6), NewFarLabel(KEY_ShiftF7), NewFarLabel(KEY_ShiftF8),
      NewFarLabel(KEY_AltF3), NewFarLabel(KEY_AltF4), NewFarLabel(KEY_AltF5), NewFarLabel(KEY_AltF6)
    ]);
    if cmCopy in FCommands then
      TFarPanelLabel(FKeyBar[2]).FText := GetMsgStr(strCmdCopy);
    if cmAdd in FCommands then
      TFarPanelLabel(FKeyBar[4]).FText := GetMsgStr(strCmdAdd);
    if cmDelete in FCommands then
      TFarPanelLabel(FKeyBar[5]).FText := GetMsgStr(strCmdDelete);
    if cmHide in FCommands then
      TFarPanelLabel(FKeyBar[5]).FText := GetMsgStr(strCmdHide);
    if cmAddFavorite in FCommands then
      TFarPanelLabel(FKeyBar[8]).FText := GetMsgStr(strCmdToLib);
    if cmDropCache in FCommands then
      TFarPanelLabel(FKeyBar[11]).FText := GetMsgStr(strCmdClear);
  end;


  procedure TFarFmPanel.TrackLoad(APage :Integer);
  var
    I, J, vTotal :Integer;
    vDoc :IXMLDOMDocument;
    vTitle, vArtist :TString;
    vTracks :TStringArray2;
    vList :TObjList;
    vItem :TFarFmItem;
  begin
    vList := nil;
    if opt_CheckDuplicate then
      vList := TObjList.Create;
    try
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

      if vList <> nil then begin
        vList.Options := [];
        for I := 0 to FItems.Count - 1 do begin
          vItem := FItems[I];
          if vItem is TFarFmTrackItem then
            vList.AddSorted(vItem, 0, dupIgnore);
        end;
      end;

      FItems.Add(TFarFmPlaylistItem.CreateEx( vArtist + ' ' + Int2Str(APage), vTracks ));
      for I := 0 to length(vTracks) - 1 do begin
        vTitle := vTracks[I, 0];
        if (vList = nil) or not vList.FindKey( Pointer(vTracks[I, 0]), 0, [foBinary], J) then begin
          vItem := TFarFmTrackItem.CreateEx(vTitle, vTracks[I, 1], vTitle, Str2IntDef(vTracks[I, 2], 0), Str2IntDef(vTracks[I, 3], 0));
          if vList <> nil then
            vList.AddSorted(vItem, 0, dupIgnore);  
          FItems.Add( vItem );
        end;
      end;

      if APage < vTotal then
        FItems.Add(TFarFmCommand.CreateEx(Format('Page %d/%d', [APage + 1, vTotal]), cmNextPage, APage + 1));

    finally
      FreeObj(vList);
    end;
  end;


  procedure TFarFmPanel.AlbumLoad(AList :TObjList; const AArtist, AAlbum :TString);
  var
    I :Integer;
    vDoc :IXMLDOMDocument;
    vTracks :TStringArray2;
    vInfo :TString;
  begin
    vDoc := LastFMCall('album.getInfo', ['artist', AArtist, 'album', AAlbum, 'lang', opt_InfoLang]);

    vTracks := XMLParseArray(vDoc, '/lfm/album/tracks/track', ['name', 'artist/name', 'duration']);
    vInfo := ClearTags(XMLParseNode(vDoc, '/lfm/album/wiki/summary'));

    AList.FreeAll;
    AddImageItem(AList, vDoc, '/lfm/album/image', 'Album');
    AddURLItem(AList, vDoc, '/lfm/album/url', AAlbum, AAlbum);
    if vInfo <> '' then
      FItems.Add( TFarInfoItem.CreateEx(cInformation, vInfo) );
    if length(vTracks) > 0 then begin
      AList.Add(TFarFmPlaylistItem.CreateEx( AAlbum, vTracks ));
      for I := 0 to length(vTracks) - 1 do
        AList.Add( TFarFmTrackItem.CreateEx(vTracks[I, 0], vTracks[I, 1], vTracks[I, 0], Str2IntDef(vTracks[I, 2], 0), I + 1) );
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
      FItems.Add( TFarFmAlbum.CreateEx(vAlbums[I, 1] + ' - ' + vAlbums[I, 0], vAlbums[I, 1], vAlbums[I, 0]) );
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
      FItems.Add( TFarFmTrackItem.CreateEx(vTracks[I, 1] + ' - '+ vTracks[I, 0], vTracks[I, 1], vTracks[I, 0], Str2IntDef(vTracks[I, 2], 0), Str2IntDef(vTracks[I, 3], 0)) );
    if APage < vTotal then
      FItems.Add(TFarFmCommand.CreateEx(Format('Page %d/%d', [APage + 1, vTotal]), cmNextPage, APage + 1));
  end;


  procedure TFarFmPanel.LibAlbumsLoad(const aUser, Artist :TString);
  const
    cPartSize = 250;
  var
    I, vPage, vPages :Integer;
    vDoc :IXMLDOMDocument;
    vAlbums :TStringArray2;
    vList :TExList;
    vItem :TTmpItem;
    vTitle :TString;
    vSave :THandle;
  begin
    vAlbums := nil;
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      FarFM.ShowProgress('FarFM', 'Read albums', 0);

      vList := TObjList.Create;
      try
        if Artist = '' then
          vDoc := LastFMCall('library.getAlbums', ['user', aUser, 'limit', Int2Str(cPartSize)])
        else
          vDoc := LastFMCall('library.getAlbums', ['user', aUser, 'artist', Artist, 'limit', Int2Str(cPartSize)]);

        vPages := Str2IntDef(XMLParseNode(vDoc, '/lfm/albums', 'totalPages'), 1);

        vPage := 1;
        while True do begin
          vAlbums := XMLParseArray(vDoc, '/lfm/albums/album', ['name', 'artist/name', 'playcount']);
//        vTracks := XMLParseArray(vDoc, '/lfm/tracks/track', ['name', 'artist/name', 'duration', 'playcount']);
          for i := 0 to length(vAlbums) - 1 do
            vList.AddSorted( TTmpItem.CreateEx(vAlbums[i, 1], vAlbums[i, 0], 0), 0, dupIgnoreAndFree );

          FarFM.ShowProgress('FarFM', 'Read tracks ' + Int2Str(vList.Count), MulDiv(vPage, 100, vPages));
          if (vPage >= vPages) or (length(vAlbums) = 0) or FarFM.CheckInterrupt then
            Break;

          Inc(vPage);
          if Artist = '' then
            vDoc := LastFMCall('library.getAlbums', ['user', AUser, 'page', Int2Str(vPage), 'limit', Int2Str(cPartSize)])
          else
            vDoc := LastFMCall('library.getAlbums', ['user', AUser, 'artist', Artist, 'page', Int2Str(vPage), 'limit', Int2Str(cPartSize)]);
        end;

        if True {AClear} then
          FItems.FreeAll;
        for i := 0 to vList.Count - 1 do begin
          vItem := vList[i];
          if Artist <> '' then
            vTitle := vItem.FName
          else
            vTitle := vItem.FArtist + ' - ' + vItem.FName;
          FItems.Add( TFarFmAlbum.CreateEx( vTitle, vItem.FArtist, vItem.FName) );
        end;

//      FItems.Add( TFarFmCommand.CreateEx('Add', cmAddArtistToLib, 0) );

      finally
        FreeObj(vList);
      end;

    finally
      FARAPI.RestoreScreen(vSave);
    end;
  end;


  procedure TFarFmPanel.LibTracksLoad(const AUser, Artist :TString; AClear :Boolean = True);
  const
    cPartSize = 250;
  var
    I, vPage, vPages :Integer;
    vDoc :IXMLDOMDocument;
    vTracks :TStringArray2;
    vList :TExList;
    vItem :TTmpItem;
    vTitle :TString;
    vSave :THandle;
  begin
    vTracks := nil;
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      FarFM.ShowProgress('FarFM', 'Read tracks', 0);

      vList := TObjList.Create;
      try
        if Artist = '' then
          vDoc := LastFMCall('library.getTracks', ['user', AUser, 'limit', Int2Str(cPartSize)])
        else
          vDoc := LastFMCall('library.getTracks', ['user', AUser, 'artist', Artist, 'limit', Int2Str(cPartSize)]);

        vPages := Str2IntDef(XMLParseNode(vDoc, '/lfm/tracks', 'totalPages'), 1);

        vPage := 1;
        while True do begin
          vTracks := XMLParseArray(vDoc, '/lfm/tracks/track', ['name', 'artist/name', 'duration', 'playcount']);
          for i := 0 to length(vTracks) - 1 do
            vList.AddSorted( TTmpItem.CreateEx(vTracks[i, 1], vTracks[i, 0], Str2IntDef(vTracks[i, 2], 0) div 1000), 0, dupIgnoreAndFree );

          FarFM.ShowProgress('FarFM', 'Read tracks ' + Int2Str(vList.Count), MulDiv(vPage, 100, vPages));
          if (vPage >= vPages) or (length(vTracks) = 0) or FarFM.CheckInterrupt then
            Break;

          Inc(vPage);
          if Artist = '' then
            vDoc := LastFMCall('library.getTracks', ['user', AUser, 'page', Int2Str(vPage), 'limit', Int2Str(cPartSize)])
          else
            vDoc := LastFMCall('library.getTracks', ['user', AUser, 'artist', Artist, 'page', Int2Str(vPage), 'limit', Int2Str(cPartSize)]);
        end;

        if AClear then
          FItems.FreeAll;

        if Artist <> '' then
          FItems.Add(TFarFmPlaylistItem.CreateEx2( Artist, vList ));

        for i := 0 to vList.Count - 1 do begin
          vItem := vList[i];
          if Artist <> '' then
            vTitle := vItem.FName
          else
            vTitle := vItem.FArtist + ' - ' + vItem.FName;
          FItems.Add( TFarFmTrackItem.CreateEx( vTitle, vItem.FArtist, vItem.FName, vItem.FLength, I + 1) );
        end;
        
//      FItems.Add( TFarFmCommand.CreateEx('Add', cmAddArtistToLib, 0) );

      finally
        FreeObj(vList);
      end;

    finally
      FARAPI.RestoreScreen(vSave);
    end;
  end;


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
    FHideAlbums := TStringList.Create;
    FHideAlbums.Sorted := True;
    FHideTracks := TStringList.Create;
    FHideTracks.Sorted := True;
    FTrackCache := TObjList.Create;
    StoreTokens(False);
    RestoreLocalList(cArtists, FArtists);
    RestoreLocalList(cUsers, FUsers);
    RestoreLocalList(cHiddenAlbums, FHideAlbums);
    RestoreLocalList(cHiddenTracks, FHideTracks);
    if opt_CacheTrackURL then
      RestoreTrackCache;
  end;


  destructor TFarFm.Destroy; {override;}
  begin
    if opt_CacheTrackURL and (FResolved > 0) then
      SaveTrackCache;
    FreeObj(FTrackCache);
    FreeObj(FHideTracks);
    FreeObj(FHideAlbums);
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


 {-----------------------------------------------------------------------------}

  procedure TFarFm.StoreTokens(AStore :Boolean; AWhat :Integer = 3);
  var
    vConfig :TFarConfig;
  begin
    vConfig := TFarConfig.CreateEx(AStore, cPluginName);
    try
      with vConfig do begin
        if not Exists then
          Exit;
        if AWhat and 1 <> 0 then begin
          StrValue('LFMToken', FLFM_SK);
          StrValue('LFMUser', FLFMUser);
        end;
        if AWhat and 2 <> 0 then begin
          StrValue('VkToken', FVKToken);
          StrValue('VkUser', FVKUser);
        end;
      end;
    finally
      vConfig.Destroy;
    end;
  end;


  function BrowserWait(const ABrowser :InternetExplorer; const AResURL :TString) :TString;
  var
    vSave :THandle;
    vStart :DWORD;
  begin
    Result := '';
    vSave := FARAPI.SaveScreen(0, 0, -1, -1);
    try
      vStart := GetTickCount;
      while True do begin
        ShowMessage(cPluginName, Format(GetMsgStr(strWaitAuth), [TickCountDiff(GetTickCount, vStart) div 1000]), 0);
        if FarFm.CheckInterrupt then
          Abort;
        Result := ABrowser.LocationURL;
        if UpCompareSubStr(AResURL, Result) = 0 then
          Break;
        Sleep(250);
      end;
    finally
      FARAPI.RestoreScreen(vSave);
    end;
  end;


  procedure TFarFm.LastFMAuthorize;
  var
    vLFMToken :TString;  

    function LocGetToken :TString;
    var
      vDoc :IXMLDOMDocument;
    begin
      vDoc := LastFmCall('auth.getToken', []);
      Result := XMLParseNode(vDoc, '/lfm/token');
    end;


    procedure LocGetSessionKey(var AKey, AUser :TString);
    var
      vDoc :IXMLDOMDocument;
    begin
      vDoc := LastFmCall('auth.getSession', ['token', vLFMToken], True);
      AKey := XMLParseNode(vDoc, '/lfm/session/key');
      AUser := XMLParseNode(vDoc, '/lfm/session/name');
    end;


    procedure LocAuthorizeAutomatic;
    var
      vBrowser :InternetExplorer;
      vRequest, vToken :TString;
    begin
      vToken := LocGetToken;

      vRequest := Format(cLFMAuthStr, [cFarFmAPIKey, vToken]);
      vBrowser := CreateComObject(CLASS_InternetExplorer) as InternetExplorer;
      vBrowser.Navigate(vRequest, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
      vBrowser.Visible := True;
      try
        BrowserWait(vBrowser, cLFMAuthRes);
        vLFMToken := vToken;
      except
        on E :EAbort do
          raise;
        on E :Exception do
          AppError('Ошибка авторизации на Last.FM');
      end;
    end;


    procedure LocAuthorizeManual;
    var
      vRequest, vResponse, vToken :TString;
    begin
      vToken := LocGetToken;
      vRequest := Format(cLFMAuthStr, [cFarFmAPIKey, vToken]);

      if not LoginDlg(vRequest, vResponse, '') then
        Abort;

      vLFMToken := vToken;
    end;

  var
    vRes :Integer;
  begin
    if FLFMAuth then
      Exit;

    if (FLFM_SK <> '') and (FLFMUser <> '') then begin
      { Check sessin key... }
      try
        {...}
        FLFMAuth := True;
        Exit;
      except
        FLFM_SK := '';
        FLFMUser := '';
      end;
    end;

    vRes := ShowMessageBut(GetMsgStr(strWarning), GetMsgStr(strNeedAuthLFM),
      [GetMsgStr(strAutoAuthBut), GetMsgStr(strManualAuthBut), GetMsgStr(strCancel)],
      FMSG_WARNING or FMSG_LEFTALIGN);

    case vRes of
      0: LocAuthorizeAutomatic;
      1: LocAuthorizeManual;
    else
      Abort;
    end;

    LocGetSessionKey(FLFM_SK, FLFMUser);

    StoreTokens(True, 1);
    FLFMAuth := True;
  end;


  procedure TFarFm.LastFMLogout;
  begin
    FLFM_SK := '';
    FLFMUser := '';
    StoreTokens(True, 1);
    FLFMAuth := False;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFarFm.VKAuthorize;
  var
    vResponse :TString;

    procedure LocAuthorizeAutomatic;
   {$ifdef b64}
    begin
      Sorry;
   {$else}
    var
      vBrowser :InternetExplorer;
      vRequest :TString;
    begin
      vRequest := Format(cVkAuthStr, [cVKApiID]);
      vBrowser := CreateComObject(CLASS_InternetExplorer) as InternetExplorer;
      vBrowser.Navigate(vRequest, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
      vBrowser.Visible := True;
      try
        vResponse := BrowserWait(vBrowser, cVkAuthRes);
//      vBrowser.Visible := False;
        vBrowser.Quit;
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
      vRequest :TString;
    begin
      vRequest := Format(cVkAuthStr, [cVKApiID]);
      if not LoginDlg(vRequest, vResponse, cVkAuthRes) then
        Abort;
    end;


    function LocGetUser(const AResponse :TString) :TString;
    const
      cUserID = 'user_id=';
    var
      vPos :Integer;
      vID :TString;
      vDoc :IXMLDOMDocument;
    begin
      Result := '';
      vPos := Pos(cUserID, AResponse);
      if vPos <> 0 then begin
        vID := ExtractWord(1, Copy(AResponse, vPos + Length(cUserID), MaxInt), ['&']);
        vDoc := VkCall('users.get', ['uids', vID, 'fields', 'nickname']);
        Result := AppendStrCh(XMLParseNode(vDoc, '/response/user/first_name'), XMLParseNode(vDoc, '/response/user/last_name'), ' ');
      end;
    end;

    function LocGetToken(const AResponse :TString) :TString;
    begin
      Result := ExtractWord(1, Copy(AResponse, Length(cVkAuthRes) + 1, MaxInt), ['&']);
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
        FVKUser := '';
      end;
    end;

    vRes := ShowMessageBut(GetMsgStr(strWarning), GetMsgStr(strNeedAuthVK),
      [GetMsgStr(strAutoAuthBut), GetMsgStr(strManualAuthBut), GetMsgStr(strCancel)],
      FMSG_WARNING or FMSG_LEFTALIGN);

    case vRes of
      0: LocAuthorizeAutomatic;
      1: LocAuthorizeManual;
    else
      Abort;
    end;

    FVKToken := LocGetToken(vResponse);
    FVKUser := LocGetUser(vResponse);

    StoreTokens(True, 2);
    FVKAuth := True;
  end;


  procedure TFarFm.VkLogout;
  begin
    FVKToken := '';
    StoreTokens(True, 2);
    FVKAuth := False;
  end;

 {-----------------------------------------------------------------------------}

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
      if ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strInterruptPrompt), FMSG_WARNING or FMSG_MB_YESNO) = 0 then
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
  var
    vIndex :Integer;
    vKey :TString;
  begin
    Result := '';

    vKey := Artist + #9 + Track;
    if FTrackCache.FindKey(Pointer(vKey), 0, [foBinary], vIndex) then
      Result := TDescrObject(FTrackCache[vIndex]).Descr
    else begin
      if not AForce then
        Exit;

      Result := VkFindTrackURL(Artist, Track, False);

      if Result <> '' then begin
        FTrackCache.Insert( vIndex, TDescrObject.CreateEx(vKey, Result) );
        Inc(FResolved);
      end;
    end;
  end;


  function TFarFm.SetTrackURL(const Artist, Track, AURL :TString) :Boolean;
  var
    vIndex :Integer;
    vKey :TString;
  begin
    Result := False;
    vKey := Artist + #9 + Track;
    if FTrackCache.FindKey(Pointer(vKey), 0, [foBinary], vIndex) then begin
      with TDescrObject(FTrackCache[vIndex]) do
        if Descr <> AURL then begin
          Descr := AURL;
          Inc(FResolved);
        end;
    end else
    begin
      FTrackCache.Insert( vIndex, TDescrObject.CreateEx(vKey, AURL) );
      Inc(FResolved);
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


  function TFarFm.FindTrackLirics(const Artist, Track :TString) :TString;
  const
    cTryVariants = 3;
  var
    vID :TString;
    vDoc :IXMLDOMDocument;
  begin
    Result := '';
    vID := VkFindTrackURL(Artist, Track, True);
    if vID <> '' then begin
      vDoc := VkCall('audio.getLyrics', ['lyrics_id', vID]);
      Result := XMLParseNode(vDoc, '/response/lyrics/text');
//    Result := ClearTags(Result);
    end;
  end;


  function TFarFm.VkFindTrackURL(const Artist, Track :TString; ALiric :Boolean) :TString;
  const
    cTryVariants = 3;
  var
    I, vScore, vBestScore :Integer;
    vDoc :IXMLDOMDocument;
    vStreams :TStringArray2;
  begin
    Result := '';
    VKAuthorize;

    if not ALiric then
      vDoc := VkCall('audio.search', ['q', Artist + ' ' + Track, 'count', Int2Str(cTryVariants)])
    else
      vDoc := VkCall('audio.search', ['q', Artist + ' ' + Track, 'count', Int2Str(cTryVariants), 'lirics', '1']);
    vStreams := XMLParseArray(vDoc, '/response/audio', [StrIf(ALiric, 'lyrics_id', 'url'), 'artist', 'title']);

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
  end;



initialization
//  TraceF('= %d, %d', [Sizeof(TFarFindData), Sizeof(TPluginPanelItem) ]);
end.


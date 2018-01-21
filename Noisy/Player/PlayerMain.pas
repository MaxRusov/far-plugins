{$I Defines.inc}

unit PlayerMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Player main module                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    ShellAPI,
    SHLObj,
    Messages,

    Bass,

    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,

    NoisyConsts,
    NoisyUtil,
    PlayerTags,
    PlayerMidi,
    PlayerWin,
    PlayerReg,
    PlayerHist;

  const
    cmOpen = 1;
    cmPlay = 2;
    cmStop = 3;
    cmNext = 4;
    cmPrev = 5;
    cmQuit = 6;
    cmGoto = $8000;
    cmHist = $9000;

  var
    cAutoPlaylistName :TString = 'Noisy.m3u';

  type
    TBassPlugin = class(TBasis)
    private
      FHandle  :THandle;
      FVersion :Cardinal;
    end;

    TBassFormat = class(TBasis)
    private
      FCode    :Cardinal;
      FExts    :TString;
    end;

    TBassPalyer = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure Run;
      procedure Idle;
      procedure ParseCommand(const AStr :TString);

    private
      FMutex        :THandle;
      FWindow       :THandle;
      FPlayIcon     :THandle;
      FPauseIcon    :THandle;
      FStopIcon     :THandle;
      FMenu         :HMenu;
      FPlaylistMenu :HMenu;
      FHistoryMenu  :HMenu;
      FPlugins      :TObjStrings;
      FFormats      :TObjStrings;
      FExts         :TStringList;
      FHistory      :TPlaylistHistory;

      FExePath      :TString;      { Каталог exe-шника }
      FRunPath      :TString;      { Каталог запуска }
      FCurPath      :TString;      { Текущий (установленный) каталог }
      FLocked       :Integer;      { Блокировка player'а, чтобы он не заершал свою работу }
      FDlgLock      :Integer;      { Открыт диалог выбора файлов }
      FAsyncLock    :Integer;      { Блокировка выполнения асинхронных команд }

      FInited       :Boolean;
      FState        :TPlayerState;

      FCommands     :TStringList;  { Зарегистрированные команды }
      FAsyncCmds    :TStringList;  { Очередь асинхронных команд }
      FPlayList     :TPlaylist;
      FShuffleList  :TExList;
      FIndex        :Integer;      { Индекс текущего трека в playlist'е }
      FUpdIndex     :Integer;
      FPlaylistRev  :Integer;

      FHistIndex    :Integer;      { Индекс текущего playlist'а в истории }

      FStream       :HSTREAM;
      FTrackFile    :TString;
      FTrackTitle   :TString;
      FTrackArtist  :TString;
      FTrackAlbum   :TString;
      FTrackBytes   :Integer;
      FTrackLength  :FLOAT;
      FTrackBitrate :Integer;
      FStreamType   :TStreamType;
      FTrackLoaded  :Integer;

      FVolume        :Float;
      FMute          :Float;
      FBalance       :Float;
      FRepeat        :Boolean;
      FShuffle       :Boolean;
      FSysTray       :Boolean;
      FTooltip       :Boolean;
      FHotkeys       :Boolean;
      FHotkeyList    :TStringList;
      FHotkeyCmds    :TStringList;

      FSeekReq       :FLOAT;       { Асинхронный Seek запрос }
      FSeekTick      :Cardinal;

      FIdleTick      :Cardinal;    { Период бездействия, для автоматического закрытия }
      FUpdateTick    :Cardinal;    { Период обновления, для обновления MemState }
      FTooltipTick   :Cardinal;    { Период показа tooltip'а, для его сокрытия }
      FStartTick     :Cardinal;    { Период проигрывания track'а, чтобы отключать плавное приглушение }
      FSyncTick      :Cardinal;    { Синхронизация Shoutcast потока }
      FPlaylistTick  :Cardinal;    { Момент изменения Playlist'а, для его асинхронного обновления }
      FPlaylistTick1 :Cardinal;    { Момент извлечения тэга, для асинхронного обновления Playlist'а }

      FMemSize       :Integer;
      FMemHandle     :THandle;

      FInfoChanged   :Boolean;
      FPlayerInfo    :PPlayerInfo;
      FInfoHandle    :THandle;

      FBassVersion   :Cardinal;

      procedure InitCommands;

      procedure InitBASS;
      procedure DoneBASS;

      procedure CreateWnd;
      function GetSysTrayIcon :THandle;
      function GetSysTrayHint :TString;
      procedure ShowInSysTray(AShow :Boolean);
      procedure UpdateSystray;
      procedure SetupPlaylistMenu(AMenu :HMenu);
      procedure SetupHistoryMenu(AMenu :HMenu);
      procedure PopupMenu(APlaylist, AMousePos :Boolean);

      procedure DisplayInfo(const ATitle, AStr :TString);
      procedure HideInfo;

      procedure ReinitHotkeySettings;
      procedure ActivateHotkeys(AOn :Boolean; ANotify :Boolean);
      procedure RunHotkey(ANum :Integer);

      {------------------------------------------------------------------------}
      { Команды                                                                }
      procedure AddFile(const AFile :TString; ARecursive, AClear :Boolean);
      procedure BeginPlay;
      procedure BeginPlayIndex(AIndex :Integer);
      procedure OpenFiles;
      procedure StopPlay;
      procedure PausePlay;
      procedure ResumePlay;
      procedure PlayOrPause;
      procedure GotoNext;
      procedure GotoPrev;
      procedure GotoIndex(AIndex :Integer);
      procedure GotoPlaylist(AIndex :Integer);
      function GetVolume :FLOAT;
      procedure SetVolume(AVolume :FLOAT);
      function GetBalance :FLOAT;
      procedure SetBalance(ABalance :FLOAT);
      procedure Mute(AVolume :Float);
      procedure SetSpeed(ASpeed :FLOAT);
      function GetPosition :FLOAT;
      procedure SeekTo(ATime :FLOAT);
      function GetAsyncPosition :FLOAT;
      procedure AsyncSeekTo(ATime :FLOAT);
      procedure DeleteTrack(AIndex :Integer);
      procedure MoveTrack(ASrcIndex, ADstIndex :Integer);
      procedure ClearPlaylist(ANotify :Boolean);
      procedure LoadPlaylist(const AFileName :TString);
      procedure SavePlaylist(const AFileName :TString; AbsolutePath :Boolean);
      procedure SetCurPath(const APath :TString);
      procedure RepeatMode(AOn :Boolean);
      procedure ShuffleMode(AOn :Boolean);
      procedure ShowTooltip(AShow :Boolean);
      procedure Quit;
      procedure IconClick;
      {------------------------------------------------------------------------}

      procedure VolumeSmoothDown(AVolume :Float);
      procedure VolumeSmoothUp;

      function GetMyAppDataFolder :TString;
      procedure AutoSavePlaylist;
      procedure AutoLoadPlaylist;

      function TrackActive :Boolean;
      procedure DonePlayed;

      procedure InitShuffleList(AMakeFirst :Boolean);
      procedure CheckPlay;

      procedure UpdateTrackInfo;
      procedure ExtractTrackInfo;
      function ExtractStreamInfo(AStream :HSTREAM; const AFileName :TString; var ATitle, AArtist, AAlbum :TString) :Boolean;

      procedure IdleUpdateTrackInfo;
      function FindTrackByName(const AName :TString; AShort :Boolean) :Integer;
      function GetTrackName :TString;
      function GetTrackAddInfo :TString;

      procedure InitMemState;
      procedure PublishMemState;
      procedure DoneMemState;
      procedure PublishMemPlaylist;
      procedure DoneMemPlaylist;
    end;



  var
    Player :TBassPalyer;
    MainThread :Cardinal;

  procedure Run;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  type
    TNoisyCommands = (
      cmdAdd,
      cmdRecursive,
      cmdOpen,
      cmdStop,
      cmdPause,
      cmdPlay,
      cmdPlayPause,
      cmdNext,
      cmdPrev,
      cmdFirst,
      cmdLast,
      cmdGoto,
      cmdVolume,
      cmdBalance,
      cmdMute,
      cmdSeek,
      cmdSpeed,
      cmdDelete,
      cmdMoveTrack,
      cmdClear,
      cmdLoad,
      cmdSave,
      cmdPlaylist,
      cmdNextPlaylist,
      cmdPrevPlaylist,
      cmdGotoPlaylist,
      cmdClearHistory,
      cmdLock,
      cmdUnlock,
      cmdCurPath,
      cmdRepeat,
      cmdShuffle,
      cmdSysTray,
      cmdTooltip,
      cmdHotkeys,
      cmdShowInfo,
      cmdInfo,
      cmdNoTooltip,
      cmdAsync,
      cmdQuit
    );


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function FloatLimit(V :FLOAT; Min, Max :FLOAT) :FLOAT;
  begin
    if V > Max then
      V := Max;
    if V < Min then
      V := Min;
    Result := V;
  end;


  function GetTagsStr(AStr :PAnsiChar; const ADel :TString) :TString;
  var
    vLen :Integer;
  begin
    Result := '';
    while AStr^ <> #0 do begin
      vLen := StrLenA(AStr);
      Result := AppendStrCh(Result, Copy(AStr, 1, vLen), ADel);
      Inc(AStr, vLen + 1);
    end;
  end;


  function ExtractTagValue(const AInfo, ATagName :TString; const ADel1, ADel2 :TAnsiCharSet) :TString;
  var
    I :Integer;
    vStr, vName :TString;
  begin
    for I := 1 to WordCount( AInfo, ADel1) do begin
      vStr := ExtractWord(I, AInfo, ADel1);
      vName := ExtractWord(1, vStr, ADel2);
      if StrEqual(ATagName, vName) then begin
        Result := Trim(ExtractWord(2, vStr, ADel2));
        if (Result <> '') and (Result[1] = '''') and (Result[Length(Result)] = '''') then
          Result := Copy(Result, 2, Length(Result) - 2);
        Exit;
      end;
    end;
    Result := '';
  end;


  function IsPlaylist(const AFileName :TString) :Boolean;
  var
    vExt :TString;
  begin
    vExt := ExtractFileExtension(AFileName);
    Result := StrEqual(vExt, 'm3u');
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    FIdleTimer :THandle;
    FTimer     :THandle;
    FStartPos  :TPoint;
    FGestrude  :Integer;


  function MyWindowProc(AWnd :HWnd; AMsg :DWORD; WParam, LParam :Integer) :LongInt; stdcall;

    procedure LocCopyData;
    var
      vStruct :PCopyDataStruct;
      vStr :TString;
    begin
      vStruct := Pointer(LParam);
      SetString(vStr, PTChar(vStruct.lpData), vStruct.cbData div SizeOf(TChar));
      Player.ParseCommand(vStr);
    end;

    procedure LocSysTrayNotify;
    begin
//    TraceF('SysTray notify: LParam:%d:%d, PWaram:%dx%d', [HiWord(LParam), LoWord(LParam), HiWord(WParam), LoWord(WParam)]);

      case LoWord(LParam) of
        WM_RBUTTONUP:
          Player.PopupMenu(GetKeyState(VK_CONTROL) < 0, True);

        WM_MBUTTONDOWN:
          SetForegroundWindow(AWnd);

        WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
          begin
            SetForegroundWindow(AWnd);

            if FTimer <> 0 then begin
              KillTimer(AWnd, 2);
              ShowCursor(True);
              FTimer := 0;
            end;

            if GestrudeEnabled then begin
              FTimer := SetTimer(AWnd, 2, 10, nil);
              GetCursorPos(FStartPos);
              FGestrude := 0;
            end;
          end;

        WM_LBUTTONUP:
          begin
            if FTimer <> 0 then begin
              if FGestrude <> 0 then begin
                ShowCursor(True);
                Player.HideInfo;
              end;
              KillTimer(AWnd, 2);
              FTimer := 0;
            end;

            if not (GetKeyState(VK_Shift) < 0) and (FGestrude = 0) then
              Player.IconClick;
          end;

//      NIN_BALLOONSHOW:
//        NOP;

//      NIN_POPUPOPEN:
//        with Player do
//          DisplayInfo(GetTrackName, GetTrackAddInfo);
//      NIN_POPUPCLOSE:
//        Player.HideInfo;

      end;
    end;


    procedure LocGestrude;
    var
      vPoint :TPoint;
      DX, DY :Integer;
    begin
      if GetAsyncKeyState(VK_LBUTTON) < 0 then begin
        GetCursorPos(vPoint);
        DX := vPoint.x - FStartPos.x;
        DY := FStartPos.y - vPoint.y;
        if FGestrude = 0 then begin
          if (Abs(DX) > 5) or (Abs(DY) > 5) then begin
            if Abs(DY) > Abs(DX) then
              { Изменение громкости }
              FGestrude := 1
            else
              { Изменение позиции }
              FGestrude := 2;
            SetCursorPos(FStartPos.X, FStartPos.Y);
            ShowCursor(False);
          end;
        end else
        begin
          if FGestrude = 1 then begin
            if DY <> 0 then
              Player.SetVolume(Player.FVolume + DY)
          end else
          begin
            if DX <> 0 then
              Player.AsyncSeekTo(Player.GetAsyncPosition + DX);
            Player.FSeekTick := GetTickCount;
          end;
          SetCursorPos(FStartPos.X, FStartPos.Y);
        end;
      end else
      begin
        if FGestrude <> 0 then begin
          ShowCursor(True);
          Player.HideInfo;
        end;
        KillTimer(AWnd, 2);
        FTimer := 0;
      end;
    end;


  begin
//  if AMsg <> WM_Timer then
//    TraceF('Wnd Msg: %s', [WindowMessage2Str(AMsg)]);
    
    Result := 0;
    try
      case AMsg of
        WM_NCCreate: begin
          Result := DefWindowProc (AWnd, AMsg, WParam, LParam);
          FIdleTimer := SetTimer(AWnd, 1, 10, nil);
        end;

        WM_NCDestroy : begin
          if FIdleTimer <> 0 then begin
            KillTimer(AWnd, 1);
            FIdleTimer := 1;
          end;
          Result := DefWindowProc (AWnd, AMsg, WParam, LParam);
        end;

        WM_CopyData:
          LocCopyData;

        WM_MySysTrayNotify:
          LocSysTrayNotify;

        WM_INITMENUPOPUP:
          if HMenu(WParam) = Player.FPlaylistMenu then
            Player.SetupPlaylistMenu(HMenu(WParam))
          else
          if HMenu(WParam) = Player.FHistoryMenu then
            Player.SetupHistoryMenu(HMenu(WParam));

        WM_COMMAND:
          case LongRec(WParam).Lo of
            cmOpen : Player.OpenFiles;
            cmPlay : Player.PlayOrPause;
            cmStop : Player.StopPlay;
            cmNext : Player.GotoNext;
            cmPrev : Player.GotoPrev;
            cmQuit : Player.Quit;

            cmGoto .. cmGoto + $FFF:
              Player.GotoIndex( LongRec(WParam).Lo - cmGoto );
            cmHist .. cmHist + $FFF:
              Player.GotoPlaylist( LongRec(WParam).Lo - cmHist );
          end;

        WM_HOTKEY:
          Player.RunHotkey(WParam);

        WM_MouseWheel:
          if Smallint(LongRec(wParam).Hi) > 0 then
            Player.SetVolume(Player.FVolume + 5)
          else
            Player.SetVolume(Player.FVolume - 5);

        WM_TIMER:
          if WParam = 1 then
            Player.Idle
          else
          if WParam = 2 then
            LocGestrude;

        WM_Destroy:
          PostQuitMessage(0);

      else
        Result := DefWindowProc (AWnd, AMsg, WParam, LParam);
      end;

    except
      on E :Exception do
        MessageBox(0, PTChar(E.Message), 'Error', MB_OK or MB_ICONERROR);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TBassPalyer                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TBassPalyer.Create;
  begin
    inherited Create;

    FCommands := TStringList.Create;
    FAsyncCmds := TStringList.Create;
    FPlugins := TObjStrings.Create;
    FFormats := TObjStrings.Create;
    FExts := TStringList.Create;
    FPlayList := TPlaylist.Create;
    FHotkeyList := TStringList.Create;
    FHotkeyCmds := TStringList.Create;
    FHistory := TPlaylistHistory.Create;

    FExePath := ExtractFilePath(GetExeModuleFileName);
    FRunPath := GetCurrentDir;
    FCurPath := FRunPath;

    if not CreateMutexEx(MutexName, FMutex, False) then
      AppError('Another copy of player already running');

    { До InitBass, так как понадобится список плагинов }
    ReadSettings;

    InitCommands;
//  CoInitialize(nil);
    InitBass;

    FVolume := LastVolume;
    FBalance := LastBalance;
    FRepeat := LastRepeat;
    FShuffle := LastShuffle;
    FTooltip := LastTooltip;
    FSysTray := LastSystray;

    FMute := -1;
    FUpdIndex := -1;
    FHistIndex := -1;
    FSeekReq := -1;

    try
      AutoLoadPlaylist;
    except
    end;

    InitMemState;
    PublishMemState;
    PublishMemPlaylist;

    FInfoChanged := False;
    FPlaylistTick := 0;
    FPlaylistTick1 := 0;

    FPlayIcon := LoadIcon(HInstance, 'Play');
    FPauseIcon := LoadIcon(HInstance, 'Pause');
    FStopIcon := LoadIcon(HInstance, 'Stop');

    CreateWnd;

    FSysTray := False;
    ShowInSysTray(LastSystray);
    ActivateHotkeys(LastHotkeys, False);

    FInited := True;
  end;


  destructor TBassPalyer.Destroy;
  begin
    if FInited then begin
      try
        AutoSavePlaylist;
      except
      end;

      LastRepeat := FRepeat;
      LastShuffle := FShuffle;
      LastTooltip := FTooltip;
      LastSystray := FSysTray;
      LastHotkeys := FHotkeys;
      LastVolume := Round(FVolume);
      LastBalance := Round(FBalance);

      WriteSettings;
    end;

    ActivateHotkeys(False, False);
    ShowInSysTray(False);
    DonePlayed;
    DoneBass;
//  CoUninitialize;

    DoneMemState;
    DoneMemPlaylist;

    if (FWindow <> 0) and IsWindow(FWindow) then begin
      DestroyWindow(FWindow);
      FWindow := 0;
    end;

    if FMutex <> 0 then begin
      CloseHandle(FMutex);
      FMutex := 0;
    end;

    FreeObj(FHistory);
    FreeObj(FHotkeyList);
    FreeObj(FHotkeyCmds);
    FreeObj(FShuffleList);
    FreeObj(FPlaylist);
    FreeObj(FFormats);
    FreeObj(FExts);
    FreeObj(FPlugins);
    FreeObj(FAsyncCmds);
    FreeObj(FCommands);
    inherited Destroy;
  end;


  procedure TBassPalyer.InitBASS;

    procedure LocAddFormat(ACode :Cardinal; const AName, AExts :TString);
    var
      vFormat :TBassFormat;
    begin
//    TraceF('Register format: %s (%s), %d', [AName, AExts, ACode]);
      vFormat := TBassFormat.Create;
      vFormat.FCode := ACode;
      vFormat.FExts := AExts;
      FFormats.AddObject(AName, vFormat);
    end;


    procedure LocLoadPlugin(const AFileName :TString);
    var
      I :Integer;
      vHandle :HPLUGIN;
      vInfo :PBASS_PLUGININFO;
      vFmtInfo :^BASS_PLUGINFORM;
      vPlugin :TBassPlugin;
      vName :TString;
    begin
      vName := ExtractFileTitle(AFileName);
      if FPlugins.IndexOf(vName) <> -1 then
        Exit;

     {$ifdef bDebug}
      TraceF('Load plugin: %s', [AFileName]);
     {$endif bDebug}

      vHandle := BASS_PluginLoad(Pointer(PTChar(AFileName)), BASS_UNICODE);
      if vHandle <> 0 then begin
        vPlugin := TBassPlugin.Create;
        vPlugin.FHandle := vHandle;

        vInfo := BASS_PluginGetInfo(vHandle);
        if vInfo <> nil then begin
          vPlugin.FVersion := vInfo.Version;
          vFmtInfo := Pointer(vInfo.formats);
          for I := 0 to Integer(vInfo.formatc) - 1 do begin
            LocAddFormat(vFmtInfo.ctype, vFmtInfo.Name, vFmtInfo.exts);
            Inc(Pointer1(vFmtInfo), SizeOf(BASS_PLUGINFORM));
          end;
        end;

        FPlugins.AddObject(vName, vPlugin);
      end;
    end;


    procedure LocLoadPlugins(const APlugins :TString);

      procedure EnumFiles(const aPath :TString; const aSRec :TWin32FindData);
      var
        vFileName :TString;
      begin
        vFileName := AddFilename(APath, aSRec.cFileName);
        LocLoadPlugin(vFileName);
      end;

    var
      I :Integer;
      vStr, vPath :TString;
    begin
      for I := 1 to WordCount(APlugins, [',', ';']) do begin
        vStr := Trim(ExtractWord(I, APlugins, [',', ';']));
        if vStr <> '' then begin
          if not FileNameHasMask(vStr) then
            LocLoadPlugin(vStr)
          else begin
            vPath := RemoveBackSlash(ExtractFilePath(vStr));
            if WinFolderExists(vPath) then
              WinEnumFilesEx(vPath, ExtractFileName(vStr), faEnumFiles, [], LocalAddr(@EnumFiles));
          end;
        end;
      end;
    end;

    procedure LocMakeExtsList;
    var
      I, J :Integer;
      vStr :TString;
      vFormat :TBassFormat;
    begin
      FExts.Sorted := True;
      FExts.Duplicates := dupIgnore;
      for I := 0 to FFormats.Count - 1 do begin
        vFormat := FFormats.Objects[I] as TBassFormat;
        for J := 1 to WordCount(vFormat.FExts, [';', ',']) do begin
          vStr := ExtractFileExtension(ExtractWord(J, vFormat.FExts, [';', ',']));
          FExts.Add(vStr);
        end;
      end;
    end;

  var
    vVersion :Integer;
  begin
    vVersion := BASS_GetVersion;

    if (HIWORD(vVersion) <> BASSVERSION) then
      AppError('An incorrect version of BASS.DLL was loaded');

    if not BASS_Init(-1, 44100, 0, 0, nil) then
      AppError('Error initializing audio');

    LocAddFormat(BASS_CTYPE_STREAM_MP3, 'Wave', '*.wav');
//  LocAddFormat(BASS_CTYPE_STREAM_MP1, 'MPEG layer 1', '*.mpg');
//  LocAddFormat(BASS_CTYPE_STREAM_MP2, 'MPEG layer 2', '*.mp2');
    LocAddFormat(BASS_CTYPE_STREAM_MP3, 'MPEG layer 3', '*.mp3');
    LocAddFormat(BASS_CTYPE_STREAM_OGG, 'Ogg Vorbis', '*.ogg');
    LocAddFormat(BASS_CTYPE_STREAM_AIFF, 'Audio IFF', '*.aif');
(*
    BASS_CTYPE_MUSIC_MOD Generic MOD format music. This can also be used as a flag to test if the channel is any kind of HMUSIC.
    BASS_CTYPE_MUSIC_MTM MultiTracker format music.
    BASS_CTYPE_MUSIC_S3M ScreamTracker 3 format music.
    BASS_CTYPE_MUSIC_XM FastTracker 2 format music.
    BASS_CTYPE_MUSIC_IT Impulse Tracker format music.
*)
    if BassPlugins <> '' then
      LocLoadPlugins(BassPlugins)
    else begin
      LocLoadPlugin('basswma.dll');
      LocLoadPlugin('bassflac.dll');
      LocLoadPlugin('bass_ape.dll');
      LocLoadPlugin('bassmidi.dll');
    end;

    InitMidi;

    LocMakeExtsList;

    FBassVersion := vVersion;
  end;


  procedure TBassPalyer.DoneBASS;
  var
    I :Integer;
  begin
    for I := 0 to FPlugins.Count - 1 do
      BASS_PluginFree( (FPlugins.Objects[i] as TBassPlugin).FHandle );
    if FBassVersion <> 0 then
      BASS_Free;
  end;


 {-----------------------------------------------------------------------------}

  procedure TBassPalyer.AddFile(const AFile :TString; ARecursive, AClear :Boolean);
  var
    vAllKnown :Boolean;

    procedure LocAdd(const AName :TString);
    begin
      if AClear then begin
        ClearPlaylist(False);
        AClear := False;
      end;
      if IsPlaylist(AName) then
        LoadPlaylist(AName)
      else
        FPlaylist.Add(AName);
      if FUpdIndex = -1 then
        FUpdIndex := FPlayList.Count - 1;
    end;

    procedure EnumFiles(const aPath :TString; const aSRec :TWin32FindData);
    var
      vFileName :TString;
    begin
      vFileName := AddFilename(APath, aSRec.cFileName);
      if vAllKnown then
        if FExts.IndexOf( ExtractFileExtension(vFileName) ) = -1 then
          Exit;
//    Trace(vFileName);
      LocAdd(vFileName);
    end;

  var
    vFileName, vMask :TString;
    vOpt :TEnumFileOptions;
  begin
    try
      if FileNameIsURL(AFile) then
        LocAdd(AFile)
      else begin
        vFileName := CombineFileName(FCurPath, AFile);
        if not FileNameHasMask(vFileName) and WinFolderExists(vFileName) then
          vFileName := AddFileName(vFileName, '*');

        if not FileNameHasMask(vFileName) then begin
          if WinFileExists(vFileName) then
            LocAdd(vFileName)
        end else
        begin
          vOpt := [];
          if ARecursive then
            vOpt := vOpt + [efoRecursive];
          vMask := ExtractFileName(vFileName);
          vAllKnown := vMask = '*';
          if vAllKnown then
            vMask := '*.*';
          WinEnumFilesEx(ExtractFilePath(vFileName), vMask, faEnumFiles, vOpt, LocalAddr(@EnumFiles));
        end;
      end;
    finally
      FreeObj(FShuffleList);
      FPlaylistTick := GetTickCount;
      FPlaylistTick1 := 0;
    end;
  end;


  procedure TBassPalyer.OpenFiles;
  var
    I :Integer;
    vMasks :TString;
    vFiles :TStrList;
    vFormat :TBassFormat;
  begin
    if FDlgLock > 0 then begin
      Beep;
      Exit;
    end;

    vFiles := TStrList.Create;
    Inc(FDlgLock);
    try
      vMasks := '*.m3u';
      for I := 0 to FExts.Count - 1 do
        vMasks := AppendStrCh(vMasks, '*.' + FExts[I], ';');

      vMasks :=
        'All music'#0 + vMasks + #0 +
        'Playlists'#0 + '*.m3u' + #0; 
      for I := 0 to FFormats.Count - 1 do begin
        vFormat := FFormats.Objects[I] as TBassFormat;
        vMasks := vMasks + FFormats[I] + ' (' + vFormat.FExts + ')' + #0 + vFormat.FExts + #0
      end;
      vMasks := vMasks + 'All files '#0'*.*'#0#0;

      if GetForegroundWindow <> FWindow then begin
//      Trace('SetForegroundWindow...');
        SetForegroundWindow(FWindow);
        Sleep(10);
      end;

      if OpenFilesDlg(FWindow, vMasks, vFiles) then begin
        for I := 0 to vFiles.Count - 1 do begin
          AddFile(vFiles[I], True, I = 0);
          if I = 0 then
            BeginPlayIndex(0);
        end;
      end;

    finally
      Dec(FDlgLock);
      FIdleTick := 0;
      FreeObj(vFiles);
    end;
  end;


  procedure TBassPalyer.ClearPlaylist(ANotify :Boolean);
  begin
    StopPlay;
    if FPlaylist.Count > 0 then begin
      FHistory.AddToHistory(FPlaylist, FIndex);

      FIndex := 0;
      FUpdIndex := -1;
      FHistIndex := -1;
      FTrackFile := '';
      FTrackTitle := '';
      FTrackArtist := '';
      FTrackAlbum := '';
      FPlaylist.Clear;
      FreeObj(FShuffleList);
      FPlaylistTick := GetTickCount;
      FPlaylistTick1 := 0;
      if ANotify then
        DisplayInfo('', 'Playlist is empty');
    end;
  end;


  procedure DownloadProc(ABuffer :Pointer; ALength :DWORD; AUser :Pointer); stdcall;
  begin
//  TraceF('DownloadProc: ALen = %d', [ALength]);
    with Player do begin
      Inc(FTrackLoaded, ALength);
      if MainThread = GetCurrentThreadID then
        DisplayInfo(GetTrackName, 'Buffering...');
      if ABuffer = nil then
        { Завершение загрузки - повторное извлечение тэга }
        Player.FSyncTick := GetTickCount;
    end;
  end;


  procedure SyncProc(AHandle :HSYNC; AChannel :DWORD; AData :DWORD; AUser :Pointer); stdcall;
  begin
//  Trace('SyncProc...');
    Player.FSyncTick := GetTickCount;
  end;


  procedure TBassPalyer.BeginPlay;
  var
    vAnsiStr :AnsiString;
    vInfo :BASS_CHANNELINFO;
  begin
    DonePlayed;
   {$ifdef bTrace}
    TraceF('Play: %s', [FTrackFile]);
   {$endif bTrace}

    if FileNameIsURL(FTrackFile) then begin
      vAnsiStr := FTrackFile;
      {!!!-UTF}
      Player.DisplayInfo(GetTrackName, 'Open...');
      MainThread := GetCurrentThreadID;
      FStreamType := stStream;
      FTrackLoaded := 0;
      FStream := BASS_StreamCreateURL(PAnsiChar(vAnsiStr), 0, BASS_STREAM_STATUS, DownloadProc, nil);
      if FStream <> 0 then begin
        FillChar(vInfo, SizeOf(vInfo), 0);
        BASS_ChannelGetInfo(FStream, vInfo);
        if BASS_STREAM_BLOCK and vInfo.flags <> 0 then
          FStreamType := stShoutcast;
        if FStreamType = stShoutcast then
          BASS_ChannelSetSync(FStream, BASS_SYNC_MIXTIME or BASS_SYNC_META, 0, SyncProc, nil);
      end else
      begin
        DisplayInfo(GetTrackName, 'Error');
        FState := psStopped;
        Exit;
      end;
    end else
    begin
      FStreamType := stNormal;
      FStream := BASS_StreamCreateFile(False, PTChar(FTrackFile), 0, 0, BASS_UNICODE);
      if FStream = 0 then begin
        FStreamType := stMusic;
        FStream := BASS_MusicLoad(False, PTChar(FTrackFile), 0, 0, BASS_UNICODE, 0);
      end;
    end;

    if FStream <> 0 then begin
//    SetVolume(FVolume);
      if FMute < 0 then
        BASS_ChannelSetAttribute(FStream, BASS_ATTRIB_VOL, FVolume / 100)
      else
        BASS_ChannelSetAttribute(FStream, BASS_ATTRIB_VOL, FMute / 100);
      BASS_ChannelSetAttribute(FStream, BASS_ATTRIB_PAN, FBalance / 100);
      BASS_ChannelPlay(FStream, False);
      ExtractTrackInfo;
      DisplayInfo(GetTrackName, GetTrackAddInfo);
    end;

    FSeekReq := -1;
    FState := psPlayed;
    FStartTick := GetTickCount;
    FInfoChanged := True;
  end;


  procedure TBassPalyer.BeginPlayIndex(AIndex :Integer);
  begin
    FIndex := AIndex;
    FTrackFile := FPlaylist[AIndex];
    with FPlaylist.TrackInfo[AIndex] do begin
      FTrackTitle  := Title;
      FTrackArtist := Artist;
      FTrackAlbum  := Album;
    end;
    BeginPlay;
  end;



  procedure TBassPalyer.DonePlayed;
  begin
    if FStream <> 0 then begin
      FTrackTitle := '';
      FTrackArtist := '';
      FTrackAlbum := '';
      FTrackBytes := 0;
      FTrackLength := 0;
      FTrackBitrate := 0;
      FTrackLoaded := 0;

      if FStreamType = stMusic then
        BASS_MusicFree(FStream)
      else
        BASS_StreamFree(FStream);
      FStream := 0;
    end;
  end;


  function TBassPalyer.TrackActive :Boolean;
  begin
    if FStream <> 0 then
      if BASS_ChannelIsActive(FStream) = BASS_ACTIVE_STOPPED then
        DonePlayed;
    Result := FStream <> 0;
  end;


  procedure TBassPalyer.StopPlay;
  begin
    if FState <> psStopped then begin
      if TrackActive then begin
        { Чтобы плавное приглушение громкости не тормозило переключение каналов }
        if TickCountDiff(GetTickCount, FStartTick) > 1000 then
          VolumeSmoothDown(0);
        BASS_ChannelStop(FStream);
      end;
      FState := psStopped;
      FInfoChanged := True;
      TrackActive;
    end;
  end;


  procedure TBassPalyer.PausePlay;
  begin
    if TrackActive and (FState = psPlayed) then begin
      DisplayInfo(GetTrackName, 'Pause: On');
      VolumeSmoothDown(0);
      BASS_ChannelPause(FStream);
      FState := psPaused;
      FInfoChanged := True;
    end;
  end;


  procedure TBassPalyer.ResumePlay;
  begin
    if not TrackActive then begin
      if FTrackFile <> '' then
        BeginPlay;
    end else
    if TrackActive and (FState = psPaused) then begin
      DisplayInfo(GetTrackName, 'Pause: Off');
      BASS_ChannelPlay(FStream, False);
      VolumeSmoothUp;
      FState := psPlayed;
      FInfoChanged := True;
    end;
  end;


  procedure TBassPalyer.PlayOrPause;
  begin
    if TrackActive and (FState <> psPaused) then
      PausePlay
    else
      ResumePlay;
  end;


  procedure TBassPalyer.InitShuffleList(AMakeFirst :Boolean);
  var
    I, N :Integer;
  begin
//  Trace('Suffle...');
    if FShuffleList = nil then
      FShuffleList := TExList.Create;
    FShuffleList.Clear;
    N := FPlaylist.Count;
    for I := 0 to N - 1 do
      FShuffleList.Add(Pointer(I));
    Randomize;
    for I := 0 to N - 1 do
      FShuffleList.Exchange(I, Random(N));
    I := FShuffleList.IndexOf(Pointer(FIndex));
    if I <> -1 then
      if AMakeFirst then
        FShuffleList.Exchange(I, 0)
      else
        FShuffleList.Exchange(I, FShuffleList.Count - 1);
  end;


  procedure TBassPalyer.GotoNext;
  var
    vIndex :Integer;
  begin
    if FShuffle then begin
      if FShuffleList = nil then
        InitShuffleList(True);

      vIndex := FShuffleList.IndexOf(Pointer(FIndex));

      Inc(vIndex);
      if (vIndex >= FShuffleList.Count) and FRepeat then begin
        InitShuffleList(False);
        vIndex := 0;
      end;

      if vIndex < FShuffleList.Count then
        GotoIndex(Integer(FShuffleList[vIndex]));

    end else
    begin
      vIndex := FIndex + 1;
      if (vIndex >= FPlaylist.Count) and FRepeat then
        vIndex := 0;
      GotoIndex(vIndex);
    end;
  end;


  procedure TBassPalyer.GotoPrev;
  var
    vIndex :Integer;
  begin
    if FShuffle then begin
      if FShuffleList = nil then
        InitShuffleList(True);

      vIndex := FShuffleList.IndexOf(Pointer(FIndex));

      Dec(vIndex);
      if (vIndex < 0) and FRepeat then begin
        InitShuffleList(True);
        vIndex := FShuffleList.Count - 1;
      end;

      if vIndex >= 0 then
        GotoIndex(Integer(FShuffleList[vIndex]));

    end else
    begin
      vIndex := FIndex - 1;
      if (vIndex < 0) and FRepeat then
        vIndex := FPlaylist.Count - 1;
      GotoIndex(vIndex);
    end;
  end;


  procedure TBassPalyer.GotoIndex(AIndex :Integer);
  begin
    if AIndex = MaxInt - 1 then
      Exit;
    AIndex := RangeLimit(AIndex, 0, FPlaylist.Count - 1);
    if AIndex <> FIndex then begin
      StopPlay;
      BeginPlayIndex(AIndex);
    end;
  end;


  procedure TBassPalyer.GotoPlaylist(AIndex :Integer);
  var
    vFileName {, vStr} :TString;
  begin
    if AIndex = MaxInt - 1 then
      Exit;

    AIndex := RangeLimit(AIndex, 0, FHistory.Count - 1);
    if AIndex <> FHistIndex then begin
//    vStr := FHistory[AIndex];
      vFileName := FHistory.GetPlaylistName(AIndex);

      StopPlay;
      ClearPlaylist(False);

      if WinFileExists(vFileName) then begin
        LoadPlaylist(vFileName);

        {!!! Сохранять Index?}

        if FPlaylist.Count > 0 then
          BeginPlayIndex(0);
      end;
    end;
  end;


  procedure TBassPalyer.DeleteTrack(AIndex :Integer);
  begin
    if (AIndex >= 0) and (AIndex < FPlaylist.Count) then begin
      if FIndex = AIndex then begin
        FStartTick := GetTickCount;
        StopPlay;
        {???}
      end;

      FPlaylist.Delete(AIndex);

      if FIndex > AIndex then
        Dec(FIndex);
      if FUpdIndex > AIndex then
        Dec(FUpdIndex);

      FreeObj(FShuffleList);
      FPlaylistTick := GetTickCount;
      FPlaylistTick1 := 0;
    end;
  end;


  procedure TBassPalyer.MoveTrack(ASrcIndex, ADstIndex :Integer);
  begin
    if (ASrcIndex >= 0) and (ASrcIndex < FPlaylist.Count) and
      (ADstIndex >= 0) and (ADstIndex < FPlaylist.Count) then
    begin
      FPlaylist.Move(ASrcIndex, ADstIndex);

      if FIndex = ASrcIndex then
        FIndex := ADstIndex
      else begin
        if ASrcIndex < FIndex then begin
          if ADstIndex >= FIndex then
            Dec(FIndex);
        end else
        begin
          if ADstIndex <= FIndex then
            Inc(FIndex);
        end;
      end;

      FreeObj(FShuffleList);
      FPlaylistTick := GetTickCount;
      FPlaylistTick1 := 0;
    end;
  end;


  function TBassPalyer.GetVolume :FLOAT;
  begin
    Result := FVolume;
  end;


  procedure TBassPalyer.SetVolume(AVolume :FLOAT);
  begin
    if AVolume >= 0 then begin
      FVolume := FloatLimit(AVolume, 0, 100);
      BASS_ChannelSetAttribute(FStream, BASS_ATTRIB_VOL, FVolume / 100);
      DisplayInfo('', 'Volume: ' + Int2Str(Round(FVolume)));
      FMute := -1;
      FInfoChanged := True;
    end;
  end;



  function TBassPalyer.GetBalance :FLOAT;
  begin
    Result := FBalance;
  end;


  procedure TBassPalyer.SetBalance(ABalance :FLOAT);
  begin
    ABalance := FloatLimit(ABalance, -100, 100);
    if ABalance <> FBalance then begin
      FBalance := ABalance;
      BASS_ChannelSetAttribute(FStream, BASS_ATTRIB_PAN, FBalance / 100);
      DisplayInfo('', 'Balance: ' + Int2Str(Round(FBalance)));
      FInfoChanged := True;
    end;
  end;


  procedure TBassPalyer.Mute(AVolume :Float);
  begin
    if FMute < 0 then begin
      { Приглушаем звук }
      VolumeSmoothDown(AVolume);
      DisplayInfo('', 'Mute: On');
      FMute := AVolume;
    end else
    begin
      { Восстанавливаем громкость }
      VolumeSmoothUp;
      DisplayInfo('', 'Mute: Off');
      FMute := -1;
    end;
    FInfoChanged := True;
  end;


  procedure TBassPalyer.VolumeSmoothDown(AVolume :Float);
  begin
//  BASS_ChannelSlideAttribute(FStream, BASS_ATTRIB_FREQ, 1000, 500);
//  Sleep(300);

    BASS_ChannelSlideAttribute(FStream, BASS_ATTRIB_VOL, AVolume / 100, SmoothFadePeriod);
    while BASS_ChannelIsSliding(FStream, BASS_ATTRIB_VOL) do
      Sleep(1);
  end;


  procedure TBassPalyer.VolumeSmoothUp;
  begin
    BASS_ChannelSlideAttribute(FStream, BASS_ATTRIB_VOL, FVolume / 100, SmoothFadePeriod);
    while BASS_ChannelIsSliding(FStream, BASS_ATTRIB_VOL) do
      Sleep(1);
  end;


  procedure TBassPalyer.SetSpeed(ASpeed :FLOAT);
  begin
    if ASpeed > 0 then
      BASS_ChannelSetAttribute( FStream, BASS_ATTRIB_MUSIC_SPEED, ASpeed );
  end;


  function TBassPalyer.GetPosition :FLOAT;
  var
    vPos :QWORD;
  begin
    Result := 0;
    if TrackActive then begin
      vPos := BASS_ChannelGetPosition(FStream, BASS_POS_BYTE);
      if vPos > 0 then
        Result := BASS_ChannelBytes2Seconds(FStream, vPos);
    end;
  end;


  function TBassPalyer.GetAsyncPosition :FLOAT;
  begin
    Result := 0;
    if TrackActive then begin
      if FSeekReq <> -1 then
        Result := FSeekReq
      else
        Result := GetPosition;
    end;
  end;


  procedure TBassPalyer.AsyncSeekTo(ATime :FLOAT);
  var
    vPercent :FLOAT;
  begin
    if TrackActive and (FStreamType <> stShoutcast) then begin
      if ATime < 0 then
        ATime := 0
      else
      if ATime > FTRackLength then
        ATime := FTRackLength;

      if ATime <> FSeekReq then begin
        FSeekReq  := ATime;
        FSeekTick := GetTickCount;

        vPercent := 0;
        if FTrackLength > 0 then
          vPercent := ATime * 100 / FTrackLength;
        DisplayInfo(GetTrackName, Format('%d%% - %d sec', [Round(vPercent), Round(ATime)]));
      end;
    end;
  end;


  procedure TBassPalyer.SeekTo(ATime :FLOAT);
  var
    vPos, vLen :QWORD;
  begin
    if TrackActive and (FStreamType <> stShoutcast) then begin
//    TraceF('SeekTo: %d', [Round(ATime)]);
      if ATime < 0 then
        ATime := 0;
      vLen := BASS_ChannelGetLength(FStream, BASS_POS_BYTE);
      vPos := BASS_ChannelSeconds2Bytes(FStream, ATime);
      if vPos <> -1 then begin
        if vPos > vLen - 1 then
          vPos := vLen - 1;
        BASS_ChannelSetPosition(FStream, vPos, BASS_POS_BYTE);
      end;
      FSeekReq := -1;
      FSeekTick := 0;
      FInfoChanged := True;
    end;
  end;


  procedure TBassPalyer.LoadPlaylist(const AFileName :TString);
  var
    vFileName :TString;
    vCount :Integer;
  begin
    vFileName := CombineFileName(FCurPath, AFileName);
    if WinFileExists(vFileName) then begin
      vCount := FPlaylist.Count;
      try
        LoadPlaylistM3U(FPlaylist, vFileName);
      finally
        if (FUpdIndex = -1) and (FPlaylist.Count > vCount) then
          FUpdIndex := vCount;
        FreeObj(FShuffleList);
        FPlaylistTick := GetTickCount;
        FPlaylistTick1 := 0;
      end;
    end;
  end;


  procedure TBassPalyer.SavePlaylist(const AFileName :TString; AbsolutePath :Boolean);
  var
    vFileName :TString;
  begin
    vFileName := SafeChangeFileExtension(CombineFileName(FCurPath, AFileName), 'm3u');
    SavePlaylistM3U(FPlaylist, vFileName, AbsolutePath);
  end;


  procedure TBassPalyer.SetCurPath(const APath :TString);
  begin
    if APath <> '' then begin
      if WinFolderExists(APath) then
        FCurPath := APath;
    end else
      FCurPath := FRunPath;
  end;


  procedure TBassPalyer.RepeatMode(AOn :Boolean);
  begin
    if FRepeat <> AOn then begin
      FRepeat := AOn;
      DisplayInfo('', 'Repeat: ' + StrIf(FRepeat, 'On', 'Off'));
    end;
  end;


  procedure TBassPalyer.ShuffleMode(AOn :Boolean);
  begin
    if FShuffle <> AOn then begin
      FShuffle := AOn;
      FreeObj(FShuffleList);
      DisplayInfo('', 'Shuffle: ' + StrIf(FShuffle, 'On', 'Off'));
    end;
  end;


  procedure TBassPalyer.ShowTooltip(AShow :Boolean);
  begin
    if AShow <> FTooltip then begin
      if FTooltip then
        DisplayInfo('', 'Tooltip: off');
      FTooltip := AShow;
      if FTooltip then
        DisplayInfo('', 'Tooltip: on');
    end;
  end;


  procedure TBassPalyer.Quit;
  begin
    if FDlgLock > 0 then begin
      Beep;
      Exit;
    end;

//  DisplayInfo('', 'Bye!');
    if TrackActive then begin
      LastTrack := FTrackFile;
      LastTrackPos := Round(GetPosition);
      StopPlay;
    end;
    PostQuitMessage(0)
  end;


 {-----------------------------------------------------------------------------}

  procedure TBassPalyer.IconClick;
  var
    vStr :TString;
    vSave  :Boolean;
  begin
    vStr := CombineFileName(FExePath, 'WinNoisy.exe');
    if WinFileExists(vStr) then
      ShellOpen(0, vStr, '/Popup')
    else begin
      vSave := Player.FTooltip;
      Player.FTooltip := False;
      Player.PlayOrPause;
      Player.FTooltip := vSave;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TBassPalyer.GetMyAppDataFolder :TString;
  var
    vFolder :TString;
  begin
    vFolder := GetSpecialFolder(CSIDL_APPDATA);
    if WinFolderExists(vFolder) then begin
      vFolder := AddFileName(vFolder, 'Noisy');
      if not WinFolderExists(vFolder) then
        CreateDir(vFolder);
      Result := vFolder;
    end;
  end;


  procedure TBassPalyer.AutoSavePlaylist;
  var
    vFolder :TString;
  begin
    vFolder := GetMyAppDataFolder;
    if vFolder <> '' then begin
      SavePlaylist(AddFileName(vFolder, cAutoPlaylistName), True);
      FHistory.SavePlaylists;
    end;
  end;


  function TBassPalyer.FindTrackByName(const AName :TString; AShort :Boolean) :Integer;
  var
    I :Integer;
    vStr :TString;
  begin
    for I := 0 to FPlaylist.Count - 1 do begin
      vStr := ExtractWord(1, FPlaylist[I], ['|']);
      if AShort then
        vStr := ExtractFilenameEx(vStr);
      if StrEqual(vStr, AName) then begin
        Result := I;
        Exit;
      end;
    end;
    Result := -1;
  end;


  procedure TBassPalyer.AutoLoadPlaylist;
  var
    vFolder :TString;
  begin
    vFolder := GetMyAppDataFolder;
    if vFolder <> '' then begin
      LoadPlaylist(AddFileName(vFolder, cAutoPlaylistName));
      if FPlaylist.Count > 0 then begin
        FIndex := FindTrackByName(LastTrack, False);
        if FIndex = -1 then
          FIndex := 0;
        FTrackFile := FPlaylist[FIndex];
        with FPlaylist.TrackInfo[FIndex] do begin
          FTrackTitle  := Title;
          FTrackArtist := Artist;
          FTrackAlbum  := Album;
        end;
        FState := psStopped;
      end;

      FHistory.SetHistoryFolder( vFolder );
      FHistory.ReadPlaylists;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TBassPalyer.UpdateTrackInfo;
  var
    vOldTitle, vOldArtist, vOldAlbum :TString;
  begin
    if TrackActive then begin
//    Trace('UpdateTrackInfo...');
      vOldTitle  := FTrackTitle;
      vOldArtist := FTrackArtist;
      vOldAlbum  := FTrackAlbum;
      ExtractTrackInfo;
      if (vOldTitle <> FTrackTitle) or (vOldArtist <> FTrackArtist) or (vOldAlbum <> FTrackAlbum) then
        DisplayInfo(GetTrackName, GetTrackAddInfo);
    end;
  end;


  procedure TBassPalyer.ExtractTrackInfo;
  var
    vSize, vLen :QWORD;
    vPtr :PAnsiChar;
    vTitle, vArtist, vAlbum :TString;
  begin
    if FStreamType = stShoutcast then begin

      if FTrackArtist = '' then begin
        vPtr := BASS_ChannelGetTags(FStream, BASS_TAG_HTTP);
        if vPtr <> '' then
          FTrackArtist := ExtractTagValue(GetTagsStr(vPtr, #1), 'icy-name', [#1], [':']);
      end;

      if FTrackArtist = '' then begin
        vPtr := BASS_ChannelGetTags(FStream, BASS_TAG_ICY);
        if vPtr <> '' then
          FTrackArtist := ExtractTagValue(GetTagsStr(vPtr, #1), 'icy-name', [#1], [':']);
      end;

      vPtr := BASS_ChannelGetTags(FStream, BASS_TAG_META);
      if vPtr <> nil then
        FTrackAlbum := ExtractTagValue(vPtr, 'StreamTitle', [';'], ['=']);

    end else
    begin
      vSize := BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_END);
      vLen := BASS_ChannelGetLength(FStream, BASS_POS_BYTE);
      if vLen > 0 then
        FTrackLength := BASS_ChannelBytes2Seconds(FStream, vLen);
      if FTrackLength > 0 then
        FTrackBitrate := Round(vSize / (125 * FTrackLength) + 0.5);
      FTrackBytes := vSize;

      if ExtractStreamInfo(FStream, FTrackFile, vTitle, vArtist, vAlbum) then begin
        FTrackTitle := vTitle;
        FTrackArtist := vArtist;
        FTrackAlbum := vAlbum;

        { Обновляем данные Playlist-а }
        if (FIndex >= 0) and (FIndex < FPlaylist.Count) then begin
          if StrEqual(FPlaylist[FIndex], FTrackFile) then begin
            with FPlaylist.TrackInfo[Findex] do begin

              if not StrEqual(Title, FTrackTitle) or not StrEqual(Artist, FTrackArtist) or (LenSec <> Round(FTrackLength)) then
                if FPlaylistTick1 = 0 then
                  FPlaylistTick1 := GetTickCount;

              Title  := FTrackTitle;
              Artist := FTrackArtist;
              Album  := FTrackAlbum;
              LenSec := Round(FTrackLength);
            end;
          end;
        end;

      end;

    end;
  end;


  function TBassPalyer.ExtractStreamInfo(AStream :HSTREAM; const AFileName :TString; var ATitle, AArtist, AAlbum :TString) :Boolean;
  var
    vInfo :BASS_CHANNELINFO;
    vPtr :PAnsiChar;
    vTag :PID3v1Tag;
  begin
    Result := False;

    { Получаем Tag'и }
    FillChar(vInfo, SizeOf(vInfo), 0);
    BASS_ChannelGetInfo(AStream, vInfo);

    if vInfo.ctype = BASS_CTYPE_STREAM_MP3 then begin

      vPtr := BASS_ChannelGetTags(AStream, BASS_TAG_ID3V2);
      if vPtr <> nil then
        Result := ParseTagV2(vPtr, ATitle, AArtist, AAlbum);

      if not Result then begin
        vTag := Pointer(BASS_ChannelGetTags(AStream, BASS_TAG_ID3));
        if (vTag <> nil) and (vTag.cID = cID3v1TagID) then begin
          ATitle := StrFromChrA(vTag.cTitle, SizeOf(vTag.cTitle));
          AArtist := StrFromChrA(vTag.cArtist, SizeOf(vTag.cArtist));
          AAlbum := StrFromChrA(vTag.cAlbum, SizeOf(vTag.cAlbum));
          Result := (ATitle <> '') or (AArtist <> '');
        end;
      end;
    end;

    if not Result then
      Result := ParseOtherTags(AStream, ATitle, AArtist, AAlbum);

    if Result and (ATitle = '') then
      ATitle := ExtractFileTitle(AFileName);  

//  TraceF('Info extracted: %s - %s (%s)', [ATitle, AArtist, AAlbum]);
  end;


  procedure TBassPalyer.IdleUpdateTrackInfo;
  var
    vStr, vTitle, vArtist, vAlbum :TString;
    vStream :HSTREAM;
    vInfo :TTrackInfo;
    vLen :QWORD;
    vLenSec :Integer;
    vChanged :Boolean;
  begin
    if FUpdIndex >= FPlaylist.Count then begin
      FUpdIndex := -1;
      Exit;
    end;

    if FPlaylistTick <> 0 then
      { Чтобы обновление TrackInfo не начиналось пока добавляются треки... }
      Exit;

    vStr := FPlaylist[FUpdIndex];
    vInfo := FPlaylist.TrackInfo[FUpdIndex];
    Inc(FUpdIndex);

    if FileNameIsURL(vStr) then
      Exit;

    if vInfo.Title <> '' then
      Exit;

   {$ifdef bDebug}
//  TraceF('Update Info: %s', [vStr]);
   {$endif bDebug}
    vStream := BASS_StreamCreateFile(False, PTChar(vStr), 0, 0, BASS_UNICODE);
    if vStream <> 0 then begin
      try
        vLenSec := 0;
        vLen := BASS_ChannelGetLength(vStream, BASS_POS_BYTE);
        if vLen > 0 then
          vLenSec := Round(BASS_ChannelBytes2Seconds(vStream, vLen));

        vChanged := vLenSec <> vInfo.LenSec;
        vInfo.LenSec := vLenSec;

        if ExtractStreamInfo(vStream, vStr, vTitle, vArtist, vAlbum) then begin
          vChanged := vChanged or not StrEqual(vInfo.Title, vTitle) or not StrEqual(vInfo.Artist, vArtist);
          vInfo.Title  := vTitle;
          vInfo.Artist := vArtist;
          vInfo.Album  := vAlbum;
        end;

        if vChanged  and (FPlaylistTick1 = 0) then
          FPlaylistTick1 := GetTickCount;

      finally
        BASS_StreamFree(vStream)
      end;
    end;
  end;


  function TBassPalyer.GetTrackName :TString;
  begin
    Result := '';
    if FTrackFile <> '' {TrackActive} then begin
      if FTrackTitle <> '' then begin
        if FTrackArtist <> '' then
          Result := FTrackArtist + ' - ' + FTrackTitle
        else
          Result := cUnknownArtist + ' - ' + FTrackTitle;
      end else
        Result := FTrackArtist;
      if Result = '' then
        Result := ExtractFileNameEx(FTrackFile);
    end;
  end;


  function TBassPalyer.GetTrackAddInfo :TString;
  begin
    Result := '';
    if TrackActive then begin
      Result := FTrackAlbum;
      if Result = '' then
        Result := ' ';
    end;
  end;


 {-----------------------------------------------------------------------------}

 {!!! Interprocess critical section                                            }

  procedure TBassPalyer.InitMemState;
  var
    I, vSize :Integer;
    vPlugin :TBassPlugin;
    vFormat :TBassFormat;
    vPluginInfo :PBassPluginInfo;
    vFormatInfo :PAudioFormatInfo;
  begin
    vSize := SizeOf(TPlayerInfo) + FPlugins.Count * SizeOf(TBassPluginInfo) + FFormats.Count * SizeOf(TAudioFormatInfo);
    FInfoHandle := CreateMemoryMapping(InfoMemName, vSize);
    FPlayerInfo := MapMemory(FInfoHandle, True);
    FillChar(FPlayerInfo^, vSize, 0);
    FPlayerInfo.FStructSize := SizeOf(TPlayerInfo);

    { Сразу публикуем статическую информацию - о плагинах и форматах}
    vPluginInfo := Pointer(Pointer1(FPlayerInfo) + SizeOf(TPlayerInfo));
    for I := 0 to FPlugins.Count - 1 do begin
      vPlugin := FPlugins.Objects[I] as TBassPlugin;
      vPluginInfo.FVersion := vPlugin.FVersion;
      StrPLCopyA(@vPluginInfo.FName[0], FPlugins[I], cMaxPluginNameSize);
      Inc(Pointer1(vPluginInfo), SizeOf(TBassPluginInfo));
    end;

    vFormatInfo := Pointer(vPluginInfo);
    for I := 0 to FFormats.Count - 1 do begin
      vFormat := FFormats.Objects[I] as TBassFormat;
      vFormatInfo.FCode := vFormat.FCode;
      StrPLCopyA(@vFormatInfo.FName[0], FFormats[I], cMaxFormatNameSize);
      StrPLCopyA(@vFormatInfo.FExts[0], vFormat.FExts, cMaxFormatNameSize);
      Inc(Pointer1(vFormatInfo), SizeOf(TAudioFormatInfo));
    end;
  end;


  procedure TBassPalyer.PublishMemState;
  var
    vInfo :BASS_CHANNELINFO;
  begin
//  TraceF('State=%d (Loaded=%d)', [byte(FState), FTrackLoaded]);
    if TrackActive then begin
      StrPLCopy(@FPlayerInfo.FPlayedFile[0], FTrackFile, cMaxFileSize);
      StrPLCopy(@FPlayerInfo.FTrackTitle[0], FTrackTitle, cMaxTitleSize);
      StrPLCopy(@FPlayerInfo.FTrackArtist[0], FTrackArtist, cMaxTitleSize);
      StrPLCopy(@FPlayerInfo.FTrackAlbum[0], FTrackAlbum, cMaxTitleSize);

      FillChar(vInfo, SizeOf(vInfo), 0);
      BASS_ChannelGetInfo(FStream, vInfo);

      FPlayerInfo.FTrackFreq   := vInfo.Freq;
      FPlayerInfo.FTrackChans  := vInfo.Chans;
      FPlayerInfo.FTrackType   := vInfo.ctype;

      FPlayerInfo.FTrackLength := FTrackLength;
      FPlayerInfo.FTrackBPS    := FTrackBitrate;
      FPlayerInfo.FTrackBytes  := FTrackBytes;
      FPlayerInfo.FTrackLoaded := FTrackLoaded;
      FPlayerInfo.FStreamType  := FStreamType;

      FPlayerInfo.FPlayTime    := GetPosition;
    end else
    begin
      FillChar(FPlayerInfo^, SizeOf(TPlayerInfo), 0);
      StrPLCopy(@FPlayerInfo.FPlayedFile[0], FTrackFile, cMaxFileSize);
      StrPLCopy(@FPlayerInfo.FTrackTitle[0], FTrackTitle, cMaxTitleSize);
      StrPLCopy(@FPlayerInfo.FTrackArtist[0], FTrackArtist, cMaxTitleSize);
      StrPLCopy(@FPlayerInfo.FTrackAlbum[0], FTrackAlbum, cMaxTitleSize);
    end;

    FPlayerInfo.FState       := FState;
    FPlayerInfo.FRepeat      := FRepeat;
    FPlayerInfo.FShuffle     := FShuffle;
    FPlayerInfo.FSystray     := FSysTray;
    FPlayerInfo.FTooltips    := FTooltip;
    FPlayerInfo.FHotkeys     := FHotkeys;

    FPlayerInfo.FBassVersion := FBassVersion;
    FPlayerInfo.FTrackCount  := FPlaylist.Count;
    FPlayerInfo.FTrackIndex  := FIndex;
    FPlayerInfo.FVolume      := FVolume;
    FPlayerInfo.FMute        := FMute >= 0;

    FPlayerInfo.FPlaylistRev := FPlaylistRev;

    FPlayerInfo.FPlugins     := FPlugins.Count;
    FPlayerInfo.FFormats     := FFormats.Count;

    FPlayerInfo.FStructSize := SizeOf(TPlayerInfo);
//  TraceF('Time: %g', [FPlayerInfo.FPlayTime]);
  end;


  procedure TBassPalyer.DoneMemState;
  begin
    if FPlayerInfo <> nil then begin
      UnMapViewOfFile(FPlayerInfo);
      FPlayerInfo := nil;
    end;
    if FInfoHandle <> 0 then begin
      CloseHandle(FInfoHandle);
      FInfoHandle := 0;
    end;
  end;


 {-----------------------------------------------------------------------------}


  procedure TBassPalyer.PublishMemPlaylist;
  const
    PageSize = 4096;
  var
    I, vLen :Integer;
    vStr    :TString;
    vList   :TStringList;
    vSize   :Integer;
    vPtr    :Pointer1;
   {$ifdef bTrace}
    vStart  :Cardinal;
   {$endif bTrace}
  begin
   {$ifdef bTrace}
    TraceF('Publish playlist (%d tracks)...', [FPlayList.Count]);
    vStart := GetTickCount;
   {$endif bTrace}

    if FPlayList.Count = 0 then
      DoneMemPlaylist
    else begin
      FHistIndex := FHistory.SetCurrentPlaylist(FHistIndex, FPlaylist);

      vList := TStringList.Create;
      try
        for I := 0 to FPlaylist.Count - 1 do
          with PStringItem(FPlaylist.PItems[I])^, FPlaylist.TrackInfo[I] do
            vList.Add(FString + '|' + Int2Str(LenSec) + '|' +  GetInfoAsStr);
        vStr := vList.Text;
      finally
        FreeObj(vList);
      end;

      vLen := Length(vStr);
      vSize := vLen * SizeOf(TChar) + SizeOf(Integer);
      vSize := (vSize + (PageSize - 1)) and not (PageSize - 1);
      if FMemSize <> vSize then begin
        DoneMemPlaylist;
        FMemHandle := CreateMemoryMapping(PlaylistMemName, vSize);
        FMemSize := vSize;
      end;

      vPtr := MapMemory(FMemHandle, True);
      try
        if vPtr = nil then
          RaiseLastWin32Error;
        CopyMemory(vPtr, @vLen, SizeOf(Integer));
        CopyMemory(vPtr + SizeOf(Integer), PTChar(vStr), vLen * SizeOf(TChar));
      finally
        UnMapViewOfFile(vPtr);
      end;
    end;

    Inc(FPlaylistRev);

   {$ifdef bTrace}
    TraceF('Done Rev=%d (%d bytes, %d ms)', [FPlaylistRev, FMemSize, TickCountDiff(GetTickCount, vStart)]);
   {$endif bTrace}
  end;


  procedure TBassPalyer.DoneMemPlaylist;
  begin
    if FMemHandle <> 0 then begin
      CloseHandle(FMemHandle);
      FMemHandle := 0;
      FMemSize := 0;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TBassPalyer.CreateWnd;
  var
    vWndClass, vTempClass :TWndClass;
  begin
    FillChar(vWndClass, SizeOf(vWndClass), 0);
    vWndClass.hInstance := HInstance;
    vWndClass.lpfnWndProc := @MyWindowProc;
    vWndClass.lpszClassName := WndClassName;
    if not GetClassInfo(HInstance, WndClassName, vTempClass) then
      Windows.RegisterClass(vWndClass);
    FWindow := CreateWindow(WndClassName, 'Noisy', WS_POPUP or WS_BORDER{!!!}, 0, 0, 0, 0, 0, 0, HInstance, nil);
  end;


  function TBassPalyer.GetSysTrayIcon :THandle;
  begin
    if FState = psPlayed then
      Result  := FPlayIcon
    else
    if FState = psPaused then
      Result  := FPauseIcon
    else
      Result  := FStopIcon;
  end;


  function TBassPalyer.GetSysTrayHint :TString;
  var
    vStr :TString;
  begin
    if TrackActive then begin
      Result := GetTrackName;
      vStr := GetTrackAddInfo;
      if not StrIsEmpty(vStr) then
        Result := Result + #13 + vStr;
    end else
      Result := 'Noisy Player';
  end;


  procedure TBassPalyer.ShowInSysTray(AShow :Boolean);

    procedure LocAdd(const aCaption :TString; aType, aState :UINT; aTag :Integer);
    begin
      AddMenuItem(FMenu, aCaption, aType, aState, 0, aTag);
    end;

  begin
    if AShow <> FSysTray then begin
      if AShow then begin
        SysTrayUpdate(True, FWindow, GetSysTrayIcon, GetSysTrayHint);
        FSysTray := True;

        FPlaylistMenu := CreatePopupMenu;
        FHistoryMenu := CreatePopupMenu;
//      LocCreateMenuItemEx(FPlaylistMenu, 'Clear', MFT_STRING, 0, 0, 0);

        FMenu := CreatePopupMenu;
        LocAdd('Open', MFT_STRING, 0, cmOpen);
        LocAdd('', MFT_SEPARATOR, MFS_DISABLED, 0);
        LocAdd('Play / Pause', MFT_STRING, 0, cmPlay);
        LocAdd('Stop', MFT_STRING, 0, cmStop);
        LocAdd('', MFT_SEPARATOR, MFS_DISABLED, 0);
        LocAdd('Next track', MFT_STRING, 0, cmNext);
        LocAdd('Prev track', MFT_STRING, 0, cmPrev);
        AddMenuItem(FMenu, 'Playlist', MFT_STRING, 0, FPlaylistMenu, 0);
        AddMenuItem(FMenu, 'History', MFT_STRING, 0, FHistoryMenu, 0);
        LocAdd('', MFT_SEPARATOR, MFS_DISABLED, 0);
        LocAdd('Exit', MFT_STRING, 0, cmQuit);
      end else
      begin
        SysTrayDelete(FWindow);
        FSysTray := False;

        if FMenu <> 0 then begin
          DestroyMenu(FMenu);
          FMenu := 0;
        end;

        if FPlaylistMenu <> 0 then
          FPlaylistMenu := 0;
        if FHistoryMenu <> 0 then
          FHistoryMenu := 0;
      end;
    end;
  end;


  procedure TBassPalyer.UpdateSystray;
  begin
    if FSysTray then begin
//    Trace('Update sys tray...');
      SysTrayUpdate(False, FWindow, GetSysTrayIcon, GetSysTrayHint);
    end;
  end;


  procedure TBassPalyer.SetupPlaylistMenu(AMenu :HMenu);
  var
    I, N :Integer;
    vTrack, vTitle :TString;
  begin
    N := GetMenuItemCount(AMenu);
    for I := N - 1 downto 0 do
      DeleteMenu(AMenu, I, MF_BYPOSITION);

    for I := 0 to IntMin(FPlaylist.Count, $FFF) - 1 do begin
      vTrack := FPlaylist[I];
      with FPlaylist.TrackInfo[I] do begin
        vTitle := GetInfoAsStr;
        if vTitle = '' then
          vTitle := ExtractFileNameEx(vTrack);
        if LenSec > 0 then
          vTitle := vTitle + #9 + Time2Str(LenSec);
      end;
      AddMenuItem(AMenu, vTitle, MFT_STRING or MFT_RADIOCHECK, 0, 0, cmGoto or I );
    end;

    CheckMenuItem(AMenu, FIndex, MF_BYPOSITION or MF_CHECKED);
    SetMenuDefaultItem(AMenu, FIndex, 1);
  end;


  procedure TBassPalyer.SetupHistoryMenu(AMenu :HMenu);
  var
    I, N, M :Integer;
    vStr :TString;
    vReview :TPlaylistReview;
  begin
    N := GetMenuItemCount(AMenu);
    for I := N - 1 downto 0 do
      DeleteMenu(AMenu, I, MF_BYPOSITION);

    M := IntMin(FHistory.Count, 25);
    for I := M - 1 downto 0 do begin
      vReview := FHistory.Objects[I] as TPlaylistReview;
      vStr := vReview.GetMenuDidgest;
      AddMenuItem(AMenu, vStr, MFT_STRING or MFT_RADIOCHECK, 0, 0, cmHist or I );
    end;

    if (FHistIndex >= 0) and (FHistIndex < M) then begin
      CheckMenuItem(AMenu, M - FHistIndex - 1, MF_BYPOSITION or MF_CHECKED);
      SetMenuDefaultItem(AMenu, M - FHistIndex - 1, 1);
    end;
  end;


  procedure TBassPalyer.PopupMenu(APlaylist, AMousePos :Boolean);

    procedure SetMenuItem(ATag :Integer; const AText :TString; AEnabled :Boolean);
    var
      vItem :TMenuItemInfo;
    begin
      FillChar(vItem, SIzeOf(vItem), 0);
      vItem.cbSize := 44; // Required for Windows 95
      vItem.fMask := MIIM_STATE;
      if GetMenuItemInfo(FMenu, ATag, False, vItem) then begin
        if AEnabled then
          vItem.fState := vItem.fState and not MFS_DISABLED
        else
          vItem.fState := vItem.fState or MFS_DISABLED;
        if AText <> '' then begin
          vItem.fMask := vItem.fMask or MIIM_TYPE;
          vItem.dwTypeData := PTChar(AText);
        end;
        SetMenuItemInfo(FMenu, ATag, False, vItem);
      end;
    end;

  var
    vPoint :TPoint;
  begin
    HideInfo;

    if AMousePos then
      GetCursorPos(vPoint)
    else
      vPoint := GetSystrayWindowPos;

    if APlaylist then begin
      SetForegroundWindow(FWindow);
      Win32Check(TrackPopupMenu(FPlaylistMenu, TPM_RIGHTALIGN or TPM_LEFTBUTTON or TPM_VERTICAL, vPoint.x, vPoint.y, 0, FWindow, nil));
    end else
    begin
      if FState = psPlayed then
        SetMenuItem(cmPlay, 'Pause', True)
      else
        SetMenuItem(cmPlay, 'Play', FPlaylist.Count > 0);
      SetMenuItem(cmStop, '', FState in [psPlayed, psPaused]);
      SetMenuItem(cmNext, '', FIndex < FPlaylist.Count - 1);
      SetMenuItem(cmPrev, '', FIndex > 0);

      SetForegroundWindow(FWindow);
      Win32Check(TrackPopupMenu(FMenu, TPM_RIGHTALIGN or TPM_LEFTBUTTON or TPM_VERTICAL, vPoint.x, vPoint.y, 0, FWindow, nil));
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Tooltip support                                                             }

  procedure TBassPalyer.DisplayInfo(const ATitle, AStr :TString);
  begin
    if FSysTray and FTooltip then begin
//    TraceF('DisplayInfo: %s, %s', [ATitle, AStr]);
      WinShowTooltip(FWindow, ATitle, AStr);
      FTooltipTick := GetTickCount;
    end;
  end;


  procedure TBassPalyer.HideInfo;
  begin
    if FSysTray  then begin
//    Trace('HideInfo');
      WinHideTooltip(FWindow);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Подержка Hotkey                                                             }

  procedure TBassPalyer.RunHotkey(ANum :Integer);
  begin
    if (ANum < 0) or (ANum >= FHotkeyList.Count) then
      Exit;
    ParseCommand( FHotkeyList[ANum] );
  end;


  procedure TBassPalyer.ActivateHotkeys(AOn :Boolean; ANotify :Boolean);

    procedure LocRegister(const ACmd :TString; AHotkey :Cardinal);
    var
      vShift, vKey :Cardinal;
    begin
      if AHotkey = 0 then
        Exit;

      vKey := AHotkey and $0000FFFF;
      vShift := AHotkey and $FFFF0000 shr 16;

      if RegisterHotkey(FWindow, FHotkeyList.Count, vShift, vKey) then begin
        FHotkeyList.Add(ACmd);
      end;
    end;

  var
    I :Integer;
  begin
    if FHotkeys <> AOn then begin

      if AOn then begin
        ReinitHotkeySettings;
        for I := 0 to FHotkeyCmds.Count - 1 do
          LocRegister(FHotkeyCmds[I], Cardinal(FHotkeyCmds.Objects[I]));
      end else
      begin
        for I := 0 to FHotkeyList.Count - 1 do
          UnregisterHotKey(FWindow, I);
        FHotkeyList.Clear;
      end;

      FHotkeys := AOn;
      
      if ANotify then
        DisplayInfo('', 'Hotkeys: ' + StrIf(FHotkeys, 'On', 'Off'));
    end;
  end;


  procedure TBassPalyer.ReinitHotkeySettings;
  const
    HotkeyPlay   :Cardinal = VK_MEDIA_PLAY_PAUSE;
    HotkeyStop   :Cardinal = VK_MEDIA_STOP;
    HotkeyNext   :Cardinal = VK_MEDIA_NEXT_TRACK;
    HotkeyPrev   :Cardinal = VK_MEDIA_PREV_TRACK;
    HotkeyNextPL :Cardinal = VK_MEDIA_NEXT_TRACK or (MOD_ALT) shl 16 ;
    HotkeyPrevPL :Cardinal = VK_MEDIA_PREV_TRACK or (MOD_ALT) shl 16 ;
    HotkeyVolUp  :Cardinal = VK_VOLUME_UP        or (MOD_ALT) shl 16 ;
    HotkeyVolDn  :Cardinal = VK_VOLUME_DOWN      or (MOD_ALT) shl 16 ;
    HotkeyMute   :Cardinal = VK_VOLUME_MUTE      or (MOD_ALT) shl 16 ;
  begin
    FHotkeyCmds.Clear;
    if not ReadHotkeysFromReg(FHotkeyCmds) then begin
      { Инициализируем умолчания... }
      FHotkeyCmds.AddObject('/PlayPause', Pointer(HotkeyPlay));
      FHotkeyCmds.AddObject('/Stop', Pointer(HotkeyStop));
      FHotkeyCmds.AddObject('/Next', Pointer(HotkeyNext));
      FHotkeyCmds.AddObject('/Prev', Pointer(HotkeyPrev));
      FHotkeyCmds.AddObject('/NextPlaylist', Pointer(HotkeyNextPL));
      FHotkeyCmds.AddObject('/PrevPlaylist', Pointer(HotkeyPrevPL));
      FHotkeyCmds.AddObject('/Volume=+5', Pointer(HotkeyVolUp));
      FHotkeyCmds.AddObject('/Volume=-5', Pointer(HotkeyVolDn));
      FHotkeyCmds.AddObject('/Mute=5', Pointer(HotkeyMute));
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TBassPalyer.InitCommands;

    procedure AddCmd(const AKeyword :TString; ACommand :TNoisyCommands);
    begin
      FCommands.AddObject(AKeyword, Pointer(ACommand));
    end;

  begin
    AddCmd('Add',           cmdAdd);
    AddCmd('Recursive',     cmdRecursive);
    AddCmd('Open',          cmdOpen);
    AddCmd('Stop',          cmdStop);
    AddCmd('Pause',         cmdPause);
    AddCmd('Play',          cmdPlay);
    AddCmd('PlayPause',     cmdPlayPause);
    AddCmd('Next',          cmdNext);
    AddCmd('Prev',          cmdPrev);
    AddCmd('First',         cmdFirst);
    AddCmd('Last',          cmdLast);
    AddCmd('Goto',          cmdGoto);
    AddCmd('Volume',        cmdVolume);
    AddCmd('Balance',       cmdBalance);
    AddCmd('Mute',          cmdMute);
    AddCmd('Seek',          cmdSeek);
    AddCmd('Speed',         cmdSpeed);
    AddCmd('Delete',        cmdDelete);
    AddCmd('MoveTrack',     cmdMoveTrack);
    AddCmd('Clear',         cmdClear);
    AddCmd('Load',          cmdLoad);
    AddCmd('Save',          cmdSave);
    AddCmd('Playlist',      cmdPlaylist);
    AddCmd('NextPlaylist',  cmdNextPlaylist);
    AddCmd('PrevPlaylist',  cmdPrevPlaylist);
    AddCmd('GotoPlaylist',  cmdGotoPlaylist);
    AddCmd('ClearHistory',  cmdClearHistory);
    AddCmd('Lock',          cmdLock);
    AddCmd('Unlock',        cmdUnlock);
    AddCmd('CurPath',       cmdCurPath);
    AddCmd('Repeat',        cmdRepeat);
    AddCmd('Shuffle',       cmdShuffle);
    AddCmd('SysTray',       cmdSysTray);
    AddCmd('Tooltip',       cmdTooltip);
    AddCmd('Hotkeys',       cmdHotkeys);
    AddCmd('ShowInfo',      cmdShowInfo);
    AddCmd('Info',          cmdInfo);
    AddCmd('NoTooltip',     cmdNoTooltip);
    AddCmd('Async',         cmdAsync);
    AddCmd('Quit',          cmdQuit);
  end;


  procedure TBassPalyer.ParseCommand(const AStr :TString);
  var
    vStr :PTChar;
    vCmd, vPar :TString;
    vChr :TChar;
    vNum :Float;
    vAdd, vRecursive :Boolean;
    vOldTooltip :Integer;
    vPos, vIndex :Integer;
    vCommand :TNoisyCommands;
  begin
   {$ifdef bTrace}
    TraceF('Command=%s', [AStr]);
   {$endif bTrace}

    vAdd := False;
    vRecursive := False;
    vOldTooltip := -1;
    FIdleTick := 0;
    try
      vStr := PTChar(AStr);
      while vStr^ <> #0 do begin
        vCmd := ExtractParamStr(vStr);
        if vCmd = '' then
          Continue;

        if (vCmd[1] = '/') or (vCmd[1] = '-') then begin
          Delete(vCmd, 1, 1);

          vPar := '';
          vPos := ChrPos('=', vCmd);
          if vPos <> 0 then begin
            vPar := Copy(vCmd, vPos + 1, MaxInt);
            vCmd := Copy(vCmd, 1, vPos - 1);
          end;

          vChr := #0;
          if vPar <> '' then
            vChr := CharUpcase(vPar[1]);

          vIndex := FCommands.IndexOf(vCmd);
          if vIndex >= 0 then begin
            vCommand := TNoisyCommands(FCommands.Objects[vIndex]);
            case vCommand of
              cmdAdd:       vAdd := True;
              cmdRecursive: vRecursive := True;
              cmdOpen:      OpenFiles;
              cmdStop:      StopPlay;
              cmdPause:     PausePlay;
              cmdPlay:      ResumePlay;
              cmdPlayPause: PlayOrPause;
              cmdNext:      GotoNext;
              cmdPrev:      GotoPrev;
              cmdFirst:     GotoIndex(0);
              cmdLast:      GotoIndex(MaxInt);

              cmdGoto:
                if vPar <> '' then begin
                  if (vChr = '+') or (vChr = '-') then
                    GotoIndex(FIndex + Str2IntDef(vPar, 0))
                  else begin
                    vIndex := Str2IntDef(vPar, 0) - 1;
                    if vIndex >= 0 then
                      GotoIndex(vIndex)
                    else begin
                      vIndex := FindTrackByName(vPar, False);
                      if vIndex = -1 then
                        vIndex := FindTrackByName(vPar, True);
                      if vIndex <> -1 then
                        GotoIndex(vIndex);
                    end;
                  end;
                end;

              cmdVolume:
                if vPar <> '' then begin
                  if (vChr = '+') or (vChr = '-') then
                    SetVolume(FloatLimit(GetVolume + StrToFloatDef(vPar, 0), 0, 100))
                  else
                    SetVolume(StrToFloatDef(vPar, -1))
                end;

              cmdBalance:
                if vPar <> '' then begin
                  if (vChr = '+') or (vChr = '-') then
                    SetBalance(GetBalance + StrToFloatDef(vPar, 0))
                  else begin
                    if (vChr = 'L') or (vChr = 'R') then
                      vPar := Copy(vPar, 2, MaxInt);
                    vNum := StrToFloatDef(vPar, 0);
                    if vChr = 'L' then
                      vNum := -vNum;
                    SetBalance(vNum);
                  end;
                end;

              cmdMute:
                Mute(StrToFloatDef(vPar, 0));

              cmdSeek:
                if vPar <> '' then begin
                  if (vChr = '+') or (vChr = '-') then
                    AsyncSeekTo(GetAsyncPosition + StrToFloatDef(vPar, 0))
                  else
                    SeekTo(Str2IntDef(vPar, -1))
                end;

              cmdSpeed:
                SetSpeed(StrToFloatDef(vPar, -1));

              cmdDelete:     DeleteTrack(Str2IntDef(vPar, 0) - 1);
              cmdMoveTrack:  MoveTrack(Str2IntDef(ExtractWord(1, vPar, [';']), 0) - 1, Str2IntDef(ExtractWord(2, vPar, [';']), 0) - 1);
              cmdClear:      ClearPlaylist(True);

              cmdLoad:
                begin
                  if not vAdd then
                    ClearPlaylist(False);
                  LoadPlaylist(vPar);
                  if not TrackActive and (FPlaylist.Count > 0) then
                    BeginPlayIndex(0);
                end;

              cmdSave:
                SavePlaylist(vPar, False);

              cmdPlaylist:
                PopupMenu(True, False);

              cmdNextPlaylist:
                {Sorry};
              cmdPrevPlaylist:
                {Sorry};
              cmdGotoPlaylist:
                {Sorry};
              cmdClearHistory:
                FHistory.ClearHistory;

              cmdLock:
                Inc(FLocked);
              cmdUnlock:
                if FLocked > 0 then
                  Dec(FLocked);
              cmdCurPath:
                SetCurPath(vPar);

              cmdRepeat:
                if vPar = '' then
                  RepeatMode( not FRepeat)
                else
                  RepeatMode( vPar = '1' );

              cmdShuffle:
                if vPar = '' then
                  ShuffleMode( not FShuffle)
                else
                  ShuffleMode( vPar = '1' );

              cmdSysTray:
                if vPar = '' then
                  ShowInSysTray( not FSysTray)
                else
                  ShowInSysTray( vPar = '1' );

              cmdTooltip:
                if vPar = '' then
                  ShowTooltip( not FTooltip)
                else
                  ShowTooltip( vPar = '1');

              cmdHotkeys:
                if vPar = '' then
                  ActivateHotkeys( not FHotkeys, True)
                else
                  ActivateHotkeys( vPar = '1', True);

              cmdShowInfo:
                DisplayInfo(GetTrackName, GetTrackAddInfo);

              cmdInfo: begin
                FInfoChanged := False;
                PublishMemState;
              end;

              cmdNoTooltip: begin
                vOldTooltip := Byte(FTooltip);
                FTooltip := False;
              end;

              cmdAsync: begin
                FAsyncCmds.Add(vStr);
                Exit;
              end;

              cmdQuit:
                Quit;
            end;
          end; {if}

        end else
        begin
          { Не команда, а имя файла }
//        if not vAdd then
//          ClearPlaylist(False);
          AddFile(vCmd, vRecursive, not vAdd);
          if not TrackActive and (FPlaylist.Count > 0) and not vAdd then
            BeginPlayIndex(0);
          vAdd := True;
        end;

      end; {while}

    finally
      if vOldTooltip <> -1 then
        FTooltip := vOldTooltip <> 0;
    end;
  end;


  procedure TBassPalyer.CheckPlay;
  var
    vTick :Cardinal;
    vIndex :Integer;
    vStr :TString;
  begin
    if (FAsyncCmds.Count > 0) and (FAsyncLock = 0) then begin
      inc(FAsyncLock);
      try
        vStr := FAsyncCmds[0];
        FAsyncCmds.Delete(0);
        ParseCommand(vStr);
      finally
        Dec(FAsyncLock);
      end;
    end;

    if not TrackActive and (FState <> psStopped) then begin
      vIndex := FIndex;
      GotoNext;

      if not TrackActive and (FIndex = vIndex) then begin
        FState := psStopped;
        FInfoChanged := True;
        DisplayInfo('Noisy Player', 'Finish');
      end
    end;

    if FUpdIndex <> -1 then
      { Фоновое извлечение тегов для треков playlist'а }
      IdleUpdateTrackInfo;

    vTick := GetTickCount;

    if (FSyncTick <> 0) and (TickCountDiff(vTick, FSyncTick) > ResyncPeriod) then begin
      { Синхронизация Shoutcast потока (или извлечение тэгов по окончании буферизации) }
      FSyncTick := 0;
      FInfoChanged := True;
      UpdateTrackInfo;
    end;

    if (FSeekReq <> -1) and (TickCountDiff(vTick, FSeekTick) > AsyncSeekPeriod) then begin
      SeekTo(FSeekReq);
    end;

    if TrackActive then begin
      if TickCountDiff(vTick, FUpdateTick) > StatusUpdatePeriod then begin
        FInfoChanged := True;
        FUpdateTick := vTick;
      end;
    end;

    if ((FPlaylistTick <> 0) and (TickCountDiff(vTick, FPlaylistTick) > PlaylistUpdateDelay)) or
      (FPlaylistTick1 <> 0) and (TickCountDiff(vTick, FPlaylistTick1) > PlaylistInfoDelay)
    then begin
      FPlaylistTick := 0;
      FPlaylistTick1 := 0;
      FInfoChanged := True;
      PublishMemPlaylist;
    end;

    if FInfoChanged then begin
      FInfoChanged := False;
      PublishMemState;
      UpdateSystray;
    end;

    if (FTooltipTick <> 0) and (TickCountDiff(vTick, FTooltipTick) > TooltipPeriod) then begin
      FTooltipTick := 0;
      HideInfo;
    end;

    if (FState = psStopped) {not TrackActive} and (FLocked = 0) and (FDlgLock = 0) and (IdleShutdownPeriod > 0) then begin
      if FIdleTick = 0 then
        FIdleTick := vTick
      else begin
        if TickCountDiff(vTick, FIdleTick) > IdleShutdownPeriod then
          PostQuitMessage(0)
      end;
    end else
      FIdleTick := 0;
  end;


  procedure TBassPalyer.Idle;
  begin
//  Trace('Idle...');
    CheckPlay;
  end;


 {-----------------------------------------------------------------------------}

  procedure TBassPalyer.Run;
  var
    vMsg :TMsg;
  begin
    while True do begin
      if PeekMessage(vMsg, 0, 0, 0, PM_REMOVE) then begin
        if vMsg.Message <> WM_Quit then begin
          TranslateMessage(vMsg);
          DispatchMessage(vMsg);
        end else
          Break;
      end else
        Sleep(1);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ShowHelp;
  var
    vStr :TString;
  begin
    vStr := TString(
      'Usage: '#13 +
      '  Noisy [Commands...] [FileNames...]'#13 +
      'Commands:'#13 +
      '  /Play'#13 +
      '  /Stop'#13 +
      '  /Pause'#13 +
      '  ...'+#13 +
      'see documentation for more.' );

    MessageBox(0, PTChar(vStr), 'Information', MB_OK or MB_ICONINFORMATION);
  end;


  procedure SendStrTo(AWnd :THandle; const AStr :TString);
  var
    vStruct :CopyDataStruct;
  begin
    vStruct.dwData := nSendCmd;
    vStruct.cbData := Length(AStr) * SizeOf(TChar);
    vStruct.lpData := PTChar(AStr);
    SendMessage(AWnd, WM_CopyData, 0, Integer(@vStruct));
  end;


  procedure Run;
  var
    vStr, vCurPath :TString;
    vWnd :THandle;
  begin
    vStr := GetCommandLineStr;
    if vStr = '' then begin
      ShowHelp;
      Halt(0);
    end;

    if CheckMutexExistsEx(MutexName, False) then begin
      vWnd := FindWindow(WndClassName, nil);
      if vWnd = 0 then
        AppError('Window not found');
      vCurPath := GetCurrentDir;
      SendStrTo(vWnd, '"/CurPath=' + vCurPath + '" ' + vStr);
    end else
    begin
      Player := TBassPalyer.Create;
      try
        Player.ParseCommand(vStr);
        Player.Run;
      finally
        FreeObj(Player);
      end;
    end;
  end;


end.

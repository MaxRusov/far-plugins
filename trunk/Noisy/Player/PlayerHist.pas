{$I Defines.inc}

unit PlayerHist;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Player main module                                                         *}
{******************************************************************************}

interface

  uses
    Windows,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixWinUtils,
    MixClasses,
    MixCRC,

    NoisyConsts,
    NoisyUtil,
    PlayerTags,
    PlayerWin,
    PlayerReg;

  const
    cHistoryFolderName   :TString = 'History';
    cHistoryIndexName    :TString = 'History.dat';

    cUnknownArtist       :TString = 'Unknown Artist';

  type
    TTrackInfo = class(TBasis)
    public
      Title  :TString;
      Artist :TString;
      Album  :TString;
      LenSec :Integer;

      function GetInfoAsStr :TString;
    end;


    TPlaylist = class(TObjStrings)
    public
      function AddTrack(const AFileName, AInfoStr :TString; ALenSec :Integer) :Integer;

    private
      function GetTrackInfo(AIndex :Integer) :TTrackInfo;

    public
      property TrackInfo[I :Integer] :TTrackInfo read GetTrackInfo;
    end;


    TPlaylistReview = class(TBasis)
    public
      function GetMenuDidgest :TString;

    private
      FDidgest     :TString;
      FTrackCount  :Integer;
      FCurTrack    :Integer;
      FLastAccess  :TDateTime;
      FSaved       :Boolean;

    public
      property Didgest :TString read FDidgest;
    end;


    TPlaylistHistory = class(TObjStrings)
    public
      procedure SetHistoryFolder(const AFolder :TString);

      procedure ReadPlaylists;
      procedure SavePlaylists;
      procedure AddToHistory(APlaylist :TPlaylist; ACurTrack :Integer);
      function SetCurrentPlaylist(AIndex :Integer; APlaylist :TPlaylist) :Integer;

      procedure ClearHistory;

      function GetPlaylistName(AIndex :Integer) :TString;

    private
      FAppFolder  :TString;
      FHistFolder :TString;

      procedure CheckOverflow(ALimit :Integer);
      function CalcPlaylistCRC(APlaylist :TPlaylist) :TCRC;
      function MakePlaylistDidgest(APlaylist :TPlaylist) :TString;
    end;


  procedure SavePlaylistM3U(APlaylist :TPlaylist; const AFileName :TString; AbsolutePath :Boolean);
  procedure LoadPlaylistM3U(APlaylist :TPlaylist; const AFileName :TString);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure SavePlaylistM3U(APlaylist :TPlaylist; const AFileName :TString; AbsolutePath :Boolean);
  var
    I, vLenSec :Integer;
    vListPath, vTrack, vTitle :TString;
    vList :TStringList;
  begin
    vList := TStringList.Create;
    try
      vListPath := ExtractFilePath(AFileName);
      vList.Add('#EXTM3U');
      for I := 0 to APlaylist.Count - 1 do begin
        vTrack := APlaylist[I];
        with APlaylist.TrackInfo[I] do begin
          vTitle := GetInfoAsStr;
          vLenSec := LenSec;
        end;
        if vTitle <> '' then
          vList.Add(Format('#EXTINF:%d,%s', [vLenSec, vTitle]));
        if not AbsolutePath then
          vTrack := ExtractRelativePath(vListPath, vTrack);
        vList.Add(vTrack);
      end;
      vList.SaveToFile(AFileName, sffAnsi);
    finally
      FreeObj(vList);
    end;
  end;


  procedure LoadPlaylistM3U(APlaylist :TPlaylist; const AFileName :TString);
  var
    I, vLenSec :Integer;
    vListPath, vStr, vTrack, vTitle :TString;
    vList :TStringList;
  begin
    vListPath := ExtractFilePath(AFileName);
    vList := TStringList.Create;
    try
      vList.LoadFromFile(AFileName);
      vTitle := '';
      vLenSec := 0;
      for I := 0 to vList.Count - 1 do begin
        vStr := Trim(vList[I]);
        if (vStr <> '') and (vStr[1] <> ';') then begin
          if vStr[1] = '#' then begin
            if UpCompareSubStr('#EXTINF', vStr) = 0 then begin
              vTitle := ExtractWords(2, MaxInt, vStr, [',']);
              vLenSec := Str2IntDef(ExtractWord(2, vStr, [':', ',']), 0);
            end;
          end else
          begin
            if FileNameIsURL(vStr) then
              vTrack := vStr
            else
              vTrack := ExpandFileName(CombineFileName(vListPath, vStr));
            APlaylist.AddTrack(vTrack, vTitle, vLenSec);
            vTitle := '';
            vLenSec := 0;
          end;
        end;
      end;
    finally
      FreeObj(vList);
    end;
  end;


  function TTrackInfo.GetInfoAsStr :TString;
  begin
    if Title <> '' then begin
      if Artist <> '' then
        Result := Artist + ' - ' + Title
      else
        Result := cUnknownArtist + ' - ' + Title;
    end else
      Result := Artist
  end;


 {-----------------------------------------------------------------------------}
 { TPlaylist                                                                   }
 {-----------------------------------------------------------------------------}

  function TPlaylist.AddTrack(const AFileName, AInfoStr :TString; ALenSec :Integer) :Integer;
  var
    vInfo :TTrackInfo;
    vPos :Integer;
  begin
    vInfo := TTrackInfo.Create;
    if AInfoStr <> '' then begin
      vPos := Pos(' - ', AInfoStr);
      if vPos <> 0 then begin
        vInfo.Artist := Copy(AInfoStr, 1, vPos - 1);
        vInfo.Title  := Copy(AInfoStr, vPos + 3, MaxInt);
      end else
        vInfo.Artist := AInfoStr;
    end;
    vInfo.LenSec := ALenSec;
    Result := AddObject(AFileName, vInfo);
  end;


  function TPlaylist.GetTrackInfo(AIndex :Integer) :TTrackInfo;
  begin
    Result := Objects[AIndex] as TTrackInfo;
    if Result = nil then begin
      Result := TTrackInfo.Create;
      Objects[AIndex] := Result;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TPlaylistReview                                                             }
 {-----------------------------------------------------------------------------}

  function TPlaylistReview.GetMenuDidgest :TString;
  begin
    Result := FDidgest;
    if FTrackCount > 1 then
      Result := Format('%s, %d tracks', [Result, FTrackCount]);
  end;


 {-----------------------------------------------------------------------------}
 { TPlaylistHistory                                                            }
 {-----------------------------------------------------------------------------}

  procedure TPlaylistHistory.SetHistoryFolder(const AFolder :TString);
  begin
    FAppFolder := AFolder;
    FHistFolder := AddFileName(AFolder, cHistoryFolderName);
    if not WinFolderExists(FHistFolder) then
      CreateDir(FHistFolder);
  end;


  procedure TPlaylistHistory.ReadPlaylists;
  var
    I :Integer;
    vList :TStringList;
    vFileName, vStr, vCRCStr :TString;
    vPtr :PTChar;
    vReview :TPlaylistReview;
  begin
    vList := TStringList.Create;
    try
      vFileName := AddFileName(FAppFolder, cHistoryIndexName);
      if not WinFileExists(vFileName) then
        Exit;

      vList.LoadFromFile(vFileName);
      for I := 0  to vList.Count - 1 do begin
        vStr := vList[I];
        vPtr := PTChar(vStr);
        vCRCStr := ExtractNextWord(vPtr, [',']);

        vReview := TPlaylistReview.Create;
        vReview.FTrackCount := ExtractNextInt(vPtr, [',']);
        vReview.FCurTrack := ExtractNextInt(vPtr, [',']);
        vReview.FLastAccess := FileDateToDateTime(ExtractNextInt(vPtr, [',']));
        vReview.FDidgest := vPtr;
        vReview.FSaved := True;
        AddObject(vCRCStr, vReview);
      end;

    finally
      FreeObj(vList);
    end;
  end;


  procedure TPlaylistHistory.SavePlaylists;
  var
    I :Integer;
    vList :TStringList;
    vFileName :TString;
    vReview :TPlaylistReview;
  begin
    vList := TStringList.Create;
    try
      for I := 0 to Count - 1 do begin
        vReview := Objects[I] as TPlaylistReview;
        if vReview.FSaved then
          vList.Add(Format('%s,%d,%d,%d,%s',
            [Strings[I], vReview.FTrackCount, vReview.FCurTrack, DateTimeToFileDate(vReview.FLastAccess), vReview.FDidgest]));
      end;
      vFileName := AddFileName(FAppFolder, cHistoryIndexName);
      vList.SaveToFile(vFileName, sffAnsi);
    finally
      FreeObj(vList);
    end;
  end;


  procedure TPlaylistHistory.ClearHistory;
  begin
    CheckOverflow(0);
    SavePlaylists;
  end;


  procedure TPlaylistHistory.AddToHistory(APlaylist :TPlaylist; ACurTrack :Integer);
  var
    vCRC :TCRC;
    vStr :TString;
    vIndex :Integer;
    vReview :TPlaylistReview;
  begin
    if HistoryLength = 0 then begin
      ClearHistory;
      Exit;
    end;

    vCRC := CalcPlaylistCRC(APlaylist);
    vStr := CRC2Str(vCRC);

    vIndex := IndexOf(vStr);

    if vIndex = -1 then begin
      vReview := TPlaylistReview.Create;
      vReview.FDidgest := MakePlaylistDidgest(APlaylist);
      vReview.FCurTrack := ACurTrack;
      vReview.FTrackCount := APlaylist.Count;
      vReview.FLastAccess := Now;
      InsertObject(0, vStr, vReview);
    end else
    begin
      vReview := Objects[vIndex] as TPlaylistReview;
      vReview.FDidgest := MakePlaylistDidgest(APlaylist);
      vReview.FLastAccess := Now;
      Move(vIndex, 0);
    end;

    if not vReview.FSaved then begin
      vStr := AddFileName(FHistFolder, vStr + '.m3u');
      SavePlaylistM3U(APLaylist, vStr, True);
      vReview.FSaved := True;
    end;
    
    CheckOverflow(HistoryLength + 1);
  end;


  function TPlaylistHistory.SetCurrentPlaylist(AIndex :Integer; APlaylist :TPlaylist) :Integer;
  var
    vCRC :TCRC;
    vStr :TString;
    vIndex :Integer;
    vReview :TPlaylistReview;
  begin
    vCRC := CalcPlaylistCRC(APlaylist);
    vStr := CRC2Str(vCRC);

    if (AIndex >= 0) and (AIndex < Count) then begin
      { Playlist уже в истории, проверим не изменился ли он }
      vReview := Objects[AIndex] as TPlaylistReview;

      if vStr <> Strings[AIndex] then begin
        { Изменился, снимаем флаг FSaved }
        Strings[AIndex] := vStr;
        vReview.FTrackCount := APlaylist.Count;
        vReview.FLastAccess := Now;
        vReview.FSaved := False;
        {!!!Надо бы удалить...}
      end;

      { Дайджест мог измениться из-за извлечения новых тэгов }
      vReview.FDidgest := MakePlaylistDidgest(APlaylist);
      Result := AIndex;

    end else
    begin
      vIndex := IndexOf(vStr);

      if vIndex = -1 then begin
        { Добавляем текущий Playlist в историю, но не сохраняем его }
        vReview := TPlaylistReview.Create;
        vReview.FDidgest := MakePlaylistDidgest(APlaylist);
        vReview.FTrackCount := APlaylist.Count;
        vReview.FLastAccess := Now;
        InsertObject(0, vStr, vReview);
      end else
      begin
        { Переместим найденый Playlist в конец списка }
        vReview := Objects[vIndex] as TPlaylistReview;
        vReview.FDidgest := MakePlaylistDidgest(APlaylist);
        vReview.FLastAccess := Now;
        Move(vIndex, 0);
      end;

      Result := 0;

      CheckOverflow(HistoryLength + 1);
    end;
  end;


  function TPlaylistHistory.CalcPlaylistCRC(APlaylist :TPlaylist) :TCRC;
  var
    I :Integer;
  begin
    Result := 0;
    for I := 0 to APlaylist.Count - 1 do
      with PStringItem(APlaylist.PItems[I])^ do
        AddCRCStr(Result, FString);
  end;


  function TPlaylistHistory.MakePlaylistDidgest(APlaylist :TPlaylist) :TString;
  var
    I :Integer;
    vInfo :TString;
    vList :TStringList;
  begin
    if APlaylist.Count = 1 then begin
      with APlaylist.TrackInfo[0] do
        Result := GetInfoAsStr;
      if Result = '' then
        Result := ExtractFileNameEx(APlaylist[0]);
    end else
    begin
      vList := TStringList.Create;
      try
        for I := 0 to APlaylist.Count - 1 do begin
          with APlaylist.TrackInfo[I] do
            vInfo := Artist;
          if vInfo <> '' then begin
            if vList.IndexOf(vInfo)= -1 then
              vList.Add(vInfo);
            if vList.Count > 3 then
              Break;
          end;
        end;
        if vList.Count > 0 then begin
          Result := '';
          for I := 0 to IntMin(vList.Count, 3) - 1 do
            Result := AppendStrCh(Result, vList[I], ', ');
          if vList.Count > 3 then
            Result := AppendStrCh(Result, '...', ', ');
        end else
          Result := cUnknownArtist;
      finally
        FreeObj(vList);
      end;
    end;
  end;


  procedure TPlaylistHistory.CheckOverflow(ALimit :Integer);
  var
    vFileName :TString;
  begin
    while Count > ALimit do begin
      vFileName := GetPlaylistName(Count - 1);
      if WinFileExists(vFileName) then
        DeleteFile(vFileName);
      Delete(Count - 1);
    end;
  end;


  function TPlaylistHistory.GetPlaylistName(AIndex :Integer) :TString;
  begin
    Result := AddFileName(FHistFolder, Strings[AIndex] + '.m3u');
  end;


end.

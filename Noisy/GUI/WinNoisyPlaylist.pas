{$I Defines.inc}

unit WinNoisyPlaylist;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Player GUI control main module                                             *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    CommCtrl,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    MixWin,

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,
    WinNoisyCtrl;


  var
    PlaylistShowTitle :Boolean = True;


  type
    TTrackInfo = class(TBasis)
    private
//    FArtist   :TString;
      FTitle    :TString;
      FFileName :TString;
      FLength   :Integer;
    end;


    TPlaylistView = class(TListView)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure InitPlaylist;
      procedure PlayCurrent;

      procedure GetTrackIcon(var AItem :TLVItem);
      procedure GetCellText(var AItem :TLVItem);

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure ErrorHandler(E :Exception); override;

    private
      FIdleTimer  :THandle;

      FPlaylist   :TObjStrings;

      FPlaylistRevision :Integer;
      FPlayedTrackIndex :Integer;
      FPlayerState :TPlayerState;

      FPlaylistCheckedIndex :Integer;
      FPlaylistCheckedState :TPlayerState;

      procedure Idle;

      function PlaylistToDlgIndex(APlaylistIndex :Integer) :Integer;
      function GetPlaylistIndex :Integer;

      procedure UpdatePlaylist;
      function DetectPlaylistChange :Boolean;
      procedure UpdatePlayed(AIndex :Integer; AState :TPlayerState);
      function GetTrackInfo(AIndex :Integer) :TTrackInfo;
      procedure ReinitListControl;

      procedure WMNCDestroy(var Mess :TWMNCDestroy); message WM_NCDestroy;
      procedure WMTimer(var Mess :TWMTimer); message WM_Timer;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    WinNoisyMain,
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TPlaylistView                                                               }
 {-----------------------------------------------------------------------------}

  constructor TPlaylistView.Create; {override;}
  begin
    inherited Create;
    FPlaylist := TObjStrings.Create;
  end;


  destructor TPlaylistView.Destroy; {override;}
  begin
    FreeObj(FPlaylist);
    inherited Destroy;
  end;


  procedure TPlaylistView.InitPlaylist;
  begin
    FIdleTimer := SetTimer(FHandle, 1, 10, nil);
    UpdatePlaylist;
    ReinitListControl;
  end;


 {--------------------------------------}

  procedure TPlaylistView.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
  end;


(*
  procedure TPlaylistView.SetupControls;
  var
    vCol :TLVColumn;
  begin
    FListView := TListView.CreateEx(Self, 0, 0, 0, 100, 100,
      LVS_OWNERDATA or LVS_REPORT {or LVS_NOCOLUMNHEADER} or LVS_NOSORTHEADER or LVS_SHAREIMAGELISTS, '');

    ListView_SetExtendedListViewStyle(FListView.Handle,
      LVS_EX_FULLROWSELECT or
      LVS_EX_DOUBLEBUFFER or
//    LVS_EX_AUTOSIZECOLUMNS or
//    LVS_EX_ONECLICKACTIVATE or LVS_EX_UNDERLINEHOT
      {or LVS_EX_FLATSB or LVS_EX_GRIDLINES or LVS_EX_TRACKSELECT or LVS_EX_BORDERSELECT}
      0);

    ListView_SetImageList(FListView.Handle, MainForm.Images, LVSIL_SMALL);
    ListView_SetBkColor(FListView.Handle, cColor3);
    ListView_SetTextBkColor(FListView.Handle, cColor3);

    FillChar(vCol, SizeOf(vCol), 0);
    vCol.mask := LVCF_TEXT or LVCF_WIDTH;
    vCol.pszText := 'Name';
    vCol.cx := 300;
    ListView_InsertColumn(FListView.Handle, 0, vCol);

    vCol.mask := LVCF_TEXT or LVCF_WIDTH or LVCF_FMT;
    vCol.pszText := 'Length';
    vCol.fmt := LVCFMT_RIGHT;
    vCol.cx := 100;
    ListView_InsertColumn(FListView.Handle, 2, vCol);
  end;
*)

  procedure TPlaylistView.WMNCDestroy(var Mess :TWMNCDestroy); {message WM_NCDestroy;}
  begin
    KillTimer(FHandle, 1);
    inherited;
  end;


  procedure TPlaylistView.WMTimer(var Mess :TWMTimer); {message WM_Timer;}
  begin
    Idle;
  end;


 {-----------------------------------------------------------------------------}

  procedure TPlaylistView.ErrorHandler(E :Exception); {override;}
  begin
    MessageBox(0, PTChar(E.Message), 'Error', MB_OK or MB_ICONHAND);
  end;


 {-----------------------------------------------------------------------------}

  procedure TPlaylistView.UpdatePlaylist;
  var
    vInfo :TPlayerInfo;
  begin
    FPlaylist.Clear;
    if GetPlayerInfo(vInfo, False) and (vInfo.FTrackCount > 0) then begin
      FPlaylist.Text := GetPlaylist;
      FPlaylistRevision := vInfo.FPlaylistRev;
      FPlayedTrackIndex := vInfo.FTrackIndex;
      FPlayerState := vInfo.FState;
    end else
    begin
      FPlaylistRevision := 0;
      FPlayedTrackIndex := -1;
      FPlayerState := psEmpty;
    end;
  end;


  function TPlaylistView.GetTrackInfo(AIndex :Integer) :TTrackInfo;

    procedure LocPrepareTrackInfo;
    begin
      Result := TTrackInfo.Create;
      FPlaylist.Objects[AIndex] := Result;
      with PStringItem(FPlaylist.PItems[AIndex])^ do begin
        Result.FFileName := ExtractWord(1, FString, ['|']);
        Result.FTitle := ExtractWord(3, FString, ['|']);
        if Result.FTitle = '' then
          Result.FTitle := ExtractFileNameEx(Result.FFileName);
        Result.FLength := Str2IntDef(ExtractWord(2, FSTring, ['|']), 0);
      end;
    end;

  begin
    Result := TTrackInfo(FPlaylist.Objects[AIndex]);
    if Result = nil then
      LocPrepareTrackInfo;
  end;


  function TPlaylistView.DetectPlaylistChange :Boolean;
  var
    vInfo :TPlayerInfo;
    vNewRevision :Integer;
  begin
    vNewRevision := 0;
    FPlayedTrackIndex := -1;
    if GetPlayerInfo(vInfo, False) then begin
      vNewRevision := vInfo.FPlaylistRev;
      FPlayedTrackIndex := vInfo.FTrackIndex;
      FPlayerState := vInfo.FState;
    end;
    Result := FPlaylistRevision <> vNewRevision;
  end;


  function TPlaylistView.PlaylistToDlgIndex(APlaylistIndex :Integer) :Integer;
(*var
    I :Integer;
  begin
    if vFilterList = nil then
      Result := APlaylistIndex
    else begin
      Result := -1;
      for I := 0 to vFilterList.Count - 1 do
        if Integer(vFilterList[I]) = APlaylistIndex then begin
          Result := I;
          Exit;
        end;
    end; *)
  begin
    Result := APlaylistIndex;
  end;


  procedure TPlaylistView.UpdatePlayed(AIndex :Integer; AState :TPlayerState);
  begin
    if (AIndex <> FPlaylistCheckedIndex) or (AState <> FPlaylistCheckedState) then begin
      if FPlaylistCheckedIndex <> -1 then
        ListView_RedrawItems(FHandle, FPlaylistCheckedIndex, FPlaylistCheckedIndex);

      FPlaylistCheckedIndex := AIndex;
      FPlaylistCheckedState := AState;

      if FPlaylistCheckedIndex <> -1 then
        ListView_RedrawItems(FHandle, FPlaylistCheckedIndex, FPlaylistCheckedIndex);
    end;
  end;


  procedure TPlaylistView.GetTrackIcon(var AItem :TLVItem);
  var
    vIndex :Integer;
  begin
    vIndex := AItem.iItem;
    if (vIndex < 0) or (vIndex >= FPlaylist.Count) then
      Exit;

    AItem.iImage := -1;
    if vIndex = FPlaylistCheckedIndex then begin
      AItem.iImage := 0;
      if FPlaylistCheckedState = psPaused then
        AItem.iImage := 1;
      if FPlaylistCheckedState = psStopped then
        AItem.iImage := 2;
    end;
  end;


  procedure TPlaylistView.GetCellText(var AItem :TLVItem);
  var
    vIndex :Integer;
    vInfo :TTrackInfo;
  begin
    vIndex := AItem.iItem;
    if (vIndex < 0) or (vIndex >= FPlaylist.Count) then
      Exit;

    vInfo := GetTrackInfo(vIndex);
    if AItem.iSubItem = 0 then
      StrPLCopy(AItem.pszText, vInfo.FTitle, AItem.cchTextMax)
    else
      StrPLCopy(AItem.pszText, Time2Str(vInfo.FLength), AItem.cchTextMax);
  end;



  procedure TPlaylistView.ReinitListControl;
  begin
    {!!!}

    if ListView_GetItemCount(FHandle) <> FPlaylist.Count then
      ListView_SetItemCount(FHandle, FPlaylist.Count)
    else
      ListView_RedrawItems(FHandle, 0, FPlaylist.Count);

    FPlaylistCheckedIndex := -1;
    UpdatePlayed(PlaylistToDlgIndex(FPlayedTrackIndex), FPlayerState);
  end;


  procedure TPlaylistView.Idle;
  begin
    if DetectPlaylistChange then begin
      UpdatePlaylist;
      ReinitListControl;
    end else
      UpdatePlayed(PlaylistToDlgIndex(FPlayedTrackIndex), FPlayerState);
  end;


 {-----------------------------------------------------------------------------}

  function TPlaylistView.GetPlaylistIndex :Integer;
  begin
    Result := ListView_GetNextItem(FHandle, -1, LVNI_FOCUSED);
//  Result := DlgToPlaylistIndex( Result );
  end;


  procedure TPlaylistView.PlayCurrent;
  var
    vIndex :Integer;
  begin
    vIndex := GetPlaylistIndex;
    ExecCommandFmt(CmdSafe + ' ' + CmdGoto1, [vIndex + 1]);
    DetectPlaylistChange;
    UpdatePlayed(PlaylistToDlgIndex(FPlayedTrackIndex), FPlayerState);
  end;



end.

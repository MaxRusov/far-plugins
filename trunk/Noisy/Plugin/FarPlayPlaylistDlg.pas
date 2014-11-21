{$I Defines.inc}
{$Typedaddress Off}

unit FarPlayPlaylistDlg;

{******************************************************************************}
{* Noisy - Noisy Player Far plugin                                            *}
{* 2008-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,

    Far_API,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,
    FarListDlg,
    
    FarPlayCtrl,
    FarPlayReg;


  var
    vPlaylistLock :Integer;


  procedure OpenPlaylist;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TPlaylistDlg                                                                }
 {-----------------------------------------------------------------------------}

  type
    TPlaylistDlg = class(TFilteredListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;

      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FPlaylist :TStringList;
      FPlaylistRevision :Integer;
      FPlayedTrackIndex :Integer;
      FPlayerState :TPlayerState;
      FPlaylistCheckedIndex :Integer;
      FPlaylistCheckedState :TPlayerState;

      procedure UpdatePlaylist;
      function DetectPlaylistChange :Boolean;
      procedure UpdatePlayed(AIndex :Integer; AState :TPlayerState; ARedraw :Boolean);
      procedure PlayCurrent;
      function FormatTitle(const AStr :TString) :TString;
      function FormatTime(const AStr :TString) :TString;
    end;



  constructor TPlaylistDlg.Create; {override;}
  begin
    inherited Create;
//  RegisterHints(Self);
    FPlaylist := TStringList.Create;
  end;


  destructor TPlaylistDlg.Destroy; {override;}
  begin
    FreeObj(FPlaylist);
    inherited Destroy;
  end;


  procedure TPlaylistDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FGUID := cPlaylistDlgID;
    FHelpTopic := 'Playlist';
//  FGrid.Options := FGrid.Options + [goRowSelect];
  end;


  procedure TPlaylistDlg.InitDialog; {override;}
  begin
    UpdatePlaylist;
    inherited InitDialog;
    SetCurrent(IdxToRow(FPlayedTrackIndex), lmSafe);
  end;


  procedure TPlaylistDlg.UpdatePlaylist;
  var
    vInfo :TPlayerInfo;
  begin
    if GetPlayerInfo(vInfo, False) and (vInfo.FTrackCount > 0) then begin
      FPlaylist.Text := GetPlaylist;
      FPlaylistRevision := vInfo.FPlaylistRev;
      FPlayedTrackIndex := vInfo.FTrackIndex;
      FPlayerState := vInfo.FState;
    end else
    begin
      FPlaylist.Clear;
      FPlaylistRevision := 0;
      FPlayedTrackIndex := -1;
      FPlayerState := psEmpty;
    end;
  end;


  function TPlaylistDlg.DetectPlaylistChange :Boolean;
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


  procedure TPlaylistDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strPlaylistTitle);

    if FFilter = nil then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount]);

    SetText(IdFrame, vTitle);

    if length(vTitle) + 4 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle) + 4;
  end;


  procedure TPlaylistDlg.ReinitGrid; {override;}
  var
    I, vPos, vFndLen, vCount, vMaxLen :Integer;
    vStr, vMask, vXMask :TString;
    vHasMask :Boolean;
  begin
    FTotalCount := FPlaylist.Count;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    vCount := 0;
    FreeObj(FFilter);
    if vMask <> '' then begin
      FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
      FFilter.Owner := Self;
      if True{optXLatMask} then
        vXMask := FarXLatStr(vMask);
    end;

    vMaxLen := 0;
    for I := 0 to FPlaylist.Count - 1 do begin
      vStr := FormatTitle(FPlaylist[I]);

      vPos := 0; vFndLen := 0;
      if FFilter <> nil then begin
        if vMask <> '' then
          if not ChrCheckXMask(vMask, vXMask, PTChar(vStr), vHasMask, vPos, vFndLen) then
            Continue;
        FFilter.Add(I, vPos, vFndLen);
      end;

      vMaxLen := IntMax(vMaxLen, Length(vStr));
      Inc(vCount);
    end;

    FGrid.RowCount := vCount;
    FGrid.ResetSize;
    FGrid.Columns.Clear;
    if PlaylistShowNumber then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', '', Length(Int2Str(vCount)) + 2, -1,  taRightJustify, [coColMargin], 1) );
    if True then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', '', vMaxLen + 2, 10, taLeftJustify, [coColMargin, coOwnerDraw], 2) );
    if PlaylistShowTime then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', '', 7, -1, taLeftJustify, [coColMargin], 3) );

    FGrid.ReduceColumns(FarGetWindowSize.CX - (10 + IntIf(True{optShowGrid}, FGrid.Columns.Count, 1) + FGrid.Margins.Left + FGrid.Margins.Right));

    FMenuMaxWidth := 0;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then begin
//        if optShowTitles and (Abs(PluginSortMode) = Tag) then
//          Header := StrIf(PluginSortMode > 0, chrUpMark, chrDnMark) + Header;
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
        end;
    if True {optShowGrid} then
      Dec(FMenuMaxWidth);
    Inc(FMenuMaxWidth, FGrid.Margins.Left + FGrid.Margins.Right);


    FPlaylistCheckedIndex := -1;
    UpdateHeader;
    ResizeDialog;
  end;


  procedure TPlaylistDlg.ReinitAndSaveCurrent; {override;}
  var
    vIdx :Integer;
  begin
    vIdx := RowToIdx(FGrid.CurRow);
    ReinitGrid;
    SetCurrent(IdxToRow(vIdx), lmCenter);
  end;


  procedure TPlaylistDlg.UpdatePlayed(AIndex :Integer; AState :TPlayerState; ARedraw :Boolean);
  begin
    if (AIndex <> FPlaylistCheckedIndex) or (AState <> FPlaylistCheckedState) then begin
//    Trace('UpdatePlayed...');
      FPlaylistCheckedIndex := AIndex;
      FPlaylistCheckedState := AState;
      if ARedraw then
        FARAPI.SendDlgMessage(FHandle, DM_REDRAW, 0, nil);
    end;
  end;


  function TPlaylistDlg.FormatTitle(const AStr :TString) :TString;
  begin
    Result := '';
    if PlaylistShowTitle then
      Result := ExtractWord(3, AStr, ['|']);
    if Result = '' then begin
      Result := ExtractWord(1, AStr, ['|']);
      Result := ExtractFileNameEx(Result);
    end;
  end;


  function TPlaylistDlg.FormatTime(const AStr :TString) :TString;
  var
    vTime :Integer;
  begin
    vTime := Str2IntDef(ExtractWord(2, AStr, ['|']), 0);
    Result := Time2Str(vTime);
  end;


  function TPlaylistDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vIdx :Integer;
  begin
    vIdx := RowToIdx(ARow);
    case FGrid.Column[ACol].Tag of
      1: Result := Int2Str(ARow + 1);
      2: Result := FormatTitle(FPlaylist[vIdx]);
      3: Result := FormatTime(FPlaylist[vIdx]);
    end;
  end;


  procedure TPlaylistDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  const
    cStatesMarks :array[TPlayerState] of TString =
      ('', chrPlay, chrPause, chrStop);
  var
    vStr :TString;
    vRec :PFilterRec;
    vIdx :Integer;
  begin
    vIdx := RowToIdx(ARow);
    vStr := FormatTitle(FPlaylist[vIdx]);

    vRec := nil;
    if FFilter <> nil then
      vRec := FFilter.PItems[ARow];

    if vRec <> nil then
      FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(AColor, optFoundColor))
    else
      FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);

    if (vIdx = FPlaylistCheckedIndex) and (FPlaylistCheckedState <> psEmpty) then
      FGrid.DrawChr(X-1, Y, PTChar(cStatesMarks[FPlaylistCheckedState]), 1, AColor);
  end;


  procedure TPlaylistDlg.PlayCurrent;
  var
    vIndex :Integer;
  begin
    vIndex := RowToIdx(FGrid.CurRow);
    ExecCommandFmt(CmdGoto1, [vIndex + 1]);
    DetectPlaylistChange;
    UpdatePlayed(vIndex, FPlayerState, True);
  end;


  procedure TPlaylistDlg.SelectItem(ACode :Integer); {override;}
  begin
    PlayCurrent;
    if ACode = 2 then
      SendMsg(DM_CLOSE, -1, 0);
  end;


  function TPlaylistDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure DeleteCurrent;
    var
      vIndex :Integer;
    begin
      vIndex := RowToIdx(FGrid.CurRow);
      if (vIndex >= 0) and (vIndex < FPlaylist.Count) then begin
        ExecCommandFmt(CmdDelete1, [vIndex + 1]);
        FPlaylist.Delete(vIndex);
        FPlayedTrackIndex := -1;
        ReinitAndSaveCurrent;
      end;
    end;

    procedure MoveCurrent(ADelta :Integer);
    var
      vIndex, vNewIndex :Integer;
    begin
      vIndex := RowToIdx(FGrid.CurRow);
      vNewIndex := vIndex + ADelta;
      if (vIndex >= 0) and (vIndex < FPlaylist.Count) and (vNewIndex >= 0) and (vNewIndex < FPlaylist.Count) then begin
        ExecCommandFmt(CmdMoveTrack1, [vIndex + 1, vNewIndex + 1]);
        FPlaylist.Move(vIndex, vNewIndex);
        FPlayedTrackIndex := -1;
        ReInitGrid;
        SetCurrent(IdxToRow(vNewIndex));
      end;
    end;

  begin
    Result := True;
    case AKey of
      KEY_ENTER, KEY_SHIFTENTER:
        begin
          PlayCurrent;
          if AKey = KEY_ENTER then
            SendMsg(DM_CLOSE, -1, 0);
        end;

      KEY_SHIFTHOME:
        SetCurrent(IdxToRow(FPlayedTrackIndex), lmSafe);

      KEY_CTRL1:
        begin
          PlaylistShowNumber := not PlaylistShowNumber;
          ReinitAndSaveCurrent;
        end;
      KEY_CTRL2:
        begin
          PlaylistShowTitle := not PlaylistShowTitle;
          ReinitAndSaveCurrent;
        end;
      KEY_CTRL3:
        begin
          PlaylistShowTime := not PlaylistShowTime;
          ReinitAndSaveCurrent;
        end;

      KEY_CTRLDEL:
        DeleteCurrent;
      KEY_CTRLUP:
        MoveCurrent(-1);
      KEY_CTRLDOWN:
        MoveCurrent(+1);

      KEY_CTRLR:
        begin
          UpdatePlaylist;
          ReinitGrid;
          SetCurrent(IdxToRow(FPlayedTrackIndex), lmCenter);
        end;

    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TPlaylistDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_EnterIdle:
        if DetectPlaylistChange then begin
          UpdatePlaylist;
          ReinitGrid;
        end else
          UpdatePlayed(FPlayedTrackIndex, FPlayerState, True);

      DN_RESIZECONSOLE:
        ReinitAndSaveCurrent;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure OpenPlaylist;
  var
    vInfo :TPlayerInfo;
    vDlg :TPlaylistDlg;
  begin
    if vPlaylistLock > 0 then
      Exit;

    ExecCommand(CmdInfo);
    if not GetPlayerInfo(vInfo, False) then
      AppErrorID(strPlayerNotRunning);

    Inc(vPlaylistLock);
    vDlg := TPlaylistDlg.Create;
    try
      LockPlayer;
      try
        vDlg.Run;
      finally
        UnlockPlayer;
      end;

    finally
      vDlg.Destroy;
      Dec(vPlaylistLock);
    end;

  end;
  

end.


{$I Defines.inc}

unit FarPlayInfoDlg;

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

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,

    Far_API,
    FarCtrl,
    FarMenu,
    FarDlg,
    FarPlayCtrl,
    FarPlayReg,
    FarPlayPlaylistDlg;


  procedure OpenAboutDialog; 
  procedure OpenInfoDialog;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;

 {-----------------------------------------------------------------------------}

  var
    BassVersion :Cardinal;


  function Ver2Str(AVersion :Cardinal) :TString;
  begin
    Result := Format('%d.%d.%d.%d',
      [HIBYTE(HIWORD(AVersion)),LOBYTE(HIWORD(AVersion)),HIBYTE(LOWORD(AVersion)),LOBYTE(LOWORD(AVersion))]);
  end;


  function GetModuleName(Module :THandle) :TString;
  var
    ModName: array[0..MAX_PATH] of TChar;
  begin
    SetString(Result, ModName, GetModuleFileName(Module, ModName, High(ModName)+1));
  end;


  function GetVersionNumber :TString;
  var
    FName   :TString;
    Buf     :TString;
    Str     :Pointer;
    VerSize :DWORD;
    Temp    :DWORD;
  begin
    Result := '';
    FName := GetModuleName(HInstance);
    VerSize := GetFileVersionInfoSize( PTChar(FName), Temp);
    if VerSize > 0 then begin
      SetLength(Buf, VerSize);
      GetFileVersionInfo( PTChar(FName), Temp, VerSize, PTChar(Buf));
      if VerQueryValue(PTChar(Buf), '\StringFileInfo\041904E3\FileVersion', Str, VerSize) then
        Result := PTChar(Str);
    end;
  end;


  procedure OpenFormatsDialog;
  var
    I, vRes :Integer;
    vStr :TString;
  begin
    vStr :=
      #10 + GetMsgStr(strSupportedFormats) + #10;

    if FFormats.Count > 0 then begin
      for I := 0 to FFormats.Count - 1 do begin
        with TBassFormat(FFormats[I]) do
          vStr := vStr + #10 + '  ' + Name + ' (' + Exts + ')';
      end;
    end;

    vRes := ShowMessageBut(GetMsgStr(strInfoTitle), vStr, [GetMsgStr(strOk), GetMsgStr(strVersions)]);

    if vRes = 1 then
      OpenAboutDialog;
  end;


  procedure OpenAboutDialog;
  var
    I, vRes :Integer;
    vStr :TString;
    vInfo :TPlayerInfo;
  begin
    ExecCommand(CmdInfo);
    if GetPlayerInfo(vInfo, True) then begin
      BassVersion := vInfo.FBassVersion;
    end else
      AppErrorID(strPlayerNotRunning);

    vStr :=
      #10'Noisy Far plugin' {$ifdef bUnicode} + ' (unicode)' {$endif bUnicode} + #10 +
      'ver ' + GetVersionNumber + #10 +
      '(c) 2008, Max Rusov'#10 +
      #10 +
      'BASS Audio Library'#10 +
      'ver ' + Ver2Str(BassVersion) + #10 +
      '(c) 1999-2008 Un4seen Developments Ltd.'#10+
      'http://www.un4seen.com'#10;

    if FPlugins.Count > 0 then begin
      vStr := vStr + #10 +
        GetMsgStr(strLoadedPlugins);
      for I := 0 to FPlugins.Count - 1 do begin
        with TBassPlugin(FPlugins[I]) do
          vStr := vStr + #10 + '  ' + Name + ', ver ' + Ver2Str(Version);
      end;
    end;

    vRes := ShowMessageBut(GetMsgStr(strInfoTitle), vStr, [GetMsgStr(strOk), GetMsgStr(strFormats)]);

    if vRes = 1 then
      OpenFormatsDialog;
  end;


 {-----------------------------------------------------------------------------}

  procedure OpenConfig;
  var
    vMenu :TFarMenu;
    vInfo :TPlayerInfo;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strConfigTitle),
    [
      GetMsg(strRepeatMode),
      GetMsg(strSuffleMode),
      '',
      GetMsg(strShowIcon),
      GetMsg(strShowTooltips),
      GetMsg(strUseHotkeys)
    ]
    );
    try
      while True do begin
        ExecCommand(cmdInfo);
        if GetPlayerInfo(vInfo, False) then begin
          vMenu.Checked[0] := vInfo.FRepeat;
          vMenu.Checked[1] := vInfo.FShuffle;
          vMenu.Checked[3] := vInfo.FSystray;
          vMenu.Checked[4] := vInfo.FTooltips;
          vMenu.Checked[5] := vInfo.FHotkeys;
        end;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0: ExecCommand(CmdRepeat);
          1: ExecCommand(CmdShuffle);

          3: ExecCommand(CmdSystray);
          4: ExecCommand(CmdTooltip);
          5: ExecCommand(CmdHotkeys);
        else
          Break;
        end;
      end;  

    finally
      vMenu.Destroy;
    end;
  end;



 {-----------------------------------------------------------------------------}
 { TPlayerDlg                                                                  }
 {-----------------------------------------------------------------------------}

  type
    TPlayerDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;

//    function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      procedure UpdateStatus;
    end;



  const
    IdTitle = 1;
    IdInfo  = 2;
    IdTime1 = 4;
    IdTime2 = 5;
    IdProgress = 6;

    IdTracksLab = 7;
    IdTracks = 8;
    IdPrev = 9;
    IdNext = 10;
    IdList = 11;

    IdVolLab = 12;
    IdVol = 13;
    IdVolDn = 14;
    IdVolUp = 15;
    IdVolMute = 16;

    IdPlay = 18;
    IdStop = 19;
    IdConfig = 20;
    IdAbout = 21;

    DX = 60;
    DY = 14;
    
    ProgressLen = DX-10;


  procedure TPlayerDlg.Prepare; {override;}
  const
    p1 = 5;
    p2 = 40;
  begin
    FGUID := cPlayerDlgID;
    FHelpTopic := 'Info';

    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3, 1, DX-6, DY-2, 0, GetMsg(strTitle)),

        NewItemApi(DI_Text, 5, 2, DX-10,  -1, 0, '' {Title} ),
        NewItemApi(DI_Text, 5, 3, DX-10,  -1, 0, '' {MP3, 128 kbps} ),
        NewItemApi(DI_Text, 0, 4, -1, -1,  DIF_SEPARATOR, ''),

        NewItemApi(DI_Text, 5, 5, 5, -1,      0, '' {01:00} ),
        NewItemApi(DI_Text, DX-10, 5, 5, -1,  0, '' {01:00} ),
        NewItemApi(DI_Text, 5, 6, DX-10, -1,  0, ''),

        NewItemApi(DI_Text, p1, 8, 9, -1,     0, GetMsg(strTrack)),
        NewItemApi(DI_Text, p1, 9, 9, -1,     0{DIF_CENTERTEXT}, '' {9999/9999}),

        NewItemApi(DI_Button, p1+10, 9, 3, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, '[&<]'),
        NewItemApi(DI_Button, p1+14, 9, 3, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, '[&>]'),
        NewItemApi(DI_Button, p1+18, 9, 8, -1, DIF_BTNNOCLOSE {or DIF_NOBRACKETS}, GetMsg(strList) {'[&List]'} ),

        NewItemApi(DI_Text, p2-1, 8, 11, -1,  0, GetMsg(strVolume) ),
        NewItemApi(DI_Text, p2,   9, 3,  -1,  0, '100'),

        NewItemApi(DI_Button, p2+4,  9, 3, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, '[&-]'),
        NewItemApi(DI_Button, p2+8,  9, 3, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, '[&+]'),
        NewItemApi(DI_Button, p2+12, 9, 3, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, '[&M]'),

        NewItemApi(DI_Text, 0, DY-4, -1, -1, DIF_SEPARATOR, ''),

        NewItemApi(DI_Button, 0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strPlay)),
        NewItemApi(DI_Button, 0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strStop)),
        NewItemApi(DI_Button, 0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strConfig)),
        NewItemApi(DI_Button, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strAbout))
      ],
      @FItemCount
    );
  end;


  procedure TPlayerDlg.InitDialog; {override;}
  begin
//  SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    UpdateStatus;
  end;


  procedure TPlayerDlg.UpdateStatus;
  var
    vInfo :TPlayerInfo;
    vFormat :TBassFormat;
    vName, vStr :TString;
    vPerc, vLen :Integer;
  begin
    if GetPlayerInfo(vInfo, False) then begin

      vName := vInfo.FTrackArtist;
      vStr := vInfo.FTrackTitle;
      if (vName <> '') and (vStr <> '') then
        vName := vName + ' - ' + vStr;
      if vName = '' then
        vName := ExtractFileNameEx(vInfo.FPlayedFile);

      if vName <> '' then
        SetText(IdTitle, vName)
      else
        SetText(IdTitle, GetMsg(strPLaylistIsEmpty));

      if vInfo.FTrackType <> 0 then begin
        vStr := NameOfCType(vInfo.FTrackType);
        if vStr = '' then begin
          vFormat := GetFormatByCode(vInfo.FTrackType);
          if vFormat <> nil then
            vStr := vFormat.GetShortName;
          if vStr = '' then
            vStr := Format('F%x', [vInfo.FTrackType]);
        end;

        if vInfo.FStreamType = stShoutcast then
          SetText(IdInfo, Format(' %s, shothcast, %s', [vStr, NameOfChans(vInfo.FTrackChans)] ))
        else
          SetText(IdInfo, Format(' %s, %d kbps, %s', [vStr, vInfo.FTrackBPS, {vInfo.FTrackFreq,} NameOfChans(vInfo.FTrackChans)] ));
        SetText(IdTime1, Time2Str(vInfo.FPlayTime));
        SetText(IdTime2, Time2Str(vInfo.FTrackLength));
      end else
      begin
        SetText(IdInfo, '');
        SetText(IdTime1, '');
        SetText(IdTime2, '');
      end;

      vPerc := 0;
      if vInfo.FTrackLength > 0 then
        vPerc := Round(vInfo.FPlayTime / vInfo.FTrackLength * 100);
      vStr := GetProgressStr(ProgressLen, vPerc);

      if (vInfo.FStreamType = stStream) and (vInfo.FTrackLoaded < vInfo.FTrackBytes) then begin
        vLen := Round(vInfo.FTrackLoaded / vInfo.FTrackBytes * ProgressLen);
        vStr := Copy(vStr, 1, vLen);
      end;

      SetText(IdProgress, vStr);

      if vInfo.FTrackCount = 0 then
        vStr := GetMsgStr(strEmpty)
      else begin
        vStr := Format('%d / %d', [vInfo.FTrackIndex + 1, vInfo.FTrackCount]);
        if Length(vStr) > 9 then
          vStr := Format('%d/%d', [vInfo.FTrackIndex + 1, vInfo.FTrackCount]);
      end;
      SetText(IdTracks, vStr);

      SetText(IdVol, Format('%3d', [Round(vInfo.FVolume)]));

      if vInfo.FState <> psPlayed then
        SetText(IdPlay, GetMsg(strPlay) )
      else
        SetText(IdPlay, GetMsg(strPause) );

    end else
    begin
      SetText(IdTitle, GetMsg(strPlayerNotRunning));
      SetText(IdInfo, '');
      SetText(IdTime1, '');
      SetText(IdTime2, '');
      SetText(IdProgress, GetProgressStr(ProgressLen, 0));
      SetText(IdTracks, GetMsg(strEmpty));
      SetText(IdVol, '--');
      SetText(IdPlay, GetMsg(strPlay) )
    end;

//  FARAPI.SendDlgMessage(hDlg, DM_ENABLE, IdPrev, Byte(vInfo.FTrackIndex > 0));
//  FARAPI.SendDlgMessage(hDlg, DM_ENABLE, IdNext, Byte(vInfo.FTrackIndex < vInfo.FTrackCount - 1));
  end;


//function TPlayerDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
//begin
//  Result := True;
//  case AKey of
//    0: {};
//  else
//    Result := inherited KeyDown(AID, AKey);
//  end;
//end;


  function TPlayerDlg.MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; {override;}
  var
    vPos, vSeekTo :Integer;
    vInfo :TPlayerInfo;
  begin
    Result := False;
    if AID = IdProgress then begin
      vPos := AMouse.dwMousePosition.X - GetScreenItemRect(IdProgress).Left;
      if GetPlayerInfo(vInfo, False) then begin
        vSeekTo := Round(vInfo.FTrackLength * vPos / ProgressLen);
        ExecCommandFmt(CmdSeek1, [vSeekTo]);
        UpdateStatus;
      end;
    end;
  end;


  function TPlayerDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK : begin
        case Param1 of
          IdPrev:
            ExecCommand(CmdPrev);
          IdNext:
            ExecCommand(CmdNext);

          IdVolDn:
            ExecCommand(CmdVolumeDec);
          IdVolUp:
            ExecCommand(CmdVolumeInc);
          IdVolMute:
            ExecCommand(CmdVolumeMute);

          IdPlay:
            ExecCommand(CmdPlayPause);
          IdStop:
            ExecCommand(CmdStop);
          IdList:
            OpenPlaylist;
          IdConfig:
            OpenConfig;
          IdAbout:
            OpenAboutDialog;
        end;
        UpdateStatus;
      end;

      DN_EnterIdle:
        UpdateStatus;
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    vLock :Integer;


  procedure OpenInfoDialog;
  var
    vDlg :TPlayerDlg;
    vInfo :TPlayerInfo;
  begin
    if (vLock > 0) or (vPlaylistLock > 0) then
      Exit;

    ExecCommand(CmdInfo);
    if not GetPlayerInfo(vInfo, True) then
      AppErrorID(strPlayerNotRunning);

    Inc(vLock);
    vDlg := TPlayerDlg.Create;
    try

      LockPlayer;
      try
        vDlg.Run;
      finally
        UnlockPlayer;
      end;

    finally
      vDlg.Destroy;
      Dec(vLock);
    end;
  end;


end.

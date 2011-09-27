{$I Defines.inc}
{$Typedaddress Off}

unit FarPlayInfoDlg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,

    FarCtrl,
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

    vStr :=
      GetMsgStr(strInfoTitle) + #10 +
      vStr + #10#10 +
      GetMsgStr(strOk) + #10 +
      GetMsgStr(strVersions);

    vStr := StrAnsiToOEM(vStr);
    vRes := FARAPI.Message(hModule, FMSG_LEFTALIGN or FMSG_ALLINONE, nil, PPCharArray(PFarChar(vStr)), 0, 2);

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

    vStr :=
      GetMsgStr(strInfoTitle) + #10 +
      vStr + #10#10 +
      GetMsgStr(strOk) + #10 +
      GetMsgStr(strFormats);

    vStr := StrAnsiToOEM(vStr);
    vRes := FARAPI.Message(hModule, FMSG_LEFTALIGN or FMSG_ALLINONE, nil, PPCharArray(PFarChar(vStr)), 0, 2);

    if vRes = 1 then
      OpenFormatsDialog;
  end;


 {-----------------------------------------------------------------------------}


  const
    cConfigMenuCount = 6;

  procedure OpenConfig;
  var
    vRes, I :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
    vInfo :TPlayerInfo;
  begin
    vItems := MemAllocZero(cConfigMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strRepeatMode), 0);
      SetMenuItemChrEx(vItem, GetMsg(strSuffleMode), 0);
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strShowIcon), 0);
      SetMenuItemChrEx(vItem, GetMsg(strShowTooltips), 0);
      SetMenuItemChrEx(vItem, GetMsg(strUseHotkeys), 0);

      vRes := 0;
      while True do begin
        ExecCommand(cmdInfo);
        if GetPlayerInfo(vInfo, False) then begin
          vItems[0].Flags := SetFlag(0, MIF_CHECKED1, vInfo.FRepeat);
          vItems[1].Flags := SetFlag(0, MIF_CHECKED1, vInfo.FShuffle);
          vItems[3].Flags := SetFlag(0, MIF_CHECKED1, vInfo.FSystray);
          vItems[4].Flags := SetFlag(0, MIF_CHECKED1, vInfo.FTooltips);
          vItems[5].Flags := SetFlag(0, MIF_CHECKED1, vInfo.FHotkeys);
        end;

        for I := 0 to cConfigMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strConfigTitle),
          '',
          'Config',
          nil, nil,
          Pointer(vItems),
          cConfigMenuCount);

        case vRes of
          0: ExecCommand(CmdRepeat);
          1: ExecCommand(CmdShuffle);
          2: {};
          3: ExecCommand(CmdSystray);
          4: ExecCommand(CmdTooltip);
          5: ExecCommand(CmdHotkeys);
        else
          Break;
        end;
      end;  

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure DlgScreenToClient(hDlg :THandle; AItemID :Integer; var APos :COORD);
  var
    vRect :SMALL_RECT;
  begin
    FARAPI.SendDlgMessage(hDlg, DM_GETDLGRECT, 0, Integer(@vRect));
    Dec(APos.X, vRect.Left);
    Dec(APos.Y, vRect.Top);
    FARAPI.SendDlgMessage(hDlg, DM_GETITEMPOSITION, AItemID, Integer(@vRect));
    Dec(APos.X, vRect.Left);
    Dec(APos.Y, vRect.Top);
  end;


  const
    cDlgItemsCount = 22;

    DX = 60;
    DY = 14;

    p1 = 5;
    p2 = 40;

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

    ProgressLen = DX-10;


  function GetInfoDlg :PFarDialogItemArray;
  begin
    Result := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3, 1, DX-6, DY-2, 0, GetMsg(strTitle)),

        NewItemApi(DI_Text, 5, 2, DX-10,  -1, 0, '' {Title} ),
        NewItemApi(DI_Text, 5, 3, DX-10,  -1, 0, '' {MP3, 128 kbps} ),
        NewItemApi(DI_Text, 0, 4, -1, -1,  DIF_SEPARATOR, ''),

        NewItemApi(DI_Text, 5, 5, 5, -1,      0, '' {01:00} ),
        NewItemApi(DI_Text, DX-10, 5, 5, -1,  0, '' {01:00} ),
        NewItemApi(DI_Text, 5, 6, DX-10, -1,  0, ''),

        NewItemApi(DI_Text, p1, 8, 9, -1,     0, GetMsg(strTrack)),
        NewItemApi(DI_Text, p1, 9, 9, -1,     DIF_CENTERTEXT, '' {9999/9999}),

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
      ]
    );
  end;


  function InfoDialogProc(hDlg : THandle; Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; stdcall;

    procedure DlgSetTextApi(AItemID :Integer; const AStr :TString);
    var
      vData :TFarDialogItemData;
    begin
      vData.PtrLength := Length(AStr);
      vData.PtrData := PFarChar(AStr);
      FARAPI.SendDlgMessage(hDlg, DM_SETTEXT, AItemID, Integer(@vData));
    end;

    procedure DlgSetText(AItemID :Integer; const AStr :TString);
    begin
      DlgSetTextApi( AItemID, StrAnsiToOEM(AStr) );
    end;


    procedure LocUpdateStatus;
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
          DlgSetText(IdTitle, vName)
        else
          DlgSetTextApi(IdTitle, GetMsg(strPLaylistIsEmpty));

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
            DlgSetText(IdInfo, Format(' %s, shothcast, %s', [vStr, NameOfChans(vInfo.FTrackChans)] ))
          else
            DlgSetText(IdInfo, Format(' %s, %d kbps, %s', [vStr, vInfo.FTrackBPS, {vInfo.FTrackFreq,} NameOfChans(vInfo.FTrackChans)] ));
          DlgSetText(IdTime1, Time2Str(vInfo.FPlayTime));
          DlgSetText(IdTime2, Time2Str(vInfo.FTrackLength));
        end else
        begin
          DlgSetText(IdInfo, '');
          DlgSetText(IdTime1, '');
          DlgSetText(IdTime2, '');
        end;

        vPerc := 0;
        if vInfo.FTrackLength > 0 then
          vPerc := Round(vInfo.FPlayTime / vInfo.FTrackLength * 100);
        vStr := GetProgressStr(ProgressLen, vPerc);

        if (vInfo.FStreamType = stStream) and (vInfo.FTrackLoaded < vInfo.FTrackBytes) then begin
          vLen := Round(vInfo.FTrackLoaded / vInfo.FTrackBytes * ProgressLen);
          vStr := Copy(vStr, 1, vLen);
        end;

        DlgSetTextApi(IdProgress, vStr);

        if vInfo.FTrackCount = 0 then
          vStr := GetMsgStr(strEmpty)
        else begin
          vStr := Format('%d / %d', [vInfo.FTrackIndex + 1, vInfo.FTrackCount]);
          if Length(vStr) > 9 then
            vStr := Format('%d/%d', [vInfo.FTrackIndex + 1, vInfo.FTrackCount]);
        end;
        DlgSetText(IdTracks, vStr);

        DlgSetText(IdVol, Format('%3d', [Round(vInfo.FVolume)]));

        if vInfo.FState <> psPlayed then
          DlgSetTextApi(IdPlay, GetMsg(strPlay) )
        else
          DlgSetTextApi(IdPlay, GetMsg(strPause) );

      end else
      begin
        DlgSetTextApi(IdTitle, GetMsg(strPlayerNotRunning));
        DlgSetTextApi(IdInfo, '');
        DlgSetTextApi(IdTime1, '');
        DlgSetTextApi(IdTime2, '');
        DlgSetTextApi(IdProgress, GetProgressStr(ProgressLen, 0));
        DlgSetTextApi(IdTracks, GetMsg(strEmpty));
        DlgSetTextApi(IdVol, '--');
        DlgSetTextApi(IdPlay, GetMsg(strPlay) )
      end;

//    FARAPI.SendDlgMessage(hDlg, DM_ENABLE, IdPrev, Byte(vInfo.FTrackIndex > 0));
//    FARAPI.SendDlgMessage(hDlg, DM_ENABLE, IdNext, Byte(vInfo.FTrackIndex < vInfo.FTrackCount - 1));
    end;


    procedure LocClickProgress;
    var
      vCoord :COORD;
      vSeekTo :Integer;
      vInfo :TPlayerInfo;
    begin
      vCoord := PMouseEventRecord(Param2).dwMousePosition;
      DlgScreenToClient(hDlg, IdProgress, vCoord);
      if GetPlayerInfo(vInfo, False) then begin
        vSeekTo := Round(vInfo.FTrackLength * vCoord.X / ProgressLen);
        ExecCommandFmt(CmdSeek1, [vSeekTo]);
        LocUpdateStatus;
      end;
    end;


  begin
//  TraceF('InfoDialogProc: hDlg=%d, Msg=%d, Param1=%d, Param2=%d', [hDlg, Msg, Param1, Param2]);
    Result := 1;
    try
      case Msg of
        DN_INITDIALOG: begin
          LocUpdateStatus;
//        SetTimer(0, 0, 100, @MyTimerProc);
        end;

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
          LocUpdateStatus;
        end;

        DN_MouseClick:
          if Param1 = IdProgress then
            LocClickProgress
          else
            Result := 0;

        DN_EnterIdle:
          LocUpdateStatus;
      else
        Result := FARAPI.DefDlgProc(hDlg, Msg, Param1, Param2);
      end;

    except
      on E :Exception do
        ShowMessage(GetMsgStr(strError), E.Message, FMSG_WARNING or FMSG_MB_OK);
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    vLock :Integer;


  procedure OpenInfoDialog;
  var
    vDlg :PFarDialogItemArray;
    vInfo :TPlayerInfo;
  begin
    if (vLock > 0) or (vPlaylistLock > 0) then
      Exit;

    ExecCommand(CmdInfo);
    if not GetPlayerInfo(vInfo, True) then
      AppErrorID(strPlayerNotRunning);

    Inc(vLock);
    vDlg := GetInfoDlg;
    try

      LockPlayer;
      try
        RunDialog(-1, -1, DX, DY, 'Info', vDlg, cDlgItemsCount, 0, InfoDialogProc, 0);
      finally
        UnlockPlayer;
      end;

    finally
      MemFree(vDlg);
      Dec(vLock);
    end;
  end;


end.

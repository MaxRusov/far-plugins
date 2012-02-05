{$I Defines.inc}
{$Typedaddress Off}

unit FarPlayPlaylistDlg;

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
    MixClasses,

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,

    Far_API,
    FarCtrl,
    FarMatch,
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

  var
    vPlaylist :TStringList;
    vPlaylistRevision :Integer;
    vPlayedTrackIndex :Integer;
    vPlayerState :TPlayerState;

    vPlaylistMaxWidth :Integer;
    vPlaylistCheckedIndex :Integer;
    vPlaylistCheckedState :TPlayerState;

    vFilterMask :TString;
    vFilterList :TExList;


  const
    DX = 20;
    DY = 10;

    IdList = 0;



  function GetPlaylistDlg :PFarDialogItemArray;
  begin
    Result := CreateDialog(
      [
//      NewItemApi(DI_DoubleBox, 3, 1, 10, 10, 0, GetMsg(strTitle))
        NewItemApi(DI_LISTBOX, 2, 1, DX - 4, DY - 2, DIF_LISTWRAPMODE {or DIF_LISTAUTOHIGHLIGHT or DIF_LISTNOAMPERSAND}, GetMsg(strPlaylistTitle))
      ]
    );
  end;


  procedure UpdatePlaylist;
  var
    vInfo :TPlayerInfo;
  begin
    if GetPlayerInfo(vInfo, False) and (vInfo.FTrackCount > 0) then begin
      vPlaylist.Text := GetPlaylist;
      vPlaylistRevision := vInfo.FPlaylistRev;
      vPlayedTrackIndex := vInfo.FTrackIndex;
      vPlayerState := vInfo.FState;
    end else
    begin
      vPlaylist.Clear;
      vPlaylistRevision := 0;
      vPlayedTrackIndex := -1;
      vPlayerState := psEmpty;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function PlaylistDialogProc(hDlg : THandle; Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; stdcall;

    function DetectPlaylistChange :Boolean;
    var
      vInfo :TPlayerInfo;
      vNewRevision :Integer;
    begin
      vNewRevision := 0;
      vPlayedTrackIndex := -1;
      if GetPlayerInfo(vInfo, False) then begin
        vNewRevision := vInfo.FPlaylistRev;
        vPlayedTrackIndex := vInfo.FTrackIndex;
        vPlayerState := vInfo.FState;
      end;
      Result := vPlaylistRevision <> vNewRevision;
    end;


    function DlgToPlaylistIndex(ADlgIndex :Integer) :Integer;
    begin
      Result := ADlgIndex;
      if (vFilterList <> nil) and (Result >= 0) and (Result < vFilterList.Count) then
        Result := Integer(vFilterList[Result]);
    end;


    function PlaylistToDlgIndex(APlaylistIndex :Integer) :Integer;
    var
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
      end;
    end;


    function GetPlaylistIndex :Integer;
    begin
      Result := DlgToPlaylistIndex( FARAPI.SendDlgMessage(hDlg, DM_LISTGETCURPOS, IdList, 0) );
    end;


    procedure ResizeDialog;
    var
      vWidth, vHeight :Integer;
      vCoord :TCoord;
      vRect :TSmallRect;
      vListInfo :TFarListInfo;
      vScreenInfo :TConsoleScreenBufferInfo;
    begin
      GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);
      FARAPI.SendDlgMessage(hDlg, DM_LISTINFO, IdList, Integer(@vListInfo));

      vWidth := vPlaylistMaxWidth + 9;
      if vWidth > vScreenInfo.dwSize.X - 4 then
        vWidth := vScreenInfo.dwSize.X - 4;
      vWidth := IntMax(vWidth, 40);  

      vHeight := vListInfo.ItemsNumber + 4;
      if vHeight > vScreenInfo.dwSize.Y - 2 then
        vHeight := vScreenInfo.dwSize.Y - 2;

      vCoord.X := vWidth;
      vCoord.Y := vHeight;
      FARAPI.SendDlgMessage(hDlg, DM_RESIZEDIALOG, 0, Integer(@vCoord));

      vCoord.X := -1;
      vCoord.Y := -1;
      FARAPI.SendDlgMessage(hDlg, DM_MOVEDIALOG, 1, Integer(@vCoord));

      vRect.Left := 2;
      vRect.Top := 1;
      vRect.Right := vWidth - 3;
      vRect.Bottom := vHeight - 2;
      FARAPI.SendDlgMessage(hDlg, DM_SETITEMPOSITION, IdList, Integer(@vRect));
    end;


    procedure UpdatePlayed(AIndex :Integer; AState :TPlayerState; ARedraw :Boolean);

      procedure LocSetChecked(AIndex :Integer; AChecked :Boolean; AState :TPlayerState);
      var
        vItem :TFarListUpdate;
        vChr :Integer;
      begin
        vItem.Index := AIndex;
        FARAPI.SendDlgMessage(hDlg, DM_LISTGETITEM, IdList, Integer(@vItem));
        vChr := Integer(chrPlay);
        if AState = psPaused then
          vChr := Integer(chrPause);
        if AState = psStopped then
          vChr := Integer(chrStop);
        vItem.Item.Flags := SetFlag(vItem.Item.Flags, LIF_CHECKED or vChr, AChecked);
        FARAPI.SendDlgMessage(hDlg, DM_LISTUPDATE, IdList, Integer(@vItem));
      end;

    begin
      if (AIndex <> vPlaylistCheckedIndex) or (AState <> vPlaylistCheckedState) then begin
//      Trace('UpdatePlayed...');
        if vPlaylistCheckedIndex <> -1 then
          LocSetChecked(vPlaylistCheckedIndex, False, vPlaylistCheckedState);
        if AIndex <> -1 then
          LocSetChecked(AIndex, True, AState);
        if ARedraw then
          FARAPI.SendDlgMessage(hDlg, DM_REDRAW, 0, 0);
        vPlaylistCheckedIndex := AIndex;
        vPlaylistCheckedState := AState;
      end;
    end;


    procedure ReinitListControl;
    var
      vNumLen :Integer;

      function FormatTitle(const AStr :TString; var ATrackLen :Integer) :TString;
      begin
        Result := '';
        if PlaylistShowTitle then
          Result := ExtractWord(3, AStr, ['|']);
        if Result = '' then begin
          Result := ExtractWord(1, AStr, ['|']);
          Result := ExtractFileNameEx(Result);
        end;
        ATrackLen := Str2IntDef(ExtractWord(2, AStr, ['|']), 0);
      end;

      function LocCheckLen(AMaxWidth :Integer) :Integer;
      var
        vScreenInfo :TConsoleScreenBufferInfo;
      begin
        GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);
        Result := vScreenInfo.dwSize.X;
        Result := IntMin(Result - 4{Отступы от краев экрана}, AMaxWidth);
        Dec(Result, 9); {Борюры}
        Dec(Result, 3 + 5); {Для времени}
        if PlaylistShowNumber then
          Dec(Result, 3 + vNumLen);
      end;

    var
      I, J, vCount, vTitleLen, vTrackLen, vMaxTrackLen, vPos, vLen :Integer;
      vStruct :TFarList;
      vItems :PFarListItemArray;
      vItem :PFarListItem;
      vStr, vMask, vTitle :TString;
      vListPos :TFarListPos;
      vRect :TSmallRect;
      vHeight :Integer;
      vHasMask :Boolean;
    begin
//    Trace('ReinitListControl...');
      FARAPI.SendDlgMessage(hDlg, DM_LISTGETCURPOS, IdList, Integer(@vListPos));
      FARAPI.SendDlgMessage(hDlg, DM_ENABLEREDRAW, 0, 0);

      vHasMask := False;
      if vFilterMask <> '' then begin
        if vFilterList = nil then
          vFilterList := TExList.Create;
        vFilterList.Clear;

        vMask := vFilterMask;
        vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
        if vHasMask and (vMask[Length(vMask)] <> '*') and (vMask[Length(vMask)] <> '?') then
          vMask := vMask + '*';
      end else
        FreeObj(vFilterList);

      vTitleLen := 0;
      vMaxTrackLen := 0;
      for I := 0 to vPlaylist.Count - 1 do begin
        vTitle := FormatTitle(vPlaylist[I], vTrackLen);
        if vFilterList <> nil then begin
          if not CheckMask(vMask, vTitle, vHasMask, vPos, vLen) then
            Continue;
          vFilterList.Add(Pointer(I));
        end;
        vTitleLen := IntMax(vTitleLen, Length(vTitle));
        vMaxTrackLen := IntMax(vMaxTrackLen, vTrackLen);
      end;

      vCount := vPlaylist.Count;
      if vFilterList <> nil then
        vCount := vFilterList.Count;

      vItems := MemAllocZero(vCount * SizeOf(TFarListItem));
      try
        vPlaylistMaxWidth := 0;
        vNumLen := Length(Int2Str(vCount));

        if PlaylistShowTime and (vMaxTrackLen > 0) then
          { Если vTitleLen слишком большой, то уменьшаем его, чтобы на экран влезло время }
          vTitleLen := RangeLimit(vTitleLen, LocCheckLen(40), LocCheckLen(MaxInt));

        vItem := @vItems[0];
        for I := 0 to vCount - 1 do begin
          J := I;
          if vFilterList <> nil then
            J := Integer(vFilterList[I]);

          vTitle := FormatTitle(vPlaylist[J], vTrackLen);
         {$ifndef bUnicodeFar}
          vTitle := StrAnsiToOEM(vTitle);
         {$endif bUnicodeFar}

          if PlaylistShowTime and (vMaxTrackLen > 0) then begin
            vTitle := StrLeftAjust(vTitle, vTitleLen) + ' ' + chrVertLine + ' ';
            if vTrackLen > 0 then
              vTitle := vTitle + Time2Str(vTrackLen);
          end;

          if PlaylistShowNumber then begin
            vStr := Int2Str(I + 1);
//          if I < 9 then
//            vStr := '&' + vStr;
            vTitle := StrLeftAjust(vStr, vNumLen) + ' ' + chrVertLine + ' ' + vTitle;
          end;

          if Length(vTitle) > vPlaylistMaxWidth then
            vPlaylistMaxWidth := Length(vTitle);

          {!!!}
          SetListItem(vItem, PFarChar(vTitle), 0);
          Inc(PChar(vItem), SizeOf(TFarListItem));
        end;

        vStruct.ItemsNumber := vCount;
        vStruct.Items := vItems;
        FARAPI.SendDlgMessage(hDlg, DM_LISTSET, IdList, Integer(@vStruct));

        vPlaylistCheckedIndex := -1;
        UpdatePlayed(PlaylistToDlgIndex(vPlayedTrackIndex), vPlayerState, False);

        FARAPI.SendDlgMessage(hDlg, DM_GETITEMPOSITION, IdList, Integer(@vRect));
        vHeight := vRect.Bottom - vRect.Top - 1;
        vListPos.SelectPos := RangeLimit(vListPos.SelectPos, 0, vCount - 1);
        vListPos.TopPos := RangeLimit(vListPos.TopPos, 0, vCount - vHeight);
        FARAPI.SendDlgMessage(hDlg, DM_LISTSETCURPOS, IdList, Integer(@vListPos));

      finally
        FARAPI.SendDlgMessage(hDlg, DM_ENABLEREDRAW, 1, 0);
       {$ifdef bUnicodeFar}
        CleanupList(@vItems[0], vCount);
       {$endif bUnicodeFar}
        MemFree(vItems);
      end;

      ResizeDialog;
    end;


    procedure SetCurrent(AIndex :Integer; ACenter :Boolean);
    var
      vListPos :TFarListPos;
      vInfo :TFarListInfo;
      vRect :TSmallRect;
      vHeight :Integer;
    begin
      if AIndex >= 0 then begin
        FARAPI.SendDlgMessage(hDlg, DM_LISTGETCURPOS, IdList, Integer(@vListPos));
        FARAPI.SendDlgMessage(hDlg, DM_LISTINFO, IdList, Integer(@vInfo));
        FARAPI.SendDlgMessage(hDlg, DM_GETITEMPOSITION, IdList, Integer(@vRect));
        vHeight := vRect.Bottom - vRect.Top - 1;

        if (AIndex < vListPos.TopPos) or (AIndex >= vListPos.TopPos + vHeight) then
          ACenter := True;
        if ACenter then
          vListPos.TopPos := AIndex - (vHeight div 2);

        vListPos.SelectPos := AIndex;
        vListPos.TopPos := RangeLimit(vListPos.TopPos, 0, vInfo.ItemsNumber - vHeight);
        FARAPI.SendDlgMessage(hDlg, DM_LISTSETCURPOS, IdList, Integer(@vListPos));
      end;
    end;


    procedure PlayCurrent;
    var
      vIndex :Integer;
    begin
      vIndex := GetPlaylistIndex;
      ExecCommandFmt(CmdGoto1, [vIndex + 1]);
      DetectPlaylistChange;
      UpdatePlayed(PlaylistToDlgIndex(vPlayedTrackIndex), vPlayerState, True);
    end;


    procedure DeleteCurrent;
    var
      vIndex :Integer;
    begin
      vIndex := GetPlaylistIndex;
      if (vIndex >= 0) and (vIndex < vPlaylist.Count) then begin
        ExecCommandFmt(CmdDelete1, [vIndex + 1]);
        vPlaylist.Delete(vIndex);
        vPlayedTrackIndex := -1;
        ReinitListControl;
      end;
    end;


    procedure MoveCurrent(ADelta :Integer);
    var
      vIndex, vNewIndex :Integer;
    begin
      vIndex := GetPlaylistIndex;
      vNewIndex := vIndex + ADelta;
      if (vIndex >= 0) and (vIndex < vPlaylist.Count) and (vNewIndex >= 0) and (vNewIndex < vPlaylist.Count) then begin
        ExecCommandFmt(CmdMoveTrack1, [vIndex + 1, vNewIndex + 1]);
        vPlaylist.Move(vIndex, vNewIndex);
        vPlayedTrackIndex := -1;
        ReinitListControl;
        SetCurrent(PlaylistToDlgIndex(vNewIndex), False);
      end;
    end;


    procedure SetFilter(const ANewFilter :TString);
    var
      vTitles :TFarListTitles;
      vTitle :PFarChar;
      vFooter :TString;
      vIndex :Integer;
    begin
      if ANewFilter <> vFilterMask then begin
//      TraceF('Mask: %s', [ANewFilter]);
        vFilterMask := ANewFilter;

        vIndex := GetPlaylistIndex;
        ReinitListControl;
        vIndex := PlaylistToDlgIndex(vIndex);
        if vIndex < 0 then
          vIndex := 0;
        SetCurrent( vIndex, False );

        vTitle := GetMsg(strPlaylistTitle);

        vFooter := '';
        if vFilterMask <> '' then
          vFooter := Format('[%s] %d / %d', [ StrAnsiToOEM(vFilterMask), vFilterList.Count, vPlaylist.Count ]);

        FillChar(vTitles, SizeOf(vTitles), 0);
        vTitles.Title := PTChar(vTitle);
        vTitles.TitleLen := StrLen(vTitle);
        vTitles.Bottom := PTChar(vFooter);
        vTitles.BottomLen := Length(vFooter);

        FARAPI.SendDlgMessage(hDlg, DM_LISTSETTITLES, IdList, Integer(@vTitles));
      end;
    end;


    procedure ChangePalette(AColors :PFarListColors);
    const
      cColors = 10;
      cMenuPalette :array[0..cColors - 1] of TPaletteColors =
        (COL_MENUBOX,COL_MENUBOX,COL_MENUTITLE,COL_MENUTEXT, COL_MENUHIGHLIGHT,COL_MENUBOX,COL_MENUSELECTEDTEXT, COL_MENUSELECTEDHIGHLIGHT,COL_MENUSCROLLBAR,COL_MENUDISABLEDTEXT);
    var
      I :Integer;
    begin
      for I := 0 to IntMin(cColors, AColors.ColorCount) - 1 do
        AColors.Colors[I] := Char( FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(cMenuPalette[i])) );
    end;


  begin
//  TraceF('InfoDialogProc: hDlg=%d, Msg=%d, Param1=%d, Param2=%d', [hDlg, Msg, Param1, Param2]);
    Result := 1;
    try
      case Msg of
        DN_INITDIALOG: begin
          ReinitListControl;
          SetCurrent(vPlayedTrackIndex, False);
        end;

        DN_CTLCOLORDIALOG:
          Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

        DN_CTLCOLORDLGLIST:
          if Param1 = IdList then begin
            ChangePalette(PFarListColors(Param2));
            Result := 1;
          end;

        DN_RESIZECONSOLE: begin
//        FARAPI.SendDlgMessage(hDlg, DM_ENABLEREDRAW, 0, 0);
//        try
            ReinitListControl;
            SetCurrent(FARAPI.SendDlgMessage(hDlg, DM_LISTGETCURPOS, IdList, 0), False);
//        finally
//          FARAPI.SendDlgMessage(hDlg, DM_ENABLEREDRAW, 1, 0);
//        end;
        end;

        DN_EnterIdle: begin
          if DetectPlaylistChange then begin
            UpdatePlaylist;
            ReinitListControl;
          end else
            UpdatePlayed(PlaylistToDlgIndex(vPlayedTrackIndex), vPlayerState, True);
        end;

        DN_MouseClick:
          if Param1 = IdList then begin
            PlayCurrent;
            if PMouseEventRecord(Param2).dwButtonState and FROM_LEFT_1ST_BUTTON_PRESSED <> 0 then
              FARAPI.SendDlgMessage(hDlg, DM_CLOSE, -1, 0);
          end else
            Result := FARAPI.DefDlgProc(hDlg, Msg, Param1, Param2);

        DN_KEY: begin
//        TraceF('Key = %d', [Param2]);
          case Param2 of
            KEY_ENTER, KEY_SHIFTENTER:
              begin
                PlayCurrent;
                if Param2 = KEY_ENTER then
                  FARAPI.SendDlgMessage(hDlg, DM_CLOSE, -1, 0);
              end;

            KEY_SHIFTHOME:
              SetCurrent(PlaylistToDlgIndex(vPlayedTrackIndex), False);

            KEY_CTRL1:
              begin
                PlaylistShowNumber := not PlaylistShowNumber;
                ReinitListControl;
              end;
            KEY_CTRL2:
              begin
                PlaylistShowTitle := not PlaylistShowTitle;
                ReinitListControl;
              end;
            KEY_CTRL3:
              begin
                PlaylistShowTime := not PlaylistShowTime;
                ReinitListControl;
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
                ReinitListControl;
                UpdatePlayed(PlaylistToDlgIndex(vPlayedTrackIndex), vPlayerState, True);
              end;

            KEY_DEL:
              SetFilter('');
            KEY_BS:
              if vFilterMask <> '' then
                SetFilter( Copy(vFilterMask, 1, Length(vFilterMask) - 1));
            KEY_MULTIPLY:
              SetFilter( vFilterMask + '*' );

          else
           {$ifdef bUnicodeFar}
            if (Param2 >= 32) and (Param2 < $FFFF) then
           {$else}
            if (Param2 >= 32) and (Param2 <= $FF) then
           {$endif bUnicodeFar}
            begin
             {$ifdef bUnicodeFar}
              SetFilter(vFilterMask + TChar(Param2));
             {$else}
              SetFilter(vFilterMask + StrOEMToAnsi(TChar(Param2)));
             {$endif bUnicodeFar}
            end else
              Result := FARAPI.DefDlgProc(hDlg, Msg, Param1, Param2);
          end;
        end;

      else
        Result := FARAPI.DefDlgProc(hDlg, Msg, Param1, Param2);
      end;

    except
      on E :Exception do
        ShowMessage(GetMsgStr(strError), E.Message, FMSG_WARNING or FMSG_MB_OK);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure OpenPlaylist;
  var
    vInfo :TPlayerInfo;
    vDlg :PFarDialogItemArray;
  begin
    if vPlaylistLock > 0 then
      Exit;

    ExecCommand(CmdInfo);
    if not GetPlayerInfo(vInfo, False) then
      AppErrorID(strPlayerNotRunning);

    Inc(vPlaylistLock);
    vDlg := GetPlaylistDlg;
    try
      vPlaylist := TStringList.Create;
      UpdatePlaylist;

      LockPlayer;
      try
        vFilterMask := '';
        RunDialog(-1, -1, DX, DY, 'Playlist', vDlg, 1, 0, PlaylistDialogProc, 0);
      finally
        UnlockPlayer;
      end;

    finally
      vFilterMask := '';
      FreeObj(vPlaylist);
      FreeObj(vFilterList);
      MemFree(vDlg);
      Dec(vPlaylistLock);
    end;

  end;


end.


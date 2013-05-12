{$I Defines.inc}

unit FarFMFindUrlDlg;

interface

  uses
    Windows,
    MSXML,

    MixTypes,
    MixUtils,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg,
    FarGrid,

    FarFMCtrl,
    FarFmCalls;


  function FindDlg(AMode :Integer; const APrompt :TString; var AName :TString) :Boolean;
    { AMode = 1 - поиск исполнителей }
    { AMode = 2 - поиск пользователей }


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    cFindWhats :array[0..2] of TMessages = (
      strArtists,
      strAlbums,
      strTracks
    );

    cCol2Title :array[0..2] of TMessages = (
      strListeners,
      strAlbums,
      strTracks
    );


  const
    cDlgDefWidth  = 60;
    cDlgMinWidth  = 40;
    cDlgMinHeight = 12;

    cTypeWidth    = 11;

    IdFrame   = 0;
    IdPrompt  = 1;
    IdEdit    = 2;
    IdPrompt2 = 3;
    IdEdit2   = 4;
    IdGrid    = 5;
    IdDel     = 6;
    IdOk      = 7;
    IdCancel  = 8;


  type
    TFindDlg = class(TFarDialog)
    public
      constructor CreateEx(AMode :Integer);
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FMode     :Integer;
      FPrompt   :TString;
      FRes      :TString;

      FChanged  :Boolean;

      FGrid     :TFarGrid;
      FMaxWidth :Integer;

      FList     :TStringArray2;
      FListMode :Integer;

      procedure RunFind;
      procedure ReinitGrid;
      procedure ResizeDialog;

      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
    end;


  constructor TFindDlg.CreateEx(AMode :Integer);
  begin
    FMode := AMode;
    Create;
  end;


  destructor TFindDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TFindDlg.Prepare; {override;}
  var
    X1 :Integer;
  begin
//  FHelpTopic := 'Find';
    FGUID := cFindDlgID;
    FWidth := cDlgDefWidth;
    FHeight := cDlgMinHeight;
    X1 := FWidth-5-cTypeWidth;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   3,  1, FWidth-6, FHeight-2, 0, GetMsg(TMessages(IntIf(FMode = 1, byte(strFindArtist), byte(strFindUser))))),

        NewItemApi(DI_Text,        5,  2, X1-7, -1, 0, GetMsg(strFindTextPrompt) ),
        NewItemApi(DI_Edit,        5,  3, X1-7, -1, DIF_HISTORY, '', PCharIf(FMode = 1, 'FarFM.Find', 'FarFM.FindUser') ),

        NewItemApi(DI_Text,        X1,  2, cTypeWidth, -1, 0, GetMsg(strFindWherePrompt) ),
        NewItemApi(DI_ComboBox,    X1,  3, cTypeWidth, -1, DIF_DROPDOWNLIST, ''),

        NewItemApi(DI_USERCONTROL, 5,  5, FWidth-10, FHeight-9, 0, '' ),

        NewItemApi(DI_Text,        0, FHeight-4, -1, -1, DIF_SEPARATOR, ''),
        NewItemApi(DI_DefButton,   0, FHeight-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk)),
        NewItemApi(DI_Button,      0, FHeight-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel))
      ], @FItemCount
    );

    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid.NormColor := FarGetColor(COL_DIALOGLISTTEXT);
    FGrid.SelColor := FarGetColor(COL_DIALOGLISTSELECTEDTEXT);
    FGrid.TitleColor := FarGetColor(COL_DIALOGLISTHIGHLIGHT);

//  FGrid.NormColor := FarGetColor(COL_DIALOGEDIT);
//  FGrid.SelColor := FarGetColor(COL_DIALOGEDITSELECTED);

//  FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
  end;


  procedure TFindDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);

    SetListItems(IdEdit2, [
      GetMsgStr(cFindWhats[0]),
      GetMsgStr(cFindWhats[1]),
      GetMsgStr(cFindWhats[2])
    ]);
    SetListIndex(IdEdit2, 0);
    SetText(IdEdit2, GetMsgStr(cFindWhats[0]));

    SetEnabled(IdOk, False);
    FChanged := True;
    ReinitGrid;
  end;


  function TFindDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      if FChanged then begin
        RunFind;
        Result := False;
      end else
      begin
        FRes := Trim(FList[FGrid.CurRow, 0]);
        Result := True;
      end;
    end else
      Result := True;
  end;


 {-----------------------------------------------------------------------------}

  function TFindDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < length(FList) then
      Result := FList[ARow, ACol];
  end;


  procedure TFindDlg.ReinitGrid;
  var
    I, vMaxLen1, vMaxLen2 :Integer;
  begin
    FMaxWidth := 0;
    vMaxLen1 := 2; vMaxLen2 := 2;
    for I := 0 to length(FList) - 1 do begin
      vMaxLen1 := IntMax(vMaxLen1, Length(FList[I, 0]));
      vMaxLen2 := IntMax(vMaxLen2, Length(FList[I, 1]));
    end;

    if vMaxLen1 + vMaxLen2 + 9{4+4+1} < cDlgDefWidth then
      vMaxLen1 := cDlgDefWidth - (vMaxLen2 + 9);

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(strArtists), vMaxLen1+2, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', GetMsgStr(cCol2Title[FListMode]), vMaxLen2+2, taLeftJustify, [coColMargin], 2) );
    FGrid.ReduceColumns( IntMax(FarGetWindowSize.CX - 4, cDlgMinWidth) - 6 - 5);
    FMaxWidth := FGrid.Column[0].Width + FGrid.Column[1].Width + 5;

    if length(FList) > 0 then
      FGrid.Options := FGrid.Options + [goShowTitle]
    else
      FGrid.Options := FGrid.Options - [goShowTitle];

    FGrid.RowCount := length(FList);

    if FChanged then
      SetText(IdOk, GetMsgStr(strFindBut))
    else begin
      SetText(IdOk, GetMsgStr(strAddBut));
      SetEnabled(IdOk, FGrid.RowCount > 0);
    end;

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      ResizeDialog;
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TFindDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect, vRect1 :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := IntMax(FMaxWidth + 6, cDlgDefWidth);
    if vWidth > vSize.CX - 4 then
      vWidth := vSize.CX - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 9;
    if goShowTitle in FGrid.Options then
      Inc(vHeight);
    vHeight := IntMax(vHeight, cDlgMinHeight);
    if vHeight > vSize.CY - 2 then
      vHeight := vSize.CY - 2;
    vHeight := IntMax(vHeight, cDlgMinHeight);

    vRect := SBounds(3, 1, vWidth - 7, vHeight - 3);
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);

    RectGrow(vRect, -1, -1);

    vRect1 := SRect(vRect.Left + 1, vRect.Top, vRect.Right - cTypeWidth - 3, vRect.Top + 1);
    SendMsg(DM_SETITEMPOSITION, IdPrompt, @vRect1);
    RectMove(vRect1, 0, 1);
    SendMsg(DM_SETITEMPOSITION, IdEdit, @vRect1);

    vRect1 := SRect(vRect.Right - cTypeWidth, vRect.Top, vRect.Right - 1, vRect.Top + 1);
    SendMsg(DM_SETITEMPOSITION, IdPrompt2, @vRect1);
    RectMove(vRect1, 0, 1);
    SendMsg(DM_SETITEMPOSITION, IdEdit2, @vRect1);

    vRect1 := SRect(vRect.Left + 1, vRect.Top + 3, vRect.Right - 1, vRect.Bottom - 2);
    SendMsg(DM_SETITEMPOSITION, IdGrid, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := vRect;
    vRect1.Top := vRect1.Bottom - 1;
    SendMsg(DM_SETITEMPOSITION, IdDel, @vRect1);

    RectMove(vRect1, 0, 1);
    SendMsg(DM_SETITEMPOSITION, IdOk, @vRect1);
    SendMsg(DM_SETITEMPOSITION, IdCancel, @vRect1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


 {-----------------------------------------------------------------------------}

  procedure TFindDlg.RunFind;
  var
    vStr :TString;
    vDoc :IXMLDOMDocument;
  begin
    vStr := Trim(GetText(IdEdit));
    if vStr = '' then
      Exit;

    FListMode := SendMsg(DM_LISTGETCURPOS, IdEdit2, 0);

    if FMode = 1 then begin

      if FListMode = 0 then begin
        vDoc := LastFMCall('artist.search', ['artist', vStr]);
        FList := XMLParseArray(vDoc, 'lfm/results/artistmatches/artist', ['name', 'listeners']);
      end else
      if FListMode = 1 then begin
        vDoc := LastFMCall('album.search', ['album', vStr]);
        FList := XMLParseArray(vDoc, 'lfm/results/albummatches/album', ['artist', 'name']);
      end else
      if FListMode = 2 then begin
        vDoc := LastFMCall('track.search', ['track', vStr]);
        FList := XMLParseArray(vDoc, 'lfm/results/trackmatches/track', ['artist', 'name']);
      end else
        Sorry;

    end else
    begin
      {???}
      vDoc := LastFMCall('user.search', ['user', vStr]);
    end;

    FChanged := False;
    FGrid.GotoLocation(0, 0, lmScroll);
    ReinitGrid;
  end;


 {-----------------------------------------------------------------------------}

  function TFindDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    if SendMsg(DM_GETFOCUS, 0, 0) = IdEdit then begin
      case AKey of
        KEY_UP, KEY_DOWN, KEY_PGUP, KEY_PGDN, KEY_CTRLPGUP, KEY_CTRLPGDN:
          FGrid.KeyDown(AKey);
       else
         Result := inherited KeyDown(AID, AKey);
      end;
    end else
      Result := inherited KeyDown(AID, AKey);
  end;


  function TFindDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE: begin
        ReInitGrid;
        FGrid.GotoLocation(FGrid.CurCol, FGrid.CurRow, lmScroll);
      end;

      DN_EDITCHANGE:
        if Param1 = IdEdit then begin
          if not FChanged then begin
            FChanged := True;
            FList := nil;
            ReinitGrid;
          end;
          SetEnabled(IdOk, not StrIsEmpty(GetText(IdEdit)));
        end else
        if Param1 = IdEdit2 then begin
          if  not FChanged then
            SetText(IdEdit, '');
        end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  procedure TFindDlg.ErrorHandler(E :Exception); {override;}
  begin
    if not (E is EAbort) then
      ShowMessage(cPluginName, E.Message, FMSG_WARNING or FMSG_MB_OK or FMSG_LEFTALIGN);
  end;

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function FindDlg(AMode :Integer; const APrompt :TString; var AName :TString) :Boolean;
  var
    vDlg :TFindDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TFindDlg.CreateEx(AMode);
    try
      vDlg.FPrompt := APrompt;

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      AName := vDlg.FRes;
      Result := AName <> '';
    finally
      FreeObj(vDlg);
    end;
  end;


end.


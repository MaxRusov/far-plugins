{$I Defines.inc}

unit WinNoisyMain;

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
    MultiMon, 

    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,
    MixClasses,
    MixWin,

    NoisyConsts,
    NoisyUtil,
    NoisyCtrl,
    WinNoisyCtrl,
    WinNoisyPlaylist;



  const
    GUIWndClassName = 'WINNOISY@001';

  var
    cColor1  :Integer = $FADAC4; // $E4DAAF;
    cColor2  :Integer = $F5BE9E; // $D6C583;
    cColor3  :Integer = $FEECDD; // $F0EBD5;

  var
    PopupMode :Boolean = False;


  type
    TMainForm = class(TMSWindow)
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure Run;

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure WndProc(var Mess :TMessage); override;
      procedure ErrorHandler(E :Exception); override;

    private
      FTitleLab   :TLabel;
//    FAlbumLab   :TLabel;
      FTypeLab    :TLabel;
      FTimeLab    :TLabel;

      FTracker    :TTracker;
      FVolume     :TTracker;
      FToolbar    :TToolbar;

      FListView   :TPlaylistView;

      FImages     :HImagelist;
      FFont       :HFont;
      FBrush1     :HBrush;
      FBrush2     :HBrush;

      FStartSeek  :Integer;

      FLastState  :TPlayerState;
      FLastLen    :Integer;
      FLastTime   :Integer;
      FLastCount  :Integer;
      FLastIndex  :Integer;
      FLastVolume :Integer;
      FLastMute   :Boolean;

      FShowList   :Boolean;
      FSmallRect  :TRect;
      FBigRect    :TRect;

      procedure SafeMoveTo(const APoint :TPoint);
      procedure SafeMoveToRect(ARect :TRect);
      procedure ShowPlaylist(AShow :Boolean);

      procedure SetupInitialPos;
      procedure SetupFont;
      procedure SetupControls;
      procedure SetupListView;
      procedure RealignControls;

      procedure CallOpenDialog;
      procedure Idle;

      procedure WMDestroy(var Mess :TWMDestroy); message WM_Destroy;
      procedure WMClose(var Mess :TWMClose); message WM_Close;
      procedure WMWindowPosChanged(var Mess :TWMWindowPosChanged); message WM_WindowPosChanged;
      procedure WMGetMinMaxInfo(var Mess :TWMGetMinMaxInfo); message WM_GetMinMaxInfo;
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMPrintClient(var Mess :TMessage); message WM_PrintClient;
      procedure WMCtlColorStatic(var Mess :TWMCtlColorStatic); message WM_CtlColorStatic;
      procedure WMNCHitTest(var Mess :TWMPaint); message WM_NCHitTest;
      procedure WMNotify(var Mess :TWMNotify); message WM_Notify;
      procedure WMCommand(var Mess :TWMCommand); message WM_Command;
      procedure WMKeyDown(var Mess :TWMKeyDown); message WM_KeyDown;
      procedure WMHScroll(var Mess :TWMHScroll); message WM_HScroll;

    public
      property Images :HImagelist read FImages;
    end;


  var
    MainForm :TMainForm;

  procedure Run;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function ScreenBitPerPixel :Integer;
  var
    vHDC :HDC;
  begin
    vHDC := GetDC(0);
    try
      Result := GetDeviceCaps(vHDC, BITSPIXEL) * GetDeviceCaps(vHDC, PLANES) {???};
    finally
      ReleaseDC(0, vHDC);
    end;
  end;


  procedure VertexSetColor(var AVertex :TTriVertex; AColor :Integer);
  begin
    with RGBRec(AColor) do begin
      AVertex.Red := Red shl 8;
      AVertex.Green := Green shl 8;
      AVertex.Blue := Blue shl 8;
      AVertex.Alpha := 0;
    end;
  end;


  procedure GradientFillRect(ADC :HDC; const ARect :TRect; AColor1, AColor2 :Integer; AVert :Boolean);
  const
    FillFlag :Array[Boolean] of Integer = (GRADIENT_FILL_RECT_H, GRADIENT_FILL_RECT_V);
  var
    VA :array[0..1] of TTriVertex;
    GR :TGradientRect;
  begin
    VA[0].X := ARect.Left;
    VA[0].Y := ARect.Top;
    VertexSetColor(VA[0], AColor1);

    VA[1].X := ARect.Right;
    VA[1].Y := ARect.Bottom;
    VertexSetColor(VA[1], AColor2);

    GR.UpperLeft := 0;
    GR.LowerRight := 1;
    GradientFill(ADC, @VA[0], 2, @GR, 1, FillFlag[AVert]);
  end;


 {-----------------------------------------------------------------------------}

  procedure CorrectBoundsRectEx(var ARect :TRect; const AMonRect :TRect);
  begin
    if ARect.Right > AMonRect.Right then
      RectMove(ARect, AMonRect.Right - ARect.Right, 0);
    if ARect.Bottom > AMonRect.Bottom then
      RectMove(ARect, 0, AMonRect.Bottom - ARect.Bottom);
    if ARect.Left < AMonRect.Left then
      RectMove(ARect, AMonRect.Left - ARect.Left, 0);
    if ARect.Top < AMonRect.Top then
      RectMove(ARect, 0, AMonRect.Top - ARect.Top);
  end;


  function MonitorRectFromPoint(const APoint :TPoint) :TRect;
  var
    vMonInfo :TMonitorInfo;
    vHM :HMONITOR;
  begin
    FillChar(vMonInfo, SizeOf(vMonInfo), 0);
    vMonInfo.cbSize := SizeOf(vMonInfo);
    vHM := MonitorFromPoint(APoint, MONITOR_DEFAULTTONEAREST);
    if vHM <> 0 then begin
      GetMonitorInfo(vHM, @vMonInfo);
      Result := vMonInfo.rcWork;
    end else
      Result := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
  end;


  procedure CorrectBoundsRectForPoint(var ARect :TRect; const APoint :TPoint);
  var
    vRect :TRect;
  begin
    vRect := MonitorRectFromPoint(APoint);
    CorrectBoundsRectEx(ARect, vRect);
  end;


 {-----------------------------------------------------------------------------}
 { TMainForm                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TMainForm.Create; {override;}
  begin
    inherited Create;

    if ScreenBitPerPixel <= 8 then begin
      cColor1 := GetSysColor(COLOR_BTNFACE);
      cColor2 := cColor1;
      cColor3 := GetSysColor(COLOR_WINDOW);
    end (*!!!else
    if not IsWindowsVista then begin
      cColor1 := cColor2;
    end*);

    CreateHandle;
    SetupInitialPos;
    SetupControls;
    SetupFont;

    FLastState := psEmpty;
    FLastLen := -1;
    FLastTime := -1;
    FLastCount := 0;

    FModulePath := ExtractFilePath(Paramstr(0));

    ReadSettings;
    FBigRect := PlaylistRect;
    if LastShowPlaylist then
      ShowPlaylist(True);

    if not PopupMode then
      if FShowList then begin
        if (PlaylistRect.Right > PlaylistRect.Left) and (PlaylistRect.Bottom > PlaylistRect.Top) then
          SafeMoveToRect(PlaylistRect);
      end else
      begin
        if (MainWinPos.X <> 0) or (MainWinPos.Y <> 0) then
          SafeMoveTo(MainWinPos)
      end;
  end;


  destructor TMainForm.Destroy; {override;}
  begin
    try
      MainWinPos := FSmallRect.TopLeft;
      PlaylistRect := FBigRect;
      LastShowPlaylist := FShowList;

      WriteSettings;
    except
    end;

    FreeObj(FTitleLab);
    FreeObj(FTypeLab);
    FreeObj(FTimeLab);
    FreeObj(FTracker);
    FreeObj(FVolume);
    FreeObj(FToolbar);
    FreeObj(FListView);

    inherited Destroy;
  end;


 {--------------------------------------}

  const
    cMainWidth  = 300;
    cMainHeight = 100;

    cListWidth  = 400;
    cListHeight = 600;

    cDelta      = 10;
    cDelta1     = 5;
    cLabHeight  = 16;
    cTrkHeight  = 18;

    cVolHeight  = 18;
    cVolWidth   = 50;

    cTbrHeight  = 22;
    cButSize    = 16;

    cButHeight  = 20;
    cButWidth   = 50;

    cButPlay    = 1;
    cButStop    = 2;
    cButPrev    = 3;
    cButNext    = 4;
    cButOpen    = 5;
    cButList    = 6;
    cButMute    = 7;

    IdTracker   = 10;
    IdVolume    = 11;


  procedure TMainForm.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    StrPCopy(AParams.WinClassName, GUIWndClassName);
//  AParams.WindowClass.Style := AParams.WindowClass.Style and not (CS_VREDRAW + CS_HREDRAW);

    if PopupMode then begin
      AParams.Style := WS_POPUP or WS_THICKFRAME;
      AParams.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST {or WS_CLIPCHILDREN};
    end else
    begin
(*!!!      if IsWindowsVista then
        AParams.Caption := 'Noisy'
      else *)
        AParams.Caption := ' Noisy ';
      AParams.Style := WS_CAPTION or WS_BORDER or WS_SYSMENU or WS_SIZEBOX {or WS_CLIPCHILDREN};
      AParams.ExStyle := WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
      AParams.X := Integer(CW_USEDEFAULT);
      AParams.Y := Integer(CW_USEDEFAULT);
    end;

    AParams.DX := cMainWidth;
    AParams.DY := cMainHeight;
  end;


  procedure TMainForm.SetupInitialPos;
  var
    vRect, vRect1, vSysRect :TRect;
    vWnd :THandle;
  begin
    vRect := ClientRect;
    vRect1 := GetBoundsRect;
    SetWindowSize(
      (vRect1.Right - vRect1.Left) + (cMainWidth - vRect.Right),
      (vRect1.Bottom - vRect1.Top) + (cMainHeight - vRect.Bottom));

    if PopupMode then begin
      { Прижимаем окно к SysTray }
      vWnd := GetSystrayWindow;
      if vWnd <> 0 then begin
        GetWindowRect(vWnd, vSysRect);
        SafeMoveTo(vSysRect.TopLeft);
      end;
    end;
  end;


  procedure TMainForm.SetupControls;
  const
    cButtonCount = 10;
    cButtons :array[0..cButtonCount - 1] of TTBButton = (
      (iBitmap:0; idCommand:cButPlay; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
      (iBitmap:2; idCommand:cButStop; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
      (fsStyle:TBSTYLE_SEP),
      (iBitmap:4; idCommand:cButPrev; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
      (iBitmap:3; idCommand:cButNext; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
      (fsStyle:TBSTYLE_SEP),
      (iBitmap:5; idCommand:cButOpen; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
      (iBitmap:8; idCommand:cButList; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON),
      (iBitmap:43; fsStyle:TBSTYLE_SEP),
      (iBitmap:6; idCommand:cButMute; fsState:TBSTATE_ENABLED; fsStyle:TBSTYLE_BUTTON)
    );
  var
    vRect :TRect;
    Y, DX :Integer;
  begin
    vRect := ClientRect;
    DX := vRect.Right - cDelta*2;

    Y := cDelta;
    FTitleLab := TLabel.CreateEx(Self, 0, cDelta, Y, DX, cLabHeight, SS_ENDELLIPSIS, ''{Track name});

//  Inc(Y, cLabHeight);
//  FAlbumLab := TLabel.CreateEx(Self, 0, cDelta, Y, DX, cLabHeight, 0, ''{Album name});

    Inc(Y, cLabHeight);
    FTypeLab := TLabel.CreateEx(Self, 0, cDelta, Y, 200, cLabHeight, SS_ENDELLIPSIS, '');
    FTimeLab := TLabel.CreateEx(Self, 0, vRect.Right - cDelta - 100, Y, 100, cLabHeight, SS_RIGHT, '');

    Inc(Y, cLabHeight + 5);
    FTracker := TTracker.CreateEx(Self, IdTracker, cDelta-6, Y, DX+12, cTrkHeight,
      TBS_HORZ or TBS_BOTH or TBS_ENABLESELRANGE or TBS_FIXEDLENGTH or TBS_NOTICKS or TBS_TRANSPARENTBKGND, '');
    FTracker.Perform(TBM_SETTHUMBLENGTH, 14, 0);

    Y := vRect.Bottom - cTbrHeight - cDelta div 2;

    FVolume := TTracker.CreateEx(Self, IdVolume, vRect.Right-cDelta-cVolWidth-6, Y+2, cVolWidth+12, cTrkHeight,
      TBS_HORZ or TBS_BOTH {or TBS_ENABLESELRANGE} or TBS_FIXEDLENGTH or TBS_NOTICKS or TBS_TRANSPARENTBKGND, '');
    FVolume.Perform(TBM_SETTHUMBLENGTH, 14, 0);
    FVolume.Perform(TBM_SETRANGE, 1, MakeLong(0, 100));

    FToolbar := TToolbar.CreateEx(Self, 0, cDelta, Y, DX-cVolWidth-cDelta, cTbrHeight,
      CCS_NORESIZE or CCS_NODIVIDER or TBSTYLE_FLAT, '');

    FImages := ImageList_LoadBitmap(HInstance, 'Buttons', cButSize, 0, RGB(255,255,255));
    SendMessage(FToolbar.Handle, TB_SETIMAGELIST, 0,  FImages);

    SendMessage(FToolbar.Handle, TB_BUTTONSTRUCTSIZE, sizeof(TTBButton), 0);
    SendMessage(FToolbar.Handle, TB_ADDBUTTONS, cButtonCount, Integer(@cButtons));
  end;


  procedure TMainForm.SetupListView;
  var
    vCol :TLVColumn;
  begin
    FListView := TPlaylistView.CreateEx(Self, 0, 0, 0, 100, 100,
      LVS_OWNERDATA or LVS_REPORT {or LVS_NOCOLUMNHEADER} or LVS_NOSORTHEADER or LVS_SHAREIMAGELISTS, '');

    ListView_SetExtendedListViewStyle(FListView.Handle,
      LVS_EX_FULLROWSELECT or
      LVS_EX_DOUBLEBUFFER or
//    LVS_EX_AUTOSIZECOLUMNS or
//    LVS_EX_ONECLICKACTIVATE or LVS_EX_UNDERLINEHOT
      {or LVS_EX_FLATSB or LVS_EX_GRIDLINES or LVS_EX_TRACKSELECT or LVS_EX_BORDERSELECT}
      0);

    ListView_SetImageList(FListView.Handle, FImages, LVSIL_SMALL);
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

    FListView.InitPlaylist;
  end;


  procedure TMainForm.RealignControls;
  var
    vRect :TRect;
    Y, DX :Integer;
  begin
    vRect := ClientRect;
    DX := vRect.Right - cDelta*2;
    Y := vRect.Bottom - cMainHeight + cDelta;
    FTitleLab.SetBounds(Bounds(cDelta, Y, DX, cLabHeight), 0);
    Inc(Y, cLabHeight);
    FTypeLab.SetBounds(Bounds(cDelta, Y, DX - 100, cLabHeight), 0);
    FTimeLab.SetBounds(Bounds(cDelta + DX - 100, Y, 100, cLabHeight), 0);
    Inc(Y, cLabHeight + 5);
    FTracker.SetBounds(Bounds(cDelta-6, Y, DX+12, cTrkHeight), 0);
    Y := vRect.Bottom - cTbrHeight - cDelta div 2;
    FVolume.SetBounds(Bounds(vRect.Right-cDelta-cVolWidth-6, Y+2, cVolWidth+12, cTrkHeight), 0);
    FToolbar.SetBounds(Bounds(cDelta, Y, DX-cVolWidth-cDelta, cTbrHeight), 0);

    if FListView <> nil then
      FListView.SetBounds(Bounds(cDelta1, cDelta1, vRect.Right - cDelta1*2, vRect.Bottom-cMainHeight-cDelta), 0);
  end;


  procedure TMainForm.ShowPlaylist(AShow :Boolean);
  var
    vRect :TRect;
    vDX, vDY :Integer;
    vWnd :THandle;
  begin
    if FShowList = AShow then
      Exit;

    vRect := GetBoundsRect;
    if PopupMode then begin
      { Прижимаем окно к SysTray }
      vWnd := GetSystrayWindow;
      if vWnd <> 0 then
        GetWindowRect(vWnd, vRect);
    end;

    FShowList := AShow;
    if FShowList then begin

      vDX := FBigRect.Right - FBigRect.Left;
      vDY := FBigRect.Bottom - FBigRect.Top;
      if (vDX < 0) or (vDY <= 0) then begin
        vDX := cListWidth;
        vDY := cListHeight;
      end;

      vRect.Top := vRect.Bottom - vDY;
      vRect.Right := vRect.Left + vDX;

      SetupListView;
    end else
    begin
      vDX := FSmallRect.Right - FSmallRect.Left;
      vDY := FSmallRect.Bottom - FSmallRect.Top;

      vRect.Top := vRect.Bottom - vDY;
      vRect.Right := vRect.Left + vDX;

      FreeObj(FListView);
    end;

    SafeMoveToRect(vRect);
  end;


  procedure TMainForm.SafeMoveTo(const APoint :TPoint);
  var
    vRect :TRect;
  begin
    vRect := GetBoundsRect;
    vRect := Bounds(APoint.X, APoint.Y, vRect.Right - vRect.Left, vRect.Bottom - vRect.Top);
    SafeMoveToRect(vRect);
  end;


  procedure TMainForm.SafeMoveToRect(ARect :TRect);
  var
    vRect :TRect;
  begin
    vRect := MonitorRectFromPoint(ARect.TopLeft);
    CorrectBoundsRectEx(ARect, vRect);
    SetBounds(ARect, 0);
  end;


  procedure TMainForm.SetupFont;
  var
//  vFontInfo :LOGFONT;
    vWnd :HWND;
  begin
    FBrush1 := CreateSolidBrush(cColor1);
    FBrush2 := CreateSolidBrush(cColor3);

//  SystemParametersInfo(SPI_GetIconTitleLogFont, sizeof(vFontInfo), @vFontInfo, 0);
//  FFont := CreateFontIndirect(vFontInfo);
    FFont := GetStockObject(DEFAULT_GUI_FONT);

    SendMessage(Handle, WM_SetFont, Integer(FFont), 0);

    vWnd := GetWindow(Handle, GW_CHILD);
    while vWnd <> 0 do begin
      SendMessage(vWnd, WM_SetFont, Integer(FFont), 0);
      vWnd := GetWindow(vWnd, GW_HWNDNEXT);
    end;
  end;


  procedure TMainForm.WndProc(var Mess :TMessage); {override;}
  begin
    inherited WndProc(Mess);
  end;


  procedure TMainForm.WMClose(var Mess :TWMClose); {message WM_Close;}
  begin
(*
    ShowPlaylist := Playlist <> nil;
    ClosePlaylist;
*)
    inherited;
  end;


  procedure TMainForm.WMDestroy(var Mess :TWMDestroy); {message WM_Destroy;}
  begin
    inherited;
    PostQuitMessage(0);
  end;


  procedure TMainForm.WMWindowPosChanged(var Mess :TWMWindowPosChanged); {message WM_WindowsPosChanged;}
  begin
    inherited;
    if FToolbar <> nil then
      RealignControls;

    if FShowList then begin
      with Mess.WindowPos^ do
        FBigRect := Bounds(X, Y, CX, CY);
    end else
    begin
      with Mess.WindowPos^ do
        FSmallRect := Bounds(X, Y, CX, CY);
    end;
  end;


  procedure TMainForm.WMGetMinMaxInfo(var Mess :TWMGetMinMaxInfo); {message WM_GetMinMaxInfo;}
  var
    vMinSize :TSize;
  begin
    inherited;
    
    vMinSize := Size(cMainWidth, cMainHeight);
    if FShowList then
      Inc(vMinSize.cy, cMainHeight);

    with Mess.MinMaxInfo^ do begin
      if vMinSize.CX <> 0 then
        ptMinTrackSize.X := vMinSize.CX + GetSystemMetrics(SM_CXFRAME) * 2;
      if vMinSize.CY <> 0 then
        ptMinTrackSize.Y := vMinSize.CY + GetSystemMetrics(SM_CYFRAME) * 2 +
          IntIf(not PopupMode, GetSystemMetrics(SM_CYCAPTION), 0);
      if not FShowList then
        ptMaxTrackSize := ptMinTrackSize;
    end;
  end;


  procedure TMainForm.WMNCHitTest(var Mess :TWMPaint); {message WM_NCHitTest;}
  begin
    inherited;
    if Mess.Result in [HTCLIENT {, HTTOP, HTBOTTOM, HTLEFT, HTRIGHT, HTTOPLEFT, HTTOPRIGHT, HTBOTTOMLEFT, HTBOTTOMRIGHT}] then
      Mess.Result := HTCAPTION;
    if not FShowList and (Mess.Result in [HTTOP, HTBOTTOM, HTLEFT, HTRIGHT, HTTOPLEFT, HTTOPRIGHT, HTBOTTOMLEFT, HTBOTTOMRIGHT]) then
      Mess.Result := HTCAPTION;
  end;


  procedure TMainForm.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
//  inherited;
    GradientFillRect(Mess.DC, ClientRect, cColor1, cColor2, True);
    Mess.Result := 1;
  end;


  procedure TMainForm.WMPrintClient(var Mess :TMessage); {message WM_PrintClient;}
  begin
    if Mess.LParam = PRF_CLIENT	then begin
      GradientFillRect(HDC(Mess.WParam), ClientRect, cColor1, cColor2, True);
//    TraceF('WMPrintClient: %d, %d', [Mess.WParam, Mess.LParam]);
    end else
      inherited;
  end;


  procedure TMainForm.WMCtlColorStatic(var Mess :TWMCtlColorStatic); {message WM_CtlColorStatic;}
  begin
    if (Mess.ChildWnd = FTracker.Handle) or (Mess.ChildWnd = FVolume.Handle) then begin
      if FBrush1 <> 0 then
        Mess.Result := Integer(FBrush1)
      else
        inherited;
    end else
    begin
      if FBrush2 <> 0 then begin
        SetBkMode(Mess.ChildDC, Transparent);
        Mess.Result := Integer(FBrush2);
      end else
        inherited;
    end;
  end;


  procedure TMainForm.WMNotify(var Mess :TWMNotify); {message WM_Notify;}
  begin
//  TraceF('WMNotify: %d', [Mess.NMHdr.Code]);
    inherited;

    if (FListView <> nil) and (Mess.NMHdr.hwndFrom = FListView.Handle)  then begin
      case Mess.NMHdr.Code of
        NM_DBLCLK:
          FListView.PlayCurrent;

        LVN_GETDISPINFO:
          with PLVDispInfo(Mess.NMHdr)^ do begin
  //        TraceF('WMNotify: Mask: %d, Item: %d, %d', [Item.mask, Item.iItem, Item.iSubitem]);
            if Item.mask and LVIF_IMAGE <> 0 then
              FListView.GetTrackIcon(Item);
            if Item.mask and LVIF_TEXT <> 0 then
              FListView.GetCellText(Item);
          end;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMainForm.WMKeyDown(var Mess :TWMKeyDown); {message WM_KeyDown;}
  var
    vPos :Integer;
  begin
    inherited;
    case Mess.CharCode of
      Byte('P'), VK_Space:
        ExecCommand(CmdSafe + ' ' + CmdPlayPause);
      Byte('S'):
        ExecCommand(CmdSafe + ' ' + CmdStop);
      Byte('O'):
        CallOpenDialog;
      Byte('M'):
        ExecCommand(CmdSafe + ' ' + CmdVolumeMute);
      VK_UP:
        ExecCommand(CmdSafe + ' ' + CmdVolumeInc);
      VK_DOWN:
        ExecCommand(CmdSafe + ' ' + CmdVolumeDec);
      VK_NEXT:
        ExecCommand(CmdSafe + ' ' + CmdNext);
      VK_PRIOR:
        ExecCommand(CmdSafe + ' ' + CmdPrev);
      VK_LEFT: begin
        vPos := FTracker.Perform(TBM_GETPOS, 0, 0);
        FTracker.Perform(TBM_SETPOS, 1, vPos - 5);
        FStartSeek := GetTickCount;
      end;
      VK_RIGHT: begin
        vPos := FTracker.Perform(TBM_GETPOS, 0, 0);
        FTracker.Perform(TBM_SETPOS, 1, vPos + 5);
        FStartSeek := GetTickCount;
      end;

      VK_ESCAPE:
        Perform(WM_Close, 0, 0);
    end;
  end;


  procedure TMainForm.WMCommand(var Mess :TWMCommand); {message WM_COMMAND;}
  begin
    case Mess.ItemID of
      cButPlay:
        ExecCommand(CmdSafe + ' ' + CmdPlayPause);
      cButStop:
        ExecCommand(CmdSafe + ' ' + CmdStop);
      cButPrev:
        ExecCommand(CmdSafe + ' ' + CmdPrev);
      cButNext:
        ExecCommand(CmdSafe + ' ' + CmdNext);
      cButOpen:
        CallOpenDialog;
      cButList:
(*      OpenPlaylist;  *)
        ShowPlaylist(not FShowList);
      cButMute:
        ExecCommand(CmdSafe + ' ' + CmdVolumeMute);
    end;
  end;


  procedure TMainForm.WMHScroll(var Mess :TWMHScroll); {message WM_HScroll;}
  var
    vPos :Integer;
  begin
//  TraceF('WMHScroll: Code: %d, Pos: %d', [Mess.ScrollCode, Mess.Pos]);
    if Mess.ScrollBar = FTracker.Handle then begin
      if Mess.ScrollCode = SB_ENDSCROLL then begin
        vPos := FTracker.Perform(TBM_GETPOS, 0, 0);
//      TraceF('Scroll to: %d', [vPos]);
        ExecCommandFmt(CmdNoTooltip + ' ' + CmdSeek1, [vPos]);
      end;
    end else
    begin
      if Mess.ScrollCode in [SB_THUMBTRACK, SB_ENDSCROLL] then begin
        vPos := FVolume.Perform(TBM_GETPOS, 0, 0);
//      TraceF('Volume=%d', [vPos]);
        ExecCommandFmt(CmdNoTooltip + ' ' + CmdVolume1, [vPos]);
      end;
    end;
  end;


  procedure TMainForm.ErrorHandler(E :Exception); {override;}
  begin
    MessageBox(0, PTChar(E.Message), 'Error', MB_OK or MB_ICONHAND);
  end;


 {-----------------------------------------------------------------------------}

  procedure TMainForm.CallOpenDialog;
  var
    vWnd :THandle;
  begin
    vWnd := FindWindow(WndClassName, nil);
    if vWnd <> 0 then
      SetForegroundWindow(vWnd);
    ExecCommand(CmdSafe + ' ' + CmdOpen);
  end;


  procedure TMainForm.Idle;
  var
    vRunning :Boolean;
    vInfo :TPlayerInfo;
    vFormat :TBassFormat;
    vName, vStr :TString;
    vLen, vPos, vVol :Integer;
    vWnd :THandle;
  begin
    vRunning := GetPlayerInfo(vInfo, False);
    if not vRunning then
      FillChar(vInfo, SizeOf(vInfo), 0);

    vName := vInfo.FTrackArtist;
    vStr := vInfo.FTrackTitle;
    if (vName <> '') and (vStr <> '') then
      vName := vName + ' - ' + vStr;
    if vName = '' then
      vName := ExtractFileNameEx(vInfo.FPlayedFile);

    if vName <> '' then
      FTitleLab.Text := ' ' + vName
    else begin
      if vRunning then
        FTitleLab.Text := ' Playlist is empty '
      else
        FTitleLab.Text := ' Player not running ';
    end;

//  vStr := vInfo.FTrackAlbum;
//  if vStr <> '' then
//    vStr := '   ' + vStr;
//  FAlbumLab.Text := vStr;

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
        FTypeLab.Text := Format('   %s, shothcast, %s', [vStr, NameOfChans(vInfo.FTrackChans)] )
      else
        FTypeLab.Text := Format('   %s, %d kbps, %s', [vStr, vInfo.FTrackBPS, {vInfo.FTrackFreq,} NameOfChans(vInfo.FTrackChans)] );

      vStr := Time2Str(vInfo.FPlayTime) + ' / ' + Time2Str(vInfo.FTrackLength) + ' ';
      FTimeLab.Text := vStr;
    end else
    begin
      FTypeLab.Text := '';
      FTimeLab.Text := '';
    end;

    vLen := Round(vInfo.FTrackLength);
    if vLen <> FLastLen then begin
      FTracker.Perform(WM_ENABLE, IntIf(vLen > 0, 1, 0), 0);
      FTracker.Perform(TBM_SETRANGE, 1, MakeLong(0, vLen));
//      FTracker.Perform(TBM_SETTICFREQ, 10, 0);
      FLastLen := vLen;
      FLastTime := -1;
      FStartSeek := 0;
    end;

    vPos := 0;
    if vLen > 0 then
      vPos := Round(vInfo.FPlaytime);
    if vPos <> FLastTime then begin
      FTracker.Perform(TBM_SETSELEND, 1, vPos);
      if (GetCapture <> FTracker.Handle) and (FStartSeek = 0) then
        FTracker.Perform(TBM_SETPOS, 1, vPos);
      FLastTime := vPos;
    end;

    if FLastState <> vInfo.FState then begin
      FToolbar.SetButtonInfo(cButPlay, IntIf(vInfo.FState = psPlayed, 1, 0), '');
      FToolbar.SetButtonEnabled(cButStop, vInfo.FState in [psPlayed, psPaused]);
      FLastState := vInfo.FState;
    end;

    if (FLastCount <> vInfo.FTrackCount) or (FLastIndex <> vInfo.FTrackIndex) then begin
      FToolbar.SetButtonEnabled(cButPlay, (vInfo.FTrackCount > 0) or not vRunning);
      FToolbar.SetButtonEnabled(cButPrev, vInfo.FTrackIndex > 0);
      FToolbar.SetButtonEnabled(cButNext, vInfo.FTrackIndex < vInfo.FTrackCount - 1);

      FLastCount := vInfo.FTrackCount;
      FLastIndex := vInfo.FTrackIndex;
    end;

    vVol := Round(vInfo.FVolume);
    if FLastVolume <> vVol then begin
      if GetCapture <> FVolume.Handle then
        FVolume.Perform(TBM_SETPOS, 1, vVol);
      FLastVolume := vVol;
    end;

    if FLastMute <> vInfo.FMute then begin
      FToolbar.SetButtonInfo(cButMute, IntIf(vInfo.FMute, 7, 6), '');
      FLastMute := vInfo.FMute
    end;

    {-----------------------------}

    if (FStartSeek <> 0) and (TickCountDiff(GetTickCount, FStartSeek) > 500) then begin
      vPos := FTracker.Perform(TBM_GETPOS, 0, 0);
      ExecCommandFmt(CmdNoTooltip + ' ' + CmdSeek1, [vPos]);
      FStartSeek := 0;
    end;

    if PopupMode then begin
      vWnd := GetForegroundWindow;
      if (vWnd = 0) or (GetWindowThreadProcessId(vWnd, nil) <> GetCurrentThreadId) then
        Perform(WM_Close, 0, 0);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMainForm.Run;
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
      begin
        try
          Idle;
          Sleep(1);
        except
          {Nothing}
        end;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ParseCommandLine;
  var
    vPtr :PTChar;
    vCmd :TString;
  begin
    vPtr := GetCommandLineStr;
    while vPtr^ <> #0 do begin
      vCmd := ExtractParamStr(vPtr);
      if vCmd = '' then
        Continue;

      if (vCmd[1] = '/') or (vCmd[1] = '-') then begin
        Delete(vCmd, 1, 1);

        if StrEqual(vCmd, 'Popup') then
          PopupMode := True;

        {!!!}
      end;
    end;
  end;


  procedure Run;
  var
    vWnd :THandle;
  begin
    vWnd := FindWindow(GUIWndClassName, nil);
    if vWnd <> 0 then begin
      SetForegroundWindow(vWnd);
      Exit;
    end;

    ParseCommandLine;
    LockPlayer;
    try
      MainForm := TMainForm.Create;
      try
        MainForm.Show(SW_Show);
        MainForm.Run;
      finally
        FreeObj(MainForm);
      end;
    finally
      UnlockPlayer;
    end;
  end;


end.

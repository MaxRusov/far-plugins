{$I Defines.inc}

unit ReviewMain;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

{
To Do:
  - ������������ FileMapping ��� GDI+, ��� �� �� ��� ����� ���������...

  + ��������� ������ ����� ��� ������� �������� (��� ������ Info?)  

  * ��������� JpegLIB
    + ����� DLL
    + ������ ���������������� ��������
    * ��������� ������
      + ���� �� ����������� JpegLIB - ����� ��������� GDI+
      + JpegLIB - ������������� ����� �����������
      + ����������� ������������� Thumbnail
    + x64
    + ��������� Internal ������� - ���������

  + ����������� ��� ���������� �����
    + �������� Mapped �����?
    + ��������� �� ������ ��� ������������ �������
    + GFL: �� �������� �������� ��������������� ����������� (������ GIF?)

  + ���������� ���������� �����������
    * AV ��� ����������, ������������ � ��������������...
    x ���� ������������ ��� x64 - �������� � Viewer'��.
    + �� ����������� ������� ��� x64
    + ������ ��� ���������� �����
    + �� ������������ Read-Only �����
    + ���������� ����� GDI+ ��� PVD ��������� (�� �����������)

  * Slideshow
    - ����� �� ����� ��������� �����/���������������.
    - ����� ������ media-������

  - Tags:
    - ����������� ��������

  - DXVideo.pvd
    - ���������� ������� OSD ��� ���������� � ����������
    - ������ � ConEmu
    - ���������� ����� �������
    * ���������� �������� (?)

  - ������ ���������������� ���� QuickView � ������ Far Fullscreen
  - ������: QuicView-F3-PgDn-Esc


�� �������:
  + ��������� PVD v1
  - ��������� PVD v3
  - Popup ����
  - ����������� � clipboard
  - SaveAs: ������� Bitmaps
  - SaveAs: ��� *.pvd ���������

Ready:
  + Help
  + ���������
  + Fulscreen mode
  + Tile mode
  + ������� ��������
    + ������ ��������������� �������� ���������� �����������
  + ���������� ��������� FullScreen
  + �������� "���������" ��������

  + ����������� ���������
    + ���������� ���� ��� ������ �������
    + "������������" ������ ����������

  + ��������� ��������:
    + Zoom
    + ���������
    + ��������
    + ����������

  + ��������� � ���������� ���������
    + ����������/�������
    + ��������������
    x ����������� (?)

  * ���������� ��������
    + ���������� ���� ����� ��� ����������
    + ���������� ����� �������
    + ��������� ������ ����������
    + ������������� ����� ���������� (��� ����� ����������?)
    + ���������� ����������� ��� ������� �������������...
      + �������� ���������� ����� ��� �������

  * �����:
    + DoubleClick - Fullscreen
    + ���������� ��������� ����� ������
    + ���������� � ����������
      + ����������������
      + Play/Pause
    + ���������� ����������

  + GFL.pvd
    + ������ ���������� ����� EXIF2

  + ���������
    + ������ ��������
      + ��������������
      + ���������� ������
      + ��������� ��������

    * ��������� ���������
      + ���������� ��������
      + ��������� �������� Enable
      + ��������������
      + ������ "���������"
      + ���������� � �������� + ���������
      + ������ "������������ ���������"
      - ��������� ����� ��������

  + ��������� Detach Console
  + ��������� ConEmu

  + ���������� ����� ����������
    + ������� ������� �����
    + ��������� ����
  + ����� Tag'��
    + ����������� Tag'��
    + ������������ ���
    + ����������� ����������
    + ��������������� ���������

  + Slideshow
  + ���� �������� ��������
  + ������������� � �������� ����������� ��� *.pvd ���������
  + �� �������� ������������� �� ������ ������ ��� ��������������� ����������� (?)
  + ����������� ��������� ��������? (������� SendMessage �� PostMessage)

  + AV ��� ������ �������� EMF.

  + ����� ���������� ��� ���������������
    + ���������� � ������ Preview

}


interface

  uses
    Windows,
    ActiveX,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMenu,
    FarPlug,

    ReviewConst,
    ReviewDecoders,
    ReviewClasses;

  type
    TReviewPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;

//    function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
     {$endif Far3}

      function ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      procedure SynchroEvent(AParam :Pointer); override;

    private
      FCmdWords  :TKeywordsList;

     {$ifdef Far3}
      function MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;
     {$endif Far3}
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
   {$ifdef bThumbs}
    ReviewThumbs,
   {$endif bThumbs}
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TReviewPlug                                                                 }
 {-----------------------------------------------------------------------------}

  procedure TReviewPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison;

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
    FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
    FMinFarVer := MakeVersion(3, 0, 3000);   { LUA }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1800);   { OPEN_FROMMACROSTRING, MCMD_POSTMACROSTRING };
   {$endif Far3}
  end;


  procedure TReviewPlug.Startup; {override;}
  begin
    { �������� Handle ������� Far'� }
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    FFarExePath := AddBackSlash(ExtractFilePath(GetExeModuleFileName));

    RestoreDefColor;
    PluginConfig(False);

    Review := TReviewManager.Create;
    Review.InitSubplugins;
  end;


  procedure TReviewPlug.ExitFar; {override;}
  begin
    FreeObj(FCmdWords);
    FreeObj(Review);
  end;


  procedure TReviewPlug.GetInfo; {override;}
  begin
    FFlags:= {PF_PRELOAD or PF_EDITOR or} PF_VIEWER;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    if optCmdPrefix <> '' then
      FPrefix := PTChar(optCmdPrefix);
  end;



  function TReviewPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}

    function IsRealFile :Boolean;
    var
      vInfo :TPanelInfo;
    begin
      Result := False;
      if (FarGetMacroArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}]) and (FarGetWindowType = WTYPE_PANELS) then
        if FarGetPanelInfo(True, vInfo) {and IsVisiblePanel(vInfo)} and (vInfo.PanelType = PTYPE_FILEPANEL) then
          Result := not IsPluginPanel(vInfo) or (vInfo.Flags and PFLAGS_REALNAMES <> 0);
    end;

  begin
    Result:= INVALID_HANDLE_VALUE;
    case AFrom of
      OPEN_PLUGINSMENU:
        if IsRealFile then begin
          if Review.ShowImage('', 0, True) then
            ViewModalState(False, False);
        end else
        begin
          Review.SetForceFile(FarPanelItemName(PANEL_ACTIVE, FCTL_GETCURRENTPANELITEM, 0), 2);
          FarPostMacro('Keys("F3")');
        end;  

      OPEN_VIEWER:
        if Review.ShowImage(ViewerControlString(VCTL_GETFILENAME), 0, True) then
          ViewModalState(False, False);

//    OPEN_ANALYSE:
//      {};
    end;
  end;


(*
  function TReviewPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vName :TString;
  begin
    Result:= INVALID_HANDLE_VALUE;
    if not optProcessPrefix then
      Exit;

    if (AStr = nil) or (AStr^ = #0) then begin
     {$ifdef bThumbs}
      if Review.ShowThumbs('') then
        ThumbModalState;
     {$endif bThumbs}
    end else
    begin
      vName := AStr;
      if (vName <> '') and (vName[1] = '"') and (vName[length(vName)] = '"') then
        vName := Copy(vName, 2, length(vName) - 2);
      vName := FarExpandFileName(vName);
      if Review.ShowImage(vName, 0, True) then
        ViewModalState(False, False);
    end;
  end;
*)
  function TReviewPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vName :TString;
  begin
    Result:= INVALID_HANDLE_VALUE;
    if not optProcessPrefix then
      Exit;

    vName := '';
    if AStr <> nil then
      vName := AStr;
    if (vName <> '') and (vName[1] = '"') and (vName[length(vName)] = '"') then
      vName := Copy(vName, 2, length(vName) - 2);
    vName := FarExpandFileName(vName);

   {$ifdef bThumbs}
    if (vName = '') or WinFolderExists(vName) then begin
      if Review.ShowThumbs(vName, '') then
        ThumbModalState
    end else
   {$endif bThumbs}
    if Review.ShowImage(vName, 0, True) then
      ViewModalState(False, False);
  end;


  procedure TReviewPlug.Configure; {override;}
  begin
    Review.PluginSetup;
  end;


 {$ifdef Far3}
  function TReviewPlug.OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {override;}
  begin
    Result := 0;
    if (ACount = 0) or ((ACount = 1) and (AParams[0].fType in [FMVT_INTEGER, FMVT_DOUBLE])) then
      Result := inherited OpenMacroEx(ACount, AParams)
    else
    if AParams[0].fType = FMVT_STRING then
      Result := MacroCommand(AParams[0].Value.fString, ACount, AParams);
  end;

  

  type
    TKeywordCode = (
      kwUpdate,
      kwGoto,
      kwPage,
      kwScale,
      kwDecoder,
      kwRotate,
      kwSave,
      kwFullscreen,
      kwSlideShow,
     {$ifdef bThumbs}
      kwThumbs,
      kwSize,
     {$endif bThumbs}
      kwVolume,
      kwSeek,
      kwAudio,
      kwIsMedia,
      kwIsQuickView
    );


  function TReviewPlug.MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;

    procedure InitKeywords;

      procedure Add(const aKeyword :TString; aCode :TKeywordCode);
      begin
        FCmdWords.Add(aKeyword, byte(aCode));
      end;

    begin
      if FCmdWords <> nil then
        Exit;
      FCmdWords := TKeywordsList.Create;
      Add('Update', kwUpdate);
      Add('Goto', kwGoto);
      Add('Page', kwPage);
      Add('Scale', kwScale);
      Add('Decoder', kwDecoder);
      Add('Rotate', kwRotate);
      Add('Save', kwSave);
      Add('Fullscreen', kwFullscreen);
      Add('SlideShow', kwSlideShow);
     {$ifdef bThumbs}
      Add('Thumbs', kwThumbs);
      Add('Size', kwSize);
     {$endif bThumbs}
      Add('Seek', kwSeek);
      Add('Volume', kwVolume);
      Add('Audio', kwAudio);
      Add('IsMedia', kwIsMedia);
      Add('IsQuickView', kwIsQuickView);
    end;


    function LocGoto :TIntPtr;
    var
      vOrig, vDir :Integer;
      vRes :Boolean;
    begin
      vRes := False;
      vOrig := FarValuesToInt(AParams, ACount, 1, -1);
      vDir := FarValuesToInt(AParams, ACount, 2, 1);
      if (vOrig >= 0) and (vOrig <= 2) then begin
        vRes := Review.Navigate(vOrig, vDir > 0, optEffectOnManual);
      end else
      if vOrig = 3 then
        vRes := Review.NavigateTo(FarValuesToStr(AParams, ACount, 2, ''));
      Result := FarReturnValues([vRes]);
    end;


    function LocPage :TIntPtr;
    var
      vPage :Integer;
      vImage :TReviewImage;
    begin
      Result := 0;
      vPage := FarValuesToInt(AParams, ACount, 1) - 1;
      if vPage >= 0 then
        Review.SetImagePage(vPage);
      vImage := Review.CurImage;
      if vImage <> nil then
        Result := FarReturnValues([vImage.Page + 1, vImage.Pages]);
    end;


    function LocScale :TIntPtr;
    var
      vMode :TScaleSetMode;
      vValue :Integer;
      vFloat :TFloat;
    begin
      Result := 0;
      vMode := TScaleSetMode(FarValuesToInt(AParams, ACount, 1, 0));
      if vMode = smSetMode then begin
        vValue := FarValuesToInt(AParams, ACount, 2, -1);
        if vValue >= 1 then
          Review.SetScale(vMode, TScaleMode(vValue), 0);
      end else
      if vMode in [smSetScale, smDeltaScale, smDeltaScaleMouse] then begin
        vFloat := FarValuesToFloat(AParams, ACount, 2, 0);
        if vFloat <> 0 then
          Review.SetScale(vMode, smExact, vFloat);
      end;
      if Review.Window <> nil then
        Result := FarReturnValues([byte(Review.Window.ScaleMode), Review.Window.Scale]);
    end;

    function LocDecoder :TIntPtr;
    var
      vMode :Integer;
      vImage :TReviewImage;
    begin
      Result := 0;
      vMode := FarValuesToInt(AParams, ACount, 1, -1);
      if vMode >= 0 then
        Review.Redecode(TRedecodeMode(vMode));
      vImage := Review.CurImage;
      if vImage <> nil then
        Result := FarReturnValues([vImage.Decoder.Name]);
    end;

    function LocRotate :TIntPtr;
    var
      vMode, vValue :Integer;
      vImage :TReviewImage;
    begin
      Result := 0;
      vMode := FarValuesToInt(AParams, ACount, 1, -1);
      vValue := FarValuesToInt(AParams, ACount, 2, -1);
      if vMode <> -1 then
        if vMode = 0 then
          Review.Rotate(vValue)
        else
          Review.Orient(vValue);
      vImage := Review.CurImage;
      if vImage <> nil then
        Result := FarReturnValues([vImage.Orient]);
    end;

    function LocSave :TIntPtr;
    var
      vMode :Byte;
      vRes :Boolean;
    begin
      vMode := FarValuesToInt(AParams, ACount, 1, 0);
      vRes := Review.Save('', '', 0, 0, TSaveOptions(vMode));
      Result := FarReturnValues([vRes]);
    end;

    function LocFullscreen :TIntPtr;
    var
      vMode :Integer;
    begin
      Result := 0;
      if Review.Window <> nil then begin
        vMode := FarValuesToInt(AParams, ACount, 1, -1);
        if vMode >= 0 then
          Review.SetFullscreen(vMode);
        Result := FarReturnValues([Review.Window.WinMode = wmFullscreen]);
      end;
    end;

    function LocSlideShow :TIntPtr;
    var
      vMode :Integer;
    begin
      Result := 0;
      if Review.Window <> nil then begin
        vMode := FarValuesToInt(AParams, ACount, 1, -2);
        if vMode <> -2 then
          Review.SlideShow(vMode, False);
        Result := FarReturnValues([Review.Window.SlideDelay <> 0]);
      end;
    end;


    function LocVolume :TIntPtr;
    var
      vValue :Integer;
    begin
      Result := 0;
      if Review.Window <> nil then begin
        vValue := FarValuesToInt(AParams, ACount, 1, -1);
        if vValue <> -1 then
          Review.Window.SetMediaVolume(vValue);
        vValue := Review.Window.GetMediaVolume;
        Result := FarReturnValues([vValue]);
      end;
    end;


    function LocSeek :TIntPtr;
    var
      vMode, vValue :Integer;
    begin
      Result := 0;
      vMode := FarValuesToInt(AParams, ACount, 1, -1);
      vValue := FarValuesToInt(AParams, ACount, 2, 0);
      if (vMode >= 0) and (vMode <= 2) then
        Review.MediaSeek(TSeekOrigin(vMode), vValue);
      if Review.Window <> nil then
        Result := FarReturnValues([Review.Window.GetMediaPos, Review.Window.GetMediaLen]);
    end;


    function LocAudio :TIntPtr;
    var
      vMode, vValue :Integer;
    begin
      Result := 0;
      vMode := FarValuesToInt(AParams, ACount, 1, -1);
      vValue := FarValuesToInt(AParams, ACount, 2, 0);
      if (vMode >= 0) and (vMode <= 2) then
        Review.ChangeAudioStream(TSeekOrigin(vMode), vValue);
      if Review.Window <> nil then
        Result := FarReturnValues([Review.Window.GetAudioStream, Review.Window.GetAudioStreamCount]);
    end;


   {$ifdef bThumbs}
    function LocShowThumbs :TIntPtr;
    begin
      Result := 0;
      Review.OpenThumbsView;
    end;

    function LocSetSize :TIntPtr;
    var
      vSize :Integer;
    begin
      Result := 0;
      vSize := FarValuesToInt(AParams, ACount, 1);
      if vSize > 0 then
        Review.ThumbSetSize(vSize);
      if Review.ThumbWindow <> nil then
        Result := FarReturnValues([(Review.ThumbWindow as TThumbsWindow).ThumbSize]);
    end;
   {$endif bThumbs}

  var
    vCmd :TKeywordCode;
  begin
    Result := 0;
    try
      InitKeywords;
      vCmd := TKeywordCode(FCmdWords.GetKeywordStr(ACmd));
      case vCmd of
        kwUpdate:
          Review.SyncDelayed(SyncCmdUpdateWin, FarValuesToInt(AParams, ACount, 1, optSyncDelay));
        kwGoto:
          Result := LocGoto;
        kwPage:
          Result := LocPage;
        kwScale:
          Result := LocScale;
        kwDecoder:
          Result := LocDecoder;
        kwRotate:
          Result := LocRotate;
        kwSave:
          Result := LocSave;
        kwFullscreen:
          Result := LocFullscreen;
        kwSlideShow:
          Result := LocSlideShow;
        kwSeek:
          Result := LocSeek;
        kwVolume:
          Result := LocVolume;
        kwAudio:
          Result := LocAudio;
       {$ifdef bThumbs}
        kwThumbs:
          Result := LocShowThumbs;
        kwSize:
          Result := LocSetSize;
       {$endif bThumbs}
        kwIsMedia:
          Result := FarReturnValues([(Review.Window <> nil) and Review.Window.IsMedia]);
        kwIsQuickView:
          Result := FarReturnValues([Review.IsQViewMode]);
      end;
    except
      on E :Exception do
        if ModalDlg <> nil then
          ModalDlg.SetError( E.Message )
        else
          raise;
    end;
  end;
 {$endif Far3}



  function TReviewPlug.ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  var
    vAltView, vQuickView, vRealNames :Boolean;
    vForce :Integer;
    vInfo :TPanelInfo;
    vName :TString;
  begin
//  TraceF('Event=%d, AParam=%d, AID=%d', [AEvent, TIntPtr(AParam), AID]);

    if AEvent = VE_Read then begin
      vForce := 0;
      try
       {$ifdef Far3}
        vName := ViewerControlString(VCTL_GETFILENAME);
       {$else}
//      vName := FarChar2Str(vInfo.FileName);
       {$endif Far3}

        vQuickView := False; vRealNames := False;
        if (FarGetMacroArea in [MACROAREA_SHELL, MACROAREA_SEARCH, MACROAREA_OTHER{???}]) and (FarGetWindowType = WTYPE_PANELS) then
          if FarGetPanelInfo(False, vInfo) {and IsVisiblePanel(vInfo)} and (vInfo.PanelType = PTYPE_QVIEWPANEL) then
            if FarGetPanelInfo(True, vInfo) {and IsVisiblePanel(vInfo)} and (vInfo.PanelType = PTYPE_FILEPANEL) then begin
              vQuickView := True;
              vRealNames := PFLAGS_REALNAMES and vInfo.Flags <> 0;
            end;

        if vQuickView then begin
          if optProcessQView then
            if Review.IsQViewMode and optAsyncQView and vRealNames then
              Review.SyncDelayed(SyncCmdSyncImage, optSyncDelay)
            else
            if Review.ShowImage(vName, 1) then
              { ��������� ��������� ��� QuickView. �����, ��� ��� �� �������� �������... }
              { ViewModalState(True) };
        end else
        begin
          vForce := Review.ForceMode;
          if vForce <> 0 then begin
            if not StrEqual(Review.ForceFile, ExtractFileName(vName)) then
              vForce := 0;
            Review.SetForceFile('', 0);
          end;

          vAltView := (GetKeyState(VK_Menu) < 0) or
            ((GetKeyState(VK_Control) < 0) and (GetKeyState(VK_Shift) < 0));
          if (optProcessView and not vAltView) or (vForce <> 0) then
            if Review.ShowImage(vName, 0, vForce = 2) then  
              ViewModalState(True, False);
        end;
      except
        on E :Exception do begin
          Plug.ErrorHandler(E);
          if vForce = 2 then
            FarPostMacro('Keys("Esc")');
        end;
      end;
    end else
    if AEvent = VE_CLOSE then
      if Review.IsQViewMode then
        Review.SyncDelayed(SyncCmdSyncImage, optSyncDelay);

    Result := 0;
  end;


  procedure TReviewPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
    if Review = nil then
      Exit;

    case TUnsPtr(AParam) of
      SyncCmdUpdateWin   : Review.UpdateWindowPos;
      SyncCmdSyncImage   : Review.SyncWindow;
      SyncCmdCacheNext   : Review.CacheNeighbor(True);
      SyncCmdCachePrev   : Review.CacheNeighbor(False);
      SyncCmdNextSlide   : Review.GoNextSlide;
      SyncCmdFullScreen  : Review.SetFullscreen(-1);
     {$ifdef bThumbs}
      SyncCmdThumbView   : Review.OpenThumbsView;
     {$endif bThumbs}
      SyncCmdClose       :
        if ModalDlg = nil then
          Review.CloseWindow;

      SyncCmdUpdateTitle :
        begin
         {$ifdef bThumbs}
          if ThumbsModalDlg <> nil then
            ThumbsModalDlg.UpdateTitle;
         {$endif bThumbs}
          if ModalDlg <> nil then
            ModalDlg.UpdateTitle;
        end;

    else
      if AParam <> nil then
        with TCmdObject(AParam) do begin
          Execute;
          Destroy;
        end;
    end;
  end;


initialization
finalization
end.

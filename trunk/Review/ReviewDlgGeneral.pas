{$I Defines.inc}

unit ReviewDlgGeneral;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* Review                                                                     *}
{* Image Viewer Plugn for Far 2/3                                             *}
{******************************************************************************}

interface

  uses
    Windows,
    MultiMon,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixWin,

    Far_API,
    FarCtrl,
    FarPlug,
    FarDlg,

    ReviewConst,
    ReviewDecoders,
    ReviewClasses,
    ReviewGDIPlus;


  type
    TConfigDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      procedure EnableCommands;
    end;


  function ReviewConfig :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


(*
  procedure TReviewManager.MainSetup;
  var
    vMenu :TFarMenu;
    vModified :Boolean;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMProcessView),
      GetMsg(strMProcessQView),
      GetMsg(strMAsyncQView),
      GetMsg(strMFrameQView),
      GetMsg(strMPrecache)
    ]);
    try
      vModified := False;
      while True do begin

        vMenu.Checked[0] := optProcessView;
        vMenu.Checked[1] := optProcessQView;
        vMenu.Checked[2] := optAsyncQView;
        vMenu.Checked[3] := optQViewShowFrame;
        vMenu.Checked[4] := optPrecache;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0 : optProcessView := not optProcessView;
          1 : optProcessQView := not optProcessQView;
          2 : optAsyncQView := not optAsyncQView;
          3 : optQViewShowFrame := not optQViewShowFrame;
          4 : optPrecache := not optPrecache;
        end;
        vModified := True;
      end;

      if vModified then
        PluginConfig(True);

    finally
      FreeObj(vMenu);
    end;
  end;
*)


 {-----------------------------------------------------------------------------}
 { TConfigDlg                                                                  }
 {-----------------------------------------------------------------------------}

  const
    IdFrame         = 0;

    IdPrefixEdt     = 2;

    IdViewChk       = 3;
    IdQViewChk      = 4;
    IdAsyncChk      = 5;
    IdDelayLab      = 6;
    IdDelayEdt      = 7;
    IdFrameChk      = 8;

    IdPrecacheChk   = 9;
    IdKeepZoomChk   = 10;

    IdThumnailChk   = 12;
    IdScreenSizeChk = 13;
    IdAutorotateChk = 14;
    IdKeepDateChk   = 15;

    IdOk            = 17;
    IdCancel        = 18;


  procedure TConfigDlg.Prepare; {override;}
  const
    DX = 60;
    DY = 20;
  var
    X1 :Integer;
  begin
    FGUID := cConfigDlgID;
    FHelpTopic := 'Config';

    FWidth := DX;
    FHeight := DY;
    X1 := 5;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,  3,  1,   DX-6, DY-2, 0, GetMsg(strGeneralTitle)),

        NewItem(DI_Text,      -X1,  -2,    0, 0,   0,  GetMsg(strProcessed) ),
        NewItem(DI_Edit,        1,   0,   +5, 0,   0),

        NewItem(DI_CheckBox,  -X1-1, 1,    0, 0,   0,  GetMsg(strProcessView) ),
        NewItem(DI_CheckBox,  -X1-1, 1,    0, 0,   0,  GetMsg(strProcessQView) ),
        NewItem(DI_CheckBox,  -X1-4, 1,    0, 0,   0,  GetMsg(strAsyncQView) ),

        NewItem(DI_Text,        1,   0,    0, 0,   DIF_HIDDEN,  'Delay:' ),
        NewItem(DI_Edit,        1,   0,   +5, 0,   DIF_HIDDEN),
//      NewItem(DI_Text,        1,   0,   +5, 0,   DIF_HIDDEN,  'msec'),

        NewItem(DI_CheckBox,  -X1-4, 1,    0, 0,   0,  GetMsg(strFrameQView) ),

        NewItem(DI_CheckBox,  -X1,   2,    0, 0,   0,  GetMsg(strPrecache) ),
        NewItem(DI_CheckBox,  -X1,   1,    0, 0,   0,  GetMsg(strKeepZoom) ),

        NewItem(DI_Text,      -X1,   2,    0, 0,   0,  GetMsg(strInternalDecoder) ),
        NewItem(DI_CheckBox,  -X1-1, 1,    0, 0,   0,  GetMsg(strUseThumbnail) ),
        NewItem(DI_CheckBox,  -X1-1, 1,    0, 0,   0,  GetMsg(strDecodeScreenSize) ),
        NewItem(DI_CheckBox,  -X1-1, 1,    0, 0,   0,  GetMsg(strAutorotate) ),
        NewItem(DI_CheckBox,  -X1-1, 1,    0, 0,   0,  GetMsg(strKeepDate) ),

        NewItemApi(DI_Text,      0, DY-4,  0, 0, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strCancel) )
      ],
      @FItemCount
    );
  end;


  procedure TConfigDlg.InitDialog; {override;}
  begin
    SetText(IdPrefixEdt, optCmdPrefix);

    SetChecked(IdViewChk, optProcessView);
    SetChecked(IdQViewChk, optProcessQView);

    SetChecked(IdAsyncChk, optAsyncQView);
    SetChecked(IdFrameChk, optQViewShowFrame);

    SetChecked(IdPrecacheChk, optPrecache);
    SetChecked(IdKeepZoomChk, optKeepScale);

    SetChecked(IdThumnailChk, optUseThumbnail);
    SetChecked(IdScreenSizeChk, optUseWinSize);
    SetChecked(IdAutorotateChk, optRotateOnEXIF);
    SetChecked(IdKeepDateChk, optKeepDateOnSave);

    EnableCommands;
  end;


  function TConfigDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      optCmdPrefix := GetText(IdPrefixEdt);

      optProcessView := GetChecked(IdViewChk);
      optProcessQView := GetChecked(IdQViewChk);

      optAsyncQView := GetChecked(IdAsyncChk);
      optQViewShowFrame := GetChecked(IdFrameChk);

      optPrecache := GetChecked(IdPrecacheChk);
      optKeepScale := GetChecked(IdKeepZoomChk);

      optUseThumbnail := GetChecked(IdThumnailChk);
      optUseWinSize := GetChecked(IdScreenSizeChk);
      optRotateOnEXIF := GetChecked(IdAutorotateChk);
      optKeepDateOnSave := GetChecked(IdKeepDateChk);
    end;
    Result := True;
  end;


  procedure TConfigDlg.EnableCommands;
  var
    vQView :Boolean;
  begin
    vQView := GetChecked(IdQViewChk);
    SetEnabled(IdAsyncChk, vQView);
    SetEnabled(IdFrameChk, vQView);
  end;


  function TConfigDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      0: {};
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TConfigDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 = IdQViewChk then
          EnableCommands
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function ReviewConfig :Boolean;
  var
    vDlg :TConfigDlg;
  begin
    vDlg := TConfigDlg.Create;
    try
      Result := vDlg.Run = IdOk;
      if Result then
        PluginConfig(True);
    finally
      FreeObj(vDlg);
    end;
  end;


end.


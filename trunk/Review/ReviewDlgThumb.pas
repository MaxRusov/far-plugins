{$I Defines.inc}

unit ReviewDlgThumb;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
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
    TThumbConfigDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      procedure EnableCommands;
    end;


  function ThumbConfig :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    cPriorityStrs :array[0..4] of TString =
      ('System, Review', 'Review, System', 'System only', 'Review only', 'None');


 {-----------------------------------------------------------------------------}
 { TThumbConfigDlg                                                             }
 {-----------------------------------------------------------------------------}

  const
    IdFrame          = 0;

    IdShowTitleChk   = 1;
    IdFoldTitleChk   = 2;
    IdMouseSelectChk = 3;

//  IdVertScrollChk  = 4;
    IdVertScrollRbn  = 4;
    IdHorzScrollRbn  = 5;

    IdPriorityLab    = 6;
    IdPriorityCmb    = 7;

    IdOk             = 9;
    IdCancel         = 10;


  procedure TThumbConfigDlg.Prepare; {override;}
  const
    DX = 60;
    DY = 15;
  var
    X1 :Integer;
  begin
    FGUID := cConfigDlgID;
    FHelpTopic := 'ThumbConfig';

    FWidth := DX;
    FHeight := DY;
    X1 := 5;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,  3,  1,   DX-6, DY-2, 0, GetMsg(strThumbConfigTitle)),

        NewItem(DI_CheckBox,  -X1,  -2,    0, 0,   0,  GetMsg(strShowThumbTitle)),
        NewItem(DI_CheckBox,  -X1-3, 1,    0, 0,   0,  GetMsg(strFoldThumbTitle) ),
        NewItem(DI_CheckBox,  -X1,   1,    0, 0,   0,  GetMsg(strThumbMouseSelect) ),

//      NewItem(DI_CheckBox,  -X1,   1,   0,  0,  0,  'Вертикальная прокрутка' ),
        NewItem(DI_RADIOBUTTON, -X1, 2,   0,  0,  0,  GetMsg(strThumbVertScroll) ),
        NewItem(DI_RADIOBUTTON, -X1, 1,   0,  0,  0,  GetMsg(strThumbHorzScroll) ),

        NewItem(DI_Text,      -X1,   2,    0, 0,   0,  GetMsg(strExtractPriority) ),
        NewItem(DI_ComboBox,    1,   0,   20, 0,   DIF_DROPDOWNLIST),

        NewItemApi(DI_Text,      0, DY-4,  0, 0, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strCancel) )
      ],
      @FItemCount
    );
  end;


  procedure TThumbConfigDlg.InitDialog; {override;}
  var
    vPriority :Integer;
  begin
    SetListItems(IdPriorityCmb, [cPriorityStrs[0], cPriorityStrs[1], cPriorityStrs[2], cPriorityStrs[3], cPriorityStrs[4]]);

    SetChecked(IdShowTitleChk, optThumbShowTitle);
    SetChecked(IdFoldTitleChk, optThumbFoldTitle);
    SetChecked(IdMouseSelectChk, optMouseSelect);
    
//  SetChecked(IdVertScrollChk, optVerticalScroll);
    if optVerticalScroll then
      SetChecked(IdVertScrollRbn, True)
    else
      SetChecked(IdHorzScrollRbn, True);

    vPriority := IntIf(optExtractPriority = 0, 4, optExtractPriority - 1);
    SetListIndex(IdPriorityCmb, vPriority);
    SetText(IdPriorityCmb, cPriorityStrs[vPriority]);

    EnableCommands;
  end;


  function TThumbConfigDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vPriority :Integer;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      optThumbShowTitle := GetChecked(IdShowTitleChk);
      optThumbFoldTitle := GetChecked(IdFoldTitleChk);
      optMouseSelect    := GetChecked(IdMouseSelectChk);

//    optVerticalScroll := GetChecked(IdVertScrollChk);
      optVerticalScroll := GetChecked(IdVertScrollRbn);

      vPriority := SendMsg(DM_LISTGETCURPOS, IdPriorityCmb, 0);
      optExtractPriority := IntIf(vPriority = 4, 0, vPriority + 1);
    end;
    Result := True;
  end;


  procedure TThumbConfigDlg.EnableCommands;
  var
    vShowTitle :Boolean;
  begin
    vShowTitle := GetChecked(IdShowTitleChk);
    SetEnabled(IdFoldTitleChk, vShowTitle);
    if not vShowTitle then
      SetChecked(IdFoldTitleChk, False);
  end;


  function TThumbConfigDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 = IdShowTitleChk then
          EnableCommands
        else
          Result := inherited DialogHandler(Msg, Param1, Param2)
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function ThumbConfig :Boolean;
  var
    vDlg :TThumbConfigDlg;
  begin
    vDlg := TThumbConfigDlg.Create;
    try
      Result := vDlg.Run = IdOk;
      if Result then
        PluginConfig(True);
    finally
      FreeObj(vDlg);
    end;
  end;


end.


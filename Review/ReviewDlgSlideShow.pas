{$I Defines.inc}

unit ReviewDlgSlideShow;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
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

    Far_API,
    FarCtrl,
    FarPlug,
    FarDlg,

    ReviewConst,
    ReviewClasses;


  type
    TShowConfigDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      procedure EnableCommands;
    end;


  function SlideShowConfig :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    cEffectNames :array[0..2] of TString;

 {-----------------------------------------------------------------------------}
 { TShowConfigDlg                                                              }
 {-----------------------------------------------------------------------------}

  const
    IdFrame          =  0;

    IdDelayEdt       =  2;

    IdEffectTypeCmb  =  5;
    IdEffectDelayLab =  6;
    IdEffectDelayEdt =  7;

    IdOk             =  9;
    IdCancel         = 10;


  procedure TShowConfigDlg.Prepare; {override;}
  const
    DX = 55;
    DY = 10;
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
        NewItemApi(DI_DoubleBox,  3,  1,   DX-6, DY-2, 0, GetMsg(strSSConfigTitle)),

        NewItem(DI_Text,      -X1,  -2,    0, 0,   0,  GetMsg(strSSShowDelay)),
        NewItem(DI_Edit,        1,   0,   +5, 0,   0),

//      NewItem(DI_Text,      -X1,   1,    0, 0,   0,  GetMsg(strSSMediaFiles)),
//      NewItem(DI_ComboBox,  -X1,   1,   20, 0,   DIF_DROPDOWNLIST),

        NewItem(DI_Text,      -X1,   1,  0, 0, DIF_SEPARATOR),

        NewItem(DI_Text,      -X1,   1,    0, 0,   0,  GetMsg(strSSEffect)),
        NewItem(DI_ComboBox,  -X1,   1,   20, 0,   DIF_DROPDOWNLIST),
        NewItem(DI_Text,        2,   0,    0, 0,   0,  GetMsg(strSSEffectDelay)),
        NewItem(DI_Edit,        1,   0,   +5, 0,   0),

        NewItemApi(DI_Text,      0, DY-4,  0, 0, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strCancel) )
      ],
      @FItemCount
    );
  end;


  procedure TShowConfigDlg.InitDialog; {override;}
  begin
    cEffectNames[0] := GetMsg(strSSNoEffect);
    cEffectNames[1] := GetMsg(strSSFade);
    cEffectNames[2] := GetMsg(strSSSlide);  

    SetListItems(IdEffectTypeCmb, [cEffectNames[0], cEffectNames[1], cEffectNames[2]]);

    SetText(IdDelayEdt, Int2Str(optSlideDelay div 1000));
    SetListIndex(IdEffectTypeCmb, optEffectType);
    SetText(IdEffectTypeCmb, cEffectNames[optEffectType]);
    SetText(IdEffectDelayEdt, Int2Str(optEffectPeriod));

    EnableCommands;
  end;


  function TShowConfigDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  const
    cMaxSec = 9;
  var
    vDelay1, vDelay2 :Integer;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin

      vDelay1 := Str2IntDef(GetText(IdDelayEdt), -1);
      if (vDelay1 < 1) or (vDelay1 > cMaxSec) then begin
        SendMsg(DM_SetFocus, IdDelayEdt, 0);
        AppErrorIdFmt(strValidRangeError, [1, cMaxSec]);
      end;

      vDelay2 := Str2IntDef(GetText(IdEffectDelayEdt), -1);
      if (vDelay2 < 1) or (vDelay2 > cMaxSec * 1000) then begin
        SendMsg(DM_SetFocus, IdEffectDelayEdt, 0);
        AppErrorIdFmt(strValidRangeError, [1, cMaxSec * 1000]);
      end;

      optSlideDelay := vDelay1 * 1000;
      optEffectPeriod := vDelay2;
      optEffectType := SendMsg(DM_LISTGETCURPOS, IdEffectTypeCmb, 0);
    end;
    Result := True;
  end;


  procedure TShowConfigDlg.EnableCommands;
  var
    vEffectType :Integer;
  begin
    vEffectType := SendMsg(DM_LISTGETCURPOS, IdEffectTypeCmb, 0);
//  TraceF('vEffectType=%d', [vEffectType]);
    SetEnabled(IdEffectDelayLab, vEffectType <> 0);
    SetEnabled(IdEffectDelayEdt, vEffectType <> 0);
  end;


  function TShowConfigDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_LISTCHANGE:
        if Param1 = IdEffectTypeCmb then
          EnableCommands
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function SlideShowConfig :Boolean;
  var
    vDlg :TShowConfigDlg;
  begin
    vDlg := TShowConfigDlg.Create;
    try
      Result := vDlg.Run = IdOk;
      if Result then
        PluginConfig(True);
    finally
      FreeObj(vDlg);
    end;
  end;


end.


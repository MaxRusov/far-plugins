{$I Defines.inc}

unit ReviewDlgDecoder;

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
    ReviewClasses;


  type
    TDecoderDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FDecoder   :TReviewDecoder;

      procedure UpdateDecoderInfo;
    end;


  function DecoderConfig(aDecoder :TReviewDecoder) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TDecoderDlg                                                                 }
 {-----------------------------------------------------------------------------}

  const
    IdFrame        = 0;

    IdLabel1       = 1;
    IdTitle        = 2;
    IdLabel2       = 3;
    IdComment      = 4;

    IdEnabledChk   = 6;
    IdReset        = 7;
    IdActiveEdt    = 9;
    IdOk           = 11;
    IdCancel       = 12;
    IdLoad         = 13;


  procedure TDecoderDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 13;
  begin
    FGUID := cDecoderDlgID;
    FHelpTopic := 'Decoder';

    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strDecoderTitle)),

        NewItemApi(DI_Text,      5,  2, -1,    -1, 0, GetMsg(strTitleLabel) ),
//      NewItemApi(DI_Edit,     16,  2, DX-21, -1, DIF_READONLY),
        NewItemApi(DI_Text,     16,  2, DX-21, -1, 0),

        NewItemApi(DI_Text,      5,  3, -1,    -1, 0, GetMsg(strCommentLabel) ),
//      NewItemApi(DI_Edit,     16,  3, DX-21, -1, DIF_READONLY),
        NewItemApi(DI_Text,     16,  3, DX-21, -1, 0),

        NewItemApi(DI_Text,      0,  4, -1, -1, DIF_SEPARATOR),

        NewItemApi(DI_CheckBox,  5,  5, -1, -1,   0,  GetMsg(strEnabled) ),

        NewItemApi(DI_Button,   DX-15, 7, -1, -1, {DIF_NOFOCUS or DIF_BTNNOCLOSE}0, 'Reset'),

        NewItemApi(DI_Text,      5,  7, -1,    -1, 0, GetMsg(strExtensions) ),
        NewItemApi(DI_Edit,      5,  8, DX-11, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cMaskHistory ),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton,0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strLoad) )
      ],
      @FItemCount
    );
  end;


  procedure TDecoderDlg.InitDialog; {override;}
  begin
    UpdateDecoderInfo;
  end;


  procedure TDecoderDlg.UpdateDecoderInfo;
  var
    vStr :TString;
  begin
    vStr := GetMsg(strDecoderTitle) + ' (' + FDecoder.Name + ')';
    SetText(IdFrame, vStr);

    vStr := StrIf(FDecoder.Title <> '', FDecoder.Title, FDecoder.Name);
    if FDecoder.Version <> '' then
      vStr := vStr + ', ' + GetMsg(strVersion) + ' ' + FDecoder.Version;
    SetText(IdTitle, vStr);

    case FDecoder.GetState of
      rdsInternal, rdsLoaded:
        vStr := FDecoder.Comment;
      rdsCached:
        vStr := GetMsg(strNotLoaded);
      rdsError: begin
        vStr := GetMsg(strLoadError);
        if FDecoder is TReviewDllDecoder then
          vStr := vStr + ': ' + TReviewDllDecoder(FDecoder).InitErrorMess;
      end;
    end;
    SetText(IdComment, vStr);

    SetChecked(IdEnabledChk, FDecoder.Enabled);

    SetText(IdActiveEdt, FDecoder.GetMaskAsStr);
    SetEnabled(IdReset, FDecoder.CustomMask);

    SetEnabled(IdLoad, FDecoder.GetState = rdsCached);
  end;


  function TDecoderDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vStr :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      FDecoder.Enabled := GetChecked(IdEnabledChk);
      vStr := GetText(IdActiveEdt);
      if not StrEqual(vStr, FDecoder.GetMaskAsStr) then begin
        FDecoder.SetExtensions(
          ExtractWord(1, vStr, ['|']),
          ExtractWord(2, vStr, ['|']));
        FDecoder.CustomMask := True;
      end;
    end;
    Result := True;
  end;


  function TDecoderDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      0: {};
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TDecoderDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocLoadPlugin;
    begin
      FDecoder.CanWork(True);
      UpdateDecoderInfo;
    end;

    procedure LocResetPlugin;
    begin
      FDecoder.ResetSettings;
      UpdateDecoderInfo;
      SendMsg(DM_SetFocus, IdActiveEdt, 0)
    end;

  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 = IdReset then
          LocResetPlugin
        else  
        if Param1 = IdLoad then
          LocLoadPlugin
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function DecoderConfig(aDecoder :TReviewDecoder) :Boolean;
  var
    vDlg :TDecoderDlg;
  begin
    vDlg := TDecoderDlg.Create;
    try
      vDlg.FDecoder := aDecoder;
      Result := vDlg.Run = IdOk;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


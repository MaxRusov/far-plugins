{$I Defines.inc}

unit EdtReplaceDlg;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

    PluginW,
    FarKeysW,
    FarCtrl,
    FarDlg,

    EdtFindCtrl,
    EdtFindDlg;


  type
    TReplaceDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FInitExpr   :TString;

      procedure EnableControls;
    end;

  function ReplaceDlg(APickWord :Boolean; var AFromBeg :Boolean) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TReplaceDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TReplaceDlg.Create; {override;}
  begin
    inherited Create;
  end;


  destructor TReplaceDlg.Destroy; {override;}
  begin
    inherited Destroy;
  end;



  const
    IdFrame        = 0;
    IdFindEdt      = 2;
    IdReplaceEdt   = 4;
    IdCaseSensChk  = 6;
    IdWholeWordChk = 7;
    IdRegexpChk    = 8;
    IdPromptChk    = 9;
    IdFromBeg      = 12;
    IdCancel       = 13;
//  IdOptions      = 14;

    
  procedure TReplaceDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 14;
  var
    vX2 :Integer;
  begin
    FHelpTopic := 'Replace';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 14;
    vX2 := DX div 2;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strReplace)),

        NewItemApi(DI_Text,     5,   2,   DX-10,  -1,   0, GetMsg(strSearchFor) ),
        NewItemApi(DI_Edit,     5,   3,   DX-10,  -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFindHistory ),

        NewItemApi(DI_Text,     5,   4,   DX-10,  -1,   0, GetMsg(strReplaceWith) ),
        NewItemApi(DI_Edit,     5,   5,   DX-10,  -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cReplHistory ),

        NewItemApi(DI_Text,     0,   6,   -1,    -1,   DIF_SEPARATOR),

        NewItemApi(DI_CheckBox, 5,   7,  -1,   -1,   0, GetMsg(strCaseSens)),
        NewItemApi(DI_CheckBox, 5,   8,  -1,   -1,   0, GetMsg(strWholeWords)),
        NewItemApi(DI_CheckBox, 5,   9,  -1,   -1,   0, GetMsg(strRegExp)),

        NewItemApi(DI_CheckBox, vX2, 7,  -1,   -1,   0, GetMsg(strPromptOnReplace)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strFromBegBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
//      NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strOptionsBut) )
      ]
    );
  end;


  procedure TReplaceDlg.InitDialog; {override;}
  begin
    if FInitExpr <> '' then
      SetText(IdFindEdt, FInitExpr);

    SetChecked(IdCaseSensChk, foCaseSensitive in gOptions);
    SetChecked(IdWholeWordChk, foWholeWords in gOptions);
    SetChecked(IdRegexpChk, foRegexp in gOptions);
    SetChecked(IdPromptChk, foPromptOnReplace in gOptions);
    EnableControls;
  end;


  function TReplaceDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      gStrFind := GetText(IdFindEdt);
      gStrRepl := GetText(IdReplaceEdt);

      SetFindOptions(gOptions, foCaseSensitive, GetChecked(IdCaseSensChk));
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));
      SetFindOptions(gOptions, foPromptOnReplace, GetChecked(IdPromptChk));

      if (foRegexp in gOptions) and (gStrFind <> '') then
        if not CheckRegexp(gStrFind) then
          AppErrorId(strBadRegexp);

    end;
    Result := True;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TReplaceDlg.EnableControls;
  var
    vRegExp :Boolean;
  begin
    vRegExp := GetChecked(IdRegexpChk);
    SendMsg(DM_Enable, IdWholeWordChk, Byte(not vRegExp));
    if vRegExp then
      SetChecked(IdWholeWordChk, False);
  end;


  function TReplaceDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);

    Result := 1;
    case Msg of
//    DN_RESIZECONSOLE:
//      ResizeDialog;

      DN_MOUSECLICK:
        Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_BTNCLICK:
        if Param1 = IdRegexpChk then
          EnableControls
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
          
      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_F9:
            OptionsMenu;
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  procedure TReplaceDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function ReplaceDlg(APickWord :Boolean; var AFromBeg :Boolean) :Boolean;
  var
    vDlg :TReplaceDlg;
    vRes :Integer;
  begin
    vDlg := TReplaceDlg.Create;
    try
      if APickWord then
        vDlg.FInitExpr := GetWordUnderCursor;

      vRes := vDlg.Run;

      AFromBeg := vRes = IdFromBeg;
      Result := (vRes <> -1) and (vRes <> IdCancel);

    finally
      FreeObj(vDlg);
    end;
  end;


end.


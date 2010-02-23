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
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FInitExpr   :TString;

      procedure EnableControls;
      procedure InsertRegexp(AEdtID :Integer);
    end;

  function ReplaceDlg(APickWord :Boolean; var AFromBeg :Boolean) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TReplaceDlg                                                                 }
 {-----------------------------------------------------------------------------}

  const
    IdFrame        = 0;
    IdRegexpBut    = 1;
    IdFindEdt      = 3;
    IdReplaceEdt   = 5;
    IdCaseSensChk  = 7;
    IdWholeWordChk = 8;
    IdRegexpChk    = 9;
    IdPromptChk    = 10;
    IdFromBeg      = 13;
    IdCancel       = 14;
//  IdOptions      = 15;


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
    vX2 := DX div 2;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strReplace)),

//      NewItemApi(DI_Button,   DX-11, 2, -1, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS or DIF_NOFOCUS, 'Rege&xp' {GetMsg(strSearchBut)} ),
        NewItemApi(DI_Text,     DX-11, 2, -1, -1, 0, 'Rege&xp' {GetMsg(strSearchBut)} ),

        NewItemApi(DI_Text,     5,   2,  -1,    -1,   0, GetMsg(strSearchFor) ),
        NewItemApi(DI_Edit,     5,   3,  DX-10, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFindHistory ),

        NewItemApi(DI_Text,     5,   4,  -1,    -1,   0, GetMsg(strReplaceWith) ),
        NewItemApi(DI_Edit,     5,   5,  DX-10, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cReplHistory ),

        NewItemApi(DI_Text,     0,   6,  -1, -1,   DIF_SEPARATOR),

        NewItemApi(DI_CheckBox, 5,   7,  -1, -1,   0, GetMsg(strCaseSens)),
        NewItemApi(DI_CheckBox, 5,   8,  -1, -1,   0, GetMsg(strWholeWords)),
        NewItemApi(DI_CheckBox, 5,   9,  -1, -1,   0, GetMsg(strRegExp)),

        NewItemApi(DI_CheckBox, vX2, 7,  -1, -1,   0, GetMsg(strPromptOnReplace)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strFromBegBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
//      NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strOptionsBut) )
      ],
      @FItemCount
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
    SendMsg(DM_ShowItem, IdRegexpBut, Byte(vRegExp));
  end;


  procedure TReplaceDlg.InsertRegexp(AEdtID :Integer);
  var
    vRes :Boolean;
    vRegexp :TString;
  begin
    vRes := RegexpMenu(vRegexp);
    SendMsg(DM_SetFocus, AEdtID, 0);
    if vRes then
      InsertText(vRegExp);
  end;


  function TReplaceDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_MOUSECLICK, DN_HOTKEY:
        if Param1 = IdRegexpBut then
          InsertRegexp(IdFindEdt)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_BTNCLICK:
        if Param1 = IdRegexpChk then
          EnableControls
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
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


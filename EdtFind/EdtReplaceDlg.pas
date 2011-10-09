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

   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
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

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FAutoInit   :Boolean;
      FInitExpr   :TString;

      procedure EnableControls;
      procedure InsertRegexp(AEdtID :Integer);
    end;

  function ReplaceDlg(APickWord :Boolean; var AEntire :Boolean) :Boolean;

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
   {$ifdef bComboMode}
    IdSubstrChk    = 8;
    IdWholeWordChk = 9;
    IdRegexpChk    = 10;
    IdReverse      = 11;
    IdPromptChk    = 12;
    IdFromBeg      = 15;
    IdCancel       = 16;
//  IdOptions      = 17;
   {$else}
    IdWholeWordChk = 8;
    IdRegexpChk    = 9;
    IdReverse      = 10;
    IdPromptChk    = 11;
    IdFromBeg      = 14;
    IdCancel       = 15;
//  IdOptions      = 16;
   {$endif bComboMode}


  procedure TReplaceDlg.Prepare; {override;}
  const
    DX = 76;
    DY = {$ifdef bComboMode}15{$else}14{$endif bComboMode};
  var
    vX2 :Integer;
  begin
    FGUID := cReplaceDlgID;
    FHelpTopic := 'Replace';
    FWidth := DX;
    FHeight := DY;
    vX2 := DX div 2;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strReplace)),

//      NewItemApi(DI_Text,     DX-11, 2, -1, -1, 0, GetMsg(strInsRegexp)),
        NewItemApi(DI_Button,   DX-11, 2, -1, -1, DIF_NOFOCUS or DIF_BTNNOCLOSE or DIF_NOBRACKETS, GetMsg(strInsRegexp)),

        NewItemApi(DI_Text,     5,   2,  -1,    -1,   0, GetMsg(strSearchFor) ),
        NewItemApi(DI_Edit,     5,   3,  DX-10, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFindHistory ),

        NewItemApi(DI_Text,     5,   4,  -1,    -1,   0, GetMsg(strReplaceWith) ),
        NewItemApi(DI_Edit,     5,   5,  DX-10, -1,   DIF_HISTORY or IntIf(gLastReplEmpty, 0, DIF_USELASTHISTORY), '', cReplHistory ),

        NewItemApi(DI_Text,     0,   6,  -1, -1,   DIF_SEPARATOR),

        NewItemApi(DI_CheckBox,    5,  7, -1, -1, 0, GetMsg(strCaseSens)),

       {$ifdef bComboMode}
        NewItemApi(DI_RADIOBUTTON, 5,  8, -1, -1, 0, GetMsg(strSubstring)),
        NewItemApi(DI_RADIOBUTTON, 5,  9, -1, -1, 0, GetMsg(strWholeWords)),
        NewItemApi(DI_RADIOBUTTON, 5, 10, -1, -1, 0, GetMsg(strRegExp)),
       {$else}
        NewItemApi(DI_CheckBox,    5,  8, -1, -1, 0, GetMsg(strWholeWords)),
        NewItemApi(DI_CheckBox,    5,  9, -1, -1, 0, GetMsg(strRegExp)),
       {$endif bComboMode}

        NewItemApi(DI_CheckBox, vX2, 7, -1, -1, 0, GetMsg(strReverse)),
        NewItemApi(DI_CheckBox, vX2, 8, -1, -1, 0, GetMsg(strPromptOnReplace)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton,0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strEntireBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
//      NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strOptionsBut) )
      ],
      @FItemCount
    );
  end;


  procedure TReplaceDlg.InitDialog; {override;}
  begin
    if FAutoInit then
      SetText(IdFindEdt, FInitExpr);

    SetChecked(IdCaseSensChk, foCaseSensitive in gOptions);
   {$ifdef bComboMode}
    if [foWholeWords, foRegexp] * gOptions = [] then
      SetChecked(IdSubstrChk, True);
    if [foWholeWords, foRegexp] * gOptions = [foWholeWords] then
      SetChecked(IdWholeWordChk, True);
    if [foWholeWords, foRegexp] * gOptions = [foRegexp] then
      SetChecked(IdRegexpChk, True);
   {$else}
    SetChecked(IdWholeWordChk, foWholeWords in gOptions);
    SetChecked(IdRegexpChk, foRegexp in gOptions);
   {$endif bComboMode}
    SetChecked(IdPromptChk, foPromptOnReplace in gOptions);
    EnableControls;
  end;


  function TReplaceDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vStr :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      vStr := GetText(IdFindEdt);

      if GetChecked(IdRegexpChk) and (vStr <> '') then
        if not CheckRegexp(vStr) then
          AppErrorId(strBadRegexp);

      gStrFind := vStr;
      gStrRepl := GetText(IdReplaceEdt);
      gLastReplEmpty := gStrRepl = '';

      SetFindOptions(gOptions, foCaseSensitive, GetChecked(IdCaseSensChk));
     {$ifdef bComboMode}
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));
     {$else}
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));
     {$endif bComboMode}
      SetFindOptions(gOptions, foPromptOnReplace, GetChecked(IdPromptChk));
      gReverse := GetChecked(IdReverse);
    end;
    Result := True;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TReplaceDlg.EnableControls;
  var
    vRegExp :Boolean;
  begin
    vRegExp := GetChecked(IdRegexpChk);
    SendMsg(DM_ShowItem, IdRegexpBut, Byte(vRegExp));
  end;


  procedure TReplaceDlg.InsertRegexp(AEdtID :Integer);
  var
    vRes :Boolean;
    vRegexp :TString;
  begin
//  if SendMsg(DM_GETFOCUS, 0, 0) <> AEdtID then
//    SendMsg(DM_SetFocus, AEdtID, 0);
    vRes := RegexpMenu(vRegexp);
    if vRes then
      InsertText(vRegExp);
  end;


  function TReplaceDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      KEY_CTRLP:
        InsertText(FInitExpr);
      KEY_F9:
        OptionsMenu;
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TReplaceDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
       {$ifdef bComboMode}
        if Param1 in [IdSubstrChk, IdWholeWordChk, IdRegexpChk] then
          EnableControls
        else
       {$else}
        if Param1 = IdWholeWordChk then begin
          if GetChecked(IdWholeWordChk) then
            SetChecked(IdRegexpChk, False);
          EnableControls;
        end else
        if Param1 = IdRegexpChk then begin
          if GetChecked(IdRegexpChk) then
            SetChecked(IdWholeWordChk, False);
          EnableControls;
        end else
       {$endif bComboMode}
        if Param1 = IdRegexpBut then
          InsertRegexp(IdFindEdt)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
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

  function ReplaceDlg(APickWord :Boolean; var AEntire :Boolean) :Boolean;
  var
    vDlg :TReplaceDlg;
    vRes :Integer;
  begin
    vDlg := TReplaceDlg.Create;
    try
      vDlg.FInitExpr := GetWordUnderCursor;
      vDlg.FAutoInit := APickWord;

      vRes := vDlg.Run;

      AEntire := vRes = IdFromBeg;
      Result := (vRes <> -1) and (vRes <> IdCancel);

    finally
      FreeObj(vDlg);
    end;
  end;


end.


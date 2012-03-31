{$I Defines.inc}

unit EdtFileFindDlg;

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

    Far_API,
    FarCtrl,
    FarDlg,

    EdtFindCtrl,
    EdtFindDlg;


  type
    TFileFindDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
      procedure ErrorHandler(E :Exception); override;

    private
      procedure EnableControls;
      procedure InsertRegexp(AEdtID :Integer);
    end;


  function FileFindDlg :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFileFindDlg                                                                }
 {-----------------------------------------------------------------------------}

  const
    IdFrame        = 0;
    IdMaskEdt      = 2;
    IdRegexpBut    = 3;
    IdFindEdt      = 5;

    IdCaseSensChk  = 7;
    IdSubstrChk    = 8;
    IdWholeWordChk = 9;
    IdRegexpChk    = 10;

    IdCodePageBut  = 11;
    IdCodePageLab  = 12;

    IdAreaeBut     = 14;
    IdAreaLab      = 15;

    IdFindHidden   = 16;
    IdFindLinks    = 17;

    IdCancel       = 20;


  procedure TFileFindDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 17;
  var
    vX2 :Integer;
    S1, S2 :TString;
  begin
    FGUID := cReplaceDlgID;
    FHelpTopic := 'Replace';
    FWidth := DX;
    FHeight := DY;
    vX2 := DX div 2;

    S1 := 'Code &Page';
    S2 := '&Area';

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, 'Find file'),

        NewItemApi(DI_Text,     5,   2,  -1,    -1,   0, 'File &masks:' ),
        NewItemApi(DI_Edit,     5,   3,  DX-10, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFileHistory ),

//      NewItemApi(DI_Text,     DX-11, 4, -1, -1, 0, GetMsg(strInsRegexp)),
        NewItemApi(DI_Button,   DX-11, 4, -1, -1, DIF_NOFOCUS or DIF_BTNNOCLOSE or DIF_NOBRACKETS, GetMsg(strInsRegexp)),

        NewItemApi(DI_Text,     5,   4,  -1,    -1,   0, GetMsg(strSearchFor)  ),
        NewItemApi(DI_Edit,     5,   5,  DX-10, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFindHistory ),

        NewItemApi(DI_Text,     0,   6,  -1, -1,   DIF_SEPARATOR),

        NewItemApi(DI_CheckBox,    5,  7, -1, -1, 0, GetMsg(strCaseSens)),

        NewItemApi(DI_RADIOBUTTON, 5,  8, -1, -1, 0, GetMsg(strSubstring)),
        NewItemApi(DI_RADIOBUTTON, 5,  9, -1, -1, 0, GetMsg(strWholeWords)),
        NewItemApi(DI_RADIOBUTTON, 5, 10, -1, -1, 0, GetMsg(strRegExp)),

//      NewItemApi(DI_Text,     5,    12,  -1, -1, 0, 'Code page:' ),
//      NewItemApi(DI_ComboBox, 5+11, 12,  vX2-6-11, -1,   0),

//      NewItemApi(DI_Text,     5,       13,  -1, -1, 0, 'Code page: Ansi' ),
//      NewItemApi(DI_Button,   vX2-7-6, 13,  -1, -1, DIF_BTNNOCLOSE, 'Select'),

        NewItemApi(DI_Button,   5, 12,  -1, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, PTChar(S1)),
        NewItemApi(DI_Text,     5 + length(S1) + 1,  12,  -1, -1, 0, ': Ansi' ),

        NewItemApi(DI_SingleBox, vX2-2, 7, 0, DY-11, 0),
//      NewItemApi(DI_VText, vX2-2, 6, 1, 5, DIF_SEPARATOR2, 'x'),

        NewItemApi(DI_Button,   vX2,                   7,  -1, -1, DIF_BTNNOCLOSE or DIF_NOBRACKETS, PTChar(S2)),
        NewItemApi(DI_Text,     vX2 + length(S2) + 1,  7,  -1, -1, 0, ': From Current folder' ),

        NewItemApi(DI_CheckBox, vX2,  9, -1, -1, 0, 'Search in &hidden files'),
        NewItemApi(DI_CheckBox, vX2, 10, -1, -1, 0, 'Search in symbolic &links'),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton,0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
      ],
      @FItemCount
    );
  end;


  procedure TFileFindDlg.InitDialog; {override;}
  begin
(*
    if FAutoInit then
      SetText(IdFindEdt, FInitExpr);
*)

    SetChecked(IdCaseSensChk, foCaseSensitive in gOptions);
    if [foWholeWords, foRegexp] * gOptions = [] then
      SetChecked(IdSubstrChk, True);
    if [foWholeWords, foRegexp] * gOptions = [foWholeWords] then
      SetChecked(IdWholeWordChk, True);
    if [foWholeWords, foRegexp] * gOptions = [foRegexp] then
      SetChecked(IdRegexpChk, True);
      
    EnableControls;
  end;


  function TFileFindDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vStr :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin

      vStr := GetText(IdMaskEdt);

      vStr := GetText(IdFindEdt);

      if GetChecked(IdRegexpChk) and (vStr <> '') then
        if not CheckRegexp(vStr) then
          AppErrorId(strBadRegexp);

      gStrFind := vStr;

      SetFindOptions(gOptions, foCaseSensitive, GetChecked(IdCaseSensChk));
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));

    end;
    Result := True;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure TFileFindDlg.EnableControls;
  var
    vRegExp :Boolean;
  begin
    vRegExp := GetChecked(IdRegexpChk);
    SendMsg(DM_ShowItem, IdRegexpBut, Byte(vRegExp));
  end;


  procedure TFileFindDlg.InsertRegexp(AEdtID :Integer);
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


  function TFileFindDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      KEY_F9:
        OptionsMenu;
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TFileFindDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 in [IdSubstrChk, IdWholeWordChk, IdRegexpChk] then
          EnableControls
        else
        if Param1 = IdRegexpBut then
          InsertRegexp(IdFindEdt)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  procedure TFileFindDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function FileFindDlg :Boolean;
  var
    vDlg :TFileFindDlg;
    vRes :Integer;
  begin
    vDlg := TFileFindDlg.Create;
    try
      vRes := vDlg.Run;

      Result := (vRes <> -1) and (vRes <> IdCancel);

    finally
      FreeObj(vDlg);
    end;
  end;


end.


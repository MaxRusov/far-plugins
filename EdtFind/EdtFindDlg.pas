{$I Defines.inc}

unit EdtFindDlg;

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
    MixClasses,

    Far_API,
    FarCtrl,
    FarDlg,
    FarMenu,

    EdtFindCtrl;


  type
    TFindMode = (
      efmNormal,
      efmEntire,
      efmGrep,
      efmCount
    );

  type
    TFindDlg = class(TFarDialog)
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

  procedure OptionsMenu;
  function RegexpMenu(var ARegexp :TString) :Boolean;
  function GetWordUnderCursor(ACol :PInteger = nil; APickSelection :boolean = True) :TString;
  function FindDlg(APickWord :Boolean; var AMode :TFindMode) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptions),
    [
      GetMsg(strMSelectFound),
      GetMsg(strMCursorAtEnd),
      GetMsg(strMCenterAlways),
      GetMsg(strMLoopSearch),
      GetMsg(strMShowAllFound),
      GetMsg(strMPersistMatch),
      GetMsg(strMarkWholeTab),
      GetMsg(strMShowProgress),
      GetMsg(strMGroupUndo),
      GetMsg(strAutoXLATMask),
      '',
      GetMsg(strMColors)
    ]);
    try
      vMenu.Help := 'Options';
      while True do begin
        vMenu.Checked[0] := optSelectFound;
        vMenu.Checked[1] := optCursorAtEnd;
        vMenu.Checked[2] := optCenterAlways;
        vMenu.Checked[3] := optLoopSearch;
        vMenu.Checked[4] := optShowAllFound;
        vMenu.Checked[5] := optPersistMatch;
        vMenu.Checked[6] := optMarkWholeTab;
        vMenu.Checked[7] := optShowProgress;
        vMenu.Checked[8] := optGroupUndo;
        vMenu.Checked[9] := optXLatMask;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: optSelectFound := not optSelectFound;
          1: optCursorAtEnd := not optCursorAtEnd;
          2: optCenterAlways := not optCenterAlways;
          3: optLoopSearch := not optLoopSearch;
          4: optShowAllFound := not optShowAllFound;
          5: optPersistMatch := not optPersistMatch;
          6: optMarkWholeTab := not optMarkWholeTab;
          7: optShowProgress := not optShowProgress;
          8: optGroupUndo := not optGroupUndo;
          9: optXLatMask := not optXLatMask;

         11: ColorMenu
        end;

        WriteSetup;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    RegexpList :TStrList;


  procedure InitRegexpList;
  var
    I :Integer;
    vStr :TString;
  begin
    if RegexpList = nil then
      RegexpList := TStrList.Create;
    RegexpList.Clear;

    I := Byte(strRegaexpBase);
    while True do begin
      vStr := FarCtrl.GetMsgStr(I);
      if vStr = '' then
        Break;
      if vStr = '-' then
        vStr := '';
      RegexpList.Add(vStr);
      Inc(I);
    end;
  end;


  function RegexpMenu(var ARegexp :TString) :Boolean;
  var
    I :Integer;
    vMenu :TFarMenu;
    vStrs :array of PFarChar;
  begin
    Result := False;
    if RegexpList = nil then
      InitRegexpList;

    SetLength(vStrs, RegexpList.Count);
    for I := 0 to RegexpList.Count - 1 do
      vStrs[I] := PFarChar(RegexpList.PStrings[I]^);

    vMenu := TFarMenu.CreateEx(
      GetMsg(strRegexpTitle),
      vStrs);
    try
      vMenu.Help := ':RegExp';
      if not vMenu.Run then
        Exit;

      ARegexp := ExtractWord(1, RegexpList[vMenu.ResIdx], [' ']);
      Result := True;

    finally
      FreeObj(vMenu);
    end;
  end;

  
 {-----------------------------------------------------------------------------}
 { TFindDlg                                                                    }
 {-----------------------------------------------------------------------------}

  const
    IdFrame        = 0;
    IdRegexpBut    = 1;
    IdFindEdt      = 3;
    IdCaseSensChk  = 5;
   {$ifdef bComboMode}
    IdSubstrChk    = 6;
    IdWholeWordChk = 7;
    IdRegexpChk    = 8;
    IdReverse      = 9;
    IdSearch       = 11;
    IdFromBeg      = 12;
    IdFindAll      = 13;
    IdCount        = 14;
    IdCancel       = 15;
//  IdOptions      = 16;
   {$else}
    IdWholeWordChk = 6;
    IdRegexpChk    = 7;
    IdReverse      = 8;
    IdSearch       = 10;
    IdFromBeg      = 11;
    IdFindAll      = 12;
    IdCount        = 13;
    IdCancel       = 14;
//  IdOptions      = 15;
   {$endif bComboMode}


  procedure TFindDlg.Prepare; {override;}
  const
    DX = 76;
    DY = {$ifdef bComboMode}13{$else}12{$endif bComboMode};
  var
    vX2 :Integer;
  begin
    FGUID := cFindDlgID;
    FHelpTopic := 'Find';
    FWidth := DX;
    FHeight := DY;
    vX2 := DX div 2;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strFind)),

//      NewItemApi(DI_Text,     DX-11, 2, -1, -1, 0, GetMsg(strInsRegexp)),
        NewItemApi(DI_Button,   DX-11, 2, -1, -1, DIF_NOFOCUS or DIF_BTNNOCLOSE or DIF_NOBRACKETS, GetMsg(strInsRegexp)),

        NewItemApi(DI_Text,     5,  2, -1,    -1, 0, GetMsg(strSearchFor) ),
        NewItemApi(DI_Edit,     5,  3, DX-10, -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFindHistory ),

        NewItemApi(DI_Text,     0,  4, -1, -1,   DIF_SEPARATOR),

        NewItemApi(DI_CheckBox,    5,  5, -1, -1,   0, GetMsg(strCaseSens)),

       {$ifdef bComboMode}
        NewItemApi(DI_RADIOBUTTON, 5,  6, -1, -1, 0, GetMsg(strSubstring)),
        NewItemApi(DI_RADIOBUTTON, 5,  7, -1, -1, 0, GetMsg(strWholeWords)),
        NewItemApi(DI_RADIOBUTTON, 5,  8, -1, -1, 0, GetMsg(strRegExp)),
       {$else}
        NewItemApi(DI_CheckBox,    5,  6, -1, -1, 0, GetMsg(strWholeWords)),
        NewItemApi(DI_CheckBox,    5,  7, -1, -1, 0, GetMsg(strRegExp)),
       {$endif bComboMode}

        NewItemApi(DI_CheckBox, vX2, 5, -1, -1,  0, GetMsg(strReverse)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton,0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strEntireBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strShowAllBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCountBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
//      NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strOptionsBut) )
      ],
      @FItemCount
    );
  end;


  procedure TFindDlg.InitDialog; {override;}
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

    EnableControls;
  end;


  function TFindDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vStr :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      vStr := GetText(IdFindEdt);

      if GetChecked(IdRegexpChk) and (vStr <> '') then
        if not CheckRegexp(vStr) then
          AppErrorId(strBadRegexp);

      gStrFind := vStr;

      SetFindOptions(gOptions, foCaseSensitive, GetChecked(IdCaseSensChk));
     {$ifdef bComboMode}
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));
     {$else}
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));
     {$endif bComboMode}

      gReverse := GetChecked(IdReverse);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFindDlg.EnableControls;
  var
    vRegExp :Boolean;
  begin
    vRegExp := GetChecked(IdRegexpChk);
    SendMsg(DM_ShowItem, IdRegexpBut, Byte(vRegExp));
  end;


  procedure TFindDlg.InsertRegexp(AEdtID :Integer);
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


  function TFindDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
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


  function TFindDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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


  procedure TFindDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function IsWordChar(const AChr :TChar) :Boolean;
  begin
    Result := CharIsWordChar(AChr) {or (AChr = '.')};
  end;


  function GetWordUnderCursor(ACol :PInteger = nil; APickSelection :boolean = True) :TString;
  var
    vInfo :TEditorInfo;
    vStrInfo :TEditorGetString;
    vStr :TString;
    vPos, vBeg :Integer;
  begin
    Result := '';
    FillZero(vInfo, SizeOf(vInfo));
    if FarEditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      vStrInfo.StringNumber := -1;
      if FarEditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
        with vStrInfo do begin
          vStr := StringText;
          if vStr = '' then
            Exit;
          if APickSelection and (SelStart >= 0) then begin
            Result := Copy(vStr, SelStart + 1, SelEnd - SelStart);
            if ACol <> nil then
              ACol^ := SelStart;
          end else
          begin
            vPos := IntMin(vInfo.CurPos + 1, Length(vStr) + 1);
            while (vPos > 1) and IsWordChar(vStr[vPos - 1]) do
              Dec(vPos);
            if (vPos <= Length(vStr)) and IsWordChar(vStr[vPos]) then begin
              vBeg := vPos;
              while (vPos <= Length(vStr)) and IsWordChar(vStr[vPos]) do
                Inc(vPos);
              Result := Copy(vStr, vBeg, vPos - vBeg);
              if ACol <> nil then
                ACol^ := vBeg - 1;
            end;
          end;
        end;
      end;
    end;
  end;


  function FindDlg(APickWord :Boolean; var AMode :TFindMode) :Boolean;
  var
    vDlg :TFindDlg;
    vRes :Integer;
  begin
    vDlg := TFindDlg.Create;
    try
      vDlg.FInitExpr := GetWordUnderCursor;
      vDlg.FAutoInit := APickWord;

      vRes := vDlg.Run;

      Result := (vRes <> -1) and (vRes <> IdCancel);
      if not Result then
        Exit;

      AMode := efmNormal;
      case vRes of
        IdFromBeg : AMode := efmEntire;
        IdFindAll : AMode := efmGrep;
        IdCount   : AMode := efmCount;
      end;

    finally
      FreeObj(vDlg);
    end;
  end;
  

initialization

finalization
  FreeObj(RegexpList);
end.
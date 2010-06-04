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

    PluginW,
    FarKeysW,
    FarCtrl,
    FarDlg,
    FarColorDlg,

    EdtFindCtrl;


  type
    TFindDlg = class(TFarDialog)
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

  procedure OptionsMenu;
  function RegexpMenu(var ARegexp :TString) :Boolean;
  function GetWordUnderCursor(ACol :PInteger = nil; APickSelection :boolean = True) :TString;
  function FindDlg(APickWord :Boolean; var AEntire, ACount :Boolean) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function EdtColorDlg(const ASample :TString; var AColor :Integer) :Boolean;
  begin
    ColorDlgResBase := Byte(strColorDialog);
    Result := ColorDlg('', AColor);
    if Result then
      FARAPI.EditorControl(ECTL_REDRAW, nil);
  end;


  procedure OptionsMenu;
  const
    cMenuCount = 10;
  var
    vRes, I :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strMSelectFound));
      SetMenuItemChrEx(vItem, GetMsg(strMCursorAtEnd));
      SetMenuItemChrEx(vItem, GetMsg(strMCenterAlways));
      SetMenuItemChrEx(vItem, GetMsg(strMLoopSearch));
      SetMenuItemChrEx(vItem, GetMsg(strMShowAllFound));
      SetMenuItemChrEx(vItem, GetMsg(strMPersistMatch));
      SetMenuItemChrEx(vItem, GetMsg(strMShowProgress));
      SetMenuItemChrEx(vItem, GetMsg(strMGroupUndo));
      SetMenuItemChrEx(vItem, GetMsg(strMFoundColor));
      SetMenuItemChrEx(vItem, GetMsg(strMMatchColor));

      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, optSelectFound);
        vItems[1].Flags := SetFlag(0, MIF_CHECKED1, optCursorAtEnd);
        vItems[2].Flags := SetFlag(0, MIF_CHECKED1, optCenterAlways);
        vItems[3].Flags := SetFlag(0, MIF_CHECKED1, optLoopSearch);
        vItems[4].Flags := SetFlag(0, MIF_CHECKED1, optShowAllFound);
        vItems[5].Flags := SetFlag(0, MIF_CHECKED1, optPersistMatch);
        vItems[6].Flags := SetFlag(0, MIF_CHECKED1, optShowProgress);
        vItems[7].Flags := SetFlag(0, MIF_CHECKED1, optGroupUndo);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strOptions),
          '',
          'Options',
          nil, nil,
          Pointer(vItems),
          cMenuCount);

        if vRes = -1 then
          Exit;

        case vRes of
          0: optSelectFound := not optSelectFound;
          1: optCursorAtEnd := not optCursorAtEnd;
          2: optCenterAlways := not optCenterAlways;
          3: optLoopSearch := not optLoopSearch;
          4: optShowAllFound := not optShowAllFound;
          5: optPersistMatch := not optPersistMatch;
          6: optShowProgress := not optShowProgress;
          7: optGroupUndo := not optGroupUndo;
          8: EdtColorDlg('', optCurFindColor);
          9: EdtColorDlg('', optMatchColor);
        end;

        WriteSetup;
      end;

    finally
      MemFree(vItems);
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
    I, vRes :Integer;
    vStr :TString;
    vItems :PFarMenuItemsArray;
  begin
    Result := False;
    if RegexpList = nil then
      InitRegexpList;

    vItems := MemAllocZero(RegexpList.Count * SizeOf(TFarMenuItemEx));
    try
      for I := 0 to RegexpList.Count - 1 do begin
        vStr := RegexpList[I];
        SetMenuItemStr(@vItems[I], vStr, IntIf(vStr <> '', 0, MIF_SEPARATOR));
      end;

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(strRegexpTitle),
        '',
        ':RegExp',
        nil, nil,
        Pointer(vItems),
        RegexpList.Count);

      if vRes <> -1 then begin
        ARegexp := ExtractWord(1, RegexpList[vRes], [' ']);
        if ARegexp[1] = '\' then
          ARegexp := '\' + ARegexp;
        Result := True;
      end;

    finally
      CleanupMenu(@vItems[0], RegexpList.Count);
      MemFree(vItems);
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
    IdFromBeg      = 12;
    IdCount        = 13;
    IdCancel       = 14;
//  IdOptions      = 15;
   {$else}
    IdWholeWordChk = 6;
    IdRegexpChk    = 7;
    IdReverse      = 8;
    IdFromBeg      = 11;
    IdCount        = 12;
    IdCancel       = 13;
//  IdOptions      = 14;
   {$endif bComboMode}


  procedure TFindDlg.Prepare; {override;}
  const
    DX = 76;
    DY = {$ifdef bComboMode}13{$else}12{$endif bComboMode};
  var
    vX2 :Integer;
  begin
    FHelpTopic := 'Find';
    FWidth := DX;
    FHeight := DY;
    vX2 := DX div 2;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strFind)),

        NewItemApi(DI_Text,     DX-11, 2, -1, -1, 0, GetMsg(strInsRegexp)),

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
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strEntireBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCountBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
//      NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strOptionsBut) )
      ],
      @FItemCount
    );
  end;


  procedure TFindDlg.InitDialog; {override;}
  begin
    if FInitExpr <> '' then
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
    vRes := RegexpMenu(vRegexp);
    SendMsg(DM_SetFocus, AEdtID, 0);
    if vRes then
      InsertText(vRegExp);
  end;


  function TFindDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_MOUSECLICK, DN_HOTKEY:
        if Param1 = IdRegexpBut then
          InsertRegexp(IdFindEdt)
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

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
    FillChar(vInfo, SizeOf(vInfo), 0);
    if FARAPI.EditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      vStrInfo.StringNumber := -1;
      if FARAPI.EditorControl(ECTL_GETSTRING, @vStrInfo) = 1 then begin
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


  function FindDlg(APickWord :Boolean; var AEntire, ACount :Boolean) :Boolean;
  var
    vDlg :TFindDlg;
    vRes :Integer;
  begin
    vDlg := TFindDlg.Create;
    try
      if APickWord then
        vDlg.FInitExpr := GetWordUnderCursor;

      vRes := vDlg.Run;

      AEntire := vRes = IdFromBeg;
      ACount := vRes = IdCount;
      Result := (vRes <> -1) and (vRes <> IdCancel);

    finally
      FreeObj(vDlg);
    end;
  end;


initialization

finalization
  FreeObj(RegexpList);
end.
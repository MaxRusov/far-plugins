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
    MixWinUtils,

    PluginW,
    FarKeysW,
    FarCtrl,
    FarDlg,

    EdtFindCtrl;


  type
    TFindDlg = class(TFarDialog)
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

  procedure OptionsMenu;
  function GetWordUnderCursor(ACol :PInteger = nil) :TString;
  function FindDlg(APickWord :Boolean; var AFromBeg :Boolean) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function FarInputBox(const ATitle, APrompt :TString; var AValue :TString; const AHist :TString = '';
    const AMaxLen :Integer = 1024; const AOptions :Integer = 0) :Boolean;
  var
    vNewVal :TString;
  begin
    SetLength(vNewVal, AMaxLen);
    Result := FARAPI.InputBox(
      PTChar(ATitle),
      PTChar(APrompt),
      PTChar(AHist),
      PTChar(AValue),
      PTChar(vNewVal),
      Length(vNewVal),
      nil,
      AOptions) = 1;
    if Result then
      AValue := vNewVal;
  end;


  function ColorDlg(var AColor :Integer) :Boolean;
  var
    vVal :TString;
  begin
    vVal := HexStr(AColor, 2);
    {!!!Localize}
    Result := FarInputBox('Color', 'Color value:', vVal, '', 2, FIB_BUTTONS {or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY});
    if Result then begin
      AColor := Hex2Int64(vVal);
      FARAPI.EditorControl(ECTL_REDRAW, nil);
    end;
  end;


  procedure OptionsMenu;
  const
    cMenuCount = 9;
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
        vItems[5].Flags := SetFlag(0, MIF_CHECKED1, optShowProgress);
        vItems[6].Flags := SetFlag(0, MIF_CHECKED1, optGroupUndo);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          {!!!Localize}
          'Options' {GetMsg(strOptions)},
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
          5: optShowProgress := not optShowProgress;
          6: optGroupUndo := not optGroupUndo;
          7: ColorDlg(optCurFindColor);
          8: ColorDlg(optMatchColor);
        end;

        WriteSetup;
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFindDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TFindDlg.Create; {override;}
  begin
    inherited Create;
  end;


  destructor TFindDlg.Destroy; {override;}
  begin
    inherited Destroy;
  end;

(*
  const
    IdFrame        = 0;
    IdInput        = 2;
    IdSubstrChk    = 4;
    IdWholeWordChk = 5;
    IdRegexpChk    = 6;
    IdCaseSensChk  = 7;

    IdCancel       = 10;


  procedure TFindDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 12;
  var
    vX2 :Integer;
  begin
    FHelpTopic := 'Evaluate';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 11;
    vX2 := DX div 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strFind)),

        NewItemApi(DI_Text,     5,   2,   DX-10,  -1,   0, '&Search for'{GetMsg(strLeftFolder)} ),
        NewItemApi(DI_Edit,     5,   3,   DX-10,  -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', 'SearchText' ),

        NewItemApi(DI_Text,     0,   4,   -1,    -1,   DIF_SEPARATOR),

        NewItemApi(DI_RADIOBUTTON, 5,  5,  -1,   -1,   0, 'S&ubstring'),
        NewItemApi(DI_RADIOBUTTON, 5,  6,  -1,   -1,   0, '&Whole words'),
        NewItemApi(DI_RADIOBUTTON, 5,  7,  -1,   -1,   0, '&Regular expressions'),

        NewItemApi(DI_CHECKBOX,   vX2, 5,  DX-vX2-5,  -1,  0, '&Case sensitive' {GetMsg(strCompareContents)}),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, 'Search' {GetMsg(strOk)} ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, 'Cancel' {GetMsg(strCancel)} )
      ]
    );
  end;

  procedure TFindDlg.InitDialog; {override;}
  begin
//  SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    SendMsg(DM_SETFOCUS, IdInput, 0);
    if FInitExpr <> '' then
      SetText(IdInput, FInitExpr);

    if [foWholeWords, foRegexp] * gOptions = [] then
      SetChecked(IdSubstrChk, True);
    if [foWholeWords, foRegexp] * gOptions = [foWholeWords] then
      SetChecked(IdWholeWordChk, True);
    if [foWholeWords, foRegexp] * gOptions = [foRegexp] then
      SetChecked(IdRegexpChk, True);

    SetChecked(IdCaseSensChk, foCaseSensitive in gOptions);
  end;


  function TFindDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      gStrFind := GetText(IdInput);

      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));
      SetFindOptions(gOptions, foCaseSensitive, GetChecked(IdCaseSensChk));
    end;
    Result := True;
  end;
*)


  const
    IdFrame        = 0;
    IdFindEdt      = 2;
    IdCaseSensChk  = 4;
    IdWholeWordChk = 5;
    IdRegexpChk    = 6;
    IdFromBeg      = 9;
    IdCancel       = 10;
//  IdOptions      = 11;

  procedure TFindDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 12;
//var
//  vX2 :Integer;
  begin
    FHelpTopic := 'Find';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 11;
//  vX2 := DX div 2;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strFind)),

        NewItemApi(DI_Text,     5,   2,   DX-10,  -1,   0, GetMsg(strSearchFor) ),
        NewItemApi(DI_Edit,     5,   3,   DX-10,  -1,   DIF_HISTORY or DIF_USELASTHISTORY, '', cFindHistory ),

        NewItemApi(DI_Text,     0,   4,   -1,    -1,   DIF_SEPARATOR),

        NewItemApi(DI_CheckBox, 5,  5,  -1,   -1,   0, GetMsg(strCaseSens)),
        NewItemApi(DI_CheckBox, 5,  6,  -1,   -1,   0, GetMsg(strWholeWords)),
        NewItemApi(DI_CheckBox, 5,  7,  -1,   -1,   0, GetMsg(strRegExp)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strSearchBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strFromBegBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
//      NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strOptionsBut) )
      ]
    );
  end;


  procedure TFindDlg.InitDialog; {override;}
  begin
    if FInitExpr <> '' then
      SetText(IdFindEdt, FInitExpr);
    SetChecked(IdCaseSensChk, foCaseSensitive in gOptions);
    SetChecked(IdWholeWordChk, foWholeWords in gOptions);
    SetChecked(IdRegexpChk, foRegexp in gOptions);
    EnableControls;
  end;


  function TFindDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      gStrFind := GetText(IdFindEdt);

      SetFindOptions(gOptions, foCaseSensitive, GetChecked(IdCaseSensChk));
      SetFindOptions(gOptions, foWholeWords, GetChecked(IdWholeWordChk));
      SetFindOptions(gOptions, foRegexp, GetChecked(IdRegexpChk));

      if (foRegexp in gOptions) and (gStrFind <> '') then
        if not CheckRegexp(gStrFind) then
          AppErrorId(strBadRegexp);

    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFindDlg.EnableControls;
  var
    vRegExp :Boolean;
  begin
    vRegExp := GetChecked(IdRegexpChk);
    SendMsg(DM_Enable, IdWholeWordChk, Byte(not vRegExp));
    if vRegExp then
      SetChecked(IdWholeWordChk, False);
  end;


  function TFindDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
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

  
  function GetWordUnderCursor(ACol :PInteger = nil) :TString;
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
          if SelStart >= 0 then begin
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


  function FindDlg(APickWord :Boolean; var AFromBeg :Boolean) :Boolean;
  var
    vDlg :TFindDlg;
    vRes :Integer;
  begin
    vDlg := TFindDlg.Create;
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


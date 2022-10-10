{$I Defines.inc}

unit ColorSetList;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMatch,
    FarPlug,
    FarMenu,
    FarDlg,
    FarGrid,
    FarColorDlg,
    FarListDlg,

    ColorSetConst;

  type
    TFarColorsArray = array of TFarColor;


  type
    TColorDef = class(TNamedObject)
    public
      constructor CreateEx(const AName :TString; AIndex :Integer);

    private
      FIndex  :Integer;
      FTitle  :TString;
      FGroup  :TString;

    public
      property Title :TString read FTitle;
      property Group :TString read FGroup;
    end;


    TColorsLib = class(TExList)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure ReadColors(const AFileName :TString);

      procedure StorePalette(const AFileName :TString);
      procedure RestorePalette(const AFileName :TString);

    private
      FDict  :TObjList;
    end;


    TColorsDlg = class(TFilteredListDlg)
    public
      constructor Create; override;

    protected
      procedure Prepare; override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure SelectItem(ACode :Integer); override;
      procedure ReinitAndSaveCurrent; override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FLibrary  :TColorsLib;
      FColors   :TFarColorsArray;
      FChanged  :Boolean;
      FLock     :Integer;

      procedure SetupColor(ADef :TColorDef);
      function GetColorDef(ADlgIndex :Integer) :TColorDef;
    end;


  procedure ColorListDlg(ALib :TColorsLib);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function ExtractNextLine(var AStr :PTChar) :TString;
  var
    P :PTChar;
  begin
    P := AStr;
    while (P^ <> #0) and (P^ <> #13) and (P^ <> #10) do
      Inc(P);
    SetString(Result, AStr, P - AStr);
    if P^ = #10 then
      Inc(P)
    else
    if P^ = #13 then begin
      Inc(P);
      if P^ = #10 then
        Inc(P);
    end;
    AStr := P;
  end;



  procedure FarGetColors(var AColors :TFarColorsArray);
  var
    vCount :Integer;
  begin
    vCount := FarAdvControl(ACTL_GETARRAYCOLOR, nil);
    SetLength(AColors, vCount);
    if vCount > 0 then
     {$ifdef Far3}
      FARAPI.AdvControl(PluginID, ACTL_GETARRAYCOLOR, vCount, @AColors[0]);
     {$else}
      FarAdvControl(ACTL_GETARRAYCOLOR, @AColors[0]);
     {$endif Far3}
  end;


  function FarColorToStr(AColor :TFarColor) :TString;
  begin
    Result := '';
   {$ifdef Far3}
    if AColor.Flags and FCF_FG_4BIT <> 0 then
      Result := HexStr(AColor.ForegroundColor and $0F, 1)
    else
      Result := HexStr(AColor.ForegroundColor and $00FFFFFF, 6);

    Result := Result + ',';

    if AColor.Flags and FCF_BG_4BIT <> 0 then
      Result := Result + HexStr(AColor.BackgroundColor and $0F, 1)
    else
      Result := Result + HexStr(AColor.BackgroundColor and $00FFFFFF, 6);
   {$else}
   {$endif Far3}
  end;


  function StrToFarColor(const AStr :TString; var AColor :TFarColor) :Boolean;
 {$ifdef Far3}
  var
    vStr :TString;
    vFG, vBG :DWORD;
 {$endif Far3}
  begin
    Result := False;
   {$ifdef Far3}
    vStr := ExtractWord(1, AStr, [',', ' ']);
    if not TryHex2Uns(vStr, vFG) then
      Exit;
    if Length(vStr) > 1 then
      vFG := vFG or $FF000000;

    vStr := ExtractWord(2, AStr, [',', ' ']);
    if not TryHex2Uns(vStr, vBG) then
      Exit;
    if Length(vStr) > 1 then
      vBG := vBG or $FF000000;

    AColor := MakeColor(vFG, vBG);

    Result := True;
   {$else}
   {$endif Far3}
  end;


  procedure FarUpdatePanels;
  begin
    FARAPI.Control(PANEL_ACTIVE, FCTL_UPDATEPANEL, 0, nil);
    FARAPI.Control(PANEL_ACTIVE, FCTL_REDRAWPANEL, 0, nil);

    FARAPI.Control(PANEL_PASSIVE, FCTL_UPDATEPANEL, 0, nil);
    FARAPI.Control(PANEL_PASSIVE, FCTL_REDRAWPANEL, 0, nil);
  end;

  
 {-----------------------------------------------------------------------------}
 { TColorsLib                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TColorsLib.Create;
  begin
    inherited Create;
    FDict := TObjList.Create;
//  FDict.Options := [];
  end;


  destructor TColorsLib.Destroy;
  begin
    FreeObj(FDict);
    inherited Destroy;
  end;


  procedure TColorsLib.ReadColors(const AFileName :TString);
  var
    vText, vStr, vName, vDescr, vGroup :TString;
    vPtr :PTChar;
    vIdx :Integer;
    vMode :Integer;
    vDef :TColorDef;
  begin
    vText := StrFromFile(AFileName);

    vIdx := 0;
    vPtr := PTChar(vText);
    vMode := 0;
    vGroup := '';
    while vPtr^ <> #0 do begin
      vStr := Trim(ExtractNextLine(vPtr));
      if (vStr = '') or (vStr[1] = ';') then
        Continue;

      if vStr[1] = '[' then begin
        if StrEqual(vStr, '[Colors]') then
          vMode := 1
        else
        if StrEqual(vStr, '[Groups]') then
          vMode := 2

      end else
      if vMode = 1 then begin
        FDict.AddSorted(TColorDef.CreateEx(vStr, vIdx), 0, dupError);
        Inc(vIdx);
      end else
      if vMode = 2 then begin
        if vStr[1] = '"' then begin
          vGroup := StrDeleteChars(vStr, ['"']);
        end else
        begin
          vName := ExtractWord(1, vStr, [' ', #9]);
          vDescr := StrDeleteChars(ExtractWords(2, MaxInt, vStr, [' ', #9]), ['"']);
          if FDict.FindKey(Pointer(vName), 0, [foBinary], vIdx) then begin
            vDef := FDict[vIdx];
            vDef.FTitle := vDescr;
            vDef.FGroup := vGroup;
            Add(vDef);
          end;
        end;
      end;
    end;
  end;


  procedure TColorsLib.StorePalette(const AFileName :TString);
  var
    I :Integer;
    vList :TStringList;
    vDef :TColorDef;
    vColor :TFarColor;
    vColors :TFarColorsArray;
  begin
    FarGetColors(vColors);

    vList := TStringList.Create;
    try
      for I := 0 to Count - 1 do begin
        vDef := Items[I];
        if vDef.FIndex < Length(vColors) then begin
          vColor := vColors[vDef.FIndex];
          vList.Add(vDef.Name + '=' + FarColorToStr(vColor));
        end;
      end;

      vList.SaveToFile(AFileName, sffUTF8);

      if optDefaultPalette <> AFileName then begin
        optDefaultPalette := AFileName;
        PluginConfig(True);
      end;

    finally
      FreeObj(vList);
    end;
  end;


  procedure TColorsLib.RestorePalette(const AFileName :TString);
  var
    I, vIdx :Integer;
    vList :TStringList;
    vDef :TColorDef;
    vColor :TFarColor;
    vColors :TFarColorsArray;
    vStr, vName :TString;
    vSet :TFarSetColors;
  begin
    FarGetColors(vColors);

    vList := TStringList.Create;
    try
      vList.LoadFromFile(AFileName);

      for I := 0 to vList.Count - 1 do begin
        vStr := vList[I];
        vName := ExtractWord(1, vStr, ['=', ' ', #9]);
        if (vName = '') or (vName[1] = ';') then
          Continue;

        if FDict.FindKey(Pointer(vName), 0, [foBinary], vIdx) then begin
          vDef := FDict[vIdx];
          vStr := ExtractWords(2, MaxInt, vStr, ['=', ' ', #9]);
          if StrToFarColor(vStr, vColor) then begin
            vColors[vDef.FIndex] := vColor;
          end;
        end;
      end;

      FillZero(vSet, SizeOf(vSet));
     {$ifdef Far3}
      vSet.StructSize := SizeOf(vSet);
      vSet.Flags := FSETCLR_REDRAW;
     {$else}
      vSet.Flags := FCLR_REDRAW;
     {$endif Far3}
      vSet.StartIndex := 0;
      vSet.ColorCount := length(vColors);
      vSet.Colors := Pointer(@vColors[0]);
     {$ifdef Far3}
      FARAPI.AdvControl(PluginID, ACTL_SETARRAYCOLOR, 0, @vSet);
     {$else}
      Sorry;
     {$endif Far3}
     

//    FarAdvControl(ACTL_RedrawAll, nil);
      FarUpdatePanels;


      if optDefaultPalette <> AFileName then begin
        optDefaultPalette := AFileName;
        PluginConfig(True);
      end;


    finally
      FreeObj(vList);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TColorDef                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TColorDef.CreateEx(const AName :TString; AIndex :Integer);
  begin
    CreateName(AName);
    Findex := Aindex;
  end;


 {-----------------------------------------------------------------------------}
 { TColorsDlg                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TColorsDlg.Create; {override;}
  begin
    inherited Create;
    FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
//  FFoundColor := GetOptColor(optFoundColor, COL_MENUHIGHLIGHT);
  end;


  procedure TColorsDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := '';

    FGrid.Options := FGrid.Options - [goRowSelect];

    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 5, taLeftJustify, [coColMargin], 2) );

    FarGetColors(FColors);
  end;


  procedure TColorsDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(sTitle);

    if optDefaultPalette <> '' then begin
      vTitle := vTitle + ' - ' + ExtractFileName(optDefaultPalette);
      if FChanged then
        vTitle := vTitle + '*';
    end;

    if FFilterMask = '' then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);
  end;


  procedure TColorsDlg.ReinitGrid; {override;}
  var
    I, vPos, vLen, vMaxLen :Integer;
    vDef :TColorDef;
    vName, vMask :TString;
    vHasMask :Boolean;
  begin
    FFilter.Clear;
    FTotalCount := 0;
    vMaxLen := 0;


    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    for I := 0 to FLibrary.Count - 1 do begin
      vDef := FLibrary[I];
      vName := vDef.Group + ' - ' + vDef.Title;

      Inc(FTotalCount);
      vPos := 0; vLen := 0;
      if vMask <> '' then
        if not CheckMask(vMask, vName, vHasMask, vPos, vLen) then
          Continue;

      FFilter.Add(I, vPos, vLen);
      vMaxLen := IntMax(vMaxLen, Length(vName) + 3);
    end;

    FMenuMaxWidth := vMaxLen + 5;

    FGrid.ResetSize;
    FGrid.RowCount := FFilter.Count;

    UpdateHeader;
    ResizeDialog;
  end;


  procedure TColorsDlg.ReinitAndSaveCurrent;
//  var
//    vName :TString;
  begin
//    vName := '';
//    if (FGrid.CurRow >= 0) and (FGrid.CurRow < FGrid.RowCount) then
//      {vName := GetFont(FGrid.CurRow)};
    ReinitGrid;
//    {GotoFont(vName)};
  end;

(*
  procedure TFontsDlg.GotoFont(const AName :TString);
  var
    vIndex :Integer;
  begin
    vIndex := FontNameToDlgIndex(AName);
    if vIndex < 0 then
      vIndex := 0;
    SetCurrent( vIndex, lmCenter );
  end;


  function TFontsDlg.FontNameToDlgIndex(const AName :TString) :Integer;
  var
    I :Integer;
  begin
    Result := -1;
    for I := 0 to FFilter.Count - 1 do
      if GetFont(I) = AName then begin
        Result := I;
        Exit;
      end;
  end;


  function TFontsDlg.GetFont(ADlgIndex :Integer) :TString;
  begin
    Result := FontNames[FFilter[ADlgIndex]];
  end;
*)

  function TColorsDlg.GetColorDef(ADlgIndex :Integer) :TColorDef;
  begin
    Result := FLibrary[FFilter[ADlgIndex]];
  end;


  function TColorsDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  var
    vDef :TColorDef;
  begin
    Result := '';
    vDef := GetColorDef(ARow);
    case FGrid.Column[ACol].Tag of
      1: Result := vDef.Group + ' - ' + vDef.Title;
      2: Result := 'Abc';
    end;
  end;


  procedure TColorsDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor); {override;}
  var
    vDef :TColorDef;
  begin
    if (ACol >= 0) and (FGrid.Column[ACol].Tag = 2) then begin
      vDef := GetColorDef(ARow);
      if vDef.FIndex < length(FColors) then begin
        AColor := FColors[vDef.FIndex];
      end;
    end;
  end;


  procedure TColorsDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {override;}
  var
    vRec :PFilterRec;
    vStr :TString;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      vStr := GridGetDlgText(ASender, ACol, ARow);
      if FFilterMask = '' then
        FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor)
      else
        FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(AColor, optFoundColor));
    end;
  end;


  procedure TColorsDlg.SelectItem(ACode :Integer); {override;}
  var
    vDef :TColorDef;
  begin
    vDef := GetColorDef(FGrid.CurRow);
    SetupColor(vDef);
  end;


  procedure TColorsDlg.SetupColor(ADef :TColorDef);
  var
    vColor :TFarColor;
    vSet :TFarSetColors;
  begin
    vColor := FColors[ADef.FIndex];
    if ColorDlg('', vColor) and not EqualColor(FColors[ADef.FIndex], vColor) then begin
      FColors[ADef.FIndex] := vColor;

      Inc(FLock);
      try
        FillZero(vSet, SizeOf(vSet));
       {$ifdef Far3}
        vSet.StructSize := SizeOf(vSet);
        vSet.Flags := FSETCLR_REDRAW;
       {$else}
        vSet.Flags := FCLR_REDRAW;
       {$endif Far3}
        vSet.StartIndex := ADef.FIndex;
        vSet.ColorCount := 1;
        vSet.Colors := Pointer(@vColor);
       {$ifdef Far3}
        FARAPI.AdvControl(PluginID, ACTL_SETARRAYCOLOR, 0, @vSet);
       {$else}
        Sorry;
       {$endif Far3}

        if ADef.FIndex = byte(COL_PANELTEXT) then begin
          FarUpdatePanels;
          FarAdvControl(ACTL_RedrawAll, nil);
        end;
      finally
        Dec(FLock);
      end;

      FChanged := True;
      UpdateHeader;
    end;
  end;


  function TColorsDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        if FLock = 0 then
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;



 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ColorListDlg(ALib :TColorsLib);
  var
    vDlg :TColorsDlg;
  begin
    vDlg := TColorsDlg.Create;
    try
      vDlg.FLibrary := ALib;

      if vDlg.Run = -1 then
        Exit;

    finally
      FreeObj(vDlg);
    end;
  end;



end.



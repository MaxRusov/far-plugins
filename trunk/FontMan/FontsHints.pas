{$I Defines.inc}

unit FontsHints;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* FontMan Far plugin                                                         *}
{* Интеграция с FAR Hints                                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarHintsAPI,

    FontsClasses,
    FontsCtrl;


  const
    cMaxFontSize  = 72;
    cMinFontSize  = 8;

    cSamplesIni = 'Samples.ini';

    cDefaultSample = '1234567890 '#13'AaBbCcZz ';

  var
    FontSize :Integer = 32;


  type
    TCharsetSample = class(TBasis)
    public
      constructor CreateEx(ACharset :Byte; const ASample :TWideStr);

    private
      FCharset :Byte;
      FSample  :TWideStr;
    end;

    THintPluginObject = class(TInterfacedObject, IEmbeddedHintPlugin, IHintPluginDraw, IHintPluginCommand)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

//    {IHintPluginIdle}
//    function Idle(const AItem :IFarItem) :Boolean; stdcall;

      {IHintPluginCommand}
      procedure RunCommand(const AItem :IFarItem; ACommand :Integer); stdcall;


      {IEmbeddedHintPlugin}
      procedure UnloadFarHints; stdcall;

    private
      FAPI       :IFarHintsApi;

      FName      :TString;
      FInfo      :TFontInfo;
      FSizes     :TIntList;

      FFont      :HFont;
      FSize      :Integer;
      FSizeIndex :Integer;

      FSample    :TWideStr;

      FDefSample :TWideStr;
      FSamples   :TObjList;

      procedure InitSamples;
      procedure UpdateFontPreview(const AItem :IFarItem);
      function ChooseSample(ACharsets :TIntList) :TWideStr;
    end;


  procedure RegisterFontHints;
  procedure UnRegisterFontHints;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetFont(const AName :TString; ASize :Integer; APitch, AWeight :Integer; AItalic :Boolean) :HFont;
  var
    vDC :HDC;
    vHeight, vPPI :Integer;
  begin
    vDC := CreateCompatibleDC(0);
    vPPI := GetDeviceCaps(vDC, LogPixelsY);
    DeleteDC(vDC);

    vHeight := MulDiv(ASize, vPPI, 72);

    Result := CreateFont(
      {lfHeight}         -vHeight,
      {lfWidth}          0,
      {lfEscapement}     0,
      {lfOrientation}    0,
      {lfWeight}         AWeight, {IntIf(fsBold in AStyle, FW_Bold, FW_Normal)}
      {lfItalic}         IntIf(AItalic, 1, 0),
      {lfUnderline}      0,
      {lfStrikeOut}      0,
      {lfCharSet}        DEFAULT_CHARSET,
      {lfOutPrecision}   OUT_DEFAULT_PRECIS,
      {lfClipPrecision}  CLIP_DEFAULT_PRECIS,
      {lfQuality}        DEFAULT_QUALITY,
      {lfPitchAndFamily} APitch {DEFAULT_PITCH},
      {lfFaceName}       PTChar(AName)
    );
  end;


  function TextSize(AFont :HFont; const AText :TWideStr) :TSize;
  var
    vDC :HDC;
    vOld :THandle;
    vRect :TRect;
  begin
    vDC := CreateCompatibleDC(0);
    vOld := SelectObject(vDC, AFont);
    try
      vRect := Bounds(0, 0, 128, 0);
      DrawTextW(vDC, PWideChar(AText), Length(AText), vRect, DT_CALCRECT);

      Result.CX := vRect.Right;
      Result.CY := vRect.Bottom;

    finally
      SelectObject(vDC, vOld);
      DeleteDC(vDC);
    end;
  end;


  function FindNearestSize(ASizes :TIntList; ASize :Integer) :Integer;
  var
    I, vBest, vDelta :Integer;
  begin
    Result := -1;
    vBest := MaxInt;
    for I := 0 to ASizes.Count - 1 do begin
      vDelta := Abs(ASizes[I] - ASize);
      if vDelta < vBest then begin
        Result := I;
        vBest := vDelta;
      end;
    end;
  end;


  function ReadUnicodeFile(const AFileName :TString) :TWideStr;
  var
    vFile, vSize :Integer;
    vBOM :Word;
  begin
    Result := '';
    vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
    if vFile < 0 then
      Exit;
    try
      if (FileRead(vFile, vBOM, SizeOf(vBOM)) <> SizeOf(vBOM)) or (vBOM <> Word(BOM_UTF16_LE)) then
        Exit;

      vSize := GetFileSize(vFile, nil) - SizeOf(vBOM);
      if vSize > 0 then begin
        SetString(Result, nil, (vSize + 1) div SizeOf(WideChar));
        FileRead(vFile, PWideChar(Result)^, vSize);
      end;

    finally
      FileClose(vFile);
    end;
  end;


  function ExtractNextLineW(var AStr :PWideChar) :TWideStr;
  var
    vBeg :PWideChar;
  begin
    while (AStr^ <> #0) and ((AStr^ = #13) or (AStr^ = #10)) do
      Inc(AStr);
    vBeg := AStr;
    while (AStr^ <> #0) and (AStr^ <> #13) and (AStr^ <> #10) do
      Inc(AStr);
    SetString(Result, vBeg, AStr - vBeg);
  end;


  procedure WideReplaceChars(var AStr :TWideStr; const AFromStr, AToStr :TWideStr);
  var
    vPos :Integer;
  begin
    while True do begin
      vPos := Pos(AFromStr, AStr);
      if vPos = 0 then
        Break;
      AStr := Copy(AStr, 1, vPos - 1) + #13 + Copy(AStr, vPos + Length(AFromStr), MaxInt)
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCharsetSample                                                              }
 {-----------------------------------------------------------------------------}

  constructor TCharsetSample.CreateEx(ACharset :Byte; const ASample :TWideStr);
  begin
    FCharset := ACharset;
    FSample := ASample;
  end;


 {-----------------------------------------------------------------------------}
 { THintPluginObject                                                           }
 {-----------------------------------------------------------------------------}


  procedure THintPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
    AInfo.Flags := PF_ProcessPluginItems or PF_CanChangeSize;

    FontSize := RegGetIntValue(HKCU, FRegRoot + '\' + cPlugRegFolder, cHintFontSizeRegValue, FontSize);

//  InitSamples;
  end;


  procedure THintPluginObject.InitSamples;
  var
    vFileName, vCharsetName :TString;
    vSample :TWideStr;
    vPtr :PWideChar;
    vStr :TWideStr;
    vPos, vIndex :Integer;
  begin
    FSamples := TObjList.Create;

    vFileName := AddFileName(ExtractFilePath(FModuleName), cSamplesIni);
    if not WinFileExists(vFileName) then
      Exit;

    vSample := ReadUnicodeFile(vFileName);

    vPtr := PWideChar(vSample);
    vStr := ExtractNextLineW(vPtr);
    if not StrEqual(vStr, '[Samples]') then
      Exit;

    while vPtr^ <> #0 Do begin
      vStr := ExtractNextLineW(vPtr);
      if (vStr <> '') and (vStr[1] <> ';') then begin
        vPos := Pos('=', vStr);
        if vPos <> 0 then begin
          vCharsetName := Trim(Copy(vStr, 1, vPos - 1));

          vStr := Copy(vStr, vPos + 1, MaxInt);
          WideReplaceChars(vStr, '\n', #13);
          if (vStr <> '') and (vStr[1] = '"') and (vStr[Length(vStr)] = '"') then
            vStr := Copy(vStr, 2, Length(vStr) - 2);

          if StrEqual(vCharsetName, 'Default') then
            FDefSample := vStr
          else
          if Charsets.FindKey(Pointer(vCharsetName), 0, [], vIndex) then begin
            with TFontCharset(Charsets[vIndex]) do
              FSamples.Add( TCharsetSample.CreateEx(Code, vStr));
          end;
        end;
      end;
    end;
  end;


  function THintPluginObject.ChooseSample(ACharsets :TIntList) :TWideStr;
  var
    I :Integer;
  begin
    Result := FDefSample;
    if Result = '' then
      Result := cDefaultSample;

    for I := 0 to FSamples.Count - 1 do
      with TCharsetSample(FSamples[I]) do
        if ACharsets.IndexOf(Pointer(TUnsPtr(FCharset))) <> -1 then
          Result := Result + #13 + FSample;
  end;


  procedure THintPluginObject.DonePlugin; {stdcall;}
  begin
    FreeObj(FSamples);
  end;


  function THintPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}

    procedure LocAddSizes;
    begin
      FSizes := nil;
      if (FInfo <> nil) and (FInfo.FontType = ftRaster) then
        FSizes := FInfo.Sizes;
      FSizeIndex := AItem.AttrCount;
      if FSizes <> nil then
        AItem.AddStringInfo(GetMsgStr(strSizes), '')
      else
        AItem.AddIntInfo(GetMsgStr(strSize), FontSize);
    end;

  var
    I, vIndex :Integer;
    vInfo :TPanelInfo;
    vItem :TBasis;
    vStr :TString;
  begin
    Result := False;

    LastAccessedPanel := nil;

    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodefar}
    FARAPI.Control(HandleIf(AItem.IsPrimaryPanel, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(AItem.IsPrimaryPanel, FCTL_GetPanelShortInfo, FCTL_GetAnotherPanelShortInfo), @vInfo);
   {$endif bUnicodefar}
    if LastAccessedPanel <> nil then begin
      vItem := LastAccessedPanel.GetItem(AItem.Name);
      if vItem <> nil then begin

        if FSamples = nil then
          InitSamples;

        FInfo := nil;
        FSizes := nil;

        if vItem is TFontFamily then begin
          with TFontFamily(vItem) do begin
            if Styles.Count > 0 then
              FInfo := Styles[0];

            FName := Name;

            AItem.AddStringInfo(GetMsgStr(strFont), Name);
            AItem.AddStringInfo(GetMsgStr(strType), FontTypeAsStr(FontType));

            LocAddSizes;

            vStr := '';
            for I := 0 to Styles.Count - 1 do
              with TFontInfo(Styles[I]) do
//              vStr := AppendStrCh(vStr, NormalizeFileName(ExtractFileName(FileName)), ', ');
                vStr := AppendStrCh(vStr, ExtractFileName(FileName), ', ');

            if vStr <> '' then begin
              AItem.AddStringInfo(GetMsgStr(strFileNames), vStr);
              AItem.AddDateInfo(GetMsgStr(strModified), FAPI.FileTimeToDateTime(GetLastTime));
              AItem.AddInt64Info(GetMsgStr(strFilesSize), GetTotalSize);
            end;

          end;
        end else
        if vItem is TFontInfo then begin
          with TFontInfo(vItem) do begin
            FInfo   := TFontInfo(vItem);
            if FInfo.FontType = ftRaster then
              FSizes := FInfo.Sizes;

            FName   := Family;
            if FName = '' then
              FName := Name;

            AItem.AddStringInfo(GetMsgStr(strFont), FName);
            if SubFamily <> '' then
              AItem.AddStringInfo(GetMsgStr(strStyle), SubFamily);
            AItem.AddStringInfo(GetMsgStr(strType), FontTypeAsStr(FontType));

            LocAddSizes;

            if FileName <> '' then begin
//            AItem.AddStringInfo(GetMsgStr(strFileName), NormalizeFileName(ExtractFileName(FileName)));
              AItem.AddStringInfo(GetMsgStr(strFileName), ExtractFileName(FileName));
              AItem.AddDateInfo(GetMsgStr(strModified), FAPI.FileTimeToDateTime(Time));
              AItem.AddInt64Info(GetMsgStr(strFileSize), Size);
            end;
          end;
        end;

        FSample := '';
        if FInfo <> nil then
          FSample := ChooseSample(FInfo.Charsets);

        FSize := 0;
        if FSizes <> nil then begin
          vIndex := FindNearestSize(FSizes, FontSize);
          if vIndex <> -1 then
            FSize := FSizes[vIndex];
        end else
          FSize := FontSize;

        AItem.IconFlags := IF_Buffered or IF_HideSizeLabel;
        UpdateFontPreview(AItem);

        Result := True;
      end;
    end;
  end;


  procedure THintPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
    {}
  end;


  procedure THintPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
    if FFont <> 0 then begin
      DeleteObject(FFont);
      FFont := 0;
    end;
  end;


//function THintPluginObject.Idle(const AItem :IFarItem) :Boolean; {stdcall;}
//begin
//  Result := True;
//end;


  procedure THintPluginObject.RunCommand(const AItem :IFarItem; ACommand :Integer); {stdcall;}
  var
    vNewSize, vIndex :Integer;
  begin
//  TraceF('RunCommand: %d', [ACommand]);

    if FSizes <> nil then begin
      vNewSize := FSize;
      vIndex := FindNearestSize(FSizes, FSize);
      if ACommand = 0 then begin
        if vIndex < FSizes.Count - 1 then
          vNewSize := FSizes[vIndex + 1];
      end else
      begin
        if vIndex > 0 then
          vNewSize := FSizes[vIndex - 1];
      end;
    end else
    begin
      if ACommand = 0 then
        vNewSize := IntMin(FSize + 1, cMaxFontSize)
      else
        vNewSize := IntMax(FSize - 1, cMinFontSize);
    end;

    if FSize <> vNewSize then begin
      if FFont <> 0 then begin
        DeleteObject(FFont);
        FFont := 0;
      end;

      FSize := vNewSize;
      UpdateFontPreview(AItem);

      FontSize := FSize;
      AItem.UpdateHintWindow(uhwResize + uhwInvalidateItems + uhwInvalidateImage);
      RegSetIntValue(HKCU, FRegRoot + '\' + cPlugRegFolder, cHintFontSizeRegValue, FSize);
    end;
  end;


  procedure THintPluginObject.UpdateFontPreview(const AItem :IFarItem);
  var
    I :Integer;
    vStr, vStrI :TString;
    vViewSize :TSize;
  begin
    FFont := 0;
    if (FInfo <> nil) and (FSize <> 0) then
      FFont := GetFont(FName, FSize, FInfo.Pitch, FInfo.Weight, FInfo.Italic);

    if FFont <> 0 then begin
      vViewSize := TextSize(FFont, FSample);
      AItem.IconWidth := vViewSize.cx;
      AItem.IconHeight := vViewSize.cy;
    end else
    begin
      AItem.IconWidth := 0;
      AItem.IconHeight := 0;
    end;

    if FSizes <> nil then begin
      vStr := '';
      for I := 0 to FSizes.Count - 1 do begin
        vStrI := Int2Str(FSizes[I]);
        if FSizes[I] = FSize then
          vStrI := '*' + vStrI;
        vStr := AppendStrCh(vStr, vStrI, ', ');
      end;
      AItem.Attrs[FSizeIndex].AsStr := vStr;
    end else
      AItem.Attrs[FSizeIndex].AsInt := FSize;
  end;


  procedure THintPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); {stdcall;}
  var
    vOld :THandle;
    vRect :TRect;
  begin
    vOld := SelectObject(ADC, FFont);
    vRect := ARect;
    SetBkMode(ADC, Transparent);
    DrawTextW(ADC, PWideChar(FSample), Length(FSample), vRect, 0);
    SelectObject(ADC, vOld);
  end;


  procedure THintPluginObject.UnloadFarHints; {stdcall;}
  begin
    { На случай, если FarHints выгружается раньше, чем данный плагин }
    UnRegisterFontHints;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    FHintRegistered :Boolean;
    FIntegrationAPI :IFarHintsIntegrationAPI;
    FHintObject :IEmbeddedHintPlugin;


  procedure RegisterFontHints;
  var
    vHandle :THandle;
    vGetApiProc :TGetFarHinstAPI;
    vFarHintsApi :IFarHintsAPI;
  begin
    if not FHintRegistered then begin
      try
        vHandle := GetModuleHandle('FarHints.dll');
        if vHandle = 0 then
          Exit; {FarHints не установлен}

        vGetApiProc := GetProcAddress( vHandle, 'GetFarHinstAPI' );
        if not Assigned(vGetApiProc) then
          Exit; {FarHints неподходящей версии }

        vFarHintsApi := vGetApiProc;

        vFarHintsAPI.QueryInterface(IFarHintsIntegrationAPI, FIntegrationAPI);
        if not Assigned(FIntegrationAPI) then
          Exit; {FarHints неподходящей версии }

        FHintObject := THintPluginObject.Create;
        FIntegrationAPI.RegisterEmbeddedPlugin(FHintObject);

        FHintRegistered := True;

      except
        FIntegrationAPI := nil;
        FHintObject := nil;
        raise;
      end;
    end;  
  end;


  procedure UnRegisterFontHints;
  begin
    if FHintRegistered then begin
      FIntegrationAPI.UnregisterEmbeddedPlugin(FHintObject);
      FHintObject := nil;
      FIntegrationAPI := nil;
      FHintRegistered := False;
    end;
  end;


initialization
finalization
  { Чтобы не было AV при закрытии по "крестику" }
  FHintRegistered := False;
  Pointer(FIntegrationAPI) := nil;
  pointer(FHintObject) := nil;
end.


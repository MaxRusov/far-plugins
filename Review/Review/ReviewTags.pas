{$I Defines.inc}

unit ReviewTags;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2021, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    FarColorDlg,

    FarCtrl,
    FarConfig,

    GDIImageUtil,
    ReviewConst,
    ReviewDecoders;


  const
    cDeltaH = 5;
    cDeltaV = 5;

    cOrients :array[0..8] of TString =
      ('0', '1', 'H', '180'#176, 'V', 'H-90'#176, '90'#176, 'H+90'#176, '-90'#176);


  type
    TReviewTags = record
      Time         :TString;
      Description  :TString;
      EquipMake    :TString;
      EquipModel   :TString;
      Software     :TString;
      Author       :TString;
      Copyright    :TString;

      ExposureTime :Int64;
      FNumber      :Int64;
      FocalLength  :Int64;
      ISO          :Integer;
      Flash        :Integer;
      XResolution  :Integer;
      YResolution  :Integer;

//    Title        :TString;
//    Artist       :TString;
//    Album        :TString;
//    Year         :TString;
//    Genre        :TString;

      FVideoName      :TString;
      FVideoLang      :TString;
      FVideoFormat    :TString;
      FVideoBitrate   :Integer;
      FVideoFramerate :Double;

      FAudioName      :TString;
      FAudioLang      :TString;
      FAudioFormat    :TString;
      FAudioBitrate   :Integer;
    end;


  procedure CalcInfoBounds(aImage :TReviewImageRec; AMaxWidth :Integer; var aBounds :TSize);

  procedure DrawInfoOn(DC :HDC; aImage :TReviewImageRec; AMaxWidth :Integer; aWindow :Boolean = False);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    ReviewClasses,
    MixDebug;



  procedure FillInfo(aStrs :TStrList; aImage :TReviewImage; const aTags :TReviewTags);

    function Div2Str(aVal :Int64; aPrec :Integer) :TString;
    begin
      with Int64Rec(aVal) do
        Result := FloatToStrF(Lo / Hi, ffGeneral, 0, aPrec);
    end;

    function Frac2Str(aVal :Int64) :TString;
    begin
      with Int64Rec(aVal) do
        Result := '1/' + FloatToStrF(Hi / Lo, ffGeneral, 0, 0);
    end;

    procedure Add1(const APrompt, AValue :TString);
    begin
      aStrs.Add(APrompt);
      aStrs.Add(AValue);
    end;

    procedure Add(APrompt :TMessages; const AValue :TString);
    begin
      aStrs.Add(GetMsg(APrompt));
      aStrs.Add(AValue);
    end;

  var
    vStr :TString;
    vDateTime :TDateTime;
  begin
    Add(strIName,   ExtractFileName(aImage.FName));
    if aImage.FSize <> 0 then
      Add(strISize,   Int64ToStrEx(aImage.FSize));
    if aImage.FTime <> 0 then begin
//      try
//        vStr := DateTimeToStr(FileDateToDateTime(aImage.FTime));
//      except
//        vStr := '???';
//      end;
      if TryFileDateToDateTime(aImage.FTime, vDateTime) then
        vStr := DateTimeToStr(vDateTime)
      else
        vStr := '???';
      Add(strITime, vStr);
    end;

    Add1('', '');

//  Add(strIFormat,      aImage.FFormat);
    vStr := aImage.FFormat;
    if aImage.FCompress <> '' then
      vStr := vStr + ' / ' + aImage.FCompress;
    if vStr <> '' then
      Add(strIFormat,      vStr);

    if aImage.FDescr <> '' then
      Add(strIDescription, aImage.FDescr);

    if aImage.FLength <> 0 then
      Add(strILength,     LengthToStr(aImage.FLength div 1000));
    if (aImage.FWidth <> 0) or (aImage.FHeight <> 0) then
      Add(strIDimension,   IntToStr(aImage.FWidth) + ' x ' + IntToStr(aImage.FHeight));

    if aImage.FBPP <> 0 then
      Add(strIColors,    IntToStr(aImage.FBPP) + ' ' + GetMsg(strBPP));

    if (aTags.XResolution <> 0) or (aTags.YResolution <> 0) then
      if aTags.XResolution = aTags.YResolution then
        Add(strIDensity, Int2Str(aTags.XResolution) + ' ' + GetMsg(strDPI))
      else
        Add(strIDensity, Int2Str(aTags.XResolution) + ' x ' + Int2Str(aTags.YResolution) + ' ' + GetMsg(strDPI));

    if aImage.FPages > 1 then
      Add(strIPages, IntToStr(aImage.FPage + 1) + ' / ' + IntToStr(aImage.FPages));
    if aImage.FAnimated then
      Add(strIDelay, IntToStr(aImage.FDelay) + ' ' + GetMsg(strMS) );
    if aImage.FOrient > 1 then
      Add(strIOrientation, cOrients[aImage.FOrient]);

    Add1('', '');

    Add(strIDecoder,     aImage.FDecoder.Title);
    Add(strIDecodeTime,  IntToStr(aImage.OpenTime + aImage.DecodeTime) + ' ' + GetMsg(strMS));

    Add1('', '');

    if aTags.Time <> '' then
      Add(strIImageTime,  aTags.Time);
    if aTags.Description <> '' then
      Add(strIDescription,  aTags.Description);
    if aTags.EquipModel <> '' then
      Add(strICamera,  aTags.EquipModel);
    if aTags.EquipMake <> '' then
      Add(strIManufacturer,  aTags.EquipMake);
    if aTags.Software <> '' then
      Add(strISoftware,  aTags.Software);
    if aTags.Author <> '' then
      Add(strIAuthor,  aTags.Author);
    if aTags.Copyright <> '' then
      Add(strICopyright,  aTags.Copyright);

    if not aImage.FMedia then begin
      Add1('', '');
      if aTags.ExposureTime <> 0 then
        Add(strIExposureTime,  Frac2Str(aTags.ExposureTime) + ' ' + GetMsg(strSec1));
      if aTags.FNumber <> 0 then
        Add(strIFNumber,  Div2Str(aTags.FNumber, 1));
      if aTags.FocalLength <> 0 then
        Add(strIFocalLength,  Div2Str(aTags.FocalLength, 0) + ' ' + GetMsg(strMM));
      if aTags.ISO <> 0 then
        Add(strIISO,  Int2Str(aTags.ISO));
      if aTags.Flash <> 0 then
        Add(strIFlash,  Int2Str(aTags.Flash));
    end;

    if aImage.FVideoCount > 0 then begin
      Add1('', '');
      if aImage.FVideoCount > 1 then
        Add(strIVideo, Int2Str(aImage.FVideoIndex + 1) + ' / ' + Int2Str(aImage.FVideoCount))
      else
        Add(strIVideo, '');

      if aTags.FVideoName <> '' then
        Add(strIVideoName, aTags.FVideoName);
      if aTags.FVideoLang <> '' then
        Add(strIVideoLang, aTags.FVideoLang);
      if aTags.FVideoFormat <> '' then
        Add(strIVideoFormat, aTags.FVideoFormat);
      if aTags.FVideoBitrate <> 0 then
        Add(strIVideoBitrate, Int2Str(aTags.FVideoBitrate) + '  kb/s');
      if aTags.FVideoFramerate <> 0 then
        Add(strIVideoFramerate, Float2Str(aTags.FVideoFramerate, 2) + '  fps');
    end;

    if aImage.FAudioCount > 0 then begin
      Add1('', '');
      if aImage.FAudioCount > 1 then
        Add(strIAudio, Int2Str(aImage.FAudioIndex + 1) + ' / ' + Int2Str(aImage.FAudioCount))
      else
        Add(strIAudio, '');

      if aTags.FAudioName <> '' then
        Add(strIAudioName, aTags.FAudioName);
      if aTags.FAudioLang <> '' then
        Add(strIAudioLang, aTags.FAudioLang);
      if aTags.FAudioFormat <> '' then
        Add(strIAudioFormat, aTags.FAudioFormat);
      if aTags.FAudioBitrate <> 0 then
        Add(strIAudioBitrate, Int2Str(aTags.FAudioBitrate * 8 div 1000) + '  kb/s');
    end;
  end;



  procedure CalcInfoRect(aStrs :TStrList; DC :HDC; aMaxWidth :Integer; var aPromptWidth :Integer; var aRect :TRect);
  const
    cPromptWidth = 80;
    cPromptSplit = 5;
  var
    I, CY, vHeight, vTextWidth, vMaxWidth2 :Integer;
    vSize :TSize;
    vRect :TRect;
    vStr :TString;
  begin
    GetTextExtentPoint32(DC, '1', 1, vSize);

    for I := (aStrs.Count div 2) - 1 downto 0 do
      if aStrs[I * 2 + 1] = '' then
        aStrs.DeleteRange(I * 2, 2)
      else
        Break;

    aPromptWidth := cPromptWidth;

    for I := 0 to (aStrs.Count div 2) - 1 do begin
      vStr := aStrs[I * 2];
      if vStr <> '' then begin
        vRect := Bounds(0, 0, 0, 0);
        if DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_CALCRECT) > 0 then
          aPromptWidth := IntMax(aPromptWidth, vRect.Width);
      end;
    end;

    aPromptWidth := IntMin(aPromptWidth, aMaxWidth div 2) + cPromptSplit;
    vMaxWidth2 := aMaxWidth - aPromptWidth;

    CY := 0;
    vTextWidth := 0;
    for I := 0 to (aStrs.Count div 2) - 1 do begin
      vStr := aStrs[I * 2];
      if vStr = '' then
        Inc(CY, vSize.cy div 2)
      else begin
        vStr := aStrs[I * 2 + 1];
        if vStr = '' then
          Inc(CY, vSize.cy + 2)
        else begin
          vRect := Bounds(0, 0, vMaxWidth2, 0);
          vHeight := DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_WORDBREAK or DT_CALCRECT);

          vTextWidth := IntMax(vTextWidth, vRect.Width);
          Inc(CY, vHeight + 2);
        end;
      end;
    end;

    aRect := Bounds(0, 0, aPromptWidth + vTextWidth, CY);
  end;


  procedure CalcInfoBounds(aImage :TReviewImageRec; AMaxWidth :Integer; var aBounds :TSize);
  var
    DC :HDC;
    vStrs :TStrList;
    vImage :TReviewImage;
    vPromptWidth :Integer;
    vFont, vOldFont :HFont;
    vRect :TRect;
  begin
    vStrs := TStrList.Create;
    try
      vImage := aImage as TReviewImage;

      FillInfo(vStrs, vImage, vImage.Tags);

      DC := GetDC(0);
      vFont := GetStockObject(DEFAULT_GUI_FONT);
      vOldFont := SelectObject(DC, vFont);
      try
        CalcInfoRect(vStrs, DC, aMaxWidth, vPromptWidth, vRect);

        aBounds.CX := vRect.Width;
        aBounds.CY := vRect.Height;

      finally
        SelectObject(DC, vOldFont);
        ReleaseDC(0, DC);
      end;

    finally
      FreeObj(vStrs);
    end;
  end;


  procedure DrawInfoOn(DC :HDC; aImage :TReviewImageRec; AMaxWidth :Integer; aWindow :Boolean = False);

    function GrayColor(aColor :COLORREF) :Byte;
    begin
      with RGBRec(aColor) do
        Result := (Red + Green + Blue) div 3;
    end;

    function TranspBetween(aColor1, aColor2 :COLORREF) :Integer;
    var
      vColor1, vColor2 :Byte;
    begin
      vColor1 := GrayColor(aColor1);
      vColor2 := GrayColor(aColor2);
      Result := Abs(vColor1 - vColor2);
    end;

  var
    vStrs :TStrList;
    vImage :TReviewImage;
    I, X, Y, CX1, CX2, vHeight :Integer;
    vFont, vOldFont :HFont;
    vSize :TSize;
    vRect :TRect;
    vStr :TString;
    vColor1, vColor2, vPromptColor1, vPromptColor2 :COLORREF;
  begin
    vStrs := TStrList.Create;
    try
      vImage := aImage as TReviewImage;

      FillInfo(vStrs, vImage, vImage.Tags);

      vFont := GetStockObject(DEFAULT_GUI_FONT);
      vOldFont := SelectObject(DC, vFont);
      if vOldFont = 0 then
        Exit;
      try
        GetTextExtentPoint32(DC, '1', 1, vSize);
        CalcInfoRect(vStrs, DC, aMaxWidth, CX1, vRect);
        CX2 := vRect.Width - CX1;

        Inc(vRect.Right, cDeltaH * 2);
        Inc(vRect.Bottom, cDeltaV * 2);

        vColor1 := FarAttrToCOLORREF(GetColorBG(optPanelColor));  // On black
        vColor2 := FarAttrToCOLORREF(GetColorFG(optPanelColor));

        GDIFillRectTransp(DC, vRect, vColor1, optPanelTransp);
        GDIFillRectTransp(DC, vRect, vColor2, optPanelTransp);

        vPromptColor1 := FarAttrToCOLORREF(GetColorBG(optPromptColor));
        vPromptColor2 := FarAttrToCOLORREF(GetColorFG(optPromptColor));
        vColor1 := FarAttrToCOLORREF(GetColorBG(optInfoColor));
        vColor2 := FarAttrToCOLORREF(GetColorFG(optInfoColor));

        SetBkMode(DC, TRANSPARENT);

        X  := cDeltaH; Y := cDeltaV;
        for I := 0 to (vStrs.Count div 2) - 1 do begin
          vStr := vStrs[I * 2];
          if vStr = '' then
            Inc(Y, vSize.cy div 2)
          else begin
            if vPromptColor1 <> vPromptColor2 then begin
              SetTextColor(DC, vPromptColor1);
              TextOut(DC, X+1, Y+1, PTChar(vStr), Length(vStr));
            end;

            SetTextColor(DC, vPromptColor2);
            TextOut(DC, X, Y, PTChar(vStr), Length(vStr));

            vStr := vStrs[I * 2 + 1];
            if vStr = '' then
              Inc(Y, vSize.cy + 2)
            else begin
              vRect := Bounds(X + CX1, Y, CX2, 0);

              if vColor1 <> vColor2 then begin
                SetTextColor(DC, vColor1);
                RectMove(vRect, +1, +1);
                {vHeight :=} DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_WORDBREAK);
                RectMove(vRect, -1, -1);
              end;

              SetTextColor(DC, vColor2);
              vHeight := DrawText(DC, PTChar(vStr), Length(vStr), vRect, DT_LEFT or DT_TOP or DT_NOCLIP or DT_WORDBREAK);

              Inc(Y, vHeight + 2);
            end;
          end;
        end;

      finally
        SelectObject(DC, vOldFont);
      end;

    finally
      FreeObj(vStrs);
    end;
  end;


end.

{$I Defines.inc}

unit FarHintsIconsMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    FarHintsAPI;


  const
    MaxViewSize = 256;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  function GetBitmapSize(ABitmap :HBitmap) :TSize;
  var
    vBitmapInfo :Windows.TBitmap;
  begin
    GetObject(ABitmap, SizeOf(vBitmapInfo), @vBitmapInfo);
    Result.CX := vBitmapInfo.bmWidth;
    Result.CY := vBitmapInfo.bmHeight;
  end;


  function GetIconSize(AIcon :HIcon) :TSize;
  var
    vIconInfo :TIconInfo;
  begin
    if GetIconInfo(AIcon, vIconInfo) then begin
      try
        Result := GetBitmapSize(vIconInfo.hbmMask);
      finally
        if vIconInfo.hbmColor <> 0 then
          DeleteObject(vIconInfo.hbmColor);
        if vIconInfo.hbmMask <> 0 then
          DeleteObject(vIconInfo.hbmMask);
      end;
    end else
    begin
      Result.CX := 32;
      Result.CY := 32;
    end;
  end;


  function Bounds(ALeft, ATop, AWidth, AHeight :Integer) :TRect;
  begin
    with Result do begin
      Left := ALeft;
      Top := ATop;
      Right := ALeft + AWidth;
      Bottom :=  ATop + AHeight;
    end;
  end;


  function GetFrameCount(ACursor :HCursor) :Integer;
  var
    vDC :HDC;
  begin
    Result := 0;
    vDC := GetDC(0);
    try
      while DrawIconEx(vDC, -32, -32, ACursor, 0, 0, Result, 0, DI_NORMAL) and (Result < 256) do
        Inc(Result);
    finally
      ReleaseDC(0, vDC);
    end;
  end;


 {-----------------------------------------------------------------------------}

  type
    TPluginObject = class(TInterfacedObject, IHintPlugin, IHintPluginIdle, IHintPluginDraw)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;
      function Idle(const AItem :IFarItem) :Boolean; stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

    private
      FAPI      :IFarHintsApi;
      FImgSize  :TSize;
      FViewSize :TSize;
      FFrames   :Integer;
      FFrame    :Integer;
      FTime     :Cardinal;
      FIcon     :HIcon;
      FCursor   :HCursor;
      FBitmap   :HBitmap;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi); {stdcall;}
  begin
    FAPI := API;
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vExt :TString;
  begin
    Result := False;
    vExt := FAPI.ExtractFileExt(AItem.Name);
    if FAPI.CompareStr(vExt, 'ico') = 0 then begin
      FIcon := LoadImage(HInstance, PTChar(AItem.FullName), IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
      if FIcon <> 0 then begin
        FImgSize := GetIconSize(FIcon);
        Result := True;
      end;
    end else
    if (FAPI.CompareStr(vExt, 'cur') = 0) or (FAPI.CompareStr(vExt, 'ani') = 0) then begin

      FCursor := LoadCursorFromFile(PTChar(AItem.FullName));
      if FCursor <> 0 then begin
        FFrame := 0;
        FFrames := 0;
        if FAPI.CompareStr(vExt, 'ani') = 0 then
          FFrames := GetFrameCount(FCursor);
        FTime := GetTickCount;
        FImgSize.CX := GetSystemMetrics(SM_CXCURSOR);
        FImgSize.CY := GetSystemMetrics(SM_CYCURSOR);
        Result := True;
      end;

    end else
    if FAPI.CompareStr(vExt, 'bmp') = 0 then begin
      FBitmap := LoadImage(HInstance, PTChar(AItem.FullName), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
      if FBitmap <> 0 then begin
        FImgSize := GetBitmapSize(FBitmap);
        Result := True;
      end;
    end;

    FViewSize := FImgSize;
    if (FViewSize.cx > MaxViewSize) or (FViewSize.CY > MaxViewSize) then begin
      if FViewSize.cx > FViewSize.cy then begin
        FViewSize.cy := MulDiv(FViewSize.cy, MaxViewSize, FViewSize.cx);
        FViewSize.cx := MaxViewSize;
      end else
      begin
        FViewSize.cx := MulDiv(FViewSize.cx, MaxViewSize, FViewSize.cy);
        FViewSize.cy := MaxViewSize;
      end;
    end;

    if Result then begin
      AItem.IconWidth := FViewSize.CX;
      AItem.IconHeight := FViewSize.CY;

      AItem.AddStringInfo('Name', AItem.Name);
      AItem.AddStringInfo('Sizes', FAPI.Format('%d x %d', [FImgSize.CX, FImgSize.CY]));

      AItem.AddDateInfo('Modified', AItem.Modified);
      AItem.AddInt64Info('Size', AItem.Size);
    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;


  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
    if FIcon <> 0 then begin
      DestroyIcon(FIcon);
      FIcon := 0;
    end else
    if FCursor <> 0 then begin
      DestroyCursor(FCursor);
      FCursor := 0;
    end else
    if FBitmap <> 0 then begin
      DeleteObject(FBitmap);
      FBitmap := 0;
    end;
    FFrames := 0;
  end;


  function TPluginObject.Idle(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vRect :TRect;
    vTime :Cardinal;
  begin
    if FFrames > 0 then begin
      vTime := GetTickCount;
      if vTime - FTime >= 180 then begin
        FTime := vTime;

        if FFrame < FFrames - 1 then
          Inc(FFrame)
        else
          FFrame := 0;

        vRect := Bounds(3, 2, FImgSize.CX, FImgSize.CY);
        InvalidateRect(AItem.Window, @vRect, True);
      end;
      Result := True;
    end else
      Result := True;
  end;


  procedure DrawBitmap(ADC :HDC; ABitmap :HBitmap; dX, dY, dW, dH, sX, sY, sW, sH :Integer);
  var
    vDC :HDC;
    vSave :THandle;
  begin
    vDC := CreateCompatibleDC(0);
    vSave := SelectObject(vDC, ABitmap);

//  SetStretchBltMode(ADC, STRETCH_DELETESCANS);
    SetStretchBltMode(ADC, HALFTONE);
    StretchBlt(ADC, dX, dY, dW, dH, vDC, sX, sY, sW, sH, SrcCopy);

    SelectObject(vDC, vSave);
    DeleteDC(vDC);
  end;


  procedure TPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem);
  begin
    if FIcon <> 0 then
      DrawIconEx(ADC, ARect.Left, ARect.Top, FIcon, AItem.IconWidth, AItem.IconHeight, 0, 0, DI_NORMAL)
    else
    if FCursor <> 0 then begin
      DrawIconEx(ADC, ARect.Left, ARect.Top, FCursor, AItem.IconWidth, AItem.IconHeight, FFrame, 0, DI_NORMAL);
    end else
    if FBitmap <> 0 then begin
      DrawBitmap(ADC, FBitmap, ARect.Left, ARect.Top, AItem.IconWidth, AItem.IconHeight, 0, 0, FImgSize.CX, FImgSize.CY);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.

{$I Defines.inc}

unit FarHintsCursorsMain;

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
    cAnimationStep = 180; {ms}

  var
    ViewSize      :Integer = 48;
    ShowAnimation :Boolean = True;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  type
    TStrMessage = (
      strName,
      strType,
      strModified,
      strSize,
      strDimensions
    );


 {-----------------------------------------------------------------------------}

  function LoadCursorFromFileW(lpFileName :PWideChar): HCURSOR; stdcall; external user32 name 'LoadCursorFromFileW';
    { В стандартном Windows.pas этот прототип описан с ошибкой... }


  function IntMax(L1, L2 :Integer) :Integer;
  begin
    if L1 > L2 then
      Result := L1
    else
      Result := L2;
  end;

 {-----------------------------------------------------------------------------}

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


 {-----------------------------------------------------------------------------}

  { Icon and cursor types }

  const
    rc3_StockIcon = 0;
    rc3_Icon = 1;
    rc3_Cursor = 2;

  type
    PCursorOrIcon = ^TCursorOrIcon;
    TCursorOrIcon = packed record
      Reserved: Word;
      wType: Word;
      Count: Word;
    end;

    PIconRec = ^TIconRec;
    TIconRec = packed record
      Width: Byte;
      Height: Byte;
      Colors: Word;
      Reserved1: Word;
      Reserved2: Word;
      DIBSize: Longint;
      DIBOffset: Longint;
    end;

    PIconRecArray = ^TIconRecArray;
    TIconRecArray = array[0..MaxInt div SizeOf(TIconRec) - 1] of TIconRec;

    PSizes = ^TSizes;
    TSizes = array[0..MaxInt div SizeOf(TSize) - 1] of TSize;


  function ReadIconSizes(const AFileName :WideString; var ASizes :PSizes) :Integer;
  var
    vFile :THandle;
    vInfo :TCursorOrIcon;
    vList :PIconRecArray;
    vRes, vSize :DWORD;
    I, N, L, L1, LI :Integer;
  begin
    Result := 0;
    vList := nil;
    vFile := CreateFile(PWideChar(AFileName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    if vFile <> INVALID_HANDLE_VALUE then begin
      try
        ReadFile(vFile, vInfo, SizeOf(vInfo), vRes, nil);
        if (vInfo.wType <> RC3_ICON) or (vInfo.Count = 0) then
          Exit;

        N := vInfo.Count;

        vSize := SizeOf(TIconRec) * N;
        GetMem(vList, vSize);

        ReadFile(vFile, vList^, vSize, vRes, nil);
        if vSize <> vRes then
          Exit;

        vSize := SizeOf(TSize) * N;
        GetMem(ASizes, vSize);

        L1 := 0;
        while True do begin
          L := MaxInt;
          for I := 0 to N - 1 do begin
            with vList[I], TSmallPoint(LI) do begin
              X := Width;
              if X = 0 then
                X := 256;
              Y := Height;
              if Y = 0 then
                Y := 256;
            end;
            if (LI > L1) and (LI < L) then
              L := LI;
          end;
          if L = MaxInt then
            Exit;
          with ASizes[Result], TSmallPoint(L) do begin
            CX := X;
            CY := Y;
          end;
          Inc(Result);
          L1 := L;
        end;
        
      finally
        FreeMem(vList);
        CloseHandle(vFile);
      end;
    end;
  end;



  function FindNearestSize(ASizeCount :Integer; const ASizes :PSizes; ASize :Integer) :Integer;
  var
    I, N, D, vDelta :Integer;
  begin
    Result := 0;
    vDelta := MaxInt;
    for I := 0 to ASizeCount - 1 do begin
      with ASizes[I] do
        N := IntMax(CX, CY);
      D := Abs(ASize - N);
      if D < vDelta then begin
        vDelta := D;
        Result := I;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function GetFrameCount(ACursor :HCursor) :Integer;
    { Не знаю, как иначе. Для примера - пойдет. }
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
    TPluginObject = class(TInterfacedObject, IHintPlugin, IHintPluginDraw, IHintPluginIdle, IHintPluginCommand)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

      {IHintPluginIdle}
      function Idle(const AItem :IFarItem) :Boolean; stdcall;

      {IHintPluginCommand}
      procedure RunCommand(const AItem :IFarItem; ACommand :Integer); stdcall;

    private
      FAPI       :IFarHintsApi;
      FRegPath   :WideString;
      FFileName  :WideString;
      FIcon      :HIcon;
      FCursor    :HCursor;
      FImgSize   :TSize;
      FSizeCount :Integer;
      FSizeNo    :Integer;
      FSizes     :PSizes;
      FFrame     :Integer;
      FFrames    :Integer;
      FTime      :Cardinal;

      function GetMsg(AIndex :TStrMessage) :WideString;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  const
    cMinimalRevision = 3;
  begin
    FAPI := API;

    if FAPI.GetRevision < cMinimalRevision then
      FAPI.RaiseError(FAPI.Format('FarHints API revision %d is required', [cMinimalRevision]));

    FRegPath := FAPI.GetRegRoot + '\Cursors';
    ShowAnimation := FAPI.GetRegValueInt(HKEY_CURRENT_USER, FRegPath, 'ShowAnimation', Byte(ShowAnimation) ) <> 0;
    ViewSize := FAPI.GetRegValueInt(HKEY_CURRENT_USER, FRegPath, 'MaxSize', ViewSize);
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vExt, vStr :WideString;
  begin
    Result := False;

    FFileName := AItem.FullName;
    vExt := FAPI.ExtractFileExt(FFileName);

    FSizeCount := 0;
    if FAPI.CompareStr(vExt, 'ico') = 0 then begin
      FSizeCount := ReadIconSizes(FFileName, FSizes);

      if FSizeCount > 0 then begin
        FSizeNo := FindNearestSize(FSizeCount, FSizes, ViewSize);
        with FSizes[FSizeNo] do
          FIcon := LoadImage(HInstance, PWideChar(FFileName), IMAGE_ICON, CX, CY, LR_LOADFROMFILE);
      end else
        FIcon := LoadImage(HInstance, PWideChar(FFileName), IMAGE_ICON, 0, 0, LR_LOADFROMFILE or LR_DEFAULTSIZE);

      if FIcon <> 0 then begin
        FImgSize := GetIconSize(FIcon);
        Result := True;
      end;

    end else
    if (FAPI.CompareStr(vExt, 'cur') = 0) or (FAPI.CompareStr(vExt, 'ani') = 0) then begin
      FCursor := LoadCursorFromFileW(PWideChar(FFileName));
      if FCursor <> 0 then begin
        FFrame := 0;
        if FAPI.CompareStr(vExt, 'ani') = 0 then
          FFrames := GetFrameCount(FCursor)
        else
          FFrames := 0;
        FImgSize.CX := GetSystemMetrics(SM_CXCURSOR);
        FImgSize.CY := GetSystemMetrics(SM_CYCURSOR);
        Result := True;
      end;
    end;

    if Result then begin
      AItem.IconFlags := IF_Buffered;
      AItem.IconWidth := FImgSize.CX;
      AItem.IconHeight := FImgSize.CY;

      AItem.AddStringInfo(GetMsg(strName), AItem.Name);

      if FSizeCount = 0 then begin
        vStr := FAPI.Format('%d x %d', [FImgSize.CX, FImgSize.CY]);
        if FFrames > 0 then
          vStr := vStr + FAPI.Format(', %d frames', [FFrames]);
      end else
        vStr := FAPI.Format('%d x %d, %d / %d', [FImgSize.CX, FImgSize.CY, FSizeNo + 1, FSizeCount]);
      AItem.AddStringInfo(GetMsg(strDimensions), vStr);

      AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
      AItem.AddInt64Info(GetMsg(strSize), AItem.Size);

      FTime := GetTickCount;
      Result := True;
    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;


  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
    if FSizes <> nil then begin
      FreeMem(FSizes);
      FSizes := nil;
      FSizeCount := 0;
    end;
    if FIcon <> 0 then begin
      DestroyIcon(FIcon);
      FIcon := 0;
    end else
    if FCursor <> 0 then begin
      DestroyCursor(FCursor);
      FCursor := 0;
      FFrames := 0;
    end;
  end;


  function TPluginObject.Idle(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vTime :Cardinal;
  begin
    if ShowAnimation and (FFrames > 0) then begin
      vTime := GetTickCount;
      if vTime - FTime >= cAnimationStep then begin
        FTime := vTime;
        if FFrame < FFrames - 1 then
          Inc(FFrame)
        else
          FFrame := 0;
        AItem.UpdateHintWindow(uhwInvalidateImage);
      end;
    end;
    Result := True;
  end;


  procedure TPluginObject.RunCommand(const AItem :IFarItem; ACommand :Integer);
  var
    vSizeNo :Integer;
    vNewIcon :HIcon;
  begin
    if FSizeCount > 0 then begin
      vSizeNo := FSizeNo;
      if ACommand = 0 then begin
        if vSizeNo < FSizeCount - 1 then
          Inc(vSizeNo);
      end else
      begin
        if vSizeNo > 0 then
          Dec(vSizeNo);
      end;

      if vSizeNo <> FSizeNo then begin
        with FSizes[vSizeNo] do
          vNewIcon := LoadImage(HInstance, PWideChar(FFileName), IMAGE_ICON, CX, CY, LR_LOADFROMFILE);

        if vNewIcon <> 0 then begin
          if FIcon <> 0 then
            DestroyIcon(FIcon);
          FIcon := vNewIcon;
          FSizeNo := vSizeNo;

          FImgSize := GetIconSize(FIcon);
          AItem.IconWidth := FImgSize.CX;
          AItem.IconHeight := FImgSize.CY;

          AItem.Attrs[1].AsStr := FAPI.Format('%d x %d, %d / %d', [AItem.IconWidth, AItem.IconHeight, FSizeNo + 1, FSizeCount]);

          AItem.UpdateHintWindow(uhwResize + uhwInvalidateItems + uhwInvalidateImage);

          ViewSize := IntMax(FImgSize.CX, FImgSize.CY);
          FAPI.SetRegValueInt(HKEY_CURRENT_USER, FRegPath, 'MaxSize', ViewSize);
        end;
      end;
    end;
  end;


  procedure TPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem);
  begin
    if FIcon <> 0 then
      DrawIconEx(ADC, ARect.Left, ARect.Top, FIcon, AItem.IconWidth, AItem.IconHeight, 0, 0, DI_NORMAL)
    else
    if FCursor <> 0 then
      DrawIconEx(ADC, ARect.Left, ARect.Top, FCursor, AItem.IconWidth, AItem.IconHeight, FFrame, 0, DI_NORMAL);
  end;


  function TPluginObject.GetMsg(AIndex :TStrMessage) :WideString;
  begin
    Result := FAPI.GetMsg(Self, Byte(AIndex));
  end;


 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.

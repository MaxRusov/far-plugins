{$I Defines.inc}

unit FarHintsWin;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    ShellAPI,
    MultiMon,
    Messages,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,
    MixWin,

    FAR_API,
    FarCtrl,

    MSWinAPI,
    FarHintsAPI,
    FarHintsConst,
    FarHintsUtils,
    FarHintsReg,
    MSForms;


  const
    CM_SetItem     = $8FFE;
    CM_RunCommand  = $8FFF;

  const
    cMinThumbSize = 32;
    cMaxThumbSize = 256;  

  type
    PSetItemRec = ^TSetItemRec;
    TSetItemRec = packed record
      Plugin  :Pointer;
      Item    :Pointer;
      Context :THintCallContext;
      Mode    :THintCallMode;
      PosX    :Integer;
      PosY    :Integer;
      Period  :Integer;
    end;


  type
    THintWindow = class;

    ISetWindow = interface
      ['{9641BCA4-CF8A-4304-8D82-C7FBB87BE93E}']
      procedure SetWindow(AWindow :THintWindow);
    end;


    TWinThread = class(TThread)
    public
      constructor Create;
      procedure Execute; override;

    private
      FWindow :THintWindow;

    public
      property Window :THintWindow read FWindow;
    end;


    THintWindow = class(TWindowWithCanvas)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure ShowHint(ASmooth :Boolean = True);
      procedure HideHint;

      procedure MoveWindowTo(X, Y :Integer; ASmooth :Boolean);
      procedure InvalidateIcon;
      procedure InvalidateItems;
      procedure InvalidateHint;

      procedure SetLayered(ASetOn :Boolean);

      function Idle :Boolean;

    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure WndProc(var Mess :TMessage); override;
      procedure PaintWindow(DC :HDC); override;

      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_EraseBkgnd;
      procedure WMPaint(var Mess :TWMPaint); message WM_Paint;
      procedure WMNCHitTest(var Mess :TWMNCHitTest); message WM_NCHitTest;
//    procedure WMMouseActivate(var Mess :TWMMouseActivate); message WM_MouseActivate;
//    procedure WMNCDestroy(var Mess :TWMNCDestroy); message WM_NCDestroy;
      procedure CMSetItem(var Mess :TMessage); message CM_SetItem;
      procedure CMRunCommand(var Mess :TMessage); message CM_RunCommand;

    protected
      FBrush       :HBrush;
      FFont        :HFont;
      FFont2       :HFont;
      FContext     :THintCallContext;
      FCallMode    :THintCallMode;
      FShowTime    :Cardinal;      { Время появления хинта }
      FLifePeriod  :Integer;       { Время жизни хинта }
      FPlugin      :IHintPlugin;
      FItem        :IFarItem;
      FFolder      :Boolean;
      FIcon        :HIcon;         { Extracted image }
      FThumbWait   :Boolean;       { Извлечение продолжается }
      FWaitStart   :Cardinal;      { Для мигания иконки во время извлечения... }
      FWaitPulsed  :Boolean;       { -/-/- }
      FSizeStart   :Cardinal;      { Для временного показа размера эскиза... }
      FBitmap      :HBitmap;       { Thumbnail bitmap }
      FAlpha       :Boolean;       { ... имеет альфа-канал }
      FShowImage   :Boolean;
      FIconSize    :TSize;         { Размер иконки }
      FBitmapSize  :TSize;         { Оригинальный размер bitmap-а эскиза }
      FThumbSize   :TSize;         { Отображаемый размер эскиза }
      FImageSize   :TSize;         { Размер области рисунка (эскиз и/или иконка или рисунок субплагина) }
      FInitPosX    :Integer;
      FInitPosY    :Integer;
      FShowPrompt  :Boolean;
      FTransp      :byte;
      FFontSize1   :Integer;
      FFontSize2   :Integer;
      FFontColor1  :Integer;
      FFontColor2  :Integer;
      FColor1      :Integer;
      FColor2      :Integer;
      FDelta1      :Integer;       { Вспом. размер }

      procedure UpdateIcon(ANewIcon :Boolean);
      procedure DoneIcon;
      function IdleCall :Boolean;
     {$ifdef bThumbnail}
      procedure CheckForUpdatedThumbnail;
      procedure SetThumbnail(ABitmap :HBitmap; AAlpha :Boolean);
     {$endif bThumbnail}

      function CalcSize :TSize;
      function CalcHintTextSize :TSize;
      function GetImageRect :TRect;
      function GetOverlayIconRect :TRect;
      procedure InvalidateImageHeader;
      procedure DrawHintText(DC :HDC; const ARect :TRect);
      function GetText(const AAttr :IFarItemAttr) :TString;
      procedure SmoothShowOrHide(AShow :Boolean);

    public
      property Context :THintCallContext read FContext;
      property CallMode :THintCallMode read FCallMode;
      property ShowTime :Cardinal read FShowTime;
      property Item :IFarItem read FItem;
    end;


  var
    gStockFont :HFont;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function TextSize(AFont :HFont; const AStr :TString; AMaxWidth :Integer) :TSize;
  var
    vDC :HDC;
    vOld :HGDIOBJ;
    vRect :TRect;
  begin
    vDC := CreateCompatibleDC(0);
    vOld := SelectObject(vDC, AFont);
    try

      vRect := Rect(0, 0, AMaxWidth, 0);
      DrawText(vDC, PTChar(AStr), -1, vRect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_EXPANDTABS);
      Result.CX := vRect.Right;
      Result.CY := vRect.Bottom;

    finally
      SelectObject(vDC, vOld);
      DeleteDC(vDC);
    end;
  end;


  procedure DrawBitmap(ADC :HDC; ABitmap :HBitmap; dX, dY, dW, dH, sX, sY, sW, sH :Integer; AAlpha :Boolean);
  var
    vDC :HDC;
    vSave :THandle;
    vFN :_BLENDFUNCTION;
  begin
    vDC := CreateCompatibleDC(0);
    vSave := SelectObject(vDC, ABitmap);

//  SetStretchBltMode(ADC, WHITEONBLACK);
    SetStretchBltMode(ADC, HALFTONE);
//  SetBkMode(ADC, NEWTRANSPARENT);

    if AAlpha then begin
      FillChar(vFN, SizeOf(vFN), 0);
      vFN.SourceConstantAlpha := 255;
      vFN.BlendFlags := 0;
      vFN.AlphaFormat := AC_SRC_ALPHA;
      AlphaBlend(ADC, dX, dY, dW, dH, vDC, sX, sY, sW, sH, vFN);
    end else
      StretchBlt(ADC, dX, dY, dW, dH, vDC, sX, sY, sW, sH, SrcCopy);

    SelectObject(vDC, vSave);
    DeleteDC(vDC);
  end;


  procedure GradientFillRect(AHandle :THandle; const ARect :TRect; AColor1, AColor2 :TColor; AVert :Boolean);
  const
    FillFlag :Array[Boolean] of Integer = (GRADIENT_FILL_RECT_H, GRADIENT_FILL_RECT_V);
  var
    VA :array[0..1] of TTriVertex;
    GR :TGradientRect;
  begin
    VA[0].X := ARect.Left;
    VA[0].Y := ARect.Top;
    with RGBRec(ColorToRGB(AColor1)) do begin
      VA[0].Red := Red*255;
      VA[0].Green := Green*255;
      VA[0].Blue := Blue*255;
      VA[0].Alpha := 0;
    end;

    VA[1].X := ARect.Right;
    VA[1].Y := ARect.Bottom;
    with RGBRec(ColorToRGB(AColor2)) do begin
      VA[1].Red := Red*255;
      VA[1].Green := Green*255;
      VA[1].Blue := Blue*255;
      VA[1].Alpha := 0;
    end;

    GR.UpperLeft := 0;
    GR.LowerRight := 1;
    GradientFill(AHandle, @VA[0], 2, @GR, 1, FillFlag[AVert]);
  end;


  procedure CorrectBoundsRectEx(var ARect :TRect; const AMonRect :TRect);
  begin
    if ARect.Right > AMonRect.Right then
      RectMove(ARect, AMonRect.Right - ARect.Right, 0);
    if ARect.Bottom > AMonRect.Bottom then
      RectMove(ARect, 0, AMonRect.Bottom - ARect.Bottom);
    if ARect.Left < AMonRect.Left then
      RectMove(ARect, AMonRect.Left - ARect.Left, 0);
    if ARect.Top < AMonRect.Top then
      RectMove(ARect, 0, AMonRect.Top - ARect.Top);
  end;


  function MonitorRectFromPoint(const APoint :TPoint) :TRect;
  var
    vMonInfo :TMonitorInfo;
    vHM :HMONITOR;
  begin
    FillChar(vMonInfo, SizeOf(vMonInfo), 0);
    vMonInfo.cbSize := SizeOf(vMonInfo);
    vHM := MonitorFromPoint(APoint, MONITOR_DEFAULTTONEAREST);
    if vHM <> 0 then begin
      GetMonitorInfo(vHM, @vMonInfo);
      Result := vMonInfo.rcWork;
    end else
      Result := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
  end;


  procedure CorrectBoundsRectForPoint(var ARect :TRect; const APoint :TPoint);
  var
    vRect :TRect;
  begin
    vRect := MonitorRectFromPoint(APoint);
    CorrectBoundsRectEx(ARect, vRect);
  end;


  procedure CorrectMaxSize(var ASize :TSize; MaxSize :Integer);
  begin
    if ASize.cx > ASize.cy then begin
      ASize.cy := MulDiv(ASize.cy, MaxSize, ASize.cx);
      ASize.cx := MaxSize;
    end else
    begin
      ASize.cx := MulDiv(ASize.cx, MaxSize, ASize.cy);
      ASize.cy := MaxSize;
    end;
  end;


  function ColorShadeOn(Color :TColor; Delta :Integer) :TColor;
  begin
    with RGBRec(ColorToRGB(Color)) do
      Result := RGB(
        RangeLimit(Red + Delta, 0, 255),
        RangeLimit(Green + Delta, 0, 255),
        RangeLimit(Blue + Delta, 0, 255));
  end;


 {-----------------------------------------------------------------------------}
 { THintWindow                                                                 }
 {-----------------------------------------------------------------------------}

  constructor THintWindow.Create; {override;}
  begin
    inherited Create;

    FTransp := FarHintTransp;
    FFontSize1 := FarHintFontSize;
    FFontSize2 := FarHintFontSize2;
    FFontColor1 := FarHintFontColor;
    FFontColor2 := FarHintFontColor2;

    FColor1 := FarHintColor;
    FColor2 := FarHintColor2;
    if (FColor2 = -1) and (FarHintColorFade <> 0) then
      FColor2 := ColorShadeOn(ColorToRGB(FarHintColor), FarHintColorFade);

    FBrush := CreateSolidBrush(FColor1);

    FFont := WinCreateFont(FarHintFontName, FFontSize1, FarHintFontStyle);
    FFont2 := WinCreateFont(FarHintFontName2, FFontSize2, FarHintFontStyle2);
  end;


  destructor THintWindow.Destroy; {override;}
  begin
    DoneIcon;
    if FPlugin <> nil then
      FPlugin.DoneItem(FItem);
    if FBrush <> 0 then
      DeleteObject(FBrush);
    if FFont <> 0 then
      DeleteObject(FFont);
    if FFont2 <> 0 then
      DeleteObject(FFont2);
    inherited Destroy;
  end;


  procedure THintWindow.DoneIcon;
  begin
    if FBitmap <> 0 then begin
      DeleteObject(FBitmap);
      FBitmap := 0;
    end;
    if FIcon <> 0 then begin
      DestroyIcon(FIcon);
      FIcon := 0;
    end;
  end;


  procedure THintWindow.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams); {CreateWindow}

//  AParams.WindowClass.Style := CS_SAVEBITS;
    with AParams.WindowClass do
      Style := Style and not (CS_HREDRAW or CS_VREDRAW);

    AParams.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    AParams.Style := WS_BORDER or WS_POPUP;

    if CheckWin32Version(5, 1) then
      With AParams.WindowClass do
        Style := Style or CS_DROPSHADOW;
  end;


  procedure THintWindow.WndProc(var Mess :TMessage); {override;}
  begin
    inherited WndProc(Mess);
  end;


  procedure THintWindow.WMNCHitTest(var Mess :TWMNCHitTest); {message WM_NCHitTest;}
  begin
    Mess.Result := HTTRANSPARENT;
  end;


//procedure THintWindow.WMMouseActivate(var Mess :TWMMouseActivate); {message WM_MouseActivate;}
//begin
//  Mess.Result := MA_NoActivate;
//end;


//procedure THintWindow.WMNCDestroy(var Mess :TWMNCDestroy); {message WM_NCDestroy;}
//begin
//  Inherited;
//end;


  procedure THintWindow.UpdateIcon(ANewIcon :Boolean);
  var
    vName :TString;
    vThumbSize :Integer;
   {$ifdef bThumbnail}
    vBitmap :HBitmap;
    vAlpha :Boolean;
   {$endif bThumbnail}
  begin
    if ANewIcon then
      DoneIcon;
    if FarHintShowIcon and ((FItem.IconWidth = 0) or (FItem.IconHeight = 0)) and not FItem.IsPlugin then begin
      vName := FItem.FullName;
      if FileOrFolderExists(vName) then begin

        FThumbWait := False;
        FSizeStart := 0;

        vThumbSize := IntIf(not FFolder, FarHintThumbSize1, FarHintThumbSize2);

       {$ifdef bThumbnail}
        if vThumbSize >= cMinThumbSize then begin
          vBitmap := 0;
          FThumbWait := not AsyncGetFileThumbnail(vName, vThumbSize, vBitmap, vAlpha);
          if vBitmap <> 0 then
            SetThumbnail(vBitmap, vAlpha);
        end else
          DoneIcon;
       {$endif bThumbnail}

        if (FBitmap = 0) or (FarHintIconOnThumb and not FFolder) then
          FIcon := GetFileIcon(vName, (FBitmap = 0) or (vThumbSize >= 96));

       {$ifdef bThumbnail}
        if FThumbWait then
          { Может уже готово? }
          CheckForUpdatedThumbnail;

        if FThumbWait then
          FWaitStart := GetTickCount;
        FWaitPulsed := False;
       {$endif bThumbnail}
      end;
    end;
  end;


  procedure THintWindow.CMSetItem(var Mess :TMessage); {message CM_SetItem;}

    procedure LocSetWindow(const AItem :IFarItem; AWindow :THintWindow);
    var
      vIntf :ISetWindow;
    begin
      AItem.QueryInterface(ISetWindow, vIntf);
      vIntf.SetWindow(AWindow);
    end;

    procedure SetItem(const APlugin :IHintPlugin; const AItem :IFarItem);
    begin
      if FPlugin <> nil then
        FPlugin.DoneItem(FItem);

      if FItem <> nil then
        LocSetWindow(FItem, nil);

      FPlugin := APlugin;
      FItem := AItem;

      FFolder := False;
      if FItem <> nil then begin
        FFolder := FItem.Attr and faDirectory <> 0;
        LocSetWindow(FItem, Self);
      end;
    end;

  var
    vVisible :Boolean;
  begin
//  Trace('THintWindow.CMSetItem');
    with PSetItemRec(Mess.LParam)^ do begin

      FContext := Context;
      FCallMode := Mode;
      FInitPosX := PosX;
      FInitPosY := PosY;
      FShowPrompt := FarHintShowPrompt and (FCallMode <> hcmInfo);
      SetItem(IHintPlugin(Plugin), IFarItem(Item));

      if FItem <> nil then begin
        vVisible := (FCallMode <> hcmInfo) or (FItem.Name <> '');
        if not vVisible then
          HideHint
        else begin
          UpdateIcon(True);
          MoveWindowTo(FInitPosX, FInitPosY, True);

          if not IsWindowVisible(Handle) then
            ShowHint(Mode <> hcmInfo)
          else
            InvalidateHint;
        end
      end;

      FShowTime := GetTickCount;
      FLifePeriod := Period;
    end;
  end;


  procedure THintWindow.CMRunCommand(var Mess :TMessage); {message CM_RunCommand;}

    procedure LocResize(AInc :Boolean);
    var
      vPSize :PInteger;
      vSize, vOldSize :Integer;
      vCmdIntf :IHintPluginCommand;
    begin
      FPlugin.QueryInterface(IHintPluginCommand, vCmdIntf);
      if vCmdIntf <> nil then begin

        vCmdIntf.RunCommand(FItem, IntIf(AInc, 0, 1));

        if IF_HideSizeLabel and FItem.IconFlags = 0 then begin
          FSizeStart := GetTickCount;
          InvalidateImageHeader;
        end;

      end else
      if FarHintShowIcon { and ... } then begin
        if not FFolder then
          vPSize := @FarHintThumbSize1
        else
          vPSize := @FarHintThumbSize2;

        if (FBitmap <> 0) or (vPSize^ < cMinThumbSize) then begin
          { Изменение размера эскиза... }
//        vSize := IntMax(FThumbSize.CX, FThumbSize.CY);
          vSize := vPSize^;
          vOldSize := vSize;

          if AInc then
            vSize := RangeLimit(vSize + 16, cMinThumbSize, cMaxThumbSize)
          else begin
            vSize := vSize - 16;
            if vSize < cMinThumbSize then
              vSize := 0;
          end;

          if vSize <> vOldSize then begin
            vPSize^ := vSize;
            GNeedWriteSizeSettings := True;

//          TraceF('Size: %d', [vSize]);
            UpdateIcon(False);
            FSizeStart := GetTickCount;

            MoveWindowTo(FInitPosX, FInitPosY, False);
            Invalidate;
          end else
          begin
            FSizeStart := GetTickCount;
            InvalidateImageHeader;
          end;

        end else
        begin
          {Изменение размеров иконки...}

        end;
      end;
    end;

    procedure LocSetColor(AValue :Integer);
    begin
      if FColor1 <> AValue then begin

        FColor1 := AValue;
        FColor2 := -1;
        if FarHintColorFade <> 0 then
          FColor2 := ColorShadeOn(ColorToRGB(FColor1), FarHintColorFade);

        if FBrush <> 0 then
          DeleteObject(FBrush);
        FBrush := CreateSolidBrush(FColor1);

        Invalidate;
      end;
    end;

    procedure LocSetFontColor(AValue :Integer);
    begin
      if FFontColor1 <> AValue then begin
        FFontColor1 := AValue;
        Invalidate;
      end;
    end;

    procedure LocSetFontSize(AValue :Integer);
    begin
//    TraceF('LocSetFontSize %d...', [AValue]);
      if FFontSize1 <> AValue then begin
        FFontSize1 := AValue;

        if FFont <> 0 then
          DeleteObject(FFont);
        FFont := WinCreateFont(FarHintFontName, FFontSize1, FarHintFontStyle);

        MoveWindowTo(FInitPosX, FInitPosY, False);
        Invalidate;
      end;
    end;

    procedure LocSetTransparent(AValue :Integer);
    begin
//    TraceF('LocSetTransparent %d...', [AValue]);
      if FTransp <> AValue then begin
        FTransp := AValue;
        SetLayered(True);
        SetLayeredWindowAttributes(Handle, 0, FTransp, LWA_ALPHA);
      end;
    end;

  begin
    if FPlugin <> nil then begin
     {$ifdef bTrace1}
//    TraceF('CMRunCommand. WParam=%d, LParam=%d...', [Mess.WParam, Mess.LParam]);
     {$endif bTrace1}

      case Mess.wParam of
        cmhResize:
          LocResize(Mess.lParam > 0);
        cmhColor:
          LocSetColor(Mess.lParam);
        cmhFontColor:
          LocSetFontColor(Mess.lParam);
        cmhFontSize:
          LocSetFontSize(Mess.lParam);
        cmhTransparent:
          LocSetTransparent(Mess.lParam);
      end;
    end;
  end;


  procedure THintWindow.ShowHint(ASmooth :Boolean = True);
  begin
    if ASmooth and ((FarHintsShowPeriod > 0) or (FTransp < 255)) and Assigned(SetLayeredWindowAttributes) then
      SmoothShowOrHide(True)
    else
      Show(SW_SHOWNA);
  end;


  procedure THintWindow.HideHint;
  begin
    if (FarHintsShowPeriod > 0) and Assigned(SetLayeredWindowAttributes) then
      SmoothShowOrHide(False);  
    Show(SW_Hide);

    if GNeedWriteSizeSettings then
      FarAdvControl(ACTL_SYNCHRO, scmSaveSettings);
    GNeedWriteSizeSettings := False;
  end;


  procedure THintWindow.SetLayered(ASetOn :Boolean);
  var
    vStyle: Integer;
  begin
    if not Assigned(SetLayeredWindowAttributes) then
      Exit;
    vStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if ASetOn <> ( vStyle and WS_EX_LAYERED <> 0 ) then begin
      if ASetOn then
        SetWindowLong(Handle, GWL_EXSTYLE, vStyle or WS_EX_LAYERED)
      else
        SetWindowLong(Handle, GWL_EXSTYLE, vStyle and not WS_EX_LAYERED);
    end;
  end;


  procedure THintWindow.SmoothShowOrHide(AShow :Boolean);
  const
    MaxStep = 20;

    procedure LocSetAlphaBlend(AValue :Integer);
    begin
      SetLayeredWindowAttributes(Handle, 0, AValue, LWA_ALPHA);
    end;

  var
    I, vLimit :Integer;
    vTime :Cardinal;
  begin
//  FarHintsShowPeriod := 250;

    vLimit := RangeLimit(FTransp, 0, 255);

    if AShow then begin
      SetLayered(True);
      LocSetAlphaBlend(0);
      Show(SW_SHOWNA);
      UpdateWindow(Handle);
    end else
    begin
      { Под XP не получается аккуратно включить Layered атрибут - промаргивает черное пятно :( }
      if CheckWin32Version(6, 0) then
        if GetWindowLong(Handle, GWL_EXSTYLE) and WS_EX_LAYERED = 0 then begin
          SetLayered(True);
          LocSetAlphaBlend(vLimit);
          UpdateWindow(Handle);
        end;
    end;

    vTime := GetTickCount;
    for I := 1 to MaxStep do begin
      if AShow then
        LocSetAlphaBlend( MulDiv(vLimit, I, MaxStep) )
      else
        LocSetAlphaBlend( MulDiv(vLimit, MaxStep - I, MaxStep) );
      while TickCountDiff(GetTickCount, vTime) < MulDiv(FarHintsShowPeriod, I, MaxStep) do
        Sleep(1);
      if TickCountDiff(GetTickCount, vTime) > FarHintsShowPeriod then
        Break;
    end;

    if AShow then begin
      LocSetAlphaBlend( vLimit );
      { Лучше бы, конечно, сразу выключать Layered, но тогда под XP плохо работает SmoothHide }
      { Используем компромиссный вариант - выключаем Layered, если окно Resize'ится... }
//    if vLimit = 255 then
//      SetLayered(False);
    end;
  end;


  procedure THintWindow.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
    if FColor2 = -1 then
      FillRect(Mess.DC, ClientRect, FBrush)
    else
      GradientFillRect(Mess.DC, ClientRect, FColor1, FColor2, True);
    Mess.Result := 1;
  end;


  procedure THintWindow.WMPaint(var Mess :TWMPaint); {message WM_Paint;}
  var
    PS :TPaintStruct;
    vDC, vMemDC :HDC;
    vBmp, vOldBmp: HBITMAP;
    vRect :TRect;
  begin
    if (FItem <> nil) and (IF_Buffered and FItem.IconFlags <> 0) and (Mess.DC = 0) then begin
      vRect := ClientRect;

      vDC := GetDC(0);
      vBmp := CreateCompatibleBitmap(vDC, vRect.Right, vRect.Bottom);
      ReleaseDC(0, vDC);

      vMemDC := CreateCompatibleDC(0);
      vOldBmp := SelectObject(vMemDC, vBmp);
      try
        vDC := BeginPaint(Handle, PS);
        Perform(WM_ERASEBKGND, Longint(vMemDC), Longint(vMemDC));
        Mess.DC := vMemDC;
        WMPaint(Mess);
        Mess.DC := 0;
        BitBlt(vDC, 0, 0, vRect.Right, vRect.Bottom, vMemDC, 0, 0, SRCCOPY);
        EndPaint(Handle, PS);
      finally
        SelectObject(vMemDC, vOldBmp);
        DeleteObject(vBmp);
        DeleteDC(vMemDC);
      end;

    end else
      inherited;
  end;


  procedure THintWindow.PaintWindow(DC :HDC); {override;}
  var
    vRect, vRect1 :TRect;
    vDrawIntf :IHintPluginDraw;
    vStr :TString;
    vSize :TSize;
  begin
    if FItem <> nil then begin
      vRect := ClientRect;
      Inc(vRect.Left, HMargin);
      Inc(vRect.Top, VMargin);

(*
      FCanvas.Brush.Color := FBrush.Color;
*)

      if FShowImage then begin
        vSize := FImageSize;

        if (FItem.IconWidth > 0) and (FItem.IconHeight > 0) then begin
          vRect1 := Bounds(vRect.Left, vRect.Top, FImageSize.CX, FImageSize.CY);
          FPlugin.QueryInterface(IHintPluginDraw, vDrawIntf);
          if vDrawIntf <> nil then
            vDrawIntf.DrawIcon( DC, vRect1, FItem );
        end else
        begin
          if FBitmap <> 0 then begin
            vSize := FThumbSize;

            DrawBitmap(DC, FBitmap, vRect.Left, vRect.Top, FThumbSize.CX, FThumbSize.CY, 0, 0, FBitmapSize.CX, FBitmapSize.CY,
              FAlpha and FFolder { Затычка...}  );

            if (FarHintIconOnThumb and not FFolder) and (FIcon <> 0) and not FWaitPulsed then
              with GetOverlayIconRect do
                DrawIconEx(DC, Left, Top, FIcon, Right - Left, Bottom - Top, 0, 0, DI_NORMAL);

          end else
          if FIcon <> 0 then begin
            if not FWaitPulsed then
              DrawIconEx(DC, vRect.Left, vRect.Top, FIcon, FImageSize.CX, FImageSize.CY, 0, 0, DI_NORMAL);
          end;
        end;

        if FSizeStart <> 0 then begin
          SetBkMode(DC, TRANSPARENT);
          vRect1 := Bounds(vRect.Left, vRect.Top, vSize.CX, vSize.CY );
          vStr := Format('%d x %d', [vSize.CX, vSize.CY]);
          SelectObject(DC, FFont2);
          SetTextColor(DC, clBlack);
          DrawText(DC, PTChar(vStr), -1, vRect1, DT_CENTER );
          RectMove(vRect1, -1, -1);
          SetTextColor(DC, clWhite);
          DrawText(DC, PTChar(vStr), -1, vRect1, DT_CENTER );
          SelectObject(DC, gStockFont);
        end;

        Inc(vRect.Left, FImageSize.CX + HSplit1);
      end;

      DrawHintText(dc, vRect);
    end;
  end;


  function THintWindow.CalcHintTextSize :TSize;
  var
    I :Integer;
    W1, W2, H :Integer;
    vStr :TString;
    vAttr :IFarItemAttr;
    vSize :TSize;
  begin
    Result.cy := 0;
    W1 := 0; W2 := 0;
    for I := 0 to FItem.AttrCount - 1 do begin
      vAttr := FItem.Attrs[I];

      H := 0;
      if FShowPrompt then begin
        vStr := vAttr.Name + ':';
        vSize := TextSize(FFont2, vStr, FarHintsMaxWidth);
        Inc(vSize.cx, HSplit2);
        if vSize.cx > W1 then
          W1 := vSize.cx;
        if vSize.cy > H then
          H := vSize.cy;
      end;

      vStr := GetText(vAttr);
      vSize := TextSize(FFont, vStr, FarHintsMaxWidth);
      if vSize.cx > W2 then
        W2 := vSize.cx;
      if vSize.cy > H then
        H := vSize.cy;
      Inc(Result.cy, H);

    end;
    Result.cx := W1 + W2;
    FDelta1 := W1;
  end;


  function THintWindow.CalcSize :TSize;
  begin
    Result := CalcHintTextSize;

    FShowImage := False;
    if (FItem.IconWidth > 0) and (FItem.IconHeight > 0) then begin
      FShowImage := True;
      FImageSize := Size(FItem.IconWidth, FItem.IconHeight);
    end else
    begin
      if FIcon <> 0 then
        FIconSize := GetIconSize(FIcon);

      if FBitmap <> 0 then begin
        FShowImage := True;
        FBitmapSize := GetBitmapSize(FBitmap);
        FThumbSize := FBitmapSize;
        CorrectMaxSize(FThumbSize, IntIf(not FFolder, FarHintThumbSize1, FarHintThumbSize2));
        FImageSize := FThumbSize;
        if (FarHintIconOnThumb and not FFolder) and (FIcon <> 0) then begin
          Inc(FImageSize.cx, FIconSize.cx div 4);
          Inc(FImageSize.cy, FIconSize.cy div 4);
        end;
      end else
      if FIcon <> 0 then begin
        FShowImage := True;
        FImageSize := FIconSize;
      end;
    end;

    if FShowImage then begin
      if Result.CX > 0 then
        Inc(Result.CX, HSplit1);
      Inc(Result.CX, FImageSize.CX);
      Result.CY := IntMax(Result.CY, FImageSize.CY);
    end;

    Inc( Result.CX, HMargin * 2 + 2);
    Inc( Result.CY, VMargin * 2 + 2);
  end;


  procedure THintWindow.DrawHintText(DC :HDC; const ARect :TRect);
  var
    I, Y, H :Integer;
    vStr :TString;
    vAttr :IFarItemAttr;
    vRect :TRect;
  begin
    SetBkMode(DC, TRANSPARENT);
    Y := ARect.Top;
    for I := 0 to FItem.AttrCount - 1 do begin
      vAttr := FItem.Attrs[I];
      H := 0;

      if FShowPrompt then begin
        vStr := vAttr.Name + ':';
        vRect := ARect;
        vRect.Top := Y;
        SelectObject(DC, FFont2);
        SetTextColor(DC, FFontColor2);
        DrawText(DC, PTChar(vStr), -1, vRect, DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_EXPANDTABS);
        DrawText(DC, PTChar(vStr), -1, vRect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_EXPANDTABS);
        H := vRect.Bottom - vRect.Top;
      end;

      vStr := GetText(vAttr);
      vRect := ARect;
      vRect.Top := Y;
      Inc(vRect.Left, FDelta1);
      SelectObject(DC, FFont);
      SetTextColor(DC, FFontColor1);
      DrawText(DC, PTChar(vStr), -1, vRect, DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_EXPANDTABS);
      DrawText(DC, PTChar(vStr), -1, vRect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_EXPANDTABS);
      if vRect.Bottom - vRect.Top > H then
        H := vRect.Bottom - vRect.Top;

      SelectObject(DC, gStockFont);

      Inc(Y, H);
    end;
  end;


  function THintWindow.GetText(const AAttr :IFarItemAttr) :TString;
  begin
    case AAttr.AttrType of
      fvtString:
        Result := AAttr.AsStr;
      fvtInteger:
        Result := Int2Str(AAttr.AsInt);
      fvtInt64:
        Result := Int64ToStrEx(AAttr.AsInt64);
      fvtDate:
        Result := DateTimeToStr(AAttr.AsDateTime);  (* FormatDateTime(FarHintsDateFormat, AAttr.AsDateTime); *)   {!!!}
    end;
  end;


  procedure THintWindow.MoveWindowTo(X, Y :Integer; ASmooth :Boolean);
  var
    I, Xi, Yi, vFlags :Integer;
    vDestRect, vSrcRect :TRect;
    vSize :TSize;
    vWnd :THandle;
  begin
    vSize := CalcSize;

    if X = -1 then begin
      vWnd := hConsoleWnd;
      Windows.GetClientRect(vWnd, vSrcRect);
      Windows.ClientToScreen(vWnd, vSrcRect.TopLeft);
      Windows.ClientToScreen(vWnd, vSrcRect.BottomRight);
      X := (vSrcRect.Left + vSrcRect.Right - vSize.cx) div 2;
    end;

    vDestRect := Bounds(X, Y, vSize.CX, vSize.CY);
    CorrectBoundsRectForPoint(vDestRect, Point(X, Y));

    vFlags := 0;
    if IsWindowVisible(FHandle) then begin

      if ASmooth and (FarHintSmothSteps > 0) then begin
        { Типа плавное перемещение }
        vSrcRect := GetBoundsRect;
        for I := 1 to FarHintSmothSteps do begin
          Xi := vSrcRect.Left + MulDiv( vDestRect.Left - vSrcRect.Left, I, FarHintSmothSteps);
          Yi := vSrcRect.Top + MulDiv( vDestRect.Top - vSrcRect.Top, I, FarHintSmothSteps);
          SetWindowPos(Xi, Yi);
          Sleep(1);
        end;
      end;

      if GetWindowLong(Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> 0 then begin
        vSrcRect := GetBoundsRect;
        if (vSrcRect.Right - vSrcRect.Left <> vDestRect.Right - vDestRect.Left) or (vSrcRect.Bottom - vSrcRect.Top <> vDestRect.Bottom - vDestRect.Top) then begin
          if FTransp = 255 then
            { Выключение режима Layered повышает быстродействие масштабирования и уменьшает моргание... }
            SetLayered(False)
          else
            vFlags := SWP_NOREDRAW;
        end;
      end;
    end;

    SetBounds(vDestRect, vFlags);
  end;


  function THintWindow.GetImageRect :TRect;
  begin
    Result := Bounds(HMargin, VMargin, FImageSize.CX, FImageSize.CY);
  end;


  function THintWindow.GetOverlayIconRect :TRect;
  begin
    Result := Bounds(HMargin + FImageSize.CX - FIconSize.cx, VMargin + FImageSize.CY - FIconSize.cy, FIconSize.cx, FIconSize.cy);
    if Result.Top < VMargin then
      RectMove(Result, 0, VMargin - Result.Top);
    if Result.Left < HMargin then
      RectMove(Result, HMargin - Result.Left, 0);
  end;


  procedure THintWindow.InvalidateIcon;
  var
    vRect :TRect;
  begin
    if FShowImage then begin
      if FBitmap <> 0 then
        vRect := GetOverlayIconRect
      else
        vRect := GetImageRect;
      InvalidateRect(FHandle, @vRect,
        not (IF_Solid and FItem.IconFlags <> 0) and not (IF_Buffered and FItem.IconFlags <> 0) );  
    end;
  end;


  procedure THintWindow.InvalidateImageHeader;
  var
    vRect :TRect;
  begin
    vRect := GetImageRect;
    vRect.Bottom := vRect.Top + TextSize(FFont2, ' ', FarHintsMaxWidth).CY;
    InvalidateRect(FHandle, @vRect, True {not FItem.Buffered} );
  end;


  procedure THintWindow.InvalidateItems;
  var
    vRect :TRect;
  begin
    vRect := ClientRect;
    if FShowImage then
      Inc(vRect.Left, FImageSize.CX + HSplit1);
    InvalidateRect(FHandle, @vRect, True);
  end;


  procedure THintWindow.InvalidateHint;
  var
    vRgn1, vRgn2 :HRGN;
    vRect :TRect;
  begin
    if (IF_Solid and FItem.IconFlags <> 0) or (IF_Buffered and FItem.IconFlags <> 0) then begin
      vRect := GetImageRect;

      with ClientRect do
        vRgn1 := CreateRectRgn(Left, Top, Right, Bottom);
      with vRect do
        vRgn2 := CreateRectRgn(Left, Top, Right, Bottom);
      try
        { Перерисовываем все, за исключением картинки }
        if CombineRgn(vRgn1, vRgn1, vRgn2, RGN_XOR) in [SimpleRegion, ComplexRegion] then
          RedrawWindow(FHandle, nil, vRgn1, RDW_INVALIDATE or RDW_ERASE or RDW_ERASENOW);
      finally
        DeleteObject(vRgn1);
        DeleteObject(vRgn2);
      end;

      { Перерисовываем картинку }
      InvalidateRect(FHandle, @vRect, False);

    end else
      Invalidate;
  end;


  function THintWindow.IdleCall :Boolean;
  var
    vIdleIntf :IHintPluginIdle;
  begin
    Result := True;
//  Result := FPlugin.Idle(FItem);
    FPlugin.QueryInterface(IHintPluginIdle, vIdleIntf);
    if vIdleIntf <> nil then
      Result := vIdleIntf.Idle(FItem);
  end;


  function THintWindow.Idle :Boolean;
 {$ifdef bThumbnail}
  var
    vTime :Cardinal;
 {$endif bThumbnail}
  begin
    Result := True;
    if FPlugin <> nil then begin
      try
       {$ifdef bThumbnail}
        if FThumbWait then begin
          CheckForUpdatedThumbnail;

          if FThumbWait then begin
            vTime := GetTickCount;
            if TickCountDiff(vTime, FWaitStart) > 100 then begin
              FWaitStart := vTime;
              FWaitPulsed := not FWaitPulsed;
              InvalidateIcon;
            end;
          end else
          begin
            if (FBitmap <> 0) or FWaitPulsed then begin
              FWaitPulsed := False;
              MoveWindowTo(FInitPosX, FInitPosY, False);
              Invalidate;
            end;
          end;
        end;
       {$endif bThumbnail}

        if (FSizeStart <> 0) and (TickCountDiff(GetTickCount, FSizeStart) > 1000) then begin
          FSizeStart := 0;
          InvalidateImageHeader;
        end;

        if (FLifePeriod > 0) and (TickCountDiff(GetTickCount, FShowTime) > FLifePeriod) then begin
          FLifePeriod := 0;
          FarAdvControl(ACTL_SYNCHRO, scmHideHint);
        end;

        Result := IdleCall;

      except
        {Nothing}
      end;
    end;
  end;


 {$ifdef bThumbnail}
  procedure THintWindow.CheckForUpdatedThumbnail;
  var
    vBitmap :HBitmap;
    vAlpha :Boolean;
  begin
    FThumbWait := not AsyncCheckFileThumbnail(vBitmap, vAlpha);
    if vBitmap <> 0 then
      { Появился обновленный эскиз }
      SetThumbnail(vBitmap, vAlpha);
  end;


  procedure THintWindow.SetThumbnail(ABitmap :HBitmap; AAlpha :Boolean);
  begin
    if ABitmap <> 0 then begin
      if FBitmap <> 0 then begin
        DeleteObject(FBitmap);
        FBitmap := 0;
      end;

      FBitmap := ABitmap;
      FAlpha := AAlpha;
    end;
  end;
 {$endif bThumbnail}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  constructor TWinThread.Create;
  begin
    inherited Create(False);
//  FWindow := THintWindow.Create;
//  FreeOnTerminate := True;
  end;


  procedure TWinThread.Execute; {override;}
  var
    vMsg :TMsg;
  begin
    PeekMessage(vMsg, 0, WM_USER, WM_USER, PM_NOREMOVE); { Create message queue }

    CoInitialize(nil);
    FWindow := THintWindow.Create;
    try

      while not Terminated do begin
        while PeekMessage(vMsg, 0, 0, 0, PM_REMOVE) do begin
          TranslateMessage(vMsg);
          DispatchMessage(vMsg);
        end;
        if FWindow.Idle then
          Sleep(1);
      end;

      FWindow.HideHint;

    finally
      FreeObj(FWindow);
      CoUninitialize;
    end;
  end;


initialization
//TraceF('SizeOf(TMsg)=%d', [SizeOf(TMsg)]);
//TraceF('SizeOf(TMessage)=%d', [SizeOf(TMessage)]);
//TraceF('SizeOf(TWMNCHitTest)=%d', [SizeOf(TWMNCHitTest)]);
//TraceF('SizeOf(TWMKey)=%d', [SizeOf(TWMKey)]);
//TraceF('SizeOf(TWMMenuChar)=%d', [SizeOf(TWMMenuChar)]);
//TraceF('SizeOf(TWMPaint)=%d', [SizeOf(TWMPaint)]);
//TraceF('SizeOf(TPaintStruct)=%d', [SizeOf(TPaintStruct)]);
//TraceF('SizeOf(TMsg)=%d', [SizeOf(TMsg)]);
//TraceF('SizeOf(TRTLCriticalSection)=%d', [SizeOf(TRTLCriticalSection)]);

  InitLayeredWindow;
  gStockFont := GetStockObject(SYSTEM_FONT);
end.

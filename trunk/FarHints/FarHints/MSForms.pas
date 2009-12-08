{$I Defines.inc}

unit MSForms;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWin,

    FarHintsConst;


  type
    TWindowWithCanvas = class(TMSWindow)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure PaintWindow(DC :HDC); virtual;

    protected
      procedure WMEraseBkgnd(var Mess :TWMEraseBkgnd); message WM_ERASEBKGND;
      procedure WMPaint(var Mess :TWMPaint); message WM_Paint;
    end;


  procedure FillWindowRect(AHandle :THandle; const ARect :TRect; AColor :TColor);
  procedure FillWindowRegion(AHandle :THandle; ARegion :HRgn; AColor :TColor);
    { Тестовая процедура: закрашивает у окна AHandle регион ARegion цветом AColor }


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure FillWindowRect(AHandle :THandle; const ARect :TRect; AColor :TColor);
  var
    hBr :THandle;
    hDC :THandle;
  begin
    hDC := GetDC(AHandle);
    hBr := CreateSolidBrush(RGB(255, 0, 0));
    FillRect(hDC, ARect, hBr);
    DeleteObject(hBr);
    ReleaseDC(AHandle, hDC);
  end;


  procedure FillWindowRegion(AHandle :THandle; ARegion :HRgn; AColor :TColor);
  var
    hBr :THandle;
    hDC :THandle;
  begin
    hDC := GetDC(AHandle);
    hBr := CreateSolidBrush(RGB(255, 0, 0));
    FillRgn(hDC, ARegion, hBr);
    DeleteObject(hBr);
    ReleaseDC(AHandle, hDC);
  end;


 {-----------------------------------------------------------------------------}
 { TWindowWithCanvas                                                           }
 {-----------------------------------------------------------------------------}

  constructor TWindowWithCanvas.Create; {override;}
  begin
    inherited Create;
  end;


  destructor TWindowWithCanvas.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  procedure TWindowWithCanvas.WMEraseBkgnd(var Mess :TWMEraseBkgnd); {message WM_EraseBkgnd;}
  begin
    inherited;
  end;


  procedure TWindowWithCanvas.WMPaint(var Mess :TWMPaint); {message WM_Paint;}
  var
    DC :HDC;
    PS :TPaintStruct;
  begin
    DC := Mess.DC;
    if DC = 0 then
      DC := BeginPaint(Handle, PS);
    try
      PaintWindow(DC);
    finally
      if Mess.DC = 0 then
        EndPaint(Handle, PS);
    end;
  end;


  procedure TWindowWithCanvas.PaintWindow(DC :HDC); {override;}
  begin
//  FCanvas.Handle := DC;
//  try
//    Paint;
//  finally
//    FCanvas.Handle := 0;
//  end;
  end;


end.

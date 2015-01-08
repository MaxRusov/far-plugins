{$I Defines.inc}

unit MixWin;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* WCL - Windows Component Library                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    CommCtrl,
    Messages,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses;


  const
    TBS_NOTIFYBEFOREMOVE = $0800;
    TBS_TRANSPARENTBKGND = $1000;

  type
    TColor  = Integer;
    TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
    TFontStyles = set of TFontStyle;

  const
    clBlack = TColor($000000);
    clMaroon = TColor($000080);
    clGreen = TColor($008000);
    clOlive = TColor($008080);
    clNavy = TColor($800000);
    clPurple = TColor($800080);
    clTeal = TColor($808000);
    clGray = TColor($808080);
    clSilver = TColor($C0C0C0);
    clRed = TColor($0000FF);
    clLime = TColor($00FF00);
    clYellow = TColor($00FFFF);
    clBlue = TColor($FF0000);
    clFuchsia = TColor($FF00FF);
    clAqua = TColor($FFFF00);
    clLtGray = TColor($C0C0C0);
    clDkGray = TColor($808080);
    clWhite = TColor($FFFFFF);
    clNone = TColor($1FFFFFFF);
    clDefault = TColor($20000000);


  type
    TCreateParams = record
      Caption :PTChar;
      Style :DWORD;
      ExStyle :DWORD;
      X, Y, DX, DY :Integer;
      WndParent :HWnd;
      HMenu :Integer;
//    Param: Pointer;
      WindowClass: TWndClass;
      WinClassName: array[0..63] of TChar;
    end;

    RGBRec = packed record
      Red, Green, Blue, Dummy :Byte;
    end;

    TMSWindow = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure AfterConstruction; override;

      procedure Show(ACmd :Integer);
      procedure Invalidate; overload;
      procedure Invalidate(const ARect :TRect); overload;

      procedure SetBounds(const ARect :TRect; AAddFlags :Integer);
      procedure SetWindowPos(X, Y :Integer);
      procedure SetWindowSize(CX, CY :Integer);
      function GetBoundsRect :TRect;

      function Perform(Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT;
      procedure DefaultHandler(var Mess); override;

    protected
      procedure CreateParams(var AParams :TCreateParams); virtual;

      procedure MainWndProc(var Mess :TMessage);
      procedure WndProc(var Mess :TMessage); virtual;
      procedure ErrorHandler(E :Exception); virtual;

      procedure WMNCDestroy(var Mess :TWMNCDestroy); message WM_NCDestroy;

    protected
      FHandle :THandle;
      FDefWndProc :Pointer;

      procedure RegisterWindowClass(var AParams :TCreateParams);
      procedure CreateHandle;
      procedure CreateHandleEx(var AParams :TCreateParams);
      procedure DestroyHandle;

      function GetClientRect :TRect;
      function GetText :TString;
      procedure SetText(const Value :TString);

    public
      property Handle :THandle read FHandle;
      property ClientRect :TRect read GetClientRect;
      property Text :TString read GetText write SetText;
    end;


    TFont = class(TBasis)
    public
      destructor Destroy; override;

      procedure SetFont(const AName :TString; ASize :Integer; AStyle :TFontStyles);

    private
      FHandle :HFont;
      FName   :TString;
      FSize   :Integer;
      FStyle  :TFontStyles;
    end;


  const
    TRBN_THUMBPOSCHANGING  = Integer($FFFFFA22); //TRBN_FIRST-1;

  type
    PNMTRBTHUMBPOSCHANGING = ^TNMTRBTHUMBPOSCHANGING;
    TNMTRBTHUMBPOSCHANGING = record
      hdr :NMHDR;
      dwPos :DWORD;
      nReason :Integer;
    end;


  type
    TMSControl = class(TMSWindow)
    public
      constructor CreateEx(AOwner :TMSWindow; ID, X, Y, DX, DY, AStyle :Integer; const Caption :TString); overload;
      constructor CreateEx(AOwner :HWND; ID, X, Y, DX, DY, AStyle :Integer; const Caption :TString); overload;
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
      procedure CreateSubClass(var AParams :TCreateParams; AClassName :PTChar);
    end;

    TButton = class(TMSControl)
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
    end;

    TLabel = class(TMSControl)
//  public
//    constructor Create; override;

    protected
      procedure CreateParams(var AParams :TCreateParams); override;

//  private
//    FColor :Integer;
    end;

    TTracker = class(TMSControl)
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
    end;

    TToolbar = class(TMSControl)
    public
      procedure SetButtonEnabled(AID :Integer; AEnabled :Boolean);
      procedure SetButtonInfo(AID :Integer; AImageID :Integer; const AText :TString);
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
    end;

    TListView = class(TMSControl)
    protected
      procedure CreateParams(var AParams :TCreateParams); override;
    end;

  function ColorToRGB(AColor :TColor) :TColor;
  function WinCreateFont(const AName :TString; ASize :Integer; AStyle :TFontStyles) :HFont;
  procedure WinDeleteObject(var AHandle :HGDIOBJ);
  function TextSize(AFont :HFont; const AText :TString) :TSize;

  const
    WS_EX_LAYERED = $00080000;
    LWA_COLORKEY = $00000001;
    LWA_ALPHA = $00000002;

  type
    PCOLORREF = ^COLORREF;

  var
    SetLayeredWindowAttributes :function(Hwnd: THandle; crKey :COLORREF; bAlpha :Byte; dwFlags :DWORD) :Boolean; stdcall = nil;
    GetLayeredWindowAttributes :function(Hwnd: THandle; crKey :PCOLORREF; bAlpha :PByte; dwFlags :PDWORD) :Boolean; stdcall = nil;


  procedure InitLayeredWindow;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function InitWndProc(HWindow :HWnd; Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT; stdcall;
  var
    vObj :TMSWindow;
    vMess :TMessage;
  begin
//  TraceF('InitWndProc: hWnd=%d, Msg=%d', [HWindow, Msg]);

    if Msg = WM_NCCreate then begin
      vObj := PCreateStruct(LParam).lpCreateParams;
      vObj.FHandle := HWindow;
      SetWindowLongPtr(HWindow, GWLP_USERDATA, TIntPtr(vObj));
    end else
      vObj := Pointer(GetWindowLongPtr(HWindow, GWLP_USERDATA));

    if vObj <> nil then begin
      vMess.Msg := Msg;
      vMess.WParam := WParam;
      vMess.LParam := LParam;
      vMess.Result := 0;
      vObj.MainWndProc(vMess);
      Result := vMess.Result;
    end else
      Result := DefWindowProc(HWindow, Msg, wParam, lParam);
  end;


 {-----------------------------------------------------------------------------}
 { TMSWindow                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TMSWindow.Create; {override;}
  begin
    inherited Create;
  end;

  destructor TMSWindow.Destroy; {override;}
  begin
    DestroyHandle;
    inherited Destroy;
  end;


  procedure TMSWindow.AfterConstruction; {override;}
  begin
    CreateHandle;
  end;


  procedure TMSWindow.CreateParams(var AParams :TCreateParams); {virtual;}
  begin
    with AParams do begin
      WindowClass.Style := CS_VREDRAW + CS_HREDRAW + CS_DBLCLKS;
      WindowClass.lpfnWndProc := @DefWindowProc;
      WindowClass.hbrBackground := COLOR_WINDOW;
      WindowClass.hCursor := LoadCursor(0, IDC_ARROW);
      WindowClass.hInstance := HInstance;
      StrCopyPtr(StrEnd(StrPCopy(WinClassName, ClassName)), Pointer(HInstance));
    end;
  end;


  procedure TMSWindow.RegisterWindowClass(var AParams :TCreateParams);
  var
    vRegistered :Boolean;
    vTempClass :TWndClass;
  begin
    FDefWndProc := AParams.WindowClass.lpfnWndProc;
    vRegistered := GetClassInfo(AParams.WindowClass.hInstance, AParams.WinClassName, vTempClass);
    if not vRegistered or (vTempClass.lpfnWndProc <> @InitWndProc) then begin
      if vRegistered then
        Windows.UnregisterClass(AParams.WinClassName, AParams.WindowClass.hInstance);
      AParams.WindowClass.lpfnWndProc := @InitWndProc;
      AParams.WindowClass.lpszClassName := AParams.WinClassName;
      if Windows.RegisterClass(AParams.WindowClass) = 0 then
        RaiseLastWin32Error;
    end;
  end;


  procedure TMSWindow.CreateHandle;
  var
    vParams :TCreateParams;
  begin
    if FHandle = 0 then begin
      FillChar(vParams, SizeOf(vParams), 0);
      CreateHandleEx(vParams);
    end;
  end;


  procedure TMSWindow.CreateHandleEx(var AParams :TCreateParams);
  begin
    if FHandle = 0 then begin
      CreateParams(AParams);
      RegisterWindowClass(AParams);
      with AParams do
        FHandle := CreateWindowEx(ExStyle, WinClassName, Caption, Style,
          X, Y, DX, DY, WndParent, HMenu, WindowClass.hInstance, Self);
      if FHandle = 0 then
        RaiseLastWin32Error;
    end;
  end;


  procedure TMSWindow.DestroyHandle;
  begin
    if FHandle <> 0 then begin
      DestroyWindow(FHandle);
      FHandle := 0;
    end;
  end;


  procedure TMSWindow.WMNCDestroy(var Mess :TWMNCDestroy); {message WM_Destroy;}
  begin
    inherited;
    FHandle := 0;
  end;


  procedure TMSWindow.MainWndProc(var Mess :TMessage);
  begin
//  TraceF('TMSWindow.MainWndProc: %d', [Mess.Msg {WindowMessage2Str(Mess.Msg)}]);
    try
      WndProc(Mess);
    except
      on E :Exception do
        ErrorHandler(E);
    end;
  end;


  procedure TMSWindow.WndProc(var Mess :TMessage); {virtual;}
  begin
    Dispatch(Mess);
  end;


  procedure TMSWindow.DefaultHandler(var Mess ); {override;}
  begin
    if FHandle <> 0 then
      with TMessage(Mess) do
        Result := CallWindowProc(FDefWndProc, FHandle, Msg, WParam, LParam);
  end;


  procedure TMSWindow.ErrorHandler(E :Exception); {virtual;}
  begin
    {Nothing}
  end;


  function TMSWindow.Perform(Msg :UINT; WParam :WPARAM; LParam :LPARAM) :LRESULT;
  var
    vMess :TMessage;
  begin
    vMess.Msg := Msg;
    vMess.WParam := WParam;
    vMess.LParam := LParam;
    vMess.Result := 0;
    WndProc(vMess);
    Result := vMess.Result;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMSWindow.Show(ACmd :Integer);
  begin
    ShowWindow(FHandle, ACmd);
  end;


  procedure TMSWindow.Invalidate;
  begin
    InvalidateRect(FHandle, nil, True);
  end;


  procedure TMSWindow.Invalidate(const ARect :TRect);
  begin
    InvalidateRect(FHandle, @ARect, True);
  end;


  procedure TMSWindow.SetBounds(const ARect :TRect; AAddFlags :Integer);
  begin
    Windows.SetWindowPos(FHandle, 0, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
      SWP_NOACTIVATE or SWP_NOZORDER or AAddFlags);
  end;


  procedure TMSWindow.SetWindowPos(X, Y :Integer);
  begin
    Windows.SetWindowPos(FHandle, 0, X, Y, 0, 0,
      SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
  end;


  procedure TMSWindow.SetWindowSize(CX, CY :Integer);
  begin
    Windows.SetWindowPos(FHandle, 0, 0, 0, CX, CY, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOZORDER);
  end;


  function TMSWindow.GetBoundsRect :TRect;
  var
    vPlace :TWindowPlacement;
  begin
    FillChar(vPlace, SizeOf(vPlace), 0);
    vPlace.length := SizeOf(vPlace);
    Windows.GetWindowPlacement(FHandle, @vPlace);
    Result := vPlace.rcNormalPosition;
  end;


  function TMSWindow.GetClientRect :TRect;
  begin
    Windows.GetClientRect(FHandle, Result);
  end;


  function TMSWindow.GetText :TString;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := GetWindowTextLength(Handle);
    if vlen > 0 then begin
      SetLength(Result, vLen);
      GetWindowText(Handle, PTChar(Result), vLen + 1);
    end;
  end;


  procedure TMSWindow.SetText(const Value :TString);
  begin
    if Value <> GetText then
      SetWindowText(Handle, PTChar(Value));
  end;


 {-----------------------------------------------------------------------------}
 { TMSControl                                                                  }
 {-----------------------------------------------------------------------------}
(*
  constructor TMSControl.CreateEx(AOwner :TMSWindow; ID, X, Y, DX, DY, AStyle :Integer; const Caption :TString);
  var
    vParams :TCreateParams;
  begin
    Create;
    FillChar(vParams, SizeOf(vParams), 0);
    vParams.HMenu := ID;
    vParams.X := X;
    vParams.Y := Y;
    vParams.DX := DX;
    vParams.DY := DY;
    vParams.Style := AStyle;
    vParams.Caption := PTChar(Caption);
    vParams.WndParent := AOwner.Handle;
    CreateHandleEx(vParams);
  end;
*)

  constructor TMSControl.CreateEx(AOwner :TMSWindow; ID, X, Y, DX, DY, AStyle :Integer; const Caption :TString);
  begin
    CreateEx(AOwner.Handle, ID, X, Y, DX, DY, AStyle, Caption);
  end;


  constructor TMSControl.CreateEx(AOwner :HWND; ID, X, Y, DX, DY, AStyle :Integer; const Caption :TString);
  var
    vParams :TCreateParams;
  begin
    Create;
    FillChar(vParams, SizeOf(vParams), 0);
    vParams.HMenu := ID;
    vParams.X := X;
    vParams.Y := Y;
    vParams.DX := DX;
    vParams.DY := DY;
    vParams.Style := AStyle;
    vParams.Caption := PTChar(Caption);
    vParams.WndParent := AOwner;
    CreateHandleEx(vParams);
  end;


  procedure TMSControl.CreateParams(var AParams :TCreateParams); {override;}
  begin
//  inherited CreateParams(AParams);
//  StrPCopy(AParams.WinClassName, ClassName);
    StrCopyPtr(StrEnd(StrPCopy(AParams.WinClassName, ClassName)), Pointer(HInstance));
    AParams.Style := AParams.Style or WS_CHILD or WS_VISIBLE;
  end;


  procedure TMSControl.CreateSubClass(var AParams :TCreateParams; AClassName :PTChar);
  begin
    with AParams do begin
      if not GetClassInfo(HInstance, AClassName, WindowClass)
        and not GetClassInfo(0, AClassName, WindowClass)
        and not GetClassInfo(MainInstance, AClassName, WindowClass)
        and not GetClassInfo(WindowClass.hInstance, AClassName, WindowClass)
      then
        {};
      WindowClass.hInstance := HInstance;
    end;
  end;



 {-----------------------------------------------------------------------------}
 { TLabel                                                                      }
 {-----------------------------------------------------------------------------}

  procedure TLabel.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
//  AParams.ExStyle := WS_EX_TRANSPARENT;	
    CreateSubClass(AParams, 'STATIC');
  end;


 {-----------------------------------------------------------------------------}
 { TButton                                                                     }
 {-----------------------------------------------------------------------------}

  procedure TButton.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    CreateSubClass(AParams, 'BUTTON');
  end;

  
 {-----------------------------------------------------------------------------}
 { TTracker                                                                    }
 {-----------------------------------------------------------------------------}

  procedure TTracker.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    CreateSubClass(AParams, 'msctls_trackbar32');
  end;

  
 {-----------------------------------------------------------------------------}
 { TToolbar                                                                    }
 {-----------------------------------------------------------------------------}

  procedure TToolbar.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    CreateSubClass(AParams, 'ToolbarWindow32');
  end;


  procedure TToolbar.SetButtonInfo(AID :Integer; AImageID :Integer; const AText :TString);
  var
    vInfo :TTBButtonInfo;
  begin
    FillChar(vInfo, Sizeof(vInfo), 0);
    vInfo.cbSize := SizeOf(TTBButtonInfo);
    vInfo.dwMask := TBIF_IMAGE;
    vInfo.iImage := AImageID;
//  Perform(TB_GETBUTTONINFO, AID, Integer(@vInfo));
    Perform(TB_SETBUTTONINFO, AID, LPARAM(@vInfo));
  end;


  procedure TToolbar.SetButtonEnabled(AID :Integer; AEnabled :Boolean);
  begin
    Perform(TB_ENABLEBUTTON, AID, Byte(AEnabled));
  end;


 {-----------------------------------------------------------------------------}
 { TListView                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TListView.CreateParams(var AParams :TCreateParams); {override;}
  begin
    inherited CreateParams(AParams);
    CreateSubClass(AParams, 'SysListView32');
  end;



 {-----------------------------------------------------------------------------}
 { TFont                                                                       }
 {-----------------------------------------------------------------------------}

  destructor TFont.Destroy; {override;}
  begin
    WinDeleteObject(FHandle);
    inherited Destroy;
  end;


  procedure TFont.SetFont(const AName :TString; ASize :Integer; AStyle :TFontStyles);
  begin
    if not StrEqual(AName, FName) or (FSize <> ASize) or (FStyle <> AStyle) then begin
      WinDeleteObject(FHandle);

      FHandle := WinCreateFont(AName, ASize, AStyle);
      if FHandle = 0 then
        RaiseLastWin32Error;

      FName := AName;
      FSize := ASize;
      FStyle := AStyle;
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function ColorToRGB(AColor :TColor) :TColor;
  begin
    if AColor < 0 then
      Result := GetSysColor(AColor and $000000FF)
    else
      Result := AColor;
  end;


  function WinCreateFont(const AName :TString; ASize :Integer; AStyle :TFontStyles) :HFont;
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
      {lfWeight}         IntIf(fsBold in AStyle, FW_Bold, FW_Normal),
      {lfItalic}         IntIf(fsItalic in AStyle, 1, 0),
      {lfUnderline}      IntIf(fsUnderline in AStyle, 1, 0),
      {lfStrikeOut}      IntIf(fsStrikeOut in AStyle, 1, 0),
      {lfCharSet}        DEFAULT_CHARSET,
      {lfOutPrecision}   OUT_DEFAULT_PRECIS,
      {lfClipPrecision}  CLIP_DEFAULT_PRECIS,
      {lfQuality}        DEFAULT_QUALITY,
      {lfPitchAndFamily} DEFAULT_PITCH,
      {lfFaceName}       PTChar(AName)
    );
  end;


  procedure WinDeleteObject(var AHandle :HGDIOBJ);
  begin
    if AHandle <> 0 then begin
      DeleteObject(AHandle);
      AHandle := 0;
    end;
  end;


  function TextSize(AFont :HFont; const AText :TString) :TSize;
  var
    vDC :HDC;
    vOld :THandle;
  begin
    vDC := CreateCompatibleDC(0);
    vOld := SelectObject(vDC, AFont);
    try
      GetTextExtentPoint32(vDC, PWideChar(AText), Length(AText), Result);
    finally
      SelectObject(vDC, vOld);
      DeleteDC(vDC);
    end;
  end;


  var
    LayeredWindowInited :Boolean;

  procedure InitLayeredWindow;
  var
    ModH: HMODULE;
  begin
    if not LayeredWindowInited then begin
      ModH := GetModuleHandle(user32);
      if ModH <> 0 then begin
        @SetLayeredWindowAttributes := GetProcAddress(ModH, 'SetLayeredWindowAttributes');
        @GetLayeredWindowAttributes := GetProcAddress(ModH, 'GetLayeredWindowAttributes');
      end;
      LayeredWindowInited := True;
    end;
  end;

end.

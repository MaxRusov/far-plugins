{$I Defines.inc}

unit ConCtrlMain;

interface

  uses
    Windows,
    Messages,
//  MultiMon,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWin,
    MixWinUtils,
    Far_API,  //Plugin3.pas
    FarCtrl,
    FarPlug,
    FarMenu,
    FarDlg,
    FarConfig;


  const
   {$ifdef Far3}
    cPluginID :TGUID = '{94624B7B-FFDB-435F-B955-F99DBBC3BFE0}';
    cMenuID   :TGUID = '{5FFBE970-DACD-4DB3-8074-C71338E3A183}';
    cConfigID :TGUID = '{D5E32286-8DF6-4ECD-8317-641D8F05FA6C}';
   {$endif Far3}

    cPluginName = 'Console Control';
    cPluginDescr = 'Console Control FAR plugin';
    cPluginAuthor = 'Max Rusov';

    cPrefix    = 'conctrl:';

    cPalFileExt = 'pal';
    cPltFileExt = 'plt';

    { Команды, доступные через префикс pal: }
//  cAddCmd   = 'Add';
//  cEditCmd  = 'Edit';
    cScaleCmd = 'Scale';
    cSaveCmd  = 'Save';
    cLoadCmd  = 'Load';

  var
    opt_MouseSupport    :Boolean = True;
    opt_MaximizeSupport :Boolean = True;
    opt_ShowHints       :Boolean = True;


  type
    TPaletteItem = packed record
      R, G, B, X :Byte;
    end;
    TPaletteArray = array[0..15] of COLORREF;


  type
    TConCtrlPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure GetInfo; override;
      procedure ExitFar; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
      function ConsoleInput(const ARec :TInputRecord) :Integer; override;
     {$endif Far3}
      procedure Configure; override;

    private
      FMaximized   :Boolean;
      FNormOnTop   :Boolean;
      FNormTransp  :Integer;
      FLastScrolls :Integer;
      FLastSize    :TSize;
      FLockStore   :Integer;

     {$ifdef Far3}
      FResize  :Boolean;
      FPoint0  :TPoint;
      FPoint1  :TPoint;
      FSize0   :TSize;
      FMode    :Integer;
     {$endif Far3}

      FPalScale    :TFloat;

      procedure PluginConfig(AStore :Boolean);

     {$ifdef Far3}
      function MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;
     {$endif Far3}

      procedure MainMenu;
      procedure FontMenu;
      procedure WinMenu;
      procedure BufMenu;
      procedure EffectsMenu;
      procedure OptionsMenu;

     {$ifdef Far3}
      function TrackMouseStart(X, Y :Integer) :Boolean;
      function TrackMouseContinue(X, Y :Integer) :Boolean;
      procedure TrackMouseEnd;
      procedure HintWindowSize;
     {$endif Far3}

      procedure StorePalette(const AFileName :TString);
      procedure RestorePalette(const AFileName :TString);
      procedure RunCommand(const ACmd :TString);

      procedure StoreWindowSize;
      function ConsoleWindowMaximized :Boolean;
      function GetConsoleBufferSize :TSize;
      function GetConsoleWindowSize :TSize;
      function GetConsoleWindowScrolls :Integer;
      procedure ChangeConsoleWindowSize(ADX, ADY :Integer);
      procedure SetConsoleWindowBufferSize(const AWinSize :TCoord; const ABufSize :TCoord);
      procedure SetConsoleWindowSize(ACX, ACY :Integer; AScrolls :Integer = -1; ALock :Boolean = True);
      procedure ChangeConsoleBufferSize(ADX, ADY :Integer);
      procedure SetConsoleBufferSize(ACX, ACY :Integer);
      procedure MaximizeConsoleWindow(AScrolls :Integer);
      procedure MaximizeRestoreConsoleWindow(AValue :Boolean);
      procedure PromptWindowSize;
      procedure PromptBufferSize;

      function GetFontName :TString;
      function GetFontSize :TCoord;
      procedure ChangeFontSize(ADelta :Integer);
      procedure SetFontNameSize(const AName :TString; ASize :Integer);
      procedure PromptFontSize;
      procedure PromptFontName;
      procedure PromptTransparency;

      function GetConsolePalette(var APal :TPaletteArray) :Boolean;
      procedure SetConsolePalette(const APal :TPaletteArray);

      function GetOnTop :Boolean;
      procedure SetOnTop(AValue :Boolean);

      function GetTransparency :Integer;
      procedure SetTransparency(AValue :Integer);

      procedure ChangeMaximized;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


//const
//  cTitle = 'Console control';


(*
  type
    TMessages = (
      sTitle
    );

  function GetMsg(MsgId :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(MsgId));
  end;

  function GetMsgStr(MsgId :TMessages) :TSTring;
  begin
    Result := FarCtrl.GetMsgStr(Integer(MsgId));
  end;

  procedure HandleError(AError :Exception);
  begin
    ShowMessage(cPluginName, AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;
*)

 {-----------------------------------------------------------------------------}

(*
  type
    PConsoleFontInfo = ^TConsoleFontInfo;
    TConsoleFontInfo = record
      nFont :DWORD;
      dwFontSize :COORD;
    end;

  {Windows XP}
  function GetCurrentConsoleFont(hConsoleOutput :THandle; bMaximumWindow :BOOL; lpConsoleCurrentFont :PConsoleFontInfo) :BOOL; stdcall;
    external kernel32 name 'GetCurrentConsoleFont';
  function GetConsoleFontSize(hConsoleOutput :THandle; nFont :DWORD) :COORD; stdcall;
    external kernel32 name 'GetConsoleFontSize';
*)


  type
    PConsoleScreenBufferInfoEx = ^TConsoleScreenBufferInfoEx;
    TConsoleScreenBufferInfoEx = record
      cbSize :ULONG;
      dwSize :COORD;
      dwCursorPosition :COORD;
      wAttributes :WORD;
      srWindow :TSmallRect;
      dwMaximumWindowSize :COORD;
      wPopupAttributes :WORD;
      bFullscreenSupported :BOOL;
      ColorTable :array[0..15] of COLORREF;
    end;

  {Vista+}
//function GetConsoleScreenBufferInfoEx(hConsoleOutput :THandle; lpConsoleScreenBufferInfoEx :PConsoleScreenBufferInfoEx) :BOOL; stdcall;
//  external kernel32 name 'GetConsoleScreenBufferInfoEx';
//function SetConsoleScreenBufferInfoEx(hConsoleOutput :THandle; lpConsoleScreenBufferInfoEx :PConsoleScreenBufferInfoEx) :BOOL; stdcall;
//  external kernel32 name 'SetConsoleScreenBufferInfoEx';

  var
    GetConsoleScreenBufferInfoEx :function(hConsoleOutput :THandle; lpConsoleScreenBufferInfoEx :PConsoleScreenBufferInfoEx) :BOOL; stdcall;
    SetConsoleScreenBufferInfoEx :function (hConsoleOutput :THandle; lpConsoleScreenBufferInfoEx :PConsoleScreenBufferInfoEx) :BOOL; stdcall;

  type
    PConsoleFontInfoEx = ^TConsoleFontInfoEx;
    TConsoleFontInfoEx = record
      cbSize :ULONG;
      nFont :DWORD;
      dwFontSize :COORD;
      FontFamily :UINT;
      FontWeight :UINT;
      FaceName :array[0..LF_FACESIZE-1] of WCHAR;
    end;


  {Vista+}
//function GetCurrentConsoleFontEx(hConsoleOutput :THandle; bMaximumWindow :BOOL; lpConsoleCurrentFontEx :PConsoleFontInfoEx) :BOOL; stdcall;
//  external kernel32 name 'GetCurrentConsoleFontEx';
//function SetCurrentConsoleFontEx(hConsoleOutput :THandle; bMaximumWindow :BOOL; lpConsoleCurrentFontEx :PConsoleFontInfoEx) :BOOL; stdcall;
//  external kernel32 name 'SetCurrentConsoleFontEx';

  var
    GetCurrentConsoleFontEx :function(hConsoleOutput :THandle; bMaximumWindow :BOOL; lpConsoleCurrentFontEx :PConsoleFontInfoEx) :BOOL; stdcall;
    SetCurrentConsoleFontEx :function (hConsoleOutput :THandle; bMaximumWindow :BOOL; lpConsoleCurrentFontEx :PConsoleFontInfoEx) :BOOL; stdcall;


  function InitImport :Boolean;
  var
    vHandle :THandle;
  begin
    Result := False;
    vHandle := GetModuleHandle(kernel32);
    if vHandle <> 0 then begin

      GetConsoleScreenBufferInfoEx := GetProcAddress(vHandle, 'GetConsoleScreenBufferInfoEx');
      SetConsoleScreenBufferInfoEx := GetProcAddress(vHandle, 'SetConsoleScreenBufferInfoEx');

      GetCurrentConsoleFontEx := GetProcAddress(vHandle, 'GetCurrentConsoleFontEx');
      SetCurrentConsoleFontEx := GetProcAddress(vHandle, 'SetCurrentConsoleFontEx');

      Result := Assigned(GetConsoleScreenBufferInfoEx) and Assigned(SetConsoleScreenBufferInfoEx) and
        Assigned(GetCurrentConsoleFontEx) and Assigned(SetCurrentConsoleFontEx);
    end;
    InitLayeredWindow;
  end;


  procedure InitHandles;
  begin
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);
  end;


 {-----------------------------------------------------------------------------}
 { Диалог                                                                      }
 {-----------------------------------------------------------------------------}

  const
    IdFrame        = 0;
    IdEdt1         = 2;
    IdEdt2         = 4;
    IdOk           = 6;

  type
    TInputDlg = class(TFarDialog)
    public
      constructor CreateEx(const ATitle :TString);
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FTitle :TString;
      FSize  :TSize;
    end;

    
  constructor TInputDlg.CreateEx(const ATitle :TString);
  begin
    FTitle := ATitle;
    Create;
  end;


  procedure TInputDlg.Prepare; {override;}
  const
    DX = 40;
    DY = 10;
  begin
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, PTChar(FTitle)),

        NewItemApi(DI_Text,      5,  2, -1,    -1, 0, '&Width' ),
        NewItemApi(DI_Edit,      13, 2, DX-19, -1, DIF_HISTORY, '', 'ConCtrl.WinX' ),

        NewItemApi(DI_Text,      5,  4, -1,    -1, 0, '&Height' ),
        NewItemApi(DI_Edit,      13, 4, DX-19, -1, DIF_HISTORY, '', 'ConCtrl.WinY' ),

        NewItemApi(DI_Text,      0,  5, -1, -1,     DIF_SEPARATOR),

        NewItemApi(DI_DefButton, 0, DY-3, -1, -1,   DIF_CENTERGROUP, 'Ok' ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1,   DIF_CENTERGROUP, 'Cancel' )
      ],
      @FItemCount
    );
  end;


  procedure TInputDlg.InitDialog; {override;}
  begin
    SetText(IdEdt1, Int2Str(FSize.CX));
    SetText(IdEdt2, Int2Str(FSize.CY));
  end;


  function TInputDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if ItemID = IdOk then begin
      FSize.CX := Str2Int(GetText(IdEdt1));
      FSize.CY := Str2Int(GetText(IdEdt2));
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 { TConCtrlPlug                                                                }
 {-----------------------------------------------------------------------------}

  procedure TConCtrlPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
   {$endif Far3}

   {$ifdef Far3}
    FMinFarVer := MakeVersion(3, 0, 3000);
   {$endif Far3}
  end;


  procedure TConCtrlPlug.Startup; {override;}
  begin
    InitImport;
    InitHandles;

    FMaximized := ConsoleWindowMaximized;
    if not FMaximized then
      StoreWindowSize
    else
      FLastSize := Size(80, 25);

    PluginConfig(False);
//  HookConsole(True);
  end;


  procedure TConCtrlPlug.ExitFar; {override;}
  begin
//  HookConsole(False);
  end;


  procedure TConCtrlPlug.GetInfo; {override;}
  begin
    FFlags := PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    FMenuStr := FName {GetMsg(sTitle)} ;
    FConfigStr := FName;
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    FPrefix := cPrefix;

//  TraceF('FarWnd: %d', [hFarWindow]);
  end;


  function TConCtrlPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    InitHandles;
    MainMenu;
  end;


  function TConCtrlPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vCmd :TString;
  begin
    Result := INVALID_HANDLE_VALUE;
    if (AStr <> nil) and (AStr^ <> #0) then begin
      FPalScale := 1;
      while AStr^ <> #0 do begin
        vCmd := ExtractParamStr(AStr);
        if vCmd <> '' then begin
          if (vCmd[1] = '/') or (vCmd[1] = '-') then begin
            Delete(vCmd, 1, 1);
            RunCommand(vCmd);
          end;
        end;
      end;
    end else
      MainMenu;
  end;


  procedure TConCtrlPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


 {$ifdef Far3}

  function TConCtrlPlug.MacroCommand(const ACmd :TString; ACount :Integer; AParams :PFarMacroValueArray) :TIntPtr;
  var
    vInt, DX, DY :Integer;
    vStr :TString;
  begin
    Result := 0;

    InitHandles;
    if StrEqual(ACmd, 'FontName') then begin
      if not Assigned(GetCurrentConsoleFontEx) then
        Exit;
      vStr := FarValuesToStr(AParams, ACount, 1, '');
      DY := FarValuesToInt(AParams, ACount, 2, 0);
      if vStr <> '' then
        SetFontNameSize(vStr, DY);
      Result := FarReturnValues([GetFontSize.Y, GetFontName]);
    end else
    if StrEqual(ACmd, 'FontSize') or StrEqual(ACmd, 'FontSizeDelta') then begin
      if not Assigned(GetCurrentConsoleFontEx) then
        Exit;
      DY := FarValuesToInt(AParams, ACount, 1, 0);
      if StrEqual(ACmd, 'FontSizeDelta') then begin
        if DY <> 0 then
          ChangeFontSize(DY);
      end else
        SetFontNameSize('', DY);
      Result := FarReturnValues([GetFontSize.Y, GetFontName]);
    end else
    if StrEqual(ACmd, 'WindowSize') then begin
      if ACount >= 2 then begin
        DX := FarValuesToInt(AParams, ACount, 1, 0);
        DY := FarValuesToInt(AParams, ACount, 2, 0);
        if DX = 0 then
          DX := GetConsoleWindowSize.cx;
        if DY = 0 then
          DY := GetConsoleWindowSize.cy;
        SetConsoleWindowSize(DX, DY);
      end;
      with GetConsoleWindowSize do
        Result := FarReturnValues([CX, CY]);
    end else
    if StrEqual(ACmd, 'BufferSize') then begin
      if ACount >= 2 then begin
        DX := FarValuesToInt(AParams, ACount, 1, 0);
        DY := FarValuesToInt(AParams, ACount, 2, 0);
        if DX = 0 then
          DX := GetConsoleBufferSize.cx;
        if DX < 0 then
          DX := GetConsoleWindowSize.cx;
        if DY = 0 then
          DY := GetConsoleBufferSize.cy;
        if DY < 0 then
          DY := GetConsoleWindowSize.cy;
        SetConsoleBufferSize(DX, DY);
      end;
      with GetConsoleBufferSize do
        Result := FarReturnValues([CX, CY]);
    end else
    if StrEqual(ACmd, 'Maximize') then begin
      vInt := FarValuesToInt(AParams, ACount, 1, MaxInt);
      if vInt <> MaxInt then begin
        if vInt = -1 then
          vInt := IntIf(ConsoleWindowMaximized, 0, 1);
        MaximizeRestoreConsoleWindow(vInt <> 0);
      end;
      Result := FarReturnValues([ConsoleWindowMaximized]);
    end else
    if StrEqual(ACmd, 'Topmost') then begin
      vInt := FarValuesToInt(AParams, ACount, 1, MaxInt);
      if vInt <> MaxInt then begin
        if vInt = -1 then
          vInt := IntIf(GetOnTop, 0, 1);
        SetOnTop(vInt <> 0);
        FNormOnTop := GetOnTop;
      end;
      Result := FarReturnValues([GetOnTop]);
    end else
    if StrEqual(ACmd, 'Transparency') then begin
      vInt := FarValuesToInt(AParams, ACount, 1, -1);
      if vInt <> -1 then
        SetTransparency(vInt);
      Result := FarReturnValues([GetTransparency]);
    end;
  end;


  function TConCtrlPlug.OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {override;}
  begin
    Result := 0;
    if (ACount = 0) or ((ACount = 1) and (AParams[0].fType = FMVT_INTEGER)) then
      Result := inherited OpenMacroEx(ACount, AParams)
    else
    if AParams[0].fType = FMVT_STRING then
      Result := MacroCommand(AParams[0].Value.fString, ACount, AParams);
  end;


  function SizeEqual(const ASize1, ASize2 :TSize) :Boolean;
  begin
    Result := (ASize1.cx = ASize2.cx) and (ASize1.cy = ASize2.cy);
  end;


  function TConCtrlPlug.ConsoleInput(const ARec :TInputRecord) :Integer; {override;}
  var
    vMaximized :Boolean;
  begin
    Result := 0;
    if (ARec.EventType = _MOUSE_EVENT) and opt_MouseSupport then begin
      with ARec.Event.MouseEvent do begin
        InitHandles;
        if dwEventFlags = 0 then begin
          if dwButtonState and FROM_LEFT_1ST_BUTTON_PRESSED <> 0 then begin
            if TrackMouseStart(dwMousePosition.X, dwMousePosition.Y) then
              Result := 1;
          end else
          if FResize then begin
            TrackMouseEnd;
            Result := 1;
          end
        end else
        if MOUSE_MOVED and dwEventFlags <> 0 then begin
          if FResize and TrackMouseContinue(dwMousePosition.X, dwMousePosition.Y) then
            Result := 1;
        end;
      end;
    end else
    if (ARec.EventType = WINDOW_BUFFER_SIZE_EVENT) and opt_MaximizeSupport then begin
      InitHandles;
//    TraceF('ConsoleInput: %d', [ARec.EventType]);

      vMaximized := ConsoleWindowMaximized;
      if FMaximized <> vMaximized then begin
        if not vMaximized then
          if not SizeEqual(GetConsoleWindowSize, FLastSize) or (GetConsoleWindowScrolls <> FLastScrolls) then begin
            Inc(FLockStore);
            try
//            TraceF('Restore size: %d x %d, %d...', [FLastSize.CX, FLastSize.CY, FLastScrolls]);
              SetConsoleWindowSize(FLastSize.CX, FLastSize.CY, FLastScrolls);
            finally
              Dec(FLockStore);
            end;
          end;
        FMaximized := vMaximized;
        ChangeMaximized;
      end else
      if not vMaximized then begin
        StoreWindowSize;
      end;
    end;
  end;

  function TConCtrlPlug.TrackMouseStart(X, Y :Integer) :Boolean;
  begin
    Result := False;
    FResize := False;

    FSize0  := FarGetWindowSize;
    if not RectContainsXY(Bounds(FSize0.CX-2, FSize0.CY-1, 2, 1), X, Y) or ConsoleWindowMaximized then
      Exit;

    FPoint0 := Point(X, Y);
    FPoint1 := FPoint0;
    HintWindowSize;

    FMode := IntIf(GetKeyState(VK_Shift) < 0, -1, 0);
    FResize := True;
    Result := True;
  end;


  function TConCtrlPlug.TrackMouseContinue(X, Y :Integer) :Boolean;
  var
    vPoint :TPoint;
    vSize  :TSize;
  begin
    Result := False;
    if not FResize then
      Exit;

//  vPoint := Point(X, Y);
    vPoint := GetConsoleMousePos;
    if (vPoint.X <> FPoint1.X) or (vPoint.Y <> FPoint1.Y) then begin
//    TraceF('X=%d, Y=%d', [vPoint.X, vPoint.Y]);
      if FMode = -1 then
        FMode := IntIf( vPoint.Y <> FPoint1.Y, 1, 2);

      vSize := GetConsoleWindowSize;
      if FMode in [0, 1] then
        vSize.CY := FSize0.cy + vPoint.y - FPoint0.y;
      if FMode in [0, 2] then
        vSize.CX := FSize0.cx + vPoint.x - FPoint0.x;
      SetConsoleWindowSize( vSize.CX, vSize.CY );
      HintWindowSize;

      FPoint1 := vPoint;
    end;

    Result := True;
  end;


  procedure TConCtrlPlug.TrackMouseEnd;
  begin
//  FarAdvControl(ACTL_REDRAWALL, nil);
    FResize := False;
  end;


  procedure TConCtrlPlug.HintWindowSize;
  begin
    if not opt_ShowHints then
      Exit;
    with GetConsoleWindowSize do
      FarPostMacro(Format('Plugin.Call("CDF48DA0-0334-4169-8453-69048DD3B51C", "Info", "%d x %d")', [CX, CY]));
  end;
 {$endif Far3}

 
 {-----------------------------------------------------------------------------}

  procedure TConCtrlPlug.MainMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      FName,
    [
      '&1 Window size',
      '&2 Buffer size',
      '&3 Console font',
      '&4 Effects'
//    '&5 Presets'
    ]);
    try
//    vMenu.Enabled[0] := FInited;
//    vMenu.Enabled[1] := FInited;
      vMenu.Enabled[2] := Assigned(GetCurrentConsoleFontEx);
//    vMenu.Enabled[2] :=

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: WinMenu;
        1: BufMenu;
        2: FontMenu;
        3: EffectsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TConCtrlPlug.WinMenu;
  var
    vMenu :TFarMenu;
    vStr :TString;
  begin
    vMenu := TFarMenu.CreateEx(
      'Console Window',
    [
      '&1 Inc Width',
      '&2 Dec Width',
      '&3 Inc Height',
      '&4 Dec Height',
      '',
      '&Maximize/Restore',
      '',
      '&Size:'
    ]);
    try
      while True do begin
        with GetConsoleWindowSize do
          vStr := '&Size: ' + Int2Str(CX) + ' x ' + Int2Str(CY);
        vMenu.Items[7].TextPtr := PTChar(vStr);

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ChangeConsoleWindowSize(+1, 0);
          1: ChangeConsoleWindowSize(-1, 0);
          2: ChangeConsoleWindowSize(0, +1);
          3: ChangeConsoleWindowSize(0, -1);

          5: MaximizeRestoreConsoleWindow(not ConsoleWindowMaximized);

          7: PromptWindowSize;
        end;
      end;
    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TConCtrlPlug.BufMenu;
  var
    vMenu :TFarMenu;
    vStr :TString;
  begin
    vMenu := TFarMenu.CreateEx(
      'Console Buffer',
    [
      '&1 Inc Width',
      '&2 Dec Width',
      '&3 Inc Height',
      '&4 Dec Height',
      '',
      '&Size:'
    ]);
    try
      while True do begin
        with GetConsoleBufferSize do
          vStr := '&Size: ' + Int2Str(CX) + ' x ' + Int2Str(CY);
        vMenu.Items[5].TextPtr := PTChar(vStr);

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ChangeConsoleBufferSize(+1, 0);
          1: ChangeConsoleBufferSize(-1, 0);
          2: ChangeConsoleBufferSize(0, +1);
          3: ChangeConsoleBufferSize(0, -1);

          5: PromptBufferSize;
        end;
      end;
    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TConCtrlPlug.FontMenu;
  var
    vMenu :TFarMenu;
    vSize :TCoord;
    vStr1, vStr2 :TString;
  begin
    vMenu := TFarMenu.CreateEx(
      'Console Font',
    [
      '&1 Inc Font Size',
      '&2 Dec Font Size',
      '',
      '&3 Set Font Size:',
      '&4 Font Name:'
    ]);
    try
      while True do begin
        vSize := GetFontSize;
        vStr1 := '&3 Font Size: ' + Int2Str(vSize.Y);
        vStr2 := '&4 Font Name: ' + GetFontName;
        vMenu.Items[3].TextPtr := PTChar(vStr1);
        vMenu.Items[4].TextPtr := PTChar(vStr2);

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ChangeFontSize(+1);
          1: ChangeFontSize(-1);

          3: PromptFontSize;
          4: PromptFontName;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TConCtrlPlug.EffectsMenu;
  var
    vMenu :TFarMenu;
    vStr1 :TString;
  begin
    vMenu := TFarMenu.CreateEx(
      'Effects',
    [
      '&1 Topmost',
      '&2 Transparency:'
    ]);
    try
      while True do begin
        vStr1 := '&2 Transparency: ' + Int2Str(GetTransparency);

        vMenu.Checked[0] := GetOnTop;
        vMenu.Enabled[1] := Assigned(SetLayeredWindowAttributes);
        vMenu.Items[1].TextPtr := PTChar(vStr1);

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: SetOnTop(not GetOnTop);
          1: PromptTransparency;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TConCtrlPlug.OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      FName,
    [
      '&Mouse support',
      'Ma&ximize support',
      'Show &hints'
    ]);
    try
      while True do begin
        vMenu.Checked[0] := opt_MouseSupport;
        vMenu.Checked[1] := opt_MaximizeSupport;
        vMenu.Checked[2] := opt_ShowHints;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: opt_MouseSupport := not opt_MouseSupport;
          1: opt_MaximizeSupport := not opt_MaximizeSupport;
          2: opt_ShowHints := not opt_ShowHints;
        end;

        PluginConfig(True);
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TConCtrlPlug.PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

        LogValue('UseMouse', opt_MouseSupport);
        LogValue('MaximizeCheck', opt_MaximizeSupport);
        LogValue('ShowHints', opt_ShowHints);

      finally
        Destroy;
      end;
  end;



  procedure TConCtrlPlug.PromptWindowSize;
  var
    vDlg :TInputDlg;
  begin
    vDlg := TInputDlg.CreateEx('Window Size');
    try
      vDlg.FSize := GetConsoleWindowSize;
      if vDlg.Run = IdOk then
        SetConsoleWindowSize(vDlg.FSize.CX, vDlg.FSize.CY);
    finally
      FreeObj(vDlg);
    end;
  end;


  procedure TConCtrlPlug.PromptBufferSize;
  var
    vDlg :TInputDlg;
  begin
    vDlg := TInputDlg.CreateEx('Buffer Size');
    try
      vDlg.FSize := GetConsoleBufferSize;
      if vDlg.Run = IdOk then
        SetConsoleBufferSize(vDlg.FSize.CX, vDlg.FSize.CY);
    finally
      FreeObj(vDlg);
    end;
  end;


  procedure TConCtrlPlug.PromptFontSize;
  var
    vStr :TString;
  begin
    vStr := Int2Str(GetFontSize.Y);
    if not FarInputBox(PFarChar(FName), 'Font size', vStr) then
      Exit;
    SetFontNameSize('', Str2Int(vStr));
  end;


  procedure TConCtrlPlug.PromptFontName;
  var
    vStr :TString;
  begin
    vStr := GetFontName;
    if not FarInputBox(PFarChar(FName), 'Font name', vStr, FIB_BUTTONS, 'ConsoleControl.FontName') then
      Exit;
    SetFontNameSize(vStr, 0);
  end;


  procedure TConCtrlPlug.PromptTransparency;
  var
    vStr :TString;
  begin
    vStr := Int2Str(GetTransparency);
    if not FarInputBox(PFarChar(FName), 'Transparency (0..255)', vStr) then
      Exit;
    SetTransparency(Str2Int(vStr));
  end;

 {-----------------------------------------------------------------------------}

  function TConCtrlPlug.ConsoleWindowMaximized :Boolean;
  begin
    Result := IsZoomed(hFarWindow);
  end;


  function TConCtrlPlug.GetConsoleBufferSize :TSize;
  var
    vInfo :TConsoleScreenBufferInfo;
  begin
    Result := Size(0, 0);
    if GetConsoleScreenBufferInfo(hStdOut, vInfo) then
      with vInfo.dwSize do
        Result := Size(X, Y);
  end;


  function TConCtrlPlug.GetConsoleWindowSize :TSize;
  var
    vInfo :TConsoleScreenBufferInfo;
  begin
    Result := Size(0, 0);
    if GetConsoleScreenBufferInfo(hStdOut, vInfo) then
      with vInfo.srWindow do
        Result := Size(Right - Left + 1, Bottom - Top + 1);
  end;


  function GetScrollsBy(const ASize :TCoord; const ARect :TSmallRect) :Integer;
  begin
    Result := 0;
    if ASize.Y > (ARect.Bottom - ARect.Top + 1) then
      Result := Result or 1;
    if ASize.X > (ARect.Right - ARect.Left + 1) then
      Result := Result or 2;
  end;


  function TConCtrlPlug.GetConsoleWindowScrolls :Integer;
  var
    vInfo :TConsoleScreenBufferInfo;
  begin
    Result := 0;
    if GetConsoleScreenBufferInfo(hStdOut, vInfo) then
      Result := GetScrollsBy(vInfo.dwSize, vInfo.srWindow);
  end;


  procedure TConCtrlPlug.ChangeConsoleWindowSize(ADX, ADY :Integer);
  begin
    with GetConsoleWindowSize do
      SetConsoleWindowSize(CX + ADX, CY + ADY);
  end;


  procedure TConCtrlPlug.SetConsoleWindowBufferSize(const AWinSize :TCoord; const ABufSize :TCoord);

    procedure LocResize(AGrow :Boolean; const ASize :TCoord; const ARect :TSmallRect);
    begin
      if AGrow then begin
        SetConsoleScreenBufferSize(hStdOut, ASize);
        SetConsoleWindowInfo(hStdOut, True, ARect);
      end else
      begin
        SetConsoleWindowInfo(hStdOut, True, ARect);
        SetConsoleScreenBufferSize(hStdOut, ASize);
      end;
    end;

  var
    vInfo :TConsoleScreenBufferInfo;
    vSize :TCoord;
    vRect :TSmallRect;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    if GetConsoleScreenBufferInfo(hStdOut, vInfo) then begin

      vSize := vInfo.dwSize;
      vRect := vInfo.srWindow;
      
      vSize.X := ABufSize.X;
      vRect.Left := RangeLimit(vRect.Left, 0, ABufSize.X - AWinSize.X);
      vRect.Right := vRect.Left + AWinSize.X - 1;
      LocResize(vSize.X > vInfo.dwSize.X, vSize, vRect);

      vSize.Y := ABufSize.Y;
      vRect.Top := RangeLimit(vRect.Top, 0, ABufSize.Y - AWinSize.Y);
      vRect.Bottom := vRect.Top + AWinSize.Y - 1;
      LocResize(vSize.Y > vInfo.dwSize.Y, vSize, vRect);

      if not ConsoleWindowMaximized then
        StoreWindowSize;
    end;
  end;

(*
  procedure TConCtrlPlug.SetConsoleWindowBufferSize(const AWinSize :TCoord; const ABufSize :TCoord);
  var
    vInfo :TConsoleScreenBufferInfoEx;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    if GetConsoleScreenBufferInfoEx(hStdOut, @vInfo) then begin

      vInfo.dwSize := ABufSize;

      vInfo.srWindow.Left := RangeLimit(vInfo.srWindow.Left, 0, ABufSize.X - AWinSize.X);
      vInfo.srWindow.Right := vInfo.srWindow.Left + AWinSize.X;
      vInfo.srWindow.Top := RangeLimit(vInfo.srWindow.Top, 0, ABufSize.Y - AWinSize.Y);
      vInfo.srWindow.Bottom := vInfo.srWindow.Top + AWinSize.Y;
      SetConsoleScreenBufferInfoEx(hStdOut, @vInfo);

      { Без этого глючит при увеличении размера консоли. Глюк Windows?... }
      Dec(vInfo.srWindow.Right);
      Dec(vInfo.srWindow.Bottom);
      SetConsoleWindowInfo(hStdOut, True, vInfo.srWindow);

      if not ConsoleWindowMaximized then
        StoreWindowSize;
    end;
  end;
*)

  procedure TConCtrlPlug.SetConsoleWindowSize(ACX, ACY :Integer; AScrolls :Integer = -1; ALock :Boolean = True);
  var
    vInfo :TConsoleScreenBufferInfo;
    vWinSize, vBufSize :TCoord;
  begin
    ACX := RangeLimit(ACX, 20, MaxInt);
    ACY := RangeLimit(ACY, 10, MaxInt);

    FillZero(vInfo, SizeOf(vInfo));
    if GetConsoleScreenBufferInfo(hStdOut, vInfo) then begin
      if AScrolls = -1 then
        AScrolls := GetScrollsBy(vInfo.dwSize, vInfo.srWindow);

      vWinSize := MakeCoord(ACX, ACY);
      vBufSize := vInfo.dwSize;
      if (ACX > vBufSize.X) or (AScrolls and 2 = 0) then
        vBufSize.X := ACX;
      if (ACY > vBufSize.Y) or (AScrolls and 1 = 0) then
        vBufSize.Y := ACY;

      if ALock then
        LockWindowUpdate(hFarWindow);
      try
        SetConsoleWindowBufferSize(vWinSize, vBufSize);
      finally
        if ALock then
          LockWindowUpdate(0);
      end;
    end;
  end;


  procedure TConCtrlPlug.ChangeConsoleBufferSize(ADX, ADY :Integer);
  begin
    with GetConsoleBufferSize do
      SetConsoleBufferSize(CX + ADX, CY + ADY);
  end;


  procedure TConCtrlPlug.SetConsoleBufferSize(ACX, ACY :Integer);
  var
    vInfo :TConsoleScreenBufferInfo;
    vWinSize, vBufSize :TCoord;
  begin
    ACX := RangeLimit(ACX, 20, MaxInt);
    ACY := RangeLimit(ACY, 10, MaxInt);

    FillZero(vInfo, SizeOf(vInfo));
    if GetConsoleScreenBufferInfo(hStdOut, vInfo) then begin
      vBufSize := MakeCoord(ACX, ACY);
      with vInfo.srWindow do
        vWinSize := MakeCoord(IntMin(Right - Left + 1, ACX), IntMin(Bottom - Top + 1, ACY));

      LockWindowUpdate(hFarWindow);
//    SendMessage(hFarWindow, WM_SETREDRAW, 0, 0);
      try
        SetConsoleWindowBufferSize(vWinSize, vBufSize);
      finally
        LockWindowUpdate(0);
//      SendMessage(hFarWindow, WM_SETREDRAW, 1, 0);
      end
    end;
  end;



  procedure TConCtrlPlug.MaximizeConsoleWindow(AScrolls :Integer);
  var
    vSize :TCoord;
  begin
    vSize := GetLargestConsoleWindowSize(hStdOut);
    SetConsoleWindowSize(vSize.X, vSize.Y, AScrolls, False);
  end;


  procedure TConCtrlPlug.MaximizeRestoreConsoleWindow(AValue :Boolean);
  begin
    if AValue <> ConsoleWindowMaximized then begin
      if AValue then begin
        StoreWindowSize;
        FMaximized := True;
        SendMessage(hFarWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
        MaximizeConsoleWindow(FLastScrolls);
        ChangeMaximized;
      end else
      begin
        FMaximized := False;
        SendMessage(hFarWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
        Inc(FLockStore);
        try
          SetConsoleWindowSize(FLastSize.CX, FLastSize.CY, FLastScrolls);
        finally
          Dec(FLockStore);
        end;
        ChangeMaximized;
      end;
    end;  
  end;

  
  procedure TConCtrlPlug.StoreWindowSize;
  begin
    if FLockStore = 0 then begin
      FLastSize := GetConsoleWindowSize;
      FLastScrolls := GetConsoleWindowScrolls;
//    TraceF('Store size: %d x %d, %d', [FLastSize.CX, FLastSize.CY, FLastScrolls]);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TConCtrlPlug.GetFontSize :TCoord;
  var
    vInfo :TConsoleFontInfoEx;
  begin
    Result := MakeCoord(0,0);
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    if GetCurrentConsoleFontEx(hStdOut, False, @vInfo) then
      Result := vInfo.dwFontSize
  end;


  function TConCtrlPlug.GetFontName :TString;
  var
    vInfo :TConsoleFontInfoEx;
  begin
    Result := '';
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    if GetCurrentConsoleFontEx(hStdOut, False, @vInfo) then
      Result := vInfo.FaceName;
  end;


  procedure TConCtrlPlug.ChangeFontSize(ADelta :Integer);
  var
    I :Integer;
    vSize, vSize0 :TCoord;
  begin
    if ADelta = 0 then
      Exit;
    vSize0 := GetFontSize;
    for I := 1 to 10 do begin
      SetFontNameSize('', vSize0.Y + ADelta * I);
      vSize := GetFontSize;
      if (vSize.Y <> vSize0.Y) or (vSize.X <> vSize0.X) then
        Break;
    end
  end;


  procedure TConCtrlPlug.SetFontNameSize(const AName :TString; ASize :Integer);
  var
    vInfo :TConsoleFontInfoEx;
    vMaximized :Boolean;
    vScrolls :Integer;
  begin
    ASize := RangeLimit(ASize, 0, 999);
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    if GetCurrentConsoleFontEx(hStdOut, False, @vInfo) then begin

      vMaximized := ConsoleWindowMaximized;
      vScrolls := 0;
      if vMaximized then
        vScrolls := GetConsoleWindowScrolls;

      if vMaximized then
//      LockWindowUpdate(hFarWindow);
        SendMessage(hFarWindow, WM_SETREDRAW, 0, 0);
      try
        if ASize > 0 then
          vInfo.dwFontSize := MakeCoord(MulDiv(ASize,2,3), ASize);
        if AName <> '' then begin
          StrPLCopy(vInfo.FaceName, AName, LF_FACESIZE);
          vInfo.FontFamily := FF_DONTCARE;
        end;
        SetCurrentConsoleFontEx(hStdOut, False, @vInfo);

        if vMaximized then
          MaximizeConsoleWindow(vScrolls);

      finally
        if vMaximized then
//        LockWindowUpdate(0);
          SendMessage(hFarWindow, WM_SETREDRAW, 1, 0);
      end;
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TConCtrlPlug.GetOnTop :Boolean;
  begin
    Result := GetWindowLong(hFarWindow, GWL_EXSTYLE) and WS_EX_TOPMOST <> 0;
  end;

  procedure TConCtrlPlug.SetOnTop(AValue :Boolean);
  begin
    if not SetWindowPos(hFarWindow, HandleIf(AValue, HWND_TOPMOST, HWND_NOTOPMOST), 0, 0, 0, 0,
      SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE {or SWP_NOZORDER or SWP_NOOWNERZORDER})
    then
      RaiseLastWin32Error
  end;

 {-----------------------------------------------------------------------------}

  function TConCtrlPlug.GetTransparency :Integer;
  var
    vStyle :Integer;
    vAlpha :Byte;
  begin
    Result := 0;
    if not Assigned(GetLayeredWindowAttributes) then
      Exit;
    vStyle := GetWindowLong(hFarWindow, GWL_EXSTYLE);
    if vStyle and WS_EX_LAYERED <> 0 then begin
      if GetLayeredWindowAttributes(hFarWindow, nil, @vAlpha, nil) then
        Result := 255 - vAlpha;
    end;
  end;

  procedure TConCtrlPlug.SetTransparency(AValue :Integer);
  var
    vStyle: Integer;
  begin
    if not Assigned(SetLayeredWindowAttributes) then
      Exit;
    AValue := RangeLimit(AValue, 0, 255);
    vStyle := GetWindowLong(hFarWindow, GWL_EXSTYLE);
    if AValue <> 0 then begin
      if vStyle and WS_EX_LAYERED = 0 then
        SetWindowLong(hFarWindow, GWL_EXSTYLE, vStyle or WS_EX_LAYERED);
      SetLayeredWindowAttributes(hFarWindow, 0, 255 - AValue, LWA_ALPHA);
    end else
    begin
      if vStyle and WS_EX_LAYERED <> 0 then
        SetWindowLong(hFarWindow, GWL_EXSTYLE, vStyle and not WS_EX_LAYERED);
    end;
  end;


  procedure TConCtrlPlug.ChangeMaximized;
  begin
    if FMaximized then begin
      FNormOnTop := GetOnTop;
      FNormTransp := GetTransparency;
      SetOnTop(False);
      SetTransparency(0);
    end else
    begin
      SetOnTop(FNormOnTop);
      SetTransparency(FNormTransp);
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TConCtrlPlug.GetConsolePalette(var APal :TPaletteArray) :Boolean;
  var
    vInfo :TConsoleScreenBufferInfoEx;
  begin
    Result := False;
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    if GetConsoleScreenBufferInfoEx(hStdOut, @vInfo) then begin
      APal := TPaletteArray(vInfo.ColorTable);
      Result := True;
    end;
  end;


  procedure TConCtrlPlug.SetConsolePalette(const APal :TPaletteArray);
  var
    vInfo :TConsoleScreenBufferInfoEx;
  begin
    FillZero(vInfo, SizeOf(vInfo));
    vInfo.cbSize := SizeOf(vInfo);
    if GetConsoleScreenBufferInfoEx(hStdOut, @vInfo) then begin
      Inc(vInfo.srWindow.Right);
      Inc(vInfo.srWindow.Bottom);
      TPaletteArray(vInfo.ColorTable) := APal;
      SetConsoleScreenBufferInfoEx(hStdOut, @vInfo);
    end;
  end;


  procedure ScalePalette(var APalette :TPaletteArray; AMul :TFloat);
  var
    I :Integer;
  begin
    for I := 0 to High(APalette) do
      with TPaletteItem(APalette[I]) do begin
        R := RangeLimit(Round(R * AMul), 0, 255);
        G := RangeLimit(Round(G * AMul), 0, 255);
        B := RangeLimit(Round(B * AMul), 0, 255);
      end;
  end;


  procedure TConCtrlPlug.StorePalette(const AFileName :TString);

    procedure LocSavePal(var APalette :TPaletteArray);
    var
      I :Integer;
      vStr :TString;
    begin
      vStr := '';
      for I := 0 to High(APalette) do
        vStr := vStr + HexStr(APalette[I], 8) + CRLF;
      StrToFile(AFileName, vStr, sffAnsi);
    end;

    procedure LocSavePlt(var APalette :TPaletteArray);
    var
      vFile :THandle;
    begin
      vFile := FileCreate(AFileName);
      if vFile = INVALID_HANDLE_VALUE then
        ApiCheck(False);
      try
        FileWrite(vFile, APalette, SizeOf(APalette));
      finally
        FileClose(vFile);
      end;
    end;

  var
    vPalette :TPaletteArray;
  begin
    if not Assigned(SetConsoleScreenBufferInfoEx) or not GetConsolePalette(vPalette) then
      Exit;

    ScalePalette(vPalette, 1 / FPalScale);

    if StrEqual(ExtractFileExtension(AFileName), cPltFileExt) then
      LocSavePlt(vPalette)
    else
      LocSavePal(vPalette);
  end;



  procedure TConCtrlPlug.RestorePalette(const AFileName :TString);

    function LocRestorePal(var APalette :TPaletteArray) :Boolean;
    var
      vStr, vStr1 :TString;
      vPtr :PTChar;
      vIdx :Integer;
    begin
      Result := False;
      vStr := StrFromFile(AFileName);
      if vStr <> '' then begin
        vPtr := PTChar(vStr);
        vIdx := 0;
        while vPtr^ <> #0 Do begin
          vStr1 := ExtractNextWord(vPtr, [#13, #10], True);
          if not TryHex2Uns(vStr1, APalette[vIdx]) then
            Exit;
          Inc(vIdx);
        end;
        Result := True;
      end;
    end;

    function LocRestorePlt(var APalette :TPaletteArray) :Boolean;
    var
      vFile :THandle;
      vRes :Integer;
    begin
      Result := False;
      vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
      if vFile = INVALID_HANDLE_VALUE then
        ApiCheck(False);
      try
        vRes := FileRead(vFile, APalette, SizeOf(APalette));
        if vRes <> SizeOf(APalette) then
          Exit;
        Result := True;
      finally
        FileClose(vFile);
      end;
    end;

  var
    vPalette :TPaletteArray;
    vOk :Boolean;
  begin
    if not Assigned(SetConsoleScreenBufferInfoEx) or not GetConsolePalette(vPalette) then
      Exit;

    if StrEqual(ExtractFileExtension(AFileName), cPltFileExt) then
      vOk := LocRestorePlt(vPalette)
    else
      vOk := LocRestorePal(vPalette);

    if vOk then begin
      ScalePalette(vPalette, FPalScale);
      SetConsolePalette(vPalette);
    end else
      Beep;
  end;


  procedure TConCtrlPlug.RunCommand(const ACmd :TString);
  var
    vPos :Integer;
    vCmd, vParam :TString;
  begin
    vCmd := ACmd;
    vPos := ChrPos('=', ACmd);
    if vPos <> 0 then begin
      vCmd := Copy(ACmd, 1, vPos - 1);
      vParam := Copy(ACmd, vPos + 1, MaxInt);
    end;

    if StrEqual(vCmd, cScaleCmd) then begin
      FPalScale := StrToFloatDef(vParam, 1)
    end else
    if StrEqual(vCmd, cSaveCmd) then begin
      vParam := SafeChangeFileExtension(FarExpandFileName(StrExpandEnvironment(vParam)), cPalFileExt);
      StorePalette(vParam);
    end else
    if StrEqual(vCmd, cLoadCmd) then begin
      vParam := SafeChangeFileExtension(FarExpandFileName(StrExpandEnvironment(vParam)), cPalFileExt);
      RestorePalette(vParam);
    end else
      (*AppErrorIdFmt(strUnknownCommand, [ACmd])*);
  end;


end.


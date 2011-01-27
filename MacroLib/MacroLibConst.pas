{$I Defines.inc}

unit MacroLibConst;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Macro Library                                                          *}
{******************************************************************************}

interface

  uses
    Windows,

    PluginW,
    FarKeysW,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

    FarCtrl;

  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMMacroCommands,
      strMListOfAllMacroses,
      strMUpdateMacroses,
      strMOptions,

      strMProcessHotkeys,
      strMProcessMouse,
      strMMacroPaths,

      strMacroPathsTitle,
      strMacroPathsPrompt,

      strMacrosesTitle,

      strName,
      strDescription,
      strMacroarea,
      strHotkeys,
      strPriority,
      strFileName,
      strSequence,
(*
      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,
*)
      strMacroNotSpec,
      strMacroNotFound,
      strKeyNotSpec,
      strUnknownKeyName,

      strMacroParserErrors
    );


  const
    cPluginGUID     = $424C434D;
    cPlugRegFolder  = 'MacroLib';

    cDefMacroFolder = 'Macros';
    cMacroFileExt   = 'FML';

    cMacroPathName  = 'MacroLib.Paths';

    cMacroListDlgID :TGUID = '{F002A86D-BB4A-4A8F-A875-30286C06414B}';


  var
    optProcessHotkey :Boolean = True;   { Обрабатывать нажатия горячих клавиш }
    optProcessMouse  :Boolean = True;   { Обрабатывать события мыши }
    optMacroPaths    :TString = '';     { Путь к каталогу с макросами }

    optXLatMask      :Boolean = True;   { Автоматическое XLAT преобразование при поиске }
    optShowHints     :Boolean = True;

    optShowBind      :Integer = 0;
    optShowArea      :Integer = 0;
    optShowFile      :Integer = 0;

    optSortMode      :Integer = 0;

    optFoundColor    :Integer = 0;

    optDoubleDelay   :Integer = 500;
    optHoldDelay     :Integer = 1000;

    optCmdPrefix     :TString = 'FML';

  var
    FFarExePath      :TString;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  procedure HandleError(AError :Exception);

  function WinKeyRecToFarKey(const ARec :TKeyEventRecord) :Integer;
  function MouseEventToFarKey(const ARec :TMouseEventRecord; AOldState :DWORD; var APress, ADouble :Boolean) :Integer;

  function FarKeyToName(AKey :Integer) :TString;
  function FarGetMacroArea :Integer;
  function FarGetMacroState :Integer;

  procedure ReadSetup;
  procedure WriteSetup;

  procedure ToggleOption(var AOption :Boolean);
  procedure RestoreDefColor;

  procedure OpenEditor(const AFileName :TString; ARow, ACol :Integer; ASelectLine :Boolean = False; ATopLine :Integer = 0);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;

  function GetMsgStr(AMess :TMessages) :TString;
  begin
    Result := FarCtrl.GetMsgStr(Integer(AMess));
  end;


  procedure AppErrorId(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('Macro Library', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;

 {-----------------------------------------------------------------------------}

  function WinKeyRecToFarKey(const ARec :TKeyEventRecord) :Integer;
  var
    vKey, vShift :Integer;
  begin
    vKey := ARec.wVirtualKeyCode;
    vShift := ARec.dwControlKeyState;

    case vKey of
      $C0 : vKey := $60;              { ` }

      $BA : vKey := $3B;              { ; }
      $BB : vKey := $3D;              { = }
      $BC : vKey := $2C;              { , }
      $BD : vKey := $2D;              { - }
      $BE : vKey := KEY_DOT;          { . }
      $BF : vKey := KEY_SLASH;        { / }

      $DB : vKey := KEY_BRACKET;      { [ }
      $DC : vKey := KEY_BACKSLASH;    { \ }
      $DD : vKey := KEY_BACKBRACKET;  { ] }
      $DE : vKey := $27;              { ' }

(*
      VK_SHIFT: NOP{};
      VK_CONTROL: NOP{};
      VK_MENU: NOP{};
      VK_LWIN: NOP{};
      VK_RWIN: NOP{};
      VK_APPS: NOP{};
*)
      VK_SHIFT, VK_CONTROL, VK_MENU:
        vKey := 0;

      VK_BACK, VK_TAB, VK_RETURN, VK_ESCAPE, VK_SPACE,
      Byte('0')..Byte('9'),
      Byte('A')..Byte('Z'):
        {vKey := vKey};

    else
      Inc(vKey, EXTENDED_KEY_BASE);
    end;

    if vShift and SHIFT_PRESSED <> 0 then
      vKey := vKey or KEY_SHIFT;
    if vShift and LEFT_CTRL_PRESSED <> 0 then
      vKey := vKey or KEY_CTRL;
    if vShift and RIGHT_CTRL_PRESSED <> 0 then
      vKey := vKey or KEY_RCTRL;
    if vShift and LEFT_ALT_PRESSED <> 0 then
      vKey := vKey or KEY_ALT;
    if vShift and RIGHT_ALT_PRESSED <> 0 then
      vKey := vKey or KEY_RALT;

    Result := vKey;
  end;


  function MouseEventToFarKey(const ARec :TMouseEventRecord; AOldState :DWORD; var APress, ADouble :Boolean) :Integer;
  var
    vKey, vShift :Integer;

    procedure LocCheckButton(AButton :DWORD; AKey :Integer);
    var
      vPress, vOldPress :Boolean;
    begin
      vPress := ARec.dwButtonState and AButton <> 0;
      vOldPress := AOldState and AButton <> 0;
      if vPress <> vOldPress then begin
        vKey := AKey;
        APress := vPress;
      end;
    end;

  begin
    vKey := 0;
    vShift := ARec.dwControlKeyState;
    APress := True;
    ADouble := False;

    if (ARec.dwEventFlags = 0) or (ARec.dwEventFlags and DOUBLE_CLICK <> 0) then begin
      LocCheckButton(FROM_LEFT_1ST_BUTTON_PRESSED, KEY_MSLCLICK);
      LocCheckButton(RIGHTMOST_BUTTON_PRESSED,     KEY_MSRCLICK);
      LocCheckButton(FROM_LEFT_2ND_BUTTON_PRESSED, KEY_MSM3CLICK);
      if APress and (ARec.dwEventFlags and DOUBLE_CLICK <> 0) then
        ADouble := True;
    end else
    if ARec.dwEventFlags and MOUSE_WHEELED <> 0 then begin
      if Integer(ARec.dwButtonState) > 0 then
        vKey := KEY_MSWHEEL_UP
      else
      if Integer(ARec.dwButtonState) < 0 then
        vKey := KEY_MSWHEEL_DOWN;
    end else
    if ARec.dwEventFlags and MOUSE_HWHEELED <> 0 then begin
      if Integer(ARec.dwButtonState) > 0 then
        vKey := KEY_MSWHEEL_RIGHT
      else
      if Integer(ARec.dwButtonState) < 0 then
        vKey := KEY_MSWHEEL_LEFT;
    end;

    if vShift and SHIFT_PRESSED <> 0 then
      vKey := vKey or KEY_SHIFT;
    if vShift and LEFT_CTRL_PRESSED <> 0 then
      vKey := vKey or KEY_CTRL;
    if vShift and RIGHT_CTRL_PRESSED <> 0 then
      vKey := vKey or KEY_RCTRL;
    if vShift and LEFT_ALT_PRESSED <> 0 then
      vKey := vKey or KEY_ALT;
    if vShift and RIGHT_ALT_PRESSED <> 0 then
      vKey := vKey or KEY_RALT;

    Result := vKey;
  end;


  function FarKeyToName(AKey :Integer) :TString;
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FARSTD.FarKeyToName(AKey, nil, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen - 1);
      FARSTD.FarKeyToName(AKey, PTChar(Result), vLen);
    end;
  end;


  function FarGetMacroArea :Integer;
  var
    vMacro :TActlKeyMacro;
  begin
    vMacro.Command := MCMD_GETAREA;
    Result := FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
  end;


  function FarGetMacroState :Integer;
  var
    vMacro :TActlKeyMacro;
  begin
    vMacro.Command := MCMD_GETSTATE;
    Result := FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
  end;

 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vRoot :TString;
    vKey :HKEY;
  begin
    vRoot := FARAPI.RootKey;
    if RegOpenRead(HKCU, vRoot + '\' + cPlugRegFolder, vKey) then begin
      try
        optProcessHotkey := RegQueryLog(vKey, 'ProcessHotkey', optProcessHotkey);
        optProcessMouse := RegQueryLog(vKey, 'ProcessMouse', optProcessMouse);
        optMacroPaths := RegQueryStr(vKey, 'MacroPaths', optMacroPaths);

        optShowBind := RegQueryInt(vKey, 'ShowBind', optShowBind);
        optShowArea := RegQueryInt(vKey, 'ShowArea', optShowArea);
        optShowFile := RegQueryInt(vKey, 'ShowFile', optShowFile);

        optSortMode := RegQueryInt(vKey, 'SortMode', optSortMode);

        optXLatMask := RegQueryLog(vKey, 'XLatMask', optXLatMask);
        optShowHints := RegQueryLog(vKey, 'ShowHints', optShowHints);

        optDoubleDelay := RegQueryInt(vKey, 'DoubleDelay', optDoubleDelay);
        optHoldDelay := RegQueryInt(vKey, 'HoldDelay', optHoldDelay);

        optCmdPrefix := RegQueryStr(vKey, 'CmdPrefix', optCmdPrefix);

      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure WriteSetup;
  var
    vRoot :TString;
    vKey :HKEY;
  begin
    vRoot := FARAPI.RootKey;
    RegOpenWrite(HKCU, vRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'ProcessHotkey', optProcessHotkey);
      RegWriteLog(vKey, 'ProcessMouse', optProcessMouse);
      RegWriteStr(vKey, 'MacroPaths', optMacroPaths);

      RegWriteInt(vKey, 'ShowBind', optShowBind);
      RegWriteInt(vKey, 'ShowArea', optShowArea);
      RegWriteInt(vKey, 'ShowFile', optShowFile);

      RegWriteInt(vKey, 'SortMode', optSortMode);

      RegWriteLog(vKey, 'XLatMask', optXLatMask);
      RegWriteLog(vKey, 'ShowHints', optShowHints);

      RegWriteInt(vKey, 'DoubleDelay', optDoubleDelay);
      RegWriteInt(vKey, 'HoldDelay', optHoldDelay);
      
    finally
      RegCloseKey(vKey);
    end;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    WriteSetup;
  end;


  procedure RestoreDefColor;
  begin
    optFoundColor := clLime;
  end;


 {-----------------------------------------------------------------------------}

  function EditorFile(AWindow :Integer) :TString;
  var
    vWinInfo :TWindowInfo;
    vName :TString;
  begin
    Result := '';
    FarGetWindowInfo(AWindow, vWinInfo, @vName, nil);
    if vWinInfo.WindowType = WTYPE_EDITOR then
      Result := vName;
  end;


  procedure GotoPosition(ARow, ACol :Integer; ATopLine :Integer = 0);
  var
    vNewTop, vHeight :Integer;
    vPos :TEditorSetPosition;
    vInfo :TEditorInfo;
  begin
    Dec(ARow); Dec(ACol);
    vNewTop := -1;
    if FARAPI.EditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      if ATopLine = 0 then
        vHeight := vInfo.WindowSizeY
      else
        vHeight := ATopLine - 1{Строка состояния редактора};
      if (ARow < vInfo.TopScreenLine) or (ARow >= vInfo.TopScreenLine + vHeight) then
        vNewTop := RangeLimit(ARow - (vHeight div 2), 0, MaxInt{???});
    end;
    vPos.TopScreenLine := vNewTop;
    vPos.CurLine := ARow;
    vPos.CurPos := ACol;
    vPos.CurTabPos := -1;
    vPos.LeftPos := -1;
    vPos.Overtype := -1;
    FARAPI.EditorControl(ECTL_SETPOSITION, @vPos);
  end;


  procedure OpenEditor(const AFileName :TString; ARow, ACol :Integer; ASelectLine :Boolean = False; ATopLine :Integer = 0);
  var
    I, vCount :Integer;
    vFileName :TString;
    vFarFileName :TFarStr;
    vSel :TEditorSelect;
    vFound :Boolean;
  begin
    vFileName := EditorFile(-1);
    vFound := StrEqual(vFileName, AFileName);
    if not vFound then begin
      vCount := FARAPI.AdvControl(hModule, ACTL_GETWINDOWCOUNT, nil);
      for I := 0 to vCount - 1 do begin
        vFileName := EditorFile(I);
        vFound := StrEqual(vFileName, AFileName);
        if vFound then begin
          FARAPI.AdvControl(hModule, ACTL_SETCURRENTWINDOW, Pointer(TIntPtr(I)));
          FARAPI.AdvControl(hModule, ACTL_COMMIT, nil);
          Break;
        end;
      end;
    end;

    if vFound then
      GotoPosition(ARow, ACol, ATopLine)
    else begin
      {!!!}
      vFarFileName := AFileName;
      FARAPI.Editor(PFarChar(vFarFileName), nil, 0, 0, -1, -1, EF_NONMODAL or EF_IMMEDIATERETURN or EF_ENABLE_F6, ARow, ACol
        {$ifdef bUnicodeFar}
         ,CP_AUTODETECT
        {$endif bUnicodeFar}
      );
      if ATopLine <> 0 then
        GotoPosition(ARow, ACol, ATopLine);
    end;

    if ASelectLine and (ARow > 0) then begin
      vSel.BlockType := BTYPE_STREAM;
      vSel.BlockStartLine := ARow - 1;
      vSel.BlockStartPos := 0;
      vSel.BlockWidth := 256;
      vSel.BlockHeight := 1;

      FARAPI.EditorControl(ECTL_SELECT, @vSel);
      FARAPI.EditorControl(ECTL_REDRAW, nil);
    end;
  end;


end.

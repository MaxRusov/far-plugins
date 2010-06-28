{$I Defines.inc}

unit FarDebugCtrl;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

   {$ifdef bUnicodeFar}
    PluginW,
    FarColorW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarMatch;

   
  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMStart,
      strMStep,
      strMNext,
      strMNextLine,
      strMUntil,
      strMRun,
      strMKill,
      strMLocate,
      strMEvaluate,
      strMAddBreakpoit,
      strMFindAddress,
      strMDisassemble,
      strMWindows,
      strMDebugConsole,

      strMCallstack,
      strMBreakpoints,
      strMSources,

      strCallstack,
      strBreakpoints,
      strEvaluate,
      strSources,

      strFileName,
      strParameters,
      strLoad,
      strStep,
      strRun,

      strSrcFileNotFound,
      strFolderPrompt,
      strOkBut,
      strCancelBut,
      strButSelect,

      strFindAddress,
      strAddressPrompt,
      strAddressNotFound,

      strFileNotFound,
      strFileNotFound2,
      strFolderNotFound,
      strProgramNotRun,
      strLineHasNoDebugInfo,

      strWaitDebugger,
      strInterrupt,
      strInterruptPrompt,
      strYes,
      strNo,

      strOpenFileDialog,
      strDialogToolNotInstalled
    );


 {-----------------------------------------------------------------------------}

  type
    EGDBError = class(Exception);

  const
    cDefaultLang   = 'English';
    cMenuFileMask  = '*.mnu';

    cPlugRegFolder = 'FarDebug';

    cPlugMenuPrefix = 'deb';

    cNormalIcon = '['#$18']';
    cMaximizedIcon = '['#$12']';

  var
    optGDBName        :TString = 'gdb';   { Например, "GDB64" }
    optGDBPresets     :TString = '';
    optCygwinRoot     :TString = '';

    optShowCodeLine   :Boolean = False;

    optEdtExecColor   :Integer = $2F;
    optEdtBreakColor  :Integer = $CF;
    optEdtBreakColor1 :Integer = $E0;
    optEdtCodeColor   :Integer = $F0;

    optTermUserColor  :Integer = $09;
    optTermErrorColor :Integer = $0C;

    optFoundColor     :Integer = $0A;

    { FarDebugSourcesDlg }
    optSrcShowPath    :Boolean = True;
    optSrcSortMode    :Integer = 1;

  var
    FRegRoot    :TString;

  type
    TAddr = Int64;

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  procedure HandleError(AError :Exception);
  function ExtractNextLine(var AStr :PTChar) :TString;
  function ExtractBefore(const AStr, AStart, AFinish :TString) :TString;
  function UpCompareSubPChar(const SubStr1, Str2 :PTChar) :Integer;
  function AddrToNum(Addr :TString) :TAddr;

  procedure ReadSetup;
  procedure WriteSetup;

  function EditorFile(AWindow :Integer) :TString;
  function GetCurrentEditorPos :Integer;
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

  procedure AppErrorID(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;



  procedure HandleError(AError :Exception);
  begin
    if AError is EGDBError then
      ShowMessage('GDB', Trim(AError.Message), FMSG_WARNING or FMSG_MB_OK)
    else
      ShowMessage('FAR Debug', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


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


  function ExtractBefore(const AStr, AStart, AFinish :TString) :TString;
  var
    vStr :PTChar;
    vPos, vLen :Integer;
  begin
    Result := '';
    vStr := PTChar(AStr);
    if StringMatch(AStart, vStr, vPos, vLen) then begin
      Inc(vStr, vPos + vLen);
      if AFinish = '' then
        Result := vStr
      else
      if StringMatch(AFinish, vStr, vPos, vLen) then begin
        SetString(Result, vStr, vPos);
      end;
    end;
  end;


  function UpCompareSubPChar(const SubStr1, Str2 :PTChar) :Integer;
  var
    vLen :Integer;
  begin
    vLen := StrLen(SubStr1);
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, SubStr1, vLen, Str2, vLen) - 2;
  end;


  function AddrToNum(Addr :TString) :TAddr;
  begin
    if UpCompareSubStr('0x', Addr) = 0 then
      Delete(Addr, 1, 2);
    Result := Hex2Int64(Addr);
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


  function GetCurrentEditorPos :Integer;
  var
    vInfo :TEditorInfo;
  begin
    Result := 0;
    if FARAPI.EditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      Result := vInfo.CurLine + 1;
    end;
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


 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optGDBName := RegQueryStr(vKey, 'GDBName', optGDBName);
      optGDBPresets := RegQueryStr(vKey, 'GDBPresets', optGDBPresets);
      optCygwinRoot := RegQueryStr(vKey, 'CygwinRoot', optCygwinRoot);

      optEdtExecColor := RegQueryInt(vKey, 'ExecColor', optEdtExecColor);
      optEdtBreakColor := RegQueryInt(vKey, 'BreakColor', optEdtBreakColor);

      optSrcShowPath := RegQueryLog(vKey, 'SrcShowPath', optSrcShowPath);
      optSrcSortMode := RegQueryInt(vKey, 'SrcSortMode', optSrcSortMode);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
//    RegWriteStr(vKey, 'CompareCmd', optCompareCmd);

      RegWriteLog(vKey, 'SrcShowPath', optSrcShowPath);
      RegWriteInt(vKey, 'SrcSortMode', optSrcSortMode);

    finally
      RegCloseKey(vKey);
    end;
  end;


end.


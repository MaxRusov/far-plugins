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

    Far_API,
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
      strMLeave,
      strMRun,
      strMKill,
      strMLocate,
      strMEvaluate,
      strMAddBreakpoit,
      strMFindAddress,
      strMDisassemble,
      strMWindows,
      strMDebugConsole,
      strMOptions,

      strMCallstack,
      strMBreakpoints,
      strMSources,
      strMHelp,

      strMDebugger,
      strMPresets,
      strMCygwinRoot,
      strMColors,

      strCallstack,
      strBreakpoints,
      strEvaluate,
      strSources,
      strHelp,

      strFileName,
      strHostApp,
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
      strBYes,
      strBNo,

      strDebuggerBusy,
      strBTerminate,
      strBStopWaiting,
      strBContinueWaiting,

      strAddBreakTitle,
      strAddBreakPrompt,

      strDebuggerTitle,
      strDebuggerPrompt,
      strPresetsTitle,
      strPresetsPrompt,
      strCygwinTitle,
      strCygwinPrompt,

      strOpenFileDialog,
      strDialogToolNotInstalled
    );


 {-----------------------------------------------------------------------------}

  type
    EGDBError = class(Exception);

  const
//  cDefaultLang   = 'English';
//  cMenuFileMask  = '*.mnu';

    cPlugRegFolder = 'FarDebug';

    cPlugMenuPrefix = 'deb';

    cNormalIcon = '['#$18']';
    cMaximizedIcon = '['#$12']';

    cDefGDBName = 'gdb';

    cGlobalPresetsFileName = 'Presets.ini';
    cLocalPresetsFileName  = 'FarDebug.ini';

    cConsoleDlgID     :TGUID = '{D05AE970-3898-451D-969D-FD35BCD11569}';
    cDisasmDlgID      :TGUID = '{033FED7B-A5A4-4901-A69C-252A83E3989E}';
    cOpenDlgID        :TGUID = '{F9B2BA14-7566-4F90-A9AA-628288C1D8B2}';
    cPathDlgID        :TGUID = '{52A844F0-28F6-46BD-8BA4-A49F4F8DB52A}';
    cSourceDlgID      :TGUID = '{AEDE01B6-793F-4D55-A261-6885005206A9}';
    cEvaluateDlgID    :TGUID = '{9E9C13B1-661B-473F-AFDE-0DED582B9E70}';
    cBreakpointsDlgID :TGUID = '{67E49662-B1D0-4CEC-AE07-30F1893E0132}';
    cCallstackDlgID   :TGUID = '{54F046CE-8CC9-429D-A317-F289D9D55953}';
    cHelpDlgID        :TGUID = '{C2189295-7EC8-46DB-9BC1-E367A98B752D}';

    cHistGDBName      = 'FarDebug.GDBName';
    cHistPresets      = 'FarDebug.GDBPresets';
    cHistCygWinRoot   = 'FarDebug.CygWinRoot';
    cHistBreakpoint   = 'FarDebug.Breakpoint';


  var
    optGDBName        :TString = cDefGDBName;   { Например, "GDB64" }
    optGDBPresets     :TString = '';
    optCygwinRoot     :TString = '';

    optShowCodeLine   :Boolean = False;

    { FarDebugSourcesDlg }
    optSrcShowPath    :Boolean = True;
    optSrcSortMode    :Integer = 1;

    {CPU View}
    optCPUShowAddr    :Integer = 1;     { 0-No; 1-Addr; 2-Delta; 3-Addr+Delta }
    optCPUShowSrc     :Integer = 1;     { 0-File:Line 1-File:Line Str 2-Line Str 3-Str }
    optCPUMixSrc      :Boolean = True;  { Включать исходный код... }

    optCPUCurChar     :TChar   = #16;

  var
    optEdtExecColor   :Integer;
    optEdtBreakColor  :Integer;
    optEdtBreakColor1 :Integer;
    optEdtCodeColor   :Integer;

    optTermUserColor  :Integer;
    optTermErrorColor :Integer;

    optCPUSrcColor    :Integer;
    optCPUAddrColor   :Integer;
    optCPUAsmColor    :Integer;

    optFoundColor     :Integer;



  var
    LastHost     :TString;
    LastArgs     :TString;

  var
    FRegRoot     :TString;
    FModuleName  :TString;

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

  procedure RestoreDefColor;
  procedure ReadSetup(AHistory, ASettings :Boolean);
  procedure WriteSetup(AHistory :Boolean = False; ASettings :Boolean = True);

  function EditorFile(AWindow :Integer) :TString;
  procedure AddToHistory(const AHist, AStr :TString);

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
  var
    vStr :TString;
  begin
    if AError is EGDBError then begin
      vStr := AError.Message;
      vStr := StrReplace(vStr, #13#10, #10, [rfReplaceAll]);
      vStr := StrReplace(vStr, #13, #10, [rfReplaceAll]);
      ShowMessage('GDB', Trim(vStr), FMSG_WARNING or FMSG_MB_OK)
    end else
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
    if StringMatch(AStart, '', vStr, vPos, vLen) then begin
      Inc(vStr, vPos + vLen);
      if AFinish = '' then
        Result := vStr
      else
      if StringMatch(AFinish, '', vStr, vPos, vLen) then begin
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

  procedure AddToHistory(const AHist, AStr :TString);
  var
    hDlg :THandle;
    vItems :array[0..0] of TFarDialogItem;
  begin
    vItems[0] := NewItemApi(DI_Edit, 0, 0, 5, -1, DIF_HISTORY, '', PTChar(AHist) );
    hDlg := FARAPI.DialogInit(hModule, -1, -1, 9, 2, nil, Pointer(@vItems), 1, 0, 0, nil, 0);
    try
      FARAPI.SendDlgMessage(hDlg, DM_ADDHISTORY, 0, TIntPtr(PTChar(AStr)));
    finally
      FARAPI.DialogFree(hDlg);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optEdtExecColor   := clBkGreen + clWhite;
    optEdtBreakColor  := clBkRed + clWhite;
    optEdtBreakColor1 := clBkYellow + clBlack;
    optEdtCodeColor   := clBkWhite + clBlack;

    optTermUserColor  := clBlue;
    optTermErrorColor := clRed;

    optCPUSrcColor    := clBlue;
    optCPUAddrColor   := clGray;
    optCPUAsmColor    := clBlack;

    optFoundColor     := clLime;
  end;


  procedure ReadSetup(AHistory, ASettings :Boolean);
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      if AHistory then begin
        LastHost := RegQueryStr(vKey, 'LastHost', LastHost);
        LastArgs := RegQueryStr(vKey, 'LastArgs', LastArgs);
      end;

      if ASettings then begin
        optGDBName := RegQueryStr(vKey, 'GDBName', optGDBName);
        optGDBPresets := RegQueryStr(vKey, 'GDBPresets', optGDBPresets);
        optCygwinRoot := RegQueryStr(vKey, 'CygwinRoot', optCygwinRoot);

        optEdtExecColor := RegQueryInt(vKey, 'ExecColor', optEdtExecColor);
        optEdtBreakColor := RegQueryInt(vKey, 'BreakColor', optEdtBreakColor);

        optSrcShowPath := RegQueryLog(vKey, 'SrcShowPath', optSrcShowPath);
        optSrcSortMode := RegQueryInt(vKey, 'SrcSortMode', optSrcSortMode);
      end;

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup(AHistory :Boolean = False; ASettings :Boolean = True);
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      if AHistory then begin
        RegWriteStr(vKey, 'LastHost', LastHost);
        RegWriteStr(vKey, 'LastArgs', LastArgs);
      end;

      if ASettings then begin
        RegWriteStr(vKey, 'GDBName', optGDBName);
        RegWriteStr(vKey, 'GDBPresets', optGDBPresets);
        RegWriteStr(vKey, 'CygwinRoot', optCygwinRoot);

        RegWriteLog(vKey, 'SrcShowPath', optSrcShowPath);
        RegWriteInt(vKey, 'SrcSortMode', optSrcSortMode);
      end;

    finally
      RegCloseKey(vKey);
    end;
  end;


end.


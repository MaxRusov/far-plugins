{$I Defines.inc}

unit FarDebugGDB;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarMatch,
    FarCtrl,
    FarDebugCtrl,
    FarDebugIO;


  const
    cCustomPrompt = #16;  


  procedure InitGDBDebugger;

  procedure LoadModule(const AName, AHost, AArgs :TString);
  procedure DebugCommand(const ACmd :TString; ALocate :Boolean);

  procedure DisassembleCurrentLine;
  procedure LocateSource(AUpdate :boolean);
  procedure LocateByAddr(const Addr :TString; ATopLine :Integer = 0);

  function GetCurrentProcess :TString;
  function GetCurrentAddr :TString;
  function GetCurrentSourceFile :TString;
  function GetAddrOfLine(const AFileName :TString; ALine :Integer; AllowNearest :Boolean = False) :TString;
  function GetInfoLine(const Addr :TString) :TString;
  function GetSourceLineAt(const Addr :TString; var AFileName :TString; var ALine :Integer;
    AProc :PTString = nil; ABegAddr :PTString = nil; AEndAddr :PTString = nil) :boolean;

  procedure ExtractLocation(const ALoc :TString; var ASrcName :TString; var ALine :Integer);

 {-----------------------------------------------------------------------------}

  type
    TSourceFile = class(TBasis)
    public
      destructor Destroy; override;

      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

      procedure UpdateLineInfo(ARow1, ARow2 :Integer);
      function GetVisiblePath :TString;

    private
      FFileName :TString;
      FFullName :TString;
      FOrigName :TSTring;
      FLineInfo :TExList;

    public
      property FileName :TString read FFileName;
      property FullName :TString read FFullName;
      property OrigName :TString read FOrigName;
      property LineInfo :TExList read FLineInfo;
    end;

  var
    SrcFiles :TObjList;

  procedure UpdateSourcesList;
  function FullNameToSourceFile(const AFileName :TString; APrompt :Boolean) :TString;
  function FindSrcWrapper(const AFileName :TString) :TSourceFile;

 {-----------------------------------------------------------------------------}

  type
    TBreakpoint = class(TBasis)
    private
      FID       :Integer;
//    FType     :Integer;
      FEnabled  :Boolean;
      FAddr     :TString;
      FProc     :TString;
      FSource   :TString;
      FFile     :TString;
      FLine     :Integer;

    public
      property ID :Integer read FID;
      property Enabled :Boolean read FEnabled;
      property Proc :TString read FProc;
      property Source :TString read FSource;
      property FileName :TString read FFile;
      property Line :Integer read FLine;
      property Addr :TString read FAddr;
    end;

  var
    Breakpoints :TObjList;


  procedure UpdateBreakpoints;
  procedure AddBreakpoint;
  procedure DeleteBreakpoint(AID :Integer);
  procedure EnableBreakpoint(AID :Integer; AEnable :Boolean);

  procedure RunToLine;

 {-----------------------------------------------------------------------------}

  var
    DebugProcess  :TString;
    DebugAddr     :TString;
    DebugAddrN    :TAddr;
    DebugSource   :TString;
    DebugFile     :TString;
    DebugLine     :Integer;

  procedure ResetDebuggerState;
  procedure UpdateDebuggerState;


 {-----------------------------------------------------------------------------}

  function GDBCheckInterrupt :Boolean;

  procedure RedirCall(const ACommand :TString; PRes :PTString = nil);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    FarDebugConsole,
    FarDebugPathDlg,
    MixDebug;

 {-----------------------------------------------------------------------------}


  function ConvertFileName(const AName :TString) :TString;
  var
    I :Integer;
  begin
    Result := AName;
    for I := Length(Result) downto 1 do
      if Result[I] = '\' then
        Insert('\', Result, I);
  end;


 {-----------------------------------------------------------------------------}

  procedure SetCustomPresets(const AStr :TString; const ADel :TAnsiCharSet);
  var
    I :Integer;
    vStr :TString;
  begin
    for I := 1 to WordCount(AStr, ADel) do begin
      vStr := Trim(ExtractWord(I, AStr, ADel));
      if (vStr <> '') and (vStr[1] <> ';') then
        RedirCall(vStr);
    end;
  end;


  procedure InitGDBDebugger;
  var
    vFileName, vStr :TString;
  begin
    if RedirInited then
      Exit;

    if optGDBName = '' then
      optGDBName := cDefGDBName;

    try
      RedirChildProcess(optGDBName);
      RedirReadAnswer(@vStr, ' '); // Default prompt: "(gdb) "

      if copy(vStr, length(vStr) - 4, 5) = '(gdb)' then
        vStr := copy(vStr, 1, length(vStr) - 5);
      AddConsole(vStr);
      
    except
      on E :Exception do
        AppErrorFmt('Can not run debugger "%s":'#10'%s', [optGDBName, E.Message]);
    end;

    {Устанавливаем уникальный Prompt}
    TerminatorChar := cCustomPrompt;
    RedirCall('set prompt ' + cCustomPrompt);
    {Отказываемся от запросов подтверждений}
    RedirCall('set confirm 0');
    {Установка "бесконечного" количества строк на экране}
    RedirCall('set height -1');
    {Заканчивать печать массивов "char" на нулевом символе}
    RedirCall('set print null-stop 1');
    {Установить "красивый" режим вывода элементов массива}
    RedirCall('set print array 1');
    {Установить "красивый" режим вывода структур}
    RedirCall('set print pretty 1');
    {Установить вывод в новую консоль}
    RedirCall('set new-console 1');
    { Запретить создавать новую группу }
    RedirCall('set new-group 0');
    { Разворачивать стек при получении сигнала }
    RedirCall('set unwindonsignal on');

    vFileName := AddFileName(ExtractFilePath(FModuleName), cGlobalPresetsFileName);
    if WinFileExists(vFileName) then begin
      vStr := StrFromFile(vFileName);
      SetCustomPresets(vStr, [#13, #10]);
    end;

    SetCustomPresets(optGDBPresets, [';']);
  end;


  procedure LoadModule(const AName, AHost, AArgs :TString);
  var
    vFileName, vStr :TString;
  begin
    InitGDBDebugger;

    // file with no argument makes GDB discard any information it has on both executable file and the symbol table.
    // Без этого GDB иногда слетает при повторном запуске отладки...
    RedirCall('file');

    RedirCall('file "' + ConvertFileName(AName) + '"');

    if AHost <> '' then
      RedirCall('exec-file "' + ConvertFileName(AHost) + '"');

    RedirCall('set args ' + AArgs);

    vFileName := AddFileName(ExtractFilePath(AName), cLocalPresetsFileName);
    if WinFileExists(vFileName) then begin
      vStr := StrFromFile(vFileName);
      SetCustomPresets(vStr, [#13, #10]);
    end;

    UpdateSourcesList;
    UpdateDebuggerState;
  end;


  procedure DebugCommand(const ACmd :TString; ALocate :Boolean);
  begin
    InitGDBDebugger;
    try
      if StrEqual(EditorFile(-1), DebugFile) then begin
        DebugFile := '';
        DebugLine := 0;
//      FARAPI.EditorControl(ECTL_REDRAW, nil);
        FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);
      end;

      RedirCall(ACmd);

    except
      on E :Exception do
        if StrUpPos('No such file', E.Message) = 0 then
          raise;
    end;
    UpdateDebuggerState;
    if ALocate and (DebugAddr <> '') then
      LocateSource(False);
  end;


 {-----------------------------------------------------------------------------}

  procedure LocateSource(AUpdate :boolean);
  begin
    if AUpdate then
      UpdateDebuggerState;
    if DebugAddr = '' then
      AppErrorId(strProgramNotRun);
    if DebugSource = '' then
      AppError(Trim(GetInfoLine(DebugAddr)));

    if (DebugFile = '') or not WinFileExists(DebugFile) then begin
      FullNameToSourceFile(DebugSource, True);
      UpdateDebuggerState;
      if (DebugFile = '') or not WinFileExists(DebugFile) then
        AppErrorIdFmt(strSrcFileNotFound, [DebugSource]);
    end;

    OpenEditor(DebugFile, DebugLine, 0);
    FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);
  end;


  procedure LocateByAddr(const Addr :TString; ATopLine :Integer = 0);
  var
    vFileName :TString;
    vLine :Integer;
  begin
    if GetSourceLineAt(Addr, vFileName, vLine) then begin
      vFileName := FullNameToSourceFile(vFileName, True);
      OpenEditor(vFileName, vLine, 0, True, ATopLine);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure DisassembleCurrentLine;
  var
    vAddr, vAddr1, vAddr2, vRes :TString;
  begin
    vAddr := GetCurrentAddr;
    if vAddr = '' then
      AppErrorId(strProgramNotRun);

    RedirCall('info line *' + vAddr, @vRes);

    vAddr1 := ExtractBefore(vRes, '*starts at address *', '* *');
    vAddr2 := ExtractBefore(vRes, '*ends at *', '* *');
//  TraceF('%s - %s', [vAddr1, vAddr2]);

    ShowConsoleDlg('disas ' + vAddr1 + ' ' + vAddr2);
  end;


 {-----------------------------------------------------------------------------}


  function GetCurrentProcess :TString;
  var
    vRes :TString;
  begin
    Result := '';
    RedirCall('info files', @vRes);
    if vRes <> '' then begin
      Result := ExtractBefore(vRes, 'Symbols from "*', '*"*');
      Result := StrReplaceChars(Result, ['/'], '\');
    end;
  end;


  function GetCurrentAddr :TString;
  var
    vRes :TString;
  begin
    Result := '';
    RedirCall('info program', @vRes);
    if vRes <> '' then begin
      Result := ExtractBefore(vRes, '*stopped at *', '*.*');
    end;
  end;


  function GetCurrentSourceFile :TString;
  var
    vRes :TString;
  begin
    Result := '';
    RedirCall('info source', @vRes);
    if vRes <> '' then begin
      Result := ExtractBefore(vRes, '*located in *', '*'#13'*');
      Result := StrReplaceChars(Result, ['/'], '\');
    end;
  end;


  function GetInfoLine(const Addr :TString) :TString;
  begin
    RedirCall('info line *' + Addr, @Result);
  end;


{
Line 601 of "S:/Libs/SysWindows.pas"
   starts at address 0x101e0f3 <TraceException+387>
   and ends at 0x101e110 <TraceCallstack>.

No line number information available for address
   0x100ac67 <SYSTEM_HANDLEERRORADDRFRAME$LONGINT$POINTER$POINTER+39>

No line number information available for address 0x123
}

  function GetSourceLineAt(const Addr :TString; var AFileName :TString; var ALine :Integer;
    AProc :PTString = nil; ABegAddr :PTString = nil; AEndAddr :PTString = nil) :boolean;
  var
    vRes :TString;
  begin
    Result := False;
    RedirCall('info line *' + Addr, @vRes);
    AFileName := ExtractBefore(vRes, '*of "*', '*"*');
    AFileName := ExtractFileName(StrReplaceChars(AFileName, ['/'], '\'));
    if AFileName <> '' then begin
      ALine := Str2IntDef( Trim(ExtractBefore(vRes, '*Line *', '* of*')), 0);
      if AProc <> nil then
        AProc^ := ExtractBefore(vRes, '*starts at address * <*', '*>*');
      if ABegAddr <> nil then
        ABegAddr^ := ExtractBefore(vRes, '*starts at address *', '* *');
      if AEndAddr <> nil then
        AEndAddr^ := ExtractBefore(vRes, '*ends at *', '* *');
      Result := True;
    end else
    begin
      if AProc <> nil then
        AProc^ := ExtractBefore(vRes, 'No line number * <*', '*>*');
    end;
  end;

{
Line 787 of "FPTest.dpr" starts at address 0x1001bd7 <$main+87>'#$D#$A'   and ends at 0x1001bdc <$main+92>.
Line 761 of "FPTest.dpr" is at address 0x1001ab0 <Test1> but contains no code.
}

  function GetAddrOfLine(const AFileName :TString; ALine :Integer; AllowNearest :Boolean = False) :TString;
  var
    vRes, vFileName, vAddr1, vAddr2 :TString;
  begin
    Result := '';
    RedirCall('info line ' + ExtractFileName(AFileName) + ':' + Int2Str(ALine), @vRes);
    if vRes <> '' then begin
      vFileName := ExtractBefore(vRes, '*of "*', '*"*');
      vFileName := ExtractFileName(StrReplaceChars(vFileName, ['/'], '\'));
      vAddr1 := ExtractBefore(vRes, '*starts at address *', '* *');
      vAddr2 := ExtractBefore(vRes, '*ends at *', '* *');
      if StrEqual(vFileName, ExtractFileName(AFileName)) and (vAddr2 <> '') then
        Result := vAddr1;
      if (Result = '') and AllowNearest then
        Result := ExtractBefore(vRes, '*is at address *', '* *');
    end;
  end;


 {-----------------------------------------------------------------------------}

  destructor TSourceFile.Destroy; {override;}
  begin
    FreeObj(FLineInfo);
    inherited Destroy;
  end;


  function TSourceFile.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FFileName, TString(Key));
  end;


  function TSourceFile.GetVisiblePath :TString;
  begin
    Result := FFullName;
    if Result = '' then
      Result := StrReplaceChars(FOrigName, ['/'], '\');
    Result := RemoveBackSlash(ExtractFilePath(Result));
  end;


  procedure TSourceFile.UpdateLineInfo(ARow1, ARow2 :Integer);
  var
    I :Integer;
    P :PByte;
    vAddr :TString;
  begin
    if FLineInfo = nil then
      FLineInfo := TExList.CreateSize(1);
    if FLineInfo.Count < ARow2 then
      FLineInfo.Count := ARow2;
    for I := ARow1 to ARow2 - 1 do begin
      P := FLineInfo.PItems[I];
      if P^ = 0 then begin
        vAddr := GetAddrOfLine(FFileName, I + 1);
        if vAddr <> '' then
          P^ := 1
        else
          P^ := 2;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  const
    cCygDrive = '\cygdrive\';

  function GDBPathToLocalPath(const AName :TString) :TString;
  var
    vPath :TString;
  begin
    vPath := StrReplaceChars(AName, ['/'], '\');
    if (optCygwinRoot <> '') and (UpCompareSubStr(cCygDrive, vPath) = 0) then begin
      vPath := Copy(vPath, length(cCygDrive) + 1, MaxInt);
      if (length(vPath) >= 2) and (vPath[2] = '\') then
        vPath := TString(vPath[1]) + ':' + Copy(vPath, 2, MaxInt);
      Result := CombineFileName(optCygwinRoot, vPath);
    end else
      Result := vPath;
  end;


  function LocalPathToGDBPath(const AName :TString) :TString;
  begin
    if (optCygwinRoot <> '') and FileNameIsLocal(AName) then begin
      Result := cCygDrive + AName[1] + Copy(AName, 3, MaxInt);
    end else
      Result := AName;
    Result := StrReplaceChars(Result, ['\'], '/');
  end;


  procedure UpdateSourcesList;
  var
    vRes, vStr, vName, vFullName, vFileName, vFilePath :TString;
    vPtr, vTmp :PTChar;
    vIndex :Integer;
    vFile :TSourceFile;
  begin
    SrcFiles.FreeAll;
    RedirCall('info sources', @vRes);
    if vRes <> '' then begin
     {$ifdef bTrace}
//    Trace('Source files:');
     {$endif bTrace}
      vPtr := PTChar(vRes);
      while vPtr^ <> #0 do begin
        vStr := ExtractNextLine(vPtr);
        if (vStr <> '') and (vStr[length(vStr)] <> ':') then begin
          vTmp := PTChar(vStr);
          while vTmp^ <> #0 do begin
            vName := Trim(ExtractNextWord(vTmp, [',']));
            if (vName <> '') and (ChrsPos(['<', '>'], vName) = 0) then begin
              vFullName := GDBPathToLocalPath(vName);
              vFileName := ExtractFileName(vFullName);
              if vFileName <> '' then begin
                if SrcFiles.FindKey(Pointer(vFileName), 0, [foBinary], vIndex) then
                  vFile := SrcFiles[vIndex]
                else begin
                  vFile := TSourceFile.Create;
                  vFile.FFileName := vFileName;
                  SrcFiles.Insert(vIndex, vFile);
                end;
                vFilePath := ExtractFilePath(vFullName);
                if (vFilePath <> '') and (vFile.FFullName = '') then begin
                  vFile.FOrigName := vName;
                  if IsFullFilePath(vFullName) then
                    vFile.FFullName := ExpandFileName(vFullName);
                end;
               {$ifdef bTrace}
//              TraceF('  %s - %s', [vFileName, vFile.FFullName]);
               {$endif bTrace}
              end;
            end;
          end;
        end;
      end;
    end;
  end;


  function FullNameToSourceFile(const AFileName :TString; APrompt :Boolean) :TString;
  var
    vIndex :Integer;
    vFolder :TString;
  begin
    Result := '';
    if SrcFiles.FindKey(Pointer(AFileName), 0, [foBinary], vIndex) then
      Result := TSourceFile(SrcFiles[vIndex]).FFullName;

    if APrompt and ((Result = '') or not WinFileExists(Result)) then begin
      if PromptFolderDlg(AFileName, vFolder) then begin

        RedirCall('directory ' + LocalPathToGDBPath(vFolder));
        UpdateSourcesList;

        Result := FullNameToSourceFile(AFileName, APrompt);

      end;
    end;
  end;


  function FindSrcWrapper(const AFileName :TString) :TSourceFile;
  var
    vIndex :Integer;
    vFileName :TString;
  begin
    Result := nil;
    vFileName := ExtractFileName(AFileName);
    if SrcFiles.FindKey(Pointer(vFileName), 0, [foBinary], vIndex) then
      Result := SrcFiles[vIndex];
  end;


 {-----------------------------------------------------------------------------}

  procedure ExtractLocation(const ALoc :TString; var ASrcName :TString; var ALine :Integer);
  var
    vPos :Integer;
  begin
    vPos := LastDelimiter(':', ALoc);
    if vPos <> 0 then begin
      ASrcName := Copy(ALoc, 1, vPos - 1);
      ALine := Str2IntDef(Copy(ALoc, vPos + 1, MaxInt), 0);
    end else
      ASrcName := ALoc;
    ASrcName := ExtractFileName(StrReplaceChars(ASrcName, ['/'], '\'));
  end;


  procedure UpdateBreakpoints;
  var
    vID :Integer;
    vRes, vStr :TString;
    vPtr, vTmp :PTChar;
    vBreak :TBreakpoint;
    vOldWidth, vPos, vLen :Integer;
  begin
    RedirCall('show width', @vRes);
    vOldWidth := Str2IntDef(ExtractBefore(vRes, '*is *', '*.*'), -1);
    RedirCall('set width -1');
    try
      Breakpoints.FreeAll;
      RedirCall('info breakpoints', @vRes);
      if vRes <> '' then begin

        vPtr := PTChar(vRes);
        ExtractNextLine(vPtr); { Пропускаем заголовок }
        while vPtr^ <> #0 do begin
          vStr := ExtractNextLine(vPtr);

          vTmp := PTChar(vStr);
          vID := Str2IntDef( ExtractNextWord(vTmp, [' ']), -1); //Num
          if vID <> -1 then begin
            vBreak := TBreakpoint.Create;
            vBreak.FID := vID;

            ExtractNextWord(vTmp, [' ']); //Type
            ExtractNextWord(vTmp, [' ']); //Disp
            vBreak.FEnabled := StrEqual(ExtractNextWord(vTmp, [' ']), 'y'); //Enabled
            vBreak.FAddr := ExtractNextWord(vTmp, [' ']); //Address
            if UpCompareSubPChar('in ', vTmp) = 0 then begin
              Inc(vTmp, 3);
              if StringMatch('* at *', '', vTmp, vPos, vLen) then begin
                SetString(vBreak.FProc, vTmp, vPos);
                Inc(vTmp, vPos + vLen);
                ExtractLocation(vTmp, vBreak.FSource, vBreak.FLine);
                vBreak.FFile := FullNameToSourceFile(vBreak.FSource, False);
              end else
                vBreak.FProc := vTmp;
            end;
            Breakpoints.Add(vBreak);
          end;
        end;
      end;
    finally
      if vOldWidth <> - 1 then
        RedirCall('set width ' + Int2Str(vOldWidth));
    end;
  end;


  function FindBreakpointBySource(const AFileName :TString; ALine :Integer) :TBreakpoint;
  var
    I :Integer;
    vBreak :TBreakpoint;
  begin
    for I := 0 to Breakpoints.Count - 1 do begin
      vBreak := Breakpoints[I];
      if StrEqual(AFileName, vBreak.FileName) and (ALine = vBreak.Line) then begin
        Result := vBreak;
        Exit;
      end;
    end;
    Result := nil;
  end;


  procedure AddBreakpoint;
  var
    vFileName, vAddr :TString;
    vLine :Integer;
    vBreak :TBreakpoint;
  begin
    vFileName := EditorFile(-1);
    if vFileName = '' then
      Exit;

    vLine := GetCurrentEditorPos;
    if vLine = 0 then
      Exit;

    vBreak := FindBreakpointBySource(vFileName, vLine);

    if vBreak = nil then begin
      vAddr := GetAddrOfLine(vFileName, vLine);
      if vAddr = '' then
        AppErrorId(strLineHasNoDebugInfo);

      RedirCall('break *' + vAddr);
      UpdateBreakpoints;

      if True then
        AddToHistory(cHistBreakpoint, ExtractFileName(vFileName) + ':' + Int2Str(vLine));
    end else
      DeleteBreakpoint(vBreak.FID);
  end;


  procedure DeleteBreakpoint(AID :Integer);
  begin
    RedirCall('delete breakpoint ' + Int2Str(AID));
    UpdateBreakpoints;
  end;


  procedure EnableBreakpoint(AID :Integer; AEnable :Boolean);
  begin
    if AEnable then
      RedirCall('enable ' + Int2Str(AID))
    else
      RedirCall('disable ' + Int2Str(AID));
    UpdateBreakpoints;
  end;


  procedure RunToLine;
  var
    vFileName, vAddr :TString;
    vLine :Integer;
  begin
    vFileName := EditorFile(-1);
    if vFileName = '' then
      Exit;

    vLine := GetCurrentEditorPos;
    if vLine = 0 then
      Exit;

    vAddr := GetAddrOfLine(vFileName, vLine);
    if vAddr = '' then
      AppErrorId(strLineHasNoDebugInfo);

    RedirCall('tbreak *' + vAddr);
    DebugCommand(StrIf(DebugAddr = '', 'run', 'continue'), True);
  end;


 {-----------------------------------------------------------------------------}

  procedure ResetDebuggerState;
  begin
    DebugProcess := '';
    DebugAddr := '';
    DebugAddrN := 0;
    DebugSource := '';
    DebugFile := '';
    DebugLine := 0;
    SrcFiles.FreeAll;
    Breakpoints.FreeAll;
    SetEnvironmentVariable('FarDebug', nil);
  end;


  procedure UpdateDebuggerState;
  begin
    if not RedirInited then begin
      ResetDebuggerState;
      Exit;
    end;

    DebugProcess := GetCurrentProcess;
    DebugAddr := GetCurrentAddr;
    DebugLine := 0;
    DebugSource := '';
    DebugFile := '';
    if DebugAddr <> '' then begin
      DebugAddrN := AddrToNum(DebugAddr);
      if GetSourceLineAt(DebugAddr, DebugSource, DebugLine) then
        DebugFile := FullNameToSourceFile(DebugSource, False);
      SetEnvironmentVariable('FarDebug', '1');
    end else
      SetEnvironmentVariable('FarDebug', '2');
  end;



 {-----------------------------------------------------------------------------}


  function GDBCheckInterrupt :Boolean;
  var
    vRes :Integer;
  begin
    Result := True;
    if CheckForEsc then begin
      vRes := ShowMessage(GetMsgStr(strInterrupt), GetMsgStr(strDebuggerBusy) + #10 +
        GetMsgStr(strBTerminate) + #10 + GetMsgStr(strBStopWaiting) + #10 + GetMsgStr(strBContinueWaiting),
        FMSG_WARNING, 3);
      if vRes = 0 then begin
        RedirTerminate;
        Result := False;
      end else
      if vRes = 1 then
        Result := False;
    end;
  end;


  var
    vSave  :Integer;
    vStart :DWORD;
    vLast  :DWORD;


  function ReadIdle :Boolean;
  var
    vTick :DWORD;
    vMess :TString;
  begin
    Result := True;
    vTick := GetTickCount;
    if Integer(TickCountDiff(vTick, vLast)) < IntIf(vSave = 0, 300, 100) then
      Exit;

    Result := GDBCheckInterrupt;
    if not Result then
      Abort;

    if vSave = 0 then
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);

    vMess :=
      'GDB'#10 +
      GetMsgStr(strWaitDebugger) + ' (' + Int2Str(TickCountDiff(vTick, vStart) div 1000) + ')...';

    FARAPI.Message(hModule, FMSG_ALLINONE, nil, PPCharArray(PTChar(vMess)), 0, 0);
    FARAPI.Text(0, 0, 0, nil);
    vLast := vTick;
  end;



  function GDBWaitAnswer(AEvent :TRedirEvent; const AStr :TAnsiStr; AContext :Pointer) :Boolean;
  begin
    if AEvent = reIdle then
      Result := ReadIdle
    else
      Result := DEFWaitAnswer(AEvent, AStr, AContext);
  end;


  procedure RedirCall(const ACommand :TString; PRes :PTString = nil);
  begin
    vSave := 0;
    try
      vStart := GetTickCount;
      vLast := vStart;

      RedirSendCommand(ACommand);
      RedirReadAnswer(PRes, #0, 0, GDBWaitAnswer, nil);

    finally
      if vSave <> 0 then
        FARAPI.RestoreScreen(vSave);
    end;
  end;



initialization
  SrcFiles := TObjList.Create;
  Breakpoints := TObjList.Create;

finalization
  FreeObj(SrcFiles);
  FreeObj(Breakpoints);
end.


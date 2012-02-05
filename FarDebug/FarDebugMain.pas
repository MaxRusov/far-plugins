{$I Defines.inc}
{$Typedaddress Off}

unit FarDebugMain;

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
    MixWinUtils,
    MixClasses,

    Far_API,
    FarCtrl,
    FarMenu,

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB,
    FarDebugListBase,
    FarDebugOpenDlg,
    FarDebugEvaluate,
    FarDebugCallstack,
    FarDebugBreakpoints,
    FarDebugSourcesDlg,
    FarDebugFindAddr,
    FarDebugDisasm,
    FarDebugConsole,
    FarDebugHelp;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;



  function GetCurrentFile :TString;
  var
    vInfo :TPanelInfo;
    vItem :PPluginPanelItem;
    vFolder :TString;
    vIndex :Integer;
  begin
    Result := '';

    FillZero(vInfo, SizeOf(vInfo));
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, 0, @vInfo);

    if (vInfo.PanelType = PTYPE_FILEPANEL) and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0)) then begin
      vFolder := FarPanelGetCurrentDirectory(INVALID_HANDLE_VALUE);

      vIndex := vInfo.CurrentItem;
      if (vIndex < 0) or (vIndex >= vInfo.ItemsNumber) then
        Exit;

      vItem := FarPanelItem(INVALID_HANDLE_VALUE, FCTL_GETPANELITEM, vIndex);
      try
        if faDirectory and vItem.FindData.dwFileAttributes = 0 then
          Result := AddFileName(vFolder, FarChar2Str(vItem.FindData.cFileName));
      finally
        MemFree(vItem);
      end;
    end;
  end;


  procedure OpenCmdLine(const AStr :TString);
  var
    vPtr :PTChar;
    vStr :TString;
  begin
//  TraceF('Str=%s', [AStr]);
    if AStr = '' then
      Exit;

    if AStr[1] = '>' then
      DebugCommand(Copy(AStr, 2, MaxInt), False)
    else begin
      vPtr := PTChar(AStr);
      vStr := ExtractParamStr(vPtr);

      vStr := ExpandFileName(vStr);
      if not WinFileExists(vStr) then
        AppErrorIdFmt(strFileNotFound2, [vStr]);

      LoadModule(vStr, '', vPtr);
    end;
  end;


  procedure OptionsMenu;
  const
    cBoxFlags = FIB_BUTTONS or FIB_ENABLEEMPTY or FIB_NOUSELASTHISTORY;
  var
    vMenu :TFarMenu;
    vSave :Boolean;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMDebugger),
      GetMsg(strMPresets),
      GetMsg(strMCygwinRoot),
      '',
      GetMsg(strMColors)
    ]);
    try
      vMenu.Help := 'Options';
      while True do begin
//      vMenu.Checked[0] := ...

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        vSave := False;

        case vMenu.ResIdx of
          0: vSave := FarInputBox(GetMsg(strDebuggerTitle), GetMsg(strDebuggerPrompt), optGDBName, cBoxFlags, cHistGDBName);
          1: vSave := FarInputBox(GetMsg(strPresetsTitle), GetMsg(strPresetsPrompt), optGDBPresets, cBoxFlags, cHistPresets);
          2: vSave := FarInputBox(GetMsg(strCygwinTitle), GetMsg(strCygwinPrompt), optCygwinRoot, cBoxFlags, cHistCygWinRoot);

          4: Sorry;
        end;

        if vSave then
          WriteSetup;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;

  
  procedure WindowsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMCallstack),
      GetMsg(strMBreakpoints),
      GetMsg(strMSources),
      GetMsg(strMHelp)
    ]);
    try
      vMenu.Enabled[0] := DebugProcess <> '';
      vMenu.Enabled[1] := DebugProcess <> '';
      vMenu.Enabled[2] := DebugProcess <> '';

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: CallstackDlg;
        1: BreakpointesDlg;
        2: SourcesDlg;
        3: HelpDlg;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure OpenMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMStart),         //0
      GetMsg(strMRun),           //1
      GetMsg(strMStep),          //2
      GetMsg(strMNext),          //3
      GetMsg(strMUntil),         //4
      GetMsg(strMLeave),         //5
      GetMsg(strMKill),          //6
      GetMsg(strMLocate),        //7
      '',
      GetMsg(strMEvaluate),      //9
      GetMsg(strMAddBreakpoit),  //10
      GetMsg(strMFindAddress),   //11
      GetMsg(strMDisassemble),   //12
      GetMsg(strMWindows),       //13
      '',
      GetMsg(strMDebugConsole),  //15
      GetMsg(strMOptions)        //16
    ]);

    try
      vMenu.Help := 'MainMenu';

      vMenu.Enabled[1] := DebugProcess <> '';
      vMenu.Enabled[2] := DebugProcess <> '';
      vMenu.Enabled[3] := DebugProcess <> '';
      vMenu.Enabled[4] := DebugProcess <> '';
      vMenu.Enabled[5] := DebugAddr <> '';
      vMenu.Enabled[6] := DebugAddr <> '';
      vMenu.Enabled[7] := DebugAddr <> '';

      vMenu.Enabled[10] := DebugProcess <> '';
      vMenu.Enabled[11] := DebugProcess <> '';
      vMenu.Enabled[12] := DebugProcess <> '';


      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: OpenProcessDlg(GetCurrentFile);
        1: DebugCommand(StrIf(DebugAddr = '', 'run', 'continue'), True);
        2: DebugCommand(StrIf(DebugAddr = '', 'start', 'step'), True);
        3: DebugCommand(StrIf(DebugAddr = '', 'start', 'next'), True);
        4: RunToLine;
        5: DebugCommand('finish', True);
        6: DebugCommand('kill', False);
        7: LocateSource(True);
        8: {};
        9: EvaluateDlg;
       10: AddBreakpoint;
       11: FindAddrs;
       12: Disassemble;
       13: WindowsMenu;
       14: {};
       15: ShowConsoleDlg('');
       16: OptionsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  function GetMinFarVersionW :Integer; stdcall;
  begin
    { Need 2.0.789 }
    Result := $03150200;
  end;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    FARAPI := psi;
    FARSTD := psi.fsf^;

    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    hStdIn :=  GetStdHandle(STD_INPUT_HANDLE);

    FRegRoot := psi.RootKey;
    FModuleName := psi.ModuleName;

    RestoreDefColor;
    ReadSetup(True, True);
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;
    ConfigMenuStrings: array[0..0] of PFarChar;


  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := @PluginMenuStrings;

    ConfigMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginConfigStrings := Pointer(@ConfigMenuStrings);
    pi.PluginConfigStringsNumber := 1;

//  pi.Reserved := cPluginGUID;
    pi.CommandPrefix := cPlugMenuPrefix;
  end;


  procedure ExitFARW; stdcall;
  begin
    WriteSetup(True, False);
//  Trace('ExitFAR');
  end;


  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
    try
      ReadSetup(False, True);

      if OpenFrom = OPEN_COMMANDLINE then
        OpenCmdLine(FarChar2Str(PFarChar(Item)))
      else
      if OpenFrom in [OPEN_PLUGINSMENU, OPEN_EDITOR, OPEN_VIEWER, OPEN_DIALOG] then
        OpenMenu;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    Result := 1;
    try
      ReadSetup(False, True);

      OptionsMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {-----------------------------------------------------------------------------}

  type
    TEdtHelper = class(TBasis)
    public
      constructor CreateEx(AId :Integer);
      destructor Destroy; override;

      procedure AddBreakLine(ARow :Integer);
      procedure AddCodeLine(ARow :Integer);

      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FID     :Integer;
      FLine   :Integer;
      FBreaks :TIntList;
      FCodes  :TIntList;
    end;


  constructor TEdtHelper.CreateEx(AId :Integer);
  begin
    inherited Create;
    FId := AId;
    FLine := 0;
  end;


  destructor TEdtHelper.Destroy; {override;}
  begin
    FreeObj(FBreaks);
    FreeObj(FCodes);
    inherited Destroy;
  end;


  procedure TEdtHelper.AddBreakLine(ARow :Integer);
  begin
    if FBreaks = nil then
      FBreaks := TIntList.Create;
    FBreaks.Add(ARow);
  end;


  procedure TEdtHelper.AddCodeLine(ARow :Integer);
  begin
    if FCodes = nil then
      FCodes := TIntList.Create;
    FCodes.Add(ARow);
  end;


  function TEdtHelper.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := IntCompare(FID, TIntPtr(Key));
  end;


  var
    EdtHelpers :TObjList;


  function FindEdtHelper(AId :Integer; ACreate :Boolean) :TEdtHelper;
  var
    vIndex :Integer;
  begin
    Result := nil;
    if EdtHelpers.FindKey(Pointer(TIntPtr(AID)), 0, [foBinary], vIndex) then
      Result := EdtHelpers[vIndex]
    else if ACreate then begin
      Result := TEdtHelper.CreateEx(AID);
      EdtHelpers.Insert(vIndex, Result);
    end;
  end;


  procedure DeleteEdtHelper(AId :Integer);
  var
    vIndex :Integer;
  begin
    if EdtHelpers.FindKey(Pointer(TIntPtr(AID)), 0, [foBinary], vIndex) then
      EdtHelpers.FreeAt(vIndex);
  end;


  procedure EdtSetColor(ALine, AColor :Integer; AStart :Integer = 0; ALen :Integer = 256);
  var
    vColor :TEditorColor;
  begin
    vColor.StringNumber := ALine - 1;
    if AColor <> -1 then begin
      vColor.StartPos := AStart;
      vColor.EndPos := AStart + ALen - 1;
      vColor.Color := AColor or ECF_TAB1;
    end else
    begin
      vColor.StartPos := -1;
      vColor.EndPos := 0;
      vColor.Color := 0;
    end;
    FARAPI.EditorControl(ECTL_ADDCOLOR, @vColor);
  end;


  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  var
    I, vConflictIdx :Integer;
    vInfo :TEditorInfo;
    vSrcFile :TSourceFile;
    vFileName :TString;
    vHelper :TEdtHelper;
    vFileIsExec :Boolean;
  begin
    Result := 0;
//  TraceF('ProcessEditorEvent: %d', [AEvent]);

    case AEvent of
      EE_CLOSE:
        DeleteEdtHelper(Integer(AParam^));

      EE_REDRAW:
        begin
          FARAPI.EditorControl(ECTL_GETINFO, @vInfo);
          vFileName := EditorControlString(ECTL_GETFILENAME);
          vFileIsExec := StrEqual(vFileName, DebugFile);

          vHelper := FindEdtHelper(vInfo.EditorID, False);

          { Code marks }
          if (vHelper <> nil) and (vHelper.FCodes <> nil) then begin
            for I := 0 to vHelper.FCodes.Count - 1 do
              EdtSetColor(vHelper.FCodes[I], -1);
            vHelper.FCodes.Clear;
          end;

          if optShowCodeLine then begin
            vSrcFile := FindSrcWrapper(vFileName);
            if vSrcFile <> nil then begin
              vSrcFile.UpdateLineInfo(vInfo.TopScreenLine, vInfo.TopScreenLine + vInfo.WindowSizeY);

              for I := vInfo.TopScreenLine to vInfo.TopScreenLine + vInfo.WindowSizeY do
                if (I < vSrcFile.LineInfo.Count) and (PByte(vSrcFile.LineInfo.PItems[I])^ = 1) then begin
                  if vHelper = nil then
                    vHelper := FindEdtHelper(vInfo.EditorID, True);
                  EdtSetColor(I+1, optEdtCodeColor, 0, 0);
                  vHelper.AddCodeLine(I+1);
                end;
            end;
          end;

          { Breakpoints }
          if (vHelper <> nil) and (vHelper.FBreaks <> nil) then begin
            for I := 0 to vHelper.FBreaks.Count - 1 do
              EdtSetColor(vHelper.FBreaks[I], -1);
            vHelper.FBreaks.Clear;
          end;

          { Exec line }
          if (vHelper <> nil) and (vHelper.FLine <> 0) then begin
            EdtSetColor(vHelper.FLine, -1);
            vHelper.FLine := 0;
          end;

          vConflictIdx := -1;

          for I := 0 to Breakpoints.Count - 1 do
            with TBreakpoint(Breakpoints[I]) do
              if StrEqual(vFileName, FileName) then begin
                if vHelper = nil then
                  vHelper := FindEdtHelper(vInfo.EditorID, True);
                if vFileIsExec and (Line = DebugLine) then
                  vConflictIdx := I;
                EdtSetColor(Line, IntIf(Enabled, optEdtBreakColor, optEdtBreakColor1), 0, IntIf(vConflictIdx = I, 1, 255) );
                vHelper.AddBreakLine(Line);
              end;

          if vFileIsExec then begin
            if vHelper = nil then
              vHelper := FindEdtHelper(vInfo.EditorID, True);
            EdtSetColor(DebugLine, optEdtExecColor, IntIf(vConflictIdx = -1, 0, 1));
            vHelper.FLine := DebugLine;
          end;
        end;
    end;
  end;


(*
 {$ifdef bUnicodeFar}
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$else}
  function ProcessEditorEvent(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    I :Integer;
    vInfo :TEditorInfo;
    vFileName :TString;
    vHelper :TEdtHelper;
  begin
    Result := 0;
//  TraceF('ProcessEditorEvent: %d', [AEvent]);

    case AEvent of
      EE_CLOSE:
        DeleteEdtHelper(Integer(AParam^));

      EE_REDRAW:
        begin
          FARAPI.EditorControl(ECTL_GETINFO, @vInfo);
          vFileName := FarChar2Str(vInfo.FileName);

          vHelper := FindEdtHelper(vInfo.EditorID, False);

          { Breakpoints }
          if (vHelper <> nil) and (vHelper.FBreaks <> nil) then begin
            for I := 0 to vHelper.FBreaks.Count - 1 do
              EdtSetColor(vHelper.FBreaks[I], -1);
            vHelper.FBreaks.Clear;
          end;

          for I := 0 to Breakpoints.Count - 1 do
            with TBreakpoint(Breakpoints[I]) do
              if StrEqualEx(vFileName, FileName) then begin
                if vHelper = nil then
                  vHelper := FindEdtHelper(vInfo.EditorID, True);
                EdtSetColor(Line, IntIf(Enabled, optEdtBreakColor, optEdtBreakColor1));
                vHelper.AddBreakLine(Line);
              end;

          { Exec line }
          if (vHelper <> nil) and (vHelper.FLine <> 0) then begin
            EdtSetColor(vHelper.FLine, -1);
            vHelper.FLine := 0;
          end;

          if StrEqualEx(vFileName, DebugFile) then begin
            if vHelper = nil then
              vHelper := FindEdtHelper(vInfo.EditorID, True);
            EdtSetColor(DebugLine, optEdtExecColor);
            vHelper.FLine := DebugLine;
          end;
        end;
    end;
  end;
*)


initialization
  EdtHelpers := TObjList.Create;

finalization
  FreeObj(EdtHelpers);
end.


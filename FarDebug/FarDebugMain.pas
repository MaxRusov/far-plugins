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

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,

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
    FarDebugConsole;


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  procedure ExitFAR; stdcall;
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
  function ProcessEditorEvent(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$endif bUnicodeFar}

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

    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelInfo, @vInfo);
   {$endif bUnicodeFar}

    if (vInfo.PanelType = PTYPE_FILEPANEL) and ((vInfo.Plugin = 0) or (PFLAGS_REALNAMES and vInfo.Flags <> 0)) then begin
     {$ifdef bUnicodeFar}
      vFolder := FarPanelGetCurrentDirectory(INVALID_HANDLE_VALUE);
     {$else}
      vFolder := FarChar2Str(vInfo.CurDir);
     {$endif bUnicodeFar}

      vIndex := vInfo.CurrentItem;
      if (vIndex < 0) or (vIndex >= vInfo.ItemsNumber) then
        Exit;

     {$ifdef bUnicodeFar}
      vItem := FarPanelItem(INVALID_HANDLE_VALUE, FCTL_GETPANELITEM, vIndex);
      try
     {$else}
      vItem := @vInfo.PanelItems[vIndex];
     {$endif bUnicodeFar}

      if faDirectory and vItem.FindData.dwFileAttributes = 0 then
        Result := AddFileName(vFolder, FarChar2Str(vItem.FindData.cFileName));

     {$ifdef bUnicodeFar}
      finally
        MemFree(vItem);
      end;
     {$endif bUnicodeFar}
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

      LoadModule(vStr, vPtr);
    end;
  end;


  procedure WindowsMenu;
  const
    cMenuCount = 3;
  var
    vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strMCallstack));
      SetMenuItemChrEx(vItem, GetMsg(strMBreakpoints));
      SetMenuItemChrEx(vItem, GetMsg(strMSources));

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        'Far Debug',
        '',
        'MainMenu',
        nil, nil,
        Pointer(vItems),
        cMenuCount);

      if vRes = -1 then
        Exit;

      case vRes of
        0: CallstackDlg;
        1: BreakpointesDlg;
        2: SourcesDlg;
      end;

    finally
      MemFree(vItems);
    end;
  end;


  procedure OpenMenu;
  const
    cMenuCount = 15;
  var
    vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strMStart));
      SetMenuItemChrEx(vItem, GetMsg(strMStep));
      SetMenuItemChrEx(vItem, GetMsg(strMNext));
//    SetMenuItemChrEx(vItem, '&U Next Line');
      SetMenuItemChrEx(vItem, GetMsg(strMUntil));
      SetMenuItemChrEx(vItem, GetMsg(strMRun));
      SetMenuItemChrEx(vItem, GetMsg(strMKill));
      SetMenuItemChrEx(vItem, GetMsg(strMLocate));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strMEvaluate));
      SetMenuItemChrEx(vItem, GetMsg(strMAddBreakpoit));
      SetMenuItemChrEx(vItem, GetMsg(strMFindAddress));
      SetMenuItemChrEx(vItem, GetMsg(strMDisassemble));
      SetMenuItemChrEx(vItem, GetMsg(strMWindows));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strMDebugConsole));

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        'Far Debug',
        '',
        'MainMenu',
        nil, nil,
        Pointer(vItems),
        cMenuCount);

      if vRes = -1 then
        Exit;

      case vRes of
        0: OpenProcessDlg(GetCurrentFile);
        1: DebugCommand(StrIf(DebugAddr = '', 'start', 'step'), True);
        2: DebugCommand(StrIf(DebugAddr = '', 'start', 'next'), True);
        3: RunToLine;
        4: DebugCommand(StrIf(DebugAddr = '', 'run', 'continue'), True);
        5: DebugCommand('kill', False);
        6: LocateSource(True);
        7: {};
        8: EvaluateDlg;
        9: AddBreakpoint;
       10: FindAddrs;
       11: {$ifdef bDebug}Disassemble;{$else}DisassembleCurrentLine;{$endif bDebug}
       12: WindowsMenu;
       13: {};
       14: ShowConsoleDlg('')
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
    { Need 2.0.789 }
    Result := $03150200;
  end;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

    hFarWindow := FARAPI.AdvControl(hModule, ACTL_GETFARHWND, nil);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;

(*  ReadSetup;  *)
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;


 {$ifdef bUnicodeFar}
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
 {$else}
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := @PluginMenuStrings;
    pi.CommandPrefix := cPlugMenuPrefix;
  end;


 {$ifdef bUnicodeFar}
  procedure ExitFARW; stdcall;
 {$else}
  procedure ExitFAR; stdcall;
 {$endif bUnicodeFar}
  begin
//  Trace('ExitFAR');
  end;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}
  begin
    Result:= INVALID_HANDLE_VALUE;
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
    try
     {$ifndef bUnicodeFar}
      SetFileApisToAnsi;
     {$endif bUnicodeFar}
      try
        ReadSetup;

        if OpenFrom = OPEN_COMMANDLINE then
          OpenCmdLine(FarChar2Str(PFarChar(Item)))
        else
        if OpenFrom in [OPEN_PLUGINSMENU, OPEN_EDITOR, OPEN_VIEWER, OPEN_DIALOG] then
          OpenMenu;

      finally
       {$ifndef bUnicodeFar}
        SetFileApisToOEM;
       {$endif bUnicodeFar}
      end;

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

      function CompareKey(Key :Pointer; Context :Integer) :Integer; override;

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


  function TEdtHelper.CompareKey(Key :Pointer; Context :Integer) :Integer; {override;}
  begin
    Result := IntCompare(FID, Integer(Key));
  end;


  var
    EdtHelpers :TObjList;


  function FindEdtHelper(AId :Integer; ACreate :Boolean) :TEdtHelper;
  var
    vIndex :Integer;
  begin
    Result := nil;
    if EdtHelpers.FindKey(Pointer(AID), 0, [foBinary], vIndex) then
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
    if EdtHelpers.FindKey(Pointer(AID), 0, [foBinary], vIndex) then
      EdtHelpers.FreeAt(vIndex);
  end;


  procedure EdtSetColor(ALine, AColor :Integer; ALen :Integer = 256);
  var
    vColor :TEditorColor;
  begin
    vColor.StringNumber := ALine - 1;
    if AColor <> -1 then begin
      vColor.StartPos := 0;
      vColor.EndPos := ALen;
      vColor.Color := AColor or ECF_TAB1;
    end else
    begin
      vColor.StartPos := -1;
      vColor.EndPos := 0;
      vColor.Color := 0;
    end;
    FARAPI.EditorControl(ECTL_ADDCOLOR, @vColor);
  end;



 {$ifdef bUnicodeFar}
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$else}
  function ProcessEditorEvent(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    I :Integer;
    vInfo :TEditorInfo;
    vSrcFile :TSourceFile;
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
         {$ifdef bUnicodeFar}
          vFileName := EditorControlString(ECTL_GETFILENAME);
         {$else}
          vFileName := FarChar2Str(vInfo.FileName);
         {$endif bUnicodeFar}

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
                  EdtSetColor(I+1, optEdtCodeColor, 0);
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

          for I := 0 to Breakpoints.Count - 1 do
            with TBreakpoint(Breakpoints[I]) do
              if StrEqual(vFileName, FileName) then begin
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

          if StrEqual(vFileName, DebugFile) then begin
            if vHelper = nil then
              vHelper := FindEdtHelper(vInfo.EditorID, True);
            EdtSetColor(DebugLine, optEdtExecColor);
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


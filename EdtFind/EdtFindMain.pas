{$I Defines.inc}

unit EdtFindMain;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Editor Find Shell                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,

    Far_API,
    FarCtrl,
    FarPlug,
    FarMenu,

    EdtFindCtrl,
    EdtFindDlg,
   {$ifdef bFileFind}
    EdtFileFindDlg,
   {$endif bFileFind}
    EdtFindEditor;


  type
    TEdtFindPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
      procedure ErrorHandler(E :Exception); override;
     {$ifdef bAdvSelect}
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      function EditorInput(const ARec :TInputRecord) :Integer; override;
     {$endif bAdvSelect}
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {$ifdef bFileFind}
  procedure FileFind;
(*
  var
    vMode :TFindMode;
*)
  begin
    if not FileFindDlg then
      Exit;

(*
    gLastOpt := gOptions;
    gLastIsReplace := False;
    FindStr(gStrFind, gLastOpt, vMode = efmEntire, False, not gReverse);
*)
  end;
 {$endif bFileFind}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure RunCommand(ACmd :Integer);
  begin
    case ACmd of
      1: Find(False);
      2: Find(True);
      3: Replace(False);
      4: Replace(True);
      5: RepeatLast(True);
      6: RepeatLast(False);
      7: PickWord;
     {$ifdef bAdvSelect}
      8: EdtClearMark;
     {$endif bAdvSelect}
    end;
  end;


  procedure EdtOpenMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMFind),
      GetMsg(strMFindAt),
      GetMsg(strMReplace),
      GetMsg(strMReplaceAt),
      GetMsg(strMFindNext),
      GetMsg(strMFindPrev),
      GetMsg(strMFindPickWord),
      GetMsg(strMRemoveHilight),
      '',
      GetMsg(strMOptions)
    ]);
    try
      vMenu.Enabled[7] := (gMatchStr <> ''); // or (gEdtMess <> '');

      vMenu.Help := 'MainMenu';
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0..7:
          RunCommand(vMenu.ResIdx + 1);
        9: OptionsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {$ifdef bFileFind}
  procedure ShellOpenMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMFind),
      '',
      GetMsg(strMOptions)
    ]);
    try
//    vMenu.Help := 'MainMenu';

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: FileFind;
        2: OptionsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;
 {$endif bFileFind}

  
 {-----------------------------------------------------------------------------}

  procedure SkipSpaces(var AStr :PTChar);
  begin
    while (AStr^ = ' ') or (AStr^ = #9) do
      Inc(AStr);
  end;


  function ExtractNextKey(var AStr :PTChar) :TString;
  var
    vBeg :PTChar;
  begin
    SkipSpaces(AStr);
    vBeg := AStr;
    while (AStr^ <> #0) and CharIsWordChar(AStr^) do
      Inc(AStr);
    Result := Chr2StrL(vBeg, AStr - vBeg);
  end;

  function ExtractNextItem(var AStr :PTChar) :TString;
  begin
    if AStr^ = '"' then
      Result := AnsiExtractQuotedStr(AStr, '"')
    else
      Result := ExtractNextValue(AStr, [' ']);
  end;


  function ParseCommand(ACmd :PTChar) :Boolean;
  var
    vKey, vVal, vFindStr, vRepStr :TString;
    vAction :Integer;
    vOpt :TFindOptions;
    vEntire, vReverse :Boolean;
    vErrorMode, vHighlightMode, vLoopMode :Integer;
  begin
    Result := False;

    if ACmd <> nil then
      SkipSpaces(ACmd);
    if (ACmd = nil) or (ACmd^ = #0) then begin
      { Возможно - проверка наличия плагина }
      Result := True;
      Exit;
    end;

    vAction := 0;
    vOpt := [foPromptOnReplace];
    vEntire := False;
    vReverse := False;
    vLoopMode := -1;
    vHighlightMode := -1;
    vErrorMode := -1;

    while (ACmd <> nil) and (ACmd^ <> #0) do begin
      vKey := ExtractNextKey(ACmd);
      SkipSpaces(ACmd);
      if ACmd^ = ':' then begin
        Inc(ACmd);
        SkipSpaces(ACmd);
        vVal := ExtractNextItem(ACmd);
      end else
      begin
        vVal := ACmd;
        ACmd := nil;
      end;

      if StrEqual(vKey, 'Find') then begin
        vFindStr := vVal;
        vAction := IntIf(vAction <> 5, 1, vAction);
      end else
      if StrEqual(vKey, 'Grep') then begin
        vFindStr := vVal;
        vAction := 2;
      end else
      if StrEqual(vKey, 'Count') then begin
        vFindStr := vVal;
        vAction := 3;
      end else
      if StrEqual(vKey, 'Mark') then begin
        vFindStr := vVal;
        vAction := 4;
      end else
      if StrEqual(vKey, 'Replace') then begin
        vRepStr := vVal;
        vAction := 5;
      end else
      if StrEqual(vKey, 'Set') then begin
        vFindStr := vVal;
        vAction := 6;
      end else
      if StrEqual(vKey, 'WholeWords') then
        SetFindOptions(vOpt, foWholeWords, vVal = '1')
      else
      if StrEqual(vKey, 'RegExp') then
        SetFindOptions(vOpt, foRegexp, vVal = '1')
      else
      if StrEqual(vKey, 'CaseSensitive') then
        SetFindOptions(vOpt, foCaseSensitive, vVal = '1')
      else
      if StrEqual(vKey, 'Prompt') then
        SetFindOptions(vOpt, foPromptOnReplace, vVal = '1')
      else
      if StrEqual(vKey, 'Entire') then
        vEntire := vVal = '1'
      else
      if StrEqual(vKey, 'Reverse') then
        vReverse := vVal = '1'
      else
      if StrEqual(vKey, 'Loop') then
        vLoopMode := Str2IntDef(vVal, -1)
      else
      if StrEqual(vKey, 'Highlight') then
        vHighlightMode := Str2IntDef(vVal, -1)
      else
      if StrEqual(vKey, 'Error') then
        vErrorMode := Str2IntDef(vVal, -1)
      else
        Exit;
    end;

   {$ifdef bAdvSelect}
    EdtClearMark;
   {$endif bAdvSelect}
    if vFindStr <> '' then begin
      gStrFind := vFindStr;
      gLastOpt := vOpt;
      gLastIsReplace := False;

      Result := True;
      try
        case vAction of
          1:
            Result := FindStr(vFindStr, vOpt, vEntire, False, not vReverse,
              vLoopMode, vHighlightMode, vErrorMode);
          2:
            GrepStr(vFindStr, vOpt);
          3:
            CountStr(vFindStr, vOpt);
          4:
            HighlightStr(vFindStr, vOpt);
          5:
            Result := ReplaceStr(vFindStr, vRepStr, vOpt, vEntire, False, not vReverse,
              vLoopMode, vHighlightMode, vErrorMode);
          6:
            {Nothing};
        end;

      except
        on E :ECtrlBreak do
          Result := False;
        on E :Exception do begin
          Result := False;
          if vErrorMode <> 0 then
            HandleError(E);
        end;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TEdtFindPlug                                                                }
 {-----------------------------------------------------------------------------}

  procedure TEdtFindPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
    FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
//  FMinFarVer := MakeVersion(3, 0, 2460);   { OPEN_FROMMACRO }
//  FMinFarVer := MakeVersion(3, 0, 2572);   { Api changes }
    FMinFarVer := MakeVersion(3, 0, 2851);   { LUA }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1800);   { OPEN_FROMMACROSTRING }
   {$endif Far3}
  end;


  procedure TEdtFindPlug.Startup; {override;}
  begin
//  hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    RestoreDefColor;
    ReadSetup;

    gLastOpt := gOptions;
  end;


  procedure TEdtFindPlug.ExitFar; {override;}
  begin
    {???}
    WriteSetup;
  end;


  procedure TEdtFindPlug.GetInfo; {override;}
  begin
    FFlags := PF_EDITOR {or PF_VIEWER or PF_DIALOG}
     {$ifdef bFileFind}
     {$else}
      or PF_DISABLEPANELS
     {$endif bFileFind}
    ;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID  := cConfigID;
   {$endif Far3}
  end;


  function TEdtFindPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    case AFrom of
      OPEN_EDITOR:
        EdtOpenMenu;
     {$ifdef bFileFind}
      OPEN_PLUGINSMENU:
        ShellOpenMenu
     {$endif bFileFind}
    else
      Beep;
    end;
  end;


  function TEdtFindPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {override;}
  var
    vArea :Integer;
  begin
    Result := INVALID_HANDLE_VALUE;
    vArea := FarGetMacroArea;
    if (AInt = 0) and (AStr = nil) then begin
      case vArea of
        MACROAREA_EDITOR:
          EdtOpenMenu;
       {$ifdef bFileFind}
        MACROAREA_SHELL, MACROAREA_INFOPANEL, MACROAREA_TREEPANEL, MACROAREA_QVIEWPANEL, MACROAREA_SEARCH{, MACROAREA_SHELLAUTOCOMPLETION}:
          ShellOpenMenu
       {$endif bFileFind}
      else
        Beep;
      end;
    end else
    begin

      if AStr <> nil then
        Result := HandleIf(ParseCommand(AStr), INVALID_HANDLE_VALUE, 0)
      else begin
        if AInt <= 4 then
          FarAdvControl(ACTL_SYNCHRO, Pointer(AInt))
        else
          RunCommand(AInt);
      end;
(*
      case vArea of
        MACROAREA_EDITOR:
          if AStr <> nil then
            Result := HandleIf(ParseCommand(AStr), INVALID_HANDLE_VALUE, 0)
          else begin
            if AInt <= 4 then
              FarAdvControl(ACTL_SYNCHRO, Pointer(AInt))
            else
              RunCommand(AInt);
          end;
       {$ifdef bFileFind}
        MACROAREA_SHELL, MACROAREA_INFOPANEL, MACROAREA_TREEPANEL, MACROAREA_QVIEWPANEL, MACROAREA_SEARCH{, MACROAREA_SHELLAUTOCOMPLETION}:
          Sorry;
       {$endif bFileFind}
      else
        Beep;
      end;
*)
    end;
  end;


  procedure TEdtFindPlug.SynchroEvent(AParam :Pointer); {override;}
  begin
    RunCommand(TIntPtr(AParam));
  end;


  procedure TEdtFindPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  procedure TEdtFindPlug.ErrorHandler(E :Exception); {override;}
  begin
    if E is ECtrlBreak then
      {Nothing}
    else
      HandleError(E);
  end;


 {$ifdef bAdvSelect}

  function TEdtFindPlug.EditorInput(const ARec :TInputRecord) :Integer; {override;}
  begin
    if ARec.EventType = KEY_EVENT then begin
      with ARec.Event.KeyEvent do begin
        if bKeyDown and not (wVirtualKeyCode in [0, VK_SHIFT, VK_CONTROL, VK_MENU]) then begin
//        TraceF('ProcessEditorInputW (KEY_EVENT): Press=%d, Key=%d', [Byte(bKeyDown), wVirtualKeyCode]);
          EdtClearMark(not optPersistMatch);
        end;
      end;
    end else
    if ARec.EventType = _MOUSE_EVENT then begin
      with ARec.Event.MouseEvent do
        if MOUSE_MOVED and dwEventFlags = 0 then begin
//        TraceF('ProcessEditorInputW (MOUSE_EVENT): Flags=%d', [dwEventFlags]);
          EdtClearMark(not optPersistMatch);
        end
    end;
    Result := 0;
  end;

  
  function TEdtFindPlug.EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  begin
    Result := 0;

    case AEvent of
     {$ifdef Far3}
      EE_READ:
        FarEditorSubscribeChangeEvent(-1{AID}, True);
     {$endif Far3}

      EE_CLOSE: begin
        EdtClearMark(True, False);
        DeleteEdtHelper(AID);
      end;

      EE_KILLFOCUS:
        EdtClearMark;

     {$ifdef Far3}
      EE_CHANGE:
        begin
//        TraceF('ProcessEditorEventW: Change', []);
          RefreshEdtMatches;
        end;
     {$endif Far3}

      EE_REDRAW:
        begin
//        TraceF('ProcessEditorEventW: Redraw', []);

         {$ifdef Far3}
         {$else}
          if AParam = EEREDRAW_LINE then
            Exit;
          if AParam = EEREDRAW_CHANGE then begin
//          EdtClearMark({ClearMatches=}True, {Redraw=}False);  { Сбросить }
            RefreshEdtMatches;  { Поддерживать }
          end;
         {$endif Far3}

          UpdateEdtMatches;
        end;
    end;
  end;

 {$endif bAdvSelect}


end.

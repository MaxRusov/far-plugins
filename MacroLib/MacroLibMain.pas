{$I Defines.inc}

unit MacroLibMain;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Macro Library                                                          *}
{******************************************************************************}

{
Ready
  +Приоритеты

ToDo:
  -Иногда срабатывает Realses после Hold (если shift отпустили первым)

  - Срабатывание по символьным клавишам
  - Мароподстановка #AKeyName

  +Настройка тайм-аутов
    - Через диалог настроек
  -Диалоги в меню плагинов
}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMenu,
    FarPlug,

    MacroLibConst,
    MacroLibClasses,
    MacroParser,
    MacroListDlg;

  type
    TMacroLibPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenMacro(ACount :Integer; AParams :PFarMacroValueArray) :THandle; override;
      procedure SynchroEvent(AParam :Pointer); override;
      function DialogEvent(AEvent :Integer; AParam :PFarDialogEvent) :Integer; override;
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
      function ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;
     {$ifdef bUseProcessConsoleInput}
      function ConsoleInput(const ARec :TInputRecord) :Integer; override;
     {$endif bUseProcessConsoleInput}
    end;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { Injecting Support                                                           }
 {-----------------------------------------------------------------------------}

 {$ifdef bUseInject}

  const
    ImagehlpLib = 'IMAGEHLP.DLL';

  function ImageDirectoryEntryToData(Base :Pointer; MappedAsImage :ByteBool;
    DirectoryEntry :Word; var Size: ULONG): Pointer; stdcall; external ImagehlpLib name 'ImageDirectoryEntryToData';


  function FindImport(AHandle :THandle; ADllName :PAnsiChar) :PIMAGE_IMPORT_DESCRIPTOR;
  var
    vImport :PIMAGE_IMPORT_DESCRIPTOR;
    vName :PAnsiChar;
    vSize :ULONG;
  begin
    Result := nil;
    vImport := ImageDirectoryEntryToData(Pointer(AHandle), True, IMAGE_DIRECTORY_ENTRY_IMPORT, vSize);
    if vImport <> nil then begin
      while vImport.OriginalFirstThunk <> 0 do begin
        vName := PAnsiChar(AHandle + vImport.Name);
        if lstrcmpiA(vName, ADllName) = 0 then begin
          Result := vImport;
          Exit;
        end;
        Inc(vImport);
      end;
    end;
  end;


  function InjectFunc(AFuncPtr :PPointer; ANewFunc :Pointer) :Pointer;
  var
    vMem :MEMORY_BASIC_INFORMATION;
    vTmp :DWORD;
  begin
    VirtualQuery(AFuncPtr, vMem, SizeOf(MEMORY_BASIC_INFORMATION));
    VirtualProtect(vMem.BaseAddress, vMem.RegionSize, PAGE_READWRITE, @vTmp);
    Result := AFuncPtr^;
    AFuncPtr^ := ANewFunc;
    VirtualProtect(vMem.BaseAddress, vMem.RegionSize, vTmp, @vTmp);
  end;


  function InjectHandler(AHandle :THandle; AImport :PIMAGE_IMPORT_DESCRIPTOR; AFuncName :PAnsiChar; var AFuncPtr :PPointer; var AOldFunc :Pointer; ANewFunc :Pointer) :Boolean;
  var
    vThunk, vThunk2 :PIMAGE_THUNK_DATA;
    vName :PAnsiChar;
  begin
    Result := False;

    vThunk := Pointer(AHandle + AImport.FirstThunk);
    vThunk2 := Pointer(AHandle + AImport.OriginalFirstThunk);

    while vThunk._Function <> 0 do begin
      vName := Pointer(AHandle + vThunk2.AddressOfData + 2);
      if lstrcmpiA(vName, AFuncName) = 0 then
        Break;
      Inc(vThunk);
      Inc(vThunk2);
    end;

    if vThunk._Function <> 0 then begin
//    TraceF('Injected: %s', [AFuncName]);
      AFuncPtr := @Pointer(vThunk._Function);
      AOldFunc := InjectFunc(AFuncPtr, ANewFunc);
      Result := True;
    end;
  end;


  procedure RemoveHandler(var AFuncPtr :PPointer; AOldFunc :Pointer; ANewFunc :Pointer);
  begin
    if (AFuncPtr <> nil) {and (AFuncPtr^ = ANewFunc)} then begin
//    TraceF('RemoveHandlers... Old=%p', [AOldFunc]);
      InjectFunc(AFuncPtr, AOldFunc);
      AFuncPtr := nil;
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
//  OldPeekConsoleInputW :function(hConsoleInput :THandle; var lpBuffer: TInputRecord;
//    nLength :DWORD; var lpNumberOfEventsRead :DWORD): BOOL; stdcall;

    OldReadConsoleInputW :function(hConsoleInput :THandle; var lpBuffer: TInputRecord;
      nLength :DWORD; var lpNumberOfEventsRead :DWORD): BOOL; stdcall;
//  PeekConsoleInputPtr :PPointer;
    ReadConsoleInputPtr :PPointer;


  procedure ClearKeyEvent(var ARec :TKeyEventRecord);
  begin
    { Нажатие не будет обработано FAR'ом }
    ARec.wVirtualKeyCode := 0 {VK_NONAME};
    ARec.wVirtualScanCode := 0;
    ARec.dwControlKeyState := 0;
    ARec.UnicodeChar := #0;
    ARec.wRepeatCount := 0;
  end;

  procedure ClearMouseEvent(var ARec :TMouseEventRecord);
  begin
    { Событие не будет обработано FAR'ом }
    ARec.dwEventFlags := 0;
    ARec.dwButtonState := 0;
    ARec.dwControlKeyState := 0;
    ARec.dwMousePosition.X := 0;
    ARec.dwMousePosition.Y := 0;
  end;

(*
  function MyPeekConsoleInputW(hConsoleInput :THandle; var lpBuffer: TInputRecord;
    nLength :DWORD; var lpNumberOfEventsRead :DWORD): BOOL; stdcall;
  var
    I :Integer;
    P :PInputRecord;
  begin
    Result := OldPeekConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead);
    if Result and (lpNumberOfEventsRead > 0) and opt_ProcessHotkey then begin
//    TraceF('MyPeekConsoleInputW (Events=%d)', [lpNumberOfEventsRead]);
      P := @lpBuffer;
      for I := 0 to lpNumberOfEventsRead - 1 do begin
        if P.EventType = KEY_EVENT then begin
          if MacroLibrary.CheckHotkey(P.Event.KeyEvent, False) then
            ClearKeyEvent(P.Event.KeyEvent);
        end;
        Inc(Pointer1(P), SizeOf(TInputRecord));
      end;
    end;
  end;
*)

  function MyReadConsoleInputW(hConsoleInput :THandle; var lpBuffer: TInputRecord;
    nLength :DWORD; var lpNumberOfEventsRead :DWORD): BOOL; stdcall;
  var
    I :Integer;
    P :PInputRecord;
  begin
    Result := OldReadConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead);
    if Result and (lpNumberOfEventsRead > 0) then begin
//    TraceF('MyReadConsoleInputW (Events=%d)', [lpNumberOfEventsRead]);

      P := @lpBuffer;
      for I := 0 to lpNumberOfEventsRead - 1 do begin
        if (P.EventType = KEY_EVENT) and optProcessHotkey and (FarGetMacroState = MACROSTATE_NOMACRO) then begin
          if MacroLibrary.CheckHotkey(P.Event.KeyEvent) then
            ClearKeyEvent(P.Event.KeyEvent);
        end else
        if (P.EventType = _MOUSE_EVENT) and optProcessMouse and (FarGetMacroState = MACROSTATE_NOMACRO) then begin
          if MacroLibrary.CheckMouse(P.Event.MouseEvent) then
            ClearMouseEvent(P.Event.MouseEvent);
        end;
        Inc(Pointer1(P), SizeOf(TInputRecord));
      end;
    end;
  end;


  procedure InjectHandlers;
  var
    vHandle :THandle;
    vImport :PIMAGE_IMPORT_DESCRIPTOR;
  begin
    vHandle := GetModuleHandle(nil);
    vImport := FindImport(vHandle, kernel32);
    if vImport <> nil then begin
      InjectHandler(vHandle, vImport, 'ReadConsoleInputW', ReadConsoleInputPtr, @OldReadConsoleInputW, @MyReadConsoleInputW);
//    InjectHandler(vHandle, vImport, 'PeekConsoleInputW', PeekConsoleInputPtr, @OldPeekConsoleInputW, @MyPeekConsoleInputW);
    end;
  end;


  procedure RemoveHandlers;
  begin
    RemoveHandler(ReadConsoleInputPtr, @OldReadConsoleInputW, @MyReadConsoleInputW);
//  RemoveHandler(PeekConsoleInputPtr, @OldPeekConsoleInputW, @MyPeekConsoleInputW);
  end;
 {$endif bUseInject}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMProcessHotkeys),
      GetMsg(strMProcessMouse),
      GetMsg(strMMacroPaths)
     {$ifdef bUseInject}
      ,GetMsg(strMUseInjecting)
     {$endif bUseInject}
    ]);
    try
      vMenu.Help := 'Options';

      while True do begin
        vMenu.Checked[0] := optProcessHotkey;
        vMenu.Checked[1] := optProcessMouse;
       {$ifdef bUseInject}
        vMenu.Checked[3] := optUseInject;
       {$endif bUseInject}

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOption(optProcessHotkey);
          1 : ToggleOption(optProcessMouse);
          2 :
            if FarInputBox(GetMsg(strMacroPathsTitle), GetMsg(strMacroPathsPrompt), optMacroPaths, FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY, cMacroPathName) then begin
              PluginConfig(True);
              MacroLibrary.RescanMacroses(True);
            end;
         {$ifdef bUseInject}
          3 : ToggleOption(optUseInject);
         {$endif bUseInject}
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure MainMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMMacroCommands),
      '',
      GetMsg(strMListOfAllMacroses),
      GetMsg(strMUpdateMacroses),
      '',
      GetMsg(strMOptions)
    ]);
    try
      vMenu.Help := 'MainMenu';

      if MacroLock > 0 then
        vMenu.Items[3].Flags := vMenu.Items[3].Flags or MIF_DISABLE;

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : FarAdvControl(ACTL_SYNCHRO, nil); //MacroLibrary.ShowAvailable;

        2 : MacroLibrary.ShowAll;
        3 : MacroLibrary.RescanMacroses(False);

        5 : OptionsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  const
    kwCall  = 1;
    kwKey   = 2;

  var
    CmdWords :TKeywordsList;

  procedure InitKeywords;
  begin
    if CmdWords <> nil then
      Exit;

    CmdWords := TKeywordsList.Create;
    with CmdWords do begin
      Add('Call', kwCall);
      Add('Key', kwKey);
    end;
  end;


  procedure CmdCall(const AName :TString);
  var
    vMacro :TMacro;
  begin
//  TraceF('Run: %s', [AName]);
    if AName = '' then
      AppErrorId(strMacroNotSpec);

    vMacro := MacroLibrary.FindMacroByName(AName);
    if vMacro = nil then
      AppErrorIdFmt(strMacroNotFound, [AName]);

    vMacro.Execute(0);
  end;


  procedure CmdKey(const AName :TString);
  var
    vList :TExList;
    vKey :Integer;
    vMod :TKeyModifier;
    vArea :TMacroArea;
    vPress :TKeyPress;
    vEat :Boolean;
  begin
//  TraceF('Run: %s', [AName]);
    if AName = '' then
      AppErrorId(strKeyNotSpec);

    if not KeyNameParse(PTChar(AName), vKey, vMod) then
      AppErrorIdFmt(strUnknownKeyName, [AName]);

    vList := TExList.Create;
    try
      vArea := TMacroArea(FarGetMacroArea);

      vPress := kpAll;
      case vMod of
        kmSingle  : vPress := kpDown;
        kmDouble  : vPress := kpDouble;
        kmHold    : vPress := kpHold;
        kmRelease : vPress := kpUp;
      end;

      MacroLibrary.FindMacroses(vList, vArea, vKey, vPress, vEat);

      if vList.Count > 0 then begin
        if vList.Count = 1 then
          TMacro(vList[0]).Execute(vKey)
        else
          MacroLibrary.ShowList(vList);
      end;
      
    finally
      FreeObj(vList);
    end;
  end;


  procedure OpenCmdLine(AChr :PTChar);
  var
    vStr :TString;
    vKey :Integer;
  begin
    if (AChr = nil) or (AChr^ = #0) then
      MacroLibrary.ShowAll
    else begin
      InitKeywords;
      while AChr^ <> #0 do begin
        vStr := ExtractParamStr(AChr);
        vKey := CmdWords.GetKeywordStr(vStr);
        case vKey of
          kwCall: CmdCall(ExtractParamStr(AChr));
          kwKey:  CmdKey(ExtractParamStr(AChr));
        else
          AppErrorFmt('Unknown command: %s', [vStr]);
        end;
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TMoreHistoryPlug                                                            }
 {-----------------------------------------------------------------------------}

  procedure TMacroLibPlug.Init; {override;}
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
//  FMinFarVer := MakeVersion(3, 0, 2376);   { MCTL_GETLASTERROR };
//  FMinFarVer := MakeVersion(3, 0, 2379);   { MCTL_GETLASTERROR - исправление ошибки };
//  FMinFarVer := MakeVersion(3, 0, 2380);   { MacroAddMacro - изменена (fuck!) };
    FMinFarVer := MakeVersion(3, 0, 2460);   { OPEN_FROMMACRO }
   {$else}
//  FMinFarVer := MakeVersion(2, 0, 1765);   { MCMD_GETAREA };
    FMinFarVer := MakeVersion(2, 0, 1800);   { OPEN_FROMMACROSTRING, MCMD_POSTMACROSTRING };
   {$endif Far3}
  end;


  procedure TMacroLibPlug.Startup; {override;}
  begin
    FFarExePath := AddBackSlash(ExtractFilePath(GetExeModuleFileName));

    RestoreDefColor;
    PluginConfig(False);

    MacroLibrary := TMacroLibrary.Create;

   {$ifdef bUseInject}
    if optUseInject then
      InjectHandlers;
   {$endif bUseInject}

//  MacroLibrary.RescanMacroses(True);
//  MacroLibrary.CheckEvent(maShell, meOpen);

    FarAdvControl(ACTL_SYNCHRO, TRunEvent.CreateEx(meOpen, maShell));
  end;


  procedure TMacroLibPlug.ExitFar; {override;}
  begin
   {$ifdef bUseInject}
    RemoveHandlers;
   {$endif bUseInject}
    FreeObj(MacroLibrary);
  end;


  procedure TMacroLibPlug.GetInfo; {override;}
  begin
    FFlags:= PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    if optCmdPrefix <> '' then
      FPrefix := PTChar(optCmdPrefix);
  end;


  procedure TMacroLibPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  function TMacroLibPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;

    if AFrom = OPEN_COMMANDLINE then
      OpenCmdLine(PTChar(AParam))
    else
      MainMenu;
  end;


  function TMacroLibPlug.OpenMacro(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;
    if ACount = 0 then
      MainMenu
    else begin
      with AParams[0] do
        if fType = FMVT_STRING then
          OpenCmdLine(Value.fString)
        else
          FarAdvControl(ACTL_SYNCHRO, nil);
    end;
  end;


  procedure TMacroLibPlug.SynchroEvent(AParam :Pointer); {override;}
  var
    I :Integer;
    vObj :TObject;
  begin
    if MacroLibrary = nil then
      Exit;

    vObj := AParam;
    if vObj = nil then
      MacroLibrary.ShowAvailable
    else
    if vObj is TMacro then
      TMacro(vObj).Execute(0)
    else
    if (vObj is TRunList) and ((TRunList(vObj).Count = 1) or TRunList(vObj).RunAll) then begin
      with TRunList(vObj) do
        for I := 0 to Count - 1 do
          TMacro(Items[I]).Execute(KeyCode);
      FreeObj(vObj);
    end else
    if vObj is TExList then begin
      MacroLibrary.ShowList(TExList(vObj));
      FreeObj(vObj);
    end else
    if vObj is TRunEvent then begin
      with TRunEvent(vObj) do begin

        if Area = maShell then
          { Вынужденно перенес инициализацию макросов на данный этап. }
          { Если вызывать MCTL_ADDMACRO из процедур инициализации - Far падает }
          MacroLibrary.RescanMacroses(True);

        if FarGetMacroState = MACROSTATE_NOMACRO then
          MacroLibrary.CheckEvent(Area, Event);
      end;
      FreeObj(vObj);
    end;
  end;


 {$ifdef bUseProcessConsoleInput}
  function TMacroLibPlug.ConsoleInput(const ARec :TInputRecord) :Integer; {override;}
  begin
    Result := 0;
    if MacroLibrary = nil then
      Exit;
   {$ifdef bUseInject}
    if ReadConsoleInputPtr <> nil then
      Exit;
   {$endif bUseInject}

//  if AInfo.Flags and PCIF_FROMMAIN <> 0 then begin
      if (ARec.EventType = KEY_EVENT) and optProcessHotkey and (FarGetMacroState = MACROSTATE_NOMACRO) then begin
        if MacroLibrary.CheckHotkey(ARec.Event.KeyEvent) then
          Result := 1;
      end else
      if (ARec.EventType = _MOUSE_EVENT) and optProcessMouse and (FarGetMacroState = MACROSTATE_NOMACRO) then begin
        if MacroLibrary.CheckMouse(ARec.Event.MouseEvent) then
          Result := 1;
      end;
//  end;
  end;
 {$endif bUseProcessConsoleInput}


  function TMacroLibPlug.DialogEvent(AEvent :Integer; AParam :PFarDialogEvent) :Integer; {override;}
  begin
    if (AEvent = DE_DLGPROCEND) and (AParam.Msg = DN_INITDIALOG) then
      FarAdvControl(ACTL_SYNCHRO, TRunEvent.CreateEx(meOpen, maDialog));

   {$ifdef Far3}
   {$else}
    { Весь этот геморрой нужен в Far2, чтобы получить Handle диалога, }
    { который используется для получения GUID }
    if AEvent = DE_DLGPROCEND then
      if AParam.Msg = DN_INITDIALOG then begin
//      TraceF('InitDialog: %d', [AParam.hDlg]);
        PushDlg(AParam.hDlg);
      end else
      if (AParam.Msg = DN_CLOSE) and (AParam.Result <> 0) then begin
//      TraceF('CloseDialog: %d', [AParam.hDlg]);
        PopDlg(AParam.hDlg);
      end;
   {$endif Far3}

    Result := 0;
  end;


  function TMacroLibPlug.EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  begin
    if AEvent = EE_READ then
//    MacroLibrary.CheckEvent(maEditor, meOpen);
      FarAdvControl(ACTL_SYNCHRO, TRunEvent.CreateEx(meOpen, maEditor));
//  EE_GOTFOCUS...
    Result := 0;
  end;


  function TMacroLibPlug.ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  begin
    if AEvent = VE_READ then
//    MacroLibrary.CheckEvent(maViewer, meOpen);
      FarAdvControl(ACTL_SYNCHRO, TRunEvent.CreateEx(meOpen, maViewer));
    Result := 0;
  end;

  

initialization
finalization
  FreeObj(CmdWords);
end.


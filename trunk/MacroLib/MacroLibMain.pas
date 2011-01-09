{$I Defines.inc}

unit MacroLibMain;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* MacroLib                                                                   *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,

    PluginW,
    FarCtrl,
    FarMenu,

    MacroLibConst,
    MacroLibClasses;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function GetMinFarVersionW :Integer; stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  function ConfigureW(Item: integer) :Integer; stdcall;
  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { Injecting Support                                                           }
 {-----------------------------------------------------------------------------}

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
        if (P.EventType = KEY_EVENT) and optProcessHotkey then begin
          if MacroLibrary.CheckHotkey(P.Event.KeyEvent) then
            ClearKeyEvent(P.Event.KeyEvent);
        end else
        if (P.EventType = _MOUSE_EVENT) and optProcessMouse then begin
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
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optProcessHotkey;
        vMenu.Checked[1] := optProcessMouse;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOption(optProcessHotkey);
          1 : ToggleOption(optProcessMouse);
          2 :
            if FarInputBox(GetMsg(strMacroPathsTitle), GetMsg(strMacroPathsPrompt), optMacroPaths) then begin
              WriteSetup;
              MacroLibrary.RescanMacroses(True);
            end;
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
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : MacroLibrary.ShowAvailable;

        2 : MacroLibrary.ShowAll;
        3 : MacroLibrary.RescanMacroses(False);

        5 : OptionsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Экспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  function GetMinFarVersionW :Integer; stdcall;
  begin
    Result := MakeFarVersion(2, 0, 1765);   { MCMD_GETAREA };
  end;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    FARAPI := psi;
    FARSTD := psi.fsf^;

    RestoreDefColor;
    ReadSetup;

    MacroLibrary := TMacroLibrary.Create;
    MacroLibrary.RescanMacroses(True);

    InjectHandlers;
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;

  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= PF_PRELOAD or PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := Pointer(@PluginMenuStrings);

    pi.PluginConfigStringsNumber := 1;
    pi.PluginConfigStrings := Pointer(@PluginMenuStrings);

    pi.Reserved := cPluginGUID;
  end;


  procedure ExitFARW; stdcall;
  begin
//  Trace('ExitFAR');
    RemoveHandlers;
    FreeObj(MacroLibrary);
  end;


  function OpenPluginW(OpenFrom: integer; Item :TIntPtr): THandle; stdcall;
  begin
    Result:= INVALID_HANDLE_VALUE;
    try
//    TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
      if OpenFrom and OPEN_FROMMACRO <> 0 then begin
        MacroLibrary.ShowAvailable
      end else
        MainMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function ConfigureW(Item: integer) :Integer; stdcall;
  begin
    Result := 1;
    try
      OptionsMenu;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function ProcessSynchroEventW(Event :integer; Param :Pointer) :Integer; stdcall;
  var
    vObj :TObject;
  begin
//  TraceF('ProcessSynchroEventW. Event=%d, Param=%d', [Event, Integer(Param)]);
    Result := 0;
    if Event <> SE_COMMONSYNCHRO then
      Exit;

    vObj := Param;
    if vObj is TMacro then
      TMacro(vObj).Execute
    else
    if vObj is TExList then begin
      MacroLibrary.ShowList(TExList(vObj));
      FreeObj(vObj);
    end;
  end;


  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;
  begin
    if AEvent = DE_DLGPROCEND then begin
      if AParam.Msg = DN_INITDIALOG then begin
//      TraceF('InitDialog: %d', [AParam.hDlg]);
        PushDlg(AParam.hDlg);
      end else
      if (AParam.Msg = DN_CLOSE) and (AParam.Result <> 0) then begin
//      TraceF('CloseDialog: %d', [AParam.hDlg]);
        PopDlg(AParam.hDlg);
      end;
    end;
    Result := 0;
  end;


end.


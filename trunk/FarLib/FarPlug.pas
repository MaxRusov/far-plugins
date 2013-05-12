{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Ёкспортируемые процедуры                                                   *}
{******************************************************************************}

{$I Defines.inc}

unit FarPlug;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    Far_API, {Plugin3.pas}
    FarCtrl;


  type
   {$ifdef Far3}
   {$else}
    TOpenPanelInfo = TOpenPluginInfo;  { —иноним, как в Far3 }
   {$endif Far3}

    TVersion = record
      Major :Integer;
      Minor :Integer;
      Build :Integer;
    end;

    TFarPlug = class(TBasis)
    public
      constructor Create; override;
      procedure Init; virtual;
      procedure Startup; virtual;
      procedure GetInfo; virtual;
      procedure ExitFar; virtual;

      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; virtual;
      function OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; virtual;
      function OpenCmdLine(AStr :PTChar) :THandle; virtual;
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; virtual;
     {$endif Far3}
      procedure ClosePanel(AHandle :THandle); virtual;
      procedure GetPanelInfo(AHandle :THandle; var AInfo :TOpenPanelInfo); virtual;
      function GetPanelItems(AHandle :THandle; AMode :Integer; var AItems :PPluginPanelItemArray; var ACount :Integer) :boolean; virtual;
      procedure FreePanelItems(AHandle :THandle; AItems :PPluginPanelItemArray; ACount :Integer); virtual;
      function PanelSetDirectory(AHandle :THandle; AMode :Integer; ADir :PFarChar) :Boolean; virtual;
      function PanelMakeDirectory(AHandle :THandle; AMode :Integer; var ADir :TString) :Boolean; virtual;
      function PanelGetFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer; AMove :boolean; var ADestPath :TString) :Boolean; virtual;
      function PanelDeleteFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean; virtual;
      function PanelInput(AHandle :THandle; AKey :Integer) :Boolean; virtual;
     {$ifdef Far3}
      function PanelInputEx(AHandle :THandle; const ARec :TInputRecord) :Boolean; virtual;
     {$endif Far3}

      function Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :THandle; virtual;
      procedure CloseAnalyse(AHandle :THandle); virtual;
      procedure Configure; virtual;

      procedure SynchroEvent(AParam :Pointer); virtual;
      function DialogEvent(AEvent :Integer; AParam :PFarDialogEvent) :Integer; virtual;
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; virtual;
      function ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; virtual;

      function EditorInput(const ARec :TInputRecord) :Integer; virtual;
     {$ifdef Far3}
      function ConsoleInput(const ARec :TInputRecord) :Integer; virtual;
     {$endif Far3}

      procedure ErrorHandler(E :Exception); virtual;

    protected
      FName      :TString;
      FDescr     :TString;
      FAuthor    :TString;
      FVersion   :TVersion;
      FMinFarVer :TVersion;
     {$ifdef Far3}
      FGUID      :TGUID;
     {$else}
      FID        :DWORD;
     {$endif Far3}

      FFlags     :DWORD;
      FPrefix    :TString;
      FMenuStr   :TString;
      FDiskStr   :TString;
      FConfigStr :TString;
     {$ifdef Far3}
      FMenuID    :TGUID;
      FDiskID    :TGUID;
      FConfigID  :TGUID;
     {$endif Far3}

    private
      FTmpStr    :TString;
    end;

  var
    Plug :TFarPlug;

  function MakeVersion(Major, Minor, Build :Integer) :TVersion;
  function GetSelfVerison :TVersion;


 {$ifdef Far3}
  procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;           
  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var AInfo :TPluginInfo); stdcall;
  function OpenW(var AInfo :TOpenInfo): THandle; stdcall;
  procedure ClosePanelW(const AInfo :TClosePanelInfo); stdcall;
  procedure GetOpenPanelInfoW(var AInfo :TOpenPanelInfo); stdcall;
  function GetFindDataW(var AInfo :TGetFindDataInfo) :TIntPtr; stdcall;
  procedure FreeFindDataW(const AInfo :TFreeFindDataInfo); stdcall;
  function SetDirectoryW(const AInfo :TSetDirectoryInfo) :TIntPtr; stdcall;
  function GetFilesW(var AInfo :TGetFilesInfo) :TIntPtr; stdcall;
  function PutFilesW(const AInfo :TPutFilesInfo) :TIntPtr; stdcall;
  function DeleteFilesW(var AInfo :TDeleteFilesInfo) :TIntPtr; stdcall;
  function MakeDirectoryW(var AInfo :TMakeDirectoryInfo) :TIntPtr; stdcall;
  function AnalyseW(const AInfo :TAnalyseInfo) :THandle; stdcall;
  procedure CloseAnalyseW(const AInfo :TCloseAnalyseInfo); stdcall;
  function ConfigureW(const AInfo :TConfigureInfo) :TIntPtr; stdcall;
  function ProcessPanelInputW(const AInfo :TProcessPanelInputInfo) :TIntPtr; stdcall;
  function ProcessSynchroEventW(const AInfo :TProcessSynchroEventInfo) :TIntPtr; stdcall;
  function ProcessDialogEventW(const AInfo :TProcessDialogEventInfo) :TIntPtr; stdcall;
  function ProcessEditorEventW(const AInfo :TProcessEditorEventInfo) :TIntPtr; stdcall;
  function ProcessEditorInputW(const AInfo :TProcessEditorInputInfo) :TIntPtr; stdcall;
  function ProcessViewerEventW(const AInfo :TProcessViewerEventInfo) :TIntPtr; stdcall;
  function ProcessConsoleInputW(const AInfo :TProcessConsoleInputInfo) :TIntPtr; stdcall;
  procedure ExitFARW(const AInfo :TExitInfo); stdcall;
 {$else}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var AInfo :TPluginInfo); stdcall;
  function OpenPluginW(OpenFrom :Integer; AItem :INT_PTR): THandle; stdcall;
  procedure ClosePluginW(AHandle :THandle); stdcall;
  procedure GetOpenPluginInfoW(AHandle :THandle; var AInfo :TOpenPluginInfo); stdcall;
  function GetFindDataW(AHandle :THandle; var AItems :PPluginPanelItemArray; var ACount :Integer; AMode :Integer) :boolean; stdcall;
  procedure FreeFindDataW(AHandle :THandle; AItems :PPluginPanelItemArray; ACount :Integer); stdcall;
  function SetDirectoryW(AHandle :THandle; ADir :PFarChar; AMode :Integer) :Boolean; stdcall;
  function GetFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; var ADestPath :PFarChar; AMode :Integer) :Integer; stdcall;
  function PutFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; ASrcPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
  function DeleteFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMode :Integer) :Integer; stdcall;
  function MakeDirectoryW(AHandle :THandle; var AName :PFarChar; AMode :Integer) :Integer; stdcall;
  function OpenFilePluginW(const AName :PTChar; AData :Pointer; ADataSize :Integer; AMode :Integer) :THandle; stdcall;
  function ConfigureW(AItem: integer) :Integer; stdcall;
  function ProcessKeyW(AHandle :THandle; AKey, AShiftState :Integer) :Integer; stdcall;
  function ProcessSynchroEventW(Event :integer; AParam :Pointer) :Integer; stdcall;
  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;
  function ProcessEditorEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  function ProcessEditorInputW(const ARec :INPUT_RECORD) :Integer; stdcall;
  function ProcessViewerEventW(AEvent :Integer; AParam :Pointer) :Integer; stdcall;
  procedure ExitFARW; stdcall;
 {$endif Far3}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function MakeVersion(Major, Minor, Build :Integer) :TVersion;
  begin
    Result.Major := Major;
    Result.Minor := Minor;
    Result.Build := Build;
  end;


  function GetSelfVerison :TVersion;
  var
    vName :array[0..Max_Path] of TChar;
    vBuf  :Pointer;
    vSize :DWORD;
    vTemp :DWORD;
    vInfo :PVSFixedFileInfo;
  begin
    Result.Major := 1; Result.Minor := 0;  Result.Build := 0;

    GetModuleFileName(hInstance, vName, High(vName) + 1);

    vSize := GetFileVersionInfoSize( vName, vTemp);
    if vSize > 0 then begin
      GetMem(vBuf, vSize);
      try
        GetFileVersionInfo( vName, vTemp, vSize, vBuf);
        if VerQueryValue(vBuf, '\', Pointer(vInfo), vSize) then begin
          Result.Major := LongRec(vInfo.dwFileVersionMS).Hi;
          Result.Minor := LongRec(vInfo.dwFileVersionMS).Lo;
//        Result.Build := LongRec(vInfo.dwFileVersionLS).Hi;
          Result.Build := LongRec(vInfo.dwFileVersionLS).Lo;
        end;
      finally
        FreeMem(vBuf);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFarPlug                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TFarPlug.Create;
  begin
    inherited Create;
    Init;
  end;


  procedure TFarPlug.Init; {virtual;}
  begin
    FVersion := MakeVersion(1, 0, 0);
    FMinFarVer := MakeVersion(FARMANAGERVERSION_MAJOR, FARMANAGERVERSION_MINOR, FARMANAGERVERSION_BUILD);
  end;


  procedure TFarPlug.Startup; {virtual;}
  begin
  end;


  procedure TFarPlug.GetInfo; {virtual;}
  begin
  end;


  procedure TFarPlug.ExitFar; {virtual;}
  begin
  end;


  function TFarPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {virtual;}
  begin
    Result := INVALID_HANDLE_VALUE;
  end;


  function TFarPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {virtual;}
  begin
    Result := INVALID_HANDLE_VALUE;
  end;


  function TFarPlug.OpenCmdLine(AStr :PTChar) :THandle; {virtual;}
  begin
    Result := INVALID_HANDLE_VALUE;
  end;


 {$ifdef Far3}
  function TFarPlug.OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {virtual;}
  begin
    Result := INVALID_HANDLE_VALUE;
    if ACount = 0 then
      Result := OpenMacro(0, nil)
    else
    if ACount = 1 then begin
      with AParams[0] do begin
        if fType = FMVT_INTEGER then
          Result := OpenMacro(Value.fInteger, nil)
        else
        if fType = FMVT_STRING then
          Result := OpenMacro(0, Value.fString)
        else
        if fType = FMVT_DOUBLE then
          Result := OpenMacro(Trunc(Value.fDouble), nil)
      end;
    end;
  end;
 {$endif Far3}


  procedure TFarPlug.ClosePanel(AHandle :THandle); {virtual;}
  begin
  end;


  procedure TFarPlug.GetPanelInfo(AHandle :THandle; var AInfo :TOpenPanelInfo); {virtual;}
  begin
  end;


  function TFarPlug.GetPanelItems(AHandle :THandle; AMode :Integer; var AItems :PPluginPanelItemArray; var ACount :Integer) :boolean;  {virtual;}
  begin
    Result := False;
  end;


  procedure TFarPlug.FreePanelItems(AHandle :THandle; AItems :PPluginPanelItemArray; ACount :Integer); {virtual;}
  begin
  end;


  function TFarPlug.PanelSetDirectory(AHandle :THandle; AMode :Integer; ADir :PFarChar) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TFarPlug.PanelMakeDirectory(AHandle :THandle; AMode :Integer; var ADir :TString) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TFarPlug.PanelGetFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer; AMove :boolean; var ADestPath :TString) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TFarPlug.PanelDeleteFiles(AHandle :THandle; AMode :Integer; AItems :PPluginPanelItem; ACount :Integer) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TFarPlug.PanelInput(AHandle :THandle; AKey :Integer) :Boolean; {virtual;}
  begin
    Result := False;
  end;


 {$ifdef Far3}
  function TFarPlug.PanelInputEx(AHandle :THandle; const ARec :TInputRecord) :Boolean; {virtual;}
  begin
    if ARec.EventType = KEY_EVENT then
      Result := PanelInput(AHandle, KeyEventToFarKeyDlg(ARec.Event.KeyEvent))
    else
      Result := False;
  end;
 {$endif Far3}


  function TFarPlug.Analyse(AName :PTChar; AData :Pointer; ASize :Integer; AMode :Integer) :THandle; {virtual;}
  begin
    Result := INVALID_HANDLE_VALUE;
  end;


  procedure TFarPlug.CloseAnalyse(AHandle :THandle); {virtual;}
  begin
  end;


  procedure TFarPlug.Configure; {virtual;}
  begin
  end;


  procedure TFarPlug.SynchroEvent(AParam :Pointer); {virtual;}
  begin
  end;


  function TFarPlug.DialogEvent(AEvent :Integer; AParam :PFarDialogEvent) :Integer; {virtual;}
  begin
    Result := 0;
  end;

  function TFarPlug.EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {virtual;}
  begin
    Result := 0;
  end;

  function TFarPlug.ViewerEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {virtual;}
  begin
    Result := 0;
  end;


  function TFarPlug.EditorInput(const ARec :TInputRecord) :Integer; {virtual;}
  begin
    Result := 0;
  end;

 {$ifdef Far3}
  function TFarPlug.ConsoleInput(const ARec :TInputRecord) :Integer; {virtual;}
  begin
    Result := 0;
  end;
 {$endif Far3}


  procedure TFarPlug.ErrorHandler(E :Exception); {virtual;}
  begin
    ShowMessage(FName, E.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые функции                                                      }
 {-----------------------------------------------------------------------------}

 {$ifdef Far3}
  procedure GetGlobalInfoW;
  begin
    Assert(Plug <> nil);
    AInfo.StructSize := SizeOf(AInfo);
    with Plug.FVersion do
      AInfo.Version := MakeFarVersion(Major, Minor, 0, Build, VS_RELEASE);
    with Plug.FMinFarVer do
      AInfo.MinFarVersion := MakeFarVersion(Major, Minor, 0, Build, VS_RELEASE);
    AInfo.GUID := Plug.FGUID;
    AInfo.Title := PTChar(Plug.FName);
    AInfo.Description := PTChar(Plug.FDescr);
    AInfo.Author := PTChar(Plug.FAuthor);
  end;
 {$else}
  function GetMinFarVersionW :Integer; stdcall;
  begin
    with Plug.FMinFarVer do
      Result := MakeFarVersion(Major, Minor, Build);
  end;
 {$endif Far3}


  procedure SetStartupInfoW;
  begin
//  TraceF('SetStartupInfo: %s', ['']);
    FARAPI := AInfo;
    FARSTD := AInfo.fsf^;

   {$ifdef Far3}
    PluginID := Plug.FGUID;
   {$else}
    hModule := AInfo.ModuleNumber;
   {$endif Far3}

    Plug.Startup;
  end;


  procedure GetPluginInfoW;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    Plug.GetInfo;

    AInfo.StructSize:= SizeOf(AInfo);
    AInfo.Flags:= Plug.FFlags;
   {$ifdef Far3}
   {$else}
    AInfo.Reserved := Plug.FID;
   {$endif Far3}

    if Plug.FPrefix <> '' then
      AInfo.CommandPrefix := PTChar(Plug.FPrefix);

    if Plug.FMenuStr <> '' then begin
     {$ifdef Far3}
      AInfo.PluginMenu.Count := 1;
      AInfo.PluginMenu.Strings := Pointer(@Plug.FMenuStr);
      AInfo.PluginMenu.Guids := Pointer(@Plug.FMenuID);
     {$else}
      AInfo.PluginMenuStringsNumber := 1;
      AInfo.PluginMenuStrings := Pointer(@Plug.FMenuStr);
     {$endif Far3}
    end;

    if Plug.FDiskStr <> '' then begin
     {$ifdef Far3}
      AInfo.DiskMenu.Count := 1;
      AInfo.DiskMenu.Strings := Pointer(@Plug.FDiskStr);
      AInfo.DiskMenu.Guids := Pointer(@Plug.FDiskID);
     {$else}
      AInfo.DiskMenuStringsNumber := 1;
      AInfo.DiskMenuStrings := Pointer(@Plug.FDiskStr);
     {$endif Far3}
    end;

    if Plug.FConfigStr <> '' then begin
     {$ifdef Far3}
      AInfo.PluginConfig.Count := 1;
      AInfo.PluginConfig.Strings := Pointer(@Plug.FConfigStr);
      AInfo.PluginConfig.Guids := Pointer(@Plug.FConfigID);
     {$else}
      AInfo.PluginConfigStringsNumber := 1;
      AInfo.PluginConfigStrings := Pointer(@Plug.FConfigStr);
     {$endif Far3}
    end;
  end;


  procedure ExitFARW;
  begin
//  Trace('ExitFAR');
    Plug.ExitFar;
  end;


 {$ifdef Far3}
  function OpenW;
  var
    vRes :THandle;
  begin
    Result := 0;
    try
      if AInfo.OpenFrom = OPEN_FROMMACRO_ then begin
        with POpenMacroInfo(AInfo.Data)^ do
          vRes := Plug.OpenMacroEx(Count, Values);
//      if vRes = INVALID_HANDLE_VALUE then
//        vRes := 1; { return True }
      end else
      if AInfo.OpenFrom = OPEN_COMMANDLINE then begin
        with POpenCommandLineInfo(AInfo.Data)^ do
          vRes := Plug.OpenCmdLine(CommandLine);
        if vRes = INVALID_HANDLE_VALUE then
          vRes := 0;
      end else
      begin
        vRes := Plug.Open(AInfo.OpenFrom, AInfo.Data);
        if vRes = INVALID_HANDLE_VALUE then
          vRes := 0;
      end;

      Result := vRes;

    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;

  procedure ClosePanelW;
  begin
    with AInfo do
      Plug.ClosePanel(hPanel);
  end;

  procedure GetOpenPanelInfoW;
  begin
    with AInfo do
      Plug.GetPanelInfo(hPanel, AInfo);
  end;

 {$else}

  function OpenPluginW;
  begin
    Result := INVALID_HANDLE_VALUE;
    try
      if OpenFrom and OPEN_FROMMACRO <> 0 then begin
        if OpenFrom and OPEN_FROMMACROSTRING <> 0 then
          Result := Plug.OpenMacro(0, Pointer(AItem))
        else
          Result := Plug.OpenMacro(AItem, nil)
      end else
      if OpenFrom = OPEN_COMMANDLINE then
        Result := Plug.OpenCmdLine(PFarChar(AItem))
      else
        Result := Plug.Open(OpenFrom, AItem);
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;

  procedure ClosePluginW;
  begin
    Plug.ClosePanel(AHandle);
  end;

  procedure GetOpenPluginInfoW;
  begin
    Plug.GetPanelInfo(AHandle, AInfo);
  end;
 {$endif Far3}


  function GetFindDataW;
 {$ifdef Far3}
  var
    vCount :Integer;
  begin
    with AInfo do begin
      vCount := 0;
      Result := Byte(Plug.GetPanelItems(hPanel, OpMode, PanelItem, vCount));
      ItemsNumber := vCount;
    end;
 {$else}
  begin
    Result := Plug.GetPanelItems(AHandle, AMode, AItems, ACount);
 {$endif Far3}
  end;


  procedure FreeFindDataW;
  begin
   {$ifdef Far3}
    with AInfo do
      Plug.FreePanelItems(hPanel, PanelItem, ItemsNumber);
   {$else}
    Plug.FreePanelItems(AHandle, AItems, ACount);
   {$endif Far3}
  end;


 {$ifdef Far3}
  function SetDirectoryW;
  begin
    Result := 0;
    try
      with AInfo do
        Result := Byte(Plug.PanelSetDirectory(hPanel, OpMode, Dir));
    except
      on E :Exception do
        if OPM_FIND and AInfo.OpMode = 0 then
          Plug.ErrorHandler(E);
    end;
  end;
 {$else}
  function SetDirectoryW;
  begin
    Result := False;
    try
      Result := Plug.PanelSetDirectory(AHandle, AMode, ADir);
    except
      on E :Exception do
        if OPM_FIND and AMode = 0 then
          Plug.ErrorHandler(E);
    end;
  end;
 {$endif Far3}

 
  function MakeDirectoryW;
  begin
    Result := 0;
    try
     {$ifdef Far3}
      with AInfo do begin
        Plug.FTmpStr := Name;
        if Plug.PanelMakeDirectory(hPanel, OpMode, Plug.FTmpStr) then begin
          Name := PTChar(Plug.FTmpStr);
          Result := 1;
        end else
          Result := -1;
      end;
     {$else}
      Plug.FTmpStr := AName;
      if Plug.PanelMakeDirectory(AHandle, AMode, Plug.FTmpStr) then begin
        AName := PTChar(Plug.FTmpStr);
        Result := 1;
      end else
        Result := -1;
     {$endif Far3}
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;


  function GetFilesW;
  begin
    Result := 0;
    try
     {$ifdef Far3}
      with AInfo do begin
        Plug.FTmpStr := DestPath;
        if Plug.PanelGetFiles(hPanel, OpMode, PanelItem, ItemsNumber, Move, Plug.FTmpStr) then begin
          DestPath := PTChar(Plug.FTmpStr);
          Result := 1;
        end else
          Result := -1;
      end;
     {$else}
      Plug.FTmpStr := ADestPath;
      if Plug.PanelGetFiles(AHandle, AMode, AItems, ACount, AMove <> 0, Plug.FTmpStr) then begin
        ADestPath := PTChar(Plug.FTmpStr);
        Result := 1;
      end else
        Result := -1;
     {$endif Far3}
    except
      on E :Exception do
        if OPM_FIND and {$ifdef Far3}AInfo.OpMode{$else}AMode{$endif Far3} = 0 then
          Plug.ErrorHandler(E);
    end;
  end;


  function PutFilesW;
  begin
    Result := 0;
  end;


  function DeleteFilesW;
  begin
    Result := 0;
    try
     {$ifdef Far3}
      with AInfo do
        if Plug.PanelDeleteFiles(hPanel, OpMode, PanelItem, ItemsNumber) then
          Result := 1
        else
          Result := -1;
     {$else}
      if Plug.PanelDeleteFiles(AHandle, AMode, AItems, ACount) then
        Result := 1
      else
        Result := -1;
     {$endif Far3}
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;


 {$ifdef Far3}
  function AnalyseW;
  var
    vRes :THandle;
  begin
    with AInfo do begin
      vRes := Plug.Analyse(FileName, Buffer, BufferSize, OpMode);
      if vRes = INVALID_HANDLE_VALUE then
        vRes := 0;
      Result := vRes;
    end;
  end;

  procedure CloseAnalyseW;
  begin
    with AInfo do
      Plug.CloseAnalyse(Handle);
  end;

 {$else}

  function OpenFilePluginW;
  begin
    Result := Plug.Analyse(AName, AData, ADataSize, AMode);
  end;
 {$endif Far3}


  function ConfigureW;
  begin
    Result := 1;
    try
      Plug.Configure;
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;


 {$ifdef Far3}
  function ProcessPanelInputW;
  begin
    try
      with AInfo do
        Result := byte(Plug.PanelInputEx(hPanel, Rec));
    except
      on E :Exception do begin
        Plug.ErrorHandler(E);
        Result := 1;
      end;
    end;
  end;
 {$else}
  function ProcessKeyW;
  var
    vRec :TKeyEventRecord;
  begin
    Result := 0;
    try
      if AKey and not KEY_MASKF = 0 then begin
        FillZero(vRec, SizeOf(vRec));

        vRec.wVirtualKeyCode := AKey;
        if PKF_SHIFT and AShiftState <> 0 then
          vRec.dwControlKeyState := vRec.dwControlKeyState or SHIFT_PRESSED;
        if PKF_CONTROL and AShiftState <> 0 then
          vRec.dwControlKeyState := vRec.dwControlKeyState or LEFT_CTRL_PRESSED;
        if PKF_ALT and AShiftState <> 0 then
          vRec.dwControlKeyState := vRec.dwControlKeyState or LEFT_ALT_PRESSED;

        Result := byte(Plug.PanelInput(AHandle, KeyEventToFarKey(vRec)));
      end;
    except
      on E :Exception do begin
        Plug.ErrorHandler(E);
        Result := 1;
      end;
    end;
  end;
 {$endif Far3}


  function ProcessSynchroEventW;
  begin
    Result := 0;
    try
     {$ifdef Far3}
      if AInfo.Event = SE_COMMONSYNCHRO then
        Plug.SynchroEvent(AInfo.Param);
     {$else}
      if Event = SE_COMMONSYNCHRO then
        Plug.SynchroEvent(AParam);
     {$endif Far3}
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;


  function ProcessDialogEventW;
  begin
   {$ifdef Far3}
    with AInfo do
      Result := Plug.DialogEvent(Event, Param);
   {$else}
    Result := Plug.DialogEvent(AEvent, AParam);
   {$endif Far3}
  end;


  function ProcessEditorEventW;
 {$ifdef Far3}
  begin
    with AInfo do
      Result := Plug.EditorEvent(EditorID, Event, Param);
 {$else}
  var
    vID :Integer;
  begin
    vID := 0;
    if AEvent in [EE_GOTFOCUS, EE_KILLFOCUS, EE_CLOSE] then
      vID := Integer(AParam^);
    Result := Plug.EditorEvent(vID, AEvent, AParam);
 {$endif Far3}
  end;


  function ProcessViewerEventW;
 {$ifdef Far3}
  begin
    with AInfo do
      Result := Plug.ViewerEvent(ViewerID, Event, Param);
 {$else}
  var
    vID :Integer;
  begin
    vID := 0;
    if AEvent in [VE_GOTFOCUS, VE_KILLFOCUS, VE_CLOSE] then
      vID := Integer(AParam^);
    Result := Plug.ViewerEvent(vID, AEvent, AParam);
 {$endif Far3}
  end;


  function ProcessEditorInputW;
  begin
   {$ifdef Far3}
    with AInfo do
      Result := Plug.EditorInput(Rec);
   {$else}
    Result := Plug.EditorInput(ARec);
   {$endif Far3}
  end;


 {$ifdef Far3}
  function ProcessConsoleInputW;
  begin
    Result := Plug.ConsoleInput(AInfo.Rec);
  end;
 {$endif Far3}


initialization
finalization
  FreeObj(Plug);
end.


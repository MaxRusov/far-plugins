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

    Far_API,
    FarCtrl;


  type
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
     {$ifdef Far3}
      function OpenMacroEx(ACount :Integer; AParams :PFarMacroValueArray) :THandle; virtual;
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
  function AnalyseW(const AInfo :TAnalyseInfo) :THandle; stdcall;
  procedure CloseAnalyseW(const AInfo :TCloseAnalyseInfo); stdcall;
  function ConfigureW(const AInfo :TConfigureInfo) :Integer; stdcall;
  function ProcessSynchroEventW(const AInfo :TProcessSynchroEventInfo) :Integer; stdcall;
  function ProcessDialogEventW(const AInfo :TProcessDialogEventInfo) :Integer; stdcall;
  function ProcessEditorEventW(const AInfo :TProcessEditorEventInfo) :Integer; stdcall;
  function ProcessEditorInputW(const AInfo :TProcessEditorInputInfo) :Integer; stdcall;
  function ProcessViewerEventW(const AInfo :TProcessViewerEventInfo) :Integer; stdcall;
  function ProcessConsoleInputW(const AInfo :TProcessConsoleInputInfo) :Integer; stdcall;
  procedure ExitFARW(const AInfo :TExitInfo); stdcall;
 {$else}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var AInfo :TPluginInfo); stdcall;
  function OpenPluginW(OpenFrom :Integer; AItem :INT_PTR): THandle; stdcall;
  function OpenFilePluginW(const AName :PTChar; AData :Pointer; ADataSize :Integer; AMode :Integer) :THandle; stdcall;
  function ConfigureW(AItem: integer) :Integer; stdcall;
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


(*
  function TFarPlug.OpenMacro(ACount :Integer; AParams :PFarMacroValueArray) :THandle; {virtual;}
  begin
    Result := INVALID_HANDLE_VALUE;
  end;
*)

  function TFarPlug.OpenMacro(AInt :TIntPtr; AStr :PTChar) :THandle; {virtual;}
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
      end;
    end;
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
        Result := Plug.Open(OpenFrom, AItem);
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;
 {$endif Far3}


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
    Result := Plug.ConsoleInput(AInfo.Rec^);
  end;
 {$endif Far3}


initialization
finalization
  FreeObj(Plug);
end.


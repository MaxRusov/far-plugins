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
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarKeysW,
    FarColor,
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
      procedure Configure; virtual;

      procedure SynchroEvent(AParam :Pointer); virtual;
      function DialogEvent(AEvent :Integer; AParam :Pointer) :Integer; virtual;
      function EditorEvent(AEvent :Integer; AParam :Pointer) :Integer; virtual;
      function ViewerEvent(AEvent :Integer; AParam :Pointer) :Integer; virtual;

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


 {$ifdef Far3}
  procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;
  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var AInfo :TPluginInfo); stdcall;
  function OpenW(var AInfo :TOpenInfo): THandle; stdcall;
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
    Result:= INVALID_HANDLE_VALUE;
  end;


  procedure TFarPlug.Configure; {virtual;}
  begin
  end;


  procedure TFarPlug.SynchroEvent(AParam :Pointer); {virtual;}
  begin
  end;


  function TFarPlug.DialogEvent(AEvent :Integer; AParam :Pointer) :Integer; {virtual;}
  begin
    Result := 0;
  end;

  function TFarPlug.EditorEvent(AEvent :Integer; AParam :Pointer) :Integer; {virtual;}
  begin
    Result := 0;
  end;

  function TFarPlug.ViewerEvent(AEvent :Integer; AParam :Pointer) :Integer; {virtual;}
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
    ShowMessage('Error', E.Message, FMSG_WARNING or FMSG_MB_OK);
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
 {$else}
  function OpenPluginW;
 {$endif Far3}
  begin
    Result:= INVALID_HANDLE_VALUE;
    try
     {$ifdef Far3}
      Result := Plug.Open(AInfo.OpenFrom, AInfo.Data);
     {$else}
      Result := Plug.Open(OpenFrom, AItem);
     {$endif Far3}
    except
      on E :Exception do
        Plug.ErrorHandler(E);
    end;
  end;


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
  begin
   {$ifdef Far3}
    with AInfo do
      Result := Plug.EditorEvent(Event, Param);
   {$else}
    Result := Plug.EditorEvent(AEvent, AParam);
   {$endif Far3}
  end;


  function ProcessViewerEventW;
  begin
   {$ifdef Far3}
    with AInfo do
      Result := Plug.ViewerEvent(Event, Param);
   {$else}
    Result := Plug.ViewerEvent(AEvent, AParam);
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


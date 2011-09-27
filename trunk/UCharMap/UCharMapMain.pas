{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{$I Defines.inc}

unit UCharMapMain;

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarCtrl,
    UCharMapCtrl,
    UCharMapDlg;


 {$ifdef Far3}
  procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;
 {$else}
  function GetMinFarVersionW :Integer; stdcall;
 {$endif Far3}

  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
 {$ifdef Far3}
  function OpenW(var AInfo :TOpenInfo): THandle; stdcall;
 {$else}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif Far3}

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef Far3}
  procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;
  begin
    AInfo.StructSize := SizeOf(AInfo);
  //AInfo.MinFarVersion := FARMANAGERVERSION;
  //AInfo.Info := PLUGIN_VERSION;
    AInfo.GUID := cPluginID;
    AInfo.Title := cPluginName;
    AInfo.Description := cPluginDescr;
    AInfo.Author := cPluginAuthor;
  end;
 {$else}
  function GetMinFarVersionW :Integer; stdcall;
  begin
    Result := MakeFarVersion(2, 0, 1573);   { ACTL_GETFARRECT }
  end;
 {$endif Far3}


  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  begin
    FARAPI := AInfo;
    FARSTD := AInfo.fsf^;

   {$ifdef Far3}
    PluginID := cPluginID;
   {$else}
    hModule := AInfo.ModuleNumber;
   {$endif Far3}

    RestoreDefColor;
//  ReadSettings;
  end;


  var
    PluginMenuStr :TString;
   {$ifdef Far3}
    PluginMenuGUID :TGUID;
   {$endif Far3}

  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= {PF_PRELOAD or} PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStr := GetMsg(strTitle);
   {$ifdef Far3}
    PluginMenuGUID := cMenuID;
    pi.PluginMenu.Count := 1;
    pi.PluginMenu.Strings := Pointer(@PluginMenuStr);
    pi.PluginMenu.Guids := Pointer(@PluginMenuGUID);
   {$else}
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := Pointer(@PluginMenuStr);
   {$endif Far3}

    pi.CommandPrefix := PFarChar(CmdPrefix);
  end;


 {$ifdef Far3}
  function OpenW(var AInfo :TOpenInfo): THandle; stdcall;
 {$else}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif Far3}
  begin
    Result:= INVALID_HANDLE_VALUE;
    try
//    TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
      OpenDlg;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


end.


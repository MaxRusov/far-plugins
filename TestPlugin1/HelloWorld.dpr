(*
  "Hello, World!" - демонстрационный плагин.
  Copyright (c) 2000-2011, [ FAR group ]
  Delphi version copyright (c) 2000, Vasily V. Moshninov, Max Rusov
*)

{$AppType Console}

library HelloWorld;

uses
  Windows,
 {$ifdef Far3}
  Plugin3;
 {$else}
  PluginW; 
 {$endif Far3}


{$ifdef Far3}
const
  cPluginID :TGUID = '{C35FEA83-0291-4F04-949F-F12774C03F36}';
  cMenuID   :TGUID = '{4DC4B639-7A32-4EBA-9694-3D0E87851978}';
  cDlgID    :TGUID = '{F8E1C2DE-0A18-4FD2-866E-C021C38D2491}';

  PLUGIN_NAME = 'HelloWorld';
  PLUGIN_DESC = 'Far sample plugin';
  PLUGIN_AUTHOR = 'Far Group';
{$endif Far3}


type
  TMessages = (MTitle, MMessage1, MMessage2, MMessage3, MMessage4, MButton);

var
  FARAPI: TPluginStartupInfo;

{  Функция GetMsg возвращает строку сообщения из языкового файла. }
{  А это надстройка над Info.GetMsg для сокращения кода :-) }

function GetMsg(MsgId: TMessages): PFarChar;
begin
 {$ifdef Far3}
  Result := FARAPI.GetMsg(cPluginID, integer(MsgId));
 {$else}
  Result := FARAPI.GetMsg(FARAPI.ModuleNumber, integer(MsgId));
 {$endif Far3}
end;


{$ifdef Far3}
procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;
begin
  AInfo.StructSize := SizeOf(AInfo);
//AInfo.MinFarVersion := FARMANAGERVERSION;
//AInfo.Info := PLUGIN_VERSION;
  AInfo.GUID := cPluginID;
  AInfo.Title := PLUGIN_NAME;
  AInfo.Description := PLUGIN_DESC;
  AInfo.Author := PLUGIN_AUTHOR;
end;
{$endif Far3}


{ Функция SetStartupInfo вызывается один раз, перед всеми }
{ другими функциями. Она передается плагину информацию, }
{ необходимую для дальнейшей работы. }

procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
begin
  FARAPI := AInfo;
end;

{ Функция GetPluginInfo вызывается для получения основной (general) информации о плагине }

var
  PluginMenuStrings :array[0..0] of PFarChar;
  PluginMenuGUIDS :array[0..0] of TGUID;

procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
begin
  pi.StructSize:= SizeOf(pi);
  pi.Flags:= PF_EDITOR;

  PluginMenuStrings[0] := GetMsg(MTitle);
 {$ifdef Far3}
  PluginMenuGUIDS[0] := cMenuID;
  pi.PluginMenu.Count := 1;
  pi.PluginMenu.Strings := Pointer(@PluginMenuStrings);
  pi.PluginMenu.Guids := Pointer(@PluginMenuGUIDS);
 {$else}
  pi.PluginMenuStringsNumber := 1;
  pi.PluginMenuStrings := Pointer(@PluginMenuStrings);
 {$endif Far3}
end;


{ Функция OpenPlugin вызывается при создании новой копии плагина. }

{$ifdef Far3}
function OpenW(var AInfo :TOpenInfo): THandle; stdcall;
{$else}
function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
{$endif Far3}
var
  Msg: array[0..6] of PFarChar;
begin
  Msg[0]:= GetMsg(MTitle);
  Msg[1]:= GetMsg(MMessage1);
  Msg[2]:= GetMsg(MMessage2);
  Msg[3]:= GetMsg(MMessage3);
  Msg[4]:= GetMsg(MMessage4);
  Msg[5]:= #01#00;                   // separator line
  Msg[6]:= GetMsg(MButton);

 {$ifdef Far3}
  FARAPI.Message(cPluginID,                       // PluginID
                 cDlgID,                          // DialogID
                 FMSG_WARNING or FMSG_LEFTALIGN,  // Flags
                'Contents',                       // HelpTopic
                 Pointer(@Msg),                   // Items
                 7,                               // ItemsNumber
                 1);                              // ButtonsNumber
 {$else}
  FARAPI.Message(FARAPI.ModuleNumber,             // PluginNumber
                 FMSG_WARNING or FMSG_LEFTALIGN,  // Flags
                'Contents',                       // HelpTopic
                 Pointer(@Msg),                   // Items
                 7,                               // ItemsNumber
                 1);                              // ButtonsNumber
 {$endif Far3}

  Result := INVALID_HANDLE_VALUE;
end;


exports
 {$ifdef Far3}
  GetGlobalInfow,
 {$endif Far3}
  SetStartupInfow,
  GetPluginInfow,
 {$ifdef Far3}
  Openw;
 {$else}
  OpenPluginw;
 {$endif Far3}


begin
end.

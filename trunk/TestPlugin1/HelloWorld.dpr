(*
  "Hello, World!" - демонстрационный плагин.
  Copyright (c) 2000-2006, [ FAR group ]
  Delphi version copyright (c) 2000, Vasily V. Moshninov
*)

{$AppType Console}
{$Imagebase $50000000}

library HelloWorld;

uses windows, PluginW;

type
  TMessages = (MTitle, MMessage1, MMessage2, MMessage3, MMessage4, MButton);

var
  FARAPI: TPluginStartupInfo;

(*
 Функция GetMsg возвращает строку сообщения из языкового файла.
 А это надстройка над Info.GetMsg для сокращения кода :-)
*)
function GetMsg(MsgId: TMessages): PFarChar;
begin
  result:= FARAPI.GetMsg(FARAPI.ModuleNumber, integer(MsgId));
end;

(*
Функция SetStartupInfo вызывается один раз, перед всеми
другими функциями. Она передается плагину информацию,
необходимую для дальнейшей работы.
*)
procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
begin
  Move(psi, FARAPI, SizeOf(FARAPI));
end;

(*
Функция GetPluginInfo вызывается для получения основной
  (general) информации о плагине
*)
var
  PluginMenuStrings: array[0..0] of PFarChar;

procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
begin
  pi.StructSize:= SizeOf(pi);
  pi.Flags:= PF_EDITOR;

  PluginMenuStrings[0]:= GetMsg(MTitle);
  pi.PluginMenuStrings:= @PluginMenuStrings;
  pi.PluginMenuStringsNumber:= 1;
end;

(*
  Функция OpenPlugin вызывается при создании новой копии плагина.
*)
function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
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

  FARAPI.Message(FARAPI.ModuleNumber,             // PluginNumber
                 FMSG_WARNING or FMSG_LEFTALIGN,  // Flags
                'Contents',                       // HelpTopic
                 @Msg,                            // Items
                 7,                               // ItemsNumber
                 1);                              // ButtonsNumber

  result:= INVALID_HANDLE_VALUE;
end;

exports
  SetStartupInfoW,
  GetPluginInfoW,
  OpenPluginW;

  
begin
end.

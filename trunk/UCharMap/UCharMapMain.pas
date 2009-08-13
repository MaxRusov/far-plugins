{$I Defines.inc}
{$Typedaddress Off}

unit UCharMapMain;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,

    PluginW,
    FarCtrl,
    UCharMapCtrl,
    UCharMapDlg;


  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  procedure ExitFARW; stdcall;
  function OpenPluginW(OpenFrom :integer; Item :TIntPtr): THandle; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('Unicode CharMap', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;

 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := $02F40200;  { Need 2.0.756 }
//  Result := $03150200;  { Need 2.0.789 }
    Result := $03E30200;  { Need 2.0.995 }   { »зменена TWindowInfo }
  end;


  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    FRegRoot := psi.RootKey;
    FModuleName := psi.ModuleName;

    ReadSettings;
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;

  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= {PF_PRELOAD or} PF_EDITOR or PF_VIEWER or PF_DIALOG;

    PluginMenuStrings[0]:= GetMsg(strTitle);
    pi.PluginMenuStrings:= @PluginMenuStrings;
    pi.PluginMenuStringsNumber:= 1;

    pi.CommandPrefix := PFarChar(CmdPrefix);  
  end;


  procedure ExitFARW; stdcall;
  begin
//  Trace('ExitFAR');
  end;


  function OpenPluginW(OpenFrom :integer; Item :TIntPtr): THandle; stdcall;
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


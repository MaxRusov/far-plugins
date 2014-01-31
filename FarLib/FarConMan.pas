{$I Defines.inc}

unit FarConMan;

{******************************************************************************}
{* (c) 2007-2009 Max Rusov                                                    *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Поддержка ConMan/ConEmu                                                    *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixStrings;

  var
    ConManDetected :Boolean;

  function CheckConEmuWnd :THandle;

  procedure ConManClearTitle(var ATitle :TString);

  function ConManIsActiveConsole :Boolean;

  function WindowIsChildOf(AWnd, AOwner :HWnd) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  function WindowIsChildOf(AWnd, AOwner :HWnd) :Boolean;
  begin
    while AWnd <> 0 do begin
      if AWnd = AOwner then begin
        Result := True;
        Exit;
      end;
      AWnd := GetParent(AWnd);
    end;
    Result := False;
  end;


 {-----------------------------------------------------------------------------}
 { ConEmu support                                                              }

(*
  procedure DetectConMan;
  var
    vHandle :THandle;
  begin
    vHandle := GetModuleHandle('infis.dll');
    if vHandle <> 0 then begin
     {$ifdef bTrace}
      Trace('Run under ConMan...');
     {$endif bTrace}
      IsConsoleActive := GetProcAddress( vHandle, 'IsConsoleActive' );
      ConManDetected := Assigned(IsConsoleActive);
    end;
  end;
*)

  function CheckConEmuWnd :THandle;
  var
    vDLLHandle :THandle;
    vGetFarHWND :function :HWND; stdcall;

    vBuf :array[0..255] of TChar;
    vLen, vRes :Integer;
    vHandle :THandle;
  begin
    Result := 0;

   {$ifdef b64}
    vDLLHandle := GetModuleHandle('conemu.x64.dll');
   {$else}
    vDLLHandle := GetModuleHandle('conemu.dll');
   {$endif b64}
    if vDLLHandle <> 0 then begin
//    Trace('ConEmu detected...');
      vGetFarHWND := GetProcAddress( vDLLHandle, 'GetFarHWND' );
      if Assigned(vGetFarHWND) then begin
//      Trace('GetFarHWND found...');
        Result := vGetFarHWND;
       {$ifdef bTrace}
        TraceF('ConEmu.dll: GetFarHWND=%d', [Result]);
       {$endif bTrace}
        Exit;
      end;
    end;

    vLen := GetEnvironmentVariable('ConEmuHWND', vBuf, High(vBuf));
    if vLen > 0 then begin
     {$ifdef bTrace}
      TraceF('Environment: ConEmuHWND=%s', [vBuf]);
     {$endif bTrace}
      Val(vBuf, vHandle, vRes);
      if vRes = 0 then
        Result := vHandle;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { ConMan support                                                              }

  procedure ConManClearTitle(var ATitle :TString);
  var
    vPos :Integer;
  begin
    if (ATitle <> '') and (ATitle[1] = '[') then begin
      vPos := ChrPos(']', ATitle);
      if vPos <> 0 then
        ATitle := Copy(ATitle, vPos + 2, MaxInt);
    end;
  end;



//type
//  PFarTitle = ^TFarTitle;
//  TFarTitle = packed record
//    Num    :DWORD;
//    Title  :array[0..Max_Path - 1] of Char;
//    Active :BOOL;
//  end;

  var
    MultiConDetected :Boolean;

//  GetConsoleTitles :function(ATitles :PFarTitle; var ANumber :DWORD) :BOOL;
//  ActivateConsole :function(ANumber :DWORD) :BOOL;
    IsConsoleActive :function :Boolean;


  procedure DetectMultiCon;
  var
    vDLLHandle :THandle;
  begin
   {$ifdef bTrace}
    Trace('Check for MultiCon...');
   {$endif bTrace}

    vDLLHandle := GetModuleHandle('infis.dll');
    if vDLLHandle <> 0 then begin
     {$ifdef bTrace}
      Trace('Run under ConMan...');
     {$endif bTrace}
      IsConsoleActive := GetProcAddress( vDLLHandle, 'IsConsoleActive' );
      ConManDetected := Assigned(IsConsoleActive);
    end;

    if not Assigned(IsConsoleActive) then begin
      vDLLHandle := GetModuleHandle('conemu.dll');
      if vDLLHandle <> 0 then begin
       {$ifdef bTrace}
        Trace('ConEmu.dll found...');
       {$endif bTrace}
        IsConsoleActive := GetProcAddress( vDLLHandle, 'IsConsoleActive' );
      end;
    end;
  end;


  function ConManIsActiveConsole :Boolean;
  begin
    if not MultiConDetected then begin
      DetectMultiCon;
      MultiConDetected := True;
    end;

    try
//    Trace('ConManIsActiveConsole...');

      if Assigned(IsConsoleActive) then begin
        Result := IsConsoleActive;
//      TraceF('IsConsoleActive: %d', [Byte(Result)]);
      end else
        Result := True;

    except
      { На случай выгрузки плагина ConEmu... }
      MultiConDetected := False;
      IsConsoleActive := nil;
      Result := True;
    end;
  end;


(*
initialization
  DetectConMan;
*)
end.

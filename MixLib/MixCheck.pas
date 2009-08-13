{$I Defines.inc}

unit MixCheck;

interface

  uses
    Windows,
    MixTypes,
    MixDebug;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  function IsMainInstance :Boolean;
  begin
   {$ifdef bDLLDebug}
    Result := True;
   {$else}

   {$ifdef bFreePascal}
    Result := not IsLibrary;
   {$else}
    Result := HInstance = DWORD(MainInstance);
   {$endif bFreePascal}

   {$endif bDLLDebug}
  end;


 {$ifdef bTrace}

  function GetModuleName(Module :HMODULE) :TString;
  var
    ModName: array[0..MAX_PATH] of TChar;
  begin
    SetString(Result, ModName, GetModuleFileName(Module, ModName, High(ModName)+1));
  end;


  function GetImageBase :Pointer;
  var
    vPtr :Pointer;
    vMemInfo :TMemoryBasicInformation;
  begin
   {$ifdef bFreePascal}
    vPtr := @move;
   {$else}
    vPtr := @TextStart;
   {$endif bFreePascal}
    VirtualQuery(vPtr, vMemInfo, SizeOf(vMemInfo));
    Result := vMemInfo.AllocationBase;
  end;


  function GetVersionStr(const AKey :TString) :TString;
  var
    vName, vBuf, vKey :TString;
    vPtr  :Pointer;
    vSize :DWORD;
    vTemp :DWORD;
  begin
    Result := '';
    vName := GetModuleName(HInstance);
    vSize := GetFileVersionInfoSize( PTChar(vName), vTemp);
    if vSize > 0 then begin
      SetLength(vBuf, vSize);
      GetFileVersionInfo( PTChar(vName), vTemp, vSize, PTChar(vBuf));
      vKey := '\StringFileInfo\041904E3\' + AKey;
      if VerQueryValue(PTChar(vBuf), PTChar(vKey), vPtr, vSize) then
        Result := PTChar(vPtr);
    end;
  end;


  function GetVersionNumber :TString;
  begin
    Result := GetVersionStr('FileVersion');
  end;


  function GetProductName :TString;
  begin
    Result := GetVersionStr('ProductName');
  end;


  function MemLimitGB :TInteger;
  var
    vPtr :Pointer;
  begin
    Result := 0;
    vPtr := VirtualAlloc(nil, 1, MEM_RESERVE or MEM_TOP_DOWN, PAGE_READWRITE);
    if vPtr <> nil then begin
      Result := Round(TCardinal(vPtr) / (1024 * 1024 * 1024));
      VirtualFree(vPtr, 0, MEM_RELEASE);
    end;
  end;


  function Ptr2Hex(APtr :Pointer) :TString;
  const
    HexChars :array[0..15] of TChar = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
  var
    I :TInteger;
    N :TCardinal;
    D :Byte;
  begin
    SetString(Result, nil, SizeOf(Pointer) * 2);
    N := TCardinal(APtr);
    for I := SizeOf(Pointer) * 2 downto 1 do begin
      D := N and $F;
      N := N shr 4;
      Result[I] := HexChars[D];
    end;
  end;


  procedure TraceInitInfo;
  var
    vStr, vStr1 :TString;
(*  vManagerName, vModuleName :TString;
    vDebugMode :Boolean; *)
    vPtr :PTChar;
  begin
//  if IsMainInstance then begin
//    OpenDbWin;
//    ClearTrace;
//  end;

    vStr := '';
    vStr1 := GetVersionNumber;
    if vStr1 <> '' then
      vStr := 'ver: ' + vStr1;
    vStr1 := GetProductName;
    if vStr1 <> '' then
      vStr := vStr1 + ', ' + vStr;
    if vStr <> '' then
      vStr := ' (' + vStr + ')';

    Trace('"' + GetModuleName(HInstance) + '"' + vStr);
//  vStr := 'PID: ' + StrInt(Integer(GetCurrentProcessID)) + ', Addr: ' + StrPtr(GetImageBase) + ', ';
    vStr := 'Addr: ' + Ptr2Hex(GetImageBase) + ', ';

(*  if IsWOW64 then
      vStr := vStr + 'WOW64 ';  *)

   {$ifdef bFreePascal}

   {$ifdef b64}
    vStr := vStr + 'FreePascal64 ';
   {$else}
    vStr := vStr + 'FreePascal ';
   {$endif b64}

   {ifopt O+ - не работает}
   {$ifdef bOptimization}
    vStr := vStr + 'Optimize ';
   {$endif bOptimization}

   {$else}

   {$ifdef Ver100}
    vStr := vStr + 'Delphi3 ';
   {$endif Ver100}

   {$ifdef Ver120}
    vStr := vStr + 'Delphi4 ';
   {$endif Ver120}

   {$ifdef Ver130}
    vStr := vStr + 'Delphi5 ';
   {$endif Ver130}

   {$ifdef Ver140}
    vStr := vStr + 'Delphi6 ';
   {$endif Ver140}

   {$ifdef Ver150}
    vStr := vStr + 'Delphi7 ';
   {$endif Ver150}

   {$ifdef Ver170}
    vStr := vStr + 'Delphi9 ';
   {$endif Ver170}

   {$ifdef Ver180}
    vStr := vStr + 'Delphi10 ';
   {$endif Ver180}

   {$ifopt O+}
    vStr := vStr + 'Optimize ';
   {$endif O+}

   {$endif bFreePascal}

   {$ifopt W+}
    vStr := vStr + 'Frames ';
   {$endif W+}

   {$ifopt C+}
    vStr := vStr + 'Asserts ';
   {$endif C+}

   {$ifdef bUnicode}
    vStr := vStr + 'Unicode ';
   {$endif bUnicode}

    Delete(vStr, Length(vStr), 1);
    Trace('(' + vStr + ')');

    if IsMainInstance then begin
(*
      GetMemManagerInfo(vManagerName, vModuleName, vDebugMode);
      vStr := 'Memory Manager: ' + vManagerName;
      if vModuleName <> '' then
        vStr := vStr + ' (' + vModuleName + ')';
      vStr := vStr + ' ' + StrInt(MemLimitGB) + 'GB';

      if vDebugMode then
        vStr := vStr + ' (DebugMode)';
      Trace(vStr);
      ReportDebugManager;
*)

      vPtr := GetCommandLine;
      if vPtr <> nil then begin
        if vPtr^ = '"' then begin
          Inc(vPtr);
          while (vPtr^ <> #0) and (vPtr^ <> '"') do
            Inc(vPtr);
          if vPtr^ <> #0 then
            Inc(vPtr);
        end else
        begin
          while (vPtr^ <> #0) and (vPtr^ <> ' ') do
            Inc(vPtr);
        end;

        while (vPtr^ <> #0) and (vPtr^ = ' ') do
          Inc(vPtr);

        if vPtr^ <> #0 then begin
          vStr := vPtr;
          Trace('Command line: ' + vStr);
        end;
      end;

(*    if IsDebuggerPresent then
        Trace('Run under debugger.', LoadInfoTraceClass); *)
    end;
  end;


  procedure TraceDoneInfo;
  begin
    Trace('"' + GetModuleName(HInstance) + '" finished');
  end;

 {$endif bTrace}


initialization
begin
 {$ifdef bTrace}
  TraceInitInfo;
 {$endif bTrace}
end;

finalization
begin
 {$ifdef bTrace}
  TraceDoneInfo;
 {$endif bTrace}
end;

end.

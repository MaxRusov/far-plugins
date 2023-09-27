{$I Defines.inc}

unit FarHintsVerInfoMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    FarHintsAPI;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  type
    TStrMessage = (
      strName,
      strType,
      strModified,
      strSize,
      strDescription,
      strCopyright,
      strVersion
    );


  function StrLICompW(const Str1, Str2 :PWideChar; MaxLen :Cardinal) :Integer;
  begin
    Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, Str1, MaxLen, Str2, MaxLen) - 2;
  end;


  type
    LANGANDCODEPAGE = packed record
      wLanguage :Word;
      wCodePage :Word;
    end;

  type
    TPluginObject = class(TInterfacedObject, IHintPlugin)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

    private
      FAPI :IFarHintsApi;

      function GetMsg(AIndex :TStrMessage) :WideString;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vBuf :PWideChar;
    vSize :DWORD;
    vLang :TString;
(*
    procedure LocDetectLang;
    var
      vLen :UINT;
      vCP  :^LANGANDCODEPAGE;
    begin
      if VerQueryValue(vBuf, '\VarFileInfo\Translation', Pointer(vCP), vLen) then
        vLang := FAPI.Format('%.4x%.4x', [vCP.wLanguage, vCP.wCodePage]);
    end;
*)

    procedure LocDetectLang;
    const
      cStrInfo = 'StringFileInfo';
    var
      vLen :UINT;
      vCP  :^LANGANDCODEPAGE;
      vPtr, vEnd :PWideChar;
    begin
      { Ищем сканированием, потому что иногда Translation не совпадает с StringInfo }
      vPtr := vBuf;
      vEnd := vBuf + (vSize div SizeOf(WideChar)) - Length(cStrInfo) - 4 - 8;
      while vPtr < vEnd do begin
        if StrLICompW(vPtr, cStrInfo, Length(cStrInfo)) = 0 then begin
          Inc(vPtr, Length(cStrInfo) + 4);
          SetString(vLang, vPtr, 8);
          Exit;
        end;
        Inc(vPtr);
      end;

      { Не нашли сканированием (возможно 16-ти разрядная программа), попробуем через Translation}
      if VerQueryValue(vBuf, '\VarFileInfo\Translation', Pointer(vCP), vLen) then
        vLang := FAPI.Format('%.4x%.4x', [vCP.wLanguage, vCP.wCodePage]);
    end;

    procedure LocAdd(const APrompt, AKey :WideString);
    var
      vKey :TString;
      vStr :PTChar;
      vLen :UINT;
    begin
      vKey := '\StringFileInfo\' + vLang + '\' + AKey;
      if VerQueryValue(vBuf, PTChar(vKey), Pointer(vStr), vLen) then
        AItem.AddStringInfo(APrompt, vStr);
    end;

    procedure VerAdd(const APrompt: WideString; const MS, LS: DWORD);
    begin
      if (MS or LS) <> 0 then
        AItem.AddStringInfo(APrompt,
          FAPI.Format('%d.%d.%d.%d', [HiWord(MS), LoWord(MS), HiWord(LS), Loword(LS)]));
    end;

  type
    PFFI = ^TVSFixedFileInfo;

  var
    vName :TString;
    vTemp :DWORD;
    vFixIn: PFFI;
    vFixLen: UINT;
  begin
    Result := False;
    vName := AItem.FullName;
    vSize := GetFileVersionInfoSize( PTChar(vName), vTemp);
    if vSize > 0 then begin
      GetMem(vBuf, vSize);
      try
        GetFileVersionInfo( PTChar(vName), vTemp, vSize, vBuf);
        LocDetectLang;

        AItem.AddStringInfo(GetMsg(strName), AItem.Name);

        if VerQueryValue(vBuf, '\', Pointer(vFixIn), vFixLen) then
          with vFixIn^ do
            VerAdd(GetMsg(strVersion), dwFileVersionMS, dwFileVersionLS);

        if vLang <> '' then begin
          LocAdd(GetMsg(strDescription), 'FileDescription');
          LocAdd(GetMsg(strCopyright), 'LegalCopyright');
//        LocAdd(GetMsg(strVersion), 'FileVersion');
//        LocAdd('CompanyName');
//        LocAdd('OriginalFilename');
//        LocAdd('InternalName');
//        LocAdd('ProductName');
//        LocAdd('ProductVersion');
        end;

        AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
        AItem.AddInt64Info(GetMsg(strSize), AItem.Size);

        Result := True;

      finally
        FreeMem(vBuf);
      end;
    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;

  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
  end;


  function TPluginObject.GetMsg(AIndex :TStrMessage) :WideString;
  begin
    Result := FAPI.GetMsg(Self, Byte(AIndex));
  end;

 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.

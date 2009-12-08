{$I Defines.inc}

unit FarHintsProcessMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    ShellAPI,
    MixTypes,
    FarHintsAPI;


  var
    FPluginTitles :TString = 'Process list;Список процессов';


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  type
    TStrMessage = (
      strProcess,
      strFullPath,
      strDescription,
      strCompany,
      strCopyright,
      strUser
    );


  {$ifdef bFreePascal}
   {$PACKRECORDS C}
  {$endif bFreePascal}

  type
    PProcessData = ^TProcessData;
    TProcessData = record
      FSize    :Cardinal;
      FWnd     :THandle;
      FPID     :Cardinal;
      FParent  :Cardinal;
      FPrBase  :Cardinal;
      FAppType :Integer;
     {$ifdef bUnicodeFar}
      FPath    :array[0..MAX_PATH - 1] of WideChar;
     {$else}
      FPath    :array[0..MAX_PATH - 1] of AnsiChar;
     {$endif bUnicodeFar}
    end;


    LANGANDCODEPAGE = packed record
      wLanguage :Word;
      wCodePage :Word;
    end;


  function StrMatch(const ATitle, AMasks :TString) :Boolean;
  begin
    Result := Pos(ATitle, AMasks) <> 0;
  end;


  function FileExists(const aFileName :TString) :Boolean;
  var
    vCode :DWORD;
  begin
    vCode := GetFileAttributes(PTChar(AFileName));
    Result := (vCode <> DWORD(-1)) and (vCode and FILE_ATTRIBUTE_DIRECTORY = 0);
  end;


  function GetFileIcon(const AName :TString) :HIcon;
  var
    vInfo :SHFILEINFO;
  begin
    FillChar(vInfo, SizeOf(vInfo), 0);
    SHGetFileInfo( PTChar(AName), 0, vInfo, SizeOf(vInfo), {SHGFI_TYPENAME or} SHGFI_ICON {or SHGFI_SMALLICON} {or SHGFI_SHELLICONSIZE} or SHGFI_LARGEICON);
//  if vInfo.szTypeName[0] <> #0 then
//    AItem.AddStringInfo(GetMsgStr(strType), vInfo.szTypeName);
    Result := vInfo.hIcon;
  end;


 {-----------------------------------------------------------------------------}

  type
    TPluginObject = class(TInterfacedObject, IHintPlugin, IHintPluginDraw)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

    private
      FAPI :IFarHintsApi;

      FIcon :HIcon;

      function GetMsg(AIndex :TStrMessage) :TString;
      function GetFileVersion(const AName :TString; var ADescr, ACompany, ACopyright :TString) :Boolean;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
    AInfo.Flags := PF_ProcessPluginItems;
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vData :PProcessData;
    vPath, vDescr, vCompany, vCopyright :TString;
  begin
    Result := False;
    vData := Pointer(AItem.FarItem.UserData);
    if StrMatch(AItem.PluginTitle, FPluginTitles) and (vData <> nil) then begin
      vPath := vData.FPath;

      FIcon := 0;
      if (vPath <> '') and FileExists(vPath) then begin
        FIcon := GetFileIcon(vPath);
        GetFileVersion(vPath, vDescr, vCompany, vCopyright);
      end;

      if FIcon <> 0 then begin
        AItem.IconWidth := GetSystemMetrics(SM_CXICON);
        AItem.IconHeight := GetSystemMetrics(SM_CYICON);
      end;

//    AItem.AddStringInfo('Process', AItem.Name + ' (pid: ');
//    AItem.AddIntInfo('PID', vData.FPID);
      AItem.AddStringInfo(GetMsg(strProcess), FAPI.Format('%s (pid: %d)', [AItem.Name, vData.FPID]));
      if vPath <> '' then
        AItem.AddStringInfo(GetMsg(strFullPath), vPath );
      if vDescr <> '' then
        AItem.AddStringInfo(GetMsg(strDescription), vDescr );
      if vCompany <> '' then
        AItem.AddStringInfo(GetMsg(strCompany), vCompany );
//    if vCopyright <> '' then
//      AItem.AddStringInfo(GetMsg(strCopyright), vCopyright );

      AItem.AddStringInfo(GetMsg(strUser), AItem.FarItem.Owner);

      Result := True;
    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;

  
  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
    if FIcon <> 0 then begin
      DestroyIcon(FIcon);
      FIcon := 0;
    end;
  end;


  procedure TPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem);
  begin
    if FIcon <> 0 then
      DrawIconEx(ADC, ARect.Left, ARect.Top, FIcon, AItem.IconWidth, AItem.IconHeight, 0, 0, DI_NORMAL)
  end;



  function TPluginObject.GetMsg(AIndex :TStrMessage) :TString;
  begin
    Result := FAPI.GetMsg(Self, Byte(AIndex));
  end;


  function TPluginObject.GetFileVersion(const AName :TString; var ADescr, ACompany, ACopyright :TString) :Boolean;
  var
    vBuf :PWideChar;
    vLang :TString;

    procedure LocDetectLang;
    var
      vLen :UINT;
      vCP  :^LANGANDCODEPAGE;
    begin
      if VerQueryValue(vBuf, '\VarFileInfo\Translation', Pointer(vCP), vLen) then
        vLang := FAPI.Format('%.4x%.4x', [vCP.wLanguage, vCP.wCodePage]);
    end;

    function LocGet(const AKey :TString) :TString;
    var
      vKey :TString;
      vStr :PTChar;
      vLen :UINT;
    begin
      vKey := '\StringFileInfo\' + vLang + '\' + AKey;
      if VerQueryValue(vBuf, PTChar(vKey), Pointer(vStr), vLen) then
        Result := vStr;
    end;

  var
    vSize, vTemp :DWORD;
  begin
    Result := False;
    vSize := GetFileVersionInfoSize( PTChar(AName), vTemp);
    if vSize > 0 then begin
      GetMem(vBuf, vSize);
      try
        GetFileVersionInfo( PTChar(AName), vTemp, vSize, vBuf);
        LocDetectLang;

        ADescr := LocGet('FileDescription');
        ACompany := LocGet('CompanyName');
        ACopyright := LocGet('LegalCopyright');

        Result := True;

      finally
        FreeMem(vBuf);
      end;
    end;
  end;

 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.

{$I Defines.inc}

unit FontsMain;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* FontMan Far plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,

    Far_API,
    FarCtrl,

    FontsCtrl,
    FontsClasses,
    FontsConfig;


 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
  procedure ClosePluginW(AHandle :THandle); stdcall;
  procedure GetOpenPluginInfoW(AHandle :THandle; var AInfo :TOpenPluginInfo); stdcall;
  function GetFindDataW(AHandle :THandle; var AItems :PPluginPanelItem; var ACount :Integer; AMode :Integer) :boolean; stdcall;
  function FreeFindDataW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer) :boolean; stdcall;
  function SetDirectoryW(AHandle :THandle; ADir :PFarChar; AMode :Integer) :Boolean; stdcall;
  function GetFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; var ADestPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
  function PutFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; ASrcPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
  function DeleteFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AOpMode :Integer) :Integer; stdcall;
  function ProcessKeyW(AHandle :THandle; AKey, AShiftState :Integer) :Integer; stdcall;
  function ProcessEventW(AHandle :THandle; AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
  procedure ClosePlugin(AHandle :THandle); stdcall;
  procedure GetOpenPluginInfo(AHandle :THandle; var AInfo :TOpenPluginInfo); stdcall;
  function GetFindData(AHandle :THandle; var AItems :PPluginPanelItem; var ACount :Integer; AMode :Integer) :boolean; stdcall;
  function FreeFindData(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer) :boolean; stdcall;
  function SetDirectory(AHandle :THandle; ADir :PFarChar; AMode :Integer) :Boolean; stdcall;
  function GetFiles(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; ADestPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
  function PutFiles(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; AOpMode :Integer) :Integer; stdcall;
  function DeleteFiles(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AOpMode :Integer) :Integer; stdcall;
  function ProcessKey(AHandle :THandle; AKey, AShiftState :Integer) :Integer; stdcall;
  function ProcessEvent(AHandle :THandle; AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$endif bUnicodeFar}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  var
    FOpenLock :Boolean;


  function GetCurrentItem(AHandle :THandle) :TString;
 {$ifdef bUnicode}
  var
    vItem :PPluginPanelItem;
  begin
    vItem := FarPanelItem(AHandle, FCTL_GETCURRENTPANELITEM, 0);
    try
      Result := vItem.FindData.cFileName;
    finally
      MemFree(vItem);
    end;
 {$else}
  var
    vInfo :TPanelInfo;
  begin
    Result := '';
    if FARAPI.Control(AHandle, FCTL_GETPANELINFO, @vInfo) = 1 then begin
      if vInfo.CurrentItem < vInfo.ItemsNumber then
        Result := FarChar2Str(vInfo.PanelItems[vInfo.CurrentItem].FindData.cFileName);
    end;
 {$endif bUnicode}
  end;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage(GetMsgStr(strError), AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  function GetMinFarVersionW :Integer; stdcall;
  begin
//  Result := $02A80200; { Need 2.0.680 }
//  Result := $02F40200; { Need 2.0.756 }
    Result := $03150200; { Need 2.0.789 }
  end;
 {$endif bUnicodeFar}


 {$ifdef bUnicodeFar}
  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
 {$else}
  procedure SetStartupInfo(var psi: TPluginStartupInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('SetStartupInfo: Module=%d, RootKey=%s', [psi.ModuleNumber, psi.RootKey]);
    hModule := psi.ModuleNumber;
    Move(psi, FARAPI, SizeOf(FARAPI));
    Move(psi.fsf^, FARSTD, SizeOf(FARSTD));

    hStdIn := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

//  vRes := FARAPI.AdvControl(hModule, ACTL_GETFARVERSION, nil);

    FRegRoot := psi.RootKey;
    FModuleName := psi.ModuleName;

    ReadSettings;
  end;


  var
    PluginMenuStrings: array[0..0] of PFarChar;


 {$ifdef bUnicodeFar}
  procedure GetPluginInfoW(var pi: TPluginInfo); stdcall;
 {$else}
  procedure GetPluginInfo(var pi: TPluginInfo); stdcall;
 {$endif bUnicodeFar}
  begin
//  TraceF('GetPluginInfo: %s', ['']);
    pi.StructSize:= SizeOf(pi);
    pi.Flags:= 0;

    PluginMenuStrings[0] := GetMsg(strTitle);
    pi.PluginMenuStringsNumber := 1;
    pi.PluginMenuStrings := Pointer(@PluginMenuStrings);
    pi.CommandPrefix := cFontsPrefix;
  end;


 {$ifdef bUnicodeFar}
  function OpenPluginW(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$else}
  function OpenPlugin(OpenFrom: integer; Item: integer): THandle; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('OpenPlugin: %d, %d', [OpenFrom, Item]);
    Result := INVALID_HANDLE_VALUE;
    try
     {$ifndef bUnicode}
      SetFileApisToAnsi;
      try
     {$endif bUnicode}

      vPanel := NewFontsPanel;
      Result := vPanel.Number;
      FOpenLock := True;

     {$ifndef bUnicode}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicode}
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {$ifdef bUnicodeFar}
  procedure ClosePluginW(AHandle :THandle); stdcall;
 {$else}
  procedure ClosePlugin(AHandle :THandle); stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('ClosePlugin: %d', [AHandle]);
    vPanel := FindFontsPanel(AHandle);
    if vPanel <> nil then
      FreeFontsPanel(vPanel);
  end;


 {$ifdef bUnicodeFar}
  procedure GetOpenPluginInfoW(AHandle :THandle; var AInfo :TOpenPluginInfo); stdcall;
 {$else}
  procedure GetOpenPluginInfo(AHandle :THandle; var AInfo :TOpenPluginInfo); stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('GetOpenPluginInfo: %d', [AHandle]);
    AInfo.StructSize := SizeOf(AInfo);
    vPanel := FindFontsPanel(AHandle);
    if vPanel <> nil then begin
      AInfo.Flags := OPIF_ADDDOTS or OPIF_USEFILTER or OPIF_USEHIGHLIGHTING {OPIF_USEATTRHIGHLIGHTING};
      AInfo.CurDir := PTChar(vPanel.Path);
      AInfo.Format := cFontsPrefix;
      AInfo.PanelTitle := PTChar(vPanel.Title);

      if DefPanelMode <> 0 then
        AInfo.StartPanelMode := Byte('0') + DefPanelMode;

      LastAccessedPanel := vPanel;
    end;
  end;


 {$ifdef bUnicodeFar}
  function GetFindDataW(AHandle :THandle; var AItems :PPluginPanelItem; var ACount :Integer; AMode :Integer) :boolean; stdcall;
 {$else}
  function GetFindData(AHandle :THandle; var AItems :PPluginPanelItem; var ACount :Integer; AMode :Integer) :boolean; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('GetFindData: AMode=%d', [AMode]);
    Result := False;
    vPanel := FindFontsPanel(AHandle);
    if vPanel <> nil then begin
      vPanel.GetItems(AItems, ACount);
      FOpenLock := False;
      Result := True;
    end;
  end;

 {$ifdef bUnicodeFar}
  function FreeFindDataW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer) :boolean; stdcall;
 {$else}
  function FreeFindData(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer) :boolean; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('FreeFindData: ACount=%d', [ACount]);
    Result := False;
    vPanel := FindFontsPanel(AHandle);
    if vPanel <> nil then begin
      vPanel.FreeItems(AItems, ACount);
      Result := True;
    end;
  end;


 {$ifdef bUnicodeFar}
  function SetDirectoryW(AHandle :THandle; ADir :PFarChar; AMode :Integer) :Boolean; stdcall;
 {$else}
  function SetDirectory(AHandle :THandle; ADir :PFarChar; AMode :Integer) :Boolean; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('GetFindData: AMode=%d', [AMode]);
    Result := False;
    vPanel := FindFontsPanel(AHandle);
    if vPanel <> nil then
      Result := vPanel.SetDirectory(ADir);
  end;


 {$ifdef bUnicodeFar}
  function GetFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; var ADestPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
 {$else}
  function GetFiles(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; ADestPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    vName, vDest :TString;
    vPanel :TFontsPanel;
  begin
    Result := 0;
    try
     {$ifndef bUnicode}
      SetFileApisToAnsi;
      try
     {$endif bUnicode}
//    TraceF('GetFiles: ADestPath=%s, AOpMode=%d, API=%s', [ADestPath, AOpMode, StrIf(AreFileApisANSI, 'Ansi', 'OEM')]);

      vPanel := FindFontsPanel(AHandle);
      if vPanel <> nil then begin
        vDest := FarChar2Str(ADestPath);
        if (OPM_FIND or OPM_EDIT or OPM_VIEW or OPM_QUICKVIEW) and AOpMode <> 0 then begin
          vName := FarChar2Str(AItems.FindData.cFileName);
          vDest := AddFileName(vDest, vName);
          if vPanel.GetFontInfo(vName, vDest) then
            Result := 1;
        end else
          Result := vPanel.CopyFontsTo(AItems, ACount, vDest, AMove <> 0, OPM_SILENT and AOpMode <> 0);
      end;

     {$ifndef bUnicode}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicode}
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {$ifdef bUnicodeFar}
  function PutFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; ASrcPath :PFarChar; AOpMode :Integer) :Integer; stdcall;
 {$else}
  function PutFiles(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AMove :Integer; AOpMode :Integer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
    Result := 0;
    try
     {$ifndef bUnicode}
      SetFileApisToAnsi;
      try
     {$endif bUnicode}

      vPanel := FindFontsPanel(AHandle);
      if vPanel <> nil then
        Result := vPanel.InstallFontsFrom(AItems, ACount, AMove = 1);

     {$ifndef bUnicode}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicode}
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {$ifdef bUnicodeFar}
  function DeleteFilesW(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AOpMode :Integer) :Integer; stdcall;
 {$else}
  function DeleteFiles(AHandle :THandle; AItems :PPluginPanelItem; ACount :Integer; AOpMode :Integer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
    Result := 0;
    try
     {$ifndef bUnicode}
      SetFileApisToAnsi;
      try
     {$endif bUnicode}

      vPanel := FindFontsPanel(AHandle);
      if vPanel <> nil then
        Result := vPanel.DeleteFonts(AItems, ACount, OPM_SILENT and AOpMode <> 0);

     {$ifndef bUnicode}
      finally
        SetFileApisToOEM;
      end;
     {$endif bUnicode}
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {$ifdef bUnicodeFar}
  function ProcessKeyW(AHandle :THandle; AKey, AShiftState :Integer) :Integer; stdcall;
 {$else}
  function ProcessKey(AHandle :THandle; AKey, AShiftState :Integer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    vPanel :TFontsPanel;
  begin
//  TraceF('ProcessKey: Key=%d, Shift=%d', [AKey, AShiftState]);
    Result := 0;
    try
      vPanel := FindFontsPanel(AHandle);
      if vPanel <> nil then begin
        if AShiftState = PKF_CONTROL + PKF_ALT then begin
          Result := 1;
          case AKey of
            byte('1'):
              vPanel.SetGroupMode(1);
            byte('2'):
              vPanel.SetGroupMode(2);
          else
            Result := 0;
          end;
        end else
        if AShiftState = PKF_CONTROL then begin
          Result := 1;
          case AKey of
            byte('R'):
              vPanel.ReRead;
          else
            Result := 0;
          end;
        end else
        if AShiftState = PKF_SHIFT then begin
          Result := 1;
          case AKey of
            VK_F1:
              ConfigMenu(vPanel);
          else
            Result := 0;
          end;
        end else
        if AShiftState = 0 then begin
          Result := 1;
          case AKey of
            VK_Return:
              Result := vPanel.ClickItem(GetCurrentItem(AHandle));
          else
            Result := 0;
          end;
        end;
      end;
    except
      on E :Exception do
        HandleError(E);
    end;
  end;


 {$ifdef bUnicodeFar}
  function ProcessEventW(AHandle :THandle; AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$else}
  function ProcessEvent(AHandle :THandle; AEvent :Integer; AParam :Pointer) :Integer; stdcall;
 {$endif bUnicodeFar}
  var
    vInfo :TPanelInfo;
  begin
//  TraceF('ProcessEvent: AEvent=%d', [AEvent]);
    case AEvent of
      FE_CHANGEVIEWMODE:
        if not FOpenLock then begin
         {$ifdef bUnicode}
          FARAPI.Control(AHandle, FCTL_GetPanelInfo, 0, @vInfo);
         {$else}
          FARAPI.Control(AHandle, FCTL_GetPanelShortInfo, @vInfo);
         {$endif bUnicode}
          DefPanelMode := vInfo.ViewMode;
          WriteSettings;
        end;
    end;
    Result := 0;
  end;


end.


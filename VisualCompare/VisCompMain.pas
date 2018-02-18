{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}
{$Typedaddress Off}

unit VisCompMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarPlug,

    VisCompCtrl,
    VisCompFiles,
    VisCompTexts,
    VisCompPromptDlg,
    VisCompFilesDlg,
    VisCompTextsDlg,
    VisCompOptionsDlg;


  type
    TVisCompPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure GetInfo; override;

      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;
      function EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; override;

    private
      FPluginLock :Integer;
    end;


  function CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer; stdcall;
    { Экспорт, для межплагинного взаимодействия... }

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;
 

  function CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer;
    { Экспорт, для межплагинного взаимодействия... }
  begin
    try
      CompareTexts(AFileName1, AFileName2);
    except
      on E :Exception do
        HandleError(E);
    end;
    Result := 0;
  end;


  function MakeProvider(const AFolder :TString; ASide :Integer) :TDataProvider;
  begin
    if UpCompareSubStr(cSVNFakeDrive, AFolder) = 0 then
      Result := TSVNProvider.CreateEx(AFolder)
    else
    if UpCompareSubStr(cPlugFakeDrive, AFolder) = 0 then
      Result := TPluginProvider.CreateEx(AFolder, ASide)
    else
      Result := TFileProvider.CreateEx(AFolder);
  end;


  procedure CompareFolders2(const AFolder1, AFolder2 :TString);
  var
    vPath1, vPath2 :TString;
    vSource1, vSource2 :TDataProvider;
    vComp :TComparator;
    vSide :Integer;
  begin
    vSide  := FarPanelGetSide;

    vPath1 := RemoveBackSlash(AFolder1);
    if vPath1 = '' then
      vPath1 := GetPanelDir(vSide = 0);

    vPath2 := RemoveBackSlash(AFolder2);
    if vPath2 = '' then
      vPath2 := GetPanelDir(vSide <> 0);

    if not CompareDlg(vPath1, vPath2) then
      Exit;

    vSource1 := nil; vSource2 := nil; vComp := nil;
    try
      vSource1 := MakeProvider(vPath1, 0);
      vSource2 := MakeProvider(vPath2, 1);

      vComp := TComparator.CreateEx(vSource1, vSource2);
      vComp.CompareFolders;

      ShowFilesDlg(vComp);

    finally
      FreeObj(vComp);
      FreeObj(vSource1);
      FreeObj(vSource2);
    end
  end;


 {-----------------------------------------------------------------------------}
 { TVisCompPlug                                                                }
 {-----------------------------------------------------------------------------}

  procedure TVisCompPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
//  FID := cPluginID;
   {$endif Far3}

   {$ifdef Far3}
//  FMinFarVer := MakeVersion(3, 0, 2343);    { FCTL_GETPANELDIRECTORY/FCTL_SETPANELDIRECTORY }
//  FMinFarVer := MakeVersion(3, 0, 2572);    { Api changes }
//  FMinFarVer := MakeVersion(3, 0, 2851);    { LUA }
    FMinFarVer := MakeVersion(3, 0, 2927);    { Release }
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1573);    { ACTL_GETFARRECT }
   {$endif Far3}
  end;


  procedure TVisCompPlug.Startup; {override;}
  begin
    hStdin := GetStdHandle(STD_INPUT_HANDLE);
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

    { Получаем Handle консоли Far'а }
    hFarWindow := FarAdvControl(ACTL_GETFARHWND, nil);

    RestoreDefFilesColor;
    RestoreDefTextColor;

    ReadSetup;
    ReadSetupColors;
  end;


  procedure TVisCompPlug.GetInfo; {override;}
  begin
    FFlags := 0 {PF_EDITOR or PF_VIEWER or PF_DIALOG};

    FMenuStr := GetMsg(strTitle);
    FConfigStr := FMenuStr;
   {$ifdef Far3}
    FMenuID := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    FPrefix := cPlugMenuPrefix;
  end;


  procedure TVisCompPlug.Configure; {override;}
  begin
    OptionsDlg;
  end;


  function TVisCompPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;

    Inc(FPluginLock);
    try
      ReadSetup;
      ReadSetupColors;

      CompareFolders2('', '');

    finally
      Dec(FPluginLock);
    end;
  end;


  function TVisCompPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  var
    vStr1, vStr2 :TString;
  begin
    Result:= INVALID_HANDLE_VALUE;
    Inc(FPluginLock);
    try
      ReadSetup;
      ReadSetupColors;

      if (AStr <> nil) and (AStr^ <> #0) then begin
        vStr1 := FarExpandFileNameEx(ExtractParamStr(AStr));
        vStr2 := FarExpandFileNameEx(ExtractParamStr(AStr));

        if (vStr1 <> '') and WinFileExists(vStr1) and (vStr2 <> '') and WinFileExists(vStr2) then
          CompareTexts(vStr1, vStr2)
        else
          CompareFolders2(vStr1, vStr2);

      end else
        CompareFolders2('', '');

    finally
      Dec(FPluginLock);
    end;
  end;


  function TVisCompPlug.EditorEvent(AID :Integer; AEvent :Integer; AParam :Pointer) :Integer; {override;}
  var
    vPos :TEditorSetPosition;
  begin
    Result := 0;
    case AEvent of
      EE_READ:
        if GEditorTopRow <> -1 then begin
         {$ifdef Far3}
          vPos.StructSize := SizeOf(vPos);
         {$endif Far3}
          vPos.TopScreenLine := GEditorTopRow;
          vPos.CurLine := -1; vPos.CurPos := -1; vPos.CurTabPos := -1; vPos.LeftPos := -1; vPos.Overtype := -1;
          FarEditorControl(ECTL_SETPOSITION, @vPos);
          GEditorTopRow := -1;
        end;
    end;
  end;


end.

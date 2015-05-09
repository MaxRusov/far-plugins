{$I Defines.inc}
{$Typedaddress Off}

unit PlugInfoDlg;

{******************************************************************************}
{* (c) 2008-2012 Max Rusov                                                    *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Диалог информации о плагине                                                *}
{******************************************************************************}

interface

  uses
    Windows,
    ShellApi,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarDlg,

    PlugMenuCtrl,
    PlugMenuPlugs;


  procedure ViewPluginInfo(APlugin :TFarPlugin; ACommand :TFarPluginCmd);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  function ShellOpenEx(AWnd :THandle; const FName :TString) :Boolean;
  var
    vInfo :TShellExecuteInfo;
  begin
    FillChar(vInfo, SizeOf(vInfo), 0);
    vInfo.cbSize        := SizeOf(vInfo);
    vInfo.fMask         := SEE_MASK_INVOKEIDLIST;
    vInfo.Wnd           := AWnd {AppMainForm.Handle};
    vInfo.lpFile        := PTChar(FName);
    vInfo.lpVerb        := 'properties';
    vInfo.nShow         := SW_SHOW;
    Result := ShellExecuteEx(@vInfo);
  end;


 {-----------------------------------------------------------------------------}

  type
    TPlugProps = (
     {$ifdef Far3}
      ppTitle,
      ppDescr,
      ppAuthor,
      ppGUID,
      ppMenuGUID,
     {$endif Far3}

      ppVerinfo,
      ppCopyright,
      ppVersion,

      ppFileName,
      ppFolder,
      ppModified,

      ppEncoding,
      ppFlags,
      ppPrefixes
    );

  const
    IdFirstEdt  = 13{$ifdef Far3} + 5 {$endif};

  type
    FInfoDlg = class(TFarDialog)
    public
      constructor CreateEx(APlugin :TFarPlugin; ACommand :TFarPluginCmd);

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FPlugin  :TFarPlugin;
      FCommand :TFarPluginCmd;

      FPrompts :Array[TPlugProps] of TString;
      FDatas   :Array[TPlugProps] of TString;
    end;


  constructor FInfoDlg.CreateEx(APlugin :TFarPlugin; ACommand :TFarPluginCmd);
  begin
    FPlugin := APlugin;
    FCommand := ACommand;
    Create;
  end;


  procedure FInfoDlg.Prepare; {override;}
  const
    DY = 18 {$ifdef Far3} + 5 {$endif};
    cInfoType = DI_EDIT;
    cInfoFlags = DIF_READONLY;
  var
    I :TPlugProps;
    vDX1, vDX2, vDY1, vMaxWidth :Integer;
    vSize :TSize;
  begin
    FGUID := cPlugInfoID;
    vSize := FarGetWindowSize;
    vMaxWidth := vSize.CX - 4;

   {$ifdef Far3}
    FPrompts[ppTitle]     := GetMsg(strInfoTitle);
    FPrompts[ppDescr]     := GetMsg(strInfoDescription);
    FPrompts[ppAuthor]    := GetMsg(strInfoAuthor);
    FPrompts[ppGUID]      := GetMsg(strInfoGUID);
    FPrompts[ppMenuGUID]  := GetMsg(strInfoMenuGUID);
   {$endif Far3}

    FPrompts[ppVerinfo]   := GetMsg(strInfoDescr);
    FPrompts[ppCopyright] := GetMsg(strInfoCopyright);
    FPrompts[ppVersion]   := GetMsg(strInfoVersion);

    FPrompts[ppFileName]  := GetMsg(strInfoFileName);
    FPrompts[ppFolder]    := GetMsg(strInfoFolder);
    FPrompts[ppModified]  := GetMsg(strInfoModified);

    FPrompts[ppEncoding]  := GetMsg(strInfoEncoding);
    FPrompts[ppFlags]     := GetMsg(strInfoFlags);
    FPrompts[ppPrefixes]  := GetMsg(strInfoPrefixes);

   {$ifdef Far3}
    FDatas[ppTitle]     := FPlugin.PlugTitle;
    if FPlugin.PlugVerStr <> '' then
      FDatas[ppTitle] := FDatas[ppTitle] + ', ' + GetMsg(strVer) + ' ' + FPlugin.PlugVerStr;

    FDatas[ppDescr]     := FPlugin.PlugDescr;
    FDatas[ppAuthor]    := FPlugin.PlugAuthor;
    FDatas[ppGUID]      := GUIDToString (FPlugin.GUID);
    FDatas[ppMenuGUID]  := GUIDToString(FCommand.GUID);
   {$endif Far3}

    FDatas[ppVerinfo]   := FPlugin.Description;
    FDatas[ppCopyright] := FPlugin.Copyright;
    FDatas[ppVersion]   := FPlugin.Version;

    FDatas[ppFileName]  := ExtractFileName(FPlugin.FileName);
    FDatas[ppFolder]    := RemoveBackSlash(ExtractFilePath(FPlugin.FileName));
    FDatas[ppModified]  := DateTimeToStr(FPlugin.FileDate);

    FDatas[ppEncoding]  := StrIf(FPlugin.Unicode, 'Unicode', 'Ansi');
    FDatas[ppFlags]     := FPlugin.GetFlagsStrEx;
    FDatas[ppPrefixes]  := StrReplace(FPlugin.Prefixes, ':', ', ', [rfReplaceAll]);

    vDX1 := 0;
    for I := Low(TPlugProps) to High(TPlugProps) do
      vDX1 := IntMax(vDX1, Length(FPrompts[I]));

    for I := Low(TPlugProps) to High(TPlugProps) do
      FPrompts[I] := StrLeftAjust(FPrompts[I], vDX1) + ' :';
    Inc(vDX1, 2);

    vDX2 := 0;
    for I := Low(TPlugProps) to High(TPlugProps) do
      vDX2 := IntMax(vDX2, Length(FDatas[I]) + 1{Edit});

    FHeight := DY;
    FWidth := vDX1 + vDX2 + 11;
    if FWidth > vMaxWidth then begin
      FWidth := vMaxWidth;
      vDX2 := FWidth - vDX1 - 11;
    end;

    vDY1 := {$ifdef Far3} 6 {$else} 1 {$endif};
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1, FWidth-6, DY-2, 0, GetMsg(strPlugInfoTitle)),

       {$ifdef Far3}
        NewItemApi(DI_Text,      5,  2, 5+vDX1, -1,  0,  PTChar(FPrompts[ppTitle] ) ),
        NewItemApi(DI_Text,      5,  3, 5+vDX1, -1,  0,  PTChar(FPrompts[ppDescr] ) ),
        NewItemApi(DI_Text,      5,  4, 5+vDX1, -1,  0,  PTChar(FPrompts[ppAuthor]) ),
        NewItemApi(DI_Text,      5,  5, 5+vDX1, -1,  0,  PTChar(FPrompts[ppGUID]) ),
        NewItemApi(DI_Text,      5,  6, 5+vDX1, -1,  0,  PTChar(FPrompts[ppMenuGUID]) ),
       {$endif Far3}

        NewItemApi(DI_Text,      0,  vDY1+1, -1,     -1,  DIF_SEPARATOR or DIF_CENTERTEXT, GetMsg(strVersionInfo) ),
        NewItemApi(DI_Text,      5,  vDY1+2, 5+vDX1, -1,  0,  PTChar(FPrompts[ppVerinfo]  ) ),
        NewItemApi(DI_Text,      5,  vDY1+3, 5+vDX1, -1,  0,  PTChar(FPrompts[ppCopyright]) ),
        NewItemApi(DI_Text,      5,  vDY1+4, 5+vDX1, -1,  0,  PTChar(FPrompts[ppVersion]  ) ),

        NewItemApi(DI_Text,      0,  vDY1+5, -1,     -1,  DIF_SEPARATOR or DIF_CENTERTEXT, GetMsg(strFileInfo) ),
        NewItemApi(DI_Text,      5,  vDY1+6, 5+vDX1, -1,  0,  PTChar(FPrompts[ppFileName]) ),
        NewItemApi(DI_Text,      5,  vDY1+7, 5+vDX1, -1,  0,  PTChar(FPrompts[ppFolder]  ) ),
        NewItemApi(DI_Text,      5,  vDY1+8, 5+vDX1, -1,  0,  PTChar(FPrompts[ppModified]) ),

        NewItemApi(DI_Text,      0,  vDY1+9, -1,     -1,  DIF_SEPARATOR or DIF_CENTERTEXT, ''),
        NewItemApi(DI_Text,      5,  vDY1+10, 5+vDX1, -1,  0,  PTChar(FPrompts[ppEncoding]) ),
        NewItemApi(DI_Text,      5,  vDY1+11, 5+vDX1, -1,  0,  PTChar(FPrompts[ppFlags]   ) ),
        NewItemApi(DI_Text,      5,  vDY1+12, 5+vDX1, -1,  0,  PTChar(FPrompts[ppPrefixes]) ),

       {$ifdef Far3}
        NewItemApi(cInfoType, 6+vDX1,  2, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  3, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  4, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  5, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  6, vDX2, -1,  cInfoFlags,  '' ),
       {$endif Far3}

        NewItemApi(cInfoType, 6+vDX1,  vDY1+2, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  vDY1+3, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  vDY1+4, vDX2, -1,  cInfoFlags,  '' ),

        NewItemApi(cInfoType, 6+vDX1,  vDY1+6, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  vDY1+7, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  vDY1+8, vDX2, -1,  cInfoFlags,  '' ),

        NewItemApi(cInfoType, 6+vDX1,  vDY1+10, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  vDY1+11, vDX2, -1,  cInfoFlags,  '' ),
        NewItemApi(cInfoType, 6+vDX1,  vDY1+12, vDX2, -1,  cInfoFlags,  '' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR, ''),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strButClose)),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strButPlugring)),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strButProps))
      ],
      @FItemCount
    );

//  FHelpTopic := 'PluginInfo';
  end;


  procedure FInfoDlg.InitDialog; {override;}
  var
    I :TPlugProps;
  begin
    SendMsg(DM_SetFocus, FItemCount - 3, 0);
    for I := Low(TPlugProps) to High(TPlugProps) do
      SetText(IdFirstEdt + byte(I), FDatas[I]);
  end;


  function FInfoDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function FInfoDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 = FItemCount-2 {IdButPlugring} then begin
          FPlugin.GotoPluring
        end else
        if Param1 = FItemCount-1 {IdButProp} then begin
          ShellOpenEx(hFarWindow, FPlugin.FileName)
        end else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ViewPluginInfo(APlugin :TFarPlugin; ACommand :TFarPluginCmd);
  var
    vDlg :FInfoDlg;
  begin
    vDlg := FInfoDlg.CreateEx(APlugin, ACommand);
    try
      if vDlg.Run = -1 then
        Exit;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}
{$Typedaddress Off}

unit PlugInfoDlg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
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
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,

    PlugMenuCtrl,
    PlugMenuPlugs;

    
  procedure ViewPluginInfo(APlugin :TFarPlugin);


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

  const
    cProps = 9;

    IdFileName  = 12;
    IdFolder    = IdFileName+1;
    IdModified  = IdFileName+2;
    IdDescr     = IdFileName+3;
    IdCopyright = IdFileName+4;
    IdVersion   = IdFileName+5;
    IdMode      = IdFileName+6;
    IdFlags     = IdFileName+7;
    IdPrefixes  = IdFileName+8;

    IdButOk     = IdFileName+10;
    IdButProp   = IdFileName+11;


  type
    FInfoDlg = class(TFarDialog)
    public
      constructor CreateEx(APlugin :TFarPlugin);
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FPlugin :TFarPlugin;

      FPrompts :Array[0..cProps - 1] of TString;
      FDatas   :Array[0..cProps - 1] of TString;
    end;


  constructor FInfoDlg.CreateEx(APlugin :TFarPlugin);
  begin
    FPlugin := APlugin;
    Create;
  end;


  procedure FInfoDlg.Prepare; {override;}
  const
    DY = 17;
  var
    I :Integer;
    vDX1, vDX2, vMaxWidth :Integer;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;
    vMaxWidth := vSize.CX - 4;

    FPrompts[0] := GetMsg(strInfoFileName);
    FPrompts[1] := GetMsg(strInfoFolder);
    FPrompts[2] := GetMsg(strInfoModified);
    FPrompts[3] := GetMsg(strInfoDescr);
    FPrompts[4] := GetMsg(strInfoCopyright);
    FPrompts[5] := GetMsg(strInfoVersion);
    FPrompts[6] := GetMsg(strInfoEncoding);
    FPrompts[7] := GetMsg(strInfoFlags);
    FPrompts[8] := GetMsg(strInfoPrefixes);

    FDatas[0] := ExtractFileName(FPlugin.FileName);
    FDatas[1] := RemoveBackSlash(ExtractFilePath(FPlugin.FileName));
    FDatas[2] := DateTimeToStr(FPlugin.FileDate);
    FDatas[3] := FPlugin.Description;
    FDatas[4] := FPlugin.Copyright;
    FDatas[5] := FPlugin.Version;
    FDatas[6] := StrIf(FPlugin.Unicode, 'Unicode', 'Ansi');
    FDatas[7] := FPlugin.GetFlagsStrEx;
    FDatas[8] := StrReplace(FPlugin.Prefixes, ':', ', ', [rfReplaceAll]);

    vDX1 := 0;
    for I := 0 to cProps - 1 do
      vDX1 := IntMax(vDX1, Length(FPrompts[I]));

    for I := 0 to cProps - 1 do
      FPrompts[I] := StrLeftAjust(FPrompts[I], vDX1) + ' :';
    Inc(vDX1, 2);  

    vDX2 := 0;
    for I := 0 to cProps - 1 do
      vDX2 := IntMax(vDX2, Length(FDatas[I]));

    FHeight := DY;
    FWidth := vDX1 + vDX2 + 11;
    if FWidth > vMaxWidth then begin
      FWidth := vMaxWidth;
      vDX2 := FWidth - vDX1 - 11;
    end;

    FItemCount := 24;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1, FWidth-6, DY-2, 0, GetMsg(strPlugInfoTitle)),
        NewItemApi(DI_Text,      5,  2, 5+vDX1, -1,  0,  PTChar(FPrompts[0]) ),
        NewItemApi(DI_Text,      5,  3, 5+vDX1, -1,  0,  PTChar(FPrompts[1]) ),
        NewItemApi(DI_Text,      5,  4, 5+vDX1, -1,  0,  PTChar(FPrompts[2]) ),
        NewItemApi(DI_Text,      0,  5, -1,     -1,  DIF_SEPARATOR, ''),
        NewItemApi(DI_Text,      5,  6, 5+vDX1, -1,  0,  PTChar(FPrompts[3]) ),
        NewItemApi(DI_Text,      5,  7, 5+vDX1, -1,  0,  PTChar(FPrompts[4]) ),
        NewItemApi(DI_Text,      5,  8, 5+vDX1, -1,  0,  PTChar(FPrompts[5]) ),
        NewItemApi(DI_Text,      0,  9, -1,     -1,  DIF_SEPARATOR, ''),
        NewItemApi(DI_Text,      5, 10, 5+vDX1, -1,  0,  PTChar(FPrompts[6]) ),
        NewItemApi(DI_Text,      5, 11, 5+vDX1, -1,  0,  PTChar(FPrompts[7]) ),
        NewItemApi(DI_Text,      5, 12, 5+vDX1, -1,  0,  PTChar(FPrompts[8]) ),

        NewItemApi(DI_Text, 6+vDX1,  2, vDX2, -1,  0,  '' ),
        NewItemApi(DI_Text, 6+vDX1,  3, vDX2, -1,  0,  '' ),
        NewItemApi(DI_Text, 6+vDX1,  4, vDX2, -1,  0,  '' ),

        NewItemApi(DI_Text, 6+vDX1,  6, vDX2, -1,  0,  '' ),
        NewItemApi(DI_Text, 6+vDX1,  7, vDX2, -1,  0,  '' ),
        NewItemApi(DI_Text, 6+vDX1,  8, vDX2, -1,  0,  '' ),

        NewItemApi(DI_Text, 6+vDX1, 10, vDX2, -1,  0,  '' ),
        NewItemApi(DI_Text, 6+vDX1, 11, vDX2, -1,  0,  '' ),
        NewItemApi(DI_Text, 6+vDX1, 12, vDX2, -1,  0,  '' ),

        NewItemApi(DI_Text,   0, DY-4, -1, -1, DIF_SEPARATOR, ''),
        NewItemApi(DI_Button, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strButClose)),
        NewItemApi(DI_Button, 0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strButProps))
      ]
    );

//  FHelpTopic := 'PluginInfo';
  end;


  procedure FInfoDlg.InitDialog; {override;}
  var
    I :Integer;
  begin
    for I := 0 to cProps - 1 do
      SetText(IdFileName + I, FDatas[I]);
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
        if Param1 = IdButProp then begin
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

  procedure ViewPluginInfo(APlugin :TFarPlugin);
  var
    vDlg :FInfoDlg;
  begin
    vDlg := FInfoDlg.CreateEx(APlugin);
    try
      if vDlg.Run = -1 then
        Exit;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}

unit ReviewDlgSaveAs;

{******************************************************************************}
{* (c) 2013 Max Rusov                                                         *}
{*                                                                            *}
{* Review                                                                     *}
{* Image Viewer Plugn for Far 2/3                                             *}
{******************************************************************************}

interface

  uses
    Windows,

    MultiMon,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    GDIPAPI,
    GDIImageUtil,

    Far_API,
    FarCtrl,
    FarPlug,
    FarDlg,

    ReviewConst,
    ReviewDecoders,
    ReviewClasses,
    ReviewGDIPlus;


  type
    TSaveAsDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FFilePath :TString;
      FFileName :TString;
      FFmtName  :TString;
      FQuality  :Integer;
      FOrient   :Integer;
      FOptions  :TSaveOptions;

      procedure EnableCommands;
    end;


  function SaveAsDlg(var AFileName, AFmtName :TString; var AOrient, AQuality :Integer; var AOptions :TSaveOptions) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  const
    cFmtNames :array[0..4] of TString = (
      'BMP',
      'JPEG',
      'GIF',
      'TIFF',
      'PNG'
    );

    cFmtExts :array[0..4] of TString = (
      'BMP',
      'JPG',
      'GIF',
      'TIF',
      'PNG'
    );


  function FmtNameToExt(const aFmtName :TString) :TString;
  var
    i :Integer;
  begin
    for i := 0 to High(cFmtNames) do
      if StrEqual( cFmtNames[i], aFmtName) then begin
        Result := cFmtExts[i];
        exit;
      end;
    Result := aFmtName;
  end;


  const
    cOrients :array[0..5] of TString = (
      'Normal',
      '+90',
      '-90',
      '180',
      'X-Flip',
      'Y-Flip'
    );
    cOrientCodes :array[0..5] of Integer = (
      1, 6, 8, 3, 2, 4
    );

  function OrientToName(aOrient :Integer) :TString;
  var
    i :Integer;
  begin
    for i := 0 to High(cOrientCodes) do
      if cOrientCodes[i] = aOrient then begin
        Result := cOrients[i];
        Exit;
      end;
    Result := '';
  end;

  function NameToOrient(const aName :TString) :Integer;
  var
    i :Integer;
  begin
    for i := 0 to High(cOrientCodes) do
      if StrEqual(cOrients[i], aName) then begin
        Result := cOrientCodes[i];
        Exit;
      end;
    Result := 0;
  end;


 {-----------------------------------------------------------------------------}
 { TSaveAsDlg                                                                  }
 {-----------------------------------------------------------------------------}

  const
    IdFrame         =  0;

    IdFileName      =  2;
    IdFormatName    =  5;
    IdQualityLab    =  6;
    IdQuality       =  7;
    IdOrientation   = 10;
    IdByExif        = 11;

    IdOk            = 13;
    IdCancel        = 14;


  procedure TSaveAsDlg.Prepare; {override;}
  const
    DX = 70;
    DY = 12;
  var
    X1 :Integer;
  begin
    FGUID := cConfigDlgID;
    FHelpTopic := 'SaveAs';

    FWidth := DX;
    FHeight := DY;
    X1 := 5;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,  3,  1,   DX-6, DY-2, 0, GetMsg(strSaveAsTitle)),

        NewItem(DI_Text,      -X1,  -2,   0, 0,       0,  GetMsg(strSaveFileLabel) ),
        NewItem(DI_Edit,      -X1,   1,   DX-11, 0,   DIF_HISTORY, '', cFileNameHistory),

        NewItem(DI_Text,       -1,   1,   0, 0, DIF_SEPARATOR),

        NewItem(DI_Text,      -X1,   1,   0,  0,    0,  GetMsg(strFormatLabel) ),
        NewItem(DI_ComboBox,    1,   0,   10, 0,    DIF_DROPDOWNLIST,  ''),

        NewItem(DI_Text,        3,   0,   0,  0,    0,  GetMsg(strQualityLabel) ),
        NewItem(DI_Edit,        1,   0,   10, 0,    0,  ''),

        NewItem(DI_Text,       -1,   1,   0, 0, DIF_SEPARATOR),

        NewItem(DI_Text,      -X1,   1,   0,  0,    0,  GetMsg(strOrientationLabel) ),
        NewItem(DI_ComboBox,    1,   0,   10, 0,    DIF_DROPDOWNLIST,  ''),
        NewItem(DI_CheckBox,    3,   0,    0, 0,    0,  GetMsg(strExifLabel) ),

        NewItemApi(DI_Text,      0, DY-4,  0, 0, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3,  0, 0, DIF_CENTERGROUP, GetMsg(strCancel) )
      ],
      @FItemCount
    );
  end;


  procedure TSaveAsDlg.InitDialog; {override;}
  begin
    SetListItems(IdFormatName, [cFmtNames[0], cFmtNames[1], cFmtNames[2], cFmtNames[3], cFmtNames[4]]);
    SetListItems(IdOrientation, [cOrients[0], cOrients[1], cOrients[2], cOrients[3], cOrients[4], cOrients[5]]);

    SetText(IdFileName, FFileName);
    SetText(IdFormatName, FFmtName);
    SetText(IdOrientation, OrientToName(FOrient));
    SetChecked(IdByExif, soExifRotation in FOptions);

    EnableCommands;
  end;


  function TSaveAsDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vNewName, vNewFileName :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      vNewName := GetText(IdFileName);
      if vNewName <> '' then begin

        if not StrEqual(vNewName, FFileName) then begin
          vNewFileName := CombineFileName( FFilePath, vNewName );
          if WinFileExists(vNewFileName) then begin
            if ShowMessageBut(GetMsgStr(strWarning), Format(GetMsgStr(strOverridePrompt), [vNewName]),
              [GetMsgStr(strYes), GetMsgStr(strNo)], FMSG_WARNING) <> 0
            then
              begin Result := False; Exit; end;
          end;
        end;

        FFileName := vNewName;
      end;

      FFmtName := GetText(IdFormatName);
      FQuality := Str2IntDef(GetText(IdQuality), 0);
      FOrient := NameToOrient(GetText(IdOrientation));

      FOptions := [];
      if GetChecked(IdByExif) then
        FOptions := [soExifRotation]
      else
        FOptions := [soTransformation, soEnableLossy]

    end;
    Result := True;
  end;


  procedure TSaveAsDlg.EnableCommands;
  var
    vFmtName :TString;
    vUseQuality, vCanExifRotate :Boolean;
  begin
    vFmtName := GetText(IdFormatName);

    vUseQuality := StrEqual(vFmtName, 'JPEG');
    vCanExifRotate := StrEqual(vFmtName, 'JPEG') or StrEqual(vFmtName, 'TIFF');

    SetVisible(IdQualityLab, vUseQuality);
    SetVisible(IdQuality, vUseQuality);

    SetEnabled(IdByExif, vCanExifRotate);
    if not vCanExifRotate then
      SetChecked(IdByExif, False);
  end;


  function TSaveAsDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      0: {};
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TSaveAsDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocFormatChange;
    var
      vFileName, vFmtName :TString;
    begin
      vFileName := GetText(IdFileName);
      if vFileName <> '' then begin
        vFmtName := FmtNameToExt(GetText(IdFormatName));
        vFileName := ChangeFileExtension(vFileName, vFmtName);
        SetText(IdFileName, vFileName);
      end;
      EnableCommands;
    end;

  begin
    Result := 1;
    case Msg of
      DN_EDITCHANGE:
        if Param1 = IdFormatName then
          LocFormatChange
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function SaveAsDlg(var AFileName, AFmtName :TString; var AOrient, AQuality :Integer; var AOptions :TSaveOptions) :Boolean;
  var
    vDlg :TSaveAsDlg;
  begin
    vDlg := TSaveAsDlg.Create;
    try
      vDlg.FFilePath := ExtractFilePath(AFileName);
      vDlg.FFileName := ExtractFileName(AFileName);
      vDlg.FFmtName := AFmtName;
      vDlg.FQuality := AQuality;
      vDlg.FOrient := IntIf(AOrient <> 0, AOrient, 1);
      vDlg.FOptions := AOptions;

      Result := vDlg.Run = IdOk;

      if Result then begin
        AFileName := CombineFileName( vDlg.FFilePath, vDlg.FFileName );
        AFmtName := vDlg.FFmtName;
        AQuality := vDlg.FQuality;
        AOrient := vDlg.FOrient;
        AOptions := vDlg.FOptions;
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


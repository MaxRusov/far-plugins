{$I Defines.inc}

unit VersionColumn_Main;

{******************************************************************************}
{* VersionColumn Far Plugin                                                   *}
{* 2010-2014, Max Rusov                                                       *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixWinUtils,
    MixStrings,

    Far_API,  //Plugin3.pas
    FarCtrl,
    FarConfig,
    FarMenu,
    FarPlug,
    FarDlg;


  const
    cPluginName = 'VersionColumn';
    cPluginDescr = 'Version Column FAR plugin';
    cPluginAuthor = 'Max Rusov';

    cPluginID   :TGUID = '{4CCD74EE-757B-4D4D-8B27-66D013116BC3}';
    cMenuID     :TGUID = '{C414D105-1F76-43FF-9BE7-E168954CBB7C}';
//  cConfigID   :TGUID =

  var
    opt_Format :TString = 'FileVersion:20 | FileDescription';


  type
    TVersionColumn = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
    private
    end;


  function GetCustomDataW(AFileName :PFarChar; var CustomData :PFarChar) :Integer; stdcall;
  procedure FreeCustomDataW(CustomData :PFarChar); stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  procedure InsertText(const AStr :TString);
  var
    vStr :TString;
  begin
    vStr := 'print("' + FarMaskStr(AStr) + '")';
    FarPostMacro(vStr);
  end;


  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;
        StrValue('Format', opt_Format);
      finally
        Destroy;
      end;
  end;

 {-----------------------------------------------------------------------------}

  function FormatMenu(var AFmt :TString) :Boolean;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      'Version Info',
    [
      'FileVersion',
      'FileDescription',
      'LegalCopyright',
      'CompanyName',
      'OriginalFilename',
      'InternalName',
      'ProductName',
      'ProductVersion',
      'Comments'
    ]);
    try
      Result := vMenu.Run;

      if Result then
        AFmt := vMenu.Items[vMenu.ResIdx].TextPtr;

    finally
      FreeObj(vMenu);
    end;
  end;


  const
    IdFrame        = 0;
    IdInfoBut      = 1;
    IdInputEdt     = 3;
    IdOk           = 5;

  type
    TInputDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FInitStr  :TString;

      procedure InsertFormat;
    end;


  procedure TInputDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 8;
  begin
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, 'Version Column'),

        NewItemApi(DI_Button,   DX-11, 2, -1, -1, DIF_NOFOCUS or DIF_BTNNOCLOSE or DIF_NOBRACKETS, '&Insert'),

        NewItemApi(DI_Text,     5,  2, -1,    -1, 0, '&Format:' ),
        NewItemApi(DI_Edit,     5,  3, DX-10, -1, DIF_HISTORY, '', 'VerCol.Format' ),

        NewItemApi(DI_Text,     0,  4, -1, -1,   DIF_SEPARATOR),

        NewItemApi(DI_DefButton,0, DY-3, -1, -1, DIF_CENTERGROUP, 'OK' ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, 'Cancel' )
      ],
      @FItemCount
    );
  end;


  procedure TInputDlg.InitDialog; {override;}
  begin
    if FInitStr <> '' then
      SetText(IdInputEdt, FInitStr);
  end;


  function TInputDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if ItemID = IdOk then
      FInitStr := GetText(IdInputEdt);
    Result := True;
  end;


  procedure TInputDlg.InsertFormat;
  var
    vFmt :TString;
  begin
    if FormatMenu(vFmt) then
      InsertText(vFmt);
  end;


  function TInputDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 = IdInfoBut then
          InsertFormat
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  function QueryFormat(var AFormat :TString) :Boolean;
  var
    vDlg :TInputDlg;
  begin
    vDlg := TInputDlg.Create;
    try
      vDlg.FInitStr := AFormat;
      Result := vDlg.Run = IdOk;
      if Result then
        AFormat := vDlg.FInitStr;
    finally
      FreeObj(vDlg);
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    vDstBuf  :PTChar;
    vDstSize :Integer;


  function GrowDestBuf :PTChar;
  begin
    ReallocMem(vDstBuf, (vDstSize + 256) * SizeOf(TChar));
    Inc(vDstSize, 256);
    Result := vDstBuf;
  end;


  procedure ParseFormat(AVerInfo :PTChar; const ALang :TString);
  var
    vDstLen :Integer;

    function LocGetKey(const AKey :TString) :TString;
    var
      vKey :TString;
      vStr :PTChar;
      vLen :UINT;
    begin
      Result := '';
      vKey := '\StringFileInfo\' + ALang + '\' + AKey;
      if VerQueryValue(AVerInfo, PWideChar(vKey), Pointer(vStr), vLen) then
        Result := vStr;
    end;

    procedure AddChr(AChr :TChar);
    begin
      if vDstLen + 1 > vDstSize then
        GrowDestBuf;
      PTChar(vDstBuf + vDstLen)^ := AChr;
      Inc(vDstLen);
    end;

    procedure AddStr(const AStr :TString);
    begin
      while vDstLen + length(AStr) > vDstSize do
        GrowDestBuf;
      StrMove(vDstBuf + vDstLen, PTChar(AStr), length(AStr));
      Inc(vDstLen, length(AStr));
    end;

  var
    vPtr, vBeg :PTChar;
    vStr, vValue :TString;
    vNum :Integer;
  begin
    vPtr := PTChar(opt_Format);
    vDstLen := 0;
    while vPtr^ <> #0 do begin
      if IsCharAlpha(vPtr^) then begin
        vBeg := vPtr;
        while (vPtr^ <> #0) and IsCharAlpha(vPtr^) do
          Inc(vPtr);
        SetString(vStr, vBeg, vPtr - vBeg);
        vValue := LocGetKey(vStr);

        if vPtr^ = ':' then begin
          Inc(vPtr);
          vBeg := vPtr;
          while (vPtr^ <> #0) and ((vPtr^ >= '0') and (vPtr^ <= '9')) do
            Inc(vPtr);
          SetString(vStr, vBeg, vPtr - vBeg);
          vNum := Str2IntDef(vStr, -1);
          if vNum > 0 then begin
            if length(vValue) < vNum then
              vValue := vValue + StringOfChar(' ', vNum - length(vValue))
            else
              vValue := Copy(vValue, 1, vNum);
          end;
        end;

        AddStr(vValue);
      end else
      begin
        AddChr(vPtr^);
        Inc(vPtr);
      end;
    end;
    AddChr(#0);
  end;



  type
    PLANGANDCODEPAGE = ^TLANGANDCODEPAGE;
    TLANGANDCODEPAGE = packed record
      wLanguage :Word;
      wCodePage :Word;
    end;


  function DetectLang(AVerInfo :PTChar; ASize :Integer) :TString;
  const
    cStrInfo = 'StringFileInfo';
  var
    vLen :UINT;
    vCP  :PLANGANDCODEPAGE;
    vPtr, vEnd :PWideChar;
  begin
    { »щем сканированием, потому что иногда Translation не совпадает с StringInfo }
    vPtr := AVerInfo;
    vEnd := AVerInfo + (ASize div SizeOf(WideChar)) - Length(cStrInfo) - 4 - 8;
    while vPtr < vEnd do begin
      if StrLICompW(vPtr, cStrInfo, Length(cStrInfo)) = 0 then begin
        Inc(vPtr, Length(cStrInfo) + 4);
        SetString(Result, vPtr, 8);
        Exit;
      end;
      Inc(vPtr);
    end;

    { Ќе нашли сканированием (возможно 16-ти разр€дна€ программа), попробуем через Translation}
    if VerQueryValue(AVerInfo, '\VarFileInfo\Translation', Pointer(vCP), vLen) then
//    Result := FAPI.Format('%.4x%.4x', [vCP.wLanguage, vCP.wCodePage]);
      Result := HexStr(vCP.wLanguage, 4) + HexStr(vCP.wCodePage, 4);
  end;



 {-----------------------------------------------------------------------------}
 { TVersionColumn                                                              }
 {-----------------------------------------------------------------------------}

  procedure TVersionColumn.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison;
    FGUID := cPluginID;

    FMinFarVer := MakeVersion(3, 0, 3000);
  end;


  procedure TVersionColumn.Startup; {override;}
  begin
    PluginConfig(False);
  end;


  procedure TVersionColumn.ExitFar; {override;}
  begin
    MemFree(vDstBuf);
  end;


  procedure TVersionColumn.GetInfo; {override;}
  begin
    FFlags := PF_PRELOAD;

    FMenuStr := 'Version Column';
    FMenuID  := cMenuID;

    //  FConfigStr := FMenuStr;
//  FConfigID  := cConfigID;
  end;


  function TVersionColumn.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;
    if QueryFormat(opt_Format) then
      PluginConfig(True);
  end;


 {-----------------------------------------------------------------------------}

  function GetCustomDataW(AFileName :PFarChar; var CustomData :PFarChar) :Integer;
  var
    vBuf  :PWideChar;
    vSize :DWORD;
    vTemp :DWORD;
    vLang :TString;
 begin
    Result := 0;
    if opt_Format = '' then
      Exit;
      
    vSize := GetFileVersionInfoSize(AFileName, vTemp);
    if vSize > 0 then begin
      GetMem(vBuf, vSize);
      try
        GetFileVersionInfo(AFileName, 0, vSize, vBuf);
        vLang := DetectLang(vBuf, vSize);

        if vLang <> '' then begin
          ParseFormat(vBuf, vLang);
          CustomData := StrNew(vDstBuf);
          Result := 1;
        end

      finally
        FreeMem(vBuf);
      end;
    end;
  end;


  procedure FreeCustomDataW(CustomData :PFarChar);
  begin
    StrDispose(CustomData);
  end;


end.

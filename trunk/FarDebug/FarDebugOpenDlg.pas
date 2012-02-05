{$I Defines.inc}

unit FarDebugOpenDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Выбор каталога с исходниками                                               *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarDlg,
    FarDebugCtrl,
    FarDebugGDB;


  function OpenProcessDlg(const AFile :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdFrame     = 0;
    IdFileEdt   = 2;
    IdHostEdt   = 4;
    IdArgsEdt   = 6;

    IdLoadBut   = 8;
    IdStepBut   = 9;
    IdRunBut    = 10;
    IdCancelBut = 11;

  type
    TOpenProcessDlg = class(TFarDialog)
    public
      constructor Create; override;
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FFolder :TString;
      FFile   :TString;
      FHost   :TString;
      FArgs   :TString;
    end;


  constructor TOpenProcessDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TOpenProcessDlg.Prepare; {override;}
  const
    DX = 65;
    DY = 12;
  begin
    FGUID := cOpenDlgID;
    FHelpTopic := 'OpenDlg';
    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,   1,   DX-6, DY-2,  0,  GetMsg(strTitle)),

        NewItemApi(DI_Text,      5,   2,   DX-10,  -1,  0,  GetMsg(strFileName)),
        NewItemApi(DI_Edit,      5,   3,   DX-10,  -1,  DIF_HISTORY, '', 'FarDebug.FileName' ),

        NewItemApi(DI_Text,      5,   4,   DX-10,  -1,  0,  GetMsg(strHostApp)),
        NewItemApi(DI_Edit,      5,   5,   DX-10,  -1,  DIF_HISTORY {or DIF_USELASTHISTORY}, '', 'FarDebug.Host' ),

        NewItemApi(DI_Text,      5,   6,   DX-10,  -1,  0,  GetMsg(strParameters)),
        NewItemApi(DI_Edit,      5,   7,   DX-10,  -1,  DIF_HISTORY {or DIF_USELASTHISTORY}, '', 'FarDebug.Parameters' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strLoad) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strStep) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strRun) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
      ],
      @FItemCount
    );
  end;


  procedure TOpenProcessDlg.InitDialog; {override;}
  begin
    SetText(IdFileEdt, FFile);
    SetText(IdHostEdt, LastHost);
    SetText(IdArgsEdt, LastArgs);
  end;


  function TOpenProcessDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancelBut) then begin
      FFile := CombineFileName(FFolder, GetText(IdFileEdt));
      if not WinFileExists(FFile) then
        AppErrorID(strFileNotFound);

      FHost := GetText(IdHostEdt);
      FArgs := GetText(IdArgsEdt);

      LastHost := FHost;
      LastArgs := FArgs;
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function OpenProcessDlg(const AFile :TString) :Boolean;
  var
    vDlg  :TOpenProcessDlg;
    vRes  :Integer;
    vHost :TString;
  begin
    Result := False;
    vDlg := TOpenProcessDlg.Create;
    try
      vDlg.FFolder := ExtractFilePath(AFile);
      vDlg.FFile   := ExtractFileName(AFile);

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancelBut) then
        Exit;

//    TraceF('Res=%d', [vRes]);

      vHost := vDlg.FHost;
      if vHost <> '' then
        vHost := CombineFileName(vDlg.FFolder, vHost);

//    LoadModule('"' + vDlg.FFile + '"', vDlg.FArgs);
      LoadModule(vDlg.FFile, vHost, vDlg.FArgs);

      if vRes = IdStepBut then begin
        DebugCommand('start', True);
      end else
      if vRes = IdRunBut then begin
        DebugCommand('run', True);
      end;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


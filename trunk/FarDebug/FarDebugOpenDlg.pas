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
    SysTypes,
    MSUtils,
    MSStr,
    MSWinUtils,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,
    FarDebugCtrl,
    FarDebugGDB;


  function OpenProcessDlg(const AFile :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MSDebug;


  const
    IdFrame     = 0;
    IdFileEdt   = 2;
    IdArgsEdt   = 4;

    IdLoadBut   = 6;
    IdStepBut   = 7;
    IdRunBut    = 8;
    IdCancelBut = 9;

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
      FArgs   :TString;
    end;


  constructor TOpenProcessDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TOpenProcessDlg.Prepare; {override;}
  const
    DX = 65;
    DY = 10;
  begin
    FHelpTopic := 'OpenDlg';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 10;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,   1,   DX-6, DY-2,  0,  GetMsg(strTitle)),

        NewItemApi(DI_Text,      5,   2,   DX-10,  -1,  0,  GetMsg(strFileName)),
        NewItemApi(DI_Edit,      5,   3,   DX-10,  -1,  DIF_HISTORY, '', 'FarDebug.FileName' ),

        NewItemApi(DI_Text,      5,   4,   DX-10,  -1,  0,  GetMsg(strParameters)),
        NewItemApi(DI_Edit,      5,   5,   DX-10,  -1,  DIF_HISTORY or DIF_USELASTHISTORY, '', 'FarDebug.Parameters' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strLoad) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strStep) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strRun) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
      ]
    );
  end;


  procedure TOpenProcessDlg.InitDialog; {override;}
  begin
    SetText(IdFileEdt, FFile);
  end;


  function TOpenProcessDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancelBut) then begin
      FFile := CombineFileName(FFolder, GetText(IdFileEdt));
      if not WinFileExists(FFile) then
        AppErrorID(strFileNotFound);
      FArgs := GetText(IdArgsEdt);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function OpenProcessDlg(const AFile :TString) :Boolean;
  var
    vDlg :TOpenProcessDlg;
    vRes :Integer;
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

      LoadModule('"' + vDlg.FFile + '"', vDlg.FArgs);

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


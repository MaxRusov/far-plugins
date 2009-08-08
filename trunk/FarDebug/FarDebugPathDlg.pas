{$I Defines.inc}

unit FarDebugPathDlg;

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
    MixFormat,
    MixStrings,
    MixWinUtils,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,
    FarDebugCtrl;


  function PromptFolderDlg(const ASrcFile :TString; var AFolder :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdFrame     = 0;
    IdMess      = 1;
    IdPrompt    = 3;
    IdEdit      = 4;
    IdOkBut     = 6;
    IdCancelBut = 7;
    IdSelectBut = 8;


  type
    TPromptFolderDlg = class(TFarDialog)
    public
      constructor Create; override;
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; override;

    private
      FSrcFile :TString;
      FFolder  :TString;
    end;


  constructor TPromptFolderDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TPromptFolderDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 10;
  begin
    FHelpTopic := 'PromptDlg';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 9;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,   1,   DX-6, DY-2,  0,  GetMsg(strTitle)),

        NewItemApi(DI_Text,      5,   2,   DX-10,  -1,  0),
        NewItemApi(DI_Text,      0,   3,  -1, -1, DIF_SEPARATOR),

        NewItemApi(DI_Text,      5,   4,   DX-10,  -1,  0,  GetMsg(strFolderPrompt)),
        NewItemApi(DI_Edit,      5,   5,   DX-10,  -1,  DIF_HISTORY, '', 'FarDebug.Folder' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOkBut) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strButSelect) )
      ]
    );
  end;


  procedure TPromptFolderDlg.InitDialog; {override;}
  begin
    SetText(IdMess, Format(GetMsgStr(strSrcFileNotFound), [FSrcFile]));
  end;


  function TPromptFolderDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancelBut) then begin
      FFolder := Trim(RemoveBackSlash(GetText(IdEdit)));
      if (FFolder = '') or not WinFolderExists(FFolder) then
        AppErrorID(strFolderNotFound);
    end;
    Result := True;
  end;


  function TPromptFolderDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

    procedure LocSelectFile;
    var
      vMacro :TActlKeyMacro;
      vStr :TFarStr;
    begin
      SendMsg(DM_SETFOCUS, IdEdit, 0);

      vStr := Format('F11 $if(Menu.Select("%s", 2) > 0) Enter $else Esc MsgBox("%s", "%s", 1) $end',
        [GetMsgStr(strOpenFileDialog), GetMsgStr(strTitle), GetMsgStr(strDialogToolNotInstalled)]);

      vMacro.Command := MCMD_POSTMACROSTRING;
      vMacro.Param.PlainText.SequenceText := PFarChar(vStr);
      vMacro.Param.PlainText.Flags := KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;

      FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
    end;

  begin
    Result := 1;
    if (Msg = DN_BTNCLICK) and (Param1 = IdSelectBut) then
      LocSelectFile
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function PromptFolderDlg(const ASrcFile :TString; var AFolder :TString) :Boolean;
  var
    vDlg :TPromptFolderDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TPromptFolderDlg.Create;
    try
      vDlg.FSrcFile := ASrcFile;

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancelBut) then
        Exit;

      AFolder := vDlg.FFolder;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


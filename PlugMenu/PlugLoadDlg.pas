{$I Defines.inc}

unit PlugLoadDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PlugMenu Far plugin                                                        *}
{* Выбор плагина для загрузки                                                 *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixWinUtils,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,

    PlugMenuCtrl,
    PlugMenuPlugs;


  function LoadPluginDlg(var AFileName :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdFrame     = 0;
    IdPrompt    = 1;
    IdEdit      = 2;
    IdOkBut     = 4;
    IdCancelBut = 5;
    IdSelectBut = 6;


  type
    TLoadPluginDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; override;

    private
      FFileName  :TString;
    end;


  procedure TLoadPluginDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 8;
  begin
//  FHelpTopic := 'LoadDlg';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 7;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,   1,   DX-6, DY-2,  0,  GetMsg(strLoadDlgTitle)),

        NewItemApi(DI_Text,      5,   2,   DX-10,  -1,  0,  GetMsg(strLoadDlgPrompt)),
        NewItemApi(DI_Edit,      5,   3,   DX-10,  -1,  DIF_HISTORY, '', 'PlugMenu.Plugin' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strButOk)),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strButCancel)),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP or DIF_BTNNOCLOSE, GetMsg(strButSelect))
      ]
    );
  end;


  function TLoadPluginDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancelBut) then begin
      FFileName := Trim(GetText(IdEdit));
      if (FFileName = '') or not WinFileExists(FFileName) then
        AppErrorId(strFileNotFound);
    end;
    Result := True;
  end;


  function TLoadPluginDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

    procedure LocSelectFile;
    var
      vMacro :TActlKeyMacro;
      vStr :TString;
    begin
      SendMsg(DM_SETFOCUS, IdEdit, 0);

      vStr := Format('F11 $if(Menu.Select("%s", 2) > 0) Enter $else Esc MsgBox("%s", "%s", 1) $end',
        [GetMsgStr(strOpenFileDialog), GetMsgStr(strLoadDlgTitle), GetMsgStr(strDialogToolNotInstalled)]);

      vMacro.Command := MCMD_POSTMACROSTRING;
      vMacro.Param.PlainText.SequenceText := PTChar(vStr);
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

  function LoadPluginDlg(var AFileName :TString) :Boolean;
  var
    vDlg :TLoadPluginDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TLoadPluginDlg.Create;
    try
      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancelBut) then
        Exit;

      AFileName := vDlg.FFileName;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


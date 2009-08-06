{$I Defines.inc}

unit FarDebugFindAddr;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Поиcк адреса                                                               *}
{******************************************************************************}

interface

  uses
    Windows,
    SysTypes,
    SysUtil,
    SysFmt,
    MSStr,
    MSUtils,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,
    FarDebugCtrl,
    FarDebugGDB,
    FarDebugAddrsList;


  function PromptAddrDlg(var AAddrs :TString) :Boolean;

  procedure FindAddrs;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MSDebug;


  const
    IdFrame     = 0;
    IdPrompt    = 1;
    IdEdit      = 2;
    IdOkBut     = 4;
    IdCancelBut = 5;


  type
    TPromptAddrDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FAddrs  :TString;
    end;


  procedure TPromptAddrDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 8;
  begin
    FHelpTopic := 'AddrDlg';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 6;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,   1,   DX-6, DY-2,  0, GetMsg(strFindAddress)),

        NewItemApi(DI_Text,      5,   2,   DX-10,  -1,  0, GetMsg(strAddressPrompt)),
        NewItemApi(DI_Edit,      5,   3,   DX-10,  -1,  DIF_HISTORY, '', 'FarDebug.Addrs' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOkBut) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancelBut) )
      ]
    );
  end;


  function TPromptAddrDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancelBut) then
      FAddrs := Trim(GetText(IdEdit));
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function PromptAddrDlg(var AAddrs :TString) :Boolean;
  var
    vDlg :TPromptAddrDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TPromptAddrDlg.Create;
    try
      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancelBut) then
        Exit;

      AAddrs := vDlg.FAddrs;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


  procedure FindAddrs;
  var
    vAddr :TString;
  begin
    InitGDBDebugger;
    if PromptAddrDlg(vAddr) and (vAddr <> '') then
      AddrsDlg(vAddr);
  end;


end.


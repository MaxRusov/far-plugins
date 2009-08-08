{$I Defines.inc}

unit EditTabDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,
    PanelTabsCtrl,
    PanelTabsClasses;


  function EditTab(ATabs :TPanelTabs; AIndex :Integer) :Boolean;
  function NewTab(ATabs :TPanelTabs; AIndex :Integer) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdFrame         = 0;
    IdEdtCaption    = 2;
    IdEdtFolder     = 4;
    IdCancel        = 7;
    IdDelete        = 8;

  type
    TEditTabDlg = class(TFarDialog)
    public
      constructor Create; override;
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FTab    :TPanelTab;
    end;


  constructor TEditTabDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TEditTabDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 11;
  begin
    FHelpTopic := 'Edit';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 9;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strEditTab)),

        NewItemApi(DI_Text,     5,   2,   DX-10,  -1,   0, GetMsg(strCaption)),
        NewItemApi(DI_Edit,     5,   3,   DX-10,  -1,   DIF_HISTORY, '', 'PanelTabs.Caption' ),

        NewItemApi(DI_Text,     5,   4,   DX-10,  -1,   0, GetMsg(strFolder)),
        NewItemApi(DI_Edit,     5,   5,   DX-10,  -1,   DIF_HISTORY, '', 'PanelTabs.Folder' ),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strDelete) )
      ]
    );
  end;


  procedure TEditTabDlg.InitDialog; {override;}
  begin
    SetText(IdEdtCaption, FTab.Caption);
    SetText(IdEdtFolder, FTab.Folder);
    if FTab.Caption = '' then begin
      SetText(IdFrame, GetMsg(strAddTab));
      SendMsg(DM_ENABLE, IdDelete, 0);
    end;
  end;


  function TEditTabDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  var
    vCaption, vFolder :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) and (ItemID <> IdDelete) then begin
      vCaption := Trim(GetText(IdEdtCaption));
      vFolder := GetText(IdEdtFolder);
      if vCaption = '' then
        AppErrorID(strEmptyCaption);
//    if not IsFullFilePath(vFolder) then
//      AppErrorFmt('Invalid path: %s', [vFolder]);

      FTab.Caption := vCaption;
      FTab.Folder := vFolder;
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}


  function EditTab(ATabs :TPanelTabs; AIndex :Integer) :Boolean;
  var
    vDlg :TEditTabDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TEditTabDlg.Create;
    try
      vDlg.FTab := ATabs[AIndex];

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      if vRes = IdDelete then
        ATabs.FreeAt(AIndex);

      Result := True;

    finally
      FreeObj(vDlg);
    end;
  end;


  function NewTab(ATabs :TPanelTabs; AIndex :Integer) :Boolean;
  var
    vDlg :TEditTabDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TEditTabDlg.Create;
    try
      vDlg.FTab := TPanelTab.CreateEx('', '');

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      ATabs.Insert(AIndex, vDlg.FTab);
      vDlg.FTab := nil;

      Result := True;

    finally
      FreeObj(vDlg.FTab);
      FreeObj(vDlg);
    end;
  end;


end.


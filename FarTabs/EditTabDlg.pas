{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}

unit EditTabDlg;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
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
    IdChkFixed      = 5;
    IdCancel        = 8;
    IdDelete        = 9;

  type
    TEditTabDlg = class(TFarDialog)
    public
      constructor Create; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FTab    :TPanelTab;
      FLock   :Integer;
    end;


  constructor TEditTabDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TEditTabDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 12;
  begin
    FHelpTopic := 'Edit';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 10;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strEditTab)),

        NewItemApi(DI_Text,     5,   2,   DX-10,  -1,   0, GetMsg(strCaption)),
        NewItemApi(DI_Edit,     5,   3,   DX-10,  -1,   DIF_HISTORY, '', 'PanelTabs.Caption' ),

        NewItemApi(DI_Text,     5,   4,   DX-10,  -1,   0, GetMsg(strFolder)),
        NewItemApi(DI_Edit,     5,   5,   DX-10,  -1,   DIF_HISTORY, '', 'PanelTabs.Folder' ),

        NewItemApi(DI_Checkbox, 5,   7,   DX-10,  -1,   0, GetMsg(strFixed) ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strDelete) )
      ]
    );
  end;


  procedure TEditTabDlg.InitDialog; {override;}
  begin
    if FTab.IsFixed then
      SetText(IdEdtCaption, FTab.Caption);
    SetText(IdEdtFolder, FTab.Folder);
    if FTab.Caption = '' then begin
      SetText(IdFrame, GetMsg(strAddTab));
      SendMsg(DM_ENABLE, IdDelete, 0);
    end;
    SendMsg(DM_SETCHECK, IdChkFixed, IntIf(FTab.IsFixed, BSTATE_CHECKED, BSTATE_UNCHECKED));
  end;


  function TEditTabDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  var
    vCaption, vFolder :TString;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) and (ItemID <> IdDelete) then begin
      Result := False;

      vCaption := Trim(GetText(IdEdtCaption));
      vFolder := GetText(IdEdtFolder);
//    if vCaption = '' then
//      AppErrorID(strEmptyCaption);
//    if not IsFullFilePath(vFolder) then
//      AppErrorFmt('Invalid path: %s', [vFolder]);

      if (vCaption = '') and (vFolder <> '') then
        vCaption := '*';

      if UpCompareSubStr(cMacroPrefix, vFolder) = 0 then
        if not FarCheckMacro(Copy(vFolder, length(cMacroPrefix) + 1, MaxInt), False) then
          Exit;

      FTab.Caption := vCaption;
      FTab.Folder := vFolder;
    end;
    Result := True;
  end;


  function TEditTabDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocChangeChk;
    var
      vFixed :Boolean;
      vFolder :TString;
    begin
      Inc(FLock);
      try
        vFixed := SendMsg(DM_GETCHECK, IdChkFixed, 0) = BSTATE_CHECKED;
//      TraceF('Fixed: %d', [Byte(vFixed)]);
        if vFixed then begin
          vFolder := GetText(IdEdtFolder);
          SetText(IdEdtCaption, PathToCaption(vFolder));
        end else
          SetText(IdEdtCaption, '');
      finally
        Dec(FLock);
      end;
    end;


    procedure LocChangeCaption;
    var
      vCaption :TString;
    begin
      if FLock = 0 then begin
        vCaption := Trim(GetText(IdEdtCaption));
        SendMsg(DM_SETCHECK, IdChkFixed, IntIf(vCaption <> '', BSTATE_CHECKED, BSTATE_UNCHECKED));
      end;
    end;

  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    case Msg of
      DN_BTNCLICK:
        if Param1 = IdChkFixed then
          LocChangeChk;
      DN_EDITCHANGE:
        if Param1 = IdEdtCaption then
          LocChangeCaption;
    end;
    Result := inherited DialogHandler(Msg, Param1, Param2);
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
        ATabs.Delete(AIndex);

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
      if (vRes = -1) or (vRes = IdCancel) or (vDlg.FTab.Folder = '') then
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


{$I Defines.inc}
{$Typedaddress Off}

unit PlugEditDlg;

{******************************************************************************}
{* (c) 2008-2012 Max Rusov                                                    *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Диалог настройки команды                                                   *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarCtrl,
    FarDlg,
    
    PlugMenuCtrl,
    PlugMenuPlugs;


  function EditPlugin(ACommand :TFarPluginCmd) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;



  type
    TEditDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FCommand :TFarPluginCmd
    end;



  const
    IdKeyEdit = 1;
    IdPlugName = 5;
    IdRenameEdit = 7;
    IdHideCheck = 8;

  procedure TEditDlg.Prepare; {override;}
  const
    DX = 60;
    DY = 14;
  begin
    FGUID := cPlugEditID;
    FHelpTopic := 'AssignHotkey';
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1, DX-6, DY-2, 0, GetMsg(strEditDlgTitle)),

        NewItemApi(DI_FixEdit,   5,  2, 1, -1, 0, '' ),
        NewItemApi(DI_Text,      8,  2, DX-13, -1, 0, GetMsg(strHotkeyPrompt) ),

        NewItemApi(DI_Text,      0,  3, -1, -1, DIF_SEPARATOR, ''),

        NewItemApi(DI_Text,      5,  4, DX-13, -1, 0, GetMsg(strCommandName) ),
        NewItemApi(DI_Edit,      5,  5, DX-10, -1, DIF_READONLY, '' ),

        NewItemApi(DI_Text,      5,  6, DX-13, -1, 0, GetMsg(strRenameCommand) ),
        NewItemApi(DI_Edit,      5,  7, DX-11, -1, DIF_HISTORY, '', 'PlugMenu.CmdName' ),

        NewItemApi(DI_CheckBox,  5,  9, 1, -1, 0, GetMsg(strHideCommand) ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR, ''),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strButOk)),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strButCancel))
      ],
      @FItemCount
    );
  end;


  procedure TEditDlg.InitDialog; {override;}
(*var
    I :Integer;
    vStr :TString;
    vList :TStringList;
    vItems :PFarListItemArray;
    vItem :PFarListItem;
    vStruct :TFarList; *)
  begin
(*  SendMsg(DM_SETMAXTEXTLENGTH, IdKeyEdit, 2); *)

//  SendMsg(DM_SetFocus, IdRenameEdit, 0);

    SetText(IdPlugName, FCommand.GetOrigTitle);
    SetText(IdRenameEdit, FCommand.NewName);
    if FCommand.Hotkey <> #0 then
      SetText(IdKeyEdit, FCommand.Hotkey);

    if FCommand.Hidden then
      SendMsg(DM_SetCheck, IdHideCheck, BSTATE_CHECKED);
      
(*
    vList := TStringList.Create;
    try
      for I := Byte('0') to Byte('9') do
        vList.Add( TChar(I) + ' - ' );
      for I := Byte('a') to Byte('z') do
        vList.Add( TChar(I) + ' - ' + StringOfChar('x', 50)  );

      vItems := MemAllocZero(vList.Count * SizeOf(TFarListItem));
      try
        vItem := @vItems[0];
        for I := 0 to vList.Count - 1 do begin
          SetListItem(vItem, vList[I], 0);
          Inc(PChar(vItem), SizeOf(TFarListItem));
        end;

        vStruct.ItemsNumber := vList.Count;
        vStruct.Items := vItems;
        SendMsg(DM_LISTSET, IdKeyEdit, Integer(@vStruct));

      finally
       {$ifdef bUnicodeFar}
        CleanupList(@vItems[0], vCount);
       {$endif bUnicodeFar}
        MemFree(vItems);
      end;

    finally
      FreeObj(vList);
    end;
*)
  end;


  function TEditDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  var
    vStr :TString;
    vShortcut :TChar;
    vHidden :Boolean;
  begin
    if ItemID >= 0 then begin
      vStr := GetText(IdKeyEdit);
      vShortcut := #0;
      if vStr <> '' then
        vShortcut := vStr[1];
      FCommand.SetHotkey(vShortcut);

      vStr := GetText(IdRenameEdit);
      FCommand.SetNewName(vStr);

      vHidden := SendMsg(DM_GetCheck, IdHideCheck, 0) <> 0;
      FCommand.SetHidden(vHidden);
    end;
    Result := True;
  end;


  function EditPlugin(ACommand :TFarPluginCmd) :Boolean;
  var
    vDlg :TEditDlg;
  begin
    Result := False;
    vDlg := TEditDlg.Create;
    try
      vDlg.FCommand := ACommand;
      if vDlg.Run = -1 then
        Exit;
      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


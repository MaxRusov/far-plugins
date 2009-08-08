{$I Defines.inc}
{$Typedaddress Off}

unit PlugEditDlg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Диалог назначения горячих клавиш                                           *}
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
    
    PlugMenuCtrl,
    PlugMenuPlugs;


  function EditPlugin(ACommand :TFarPluginCmd) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdPlugName = 1;
    IdKeyEdit = 2;
    IdHideCheck = 4;


  type
    TEditDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FCommand :TFarPluginCmd
    end;


  procedure TEditDlg.Prepare; {override;}
  const
    DX = 60;
    DY =  9;
  begin
    FHelpTopic := 'AssignHotkey';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 5;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1, DX-6, DY-2, 0, GetMsg(strEditDlgTitle)),
        NewItemApi(DI_Text,      5,  2, DX-10, -1, 0, '' ),
//      NewItemApi(DI_ComboBox,  5,  4, 2, -1, 0, '' ),
        NewItemApi(DI_FixEdit,   5,  4, 1, -1, 0, '' ),
        NewItemApi(DI_Text,      8,  4, DX-13, -1, 0, GetMsg(strEditDlgPrompt) ),
        NewItemApi(DI_CheckBox,  5,  6, 1, -1, 0, GetMsg(strHideCommand) )
      ]
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

    SetText(IdPlugName, FCommand.GetMenuTitle);
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


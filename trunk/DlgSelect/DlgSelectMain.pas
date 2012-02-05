{$I Defines.inc}

unit DlgSelectMain;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* DlgSelect Plugin                                                           *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    Far_API,
    FarCtrl;

  const
   {$ifdef Far3}
    cPluginID :TGUID = '{020B85C2-DB44-45D3-9D25-939499DD7813}';
   {$endif Far3}

    PLUGIN_NAME = 'DlgSelect';
    PLUGIN_DESC = 'DlgSelect FAR plugin';
    PLUGIN_AUTHOR = 'Max Rusov';

 {$ifdef Far3}
  procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;
 {$endif Far3}
  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
 {$ifdef Far3}
  function ProcessDialogEventW(var AInfo :TProcessDialogEventInfo) :Integer; stdcall;
 {$else}
  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;
 {$endif Far3}

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef Far3}
  procedure GetGlobalInfoW(var AInfo :TGlobalInfo); stdcall;
  begin
    AInfo.StructSize := SizeOf(AInfo);
  //AInfo.MinFarVersion := FARMANAGERVERSION;
  //AInfo.Info := PLUGIN_VERSION;
    AInfo.GUID := cPluginID;
    AInfo.Title := PLUGIN_NAME;
    AInfo.Description := PLUGIN_DESC;
    AInfo.Author := PLUGIN_AUTHOR;
  end;
 {$endif Far3}


  procedure SetStartupInfoW(var AInfo :TPluginStartupInfo); stdcall;
  begin
    FARAPI := AInfo;
    FARSTD := AInfo.fsf^;
   {$ifdef Far3}
    PluginID := cPluginID;
   {$else}
    hModule := AInfo.ModuleNumber;
   {$endif Far3}
  end;


  procedure ProcessFocus(AMsg :Integer; ADlg :THandle; AID :Integer);
  var
    vLen :Integer;
    vInfo :TFarDialogItem;
    vSelect :TEditorSelect;
    vCoord :TCoord;
  begin
    if (AMsg = DN_GOTFOCUS) or (AMsg = DN_KILLFOCUS) then begin
      FarSendDlgMessage(ADlg,  DM_GETDLGITEMSHORT, AID, @vInfo);
      if (vInfo.ItemType in [DI_EDIT, DI_PSWEDIT, DI_FIXEDIT]) and (vInfo.Flags and DIF_EDITOR = 0) then begin
//      TraceF('ProcessDialogEventW: GotFocus, ID=%d...', [vID]);
        FillChar(vSelect, SizeOf(vSelect), 0);
        if AMsg = DN_GOTFOCUS then begin
          vLen := FarSendDlgMessage(ADlg, DM_GETTEXTLENGTH, AID, nil);

          vSelect.BlockType := BTYPE_STREAM;
          vSelect.BlockWidth := vLen;
          vSelect.BlockHeight := 1;
          FarSendDlgMessage(ADlg, DM_SETSELECTION, AID, @vSelect);

          vCoord.X := vLen;
          vCoord.Y := 0;
          FarSendDlgMessage(ADlg, DM_SETCURSORPOS, AID, @vCoord);

        end else
          FarSendDlgMessage(ADlg, DM_SETSELECTION, AID, @vSelect);
      end;
    end;
  end;


 {$ifdef Far3}
  function ProcessDialogEventW(var AInfo :TProcessDialogEventInfo) :Integer; stdcall;
  begin
    if AInfo.Event = DE_DEFDLGPROCINIT then
      ProcessFocus(AInfo.Param.Msg, AInfo.Param.hDlg, AInfo.Param.Param1);
    Result := 0;
  end;
 {$else}
  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;
  begin
    if AEvent = DE_DEFDLGPROCINIT then
      ProcessFocus(AParam.Msg, AParam.hDlg, AParam.Param1);
    Result := 0;
  end;
 {$endif Far3}


end.

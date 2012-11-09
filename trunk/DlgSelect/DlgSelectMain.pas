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
    MixUtils,
    Far_API,
    FarCtrl,
    FarPlug;

  const
   {$ifdef Far3}
    cPluginID :TGUID = '{020B85C2-DB44-45D3-9D25-939499DD7813}';
   {$endif Far3}

    cPluginName = 'DlgSelect';
    cPluginDescr = 'DlgSelect FAR plugin';
    cPluginAuthor = 'Max Rusov';


  type
    TDlgSelectPlug = class(TFarPlug)
    public
      procedure Init; override;
      function DialogEvent(AEvent :Integer; AParam :PFarDialogEvent) :Integer; override;

    private
      procedure ProcessFocus(AMsg :Integer; ADlg :THandle; AID :Integer);
    end;

    
{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TDlgSelectPlug                                                              }
 {-----------------------------------------------------------------------------}

  procedure TDlgSelectPlug.Init; {override;}
  begin
    inherited Init;
    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 
   {$ifdef Far3}
    FGUID := cPluginID;
    FMinFarVer := MakeVersion(3, 0, 2851);   { LUA }
   {$endif Far3}
  end;


  function TDlgSelectPlug.DialogEvent(AEvent :Integer; AParam :PFarDialogEvent) :Integer;
  begin
    if AEvent = DE_DEFDLGPROCINIT then
      ProcessFocus(AParam.Msg, AParam.hDlg, AParam.Param1);
    Result := 0;
  end;


  procedure TDlgSelectPlug.ProcessFocus(AMsg :Integer; ADlg :THandle; AID :Integer);

    function GetTextLen(AItemID :Integer) :Integer;
    var
      vLen :Integer;
      vStr :TString;
      vData :TFarDialogItemData;
    begin
      Result := 0;
      vLen := FarSendDlgMessage(ADlg, DM_GETTEXT, AItemID, 0);
//    vLen := FarSendDlgMessage(ADlg, DM_GETTEXTLENGTH, AItemID, 0);
      if vLen > 0 then begin
        SetLength(vStr, vLen);
       {$ifdef Far3}
        vData.StructSize := SizeOf(vData);
       {$endif Far3}
        vData.PtrLength := vLen;
        vData.PtrData := PFarChar(vStr);
        FarSendDlgMessage(ADlg, DM_GETTEXT, AItemID, @vData);
        vStr := Trim(vStr);
        Result := Length(vStr);
      end;
    end;

  var
    vLen :Integer;
    vInfo :TFarDialogItem;
    vSelect :TEditorSelect;
    vCoord :TCoord;
  begin
    if (AMsg = DN_GOTFOCUS) or (AMsg = DN_KILLFOCUS) then begin
      FarSendDlgMessage(ADlg,  DM_GETDLGITEMSHORT, AID, @vInfo);
      if (vInfo.ItemType in [DI_EDIT, DI_PSWEDIT, DI_FIXEDIT ]) and (vInfo.Flags and DIF_EDITOR = 0) then begin
//      TraceF('ProcessDialogEventW: GotFocus, ID=%d...', [vID]);
        FillZero(vSelect, SizeOf(vSelect));
       {$ifdef Far3}
        vSelect.StructSize := SizeOf(vSelect);
       {$endif Far3}
        if AMsg = DN_GOTFOCUS then begin
          if vInfo.ItemType = DI_FIXEDIT then
            vLen := GetTextLen(AID)
          else
            vLen := FarSendDlgMessage(ADlg, DM_GETTEXT, AID, nil);
//          vLen := FarSendDlgMessage(ADlg, DM_GETTEXTLENGTH, AID, nil);

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


end.

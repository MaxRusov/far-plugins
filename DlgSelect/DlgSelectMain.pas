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
    PluginW,
    FarCtrl;

  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { Ёкспортируемые процедуры                                                    }
 {-----------------------------------------------------------------------------}

  procedure SetStartupInfoW(var psi: TPluginStartupInfo); stdcall;
  begin
    hModule := psi.ModuleNumber;
    FARAPI := psi;
    FARSTD := psi.fsf^;
  end;


  function ProcessDialogEventW(AEvent :Integer; AParam :PFarDialogEvent) :Integer; stdcall;
  var
    vID, vLen :Integer;
    vInfo :TFarDialogItem;
    vSelect :TEditorSelect;
    vCoord :TCoord;
  begin
    if AEvent = DE_DEFDLGPROCINIT then begin
      if (AParam.Msg = DN_GOTFOCUS) or (AParam.Msg = DN_KILLFOCUS) then begin
        vID := AParam.Param1;
        FARAPI.SendDlgMessage(AParam.hDlg,  DM_GETDLGITEMSHORT, vID, TIntPtr(@vInfo));
        if (vInfo.ItemType in [DI_EDIT, DI_PSWEDIT, DI_FIXEDIT]) and (vInfo.Flags and DIF_EDITOR = 0) then begin
//        TraceF('ProcessDialogEventW: GotFocus, ID=%d...', [vID]);
          FillChar(vSelect, SizeOf(vSelect), 0);
          if AParam.Msg = DN_GOTFOCUS then begin
            vLen := FARAPI.SendDlgMessage(AParam.hDlg, DM_GETTEXTLENGTH, vID, 0);

            vSelect.BlockType := BTYPE_STREAM;
            vSelect.BlockWidth := vLen;
            vSelect.BlockHeight := 1;
            FARAPI.SendDlgMessage(AParam.hDlg, DM_SETSELECTION, vID, TIntPtr(@vSelect));

            vCoord.X := vLen;
            vCoord.Y := 0;
            FARAPI.SendDlgMessage(AParam.hDlg, DM_SETCURSORPOS, vID, TIntPtr(@vCoord));

          end else
            FARAPI.SendDlgMessage(AParam.hDlg, DM_SETSELECTION, vID, TIntPtr(@vSelect));
        end;
      end;
    end;
    Result := 0;
  end;

end.

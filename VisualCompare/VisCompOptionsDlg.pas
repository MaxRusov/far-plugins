{$I Defines.inc}

unit VisCompOptionsDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{* Диалог опций                                                               *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
    FarDlg,
    VisCompCtrl;


  function OptionsDlg :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  type
    TOptionsDlg = class(TFarDialog)
    public
      constructor Create; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
    end;


  constructor TOptionsDlg.Create; {override;}
  begin
    inherited Create;
  end;


  const
    IdAutoscroll    = 1;
    IdEdtTab        = 3;
    IdCancel        = 6;

  procedure TOptionsDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 10;
  begin
    FHelpTopic := 'Options';
    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strTitle)),

        NewItemApi(DI_CHECKBOX,  5,  2,   -1, -1,   0, GetMsg(strAutoscroll)),

        NewItemApi(DI_Text,      5,  4,   DX-10,  -1,   0, GetMsg(strTabSize)),
        NewItemApi(DI_FixEdit,   5,  5,   3,  -1,   0),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) )
      ], @FItemCount
    );
  end;


  procedure TOptionsDlg.InitDialog; {override;}
  begin
    SetText(IdEdtTab, Int2Str(optTabSize));
    SetChecked(IdAutoscroll,  optEdtAutoscroll);
  end;


  function TOptionsDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  var
    vTabSize :Integer;
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      vTabSize := Str2Int(GetText(IdEdtTab));
      if (vTabSize <= 0) or (vTabSize > 9) then
        AppErrorIdFmt(strErrInvalidTabSize, [1, 9]);

      optTabSize := Str2Int(GetText(IdEdtTab));
      optEdtAutoscroll := GetChecked(IdAutoscroll);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function OptionsDlg :Boolean;
  var
    vDlg :TOptionsDlg;
    vRes :Integer;
  begin
    Result := False;

    ReadSetup;
    vDlg := TOptionsDlg.Create;
    try
      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      WriteSetup;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}

unit FarColorDlg;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Диалог настройки цвета                                                     *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

    PluginW,
    FarKeysW,
    FarCtrl,
    FarDlg;

  var
    ColorDlgResBase :Integer;

  type
    TColorDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FColor   :Integer;
      FSample  :TString;
      FFixedBG :Integer;
      FFixedFG :Integer;

      procedure DrawSample;

      function GetColor :Integer;
      procedure SetColor(AValue :Integer);
    end;


  function ColorDlg(const ATitle :TString; var AColor :Integer; AFixedBG :Integer = -1; AFixedFG :Integer = -1) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TColorDlg                                                                   }
 {-----------------------------------------------------------------------------}

  const
    IdRadio1  = 2;
    IdRadio2  = 19;
    IdSample  = 36;
    IdSetBut  = 38;


  procedure TColorDlg.Prepare; {override;}
  const
    DX = 39;
    DY = 15;
  begin
    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,  3,  1,   DX-6, DY-2, 0, GetMsg(ColorDlgResBase){'Color'} ),

        NewItemApi(DI_SingleBox, 5,  2,  14, 6, 0,  GetMsg(ColorDlgResBase+1){'Foreground'} ),

        NewItemApi(DI_RadioButton,  6,  3,  3,  1,  DIF_GROUP or DIF_MOVESELECT or DIF_SETCOLOR or $07),
        NewItemApi(DI_RadioButton,  9,  3,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $17),
        NewItemApi(DI_RadioButton, 12,  3,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $20),
        NewItemApi(DI_RadioButton, 15,  3,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $30),

        NewItemApi(DI_RadioButton,  6,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $47),
        NewItemApi(DI_RadioButton,  9,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $57),
        NewItemApi(DI_RadioButton, 12,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $60),
        NewItemApi(DI_RadioButton, 15,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $70),

        NewItemApi(DI_RadioButton,  6,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $87),
        NewItemApi(DI_RadioButton,  9,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $97),
        NewItemApi(DI_RadioButton, 12,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $A0),
        NewItemApi(DI_RadioButton, 15,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $B0),

        NewItemApi(DI_RadioButton,  6,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $C0),
        NewItemApi(DI_RadioButton,  9,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $D0),
        NewItemApi(DI_RadioButton, 12,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $E0),
        NewItemApi(DI_RadioButton, 15,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $F0),

        NewItemApi(DI_SingleBox, 20,  2,   14, 6, 0, GetMsg(ColorDlgResBase+2){'Background'} ),

        NewItemApi(DI_RadioButton, 21,  3,  3,  1,  DIF_GROUP or DIF_MOVESELECT or DIF_SETCOLOR or $07),
        NewItemApi(DI_RadioButton, 24,  3,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $17),
        NewItemApi(DI_RadioButton, 27,  3,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $20),
        NewItemApi(DI_RadioButton, 30,  3,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $30),

        NewItemApi(DI_RadioButton, 21,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $47),
        NewItemApi(DI_RadioButton, 24,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $57),
        NewItemApi(DI_RadioButton, 27,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $60),
        NewItemApi(DI_RadioButton, 30,  4,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $70),

        NewItemApi(DI_RadioButton, 21,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $87),
        NewItemApi(DI_RadioButton, 24,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $97),
        NewItemApi(DI_RadioButton, 27,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $A0),
        NewItemApi(DI_RadioButton, 30,  5,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $B0),

        NewItemApi(DI_RadioButton, 21,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $C0),
        NewItemApi(DI_RadioButton, 24,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $D0),
        NewItemApi(DI_RadioButton, 27,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $E0),
        NewItemApi(DI_RadioButton, 30,  6,  3,  1,  DIF_MOVESELECT or DIF_SETCOLOR or $F0),

        NewItemApi(DI_SingleBox,   5, 8, DX-10, 3,  0,  GetMsg(ColorDlgResBase+3){'Sample'}),
        NewItemApi(DI_USERCONTROL, 6, 9, DX-12, 1,  DIF_NOFOCUS),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(ColorDlgResBase+4){'Set'} ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(ColorDlgResBase+5){'Cancel'} )
      ],
      @FItemCount
    );
  end;


  procedure TColorDlg.InitDialog; {override;}
  var
    I, vColor :Integer;
  begin
    vColor := FColor;
    if FFixedBG <> -1 then begin
      vColor := (vColor and $0F) + (FFixedBG and $F0);
      for I := 0 to 16 do
        SendMsg(DM_ENABLE, IdRadio2 - 1 + I, 0);
    end;
    SetColor(vColor);
  end;


  function TColorDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      FColor := GetColor;
      if FFixedBG <> -1 then
        FColor := FColor and $0F;
    end;
    Result := True;
  end;


  function TColorDlg.GetColor :Integer;
  begin
    Result := GetRadioIndex(IdRadio1, 16) + (GetRadioIndex(IdRadio2, 16) shl 4);
  end;


  procedure TColorDlg.SetColor(AValue :Integer);
  begin
    SetChecked(IdRadio1 + AValue and $0F, True);
    SetChecked(IdRadio2 + ((AValue and $F0) shr 4), True);
  end;


  procedure TColorDlg.DrawSample;
  var
    vColor, vLen :Integer;
    vRect :TSmallrect;
    vBuf :array[0..128] of TChar;
  begin
    vColor := GetColor;
    if (vColor < 0) or (vColor > $FF) then
      vColor := $0F;

    vRect := GetScreenItemRect(IdSample);
    vLen := vRect.Right - vRect.Left + 1;

    MemFillChar(@vBuf, vLen, ' ');
    StrMove(@vBuf[0], PTChar(FSample), IntMin(vLen, Length(FSample)));
    vBuf[vLen] := #0;

    FARAPI.Text(vRect.Left, vRect.Top, vColor, vBuf);
  end;


  function TColorDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    case Msg of
      DN_DRAWDLGITEM:
        if Param1 = IdSample then
          DrawSample;
//    DN_BTNCLICK:
//      if Param1 < IdSetBut then
//        ChangeColor;
    end;
    Result := inherited DialogHandler(Msg, Param1, Param2);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function ColorDlg(const ATitle :TString; var AColor :Integer; AFixedBG :Integer = -1; AFixedFG :Integer = -1) :Boolean;
  var
    vDlg :TColorDlg;
    vRes :Integer;
  begin
    vDlg := TColorDlg.Create;
    try
      vDlg.FColor   := AColor;
      vDlg.FSample  := 'Text Text Text Text Text';
      vDlg.FFixedBG := AFixedBG;
      vDlg.FFixedFG := AFixedFG;

      vRes := vDlg.Run;

      Result := (vRes <> -1) and (vRes <> IdCancel);
      if Result then
        AColor := vDlg.FColor;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


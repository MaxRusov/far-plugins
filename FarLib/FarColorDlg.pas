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
    Messages,
    CommDlg,  
    MixTypes,
    MixUtils,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg;

  var
    ColorDlgResBase :Integer;

  const
    UndefAttr = DWORD(-1);
(*
   {$ifdef Far3}
    UndefAttr = DWORD(0);
   {$else}
    UndefAttr = DWORD(-1);
   {$endif Far3}
*)

  type
    TColorDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FColor   :TFarColor;
      FSample  :TString;

      FFixedBG :DWORD;
      FFixedFG :DWORD;

      FLock    :Integer;

      procedure DMKey(AKey :Integer);
      procedure DrawSample;

      procedure UpdateControls;
    end;

  function FarAttrToCOLORREF(Attr :DWORD) :DWORD;

  function ColorDlg(const ATitle :TString; var AColor :TFarColor; AFixedBG :DWORD = UndefAttr; AFixedFG :DWORD = UndefAttr) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;



 {$ifdef Far3}
  const
    MaxCustomColors = 16;

  type
    TCustomColors = array[0..MaxCustomColors - 1] of COLORREF;

  var
    GUserColors :TCustomColors;


(*
  function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
  begin
    Result := 0;
//  TraceF('DialogHook: Msg=%d', [Msg]);
    if Msg = WM_Notify then begin
//    with POFNotify(LParam).hdr do begin
      with PNMHdr(LParam)^ do begin
        TraceF('DialogHook: NotifyCode=%d', [Code]);
      end;
    end;
  end;
*)

  function WinChooseColor(var AColor :COLORREF) :Boolean;
  var
    vRec :TChooseColor;
  begin
    FillZero(vRec, SizeOf(vRec));
    vRec.lStructSize := SizeOf(vRec);
    vRec.Flags := CC_RGBINIT or CC_FULLOPEN {or CC_ENABLEHOOK};
    vRec.lpCustColors := @GUserColors[0];
    vRec.hWndOwner := FarAdvControl(ACTL_GETFARHWND, nil);
//  vRec.lpfnHook := DialogHook;
    vRec.rgbResult := AColor;
    Result := ChooseColor(vRec);
    if Result then
      AColor := vRec.rgbResult;
  end;
 {$endif Far3}


  function FarAttrToCOLORREF(Attr :DWORD) :DWORD;
  const
    cColors :array[0..15] of COLORREF =
      ($000000, $7F0000, $007F00, $7F7F00, $00007F, $7F007F, $007F7F, $C0C0C0, $7F7F7F, $FF0000, $00FF00, $FFFF00, $0000FF, $FF00FF, $00FFFF, $FFFFFF);
  begin
    if Attr <= $0F then
      Result := cColors[Attr]
    else
      Result := Attr and $00FFFFFF;
  end;


 {-----------------------------------------------------------------------------}
 { TColorDlg                                                                   }
 {-----------------------------------------------------------------------------}

  const
    IdRadio1   = 2;
   {$ifdef Far3}
    IdMoreRad1 = 18;
    IdMoreBut1 = 19;
   {$endif Far3}
    IdRadio2   = 19 {$ifdef Far3}+2{$endif};
   {$ifdef Far3}
    IdMoreRad2 = 37;
    IdMoreBut2 = 38;
   {$endif Far3}
    IdSample   = 36 {$ifdef Far3}+4{$endif};
    IdSetBut   = 38 {$ifdef Far3}+4{$endif};


  procedure TColorDlg.Prepare; {override;}
  const
    DX = 39;
   {$ifdef Far3}
    DY = 17;
   {$else}
    DY = 15;
   {$endif Far3}
  begin
    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,  3,  1,   DX-6, DY-2, 0, GetMsg(ColorDlgResBase){'Color'} ),

        NewItemApi(DI_SingleBox, 5,  2,  14, {$ifdef Far3}8{$else}6{$endif}, 0,  GetMsg(ColorDlgResBase+1){'Foreground'} ),

        NewItemApi(DI_RadioButton,  6,  3,  3,  1,  DIF_GROUP or DIF_MOVESELECT),
        NewItemApi(DI_RadioButton,  9,  3,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 12,  3,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 15,  3,  3,  1,  DIF_MOVESELECT),

        NewItemApi(DI_RadioButton,  6,  4,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton,  9,  4,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 12,  4,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 15,  4,  3,  1,  DIF_MOVESELECT),

        NewItemApi(DI_RadioButton,  6,  5,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton,  9,  5,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 12,  5,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 15,  5,  3,  1,  DIF_MOVESELECT),

        NewItemApi(DI_RadioButton,  6,  6,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton,  9,  6,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 12,  6,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 15,  6,  3,  1,  DIF_MOVESELECT),

       {$ifdef Far3}
        NewItemApi(DI_RadioButton,  8,  8,  3,  1,  DIF_NOFOCUS),
        NewItemApi(DI_Button,       8,  8,  8,  1,  DIF_BTNNOCLOSE, 'More' ),
       {$endif Far3}

        NewItemApi(DI_SingleBox, 20,  2,   14, {$ifdef Far3}8{$else}6{$endif}, 0, GetMsg(ColorDlgResBase+2){'Background'} ),

        NewItemApi(DI_RadioButton, 21,  3,  3,  1,  DIF_GROUP or DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 24,  3,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 27,  3,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 30,  3,  3,  1,  DIF_MOVESELECT),

        NewItemApi(DI_RadioButton, 21,  4,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 24,  4,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 27,  4,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 30,  4,  3,  1,  DIF_MOVESELECT),

        NewItemApi(DI_RadioButton, 21,  5,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 24,  5,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 27,  5,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 30,  5,  3,  1,  DIF_MOVESELECT),

        NewItemApi(DI_RadioButton, 21,  6,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 24,  6,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 27,  6,  3,  1,  DIF_MOVESELECT),
        NewItemApi(DI_RadioButton, 30,  6,  3,  1,  DIF_MOVESELECT),

       {$ifdef Far3}
        NewItemApi(DI_RadioButton, 23,  8,  3,  1,  DIF_NOFOCUS),
        NewItemApi(DI_Button,      23,  8,  8,  1,  DIF_BTNNOCLOSE, 'More' ),
       {$endif Far3}

        NewItemApi(DI_SingleBox,   5, DY-7, DX-10, 3,  0,  GetMsg(ColorDlgResBase+3){'Sample'}),
        NewItemApi(DI_USERCONTROL, 6, DY-6, DX-12, 1,  DIF_NOFOCUS),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(ColorDlgResBase+4){'Set'} ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(ColorDlgResBase+5){'Cancel'} )
      ],
      @FItemCount
    );
  end;


  procedure TColorDlg.InitDialog; {override;}
  var
    I :Integer;
    vColor :DWORD;
  begin
    if FFixedBG <> UndefAttr then begin
      FColor := MakeColor(GetColorFG(FColor), FFixedBG);
      for I := IdRadio2 - 1 to IdSample - 2 do
        SendMsg(DM_ENABLE, I, 0);
    end;
    if FFixedFG <> UndefAttr then begin
      FColor := MakeColor(FFixedFG, GetColorBG(FColor));
      for I := IdRadio1 - 1 to IdRadio2 - 2 do
        SendMsg(DM_ENABLE, I, 0);
    end;
    UpdateControls;

    vColor := GetColorFG(FColor);
    if vColor <= $0F then
      SendMsg(DM_SetFocus, IdRadio1 + vColor, 0);
  end;


  function TColorDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      if FFixedBG <> UndefAttr then
        FColor := ChangeBG(FColor, UndefColor);
    end;
    Result := True;
  end;


  procedure TColorDlg.UpdateControls;
  var
    vColor :DWORD;
  begin
    Inc(FLock);
    try
      vColor := GetColorFG(FColor);
      if vColor <= $0F then
        SetChecked(IdRadio1 + vColor, True)
     {$ifdef Far3}
      else
        SetChecked(IdMoreRad1, True)
     {$endif Far3};

      vColor := GetColorBG(FColor);
      if vColor <= $0F then
        SetChecked(IdRadio2 + vColor, True)
     {$ifdef Far3}
      else
        SetChecked(IdMoreRad2, True)
     {$endif Far3};

    finally
      Dec(FLock);
    end;
  end;


  procedure TColorDlg.DrawSample;
  var
    vLen :Integer;
    vRect :TSmallrect;
    vBuf :array[0..128] of TChar;
  begin
    vRect := GetScreenItemRect(IdSample);
    vLen := vRect.Right - vRect.Left + 1;

    MemFillChar(@vBuf, vLen, ' ');
    StrMove(@vBuf[0], PTChar(FSample), IntMin(vLen, Length(FSample)));
    vBuf[vLen] := #0;

    FARAPI.Text(vRect.Left, vRect.Top, FColor, vBuf);
  end;


  procedure TColorDlg.DMKey(AKey :Integer);
 {$ifdef Far3}
  var
    vRec :TInputRecord;
  begin
    FarKeyToInputRecord(AKey, vRec);
    SendMsg(DM_KEY, 1, @vRec);
 {$else}
  begin
    SendMsg(DM_KEY, 1, @AKey);
 {$endif Far3}
  end;


  function TColorDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  var
    vBase :Integer;
  begin
    case AKey of
      KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT:
        if AID in [IdRadio1..IdRadio1+15, IdRadio2..IdRadio2+15] then begin
          vBase := IntIf(AID < IDRadio2, IdRadio1, IdRadio2);
          Dec(AID, vBase);

          case AKey of
            KEY_LEFT:
              AID := IntIf(AID > 0, AID - 1, 15);
            KEY_RIGHT:
              AID := IntIf(AID < 15, AID + 1, 0);
            KEY_UP:
              if AID = 0 then
                AID := 15
              else if AID < 4 then
                AID := AID - 1 + 12
              else
                Dec(AID, 4);
            KEY_DOWN:
              if AID = 15 then
                AID := 0
              else if AID >= 12 then
                AID := AID + 1 - 12
              else
                Inc(AID, 4);
          end;

          SendMsg(DM_SetFocus, vBase + AID, 0);
          DMKey(VK_Space);
          Result := True;
          Exit;
        end;
    end;
    Result := inherited KeyDown(AID, AKey);
  end;



  function TColorDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  const
    cColors :array[0..15] of byte = ($07,$17,$20,$30, $47,$57,$60,$70, $87,$97,$A0,$B0, $C0,$D0,$E0,$F0);
  var
    vIdx :Integer;
    vColor :DWORD;
  begin
    case Msg of
      DN_DRAWDLGITEM:
        if Param1 = IdSample then
          DrawSample;

      DN_CTLCOLORDLGITEM:
        if Param1 in [IdRadio1..IdRadio1+15, IdRadio2..IdRadio2+15] then begin
          if Param1 < IDRadio2 then
            vIdx := Param1 - IdRadio1
          else
            vIdx := Param1 - IdRadio2;
         {$ifdef Far3}
          PFarDialogItemColors(Param2)^.Colors[0] := MakeColor(cColors[vIdx] and $0F, (cColors[vIdx] and $F0) shr 4);
          Result := 1;
         {$else}
          Result := cColors[vIdx];
         {$endif Far3}
          Exit;
        end;

      DN_BTNCLICK:
        if FLock = 0 then begin
          if Param1 in [IdRadio1..IdRadio1+15] then begin
            vColor := IntMax(GetRadioIndex(IdRadio1, 16), 0);
            FColor := MakeColor(vColor, GetColorBG(FColor));
          end else
          if Param1 in [IdRadio2..IdRadio2+15] then begin
            vColor := IntMax(GetRadioIndex(IdRadio2, 16), 0);
            FColor := MakeColor(GetColorFG(FColor), vColor);
          end;
         {$ifdef Far3}
          if Param1 = IdMoreBut1 then begin
            vColor := FarAttrToCOLORREF(GetColorFG(FColor));
            if WinChooseColor(vColor) then begin
              FColor := MakeColor(vColor or $FF000000, GetColorBG(FColor));
              UpdateControls;
            end;
          end else
          if Param1 = IdMoreBut2 then begin
            vColor := FarAttrToCOLORREF(GetColorBG(FColor));
            if WinChooseColor(vColor) then begin
              FColor := MakeColor(GetColorFG(FColor), vColor or $FF000000);
              UpdateControls;
            end;
          end;
         {$endif Far3}
          SendMsg(DM_REDRAW, 0, 0);
        end;
    end;
    Result := inherited DialogHandler(Msg, Param1, Param2);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function ColorDlg(const ATitle :TString; var AColor :TFarColor; AFixedBG :DWORD = UndefAttr; AFixedFG :DWORD = UndefAttr) :Boolean;
  var
    vDlg :TColorDlg;
  begin
    vDlg := TColorDlg.Create;
    try
      vDlg.FColor   := AColor;
      vDlg.FSample  := 'Text Text Text Text Text';
      vDlg.FFixedBG := AFixedBG;
      vDlg.FFixedFG := AFixedFG;

      Result := vDlg.Run = IdSetBut;

      if Result then
        AColor := vDlg.FColor;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}

unit FarFMLoginDlg;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg,

    FarFMCtrl;


  function LoginDlg(const ARequest :TString; var AResponse :TString; const AValidResp :TString) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  const
    IdPrompt1 = 1;
    IdEdit1   = 2;
    IdPrompt2 = 3;
    IdEdit2   = 4;
    IdOk      = 6;
    IdCancel  = 7;

  type
    TLoginDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FValidResp :TString;
      FRequest   :TString;
      FResponse  :TString;
    end;


  procedure TLoginDlg.Prepare; {override;}
  const
    DX = 70;
    DY = 10;
  begin
//  FHelpTopic := 'ManualAuth';
    FGUID := cLoginDlgID;
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1, DX-6, DY-2, 0, GetMsg(strAuthTitle)),

        NewItemApi(DI_Text,      5,  2, DX-10, -1, 0, GetMsg(strRequestPrompt)),
        NewItemApi(DI_Edit,      5,  3, DX-10, -1, DIF_READONLY, '' ),

        NewItemApi(DI_Text,      5,  4, DX-10, -1, 0, GetMsg(strResponsePrompt)),
        NewItemApi(DI_Edit,      5,  5, DX-10, -1, 0, '' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR, ''),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk)),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel))
      ], @FItemCount
    );
  end;


  procedure TLoginDlg.InitDialog; {override;}
  begin
    SetText(IdEdit1, FRequest);

    if FValidResp = '' then begin
      SetEnabled(IdPrompt2, False);
      SetEnabled(IdEdit2, False);
    end;
  end;


  function TLoginDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      FResponse := Trim(GetText(IdEdit2));
      if (FValidResp <> '') and (UpCompareSubStr(FValidResp, FResponse) <> 0)  then
        AppErrorId(strResponseError);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function LoginDlg(const ARequest :TString; var AResponse :TString; const AValidResp :TString) :Boolean;
  var
    vDlg :TLoginDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TLoginDlg.Create;
    try
      vDlg.FRequest := ARequest;
      vDlg.FValidResp := AValidResp;

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      AResponse := vDlg.FResponse;
      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


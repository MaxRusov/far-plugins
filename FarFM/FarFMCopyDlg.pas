{$I Defines.inc}

unit FarFMCopyDlg;

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


  function CopyDlg(AMove :Boolean; const APrompt :TString; var AFolder :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  const
    IdPrompt = 1;
    IdEdit   = 2;
    IdOk     = 4;
    IdCancel = 5;

  type
    TCopyDlg = class(TFarDialog)
    public
      constructor CreateEx(AMove :Boolean);

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FMove   :Boolean;
      FPrompt :TString;
      FFolder :TString;
    end;


  constructor TCopyDlg.CreateEx(AMove :Boolean);
  begin
    FMove := AMove;
    Create;
  end;


  procedure TCopyDlg.Prepare; {override;}
  const
    DX = 70;
    DY =  8;
  begin
//  FHelpTopic := 'Copy';
    FGUID := cCopyDlgID;
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1, DX-6, DY-2, 0, FarCtrl.GetMsg(IntIf(FMove, Byte(strMoveTitle), Byte(strCopyTitle)))),
        NewItemApi(DI_Text,      5,  2, DX-10, -1, 0, '' ),
        NewItemApi(DI_Edit,      5,  3, DX-10, -1, 0, '' ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR, ''),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, FarCtrl.GetMsg(IntIf(FMove, Byte(strMoveBut), Byte(strCopyBut)))),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel))
      ], @FItemCount
    );
  end;


  procedure TCopyDlg.InitDialog; {override;}
  begin
    SetText(IdPrompt, FPrompt);
    SetText(IdEdit, FFolder);
  end;


  function TCopyDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      FFolder := Trim(GetText(IdEdit));
      if not IsFullFilePath(FFolder) then
        AppErrorID(strPathNotAbsolute);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CopyDlg(AMove :Boolean; const APrompt :TString; var AFolder :TString) :Boolean;
  var
    vDlg :TCopyDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TCopyDlg.CreateEx(AMove);
    try
      vDlg.FPrompt := APrompt;
      vDlg.FFolder := AFolder;

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      AFolder := vDlg.FFolder;
      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


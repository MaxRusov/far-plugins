{$I Defines.inc}

unit VisCompPromptDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{* Диалог сравнения                                                           *}
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


  function CompareDlg(var AFolder1, AFolder2 :TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


  const
    IdEdtFolder1    = 2;
    IdEdtFolder2    = 4;
    IdEdtMask       = 6;
    IdChkRecursive  = 8;
    IdChkSkipHidden = 9;
    IdChkSkipOrphan = 10;
    IdChkContents   = 11;
    IdCancel        = 14;

  type
    TCompareDlg = class(TFarDialog)
    public
      constructor Create; override;
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

    private
      FFolder1 :TString;
      FFolder2 :TString;
    end;


  constructor TCompareDlg.Create; {override;}
  begin
    inherited Create;
  end;


  procedure TCompareDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 16;
  var
    vX2 :Integer;
  begin
//  FHelpTopic := 'Compare';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 15;

    vX2 := DX div 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strTitle)),

        NewItemApi(DI_Text,     5,   2,   DX-10,  -1,   0, GetMsg(strLeftFolder) ),
        NewItemApi(DI_Edit,     5,   3,   DX-10,  -1,   DIF_HISTORY, '', 'VisCompare.Folder' ),

        NewItemApi(DI_Text,     5,   4,   DX-10,  -1,   0, GetMsg(strRightFolder) ),
        NewItemApi(DI_Edit,     5,   5,   DX-10,  -1,   DIF_HISTORY, '', 'VisCompare.Folder' ),

        NewItemApi(DI_Text,     5,   6,   DX-10, -1,   0, GetMsg(strFileMask) ),
        NewItemApi(DI_Edit,     5,   7,   DX-10, -1,   DIF_HISTORY, '', 'VisCompare.FileMasks' ),

        NewItemApi(DI_Text,     0,   8,   -1,    -1,   DIF_SEPARATOR),

        NewItemApi(DI_CHECKBOX, 5,   9,   -1,    -1,   0, GetMsg(strRecursive)),
        NewItemApi(DI_CHECKBOX, 5,  10,   -1,    -1,   0, GetMsg(strSkipHidden)),
        NewItemApi(DI_CHECKBOX, 5,  11,   vX2-6, -1,   0, GetMsg(strDoNotScanOrphan)),

        NewItemApi(DI_CHECKBOX, vX2, 9,   DX-vX2-5,  -1,  0, GetMsg(strCompareContents)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) )
      ]
    );
  end;


  procedure TCompareDlg.InitDialog; {override;}
  begin
    SetText(IdEdtFolder1, FFolder1);
    SetText(IdEdtFolder2, FFolder2);
    SetText(IdEdtMask,    optScanFileMask);

    SetChecked(IdChkRecursive,  optScanRecursive);
    SetChecked(IdChkSkipHidden, optNoScanHidden);
    SetChecked(IdChkSkipOrphan, optNoScanOrphan);
    SetChecked(IdChkContents,   optScanContents);
  end;


  function TCompareDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      FFolder1 := Trim(GetText(IdEdtFolder1));
      FFolder2 := Trim(GetText(IdEdtFolder2));
      if not IsFullFilePath(FFolder1) then
        AppErrorFmt('Invalid path: %s', [FFolder1]);
      if not IsFullFilePath(FFolder2) then
        AppErrorFmt('Invalid path: %s', [FFolder2]);

      optScanFileMask := Trim(GetText(IdEdtMask));

      optScanRecursive := GetChecked(IdChkRecursive);
      optNoScanHidden := GetChecked(IdChkSkipHidden);
      optNoScanOrphan := GetChecked(IdChkSkipOrphan);
      optScanContents := GetChecked(IdChkContents);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CompareDlg(var AFolder1, AFolder2 :TString) :Boolean;
  var
    vDlg :TCompareDlg;
    vRes :Integer;
  begin
    Result := False;
    vDlg := TCompareDlg.Create;
    try
      vDlg.FFolder1 := AFolder1;
      vDlg.FFolder2 := AFolder2;

      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      AFolder1 := vDlg.FFolder1;
      AFolder2 := vDlg.FFolder2;

      WriteSetup;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


end.


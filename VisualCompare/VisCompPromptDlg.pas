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
    Far_API,
    FarCtrl,
    FarDlg,
    FarMenu,
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
    IdChkAsText     = 12;
    IdSetup         = 13;
    IdCancel        = 16;


  type
    TCompareDlg = class(TFarDialog)
    public
      constructor Create; override;
      
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; override;

    private
      FFolder1 :TString;
      FFolder2 :TString;

      procedure CompareTextSetup;
      procedure EnableControls;
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
    vStr :PFarChar;
  begin
    FGUID := cPromptDlgID;
    FHelpTopic := 'Compare';
    FWidth := DX;
    FHeight := DY;

    vStr := GetMsg(strCompareSetup);

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

        NewItemApi(DI_CHECKBOX, vX2,   9,  DX-vX2-5,  -1,  0, GetMsg(strCompareContents)),
        NewItemApi(DI_CHECKBOX, vX2+2, 10, DX-vX2-5,  -1,  0, GetMsg(strCompareAsText)),

        NewItemApi(DI_Button,   DX-8 - StrLen(vStr),  10, -1, -1, DIF_BTNNOCLOSE, vStr ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) )
      ], @FItemCount
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
    SetChecked(IdChkAsText,     optCompareAsText);
    
    EnableControls;
  end;


  function TCompareDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      FFolder1 := Trim(GetText(IdEdtFolder1));
      FFolder2 := Trim(GetText(IdEdtFolder2));
      if not IsFullFilePath(FFolder1) and not IsSpecialPath(FFolder1) then
        AppErrorIdFmt(strInvalidPath, [FFolder1]);
      if not IsFullFilePath(FFolder2) and not IsSpecialPath(FFolder2) then
        AppErrorIdFmt(strInvalidPath, [FFolder2]);

      optScanFileMask := Trim(GetText(IdEdtMask));

      optScanRecursive := GetChecked(IdChkRecursive);
      optNoScanHidden  := GetChecked(IdChkSkipHidden);
      optNoScanOrphan  := GetChecked(IdChkSkipOrphan);
      optScanContents  := GetChecked(IdChkContents);
      optCompareAsText := GetChecked(IdChkAsText);
    end;
    Result := True;
  end;


  procedure TCompareDlg.EnableControls;
  begin
    SendMsg(DM_ENABLE, IdChkAsText, Byte(GetChecked(IdChkContents)));
    SendMsg(DM_ENABLE, IdSetup, Byte(GetChecked(IdChkContents) and GetChecked(IdChkAsText)));
  end;


  procedure TCompareDlg.CompareTextSetup;
  var
    vMenu :TFarMenu;
    vStr :TFarStr;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle2),
    [
      GetMsg(StrMIgnoreEmptyLines),
      GetMsg(StrMIgnoreSpaces),
      GetMsg(StrMIgnoreCase),
      GetMsg(StrMIgnoreCRLF),
      '',
      GetMsg(strMDefaultCodePage)
    ]);
    try
      while True do begin
        vMenu.Checked[0] := optTextIgnoreEmptyLine;
        vMenu.Checked[1] := optTextIgnoreSpace;
        vMenu.Checked[2] := optTextIgnoreCase;
        vMenu.Checked[3] := optTextIgnoreCRLF;

        vStr := GetMsgStr(strMDefaultCodePage) + ' ' + cFormatNames[optDefaultFormat];
        vMenu.Items[5].TextPtr := PFarChar(vStr);

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: optTextIgnoreEmptyLine := not optTextIgnoreEmptyLine;
          1: optTextIgnoreSpace := not optTextIgnoreSpace;
          2: optTextIgnoreCase := not optTextIgnoreCase;
          3: optTextIgnoreCRLF := not optTextIgnoreCRLF;

          5: GetCodePage(optDefaultFormat);
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  function TCompareDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 in [IdChkContents, IdChkAsText] then
          EnableControls
        else
        if Param1 = IdSetup then
          CompareTextSetup
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
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


{******************************************************************************}
{* (c) 2009-2013 Max Rusov                                                    *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{* Диалог опций                                                               *}
{******************************************************************************}

{$I Defines.inc}

unit PanelTabsOptions;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    Far_API,
    FarCtrl,
    FarMenu,
    FarDlg,
    FarColorDlg,

    PanelTabsCtrl,
    TabActionsList;


  function OptionsDlg :Boolean;
  procedure OptionsMenu;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    PanelTabsClasses,
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
    IdShowTabs        =  1;
    IdShowNumbers     =  2;
    IdSeparateTabs    =  3;
    IdStoreSelection  =  4;

    IdNormEdit        =  5;
    IdFixedEdit       =  7;
    IdDelimEdit       =  9;

    IdOk              =  12;
    IdCancel          =  13;


  procedure TOptionsDlg.Prepare; {override;}
  const
    DX = 40;
    DY = 13;
  begin
    FHelpTopic := 'Options';
    FWidth := DX;
    FHeight := DY;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(strOptionsDlgTile)),

        NewItemApi(DI_CHECKBOX,  5,  2,  -1, -1,  0, GetMsg(strDShowTabs)),
        NewItemApi(DI_CHECKBOX,  5,  3,  -1, -1,  0, GetMsg(strDShowNumbers)),
        NewItemApi(DI_CHECKBOX,  5,  4,  -1, -1,  0, GetMsg(strDSeparateTabs)),
        NewItemApi(DI_CHECKBOX,  5,  5,  -1, -1,  0, GetMsg(strDStoreSelection)),

        NewItemApi(DI_Edit,      5,  6,   8, -1,  0),
        NewItemApi(DI_Text,     14,  6,  -1, -1,  0, GetMsg(strDTabFormat) ),

        NewItemApi(DI_Edit,      5,  7,   8, -1,  0),
        NewItemApi(DI_Text,     14,  7,  -1, -1,  0, GetMsg(strDFixedTabFormat) ),

        NewItemApi(DI_Edit,      5,  8,   4, -1,  0),
        NewItemApi(DI_Text,     14,  8,  -1, -1,  0, GetMsg(strDTabDelimiter) ),

        NewItemApi(DI_Text,      0, DY-4, -1, -1, DIF_SEPARATOR),
        NewItemApi(DI_DefButton, 0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strOk) ),
        NewItemApi(DI_Button,    0, DY-3, -1, -1, DIF_CENTERGROUP, GetMsg(strCancel) )

      ], @FItemCount
    );
  end;

  procedure TOptionsDlg.InitDialog; {override;}
  begin
    SetChecked(IdShowTabs, optShowTabs);
    SetChecked(IdShowNumbers, optShowNumbers);
    SetChecked(IdSeparateTabs, optSeparateTabs);
    SetChecked(IdStoreSelection, optStoreSelection);

    SetText(IdNormEdit, optNormTabFmt);
    SetText(IdFixedEdit,  optFixedTabFmt);
    SetText(IdDelimEdit,  optTabDelimiter);
  end;


  function TOptionsDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if (ItemID <> -1) and (ItemID <> IdCancel) then begin
      optShowTabs := GetChecked(IdShowTabs);
      optShowNumbers := GetChecked(IdShowNumbers);
      optSeparateTabs := GetChecked(IdSeparateTabs);
      optStoreSelection := GetChecked(IdStoreSelection);

      optNormTabFmt := GetText(IdNormEdit);
      optFixedTabFmt := GetText(IdFixedEdit);
      optTabDelimiter := GetText(IdDelimEdit);
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

    vDlg := TOptionsDlg.Create;
    try
      vRes := vDlg.Run;
      if (vRes = -1) or (vRes = IdCancel) then
        Exit;

      TabsManager.NeedRealign;
      WriteSetup;

      Result := True;
    finally
      FreeObj(vDlg);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ColorsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strColorsTitle),
    [
      GetMsg(strColBackground),
      GetMsg(strColInactiveTab),
      GetMsg(strColActiveTab),
      GetMsg(strColAddButton),
      GetMsg(strColShortcut),
      {!!!Localize}
      '&6 Delimiter',
      '',
      GetMsg(strRestoreDefaults)
    ]);
    try
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        TabsManager.PaintTabs;
        if not vMenu.Run then
          Exit;

        TabsManager.PaintTabs;
        case vMenu.ResIdx of
          0: ColorDlg('', optBkColor);
          1: ColorDlg('', optPassiveTabColor);
          2: ColorDlg('', optActiveTabColor);
          3: ColorDlg('', optButtonColor);
          4: ColorDlg('', optNumberColor);
          5: ColorDlg('', optDelimiterColor);
//        6:
          7: RestoreDefColor;
        end;

        WriteSetup;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsMenuTile),
    [
      GetMsg(strMGeneral),
      GetMsg(strMMouseActions),
      GetMsg(strMColors)
    ]);
    try
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        TabsManager.PaintTabs;
        if not vMenu.Run then
          Exit;

        TabsManager.PaintTabs;
        case vMenu.ResIdx of
          0: OptionsDlg;
          1: ActionsList(TabsManager.Actions);
          2: ColorsMenu;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;

end.

{$I Defines.inc}

unit FarListDlg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Типовой диалог - список                                                    *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarDlg,
    FarGrid;


  const
    cDlgMinWidth  = 30;
    cDlgMinHeight = 5;

    IdFrame = 0;
    IdList = 1;

  type
    TFarListDlg = class(TFarDialog)
    public
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    protected
      FGrid           :TFarGrid;
      FMenuMaxWidth   :Integer;
      FMaxHeightPerc  :Integer;   { Ограничитель высоты диалога }
      FBottomAlign    :Boolean;   { Прижимать диалог к нижней части окна }

      procedure ResizeDialog;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode = lmScroll);
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TFarListDlg                                                                 }
 {-----------------------------------------------------------------------------}

  destructor TFarListDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    inherited Destroy;
  end;


  procedure TFarListDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_USERCONTROL, 3, 2, DX - 6, DY - 4, 0, '' )
      ],
      @FItemCount
    );
    FGrid := TFarGrid.CreateEx(Self, IdList);
  end;


  procedure TFarListDlg.ResizeDialog;
  var
    vWidth, vHeight, vMaxHeight, vTop :Integer;
    vRect :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vSize.CX - 4 then
      vWidth := vSize.CX - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 4;
    if vHeight > vSize.CY - 2 then
      vHeight := vSize.CY - 2;

    if FMaxHeightPerc <> 0 then begin
      vMaxHeight := MulDiv(vSize.CY, FMaxHeightPerc, 100);
      if vHeight > vMaxHeight then
        vHeight := vMaxHeight;
    end;

    vHeight := IntMax(vHeight, cDlgMinHeight);

    vTop := -1;
    if FBottomAlign then
      vTop := IntMin(vSize.cy div 2, vSize.cy - vHeight - 2);

    SetDlgPos(-1, vTop, vWidth, vHeight);

    vRect.Left := 2;
    vRect.Top := 1;
    vRect.Right := vWidth - 3;
    vRect.Bottom := vHeight - 2;
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    SRectGrow(vRect, -1, -1);
    if vRect.Bottom - vRect.Top + 2 <= FGrid.RowCount then
      Inc(vRect.Right);
    SendMsg(DM_SETITEMPOSITION, IdList, @vRect);
    FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);
  end;


  procedure TFarListDlg.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  function TFarListDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        begin
          ResizeDialog;
          SetCurrent(FGrid.CurRow);
        end;

      DN_CTLCOLORDIALOG:
        Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

      DN_CTLCOLORDLGITEM:
        if Param1 = IdFrame then
          Result := CtrlPalette([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX])
        else
          Result := Param2;
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;



end.


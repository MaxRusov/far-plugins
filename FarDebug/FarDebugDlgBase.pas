{$I Defines.inc}

unit FarDebugDlgBase;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Addrs list window                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    SysTypes,
    SysUtil,
    MSStr,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl,
    FarDlg,
    FarGrid,

    FarDebugCtrl;


  const
    IdFrame  = 0;
    IdGrid   = 1;

  const
    cListDlgDefWidth  = 50;
    cListDlgDefHeight = 5;

    cListDlgMinWidth  = 30;
    cListDlgMinHeight = 5;


  type
    TFarDebugBaseDlg = class(TFarDialog)
    protected
      procedure ErrorHandler(E :Exception); override;
    end;


    TFarDebugListBaseDlg = class(TFarDialog)
    protected
      FGrid     :TFarGrid;
      FMaxWidth :Integer;

      procedure ResizeDialog;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MSDebug;


 {-----------------------------------------------------------------------------}
 { TFarDebugBaseDlg                                                            }
 {-----------------------------------------------------------------------------}

  procedure TFarDebugBaseDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 { TFarDebugListBaseDlg                                                        }
 {-----------------------------------------------------------------------------}

(*
  procedure TFarDebugBaseDlg.Prepare; {override;}
  begin
    FHelpTopic := 'AddrsList';
    FWidth := cDlgDefWidth;
    FHeight := cDlgDefHeight;
    FItemCount := 2;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, 'Find Address' {GetMsg(strCallstack)} ),
        NewItemApi(DI_USERCONTROL, 3, 2, FWidth - 6, FHeight - 6, 0)
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
//  FGrid.NormColor := GetOptColor(0, COL_DIALOGEDIT);
//  FGrid.SelColor := GetOptColor(optCurColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnGetCellText := GridGetDlgText;
//  FGrid.OnGetCellColor := GridGetCellColor;
  end;
*)


  procedure TFarDebugListBaseDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect, vRect1 :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

    vWidth := IntMax(FMaxWidth + 6, cListDlgDefWidth);
    if vWidth > vScreenInfo.dwSize.X - 4 then
      vWidth := IntMax(vScreenInfo.dwSize.X - 4, cListDlgMinWidth);

    vHeight := IntMax(FGrid.RowCount + 4, cListDlgDefHeight);
    if vHeight > vScreenInfo.dwSize.Y - 2 then
      vHeight := IntMax(vScreenInfo.dwSize.Y - 2, cListDlgMinHeight);

    vRect := SBounds(2, 1, vWidth - 5, vHeight - 3);
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    SendMsg(DM_SHOWITEM, IdFrame, 1);

    SRectGrow(vRect, -1, -1);

    vRect1 := vRect;
    if vRect1.Bottom - vRect1.Top + 2 <= FGrid.RowCount then
      Inc(vRect1.Right);
    SendMsg(DM_SETITEMPOSITION, IdGrid, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;


(*
  procedure TListBase.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

    vWidth := FMaxWidth + 6;
    if vWidth > vScreenInfo.dwSize.X - 4 then
      vWidth := vScreenInfo.dwSize.X - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 4;
    if vHeight > vScreenInfo.dwSize.Y - 2 then
      vHeight := vScreenInfo.dwSize.Y - 2;
    vHeight := IntMax(vHeight, cDlgMinHeight);

    SetDlgPos(-1, -1, vWidth, vHeight);

    vRect.Left := 2;
    vRect.Top := 1;
    vRect.Right := vWidth - 3;
    vRect.Bottom := vHeight - 2;
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    SRectGrow(vRect, -1, -1);
    if vRect.Bottom - vRect.Top + 2 <= FGrid.RowCount then
      Inc(vRect.Right);
    SendMsg(DM_SETITEMPOSITION, IdGrid, @vRect);
    FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);
  end;
*)


end.


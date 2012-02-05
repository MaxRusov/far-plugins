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
    MixTypes,
    MixUtils,
    MixStrings,

    Far_API,
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
      FDeltaY   :Integer;
      FMaxWidth :Integer;

      function CalcDlgSize :TSize; virtual;
      procedure ResizeDialog; virtual;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


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

  function TFarDebugListBaseDlg.CalcDlgSize :TSize; {virtual;}
  var
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    Result.CX := IntMax(FMaxWidth + 6, cListDlgDefWidth);
    if Result.CX > vSize.CX - 4 then
      Result.CX := IntMax(vSize.CX - 4, cListDlgMinWidth);

    Result.CY := IntMax(FGrid.RowCount + 4 + FDeltaY, cListDlgDefHeight);
    if Result.CY > vSize.CY - 2 then
      Result.CY := IntMax(vSize.CY - 2, cListDlgMinHeight);
  end;


  procedure TFarDebugListBaseDlg.ResizeDialog; {virtual;}
  var
    vRect, vRect1 :TSmallRect;
    vSize :TSize;
  begin
    vSize := CalcDlgSize;

    vRect := SBounds(2, 1, vSize.CX - 5, vSize.CY - 3);
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
    SendMsg(DM_SHOWITEM, IdFrame, 1);

    SRectGrow(vRect, -1, -1);

    vRect1 := vRect;
    if vRect1.Bottom - vRect1.Top + 2 <= FGrid.RowCount then
      Inc(vRect1.Right);
    Dec(vRect1.Bottom, FDeltaY);
    SendMsg(DM_SETITEMPOSITION, IdGrid, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    SetDlgPos(-1, -1, vSize.CX, vSize.CY);
  end;


end.


{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{$I Defines.inc}

unit UCharListBase;

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
    FarGrid,
    FarListDlg,

    UCharMapCtrl;


  type
    TListBase = class(TFilteredListDlg)
    public
      constructor Create; override;

    protected
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); override;

    protected
      FFoundColor :TFarColor;
    end;

  var
    TopDlg :TFarDialog;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TListBase                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TListBase.Create; {override;}
  begin
    inherited Create;
    FFilter := TListFilter.CreateSize(SizeOf(TFilterRec));
    FFoundColor := GetOptColor(optFoundColor, COL_MENUHIGHLIGHT);
  end;

  
  procedure TListBase.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor); {virtual;}

    procedure LocDrawPart(var AChr :PTChar; var ARest :Integer; ALen :Integer; AColor :TFarColor);
    begin
      if ARest > 0 then begin
        if ALen > ARest then
          ALen := ARest;
        SetFarChr(FGrid.RowBuf, AChr, ALen);
        FARAPI.Text(X, Y, AColor, FGrid.RowBuf);
        Dec(ARest, ALen);
        Inc(AChr, ALen);
        Inc(X, ALen);
      end;
    end;

  var
    vRec :PFilterRec;
    vChr :PTChar;
    vStr :TString;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      vStr := GridGetDlgText(ASender, ACol, ARow);
      if FFilterMask = '' then begin
        SetFarStr(FGrid.RowBuf, vStr, AWidth);
        FARAPI.Text(X, Y, AColor, FGrid.RowBuf);
      end else
      begin
        vChr := PTChar(vStr);
        if AWidth > Length(vStr) then
          AWidth := length(vStr);
        LocDrawPart(vChr, AWidth, vRec.FPos, AColor);
        LocDrawPart(vChr, AWidth, vRec.FLen, ChangeFG(AColor, FFoundColor));
        LocDrawPart(vChr, AWidth, AWidth, AColor);
      end;
    end;
  end;


  function TListBase.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      KEY_ENTER:
        SelectItem(1);
      KEY_CTRLENTER:
        SelectItem(2);
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


end.


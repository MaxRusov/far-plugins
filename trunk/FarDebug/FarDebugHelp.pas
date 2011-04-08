{$I Defines.inc}

unit FarDebugHelp;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Help window                                                                *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,

    PluginW,
    FarKeysW,
    FarColor,
    FarCtrl,
    FarDlg,
    FarGrid,
    FarMatch,

    FarDebugCtrl,
    FarDebugIO,
    FarDebugGDB,
    FarDebugDlgBase,
    FarDebugConsole;


  const
    chrMore = #$25BA;

  type
    THelpDlg = class(TFarDebugListBaseDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CalcDlgSize :TSize; override;
      procedure ResizeDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FData      :THistoryStrs;
      FHelpPath  :TString;
      FResStr    :TString;

      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
      procedure GridPosChange(ASender :TFarGrid);
      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);

      procedure ReinitGrid;
      procedure UpdateHeader;
      function HelpOn(const AWord, APath :TString) :boolean;
      procedure GoBack;

      function GetCurWord :TString;
    end;


  procedure HelpDlg;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  const
//  IdFrame  = 0;
//  IdGrid   = 1;
    IdInput  = 2;


 {-----------------------------------------------------------------------------}
 { THelpDlg                                                              }
 {-----------------------------------------------------------------------------}

  constructor THelpDlg.Create; {override;}
  begin
    inherited Create;
    FData := THistoryStrs.Create;
  end;


  destructor THelpDlg.Destroy; {override;}
  begin
    FreeObj(FData);
    FreeObj(FGrid);
    inherited Destroy;
  end;


  procedure THelpDlg.Prepare; {override;}
  begin
    FGUID := cHelpDlgID;
    FHelpTopic := 'Help';
    FWidth := cListDlgDefWidth;
    FHeight := cListDlgDefHeight;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, FWidth - 4, FHeight - 2, 0, GetMsg(strHelp)),
        NewItemApi(DI_USERCONTROL, 3, 2, FWidth - 6, FHeight - 5, 0),
        NewItemApi(DI_Edit,        3, FHeight - 3, FWIdth - 7, -1, DIF_HISTORY, '', 'FarDebug.Help' )
      ],
      @FItemCount
    );
    FDeltaY := 1;

    FGrid := TFarGrid.CreateEx(Self, IdGrid);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid.Column[0].Options := [coOwnerDraw];

    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnCellClick := GridCellClick;
  end;


  procedure THelpDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    SendMsg(DM_SETFOCUS, IdInput, 0);
    HelpOn('', '');
  end;


  function THelpDlg.CalcDlgSize :TSize; {virtual;}
  begin
    Result := FarGetWindowSize;
    Dec(Result.CX, 4); Dec(Result.CY, 4);
  end;


  procedure THelpDlg.ResizeDialog; {override;}
  var
    vRect :TSmallRect;
  begin
    inherited ResizeDialog;

    SendMsg(DM_GETITEMPOSITION, IdFrame, @vRect);
    vRect.Top := vRect.Bottom - 1; vRect.Bottom := vRect.Top;
    Inc(vRect.Left); Dec(vRect.Right,2);
    SendMsg(DM_SETITEMPOSITION, IdInput, @vRect);
  end;


  procedure THelpDlg.UpdateHeader;
  var
    vStr :TString;
  begin
    vStr := GetMsgStr(strHelp);
    if FHelpPath <> '' then
      vStr := vStr + ': ' + FHelpPath;
    SetText(IdFrame, vStr);
  end;


  procedure THelpDlg.ReinitGrid;
  var
    I  :Integer;
  begin
//  Trace('ReinitGrid...');
    FMaxWidth := cListDlgDefWidth;
    for I := 0 to FData.Count - 1 do
      FMaxWidth := IntMax(FMaxWidth, Length(FData.PStrings[I]^));

    FGrid.RowCount := FData.Count;

//  SendMsg(DM_ENABLEREDRAW, 0, 0);
//  try
      ResizeDialog;
      FGrid.GotoLocation(0, 0, lmScroll);
//  finally
//    SendMsg(DM_ENABLEREDRAW, 1, 0);
//  end;
  end;


  procedure THelpDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  begin
    if ARow = 0 then
      AColor := FGrid.NormColor;
  end;


  function THelpDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < FData.Count then
      Result := FData[ARow];
  end;


  procedure THelpDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  var
    vStr :TString;
    vPos :Integer;
  begin
    if ARow < FData.Count then begin
      vStr := FData[ARow];
      vPos := Pos('--', vStr);
      if (vPos <> 0) and (ARow <> FGrid.CurRow) then
        FGrid.DrawChrEx(X, Y, PTChar(vStr), length(vStr), 0, vPos - 1, AColor, (AColor and not $0F) or (optTermUserColor and $0F))
      else
        FGrid.DrawChr(X, Y, PTChar(vStr), length(vStr), AColor);
    end;
  end;


  procedure THelpDlg.GridPosChange(ASender :TFarGrid);
  begin
    SetText(IdInput, GetCurWord);
  end;


  procedure THelpDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  var
    vWord, vPath :TString;
  begin
    if ADouble and (AButton = 1) then begin
      vWord := GetCurWord;
      if vWord <> '' then begin
        vPath := StrIf(FHelpPath <> '', FHelpPath + ' ' + chrMore + ' ', '') + vWord;
        HelpOn(vWord, vPath);
      end else
        Beep;
    end
//  else if AButton = 2 then
//    GoBack;
  end;


  procedure THelpDlg.GoBack;
  var
    vWord, vPath :TString;
    vPos :Integer;
  begin
    if FHelpPath <> '' then begin
      vWord := ''; vPath := '';
      vPos := ChrLastPos(chrMore, FHelpPath);
      if vPos <> 0 then begin
        vPath := copy(FHelpPath, 1, vPos - 2);
        vPos := ChrLastPos(chrMore, vPath);
        if vPos <> 0 then
          vWord := copy(vPath, vPos + 2, MaxInt)
        else
          vWord := vPath;
      end;
      if HelpOn(vWord, vPath) then
        SetText(IdInput, '');
    end else
      Beep;
  end;


  function THelpDlg.HelpOn(const AWord, APath :TString) :boolean;
  var
    vStr, vRes :TString;
  begin
    Result := False;
    try
      vStr := 'help ' + AWord;
      RedirCall(vStr, @vRes);

      FData.Clear;
      FData.AddText(vRes, 0);

      FHelpPath := APath;
      UpdateHeader;
      ReinitGrid;

      Result := True;

    except
      on E :Exception do
        HandleError(E);
    end;
  end;


  function THelpDlg.GetCurWord :TString;
  var
    vStr :TString;
    vPos :Integer;
  begin
    Result := '';
    if (FGrid.CurRow >= 0) and (FGrid.CurRow < FData.Count) then begin
      vStr := FData[FGrid.CurRow];
      vPos := Pos('--', vStr);
      if vPos <> 0 then
        Result := Trim(copy(vStr, 1, vPos - 1));
    end;
  end;


 {-----------------------------------------------------------------------------}

  function THelpDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocInput;
    var
      vWord, vPath :TString;
    begin
      vWord := GetText(IdInput);
      if vWord <> '' then begin
        if (vWord = '.') or (vWord = '\') then
          vWord := '';

        if (vWord <> '') and StrEqual(vWord, GetCurWord) then
          vPath := StrIf(FHelpPath <> '', FHelpPath + ' ' + chrMore + ' ', '') + vWord
        else
          vPath := vWord;

        if HelpOn(vWord, vPath) then begin
          AddHistory(IdInput, vWord);
          SetText(IdInput, '');
        end;
      end;
    end;

  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE:
        ResizeDialog;

      DN_MOUSECLICK:
        if PMouseEventRecord(Param2).dwButtonState and RIGHTMOST_BUTTON_PRESSED <> 0 then
          GoBack
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            LocInput;
          KEY_CTRLENTER:
            begin
              FResStr := GetCurWord;
              if FResStr <> '' then
                SendMsg(DM_CLOSE, -1, 0)
              else
                Beep;
            end;

          KEY_CTRLPGUP:
            GoBack;

          KEY_BS:
            if (SendMsg(DM_GETFOCUS, 0, 0) <> IdInput) or (GetText(IdInput) = '') then
              GoBack
            else
              Result := inherited DialogHandler(Msg, Param1, Param2);

          KEY_UP, KEY_NUMPAD8,
          KEY_DOWN, KEY_NUMPAD2,
          KEY_PGUP, KEY_NUMPAD9,
          KEY_PGDN, KEY_NUMPAD3:
            FGrid.KeyDown(Param2);

        else
//        TraceF('Key: %d', [Param2]);
          Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure InsertText(const AStr :TString);
  begin
    FarPostMacro( 'print(@"' + AStr + '")' );
  end;


  procedure HelpDlg;
  var
    vDlg :THelpDlg;
  begin
    InitGDBDebugger;
    vDlg := THelpDlg.Create;
    try
      vDlg.Run;

      if vDlg.FResStr <> '' then
        InsertText(vDlg.FResStr);

    finally
      FreeObj(vDlg);
    end;
  end;


end.


{$I Defines.inc}

unit GitShellInfo;

interface

  uses
    Windows,
    ShellApi,
    MixTypes,
    MixUtils,
    MixFormat,
    MixClasses,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarDlg,

    GitShellCtrl,
    GitShellClasses;


  function InfoDlg(ARepo :TGitRepository; const ATitle :TString; const AInfo :array of TString) :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;


 {-----------------------------------------------------------------------------}

  type
    TInfoDlg = class(TFarDialog)
    public
      constructor Create(const ATitle :TString; const AInfo :array of TString);
      destructor Destroy; override;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
//    function CloseDialog(ItemID :Integer) :Boolean; override;
//    function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FTitle   :TString;
      FPrompts :array of TString;
      FDatas   :array of TString;
      FTemp    :TStrList;

      procedure SetInfo(const AInfo :array of TString);
    end;


  constructor TInfoDlg.Create(const ATitle :TString; const AInfo :array of TString);
  begin
    FTitle := ATitle;
    SetInfo(AInfo);
    FTemp := TStrList.Create;
    inherited Create;
  end;


  destructor TInfoDlg.Destroy; {override;}
  begin
    FreeObj(FTemp);
    inherited Destroy;
  end;


  procedure TInfoDlg.SetInfo(const AInfo :array of TString);
  var
    i, vCount :Integer;
  begin
    vCount := Length(AInfo) div 2;

    SetLength(FPrompts, vCount);
    SetLength(FDatas, vCount);

    for I := 0 to vCount - 1 do begin
      FPrompts[i] := AInfo[i * 2];
      FDatas[i] := AInfo[i * 2 + 1];
    end;
  end;


  procedure TInfoDlg.Prepare; {override;}
  var
    I, J, N, Y, vIdx, vEdtCount, vCtrlCount, vMaxOver :Integer;
    vDX1, vDX2, vMaxWidth :Integer;
    vSize :TSize;
    vItems :array of TFarDialogItem;
//  vPtr :PTChar;
  begin
//  FGUID := cPlugInfoID;
//  FHelpTopic := 'PluginInfo';

    vSize := FarGetWindowSize;
    vMaxWidth := vSize.CX - 4;

    { Упрощенно считаем, что есть только один многострочный редактор... }
    vMaxOver := vSize.CY - 4 - 6 - Length(FPrompts);

    vDX1 := 0; vDX2 := 0;
    vEdtCount := 0;
    vCtrlCount := 3; { Frame + Div + Button }
    for I := 0 to High(FPrompts) do begin
      vDX1 := IntMax(vDX1, Length(FPrompts[I]));
      if FPrompts[I] <> '' then
        Inc(vCtrlCount);
      N := RangeLimit(WordCount(FDatas[I], [#13, #10]), 1, vMaxOver);
      if N = 1 then
        vDX2 := IntMax(vDX2, Length(FDatas[I]))
      else begin
        for J := 1 to N do
          vDX2 := IntMax(vDX2, Length(ExtractWord(J, FDatas[I], [#13, #10])));
      end;
      Inc(vCtrlCount, N);
      Inc(vEdtCount, N);
    end;
    Inc(vDX2);

    FHeight := vEdtCount + 6;
    FWidth := vDX1 + vDX2 + 11;
    if FWidth > vMaxWidth then begin
      FWidth := vMaxWidth;
      vDX2 := FWidth - vDX1 - 11;
    end;

    SetLength(vItems, vCtrlCount);

    vItems[0] := NewItemApi(DI_DoubleBox, 3,  1, FWidth-6, FHeight - 2, 0, PTChar(FTitle));

    vIdx := 1; Y := 2;
    for i := 0 to High(FPrompts) do begin
      if FPrompts[i] <> '' then begin
        vItems[vIdx] := NewItemApi(DI_Text, 5, Y, vDX1, -1,  0, PTChar(FPrompts[i] ) );
        Inc(vIdx);
        N := RangeLimit(WordCount(FDatas[I], [#13, #10]), 1, vMaxOver);
        if N = 1 then begin
          vItems[vIdx] := NewItemApi(DI_Edit, 6 + vDX1, Y, vDX2, -1, DIF_READONLY, PTChar(FDatas[i] ) );
          Inc(vIdx);
        end else
        begin
(*
          for J := 1 to N do begin
            vPtr := nil;
            if J = 1 then
              vPtr := PTChar(FDatas[I]);
            vItems[vIdx] := NewItemApi(DI_Edit, 6 + vDX1, Y + J - 1, vDX2, -1, DIF_READONLY or DIF_EDITOR, vPtr);
            Inc(vIdx);
          end;
*)
          for J := 1 to N do begin
            FTemp.Add( ExtractWord(J, FDatas[I], [#13, #10]) );
            vItems[vIdx] := NewItemApi(DI_Edit, 6 + vDX1, Y + J - 1, vDX2, -1, DIF_READONLY {or DIF_EDITOR}, PTChar(FTemp.Last) );
            Inc(vIdx);
          end;
        end;
        Inc(Y, N);
      end else
      begin
        vItems[vIdx] := NewItemApi(DI_Text, 0, Y, -1, -1,  DIF_SEPARATOR or DIF_CENTERGROUP, PTChar(FDatas[i] ) );
        Inc(vIdx);
        Inc(Y);
      end;
    end;

    Assert(vIdx = vCtrlCount - 2);

    vItems[vIdx+0] := NewItemApi(DI_Text, 0, FHeight - 4, -1, -1, DIF_SEPARATOR, '');
    vItems[vIdx+1] := NewItemApi(DI_DefButton, 0, FHeight - 3, -1, -1, DIF_CENTERGROUP, GetMsg(strCloseBut));

    FDialog := CreateDialog(vItems, @FItemCount);
  end;




  procedure TInfoDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SetFocus, FItemCount - 1, 0);
//      for I := Low(TPlugProps) to High(TPlugProps) do
//        SetText(IdFirstEdt + byte(I), FDatas[I]);
  end;


//  function TInfoDlg.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
//  begin
//    Result := True;
//  end;


//  function TInfoDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
//  begin
//    Result := 1;
//    case Msg of
//      DN_BTNCLICK:
//        if Param1 = FItemCount-2 {IdButPlugring} then begin
//          FPlugin.GotoPluring
//        end else
//        if Param1 = FItemCount-1 {IdButProp} then begin
//          ShellOpenEx(hFarWindow, FPlugin.FileName)
//        end else
//          Result := inherited DialogHandler(Msg, Param1, Param2);
//    else
//      Result := inherited DialogHandler(Msg, Param1, Param2);
//    end;
//  end;



 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function InfoDlg(ARepo :TGitRepository; const ATitle :TString; const AInfo :array of TString) :Boolean;
  var
    vDlg :TInfoDlg;
  begin
    vDlg := TInfoDlg.Create(ATitle, AInfo);
    try
      Result := False;
      if vDlg.Run = -1 then
        Exit;
    finally
      FreeObj(vDlg);
    end;
  end;


initialization
  ShowInfoDlg := InfoDlg;
end.


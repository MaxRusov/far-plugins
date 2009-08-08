{$I Defines.inc}

unit FarDebugSourcesDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* GDB Shell for FAR                                                          *}
{* Sources List Dialog                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,

   {$ifdef bUnicodeFar}
    PluginW,
    FarKeysW,
   {$else}
    Plugin,
    FarKeys,
   {$endif bUnicodeFar}

    FarColor,
    FarCtrl,
    FarMatch,
    FarDlg,
    FarGrid,

    FarDebugCtrl,
    FarDebugGDB,
    FarDebugDlgBase,
    FarDebugListBase;


  function SourcesDlg :Boolean;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}
 { TSrcFilter                                                                  }
 {-----------------------------------------------------------------------------}

  type
    TSrcFilter = class(TMyFilter)
    public
      function ItemCompare(PItem, PAnother :Pointer; Context :Integer) :Integer; override;
    end;


  function TSrcFilter.ItemCompare(PItem, PAnother :Pointer; Context :Integer) :Integer; {override;}
  var
    vSrc1, vSrc2 :TSourceFile;
  begin
    Result := 0;

    vSrc1 := SrcFiles[PInteger(PItem)^];
    vSrc2 := SrcFiles[PInteger(PAnother)^];

    case Abs(Context) of
      1: Result := UpCompareStr(vSrc1.FileName, vSrc2.FileName);
      2:
      begin
        Result := UpCompareStr(vSrc1.GetVisiblePath, vSrc2.GetVisiblePath);
        if Result = 0 then
          Result := UpCompareStr(vSrc1.FileName, vSrc2.FileName);
      end;
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
  end;


 {-----------------------------------------------------------------------------}
 { TSourcesDlg                                                                 }
 {-----------------------------------------------------------------------------}

  type
    TSourcesDlg = class(TFilteredListBase)
    protected
      procedure CreateFilter; override;
      procedure Prepare; override;
      procedure InitDialog; override;

      procedure SelectItem(ACode :Integer); override;
      procedure UpdateHeader; override;
      procedure ReinitGrid; override;
      procedure ReinitAndSaveCurrent; override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;

    private
      FResSrc  :TSourceFile;

      procedure SetOrder(AOrder :Integer);
      procedure GotoFileName(const AName :TString);
      function FontNameToDlgIndex(const AName :TString) :Integer;
      function GetSrcFileName(ADlgIndex :Integer) :TString;
      function GetSource(ADlgIndex :Integer) :TSourceFile;
    end;


  procedure TSourcesDlg.CreateFilter; {override;}
  begin
    FFilter := TSrcFilter.CreateSize(SizeOf(TFilterRec));
  end;


  procedure TSourcesDlg.Prepare; {override;}
  begin
    inherited Prepare;
    FHelpTopic := 'Sources';
  end;


  procedure TSourcesDlg.InitDialog; {override;}
  begin
    inherited InitDialog;
//  GotoFileName(FResName);
  end;


  procedure TSourcesDlg.SelectItem(ACode :Integer); {override;}
  begin
    if FGrid.RowCount > 0 then begin
      FResSrc := GetSource(FGrid.CurRow);
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TSourcesDlg.UpdateHeader; {override;}
  var
    vTitle :TFarStr;
  begin
    vTitle := GetMsgStr(strSources);

    if FFilterMask = '' then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    SetText(IdFrame, vTitle);
  end;


  procedure TSourcesDlg.ReinitGrid; {override;}
  var
    I, vPos, vLen, vMaxLen1, vMaxLen2 :Integer;
    vHasMask :Boolean;
    vMask :TString;
    vSrc :TSourceFile;
  begin
    FFilter.Clear;
    FTotalCount := 0;
    vMaxLen1 := 0; vMaxLen2 := 0;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(FMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    for I := 0 to SrcFiles.Count - 1 do begin
      vSrc := SrcFiles[I];

      Inc(FTotalCount);
      vPos := 0; vLen := 0;
      if vMask <> '' then
        if not CheckMask(vMask, vSrc.FileName, vHasMask, vPos, vLen) then
          Continue;

      FFilter.Add(I, vPos, vLen);
      vMaxLen1 := IntMax(vMaxLen1, Length(vSrc.FileName));
      if optSrcShowPath then
        vMaxLen2 := IntMax(vMaxLen2, Length( vSrc.GetVisiblePath ));
    end;

    if optSrcSortMode <> 0 then
      FFilter.SortList(True, optSrcSortMode);

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen1 + 2, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    if optSrcShowPath then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0 {vMaxLen2 + 2}, taLeftJustify, [coColMargin], 2) );

    if FGrid.Columns.Count = 1 then
      FGrid.Column[0].Width := 0;

    FMaxWidth := vMaxLen1 + 2;
    if optSrcShowPath then
      Inc(FMaxWidth, vMaxLen2 + 3);

    FGrid.ResetSize;
    FGrid.RowCount := FFilter.Count;

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      UpdateHeader;
      ResizeDialog;
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TSourcesDlg.ReinitAndSaveCurrent;
  var
    vName :TString;
  begin
    vName := '';
    if (FGrid.CurRow >= 0) and (FGrid.CurRow < FGrid.RowCount) then
      vName := GetSrcFileName(FGrid.CurRow);
    ReinitGrid;
    GotoFileName(vName);
  end;


  function TSourcesDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vSrc :TSourceFile;
  begin
    if ARow < FFilter.Count then begin
      vSrc := SrcFiles[FFilter[ARow]];
      case FGrid.Column[ACol].Tag of
        1: Result := vSrc.FileName;
        2: Result := vSrc.GetVisiblePath;
      end;
    end else
      Result := '';
  end;


 {-----------------------------------------------------------------------------}

  procedure TSourcesDlg.GotoFileName(const AName :TString);
  var
    vIndex :Integer;
  begin
    vIndex := FontNameToDlgIndex(AName);
    if vIndex < 0 then
      vIndex := 0;
    SetCurrent( vIndex, lmCenter );
  end;


  function TSourcesDlg.FontNameToDlgIndex(const AName :TString) :Integer;
  var
    I :Integer;
  begin
    Result := -1;
    for I := 0 to FFilter.Count - 1 do
      if GetSrcFileName(I) = AName then begin
        Result := I;
        Exit;
      end;
  end;


  function TSourcesDlg.GetSrcFileName(ADlgIndex :Integer) :TString;
  begin
    Result := GetSource(ADlgIndex).FileName;
  end;


  function TSourcesDlg.GetSource(ADlgIndex :Integer) :TSourceFile;
  begin
    Result := SrcFiles[FFilter[ADlgIndex]];
  end;


  procedure TSourcesDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> optSrcSortMode then
      optSrcSortMode := AOrder
    else
      optSrcSortMode := -AOrder;

//  LocReinitAndSaveCurrent;
    ReinitGrid;
    WriteSetup;
  end;


  function TSourcesDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

    procedure LocRefresh;
    begin
      UpdateSourcesList;
      ReinitGrid;
    end;

  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_KEY: begin
        case Param2 of
          KEY_CTRL2:
            ToggleOption(optSrcShowPath);

          KEY_CTRLF1:
            SetOrder(1);
          KEY_CTRLF2:
            SetOrder(2);

          KEY_CTRLR:
            LocRefresh;
        else
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

  function SourcesDlg :Boolean;
  var
    vDlg :TSourcesDlg;
    vFileName :TString;
  begin
    Result := False;

//  InitGDBDebugger;
//  UpdateSourcesList;

    vDlg := TSourcesDlg.Create;
    try
//    vDlg.FResName := AName;

      if vDlg.Run = -1 then
        Exit;

      if vDlg.FResSrc <> nil then begin
        vFileName := vDlg.FResSrc.FileName;
        vFileName := FullNameToSourceFile(vFileName, True);
        if vFileName <> '' then begin
          OpenEditor(vFileName, 0, 0);
          Result := True;
        end;  
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


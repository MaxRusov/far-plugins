{$I Defines.inc}

{$ifdef Far3}
{$else}
 {$Define bPreciseMatch}
{$endif Far3}

unit EdtFindEditor;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Editor Find Shell                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,

    Far_API,
    FarCtrl,

    EdtFindCtrl,
    EdtFinder,
    EdtFindDlg,
    EdtReplaceDlg,
    EdtFindGrep;


  var
    gLastOpt   :TFindOptions;
    gMatchStr  :TString;


  procedure Find(APickWord :Boolean);
  procedure Replace(APickWord :Boolean);
  procedure RepeatLast(AForward :Boolean);
  procedure PickWord;

  function FindStr(const AStr :TString; AOpt :TFindOptions; AEntire, ANext, AForward :Boolean;
    ALoopMode :Integer = -1; AHighlightMode :Integer = -1; AErrorMode :Integer = -1) :Boolean;
  function ReplaceStr(const AFindStr, AReplStr :TString; AOpt :TFindOptions; AEntire, ANext, AForward :Boolean;
    ALoopMode :Integer = -1; AHighlightMode :Integer = -1; AErrorMode :Integer = -1) :Boolean;
  procedure GrepStr(const AStr :TString; AOpt :TFindOptions);
  procedure CountStr(const AStr :TString; AOpt :TFindOptions);
  procedure HighlightStr(const AStr :TString; AOpt :TFindOptions);
  procedure GotoFoundPos(ARow, ACol, ALen :Integer; AForward :Boolean = True; ATopLine :Integer = 0);

 {$ifdef bAdvSelect}
  procedure RefreshEdtMatches;
  procedure UpdateEdtMatches;
  procedure DeleteEdtHelper(AId :Integer);
  procedure EdtClearMark(AClearMatches :Boolean = True; ARedraw :Boolean = True);
 {$endif bAdvSelect}

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

 {$ifdef bAdvSelect}

  type
    TEdtHelper = class(TBasis)
    public
      constructor CreateEx(AId :Integer);
      destructor Destroy; override;

      procedure Reset;
      procedure AddFound(const ASel :TEdtSelection);

      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FID   :Integer;
     {$ifdef bPreciseMatch}
      FAll  :TExList;
     {$else}
      FRow1 :Integer;
      FRow2 :Integer;
     {$endif bPreciseMatch}
    end;


  constructor TEdtHelper.CreateEx(AId :Integer);
  begin
    Create;
    FId := AId;
   {$ifdef bPreciseMatch}
    FAll := TExList.CreateSize(SizeOf(TEdtSelection));
   {$else}
    Reset;
   {$endif bPreciseMatch}
  end;


  destructor TEdtHelper.Destroy; {override;}
  begin
   {$ifdef bPreciseMatch}
    FreeObj(FAll);
   {$endif bPreciseMatch}
    inherited Destroy;
  end;


  procedure TEdtHelper.Reset;
  begin
   {$ifdef bPreciseMatch}
    FAll.Clear;
   {$else}
    FRow2 := -1;
    FRow1 := MaxInt;
   {$endif bPreciseMatch}
  end;


  procedure TEdtHelper.AddFound(const ASel :TEdtSelection);
  begin
   {$ifdef bPreciseMatch}
    FAll.AddData(ASel);
   {$else}
    if ASel.FRow < FRow1 then
      FRow1 := ASel.FRow;
    if ASel.FRow > FRow2 then
      FRow2 := ASel.FRow;
   {$endif bPreciseMatch}
  end;


  function TEdtHelper.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := IntCompare(FID, TIntPtr(Key));
  end;


  var
    gEdtHelpers :TObjList;

  function FindEdtHelper(AId :Integer; ACreate :Boolean) :TEdtHelper;
  var
    vIndex :Integer;
  begin
    Result := nil;
    if gEdtHelpers.FindKey(Pointer(TIntPtr(AID)), 0, [foBinary], vIndex) then
      Result := gEdtHelpers[vIndex]
    else if ACreate then begin
      Result := TEdtHelper.CreateEx(AID);
      gEdtHelpers.Insert(vIndex, Result);
    end;
  end;


  procedure DeleteEdtHelper(AId :Integer);
  var
    vIndex :Integer;
  begin
    if gEdtHelpers.FindKey(Pointer(TIntPtr(AID)), 0, [foBinary], vIndex) then
      gEdtHelpers.FreeAt(vIndex);
  end;



  var
    gEdtID     :Integer        = -1;

    gFound     :TEdtSelection;
    gUpdFound  :Boolean;

//    gMatchStr  :TString;
    gMatchOpt  :TFindOptions;

    gMatches   :TExList;
    gMatchRow1 :Integer;
    gMatchRow2 :Integer;

//  gEdtMess   :TString;


  procedure SetEdtID;
  var
    vEdtInfo :TEditorInfo;
  begin
    FillZero(vEdtInfo, SizeOf(vEdtInfo));
   {$ifdef Far3}
    vEdtInfo.StructSize := SizeOf(vEdtInfo);
   {$endif Far3}
    if FarEditorControl(ECTL_GETINFO, @vEdtInfo) <> 1 then
      Exit;
    gEdtID := vEdtInfo.EditorID;
  end;


  procedure EdtMark(ARow, ACol, ALen :Integer);
  begin
    SetEdtID;
    gFound.FRow := ARow;
    gFound.FCol := ACol;
    gFound.FLen := ALen;
    gUpdFound := True;
  end;


  procedure EdtClearMark(AClearMatches :Boolean = True; ARedraw :Boolean = True);
  var
    vWasChange :Boolean;
  begin
    vWasChange := False;
    if AClearMatches then
      gEdtID := -1;

    if gFound.FLen > 0 then begin
      EdtMark(0, 0, 0);
      vWasChange := True;
    end;

    if AClearMatches and (gMatches <> nil) then begin
      gMatchStr := '';
      FreeObj(gMatches);
      vWasChange := True;
    end;

    if ARedraw and vWasChange then 
      FarEditorControl(ECTL_REDRAW, nil);

//  if gEdtMess <> '' then begin
//    gEdtMess := '';
//    vWasChange := True;
//    FarEditorControl(ECTL_REDRAW, nil);
//    FarAdvControl(ACTL_REDRAWALL, nil);
//  end;
  end;


  procedure ShowAllMatch(const AStr :TString; AOpt :TFindOptions);
  begin
    SetEdtID;
    gMatchStr  := AStr;
    gMatchOpt  := AOpt;
    gMatchRow1 := 0;
    gMatchRow2 := 0;
  end;


  function UpdateMatches(const AInfo :TEditorInfo) :Boolean;
  var
    i, vRow1, vRow2, vRow, vCol, vFindLen, vCount :Integer;
  begin
    Result := False;

    vRow1 := AInfo.TopScreenLine;
    vRow2 := vRow1 + AInfo.WindowSizeY;

    if (vRow1 <> gMatchRow1) or (vRow2 <> gMatchRow2) then begin
//    TraceF('UpdateMatches', [0]);

      if gMatches = nil then
        gMatches := TExList.CreateSize(SizeOf(TEdtSelection));

      if (vRow1 >= gMatchRow2) or (vRow2 < gMatchRow1) then begin

        gMatches.Clear;
        gMatchRow1 := 0;
        gMatchRow2 := 0;

        vCol := 0;
        EditorFind(gMatchStr, gMatchOpt, vRow1, vCol, vFindLen, {Forward:}True, [], vRow1, vRow2, gMatches);

        gMatchRow1 := vRow1;
        gMatchRow2 := vRow2;

      end else
      begin
        if gMatchRow1 < vRow1 then begin
          { Обрезание сверху }
          I := 0;
          while (I < gMatches.Count) and (PEdtSelection(gMatches.PItems[I]).FRow < vRow1) do
            Inc(I);
          if I > 0 then
            gMatches.DeleteRange(0, I);
          gMatchRow1 := vRow1;
        end;

        if gMatchRow2 > vRow2 then begin
          { Обрезание снизу }
          I := 0;
          while (I < gMatches.Count) and (PEdtSelection(gMatches.PItems[gMatches.Count - I - 1]).FRow >= vRow2) do
            Inc(I);
          if I > 0 then
            gMatches.DeleteRange(gMatches.Count - I, I);
          gMatchRow2 := vRow2;
        end;

        if vRow2 > gMatchRow2 then begin
          { Дополнение снизу }
          vRow := gMatchRow2;
          vCol := 0;
          EditorFind(gMatchStr, gMatchOpt, vRow, vCol, vFindLen, {Forward:}True, [], gMatchRow2, vRow2, gMatches);
          gMatchRow2 := vRow2;
        end;

        if vRow1 < gMatchRow1 then begin
          { Дополнение сверху }
          vCount := gMatches.Count;

          vRow := vRow1;
          vCol := 0;
          EditorFind(gMatchStr, gMatchOpt, vRow, vCol, vFindLen, {Forward:}True, [], vRow1, gMatchRow1, gMatches);

          if gMatches.Count > vCount then
            gMatches.Move(vCount, 0, gMatches.Count - vCount);

          gMatchRow1 := vRow1;
        end;
      end;

//    TraceF('Known matches: %d (%d-%d)', [gMatches.Count, gMatchRow1, gMatchRow2]);
      Result := True;
    end;
  end;

 {$endif bAdvSelect}


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure GoNext(var ACol :Integer; AForward :Boolean);
  begin
    if optCursorAtEnd then begin
      if AForward then
        {}
      else
        Dec(ACol);
    end else
    begin
      if AForward then
        Inc(ACol)
      else
        Dec(ACol);
    end;
  end;


  procedure GotoPosition(ARow, ACol1, ACol2, ACol :Integer; ACenter :Boolean; ATopLine :Integer = 0);
  var
    vNewTop, vHeight, vNewLeft, vWidth :Integer;
    vPos :TEditorSetPosition;
    vInfo :TEditorInfo;
  begin
    vNewTop := -1; vNewLeft := -1;
   {$ifdef Far3}
    vInfo.StructSize := SizeOf(vInfo);
   {$endif Far3}
    if (ACol1 <> -1) and (FarEditorControl(ECTL_GETINFO, @vInfo) = 1) then begin
      if ATopLine = 0 then
        vHeight := vInfo.WindowSizeY
      else
        vHeight := ATopLine - 1{Строка состояния редактора};
      if ACenter or ((ARow < vInfo.TopScreenLine) or (ARow >= vInfo.TopScreenLine + vHeight)) then
        vNewTop := RangeLimit(ARow - (vHeight div 3), 0, vInfo.TotalLines - vInfo.WindowSizeY );

      vWidth := vInfo.WindowSizeX - 1{ScrollBar};
//    if (ACol1 < vInfo.LeftPos) or (ACol2 > vInfo.LeftPos + vWidth) then
        vNewLeft := RangeLimit(0 {vInfo.LeftPos}, (ACol2 + 3) - vWidth, IntMax(ACol1 - 3, 0));
    end;
   {$ifdef Far3}
    vPos.StructSize := SizeOf(vPos);
   {$endif Far3}
    vPos.CurLine := ARow;
    vPos.CurPos := ACol;
    vPos.TopScreenLine := vNewTop;
    vPos.LeftPos := vNewLeft;
    vPos.CurTabPos := -1;
    vPos.Overtype := -1;
    FarEditorControl(ECTL_SETPOSITION, @vPos);
  end;


  procedure SelectFound(ARow, ACol, ALen :Integer);
  var
    vSel :TEditorSelect;
  begin
   {$ifdef Far3}
    vSel.StructSize := SizeOf(vSel);
   {$endif Far3}
    vSel.BlockType := BTYPE_STREAM;
    vSel.BlockStartLine := ARow;
    vSel.BlockStartPos := ACol;
    vSel.BlockWidth := ALen;
    vSel.BlockHeight := 1;
    FarEditorControl(ECTL_SELECT, @vSel);
  end;


  procedure SelectClear;
  var
    vSel :TEditorSelect;
  begin
    FillZero(vSel, SizeOf(vSel));
   {$ifdef Far3}
    vSel.StructSize := SizeOf(vSel);
   {$endif Far3}
    vSel.BlockType := BTYPE_NONE;
    FarEditorControl(ECTL_SELECT, @vSel);
  end;


  procedure GotoFoundPos(ARow, ACol, ALen :Integer; AForward :Boolean = True; ATopLine :Integer = 0);
  begin
    GotoPosition(ARow, ACol, ACol + ALen,
      IntIf(optCursorAtEnd and AForward, ACol + ALen, ACol), optCenterAlways, ATopLine);

    if optSelectFound then
      SelectFound(ARow, ACol, ALen);

   {$ifdef bAdvSelect}
    if not optSelectFound then
      EdtMark(ARow, ACol, ALen);
   {$endif bAdvSelect}
  end;


  function LoopPrompt(const AStr :TString; AForward :Boolean) :Boolean;
  begin
    Result := ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr + #10 +
      GetMsgStr(TMessages(IntIf(AForward, Byte(strContinueFromBegin), Byte(strContinueFromEnd)))),
      FMSG_MB_YESNO, 0) = 0;
  end;


  function FindStr(const AStr :TString; AOpt :TFindOptions; AEntire, ANext, AForward :Boolean;
    ALoopMode :Integer = -1; AHighlightMode :Integer = -1; AErrorMode :Integer = -1) :Boolean;
  var
    vEdtInfo :TEditorInfo;
    vRow, vCol, vFindLen :Integer;
    vStartRow, vRow1, vRow2 :Integer;
    vFound, vLoop, vLoopSearch, vHighLight :Boolean;
    vErrorMode :Integer;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
    Result := False;
    if AStr = '' then
      Exit;

    FillZero(vEdtInfo, SizeOf(vEdtInfo));
   {$ifdef Far3}
    vEdtInfo.StructSize := SizeOf(vEdtInfo);
   {$endif Far3}
    if FarEditorControl(ECTL_GETINFO, @vEdtInfo) <> 1 then
      Exit;

    if AEntire then begin
      if AForward then begin
        vRow := 0;
        vCol := 0;
      end else
      begin
        vRow := vEdtInfo.TotalLines - 1;
        vCol := MaxInt;
      end;
    end else
    begin
      vRow := vEdtInfo.CurLine;
      vCol := vEdtInfo.CurPos;
    end;

    if ANext then
      GoNext(vCol, AForward);

    vLoop := AEntire or (AForward and (vRow = 0) and (vCol = 0));

    if ALoopMode = -1 then
      vLoopSearch := optLoopSearch
    else
      vLoopSearch := ALoopMode = 1;

    if AHighlightMode = -1 then
      vHighLight := optShowAllFound
    else
      vHighLight := AHighlightMode = 1;

    if AErrorMode = -1 then
      vErrorMode := IntIf(optNoModalMess, 2, 1)
    else
      vErrorMode := AErrorMode;

    InitFind(GetMsgStr(strFind), '');

    vRow1 := 0; vRow2 := 0;
    vStartRow := vRow;
    while True do begin

     {$ifdef bTrace}
      Trace('Search...');
      vStart := GetTickCount;
     {$endif bTrace}

      vFound := EditorFind(AStr, AOpt, vRow, vCol, vFindLen, AForward, [efoProgress], vRow1, vRow2);

     {$ifdef bTrace}
      TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
     {$endif bTrace}

      if vFound then begin

        GotoFoundPos(vRow, vCol, vFindLen, AForward);

       {$ifdef bAdvSelect}
        if vHighLight then
          ShowAllMatch(AStr, AOpt);
       {$endif bAdvSelect}

        FarEditorControl(ECTL_REDRAW, nil);
        Result := True;
      end else
      begin
        if optSelectFound then
          SelectClear;
       {$ifdef bAdvSelect}
        EdtClearMark(False);
       {$endif bAdvSelect}

        if vLoopSearch and not vLoop then begin

          if LoopPrompt(AStr, AForward) then begin
            if AForward then begin
              vRow := 0;
              vCol := 0;
              vRow1 := 0;
              vRow2 := vStartRow + 1;
            end else
            begin
              vRow := vEdtInfo.TotalLines - 1;
              vCol := MaxInt;
              vRow1 := vStartRow;
              vRow2 := vEdtInfo.TotalLines;
            end;
            vLoop := True;
            Continue;
          end;

        end else
        if vErrorMode <> 0 then begin
         {$ifdef bAdvSelect}
//        if vErrorMode = 2 then begin
//          gEdtMess := GetMsgStr(strNotFound);
//          FarEditorControl(ECTL_REDRAW, nil);
//        end else
         {$endif bAdvSelect}
            ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr,
              FMSG_WARNING or FMSG_MB_OK);
        end;
      end;

      Break;
    end;
  end;


  procedure CountStr(const AStr :TString; AOpt :TFindOptions);
  var
    vRow, vCol, vLen :Integer;
    vFound :Boolean;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
   {$ifdef bTrace}
    Trace('Count...');
    vStart := GetTickCount;
   {$endif bTrace}

    InitFind(GetMsgStr(strFind), GetMsgStr(strFoundCount));

    vRow := 0; vCol := 0; vLen := 0;
    vFound := EditorFind(AStr, AOpt, vRow, vCol, vLen, True, [efoProgress, efoCalcCount], 0, 0);

   {$ifdef bTrace}
    TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
   {$endif bTrace}

    if vFound then
      ShowMessage(gProgressTitle, Format(GetMsgStr(strCountResult), [AStr, gFoundCount]), FMSG_MB_OK)
    else
      ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr, FMSG_WARNING or FMSG_MB_OK);
  end;


  procedure GrepStr(const AStr :TString; AOpt :TFindOptions);
  var
    vRow, vCol, vLen :Integer;
    vFound :Boolean;
    vMatches :TExList;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
    vMatches := TExList.CreateSize(SizeOf(TEdtSelection));
    try
     {$ifdef bTrace}
      Trace('Grep...');
      vStart := GetTickCount;
     {$endif bTrace}

      InitFind(GetMsgStr(strFind), GetMsgStr(strFoundCount));

      vRow := 0; vCol := 0; vLen := 0;
      vFound := EditorFind(AStr, AOpt, vRow, vCol, vLen, True, [efoProgress, efoCalcCount, efoOnePerRow], 0, 0, vMatches);

     {$ifdef bTrace}
      TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
     {$endif bTrace}

      if vFound then
        GrepDlg(vMatches)
      else
        ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AStr, FMSG_WARNING or FMSG_MB_OK);

    finally
      FreeObj(vMatches);
    end;
  end;


  procedure HighlightStr(const AStr :TString; AOpt :TFindOptions);
  var
    vFinder :TFinder;
  begin
    { Проверяем валидность регулярного выражения... }
    vFinder := TFinder.CreateEx(AStr, AOpt);
    FreeObj(vFinder);

   {$ifdef bAdvSelect}
    ShowAllMatch(AStr, AOpt);
   {$endif bAdvSelect}
    FarEditorControl(ECTL_REDRAW, nil);
  end;


  procedure Find(APickWord :Boolean);
  var
    vMode :TFindMode;
  begin
//  SyncFindStr;
    if not FindDlg(APickWord, vMode) then
      Exit;
   {$ifdef bAdvSelect}
    EdtClearMark;
   {$endif bAdvSelect}
    gLastOpt := gOptions;
    gLastIsReplace := False;
    if vMode = efmCount then
      CountStr(gStrFind, gLastOpt)
    else
    if vMode = efmGrep then
      GrepStr(gStrFind, gLastOpt)
    else
      FindStr(gStrFind, gLastOpt, vMode = efmEntire, False, not gReverse);
  end;


  procedure PickWord;
  var
    vStr :TString;
    vCol :Integer;
  begin
    vCol := -1;
    vStr := GetWordUnderCursor(@vCol, False);
    if vStr <> '' then begin
      gStrFind := vStr;
      gLastOpt := gLastOpt + [foWholeWords] - [foRegexp];
      gLastIsReplace := False;
      FarAddToHistory(cFindHistory, gStrFind);
      GotoPosition(-1, -1, -1, vCol, False);
      FindStr(gStrFind, gLastOpt, False, False, True);
    end else
      Beep;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function ReplaceStr(const AFindStr, AReplStr :TString; AOpt :TFindOptions; AEntire, ANext, AForward :Boolean;
    ALoopMode :Integer = -1; AHighlightMode :Integer = -1; AErrorMode :Integer = -1) :Boolean;
  var
    vEdtInfo :TEditorInfo;
    vHighLight :Boolean;

    procedure LocShow(ARow, ACol, ALen :Integer);
    begin
      if optSelectFound then
        if ALen > 0 then
          SelectFound(ARow, ACol, ALen)
        else
          SelectClear;
     {$ifdef bAdvSelect}
      if not optSelectFound then
        if ALen > 0 then
          EdtMark(ARow, ACol, ALen)
        else
          EdtClearMark(False);
      if vHighLight then
        ShowAllMatch(AFindStr, AOpt);
     {$endif bAdvSelect}
      FarEditorControl(ECTL_REDRAW, nil);
    end;

  var
    vFinder :TFinder;
    vStr1, vStr2 :TString;
    vRow, vCol, vFindLen, vRes :Integer;
    vStartRow, vRow1, vRow2 :Integer;
    vFound, vPrompt, vReplace, vLoop, vLoopSearch :Boolean;
    vStrInfo :TEditorGetString;
    vStrSet :TEditorSetString;
    vUndoRec :TEditorUndoRedo;
    vErrorMode :Integer;
   {$ifdef bTrace}
    vStart :DWORD;
   {$endif bTrace}
  begin
    Result := False;
    if AFindStr = '' then
      Exit;

    FillChar(vEdtInfo, SizeOf(vEdtInfo), 0);
   {$ifdef Far3}
    vEdtInfo.StructSize := SizeOf(vEdtInfo);
   {$endif Far3}
    if FarEditorControl(ECTL_GETINFO, @vEdtInfo) <> 1 then
      Exit;

    if AEntire then begin
      if AForward then begin
        vRow := 0;
        vCol := 0;
      end else
      begin
        vRow := vEdtInfo.TotalLines - 1;
        vCol := MaxInt;
      end;
    end else
    begin
      vRow := vEdtInfo.CurLine;
      vCol := vEdtInfo.CurPos;
    end;

    if ANext then
      GoNext(vCol, AForward);

    vLoop := AEntire or (AForward and (vRow = 0) and (vCol = 0));

    if ALoopMode = -1 then
      vLoopSearch := optLoopSearch
    else
      vLoopSearch := ALoopMode = 1;

    if AHighlightMode = -1 then
      vHighLight := optShowAllFound
    else
      vHighLight := AHighlightMode = 1;

    if AErrorMode = -1 then
      vErrorMode := IntIf(optNoModalMess, 2, 1)
    else
      vErrorMode := AErrorMode;

    if optGroupUndo then begin
     {$ifdef Far3}
      vUndoRec.StructSize := SizeOf(vUndoRec);
     {$endif Far3}
      vUndoRec.Command := EUR_BEGIN;
      FarEditorControl(ECTL_UNDOREDO, @vUndoRec);
    end;

   {$ifdef Far3}
    FarEditorSubscribeChangeEvent(-1{AID}, False);
   {$endif Far3}

    vPrompt := foPromptOnReplace in AOpt;

    vFinder := TFinder.CreateEx(AFindStr, AOpt);
    try
      InitFind(GetMsgStr(strReplace), GetMsgStr(strFoundReplaced));

      if foRegexp in AOpt then
        vFinder.PrepareReplace(AReplStr);

      vRow1 := 0; vRow2 := 0;
      vStartRow := vRow;

     {$ifdef bTrace}
      vStart := 0;
     {$endif bTrace}

      while True do begin

        if not vPrompt and (gProgressLast = 0) then
          { Инициализируем сквозной прогресс-индикатор }
          gProgressLast := GetTickCount;

       {$ifdef bTrace}
        if vStart = 0 then begin
          Trace('Replace...');
          vStart := GetTickCount;
        end;
       {$endif bTrace}

        vFound := False;
        try
          vFound := vFinder.EdtFind(vRow, vCol, vFindLen, AForward, [efoProgress], vRow1, vRow2);
        finally
          if not vFound and (gScrSave <> 0) then begin
            FARAPI.RestoreScreen(gScrSave);
            gScrSave := 0;
          end;
        end;

       {$ifdef bTrace}
        if not vFound then
          TraceF('  done: %d ms', [TickCountDiff(GetTickCount, vStart)]);
       {$endif bTrace}

        if vFound then begin

          Inc(gFoundCount);

         {$ifdef Far3}
          vStrInfo.StructSize := SizeOf(vStrInfo);
         {$endif Far3}
          vStrInfo.StringNumber := vRow;
          if FarEditorControl(ECTL_GETSTRING, @vStrInfo) <> 1 then
            Wrong;
          if vStrInfo.StringLength < vCol + vFindLen then
            Wrong;

          { Формирование строки замены (c учетом регулярных выражений замены)... }
          vFinder.Replace(vStrInfo.StringText, vStrInfo.StringLength, AReplStr);

          vReplace := True;
          if vPrompt then begin
            { Спрашиваем... }
            GotoPosition(vRow, vCol, vCol + vFindLen, vCol, {ACenter:}True {optCenterAlways}, vEdtInfo.WindowSizeY * 2 div 3);
            LocShow(vRow, vCol, IntMax(vFindLen, 1));

            SetString(vStr1, vStrInfo.StringText + vCol, vFindLen); { Искомая строка }
            SetString(vStr2, vFinder.RepBuf + vFinder.RepBeg, vFinder.RepLen); {Заменяющая строка}

            vRes := ShowMessage(GetMsgStr(strConfirm), Format(GetMsgStr(strReplaceWith1), [vStr1, vStr2]) + #10 +
              GetMsgStr(strReplaceBut) + #10 + GetMsgStr(strAllBut) + #10 + GetMsgStr(strSkipBut) + #10 + GetMsgStr(strCancelBut1),
              0 {FMSG_WARNING} {or FMSG_MB_OK}, 4);

            case vRes of
              0: {};
              1: vPrompt := False;
              2: vReplace := False;
            else
              Exit;
            end;

           {$ifdef bTrace}
            vStart := 0;
           {$endif bTrace}
          end else
            { Иначе просто позиционируемся, чтобы лучше работало Undo... }
            GotoPosition(vRow, -1, -1, vCol, False);

          if vReplace then begin
            { Заменяем... }
           {$ifdef Far3}
            vStrSet.StructSize := SizeOf(vStrSet);
           {$endif Far3}
            vStrSet.StringNumber := -1 {vRow};
            vStrSet.StringText := vFinder.RepBuf;
            vStrSet.StringLength := vFinder.ResStrLen;
            vStrSet.StringEOL := vStrInfo.StringEOL;

            FarEditorControl(ECTL_SETSTRING, @vStrSet);
            if vPrompt then begin
              if optSelectFound then
                SelectClear;
              FarEditorControl(ECTL_REDRAW, nil);
            end;

            Inc(gReplCount);

            if AForward then begin
              Inc(vCol, vFinder.RepLen);
              if vFindLen = 0 then
                Inc(vCol); { Чтобы избежать зацикливания... }
            end else
              Dec(vCol);
          end else
          begin
            { Пропускаем... }
            if AForward then
              Inc(vCol)
            else
              Dec(vCol);
          end

        end else
        begin
          { Вхождение не найдено. Начинаем сначала, или прекращаем поиск... }
          if vLoopSearch and not vLoop then begin

            if gFoundCount > 0 then begin
              if not vPrompt then
                GotoPosition(vRow, vCol, vCol + vFindLen, vCol, {ACenter:}True);
              LocShow(vRow, vCol, -1);
            end;

            if LoopPrompt(AFindStr, AForward) then begin
              if AForward then begin
                vRow := 0;
                vCol := 0;
                vRow1 := 0;
                vRow2 := vStartRow + 1;
              end else
              begin
                vRow := vEdtInfo.TotalLines - 1;
                vCol := MaxInt;
                vRow1 := vStartRow;
                vRow2 := vEdtInfo.TotalLines;
              end;
              gProgressLast := 0;
             {$ifdef bTrace}
              vStart := 0;
             {$endif bTrace}
              vLoop := True;
              Continue;
            end;

          end;

          Break;
        end;

      end {while};

    finally
     {$ifdef Far3}
      FarEditorSubscribeChangeEvent(-1{AID}, True);
     {$endif Far3}

      if gFoundCount > 0 then begin
        if not vPrompt then
          GotoPosition(vRow, vCol, vCol + vFindLen,
            IntIf(optCursorAtEnd and AForward, vCol + vFindLen, vCol), {ACenter:}True);
        LocShow(vRow, vCol, -1);
      end;

      if optGroupUndo then begin
       {$ifdef Far3}
        vUndoRec.StructSize := SizeOf(vUndoRec);
       {$endif Far3}
        vUndoRec.Command := EUR_END;
        FarEditorControl(ECTL_UNDOREDO, @vUndoRec);
      end;

      FreeObj(vFinder);
    end;

    if vErrorMode > 0 then begin
      if gFoundCount > 0 then
        ShowMessage(gProgressTitle, Format(gProgressAdd, [gFoundCount, gReplCount]), FMSG_MB_OK)
      else
        ShowMessage(gProgressTitle, GetMsgStr(strNotFound) + #10 + AFindStr, FMSG_WARNING or FMSG_MB_OK);
    end;

    Result := gFoundCount > 0;
  end;



  procedure Replace(APickWord :Boolean);
  var
    vEntire :Boolean;
  begin
//  SyncFindStr;
    if not ReplaceDlg(APickWord, vEntire) then
      Exit;
   {$ifdef bAdvSelect}
    EdtClearMark;
   {$endif bAdvSelect}
    gLastOpt := gOptions;
    gLastIsReplace := True;
    ReplaceStr(gStrFind, gStrRepl, gLastOpt, vEntire, False, not gReverse);
  end;


  procedure RepeatLast(AForward :Boolean);
  begin
//  SyncFindStr;
    if gStrFind = '' then
      Find(False)
    else
    if gLastIsReplace then
      ReplaceStr(gStrFind, gStrRepl, gLastOpt, False, True, AForward)
    else
      FindStr(gStrFind, gLastOpt, False, True, AForward);
  end;



 {$ifdef bAdvSelect}

  procedure UpdateEdtMatches;
  var
    vHelper :TEdtHelper;


    procedure ClearAllColors(const AInfo :TEditorInfo);
   {$ifdef bPreciseMatch}
    var
      i :Integer;
    begin
      for i := 0 to vHelper.FAll.Count - 1 do
        with PEdtSelection(vHelper.FAll.PItems[I])^ do
          FarEditorDelColor(FRow, FCol, FLen);
      vHelper.Reset;
   {$else}
    var
      i, vRow1, vRow2 :Integer;
    begin
      vRow1 := AInfo.TopScreenLine;
      vRow2 := AInfo.TopScreenLine + AInfo.WindowSizeY - 1;

      with vHelper do
        if FRow1 <= FRow2 then begin
          if ((FRow1 >= vRow1) and (FRow1 <= vRow2)) or ((vRow1 >= FRow1) and (vRow1 <= FRow2)) then begin
            { Диапазоны пересекаются }
            vRow1 := IntMin(vRow1, FRow1);
            vRow2 := IntMax(vRow2, FRow2);
          end else
          begin
            { Диапазоны не пересекаются }
//          TraceF('Clear1: %d-%d', [FRow1, FRow2]);
            for i := FRow1 to FRow2 do
              FarEditorDelColor(i, -1, 0);
          end;
        end;

      { Диапазон, видимый на экране очищается всегда, потому что мы не можем }
      { отследить, какие элементы вышли за пределы экрана при модификациях... }
//    TraceF('Clear2: %d-%d', [vRow1, vRow2]);
      for i := vRow1 to vRow2 do
        FarEditorDelColor(i, -1, 0);

      vHelper.Reset;
   {$endif bPreciseMatch}
    end;


    procedure EdtSetColor(const ASel :TEdtSelection; AColor :TFarColor);
    begin
      if ASel.FLen <= 0 then
        Exit;
//    TraceF('SetColor: %d:%d, %d', [ASel.FRow, ASel.FCol, ASel.FLen]);
      FarEditorSetColor(ASel.FRow, ASel.FCol, ASel.FLen, AColor, optMarkWholeTab);
      vHelper.AddFound(ASel);
    end;

{
    procedure EdtShowMessage;
    var
      vCoord :TCoord;
      vWIdth :Integer;
      vRes :DWORD;
      vBuf :PWord;
    begin
      with FarGetWindowRect do begin
        vCoord.X := Left;
        vCoord.Y := Bottom;
        vWidth := Right - Left;
      end;

      vBuf := MemAlloc( SizeOf(Word) * vWidth);
      try
        WriteConsoleOutputCharacter(hStdOut, PTChar(gEdtMess), length(gEdtMess), vCoord, vRes);

        MemFill2(vBuf, vWidth, $CE);
        WriteConsoleOutputAttribute(hStdOut, vBuf, vWidth, vCoord, vRes);
      finally
        MemFree(vBuf);
      end;
//    FARAPI.Text(0, 1, $CE, PTChar(gEdtMess));
//    FARAPI.Text(0, 0, 0, nil);
    end;
}

  var
    I :Integer;
    vInfo :TEditorInfo;
    vNeedUpdate :Boolean;
  begin
   {$ifdef Far3}
    vInfo.StructSize := SizeOf(vInfo);
   {$endif Far3}
    FarEditorControl(ECTL_GETINFO, @vInfo);
    vHelper := FindEdtHelper(vInfo.EditorID, False);

    vNeedUpdate := False;
    if (gMatchStr <> '') and (vInfo.EditorID = gEdtID) then begin
      try
        vNeedUpdate := UpdateMatches(vInfo);
       {$ifdef Far3}
       {$else}
        vNeedUpdate := True;
       {$endif Far3}
      except
        FreeObj(gMatches);
        gMatchStr := '';
      end;
    end;

    if (gFound.FLen > 0) or (gMatches <> nil) then begin
      if not vNeedUpdate and not gUpdFound then
        Exit;
    end else
    begin
      if (vHelper = nil) {or (vHelper.FRow2 < 0)} then
        Exit;
    end;

    if vHelper <> nil then
      ClearAllColors(vInfo);

    if (gFound.FLen > 0) or (gMatches <> nil) then begin
      if vHelper = nil then
        vHelper := FindEdtHelper(vInfo.EditorID, True);

      if gMatches <> nil then begin
//      TraceF('AddColors (%d matces)', [gMatches.Count]);
        for I := 0 to gMatches.Count - 1 do
          EdtSetColor(PEdtSelection(gMatches.PItems[I])^, optMatchColor);
      end;

      if gFound.FLen > 0 then
        EdtSetColor(gFound, optCurFindColor);
    end;
    gUpdFound := False;

//  if gEdtMess <> '' then
//    EdtShowMessage;
  end;


  procedure RefreshEdtMatches;
  begin
    gMatchRow2 := 0;  { Поддерживать }
  end;

 {$endif bAdvSelect}


{$ifdef bAdvSelect}
initialization
  gEdtHelpers := TObjList.Create;

finalization
  FreeObj(gEdtHelpers);
  FreeObj(gMatches);
{$endif bAdvSelect}
end.


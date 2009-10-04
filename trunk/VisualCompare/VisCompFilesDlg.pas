{$I Defines.inc}

unit VisCompFilesDlg;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,
    MixWinUtils,

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

    VisCompCtrl,
    VisCompFiles;


  type
    TFilesDlg = class;

    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FItem :TCmpFileItem;
      FPos  :Word;
      FLen  :Byte;
      FSel  :Byte;  { 1 - выделено слева, 2 - выделено справа, 3 - выделены обе}
    end;

    TMyFilter = class(TExList)
    public
      procedure Add(AItem :TCmpFileItem; APos, ALen :Integer; AIndex :Integer = -1);

    public
      function ItemCompare(PItem, PAnother :Pointer; Context :Integer) :Integer; override;
    end;


    TFilesDlg = class(TFarDialog)
    public
      constructor Create; override;
      destructor Destroy; override;

      function GetFileItem(ADlgIndex :Integer) :TCmpFileItem;
      function GetCurrentItem :TCmpFileItem;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer) :Integer; override;
      procedure ErrorHandler(E :Exception); override;

    private
      FGrid           :TFarGrid;

      FRootItems      :TCmpFolder;
      FItems          :TCmpFolder;

      FUnfold         :Boolean;
      FExpandAll      :Boolean;

      FHeadColor      :Integer;
      FSameColor      :Integer;
      FOrphanColor    :Integer;
      FOlderColor     :Integer;
      FNewerColor     :Integer;
      FFoundColor     :Integer;
      FDiffColor      :Integer;
      FSelColor       :Integer;

      FFilter         :TMyFilter;
      FFilterMode     :Boolean;
      FFilterMask     :TString;
      FFilterColumn   :Integer;
      FTotalCount     :Integer;
      FSelectedCount  :Integer;
      FMenuMaxWidth   :Integer;

//    FResFile        :TString;
      FResCmd         :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure ResizeDialog;
      procedure UpdateHeader;
      procedure UpdateFooter;
      procedure ReinitGrid;
      procedure SetCurrent(AIndex :Integer; AMode :TLocationMode);
      function FindItem(AItem :TCmpFileItem) :Integer;
      function GetCurSide :Integer;

      procedure ReinitAndSaveCurrent;
      procedure ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
      procedure SetOrder(AOrder :Integer; ADiffAtTop :Boolean);

      procedure SelectCurrent(ACommand :Integer);
      procedure GotoCurrent;
      procedure LeaveGroup;
      procedure CompareCurrent(AForcePrompt :Boolean);
      procedure ViewOrEditCurrent(AEdit :Boolean);
      procedure CompareSelectedContents;
      procedure OptionsMenu;

    public
      property Grid :TFarGrid read FGrid;
    end;


  procedure ShowFilesDlg(AFiles :TCmpFolder);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

 {-----------------------------------------------------------------------------}

  function Date2StrMode(ADate :TDateTime; AMode :Integer) :TString;
  begin
    if ADate <> 0 then begin
      if AMode = 1 then
        Result := FormatDate('dd.MM.yy', ADate)
      else
        Result := FormatDate('dd.MM.yy', ADate) + ' ' + FormatTime('HH:mm', ADate);
    end else
      Result := '';
  end;


  function AttrToStr(Attr :Word) :TString;
  begin
    Result := '....';
    if faReadOnly and Attr <> 0 then
      Result[1] := 'R';
    if faHidden and Attr <> 0 then
      Result[2] := 'H';
    if faSysFile and Attr <> 0 then
      Result[3] := 'S';
    if faArchive and Attr <> 0 then
      Result[4] := 'A';
  end;


  function GetOptColor(AColor, ASysColor :Integer) :Integer;
  begin
    Result := AColor;
    if Result = 0 then
      Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(ASysColor));
  end;



 {-----------------------------------------------------------------------------}
 { TMyFilter                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyFilter.Add(AItem :TCmpFileItem; APos, ALen :Integer; AIndex :Integer = -1);
  var
    vRec :TFilterRec;
  begin
    vRec.FItem  := AItem;
    vRec.FPos   := Word(APos);
    vRec.FLen   := Byte(ALen);
    vRec.FSel   := 0;
    if AIndex = -1 then
      AddData(vRec)
    else
      InsertData(AIndex, vRec)
  end;


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :Integer) :Integer; {override;}
  var
    vItem1, vItem2 :TCmpFileItem;
  begin
    vItem1 := PFilterRec(PItem).FItem;
    vItem2 := PFilterRec(PAnother).FItem;

    Result := -LogCompare(vItem1.IsFolder, vItem2.IsFolder);
    if Context <> 0 then
      {Файлы вначале (Unfold режим)}
      Result := -Result;

    if Result = 0 then begin
      if optDiffAtTop then
        { Изменения вначале }
        Result := -IntCompare(Integer(vItem1.GetResume), Integer(vItem2.GetResume));

      if Result = 0 then begin
        case Abs(optFileSortMode) of
          smByName:
            Result := UpCompareStr(vItem1.Name, vItem2.Name);
          smByExt:
            begin
              Result := UpCompareStr(ExtractFileExtension(vItem1.Name), ExtractFileExtension(vItem2.Name));
              if Result = 0 then
                Result := UpCompareStr(vItem1.Name, vItem2.Name);
            end;
          smByDate:
            Result := IntCompare(IntMax(vItem1.Time[0], vItem1.Time[1]), IntMax(vItem2.Time[0], vItem2.Time[1]));
          smBySize:
            Result := Int64Compare(Int64Max(vItem1.Size[0], vItem1.Size[1]), Int64Max(vItem2.Size[0], vItem2.Size[1]));
        end;

        if optFileSortMode < 0 then
          Result := -Result;

        {???}
//      if Result = 0 then
//        Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
      end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TFilesDlg                                                                   }
 {-----------------------------------------------------------------------------}

  const
    cDlgMinWidth  = 40;
    cDlgMinHeight = 5;

    IdFrame  = 0;
    IdIcon   = 1;
    IdHead1  = 2;
    IdHead2  = 3;
    IdList   = 4;
    IdStatus = 5;


  constructor TFilesDlg.Create; {override;}
  begin
    inherited Create;
//  RegisterHints(Self);
    FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));

    FHeadColor     := optHeadColor;
    FSameColor     := optSameColor;
    FOrphanColor   := optOrphanColor;
    FOlderColor    := optOlderColor;
    FNewerColor    := optNewerColor;
    FFoundColor    := optFoundColor;
    FDiffColor     := optDiffColor;
    FSelColor      := optSelColor;
  end;


  destructor TFilesDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FFilter);
//  UnregisterHints;
    inherited Destroy;
  end;


  procedure TFilesDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FHelpTopic := '';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 5;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_Text,        DX-7, 1, 3, 1, 0, cNormalIcon),
        NewItemApi(DI_Text,        3, 2, DX div 2, 1, DIF_SETCOLOR or optHeadColor, '...'),
        NewItemApi(DI_Text,        DX div 2 + 1, 2, DX - 6, 1, DIF_SETCOLOR or optHeadColor, '...'),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0, '' )
//      NewItemApi(DI_Text,        3, 3, DX - 6, 1, DIF_CENTERTEXT, '...')
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdList);
    FGrid.Options := [goRowSelect {, goFollowMouse} {,goWheelMovePos} ];
    FGrid.NormColor := GetOptColor(0, COL_DIALOGTEXT);
    FGrid.SelColor := GetOptColor(optCurColor, COL_DIALOGLISTSELECTEDTEXT);

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
  end;


  procedure TFilesDlg.InitDialog; {override;}
  begin
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    ReinitGrid;
  end;


  procedure TFilesDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect, vRect1 :TSmallRect;
    vScreenInfo :TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(hStdOut, vScreenInfo);

    if optMaximized then begin
      vWidth := vScreenInfo.dwSize.X;
      vHeight := vScreenInfo.dwSize.Y;

      vRect := SBounds(0, 0, vWidth-1, vHeight-1);
      SendMsg(DM_SHOWITEM, IdFrame, 0);

      vRect1 := SBounds(vRect.Right - 2, vRect.Top, 2, 0);
      SendMsg(DM_SETITEMPOSITION, IdIcon, @vRect1);
      SetTextApi(IdIcon, cMaximizedIcon)
    end else
    begin
      vWidth := FMenuMaxWidth + 6;
      if vWidth > vScreenInfo.dwSize.X - 4 then
        vWidth := vScreenInfo.dwSize.X - 4;
      vWidth := IntMax(vWidth, cDlgMinWidth);

      vHeight := FGrid.RowCount + 5;
      if vHeight > vScreenInfo.dwSize.Y - 2 then
        vHeight := vScreenInfo.dwSize.Y - 2;
      vHeight := IntMax(vHeight, cDlgMinHeight);

      vRect := SBounds(2, 1, vWidth - 5, vHeight - 3);
      SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);
      SendMsg(DM_SHOWITEM, IdFrame, 1);

      vRect1 := SBounds(vRect.Right - 4, vRect.Top, 2, 0);
      SendMsg(DM_SETITEMPOSITION, IdIcon, @vRect1);
      SetTextApi(IdIcon, cNormalIcon);

      SRectGrow(vRect, -1, -1);
    end;

    vRect1 := vRect;
    Inc(vRect1.Top);
    if not optMaximized and (vRect1.Bottom - vRect1.Top + 2 <= FGrid.RowCount) then
      Inc(vRect1.Right);
    SendMsg(DM_SETITEMPOSITION, IdList, @vRect1);
    FGrid.UpdateSize(vRect1.Left, vRect1.Top, vRect1.Right - vRect1.Left + 1, vRect1.Bottom - vRect1.Top + 1);

    vRect1 := SRect(vRect.Left, vRect.Top, vRect.Left + (vRect.Right - vRect.Left) div 2 - 1, 2);
    SendMsg(DM_SETITEMPOSITION, IdHead1, @vRect1);
    vRect1 := SRect(vRect1.Right + 2, vRect.Top, vRect.Right, 2);
    if optMaximized then
      Dec(vRect1.Right, 3);
    SendMsg(DM_SETITEMPOSITION, IdHead2, @vRect1);

    SetDlgPos(-1, -1, vWidth, vHeight);
  end;



  procedure TFilesDlg.SetCurrent(AIndex :Integer; AMode :TLocationMode);
  begin
    FGrid.GotoLocation(FGrid.CurCol, AIndex, AMode);
  end;


  procedure TFilesDlg.UpdateHeader;
  var
    vStr :TString;
  begin
    vStr := GetMsgStr(strTitle);
    if not FFilterMode then
      vStr := Format('%s (%d)', [ vStr, FTotalCount ])
    else
      vStr := Format('%s [%s] (%d/%d)', [vStr, FFilterMask, FFilter.Count, FTotalCount ]);

    if length(vStr)+2 > FMenuMaxWidth then
      FMenuMaxWidth := length(vStr)+2;

    SetText(IdFrame, vStr);

    vStr := ' ' + FItems.Folder1;
    SetText(IdHead1, vStr);

    vStr := ' ' + FItems.Folder2;
    SetText(IdHead2, vStr);
  end;


  procedure TFilesDlg.UpdateFooter;
  begin
    {...}
  end;


  procedure TFilesDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if ADouble then
      SelectCurrent(1);
  end;


  procedure TFilesDlg.GridPosChange(ASender :TFarGrid);
  begin
    { Обновляем status-line }
    UpdateFooter;
  end;


  function TFilesDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  var
    vItem :TCmpFileItem;
    vTag, vVer :Integer;
    vAttr :Word;
  begin
    Result := '';
    if ARow < FFilter.Count then begin
      vItem := GetFileItem(ARow);
      if vItem = nil then
        Exit; { Элемент ".."}

      vTag := FGrid.Column[ACol].Tag;
      vVer := (vTag and $00FF) - 1;
      vTag := (vTag and $FF00) shr 8;

      vAttr := vItem.Attr[vVer];
      if faPresent and vAttr <> 0 then begin
        case vTag of
          1: {};
          2:
            if faDirectory and vAttr = 0 then
              Result := Int64ToStr(vItem.Size[vVer]);
          3:
            if (faDirectory and vAttr = 0) or optShowFolderAttrs then
              Result := Date2StrMode(FileDateToDateTime(vItem.Time[vVer]), 2);
          4:
            if (faDirectory and vAttr = 0) or optShowFolderAttrs then
              Result := AttrToStr(vItem.Attr[vVer]);
        end;
      end else
      begin
//      if True then
//        Result := StringOfChar(chrHatch, FGrid.Column[ACol].RealWidth);
      end;
    end;
  end;


  procedure TFilesDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
  var
    vRec :PFilterRec;
    vItem :TCmpFileItem;
    vTag, vVer :Integer;
    vColor :Integer;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      vItem := vRec.FItem;
      if vItem = nil then
        Exit; { Элемент ".."}

      if ACol < 0 then begin

//      if (ARow <> FGrid.CurRow) and not Odd(ARow) then
//        AColor := $F0;

        if (ARow = FGrid.CurRow) then
          {}
        else begin
          if optHilightDiff then begin
            { Подсвечивается вся строка, в которой обнаружены хоть какие-то различия }

            if vItem.GetResume <> crSame then
              AColor := optDiffColor
            else begin
              if not FUnfold and vItem.HasAttr(faDirectory) and ([crDiff, crOrphan1, crOrphan2] * vItem.GetFolderResume <> []) then
                AColor := optDiffColor;
            end;

          end;
        end;

      end else
      begin
        vTag := FGrid.Column[ACol].Tag;
        vVer := (vTag and $00FF) - 1;
        vTag := (vTag and $FF00) shr 8;

        vColor := -1;
        if vItem.BothAttr(faPresent) then begin
          { Подсвечивается ячейка, в которой обнаружены различия }

          case vTag of
            1:
              if optCompareContents then begin
                { Сравниваем содержимое }
                if vItem.HasAttr(faDirectory) then begin

                  if not FUnfold and (vItem.Subs <> nil) and ([crUncomp, crDiff, crOrphan1, crOrphan2] * vItem.GetFolderResume = []) then
                    vColor := FSameColor

                end else
                begin
                  if vItem.Content <> ccNoCompare then
                    if vItem.Content = ccDiff then
                      vColor := FNewerColor
                    else
                      vColor := FSameColor;
                end;
              end;

            2:
              if (optCompareSize and (faDirectory and vItem.Attr[vVer] = 0)) then begin
                { Сравнимаем размер }
                if vItem.Size[vVer] <> vItem.Size[1-vVer] then
                  vColor := FNewerColor
                else
                  vColor := FSameColor;
              end;

            3:
              if optCompareTime and (optCompareFolderAttrs or (faDirectory and vItem.Attr[vVer] = 0)) then begin
                { Сравнимаем даты }
                if vItem.Time[vVer] > vItem.Time[1-vVer] then
                  vColor := FNewerColor
                else
                if vItem.Time[vVer] < vItem.Time[1-vVer] then
                  vColor := FOlderColor
                else
                  vColor := FSameColor;
              end;

            4:
              if optCompareAttr and (optCompareFolderAttrs or (faDirectory and vItem.Attr[vVer] = 0)) then begin
                { Сравнимаем атрибуты }
                if vItem.Attr[vVer] and faComparedAttrs <> vItem.Attr[1-vVer] and faComparedAttrs then
                  vColor := FNewerColor
                else
                  vColor := FSameColor;
              end;
          end;

        end else
        begin
          if faPresent and vItem.Attr[vVer] <> 0 then
            { Непарный элемент (сирота) }
            vColor := FOrphanColor;
        end;

        {!!!}
        if vRec.FSel and (1 shl vVer) <> 0 then
          AColor := FSelColor;

        if vColor <> -1 then
          AColor := (AColor and not $0F) or (vColor and $0F)

      end;
    end;
  end;


  procedure TFilesDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  var
    vRec :PFilterRec;
    vItem :TCmpFileItem;
    vTag, vVer :Integer;
    vAttr :Word;
    vStr :TString;

    procedure LocDraw(ACount :Integer; ATxtColor :Integer);
    var
      vStr :TString;
    begin
      if (AWidth > 0) and (ACount <> 0) then begin
        Inc(X); Dec(AWidth);
        vStr := Int2Str(ACount);
        ATxtColor := (AColor and not $0F) or (ATxtColor and $0F);
        FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, ATxtColor);
        Inc(X, Length(vStr)); Dec(AWidth, Length(vStr));
      end;
    end;

    procedure LocDrawEx(const AStr :TString; APos, ALen :Integer);
    begin
      if (ALen > 0) (*and (FGrid.Column[ACol].Tag = FFilterColumn)*) then
        { Выделение части строки, совпадающей с фильтром... }
        FGrid.DrawChrEx(X, Y, PTChar(AStr), AWidth, APos, ALen, AColor, (AColor and not $0F) or (FFoundColor and $0F))
      else
        FGrid.DrawChr(X, Y, PTChar(AStr), AWidth, AColor);
      Inc(X, Length(AStr)); Dec(AWidth, Length(AStr));
    end;

  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      vItem := vRec.FItem;
      if vItem = nil then begin
        { Элемент ".."}
        FGrid.DrawChr(X+1, Y, '..', AWidth-1, AColor);
        Exit;
      end;

      vTag := FGrid.Column[ACol].Tag;
      vVer := (vTag and $00FF) - 1;
      vTag := (vTag and $FF00) shr 8;

      if (ARow = FGrid.CurRow) and (vVer = GetCurSide) then begin
        FGrid.DrawChr(X-1, Y, '>', 1, AColor);
      end;


      vAttr := vItem.Attr[vVer];
      if faPresent and vAttr <> 0 then begin

        if vTag = 1 then begin

          if FUnfold then begin

            if faDirectory and vAttr <> 0 then begin
              if vVer = 0 then
                vStr := vItem.ParentGroup.Folder1
              else
                vStr := vItem.ParentGroup.Folder2;
              vStr := AddBackSlash(vStr);
              LocDrawEx(vStr + vItem.Name, Length(vStr) + vRec.FPos, vRec.FLen);
            end else
            begin
              Inc(X); Dec(AWidth);
              LocDrawEx(vItem.Name, vRec.FPos, vRec.FLen);
            end;

          end else
          begin
            if faDirectory and vAttr <> 0 then begin
              vStr := StrIf(vItem.Subs <> nil, '+', '-');
              FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
              Inc(X); Dec(AWidth);

              LocDrawEx(vItem.Name, vRec.FPos, vRec.FLen);

              if optShowFilesInFolders and (vItem.Subs <> nil) then begin
                LocDraw(vItem.Subs.OrphanCount[vVer], FOrphanColor);
                LocDraw(vItem.Subs.DiffCount, FNewerColor);
                LocDraw(vItem.Subs.SameCount, FSameColor);
                LocDraw(vItem.Subs.UncompCount, FGrid.NormColor);
              end;

            end else
            begin
              Inc(X); Dec(AWidth);
              LocDrawEx(vItem.Name, vRec.FPos, vRec.FLen);
            end;
          end;

        end;

      end;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFilesDlg.ReinitGrid;
  var
    vMaxLen, vMaxLen2, vMaxLen3, vMaxLen4 :Integer;
    vMask :TString;
    vMaxSize :Int64;
    vHasMask :Boolean;


    function CheckFilter(AItem :TCmpFileItem) :Boolean;
    begin
      case AItem.GetResume of
        crSame   : Result := optShowSame;
        crDiff   : Result := optShowDiff;
        crOrphan1,
        crOrphan2: Result := optShowOrphan;
      else
        Result := True;
      end;
    end;


    function CheckFolderFilter(AItem :TCmpFileItem) :Boolean;
    var
      vResume :TFolderResume;
    begin
      vResume := AItem.GetFolderResume;
      Result := True;
      if not optShowSame and ((vResume = [crSame]) or (vResume = [])) then
        Result := False;
    end;

(*
    function CheckFolderFilter(AItem :TCmpFileItem) :Boolean;
    var
      vResume :TFolderResume;
    begin
      vResume := AItem.GetFolderResume;
      Result :=
        (optShowSame and (crSame in vResume)) or
        (optShowDiff and (crDiff in vResume)) or
        (optShowOrphan and ([crOrphan1, crOrphan2] * vResume <> []));
    end;
*)

    procedure LocAddList(AFilter :TMyFilter; AList :TCmpFolder);
    var
      I, vLen, vPos :Integer;
      vItem :TCmpFileItem;
      vTitle :TString;
      vNeedFilter :Boolean;
    begin
      vNeedFilter := not optShowSame or not optShowDiff or not optShowOrphan;

      for I := 0 to AList.Count - 1 do begin
        vItem := AList[I];

        if vNeedFilter then begin

          if vItem.Subs <> nil then begin

            if vItem.BothAttr(faPresent) then begin

              if not CheckFolderFilter(vItem) then
                Continue;

            end else
            begin

              if not optShowOrphan then
                Continue;

            end;

          end else
          if not CheckFilter(vItem) then
            Continue;

        end;

        vTitle := vItem.Name;

        Inc(FTotalCount);
        vPos := 0; vLen := 0;
        if vMask <> '' then begin
          if not CheckMask(vMask, vTitle, vHasMask, vPos, vLen) then
            if FUnfold and (vItem.Subs <> nil) then
              { Папки пока оставляем - они отфильтруются по содержимому. }
            else
              Continue;
        end;

        AFilter.Add(vItem, vPos, vLen);

        vMaxLen := IntMax(vMaxLen, Length(vTitle));
        if vItem.Size[0] > vMaxSize then
          vMaxSize := vItem.Size[0];
        if vItem.Size[1] > vMaxSize then
          vMaxSize := vItem.Size[1];
      end;
    end;


    procedure LocAddUnfold(AParent :TCmpFileItem; AList :TCmpFolder);
    var
      I :Integer;
      vRec :PFilterRec;
      vItem :TCmpFileItem;
      vTmpFilter :TMyFilter;
    begin
      vTmpFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));
      try
        LocAddList(vTmpFilter, AList);
        vTmpFilter.SortList(True, 1); {Файлы вначале}

        for I := 0 to vTmpFilter.Count - 1 do begin
          vRec := vTmpFilter.PItems[I];
          vItem := vRec.FItem;

          if vItem.Subs = nil then begin
            if AParent <> nil then begin
              { Вставляем заголовок группы, только когда в нее попадает хотя бы один файл... }
              FFilter.Add(AParent, 0, 0);
              AParent := nil;
            end;
            FFilter.Add(vItem, vRec.FPos, vRec.FLen);
          end else
          begin
            if vRec.FLen > 0 then begin
              { Группа попадает под фильтр, оставляем ее безусловно }
              FFilter.Add(vItem, vRec.FPos, vRec.FLen);
              LocAddUnfold(nil, vItem.Subs)
            end else
              LocAddUnfold(vItem, vItem.Subs)
          end;
        end;

      finally
        FreeObj(vTmpFilter);
      end;
    end;


  var
    I :Integer;
    vOpt :TColOptions;
  begin
//  Trace('ReinitGrid...');
    FFilter.Clear;
    vMaxLen := 0;
    vMaxSize := 0;
    FTotalCount := 0;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(vMask)] <> '?')} then
        vMask := vMask + '*';
    end;

    if not FUnfold then begin
      LocAddList(FFilter, FItems);
      FFilter.SortList(True, 0);
      if FRootItems <> FItems then
        { Элемент ".." для выхода из группы }
        FFilter.Add(nil, 0, 0, 0);
    end else
      LocAddUnfold(nil, FItems);

    Inc(vMaxLen, 2);  

    vMaxLen2 := 0;
    if optShowSize then
      vMaxLen2 := Length(Int64ToStr(vMaxSize)) + 2;

    vMaxLen3 := 0;
    if optShowTime then
      vMaxLen3 := Length(Date2StrMode(Now, 2{!!!})) + 2;

    vMaxLen4 := 0;
    if optShowAttr then
      vMaxLen4 := Length(AttrToStr(0)) + 2;

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;

    vOpt := [coColMargin, coNoVertLine ];

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], $0101) );
    if optShowSize then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen2, taRightJustify, vOpt, $0201) );
    if optShowTime then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen3, taLeftJustify, vOpt, $0301) );
    if optShowAttr then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen4, taLeftJustify, vOpt, $0401) );

    with FGrid.Column[FGrid.Columns.Count - 1] do
      Options := Options - [coNoVertLine];

    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, vOpt + [coOwnerDraw], $0102) );
    if optShowSize then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen2, taRightJustify, vOpt, $0202) );
    if optShowTime then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen3, taLeftJustify, vOpt, $0302) );
    if optShowAttr then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen4, taLeftJustify, vOpt, $0402) );

    FMenuMaxWidth := vMaxLen * 2 + 5;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );

    FSelectedCount := 0;
    FGrid.RowCount := FFilter.Count;

    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      UpdateHeader;
      ResizeDialog;
      UpdateFooter;
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TFilesDlg.FindItem(AItem :TCmpFileItem) :Integer;
  var
    I :Integer;
    vItem :TCmpFileItem;
  begin
    Result := -1;
    for I := 0 to FGrid.RowCount - 1 do begin
      vItem := GetFileItem(I);
      if vItem = AItem then begin
        Result := I;
        Exit;
      end;
    end;
  end;


  function TFilesDlg.GetFileItem(ADlgIndex :Integer) :TCmpFileItem;
  begin
    Result := nil;
    if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then
      Result := PFilterRec(FFilter.PItems[ADlgIndex]).FItem;
  end;


  function TFilesDlg.GetCurrentItem :TCmpFileItem;
  begin
    Result := GetFileItem( FGrid.CurRow );
  end;


  function TFilesDlg.GetCurSide :Integer;
  begin
    if FGrid.CurCol < FGrid.Columns.Count div 2 then
      Result := 0
    else
      Result := 1;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFilesDlg.OptionsMenu;
  const
    cMenuCount = 18;
  var
    I, vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      {!!!Локализация}
      SetMenuItemChrEx(vItem, 'Show Folder Summary   Ctrl+1');
      SetMenuItemChrEx(vItem, 'Show Size             Ctrl+2');
      SetMenuItemChrEx(vItem, 'Show Time             Ctrl+3');
      SetMenuItemChrEx(vItem, 'Show Attrs            Ctrl+4');
      SetMenuItemChrEx(vItem, 'Show folder attrs');
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, 'Compare Contents');
      SetMenuItemChrEx(vItem, 'Compare Size');
      SetMenuItemChrEx(vItem, 'Compare Time');
      SetMenuItemChrEx(vItem, 'Compare Attr');
      SetMenuItemChrEx(vItem, 'Compare folder attrs');
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, 'Show Same');
      SetMenuItemChrEx(vItem, 'Show Diff');
      SetMenuItemChrEx(vItem, 'Show Orphan');
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, 'Hilight difference');
      SetMenuItemChrEx(vItem, 'Unfold                Ctrl+U');

      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, optShowFilesInFolders);
        vItems[1].Flags := SetFlag(0, MIF_CHECKED1, optShowSize);
        vItems[2].Flags := SetFlag(0, MIF_CHECKED1, optShowTime);
        vItems[3].Flags := SetFlag(0, MIF_CHECKED1, optShowAttr);
        vItems[4].Flags := SetFlag(0, MIF_CHECKED1, optShowFolderAttrs);
        {}
        vItems[6].Flags  := SetFlag(0, MIF_CHECKED1, optCompareContents);
        vItems[7].Flags  := SetFlag(0, MIF_CHECKED1, optCompareSize);
        vItems[8].Flags  := SetFlag(0, MIF_CHECKED1, optCompareTime);
        vItems[9].Flags  := SetFlag(0, MIF_CHECKED1, optCompareAttr);
        vItems[10].Flags := SetFlag(0, MIF_CHECKED1, optCompareFolderAttrs);
        {}
        vItems[12].Flags  := SetFlag(0, MIF_CHECKED1, optShowSame);
        vItems[13].Flags  := SetFlag(0, MIF_CHECKED1, optShowDiff);
        vItems[14].Flags  := SetFlag(0, MIF_CHECKED1, optShowOrphan);
        {}
        vItems[16].Flags := SetFlag(0, MIF_CHECKED1, optHilightDiff);
        vItems[17].Flags := SetFlag(0, MIF_CHECKED1, FUnfold);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          'Options',
          '',
          '',
          nil, nil,
          Pointer(vItems),
          cMenuCount);

        if vRes = -1 then
          Exit;

        case vRes of
          0: ToggleOption(optShowFilesInFolders);
          1: ToggleOption(optShowSize);
          2: ToggleOption(optShowTime);
          3: ToggleOption(optShowAttr);
          4: ToggleOption(optShowFolderAttrs);
          5: {};
          6: ToggleOption(optCompareContents, True);
          7: ToggleOption(optCompareSize, True);
          8: ToggleOption(optCompareTime, True);
          9: ToggleOption(optCompareAttr, True);
          10: ToggleOption(optCompareFolderAttrs, True);
          11: {};
          12: ToggleOption(optShowSame);
          13: ToggleOption(optShowDiff);
          14: ToggleOption(optShowOrphan);
          15: {};
          16: ToggleOption(optHilightDiff);
          17: ToggleOption(FUnfold);
        end;
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFilesDlg.ReinitAndSaveCurrent;
  var
    vItem :TCmpFileItem;
    vIndex :Integer;
  begin
    SendMsg(DM_ENABLEREDRAW, 0, 0);
    try
      vItem := GetCurrentItem;
      ReinitGrid;
      vIndex := FindItem(vItem);
      if vIndex < 0 then
        vIndex := 0;
      SetCurrent( vIndex, lmSafe );
    finally
      SendMsg(DM_ENABLEREDRAW, 1, 0);
    end;
  end;


  procedure TFilesDlg.ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
  begin
    AOption := not AOption;
    if ANeedUpdateDigest then
      UpdateFolderDidgets(FRootItems);
    ReinitAndSaveCurrent;
    WriteSetup;
  end;


  procedure TFilesDlg.SetOrder(AOrder :Integer; ADiffAtTop :Boolean);
  begin
    if AOrder <> 0 then
      if AOrder <> optFileSortMode then
        optFileSortMode := AOrder
      else
        optFileSortMode := -AOrder;
    optDiffAtTop := ADiffAtTop;
//  ReinitAndSaveCurrent;
    ReinitGrid;
    WriteSetup;
  end;


  procedure TFilesDlg.SelectCurrent(ACommand :Integer);
  var
    vItem :TCmpFileItem;
  begin
    vItem := GetCurrentItem;
    if vItem <> nil then begin
      if vItem.Subs <> nil then begin
        FItems := vItem.Subs;
        ReinitGrid;
        SetCurrent( 0, lmScroll );
      end else
        CompareCurrent(ACommand = 2)
    end else
      LeaveGroup;
  end;


  procedure TFilesDlg.LeaveGroup;
  var
    vItem :TCmpFileItem;
    vIndex :Integer;
  begin
    if FItems.ParentItem <> nil then begin
      vItem := FItems.ParentItem;
      FItems := vItem.ParentGroup;
      ReinitGrid;
      vIndex := FindItem(vItem);
      if vIndex < 0 then
        vIndex := 0;
      SetCurrent( vIndex, lmSafe );
    end else
      Beep;
  end;


  procedure TFilesDlg.CompareSelectedContents;
  var
    vIndex :Integer;
    vRec  :PFilterRec;
    vItem :TCmpFileItem;
    vList :TCmpFolder;
  begin
    vItem := nil;
    vIndex := FGrid.CurRow;
    if (vIndex >= 0) and (vIndex < FFilter.Count) then begin
      vRec := FFilter.PItems[vIndex];
      vItem := vRec.FItem;
    end;

    if vItem <> nil then begin
      vList := TCmpFolder.Create;
      try
        vList.Folder1 := vItem.ParentGroup.Folder1;
        vList.Folder2 := vItem.ParentGroup.Folder2;

        vList.Add(vItem);
        CompareContents(vList);

        UpdateFolderDidgets(FRootItems);
        ReinitAndSaveCurrent;

      finally
        vList.Clear;
        FreeObj(vList);
      end;
    end else
      Beep;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFilesDlg.CompareCurrent(AForcePrompt :Boolean);
  var
    vItem :TCmpFileItem;
    vRes :Integer;
    vParam :TString;
    vCmd :TFarStr;
    vStr :array[0..256] of TFarChar;
  begin
    vItem := GetCurrentItem;
    if (vItem <> nil) and not vItem.IsFolder and vItem.BothAttr(faPresent) then begin

      if (optCompareCmd = '') or AForcePrompt then begin
        vCmd := optCompareCmd;
        {!!!Локализация}
        vRes := FARAPI.InputBox(
          'Compare',
          'Command:',
          '',
          PFarChar(vCmd),
          @vStr[0],
          256,
          nil,
          FIB_BUTTONS or FIB_NOUSELASTHISTORY or FIB_ENABLEEMPTY);
        if vRes <> 1 then
          Exit;

        vCmd := vStr;
        if vCmd = '' then
          Exit;

        optCompareCmd := vCmd;
        WriteSetup;
      end;

      vParam := '"' + vItem.GetFullFileName(0) + '" "' + vItem.GetFullFileName(1) + '"';
      ShellOpen(0, optCompareCmd, vParam);

    end else
      Beep;
  end;


  procedure TFilesDlg.ViewOrEditCurrent(AEdit :Boolean);
  var
    vItem :TCmpFileItem;
    vVer :Integer;
    vName :TFarStr;
    vSave :THandle;
  begin
    vItem := GetCurrentItem;
    vVer := GetCurSide;

    if (vItem <> nil) and (faPresent and vItem.Attr[vVer] <> 0) and not vItem.IsFolder then begin

      { Глючит, если в процессе просмотра/редактирования файла изменить размер консоли...}
      SendMsg(DM_ShowDialog, 0, 0);
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      try

        vName := vItem.GetFullFileName(vVer);
        if AEdit then
          FARAPI.Editor(PFarChar(vName), nil, 0, 0, -1, -1, EF_ENABLE_F6, 0, 1, CP_AUTODETECT)
        else
          FARAPI.Viewer(PFarChar(vName), nil, 0, 0, -1, -1, VF_ENABLE_F6, CP_AUTODETECT);

        if vItem.UpdateInfo then
          UpdateFolderDidgets(FRootItems);

      finally
        FARAPI.RestoreScreen(vSave);
        SendMsg(DM_ShowDialog, 1, 0);
      end;

      ResizeDialog;

    end else
      Beep;
  end;


  procedure JumpToFile(Active :Boolean; const AFileName :TString);
  var
    vStr :TFarStr;
  begin
//  TraceF('Jump to file: %s', [AFileName]);
    vStr := RemoveBackSlash(ExtractFilePath(AFileName));
    if WinFolderExists(vStr) then begin
      FarPanelJumpToPath(Active, vStr);

      vStr := ExtractFileName(AFileName);
      if vStr <> '' then
        FarPanelSetCurrentItem(Active, vStr);
    end;    
  end;


  procedure TFilesDlg.GotoCurrent;
  var
    vItem :TCmpFileItem;
    vVer :Integer;
  begin
    vItem := GetCurrentItem;
    vVer := GetCurSide;

    if (vItem = nil) and not FUnfold then
      { Позиция - ".." }
      vItem := FItems.ParentItem;

    if (vItem <> nil) then begin

      if vItem.ParentGroup.Folder1 <> '' then
        JumpToFile( True, vItem.GetFullFileName(0) );
      if vItem.ParentGroup.Folder2 <> '' then
        JumpToFile( False, vItem.GetFullFileName(1) );

      FResCmd  := 0;
      SendMsg(DM_CLOSE, -1, 0);
    end;
  end;

  
 {-----------------------------------------------------------------------------}

  function TFilesDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :Integer): Integer; {override;}

    procedure LocFoldUnfold;
    begin
      FUnfold := not FUnfold;
      ReinitGrid;
      SetCurrent( 0, lmScroll );
    end;


    procedure LocSetFilter(const ANewFilter :TString);
    begin
      if ANewFilter <> FFilterMask then begin
//      TraceF('Mask: %s', [ANewFilter]);
        if not FFilterMode then
          FFilterColumn := FGrid.Column[FGrid.CurCol].Tag;
        FFilterMode := ANewFilter <> '';
        FFilterMask := ANewFilter;
        ReinitAndSaveCurrent;
      end;
    end;


    procedure LocSetCheck(AIndex :Integer; ASetOn :Integer);
    var
      vVer, vMask :Integer;
      vRec :PFilterRec;
      vOldOn :Boolean;
    begin
      vVer := GetCurSide;
      vMask := 1 shl vVer;
      vRec := FFilter.PItems[AIndex];
      if (vRec.FItem <> nil) and (faPresent and vRec.FItem.Attr[vVer] <> 0) then begin

//      if FUnfold and (faDirectory and vRec.FItem.Attr[vVer] <> 0) then
//        Exit;

        vOldOn := vRec.FSel and vMask <> 0;
        if ASetOn = -1 then
          ASetOn := IntIf(vOldOn, 0, 1);
        if ASetOn = 1 then
          vRec.FSel := vRec.FSel or vMask
        else
          vRec.FSel := vRec.FSel and not vMask;
        if vOldOn then
          Dec(FSelectedCount);
        if ASetOn = 1 then
          Inc(FSelectedCount);
      end;
    end;


    procedure LocSelectCurrent;
    var
      vIndex :Integer;
    begin
      vIndex := FGrid.CurRow;
      if vIndex = -1 then
        Exit;
      LocSetCheck(vIndex, -1);
      if vIndex < FGrid.RowCount - 1 then
        SetCurrent(vIndex + 1, lmScroll);
    end;


    procedure LocSelectAll(AFrom :Integer; ASetOn :Integer);
    var
      I :Integer;
    begin
      for I := AFrom to FGrid.RowCount - 1 do
        LocSetCheck(I, ASetOn);
      SendMsg(DM_REDRAW, 0, 0);
    end;


  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE: begin
        ResizeDialog;
        UpdateFooter; { Чтобы центрировался status-line }
        SetCurrent(FGrid.CurRow, lmScroll);
      end;

      DN_MOUSECLICK:
        if Param1 = IdIcon then
          ToggleOption(optMaximized)
        else
        if (Param1 = IdHead1) or (Param1 = IdHead2) then
          NOP
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER:
            SelectCurrent(1);
          KEY_SHIFTENTER:
            SelectCurrent(2);
          KEY_CTRLPGDN:
            GotoCurrent;
          KEY_CTRLPGUP:
            LeaveGroup;
          KEY_CTRL + Byte('\'):
            begin
              {Go to root...}
              FItems := FRootItems;
              ReinitGrid;
              SetCurrent( 0, lmScroll );
            end;

          KEY_TAB:
            if GetCurSide = 0 then
              FGrid.GotoLocation(FGrid.Columns.Count div 2, FGrid.CurRow, lmSimple)
            else
              FGrid.GotoLocation(0, FGrid.CurRow, lmSimple);
          KEY_LEFT:
            FGrid.GotoLocation(0, FGrid.CurRow, lmSimple);
          KEY_RIGHT:
            FGrid.GotoLocation(FGrid.Columns.Count div 2, FGrid.CurRow, lmSimple);

          KEY_F2:
            OptionsMenu;
          KEY_F3:
            ViewOrEditCurrent(False);
          KEY_F4:
            ViewOrEditCurrent(True);
          KEY_F5:
            Sorry;
          KEY_F6:
            Sorry;
          KEY_F8:
            Sorry;

          { Выделение }
          KEY_INS:
            LocSelectCurrent;
          KEY_CTRLADD:
            LocSelectAll(0, 1);
          KEY_CTRLSUBTRACT:
            LocSelectAll(0, 0);
          KEY_CTRLMULTIPLY:
            LocSelectAll(0, -1);

          KEY_CTRLU:
            LocFoldUnfold;
          KEY_CTRLA:
            begin
              FExpandAll := not FExpandAll;
              ReinitAndSaveCurrent;
            end;
          KEY_CTRL + Byte('='):
            CompareSelectedContents;

(*
          KEY_CTRL + Byte('-'):
            ToggleFilter(fmShowDiff);
*)

          KEY_CTRLM:
            ToggleOption(optMaximized);

          KEY_CTRL1:
            ToggleOption(optShowFilesInFolders);
          KEY_CTRL2:
            ToggleOption(optShowSize);
          KEY_CTRL3:
            ToggleOption(optShowTime);
          KEY_CTRL4:
            ToggleOption(optShowAttr);
(*
          KEY_CTRLF10:
            SetOrder(0);
          KEY_CTRLF1, KEY_CTRLSHIFTF1:
            SetOrder(1);
          KEY_CTRLF2, KEY_CTRLSHIFTF2:
            SetOrder(2);
*)
          KEY_CTRLF3, KEY_CTRLSHIFTF3:
            SetOrder(smByName, optDiffAtTop);
          KEY_CTRLF4, KEY_CTRLSHIFTF4:
            SetOrder(smByExt, optDiffAtTop);
          KEY_CTRLF5, KEY_CTRLSHIFTF5:
            SetOrder(smByDate, optDiffAtTop);
          KEY_CTRLF6, KEY_CTRLSHIFTF6:
            SetOrder(smBySize, optDiffAtTop);
          KEY_CTRLF7, KEY_CTRLSHIFTF7:
            SetOrder(0, not optDiffAtTop);
          KEY_CTRLF12:
            Sorry {SortByDlg};

          { Фильтрация }
          KEY_DEL, KEY_ALT, KEY_RALT:
            LocSetFilter('');
          KEY_BS:
            if FFilterMask <> '' then
              LocSetFilter( Copy(FFilterMask, 1, Length(FFilterMask) - 1));

          KEY_ADD      : LocSetFilter( FFilterMask + '+' );
          KEY_SUBTRACT : LocSetFilter( FFilterMask + '-' );
          KEY_DIVIDE   : LocSetFilter( FFilterMask + '/' );
          KEY_MULTIPLY : LocSetFilter( FFilterMask + '*' );

        else
//        TraceF('Key: %d', [Param2]);
         {$ifdef bUnicodeFar}
          if (Param2 >= 32) and (Param2 < $FFFF) then
         {$else}
          if (Param2 >= 32) and (Param2 <= $FF) then
         {$endif bUnicodeFar}
          begin
           {$ifdef bUnicodeFar}
            LocSetFilter(FFilterMask + WideChar(Param2));
           {$else}
            LocSetFilter(FFilterMask + StrDos2Win(AnsiChar(Param2)));
           {$endif bUnicodeFar}
          end else
            Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


  procedure TFilesDlg.ErrorHandler(E :Exception); {override;}
  begin
    HandleError(E);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ShowFilesDlg(AFiles :TCmpFolder);
  var
    vDlg :TFilesDlg;
    vFinish :Boolean;
  begin
    vDlg := TFilesDlg.Create;
    try
      UpdateFolderDidgets(AFiles);
      vDlg.FRootItems := AFiles;
      vDlg.FItems := AFiles;

      vFinish := False;
      while not vFinish do begin
        vDlg.FResCmd := 0;
        if (vDlg.Run = -1) or (vDlg.FResCmd = 0) then
          Exit;

        vFinish := True;
(*
        if vDlg.FResCmd = 1 then
          JumpToFile(vDlg.FResFile);
*)
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


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
      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;
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
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;
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
      FSelectedCount  :array[0..1] of Integer;
      FMenuMaxWidth   :Integer;

//    FCurSide        :Integer;
      FWholeLine      :Boolean;

      FResCmd         :Integer;
      FResLog         :Boolean;
      FResStr         :TString;

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
      procedure GetSelected(AList :TStringList; AVer :Integer; AFullPath :Boolean);

      procedure ReinitAndSaveCurrent;
      procedure ToggleOption(var AOption :Boolean; ANeedUpdateDigest :Boolean = False);
      procedure SetOrder(AOrder :Integer; ADiffAtTop :Boolean);

      procedure SelectCurrent(ACommand :Integer);
      procedure GotoCurrent;
      procedure CopySelected;
      procedure SendToTempPanel;
      procedure LeaveGroup;
      procedure CompareCurrent(AForcePrompt :Boolean);
      procedure ViewOrEditCurrent(AEdit :Boolean);
      procedure CompareSelectedContents;
      procedure SortByDlg;
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


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
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

    FWholeLine     := True;
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
        NewItemApi(DI_Text,        3, 2, DX div 2, 1, DIF_SETCOLOR or DIF_SHOWAMPERSAND or optHeadColor, '...'),
        NewItemApi(DI_Text,        DX div 2 + 1, 2, DX - 6, 1, DIF_SETCOLOR or DIF_SHOWAMPERSAND or optHeadColor, '...'),
        NewItemApi(DI_USERCONTROL, 3, 3, DX - 6, DY - 4, 0, '' )
//      NewItemApi(DI_Text,        3, 3, DX - 6, 1, DIF_CENTERTEXT, '...')
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdList);
    FGrid.Options := [{goRowSelect} {, goFollowMouse} {,goWheelMovePos} ];
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
      if (ARow = FGrid.CurRow) and FWholeLine then
        AColor := FGrid.SelColor;

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
              if not FUnfold and vItem.HasAttr(faDirectory) and ([crDiff, crOrphan] * vItem.GetFolderResume <> []) then
                AColor := optDiffColor;
            end;

          end;
        end;

      end else
      begin
        vTag := FGrid.Column[ACol].Tag;
        vVer := (vTag and $00FF) - 1;
        vTag := (vTag and $FF00) shr 8;

        if (ARow = FGrid.CurRow) and (GetCurSide = vVer) then
          AColor := FGrid.SelColor;

        vColor := -1;
        if vItem.BothAttr(faPresent) then begin
          { Подсвечивается ячейка, в которой обнаружены различия }

          case vTag of
            1:
              if optCompareContents then begin
                { Сравниваем содержимое }
                if vItem.HasAttr(faDirectory) then begin

                  if not FUnfold and (vItem.Subs <> nil) and ([crUncomp, crDiff, crOrphan] * vItem.GetFolderResume = []) then
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

        if (vRec.FSel and (1 shl vVer) <> 0) and (AColor <> FGrid.SelColor) then
          AColor := FSelColor;

        if vColor <> -1 then
          AColor := (AColor and $F0) or (vColor and $0F)

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

    procedure LocDrawCount(ACount :Integer; ATxtColor :Integer);
    var
      vStr :TString;
    begin
      if (AWidth > 0) and (ACount <> 0) then begin
        Inc(X); Dec(AWidth);
        vStr := Int2Str(ACount);
        if (AColor = FGrid.SelColor) and (((AColor and $F0) shr 4) = (ATxtColor and $0F)) then
          { Чтобы не пропадали цифры, если их цвет совпадает с фоном текущей строки }
          ATxtColor := FGrid.SelColor;
        ATxtColor := (AColor and $F0) or (ATxtColor and $0F);
        FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, ATxtColor);
        Inc(X, Length(vStr)); Dec(AWidth, Length(vStr));
      end;
    end;

    procedure LocDrawEx(const AStr :TString; APos, ALen :Integer);
    begin
      if (ALen > 0) (*and (FGrid.Column[ACol].Tag = FFilterColumn)*) then
        { Выделение части строки, совпадающей с фильтром... }
        FGrid.DrawChrEx(X, Y, PTChar(AStr), AWidth, APos, ALen, AColor, (AColor and $F0) or (FFoundColor and $0F))
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
                LocDrawCount(vItem.Subs.OrphanCount[vVer], FOrphanColor);
                LocDrawCount(vItem.Subs.DiffCount, FNewerColor);
                LocDrawCount(vItem.Subs.SameCount, FSameColor);
                LocDrawCount(vItem.Subs.UncompCount, FGrid.NormColor);
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
        crOrphan : Result := optShowOrphan;
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

        {!!! Учесть Folder Summary}
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

    FSelectedCount[0] := 0;
    FSelectedCount[1] := 0;
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
    if FWholeLine then
      Result := -1
    else begin
      if FGrid.CurCol < FGrid.Columns.Count div 2 then
        Result := 0
      else
        Result := 1;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFilesDlg.SortByDlg;
  const
    cSortMenuCount = 6;
  var
    vRes :Integer;
    vChr :TChar;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cSortMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(StrSortByName));
      SetMenuItemChrEx(vItem, GetMsg(StrSortByExt));
      SetMenuItemChrEx(vItem, GetMsg(StrSortByDate));
      SetMenuItemChrEx(vItem, GetMsg(StrSortBySize));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strDiffAtTop));

      vRes := Abs(optFileSortMode) - 1;
      vChr := '+';
      if optFileSortMode < 0 then
        vChr := '-';
      if (vRes >= 0) and (vRes < 4) then
        vItems[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);
      vItems[5].Flags := SetFlag(0, MIF_CHECKED, optDiffAtTop);

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(StrSortByTitle),
        '',
        '',
        nil, nil,
        Pointer(vItems),
        cSortMenuCount);

      case vRes of
        0: SetOrder(smByName, optDiffAtTop);
        1: SetOrder(smByExt, optDiffAtTop);
        2: SetOrder(-smByDate, optDiffAtTop);
        3: SetOrder(-smBySize, optDiffAtTop);
        5: SetOrder(0, not optDiffAtTop);
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TFilesDlg.OptionsMenu;
  const
    cMenuCount = 20;
  var
    I, vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];

      SetMenuItemChrEx(vItem, GetMsg(StrMShowFolderSummary));
      SetMenuItemChrEx(vItem, GetMsg(StrMShowSize));
      SetMenuItemChrEx(vItem, GetMsg(StrMShowTime));
      SetMenuItemChrEx(vItem, GetMsg(StrMShowAttrs));
      SetMenuItemChrEx(vItem, GetMsg(StrMShowFolderAttrs));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(StrMSortBy));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(StrMCompContents));
      SetMenuItemChrEx(vItem, GetMsg(StrMCompSize));
      SetMenuItemChrEx(vItem, GetMsg(StrMCompTime));
      SetMenuItemChrEx(vItem, GetMsg(StrMCompAttr));
      SetMenuItemChrEx(vItem, GetMsg(StrMCompFolderAttrs));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(StrMShowSame));
      SetMenuItemChrEx(vItem, GetMsg(StrMShowDiff));
      SetMenuItemChrEx(vItem, GetMsg(StrMShowOrphan));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(StrMHilightDiff));
      SetMenuItemChrEx(vItem, GetMsg(StrMUnfold));

      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, optShowFilesInFolders);
        vItems[1].Flags := SetFlag(0, MIF_CHECKED1, optShowSize);
        vItems[2].Flags := SetFlag(0, MIF_CHECKED1, optShowTime);
        vItems[3].Flags := SetFlag(0, MIF_CHECKED1, optShowAttr);
        vItems[4].Flags := SetFlag(0, MIF_CHECKED1, optShowFolderAttrs);
        {}
        vItems[8].Flags  := SetFlag(0, MIF_CHECKED1, optCompareContents);
        vItems[9].Flags  := SetFlag(0, MIF_CHECKED1, optCompareSize);
        vItems[10].Flags  := SetFlag(0, MIF_CHECKED1, optCompareTime);
        vItems[11].Flags  := SetFlag(0, MIF_CHECKED1, optCompareAttr);
        vItems[12].Flags := SetFlag(0, MIF_CHECKED1, optCompareFolderAttrs);
        {}
        vItems[14].Flags  := SetFlag(0, MIF_CHECKED1, optShowSame);
        vItems[15].Flags  := SetFlag(0, MIF_CHECKED1, optShowDiff);
        vItems[16].Flags  := SetFlag(0, MIF_CHECKED1, optShowOrphan);
        {}
        vItems[18].Flags := SetFlag(0, MIF_CHECKED1, optHilightDiff);
        vItems[19].Flags := SetFlag(0, MIF_CHECKED1, FUnfold);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strOptions),
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
          6: SortByDlg;
          7: {};
          8: ToggleOption(optCompareContents, True);
          9: ToggleOption(optCompareSize, True);
          10: ToggleOption(optCompareTime, True);
          11: ToggleOption(optCompareAttr, True);
          12: ToggleOption(optCompareFolderAttrs, True);
          13: {};
          14: ToggleOption(optShowSame);
          15: ToggleOption(optShowDiff);
          16: ToggleOption(optShowOrphan);
          17: {};
          18: ToggleOption(optHilightDiff);
          19: ToggleOption(FUnfold);
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
    vVer :Integer;
    vItem :TCmpFileItem;
    vList :TStringList;
  begin
    vList := TStringList.Create;
    try
      vVer := GetCurSide;
      if vVer = -1 then
        vVer := 0; {???}

      if FSelectedCount[vVer] = 0 then begin
        vItem := GetCurrentItem;
        vList.AddObject('', vItem);
      end else
        GetSelected(vList, vVer, False);

      CompareFilesContents('', vList);

      UpdateFolderDidgets(FRootItems);
      ReinitAndSaveCurrent;

    finally
      FreeObj(vList);
    end;
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

        vRes := FARAPI.InputBox(
          GetMsg(strCompareTitle),
          GetMsg(strCompareCommand),
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
    vSave :THandle;
  begin
    vItem := GetCurrentItem;
    vVer := GetCurSide;
    if (vItem <> nil) and (vVer <> -1) and (faPresent and vItem.Attr[vVer] <> 0) and not vItem.IsFolder then begin

      { Глючит, если в процессе просмотра/редактирования файла изменить размер консоли...}
      SendMsg(DM_ShowDialog, 0, 0);
      vSave := FARAPI.SaveScreen(0, 0, -1, -1);
      try
        FarEditOrView(vItem.GetFullFileName(vVer), AEdit, EF_ENABLE_F6);

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


  function JumpToFile(Active :Boolean; const AFileName :TString) :Boolean;
  var
    vStr :TString;
  begin
    Result := False;
//  TraceF('Jump to file: %s', [AFileName]);
    vStr := RemoveBackSlash(ExtractFilePath(AFileName));
    if WinFolderExists(vStr) then begin
      FarPanelJumpToPath(Active, vStr);

      vStr := ExtractFileName(AFileName);
      if vStr <> '' then
        FarPanelSetCurrentItem(Active, vStr);

      Result := True;
    end;
  end;


  procedure TFilesDlg.GotoCurrent;
  var
    vItem :TCmpFileItem;
    vName :TString;
    vVer, vSide :Integer;
    vSelected :TStringList;
  begin
    vItem := GetCurrentItem;
    vVer := GetCurSide;

    if (vItem = nil) and not FUnfold then
      { Позиция - ".." }
      vItem := FItems.ParentItem;

    if (vItem <> nil) then begin
      vSelected := TStringList.Create;
      try
        { Строим сортированный список, чтобы быстрее работал FarPanelSetSelectedItems }
        vSelected.Sorted := True;

        vName := vItem.Name;
        if vItem <> FItems.ParentItem then
          vName := RemoveBackSlash(vName);

        vSide := CurrentPanelSide;

        if vItem.ParentGroup.Folder1 <> '' then
          if JumpToFile( vSide = 0, AddFileName(vItem.ParentGroup.Folder1, vName) ) then
            if FSelectedCount[0] > 0 then begin
              GetSelected(vSelected, 0, False);
              FarPanelSetSelectedItems( vSide = 0, vSelected);
            end;

        if vItem.ParentGroup.Folder2 <> '' then
          if JumpToFile( vSide <> 0, AddFileName(vItem.ParentGroup.Folder2, vName) ) then
            if FSelectedCount[1] > 0 then begin
              GetSelected(vSelected, 1, False);
              FarPanelSetSelectedItems(vSide <> 0, vSelected);
            end;

      finally
        FreeObj(vSelected);
      end;

      FResLog := (vVer <> -1) and (vSide <> GetCurSide);
      FResCmd := 1;
      SendMsg(DM_CLOSE, -1, 0);
    end;
  end;


  procedure TFilesDlg.CopySelected;
  var
    vVer :Integer;
    vItem :TCmpFileItem;
    vSelected :TStringList;
  begin
    vVer := GetCurSide;
    if vVer = -1 then
      vVer := 0; {???}

    if FSelectedCount[vVer] = 0 then begin
      vItem := GetCurrentItem;
      if (vItem <> nil) and (faPresent and vItem.Attr[vVer] <> 0) then
        CopyToClipboard(vItem.GetFullFileName(vVer))
      else
        Beep;
    end else
    begin
      vSelected := TStringList.Create;
      try
        GetSelected(vSelected, vVer, True);
        CopyToClipboard(vSelected.Text)
      finally
        FreeObj(vSelected);
      end;
    end
  end;


  procedure TFilesDlg.SendToTempPanel;
  var
    vVer :Integer;
    vSelected :TStringList;
    vFileName :TString;
  begin
    vSelected := TStringList.Create;
    try
      vVer := GetCurSide;
      if vVer = -1 then
        vVer := 0; {???}

      GetSelected(vSelected, vVer, True);

      if vSelected.Count > 0 then begin
        vFileName := StrGetTempFileName(StrGetTempPath, 'tmp');
       {$ifdef bUnicodeFar}
        vSelected.SaveToFile(vFileName);
       {$else}
        vSelected.SaveToFile(vFileName, sffAnsi);
       {$endif bUnicodeFar}

        FResStr := vFileName;
        FResLog := CurrentPanelSide <> vVer;
        FResCmd := 2;
        SendMsg(DM_CLOSE, -1, 0);
      end else
        Beep;

    finally
      FreeObj(vSelected);
    end;
  end;


  procedure TFilesDlg.GetSelected(AList :TStringList; AVer :Integer; AFullPath :Boolean);
  var
    I :Integer;
    vRec :PFilterRec;
    vMask :Integer;
  begin
    AList.Clear;
    vMask := 1 shl AVer;
    for I := 0 to FGrid.RowCount - 1 do begin
      vRec := FFilter.PItems[I];
      if (vRec.FItem <> nil) and (faPresent and vRec.FItem.Attr[AVer] <> 0) and (vRec.FSel and vMask <> 0) then begin
        if AFullPath then
          AList.AddObject( vRec.FItem.GetFullFileName(AVer), vRec.FItem )
        else
          AList.AddObject( RemoveBackSlash(vRec.FItem.Name), vRec.FItem );
      end;
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TFilesDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr): TIntPtr; {override;}

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


    procedure LocSetCheck(AIndex, AVer :Integer; ASetOn :Integer);
    var
      vMask :Integer;
      vRec :PFilterRec;
      vOldOn :Boolean;
    begin
      vMask := 1 shl AVer;
      vRec := FFilter.PItems[AIndex];
      if (vRec.FItem <> nil) and (faPresent and vRec.FItem.Attr[AVer] <> 0) then begin

        if FUnfold and (faDirectory and vRec.FItem.Attr[AVer] <> 0) then
          Exit;

        vOldOn := vRec.FSel and vMask <> 0;
        if ASetOn = -1 then
          ASetOn := IntIf(vOldOn, 0, 1);
        if ASetOn = 1 then
          vRec.FSel := vRec.FSel or vMask
        else
          vRec.FSel := vRec.FSel and not vMask;
        if vOldOn then
          Dec(FSelectedCount[AVer]);
        if ASetOn = 1 then
          Inc(FSelectedCount[AVer]);
      end;
    end;


    procedure LocSetCheckEx(AIndex, AVer :Integer; ASetOn :Integer);
    begin
      if (AVer = 0) or (AVer = -1) then
        LocSetCheck(AIndex, 0, ASetOn);
      if (AVer = 1) or (AVer = -1) then
        LocSetCheck(AIndex, 1, ASetOn);
    end;


    procedure LocSelectCurrent;
    var
      vIndex, vVer :Integer;
    begin
      vIndex := FGrid.CurRow;
      if vIndex = -1 then
        Exit;
      vVer := GetCurSide;
      LocSetCheckEx(vIndex, vVer, -1);
      if vIndex < FGrid.RowCount - 1 then
        SetCurrent(vIndex + 1, lmScroll);
    end;


    procedure LocSelectAll(AFrom :Integer; ASetOn :Integer);
    var
      I, vVer :Integer;
    begin
      vVer := GetCurSide;
      for I := AFrom to FGrid.RowCount - 1 do
        LocSetCheckEx(I, vVer, ASetOn);
      SendMsg(DM_REDRAW, 0, 0);
    end;


    procedure LocSelectSameColor(AFrom :Integer; ASetOn :Integer);
    var
      I, vVer :Integer;
      vItem :TCmpFileItem;
      vRec :PFilterRec;
      vResume :TCompareResume;
    begin
      vVer := GetCurSide;
      vItem := GetCurrentItem;
      if (vItem = nil) then
        Exit;

      vResume := vItem.GetResume;

      for I := AFrom to FGrid.RowCount - 1 do begin
        vRec := FFilter.PItems[I];
        if vRec.FItem = nil then
          Continue;
        if vRec.FItem.GetResume <> vResume then
          Continue;
        LocSetCheckEx(I, vVer, ASetOn);
      end;
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
          KEY_CTRLINS:
            CopySelected;
          KEY_ALTP:
            SendToTempPanel;

          KEY_TAB:
            begin
              if GetCurSide = 0 then
                FGrid.GotoLocation(FGrid.Columns.Count div 2, FGrid.CurRow, lmSimple)
              else
                FGrid.GotoLocation(0, FGrid.CurRow, lmSimple);
              FWholeLine := False;
              SendMsg(DM_REDRAW, 0, 0);
            end;
          KEY_LEFT:
            begin
              if GetCurSide = 0 then
                FWholeLine := True
              else begin
                FWholeLine := False;
                FGrid.GotoLocation(0, FGrid.CurRow, lmSimple);
              end;
              SendMsg(DM_REDRAW, 0, 0);
            end;
          KEY_RIGHT:
            begin
              if GetCurSide = 1 then
                FWholeLine := True
              else begin
                FWholeLine := False;
                FGrid.GotoLocation(FGrid.Columns.Count div 2, FGrid.CurRow, lmSimple);
              end;
              SendMsg(DM_REDRAW, 0, 0);
            end;

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
          KEY_ALTADD:
            LocSelectSameColor(0, 1);
          KEY_ALTSUBTRACT:
            LocSelectSameColor(0, -1);

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
            SetOrder(-smByDate, optDiffAtTop);
          KEY_CTRLF6, KEY_CTRLSHIFTF6:
            SetOrder(-smBySize, optDiffAtTop);
          KEY_CTRLF7, KEY_CTRLSHIFTF7:
            SetOrder(0, not optDiffAtTop);
          KEY_CTRLF12:
            SortByDlg;

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
            LocSetFilter(FFilterMask + StrOEMToAnsi(AnsiChar(Param2)));
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

  procedure GotoPanel(Another :Boolean);
  var
    vStr :TFarStr;
    vMacro :TActlKeyMacro;
  begin
    if Another then begin
      vStr := 'Tab';
      vMacro.Command := MCMD_POSTMACROSTRING;
      vMacro.Param.PlainText.SequenceText := PFarChar(vStr);
      vMacro.Param.PlainText.Flags := {KSFLAGS_DISABLEOUTPUT or} KSFLAGS_NOSENDKEYSTOPLUGINS;
      FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
    end;
  end;


  procedure OpenTempPanel(const AFileName :TString; Another :Boolean);
  var
    vStr :TFarStr;
    vMacro :TActlKeyMacro;
  begin
   {$ifdef bUnicodeFar}
    vStr := 'Tmp:' + AFileName;
   {$else}
    vStr := 'Tmp: +ansi +replace ' + AFileName;
   {$endif bUnicodeFar}

   {$ifdef bUnicodeFar}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(vStr));
   {$else}
    vStr := StrAnsiToOem(vStr);
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, PFarChar(vStr));
   {$endif bUnicodeFar}

    if Another then
      vStr := 'Tab Enter'
    else
      vStr := 'Enter';
    vMacro.Command := MCMD_POSTMACROSTRING;
    vMacro.Param.PlainText.SequenceText := PFarChar(vStr);
    vMacro.Param.PlainText.Flags := {KSFLAGS_DISABLEOUTPUT or} KSFLAGS_NOSENDKEYSTOPLUGINS;
    FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
  end;


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

        if vDlg.FResCmd = 1 then
          GotoPanel(vDlg.FResLog);
        if vDlg.FResCmd = 2 then
          OpenTempPanel(vDlg.FResStr, vDlg.FResLog);

        vFinish := True;
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.


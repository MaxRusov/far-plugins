{$I Defines.inc}

unit PlugListDlg;

{******************************************************************************}
{* (c) 2008-2012 Max Rusov                                                    *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Основное окно - список команд                                              *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMatch,
    FarMenu,
    FarDlg,
    FarGrid,
    FarListDlg,

    PlugMenuCtrl,
    PlugMenuPlugs,
    PlugEditDlg,
    PlugInfoDlg,
    PlugLoadDlg;


  var
    LastPlugin  :TString;
    LastFilter  :TString;
    LastColumn  :Integer;


  type
    PFilterRec = ^TFilterRec;
    TFilterRec = packed record
      FIdx :Integer;
      FPos :Word;
      FLen :Byte;
      FSel :Boolean;
    end;

    TMyFilter = class(TExList)
    public
      procedure Add(AIndex, APos, ALen :Integer);

    public
      FWindowType :Integer;

      function ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; override;

    private
      function GetItems(AIndex :Integer) :Integer;

    public
      property Items[AIndex :Integer] :Integer read GetItems; default;
    end;


  type
    TMenuDlg = class(TFarListDlg)
    public
      constructor Create; override;
      destructor Destroy; override;

      function RunCurrentCommand :Boolean;
      function OpenConfig(ATryLoad :Boolean) :Boolean;
      function GotoPluginFolder :Boolean;

      function GetCommand(ADlgIndex :Integer) :TFarPluginCmd;

    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FHotkeyColor1   :TFarColor;
      FHotkeyColor2   :TFarColor;

      FWindowType     :Integer;
      FFilter         :TMyFilter;
      FFilterMode     :Boolean;
      FFilterMask     :TString;
      FFilterColumn   :Integer;
      FTotalCount     :Integer;

      FSetChanged     :Boolean;

      FChoosenCmd     :TFarPluginCmd;
      FChoosenCommand :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridTitleClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);

      procedure UpdateHeader;
      procedure UpdateFooter;
      procedure ReinitGrid;
      procedure ReinitAndSaveCurrent;
      procedure SetCurrent(AIndex :Integer; ACenter :Boolean);
      function DlgToPluginIndex(ADlgIndex :Integer) :Integer;
      function PluginToDlgIndex(APluginIndex :Integer) :Integer;

      function FindShortcut(AChr :TChar) :Integer;
      function FindCommand(ACommand :TFarPluginCmd) :Integer;

      procedure SetOrder(AOrder :Integer);
      procedure SortByDlg;
      procedure OptionsDlg;
      procedure CommandMenu(X :Integer = -1; Y :Integer = -1);

      procedure PlugInfoDlg;
      procedure PlugGoPlugring;
      procedure PlugEditDlg;
      procedure PlugHelpOpen;
      procedure PlugConfigOpen;
      procedure PlugLoad;
      procedure PlugUnLoad;

      procedure SelectItem(ACode :Integer);
      procedure ToggleOption(var AOption :Boolean; ASaveCurrent :Boolean);
      procedure ToggleOptionInt(var AOption :Integer; ANewValue :Integer; ASaveCurrent :Boolean);
      procedure PromptAndLoadPlugin;

      function DlgItemsCount :Integer;
      function CurrentDlgIndex :Integer;
      function CurrentCommandIndex :Integer;
      function CurrentCommand :TFarPluginCmd;
      function CurrentPlugin :TFarPlugin;

    public
      property Grid :TFarGrid read FGrid;
    end;


  procedure OpenMenu(AWinType :Integer; const AInitFilter :TString = '');

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    PlugMenuHints,
    MixDebug;


  const
    colTitle  = 1;
    colFile   = 2;
    colModify = 3;
    colAccess = 4;
    colFlags  = 5;
   {$ifdef Far3}
    colAuthor = 6;
    colVer    = 7;
   {$endif Far3}

   {$ifdef Far3}
    colLast   = colVer;
   {$else}
    colLast   = colFlags;
   {$endif Far3}

  const
    cDescSort = [colModify, colAccess, colFlags {$ifdef Far3}, colVer {$endif Far3}];

 {-----------------------------------------------------------------------------}


  function HotkeyEqual(AChr1, AChr2 :TChar; AByScancode :Boolean) :Boolean;
  begin
    if AByScancode then
      Result := HotkeyEqual(FarXLat(AChr1), AChr2, False) {or HotkeyEqual(AChr1, FarXLat(AChr2), False)}
    else
      Result := (AChr1 = AChr2) or (CharUpCase(AChr1) = CharUpCase(AChr2));
  end;



  function Date2StrMode(ADate :TDateTime; AMode :Integer) :TString;
  begin
    if AMode = 1 then
      Result := FormatDate('dd.MM.yy', ADate)
    else
      Result := FormatDate('dd.MM.yy', ADate) + ' ' + FormatTime('HH:mm', ADate);
    if ADate = 0 then
      Result := StringOfChar(' ', Length(Result));
  end;


 {-----------------------------------------------------------------------------}
 { TMyFilter                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TMyFilter.Add(AIndex, APos, ALen :Integer);
  var
    vRec :TFilterRec;
  begin
    vRec.FIdx := AIndex;
    vRec.FPos := Word(APos);
    vRec.FLen := Byte(ALen);
    vRec.FSel := False;
    AddData(vRec);
  end;


  function TMyFilter.GetItems(AIndex :Integer) :Integer;
  begin
    Result := PFilterRec(PItems[AIndex]).FIdx;
  end;


 {$ifdef Far3}
  function VersionCompare(const AVer1, AVer2 :TVersionInfo) :Integer;
  begin
    Result := IntCompare(AVer1.Major, AVer2.Major);
    if Result = 0 then
      Result := IntCompare(AVer1.Minor, AVer2.Minor);
    if Result = 0 then
      Result := IntCompare(AVer1.Revision, AVer2.Revision);
    if Result = 0 then
      Result := IntCompare(AVer1.Build, AVer2.Build);
    if Result = 0 then
      Result := IntCompare(AVer1.Stage, AVer2.Stage);
  end;
 {$endif Far3}


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vCmd1, vCmd2 :TFarPluginCmd;
  begin
    Result := 0;

    vCmd1 := GetPluginComman(PInteger(PItem)^);
    vCmd2 := GetPluginComman(PInteger(PAnother)^);

    if SortHiddenLast then
      Result := -LogCompare(vCmd1.Plugin.AccessibleInContext(FWindowType), vCmd2.Plugin.AccessibleInContext(FWindowType));

    if Result = 0 then begin
      case Abs(PluginSortMode) of
        colTitle  : Result := UpCompareStr(vCmd1.GetMenuTitle, vCmd2.GetMenuTitle);
        colFile   : Result := UpCompareStr(vCmd1.Plugin.GetFileName(PluginShowFileName), vCmd2.Plugin.GetFileName(PluginShowFileName));
        colModify : Result := DateTimeCompare(vCmd1.Plugin.FileDate, vCmd2.Plugin.FileDate);
        colAccess : Result := DateTimeCompare(vCmd1.AccessDate, vCmd2.AccessDate);
        colFlags  : Result := UpCompareStr(vCmd1.Plugin.GetFlagsStr, vCmd2.Plugin.GetFlagsStr);
       {$ifdef Far3}
        colAuthor : Result := UpCompareStr(vCmd1.Plugin.PlugAuthor, vCmd2.Plugin.PlugAuthor);
        colVer    : Result := VersionCompare(vCmd1.Plugin.PlugVer, vCmd2.Plugin.PlugVer);
       {$endif Far3}
      end;

      if PluginSortMode < 0 then
        Result := -Result;
      if Result = 0 then
        Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
    end;
  end;

 {-----------------------------------------------------------------------------}
 { TMenuDlg                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TMenuDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));
    FHotkeyColor1 := FarGetColor(COL_MENUHIGHLIGHT);
    FHotkeyColor2 := FarGetColor(COL_MENUSELECTEDHIGHLIGHT);
  end;


  destructor TMenuDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FFilter);
    UnregisterHints;
    inherited Destroy;
  end;


  procedure TMenuDlg.Prepare; {override;}
  begin
    inherited Prepare;
    
    FGUID := cPlugListID;
    FHelpTopic := 'PluginCommands';

    FGrid.OnCellClick := GridCellClick;
    FGrid.OnTitleClick := GridTitleClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [{goRowSelect,} goFollowMouse, goWrapMode {,goWheelMovePos} ];
  end;


  procedure TMenuDlg.InitDialog; {override;}
  var
    vIndex :Integer;
  begin
    SendMsg(DM_ShowItem, IdStatus, 1);
    SendMsg(DM_SETMOUSEEVENTNOTIFY, 1, 0);
    FFilter.FWindowType := FWindowType;
    ReinitGrid;
    if FChoosenCmd <> nil then begin
      vIndex := FindCommand(FChoosenCmd);
//    TraceF('SetCurrent: %d', [vIndex]);
      if vIndex <> -1 then
        SetCurrent(vIndex, True);
    end;
  end;


  function TMenuDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if FSetChanged then
      WriteSetup;
    Result := True;
  end;


  procedure TMenuDlg.SetCurrent(AIndex :Integer; ACenter :Boolean);
  var
    vMode :TLocationMode;
  begin
    vMode := lmScroll;
    if ACenter then
      vMode := lmCenter;
    FGrid.GotoLocation(FGrid.CurCol, AIndex, vMode);
  end;


  procedure TMenuDlg.UpdateHeader;
  var
    vTitle :TString;
  begin
    vTitle := GetMsgStr(strTitle);
    if not FFilterMode then
      vTitle := Format('%s (%d)', [ vTitle, FTotalCount ])
    else
      vTitle := Format('%s [%s] (%d/%d)', [vTitle, FFilterMask, FFilter.Count, FTotalCount ]);

    if length(vTitle)+2 > FMenuMaxWidth then
      FMenuMaxWidth := length(vTitle)+2;

    SetText(IdFrame, vTitle);
  end;


  procedure TMenuDlg.UpdateFooter;
  var
    vPlugin :TFarPlugin;
    vFooter :TString;
    vRect :TSmallRect;
  begin
    vPlugin := CurrentPlugin;

    vFooter := '';
    if vPlugin <> nil then begin
      if CheckWinType(FWindowType, vPlugin) then
        vFooter := AppendStrCh(vFooter, 'Enter', ', ');
      vFooter := AppendStrCh(vFooter, 'F2, F3, F4', ', ');
      if vPlugin.ConfigString <> '' then
        vFooter := AppendStrCh(vFooter, 'F9', ', ');
    end;
    SetText(IdStatus, vFooter);

    SendMsg(DM_GETITEMPOSITION, IdStatus, @vRect);
    if vFooter <> '' then begin
      with GetDlgRect do
        vRect.Left := ((Right - Left) - (length(vFooter)+1)) div 2;
      vRect.Right := vRect.Left + length(vFooter)+1;
    end else
    begin
      vRect.Left := 1;
      vRect.Right := 1;
    end;
    SendMsg(DM_SETITEMPOSITION, IdStatus, @vRect);
  end;


  procedure TMenuDlg.GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  begin
//  TraceF('GridCellClick: Pos=%d x %d, Button=%d, Double=%d', [ACol, ARow, AButton, Byte(ADouble)]);
    if (AButton = 1) {and ADouble} then
      SelectItem(1)
    else
    if AButton = 2 then begin
      with GetConsoleMousePos do
        CommandMenu(X, Y);
    end;
  end;


  procedure TMenuDlg.GridTitleClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
  var
    vTag :Integer;
  begin
    if AButton = 1 then begin
      vTag := FGrid.Column[ACol].Tag;
      if vTag in cDescSort then
        vTag := -vTag;
      SetOrder(vTag);
    end else
      SortByDlg;
  end;


  procedure TMenuDlg.GridPosChange(ASender :TFarGrid);
  begin
    { Обновляем status-line }
    UpdateFooter;
  end;


  function TMenuDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
  begin
    if ARow < FFilter.Count then begin
      with GetCommand(ARow) do
        case FGrid.Column[ACol].Tag of
          colTitle  : Result := GetMenuTitle;
          colFile   : Result := Plugin.GetFileName(PluginShowFileName);
          colModify : Result := Date2StrMode(Plugin.FileDate, PluginShowDate);
          colAccess : Result := Date2StrMode(AccessDate, PluginShowUseDate);
          colFlags  : Result := Plugin.GetFlagsStr;
         {$ifdef Far3}
          colAuthor : Result := Plugin.PlugAuthor;
          colVer    : Result := Plugin.PlugVerStr;
         {$endif Far3}
        end;
    end else
      Result := '';
  end;


  procedure TMenuDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :TFarColor);
  begin
    if ARow < FFilter.Count then begin
      with GetCommand(ARow) do begin
        if ACol = -1 then begin
          AColor := FGrid.NormColor;
          if (FGrid.CurRow = ARow) and (FGrid.CurCol = 0) then
            AColor := FGrid.SelColor;
        end else
        begin
          if (PluginShowHidden > 0) and (Hidden or not CheckWinType(FWindowType, Plugin)) then
            AColor := ChangeFG(AColor, optHiddenColor);
        end;
      end;
    end;
  end;


  procedure TMenuDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :TFarColor);
  var
    vRec :PFilterRec;
    vStr :TString;
    vPos, X1 :Integer;
    vSelected :Boolean;
    vColor :TFarColor;
    vMark :array[0..1] of TChar;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      with GetCommand(ARow) do begin
        vSelected := (FGrid.CurRow = ARow) and ((FGrid.CurCol = ACol) or (FGrid.CurCol = 0));

        if ACol = 0 then begin
          if True then begin
            { Назначенный Hotkey }
            if Hotkey <> #0 then begin
              vColor := FHotkeyColor1;
              if vSelected then
                vColor := FHotkeyColor2;
              FGrid.DrawChr(X, Y, @Hotkey, 1, vColor);
            end;
            Inc(X, 2);
            Dec(AWidth, 2);
          end;

          vMark[1] := #0;
          if (AWidth > 0) and (PluginShowHidden > 0) then begin
            { Метка недоступного плагина }
            vMark[0] := #0;
            if not CheckWinType(FWindowType, Plugin) then
              vMark[0] := chrUnaccessibleMark
            else
            if Hidden then
              vMark[0] := chrHiddenMark;
            if vMark[0] <> #0 then
              FGrid.DrawChr(X, Y, @vMark[0], 1, AColor);
            Inc(X, 1);
            Dec(AWidth, 1);
          end;

          X1 := X + AWidth - 1;

          if PluginShowLoaded then begin
            if (Plugin.Loaded or Plugin.Unregistered) then begin
              { Метка загруженного или разрегистрированного плагина }
              if Plugin.Loaded then
                vMark[0] := chrLoadedMark
              else
                vMark[0] := chrUnregisteredMark;
              FGrid.DrawChr(X1, Y, @vMark[0], 1, AColor);
            end;
            Dec(X1);
          end;

          if PluginShowAnsi then begin
            if not Plugin.Unicode then begin
              { Метка ansi-шного плагина }
              vMark[0] := 'A';
              FGrid.DrawChr(X1, Y, @vMark[0], 1, AColor);
            end;
//          Dec(X1);
          end;
        end;

        if AWidth > 0 then begin

          vStr := GridGetDlgText(ASender, ACol, ARow);

          if (vRec.FLen > 0) and (FGrid.Column[ACol].Tag = FFilterColumn) then
            { Выделение части строки, совпадающей с фильтром... }
            FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, ChangeFG(AColor, optFoundColor))
          else begin
            vPos := -1;
            if (ACol = 0) and optAutoShortcut and not FFilterMode and (AutoHotkey <> #0) then
              vPos := ChrPos(AutoHotkey, vStr);

            if vPos > 0 then begin
              vColor := FHotkeyColor1;
              if vSelected then
                vColor := FHotkeyColor2;
              FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vPos - 1, 1, AColor, vColor);
            end else
              FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
          end;
        end;
      end;
    end;
  end;


  procedure TMenuDlg.ReinitGrid;
  var
    I, J, K, vLen, vPos, vMaxLen1, vMaxLen2 {$ifdef Far3}, vMaxLen3, vMaxLen4 {$endif Far3} :Integer;
    vTitle, vDllName, vMask, vXMask, vStr :TString;
    vPlugin :TFarPlugin;
    vCommand :TFarPluginCmd;
    vHasMask :Boolean;
    vOpt :TColOptions;
  begin
//  Trace('ReinitGrid...');
    FFilter.Clear;
    vMaxLen1 := Length(GetMsgStr(strColumnCommand));
    vMaxLen2 := Length(GetMsgStr(strColumnFileName));
   {$ifdef Far3}
    vMaxLen3 := Length(GetMsgStr(strColumnAuthor));
    vMaxLen4 := Length(GetMsgStr(strColumnVersion));
   {$endif Far3}
    FTotalCount := 0;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      if (FFilterColumn = 5) and (vMask[1] <> '*') then
        { Фильтрация по флагам - всегда по вхождению }
        vMask := '*' + vMask;

      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(vMask)] <> '?')} then
        vMask := vMask + '*';

      if optXLatMask then
        vXMask := FarXLatStr(vMask);
    end;

    vDllName := '';
    for I := 0 to FPlugins.Count - 1 do begin
      vPlugin := FPlugins[I];

      if PluginShowHidden < 2 then
        if not CheckWinType(FWindowType, vPlugin) then
          Continue;

      for J := 0 to vPlugin.Commands.Count - 1 do begin
        vCommand := vPlugin.Command[J];
        if PluginShowHidden < 1 then
          if vCommand.Hidden then
            Continue;

        vTitle := vCommand.GetMenuTitle;
        if (PluginShowFileName > 0) or (FFilterColumn = 2) then
          vDllName := vPlugin.GetFileName(PluginShowFileName);

        Inc(FTotalCount);
        vPos := 0; vLen := 0;
        if vMask <> '' then begin
          case FFilterColumn of
            colTitle  : vStr := vTitle;
            colFile   : vStr := vDllName;
            colModify : vStr := Date2StrMode(vPlugin.FileDate, PluginShowDate);
            colAccess : vStr := Date2StrMode(vCommand.AccessDate, PluginShowUseDate);
            colFlags  : vStr := vPlugin.GetFlagsStr;
           {$ifdef Far3}
            colAuthor : vStr := vCommand.Plugin.PlugAuthor;
            colVer    : vStr := vCommand.Plugin.PlugVerStr;
           {$endif Far3}
          end;
          if not ChrCheckXMask(vMask, vXMask, PTChar(vStr), vHasMask, vPos, vLen) then
            Continue;
        end;

        K := (I shl 16) + J;
        FFilter.Add(K, vPos, vLen);

        vMaxLen1 := IntMax(vMaxLen1, Length(vTitle));
        if PluginShowFileName > 0 then
          vMaxLen2 := IntMax(vMaxLen2, Length(vDllName));
       {$ifdef Far3}
        if PluginShowAuthor then
          vMaxLen3 := IntMax(vMaxLen3, Length(vCommand.Plugin.PlugAuthor));
        if PluginShowVer then
          vMaxLen4 := IntMax(vMaxLen4, Length(vCommand.Plugin.PlugVerStr));
       {$endif Far3}
      end;
    end;

//  if PluginSortMode <> 0 then
      FFilter.SortList(True, 0);

    if True then
      Inc(vMaxLen1, 2); { Hotkey }
    if PluginShowHidden > 0 then
      Inc(vMaxLen1, 1); { Hidden mark }
    if PluginShowLoaded then
      Inc(vMaxLen1, 2);
    if PluginShowAnsi then
      Inc(vMaxLen1, 1 + IntIf(PluginShowLoaded, 0, 1));

    vOpt := [coColMargin, coOwnerDraw];
    if not optShowGrid then
      vOpt := vOpt + [coNoVertLine];

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnCommand), vMaxLen1 + 2, 15, taLeftJustify, vOpt, colTitle) );
    if PluginShowFileName > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnFileName), vMaxLen2 + 2, 15, taLeftJustify, vOpt, colFile) );
    if PluginShowDate > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnModify), Length(Date2StrMode(Now, PluginShowDate)) + 2, 8+2, taLeftJustify, vOpt, colModify) );
    if PluginShowUseDate > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnAccess), Length(Date2StrMode(Now, PluginShowUseDate)) + 2, 8+2, taLeftJustify, vOpt, colAccess) );
    if PluginShowFlags then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnFlags), 5+2, 5+2, taLeftJustify, vOpt, colFlags) );
   {$ifdef Far3}
    if PluginShowAuthor then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnAuthor), vMaxLen3 + 2, 5+2, taLeftJustify, vOpt, colAuthor) );
    if PluginShowVer then
      FGrid.Columns.Add( TColumnFormat.CreateEx2('', GetMsgStr(strColumnVersion), vMaxLen4 + 2, 5+2, taLeftJustify, vOpt, colVer) );
   {$endif Far3}

    FGrid.ReduceColumns(FarGetWindowSize.CX - (10 + IntIf(optShowGrid, FGrid.Columns.Count, 1) + FGrid.Margins.Left + FGrid.Margins.Right));

    if optShowTitles then
      FGrid.Options := FGrid.Options + [goShowTitle]
    else
      FGrid.Options := FGrid.Options - [goShowTitle];

    if optFollowMouse then
      FGrid.Options := FGrid.Options + [goFollowMouse]
    else
      FGrid.Options := FGrid.Options - [goFollowMouse];

    if optWrapMode then
      FGrid.Options := FGrid.Options + [goWrapMode]
    else
      FGrid.Options := FGrid.Options - [goWrapMode];

    FGrid.TitleColor  := GetOptColor(optTitleColor, COL_MENUHIGHLIGHT);

    FMenuMaxWidth := 0;
    for I := 0 to FGrid.Columns.Count - 1 do
      with FGrid.Column[I] do
        if Width <> 0 then begin
          if optShowTitles and (Abs(PluginSortMode) = Tag) then
            Header := StrIf(PluginSortMode > 0, chrUpMark, chrDnMark) + Header;
          Inc(FMenuMaxWidth, Width + IntIf(coNoVertLine in Options, 0, 1) );
        end;
    if optShowGrid then
      Dec(FMenuMaxWidth);
    Inc(FMenuMaxWidth, FGrid.Margins.Left + FGrid.Margins.Right);

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


  procedure TMenuDlg.ReinitAndSaveCurrent;
  var
    vIndex :Integer;
  begin
    vIndex := CurrentCommandIndex;
    ReinitGrid;
    vIndex := PluginToDlgIndex(vIndex);
    if vIndex < 0 then
      vIndex := 0;
    SetCurrent( vIndex, False );
//  UpdateHeader; { Чтобы не стирался SortMark}
  end;


 {-----------------------------------------------------------------------------}

  function TMenuDlg.FindShortcut(AChr :TChar) :Integer;

    procedure LocFind(AChr :TChar; ByScanCode :Boolean);
    var
      I :Integer;
      vCommand :TFarPluginCmd;
    begin
      Result := -1;
      for I := 0 to DlgItemsCount - 1 do begin
        vCommand := GetCommand(I);
        if ((vCommand.Hotkey <> #0) and HotkeyEqual(AChr, vCommand.Hotkey, ByScanCode)) or
          (optAutoShortcut and (vCommand.AutoHotkey <> #0) and HotkeyEqual(AChr, vCommand.AutoHotkey, ByScanCode))
        then begin
          Result := I;
          Exit;
        end;
      end;
    end;

  begin
    LocFind(AChr, False);
    if Result = -1 then
      LocFind(AChr, True);
  end;


  function TMenuDlg.FindCommand(ACommand :TFarPluginCmd) :Integer;
  var
    I :Integer;
    vCommand :TFarPluginCmd;
  begin
    Result := -1;
    for I := 0 to DlgItemsCount - 1 do begin
      vCommand := GetCommand(I);
      if vCommand = ACommand then begin
        Result := I;
        Exit;
      end;
    end;
  end;


  function TMenuDlg.DlgToPluginIndex(ADlgIndex :Integer) :Integer;
  begin
    if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then
      Result := FFilter[ADlgIndex]
    else
      Result := -1;
  end;


  function TMenuDlg.PluginToDlgIndex(APluginIndex :Integer) :Integer;
  var
    I :Integer;
  begin
    Result := -1;
    for I := 0 to FFilter.Count - 1 do
      if FFilter[I] = APluginIndex then begin
        Result := I;
        Exit;
      end;
  end;


  function TMenuDlg.GetCommand(ADlgIndex :Integer) :TFarPluginCmd;
  begin
    Result := nil;
    if (ADlgIndex >= 0) and (ADlgIndex < FFilter.Count) then
      Result := GetPluginComman( FFilter[ADlgIndex] )
  end;


  function TMenuDlg.DlgItemsCount :Integer;
  begin
    Result := FGrid.RowCount;
  end;


  function TMenuDlg.CurrentDlgIndex :Integer;
  begin
    Result := FGrid.CurRow;
  end;


  function TMenuDlg.CurrentCommandIndex :Integer;
  begin
    Result := DlgToPluginIndex( CurrentDlgIndex );
  end;


  function TMenuDlg.CurrentCommand :TFarPluginCmd;
  begin
    Result := GetCommand( CurrentDlgIndex );
  end;


  function TMenuDlg.CurrentPlugin :TFarPlugin;
  var
    vCmd :TFarPluginCmd;
  begin
    Result := nil;
    vCmd := CurrentCommand;
    if vCmd <> nil then
      Result := vCmd.Plugin;
  end;

 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.SetOrder(AOrder :Integer);
  begin
    if AOrder <> PluginSortMode then
      PluginSortMode := AOrder
    else
      PluginSortMode := -AOrder;

//  LocReinitAndSaveCurrent;
    ReinitGrid;
    FSetChanged := True;
  end;


  procedure TMenuDlg.SortByDlg;
  var
    vMenu :TFarMenu;
    vRes :Integer;
    vChr :TChar;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(StrSortByTitle),
    [
      GetMsg(StrSortByName),
      GetMsg(StrSortByFileName),
      GetMsg(StrSortByModificationTime),
      GetMsg(StrSortByAccessTime),
      GetMsg(StrSortByPluginFlags),
     {$ifdef Far3}
      GetMsg(StrSortByAuthor),
      GetMsg(StrSortByVersion),
     {$endif Far3}
      GetMsg(StrSortByUnsorted),
      '',
      GetMsg(strSortHiddenLast)
    ]);
    try
      vRes := Abs(PluginSortMode) - 1;
      if vRes = -1 then
        vRes := vMenu.Count - 3;
      vChr := '+';
      if PluginSortMode < 0 then
        vChr := '-';
      vMenu.Items[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);
      vMenu.Checked[vMenu.Count - 1] := SortHiddenLast;

      if not vMenu.Run then
        Exit;

      vRes := vMenu.ResIdx;

      if vRes <> -1 then begin
        if vRes = vMenu.Count - 1 then
          ToggleOption(SortHiddenLast, False)
        else begin
          Inc(vRes);
          if vRes = colLast + 1 then
            vRes := 0;
          if vRes in cDescSort then
            vRes := -vRes;
          SetOrder(vRes);
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TMenuDlg.OptionsDlg;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptionsTitle),
    [
      GetMsg(strShowHidden)
     ,''
     ,GetMsg(strLoadedMark)
     ,GetMsg(strAnsiMark)
     ,GetMsg(strFileName)
     ,GetMsg(strModificationTime)
     ,GetMsg(strAccessTime)
     ,GetMsg(strPluginFlags)
     {$ifdef Far3}
     ,GetMsg(strAuthor)
     ,GetMsg(strVersion)
     {$endif Far3}
    ]);
    try
      while True do begin
        vMenu.Checked[0] := PluginShowHidden > 0;

        vMenu.Checked[2] := PluginShowLoaded;
        vMenu.Checked[3] := PluginShowAnsi;
        vMenu.Checked[4] := PluginShowFileName > 0;
        vMenu.Checked[5] := PluginShowDate > 0;
        vMenu.Checked[6] := PluginShowUseDate > 0;
        vMenu.Checked[7] := PluginShowFlags;
       {$ifdef Far3}
        vMenu.Checked[8] := PluginShowAuthor;
        vMenu.Checked[9] := PluginShowVer;
       {$endif Far3}

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : ToggleOptionInt(PluginShowHidden, IntIf(PluginShowHidden = 0, 2, 0), True);

          2 : ToggleOption(PluginShowLoaded, False);
          3 : ToggleOption(PluginShowAnsi, False);
          4 : ToggleOptionInt(PluginShowFileName, IntIf(PluginShowFileName < 2, PluginShowFileName + 1, 0), False);
          5 : ToggleOptionInt(PluginShowDate, IntIf(PluginShowDate < 2, PluginShowDate + 1, 0), False);
          6 : ToggleOptionInt(PluginShowUseDate, IntIf(PluginShowUseDate < 2, PluginShowUseDate + 1, 0), False);
          7 : ToggleOption(PluginShowFlags, False);
         {$ifdef Far3}
          8 : ToggleOption(PluginShowAuthor, False);
          9 : ToggleOption(PluginShowVer, False);
         {$endif Far3}
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TMenuDlg.CommandMenu(X :Integer = -1; Y :Integer = -1);
  var
    vMenu :TFarMenu;
    vCmd  :TFarPluginCmd;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strCommandsTitle),
    [
      GetMsg(strRunCommand),
      '',
      GetMsg(strPluginHelp),
      GetMsg(strPluginInfo),
      GetMsg(strSetupCommand),
      GetMsg(strPluginConfig),
      '',
      GetMsg(strLoadPlugin),
      GetMsg(strUnloadPlugin),
      '',
      GetMsg(strColumnSetup),
      GetMsg(strSortBy)
    ]);
    try
      vCmd := CurrentCommand;

      vMenu.Enabled[0] := (vCmd <> nil) and CheckWinType(FWindowType, vCmd.Plugin);
      vMenu.Enabled[2] := (vCmd <> nil);
      vMenu.Enabled[3] := (vCmd <> nil);
      vMenu.Enabled[4] := (vCmd <> nil);
      vMenu.Enabled[5] := (vCmd <> nil) and (vCmd.Plugin.ConfigString <> '');

      vMenu.Enabled[7] := (vCmd <> nil) and not vCmd.Plugin.Loaded;
      vMenu.Enabled[8] := (vCmd <> nil) and not vCmd.Plugin.Unregistered;

      vMenu.X := X;
      vMenu.Y := Y;

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0 : SelectItem(1);

        2 : PlugHelpOpen;
        3 : PlugInfoDlg;
        4 : PlugEditDlg;
        5 : PlugConfigOpen;

        7 : PlugLoad;
        8 : PlugUnload;

        10 : OptionsDlg;
        11 : SortByDlg;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;

 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.PlugInfoDlg;
  var
    vCommand :TFarPluginCmd;
  begin
    vCommand := CurrentCommand;
    if vCommand = nil then
      Exit;

    vCommand.Plugin.UpdateVerInfo;
    ViewPluginInfo(vCommand.Plugin, vCommand);
  end;


  procedure TMenuDlg.PlugGoPlugring;
  var
    vCommand :TFarPluginCmd;
  begin
    vCommand := CurrentCommand;
    if vCommand = nil then
      Exit;

    vCommand.Plugin.GotoPluring;
  end;


  procedure TMenuDlg.PlugEditDlg;
  begin
    FChoosenCmd := CurrentCommand;
    if FChoosenCmd <> nil then
      if EditPlugin(FChoosenCmd) then begin
        AssignAutoHotkeys(FWindowType);
        ReinitGrid;
      end;
  end;


  procedure TMenuDlg.PlugHelpOpen;
  begin
    FChoosenCmd := CurrentCommand;
    if FChoosenCmd <> nil then begin
      FChoosenCommand := 2;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TMenuDlg.PlugConfigOpen;
  begin
    FChoosenCmd := CurrentCommand;
    if (FChoosenCmd <> nil) and (FChoosenCmd.Plugin.ConfigString <> '') then begin
      FChoosenCommand := 3; //IntIf(AKey = KEY_F9, 3, 4);
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TMenuDlg.PlugLoad;
  var
    vPlugin :TFarPlugin;
  begin
    vPlugin := CurrentPlugin;
    if vPlugin = nil then
      Exit;
    vPlugin.PluginLoad;
    AssignAutoHotkeys(FWindowType);
    ReinitGrid;
  end;


  procedure TMenuDlg.PlugUnLoad;
  var
    vPlugin :TFarPlugin;
    vRes :Integer;
  begin
    vPlugin := CurrentPlugin;
    if vPlugin = nil then
      Exit;

    vRes := ShowMessage(GetMsgStr(strUnloadTitle), GetMsgStr(strUnloadPropmt) + #10 + vPlugin.Command[0].GetMenuTitle, FMSG_MB_YESNO);
    if vRes <> 0 then
      Exit;

    {!!!}
    vPlugin.PluginUnload(False);
    AssignAutoHotkeys(FWindowType);
    ReinitGrid;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.SelectItem(ACode :Integer);
  begin
    FChoosenCmd := CurrentCommand;
    if (FChoosenCmd <> nil) and CheckWinType(FWindowType, FChoosenCmd.Plugin) then begin
      FChoosenCommand := ACode;
      SendMsg(DM_CLOSE, -1, 0);
    end else
      Beep;
  end;


  procedure TMenuDlg.ToggleOption(var AOption :Boolean; ASaveCurrent :Boolean);
  begin
    AOption := not AOption;
    if ASaveCurrent then
      ReinitAndSaveCurrent
    else
      ReinitGrid;
    FSetChanged := True;
  end;


  procedure TMenuDlg.ToggleOptionInt(var AOption :Integer; ANewValue :Integer; ASaveCurrent :Boolean);
  begin
    AOption := ANewValue;
    if ASaveCurrent then
      ReinitAndSaveCurrent
    else
      ReinitGrid;
    FSetChanged := True;
  end;


  procedure TMenuDlg.PromptAndLoadPlugin;
  var
    vFileName :TString;
    vPlugin :TFarPlugin;
    vIndex :Integer;
  begin
    if LoadPluginDlg(vFileName) then begin
      vPlugin := LoadNewPlugin(vFileName);
      ReinitGrid;
      if vPlugin <> nil then begin
        vIndex := FindCommand( vPlugin.Command[0] );
        SetCurrent( vIndex, False );
      end;
    end;
  end;


  function TMenuDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}

    procedure SetFilter(const ANewFilter :TString);
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

  var
    vChr :TChar;
    vKey, vIndex :Integer;
  begin
    Result := True;

    case AKey of
      KEY_ENTER, KEY_SHIFTENTER:
        SelectItem(1);
      KEY_SHIFTF1:
        PlugHelpOpen;
      KEY_F2:
        CommandMenu;
      KEY_F3:
        PlugInfoDlg;
      KEY_F4:
        PlugEditDlg;
      KEY_F9:
        PlugConfigOpen;
      KEY_SHIFTF9:
        begin
          ConfigDlg;
          ReinitGrid;
        end;

      KEY_CTRLL:
        PromptAndLoadPlugin;
      KEY_INS:
        PlugLoad;
      KEY_DEL:
        PlugUnload;

      KEY_CTRLPGDN:
        begin
          FChoosenCmd := CurrentCommand;
          if (FChoosenCmd <> nil) and (FWindowType = WTYPE_PANELS) then begin
            FChoosenCommand := 5;
            SendMsg(DM_CLOSE, -1, 0);
          end else
            Beep;
        end;
      KEY_CTRLPGUP:
        PlugGoPlugring;

      KEY_CTRLH, KEY_CTRLSHIFTH:
        begin
          if PluginShowHidden <> 0 then
            PluginShowHidden := 0
          else
          if AKey = KEY_CTRLH then
            PluginShowHidden := 2
          else
            PluginShowHidden := 1;
          ReinitAndSaveCurrent;
          FSetChanged := True;
        end;

      KEY_CTRLG:
        ToggleOption(PluginSortGroup, True);
      KEY_CTRLA:
        ToggleOption(optAutoShortcut, False);
      KEY_CTRLN:
        ToggleOption(optShowOrigName, False);

      KEY_CTRL0:
        ToggleOption(optShowGrid, False);
      KEY_CTRL1:
        ToggleOption(PluginShowLoaded, False);
      KEY_CTRLSHIFT1:
        ToggleOption(PluginShowAnsi, False);
      KEY_CTRL2:
        ToggleOptionInt(PluginShowFileName, IntIf(PluginShowFileName < 2, PluginShowFileName + 1, 0), False);
      KEY_CTRL3:
        ToggleOptionInt(PluginShowDate, IntIf(PluginShowDate < 2, PluginShowDate + 1, 0), False);
      KEY_CTRL4:
        ToggleOptionInt(PluginShowUseDate, IntIf(PluginShowUseDate < 2, PluginShowUseDate + 1, 0), False);
      KEY_CTRL5:
        ToggleOption(PluginShowFlags, False);
     {$ifdef Far3}
      KEY_CTRL6:
        ToggleOption(PluginShowAuthor, False);
      KEY_CTRL7:
        ToggleOption(PluginShowVer, False);
     {$endif Far3}

      KEY_CTRLF1..KEY_CTRLF7, KEY_CTRLSHIFTF1..KEY_CTRLSHIFTF7:
        begin
          if AKey and KEY_SHIFT = 0 then
            vIndex := AKey - KEY_CTRLF1 + 1
          else
            vIndex := AKey - KEY_CTRLSHIFTF1 + 1;
          if vIndex in cDescSort then
            vIndex := - vIndex;
          SetOrder(vIndex);
        end;

      KEY_SHIFTF11:
        ToggleOption(SortHiddenLast, False);
      KEY_CTRLF11:
        SetOrder(0);
      KEY_ALTF12:
        begin
          vIndex := FGrid.Column[FGrid.CurCol].Tag;
          if vIndex in cDescSort then
            vIndex := - vIndex;
          SetOrder(vIndex);
        end;
      KEY_CTRLF12:
        SortByDlg;

      KEY_ALT, KEY_RALT:
        begin
          FFilterMode := not FFilterMode;
          if FFilterMode then
            FFilterColumn := FGrid.Column[FGrid.CurCol].Tag
          else
            FFilterMask := '';
          ReinitAndSaveCurrent;
        end;
//    KEY_DEL:
//      SetFilter('');
      KEY_BS:
        if FFilterMask <> '' then
          SetFilter( Copy(FFilterMask, 1, Length(FFilterMask) - 1));
    else
      begin
//      TraceF('Key: %d', [Param2]);

        vChr := #0;
        vKey := AKey and not KEY_ALT;

        case vKey of
          KEY_ADD      : vChr := '+';
          KEY_SUBTRACT : vChr := '-';
          KEY_DIVIDE   : vChr := '/';
          KEY_MULTIPLY : vChr := '*';
        else
          if (vKey >= 32) and (vKey < $FFFF) then begin
            vChr := TChar(vKey);
          end;
        end;

        if vChr <> #0 then begin
          if (KEY_ALT and AKey <> 0) or FFilterMode then
            SetFilter(FFilterMask + CharLoCase(vChr))
          else begin
            vIndex := FindShortcut(vChr);
            if vIndex <> -1 then begin
              SetCurrent(vIndex, False);
              FChoosenCmd := CurrentCommand;
              if (FChoosenCmd <> nil) and CheckWinType(FWindowType, FChoosenCmd.Plugin) then begin
                FChoosenCommand := 1;
                SendMsg(DM_CLOSE, -1, 0);
              end else
                Beep;
            end else
              Beep;
          end;
          Exit;
        end;

        Result := inherited KeyDown(AID, AKey)
      end;
    end;
  end;


  function TMenuDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_RESIZECONSOLE: begin
(*
        ResizeDialog;
        UpdateFooter; { Чтобы центрировался status-line }
        SetCurrent(FGrid.CurRow, False);
*)
        ReinitAndSaveCurrent
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TMenuDlg.RunCurrentCommand :Boolean;
 {$ifdef Far3}
  var
    vStr :TString;
  begin
    FChoosenCmd.MarkAccessed;

   {$ifdef bLUA}
//  vStr := Format('Keys("F11"); if Menu.Select("%s", 2) then Keys("Enter") else Keys("Esc") end', [FChoosenCmd.Name]);
    vStr := Format('Plugin.Menu("%s", "%s")', [StrDeleteChars(GUIDToString(FChoosenCmd.Plugin.GUID), ['{', '}']), StrDeleteChars(GUIDToString(FChoosenCmd.GUID), ['{', '}'])]);
   {$else}
    vStr := Format('F11 $if(Menu.Select("%s", 2) > 0) Enter $else Esc $end',  [FChoosenCmd.Name]);
   {$endif bLUA}

    FarPostMacro(vStr);
    Result := True;

 {$else}

  var
    vStr, vName :TString;
  begin
    FChoosenCmd.MarkAccessed;

    vName := FChoosenCmd.Name;
    if FChoosenCmd.Hotkey <> #0 then
      vName := TString(FChoosenCmd.Hotkey) + '  ' + vName
    else
    if FChoosenCmd.PerfHotkey <> #0 then
      vName := StrDeleteChars(vName, ['&']);

//  vStr := Format('F11 $if(Menu.Select("%s") > 0) $MMode 1 Enter $else Esc $end', [vName]);
    vStr := Format('F11 $if(Menu.Select("%s") > 0) Enter $else Esc $end',  [vName]);

    FarPostMacro(vStr);
    Result := True;
 {$endif Far3}
  end;


  function TMenuDlg.OpenConfig(ATryLoad :Boolean) :Boolean;
  var
    vPlugin :TFarPlugin;
  begin
    vPlugin := FChoosenCmd.Plugin;

    Result := vPlugin.PluginSetup;

    if Result then begin
      AssignAutoHotkeys(FWindowType);
      { В результате вызова диалога настройки список команд обновляется }
      FChoosenCmd := vPlugin.Command[0]
    end else
      Result := True;
  end;


  function TMenuDlg.GotoPluginFolder :Boolean;
  var
    vPath :TString;
  begin
    vPath := RemoveBackSlash(ExtractFilePath(FChoosenCmd.Plugin.FileName));
//  FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETPANELDIR, 0, PChar(vPath));
    FarPanelSetDir(PANEL_ACTIVE, vPath);
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    vMenuLock :Integer;


  procedure OpenMenu(AWinType :Integer; const AInitFilter :TString = '');
  var
    vDlg :TMenuDlg;
    vFinish :Boolean;
    vPlugin :TFarPlugin;
  begin
    if vMenuLock > 0 then
      Exit;

    if AInitFilter <> '' then begin
      LastFilter := AInitFilter;
      LastColumn := 1;
    end;

    Inc(vMenuLock);
    vDlg := TMenuDlg.Create;
    try
      UpdatePluginList;
      AssignAutoHotkeys(AWinType);

      vDlg.FWindowType := AWinType;
      if LastPlugin <> '' then begin
        vPlugin := FindPlugin(LastPlugin);
        if vPlugin <> nil then
          vDlg.FChoosenCmd := vPlugin.Command[0];
      end;

      if LastFilter <> '' then begin
        vDlg.FFilterMask   := LastFilter;
        vDlg.FFilterColumn := LastColumn;
        vDlg.FFilterMode   := True;
        LastFilter := '';
      end;

      vFinish := False;
      while not vFinish do begin
        vDlg.FChoosenCommand := 0;
        if (vDlg.Run = -1) or (vDlg.FChoosenCmd = nil) then
          Exit;

        LastPlugin := vDlg.FChoosenCmd.Plugin.FileName;

        case vDlg.FChoosenCommand of
          1: vFinish := vDlg.RunCurrentCommand;
          2: vDlg.FChoosenCmd.Plugin.PluginHelp;
          3: vFinish := not vDlg.OpenConfig(True);
          4: vFinish := not vDlg.OpenConfig(False {Без попытки загрузки плагина} );
          5: vFinish := vDlg.GotoPluginFolder;
        end;
      end;

    finally
      FreeObj(vDlg);
      Dec(vMenuLock);
    end;
  end;


end.


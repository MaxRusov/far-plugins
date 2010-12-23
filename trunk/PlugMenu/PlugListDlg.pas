{$I Defines.inc}

unit PlugListDlg;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* PlugMenu Far plugin                                                        *}
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

    PlugMenuCtrl,
    PlugMenuPlugs,
    PlugEditDlg,
    PlugInfoDlg,
    PlugLoadDlg;


  var
    PluginAutoShortcut :Boolean = True;

    PluginShowLoaded   :Boolean = True;
   {$ifdef bUnicode}
    PluginShowAnsi     :Boolean = True;
   {$endif bUnicode}
    PluginShowFileName :Integer = 0;
    PluginShowFlags    :Boolean = False;
    PluginShowDate     :Integer = 0;
    PluginShowUseDate  :Integer = 0;

    PluginShowHidden   :Integer = 0;

    PluginSortMode     :Integer = 0;
    PluginSortGroup    :Boolean = False;

    optShowHints       :Boolean = True;
    optFollowMouse     :Boolean = True;
    optWrapMode        :Boolean = True;

    optHiddenColor     :Integer = 0;
    optFoundColor      :Integer = $0A;
//  optSelectedColor   :Integer = $20;


  var
    LastPlugin         :TString;
    LastFilter         :TString;
    LastColumn         :Integer;

  const
   {$ifdef bUnicode}
    chrHiddenMark       :TChar = #$2022;
    chrUnaccessibleMark :TChar = #9632 { $25AC };
    chrUpMark           :TChar = #$18; { $1E }
    chrDnMark           :TChar = #$19; { $1F }
   {$else}
    chrHiddenMark       :TChar = #$07;
    chrUnaccessibleMark :TChar = #$16;
    chrUpMark           :TChar = #$18; { $1E }
    chrDnMark           :TChar = #$19; { $1F }
   {$endif bUnicode}

    chrLoadedMark       :TChar = '*';
    chrUnregisteredMark :TChar = 'x';


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
    TMenuDlg = class(TFarDialog)
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
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FGrid           :TFarGrid;

      FHotkeyColor1   :Integer;
      FHotkeyColor2   :Integer;
      FHiddenColor    :Integer;
      FFoundColor     :Integer;

      FWindowType     :Integer;
      FFilter         :TMyFilter;
      FFilterMode     :Boolean;
      FFilterMask     :TString;
      FFilterColumn   :Integer;
      FTotalCount     :Integer;
      FMenuMaxWidth   :Integer;

      FChoosenCmd     :TFarPluginCmd;
      FChoosenCommand :Integer;

      procedure GridCellClick(ASender :TFarGrid; ACol, ARow :Integer; AButton :Integer; ADouble :Boolean);
      procedure GridPosChange(ASender :TFarGrid);
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString;
      procedure GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
      procedure GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);

      procedure ResizeDialog;
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
      procedure PlugInfoDlg;

      procedure SelectItem(ACode :Integer);
      procedure ToggleOption(var AOption :Boolean; ASaveCurrent :Boolean);
      procedure ToggleOptionInt(var AOption :Integer; ANewValue :Integer; ASaveCurrent :Boolean);
     {$ifdef bUnicode}
      procedure PromptAndLoadPlugin;
     {$endif bUnicode}

      function DlgItemsCount :Integer;
      function CurrentDlgIndex :Integer;
      function CurrentCommandIndex :Integer;
      function CurrentCommand :TFarPluginCmd;
      function CurrentPlugin :TFarPlugin;

    public
      property Grid :TFarGrid read FGrid;
    end;


  procedure OpenMenu(AWinType :Integer; const AInitFilter :TString = '');

  procedure ReadSetup;
  procedure WriteSetup;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    PlugMenuHints,
    MixDebug;


 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      PluginAutoShortcut := RegQueryLog(vKey, 'AutoHotkey',  PluginAutoShortcut);
      PluginShowHidden   := RegQueryInt(vKey, 'ShowHidden',  PluginShowHidden);
      optShowHints       := RegQueryLog(vKey, 'ShowHints',   optShowHints);
      optFollowMouse     := RegQueryLog(vKey, 'FollowMouse', optFollowMouse);
      optWrapMode        := RegQueryLog(vKey, 'WrapMode',    optWrapMode);

      PluginShowLoaded   := RegQueryLog(vKey, 'ShowLoadedMark', PluginShowLoaded);
     {$ifdef bUnicode}
      PluginShowAnsi     := RegQueryLog(vKey, 'ShowAnsiMark', PluginShowAnsi);
     {$endif bUnicode}

      PluginShowFileName := RegQueryInt(vKey, 'ShowFileName', PluginShowFileName);
      PluginShowFlags    := RegQueryLog(vKey, 'ShowFlags', PluginShowFlags);
      PluginShowDate     := RegQueryInt(vKey, 'ShowModifyTime', PluginShowDate);
      PluginShowUseDate  := RegQueryInt(vKey, 'ShowAccessTime', PluginShowUseDate);

      PluginSortMode     := RegQueryInt(vKey, 'SortMode', PluginSortMode);

      optHiddenColor     := RegQueryInt(vKey, 'HiddenColor', optHiddenColor);
      optFoundColor      := RegQueryInt(vKey, 'FoundColor', optFoundColor);
//    optSelectedColor   := RegQueryInt(vKey, 'SelectedColor', optSelectedColor);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'AutoHotkey',  PluginAutoShortcut);
      RegWriteInt(vKey, 'ShowHidden',  PluginShowHidden);
      RegWriteLog(vKey, 'ShowHints',   optShowHints);
      RegWriteLog(vKey, 'FollowMouse', optFollowMouse);
      RegWriteLog(vKey, 'WrapMode',    optWrapMode);

      RegWriteLog(vKey, 'ShowLoadedMark', PluginShowLoaded);
     {$ifdef bUnicode}
      RegWriteLog(vKey, 'ShowAnsiMark', PluginShowAnsi);
     {$endif bUnicode}

      RegWriteInt(vKey, 'ShowFileName', PluginShowFileName);
      RegWriteLog(vKey, 'ShowFlags', PluginShowFlags);
      RegWriteInt(vKey, 'ShowModifyTime', PluginShowDate);
      RegWriteInt(vKey, 'ShowAccessTime', PluginShowUseDate);

      RegWriteInt(vKey, 'SortMode', PluginSortMode);

    finally
      RegCloseKey(vKey);
    end;
  end;


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


  function TMyFilter.ItemCompare(PItem, PAnother :Pointer; Context :TIntPtr) :Integer; {override;}
  var
    vCmd1, vCmd2 :TFarPluginCmd;
  begin
    Result := 0;

    vCmd1 := GetPluginComman(PInteger(PItem)^);
    vCmd2 := GetPluginComman(PInteger(PAnother)^);

    case Abs(Context) of
      0 :
        begin
//        if PluginSortGroup then
//          Result := IntCompare(Byte(vPlugin1.GetCategory), Byte(vPlugin2.GetCategory));
          Result := -LogCompare(vCmd1.Plugin.AccessibleInContext(FWindowType), vCmd2.Plugin.AccessibleInContext(FWindowType));
        end;
      1 : Result := UpCompareStr(vCmd1.GetMenuTitle, vCmd2.GetMenuTitle);
      2 : Result := UpCompareStr(vCmd1.Plugin.GetFileName(PluginShowFileName), vCmd2.Plugin.GetFileName(PluginShowFileName));
      3 : Result := DateTimeCompare(vCmd1.Plugin.FileDate, vCmd2.Plugin.FileDate);
      4 : Result := DateTimeCompare(vCmd1.AccessDate, vCmd2.AccessDate);
      5 : Result := UpCompareStr(vCmd1.Plugin.GetFlagsStr, vCmd2.Plugin.GetFlagsStr);
    end;

    if Context < 0 then
      Result := -Result;
    if Result = 0 then
      Result := IntCompare(PInteger(PItem)^, PInteger(PAnother)^);
  end;


 {-----------------------------------------------------------------------------}
 { TMenuDlg                                                                    }
 {-----------------------------------------------------------------------------}

  const
    cDlgMinWidth  = 40;
    cDlgMinHeight = 5;

    IdFrame  = 0;
    IdList   = 1;
    IdStatus = 2;


  constructor TMenuDlg.Create; {override;}
  begin
    inherited Create;
    RegisterHints(Self);
    FFilter := TMyFilter.CreateSize(SizeOf(TFilterRec));

    FHotkeyColor1 := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUHIGHLIGHT));
    FHotkeyColor2 := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUSELECTEDHIGHLIGHT));

    FHiddenColor := optHiddenColor;
    if FHiddenColor = 0 then
      FHiddenColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUDISABLEDTEXT));

    FFoundColor := optFoundColor;
    if FFoundColor = 0 then
      FFoundColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUHIGHLIGHT));

  end;


  destructor TMenuDlg.Destroy; {override;}
  begin
    FreeObj(FGrid);
    FreeObj(FFilter);
    UnregisterHints;
    inherited Destroy;
  end;


  procedure TMenuDlg.Prepare; {override;}
  const
    DX = 20;
    DY = 10;
  begin
    FHelpTopic := 'PluginCommands';
    FWidth := DX;
    FHeight := DY;
    FItemCount := 3;

    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox,   2, 1, DX - 4, DY - 2, 0, ''),
        NewItemApi(DI_USERCONTROL, 3, 2, DX - 6, DY - 4, 0, '' ),
        NewItemApi(DI_Text,        3, 3, DX - 6, 1, DIF_CENTERTEXT, '...')
      ]
    );

    FGrid := TFarGrid.CreateEx(Self, IdList);
    FGrid.OnCellClick := GridCellClick;
    FGrid.OnPosChange := GridPosChange;
    FGrid.OnGetCellText := GridGetDlgText;
    FGrid.OnGetCellColor := GridGetCellColor;
    FGrid.OnPaintCell := GridPaintCell;
    FGrid.Options := [goRowSelect, goFollowMouse, goWrapMode {,goWheelMovePos} ];
  end;


  procedure TMenuDlg.InitDialog; {override;}
  var
    vIndex :Integer;
  begin
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


  procedure TMenuDlg.ResizeDialog;
  var
    vWidth, vHeight :Integer;
    vRect :TSmallRect;
    vSize :TSize;
  begin
    vSize := FarGetWindowSize;

    vWidth := FMenuMaxWidth + 6;
    if vWidth > vSize.CX - 4 then
      vWidth := vSize.CX - 4;
    vWidth := IntMax(vWidth, cDlgMinWidth);

    vHeight := FGrid.RowCount + 4;
    if vHeight > vSize.CY - 2 then
      vHeight := vSize.CY - 2;
    vHeight := IntMax(vHeight, cDlgMinHeight);

    vRect := SBounds(2, 1, vWidth - 5, vHeight - 3);
    SendMsg(DM_SETITEMPOSITION, IdFrame, @vRect);

    SRectGrow(vRect, -1, -1);
    if vRect.Bottom - vRect.Top + 2 <= FGrid.RowCount then
      Inc(vRect.Right);
    SendMsg(DM_SETITEMPOSITION, IdList, @vRect);
    FGrid.UpdateSize(vRect.Left, vRect.Top, vRect.Right - vRect.Left + 1, vRect.Bottom - vRect.Top + 1);

    SendMsg(DM_GETITEMPOSITION, IdStatus, @vRect);
    vRect.Top := vHeight - 2; vRect.Bottom := vRect.Top;
    SendMsg(DM_SETITEMPOSITION, IdStatus, @vRect);

    SetDlgPos(-1, -1, vWidth, vHeight);
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
      SelectItem(1);
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
          1 : Result := GetMenuTitle;
          2 : Result := Plugin.GetFileName(PluginShowFileName);
          3 : Result := Date2StrMode(Plugin.FileDate, PluginShowDate);
          4 : Result := Date2StrMode(AccessDate, PluginShowUseDate);
          5 : Result := Plugin.GetFlagsStr;
        end;
    end else
      Result := '';
  end;


  procedure TMenuDlg.GridGetCellColor(ASender :TFarGrid; ACol, ARow :Integer; var AColor :Integer);
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
            AColor := (AColor and not $0F) or (FHiddenColor and $0F);
        end;
      end;
    end;
  end;


  procedure TMenuDlg.GridPaintCell(ASender :TFarGrid; X, Y, AWidth :Integer; ACol, ARow :Integer; AColor :Integer);
  var
    vRec :PFilterRec;
    vStr :TString;
    vPos, X1 :Integer;
    vSelected :Boolean;
    vMark :array[0..1] of TChar;
  begin
    if ARow < FFilter.Count then begin
      vRec := FFilter.PItems[ARow];
      with GetCommand(ARow) do begin
        vSelected := (FGrid.CurRow = ARow) and ((FGrid.CurCol = ACol) or (FGrid.CurCol = 0));

        if ACol = 0 then begin
          if True then begin
            { Назначенный Hotkey }
            if Hotkey <> #0 then
              FGrid.DrawChr(X, Y, @Hotkey, 1, IntIf(vSelected, FHotkeyColor2, FHotkeyColor1));
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

         {$ifdef bUnicode}
          if PluginShowAnsi then begin
            if not Plugin.Unicode then begin
              { Метка ansi-шного плагина }
              vMark[0] := 'A';
              FGrid.DrawChr(X1, Y, @vMark[0], 1, AColor);
            end;
//          Dec(X1);
          end;
         {$endif bUnicode}
        end;

        if AWidth > 0 then begin

          vStr := GridGetDlgText(ASender, ACol, ARow);

          if (vRec.FLen > 0) and (FGrid.Column[ACol].Tag = FFilterColumn) then
            { Выделение части строки, совпадающей с фильтром... }
            FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vRec.FPos, vRec.FLen, AColor, (AColor and not $0F) or (FFoundColor and $0F))
          else begin
            vPos := -1;
            if (ACol = 0) and PluginAutoShortcut and not FFilterMode and (AutoHotkey <> #0) then
              vPos := ChrPos(AutoHotkey, vStr);

            if vPos > 0 then
              FGrid.DrawChrEx(X, Y, PTChar(vStr), AWidth, vPos - 1, 1, AColor, IntIf(vSelected, FHotkeyColor2, FHotkeyColor1))
            else
              FGrid.DrawChr(X, Y, PTChar(vStr), AWidth, AColor);
          end;

        end;
      end;
    end;
  end;


  procedure TMenuDlg.ReinitGrid;
  var
    I, J, K, vLen, vPos, vMaxLen1, vMaxLen2 :Integer;
    vTitle, vDllName, vMask, vStr :TString;
    vPlugin :TFarPlugin;
    vCommand :TFarPluginCmd;
    vHasMask :Boolean;
  begin
//  Trace('ReinitGrid...');
    FFilter.Clear;
    vMaxLen1 := 0;
    vMaxLen2 := 0;
    FTotalCount := 0;

    vHasMask := False;
    vMask := FFilterMask;
    if vMask <> '' then begin
      if (FFilterColumn = 5) and (vMask[1] <> '*') then
        vMask := '*' + vMask;
      vHasMask := (ChrPos('*', vMask) <> 0) or (ChrPos('?', vMask) <> 0);
      if vHasMask and (vMask[Length(vMask)] <> '*') {and (vMask[Length(vMask)] <> '?')} then
        vMask := vMask + '*';
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
            1: vStr := vTitle;
            2: vStr := vDllName;
            3: vStr := Date2StrMode(vPlugin.FileDate, PluginShowDate);
            4: vStr := Date2StrMode(vCommand.AccessDate, PluginShowUseDate);
            5: vStr := vPlugin.GetFlagsStr;
          end;
          if not CheckMask(vMask, vStr, vHasMask, vPos, vLen) then
            Continue;
        end;

        K := (I shl 16) + J;
        FFilter.Add(K, vPos, vLen);

        vMaxLen1 := IntMax(vMaxLen1, Length(vTitle));
        if PluginShowFileName > 0 then
          vMaxLen2 := IntMax(vMaxLen2, Length(vDllName));
      end;
    end;

//  if PluginSortMode <> 0 then
      FFilter.SortList(True, PluginSortMode);

    if True then
      Inc(vMaxLen1, 2); { Hotkey }
    if PluginShowHidden > 0 then
      Inc(vMaxLen1, 1); { Hidden mark }
    if PluginShowLoaded then
      Inc(vMaxLen1, 2);
   {$ifdef bUnicode}
    if PluginShowAnsi then
      Inc(vMaxLen1, 1 + IntIf(PluginShowLoaded, 0, 1));
   {$endif bUnicode}

    FGrid.ResetSize;
    FGrid.Columns.FreeAll;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 0, taLeftJustify, [coColMargin, coOwnerDraw], 1) );
    FGrid.Column[0].MinWidth := vMaxLen1 + 2;
    if PluginShowFileName > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', vMaxLen2 + 2, taLeftJustify, [coColMargin, coOwnerDraw], 2) );
    if PluginShowDate > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Date2StrMode(Now, PluginShowDate)) + 2, taLeftJustify, [coColMargin, coOwnerDraw], 3) );
    if PluginShowUseDate > 0 then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', Length(Date2StrMode(Now, PluginShowUseDate)) + 2, taLeftJustify, [coColMargin, coOwnerDraw], 4) );
    if PluginShowFlags then
      FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 5 + 2, taLeftJustify, [coColMargin, coOwnerDraw], 5) );

    FMenuMaxWidth := vMaxLen1 + 2;
    for I := 1 to FGrid.Columns.Count - 1 do
      Inc(FMenuMaxWidth, FGrid.Column[I].Width + 1);

    FGrid.RowCount := FFilter.Count;

    if optFollowMouse then
      FGrid.Options := FGrid.Options + [goFollowMouse]
    else
      FGrid.Options := FGrid.Options - [goFollowMouse];

    if optWrapMode then
      FGrid.Options := FGrid.Options + [goWrapMode]
    else
      FGrid.Options := FGrid.Options - [goWrapMode];

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
          (PluginAutoShortcut and (vCommand.AutoHotkey <> #0) and HotkeyEqual(AChr, vCommand.AutoHotkey, ByScanCode))
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
    WriteSetup;
  end;


  procedure TMenuDlg.SortByDlg;
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
      SetMenuItemChrEx(vItem, GetMsg(StrSortByFileName));
      SetMenuItemChrEx(vItem, GetMsg(StrSortByModificationTime));
      SetMenuItemChrEx(vItem, GetMsg(StrSortByAccessTime));
      SetMenuItemChrEx(vItem, GetMsg(StrSortByPluginFlags));
      SetMenuItemChrEx(vItem, GetMsg(StrSortByUnsorted));

      vRes := Abs(PluginSortMode) - 1;
      if vRes = -1 then
        vRes := 5;
      vChr := '+';
      if PluginSortMode < 0 then
        vChr := '-';
      vItems[vRes].Flags := SetFlag(0, MIF_CHECKED or Word(vChr), True);

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(StrSortByTitle),
        '',
        '',
        nil, nil,
        Pointer(vItems),
        cSortMenuCount);

      if vRes <> -1 then begin
        Inc(vRes);
        if vRes = 6 then
          vRes := 0;
        if vRes >= 3 then
          vRes := -vRes;
        SetOrder(vRes);
      end;

    finally
      MemFree(vItems);
    end;
  end;

 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.OptionsDlg;
  const
    cMenuCount = 15;
  var
    vRes, I :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strShowHidden));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strLoadedMark));
      SetMenuItemChrEx(vItem, GetMsg(strAnsiMark));
      SetMenuItemChrEx(vItem, GetMsg(strFileName));
      SetMenuItemChrEx(vItem, GetMsg(strModificationTime));
      SetMenuItemChrEx(vItem, GetMsg(strAccessTime));
      SetMenuItemChrEx(vItem, GetMsg(strPluginFlags));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strSortBy));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strAutoHotkey));
      SetMenuItemChrEx(vItem, GetMsg(strShowHints));
      SetMenuItemChrEx(vItem, GetMsg(strFollowMouse));
      SetMenuItemChrEx(vItem, GetMsg(strWrapMode));

      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, PluginShowHidden > 0);

        vItems[2].Flags := SetFlag(0, MIF_CHECKED1, PluginShowLoaded);
       {$ifdef bUnicodeFar}
        vItems[3].Flags := SetFlag(0, MIF_CHECKED1, PluginShowAnsi);
       {$else}
        vItems[3].Flags := SetFlag(0, MIF_DISABLE, True);
       {$endif bUnicodeFar}
        vItems[4].Flags := SetFlag(0, MIF_CHECKED1, PluginShowFileName > 0);
        vItems[5].Flags := SetFlag(0, MIF_CHECKED1, PluginShowDate > 0);
        vItems[6].Flags := SetFlag(0, MIF_CHECKED1, PluginShowUseDate > 0);
        vItems[7].Flags := SetFlag(0, MIF_CHECKED1, PluginShowFlags);

        vItems[11].Flags := SetFlag(0, MIF_CHECKED1, PluginAutoShortcut);
        vItems[12].Flags := SetFlag(0, MIF_CHECKED1, optShowHints);
        vItems[13].Flags := SetFlag(0, MIF_CHECKED1, optFollowMouse);
        vItems[14].Flags := SetFlag(0, MIF_CHECKED1, optWrapMode);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strOptionsTitle),
          '',
          '',
          nil, nil,
          Pointer(vItems),
          cMenuCount);

        if vRes = -1 then
          Exit;

        case vRes of
          0 : ToggleOptionInt(PluginShowHidden, IntIf(PluginShowHidden = 0, 2, 0), True);

          2 : ToggleOption(PluginShowLoaded, False);
         {$ifdef bUnicodeFar}
          3 : ToggleOption(PluginShowAnsi, False);
         {$endif bUnicodeFar}
          4 : ToggleOptionInt(PluginShowFileName, IntIf(PluginShowFileName < 2, PluginShowFileName + 1, 0), False);
          5 : ToggleOptionInt(PluginShowDate, IntIf(PluginShowDate < 2, PluginShowDate + 1, 0), False);
          6 : ToggleOptionInt(PluginShowUseDate, IntIf(PluginShowUseDate < 2, PluginShowUseDate + 1, 0), False);
          7 : ToggleOption(PluginShowFlags, False);

          9 : SortByDlg;

          11: ToggleOption(PluginAutoShortcut, False);
          12: ToggleOption(optShowHints, False);
          13: ToggleOption(optFollowMouse, False);
          14: ToggleOption(optWrapMode, False);
        end;
      end;

    finally
      MemFree(vItems);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMenuDlg.PlugInfoDlg;
  var
    vPlugin :TFarPlugin;
  begin
    vPlugin := CurrentPlugin;
    if vPlugin = nil then
      Exit;

    vPlugin.UpdateVerInfo;
    ViewPluginInfo(vPlugin);
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
    WriteSetup;
  end;


  procedure TMenuDlg.ToggleOptionInt(var AOption :Integer; ANewValue :Integer; ASaveCurrent :Boolean);
  begin
    AOption := ANewValue;
    if ASaveCurrent then
      ReinitAndSaveCurrent
    else
      ReinitGrid;
    WriteSetup;
  end;


 {$ifdef bUnicode}
  procedure TMenuDlg.PromptAndLoadPlugin;
  var
    vFileName :TString;
    vPlugin :TFarPlugin;
    vIndex :Integer;
  begin
    if LoadPluginDlg(vFileName) then begin
      vPlugin := LoadNewPlugin(vFileName);
      ReinitGrid;
      vIndex := FindCommand( vPlugin.Command[0] );
      SetCurrent( vIndex, False );
    end;
  end;
 {$endif bUnicode}


  function TMenuDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

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


   {$ifdef bUnicode}
    procedure LocLoadPlugin;
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


    procedure LocUnloadPlugin;
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
   {$endif bUnicode}

  var
    vChr :TChar;
    vKey, vIndex :Integer;
  begin
//  TraceF('InfoDialogProc: FHandle=%d, Msg=%d, Param1=%d, Param2=%d', [FHandle, Msg, Param1, Param2]);
    Result := 1;
    case Msg of
      DN_CTLCOLORDIALOG:
        Result := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));
      DN_CTLCOLORDLGITEM:
        if (Param1 = IdFrame) or (Param1 = IDStatus) then
          Result := CtrlPalette([COL_MENUTITLE, COL_MENUHIGHLIGHT, COL_MENUBOX])
        else
          Result := Param2;

      DN_RESIZECONSOLE: begin
        ResizeDialog;
        UpdateFooter; { Чтобы центрировался status-line }
        SetCurrent(FGrid.CurRow, False);
      end;

      DN_KEY: begin
//      TraceF('Key = %d', [Param2]);
        case Param2 of
          KEY_ENTER, KEY_SHIFTENTER:
            SelectItem(1);
          KEY_SHIFTF1:
            begin
              FChoosenCmd := CurrentCommand;
              if FChoosenCmd <> nil then begin
                FChoosenCommand := 2;
                SendMsg(DM_CLOSE, -1, 0);
              end else
                Beep;
            end;
          KEY_F2:
            OptionsDlg;
          KEY_F3:
            PlugInfoDlg;
          KEY_F4:
            begin
              FChoosenCmd := CurrentCommand;
              if FChoosenCmd <> nil then
                if EditPlugin(FChoosenCmd) then begin
                  AssignAutoHotkeys(FWindowType);
                  ReinitGrid;
                end;
            end;
          KEY_F9, KEY_SHIFTF9:
            begin
              FChoosenCmd := CurrentCommand;
              if (FChoosenCmd <> nil) and (FChoosenCmd.Plugin.ConfigString <> '') then begin
                FChoosenCommand := IntIf(Param2 = KEY_F9, 3, 4);
                SendMsg(DM_CLOSE, -1, 0);
              end else
                Beep;
            end;

         {$ifdef bUnicode}
          KEY_CTRLL:
            PromptAndLoadPlugin;
          KEY_INS:
            LocLoadPlugin;
          KEY_DEL:
            LocUnloadPlugin;
         {$endif bUnicode}

          KEY_CTRLPGDN:
            begin
              FChoosenCmd := CurrentCommand;
              if (FChoosenCmd <> nil) and (FWindowType = WTYPE_PANELS) then begin
                FChoosenCommand := 5;
                SendMsg(DM_CLOSE, -1, 0);
              end else
                Beep;
            end;

          KEY_CTRLH, KEY_CTRLSHIFTH:
            begin
              if PluginShowHidden <> 0 then
                PluginShowHidden := 0
              else
              if Param2 = KEY_CTRLH then
                PluginShowHidden := 2
              else
                PluginShowHidden := 1;
              ReinitAndSaveCurrent;
              WriteSetup;
            end;

          KEY_CTRLG:
            ToggleOption(PluginSortGroup, True);
          KEY_CTRLA:
            ToggleOption(PluginAutoShortcut, False);

          KEY_CTRL1:
            ToggleOption(PluginShowLoaded, False);
         {$ifdef bUnicode}
          KEY_CTRLSHIFT1:
            ToggleOption(PluginShowAnsi, False);
         {$endif bUnicode}
          KEY_CTRL2:
            ToggleOptionInt(PluginShowFileName, IntIf(PluginShowFileName < 2, PluginShowFileName + 1, 0), False);
          KEY_CTRL3:
            ToggleOptionInt(PluginShowDate, IntIf(PluginShowDate < 2, PluginShowDate + 1, 0), False);
          KEY_CTRL4:
            ToggleOptionInt(PluginShowUseDate, IntIf(PluginShowUseDate < 2, PluginShowUseDate + 1, 0), False);
          KEY_CTRL5:
            ToggleOption(PluginShowFlags, False);

          KEY_CTRLF10:
            SetOrder(0);
          KEY_CTRLF1, KEY_CTRLSHIFTF1:
            SetOrder(1);
          KEY_CTRLF2, KEY_CTRLSHIFTF2:
            SetOrder(2);
          KEY_CTRLF3, KEY_CTRLSHIFTF3:
            SetOrder(-3);
          KEY_CTRLF4, KEY_CTRLSHIFTF4:
            SetOrder(-4);
          KEY_CTRLSHIFTF5:
            SetOrder(-5);
          KEY_CTRLF11:
            SetOrder(0);
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
//        KEY_DEL:
//          SetFilter('');
          KEY_BS:
            if FFilterMask <> '' then
              SetFilter( Copy(FFilterMask, 1, Length(FFilterMask) - 1));

        else
//        TraceF('Key: %d', [Param2]);

          vChr := #0;
          vKey := Param2 and not KEY_ALT;

          case vKey of
            KEY_ADD      : vChr := '+';
            KEY_SUBTRACT : vChr := '-';
            KEY_DIVIDE   : vChr := '/';
            KEY_MULTIPLY : vChr := '*';
          else
           {$ifdef bUnicodeFar}
            if (vKey >= 32) and (vKey < $FFFF) then
           {$else}
            if (vKey >= 32) and (vKey <= $FF) then
           {$endif bUnicodeFar}
            begin
              vChr := TChar(vKey);
             {$ifdef bUnicodeFar}
             {$else}
              ChrOemToAnsi(vChr, 1);
             {$endif bUnicodeFar}
            end;
          end;

          if vChr <> #0 then begin
            if (KEY_ALT and Param2 <> 0) or FFilterMode then
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

          Result := inherited DialogHandler(Msg, Param1, Param2);
        end;
      end;

    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TMenuDlg.RunCurrentCommand :Boolean;
  var
    vMacro :TActlKeyMacro;
    vStr, vName :TString;
  begin
    FChoosenCmd.MarkAccessed;

    vName := FChoosenCmd.Name;
    if FChoosenCmd.Hotkey <> #0 then
      vName := TString(FChoosenCmd.Hotkey) + '  ' + vName
    else
    if FChoosenCmd.PerfHotkey <> #0 then
      vName := StrDeleteChars(vName, ['&']);

//  vStr := Format('F11 $if(Menu.Select("%s") > 0) $MMode 1 Enter $else Esc $end',
//    [StrWin2Dos(vName)]);
    vStr := Format('F11 $if(Menu.Select("%s") > 0) Enter $else Esc $end',
      [StrAnsiToOem(vName)]);

    vMacro.Command := MCMD_POSTMACROSTRING;
    vMacro.Param.PlainText.SequenceText := PTChar(vStr);
    vMacro.Param.PlainText.Flags := KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;

    FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
    Result := True;
  end;


  function TMenuDlg.OpenConfig(ATryLoad :Boolean) :Boolean;
  var
    vPlugin :TFarPlugin;
   {$ifdef bUnicode}
   {$else}
    vStr :TString;
    vMacro :TActlKeyMacro;
   {$endif bUnicode}
  begin
    vPlugin := FChoosenCmd.Plugin;

    Result := vPlugin.PluginSetup;

    if Result then begin
      AssignAutoHotkeys(FWindowType);
      { В результате вызова диалога настройки список команд обновляется }
      FChoosenCmd := vPlugin.Command[0]
    end else
    begin
     {$ifdef bUnicode}
      Result := True;
     {$else}
      if ATryLoad then begin
        { Попытка принудително загрузить плагин путем открытия и закрытия стандартного диалога настроек }

        if FWindowType = WTYPE_PANELS then begin
          vStr := Format(
            'F9 End Left Down Down Down Down Down Enter $if(Menu.Select("%s",2) > 0) Enter Esc $end Esc ' +
            'F11 $if(Menu.Select("%s",2) > 0) Enter ShiftF9 $end',
            [StrAnsiToOem(vPlugin.ConfigString), GetMsg(strTitle)]);

          vMacro.Command := MCMD_POSTMACROSTRING;
          vMacro.Param.PlainText.SequenceText := PTChar(vStr);
          vMacro.Param.PlainText.Flags := KSFLAGS_DISABLEOUTPUT or KSFLAGS_NOSENDKEYSTOPLUGINS;

          FARAPI.AdvControl(hModule, ACTL_KEYMACRO, @vMacro);
          LastFilter := FFilterMask;
          LastColumn := FFilterColumn;
        end else
          Beep {ShowMessage(GetMsgStr(strTitle), 'Данная функция пока не реализована', FMSG_WARNING or FMSG_MB_OK)};

      end else
      begin
        Result := True;
        Exit;
      end;
     {$endif bUnicode}
    end;
  end;


  function TMenuDlg.GotoPluginFolder :Boolean;
  var
    vPath :TString;
  begin
    vPath := RemoveBackSlash(ExtractFilePath(FChoosenCmd.Plugin.FileName));
   {$ifdef bUnicode}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETPANELDIR, 0, PChar(vPath));
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETPANELDIR, PChar(vPath));
   {$endif bUnicode}
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
      UpdateLoadedPlugins;
      UpdatePluginHotkeys;
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


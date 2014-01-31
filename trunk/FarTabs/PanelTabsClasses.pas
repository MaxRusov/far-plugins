{******************************************************************************}
{* (c) 2009-2013 Max Rusov                                                    *}
{*                                                                            *}
{* PanelTabs Far plugin                                                       *}
{******************************************************************************}

{$I Defines.inc}

unit PanelTabsClasses;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,

    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarConfig,
    FarCtrl,
    FarMenu,
    FarConMan,

    PanelTabsCtrl;

  const
    cMinTabWidth = 3;

    cSide1 = #$2590;
    cSide2 = #$258C;


  type
    THotSpot = (
      hsNone,
      hsTab,
      hsButtom,
      hsPanel
    );

    TTabKind = (
      tkLeft,
      tkRight,
      tkCommon
    );

    TClickType = (
      mcNone,
      mcLeft,
      mcDblLeft,
      mcRight,
      mcDblRight,
      mcMiddle,
      mcDblMiddle
    );

    TKeyShift = (
      ksShift,
      ksControl,
      ksAlt
    );
    TKeyShifts = set of TKeyShift;

    TTabAction = (
      taNone,

      taSelect,
      taPSelect,
      taEdit,
      taDelete,
      taFixUnfix,

      taAdd,
      taAddFixed,
      taPAdd,
      taPAddFixed,

      taList,
      taMainMenu
    );

    TClickAction = class(TBasis)
    public
      constructor CreateEx(AHotSpot :THotSpot; AClickType :TClickType; AShifts :TKeyShifts; AAction :TTabAction);

      function ShiftAndClickAsStr :TString;

    public
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

    private
      FHotSpot   :THotSpot;
      FClickType :TClickType;
      FShifts    :TKeyShifts;
      FAction    :TTabAction;

    public
      property HotSpot :THotSpot read FHotSpot write FHotSpot;
      property ClickType :TClickType read FClickType write FClickType;
      property Shifts :TKeyShifts read FShifts write FShifts;
      property Action :TTabAction read FAction write FAction;
    end;


    TClickActions = class(TObjList)
    public
      procedure StoreReg;
      procedure RestoreReg;
    end;


    TPanelTab = class(TBasis)
    public
      constructor CreateEx(const ACaption, AFolder :TString);
      destructor Destroy; override;

      procedure FormatCaption(AHotkey :TChar);
      function GetTabCaption :TString;
      function IsFixed :Boolean;
      procedure Fix(AValue :Boolean);

    private
      FCaption  :TString;
      FFolder   :TString;
      FDelta    :Integer;
      FWidth    :Integer;
      FHotkey   :TChar;
      FHotPos   :Integer;

      FCurrent  :TString;     { Текущий Item на данном Tab'е }
      FSelected :TStringList; { Список выделенных элементов }

      FFmtCaption :TString;

    public
      property Caption :TString read FCaption write FCaption;
      property Folder :TString read FFolder write FFolder;
      property FmtCaption :TString read FFmtCaption;
    end;


    TPanelTabs = class(TObjList)
    public
      constructor CreateEx(const AName :TString);

      function FindTab(const AName :TString; AFixedOnly, AByFolder :Boolean) :Integer;
      function FindTabByKey(AKey :TChar) :Integer;
      procedure UpdateHotkeys;
      procedure RealignTabs(ANewWidth :Integer);
      procedure StoreReg(const APath :TString; AOnlyCurrent :Boolean = False);
      procedure RestoreReg(const APath :TString);
      procedure StoreFile(const AFileName :TString);
      procedure RestoreFile(const AFileName :TString);

    private
      FName     :TString;    { Имя набора = имя ветки реестра}
      FCurrent  :Integer;    { Текущий Tab (для нефиксированных табов) }
      FAllWidth :Integer;    { Ширина панели табов при последнем вызове RealignTabs }
    end;


    TTabsManager = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function HitTest(X, Y :Integer; var APanelKind :TTabKind; var AIndex :Integer) :THotSpot;
      function FindActions(AHotSpot :THotSpot; AClickType :TClickType; AShifts :TKeyShifts) :TClickAction;

      function NeedCheck(var X, Y :Integer) :Boolean;
      function CanPaintTabs(ACheckCursor :Boolean = False) :Boolean;
      procedure NeedRealign;
      procedure PaintTabs(ACheckCursor :Boolean = False);
//    procedure RefreshTabs;

      procedure ClickAction(Action :TTabAction; AKind :TTabKind; AIndex :Integer);
      procedure AddTab(Active :Boolean);
      procedure DeleteTab(Active :Boolean);
      procedure ListTab(Active :Boolean);
      procedure FixUnfixTab(Active :Boolean);
      procedure SelectTab(Active :Boolean; AIndex :Integer);
      procedure SelectTabByKey(Active, AOnPassive :Boolean; AChar :TChar);

      procedure ToggleOption(var AOption :Boolean);
      procedure RunCommand(const ACmd :TString);

     {$ifdef bUseProcessConsoleInput}
      function TrackMouseStart(AButton, X, Y :Integer; ADouble :Boolean; AShifts :DWORD) :Boolean;
      function TrackMouseContinue(X, Y :Integer) :Boolean;
      function TrackMouseEnd(X, Y :Integer) :Boolean;
     {$else}
      procedure MouseClick;
     {$endif bUseProcessConsoleInput}

      procedure StoreTabs;
      procedure RestoreTabs;

    private
      FRects :array[TTabKind] of TRect;
      FTabs  :array[TTabKind] of TPanelTabs;

      FPressedKind  :TTabKind;
      FPressedIndex :Integer;

     {$ifdef bUseProcessConsoleInput}
      FTrackClick    :TClickType;
      FTrackShifts   :TKeyShifts;
      FTrackKind     :TTabKind;
      FTrackIndex    :Integer;
      FTrackWhat     :THotSpot;
      FTrackPressed  :Boolean;
      FTracked       :Boolean;
     {$else}
      FLastClickTime :DWORD;        { Для отслеживания DblClick }
      FLastClickPos  :TPoint;
      FLastClickType :TClickType;
     {$endif bUseProcessConsoleInput}

      FActions :TClickActions;

     {$ifdef bUseInjecting}
      FDrawLock     :Integer;
     {$endif bUseInjecting}

      function KindOfTab(Active :Boolean) :TTabKind;
      function GetTabs(Active :Boolean) :TPanelTabs;
      procedure RememberTabState(Active :Boolean; AKind :TTabKind);
      procedure RestoreTabState(Active :Boolean; ATab :TPanelTab);
      procedure DoSelectTab(Active :Boolean; AKind :TTabKind; AOnPassive :Boolean; AIndex :Integer);

      procedure AddTabEx(Active :Boolean; AKind :TTabKind; AFixed :Boolean; AFromPassive :Boolean = False);
      procedure DeleteTabEx(Active :Boolean; AKind :TTabKind; AIndex :Integer);
      procedure FixUnfixTabEx(Active :Boolean; AKind :TTabKind; AIndex :Integer);
      procedure ListTabEx(Active :Boolean; AKind :TTabKind);

      procedure SetPressed(AKind :TTabKind; AIndex :Integer);

    public
     {$ifdef bUseInjecting}
      property DrawLock :Integer read FDrawLock;
     {$endif bUseInjecting}
      property Actions :TClickActions read FActions;
    end;

  function HotSpot2Str(AHotSpot :THotSpot) :TString;
  function ClickType2Str(AHotSpot :TClickType) :TString;
  function Shifths2Str(AShifts :TKeyShifts) :TString;
  function TabAction2Str(Action :TTabAction) :TString;

  var
    TabsManager :TTabsManager;

  procedure MainMenu;
  procedure ProcessSelectMode;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    EditTabDlg,
    TabListDlg,
    PanelTabsOptions,
    MixDebug;


  function FarSettingShowKeyBar :Boolean;
  begin
   {$ifdef Far3}
    Result := FarGetSetting(FSSF_SCREEN, 'KeyBar') <> 0;
   {$else}
    Result := FarAdvControl(ACTL_GETINTERFACESETTINGS, nil) and FIS_SHOWKEYBAR <> 0;
   {$endif Far3}
  end;


 {-----------------------------------------------------------------------------}

  procedure ExecuteCommand(const ACommand :TString);
  var
    vFile :TString;
    vParam :PTChar;
  begin
    vParam := PTChar(ACommand);
    vFile := ExtractParamStr(vParam);
    ShellOpen(vFile, vParam);
  end;


  function ParseExecLine(const ACmdStr :TString) :TString;
  var
    vDstBuf :PTChar;
    vDstSize :Integer;
    vDstLen :Integer;

    procedure LocGrow;
    begin
      ReallocMem(vDstBuf, (vDstSize + 256) * SizeOf(TChar));
      Inc(vDstSize, 256);
    end;

    procedure AddChr(AChr :TChar);
    begin
      if vDstLen + 1 > vDstSize then
        LocGrow;
      PTChar(vDstBuf + vDstLen)^ := AChr;
      Inc(vDstLen);
    end;

    procedure AddStr(const AStr :TString);
    begin
      while vDstLen + length(AStr) > vDstSize do
        LocGrow;
      StrMove(vDstBuf + vDstLen, PTChar(AStr), length(AStr));
      Inc(vDstLen, length(AStr));
    end;

    function GetPanelFolder(Active :Boolean) :TString;
    begin
      Result := FarPanelGetCurrentDirectory(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE));
    end;

  var
    vPtr :PTChar;
    vActive :Boolean;
  begin
    Result := '';

    vDstSize := 0;
    vDstBuf := nil;
    try
      LocGrow;
      vDstLen := 0;
      vActive := True;

      vPtr := PTChar(ACmdStr);
      while vPtr^ <> #0 do begin
        { Частично совместимо с метасимволами стандартных ассоциации FAR }
        if vPtr^ = '!' then begin
          Inc(vPtr);
          if vPtr^ = '!' then begin
            AddChr('!');
            Inc(vPtr);
          end else
          if vPtr^ = ':' then begin
            AddStr(ExtractFileDrive(GetPanelFolder(vActive)));
            Inc(vPtr);
          end else
          if vPtr^ = '\' then begin
            AddStr(AddBackSlash(GetPanelFolder(vActive)));
            Inc(vPtr);
          end else
          if (vPtr^ = '.') and ((vPtr + 1)^ = '!') then begin
            AddStr(FarPanelGetCurrentItem(vActive));
            Inc(vPtr, 2);
          end else
          if (vPtr^ = '#') or (vPtr^ = '^') then begin
            vActive := vPtr^ = '^';
            Inc(vPtr);
          end else
            AddStr(ExtractFileTitle(FarPanelGetCurrentItem(vActive)));
        end else
        begin
          AddChr(vPtr^);
          Inc(vPtr);
        end;
      end;

      SetString(Result, vDstBuf, vDstLen);

    finally
      MemFree(vDstBuf);
    end;
  end;



 {-----------------------------------------------------------------------------}
 { Копипаста с MoreHistory....                                                 }

  function GetNearestExistFolder(const APath :TString) :TString;
  var
    vDrive, vPath :TString;
    vLen :Integer;
  begin
    Result := '';
    if FileNameIsLocal(APath) then begin
      vDrive := AddBackSlash(ExtractFileDrive(APath));
      if WinFolderExists(vDrive) then begin
        vPath := RemoveBackSlash(APath);
        while Length(vPath) > 3 do begin
          if WinFolderExists(vPath) then begin
            Result := vPath;
            Exit;
          end;
          vLen := Length(vPath);
          vPath := RemoveBackSlash(ExtractFilePath(vPath));
          if Length(vPath) >= vLen then
            Exit;
        end;
        Result := vDrive;
      end;
    end;
  end;


  function CreateFolders(const APath :TString) :Boolean;
  var
    vDrive :TString;

    function LocCreate(const APath :TString) :Boolean;
    begin
      Result := True;
      if (APath = '') or (vDrive = APath) or WinFolderExists(APath) then
        Exit;
      Result := LocCreate(RemoveBackSlash(ExtractFilePath(APath)));
      if Result then
        Result := CreateDir(APath);
    end;

  begin
    Result := False;
    vDrive := ExtractFileDrive(APath);
    if FileNameIsLocal(APath) then
      vDrive := AddBackSlash(vDrive);
    if (vDrive = '') or WinFolderExists(vDrive) then
      Result := LocCreate(APath);
  end;


  function CheckFolderExists(var AName :TString) :Boolean;
  var
    vRes :Integer;
    vFolder :TString;
  begin
    Result := True;
    if not WinFolderExists(AName) then begin

      vFolder := GetNearestExistFolder(AName);

      if vFolder <> '' then begin

        vRes := ShowMessage(GetMsgStr(strConfirmation),
          GetMsgStr(strFolderNotFound) + #10 + AName + #10 +
          GetMsgStr(strNearestFolderIs) + #10 + vFolder + #10 +
          GetMsgStr(strGotoNearestBut) + #10 + GetMsgStr(strCreateFolderBut) + #10 + {GetMsgStr(strDeleteBut) + #10 +} GetMsgStr(strCancel),
          FMSG_WARNING, 3{4});

        case vRes of
          0: AName := vFolder;
          1:
          begin
            if not CreateFolders(AName) then
              AppError(GetMsgStr(strCannotCreateFolder) + #10 + AName);
          end;
//        2:
//        begin
//          Result := False;
//          DeleteSelected;
//        end;
        else
          Result := False;
        end;

      end else
      begin

        vRes := ShowMessage(GetMsgStr(strError),
          GetMsgStr(strFolderNotFound) + #10 + AName + #10 +
          {GetMsgStr(strDeleteBut) + #10 +} GetMsgStr(strCancel),
          FMSG_WARNING, 1{2});

        case vRes of
          0:
          begin
            Result := False;
//          DeleteSelected;
          end;
        else
          Result := False;
        end;
      end;

    end;
  end;


  function JumpToPath(Active :Boolean; {const} APath :TString) :Boolean;
  begin
    Result := False;

    APath := StrExpandEnvironment(APath);

    if IsFullFilePath(APath) then
      if not CheckFolderExists(APath) then
        Exit;

    FarPanelJumpToPath(Active, APath);
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  function SafeMaskStr(const AStr :TString) :TSTring;
  begin
    if LastDelimiter(',"', AStr) <> 0 then
      Result := AnsiQuotedStr(AStr, '"')
    else
      Result := AStr;
  end;


  function ExtractNextLine(var AStr :PTChar) :TString;
  var
    vBeg :PTChar;
  begin
    while (AStr^ <> #0) and ((AStr^ = #13) or (AStr^ = #10)) do
      Inc(AStr);
    vBeg := AStr;
    while (AStr^ <> #0) and (AStr^ <> #13) and (AStr^ <> #10) do
      Inc(AStr);
    SetString(Result, vBeg, AStr - vBeg);
  end;


  function ExtractNextItem(var AStr :PTChar) :TString;
  begin
    if AStr^ = '"' then begin
      Result := AnsiExtractQuotedStr(AStr, '"');
      if AStr^ = ',' then
        Inc(AStr)
      else
        Result := Result + ExtractNextValue(AStr, [',']);
    end else
      Result := ExtractNextValue(AStr, [',']);
  end;


  procedure DrawTextChr(AChr :TChar; X, Y :Integer; const AColor :TFarColor);
  var
    vBuf :array[0..1] of TChar;
  begin
    vBuf[0] := AChr;
    vBuf[1] := #0;
    FARAPI.Text(X, Y, AColor, @vBuf[0]);
  end;


  procedure DrawTextEx(const AStr :TString; X, Y :Integer; AMaxLen, ASelPos, ASelLen :Integer; const AColor1, AColor2 :TFarColor);

    procedure LocDrawPart(var AChr :PTChar; ALen :Integer; var ARest :Integer; const AColor :TFarColor);
    var
      vBuf :Array[0..255] of TChar;
    begin
      if (ARest > 0) and (ALen > 0) then begin
        if ALen > ARest then
          ALen := ARest;
        if ALen > High(vBuf) then
          ALen := High(vBuf);
        StrLCopy(@vBuf[0], AChr, ALen);
        FARAPI.Text(X, Y, AColor, @vBuf[0]);
        Dec(ARest, ALen);
        Inc(AChr, ALen);
        Inc(X, ALen);
      end;
    end;

  var
    vChr :PTChar;
  begin
    vChr := PTChar(AStr);
    if (ASelPos = 0) or (ASelLen = 0) then
      LocDrawPart(vChr, Length(AStr), AMaxLen, AColor1)
    else begin
      LocDrawPart(vChr, ASelPos - 1, AMaxLen, AColor1);
      LocDrawPart(vChr, ASelLen, AMaxLen, AColor2);
      LocDrawPart(vChr, Length(AStr) - ASelPos - ASelLen + 1, AMaxLen, AColor1);
    end;
  end;

  
 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function HotSpot2Str(AHotSpot :THotSpot) :TString;
  begin
    case AHotSpot of
      hsNone:   Result := 'None';
      hsTab:    Result := 'Tab';
      hsPanel:  Result := 'Panel';
      hsButtom: Result := 'Button';
    end;
  end;

  function ClickType2Str(AHotSpot :TClickType) :TString;
  begin
    case AHotSpot of
      mcNone:      Result := 'None';
      mcLeft:      Result := 'Left';
      mcRight:     Result := 'Right';
      mcMiddle:    Result := 'Middle';
      mcDblLeft:   Result := 'DblLeft';
      mcDblRight:  Result := 'DblRight';
      mcDblMiddle: Result := 'DblMiddle';
    end;
  end;

  function Shifths2Str(AShifts :TKeyShifts) :TString;
  begin
    Result := '';
    if ksShift in AShifts then
      Result := 'Shift';
    if ksControl in AShifts then
      Result := AppendStrCh(Result, 'Ctrl', '+');
    if ksAlt in AShifts then
      Result := AppendStrCh(Result, 'Alt', '+');
  end;


  function TabAction2Str(Action :TTabAction) :TString;
  begin
    Result := GetMsgStr(TMessages(byte(strMouseActionBase) + byte(Action)));
  end;


  function TabAction2Word(Action :TTabAction) :TString;
  begin
    case Action of
      taNone:       Result := 'None';
      taSelect:     Result := 'Select';
      taPSelect:    Result := 'PSelect';
      taEdit:       Result := 'Edit';
      taDelete:     Result := 'Delete';
      taFixUnfix:   Result := 'Fix';
      taAdd:        Result := 'Add';
      taAddFixed:   Result := 'AddFix';
      taPAdd:       Result := 'PAdd';
      taPAddFixed:  Result := 'PAddFix';
      taList:       Result := 'List';
      taMainMenu:   Result := 'Menu';
    end;
  end;


  function Word2TabAction(const AStr :TString) :TTabAction;
  var
    I :TTabAction;
  begin
    for I := Low(TTabAction) to High(TTabAction) do
      if StrEqual(TabAction2Word(I), AStr) then begin
        Result := I;
        Exit;
      end;
    Result := taNone;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure ProcessSelectMode;
  var
    vKey :Integer;
    vChr :TChar;
    vReady, vActive, vOnPassive :Boolean;
  begin
    vActive := True;
    vOnPassive := False;
    repeat
      vKey := FarAdvControl(ACTL_WAITKEY, nil);

      vReady := True;
      case vKey of
        KEY_ESC:
          {};
        KEY_INS:
          TabsManager.AddTab(vActive);
        KEY_DEL:
          TabsManager.DeleteTab(vActive);
        KEY_SPACE:
          TabsManager.ListTab(vActive);
        KEY_MULTIPLY:
          TabsManager.FixUnfixTab(vActive);
        KEY_DIVIDE:
          begin
            vOnPassive := not vOnPassive;
            vReady := False;
          end;
        KEY_TAB:
          begin
            vActive := not vActive;
            vReady := False;
          end;
      else
//      TabsManager.SelectTab(True, VKeyToIndex(vKey));
        if (vKey > 32) and (vKey <= $FFFF) then begin
          vChr := TChar(vKey);
          TabsManager.SelectTabByKey(vActive, vOnPassive, vChr);
        end;
      end;
    until vReady;
  end;


  procedure MainMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMAddTab),
      GetMsg(strMEditTabs),
      GetMsg(strMSelectTab),
      '',
      GetMsg(strMOptions)
    ]);
    try
      vMenu.Help := 'Contents';

      TabsManager.PaintTabs;
      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: TabsManager.AddTab(True);
        1: TabsManager.ListTab(True);
        2: ProcessSelectMode;
        4: OptionsMenu;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TClickAction                                                               }
 {-----------------------------------------------------------------------------}

  constructor TClickAction.CreateEx(AHotSpot :THotSpot; AClickType :TClickType; AShifts :TKeyShifts; AAction :TTabAction);
  begin
    Create;
    FHotSpot := AHotSpot;
    FClickType := AClickType;
    FShifts := AShifts;
    FAction := AAction;
  end;


  function TClickAction.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  var
    vAnother :TClickAction;
  begin
    vAnother := Another as TClickAction;
    Result := IntCompare(Byte(FHotSpot), Byte(vAnother.HotSpot));
    if Result = 0 then
      Result := IntCompare(Byte(FClickType), Byte(vAnother.ClickType));
    if Result = 0 then
      Result := IntCompare(Byte(FShifts), Byte(vAnother.Shifts));
    if Result = 0 then
      Result := IntCompare(Byte(FAction), Byte(vAnother.Action));
  end;


  function TClickAction.ShiftAndClickAsStr :TString;
  begin
    Result := AppendStrCh( ClickType2Str(FClickType), Shifths2Str(FShifts), '+');
  end;


 {-----------------------------------------------------------------------------}
 { TClickActions                                                               }
 {-----------------------------------------------------------------------------}

  procedure TClickActions.StoreReg;
  var
    vConfig :TFarConfig;

    procedure LocWriteAction(AIndex :Integer; Action :TClickAction);
    begin
      if vConfig.OpenKey(cActionsRegFolder + '\' + cActionRegFolder + Int2Str(AIndex)) then begin
        try
          vConfig.WriteInt(cAreaRegKey, Byte(Action.Hotspot));
          vConfig.WriteInt(cClickRegKey, Byte(Action.ClickType));
          vConfig.WriteInt(cShiftsRegKey, Byte(Action.Shifts));
          vConfig.WriteStr(cActionRegKey, TabAction2Word(Action.Action));
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I :Integer;
  begin
    vConfig := TFarConfig.CreateEx(True, cPluginName);
    try
      for I := 0 to Count - 1 do
        LocWriteAction(I, Items[I]);

      if vConfig.OpenKey(cActionsRegFolder) then begin
        I := Count;
        while vConfig.DeleteKey( cActionRegFolder + Int2Str(I) ) do
          Inc(I);
      end;

    finally
      FreeObj(vConfig);
    end;
  end;


  procedure TClickActions.RestoreReg;
  var
    vConfig :TFarConfig;

    function LocReadAction(AIndex :Integer) :Boolean;
    var
      vActionStr :TString;
      vArea, vClick, vShifts :Integer;
    begin
      Result := False;
      if vConfig.OpenKey( cActionsRegFolder + '\' + cActionRegFolder + Int2Str(AIndex) ) then begin
        try
          vArea := vConfig.ReadInt(cAreaRegKey, -1);
          vClick := vConfig.ReadInt(cClickRegKey, -1);
          vShifts := vConfig.ReadInt(cShiftsRegKey, -1);
          vActionStr := vConfig.ReadStr(cActionRegKey);
          if (vArea >= 1) and (vClick >= 1) and (vShifts >= 0) and (vActionStr <> '') then
            AddSorted( TClickAction.CreateEx(THotSpot(vArea), TClickType(vClick), TKeyShifts(Byte(vShifts)), Word2TabAction(vActionStr)), 0, dupAccept);
          Result := True;
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I :Integer;
  begin
    vConfig := TFarConfig.CreateEx(False, cPluginName);
    try
      if vConfig.Exists then begin
        I := 0;
        while LocReadAction(I) do
          Inc(I);
      end;
    finally
      FreeObj(vConfig);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TPanelTab                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TPanelTab.CreateEx(const ACaption, AFolder :TString);
  begin
    inherited Create;
    FCaption := ACaption;
    FFolder := AFolder;
    FSelected := TStringList.Create;
    FSelected.Sorted := True; { Для ускорения FarPanelSetSelectedItems }
  end;


  destructor TPanelTab.Destroy; {override;}
  begin
    FreeObj(FSelected);
    inherited Destroy;
  end;


  function TPanelTab.GetTabCaption :TString;
  begin
    if IsFixed then
      Result := FCaption
    else
      Result := PathToCaption(FFolder);
  end;


  function TPanelTab.IsFixed :Boolean;
  begin
    Result := (FCaption <> '') and (FCaption <> '*');
  end;


  procedure TPanelTab.FormatCaption(AHotkey :TChar);

    function LocFormat(const ACaption, AHotkey :TString) :TString;
    begin
      Result := StrIf(IsFixed, optFixedTabFmt, optNormTabFmt);
      if Result <> '' then begin
        Result := StrReplace(Result, '%s', ACaption, []);
        Result := StrReplace(Result, '%n', AHotkey, []);
      end else
        Result := AHotkey + ACaption;
    end;

  var
    vStr, vStr1 :TString;
    vPos :Integer;
  begin
    vStr := GetTabCaption;

    FHotkey := #0;
    FHotPos := -1;
    FFmtCaption := '';

    if AHotkey = #0 then begin
      vPos := ChrPos('&', vStr);
      if (vPos > 0) and (vPos < length(vStr)) then begin
        FHotkey := CharUpcase(vStr[vPos + 1]);
        FFmtCaption := LocFormat(vStr, '');
      end;
    end else
    begin
      FHotkey := AHotkey;
      vStr1 := '';
      if optShowNumbers then
        vStr1 := '&' + TString(AHotkey);
      FFmtCaption := LocFormat(vStr, vStr1);
    end;

    if FFmtCaption <> '' then begin
      FHotPos := ChrPos('&', FFmtCaption);
      if FHotPos <> 0 then
        Delete(FFmtCaption, FHotPos, 1);
    end;
  end;


  procedure TPanelTab.Fix(AValue :Boolean);
  begin
    if AValue then
      FCaption := PathToCaption(FFolder)
    else
      FCaption := '*';
  end;


 {-----------------------------------------------------------------------------}
 { TPanelTabs                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TPanelTabs.CreateEx(const AName :TString);
  begin
    Create;
    FName := AName;
    FCurrent := -1;
  end;


  function TPanelTabs.FindTab(const AName :TString; AFixedOnly, AByFolder :Boolean) :Integer;
  var
    I :Integer;
    vTab :TPanelTab;
    vStr :TString;
  begin
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      if AFixedOnly and not vTab.IsFixed then
        Continue;
      if not AByFolder then
        vStr := vTab.FCaption
      else
        vStr := RemoveBackSlash(vTab.FFolder);
      if StrEqual(AName, vStr) then begin
        Result := I;
        Exit;
      end;
    end;
    Result := -1;
  end;


  function TPanelTabs.FindTabByKey(AKey :TChar) :Integer;
  var
    I :Integer;
    vKey :TChar;
    vTab :TPanelTab;
  begin
    vKey := CharUpcase(AKey);
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      if vTab.FHotkey = vKey then begin
        Result := I;
        Exit;
      end;
    end;
    Result := -1;
  end;


  procedure TPanelTabs.UpdateHotkeys;
  var
    I, J :Integer;
    vTab :TPanelTab;
    vChr :TChar;
  begin
//  TraceF('UpdateHotkeys %s', [FName]);

    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      vTab.FormatCaption(#0)
    end;

    J := 0;
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      if vTab.FHotkey = #0 then begin
        repeat
          vChr := IndexToChar(J);
          Inc(J);
        until FindTabByKey(vChr) = -1;
        vTab.FormatCaption(vChr)
      end;
    end;
  end;


  procedure TPanelTabs.RealignTabs(ANewWidth :Integer);

    function LocReduceTab :Boolean;
    var
      I, J, L :Integer;
    begin
      Result := False;
      J := -1; L := 0;
      for I := 0 to FCount - 1 do
        with TPanelTab(Items[I]) do
          if FWidth > L then begin
            L := FWidth;
            J := I;
          end;
      with TPanelTab(Items[J]) do begin
        if FWidth <= cMinTabWidth then
          Exit;
        Dec(FWidth);
      end;
      for I := J + 1 to FCount - 1 do
        with TPanelTab(Items[I]) do
          Dec(FDelta);
      Result := True;
    end;

  var
    I, X, L :Integer;
    vTab :TPanelTab;
  begin
//  TraceF('RealignTabs %s', [FName]);
    UpdateHotkeys;

    FAllWidth := ANewWidth;
    X := 1;
    for I := 0 to FCount - 1 do begin
      vTab := Items[I];
      L := Length(vTab.FmtCaption) + length(optTabDelimiter);
      vTab.FDelta := X;
      vTab.FWidth := L;
      Inc(X, L);
    end;

    if optShowButton then
      { Вычитаем размер кнопочки }
      Dec(ANewWidth, 3);

    if X > ANewWidth then begin
      { Алгоритм тормозной, но пока - покатит }
      for I := 0 to X - ANewWidth - 1 do
        if not LocReduceTab then
          Break;
    end;
  end;


  procedure TPanelTabs.StoreReg(const APath :TString; AOnlyCurrent :Boolean = False);
  var
    vPath :TString;
    vConfig :TFarConfig;

    procedure LocWriteTab(AIndex :Integer; ATab :TPanelTab);
    begin
      if vConfig.OpenKey(vPath + '\' + cTabRegFolder + Int2Str(AIndex)) then begin
        try
          vConfig.StrValue(cCaptionRegKey, ATab.FCaption);
          vConfig.StrValue(cFolderRegKey, ATab.FFolder);
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I :Integer;
  begin
    vPath := APath;
    if vPath = '' then
      vPath := cTabsRegFolder + '\' + FName;

    vConfig := TFarConfig.CreateEx(True, cPluginName);
    try
      if vConfig.OpenKey(vPath) then begin

        vConfig.IntValue(cCurrentRegKey, FCurrent);

        if not AOnlyCurrent then begin
          { Сохраняем табы }
          for I := 0 to Count - 1 do
            LocWriteTab(I, Items[I]);

          { Удаляем лишние табы }
          if vConfig.OpenKey(vPath) then begin
            I := Count;
            while vConfig.DeleteKey( cTabRegFolder + Int2Str(I) ) do
              Inc(I);
          end;
        end;
      end;

    finally
      FreeObj(vConfig);
    end;
  end;


  procedure TPanelTabs.RestoreReg(const APath :TString);
  var
    vPath :TString;
    vConfig :TFarConfig;

    function LocReadTab(AIndex :Integer) :Boolean;
    var
      vCaption, vFolder :TString;
    begin
      Result := False;
      if vConfig.OpenKey( vPath + '\' + cTabRegFolder + Int2Str(AIndex) ) then begin
        try
          vConfig.StrValue(cCaptionRegKey, vCaption);
          if vCaption <> '' then begin
            vConfig.StrValue(cFolderRegKey, vFolder);
            Add(TPanelTab.CreateEx(vCaption, vFolder));
          end;
          Result := True;
        finally
          vConfig.OpenKey( '' );
        end;
      end;
    end;

  var
    I :Integer;
  begin
    vPath := APath;
    if vPath = '' then
      vPath := cTabsRegFolder + '\' + FName;

    vConfig := TFarConfig.CreateEx(False, cPluginName);
    try
      if vConfig.Exists and vConfig.OpenKey(vPath) then begin

        vConfig.IntValue(cCurrentRegKey, FCurrent);

        I := 0;
        while LocReadTab(I) do
          Inc(I);

//      UpdateHotkeys;
      end;
    finally
      FreeObj(vConfig);
    end;
  end;


  procedure TPanelTabs.StoreFile(const AFileName :TString);
  var
    I :Integer;
    vTab :TPanelTab;
    vFileName, vStr :TString;
  begin
    vFileName := SafeChangeFileExtension(FarExpandFileName(StrExpandEnvironment(AFileName)), cTabFileExt);
//  TraceF('TPanelTabs.StoreFile: %s', [vFileName]);

    vStr := '';
    for I := 0 to Count - 1 do begin
      vTab := Items[I];
      vStr := vStr + SafeMaskStr(vTab.Caption) + ',' + SafeMaskStr(vTab.FFolder) + CRLF;
    end;

    StrToFile(vFileName, vStr);
  end;


  procedure TPanelTabs.RestoreFile(const AFileName :TString);
  var
    vFileName, vStr, vStr1, vCaption, vFolder :TString;
    vPtr, vPtr1 :PTChar;
  begin
    vFileName := SafeChangeFileExtension(FarExpandFileName(StrExpandEnvironment(AFileName)), cTabFileExt);
//  TraceF('TPanelTabs.RestoreFile: %s', [vFileName]);

    vStr := StrFromFile(vFileName);

    Clear;
    FAllWidth := -1;

    vPtr := PTChar(vStr);
    while vPtr^ <> #0 Do begin
      vStr1 := ExtractNextLine(vPtr);
      if vStr1 <> '' then begin
        vPtr1 := PTChar(vStr1);
        vCaption := ExtractNextItem(vPtr1);
        vFolder := ExtractNextItem(vPtr1);
        Add(TPanelTab.CreateEx(vCaption, vFolder));
      end;
    end;
//  UpdateHotkeys;
  end;


 {-----------------------------------------------------------------------------}
 { TTabsManager                                                                }
 {-----------------------------------------------------------------------------}

  constructor TTabsManager.Create; {override;}
  begin
    inherited Create;

    FTabs[tkLeft] := TPanelTabs.CreateEx(cLeftRegFolder);
    FTabs[tkRight] := TPanelTabs.CreateEx(cRightRegFolder);
    FTabs[tkCommon] := TPanelTabs.CreateEx(cCommonRegFolder);
    FActions := TClickActions.Create;

    FPressedIndex := -1;

    RestoreTabs;
    FActions.RestoreReg;
  end;


  destructor TTabsManager.Destroy; {override;}
  begin
    FreeObj(FActions);
    FreeObj(FTabs[tkLeft]);
    FreeObj(FTabs[tkRight]);
    FreeObj(FTabs[tkCommon]);
    inherited Destroy;
  end;


  procedure TTabsManager.StoreTabs;
  begin
    FTabs[tkLeft].StoreReg('');
    FTabs[tkRight].StoreReg('');
    FTabs[tkCommon].StoreReg('');
  end;


  procedure TTabsManager.RestoreTabs;
  begin
    FTabs[tkLeft].RestoreReg('');
    FTabs[tkRight].RestoreReg('');
    FTabs[tkCommon].RestoreReg('');
  end;


  procedure TTabsManager.ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    WriteSetup;
    NeedRealign;
    PaintTabs;
  end;


  procedure TTabsManager.NeedRealign;
  begin
    FTabs[tkLeft].FAllWidth := -1;
    FTabs[tkRight].FAllWidth := -1;
    FTabs[tkCommon].FAllWidth := -1;
  end;


  function TTabsManager.FindActions(AHotSpot :THotSpot; AClickType :TClickType; AShifts :TKeyShifts) :TClickAction;
  var
    I :Integer;
    vAction :TClickAction;
  begin
    for I := 0 to FActions.Count - 1 do begin
      vAction := FActions[I];
      if (vAction.FHotSpot = AHotSpot) and (vAction.FClickType = AClickType) and (AShifts = vAction.FShifts) then begin
        Result := vAction;
        Exit;
      end;
    end;
    Result := nil;
  end;


 {-----------------------------------------------------------------------------}

  function TTabsManager.HitTest(X, Y :Integer; var APanelKind :TTabKind; var AIndex :Integer) :THotSpot;

    function LocCheck(AKind :TTabKind) :THotSpot;
    var
      I :Integer;
      vTabs :TPanelTabs;
      vTab :TPanelTab;
      vRect, vRect1 :TRect;
    begin
      Result := hsNone;
      vRect := FRects[AKind];
      if RectContainsXY(vRect, X, Y) then begin
        APanelKind := AKind;

        vTabs := FTabs[AKind];
        for I := 0 to vTabs.Count - 1 do begin
          vTab := vTabs[I];
          vRect1 := Bounds(vRect.Left + vTab.FDelta, vRect.Top, vTab.FWidth, 1);
          if RectContainsXY(vRect1, X, Y) then begin
            Result := hsTab;
            AIndex := I;
            Exit;
          end;
        end;

        if optShowButton then begin
          vRect1 := Bounds(vRect.Right - 2, vRect.Top, 3, 1);
          if RectContainsXY(vRect1, X, Y) then begin
            Result := hsButtom;
            Exit;
          end;
        end;

        Result := hsPanel;
      end;
    end;

  begin
//  TraceF('HitTest: %d, %d', [X, Y]);
    Result := hsNone;
    AIndex := -1;
    APanelKind := tkCommon;
    if not CanPaintTabs then
      Exit;

    if optSeparateTabs then begin
      Result := LocCheck(tkRight);
      if Result = hsNone then
        Result := LocCheck(tkLeft);
    end else
      Result := LocCheck(tkCommon);
  end;


  function TTabsManager.NeedCheck(var X, Y :Integer) :Boolean;

    function LocNeedCheck(AKind :TTabKind) :Boolean;
    begin
      Result := False;
      with FRects[AKind] do
        if Right > Left then begin
          Y := Top;
          X := Right - 2;
          Result := True;
        end;
    end;

  begin
    if optSeparateTabs then begin
      Result := LocNeedCheck(tkRight);
      if not Result then
        Result := LocNeedCheck(tkLeft);
    end else
      Result := LocNeedCheck(tkCommon);
  end;


  function TTabsManager.CanPaintTabs(ACheckCursor :Boolean = False) :Boolean;
    { Вызывается из дополнительного потока. Не должна использовать не-threadsafe функции}
  var
    vWinType :Integer;
    vCursorInfo :TConsoleCursorInfo;
  begin
    Result := False;
    if not optShowTabs then
      Exit;

    vWinType := FarGetWindowType;
//  TraceF('WindowType=%d', [vWinType]);

    if vWinType = WTYPE_PANELS then begin

      if ACheckCursor then begin
        GetConsoleCursorInfo(hStdOut, vCursorInfo);
//      TraceF('Cursor=%d', [Byte(vCursorInfo.bVisible)]);
        if not vCursorInfo.bVisible then
          { Нет курсора - значит активна не панель. Этой проверкой отсекаем ситуацию, }
          { когда активно меню и т.п., что не определяется с помощью ACTL_GETWINDOWINFO/ACTL_GETWINDOWTYPE }
          Exit;
      end;

//    vStr := GetConsoleTitleStr;
//    TraceF('Title=%s', [vStr]);
//    if (vStr = '') or (vStr[1] <> '{') then
//      { Этой проверкой отсекаем ситуацию, когда из под Far'а запущена консольная программа }
//      Exit;

      Result := True;
    end;
  end;


  function SwapFgBgColors(AColor :TFarColor) :TFarColor;
  begin
    Result := MakeColor(GetColorBG(AColor), GetColorFG(AColor));
  end;


  procedure TTabsManager.PaintTabs(ACheckCursor :Boolean = False);
  var
    vColorSide1, vColorSide2 :TFarColor;
    vWinWidth :Integer;
    vCmdLineY :Integer;
    vFolders :array[TTabKind] of TString;


    procedure DetectPanelSettings;
    var
      vSize :TSize;
    begin
      vSize := FarGetWindowSize;
      vCmdLineY := vSize.CY - 1 - IntIf(FarSettingShowKeyBar, 1, 0);
      vWinWidth := vSize.CX;
    end;


    procedure DetectPanelsLayout;
    var
      vMaximized :Boolean;

      procedure LocDetect(Active :Boolean);
      var
        vInfo  :TPanelInfo;
        vKind  :TTabKind;
        vVisible, vPlugin :Boolean;
      begin
        FarGetPanelInfo(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), vInfo);
       {$ifdef Far3}
        vVisible := PFLAGS_VISIBLE and vInfo.Flags <> 0;
        vPlugin  := PFLAGS_PLUGIN and vInfo.Flags <> 0;
       {$else}
        vVisible := vInfo.Visible <> 0;
        vPlugin  := vInfo.Plugin <> 0;
       {$endif Far3}
        if PFLAGS_PANELLEFT and vInfo.Flags <> 0 then
          vKind := tkLeft
        else
          vKind := tkRight;

        if not vPlugin then
          vFolders[vKind] := GetPanelDir(Active)
        else
          vFolders[vKind] := '';
        if not optSeparateTabs and Active then
          vFolders[tkCommon] := vFolders[vKind];

        if not vVisible {or not vInfo.Focus} then
          Exit;
        if vInfo.PanelRect.Bottom + 1 >= vCmdLineY then
          { Нет места для табов }
          Exit;

        if not vMaximized then
          with vInfo.PanelRect do begin
            FRects[vKind] := Rect(Left, Bottom + 1, Right + 1, Bottom + 2);
//          FRects[vKind] := Rect(Left, Bottom + 2, Right + 1, Bottom + 3);
            { Check fullscreen }
            vMaximized := (Right - Left + 1) = vWinWidth;
          end;
      end;


    begin
      vMaximized := False;
      FillChar(FRects, SizeOf(FRects), 0);
      LocDetect(True);
      LocDetect(False);

      if not optSeparateTabs then begin
        if not RectEmpty(FRects[tkLeft]) and not RectEmpty(FRects[tkRight]) then begin
          FRects[tkCommon] := FRects[tkLeft];
          FRects[tkCommon].Right := FRects[tkRight].Right;
          FRects[tkCommon].Top := IntMax(FRects[tkLeft].Top, FRects[tkRight].Top);
          FRects[tkCommon].Bottom := FRects[tkCommon].Top + 1;
        end else
        if not RectEmpty(FRects[tkLeft]) then
          FRects[tkCommon] := FRects[tkLeft]
        else
        if not RectEmpty(FRects[tkRight]) then
          FRects[tkCommon] := FRects[tkRight]
      end;
    end;

    

    procedure PaintTabsForPanel(AKind :TTabKind);

      function IsTabSelected(const ATabStr :TString) :Boolean;
      var
        vPos :Integer;
        vPath1, vPath2 :TString;
      begin
        vPos := ChrPos(';', ATabStr);
        if vPos = 0 then begin
          vPath1 := RemoveBackSlash(StrExpandEnvironment(ATabStr));
          Result := StrEqual(vPath1, vFolders[AKind])
        end else
        begin
          vPath1 := RemoveBackSlash(StrExpandEnvironment(Copy(ATabStr, 1, vPos - 1)));
          vPath2 := RemoveBackSlash(StrExpandEnvironment(Copy(ATabStr, vPos + 1, MaxInt)));
          Result :=
            (StrEqual(vPath1, vFolders[tkLeft]) and StrEqual(vPath2, vFolders[tkRight])) or
            (StrEqual(vPath1, vFolders[tkRight]) and StrEqual(vPath2, vFolders[tkLeft]));
        end;
      end;

    var
      I, X, vWidth :Integer;
      vRect :TRect;
      vTabs :TPanelTabs;
      vTab :TPanelTab;
      vStr :TString;
      vHotColor :TFarColor;
      vCurrentIndex :Integer;
    begin
      vTabs := FTabs[AKind];
      vRect := FRects[AKind];
      if RectEmpty(vRect) then
        Exit;

      vCurrentIndex := -1;
      if (FPressedIndex <> -1) and (FPressedKind = AKind) then begin
        vCurrentIndex := FPressedIndex;
      end else
      if vTabs.FCurrent <> -1 then begin
        if vTabs.FCurrent < vTabs.Count then begin
          vTab := vTabs[vTabs.FCurrent];
          if not vTab.IsFixed then begin
            { Таб, следящий за сменой позиции... }
            vCurrentIndex := vTabs.FCurrent;
            if not StrEqual(vTab.FFolder, vFolders[AKind]) then begin
              if vFolders[AKind] <> '' then begin
                vTab.FFolder := vFolders[AKind];
                vTabs.FAllWidth := -1;
              end else
                { Плагин. Пока не поддерживается. }
                vCurrentIndex := -1;
            end;
          end;
        end else
          vTabs.FCurrent := -1;
      end;

      vWidth := vRect.Right - vRect.Left + 1;
      if vTabs.FAllWidth <> vWidth then
        vTabs.RealignTabs(vWidth);

      vStr := StringOfChar(' ', vRect.Right - vRect.Left);
      FARAPI.Text(vRect.Left, vRect.Top, optBkColor, PTChar(vStr));

      if vCurrentIndex = -1 then
        for I := 0 to vTabs.Count - 1 do begin
          vTab := vTabs[I];
          if vTab.IsFixed and IsTabSelected(vTab.FFolder) then begin
            vCurrentIndex := I;
            Break;
          end;
        end;

      for I := 0 to vTabs.Count - 1 do begin
        vTab := vTabs[I];
        vStr := vTab.FmtCaption;
        vWidth := vTab.FWidth - length(optTabDelimiter);

        X := vRect.Left + vTab.FDelta;
        if vCurrentIndex = I then begin
          if optTabDelimiter <> '' then
            DrawTextChr(cSide1, X-1, vRect.Top, SwapFgBgColors(vColorSide1));

          vHotColor := MakeColor(GetColorFG(optNumberColor), GetColorBG(optActiveTabColor));
          DrawTextEx(vStr, X, vRect.Top, vWidth, vTab.FHotPos, 1, optActiveTabColor, vHotColor);
          Inc(X, vWidth);

          if optTabDelimiter <> '' then begin
            DrawTextChr(cSide1, X, vRect.Top, vColorSide1);
            Inc(X);
          end;
        end else
        begin
          vHotColor := MakeColor(GetColorFG(optNumberColor), GetColorBG(optPassiveTabColor));
          DrawTextEx(vStr, X, vRect.Top, vWidth, vTab.FHotPos, 1, optPassiveTabColor, vHotColor);
          Inc(X, vWidth);
        end;

        if (optTabDelimiter <> '') and (I < vTabs.Count - 1) {and (I <> vCurrentIndex - 1)} then begin
          vStr := optTabDelimiter;
          if I = vCurrentIndex then
            Delete(vStr, 1, 1);
          if I = vCurrentIndex - 1 then
            Delete(vStr, length(vStr), 1);
          if vStr <> '' then
            DrawTextEx(vStr, X, vRect.Top, length(vStr), 0, 0, optDelimiterColor, UndefColor);
        end;
      end;

      if optShowButton then begin
//      DrawTextChr(cSide2, vRect.Right - 3, vRect.Top, vColorSide2);
        DrawTextChr(cSide1, vRect.Right - 3, vRect.Top, SwapFgBgColors(vColorSide2));
        DrawTextChr('+', vRect.Right - 2, vRect.Top, optButtonColor);
        DrawTextChr(cSide1, vRect.Right - 1, vRect.Top, vColorSide2);
      end else
      begin
//      vTmp[0] := cSide1;
//      FARAPI.Text(vRect.Right - 1, vRect.Top, vColorSide2, @vTmp[0]);
      end
    end;


  begin
    if not CanPaintTabs(ACheckCursor) then
      Exit;

    vColorSide1 := MakeColor(GetColorBG(optBkColor), GetColorBG(optActiveTabColor));
    vColorSide2 := MakeColor(GetColorBG(optBkColor), GetColorBG(optButtonColor));

    DetectPanelSettings;
    DetectPanelsLayout;
//  DetectPanelsFolders;

   {$ifdef bUseInjecting}
    Inc(FDrawLock);
    try
   {$endif bUseInjecting}

      if optSeparateTabs then begin
        PaintTabsForPanel(tkLeft);
        PaintTabsForPanel(tkRight);
      end else
        PaintTabsForPanel(tkCommon);

   {$ifdef bUseInjecting}
    finally
      FARAPI.Text(0, 0, 0, nil);
      Dec(FDrawLock);
    end;
   {$endif bUseInjecting}
  end;


(*
  procedure TTabsManager.RefreshTabs;
  var
    X, Y :Integer;
    vCh :TChar;
  begin
    if NeedCheck(X, Y) then begin
      vCh := ReadScreenChar(X, Y);
      if vCh <> '+' then begin
//      Trace('RefreshTabs: Need repaint...');
        PaintTabs(True);
      end;
    end;
  end;
*)


  function TTabsManager.KindOfTab(Active :Boolean) :TTabKind;
  begin
    if optSeparateTabs then begin
      if Active = (FarPanelGetSide = 0) then
        Result := tkLeft
      else
        Result := tkRight;
    end else
      Result := tkCommon;
  end;


  function TTabsManager.GetTabs(Active :Boolean) :TPanelTabs;
  begin
    Result := FTabs[KindOfTab(Active)];
  end;


 {-----------------------------------------------------------------------------}

  procedure TTabsManager.RememberTabState(Active :Boolean; AKind :TTabKind);
  var
    vTabs :TPanelTabs;
    vTab :TPanelTab;
  begin
    vTabs := FTabs[AKind];
    if (vTabs.FCurrent >= 0) and (vTabs.FCurrent < vTabs.FCount) then begin
      vTab := vTabs[vTabs.FCurrent];
      vTab.FCurrent := FarPanelGetCurrentItem(Active);
      if optStoreSelection then begin
        vTab.FSelected.Clear;
        FarPanelGetSelectedItems(Active, vTab.FSelected);
      end;
    end;
  end;


  procedure TTabsManager.RestoreTabState(Active :Boolean; ATab :TPanelTab);
  begin
    if (ATab.FCurrent <> '') and (ATab.FCurrent <> '..') then
      FarPanelSetCurrentItem(Active, ATab.FCurrent);
    if optStoreSelection and (ATab.FSelected.Count > 0) then
      FarPanelSetSelectedItems(Active, ATab.FSelected, True);
  end;


  procedure TTabsManager.DoSelectTab(Active :Boolean; AKind :TTabKind; AOnPassive :Boolean; AIndex :Integer);

    procedure LocSetPath(Active :Boolean; const APath :TString);
    var
      vPos :Integer;
    begin
      vPos := ChrPos(';', APath);
      if vPos = 0 then
        JumpToPath(Active, APath)
      else begin
        JumpToPath(Active, Copy(APath, 1, vPos - 1));
        JumpToPath(not Active, Copy(APath, vPos + 1, MaxInt));
      end;
    end;

  var
    vTabs :TPanelTabs;
    vTab :TPanelTab;
    vStr :TString;
  begin
    vTabs := FTabs[AKind];
    if (AIndex >= 0) and (AIndex < vTabs.Count)then begin
      vTab := vTabs[AIndex];

      if UpCompareSubStr(cMacroPrefix, vTab.FFolder) = 0 then begin
        vStr := Copy(vTab.FFolder, length(cMacroPrefix) + 1, MaxInt);
        FarPostMacro(vStr);
        Exit;
      end;

      if UpCompareSubStr(cExecPrefix, vTab.FFolder) = 0 then begin
        vStr := ParseExecLine(StrExpandEnvironment(Copy(vTab.FFolder, length(cExecPrefix) + 1, MaxInt)));
        ExecuteCommand(vStr);
        Exit;
      end;

      if not AOnPassive then begin
        RememberTabState(Active, AKind);
        LocSetPath(Active, vTab.FFolder);
        RestoreTabState(Active, vTab);
        vTabs.FCurrent := AIndex;
      end else
        LocSetPath(not Active, vTab.FFolder);
      PaintTabs;
    end else
      Beep;
  end;


 {-----------------------------------------------------------------------------}

  procedure TTabsManager.AddTab(Active :Boolean);
  begin
    AddTabEx(Active, KindOfTab(Active), {Fixed:}False);
  end;


  procedure TTabsManager.AddTabEx(Active :Boolean; AKind :TTabKind; AFixed :Boolean; AFromPassive :Boolean = False);
  var
    vPath, vCaption :TString;
    vTabs :TPanelTabs;
  begin
    vPath := GetPanelDir(not (Active xor not AFromPassive));
    vTabs := FTabs[AKind];
    if not AFixed or (vTabs.FindTab(vPath, True, True) = -1) then begin
      if AFixed then
        vCaption := PathToCaption(vPath)
      else
        vCaption := '*';
      vTabs.Add(TPanelTab.CreateEx(vCaption, vPath));
      if not AFromPassive then
        vTabs.FCurrent := vTabs.Count - 1;
      vTabs.StoreReg('');
      vTabs.FAllWidth := -1;
      PaintTabs;
    end else
      Beep;
  end;


  procedure TTabsManager.DeleteTab(Active :Boolean);
  begin
    DeleteTabEx(Active, KindOfTab(Active), -1);
  end;

  procedure TTabsManager.DeleteTabEx(Active :Boolean; AKind :TTabKind; AIndex :Integer);
  var
    vTabs :TPanelTabs;
  begin
    vTabs := FTabs[AKind];
    if AIndex = -1 then
      AIndex := vTabs.FCurrent;
    if AIndex <> -1 then begin
      vTabs.Delete(AIndex);
      vTabs.FCurrent := -1; {!!!-???}
      vTabs.StoreReg('');
      vTabs.FAllWidth := -1;
      PaintTabs;
    end else
      Beep;
  end;


  procedure TTabsManager.FixUnfixTab(Active :Boolean);
  begin
    FixUnfixTabEx(Active, KindOfTab(Active), -1);
  end;

  procedure TTabsManager.FixUnfixTabEx(Active :Boolean; AKind :TTabKind; AIndex :Integer);
  var
    vTabs :TPanelTabs;
    vTab :TPanelTab;
  begin
    vTabs := FTabs[AKind];
    if AIndex = -1 then
      AIndex := vTabs.FCurrent;
    if AIndex <> -1 then begin
      vTab := vTabs[AIndex];
      vTab.Fix(not vTab.IsFixed);
      vTabs.StoreReg('');
      vTabs.FAllWidth := -1;
      PaintTabs;
    end else
      Beep;
  end;


  procedure TTabsManager.ListTab(Active :Boolean);
  begin
    ListTabEx(Active, KindOfTab(Active));
  end;

  procedure TTabsManager.ListTabEx(Active :Boolean; AKind :TTabKind);
  var
    vIndex :Integer;
    vTabs :TPanelTabs;
  begin
    vTabs := FTabs[AKind];
    vIndex := vTabs.FCurrent;
    if ListTabDlg(vTabs, vIndex) then
      DoSelectTab( Active, AKind, False, vIndex );
    vTabs.FAllWidth := -1;
    PaintTabs;
  end;


  procedure TTabsManager.SelectTab(Active :Boolean; AIndex :Integer);
  begin
    DoSelectTab( Active, KindOfTab(Active), False, AIndex );
  end;


  procedure TTabsManager.SelectTabByKey(Active, AOnPassive :Boolean; AChar :TChar);
  var
    vKind :TTabKind;
    vTabs :TPanelTabs;
    vIndex :Integer;
  begin
    vKind := KindOfTab(Active);

    vTabs := FTabs[vKind];
    vIndex := vTabs.FindTabByKey(AChar);
    if vIndex = -1 then begin
      AChar := FarXLat(AChar);
      vIndex := vTabs.FindTabByKey(AChar);
    end;

    DoSelectTab( Active, vKind, AOnPassive, vIndex );
  end;


  procedure TTabsManager.SetPressed(AKind :TTabKind; AIndex :Integer);
  begin
    if (AIndex <> FPressedIndex) or (AKind <> FPressedKind) then begin
      FPressedIndex := AIndex;
      FPressedKind := AKind;
      PaintTabs;
      
     {$ifdef bUseInjecting}
     {$else}
      FARAPI.Text(0, 0, UndefColor, nil);
     {$endif bUseInjecting}
    end;
  end;


  procedure TTabsManager.ClickAction(Action :TTabAction; AKind :TTabKind; AIndex :Integer);
  var
    vActive :Boolean;

    procedure LocEditTab;
    var
      vTabs :TPanelTabs;
    begin
      vTabs := FTabs[AKind];
      if EditTab(vTabs, AIndex) then begin
        vTabs.StoreReg('');
        vTabs.FAllWidth := -1;
        PaintTabs;
      end;
    end;

  begin
    vActive := True;
    if optSeparateTabs then
      vActive := (AKind = tkRight) = (FarPanelGetSide = 1);

    case Action of
      taSelect:
        DoSelectTab( vActive, AKind, False, AIndex );
      taPSelect:
        DoSelectTab( vActive, AKind, True, AIndex );
      taEdit:
        LocEditTab;
      taDelete:
        DeleteTabEx(vActive, AKind, AIndex);
      taFixUnfix:
        FixUnfixTabEx(vActive, AKind, AIndex);

      taAdd:
        AddTabEx(vActive, AKind, {Fixed:}False);
      taAddFixed:
        AddTabEx(vActive, AKind, {Fixed:}True);

      taPAdd:
        AddTabEx(vActive, AKind, {Fixed:}False, {FromPassive:}True);
      taPAddFixed:
        AddTabEx(vActive, AKind, {Fixed:}True, {FromPassive:}True);

      taList:
        ListTabEx(vActive, AKind);
      taMainMenu:
        MainMenu;
    end;
  end;


 {$ifdef bUseProcessConsoleInput}

  function TTabsManager.TrackMouseStart(AButton, X, Y :Integer; ADouble :Boolean; AShifts :DWORD) :Boolean;
  var
    vHotSpot :THotSpot;
    vKind :TTabKind;
    vIndex :Integer;
  begin
    Result := False;

    vHotSpot := HitTest(X, Y, vKind, vIndex);
    if vHotSpot = hsNone then
      Exit;
//  TraceF('TrackMouseStart: %d, %d x %d', [AButton, X, Y]);

    if not ADouble then begin
      case AButton of
        1: FTrackClick := mcLeft;
        2: FTrackClick := mcRight;
        3: FTrackClick := mcMiddle;
      end;
    end else begin
      case AButton of
        1: FTrackClick := mcDblLeft;
        2: FTrackClick := mcDblRight;
        3: FTrackClick := mcDblMiddle;
      end;
    end;

    FTrackShifts := [];
    if SHIFT_PRESSED and AShifts <> 0 then
      Include(FTrackShifts, ksShift);
    if (LEFT_CTRL_PRESSED + RIGHT_CTRL_PRESSED) and AShifts <> 0 then
      Include(FTrackShifts, ksControl);
    if (LEFT_ALT_PRESSED + RIGHT_ALT_PRESSED) and AShifts <> 0 then
      Include(FTrackShifts, ksAlt);

    if {not vRButton and} (vHotSpot = hsTab) then
      SetPressed(vKind, vIndex);

    FTrackPressed := True;
    FTrackIndex := vIndex;
    FTrackKind := vKind;
    FTrackWhat := vHotSpot;
    FTracked := True;
    Result := True;
  end;


  function TTabsManager.TrackMouseContinue(X, Y :Integer) :Boolean;
  var
    vHotSpot :THotSpot;
    vKind :TTabKind;
    vIndex :Integer;
  begin
    Result := False;
    if not FTracked then
      Exit;
//  TraceF('TrackMouseContinue: %d x %d', [X, Y]);

    vHotSpot := HitTest(X, Y, vKind, vIndex);

    FTrackPressed := (vHotSpot = FTrackWhat) and (vKind = FTrackKind) and (vIndex = FTrackIndex);
    if FTrackPressed then begin
      if {not vRButton and} (vHotSpot = hsTab) then
        SetPressed(vKind, vIndex);
    end else
      SetPressed(tkCommon, -1);

    Result := True;
  end;


  function TTabsManager.TrackMouseEnd(X, Y :Integer) :Boolean;
  var
    vAction :TClickAction;
  begin
    Result := False;
    if not FTracked then
      Exit;
//  TraceF('TrackMouseEnd: %d x %d', [X, Y]);

    FTracked := False;
    if FTrackPressed then begin
      try
        vAction := FindActions(FTrackWhat, FTrackClick, FTrackShifts);

        if vAction <> nil then
          ClickAction(vAction.FAction, FTrackKind, FTrackIndex)
        else begin
          case FTrackWhat of
            hsTab:
              if FTrackClick in [mcLeft, mcDblLeft] then begin
                if GetKeyState(VK_Shift) < 0 then
                  ClickAction(taPSelect, FTrackKind, FTrackIndex)
                else
                  ClickAction(taSelect, FTrackKind, FTrackIndex)
              end else
              if FTrackClick = mcRight then
                ClickAction(taEdit, FTrackKind, FTrackIndex)
              else
              if FTrackClick = mcMiddle then
                ClickAction(taDelete, FTrackKind, FTrackIndex);
            hsButtom:
              if FTrackClick = mcLeft then begin
                if GetKeyState(VK_Shift) < 0 then
                  ClickAction(taPAdd, FTrackKind, -1)
                else
                  ClickAction(taAdd, FTrackKind, -1)
              end else
              if FTrackClick = mcRight then
                ClickAction(taList, FTrackKind, -1);
            hsPanel:
              if FTrackClick = mcRight then
                ClickAction(taMainMenu, FTrackKind, -1);
          end;
        end;
      finally
        SetPressed(tkCommon, -1);
      end;
    end;
    Result := True;
  end;

 {$else}

  procedure TTabsManager.MouseClick;
  var
    vPoint, vPoint1 :TPoint;
    vIndex, vIndex1 :Integer;
    vKind, vKind1 :TTabKind;
    vHotSpot, vHotSpot1 :THotSpot;
    vClickType :TClickType;
    vShifts :TKeyShifts;
    vAction :TClickAction;
    vPressed :Boolean;
    vTime :DWORD;
  begin
    vPoint := GetConsoleMousePos;

    if GetKeyState(VK_RBUTTON) < 0 then
      vClickType := mcRight
    else
      vClickType := mcLeft;

    vTime := GetTickCount;
    if (FLastClickTime <> 0) and (TickCountDiff(vTime, FLastClickTime) < optDblClickDelay) and (vClickType = FLastClickType) and
      (FLastClickPos.X = vPoint.X) and (FLastClickPos.Y = vPoint.Y)
    then begin
      FLastClickTime := 0;
      if vClickType = mcLeft then
        vClickType := mcDblLeft
      else
        vClickType := mcDblRight;
    end else
    begin
      FLastClickTime := vTime;
      FLastClickPos  := vPoint;
      FLastClickType := vClickType;
    end;

    vShifts := [];
    if GetKeyState(VK_SHIFT) < 0 then
      Include(vShifts, ksShift);
    if GetKeyState(VK_CONTROL) < 0 then
      Include(vShifts, ksControl);
    if GetKeyState(VK_MENU) < 0 then
      Include(vShifts, ksAlt);

    vHotSpot := HitTest(vPoint.X, vPoint.Y, vKind, vIndex);
    if {not vRButton and} (vHotSpot = hsTab) then
      SetPressed(vKind, vIndex);
    vPressed := True;
    try

      while (GetKeyState(VK_LBUTTON) < 0) or (GetKeyState(VK_RBUTTON) < 0) do begin
        Sleep(10);
        vPoint1 := GetConsoleMousePos;
        if (vPoint1.X <> vPoint.X) or (vPoint1.Y <> vPoint.Y) then begin
          vPoint := vPoint1;
          vHotSpot1 := HitTest(vPoint1.X, vPoint1.Y, vKind1, vIndex1);
          vPressed := (vHotSpot = vHotSpot1) and (vKind = vKind1) and (vIndex = vIndex1);
          if vPressed then begin
            if {not vRButton and} (vHotSpot = hsTab) then
              SetPressed(vKind, vIndex);
          end else
            SetPressed(tkCommon, -1);
        end;
      end;

      { Чтобы выбрать событие отпускания мыши (?)... }
//    if vRButton then
        CheckForEsc;

      if vPressed then begin

        vAction := FindActions(vHotSpot, vClickType, vShifts);

        if vAction <> nil then
          ClickAction(vAction.FAction, vKind, vIndex)
        else begin
          case vHotSpot of
            hsTab:
              if vClickType in [mcLeft, mcDblLeft] then begin
                if GetKeyState(VK_Shift) < 0 then
                  ClickAction(taPSelect, vKind, vIndex)
                else
                  ClickAction(taSelect, vKind, vIndex)
              end else
              if vClickType = mcRight then
                ClickAction(taEdit, vKind, vIndex);
            hsButtom:
              if vClickType = mcLeft then begin
                if GetKeyState(VK_Shift) < 0 then
                  ClickAction(taPAdd, vKind, -1)
                else
                  ClickAction(taAdd, vKind, -1)
              end else
              if vClickType = mcRight then
                ClickAction(taList, vKind, -1);
            hsPanel:
              if vClickType = mcRight then
                ClickAction(taMainMenu, vKind, -1);
          end;
        end;
      end;

    finally
      SetPressed(tkCommon, -1);
    end;
  end;

 {$endif bUseProcessConsoleInput}


  procedure TTabsManager.RunCommand(const ACmd :TString);
  var
    vPos :Integer;
    vCmd, vParam :TString;
  begin
    vCmd := ACmd;
    vPos := ChrPos('=', ACmd);
    if vPos <> 0 then begin
      vCmd := Copy(ACmd, 1, vPos - 1);
      vParam := Copy(ACmd, vPos + 1, MaxInt);
    end;

    if StrEqual(vCmd, cAddCmd) then
      AddTab(True)
    else
    if StrEqual(vCmd, cEditCmd) then
      ListTab(True)
    else
    if StrEqual(vCmd, cSaveCmd) then
      GetTabs(True).StoreFile(vParam)
    else
    if StrEqual(vCmd, cLoadCmd) then begin
      with GetTabs(True) do begin
        RestoreFile(vParam);
        StoreReg('');
        PaintTabs;
      end;
    end else
      AppErrorIdFmt(strUnknownCommand, [ACmd]);
  end;


initialization
finalization
  FreeObj(TabsManager);
end.


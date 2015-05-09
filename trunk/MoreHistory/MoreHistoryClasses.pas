{$I Defines.inc}

unit MoreHistoryClasses;

{******************************************************************************}
{* (c) 2009-2011, Max Rusov                                                   *}
{*                                                                            *}
{* MoreHistory plugin                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    ShlObj,
    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMatch,
    FarConMan,
    FarMenu,
    FarColorDlg,
    FarConfig,

    MoreHistoryOptionsDlg,
    MoreHistoryCtrl;


  type
    THistoryEntryClass = class of THistoryEntry;

    THistoryEntry = class(TBasis)
    public
      constructor CreateEx(const APath :TString);
      destructor Destroy; override;

      procedure SetFlags(AFlags :Cardinal);

      function GetDomain :TString; virtual;
      function GetGroup(ASort :Integer) :TString; virtual;
      function GetNameWithoutDomain(var ADelta :Integer) :TString; virtual;

      function CalcSize :Integer; virtual;
      procedure WriteTo(var APtr :Pointer1); virtual;
      procedure ReadFrom(var APtr :Pointer1; AVersion :Integer); virtual;
      function IsValid :Boolean; virtual;

      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

    private
      FPath  :TString;
      FTime  :TDateTime;
      FFlags :Cardinal;
      FAvail :Integer;         { Для поддержки недоступных путей (не сохраняется) }

    public
      property Path :TString read FPath;
      property Time :TDateTime read FTime;
      property Flags :Cardinal read FFlags;
      property Avail :Integer read FAvail write FAvail;
    end;


    TFldHistoryEntry = class(THistoryEntry)
    public
      procedure HitInfoClear;

      function IsActive :Boolean;
//    function IsTranzit :Boolean;
      procedure SetFinal(AOn :Boolean);
      function GetDomain :TString; override;
      function GetGroup(ASort :Integer) :TString; override;
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

      function CalcSize :Integer; override;
      procedure WriteTo(var APtr :Pointer1); override;
      procedure ReadFrom(var APtr :Pointer1; AVersion :Integer); override;
      function IsValid :Boolean; override;

    private
      FHits      :Integer;     { Количество обращений к каталогу }
      FActTime   :TDateTime;   { Время последнего активного действие }
      FActCount  :Integer;     { Количество активных действий }
      FItemName  :TString;     { Текущий элемент панели (не сохраняется) }

    public
      property Hits :Integer read FHits;
      property ActTime :TDateTime read FActTime;
      property ActCount :Integer read FActCount;
      property ItemName :TString read FItemName;
    end;


    TEdtHistoryEntry = class(THistoryEntry)
    public
      function GetDomain :TString; override;
      function GetGroup(ASort :Integer) :TString; override;
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;

      function CalcSize :Integer; override;
      procedure WriteTo(var APtr :Pointer1); override;
      procedure ReadFrom(var APtr :Pointer1; AVersion :Integer); override;
      function IsValid :Boolean; override;

    private
//    FPath      :TString;     { Имя файла }
//    FTime      :TDateTime;   { Время последнего доступа }
//    FFlags     :Integer;     { Редактирование/просмотр/флаги }
      FHits      :Integer;     { Количество открытий файла }
      FEdtTime   :TDateTime;   { Время последней модификации }
      FSaveCount :Integer;     { Количество сохранений файла }
      FModRow    :Integer;     { Место последней модификации }
      FModCol    :Integer;     { -/-/- }
      FEncoding  :Word;        { Кодировка }

//    FEdtRow    :Integer;     { Место последнего редактирования (не сохраняется) }
//    FEdtCol    :Integer;

    public
      property Hits :Integer read FHits;
      property EdtTime :TDateTime read FEdtTime;
      property ModRow :Integer read FModRow;
      property ModCol :Integer read FModCol;
      property SaveCount :Integer read FSaveCount;
    end;


   {$ifdef bCmdHistory}
    TCmdHistoryEntry = class(THistoryEntry)
    public
      procedure HitInfoClear;

      function CalcSize :Integer; override;
      procedure WriteTo(var APtr :Pointer1); override;
      procedure ReadFrom(var APtr :Pointer1; AVersion :Integer); override;
      function IsValid :Boolean; override;

      function GetDomain :TString; override;
      function GetNameWithoutDomain(var ADelta :Integer) :TString; override;
      function GetGroup(ASort :Integer) :TString; override;

      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;
      
    private
      FHits  :Integer;

    public
      property Hits :Integer read FHits;
    end;
   {$endif bCmdHistory}


    TFilterMask = class(TBasis)
    public
      constructor CreateEx(const AMask :TString; AXlat, AExact :Boolean);
      destructor Destroy; override;
      function Check(const AStr :TString; var APos, ALen :Integer) :Boolean;

    private
      FSubMasks :TObjList;
      FMask     :TString;     { Исходная маска }
      FXMask    :TString;     { Маска после XLat преобразования }
      FExact    :Boolean;
      FRegExp   :Boolean;
      FNot      :Boolean;
      FFromBeg  :Boolean;
    end;


    { Базовый класс для историй }

    THistory = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure InitExclusion; virtual;

      procedure LockHistory;
      procedure UnlockHistory;
      function TryLockHistory :Boolean;

      procedure SetModified;
      function TryLockAndStore :Boolean;
      procedure StoreModifiedHistory;
      procedure LoadModifiedHistory;
      function GetHistoryFileForRead :TString; virtual;

      procedure DeleteAt(AIndex :Integer);
      procedure ClearAvail;

    protected
      function CheckExclusion(const APath :TString) :Boolean; virtual;

      function GetHistoryFolder :TString; virtual;
      function StoreHistory :Boolean; {virtual;}
      function RestoreHistory(const AFileName :TString) :Boolean; {virtual;}

      function GetAddHeaderSize :Integer; virtual;
      procedure WriteAddHeaderTo(APtr :Pointer1; ASize :Integer); virtual;
      procedure ReadAddHeaderFrom(APtr :Pointer1; ASize :Integer; AVersion :Integer); virtual;

    private
      FCSLock     :TRTLCriticalSection;
      FVersion    :Byte;
      FFileName   :TString;
      FItemClass  :THistoryEntryClass;
      FHistory    :TObjList;
      FModified   :Boolean;
      FLastTime   :Integer;
      FExclusions :TFilterMask;
      FRevision   :Integer;

      function GetItems(AIndex :Integer) :THistoryEntry;

    public
      property Modified :Boolean read FModified;
      property History :TObjList read FHistory;
      property Items[I :Integer] :THistoryEntry read GetItems; default;
      property Revision :Integer read FRevision;
    end;


    { История папок }

    TFldAction = (
      faEnter,
      faReturn,
      faActivity
    );

    TFldHistory = class(THistory)
    public
      constructor Create; override;

      procedure InitExclusion; override;

      procedure AddCurrentToHistory;
      procedure RememberCurrentPos;
      procedure AddHistory(const APath :TString; Action :TFldAction);

      function GetHistoryFileForRead :TString; override;

    private
      procedure AddHistoryStr(const APath :TString; Action :TFldAction);
    end;


    { История редактора }

    TEdtAction = (
      eaOpenView,
      eaOpenEdit,
      eaSaveEdit,
      eaGotFocus,
      eaModify
    );

    TEdtHistory = class(THistory)
    public
      constructor Create; override;
      procedure InitExclusion; override;
      procedure AddHistory(const AName :TString; Action :TEdtAction; ARow, ACol :Integer);
    end;


    { История команд }

   {$ifdef bCmdHistory}
    TCmdHistory = class(THistory)
    public
      constructor Create; override;
      procedure InitExclusion; override;
      procedure UpdateHistory;

      function CmdLineFilter(const AStr :TString) :TString;
      procedure CmdLineNext(AForward :Boolean; const AStr :TString);

    protected
      function CheckExclusion(const APath :TString) :Boolean; override;
      function GetAddHeaderSize :Integer; override;
      procedure WriteAddHeaderTo(APtr :Pointer1; ASize :Integer); override;
      procedure ReadAddHeaderFrom(APtr :Pointer1; ASize :Integer; AVersion :Integer); override;

    private
      FTimeStamp :TDateTime;
      FLastMask  :TString;
      FLastCmd   :TString;
      FLastIndex :Integer;

      procedure AddHistoryStr(const APath :TString; ATime :TDateTime);
    end;
   {$endif bCmdHistory}


  function GetConsoleTitleStr :TString;
  function GetCurrentPanelPath(ACheckWindow :Boolean = True) :TString;

  procedure JumpToPath(const APath, AFileName :TString; ASetPassive :Boolean = False; AAdd :Boolean = True);

  procedure OptionsMenu;

  var
    GLastAdded  :TString;  { Последняя добавленная папка, для опциональной фильтрации (optHideCurrent) }
    GSkipFolder :TString;  { Папка, которую не надо добавлять/двигать в истории (для GotoFolder) }
//  GSkipFile   :TString;  { Имя файла, которое не надо добавлять в историю команд (запущенное по ассоциации) }

  var
    FldHistory :TFldHistory;
    EdtHistory :TEdtHistory;
   {$ifdef bCmdHistory}
    CmdHistory :TCmdHistory;
   {$endif bCmdHistory}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..1024] of TChar;
  begin
    FillZero(vBuf, SizeOf(vBuf));
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;

    if ConManDetected then
      ConManClearTitle(Result);
  end;


 {$ifdef Far3}
  function GetPluginPath(AHandle :THandle) :TString;
  var
    vFrmt, vPrefix, vPath, vHost :TString;
  begin
    Result := '';

    vFrmt := FarPanelString(AHandle, FCTL_GETPANELFORMAT);
    vPrefix := FarPanelString(AHandle, FCTL_GETPANELPREFIX);
    vHost := FarPanelString(AHandle, FCTL_GETPANELHOSTFILE);
    vPath := FarPanelGetCurrentDirectory(AHandle);
   {$ifdef bTrace}
    TraceF('Format=%s, Prefix=%s, Path=%s, Host=%s', [vFrmt, vPrefix, vPath, vHost]);
   {$endif bTrace}

    if StrEqual(vPrefix, 'FTP') then begin
      if UpCompareSubStr('//Hosts', vFrmt) = 0 then
        Exit;
      Result := 'FTP:' + vFrmt;
      if Result[length(Result)] <> '/' then
        Result := Result + '/';
    end else
    if UpCompareSubStr('NetBox', vPrefix) = 0 then begin
      if StrEqual('NetBox', vFrmt) then
        Exit;
      Result := 'Netbox:' + vFrmt + vPath;
    end else
    if StrEqual(vFrmt, 'Network') then begin
      if (vPath = '') or (vPath[1] <> '\') then
        Exit;
      Result := 'NET:' + vPath;
    end else
    if (vPrefix <> '') and ((vHost <> '') or (vPath <> '')) then begin
      {Reg: Arc: Observe: SQLite:}
      Result := vPrefix;
      if vHost <> '' then
        Result := Result + ':' + vHost;
      if vPath <> '' then
        Result := Result + ':' + vPath;
    end;
  end;

 {$else}

  function GetPluginPath(AHandle :THandle) :TString;
  var
    vFrmt, vPath, vHost :TString;
  begin
    Result := '';

    vFrmt := FarPanelString(AHandle, FCTL_GETPANELFORMAT);
    vHost := FarPanelString(AHandle, FCTL_GETPANELHOSTFILE);
    vPath := FarPanelGetCurrentDirectory(AHandle);

   {$ifdef bTrace}
//  TraceF('Format=%s, Path=%s, Host=%s', [vFrmt, vPath, vHost]);
   {$endif bTrace}

    if UpCompareSubStr('//', vFrmt) = 0  then begin
      {FTP плагин}
      if UpCompareSubStr('//Hosts', vFrmt) = 0 then
        Exit;
      Result := 'FTP:' + vFrmt;
      if Result[length(Result)] <> '/' then
        Result := Result + '/';
    end else
    if StrEqual(vFrmt, 'NETWORK') then begin
      if (vPath = '') or (vPath[1] <> '\') then
        Exit;
      Result := 'NET:' + vPath;
    end else
    if (vFrmt <> '') and (vHost = '')
//    StrEqual(vFrmt, 'REG') or
//    StrEqual(vFrmt, 'REG2') or
//    StrEqual(vFrmt, 'PDA') or
//    StrEqual(vFrmt, 'PPC')
    then
      { "Правильные" плагины }
      Result := vFrmt + ':' + vPath;
  end;
 {$endif Far3}


  function GetCurrentPanelPath(ACheckWindow :Boolean = True) :TString;
  var
    vWinInfo :TWindowInfo;
    vPanInfo :TPanelInfo;
  begin
    Result := '';
    if ACheckWindow then begin
      FarGetWindowInfo(-1, vWinInfo);
      if vWinInfo.WindowType <> WTYPE_PANELS then
        Exit;
    end;

    if not FarGetPanelInfo(PANEL_ACTIVE, vPanInfo) then
      Exit;
    if (vPanInfo.PanelType <> PTYPE_FILEPANEL) or not IsVisiblePanel(vPanInfo) then
      Exit;

    if not IsPluginPanel(vPanInfo) {or (PFLAGS_REALNAMES and vPanInfo.Flags <> 0)} then
      Result := FarPanelGetCurrentDirectory(PANEL_ACTIVE)
    else
      Result := GetPluginPath(PANEL_ACTIVE
//      , {$ifdef Far3} PFLAGS_SHORTCUT and vPanInfo.Flags <> 0 {$else} False {$endif Far3}
      );
  end;


(*
  function GetCurrentPanelItem :TString;
  var
    vWinInfo :TWindowInfo;
  begin
    Result := '';
    FarGetWindowInfo(-1, vWinInfo);
    if vWinInfo.WindowType <> WTYPE_PANELS then
      Exit;
    Result := FarPanelGetCurrentItem(True);
  end;
*)

  function GetSpecialFolder(FolderType :Integer) :TString;
  var
    pidl :PItemIDList;
    buf  :array[0..MAX_PATH] of TChar;
  begin
    Result := '';
    if SHGetSpecialFolderLocation(0, FolderType, pidl) = NOERROR then begin
      SHGetPathFromIDList(pidl, buf);
      Result := buf;
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure FarPanelSetPath(AHandle :THandle; const APath, AItem :TString);
  var
    vOldPath :TFarStr;
  begin
    vOldPath := FarPanelGetCurrentDirectory(AHandle);
    if not StrEqual(vOldPath, APath) then begin
      FarPanelSetDir(AHandle, APath);
      if AItem = '' then
        FARAPI.Control(AHandle, FCTL_REDRAWPANEL, 0, nil);
    end;

    if AItem <> '' then
      FarPanelSetCurrentItem(AHandle = PANEL_ACTIVE, AItem)
  end;


  procedure JumpToPath(const APath, AFileName :TString; ASetPassive :Boolean = False; AAdd :Boolean = True);
  var
    vHandle :THandle;
    vWinInfo :TWindowInfo;
    vInfo :TPanelInfo;
    vMacro, vStr :TString;
    vVisible, vRealFolder :Boolean;
  begin
    FldHistory.RememberCurrentPos;
    if AAdd then
      FldHistory.AddHistoryStr( APath, faReturn )
    else
      GSkipFolder := APath;

    vHandle := HandleIf(ASetPassive, PANEL_PASSIVE, PANEL_ACTIVE);

    FarGetWindowInfo(-1, vWinInfo);
    FarGetPanelInfo(vHandle, vInfo);
    vVisible := IsVisiblePanel(vInfo);
    vRealFolder := IsFullFilePath(APath);

    if vRealFolder and vVisible and (vInfo.PanelType = PTYPE_FILEPANEL) then begin
      { Установка каталога и файла через API }
      FarPanelSetPath(vHandle, APath, AFileName);

      if vWinInfo.WindowType <> WTYPE_PANELS then
        { Макросом переходим на панель... }
        FarPostMacro(FarKeyToMacro('F12 0'));

    end else
    begin
      { ...или через макрос }
      vMacro := '';

      case vInfo.PanelType of
        PTYPE_FILEPANEL:
          if not vVisible then
            vMacro := FarKeyToMacro('CtrlP');
        PTYPE_TREEPANEL:
          vMacro := FarKeyToMacro('CtrlT');
        PTYPE_QVIEWPANEL:
          vMacro := FarKeyToMacro('CtrlQ');
        PTYPE_INFOPANEL:
          vMacro := FarKeyToMacro('CtrlL');
      end;

      if vRealFolder then begin
        vMacro := vMacro + ' ' +
          'Panel.SetPath(' +
            StrIf(ASetPassive, '1', '0') + ', ' +
            FarStrToMacro(APath) +
            StrIf(AFileName <> '', ', ' + FarStrToMacro(AFileName), '') +
          ')';
      end else
      begin
        vStr := '';
        FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(vStr));

        vMacro := vMacro +
         {$ifdef Far3}
          'Far.DisableHistory(1) ' +
         {$endif Far3}
          'print(' + FarStrToMacro(APath) + ') ' + FarKeyToMacro('Enter');
        if ASetPassive then
          vMacro := FarKeyToMacro('Tab') + ' ' + vMacro + ' ' + FarKeyToMacro('Tab');
        if AFileName <> '' then
          vMacro := vMacro + ' ' +
            'Panel.SetPos(' + StrIf(ASetPassive, '1', '0') + ', ' + FarStrToMacro(AFileName) + ')';
      end;

      if vWinInfo.WindowType <> WTYPE_PANELS then
        vMacro := FarKeyToMacro('F12 0') + ' ' +
         {$ifdef Far3}
          'if (Area.Shell) then ' + vMacro + ' end';
         {$else}
          '$if (Shell) ' + vMacro + ' $end';
         {$endif Far3}

      FarPostMacro(vMacro);
    end;
  end;


 {-----------------------------------------------------------------------------}

  function NumMode(ANum :Integer) :Integer;
    {-Для сопряжения числительных }
  const
    cModes :array[0..9] of Integer = (3, 4, 2, 2, 2, 3, 3, 3, 3, 3);
  begin
    if ANum = 1 then
      Result := 1
    else begin
      ANum := ANum mod 100;
      if (ANum > 10) and (ANum < 20) then
        Result := 3
      else
        Result := cModes[ANum mod 10];
    end;
  end;


  function NumToRangeStr(ANum :Integer) :TString;
  begin
    if ANum < 0 then
      Result := '< 0'
    else
    if ANum = 0 then
      Result := '0'
    else
    if ANum < 10 then
      Result := '1 - 9'
    else
    if ANum < 100 then
      Result := '10 - 99'
    else
    if ANum < 1000 then
      Result := '100 - 999'
    else
    if ANum < 10000 then
      Result := '1000 - 9999'
    else
      Result := '>= 10K';
  end;


  function DateToRangeStr(ADateTime :TDateTime; AByPeriod :Boolean) :TString;
  const
    cDays :array[1..4] of TMessages = (strDays1, strDays2, strDays5, strDays21);
  var
    vDate0, vDateI, vDays :Integer;
    vDateW0, vDateM0, vDateY0 :Integer;
    vYear, vMonth, vDay :Word;
  begin
    if ADateTime = 0 then begin
      Result := GetMsgStr(strNever);
      Exit;
    end;

    vDate0 := Trunc(Now - EncodeTime(optMidnightHour, 0, 0, 0));
    vDateI := Trunc(ADateTime - EncodeTime(optMidnightHour, 0, 0, 0));

    if not AByPeriod then begin
      vDays := vDate0 - vDateI;

      if vDays = 0 then
        Result := GetMsgStr(strToday)
      else
      if vDays > 0 then
        Result := Int2Str(vDays) + ' ' + Format(GetMsgStr(strDaysAgo), [GetMsgStr(cDays[NumMode(vDays)])])
      else
        Result := Int2Str(vDays) + ' ' + Format(GetMsgStr(strDaysForward), [GetMsgStr(cDays[NumMode(-vDays)])]);

      Result := Result + ', ' + FormatDate('ddd dd', Trunc(vDateI));

    end else
    begin
      DecodeDate(vDate0, vYear, vMonth, vDay);

      { День начала... }
      vDateW0 := vDate0 - DayOfWeek(vDate0) + 1;       {...текущей недели }
      vDateM0 := Trunc(EncodeDate(vYear, vMonth, 1));  {...текущего месяца }
      vDateY0 := Trunc(EncodeDate(vYear, 1, 1));       {...текущего года }

      if vDateI > vDate0 then
        Result := GetMsgStr(strFuture)
      else
      if vDateI = vDate0 then
        Result := GetMsgStr(strToday)
      else
      if vDateI = vDate0 - 1 then
        Result := GetMsgStr(strYesterday)
      else
      if vDateI >= vDateW0 then
        Result := GetMsgStr(strThisWeek)
      else
      if vDateI >= vDateM0 then
        Result := GetMsgStr(strThisMonth)
      else
      if vDateI >= vDateY0 then
        Result := GetMsgStr(strThisYear)
      else
        Result := GetMsgStr(strPastYears);

      if (vDateI = vDate0) or (vDateI = vDate0 - 1) then
        Result := Result + ', ' + FormatDate('ddd dd', Trunc(vDateI));
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure OptionsMenu;
  var
    vMenu :TFarMenu;
    vChanged :Boolean;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle) {GetMsg(strOptionsTitle2)},
    [
      GetMsg(strMGeneralOptions),
      '',
      GetMsg(strMFldExclusions),
      GetMsg(strMEdtExclusions),
      GetMsg(strMCmdExclusions),
      '',
      GetMsg(strMColors)
    ]);
    try
      vChanged := False;
      vMenu.Help := 'Options';
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0: OptionsDlg;

          2:
            if FarInputBox(GetMsg(strFldExclTitle), GetMsg(strExclPrompt), optFldExclusions) then
              FldHistory.InitExclusion;
          3:
            if FarInputBox(GetMsg(strEdtExclTitle), GetMsg(strExclPrompt), optEdtExclusions) then
              EdtHistory.InitExclusion;
          4:
           {$ifdef bCmdHistory}
            if FarInputBox(GetMsg(strCmdExclTitle), GetMsg(strExclPrompt), optCmdExclusions) then
              CmdHistory.InitExclusion;
           {$else}
            Sorry;
           {$endif bCmdHistory}

          6: ColorMenu;
        end;

        vChanged := True;
      end;

      if vChanged then
        WriteSetup('');

    finally
      FreeObj(vMenu);
    end;
  end;

 {-----------------------------------------------------------------------------}
 { THistoryEntry                                                               }
 {-----------------------------------------------------------------------------}

  constructor THistoryEntry.CreateEx(const APath :TString);
  begin
    Create;
    FPath := APath;
    FTime := Now;
  end;


  destructor THistoryEntry.Destroy; {override;}
  begin
//  TraceF('THistoryEntry.Destroy %s', [FPath]);
    inherited Destroy;
  end;


  function THistoryEntry.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := UpCompareStr(FPath, TString(Key));
  end;


  function THistoryEntry.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    Result := 0;
    case Context of
      1 : Result := UpCompareStr(FPath, THistoryEntry(Another).Path);
      2 : Result := DateTimeCompare(FTime, THistoryEntry(Another).Time);
    end;
  end;


  function THistoryEntry.GetGroup(ASort :Integer) :TString; {virtual;}
  begin
    Result := '';
    case Abs(ASort) of
      0, 2: { By time }
        Result := DateToRangeStr(FTime, opdGroupByPeriod);
      1: { By name }
        Result := GetDomain;
    end;
  end;


  procedure THistoryEntry.SetFlags(AFlags :Cardinal);
  begin
    FFlags := AFlags;
  end;


  function THistoryEntry.GetDomain :TString; {virtual;}
  begin
    Result := '';
  end;


  function THistoryEntry.GetNameWithoutDomain(var ADelta :Integer) :TString; {virtual;}
  begin
//  ADelta := 0;
//  Result := FPath;

    ADelta := IntMin(length(GetDomain), length(FPath));
    Result := Copy(FPath, ADelta + 1, MaxInt);
  end;



  function THistoryEntry.CalcSize :Integer; {virtual;}
  begin
    Result := SizeOf(Word) + Length(FPath) * SizeOf(TChar) + SizeOf(FTime) {+ SizeOf(FHits) + Sizeof(FFlags)};
  end;


  procedure THistoryEntry.WriteTo(var APtr :Pointer1); {virtual;}
  var
    vLen :Integer;
  begin
    vLen := Length(FPath);
    PWord(APtr)^ := vLen;
    Inc(APtr, SizeOf(Word));
    Move(PTChar(FPath)^, APtr^, vLen * SizeOf(TChar));
    Inc(APtr, vLen * SizeOf(TChar));

    Move(FTime, APtr^, SizeOf(TDateTime));
    Inc(APtr, SizeOf(TDateTime));
  end;


  procedure THistoryEntry.ReadFrom(var APtr :Pointer1; AVersion :Integer); {virtual;}
  var
    vLen :Integer;
  begin
    vLen := PWord(APtr)^;
    Inc(APtr, SizeOf(Word));
    SetString(FPath, PTChar(APtr), vLen);
    Inc(APtr, vLen * SizeOf(TChar));

    Move(APtr^, FTime, SizeOf(TDateTime));
    Inc(APtr, SizeOf(TDateTime));
  end;


  function THistoryEntry.IsValid :Boolean; {virtual;}
  begin
    Result := True;
  end;


 {-----------------------------------------------------------------------------}
 { TFldHistoryEntry                                                            }
 {-----------------------------------------------------------------------------}

  procedure TFldHistoryEntry.HitInfoClear;
  begin
    FHits := 0;
    FActCount := 0;
  end;


  function TFldHistoryEntry.IsActive :Boolean;
  begin
    Result := FActTime <> 0;
  end;


//function TFldHistoryEntry.IsTranzit :Boolean;
//begin
//  Result := FActTime < FTime;
//end;


  procedure TFldHistoryEntry.SetFinal(AOn :Boolean);
  begin
    if AOn then
//    FFlags := FFlags or hfFinal
      FActTime := Now
    else
//    FFlags := FFlags and not hfFinal;
      FActTime := 0;
  end;


  function TFldHistoryEntry.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    case Context of
      3: Result := IntCompare(FHits, TFldHistoryEntry(Another).Hits);
      4: Result := DateTimeCompare(FActTime, TFldHistoryEntry(Another).ActTime);
      5: Result := IntCompare(FActCount, TFldHistoryEntry(Another).ActCount);
    else
      Result := inherited CompareObj(Another, Context);
    end;
  end;


  function TFldHistoryEntry.GetGroup(ASort :Integer) :TString; {override;}
  begin
    case Abs(ASort) of
      3: Result := NumToRangeStr(FHits);
      4: Result := DateToRangeStr(FActTime, opdGroupByPeriod);
      5: Result := NumToRangeStr(FActCount);
    else
      Result := inherited GetGroup(ASort);
    end;
  end;


  function TFldHistoryEntry.GetDomain :TString; {override;}
  begin
    if IsFullFilePath(FPath) then begin
      if UpCompareSubStr('\\', FPath) = 0 then
        Result := ExtractFileDrive(FPath)
      else begin
        Result := ExtractWords(1, 2, FPath, ['\']);
        if StrEqual(Result, FPath) then
          Result := ExtractFileDrive(FPath);
        Result := Result + '\';
      end;
    end else
//  if UpCompareSubStr('REG:', FPath) = 0 then
//    Result := ''
//  else
    if UpCompareSubStr('FTP:', FPath) = 0 then
      Result := ExtractWords(1, 2, FPath, ['/']) {+ '/'}
    else
    if UpCompareSubStr('PPC:', FPath) = 0 then
      Result := ExtractWords(1, 2, FPath, [':']) + ':'
    else
    if UpCompareSubStr('PDA:', FPath) = 0 then
      Result := ExtractWord(1, FPath, [':']) + ':\'
    else
      Result := ExtractWord(1, FPath, [':']) + ':';
  end;


  function TFldHistoryEntry.CalcSize :Integer; {override;}
  begin
    Result := inherited CalcSize + SizeOf(FHits) + Sizeof(FFlags) + SizeOf(FActTime) + SizeOf(FActCount);
  end;


  procedure TFldHistoryEntry.WriteTo(var APtr :Pointer1); {override;}
  begin
    inherited WriteTo(APtr);

    PInteger(APtr)^ := FHits;
    Inc(APtr, SizeOf(Integer));

    PInteger(APtr)^ := FFlags;
    Inc(APtr, SizeOf(Integer));

    Move(FActTime, APtr^, SizeOf(TDateTime));
    Inc(APtr, SizeOf(TDateTime));

    PInteger(APtr)^ := FActCount;
    Inc(APtr, SizeOf(Integer));
  end;


  procedure TFldHistoryEntry.ReadFrom(var APtr :Pointer1; AVersion :Integer); {override;}
  begin
    inherited ReadFrom(APtr, AVersion);

    FHits := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));

    FFlags := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));

    if AVersion > 1 then begin
      Move(APtr^, FActTime, SizeOf(TDateTime));
      Inc(APtr, SizeOf(TDateTime));

      FActCount := PInteger(APtr)^;
      Inc(APtr, SizeOf(Integer));
    end else
    begin
      if FFlags and hfFinal_Old <> 0 then begin
        FActTime := FTime;
        FActCount := FHits; {?}
      end;
      FFlags := 0;
    end;
  end;


  function TFldHistoryEntry.IsValid :Boolean; {override;}
  begin
//  FPath := PTChar(FPath);
    Result := FPath <> '';
  end;


 {-----------------------------------------------------------------------------}
 { TEdtHistoryEntry                                                            }
 {-----------------------------------------------------------------------------}

  function TEdtHistoryEntry.GetDomain :TString; {override;}
  begin
    Result := ExtractFilePath(FPath);
  end;


  function TEdtHistoryEntry.GetGroup(ASort :Integer) :TString; {override;}
  begin
    case Abs(ASort) of
      3:  Result := NumToRangeStr(FHits);
      4:  Result := DateToRangeStr(FEdtTime, opdGroupByPeriod);
      5:  Result := NumToRangeStr(FSaveCount);
    else
      Result := inherited GetGroup(ASort);
    end;
  end;


  function TEdtHistoryEntry.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    case Context of
      1 :
        if optSeparateName or not optShowFullPath then
          Result := UpCompareStr(ExtractFileName(FPath), ExtractFileName(THistoryEntry(Another).Path))
        else
          Result := UpCompareStr(FPath, THistoryEntry(Another).Path);

      3:  Result := IntCompare(FHits, TEdtHistoryEntry(Another).Hits);
      4:  Result := DateTimeCompare(FEdtTime, TEdtHistoryEntry(Another).EdtTime);
      5:  Result := IntCompare(FSaveCount, TEdtHistoryEntry(Another).SaveCount);
    else
      Result := inherited CompareObj(Another, Context);
    end;
  end;


  function TEdtHistoryEntry.CalcSize :Integer; {override;}
  begin
    Result := SizeOf(Word) + Length(FPath) * SizeOf(TChar) + SizeOf(FFlags) +
      SizeOf(FTime) + Sizeof(FHits) + SizeOf(FEdtTime) + SizeOf(FModRow) + SizeOf(FModCol) + Sizeof(FSaveCount) + SizeOf(FEncoding);
  end;


  procedure TEdtHistoryEntry.WriteTo(var APtr :Pointer1); {override;}
  var
    vLen :Integer;
  begin
    vLen := Length(FPath);
    PWord(APtr)^ := vLen;
    Inc(APtr, SizeOf(Word));
    Move(PTChar(FPath)^, APtr^, vLen * SizeOf(TChar));
    Inc(APtr, vLen * SizeOf(TChar));

    PInteger(APtr)^ := FFlags;
    Inc(APtr, SizeOf(Integer));

    Move(FTime, APtr^, SizeOf(FTime));
    Inc(APtr, SizeOf(FTime));

    PInteger(APtr)^ := FHits;
    Inc(APtr, SizeOf(Integer));

    Move(FEdtTime, APtr^, SizeOf(FEdtTime));
    Inc(APtr, SizeOf(FEdtTime));

    PInteger(APtr)^ := FModRow;
    Inc(APtr, SizeOf(Integer));

    PInteger(APtr)^ := FModCol;
    Inc(APtr, SizeOf(Integer));

    PInteger(APtr)^ := FSaveCount;
    Inc(APtr, SizeOf(Integer));

    PWord(APtr)^ := FEncoding;
    Inc(APtr, SizeOf(Word));
  end;


  procedure TEdtHistoryEntry.ReadFrom(var APtr :Pointer1; AVersion :Integer); {override;}
  var
    vLen :Integer;
  begin
    vLen := PWord(APtr)^;
    Inc(APtr, SizeOf(Word));
    SetString(FPath, PTChar(APtr), vLen);
    Inc(APtr, vLen * SizeOf(TChar));

    FFlags := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));

    Move(APtr^, FTime, SizeOf(FTime));
    Inc(APtr, SizeOf(FTime));

    FHits := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));

    Move(APtr^, FEdtTime, SizeOf(FEdtTime));
    Inc(APtr, SizeOf(FEdtTime));

    FModRow := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));

    if AVersion > 2 then begin
      FModCol := PInteger(APtr)^;
      Inc(APtr, SizeOf(Integer));
    end;

    if AVersion > 1 then begin
      FSaveCount := PInteger(APtr)^;
      Inc(APtr, SizeOf(Integer));

      FEncoding := PWord(APtr)^;
      Inc(APtr, SizeOf(Word));
    end;

//  FEdtRow := FModRow;
//  FEdtCol := FModCol;
  end;


  function TEdtHistoryEntry.IsValid :Boolean; {override;}
  begin
    Result := FPath <> '';
  end;


 {-----------------------------------------------------------------------------}
 { TCmdHistoryEntry                                                            }
 {-----------------------------------------------------------------------------}

 {$ifdef bCmdHistory}

  function TCmdHistoryEntry.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    {TODO: поддержать режим сравнения только командной строки...}
    if optCaseSensCmdHist = 0 then
      Result := UpCompareStr(FPath, TString(Key))
    else
      Result := CompareStr(FPath, TString(Key));
  end;


  function TCmdHistoryEntry.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    case Context of
      3: Result := IntCompare(Hits, TFldHistoryEntry(Another).Hits);
    else
      Result := inherited CompareObj(Another, Context);
    end;
  end;


  function TCmdHistoryEntry.GetGroup(ASort :Integer) :TString; {override;}
  begin
    case Abs(ASort) of
      3:  Result := NumToRangeStr(FHits);
    else
      Result := inherited GetGroup(ASort);
    end;
  end;


  function ExtractFileName(var AStr :PTChar) :TString;
  begin
    while AStr^ = ' ' do
      Inc(AStr);
    if AStr^ = '"' then
      Result := AnsiExtractQuotedStr(AStr, '"')
    else
      Result := ExtractNextWord(AStr, [' ']);
    while AStr^ = ' ' do
      Inc(AStr);
  end;


  function TCmdHistoryEntry.GetDomain :TString; {override;}
  var
    vPath :TString;
    vStr :PTChar;
    vPos :Integer;
  begin
    vStr := PTChar(FPath);
    vPath := ExtractFileName(vStr);

    vPos := ChrPos(':', vPath);
    if (vPos <> 0) and not FileNameIsLocal(vPath) then
      { Вызов плагина FAR через префикс }
      Result := copy(vPath, 1, vPos)
    else
    if (vStr^ <> #0) or ((ChrPos('.', vPath) = 0) and not IsFullFilePath(vPath)) then
      { Вызов команды (так как есть аргументы или не похоже(?) на имя файла) }
      Result := vPath
    else begin
      {!!!Localize}
      Result := 'Files/Folders';
    end;
  end;


  function TCmdHistoryEntry.GetNameWithoutDomain(var ADelta :Integer) :TString; {virtual;}
  begin
    ADelta := 0;
    Result := FPath;
  end;


  procedure TCmdHistoryEntry.HitInfoClear;
  begin
    FHits := 0;
  end;


  function TCmdHistoryEntry.CalcSize :Integer; {override;}
  begin
    Result := inherited CalcSize + SizeOf(FHits) + Sizeof(FFlags);
  end;


  procedure TCmdHistoryEntry.WriteTo(var APtr :Pointer1); {override;}
  begin
    inherited WriteTo(APtr);

    PInteger(APtr)^ := FHits;
    Inc(APtr, SizeOf(Integer));

    PInteger(APtr)^ := FFlags;
    Inc(APtr, SizeOf(Integer));
  end;


  procedure TCmdHistoryEntry.ReadFrom(var APtr :Pointer1; AVersion :Integer); {override;}
  begin
    inherited ReadFrom(APtr, AVersion);

    FHits := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));

    FFlags := PInteger(APtr)^;
    Inc(APtr, SizeOf(Integer));
  end;


  function TCmdHistoryEntry.IsValid :Boolean; {override;}
  begin
    Result := FPath <> '';
  end;
 {$endif bCmdHistory}


 {-----------------------------------------------------------------------------}
 { TFilterMask                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFilterMask.CreateEx(const AMask :TString; AXlat, AExact :Boolean);
  var
    vPos :Integer;
    vStr :TString;
  begin
    Create;
    FExact := AExact;
    vPos := ChrPos('|', AMask);
    if vPos = 0 then begin
      FMask := AMask;
      if (FMask <> '') and (FMask[1] = '^') then begin
        FFromBeg := True;
        Delete(FMask, 1, 1);
        if (FMask = '') or (FMask[Length(FMask)] <> '*') then
          FMask := FMask + '*';
      end;
      if (FMask <> '') and (FMask[1] = '!') then begin
        FNot := True;
        Delete(FMask, 1, 1);
      end;
      FRegExp := (ChrPos('*', FMask) <> 0) or (ChrPos('?', FMask) <> 0);
      if FRegExp and not AExact and (FMask[Length(FMask)] <> '*') {and (FMask[Length(FMask)] <> '?')} then
        FMask := FMask + '*';
        
      if AXlat then
        FXMask := FarXLatStr(FMask);

    end else
    begin
      FSubMasks := TObjList.Create;
      vStr := AMask;
      repeat
        FSubMasks.Add( TFilterMask.CreateEx(Copy(vStr, 1, vPos - 1), AXlat, AExact) );
        vStr := Copy(vStr, vPos + 1, MaxInt);
        vPos := ChrPos('|', vStr);
      until vPos = 0;
      if vStr <> '' then
        FSubMasks.Add( TFilterMask.CreateEx(vStr, AXlat, AExact) );
    end;
  end;


  destructor TFilterMask.Destroy; {override;}
  begin
    FreeObj(FSubMasks);
    inherited Destroy;
  end;


  function TFilterMask.Check(const AStr :TString; var APos, ALen :Integer) :Boolean;
  var
    I :Integer;
    vOpt :TMatchOptions;
  begin
    if FSubMasks = nil then begin
      if FExact then
        Result := StringMatch(FMask, FXMask, PTChar(AStr), APos, ALen)
      else
      if FFromBeg then
        Result := StringMatch(FMask, FXMask, PTChar(AStr), APos, ALen, [moIgnoreCase, moWilcards])
      else begin
//      Result := ChrCheckXMask(FMask, FXMask, PTChar(AStr), FRegExp, APos, ALen);

        vOpt := [moIgnoreCase];
        if FRegExp then
          vOpt := vOpt + [moWilcards];

        vOpt := vOpt + [moWithin];
        if optMaskByWord and not ((FMask <> '') and (FMask[1] = '*')) then
          vOpt := vOpt + [moWordBegin];

        Result := StringMatch(FMask, FXMask, PTChar(AStr), APos, ALen, vOpt);
      end;
      if FNot then
        Result := not Result;
    end else
    begin
      Result := False;
      for I := 0 to FSubMasks.Count - 1 do
        if TFilterMask(FSubMasks[I]).Check(AStr, APos, ALen) then begin
          Result := True;
          Exit;
        end;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { THistory                                                                    }
 {-----------------------------------------------------------------------------}

  constructor THistory.Create; {override;}
  begin
    inherited Create;
    InitializeCriticalSection(FCSLock);
    FHistory := TObjList.Create;
    FLastTime := -1;
    InitExclusion;
  end;


  destructor THistory.Destroy; {override;}
  begin
    FreeObj(FExclusions);
    FreeObj(FHistory);
    DeleteCriticalSection(FCSLock);
    inherited Destroy;
  end;


  procedure THistory.InitExclusion; {virtual;}
  begin
    {Abstract}
  end;


  procedure THistory.LockHistory;
  begin
    EnterCriticalSection(FCSLock);
  end;


  procedure THistory.UnlockHistory;
  begin
    LeaveCriticalSection(FCSLock);
  end;


  function THistory.TryLockHistory :Boolean;
  begin
    Result := TryEnterCriticalSection(FCSLock);
  end;


  function THistory.CheckExclusion(const APath :TString) :Boolean; {virtual;}
  var
    vPos, vLen :Integer;
  begin
    Result := True;
    if FExclusions <> nil then
      Result := not FExclusions.Check(APath, vPos, vLen);
  end;


  procedure THistory.DeleteAt(AIndex :Integer);
  begin
    LockHistory;
    try
      FHistory.Delete(AIndex);
      SetModified;
    finally
      UnlockHistory;
    end;
  end;


  procedure THistory.ClearAvail;
  var
    i :Integer;
  begin
    for i := 0 to FHistory.Count - 1 do
      Items[I].Avail := 0;
  end;


  procedure THistory.SetModified;
  begin
    Inc(FRevision);
    FModified := True;
  end;


  function THistory.TryLockAndStore :Boolean;
  begin
    Result := False;
    if TryLockHistory then begin
      try
        try
          StoreModifiedHistory;
          Result := True;
        except
        end;
      finally
        UnlockHistory;
      end;
    end;
  end;


  procedure THistory.StoreModifiedHistory;
  begin
    if FModified then begin
      if StoreHistory then
        FModified := False;
    end;
  end;


  function THistory.GetHistoryFileForRead :TString; {virtual;}
  begin
    Result := AddFileName(GetHistoryFolder, FFileName);
  end;


  procedure THistory.LoadModifiedHistory;
  var
    vFileName :TString;
  begin
    vFileName := GetHistoryFileForRead;
    if FileAge(vFileName) <> FLastTime then
      RestoreHistory(vFileName);
  end;


  function THistory.GetHistoryFolder :TString;
  begin
    Result := StrExpandEnvironment(optHistoryFolder);
    if Result = '' then
      Result := AddFileName(GetSpecialFolder(CSIDL_APPDATA), cPluginFolder);
  end;


  function THistory.StoreHistory :Boolean;
  var
    I, vSize, vAddHeaderSize :Integer;
    vFolder, vFileName, vBackupFileName, vTmpFileName :TString;
    vMemory :Pointer;
    vPtr :Pointer1;
    vFile :Integer;
  begin
    Result := False;

    vFolder := GetHistoryFolder;
    vFileName := AddFileName(vFolder, FFileName);
    vTmpFileName := ChangeFileExtension(vFileName, '$$$');
    vBackupFileName  := ChangeFileExtension(vFileName, '~dat');

   {$ifdef bTrace}
    TraceF('Store history: %s', [vFileName]);
   {$endif bTrace}

    vMemory := nil;
    try
      { Подготавливаем данные к сохранению }

      LockHistory;
      try
        vAddHeaderSize := GetAddHeaderSize;

        vSize := SizeOf(cSignature) + SizeOf(Byte){Version} + SizeOf(Integer){AddHeaderSize} + vAddHeaderSize + SizeOf(Integer){Count};
        for I := 0 to FHistory.Count - 1 do
          Inc(vSize, Items[I].CalcSize);

        vMemory := MemAlloc(vSize);

        vPtr := vMemory;
        PInteger(vPtr)^ := Integer(cSignature);
        Inc(vPtr, SizeOf(Integer));

        PByte(vPtr)^ := FVersion;
        Inc(vPtr, SizeOf(Byte));

        PInteger(vPtr)^ := vAddHeaderSize;
        Inc(vPtr, SizeOf(Integer));
        WriteAddHeaderTo(vPtr, vAddHeaderSize);
        Inc(vPtr, vAddHeaderSize);

        PInteger(vPtr)^ := FHistory.Count;
        Inc(vPtr, SizeOf(Integer));

        for I := 0 to FHistory.Count - 1 do
          Items[I].WriteTo(vPtr);

        Assert(vPtr = Pointer1(vMemory) + vSize);

      finally
        UnlockHistory;
      end;

      { Сохраняем данные }

      if not WinFolderExists(vFolder) then
        if not CreateDir(vFolder) then
          Exit;

      vFile := FileCreate(vTmpFileName);
      if vFile < 0 then
        Exit;
      try
        try
          FileWrite(vFile, vMemory^, vSize);
        finally
          FileClose(vFile);
        end;

        if WinFileExists(vFileName) then begin
          { Бэкапим старый файл }
          if WinFileExists(vBackupFileName) then
            if not DeleteFile(vBackupFileName) then
              Exit;
          if not RenameFile(vFileName, vBackupFileName) then
            Exit;
        end;

        if RenameFile(vTmpFileName, vFileName) then begin
          FLastTime := FileAge(vFileName);
          Result := True;
        end;

      finally
        if not Result then
          DeleteFile(vTmpFileName);
      end;

    finally
      MemFree(vMemory)
    end;
  end;


  function THistory.RestoreHistory(const AFileName :TString) :Boolean;
  const
    cHeaderSize = SizeOf(Integer){Signature} + SizeOf(Byte){Version} + SizeOf(Integer){AddHeader} + SizeOf(Integer){Count};
  var
    I, vSize, vAddHeaderSize, vCount, vVersion :Integer;
    vPtr, vEnd :Pointer1;
    vFile :Integer;
    vMemory :Pointer;
    vEntry :THistoryEntry;
  begin
    Result := False;
    if not WinFileExists(AFileName) then
      Exit;

   {$ifdef bTrace}
    TraceF('Restore history: %s', [AFileName]);
   {$endif bTrace}

    vMemory := nil;
    try
      vFile := FileOpen(AFileName, fmOpenRead or fmShareDenyWrite);
      if vFile < 0 then
        Exit;
      try
        FLastTime := FileAge(AFileName);
        vSize := GetFileSize(vFile, nil);
        if vSize < cHeaderSize then
          Exit;
        vMemory := MemAlloc(vSize);
        if FileRead(vFile, vMemory^, vSize) <> vSize then
          Exit;
      finally
        FileClose(vFile);
      end;

      vPtr := vMemory;
      vEnd := vPtr + vSize;
      if PInteger(vPtr)^ <> Integer(cSignature) then
        Exit;
      Inc(vPtr, SizeOf(Integer));

      vVersion := PByte(vPtr)^;
      if vVersion > FVersion then
        Exit;
      Inc(vPtr, SizeOf(Byte));

      vAddHeaderSize := PInteger(vPtr)^;
      Inc(vPtr, SizeOf(Integer));
      ReadAddHeaderFrom(vPtr, vAddHeaderSize, vVersion);
      Inc(vPtr, vAddHeaderSize);

      vCount := PInteger(vPtr)^;
      Inc(vPtr, SizeOf(Integer));

      try
        FHistory.Clear;
        FHistory.Capacity := vCount;
        for I := 0 to vCount - 1 do begin
          if vPtr >= vEnd then
            Wrong;
          vEntry := FItemClass.Create;
          vEntry.ReadFrom(vPtr, vVersion);
          if vEntry.IsValid then
            FHistory.Add(vEntry)
          else
            FreeObj(vEntry);
        end;
        Assert(vPtr = vEnd);
        Inc(FRevision);

      except
        FHistory.Clear;
        raise
      end;

    finally
      MemFree(vMemory)
    end;
  end;


  function THistory.GetAddHeaderSize :Integer; {virtual;}
  begin
    Result := 0;
  end;

  procedure THistory.WriteAddHeaderTo(APtr :Pointer1; ASize :Integer); {virtual;}
  begin
  end;

  procedure THistory.ReadAddHeaderFrom(APtr :Pointer1; ASize :Integer; AVersion :Integer); {virtual;}
  begin
  end;


  function THistory.GetItems(AIndex :Integer) :THistoryEntry;
  begin
    Result := FHistory[AIndex];
  end;


 {-----------------------------------------------------------------------------}
 { TFldHistory                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TFldHistory.Create; {override;}
  begin
    inherited Create;
    FFileName  := cFldHistFileName;
    FVersion   := cFldVersion;
    FItemClass := TFldHistoryEntry;
  end;


  function TFldHistory.GetHistoryFileForRead :TString; {override;}
  begin
    { Переименовали файл истории, чтобы не терять ее, если случайно запустится старая версия плагина... }
    Result := AddFileName(GetHistoryFolder, FFileName);
    if not WinFileExists(Result) then
      Result := AddFileName(GetHistoryFolder, cFldHistFileName1);
  end;


  procedure TFldHistory.InitExclusion; {override;}
  begin
    FreeObj(FExclusions);
    if optFldExclusions <> '' then
      FExclusions := TFilterMask.CreateEx( optFldExclusions, False, True );
  end;


  procedure TFldHistory.AddCurrentToHistory;
  begin
    LockHistory;
    try
      LoadModifiedHistory;
      AddHistory( GetCurrentPanelPath, faActivity);
    finally
      UnlockHistory;
    end;
  end;


  procedure TFldHistory.AddHistory(const APath :TString; Action :TFldAction);
  begin
    GLastAdded := '';
    if (APath = '') or not CheckExclusion(APath) then
      Exit;

    if (* not AFinal and ??? *) (GSkipFolder <> '') and StrEqual(APath, GSkipFolder) then
      Exit;

    GSkipFolder := '';
    GLastAdded := APath;
    AddHistoryStr(APath, Action);
  end;


  procedure TFldHistory.AddHistoryStr(const APath :TString; Action :TFldAction);
  var
    vNow   :TDateTime;
    vIndex :Integer;
    vEntry :TFldHistoryEntry;
  begin
    LockHistory;
    try
//    TraceF('Add history: %s, %d', [APath, Byte(Action)]);
      vNow := Now;

      if FHistory.FindKey(Pointer(APath), 0, [], vIndex) then begin
        vEntry := FHistory[vIndex];
        if vIndex <> FHistory.Count - 1 then begin
          FHistory.Move(vIndex, FHistory.Count - 1);
          SetModified;
        end;
      end else
      begin
        vEntry := TFldHistoryEntry.CreateEx(APath);
        vEntry.FTime := Now;
        FHistory.Add(vEntry);

        if FHistory.Count > optHistoryLimit then
//        FHistory.DeleteRange(0, FHistory.Count - optHistoryLimit);
          FHistory.Delete(0); { Удаляем только один элемент, чтобы случайно не потерся большой кусок истории }
        SetModified;
      end;

      if Action in [faEnter{, faReturn}] then begin
        vEntry.FTime := vNow;
        Inc(vEntry.FHits);
      end;
      if Action in [faActivity, faReturn] then begin
        if vEntry.FActTime < vEntry.FTime then
          Inc(vEntry.FActCount);
        vEntry.FActTime := vNow;
      end;
      SetModified;

    finally
      UnlockHistory;
    end;
  end;


  procedure TFldHistory.RememberCurrentPos;
  var
    vPath, vItem :TString;
    vIndex :Integer;
    vEntry :TFldHistoryEntry;
  begin
    LockHistory;
    try
      vPath := GetCurrentPanelPath(False);
      if vPath = '' then
        Exit;

      vItem := FarPanelGetCurrentItem(True);
      if vItem = '' then
        Exit;

      if FHistory.FindKey(Pointer(vPath), 0, [], vIndex) then begin
//      TraceF('Remember: %s: %s', [vPath, vItem]);

        vEntry := FHistory[vIndex];
        vEntry.FItemName := vItem;
      end;

    finally
      UnlockHistory;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TEdtHistory                                                                 }
 {-----------------------------------------------------------------------------}

  constructor TEdtHistory.Create; {override;}
  begin
    inherited Create;
    FFileName := cEdtHistFileName;
    FVersion  := cEdtVersion;
    FItemClass := TEdtHistoryEntry;
  end;


  procedure TEdtHistory.InitExclusion; {override;}
  begin
    FreeObj(FExclusions);
    if optEdtExclusions <> '' then
      FExclusions := TFilterMask.CreateEx( StrExpandEnvironment(optEdtExclusions), False, True );
  end;


  procedure TEdtHistory.AddHistory(const AName :TString; Action :TEdtAction; ARow, ACol :Integer);
    { Action:  eaOpenView(0), eaOpenEdit(1), eaSaveEdit(2), eaGotFocus(3), eaModify(4) }
  var
    vNow   :TDateTime;
    vIndex :Integer;
    vEntry :TEdtHistoryEntry;
  begin
    LockHistory;
    try
//    TraceF('Add history: %s, %d', [AName, Byte(Action)]);

      if (AName = '') or not CheckExclusion(AName) then
        Exit;

      if FHistory.FindKey(Pointer(AName), 0, [], vIndex) then begin

        vNow := Now;
        vEntry := FHistory[vIndex];
        if vIndex <> FHistory.Count - 1 then begin
//        TraceF('Up: %s, %d', [APath, Byte(AFinal)]);
          FHistory.Move(vIndex, FHistory.Count - 1);
          SetModified;
        end;

        if Action = eaGotFocus then
          Exit;

        if Action in [eaOpenEdit, eaSaveEdit] then
          vEntry.FFlags := vEntry.FFlags or hfEdit;
        if Action in [eaOpenView, eaOpenEdit] then begin
          vEntry.FTime := vNow;
          Inc(vEntry.FHits);
        end;
        if Action = eaSaveEdit then begin
          vEntry.FEdtTime := vNow;
          Inc(vEntry.FSaveCount);
        end;
        if Action = eaModify then begin
          vEntry.FEdtTime := vNow;
          vEntry.FModRow := ARow;
          vEntry.FModCol := ACol;
        end;

        SetModified;
      end else
      begin
//      TraceF('Add: %s, %d', [APath, Byte(AFinal)]);
        vEntry := TEdtHistoryEntry.CreateEx(AName);

        vEntry.FHits := 1;
        if Action in [eaOpenEdit, eaSaveEdit] then
          vEntry.FFlags := vEntry.FFlags or hfEdit;
        if Action = eaSaveEdit then begin
          vEntry.FEdtTime := vEntry.Time;
          Inc(vEntry.FSaveCount);
        end;

        FHistory.Add(vEntry);
        if FHistory.Count > optHistoryLimit then
//        FHistory.DeleteRange(0, FHistory.Count - optHistoryLimit);
          FHistory.Delete(0); { Удаляем только один элемент, чтобы случайно не потерся большой кусок истории }
        SetModified;
      end;

    finally
      UnlockHistory;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TCmdHistory                                                                 }
 {-----------------------------------------------------------------------------}

 {$ifdef bCmdHistory}

  constructor TCmdHistory.Create; {override;}
  begin
    inherited Create;
    FFileName := cCmdHistFileName;
    FVersion  := cCmdVersion;
    FItemClass := TCmdHistoryEntry;
    FLastCmd := #0;
  end;


  procedure TCmdHistory.InitExclusion; {override;}
  begin
    FreeObj(FExclusions);
    if optCmdExclusions <> '' then
      FExclusions := TFilterMask.CreateEx( StrExpandEnvironment(optCmdExclusions), False, True );
  end;


  function TCmdHistory.CheckExclusion(const APath :TString) :Boolean; {override;}
  var
    vStr :PTChar;
    vName :TString;
  begin
    Result := inherited CheckExclusion(APath);

    if Result and optCmdExcludeFile then begin
      vStr := PTChar(APath);
      vName := ExtractFileName(vStr);
      if vStr^ = #0 then
        Result := (ChrsLastPos([':', '\'], vName) <> 0) or (ChrsLastPos(['.'], vName) = 0);
    end;
  end;

(*
  function TCmdHistoryEntry.GetDomain :TString; {override;}
  var
    vPath :TString;
    vStr :PTChar;
    vPos :Integer;
  begin
    vStr := PTChar(FPath);
    vPath := ExtractFileName(vStr);

    vPos := ChrPos(':', vPath);
    if (vPos <> 0) and not FileNameIsLocal(vPath) then
      { Вызов плагина FAR через префикс }
      Result := copy(vPath, 1, vPos)
    else
    if (vStr^ <> #0) or ((ChrPos('.', vPath) = 0) and not IsFullFilePath(vPath)) then
      { Вызов команды (так как есть аргументы или не похоже(?) на имя файла) }
      Result := vPath
    else begin
      {!!!Localize}
      Result := 'Files/Folders';
    end;
  end;
*)

  procedure TCmdHistory.UpdateHistory;
  var
    I :Integer;
    vHandle :THandle;
    vData :TFarSettingsEnum;
    vTime, vNow :TDateTime;
  begin
    LockHistory;
    try
      vHandle := FarOpenSetings(GUID_NULL);
      if vHandle = 0 then
        Exit;

      try
        FillZero(vData, SizeOf(vData));
        vData.StructSize := SizeOf(vData);
        vData.Root := FSSF_HISTORY_CMD;
        if FARAPI.SettingsControl(vHandle, SCTL_ENUM, 0, @vData) = 0 then
          Exit;

        vNow := Now + EncodeTime(0, 0, 1, 0);
        for I := 0 to Integer(vData.Count) - 1 do
          with vData.Value.Histories[I] do begin
            vTime := FileTimeToDateTime(Time);
            if (vTime > FTimeStamp) and (vTime <= vNow) then
              AddHistoryStr(Name, vTime);
          end;
        FTimeStamp := vNow; {???}

      finally
        FARAPI.SettingsControl(vHandle, SCTL_FREE, 0, nil);
      end;

    finally
      UnlockHistory;
    end;
  end;


  procedure TCmdHistory.AddHistoryStr(const APath :TString; ATime :TDateTime);
  var
    vIndex :Integer;
    vEntry :TCmdHistoryEntry;
  begin
//  TraceF('Add history: %s, %s', [DateTimeToStr(ATime), APath]);
    if (APath = '') or not CheckExclusion(APath) then
      Exit;

    if FHistory.FindKey(Pointer(APath), 0, [], vIndex) then begin
      vEntry := FHistory[vIndex];
      FHistory.Move(vIndex, FHistory.Count - 1);
      vEntry.FPath := APath;
      vEntry.FTime := ATime;
      Inc(vEntry.FHits);
      SetModified;
    end else
    begin
      vEntry := TCmdHistoryEntry.CreateEx(APath);
      vEntry.FTime := ATime;
      vEntry.FHits := 1;
      FHistory.Add(vEntry);
      if FHistory.Count > optHistoryLimit then
//      FHistory.DeleteRange(0, FHistory.Count - optHistoryLimit);
        FHistory.Delete(0); { Удаляем только один элемент, чтобы случайно не потерся большой кусок истории }
      SetModified;
    end;

    FLastCmd := #0;
  end;


  function TCmdHistory.GetAddHeaderSize :Integer; {virtual;}
  begin
    Result := SizeOf(TDateTime);
  end;

  procedure TCmdHistory.WriteAddHeaderTo(APtr :Pointer1; ASize :Integer); {virtual;}
  begin
    PDateTime(APtr)^ := FTimeStamp;
  end;

  procedure TCmdHistory.ReadAddHeaderFrom(APtr :Pointer1; ASize :Integer; AVersion :Integer); {virtual;}
  begin
    Assert(ASize = SizeOf(TDateTime));
    FTimeStamp := PDateTime(APtr)^;
  end;


  function TCmdHistory.CmdLineFilter(const AStr :TString) :TString;
  begin
    if AStr <> FLastCmd then
      Result := AStr
    else
      Result := FLastMask;
    if Result <> '' then
      Result := '^' + Result;  
  end;


  procedure TCmdHistory.CmdLineNext(AForward :Boolean; const AStr :TString);
  var
    i :Integer;
  begin
    CmdHistory.LoadModifiedHistory;
    CmdHistory.UpdateHistory;

    if AStr <> FLastCmd then begin
      FLastMask := AStr;

      FLastIndex := -1;
      for i := FHistory.Count - 1 downto 0 do
        if UpCompareSubStr(FLastMask, Items[i].Path) = 0 then begin
          FLastIndex := i;
          Break;
        end;

    end else
    begin
      i := FLastIndex;
      while True do begin
        if AForward then
          Inc(i)
        else
          Dec(i);
        if (i < 0) or (i >= FHistory.Count) then
          Break;
        if UpCompareSubStr(FLastMask, Items[i].Path) = 0 then
          Break;
      end;

      if (i >= 0) and (i < FHistory.Count) then
        FLastIndex := i
      else begin
        Beep;
        Exit;
      end;
    end;

    if (FLastIndex >= 0) and (FLastIndex < FHistory.Count) then begin
      FLastCmd := Items[FLastIndex].Path;
      FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_SETCMDLINE, 0, PFarChar(FLastCmd));
    end else
      Beep;
  end;

 {$endif bCmdHistory}


initialization
finalization
  FreeObj(FldHistory);
  FreeObj(EdtHistory);
 {$ifdef bCmdHistory}
  FreeObj(CmdHistory);
 {$endif bCmdHistory}
end.

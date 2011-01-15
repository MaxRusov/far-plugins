{$I Defines.inc}

unit MacroLibClasses;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Macro Library                                                          *}
{* Основные классы                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

    PluginW,
    FarCtrl,
    FarKeys,

    MacroLibConst,
    MacroParser;



  type
    TMacroLibrary = class;

    TMacro = class(TBasis)
    public
      constructor CreateBy(const ARec :TMacroRec; const AFileName :TString);
      destructor Destroy; override;

      function CheckCondition(Area :TMacroArea; AKey :Integer; ALib :TMacroLibrary) :Boolean;
      function CheckEventCondition(Area :TMacroArea; Event :TMacroEvent) :Boolean;
      function CheckArea(Area :TMacroArea) :Boolean;
      procedure Execute(AKeyCode :Integer);

      function GetBindAsStr(AMode :Integer) :TString;
      function GetAreaAsStr(AMode :Integer) :TString;
      function GetFileTitle(AMode :Integer) :TString;
      function GetSrcLink :TString;

    private
      FName     :TString;          { Имя макрокоманды }
      FDescr    :TString;          { Описание макрокоманды }
      FWhere    :TString;          { Условие запуска }
      FBind     :TIntArray;        { Список кнопок для запуска }
      FArea     :TMacroAreas;      { Маска макрообластей }
      FDlgs     :TGUIDArray;       { Список GUID-ов диалогов }
      FCond     :TMacroConditions; { Условия срабатывания }
      FEvents   :TMacroEvents;     { Список событий для запуска }
      FText     :TString;          { Текст макрокоманды }
      FOptions  :TMacroOptions;

      FFileName :TString;
      FRow      :Integer;
      FCol      :Integer;
      FIndex    :Integer;

    public
      property Name :TString read FName;
      property Descr :TString read FDescr;
//    property BindStr :TString read GetBindAsStr;
//    property AreaStr :TString read GetAreaAsStr;
      property Text :TString read FText;

      property FileName :TString read FFileName;
      property Row :Integer read FRow;
      property Col :Integer read FCol;
    end;


    TRunList = class(TExList)
    public
      KeyCode :Integer;
      RunAll  :Boolean;
    end;


    TMacroLibrary = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure RescanMacroses(ASilence :Boolean);
      function CheckHotkey(const ARec :TKeyEventRecord) :boolean;
      function CheckMouse(const ARec :TMouseEventRecord) :boolean;
      function CheckEvent(Area :TMacroArea; AEvent :TMacroEvent) :boolean;
      procedure ShowAvailable;
      procedure ShowAll;
      procedure ShowList(AList :TExList);

    private
      FMacroses    :TObjList;
      FNewMacroses :TObjList;
      FRevision    :Integer;
      FSilence     :Boolean;
      FLastKey     :DWORD;
      FMouseState  :DWORD;

      FWindowType  :Integer;
      FConditions  :TMacroConditions;

      procedure ScanMacroFolder(const AFolder :TString);
      function ParseMacroFile(const AFileName :TString) :boolean;

      procedure AddMacro(Sender :TMacroParser; const ARec :TMacroRec);
      procedure ParseError(Sender :TMacroParser; ACode :Integer; const AMessage :TString; const AFileName :TString; ARow, ACol :Integer);

      function CheckForRun(AKey :Integer; APress :Boolean) :boolean;
//    function FindMacro(Area :Integer; AKey :Integer) :TMacro;
      procedure FindMacroses(AList :TExList; Area :TMacroArea; AKey :Integer);

      procedure InitConditions;
      function CheckCondition(ACond :TMacroCondition) :Boolean;

    public
      property Revision :Integer read FRevision;
      property Macroses :TObjList read FMacroses;
    end;


  var
    MacroLibrary :TMacroLibrary;


  procedure PushDlg(AHandle :THandle);
  procedure PopDlg(AHandle :THandle);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug,
    MacroListDlg;


 {-----------------------------------------------------------------------------}

  type
    PDlgRec = ^TDlgRec;
    TDlgRec = record
      Handle :THandle;
      Inited :Boolean;
      GUID   :TGUID;
    end;

  var
    DlgStack :TExList;


  procedure PushDlg(AHandle :THandle);
  begin
    if DlgStack = nil then
      DlgStack := TExList.CreateSize(SizeOf(TDlgRec));
    with PDlgRec(DlgStack.NewItem(DlgStack.Count))^ do begin
      Handle := AHandle;
      Inited := False;
      FillZero(GUID, SizeOf(TGUID));
    end
  end;


  procedure PopDlg(AHandle :THandle);
  begin
//  Assert(DlgStack.Count > 0);
    if (DlgStack <> nil) and (DlgStack.Count > 0) then begin
      with PDlgRec(DlgStack.PItems[DlgStack.Count - 1])^ do begin
        Assert(Handle = AHandle);
        if Handle <> AHandle then
          Exit;
      end;
      DlgStack.Delete(DlgStack.Count - 1);
    end;
  end;


  function GetTopDlgGUID :TGUID;
  var
    vInfo :TDialogInfo;
  begin
    if DlgStack.Count > 0 then begin
      with PDlgRec(DlgStack.PItems[DlgStack.Count - 1])^ do begin
        if not Inited then begin
          FillZero(vInfo, SizeOf(vInfo));
          vInfo.StructSize := SizeOf(vInfo);
          if FARAPI.SendDlgMessage(Handle, DM_GETDIALOGINFO, 0, TIntPtr(@vInfo)) <> 0 then
            GUID := vInfo.Id;
          Inited := True;
        end;
        Result := GUID;
      end;
    end else
      FillZero(Result, SizeOf(TGUID));
  end;


 {-----------------------------------------------------------------------------}
 { TMacro                                                                      }
 {-----------------------------------------------------------------------------}

  constructor TMacro.CreateBy(const ARec :TMacroRec; const AFileName :TString);
  begin
    Create;
    FName    := ARec.Name;
    FDescr   := ARec.Descr;
    FArea    := TMacroAreas(Word(ARec.Area));
    FCond    := ARec.Cond;
    FEvents  := ARec.Events;
    FWhere   := ARec.Where;
    FText    := ARec.Text;
    FOptions := ARec.Options;

    SetLength(FDlgs, Length(ARec.Dlgs));
    if Length(ARec.Dlgs) > 0 then
      Move(ARec.Dlgs[0], FDlgs[0], Length(ARec.Dlgs) * SizeOf(TGUID));

    SetLength(FBind, Length(ARec.Bind));
    if Length(ARec.Bind) > 0 then
      Move(ARec.Bind[0], FBind[0], Length(ARec.Bind) * SizeOf(Integer));

    FFileName := AFileName;
    FRow := ARec.Row;
    FCol := ARec.Col;
    FIndex := ARec.Index;
  end;


  destructor TMacro.Destroy; {override;}
  begin
    FBind := nil;
    inherited Destroy;
  end;

(*
  function TMacro.CheckCondition(Area :TMacroArea; AKey :Integer; ALib :TMacroLibrary) :Boolean;
  var
    I :Integer;
    vFound :Boolean;
    vCond :TMacroCondition;
    vGUID :TGUID;
  begin
    Result := False;

    if AKey <> 0 then begin
      vFound := False;
      for I := 0 to length(FBind) - 1 do
        if FBind[I] = AKey then begin
          vFound := True;
          break;
        end;
      if not vFound then
        Exit;
    end;


    if (FArea <> []) or (length(FDlgs) > 0) then begin
      if Area = maDialog then begin

        if maDialog in FArea then
          { Для всех диалогов }
        else begin
          { Возможно, макрос назначен на конкретный диалог, по GUID }
          vFound := False;

          if length(FDlgs) > 0 then begin
            vGUID := GetTopDlgGUID;
            for I := 0 to length(FDlgs) - 1 do
              if IsEqualGUID( vGUID, FDlgs[I] ) then begin
                vFound := True;
                break;
              end;
           end;

          if not vFound then
            Exit;
        end;

      end else
      if not (Area in FArea) then
        Exit;
    end;


    if (ALib <> nil) and (FCond <> []) then begin
      for vCond := low(TMacroCondition) to High(TMacroCondition) do begin
        if vCond in FCond then
          if not ALib.CheckCondition(vCond) then
            Exit;
      end;
    end;

    Result := True;
  end;
*)

  function TMacro.CheckCondition(Area :TMacroArea; AKey :Integer; ALib :TMacroLibrary) :Boolean;
  var
    I :Integer;
    vFound :Boolean;
    vCond :TMacroCondition;
  begin
    Result := False;

    if AKey <> 0 then begin
      vFound := False;
      for I := 0 to length(FBind) - 1 do
        if FBind[I] = AKey then begin
          vFound := True;
          break;
        end;
      if not vFound then
        Exit;
    end;

    if (FArea <> []) or (length(FDlgs) > 0) then
      if not CheckArea(Area) then
        Exit;

    if (ALib <> nil) and (FCond <> []) then begin
      for vCond := low(TMacroCondition) to High(TMacroCondition) do begin
        if vCond in FCond then
          if not ALib.CheckCondition(vCond) then
            Exit;
      end;
    end;

    Result := True;
  end;


  function TMacro.CheckEventCondition(Area :TMacroArea; Event :TMacroEvent) :Boolean;
  begin
    Result := (Event in FEvents) and CheckArea(Area);
  end;


  function TMacro.CheckArea(Area :TMacroArea) :Boolean;
  var
    I :Integer;
    vGUID :TGUID;
  begin
    Result := Area in FArea;

    if not Result and (Area = maDialog) and (length(FDlgs) > 0) then begin
      { Возможно, макрос назначен на конкретный диалог, по GUID }
      vGUID := GetTopDlgGUID;
      for I := 0 to length(FDlgs) - 1 do
        if IsEqualGUID( vGUID, FDlgs[I] ) then begin
          Result := True;
          Exit;
        end;
    end;
  end;


  procedure TMacro.Execute(AKeyCode :Integer);
  var
    vFlags :DWORD;
    vText :TString;
  begin
    vFlags := 0;
    if moDisableOutput in FOptions then
      vFlags := vFlags or KSFLAGS_DISABLEOUTPUT;
    if not (moSendToPlugins in FOptions) then
      vFlags := vFlags or KSFLAGS_NOSENDKEYSTOPLUGINS;
    if (moDefineAKey in FOptions) and (AKeyCode <> 0) then begin

      vText :=
        '%_AK_=' + Int2Str(AKeyCode) + ';'#13 +
        FText;

      FarPostMacro(vText, vFlags);
    end else
      FarPostMacro(FText, vFlags);
  end;


  function TMacro.GetBindAsStr(AMode :Integer) :TString;
  var
    I :Integer;
  begin
    Result := '';
    if length(FBind) > 0 then begin
      if AMode <= 1 then begin
        for I := 0 to length(FBind) - 1 do
          Result := AppendStrCh(Result, FarKeyToName(FBind[I]), ' ');
      end else
      begin
        Result := FarKeyToName(FBind[0]);
        if length(FBind) > 1 then
          Result := Result + ' (' + Int2Str(length(FBind)) + ')';
      end;
    end;
  end;


  function TMacro.GetAreaAsStr(AMode :Integer) :TString;
  const
    cAreaAll    = [Low(TMacroArea)..High(TMacroArea)];
    cAreaMenus  = [maMenu, maMainMenu, maUserMenu];
    cAreaOthers = [maSearch..maAutoCompletion] - cAreaMenus;

    procedure LocCheckArea(Area :TMacroArea);
    begin
      if Area in FArea then
        Result := AppendStrCh(Result, FarAreaToName(Area), ' ');
    end;

  var
    I :TMacroArea;
    vChr :array[0..6] of TChar;
  begin
    Result := '';
    if (FArea <> []) or (length(FDlgs) > 0) then begin
      if AMode <= 1 then begin
        if FArea = cAreaAll then
          Result := 'All'
        else begin
          LocCheckArea(maSHELL);
          LocCheckArea(maEDITOR);
          LocCheckArea(maVIEWER);
          for I := maDialog {maSHELL} to maAutoCompletion do
            LocCheckArea(I);
          if (length(FDlgs) > 0) and not (maDialog in FArea) then
            Result := AppendStrCh(Result, Format('%s(%d)', [FarAreaToName(maDialog), length(FDlgs)]), ' ');
        end;
      end else
      begin
        MemFillChar(@vChr, High(vChr) + 1, '.');
        vChr[High(vChr)] := #0;
        if maShell in FArea then
          vChr[0] := 'S';
        if  maEditor in FArea then
          vChr[1] := 'E';
        if maViewer in FArea then
          vChr[2] := 'V';
        if (maDialog in FArea) or (length(FDlgs) > 0) then
          vChr[3] := 'D';
        if cAreaMenus * FArea <> [] then
          vChr[4] := 'M';
        if cAreaOthers * FArea <> [] then
          vChr[5] := 'O';
        Result := vChr;
      end;
    end;
  end;


  function TMacro.GetFileTitle(AMode :Integer) :TString;
  begin
    if AMode <= 1 then
      Result := ExtractFileName(FFileName)
    else begin
      if UpCompareSubStr(FFarExePath, FFileName) = 0 then
        Result := ExtractRelativePath(FFarExePath, FFileName)
      else
        Result := FFileName;
    end;
  end;


  function TMacro.GetSrcLink :TString;
  begin
    Result := FFileName + ';' + Int2Str(FIndex);
  end;


 {-----------------------------------------------------------------------------}
 { TMacroLibrary                                                               }
 {-----------------------------------------------------------------------------}

  constructor TMacroLibrary.Create; {override;}
  begin
    inherited Create;
    FMacroses := TObjList.Create;
  end;


  destructor TMacroLibrary.Destroy; {override;}
  begin
    FreeObj(FMacroses);
    inherited Destroy;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMacroLibrary.RescanMacroses(ASilence :Boolean);
  var
    vFolder :TString;
  begin
    FSilence := ASilence;

    vFolder := optMacroPaths;
    if vFolder = '' then
      vFolder := AddFileName(ExtractFilePath(FARAPI.ModuleName), cDefMacroFolder);

    FNewMacroses := TObjList.Create;
    try

      ScanMacroFolder(vFolder);

      if FNewMacroses <> nil then begin
        FreeObj(FMacroses);
        FMacroses := FNewMacroses;
        FNewMacroses := nil;
        Inc(FRevision);
      end;

    except
      FreeObj(FNewMacroses);
      raise;
    end;
  end;


  procedure TMacroLibrary.ScanMacroFolder(const AFolder :TString);

    function LocEnumMacroFiles(const AFileName :TString; const ARec :TFarFindData) :Integer;
    begin
      Result := 1;
      if ARec.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN <> 0 then
        Exit;
      if not ParseMacroFile(AFileName) and not FSilence then
        Result := 0;
    end;

  var
    I :Integer;
    vPath :TString;
  begin
//  TraceF('ScanMacroFolder: %s', [vPath]);
    for I := 1 to WordCount(AFolder, [';', ',']) do begin

      vPath := Trim(ExtractWord(I, AFolder, [';', ',']));
      if (vPath <> '') and (vPath[1] = '"') and (vPath[length(vPath)] = '"') then
        vPath := Trim(Copy(vPath, 2, length(vPath) - 2));
      vPath := StrExpandEnvironment(vPath);

      if WinFolderExists(vPath) then
        EnumFilesEx(vPath, '*.' + cMacroFileExt, LocalAddr(@LocEnumMacroFiles));
    end;
  end;


  function TMacroLibrary.ParseMacroFile(const AFileName :TString) :boolean;
  var
    vParser :TMacroParser;
  begin
   {$ifdef bTrace}
    TraceF('Parse: %s', [AFileName]);
   {$endif bTrace}
    try
      vParser := TMacroParser.Create;
      try
        vParser.Safe := FSilence;
        vParser.CheckBody := not FSilence;
        vParser.OnAdd := AddMacro;
        vParser.OnError := ParseError;
        Result := vParser.ParseFile(AFileName);
      finally
        FreeObj(vParser);
      end;
    except
      if FSilence then
        Result := False
      else
        raise;
    end;
  end;


  procedure TMacroLibrary.AddMacro(Sender :TMacroParser; const ARec :TMacroRec);
  begin
    FNewMacroses.Add( TMacro.CreateBy(ARec, Sender.FileName) );
  end;


  procedure TMacroLibrary.ParseError(Sender :TMacroParser; ACode :Integer; const AMessage :TString; const AFileName :TString; ARow, ACol :Integer);
  begin
    if FSilence then begin
      {!!!Вывести в лог}
    end else
    begin
      FreeObj(FNewMacroses);
      if AFileName <> '' then
        OpenEditor(AFileName, ARow + 1, ACol + 1, True);
      if TParseError(ACode) <> errBadMacroSequence then
        ShowMessage(GetMsgStr(strError), AMessage, FMSG_WARNING or FMSG_MB_OK)
      else
        Sender.ShowSequenceError;
    end;
  end;


 {-----------------------------------------------------------------------------}

  function TMacroLibrary.CheckHotkey(const ARec :TKeyEventRecord) :boolean;
  var
    vKey :Integer;
  begin
    Result := False;

    vKey := WinKeyRecToFarKey(ARec);

    if ARec.bKeyDown then
      FLastKey := vKey
    else begin
      if (vKey and not KEY_CTRLMASK) = 0 then
        vKey := 0;
      if vKey = 0 then
        vKey := FLastKey;
      FLastKey := 0;
    end;
//  TraceF('CheckHotkey (Press=%d, vKey=%x "%s")',
//    [byte(ARec.bKeyDown), vKey, FarKeyToName(vKey)]);

    if vKey <> 0 then
      Result := CheckForRun(vKey, ARec.bKeyDown);
  end;


  function TMacroLibrary.CheckMouse(const ARec :TMouseEventRecord) :boolean;
  var
    vKey :Integer;
    vPress :Boolean;
  begin
    Result := False;
    if ARec.dwEventFlags and (MOUSE_MOVED + DOUBLE_CLICK + MOUSE_WHEELED + MOUSE_HWHEELED) = MOUSE_MOVED then
      Exit;

    vKey := MouseEventToFarKey(ARec, FMouseState, vPress);
    FMouseState := ARec.dwButtonState;
    FLastKey := 0;
//  TraceF('CheckMouse (Flag=%d, Buttons=%d, vKey=%x "%s", Press=%d)',
//    [ARec.dwEventFlags, ARec.dwButtonState, vKey, FarKeyToName(vKey), Byte(vPress)]);

    if vKey <> 0 then
      Result := CheckForRun(vKey, vPress);
  end;


  function TMacroLibrary.CheckEvent(Area :TMacroArea; AEvent :TMacroEvent) :boolean;
  var
    I :Integer;
    vList :TRunList;
    vMacro :TMacro;
  begin
    Result := False;
    vList := TRunList.Create;
    try
      InitConditions;
//    TraceF('CheckEvent (Event=%d, Area=%d)', [Byte(AEvent), byte(Area)]);

      for I := 0 to FMacroses.Count - 1 do begin
        vMacro := FMacroses[I];
        if vMacro.CheckEventCondition(Area, AEvent) then
          vList.Add(vMacro);
      end;

      if vList.Count > 0 then begin
        vList.RunAll := True;
        FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList);
        vList := nil;
      end;

    finally
      FreeObj(vList);
    end;
  end;


  function TMacroLibrary.CheckForRun(AKey :Integer; APress :Boolean) :boolean;
  var
    I :Integer;
    vArea :TMacroArea;
    vList :TRunList;
    vMacro :TMacro;
  begin
    Result := False;
    if AKey <> 0 then begin
      vList := TRunList.Create;
      try
        vArea := TMacroArea(FarGetMacroArea);
        FindMacroses(vList, vArea, AKey);
        if vList.Count > 0 then begin

          for I := vList.Count - 1 downto 0 do begin
            vMacro := vList[I];
            if moEatOnRun in vMacro.FOptions then
              Result := True;
            if (moRunOnRelease in vMacro.FOptions) = APress then
              vList.Delete(I)
          end;

          if vList.Count > 0 then begin
            vList.KeyCode := AKey;
            FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList);
            vList := nil;
          end;
        end;

      finally
        FreeObj(vList);
      end;
    end;
  end;


  procedure TMacroLibrary.FindMacroses(AList :TExList; Area :TMacroArea; AKey :Integer);

    procedure LocFind(AKey :Integer);
    var
      I :Integer;
      vMacro :TMacro;
    begin
      for I := 0 to FMacroses.Count - 1 do begin
        vMacro := FMacroses[I];
        if vMacro.CheckCondition(Area, AKey, Self) then
          AList.Add(vMacro);
      end;
    end;

  begin
    InitConditions;
    LocFind(AKey);
    if (AList.Count = 0) and (AKey and (KEY_RCTRL + KEY_RALT) <> 0) then begin
      if AKey and KEY_RCTRL <> 0 then
        AKey := (AKey and not KEY_RCTRL) or KEY_CTRL;
      if AKey and KEY_RALT <> 0 then
        AKey := (AKey and not KEY_RALT) or KEY_ALT;
      LocFind(AKey);
    end;
  end;


  procedure TMacroLibrary.ShowList(AList :TExList);
  var
    vIndex :Integer;
    vMacro :TMacro;
  begin
    vIndex := -1;
    if ListMacrosesDlg(AList, vIndex) then begin
      vMacro := AList[vIndex];
      FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vMacro);
    end;
  end;


  procedure TMacroLibrary.ShowAvailable;
  var
    I, vIndex :Integer;
    vArea :TMacroArea;
    vList :TExList;
    vMacro :TMacro;
  begin
    vList := TExList.Create;
    try
      vArea := TMacroArea(FarGetMacroArea);

      InitConditions;
      for I := 0 to FMacroses.Count - 1 do begin
        vMacro := FMacroses[I];
        if vMacro.CheckCondition(vArea, 0, Self) then
          vList.Add(vMacro);
      end;

      vIndex := -1;
      if ListMacrosesDlg(vList, vIndex) then begin
        vMacro := vList[vIndex];
        FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vMacro);
      end;

    finally
      FreeObj(vList);
    end;
  end;


  procedure TMacroLibrary.ShowAll;
  var
    vIndex :Integer;
    vMacro :TMacro;
  begin
    vIndex := -1;
    if ListMacrosesDlg(FMacroses, vIndex) then begin
      vMacro := FMacroses[vIndex];
      FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vMacro);
    end;
  end;

 {-----------------------------------------------------------------------------}

  procedure TMacroLibrary.InitConditions;
  begin
    FWindowType := -1;
    FConditions := [];
  end;


  function TMacroLibrary.CheckCondition(ACond :TMacroCondition) :Boolean;

    procedure InitWindowType;
    var
      vWinInfo :TWindowInfo;
    begin
      FillZero(vWinInfo, SizeOf(vWinInfo));
      vWinInfo.Pos := -1;
      FARAPI.AdvControl(hModule, ACTL_GETSHORTWINDOWINFO, @vWinInfo);
      FWindowType := vWinInfo.WindowType;
    end;

    procedure InitCmdLineCondition;
    var
      vLen :Integer;
    begin
      if FWindowType = WTYPE_PANELS then begin
        vLen := FARAPI.Control(PANEL_ACTIVE, FCTL_GetCmdLine, 0, nil);
        SetMacroCondition(FConditions, mcCmdLineEmpty, vLen > 1);
      end;
    end;

    procedure InitBlockCondition;
    var
      vEdtInfo :TEditorInfo;
    begin
      if FWindowType = WTYPE_EDITOR then begin
        FillZero(vEdtInfo, SizeOf(vEdtInfo));
        FARAPI.EditorControl(ECTL_GETINFO, @vEdtInfo);
        SetMacroCondition(FConditions, mcBlockNotSelected, vEdtInfo.BlockType <> BTYPE_NONE);
      end else
      if FWindowType = WTYPE_VIEWER then begin
//      FConditions := FConditions + [mcBlockNotSelected]
      end else
      if FWindowType = WTYPE_DIALOG then begin
//      FConditions := FConditions + [mcBlockNotSelected]
      end;
    end;

    procedure GetCondition(AHandle :THandle; var AIsPlugin, AIsFolder, AHasSelected :Boolean);
    var
      vPanInfo :TPanelInfo;
      vItem :PPluginPanelItem;
    begin
      FillZero(vPanInfo, SizeOf(vPanInfo));
      FARAPI.Control(AHandle, FCTL_GETPANELINFO, 0, @vPanInfo);
      AIsPlugin := vPanInfo.Plugin = 1;

      AIsFolder := False; AHasSelected := False;
      if vPanInfo.ItemsNumber > 0 then begin
        vItem := FarPanelItem(AHandle, FCTL_GETCURRENTPANELITEM, 0);
        try
          AIsFolder := vItem.FindData.dwFileAttributes and faDirectory <> 0;
        finally
          MemFree(vItem);
        end;

        { Мы должны проверить флаг PPIF_SELECTED, потому что SelectedItemsNumber = 1}
        { даже если не выделено ни одного элемента }
        if vPanInfo.SelectedItemsNumber > 0 then begin
          vItem := FarPanelItem(AHandle, FCTL_GETSELECTEDPANELITEM, 0);
          try
            AHasSelected := vItem.Flags and PPIF_SELECTED <> 0;
          finally
            MemFree(vItem);
          end;
        end;
      end;
    end;

    procedure InitPanelCondition;
    var
      vIsPlugin, vIsFolder, vHasSelected :Boolean;
    begin
      if FWindowType = WTYPE_PANELS then begin
        GetCondition(PANEL_ACTIVE, vIsPlugin, vIsFolder, vHasSelected);
        SetMacroCondition(FConditions, mcPanelTypeFile, vIsPlugin);
        SetMacroCondition(FConditions, mcPanelItemFile, vIsFolder);
        SetMacroCondition(FConditions, mcPanelNotSelected, vHasSelected);
      end;
    end;

    procedure InitPPanelCondition;
    var
      vIsPlugin, vIsFolder, vHasSelected :Boolean;
    begin
      if FWindowType = WTYPE_PANELS then begin
        GetCondition(PANEL_PASSIVE, vIsPlugin, vIsFolder, vHasSelected);
        SetMacroCondition(FConditions, mcPPanelTypeFile, vIsPlugin);
        SetMacroCondition(FConditions, mcPPanelItemFile, vIsFolder);
        SetMacroCondition(FConditions, mcPPanelNotSelected, vHasSelected);
      end;
    end;

  begin
    if FWindowType = -1 then
      InitWindowType;
    if (ACond in [mcCmdLineEmpty, mcCmdLineNotEmpty]) and ([mcCmdLineEmpty, mcCmdLineNotEmpty] * FConditions = []) then
      InitCmdLineCondition;
    if (ACond in [mcBlockSelected, mcBlockNotSelected]) and ([mcBlockSelected, mcBlockNotSelected] * FConditions = []) then
      InitBlockCondition;
    if (ACond in [mcPanelTypeFile..mcPanelSelected]) and ([mcPanelTypeFile..mcPanelSelected] * FConditions = []) then
      InitPanelCondition;
    if (ACond in [mcPPanelTypeFile..mcPPanelSelected]) and ([mcPanelTypeFile..mcPPanelSelected] * FConditions = []) then
      InitPPanelCondition;

    Result := ACond in FConditions;
  end;


initialization
//ColorDlgResBase := Byte(strColorDialog);
  ParserResBase := Byte(strMacroParserErrors);

finalization
  FreeObj(MacroLibrary);
  FreeObj(DlgStack);
end.

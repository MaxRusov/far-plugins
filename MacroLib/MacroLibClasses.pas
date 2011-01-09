{$I Defines.inc}

unit MacroLibClasses;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* MacroLib                                                                   *}
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

    MacroLibConst,
    MacroParser;



  type
    TMacroLibrary = class;

    TMacro = class(TBasis)
    public
      constructor CreateBy(const ARec :TMacroRec; const AFileName :TString);
      destructor Destroy; override;

      function CheckCondition(Area :Integer; AKey :Integer; ALib :TMacroLibrary) :Boolean;
      procedure Execute;

    private
      FName     :TString;          { Имя макрокоманды }
      FDescr    :TString;          { Описание макрокоманды }
      FWhere    :TString;          { Условие запуска }
      FBind     :TIntArray;        { Список кнопок для запуска }
      FArea     :DWORD;            { Маска макрообластей }
      FDlgs     :TGUIDArray;       { Список GUID-ов диалогов }
      FCond     :TMacroConditions; { Условия срабатывания }
      FText     :TString;          { Текст макрокоманды }
      FOptions  :TMacroOptions;

      FFileName :TString;
      FRow      :Integer;
      FCol      :Integer;

      function GetBindAsStr :TString;
      function GetAreaAsStr :TString;

    public
      property Name :TString read FName;
      property Descr :TString read FDescr;
      property BindStr :TString read GetBindAsStr;
      property AreaStr :TString read GetAreaAsStr;

      property FileName :TString read FFileName;
      property Row :Integer read FRow;
      property Col :Integer read FCol;
    end;


    TMacroLibrary = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure RescanMacroses(ASilence :Boolean);
      function CheckHotkey(const ARec :TKeyEventRecord) :boolean;
      function CheckMouse(const ARec :TMouseEventRecord) :boolean;
      procedure ShowAvailable;
      procedure ShowAll;
      procedure ShowList(AList :TExList);

    private
      FMacroses    :TObjList;
      FNewMacroses :TObjList;
      FSilence     :Boolean;
      FMouseState  :DWORD;

      FWindowType  :Integer;
      FConditions  :TMacroConditions;

      procedure ScanMacroFolder(const AFolder :TString);
      function ParseMacroFile(const AFileName :TString) :boolean;

      procedure AddMacro(Sender :TMacroParser; const ARec :TMacroRec);
      procedure ParseError(Sender :TMacroParser; ACode :Integer; const AMessage :TString; const AFileName :TString; ARow, ACol :Integer);

      function CheckForRun(AKey :Integer; APress :Boolean) :boolean;
//    function FindMacro(Area :Integer; AKey :Integer) :TMacro;
      procedure FindMacroses(AList :TExList; Area :Integer; AKey :Integer);

      procedure InitConditions;
      function CheckCondition(ACond :TMacroCondition) :Boolean;
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
    Assert(DlgStack.Count > 0);
    if DlgStack.Count > 0 then begin
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
    FArea    := ARec.Area;
    FCond    := ARec.Cond;
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
  end;


  destructor TMacro.Destroy; {override;}
  begin
    FBind := nil;
    inherited Destroy;
  end;


  function TMacro.CheckCondition(Area :Integer; AKey :Integer; ALib :TMacroLibrary) :Boolean;
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


    if (FArea <> 0) or (length(FDlgs) > 0) then begin
      if Area = MACROAREA_DIALOG then begin

        if (1 shl MACROAREA_DIALOG) and FArea <> 0 then
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
      if (1 shl Area) and FArea = 0 then
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


  procedure TMacro.Execute;
  var
    vFlags :DWORD;
  begin
    vFlags := 0;
    if moDisableOutput in FOptions then
      vFlags := vFlags or KSFLAGS_DISABLEOUTPUT;
    if not (moSendToPlugins in FOptions) then
      vFlags := vFlags or KSFLAGS_NOSENDKEYSTOPLUGINS;
    FarPostMacro(FText, vFlags);
  end;


  function TMacro.GetBindAsStr :TString;
  var
    I :Integer;
  begin
    Result := '';
    for I := 0 to length(FBind) - 1 do
      Result := AppendStrCh(Result, FarKeyToName(FBind[I]), ' ');
  end;


  function TMacro.GetAreaAsStr :TString;
  var
    I :Integer;
  begin
    Result := '';
    for I := MACROAREA_SHELL to MACROAREA_AUTOCOMPLETION do
      if (1 shl I) and FArea <> 0 then
        Result := AppendStrCh(Result, FarAreaToName(I), ' ');

    if (length(FDlgs) > 0) and ((1 shl MACROAREA_DIALOG) and FArea = 0) then
      Result := AppendStrCh(Result, Format('%s(%d)', [FarAreaToName(MACROAREA_DIALOG), length(FDlgs)]), ' ');
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
//  TraceF('CheckMouse (Flag=%d, Buttons=%d, vKey=%x "%s", Press=%d)',
//    [ARec.dwEventFlags, ARec.dwButtonState, vKey, FarKeyToName(vKey), Byte(vPress)]);

    if vKey <> 0 then
      Result := CheckForRun(vKey, vPress);
  end;


  function TMacroLibrary.CheckForRun(AKey :Integer; APress :Boolean) :boolean;
  var
    I, vArea :Integer;
    vList :TExList;
    vMacro :TMacro;
  begin
    Result := False;
    if AKey <> 0 then begin
      vArea := FarGetMacroArea;
      vList := TExList.Create;
      try
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
            if vList.Count = 1 then
              FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList[0])
            else begin
              FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList);
              vList := nil;
            end;
          end;
        end;

      finally
        FreeObj(vList);
      end;
    end;
  end;

(*
  function TMacroLibrary.FindMacro(Area :Integer; AKey :Integer) :TMacro;
  var
    I :Integer;
  begin
    for I := 0 to FMacroses.Count - 1 do begin
      Result := FMacroses[I];
      if Result.CheckCondition(Area, AKey) then
        Exit;
    end;
    Result := nil;
  end;
*)

  procedure TMacroLibrary.FindMacroses(AList :TExList; Area :Integer; AKey :Integer);
  var
    I :Integer;
    vMacro :TMacro;
  begin
    InitConditions;
    for I := 0 to FMacroses.Count - 1 do begin
      vMacro := FMacroses[I];
      if vMacro.CheckCondition(Area, AKey, Self) then
        AList.Add(vMacro);
    end;
  end;


  procedure TMacroLibrary.ShowList(AList :TExList);
  var
    vIndex :Integer;
    vMacro :TMacro;
  begin
    vIndex := 0;
    if ListMacrosesDlg(AList, vIndex) then begin
      vMacro := AList[vIndex];
      FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vMacro);
    end;
  end;


  procedure TMacroLibrary.ShowAvailable;
  var
    I, vArea, vIndex :Integer;
    vList :TExList;
    vMacro :TMacro;
  begin
    vList := TExList.Create;
    try
      vArea := FarGetMacroArea;

      InitConditions;
      for I := 0 to FMacroses.Count - 1 do begin
        vMacro := FMacroses[I];
        if vMacro.CheckCondition(vArea, 0, Self) then
          vList.Add(vMacro);
      end;

      vIndex := 0;
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
    vIndex := 0;
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

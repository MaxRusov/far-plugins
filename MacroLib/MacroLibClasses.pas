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
    TMacro = class(TBasis)
    public
      constructor CreateBy(const ARec :TMacroRec; const AFileName :TString);
      destructor Destroy; override;

      function CheckCondition(Area :Integer; AKey :Integer) :Boolean;
      procedure Execute;

    private
      FName     :TString;   { Имя макрокоманды }
      FDescr    :TString;   { Описание макрокоманды }
      FWhere    :TString;   { Условие запуска }
      FBind     :TIntArray; { Список кнопок для запуска }
      FArea     :DWORD;     { Маска макрообластей }
      FCond     :DWORD;     { Условия срабатывания }
      FText     :TString;   { Текст макрокоманды }
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

      procedure ScanMacroFolder(const AFolder :TString);
      function ParseMacroFile(const AFileName :TString) :boolean;

      procedure AddMacro(Sender :TMacroParser; const ARec :TMacroRec);
      procedure ParseError(Sender :TMacroParser; ACode :Integer; const AMessage :TString; const AFileName :TString; ARow, ACol :Integer);

      function CheckForRun(AKey :Integer; APress :Boolean) :boolean;
//    function FindMacro(Area :Integer; AKey :Integer) :TMacro;
      procedure FindMacroses(AList :TExList; Area :Integer; AKey :Integer);
    end;


  var
    MacroLibrary :TMacroLibrary;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug,
    MacroListDlg;


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


  function TMacro.CheckCondition(Area :Integer; AKey :Integer) :Boolean;
  var
    I :Integer;
  begin
    Result := False;
    if (FArea = 0) or ((1 shl Area) and FArea <> 0) then begin

      if AKey <> 0 then begin
        for I := 0 to length(FBind) - 1 do begin
          if FBind[I] = AKey then begin
            {!!! Check run conditions... }
            Result := True;
            Exit;
          end;
        end;
      end else
        Result := True;

    end;
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

(*
  function TMacroLibrary.CheckHotkey(const ARec :TKeyEventRecord) :boolean;
  var
    vKey, vArea :Integer;
    vList :TExList;
  begin
    Result := False;

    vKey := WinKeyRecToFarKey(ARec);
    vArea := FarGetMacroArea;
    TraceF('CheckHotkey (Press=%d, Area=%d, vKey=%x "%s")', [byte(ARec.bKeyDown), vArea, vKey, FarKeyToName(vKey)]);

    if vKey <> 0 then begin
      vList := TExList.Create;
      try
        FindMacroses(vList, vArea, vKey);

        if vList.Count > 0 then begin

          if ARec.bKeyDown then begin

            if vList.Count = 1 then
              FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList[0])
            else begin
              FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList);
              vList := nil;
            end;

          end;

          Result := True;
        end;

      finally
        FreeObj(vList);
      end;
    end;
  end;


  function TMacroLibrary.CheckMouse(const ARec :TMouseEventRecord) :boolean;
  var
    vKey, vArea :Integer;
    vList :TExList;
  begin
    Result := False;
    if ARec.dwEventFlags and (MOUSE_MOVED + DOUBLE_CLICK + MOUSE_WHEELED + MOUSE_HWHEELED) = MOUSE_MOVED then
      Exit;

    vKey := MouseEventToFarKey(ARec);
    vArea := FarGetMacroArea;
    
    TraceF('CheckMouse (Flag=%d, Buttons=%d, Area=%d, vKey=%x "%s")',
      [ARec.dwEventFlags, ARec.dwButtonState, vArea, vKey, FarKeyToName(vKey)]);

    if vKey <> 0 then begin
      vList := TExList.Create;
      try
        FindMacroses(vList, vArea, vKey);

        if vList.Count > 0 then begin

//        if ARec.bKeyDown then begin

            if vList.Count = 1 then
              FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList[0])
            else begin
              FARAPI.AdvControl(hModule, ACTL_SYNCHRO, vList);
              vList := nil;
            end;

//        end;

          Result := True;
        end;

      finally
        FreeObj(vList);
      end;
    end;

  end;
*)


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
    for I := 0 to FMacroses.Count - 1 do begin
      vMacro := FMacroses[I];
      if vMacro.CheckCondition(Area, AKey) then
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

      for I := 0 to FMacroses.Count - 1 do begin
        vMacro := FMacroses[I];
        if vMacro.CheckCondition(vArea, 0) then
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


initialization
//ColorDlgResBase := Byte(strColorDialog);
  ParserResBase := Byte(strMacroParserErrors);

finalization
  FreeObj(MacroLibrary);
end.

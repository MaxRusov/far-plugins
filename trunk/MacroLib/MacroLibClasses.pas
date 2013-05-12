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

    Far_API,
    FarCtrl,

    FarMatch,
    MacroLibConst,
    MacroParser;


  type
    TKeyPress =
    (
      kpDown,
      kpAuto,
      kpHold,
      kpUp,
      kpShiftUp,
      kpDouble,
      kpAll
    );

  type
    TMacroLibrary = class;

    TMacro = class(TBasis)
    public
      constructor CreateBy(const ARec :TMacroRec; const AFileName :TString);
      destructor Destroy; override;

      function CheckKeyCondition(Area :TMacroArea; AKey :Integer; APress :TKeyPress; ALib :TMacroLibrary; var AEat :Boolean) :Boolean;
      function CheckAreaCondition(Area :TMacroArea; ALib :TMacroLibrary) :Boolean;
      function CheckEventCondition(Area :TMacroArea; Event :TMacroEvent) :Boolean;
      procedure Execute(AKeyCode :Integer);

      procedure AddToFar;
      procedure RemoveFromFar;

      function GetBindAsStr(AMode :Integer) :TString;
      function GetAreaAsStr(AMode :Integer) :TString;
      function GetFileTitle(AMode :Integer) :TString;
      function GetSrcLink :TString;

    private
      FName      :TString;            { Имя макрокоманды }
      FDescr     :TString;            { Описание макрокоманды }
      FWhere     :TString;            { Условие запуска (пока не используется) }
      FBind      :TKeyArray;          { Список кнопок для запуска }
     {$ifdef bUseKeyMask}
      FBind1     :TKeyMaskArray;      { Альтернативная привязка - по регулярным выражениям }
     {$endif bUseKeyMask}
      FEvents    :TMacroEvents;       { Список событий для запуска }
      FArea      :TMacroAreas;        { Маска макрообластей }
      FDlgs      :TGUIDArray;         { Список GUID-ов диалогов }
      FDlgs1     :TStrArray;          { Список Caption-ов диалогов }
      FEdts      :TStrArray;          { Список масок редактора }
      FViews     :TStrArray;          { Список масок viewer'а }
      FCond      :TMacroConditions;   { Условия срабатывания }
     {$ifdef bMacroInclude}
      FIncludes  :TMacroIncludeArray; { Макроподстановки }
     {$endif bMacroInclude}
      FText      :TString;            { Текст макрокоманды }
      FPriority  :Integer;            { Приоритет макрокоманды }
      FOptions   :TMacroOptions;

      FFileName  :TString;
      FRow       :Integer;
      FCol       :Integer;
      FIndex     :Integer;

      FRunCount :Integer;           { Счетчик запусков }

      FIDs      :TObjList;          { ID макросов, добавленных в FAR. Для удаления. }

      function GetHidden :Boolean;
      function CheckArea(Area :TMacroArea) :Boolean;

    public
      property Hidden :Boolean read GetHidden;
      property Name :TString read FName;
      property Descr :TString read FDescr;
      property Priority :Integer read FPriority;
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

    TRunEvent = class(TBasis)
    public
      Event :TMacroEvent;
      Area  :TMacroArea;
      constructor CreateEx(AEvent :TMacroEvent; AArea :TMacroArea);
    end;


    TKeyIndex = class(TExList)
    public
      function CompareObj(Another :TBasis; Context :TIntPtr) :Integer; override;
      function CompareKey(Key :Pointer; Context :TIntPtr) :Integer; override;

    private
      FKey  :Integer;
    end;


    TMacroLibrary = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function RescanMacroses(ASilence :Boolean; AHideError :Boolean = False) :Boolean;
      function CheckHotkey(const ARec :TKeyEventRecord) :boolean;
      function CheckMouse(const ARec :TMouseEventRecord) :boolean;
      function CheckEvent(Area :TMacroArea; AEvent :TMacroEvent) :boolean;
      procedure ShowAvailable;
      procedure ShowAll;
      procedure ShowList(AList :TExList);

      function FindMacroByName(const AName :TString) :TMacro;
      procedure FindMacroses(AList :TExList; Area :TMacroArea; AKey :Integer; APress :TKeyPress; var AEat :Boolean);

      procedure CancellPress;

     {$ifdef bLua}
      procedure AddLuaMacro(AWhat :Integer; const ADescr, AKeys, AAreas, AFileName :TString; ARow :Integer);
     {$endif bLua}

    private
      FMacroses    :TObjList;
      FNewMacroses :TObjList;
      FKeyIndex    :TObjList;
     {$ifdef bLua}
      FLuaMacroses :TObjList;
      FAllMacroses :TExList;
     {$endif bLua}
      FRevision    :Integer;
      FSilence     :Boolean;
      FHideError   :Boolean;
      FLastKey     :Integer;
      FLastShift   :Integer;
      FPrevKey     :Integer;
      FPressTime   :DWORD;
      FMouseState  :DWORD;
      FCancelled   :Boolean;

      FWindowType  :Integer;
      FDialogID    :THandle;
      FConditions  :TMacroConditions;

      FLastError   :TString;

      procedure ScanMacroFolder(const AFolder :TString);
      function ParseMacroFile(const AFileName :TString) :boolean;
      procedure Reindex;

      procedure AddMacro(Sender :TMacroParser; const ARec :TMacroRec);
      procedure ParseError(Sender :TMacroParser; ACode :Integer; const AMessage :TString; const AFileName :TString; ARow, ACol :Integer);

      function CheckForRun(AKey :Integer; AChr :TChar; APress :TKeyPress) :boolean;

      procedure InitConditions;
      function CheckCondition(ACond :TMacroCondition) :Boolean;

      procedure CheckPriority(AList :TExList);

      function GetAllMacroses :TExList;

    public
      property Revision :Integer read FRevision;
      property Macroses :TObjList read FMacroses;
      property AllMacroses :TExList read GetAllMacroses;
      property LastError :TString read FLastError;
    end;


 {$ifdef Far3}
 {$else}
  procedure PushDlg(AHandle :THandle);
  procedure PopDlg(AHandle :THandle);
 {$endif Far3}


  var
    MacroLibrary :TMacroLibrary;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug,
    MacroListDlg;


 {-----------------------------------------------------------------------------}


 {$ifdef Far3}
 {$else}
  var
    DlgStack :TExList;

  procedure PushDlg(AHandle :THandle);
  begin
    if DlgStack = nil then
      DlgStack := TExList.Create;
    DlgStack.Add(Pointer(AHandle));
  end;

  procedure PopDlg(AHandle :THandle);
  begin
    if (DlgStack <> nil) and (DlgStack.Count > 0) then
      if THandle(DlgStack.Last) = AHandle then
        DlgStack.Delete(DlgStack.Count - 1);
  end;

  function GetTopDlgHandle :THandle;
  begin
    Result := 0;
    if (DlgStack <> nil) and (DlgStack.Count > 0) then
      Result := THandle(DlgStack.Last);
  end;
 {$endif Far3}


  function GetTopDlgGUID :TGUID;
  var
    vWinInfo :TWindowInfo;
    vDlgInfo :TDialogInfo;
    vDlg :THandle;
  begin
    FillZero(Result, SizeOf(TGUID));
    if FarGetWindowInfo(-1, vWinInfo) and (vWinInfo.WindowType = WTYPE_DIALOG) then begin
     {$ifdef Far3}
      vDlg := vWinInfo.ID;
     {$else}
      vDlg := GetTopDlgHandle;
     {$endif Far3}
      FillZero(vDlgInfo, SizeOf(vDlgInfo));
      vDlgInfo.StructSize := SizeOf(vDlgInfo);
      if FarSendDlgMessage(vDlg, DM_GETDIALOGINFO, 0, @vDlgInfo) <> 0 then
        Result := vDlgInfo.Id;
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TRunEvent                                                                   }
 {-----------------------------------------------------------------------------}

  constructor TRunEvent.CreateEx(AEvent :TMacroEvent; AArea :TMacroArea);
  begin
    Event := AEvent;
    Area := AArea;
  end;


 {-----------------------------------------------------------------------------}
 { TMacro                                                                      }
 {-----------------------------------------------------------------------------}

  constructor TMacro.CreateBy(const ARec :TMacroRec; const AFileName :TString);
  begin
    Create;
    FName     := ARec.Name;
    FDescr    := ARec.Descr;
   {$ifdef Far3}
    FArea     := TMacroAreas(Integer(ARec.Area));
   {$else}
    FArea     := TMacroAreas(Word(ARec.Area));
   {$endif Far3}
    FCond     := ARec.Cond;
    FEvents   := ARec.Events;
    FWhere    := ARec.Where;
    FText     := ARec.Text;
    FPriority := ARec.Priority;
    FOptions  := ARec.Options;

    SetLength(FDlgs, Length(ARec.Dlgs));
    if Length(ARec.Dlgs) > 0 then
      Move(ARec.Dlgs[0], FDlgs[0], Length(ARec.Dlgs) * SizeOf(TGUID));

    MoveStrArray(ARec.Dlgs1, FDlgs1);
    MoveStrArray(ARec.Edts, FEdts);
    MoveStrArray(ARec.Views, FViews);

    SetLength(FBind, Length(ARec.Bind));
    if Length(ARec.Bind) > 0 then
      Move(ARec.Bind[0], FBind[0], Length(ARec.Bind) * SizeOf(TKeyRec));

   {$ifdef bUseKeyMask}
    SetLength(FBind1, Length(ARec.Bind1));
    if Length(ARec.Bind1) > 0 then begin
      Move(ARec.Bind1[0], FBind1[0], Length(ARec.Bind1) * SizeOf(TKeyMaskRec));
      FillZero(ARec.Bind1[0], Length(ARec.Bind1) * SizeOf(TKeyMaskRec));
    end;
   {$endif bUseKeyMask}

   {$ifdef bMacroInclude}
    SetLength(FIncludes, Length(ARec.Includes));
    if Length(ARec.Includes) > 0 then begin
      Move(ARec.Includes[0], FIncludes[0], Length(ARec.Includes) * SizeOf(TMacroInclude));
      FillZero(ARec.Includes[0], Length(ARec.Includes) * SizeOf(TMacroInclude));
    end;
   {$endif bMacroInclude}

    FFileName := AFileName;
    FRow := ARec.Row;
    FCol := ARec.Col;
    FIndex := ARec.Index;
  end;


  destructor TMacro.Destroy; {override;}
  begin
    RemoveFromFar;
    FBind := nil;
   {$ifdef bUseKeyMask}
    FBind1 := nil;
   {$endif bUseKeyMask}
    FDlgs := nil;
    FDlgs1 := nil;
    FEdts := nil;
    FViews := nil;
   {$ifdef bMacroInclude}
    FIncludes := nil;
   {$endif bMacroInclude}
    FreeObj(FIDs);
    inherited Destroy;
  end;



 {$ifdef Far3}

  type
    TMacroRef = class(TBasis)
      FMacro :TMacro;
    end;


  function MacroCallback(AId :Pointer; AFlags :TFarAddKeyMacroFlags) :TIntPtr; stdcall;
  begin
    Result := 0;
    MacroLibrary.InitConditions;  { !!!Неоптимально }
    if TMacroRef(AId).FMacro.CheckAreaCondition(TMacroArea(FarGetMacroArea), MacroLibrary) then
      Result := 1;
  end;


  function FarAddMacro(AOwner :TMacro; AKey :TKeyRec) :Pointer;
  var
    vRec :TMacroAddMacro;
    vRef :TMacroRef;
  begin
    vRef := TMacroRef.Create;
    vRef.FMacro := AOwner;

    FillZero(vRec, SizeOf(vRec));
    vRec.StructSize := SizeOf(vRec);
    vRec.Area := MACROAREA_COMMON;
    FarKeyToInputRecord(AKey.Key, vRec.AKey);
    vRec.Description := PFarChar(AOwner.FDescr);
    vRec.SequenceText := PFarChar(AOwner.FText);

    if moDisableOutput in AOwner.FOptions then
      vRec.Flags := vRec.Flags or KMFLAGS_DISABLEOUTPUT;
    if not (moSendToPlugins in AOwner.FOptions) then
      vRec.Flags := vRec.Flags or KMFLAGS_NOSENDKEYSTOPLUGINS;

    vRec.Callback := MacroCallback;
    vRec.Id := vRef;

    if FARAPI.MacroControl(PluginID, MCTL_ADDMACRO, 0, @vRec) = 0 then
      { Не удалось... }
      FreeObj(vRef);

    Result := vRef;
  end;


  procedure FarDelMacro(AID :Pointer);
  begin
    FARAPI.MacroControl(PluginID, MCTL_DELMACRO, 0, AID);
  end;

 {$endif Far3}


  procedure TMacro.AddToFar;
 {$ifdef Far3}
  var
    I :Integer;
  begin
    if FIDs = nil then
      FIDs := TObjList.Create;
    for I := 0 to length(FBind) - 1 do
      FIDs.Add( FarAddMacro(Self, FBind[I]) );
 {$else}
  begin
 {$endif Far3}
  end;


  procedure TMacro.RemoveFromFar;
 {$ifdef Far3}
  var
    I :Integer;
  begin
    if FIDs = nil then
      Exit;
    for I := 0 to FIDs.Count - 1 do
      FarDelMacro(FIDs[I]);
    FIDs.Clear;
 {$else}
  begin
 {$endif Far3}
  end;


  function TMacro.CheckKeyCondition(Area :TMacroArea; AKey :Integer; APress :TKeyPress; ALib :TMacroLibrary; var AEat :Boolean) :Boolean;
    { Press:  kpDown, kpAuto, kpHold, kpUp, kpDouble, kpAll }
  var
    vRes, vFin, vEat :Boolean;

    function LocTestMod(AMod :TKeyModifier) :Boolean;
    begin
      Result := False;
      case AMod of
        kmPress: begin
          { Обычный хоткей: все, кроме отпускания }
          vRes := not (APress in [kpUp, kpShiftUp]);
          vEat := True;
          Result := True;
        end;
        kmRelease: begin
          { На отпускание }
          vRes := APress in [kpUp, kpAll];
          vEat := True;
          Result := True;
        end;
        kmSingle: begin
          { На SingleClick }
          vRes := APress in [kpDown, kpAuto, kpHold, kpAll];
          vEat := APress <> kpDouble;
        end;
        kmDouble: begin
          { На DoubleClick }
          vRes := APress in [kpDouble, kpAll];
          vEat := vRes;
          vFin := vRes;
        end;
        kmHold: begin
          { На удержание }
          vRes := APress in [kpHold, kpAll];
          vEat := vRes;
          vFin := vRes;
        end;
        kmDown: begin
          { На нажатие }
          vRes := APress in [kpDown, kpDouble, kpAll];
          vEat := vRes;
        end;
        kmUp: begin
          { На отжатие }
          vRes := APress in [kpUp, kpShiftUp, kpAll];
          vEat := vRes;
        end;
      end;
      if vRes then
        Result := True;
    end;

  var
    I :Integer;
   {$ifdef bUseKeyMask}
    vKeyName :TString;
   {$endif bUseKeyMask}
  begin
    Result := False;

    { Поскольку теперь используем индекс, то какая-то кнопка точно совпадет }
    if not CheckAreaCondition(Area, ALib) then
      Exit;

    vRes := False;
    vEat := False;
    vFin := False;

    for I := 0 to length(FBind) - 1 do
      if FBind[I].Key = AKey then begin
        if LocTestMod(FBind[I].KMod) then
          Break;
      end;

   {$ifdef bUseKeyMask}
    if not vRes and (length(FBind1) > 0) then begin
      vKeyName := FarKeyToName(AKey);
      for I := 0 to length(FBind1) - 1 do
        if MatchRegexpStr(FBind1[I].Mask, vKeyName) then begin
          if LocTestMod(FBind1[I].KMod) then
            Break;
        end;
    end;
   {$endif bUseKeyMask}

    if vEat and (moEatOnRun in FOptions) then begin
      AEat := True;
      if vFin then
        ALib.CancellPress;
    end;

    Result := vRes;
  end;


  function TMacro.CheckAreaCondition(Area :TMacroArea; ALib :TMacroLibrary) :Boolean;
  var
    vCond :TMacroCondition;
  begin
    Result := False;

    if (FArea <> []) or (length(FDlgs) > 0) or (length(FDlgs1) > 0) or
      (length(FEdts) > 0) or (length(FViews) > 0)
    then
      if not CheckArea(Area) then
        Exit;

    if (ALib <> nil) and (FCond <> []) then
      for vCond := low(TMacroCondition) to High(TMacroCondition) do begin
        if vCond in FCond then
          if not ALib.CheckCondition(vCond) then
            Exit;
      end;

    Result := True;
  end;


  function TMacro.CheckEventCondition(Area :TMacroArea; Event :TMacroEvent) :Boolean;
  begin
    Result := (Event in FEvents) and CheckArea(Area);
  end;


  function TMacro.CheckArea(Area :TMacroArea) :Boolean;
  var
    I, vPos, vLen :Integer;
    vGUID :TGUID;
    vWinInfo :TWindowInfo;
    vTitle :TString;
  begin
    Result := Area in FArea;

    if not Result and (Area = maDialog) and ((length(FDlgs) > 0) or ((length(FDlgs1) > 0))) then begin
      { Возможно, макрос назначен на конкретный диалог, ... }

      if length(FDlgs) > 0 then begin
        { ...по GUID }
        vGUID := GetTopDlgGUID;
        for I := 0 to length(FDlgs) - 1 do
          if IsEqualGUID( vGUID, FDlgs[I] ) then begin
            Result := True;
            Exit;
          end;
      end;

      if length(FDlgs1) > 0 then begin
        { ...или по Caption }
        FarGetWindowInfo(-1, vWinInfo, @vTitle);
        if vWinInfo.WindowType = WTYPE_DIALOG then
          for I := 0 to length(FDlgs1) - 1 do
            if StringMatch(FDlgs1[I], '', PTChar(vTitle), vPos, vLen, [moIgnoreCase, moWilcards]) then begin
              Result := True;
              Exit;
            end;
      end;
    end;

    if not Result and (Area = maEditor) and (length(FEdts) > 0) then begin
      FarGetWindowInfo(-1, vWinInfo, @vTitle, nil);
      if vWinInfo.WindowType = WTYPE_EDITOR then
        for I := 0 to length(FEdts) - 1 do
          if StringMatch(FEdts[I], '', PTChar(vTitle), vPos, vLen, [moIgnoreCase, moWilcards]) then begin
            Result := True;
            Exit;
          end;
    end;

    if not Result and (Area = maViewer) and (length(FViews) > 0) then begin
      FarGetWindowInfo(-1, vWinInfo, @vTitle, nil);
      if vWinInfo.WindowType = WTYPE_VIEWER then
        for I := 0 to length(FViews) - 1 do
          if StringMatch(FViews[I], '', PTChar(vTitle), vPos, vLen, [moIgnoreCase, moWilcards]) then begin
            Result := True;
            Exit;
          end;
    end;
  end;


  procedure TMacro.Execute(AKeyCode :Integer);
  var
   {$ifdef bMacroInclude}
    I :Integer;
    vMacro :TMacro;
   {$endif bMacroInclude}
    vFlags :DWORD;
    vText :TString;
  begin
    vFlags := 0;

   {$ifdef Far3}
    if moDisableOutput in FOptions then
      vFlags := vFlags or KMFLAGS_DISABLEOUTPUT;
    if not (moSendToPlugins in FOptions) then
      vFlags := vFlags or KMFLAGS_NOSENDKEYSTOPLUGINS;
   {$else}
    if moDisableOutput in FOptions then
      vFlags := vFlags or KSFLAGS_DISABLEOUTPUT;
    if not (moSendToPlugins in FOptions) then
      vFlags := vFlags or KSFLAGS_NOSENDKEYSTOPLUGINS;
   {$endif Far3}

    vText := FText;

   {$ifdef bMacroInclude}
    if Length(FIncludes) > 0 then
      for i := Length(FIncludes) - 1 downto 0 do begin
        vMacro := MacroLibrary.FindMacroByName(FIncludes[i].Name);
        if vMacro <> nil then begin
          if (mifOnce in FIncludes[i].Flags) and (vMacro.FRunCount > 0) then
            { Уже устанавливался }
          else begin
            Insert(vMacro.FText, vText, FIncludes[i].Pos);
            Inc(vMacro.FRunCount);
          end;
        end;
      end;
   {$endif bMacroInclude}

    if (moDefineAKey in FOptions) and (AKeyCode <> 0) then
      vText :=
        cAKeyMacroVar + '=' + Int2Str(AKeyCode) + ';'#13 +
        FText;

    FarPostMacro(vText, vFlags, AKeyCode);
    Inc(FRunCount);
  end;


  function KeyToName(const AKey :TKeyRec) :TString;
  begin
    Result := FarKeyToName(AKey.Key);
    if AKey.KMod <> kmPress then
      Result := Result + ':' + KeyModToName(AKey.KMod);
  end;


  function TMacro.GetBindAsStr(AMode :Integer) :TString;
  var
    I, vCount :Integer;
  begin
    Result := '';
    vCount := 0;

   {$ifdef bUseKeyMask}
    Inc(vCount, length(FBind1));
    for I := 0 to length(FBind1) - 1 do begin
      if (AMode > 1) and (Result <> '') then
        Break;
      Result := AppendStrCh(Result, FBind1[I].Mask, ' ');
    end;
   {$endif bUseKeyMask}

    Inc(vCount, length(FBind));
    for I := 0 to length(FBind) - 1 do begin
      if (AMode > 1) and (Result <> '') then
        Break;
      Result := AppendStrCh(Result, KeyToName(FBind[I]), ' ');
    end;

    if (AMode > 1) and (vCount > 1) then
      Result := Result + ' (' + Int2Str(vCount) + ')';
  end;


  function TMacro.GetAreaAsStr(AMode :Integer) :TString;
  const
    cAreaAll    = [Low(TMacroArea)..High(TMacroArea)];
    cAreaMenus  = [maMenu, maMainMenu, maUserMenu];
    cAreaOthers = [maSearch..High(TMacroArea){maAutoCompletion}] - cAreaMenus;

    procedure LocCheckArea(Area :TMacroArea);
    begin
      if Area in FArea then
        Result := AppendStrCh(Result, AreaToName(Area), ' ');
    end;

  var
    I :TMacroArea;
    vChr :array[0..6] of TChar;
  begin
    Result := '';
    if (FArea <> []) or (length(FDlgs) > 0) or (length(FDlgs1) > 0) or
      (length(FEdts) > 0) or (length(FViews) > 0) then
    begin
      if AMode <= 1 then begin
        if FArea = cAreaAll then
          Result := 'All'
        else begin
          LocCheckArea(maSHELL);
          LocCheckArea(maEDITOR);
          LocCheckArea(maVIEWER);
          for I := maDialog {maSHELL} to High(TMacroArea){maAutoCompletion} do
            LocCheckArea(I);
          if ((length(FDlgs) > 0) or ((length(FDlgs1) > 0))) and not (maDialog in FArea) then
            Result := AppendStrCh(Result, Format('%s(%d)', [AreaToName(maDialog), length(FDlgs) + length(FDlgs1)]), ' ');
          if (length(FEdts) > 0) and not (maEditor in FArea) then
            Result := AppendStrCh(Result, Format('%s(%d)', [AreaToName(maEditor), length(FEdts)]), ' ');
          if (length(FViews) > 0) and not (maViewer in FArea) then
            Result := AppendStrCh(Result, Format('%s(%d)', [AreaToName(maViewer), length(FViews)]), ' ');
        end;
      end else
      begin
        MemFillChar(@vChr, High(vChr) + 1, '.');
        vChr[High(vChr)] := #0;
        if maShell in FArea then
          vChr[0] := 'S';
        if (maEditor in FArea) or (length(FEdts) > 0) then
          vChr[1] := 'E';
        if (maViewer in FArea) or (length(FViews) > 0) then
          vChr[2] := 'V';
        if (maDialog in FArea) or (length(FDlgs) > 0) or (length(FDlgs1) > 0) then
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


  function TMacro.GetHidden :Boolean;
  begin
    Result := (FDescr = '') or (FDescr[1] = '.');
  end;


 {-----------------------------------------------------------------------------}
 { TKeyIndex                                                                   }
 {-----------------------------------------------------------------------------}

  function TKeyIndex.CompareObj(Another :TBasis; Context :TIntPtr) :Integer; {override;}
  begin
    Result := IntCompare( FKey, TKeyIndex(Another).FKey );
  end;

  function TKeyIndex.CompareKey(Key :Pointer; Context :TIntPtr) :Integer; {override;}
  begin
    Result := IntCompare( FKey, TIntPtr(Key) );
  end;



 {-----------------------------------------------------------------------------}
 { TMacroLibrary                                                               }
 {-----------------------------------------------------------------------------}

  constructor TMacroLibrary.Create; {override;}
  begin
    inherited Create;
    FMacroses := TObjList.Create;
    FKeyIndex := TObjList.Create;
   {$ifdef bLua}
    FLuaMacroses := TObjList.Create;
   {$endif bLua}
  end;


  destructor TMacroLibrary.Destroy; {override;}
  begin
   {$ifdef bLua}
    FreeObj(FLuaMacroses);
    FreeObj(FAllMacroses);
   {$endif bLua}
    FreeObj(FMacroses);
    FreeObj(FKeyIndex);
    inherited Destroy;
  end;


 {-----------------------------------------------------------------------------}

 {$ifdef bLua}
  procedure TMacroLibrary.AddLuaMacro(AWhat :Integer; const ADescr, AKeys, AAreas, AFileName :TString; ARow :Integer);
  var
    vRec :TMacroRec;
    vMacro :TMacro;
  begin
    if AWhat = 0 then begin
      FLuaMacroses.FreeAll;
      FreeObj(FAllMacroses);
      Inc(FRevision);
    end else
    begin
      InitMacro(vRec);
      vRec.Descr := ADescr;
      MacroSetKeys(vRec, AKeys);
      MacroSetAreas(vRec, AAreas);
      vRec.Row := ARow;
      vRec.Index := FLuaMacroses.Count;

      vMacro := TMacro.CreateBy(vRec, AFileName);
      FLuaMacroses.Add(vMacro);
    end;
  end;


  function TMacroLibrary.GetAllMacroses :TExList;
  var
    I :Integer;
  begin
    if FAllMacroses = nil then begin
      FAllMacroses := TExList.Create;
     {$ifdef bLua}
      for I := 0 to FLuaMacroses.Count - 1 do
        FAllMacroses.Add( FLuaMacroses[I] );
     {$endif bLua}
      for I := 0 to FMacroses.Count - 1 do
        FAllMacroses.Add( FMacroses[I] );
    end;
    Result := FAllMacroses;
  end;

 {$else}

  function TMacroLibrary.GetAllMacroses :TExList;
  begin
    Result := FMacroses;
  end;
 {$endif bLua}


 {-----------------------------------------------------------------------------}

  function TMacroLibrary.RescanMacroses(ASilence :Boolean; AHideError :Boolean = False) :Boolean;
  var
    vFolder :TString;
  begin
    Result := False;

    FSilence := ASilence;
    FHideError := AHideError;
    FLastError := '';

    vFolder := optMacroPaths;
    if vFolder = '' then
      vFolder := AddFileName(ExtractFilePath(FARAPI.ModuleName), cDefMacroFolder);

    FNewMacroses := TObjList.Create;
    try

      ScanMacroFolder(vFolder);

      if FNewMacroses <> nil then begin
       {$ifdef bLua}
        FreeObj(FAllMacroses);
       {$endif bLua}
        FreeObj(FMacroses);
        FMacroses := FNewMacroses;
        FNewMacroses := nil;
        Reindex;
        Inc(FRevision);
        Result := True;
      end;

    except
      FreeObj(FNewMacroses);
      raise;
    end;
  end;


  procedure TMacroLibrary.ScanMacroFolder(const AFolder :TString);

    function LocEnumMacroFiles(const APath :TString; const ARec :TWin32FindData) :Boolean;
    begin
      Result := ParseMacroFile(AddFileName(APath, ARec.cFileName)) or FSilence;
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
        WinEnumFilesEx(vPath, '*.' + cMacroFileExt, faEnumFiles or faSkipHidden, [efoRecursive], LocalAddr(@LocEnumMacroFiles));
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
      {TODO: Вывести в лог... }
    end else
    begin
      FreeObj(FNewMacroses);
      if AFileName <> '' then
        OpenEditor(AFileName, ARow + 1, ACol + 1, not FHideError{True} );

      if FHideError then begin
        if TParseError(ACode) <> errBadMacroSequence then
          FLastError := AMessage
        else
          FLastError := Sender.GetSequenceError;
      end else
      begin
        if TParseError(ACode) <> errBadMacroSequence then
          ShowMessage(GetMsgStr(strError), AMessage, FMSG_WARNING or FMSG_MB_OK)
        else
          Sender.ShowSequenceError;
      end;
    end;
  end;


  procedure TMacroLibrary.Reindex;
  var
    I :Integer;
    vMacro :TMacro;
  begin
    FKeyIndex.Clear;
    for I := 0 to FMacroses.Count - 1 do begin
      vMacro := FMacroses[I];
      if moCompatible in vMacro.FOptions then
        vMacro.AddToFar;
    end;
  end;

 {-----------------------------------------------------------------------------}

  function TMacroLibrary.CheckHotkey(const ARec :TKeyEventRecord) :boolean;
  var
    vRecKey, vKey :Integer;
    vPress :TKeyPress;
    vTick :DWORD;
  begin
    Result := False;
    if ARec.wVirtualKeyCode = 0 then
      Exit;

    vRecKey := KeyEventToFarKey(ARec);
    vKey := vRecKey;

//  if ARec.bKeyDown then
//    TraceF('CheckHotkey. Down=%d, Ch=%d, VK=%d, State=%x --> FarKey=%x (%s)',
//      [byte(ARec.bKeyDown), Word(ARec.UnicodeChar), ARec.wVirtualKeyCode, ARec.dwControlKeyState, vKey, FarKeyToName(vKey)]);

    if ARec.bKeyDown then begin
      vTick := GetTickCount;

      if FLastKey <> vKey then begin
        { Первое нажатие }
        vPress := kpDown;
        FCancelled := False;
        FLastKey := vKey;
        FLastShift := vKey and KEY_CTRLMASK;
        if (FLastKey = FPrevKey) and (TickCountDiff(vTick, FPressTime) < optDoubleDelay) then begin
          vPress := kpDouble;
          FPressTime := 0;
        end else
          FPressTime := vTick;
      end else
      begin
        { Автоповтор }
        vPress := kpAuto;
        if (FPressTime <> 0) and (TickCountDiff(vTick, FPressTime) > optHoldDelay) then begin
          FPressTime := 0;
          vPress := kpHold;
        end;
      end;

    end else
    begin
      vPress := kpUp;
      if (FLastKey and not KEY_CTRLMASK) = 0 then
        vKey := 0;
      if vKey = 0 then
        vKey := FLastKey
      else
      if vKey <> FLastKey then
        vKey := 0;

      FPrevKey := vKey;

      if vKey = 0 then begin
        vKey := FLastShift;
        if vKey <> 0 then
          vPress := kpShiftUp;
      end;

      FLastShift := vRecKey and KEY_CTRLMASK;
      FLastKey := 0;
    end;

//  if True {and (vKey <> 0)} {and ARec.bKeyDown} then
//    TraceF('CheckHotkey (Press=%d, Repeat=%d, vChr=%x, vKey=%x -> %x "%s":%d)',
//      [byte(ARec.bKeyDown), ARec.wRepeatCount, Word(ARec.UnicodeChar), vRecKey, vKey, FarKeyToName(vKey), byte(vPress)]);

    if not FCancelled then begin

      if vKey <> 0 then
        Result := CheckForRun(vKey, ARec.UnicodeChar, vPress);

    end else
    begin
      if not ARec.bKeyDown then
        FCancelled := False;
      Result := True;
    end;
  end;


  procedure TMacroLibrary.CancellPress;
  begin
    FCancelled := True;
  end;


  function TMacroLibrary.CheckMouse(const ARec :TMouseEventRecord) :boolean;
  var
    vKey :Integer;
    vDown, vDouble :Boolean;
    vPress :TKeyPress;
  begin
    Result := False;
    if ARec.dwEventFlags and (MOUSE_MOVED + DOUBLE_CLICK + MOUSE_WHEELED + MOUSE_HWHEELED) = MOUSE_MOVED then
      Exit;

    vKey := MouseEventToFarKeyEx(ARec, FMouseState, vDown, vDouble);
    FMouseState := ARec.dwButtonState;
    FLastKey := 0;
    FPrevKey := 0;
    FCancelled := False;
//  TraceF('CheckMouse (Flag=%d, Buttons=%d, vKey=%x "%s", Press=%d, Double=%d)',
//    [ARec.dwEventFlags, ARec.dwButtonState, vKey, FarKeyToName(vKey), Byte(vPress), byte(vDouble)]);

    vPress := kpDown;
    if vDown and vDouble then
      vPress := kpDouble;
    if not vDown then
      vPress := kpUp;

    if vKey <> 0 then
      Result := CheckForRun(vKey, #0, vPress);
  end;


  function TMacroLibrary.CheckForRun(AKey :Integer; AChr :TChar; APress :TKeyPress) :boolean;
  var
    vArea :TMacroArea;
    vList :TRunList;
  begin
    Result := False;
    if AKey <> 0 then begin
      vList := TRunList.Create;
      try
        vArea := TMacroArea(FarGetMacroArea);
//      TraceF('Area: %d', [byte(vArea)]);

        FindMacroses(vList, vArea, AKey, APress, Result);
        CheckPriority(vList);

        if vList.Count > 0 then begin
          if ((AKey and KEY_CTRLMASK = 0) or (AKey and KEY_CTRLMASK = KEY_SHIFT)) and
            (word(AChr) > 32) and IsCharAlphaNumeric(AChr)
          then
            vList.KeyCode := word(AChr)
          else
            vList.KeyCode := AKey;

//        if (vList.Count = 1) and True then begin
//          { Быстрый запуск. Возможны глюки (?) }
//          TMacro(vList[0]).Execute(vList.KeyCode)
//        end else
//        begin
            FarAdvControl(ACTL_SYNCHRO, vList);
            vList := nil;
//        end;

        end;
      finally
        FreeObj(vList);
      end;
    end;
  end;


  procedure TMacroLibrary.FindMacroses(AList :TExList; Area :TMacroArea; AKey :Integer; APress :TKeyPress; var AEat :Boolean);


    procedure LocFindAll(AList :TKeyIndex);
    var
      I, J :Integer;
      vMacro :TMacro;
      vMatch :Boolean;
     {$ifdef bUseKeyMask}
      vKeyName :TString;
     {$endif bUseKeyMask}
    begin
     {$ifdef bUseKeyMask}
      vKeyName := FarKeyToName(AKey);
     {$endif bUseKeyMask}

      for I := 0 to FMacroses.Count - 1 do begin
        vMacro := FMacroses[I];
        if not (moCompatible in vMacro.FOptions) then begin
          vMatch := False;

//        if vMacro.Descr = 'Привет' then
//          NOP;

          for J := 0 to length(vMacro.FBind) - 1 do
            if vMacro.FBind[J].Key = AKey then begin
              vMatch := True;
              break;
            end;

         {$ifdef bUseKeyMask}
          if not vMatch and (length(vMacro.FBind1) > 0) then begin
            for J := 0 to length(vMacro.FBind1) - 1 do
              if MatchRegexpStr(vMacro.FBind1[J].Mask, vKeyName) then begin
                vMatch := True;
                break;
              end;
          end;
         {$endif bUseKeyMask}

          if vMatch then
            AList.Add(vMacro);
        end;
      end;
    end;


    procedure LocFind(AKey :Integer);
    var
      I :Integer;
      vMacro :TMacro;
      vList :TKeyIndex;
    begin
      if FKeyIndex.FindKey( Pointer(TIntPtr(AKey)), 0, [foBinary], I) then
        vList := FKeyIndex[I]
      else begin
        vList := TKeyIndex.Create;
        vList.FKey := AKey;
        LocFindAll(vList);
        FKeyIndex.Insert(I, vList);
      end;

      for I := 0 to vList.Count - 1 do begin
        vMacro := vList[ I ];
        if vMacro.CheckKeyCondition(Area, AKey, APress, Self, AEat) then
          AList.Add(vMacro);
      end;
    end;


  begin
    InitConditions;
    LocFind(AKey);

    if (AList.Count = 0) and (AKey and KEY_CTRLMASK = KEY_SHIFT) then begin
      AKey := AKey and not KEY_CTRLMASK;
      if (AKey >= byte('A')) and (AKey <= byte('Z')) then
        LocFind(AKey);
    end else
    if (AList.Count = 0) and (AKey and (KEY_RCTRL + KEY_RALT) <> 0) then begin
      if AKey and KEY_RCTRL <> 0 then
        AKey := (AKey and not KEY_RCTRL) or KEY_CTRL;
      if AKey and KEY_RALT <> 0 then
        AKey := (AKey and not KEY_RALT) or KEY_ALT;
      LocFind(AKey);
    end;
  end;


  function TMacroLibrary.FindMacroByName(const AName :TString) :TMacro;
  var
    I :Integer;
    vMacro :TMacro;
  begin
    Result := nil;
    for I := 0 to FMacroses.Count - 1 do begin
      vMacro := FMacroses[I];
      if StrEqual(AName, vMacro.Name) then begin
        Result := vMacro;
        Exit;
      end;
    end;
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
      CheckPriority(vList);

      if vList.Count > 0 then begin
        vList.RunAll := True;
        FarAdvControl(ACTL_SYNCHRO, vList);
        vList := nil;
      end;

    finally
      FreeObj(vList);
    end;
  end;


  procedure TMacroLibrary.CheckPriority(AList :TExList);
    { Если в списке есть более приоритетные макросы - оставляем только их }
  var
    I, vMax :Integer;
  begin
    vMax := -MaxInt;
    for I := 0 to AList.Count - 1 do
      vMax := IntMax(vMax, TMacro(AList[I]).FPriority);
    for I := AList.Count - 1 downto 0 do
      if TMacro(AList[I]).FPriority < vMax then
        AList.Delete(I);
  end;


  procedure TMacroLibrary.ShowList(AList :TExList);
  var
    vIndex :Integer;
    vMacro :TMacro;
  begin
    vIndex := -1;
    if ListMacrosesDlg(AList, vIndex) then begin
      vMacro := AList[vIndex];
      FarAdvControl(ACTL_SYNCHRO, vMacro);
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
        if vMacro.CheckAreaCondition(vArea, Self) then
          vList.Add(vMacro);
      end;

      vIndex := -1;
      if ListMacrosesDlg(vList, vIndex) then begin
        vMacro := vList[vIndex];
        FarAdvControl(ACTL_SYNCHRO, vMacro);
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
    if ListMacrosesDlg(AllMacroses, vIndex) then begin
      vMacro := AllMacroses[vIndex];
      FarAdvControl(ACTL_SYNCHRO, vMacro);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TMacroLibrary.InitConditions;
  begin
    FWindowType := -1;
    FDialogID   := 0;
    FConditions := [];
  end;


  function TMacroLibrary.CheckCondition(ACond :TMacroCondition) :Boolean;

    procedure InitWindowType;
    var
      vWinInfo :TWindowInfo;
    begin
      if FarGetWindowInfo(-1, vWinInfo) then begin
        FWindowType := vWinInfo.WindowType;
        if FWindowType = WTYPE_DIALOG then begin
         {$ifdef Far3}
          FDialogID := vWinInfo.ID;
         {$else}
          FDialogID := GetTopDlgHandle;
         {$endif Far3}
        end;
      end;
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
      vCtrlID :Integer;
      vSelect :TEditorSelect;
      vSelected :Boolean;
    begin
      vSelected := False;
      if FWindowType = WTYPE_EDITOR then begin
        FillZero(vEdtInfo, SizeOf(vEdtInfo));
       {$ifdef Far3}
        vEdtInfo.StructSize := SizeOf(vEdtInfo);
       {$endif Far3}
        FarEditorControl(ECTL_GETINFO, @vEdtInfo);
        vSelected := vEdtInfo.BlockType <> BTYPE_NONE;
      end else
      if FWindowType = WTYPE_VIEWER then begin
//      FConditions := FConditions + [mcBlockNotSelected]
      end else
      if (FWindowType = WTYPE_DIALOG) and (FDialogID <> 0) then begin
        vCtrlID := FarSendDlgMessage(FDialogID, DM_GETFOCUS, 0, 0);
        if vCtrlID >= 0 then begin
          FillZero(vSelect, SizeOf(vSelect));
         {$ifdef Far3}
          vSelect.StructSize := SizeOf(vSelect);
         {$endif Far3}
          if FarSendDlgMessage(FDialogID, DM_GETSELECTION, vCtrlID, @vSelect) = 1 then
            vSelected := vSelect.BlockType <> BTYPE_NONE;
        end;
      end;
      SetMacroCondition(FConditions, mcBlockNotSelected, vSelected);
    end;

    procedure GetCondition(AHandle :THandle; var AIsPlugin, AIsFolder, AHasSelected :Boolean);
    var
      vPanInfo :TPanelInfo;
      vItem :PPluginPanelItem;
    begin
      FillZero(vPanInfo, SizeOf(vPanInfo));
     {$ifdef Far3}
      vPanInfo.StructSize := SizeOf(vPanInfo);
      FARAPI.Control(AHandle, FCTL_GETPANELINFO, 0, @vPanInfo);
      AIsPlugin := PFLAGS_PLUGIN and vPanInfo.Flags <> 0;
     {$else}
      FARAPI.Control(AHandle, FCTL_GETPANELINFO, 0, @vPanInfo);
      AIsPlugin := vPanInfo.Plugin = 1;
     {$endif Far3}

      AIsFolder := False; AHasSelected := False;
      if vPanInfo.ItemsNumber > 0 then begin
        vItem := FarPanelItem(AHandle, FCTL_GETCURRENTPANELITEM, 0);
        try
         {$ifdef Far3}
          AIsFolder := vItem.FileAttributes and faDirectory <> 0;
         {$else}
          AIsFolder := vItem.FindData.dwFileAttributes and faDirectory <> 0;
         {$endif Far3}
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
 {$ifdef Far3}
 {$else}
  FreeObj(DlgStack);
 {$endif Far3}
end.

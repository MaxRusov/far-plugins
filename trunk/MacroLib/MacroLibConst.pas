{$I Defines.inc}

unit MacroLibConst;

{******************************************************************************}
{* (c) 2011 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Macro Library                                                          *}
{******************************************************************************}

interface

  uses
    Windows,

   {$ifdef Far3}
    Plugin3,
   {$else}
    PluginW,
   {$endif Far3}
    FarKeysW,

    MixTypes,
    MixUtils,
    MixFormat,
    MixStrings,
    MixClasses,
    MixWinUtils,

    FarCtrl,
    FarConfig;
    

  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMMacroCommands,
      strMListOfAllMacroses,
      strMUpdateMacroses,
      strMOptions,

      strMProcessHotkeys,
      strMProcessMouse,
      strMMacroPaths,

      strMacroPathsTitle,
      strMacroPathsPrompt,

      strMacrosesTitle,

      strName,
      strDescription,
      strMacroarea,
      strHotkeys,
      strPriority,
      strFileName,
      strSequence,
(*
      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,
*)
      strMacroNotSpec,
      strMacroNotFound,
      strKeyNotSpec,
      strUnknownKeyName,

      strMacroParserErrors
    );


  const
    cPluginName = 'MacroLib';
    cPluginDescr = 'Macro Library FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID   :TGUID = '{84884660-5B2F-4581-9282-96E00AE109A2}';
    cMenuID     :TGUID = '{0E8A1143-3619-41B9-BA61-5A5C899E38C7}';
   {$else}
    cPluginGUID     = $424C434D;
   {$endif Far3}

    cDefMacroFolder = 'Macros';
    cMacroFileExt   = 'FML';

    cMacroPathName  = 'MacroLib.Paths';

    cMacroListDlgID :TGUID = '{F002A86D-BB4A-4A8F-A875-30286C06414B}';


  var
    optProcessHotkey :Boolean = True;   { Обрабатывать нажатия горячих клавиш }
    optProcessMouse  :Boolean = True;   { Обрабатывать события мыши }
    optMacroPaths    :TString = '';     { Путь к каталогу с макросами }

    optXLatMask      :Boolean = True;   { Автоматическое XLAT преобразование при поиске }
    optShowHints     :Boolean = True;

    optShowBind      :Integer = 0;
    optShowArea      :Integer = 0;
    optShowFile      :Integer = 0;

    optSortMode      :Integer = 0;

    optFoundColor    :TFarColor;

    optDoubleDelay   :Integer = 500;
    optHoldDelay     :Integer = 500;

    optCmdPrefix     :TString = 'FML';

  var
    FFarExePath      :TString;


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  procedure HandleError(AError :Exception);

  function NameToFarKey(AName :PTChar) :Integer;
  function FarKeyToName(AKey :Integer) :TString;
  
  procedure PluginConfig(AStore :Boolean);

  procedure ToggleOption(var AOption :Boolean);
  procedure RestoreDefColor;

  procedure OpenEditor(const AFileName :TString; ARow, ACol :Integer; ASelectLine :Boolean = False; ATopLine :Integer = 0);

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;

  function GetMsgStr(AMess :TMessages) :TString;
  begin
    Result := FarCtrl.GetMsgStr(Integer(AMess));
  end;


  procedure AppErrorId(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('Macro Library', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;

 {-----------------------------------------------------------------------------}

  function NameToFarKey(AName :PTChar) :Integer;
  var
    vTmp :array[0..1] of TChar;
   {$ifdef Far3}
    vKey :INPUT_RECORD;
   {$endif Far3}
  begin
    if ((AName + 1)^ = #0) and IsCharAlpha(AName^) then begin
      vTmp[0] := CharUpCase(AName^);
      vTmp[1] := #0;
      AName := @vTmp[0];
    end;

   {$ifdef Far3}
    Result := -1;
    FillZero(vKey, SizeOf(vKey));
    if FARSTD.FarNameToInputRecord(AName, vKey) then
      if vKey.EventType = KEY_EVENT then
        Result := KeyEventToFarKey(vKey.Event.KeyEvent)
      else
      if vKey.EventType = _MOUSE_EVENT then
        Result := MouseEventToFarKey(vKey.Event.MouseEvent);
   {$else}
    Result := FARSTD.FarNameToKey(AName);
   {$endif Far3}
  end;


  function FarKeyToName(AKey :Integer) :TString;
 {$ifdef Far3}
  var
    vInput :INPUT_RECORD;
    vLen :Integer;
  begin
    Result := '';
    if FarKeyToInputRecord(AKey, vInput) then begin
      vLen := FARSTD.FarInputRecordToName(vInput, nil, 0);
      if vLen > 0 then begin
        SetLength(Result, vLen - 1);
        FARSTD.FarInputRecordToName(vInput, PTChar(Result), vLen);
      end;
    end;
 {$else}
  var
    vLen :Integer;
  begin
    Result := '';
    vLen := FARSTD.FarKeyToName(AKey, nil, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen - 1);
      FARSTD.FarKeyToName(AKey, PTChar(Result), vLen);
    end;
 {$endif Far3}
  end;


 {-----------------------------------------------------------------------------}

  procedure PluginConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if not Exists then
          Exit;

        LogValue('ProcessHotkey', optProcessHotkey);
        LogValue('ProcessMouse', optProcessMouse);
        StrValue('MacroPaths', optMacroPaths);

        IntValue('ShowBind', optShowBind);
        IntValue('ShowArea', optShowArea);
        IntValue('ShowFile', optShowFile);

        IntValue('SortMode', optSortMode);

        LogValue('XLatMask', optXLatMask);
        LogValue('ShowHints', optShowHints);

        IntValue('DoubleDelay', optDoubleDelay);
        IntValue('HoldDelay', optHoldDelay);

//      optCmdPrefix := RegQueryStr(vKey, 'CmdPrefix', optCmdPrefix);

      finally
        Destroy;
      end;
  end;


 {-----------------------------------------------------------------------------}

  procedure ToggleOption(var AOption :Boolean);
  begin
    AOption := not AOption;
    PluginConfig(True);
  end;


  procedure RestoreDefColor;
  begin
    optFoundColor := MakeColor(clLime, 0);
  end;


 {-----------------------------------------------------------------------------}

  function EditorFile(AWindow :Integer) :TString;
  var
    vWinInfo :TWindowInfo;
    vName :TString;
  begin
    Result := '';
    FarGetWindowInfo(AWindow, vWinInfo, @vName, nil);
    if vWinInfo.WindowType = WTYPE_EDITOR then
      Result := vName;
  end;


  procedure GotoPosition(ARow, ACol :Integer; ATopLine :Integer = 0);
  var
    vNewTop, vHeight :Integer;
    vPos :TEditorSetPosition;
    vInfo :TEditorInfo;
  begin
    Dec(ARow); Dec(ACol);
    vNewTop := -1;
    FillZero(vInfo, SizeOf(vInfo));
    if FarEditorControl(ECTL_GETINFO, @vInfo) = 1 then begin
      if ATopLine = 0 then
        vHeight := vInfo.WindowSizeY
      else
        vHeight := ATopLine - 1{Строка состояния редактора};
      if (ARow < vInfo.TopScreenLine) or (ARow >= vInfo.TopScreenLine + vHeight) then
        vNewTop := RangeLimit(ARow - (vHeight div 2), 0, MaxInt{???});
    end;
    vPos.TopScreenLine := vNewTop;
    vPos.CurLine := ARow;
    vPos.CurPos := ACol;
    vPos.CurTabPos := -1;
    vPos.LeftPos := -1;
    vPos.Overtype := -1;
    FarEditorControl(ECTL_SETPOSITION, @vPos);
  end;


  procedure OpenEditor(const AFileName :TString; ARow, ACol :Integer; ASelectLine :Boolean = False; ATopLine :Integer = 0);
  var
    I, vCount :Integer;
    vFileName :TString;
    vFarFileName :TFarStr;
    vSel :TEditorSelect;
    vFound :Boolean;
  begin
    vFileName := EditorFile(-1);
    vFound := StrEqual(vFileName, AFileName);
    if not vFound then begin
      vCount := FarAdvControl(ACTL_GETWINDOWCOUNT, nil);
      for I := 0 to vCount - 1 do begin
        vFileName := EditorFile(I);
        vFound := StrEqual(vFileName, AFileName);
        if vFound then begin
         {$ifdef Far3}
          FARAPI.AdvControl(PluginID, ACTL_SETCURRENTWINDOW_, I, nil);
         {$else}
          FarAdvControl(ACTL_SETCURRENTWINDOW, Pointer(TIntPtr(I)));
         {$endif Far3}
          FarAdvControl(ACTL_COMMIT, nil);
          Break;
        end;
      end;
    end;

    if vFound then
      GotoPosition(ARow, ACol, ATopLine)
    else begin
      vFarFileName := AFileName;
      FARAPI.Editor(PFarChar(vFarFileName), nil, 0, 0, -1, -1, EF_NONMODAL or EF_IMMEDIATERETURN or EF_ENABLE_F6, ARow, ACol, CP_AUTODETECT);
      if ATopLine <> 0 then
        GotoPosition(ARow, ACol, ATopLine);
    end;

    if ASelectLine and (ARow > 0) then begin
      vSel.BlockType := BTYPE_STREAM;
      vSel.BlockStartLine := ARow - 1;
      vSel.BlockStartPos := 0;
      vSel.BlockWidth := 256;
      vSel.BlockHeight := 1;

      FarEditorControl(ECTL_SELECT, @vSel);
      FarEditorControl(ECTL_REDRAW, nil);
    end;
  end;

end.

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

{$I Defines.inc}

unit VisCompCtrl;

interface

  uses
    Windows,
    ShellAPI,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    Far_API,
    FarCtrl,
    FarMenu,
    FarConfig,
    FarColorDlg;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strLeftFolder,
      strRightFolder,
      strFileMask,
      strRecursive,
      strSkipHidden,
      strDoNotScanOrphan,
      strCompareContents,
      strCompareAsText,
      strCompareSetup,
      strInvalidPath,

      strCompareTitle,
      strCompareCommand,

      strCompareFoldersTitle,
      strMCompareFiles,
      strMView1,
      strMEdit1,
      strMCopy1,
      strMMove1,
      strMDelete1,
      strMCompareContents,
      strMGotoFile,
      strMSendToTemp,
      strMSortBy1,
      strMOptions1,

      strOptionsTitle1,
      strMShowSame,
      strMShowDiff,
      strMShowOrphan,
      strMShowLeftOrphan,
      strMShowRightOrphan,
      strMCompContents,
      strMCompSize,
      strMCompTime,
      strMCompAttr,
      strMCompFolderAttrs,
      strMShowFolderSummary,
      strMShowSize,
      strMShowTime,
      strMShowAttrs,
      strMShowFolderAttrs,
      strMHilightDiff,
      strMUnfold,
      strMColors1,

      strSortByTitle,
      strSortByName,
      strSortByExt,
      strSortByDate,
      strSortBySize,
      strDiffAtTop,

      strCompTextsTitle,
      strMNextDiff,
      strMPrevDiff,
      strMView2,
      strMEdit2,
      strMCodePage,
      strMOptions2,

      strOptionsTitle2,
      strMIgnoreEmptyLines,
      strMIgnoreSpaces,
      strMIgnoreCase,
      strMIgnoreCRLF,
      strMShowLineNumbers,
      strMShowCurrentRows,
      strMHilightRowDiff,
      strMShowSpaces,
      strMShowCRLF,
      strMHorizontalDivide,
      strMColors2,

      strCodePages,
      strMAnsi,
      strMOEM,
      strMUnicode,
      strMUTF8,
      strMDefault,
      strMDefaultCodePage,

      strColorsTitle,
      strClWindow,
      strClCurrentLine,
      strClSelectedLine,
      strClHilightedLine,
      strClSameItem,
      strClOrphanItem,
      strClDiffItem,
      strClOlderItem,
      strClFoundText,
      strClCaption1,

      strClNormalText,
      strClSelectedText,
      strClNewLine,
      strClDelLine,
      strClDiffLine,
      strClDiffChars,
      strClLineNumbers,
      strClCaption2,
      strClCursor,
      strClPCursor,
      strClSpecSymbols,
      strRestoreDefaults,

      strAutoscroll,
      strTabSize,
      strMaxTextSize,
      strErrInvalidTabSize,

      strCompareProgress,
      strProgressInfo1,
      strProgressInfo2,

      strInterrupt,
      strInterruptPrompt,
      strYes,
      strNo,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,

      strDelete,
      strDeleteFile,
      strDeleteFolder,
      strDeleteNItems,
      strBothSides,
      strLeftSide,
      strRightSide,
      strDeleteBut,

      strWarning,
      strDeleteReadOnlyFile,
      strDeleteNotEmptyFolder,
      strDelete1But,
      strAllBut,
      strSkipBut,
      strSkipAllBut,

      strOk,
      strCancel
    );


 {-----------------------------------------------------------------------------}

   const
    cPluginName = 'VisualCompare';
    cPluginDescr = 'VisualCompare FAR plugin';
    cPluginAuthor = 'Max Rusov';

   {$ifdef Far3}
    cPluginID    :TGUID = '{AF4DAB38-C00A-4653-900E-7A8230308010}';
    cMenuID      :TGUID = '{2E2102A3-412F-4162-A5B5-9906F8679691}';
    cConfigID    :TGUID = '{9AE80AE6-15D9-4AD4-BECF-46C1182EAE65}';
   {$else}
//  cPluginID    = ...;
   {$endif Far3}


  const
    smByName  = 1;
    smByExt   = 2;
    smByDate  = 3;
    smBySize  = 4;

  const
    cDefaultLang   = 'English';
    cMenuFileMask  = '*.mnu';

    cPlugRegFolder = 'VisComp';
    cPlugColorRegFolder = 'Colors';

    cPlugMenuPrefix = 'vc';
    cSVNFakeDrive = 'svn:';
    cPlugFakeDrive = 'plugin:';

    cNormalIcon = '['#$18']';
    cMaximizedIcon = '['#$12']';

    cPromptDlgID  :TGUID = '{4D75034E-8547-4D1B-9FDC-337CF4633EA8}';
    cCompareDlgID :TGUID = '{6DA86506-4033-45E0-BD7A-FF57397FD817}';
    cTextDlgID    :TGUID = '{78DBDD6F-74A0-41E4-91FC-DE5707CF63F5}';


  const
    cFormatNames :array[TStrFileFormat] of TString = ('Ansi', 'OEM', 'Unicode', 'UTF8', '');


  var
    optCompareCmd          :TString = '';

    optScanRecursive       :Boolean = True;
    optNoScanHidden        :Boolean = True;
    optNoScanOrphan        :Boolean = True;
    optScanContents        :Boolean = True;   { Сравнивать содержимое }
    optCompareAsText       :Boolean = False;  { ...как текст (по возможности) }
    optScanFileMask        :TString = '*.*';

    optShowFilesInFolders  :Boolean = True;
    optShowSize            :Boolean = True;
    optShowTime            :Boolean = True;
    optShowAttr            :Boolean = False;
    optShowFolderAttrs     :Boolean = False;

    optShowLinesNumber     :Boolean = True;    { Показывать номера строк }
    optShowSpaces          :Boolean = False;   { Показывать пробелы и символы табуляции }
    optShowCRLF            :Boolean = False;   { Показывать символы завершения строк }
    optShowCurrentRows     :Boolean = True;    { Показывать снизу сравнение для текущей строки }
    optHilightRowsDiff     :Boolean = True;    { Выделять цветом различия в строке }
    optTextHorzDiv         :Boolean = False;   { Горизонтальное разделение окна сравнения}

    optCompareContents     :Boolean = True;
    optCompareSize         :Boolean = True;
    optCompareTime         :Boolean = True;
    optCompareAttr         :Boolean = True;
    optCompareFolderAttrs  :Boolean = False;

    optShowSame            :Boolean = True;
    optShowDiff            :Boolean = True;
//  optShowOrphan          :Boolean = True;
    optShowLeftOrphan      :Boolean = True;
    optShowRightOrphan     :Boolean = True;

    optHilightDiff         :Boolean = True;
    optDiffAtTop           :Boolean = True;
    optFileSortMode        :Integer = smByName;

    optTextIgnoreEmptyLine :Boolean = True;    { Игнорировать пустые строки }
    optTextIgnoreSpace     :Boolean = True;    { Игнорировать пробельные символы }
    optTextIgnoreCase      :Boolean = True;    { Игнорировать регистр }
    optTextIgnoreCRLF      :Boolean = True;    { Игнорировать символы окончания строк }

    optMaximized           :Boolean = False;

    optSpaceChar           :TChar   = #$B7;
    optTabChar             :TChar   = #$1A; //#$BB;
    optTabSpaceChar        :TChar   = ' ';
    optShowCursor          :Boolean = False;   { Показывать мигающий курсор (сильно тормозит :( ) }

    optTabSize             :Integer = 8;
    optEdtAutoscroll       :Boolean = False;   { Автоматически переходить на первое различие }
    optTextFileSizeLimit   :Integer = 10 * 1024 * 1024;

    optDefaultFormat       :TStrFileFormat = sffAnsi;

  var
    optOptimization1       :Boolean = True;
    optOptimization2       :Boolean = True;

    optPostOptimization    :Boolean = False;    { Оптимизация сравнения }

  var
    optDlgColor            :TFarColor;
    optCurColor            :TFarColor;
    optSelColor            :TFarColor;
    optDiffColor           :TFarColor;
    optSameColor           :TFarColor;
    optOrphanColor         :TFarColor;
    optOlderColor          :TFarColor;
    optNewerColor          :TFarColor;
    optFoundColor          :TFarColor;
    optHeadColor           :TFarColor;

    optTextColor           :TFarColor;
    optTextSelColor        :TFarColor;
    optTextNewColor        :TFarColor;
    optTextDelColor        :TFarColor;
    optTextDiffStrColor1   :TFarColor;
    optTextDiffStrColor2   :TFarColor;
    optTextNumColor        :TFarColor;
    optTextHeadColor       :TFarColor;
    optTextActCursorColor  :TFarColor;
    optTextPasCursorColor  :TFarColor;
    optTextSpecColor       :TFarColor;         { Цвет спец-символов (Space, Tab, CR, LF) }


  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

  procedure AppErrorID(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  procedure HandleError(AError :Exception);

  procedure RestoreDefFilesColor;
  procedure RestoreDefTextColor;

  procedure ReadSetup;
  procedure WriteSetup;
  procedure ReadSetupColors;
  procedure WriteSetupColors;

  function ShellOpen(AWnd :THandle; const FName, Param :TString) :Boolean;

  function GetPanelDir(Active :Boolean) :TString;

  function IsSpecialPath(const AName :TString) :boolean;
  function FarExpandFileNameEx(const AName :TString) :TString;

  function ReduceFileName(const AName :TString; ALen :Integer) :TString;
  
  function GetCodePage(var AFormat :TStrFileFormat) :Boolean;

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


  procedure AppErrorID(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('Visual Compare', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


  procedure PluginConfig(AStore :Boolean);
  var
    vFmt :Integer;
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if Exists then begin
          StrValue('CompareCmd', optCompareCmd);

          LogValue('ScanRecursive', optScanRecursive);
          LogValue('NoScanHidden', optNoScanHidden);
          LogValue('NoScanOrphan', optNoScanOrphan);
          LogValue('ScanContents', optScanContents);
          LogValue('CompareAsText', optCompareAsText);
          StrValue('ScanFileMask', optScanFileMask);

          LogValue('ShowFilesInFolders', optShowFilesInFolders);

          LogValue('ShowSize', optShowSize);
          LogValue('ShowTime', optShowTime);
          LogValue('ShowAttr', optShowAttr);
          LogValue('ShowFolderAttrs', optShowFolderAttrs);

          LogValue('ShowLinesNumber', optShowLinesNumber);
          LogValue('ShowSpaces', optShowSpaces);
          LogValue('ShowCRLF', optShowCRLF);
          LogValue('ShowCurrentRows', optShowCurrentRows);
          LogValue('HilightRowsDiff', optHilightRowsDiff);
          LogValue('TextHorzDiv', optTextHorzDiv);

          LogValue('HilightDiff', optHilightDiff);
          LogValue('DiffAtTop', optDiffAtTop);
          IntValue('SortMode', optFileSortMode);

          LogValue('CompareContents', optCompareContents);
          LogValue('CompareSize', optCompareSize);
          LogValue('CompareTime', optCompareTime);
          LogValue('CompareAttr', optCompareAttr);
          LogValue('CompareFolderAttrs', optCompareFolderAttrs);

          LogValue('TextIgnoreEmptyLine', optTextIgnoreEmptyLine);
          LogValue('TextIgnoreSpace', optTextIgnoreSpace);
          LogValue('TextIgnoreCase', optTextIgnoreCase);
          LogValue('TextIgnoreCRLF', optTextIgnoreCRLF);

          LogValue('Maximized', optMaximized);

//        Byte(optDefaultFormat) := IntMin(RegQueryInt(vKey, 'DefaultFormat', Byte(optDefaultFormat)), Byte(sffAuto) - 1); 

          vFmt := Byte(optDefaultFormat);
          IntValue('DefaultFormat', vFmt);
          if not AStore and (vFmt >= 0) and (vFmt < byte(sffAuto)) then
            Byte(optDefaultFormat) := vFmt;

          LogValue('AutoScroll', optEdtAutoscroll);
          IntValue('TabSize', optTabSize);
          IntValue('MaxTextSize', optTextFileSizeLimit);
        end;
      finally
        Destroy;
      end;
  end;


  procedure ReadSetup;
  begin
    PluginConfig(False);
  end;


  procedure WriteSetup;
  begin
    PluginConfig(True);
  end;



  procedure ColorsConfig(AStore :Boolean);
  begin
    with TFarConfig.CreateEx(AStore, cPluginName) do
      try
        if Exists then begin
          ColorValue('FDlgColor',  optDlgColor);
          ColorValue('FCurColor',  optCurColor);
          ColorValue('FSelColor',  optSelColor);
          ColorValue('FDiffColor',  optDiffColor);
          ColorValue('FSameColor', optSameColor);
          ColorValue('FOrphanColor', optOrphanColor);
          ColorValue('FOlderColor', optOlderColor);
          ColorValue('FNewerColor', optNewerColor);
          ColorValue('FFoundColor', optFoundColor);
          ColorValue('FHeadColor', optHeadColor);

          ColorValue('TColor', optTextColor);
          ColorValue('TSelColor', optTextSelColor);
          ColorValue('TDiffColor', optTextNewColor);
          ColorValue('TDiffColor2', optTextDelColor);
          ColorValue('TDiffStrColor1', optTextDiffStrColor1);
          ColorValue('TDiffStrColor2', optTextDiffStrColor2);
          ColorValue('TNumColor', optTextNumColor);
          ColorValue('THeadColor', optTextHeadColor);
          ColorValue('TCursorColor', optTextActCursorColor);
          ColorValue('TPCursorColor', optTextPasCursorColor);
          ColorValue('TSpecColor', optTextSpecColor);
        end;
      finally
        Destroy;
      end;
  end;


  procedure ReadSetupColors;
  begin
    ColorsConfig(False);
  end;


  procedure WriteSetupColors;
  begin
    ColorsConfig(TRue);
  end;


  procedure RestoreDefFilesColor;
  begin
    optDlgColor      := UndefColor;
    optCurColor      := UndefColor;
    optSelColor      := MakeColor(clBlack, clGreen);
    optDiffColor     := MakeColor(clBlack, clCyan);
    optSameColor     := MakeColor(clGray, clBlack);
    optOrphanColor   := MakeColor(clBlue, clBlack);
    optOlderColor    := MakeColor(clMaroon, clBlack);
    optNewerColor    := MakeColor(clRed, clBlack);
    optFoundColor    := MakeColor(clLime, clBlack);
    optHeadColor     := MakeColor(clWhite, clGreen);
  end;


  procedure RestoreDefTextColor;
  begin
    optTextColor          := UndefColor;
    optTextSelColor       := UndefColor;
    optTextNewColor       := MakeColor(clBlack, clCyan);   // $B0;
    optTextDelColor       := MakeColor(clBlack, clSilver); // $70;
    optTextDiffStrColor1  := MakeColor(clBlack, clWhite);  // $F0;
    optTextDiffStrColor2  := MakeColor(clBlack, clCyan);   // $B0;
    optTextNumColor       := MakeColor(clGray, clBlack);   // $08;
    optTextHeadColor      := MakeColor(clWhite, clGreen);  // $2F;
    optTextActCursorColor := MakeColor(clYellow, clRed);   // $CE;
    optTextPasCursorColor := MakeColor(clBlack, clYellow); // $E0;
    optTextSpecColor      := MakeColor(clGray, clBlack);   // $08;
  end;


 {-----------------------------------------------------------------------------}

  function ShellOpenEx(AWnd :THandle; const FName, Param :TString; AMask :ULONG;
    AShowMode :Integer; AInfo :PShellExecuteInfo) :Boolean;
  var
    vInfo :TShellExecuteInfo;
  begin
//  Trace(FName);
    if not Assigned(AInfo) then
      AInfo := @vInfo;
    FillChar(AInfo^, SizeOf(AInfo^), 0);
    AInfo.cbSize        := SizeOf(AInfo^);
    AInfo.fMask         := AMask;
    AInfo.Wnd           := AWnd {AppMainForm.Handle};
    AInfo.lpFile        := PTChar(FName);
    AInfo.lpParameters  := PTChar(Param);
    AInfo.nShow         := AShowMode;
    Result := ShellExecuteEx(AInfo);
  end;


  function ShellOpen(AWnd :THandle; const FName, Param :TString) :Boolean;
  begin
    Result := ShellOpenEx(AWnd, FName, Param, 0{ or SEE_MASK_FLAG_NO_UI}, SW_Show, nil);
  end;


  function GetPanelDir(Active :Boolean) :TString;
  var
    vHandle :THandle;
    vInfo  :TPanelInfo;
    vPlugin :Boolean;
  begin
    Result := '';
    vHandle := HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE);
    FarGetPanelInfo(vHandle, vInfo);
    if vInfo.PanelType = PTYPE_FILEPANEL then begin
     {$ifdef Far3}
      vPlugin  := PFLAGS_PLUGIN and vInfo.Flags <> 0;
     {$else}
      vPlugin  := vInfo.Plugin <> 0;
     {$endif Far3}
      if not vPlugin then
        Result := FarPanelGetCurrentDirectory(vHandle)
      else
        Result := cPlugFakeDrive;
    end;
  end;


  function IsSpecialPath(const AName :TString) :boolean;
  begin
    Result := (UpCompareSubStr(cPlugFakeDrive, AName) = 0) or (UpCompareSubStr(cSVNFakeDrive, AName) = 0);
  end;


  function FarExpandFileNameEx(const AName :TString) :TString;
  begin
    if IsSpecialPath(AName) then
      Result := AName
    else
      Result := FarExpandFileName( AName );
  end;


  function ReduceFileName(const AName :TString; ALen :Integer) :TString;
  var
    vLen, vPos :Integer;
  begin
    vLen := length(AName);
    if vLen > ALen then begin

      vPos := ChrPos(':', AName);
      if (vPos > 0) and (vPos < ALen - 3) then
        Result := Copy(AName, 1, vPos) + '...' + Copy(AName, vLen - ALen + vPos + 4, MaxInt)
      else
        Result := '...' + Copy(AName, vLen - ALen + 4, MaxInt);

    end else
      Result := AName;
  end;

 {-----------------------------------------------------------------------------}

  function GetCodePage(var AFormat :TStrFileFormat) :Boolean;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(StrCodePages),
    [
      GetMsg(StrMAnsi),
      GetMsg(StrMOEM),
      GetMsg(StrMUnicode),
      GetMsg(StrMUTF8)
    ]);
    try
      vMenu.SetSelected(Byte(AFormat));

      Result := vMenu.Run;

      if Result then
        Byte(AFormat) := vMenu.ResIdx;

    finally
      FreeObj(vMenu);
    end;
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


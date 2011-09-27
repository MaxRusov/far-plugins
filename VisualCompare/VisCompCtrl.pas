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

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,
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
      strMShowLineNumbers,
      strMShowCurrentRows,
      strMHilightRowDiff,
      strMShowSpaces,
      strMHorizontalDivide,
      strMColors2,

      strCodePages,
      strMAnsi,
      strMOEM,
      strMUnicode,
      strMUTF8,
      strMDefault,

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
      strRestoreDefaults,

      strAutoscroll,
      strTabSize,
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
    optScanContents        :Boolean = True;
    optScanFileMask        :TString = '*.*';

    optShowFilesInFolders  :Boolean = True;
    optShowSize            :Boolean = True;
    optShowTime            :Boolean = True;
    optShowAttr            :Boolean = False;
    optShowFolderAttrs     :Boolean = False;

    optShowLinesNumber     :Boolean = True;    { Показывать номера строк }
    optShowSpaces          :Boolean = False;   { Показывать пробелы и символы табуляции }
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
    optShowOrphan          :Boolean = True;

    optHilightDiff         :Boolean = True;
    optDiffAtTop           :Boolean = True;
    optFileSortMode        :Integer = smByName;

    optTextIgnoreEmptyLine :Boolean = True;
    optTextIgnoreSpace     :Boolean = True;
    optTextIgnoreCase      :Boolean = True;

    optMaximized           :Boolean = False;

    optSpaceChar           :TChar   = #$B7;
    optTabChar             :TChar   = #$1A; //#$BB;
    optTabSpaceChar        :TChar   = ' ';
    optShowCursor          :Boolean = False;   { Показывать мигающий курсор (сильно тормозит :( ) }

    optTabSize             :Integer = 8;
    optEdtAutoscroll       :Boolean = False;   { Автоматически переходить на первое различие }

    optDefaultFormat       :TStrFileFormat = sffAnsi;

  var
    optDlgColor            :Integer;
    optCurColor            :Integer;
    optSelColor            :Integer;
    optDiffColor           :Integer;
    optSameColor           :Integer;
    optOrphanColor         :Integer;
    optOlderColor          :Integer;
    optNewerColor          :Integer;
    optFoundColor          :Integer;
    optHeadColor           :Integer;

    optTextColor           :Integer;
    optTextSelColor        :Integer;
    optTextNewColor        :Integer;
    optTextDelColor        :Integer;
    optTextDiffStrColor1   :Integer;
    optTextDiffStrColor2   :Integer;
    optTextNumColor        :Integer;
    optTextHeadColor       :Integer;
    optTextActCursorColor  :Integer;
    optTextPasCursorColor  :Integer;


  var
    FRegRoot :TString;


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

  function CurrentPanelSide :Integer;
  function GetPanelDir(Active :Boolean) :TString;

  function IsSpecialPath(const AName :TString) :boolean;
  function FarExpandFileNameEx(const AName :TString) :TString;

  function ReduceFileName(const AName :TString; ALen :Integer) :TString;

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


  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      optCompareCmd := RegQueryStr(vKey, 'CompareCmd', optCompareCmd);

      optScanRecursive := RegQueryLog(vKey, 'ScanRecursive', optScanRecursive);
      optNoScanHidden := RegQueryLog(vKey, 'NoScanHidden', optNoScanHidden);
      optNoScanOrphan := RegQueryLog(vKey, 'NoScanOrphan', optNoScanOrphan);
      optScanContents := RegQueryLog(vKey, 'ScanContents', optScanContents);
      optScanFileMask := RegQueryStr(vKey, 'ScanFileMask', optScanFileMask);

      optShowFilesInFolders := RegQueryLog(vKey, 'ShowFilesInFolders', optShowFilesInFolders);

      optShowSize := RegQueryLog(vKey, 'ShowSize', optShowSize);
      optShowTime := RegQueryLog(vKey, 'ShowTime', optShowTime);
      optShowAttr := RegQueryLog(vKey, 'ShowAttr', optShowAttr);
      optShowFolderAttrs := RegQueryLog(vKey, 'ShowFolderAttrs', optShowFolderAttrs);

      optShowLinesNumber := RegQueryLog(vKey, 'ShowLinesNumber', optShowLinesNumber);
      optShowSpaces := RegQueryLog(vKey, 'ShowSpaces', optShowSpaces);
      optShowCurrentRows := RegQueryLog(vKey, 'ShowCurrentRows', optShowCurrentRows);
      optHilightRowsDiff := RegQueryLog(vKey, 'HilightRowsDiff', optHilightRowsDiff);
      optTextHorzDiv := RegQueryLog(vKey, 'TextHorzDiv', optTextHorzDiv);

      optHilightDiff := RegQueryLog(vKey, 'HilightDiff', optHilightDiff);
      optDiffAtTop := RegQueryLog(vKey, 'DiffAtTop', optDiffAtTop);
      optFileSortMode := RegQueryInt(vKey, 'SortMode', optFileSortMode);

      optCompareContents := RegQueryLog(vKey, 'CompareContents', optCompareContents);
      optCompareSize := RegQueryLog(vKey, 'CompareSize', optCompareSize);
      optCompareTime := RegQueryLog(vKey, 'CompareTime', optCompareTime);
      optCompareAttr := RegQueryLog(vKey, 'CompareAttr', optCompareAttr);
      optCompareFolderAttrs := RegQueryLog(vKey, 'CompareFolderAttrs', optCompareFolderAttrs);

      optTextIgnoreEmptyLine := RegQueryLog(vKey, 'TextIgnoreEmptyLine', optTextIgnoreEmptyLine);
      optTextIgnoreSpace := RegQueryLog(vKey, 'TextIgnoreSpace', optTextIgnoreSpace);
      optTextIgnoreCase := RegQueryLog(vKey, 'TextIgnoreCase', optTextIgnoreCase);

      optMaximized := RegQueryLog(vKey, 'Maximized', optMaximized);

      Byte(optDefaultFormat) := IntMin(RegQueryInt(vKey, 'DefaultFormat', Byte(optDefaultFormat)), Byte(sffAuto) - 1);

      optEdtAutoscroll := RegQueryLog(vKey, 'AutoScroll', optEdtAutoscroll);
      optTabSize := RegQueryInt(vKey, 'TabSize', optTabSize);

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
      RegWriteStr(vKey, 'CompareCmd', optCompareCmd);

      RegWriteLog(vKey, 'ScanRecursive', optScanRecursive);
      RegWriteLog(vKey, 'NoScanHidden', optNoScanHidden);
      RegWriteLog(vKey, 'NoScanOrphan', optNoScanOrphan);
      RegWriteLog(vKey, 'ScanContents', optScanContents);
      RegWriteStr(vKey, 'ScanFileMask', optScanFileMask);

      RegWriteLog(vKey, 'ShowFilesInFolders', optShowFilesInFolders);

      RegWriteLog(vKey, 'ShowSize', optShowSize);
      RegWriteLog(vKey, 'ShowTime', optShowTime);
      RegWriteLog(vKey, 'ShowAttr', optShowAttr);
      RegWriteLog(vKey, 'ShowFolderAttrs', optShowFolderAttrs);

      RegWriteLog(vKey, 'ShowLinesNumber', optShowLinesNumber);
      RegWriteLog(vKey, 'ShowSpaces', optShowSpaces);
      RegWriteLog(vKey, 'ShowCurrentRows', optShowCurrentRows);
      RegWriteLog(vKey, 'HilightRowsDiff', optHilightRowsDiff);
      RegWriteLog(vKey, 'TextHorzDiv', optTextHorzDiv);

      RegWriteLog(vKey, 'HilightDiff', optHilightDiff);
      RegWriteLog(vKey, 'DiffAtTop', optDiffAtTop);
      RegWriteInt(vKey, 'SortMode', optFileSortMode);

      RegWriteLog(vKey, 'CompareContents', optCompareContents);
      RegWriteLog(vKey, 'CompareSize', optCompareSize);
      RegWriteLog(vKey, 'CompareTime', optCompareTime);
      RegWriteLog(vKey, 'CompareAttr', optCompareAttr);
      RegWriteLog(vKey, 'CompareFolderAttrs', optCompareFolderAttrs);

      RegWriteLog(vKey, 'TextIgnoreEmptyLine', optTextIgnoreEmptyLine);
      RegWriteLog(vKey, 'TextIgnoreSpace', optTextIgnoreSpace);
      RegWriteLog(vKey, 'TextIgnoreCase', optTextIgnoreCase);

      RegWriteLog(vKey, 'Maximized', optMaximized);

      RegWriteInt(vKey, 'DefaultFormat', Byte(optDefaultFormat));

      RegWriteLog(vKey, 'AutoScroll', optEdtAutoscroll);
      RegWriteInt(vKey, 'TabSize', optTabSize);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure ReadSetupColors;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder + '\' + cPlugColorRegFolder, vKey) then
      Exit;
    try
      optDlgColor    := RegQueryInt(vKey, 'FDlgColor',  optDlgColor);
      optCurColor    := RegQueryInt(vKey, 'FCurColor',  optCurColor);
      optSelColor    := RegQueryInt(vKey, 'FSelColor',  optSelColor);
      optDiffColor   := RegQueryInt(vKey, 'FDiffColor',  optDiffColor);
      optSameColor   := RegQueryInt(vKey, 'FSameColor', optSameColor);
      optOrphanColor := RegQueryInt(vKey, 'FOrphanColor', optOrphanColor);
      optOlderColor  := RegQueryInt(vKey, 'FOlderColor', optOlderColor);
      optNewerColor  := RegQueryInt(vKey, 'FNewerColor', optNewerColor);
      optFoundColor  := RegQueryInt(vKey, 'FFoundColor', optFoundColor);
      optHeadColor   := RegQueryInt(vKey, 'FHeadColor', optHeadColor);

      optTextColor  := RegQueryInt(vKey, 'TColor', optTextColor);
      optTextSelColor  := RegQueryInt(vKey, 'TSelColor', optTextSelColor);
      optTextNewColor  := RegQueryInt(vKey, 'TDiffColor', optTextNewColor);
      optTextDelColor  := RegQueryInt(vKey, 'TDiffColor2', optTextDelColor);
      optTextDiffStrColor1  := RegQueryInt(vKey, 'TDiffStrColor1', optTextDiffStrColor1);
      optTextDiffStrColor2  := RegQueryInt(vKey, 'TDiffStrColor2', optTextDiffStrColor2);
      optTextNumColor  := RegQueryInt(vKey, 'TNumColor', optTextNumColor);
      optTextHeadColor  := RegQueryInt(vKey, 'THeadColor', optTextHeadColor);
      optTextActCursorColor := RegQueryInt(vKey, 'TCursorColor', optTextActCursorColor);
      optTextPasCursorColor := RegQueryInt(vKey, 'TPCursorColor', optTextPasCursorColor);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetupColors;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder + '\' + cPlugColorRegFolder, vKey);
    try
      RegWriteInt(vKey, 'FDlgColor',  optDlgColor);
      RegWriteInt(vKey, 'FCurColor',  optCurColor);
      RegWriteInt(vKey, 'FSelColor',  optSelColor);
      RegWriteInt(vKey, 'FDiffColor', optDiffColor);
      RegWriteInt(vKey, 'FSameColor', optSameColor);
      RegWriteInt(vKey, 'FOrphanColor', optOrphanColor);
      RegWriteInt(vKey, 'FOlderColor', optOlderColor);
      RegWriteInt(vKey, 'FNewerColor', optNewerColor);
      RegWriteInt(vKey, 'FFoundColor', optFoundColor);
      RegWriteInt(vKey, 'FHeadColor', optHeadColor);

      RegWriteInt(vKey, 'TColor', optTextColor);
      RegWriteInt(vKey, 'TSelColor', optTextSelColor);
      RegWriteInt(vKey, 'TDiffColor', optTextNewColor);
      RegWriteInt(vKey, 'TDiffColor2', optTextDelColor);
      RegWriteInt(vKey, 'TDiffStrColor1', optTextDiffStrColor1);
      RegWriteInt(vKey, 'TDiffStrColor2', optTextDiffStrColor2);
      RegWriteInt(vKey, 'TNumColor', optTextNumColor);
      RegWriteInt(vKey, 'THeadColor', optTextHeadColor);
      RegWriteInt(vKey, 'TCursorColor', optTextActCursorColor);
      RegWriteInt(vKey, 'TPCursorColor', optTextPasCursorColor);
    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure RestoreDefFilesColor;
  begin
    optDlgColor      := 0;
    optCurColor      := 0;
    optSelColor      := $20;
    optDiffColor     := $B0;
    optSameColor     := $08;
    optOrphanColor   := $09;
    optOlderColor    := $04;
    optNewerColor    := $0C;
    optFoundColor    := $0A;
    optHeadColor     := $2F;
  end;


  procedure RestoreDefTextColor;
  begin
    optTextColor          := 0;
    optTextSelColor       := 0;
    optTextNewColor       := $B0;
    optTextDelColor       := $70;
    optTextDiffStrColor1  := $F0;
    optTextDiffStrColor2  := $B0;
    optTextNumColor       := $08;
    optTextHeadColor      := $2F;
    optTextActCursorColor := $CE;
    optTextPasCursorColor := $E0;
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


  function CurrentPanelSide :Integer;
  var
    vInfo  :TPanelInfo;
  begin
    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    FARAPI.Control(PANEL_ACTIVE, FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, FCTL_GetPanelShortInfo, @vInfo);
   {$endif bUnicodeFar}
    if PFLAGS_PANELLEFT and vInfo.Flags <> 0 then
      Result := 0  {Left}
    else
      Result := 1; {Right}
  end;


  function GetPanelDir(Active :Boolean) :TString;
  var
    vInfo  :TPanelInfo;
  begin
    Result := '';
    FillChar(vInfo, SizeOf(vInfo), 0);
   {$ifdef bUnicodeFar}
    FARAPI.Control(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE), FCTL_GetPanelInfo, 0, @vInfo);
   {$else}
    FARAPI.Control(INVALID_HANDLE_VALUE, IntIf(Active, FCTL_GetPanelInfo, FCTL_GetAnotherPanelInfo), @vInfo);
   {$endif bUnicodeFar}
    if vInfo.PanelType = PTYPE_FILEPANEL then begin
      if vInfo.Plugin = 0 then begin
       {$ifdef bUnicodeFar}
        Result := FarPanelGetCurrentDirectory(HandleIf(Active, PANEL_ACTIVE, PANEL_PASSIVE));
       {$else}
        Result := StrOEMToAnsi(vInfo.CurDir);
       {$endif bUnicodeFar}
      end else
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


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.


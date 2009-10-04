{$I Defines.inc}

unit VisCompCtrl;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* Noisy Far plugin                                                           *}
{* Процедуры взаимодействия с плеером                                         *}
{******************************************************************************}

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
    FarCtrl;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strInterrupt,
      strInterruptPrompt,
      strYes,
      strNo
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

    cPlugMenuPrefix = 'vc';

    cNormalIcon = '['#$18']';
    cMaximizedIcon = '['#$12']';

  var
    optCompareCmd         :TString = '';

    optScanRecursive      :Boolean = True;
    optNoScanHidden       :Boolean = True;
    optNoScanOrphan       :Boolean = True;
    optScanContents       :Boolean = True;
    optScanFileMask       :TString = '*.*';

    optShowFilesInFolders :Boolean = True;
    optShowSize           :Boolean = True;
    optShowTime           :Boolean = True;
    optShowAttr           :Boolean = False;
    optShowFolderAttrs    :Boolean = False;

    optCompareContents    :Boolean = True;
    optCompareSize        :Boolean = True;
    optCompareTime        :Boolean = True;
    optCompareAttr        :Boolean = True;
    optCompareFolderAttrs :Boolean = False;

    optShowSame           :Boolean = True;
    optShowDiff           :Boolean = True;
    optShowOrphan         :Boolean = True;

    optHilightDiff        :Boolean = True;
    optDiffAtTop          :Boolean = True;
    optFileSortMode       :Integer = smByName;

    optMaximized          :Boolean = False;

    optHeadColor          :Integer = $2F;
    optCurColor           :Integer = 0;
    optSelColor           :Integer = $30;
    optSameColor          :Integer = $08;
    optOrphanColor        :Integer = $09;
    optOlderColor         :Integer = $04;
    optNewerColor         :Integer = $0C;
    optFoundColor         :Integer = $0A;
    optDiffColor          :Integer = $F0;

  var
    FRegRoot              :TString;

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;

  
  procedure HandleError(AError :Exception);

  procedure ReadSetup;
  procedure WriteSetup;

  function ShellOpen(AWnd :THandle; const FName, Param :TString) :Boolean;

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

      optCompareContents := RegQueryLog(vKey, 'CompareContents', optCompareContents);
      optCompareSize := RegQueryLog(vKey, 'CompareSize', optCompareSize);
      optCompareTime := RegQueryLog(vKey, 'CompareTime', optCompareTime);
      optCompareAttr := RegQueryLog(vKey, 'CompareAttr', optCompareAttr);
      optCompareFolderAttrs := RegQueryLog(vKey, 'CompareFolderAttrs', optCompareFolderAttrs);

      optHilightDiff := RegQueryLog(vKey, 'HilightDiff', optHilightDiff);
      optDiffAtTop := RegQueryLog(vKey, 'DiffAtTop', optDiffAtTop);
      optFileSortMode := RegQueryInt(vKey, 'SortMode', optFileSortMode);

      optMaximized := RegQueryLog(vKey, 'Maximized', optMaximized);

      optHeadColor   := RegQueryInt(vKey, 'HeadColor', optHeadColor);
      optCurColor    := RegQueryInt(vKey, 'CurColor',  optCurColor);
      optSelColor    := RegQueryInt(vKey, 'SelColor',  optSelColor);
      optSameColor   := RegQueryInt(vKey, 'SameColor', optSameColor);
      optOrphanColor := RegQueryInt(vKey, 'OrphanColor', optOrphanColor);
      optOlderColor  := RegQueryInt(vKey, 'OlderColor', optOlderColor);
      optNewerColor  := RegQueryInt(vKey, 'NewerColor', optNewerColor);
      optFoundColor  := RegQueryInt(vKey, 'FoundColor', optFoundColor);

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

      RegWriteLog(vKey, 'HilightDiff', optHilightDiff);
      RegWriteLog(vKey, 'DiffAtTop', optDiffAtTop);
      RegWriteInt(vKey, 'SortMode', optFileSortMode);

      RegWriteLog(vKey, 'Maximized', optMaximized);

      RegWriteLog(vKey, 'CompareContents', optCompareContents);
      RegWriteLog(vKey, 'CompareSize', optCompareSize);
      RegWriteLog(vKey, 'CompareTime', optCompareTime);
      RegWriteLog(vKey, 'CompareAttr', optCompareAttr);
      RegWriteLog(vKey, 'CompareFolderAttrs', optCompareFolderAttrs);

    finally
      RegCloseKey(vKey);
    end;
  end;


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


end.


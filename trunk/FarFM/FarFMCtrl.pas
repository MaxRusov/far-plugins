{$I Defines.inc}

unit FarFmCtrl;

interface

  uses
    Windows,
    ActiveX,
    ShellAPI,
    MSXML,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    Far_API,  //Plugin3.pas
    FarCtrl,
    FarPlug,
    FarMenu,
    FarDlg,
    FarConfig;


  const
    cPluginName = 'FarFM';
    cPluginDescr = 'Last FM FAR plugin';
    cPluginAuthor = 'Max Rusov';

    cPrefix = 'FarFM';

   {$ifdef Far3}
    cPluginID   :TGUID = '{fda904ec-5ae7-497e-891b-e6efeee508e8}';
    cMenuID     :TGUID = '{0f36e348-68ad-4af2-8d07-a7d475f44570}';
    cConfigID   :TGUID = '{86f0fe36-fb21-4ab5-9186-2524b3d09eaf}';
   {$endif Far3}
    cCopyDlgID  :TGUID = '{F2A9CE51-990C-40C8-AC70-495ABDB2464B}';
    cLoginDlgID :TGUID = '{28A7C32C-54EC-4633-9800-EC057B669689}';
    cFindDlgID  :TGUID = '{22DBEAD9-40DF-46C9-9CD5-1371723A978D}';


  const
    cArtists = 'Artists';
    cAlbums = 'Albums';
    cUsers = 'Users';
    cTracks = 'Tracks';
    cPlaylists = 'Playlists';
    cSimilar = 'Similar';
    cFavorites = 'Favorites';
    cInformation = 'Information';
    cAccount = 'My Account';
    
    cHiddenAlbums = 'HiddenAlbums';
    cHiddenTracks = 'HiddenTracks';

    cPlaylistExt = 'm3u';
    cM3UHeader = '#EXTM3U';
    cM3UExtInfo = '#EXTINF:%d,%s - %s';

    cMP3Ext = 'mp3';
    cHTMLExt = 'htm';
    cTXTExt = 'txt';

    cConfigExt = 'cfg';
   {$ifdef Far3}
    cLocalConfigPath = '%FarProfile%\FarFM';
   {$else}
    cLocalConfigPath = '%AppData%\FarFM';
   {$endif Far3}
    cUrlCacheFileName = 'UrlCache.dat';

    cRedirectHTML =
      '<!DOCTYPE HTML>'#13#10'<html>'#13#10'<head>'#13#10 +
      '<meta http-equiv="refresh" content="0;url=%0:s"/>'#13#10+
      '</head>'#13#10'<body>'#13#10+
      '<a href="%0:s">%1:s</a>'#13#10+
      '</body>'#13#10'</html>';


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strYes,
      strNo,
      strOk,
      strCancel,

      strName,
      strArtist,
      strAlbum,
      strTrack,
      strLength,
      strN,

      strCmdAdd,
      strCmdCopy,
      strCmdToLib,
      strCmdDelete,
      strCmdHide,
      strCmdClear,

      strMAdd,
      strMDelete,
      strMCopy,
      strMAddToLib,
      strMFindURL,
      strMClearCache,
      strMAuthLFM,
      strMAuthVK,
      strMLogin,
      strMLogout,

      strCopyTitle,
      strMoveTitle,
      strCopyBut,
      strMoveBut,
      strPathNotAbsolute,

      strFindArtist,
      strFindUser,
      strFindTrackURL,
      strAddUser,
      strFindTextPrompt,
      strFindWherePrompt,
      strFindBut,
      strAddBut,
      strArtists,
      strAlbums,
      strTracks,
      strListeners,

      strCopyPrompt,
      strMovePrompt,
      strCopyPromptN,
      strMovePromptN,
      strCopying,
      strMoving,
      strFindTracks,

      strDelete,
      strDeletePrompt,
      strDeletePromptN,
      strDeleteBut,
      strRefreshPanel,

      strHide,
      strUnhide,
      strHidePrompt,
      strUnHidePrompt,
      strHidePromptN,
      strUnHidePromptN,
      strHideBut,
      strUnhideBut,

      strClear,
      strClearPrompt,
      strClearPromptN,
      strClearBut,

      strAddToLib,
      strAddToLibPrompt,
      strAddToLibPromptN,
      strAddToLibBut,
      
      strWarning,
      strFileExists,
      strOverwriteBut,
      strAllBut,
      strSkipBut,
      strSkipAllBut,

      strInfoName,
      strInfoGender,
      strInfoAge,
      strInfoCountry,
      strInfoPlaycount,
      strInfoRegistered,

      strInterrupt,
      strInterruptPrompt,

      strNeedAuthVK,
      strNeedAuthLFM,
      strAutoAuthBut,
      strManualAuthBut,
      strWaitAuth,

      strAuthTitle,
      strRequestPrompt,
      strResponsePrompt,
      strResponseError,

      strAuthError,
      strXMLParseError
   );

  var
    opt_ShowResolvedFile :Boolean = True;
    opt_CacheTrackURL    :Boolean = True;
    opt_CheckDuplicate   :Boolean = True;

    opt_ShowURL          :Boolean = False;

    opt_InfoLang         :TString = 'ru';


  type
    TStringArray2 = array of array of TString;

  function NewStrs(const AStrs :array of TString) :PPCharArray;
  function NewStrsI(const AStrs :array of TMessages) :PPCharArray;
  procedure DisposeStrs(APtr :PPCharArray);

  procedure AppendArray2(var ADest, ASrc :TStringArray2);

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function NewStrs(const AStrs :array of TString) :PPCharArray;
  var
    I, vCount :Integer;
  begin
    vCount := High(AStrs) + 1;
    Result := MemAlloc((vCount + 1) * SizeOf(Pointer));
    PIntPtr(Result)^ := vCount;
    Inc(Pointer1(Result), SizeOf(Pointer));
    for I := 0 to vCount - 1 do
      Result[I] := StrNew(AStrs[I]);
  end;

  function NewStrsI(const AStrs :array of TMessages) :PPCharArray;
  var
    I, vCount :Integer;
  begin
    vCount := High(AStrs) + 1;
    Result := MemAlloc((vCount + 1) * SizeOf(Pointer));
    PIntPtr(Result)^ := vCount;
    Inc(Pointer1(Result), SizeOf(Pointer));
    for I := 0 to vCount - 1 do
      Result[I] := StrNew(GetMsg(AStrs[I]));
  end;

  procedure DisposeStrs(APtr :PPCharArray);
  var
    I, vCount :Integer;
    vPtr :Pointer;
  begin
    vPtr := Pointer1(APtr) - SizeOf(Pointer);
    vCount := PIntPtr(vPtr)^;
    for I := 0 to vCount - 1 do
      StrDispose(APtr[I]);
    MemFree(vPtr);
  end;


  procedure AppendArray2(var ADest, ASrc :TStringArray2);
  var
    I, N :Integer;
  begin
    N := length(ADest);
    SetLength(ADest, N + Length(ASrc));
    for I := 0 to Length(ASrc) - 1 do
      ADest[N + I] := ASrc[I];
  end;



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


end.


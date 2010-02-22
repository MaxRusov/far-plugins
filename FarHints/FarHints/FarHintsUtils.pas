{$I Defines.inc}

unit FarHintsUtils;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    ShellAPI,
    ShlObj,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    MSWinAPI,
    FarHintsAPI,
    FarHintsConst;


  function CheckWin32Version(AMajor: Integer; AMinor: Integer): Boolean;
  function FileOrFolderExists(const aFileName :TString) :Boolean;

  function GetBitmapSize(ABitmap :HBitmap) :TSize;
  function GetIconSize(AIcon :HIcon) :TSize;

  function GetFileIcon(const AName :TString; ALarge :Boolean) :HIcon;
  function GetFileThumbnail(const AName :TString; ASize :Integer; var AHasAlpha :Boolean) :HBitmap;

 {$ifdef bThumbnail}
  function CanUseThumbnail :Boolean;
    { False, ели не Vista'а }

  procedure InitThumbnailThread;
  procedure DoneThumbnailThread;

  function AsyncGetFileThumbnail(const AName :TString; ASize :Integer; var ABitmap :HBitmap; var AHasAlpha :Boolean) :Boolean;
  function AsyncCheckFileThumbnail(var ABitmap :HBitmap; var AHasAlpha :Boolean) :Boolean;
 {$endif bThumbnail}

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  var
    Win32Platform: Integer = 0;
    Win32MajorVersion: Integer = 0;
    Win32MinorVersion: Integer = 0;
//  Win32BuildNumber: Integer = 0;


  procedure InitPlatformId;
  var
    OSVersionInfo: TOSVersionInfo;
  begin
    FillChar(OSVersionInfo, SizeOf(OSVersionInfo), 0);
    OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
    if GetVersionEx(OSVersionInfo) then
      with OSVersionInfo do begin
        Win32Platform := dwPlatformId;
        Win32MajorVersion := dwMajorVersion;
        Win32MinorVersion := dwMinorVersion;
//      Win32BuildNumber := dwBuildNumber;
//      Win32CSDVersion := szCSDVersion;
      end;
  end;


  function CheckWin32Version(AMajor: Integer; AMinor: Integer): Boolean;
  begin
    Result := (Win32MajorVersion > AMajor) or ((Win32MajorVersion = AMajor) and (Win32MinorVersion >= AMinor));
  end;


  function FileOrFolderExists(const aFileName :TString) :Boolean;
  var
    vCode :Cardinal;
  begin
    vCode := Cardinal(FileGetAttr(aFileName));
    Result := (vCode <> Cardinal(-1)) { and (vCode and FILE_ATTRIBUTE_DIRECTORY = 0) };
  end;


  function GetBitmapSize(ABitmap :HBitmap) :TSize;
  var
    vBitmapInfo :TBitmap;
  begin
    GetObject(ABitmap, SizeOf(vBitmapInfo), @vBitmapInfo);
    Result.CX := vBitmapInfo.bmWidth;
    Result.CY := vBitmapInfo.bmHeight;
  end;


  function GetIconSize(AIcon :HIcon) :TSize;
  var
    vIconInfo :TIconInfo;
  begin
    if GetIconInfo(AIcon, vIconInfo) then begin
      try
        Result := GetBitmapSize(vIconInfo.hbmMask);
      finally
        if vIconInfo.hbmColor <> 0 then
          DeleteObject(vIconInfo.hbmColor);
        if vIconInfo.hbmMask <> 0 then
          DeleteObject(vIconInfo.hbmMask);
      end;
    end else
    begin
      Result.CX := GetSystemMetrics(SM_CYICON);
      Result.CY := GetSystemMetrics(SM_CXICON);
    end;
  end;


  function GetFileIcon(const AName :TString; ALarge :Boolean) :HIcon;
  var
    vInfo :SHFILEINFO;
    vFlags :UINT;
  begin
//  Result := ExtractAssociatedIcon(HInstance, PTChar(vName), vIcon);

    FillChar(vInfo, SizeOf(vInfo), 0);
    vFlags := {SHGFI_TYPENAME or} SHGFI_ICON {or SHGFI_SHELLICONSIZE};
    if ALarge then
      vFlags := vFlags or SHGFI_LARGEICON
    else
      vFlags := vFlags or SHGFI_SMALLICON;
    SHGetFileInfo( PTChar(AName), 0, vInfo, SizeOf(vInfo), vFlags );
    Result := vInfo.hIcon;
  end;


(*
  function GetFileThumbnail(const AName :TString; AWidth, AHeight :Integer) :HBitmap;
  var
    vPath, vName :WideString;
    vMalloc :IMalloc;
    vFolder, vTargetFolder :IShellFolder;
    vXtractImg :IExtractImage;
    vItems :PItemIDList;
    vEaten, vAttrs :Cardinal;

    vBuf: array[0..MAX_PATH] of WideChar;
    vRes :HResult;
    vPriority, vColorDepth, vFlags :Cardinal;
    vSize :TSize;

    vBitmapHandle :HBitmap;
  begin
    Result := 0;
    SHGetMalloc(vMalloc);

    if not Succeeded(SHGetDesktopFolder(vFolder)) then
      Exit;

    vPath := ExtractFileDir(AName);
    if not Succeeded( vFolder.ParseDisplayName(0, nil, PWideChar(vPath), vEaten, vItems, vAttrs) ) then
      Exit;
    vFolder.BindToObject(vItems, nil, IShellFolder, vTargetFolder);
    vMalloc.Free(vItems);

    vName := ExtractFileName(AName);
    if not Succeeded( vTargetFolder.ParseDisplayName(0, nil, PWideChar(vName), vEaten,  vItems, vAttrs)) then
      Exit;
    vTargetFolder.GetUIObjectOf(0, 1, vItems, IExtractImage, nil, vXtractImg);
    vMalloc.Free(vItems);

    if vXtractImg <> nil then begin
      vSize.cx := 128;
      vSize.cy := 128;

      vFlags :=
        IEIFLAG_ASPECT or
        IEIFLAG_SCREEN {or
        IEIFLAG_OFFLINE};

      vPriority := 0;
      vColorDepth := 32;

      vRes := vXtractImg.GetLocation(vBuf, sizeof(vBuf), vPriority, vSize, vColorDepth, vFlags);

      if (vRes = NOERROR) or (vRes = E_PENDING) then
        if Succeeded( vXtractImg.Extract(vBitmapHandle) ) then
          Result := vBitmapHandle;
    end;
  end;
*)


  function GetFileThumbnail(const AName :TString; ASize :Integer; var AHasAlpha :Boolean) :HBitmap;
  var
    vCache :IThumbnailCache;
    vItem :IShellItem;
    vBitmap :ISharedBitmap;
    vFlags :DWORD;
    vFormat :DWORD;
    vHBitmap :HBitmap;
  begin
    Result := 0;
    if not Assigned(SHCreateItemFromParsingName) then
      Exit;

    if not Succeeded( CoCreateInstance(CLSID_ThumbnailCache, nil, CLSCTX_INPROC_SERVER, IThumbnailCache, vCache) ) then
      Exit;

    if not Succeeded( SHCreateItemFromParsingName( PWideChar(AName), nil, IShellItem, @vItem) ) then
      Exit;

    vFlags := 0;
    if not Succeeded( vCache.GetThumbnail(vItem, ASize, WTS_EXTRACT, @vBitmap, vFlags, nil) ) then
      Exit;

    AHasAlpha := False;
    if Succeeded( vBitmap.GetFormat(vFormat) ) then
      AHasAlpha := vFormat = WTSAT_ARGB;

    if not Succeeded( vBitmap.Detach(vHBitmap) ) then
      Exit;

    Result := vHBitmap;
  end;


 {-----------------------------------------------------------------------------}

  const
    tsNone     = 0;
    tsWait     = 1;
    tsProceed  = 2;
    tsExtract  = 3;
    tsComplete = 4;

  type
    TThumbnailThread = class(TThread)
    public
      constructor Create;
      destructor Destroy; override;

      procedure Execute; override;

      procedure SetTask(const AName :TString; ASize :Integer);
      function CheckTask(var ABitmap :HBitmap; var AHasAlpha :Boolean) :Integer;

    private
      FEvent       :TEvent;
      FTaskCS      :TCriticalSection;
      FCache       :IThumbnailCache;
      FMalloc      :IMalloc;
      FDesktop     :IShellFolder;

      FTaskFile    :TString;
      FTaskSize    :Integer;
      FTaskState   :Integer;
      FResBitmap   :HBitmap;
      FResHasAlpha :Boolean;

      procedure DoTask;
      function GetThumbnailVista(const AName :TString; var AHasAlpha :Boolean) :HBitmap;
      function GetThumbnailXP(const AName :TString; var AHasAlpha :Boolean) :HBitmap;
    end;


  constructor TThumbnailThread.Create;
  begin
    FEvent := TEvent.Create;
    FTaskCS := TCriticalSection.Create;
    inherited Create(False);
  end;


  destructor TThumbnailThread.Destroy; {override;}
  begin
    if FResBitmap <> 0 then begin
      DeleteObject(FResBitmap);
      FResBitmap := 0;
    end;
    FreeObj(FEvent);
    FreeObj(FTaskCS);
    inherited Destroy;
  end;


  procedure TThumbnailThread.Execute;
  var
    vRes :TWaitResult;
  begin
    CoInitialize(nil);
    try
      CoCreateInstance(CLSID_ThumbnailCache, nil, CLSCTX_INPROC_SERVER, IThumbnailCache, FCache);
      if FCache = nil then begin
        SHGetMalloc(FMalloc);
        SHGetDesktopFolder(FDesktop);
      end;

      while not Terminated do begin
        vRes := fEvent.WaitFor(5000);
//      TraceF('WaitRes = %d', [Byte(vRes)]);
        if Terminated then
          break;

        if vRes = wrSignaled then begin
          fEvent.ResetEvent;
          DoTask;
        end;
      end;

    finally
      FreeIntf(FCache);
      CoUninitialize;
    end;
  end;


  procedure TThumbnailThread.DoTask;
  var
    vName :TString;
    vBitmap :HBitmap;
    vHasAlpha :Boolean;
  begin
    FTaskCS.Enter;
    try
      if FTaskState = tsWait then begin
        vName := FTaskFile;
        FTaskState := tsProceed;
      end else
        Exit;
    finally
      FTaskCS.Leave;
    end;

    if FCache <> nil then
      vBitmap := GetThumbnailVista(vName, vHasAlpha)
    else
      vBitmap := GetThumbnailXP(vName, vHasAlpha);

    FTaskCS.Enter;
    try
      if FResBitmap <> 0 then begin
        { Удаляем невостребованный промежуточный результат }
        DeleteObject(FResBitmap);
        FResBitmap := 0;
      end;

      if FTaskState in [tsProceed, tsExtract] then begin
        FResBitmap := vBitmap;
        FResHasAlpha := vHasAlpha;
        FTaskState := tsComplete;
      end else
        { Пока эскиз извлекался, была поставлена новая задача, результат никого не интересует }
        DeleteObject(vBitmap);

    finally
      FTaskCS.Leave;
    end;
  end;


  procedure TThumbnailThread.SetTask(const AName :TString; ASize :Integer);
  begin
    FTaskCS.Enter;
    try
      if FResBitmap <> 0 then begin
        DeleteObject(FResBitmap);
        FResBitmap := 0;
      end;

      FTaskFile := AName;
      FTaskSize := ASize;
      FTaskState := tsWait;

    finally
      FTaskCS.Leave;
    end;
    FEvent.SetEvent;
  end;


  function TThumbnailThread.CheckTask(var ABitmap :HBitmap; var AHasAlpha :Boolean) :Integer;
  begin
    FTaskCS.Enter;
    try
      ABitmap :=  FResBitmap;
      FResBitmap := 0;

      AHasAlpha := FResHasAlpha;
      FResHasAlpha := False;

      Result := FTaskState;
    finally
      FTaskCS.Leave;
    end;
  end;


  function TThumbnailThread.GetThumbnailVista(const AName :TString; var AHasAlpha :Boolean) :HBitmap;
  var
    vItem :IShellItem;
    vBitmap :ISharedBitmap;
    vFlags :DWORD;
    vFormat :DWORD;
    vHBitmap :HBitmap;
    vSize :TSize;
  begin
    Result := 0;
    if not Assigned(SHCreateItemFromParsingName) then
      Exit;

   {$ifdef bTrace1}
    TraceF('GetThumbnailVista: %s', [AName]);
   {$endif bTrace1}

    if not Succeeded( SHCreateItemFromParsingName( PWideChar(AName), nil, IShellItem, @vItem) ) then
      Exit;

    vHBitmap := 0;
    AHasAlpha := False;

    vFlags := 0;
    { Быстрый способ. Берем эскиз из кэша (но при этом может быть не того размера). }
    if Succeeded( FCache.GetThumbnail(vItem, FTaskSize, WTS_INCACHEONLY, @vBitmap, vFlags, nil) ) then begin

      if Succeeded( vBitmap.GetFormat(vFormat) ) then
        AHasAlpha := vFormat = WTSAT_ARGB;
      if not Succeeded( vBitmap.Detach(vHBitmap) ) then
        Exit;

      vSize := GetBitmapSize(vHBitmap);
//    TraceF('Cached bitmap: %d x %d', [vSize.cx, vSize.cy ]);

      if (vSize.cx >= FTaskSize) or (vSize.cy >= FTaskSize) then begin
        { Извлеченный из кэша эскиз подходящего размера. Завершаем работу. }
        Result := vHBitmap;
        Exit;
      end;
    end;

    { Медленный способ. Извлекаем эскиз. }
    FTaskCS.Enter;
    try
      if Terminated or (FTaskState <> tsProceed) then
        Exit;

      { Установим извлеченный из кэша эскиз в качестве промежуточного результата }
      FResBitmap := vHBitmap;
      FResHasAlpha := AHasAlpha;

      FTaskState := tsExtract;
    finally
      FTaskCS.Leave;
    end;

    vFlags := 0;
    if not Succeeded( FCache.GetThumbnail(vItem, FTaskSize, WTS_EXTRACT, @vBitmap, vFlags, nil) ) then
      Exit;

    AHasAlpha := False;
    if Succeeded( vBitmap.GetFormat(vFormat) ) then
      AHasAlpha := vFormat = WTSAT_ARGB;
    if not Succeeded( vBitmap.Detach(vHBitmap) ) then
      Exit;

    Result := vHBitmap;
  end;


  function TThumbnailThread.GetThumbnailXP(const AName :TString; var AHasAlpha :Boolean) :HBitmap;
  var
    vPath, vName :WideString;
    vFolder :IShellFolder;
    vXtractImg :IExtractImage;
    vItems :PItemIDList;
    vEaten, vAttrs :Cardinal;

    vBuf: array[0..MAX_PATH] of WideChar;
    vPriority, vColorDepth, vFlags :Cardinal;
    vSize :TSize;
    vRes :HResult;

    vBitmapHandle :HBitmap;
  begin
    Result := 0;
    if not Assigned(FMalloc) or not Assigned(FDesktop) then
      Exit;

   {$ifdef bTrace1}
    TraceF('GetThumbnailXP: %s', [AName]);
   {$endif bTrace1}

    vPath := RemoveBackSlash(ExtractFilePath(AName));
    if not Succeeded( FDesktop.ParseDisplayName(0, nil, PWideChar(vPath), vEaten, vItems, vAttrs) ) then
      Exit;
    FDesktop.BindToObject(vItems, nil, IShellFolder, vFolder);
    FMalloc.Free(vItems);

    vName := ExtractFileName(AName);
    if not Succeeded( vFolder.ParseDisplayName(0, nil, PWideChar(vName), vEaten,  vItems, vAttrs)) then
      Exit;
    vFolder.GetUIObjectOf(0, 1, vItems, IExtractImage, nil, vXtractImg);
    FMalloc.Free(vItems);

    if vXtractImg <> nil then begin

      vFlags :=
        IEIFLAG_ASPECT or
        IEIFLAG_SCREEN {or
        IEIFLAG_OFFLINE};

      vPriority := 0;
      vColorDepth := 32;
      vSize.cx := FTaskSize;
      vSize.cy := FTaskSize;

//    vRes := vXtractImg.GetLocation(vBuf, sizeof(vBuf), vPriority, vSize, vColorDepth, vFlags);
      vRes := vXtractImg.GetLocation(vBuf, High(vBuf), vPriority, vSize, vColorDepth, vFlags);

      FTaskCS.Enter;
      try
        if Terminated or (FTaskState <> tsProceed) then
          Exit;
        FTaskState := tsExtract;
      finally
        FTaskCS.Leave;
      end;

      AHasAlpha := False;
      if (vRes = NOERROR) or (vRes = E_PENDING) then
        if Succeeded( vXtractImg.Extract(vBitmapHandle) ) then
          Result := vBitmapHandle;
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    GThumbThread :TThumbnailThread;


  function CanUseThumbnail :Boolean;
  begin
//  Result := Assigned(SHCreateItemFromParsingName);
    Result := True;
  end;


  procedure InitThumbnailThread;
  begin
    if GThumbThread = nil then begin
      GThumbThread := TThumbnailThread.Create;
    end;
  end;


  procedure DoneThumbnailThread;
  begin
    if GThumbThread <> nil then begin
      GThumbThread.Terminate;
      GThumbThread.FEvent.SetEvent;
      GThumbThread.WaitFor;
      FreeObj(GThumbThread);
    end;
  end;


  function AsyncGetFileThumbnail(const AName :TString; ASize :Integer; var ABitmap :HBitmap; var AHasAlpha :Boolean) :Boolean;
  var
    vStart :Cardinal;
  begin
    if GThumbThread = nil then begin
      Result := True;
      ABitmap := 0;
      Exit;
    end;

    GThumbThread.SetTask(AName, ASize);

    Result := False;
    vStart := GetTickCount;
    while True do begin
      case GThumbThread.CheckTask(ABitmap, AHasAlpha) of
        tsComplete:
          begin
            Result := True;
            Exit;
          end;
        tsExtract:
          { Пошли по медленному алгоритму, прекращаем ждать... }
          Exit;
      end;
      if TickCountDiff(GetTickCount, vStart) > 100 then
        Exit;
      Sleep(1);
    end;
  end;


  function AsyncCheckFileThumbnail(var ABitmap :HBitmap; var AHasAlpha :Boolean) :Boolean;
  begin
    Result := GThumbThread.CheckTask(ABitmap, AHasAlpha) = tsComplete;
  end;


initialization
  InitPlatformId;
end.

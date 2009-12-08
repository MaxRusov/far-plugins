{$I Defines.inc}

unit FarHintsFoldersMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    FarHintsAPI;


  const
    ThreadIdlePeriod  = 3000;
    ThreadCalcDelay   = 250;
    IdleRefresTimeout = 250;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  type
    TStrMessage = (
      strName,
      strType,
      strModified,
      strSize,
      strContains,
      strFiles,
      strFolders
    );


  type
    TInt64Rec = packed record
      Lo, Hi :DWORD;
    end;


  function MakeInt64(Lo, Hi :DWORD) :TInt64;
  begin
    TInt64Rec(Result).Lo := Lo;
    TInt64Rec(Result).Hi := Hi;
  end;


  function TickCountDiff(AValue1, AValue2 :Cardinal) :Cardinal;
  begin
    if AValue1 >= AValue2 then
      Result := AValue1 - AValue2
    else
      Result := ($FFFFFFFF - AValue2) + aValue1;
  end;


 {-----------------------------------------------------------------------------}

  type
    TPluginObject = class(TInterfacedObject, IHintPlugin, IHintPluginIdle)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;
      function Idle(const AItem :IFarItem) :Boolean; stdcall;

    private
      FAPI          :IFarHintsApi;

      FCSection     :TRTLCriticalSection;

      FLock         :Integer;
      FTaskInc      :Integer;   { Инкремент задач }
      FTaskReq      :Integer;   { Требуемая задача }
      FTaskRun      :Integer;   { Обрабатываемая задача }
      FTaskView     :Integer;
      FTaskStart    :Cardinal;  { Время постановки задачи }
      FLastRefresh  :Cardinal;  { Последнее обновление }

      FFolder       :TString;
      FFileCount    :Integer;
      FFolderCount  :Integer;
      FFileSize     :TInt64;

      FHandle       :THandle;
      FThreadID     :THandle;
      FTerminated   :Boolean;
      FThreadGoDown :Boolean;

      function GetMsg(AIndex :TStrMessage) :WideString;
      procedure StartCalcThread;
      procedure StopCalcThread;
      procedure Execute;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
    InitializeCriticalSection(FCSection);
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
    StopCalcThread;
    DeleteCriticalSection(FCSection);
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  begin
    Result := False;
    if FILE_ATTRIBUTE_DIRECTORY and AItem.Attr <> 0 then begin
//    TraceF('Process %s', [AItem.FullName]);

      if AItem.FarItem <> nil then
        AItem.AddStringInfo(GetMsg(strName), AItem.Name)
      else
        { Плагин вызван из дерева - показываем полный путь }
        AItem.AddStringInfo(GetMsg(strName), AItem.FullName);

      if AItem.Modified <> 0 then
        AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
        
      AItem.AddStringInfo(GetMsg(strSize), ' ');
      AItem.AddStringInfo(GetMsg(strContains), ' ');

      Result := True;
    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
    EnterCriticalSection(FCSection);
    try
      Inc(FLock);
    finally
      LeaveCriticalSection(FCSection);
    end;

    try
      if (FHandle <> 0) and FThreadGoDown then
        StopCalcThread;
      if FHandle = 0 then
        StartCalcThread;

      EnterCriticalSection(FCSection);
      try
        Inc(FTaskInc);
        FFolder      := AItem.FullName;
        FTaskStart   := GetTickCount;
        FTaskReq     := FTaskInc;
        FTaskView    := 0;
        FFileCount   := 0;
        FFolderCount := 0;
        FFileSize    := 0;
      finally
        LeaveCriticalSection(FCSection);
      end;

    finally

      EnterCriticalSection(FCSection);
      try
        Dec(FLock);
      finally
        LeaveCriticalSection(FCSection);
      end;

    end;
  end;


  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
//  TraceF('DoneItem %s', [AItem.FullName]);
    EnterCriticalSection(FCSection);
    try
      FTaskReq := 0;
    finally
      LeaveCriticalSection(FCSection);
    end;
  end;


  function TPluginObject.Idle(const AItem :IFarItem) :Boolean; {stdcall;}

    function ScaleStr(ANum :TInt64; AScale :Integer) :TString;
    var
      vNum :Extended;
    begin
      vNum := ANum / AScale;
      if vNum < 10 then
        Result := FAPI.FormatFloat(',0.00', vNum)
      else if vNum < 100 then
        Result := FAPI.FormatFloat(',0.0', vNum)
      else
        Result := FAPI.FormatFloat(',0', vNum);
    end;


    function LocFormatSize(ASize :TInt64) :TString;
    begin
      if ASize < 1024 then
        Result := FAPI.Int64ToStr(ASize)
      else if ASize < 1024 * 1024 then
        Result := FAPI.Format('%s K (%s)', [ScaleStr(ASize, 1024), FAPI.Int64ToStr(ASize)])
      else if ASize < 1024 * 1024 * 1024 then
        Result := FAPI.Format('%s MB (%s)', [ScaleStr(ASize, 1024 * 1024), FAPI.Int64ToStr(ASize)])
      else
        Result := FAPI.Format('%s GB (%s)', [ScaleStr(ASize, 1024 * 1024 * 1024), FAPI.Int64ToStr(ASize)]);
    end;

  var
    i :Integer;
  begin
    Result := True;
    EnterCriticalSection(FCSection);
    try
      if FTaskView <> 0 then begin
        if FTaskRun = 0 then
          FTaskView := 0;

        if (FTaskView = 0) or (TickCountDiff(GetTickCount, FLastRefresh) >= IdleRefresTimeout) then begin
          i := AItem.AttrCount - 2;

//        AItem.Attrs[i].AsInt64 := FFileSize;
          AItem.Attrs[i+0].AsStr := LocFormatSize(FFileSize);

          AItem.Attrs[i+1].AsStr := FAPI.Format('%s: %s, %s: %s', [GetMsg(strFiles), FAPI.IntToStr(FFileCount), GetMsg(strFolders), FAPI.IntToStr(FFolderCount) ]);
          FLastRefresh := GetTickCount;
        end;
      end;
    finally
      LeaveCriticalSection(FCSection);
    end;
  end;


  function TPluginObject.GetMsg(AIndex :TStrMessage) :WideString;
  begin
    Result := FAPI.GetMsg(Self, Byte(AIndex));
  end;


 {-----------------------------------------------------------------------------}

  function ThreadProc(Thread :Pointer) :TIntPtr;
  begin
    Result := 0;
    try
      TPluginObject(Thread).Execute;
    finally
      EndThread(Result);
    end;
  end;


  procedure TPluginObject.StartCalcThread;
  begin
    FTerminated := False;
    FThreadGoDown := False;
    FHandle := BeginThread(nil, 0, ThreadProc, Pointer(Self), 0, FThreadID);  //CreateThread
  end;


  procedure TPluginObject.StopCalcThread;
  begin
    if FHandle <> 0 then begin
      FTerminated := True;
      WaitForSingleObject(FHandle, INFINITE);
      CloseHandle(FHandle);
      FHandle := 0;
    end;
  end;


  procedure TPluginObject.Execute;

    procedure LocProcess(AInitFolder :TString);
    var
      vAborted :Boolean;

      procedure LocScan(const AFolder :TString);
      var
        vRes :THandle;
        vData :TWin32FindData;
        vFileMask :TString;
      begin
//      Trace(AFolder);
        vFileMask := AFolder + '*.*';
        vRes := FindFirstFile(PTChar(vFileMask), vData);
        if vRes = INVALID_HANDLE_VALUE then
          Exit;
        try
          while True do begin
            if (vData.cFileName[0] = '.') and ((vData.cFileName[1] = #0) or
              ((vData.cFileName[1] = '.') and (vData.cFileName[2] = #0)))
            then
              {Skip}
            else begin

              EnterCriticalSection(FCSection);
              try
                vAborted := FTaskRun <> FTaskReq;
                if FTerminated or vAborted then
                  Break;

                if FILE_ATTRIBUTE_DIRECTORY and vData.dwFileAttributes <> 0 then
                  Inc(FFolderCount)
                else begin
                  Inc(FFileCount);
                  Inc(FFileSize, MakeInt64(vData.nFileSizeLow, vData.nFileSizeHigh));
                end;
              finally
                LeaveCriticalSection(FCSection);
              end;

              if FILE_ATTRIBUTE_DIRECTORY and vData.dwFileAttributes <> 0 then begin
                vFileMask := AFolder + vData.cFileName + '\';
                LocScan(vFileMask);
              end;
            end;

            if FTerminated or vAborted then
              Break;
            if not FindNextFile(vRes, vData) then
              Break;
          end;

        finally
          FindClose(vRes);
        end;
      end;

    begin
//    TraceF('Processing "%s"...', [AInitFolder]);

      try
        vAborted := False;
        if AInitFolder[length(AInitFolder)] <> '\' then
          AInitFolder := AInitFolder + '\';
        LocScan(AInitFolder);
      finally

        EnterCriticalSection(FCSection);
        try
//        TraceF('  finish (%d)', [Byte(FTaskRun = FTaskReq)] );
          if FTaskRun = FTaskReq then
            FTaskReq := 0;
          FTaskRun := 0;
        finally
          LeaveCriticalSection(FCSection);
        end;

      end;
    end;


  var
    vTime :Cardinal;
    vFolder :TString;
  begin
//  Trace('Init thread...');

    vTime := GetTickCount;

    while not FTerminated do begin

      EnterCriticalSection(FCSection);
      try
        FThreadGoDown := (FLock = 0) and (FTaskReq = 0) and (TickCountDiff(GetTickCount, vTime) >= ThreadIdlePeriod);
        if FThreadGoDown then
          Break;

        FTaskRun := 0;
        if (FTaskReq <> 0) and (TickCountDiff(GetTickCount, FTaskStart) >= ThreadCalcDelay) then begin
          FTaskRun := FTaskReq;
          FTaskView := FTaskReq;
          FLastRefresh := 0;
          vFolder := FFolder;
        end;

      finally
        LeaveCriticalSection(FCSection);
      end;

      if FTaskRun <> 0 then begin
        LocProcess(vFolder);
        vTime := GetTickCount;
      end else
      begin
        if FTaskReq <> 0 then
          vTime := GetTickCount;
        Sleep(1);
      end;
    end;

//  Trace('Done thread...');
  end;


 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.

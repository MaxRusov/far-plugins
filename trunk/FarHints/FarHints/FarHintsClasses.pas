{$I Defines.inc}

unit FarHintsClasses;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixFormat,
    MixWinUtils,

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarCtrl,

    MSForms,
    FarConMan,
    FarHintsConst,
    FarHintsAPI,
    FarHintsWin,  
    FarHintsReg,
    FarHintsUtils,
    FarHintsStdPlugin,
    FarHintsPlugins;


  type
    THintPluginInfo = class(TComBasis, IHintPluginInfo)
    public
      constructor CreateEx(const AName :TString);

    public
      {IHintPluginInfo}
      function GetName :WideString; stdcall;
      function GetCaption :WideString; stdcall;
      procedure SetCaption(const Value :WideString); stdcall;
      function GetFlags :Cardinal; stdcall;
      procedure SetFlags(Value :Cardinal); stdcall;

    private
      FFlags :Cardinal;
      FName :TString;
      FCaption :TString;
    end;

    TFarItemAttr = class(TComBasis, IFarItemAttr)
    public
      constructor CreateEx(const AName :TString; AType :TFarAttrType;
        const AStrValue :TString; AIntValue :Integer; AI64Value :TInt64; ADateValue :TDateTime);

    public
      {IFarItemAttr}
      function GetName :WideString; stdcall;
      function GetAttrType :TFarAttrType; stdcall;
      function GetAsStr :WideString; stdcall;
      procedure SetAsStr(const AValue :WideString); stdcall;
      function GetAsInt :Integer; stdcall;
      procedure SetAsInt(AValue :Integer); stdcall;
      function GetAsInt64 :TInt64; stdcall;
      procedure SetAsInt64(AValue :TInt64); stdcall;
      function GetAsDateTime :TDateTime; stdcall;
      procedure SetAsDateTime(AValue :TDateTime); stdcall;

    private
      FName :TString;
      FType :TFarAttrType;
      FStrValue :TString;
      FIntValue :Integer;
      FI64Value :TInt64;
      FDateValue :TDateTime;
    end;


    TFarItem = class(TComBasis, IFarItem, ISetWindow)
    public
      constructor CreateEx(APlugin, APrimary :Boolean; const ATitle, AFolder :TString; AItem :PPluginPanelItem);
      constructor CreateFolder(const AFolder :TString);
      destructor Destroy; override;

    public
      {ISetWindow}
      procedure SetWindow(AWindow :THintWindow);

      {IFarItem}
      procedure AddStringInfo(const AName, AValue :WideString); stdcall;
      procedure AddIntInfo(const AName :WideString; AValue :Integer); stdcall;
      procedure AddInt64Info(const AName :WideString; AValue :TInt64); stdcall;
      procedure AddDateInfo(const AName :WideString; AValue :TDateTime); stdcall;

      procedure UpdateHintWindow(AFlags :Integer); stdcall;

      function GetIsPlugin :Boolean; stdcall;
      function GetIsPrimaryPanel :Boolean; stdcall;
      function GetPluginTitle :WideString; stdcall;
      function GetFarItem :PPluginPanelItem; stdcall;
      function GetFolder :WideString; stdcall;
      function GetName :WideString; stdcall;
      function GetFullName :WideString; stdcall;
      function GetAttr :Integer; stdcall;
      function GetSize :TInt64; stdcall;
      function GetModified :TDateTime; stdcall;
      function GetAttrCount :Integer; stdcall;
      function GetAttrs(AIndex :Integer) :IFarItemAttr; stdcall;

      function GetWindow :Integer; stdcall;

      function GetTag :Integer; stdcall;
      procedure SetTag(AValue :Integer); stdcall;
      function GetIconWidth :Integer; stdcall;
      procedure SetIconWidth(AValue :Integer); stdcall;
      function GetIconHeight :Integer; stdcall;
      procedure SetIconHeight(AValue :Integer); stdcall;
      function GetIconFlags :Integer; stdcall;
      procedure SetIconFlags(AValue :Integer); stdcall;

      function GetMouseX :integer; stdcall;
      function GetMouseY :integer; stdcall;
      procedure SetItemRect(const ARect :TRect); stdcall;

    private
      FWindow :THintWindow;

      FMouseX :Integer;
      FMouseY :Integer;
      FItemRect :TRect;

      FPlugin :Boolean;
      FPrimaryPanel :Boolean;
      FPluginTitle :TString;

      FFarItem :PPluginPanelItem;
      FFolder :TString;
      FName :TString;
      FAttr :Integer;
      FSize :TInt64;
      FModified :TDateTime;

      FTag :Integer;
      FItemWidth :Integer;
      FItemHeight :Integer;
      FIconFlags :Integer;

      FAttrs :TExList;

      procedure AddAttr(AAttr :TFarItemAttr);
    end;

    TFarHintsMain = class(TComBasis, IFarHintsApi, IFarHintsIntegrationAPI)
    public
      constructor Create; override;
      destructor Destroy; override;

      function ShowHint(AContext :THintCallContext; ACallMode :THintCallMode; APlugin, APrimary :Boolean; const ATitle :TString;
        MouseX, MouseY, ShowX, ShowY :Integer; AItemRect :PRect; const AFolder :TString; AItem :PPluginPanelItem) :Boolean;
      procedure HideHint;

      procedure HintCommand(ACommand :Integer);

      function HintVisible :Boolean;
      function CurrentHintContext :THintCallContext;
      function CurrentHintMode :THintCallMode;
      function CurrentHintAge :Cardinal;
      function IsHintWindow(AHandle :THandle) :Boolean;
      function InItemRect(const APos :TPoint) :Boolean;

    public
      function _AddRef :Integer; override;
      function _Release :Integer; override;

    private
      {IFarHintsApi}
      function GetRevision :Integer; stdcall;
      procedure RaiseError(const AMessage :WideString); stdcall;
      function IsHintVisible :Boolean; stdcall;
      function GetRegRoot :WideString; stdcall;
      function GetRegValueStr(ARoot :HKEY; const APath, AName, ADefault :WideString) :WideString; stdcall;
      function GetRegValueInt(ARoot :HKEY; const APath, AName :WideString; ADefault :Integer) :Integer; stdcall;
      procedure SetRegValueStr(ARoot :HKEY; const APath, AName, AValue :WideString); stdcall;
      procedure SetRegValueInt(ARoot :HKEY; const APath, AName :WideString; AValue :Integer); stdcall;
      function GetMsg(const ASender :IHintPlugin; AIndex :Integer) :WideString; stdcall;
      function Format(const AFormat :WideString; const Args :array of const) :WideString; stdcall;
      function FormatFloat(const AFormat :WideString; ANum :Extended) :WideString; stdcall;
      function IntToStr(ANum :Integer) :WideString; stdcall;
      function Int64ToStr(ANum :TInt64) :WideString; stdcall;
      function FileTimeToDateTime(const AFileTime :TFileTime) :TDateTime; stdcall;
      function CompareStr(const AStr1, AStr2 :WideString) :Integer; stdcall;
      function ExtractFileName(const AName :WideString) :WideString; stdcall;
      function ExtractFileExt(const AName :WideString) :WideString; stdcall;

      {IFarHintsIntegrationAPI}
      procedure RegisterEmbeddedPlugin(const APlugin :IEmbeddedHintPlugin);
      procedure UnregisterEmbeddedPlugin(const APlugin :IEmbeddedHintPlugin);

    private
      FPlugins     :TPlugins;
      FStdPlugin   :IHintPlugin;
      FWinThread   :TWinThread;
      FWindow      :THintWindow;
      FItemRect    :TRect;
      FCreateLock  :TCriticalSection;

      procedure DeinitHint;

      procedure SetItemToWindow(const APlugin :IHintPlugin; const AItem :IFarItem;
        AContext :THintCallContext; ACallMode :THintCallMode; X, Y :Integer);
      procedure InvalidateWindow(AFlags :Integer);

    public
      property Plugins :TPlugins read FPlugins;
    end;


  var
    FarHints :TFarHintsMain;


  function GetConsoleTitleStr :TString;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  type  
    TInt64Rec = packed record
      Lo, Hi :DWORD;
    end;


  function MakeInt64(Lo, Hi :DWORD) :TInt64;
  begin
    TInt64Rec(Result).Lo := Lo;
    TInt64Rec(Result).Hi := Hi;
  end;


  function FileTimeToDateTime(const AFileTime :TFileTime) :TDateTime;
  var
    vLocalFileTime :TFileTime;
    vDosTime :Integer;
  begin
    Result := 0;
    if (AFileTime.dwLowDateTime <> 0) or (AFileTime.dwHighDateTime <> 0) then begin
      FileTimeToLocalFileTime(AFileTime, vLocalFileTime);
      FileTimeToDosDateTime(vLocalFileTime, LongRec(vDosTime).Hi, LongRec(vDosTime).Lo);
      if vDosTime <> 0 then
        try
          Result := FileDateToDateTime(vDosTime);
        except
          Result := 0;
        end;
    end;    
  end;


  function NameByShortName(const AFolder, AFileName :TString) :TString;
  var
    vName :TString;
    vHandle :THandle;
    vRec :TWin32FindData;
  begin
    vName := AddFileName(AFolder, AFileName);
    vHandle := FindFirstFile(PTChar(vName), vRec);
    try
      if vHandle <> INVALID_HANDLE_VALUE then
        Result := vRec.cFileName
      else
        Result := AFileName;
    finally
      FindClose(vHandle);
    end;
  end;


  function GetConsoleTitleStr :TString;
  var
    vBuf :Array[0..255] of TChar;
  begin
    FillChar(vBuf, SizeOf(vBuf), $00);
    GetConsoleTitle(@vBuf[0], High(vBuf));
    Result := vBuf;

    if ConManDetected then
      ConManClearTitle(Result);
  end;


 {-----------------------------------------------------------------------------}
 { THintPluginInfo                                                             }
 {-----------------------------------------------------------------------------}

  constructor THintPluginInfo.CreateEx(const AName :TString);
  begin
    Create;
    FName := AName;
    FFlags := PF_Preload or PF_ProcessRealNames;
  end;


  function THintPluginInfo.GetName :WideString;
  begin
    Result := FName;
  end;

  function THintPluginInfo.GetCaption :WideString;
  begin
    Result := FCaption;
  end;

  procedure THintPluginInfo.SetCaption(const Value :WideString);
  begin
    FCaption := Value;
  end;

  function THintPluginInfo.GetFlags :Cardinal;
  begin
    Result := FFlags;
  end;

  procedure THintPluginInfo.SetFlags(Value :Cardinal);
  begin
    FFlags := Value;
  end;


 {-----------------------------------------------------------------------------}
 { TFarItemAttr                                                                }
 {-----------------------------------------------------------------------------}

  constructor TFarItemAttr.CreateEx(const AName :TString; AType :TFarAttrType;
    const AStrValue :TString; AIntValue :Integer; AI64Value :TInt64; ADateValue :TDateTime);
  begin
    Create;
    FName := AName;
    FType := AType;
    FStrValue := AStrValue;
    FIntValue := AIntValue;
    FI64Value := AI64Value;
    FDateValue := ADateValue;
  end;


  function TFarItemAttr.GetName :WideString;
  begin
    Result := FName;
  end;

  function TFarItemAttr.GetAttrType :TFarAttrType;
  begin
    Result := FType;
  end;

  function TFarItemAttr.GetAsStr :WideString;
  begin
    Result := FStrValue;
  end;

  function TFarItemAttr.GetAsInt :Integer;
  begin
    Result := FIntValue;
  end;

  function TFarItemAttr.GetAsInt64 :TInt64;
  begin
    Result := FI64Value;
  end;

  function TFarItemAttr.GetAsDateTime :TDateTime;
  begin
    Result := FDateValue;
  end;


  procedure TFarItemAttr.SetAsStr(const AValue :WideString);
  begin
    {!!!}
    FStrValue := AValue;
    FarHints.InvalidateWindow(uhwResize or uhwInvalidateItems);
  end;

  procedure TFarItemAttr.SetAsInt(AValue :Integer);
  begin
    {!!!}
    FIntValue := AValue;
    FarHints.InvalidateWindow(uhwResize or uhwInvalidateItems);
  end;

  procedure TFarItemAttr.SetAsInt64(AValue :TInt64);
  begin
    {!!!}
    FI64Value := AValue;
    FarHints.InvalidateWindow(uhwResize or uhwInvalidateItems);
  end;

  procedure TFarItemAttr.SetAsDateTime(AValue :TDateTime);
  begin
    {!!!}
    FDateValue := AValue;
    FarHints.InvalidateWindow(uhwResize or uhwInvalidateItems);
  end;

 {-----------------------------------------------------------------------------}
 { TFarItem                                                                    }
 {-----------------------------------------------------------------------------}

 {$ifdef bUnicodeFar}
  constructor TFarItem.CreateEx(APlugin, APrimary :Boolean; const ATitle, AFolder :TString; AItem :PPluginPanelItem);
  begin
    inherited Create;

    FPlugin := APlugin;
    FPrimaryPanel := APrimary;
    FPluginTitle := ATitle;

    FFolder := AFolder;
    FFarItem := AItem;
    FName := AItem.FindData.cFileName;

    if (FFolder = '') or IsFullFilePath(FName) then begin
      { Временная панель. Имя содержит полный путь. }
      FFolder := ExtractFilePath(FName);
      FName := ExtractFileName(FName);
    end;

    FAttr := AItem.FindData.dwFileAttributes;
    FSize := AItem.FindData.nFileSize;
    FModified := FileTimeToDateTime(AItem.FindData.ftLastWriteTime);

    FAttrs := TExList.Create;
  end;

 {$else}

  constructor TFarItem.CreateEx(APlugin, APrimary  :Boolean; const ATitle, AFolder :TString; AItem :PPluginPanelItem);
  var
    vAltName :TString;
  begin
    inherited Create;

    FPlugin := APlugin;
    FPrimaryPanel := APrimary;
    FPluginTitle := ATitle;

    FFolder := StrOemToAnsi(AFolder);
    FFarItem := AItem;
    FName := StrOemToAnsi(AItem.FindData.cFileName);
    vAltName := StrOemToAnsi(AItem.FindData.cAlternateFileName);

    if FFolder = '' then begin
      { Временная панель. Имя содержит полный путь. }
      FFolder := ExtractFilePath(FName);
      FName := ExtractFileName(FName);
      vAltName := '';
    end;
   {$ifdef bUnicode}
    if vAltName <> '' then
      FName := NameByShortName(FFolder, vAltName);
   {$endif bUnicode}

    FAttr := AItem.FindData.dwFileAttributes;
    FSize := MakeInt64(AItem.FindData.nFileSizeLow, AItem.FindData.nFileSizeHigh);
    FModified := FileTimeToDateTime(AItem.FindData.ftLastWriteTime);

    FAttrs := TExList.Create;
  end;
 {$endif bUnicodeFar}


  constructor TFarItem.CreateFolder(const AFolder :TString);
  var
    vFolder :TString;
    vHandle :THandle;
    vRec :TWin32FindData;
  begin
    inherited Create;

    FPrimaryPanel := True;

    FAttr := faDirectory;
    vFolder := StrOemToAnsi(AFolder);

    FName := ExtractFileName(vFolder);
    if FName <> '' then begin
      FFolder := RemoveBackSlash(ExtractFilePath(vFolder));
      vHandle := FindFirstFile(PTChar(FFolder), vRec);
      try
        if vHandle <> INVALID_HANDLE_VALUE then begin
          FAttr := vRec.dwFileAttributes;
          FModified := FileTimeToDateTime( vRec.ftLastWriteTime );
        end;
      finally
        FindClose(vHandle);
      end;
    end else
      { Корневой диск }
      FName := vFolder;

    FAttrs := TExList.Create;
  end;


  destructor TFarItem.Destroy; {override;}
  var
    I :Integer;
  begin
    if FAttrs <> nil then
      for I := 0 to FAttrs.Count - 1 do
        TFarItemAttr(FAttrs[I])._Release;
    FreeObj(FAttrs);
    inherited Destroy;
  end;


  procedure TFarItem.SetWindow(AWindow :THintWindow);
  begin
    FWindow := AWindow;
  end;


  procedure TFarItem.AddAttr(AAttr :TFarItemAttr);
  begin
    FAttrs.Add(AAttr);
    AAttr._AddRef;
  end;


  procedure TFarItem.AddStringInfo(const AName, AValue :WideString);
  begin
    AddAttr( TFarItemAttr.CreateEx(AName, fvtString, AValue, 0, 0, 0) );
  end;

  procedure TFarItem.AddIntInfo(const AName :WideString; AValue :Integer);
  begin
    AddAttr( TFarItemAttr.CreateEx(AName, fvtInteger, '', AValue, 0, 0) );
  end;

  procedure TFarItem.AddInt64Info(const AName :WideString; AValue :TInt64);
  begin
    AddAttr( TFarItemAttr.CreateEx(AName, fvtInt64, '', 0, AValue, 0) );
  end;

  procedure TFarItem.AddDateInfo(const AName :WideString; AValue :TDateTime);
  begin
    AddAttr( TFarItemAttr.CreateEx(AName, fvtDate, '', 0, 0, AValue) );
  end;

  procedure TFarItem.UpdateHintWindow(AFlags :Integer);
  begin
    FarHints.InvalidateWindow(AFlags);
  end;

  function TFarItem.GetFullName :WideString;
  begin
    Result := AddFileName(FFolder, FName);
  end;

  function TFarItem.GetIsPlugin :Boolean;
  begin
    Result := FPlugin;
  end;

  function TFarItem.GetIsPrimaryPanel :Boolean;
  begin
    Result := FPrimaryPanel;
  end;

  function TFarItem.GetPluginTitle :WideString;
  begin
    Result := FPluginTitle;
  end;

  function TFarItem.GetFarItem :PPluginPanelItem;
  begin
    Result := FFarItem;
  end;

  function TFarItem.GetFolder :WideString;
  begin
    Result := FFolder;
  end;

  function TFarItem.GetName :WideString;
  begin
    Result := FName;
  end;

  function TFarItem.GetAttr :Integer;
  begin
    Result := FAttr;
  end;

  function TFarItem.GetSize :TInt64;
  begin
    Result := FSize;
  end;

  function TFarItem.GetModified :TDateTime;
  begin
    Result := FModified;
  end;


  function TFarItem.GetAttrCount :Integer;
  begin
    Result := FAttrs.Count;
  end;

  function TFarItem.GetAttrs(AIndex :Integer) :IFarItemAttr;
  begin
    Result := TFarItemAttr(FAttrs[AIndex]);
  end;


  function TFarItem.GetWindow :Integer;
  begin
    Result := 0;
    if FWindow <> nil then
      Result := FWindow.Handle;  
  end;


  function TFarItem.GetTag :Integer;
  begin
    Result := FTag;
  end;

  procedure TFarItem.SetTag(AValue :Integer);
  begin
    FTag := AValue;
  end;


  function TFarItem.GetIconWidth :Integer;
  begin
    Result := FItemWidth;
  end;

  procedure TFarItem.SetIconWidth(AValue :Integer);
  begin
    FItemWidth := AValue;
  end;

  function TFarItem.GetIconHeight :Integer;
  begin
    Result := FItemHeight;
  end;

  procedure TFarItem.SetIconHeight(AValue :Integer);
  begin
    FItemHeight := AValue;
  end;
  

  function TFarItem.GetIconFlags :Integer; 
  begin
    Result := FIconFlags;
  end;

  procedure TFarItem.SetIconFlags(AValue :Integer);
  begin
    FIconFlags := AValue;
  end;


  function TFarItem.GetMouseX :integer;
  begin
    Result := FMouseX;
  end;

  function TFarItem.GetMouseY :integer;
  begin
    Result := FMouseY;
  end;

  procedure TFarItem.SetItemRect(const ARect :TRect);
  begin
    FItemRect := ARect;
  end;


 {-----------------------------------------------------------------------------}
 { TFarHintsMain                                                                }
 {-----------------------------------------------------------------------------}

  constructor TFarHintsMain.Create; {override;}
  begin
    inherited Create;
    FPlugins := TPlugins.Create;
    FStdPlugin := TStdPlugin.Create;
    FCreateLock := TCriticalSection.Create;  
  end;


  destructor TFarHintsMain.Destroy; {override;}
  begin
    HideHint;
    FPlugins.UnloadNotify;
    FreeObj(FCreateLock);
    FreeIntf(FStdPlugin);
    FreeObj(FPlugins);
    inherited Destroy;
  end;


  function TFarHintsMain._AddRef :Integer; {override;}
  begin
    Result := -1;
  end;

  function TFarHintsMain._Release :Integer; {override;}
  begin
    Result := -1;
  end;


  function ItemEquals(const AItem1, AItem2 :IFarItem) :Boolean;
  begin
    Result := (AItem1 <> nil) = (AItem2 <> nil);
    if Result and (AItem1 <> nil) then begin
      Result := StrEqual(AItem1.FullName, AItem2.FullName) and
        (AItem1.Size = AItem2.Size) and
        (AItem1.Modified = AItem2.Modified);
    end;
  end;


  function TFarHintsMain.ShowHint(AContext :THintCallContext; ACallMode :THintCallMode; APlugin, APrimary :Boolean; const ATitle :TString;
    MouseX, MouseY, ShowX, ShowY :Integer; AItemRect :PRect; const AFolder :TString; AItem :PPluginPanelItem) :Boolean;
  var
    I :Integer;
    vObj :TFarItem;
    vItem :IFarItem;
    vPlugin :IHintPlugin;
    vEqual :Boolean;
  begin
    Result := False;
    if (AItem <> nil) and (AItem.FindData.cFileName = '..') then
      Exit;

   {$ifdef bTrace1}
    if AItem <> nil then
      TraceF('ShowHint, Folder=%s, File=%s', [AFolder, AItem.FindData.cFileName])
    else
      TraceF('ShowHint, Folder=%s', [AFolder]);
   {$endif bTrace1}

    if AItem <> nil then
      { Обычный Hint для файловой или плагинной панели }
      vObj := TFarItem.CreateEx(APlugin, APrimary, ATitle, AFolder, AItem)
    else
      { Либо хинт для каталога (дерево), либо хинт для диалога, если AFolder = '' }
      vObj := TFarItem.CreateFolder(AFolder);

    { Координаты мыши (консольные) - нужны для диалогового хинта }
    vObj.FMouseX := MouseX;
    vObj.FMouseY := MouseY;

    { ItemRect - область "хинтования" (консольная). Для диалогового хинта }
    { заранее неизвестна, будет назначена плагином через вызов SetItemRect. }
    if AItemRect <> nil then
      vObj.FItemRect := AItemRect^
    else
      vObj.FItemRect := Bounds(MouseX, MouseY, 1, 1);

    vItem := vObj;

    if ACallMode = hcmCurrent then begin
      { Затычка, для persistent-режима }
      FCreateLock.Enter;
      try
        vEqual := False;
        if FWindow <> nil then
          with FWindow.GetBoundsRect do
            vEqual := ItemEquals(vItem, FWindow.Item) { and (Left = X) and (Top = Y) };  
      finally
        FCreateLock.Leave;
      end;

      if vEqual then begin
        Result := True;
        Exit;
      end;
    end;

    if not HintVisible then
      ReadSettings(FRegRoot);

   {$ifdef bThumbnail}
    if FarHintUseThumbnail and CanUseThumbnail then
      {!!! Перенести в фоновый режим...}
      InitThumbnailThread
    else
      DoneThumbnailThread;
   {$endif bThumbnail}

    { Этот гарантирует, что у суб-плагина будет вызван DoneItem перед Process, }
    { т.е. что суб-плагин работает только с одним экземпляром Item... }
    DeinitHint;

    vPlugin := nil;
    for i := 0 to FPlugins.Count - 1 do
      with TPlugin(FPlugins[I]) do
        if Inited and CanProcess(vItem) and Plugin.Process(vItem) then begin
         {$ifdef bTrace1}
          TraceF('Selected plugin: %s (%s), Flags=%x', [Info.Name, Info.Caption, Integer(Info.Flags)]);
         {$endif bTrace1}
          vPlugin := Plugin;
          Break;
        end;

    if vPlugin = nil then begin
      vPlugin := FStdPlugin;
      if (vItem.Name = '') or not vPlugin.Process(vItem) then
        Exit;
    end;

    FCreateLock.Enter;
    try
      if FWinThread = nil then begin
        FWinThread := TWinThread.Create;
        while FWinThread.Window = nil do
          Sleep(0);
        FWindow := FWinThread.Window;

        { Устанавливаем Hint, для использования в макросах }
        SetEnvironmentVariable('FarHint', '1');
      end;

      SetItemToWindow(vPlugin, vItem, AContext, ACallMode, ShowX, ShowY);

      vPlugin.PostProcess(vItem);
      FItemRect := vObj.FItemRect;

    finally
      vObj.FFarItem := nil;
      FCreateLock.Leave;
    end;

    Result := True;
  end;


  procedure TFarHintsMain.HideHint;
  begin
    FCreateLock.Enter;
    try
      if FWinThread <> nil then begin
        SetEnvironmentVariable('FarHint', nil);

        FWinThread.Terminate;
        FWinThread.WaitFor;
        FreeObj(FWinThread);

        FWindow := nil;
      end;
    finally
      FCreateLock.Leave;
    end;
  end;


  procedure TFarHintsMain.HintCommand(ACommand :Integer);
  begin
    FCreateLock.Enter;
    try
      if FWindow <> nil then
        SendMessage(FWindow.Handle, CM_RunCommand, ACommand, 0);
    finally
      FCreateLock.Leave;
    end;
  end;


  procedure TFarHintsMain.DeinitHint;
  begin
    FCreateLock.Enter;
    try
      if FWindow <> nil then
        SetItemToWindow(nil, nil, hccNone, hcmNone, 0, 0);
    finally
      FCreateLock.Leave;
    end;
  end;


  function TFarHintsMain.HintVisible :Boolean;
  begin
    FCreateLock.Enter;
    try
      Result := FWindow <> nil;
    finally
      FCreateLock.Leave;
    end;
  end;


  function TFarHintsMain.CurrentHintContext :THintCallContext;
  begin
    FCreateLock.Enter;
    try
      Result := hccNone;
      if FWindow <> nil then
        Result := FWindow.Context;
    finally
      FCreateLock.Leave;
    end;
  end;


  function TFarHintsMain.CurrentHintMode :THintCallMode;
  begin
    FCreateLock.Enter;
    try
      Result := hcmNone;
      if FWindow <> nil then
        Result := FWindow.CallMode;
    finally
      FCreateLock.Leave;
    end;
  end;


  function TFarHintsMain.CurrentHintAge :Cardinal;
  begin
    FCreateLock.Enter;
    try
      Result := 0;
      if FWindow <> nil then
        Result := TickCountDiff(GetTickCount, FWindow.ShowTime);
    finally
      FCreateLock.Leave;
    end;
  end;


  function TFarHintsMain.IsHintWindow(AHandle :THandle) :Boolean;
  begin
    FCreateLock.Enter;
    try
      Result := (FWindow <> nil) and (FWindow.Handle = AHandle);
    finally
      FCreateLock.Leave;
    end;
  end;


  function TFarHintsMain.InItemRect(const APos :TPoint) :Boolean;
  begin
    FCreateLock.Enter;
    try
      Result := PtInRect(FItemRect, APos);
    finally
      FCreateLock.Leave;
    end;
  end;


  procedure TFarHintsMain.InvalidateWindow(AFlags :Integer);
  const
    uhwInvalidateAll = uhwInvalidateItems + uhwInvalidateImage;
  begin
    if (FWindow <> nil) and (FWindow.Item <> nil) then begin
      if uhwResize and AFlags <> 0 then begin
        with FWindow.GetBoundsRect do
          FWindow.MoveWindowTo(Left, Top, False);
      end;
      if uhwInvalidateAll and AFlags = uhwInvalidateAll then
        FWindow.InvalidateHint
      else begin
        if uhwInvalidateItems and AFlags <> 0 then
          FWindow.InvalidateItems;
        if uhwInvalidateImage and AFlags <> 0 then
          FWindow.InvalidateIcon;
      end;
    end
  end;


  procedure TFarHintsMain.SetItemToWindow(const APlugin :IHintPlugin; const AItem :IFarItem;
    AContext :THintCallContext; ACallMode :THintCallMode; X, Y :Integer);
  var
    vRec :TSetItemRec;
  begin
//  TraceF('SetItemToWindow. ACallMode=%d', [Byte(ACallMode)]);
    vRec.Plugin  := Pointer(APlugin);
    vRec.Item    := Pointer(AItem);
    vRec.Context := AContext;
    vRec.Mode    := ACallMode;
    vRec.PosX    := X;
    vRec.PosY    := Y;
    SendMessage(FWindow.Handle, CM_SetItem, 0, LPARAM(@vRec));
  end;


 {-----------------------------------------------------------------------------}
 { IFarHintsApi                                                                }

  function TFarHintsMain.GetRevision :Integer;
  begin
    Result := 3;
  end;

  procedure TFarHintsMain.RaiseError(const AMessage :WideString);
  begin
    AppError(AMessage);
  end;


  function TFarHintsMain.IsHintVisible :Boolean;
  begin
    Result := HintVisible;
  end;


  function TFarHintsMain.GetRegRoot :WideString;
  begin
    Result :=  FRegRoot + '\' + RegFolder + '\' + RegPluginsFolder;
  end;

  function TFarHintsMain.GetRegValueStr(ARoot :HKEY; const APath, AName, ADefault :WideString) :WideString;
  begin
    Result := RegGetStrValue(ARoot, APath, AName, ADefault);
  end;

  function TFarHintsMain.GetRegValueInt(ARoot :HKEY; const APath, AName :WideString; ADefault :Integer) :Integer;
  begin
    Result := RegGetIntValue(ARoot, APath, AName, ADefault);
  end;


  procedure TFarHintsMain.SetRegValueStr(ARoot :HKEY; const APath, AName, AValue :WideString);
  begin
    RegSetStrValue(ARoot, APath, AName, AValue);
  end;

  procedure TFarHintsMain.SetRegValueInt(ARoot :HKEY; const APath, AName :WideString; AValue :Integer);
  begin
    RegSetIntValue(ARoot, APath, AName, AValue);
  end;


  function TFarHintsMain.GetMsg(const ASender :IHintPlugin; AIndex :Integer) :WideString;
  var
    vPlugin :TPlugin;
  begin
    vPlugin := FPlugins.FindPlugin(ASender);
    if vPlugin <> nil then
      Result := vPlugin.GetMsg(AIndex)
    else
      Result := '';
  end;

  function TFarHintsMain.Format(const AFormat :WideString; const Args :array of const) :WideString;
  begin
    Result := MixUtils.Format(AFormat, Args);
  end;

  function TFarHintsMain.FormatFloat(const AFormat :WideString; ANum :Extended) :WideString;
  begin
    Result := MixFormat.FormatFloat(AFormat, ANum);
  end;

  function TFarHintsMain.IntToStr(ANum :Integer) :WideString;
  begin
    Result := MixStrings.Int2StrEx(ANum);
  end;

  function TFarHintsMain.Int64ToStr(ANum :TInt64) :WideString;
  begin
    Result := MixStrings.Int64ToStrEx(ANum);
  end;

  function TFarHintsMain.FileTimeToDateTime(const AFileTime :TFileTime) :TDateTime;
  begin
    Result := FarHintsClasses.FileTimeToDateTime(AFileTime);
  end;

  function TFarHintsMain.CompareStr(const AStr1, AStr2 :WideString) :Integer;
  begin
    Result := MixStrings.UpCompareStr(AStr1, AStr2);
  end;

  function TFarHintsMain.ExtractFileName(const AName :WideString) :WideString;
  begin
    Result := MixStrings.ExtractFileName(AName);
  end;

  function TFarHintsMain.ExtractFileExt(const AName :WideString) :WideString;
  begin
    Result := MixStrings.ExtractFileExtension(AName);
  end;


 {-----------------------------------------------------------------------------}
 {IFarHintsIntegrationAPI                                                      }

  procedure TFarHintsMain.RegisterEmbeddedPlugin(const APlugin :IEmbeddedHintPlugin);
  var
    vPlugin :TPlugin;
  begin
    vPlugin := TPlugin.CreateEmbedded(APlugin);
    FPlugins.Add( vPlugin );
  end;


  procedure TFarHintsMain.UnregisterEmbeddedPlugin(const APlugin :IEmbeddedHintPlugin);
  var
    vPlugin :TPlugin;
  begin
    vPlugin := FPlugins.FindPlugin(APlugin);
    if vPlugin <> nil then
      FPlugins.Delete( FPlugins.IndexOf(vPlugin) );
  end;


end.

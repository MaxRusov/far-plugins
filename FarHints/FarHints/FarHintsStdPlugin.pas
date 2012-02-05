{$I Defines.inc}

unit FarHintsStdPlugin;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    ShellAPI,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    Far_API,
    FarCtrl, 
    FarHintsConst,
    FarHintsAPI,
    FarHintsUtils;


  type
    TStdPlugin = class(TComBasis, IHintPlugin (*, IHintPluginDraw *))
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

(*    {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;  *)

(*  private
      FIcon :Integer;  *)
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

    
 {-----------------------------------------------------------------------------}
 { TStdPlugin                                                                  }
 {-----------------------------------------------------------------------------}

  procedure TStdPlugin.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo);
  begin
    {Nothing;}
  end;


  procedure TStdPlugin.DonePlugin;
  begin
    {Nothing;}
  end;

(*
  function TStdPlugin.Process(const AItem :IFarItem) :Boolean;
  var
    vName :TString;
    vInfo :SHFILEINFO;
    vSize :TSize;
  begin
    AItem.AddStringInfo(GetMsgStr(strName), AItem.Name);

    vName := AItem.FullName;
    FIcon := 0;
    if FileOrFolderExists(vName) then begin
      FillChar(vInfo, SizeOf(vInfo), 0);
      SHGetFileInfo( PTChar(vName), 0, vInfo, SizeOf(vInfo), {SHGFI_TYPENAME or} SHGFI_ICON {or SHGFI_SMALLICON} {or SHGFI_SHELLICONSIZE} or SHGFI_LARGEICON);
      if vInfo.szTypeName[0] <> #0 then
        AItem.AddStringInfo(GetMsgStr(strType), vInfo.szTypeName);
      FIcon := vInfo.hIcon;
    end;

    if FIcon <> 0 then begin
      with GetIconSize(FIcon) do begin
        AItem.IconWidth := 48 {CX};
        AItem.IconHeight := 48 {CY};
      end;
    end;

    AItem.AddDateInfo(GetMsgStr(strModified), AItem.Modified);
    if faDirectory and AItem.Attr = 0 then
      AItem.AddInt64Info(GetMsgStr(strSize), AItem.Size);

    Result := True;
  end;


  procedure TStdPlugin.PostProcess(const AItem :IFarItem);
  begin
    {Nothing;}
  end;


  procedure TStdPlugin.DoneItem(const AItem :IFarItem);
  begin
    if FIcon <> 0 then begin
      DestroyIcon(FIcon);
      FIcon := 0;
    end;
  end;


  procedure TStdPlugin.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem);
  begin
    if FIcon <> 0 then
      DrawIconEx(ADC, ARect.Left, ARect.Top, FIcon, AItem.IconWidth, AItem.IconHeight, 0, 0, DI_NORMAL);
  end;
*)



  function TStdPlugin.Process(const AItem :IFarItem) :Boolean;
  var
    vName :TString;
    vInfo :SHFILEINFO;
  begin
    AItem.AddStringInfo(GetMsgStr(strName), AItem.Name);

    if not AItem.IsPlugin then begin
      vName := AItem.FullName;
      if FileOrFolderExists(vName) then begin
        FillChar(vInfo, SizeOf(vInfo), 0);
        SHGetFileInfo( PTChar(vName), 0, vInfo, SizeOf(vInfo), SHGFI_TYPENAME);
        if vInfo.szTypeName[0] <> #0 then
          AItem.AddStringInfo(GetMsgStr(strType), vInfo.szTypeName);
      end;

      AItem.AddDateInfo(GetMsgStr(strModified), AItem.Modified);

      if faDirectory and AItem.Attr = 0 then
        AItem.AddInt64Info(GetMsgStr(strSize), AItem.Size);

    end else
    begin
      vName := StrOemToAnsi(AItem.FarItem.Description);
      if vName <> '' then
        AItem.AddStringInfo(GetMsgStr(strDescription), vName);

      AItem.AddDateInfo(GetMsgStr(strModified), AItem.Modified);

      if faDirectory and AItem.Attr = 0 then begin
        if AItem.Size > 0 then
          AItem.AddInt64Info(GetMsgStr(strSize), AItem.Size);

       {$ifdef bUnicodeFar}
        if AItem.FarItem.FindData.nPackSize > 0 then
          AItem.AddInt64Info(GetMsgStr(strPackedSize), AItem.FarItem.FindData.nPackSize);
       {$else}
        if AItem.FarItem.PackSize > 0 then
          AItem.AddInt64Info(GetMsgStr(strPackedSize), AItem.FarItem.PackSize);
       {$endif bUnicodeFar}
      end;
    end;


    Result := True;
  end;


  procedure TStdPlugin.PostProcess(const AItem :IFarItem);
  begin
    {Nothing;}
  end;


  procedure TStdPlugin.DoneItem(const AItem :IFarItem);
  begin
    {Nothing;}
  end;


end.

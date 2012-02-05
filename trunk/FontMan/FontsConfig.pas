{$I Defines.inc}

unit FontsConfig;

{******************************************************************************}
{* (c) 2008-2009, Max Rusov                                                   *}
{*                                                                            *}
{* FontMan Far plugin                                                         *}
{* Настройки панели шрифтов                                                   *}
{******************************************************************************}

interface

  uses
    Windows,
    MixUtils,
    MixWinUtils,

    Far_API,
    FarCtrl,

    FontsCtrl,
    FontsClasses;


  procedure GroupByMenu(APanel :TFontsPanel);
  procedure FilterByType(APanel :TFontsPanel);
  procedure FilterByCharset(APanel :TFontsPanel);
  procedure ConfigMenu(APanel :TFontsPanel);

  procedure ReadSettings;
  procedure WriteSettings;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure ReadSettings;
  var
    vKey :HKEY;
    vType, vLen :DWord;
    vFilter :TFontCharsets;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      DefPanelMode := RegQueryInt(vKey, 'PanelMode', DefPanelMode);

      DefGroupMode := RegQueryInt(vKey, 'GroupMode', DefGroupMode);
      DefGroupAll := RegQueryLog(vKey, 'GroupAll', DefGroupAll);

      Byte(DefFilterByType) := RegQueryInt(vKey, 'FilterByType', Byte(DefFilterByType));
      Byte(DefFilterByPitch) := RegQueryInt(vKey, 'FilterByPitch', Byte(DefFilterByPitch));

      vLen := SizeOf(vFilter);
      if (RegQueryValueEx(vKey, 'FilterByCharset', nil, @vType, Pointer(@vFilter), @vLen) = 0)
        and (vType = REG_BINARY) and (vLen = SizeOf(vFilter))
      then
        DefFilterByCharsets := vFilter;

    finally
      RegCloseKey(vKey);
    end;
  end;



  procedure WriteSettings;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteInt(vKey, 'PanelMode', DefPanelMode);

      RegWriteInt(vKey, 'GroupMode', DefGroupMode);
      RegWriteLog(vKey, 'GroupAll', DefGroupAll);

      RegWriteInt(vKey, 'FilterByType', Byte(DefFilterByType));
      RegWriteInt(vKey, 'FilterByPitch', Byte(DefFilterByPitch));

      if DefFilterByCharsets <> [] then
        RegSetValueEx(vKey, 'FilterByCharset', 0, REG_BINARY, @DefFilterByCharsets, SizeOf(DefFilterByCharsets))
      else
        RegDeleteValue(vKey, 'FilterByCharset');

    finally
      RegCloseKey(vKey);
    end;
  end;

  
 {-----------------------------------------------------------------------------}

  procedure GroupByMenu(APanel :TFontsPanel);
  const
    cMenuCount = 4;
  var
    I, vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strNone));
      SetMenuItemChrEx(vItem, GetMsg(strByFamily));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strGroupAllFonts));

      vRes := 0;
      while True do begin
        vItems[0].Flags := SetFlag(0, MIF_CHECKED1, APanel.GroupMode = 1);
        vItems[1].Flags := SetFlag(0, MIF_CHECKED1, APanel.GroupMode = 2);
        vItems[3].Flags := SetFlag(0, MIF_CHECKED1, APanel.GroupAll);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strGroupMode),
          '',
          'SetupMenu',
          nil, nil,
          Pointer(vItems),
          cMenuCount);

        if vRes = -1 then
          Exit;

        case vRes of
          0..1: begin
            DefGroupMode := vRes + 1;
            APanel.SetGroupMode( DefGroupMode );
          end;
          3: begin
            DefGroupAll := not APanel.GroupAll;
            APanel.SetGroupAll( DefGroupAll );
          end;
        end;

        WriteSettings;
      end;

    finally
      MemFree(vItems);
    end;
  end;


  procedure FilterByType(APanel :TFontsPanel);

    procedure LocFilterByType(AFontType :TFontType);
    begin
      DefFilterByType := APanel.FilterByType;
      if AFontType in DefFilterByType then
        Exclude(DefFilterByType, AFontType)
      else
        Include(DefFilterByType, AFontType);
      APanel.SetFilterByType(DefFilterByType);
    end;


    procedure LocFilterByPitch(APitchType :TPitchType);
    begin
      DefFilterByPitch := APanel.FilterByPitch;
      if APitchType in DefFilterByPitch then
        Exclude(DefFilterByPitch, APitchType)
      else
        Include(DefFilterByPitch, APitchType);
      APanel.SetFilterByPitch(DefFilterByPitch);
    end;

  const
    cMenuCount = 7;
    cTypeMap :array[0..3] of TFontType =
      (ftTrueType, ftOpenType, ftVector, ftRaster);
  var
    I, vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strTrueType));
      SetMenuItemChrEx(vItem, GetMsg(strOpenType));
      SetMenuItemChrEx(vItem, GetMsg(strVector));
      SetMenuItemChrEx(vItem, GetMsg(strRaster));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strVariablePitch));
      SetMenuItemChrEx(vItem, GetMsg(strFixedPitch));

      vRes := 0;
      while True do begin
        for I := 0 to 3 do
          vItems[I].Flags := SetFlag(0, MIF_CHECKED1, cTypeMap[I] in APanel.FilterByType);

        vItems[5].Flags := SetFlag(0, MIF_CHECKED1, stProportional in APanel.FilterByPitch);
        vItems[6].Flags := SetFlag(0, MIF_CHECKED1, stMonospace in APanel.FilterByPitch);

        for I := 0 to cMenuCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT,
          GetMsg(strFilterByType),
          '',
          'SetupMenu',
          nil, nil,
          Pointer(vItems),
          cMenuCount);

        if vRes = -1 then
          Exit;

        case vRes of
          0..3:
            LocFilterByType(cTypeMap[vRes]);
          5: LocFilterByPitch(stProportional);
          6: LocFilterByPitch(stMonospace);
        end;

        WriteSettings;
      end;

    finally
      MemFree(vItems);
    end;
  end;


  procedure FilterByCharset(APanel :TFontsPanel);
  var
    I, vCount, vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vCount := Charsets.Count;
    vItems := MemAllocZero(vCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      for I := 0 to vCount - 1 do
        with TFontCharset(Charsets[I]) do
          SetMenuItemStrEx(vItem, Name);

      vRes := 0;
      while True do begin
        for I := 0 to vCount - 1 do
          with TFontCharset(Charsets[I]) do
            vItems[I].Flags := SetFlag(0, MIF_CHECKED1, Code in APanel.FilterByCharsets);

        for I := 0 to vCount - 1 do
          vItems[I].Flags := SetFlag(vItems[I].Flags, MIF_SELECTED, I = vRes);

        vRes := FARAPI.Menu(hModule, -1, -1, 0,
          FMENU_WRAPMODE or FMENU_USEEXT or FMENU_AUTOHIGHLIGHT,
          GetMsg(strFilterByCharset),
          '',
          'SetupMenu',
          nil, nil,
          Pointer(vItems),
          vCount);

        if vRes = -1 then
          Exit;

        DefFilterByCharsets := APanel.FilterByCharsets;
        with TFontCharset(Charsets[vRes]) do
          if Code in DefFilterByCharsets then
            Exclude(DefFilterByCharsets, Code)
          else
            Include(DefFilterByCharsets, Code);
        APanel.SetFilterByCharset(DefFilterByCharsets);
        WriteSettings;
      end;

    finally
     {$ifdef bUnicode}
      CleanupMenu(@vItems[0], vCount);
     {$endif bUnicode}
      MemFree(vItems);
    end;
  end;


  procedure ConfigMenu(APanel :TFontsPanel);
  const
    cMenuCount = 4;
  var
    vRes :Integer;
    vItems :PFarMenuItemsArray;
    vItem :PFarMenuItemEx;
  begin
    vItems := MemAllocZero(cMenuCount * SizeOf(TFarMenuItemEx));
    try
      vItem := @vItems[0];
      SetMenuItemChrEx(vItem, GetMsg(strGroupMode_));
      SetMenuItemChrEx(vItem, '', MIF_SEPARATOR);
      SetMenuItemChrEx(vItem, GetMsg(strFilterByType_));
      SetMenuItemChrEx(vItem, GetMsg(strFilterByCharset_));

      vRes := FARAPI.Menu(hModule, -1, -1, 0,
        FMENU_WRAPMODE or FMENU_USEEXT,
        GetMsg(strFontManager),
        '',
        'SetupMenu',
        nil, nil,
        Pointer(vItems),
        cMenuCount);

      if vRes <> -1 then begin
        case vRes of
          0: GroupByMenu(APanel);
          2: FilterByType(APanel);
          3: FilterByCharset(APanel);
        end;
      end;

    finally
      MemFree(vItems);
    end;
  end;


end.


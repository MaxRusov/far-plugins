{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Unicode CharMap                                                            *}
{******************************************************************************}

{
ToDo:
  + ReinitAndSaveCurrent - сохранение позиции на группе
  + Expand/Collapse мышкой
    - На [+]/[-]
    
  - [+]/[-] на группах
  - Код на закрытых группах

  - Позиционирование на ближайший символ в списке, если искомый отсутствует
  - Сокрытие пустых групп
  - Изменение шорткатов
  - Настройка цветов
  - Локализация
}


{$I Defines.inc}

unit UCharMapMain;

interface

  uses
    Windows,
    Messages,
    MixTypes,
    MixUtils,
    MixStrings,

    Far_API,
    FarCtrl,
    FarPlug,

    UCharMapCtrl,
    UCharMapDlg;


  type
    TCharMapPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      procedure Configure; override;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;



 {-----------------------------------------------------------------------------}
 { TCharMapPlug                                                                }
 {-----------------------------------------------------------------------------}

  procedure TCharMapPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
   {$endif Far3}

   {$ifdef Far3}
    FMinFarVer := MakeVersion(3, 0, 3000);
   {$else}
    FMinFarVer := MakeVersion(2, 0, 1573);   { ACTL_GETFARRECT }
   {$endif Far3}
  end;


  procedure TCharMapPlug.Startup; {override;}
  begin
    RestoreDefColor;
//  ReadSettings;
  end;


  procedure TCharMapPlug.GetInfo; {override;}
  begin
    FFlags := PF_EDITOR or PF_VIEWER or PF_DIALOG;

    FMenuStr := GetMsg(strTitle);;
    FConfigStr := FName;
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}

    FPrefix := PFarChar(CmdPrefix);
  end;


  function TCharMapPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    OpenDlg;
    Result := INVALID_HANDLE_VALUE;
  end;


  procedure TCharMapPlug.Configure; {override;}
  begin
    ConfigMenu;
  end;


end.


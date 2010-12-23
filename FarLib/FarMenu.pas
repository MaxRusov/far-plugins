{$I Defines.inc}

unit FarMenu;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Объектная обертка для меню FAR                                             *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixClasses,
    PluginW,
    FarCtrl;


  type
    TFarMenu = class(TBasis)
    public
      constructor Create; override;
      constructor CreateEx(ATitle :PTChar; const AItems :array of PFarChar); overload;
      constructor CreateEx(const ATitle :TString; const AItems :array of PFarChar); overload;
      destructor Destroy; override;

      procedure SetSelected(AIndex :Integer);

      function Run :Boolean;

    protected
      FItems    :PFarMenuItemsArray;
      FCount    :Integer;
      FTitle    :TString;
      FFooter   :TString;
      FHelp     :TString;
      FFlags    :DWORD;
      FX, FY    :Integer;
      FMaxDY    :Integer;

      FResIdx   :Integer;

      function GetChecked(AIndex :Integer) :Boolean;
      procedure SetChecked(AIndex :Integer; AValue :Boolean);

    public
      property Items :PFarMenuItemsArray read FItems;
      property Count :Integer read FCount;
      property Title :TString read FTitle write FTitle;
      property Footer :TString read FFooter write FFooter;
      property Help :TString read FHelp write FHelp;
      property Flags :DWORD read FFlags write FFlags;

      property Checked[I :Integer] :Boolean read GetChecked write SetChecked;

      property ResIdx :Integer read FResIdx;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFarMenu                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TFarMenu.Create; {override;}
  begin
    inherited Create;
    FFlags := FMENU_WRAPMODE or FMENU_USEEXT;
    FX := -1;
    FY := -1;
  end;


  constructor TFarMenu.CreateEx(ATitle :PTChar; const AItems :array of PFarChar);
  begin
    Create;
    FTitle := ATitle;
    FItems := FarCreateMenu(AItems, @FCount);
  end;


  constructor TFarMenu.CreateEx(const ATitle :TString; const AItems :array of PFarChar);
  begin
    Create;
    FTitle := ATitle;
    FItems := FarCreateMenu(AItems, @FCount);
  end;


  destructor TFarMenu.Destroy; {override;}
  begin
    MemFree(FItems);
    inherited Destroy;
  end;


  procedure TFarMenu.SetSelected(AIndex :Integer);
  var
    I :Integer;
  begin
    for I := 0 to FCount - 1 do
      FItems[I].Flags := SetFlag(FItems[I].Flags, MIF_SELECTED, I = AIndex);
  end;


  function TFarMenu.GetChecked(AIndex :Integer) :Boolean;
  begin
    Result := MIF_CHECKED1 and FItems[AIndex].Flags <> 0;
  end;


  procedure TFarMenu.SetChecked(AIndex :Integer; AValue :Boolean);
  begin
    FItems[AIndex].Flags := SetFlag(FItems[AIndex].Flags, MIF_CHECKED1, AValue);
  end;


  function TFarMenu.Run :Boolean;
  begin
    FResIdx := FARAPI.Menu(
      hModule,
      FX, FY,
      FMaxDY,
      FFlags,
      PTChar(FTitle),
      PTChar(FFooter),
      PTChar(FHelp),
      nil, nil,
      Pointer(FItems),
      FCount);

    Result := FResIdx <> -1;
  end;


end.


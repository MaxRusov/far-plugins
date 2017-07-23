{$I Defines.inc}

unit FarHintsApi;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{* Sub-plugins API                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    Far_API;

{
  Revision history:
  1 - First revision
  2 - IHintPluginDraw interface added
  3 - IHintPluginIdle interface added
  4 - IHintPluginInfo interface added + some various changes
  5 - IHintPluginCommand interface added + some various changes
  6 - Embedded plugin support
  7 - Изменено поведение функций GetRegXXX/SetRegXXX
}

  type
    TInt64 = Int64;

  const
    { IHintPluginInfo Flags }
    PF_Preload            = $0001;
    PF_ProcessRealNames   = $0002;
    PF_ProcessPluginItems = $0004;
    PF_CanChangeSize      = $0008;
    PF_ProcessEditor      = $0010;
    PF_ProcessViewer      = $0020;
    PF_ProcessDialog      = $0040;

    { Plugin commands }
    PC_Increase           = 1;
    PC_Decrease           = 2;

    { IconFlags flags }
    IF_Buffered           = 1;
    IF_Solid              = 2;
    IF_HideSizeLabel      = 4;

    { UpdateHintWindow flags }
    uhwResize             = 1;
    uhwInvalidateItems    = 2;
    uhwInvalidateImage    = 4;


  type
    IHintPlugin = interface;
    IHintPluginInfo = interface;
    IFarHintsApi = interface;
    IFarItem = interface;
    IFarItemAttr = interface;


    TFarAttrType = (
      fvtString,
      fvtInteger,
      fvtInt64,
      fvtDate
    );

    IHintPlugin = interface(IUnknown)
      ['{8DCF9F2A-888B-4991-AA5E-85F1D1B38656}']
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;
    end;

    IHintPluginDraw = interface(IUnknown)
      ['{02A4A47E-F564-42FE-AF6A-73009818DC3F}']
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;
    end;

    IHintPluginIdle = interface(IUnknown)
      ['{597F38D9-B18D-4D4B-8CDD-32AE6C897828}']
      function Idle(const AItem :IFarItem) :Boolean; stdcall;
    end;

    IHintPluginCommand = interface(IUnknown)
      ['{F8A0D203-B37A-43AE-875F-68A102E5B6AE}']
      procedure RunCommand(const AItem :IFarItem; ACommand :Integer); stdcall;
    end;

    IHintPluginInfo = interface(IUnknown)
      ['{E6BDA8DF-6565-4445-BBDA-54A676C9061F}']
      function GetName :WideString; stdcall;
      function GetCaption :WideString; stdcall;
      procedure SetCaption(const Value :WideString); stdcall;
      function GetFlags :Cardinal; stdcall;
      procedure SetFlags(Value :Cardinal); stdcall;

      property Name :WideString read GetName;
      property Caption :WideString read GetCaption write SetCaption;
      property Flags :Cardinal read GetFlags write SetFlags;
    end;

    IFarHintsApi = interface(IUnknown)
      ['{528FCEB3-8D42-47B7-91D1-E0D064399BC0}']
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
    end;

    IFarItem = interface(IUnknown)
      ['{528FCEB3-8D42-47B7-91D1-E0D064399BC0}']
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

      property IsPlugin :Boolean read GetIsPlugin;
      property IsPrimaryPanel :Boolean read GetIsPrimaryPanel;
      property MouseX :Integer read GetMouseX;
      property MouseY :Integer read GetMouseY;
      property PluginTitle :WideString read GetPluginTitle;
      property FarItem :PPluginPanelItem read GetFarItem;
      property Folder :WideString read GetFolder;
      property Name :WideString read GetName;
      property FullName :WideString read GetFullName;
      property Attr :Integer read GetAttr;
      property Size :TInt64 read GetSize;
      property Modified :TDateTime read GetModified;

      property Window :Integer read GetWindow;

      property Tag :Integer read GetTag write SetTag;
      property IconWidth :Integer read GetIconWidth write SetIconWidth;
      property IconHeight :Integer read GetIconHeight write SetIconHeight;
      property IconFlags :Integer read GetIconFlags write SetIconFlags;

      property AttrCount :Integer read GetAttrCount;
      property Attrs[I :Integer] :IFarItemAttr read GetAttrs;
    end;

    IFarItemAttr = interface(IUnknown)
      ['{A3D54547-5A5B-4432-8702-07A0C63A8950}']
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

      property Name :WideString read GetName;
      property AttrType :TFarAttrType read GetAttrType;
      property AsStr :WideString read GetAsStr write SetAsStr;
      property AsInt :Integer read GetAsInt write SetAsInt;
      property AsInt64 :TInt64 read GetAsInt64 write SetAsInt64;
      property AsDateTime :TDateTime read GetAsDateTime write SetAsDateTime;
    end;

  type
    TGetPluginInterface = function :IHintPlugin; stdcall;


 {-----------------------------------------------------------------------------}
 { Embedded plugin support                                                     }

  type
    IEmbeddedHintPlugin = interface(IHintPlugin)
      ['{7BD83AEE-3A71-440A-BD6E-25199045CDA1}']
      procedure UnloadFarHints; stdcall;
    end;

    IFarHintsIntegrationAPI = interface(IUnknown)
      ['{23DFDF5C-E14E-4B3E-A6BD-1481DB54289E}']
      procedure RegisterEmbeddedPlugin(const APlugin :IEmbeddedHintPlugin);
      procedure UnregisterEmbeddedPlugin(const APlugin :IEmbeddedHintPlugin);
    end;


  type
   {$ifdef b64}
    { Для совместимости с FreePascal }
    TGetFarHinstAPI = function :Pointer; stdcall;
   {$else}
    TGetFarHinstAPI = function :IFarHintsApi; stdcall;
   {$endif b64}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


end.

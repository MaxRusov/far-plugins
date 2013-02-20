
unit SHDocVw;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.8  $
// File generated on 7/26/99 12:22:56 PM from Type Library described below.

// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
// ************************************************************************ //
// Type Lib: C:\WINNT\System32\shdocvw.dll (1)
// IID\LCID: {EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\STDOLE2.TLB)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Hint: Member 'Type' of 'IWebBrowser' changed to 'Type_'
//   Hint: Parameter 'Type' of IWebBrowser.Type changed to 'Type_'
//   Hint: Parameter 'Property' of DWebBrowserEvents.PropertyChange changed to 'Property_'
//   Hint: Parameter 'Property' of IWebBrowserApp.PutProperty changed to 'Property_'
//   Hint: Parameter 'Property' of IWebBrowserApp.GetProperty changed to 'Property_'
//   Hint: Parameter 'Type' of IShellUIHelper.AddDesktopComponent changed to 'Type_'
//   Error creating palette bitmap of (TInternetExplorer) : Invalid GUID format
// ************************************************************************ //

interface

uses Windows, ActiveX;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SHDocVwMajorVersion = 1;
  SHDocVwMinorVersion = 1;

  LIBID_SHDocVw: TGUID = '{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}';

  IID_IWebBrowser: TGUID = '{EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}';
  DIID_DWebBrowserEvents: TGUID = '{EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B}';
  IID_IWebBrowserApp: TGUID = '{0002DF05-0000-0000-C000-000000000046}';
  IID_IWebBrowser2: TGUID = '{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}';
  DIID_DWebBrowserEvents2: TGUID = '{34A715A0-6587-11D0-924A-0020AFC7AC4D}';
  CLASS_WebBrowser_V1: TGUID = '{EAB22AC3-30C1-11CF-A7EB-0000C05BAE0B}';
  CLASS_WebBrowser: TGUID = '{8856F961-340A-11D0-A96B-00C04FD705A2}';
  CLASS_InternetExplorer: TGUID = '{0002DF01-0000-0000-C000-000000000046}';
  CLASS_ShellBrowserWindow: TGUID = '{C08AFD90-F2A1-11D1-8455-00A0C91F3880}';
  DIID_DShellWindowsEvents: TGUID = '{FE4106E0-399A-11D0-A48C-00A0C90A8F39}';
  IID_IShellWindows: TGUID = '{85CB6900-4D95-11CF-960C-0080C7F4EE85}';
  CLASS_ShellWindows: TGUID = '{9BA05972-F6A8-11CF-A442-00A0C90A8F39}';
  IID_IShellUIHelper: TGUID = '{729FE2F8-1EA8-11D1-8F85-00C04FC2FBE1}';
  CLASS_ShellUIHelper: TGUID = '{64AB4BB7-111E-11D1-8F79-00C04FC2FBE1}';
  DIID__ShellFavoritesNameSpaceEvents: TGUID = '{55136806-B2DE-11D1-B9F2-00A0C98BC547}';
  IID_IShellFavoritesNameSpace: TGUID = '{55136804-B2DE-11D1-B9F2-00A0C98BC547}';
  CLASS_ShellFavoritesNameSpace: TGUID = '{55136805-B2DE-11D1-B9F2-00A0C98BC547}';
  IID_IScriptErrorList: TGUID = '{F3470F24-15FD-11D2-BB2E-00805FF7EFCA}';
  CLASS_CScriptErrorList: TGUID = '{EFD01300-160F-11D2-BB2E-00805FF7EFCA}';
  IID_ISearch: TGUID = '{BA9239A4-3DD5-11D2-BF8B-00C04FB93661}';
  IID_ISearches: TGUID = '{47C922A2-3DD5-11D2-BF8B-00C04FB93661}';
  IID_ISearchAssistantOC: TGUID = '{72423E8F-8011-11D2-BE79-00A0C9A83DA1}';
  DIID__SearchAssistantEvents: TGUID = '{1611FDDA-445B-11D2-85DE-00C04FA35C89}';
  CLASS_SearchAssistantOC: TGUID = '{B45FF030-4447-11D2-85DE-00C04FA35C89}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// CommandStateChangeConstants constants
type
  CommandStateChangeConstants = TOleEnum;
const
  CSC_UPDATECOMMANDS = $FFFFFFFF;
  CSC_NAVIGATEFORWARD = $00000001;
  CSC_NAVIGATEBACK = $00000002;

// OLECMDID constants
type
  OLECMDID = TOleEnum;
const
  OLECMDID_OPEN = $00000001;
  OLECMDID_NEW = $00000002;
  OLECMDID_SAVE = $00000003;
  OLECMDID_SAVEAS = $00000004;
  OLECMDID_SAVECOPYAS = $00000005;
  OLECMDID_PRINT = $00000006;
  OLECMDID_PRINTPREVIEW = $00000007;
  OLECMDID_PAGESETUP = $00000008;
  OLECMDID_SPELL = $00000009;
  OLECMDID_PROPERTIES = $0000000A;
  OLECMDID_CUT = $0000000B;
  OLECMDID_COPY = $0000000C;
  OLECMDID_PASTE = $0000000D;
  OLECMDID_PASTESPECIAL = $0000000E;
  OLECMDID_UNDO = $0000000F;
  OLECMDID_REDO = $00000010;
  OLECMDID_SELECTALL = $00000011;
  OLECMDID_CLEARSELECTION = $00000012;
  OLECMDID_ZOOM = $00000013;
  OLECMDID_GETZOOMRANGE = $00000014;
  OLECMDID_UPDATECOMMANDS = $00000015;
  OLECMDID_REFRESH = $00000016;
  OLECMDID_STOP = $00000017;
  OLECMDID_HIDETOOLBARS = $00000018;
  OLECMDID_SETPROGRESSMAX = $00000019;
  OLECMDID_SETPROGRESSPOS = $0000001A;
  OLECMDID_SETPROGRESSTEXT = $0000001B;
  OLECMDID_SETTITLE = $0000001C;
  OLECMDID_SETDOWNLOADSTATE = $0000001D;
  OLECMDID_STOPDOWNLOAD = $0000001E;
  OLECMDID_ONTOOLBARACTIVATED = $0000001F;
  OLECMDID_FIND = $00000020;
  OLECMDID_DELETE = $00000021;
  OLECMDID_HTTPEQUIV = $00000022;
  OLECMDID_HTTPEQUIV_DONE = $00000023;
  OLECMDID_ENABLE_INTERACTION = $00000024;
  OLECMDID_ONUNLOAD = $00000025;
  OLECMDID_PROPERTYBAG2 = $00000026;
  OLECMDID_PREREFRESH = $00000027;
  OLECMDID_SHOWSCRIPTERROR = $00000028;
  OLECMDID_SHOWMESSAGE = $00000029;
  OLECMDID_SHOWFIND = $0000002A;
  OLECMDID_SHOWPAGESETUP = $0000002B;
  OLECMDID_SHOWPRINT = $0000002C;
  OLECMDID_CLOSE = $0000002D;
  OLECMDID_ALLOWUILESSSAVEAS = $0000002E;
  OLECMDID_DONTDOWNLOADCSS = $0000002F;

// OLECMDF constants
type
  OLECMDF = TOleEnum;
const
  OLECMDF_SUPPORTED = $00000001;
  OLECMDF_ENABLED = $00000002;
  OLECMDF_LATCHED = $00000004;
  OLECMDF_NINCHED = $00000008;
  OLECMDF_INVISIBLE = $00000010;
  OLECMDF_DEFHIDEONCTXTMENU = $00000020;

// OLECMDEXECOPT constants
type
  OLECMDEXECOPT = TOleEnum;
const
  OLECMDEXECOPT_DODEFAULT = $00000000;
  OLECMDEXECOPT_PROMPTUSER = $00000001;
  OLECMDEXECOPT_DONTPROMPTUSER = $00000002;
  OLECMDEXECOPT_SHOWHELP = $00000003;

// tagREADYSTATE constants
type
  tagREADYSTATE = TOleEnum;
const
  READYSTATE_UNINITIALIZED = $00000000;
  READYSTATE_LOADING = $00000001;
  READYSTATE_LOADED = $00000002;
  READYSTATE_INTERACTIVE = $00000003;
  READYSTATE_COMPLETE = $00000004;

// ShellWindowTypeConstants constants
type
  ShellWindowTypeConstants = TOleEnum;
const
  SWC_EXPLORER = $00000000;
  SWC_BROWSER = $00000001;
  SWC_3RDPARTY = $00000002;
  SWC_CALLBACK = $00000004;

// ShellWindowFindWindowOptions constants
type
  ShellWindowFindWindowOptions = TOleEnum;
const
  SWFO_NEEDDISPATCH = $00000001;
  SWFO_INCLUDEPENDING = $00000002;
  SWFO_COOKIEPASSED = $00000004;

type
  RefreshConstants = TOleEnum;
const
  REFRESH_NORMAL = 0;
  REFRESH_IFEXPIRED = 1;
  REFRESH_CONTINUE = 2;
  REFRESH_COMPLETELY = 3;

type
  BrowserNavConstants = TOleEnum;
const
  navOpenInNewWindow = $00000001;
  navNoHistory       = $00000002;
  navNoReadFromCache = $00000004;
  navNoWriteToCache  = $00000008;
  navAllowAutosearch = $00000010;
  navBrowserBar      = $00000020;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IWebBrowser = interface;
  IWebBrowserDisp = dispinterface;
  DWebBrowserEvents = dispinterface;
  IWebBrowserApp = interface;
  IWebBrowserAppDisp = dispinterface;
  IWebBrowser2 = interface;
  IWebBrowser2Disp = dispinterface;
  DWebBrowserEvents2 = dispinterface;
  DShellWindowsEvents = dispinterface;
  IShellWindows = interface;
  IShellWindowsDisp = dispinterface;
  IShellUIHelper = interface;
  IShellUIHelperDisp = dispinterface;
  _ShellFavoritesNameSpaceEvents = dispinterface;
  IShellFavoritesNameSpace = interface;
  IShellFavoritesNameSpaceDisp = dispinterface;
  IScriptErrorList = interface;
  IScriptErrorListDisp = dispinterface;
  ISearch = interface;
  ISearchDisp = dispinterface;
  ISearches = interface;
  ISearchesDisp = dispinterface;
  ISearchAssistantOC = interface;
  ISearchAssistantOCDisp = dispinterface;
  _SearchAssistantEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  WebBrowser_V1 = IWebBrowser;
  WebBrowser = IWebBrowser2;
  InternetExplorer = IWebBrowser2;
  ShellBrowserWindow = IWebBrowser2;
  ShellWindows = IShellWindows;
  ShellUIHelper = IShellUIHelper;
  ShellFavoritesNameSpace = IShellFavoritesNameSpace;
  CScriptErrorList = IScriptErrorList;
  SearchAssistantOC = ISearchAssistantOC;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  POleVariant1 = ^OleVariant; {*}


// *********************************************************************//
// Interface: IWebBrowser
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}
// *********************************************************************//
  IWebBrowser = interface(IDispatch)
    ['{EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}']
    procedure GoBack; safecall;
    procedure GoForward; safecall;
    procedure GoHome; safecall;
    procedure GoSearch; safecall;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; 
                       var TargetFrameName: OleVariant; var PostData: OleVariant; 
                       var Headers: OleVariant); safecall;
    procedure Refresh; safecall;
    procedure Refresh2(var Level: OleVariant); safecall;
    procedure Stop; safecall;
    function  Get_Application: IDispatch; safecall;
    function  Get_Parent: IDispatch; safecall;
    function  Get_Container: IDispatch; safecall;
    function  Get_Document: IDispatch; safecall;
    function  Get_TopLevelContainer: WordBool; safecall;
    function  Get_Type_: WideString; safecall;
    function  Get_Left: Integer; safecall;
    procedure Set_Left(pl: Integer); safecall;
    function  Get_Top: Integer; safecall;
    procedure Set_Top(pl: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(pl: Integer); safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(pl: Integer); safecall;
    function  Get_LocationName: WideString; safecall;
    function  Get_LocationURL: WideString; safecall;
    function  Get_Busy: WordBool; safecall;
    property Application: IDispatch read Get_Application;
    property Parent: IDispatch read Get_Parent;
    property Container: IDispatch read Get_Container;
    property Document: IDispatch read Get_Document;
    property TopLevelContainer: WordBool read Get_TopLevelContainer;
    property Type_: WideString read Get_Type_;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property LocationName: WideString read Get_LocationName;
    property LocationURL: WideString read Get_LocationURL;
    property Busy: WordBool read Get_Busy;
  end;

// *********************************************************************//
// DispIntf:  IWebBrowserDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}
// *********************************************************************//
  IWebBrowserDisp = dispinterface
    ['{EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}']
    procedure GoBack; dispid 100;
    procedure GoForward; dispid 101;
    procedure GoHome; dispid 102;
    procedure GoSearch; dispid 103;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; 
                       var TargetFrameName: OleVariant; var PostData: OleVariant; 
                       var Headers: OleVariant); dispid 104;
    procedure Refresh; dispid -550;
    procedure Refresh2(var Level: OleVariant); dispid 105;
    procedure Stop; dispid 106;
    property Application: IDispatch readonly dispid 200;
    property Parent: IDispatch readonly dispid 201;
    property Container: IDispatch readonly dispid 202;
    property Document: IDispatch readonly dispid 203;
    property TopLevelContainer: WordBool readonly dispid 204;
    property Type_: WideString readonly dispid 205;
    property Left: Integer dispid 206;
    property Top: Integer dispid 207;
    property Width: Integer dispid 208;
    property Height: Integer dispid 209;
    property LocationName: WideString readonly dispid 210;
    property LocationURL: WideString readonly dispid 211;
    property Busy: WordBool readonly dispid 212;
  end;

// *********************************************************************//
// DispIntf:  DWebBrowserEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B}
// *********************************************************************//
  DWebBrowserEvents = dispinterface
    ['{EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B}']
    procedure BeforeNavigate(const URL: WideString; Flags: Integer; 
                             const TargetFrameName: WideString; var PostData: OleVariant; 
                             const Headers: WideString; var Cancel: WordBool); dispid 100;
    procedure NavigateComplete(const URL: WideString); dispid 101;
    procedure StatusTextChange(const Text: WideString); dispid 102;
    procedure ProgressChange(Progress: Integer; ProgressMax: Integer); dispid 108;
    procedure DownloadComplete; dispid 104;
    procedure CommandStateChange(Command: Integer; Enable: WordBool); dispid 105;
    procedure DownloadBegin; dispid 106;
    procedure NewWindow(const URL: WideString; Flags: Integer; const TargetFrameName: WideString; 
                        var PostData: OleVariant; const Headers: WideString; var Processed: WordBool); dispid 107;
    procedure TitleChange(const Text: WideString); dispid 113;
    procedure FrameBeforeNavigate(const URL: WideString; Flags: Integer; 
                                  const TargetFrameName: WideString; var PostData: OleVariant; 
                                  const Headers: WideString; var Cancel: WordBool); dispid 200;
    procedure FrameNavigateComplete(const URL: WideString); dispid 201;
    procedure FrameNewWindow(const URL: WideString; Flags: Integer; 
                             const TargetFrameName: WideString; var PostData: OleVariant; 
                             const Headers: WideString; var Processed: WordBool); dispid 204;
    procedure Quit(var Cancel: WordBool); dispid 103;
    procedure WindowMove; dispid 109;
    procedure WindowResize; dispid 110;
    procedure WindowActivate; dispid 111;
    procedure PropertyChange(const Property_: WideString); dispid 112;
  end;

// *********************************************************************//
// Interface: IWebBrowserApp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002DF05-0000-0000-C000-000000000046}
// *********************************************************************//
  IWebBrowserApp = interface(IWebBrowser)
    ['{0002DF05-0000-0000-C000-000000000046}']
    procedure Quit; safecall;
    procedure ClientToWindow(var pcx: SYSINT; var pcy: SYSINT); safecall;
    procedure PutProperty(const Property_: WideString; vtValue: OleVariant); safecall;
    function  GetProperty(const Property_: WideString): OleVariant; safecall;
    function  Get_Name: WideString; safecall;
    function  Get_HWND: Integer; safecall;
    function  Get_FullName: WideString; safecall;
    function  Get_Path: WideString; safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(pBool: WordBool); safecall;
    function  Get_StatusBar: WordBool; safecall;
    procedure Set_StatusBar(pBool: WordBool); safecall;
    function  Get_StatusText: WideString; safecall;
    procedure Set_StatusText(const StatusText: WideString); safecall;
    function  Get_ToolBar: SYSINT; safecall;
    procedure Set_ToolBar(Value: SYSINT); safecall;
    function  Get_MenuBar: WordBool; safecall;
    procedure Set_MenuBar(Value: WordBool); safecall;
    function  Get_FullScreen: WordBool; safecall;
    procedure Set_FullScreen(pbFullScreen: WordBool); safecall;
    property Name: WideString read Get_Name;
    property HWND: Integer read Get_HWND;
    property FullName: WideString read Get_FullName;
    property Path: WideString read Get_Path;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property StatusBar: WordBool read Get_StatusBar write Set_StatusBar;
    property StatusText: WideString read Get_StatusText write Set_StatusText;
    property ToolBar: SYSINT read Get_ToolBar write Set_ToolBar;
    property MenuBar: WordBool read Get_MenuBar write Set_MenuBar;
    property FullScreen: WordBool read Get_FullScreen write Set_FullScreen;
  end;

// *********************************************************************//
// DispIntf:  IWebBrowserAppDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002DF05-0000-0000-C000-000000000046}
// *********************************************************************//
  IWebBrowserAppDisp = dispinterface
    ['{0002DF05-0000-0000-C000-000000000046}']
    procedure Quit; dispid 300;
    procedure ClientToWindow(var pcx: SYSINT; var pcy: SYSINT); dispid 301;
    procedure PutProperty(const Property_: WideString; vtValue: OleVariant); dispid 302;
    function  GetProperty(const Property_: WideString): OleVariant; dispid 303;
    property Name: WideString readonly dispid 0;
    property HWND: Integer readonly dispid -515;
    property FullName: WideString readonly dispid 400;
    property Path: WideString readonly dispid 401;
    property Visible: WordBool dispid 402;
    property StatusBar: WordBool dispid 403;
    property StatusText: WideString dispid 404;
    property ToolBar: SYSINT dispid 405;
    property MenuBar: WordBool dispid 406;
    property FullScreen: WordBool dispid 407;
    procedure GoBack; dispid 100;
    procedure GoForward; dispid 101;
    procedure GoHome; dispid 102;
    procedure GoSearch; dispid 103;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; 
                       var TargetFrameName: OleVariant; var PostData: OleVariant; 
                       var Headers: OleVariant); dispid 104;
    procedure Refresh; dispid -550;
    procedure Refresh2(var Level: OleVariant); dispid 105;
    procedure Stop; dispid 106;
    property Application: IDispatch readonly dispid 200;
    property Parent: IDispatch readonly dispid 201;
    property Container: IDispatch readonly dispid 202;
    property Document: IDispatch readonly dispid 203;
    property TopLevelContainer: WordBool readonly dispid 204;
    property Type_: WideString readonly dispid 205;
    property Left: Integer dispid 206;
    property Top: Integer dispid 207;
    property Width: Integer dispid 208;
    property Height: Integer dispid 209;
    property LocationName: WideString readonly dispid 210;
    property LocationURL: WideString readonly dispid 211;
    property Busy: WordBool readonly dispid 212;
  end;

// *********************************************************************//
// Interface: IWebBrowser2
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}
// *********************************************************************//
  IWebBrowser2 = interface(IWebBrowserApp)
    ['{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}']
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; 
                        var TargetFrameName: OleVariant; var PostData: OleVariant; 
                        var Headers: OleVariant); safecall;
    function  QueryStatusWB(cmdID: OLECMDID): OLECMDF; safecall;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant;
                     var pvaOut: OleVariant); safecall;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant; 
                             var pvarSize: OleVariant); safecall;
    function  Get_ReadyState: tagREADYSTATE; safecall;
    function  Get_Offline: WordBool; safecall;
    procedure Set_Offline(pbOffline: WordBool); safecall;
    function  Get_Silent: WordBool; safecall;
    procedure Set_Silent(pbSilent: WordBool); safecall;
    function  Get_RegisterAsBrowser: WordBool; safecall;
    procedure Set_RegisterAsBrowser(pbRegister: WordBool); safecall;
    function  Get_RegisterAsDropTarget: WordBool; safecall;
    procedure Set_RegisterAsDropTarget(pbRegister: WordBool); safecall;
    function  Get_TheaterMode: WordBool; safecall;
    procedure Set_TheaterMode(pbRegister: WordBool); safecall;
    function  Get_AddressBar: WordBool; safecall;
    procedure Set_AddressBar(Value: WordBool); safecall;
    function  Get_Resizable: WordBool; safecall;
    procedure Set_Resizable(Value: WordBool); safecall;
    property ReadyState: tagREADYSTATE read Get_ReadyState;
    property Offline: WordBool read Get_Offline write Set_Offline;
    property Silent: WordBool read Get_Silent write Set_Silent;
    property RegisterAsBrowser: WordBool read Get_RegisterAsBrowser write Set_RegisterAsBrowser;
    property RegisterAsDropTarget: WordBool read Get_RegisterAsDropTarget write Set_RegisterAsDropTarget;
    property TheaterMode: WordBool read Get_TheaterMode write Set_TheaterMode;
    property AddressBar: WordBool read Get_AddressBar write Set_AddressBar;
    property Resizable: WordBool read Get_Resizable write Set_Resizable;
  end;

// *********************************************************************//
// DispIntf:  IWebBrowser2Disp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}
// *********************************************************************//
  IWebBrowser2Disp = dispinterface
    ['{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}']
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; 
                        var TargetFrameName: OleVariant; var PostData: OleVariant; 
                        var Headers: OleVariant); dispid 500;
    function  QueryStatusWB(cmdID: OLECMDID): OLECMDF; dispid 501;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant; 
                     var pvaOut: OleVariant); dispid 502;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant; 
                             var pvarSize: OleVariant); dispid 503;
    property ReadyState: tagREADYSTATE readonly dispid -525;
    property Offline: WordBool dispid 550;
    property Silent: WordBool dispid 551;
    property RegisterAsBrowser: WordBool dispid 552;
    property RegisterAsDropTarget: WordBool dispid 553;
    property TheaterMode: WordBool dispid 554;
    property AddressBar: WordBool dispid 555;
    property Resizable: WordBool dispid 556;
    procedure Quit; dispid 300;
    procedure ClientToWindow(var pcx: SYSINT; var pcy: SYSINT); dispid 301;
    procedure PutProperty(const Property_: WideString; vtValue: OleVariant); dispid 302;
    function  GetProperty(const Property_: WideString): OleVariant; dispid 303;
    property Name: WideString readonly dispid 0;
    property HWND: Integer readonly dispid -515;
    property FullName: WideString readonly dispid 400;
    property Path: WideString readonly dispid 401;
    property Visible: WordBool dispid 402;
    property StatusBar: WordBool dispid 403;
    property StatusText: WideString dispid 404;
    property ToolBar: SYSINT dispid 405;
    property MenuBar: WordBool dispid 406;
    property FullScreen: WordBool dispid 407;
    procedure GoBack; dispid 100;
    procedure GoForward; dispid 101;
    procedure GoHome; dispid 102;
    procedure GoSearch; dispid 103;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; 
                       var TargetFrameName: OleVariant; var PostData: OleVariant; 
                       var Headers: OleVariant); dispid 104;
    procedure Refresh; dispid -550;
    procedure Refresh2(var Level: OleVariant); dispid 105;
    procedure Stop; dispid 106;
    property Application: IDispatch readonly dispid 200;
    property Parent: IDispatch readonly dispid 201;
    property Container: IDispatch readonly dispid 202;
    property Document: IDispatch readonly dispid 203;
    property TopLevelContainer: WordBool readonly dispid 204;
    property Type_: WideString readonly dispid 205;
    property Left: Integer dispid 206;
    property Top: Integer dispid 207;
    property Width: Integer dispid 208;
    property Height: Integer dispid 209;
    property LocationName: WideString readonly dispid 210;
    property LocationURL: WideString readonly dispid 211;
    property Busy: WordBool readonly dispid 212;
  end;

// *********************************************************************//
// DispIntf:  DWebBrowserEvents2
// Flags:     (4112) Hidden Dispatchable
// GUID:      {34A715A0-6587-11D0-924A-0020AFC7AC4D}
// *********************************************************************//
  DWebBrowserEvents2 = dispinterface
    ['{34A715A0-6587-11D0-924A-0020AFC7AC4D}']
    procedure StatusTextChange(const Text: WideString); dispid 102;
    procedure ProgressChange(Progress: Integer; ProgressMax: Integer); dispid 108;
    procedure CommandStateChange(Command: Integer; Enable: WordBool); dispid 105;
    procedure DownloadBegin; dispid 106;
    procedure DownloadComplete; dispid 104;
    procedure TitleChange(const Text: WideString); dispid 113;
    procedure PropertyChange(const szProperty: WideString); dispid 112;
    procedure BeforeNavigate2(const pDisp: IDispatch; var URL: OleVariant; var Flags: OleVariant; 
                              var TargetFrameName: OleVariant; var PostData: OleVariant; 
                              var Headers: OleVariant; var Cancel: WordBool); dispid 250;
    procedure NewWindow2(var ppDisp: IDispatch; var Cancel: WordBool); dispid 251;
    procedure NavigateComplete2(const pDisp: IDispatch; var URL: OleVariant); dispid 252;
    procedure DocumentComplete(const pDisp: IDispatch; var URL: OleVariant); dispid 259;
    procedure OnQuit; dispid 253;
    procedure OnVisible(Visible: WordBool); dispid 254;
    procedure OnToolBar(ToolBar: WordBool); dispid 255;
    procedure OnMenuBar(MenuBar: WordBool); dispid 256;
    procedure OnStatusBar(StatusBar: WordBool); dispid 257;
    procedure OnFullScreen(FullScreen: WordBool); dispid 258;
    procedure OnTheaterMode(TheaterMode: WordBool); dispid 260;
  end;

// *********************************************************************//
// DispIntf:  DShellWindowsEvents
// Flags:     (4096) Dispatchable
// GUID:      {FE4106E0-399A-11D0-A48C-00A0C90A8F39}
// *********************************************************************//
  DShellWindowsEvents = dispinterface
    ['{FE4106E0-399A-11D0-A48C-00A0C90A8F39}']
    procedure WindowRegistered(lCookie: Integer); dispid 200;
    procedure WindowRevoked(lCookie: Integer); dispid 201;
  end;

// *********************************************************************//
// Interface: IShellWindows
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {85CB6900-4D95-11CF-960C-0080C7F4EE85}
// *********************************************************************//
  IShellWindows = interface(IDispatch)
    ['{85CB6900-4D95-11CF-960C-0080C7F4EE85}']
    function  Get_Count: Integer; safecall;
    function  Item(index: OleVariant): IDispatch; safecall;
    function  _NewEnum: IUnknown; safecall;
    procedure Register(const pid: IDispatch; HWND: Integer; swClass: SYSINT; out plCookie: Integer); safecall;
    procedure RegisterPending(lThreadId: Integer; var pvarloc: OleVariant; 
                              var pvarlocRoot: OleVariant; swClass: SYSINT; out plCookie: Integer); safecall;
    procedure Revoke(lCookie: Integer); safecall;
    procedure OnNavigate(lCookie: Integer; var pvarloc: OleVariant); safecall;
    procedure OnActivated(lCookie: Integer; fActive: WordBool); safecall;
    function  FindWindow(var pvarloc: OleVariant; var pvarlocRoot: OleVariant; swClass: SYSINT; 
                         out pHWND: Integer; swfwOptions: SYSINT): IDispatch; safecall;
    procedure OnCreated(lCookie: Integer; const punk: IUnknown); safecall;
    procedure ProcessAttachDetach(fAttach: WordBool); safecall;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IShellWindowsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {85CB6900-4D95-11CF-960C-0080C7F4EE85}
// *********************************************************************//
  IShellWindowsDisp = dispinterface
    ['{85CB6900-4D95-11CF-960C-0080C7F4EE85}']
    property Count: Integer readonly dispid 1610743808;
    function  Item(index: OleVariant): IDispatch; dispid 0;
    function  _NewEnum: IUnknown; dispid -4;
    procedure Register(const pid: IDispatch; HWND: Integer; swClass: SYSINT; out plCookie: Integer); dispid 1610743811;
    procedure RegisterPending(lThreadId: Integer; var pvarloc: OleVariant; 
                              var pvarlocRoot: OleVariant; swClass: SYSINT; out plCookie: Integer); dispid 1610743812;
    procedure Revoke(lCookie: Integer); dispid 1610743813;
    procedure OnNavigate(lCookie: Integer; var pvarloc: OleVariant); dispid 1610743814;
    procedure OnActivated(lCookie: Integer; fActive: WordBool); dispid 1610743815;
    function  FindWindow(var pvarloc: OleVariant; var pvarlocRoot: OleVariant; swClass: SYSINT; 
                         out pHWND: Integer; swfwOptions: SYSINT): IDispatch; dispid 1610743816;
    procedure OnCreated(lCookie: Integer; const punk: IUnknown); dispid 1610743817;
    procedure ProcessAttachDetach(fAttach: WordBool); dispid 1610743818;
  end;

// *********************************************************************//
// Interface: IShellUIHelper
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {729FE2F8-1EA8-11D1-8F85-00C04FC2FBE1}
// *********************************************************************//
  IShellUIHelper = interface(IDispatch)
    ['{729FE2F8-1EA8-11D1-8F85-00C04FC2FBE1}']
    procedure ResetFirstBootMode; safecall;
    procedure ResetSafeMode; safecall;
    procedure RefreshOfflineDesktop; safecall;
    procedure AddFavorite(const URL: WideString; var Title: OleVariant); safecall;
    procedure AddChannel(const URL: WideString); safecall;
    procedure AddDesktopComponent(const URL: WideString; const Type_: WideString; 
                                  var Left: OleVariant; var Top: OleVariant; var Width: OleVariant; 
                                  var Height: OleVariant); safecall;
    function  IsSubscribed(const URL: WideString): WordBool; safecall;
    procedure NavigateAndFind(const URL: WideString; const strQuery: WideString; 
                              var varTargetFrame: OleVariant); safecall;
    procedure ImportExportFavorites(fImport: WordBool; const strImpExpPath: WideString); safecall;
    procedure AutoCompleteSaveForm(var Form: OleVariant); safecall;
    procedure AutoScan(const strSearch: WideString; const strFailureUrl: WideString; 
                       var pvarTargetFrame: OleVariant); safecall;
    procedure AutoCompleteAttach(var Reserved: OleVariant); safecall;
    function  ShowBrowserUI(const bstrName: WideString; var pvarIn: OleVariant): OleVariant; safecall;
  end;

// *********************************************************************//
// DispIntf:  IShellUIHelperDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {729FE2F8-1EA8-11D1-8F85-00C04FC2FBE1}
// *********************************************************************//
  IShellUIHelperDisp = dispinterface
    ['{729FE2F8-1EA8-11D1-8F85-00C04FC2FBE1}']
    procedure ResetFirstBootMode; dispid 1;
    procedure ResetSafeMode; dispid 2;
    procedure RefreshOfflineDesktop; dispid 3;
    procedure AddFavorite(const URL: WideString; var Title: OleVariant); dispid 4;
    procedure AddChannel(const URL: WideString); dispid 5;
    procedure AddDesktopComponent(const URL: WideString; const Type_: WideString; 
                                  var Left: OleVariant; var Top: OleVariant; var Width: OleVariant; 
                                  var Height: OleVariant); dispid 6;
    function  IsSubscribed(const URL: WideString): WordBool; dispid 7;
    procedure NavigateAndFind(const URL: WideString; const strQuery: WideString; 
                              var varTargetFrame: OleVariant); dispid 8;
    procedure ImportExportFavorites(fImport: WordBool; const strImpExpPath: WideString); dispid 9;
    procedure AutoCompleteSaveForm(var Form: OleVariant); dispid 10;
    procedure AutoScan(const strSearch: WideString; const strFailureUrl: WideString; 
                       var pvarTargetFrame: OleVariant); dispid 11;
    procedure AutoCompleteAttach(var Reserved: OleVariant); dispid 12;
    function  ShowBrowserUI(const bstrName: WideString; var pvarIn: OleVariant): OleVariant; dispid 13;
  end;

// *********************************************************************//
// DispIntf:  _ShellFavoritesNameSpaceEvents
// Flags:     (4096) Dispatchable
// GUID:      {55136806-B2DE-11D1-B9F2-00A0C98BC547}
// *********************************************************************//
  _ShellFavoritesNameSpaceEvents = dispinterface
    ['{55136806-B2DE-11D1-B9F2-00A0C98BC547}']
    procedure FavoritesSelectionChange(cItems: Integer; hItem: Integer; const strName: WideString; 
                                       const strUrl: WideString; cVisits: Integer; 
                                       const strDate: WideString; fAvailableOffline: Integer); dispid 1;
  end;

// *********************************************************************//
// Interface: IShellFavoritesNameSpace
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {55136804-B2DE-11D1-B9F2-00A0C98BC547}
// *********************************************************************//
  IShellFavoritesNameSpace = interface(IDispatch)
    ['{55136804-B2DE-11D1-B9F2-00A0C98BC547}']
    procedure MoveSelectionUp; safecall;
    procedure MoveSelectionDown; safecall;
    procedure ResetSort; safecall;
    procedure NewFolder; safecall;
    procedure Synchronize; safecall;
    procedure Import; safecall;
    procedure Export; safecall;
    procedure InvokeContextMenuCommand(const strCommand: WideString); safecall;
    procedure MoveSelectionTo; safecall;
    function  Get_FOfflinePackInstalled: WordBool; safecall;
    function  CreateSubscriptionForSelection: WordBool; safecall;
    function  DeleteSubscriptionForSelection: WordBool; safecall;
    procedure SetRoot(const bstrFullPath: WideString); safecall;
    property FOfflinePackInstalled: WordBool read Get_FOfflinePackInstalled;
  end;

// *********************************************************************//
// DispIntf:  IShellFavoritesNameSpaceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {55136804-B2DE-11D1-B9F2-00A0C98BC547}
// *********************************************************************//
  IShellFavoritesNameSpaceDisp = dispinterface
    ['{55136804-B2DE-11D1-B9F2-00A0C98BC547}']
    procedure MoveSelectionUp; dispid 1;
    procedure MoveSelectionDown; dispid 2;
    procedure ResetSort; dispid 3;
    procedure NewFolder; dispid 4;
    procedure Synchronize; dispid 5;
    procedure Import; dispid 6;
    procedure Export; dispid 7;
    procedure InvokeContextMenuCommand(const strCommand: WideString); dispid 8;
    procedure MoveSelectionTo; dispid 9;
    property FOfflinePackInstalled: WordBool readonly dispid 10;
    function  CreateSubscriptionForSelection: WordBool; dispid 11;
    function  DeleteSubscriptionForSelection: WordBool; dispid 12;
    procedure SetRoot(const bstrFullPath: WideString); dispid 13;
  end;

// *********************************************************************//
// Interface: IScriptErrorList
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {F3470F24-15FD-11D2-BB2E-00805FF7EFCA}
// *********************************************************************//
  IScriptErrorList = interface(IDispatch)
    ['{F3470F24-15FD-11D2-BB2E-00805FF7EFCA}']
    procedure advanceError; safecall;
    procedure retreatError; safecall;
    function  canAdvanceError: Integer; safecall;
    function  canRetreatError: Integer; safecall;
    function  getErrorLine: Integer; safecall;
    function  getErrorChar: Integer; safecall;
    function  getErrorCode: Integer; safecall;
    function  getErrorMsg: WideString; safecall;
    function  getErrorUrl: WideString; safecall;
    function  getAlwaysShowLockState: Integer; safecall;
    function  getDetailsPaneOpen: Integer; safecall;
    procedure setDetailsPaneOpen(fDetailsPaneOpen: Integer); safecall;
    function  getPerErrorDisplay: Integer; safecall;
    procedure setPerErrorDisplay(fPerErrorDisplay: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IScriptErrorListDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {F3470F24-15FD-11D2-BB2E-00805FF7EFCA}
// *********************************************************************//
  IScriptErrorListDisp = dispinterface
    ['{F3470F24-15FD-11D2-BB2E-00805FF7EFCA}']
    procedure advanceError; dispid 10;
    procedure retreatError; dispid 11;
    function  canAdvanceError: Integer; dispid 12;
    function  canRetreatError: Integer; dispid 13;
    function  getErrorLine: Integer; dispid 14;
    function  getErrorChar: Integer; dispid 15;
    function  getErrorCode: Integer; dispid 16;
    function  getErrorMsg: WideString; dispid 17;
    function  getErrorUrl: WideString; dispid 18;
    function  getAlwaysShowLockState: Integer; dispid 23;
    function  getDetailsPaneOpen: Integer; dispid 19;
    procedure setDetailsPaneOpen(fDetailsPaneOpen: Integer); dispid 20;
    function  getPerErrorDisplay: Integer; dispid 21;
    procedure setPerErrorDisplay(fPerErrorDisplay: Integer); dispid 22;
  end;

// *********************************************************************//
// Interface: ISearch
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {BA9239A4-3DD5-11D2-BF8B-00C04FB93661}
// *********************************************************************//
  ISearch = interface(IDispatch)
    ['{BA9239A4-3DD5-11D2-BF8B-00C04FB93661}']
    function  Get_Title: WideString; safecall;
    function  Get_Id: WideString; safecall;
    function  Get_URL: WideString; safecall;
    property Title: WideString read Get_Title;
    property Id: WideString read Get_Id;
    property URL: WideString read Get_URL;
  end;

// *********************************************************************//
// DispIntf:  ISearchDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {BA9239A4-3DD5-11D2-BF8B-00C04FB93661}
// *********************************************************************//
  ISearchDisp = dispinterface
    ['{BA9239A4-3DD5-11D2-BF8B-00C04FB93661}']
    property Title: WideString readonly dispid 1610743808;
    property Id: WideString readonly dispid 1610743809;
    property URL: WideString readonly dispid 1610743810;
  end;

// *********************************************************************//
// Interface: ISearches
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {47C922A2-3DD5-11D2-BF8B-00C04FB93661}
// *********************************************************************//
  ISearches = interface(IDispatch)
    ['{47C922A2-3DD5-11D2-BF8B-00C04FB93661}']
    function  Get_Count: Integer; safecall;
    function  Get_Default: WideString; safecall;
    function  Item(index: OleVariant): ISearch; safecall;
    function  _NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property Default: WideString read Get_Default;
  end;

// *********************************************************************//
// DispIntf:  ISearchesDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {47C922A2-3DD5-11D2-BF8B-00C04FB93661}
// *********************************************************************//
  ISearchesDisp = dispinterface
    ['{47C922A2-3DD5-11D2-BF8B-00C04FB93661}']
    property Count: Integer readonly dispid 1610743808;
    property Default: WideString readonly dispid 1610743809;
    function  Item(index: OleVariant): ISearch; dispid 1610743810;
    function  _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// Interface: ISearchAssistantOC
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {72423E8F-8011-11D2-BE79-00A0C9A83DA1}
// *********************************************************************//
  ISearchAssistantOC = interface(IDispatch)
    ['{72423E8F-8011-11D2-BE79-00A0C9A83DA1}']
    procedure AddNextMenuItem(const bstrText: WideString; idItem: Integer); safecall;
    procedure SetDefaultSearchUrl(const bstrUrl: WideString); safecall;
    procedure NavigateToDefaultSearch; safecall;
    function  IsRestricted(const bstrGuid: WideString): WordBool; safecall;
    function  Get_ShellFeaturesEnabled: WordBool; safecall;
    function  Get_SearchAssistantDefault: WordBool; safecall;
    function  Get_Searches: ISearches; safecall;
    function  Get_InWebFolder: WordBool; safecall;
    procedure PutProperty(bPerLocale: WordBool; const bstrName: WideString; 
                          const bstrValue: WideString); safecall;
    function  GetProperty(bPerLocale: WordBool; const bstrName: WideString): WideString; safecall;
    procedure Set_EventHandled(Param1: WordBool); safecall;
    procedure ResetNextMenu; safecall;
    procedure FindOnWeb; safecall;
    procedure FindFilesOrFolders; safecall;
    procedure FindComputer; safecall;
    procedure FindPrinter; safecall;
    procedure FindPeople; safecall;
    function  GetSearchAssistantURL(bSubstitute: WordBool; bCustomize: WordBool): WideString; safecall;
    procedure NotifySearchSettingsChanged; safecall;
    procedure Set_ASProvider(const pProvider: WideString); safecall;
    function  Get_ASProvider: WideString; safecall;
    procedure Set_ASSetting(pSetting: SYSINT); safecall;
    function  Get_ASSetting: SYSINT; safecall;
    procedure NETDetectNextNavigate; safecall;
    procedure PutFindText(const FindText: WideString); safecall;
    function  Get_Version: SYSINT; safecall;
    function  EncodeString(const bstrValue: WideString; const bstrCharSet: WideString; 
                           bUseUTF8: WordBool): WideString; safecall;
    property ShellFeaturesEnabled: WordBool read Get_ShellFeaturesEnabled;
    property SearchAssistantDefault: WordBool read Get_SearchAssistantDefault;
    property Searches: ISearches read Get_Searches;
    property InWebFolder: WordBool read Get_InWebFolder;
    property EventHandled: WordBool write Set_EventHandled;
    property ASProvider: WideString read Get_ASProvider write Set_ASProvider;
    property ASSetting: SYSINT read Get_ASSetting write Set_ASSetting;
    property Version: SYSINT read Get_Version;
  end;

// *********************************************************************//
// DispIntf:  ISearchAssistantOCDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {72423E8F-8011-11D2-BE79-00A0C9A83DA1}
// *********************************************************************//
  ISearchAssistantOCDisp = dispinterface
    ['{72423E8F-8011-11D2-BE79-00A0C9A83DA1}']
    procedure AddNextMenuItem(const bstrText: WideString; idItem: Integer); dispid 1;
    procedure SetDefaultSearchUrl(const bstrUrl: WideString); dispid 2;
    procedure NavigateToDefaultSearch; dispid 3;
    function  IsRestricted(const bstrGuid: WideString): WordBool; dispid 4;
    property ShellFeaturesEnabled: WordBool readonly dispid 5;
    property SearchAssistantDefault: WordBool readonly dispid 6;
    property Searches: ISearches readonly dispid 7;
    property InWebFolder: WordBool readonly dispid 8;
    procedure PutProperty(bPerLocale: WordBool; const bstrName: WideString; 
                          const bstrValue: WideString); dispid 9;
    function  GetProperty(bPerLocale: WordBool; const bstrName: WideString): WideString; dispid 10;
    property EventHandled: WordBool writeonly dispid 11;
    procedure ResetNextMenu; dispid 12;
    procedure FindOnWeb; dispid 13;
    procedure FindFilesOrFolders; dispid 14;
    procedure FindComputer; dispid 15;
    procedure FindPrinter; dispid 16;
    procedure FindPeople; dispid 17;
    function  GetSearchAssistantURL(bSubstitute: WordBool; bCustomize: WordBool): WideString; dispid 18;
    procedure NotifySearchSettingsChanged; dispid 19;
    property ASProvider: WideString dispid 20;
    property ASSetting: SYSINT dispid 21;
    procedure NETDetectNextNavigate; dispid 22;
    procedure PutFindText(const FindText: WideString); dispid 23;
    property Version: SYSINT readonly dispid 24;
    function  EncodeString(const bstrValue: WideString; const bstrCharSet: WideString; 
                           bUseUTF8: WordBool): WideString; dispid 25;
  end;

// *********************************************************************//
// DispIntf:  _SearchAssistantEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {1611FDDA-445B-11D2-85DE-00C04FA35C89}
// *********************************************************************//
  _SearchAssistantEvents = dispinterface
    ['{1611FDDA-445B-11D2-85DE-00C04FA35C89}']
    procedure OnNextMenuSelect(idItem: Integer); dispid 1;
    procedure OnNewSearch; dispid 2;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TWebBrowser_V1
// Help String      : WebBrowser Control
// Default Interface: IWebBrowser
// Def. Intf. DISP? : No
// Event   Interface: DWebBrowserEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TWebBrowser_V1BeforeNavigate = procedure(Sender: TObject; const URL: WideString; Flags: Integer; 
                                                            const TargetFrameName: WideString; 
                                                            var PostData: OleVariant; 
                                                            const Headers: WideString; 
                                                            var Cancel: WordBool) of object;
  TWebBrowser_V1NavigateComplete = procedure(Sender: TObject; const URL: WideString) of object;
  TWebBrowser_V1StatusTextChange = procedure(Sender: TObject; const Text: WideString) of object;
  TWebBrowser_V1ProgressChange = procedure(Sender: TObject; Progress: Integer; ProgressMax: Integer) of object;
  TWebBrowser_V1CommandStateChange = procedure(Sender: TObject; Command: Integer; Enable: WordBool) of object;
  TWebBrowser_V1NewWindow = procedure(Sender: TObject; const URL: WideString; Flags: Integer; 
                                                       const TargetFrameName: WideString; 
                                                       var PostData: OleVariant; 
                                                       const Headers: WideString; 
                                                       var Processed: WordBool) of object;
  TWebBrowser_V1TitleChange = procedure(Sender: TObject; const Text: WideString) of object;
  TWebBrowser_V1FrameBeforeNavigate = procedure(Sender: TObject; const URL: WideString; 
                                                                 Flags: Integer; 
                                                                 const TargetFrameName: WideString; 
                                                                 var PostData: OleVariant; 
                                                                 const Headers: WideString; 
                                                                 var Cancel: WordBool) of object;
  TWebBrowser_V1FrameNavigateComplete = procedure(Sender: TObject; const URL: WideString) of object;
  TWebBrowser_V1FrameNewWindow = procedure(Sender: TObject; const URL: WideString; Flags: Integer; 
                                                            const TargetFrameName: WideString; 
                                                            var PostData: OleVariant; 
                                                            const Headers: WideString; 
                                                            var Processed: WordBool) of object;
  TWebBrowser_V1Quit = procedure(Sender: TObject; var Cancel: WordBool) of object;
  TWebBrowser_V1PropertyChange = procedure(Sender: TObject; const Property_: WideString) of object;

(*
  TWebBrowser_V1 = class(TOleControl)
  private
    FOnBeforeNavigate: TWebBrowser_V1BeforeNavigate;
    FOnNavigateComplete: TWebBrowser_V1NavigateComplete;
    FOnStatusTextChange: TWebBrowser_V1StatusTextChange;
    FOnProgressChange: TWebBrowser_V1ProgressChange;
    FOnDownloadComplete: TNotifyEvent;
    FOnCommandStateChange: TWebBrowser_V1CommandStateChange;
    FOnDownloadBegin: TNotifyEvent;
    FOnNewWindow: TWebBrowser_V1NewWindow;
    FOnTitleChange: TWebBrowser_V1TitleChange;
    FOnFrameBeforeNavigate: TWebBrowser_V1FrameBeforeNavigate;
    FOnFrameNavigateComplete: TWebBrowser_V1FrameNavigateComplete;
    FOnFrameNewWindow: TWebBrowser_V1FrameNewWindow;
    FOnQuit: TWebBrowser_V1Quit;
    FOnWindowMove: TNotifyEvent;
    FOnWindowResize: TNotifyEvent;
    FOnWindowActivate: TNotifyEvent;
    FOnPropertyChange: TWebBrowser_V1PropertyChange;
    FIntf: IWebBrowser;
    function  GetControlInterface: IWebBrowser;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function  Get_Application: IDispatch;
    function  Get_Parent: IDispatch;
    function  Get_Container: IDispatch;
    function  Get_Document: IDispatch;
  public
    procedure GoBack;
    procedure GoForward;
    procedure GoHome;
    procedure GoSearch;

    procedure Navigate(const URL: WideString); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_1{$endif}(const URL: WideString; var Flags: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_2{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_3{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant; var PostData: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_4{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant;
      var PostData: OleVariant; var Headers: OleVariant); {$ifdef bDelphi5}overload;{$endif}

    procedure Refresh;
    procedure Refresh2; {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Refresh2{$else}Refresh2_1{$endif}(var Level: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure Stop;
    property  ControlInterface: IWebBrowser read GetControlInterface;
    property  DefaultInterface: IWebBrowser read GetControlInterface;
    property Application: IDispatch index 200 read GetIDispatchProp;
    property Parent: IDispatch index 201 read GetIDispatchProp;
    property Container: IDispatch index 202 read GetIDispatchProp;
    property Document: IDispatch index 203 read GetIDispatchProp;
    property TopLevelContainer: WordBool index 204 read GetWordBoolProp;
    property Type_: WideString index 205 read GetWideStringProp;
    property LocationName: WideString index 210 read GetWideStringProp;
    property LocationURL: WideString index 211 read GetWideStringProp;
    property Busy: WordBool index 212 read GetWordBoolProp;
  published
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property OnBeforeNavigate: TWebBrowser_V1BeforeNavigate read FOnBeforeNavigate write FOnBeforeNavigate;
    property OnNavigateComplete: TWebBrowser_V1NavigateComplete read FOnNavigateComplete write FOnNavigateComplete;
    property OnStatusTextChange: TWebBrowser_V1StatusTextChange read FOnStatusTextChange write FOnStatusTextChange;
    property OnProgressChange: TWebBrowser_V1ProgressChange read FOnProgressChange write FOnProgressChange;
    property OnDownloadComplete: TNotifyEvent read FOnDownloadComplete write FOnDownloadComplete;
    property OnCommandStateChange: TWebBrowser_V1CommandStateChange read FOnCommandStateChange write FOnCommandStateChange;
    property OnDownloadBegin: TNotifyEvent read FOnDownloadBegin write FOnDownloadBegin;
    property OnNewWindow: TWebBrowser_V1NewWindow read FOnNewWindow write FOnNewWindow;
    property OnTitleChange: TWebBrowser_V1TitleChange read FOnTitleChange write FOnTitleChange;
    property OnFrameBeforeNavigate: TWebBrowser_V1FrameBeforeNavigate read FOnFrameBeforeNavigate write FOnFrameBeforeNavigate;
    property OnFrameNavigateComplete: TWebBrowser_V1FrameNavigateComplete read FOnFrameNavigateComplete write FOnFrameNavigateComplete;
    property OnFrameNewWindow: TWebBrowser_V1FrameNewWindow read FOnFrameNewWindow write FOnFrameNewWindow;
    property OnQuit: TWebBrowser_V1Quit read FOnQuit write FOnQuit;
    property OnWindowMove: TNotifyEvent read FOnWindowMove write FOnWindowMove;
    property OnWindowResize: TNotifyEvent read FOnWindowResize write FOnWindowResize;
    property OnWindowActivate: TNotifyEvent read FOnWindowActivate write FOnWindowActivate;
    property OnPropertyChange: TWebBrowser_V1PropertyChange read FOnPropertyChange write FOnPropertyChange;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TWebBrowser
// Help String      : WebBrowser Control
// Default Interface: IWebBrowser2
// Def. Intf. DISP? : No
// Event   Interface: DWebBrowserEvents2
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TWebBrowserStatusTextChange = procedure(Sender: TObject; const Text: WideString) of object;
  TWebBrowserProgressChange = procedure(Sender: TObject; Progress: Integer; ProgressMax: Integer) of object;
  TWebBrowserCommandStateChange = procedure(Sender: TObject; Command: Integer; Enable: WordBool) of object;
  TWebBrowserTitleChange = procedure(Sender: TObject; const Text: WideString) of object;
  TWebBrowserPropertyChange = procedure(Sender: TObject; const szProperty: WideString) of object;
  TWebBrowserBeforeNavigate2 = procedure(Sender: TObject; const pDisp: IDispatch; 
                                                          var URL: OleVariant; 
                                                          var Flags: OleVariant; 
                                                          var TargetFrameName: OleVariant; 
                                                          var PostData: OleVariant; 
                                                          var Headers: OleVariant;
                                                          var Cancel: WordBool) of object;
  TWebBrowserNewWindow2 = procedure(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool) of object;
  TWebBrowserNavigateComplete2 = procedure(Sender: TObject; const pDisp: IDispatch; 
                                                            var URL: OleVariant) of object;
  TWebBrowserDocumentComplete = procedure(Sender: TObject; const pDisp: IDispatch; 
                                                           var URL: OleVariant) of object;
  TWebBrowserOnVisible = procedure(Sender: TObject; Visible: WordBool) of object;
  TWebBrowserOnToolBar = procedure(Sender: TObject; ToolBar: WordBool) of object;
  TWebBrowserOnMenuBar = procedure(Sender: TObject; MenuBar: WordBool) of object;
  TWebBrowserOnStatusBar = procedure(Sender: TObject; StatusBar: WordBool) of object;
  TWebBrowserOnFullScreen = procedure(Sender: TObject; FullScreen: WordBool) of object;
  TWebBrowserOnTheaterMode = procedure(Sender: TObject; TheaterMode: WordBool) of object;

  TWebBrowser = class(TOleControl)
  private
    FOnStatusTextChange: TWebBrowserStatusTextChange;
    FOnProgressChange: TWebBrowserProgressChange;
    FOnCommandStateChange: TWebBrowserCommandStateChange;
    FOnDownloadBegin: TNotifyEvent;
    FOnDownloadComplete: TNotifyEvent;
    FOnTitleChange: TWebBrowserTitleChange;
    FOnPropertyChange: TWebBrowserPropertyChange;
    FOnBeforeNavigate2: TWebBrowserBeforeNavigate2;
    FOnNewWindow2: TWebBrowserNewWindow2;
    FOnNavigateComplete2: TWebBrowserNavigateComplete2;
    FOnDocumentComplete: TWebBrowserDocumentComplete;
    FOnQuit: TNotifyEvent;
    FOnVisible: TWebBrowserOnVisible;
    FOnToolBar: TWebBrowserOnToolBar;
    FOnMenuBar: TWebBrowserOnMenuBar;
    FOnStatusBar: TWebBrowserOnStatusBar;
    FOnFullScreen: TWebBrowserOnFullScreen;
    FOnTheaterMode: TWebBrowserOnTheaterMode;
    FIntf: IWebBrowser2;
    function  GetControlInterface: IWebBrowser2;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function  Get_Application: IDispatch;
    function  Get_Parent: IDispatch;
    function  Get_Container: IDispatch;
    function  Get_Document: IDispatch;
  public
    procedure GoBack;
    procedure GoForward;
    procedure GoHome;
    procedure GoSearch;

    procedure Navigate(const URL: WideString); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_1{$endif}(const URL: WideString; var Flags: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_2{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_3{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant; var PostData: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Navigate{$else}Navigate_4{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant;
      var PostData: OleVariant; var Headers: OleVariant); {$ifdef bDelphi5}overload;{$endif}

    procedure Refresh;
    procedure Refresh2; {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}Refresh2{$else}Refresh2_1{$endif}(var Level: OleVariant);  {$ifdef bDelphi5}overload;{$endif}
    procedure Stop;
    procedure Quit;
    procedure ClientToWindow(var pcx: SYSINT; var pcy: SYSINT);
    procedure PutProperty(const Property_: WideString; vtValue: OleVariant);
    function  GetProperty(const Property_: WideString): OleVariant;

    procedure Navigate2(var URL: OleVariant); {$ifdef bDelphi5} overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant); overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant); overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant; var PostData: OleVariant); overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant;
      var PostData: OleVariant; var Headers: OleVariant); overload; {$endif bDelphi5}

    function  QueryStatusWB(cmdID: OLECMDID): OLECMDF;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT); {$ifdef bDelphi5} overload;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant); overload;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant; var pvaOut: OleVariant); overload; {$endif bDelphi5}

    procedure ShowBrowserBar(var pvaClsid: OleVariant); {$ifdef bDelphi5} overload;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant); overload;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant; var pvarSize: OleVariant); overload; {$endif bDelphi5}

    property  ControlInterface: IWebBrowser2 read GetControlInterface;
    property  DefaultInterface: IWebBrowser2 read GetControlInterface;
    property Application: IDispatch index 200 read GetIDispatchProp;
    property Parent: IDispatch index 201 read GetIDispatchProp;
    property Container: IDispatch index 202 read GetIDispatchProp;
    property Document: IDispatch index 203 read GetIDispatchProp;
    property TopLevelContainer: WordBool index 204 read GetWordBoolProp;
    property Type_: WideString index 205 read GetWideStringProp;
    property LocationName: WideString index 210 read GetWideStringProp;
    property LocationURL: WideString index 211 read GetWideStringProp;
    property Busy: WordBool index 212 read GetWordBoolProp;
    property Name: WideString index 0 read GetWideStringProp;
    property HWND: Integer index -515 read GetIntegerProp;
    property FullName: WideString index 400 read GetWideStringProp;
    property Path: WideString index 401 read GetWideStringProp;
    property ReadyState: TOleEnum index -525 read GetTOleEnumProp;
  published
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property Visible: WordBool index 402 read GetWordBoolProp write SetWordBoolProp stored False;
    property StatusBar: WordBool index 403 read GetWordBoolProp write SetWordBoolProp stored False;
    property StatusText: WideString index 404 read GetWideStringProp write SetWideStringProp stored False;
    property ToolBar: Integer index 405 read GetIntegerProp write SetIntegerProp stored False;
    property MenuBar: WordBool index 406 read GetWordBoolProp write SetWordBoolProp stored False;
    property FullScreen: WordBool index 407 read GetWordBoolProp write SetWordBoolProp stored False;
    property Offline: WordBool index 550 read GetWordBoolProp write SetWordBoolProp stored False;
    property Silent: WordBool index 551 read GetWordBoolProp write SetWordBoolProp stored False;
    property RegisterAsBrowser: WordBool index 552 read GetWordBoolProp write SetWordBoolProp stored False;
    property RegisterAsDropTarget: WordBool index 553 read GetWordBoolProp write SetWordBoolProp stored False;
    property TheaterMode: WordBool index 554 read GetWordBoolProp write SetWordBoolProp stored False;
    property AddressBar: WordBool index 555 read GetWordBoolProp write SetWordBoolProp stored False;
    property Resizable: WordBool index 556 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnStatusTextChange: TWebBrowserStatusTextChange read FOnStatusTextChange write FOnStatusTextChange;
    property OnProgressChange: TWebBrowserProgressChange read FOnProgressChange write FOnProgressChange;
    property OnCommandStateChange: TWebBrowserCommandStateChange read FOnCommandStateChange write FOnCommandStateChange;
    property OnDownloadBegin: TNotifyEvent read FOnDownloadBegin write FOnDownloadBegin;
    property OnDownloadComplete: TNotifyEvent read FOnDownloadComplete write FOnDownloadComplete;
    property OnTitleChange: TWebBrowserTitleChange read FOnTitleChange write FOnTitleChange;
    property OnPropertyChange: TWebBrowserPropertyChange read FOnPropertyChange write FOnPropertyChange;
    property OnBeforeNavigate2: TWebBrowserBeforeNavigate2 read FOnBeforeNavigate2 write FOnBeforeNavigate2;
    property OnNewWindow2: TWebBrowserNewWindow2 read FOnNewWindow2 write FOnNewWindow2;
    property OnNavigateComplete2: TWebBrowserNavigateComplete2 read FOnNavigateComplete2 write FOnNavigateComplete2;
    property OnDocumentComplete: TWebBrowserDocumentComplete read FOnDocumentComplete write FOnDocumentComplete;
    property OnQuit: TNotifyEvent read FOnQuit write FOnQuit;
    property OnVisible: TWebBrowserOnVisible read FOnVisible write FOnVisible;
    property OnToolBar: TWebBrowserOnToolBar read FOnToolBar write FOnToolBar;
    property OnMenuBar: TWebBrowserOnMenuBar read FOnMenuBar write FOnMenuBar;
    property OnStatusBar: TWebBrowserOnStatusBar read FOnStatusBar write FOnStatusBar;
    property OnFullScreen: TWebBrowserOnFullScreen read FOnFullScreen write FOnFullScreen;
    property OnTheaterMode: TWebBrowserOnTheaterMode read FOnTheaterMode write FOnTheaterMode;
  end;

// *********************************************************************//
// The Class CoInternetExplorer provides a Create and CreateRemote method to          
// create instances of the default interface IWebBrowser2 exposed by              
// the CoClass InternetExplorer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoInternetExplorer = class
    class function Create: IWebBrowser2;
    class function CreateRemote(const MachineName: string): IWebBrowser2;
  end;

  TInternetExplorerStatusTextChange = procedure(Sender: TObject; var Text: OleVariant) of object;
  TInternetExplorerProgressChange = procedure(Sender: TObject; Progress: Integer; 
                                                               ProgressMax: Integer) of object;
  TInternetExplorerCommandStateChange = procedure(Sender: TObject; Command: Integer; 
                                                                   Enable: WordBool) of object;
  TInternetExplorerTitleChange = procedure(Sender: TObject; var Text: OleVariant) of object;
  TInternetExplorerPropertyChange = procedure(Sender: TObject; var szProperty: OleVariant) of object;
  TInternetExplorerBeforeNavigate2 = procedure(Sender: TObject; var pDisp: OleVariant;
                                                                var URL: OleVariant;
                                                                var Flags: OleVariant;
                                                                var TargetFrameName: OleVariant;
                                                                var PostData: OleVariant;
                                                                var Headers: OleVariant;
                                                                var Cancel: OleVariant) of object;
  TInternetExplorerNewWindow2 = procedure(Sender: TObject; var ppDisp: OleVariant;
                                                           var Cancel: OleVariant) of object;
  TInternetExplorerNavigateComplete2 = procedure(Sender: TObject; var pDisp: OleVariant;
                                                                  var URL: OleVariant) of object;
  TInternetExplorerDocumentComplete = procedure(Sender: TObject; var pDisp: OleVariant;
                                                                 var URL: OleVariant) of object;
  TInternetExplorerOnVisible = procedure(Sender: TObject; Visible: WordBool) of object;
  TInternetExplorerOnToolBar = procedure(Sender: TObject; ToolBar: WordBool) of object;
  TInternetExplorerOnMenuBar = procedure(Sender: TObject; MenuBar: WordBool) of object;
  TInternetExplorerOnStatusBar = procedure(Sender: TObject; StatusBar: WordBool) of object;
  TInternetExplorerOnFullScreen = procedure(Sender: TObject; FullScreen: WordBool) of object;
  TInternetExplorerOnTheaterMode = procedure(Sender: TObject; TheaterMode: WordBool) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TInternetExplorer
// Help String      : Internet Explorer Application.
// Default Interface: IWebBrowser2
// Def. Intf. DISP? : No
// Event   Interface: DWebBrowserEvents2
// TypeFlags        : (2) CanCreate
// *********************************************************************//



  TInternetExplorer = class(TOleServer)
  private
    FOnStatusTextChange: TInternetExplorerStatusTextChange;
    FOnProgressChange: TInternetExplorerProgressChange;
    FOnCommandStateChange: TInternetExplorerCommandStateChange;
    FOnDownloadBegin: TNotifyEvent;
    FOnDownloadComplete: TNotifyEvent;
    FOnTitleChange: TInternetExplorerTitleChange;
    FOnPropertyChange: TInternetExplorerPropertyChange;
    FOnBeforeNavigate2: TInternetExplorerBeforeNavigate2;
    FOnNewWindow2: TInternetExplorerNewWindow2;
    FOnNavigateComplete2: TInternetExplorerNavigateComplete2;
    FOnDocumentComplete: TInternetExplorerDocumentComplete;
    FOnQuit: TNotifyEvent;
    FOnVisible: TInternetExplorerOnVisible;
    FOnToolBar: TInternetExplorerOnToolBar;
    FOnMenuBar: TInternetExplorerOnMenuBar;
    FOnStatusBar: TInternetExplorerOnStatusBar;
    FOnFullScreen: TInternetExplorerOnFullScreen;
    FOnTheaterMode: TInternetExplorerOnTheaterMode;
    FIntf:        IWebBrowser2;
    function  GetDefaultInterface: IWebBrowser2;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_Application: IDispatch;
    function  Get_Parent: IDispatch;
    function  Get_Container: IDispatch;
    function  Get_Document: IDispatch;
    function  Get_TopLevelContainer: WordBool;
    function  Get_Type_: WideString;
    function  Get_Left: Integer;
    procedure Set_Left(pl: Integer);
    function  Get_Top: Integer;
    procedure Set_Top(pl: Integer);
    function  Get_Width: Integer;
    procedure Set_Width(pl: Integer);
    function  Get_Height: Integer;
    procedure Set_Height(pl: Integer);
    function  Get_LocationName: WideString;
    function  Get_LocationURL: WideString;
    function  Get_Busy: WordBool;
    function  Get_Name: WideString;
    function  Get_HWND: Integer;
    function  Get_FullName: WideString;
    function  Get_Path: WideString;
    function  Get_Visible: WordBool;
    procedure Set_Visible(pBool: WordBool);
    function  Get_StatusBar: WordBool;
    procedure Set_StatusBar(pBool: WordBool);
    function  Get_StatusText: WideString;
    procedure Set_StatusText(const StatusText: WideString);
    function  Get_ToolBar: SYSINT;
    procedure Set_ToolBar(Value: SYSINT);
    function  Get_MenuBar: WordBool;
    procedure Set_MenuBar(Value: WordBool);
    function  Get_FullScreen: WordBool;
    procedure Set_FullScreen(pbFullScreen: WordBool);
    function  Get_ReadyState: tagREADYSTATE;
    function  Get_Offline: WordBool;
    procedure Set_Offline(pbOffline: WordBool);
    function  Get_Silent: WordBool;
    procedure Set_Silent(pbSilent: WordBool);
    function  Get_RegisterAsBrowser: WordBool;
    procedure Set_RegisterAsBrowser(pbRegister: WordBool);
    function  Get_RegisterAsDropTarget: WordBool;
    procedure Set_RegisterAsDropTarget(pbRegister: WordBool);
    function  Get_TheaterMode: WordBool;
    procedure Set_TheaterMode(pbRegister: WordBool);
    function  Get_AddressBar: WordBool;
    procedure Set_AddressBar(Value: WordBool);
    function  Get_Resizable: WordBool;
    procedure Set_Resizable(Value: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWebBrowser2);
    procedure Disconnect; override;
    procedure GoBack;
    procedure GoForward;
    procedure GoHome;
    procedure GoSearch;

    procedure Navigate(const URL: WideString); {$ifdef bDelphi5} overload;
    procedure Navigate(const URL: WideString; var Flags: OleVariant); overload;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant); overload;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant; var PostData: OleVariant); overload;
    procedure Navigate(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant;
      var PostData: OleVariant; var Headers: OleVariant); overload; {$endif bDelphi5}

    procedure Refresh;
    procedure Refresh2; {$ifdef bDelphi5} overload;
    procedure Refresh2(var Level: OleVariant); overload; {$endif bDelphi5}
    procedure Stop;
    procedure Quit;
    procedure ClientToWindow(var pcx: SYSINT; var pcy: SYSINT);
    procedure PutProperty(const Property_: WideString; vtValue: OleVariant);
    function  GetProperty(const Property_: WideString): OleVariant;

    procedure Navigate2(var URL: OleVariant); {$ifdef bDelphi5} overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant); overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant); overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant; var PostData: OleVariant); overload;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant;
      var PostData: OleVariant; var Headers: OleVariant); overload; {$endif bDelphi5}

    function  QueryStatusWB(cmdID: OLECMDID): OLECMDF;

    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT); {$ifdef bDelphi5} overload;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant); overload;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant; var pvaOut: OleVariant); overload; {$endif bDelphi5}

    procedure ShowBrowserBar(var pvaClsid: OleVariant); {$ifdef bDelphi5} overload;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant); overload;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant; var pvarSize: OleVariant); overload; {$endif bDelphi5}

    property  DefaultInterface: IWebBrowser2 read GetDefaultInterface;
    property Application: IDispatch read Get_Application;
    property Parent: IDispatch read Get_Parent;
    property Container: IDispatch read Get_Container;
    property Document: IDispatch read Get_Document;
    property TopLevelContainer: WordBool read Get_TopLevelContainer;
    property Type_: WideString read Get_Type_;
    property LocationName: WideString read Get_LocationName;
    property LocationURL: WideString read Get_LocationURL;
    property Busy: WordBool read Get_Busy;
    property Name: WideString read Get_Name;
    property HWND: Integer read Get_HWND;
    property FullName: WideString read Get_FullName;
    property Path: WideString read Get_Path;
    property ReadyState: tagREADYSTATE read Get_ReadyState;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property StatusBar: WordBool read Get_StatusBar write Set_StatusBar;
    property StatusText: WideString read Get_StatusText write Set_StatusText;
    property ToolBar: SYSINT read Get_ToolBar write Set_ToolBar;
    property MenuBar: WordBool read Get_MenuBar write Set_MenuBar;
    property FullScreen: WordBool read Get_FullScreen write Set_FullScreen;
    property Offline: WordBool read Get_Offline write Set_Offline;
    property Silent: WordBool read Get_Silent write Set_Silent;
    property RegisterAsBrowser: WordBool read Get_RegisterAsBrowser write Set_RegisterAsBrowser;
    property RegisterAsDropTarget: WordBool read Get_RegisterAsDropTarget write Set_RegisterAsDropTarget;
    property TheaterMode: WordBool read Get_TheaterMode write Set_TheaterMode;
    property AddressBar: WordBool read Get_AddressBar write Set_AddressBar;
    property Resizable: WordBool read Get_Resizable write Set_Resizable;
  published



    property OnStatusTextChange: TInternetExplorerStatusTextChange read FOnStatusTextChange write FOnStatusTextChange;
    property OnProgressChange: TInternetExplorerProgressChange read FOnProgressChange write FOnProgressChange;
    property OnCommandStateChange: TInternetExplorerCommandStateChange read FOnCommandStateChange write FOnCommandStateChange;
    property OnDownloadBegin: TNotifyEvent read FOnDownloadBegin write FOnDownloadBegin;
    property OnDownloadComplete: TNotifyEvent read FOnDownloadComplete write FOnDownloadComplete;
    property OnTitleChange: TInternetExplorerTitleChange read FOnTitleChange write FOnTitleChange;
    property OnPropertyChange: TInternetExplorerPropertyChange read FOnPropertyChange write FOnPropertyChange;
    property OnBeforeNavigate2: TInternetExplorerBeforeNavigate2 read FOnBeforeNavigate2 write FOnBeforeNavigate2;
    property OnNewWindow2: TInternetExplorerNewWindow2 read FOnNewWindow2 write FOnNewWindow2;
    property OnNavigateComplete2: TInternetExplorerNavigateComplete2 read FOnNavigateComplete2 write FOnNavigateComplete2;
    property OnDocumentComplete: TInternetExplorerDocumentComplete read FOnDocumentComplete write FOnDocumentComplete;
    property OnQuit: TNotifyEvent read FOnQuit write FOnQuit;
    property OnVisible: TInternetExplorerOnVisible read FOnVisible write FOnVisible;
    property OnToolBar: TInternetExplorerOnToolBar read FOnToolBar write FOnToolBar;
    property OnMenuBar: TInternetExplorerOnMenuBar read FOnMenuBar write FOnMenuBar;
    property OnStatusBar: TInternetExplorerOnStatusBar read FOnStatusBar write FOnStatusBar;
    property OnFullScreen: TInternetExplorerOnFullScreen read FOnFullScreen write FOnFullScreen;
    property OnTheaterMode: TInternetExplorerOnTheaterMode read FOnTheaterMode write FOnTheaterMode;
  end;


// *********************************************************************//
// The Class CoShellBrowserWindow provides a Create and CreateRemote method to
// create instances of the default interface IWebBrowser2 exposed by
// the CoClass ShellBrowserWindow. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoShellBrowserWindow = class
    class function Create: IWebBrowser2;
    class function CreateRemote(const MachineName: string): IWebBrowser2;
  end;

// *********************************************************************//
// The Class CoShellWindows provides a Create and CreateRemote method to
// create instances of the default interface IShellWindows exposed by
// the CoClass ShellWindows. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoShellWindows = class
    class function Create: IShellWindows;
    class function CreateRemote(const MachineName: string): IShellWindows;
  end;

  TShellWindowsWindowRegistered = procedure(Sender: TObject; lCookie: Integer) of object;
  TShellWindowsWindowRevoked = procedure(Sender: TObject; lCookie: Integer) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TShellWindows
// Help String      : ShellDispatch Load in Shell Context
// Default Interface: IShellWindows
// Def. Intf. DISP? : No
// Event   Interface: DShellWindowsEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//



  TShellWindows = class(TOleServer)
  private
    FOnWindowRegistered: TShellWindowsWindowRegistered;
    FOnWindowRevoked: TShellWindowsWindowRevoked;
    FIntf:        IShellWindows;




    function      GetDefaultInterface: IShellWindows;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IShellWindows);
    procedure Disconnect; override;
    function  Item: IDispatch; {$ifdef bDelphi5} overload;
    function  Item(index: OleVariant): IDispatch; overload; {$endif bDelphi5}
    function  _NewEnum: IUnknown;
    procedure Register(const pid: IDispatch; HWND: Integer; swClass: SYSINT; out plCookie: Integer);
    procedure RegisterPending(lThreadId: Integer; var pvarloc: OleVariant; 
                              var pvarlocRoot: OleVariant; swClass: SYSINT; out plCookie: Integer);
    procedure Revoke(lCookie: Integer);
    procedure OnNavigate(lCookie: Integer; var pvarloc: OleVariant);
    procedure OnActivated(lCookie: Integer; fActive: WordBool);
    function  FindWindow(var pvarloc: OleVariant; var pvarlocRoot: OleVariant; swClass: SYSINT; 
                         out pHWND: Integer; swfwOptions: SYSINT): IDispatch;
    procedure OnCreated(lCookie: Integer; const punk: IUnknown);
    procedure ProcessAttachDetach(fAttach: WordBool);
    property  DefaultInterface: IShellWindows read GetDefaultInterface;
    property Count: Integer read Get_Count;
  published



    property OnWindowRegistered: TShellWindowsWindowRegistered read FOnWindowRegistered write FOnWindowRegistered;
    property OnWindowRevoked: TShellWindowsWindowRevoked read FOnWindowRevoked write FOnWindowRevoked;
  end;

// *********************************************************************//
// The Class CoShellUIHelper provides a Create and CreateRemote method to
// create instances of the default interface IShellUIHelper exposed by
// the CoClass ShellUIHelper. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoShellUIHelper = class
    class function Create: IShellUIHelper;
    class function CreateRemote(const MachineName: string): IShellUIHelper;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TShellUIHelper
// Help String      : 
// Default Interface: IShellUIHelper
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//



  TShellUIHelper = class(TOleServer)
  private
    FIntf:        IShellUIHelper;




    function      GetDefaultInterface: IShellUIHelper;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IShellUIHelper);
    procedure Disconnect; override;
    procedure ResetFirstBootMode;
    procedure ResetSafeMode;
    procedure RefreshOfflineDesktop;
    procedure AddFavorite(const URL: WideString); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AddFavorite{$else}AddFavorite_1{$endif}(const URL: WideString; var Title: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure AddChannel(const URL: WideString);

    procedure AddDesktopComponent(const URL: WideString; const Type_: WideString); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_1{$endif}(const URL: WideString; const Type_: WideString; var Left: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_2{$endif}(const URL: WideString; const Type_: WideString; var Left: OleVariant; var Top: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_3{$endif}(const URL: WideString; const Type_: WideString; var Left: OleVariant; var Top: OleVariant; var Width: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_4{$endif}(const URL: WideString; const Type_: WideString; var Left: OleVariant; var Top: OleVariant; var Width: OleVariant; var Height: OleVariant); {$ifdef bDelphi5}overload;{$endif}

    function  IsSubscribed(const URL: WideString): WordBool;
    procedure NavigateAndFind(const URL: WideString; const strQuery: WideString; var varTargetFrame: OleVariant);
    procedure ImportExportFavorites(fImport: WordBool; const strImpExpPath: WideString);
    procedure AutoCompleteSaveForm; {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AutoCompleteSaveForm{$else}AutoCompleteSaveForm_1{$endif}(var Form: OleVariant); {$ifdef bDelphi5}overload;{$endif}

    procedure AutoScan(const strSearch: WideString; const strFailureUrl: WideString); {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AutoScan{$else}AutoScan_1{$endif}(const strSearch: WideString; const strFailureUrl: WideString; var pvarTargetFrame: OleVariant); {$ifdef bDelphi5}overload;{$endif}

    procedure AutoCompleteAttach; {$ifdef bDelphi5}overload;{$endif}
    procedure {$ifdef bDelphi5}AutoCompleteAttach{$else}AutoCompleteAttach_1{$endif}(var Reserved: OleVariant); {$ifdef bDelphi5}overload;{$endif}
    
    function  ShowBrowserUI(const bstrName: WideString; var pvarIn: OleVariant): OleVariant;
    property  DefaultInterface: IShellUIHelper read GetDefaultInterface;
  published
  end;

// *********************************************************************//
// The Class CoShellFavoritesNameSpace provides a Create and CreateRemote method to
// create instances of the default interface IShellFavoritesNameSpace exposed by
// the CoClass ShellFavoritesNameSpace. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoShellFavoritesNameSpace = class
    class function Create: IShellFavoritesNameSpace;
    class function CreateRemote(const MachineName: string): IShellFavoritesNameSpace;
  end;

  TShellFavoritesNameSpaceFavoritesSelectionChange = procedure(Sender: TObject; cItems: Integer; 
                                                                                hItem: Integer; 
                                                                                var strName: OleVariant;
                                                                                var strUrl: OleVariant;
                                                                                cVisits: Integer; 
                                                                                var strDate: OleVariant;
                                                                                fAvailableOffline: Integer) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TShellFavoritesNameSpace
// Help String      : 
// Default Interface: IShellFavoritesNameSpace
// Def. Intf. DISP? : No
// Event   Interface: _ShellFavoritesNameSpaceEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//



  TShellFavoritesNameSpace = class(TOleServer)
  private
    FOnFavoritesSelectionChange: TShellFavoritesNameSpaceFavoritesSelectionChange;
    FIntf:        IShellFavoritesNameSpace;




    function      GetDefaultInterface: IShellFavoritesNameSpace;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_FOfflinePackInstalled: WordBool;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IShellFavoritesNameSpace);
    procedure Disconnect; override;
    procedure MoveSelectionUp;
    procedure MoveSelectionDown;
    procedure ResetSort;
    procedure NewFolder;
    procedure Synchronize;
    procedure Import;
    procedure Export;
    procedure InvokeContextMenuCommand(const strCommand: WideString);
    procedure MoveSelectionTo;
    function  CreateSubscriptionForSelection: WordBool;
    function  DeleteSubscriptionForSelection: WordBool;
    procedure SetRoot(const bstrFullPath: WideString);
    property  DefaultInterface: IShellFavoritesNameSpace read GetDefaultInterface;
    property FOfflinePackInstalled: WordBool read Get_FOfflinePackInstalled;

  published
    property OnFavoritesSelectionChange: TShellFavoritesNameSpaceFavoritesSelectionChange read FOnFavoritesSelectionChange write FOnFavoritesSelectionChange;
  end;


// *********************************************************************//
// The Class CoCScriptErrorList provides a Create and CreateRemote method to          
// create instances of the default interface IScriptErrorList exposed by              
// the CoClass CScriptErrorList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCScriptErrorList = class
    class function Create: IScriptErrorList;
    class function CreateRemote(const MachineName: string): IScriptErrorList;
  end;

// *********************************************************************//
// The Class CoSearchAssistantOC provides a Create and CreateRemote method to          
// create instances of the default interface ISearchAssistantOC exposed by              
// the CoClass SearchAssistantOC. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSearchAssistantOC = class
    class function Create: ISearchAssistantOC;
    class function CreateRemote(const MachineName: string): ISearchAssistantOC;
  end;
*)

implementation

//uses ComObj;

(*
procedure TWebBrowser_V1.InitControlData;
const
  CEventDispIDs: array [0..16] of DWORD = (
    $00000064, $00000065, $00000066, $0000006C, $00000068, $00000069,
    $0000006A, $0000006B, $00000071, $000000C8, $000000C9, $000000CC,
    $00000067, $0000006D, $0000006E, $0000006F, $00000070);
  CControlData: TControlData2 = (
    ClassID: '{EAB22AC3-30C1-11CF-A7EB-0000C05BAE0B}';
    EventIID: '{EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B}';
    EventCount: 17;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil {HR:$80040154};
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnBeforeNavigate) - Cardinal(Self);
end;

procedure TWebBrowser_V1.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IWebBrowser;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TWebBrowser_V1.GetControlInterface: IWebBrowser;
begin
  CreateControl;
  Result := FIntf;
end;

function  TWebBrowser_V1.Get_Application: IDispatch;
begin
  Result := DefaultInterface.Get_Application;
end;

function  TWebBrowser_V1.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Get_Parent;
end;

function  TWebBrowser_V1.Get_Container: IDispatch;
begin
  Result := DefaultInterface.Get_Container;
end;

function  TWebBrowser_V1.Get_Document: IDispatch;
begin
  Result := DefaultInterface.Get_Document;
end;

procedure TWebBrowser_V1.GoBack;
begin
  DefaultInterface.GoBack;
end;

procedure TWebBrowser_V1.GoForward;
begin
  DefaultInterface.GoForward;
end;

procedure TWebBrowser_V1.GoHome;
begin
  DefaultInterface.GoHome;
end;

procedure TWebBrowser_V1.GoSearch;
begin
  DefaultInterface.GoSearch;
end;

procedure TWebBrowser_V1.Navigate(const URL: WideString);
begin
  DefaultInterface.Navigate(URL, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TWebBrowser_V1.{$ifdef bDelphi5}Navigate{$else}Navigate_1{$endif}(const URL: WideString; var Flags: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TWebBrowser_V1.{$ifdef bDelphi5}Navigate{$else}Navigate_2{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, EmptyParam, EmptyParam);
end;

procedure TWebBrowser_V1.{$ifdef bDelphi5}Navigate{$else}Navigate_3{$endif}(const URL: WideString; var Flags: OleVariant;
  var TargetFrameName: OleVariant; var PostData: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, PostData, EmptyParam);
end;

procedure TWebBrowser_V1.{$ifdef bDelphi5}Navigate{$else}Navigate_4{$endif}(const URL: WideString; var Flags: OleVariant;
  var TargetFrameName: OleVariant; var PostData: OleVariant; var Headers: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, PostData, Headers);
end;

procedure TWebBrowser_V1.Refresh;
begin
  DefaultInterface.Refresh;
end;

procedure TWebBrowser_V1.Refresh2;
begin
  DefaultInterface.Refresh2(EmptyParam);
end;

procedure TWebBrowser_V1.{$ifdef bDelphi5}Refresh2{$else}Refresh2_1{$endif}(var Level: OleVariant);
begin
  DefaultInterface.Refresh2(Level);
end;

procedure TWebBrowser_V1.Stop;
begin
  DefaultInterface.Stop;
end;

procedure TWebBrowser.InitControlData;
const
  CEventDispIDs: array [0..17] of DWORD = (
    $00000066, $0000006C, $00000069, $0000006A, $00000068, $00000071,
    $00000070, $000000FA, $000000FB, $000000FC, $00000103, $000000FD,
    $000000FE, $000000FF, $00000100, $00000101, $00000102, $00000104);
  CControlData: TControlData2 = (
    ClassID: '{8856F961-340A-11D0-A96B-00C04FD705A2}';
    EventIID: '{34A715A0-6587-11D0-924A-0020AFC7AC4D}';
    EventCount: 18;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil {HR:$80040154};
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnStatusTextChange) - Cardinal(Self);
end;

procedure TWebBrowser.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IWebBrowser2;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TWebBrowser.GetControlInterface: IWebBrowser2;
begin
  CreateControl;
  Result := FIntf;
end;

function  TWebBrowser.Get_Application: IDispatch;
begin
  Result := DefaultInterface.Get_Application;
end;

function  TWebBrowser.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Get_Parent;
end;

function  TWebBrowser.Get_Container: IDispatch;
begin
  Result := DefaultInterface.Get_Container;
end;

function  TWebBrowser.Get_Document: IDispatch;
begin
  Result := DefaultInterface.Get_Document;
end;

procedure TWebBrowser.GoBack;
begin
  DefaultInterface.GoBack;
end;

procedure TWebBrowser.GoForward;
begin
  DefaultInterface.GoForward;
end;

procedure TWebBrowser.GoHome;
begin
  DefaultInterface.GoHome;
end;

procedure TWebBrowser.GoSearch;
begin
  DefaultInterface.GoSearch;
end;

procedure TWebBrowser.Navigate(const URL: WideString);
begin
  DefaultInterface.Navigate(URL, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TWebBrowser.{$ifdef bDelphi5}Navigate{$else}Navigate_1{$endif}(const URL: WideString; var Flags: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TWebBrowser.{$ifdef bDelphi5}Navigate{$else}Navigate_2{$endif}(const URL: WideString; var Flags: OleVariant; var TargetFrameName: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, EmptyParam, EmptyParam);
end;

procedure TWebBrowser.{$ifdef bDelphi5}Navigate{$else}Navigate_3{$endif}(const URL: WideString; var Flags: OleVariant;
  var TargetFrameName: OleVariant; var PostData: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, PostData, EmptyParam);
end;

procedure TWebBrowser.{$ifdef bDelphi5}Navigate{$else}Navigate_4{$endif}(const URL: WideString; var Flags: OleVariant;
  var TargetFrameName: OleVariant; var PostData: OleVariant; var Headers: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, PostData, Headers);
end;

procedure TWebBrowser.Refresh;
begin
  DefaultInterface.Refresh;
end;

procedure TWebBrowser.Refresh2;
begin
  DefaultInterface.Refresh2(EmptyParam);
end;

procedure TWebBrowser.{$ifdef bDelphi5}Refresh2{$else}Refresh2_1{$endif}(var Level: OleVariant);
begin
  DefaultInterface.Refresh2(Level);
end;

procedure TWebBrowser.Stop;
begin
  DefaultInterface.Stop;
end;

procedure TWebBrowser.Quit;
begin
  DefaultInterface.Quit;
end;

procedure TWebBrowser.ClientToWindow(var pcx: SYSINT; var pcy: SYSINT);
begin
  DefaultInterface.ClientToWindow(pcx, pcy);
end;

procedure TWebBrowser.PutProperty(const Property_: WideString; vtValue: OleVariant);
begin
  DefaultInterface.PutProperty(Property_, vtValue);
end;

function  TWebBrowser.GetProperty(const Property_: WideString): OleVariant;
begin
  Result := DefaultInterface.GetProperty(Property_);
end;

procedure TWebBrowser.Navigate2(var URL: OleVariant);
begin
  DefaultInterface.Navigate2(URL, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

{$ifdef bDelphi5}
procedure TWebBrowser.Navigate2(var URL: OleVariant; var Flags: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TWebBrowser.Navigate2(var URL: OleVariant; var Flags: OleVariant;
                                var TargetFrameName: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, TargetFrameName, EmptyParam, EmptyParam);
end;

procedure TWebBrowser.Navigate2(var URL: OleVariant; var Flags: OleVariant;
                                var TargetFrameName: OleVariant; var PostData: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, TargetFrameName, PostData, EmptyParam);
end;

procedure TWebBrowser.Navigate2(var URL: OleVariant; var Flags: OleVariant;
                                var TargetFrameName: OleVariant; var PostData: OleVariant;
                                var Headers: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, TargetFrameName, PostData, Headers);
end;
{$endif bDelphi5}

function  TWebBrowser.QueryStatusWB(cmdID: OLECMDID): OLECMDF;
begin
  Result := DefaultInterface.QueryStatusWB(cmdID);
end;

procedure TWebBrowser.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT);
var
  vEmptyParamIn, vEmptyParamOut :OleVariant;
begin
  vEmptyParamIn  := EmptyParam;
  vEmptyParamOut := EmptyParam;
  DefaultInterface.ExecWB(cmdID, cmdexecopt, vEmptyParamIn, vEmptyParamOut);
end;

{$ifdef bDelphi5}
procedure TWebBrowser.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant);
var
  vEmptyParamOut :OleVariant;
begin
  vEmptyParamOut := EmptyParam;
  DefaultInterface.ExecWB(cmdID, cmdexecopt, pvaIn, vEmptyParamOut);
end;

procedure TWebBrowser.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant;
                             var pvaOut: OleVariant);
begin
  DefaultInterface.ExecWB(cmdID, cmdexecopt, pvaIn, pvaOut);
end;
{$endif bDelphi5}

procedure TWebBrowser.ShowBrowserBar(var pvaClsid: OleVariant);
begin
  DefaultInterface.ShowBrowserBar(pvaClsid, EmptyParam, EmptyParam);
end;

{$ifdef bDelphi5}
procedure TWebBrowser.ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant);
begin
  DefaultInterface.ShowBrowserBar(pvaClsid, pvarShow, EmptyParam);
end;

procedure TWebBrowser.ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant;
                                     var pvarSize: OleVariant);
begin
  DefaultInterface.ShowBrowserBar(pvaClsid, pvarShow, pvarSize);
end;
{$endif bDelphi5}

class function CoInternetExplorer.Create: IWebBrowser2;
begin
  Result := CreateComObject(CLASS_InternetExplorer) as IWebBrowser2;
end;

class function CoInternetExplorer.CreateRemote(const MachineName: string): IWebBrowser2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_InternetExplorer) as IWebBrowser2;
end;

procedure TInternetExplorer.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0002DF01-0000-0000-C000-000000000046}';
    IntfIID:   '{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}';
    EventIID:  '{34A715A0-6587-11D0-924A-0020AFC7AC4D}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TInternetExplorer.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IWebBrowser2;
  end;
end;

procedure TInternetExplorer.ConnectTo(svrIntf: IWebBrowser2);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TInternetExplorer.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TInternetExplorer.GetDefaultInterface: IWebBrowser2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TInternetExplorer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);



end;

destructor TInternetExplorer.Destroy;
begin
  inherited Destroy;
end;
*)

(*
procedure TInternetExplorer.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   102: if Assigned(FOnStatusTextChange) then
            FOnStatusTextChange(Self, Params[0];
   108: if Assigned(FOnProgressChange) then
            FOnProgressChange(Self, Params[0], Params[1]);
   105: if Assigned(FOnCommandStateChange) then
            FOnCommandStateChange(Self, Params[0], Params[1]);
   106: if Assigned(FOnDownloadBegin) then
            FOnDownloadBegin(Self);
   104: if Assigned(FOnDownloadComplete) then
            FOnDownloadComplete(Self);
   113: if Assigned(FOnTitleChange) then
            FOnTitleChange(Self, Params[0]);
   112: if Assigned(FOnPropertyChange) then
            FOnPropertyChange(Self, Params[0]);
   250: if Assigned(FOnBeforeNavigate2) then
            FOnBeforeNavigate2(Self, Params[0], Params[1], Params[2], Params[3], Params[4], Params[5], Params[6]);
   251: if Assigned(FOnNewWindow2) then
            FOnNewWindow2(Self, Params[0], Params[1]);
   252: if Assigned(FOnNavigateComplete2) then
            FOnNavigateComplete2(Self, Params[0], Params[1]);
   259: if Assigned(FOnDocumentComplete) then
            FOnDocumentComplete(Self, Params[0], Params[1]);
   253: if Assigned(FOnQuit) then
            FOnQuit(Self);
   254: if Assigned(FOnVisible) then
            FOnVisible(Self, Params[0]);
   255: if Assigned(FOnToolBar) then
            FOnToolBar(Self, Params[0]);
   256: if Assigned(FOnMenuBar) then
            FOnMenuBar(Self, Params[0]);
   257: if Assigned(FOnStatusBar) then
            FOnStatusBar(Self, Params[0]);
   258: if Assigned(FOnFullScreen) then
            FOnFullScreen(Self, Params[0]);
   260: if Assigned(FOnTheaterMode) then
            FOnTheaterMode(Self, Params[0]);
  end; {case DispID}
end;

function  TInternetExplorer.Get_Application: IDispatch;
begin
  Result := DefaultInterface.Get_Application;
end;

function  TInternetExplorer.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Get_Parent;
end;

function  TInternetExplorer.Get_Container: IDispatch;
begin
  Result := DefaultInterface.Get_Container;
end;

function  TInternetExplorer.Get_Document: IDispatch;
begin
  Result := DefaultInterface.Get_Document;
end;

function  TInternetExplorer.Get_TopLevelContainer: WordBool;
begin
  Result := DefaultInterface.Get_TopLevelContainer;
end;

function  TInternetExplorer.Get_Type_: WideString;
begin
  Result := DefaultInterface.Get_Type_;
end;

function  TInternetExplorer.Get_Left: Integer;
begin
  Result := DefaultInterface.Get_Left;
end;

procedure TInternetExplorer.Set_Left(pl: Integer);
begin
  DefaultInterface.Set_Left(pl);
end;

function  TInternetExplorer.Get_Top: Integer;
begin
  Result := DefaultInterface.Get_Top;
end;

procedure TInternetExplorer.Set_Top(pl: Integer);
begin
  DefaultInterface.Set_Top(pl);
end;

function  TInternetExplorer.Get_Width: Integer;
begin
  Result := DefaultInterface.Get_Width;
end;

procedure TInternetExplorer.Set_Width(pl: Integer);
begin
  DefaultInterface.Set_Width(pl);
end;

function  TInternetExplorer.Get_Height: Integer;
begin
  Result := DefaultInterface.Get_Height;
end;

procedure TInternetExplorer.Set_Height(pl: Integer);
begin
  DefaultInterface.Set_Height(pl);
end;

function  TInternetExplorer.Get_LocationName: WideString;
begin
  Result := DefaultInterface.Get_LocationName;
end;

function  TInternetExplorer.Get_LocationURL: WideString;
begin
  Result := DefaultInterface.Get_LocationURL;
end;

function  TInternetExplorer.Get_Busy: WordBool;
begin
  Result := DefaultInterface.Get_Busy;
end;

function  TInternetExplorer.Get_Name: WideString;
begin
  Result := DefaultInterface.Get_Name;
end;

function  TInternetExplorer.Get_HWND: Integer;
begin
  Result := DefaultInterface.Get_HWND;
end;

function  TInternetExplorer.Get_FullName: WideString;
begin
  Result := DefaultInterface.Get_FullName;
end;

function  TInternetExplorer.Get_Path: WideString;
begin
  Result := DefaultInterface.Get_Path;
end;

function  TInternetExplorer.Get_Visible: WordBool;
begin
  Result := DefaultInterface.Get_Visible;
end;

procedure TInternetExplorer.Set_Visible(pBool: WordBool);
begin
  DefaultInterface.Set_Visible(pBool);
end;

function  TInternetExplorer.Get_StatusBar: WordBool;
begin
  Result := DefaultInterface.Get_StatusBar;
end;

procedure TInternetExplorer.Set_StatusBar(pBool: WordBool);
begin
  DefaultInterface.Set_StatusBar(pBool);
end;

function  TInternetExplorer.Get_StatusText: WideString;
begin
  Result := DefaultInterface.Get_StatusText;
end;

procedure TInternetExplorer.Set_StatusText(const StatusText: WideString);
begin
  DefaultInterface.Set_StatusText(StatusText);
end;

function  TInternetExplorer.Get_ToolBar: SYSINT;
begin
  Result := DefaultInterface.Get_ToolBar;
end;

procedure TInternetExplorer.Set_ToolBar(Value: SYSINT);
begin
  DefaultInterface.Set_ToolBar(Value);
end;

function  TInternetExplorer.Get_MenuBar: WordBool;
begin
  Result := DefaultInterface.Get_MenuBar;
end;

procedure TInternetExplorer.Set_MenuBar(Value: WordBool);
begin
  DefaultInterface.Set_MenuBar(Value);
end;

function  TInternetExplorer.Get_FullScreen: WordBool;
begin
  Result := DefaultInterface.Get_FullScreen;
end;

procedure TInternetExplorer.Set_FullScreen(pbFullScreen: WordBool);
begin
  DefaultInterface.Set_FullScreen(pbFullScreen);
end;

function  TInternetExplorer.Get_ReadyState: tagREADYSTATE;
begin
  Result := DefaultInterface.Get_ReadyState;
end;

function  TInternetExplorer.Get_Offline: WordBool;
begin
  Result := DefaultInterface.Get_Offline;
end;

procedure TInternetExplorer.Set_Offline(pbOffline: WordBool);
begin
  DefaultInterface.Set_Offline(pbOffline);
end;

function  TInternetExplorer.Get_Silent: WordBool;
begin
  Result := DefaultInterface.Get_Silent;
end;

procedure TInternetExplorer.Set_Silent(pbSilent: WordBool);
begin
  DefaultInterface.Set_Silent(pbSilent);
end;

function  TInternetExplorer.Get_RegisterAsBrowser: WordBool;
begin
  Result := DefaultInterface.Get_RegisterAsBrowser;
end;

procedure TInternetExplorer.Set_RegisterAsBrowser(pbRegister: WordBool);
begin
  DefaultInterface.Set_RegisterAsBrowser(pbRegister);
end;

function  TInternetExplorer.Get_RegisterAsDropTarget: WordBool;
begin
  Result := DefaultInterface.Get_RegisterAsDropTarget;
end;

procedure TInternetExplorer.Set_RegisterAsDropTarget(pbRegister: WordBool);
begin
  DefaultInterface.Set_RegisterAsDropTarget(pbRegister);
end;

function  TInternetExplorer.Get_TheaterMode: WordBool;
begin
  Result := DefaultInterface.Get_TheaterMode;
end;

procedure TInternetExplorer.Set_TheaterMode(pbRegister: WordBool);
begin
  DefaultInterface.Set_TheaterMode(pbRegister);
end;

function  TInternetExplorer.Get_AddressBar: WordBool;
begin
  Result := DefaultInterface.Get_AddressBar;
end;

procedure TInternetExplorer.Set_AddressBar(Value: WordBool);
begin
  DefaultInterface.Set_AddressBar(Value);
end;

function  TInternetExplorer.Get_Resizable: WordBool;
begin
  Result := DefaultInterface.Get_Resizable;
end;

procedure TInternetExplorer.Set_Resizable(Value: WordBool);
begin
  DefaultInterface.Set_Resizable(Value);
end;

procedure TInternetExplorer.GoBack;
begin
  DefaultInterface.GoBack;
end;

procedure TInternetExplorer.GoForward;
begin
  DefaultInterface.GoForward;
end;

procedure TInternetExplorer.GoHome;
begin
  DefaultInterface.GoHome;
end;

procedure TInternetExplorer.GoSearch;
begin
  DefaultInterface.GoSearch;
end;

procedure TInternetExplorer.Navigate(const URL: WideString);
begin
  DefaultInterface.Navigate(URL, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

{$ifdef bDelphi5}
procedure TInternetExplorer.Navigate(const URL: WideString; var Flags: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TInternetExplorer.Navigate(const URL: WideString; var Flags: OleVariant; 
                                     var TargetFrameName: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, EmptyParam, EmptyParam);
end;

procedure TInternetExplorer.Navigate(const URL: WideString; var Flags: OleVariant; 
                                     var TargetFrameName: OleVariant; var PostData: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, PostData, EmptyParam);
end;

procedure TInternetExplorer.Navigate(const URL: WideString; var Flags: OleVariant; 
                                     var TargetFrameName: OleVariant; var PostData: OleVariant; 
                                     var Headers: OleVariant);
begin
  DefaultInterface.Navigate(URL, Flags, TargetFrameName, PostData, Headers);
end;
{$endif bDelphi5}

procedure TInternetExplorer.Refresh;
begin
  DefaultInterface.Refresh;
end;

procedure TInternetExplorer.Refresh2;
begin
  DefaultInterface.Refresh2(EmptyParam);
end;

{$ifdef bDelphi5}
procedure TInternetExplorer.Refresh2(var Level: OleVariant);
begin
  DefaultInterface.Refresh2(Level);
end;
{$endif bDelphi5}

procedure TInternetExplorer.Stop;
begin
  DefaultInterface.Stop;
end;

procedure TInternetExplorer.Quit;
begin
  DefaultInterface.Quit;
end;

procedure TInternetExplorer.ClientToWindow(var pcx: SYSINT; var pcy: SYSINT);
begin
  DefaultInterface.ClientToWindow(pcx, pcy);
end;

procedure TInternetExplorer.PutProperty(const Property_: WideString; vtValue: OleVariant);
begin
  DefaultInterface.PutProperty(Property_, vtValue);
end;

function  TInternetExplorer.GetProperty(const Property_: WideString): OleVariant;
begin
  Result := DefaultInterface.GetProperty(Property_);
end;

procedure TInternetExplorer.Navigate2(var URL: OleVariant);
begin
  DefaultInterface.Navigate2(URL, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

{$ifdef bDelphi5}
procedure TInternetExplorer.Navigate2(var URL: OleVariant; var Flags: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TInternetExplorer.Navigate2(var URL: OleVariant; var Flags: OleVariant; 
                                      var TargetFrameName: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, TargetFrameName, EmptyParam, EmptyParam);
end;

procedure TInternetExplorer.Navigate2(var URL: OleVariant; var Flags: OleVariant; 
                                      var TargetFrameName: OleVariant; var PostData: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, TargetFrameName, PostData, EmptyParam);
end;

procedure TInternetExplorer.Navigate2(var URL: OleVariant; var Flags: OleVariant; 
                                      var TargetFrameName: OleVariant; var PostData: OleVariant; 
                                      var Headers: OleVariant);
begin
  DefaultInterface.Navigate2(URL, Flags, TargetFrameName, PostData, Headers);
end;
{$endif bDelphi5}

function  TInternetExplorer.QueryStatusWB(cmdID: OLECMDID): OLECMDF;
begin
  Result := DefaultInterface.QueryStatusWB(cmdID);
end;

procedure TInternetExplorer.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT);
begin
  DefaultInterface.ExecWB(cmdID, cmdexecopt, EmptyParam, EmptyParam);
end;

{$ifdef bDelphi5}
procedure TInternetExplorer.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant);
begin
  DefaultInterface.ExecWB(cmdID, cmdexecopt, pvaIn, EmptyParam);
end;

procedure TInternetExplorer.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT;
                                   var pvaIn: OleVariant; var pvaOut: OleVariant);
begin
  DefaultInterface.ExecWB(cmdID, cmdexecopt, pvaIn, pvaOut);
end;
{$endif bDelphi5}

procedure TInternetExplorer.ShowBrowserBar(var pvaClsid: OleVariant);
begin
  DefaultInterface.ShowBrowserBar(pvaClsid, EmptyParam, EmptyParam);
end;

{$ifdef bDelphi5}
procedure TInternetExplorer.ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant);
begin
  DefaultInterface.ShowBrowserBar(pvaClsid, pvarShow, EmptyParam);
end;

procedure TInternetExplorer.ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant;
                                           var pvarSize: OleVariant);
begin
  DefaultInterface.ShowBrowserBar(pvaClsid, pvarShow, pvarSize);
end;
{$endif bDelphi5}

class function CoShellBrowserWindow.Create: IWebBrowser2;
begin
  Result := CreateComObject(CLASS_ShellBrowserWindow) as IWebBrowser2;
end;

class function CoShellBrowserWindow.CreateRemote(const MachineName: string): IWebBrowser2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ShellBrowserWindow) as IWebBrowser2;
end;

class function CoShellWindows.Create: IShellWindows;
begin
  Result := CreateComObject(CLASS_ShellWindows) as IShellWindows;
end;

class function CoShellWindows.CreateRemote(const MachineName: string): IShellWindows;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ShellWindows) as IShellWindows;
end;

procedure TShellWindows.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{9BA05972-F6A8-11CF-A442-00A0C90A8F39}';
    IntfIID:   '{85CB6900-4D95-11CF-960C-0080C7F4EE85}';
    EventIID:  '{FE4106E0-399A-11D0-A48C-00A0C90A8F39}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TShellWindows.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IShellWindows;
  end;
end;

procedure TShellWindows.ConnectTo(svrIntf: IShellWindows);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TShellWindows.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TShellWindows.GetDefaultInterface: IShellWindows;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TShellWindows.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);



end;

destructor TShellWindows.Destroy;
begin



  inherited Destroy;
end;








procedure TShellWindows.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   200: if Assigned(FOnWindowRegistered) then
            FOnWindowRegistered(Self, Params[0]);
   201: if Assigned(FOnWindowRevoked) then
            FOnWindowRevoked(Self, Params[0]);
  end; {case DispID}
end;

function  TShellWindows.Get_Count: Integer;
begin
  Result := DefaultInterface.Get_Count;
end;

function  TShellWindows.Item: IDispatch;
begin
  Result := DefaultInterface.Item(EmptyParam);
end;

{$ifdef bDelphi5}
function  TShellWindows.Item(index: OleVariant): IDispatch;
begin
  Result := DefaultInterface.Item(index);
end;
{$endif bDelphi5}

function  TShellWindows._NewEnum: IUnknown;
begin
  Result := DefaultInterface._NewEnum;
end;

procedure TShellWindows.Register(const pid: IDispatch; HWND: Integer; swClass: SYSINT; 
                                 out plCookie: Integer);
begin
  DefaultInterface.Register(pid, HWND, swClass, plCookie);
end;

procedure TShellWindows.RegisterPending(lThreadId: Integer; var pvarloc: OleVariant; 
                                        var pvarlocRoot: OleVariant; swClass: SYSINT; 
                                        out plCookie: Integer);
begin
  DefaultInterface.RegisterPending(lThreadId, pvarloc, pvarlocRoot, swClass, plCookie);
end;

procedure TShellWindows.Revoke(lCookie: Integer);
begin
  DefaultInterface.Revoke(lCookie);
end;

procedure TShellWindows.OnNavigate(lCookie: Integer; var pvarloc: OleVariant);
begin
  DefaultInterface.OnNavigate(lCookie, pvarloc);
end;

procedure TShellWindows.OnActivated(lCookie: Integer; fActive: WordBool);
begin
  DefaultInterface.OnActivated(lCookie, fActive);
end;

function  TShellWindows.FindWindow(var pvarloc: OleVariant; var pvarlocRoot: OleVariant; 
                                   swClass: SYSINT; out pHWND: Integer; swfwOptions: SYSINT): IDispatch;
begin
  Result := DefaultInterface.FindWindow(pvarloc, pvarlocRoot, swClass, pHWND, swfwOptions);
end;

procedure TShellWindows.OnCreated(lCookie: Integer; const punk: IUnknown);
begin
  DefaultInterface.OnCreated(lCookie, punk);
end;

procedure TShellWindows.ProcessAttachDetach(fAttach: WordBool);
begin
  DefaultInterface.ProcessAttachDetach(fAttach);
end;




















class function CoShellUIHelper.Create: IShellUIHelper;
begin
  Result := CreateComObject(CLASS_ShellUIHelper) as IShellUIHelper;
end;

class function CoShellUIHelper.CreateRemote(const MachineName: string): IShellUIHelper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ShellUIHelper) as IShellUIHelper;
end;

procedure TShellUIHelper.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{64AB4BB7-111E-11D1-8F79-00C04FC2FBE1}';
    IntfIID:   '{729FE2F8-1EA8-11D1-8F85-00C04FC2FBE1}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TShellUIHelper.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IShellUIHelper;
  end;
end;

procedure TShellUIHelper.ConnectTo(svrIntf: IShellUIHelper);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TShellUIHelper.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TShellUIHelper.GetDefaultInterface: IShellUIHelper;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TShellUIHelper.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);



end;

destructor TShellUIHelper.Destroy;
begin



  inherited Destroy;
end;








procedure TShellUIHelper.ResetFirstBootMode;
begin
  DefaultInterface.ResetFirstBootMode;
end;

procedure TShellUIHelper.ResetSafeMode;
begin
  DefaultInterface.ResetSafeMode;
end;

procedure TShellUIHelper.RefreshOfflineDesktop;
begin
  DefaultInterface.RefreshOfflineDesktop;
end;

procedure TShellUIHelper.AddFavorite(const URL: WideString);
begin
  DefaultInterface.AddFavorite(URL, EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AddFavorite{$else}AddFavorite_1{$endif}(const URL: WideString; var Title: OleVariant);
begin
  DefaultInterface.AddFavorite(URL, Title);
end;


procedure TShellUIHelper.AddChannel(const URL: WideString);
begin
  DefaultInterface.AddChannel(URL);
end;

procedure TShellUIHelper.AddDesktopComponent(const URL: WideString; const Type_: WideString);
begin
  DefaultInterface.AddDesktopComponent(URL, Type_, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;


procedure TShellUIHelper.{$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_1{$endif}
  (const URL: WideString; const Type_: WideString; var Left: OleVariant);
begin
  DefaultInterface.AddDesktopComponent(URL, Type_, Left, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_2{$endif}
  (const URL: WideString; const Type_: WideString; var Left: OleVariant; var Top: OleVariant);
begin
  DefaultInterface.AddDesktopComponent(URL, Type_, Left, Top, EmptyParam, EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_3{$endif}
  (const URL: WideString; const Type_: WideString; var Left: OleVariant; var Top: OleVariant; var Width: OleVariant);
begin
  DefaultInterface.AddDesktopComponent(URL, Type_, Left, Top, Width, EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AddDesktopComponent{$else}AddDesktopComponent_4{$endif}
  (const URL: WideString; const Type_: WideString; var Left: OleVariant; var Top: OleVariant; var Width: OleVariant; var Height: OleVariant);
begin
  DefaultInterface.AddDesktopComponent(URL, Type_, Left, Top, Width, Height);
end;


function  TShellUIHelper.IsSubscribed(const URL: WideString): WordBool;
begin
  Result := DefaultInterface.IsSubscribed(URL);
end;

procedure TShellUIHelper.NavigateAndFind(const URL: WideString; const strQuery: WideString; 
                                         var varTargetFrame: OleVariant);
begin
  DefaultInterface.NavigateAndFind(URL, strQuery, varTargetFrame);
end;

procedure TShellUIHelper.ImportExportFavorites(fImport: WordBool; const strImpExpPath: WideString);
begin
  DefaultInterface.ImportExportFavorites(fImport, strImpExpPath);
end;

procedure TShellUIHelper.AutoCompleteSaveForm;
begin
  DefaultInterface.AutoCompleteSaveForm(EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AutoCompleteSaveForm{$else}AutoCompleteSaveForm_1{$endif}
  (var Form: OleVariant);
begin
  DefaultInterface.AutoCompleteSaveForm(Form);
end;


procedure TShellUIHelper.AutoScan(const strSearch: WideString; const strFailureUrl: WideString);
begin
  DefaultInterface.AutoScan(strSearch, strFailureUrl, EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AutoScan{$else}AutoScan_1{$endif}
  (const strSearch: WideString; const strFailureUrl: WideString; var pvarTargetFrame: OleVariant);
begin
  DefaultInterface.AutoScan(strSearch, strFailureUrl, pvarTargetFrame);
end;


procedure TShellUIHelper.AutoCompleteAttach;
begin
  DefaultInterface.AutoCompleteAttach(EmptyParam);
end;

procedure TShellUIHelper.{$ifdef bDelphi5}AutoCompleteAttach{$else}AutoCompleteAttach_1{$endif}
  (var Reserved: OleVariant);
begin
  DefaultInterface.AutoCompleteAttach(Reserved);
end;


function  TShellUIHelper.ShowBrowserUI(const bstrName: WideString; var pvarIn: OleVariant): OleVariant;
begin
  Result := DefaultInterface.ShowBrowserUI(bstrName, pvarIn);
end;


class function CoShellFavoritesNameSpace.Create: IShellFavoritesNameSpace;
begin
  Result := CreateComObject(CLASS_ShellFavoritesNameSpace) as IShellFavoritesNameSpace;
end;

class function CoShellFavoritesNameSpace.CreateRemote(const MachineName: string): IShellFavoritesNameSpace;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ShellFavoritesNameSpace) as IShellFavoritesNameSpace;
end;

procedure TShellFavoritesNameSpace.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{55136805-B2DE-11D1-B9F2-00A0C98BC547}';
    IntfIID:   '{55136804-B2DE-11D1-B9F2-00A0C98BC547}';
    EventIID:  '{55136806-B2DE-11D1-B9F2-00A0C98BC547}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TShellFavoritesNameSpace.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IShellFavoritesNameSpace;
  end;
end;

procedure TShellFavoritesNameSpace.ConnectTo(svrIntf: IShellFavoritesNameSpace);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TShellFavoritesNameSpace.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TShellFavoritesNameSpace.GetDefaultInterface: IShellFavoritesNameSpace;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TShellFavoritesNameSpace.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);



end;

destructor TShellFavoritesNameSpace.Destroy;
begin



  inherited Destroy;
end;








procedure TShellFavoritesNameSpace.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnFavoritesSelectionChange) then
            FOnFavoritesSelectionChange(Self, Params[0], Params[1], Params[2], Params[3], Params[4], Params[5], Params[6]);
  end; {case DispID}
end;

function  TShellFavoritesNameSpace.Get_FOfflinePackInstalled: WordBool;
begin
  Result := DefaultInterface.Get_FOfflinePackInstalled;
end;

procedure TShellFavoritesNameSpace.MoveSelectionUp;
begin
  DefaultInterface.MoveSelectionUp;
end;

procedure TShellFavoritesNameSpace.MoveSelectionDown;
begin
  DefaultInterface.MoveSelectionDown;
end;

procedure TShellFavoritesNameSpace.ResetSort;
begin
  DefaultInterface.ResetSort;
end;

procedure TShellFavoritesNameSpace.NewFolder;
begin
  DefaultInterface.NewFolder;
end;

procedure TShellFavoritesNameSpace.Synchronize;
begin
  DefaultInterface.Synchronize;
end;

procedure TShellFavoritesNameSpace.Import;
begin
  DefaultInterface.Import;
end;

procedure TShellFavoritesNameSpace.Export;
begin
  DefaultInterface.Export;
end;

procedure TShellFavoritesNameSpace.InvokeContextMenuCommand(const strCommand: WideString);
begin
  DefaultInterface.InvokeContextMenuCommand(strCommand);
end;

procedure TShellFavoritesNameSpace.MoveSelectionTo;
begin
  DefaultInterface.MoveSelectionTo;
end;

function  TShellFavoritesNameSpace.CreateSubscriptionForSelection: WordBool;
begin
  Result := DefaultInterface.CreateSubscriptionForSelection;
end;

function  TShellFavoritesNameSpace.DeleteSubscriptionForSelection: WordBool;
begin
  Result := DefaultInterface.DeleteSubscriptionForSelection;
end;

procedure TShellFavoritesNameSpace.SetRoot(const bstrFullPath: WideString);
begin
  DefaultInterface.SetRoot(bstrFullPath);
end;




















class function CoCScriptErrorList.Create: IScriptErrorList;
begin
  Result := CreateComObject(CLASS_CScriptErrorList) as IScriptErrorList;
end;

class function CoCScriptErrorList.CreateRemote(const MachineName: string): IScriptErrorList;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CScriptErrorList) as IScriptErrorList;
end;

class function CoSearchAssistantOC.Create: ISearchAssistantOC;
begin
  Result := CreateComObject(CLASS_SearchAssistantOC) as ISearchAssistantOC;
end;

class function CoSearchAssistantOC.CreateRemote(const MachineName: string): ISearchAssistantOC;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SearchAssistantOC) as ISearchAssistantOC;
end;
*)

end.

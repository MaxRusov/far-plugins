{$I Defines.inc}

{*******************************************************}
{                                                       }
{                Delphi Runtime Library                 }
{                                                       }
{          File: winuser.h                              }
{          Copyright (c) Microsoft Corporation          }
{          All Rights Reserved.                         }
{                                                       }
{       Translator: Embarcadero Technologies, Inc.      }
{ Copyright(c) 1995-2014 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

{*******************************************************}
{             Windows Messages and Types                }
{*******************************************************}

unit Messages;

{$ALIGN ON}
{$WEAKPACKAGEUNIT}

interface

uses MixTypes, Windows;

{ Window Messages }

const
  WM_NULL             = $0000;
  WM_CREATE           = $0001;
  WM_DESTROY          = $0002;
  WM_MOVE             = $0003;
  WM_SIZE             = $0005;
  WM_ACTIVATE         = $0006;
  WM_SETFOCUS         = $0007;
  WM_KILLFOCUS        = $0008;
  WM_ENABLE           = $000A;
  WM_SETREDRAW        = $000B;
  WM_SETTEXT          = $000C;
  WM_GETTEXT          = $000D;
  WM_GETTEXTLENGTH    = $000E;
  WM_PAINT            = $000F;
  WM_CLOSE            = $0010;
  WM_QUERYENDSESSION  = $0011;
  WM_QUIT             = $0012;
  WM_QUERYOPEN        = $0013;
  WM_ERASEBKGND       = $0014;
  WM_SYSCOLORCHANGE   = $0015;
  WM_ENDSESSION       = $0016;
  WM_SYSTEMERROR      = $0017;
  WM_SHOWWINDOW       = $0018;
  WM_CTLCOLOR         = $0019;
  WM_WININICHANGE     = $001A;
  WM_SETTINGCHANGE = WM_WININICHANGE;
  WM_DEVMODECHANGE    = $001B;
  WM_ACTIVATEAPP      = $001C;
  WM_FONTCHANGE       = $001D;
  WM_TIMECHANGE       = $001E;
  WM_CANCELMODE       = $001F;
  WM_SETCURSOR        = $0020;
  WM_MOUSEACTIVATE    = $0021;
  WM_CHILDACTIVATE    = $0022;
  WM_QUEUESYNC        = $0023;
  WM_GETMINMAXINFO    = $0024;
  WM_PAINTICON        = $0026;
  WM_ICONERASEBKGND   = $0027;
  WM_NEXTDLGCTL       = $0028;
  WM_SPOOLERSTATUS    = $002A;
  WM_DRAWITEM         = $002B;
  WM_MEASUREITEM      = $002C;
  WM_DELETEITEM       = $002D;
  WM_VKEYTOITEM       = $002E;
  WM_CHARTOITEM       = $002F;
  WM_SETFONT          = $0030;
  WM_GETFONT          = $0031;
  WM_SETHOTKEY        = $0032;
  WM_GETHOTKEY        = $0033;
  WM_QUERYDRAGICON    = $0037;
  WM_COMPAREITEM      = $0039;
  WM_GETOBJECT        = $003D;
  WM_COMPACTING       = $0041;

  WM_COMMNOTIFY       = $0044;    { obsolete in Win32}

  WM_WINDOWPOSCHANGING = $0046;
  WM_WINDOWPOSCHANGED = $0047;
  WM_POWER            = $0048;
  WM_COPYGLOBALDATA   = $0049;
  WM_COPYDATA         = $004A;
  WM_CANCELJOURNAL    = $004B;
  WM_NOTIFY           = $004E;
  WM_INPUTLANGCHANGEREQUEST = $0050;
  WM_INPUTLANGCHANGE  = $0051;
  WM_TCARD            = $0052;
  WM_HELP             = $0053;
  WM_USERCHANGED      = $0054;
  WM_NOTIFYFORMAT     = $0055;

  WM_CONTEXTMENU      = $007B;
  WM_STYLECHANGING    = $007C;
  WM_STYLECHANGED     = $007D;
  WM_DISPLAYCHANGE    = $007E;
  WM_GETICON          = $007F;
  WM_SETICON          = $0080;

  WM_NCCREATE         = $0081;
  WM_NCDESTROY        = $0082;
  WM_NCCALCSIZE       = $0083;
  WM_NCHITTEST        = $0084;
  WM_NCPAINT          = $0085;
  WM_NCACTIVATE       = $0086;
  WM_GETDLGCODE       = $0087;
  WM_NCMOUSEMOVE      = $00A0;
  WM_NCLBUTTONDOWN    = $00A1;
  WM_NCLBUTTONUP      = $00A2;
  WM_NCLBUTTONDBLCLK  = $00A3;
  WM_NCRBUTTONDOWN    = $00A4;
  WM_NCRBUTTONUP      = $00A5;
  WM_NCRBUTTONDBLCLK  = $00A6;
  WM_NCMBUTTONDOWN    = $00A7;
  WM_NCMBUTTONUP      = $00A8;
  WM_NCMBUTTONDBLCLK  = $00A9;

  WM_NCXBUTTONDOWN = $00AB;
  WM_NCXBUTTONUP = $00AC;
  WM_NCXBUTTONDBLCLK = $00AD;
  WM_INPUT_DEVICE_CHANGE = $00FE;
  WM_INPUT = $00FF;

  WM_KEYFIRST         = $0100;
  WM_KEYDOWN          = $0100;
  WM_KEYUP            = $0101;
  WM_CHAR             = $0102;
  WM_DEADCHAR         = $0103;
  WM_SYSKEYDOWN       = $0104;
  WM_SYSKEYUP         = $0105;
  WM_SYSCHAR          = $0106;
  WM_SYSDEADCHAR      = $0107;
  WM_UNICHAR          = $0109;
  WM_KEYLAST          = $0109;

  WM_INITDIALOG       = $0110;
  WM_COMMAND          = $0111;
  WM_SYSCOMMAND       = $0112;
  WM_TIMER            = $0113;
  WM_HSCROLL          = $0114;
  WM_VSCROLL          = $0115;
  WM_INITMENU         = $0116;
  WM_INITMENUPOPUP    = $0117;

  WM_GESTURE = $0119;
  WM_GESTURENOTIFY = $011A;

  WM_MENUSELECT       = $011F;
  WM_MENUCHAR         = $0120;
  WM_ENTERIDLE        = $0121;

  WM_MENURBUTTONUP    = $0122;
  WM_MENUDRAG         = $0123;
  WM_MENUGETOBJECT    = $0124;
  WM_UNINITMENUPOPUP  = $0125;
  WM_MENUCOMMAND      = $0126;

  WM_CHANGEUISTATE    = $0127;
  WM_UPDATEUISTATE    = $0128;
  WM_QUERYUISTATE     = $0129;

  WM_CTLCOLORMSGBOX   = $0132;
  WM_CTLCOLOREDIT     = $0133;
  WM_CTLCOLORLISTBOX  = $0134;
  WM_CTLCOLORBTN      = $0135;
  WM_CTLCOLORDLG      = $0136;
  WM_CTLCOLORSCROLLBAR= $0137;
  WM_CTLCOLORSTATIC   = $0138;

  WM_MOUSEFIRST       = $0200;
  WM_MOUSEMOVE        = $0200;
  WM_LBUTTONDOWN      = $0201;
  WM_LBUTTONUP        = $0202;
  WM_LBUTTONDBLCLK    = $0203;
  WM_RBUTTONDOWN      = $0204;
  WM_RBUTTONUP        = $0205;
  WM_RBUTTONDBLCLK    = $0206;
  WM_MBUTTONDOWN      = $0207;
  WM_MBUTTONUP        = $0208;
  WM_MBUTTONDBLCLK    = $0209;
  WM_MOUSEWHEEL       = $020A;

  WM_XBUTTONDOWN = $020B; 
  WM_XBUTTONUP = $020C; 
  WM_XBUTTONDBLCLK = $020D; 
  WM_MOUSEHWHEEL = $020E; 

  WM_MOUSELAST = $020E; 

  WM_PARENTNOTIFY     = $0210;
  WM_ENTERMENULOOP    = $0211;
  WM_EXITMENULOOP     = $0212;
  WM_NEXTMENU         = $0213;

  WM_SIZING           = 532;
  WM_CAPTURECHANGED   = 533;
  WM_MOVING           = 534;
  WM_POWERBROADCAST   = 536;
  WM_DEVICECHANGE     = 537;

  WM_IME_STARTCOMPOSITION        = $010D;
  WM_IME_ENDCOMPOSITION          = $010E;
  WM_IME_COMPOSITION             = $010F;
  WM_IME_KEYLAST                 = $010F;

  WM_IME_SETCONTEXT              = $0281;
  WM_IME_NOTIFY                  = $0282;
  WM_IME_CONTROL                 = $0283;
  WM_IME_COMPOSITIONFULL         = $0284;
  WM_IME_SELECT                  = $0285;
  WM_IME_CHAR                    = $0286;
  WM_IME_REQUEST                 = $0288;

  WM_IME_KEYDOWN                 = $0290;
  WM_IME_KEYUP                   = $0291;

  WM_MDICREATE        = $0220;
  WM_MDIDESTROY       = $0221;
  WM_MDIACTIVATE      = $0222;
  WM_MDIRESTORE       = $0223;
  WM_MDINEXT          = $0224;
  WM_MDIMAXIMIZE      = $0225;
  WM_MDITILE          = $0226;
  WM_MDICASCADE       = $0227;
  WM_MDIICONARRANGE   = $0228;
  WM_MDIGETACTIVE     = $0229;
  WM_MDISETMENU       = $0230;

  WM_ENTERSIZEMOVE    = $0231;
  WM_EXITSIZEMOVE     = $0232;
  WM_DROPFILES        = $0233;
  WM_MDIREFRESHMENU   = $0234;

  WM_TOUCH            = $0240;

  WM_MOUSEHOVER       = $02A1;
  WM_MOUSELEAVE       = $02A3;

  WM_NCMOUSEHOVER     = $02A0;
  WM_NCMOUSELEAVE     = $02A2;
  WM_WTSSESSION_CHANGE = $02B1;

  WM_TABLET_FIRST     = $02C0;
  WM_TABLET_LAST      = $02DF;

  WM_CUT              = $0300;
  WM_COPY             = $0301;
  WM_PASTE            = $0302;
  WM_CLEAR            = $0303;
  WM_UNDO             = $0304;
  WM_RENDERFORMAT     = $0305;
  WM_RENDERALLFORMATS = $0306;
  WM_DESTROYCLIPBOARD = $0307;
  WM_DRAWCLIPBOARD    = $0308;
  WM_PAINTCLIPBOARD   = $0309;
  WM_VSCROLLCLIPBOARD = $030A;
  WM_SIZECLIPBOARD    = $030B;
  WM_ASKCBFORMATNAME  = $030C;
  WM_CHANGECBCHAIN    = $030D;
  WM_HSCROLLCLIPBOARD = $030E;
  WM_QUERYNEWPALETTE  = $030F;
  WM_PALETTEISCHANGING= $0310;
  WM_PALETTECHANGED   = $0311;
  WM_HOTKEY           = $0312;

  WM_PRINT            = 791;
  WM_PRINTCLIENT      = 792;
  WM_APPCOMMAND       = $0319;
  WM_THEMECHANGED     = $031A;

  WM_CLIPBOARDUPDATE  = $031D;

  WM_HANDHELDFIRST    = 856;
  WM_HANDHELDLAST     = 863;

  WM_PENWINFIRST      = $0380;
  WM_PENWINLAST       = $038F;

  WM_COALESCE_FIRST   = $0390;
  WM_COALESCE_LAST    = $039F;

  WM_DDE_FIRST        = $03E0;
  WM_DDE_INITIATE     = WM_DDE_FIRST + 0;
  WM_DDE_TERMINATE    = WM_DDE_FIRST + 1;
  WM_DDE_ADVISE       = WM_DDE_FIRST + 2;
  WM_DDE_UNADVISE     = WM_DDE_FIRST + 3;
  WM_DDE_ACK          = WM_DDE_FIRST + 4;
  WM_DDE_DATA         = WM_DDE_FIRST + 5;
  WM_DDE_REQUEST      = WM_DDE_FIRST + 6;
  WM_DDE_POKE         = WM_DDE_FIRST + 7;
  WM_DDE_EXECUTE      = WM_DDE_FIRST + 8;
  WM_DDE_LAST         = WM_DDE_FIRST + 8;

  WM_DWMCOMPOSITIONCHANGED        = $031E; 
  WM_DWMNCRENDERINGCHANGED        = $031F;
  WM_DWMCOLORIZATIONCOLORCHANGED  = $0320;
  WM_DWMWINDOWMAXIMIZEDCHANGE     = $0321;

  WM_DWMSENDICONICTHUMBNAIL       = $0323;
  WM_DWMSENDICONICLIVEPREVIEWBITMAP = $0326;

  WM_GETTITLEBARINFOEX = $033F;

  WM_TABLET_DEFBASE = $02C0;
  WM_TABLET_MAXOFFSET = $20;
  WM_TABLET_ADDED = WM_TABLET_DEFBASE + 8;
  WM_TABLET_DELETED = WM_TABLET_DEFBASE + 9;
  WM_TABLET_FLICK = WM_TABLET_DEFBASE + 11;
  WM_TABLET_QUERYSYSTEMGESTURESTATUS = WM_TABLET_DEFBASE + 12;

  WM_APP = $8000;

{ NOTE: All Message Numbers below 0x0400 are RESERVED }

{ Private Window Messages Start Here }

  WM_USER             = $0400;

{ Button Notification Codes }

const
  BN_CLICKED       = 0;
  BN_PAINT         = 1;
  BN_HILITE        = 2;
  BN_UNHILITE      = 3;
  BN_DISABLE       = 4;
  BN_DOUBLECLICKED = 5;
  BN_PUSHED = BN_HILITE;
  BN_UNPUSHED = BN_UNHILITE;
  BN_DBLCLK = BN_DOUBLECLICKED;
  BN_SETFOCUS = 6;
  BN_KILLFOCUS = 7;

{ Button Control Messages }
const
  BM_GETCHECK = $00F0;
  BM_SETCHECK = $00F1;
  BM_GETSTATE = $00F2;
  BM_SETSTATE = $00F3;
  BM_SETSTYLE = $00F4;
  BM_CLICK    = $00F5;
  BM_GETIMAGE = $00F6;
  BM_SETIMAGE = $00F7;
  BM_SETDONTCLICK = $00F8;

{ Listbox Notification Codes }

const
  LBN_ERRSPACE  = (-2);
  LBN_SELCHANGE = 1;
  LBN_DBLCLK    = 2;
  LBN_SELCANCEL = 3;
  LBN_SETFOCUS  = 4;
  LBN_KILLFOCUS = 5;

{ Listbox messages }

const
  LB_ADDSTRING            = $0180;
  LB_INSERTSTRING         = $0181;
  LB_DELETESTRING         = $0182;
  LB_SELITEMRANGEEX       = $0183;
  LB_RESETCONTENT         = $0184;
  LB_SETSEL               = $0185;
  LB_SETCURSEL            = $0186;
  LB_GETSEL               = $0187;
  LB_GETCURSEL            = $0188;
  LB_GETTEXT              = $0189;
  LB_GETTEXTLEN           = $018A;
  LB_GETCOUNT             = $018B;
  LB_SELECTSTRING         = $018C;
  LB_DIR                  = $018D;
  LB_GETTOPINDEX          = $018E;
  LB_FINDSTRING           = $018F;
  LB_GETSELCOUNT          = $0190;
  LB_GETSELITEMS          = $0191;
  LB_SETTABSTOPS          = $0192;
  LB_GETHORIZONTALEXTENT  = $0193;
  LB_SETHORIZONTALEXTENT  = $0194;
  LB_SETCOLUMNWIDTH       = $0195;
  LB_ADDFILE              = $0196;
  LB_SETTOPINDEX          = $0197;
  LB_GETITEMRECT          = $0198;
  LB_GETITEMDATA          = $0199;
  LB_SETITEMDATA          = $019A;
  LB_SELITEMRANGE         = $019B;
  LB_SETANCHORINDEX       = $019C;
  LB_GETANCHORINDEX       = $019D;
  LB_SETCARETINDEX        = $019E;
  LB_GETCARETINDEX        = $019F;
  LB_SETITEMHEIGHT        = $01A0;
  LB_GETITEMHEIGHT        = $01A1;
  LB_FINDSTRINGEXACT      = $01A2;
  LB_SETLOCALE            = $01A5;
  LB_GETLOCALE            = $01A6;
  LB_SETCOUNT             = $01A7;
  LB_INITSTORAGE          = $01A8;
  LB_ITEMFROMPOINT        = $01A9;
  LB_MSGMAX               = $01B3; { if _WIN32_WINNT >= 0x0501 }
  //LB_MSGMAX             = $01B1; { else if _WIN32_WCE >= 0x0400 }
  //LB_MSGMAX             = $01B0; { else if WINVER >= 0x0400 }
  //LB_MSGMAX             = $01A8] { else }

{ Combo Box Notification Codes }

const
  CBN_ERRSPACE   = (-1);
  CBN_SELCHANGE  = 1;
  CBN_DBLCLK     = 2;
  CBN_SETFOCUS   = 3;
  CBN_KILLFOCUS  = 4;
  CBN_EDITCHANGE = 5;
  CBN_EDITUPDATE = 6;
  CBN_DROPDOWN   = 7;
  CBN_CLOSEUP    = 8;
  CBN_SELENDOK   = 9;
  CBN_SELENDCANCEL = 10;

{ Combo Box messages }

  CB_GETEDITSEL            = $0140;
  CB_LIMITTEXT             = $0141;
  CB_SETEDITSEL            = $0142;
  CB_ADDSTRING             = $0143;
  CB_DELETESTRING          = $0144;
  CB_DIR                   = $0145;
  CB_GETCOUNT              = $0146;
  CB_GETCURSEL             = $0147;
  CB_GETLBTEXT             = $0148;
  CB_GETLBTEXTLEN          = $0149;
  CB_INSERTSTRING          = $014A;
  CB_RESETCONTENT          = $014B;
  CB_FINDSTRING            = $014C;
  CB_SELECTSTRING          = $014D;
  CB_SETCURSEL             = $014E;
  CB_SHOWDROPDOWN          = $014F;
  CB_GETITEMDATA           = $0150;
  CB_SETITEMDATA           = $0151;
  CB_GETDROPPEDCONTROLRECT = $0152;
  CB_SETITEMHEIGHT         = $0153;
  CB_GETITEMHEIGHT         = $0154;
  CB_SETEXTENDEDUI         = $0155;
  CB_GETEXTENDEDUI         = $0156;
  CB_GETDROPPEDSTATE       = $0157;
  CB_FINDSTRINGEXACT       = $0158;
  CB_SETLOCALE             = 345;
  CB_GETLOCALE             = 346;
  CB_GETTOPINDEX           = 347;
  CB_SETTOPINDEX           = 348;
  CB_GETHORIZONTALEXTENT   = 349;
  CB_SETHORIZONTALEXTENT   = 350;
  CB_GETDROPPEDWIDTH       = 351;
  CB_SETDROPPEDWIDTH       = 352;
  CB_INITSTORAGE           = 353;
  CB_MSGMAX                = $165; { if _WIN32_WINNT >= 0x0501 }
  //CB_MSGMAX                = $163; { else if _WIN32_WCE >= 0x0400 }
  //CB_MSGMAX                = $162; { else if _WIN32_VER >= 0x0400 }
  //CB_MSGMAX                = $15B; { else }

{ Edit Control Notification Codes }

const
  EN_SETFOCUS  = $0100;
  EN_KILLFOCUS = $0200;
  EN_CHANGE    = $0300;
  EN_UPDATE    = $0400;
  EN_ERRSPACE  = $0500;
  EN_MAXTEXT   = $0501;
  EN_HSCROLL   = $0601;
  EN_VSCROLL   = $0602;

{ Edit Control Messages }

const
  EM_GETSEL              = $00B0;
  EM_SETSEL              = $00B1;
  EM_GETRECT             = $00B2;
  EM_SETRECT             = $00B3;
  EM_SETRECTNP           = $00B4;
  EM_SCROLL              = $00B5;
  EM_LINESCROLL          = $00B6;
  EM_SCROLLCARET         = $00B7;
  EM_GETMODIFY           = $00B8;
  EM_SETMODIFY           = $00B9;
  EM_GETLINECOUNT        = $00BA;
  EM_LINEINDEX           = $00BB;
  EM_SETHANDLE           = $00BC;
  EM_GETHANDLE           = $00BD;
  EM_GETTHUMB            = $00BE;
  EM_LINELENGTH          = $00C1;
  EM_REPLACESEL          = $00C2;
  EM_GETLINE             = $00C4;
  EM_LIMITTEXT           = $00C5;
  EM_CANUNDO             = $00C6;
  EM_UNDO                = $00C7;
  EM_FMTLINES            = $00C8;
  EM_LINEFROMCHAR        = $00C9;
  EM_SETTABSTOPS         = $00CB;
  EM_SETPASSWORDCHAR     = $00CC;
  EM_EMPTYUNDOBUFFER     = $00CD;
  EM_GETFIRSTVISIBLELINE = $00CE;
  EM_SETREADONLY         = $00CF;
  EM_SETWORDBREAKPROC    = $00D0;
  EM_GETWORDBREAKPROC    = $00D1;
  EM_GETPASSWORDCHAR     = $00D2;
  EM_SETMARGINS          = 211;
  EM_GETMARGINS          = 212;
  EM_SETLIMITTEXT        = EM_LIMITTEXT;    //win40 Name change
  EM_GETLIMITTEXT        = 213;
  EM_POSFROMCHAR         = 214;
  EM_CHARFROMPOS         = 215;
  EM_SETIMESTATUS        = 216;
  EM_GETIMESTATUS        = 217;

const
  { Scroll bar messages }
  SBM_SETPOS = 224;             { not in win3.1  }
  SBM_GETPOS = 225;             { not in win3.1  }
  SBM_SETRANGE = 226;           { not in win3.1  }
  SBM_SETRANGEREDRAW = 230;     { not in win3.1  }
  SBM_GETRANGE = 227;           { not in win3.1  }
  SBM_ENABLE_ARROWS = 228;      { not in win3.1  }
  SBM_SETSCROLLINFO = 233;
  SBM_GETSCROLLINFO = 234;
  SBM_GETSCROLLBARINFO = 235;   { Win XP or later }

{ Dialog messages }

  DM_GETDEFID = (WM_USER+0);
  DM_SETDEFID = (WM_USER+1);
  DM_REPOSITION = (WM_USER+2);

  PSM_PAGEINFO = (WM_USER+100);
  PSM_SHEETINFO = (WM_USER+101);

type

  { Generic 64 bits Filler record }

(*  T4Byte64Filler = record
  {$IFDEF CPUX64}
    Filler: array[0..3] of Byte;
  {$ENDIF}
  end;*)

  TWordFiller = record
  {$IFDEF CPUX86}
    Filler: array[1..2] of Byte; // Pad word make it 4 Bytes (2+2)
  {$ENDIF}
  {$IFDEF CPUX64}
    Filler: array[1..6] of Byte; // Pad word to make it 8 Bytes (2+6)
  {$ENDIF}
  end;

  TDWordFiller = record
  {$IFDEF CPUX64}
    Filler: array[1..4] of Byte; // Pad DWORD to make it 8 bytes (4+4) [x64 only]
  {$ENDIF}
  end;

{ Generic window message record }

  PMessage = ^TMessage;
  TMessage = record
    Msg: Cardinal;
    case Integer of
      0: (
        WParam: WPARAM;
        LParam: LPARAM;
        Result: LRESULT);
      1: (
        WParamLo: Word;
        WParamHi: Word;
        WParamFiller: TDWordFiller;
        LParamLo: Word;
        LParamHi: Word;
        LParamFiller: TDWordFiller;
        ResultLo: Word;
        ResultHi: Word;
        ResultFiller: TDWordFiller);
  end;

{ Common message format records }

  TWMNoParams = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: array[0..3] of Word;
    UnusedFiller: TDWordFiller;
    UnusedFiller2: TDWordFiller;
    Result: LRESULT;
  end;

  TWMKey = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CharCode: Word;
    Unused: Word;
	  CharCodeUnusedFiller: TDWordFiller;
    KeyData: Longint;
    KeyDataFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMMouse = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Keys: Longint;
    KeysFiller: TDWordFiller;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller;);
      1: (
        Pos: TSmallPoint;
        PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMMouseWheel = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Keys: SmallInt;
    WheelDelta: SmallInt;
    KeysWhellFiller: TDWordFiller;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller);
      1: (
        Pos: TSmallPoint;
        PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TMSHMouseWheel = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    WheelDelta: Integer;
    WheelDeltaFiller: TDWordFiller;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller);
      1: (
        Pos: TSmallPoint;
        PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMWindowPosMsg = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: Integer;
    UnusedFiller: TDWordFiller;
    WindowPos: PWindowPos;
    Result: LRESULT;
  end;

  TWMScroll = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    ScrollCode: Smallint; { SB_xxxx }
    Pos: Smallint;
    ScrollCodePosFiller: TDWordFiller;
    ScrollBar: HWND;
    Result: LRESULT;
  end;

{ Message records }

  TWMActivate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Active: Word; { WA_INACTIVE, WA_ACTIVE, WA_CLICKACTIVE }
    Minimized: WordBool;
    ActiveMinimizedFiller: TDWordFiller;
    ActiveWindow: HWND;
    Result: LRESULT;
  end;

  TWMActivateApp = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Active: BOOL;
    ActiveFiller: TDWordFiller;
    ThreadId: Longint;
    TheadIdFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMAskCBFormatName = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    NameLen: Word;
    NameLenFiller: TWordFiller;
    FormatName: PTChar;
    Result: LRESULT;
  end;

  TWMCancelMode = TWMNoParams;

  TWMChangeCBChain = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Remove: HWND;
    Next: HWND;
    Result: LRESULT;
  end;

  TWMChar = TWMKey;

  TWMCharToItem = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Key: Word;
    CaretPos: Word;
    keyCaretPosFiller: TDWordFiller;
    ListBox: HWND;
    Result: LRESULT;
  end;

  TWMChildActivate = TWMNoParams;

  TWMChooseFont_GetLogFont = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: Longint;
    UnusedFiller: TDWordFiller;
    LogFont: PLogFont;
    Result: LRESULT;
  end;

  TWMClear = TWMNoParams;
  TWMClose = TWMNoParams;

  TWMCommand = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    ItemID: Word;
    NotifyCode: Word;
    ItemIDNotifyCodeFiller: TDWordFiller;
    Ctl: HWND;
    Result: LRESULT;
  end;

  TWMCompacting = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CompactRatio: WPARAM;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMCompareItem = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Ctl: HWnd;
    CompareItemStruct: PCompareItemStruct;
    Result: LRESULT;
  end;

  TWMCopy = TWMNoParams;

  TWMCopyData = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    From: HWND;
    CopyDataStruct: PCopyDataStruct;
    Result: LRESULT;
  end;

  { ?? WM_CLP_LAUNCH, WM_CPL_LAUNCHED }

  TWMCreate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    CreateStruct: PCreateStruct;
    Result: LRESULT;
  end;

  TWMCtlColor = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    ChildDC: HDC;
    ChildWnd: HWND;
    Result: LRESULT;
  end;

  TWMCtlColorBtn = TWMCtlColor;
  TWMCtlColorDlg = TWMCtlColor;
  TWMCtlColorEdit = TWMCtlColor;
  TWMCtlColorListbox = TWMCtlColor;
  TWMCtlColorMsgbox = TWMCtlColor;
  TWMCtlColorScrollbar = TWMCtlColor;
  TWMCtlColorStatic = TWMCtlColor;

  TWMCut = TWMNoParams;

  TWMDDE_Ack = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    case Word of
      WM_DDE_INITIATE: (
        App: Word;
        Topic: Word;
        AppTopicFiller: TDWordFiller;
        Result: LRESULT);
      WM_DDE_EXECUTE {and all others}: (
        PackedVal: Longint;
        PackedValFiller: TDWordFiller;);
  end;

  TWMDDE_Advise = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    PackedVal: Longint;
    PackedValFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMDDE_Data = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    PackedVal: Longint;
    PackedValFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMDDE_Execute = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    Commands: THandle;
    Result: LRESULT;
  end;

  TWMDDE_Initiate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    App: Word;
    Topic: Word;
    AppTopicFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMDDE_Poke = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    PackedVal: Longint;
    PackedValFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMDDE_Request = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    Format: Word;
    Item: Word;
    FormatItemFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMDDE_Terminate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMDDE_Unadvise = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PostingApp: HWND;
    Format: Word;
    Item: Word;
    FormatItemFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMDeadChar = TWMChar;

  TWMDeleteItem = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Ctl: HWND;
    DeleteItemStruct: PDeleteItemStruct;
    Result: LRESULT;
  end;

  TWMDestroy = TWMNoParams;
  TWMDestroyClipboard = TWMNoParams;

  TWMDevModeChange = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    Device: PTChar;
    Result: LRESULT;
  end;

  TWMDrawClipboard = TWMNoParams;

  TWMDrawItem = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Ctl: HWND;
    DrawItemStruct: PDrawItemStruct;
    Result: LRESULT;
  end;

  TWMDropFiles = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Drop: THANDLE;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMEnable = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Enabled: LongBool;
    EnabledFiller: TDWordFiller;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMEndSession = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    EndSession: LongBool;
    EndSessionFiller: TDWordFiller;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMEnterIdle = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Source: WPARAM; { MSGF_DIALOGBOX, MSGF_MENU }
    IdleWnd: HWND;
    Result: LRESULT;
  end;

  TWMEnterMenuLoop = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    IsTrackPopupMenu: LongBool;
    IsTrackPopupMenuFiller: TDWordFiller;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMExitMenuLoop = TWMEnterMenuLoop;

  TWMEraseBkgnd = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    DC: HDC;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMFontChange = TWMNoParams;
  TWMGetDlgCode = TWMNoParams;
  TWMGetFont = TWMNoParams;

  TWMGetIcon = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    BigIcon: Longbool;
    BigIconFiller: TDWordFiller;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMGetHotKey = TWMNoParams;

  TWMGetMinMaxInfo = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    MinMaxInfo: PMinMaxInfo;
    Result: LRESULT;
  end;

  TWMGetText = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    TextMax: WPARAM;
    Text: PTChar;
    Result: LRESULT;
  end;

  TWMGetTextLength = TWMNoParams;

  TWMHotKey = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    HotKey: WPARAM;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMHScroll = TWMScroll;

  TWMHScrollClipboard = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Viewer: HWND;
    ScrollCode: Word; {SB_BOTTOM, SB_ENDSCROLL, SB_LINEDOWN, SB_LINEUP,
                       SB_PAGEDOWN, SB_PAGEUP, SB_THUMBPOSITION,
                       SB_THUMBTRACK, SB_TOP }
    Pos: Word;
    ScrollCodePosFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMIconEraseBkgnd = TWMEraseBkgnd;

  TWMInitDialog = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Focus: HWND;
    InitParam: LPARAM;
    Result: LRESULT;
  end;

  TWMInitMenu = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Menu: HMENU;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMInitMenuPopup = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    MenuPopup: HMENU;
    Pos: Smallint;
    SystemMenu: WordBool;
    PosSystemMenuFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMKeyDown = TWMKey;
  TWMKeyUp = TWMKey;

  TWMKillFocus = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    FocusedWnd: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMLButtonDblClk = TWMMouse;
  TWMLButtonDown   = TWMMouse;
  TWMLButtonUp     = TWMMouse;
  TWMMButtonDblClk = TWMMouse;
  TWMMButtonDown   = TWMMouse;
  TWMMButtonUp     = TWMMouse;

  TWMMDIActivate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    case Integer of
      0: (
        ChildWnd: HWND);
      1: (
        DeactiveWnd: HWND;
        ActiveWnd: HWND;
        Result: LRESULT);
  end;

  TWMMDICascade = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Cascade: WPARAM; { 0, MDITILE_SKIPDISABLED }
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMMDICreate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    MDICreateStruct: PMDICreateStruct;
    Result: LRESULT;
  end;

  TWMMDIDestroy = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Child: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMMDIGetActive = TWMNoParams;
  TWMMDIIconArrange = TWMNoParams;

  TWMMDIMaximize = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Maximize: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMMDINext = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Child: HWND;
    Next: LPARAM;
    Result: LRESULT;
  end;

  TWMMDIRefreshMenu = TWMNoParams;

  TWMMDIRestore = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    IDChild: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMMDISetMenu = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    MenuFrame: HMENU;
    MenuWindow: HMENU;
    Result: LRESULT;
  end;

  TWMMDITile = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Tile: WPARAM;  { MDITILE_HORIZONTAL, MDITILE_SKIPDISABLE,
                     MDITILE_VERTICAL }
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMMeasureItem = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    IDCtl: HWnd;
    MeasureItemStruct: PMeasureItemStruct;
    Result: LRESULT;
  end;

  TWMMenuChar = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    User:TChar;
{$IF NOT DEFINED(UNICODE)}
    Unused: Byte;
{$ENDIF}
    MenuFlag: Word; { MF_POPUP, MF_SYSMENU }
    UserMenuFlagFiller: TDWordFiller;
    Menu: HMENU;
    Result: LRESULT;
  end;

  TWMMenuSelect = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    IDItem: Word;
    MenuFlag: Word; { MF_BITMAP, MF_CHECKED, MF_DISABLED, MF_GRAYED,
                      MF_MOUSESELECT, MF_OWNERDRAW, MF_POPUP, MF_SEPARATOR,
                      MF_SYSMENU }
    IDItemMenuFlagFiller: TDWordFiller;
    Menu: HMENU;
    Result: LRESULT;
  end;

  TWMMouseActivate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    TopLevel: HWND;
    HitTestCode: Word;
    MouseMsg: Word;
    HitTestCodeMouseMsg: TDWordFiller;
    Result: LRESULT;
  end;

  TWMMouseMove = TWMMouse;

  TWMMove = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller);
      1: (
        Pos: TSmallPoint;
        PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMMoving = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Edge: WPARAM;
    DragRect: PRect;
  end;

  TWMNCActivate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Active: BOOL;
    ActiveFiller: TDWordFiller;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMNCCalcSize = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CalcValidRects: BOOL;
    CalcValidRectsFiller: TDWordFiller;
    CalcSize_Params: PNCCalcSizeParams;
    Result: LRESULT;
  end;

  TWMNCCreate = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    CreateStruct: PCreateStruct;
    Result: LRESULT;
  end;

  TWMNCDestroy = TWMNoParams;

  TWMNCHitTest = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller);
      1: (
        Pos: TSmallPoint;
        PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMNCHitMessage = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    HitTest: Longint;
    HitTestFiller: TDWordFiller;
    XCursor: Smallint;
    YCursor: Smallint;
    XYCursorFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMNCLButtonDblClk = TWMNCHitMessage;
  TWMNCLButtonDown   = TWMNCHitMessage;
  TWMNCLButtonUp     = TWMNCHitMessage;
  TWMNCMButtonDblClk = TWMNCHitMessage;
  TWMNCMButtonDown   = TWMNCHitMessage;
  TWMNCMButtonUp     = TWMNCHitMessage;
  TWMNCMouseMove     = TWMNCHitMessage;

  TWMNCPaint = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    RGN: HRGN;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMNCRButtonDblClk = TWMNCHitMessage;
  TWMNCRButtonDown   = TWMNCHitMessage;
  TWMNCRButtonUp     = TWMNCHitMessage;

  TWMNextDlgCtl = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CtlFocus: WPARAM;
    Handle: WordBool;
    HandleFiller: TWordFiller;
    Result: LRESULT;
  end;

  TWMNotify = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    IDCtrl: WPARAM;
    NMHdr: PNMHdr;
    Result: LRESULT;
  end;

  TWMNotifyFormat = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    From: HWND;
    Command: LPARAM;
    Result: LRESULT;
  end;

  TWMPaint = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    DC: HDC;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMPaintClipboard = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Viewer: HWND;
    PaintStruct: THandle;
    Result: LRESULT;
  end;

  TWMPaintIcon = TWMNoParams;

  TWMPaletteChanged = record
    Msg: Cardinal;
    MsgFiller:TDWordFiller;
    PalChg: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMPaletteIsChanging = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Realize: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMParentNotify = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    case Word of
      WM_CREATE, WM_DESTROY: (
        Unused1: Word;
        ChildID: Word;
        EventChildIDFiller: TDWordFiller;
        ChildWnd: HWnd);
      WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN: (
        Unused2: Word;
        Value: Word;
        EventValueFiller: TDWordFiller;
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller);
      0: (
        Event: Word;
        Value1: Word;
        EventValue1Filler: TDWordFiller;
        Value2: LPARAM;
        Result: LRESULT);
  end;

  TWMPaste = TWMNoParams;

  TWMPower = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    PowerEvt: WPARAM;  { PWR_SUSPENDREQUEST, PWR_SUSPENDRESUME,
                         PWR_CRITICALRESUME }
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMQueryDragIcon = TWMNoParams;

  TWMQueryEndSession = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Source: WPARAM;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMQueryNewPalette = TWMNoParams;
  TWMQueryOpen = TWMNoParams;
  TWMQueueSync = TWMNoParams;

  TWMQuit = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    ExitCode: WPARAM;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMRButtonDblClk = TWMMouse;
  TWMRButtonDown = TWMMouse;
  TWMRButtonUp = TWMMouse;

  TWMRenderAllFormats = TWMNoParams;

  TWMRenderFormat = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Format: WPARAM;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMSetCursor = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CursorWnd: HWND;
    HitTest: SmallInt;
    MouseMsg: Word;
    HitTestMouseMsgFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMSetFocus = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    FocusedWnd: HWND;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMSetFont = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Font: HFONT;
    Redraw: WordBool;
    RedrawFiller: TWordFiller;
    Result: LRESULT;
  end;

  TWMSetHotKey = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Key: Longint;
    KeyFiller: TDWordFiller;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMSetIcon = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    BigIcon: Longbool;
    BigIconFiller: TDWordFiller;
    Icon: HICON;
    Result: LRESULT;
  end;

  TWMSetRedraw = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Redraw: WPARAM;
    Unused: LPARAM;
    Result: LRESULT;
  end;

  TWMSetText = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    Text: PTChar;
    Result: LRESULT;
  end;

  TWMShowWindow = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Show: BOOL;
    ShowFiller: TDWordFiller;
    Status: LPARAM;
    Result: LRESULT;
  end;

  TWMSize = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    SizeType: WPARAM;  { SIZE_MAXIMIZED, SIZE_MINIMIZED, SIZE_RESTORED,
                         SIZE_MAXHIDE, SIZE_MAXSHOW }
    Width: Word;
    Height: Word;
    WidthHeightFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMSizeClipboard = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Viewer: HWND;
    RC: THandle;
    Result: LRESULT;
  end;

  TWMSpoolerStatus = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    JobStatus: WPARAM;
    JobsLeft: Word;
    JobsLeftFiller: TWordFiller;
    Result: LRESULT;
  end;

  TWMStyleChange = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    StyleType: WPARAM;
    StyleStruct: PStyleStruct;
    Result: LRESULT;
  end;

  TWMStyleChanged = TWMStyleChange;
  TWMStyleChanging = TWMStyleChange;

  TWMSysChar = TWMKey;
  TWMSysColorChange = TWMNoParams;

  TWMSysCommand = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CmdType: WPARAM;
    case WPARAM of
      SC_HOTKEY: (
        ActivateWnd: HWND);
      SC_KEYMENU: (
        Key: Word);
      SC_CLOSE, SC_HSCROLL, SC_MAXIMIZE, SC_MINIMIZE, SC_MOUSEMENU, SC_MOVE,
      SC_NEXTWINDOW, SC_PREVWINDOW, SC_RESTORE, SC_SCREENSAVE, SC_SIZE,
      SC_TASKLIST, SC_VSCROLL: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMSysDeadChar = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    CharCode: Word;
    CharCodeFiller: TWordFiller;
    KeyData: Longint;
    KeyDataFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMSysKeyDown = TWMKey;
  TWMSysKeyUp = TWMKey;

  TWMSystemError = record
    Msg: Cardinal;
    ErrSpec: Word;
    Unused: Longint;
    Result: Longint;
  end;

  TWMTimeChange = TWMNoParams;

  TWMTimer = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    TimerID: WPARAM;
    TimerProc: TFarProc;
    Result: LRESULT;
  end;

  TWMUIState = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Action: Word;
    Flags: Word;
    ActionFlagsFiller: TDWordFiller;
    Unused: LPARAM;
  end;

  TWMChangeUIState = TWMUIState;
  TWMUpdateUIState = TWMUIState;
  TWMQueryUIState = TWMNoParams;

  TWMUndo = TWMNoParams;

  TWMVKeyToItem = TWMCharToItem;

  TWMVScroll = TWMScroll;

  TWMVScrollClipboard = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Viewer: HWND;
    ScollCode: Word;
    ThumbPos: Word;
    ScrollCodeThumbPosFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMWindowPosChanged = TWMWindowPosMsg;
  TWMWindowPosChanging = TWMWindowPosMsg;

  TWMWinIniChange = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    Section: PTChar;
    Result: LRESULT;
  end;

  TWMSettingChange = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Flag: WPARAM;
    Section: PTChar;
    Result: LRESULT;
  end;

  TWMHelp = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    HelpInfo: PHelpInfo;
    Result: LRESULT;
  end;

  TWMDisplayChange = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    BitsPerPixel: WPARAM;
    Width: Word;
    Height: Word;
    WidthHeightFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMContextMenu = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    hWnd: HWND;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint;
        XYPosFiller: TDWordFiller);
      1: (
        Pos: TSmallPoint;
        PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMPrint = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    DC: HDC;
    Flags: Cardinal;
    FlagsFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMPrintClient = TWMPrint;

  PGestureNotifyStruct = pointer;

  TWMGestureNotify = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    NotifyStruct: PGestureNotifyStruct;
    Result: LRESULT;
  end;

// Utility functions to simplify .NET/Win32 single code source

{$IFNDEF UNICODE}
function SendTextMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; LParam: AnsiString): LRESULT; overload;
{$ENDIF}
function SendTextMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; LParam: UnicodeString): LRESULT; overload;
function SendStructMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; const LParam): LRESULT;
function SendGetStructMessage(Handle: HWND; Msg: UINT; WParam: WPARAM;
  var LParam; Unused: Boolean = False): LRESULT;
function SendGetIntMessage(Handle: HWND; Msg: UINT; var WParam: Integer;
  var LParam: Integer): LRESULT;

implementation

{$IFNDEF UNICODE}
function SendTextMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; LParam: AnsiString): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(PAnsiChar(LParam)));
end;
{$ENDIF}

function SendTextMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; LParam: UnicodeString): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(PWideChar(LParam)));
end;

function SendStructMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; const LParam): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(@LParam));
end;

function SendGetStructMessage(Handle: HWND; Msg: UINT; WParam: WPARAM;
  var LParam; Unused: Boolean = False): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(@LParam));
end;

function SendGetIntMessage(Handle: HWND; Msg: UINT; var WParam: Integer;
  var LParam: Integer): LRESULT;
begin
  Result := SendMessage(Handle, Msg, Windows.WPARAM(@WParam), Windows.LPARAM(@LParam));
end;

end.

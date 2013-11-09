{$I Defines.inc}

{*******************************************************}
{                                                       }
{       Borland Delphi Runtime Library                  }
{       Windows Messages and Types                      }
{                                                       }
{       Copyright (C) 1991,99 Inprise Corporation       }
{                                                       }
{*******************************************************}

unit Messages;

{$Align On}
{$WEAKPACKAGEUNIT}

{$ifdef bFreePascal}
 {$PACKRECORDS C}
{$endif bFreePascal}


interface

uses Windows;

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

  WM_KEYFIRST         = $0100;
  WM_KEYDOWN          = $0100;
  WM_KEYUP            = $0101;
  WM_CHAR             = $0102;
  WM_DEADCHAR         = $0103;
  WM_SYSKEYDOWN       = $0104;
  WM_SYSKEYUP         = $0105;
  WM_SYSCHAR          = $0106;
  WM_SYSDEADCHAR      = $0107;
  WM_KEYLAST          = $0108;

  WM_INITDIALOG       = $0110;
  WM_COMMAND          = $0111;
  WM_SYSCOMMAND       = $0112;
  WM_TIMER            = $0113;
  WM_HSCROLL          = $0114;
  WM_VSCROLL          = $0115;
  WM_INITMENU         = $0116;
  WM_INITMENUPOPUP    = $0117;
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
  WM_MOUSELAST        = $020A;

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

  WM_MOUSEHOVER       = $02A1;
  WM_MOUSELEAVE       = $02A3;

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
  LB_MSGMAX               = 432;

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
  CB_MSGMAX                = 354;

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

{ Dialog messages }

  DM_GETDEFID = (WM_USER+0);
  DM_SETDEFID = (WM_USER+1);
  DM_REPOSITION = (WM_USER+2);

  PSM_PAGEINFO = (WM_USER+100);
  PSM_SHEETINFO = (WM_USER+101);

type

{ Generic window message record }

 {$ifdef b64}
  HALFLRESULT = DWORD;
  HALFPARAM = DWORD;
  HALFPARAMBOOL = LONGBOOL;
 {$else}
  HALFLRESULT = WORD;
  HALFPARAM = WORD;
  HALFPARAMBOOL = WORDBOOL;
 {$endif b64}


  PMessage = ^TMessage;
  TMessage = record
    msg  :UINT;
    case longint of
      0: (
        wParam :WPARAM;
        lParam :LPARAM;
        Result :LRESULT;
       );
      1: (
        wParamlo, wParamhi : HALFPARAM;
        lParamlo, lParamhi : HALFPARAM;
        Resultlo, Resulthi : HALFLRESULT;
      );
   end;

{ Common message format records }

   TWMNoParams = record
     Msg : UINT;
     Unused : array[0..3] of HALFPARAM;
     Result : LRESULT;
   end;

  TWMKey = record
    Msg: UINT;
    CharCode: Word;
    Unused: Word;
    KeyData: Longint;
    Result: LRESULT;
  end;

  TWMMouse = record
    Msg :Cardinal;
    Keys :WPARAM;
    case Integer of
      0: (
        XPos :Smallint;
        YPos :Smallint);
      1: (
        Pos :TSmallPoint;
        Result :LRESULT);
  end;

  TWMMouseWheel = packed record
    Msg: Cardinal;
    Keys: SmallInt;
    WheelDelta: SmallInt;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint);
      1: (
        Pos: TSmallPoint;
        Result: Longint);
  end;

  TMSHMouseWheel = packed record
    Msg: Cardinal;
    WheelDelta: Integer;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint);
      1: (
        Pos: TSmallPoint;
        Result: Longint);
  end;

  TWMWindowPosMsg = packed record
    Msg: Cardinal;
    Unused: Integer;
    WindowPos: PWindowPos;
    Result: Longint;
  end;

  TWMScroll = packed record
    Msg: Cardinal;
    ScrollCode: Smallint; { SB_xxxx }
    Pos: Smallint;
    ScrollBar: HWND;
    Result: Longint;
  end;

{ Message records }

  TWMActivate = packed record
    Msg: Cardinal;
    Active: Word; { WA_INACTIVE, WA_ACTIVE, WA_CLICKACTIVE }
    Minimized: WordBool;
    ActiveWindow: HWND;
    Result: Longint;
  end;

  TWMActivateApp = packed record
    Msg: Cardinal;
    Active: BOOL;
    ThreadId: Longint;
    Result: Longint;
  end;

  TWMAskCBFormatName = packed record
    Msg: Cardinal;
    NameLen: Word;
    Unused: Word;
    FormatName: PChar;
    Result: Longint;
  end;

  TWMCancelMode = TWMNoParams;

  TWMChangeCBChain = packed record
    Msg: Cardinal;
    Remove: HWND;
    Next: HWND;
    Result: Longint;
  end;

  TWMChar = TWMKey;

  TWMCharToItem = packed record
    Msg: Cardinal;
    Key: Word;
    CaretPos: Word;
    ListBox: HWND;
    Result: Longint;
  end;

  TWMChildActivate = TWMNoParams;

  TWMChooseFont_GetLogFont = packed record
    Msg: Cardinal;
    Unused: Longint;
    LogFont: PLogFont;
    Result: Longint;
  end;

  TWMClear = TWMNoParams;
  TWMClose = TWMNoParams;

  TWMCommand = record
    Msg :Cardinal;
    case Integer of
      0: (
        ItemID :Word;
        NotifyCode :Word);
      1: (
        wParam :WPARAM;
        Ctl :HWND;
        Result :LRESULT);
  end;
(*
  TWMCommand = record
    Msg :Cardinal;
    ItemID :Word;
    NotifyCode :Word;
    Ctl :HWND;
    Result :LRESULT;
  end;
*)

  TWMCompacting = packed record
    Msg: Cardinal;
    CompactRatio: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMCompareItem = packed record
    Msg: Cardinal;
    Ctl: HWnd;
    CompareItemStruct: PCompareItemStruct;
    Result: Longint;
  end;

  TWMCopy = TWMNoParams;

  TWMCopyData = packed record
    Msg: Cardinal;
    From: HWND;
    CopyDataStruct: PCopyDataStruct;
    Result: Longint;
  end;

  { ?? WM_CLP_LAUNCH, WM_CPL_LAUNCHED }

  TWMCreate = record
    Msg :Cardinal;
    Unused :WPARAM;
    CreateStruct: PCreateStruct;
    Result :LRESULT;
  end;

  TWMCtlColor = record
    Msg :Cardinal;
    ChildDC :HDC;
    ChildWnd :HWND;
    Result :LRESULT;
  end;

  TWMCtlColorBtn = TWMCtlColor;
  TWMCtlColorDlg = TWMCtlColor;
  TWMCtlColorEdit = TWMCtlColor;
  TWMCtlColorListbox = TWMCtlColor;
  TWMCtlColorMsgbox = TWMCtlColor;
  TWMCtlColorScrollbar = TWMCtlColor;
  TWMCtlColorStatic = TWMCtlColor;

  TWMCut = TWMNoParams;

  TWMDDE_Ack = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    case Word of
      WM_DDE_INITIATE: (
        App: Word;
        Topic: Word;
        Result: Longint);
      WM_DDE_EXECUTE {and all others}: (
        PackedVal: Longint);
  end;

  TWMDDE_Advise = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    PackedVal: Longint;
    Result: Longint;
  end;

  TWMDDE_Data = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    PackedVal: Longint;
    Result: Longint;
  end;

  TWMDDE_Execute = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    Commands: THandle;
    Result: Longint;
  end;

  TWMDDE_Initiate = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    App: Word;
    Topic: Word;
    Result: Longint;
  end;

  TWMDDE_Poke = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    PackedVal: Longint;
    Result: Longint;
  end;

  TWMDDE_Request = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    Format: Word;
    Item: Word;
    Result: Longint;
  end;

  TWMDDE_Terminate = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMDDE_Unadvise = packed record
    Msg: Cardinal;
    PostingApp: HWND;
    Format: Word;
    Item: Word;
    Result: Longint;
  end;

  TWMDeadChar = TWMChar;

  TWMDeleteItem = packed record
    Msg: Cardinal;
    Ctl: HWND;
    DeleteItemStruct: PDeleteItemStruct;
    Result: Longint;
  end;

  TWMDestroy = TWMNoParams;
  TWMDestroyClipboard = TWMNoParams;

  TWMDevModeChange = packed record
    Msg: Cardinal;
    Unused: Integer;
    Device: PChar;
    Result: Longint;
  end;

  TWMDrawClipboard = TWMNoParams;

  TWMDrawItem = packed record
    Msg: Cardinal;
    Ctl: HWND;
    DrawItemStruct: PDrawItemStruct;
    Result: Longint;
  end;

  TWMDropFiles = packed record
    Msg: Cardinal;
    Drop: THANDLE;
    Unused: Longint;
    Result: Longint;
  end;

  TWMEnable = packed record
    Msg: Cardinal;
    Enabled: LongBool;
    Unused: Longint;
    Result: Longint;
  end;

  TWMEndSession = packed record
    Msg: Cardinal;
    EndSession: LongBool;
    Unused: Longint;
    Result: Longint;
  end;

  TWMEnterIdle = packed record
    Msg: Cardinal;
    Source: Longint; { MSGF_DIALOGBOX, MSGF_MENU }
    IdleWnd: HWND;
    Result: Longint;
  end;

  TWMEnterMenuLoop = packed record
    Msg: Cardinal;
    IsTrackPopupMenu: LongBool;
    Unused: Longint;
    Result: Longint;
  end;

  TWMExitMenuLoop = TWMEnterMenuLoop;

  TWMEraseBkgnd = record
    Msg :UINT;
    DC :HDC;
    Unused :LPARAM;
    Result :LRESULT;
  end;

  TWMFontChange = TWMNoParams;
  TWMGetDlgCode = TWMNoParams;
  TWMGetFont = TWMNoParams;

  TWMGetIcon = packed record
    Msg: Cardinal;
    BigIcon: Longbool;
    Unused: Longint;
    Result: Longint;
  end;

  TWMGetHotKey = TWMNoParams;

  TWMGetMinMaxInfo = packed record
    Msg: Cardinal;
    Unused: Integer;
    MinMaxInfo: PMinMaxInfo;
    Result: Longint;
  end;

  TWMGetText = packed record
    Msg: Cardinal;
    TextMax: Integer;
    Text: PChar;
    Result: Longint;
  end;

  TWMGetTextLength = TWMNoParams;

  TWMHotKey = packed record
    Msg: Cardinal;
    HotKey: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMHScroll = TWMScroll;

  TWMHScrollClipboard = packed record
    Msg: Cardinal;
    Viewer: HWND;
    ScrollCode: Word; {SB_BOTTOM, SB_ENDSCROLL, SB_LINEDOWN, SB_LINEUP,
                       SB_PAGEDOWN, SB_PAGEUP, SB_THUMBPOSITION,
                       SB_THUMBTRACK, SB_TOP }
    Pos: Word;
    Result: Longint;
  end;

  TWMIconEraseBkgnd = TWMEraseBkgnd;

  TWMInitDialog = packed record
    Msg: Cardinal;
    Focus: HWND;
    InitParam: Longint;
    Result: Longint;
  end;

  TWMInitMenu = packed record
    Msg: Cardinal;
    Menu: HMENU;
    Unused: Longint;
    Result: Longint;
  end;

  TWMInitMenuPopup = packed record
    Msg: Cardinal;
    MenuPopup: HMENU;
    Pos: Smallint;
    SystemMenu: WordBool;
    Result: Longint;
  end;

  TWMKeyDown = TWMKey;
  TWMKeyUp = TWMKey;

  TWMKillFocus = packed record
    Msg: Cardinal;
    FocusedWnd: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMLButtonDblClk = TWMMouse;
  TWMLButtonDown   = TWMMouse;
  TWMLButtonUp     = TWMMouse;
  TWMMButtonDblClk = TWMMouse;
  TWMMButtonDown   = TWMMouse;
  TWMMButtonUp     = TWMMouse;

  TWMMDIActivate = packed record
    Msg: Cardinal;
    case Integer of
      0: (
        ChildWnd: HWND);
      1: (
        DeactiveWnd: HWND;
        ActiveWnd: HWND;
        Result: Longint);
  end;

  TWMMDICascade = packed record
    Msg: Cardinal;
    Cascade: Longint; { 0, MDITILE_SKIPDISABLED }
    Unused: Longint;
    Result: Longint;
  end;

  TWMMDICreate = packed record
    Msg: Cardinal;
    Unused: Integer;
    MDICreateStruct: PMDICreateStruct;
    Result: Longint;
  end;

  TWMMDIDestroy = packed record
    Msg: Cardinal;
    Child: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMMDIGetActive = TWMNoParams;
  TWMMDIIconArrange = TWMNoParams;

  TWMMDIMaximize = packed record
    Msg: Cardinal;
    Maximize: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMMDINext = packed record
    Msg: Cardinal;
    Child: HWND;
    Next: Longint;
    Result: Longint;
  end;

  TWMMDIRefreshMenu = TWMNoParams;

  TWMMDIRestore = packed record
    Msg: Cardinal;
    IDChild: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMMDISetMenu = packed record
    Msg: Cardinal;
    MenuFrame: HMENU;
    MenuWindow: HMENU;
    Result: Longint;
  end;

  TWMMDITile = packed record
    Msg: Cardinal;
    Tile: Longint; { MDITILE_HORIZONTAL, MDITILE_SKIPDISABLE,
                     MDITILE_VERTICAL }
    Unused: Longint;
    Result: Longint;
  end;

  TWMMeasureItem = packed record
    Msg: Cardinal;
    IDCtl: HWnd;
    MeasureItemStruct: PMeasureItemStruct;
    Result: Longint;
  end;

  TWMMenuChar = packed record
    Msg :Cardinal;
   {$ifdef bUnicode}
    User :WideChar;
   {$else}
    User :AnsiChar;
    Unused :Byte;
   {$endif bUnicode}
    MenuFlag: Word; { MF_POPUP, MF_SYSMENU }
    Menu :HMENU;
    Result :Longint;
  end;

  TWMMenuSelect = packed record
    Msg: Cardinal;
    IDItem: Word;
    MenuFlag: Word; { MF_BITMAP, MF_CHECKED, MF_DISABLED, MF_GRAYED,
                      MF_MOUSESELECT, MF_OWNERDRAW, MF_POPUP, MF_SEPARATOR,
                      MF_SYSMENU }
    Menu: HMENU;
    Result: Longint;
  end;

  TWMMouseActivate = {packed} record
    Msg :Cardinal;
    TopLevel :HWND;
    HitTestCode :Word;
    MouseMsg :Word;
    Result :LRESULT;
  end;

  TWMMouseMove = TWMMouse;

  TWMMove = packed record
    Msg: Cardinal;
    Unused: Integer;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint);
      1: (
        Pos: TSmallPoint;
        Result: Longint);
  end;

  TWMNCActivate = packed record
    Msg: Cardinal;
    Active: BOOL;
    Unused: Longint;
    Result: Longint;
  end;

  TWMNCCalcSize = packed record
    Msg: Cardinal;
    CalcValidRects: BOOL;
    CalcSize_Params: PNCCalcSizeParams;
    Result: Longint;
  end;

  TWMNCCreate = packed record
    Msg: Cardinal;
    Unused: Integer;
    CreateStruct: PCreateStruct;
    Result: Longint;
  end;

  TWMNCDestroy = TWMNoParams;

  TWMNCHitTest = record
    Msg :UINT;
    Unused :LPARAM;
    case Integer of
      0: (
        XPos :Smallint;
        YPos :Smallint);
      1: (
        Pos :TSmallPoint;
        Result :LRESULT);
  end;

  TWMNCHitMessage = packed record
    Msg: Cardinal;
    HitTest: Longint;
    XCursor: Smallint;
    YCursor: Smallint;
    Result: Longint;
  end;

  TWMNCLButtonDblClk = TWMNCHitMessage;
  TWMNCLButtonDown   = TWMNCHitMessage;
  TWMNCLButtonUp     = TWMNCHitMessage;
  TWMNCMButtonDblClk = TWMNCHitMessage;
  TWMNCMButtonDown   = TWMNCHitMessage;
  TWMNCMButtonUp     = TWMNCHitMessage;
  TWMNCMouseMove     = TWMNCHitMessage;

  TWMNCPaint = TWMNoParams;

  TWMNCRButtonDblClk = TWMNCHitMessage;
  TWMNCRButtonDown   = TWMNCHitMessage;
  TWMNCRButtonUp     = TWMNCHitMessage;

  TWMNextDlgCtl = packed record
    Msg: Cardinal;
    CtlFocus: Longint;
    Handle: WordBool;
    Unused: Word;
    Result: Longint;
  end;

  TWMNotify = packed record
    Msg: Cardinal;
    IDCtrl: Longint;
    NMHdr: PNMHdr;
    Result: Longint;
  end;

  TWMNotifyFormat = packed record
    Msg: Cardinal;
    From: HWND;
    Command: Longint;
    Result: Longint;
  end;

  TWMPaint = record
    Msg :UINT;
    DC :HDC;
    Unused :LPARAM;
    Result :LRESULT;
  end;

  TWMPaintClipboard = packed record
    Msg: Cardinal;
    Viewer: HWND;
    PaintStruct: THandle;
    Result: Longint;
  end;

  TWMPaintIcon = TWMNoParams;

  TWMPaletteChanged = packed record
    Msg: Cardinal;
    PalChg: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMPaletteIsChanging = packed record
    Msg: Cardinal;
    Realize: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMParentNotify = packed record
    Msg: Cardinal;
    case Event: Word of
      WM_CREATE, WM_DESTROY: (
        ChildID: Word;
        ChildWnd: HWnd);
      WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN: (
        Value: Word;
        XPos: Smallint;
        YPos: Smallint);
      0: (
        Value1: Word;
        Value2: Longint;
        Result: Longint);
  end;

  TWMPaste = TWMNoParams;

  TWMPower = packed record
    Msg: Cardinal;
    PowerEvt: Longint; { PWR_SUSPENDREQUEST, PWR_SUSPENDRESUME,
                         PWR_CRITICALRESUME }
    Unused: Longint;
    Result: Longint;
  end;

  TWMQueryDragIcon = TWMNoParams;

  TWMQueryEndSession = packed record
    Msg: Cardinal;
    Source: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMQueryNewPalette = TWMNoParams;
  TWMQueryOpen = TWMNoParams;
  TWMQueueSync = TWMNoParams;

  TWMQuit = packed record
    Msg: Cardinal;
    ExitCode: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMRButtonDblClk = TWMMouse;
  TWMRButtonDown = TWMMouse;
  TWMRButtonUp = TWMMouse;

  TWMRenderAllFormats = TWMNoParams;

  TWMRenderFormat = packed record
    Msg: Cardinal;
    Format: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMSetCursor = packed record
    Msg: Cardinal;
    CursorWnd: HWND;
    HitTest: Word;
    MouseMsg: Word;
    Result: Longint;
  end;

  TWMSetFocus = packed record
    Msg: Cardinal;
    FocusedWnd: HWND;
    Unused: Longint;
    Result: Longint;
  end;

  TWMSetFont = packed record
    Msg: Cardinal;
    Font: HFONT;
    Redraw: WordBool;
    Unused: Word;
    Result: Longint;
  end;

  TWMSetHotKey = packed record
    Msg: Cardinal;
    Key: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMSetIcon = packed record
    Msg: Cardinal;
    BigIcon: Longbool;
    Icon: HICON;
    Result: Longint;
  end;

  TWMSetRedraw = packed record
    Msg: Cardinal;
    Redraw: Longint;
    Unused: Longint;
    Result: Longint;
  end;

  TWMSetText = packed record
    Msg: Cardinal;
    Unused: Longint;
    Text: PChar;
    Result: Longint;
  end;

  TWMShowWindow = packed record
    Msg: Cardinal;
    Show: BOOL;
    Status: Longint;
    Result: Longint;
  end;

  TWMSize = packed record
    Msg: Cardinal;
    SizeType: Longint; { SIZE_MAXIMIZED, SIZE_MINIMIZED, SIZE_RESTORED,
                         SIZE_MAXHIDE, SIZE_MAXSHOW }
    Width: Word;
    Height: Word;
    Result: Longint;
  end;

  TWMSizeClipboard = packed record
    Msg: Cardinal;
    Viewer: HWND;
    RC: THandle;
    Result: Longint;
  end;

  TWMSpoolerStatus = packed record
    Msg: Cardinal;
    JobStatus: Longint;
    JobsLeft: Word;
    Unused: Word;
    Result: Longint;
  end;

  TWMStyleChange = packed record
    Msg: Cardinal;
    StyleType: Longint;
    StyleStruct: PStyleStruct;
    Result: Longint;
  end;

  TWMStyleChanged = TWMStyleChange;
  TWMStyleChanging = TWMStyleChange;

  TWMSysChar = TWMKey;
  TWMSysColorChange = TWMNoParams;

  TWMSysCommand = packed record
    Msg: Cardinal;
    case CmdType: Longint of
      SC_HOTKEY: (
        ActivateWnd: HWND);
      SC_KEYMENU: (
        Key: Word);
      SC_CLOSE, SC_HSCROLL, SC_MAXIMIZE, SC_MINIMIZE, SC_MOUSEMENU, SC_MOVE,
      SC_NEXTWINDOW, SC_PREVWINDOW, SC_RESTORE, SC_SCREENSAVE, SC_SIZE,
      SC_TASKLIST, SC_VSCROLL: (
        XPos: Smallint;
        YPos: Smallint;
        Result: Longint);
  end;

  TWMSysDeadChar = packed record
    Msg: Cardinal;
    CharCode: Word;
    Unused: Word;
    KeyData: Longint;
    Result: Longint;
  end;

  TWMSysKeyDown = TWMKey;
  TWMSysKeyUp = TWMKey;

  TWMSystemError = packed record
    Msg: Cardinal;
    ErrSpec: Word;
    Unused: Longint;
    Result: Longint;
  end;

  TWMTimeChange = TWMNoParams;

  TWMTimer = packed record
    Msg: Cardinal;
    TimerID: Longint;
    TimerProc: TFarProc;
    Result: Longint;
  end;

  TWMUIState = packed record
    Msg: Cardinal;
    Action: Word;
    Flags: Word;
    Unused: Longint;
  end;

  TWMChangeUIState = TWMUIState;
  TWMUpdateUIState = TWMUIState;
  TWMQueryUIState = TWMNoParams;

  TWMUndo = TWMNoParams;

  TWMVKeyToItem = TWMCharToItem;

  TWMVScroll = TWMScroll;

  TWMVScrollClipboard = packed record
    Msg: Cardinal;
    Viewer: HWND;
    ScollCode: Word;
    ThumbPos: Word;
    Result: Longint;
  end;

  TWMWindowPosChanged = TWMWindowPosMsg;
  TWMWindowPosChanging = TWMWindowPosMsg;

  TWMWinIniChange = packed record
    Msg: Cardinal;
    Unused: Integer;
    Section: PChar;
    Result: Longint;
  end;

  TWMSettingChange = packed record
    Msg: Cardinal;
    Flag: Integer;
    Section: PChar;
    Result: Longint;
  end;

  TWMHelp = packed record
    Msg: Cardinal;
    Unused: Integer;
    HelpInfo: PHelpInfo;
    Result: Longint;
  end;

  TWMDisplayChange = packed record
    Msg: Cardinal;
    BitsPerPixel: Integer;
    Width: Word;
    Height: Word;
    Result: Longint;
  end;

  TWMContextMenu = packed record
    Msg: Cardinal;
    hWnd: HWND;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint);
      1: (
        Pos: TSmallPoint;
        Result: Longint);
  end;

implementation

end.

{
  PluginW.pas

  Plugin API for FAR Manager <%VERSION%>
}

{
Copyright (c) 1996 Eugene Roshal
Copyright (c) 2000 Far Group
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the authors may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

EXCEPTION:
Far Manager plugins that use this header file can be distributed under any
other possible license with no implications from the above license on them.
}

{$ifndef Far3}
 Use PluginW!
{$endif Far3}

{$Align On}
{$RangeChecks Off}

{$ifdef FPC}
 {$PACKRECORDS C}
{$endif FPC}

Unit Plugin3;

interface

uses Windows;

const
  FARMANAGERVERSION_MAJOR = 3;
  FARMANAGERVERSION_MINOR = 0;
  FARMANAGERVERSION_REVISION = 0;
  FARMANAGERVERSION_BUILD = 2250;

type
//TFarChar = AnsiChar;
//PFarChar = PAnsiChar;

  TFarChar = WideChar;
  PFarChar = PWideChar;

 {$ifdef CPUX86_64}
  INT_PTR = PtrInt;
  LONG_PTR = PtrInt;
  DWORD_PTR = PtrUInt;
  SIZE_T = PtrUInt;
 {$else}
 {$ifdef Win64}
  INT_PTR = IntPtr;
  LONG_PTR = IntPtr;
  DWORD_PTR = UIntPtr;
  SIZE_T = UIntPtr;
 {$else}
  INT_PTR = Integer;
  LONG_PTR = Integer;
  DWORD_PTR = Cardinal;
  SIZE_T = Cardinal;
 {$endif CPUX86_64}
 {$endif Win64}

  PPCharArray = ^TPCharArray;
  TPCharArray = packed array[0..MaxInt div SizeOf(PFarChar) - 1] of PFarChar;

  PIntegerArray = ^TIntegerArray;
  TIntegerArray = packed array[0..Pred(MaxLongint div SizeOf(Integer))] of Integer;

  PGuidsArray = ^TGuidsArray;
  TGuidsArray = packed array[0..Pred(MaxLongint div SizeOf(TGUID))] of TGUID;

const
  FARMACRO_KEY_EVENT = KEY_EVENT or $8000;

  CP_UNICODE    = 1200;
  CP_REVERSEBOM = 1201;
  CP_AUTODETECT = UINT(-1);
  CP_REDETECT   = UINT(-2);


{FARCOLORFLAGS}

type
  TFARCOLORFLAGS = Int64;

const
  FCF_NONE          = 0;
  FCF_FG_4BIT       = $0000000000000001;
  FCF_BG_4BIT       = $0000000000000002;

  FCF_4BITMASK      = $0000000000000003; // FCF_FG_4BIT|FCF_BG_4BIT

  FCF_EXTENDEDFLAGS = $FFFFFFFFFFFFFFFC; // ~FCF_4BITMASK

  FCF_FG_BOLD       = $1000000000000000;
  FCF_FG_ITALIC     = $2000000000000000;
  FCF_FG_UNDERLINE  = $4000000000000000;
  FCF_STYLEMASK     = $7000000000000000; // FCF_FG_BOLD|FCF_FG_ITALIC|FCF_FG_UNDERLINE

(*
struct FarColor
{
  FARCOLORFLAGS Flags;
  COLORREF ForegroundColor;
  COLORREF BackgroundColor;
  void* Reserved;
};
*)
type
  PFarColor = ^TFarColor;
  TFarColor = record
    Flags :TFARCOLORFLAGS;
    ForegroundColor :COLORREF;
    BackgroundColor :COLORREF;
    Reserved :Pointer;
  end;

  PFarColorArray = ^TFarColorArray;
  TFarColorArray = packed array[0..MaxInt div SizeOf(TFarColor) - 1] of TFarColor;


(*
typedef BOOL (WINAPI *FARAPICOLORDIALOG)(
    const GUID* PluginId,
    COLORDIALOGFLAGS Flags,
    struct FarColor *Color
);
*)
{!!!}


{ FARMESSAGEFLAGS }

type
  TFarMessageFlags = Int64;

const
  FMSG_NONE                = 0;
  FMSG_WARNING             = $00000001;
  FMSG_ERRORTYPE           = $00000002;
  FMSG_KEEPBACKGROUND      = $00000004;
  FMSG_LEFTALIGN           = $00000008;
  FMSG_ALLINONE            = $00000010;

  FMSG_MB_OK               = $00010000;
  FMSG_MB_OKCANCEL         = $00020000;
  FMSG_MB_ABORTRETRYIGNORE = $00030000;
  FMSG_MB_YESNO            = $00040000;
  FMSG_MB_YESNOCANCEL      = $00050000;
  FMSG_MB_RETRYCANCEL      = $00060000;

(*
typedef int (WINAPI *FARAPIMESSAGE)(
    const GUID* PluginId,
    const GUID* Id,
    FARMESSAGEFLAGS Flags,
    const wchar_t *HelpTopic,
    const wchar_t * const *Items,
    size_t ItemsNumber,
    int ButtonsNumber
);
*)
type
  TFarApiMessage = function (
    const PluginId :TGUID;
    const Id :TGUID;
    Flags :TFarMessageFlags;
    HelpTopic :PFarChar;
    Items :PPCharArray;
    ItemsNumber :size_t;
    ButtonsNumber :Integer
  ) :Integer; stdcall;

  
{ FARDIALOGITEMTYPES }

const
  DI_TEXT         = 0;
  DI_VTEXT        = 1;
  DI_SINGLEBOX    = 2;
  DI_DOUBLEBOX    = 3;
  DI_EDIT         = 4;
  DI_PSWEDIT      = 5;
  DI_FIXEDIT      = 6;
  DI_BUTTON       = 7;
  DI_CHECKBOX     = 8;
  DI_RADIOBUTTON  = 9;
  DI_COMBOBOX     = 10;
  DI_LISTBOX      = 11;
  DI_USERCONTROL  = 255;


{ FARDIALOGITEMFLAGS }

const
  DIF_NONE                  = 0;
  DIF_BOXCOLOR              =  $00000200;
  DIF_GROUP                 =  $00000400;
  DIF_LEFTTEXT              =  $00000800;
  DIF_MOVESELECT            =  $00001000;
  DIF_SHOWAMPERSAND         =  $00002000;
  DIF_CENTERGROUP           =  $00004000;
  DIF_NOBRACKETS            =  $00008000;
  DIF_MANUALADDHISTORY      =  $00008000;
  DIF_SEPARATOR             =  $00010000;
  DIF_SEPARATOR2            =  $00020000;
  DIF_EDITOR                =  $00020000;
  DIF_LISTNOAMPERSAND       =  $00020000;
  DIF_LISTNOBOX             =  $00040000;
  DIF_HISTORY               =  $00040000;
  DIF_BTNNOCLOSE            =  $00040000;
  DIF_CENTERTEXT            =  $00040000;
  DIF_SETSHIELD             =  $00080000;
  DIF_EDITEXPAND            =  $00080000;
  DIF_DROPDOWNLIST          =  $00100000;
  DIF_USELASTHISTORY        =  $00200000;
  DIF_MASKEDIT              =  $00400000;
  DIF_LISTTRACKMOUSE        =  $00400000;
  DIF_LISTTRACKMOUSEINFOCUS =  $00800000;
  DIF_SELECTONENTRY         =  $00800000;
  DIF_3STATE                =  $00800000;
  DIF_EDITPATH              =  $01000000;
  DIF_LISTWRAPMODE          =  $01000000;
  DIF_NOAUTOCOMPLETE        =  $02000000;
  DIF_LISTAUTOHIGHLIGHT     =  $02000000;
  DIF_LISTNOCLOSE           =  $04000000;
  DIF_HIDDEN                =  $10000000;
  DIF_READONLY              =  $20000000;
  DIF_NOFOCUS               =  $40000000;
  DIF_DISABLE               =  $80000000;
  DIF_DEFAULTBUTTON         = $100000000;
  DIF_FOCUS                 = $200000000;


{ FARMESSAGE }

const
  DM_FIRST                = 0;
  DM_CLOSE                = 1;
  DM_ENABLE               = 2;
  DM_ENABLEREDRAW         = 3;
  DM_GETDLGDATA           = 4;
  DM_GETDLGITEM           = 5;
  DM_GETDLGRECT           = 6;
  DM_GETTEXT              = 7;
  DM_GETTEXTLENGTH        = 8;
  DM_KEY                  = 9;
  DM_MOVEDIALOG           = 10;
  DM_SETDLGDATA           = 11;
  DM_SETDLGITEM           = 12;
  DM_SETFOCUS             = 13;
  DM_REDRAW               = 14;
  DM_SETTEXT              = 15;
  DM_SETMAXTEXTLENGTH     = 16;
  DM_SHOWDIALOG           = 17;
  DM_GETFOCUS             = 18;
  DM_GETCURSORPOS         = 19;
  DM_SETCURSORPOS         = 20;
  DM_GETTEXTPTR           = 21;
  DM_SETTEXTPTR           = 22;
  DM_SHOWITEM             = 23;
  DM_ADDHISTORY           = 24;
  DM_GETCHECK             = 25;
  DM_SETCHECK             = 26;
  DM_SET3STATE            = 27;
  DM_LISTSORT             = 28;
  DM_LISTGETITEM          = 29;
  DM_LISTGETCURPOS        = 30;
  DM_LISTSETCURPOS        = 31;
  DM_LISTDELETE           = 32;
  DM_LISTADD              = 33;
  DM_LISTADDSTR           = 34;
  DM_LISTUPDATE           = 35;
  DM_LISTINSERT           = 36;
  DM_LISTFINDSTRING       = 37;
  DM_LISTINFO             = 38;
  DM_LISTGETDATA          = 39;
  DM_LISTSETDATA          = 40;
  DM_LISTSETTITLES        = 41;
  DM_LISTGETTITLES        = 42;
  DM_RESIZEDIALOG         = 43;
  DM_SETITEMPOSITION      = 44;
  DM_GETDROPDOWNOPENED    = 45;
  DM_SETDROPDOWNOPENED    = 46;
  DM_SETHISTORY           = 47;
  DM_GETITEMPOSITION      = 48;
  DM_SETMOUSEEVENTNOTIFY  = 49;
  DM_EDITUNCHANGEDFLAG    = 50;
  DM_GETITEMDATA          = 51;
  DM_SETITEMDATA          = 52;
  DM_LISTSET              = 53;
  DM_GETCURSORSIZE        = 54;
  DM_SETCURSORSIZE        = 55;
  DM_LISTGETDATASIZE      = 56;
  DM_GETSELECTION         = 57;
  DM_SETSELECTION         = 58;
  DM_GETEDITPOSITION      = 59;
  DM_SETEDITPOSITION      = 60;
  DM_SETCOMBOBOXEVENT     = 61;
  DM_GETCOMBOBOXEVENT     = 62;
  DM_GETCONSTTEXTPTR      = 63;
  DM_GETDLGITEMSHORT      = 64;
  DM_SETDLGITEMSHORT      = 65;
  DM_GETDIALOGINFO        = 66;

  DN_FIRST                = 4096;
  DN_BTNCLICK             = 4097;
  DN_CTLCOLORDIALOG       = 4098;
  DN_CTLCOLORDLGITEM      = 4099;
  DN_CTLCOLORDLGLIST      = 4100;
  DN_DRAWDIALOG           = 4101;
  DN_DRAWDLGITEM          = 4102;
  DN_EDITCHANGE           = 4103;
  DN_ENTERIDLE            = 4104;
  DN_GOTFOCUS             = 4105;
  DN_HELP                 = 4106;
  DN_HOTKEY               = 4107;
  DN_INITDIALOG           = 4108;
  DN_KILLFOCUS            = 4109;
  DN_LISTCHANGE           = 4110;
  DN_DRAGGED              = 4111;
  DN_RESIZECONSOLE        = 4112;
  DN_DRAWDIALOGDONE       = 4113;
  DN_LISTHOTKEY           = 4114;
  DN_INPUT                = 4115;
  DN_CONTROLINPUT         = 4116;
  DN_CLOSE                = 4117;
  DN_GETVALUE             = 4118;

  DM_USER                 = $4000;


{ FARCHECKEDSTATE }

const
  BSTATE_UNCHECKED = 0;
  BSTATE_CHECKED   = 1;
  BSTATE_3STATE    = 2;
  BSTATE_TOGGLE    = 3;


          { FARLISTMOUSEREACTIONTYPE }

          const
            LMRT_ONLYFOCUS = 0;
            LMRT_ALWAYS    = 1;
            LMRT_NEVER     = 2;

          {FARCOMBOBOXEVENTTYPE}

          const
            CBET_KEY         = 1;
            CBET_MOUSE       = 2;


          {------------------------------------------------------------------------------}
          { List                                                                         }
          {------------------------------------------------------------------------------}

          { LISTITEMFLAGS }

          const
            LIF_SELECTED       = $00010000;
            LIF_CHECKED        = $00020000;
            LIF_SEPARATOR      = $00040000;
            LIF_DISABLE        = $00080000;
            LIF_GRAYED         = $00100000;
            LIF_HIDDEN         = $00200000;
            LIF_DELETEUSERDATA = $80000000;

          (*
          struct FarListItem
          {
            DWORD Flags;
            const wchar_t *Text;
            DWORD Reserved[3];
          };
          *)
          type
            PFarListItem = ^TFarListItem;
            TFarListItem = record
              Flags    :DWORD;
              TextPtr  :PFarChar;
              Reserved :array [0..2] of DWORD;
            end;

          type
            PFarListItemArray = ^TFarListItemArray;
            TFarListItemArray = packed array[0..MaxInt div SizeOf(TFarListItem) - 1] of TFarListItem;

          (*
          struct FarListUpdate
          {
            int Index;
            struct FarListItem Item;
          };
          *)
          type
            PFarListUpdate = ^TFarListUpdate;
            TFarListUpdate = record
              Index :Integer;
              Item :TFarListItem;
            end;

          (*
          struct FarListInsert
          {
            int Index;
            struct FarListItem Item;
          };
          *)
          type
            PFarListInsert = ^TFarListInsert;
            TFarListInsert = record
              Index :Integer;
              Item :TFarListItem;
            end;

          (*
          struct FarListGetItem
          {
            int ItemIndex;
            struct FarListItem Item;
          };
          *)
          type
            PFarListGetItem = ^TFarListGetItem;
            TFarListGetItem = record
              ItemIndex :Integer;
              Item :TFarListItem;
            end;

          (*
          struct FarListPos
          {
            int SelectPos;
            int TopPos;
          };
          *)
          type
            PFarListPos = ^TFarListPos;
            TFarListPos = record
              SelectPos : Integer;
              TopPos : Integer;
            end;

          { FARLISTFINDFLAGS }

          const
             LIFIND_EXACTMATCH = $00000001;

          (*
          struct FarListFind
          {
            int StartIndex;
            const wchar_t *Pattern;
            DWORD Flags;
            DWORD Reserved;
          };
          *)
          type
            PFarListFind = ^TFarListFind;
            TFarListFind = record
              StartIndex : Integer;
              Pattern : PFarChar;
              Flags : DWORD;
              Reserved : DWORD;
            end;

          (*
          struct FarListDelete
          {
            int StartIndex;
            int Count;
          };
          *)
          type
            PFarListDelete = ^TFarListDelete;
            TFarListDelete = record
              StartIndex : Integer;
              Count : Integer;
            end;

          { FARLISTINFOFLAGS }

          const
            LINFO_SHOWNOBOX         = $00000400;
            LINFO_AUTOHIGHLIGHT     = $00000800;
            LINFO_REVERSEHIGHLIGHT  = $00001000;
            LINFO_WRAPMODE          = $00008000;
            LINFO_SHOWAMPERSAND     = $00010000;

          (*
          struct FarListInfo
          {
            DWORD Flags;
            int ItemsNumber;
            int SelectPos;
            int TopPos;
            int MaxHeight;
            int MaxLength;
            DWORD Reserved[6];
          };
          *)
          type
            PFarListInfo = ^TFarListInfo;
            TFarListInfo = record
              Flags :DWORD;
              ItemsNumber :Integer;
              SelectPos :Integer;
              TopPos :Integer;
              MaxHeight :Integer;
              MaxLength :Integer;
              Reserved :array [0..5] of DWORD;
           end;

          (*
          struct FarListItemData
          {
            int   Index;
            int   DataSize;
            void *Data;
            DWORD Reserved;
          };
          *)
          type
            PFarListItemData = ^TFarListItemData;
            TFarListItemData = record
              Index :Integer;
              DataSize :Integer;
              Data :Pointer;
              Reserved :DWORD;
            end;

          (*
          struct FarList
          {
            int ItemsNumber;
            struct FarListItem *Items;
          };
          *)
          type
            PFarList = ^TFarList;
            TFarList = record
              ItemsNumber : Integer;
              Items :PFarListItemArray;
            end;

          (*
          struct FarListTitles
          {
            int   TitleLen;
            const wchar_t *Title;
            int   BottomLen;
            const wchar_t *Bottom;
          };
          *)
          type
            PFarListTitles = ^TFarListTitles;
            TFarListTitles = record
              TitleLen :Integer;
              Title :PFarChar;
              BottomLen :Integer;
              Bottom :PFarChar;
           end;


          (*
          struct FarDialogItemColors
          {
            unsigned __int64 Flags;
            size_t ColorsCount;
            struct FarColor* Colors;
            void* Reserved;
          };
          *)
          type
            PFarDialogItemColors = ^TFarDialogItemColors;
            TFarDialogItemColors = record
              Flags :Int64;
              ColorsCount :size_t;
              Colors :PFarColorArray;
              Reserved :Pointer;
            end;


          {------------------------------------------------------------------------------}
          { Dialogs                                                                      }
          {------------------------------------------------------------------------------}

          (*
          struct FarDialogItem
          {
            enum FARDIALOGITEMTYPES Type;
            int X1,Y1,X2,Y2;
            union
            {
                    int Selected;
                    struct FarList *ListItems;
                    struct FAR_CHAR_INFO *VBuf;
                    DWORD_PTR Reserved;
            }
            Param
            ;
            const wchar_t *History;
            const wchar_t *Mask;
            FARDIALOGITEMFLAGS Flags;
            const wchar_t *Data;
            size_t MaxLength; // terminate 0 not included (if == 0 string size is unlimited)
            DWORD_PTR UserData;
          };
          *)

          type
            PFarDialogItem = ^TFarDialogItem;
            TFarDialogItem = record
              ItemType :Integer; {FARDIALOGITEMTYPES}
              X1, Y1, X2, Y2 :Integer;

              Param : record case Integer of
                0 : (Selected :Integer);
                1 : (ListItems :PFarList);
                2 : (VBuf :PCharInfo);
              end;

              History :PFarChar;
              Mask :PFarChar;
              Flags :Int64; {FARDIALOGITEMFLAGS}
              Data :PFarChar;
              MaxLength :size_t;
              UserDate :DWORD_PTR;
            end;

          type
            PFarDialogItemArray = ^TFarDialogItemArray;
            TFarDialogItemArray = packed array[0..MaxInt div SizeOf(TFarDialogItem) - 1] of TFarDialogItem;

          (*
          struct FarDialogItemData
          {
            size_t  PtrLength;
            wchar_t *PtrData;
          };
          *)
          type
            PFarDialogItemData = ^TFarDialogItemData;
            TFarDialogItemData = record
              PtrLength :SIZE_T;
              PtrData :PFarChar;
            end;

(*
struct FarDialogEvent
{
	HANDLE hDlg;
	int Msg;
	int Param1;
	void* Param2;
	INT_PTR Result;
};
*)
type
  PFarDialogEvent = ^TFarDialogEvent;
  TFarDialogEvent = record
    hDlg :THandle;
    Msg :Integer;
    Param1 :Integer;
    Param2 :Pointer;
    Result :INT_PTR;
  end;

          (*
          struct OpenDlgPluginData
          {
            int ItemNumber;
            HANDLE hDlg;
          };
          *)
          type
            POpenDlgPluginData = ^TOpenDlgPluginData;
            TOpenDlgPluginData = record
              ItemNumber :Integer;
              hDlg :THandle;
            end;

(*
struct DialogInfo
{
	size_t StructSize;
	GUID Id;
	GUID Owner;
};
*)
type
  PDialogInfo = ^TDialogInfo;
  TDialogInfo = record
    StructSize :size_t;
    Id :TGUID;
    Owner :TGUID;
  end;

          { FARDIALOGFLAGS }

          const
            FDLG_NONE             = 0;
            FDLG_WARNING          = $00000001;
            FDLG_SMALLDIALOG      = $00000002;
            FDLG_NODRAWSHADOW     = $00000004;
            FDLG_NODRAWPANEL      = $00000008;
            FDLG_KEEPCONSOLETITLE = $00000010;

          type
          (*
          typedef LONG_PTR (WINAPI *FARWINDOWPROC)(
            HANDLE   hDlg,
            int      Msg,
            int      Param1,
            LONG_PTR Param2
          );
          *)
            TFarApiWindowProc = function (
              hDlg :THandle;
              Msg :Integer;
              Param1 :Integer;
              Param2 :LONG_PTR
            ) :LONG_PTR; stdcall;

          (*
          typedef INT_PTR(WINAPI *FARAPISENDDLGMESSAGE)(
              HANDLE   hDlg,
              int Msg,
              int      Param1,
              void* Param2
          );
          *)
            TFarApiSendDlgMessage = function (
              hDlg :THandle;
              Msg :Integer;
              Param1 :Integer;
              Param2 :Pointer
            ) :INT_PTR; stdcall;

          (*
          typedef LONG_PTR (WINAPI *FARAPIDEFDLGPROC)(
            HANDLE   hDlg,
            int      Msg,
            int      Param1,
            LONG_PTR Param2
          );
          *)
            TFarApiDefDlgProc = function (
              hDlg :THandle;
              Msg :Integer;
              Param1 :Integer;
              Param2 :LONG_PTR
            ) :LONG_PTR; stdcall;

          (*
          typedef HANDLE(WINAPI *FARAPIDIALOGINIT)(
              const GUID*           PluginId,
              const GUID*           Id,
              int                   X1,
              int                   Y1,
              int                   X2,
              int                   Y2,
              const wchar_t        *HelpTopic,
              const struct FarDialogItem *Item,
              size_t                ItemsNumber,
              DWORD_PTR             Reserved,
              FARDIALOGFLAGS        Flags,
              FARWINDOWPROC         DlgProc,
              void*                 Param
          );
          *)
            TFarApiDialogInit = function (
              const PluginID :TGUID;
              const ID :TGUID;
              X1, Y1, X2, Y2 :Integer;
              HelpTopic :PFarChar;
              Item :PFarDialogItemArray;
              ItemsNumber :size_t;
              Reserved :DWORD_PTR;
              Flags :Int64; {FARDIALOGFLAGS}
              DlgProc :TFarApiWindowProc;
              Param :LONG_PTR
            ) :THandle; stdcall;

          (*
          typedef int (WINAPI *FARAPIDIALOGRUN)(
            HANDLE hDlg
          );
          *)
            TFarApiDialogRun = function(
              hDlg :THandle
            ) :Integer;  stdcall;

          (*
          typedef void (WINAPI *FARAPIDIALOGFREE)(
            HANDLE hDlg
          );
          *)
            TFarApiDialogFree = procedure(
              hDlg :THandle
            ); stdcall;


{------------------------------------------------------------------------------}
{ Menu                                                                         }
{------------------------------------------------------------------------------}

(*
struct FarKey
{
    WORD VirtualKeyCode;
    DWORD ControlKeyState;
};
*)
type
  PFarKey = ^TFarKey;
  TFarKey = record
    VirtualKeyCode :WORD;
    ControlKeyState :DWORD;
  end;

{ MENUITEMFLAGS }

type
  TMenuItemFlags = Int64;

const
  MIF_NONE       = 0;
  MIF_SELECTED   = $00010000;
  MIF_CHECKED    = $00020000;
  MIF_SEPARATOR  = $00040000;
  MIF_DISABLE    = $00080000;
  MIF_GRAYED     = $00100000;
  MIF_HIDDEN     = $00200000;

(*
struct FarMenuItem
{
  MENUITEMFLAGS Flags;
  const wchar_t *Text;
  struct FarKey AccelKey;
  DWORD_PTR Reserved;
  DWORD_PTR UserData;
};
*)
type
  PFarMenuItem = ^TFarMenuItem;
  TFarMenuItem = record
    Flags :TMenuItemFlags;
    TextPtr :PFarChar;
    AccelKey :TFarKey;
    Reserved :DWORD_PTR;
    UserData :DWORD_PTR;
  end;

{ FARMENUFLAGS }

type
  TFarMenuFlags = Int64;

const
  FMENU_NONE                 = 0;
  FMENU_SHOWAMPERSAND        = $00000001;
  FMENU_WRAPMODE             = $00000002;
  FMENU_AUTOHIGHLIGHT        = $00000004;
  FMENU_REVERSEAUTOHIGHLIGHT = $00000008;
  FMENU_CHANGECONSOLETITLE   = $00000010;

type
  PFarMenuItemArray = ^TFarMenuItemArray;
  TFarMenuItemArray = packed array[0..MaxInt div SizeOf(TFarMenuItem) - 1] of TFarMenuItem;

(*
typedef int (WINAPI *FARAPIMENU)(
  const GUID*         PluginId,
  const GUID*         Id,
  int                 X,
  int                 Y,
  int                 MaxHeight,
  FARMENUFLAGS        Flags,
  const wchar_t      *Title,
  const wchar_t      *Bottom,
  const wchar_t      *HelpTopic,
  const struct FarKey *BreakKeys,
  int                *BreakCode,
  const struct FarMenuItem *Item,
  size_t              ItemsNumber
);
*)
type
  TFarApiMenu = function (
    const PluginId :TGUID;
    const ID :TGUID;
    X, Y : Integer;
    MaxHeight : Integer;
    Flags :TFARMENUFLAGS;
    Title :PFarChar;
    Bottom :PFarChar;
    HelpTopic :PFarChar;
    BreakKeys :PIntegerArray; {!!!}
    BreakCode :PIntegerArray;
    Item :PFarMenuItemArray;
    ItemsNumber :size_t
  ) : Integer; stdcall;


{------------------------------------------------------------------------------}
{ Panel                                                                        }
{------------------------------------------------------------------------------}

{ PLUGINPANELITEMFLAGS }

type
  TPluginPanelItemFlags = Int64;

const
  PPIF_NONE         = 0;
  PPIF_USERDATA     = $20000000;
  PPIF_SELECTED     = $40000000;
  PPIF_PROCESSDESCR = $80000000;

(*
struct PluginPanelItem
{
  FILETIME CreationTime;
  FILETIME LastAccessTime;
  FILETIME LastWriteTime;
  FILETIME ChangeTime;
  unsigned __int64 FileSize;
  unsigned __int64 PackSize;
  const wchar_t *FileName;
  const wchar_t *AlternateFileName;
  const wchar_t *Description;
  const wchar_t *Owner;
  const wchar_t * const *CustomColumnData;
  size_t CustomColumnNumber;
  PLUGINPANELITEMFLAGS Flags;
  DWORD_PTR UserData;
  DWORD FileAttributes;
  DWORD NumberOfLinks;
  DWORD CRC32;
  DWORD_PTR Reserved[2];
};
*)
type
  PPluginPanelItem = ^TPluginPanelItem;
  TPluginPanelItem = record
    CreationTime :FILETIME;
    LastAccessTime :FILETIME;
    LastWriteTime :FILETIME;
    ChangeTime :FILETIME;
    FileSize :Int64 ;
    PackSize :Int64 ;
    FileName :PFarChar;
    AlternateFileName :PFarChar;
    Description :PFarChar;
    Owner :PFarChar;
    CustomColumnData :PPCharArray;
    CustomColumnNumber :size_t;
    Flags :TPluginPanelItemFlags;
    UserData :DWORD_PTR;
    FileAttributes :DWORD;
    NumberOfLinks :DWORD;
    CRC32 :DWORD;
    Reserved : array [0..1] of DWORD_PTR;
  end;

  PPluginPanelItemArray = ^TPluginPanelItemArray;
  TPluginPanelItemArray = packed array[0..MaxInt div sizeof(TPluginPanelItem) - 1] of TPluginPanelItem;

(*
struct FarGetPluginPanelItem
{
  size_t Size;
  struct PluginPanelItem* Item;
};
*)
type
  PFarGetPluginPanelItem = ^TFarGetPluginPanelItem;
  TFarGetPluginPanelItem = record
    Size :size_t;
    Item :PPluginPanelItem;
  end;


{ PANELINFOFLAGS }

type
  TPANELINFOFLAGS = Int64;

const
  PFLAGS_NONE               = 0;
  PFLAGS_SHOWHIDDEN         = $00000001;
  PFLAGS_HIGHLIGHT          = $00000002;
  PFLAGS_REVERSESORTORDER   = $00000004;
  PFLAGS_USESORTGROUPS      = $00000008;
  PFLAGS_SELECTEDFIRST      = $00000010;
  PFLAGS_REALNAMES          = $00000020;
  PFLAGS_NUMERICSORT        = $00000040;
  PFLAGS_PANELLEFT          = $00000080;
  PFLAGS_DIRECTORIESFIRST   = $00000100;
  PFLAGS_USECRC32           = $00000200;
  PFLAGS_CASESENSITIVESORT  = $00000400;
  PFLAGS_PLUGIN             = $00000800;
  PFLAGS_VISIBLE            = $00001000;
  PFLAGS_FOCUS              = $00002000;
  PFLAGS_ALTERNATIVENAMES   = $00004000;


{ PANELINFOTYPE }

const
  PTYPE_FILEPANEL   = 0;
  PTYPE_TREEPANEL   = 1;
  PTYPE_QVIEWPANEL  = 2;
  PTYPE_INFOPANEL   = 3;


{ OPENPANELINFO_SORTMODES }

const
  SM_DEFAULT        =  0;
  SM_UNSORTED       =  1;
  SM_NAME           =  2;
  SM_EXT            =  3;
  SM_MTIME          =  4;
  SM_CTIME          =  5;
  SM_ATIME          =  6;
  SM_SIZE           =  7;
  SM_DESCR          =  8;
  SM_OWNER          =  9;
  SM_COMPRESSEDSIZE = 10;
  SM_NUMLINKS       = 11;
  SM_NUMSTREAMS     = 12;
  SM_STREAMSSIZE    = 13;
  SM_FULLNAME       = 14;
  SM_CHTIME         = 15;

(*
struct PanelInfo
{
  size_t StructSize;
  HANDLE PluginHandle;
  GUID OwnerGuid;
  PANELINFOFLAGS Flags;
  size_t ItemsNumber;
  size_t SelectedItemsNumber;
  RECT PanelRect;
  size_t CurrentItem;
  size_t TopPanelItem;
  int ViewMode;
  enum PANELINFOTYPE PanelType;
  enum OPENPANELINFO_SORTMODES SortMode;
  DWORD_PTR Reserved;
};
*)
type
  PPanelInfo = ^TPanelInfo;
  TPanelInfo = record
    StructSize :size_t;
    PluginHandle :THandle;
    OwnerGuid :TGUID;
    Flags :TPANELINFOFLAGS;
    ItemsNumber :size_t;
    SelectedItemsNumber :size_t;
    PanelRect : TRect;
    CurrentItem :size_t;
    TopPanelItem :size_t;
    ViewMode :Integer;
    PanelType :Integer; { PANELINFOTYPE }
    SortMode :Integer; { OPENPANELINFO_SORTMODES }
    Reserved :DWORD_PTR;
  end;

(*
struct PanelRedrawInfo
{
  size_t CurrentItem;
  size_t TopPanelItem;
};
*)
type
  PPanelRedrawInfo = ^TPanelRedrawInfo;
  TPanelRedrawInfo = record
    CurrentItem :size_t;
    TopPanelItem :size_t;
  end;


(*
struct CmdLineSelect
{
  int SelStart;
  int SelEnd;
};
*)
type
  PCmdLineSelect = ^TCmdLineSelect;
  TCmdLineSelect = record
    SelStart : Integer;
    SelEnd : Integer;
  end;

{------------------------------------------------------------------------------}
{                                                                              }
{------------------------------------------------------------------------------}

{ FILE_CONTROL_COMMANDS }

const
  PANEL_NONE	              = THandle(-1);
  PANEL_ACTIVE	              = THandle(-1);
  PANEL_PASSIVE	              = THandle(-2);

const
  FCTL_CLOSEPANEL             = 0;
  FCTL_GETPANELINFO           = 1;
  FCTL_UPDATEPANEL            = 2;
  FCTL_REDRAWPANEL            = 3;
  FCTL_GETCMDLINE             = 4;
  FCTL_SETCMDLINE             = 5;
  FCTL_SETSELECTION           = 6;
  FCTL_SETVIEWMODE            = 7;
  FCTL_INSERTCMDLINE          = 8;
  FCTL_SETUSERSCREEN          = 9;
  FCTL_SETPANELDIR            = 10;
  FCTL_SETCMDLINEPOS          = 11;
  FCTL_GETCMDLINEPOS          = 12;
  FCTL_SETSORTMODE            = 13;
  FCTL_SETSORTORDER           = 14;
  FCTL_SETCMDLINESELECTION    = 15;
  FCTL_GETCMDLINESELECTION    = 16;
  FCTL_CHECKPANELSEXIST       = 17;
  FCTL_SETNUMERICSORT         = 18;
  FCTL_GETUSERSCREEN          = 19;
  FCTL_ISACTIVEPANEL          = 20;
  FCTL_GETPANELITEM           = 21;
  FCTL_GETSELECTEDPANELITEM   = 22;
  FCTL_GETCURRENTPANELITEM    = 23;
  FCTL_GETPANELDIR            = 24;
  FCTL_GETCOLUMNTYPES         = 25;
  FCTL_GETCOLUMNWIDTHS        = 26;
  FCTL_BEGINSELECTION         = 27;
  FCTL_ENDSELECTION           = 28;
  FCTL_CLEARSELECTION         = 29;
  FCTL_SETDIRECTORIESFIRST    = 30;
  FCTL_GETPANELFORMAT         = 31;
  FCTL_GETPANELHOSTFILE       = 32;
  FCTL_SETCASESENSITIVESORT   = 33;
  FCTL_GETPANELPREFIX         = 34;

type
(*
typedef void (WINAPI *FARAPITEXT)(
  int X,
  int Y,
  const struct FarColor* Color,
  const wchar_t *Str
);
*)
  TFarApiText = procedure (
    X, Y : Integer;
    const Color :TFarColor;
    Str :PFarChar
   ); stdcall;


(*
typedef HANDLE (WINAPI *FARAPISAVESCREEN)(int X1, int Y1, int X2, int Y2);
*)
  TFarApiSaveScreen = function (
    X1, Y1, X2, Y2 : Integer
  ) :THandle; stdcall;

(*
typedef void (WINAPI *FARAPIRESTORESCREEN)(HANDLE hScreen);
*)
  TFarApiRestoreScreen = procedure (
     hScreen : THandle
  ); stdcall;


(*
typedef int (WINAPI *FARAPIGETDIRLIST)(
  const wchar_t *Dir,
  struct PluginPanelItem **pPanelItem,
  size_t *pItemsNumber
);
*)
  TFarApiGetDirList = function (
    Dir : PFarChar;
    var Items :PPluginPanelItemArray;
    var ItemsNumber :size_t
  ) :Integer; stdcall;

(*
typedef int (WINAPI *FARAPIGETPLUGINDIRLIST)(
    const GUID* PluginId,
    HANDLE hPanel,
    const wchar_t *Dir,
    struct PluginPanelItem **pPanelItem,
    size_t *pItemsNumber
);
*)
  TFarApiGetPluginDirList = function (
    PluginID :TGUID;
    hPlugin :THandle;
    Dir :PFarChar;
    var Items :PPluginPanelItemArray;
    var ItemsNumber :size_t
  ) :Integer; stdcall;


(*
typedef void (WINAPI *FARAPIFREEDIRLIST)(struct PluginPanelItem *PanelItem, size_t nItemsNumber);
typedef void (WINAPI *FARAPIFREEPLUGINDIRLIST)(struct PluginPanelItem *PanelItem, size_t nItemsNumber);
*)
  TFarApiFreeDirList = procedure (
    Items :PPluginPanelItemArray;
    ItemsNumber :size_t
  ); stdcall;

  TFarApiFreePluginDirList = procedure (
    Items :PPluginPanelItemArray;
    ItemsNumber :size_t
  ); stdcall;


{------------------------------------------------------------------------------}
{ Viewer / Editor                                                              }
{------------------------------------------------------------------------------}

{ VIEWER_FLAGS }

type
  TViewerFlags = Int64;

const
  VF_NONMODAL              = $00000001;
  VF_DELETEONCLOSE         = $00000002;
  VF_ENABLE_F6             = $00000004;
  VF_DISABLEHISTORY        = $00000008;
  VF_IMMEDIATERETURN       = $00000100;
  VF_DELETEONLYFILEONCLOSE = $00000200;

(*
typedef int (WINAPI *FARAPIVIEWER)(
  const wchar_t *FileName,
  const wchar_t *Title,
  int X1,
  int Y1,
  int X2,
  int Y2,
  VIEWER_FLAGS Flags,
  UINT CodePage
);
*)
type
  TFarApiViewer = function (
    FileName :PFarChar;
    Title :PFarChar;
    X1, Y1, X2, Y2 :Integer;
    Flags :TViewerFlags;
    CodePage :UINT
  ) :Integer; stdcall;


{ EDITOR_FLAGS }

type
  TEditorFlags = Int64;

const
  EN_NONE                  = 0;
  EF_NONMODAL              = $00000001;
  EF_CREATENEW             = $00000002;
  EF_ENABLE_F6             = $00000004;
  EF_DISABLEHISTORY        = $00000008;
  EF_DELETEONCLOSE         = $00000010;
  EF_IMMEDIATERETURN       = $00000100;
  EF_DELETEONLYFILEONCLOSE = $00000200;
  EF_LOCKED                = $00000400;
  EF_DISABLESAVEPOS        = $00000800;

{ EDITOR_EXITCODE }

const
  EEC_OPEN_ERROR          = 0;
  EEC_MODIFIED            = 1;
  EEC_NOT_MODIFIED        = 2;
  EEC_LOADING_INTERRUPTED = 3;

(*
typedef int (WINAPI *FARAPIEDITOR)(
    const wchar_t *FileName,
    const wchar_t *Title,
    int X1,
    int Y1,
    int X2,
    int Y2,
    EDITOR_FLAGS Flags,
    int StartLine,
    int StartChar,
    UINT CodePage
);
*)
type
  TFarApiEditor = function (
    FileName :PFarChar;
    Title :PFarChar;
    X1, Y1, X2, Y2 : Integer;
    Flags :TEditorFlags;
    StartLine :Integer;
    StartChar :Integer;
    CodePage :UINT
  ) :Integer; stdcall;


{------------------------------------------------------------------------------}

(*
typedef const wchar_t*(WINAPI *FARAPIGETMSG)(
    const GUID* PluginId,
    int MsgId
);
*)
type
  TFarApiGetMsg = function (
    const PluginId :TGUID;
    MsgId :Integer
  ) :PFarChar; stdcall;


{ FARHELPFLAGS }

type
  TFarHelpFlags = Int64;

const
  FHELP_NOSHOWERROR = $80000000;
  FHELP_SELFHELP    = $00000000;
  FHELP_FARHELP     = $00000001;
  FHELP_CUSTOMFILE  = $00000002;
  FHELP_CUSTOMPATH  = $00000004;
  FHELP_USECONTENTS = $40000000;


(*
typedef BOOL (WINAPI *FARAPISHOWHELP)(
  const wchar_t *ModuleName,
  const wchar_t *Topic,
  FARHELPFLAGS Flags
);
*)
type
  TFarApiShowHelp = function (
    ModuleName :PFarChar;
    Topic :PFarChar;
    Flags :TFarHelpFlags
  ) :BOOL; stdcall;


{ ADVANCED_CONTROL_COMMANDS }

type
  TADVANCED_CONTROL_COMMANDS = Integer;

const
  ACTL_GETFARMANAGERVERSION  = 0;
  ACTL_GETSYSWORDDIV         = 1;
  ACTL_WAITKEY               = 2;
  ACTL_GETCOLOR              = 3;
  ACTL_GETARRAYCOLOR         = 4;
  ACTL_EJECTMEDIA            = 5;
  ACTL_GETWINDOWINFO         = 6;
  ACTL_GETWINDOWCOUNT        = 7;
  ACTL_SETCURRENTWINDOW_     = 8;
  ACTL_COMMIT                = 9;
  ACTL_GETFARHWND            = 10;
  ACTL_GETSYSTEMSETTINGS     = 11;
  ACTL_GETPANELSETTINGS      = 12;
  ACTL_GETINTERFACESETTINGS  = 13;
  ACTL_GETCONFIRMATIONS      = 14;
  ACTL_GETDESCSETTINGS       = 15;
  ACTL_SETARRAYCOLOR         = 16;
  ACTL_GETPLUGINMAXREADDATA  = 17;
  ACTL_GETDIALOGSETTINGS     = 18;
  ACTL_REDRAWALL             = 19;
  ACTL_SYNCHRO               = 20;
  ACTL_SETPROGRESSSTATE      = 21;
  ACTL_SETPROGRESSVALUE      = 22;
  ACTL_QUIT                  = 23;
  ACTL_GETFARRECT            = 24;
  ACTL_GETCURSORPOS          = 25;
  ACTL_SETCURSORPOS          = 26;
  ACTL_PROGRESSNOTIFY        = 27;
  ACTL_GETWINDOWTYPE         = 28;


          { FarSystemSettings }

          const
            FSS_CLEARROATTRIBUTE           = $00000001;
            FSS_DELETETORECYCLEBIN         = $00000002;
            FSS_USESYSTEMCOPYROUTINE       = $00000004;
            FSS_COPYFILESOPENEDFORWRITING  = $00000008;
            FSS_CREATEFOLDERSINUPPERCASE   = $00000010;
            FSS_SAVECOMMANDSHISTORY        = $00000020;
            FSS_SAVEFOLDERSHISTORY         = $00000040;
            FSS_SAVEVIEWANDEDITHISTORY     = $00000080;
            FSS_USEWINDOWSREGISTEREDTYPES  = $00000100;
            FSS_AUTOSAVESETUP              = $00000200;
            FSS_SCANSYMLINK                = $00000400;

          { FarPanelSettings }

          const
            FPS_SHOWHIDDENANDSYSTEMFILES    = $00000001;
            FPS_HIGHLIGHTFILES              = $00000002;
            FPS_AUTOCHANGEFOLDER            = $00000004;
            FPS_SELECTFOLDERS               = $00000008;
            FPS_ALLOWREVERSESORTMODES       = $00000010;
            FPS_SHOWCOLUMNTITLES            = $00000020;
            FPS_SHOWSTATUSLINE              = $00000040;
            FPS_SHOWFILESTOTALINFORMATION   = $00000080;
            FPS_SHOWFREESIZE                = $00000100;
            FPS_SHOWSCROLLBAR               = $00000200;
            FPS_SHOWBACKGROUNDSCREENSNUMBER = $00000400;
            FPS_SHOWSORTMODELETTER          = $00000800;

          { FarDialogSettings }

          const
            FDIS_HISTORYINDIALOGEDITCONTROLS    = $00000001;
            FDIS_PERSISTENTBLOCKSINEDITCONTROLS = $00000002;
            FDIS_AUTOCOMPLETEININPUTLINES       = $00000004;
            FDIS_BSDELETEUNCHANGEDTEXT          = $00000008;
            FDIS_DELREMOVESBLOCKS               = $00000010;
            FDIS_MOUSECLICKOUTSIDECLOSESDIALOG  = $00000020;

          { FarInterfaceSettings }

          const
            FIS_CLOCKINPANELS                  = $00000001;
            FIS_CLOCKINVIEWERANDEDITOR         = $00000002;
            FIS_MOUSE                          = $00000004;
            FIS_SHOWKEYBAR                     = $00000008;
            FIS_ALWAYSSHOWMENUBAR              = $00000010;
            FIS_USERIGHTALTASALTGR             = $00000080;
            FIS_SHOWTOTALCOPYPROGRESSINDICATOR = $00000100;
            FIS_SHOWCOPYINGTIMEINFO            = $00000200;
            FIS_USECTRLPGUPTOCHANGEDRIVE       = $00000800;
            FIS_SHOWTOTALDELPROGRESSINDICATOR  = $00001000;

          { FarConfirmationsSettings }

          const
            FCS_COPYOVERWRITE          = $00000001;
            FCS_MOVEOVERWRITE          = $00000002;
            FCS_DRAGANDDROP            = $00000004;
            FCS_DELETE                 = $00000008;
            FCS_DELETENONEMPTYFOLDERS  = $00000010;
            FCS_INTERRUPTOPERATION     = $00000020;
            FCS_DISCONNECTNETWORKDRIVE = $00000040;
            FCS_RELOADEDITEDFILE       = $00000080;
            FCS_CLEARHISTORYLIST       = $00000100;
            FCS_EXIT                   = $00000200;
            FCS_OVERWRITEDELETEROFILES = $00000400;

          { FarDescriptionSettings }

          const
            FDS_UPDATEALWAYS      = $00000001;
            FDS_UPDATEIFDISPLAYED = $00000002;
            FDS_SETHIDDEN         = $00000004;
            FDS_UPDATEREADONLY    = $00000008;


          //const
          //  FAR_CONSOLE_GET_MODE       = -2;
          //  FAR_CONSOLE_TRIGGER        = -1;
          //  FAR_CONSOLE_SET_WINDOWED   = 0;
          //  FAR_CONSOLE_SET_FULLSCREEN = 1;
          //  FAR_CONSOLE_WINDOWED       = 0;
          //  FAR_CONSOLE_FULLSCREEN     = 1;


          { FAREJECTMEDIAFLAGS }

          const
            EJECT_NO_MESSAGE          = $00000001;
            EJECT_LOAD_MEDIA          = $00000002;

          (*
          struct ActlEjectMedia {
            DWORD Letter;
            DWORD Flags;
          };
          *)
          type
            PActlEjectMedia = ^TActlEjectMedia;
            TActlEjectMedia = record
              Letter :DWORD;
              Flags :DWORD;
            end;


{------------------------------------------------------------------------------}
{ Macro                                                                        }

{ FAR_MACRO_CONTROL_COMMANDS }

type
  TFAR_MACRO_CONTROL_COMMANDS = Integer;

const
  MCTL_LOADALL      = 0;
  MCTL_SAVEALL      = 1;
  MCTL_SENDSTRING   = 2;
  MCTL_GETSTATE     = 5;
  MCTL_GETAREA      = 6;
  MCTL_ADDMACRO     = 7;
  MCTL_DELMACRO     = 8;


{ FARKEYMACROFLAGS }

type
  TFARKEYMACROFLAGS = Int64;

const
  KMFLAGS_NONE                = 0;
  KMFLAGS_DISABLEOUTPUT       = $00000001;
  KMFLAGS_NOSENDKEYSTOPLUGINS = $00000002;
  KMFLAGS_SILENTCHECK         = $00000001;


{ FARMACROSENDSTRINGCOMMAND }

const
  MSSC_POST  = 0;
  MSSC_CHECK = 2;


{ FARMACROAREA }

const
  MACROAREA_OTHER             =  0;
  MACROAREA_SHELL             =  1;
  MACROAREA_VIEWER            =  2;
  MACROAREA_EDITOR            =  3;
  MACROAREA_DIALOG            =  4;
  MACROAREA_SEARCH            =  5;
  MACROAREA_DISKS             =  6;
  MACROAREA_MAINMENU          =  7;
  MACROAREA_MENU              =  8;
  MACROAREA_HELP              =  9;
  MACROAREA_INFOPANEL         = 10;
  MACROAREA_QVIEWPANEL        = 11;
  MACROAREA_TREEPANEL         = 12;
  MACROAREA_FINDFOLDER        = 13;
  MACROAREA_USERMENU          = 14;
  MACROAREA_AUTOCOMPLETION    = 15;


{ FARMACROSTATE }

const
  MACROSTATE_NOMACRO          = 0;
  MACROSTATE_EXECUTING        = 1;
  MACROSTATE_EXECUTING_COMMON = 2;
  MACROSTATE_RECORDING        = 3;
  MACROSTATE_RECORDING_COMMON = 4;


{FARMACROPARSEERRORCODE}

const
  MPEC_SUCCESS                =  0;
  MPEC_UNRECOGNIZED_KEYWORD   =  1;
  MPEC_UNRECOGNIZED_FUNCTION  =  2;
  MPEC_FUNC_PARAM             =  3;
  MPEC_NOT_EXPECTED_ELSE      =  4;
  MPEC_NOT_EXPECTED_END       =  5;
  MPEC_UNEXPECTED_EOS         =  6;
  MPEC_EXPECTED_TOKEN         =  7;
  MPEC_BAD_HEX_CONTROL_CHAR   =  8;
  MPEC_BAD_CONTROL_CHAR       =  9;
  MPEC_VAR_EXPECTED           = 10;
  MPEC_EXPR_EXPECTED          = 11;
  MPEC_ZEROLENGTHMACRO        = 12;
  MPEC_INTPARSERERROR         = 13;
  MPEC_CONTINUE_OTL           = 14;

(*
struct MacroParseResult
{
  size_t StructSize;
  DWORD ErrCode;
  COORD ErrPos;
  const wchar_t *ErrSrc;
};
*)
type
  PMacroParseResult = ^TMacroParseResult;
  TMacroParseResult = record
    StructSize :size_t;
    ErrCode :DWORD;
    ErrPos :COORD;
    ErrSrc :PFarChar;
  end;

(*
struct MacroSendMacroText
{
  size_t StructSize;
  FARKEYMACROFLAGS Flags;
  INPUT_RECORD AKey;
  const wchar_t *SequenceText;
};
*)
type
  PMacroSendMacroText = ^TMacroSendMacroText;
  TMacroSendMacroText = record
    StructSize :size_t;
    Flags :TFARKEYMACROFLAGS;
    AKey :TInputRecord;
    SequenceText :PFarChar;
  end;


(*
struct MacroCheckMacroText
{
  union
  {
    struct MacroSendMacroText Text;
    struct MacroParseResult   Result;
  }
  Check
  ;
};
*)
type
  PMacroCheckMacroText = ^TMacroCheckMacroText;
  TMacroCheckMacroText = record
    Check : record case Integer of
      0 : (Text :TMacroSendMacroText);
      1 : (Result :TMacroParseResult);
    end;
  end;


{ FARADDKEYMACROFLAGS }

type
  TFARADDKEYMACROFLAGS = Int64;

const
  AKMFLAGS_NONE  = 0;

(*
typedef int (WINAPI *FARMACROCALLBACK)(void* Id,FARADDKEYMACROFLAGS Flags);

struct MacroAddMacro
{
  size_t StructSize;
  void* Id;
  FARKEYMACROFLAGS Flags;
  INPUT_RECORD AKey;
  const wchar_t *SequenceText;
  const wchar_t *Description;
  FARMACROCALLBACK Callback;
};
*)
type
  PMacroAddMacro = ^TMacroAddMacro;
  TMacroAddMacro = record
    StructSize :size_t;
    Id :Pointer;
    Flags :TFARKEYMACROFLAGS;
    AKey :TInputRecord;
    SequenceText :PFarChar;
    Description :PFarChar;
    Callback :Pointer; {FARMACROCALLBACK}
  end;


{ FARMACROVARTYPE }

const
  FMVT_UNKNOWN  = 0;
  FMVT_INTEGER  = 1;
  FMVT_STRING   = 2;
  FMVT_DOUBLE   = 3;

(*
struct FarMacroValue
{
  enum FARMACROVARTYPE Type;
  union
  {
    __int64  Integer;
    double   Double;
    const wchar_t *String;
  }
  Value
  ;
};
*)
type
  PFarMacroValue = ^TFarMacroValue;
  TFarMacroValue = record
    fType :Integer;
    Value : record case Integer of
      0 : (fInteger :Int64);
      1 : (fDouble :Double);
      2 : (fString :PFarChar);
    end;
  end;

(*
#ifdef FAR_USE_INTERNALS
#if defined(MANTIS_0000466)
struct FarMacroFunction
{
	unsigned __int64 Flags;
	const wchar_t *Name;
	int nParam;
	int oParam;
	const wchar_t *Syntax;
	const wchar_t *Description;
};

struct ProcessMacroFuncInfo
{
	size_t StructSize;
	const wchar_t *Name;
	const FarMacroValue *Params;
	int nParams;
	struct FarMacroValue *Results;
	int nResults;
};

enum FAR_MACROINFOTYPE
{
	FMIT_GETFUNCINFO   = 0,
	FMIT_PROCESSFUNC   = 1,
};

struct ProcessMacroInfo
{
	size_t StructSize;
	enum FAR_MACROINFOTYPE Type;
	union {
		struct ProcessMacroFuncInfo Func;
	}
#ifndef __cplusplus
	Value
#endif
	;
};

#endif
#endif // END FAR_USE_INTERNALS
*)


(*
struct FarGetValue
{
  int Type;
  struct FarMacroValue Value;
};
*)
type
  PFarGetValue = ^TFarGetValue;
  TFarGetValue = record
    fType :Integer;
    Value :TFarMacroValue;
  end;

{------------------------------------------------------------------------------}

{ FARSETCOLORFLAGS }

type
  TFarSetColorFlags = Int64;

const
  FSETCLR_NONE    = 0;
  FSETCLR_REDRAW  = $00000001;

(*
struct FarSetColors
{
  FARSETCOLORFLAGS Flags;
  size_t StartIndex;
  size_t ColorsCount;
  struct FarColor* Colors;
};
*)
type
  PFarSetColors = ^TFarSetColors;
  TFarSetColors = record
    Flags :TFarSetColorFlags;
    StartIndex :size_t;
    ColorCount :size_t;
    Colors :PFarColorArray;
  end;


{ WINDOWINFO_TYPE }

const
  WTYPE_PANELS     = 1;
  WTYPE_VIEWER     = 2;
  WTYPE_EDITOR     = 3;
  WTYPE_DIALOG     = 4;
  WTYPE_VMENU      = 5;
  WTYPE_HELP       = 6;


{ WINDOWINFO_FLAGS }

type
  TWindowInfoFlags = Int64;

const
  WIF_MODIFIED = $00000001;
  WIF_CURRENT  = $00000002;


(*
struct WindowInfo
{
  size_t StructSize;
  INT_PTR Id;
  wchar_t *TypeName;
  wchar_t *Name;
  int TypeNameSize;
  int NameSize;
  int Pos;
  enum WINDOWINFO_TYPE Type;
  WINDOWINFO_FLAGS Flags;
};
*)
type
  PWindowInfo = ^TWindowInfo;
  TWindowInfo = record
    StructSize :size_t;
    ID :INT_PTR;
    TypeName :PFarChar;
    Name :PFarChar;
    TypeNameSize :Integer;
    NameSize :Integer;
    Pos :Integer;
    WindowType :Integer; {WINDOWINFO_TYPE}
    Flags :TWindowInfoFlags;
  end;

(*
struct WindowType
{
  size_t StructSize;
  int Type;
};
*)
type
  PWindowType = ^TWindowType;
  TWindowType = record
    StructSize :size_t;
    fType :Integer;
  end;

          { PROGRESSTATE }

          const
            PS_NOPROGRESS    = 0;
            PS_INDETERMINATE = 1;
            PS_NORMAL        = 2;
            PS_ERROR         = 4;
            PS_PAUSED        = 8;

          (*
          struct PROGRESSVALUE
          {
                  unsigned __int64 Completed;
                  unsigned __int64 Total;
          };
          *)
          type
            PProgressValue = ^TProgressValue;
            TProgressValue = record
              Completed :Int64;
              Total :Int64;
            end;


{------------------------------------------------------------------------------}

{ VIEWER_CONTROL_COMMANDS }

const
  VCTL_GETINFO     = 0;
  VCTL_QUIT        = 1;
  VCTL_REDRAW      = 2;
  VCTL_SETKEYBAR   = 3;
  VCTL_SETPOSITION = 4;
  VCTL_SELECT      = 5;
  VCTL_SETMODE     = 6;


{ VIEWER_OPTIONS }

type
  TViewerOptions = Int64;

const
  VOPT_NONE             = 0;
  VOPT_SAVEFILEPOSITION = 1;
  VOPT_AUTODETECTTABLE  = 2;

{VIEWER_SETMODE_TYPES}

const
  VSMT_HEX       = 0;
  VSMT_WRAP      = 1;
  VSMT_WORDWRAP  = 2;


{VIEWER_SETMODEFLAGS_TYPES}

type
  TViewerSetModeFlagsTypes = Int64;

const
  VSMFL_REDRAW   = $00000001;

(*
struct ViewerSetMode
{
  enum VIEWER_SETMODE_TYPES Type;
  union
  {
    int iParam;
    wchar_t *wszParam;
  }
  Param;
  VIEWER_SETMODEFLAGS_TYPES Flags;
  DWORD_PTR Reserved;
};
*)
type
  PViewerSetMode = ^TViewerSetMode;
  TViewerSetMode = record
    ParamType :Integer;
    Param : record case Integer of
      0 : (iParam : Integer);
      1 : (wszParam : PFarChar);
    end;
    Flags :TViewerSetModeFlagsTypes;
    Reserved :DWORD_PTR;
  end;

(*
struct ViewerSelect
{
  __int64 BlockStartPos;
  int     BlockLen;
};
*)
type
  TFarInt64Part = record
    LowPart :DWORD;
    HighPart :DWORD;
  end;

  TFarInt64 = record
    case Integer of
      0 : (i64 :Int64);
      1 : (Part :TFarInt64Part);
  end;

  PViewerSelect = ^TViewerSelect;
  TViewerSelect = record
    BlockStartPos :TFarInt64;
    BlockLen :Integer;
  end;


{ VIEWER_SETPOS_FLAGS }

type
  TViewerSetPosFlags = Int64;

const
  VSP_NOREDRAW    = $0001;
  VSP_PERCENT     = $0002;
  VSP_RELATIVE    = $0004;
  VSP_NORETNEWPOS = $0008;

(*
struct ViewerSetPosition
{
  VIEWER_SETPOS_FLAGS Flags;
  __int64 StartPos;
  __int64 LeftPos;
};

*)
type
  PViewerSetPosition = ^TViewerSetPosition;
  TViewerSetPosition = record
    Flags :TViewerSetPosFlags;
    StartPos :TFarInt64;
    LeftPos :TFarInt64;
  end;

(*
struct ViewerMode
{
  UINT CodePage;
  int Wrap;
  int WordWrap;
  int Hex;
  DWORD_PTR Reserved[4];
};
*)
type
  PViewerMode = ^TViewerMode;
  TViewerMode = record
    CodePage :UINT;
    Wrap :Integer;
    WordWrap :Integer;
    Hex :Integer;
    Reserved :array[0..3] of DWORD_PTR;
  end;

(*
struct ViewerInfo
struct ViewerInfo
{
  size_t StructSize;
  int ViewerID;
  int TabSize;
  const wchar_t *FileName;
  struct ViewerMode CurMode;
  __int64 FileSize;
  __int64 FilePos;
  __int64 LeftPos;
  VIEWER_OPTIONS Options;
  int WindowSizeX;
  int WindowSizeY;
};
*)
type
  PViewerInfo = ^TViewerInfo;
  TViewerInfo = record
    StructSize :size_t;
    ViewerID :Integer;
    TabSize :Integer;
    FileName :PFarChar;
    CurMode :TViewerMode;

    FileSize :TFarInt64;
    FilePos :TFarInt64;
    LeftPos :TFarInt64;

    Options :TViewerOptions;

    WindowSizeX :Integer;
    WindowSizeY :Integer;
  end;


{ VIEWER_EVENTS }

const
  VE_READ      = 0;
  VE_CLOSE     = 1;
  VE_GOTFOCUS  = 6;
  VE_KILLFOCUS = 7;


{ EDITOR_EVENTS }

const
  EE_READ       = 0;
  EE_SAVE       = 1;
  EE_REDRAW     = 2;
  EE_CLOSE      = 3;
  EE_GOTFOCUS   = 6;
  EE_KILLFOCUS  = 7;


{ DIALOG_EVENTS }

const
  DE_DLGPROCINIT    = 0;
  DE_DEFDLGPROCINIT = 1;
  DE_DLGPROCEND     = 2;


{ SYNCHRO_EVENTS }

const
  SE_COMMONSYNCHRO  = 0;


const
  EEREDRAW_ALL    = Pointer(0);
  EEREDRAW_CHANGE = Pointer(1);
  EEREDRAW_LINE   = Pointer(2);


{ EDITOR_CONTROL_COMMANDS }

const
  ECTL_GETSTRING            = 0;
  ECTL_SETSTRING            = 1;
  ECTL_INSERTSTRING         = 2;
  ECTL_DELETESTRING         = 3;
  ECTL_DELETECHAR           = 4;
  ECTL_INSERTTEXT           = 5;
  ECTL_GETINFO              = 6;
  ECTL_SETPOSITION          = 7;
  ECTL_SELECT               = 8;
  ECTL_REDRAW               = 9;
  ECTL_TABTOREAL            = 10;
  ECTL_REALTOTAB            = 11;
  ECTL_EXPANDTABS           = 12;
  ECTL_SETTITLE             = 13;
  ECTL_READINPUT            = 14;
  ECTL_PROCESSINPUT         = 15;
  ECTL_ADDCOLOR             = 16;
  ECTL_GETCOLOR             = 17;
  ECTL_SAVEFILE             = 18;
  ECTL_QUIT                 = 19;
  ECTL_SETKEYBAR            = 20;

  ECTL_SETPARAM             = 22;
  ECTL_GETBOOKMARKS         = 23;
  ECTL_TURNOFFMARKINGBLOCK  = 24;
  ECTL_DELETEBLOCK          = 25;
  ECTL_ADDSTACKBOOKMARK     = 26;
  ECTL_PREVSTACKBOOKMARK    = 27;
  ECTL_NEXTSTACKBOOKMARK    = 28;
  ECTL_CLEARSTACKBOOKMARKS  = 29;
  ECTL_DELETESTACKBOOKMARK  = 30;
  ECTL_GETSTACKBOOKMARKS    = 31;
  ECTL_UNDOREDO             = 32;
  ECTL_GETFILENAME          = 33;
  ECTL_DELCOLOR             = 34;


  
          { EDITOR_SETPARAMETER_TYPES }

          const
            ESPT_TABSIZE          = 0;
            ESPT_EXPANDTABS       = 1;
            ESPT_AUTOINDENT       = 2;
            ESPT_CURSORBEYONDEOL  = 3;
            ESPT_CHARCODEBASE     = 4;
            ESPT_CODEPAGE         = 5;
            ESPT_SAVEFILEPOSITION = 6;
            ESPT_LOCKMODE         = 7;
            ESPT_SETWORDDIV       = 8;
            ESPT_GETWORDDIV       = 9;
            ESPT_SHOWWHITESPACE   = 10;
            ESPT_SETBOM           = 11;


          (*
          struct EditorSetParameter
          {
            int Type;
            union {
              int iParam;
              wchar_t *wszParam;
              DWORD Reserved1;
            } Param;
            DWORD Flags;
            DWORD Size;
          };
          *)
          type
            PEditorSetParameter = ^TEditorSetParameter;
            TEditorSetParameter = record
              ParamType : Integer;
              Param : record case Integer of
                 0 : (iParam : Integer);
                 1 : (wszParam : PFarChar);
                 2 : (Reserved : DWORD);
              end;
              Flags : DWORD;
              Size : DWORD;
            end;


{EDITOR_UNDOREDO_COMMANDS}

const
  EUR_BEGIN = 0;
  EUR_END   = 1;
  EUR_UNDO  = 2;
  EUR_REDO  = 3;

(*
struct EditorUndoRedo
{
  int Command;
  DWORD_PTR Reserved[3];
};
*)
type
  PEditorUndoRedo = ^TEditorUndoRedo;
  TEditorUndoRedo = record
    Command :Integer;
    Reserved :array[0..2] of DWORD_PTR;
  end;

(*
struct EditorGetString
{
  int StringNumber;
  int StringLength;
  const wchar_t *StringText;
  const wchar_t *StringEOL;
  int SelStart;
  int SelEnd;
};
*)
type
  PEditorGetString = ^TEditorGetString;
  TEditorGetString = record
    StringNumber :Integer;
    StringLength :Integer;
    StringText :PFarChar;
    StringEOL :PFarChar;
    SelStart :Integer;
    SelEnd :Integer;
  end;

(*
struct EditorSetString
{
  int StringNumber;
  int StringLength;
  const wchar_t *StringText;
  const wchar_t *StringEOL;
};
*)
type
  PEditorSetString = ^TEditorSetString;
  TEditorSetString = record
    StringNumber :Integer;
    StringLength :Integer;
    StringText :PFarChar;
    StringEOL :PFarChar;
  end;

  
{ EXPAND_TABS }

const
  EXPAND_NOTABS  = 0;
  EXPAND_ALLTABS = 1;
  EXPAND_NEWTABS = 2;


{ EDITOR_OPTIONS }

const
  EOPT_EXPANDALLTABS      = $00000001;
  EOPT_PERSISTENTBLOCKS   = $00000002;
  EOPT_DELREMOVESBLOCKS   = $00000004;
  EOPT_AUTOINDENT         = $00000008;
  EOPT_SAVEFILEPOSITION   = $00000010;
  EOPT_AUTODETECTCODEPAGE = $00000020;
  EOPT_CURSORBEYONDEOL    = $00000040;
  EOPT_EXPANDONLYNEWTABS  = $00000080;
  EOPT_SHOWWHITESPACE     = $00000100;
  EOPT_BOM                = $00000200;


{ EDITOR_BLOCK_TYPES }

const
  BTYPE_NONE   = 0;
  BTYPE_STREAM = 1;
  BTYPE_COLUMN = 2;


{ EDITOR_CURRENTSTATE }

const
  ECSTATE_MODIFIED = $00000001;
  ECSTATE_SAVED    = $00000002;
  ECSTATE_LOCKED   = $00000004;

(*
struct EditorInfo
{
  int EditorID;
  int WindowSizeX;
  int WindowSizeY;
  int TotalLines;
  int CurLine;
  int CurPos;
  int CurTabPos;
  int TopScreenLine;
  int LeftPos;
  int Overtype;
  int BlockType;
  int BlockStartLine;
  DWORD Options;
  int TabSize;
  int BookMarkCount;
  DWORD CurState;
  UINT CodePage;
  DWORD Reserved[5];
};
*)
type
  PEditorInfo = ^TEditorInfo;
  TEditorInfo = record
    EditorID : Integer;
    WindowSizeX : Integer;
    WindowSizeY : Integer;
    TotalLines : Integer;
    CurLine : Integer;
    CurPos : Integer;
    CurTabPos : Integer;
    TopScreenLine : Integer;
    LeftPos : Integer;
    Overtype : Integer;
    BlockType : Integer;
    BlockStartLine : Integer;
    Options : DWORD;
    TabSize : Integer;
    BookMarkCount : Integer;
    CurState : DWORD;
    CodePage : UINT;
    Reserved : array [0..4] of DWORD;
  end;

          (*
          struct EditorBookMarks
          {
            long *Line;
            long *Cursor;
            long *ScreenLine;
            long *LeftPos;
            DWORD Reserved[4];
          };
          *)
          type
            PEditorBookMarks = ^TEditorBookMarks;
            TEditorBookMarks = record
              Line : PIntegerArray;
              Cursor : PIntegerArray;
              ScreenLine : PIntegerArray;
              LeftPos : PIntegerArray;
              Reserved : array [0..3] of DWORD;
            end;

(*
struct EditorSetPosition
{
  int CurLine;
  int CurPos;
  int CurTabPos;
  int TopScreenLine;
  int LeftPos;
  int Overtype;
};
*)
type
  PEditorSetPosition = ^TEditorSetPosition;
  TEditorSetPosition = record
    CurLine : Integer;
    CurPos : Integer;
    CurTabPos : Integer;
    TopScreenLine : Integer;
    LeftPos : Integer;
    Overtype : Integer;
  end;

          (*
          struct EditorSelect
          {
            int BlockType;
            int BlockStartLine;
            int BlockStartPos;
            int BlockWidth;
            int BlockHeight;
          };
          *)
          type
            PEditorSelect = ^TEditorSelect;
            TEditorSelect = record
              BlockType : Integer;
              BlockStartLine : Integer;
              BlockStartPos : Integer;
              BlockWidth : Integer;
              BlockHeight : Integer;
            end;

          (*
          struct EditorConvertPos
          {
            int StringNumber;
            int SrcPos;
            int DestPos;
          };
          *)
          type
            PEditorConvertPos = ^TEditorConvertPos;
            TEditorConvertPos = record
              StringNumber : Integer;
              SrcPos : Integer;
              DestPos : Integer;
            end;


{ EDITORCOLORFLAGS }

type
  TEditorColorFlags = Int64;

const
  ECF_TABMARKFIRST   = $00000001;
  ECF_TABMARKCURRENT = $00000002;

(*
struct EditorColor
{
  size_t StructSize;
  int StringNumber;
  int ColorItem;
  int StartPos;
  int EndPos;
  unsigned Priority;
  EDITORCOLORFLAGS Flags;
  struct FarColor Color;
  GUID Owner;
};
*)
type
  PEditorColor = ^TEditorColor;
  TEditorColor = record
    StructSize :size_t;
    StringNumber :Integer;
    ColorItem :Integer;
    StartPos :Integer;
    EndPos :Integer;
    Priority :Cardinal;
    Flags :TEditorColorFlags;
    Color :TFarColor;
    Owner :TGUID;
  end;

(*
struct EditorDeleteColor
{
  size_t StructSize;
  GUID Owner;
  int StringNumber;
  int StartPos;
};
*)
type
  PEditorDeleteColor = ^TEditorDeleteColor;
  TEditorDeleteColor = record
    StructSize :size_t;
    Owner :TGUID;
    StringNumber :Integer;
    StartPos :Integer;
  end;

const
  EDITOR_COLOR_NORMAL_PRIORITY = $80000000;


          (*
          struct EditorSaveFile
          {
            const wchar_t *FileName;
            const wchar_t *FileEOL;
            UINT CodePage;
          };
          *)
          type
            PEditorSaveFile = ^TEditorSaveFile;
            TEditorSaveFile = record
              FileName :PFarChar;
              FileEOL :PFarChar;
              CodePage :UINT;
            end;


{ INPUTBOXFLAGS }

type
  TInputBoxFlags = Int64;

const
  FIB_NONE             = 0;
  FIB_ENABLEEMPTY      = $00000001;
  FIB_PASSWORD         = $00000002;
  FIB_EXPANDENV        = $00000004;
  FIB_NOUSELASTHISTORY = $00000008;
  FIB_BUTTONS          = $00000010;
  FIB_NOAMPERSAND      = $00000020;
  FIB_EDITPATH         = $00000040;

(*
typedef int (WINAPI *FARAPIINPUTBOX)(
    const GUID* PluginId,
    const GUID* Id,
    const wchar_t *Title,
    const wchar_t *SubTitle,
    const wchar_t *HistoryName,
    const wchar_t *SrcText,
    wchar_t *DestText,
    int   DestLength,
    const wchar_t *HelpTopic,
    INPUTBOXFLAGS Flags
);
*)
type
  TFarApiInputBox = function (
    const PluginID :TGUID;
    const ID :TGUID;
    Title : PFarChar;
    SubTitle : PFarChar;
    HistoryName : PFarChar;
    SrcText : PFarChar;
    DestText : PFarChar;
    DestLength : Integer;
    HelpTopic : PFarChar;
    Flags :TInputBoxFlags
  ) :Integer; stdcall;

{------------------------------------------------------------------------------}

{ FAR_PLUGINS_CONTROL_COMMANDS }

const
  PCTL_LOADPLUGIN       = 0;
  PCTL_UNLOADPLUGIN     = 1;
  PCTL_FORCEDLOADPLUGIN = 2;
  PCTL_GETPLUGINS       = 3;  { Param2 - TFarPlugins }
  PCTL_GETPLUGININFO    = 4;  { Param2 - TFarPluginInfo }
  PCTL_FINDPLUGIN       = 5;


{ FAR_PLUGIN_LOAD_TYPE }

const
  PLT_PATH = 0;


{ FAR_PLUGIN_FIND_MODE }

const
  PFM_GUID        = 0;
  PFM_MODULENAME  = 1;

{ FAR_PLUGIN_FLAGS }

type
  TFarPluginFlags = Int64;

const
  FPF_NONE         = 0;
  FPF_FAR1         = $00000001;
  FPF_FAR2         = $00000002;
  FPF_LOADED       = $00000004;

(*
struct FarPlugins
{
  size_t StructSize;
  int PluginsCount;
};
*)
type
  {PCTL_GETPLUGINS}
  PFarPlugins = ^TFarPlugins;
  TFarPlugins = record
    StructSize :size_t;
    PluginsCount :Integer;
  end;


{FAR_FILE_FILTER_CONTROL_COMMANDS}

const
  FFCTL_CREATEFILEFILTER = 0;
  FFCTL_FREEFILEFILTER   = 1;
  FFCTL_OPENFILTERSMENU  = 2;
  FFCTL_STARTINGTOFILTER = 3;
  FFCTL_ISFILEINFILTER   = 4;

{FAR_FILE_FILTER_TYPE}

const
  FFT_PANEL     = 0;
  FFT_FINDFILE  = 1;
  FFT_COPY      = 2;
  FFT_SELECT    = 3;
  FFT_CUSTOM    = 4;


{FAR_REGEXP_CONTROL_COMMANDS}

const
  RECTL_CREATE        = 0;
  RECTL_FREE          = 1;
  RECTL_COMPILE       = 2;
  RECTL_OPTIMIZE      = 3;
  RECTL_MATCHEX       = 4;
  RECTL_SEARCHEX      = 5;
  RECTL_BRACKETSCOUNT = 6;


(*
struct RegExpMatch
{
  int start,end;
};
*)
type
  PRegExpMatch = ^TRegExpMatch;
  TRegExpMatch = record
    Start :Integer;
    EndPos :Integer;
  end;

(*
struct RegExpSearch
{
  const wchar_t* Text;
  int Position;
  int Length;
  struct RegExpMatch* Match;
  int Count;
  void* Reserved;
};
*)
type
  PRegExpSearch = ^TRegExpSearch;
  TRegExpSearch = record
    Text :PFarChar;
    Position :Integer;
    Length :Integer;
    Match :PRegExpMatch;
    Count :Integer;
    Reserved :Pointer;
  end;

{------------------------------------------------------------------------------}

{ FAR_SETTINGS_CONTROL_COMMANDS }

const
  SCTL_CREATE       = 0;
  SCTL_FREE         = 1;
  SCTL_SET          = 2;
  SCTL_GET          = 3;
  SCTL_ENUM         = 4;
  SCTL_DELETE       = 5;
  SCTL_CREATESUBKEY = 6;
  SCTL_OPENSUBKEY   = 7;


{ FARSETTINGSTYPES }

const
  FST_UNKNOWN  = 0;
  FST_SUBKEY   = 1;
  FST_QWORD    = 2;
  FST_STRING   = 3;
  FST_DATA     = 4;


{ FARSETTINGS_SUBFOLDERS }

const
  FSSF_ROOT              =  0;
  FSSF_HISTORY_CMD       =  1;
  FSSF_HISTORY_FOLDER    =  2;
  FSSF_HISTORY_VIEW      =  3;
  FSSF_HISTORY_EDIT      =  4;
  FSSF_HISTORY_EXTERNAL  =  5;
  FSSF_FOLDERSHORTCUT_0  =  6;
  FSSF_FOLDERSHORTCUT_1  =  7;
  FSSF_FOLDERSHORTCUT_2  =  8;
  FSSF_FOLDERSHORTCUT_3  =  9;
  FSSF_FOLDERSHORTCUT_4  = 10;
  FSSF_FOLDERSHORTCUT_5  = 11;
  FSSF_FOLDERSHORTCUT_6  = 12;
  FSSF_FOLDERSHORTCUT_7  = 13;
  FSSF_FOLDERSHORTCUT_8  = 14;
  FSSF_FOLDERSHORTCUT_9  = 15;


(*
struct FarSettingsCreate
{
  size_t StructSize;
  GUID Guid;
  HANDLE Handle;
};
*)
type
  PFarSettingsCreate = ^TFarSettingsCreate;
  TFarSettingsCreate = record
    StructSize :size_t;
    Guid :TGUID;
    Handle :THandle;
  end;

(*
struct FarSettingsItem
{
   size_t Root;
   const wchar_t* Name;
   enum FARSETTINGSTYPES Type;
   union
   {
     unsigned __int64 Number;
     const wchar_t* String;
     struct
     {
       size_t Size;
       const void* Data;
     } Data;
   } Value
   ;
};
*)
type
  PFarSettingsData = ^TFarSettingsData;
  TFarSettingsData = record
    Size :size_t;
    Data :Pointer;
  end;

  PFarSettingsItem = ^TFarSettingsItem;
  TFarSettingsItem = record
    Root :size_t;
    Name :PFarChar;
    FType :Integer {FARSETTINGSTYPES};
    Value :record case Integer of
      0 : (Number :Int64);
      1 : (Str :PFarChar);
      2 : (Data :TFarSettingsData);
    end;
  end;

(*
struct FarSettingsName
{
  const wchar_t* Name;
  enum FARSETTINGSTYPES Type;
};
*)
type
  PFarSettingsName = ^TFarSettingsName;
  TFarSettingsName = record
    Name :PFarChar;
    FType :Integer {FARSETTINGSTYPES};
  end;

(*
struct FarSettingsHistory
{
  const wchar_t* Name;
  const wchar_t* Param;
  GUID PluginId;
  const wchar_t* File;
  FILETIME Time;
  BOOL Lock;
};
*)
type
  PFarSettingsHistory = ^TFarSettingsHistory;
  TFarSettingsHistory = record
    Name :PFarChar;
    Param :PFarChar;
    PluginId :TGUID;
    _File :PFarChar;
    Time :FILETIME;
    Lock :BOOL;
  end;

  PFarSettingsHistoryArray = ^TFarSettingsHistoryArray;
  TFarSettingsHistoryArray = packed array[0..MaxInt div SizeOf(TFarSettingsHistory) - 1] of TFarSettingsHistory;


(*
struct FarSettingsEnum
{
  size_t Root;
  size_t Count;
  union
  {
    const struct FarSettingsName* Items;
    const struct FarSettingsHistory* Histories;
  }
  Value;
};
*)
type
  PFarSettingsEnum = ^TFarSettingsEnum;
  TFarSettingsEnum = record
    Root :size_t;
    Count :size_t;
    Value : record case Integer of
      0 : (Items :PFarSettingsName);
      1 : (Histories :PFarSettingsHistoryArray);
    end;
  end;

(*
struct FarSettingsValue
{
  size_t Root;
  const wchar_t* Value;
};
*)
type
  PFarSettingsValue = ^TFarSettingsValue;
  TFarSettingsValue = record
    Root :size_t;
    Value :PFarChar;
  end;

{------------------------------------------------------------------------------}

type
(*
typedef INT_PTR (WINAPI *FARAPIPANELCONTROL)(
    HANDLE hPanel,
    enum FILE_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiPanelControl = function (
    hPlugin :THandle;
    Command :Integer; {FILE_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;


(*
typedef INT_PTR(WINAPI *FARAPIADVCONTROL)(
    const GUID* PluginId,
    enum ADVANCED_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiAdvControl = function (
    const PluginID :TGUID;
    Command :TADVANCED_CONTROL_COMMANDS;
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;


(*
typedef INT_PTR (WINAPI *FARAPIVIEWERCONTROL)(
    int ViewerID,
    enum VIEWER_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
type
  TFarApiViewerControl = function (
    ViewerID :Integer;
    Command :Integer; {VIEWER_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;

(*
typedef INT_PTR (WINAPI *FARAPIEDITORCONTROL)(
    int EditorID,
    enum EDITOR_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
type
  TFarApiEditorControl = function (
    EditorID :Integer;
    Command :Integer; {EDITOR_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;

(*
typedef INT_PTR (WINAPI *FARAPIMACROCONTROL)(
    const GUID* PluginId,
    enum FAR_MACRO_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiMacroControl = function(
    const PluginId :TGUID;
    Command :TFAR_MACRO_CONTROL_COMMANDS;
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;


(*
typedef INT_PTR (WINAPI *FARAPIPLUGINSCONTROL)(
    HANDLE hHandle,
    enum FAR_PLUGINS_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiPluginsControl = function(
    hHandle :THandle;
    Command :Integer; {FAR_PLUGINS_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;

(*
typedef INT_PTR (WINAPI *FARAPIFILEFILTERCONTROL)(
    HANDLE hHandle,
    enum FAR_FILE_FILTER_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiFilterControl = function(
    hHandle :THandle;
    Command :Integer; {FAR_FILE_FILTER_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer //LONG_PTR
  ) :INT_PTR; stdcall;

(*
typedef INT_PTR (WINAPI *FARAPIREGEXPCONTROL)(
    HANDLE hHandle,
    enum FAR_REGEXP_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiRegexpControl = function(
    hHandle :THandle;
    Command :Integer; {FAR_REGEXP_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;

(*
typedef INT_PTR (WINAPI *FARAPISETTINGSCONTROL)(
    HANDLE hHandle,
    enum FAR_SETTINGS_CONTROL_COMMANDS Command,
    int Param1,
    void* Param2
);
*)
  TFarApiSettingsControl = function(
    hHandle :THandle;
    Command :Integer; {FAR_SETTINGS_CONTROL_COMMANDS}
    Param1 :Integer;
    Param2 :Pointer
  ) :INT_PTR; stdcall;


          (*
          // <C&C++>
          typedef int     (WINAPIV *FARSTDSPRINTF)(wchar_t *Buffer,const wchar_t *Format,...);
          typedef int     (WINAPIV *FARSTDSNPRINTF)(wchar_t *Buffer,size_t Sizebuf,const wchar_t *Format,...);
          typedef int     (WINAPIV *FARSTDSSCANF)(const wchar_t *Buffer, const wchar_t *Format,...);
          // </C&C++>
          typedef void    (WINAPI *FARSTDQSORT)(void *base, size_t nelem, size_t width, int (__cdecl *fcmp)(const void *, const void * ));
          typedef void    (WINAPI *FARSTDQSORTEX)(void *base, size_t nelem, size_t width, int (__cdecl *fcmp)(const void *, const void *,void *userparam),void *userparam);
          typedef void   *(WINAPI *FARSTDBSEARCH)(const void *key, const void *base, size_t nelem, size_t width, int (__cdecl *fcmp)(const void *, const void * ));
          typedef int     (WINAPI *FARSTDGETFILEOWNER)(const wchar_t *Computer,const wchar_t *Name,wchar_t *Owner,int Size);
          typedef int     (WINAPI *FARSTDGETNUMBEROFLINKS)(const wchar_t *Name);
          typedef int     (WINAPI *FARSTDATOI)(const wchar_t *s);
          typedef __int64 (WINAPI *FARSTDATOI64)(const wchar_t *s);
          typedef wchar_t   *(WINAPI *FARSTDITOA64)(__int64 value, wchar_t *string, int radix);
          typedef wchar_t   *(WINAPI *FARSTDITOA)(int value, wchar_t *string, int radix);
          typedef wchar_t   *(WINAPI *FARSTDLTRIM)(wchar_t *Str);
          typedef wchar_t   *(WINAPI *FARSTDRTRIM)(wchar_t *Str);
          typedef wchar_t   *(WINAPI *FARSTDTRIM)(wchar_t *Str);
          typedef wchar_t   *(WINAPI *FARSTDTRUNCSTR)(wchar_t *Str,int MaxLength);
          typedef wchar_t   *(WINAPI *FARSTDTRUNCPATHSTR)(wchar_t *Str,int MaxLength);
          typedef wchar_t   *(WINAPI *FARSTDQUOTESPACEONLY)(wchar_t *Str);
          typedef const wchar_t*   (WINAPI *FARSTDPOINTTONAME)(const wchar_t *Path);
          typedef int     (WINAPI *FARSTDGETPATHROOT)(const wchar_t *Path,wchar_t *Root, int DestSize);
          typedef BOOL    (WINAPI *FARSTDADDENDSLASH)(wchar_t *Path);
          typedef int     (WINAPI *FARSTDCOPYTOCLIPBOARD)(const wchar_t *Data);
          typedef wchar_t *(WINAPI *FARSTDPASTEFROMCLIPBOARD)(void);
          typedef int     (WINAPI *FARSTDINPUTRECORDTOKEY)(const INPUT_RECORD *r);
          typedef int     (WINAPI *FARSTDLOCALISLOWER)(wchar_t Ch);
          typedef int     (WINAPI *FARSTDLOCALISUPPER)(wchar_t Ch);
          typedef int     (WINAPI *FARSTDLOCALISALPHA)(wchar_t Ch);
          typedef int     (WINAPI *FARSTDLOCALISALPHANUM)(wchar_t Ch);
          typedef wchar_t (WINAPI *FARSTDLOCALUPPER)(wchar_t LowerChar);
          typedef wchar_t (WINAPI *FARSTDLOCALLOWER)(wchar_t UpperChar);
          typedef void    (WINAPI *FARSTDLOCALUPPERBUF)(wchar_t *Buf,int Length);
          typedef void    (WINAPI *FARSTDLOCALLOWERBUF)(wchar_t *Buf,int Length);
          typedef void    (WINAPI *FARSTDLOCALSTRUPR)(wchar_t *s1);
          typedef void    (WINAPI *FARSTDLOCALSTRLWR)(wchar_t *s1);
          typedef int     (WINAPI *FARSTDLOCALSTRICMP)(const wchar_t *s1,const wchar_t *s2);
          typedef int     (WINAPI *FARSTDLOCALSTRNICMP)(const wchar_t *s1,const wchar_t *s2,int n);
          *)

          type
            {&Cdecl+}
            TFarStdQSortFunc = function (Param1 : Pointer; Param2 : Pointer) :Integer; cdecl;
            TFarStdQSortExFunc = function (Param1 : Pointer; Param2 : Pointer; UserParam : Pointer) : Integer; cdecl;

            {&StdCall+}
            TFarStdQSort = procedure (Base : Pointer; NElem : SIZE_T; Width : SIZE_T; FCmp : TFarStdQSortFunc); stdcall;
            TFarStdQSortEx = procedure (Base : Pointer; NElem : SIZE_T; Width : SIZE_T; FCmp : TFarStdQSortExFunc; UserParam : Pointer); stdcall;
            TFarStdBSearch = procedure (Key : Pointer; Base : Pointer; NElem : SIZE_T; Width : SIZE_T; FCmp : TFarStdQSortFunc); stdcall;

            TFarStdGetFileOwner = function (Computer : PFarChar; Name : PFarChar; Owner : PFarChar ) : Integer; stdcall;
            TFarStdGetNumberOfLinks = function (Name : PFarChar) : Integer; stdcall;
            TFarStdAtoi = function (S : PFarChar) : Integer; stdcall;
            TFarStdAtoi64 = function (S : PFarChar) : Int64; stdcall;
            TFarStdItoa64 = function (Value : Int64; Str : PFarChar; Radix : Integer) :PFarChar; stdcall;

            TFarStdItoa = function (Value : Integer; Str : PFarChar; Radix : Integer ) : PFarChar; stdcall;
            TFarStdLTrim = function (Str : PFarChar) : PFarChar; stdcall;
            TFarStdRTrim = function (Str : PFarChar) : PFarChar; stdcall;
            TFarStdTrim = function (Str : PFarChar) : PFarChar; stdcall;
            TFarStdTruncStr = function (Str : PFarChar; MaxLength : Integer) : PFarChar; stdcall;
            TFarStdTruncPathStr = function (Str : PFarChar; MaxLength : Integer) : PFarChar; stdcall;
            TFarStdQuoteSpaceOnly = function (Str : PFarChar) : PFarChar; stdcall;
            TFarStdPointToName = function (Path : PFarChar) : PFarChar; stdcall;
            TFarStdGetPathRoot = function (Path : PFarChar; Root : PFarChar; DestSize :Integer) :Integer; stdcall;
            TFarStdAddEndSlash = function (Path : PFarChar) : LongBool; stdcall;
            TFarStdCopyToClipBoard = function (Data : PFarChar) : Integer; stdcall;
            TFarStdPasteFromClipboard = function : PFarChar; stdcall;
            TFarStdInputRecordToKey = function (const R : TInputRecord) : Integer; stdcall;

            TFarStdLocalIsLower = function (Ch : Integer) : Integer; stdcall;
            TFarStdLocalIsUpper = function (Ch : Integer) : Integer; stdcall;
            TFarStdLocalIsAlpha = function (Ch : Integer) : Integer; stdcall;
            TFarStdLocalIsAlphaNum = function (Ch : Integer) : Integer; stdcall;
            TFarStdLocalUpper = function (LowerChar : Integer) : Integer; stdcall;
            TFarStdLocalLower = function (UpperChar : Integer) : Integer; stdcall;

            TFarStdLocalUpperBuf = function (Buf : PFarChar; Length : Integer) : Integer; stdcall;
            TFarStdLocalLowerBuf = function (Buf : PFarChar; Length : Integer) : Integer; stdcall;
            TFarStdLocalStrUpr = function (S1 : PFarChar) : Integer; stdcall;
            TFarStdLocalStrLwr = function (S1 : PFarChar) : Integer; stdcall;
            TFarStdLocalStrICmp = function (S1 : PFarChar; S2 : PFarChar) : Integer; stdcall;
            TFarStdLocalStrNICmp = function (S1 : PFarChar; S2 : PFarChar; N : Integer) : Integer; stdcall;


          { PROCESSNAME_FLAGS }

          const
            PN_CMPNAME      = $00000000;
            PN_CMPNAMELIST  = $00001000;
            PN_GENERATENAME = $00002000;
            PN_SKIPPATH     = $00100000;

          (*
          typedef int (WINAPI *FARSTDPROCESSNAME)(const wchar_t *param1, wchar_t *param2, DWORD size, DWORD flags);
          typedef void (WINAPI *FARSTDUNQUOTE)(wchar_t *Str);
          *)
          type
            TFarStdProcessName = function (Param1, Param2 :PFarChar; Size, Flags :DWORD) : Integer; stdcall;
            TFarStdUnquote = procedure (Str : PFarChar); stdcall;


          { XLATMODE }

          type
            TXLAT_FLAGS = Int64;

          const
            XLAT_SWITCHKEYBLAYOUT  = $00000001;
            XLAT_SWITCHKEYBBEEP    = $00000002;
            XLAT_USEKEYBLAYOUTNAME = $00000004;
            XLAT_CONVERTALLCMDLINE = $00010000;


(*
typedef size_t (WINAPI *FARSTDINPUTRECORDTOKEYNAME)(const INPUT_RECORD* Key, wchar_t *KeyText, size_t Size);
typedef BOOL (WINAPI *FARSTDKEYNAMETOINPUTRECORD)(const wchar_t *Name,INPUT_RECORD* Key);
typedef wchar_t*(WINAPI *FARSTDXLAT)(wchar_t *Line,int StartPos,int EndPos,XLAT_FLAGS Flags);
*)
type
  TFarStdInputRecordToKeyName = function(const Key :TInputRecord; KeyText :PFarChar; Size :size_t) :size_t; stdcall;
  TFarStdKeyNameToInputRecord = function(Name :PFarChar; var Key :TInputRecord) :Boolean; stdcall;
  TFarStdXLat = function(Line :PFarChar; StartPos, EndPos :Integer; Flags :TXLAT_FLAGS) :PFarChar; stdcall;


{ FRSMODE }

type
  TFRSMODE = Int64;

const
  FRS_RETUPDIR    = $01;
  FRS_RECUR       = $02;
  FRS_SCANSYMLINK = $04;

(*
typedef int (WINAPI *FRSUSERFUNC)(
    const struct PluginPanelItem *FData,
    const wchar_t *FullName,
    void *Param
);

typedef void (WINAPI *FARSTDRECURSIVESEARCH)(const wchar_t *InitDir,const wchar_t *Mask,FRSUSERFUNC Func,FRSMODE Flags,void *Param);
*)
type
  TFRSUserFunc = function(const FData :TPluginPanelItem; FullName :PFarChar; Param :Pointer) :Integer; stdcall;

  TFarStdRecursiveSearch = procedure(InitDir, Mask :PFarChar; Func :TFRSUserFunc; Flags :TFRSMODE; Param :Pointer); stdcall;




(*
typedef size_t (WINAPI *FARSTDMKTEMP)(wchar_t *Dest, size_t DestSize, const wchar_t *Prefix);
typedef void (WINAPI *FARSTDDELETEBUFFER)(void *Buffer);
typedef size_t (WINAPI *FARSTDGETPATHROOT)(const wchar_t *Path,wchar_t *Root, size_t DestSize);
*)
          type
            TFarStdMkTemp = function (Dest :PFarChar; Size :DWORD; Prefix :PFarChar) :Integer; stdcall;
            TFarStdDeleteBuffer = procedure(Buffer :Pointer); stdcall;


          { MKLINKOP }

          const
            FLINK_HARDLINK         = 1;
            FLINK_JUNCTION         = 2;
            FLINK_VOLMOUNT         = 3;
            FLINK_SYMLINKFILE      = 4;
            FLINK_SYMLINKDIR       = 5;
            FLINK_SYMLINK          = 6;

            FLINK_SHOWERRMSG       = $10000;
            FLINK_DONOTUPDATEPANEL = $20000;

          (*
          typedef int     (WINAPI *FARSTDMKLINK)(const wchar_t *Src,const wchar_t *Dest,DWORD Flags);
          typedef int     (WINAPI *FARGETREPARSEPOINTINFO)(const wchar_t *Src, wchar_t *Dest,int DestSize);
          *)
          type
            TFarStdMkLink = function (Src, Dest :PFarChar; Flags :DWORD) :Integer; stdcall;
            TFarGetReparsePointInfo = function (Src, Dest :PFarChar; DestSize :Integer) : Integer; stdcall;

          (*
          enum CONVERTPATHMODES
          {
                  CPM_FULL,
                  CPM_REAL,
                  CPM_NATIVE,
          };

          typedef int (WINAPI *FARCONVERTPATH)(CONVERTPATHMODES Mode, const wchar_t *Src, wchar_t *Dest, int DestSize);
          *)

          const
            CPM_FULL   = 0;
            CPM_REAL   = 1;
            CPM_NATIVE = 2;

          type
            TFarConvertPath = function(Mode :Integer {TConvertPathModes}; Src :PFarChar; Dest :PFarChar; DestSize :Integer) :Integer; stdcall;

          (*
          typedef DWORD (WINAPI *FARGETCURRENTDIRECTORY)(DWORD Size,wchar_t* Buffer);
          *)
          type
            TFarGetCurrentDirectory = function(Size :DWORD; Buffer :PFarChar) :DWORD; stdcall;


{ FarStandardFunctions }

type
  PFarStandardFunctions = ^TFarStandardFunctions;
  TFarStandardFunctions = record
    StructSize           :Integer;

    atoi                 :TFarStdAtoi;
    atoi64               :TFarStdAtoi64;
    itoa                 :TFarStdItoa;
    itoa64               :TFarStdItoa64;

    sprintf              :Pointer;
    sscanf               :Pointer;

    qsort                :TFarStdQSort;
    bsearch              :TFarStdBSearch;
    qsortex              :TFarStdQSortEx;

    snprintf             :Pointer {TFarStdSNPRINTF};

    Reserved             :array [0..7] of DWORD_PTR;

    LIsLower             :TFarStdLocalIsLower;
    LIsUpper             :TFarStdLocalIsUpper;
    LIsAlpha             :TFarStdLocalIsAlpha;
    LIsAlphaNum          :TFarStdLocalIsAlphaNum;
    LUpper               :TFarStdLocalUpper;
    LLower               :TFarStdLocalLower;
    LUpperBuf            :TFarStdLocalUpperBuf;
    LLowerBuf            :TFarStdLocalLowerBuf;
    LStrupr              :TFarStdLocalStrUpr;
    LStrlwr              :TFarStdLocalStrLwr;
    LStricmp             :TFarStdLocalStrICmp;
    LStrnicmp            :TFarStdLocalStrNICmp;

    Unquote              :TFarStdUnquote;
    LTrim                :TFarStdLTrim;
    RTrim                :TFarStdRTrim;
    Trim                 :TFarStdTrim;
    TruncStr             :TFarStdTruncStr;
    TruncPathStr         :TFarStdTruncPathStr;
    QuoteSpaceOnly       :TFarStdQuoteSpaceOnly;
    PointToName          :TFarStdPointToName;
    GetPathRoot          :TFarStdGetPathRoot;
    AddEndSlash          :TFarStdAddEndSlash;
    CopyToClipboard      :TFarStdCopyToClipboard;
    PasteFromClipboard   :TFarStdPasteFromClipboard;
    FarInputRecordToName :TFarStdInputRecordToKeyName;
    FarNameToInputRecord :TFarStdKeyNameToInputRecord;
    XLat                 :TFarStdXLat;
    GetFileOwner         :TFarStdGetFileOwner;
    GetNumberOfLinks     :TFarStdGetNumberOfLinks;
    FarRecursiveSearch   :TFarStdRecursiveSearch;
    MkTemp               :TFarStdMkTemp;
    DeleteBuffer         :TFarStdDeleteBuffer;
    ProcessName          :TFarStdProcessName;
    MkLink               :TFarStdMkLink;
    ConvertPath          :TFarConvertPath;
    GetReparsePointInfo  :TFarGetReparsePointInfo;
    GetCurrentDirectory  :TFarGetCurrentDirectory;
  end; {TFarStandardFunctions}


{ PluginStartupInfo }

type
  PPluginStartupInfo = ^TPluginStartupInfo;
  TPluginStartupInfo = record
    StructSize          : size_t;
    ModuleName          : PFarChar;

    Menu                : TFarApiMenu;
    Message             : TFarApiMessage;
    GetMsg              : TFarApiGetMsg;
    Control             : TFarApiPanelControl;
    SaveScreen          : TFarApiSaveScreen;
    RestoreScreen       : TFarApiRestoreScreen;
    GetDirList          : TFarApiGetDirList;
    GetPluginDirList    : TFarApiGetPluginDirList;
    FreeDirList         : TFarApiFreeDirList;
    FreePluginDirList   : TFarApiFreePluginDirList;
    Viewer              : TFarApiViewer;
    Editor              : TFarApiEditor;
    Text                : TFarApiText;
    EditorControl       : TFarApiEditorControl;

    FSF                 : PFarStandardFunctions;

    ShowHelp            : TFarApiShowHelp;
    AdvControl          : TFarApiAdvControl;
    InputBox            : TFarApiInputBox;
    ColorDialog         : Pointer (* TFarApiColorDialog *);
    DialogInit          : TFarApiDialogInit;
    DialogRun           : TFarApiDialogRun;
    DialogFree          : TFarApiDialogFree;

    SendDlgMessage      : TFarApiSendDlgMessage;
    DefDlgProc          : TFarApiDefDlgProc;
    Reserved            : DWORD_PTR;
    ViewerControl       : TFarApiViewerControl;
    PluginsControl      : TFarApiPluginsControl;
    FileFilterControl   : TFarApiFilterControl;
    RegExpControl       : TFarApiRegexpControl;
    MacroControl        : TFarApiMacroControl;
    SettingsControl     : TFarApiSettingsControl;
  end; {TPluginStartupInfo}


{ PLUGIN_FLAGS }

type
  TPluginFlags = Int64;

const
  PF_NONE          = 0;
  PF_PRELOAD       = $0001;
  PF_DISABLEPANELS = $0002;
  PF_EDITOR        = $0004;
  PF_VIEWER        = $0008;
  PF_FULLCMDLINE   = $0010;
  PF_DIALOG        = $0020;

(*
struct PluginMenuItem
{
  const GUID *Guids;
  const wchar_t * const *Strings;
  int Count;
};
*)
type
  PPluginMenuItem = ^TPluginMenuItem;
  TPluginMenuItem = record
    Guids :PGuidsArray;
    Strings :PPCharArray; {PFarChar;}
    Count :Integer;
  end;


{ VERSION_STAGE }

const
  VS_RELEASE = 0;
  VS_ALPHA   = 1;
  VS_BETA    = 2;
  VS_RC      = 3;

(*
struct VersionInfo
{
  DWORD Major;
  DWORD Minor;
  DWORD Revision;
  DWORD Build;
  enum VERSION_STAGE Stage;
};
*)
type
  PVersionInfo = ^TVersionInfo;
  TVersionInfo = record
    Major :DWORD;
    Minor :DWORD;
    Revision :DWORD;
    Build :DWORD;
    Stage :Integer{VERSION_STAGE};
  end;

(*
struct GlobalInfo
{
  size_t StructSize;
  struct VersionInfo MinFarVersion;
  struct VersionInfo Version;
  GUID Guid;
  const wchar_t *Title;
  const wchar_t *Description;
  const wchar_t *Author;
};
*)
type
  PGlobalInfo = ^TGlobalInfo;
  TGlobalInfo = record
    StructSize :size_t;
    MinFarVersion :TVersionInfo;
    Version :TVersionInfo;
    Guid :TGUID;
    Title :PFarChar;
    Description :PFarChar;
    Author :PFarChar;
  end;

(*
struct PluginInfo
{
  size_t StructSize;
  PLUGIN_FLAGS Flags;
  struct PluginMenuItem DiskMenu;
  struct PluginMenuItem PluginMenu;
  struct PluginMenuItem PluginConfig;
  const wchar_t *CommandPrefix;
};
*)
type
  PPluginInfo = ^TPluginInfo;
  TPluginInfo = record
    StructSize :size_t;
    Flags :TPluginFlags;
    DiskMenu :TPluginMenuItem;
    PluginMenu :TPluginMenuItem;
    PluginConfig :TPluginMenuItem;
    CommandPrefix :PFarChar;
  end;

(*
struct FarPluginInfo
{
  size_t StructSize;
  int Index;
  GUID Guid;
  const wchar_t *ModuleName;
  struct VersionInfo Version;
  const wchar_t *Title;
  const wchar_t *Description;
  const wchar_t *Author;
  PLUGIN_FLAGS Flags;
  struct PluginMenuItem DiskMenu;
  struct PluginMenuItem PluginMenu;
  struct PluginMenuItem PluginConfig;
  const wchar_t *CommandPrefix;
};
-->
struct FarGetPluginInfo
{
  size_t Size;
  const wchar_t *ModuleName;
  struct GlobalInfo Info1;
  struct PluginInfo Info2;
};
*)
type
(*
  { PCTL_GETPLUGININFO }
  PFarPluginInfo = ^TFarPluginInfo;
  TFarPluginInfo = record
    StructSize :size_t;
    Index :Integer;
    Guid :TGUID;
    ModuleName :PFarChar;
    Version :TVersionInfo;
    Title :PFarChar;
    Description :PFarChar;
    Author :PFarChar;
    Flags :TPluginFlags;
    DiskMenu :TPluginMenuItem;
    PluginMenu :TPluginMenuItem;
    PluginConfig :TPluginMenuItem;
    CommandPrefix :PFarChar;
  end;
*)
  PFarPluginInfo = ^TFarPluginInfo;
  TFarPluginInfo = record
    Size :size_t;
    ModuleName :PFarChar;
    Flags :TFarPluginFlags;
    Info1 :TGlobalInfo;
    Info2 :TPluginInfo;
  end;


(*
struct InfoPanelLine
{
  const wchar_t *Text;
  const wchar_t *Data;
  int  Separator;
};
*)
type
  PInfoPanelLine = ^TInfoPanelLine;
  TInfoPanelLine = record
    Text :PFarChar;
    Data :PFarChar;
    Separator :Integer;
  end;

  PInfoPanelLineArray = ^TInfoPanelLineArray;
  TInfoPanelLineArray = packed array [0..MaxInt div SizeOf(TInfoPanelLine) - 1] of TInfoPanelLine;


          (*
          struct PanelMode
          {
            wchar_t  *ColumnTypes;
            wchar_t  *ColumnWidths;
            wchar_t **ColumnTitles;
            int    FullScreen;
            int    DetailedStatus;
            int    AlignExtensions;
            int    CaseConversion;
            wchar_t  *StatusColumnTypes;
            wchar_t  *StatusColumnWidths;
            DWORD  Reserved[2];
          };
          *)
          type
            PPanelMode = ^TPanelMode;
            TPanelMode = record
              ColumnTypes : PFarChar;
              ColumnWidths : PFarChar;
              ColumnTitles : PPCharArray;
              FullScreen : Integer;
              DetailedStatus : Integer;
              AlignExtensions : Integer;
              CaseConversion : Integer;
              StatusColumnTypes : PFarChar;
              StatusColumnWidths : PFarChar;
              Reserved : array [0..1] of DWORD;
            end;

            PPanelModeArray = ^TPanelModeArray;
            TPanelModeArray = packed array [0..MaxInt div SizeOf(TPanelMode) - 1] of TPanelMode;


          { OPENPLUGININFO_FLAGS }

          const
            OPIF_USEFILTER           = $00000001;
            OPIF_USESORTGROUPS       = $00000002;
            OPIF_USEHIGHLIGHTING     = $00000004;
            OPIF_ADDDOTS             = $00000008;
            OPIF_RAWSELECTION        = $00000010;
            OPIF_REALNAMES           = $00000020;
            OPIF_SHOWNAMESONLY       = $00000040;
            OPIF_SHOWRIGHTALIGNNAMES = $00000080;
            OPIF_SHOWPRESERVECASE    = $00000100;
          //OPIF_FINDFOLDERS         = $00000200;
            OPIF_COMPAREFATTIME      = $00000400;
            OPIF_EXTERNALGET         = $00000800;
            OPIF_EXTERNALPUT         = $00001000;
            OPIF_EXTERNALDELETE      = $00002000;
            OPIF_EXTERNALMKDIR       = $00004000;
            OPIF_USEATTRHIGHLIGHTING = $00008000;
            OPIF_USECRC32            = $00010000;


          (*
          struct KeyBarTitles
          {
            wchar_t *Titles[12];
            wchar_t *CtrlTitles[12];
            wchar_t *AltTitles[12];
            wchar_t *ShiftTitles[12];

            wchar_t *CtrlShiftTitles[12];
            wchar_t *AltShiftTitles[12];
            wchar_t *CtrlAltTitles[12];
          };
          *)
          type
            PKeyBarTitles = ^TKeyBarTitles;
            TKeyBarTitles = record
              Titles : array [0..11] of PFarChar;
              CtrlTitles : array [0..11] of PFarChar;
              AltTitles : array [0..11] of PFarChar;
              ShiftTitles : array [0..11] of PFarChar;
              CtrlShiftTitles : array [0..11] of PFarChar;
              AltShiftTitles : array [0..11] of PFarChar;
              CtrlAltTitles : array [0..11] of PFarChar;
            end;

            PKeyBarTitlesArray = ^TKeyBarTitlesArray;
            TKeyBarTitlesArray = packed array [0..MaxInt div SizeOf(TKeyBarTitles) - 1] of TKeyBarTitles;


{ OPERATION_MODES }

type
  TOperationModes = Int64;

const
  OPM_NONE      = 0;
  OPM_SILENT    = $0001;
  OPM_FIND      = $0002;
  OPM_VIEW      = $0004;
  OPM_EDIT      = $0008;
  OPM_TOPLEVEL  = $0010;
  OPM_DESCR     = $0020;
  OPM_QUICKVIEW = $0040;
  OPM_PGDN      = $0080;


(*
struct OpenPanelInfo
{
	size_t                       StructSize;
	HANDLE                       hPanel;
	OPENPANELINFO_FLAGS          Flags;
	const wchar_t               *HostFile;
	const wchar_t               *CurDir;
	const wchar_t               *Format;
	const wchar_t               *PanelTitle;
	const struct InfoPanelLine  *InfoLines;
	size_t                       InfoLinesNumber;
	const wchar_t * const       *DescrFiles;
	size_t                       DescrFilesNumber;
	const struct PanelMode      *PanelModesArray;
	size_t                       PanelModesNumber;
	int                          StartPanelMode;
	enum OPENPANELINFO_SORTMODES StartSortMode;
	int                          StartSortOrder;
	const struct KeyBarTitles   *KeyBar;
	const wchar_t               *ShortcutData;
	unsigned __int64             FreeSize;
};
*)

{!!!}

(*
struct AnalyseInfo
{
  size_t          StructSize;
  const wchar_t  *FileName;
  void           *Buffer;
  size_t          BufferSize;
  OPERATION_MODES OpMode;
};
*)
type
  PAnalyseInfo = ^TAnalyseInfo;
  TAnalyseInfo = record
    StructSize :size_t;
    FileName :PFarChar;
    Buffer :Pointer;
    BufferSize :size_t;
    OpMode :TOperationModes;
  end;


{ OPENFROM }

const
  OPEN_DISKMENU        = 0;
  OPEN_PLUGINSMENU     = 1;
  OPEN_FINDLIST        = 2;
  OPEN_SHORTCUT        = 3;
  OPEN_COMMANDLINE     = 4;
  OPEN_EDITOR          = 5;
  OPEN_VIEWER          = 6;
  OPEN_FILEPANEL       = 7;
  OPEN_DIALOG          = 8;
  OPEN_ANALYSE         = 9;
  OPEN_RIGHTDISKMENU   = 10;
  OPEN_FROM_MASK       = $FF;

  OPEN_FROMMACRO       = $10000;
  OPEN_FROMMACROSTRING = $20000;
  OPEN_FROMMACRO_MASK  = $F0000;


          { FAR_PKF_FLAGS }

          const
            PKF_CONTROL    = $00000001;
            PKF_ALT        = $00000002;
            PKF_SHIFT      = $00000004;
            PKF_PREPROCESS = $00080000; // for "Key", function ProcessKey()

          { FAR_EVENTS }

          const
            FE_CHANGEVIEWMODE = 0;
            FE_REDRAW         = 1;
            FE_IDLE           = 2;
            FE_CLOSE          = 3;
            FE_BREAK          = 4;
            FE_COMMAND        = 5;
            FE_GOTFOCUS       = 6;
            FE_KILLFOCUS      = 7;


(*
struct OpenInfo
{
  size_t StructSize;
  enum OPENFROM OpenFrom;
  const GUID* Guid;
  INT_PTR Data;
};
*)
type
  POpenInfo = ^TOpenInfo;
  TOpenInfo = record
    StructSize :size_t;
    OpenFrom :DWORD{enum OPENFROM};
    GUID :PGUID;
    Data :INT_PTR;
  end;

          (*
          struct SetDirectoryInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  const wchar_t *Dir;
                  DWORD_PTR UserData;
                  OPERATION_MODES OpMode;
          };

          struct SetFindListInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  const struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
          };

          struct PutFilesInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
                  BOOL Move;
                  const wchar_t *SrcPath;
                  OPERATION_MODES OpMode;
          };

          struct ProcessHostFileInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
                  OPERATION_MODES OpMode;
          };

          struct MakeDirectoryInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  const wchar_t *Name;
                  OPERATION_MODES OpMode;
          };

          struct CompareInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  const struct PluginPanelItem *Item1;
                  const struct PluginPanelItem *Item2;
                  enum OPENPANELINFO_SORTMODES Mode;
          };

          struct GetFindDataInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
                  OPERATION_MODES OpMode;
          };

          struct GetVirtualFindDataInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
                  const wchar_t *Path;
          };

          struct FreeFindDataInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
          };

          struct GetFilesInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
                  BOOL Move;
                  const wchar_t *DestPath;
                  OPERATION_MODES OpMode;
          };

          struct DeleteFilesInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  struct PluginPanelItem *PanelItem;
                  size_t ItemsNumber;
                  OPERATION_MODES OpMode;
          };

          struct ProcessPanelInputInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  INPUT_RECORD Rec;
          };
*)

(*
struct ProcessEditorInputInfo
{
        size_t StructSize;
        INPUT_RECORD Rec;
};
*)
type
  PProcessEditorInputInfo = ^TProcessEditorInputInfo;
  TProcessEditorInputInfo = record
    StructSize :size_t;
    Rec :INPUT_RECORD;
  end;


type
  TPROCESSCONSOLEINPUT_FLAGS = Int64;

const
  PCIF_NONE      = 0;
  PCIF_FROMMAIN  = $0000000000000001;

(*
struct ProcessConsoleInputInfo
{
	size_t StructSize;
	PROCESSCONSOLEINPUT_FLAGS Flags;
	const INPUT_RECORD *Rec;
	HANDLE hPanel;
};
*)
type
  PProcessConsoleInputInfo = ^TProcessConsoleInputInfo;
  TProcessConsoleInputInfo = record
    StructSize :size_t;
    Flags :TPROCESSCONSOLEINPUT_FLAGS;
    Rec :PInputRecord;
    hPanel :THANDLE;
  end;

(*
struct ExitInfo
{
  size_t StructSize;
};
*)
type
  PExitInfo = ^TExitInfo;
  TExitInfo = record
    StructSize :size_t;
  end;

          (*
          struct ProcessPanelEventInfo
          {
                  size_t StructSize;
                  HANDLE hPanel;
                  int Event;
                  void* Param;
          };
          *)

(*
struct ProcessEditorEventInfo
{
  size_t StructSize;
  int Event;
  void* Param;
};
*)
type
  PProcessEditorEventInfo = ^TProcessEditorEventInfo;
  TProcessEditorEventInfo = record
    StructSize :size_t;
    Event :Integer;
    Param :Pointer;
  end;

(*
struct ProcessDialogEventInfo
{
  size_t StructSize;
  int Event;
  struct FarDialogEvent* Param;
};
*)
type
  PProcessDialogEventInfo = ^TProcessDialogEventInfo;
  TProcessDialogEventInfo = record
    StructSize :size_t;
    Event :Integer;
    Param :PFarDialogEvent;
  end;

(*
struct ProcessSynchroEventInfo
{
  size_t StructSize;
  int Event;
  void* Param;
};
*)
type
  PProcessSynchroEventInfo = ^TProcessSynchroEventInfo;
  TProcessSynchroEventInfo = record
    StructSize :size_t;
    Event :Integer;
    Param :Pointer;
  end;

(*
struct ProcessViewerEventInfo
{
  size_t StructSize;
  int Event;
  void* Param;
};
*)
type
  PProcessViewerEventInfo = ^TProcessViewerEventInfo;
  TProcessViewerEventInfo = record
    StructSize :size_t;
    Event :Integer;
    Param :Pointer;
  end;

(*
struct ClosePanelInfo
{
  size_t StructSize;
  HANDLE hPanel;
};
*)
type
  PClosePanelInfo = ^TClosePanelInfo;
  TClosePanelInfo = record
    StructSize :size_t;
    hPanel :THandle;
  end;

(*
struct ConfigureInfo
{
  size_t StructSize;
  const GUID* Guid;
};
*)
type
  PConfigureInfo = ^TConfigureInfo;
  TConfigureInfo = record
    StructSize :size_t;
    GUID :PGUID;
  end;


(*
// Exported Functions
int    WINAPI AnalyseW(const struct AnalyseInfo *Info);
void   WINAPI ClosePanelW(const struct ClosePanelInfo *Info);
int    WINAPI CompareW(const struct CompareInfo *Info);
int    WINAPI ConfigureW(const struct ConfigureInfo *Info);
int    WINAPI DeleteFilesW(const struct DeleteFilesInfo *Info);
void   WINAPI ExitFARW(const struct ExitInfo *Info);
void   WINAPI FreeFindDataW(const struct FreeFindDataInfo *Info);
void   WINAPI FreeVirtualFindDataW(const struct FreeFindDataInfo *Info);
int    WINAPI GetFilesW(struct GetFilesInfo *Info);
int    WINAPI GetFindDataW(struct GetFindDataInfo *Info);
void   WINAPI GetGlobalInfoW(struct GlobalInfo *Info);
void   WINAPI GetOpenPanelInfoW(struct OpenPanelInfo *Info);
void   WINAPI GetPluginInfoW(struct PluginInfo *Info);
int    WINAPI GetVirtualFindDataW(struct GetVirtualFindDataInfo *Info);
int    WINAPI MakeDirectoryW(struct MakeDirectoryInfo *Info);
HANDLE WINAPI OpenW(const struct OpenInfo *Info);
int    WINAPI ProcessDialogEventW(const struct ProcessDialogEventInfo *Info);
int    WINAPI ProcessEditorEventW(const struct ProcessEditorEventInfo *Info);
int    WINAPI ProcessEditorInputW(const struct ProcessEditorInputInfo *Info);
int    WINAPI ProcessPanelEventW(const struct ProcessPanelEventInfo *Info);
int    WINAPI ProcessHostFileW(const struct ProcessHostFileInfo *Info);
int    WINAPI ProcessPanelInputW(const struct ProcessPanelInputInfo *Info);
int    WINAPI ProcessConsoleInputW(struct ProcessConsoleInputInfo *Info);
int    WINAPI ProcessSynchroEventW(const struct ProcessSynchroEventInfo *Info);
int    WINAPI ProcessViewerEventW(const struct ProcessViewerEventInfo *Info);
int    WINAPI PutFilesW(const struct PutFilesInfo *Info);
int    WINAPI SetDirectoryW(const struct SetDirectoryInfo *Info);
int    WINAPI SetFindListW(const struct SetFindListInfo *Info);
void   WINAPI SetStartupInfoW(const struct PluginStartupInfo *Info);
*)


(*
static __inline struct VersionInfo MAKEFARVERSION(DWORD Major, DWORD Minor, DWORD Revision, DWORD Build, enum VERSION_STAGE Stage)
{
  struct VersionInfo Info = {Major, Minor, Revision, Build, Stage};
  return Info;
}
#define FARMANAGERVERSION MAKEFARVERSION(FARMANAGERVERSION_MAJOR,FARMANAGERVERSION_MINOR, FARMANAGERVERSION_REVISION, FARMANAGERVERSION_BUILD, FARMANAGERVERSION_STAGE)
*)

function MakeFarVersion(Major :DWORD; Minor :DWORD; Revision :DWORD; Build :DWORD; Stage :Integer) :TVersionInfo;


          (*
          #define Dlg_RedrawDialog(Info,hDlg)            Info.SendDlgMessage(hDlg,DM_REDRAW,0,0)

          #define Dlg_GetDlgData(Info,hDlg)              Info.SendDlgMessage(hDlg,DM_GETDLGDATA,0,0)
          #define Dlg_SetDlgData(Info,hDlg,Data)         Info.SendDlgMessage(hDlg,DM_SETDLGDATA,0,(LONG_PTR)Data)

          #define Dlg_GetDlgItemData(Info,hDlg,ID)       Info.SendDlgMessage(hDlg,DM_GETITEMDATA,0,0)
          #define Dlg_SetDlgItemData(Info,hDlg,ID,Data)  Info.SendDlgMessage(hDlg,DM_SETITEMDATA,0,(LONG_PTR)Data)

          #define DlgItem_GetFocus(Info,hDlg)            Info.SendDlgMessage(hDlg,DM_GETFOCUS,0,0)
          #define DlgItem_SetFocus(Info,hDlg,ID)         Info.SendDlgMessage(hDlg,DM_SETFOCUS,ID,0)
          #define DlgItem_Enable(Info,hDlg,ID)           Info.SendDlgMessage(hDlg,DM_ENABLE,ID,TRUE)
          #define DlgItem_Disable(Info,hDlg,ID)          Info.SendDlgMessage(hDlg,DM_ENABLE,ID,FALSE)
          #define DlgItem_IsEnable(Info,hDlg,ID)         Info.SendDlgMessage(hDlg,DM_ENABLE,ID,-1)
          #define DlgItem_SetText(Info,hDlg,ID,Str)      Info.SendDlgMessage(hDlg,DM_SETTEXTPTR,ID,(LONG_PTR)Str)

          #define DlgItem_GetCheck(Info,hDlg,ID)         Info.SendDlgMessage(hDlg,DM_GETCHECK,ID,0)
          #define DlgItem_SetCheck(Info,hDlg,ID,State)   Info.SendDlgMessage(hDlg,DM_SETCHECK,ID,State)

          #define DlgEdit_AddHistory(Info,hDlg,ID,Str)   Info.SendDlgMessage(hDlg,DM_ADDHISTORY,ID,(LONG_PTR)Str)

          #define DlgList_AddString(Info,hDlg,ID,Str)    Info.SendDlgMessage(hDlg,DM_LISTADDSTR,ID,(LONG_PTR)Str)
          #define DlgList_GetCurPos(Info,hDlg,ID)        Info.SendDlgMessage(hDlg,DM_LISTGETCURPOS,ID,0)
          #define DlgList_SetCurPos(Info,hDlg,ID,NewPos) {struct FarListPos LPos={NewPos,-1};Info.SendDlgMessage(hDlg,DM_LISTSETCURPOS,ID,(LONG_PTR)&LPos);}
          #define DlgList_ClearList(Info,hDlg,ID)        Info.SendDlgMessage(hDlg,DM_LISTDELETE,ID,0)
          #define DlgList_DeleteItem(Info,hDlg,ID,Index) {struct FarListDelete FLDItem={Index,1}; Info.SendDlgMessage(hDlg,DM_LISTDELETE,ID,(LONG_PTR)&FLDItem);}
          #define DlgList_SortUp(Info,hDlg,ID)           Info.SendDlgMessage(hDlg,DM_LISTSORT,ID,0)
          #define DlgList_SortDown(Info,hDlg,ID)         Info.SendDlgMessage(hDlg,DM_LISTSORT,ID,1)
          #define DlgList_GetItemData(Info,hDlg,ID,Index)          Info.SendDlgMessage(hDlg,DM_LISTGETDATA,ID,Index)
          #define DlgList_SetItemStrAsData(Info,hDlg,ID,Index,Str) {struct FarListItemData FLID{Index,0,Str,0}; Info.SendDlgMessage(hDlg,DM_LISTSETDATA,ID,(LONG_PTR)&FLID);}
          *)

          function Dlg_RedrawDialog(const Info :TPluginStartupInfo; hDlg :THandle) :Integer;
          function Dlg_GetDlgData(const Info :TPluginStartupInfo; hDlg :THandle) :Integer;
          function Dlg_SetDlgData(const Info :TPluginStartupInfo; hDlg :THandle; Data :Pointer) :Integer;
          function Dlg_GetDlgItemData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function Dlg_SetDlgItemData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Data :Pointer) :Integer;
          function DlgItem_GetFocus(const Info :TPluginStartupInfo; hDlg :THandle) :Integer;
          function DlgItem_SetFocus(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgItem_Enable(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgItem_Disable(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgItem_IsEnable(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgItem_SetText(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Str :PFarChar) :Integer;
          function DlgItem_GetCheck(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgItem_SetCheck(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; State :Integer) :Integer;
          function DlgEdit_AddHistory(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Str :PFarChar) :Integer;
          function DlgList_AddString(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Str :PFarChar) :Integer;
          function DlgList_GetCurPos(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgList_SetCurPos(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; NewPos :Integer) :Integer;
          function DlgList_ClearList(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgList_DeleteItem(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Index :Integer) :Integer;
          function DlgList_SortUp(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgList_SortDown(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          function DlgList_GetItemData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Index :Integer) :Integer;
          function DlgList_SetItemStrAsData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Index :Integer; Str :PFarChar) :Integer;

          const
            FindFileId        :TGUID = '{8C9EAD29-910F-4b24-A669-EDAFBA6ED964}';
            CopyOverwriteId   :TGUID = '{9FBCB7E1-ACA2-475d-B40D-0F7365B632FF}';
            FileOpenCreateId  :TGUID = '{1D07CEE2-8F4F-480a-BE93-069B4FF59A2B}';
            FileSaveAsId      :TGUID = '{9162F965-78B8-4476-98AC-D699E5B6AFE7}';
            MakeFolderId      :TGUID = '{FAD00DBE-3FFF-4095-9232-E1CC70C67737}';
            FileAttrDlgId     :TGUID = '{80695D20-1085-44d6-8061-F3C41AB5569C}';
            CopyReadOnlyId    :TGUID = '{879A8DE6-3108-4beb-80DE-6F264991CE98}';
            CopyFilesId       :TGUID = '{FCEF11C4-5490-451d-8B4A-62FA03F52759}';
            HardSymLinkId     :TGUID = '{5EB266F4-980D-46af-B3D2-2C50E64BCA81}';

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

function MakeFarVersion(Major :DWORD; Minor :DWORD; Revision :DWORD; Build :DWORD; Stage :Integer) :TVersionInfo;
begin
  Result.Major := Major;
  Result.Minor := Minor;
  Result.Revision := Revision;
  Result.Build := Build;
  Result.Stage := Stage;
end;


          function Dlg_RedrawDialog(const Info :TPluginStartupInfo; hDlg :THandle) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_REDRAW, 0, nil);
          end;

          function Dlg_GetDlgData(const Info :TPluginStartupInfo; hDlg :THandle) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_GETDLGDATA, 0, nil);
          end;

          function Dlg_SetDlgData(const Info :TPluginStartupInfo; hDlg :THandle; Data :Pointer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_SETDLGDATA, 0, Data);
          end;

          function Dlg_GetDlgItemData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_GETITEMDATA, 0, nil);
          end;

          function Dlg_SetDlgItemData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Data :Pointer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_SETITEMDATA, 0, Data);
          end;

          function DlgItem_GetFocus(const Info :TPluginStartupInfo; hDlg :THandle) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_GETFOCUS, 0, nil)
          end;

          function DlgItem_SetFocus(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_SETFOCUS, ID, nil)
          end;

          function DlgItem_Enable(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_ENABLE, ID, Pointer(1));
          end;

          function DlgItem_Disable(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_ENABLE, ID, Pointer(0));
          end;

          function DlgItem_IsEnable(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_ENABLE, ID, Pointer(-1));
          end;

          function DlgItem_SetText(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Str :PFarChar) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_SETTEXTPTR, ID, Str);
          end;

          function DlgItem_GetCheck(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_GETCHECK, ID, nil);
          end;

          function DlgItem_SetCheck(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; State :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_SETCHECK, ID, Pointer(INT_PTR(State)));
          end;

          function DlgEdit_AddHistory(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Str :PFarChar) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_ADDHISTORY, ID, Str);
          end;

          function DlgList_AddString(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Str :PFarChar) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_LISTADDSTR, ID, Str);
          end;

          function DlgList_GetCurPos(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_LISTGETCURPOS, ID, nil);
          end;

          function DlgList_SetCurPos(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; NewPos :Integer) :Integer;
          var
            LPos :TFarListPos;
          begin
            LPos.SelectPos := NewPos;
            LPos.TopPos := -1;
            Result := Info.SendDlgMessage(hDlg, DM_LISTSETCURPOS, ID, @LPos);
          end;

          function DlgList_ClearList(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg,DM_LISTDELETE,ID,nil)
          end;

          function DlgList_DeleteItem(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Index :Integer) :Integer;
          var
            FLDItem :TFarListDelete;
          begin
            FLDItem.StartIndex := Index;
            FLDItem.Count := 1;
            Result := Info.SendDlgMessage(hDlg, DM_LISTDELETE, ID, @FLDItem);
          end;

          function DlgList_SortUp(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_LISTSORT, ID, nil);
          end;

          function DlgList_SortDown(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_LISTSORT, ID, Pointer(1));
          end;

          function DlgList_GetItemData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Index :Integer) :Integer;
          begin
            Result := Info.SendDlgMessage(hDlg, DM_LISTGETDATA, ID, Pointer(INT_PTR(Index)));
          end;

          function DlgList_SetItemStrAsData(const Info :TPluginStartupInfo; hDlg :THandle; ID :Integer; Index :Integer; Str :PFarChar) :Integer;
          var
            FLID :TFarListItemData;
          begin
            FLID.Index := Index;
            FLID.DataSize := 0;
            FLID.Data := Str;
            FLID.Reserved := 0;
            Result := Info.SendDlgMessage (hDlg, DM_LISTSETDATA, ID, @FLID);
          end;


end.

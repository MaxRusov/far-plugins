{$I Defines.inc}

{-$Define bUseOleVariant}

{*******************************************************}
{                                                       }
{       Borland Delphi Runtime Library                  }
{       ActiveX / OLE 2 Interface Unit                  }
{                                                       }
{       Copyright (C) 1997,99 Inprise Corporation       }
{                                                       }
{*******************************************************}

unit ActiveX;

interface

uses Windows, Messages;

{ Do not WEAKPACKAGE this unit.
  This unit requires startup code to initialize constants. }


type
 {$ifdef bUseOleVariant}
  _OleVariant = OleVariant;
 {$else}
  _OleVariant = Pointer;
 {$endif bUseOleVariant}

const

{ from WTYPES.H }
  MEMCTX_TASK      = 1;
  MEMCTX_SHARED    = 2;
  MEMCTX_MACSYSTEM = 3;
  MEMCTX_UNKNOWN   = -1;
  MEMCTX_SAME      = -2;

  ROTFLAGS_REGISTRATIONKEEPSALIVE = 1;
  ROTFLAGS_ALLOWANYCLIENT         = 2;

  CLSCTX_INPROC_SERVER     = 1;
  CLSCTX_INPROC_HANDLER    = 2;
  CLSCTX_LOCAL_SERVER      = 4;
  CLSCTX_INPROC_SERVER16   = 8;
  CLSCTX_REMOTE_SERVER     = $10;
  CLSCTX_INPROC_HANDLER16  = $20;
  CLSCTX_INPROC_SERVERX86  = $40;
  CLSCTX_INPROC_HANDLERX86 = $80;

{ from OBJBASE }
  CLSCTX_ALL    = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER or
      CLSCTX_LOCAL_SERVER;
  CLSCTX_INPROC = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER;
  CLSCTX_SERVER = CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER;

  COM_RIGHTS_EXECUTE = 1;

{ from WTYPES.H }
  MSHLFLAGS_NORMAL      = 0;
  MSHLFLAGS_TABLESTRONG = 1;
  MSHLFLAGS_TABLEWEAK   = 2;
  MSHLFLAGS_NOPING      = 4;

  MSHCTX_LOCAL            = 0;
  MSHCTX_NOSHAREDMEM      = 1;
  MSHCTX_DIFFERENTMACHINE = 2;
  MSHCTX_INPROC           = 3;

  DVASPECT_CONTENT   = 1;
  DVASPECT_THUMBNAIL = 2;
  DVASPECT_ICON      = 4;
  DVASPECT_DOCPRINT  = 8;

  STGC_DEFAULT                            = 0;
  STGC_OVERWRITE                          = 1;
  STGC_ONLYIFCURRENT                      = 2;
  STGC_DANGEROUSLYCOMMITMERELYTODISKCACHE = 4;

  STGMOVE_MOVE        = 0;
  STGMOVE_COPY        = 1;
  STGMOVE_SHALLOWCOPY = 2;

  STATFLAG_DEFAULT = 0;
  STATFLAG_NONAME  = 1;

{ from OBJIDL.H }
  BIND_MAYBOTHERUSER     = 1;
  BIND_JUSTTESTEXISTENCE = 2;

  MKSYS_NONE             = 0;
  MKSYS_GENERICCOMPOSITE = 1;
  MKSYS_FILEMONIKER      = 2;
  MKSYS_ANTIMONIKER      = 3;
  MKSYS_ITEMMONIKER      = 4;
  MKSYS_POINTERMONIKER   = 5;

  MKRREDUCE_ONE         = 3 shl 16;
  MKRREDUCE_TOUSER      = 2 shl 16;
  MKRREDUCE_THROUGHUSER = 1 shl 16;
  MKRREDUCE_ALL         = 0;

  STGTY_STORAGE   = 1;
  STGTY_STREAM    = 2;
  STGTY_LOCKBYTES = 3;
  STGTY_PROPERTY  = 4;

  STREAM_SEEK_SET = 0;
  STREAM_SEEK_CUR = 1;
  STREAM_SEEK_END = 2;

  LOCK_WRITE     = 1;
  LOCK_EXCLUSIVE = 2;
  LOCK_ONLYONCE  = 4;

  ADVF_NODATA            = 1;
  ADVF_PRIMEFIRST        = 2;
  ADVF_ONLYONCE          = 4;
  ADVF_DATAONSTOP        = 64;
  ADVFCACHE_NOHANDLER    = 8;
  ADVFCACHE_FORCEBUILTIN = 16;
  ADVFCACHE_ONSAVE       = 32;

  TYMED_HGLOBAL  = 1;
  TYMED_FILE     = 2;
  TYMED_ISTREAM  = 4;
  TYMED_ISTORAGE = 8;
  TYMED_GDI      = 16;
  TYMED_MFPICT   = 32;
  TYMED_ENHMF    = 64;
  TYMED_NULL     = 0;

  DATADIR_GET = 1;
  DATADIR_SET = 2;

  CALLTYPE_TOPLEVEL             = 1;
  CALLTYPE_NESTED               = 2;
  CALLTYPE_ASYNC                = 3;
  CALLTYPE_TOPLEVEL_CALLPENDING = 4;
  CALLTYPE_ASYNC_CALLPENDING    = 5;

  SERVERCALL_ISHANDLED  = 0;
  SERVERCALL_REJECTED   = 1;
  SERVERCALL_RETRYLATER = 2;

  PENDINGTYPE_TOPLEVEL = 1;
  PENDINGTYPE_NESTED   = 2;

  PENDINGMSG_CANCELCALL     = 0;
  PENDINGMSG_WAITNOPROCESS  = 1;
  PENDINGMSG_WAITDEFPROCESS = 2;

  PROPSETFLAG_DEFAULT   = 0;
  PROPSETFLAG_NONSIMPLE	= 1;
  PROPSETFLAG_ANSI	= 2;

{ from OBJBASE.H }
  REGCLS_SINGLEUSE      = 0;
  REGCLS_MULTIPLEUSE    = 1;
  REGCLS_MULTI_SEPARATE = 2;
  REGCLS_SUSPENDED      = 4;

  MARSHALINTERFACE_MIN = 500;

  CWCSTORAGENAME = 32;

  STGM_DIRECT           = $00000000;
  STGM_TRANSACTED       = $00010000;
  STGM_SIMPLE           = $08000000;

  STGM_READ             = $00000000;
  STGM_WRITE            = $00000001;
  STGM_READWRITE        = $00000002;

  STGM_SHARE_DENY_NONE  = $00000040;
  STGM_SHARE_DENY_READ  = $00000030;
  STGM_SHARE_DENY_WRITE = $00000020;
  STGM_SHARE_EXCLUSIVE  = $00000010;

  STGM_PRIORITY         = $00040000;
  STGM_DELETEONRELEASE  = $04000000;
  STGM_NOSCRATCH        = $00100000;

  STGM_CREATE           = $00001000;
  STGM_CONVERT          = $00020000;
  STGM_FAILIFTHERE      = $00000000;

  FADF_AUTO      = $0001;  { array is allocated on the stack }
  FADF_STATIC    = $0002;  { array is staticly allocated }
  FADF_EMBEDDED  = $0004;  { array is embedded in a structure }
  FADF_FIXEDSIZE = $0010;  { array may not be resized or reallocated }
  FADF_BSTR      = $0100;  { an array of BSTRs }
  FADF_UNKNOWN   = $0200;  { an array of IUnknown }
  FADF_DISPATCH  = $0400;  { an array of IDispatch }
  FADF_VARIANT   = $0800;  { an array of VARIANTs }
  FADF_RESERVED  = $F0E8;  { bits reserved for future use }

{ from WTYPES.H }
{ VARENUM usage key,

    [V] - may appear in a VARIANT
    [T] - may appear in a TYPEDESC
    [P] - may appear in an OLE property set
    [S] - may appear in a Safe Array }

  VT_EMPTY           = 0;   { [V]   [P]  nothing                     }
  VT_NULL            = 1;   { [V]        SQL style Null              }
  VT_I2              = 2;   { [V][T][P]  2 byte signed int           }
  VT_I4              = 3;   { [V][T][P]  4 byte signed int           }
  VT_R4              = 4;   { [V][T][P]  4 byte real                 }
  VT_R8              = 5;   { [V][T][P]  8 byte real                 }
  VT_CY              = 6;   { [V][T][P]  currency                    }
  VT_DATE            = 7;   { [V][T][P]  date                        }
  VT_BSTR            = 8;   { [V][T][P]  binary string               }
  VT_DISPATCH        = 9;   { [V][T]     IDispatch FAR*              }
  VT_ERROR           = 10;  { [V][T]     SCODE                       }
  VT_BOOL            = 11;  { [V][T][P]  True=-1, False=0            }
  VT_VARIANT         = 12;  { [V][T][P]  VARIANT FAR*                }
  VT_UNKNOWN         = 13;  { [V][T]     IUnknown FAR*               }
  VT_DECIMAL         = 14;  { [V][T]   [S]  16 byte fixed point      }

  VT_I1              = 16;  {    [T]     signed char                 }
  VT_UI1             = 17;  {    [T]     unsigned char               }
  VT_UI2             = 18;  {    [T]     unsigned short              }
  VT_UI4             = 19;  {    [T]     unsigned short              }
  VT_I8              = 20;  {    [T][P]  signed 64-bit int           }
  VT_UI8             = 21;  {    [T]     unsigned 64-bit int         }
  VT_INT             = 22;  {    [T]     signed machine int          }
  VT_UINT            = 23;  {    [T]     unsigned machine int        }
  VT_VOID            = 24;  {    [T]     C style void                }
  VT_HRESULT         = 25;  {    [T]                                 }
  VT_PTR             = 26;  {    [T]     pointer type                }
  VT_SAFEARRAY       = 27;  {    [T]     (use VT_ARRAY in VARIANT)   }
  VT_CARRAY          = 28;  {    [T]     C style array               }
  VT_USERDEFINED     = 29;  {    [T]     user defined type          }
  VT_LPSTR           = 30;  {    [T][P]  null terminated string      }
  VT_LPWSTR          = 31;  {    [T][P]  wide null terminated string }

  VT_FILETIME        = 64;  {       [P]  FILETIME                    }
  VT_BLOB            = 65;  {       [P]  Length prefixed bytes       }
  VT_STREAM          = 66;  {       [P]  Name of the stream follows  }
  VT_STORAGE         = 67;  {       [P]  Name of the storage follows }
  VT_STREAMED_OBJECT = 68;  {       [P]  Stream contains an object   }
  VT_STORED_OBJECT   = 69;  {       [P]  Storage contains an object  }
  VT_BLOB_OBJECT     = 70;  {       [P]  Blob contains an object     }
  VT_CF              = 71;  {       [P]  Clipboard format            }
  VT_CLSID           = 72;  {       [P]  A Class ID                  }

  VT_VECTOR        = $1000; {       [P]  simple counted array        }
  VT_ARRAY         = $2000; { [V]        SAFEARRAY*                  }
  VT_BYREF         = $4000; { [V]                                    }
  VT_RESERVED      = $8000;
  VT_ILLEGAL       = $ffff;
  VT_ILLEGALMASKED = $0fff;
  VT_TYPEMASK      = $0fff;

type
  PROPID = ULONG;
  PPropID = ^TPropID;
  TPropID = PROPID;

{ from OAIDL.H }

const
  TKIND_ENUM      = 0;
  TKIND_RECORD    = 1;
  TKIND_MODULE    = 2;
  TKIND_INTERFACE = 3;
  TKIND_DISPATCH  = 4;
  TKIND_COCLASS   = 5;
  TKIND_ALIAS     = 6;
  TKIND_UNION     = 7;
  TKIND_MAX       = 8;

  CC_CDECL       = 1;
  CC_PASCAL      = 2;
  CC_MACPASCAL   = 3;
  CC_STDCALL     = 4;
  CC_FPFASTCALL  = 5;
  CC_SYSCALL     = 6;
  CC_MPWCDECL    = 7;
  CC_MPWPASCAL   = 8;
  CC_MAX         = 9;

  FUNC_VIRTUAL     = 0;
  FUNC_PUREVIRTUAL = 1;
  FUNC_NONVIRTUAL  = 2;
  FUNC_STATIC      = 3;
  FUNC_DISPATCH    = 4;

  INVOKE_FUNC           = 1;
  INVOKE_PROPERTYGET    = 2;
  INVOKE_PROPERTYPUT    = 4;
  INVOKE_PROPERTYPUTREF = 8;

  VAR_PERINSTANCE = 0;
  VAR_STATIC      = 1;
  VAR_CONST       = 2;
  VAR_DISPATCH    = 3;

  IMPLTYPEFLAG_FDEFAULT        = 1;
  IMPLTYPEFLAG_FSOURCE         = 2;
  IMPLTYPEFLAG_FRESTRICTED     = 4;
  IMPLTYPEFLAG_FDEFAULTVTABLE    = 8;

  TYPEFLAG_FAPPOBJECT     = $0001;
  TYPEFLAG_FCANCREATE     = $0002;
  TYPEFLAG_FLICENSED      = $0004;
  TYPEFLAG_FPREDECLID     = $0008;
  TYPEFLAG_FHIDDEN        = $0010;
  TYPEFLAG_FCONTROL       = $0020;
  TYPEFLAG_FDUAL          = $0040;
  TYPEFLAG_FNONEXTENSIBLE = $0080;
  TYPEFLAG_FOLEAUTOMATION = $0100;
  TYPEFLAG_FRESTRICTED    = $0200;
  TYPEFLAG_FAGGREGATABLE  = $0400;
  TYPEFLAG_FREPLACEABLE   = $0800;
  TYPEFLAG_FDISPATCHABLE  = $1000;
  TYPEFLAG_FREVERSEBIND   = $2000;

  FUNCFLAG_FRESTRICTED       = $0001;
  FUNCFLAG_FSOURCE           = $0002;
  FUNCFLAG_FBINDABLE         = $0004;
  FUNCFLAG_FREQUESTEDIT      = $0008;
  FUNCFLAG_FDISPLAYBIND      = $0010;
  FUNCFLAG_FDEFAULTBIND      = $0020;
  FUNCFLAG_FHIDDEN           = $0040;
  FUNCFLAG_FUSESGETLASTERROR = $0080;
  FUNCFLAG_FDEFAULTCOLLELEM  = $0100;
  FUNCFLAG_FUIDEFAULT        = $0200;
  FUNCFLAG_FNONBROWSABLE          = $0400;
  FUNCFLAG_FREPLACEABLE      = $0800;
  FUNCFLAG_FIMMEDIATEBIND         = $1000;

  VARFLAG_FREADONLY        = $0001;
  VARFLAG_FSOURCE          = $0002;
  VARFLAG_FBINDABLE        = $0004;
  VARFLAG_FREQUESTEDIT     = $0008;
  VARFLAG_FDISPLAYBIND     = $0010;
  VARFLAG_FDEFAULTBIND     = $0020;
  VARFLAG_FHIDDEN          = $0040;
  VARFLAG_FRESTRICTED      = $0080;
  VARFLAG_FDEFAULTCOLLELEM      = $0100;
  VARFLAG_FUIDEFAULT          = $0200;
  VARFLAG_FNONBROWSABLE    = $0400;
  VARFLAG_FREPLACEABLE     = $0800;
  VARFLAG_FIMMEDIATEBIND        = $1000;

  DISPID_VALUE       = 0;
  DISPID_UNKNOWN     = -1;
  DISPID_PROPERTYPUT = -3;
  DISPID_NEWENUM     = -4;
  DISPID_EVALUATE    = -5;
  DISPID_CONSTRUCTOR = -6;
  DISPID_DESTRUCTOR  = -7;
  DISPID_COLLECT     = -8;

  DESCKIND_NONE = 0;
  DESCKIND_FUNCDESC = 1;
  DESCKIND_VARDESC = 2;
  DESCKIND_TYPECOMP = 3;
  DESCKIND_IMPLICITAPPOBJ = 4;
  DESCKIND_MAX = 5;

  SYS_WIN16 = 0;
  SYS_WIN32 = 1;
  SYS_MAC   = 2;

  LIBFLAG_FRESTRICTED   = 1;
  LIBFLAG_FCONTROL      = 2;
  LIBFLAG_FHIDDEN       = 4;
  LIBFLAG_FHASDISKIMAGE = 8;

{ from OLEAUTO.H }
  STDOLE_MAJORVERNUM = 1;
  STDOLE_MINORVERNUM = 0;
  STDOLE_LCID = 0;

  VARIANT_NOVALUEPROP = 1;

  VAR_TIMEVALUEONLY = 1;
  VAR_DATEVALUEONLY = 2;

  MEMBERID_NIL = DISPID_UNKNOWN;
  ID_DEFAULTINST = -2;

  DISPATCH_METHOD         = 1;
  DISPATCH_PROPERTYGET    = 2;
  DISPATCH_PROPERTYPUT    = 4;
  DISPATCH_PROPERTYPUTREF = 8;

{ from OAIDL.H }
  IDLFLAG_NONE    = 0;
  IDLFLAG_FIN     = 1;
  IDLFLAG_FOUT    = 2;
  IDLFLAG_FLCID   = 4;
  IDLFLAG_FRETVAL = 8;

  PARAMFLAG_NONE          = $00;
  PARAMFLAG_FIN           = $01;
  PARAMFLAG_FOUT          = $02;
  PARAMFLAG_FLCID         = $04;
  PARAMFLAG_FRETVAL       = $08;
  PARAMFLAG_FOPT          = $10;
  PARAMFLAG_FHASDEFAULT   = $20;

{ from OLE2.H }
  OLEIVERB_PRIMARY          = 0;
  OLEIVERB_SHOW             = -1;
  OLEIVERB_OPEN             = -2;
  OLEIVERB_HIDE             = -3;
  OLEIVERB_UIACTIVATE       = -4;
  OLEIVERB_INPLACEACTIVATE  = -5;
  OLEIVERB_DISCARDUNDOSTATE = -6;

  EMBDHLP_INPROC_HANDLER = $00000000;
  EMBDHLP_INPROC_SERVER  = $00000001;
  EMBDHLP_CREATENOW      = $00000000;
  EMBDHLP_DELAYCREATE    = $00010000;

  OLECREATE_LEAVERUNNING = $00000001;

{ from OLEIDL.H }

type
  BORDERWIDTHS = TRect;
  PBorderWidths = ^TBorderWidths;
  TBorderWidths = BORDERWIDTHS;

const
  UPDFCACHE_NODATACACHE = 1;
  UPDFCACHE_ONSAVECACHE = 2;
  UPDFCACHE_ONSTOPCACHE = 4;
  UPDFCACHE_NORMALCACHE = 8;
  UPDFCACHE_IFBLANK     = $10;
  UPDFCACHE_ONLYIFBLANK = DWORD($80000000);

  UPDFCACHE_IFBLANKORONSAVECACHE = UPDFCACHE_IFBLANK or UPDFCACHE_ONSAVECACHE;
  UPDFCACHE_ALL                  = not UPDFCACHE_ONLYIFBLANK;
  UPDFCACHE_ALLBUTNODATACACHE    = UPDFCACHE_ALL and not UPDFCACHE_NODATACACHE;

  DISCARDCACHE_SAVEIFDIRTY = 0;
  DISCARDCACHE_NOSAVE      = 1;

  OLEGETMONIKER_ONLYIFTHERE = 1;
  OLEGETMONIKER_FORCEASSIGN = 2;
  OLEGETMONIKER_UNASSIGN    = 3;
  OLEGETMONIKER_TEMPFORUSER = 4;

  OLEWHICHMK_CONTAINER = 1;
  OLEWHICHMK_OBJREL    = 2;
  OLEWHICHMK_OBJFULL   = 3;

  USERCLASSTYPE_FULL    = 1;
  USERCLASSTYPE_SHORT   = 2;
  USERCLASSTYPE_APPNAME = 3;

  OLEMISC_RECOMPOSEONRESIZE            = 1;
  OLEMISC_ONLYICONIC                   = 2;
  OLEMISC_INSERTNOTREPLACE             = 4;
  OLEMISC_STATIC                       = 8;
  OLEMISC_CANTLINKINSIDE                    = $10;
  OLEMISC_CANLINKBYOLE1                = $20;
  OLEMISC_ISLINKOBJECT                 = $40;
  OLEMISC_INSIDEOUT                       = $80;
  OLEMISC_ACTIVATEWHENVISIBLE            = $100;
  OLEMISC_RENDERINGISDEVICEINDEPENDENT  = $200;
  OLEMISC_INVISIBLEATRUNTIME             = $400;
  OLEMISC_ALWAYSRUN                       = $800;
  OLEMISC_ACTSLIKEBUTTON                    = $1000;
  OLEMISC_ACTSLIKELABEL                = $2000;
  OLEMISC_NOUIACTIVATE                 = $4000;
  OLEMISC_ALIGNABLE                       = $8000;
  OLEMISC_SIMPLEFRAME                  = $10000;
  OLEMISC_SETCLIENTSITEFIRST           = $20000;
  OLEMISC_IMEMODE                            = $40000;
  OLEMISC_IGNOREACTIVATEWHENVISIBLE    = $80000;
  OLEMISC_WANTSTOMENUMERGE             = $100000;
  OLEMISC_SUPPORTSMULTILEVELUNDO              = $200000;

  OLECLOSE_SAVEIFDIRTY = 0;
  OLECLOSE_NOSAVE      = 1;
  OLECLOSE_PROMPTSAVE  = 2;

  OLERENDER_NONE   = 0;
  OLERENDER_DRAW   = 1;
  OLERENDER_FORMAT = 2;
  OLERENDER_ASIS   = 3;

  OLEUPDATE_ALWAYS = 1;
  OLEUPDATE_ONCALL = 3;

  OLELINKBIND_EVENIFCLASSDIFF = 1;

  BINDSPEED_INDEFINITE = 1;
  BINDSPEED_MODERATE   = 2;
  BINDSPEED_IMMEDIATE  = 3;

  OLECONTF_EMBEDDINGS    = 1;
  OLECONTF_LINKS         = 2;
  OLECONTF_OTHERS        = 4;
  OLECONTF_ONLYUSER      = 8;
  OLECONTF_ONLYIFRUNNING = 16;

  DROPEFFECT_NONE   = 0;
  DROPEFFECT_COPY   = 1;
  DROPEFFECT_MOVE   = 2;
  DROPEFFECT_LINK   = 4;
  DROPEFFECT_SCROLL = DWORD($80000000);

  DD_DEFSCROLLINSET    = 11;
  DD_DEFSCROLLDELAY    = 50;
  DD_DEFSCROLLINTERVAL = 50;
  DD_DEFDRAGDELAY      = 200;
  DD_DEFDRAGMINDIST    = 2;

  OLEVERBATTRIB_NEVERDIRTIES    = 1;
  OLEVERBATTRIB_ONCONTAINERMENU = 2;

{ from OLECTL.H}
{ OLE control status codes }

  CTL_E_ILLEGALFUNCTIONCALL       = HRESULT($800A0000) + 5;
  CTL_E_OVERFLOW                  = HRESULT($800A0000) + 6;
  CTL_E_OUTOFMEMORY               = HRESULT($800A0000) + 7;
  CTL_E_DIVISIONBYZERO            = HRESULT($800A0000) + 11;
  CTL_E_OUTOFSTRINGSPACE          = HRESULT($800A0000) + 14;
  CTL_E_OUTOFSTACKSPACE           = HRESULT($800A0000) + 28;
  CTL_E_BADFILENAMEORNUMBER       = HRESULT($800A0000) + 52;
  CTL_E_FILENOTFOUND              = HRESULT($800A0000) + 53;
  CTL_E_BADFILEMODE               = HRESULT($800A0000) + 54;
  CTL_E_FILEALREADYOPEN           = HRESULT($800A0000) + 55;
  CTL_E_DEVICEIOERROR             = HRESULT($800A0000) + 57;
  CTL_E_FILEALREADYEXISTS         = HRESULT($800A0000) + 58;
  CTL_E_BADRECORDLENGTH           = HRESULT($800A0000) + 59;
  CTL_E_DISKFULL                  = HRESULT($800A0000) + 61;
  CTL_E_BADRECORDNUMBER           = HRESULT($800A0000) + 63;
  CTL_E_BADFILENAME               = HRESULT($800A0000) + 64;
  CTL_E_TOOMANYFILES              = HRESULT($800A0000) + 67;
  CTL_E_DEVICEUNAVAILABLE         = HRESULT($800A0000) + 68;
  CTL_E_PERMISSIONDENIED          = HRESULT($800A0000) + 70;
  CTL_E_DISKNOTREADY              = HRESULT($800A0000) + 71;
  CTL_E_PATHFILEACCESSERROR       = HRESULT($800A0000) + 75;
  CTL_E_PATHNOTFOUND              = HRESULT($800A0000) + 76;
  CTL_E_INVALIDPATTERNSTRING      = HRESULT($800A0000) + 93;
  CTL_E_INVALIDUSEOFNULL          = HRESULT($800A0000) + 94;
  CTL_E_INVALIDFILEFORMAT         = HRESULT($800A0000) + 321;
  CTL_E_INVALIDPROPERTYVALUE      = HRESULT($800A0000) + 380;
  CTL_E_INVALIDPROPERTYARRAYINDEX = HRESULT($800A0000) + 381;
  CTL_E_SETNOTSUPPORTEDATRUNTIME  = HRESULT($800A0000) + 382;
  CTL_E_SETNOTSUPPORTED           = HRESULT($800A0000) + 383;
  CTL_E_NEEDPROPERTYARRAYINDEX    = HRESULT($800A0000) + 385;
  CTL_E_SETNOTPERMITTED           = HRESULT($800A0000) + 387;
  CTL_E_GETNOTSUPPORTEDATRUNTIME  = HRESULT($800A0000) + 393;
  CTL_E_GETNOTSUPPORTED           = HRESULT($800A0000) + 394;
  CTL_E_PROPERTYNOTFOUND          = HRESULT($800A0000) + 422;
  CTL_E_INVALIDCLIPBOARDFORMAT    = HRESULT($800A0000) + 460;
  CTL_E_INVALIDPICTURE            = HRESULT($800A0000) + 481;
  CTL_E_PRINTERERROR              = HRESULT($800A0000) + 482;
  CTL_E_CANTSAVEFILETOTEMP        = HRESULT($800A0000) + 735;
  CTL_E_SEARCHTEXTNOTFOUND        = HRESULT($800A0000) + 744;
  CTL_E_REPLACEMENTSTOOLONG       = HRESULT($800A0000) + 746;

  CTL_E_CUSTOM_FIRST = HRESULT($800A0000) + 600;

{ IClassFactory2 status codes }

  CLASS_E_NOTLICENSED = CLASSFACTORY_E_FIRST + 2;

{ IConnectionPoint status codes }

  CONNECT_E_FIRST = HRESULT($80040200);
  CONNECT_E_LAST  = HRESULT($8004020F);
  CONNECT_S_FIRST = $00040200;
  CONNECT_S_LAST  = $0004020F;

  CONNECT_E_NOCONNECTION  = CONNECT_E_FIRST + 0;
  CONNECT_E_ADVISELIMIT   = CONNECT_E_FIRST + 1;
  CONNECT_E_CANNOTCONNECT = CONNECT_E_FIRST + 2;
  CONNECT_E_OVERRIDDEN    = CONNECT_E_FIRST + 3;

{ DllRegisterServer/DllUnregisterServer status codes }

  SELFREG_E_FIRST = HRESULT($80040200);
  SELFREG_E_LAST  = HRESULT($80040200);
  SELFREG_S_FIRST = $00040200;
  SELFREG_S_LAST  = $00040200;

  SELFREG_E_TYPELIB = SELFREG_E_FIRST + 0;
  SELFREG_E_CLASS   = SELFREG_E_FIRST + 1;

{ IPerPropertyBrowsing status codes }

  PERPROP_E_FIRST = HRESULT($80040200);
  PERPROP_E_LAST  = HRESULT($8004020F);
  PERPROP_S_FIRST = $00040200;
  PERPROP_S_LAST  = $0004020F;

  PERPROP_E_NOPAGEAVAILABLE = PERPROP_E_FIRST + 0;

{ Additional OLEIVERB constants }

  OLEIVERB_PROPERTIES = -7;

{ Additional variant type tags for property sets }

  VT_STREAMED_PROPSET = 73;  { Stream contains a property set }
  VT_STORED_PROPSET   = 74;  { Storage contains a property set }
  VT_BLOB_PROPSET     = 75;  { Blob contains a property set }
  VT_VERBOSE_ENUM     = 76;  { Enum value with text string }

{ Variant type tags that are just aliases for others }

  VT_COLOR          = VT_I4;
  VT_XPOS_PIXELS    = VT_I4;
  VT_YPOS_PIXELS    = VT_I4;
  VT_XSIZE_PIXELS   = VT_I4;
  VT_YSIZE_PIXELS   = VT_I4;
  VT_XPOS_HIMETRIC  = VT_I4;
  VT_YPOS_HIMETRIC  = VT_I4;
  VT_XSIZE_HIMETRIC = VT_I4;
  VT_YSIZE_HIMETRIC = VT_I4;
  VT_TRISTATE       = VT_I2;
  VT_OPTEXCLUSIVE   = VT_BOOL;
  VT_FONT           = VT_DISPATCH;
  VT_PICTURE        = VT_DISPATCH;
  VT_HANDLE         = VT_I4;

{ Reflected window message IDs }

  OCM__BASE = WM_USER + $1C00;

  OCM_COMMAND           = OCM__BASE + WM_COMMAND;
  OCM_CTLCOLORBTN       = OCM__BASE + WM_CTLCOLORBTN;
  OCM_CTLCOLOREDIT      = OCM__BASE + WM_CTLCOLOREDIT;
  OCM_CTLCOLORDLG       = OCM__BASE + WM_CTLCOLORDLG;
  OCM_CTLCOLORLISTBOX   = OCM__BASE + WM_CTLCOLORLISTBOX;
  OCM_CTLCOLORMSGBOX    = OCM__BASE + WM_CTLCOLORMSGBOX;
  OCM_CTLCOLORSCROLLBAR = OCM__BASE + WM_CTLCOLORSCROLLBAR;
  OCM_CTLCOLORSTATIC    = OCM__BASE + WM_CTLCOLORSTATIC;
  OCM_DRAWITEM          = OCM__BASE + WM_DRAWITEM;
  OCM_MEASUREITEM       = OCM__BASE + WM_MEASUREITEM;
  OCM_DELETEITEM        = OCM__BASE + WM_DELETEITEM;
  OCM_VKEYTOITEM        = OCM__BASE + WM_VKEYTOITEM;
  OCM_CHARTOITEM        = OCM__BASE + WM_CHARTOITEM;
  OCM_COMPAREITEM       = OCM__BASE + WM_COMPAREITEM;
  OCM_HSCROLL           = OCM__BASE + WM_HSCROLL;
  OCM_VSCROLL           = OCM__BASE + WM_VSCROLL;
  OCM_PARENTNOTIFY      = OCM__BASE + WM_PARENTNOTIFY;
  OCM_NOTIFY            = OCM__BASE + WM_NOTIFY;

{ from OCIDL.H }
{ TControlInfo.dwFlags masks }

  CTRLINFO_EATS_RETURN = 1;  { Control doesn't send Return to container }
  CTRLINFO_EATS_ESCAPE = 2;  { Control doesn't send Escape to container }

{ IOleControlSite.TransformCoords flags }

  XFORMCOORDS_POSITION            = 1;
  XFORMCOORDS_SIZE                = 2;
  XFORMCOORDS_HIMETRICTOCONTAINER = 4;
  XFORMCOORDS_CONTAINERTOHIMETRIC = 8;

{ IPropertyPageSite.OnStatusChange flags }

  PROPPAGESTATUS_DIRTY    = 1;  { Values in page have changed }
  PROPPAGESTATUS_VALIDATE = 2;  { Appropriate time to validate/apply }
  PROPPAGESTATUS_CLEAN    = 4;

{ Picture attributes }

  PICTURE_SCALABLE    = 1;
  PICTURE_TRANSPARENT = 2;

{ from OLECTL.H }
{ TPictDesc.picType values }

  PICTYPE_UNINITIALIZED = -1;
  PICTYPE_NONE          = 0;
  PICTYPE_BITMAP        = 1;
  PICTYPE_METAFILE      = 2;
  PICTYPE_ICON          = 3;
  PICTYPE_ENHMETAFILE   = 4;

{ Standard dispatch ID constants }

  DISPID_AUTOSIZE      = -500;
  DISPID_BACKCOLOR     = -501;
  DISPID_BACKSTYLE     = -502;
  DISPID_BORDERCOLOR   = -503;
  DISPID_BORDERSTYLE   = -504;
  DISPID_BORDERWIDTH   = -505;
  DISPID_DRAWMODE      = -507;
  DISPID_DRAWSTYLE     = -508;
  DISPID_DRAWWIDTH     = -509;
  DISPID_FILLCOLOR     = -510;
  DISPID_FILLSTYLE     = -511;
  DISPID_FONT          = -512;
  DISPID_FORECOLOR     = -513;
  DISPID_ENABLED       = -514;
  DISPID_HWND          = -515;
  DISPID_TABSTOP       = -516;
  DISPID_TEXT          = -517;
  DISPID_CAPTION       = -518;
  DISPID_BORDERVISIBLE = -519;
  DISPID_APPEARANCE    = -520;
  DISPID_MOUSEPOINTER  = -521;
  DISPID_MOUSEICON     = -522;
  DISPID_PICTURE       = -523;
  DISPID_VALID         = -524;
  DISPID_READYSTATE    = -525;

  DISPID_REFRESH  = -550;
  DISPID_DOCLICK  = -551;
  DISPID_ABOUTBOX = -552;

  DISPID_CLICK            = -600;
  DISPID_DBLCLICK         = -601;
  DISPID_KEYDOWN          = -602;
  DISPID_KEYPRESS         = -603;
  DISPID_KEYUP            = -604;
  DISPID_MOUSEDOWN        = -605;
  DISPID_MOUSEMOVE        = -606;
  DISPID_MOUSEUP          = -607;
  DISPID_ERROREVENT       = -608;
  DISPID_READYSTATECHANGE = -609;

  DISPID_AMBIENT_BACKCOLOR         = -701;
  DISPID_AMBIENT_DISPLAYNAME       = -702;
  DISPID_AMBIENT_FONT              = -703;
  DISPID_AMBIENT_FORECOLOR         = -704;
  DISPID_AMBIENT_LOCALEID          = -705;
  DISPID_AMBIENT_MESSAGEREFLECT    = -706;
  DISPID_AMBIENT_SCALEUNITS        = -707;
  DISPID_AMBIENT_TEXTALIGN         = -708;
  DISPID_AMBIENT_USERMODE          = -709;
  DISPID_AMBIENT_UIDEAD            = -710;
  DISPID_AMBIENT_SHOWGRABHANDLES   = -711;
  DISPID_AMBIENT_SHOWHATCHING      = -712;
  DISPID_AMBIENT_DISPLAYASDEFAULT  = -713;
  DISPID_AMBIENT_SUPPORTSMNEMONICS = -714;
  DISPID_AMBIENT_AUTOCLIP          = -715;
  DISPID_AMBIENT_APPEARANCE        = -716;

  DISPID_AMBIENT_PALETTE           = -726;
  DISPID_AMBIENT_TRANSFERPRIORITY  = -728;

  DISPID_Name                      = -800;
  DISPID_Delete                    = -801;
  DISPID_Object                    = -802;
  DISPID_Parent                    = -803;


{ Dispatch ID constants for fonts }

  DISPID_FONT_NAME    = 0;
  DISPID_FONT_SIZE    = 2;
  DISPID_FONT_BOLD    = 3;
  DISPID_FONT_ITALIC  = 4;
  DISPID_FONT_UNDER   = 5;
  DISPID_FONT_STRIKE  = 6;
  DISPID_FONT_WEIGHT  = 7;
  DISPID_FONT_CHARSET = 8;

{ Dispatch ID constants for pictures }

  DISPID_PICT_HANDLE = 0;
  DISPID_PICT_HPAL   = 2;
  DISPID_PICT_TYPE   = 3;
  DISPID_PICT_WIDTH  = 4;
  DISPID_PICT_HEIGHT = 5;
  DISPID_PICT_RENDER = 6;

  // Reserved global Property IDs
  PID_DICTIONARY	 = 0;
  PID_CODEPAGE	         = $1;
  PID_FIRST_USABLE	 = $2;
  PID_FIRST_NAME_DEFAULT = $fff;
  PID_LOCALE	         = $80000000;
  PID_MODIFY_TIME	 = $80000001;
  PID_SECURITY	         = $80000002;
  PID_ILLEGAL            = $ffffffff;

  // Property IDs for the SummaryInformation Property Set
  PIDSI_TITLE               = $00000002;  // VT_LPSTR
  PIDSI_SUBJECT             = $00000003;  // VT_LPSTR
  PIDSI_AUTHOR              = $00000004;  // VT_LPSTR
  PIDSI_KEYWORDS            = $00000005;  // VT_LPSTR
  PIDSI_COMMENTS            = $00000006;  // VT_LPSTR
  PIDSI_TEMPLATE            = $00000007;  // VT_LPSTR
  PIDSI_LASTAUTHOR          = $00000008;  // VT_LPSTR
  PIDSI_REVNUMBER           = $00000009;  // VT_LPSTR
  PIDSI_EDITTIME            = $0000000a;  // VT_FILETIME (UTC)
  PIDSI_LASTPRINTED         = $0000000b;  // VT_FILETIME (UTC)
  PIDSI_CREATE_DTM          = $0000000c;  // VT_FILETIME (UTC)
  PIDSI_LASTSAVE_DTM        = $0000000d;  // VT_FILETIME (UTC)
  PIDSI_PAGECOUNT           = $0000000e;  // VT_I4
  PIDSI_WORDCOUNT           = $0000000f;  // VT_I4
  PIDSI_CHARCOUNT           = $00000010;  // VT_I4
  PIDSI_THUMBNAIL           = $00000011;  // VT_CF
  PIDSI_APPNAME             = $00000012;  // VT_LPSTR
  PIDSI_DOC_SECURITY        = $00000013;  // VT_I4

  PRSPEC_INVALID            = $ffffffff;
  PRSPEC_LPWSTR             = 0;
  PRSPEC_PROPID             = 1;

{ from WTYPES.H }
{ Result code }

type
  PHResult = ^HResult;
  PSCODE = ^Integer;
  SCODE = Integer;

{ VT_INT and VT_UINT }
  PSYSINT = ^SYSINT;
  SYSINT = Integer;
  PSYSUINT = ^SYSUINT;
  SYSUINT = LongWord;

  PResultList = ^TResultList;
  TResultList = array[0..65535] of HRESULT;

{ Unknown lists }

  PUnknownList = ^TUnknownList;
  TUnknownList = array[0..65535] of IUnknown;

{ OLE character and string types }

  TOleChar = WideChar;
  POleStr = PWideChar;
  PPOleStr = ^POleStr;

  POleStrList = ^TOleStrList;
  TOleStrList = array[0..65535] of POleStr;

{ 64-bit large integer }

  Largeint = Int64;

{ 64-bit large unsigned integer }

  PLargeuint = ^Largeuint;
  Largeuint = Int64;

{ Interface ID }

  PIID = PGUID;
  TIID = TGUID;

{ Class ID }

  PCLSID = PGUID;
  TCLSID = TGUID;

{ Object ID }

  PObjectID = ^TObjectID;
  _OBJECTID = record
    Lineage: TGUID;
    Uniquifier: Longint;
  end;
  TObjectID = _OBJECTID;
  OBJECTID = TObjectID;

{ Locale ID }

  TLCID = DWORD;

{ Format ID }

  FMTID = TGUID;
  PFmtID = ^TFmtID;
  TFmtID = TGUID;

{ OLE control types }

  PTextMetricOle = PTextMetricW;
  TTextMetricOle = TTextMetricW;

  OLE_COLOR = DWORD;
  TOleColor = OLE_COLOR;

  PCoServerInfo = ^TCoServerInfo;
  _COSERVERINFO = record
    dwReserved1: Longint;
    pwszName: LPWSTR;
    pAuthInfo: Pointer;
    dwReserved2: Longint;
  end;
  TCoServerInfo = _COSERVERINFO;
  COSERVERINFO = TCoServerInfo;

  PMultiQI = ^TMultiQI;
  tagMULTI_QI = record
    IID: PIID;
    Itf: IUnknown;
    hr: HRESULT;
  end;
  TMultiQI = tagMULTI_QI;
  MULTI_QI = TMultiQI;


  PMultiQIArray = ^TMultiQIArray;
  TMultiQIArray = array[0..65535] of TMultiQI;

{ from OAIDL.H }
  PSafeArrayBound = ^TSafeArrayBound;
  tagSAFEARRAYBOUND = record
    cElements: Longint;
    lLbound: Longint;
  end;
  TSafeArrayBound = tagSAFEARRAYBOUND;
  SAFEARRAYBOUND = TSafeArrayBound;

  PSafeArray = ^TSafeArray;
  tagSAFEARRAY = record
    cDims: Word;
    fFeatures: Word;
    cbElements: Longint;
    cLocks: Longint;
    pvData: Pointer;
    rgsabound: array[0..0] of TSafeArrayBound;
  end;
  TSafeArray = tagSAFEARRAY;
  SAFEARRAY = TSafeArray;


  TOleDate = Double;
  POleDate = ^TOleDate;

  TOleBool = WordBool;
  POleBool = ^TOleBool;

  TVarType = Word;

  TOleEnum = type Integer;

{ from OLECTL.H }
  OLE_XPOS_PIXELS  = Longint;
  OLE_YPOS_PIXELS  = Longint;
  OLE_XSIZE_PIXELS = Longint;
  OLE_YSIZE_PIXELS = Longint;

  OLE_XPOS_HIMETRIC  = Longint;
  OLE_YPOS_HIMETRIC  = Longint;
  OLE_XSIZE_HIMETRIC = Longint;
  OLE_YSIZE_HIMETRIC = Longint;

  OLE_XPOS_CONTAINER  = Single;
  OLE_YPOS_CONTAINER  = Single;
  OLE_XSIZE_CONTAINER = Single;
  OLE_YSIZE_CONTAINER = Single;

  OLE_TRISTATE = SmallInt;

const
  triUnchecked = 0;
  triChecked   = 1;
  triGray      = 2;

type
  OLE_OPTEXCLUSIVE = WordBool;

  OLE_CANCELBOOL = WordBool;

  OLE_ENABLEDEFAULTBOOL = WordBool;

  OLE_HANDLE = LongWord;

  FONTNAME = WideString;

  FONTSIZE = Currency;

  FONTBOLD = WordBool;

  FONTITALIC = WordBool;

  FONTUNDERSCORE = WordBool;

  FONTSTRIKETHROUGH = WordBool;


{ Registration function types }

  TDLLRegisterServer = function: HResult stdcall;
  TDLLUnregisterServer = function: HResult stdcall;

{ from OCIDL.H }
{ TPointF structure }

  PPointF = ^TPointF;
  tagPOINTF = record
    x: Single;
    y: Single;
  end;
  TPointF = tagPOINTF;
  POINTF = TPointF;


{ TControlInfo structure }

  PControlInfo = ^TControlInfo;
  tagCONTROLINFO = record
    cb: Longint;
    hAccel: HAccel;
    cAccel: Word;
    dwFlags: Longint;
  end;
  TControlInfo = tagCONTROLINFO;
  CONTROLINFO = TControlInfo;


{ from OBJIDL.H }
{ Forward declarations }

  IStream = interface;
  IRunningObjectTable = interface;
  IEnumString = interface;
  IMoniker = interface;
  IAdviseSink = interface;
  ITypeInfo = interface;
  ITypeInfo2 = interface;
  ITypeComp = interface;
  ITypeLib = interface;
  ITypeLib2 = interface;
  IEnumOLEVERB = interface;
  IOleInPlaceActiveObject = interface;
  IOleControl = interface;
  IOleControlSite = interface;
  ISimpleFrameSite = interface;
  IPersistStreamInit = interface;
  IPersistPropertyBag = interface;
  IPropertyNotifySink = interface;
  IProvideClassInfo = interface;
  IConnectionPointContainer = interface;
  IEnumConnectionPoints = interface;
  IConnectionPoint = interface;
  IEnumConnections = interface;
  IClassFactory2 = interface;
  ISpecifyPropertyPages = interface;
  IPerPropertyBrowsing = interface;
  IPropertyPageSite = interface;
  IPropertyPage = interface;
  IPropertyPage2 = interface;
  IPropertySetStorage = interface;
  IPropertyStorage = interface;
  IEnumSTATPROPSTG = interface;
  IEnumSTATPROPSETSTG = interface;


{ IClassFactory interface }

  IClassFactory = interface(IUnknown)
    ['{00000001-0000-0000-C000-000000000046}']
    function CreateInstance(const unkOuter: IUnknown; const iid: TIID;
      out obj): HResult; stdcall;
    function LockServer(fLock: BOOL): HResult; stdcall;
  end;


{ IMarshal interface }

  IMarshal = interface(IUnknown)
    ['{00000003-0000-0000-C000-000000000046}']
    function GetUnmarshalClass(const iid: TIID; pv: Pointer;
      dwDestContext: Longint; pvDestContext: Pointer; mshlflags: Longint;
      out cid: TCLSID): HResult; stdcall;
    function GetMarshalSizeMax(const iid: TIID; pv: Pointer;
      dwDestContext: Longint; pvDestContext: Pointer; mshlflags: Longint;
      out size: Longint): HResult; stdcall;
    function MarshalInterface(const stm: IStream; const iid: TIID; pv: Pointer;
      dwDestContext: Longint; pvDestContext: Pointer;
      mshlflags: Longint): HResult; stdcall;
    function UnmarshalInterface(const stm: IStream; const iid: TIID;
      out pv): HResult; stdcall;
    function ReleaseMarshalData(const stm: IStream): HResult;
      stdcall;
    function DisconnectObject(dwReserved: Longint): HResult;
      stdcall;
  end;

{ IMalloc interface }

  IMalloc = interface(IUnknown)
    ['{00000002-0000-0000-C000-000000000046}']
    function Alloc(cb: Longint): Pointer; stdcall;
    function Realloc(pv: Pointer; cb: Longint): Pointer; stdcall;
    procedure Free(pv: Pointer); stdcall;
    function GetSize(pv: Pointer): Longint; stdcall;
    function DidAlloc(pv: Pointer): Integer; stdcall;
    procedure HeapMinimize; stdcall;
  end;

{ IMallocSpy interface }

  IMallocSpy = interface(IUnknown)
    ['{0000001D-0000-0000-C000-000000000046}']
    function PreAlloc(cbRequest: Longint): Longint; stdcall;
    function PostAlloc(pActual: Pointer): Pointer; stdcall;
    function PreFree(pRequest: Pointer; fSpyed: BOOL): Pointer; stdcall;
    procedure PostFree(fSpyed: BOOL); stdcall;
    function PreRealloc(pRequest: Pointer; cbRequest: Longint;
      out ppNewRequest: Pointer; fSpyed: BOOL): Longint; stdcall;
    function PostRealloc(pActual: Pointer; fSpyed: BOOL): Pointer; stdcall;
    function PreGetSize(pRequest: Pointer; fSpyed: BOOL): Pointer; stdcall;
    function PostGetSize(pActual: Pointer; fSpyed: BOOL): Longint; stdcall;
    function PreDidAlloc(pRequest: Pointer; fSpyed: BOOL): Pointer; stdcall;
    function PostDidAlloc(pRequest: Pointer; fSpyed: BOOL; fActual: Integer): Integer; stdcall;
    procedure PreHeapMinimize; stdcall;
    procedure PostHeapMinimize; stdcall;
  end;

{ IStdMarshalInfo interface }

  IStdMarshalInfo = interface(IUnknown)
    ['{00000018-0000-0000-C000-000000000046}']
    function GetClassForHandler(dwDestContext: Longint; pvDestContext: Pointer;
      out clsid: TCLSID): HResult; stdcall;
  end;

{ IExternalConnection interface }

  IExternalConnection = interface(IUnknown)
    ['{00000019-0000-0000-C000-000000000046}']
    function AddConnection(extconn: Longint; reserved: Longint): Longint;
      stdcall;
    function ReleaseConnection(extconn: Longint; reserved: Longint;
      fLastReleaseCloses: BOOL): Longint; stdcall;
  end;

{ IWeakRef interface }

  IWeakRef = interface(IUnknown)
    ['{A35E20C2-837D-11D0-9E9F-00A02457621F}']
    function ChangeWeakCount(delta: Longint): Longint; stdcall;
    function ReleaseKeepAlive(const unkReleased: IUnknown;
      reserved: Longint): Longint; stdcall;
  end;

{ IEnumUnknown interface }

  IEnumUnknown = interface(IUnknown)
    ['{00000100-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumUnknown): HResult; stdcall;
  end;

{ IBindCtx interface }

  PBindOpts = ^TBindOpts;
  tagBIND_OPTS = record
    cbStruct: Longint;
    grfFlags: Longint;
    grfMode: Longint;
    dwTickCountDeadline: Longint;
  end;
  TBindOpts = tagBIND_OPTS;
  BIND_OPTS = TBindOpts;

  IBindCtx = interface(IUnknown)
    ['{0000000E-0000-0000-C000-000000000046}']
    function RegisterObjectBound(const unk: IUnknown): HResult; stdcall;
    function RevokeObjectBound(const unk: IUnknown): HResult; stdcall;
    function ReleaseBoundObjects: HResult; stdcall;
    function SetBindOptions(const bindopts: TBindOpts): HResult; stdcall;
    function GetBindOptions(var bindopts: TBindOpts): HResult; stdcall;
    function GetRunningObjectTable(out rot: IRunningObjectTable): HResult;
      stdcall;
    function RegisterObjectParam(pszKey: POleStr; const unk: IUnknown): HResult;
      stdcall;
    function GetObjectParam(pszKey: POleStr; out unk: IUnknown): HResult;
      stdcall;
    function EnumObjectParam(out Enum: IEnumString): HResult; stdcall;
    function RevokeObjectParam(pszKey: POleStr): HResult; stdcall;
  end;

{ IEnumMoniker interface }

  IEnumMoniker = interface(IUnknown)
    ['{00000102-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumMoniker): HResult; stdcall;
  end;

{ IRunnableObject interface }

  IRunnableObject = interface(IUnknown)
    ['{00000126-0000-0000-C000-000000000046}']
    function GetRunningClass(out clsid: TCLSID): HResult; stdcall;
    function Run(const bc: IBindCtx): HResult; stdcall;
    function IsRunning: BOOL; stdcall;
    function LockRunning(fLock: BOOL; fLastUnlockCloses: BOOL): HResult;
      stdcall;
    function SetContainedObject(fContained: BOOL): HResult; stdcall;
  end;

{ IRunningObjectTable interface }

  IRunningObjectTable = interface(IUnknown)
    ['{00000010-0000-0000-C000-000000000046}']
    function Register(grfFlags: Longint; const unkObject: IUnknown;
      const mkObjectName: IMoniker; out dwRegister: Longint): HResult; stdcall;
    function Revoke(dwRegister: Longint): HResult; stdcall;
    function IsRunning(const mkObjectName: IMoniker): HResult; stdcall;
    function GetObject(const mkObjectName: IMoniker;
      out unkObject: IUnknown): HResult; stdcall;
    function NoteChangeTime(dwRegister: Longint;
      const filetime: TFileTime): HResult; stdcall;
    function GetTimeOfLastChange(const mkObjectName: IMoniker;
      out filetime: TFileTime): HResult; stdcall;
    function EnumRunning(out enumMoniker: IEnumMoniker): HResult; stdcall;
  end;

{ IPersist interface }

  IPersist = interface(IUnknown)
    ['{0000010C-0000-0000-C000-000000000046}']
    function GetClassID(out classID: TCLSID): HResult; stdcall;
  end;

{ IPersistStream interface }

  IPersistStream = interface(IPersist)
    ['{00000109-0000-0000-C000-000000000046}']
    function IsDirty: HResult; stdcall;
    function Load(const stm: IStream): HResult; stdcall;
    function Save(const stm: IStream; fClearDirty: BOOL): HResult; stdcall;
    function GetSizeMax(out cbSize: Largeint): HResult; stdcall;
  end;

{ IMoniker interface }

  PIMoniker = ^IMoniker;
  IMoniker = interface(IPersistStream)
    ['{0000000F-0000-0000-C000-000000000046}']
    function BindToObject(const bc: IBindCtx; const mkToLeft: IMoniker;
      const iidResult: TIID; out vResult): HResult; stdcall;
    function BindToStorage(const bc: IBindCtx; const mkToLeft: IMoniker;
      const iid: TIID; out vObj): HResult; stdcall;
    function Reduce(const bc: IBindCtx; dwReduceHowFar: Longint;
      mkToLeft: PIMoniker; out mkReduced: IMoniker): HResult; stdcall;
    function ComposeWith(const mkRight: IMoniker; fOnlyIfNotGeneric: BOOL;
      out mkComposite: IMoniker): HResult; stdcall;
    function Enum(fForward: BOOL; out enumMoniker: IEnumMoniker): HResult;
      stdcall;
    function IsEqual(const mkOtherMoniker: IMoniker): HResult; stdcall;
    function Hash(out dwHash: Longint): HResult; stdcall;
    function IsRunning(const bc: IBindCtx; const mkToLeft: IMoniker;
      const mkNewlyRunning: IMoniker): HResult; stdcall;
    function GetTimeOfLastChange(const bc: IBindCtx; const mkToLeft: IMoniker;
      out filetime: TFileTime): HResult; stdcall;
    function Inverse(out mk: IMoniker): HResult; stdcall;
    function CommonPrefixWith(const mkOther: IMoniker;
      out mkPrefix: IMoniker): HResult; stdcall;
    function RelativePathTo(const mkOther: IMoniker;
      out mkRelPath: IMoniker): HResult; stdcall;
    function GetDisplayName(const bc: IBindCtx; const mkToLeft: IMoniker;
      out pszDisplayName: POleStr): HResult; stdcall;
    function ParseDisplayName(const bc: IBindCtx; const mkToLeft: IMoniker;
      pszDisplayName: POleStr; out chEaten: Longint;
      out mkOut: IMoniker): HResult; stdcall;
    function IsSystemMoniker(out dwMksys: Longint): HResult; stdcall;
  end;

{ IEnumString interface }

  IEnumString = interface(IUnknown)
    ['{00000101-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumString): HResult; stdcall;
  end;


{ IStream interface }

  PStatStg = ^TStatStg;
  tagSTATSTG = record
    pwcsName: POleStr;
    dwType: Longint;
    cbSize: Largeint;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    grfMode: Longint;
    grfLocksSupported: Longint;
    clsid: TCLSID;
    grfStateBits: Longint;
    reserved: Longint;
  end;
  TStatStg = tagSTATSTG;
  STATSTG = TStatStg;

//  ISequentialStream = interface(IUnknown)
//    ['{0c733a30-2a1c-11ce-ade5-00aa0044773d}']
//    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; stdcall;
//    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; stdcall;
//  end;

  ISequentialStream = interface(IUnknown)
    ['{0c733a30-2a1c-11ce-ade5-00aa0044773d}']
    function Read(pv: Pointer; cb: FixedUInt; pcbRead: PFixedUInt): HResult; stdcall;
    function Write(pv: Pointer; cb: FixedUInt; pcbWritten: PFixedUInt): HResult; stdcall;
  end;


//  IStream = interface(ISequentialStream)
//    ['{0000000C-0000-0000-C000-000000000046}']
//    function Seek(dlibMove: Largeint; dwOrigin: Longint; out libNewPosition: Largeint): HResult; stdcall;
//    function SetSize(libNewSize: Largeint): HResult; stdcall;
//    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult; stdcall;
//    function Commit(grfCommitFlags: Longint): HResult; stdcall;
//    function Revert: HResult; stdcall;
//    function LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
//    function UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
//    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; stdcall;
//    function Clone(out stm: IStream): HResult; stdcall;
//  end;

  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeint; dwOrigin: DWORD; out libNewPosition: LargeUInt): HResult; stdcall;
    function SetSize(libNewSize: LargeUInt): HResult; stdcall;
    function CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HResult; stdcall;
    function Commit(grfCommitFlags: DWORD): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult; stdcall;
    function UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult; stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;


{ IEnumStatStg interface }

  IEnumStatStg = interface(IUnknown)
    ['{0000000D-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumStatStg): HResult; stdcall;
  end;

{ IStorage interface }

  TSNB = ^POleStr;

  IStorage = interface(IUnknown)
    ['{0000000B-0000-0000-C000-000000000046}']
    function CreateStream(pwcsName: POleStr; grfMode: Longint; reserved1: Longint;
      reserved2: Longint; out stm: IStream): HResult; stdcall;
    function OpenStream(pwcsName: POleStr; reserved1: Pointer; grfMode: Longint;
      reserved2: Longint; out stm: IStream): HResult; stdcall;
    function CreateStorage(pwcsName: POleStr; grfMode: Longint;
      dwStgFmt: Longint; reserved2: Longint; out stg: IStorage): HResult;
      stdcall;
    function OpenStorage(pwcsName: POleStr; const stgPriority: IStorage;
      grfMode: Longint; snbExclude: TSNB; reserved: Longint;
      out stg: IStorage): HResult; stdcall;
    function CopyTo(ciidExclude: Longint; rgiidExclude: PIID;
      snbExclude: TSNB; const stgDest: IStorage): HResult; stdcall;
    function MoveElementTo(pwcsName: POleStr; const stgDest: IStorage;
      pwcsNewName: POleStr; grfFlags: Longint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function EnumElements(reserved1: Longint; reserved2: Pointer; reserved3: Longint;
      out enm: IEnumStatStg): HResult; stdcall;
    function DestroyElement(pwcsName: POleStr): HResult; stdcall;
    function RenameElement(pwcsOldName: POleStr;
      pwcsNewName: POleStr): HResult; stdcall;
    function SetElementTimes(pwcsName: POleStr; const ctime: TFileTime;
      const atime: TFileTime; const mtime: TFileTime): HResult;
      stdcall;
    function SetClass(const clsid: TCLSID): HResult; stdcall;
    function SetStateBits(grfStateBits: Longint; grfMask: Longint): HResult;
      stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
  end;

{ IPersistFile interface }

  IPersistFile = interface(IPersist)
    ['{0000010B-0000-0000-C000-000000000046}']
    function IsDirty: HResult; stdcall;
    function Load(pszFileName: POleStr; dwMode: Longint): HResult;
      stdcall;
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult;
      stdcall;
    function SaveCompleted(pszFileName: POleStr): HResult;
      stdcall;
    function GetCurFile(out pszFileName: POleStr): HResult;
      stdcall;
  end;

{ IPersistStorage interface }

  IPersistStorage = interface(IPersist)
    ['{0000010A-0000-0000-C000-000000000046}']
    function IsDirty: HResult; stdcall;
    function InitNew(const stg: IStorage): HResult; stdcall;
    function Load(const stg: IStorage): HResult; stdcall;
    function Save(const stgSave: IStorage; fSameAsLoad: BOOL): HResult;
      stdcall;
    function SaveCompleted(const stgNew: IStorage): HResult; stdcall;
    function HandsOffStorage: HResult; stdcall;
  end;

{ ILockBytes interface }

  ILockBytes = interface(IUnknown)
    ['{0000000A-0000-0000-C000-000000000046}']
    function ReadAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
      pcbRead: PLongint): HResult; stdcall;
    function WriteAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
      pcbWritten: PLongint): HResult; stdcall;
    function Flush: HResult; stdcall;
    function SetSize(cb: Largeint): HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
  end;

{ IEnumFormatEtc interface }

  PDVTargetDevice = ^TDVTargetDevice;
  tagDVTARGETDEVICE = record
    tdSize: Longint;
    tdDriverNameOffset: Word;
    tdDeviceNameOffset: Word;
    tdPortNameOffset: Word;
    tdExtDevmodeOffset: Word;
    tdData: record end;
  end;
  TDVTargetDevice = tagDVTARGETDEVICE;
  DVTARGETDEVICE = TDVTargetDevice;


  PClipFormat = ^TClipFormat;
  TClipFormat = Word;

  PFormatEtc = ^TFormatEtc;
  tagFORMATETC = record
    cfFormat: TClipFormat;
    ptd: PDVTargetDevice;
    dwAspect: Longint;
    lindex: Longint;
    tymed: Longint;
  end;
  TFormatEtc = tagFORMATETC;
  FORMATETC = TFormatEtc;


  IEnumFORMATETC = interface(IUnknown)
    ['{00000103-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumFormatEtc): HResult; stdcall;
  end;

{ IEnumStatData interface }

  PStatData = ^TStatData;
  tagSTATDATA = record
    formatetc: TFormatEtc;
    advf: Longint;
    advSink: IAdviseSink;
    dwConnection: Longint;
  end;
  TStatData = tagSTATDATA;
  STATDATA = TStatData;


  IEnumSTATDATA = interface(IUnknown)
    ['{00000105-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumStatData): HResult; stdcall;
  end;

{ IRootStorage interface }

  IRootStorage = interface(IUnknown)
    ['{00000012-0000-0000-C000-000000000046}']
    function SwitchToFile(pszFile: POleStr): HResult; stdcall;
  end;

{ IAdviseSink interface }

  PRemStgMedium = ^TRemStgMedium;
  tagRemSTGMEDIUM = record
    tymed: Longint;
    dwHandleType: Longint;
    pData: Longint;
    pUnkForRelease: Longint;
    cbData: Longint;
    data: record end;
  end;
  TRemStgMedium = tagRemSTGMEDIUM;
  RemSTGMEDIUM = TRemStgMedium;


  PStgMedium = ^TStgMedium;
  tagSTGMEDIUM = record
    tymed: Longint;
    case Integer of
      0: (hBitmap: HBitmap; unkForRelease: Pointer{IUnknown});
      1: (hMetaFilePict: THandle);
      2: (hEnhMetaFile: THandle);
      3: (hGlobal: HGlobal);
      4: (lpszFileName: POleStr);
      5: (stm: Pointer{IStream});
      6: (stg: Pointer{IStorage});
  end;
  TStgMedium = tagSTGMEDIUM;
  STGMEDIUM = TStgMedium;


  IAdviseSink = interface(IUnknown)
    ['{0000010F-0000-0000-C000-000000000046}']
    procedure OnDataChange(const formatetc: TFormatEtc; const stgmed: TStgMedium);
      stdcall;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint);
      stdcall;
    procedure OnRename(const mk: IMoniker); stdcall;
    procedure OnSave; stdcall;
    procedure OnClose; stdcall;
  end;

{ IAdviseSink2 interface }

  IAdviseSink2 = interface(IAdviseSink)
    ['{00000125-0000-0000-C000-000000000046}']
    procedure OnLinkSrcChange(const mk: IMoniker); stdcall;
  end;

{ IDataObject interface }

  IDataObject = interface(IUnknown)
    ['{0000010E-0000-0000-C000-000000000046}']
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium):
      HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium):
      HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult;
      stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
      stdcall;
  end;

{ IDataAdviseHolder interface }

  IDataAdviseHolder = interface(IUnknown)
    ['{00000110-0000-0000-C000-000000000046}']
    function Advise(const dataObject: IDataObject; const fetc: TFormatEtc;
      advf: Longint; const advise: IAdviseSink; out pdwConnection: Longint): HResult;
      stdcall;
    function Unadvise(dwConnection: Longint): HResult; stdcall;
    function EnumAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
    function SendOnDataChange(const dataObject: IDataObject; dwReserved: Longint;
      advf: Longint): HResult; stdcall;
  end;

{ IMessageFilter interface }

  PInterfaceInfo = ^TInterfaceInfo;
  tagINTERFACEINFO = record
    unk: IUnknown;
    iid: TIID;
    wMethod: Word;
  end;
  TInterfaceInfo = tagINTERFACEINFO;
  INTERFACEINFO = TInterfaceInfo;


  IMessageFilter = interface(IUnknown)
    ['{00000016-0000-0000-C000-000000000046}']
    function HandleInComingCall(dwCallType: Longint; htaskCaller: HTask;
      dwTickCount: Longint; lpInterfaceInfo: PInterfaceInfo): Longint;
      stdcall;
    function RetryRejectedCall(htaskCallee: HTask; dwTickCount: Longint;
      dwRejectType: Longint): Longint; stdcall;
    function MessagePending(htaskCallee: HTask; dwTickCount: Longint;
      dwPendingType: Longint): Longint; stdcall;
  end;

{ IRpcChannelBuffer interface }

  TRpcOleDataRep = DWORD;

  PRpcOleMessage = ^TRpcOleMessage;
  tagRPCOLEMESSAGE = record
    reserved1: Pointer;
    dataRepresentation: TRpcOleDataRep;
    Buffer: Pointer;
    cbBuffer: Longint;
    iMethod: Longint;
    reserved2: array[0..4] of Pointer;
    rpcFlags: Longint;
  end;
  TRpcOleMessage = tagRPCOLEMESSAGE;
  RPCOLEMESSAGE = TRpcOleMessage;


  IRpcChannelBuffer = interface(IUnknown)
    ['{D5F56B60-593B-101A-B569-08002B2DBF7A}']
    function GetBuffer(var message: TRpcOleMessage; iid: TIID): HResult;
      stdcall;
    function SendReceive(var message: TRpcOleMessage;
      var status: Longint): HResult; stdcall;
    function FreeBuffer(var message: TRpcOleMessage): HResult;
      stdcall;
    function GetDestCtx(out dwDestContext: Longint;
      out pvDestContext): HResult; stdcall;
    function IsConnected: HResult; stdcall;
  end;

{ IRpcProxyBuffer interface }

  IRpcProxyBuffer = interface(IUnknown)
    ['{D5F56A34-593B-101A-B569-08002B2DBF7A}']
    function Connect(const rpcChannelBuffer: IRpcChannelBuffer): HResult;
      stdcall;
    procedure Disconnect; stdcall;
  end;

{ IRpcStubBuffer interface }

  IRpcStubBuffer = interface(IUnknown)
    ['{D5F56AFC-593B-101A-B569-08002B2DBF7A}']
    function Connect(const unkServer: IUnknown): HResult; stdcall;
    procedure Disconnect; stdcall;
    function Invoke(var rpcmsg: TRpcOleMessage; rpcChannelBuffer:
      IRpcChannelBuffer): HResult; stdcall;
    function IsIIDSupported(const iid: TIID): Pointer{IRpcStubBuffer};
      stdcall;
    function CountRefs: Longint; stdcall;
    function DebugServerQueryInterface(var pv): HResult;
      stdcall;
    procedure DebugServerRelease(pv: Pointer); stdcall;
  end;

{ IPSFactoryBuffer interface }

  IPSFactoryBuffer = interface(IUnknown)
    ['{D5F569D0-593B-101A-B569-08002B2DBF7A}']
    function CreateProxy(const unkOuter: IUnknown; const iid: TIID;
      out proxy: IRpcProxyBuffer; out pv): HResult; stdcall;
    function CreateStub(const iid: TIID; const unkServer: IUnknown;
      out stub: IRpcStubBuffer): HResult; stdcall;
  end;

  IChannelHook = interface(IUnknown)
    ['{1008C4A0-7613-11CF-9AF1-0020AF6E72F4}']
    procedure ClientGetSize(const uExtent: TGUID; const iid: TIID;
      out DataSize: Longint); stdcall;
    procedure ClientFillBuffer(const uExtent: TGUID; const iid: TIID;
      var DataSize: Longint; var DataBuffer); stdcall;
    procedure ClientNotify(const uExtent: TGUID; const iid: TIID;
      DataSize: Longint; var DataBuffer; lDataRep: Longint;
      hrFault: HResult); stdcall;
    procedure ServerNotify(const uExtent: TGUID; const iid: TIID;
      DataSize: Longint; var DataBuffer; lDataRep: Longint); stdcall;
    procedure ServerGetSize(const uExtent: TGUID; const iid: TIID;
      hrFault: HResult; out DataSize: Longint); stdcall;
    procedure ServerFillBuffer(const uExtent: TGUID; const iid: TIID;
      var DataSize: Longint; var DataBuffer; hrFault: HResult); stdcall;
  end;

  IFillLockBytes = interface(IUnknown)
    ['{99CAF010-415E-11CF-8814-00AA00B569F5}']
    function FillAppend(const pv; cb: Longint;
      out cbWritten: Longint): HResult; stdcall;
    function FillAt(Offset: Longint; const pv; cb: Longint;
      out cbWritten: Longint): HResult; stdcall;
    function SetFillSize(Offset: Longint): HResult; stdcall;
    function Terminate(bCanceled: Boolean): HResult; stdcall;
  end;

{ Automation types }

  PBStr = ^TBStr;
  TBStr = POleStr;

  PBStrList = ^TBStrList;
  TBStrList = array[0..65535] of TBStr;

  PComp = ^Comp;

{ from WTYPES.H }
  PDecimal = ^TDecimal;
  tagDEC = packed record
    wReserved: Word;
    case Integer of
      0: (scale, sign: Byte; Hi32: Longint;
      case Integer of
        0: (Lo32, Mid32: Longint);
        1: (Lo64: LONGLONG));
      1: (signscale: Word);
  end;
  TDecimal = tagDEC;
  DECIMAL = TDecimal;

  PBlob = ^TBlob;
  tagBLOB = record
    cbSize: Longint;
    pBlobData: Pointer;
  end;
  TBlob = tagBLOB;
  BLOB = TBlob;

  PClipData = ^TClipData;
  tagCLIPDATA = record
    cbSize: Longint;
    ulClipFmt: Longint;
    pClipData: Pointer;
  end;
  TClipData = tagCLIPDATA;
  CLIPDATA = TClipData;

{ IPropertyStorage / IPropertySetStorage }

  PPropVariant = ^TPropVariant;

  tagCAUB = packed record
    cElems: ULONG;
    pElems: PByte;
  end;
  CAUB = tagCAUB;
  PCAUB = ^TCAUB;
  TCAUB = tagCAUB;
                         
  tagCAI = packed record
    cElems: ULONG;
    pElems: PShortInt;
  end;
  CAI = tagCAI;
  PCAI = ^TCAI;
  TCAI = tagCAI;

  tagCAUI = packed record
    cElems: ULONG;
    pElems: PWord;
  end;
  CAUI = tagCAUI;
  PCAUI = ^TCAUI;
  TCAUI = tagCAUI;

  tagCAL = packed record
    cElems: ULONG;
    pElems: PLongint;
  end;
  CAL = tagCAL;
  PCAL = ^TCAL;
  TCAL = tagCAL;

  tagCAUL = packed record
    cElems: ULONG;
    pElems: PULONG;
  end;
  CAUL = tagCAUL;
  PCAUL = ^TCAUL;
  TCAUL = tagCAUL;

  tagCAFLT = packed record
    cElems: ULONG;
    pElems: PSingle;
  end;
  CAFLT = tagCAFLT;
  PCAFLT = ^TCAFLT;
  TCAFLT = tagCAFLT;

  tagCADBL = packed record
    cElems: ULONG;
    pElems: PDouble;
  end;
  CADBL = tagCADBL;
  PCADBL = ^TCADBL;
  TCADBL = tagCADBL;

  tagCACY = packed record
    cElems: ULONG;
    pElems: PCurrency;
  end;
  CACY = tagCACY;
  PCACY = ^TCACY;
  TCACY = tagCACY;

  tagCADATE = packed record
    cElems: ULONG;
    pElems: POleDate;
  end;
  CADATE = tagCADATE;
  PCADATE = ^TCADATE;
  TCADATE = tagCADATE;

  tagCABSTR = packed record
    cElems: ULONG;
    pElems: PBSTR;
  end;
  CABSTR = tagCABSTR;
  PCABSTR = ^TCABSTR;
  TCABSTR = tagCABSTR;

  tagCABOOL = packed record
    cElems: ULONG;
    pElems: POleBool;
  end;
  CABOOL = tagCABOOL;
  PCABOOL = ^TCABOOL;
  TCABOOL = tagCABOOL;

  tagCASCODE = packed record
    cElems: ULONG;
    pElems: PSCODE;
  end;
  CASCODE = tagCASCODE;
  PCASCODE = ^TCASCODE;
  TCASCODE = tagCASCODE;

  tagCAPROPVARIANT = packed record
    cElems: ULONG;
    pElems: PPropVariant;
  end;
  CAPROPVARIANT = tagCAPROPVARIANT;
  PCAPROPVARIANT = ^TCAPROPVARIANT;
  TCAPROPVARIANT = tagCAPROPVARIANT;

  tagCAH = packed record
    cElems: ULONG;
    pElems: PLargeInteger;
  end;
  CAH = tagCAH;
  PCAH = ^TCAH;
  TCAH = tagCAH;

  tagCAUH = packed record
    cElems: ULONG;
    pElems: PULargeInteger;
  end;
  CAUH = tagCAUH;
  PCAUH = ^TCAUH;
  TCAUH = tagCAUH;

  tagCALPSTR = packed record
    cElems: ULONG;
    pElems: PLPSTR;
  end;
  CALPSTR = tagCALPSTR;
  PCALPSTR = ^TCALPSTR;
  TCALPSTR = tagCALPSTR;

  tagCALPWSTR = packed record
    cElems: ULONG;
    pElems: PLPWSTR;
  end;
  CALPWSTR = tagCALPWSTR;
  PCALPWSTR = ^TCALPWSTR;
  TCALPWSTR = tagCALPWSTR;

  tagCAFILETIME = packed record
    cElems: ULONG;
    pElems: PFileTime;
  end;
  CAFILETIME = tagCAFILETIME;
  PCAFILETIME = ^TCAFILETIME;
  TCAFILETIME = tagCAFILETIME;

  tagCACLIPDATA = packed record
    cElems: ULONG;
    pElems: PClipData;
  end;
  CACLIPDATA = tagCACLIPDATA;
  PCACLIPDATA = ^TCACLIPDATA;
  TCACLIPDATA = tagCACLIPDATA;

  tagCACLSID = packed record
    cElems: ULONG;
    pElems: PCLSID;
  end;
  CACLSID = tagCACLSID;
  PCACLSID = ^TCACLSID;
  TCACLSID = tagCACLSID;

  tagPROPVARIANT = packed record
    vt: TVarType;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    case Integer of
      0: (bVal: Byte);
      1: (iVal: SmallInt);
      2: (uiVal: Word);
      3: (boolVal: TOleBool);
      4: (bool: TOleBool);
      5: (lVal: Longint);
      6: (ulVal: Cardinal);
      7: (fltVal: Single);
      8: (scode: SCODE);
      9: (hVal: LARGE_INTEGER);
      10: (uhVal: ULARGE_INTEGER);
      11: (dblVal: Double);
      12: (cyVal: Currency);
      13: (date: TOleDate);
      14: (filetime: TFileTime);
      15: (puuid: PGUID);
      16: (blob: TBlob);
      17: (pclipdata: PClipData);
      18: (pStream: Pointer{IStream});
      19: (pStorage: Pointer{IStorage});
      20: (bstrVal: TBStr);
      21: (pszVal: PAnsiChar);
      22: (pwszVal: PWideChar);
      23: (caub: TCAUB);
      24: (cai: TCAI);
      25: (caui: TCAUI);
      26: (cabool: TCABOOL);
      27: (cal: TCAL);
      28: (caul: TCAUL);
      29: (caflt: TCAFLT);
      30: (cascode: TCASCODE);
      31: (cah: TCAH);
      32: (cauh: TCAUH);
      33: (cadbl: TCADBL);
      34: (cacy: TCACY);
      35: (cadate: TCADATE);
      36: (cafiletime: TCAFILETIME);
      37: (cauuid: TCACLSID);
      38: (caclipdata: TCACLIPDATA);
      39: (cabstr: TCABSTR);
      40: (calpstr: TCALPSTR);
      41: (calpwstr: TCALPWSTR );
      42: (capropvar: TCAPROPVARIANT);
  end;
  PROPVARIANT = tagPROPVARIANT;
  TPropVariant = tagPROPVARIANT;

  tagPROPSPEC = packed record
    ulKind: ULONG;
    case Integer of
      0: (propid: TPropID);
      1: (lpwstr: POleStr);
  end;
  PROPSPEC = tagPROPSPEC;
  PPropSpec = ^TPropSpec;
  TPropSpec = tagPROPSPEC;

  tagSTATPROPSTG = record
    lpwstrName: POleStr;
    propid: TPropID;
    vt: TVarType;
  end;
  STATPROPSTG = tagSTATPROPSTG;
  PStatPropStg = ^TStatPropStg;
  TStatPropStg = tagSTATPROPSTG;


  tagSTATPROPSETSTG = packed record
    fmtid: TFmtID;
    clsid: TClsID;
    grfFlags: DWORD;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    dwOSVersion: DWORD;
  end;
  STATPROPSETSTG = tagSTATPROPSETSTG;
  PStatPropSetStg = ^TStatPropSetStg;
  TStatPropSetStg = tagSTATPROPSETSTG;

  IPropertyStorage = interface(IUnknown)
    ['{00000138-0000-0000-C000-000000000046}']
    function ReadMultiple(cpspec: ULONG; rgpspec : PPropSpec; rgpropvar: PPropVariant): HResult; stdcall;
    function WriteMultiple(cpspec: ULONG; rgpspec : PPropSpec; rgpropvar: PPropVariant;
      propidNameFirst: TPropID): HResult; stdcall;
    function DeleteMultiple(cpspec: ULONG; rgpspec: PPropSpec): HResult; stdcall;
    function ReadPropertyNames(cpropid: ULONG; rgpropid: PPropID;
      rglpwstrName: PPOleStr): HResult; stdcall;
    function WritePropertyNames(cpropid: ULONG; rgpropid: PPropID;
      rglpwstrName: PPOleStr): HResult; stdcall;
    function DeletePropertyNames(cpropid: ULONG; rgpropid: PPropID): HResult; stdcall;
    function Commit(grfCommitFlags: DWORD): HResult; stdcall;
    function Revert: HResult; stdcall;
    function Enum(out ppenum: IEnumSTATPROPSTG): HResult; stdcall;
    function SetTimes(const pctime, patime, pmtime: TFileTime): HResult; stdcall;
    function SetClass(const clsid: TCLSID): HResult; stdcall;
    function Stat(pstatpsstg: PStatPropSetStg): HResult; stdcall;
  end;

  IPropertySetStorage = interface(IUnknown)
    ['{0000013A-0000-0000-C000-000000000046}']
    function Create(const rfmtid: TFmtID; const pclsid: TCLSID; grfFlags,
      grfMode: DWORD; out ppprstg: IPropertyStorage): HResult; stdcall;
    function Open(const rfmtid: TFmtID; grfMode: DWORD;
      out ppprstg: IPropertyStorage): HResult; stdcall;
    function Delete(const rfmtid: TFmtID): HResult; stdcall;
    function Enum(out ppenum: IEnumSTATPROPSETSTG): HResult; stdcall;
  end;

  IEnumSTATPROPSTG = interface(IUnknown)
    ['{00000139-0000-0000-C000-000000000046}']
    function Next(celt: ULONG; out rgelt; pceltFetched: PULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumSTATPROPSTG): HResult; stdcall;
  end;

  IEnumSTATPROPSETSTG = interface(IUnknown)
    ['{0000013B-0000-0000-C000-000000000046}']
    function Next(celt: ULONG; out rgelt; pceltFetched: PULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumSTATPROPSETSTG): HResult; stdcall;
  end;

{ from OAIDL.H }

  PVariantArg = ^TVariantArg;
  tagVARIANT = record
    vt: TVarType;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    case Integer of
      VT_UI1:                  (bVal: Byte);
      VT_I2:                   (iVal: Smallint);
      VT_I4:                   (lVal: Longint);
      VT_R4:                   (fltVal: Single);
      VT_R8:                   (dblVal: Double);
      VT_BOOL:                 (vbool: TOleBool);
      VT_ERROR:                (scode: HResult);
      VT_CY:                   (cyVal: Currency);
      VT_DATE:                 (date: TOleDate);
      VT_BSTR:                 (bstrVal: PWideChar{WideString});
      VT_UNKNOWN:              (unkVal: Pointer{IUnknown});
      VT_DISPATCH:             (dispVal: Pointer{IDispatch});
      VT_ARRAY:                (parray: PSafeArray);
      VT_BYREF or VT_UI1:      (pbVal: ^Byte);
      VT_BYREF or VT_I2:       (piVal: ^Smallint);
      VT_BYREF or VT_I4:       (plVal: ^Longint);
      VT_BYREF or VT_R4:       (pfltVal: ^Single);
      VT_BYREF or VT_R8:       (pdblVal: ^Double);
      VT_BYREF or VT_BOOL:     (pbool: ^TOleBool);
      VT_BYREF or VT_ERROR:    (pscode: ^HResult);
      VT_BYREF or VT_CY:       (pcyVal: ^Currency);
      VT_BYREF or VT_DATE:     (pdate: ^TOleDate);
      VT_BYREF or VT_BSTR:     (pbstrVal: ^WideString);
      VT_BYREF or VT_UNKNOWN:  (punkVal: ^IUnknown);
      VT_BYREF or VT_DISPATCH: (pdispVal: ^IDispatch);
      VT_BYREF or VT_ARRAY:    (pparray: ^PSafeArray);
      VT_BYREF or VT_VARIANT:  (pvarVal: PVariant);
      VT_BYREF:                (byRef: Pointer);
      VT_I1:                   (cVal: AnsiChar);
      VT_UI2:                  (uiVal: Word);
      VT_UI4:                  (ulVal: LongWord);
      VT_INT:                  (intVal: Integer);
      VT_UINT:                 (uintVal: LongWord);
      VT_BYREF or VT_DECIMAL:  (pdecVal: PDecimal);
      VT_BYREF or VT_I1:       (pcVal: PAnsiChar);
      VT_BYREF or VT_UI2:      (puiVal: PWord);
      VT_BYREF or VT_UI4:      (pulVal: PInteger);
      VT_BYREF or VT_INT:      (pintVal: PInteger);
      VT_BYREF or VT_UINT:     (puintVal: PLongWord);
  end;
  TVariantArg = tagVARIANT;


  PVariantArgList = ^TVariantArgList;
  TVariantArgList = array[0..65535] of TVariantArg;

  TDispID = Longint;

  PDispIDList = ^TDispIDList;
  TDispIDList = array[0..65535] of TDispID;

  TMemberID = TDispID;

  PMemberIDList = ^TMemberIDList;
  TMemberIDList = array[0..65535] of TMemberID;

  HRefType = DWORD;

  tagTYPEKIND = DWORD;
  TTypeKind = tagTYPEKIND;

  PArrayDesc = ^TArrayDesc;

  PTypeDesc = ^TTypeDesc;
  tagTYPEDESC = record
    case Integer of
      VT_PTR:         (ptdesc: PTypeDesc; vt: TVarType);
      VT_CARRAY:      (padesc: PArrayDesc);
      VT_USERDEFINED: (hreftype: HRefType);
  end;
  TTypeDesc = tagTYPEDESC;
  TYPEDESC = TTypeDesc;


  tagARRAYDESC = record
    tdescElem: TTypeDesc;
    cDims: Word;
    rgbounds: array[0..0] of TSafeArrayBound;
  end;
  TArrayDesc = tagARRAYDESC;
  ARRAYDESC = TArrayDesc;


  PIDLDesc = ^TIDLDesc;
  tagIDLDESC = record
    dwReserved: Longint;
    wIDLFlags: Word;
  end;
  TIDLDesc = tagIDLDESC;
  IDLDESC = TIDLDesc;


  PParamDescEx = ^TParamDescEx;
  tagPARAMDESCEX = record
    cBytes: Longint;
    FourBytePad: Longint;
    varDefaultValue: TVariantArg;
  end;
  TParamDescEx = tagPARAMDESCEX;
  PARAMDESCEX = TParamDescEx;


  PParamDesc = ^TParamDesc;
  tagPARAMDESC = record
    pparamdescex: PParamDescEx;
    wParamFlags: Word;
  end;
  TParamDesc = tagPARAMDESC;
  PARAMDESC = TParamDesc;


  PElemDesc = ^TElemDesc;
  tagELEMDESC = record
    tdesc: TTypeDesc;
    case Integer of
      0: (idldesc: TIDLDesc);
      1: (paramdesc: TParamDesc);
  end;
  TElemDesc = tagELEMDESC;
  ELEMDESC = TElemDesc;


  PElemDescList = ^TElemDescList;
  TElemDescList = array[0..65535] of TElemDesc;


  PTypeAttr = ^TTypeAttr;
  tagTYPEATTR = record
    guid: TGUID;
    lcid: TLCID;
    dwReserved: Longint;
    memidConstructor: TMemberID;
    memidDestructor: TMemberID;
    lpstrSchema: POleStr;
    cbSizeInstance: Longint;
    typekind: TTypeKind;
    cFuncs: Word;
    cVars: Word;
    cImplTypes: Word;
    cbSizeVft: Word;
    cbAlignment: Word;
    wTypeFlags: Word;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    tdescAlias: TTypeDesc;
    idldescType: TIDLDesc;
  end;
  TTypeAttr = tagTYPEATTR;
  TYPEATTR = TTypeAttr;


  PDispParams = ^TDispParams;
  tagDISPPARAMS = record
    rgvarg: PVariantArgList;
    rgdispidNamedArgs: PDispIDList;
    cArgs: Longint;
    cNamedArgs: Longint;
  end;
  TDispParams = tagDISPPARAMS;
  DISPPARAMS = TDispParams;


  PExcepInfo = ^TExcepInfo;

  TFNDeferredFillIn = function(ExInfo: PExcepInfo): HResult stdcall;


  tagEXCEPINFO = record
    wCode: Word;
    wReserved: Word;
    bstrSource: WideString;
    bstrDescription: WideString;
    bstrHelpFile: WideString;
    dwHelpContext: Longint;
    pvReserved: Pointer;
    pfnDeferredFillIn: TFNDeferredFillIn;
    scode: HResult;
  end;
  TExcepInfo = tagEXCEPINFO;
  EXCEPINFO = TExcepInfo;

  tagFUNCKIND = Longint;
  TFuncKind = tagFUNCKIND;

  tagINVOKEKIND = Longint;
  TInvokeKind = tagINVOKEKIND;

  tagCALLCONV = Longint;
  TCallConv = tagCALLCONV;


  PFuncDesc = ^TFuncDesc;
  tagFUNCDESC = record
    memid: TMemberID;
    lprgscode: PResultList;
    lprgelemdescParam: PElemDescList;
    funckind: TFuncKind;
    invkind: TInvokeKind;
    callconv: TCallConv;
    cParams: Smallint;
    cParamsOpt: Smallint;
    oVft: Smallint;
    cScodes: Smallint;
    elemdescFunc: TElemDesc;
    wFuncFlags: Word;
  end;
  TFuncDesc = tagFUNCDESC;
  FUNCDESC = TFuncDesc;


  TVarKind = Longint;


  PVarDesc = ^TVarDesc;
  tagVARDESC = record
    memid: TMemberID;
    lpstrSchema: POleStr;
    case Integer of
      VAR_PERINSTANCE: (
        oInst: Longint;
        elemdescVar: TElemDesc;
        wVarFlags: Word;
        varkind: TVarKind);
      VAR_CONST: (
        lpvarValue: POleVariant);
  end;
  TVarDesc = tagVARDESC;
  VARDESC = TVarDesc;


{ ICreateTypeInfo interface }

  ICreateTypeInfo = interface(IUnknown)
    ['{00020405-0000-0000-C000-000000000046}']
    function SetGuid(const guid: TGUID): HResult; stdcall;
    function SetTypeFlags(uTypeFlags: Integer): HResult; stdcall;
    function SetDocString(pstrDoc: POleStr): HResult; stdcall;
    function SetHelpContext(dwHelpContext: Longint): HResult; stdcall;
    function SetVersion(wMajorVerNum: Word; wMinorVerNum: Word): HResult;
      stdcall;
    function AddRefTypeInfo(const tinfo: ITypeInfo; out reftype: HRefType): HResult;
      stdcall;
    function AddFuncDesc(index: Integer; const funcdesc: TFuncDesc): HResult;
      stdcall;
    function AddImplType(index: Integer; reftype: HRefType): HResult;
      stdcall;
    function SetImplTypeFlags(index: Integer; impltypeflags: Integer): HResult;
      stdcall;
    function SetAlignment(cbAlignment: Word): HResult; stdcall;
    function SetSchema(lpstrSchema: POleStr): HResult; stdcall;
    function AddVarDesc(index: Integer; const vardesc: TVarDesc): HResult;
      stdcall;
    function SetFuncAndParamNames(index: Integer; rgszNames: POleStrList;
      cNames: Integer): HResult; stdcall;
    function SetVarName(index: Integer; szName: POleStr): HResult; stdcall;
    function SetTypeDescAlias(const descAlias: TTypeDesc): HResult; stdcall;
    function DefineFuncAsDllEntry(index: Integer; szDllName: POleStr;
      szProcName: POleStr): HResult; stdcall;
    function SetFuncDocString(index: Integer; szDocString: POleStr): HResult;
      stdcall;
    function SetVarDocString(index: Integer; szDocString: POleStr): HResult;
      stdcall;
    function SetFuncHelpContext(index: Integer; dwHelpContext: Longint): HResult;
      stdcall;
    function SetVarHelpContext(index: Integer; dwHelpContext: Longint): HResult;
      stdcall;
    function SetMops(index: Integer; const bstrMops: WideString): HResult; stdcall;
    function SetTypeIdldesc(const idldesc: TIDLDesc): HResult; stdcall;
    function LayOut: HResult; stdcall;
  end;

{ ICreateTypeInfo2 interface }

  ICreateTypeInfo2 = interface(ICreateTypeInfo)
    ['{00020412-0000-0000-C000-000000000046}']
    function DeleteFuncDesc(index: Integer): HResult; stdcall;
    function DeleteFuncDescByMemId(memid: TMemberID; invKind: TInvokeKind): HResult; stdcall;
    function DeleteVarDesc(index: Integer): HResult; stdcall;
    function DeleteVarDescByMemId(memid: TMemberID): HResult; stdcall;
    function DeleteImplType(index: Integer): HResult; stdcall;
    function SetCustData(const guid: TGUID; pVarVal: POleVariant): HResult; stdcall;
    function SetFuncCustData(index: Integer; const guid: TGUID;
      pVarVal: POleVariant): HResult; stdcall;
    function SetParamCustData(indexFunc: Integer; indexParam: Integer;
      const guid: TGUID; pVarVal: POleVariant): HResult; stdcall;
    function SetVarCustData(index: Integer; const guid: TGUID;
      pVarVal: POleVariant): HResult; stdcall;
    function SetImplTypeCustData(index: Integer; const guid: TGUID;
      pVarVal: POleVariant): HResult; stdcall;
    function SetHelpStringContext(dwHelpStringContext: Longint): HResult; stdcall;
    function SetFuncHelpStringContext(index: Integer;
      dwHelpStringContext: Longint): HResult; stdcall;
    function SetVarHelpStringContext(index: Integer;
       dwHelpStringContext: Longint): HResult; stdcall;
    function Invalidate: HResult; stdcall;
    function SetName(szName: POleStr): HResult; stdcall;
  end;

{ ICreateTypeLib interface }

  ICreateTypeLib = interface(IUnknown)
    ['{00020406-0000-0000-C000-000000000046}']
    function CreateTypeInfo(szName: POleStr; tkind: TTypeKind;
      out ictinfo: ICreateTypeInfo): HResult; stdcall;
    function SetName(szName: POleStr): HResult; stdcall;
    function SetVersion(wMajorVerNum: Word; wMinorVerNum: Word): HResult; stdcall;
    function SetGuid(const guid: TGUID): HResult; stdcall;
    function SetDocString(szDoc: POleStr): HResult; stdcall;
    function SetHelpFileName(szHelpFileName: POleStr): HResult; stdcall;
    function SetHelpContext(dwHelpContext: Longint): HResult; stdcall;
    function SetLcid(lcid: TLCID): HResult; stdcall;
    function SetLibFlags(uLibFlags: Integer): HResult; stdcall;
    function SaveAllChanges: HResult; stdcall;
  end;

  ICreateTypeLib2 = interface(ICreateTypeLib)
    ['{0002040F-0000-0000-C000-000000000046}']
    function DeleteTypeInfo(szName: PWideChar): HResult; stdcall;
    function SetCustData(const guid: TGUID; pVarVal: POleVariant): HResult; stdcall;
    function SetHelpStringContext(dwHelpStringContext: Longint): HResult; stdcall;
    function SetHelpStringDll(szFileName: PWideChar): HResult; stdcall;
  end;

{ IEnumVariant interface }

  IEnumVariant = interface(IUnknown)
    ['{00020404-0000-0000-C000-000000000046}']
    function Next(celt: LongWord; var rgvar : _OleVariant;
      out pceltFetched: LongWord): HResult; stdcall;
    function Skip(celt: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumVariant): HResult; stdcall;
  end;

  IEnumVariant_D4 = interface(IUnknown)
    ['{00020404-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumVariant): HResult; stdcall;
  end;

  { IEnumVariant_D4 is the IEnumVariant interface as used by Delphi 4, and
    has been deprecated due to changes in the type library. IEnumVariant
    has been updated to reflect those changes. }

{ ITypeComp interface }

  TDescKind = Longint;

  PBindPtr = ^TBindPtr;
  tagBINDPTR = record
    case Integer of
      0: (lpfuncdesc: PFuncDesc);
      1: (lpvardesc: PVarDesc);
      2: (lptcomp: Pointer {ITypeComp});
  end;
  TBindPtr = tagBINDPTR;
  BINDPTR = TBindPtr;


  ITypeComp = interface(IUnknown)
    ['{00020403-0000-0000-C000-000000000046}']
    function Bind(szName: POleStr; lHashVal: Longint; wflags: Word;
      out tinfo: ITypeInfo; out desckind: TDescKind;
      out bindptr: TBindPtr): HResult; stdcall;
    function BindType(szName: POleStr; lHashVal: Longint;
      out tinfo: ITypeInfo; out tcomp: ITypeComp): HResult;
      stdcall;
  end;

{ ITypeInfo interface }

  ITypeInfo = interface(IUnknown)
    ['{00020401-0000-0000-C000-000000000046}']
    function GetTypeAttr(out ptypeattr: PTypeAttr): HResult; stdcall;
    function GetTypeComp(out tcomp: ITypeComp): HResult; stdcall;
    function GetFuncDesc(index: Integer; out pfuncdesc: PFuncDesc): HResult;
      stdcall;
    function GetVarDesc(index: Integer; out pvardesc: PVarDesc): HResult;
      stdcall;
    function GetNames(memid: TMemberID; rgbstrNames: PBStrList;
      cMaxNames: Integer; out cNames: Integer): HResult; stdcall;
    function GetRefTypeOfImplType(index: Integer; out reftype: HRefType): HResult;
      stdcall;
    function GetImplTypeFlags(index: Integer; out impltypeflags: Integer): HResult;
      stdcall;
    function GetIDsOfNames(rgpszNames: POleStrList; cNames: Integer;
      rgmemid: PMemberIDList): HResult; stdcall;
    function Invoke(pvInstance: Pointer; memid: TMemberID; flags: Word;
      var dispParams: TDispParams; varResult: PVariant;
      excepInfo: PExcepInfo; argErr: PInteger): HResult; stdcall;
    function GetDocumentation(memid: TMemberID; pbstrName: PWideString;
      pbstrDocString: PWideString; pdwHelpContext: PLongint;
      pbstrHelpFile: PWideString): HResult; stdcall;
    function GetDllEntry(memid: TMemberID; invkind: TInvokeKind;
      bstrDllName, bstrName: PWideString; wOrdinal: PWord): HResult;
      stdcall;
    function GetRefTypeInfo(reftype: HRefType; out tinfo: ITypeInfo): HResult;
      stdcall;
    function AddressOfMember(memid: TMemberID; invkind: TInvokeKind;
      out ppv: Pointer): HResult; stdcall;
    function CreateInstance(const unkOuter: IUnknown; const iid: TIID;
      out vObj): HResult; stdcall;
    function GetMops(memid: TMemberID; out bstrMops: WideString): HResult;
      stdcall;
    function GetContainingTypeLib(out tlib: ITypeLib; out pindex: Integer): HResult;
      stdcall;
    procedure ReleaseTypeAttr(ptypeattr: PTypeAttr); stdcall;
    procedure ReleaseFuncDesc(pfuncdesc: PFuncDesc); stdcall;
    procedure ReleaseVarDesc(pvardesc: PVarDesc); stdcall;
  end;

{ ITypeLib interface }

  TSysKind = Longint;

  PTLibAttr = ^TTLibAttr;
  tagTLIBATTR = record
    guid: TGUID;
    lcid: TLCID;
    syskind: TSysKind;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    wLibFlags: Word;
  end;
  TTLibAttr = tagTLIBATTR;
  TLIBATTR = TTLibAttr;


  PTypeInfoList = ^TTypeInfoList;
  TTypeInfoList = array[0..65535] of ITypeInfo;

  ITypeLib = interface(IUnknown)
    ['{00020402-0000-0000-C000-000000000046}']
    function GetTypeInfoCount: Integer; stdcall;
    function GetTypeInfo(index: Integer; out tinfo: ITypeInfo): HResult; stdcall;
    function GetTypeInfoType(index: Integer; out tkind: TTypeKind): HResult;
      stdcall;
    function GetTypeInfoOfGuid(const guid: TGUID; out tinfo: ITypeInfo): HResult;
      stdcall;
    function GetLibAttr(out ptlibattr: PTLibAttr): HResult; stdcall;
    function GetTypeComp(out tcomp: ITypeComp): HResult; stdcall;
    function GetDocumentation(index: Integer; pbstrName: PWideString;
      pbstrDocString: PWideString; pdwHelpContext: PLongint;
      pbstrHelpFile: PWideString): HResult; stdcall;
    function IsName(szNameBuf: POleStr; lHashVal: Longint; out fName: BOOL): HResult;
      stdcall;
    function FindName(szNameBuf: POleStr; lHashVal: Longint;
      rgptinfo: PTypeInfoList; rgmemid: PMemberIDList;
      out pcFound: Word): HResult; stdcall;
    procedure ReleaseTLibAttr(ptlibattr: PTLibAttr); stdcall;
  end;

{ ITypeLib2 interface }
  PCustDataItem = ^TCustDataItem;
  tagCUSTDATAITEM = record
    guid: TGUID;
    varValue: TVariantArg;
   end;
  TCustDataItem = tagCUSTDATAITEM;
  CUSTDATAITEM = TCustDataItem;

  PCustDataItemList = ^TCustDataItemList;
  TCustDataItemList = array[0..65535] of TCustDataItem;

  PCustData = ^TCustData;
  tagCUSTDATA = record
    cCustData: DWORD;
    prgCustData: PCustDataItemList;
  end;
  TCustData = tagCUSTDATA;
  CUSTDATA = TCustData;


  ITypeLib2 = interface(ITypeLib)
    ['{00020411-0000-0000-C000-000000000046}']
    function GetCustData(guid: TGUID;
      out pVarVal: _OleVariant): HResult; stdcall;
    function GetLibStatistics(pcUniqueNames: PLongInt;
      out pcchUniqueNames: LongInt): HResult; stdcall;
    function GetDocumentation2(index: Integer; lcid: TLCID;
      pbstrHelpString: PWideString; pdwHelpStringContext: PDWORD;
      pbstrHelpStringDll: PWideString): HResult; stdcall;
    function GetAllCustData(out pCustData: TCustData): HResult; stdcall;
  end;

  ITypeInfo2 = interface(ITypeInfo)
    ['{00020412-0000-0000-C000-000000000046}']
    function GetTypeKind(out pTypeKind: TTypeKind): HResult; stdcall;
    function GetTypeFlags(out pTypeFlags: LongInt): HResult; stdcall;
    function GetFuncIndexOfMemId(memid: TMemberID; invKind: TInvokeKind;
      out pFuncIndex: UINT): HResult; stdcall;
    function GetVarIndexOfMemId(memid: TMemberID; out pVarIndex: UINT): HResult; stdcall;
    function GetCustData(guid: TGUID; out pVarVal: _OleVariant): HResult; stdcall;
    function GetFuncCustData(index: UINT; guid: TGUID;
      out pVarVal: _OleVariant): HResult; stdcall;
    function GetParamCustData(indexFunc, indexParam: UINT; guid: TGUID;
      out pVarVal: _OleVariant): HResult; stdcall;
    function GetVarCustData(index: UINT; guid: TGUID;
      out pVarVal: _OleVariant): HResult; stdcall;
    function GetImplTypeCustData(index: UINT; guid: TGUID;
      out pVarVal: _OleVariant): HResult; stdcall;
    function GetDocumentation2(memid: TMemberID; lcid: TLCID;
      pbstrHelpString: PWideString; pdwHelpStringContext: PDWORD;
      pbstrHelpStringDll: PWideString): HResult; stdcall;
    function GetAllCustData(out pCustData: TCustData): HResult; stdcall;
    function GetAllFuncCustData(index: UINT; out pCustData: TCustData): HResult; stdcall;
    function GetAllParamCustData(indexFunc, indexParam: UINT;
      out pCustData: TCustData): HResult; stdcall;
    function GetAllVarCustData(index: UINT; out pCustData: TCustData): HResult; stdcall;
    function GetAllImplTypeCustData(index: UINT; out pCustData: TCustData): HResult; stdcall;
  end;

{ IErrorInfo interface }

  IErrorInfo = interface(IUnknown)
    ['{1CF2B120-547D-101B-8E65-08002B2BD119}']
    function GetGUID(out guid: TGUID): HResult; stdcall;
    function GetSource(out bstrSource: WideString): HResult; stdcall;
    function GetDescription(out bstrDescription: WideString): HResult; stdcall;
    function GetHelpFile(out bstrHelpFile: WideString): HResult; stdcall;
    function GetHelpContext(out dwHelpContext: Longint): HResult; stdcall;
  end;

{ ICreateErrorInfo interface }

  ICreateErrorInfo = interface(IUnknown)
    ['{22F03340-547D-101B-8E65-08002B2BD119}']
    function SetGUID(const guid: TGUID): HResult; stdcall;
    function SetSource(szSource: POleStr): HResult; stdcall;
    function SetDescription(szDescription: POleStr): HResult; stdcall;
    function SetHelpFile(szHelpFile: POleStr): HResult; stdcall;
    function SetHelpContext(dwHelpContext: Longint): HResult; stdcall;
  end;

{ ISupportErrorInfo interface }

  ISupportErrorInfo = interface(IUnknown)
    ['{DF0B3D60-548F-101B-8E65-08002B2BD119}']
    function InterfaceSupportsErrorInfo(const iid: TIID): HResult; stdcall;
  end;

{ from OLEAUTO.H }
{ IDispatch implementation support }

  PParamData = ^TParamData;
  tagPARAMDATA = record
    szName: POleStr;
    vt: TVarType;
  end;
  TParamData = tagPARAMDATA;
  PARAMDATA = TParamData;


  PParamDataList = ^TParamDataList;
  TParamDataList = array[0..65535] of TParamData;

  PMethodData = ^TMethodData;
  tagMETHODDATA = record
    szName: POleStr;
    ppdata: PParamDataList;
    dispid: TDispID;
    iMeth: Integer;
    cc: TCallConv;
    cArgs: Integer;
    wFlags: Word;
    vtReturn: TVarType;
  end;
  TMethodData = tagMETHODDATA;
  METHODDATA = TMethodData;


  PMethodDataList = ^TMethodDataList;
  TMethodDataList = array[0..65535] of TMethodData;

  PInterfaceData = ^TInterfaceData;
  tagINTERFACEDATA = record
    pmethdata: PMethodDataList;
    cMembers: Integer;
  end;
  TInterfaceData = tagINTERFACEDATA;
  INTERFACEDATA = TInterfaceData;

  tagREGKIND = (REGKIND_DEFAULT, REGKIND_REGISTER, REGKIND_NONE);
  TRegKind = tagREGKIND;

{ from OLEIDL.H }
{ IOleAdviseHolder interface }

  IOleAdviseHolder = interface(IUnknown)
    ['{00000111-0000-0000-C000-000000000046}']
    function Advise(const advise: IAdviseSink; out dwConnection: Longint): HResult;
      stdcall;
    function Unadvise(dwConnection: Longint): HResult; stdcall;
    function EnumAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
    function SendOnRename(const mk: IMoniker): HResult; stdcall;
    function SendOnSave: HResult; stdcall;
    function SendOnClose: HResult; stdcall;
  end;

{ IOleCache interface }

  IOleCache = interface(IUnknown)
    ['{0000011E-0000-0000-C000-000000000046}']
    function Cache(const formatetc: TFormatEtc; advf: Longint;
      out dwConnection: Longint): HResult; stdcall;
    function Uncache(dwConnection: Longint): HResult; stdcall;
    function EnumCache(out enumStatData: IEnumStatData): HResult;
      stdcall;
    function InitCache(const dataObject: IDataObject): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; const medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
  end;

{ IOleCache2 interface }

  IOleCache2 = interface(IOleCache)
    ['{00000128-0000-0000-C000-000000000046}']
    function UpdateCache(const dataObject: IDataObject; grfUpdf: Longint;
      pReserved: Pointer): HResult; stdcall;
    function DiscardCache(dwDiscardOptions: Longint): HResult; stdcall;
  end;

{ IOleCacheControl interface }

  IOleCacheControl = interface(IUnknown)
    ['{00000129-0000-0000-C000-000000000046}']
    function OnRun(const dataObject: IDataObject): HResult; stdcall;
    function OnStop: HResult; stdcall;
  end;

{ IParseDisplayName interface }

  IParseDisplayName = interface(IUnknown)
    ['{0000011A-0000-0000-C000-000000000046}']
    function ParseDisplayName(const bc: IBindCtx; pszDisplayName: POleStr;
      out chEaten: Longint; out mkOut: IMoniker): HResult; stdcall;
  end;

{ IOleContainer interface }

  IOleContainer = interface(IParseDisplayName)
    ['{0000011B-0000-0000-C000-000000000046}']
    function EnumObjects(grfFlags: Longint; out Enum: IEnumUnknown): HResult;
      stdcall;
    function LockContainer(fLock: BOOL): HResult; stdcall;
  end;

{ IOleClientSite interface }

  IOleClientSite = interface(IUnknown)
    ['{00000118-0000-0000-C000-000000000046}']
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
  end;

{ IOleObject interface }

  IOleObject = interface(IUnknown)
    ['{00000112-0000-0000-C000-000000000046}']
    function SetClientSite(const clientSite: IOleClientSite): HResult;
      stdcall;
    function GetClientSite(out clientSite: IOleClientSite): HResult;
      stdcall;
    function SetHostNames(szContainerApp: POleStr;
      szContainerObj: POleStr): HResult; stdcall;
    function Close(dwSaveOption: Longint): HResult; stdcall;
    function SetMoniker(dwWhichMoniker: Longint; const mk: IMoniker): HResult;
      stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function InitFromData(const dataObject: IDataObject; fCreation: BOOL;
      dwReserved: Longint): HResult; stdcall;
    function GetClipboardData(dwReserved: Longint;
      out dataObject: IDataObject): HResult; stdcall;
    function DoVerb(iVerb: Longint; msg: PMsg; const activeSite: IOleClientSite;
      lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult;
      stdcall;
    function EnumVerbs(out enumOleVerb: IEnumOleVerb): HResult; stdcall;
    function Update: HResult; stdcall;
    function IsUpToDate: HResult; stdcall;
    function GetUserClassID(out clsid: TCLSID): HResult; stdcall;
    function GetUserType(dwFormOfType: Longint; out pszUserType: POleStr): HResult;
      stdcall;
    function SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult;
      stdcall;
    function GetExtent(dwDrawAspect: Longint; out size: TPoint): HResult;
      stdcall;
    function Advise(const advSink: IAdviseSink; out dwConnection: Longint): HResult;
      stdcall;
    function Unadvise(dwConnection: Longint): HResult; stdcall;
    function EnumAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
    function GetMiscStatus(dwAspect: Longint; out dwStatus: Longint): HResult;
      stdcall;
    function SetColorScheme(const logpal: TLogPalette): HResult; stdcall;
  end;

{ OLE types }

  PObjectDescriptor = ^TObjectDescriptor;
  tagOBJECTDESCRIPTOR = record
    cbSize: Longint;
    clsid: TCLSID;
    dwDrawAspect: Longint;
    size: TPoint;
    point: TPoint;
    dwStatus: Longint;
    dwFullUserTypeName: Longint;
    dwSrcOfCopy: Longint;
  end;
  TObjectDescriptor = tagOBJECTDESCRIPTOR;
  OBJECTDESCRIPTOR = TObjectDescriptor;


  PLinkSrcDescriptor = PObjectDescriptor;
  TLinkSrcDescriptor = TObjectDescriptor;

{ IOleWindow interface }

  IOleWindow = interface(IUnknown)
    ['{00000114-0000-0000-C000-000000000046}']
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
  end;

{ IOleLink interface }

  IOleLink = interface(IUnknown)
    ['{0000011D-0000-0000-C000-000000000046}']
    function SetUpdateOptions(dwUpdateOpt: Longint): HResult;
      stdcall;
    function GetUpdateOptions(out dwUpdateOpt: Longint): HResult; stdcall;
    function SetSourceMoniker(const mk: IMoniker; const clsid: TCLSID): HResult;
      stdcall;
    function GetSourceMoniker(out mk: IMoniker): HResult; stdcall;
    function SetSourceDisplayName(pszDisplayName: POleStr): HResult;
      stdcall;
    function GetSourceDisplayName(out pszDisplayName: POleStr): HResult;
      stdcall;
    function BindToSource(bindflags: Longint; const bc: IBindCtx): HResult;
      stdcall;
    function BindIfRunning: HResult; stdcall;
    function GetBoundSource(out unk: IUnknown): HResult; stdcall;
    function UnbindSource: HResult; stdcall;
    function Update(const bc: IBindCtx): HResult; stdcall;
  end;

{ IOleItemContainer interface }

  IOleItemContainer = interface(IOleContainer)
    ['{0000011C-0000-0000-C000-000000000046}']
    function GetObject(pszItem: POleStr; dwSpeedNeeded: Longint;
      const bc: IBindCtx; const iid: TIID; out vObject): HResult; stdcall;
    function GetObjectStorage(pszItem: POleStr; const bc: IBindCtx;
      const iid: TIID; out vStorage): HResult; stdcall;
    function IsRunning(pszItem: POleStr): HResult; stdcall;
  end;

{ IOleInPlaceUIWindow interface }

  IOleInPlaceUIWindow = interface(IOleWindow)
    ['{00000115-0000-0000-C000-000000000046}']
    function GetBorder(out rectBorder: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(pborderwidths: PRect): HResult; stdcall;
    function SetActiveObject(const activeObject: IOleInPlaceActiveObject;
      pszObjName: POleStr): HResult; stdcall;
  end;

{ IOleInPlaceActiveObject interface }

  IOleInPlaceActiveObject = interface(IOleWindow)
    ['{00000117-0000-0000-C000-000000000046}']
    function TranslateAccelerator(var msg: TMsg): HResult; stdcall;
    function OnFrameWindowActivate(fActivate: BOOL): HResult; stdcall;
    function OnDocWindowActivate(fActivate: BOOL): HResult; stdcall;
    function ResizeBorder(const rcBorder: TRect; const uiWindow: IOleInPlaceUIWindow;
      fFrameWindow: BOOL): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
  end;

{ IOleInPlaceFrame interface }

  POleInPlaceFrameInfo = ^TOleInPlaceFrameInfo;
  tagOIFI = record
    cb: Integer;
    fMDIApp: BOOL;
    hwndFrame: HWND;
    haccel: HAccel;
    cAccelEntries: Integer;
  end;
  TOleInPlaceFrameInfo = tagOIFI;
  OLEINPLACEFRAMEINFO = TOleInPlaceFrameInfo;

  POleMenuGroupWidths = ^TOleMenuGroupWidths;
  tagOleMenuGroupWidths = record
    width: array[0..5] of Longint;
  end;
  TOleMenuGroupWidths = tagOleMenuGroupWidths;
  OLEMENUGROUPWIDTHS = TOleMenuGroupWidths;


  IOleInPlaceFrame = interface(IOleInPlaceUIWindow)
    ['{00000116-0000-0000-C000-000000000046}']
    function InsertMenus(hmenuShared: HMenu;
      var menuWidths: TOleMenuGroupWidths): HResult; stdcall;
    function SetMenu(hmenuShared: HMenu; holemenu: HMenu;
      hwndActiveObject: HWnd): HResult; stdcall;
    function RemoveMenus(hmenuShared: HMenu): HResult; stdcall;
    function SetStatusText(pszStatusText: POleStr): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    function TranslateAccelerator(var msg: TMsg; wID: Word): HResult; stdcall;
  end;

{ IOleInPlaceObject interface }

  IOleInPlaceObject = interface(IOleWindow)
    ['{00000113-0000-0000-C000-000000000046}']
    function InPlaceDeactivate: HResult; stdcall;
    function UIDeactivate: HResult; stdcall;
    function SetObjectRects(const rcPosRect: TRect;
      const rcClipRect: TRect): HResult; stdcall;
    function ReactivateAndUndo: HResult; stdcall;
  end;

{ IOleInPlaceSite interface }

  IOleInPlaceSite = interface(IOleWindow)
    ['{00000119-0000-0000-C000-000000000046}']
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out frame: IOleInPlaceFrame;
      out doc: IOleInPlaceUIWindow; out rcPosRect: TRect;
      out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult;
      stdcall;
    function Scroll(scrollExtent: TPoint): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(const rcPosRect: TRect): HResult; stdcall;
  end;

{ IViewObject interface }

  TContinueFunc = function(dwContinue: Longint): BOOL stdcall;

  IViewObject = interface(IUnknown)
    ['{0000010D-0000-0000-C000-000000000046}']
    function Draw(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      ptd: PDVTargetDevice; hicTargetDev: HDC; hdcDraw: HDC;
      prcBounds: PRect; prcWBounds: PRect; fnContinue: TContinueFunc;
      dwContinue: Longint): HResult; stdcall;
    function GetColorSet(dwDrawAspect: Longint; lindex: Longint;
      pvAspect: Pointer; ptd: PDVTargetDevice; hicTargetDev: HDC;
      out colorSet: PLogPalette): HResult; stdcall;
    function Freeze(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      out dwFreeze: Longint): HResult; stdcall;
    function Unfreeze(dwFreeze: Longint): HResult; stdcall;
    function SetAdvise(aspects: Longint; advf: Longint;
      const advSink: IAdviseSink): HResult; stdcall;
    function GetAdvise(pAspects: PLongint; pAdvf: PLongint;
      out advSink: IAdviseSink): HResult; stdcall;
  end;

{ IViewObject2 interface }

  IViewObject2 = interface(IViewObject)
    ['{00000127-0000-0000-C000-000000000046}']
    function GetExtent(dwDrawAspect: Longint; lindex: Longint;
      ptd: PDVTargetDevice; out size: TPoint): HResult; stdcall;
  end;

{ IDropSource interface }

  IDropSource = interface(IUnknown)
    ['{00000121-0000-0000-C000-000000000046}']
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;
  end;

{ IDropTarget interface }

  IDropTarget = interface(IUnknown)
    ['{00000122-0000-0000-C000-000000000046}']
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
  end;

{ IEnumOleVerb interface }

  POleVerb = ^TOleVerb;
  tagOLEVERB = record
    lVerb: Longint;
    lpszVerbName: POleStr;
    fuFlags: Longint;
    grfAttribs: Longint;
  end;
  TOleVerb = tagOLEVERB;
  OLEVERB = TOleVerb;


  IEnumOLEVERB = interface(IUnknown)
    ['{00000104-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumOleVerb): HResult; stdcall;
  end;

{ IOleControl interface }

  IOleControl = interface
    ['{B196B288-BAB4-101A-B69C-00AA00341D07}']
    function GetControlInfo(var ci: TControlInfo): HResult; stdcall;
    function OnMnemonic(msg: PMsg): HResult; stdcall;
    function OnAmbientPropertyChange(dispid: TDispID): HResult; stdcall;
    function FreezeEvents(bFreeze: BOOL): HResult; stdcall;
  end;

{ IOleControlSite interface }

  IOleControlSite = interface
    ['{B196B289-BAB4-101A-B69C-00AA00341D07}']
    function OnControlInfoChanged: HResult; stdcall;
    function LockInPlaceActive(fLock: BOOL): HResult; stdcall;
    function GetExtendedControl(out disp: IDispatch): HResult; stdcall;
    function TransformCoords(var ptlHimetric: TPoint; var ptfContainer: TPointF;
      flags: Longint): HResult; stdcall;
    function TranslateAccelerator(msg: PMsg; grfModifiers: Longint): HResult;
       stdcall;
    function OnFocus(fGotFocus: BOOL): HResult; stdcall;
    function ShowPropertyFrame: HResult; stdcall;
  end;

{ ISimpleFrameSite interface }

  ISimpleFrameSite = interface
    ['{742B0E01-14E6-101B-914E-00AA00300CAB}']
    function PreMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
      out res: Integer; out Cookie: Longint): HResult;
      stdcall;
    function PostMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
      out res: Integer; Cookie: Longint): HResult;
      stdcall;
  end;

{ IObjectWithSite interface }

  IObjectWithSite = interface
    ['{FC4801A3-2BA9-11CF-A229-00AA003D7352}']
    function SetSite(const pUnkSite: IUnknown ):HResult; stdcall;
    function GetSite(const riid: TIID; out site: IUnknown):HResult; stdcall;
  end;

{ IErrorLog interface }

  IErrorLog = interface
    ['{3127CA40-446E-11CE-8135-00AA004BB851}']
    function AddError(pszPropName: POleStr; pExcepInfo: PExcepInfo): HResult; stdcall;
  end;

{ IPropertyBag interface }

  IPropertyBag = interface
    ['{55272A00-42CB-11CE-8135-00AA004BB851}']
    function Read(pszPropName: POleStr; var pvar: _OleVariant;
      const pErrorLog: IErrorLog): HResult; stdcall;
    function Write(pszPropName: POleStr; const pvar: _OleVariant): HResult; stdcall;
  end;

{ IPersistPropertyBag interface }

  IPersistPropertyBag = interface(IPersist)
    ['{37D84F60-42CB-11CE-8135-00AA004BB851}']
    function InitNew: HResult; stdcall;
    function Load(const pPropBag: IPropertyBag;
      const pErrorLog: IErrorLog): HResult; stdcall;
    function Save(const pPropBag: IPropertyBag; fClearDirty: BOOL;
      fSaveAllProperties: BOOL): HResult; stdcall;
  end;

{ IPersistStreamInit interface }

  IPersistStreamInit = interface(IPersistStream)
    ['{7FD52380-4E07-101B-AE2D-08002B2EC713}']
    function InitNew: HResult; stdcall;
  end;

{ IPropertyNotifySink interface }

  IPropertyNotifySink = interface
    ['{9BFBBC02-EFF1-101A-84ED-00AA00341D07}']
    function OnChanged(dispid: TDispID): HResult; stdcall;
    function OnRequestEdit(dispid: TDispID): HResult; stdcall;
  end;

{ IProvideClassInfo interface }

  IProvideClassInfo = interface
    ['{B196B283-BAB4-101A-B69C-00AA00341D07}']
    function GetClassInfo(out ti: ITypeInfo): HResult; stdcall;
  end;

{ IConnectionPointContainer interface }

  IConnectionPointContainer = interface
    ['{B196B284-BAB4-101A-B69C-00AA00341D07}']
    function EnumConnectionPoints(out Enum: IEnumConnectionPoints): HResult;
      stdcall;
    function FindConnectionPoint(const iid: TIID;
      out cp: IConnectionPoint): HResult; stdcall;
  end;

{ IEnumConnectionPoints interface }

  IEnumConnectionPoints = interface
    ['{B196B285-BAB4-101A-B69C-00AA00341D07}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumConnectionPoints): HResult;
      stdcall;
  end;

{ IConnectionPoint interface }

  IConnectionPoint = interface
    ['{B196B286-BAB4-101A-B69C-00AA00341D07}']
    function GetConnectionInterface(out iid: TIID): HResult; stdcall;
    function GetConnectionPointContainer(out cpc: IConnectionPointContainer): HResult;
      stdcall;
    function Advise(const unkSink: IUnknown; out dwCookie: Longint): HResult; stdcall;
    function Unadvise(dwCookie: Longint): HResult; stdcall;
    function EnumConnections(out Enum: IEnumConnections): HResult; stdcall;
  end;

{ from OCIDL.H }
{ TConnectData structure }

  PConnectData = ^TConnectData;
  tagCONNECTDATA = record
    pUnk: IUnknown;
    dwCookie: Longint;
  end;
  TConnectData = tagCONNECTDATA;
  CONNECTDATA = TConnectData;


{ IEnumConnections interface }

  IEnumConnections = interface
    ['{B196B287-BAB4-101A-B69C-00AA00341D07}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumConnections): HResult; stdcall;
  end;

{ TLicInfo structure }

  PLicInfo = ^TLicInfo;
  tagLICINFO = record
    cbLicInfo: Longint;
    fRuntimeKeyAvail: BOOL;
    fLicVerified: BOOL;
  end;
  TLicInfo = tagLICINFO;
  LICINFO = TLicInfo;


{ IClassFactory2 interface }

  IClassFactory2 = interface(IClassFactory)
    ['{B196B28F-BAB4-101A-B69C-00AA00341D07}']
    function GetLicInfo(var licInfo: TLicInfo): HResult; stdcall;
    function RequestLicKey(dwResrved: Longint; out bstrKey: WideString): HResult;
      stdcall;
    function CreateInstanceLic(const unkOuter: IUnknown; const unkReserved: IUnknown;
      const iid: TIID; const bstrKey: WideString; out vObject): HResult; stdcall;
  end;

{ TCAUUID structure - a counted array of TGUID }

  PGUIDList = ^TGUIDList;
  TGUIDList = array[0..65535] of TGUID;

  PCAGUID = ^TCAGUID;
  tagCAUUID = record
    cElems: Longint;
    pElems: PGUIDList;
  end;
  TCAGUID = tagCAUUID;
  CAUUID = TCAGUID;


{ TCAPOleStr structure - a counted array of POleStr }

  PCAPOleStr = ^TCAPOleStr; //???
  tagCALPOLESTR = record
    cElems: Longint;
    pElems: POleStrList;
  end;
  CALPOLESTR = tagCALPOLESTR;
  TCAPOleStr = tagCALPOLESTR;

{ TCALongint - a counted array of Longint }

  PLongintList = ^TLongintList;
  TLongintList = array[0..65535] of Longint;

  PCALongint = ^TCALongint; //???
  tagCADWORD = record
    cElems: Longint;
    pElems: PLongintList;
  end;
  CADWORD = tagCADWORD;
  TCALongint = tagCADWORD;

{ from OLECTL.H }
{ TOCPFIParams - parameters for OleCreatePropertyFrameIndirect }

  POCPFIParams = ^TOCPFIParams;
  tagOCPFIPARAMS = record
    cbStructSize: Longint;
    hWndOwner: HWnd;
    x: Integer;
    y: Integer;
    lpszCaption: POleStr;
    cObjects: Longint;
    pObjects: Pointer;
    cPages: Longint;
    pPages: Pointer;
    lcid: TLCID;
    dispidInitialProperty: TDispID;
  end;
  TOCPFIParams = tagOCPFIPARAMS;
  OCPFIPARAMS = TOCPFIParams;


{ from OCIDL.H }
{ TPropPageInfo structure - information about a property page }

  PPropPageInfo = ^TPropPageInfo;
  tagPROPPAGEINFO = record
    cb: Longint;
    pszTitle: POleStr;
    size: TSize;
    pszDocString: POleStr;
    pszHelpFile: POleStr;
    dwHelpContext: Longint;
  end;
  TPropPageInfo = tagPROPPAGEINFO;
  PROPPAGEINFO = TPropPageInfo;


{ ISpecifyPropertyPages interface }

  ISpecifyPropertyPages = interface
    ['{B196B28B-BAB4-101A-B69C-00AA00341D07}']
    function GetPages(out pages: TCAGUID): HResult; stdcall;
  end;

{ IPerPropertyBrowsing interface }

  IPerPropertyBrowsing = interface
    ['{376BD3AA-3845-101B-84ED-08002B2EC713}']
    function GetDisplayString(dispid: TDispID; out bstr: WideString): HResult;
      stdcall;
    function MapPropertyToPage(dispid: TDispID; out clsid: TCLSID): HResult;
      stdcall;
    function GetPredefinedStrings(dispid: TDispID; out caStringsOut: TCAPOleStr;
      out caCookiesOut: TCALongint): HResult; stdcall;
    function GetPredefinedValue(dispid: TDispID; dwCookie: Longint;
      out varOut: _OleVariant): HResult; stdcall;
  end;


{ IPropertyBag2 interface }

  tagPROPBAG2 = record
    dwType: DWORD;
    vt: TVarType;
    cfType: TClipFormat;
    dwHint: DWORD;
    pstrName: POleStr;
    clsid: TCLSID;
  end;
  TPropBag2 = tagPROPBAG2;
  PPropBag2 = ^TPropBag2;

  IPropertyBag2 = interface(IUnknown)
    ['{22F55882-280B-11d0-A8A9-00A0C90C2004}']
    function Read(pPropBag: PPropBag2; pErrLog: IErrorLog;
      pvarValue: PVariant; phrError: PHResult): HRESULT; stdcall;

    function Write(cProperties: ULONG; pPropBag: PPropBag2;
      pvarValue: PVariant): HRESULT; stdcall;
    function CountProperties(var pcProperties: ULONG): HRESULT; stdcall;

    function GetPropertyInfo(iProperty, cProperties: ULONG;
      pPropBag: PPropBag2; var pcProperties: ULONG): HRESULT; stdcall;

    function LoadObject(pstrName:POleStr; dwHint: DWORD; pUnkObject: IUnknown;
      pErrLog: IErrorLog): HRESULT; stdcall;
  end;

{ IPersistPropertyBag2 interface }

  IPersistPropertyBag2 = interface(IPersist)
    ['{22F55881-280B-11d0-A8A9-00A0C90C2004}']
    function InitNew: HRESULT; stdcall;

    function Load(pPropBag: IPropertyBag2; pErrLog: IErrorLog): HRESULT; stdcall;

    function Save(pPropBag: IPropertyBag2;
      fClearDirty, fSaveAllProperties: BOOL): HRESULT; stdcall;

    function IsDirty: HRESULT; stdcall;
  end;


{ IPropertyPageSite interface }

  IPropertyPageSite = interface
    ['{B196B28C-BAB4-101A-B69C-00AA00341D07}']
    function OnStatusChange(flags: Longint): HResult; stdcall;
    function GetLocaleID(out localeID: TLCID): HResult; stdcall;
    function GetPageContainer(out unk: IUnknown): HResult; stdcall;
    function TranslateAccelerator(msg: PMsg): HResult; stdcall;
  end;

{ IPropertyPage interface }

  IPropertyPage = interface
    ['{B196B28D-BAB4-101A-B69C-00AA00341D07}']
    function SetPageSite(const pageSite: IPropertyPageSite): HResult; stdcall;
    function Activate(hwndParent: HWnd; const rc: TRect; bModal: BOOL): HResult;
      stdcall;
    function Deactivate: HResult; stdcall;
    function GetPageInfo(out pageInfo: TPropPageInfo): HResult; stdcall;
    function SetObjects(cObjects: Longint; pUnkList: PUnknownList): HResult; stdcall;
    function Show(nCmdShow: Integer): HResult; stdcall;
    function Move(const rect: TRect): HResult; stdcall;
    function IsPageDirty: HResult; stdcall;
    function Apply: HResult; stdcall;
    function Help(pszHelpDir: POleStr): HResult; stdcall;
    function TranslateAccelerator(msg: PMsg): HResult; stdcall;
  end;

{ IPropertyPage2 interface }

  IPropertyPage2 = interface(IPropertyPage)
    ['{01E44665-24AC-101B-84ED-08002B2EC713}']
    function EditProperty(dispid: TDispID): HResult; stdcall;
  end;

{ IFont interface }

  IFont = interface
    ['{BEF6E002-A874-101A-8BBA-00AA00300CAB}']
    function get_Name(out name: WideString): HResult; stdcall;
    function put_Name(name: WideString): HResult; stdcall;
    function get_Size(out size: Currency): HResult; stdcall;
    function put_Size(size: Currency): HResult; stdcall;
    function get_Bold(out bold: BOOL): HResult; stdcall;
    function put_Bold(bold: BOOL): HResult; stdcall;
    function get_Italic(out italic: BOOL): HResult; stdcall;
    function put_Italic(italic: BOOL): HResult; stdcall;
    function get_Underline(out underline: BOOL): HResult; stdcall;
    function put_Underline(underline: BOOL): HResult; stdcall;
    function get_Strikethrough(out strikethrough: BOOL): HResult; stdcall;
    function put_Strikethrough(strikethrough: BOOL): HResult; stdcall;
    function get_Weight(out weight: Smallint): HResult; stdcall;
    function put_Weight(weight: Smallint): HResult; stdcall;
    function get_Charset(out charset: Smallint): HResult; stdcall;
    function put_Charset(charset: Smallint): HResult; stdcall;
    function get_hFont(out font: HFont): HResult; stdcall;
    function Clone(out font: IFont): HResult; stdcall;
    function IsEqual(const fontOther: IFont): HResult; stdcall;
    function SetRatio(cyLogical, cyHimetric: Longint): HResult; stdcall;
    function QueryTextMetrics(out tm: TTextMetricOle): HResult; stdcall;
    function AddRefHfont(font: HFont): HResult; stdcall;
    function ReleaseHfont(font: HFont): HResult; stdcall;
  end;

{ Font dispatch interface }

  IFontDisp = interface(IDispatch)
    ['{BEF6E003-A874-101A-8BBA-00AA00300CAB}']
  end;

  Font = IFontDisp;

  PSOleAuthenticationService = ^TSOleAuthenticationService;
  tagSOLE_AUTHENTICATION_SERVICE = record
    dwAuthnSvc: Longint;
    dwAuthzSvc: Longint;
    pPrincipalName: POleStr;
    hr: HResult;
  end;
  TSOleAuthenticationService = tagSOLE_AUTHENTICATION_SERVICE;
  SOLE_AUTHENTICATION_SERVICE = TSOleAuthenticationService;


{ from OLECTL.H }
{ TFontDesc structure }

  PFontDesc = ^TFontDesc;
  tagFONTDESC = record
    cbSizeofstruct: Integer;
    lpstrName: POleStr;
    cySize: Currency;
    sWeight: Smallint;
    sCharset: Smallint;
    fItalic: BOOL;
    fUnderline: BOOL;
    fStrikethrough: BOOL;
  end;
  TFontDesc = tagFONTDESC;
  FONTDESC = TFontDesc;


{ from OCIDL.H }
{ IPicture interface }

  IPicture = interface
    ['{7BF80980-BF32-101A-8BBB-00AA00300CAB}']
    function get_Handle(out handle: OLE_HANDLE): HResult;  stdcall;
    function get_hPal(out handle: OLE_HANDLE): HResult; stdcall;
    function get_Type(out typ: Smallint): HResult; stdcall;
    function get_Width(out width: OLE_XSIZE_HIMETRIC): HResult; stdcall;
    function get_Height(out height: OLE_YSIZE_HIMETRIC): HResult; stdcall;
    function Render(dc: HDC; x, y, cx, cy: Longint;
      xSrc: OLE_XPOS_HIMETRIC; ySrc: OLE_YPOS_HIMETRIC;
      cxSrc: OLE_XSIZE_HIMETRIC; cySrc: OLE_YSIZE_HIMETRIC;
      const rcWBounds: TRect): HResult; stdcall;
    function set_hPal(hpal: OLE_HANDLE): HResult; stdcall;
    function get_CurDC(out dcOut: HDC): HResult; stdcall;
    function SelectPicture(dcIn: HDC; out hdcOut: HDC;
      out bmpOut: OLE_HANDLE): HResult; stdcall;
    function get_KeepOriginalFormat(out fkeep: BOOL): HResult; stdcall;
    function put_KeepOriginalFormat(fkeep: BOOL): HResult; stdcall;
    function PictureChanged: HResult; stdcall;
    function SaveAsFile(const stream: IStream; fSaveMemCopy: BOOL;
      out cbSize: Longint): HResult; stdcall;
    function get_Attributes(out dwAttr: Longint): HResult; stdcall;
  end;

{ Picture dispatch interface }

  IPictureDisp = interface(IDispatch)
    ['{7BF80981-BF32-101A-8BBB-00AA00300CAB}']
  end;

  Picture = IPictureDisp;

{ from OLECTL.H }
{ TPictDesc structure }

  PPictDesc = ^TPictDesc;
  tagPICTDESC = record
    cbSizeofstruct: Integer;
    picType: Integer;
    case Integer of
      PICTYPE_BITMAP: (
  hbitmap: THandle;       { Bitmap }
  hpal: THandle);         { Accompanying palette }
      PICTYPE_METAFILE: (
  hMeta: THandle;         { Metafile }
  xExt, yExt: Integer);   { Extent }
      PICTYPE_ICON: (
  hIcon: THandle);        { Icon }
      PICTYPE_ENHMETAFILE: (
  hemf: THandle);         { Enhanced Metafile }
  end;
  TPictDesc = tagPICTDESC;
  PICTDESC = TPictDesc;


{ The following ActiveDoc interfaces come from DocObj.idl }

  IOleDocumentView = interface(IUnknown)
    ['{b722bcc6-4e68-101b-a2bc-00aa00404770}']
    function SetInPlaceSite(Site: IOleInPlaceSite):HResult; stdcall;
    function GetInPlaceSite(out Site: IOleInPlaceSite):HResult; stdcall;
    function GetDocument(out P: IUnknown):HResult; stdcall;
    function SetRect(const View: TRECT):HResult; stdcall;
    function GetRect(var View: TRECT):HResult; stdcall;
    function SetRectComplex(const View, HScroll, VScroll, SizeBox):HResult; stdcall;
    function Show(fShow: BOOL):HResult; stdcall;
    function UIActivate(fUIActivate: BOOL):HResult; stdcall;
    function Open:HResult; stdcall;
    function CloseView(dwReserved: DWORD):HResult; stdcall;
    function SaveViewState(pstm: IStream):HResult; stdcall;
    function ApplyViewState(pstm: IStream):HResult; stdcall;
    function Clone(NewSite: IOleInPlaceSite; out NewView: IOleDocumentView):HResult; stdcall;
  end;

  IEnumOleDocumentViews = interface(IUnknown)
    ['{b722bcc8-4e68-101b-a2bc-00aa00404770}']
    function Next(Count: Longint; out View: IOleDocumentView; var Fetched: Longint):HResult; stdcall;
    function Skip(Count: Longint):HResult; stdcall;
    function Reset:HResult; stdcall;
    function Clone(out Enum: IEnumOleDocumentViews):HResult; stdcall;
  end;

  IOleDocument = interface(IUnknown)
    ['{b722bcc5-4e68-101b-a2bc-00aa00404770}']
    function CreateView(Site: IOleInPlaceSite; Stream: IStream; rsrvd: DWORD;
      out View: IOleDocumentView):HResult; stdcall;
    function GetDocMiscStatus(var Status: DWORD):HResult; stdcall;
    function EnumViews(out Enum: IEnumOleDocumentViews;
      out View: IOleDocumentView):HResult; stdcall;
  end;

  IOleDocumentSite = interface(IUnknown)
    ['{b722bcc7-4e68-101b-a2bc-00aa00404770}']
    function ActivateMe(View: IOleDocumentView): HRESULT; stdcall;
  end;

  IContinueCallback = interface(IUnknown)
    ['{b722bcca-4e68-101b-a2bc-00aa00404770}']
    function Continue: HResult; stdcall;
    function ContinuePrinting( nCntPrinted, nCurPage: Longint;
      PrintStatus: PWideChar): HResult; stdcall;
  end;

{!! From servprov.idl: }

  IServiceProvider = interface(IUnknown)
    ['{6d5140c1-7436-11ce-8034-00aa006009fa}']
    function QueryService(const rsid, iid: TGuid; out Obj): HResult; stdcall;
  end;


const
  PRINTFLAG_MAYBOTHERUSER         = 1;
  PRINTFLAG_PROMPTUSER            = 2;
  PRINTFLAG_USERMAYCHANGEPRINTER  = 4;
  PRINTFLAG_RECOMPOSETODEVICE     = 8;
  PRINTFLAG_DONTACTUALLYPRINT     = 16;
  PRINTFLAG_FORCEPROPERTIES       = 32;
  PRINTFLAG_PRINTTOFILE           = 64;

  PAGESET_TOLASTPAGE              = Cardinal(-1);

type
  PPageRange = ^TPageRange; //???
  tagPAGERANGE = record
    nFromPage: Longint;
    nToPage: Longint;
  end;
  PAGERANGE = tagPAGERANGE;
  TPageRange = tagPAGERANGE;

  PPageSet = ^TPageSet; //???
  tagPAGESET = record
    cbStruct: Cardinal;
    fOddPages: BOOL;
    fEvenPages: BOOL;
    cPageRange: Cardinal;
    rgPages: array [0..0] of TPageRange;
  end;
  PAGESET = tagPAGESET;
  TPageSet = tagPAGESET;

  IPrint = interface(IUnknown)
    ['{b722bcc9-4e68-101b-a2bc-00aa00404770}']
    function SetInitialPageNum(nFirstPage: Longint): HResult; stdcall;
    function GetPageInfo(var pnFirstPage, pcPages: Longint): HResult; stdcall;
    function Print(grfFlags: DWORD; var td: TDVTARGETDEVICE;
      PageSet: PPageSet; stgmOptions: PStgMedium; Callback: IContinueCallback;
      FirstPage: Longint; pcPagesPrinted, pnLastPage: PLongint): HResult; stdcall;
  end;

const
  OLECMDIDF_REFRESH_NORMAL     = 0;
  OLECMDIDF_REFRESH_IFEXPIRED  = 1;
  OLECMDIDF_REFRESH_CONTINUE   = 2;
  OLECMDIDF_REFRESH_COMPLETELY = 3;

  OLECMDF_SUPPORTED       = 1;
  OLECMDF_ENABLED         = 2;
  OLECMDF_LATCHED         = 4;
  OLECMDF_NINCHED         = 8;

  OLECMDTEXTF_NONE        = 0;
  OLECMDTEXTF_NAME        = 1;
  OLECMDTEXTF_STATUS      = 2;

  OLECMDEXECOPT_DODEFAULT         = 0;
  OLECMDEXECOPT_PROMPTUSER        = 1;
  OLECMDEXECOPT_DONTPROMPTUSER    = 2;
  OLECMDEXECOPT_SHOWHELP          = 3;

  OLECMDID_OPEN                           = 1;
  OLECMDID_NEW                            = 2;
  OLECMDID_SAVE                           = 3;
  OLECMDID_SAVEAS                         = 4;
  OLECMDID_SAVECOPYAS                     = 5;
  OLECMDID_PRINT                          = 6;
  OLECMDID_PRINTPREVIEW                   = 7;
  OLECMDID_PAGESETUP                      = 8;
  OLECMDID_SPELL                          = 9;
  OLECMDID_PROPERTIES                     = 10;
  OLECMDID_CUT                            = 11;
  OLECMDID_COPY                           = 12;
  OLECMDID_PASTE                          = 13;
  OLECMDID_PASTESPECIAL                   = 14;
  OLECMDID_UNDO                           = 15;
  OLECMDID_REDO                           = 16;
  OLECMDID_SELECTALL                      = 17;
  OLECMDID_CLEARSELECTION                 = 18;
  OLECMDID_ZOOM                           = 19;
  OLECMDID_GETZOOMRANGE                   = 20;
  OLECMDID_UPDATECOMMANDS                 = 21;
  OLECMDID_REFRESH                        = 22;
  OLECMDID_STOP                           = 23;
  OLECMDID_HIDETOOLBARS                   = 24;
  OLECMDID_SETPROGRESSMAX                 = 25;
  OLECMDID_SETPROGRESSPOS                 = 26;
  OLECMDID_SETPROGRESSTEXT                = 27;
  OLECMDID_SETTITLE                       = 28;
  OLECMDID_SETDOWNLOADSTATE               = 29;
  OLECMDID_STOPDOWNLOAD                   = 30;
    // OLECMDID_STOPDOWNLOAD is supported for QueryStatus Only

// error codes
  OLECMDERR_E_FIRST           = OLE_E_LAST+1;
  OLECMDERR_E_NOTSUPPORTED    = OLECMDERR_E_FIRST;
  OLECMDERR_E_DISABLED        = OLECMDERR_E_FIRST+1;
  OLECMDERR_E_NOHELP          = OLECMDERR_E_FIRST+2;
  OLECMDERR_E_CANCELED        = OLECMDERR_E_FIRST+3;
  OLECMDERR_E_UNKNOWNGROUP    = OLECMDERR_E_FIRST+4;

  MSOCMDERR_E_FIRST           = OLECMDERR_E_FIRST;
  MSOCMDERR_E_NOTSUPPORTED    = OLECMDERR_E_NOTSUPPORTED;
  MSOCMDERR_E_DISABLED        = OLECMDERR_E_DISABLED;
  MSOCMDERR_E_NOHELP          = OLECMDERR_E_NOHELP;
  MSOCMDERR_E_CANCELED        = OLECMDERR_E_CANCELED;
  MSOCMDERR_E_UNKNOWNGROUP    = OLECMDERR_E_UNKNOWNGROUP;

type

  POleCmd = ^TOleCmd; //???
  _tagOLECMD = record
    cmdID: Cardinal;
    cmdf: Longint;
  end;
  OLECMD = _tagOLECMD;
  TOleCmd = _tagOLECMD;

  POleCmdText = ^TOleCmdText; //???
  _tagOLECMDTEXT = record
    cmdtextf: Longint;
    cwActual: Cardinal;
    cwBuf: Cardinal;         // size in wide chars of the buffer for text
    rgwz: array [0..0] of WideChar; // Array into which callee writes the text
  end;
  OLECMDTEXT = _tagOLECMDTEXT;
  TOleCmdText = _tagOLECMDTEXT;

  IOleCommandTarget = interface(IUnknown)
    ['{b722bccb-4e68-101b-a2bc-00aa00404770}']
    function QueryStatus(CmdGroup: PGUID; cCmds: Cardinal;
      prgCmds: POleCmd; CmdText: POleCmdText): HResult; stdcall;
    function Exec(CmdGroup: PGUID; nCmdID, nCmdexecopt: DWORD;
      const vaIn: _OleVariant; var vaOut: _OleVariant): HResult; stdcall;
  end;

{ from designer.h}

const
  CATID_Designer: TGUID = '{4EB304D0-7555-11cf-A0C2-00AA0062BE57}';

type
  IActiveDesigner = interface
    ['{51AAE3E0-7486-11cf-A0C2-00AA0062BE57}']
    function GetRuntimeClassID(var clsid: TGUID): HResult; stdcall;
    function GetRuntimeMiscStatusFlags(var dwMiscFlags: DWORD): HResult; stdcall;
    function QueryPersistenceInterface(const iid: TGUID): HResult; stdcall;
    function SaveRuntimeState(const iidItf: TGUID; const iidObj: TGUID; Obj: IUnknown): HResult; stdcall;
    function GetExtensibilityObject(var ppvObjOut: IDispatch): HResult; stdcall;
  end;


{ from webdc.h }
const
  CATID_WebDesigntimeControl: TGUID = '{73cef3dd-ae85-11cf-a406-00aa00c00940}';

type
  IPersistTextStream = interface(IPersistStreamInit)
    ['{56223fe3-d397-11cf-a42e-00aa00c00940}']
  end;

  IProvideRuntimeText = interface
    ['{56223FE1-D397-11cf-A42E-00AA00C00940}']
    function GetRuntimeText( var strRuntimeText: TBSTR ): HResult; stdcall;
  end;

const
{ from CGUID.H }
{ Standard GUIDs }

  GUID_NULL: TGUID = '{00000000-0000-0000-0000-000000000000}';
  GUID_OLE_COLOR: TGUID = '{66504301-BE0F-101A-8BBB-00AA00300CAB}';

{ Additional GUIDs }

  IID_IRpcChannel: TGUID = '{00000004-0000-0000-C000-000000000046}';
  IID_IRpcStub: TGUID = '{00000005-0000-0000-C000-000000000046}';
  IID_IStubManager: TGUID = '{00000006-0000-0000-C000-000000000046}';
  IID_IRpcProxy: TGUID = '{00000007-0000-0000-C000-000000000046}';
  IID_IProxyManager: TGUID = '{00000008-0000-0000-C000-000000000046}';
  IID_IPSFactory: TGUID = '{00000009-0000-0000-C000-000000000046}';
  IID_IInternalMoniker: TGUID = '{00000011-0000-0000-C000-000000000046}';
  CLSID_StdMarshal: TGUID = '{00000017-0000-0000-C000-000000000046}';
  IID_IEnumGeneric: TGUID = '{00000106-0000-0000-C000-000000000046}';
  IID_IEnumHolder: TGUID = '{00000107-0000-0000-C000-000000000046}';
  IID_IEnumCallback: TGUID = '{00000108-0000-0000-C000-000000000046}';
  IID_IOleManager: TGUID = '{0000011F-0000-0000-C000-000000000046}';
  IID_IOlePresObj: TGUID = '{00000120-0000-0000-C000-000000000046}';
  IID_IDebug: TGUID = '{00000123-0000-0000-C000-000000000046}';
  IID_IDebugStream: TGUID = '{00000124-0000-0000-C000-000000000046}';

{ Standard class IDs }

  CLSID_CFontPropPage: TGUID = '{2542f180-3532-1069-a2cd-00aa0034b50b}';
  CLSID_CColorPropPage: TGUID = '{ddf5a600-b9c0-101a-af1a-00aa0034b50b}';
  CLSID_CPicturePropPage: TGUID = '{fc7af71d-fc74-101a-84ed-08002b2ec713}';
  CLSID_PersistPropset: TGUID = '{fb8f0821-0164-101b-84ed-08002b2ec713}';
  CLSID_ConvertVBX: TGUID = '{fb8f0822-0164-101b-84ed-08002b2ec713}';
  CLSID_StdFont: TGUID = '{fb8f0823-0164-101b-84ed-08002b2ec713}';
  CLSID_StdPicture: TGUID = '{fb8f0824-0164-101b-84ed-08002b2ec713}';

{ from comcat.h }
{ COM Category Manager Interfaces }
type
  IEnumGUID = interface;
  IEnumCATEGORYINFO = interface;
  ICatRegister = interface;
  ICatInformation = interface;

  PCATEGORYINFO = ^TCATEGORYINFO;
  TCATEGORYINFO = record
    catid: TGUID;
    lcid: UINT;
    szDescription: array[0..127] of WideChar;
  end;

  IEnumGUID = interface(IUnknown)
    ['{0002E000-0000-0000-C000-000000000046}']
    function Next(celt: UINT; out rgelt: TGUID; out pceltFetched: UINT): HResult; stdcall;
    function Skip(celt: UINT): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumGUID): HResult; stdcall;
  end;

  IEnumCATEGORYINFO = interface(IUnknown)
    ['{0002E011-0000-0000-C000-000000000046}']
    function Next(celt: UINT; out rgelt: TCATEGORYINFO; out pceltFetched: UINT): HResult; stdcall;
    function Skip(celt: UINT): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumCATEGORYINFO): HResult; stdcall;
  end;

  ICatRegister = interface(IUnknown)
    ['{0002E012-0000-0000-C000-000000000046}']
    function RegisterCategories(cCategories: UINT; rgCategoryInfo: PCATEGORYINFO): HResult; stdcall;
    function UnRegisterCategories(cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function RegisterClassImplCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function UnRegisterClassImplCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function RegisterClassReqCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function UnRegisterClassReqCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
  end;

  ICatInformation = interface(IUnknown)
    ['{0002E013-0000-0000-C000-000000000046}']
    function EnumCategories(lcid: UINT; out ppenumCategoryInfo: IEnumCATEGORYINFO): HResult; stdcall;
    function GetCategoryDesc(const rcatid: TGUID; lcid: UINT; out pszDesc: PWideChar): HResult; stdcall;
    function EnumClassesOfCategories(cImplemented: UINT; rgcatidImpl: Pointer; cRequired: UINT; rgcatidReq: Pointer; out ppenumClsid: IEnumGUID): HResult; stdcall;
    function IsClassOfCategories(const rclsid: TGUID; cImplemented: UINT; rgcatidImpl: Pointer; cRequired: UINT; rgcatidReq: Pointer): HResult; stdcall;
    function EnumImplCategoriesOfClass(var rclsid: TGUID; out ppenumCatid: IEnumGUID): HResult; stdcall;
    function EnumReqCategoriesOfClass(var rclsid: TGUID; out ppenumCatid: IEnumGUID): HResult; stdcall;
  end;


{ IBindHost Interface }
  IBindHost = interface(IUnknown)
    ['{fc4801a1-2ba9-11cf-a229-00aa003d7352}']
  end;

{ IOleUndoManager Interface }
  IOleUndoManager = interface(IUnknown)
    ['{d001f200-ef97-11ce-9bc9-00aa00608e01}']
  end;

{ IQuickActivate Interface }

  tagQACONTAINER = record
    cbSize: LongInt;
    pClientSite: IOleClientSite;
    pAdviseSink: IAdviseSink;
    pPropertyNotifySink: IPropertyNotifySink;
    pUnkEventSink: IUnknown;
    dwAmbientFlags: LongInt;
    colorFore: OLE_COLOR;
    colorBack: OLE_COLOR;
    pFont: IFont;
    pUndoMgr: IOleUndoManager;
    dwAppearance: LongInt;
    lcid: LongInt;
    hpal: HPALETTE;
    pBindHost: IBindHost;
  end;

  PQaContainer = ^tagQACONTAINER;
  TQaContainer =  tagQACONTAINER;

  tagQACONTROL = record
    cbSize: LongInt;
    dwMiscStatus: LongInt;
    dwViewStatus: LongInt;
    dwEventCookie: LongInt;
    dwPropNotifyCookie: LongInt;
    dwPointerActivationPolicy: LongInt;
  end;

  PQaControl = ^TQaControl;
  TQaControl =  tagQACONTROL;

  IQuickActivate = interface(IUnknown)
    ['{cf51ed10-62fe-11cf-bf86-00a0c9034836}']
    function QuickActivate(var qaCont: tagQACONTAINER; var qaCtrl: tagQACONTROL): HResult; stdcall;
    function SetContentExtent(const sizel: TPoint): HResult; stdcall;
    function GetContentExtent(out sizel: TPoint): HResult; stdcall;
  end;

const
  CLSID_StdComponentCategoryMgr: TGUID = '{0002E005-0000-0000-C000-000000000046}';

{ from OBJSAFE.H }

//+--------------------------------------------------------------------------=
//
//  Contents:   IObjectSafety definition
//
//
//  IObjectSafety should be implemented by objects that have interfaces which
//      support "untrusted" clients (for example, scripts). It allows the owner of
//      the object to specify which interfaces need to be protected from untrusted
//      use. Examples of interfaces that might be protected in this way are:
//
//      IID_IDispatch           - "Safe for automating with untrusted automation client or script"
//      IID_IPersist*           - "Safe for initializing with untrusted data"
//      IID_IActiveScript       - "Safe for running untrusted scripts"
//
//---------------------------------------------------------------------------=


const
  // Option bit definitions for IObjectSafety:
  INTERFACESAFE_FOR_UNTRUSTED_CALLER = 1;   // Caller of interface may be untrusted
  INTERFACESAFE_FOR_UNTRUSTED_DATA = 2;     // Data passed into interface may be untrusted

type
  IObjectSafety = interface(IUnknown)
    ['{CB5BDC81-93C1-11CF-8F20-00805F2CD064}']
    function GetInterfaceSafetyOptions(const IID: TIID; pdwSupportedOptions,
      pdwEnabledOptions: PDWORD): HResult; stdcall;
    function SetInterfaceSafetyOptions(const IID: TIID; dwOptionSetMask,
      dwEnabledOptions: DWORD): HResult; stdcall;
  end;

{ from OBJBASE.H }
{ HResult manipulation routines }

function Succeeded(Res: HResult): Boolean;
function Failed(Res: HResult): Boolean;
function ResultCode(Res: HResult): Integer;
function ResultFacility(Res: HResult): Integer;
function ResultSeverity(Res: HResult): Integer;
function MakeResult(Severity, Facility, Code: Integer): HResult;

{ GUID functions }

function IsEqualGUID(const guid1, guid2: TGUID): Boolean; stdcall;
function IsEqualIID(const iid1, iid2: TIID): Boolean; stdcall;
function IsEqualCLSID(const clsid1, clsid2: TCLSID): Boolean; stdcall;

{ Standard object API functions }

function CoBuildVersion: Longint; stdcall;

{ Init/Uninit }

const
  // flags passed as the coInit parameter to CoInitializeEx.
  COINIT_MULTITHREADED      = 0;      // OLE calls objects on any thread.
  COINIT_APARTMENTTHREADED  = 2;      // Apartment model
  COINIT_DISABLE_OLE1DDE    = 4;      // Don't use DDE for Ole1 support.
  COINIT_SPEED_OVER_MEMORY  = 8;      // Trade memory for speed.

function CoInitialize(pvReserved: Pointer): HResult; stdcall;
procedure CoUninitialize; stdcall;
function CoGetMalloc(dwMemContext: Longint; out malloc: IMalloc): HResult; stdcall;
function CoGetCurrentProcess: Longint; stdcall;
function CoRegisterMallocSpy(mallocSpy: IMallocSpy): HResult; stdcall;
function CoRevokeMallocSpy: HResult stdcall;
function CoCreateStandardMalloc(memctx: Longint; out malloc: IMalloc): HResult; stdcall;
function CoInitializeEx(pvReserved: Pointer; coInit: Longint): HResult; stdcall;

{ Register, revoke, and get class objects }

function CoGetClassObject(const clsid: TCLSID; dwClsContext: Longint;
  pvReserved: Pointer; const iid: TIID; out pv): HResult; stdcall;
function CoRegisterClassObject(const clsid: TCLSID; unk: IUnknown;
  dwClsContext: Longint; flags: Longint; out dwRegister: Longint): HResult; stdcall;
function CoRevokeClassObject(dwRegister: Longint): HResult; stdcall;
function CoResumeClassObjects: HResult; stdcall;
function CoSuspendClassObjects: HResult; stdcall;
function CoAddRefServerProcess: Longint; stdcall;
function CoReleaseServerProcess: Longint; stdcall;
function CoGetPSClsid(const iid: TIID; var pClsid: TCLSID): HResult; stdcall;
function CoRegisterPSClsid(const iid: TIID; clsid: TCLSID): HResult; stdcall;

{ Marshaling interface pointers }

function CoGetMarshalSizeMax(out ulSize: Longint; const iid: TIID;
  unk: IUnknown; dwDestContext: Longint; pvDestContext: Pointer;
  mshlflags: Longint): HResult; stdcall;
function CoMarshalInterface(stm: IStream; const iid: TIID; unk: IUnknown;
  dwDestContext: Longint; pvDestContext: Pointer;
  mshlflags: Longint): HResult; stdcall;
function CoUnmarshalInterface(stm: IStream; const iid: TIID;
  out pv): HResult; stdcall;
function CoMarshalHResult(stm: IStream; result: HResult): HResult; stdcall;
function CoUnmarshalHResult(stm: IStream; out result: HResult): HResult; stdcall;
function CoReleaseMarshalData(stm: IStream): HResult; stdcall;
function CoDisconnectObject(unk: IUnknown; dwReserved: Longint): HResult; stdcall;
function CoLockObjectExternal(unk: IUnknown; fLock: BOOL;
  fLastUnlockReleases: BOOL): HResult; stdcall;
function CoGetStandardMarshal(const iid: TIID; unk: IUnknown;
  dwDestContext: Longint; pvDestContext: Pointer; mshlflags: Longint;
  out marshal: IMarshal): HResult; stdcall;

function CoIsHandlerConnected(unk: IUnknown): BOOL; stdcall;
function CoHasStrongExternalConnections(unk: IUnknown): BOOL; stdcall;

{ Apartment model inter-thread interface passing helpers }

function CoMarshalInterThreadInterfaceInStream(const iid: TIID;
  unk: IUnknown; out stm: IStream): HResult; stdcall;
function CoGetInterfaceAndReleaseStream(stm: IStream; const iid: TIID;
  out pv): HResult; stdcall;
function CoCreateFreeThreadedMarshaler(unkOuter: IUnknown;
  out unkMarshal: IUnknown): HResult; stdcall;

{ DLL loading helpers; keeps track of ref counts and unloads all on exit }

function CoLoadLibrary(pszLibName: POleStr; bAutoFree: BOOL): THandle; stdcall;
procedure CoFreeLibrary(hInst: THandle); stdcall;
procedure CoFreeAllLibraries; stdcall;
procedure CoFreeUnusedLibraries; stdcall;

{ Call Security. }

function CoInitializeSecurity(pSecDesc: PSecurityDescriptor; cAuthSvc: Longint;
  asAuthSvc: PSOleAuthenticationService; pReserved1: Pointer;
  dwAuthnLevel, dImpLevel: Longint; pReserved2: Pointer; dwCapabilities: Longint;
  pReserved3: Pointer): HResult; stdcall;
function CoGetCallContext(const iid: TIID; pInterface: Pointer): HResult; stdcall;
function CoQueryProxyBlanket(Proxy: IUnknown; pwAuthnSvc, pAuthzSvc: PLongint;
  pServerPrincName: POleStr; pAuthnLevel, pImpLevel: PLongint;
  pAuthInfo: Pointer; pCapabilites: PLongint): HResult; stdcall;
function CoSetProxyBlanket(Proxy: IUnknown; dwAuthnSvc, dwAuthzSvc: Longint;
  pServerPrincName: POleStr; dwAuthnLevel, dwImpLevel: Longint;
  pAuthInfo: Pointer; dwCapabilites: Longint): HResult; stdcall;
function CoCopyProxy(Proxy: IUnknown; var pCopy: IUnknown): HResult; stdcall;
function CoQueryClientBlanket(pwAuthnSvc, pAuthzSvc: PLongint;
  pServerPrincName: POleStr; dwAuthnLevel, dwImpLevel: Longint;
  pPrivs: Pointer; dwCapabilites: Longint): HResult; stdcall;
function CoImpersonateClient: HResult; stdcall;
function CoRevertToSelf: HResult; stdcall;
function CoQueryAuthenticationServices(pcAuthSvc: PLongint;
  asAuthSvc: PSOleAuthenticationService): HResult; stdcall;
function CoSwitchCallContext(NewObject: IUnknown; var pOldObject: IUnknown): HResult; stdcall;

{ Helper for creating instances }

function CoCreateInstance(const clsid: TCLSID; unkOuter: IUnknown;
  dwClsContext: Longint; const iid: TIID; out pv): HResult; stdcall;
function CoGetInstanceFromFile(ServerInfo: PCoServerInfo; clsid: PCLSID;
  punkOuter: IUnknown; dwClsCtx, grfMode: Longint; pwszName: POleStr;
  dwCount: Longint; rgmqResults: PMultiQIArray): HResult; stdcall;
function CoGetInstanceFromIStorage(ServerInfo: PCoServerInfo; clsid: PCLSID;
  punkOuter: IUnknown; dwClsCtx: Longint; stg: IUnknown;
  dwCount: Longint; rgmqResults: PMultiQIArray): HResult; stdcall;
function CoCreateInstanceEx(const clsid: TCLSID;
  unkOuter: IUnknown; dwClsCtx: Longint; ServerInfo: PCoServerInfo;
  dwCount: Longint; rgmqResults: PMultiQIArray): HResult; stdcall;

{ Other helpers }

function StringFromCLSID(const clsid: TCLSID; out psz: POleStr): HResult; stdcall;
function CLSIDFromString(psz: POleStr; out clsid: TCLSID): HResult; stdcall;
function StringFromIID(const iid: TIID; out psz: POleStr): HResult; stdcall;
function IIDFromString(psz: POleStr; out iid: TIID): HResult; stdcall;
function CoIsOle1Class(const clsid: TCLSID): BOOL; stdcall;
function ProgIDFromCLSID(const clsid: TCLSID; out pszProgID: POleStr): HResult; stdcall;
function CLSIDFromProgID(pszProgID: POleStr; out clsid: TCLSID): HResult; stdcall;
function StringFromGUID2(const guid: TGUID; psz: POleStr; cbMax: Integer): Integer; stdcall;

function CoCreateGuid(out guid: TGUID): HResult; stdcall;

function CoFileTimeToDosDateTime(const filetime: TFileTime; out dosDate: Word;
  out dosTime: Word): BOOL; stdcall;
function CoDosDateTimeToFileTime(nDosDate: Word; nDosTime: Word;
  out filetime: TFileTime): BOOL; stdcall;
function CoFileTimeNow(out filetime: TFileTime): HResult; stdcall;
function CoRegisterMessageFilter(messageFilter: IMessageFilter;
  out pMessageFilter: IMessageFilter): HResult; stdcall;
function CoRegisterChannelHook(const ExtensionUuid: TGUID;
  ChannelHook: IChannelHook): HResult; stdcall;

{ TreatAs APIs }

function CoGetTreatAsClass(const clsidOld: TCLSID; out clsidNew: TCLSID): HResult; stdcall;
function CoTreatAsClass(const clsidOld: TCLSID; const clsidNew: TCLSID): HResult; stdcall;

{ The server DLLs must define their DllGetClassObject and DllCanUnloadNow
  to match these; the typedefs are located here to ensure all are changed at
  the same time }

type
  TDLLGetClassObject = function(const clsid: TCLSID; const iid: TIID;
    out pv): HResult stdcall;
  TDLLCanUnloadNow = function: HResult stdcall;

{ Default memory allocation }

function CoTaskMemAlloc(cb: Longint): Pointer; stdcall;
function CoTaskMemRealloc(pv: Pointer; cb: Longint): Pointer; stdcall;
procedure CoTaskMemFree(pv: Pointer); stdcall;

{ DV APIs }

function CreateDataAdviseHolder(out DAHolder: IDataAdviseHolder): HResult; stdcall;
function CreateDataCache(unkOuter: IUnknown; const clsid: TCLSID;
  const iid: TIID; out pv): HResult; stdcall;

{ Storage API prototypes }

function StgCreateDocfile(pwcsName: POleStr; grfMode: Longint;
  reserved: Longint; out stgOpen: IStorage): HResult; stdcall;
function StgCreateDocfileOnILockBytes(lkbyt: ILockBytes; grfMode: Longint;
  reserved: Longint; out stgOpen: IStorage): HResult; stdcall;
function StgOpenStorage(pwcsName: POleStr; stgPriority: IStorage;
  grfMode: Longint; snbExclude: TSNB; reserved: Longint;
  out stgOpen: IStorage): HResult; stdcall;
function StgOpenStorageOnILockBytes(lkbyt: ILockBytes; stgPriority: IStorage;
  grfMode: Longint; snbExclude: TSNB; reserved: Longint;
  out stgOpen: IStorage): HResult; stdcall;
function StgIsStorageFile(pwcsName: POleStr): HResult; stdcall;
function StgIsStorageILockBytes(lkbyt: ILockBytes): HResult; stdcall;
function StgSetTimes(pszName: POleStr; const ctime: TFileTime;
  const atime: TFileTime; const mtime: TFileTime): HResult; stdcall;
function StgOpenAsyncDocfileOnIFillLockBytes(flb: IFillLockBytes;
  grfMode, asyncFlags: Longint; var stgOpen: IStorage): HResult; stdcall;
function StgGetIFillLockBytesOnILockBytes(ilb: ILockBytes;
  var flb: IFillLockBytes): HResult; stdcall;
function StgGetIFillLockBytesOnFile(pwcsName: POleStr;
  var flb: IFillLockBytes): HResult; stdcall;
function StgOpenLayoutDocfile(pwcsDfName: POleStr; grfMode, reserved: Longint;
  var stgOpen: IStorage): HResult; stdcall;


{ Moniker APIs }

function BindMoniker(mk: IMoniker; grfOpt: Longint; const iidResult: TIID;
  out pvResult): HResult; stdcall;
function CoGetObject(pszName: PWideString; pBindOptions: PBindOpts;
  const iid: TIID; ppv: Pointer): HResult; stdcall;
function MkParseDisplayName(bc: IBindCtx; szUserName: POleStr;
  out chEaten: Longint; out mk: IMoniker): HResult; stdcall;
function MonikerRelativePathTo(mkSrc: IMoniker; mkDest: IMoniker;
  out mkRelPath: IMoniker; dwReserved: BOOL): HResult; stdcall;
function MonikerCommonPrefixWith(mkThis: IMoniker; mkOther: IMoniker;
  out mkCommon: IMoniker): HResult; stdcall;
function CreateBindCtx(reserved: Longint; out bc: IBindCtx): HResult; stdcall;
function CreateGenericComposite(mkFirst: IMoniker; mkRest: IMoniker;
  out mkComposite: IMoniker): HResult; stdcall;
function GetClassFile(szFilename: POleStr; out clsid: TCLSID): HResult; stdcall;
function CreateFileMoniker(pszPathName: POleStr; out mk: IMoniker): HResult; stdcall;
function CreateItemMoniker(pszDelim: POleStr; pszItem: POleStr;
  out mk: IMoniker): HResult; stdcall;
function CreateAntiMoniker(out mk: IMoniker): HResult; stdcall;
function CreatePointerMoniker(unk: IUnknown; out mk: IMoniker): HResult; stdcall;
function GetRunningObjectTable(reserved: Longint;
  out rot: IRunningObjectTable): HResult; stdcall;

{ from OLEAUTO.H }
{ TBStr API }

function SysAllocString(psz: POleStr): TBStr; stdcall;
function SysReAllocString(var bstr: TBStr; psz: POleStr): Integer; stdcall;
function SysAllocStringLen(psz: POleStr; len: Integer): TBStr; stdcall;
function SysReAllocStringLen(var bstr: TBStr; psz: POleStr;
  len: Integer): Integer; stdcall;
procedure SysFreeString(bstr: TBStr); stdcall;
function SysStringLen(bstr: TBStr): Integer; stdcall;
function SysStringByteLen(bstr: TBStr): Integer; stdcall;
function SysAllocStringByteLen(psz: PAnsiChar; len: Integer): TBStr; stdcall;

{ Time API }

function DosDateTimeToVariantTime(wDosDate, wDosTime: Word;
  out vtime: TOleDate): Integer; stdcall;
function VariantTimeToDosDateTime(vtime: TOleDate; out wDosDate,
  wDosTime: Word): Integer; stdcall;
function SystemTimeToVariantTime(var SystemTime: TSystemTime;
  out vtime: TOleDate): Integer; stdcall;
function VariantTimeToSystemTime(vtime: TOleDate;
  out SystemTime: TSystemTime): Integer; stdcall;

{ SafeArray API }

function SafeArrayAllocDescriptor(cDims: Integer; out psaOut: PSafeArray): HResult; stdcall;
function SafeArrayAllocData(psa: PSafeArray): HResult; stdcall;
function SafeArrayCreate(vt: TVarType; cDims: Integer; const rgsabound): PSafeArray; stdcall;
function SafeArrayCreateVector(vt: TVarType; Lbound, cElements: Longint): PSafeArray; stdcall;
function SafeArrayCopyData(psaSource, psaTarget: PSafeArray): HResult; stdcall;
function SafeArrayDestroyDescriptor(psa: PSafeArray): HResult; stdcall;
function SafeArrayDestroyData(psa: PSafeArray): HResult; stdcall;
function SafeArrayDestroy(psa: PSafeArray): HResult; stdcall;
function SafeArrayRedim(psa: PSafeArray; const saboundNew: TSafeArrayBound): HResult; stdcall;
function SafeArrayGetDim(psa: PSafeArray): Integer; stdcall;
function SafeArrayGetElemsize(psa: PSafeArray): Integer; stdcall;
function SafeArrayGetUBound(psa: PSafeArray; nDim: Integer; out lUbound: Longint): HResult; stdcall;
function SafeArrayGetLBound(psa: PSafeArray; nDim: Integer; out lLbound: Longint): HResult; stdcall;
function SafeArrayLock(psa: PSafeArray): HResult; stdcall;
function SafeArrayUnlock(psa: PSafeArray): HResult; stdcall;
function SafeArrayAccessData(psa: PSafeArray; out pvData: Pointer): HResult; stdcall;
function SafeArrayUnaccessData(psa: PSafeArray): HResult; stdcall;
function SafeArrayGetElement(psa: PSafeArray; const rgIndices; out pv): HResult; stdcall;
function SafeArrayPutElement(psa: PSafeArray; const rgIndices; const pv): HResult; stdcall;
function SafeArrayCopy(psa: PSafeArray; out psaOut: PSafeArray): HResult; stdcall;
function SafeArrayPtrOfIndex(psa: PSafeArray; var rgIndices; out pvData: Pointer): HResult; stdcall;

{ Variant API }

procedure VariantInit(var varg: _OleVariant); stdcall;
function VariantClear(var varg: _OleVariant): HResult; stdcall;
function VariantCopy(var vargDest: _OleVariant; const vargSrc: _OleVariant): HResult; stdcall;
function VariantCopyInd(var varDest: _OleVariant; const vargSrc: _OleVariant): HResult; stdcall;
function VariantChangeType(var vargDest: _OleVariant; const vargSrc: _OleVariant;
  wFlags: Word; vt: TVarType): HResult; stdcall;
function VariantChangeTypeEx(var vargDest: _OleVariant; const vargSrc: _OleVariant;
  lcid: TLCID; wFlags: Word; vt: TVarType): HResult; stdcall;

{ Vector <-> Bstr conversion APIs }

function VectorFromBstr(bstr: TBStr; out psa: PSafeArray): HResult; stdcall;
function BstrFromVector(psa: PSafeArray; out bstr: TBStr): HResult; stdcall;

{ VarType coercion API }

{ Note: The routines that convert from a string are defined
  to take a POleStr rather than a TBStr because no allocation is
  required, and this makes the routines a bit more generic.
  They may of course still be passed a TBStr as the strIn param. }

{ Any of the coersion functions that converts either from or to a string
  takes an additional lcid and dwFlags arguments. The lcid argument allows
  locale specific parsing to occur.  The dwFlags allow additional function
  specific condition to occur.  All function that accept the dwFlags argument
  can include either 0 or LOCALE_NOUSEROVERRIDE flag. In addition, the
  VarDateFromStr functions also accepts the VAR_TIMEVALUEONLY and
  VAR_DATEVALUEONLY flags }

function VarUI1FromI2(sIn: Smallint; out bOut: Byte): HResult; stdcall;
function VarUI1FromI4(lIn: Longint; out bOut: Byte): HResult; stdcall;
function VarUI1FromR4(fltIn: Single; out bOut: Byte): HResult; stdcall;
function VarUI1FromR8(dblIn: Double; out bOut: Byte): HResult; stdcall;
function VarUI1FromCy(cyIn: Currency; out bOut: Byte): HResult; stdcall;
function VarUI1FromDate(dateIn: TOleDate; out bOut: Byte): HResult; stdcall;
function VarUI1FromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out bOut: Byte): HResult; stdcall;
function VarUI1FromDisp(dispIn: IDispatch; lcid: TLCID; out bOut: Byte): HResult; stdcall;
function VarUI1FromBool(boolIn: TOleBool; out bOut: Byte): HResult; stdcall;
function VarUI1FromI1(cIn: AnsiChar; out bOut: Byte): HResult; stdcall;
function VarUI1FromUI2(uiIn: Word; out bOut: Byte): HResult; stdcall;
function VarUI1FromUI4(ulIn: Longint; out bOut: Byte): HResult; stdcall;
function VarUI1FromDec(pdecIn: PDecimal; out bOut: Byte): HResult; stdcall;

function VarI2FromUI1(bIn: Byte; out sOut: Smallint): HResult; stdcall;
function VarI2FromI4(lIn: Longint; out sOut: Smallint): HResult; stdcall;
function VarI2FromR4(fltIn: Single; out sOut: Smallint): HResult; stdcall;
function VarI2FromR8(dblIn: Double; out sOut: Smallint): HResult; stdcall;
function VarI2FromCy(cyIn: Currency; out sOut: Smallint): HResult; stdcall;
function VarI2FromDate(dateIn: TOleDate; out sOut: Smallint): HResult; stdcall;
function VarI2FromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out sOut: Smallint): HResult; stdcall;
function VarI2FromDisp(dispIn: IDispatch; lcid: TLCID; out sOut: Smallint): HResult; stdcall;
function VarI2FromBool(boolIn: TOleBool; out sOut: Smallint): HResult; stdcall;
function VarI2FromI1(cIn: AnsiChar; out bOut: Smallint): HResult; stdcall;
function VarI2FromUI2(uiIn: Word; out bOut: Smallint): HResult; stdcall;
function VarI2FromUI4(ulIn: Longint; out bOut: Smallint): HResult; stdcall;
function VarI2FromDec(pdecIn: PDecimal; out bOut: Smallint): HResult; stdcall;

function VarI4FromUI1(bIn: Byte; out lOut: Longint): HResult; stdcall;
function VarI4FromI2(sIn: Smallint; out lOut: Longint): HResult; stdcall;
function VarI4FromR4(fltIn: Single; out lOut: Longint): HResult; stdcall;
function VarI4FromR8(dblIn: Double; out lOut: Longint): HResult; stdcall;
function VarI4FromCy(cyIn: Currency; out lOut: Longint): HResult; stdcall;
function VarI4FromDate(dateIn: TOleDate; out lOut: Longint): HResult; stdcall;
function VarI4FromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out lOut: Longint): HResult; stdcall;
function VarI4FromDisp(dispIn: IDispatch; lcid: TLCID; out lOut: Longint): HResult; stdcall;
function VarI4FromBool(boolIn: TOleBool; out lOut: Longint): HResult; stdcall;
function VarI4FromI1(cIn: AnsiChar; out bOut: Longint): HResult; stdcall;
function VarI4FromUI2(uiIn: Word; out bOut: Longint): HResult; stdcall;
function VarI4FromUI4(ulIn: Longint; out bOut: Longint): HResult; stdcall;
function VarI4FromDec(pdecIn: PDecimal; out bOut: Longint): HResult; stdcall;
function VarI4FromInt(intIn: Integer; out bOut: Longint): HResult; stdcall;

function VarR4FromUI1(bIn: Byte; out fltOut: Single): HResult; stdcall;
function VarR4FromI2(sIn: Smallint; out fltOut: Single): HResult; stdcall;
function VarR4FromI4(lIn: Longint; out fltOut: Single): HResult; stdcall;
function VarR4FromR8(dblIn: Double; out fltOut: Single): HResult; stdcall;
function VarR4FromCy(cyIn: Currency; out fltOut: Single): HResult; stdcall;
function VarR4FromDate(dateIn: TOleDate; out fltOut: Single): HResult; stdcall;
function VarR4FromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out fltOut: Single): HResult; stdcall;
function VarR4FromDisp(dispIn: IDispatch; lcid: TLCID; out fltOut: Single): HResult; stdcall;
function VarR4FromBool(boolIn: TOleBool; out fltOut: Single): HResult; stdcall;
function VarR4FromI1(cIn: AnsiChar; out bOut: Single): HResult; stdcall;
function VarR4FromUI2(uiIn: Word; out bOut: Single): HResult; stdcall;
function VarR4FromUI4(ulIn: Longint; out bOut: Single): HResult; stdcall;
function VarR4FromDec(pdecIn: PDecimal; out bOut: Single): HResult; stdcall;

function VarR8FromUI1(bIn: Byte; out dblOut: Double): HResult; stdcall;
function VarR8FromI2(sIn: Smallint; out dblOut: Double): HResult; stdcall;
function VarR8FromI4(lIn: Longint; out dblOut: Double): HResult; stdcall;
function VarR8FromR4(fltIn: Single; out dblOut: Double): HResult; stdcall;
function VarR8FromCy(cyIn: Currency; out dblOut: Double): HResult; stdcall;
function VarR8FromDate(dateIn: TOleDate; out dblOut: Double): HResult; stdcall;
function VarR8FromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out dblOut: Double): HResult; stdcall;
function VarR8FromDisp(dispIn: IDispatch; lcid: TLCID; out dblOut: Double): HResult; stdcall;
function VarR8FromBool(boolIn: TOleBool; out dblOut: Double): HResult; stdcall;
function VarR8FromI1(cIn: AnsiChar; out bOut: Double): HResult; stdcall;
function VarR8FromUI2(uiIn: Word; out bOut: Double): HResult; stdcall;
function VarR8FromUI4(ulIn: Longint; out bOut: Double): HResult; stdcall;
function VarR8FromDec(pdecIn: PDecimal; out bOut: Double): HResult; stdcall;

function VarDateFromUI1(bIn: Byte; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromI2(sIn: Smallint; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromI4(lIn: Longint; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromR4(fltIn: Single; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromR8(dblIn: Double; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromCy(cyIn: Currency; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromDisp(dispIn: IDispatch; lcid: TLCID; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromBool(boolIn: TOleBool; out dateOut: TOleDate): HResult; stdcall;
function VarDateFromI1(cIn: AnsiChar; out bOut: TOleDate): HResult; stdcall;
function VarDateFromUI2(uiIn: Word; out bOut: TOleDate): HResult; stdcall;
function VarDateFromUI4(ulIn: Longint; out bOut: TOleDate): HResult; stdcall;
function VarDateFromDec(pdecIn: PDecimal; out bOut: TOleDate): HResult; stdcall;

function VarCyFromUI1(bIn: Byte; out cyOut: Currency): HResult; stdcall;
function VarCyFromI2(sIn: Smallint; out cyOut: Currency): HResult; stdcall;
function VarCyFromI4(lIn: Longint; out cyOut: Currency): HResult; stdcall;
function VarCyFromR4(fltIn: Single; out cyOut: Currency): HResult; stdcall;
function VarCyFromR8(dblIn: Double; out cyOut: Currency): HResult; stdcall;
function VarCyFromDate(dateIn: TOleDate; out cyOut: Currency): HResult; stdcall;
function VarCyFromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out cyOut: Currency): HResult; stdcall;
function VarCyFromDisp(dispIn: IDispatch; lcid: TLCID; out cyOut: Currency): HResult; stdcall;
function VarCyFromBool(boolIn: TOleBool; out cyOut: Currency): HResult; stdcall;
function VarCyFromI1(cIn: AnsiChar; out bOut: Currency): HResult; stdcall;
function VarCyFromUI2(uiIn: Word; out bOut: Currency): HResult; stdcall;
function VarCyFromUI4(ulIn: Longint; out bOut: Currency): HResult; stdcall;
function VarCyFromDec(pdecIn: PDecimal; out bOut: Currency): HResult; stdcall;

function VarBStrFromUI1(bVal: Byte; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromI2(iVal: Smallint; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromI4(lIn: Longint; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromR4(fltIn: Single; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromR8(dblIn: Double; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromCy(cyIn: Currency; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromDate(dateIn: TOleDate; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromDisp(dispIn: IDispatch; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromBool(boolIn: TOleBool; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromI1(cIn: AnsiChar; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromUI2(uiIn: Word; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromUI4(ulIn: Longint; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;
function VarBStrFromDec(pdecIn: PDecimal; lcid: TLCID; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;

function VarBoolFromUI1(bIn: Byte; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromI2(sIn: Smallint; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromI4(lIn: Longint; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromR4(fltIn: Single; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromR8(dblIn: Double; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromDate(dateIn: TOleDate; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromCy(cyIn: Currency; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromStr(const strIn: WideString; lcid: TLCID; dwFlags: Longint; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromDisp(dispIn: IDispatch; lcid: TLCID; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromI1(cIn: AnsiChar; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromUI2(uiIn: Word; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromUI4(ulIn: Longint; out boolOut: TOleBool): HResult; stdcall;
function VarBoolFromDec(pdecIn: PDecimal; out boolOut: TOleBool): HResult; stdcall;

{ TypeInfo API }

function LHashValOfNameSys(syskind: TSysKind; lcid: TLCID;
  szName: POleStr): Longint; stdcall;
function LHashValOfNameSysA(syskind: TSysKind; lcid: TLCID;
  szName: PAnsiChar): Longint; stdcall;

function LHashValOfName(lcid: TLCID; szName: POleStr): Longint;
function WHashValOfLHashVal(lhashval: Longint): Word;
function IsHashValCompatible(lhashval1, lhashval2: Longint): Boolean;

function LoadTypeLib(szFile: POleStr; out tlib: ITypeLib): HResult; stdcall;
function LoadTypeLibEx(szFile: POleStr; regkind: TRegKind; out tlib: ITypeLib): HResult; stdcall;
function LoadRegTypeLib(const guid: TGUID; wVerMajor, wVerMinor: Word;
  lcid: TLCID; out tlib: ITypeLib): HResult; stdcall;
function QueryPathOfRegTypeLib(const guid: TGUID; wMaj, wMin: Word;
  lcid: TLCID; out bstrPathName: WideString): HResult; stdcall;
function RegisterTypeLib(tlib: ITypeLib; szFullPath, szHelpDir: POleStr): HResult; stdcall;
function UnRegisterTypeLib(const libID: TGUID; wVerMajor, wVerMinor: Word;
  lcid: TLCID; syskind: TSysKind): HResult; stdcall;
function CreateTypeLib(syskind: TSysKind; szFile: POleStr;
  out ctlib: ICreateTypeLib): HResult; stdcall;
function CreateTypeLib2(syskind: TSysKind; szFile: POleStr;
  out ctlib: ICreateTypeLib2): HResult; stdcall;

{ IDispatch implementation support }

function DispGetParam(const dispparams: TDispParams; position: Integer;
  vtTarg: TVarType; var varResult: _OleVariant; var puArgErr: Integer): HResult; stdcall;
function DispGetIDsOfNames(tinfo: ITypeInfo; rgszNames: POleStrList;
  cNames: Integer; rgdispid: PDispIDList): HResult; stdcall;
function DispInvoke(This: Pointer; tinfo: ITypeInfo; dispidMember: TDispID;
  wFlags: Word; var params: TDispParams; varResult: PVariant;
  excepinfo: PExcepInfo; puArgErr: PInteger): HResult; stdcall;
function CreateDispTypeInfo(var idata: TInterfaceData; lcid: TLCID;
  out tinfo: ITypeInfo): HResult; stdcall;
function CreateStdDispatch(unkOuter: IUnknown; pvThis: Pointer;
  tinfo: ITypeInfo; out unkStdDisp: IUnknown): HResult; stdcall;
function DispCallFunc(pvInstance: Pointer; oVft: Longint; cc: TCallConv;
  vtReturn: TVarType; cActuals: Longint; var rgvt: TVarType; var prgpvarg: _OleVariant;
  var vargResult: _OleVariant): HResult; stdcall;


{ Active object registration API }
const
  ACTIVEOBJECT_STRONG = 0;
  ACTIVEOBJECT_WEAK = 1;

function RegisterActiveObject(unk: IUnknown; const clsid: TCLSID;
  dwFlags: Longint; out dwRegister: Longint): HResult; stdcall;
function RevokeActiveObject(dwRegister: Longint; pvReserved: Pointer): HResult; stdcall;
function GetActiveObject(const clsid: TCLSID; pvReserved: Pointer;
  out unk: IUnknown): HResult; stdcall;

{ ErrorInfo API }

function SetErrorInfo(dwReserved: Longint; errinfo: IErrorInfo): HResult; stdcall;
function GetErrorInfo(dwReserved: Longint; out errinfo: IErrorInfo): HResult; stdcall;
function CreateErrorInfo(out errinfo: ICreateErrorInfo): HResult; stdcall;

{ Misc API }

function OaBuildVersion: Longint; stdcall;

procedure ClearCustData(var pCustData: TCustData); stdcall;

{ from OLE2.H }
{ OLE API prototypes }

function OleBuildVersion: HResult; stdcall;

{ helper functions }

function ReadClassStg(stg: IStorage; out clsid: TCLSID): HResult; stdcall;
function WriteClassStg(stg: IStorage; const clsid: TIID): HResult; stdcall;
function ReadClassStm(stm: IStream; out clsid: TCLSID): HResult; stdcall;
function WriteClassStm(stm: IStream; const clsid: TIID): HResult; stdcall;
function WriteFmtUserTypeStg(stg: IStorage; cf: TClipFormat;
  pszUserType: POleStr): HResult; stdcall;
function ReadFmtUserTypeStg(stg: IStorage; out cf: TClipFormat;
  out pszUserType: POleStr): HResult; stdcall;

{ Initialization and termination }

function OleInitialize(pwReserved: Pointer): HResult; stdcall;
procedure OleUninitialize; stdcall;

{ APIs to query whether (Embedded/Linked) object can be created from
  the data object }

function OleQueryLinkFromData(srcDataObject: IDataObject): HResult; stdcall;
function OleQueryCreateFromData(srcDataObject: IDataObject): HResult; stdcall;

{ Object creation APIs }

function OleCreate(const clsid: TCLSID; const iid: TIID; renderopt: Longint;
  formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateEx(const clsid: TCLSID; const iid: TIID;
  dwFlags, renderopt, cFormats: Longint; rgAdvf: PLongintList; rgFFormatEtc: PFormatEtc;
  AdviseSink: IAdviseSink; rgdwConnection: PLongintList; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateFromData(srcDataObj: IDataObject; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateFromDataEx(srcDataObj: IDataObject; const iid: TIID;
  dwFlags, renderopt, cFormats: Longint; rgAdvf: PLongintList; rgFFormatEtc: PFormatEtc;
  AdviseSink: IAdviseSink; rgdwConnection: PLongintList; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateLinkFromData(srcDataObj: IDataObject; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateLinkFromDataEx(srcDataObj: IDataObject; const iid: TIID;
  dwFlags, renderopt, cFormats: Longint; rgAdvf: PLongintList; rgFFormatEtc: PFormatEtc;
  AdviseSink: IAdviseSink; rgdwConnection: PLongintList; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateStaticFromData(srcDataObj: IDataObject; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateLink(mkLinkSrc: IMoniker; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateLinkEx(mkLinkSrc: IMoniker; const iid: TIID;
  dwFlags, renderopt, cFormats: Longint; rgAdvf: PLongintList; rgFFormatEtc: PFormatEtc;
  AdviseSink: IAdviseSink; rgdwConnection: PLongintList; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateLinkToFile(pszFileName: POleStr; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateLinkToFileEx(pszFileName: POleStr; const iid: TIID;
  dwFlags, renderopt, cFormats: Longint; rgAdvf: PLongintList; rgFFormatEtc: PFormatEtc;
  AdviseSink: IAdviseSink; rgdwConnection: PLongintList; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleCreateFromFile(const clsid: TCLSID; pszFileName: POleStr;
  const iid: TIID; renderopt: Longint; formatEtc: PFormatEtc;
  clientSite: IOleClientSite; stg: IStorage; out vObj): HResult; stdcall;
function OleCreateFromFileEx(const clsid: TCLSID; pszFileName: POleStr; const iid: TIID;
  dwFlags, renderopt, cFormats: Longint; rgAdvf: PLongintList; rgFFormatEtc: PFormatEtc;
  AdviseSink: IAdviseSink; rgdwConnection: PLongintList; clientSite: IOleClientSite;
  stg: IStorage; out vObj): HResult; stdcall;
function OleLoad(stg: IStorage; const iid: TIID; clientSite: IOleClientSite;
  out vObj): HResult; stdcall;
function OleSave(ps: IPersistStorage; stg: IStorage; fSameAsLoad: BOOL): HResult; stdcall;
function OleLoadFromStream(stm: IStream; const iidInterface: TIID;
  out vObj): HResult; stdcall;
function OleSaveToStream(pstm: IPersistStream; stm: IStream): HResult; stdcall;
function OleSetContainedObject(unknown: IUnknown; fContained: BOOL): HResult; stdcall;
function OleNoteObjectVisible(unknown: IUnknown; fVisible: BOOL): HResult; stdcall;

{ DragDrop APIs }

function RegisterDragDrop(wnd: HWnd; dropTarget: IDropTarget): HResult; stdcall;
function RevokeDragDrop(wnd: HWnd): HResult; stdcall;
function DoDragDrop(dataObj: IDataObject; dropSource: IDropSource;
  dwOKEffects: Longint; var dwEffect: Longint): HResult; stdcall;

{ Clipboard APIs }

function OleSetClipboard(dataObj: IDataObject): HResult; stdcall;
function OleGetClipboard(out dataObj: IDataObject): HResult; stdcall;
function OleFlushClipboard: HResult; stdcall;
function OleIsCurrentClipboard(dataObj: IDataObject): HResult; stdcall;

{ In-place editing APIs }

function OleCreateMenuDescriptor(hmenuCombined: HMenu;
  var menuWidths: TOleMenuGroupWidths): HMenu; stdcall;
function OleSetMenuDescriptor(holemenu: HMenu; hwndFrame: HWnd;
  hwndActiveObject: HWnd; frame: IOleInPlaceFrame;
  activeObj: IOleInPlaceActiveObject): HResult; stdcall;
function OleDestroyMenuDescriptor(holemenu: HMenu): HResult; stdcall;
function OleTranslateAccelerator(frame: IOleInPlaceFrame;
  var frameInfo: TOleInPlaceFrameInfo; msg: PMsg): HResult; stdcall;

{ Helper APIs }

function OleDuplicateData(hSrc: THandle; cfFormat: TClipFormat;
  uiFlags: Integer): THandle; stdcall;
function OleDraw(unknown: IUnknown; dwAspect: Longint; hdcDraw: HDC;
  const rcBounds: TRect): HResult; stdcall;
function OleRun(unknown: IUnknown): HResult; stdcall;
function OleIsRunning(obj: IOleObject): BOOL; stdcall;
function OleLockRunning(unknown: IUnknown; fLock: BOOL;
  fLastUnlockCloses: BOOL): HResult; stdcall;
procedure ReleaseStgMedium(var medium: TStgMedium); stdcall;
function CreateOleAdviseHolder(out OAHolder: IOleAdviseHolder): HResult; stdcall;
function OleCreateDefaultHandler(const clsid: TCLSID; unkOuter: IUnknown;
  const iid: TIID; out vObj): HResult; stdcall;
function OleCreateEmbeddingHelper(const clsid: TCLSID; unkOuter: IUnknown;
  flags: Longint; cf: IClassFactory; const iid: TIID; out vObj): HResult; stdcall;
function IsAccelerator(accel: HAccel; cAccelEntries: Integer; msg: PMsg;
  var pwCmd: Word): BOOL; stdcall;

{ Icon extraction helper APIs }

function OleGetIconOfFile(pszPath: POleStr; fUseFileAsLabel: BOOL): HGlobal; stdcall;
function OleGetIconOfClass(const clsid: TCLSID; pszLabel: POleStr;
  fUseTypeAsLabel: BOOL): HGlobal; stdcall;
function OleMetafilePictFromIconAndLabel(icon: HIcon; pszLabel: POleStr;
  pszSourceFile: POleStr; iIconIndex: Integer): HGlobal; stdcall;

{ Registration database helper APIs }

function OleRegGetUserType(const clsid: TCLSID; dwFormOfType: Longint;
  out pszUserType: POleStr): HResult; stdcall;
function OleRegGetMiscStatus(const clsid: TCLSID; dwAspect: Longint;
  out dwStatus: Longint): HResult; stdcall;
function OleRegEnumFormatEtc(const clsid: TCLSID; dwDirection: Longint;
  out Enum: IEnumFormatEtc): HResult; stdcall;
function OleRegEnumVerbs(const clsid: TCLSID;
  out Enum: IEnumOleVerb): HResult; stdcall;

{ OLE 1.0 conversion APIs }

function OleConvertIStorageToOLESTREAM(stg: IStorage;
  polestm: Pointer): HResult; stdcall;
function OleConvertOLESTREAMToIStorage(polestm: Pointer; stg: IStorage;
  td: PDVTargetDevice): HResult; stdcall;
function OleConvertIStorageToOLESTREAMEx(stg: IStorage; cfFormat: TClipFormat;
  lWidth: Longint; lHeight: Longint; dwSize: Longint; var medium: TStgMedium;
  polestm: Pointer): HResult; stdcall;
function OleConvertOLESTREAMToIStorageEx(polestm: Pointer; stg: IStorage;
  var cfFormat: TClipFormat; var lWidth: Longint; var lHeight: Longint;
  var dwSize: Longint; var medium: TStgMedium): HResult; stdcall;

{ Storage utility APIs }

function GetHGlobalFromILockBytes(lkbyt: ILockBytes; out hglob: HGlobal): HResult; stdcall;
function CreateILockBytesOnHGlobal(hglob: HGlobal; fDeleteOnRelease: BOOL;
  out lkbyt: ILockBytes): HResult; stdcall;
function GetHGlobalFromStream(stm: IStream; out hglob: HGlobal): HResult; stdcall;
function CreateStreamOnHGlobal(hglob: HGlobal; fDeleteOnRelease: BOOL;
  out stm: IStream): HResult; stdcall;

{ ConvertTo APIs }

function OleDoAutoConvert(stg: IStorage; out clsidNew: TCLSID): HResult; stdcall;
function OleGetAutoConvert(const clsidOld: TCLSID; out clsidNew: TCLSID): HResult; stdcall;
function OleSetAutoConvert(const clsidOld: TCLSID; const clsidNew: TCLSID): HResult; stdcall;
function GetConvertStg(stg: IStorage): HResult; stdcall;
function SetConvertStg(stg: IStorage; fConvert: BOOL): HResult; stdcall;

{ from OLECTL.H }
{ Property frame APIs }

function OleCreatePropertyFrame(hwndOwner: HWnd; x, y: Integer;
  lpszCaption: POleStr; cObjects: Integer; pObjects: Pointer;
  cPages: Integer; pPageCLSIDs: Pointer; lcid: TLCID; dwReserved: Longint;
  pvReserved: Pointer): HResult; stdcall;
function OleCreatePropertyFrameIndirect(const Params: TOCPFIParams): HResult; stdcall;

{ Standard type APIs }

function OleTranslateColor(clr: TOleColor; hpal: HPalette;
 out colorref: TColorRef): HResult; stdcall;
function OleCreateFontIndirect(const FontDesc: TFontDesc; const iid: TIID;
  out vObject): HResult; stdcall;
function OleCreatePictureIndirect(const PictDesc: TPictDesc; const iid: TIID;
  fOwn: BOOL; out vObject): HResult; stdcall;
function OleLoadPicture(stream: IStream; lSize: Longint; fRunmode: BOOL;
  const iid: TIID; out vObject): HResult; stdcall;
function OleLoadPicturePath(szURLorPath: POleStr; unkCaller: IUnknown;
  dwReserved: Longint; clrReserved: TOleColor; const iid: TIID;
  ppvRet: Pointer): HResult; stdcall;
function OleLoadPictureFile(varFileName: _OleVariant;
  var lpdispPicture: IDispatch): HResult; stdcall;
function OleSavePictureFile(dispPicture: IDispatch;
  bstrFileName: TBStr): HResult; stdcall;
function OleIconToCursor(hinstExe: THandle; hIcon: THandle): HCursor; stdcall;

// Macros for parsing the OS Version of the Property Set Header
function PROPSETHDR_OSVER_KIND(dwOSVer: DWORD): Word;
function PROPSETHDR_OSVER_MAJOR(dwOSVer: DWORD): Byte;
function PROPSETHDR_OSVER_MINOR(dwOSVer: DWORD): Byte;

const
  PROPSETHDR_OSVERSION_UNKNOWN        = $FFFFFFFF;


implementation

const
  ole32    = 'ole32.dll';
  oleaut32 = 'oleaut32.dll';
  olepro32 = 'olepro32.dll';


{ Externals from ole32.dll }

function IsEqualGUID;                   external ole32 name 'IsEqualGUID';
function IsEqualIID;                    external ole32 name 'IsEqualGUID';
function IsEqualCLSID;                  external ole32 name 'IsEqualGUID';
function CoBuildVersion;                external ole32 name 'CoBuildVersion';
function CoInitialize;                  external ole32 name 'CoInitialize';
function CoInitializeEx;                external ole32 name 'CoInitializeEx';
procedure CoUninitialize;               external ole32 name 'CoUninitialize';
function CoGetMalloc;                   external ole32 name 'CoGetMalloc';
function CoGetCurrentProcess;           external ole32 name 'CoGetCurrentProcess';
function CoRegisterMallocSpy;           external ole32 name 'CoRegisterMallocSpy';
function CoRevokeMallocSpy;             external ole32 name 'CoRevokeMallocSpy';
function CoCreateStandardMalloc;        external ole32 name 'CoCreateStandardMalloc';
function CoGetClassObject;              external ole32 name 'CoGetClassObject';
function CoRegisterClassObject;         external ole32 name 'CoRegisterClassObject';
function CoRevokeClassObject;           external ole32 name 'CoRevokeClassObject';
function CoResumeClassObjects;          external ole32 name 'CoResumeClassObjects';
function CoSuspendClassObjects;         external ole32 name 'CoSuspendClassObjects';
function CoAddRefServerProcess;         external ole32 name 'CoAddRefServerProcess';
function CoReleaseServerProcess;        external ole32 name 'CoReleaseServerProcess';
function CoGetPSClsid;                  external ole32 name 'CoGetPSClsid';
function CoRegisterPSClsid;             external ole32 name 'CoRegisterPSClsid';
function CoGetMarshalSizeMax;           external ole32 name 'CoGetMarshalSizeMax';
function CoMarshalInterface;            external ole32 name 'CoMarshalInterface';
function CoUnmarshalInterface;          external ole32 name 'CoUnmarshalInterface';
function CoMarshalHResult;              external ole32 name 'CoMarshalHResult';
function CoUnmarshalHResult;            external ole32 name 'CoUnmarshalHResult';
function CoReleaseMarshalData;          external ole32 name 'CoReleaseMarshalData';
function CoDisconnectObject;            external ole32 name 'CoDisconnectObject';
function CoLockObjectExternal;          external ole32 name 'CoLockObjectExternal';
function CoGetStandardMarshal;          external ole32 name 'CoGetStandardMarshal';
function CoIsHandlerConnected;          external ole32 name 'CoIsHandlerConnected';
function CoHasStrongExternalConnections; external ole32 name 'CoHasStrongExternalConnections';
function CoMarshalInterThreadInterfaceInStream; external ole32 name 'CoMarshalInterThreadInterfaceInStream';
function CoGetInterfaceAndReleaseStream; external ole32 name 'CoGetInterfaceAndReleaseStream';
function CoCreateFreeThreadedMarshaler; external ole32 name 'CoCreateFreeThreadedMarshaler';
function CoLoadLibrary;                 external ole32 name 'CoLoadLibrary';
procedure CoFreeLibrary;                external ole32 name 'CoFreeLibrary';
procedure CoFreeAllLibraries;           external ole32 name 'CoFreeAllLibraries';
procedure CoFreeUnusedLibraries;        external ole32 name 'CoFreeUnusedLibraries';
function CoInitializeSecurity;          external ole32 name 'CoInitializeSecurity';
function CoGetCallContext;              external ole32 name 'CoGetCallContext';
function CoQueryProxyBlanket;           external ole32 name 'CoQueryProxyBlanket';
function CoSetProxyBlanket;             external ole32 name 'CoSetProxyBlanket';
function CoCopyProxy;                   external ole32 name 'CoCopyProxy';
function CoQueryClientBlanket;          external ole32 name 'CoQueryClientBlanket';
function CoImpersonateClient;           external ole32 name 'CoImpersonateClient';
function CoRevertToSelf;                external ole32 name 'CoRevertToSelf';
function CoQueryAuthenticationServices; external ole32 name 'CoQueryAuthenticationServices';
function CoSwitchCallContext;           external ole32 name 'CoSwitchCallContext';
function CoCreateInstance;              external ole32 name 'CoCreateInstance';
function CoGetInstanceFromFile;         external ole32 name 'CoGetInstanceFromFile';
function CoGetInstanceFromIStorage;     external ole32 name 'CoGetInstanceFromIStorage';
function CoCreateInstanceEx;            external ole32 name 'CoCreateInstanceEx';
function StringFromCLSID;               external ole32 name 'StringFromCLSID';
function CLSIDFromString;               external ole32 name 'CLSIDFromString';
function StringFromIID;                 external ole32 name 'StringFromIID';
function IIDFromString;                 external ole32 name 'IIDFromString';
function CoIsOle1Class;                 external ole32 name 'CoIsOle1Class';
function ProgIDFromCLSID;               external ole32 name 'ProgIDFromCLSID';
function CLSIDFromProgID;               external ole32 name 'CLSIDFromProgID';
function StringFromGUID2;               external ole32 name 'StringFromGUID2';
function CoCreateGuid;                  external ole32 name 'CoCreateGuid';
function CoFileTimeToDosDateTime;       external ole32 name 'CoFileTimeToDosDateTime';
function CoDosDateTimeToFileTime;       external ole32 name 'CoDosDateTimeToFileTime';
function CoFileTimeNow;                 external ole32 name 'CoFileTimeNow';
function CoRegisterMessageFilter;       external ole32 name 'CoRegisterMessageFilter';
function CoRegisterChannelHook;         external ole32 name 'CoRegisterChannelHook';
function CoGetTreatAsClass;             external ole32 name 'CoGetTreatAsClass';
function CoTreatAsClass;                external ole32 name 'CoTreatAsClass';
function CoTaskMemAlloc;                external ole32 name 'CoTaskMemAlloc';
function CoTaskMemRealloc;              external ole32 name 'CoTaskMemRealloc';
procedure CoTaskMemFree;                external ole32 name 'CoTaskMemFree';
function CreateDataAdviseHolder;        external ole32 name 'CreateDataAdviseHolder';
function CreateDataCache;               external ole32 name 'CreateDataCache';
function StgCreateDocfile;              external ole32 name 'StgCreateDocfile';
function StgCreateDocfileOnILockBytes;  external ole32 name 'StgCreateDocfileOnILockBytes';
function StgOpenStorage;                external ole32 name 'StgOpenStorage';
function StgOpenStorageOnILockBytes;    external ole32 name 'StgOpenStorageOnILockBytes';
function StgIsStorageFile;              external ole32 name 'StgIsStorageFile';
function StgIsStorageILockBytes;        external ole32 name 'StgIsStorageILockBytes';
function StgSetTimes;                   external ole32 name 'StgSetTimes';
function StgOpenAsyncDocfileOnIFillLockBytes; external ole32 name 'StgOpenAsyncDocfileOnIFillLockBytes';
function StgGetIFillLockBytesOnILockBytes; external ole32 name 'StgGetIFillLockBytesOnILockBytes';
function StgGetIFillLockBytesOnFile;    external ole32 name 'StgGetIFillLockBytesOnFile';
function StgOpenLayoutDocfile;          external ole32 name 'StgOpenLayoutDocfile';
function BindMoniker;                   external ole32 name 'BindMoniker';
function CoGetObject;                   external ole32 name 'CoGetObject';
function MkParseDisplayName;            external ole32 name 'MkParseDisplayName';
function MonikerRelativePathTo;         external ole32 name 'MonikerRelativePathTo';
function MonikerCommonPrefixWith;       external ole32 name 'MonikerCommonPrefixWith';
function CreateBindCtx;                 external ole32 name 'CreateBindCtx';
function CreateGenericComposite;        external ole32 name 'CreateGenericComposite';
function GetClassFile;                  external ole32 name 'GetClassFile';
function CreateFileMoniker;             external ole32 name 'CreateFileMoniker';
function CreateItemMoniker;             external ole32 name 'CreateItemMoniker';
function CreateAntiMoniker;             external ole32 name 'CreateAntiMoniker';
function CreatePointerMoniker;          external ole32 name 'CreatePointerMoniker';
function GetRunningObjectTable;         external ole32 name 'GetRunningObjectTable';
function OleBuildVersion;               external ole32 name 'OleBuildVersion';
function ReadClassStg;                  external ole32 name 'ReadClassStg';
function WriteClassStg;                 external ole32 name 'WriteClassStg';
function ReadClassStm;                  external ole32 name 'ReadClassStm';
function WriteClassStm;                 external ole32 name 'WriteClassStm';
function WriteFmtUserTypeStg;           external ole32 name 'WriteFmtUserTypeStg';
function ReadFmtUserTypeStg;            external ole32 name 'ReadFmtUserTypeStg';
function OleInitialize;                 external ole32 name 'OleInitialize';
procedure OleUninitialize;              external ole32 name 'OleUninitialize';
function OleQueryLinkFromData;          external ole32 name 'OleQueryLinkFromData';
function OleQueryCreateFromData;        external ole32 name 'OleQueryCreateFromData';
function OleCreate;                     external ole32 name 'OleCreate';
function OleCreateEx;                   external ole32 name 'OleCreateEx';
function OleCreateFromDataEx;           external ole32 name 'OleCreateFromDataEx';
function OleCreateFromData;             external ole32 name 'OleCreateFromData';
function OleCreateLinkFromData;         external ole32 name 'OleCreateLinkFromData';
function OleCreateLinkFromDataEx;       external ole32 name 'OleCreateLinkFromDataEx';
function OleCreateStaticFromData;       external ole32 name 'OleCreateStaticFromData';
function OleCreateLink;                 external ole32 name 'OleCreateLink';
function OleCreateLinkEx;               external ole32 name 'OleCreateLinkEx';
function OleCreateLinkToFile;           external ole32 name 'OleCreateLinkToFile';
function OleCreateLinkToFileEx;         external ole32 name 'OleCreateLinkToFileEx';
function OleCreateFromFile;             external ole32 name 'OleCreateFromFile';
function OleCreateFromFileEx;           external ole32 name 'OleCreateFromFileEx';
function OleLoad;                       external ole32 name 'OleLoad';
function OleSave;                       external ole32 name 'OleSave';
function OleLoadFromStream;             external ole32 name 'OleLoadFromStream';
function OleSaveToStream;               external ole32 name 'OleSaveToStream';
function OleSetContainedObject;         external ole32 name 'OleSetContainedObject';
function OleNoteObjectVisible;          external ole32 name 'OleNoteObjectVisible';
function RegisterDragDrop;              external ole32 name 'RegisterDragDrop';
function RevokeDragDrop;                external ole32 name 'RevokeDragDrop';
function DoDragDrop;                    external ole32 name 'DoDragDrop';
function OleSetClipboard;               external ole32 name 'OleSetClipboard';
function OleGetClipboard;               external ole32 name 'OleGetClipboard';
function OleFlushClipboard;             external ole32 name 'OleFlushClipboard';
function OleIsCurrentClipboard;         external ole32 name 'OleIsCurrentClipboard';
function OleCreateMenuDescriptor;       external ole32 name 'OleCreateMenuDescriptor';
function OleSetMenuDescriptor;          external ole32 name 'OleSetMenuDescriptor';
function OleDestroyMenuDescriptor;      external ole32 name 'OleDestroyMenuDescriptor';
function OleTranslateAccelerator;       external ole32 name 'OleTranslateAccelerator';
function OleDuplicateData;              external ole32 name 'OleDuplicateData';
function OleDraw;                       external ole32 name 'OleDraw';
function OleRun;                        external ole32 name 'OleRun';
function OleIsRunning;                  external ole32 name 'OleIsRunning';
function OleLockRunning;                external ole32 name 'OleLockRunning';
procedure ReleaseStgMedium;             external ole32 name 'ReleaseStgMedium';
function CreateOleAdviseHolder;         external ole32 name 'CreateOleAdviseHolder';
function OleCreateDefaultHandler;       external ole32 name 'OleCreateDefaultHandler';
function OleCreateEmbeddingHelper;      external ole32 name 'OleCreateEmbeddingHelper';
function IsAccelerator;                 external ole32 name 'IsAccelerator';
function OleGetIconOfFile;              external ole32 name 'OleGetIconOfFile';
function OleGetIconOfClass;             external ole32 name 'OleGetIconOfClass';
function OleMetafilePictFromIconAndLabel; external ole32 name 'OleMetafilePictFromIconAndLabel';
function OleRegGetUserType;             external ole32 name 'OleRegGetUserType';
function OleRegGetMiscStatus;           external ole32 name 'OleRegGetMiscStatus';
function OleRegEnumFormatEtc;           external ole32 name 'OleRegEnumFormatEtc';
function OleRegEnumVerbs;               external ole32 name 'OleRegEnumVerbs';
function OleConvertIStorageToOLESTREAM; external ole32 name 'OleConvertIStorageToOLESTREAM';
function OleConvertOLESTREAMToIStorage; external ole32 name 'OleConvertOLESTREAMToIStorage';
function OleConvertIStorageToOLESTREAMEx; external ole32 name 'OleConvertIStorageToOLESTREAMEx';
function OleConvertOLESTREAMToIStorageEx; external ole32 name 'OleConvertOLESTREAMToIStorageEx';
function GetHGlobalFromILockBytes;      external ole32 name 'GetHGlobalFromILockBytes';
function CreateILockBytesOnHGlobal;     external ole32 name 'CreateILockBytesOnHGlobal';
function GetHGlobalFromStream;          external ole32 name 'GetHGlobalFromStream';
function CreateStreamOnHGlobal;         external ole32 name 'CreateStreamOnHGlobal';
function OleDoAutoConvert;              external ole32 name 'OleDoAutoConvert';
function OleGetAutoConvert;             external ole32 name 'OleGetAutoConvert';
function OleSetAutoConvert;             external ole32 name 'OleSetAutoConvert';
function GetConvertStg;                 external ole32 name 'GetConvertStg';
function SetConvertStg;                 external ole32 name 'SetConvertStg';

{ Externals from oleaut32.dll }

function SysAllocString;                external oleaut32 name 'SysAllocString';
function SysReAllocString;              external oleaut32 name 'SysReAllocString';
function SysAllocStringLen;             external oleaut32 name 'SysAllocStringLen';
function SysReAllocStringLen;           external oleaut32 name 'SysReAllocStringLen';
procedure SysFreeString;                external oleaut32 name 'SysFreeString';
function SysStringLen;                  external oleaut32 name 'SysStringLen';
function SysStringByteLen;              external oleaut32 name 'SysStringByteLen';
function SysAllocStringByteLen;         external oleaut32 name 'SysAllocStringByteLen';
function DosDateTimeToVariantTime;      external oleaut32 name 'DosDateTimeToVariantTime';
function VariantTimeToDosDateTime;      external oleaut32 name 'VariantTimeToDosDateTime';
function SystemTimeToVariantTime;       external oleaut32 name 'SystemTimeToVariantTime';
function VariantTimeToSystemTime;       external oleaut32 name 'VariantTimeToSystemTime';
function SafeArrayAllocDescriptor;      external oleaut32 name 'SafeArrayAllocDescriptor';
function SafeArrayAllocData;            external oleaut32 name 'SafeArrayAllocData';
function SafeArrayCreate;               external oleaut32 name 'SafeArrayCreate';
function SafeArrayCreateVector;         external oleaut32 name 'SafeArrayCreateVector';
function SafeArrayCopyData;             external oleaut32 name 'SafeArrayCopyData';
function SafeArrayDestroyDescriptor;    external oleaut32 name 'SafeArrayDestroyDescriptor';
function SafeArrayDestroyData;          external oleaut32 name 'SafeArrayDestroyData';
function SafeArrayDestroy;              external oleaut32 name 'SafeArrayDestroy';
function SafeArrayRedim;                external oleaut32 name 'SafeArrayRedim';
function SafeArrayGetDim;               external oleaut32 name 'SafeArrayGetDim';
function SafeArrayGetElemsize;          external oleaut32 name 'SafeArrayGetElemsize';
function SafeArrayGetUBound;            external oleaut32 name 'SafeArrayGetUBound';
function SafeArrayGetLBound;            external oleaut32 name 'SafeArrayGetLBound';
function SafeArrayLock;                 external oleaut32 name 'SafeArrayLock';
function SafeArrayUnlock;               external oleaut32 name 'SafeArrayUnlock';
function SafeArrayAccessData;           external oleaut32 name 'SafeArrayAccessData';
function SafeArrayUnaccessData;         external oleaut32 name 'SafeArrayUnaccessData';
function SafeArrayGetElement;           external oleaut32 name 'SafeArrayGetElement';
function SafeArrayPutElement;           external oleaut32 name 'SafeArrayPutElement';
function SafeArrayCopy;                 external oleaut32 name 'SafeArrayCopy';
function SafeArrayPtrOfIndex;           external oleaut32 name 'SafeArrayPtrOfIndex';
procedure VariantInit;                  external oleaut32 name 'VariantInit';
function VariantClear;                  external oleaut32 name 'VariantClear';
function VariantCopy;                   external oleaut32 name 'VariantCopy';
function VariantCopyInd;                external oleaut32 name 'VariantCopyInd';
function VariantChangeType;             external oleaut32 name 'VariantChangeType';
function VariantChangeTypeEx;           external oleaut32 name 'VariantChangeTypeEx';
function VectorFromBstr;                external oleaut32 name 'VectorFromBstr';
function BstrFromVector;                external oleaut32 name 'BstrFromVector';
function VarUI1FromI2;                  external oleaut32 name 'VarUI1FromI2';
function VarUI1FromI4;                  external oleaut32 name 'VarUI1FromI4';
function VarUI1FromR4;                  external oleaut32 name 'VarUI1FromR4';
function VarUI1FromR8;                  external oleaut32 name 'VarUI1FromR8';
function VarUI1FromCy;                  external oleaut32 name 'VarUI1FromCy';
function VarUI1FromDate;                external oleaut32 name 'VarUI1FromDate';
function VarUI1FromStr;                 external oleaut32 name 'VarUI1FromStr';
function VarUI1FromDisp;                external oleaut32 name 'VarUI1FromDisp';
function VarUI1FromBool;                external oleaut32 name 'VarUI1FromBool';
function VarUI1FromI1;                  external oleaut32 name 'VarUI1FromI1';
function VarUI1FromUI2;                 external oleaut32 name 'VarUI1FromUI2';
function VarUI1FromUI4;                 external oleaut32 name 'VarUI1FromUI4';
function VarUI1FromDec;                 external oleaut32 name 'VarUI1FromDec';
function VarI2FromUI1;                  external oleaut32 name 'VarI2FromUI1';
function VarI2FromI4;                   external oleaut32 name 'VarI2FromI4';
function VarI2FromR4;                   external oleaut32 name 'VarI2FromR4';
function VarI2FromR8;                   external oleaut32 name 'VarI2FromR8';
function VarI2FromCy;                   external oleaut32 name 'VarI2FromCy';
function VarI2FromDate;                 external oleaut32 name 'VarI2FromDate';
function VarI2FromStr;                  external oleaut32 name 'VarI2FromStr';
function VarI2FromDisp;                 external oleaut32 name 'VarI2FromDisp';
function VarI2FromBool;                 external oleaut32 name 'VarI2FromBool';
function VarI2FromI1;                   external oleaut32 name 'VarI2FromI1';
function VarI2FromUI2;                  external oleaut32 name 'VarI2FromUI2';
function VarI2FromUI4;                  external oleaut32 name 'VarI2FromUI4';
function VarI2FromDec;                  external oleaut32 name 'VarI2FromDec';
function VarI4FromUI1;                  external oleaut32 name 'VarI4FromUI1';
function VarI4FromI2;                   external oleaut32 name 'VarI4FromI2';
function VarI4FromR4;                   external oleaut32 name 'VarI4FromR4';
function VarI4FromR8;                   external oleaut32 name 'VarI4FromR8';
function VarI4FromCy;                   external oleaut32 name 'VarI4FromCy';
function VarI4FromDate;                 external oleaut32 name 'VarI4FromDate';
function VarI4FromStr;                  external oleaut32 name 'VarI4FromStr';
function VarI4FromDisp;                 external oleaut32 name 'VarI4FromDisp';
function VarI4FromBool;                 external oleaut32 name 'VarI4FromBool';
function VarI4FromI1;                   external oleaut32 name 'VarI4FromI1';
function VarI4FromUI2;                  external oleaut32 name 'VarI4FromUI2';
function VarI4FromUI4;                  external oleaut32 name 'VarI4FromUI4';
function VarI4FromDec;                  external oleaut32 name 'VarI4FromDec';
function VarI4FromInt;                  external oleaut32 name 'VarI4FromInt';
function VarR4FromUI1;                  external oleaut32 name 'VarR4FromUI1';
function VarR4FromI2;                   external oleaut32 name 'VarR4FromI2';
function VarR4FromI4;                   external oleaut32 name 'VarR4FromI4';
function VarR4FromR8;                   external oleaut32 name 'VarR4FromR8';
function VarR4FromCy;                   external oleaut32 name 'VarR4FromCy';
function VarR4FromDate;                 external oleaut32 name 'VarR4FromDate';
function VarR4FromStr;                  external oleaut32 name 'VarR4FromStr';
function VarR4FromDisp;                 external oleaut32 name 'VarR4FromDisp';
function VarR4FromBool;                 external oleaut32 name 'VarR4FromBool';
function VarR4FromI1;                   external oleaut32 name 'VarR4FromI1';
function VarR4FromUI2;                  external oleaut32 name 'VarR4FromUI2';
function VarR4FromUI4;                  external oleaut32 name 'VarR4FromUI4';
function VarR4FromDec;                  external oleaut32 name 'VarR4FromDec';
function VarR8FromUI1;                  external oleaut32 name 'VarR8FromUI1';
function VarR8FromI2;                   external oleaut32 name 'VarR8FromI2';
function VarR8FromI4;                   external oleaut32 name 'VarR8FromI4';
function VarR8FromR4;                   external oleaut32 name 'VarR8FromR4';
function VarR8FromCy;                   external oleaut32 name 'VarR8FromCy';
function VarR8FromDate;                 external oleaut32 name 'VarR8FromDate';
function VarR8FromStr;                  external oleaut32 name 'VarR8FromStr';
function VarR8FromDisp;                 external oleaut32 name 'VarR8FromDisp';
function VarR8FromBool;                 external oleaut32 name 'VarR8FromBool';
function VarR8FromI1;                   external oleaut32 name 'VarR8FromI1';
function VarR8FromUI2;                  external oleaut32 name 'VarR8FromUI2';
function VarR8FromUI4;                  external oleaut32 name 'VarR8FromUI4';
function VarR8FromDec;                  external oleaut32 name 'VarR8FromDec';
function VarDateFromUI1;                external oleaut32 name 'VarDateFromUI1';
function VarDateFromI2;                 external oleaut32 name 'VarDateFromI2';
function VarDateFromI4;                 external oleaut32 name 'VarDateFromI4';
function VarDateFromR4;                 external oleaut32 name 'VarDateFromR4';
function VarDateFromR8;                 external oleaut32 name 'VarDateFromR8';
function VarDateFromCy;                 external oleaut32 name 'VarDateFromCy';
function VarDateFromStr;                external oleaut32 name 'VarDateFromStr';
function VarDateFromDisp;               external oleaut32 name 'VarDateFromDisp';
function VarDateFromBool;               external oleaut32 name 'VarDateFromBool';
function VarDateFromI1;                 external oleaut32 name 'VarDateFromI1';
function VarDateFromUI2;                external oleaut32 name 'VarDateFromUI2';
function VarDateFromUI4;                external oleaut32 name 'VarDateFromUI4';
function VarDateFromDec;                external oleaut32 name 'VarDateFromDec';
function VarCyFromUI1;                  external oleaut32 name 'VarCyFromUI1';
function VarCyFromI2;                   external oleaut32 name 'VarCyFromI2';
function VarCyFromI4;                   external oleaut32 name 'VarCyFromI4';
function VarCyFromR4;                   external oleaut32 name 'VarCyFromR4';
function VarCyFromR8;                   external oleaut32 name 'VarCyFromR8';
function VarCyFromDate;                 external oleaut32 name 'VarCyFromDate';
function VarCyFromStr;                  external oleaut32 name 'VarCyFromStr';
function VarCyFromDisp;                 external oleaut32 name 'VarCyFromDisp';
function VarCyFromBool;                 external oleaut32 name 'VarCyFromBool';
function VarCyFromI1;                   external oleaut32 name 'VarCyFromI1';
function VarCyFromUI2;                  external oleaut32 name 'VarCyFromUI2';
function VarCyFromUI4;                  external oleaut32 name 'VarCyFromUI4';
function VarCyFromDec;                  external oleaut32 name 'VarCyFromDec';
function VarBStrFromUI1;                external oleaut32 name 'VarBStrFromUI1';
function VarBStrFromI2;                 external oleaut32 name 'VarBStrFromI2';
function VarBStrFromI4;                 external oleaut32 name 'VarBStrFromI4';
function VarBStrFromR4;                 external oleaut32 name 'VarBStrFromR4';
function VarBStrFromR8;                 external oleaut32 name 'VarBStrFromR8';
function VarBStrFromCy;                 external oleaut32 name 'VarBStrFromCy';
function VarBStrFromDate;               external oleaut32 name 'VarBStrFromDate';
function VarBStrFromDisp;               external oleaut32 name 'VarBStrFromDisp';
function VarBStrFromBool;               external oleaut32 name 'VarBStrFromBool';
function VarBstrFromI1;                 external oleaut32 name 'VarBstrFromI1';
function VarBstrFromUI2;                external oleaut32 name 'VarBstrFromUI2';
function VarBstrFromUI4;                external oleaut32 name 'VarBstrFromUI4';
function VarBstrFromDec;                external oleaut32 name 'VarBstrFromDec';
function VarBoolFromUI1;                external oleaut32 name 'VarBoolFromUI1';
function VarBoolFromI2;                 external oleaut32 name 'VarBoolFromI2';
function VarBoolFromI4;                 external oleaut32 name 'VarBoolFromI4';
function VarBoolFromR4;                 external oleaut32 name 'VarBoolFromR4';
function VarBoolFromR8;                 external oleaut32 name 'VarBoolFromR8';
function VarBoolFromDate;               external oleaut32 name 'VarBoolFromDate';
function VarBoolFromCy;                 external oleaut32 name 'VarBoolFromCy';
function VarBoolFromStr;                external oleaut32 name 'VarBoolFromStr';
function VarBoolFromDisp;               external oleaut32 name 'VarBoolFromDisp';
function VarBoolFromI1;                 external oleaut32 name 'VarBoolFromI1';
function VarBoolFromUI2;                external oleaut32 name 'VarBoolFromUI2';
function VarBoolFromUI4;                external oleaut32 name 'VarBoolFromUI4';
function VarBoolFromDec;                external oleaut32 name 'VarBoolFromDec';
function LHashValOfNameSys;             external oleaut32 name 'LHashValOfNameSys';
function LHashValOfNameSysA;            external oleaut32 name 'LHashValOfNameSysA';
function LoadTypeLib;                   external oleaut32 name 'LoadTypeLib';
function LoadTypeLibEx;                 external oleaut32 name 'LoadTypeLibEx';
function LoadRegTypeLib;                external oleaut32 name 'LoadRegTypeLib';
function QueryPathOfRegTypeLib;         external oleaut32 name 'QueryPathOfRegTypeLib';
function RegisterTypeLib;               external oleaut32 name 'RegisterTypeLib';
function UnRegisterTypeLib;             external oleaut32 name 'UnRegisterTypeLib';
function CreateTypeLib;                 external oleaut32 name 'CreateTypeLib';
function CreateTypeLib2;                external oleaut32 name 'CreateTypeLib2';
function DispGetParam;                  external oleaut32 name 'DispGetParam';
function DispGetIDsOfNames;             external oleaut32 name 'DispGetIDsOfNames';
function DispInvoke;                    external oleaut32 name 'DispInvoke';
function CreateDispTypeInfo;            external oleaut32 name 'CreateDispTypeInfo';
function CreateStdDispatch;             external oleaut32 name 'CreateStdDispatch';
function DispCallFunc;                  external oleaut32 name 'DispCallFunc';
function RegisterActiveObject;          external oleaut32 name 'RegisterActiveObject';
function RevokeActiveObject;            external oleaut32 name 'RevokeActiveObject';
function GetActiveObject;               external oleaut32 name 'GetActiveObject';
function SetErrorInfo;                  external oleaut32 name 'SetErrorInfo';
function GetErrorInfo;                  external oleaut32 name 'GetErrorInfo';
function CreateErrorInfo;               external oleaut32 name 'CreateErrorInfo';
function OaBuildVersion;                external oleaut32 name 'OaBuildVersion';
procedure ClearCustData;                external oleaut32 name 'ClearCustData';

{ Externals from olepro32.dll }

function OleCreatePropertyFrame;        external olepro32 name 'OleCreatePropertyFrame';
function OleCreatePropertyFrameIndirect; external olepro32 name 'OleCreatePropertyFrameIndirect';
function OleTranslateColor;             external olepro32 name 'OleTranslateColor';
function OleCreateFontIndirect;         external olepro32 name 'OleCreateFontIndirect';
function OleCreatePictureIndirect;      external olepro32 name 'OleCreatePictureIndirect';
function OleLoadPicture;                external olepro32 name 'OleLoadPicture';
function OleLoadPicturePath;            external olepro32 name 'OleLoadPicturePath';
function OleLoadPictureFile;            external olepro32 name 'OleLoadPictureFile';
function OleSavePictureFile;            external olepro32 name 'OleSavePictureFile';
function OleIconToCursor;               external olepro32 name 'OleIconToCursor';

{ Helper functions }

function Succeeded(Res: HResult): Boolean;
begin
  Result := Res and $80000000 = 0;
end;

function Failed(Res: HResult): Boolean;
begin
  Result := Res and $80000000 <> 0;
end;

function ResultCode(Res: HResult): Integer;
begin
  Result := Res and $0000FFFF;
end;

function ResultFacility(Res: HResult): Integer;
begin
  Result := (Res shr 16) and $00001FFF;
end;

function ResultSeverity(Res: HResult): Integer;
begin
  Result := Res shr 31;
end;

function MakeResult(Severity, Facility, Code: Integer): HResult;
begin
  Result := (Severity shl 31) or (Facility shl 16) or Code;
end;

function LHashValOfName(lcid: TLCID; szName: POleStr): Longint;
begin
  Result := LHashValOfNameSys(SYS_WIN32, lcid, szName);
end;

function WHashValOfLHashVal(lhashval: Longint): Word;
begin
  Result := lhashval and $0000FFFF;
end;

function IsHashValCompatible(lhashval1, lhashval2: Longint): Boolean;
begin
  Result := lhashval1 and $00FF0000 = lhashval2 and $00FF0000;
end;

function PROPSETHDR_OSVER_KIND(dwOSVer: DWORD): Word;
begin
  Result := HiWord(dwOSVer);
end;

function PROPSETHDR_OSVER_MAJOR(dwOSVer: DWORD): Byte;
begin
  Result := LoByte(dwOSVer);
end;

function PROPSETHDR_OSVER_MINOR(dwOSVer: DWORD): Byte;
begin
  Result := HiByte(LoWord(dwOSVer));
end;


end.

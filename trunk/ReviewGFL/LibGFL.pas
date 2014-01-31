//******************************************************************************
//  Graphics File Library
//  For Windows & Unix
//
//  GFL library Copyright (c) 1991-2011 Pierre-e Gougelet
//  All rights reserved
//
//  Commercial use is not authorized without agreement
//
//  URL:     http://www.xnview.com
//  E-Mail : webmaster@xnview.com
//
//  Version 3.40
//
//------------------------------------------------------------------------------
//  Translation of libgfl.h as import unit for Borland Delphi by
//
//  Ingo Neumann
//  E-Mail : ingo@upstart.de
//
//  Tested with Delphi 5 under Windows 2000, ServicePack 2.
//  Should also work with Delphi 2.x and above under Win9x, WinME, WinNT4
//
//------------------------------------------------------------------------------
//
// ****** !! PGFL_COLOR !! *****************************************************
//
//  It's very important do aloc memory for var PGFL_COLOR parameters
//  like NEW(pColor) and finally Dispose(pColor)
//
//  Bei vielen Funktionen die ein 'var PGFL_COLOR' als Parameter enthalten,
//  ist es von Nöten diese Variable z.B. mit New zu initialisieren!
//  Da sonst einige Funktionen nicht das gewünschte Ergebnis zurück liefern.
//  Danach mit Dispose den Speicher wieder freigeben.
//
//  Don't use followings on var PGFL_COLOR parameters:
//  var Color : TGFL_COLOR:
//      pColor: PGFL_COLOR;
//  pColor := @Color  > pColor^.red := 46 > many functions get mistaken results
//
//   You have problem with other Pointers? Test first aloc memory for it !
//
//   * you found bug ? (fixit and) contact XnView Forum please.
//   * you create newer or fixed version ? please... contact XnView Forum.
//
//   Thanks to Ingo Neumann for first translation to Delphi
//   GPo 2008
// *****************************************************************************
//
//  Delphi gflLib Version:
//  Version 2.82.01  ** you create newer or fixed version, change it please **
//
// History:
// DD/MM/YYYY
//
// 04/03/2008 by Gisbert Pospischil (GPo)
//            * added:
//                UNICODE compiler switches UNICODE_SUPPORT (default off) see below.
//                gflBitmapGetIsTrueColors  (local)
//                gflBitmapGetIs24Bits      (local)
//            * change:
//                const to var bitmap in Unicode load functions
//                gflAutoCrop and gflAutoCrop2: PGFL_COLOR to TGFL_COLOR
//                Unicode load and save functions:
//                  PFileInfo to TFileInfo and PParameters to TParameters
//            * fixed: Unicode functions, added call conversion 'stdcall'
//
// 02/03/2008 by Gisbert Pospischil, change and update to v2.82
//            * change: all exif and iptc records to packed records
//            * added: declarations and functions from version 2.82
//            * fixed bugs was reported on XnView Forum.
//            * not all updates has it tested (Delphi 10 on WinXP)
//            * Thanks to Pierre-e Gougelet for this greate work!
//
// 18/06/2004: by Pierre-e Gougelet
//             * fixed gflRotate
//
// 27/05/2004: by Pierre-e Gougelet
//             * added exif/iptc functions
//
// 30/09/2003: by Pierre-e Gougelet
//
// 09/03/2002: by Ingo Neumann
//             * changed all (var dst : PGFL_BITMAP) into (dst : PPGFL_BITMAP)
//                           to supress compiler errors if using NIL (NULL)
//                           for dst in all LibGflE functions
//                           but I am not sure if that is always correct.
//             * correct some other errors for Version 1.50, marked with  '// IN!'
//
// 30/11/2001: by Germain Garand
//             * Corrected types which were inverted (swapped LongWord/LongInt)
//
// 29/11/2001: by Germain Garand (germain@ebooksfrance.com)
//             + Added Kylix support (needed rename file to LibGfl.pas for case sensitivity)
//             * Corrected typo SaveBitmapFormHandle -> SaveBitmapFromHandle
//
// 10/07/2001: by Ingo Neumann (ingo@upstart.de)
//             + initial creation
//******************************************************************************

{$I Defines.inc}

unit LibGfl;

interface

uses Windows, MixUtils;

{$ALIGN ON} // Aligned record fields

{$ifdef bFreePascal}
 {$PACKRECORDS C}
{$endif bFreePascal}

{$DEFINE MSWINDOWS}
{$DEFINE UNICODE_SUPPORT}  //** remove it: you don't use Unicode or DLL doesn’t support it **

{-$Define bStaticLink}


const
  GflDLL = 'libgfl340.dll';   // DLL filename
  GfleDLL = 'libgfle340.dll';  // DLL filename
  GFL_VERSION = '340';

  GFL_FALSE = 0;
  GFL_TRUE  = 1;

type
  GFL_INT8    = ShortInt;
  GFL_UINT8   = Byte;
  PGFL_UINT8  = ^GFL_UINT8; // IN!
  GFL_INT16   = SmallInt;
  GFL_UINT16  = Word;
  PGFL_UINT16 = ^GFL_UINT16; //IS
  GFL_INT32   = LongInt;
  GFL_UINT32  = LongWord;
  PGFL_UINT32 = ^GFL_UINT32;
  GFL_BOOL    = Byte;

  PGFL_Point = ^TGFL_Point;
  TGFL_POINT = record
    x,y: GFL_INT32;
  end;

  PGFL_RECT = ^TGFL_RECT;
  TGFL_Rect = record
    x,y,
    w,h: GFL_INT32;
  end;

// ERROR
type
  GFL_ERROR = GFL_INT16;
const
  GFL_NO_ERROR          = 0;
  GFL_ERROR_FILE_OPEN   = 1;
  GFL_ERROR_FILE_READ   = 2;
  GFL_ERROR_FILE_CREATE = 3;
  GFL_ERROR_FILE_WRITE  = 4;
  GFL_ERROR_NO_MEMORY   = 5;
  GFL_ERROR_UNKNOWN_FORMAT = 6;
  GFL_ERROR_BAD_BITMAP     = 7;
  GFL_ERROR_BAD_FORMAT_INDEX = 10;
  GFL_ERROR_BAD_PARAMETERS   = 50;
  GFL_UNKNOWN_ERROR          = 255;

// ORIGIN type
type
  GFL_ORIGIN = GFL_UINT16;
const
  GFL_LEFT   = $00;
  GFL_TOP    = $00;
  GFL_RIGHT  = $01;
  GFL_BOTTOM = $10;
  GFL_TOP_LEFT     = GFL_TOP or GFL_LEFT;
  GFL_BOTTOM_LEFT  = GFL_BOTTOM or GFL_LEFT;
  GFL_TOP_RIGHT    = GFL_TOP or GFL_RIGHT;
  GFL_BOTTOM_RIGHT = GFL_BOTTOM or GFL_RIGHT;

// COMPRESSION type
type
  GFL_COMPRESSION = GFL_UINT16;
const
  GFL_NO_COMPRESSION = 0;
  GFL_RLE            = 1;
  GFL_LZW            = 2;
  GFL_JPEG           = 3;
  GFL_ZIP            = 4;
  GFL_SGI_RLE        = 5;
  GFL_CCITT_RLE      = 6;
  GFL_CCITT_FAX3     = 7;
  GFL_CCITT_FAX3_2D  = 8;
  GFL_CCITT_FAX4     = 9;
  GFL_WAVELET        = 10;
  GFL_LZW_PREDICTOR  = 11;
  GFL_UNKNOWN_COMPRESSION = 255;


// BITMAP type
type
  GFL_BITMAP_TYPE = GFL_UINT16;
const
  GFL_BINARY = $0001;
  GFL_GREY   = $0002;
  GFL_COLORS = $0004;
  GFL_RGB    = $0010;
  GFL_RGBA   = $0020;
  GFL_BGR    = $0040;
  GFL_ABGR   = $0080;
  GFL_BGRA   = $0100;
  GFL_ARGB   = $0200;
  GFL_CMYK   = $0400;
  // gflBitmapGetIsTrueColors
  GFL_TRUECOLORS = GFL_RGB or GFL_RGBA or GFL_BGR or GFL_ABGR or GFL_BGRA or GFL_ARGB or GFL_CMYK;
  // gflBitmapGetIs24Bits
  GFL_IS24BITS = GFL_BGR or GFL_RGB;
{*
 * ~OBSOLETE
 *}
 //* Only for gflBitmapTypeIsSupportedByIndex or gflBitmapTypeIsSupportedByName */
  GFL_24BITS = $1000;
  GFL_32BITS = $2000;
  GFL_48BITS = $4000;
  GFL_64BITS = $8000;


// Color Palette
type
  PGFL_COLORMAP = ^TGFL_COLORMAP;
  TGFL_COLORMAP = record
    Red: array[0..255] of GFL_UINT8;
    Green: array[0..255] of GFL_UINT8;
    Blue: array[0..255] of GFL_UINT8;
    Alpha: array[0..255] of GFL_UINT8;
  end;

// Color
type
  PGFL_COLOR = ^TGFL_COLOR;
  TGFL_COLOR = record
    Red: GFL_UINT16;
    Green: GFL_UINT16;
    Blue: GFL_UINT16;
    Alpha: GFL_UINT16;
  end;

// BITMAP
type
  PGFL_BITMAP = ^TGFL_BITMAP;
  PPGFL_BITMAP = ^PGFL_BITMAP;
  TGFL_BITMAP = record
    BType: GFL_BITMAP_TYPE;
    Origin: GFL_ORIGIN;
    Width: GFL_INT32;
    Height: GFL_INT32;
    BytesPerLine: GFL_UINT32;
    LinePadding: GFL_INT16;
    BitsPerComponent: GFL_UINT16;   //* 1, 8, 10, 12, 16 */
    ComponentsPerPixel: GFL_UINT16; //* 1, 3, 4  */
    BytesPerPixel: GFL_UINT16;      //* Only valid for 8 or more bits */
    Xdpi: GFL_UINT16;
    Ydpi: GFL_UINT16;
    TransparentIndex: GFL_INT16;    // -1 if not used
    Reserved: GFL_INT16; 
    ColorUsed: GFL_INT32;
    ColorMap: PGFL_COLORMAP;
    Data: PGFL_UINT8;
    Comment: PChar;
    MetaData: Pointer;
    XOffset:  GFL_INT32;
    YOffset: GFL_INT32;
	ExtrasInfo: Pointer;
    Name: PChar;
  end;

// Channels Order
type
  GFL_CORDER = GFL_UINT16;
const
  GFL_CORDER_INTERLEAVED = 0;
  GFL_CORDER_SEQUENTIAL  = 1;
  GFL_CORDER_SEPARATE    = 2;

// Channels Type
type
  GFL_CTYPE = GFL_UINT16;
const
  GFL_CTYPE_GREYSCALE = 0;
  GFL_CTYPE_RGB  = 1;
  GFL_CTYPE_BGR  = 2;
  GFL_CTYPE_RGBA = 3;
  GFL_CTYPE_ABGR = 4;
  GFL_CTYPE_CMY  = 5;
  GFL_CTYPE_CMYK = 6;

// Lut Type (For DPX/Cineon)
type
  GFL_LUT_TYPE = GFL_UINT16;
const
  GFL_LUT_TO8BITS  = 1;
  GFL_LUT_TO10BITS = 2;
  GFL_LUT_TO12BITS = 3;
  GFL_LUT_TO16BITS = 4;

// Callbacks
type
  GFL_HANDLE = Pointer;

  GFL_ALLOC_CALLBACK = procedure(size: GFL_UINT32; param: Pointer); stdcall;
  GFL_REALLOC_CALLBACK = procedure(ptr: Pointer; newsize: GFL_UINT32; param: Pointer); stdcall;
  GFL_FREE_CALLBACK = procedure(buffer: Pointer; param: Pointer); stdcall;

  GFL_READ_CALLBACK = function(handle: GFL_HANDLE; var buffer: Pointer; size: GFL_UINT32): GFL_UINT32; stdcall; 
  GFL_TELL_CALLBACK = function(handle: GFL_HANDLE): GFL_UINT32; stdcall;
  GFL_SEEK_CALLBACK = function(handle: GFL_HANDLE; offset: GFL_INT32; origin: GFL_INT32): GFL_UINT32; stdcall;
  GFL_WRITE_CALLBACK = function(handle: GFL_HANDLE; buffer: Pointer; size: GFL_UINT32): GFL_UINT32; stdcall;

  GFL_ALLOCATEBITMAP_CALLBACK = function(width: GFL_INT32; height: GFL_INT32; number_component: GFL_INT32; bits_per_component: GFL_INT32; padding: GFL_INT32; bytes_per_line: GFL_INT32; user_params: Pointer): GFL_UINT32; stdcall;
  GFL_PROGRESS_CALLBACK = procedure(percent: GFL_INT32; user_params: Pointer); stdcall;
  GFL_WANTCANCEL_CALLBACK = function(user_params: Pointer): GFL_BOOL; stdcall;

  GFL_VIRTUAL_SAVE_CALLBACK = function(user_params: Pointer): GFL_ERROR; stdcall;

type
  TGFL_LoadCallbacks = record
    Read: GFL_READ_CALLBACK;
    Tell: GFL_TELL_CALLBACK;
    Seek: GFL_SEEK_CALLBACK;

    AllocateBitmap: GFL_ALLOCATEBITMAP_CALLBACK; 
    AllocateBitmapParams : Pointer; 
    Progress: GFL_PROGRESS_CALLBACK;
    ProgressParams : Pointer; 
    WantCancel: GFL_WANTCANCEL_CALLBACK; 
    WantCancelParams : Pointer; 
  end;

type
  TGFL_SaveCallbacks = record
    Write: GFL_WRITE_CALLBACK;
    Tell: GFL_TELL_CALLBACK;
    Seek: GFL_SEEK_CALLBACK;
    GetLine: GFL_VIRTUAL_SAVE_CALLBACK;
    GetLineParams : Pointer; 
  end;

// LOAD_PARAMS Flags
const
  GFL_LOAD_SKIP_ALPHA        = $0001;
  GFL_LOAD_IGNORE_READ_ERROR = $0002;
  GFL_LOAD_BY_EXTENSION_ONLY = $0004;
  GFL_LOAD_READ_ALL_COMMENT  = $0008;
  GFL_LOAD_FORCE_COLOR_MODEL = $0010;
  GFL_LOAD_PREVIEW_NO_CANVAS_RESIZE = $0020;
  GFL_LOAD_BINARY_AS_GREY      = $0040;
  GFL_LOAD_ORIGINAL_COLORMODEL = $0080;
  GFL_LOAD_ONLY_FIRST_FRAME    = $0100;
  GFL_LOAD_ORIGINAL_DEPTH      = $0200;
  GFL_LOAD_METADATA            = $0400;
  GFL_LOAD_COMMENT             = $0800;
  GFL_LOAD_HIGH_QUALITY_THUMBNAIL = $1000;
  GFL_LOAD_EMBEDDED_THUMBNAIL     = $2000;
  GFL_LOAD_ORIENTED_THUMBNAIL     = $4000;
  GFL_LOAD_ORIGINAL_EMBEDDED_THUMBNAIL = $00008000;
  GFL_LOAD_ORIENTED                    = $00008000;

// LOAD_PARAMS
type
  PGFL_LOAD_PARAMS = ^TGFL_LOAD_PARAMS;
  TGFL_LOAD_PARAMS = record
    Flags: GFL_UINT32;
    FormatIndex: GFL_INT32;      // -1 for automatic recognition
    ImageWanted: GFL_INT32;      // for multi-page or animated file
    Origin: GFL_ORIGIN;          // default: GFL_TOP_LEFT
    ColorModel: GFL_BITMAP_TYPE; // Only for 24/32 bits picture, GFL_RGB/GFL_RGBA (default), GFL_BGR/GFL_ABGR, GFL_BGRA, GFL_ARGB */
    LinePadding: GFL_UINT32;     // 1, 2, 4, ...
    DefaultAlpha: GFL_UINT8;     // Used if alpha doesn't exist in original file & ColorModel=RGBA/BGRA/ABGR/ARGB */

    PsdNoAlphaForNonLayer: GFL_UINT8;
    PngComposeWithAlpha: GFL_UINT8;
    WMFHighResolution: GFL_UINT8;

         // for RAW/YUV
    Width: GFL_INT32;
    Height: GFL_INT32;
    Offset: GFL_UINT32;

         // for RAW
    ChannelOrder: GFL_CORDER;
    ChannelType: GFL_CTYPE;

         // for PCD
    PcdBase: GFL_UINT16; // PCD -> 2:768x576, 1:384x288, 0:192x144

       // For Eps
    EpsDpi: GFL_UINT16;
    EpsWidth: GFL_INT32;
    EpsHeight: GFL_INT32;

       // For Dpx, Cineon
    LutType: GFL_LUT_TYPE; // GFL_LUT_TO8BITS, GFL_LUT_TO10BITS, GFL_LUT_TO12BITS, GFL_LUT_TO16BITS */
    CompressRatio : GFL_UINT16; 
    MaxFileSize : GFL_UINT32; 
    LutData: PGFL_UINT16; // RRRR.../GGGG..../BBBB.....
    LutFilename: PChar;

       // Camera RAW only
    CameraRawUseAutomaticBalance: GFL_UINT8; 
    CameraRawUseCameraBalance: GFL_UINT8; 
    Reserved4: GFL_UINT16; 
    CameraRawGamma: Single; 
    CameraRawBrightness: Single; 
    CameraRawRedScaling: Single; 
    CameraRawBlueScaling: Single; 
    CameraRawFilterDomain: Single; 
    CameraRawFilterRange: Single; 
         
        // Own callback
    Callbacks: TGFL_LoadCallbacks;
    
    UserParams: Pointer;
  end;


// SAVE_PARAMS
// support of GFL_BITMAP ChannelTypes: GFL_RGB + GFL_RGBA + GFL_BGR
// support of GFL_BITMAP OriginTypes: GFL_TOP_LEFT + GFL_BOTTOM_LEFT

const
  GFL_SAVE_REPLACE_EXTENSION = $0001;
  GFL_SAVE_WANT_FILENAME = $0002;
  GFL_SAVE_ANYWAY        = $0004;
  GFL_SAVE_ICC_PROFILE   = $0008;	//* Currently only available for jpeg */

  GFL_BYTE_ORDER_DEFAULT = 0;
  GFL_BYTE_ORDER_LSBF    = 1;
  GFL_BYTE_ORDER_MSBF    = 2;

type
  PGFL_SAVE_PARAMS = ^TGFL_SAVE_PARAMS;
  TGFL_SAVE_PARAMS = record
    Flags: GFL_UINT32;
    FormatIndex: GFL_INT32;

    Compression: GFL_COMPRESSION;
    Quality: GFL_INT16;             // Jpeg + Wic + Fpx
    CompressionLevel: GFL_INT16;    // Png
    Interlaced: GFL_BOOL;           // Gif
    Progressive: GFL_BOOL;          // Jpeg
    OptimizeHuffmanTable: GFL_BOOL; // Jpeg
    InAscii: GFL_BOOL;              // PPM

       // For Dpx, Cineon
    LutType: GFL_LUT_TYPE; //* GFL_LUT_TO8BITS, GFL_LUT_TO10BITS, GFL_LUT_TO12BITS, GFL_LUT_TO16BITS

       // GFL_BYTE_ORDER 0..2
	  DpxByteOrder : GFL_UINT8;

	  Reserved3 : GFL_UINT8;
    LutData: PGFL_UINT16; //* RRRR.../GGGG..../BBBB.....
    LutFilename: PChar;

        // For RAW/YUV
    Offset: GFL_UINT32;
    ChannelOrder: GFL_CORDER;
    ChannelType: GFL_CTYPE;

       // Own callback
    Callbacks: TGFL_SaveCallbacks;

    UserParams: Pointer;
  end;

// Color model
type
  GFL_COLORMODEL = GFL_UINT16;
const
  GFL_CM_RGB    = 0;
  GFL_CM_GREY   = 1;
  GFL_CM_CMY    = 2;
  GFL_CM_CMYK   = 3;
  GFL_CM_YCBCR  = 4;
  GFL_CM_YUV16  = 5;
  GFL_CM_LAB    = 6;
  GFL_CM_LOGLUV = 7;
  GFL_CM_LOGL   = 8;

// FILE_INFORMATION
type
  PGFL_FILE_INFORMATION = ^TGFL_FILE_INFORMATION;
  TGFL_FILE_INFORMATION = record
    BType: GFL_BITMAP_TYPE; //* Not used */
    Origin: GFL_ORIGIN;
    Width: GFL_INT32;
    Height: GFL_INT32;
    FormatIndex: GFL_INT32;
    FormatName: array[0..7] of char;
    Description: array[0..63] of char;
    Xdpi: GFL_UINT16;
    Ydpi: GFL_UINT16;
    BitsPerComponent: GFL_UINT16;
    ComponentsPerPixel: GFL_UINT16;
    NumberOfImages: GFL_INT32;
    FileSize: GFL_UINT32;
    ColorModel: GFL_COLORMODEL;
    Compression: GFL_COMPRESSION;
    CompressionDescription: array[0..63] of char;
    XOffset: GFL_INT32;
    YOffset: GFL_INT32;
    ExtraInfos :Pointer;
  end;

const
  GFL_READ  = $01;
  GFL_WRITE = $02;

// FORMAT_INFORMATION
type
  PGFL_FORMAT_INFORMATION = ^TGFL_FORMAT_INFORMATION;
  TGFL_FORMAT_INFORMATION = record
    Index: GFL_INT32;
    Name: array[0..7] of char;
    Description: array[0..63] of char;
    Status: GFL_UINT32;
    NumberOfExtension: GFL_UINT32;
    Extension: array[0..15, 0..7] of char;
  end;

//---------------------------------------------------------------------------------------------------
// functions in LibGflxxx.dll
//---------------------------------------------------------------------------------------------------

{$ifdef bStaticLink}

// Common Memory Handling
function gflMemoryAlloc(size: GFL_UINT32): Pointer; stdcall;
function gflMemoryRealloc(Ptr: Pointer; size: GFL_UINT32): Pointer; stdcall;
procedure gflMemoryFree(Ptr: Pointer); stdcall;

// Version Info
function gflGetVersion: PChar; stdcall;
function gflGetVersionOfLibformat: PChar; stdcall;
function gflGetErrorString(error: GFL_ERROR): PChar; stdcall;

// Initialization
function gflLibraryInit: GFL_ERROR; stdcall;
function gflLibraryInitEx(alloc_callback: GFL_ALLOC_CALLBACK;
  realloc_callback: GFL_REALLOC_CALLBACK;
  free_callback: GFL_FREE_CALLBACK;
  user_parms: Pointer): GFL_ERROR; stdcall;
procedure gflLibraryExit; stdcall;
procedure gflEnableLZW(value: GFL_BOOL); stdcall;
procedure gflSetPluginsPathname(const pathname :PAnsiChar); stdcall;
{$IFDEF UNICODE_SUPPORT}
procedure gflSetPluginsPathnameW(const pathname :PWideChar); stdcall;
{$ENDIF UNICODE_SUPPORT}

{$else}

var
  gflLibraryInit :function: GFL_ERROR; stdcall;
  gflLibraryExit :procedure; stdcall;
  gflEnableLZW :procedure(value: GFL_BOOL); stdcall;
  gflSetPluginsPathnameW :procedure(const S: PWideChar); stdcall;

{$endif bStaticLink}


// Info of supported save params
type
  GFL_SAVE_PARAMS_TYPE= GFL_UINT32;
const
  GFL_SAVE_PARAMS_QUALITY           = 0;  //* 0<=quality<=100 */
  GFL_SAVE_PARAMS_COMPRESSION_LEVEL = 1;  //* 0<=level<=9     */
  GFL_SAVE_PARAMS_INTERLACED        = 2;
  GFL_SAVE_PARAMS_PROGRESSIVE       = 3;
  GFL_SAVE_PARAMS_OPTIMIZE_HUFFMAN  = 4;
  GFL_SAVE_PARAMS_IN_ASCII          = 5;
  GFL_SAVE_PARAMS_LUT               = 6;

{$ifdef bStaticLink}
function gflSaveParamsIsSupportedByIndex(index: GFL_INT32; params_type: GFL_SAVE_PARAMS_TYPE): GFL_Bool; stdcall;
function gflSaveParamsIsSupportedByName(const name: PChar; params_type: GFL_SAVE_PARAMS_TYPE): GFL_Bool; stdcall;
function gflCompressionIsSupportedByIndex(index: GFL_INT32; comp: GFL_COMPRESSION): GFL_Bool; stdcall;
function gflCompressionIsSupportedByName(const name: PChar; comp: GFL_COMPRESSION): GFL_Bool; stdcall;
function gflBitmapIsSupportedByIndex(index: GFL_INT32; const bitmap: PGFL_BITMAP): GFL_Bool; stdcall;
function gflBitmapIsSupportedByName(const name: PChar; const bitmap: PGFL_BITMAP): GFL_Bool; stdcall;
function gflBitmapTypeIsSupportedByIndex(index:  GFL_INT32; btype: GFL_BITMAP_TYPE; bits_per_component: GFL_UINT16): GFL_Bool; stdcall;
function gflBitmapTypeIsSupportedByName(const name: PChar; btype: GFL_BITMAP_TYPE; bits_per_component: GFL_UINT16): GFL_Bool; stdcall;

// Infos of supported Formats
function gflGetNumberOfFormat: GFL_INT32; stdcall;
function gflGetFormatIndexByName(const name: PChar): GFL_INT32; stdcall;
function gflGetFormatNameByIndex(index: GFL_INT32): PChar; stdcall;
function gflFormatIsSupported(const name: PChar): GFL_BOOL; stdcall;
function gflFormatIsWritableByIndex(index: GFL_INT32): GFL_BOOL; stdcall;
function gflFormatIsWritableByName(const name: PChar): GFL_BOOL; stdcall;
function gflFormatIsReadableByIndex(index: GFL_INT32): GFL_BOOL; stdcall;
function gflFormatIsReadableByName(const name: PChar): GFL_BOOL; stdcall;
function gflGetDefaultFormatSuffixByIndex(index: GFL_INT32): PChar; stdcall;
function gflGetDefaultFormatSuffixByName(const name: PChar): PChar; stdcall;
function gflGetFormatDescriptionByIndex(index: GFL_INT32): PChar; stdcall;
function gflGetFormatDescriptionByName(const name: PChar): PChar; stdcall;
function gflGetFormatInformationByName(const name: PChar;
  var info: TGFL_FORMAT_INFORMATION): GFL_ERROR; stdcall;
function gflGetFormatInformationByIndex(index: GFL_INT32;
  var info: TGFL_FORMAT_INFORMATION): GFL_ERROR; stdcall;

function gflGetLabelForColorModel(color_model: GFL_COLORMODEL): PChar; stdcall;

function gflGetFileInformation(const filename: PAnsiChar; index: GFL_INT32;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
{$IFDEF UNICODE_SUPPORT}
function gflGetFileInformationW(const filename: PWideChar; index: GFL_INT32;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
{$ENDIF UNICODE_SUPPORT}

//function gflGetFileInformationEx(const filename: PChar; index: GFL_INT32;
//  var info: TGFL_FILE_INFORMATION; load_infos GFL_UINT32): GFL_ERROR; stdcall;

function gflGetFileInformationFromHandle(handle : GFL_HANDLE;
  index: GFL_INT32; const callbacks: TGFL_LoadCallbacks;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflGetFileInformationFromMemory(const data: PGFL_UINT8;
  data_length : GFL_UINT32; index: GFL_INT32;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

procedure gflFreeFileInformation(var info: TGFL_FILE_INFORMATION); stdcall;


// Loading and Saving
procedure gflGetDefaultLoadParams(var params: TGFL_LOAD_PARAMS); stdcall;
procedure gflGetDefaultSaveParams(var params: TGFL_SAVE_PARAMS); stdcall;

procedure gflGetDefaultThumbnailParams(var params: TGFL_LOAD_PARAMS); stdcall;
procedure gflGetDefaultPreviewParams(var params: TGFL_LOAD_PARAMS); stdcall;

function gflLoadBitmap(const filename: PAnsiChar;
  var bitmap: PGFL_BITMAP; var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
{$IFDEF UNICODE_SUPPORT}
function gflLoadBitmapW(const filename: PWideChar;
  var Bitmap: PGFL_BITMAP; var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
{$ENDIF UNICODE_SUPPORT}

function gflLoadBitmapFromHandle(handle: GFL_HANDLE;
  var bitmap: PGFL_BITMAP; var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflLoadBitmapFromMemory(const data: PGFL_UINT8;
  data_length : GFL_UINT32; var bitmap: PGFL_BITMAP;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflLoadThumbnail(const filename :PAnsiChar;
  width, height: GFL_INT32; var bitmap: PGFL_BITMAP;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
{$IFDEF UNICODE_SUPPORT}
function gflLoadThumbnailW(const filename: PWideChar;
  width, height: GFL_INT32; var bitmap: PGFL_BITMAP;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
{$ENDIF UNICODE_SUPPORT}

function gflLoadThumbnailFromHandle(handle: GFL_HANDLE;
  width, height: GFL_INT32; var bitmap: PGFL_BITMAP;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflLoadThumbnailFromMemory(const data: PGFL_UINT8;
  data_length : GFL_UINT32; width, height: GFL_INT32;
  var bitmap: PGFL_BITMAP; const params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflSaveBitmap(filename :PAnsiChar;
  const bitmap: PGFL_BITMAP; var params: TGFL_SAVE_PARAMS): GFL_ERROR; stdcall;
{$IFDEF UNICODE_SUPPORT}
function gflSaveBitmapW(filename :PWideChar;
  const bitmap: PGFL_BITMAP; const params: TGFL_SAVE_PARAMS): GFL_ERROR; stdcall;
{$ENDIF UNICODE_SUPPORT}


function gflSaveBitmapIntoHandle(handle: GFL_HANDLE;
  const bitmap: PGFL_BITMAP; var params: TGFL_SAVE_PARAMS): GFL_ERROR; stdcall;

function gflSaveBitmapIntoMemory(var data: PGFL_UINT8; data_length: PGFL_UINT32;
  const bitmap: PGFL_BITMAP; const params : TGFL_SAVE_PARAMS): GFL_ERROR; stdcall;

// Bitmap Memory Handling
function gflAllockBitmap(BType: GFL_BITMAP_TYPE;
  width, height, line_padding: GFL_INT32;
  const color: PGFL_COLOR): PGFL_BITMAP; stdcall;

function gflAllockBitmapEx(BType: GFL_BITMAP_TYPE; width, height: GFL_INT32;
  bits_per_component: GFL_UINT16; padding: GFL_UINT32;
  const color: PGFL_COLOR): PGFL_BITMAP; stdcall;

procedure gflFreeBitmap(bitmap: PGFL_BITMAP); stdcall;
procedure gflFreeBitmapData(bitmap: PGFL_BITMAP); stdcall;

function gflCloneBitmap(bitmap: PGFL_BITMAP): PGFL_BITMAP; stdcall;

procedure gflBitmapSetName(var bitmap: PGFL_BITMAP; const name: PChar); stdcall;

{$else}

var
  gflGetNumberOfFormat :function :GFL_INT32; stdcall;
  gflGetFormatInformationByIndex :function(index: GFL_INT32; var info: TGFL_FORMAT_INFORMATION): GFL_ERROR; stdcall;

  gflGetFileInformationW :function (const filename: PWideChar; index: GFL_INT32; const info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
  gflFreeFileInformation :procedure(var info: TGFL_FILE_INFORMATION); stdcall;

  gflGetDefaultLoadParams :procedure(var params: TGFL_LOAD_PARAMS); stdcall;
  gflLoadBitmapW :function(const filename: PWideChar; var Bitmap: PGFL_BITMAP; var params: TGFL_LOAD_PARAMS; var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;
  gflFreeBitmap :procedure(bitmap: PGFL_BITMAP); stdcall;

{$endif bStaticLink}


// Multi-page file
type
  GFL_FILE_HANDLE = Pointer;


{$ifdef bStaticLink}
function gflFileCreate(var handle: GFL_FILE_HANDLE; const filename: PAnsiChar;
  image_count: GFL_UINT32; var params: TGFL_SAVE_PARAMS): GFL_ERROR; stdcall;

{$IFDEF UNICODE_SUPPORT} //* UNICODE support */
function gflFileCreateW(var handle: GFL_FILE_HANDLE; const filename: PWideChar;
  image_count: GFL_UINT32; var params: TGFL_SAVE_PARAMS): GFL_ERROR; stdcall;
{$ENDIF UNICODE_SUPPORT}

function gflFileAddPicture(handle: GFL_FILE_HANDLE;
  const bitmap: PGFL_BITMAP): GFL_ERROR; stdcall;

procedure gflFileClose(handle: GFL_FILE_HANDLE); stdcall;
{$endif bStaticLink}


// Bitmap resize
const
  GFL_RESIZE_QUICK    = 0;
  GFL_RESIZE_BILINEAR = 1;
  GFL_RESIZE_HERMITE  = 2;
  GFL_RESIZE_GAUSSIAN = 3;
  GFL_RESIZE_BELL     = 4;
  GFL_RESIZE_BSPLINE  = 5;
  GFL_RESIZE_MITSHELL = 6;
  GFL_RESIZE_LANCZOS  = 7;

{$ifdef bStaticLink}
function gflResize(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  width, height: GFL_INT32;
  resize_mode, flags: GFL_UINT32): GFL_ERROR; stdcall;
{$endif bStaticLink}


type
  GFL_MODE = GFL_UINT16;
const
  GFL_MODE_TO_BINARY    = 1;
  GFL_MODE_TO_4GREY     = 2;
  GFL_MODE_TO_8GREY     = 3;
  GFL_MODE_TO_16GREY    = 4;
  GFL_MODE_TO_32GREY    = 5;
  GFL_MODE_TO_64GREY    = 6;
  GFL_MODE_TO_128GREY   = 7;
  GFL_MODE_TO_216GREY   = 8;
  GFL_MODE_TO_256GREY   = 9;
  GFL_MODE_TO_8COLORS   = 12;
  GFL_MODE_TO_16COLORS  = 13;
  GFL_MODE_TO_32COLORS  = 14;
  GFL_MODE_TO_64COLORS  = 15;
  GFL_MODE_TO_128COLORS = 16;
  GFL_MODE_TO_216COLORS = 17;
  GFL_MODE_TO_256COLORS = 18;
  GFL_MODE_TO_RGB       = 19;
  GFL_MODE_TO_RGBA      = 20;
  GFL_MODE_TO_BGR       = 21;
  GFL_MODE_TO_ABGR      = 22;
  GFL_MODE_TO_BGRA      = 23;
  GFL_MODE_TO_ARGB      = 24;
  GFL_MODE_TO_TRUECOLORS = GFL_MODE_TO_RGB; // GFL_MODE_TO_BGR ??  For compatibility

type
  GFL_MODE_PARAMS = GFL_UINT16;
const
  GFL_MODE_NO_DITHER        = 0;
  GFL_MODE_PATTERN_DITHER   = 1;
  GFL_MODE_HALTONE45_DITHER = 2; // Only with GFL_MODE_TO_BINARY
  GFL_MODE_HALTONE90_DITHER = 3; // Only with GFL_MODE_TO_BINARY
  GFL_MODE_ADAPTIVE         = 4;
  GFL_MODE_FLOYD_STEINBERG  = 5; // Pierre says: Only with GFL_MODE_TO_BINARY
                                 // I tested with 8 and 4 Bit and test is OK ??

{$ifdef bStaticLink}
function gflChangeColorDepth(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  color_mode: GFL_MODE; mode_params: GFL_MODE_PARAMS): GFL_ERROR; stdcall;

function gflFlipVertical(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflFlipHorizontal(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflCrop(src: PGFL_BITMAP; dst: PPGFL_BITMAP; rect: PGFL_RECT): GFL_ERROR; stdcall;
function gflAutoCrop(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  var color: TGFL_COLOR; tolerance: GFL_INT32): GFL_ERROR; stdcall;
function gflAutoCrop2(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  var color: TGFL_COLOR; tolerance: GFL_INT32): GFL_ERROR; stdcall;
{$endif bStaticLink}

type
  GFL_CANVASRESIZE = GFL_UINT32;
const
  GFL_CANVASRESIZE_TOPLEFT     = 0;
  GFL_CANVASRESIZE_TOP         = 1;
  GFL_CANVASRESIZE_TOPRIGHT    = 2;
  GFL_CANVASRESIZE_LEFT        = 3;
  GFL_CANVASRESIZE_CENTER      = 4;
  GFL_CANVASRESIZE_RIGHT       = 5;
  GFL_CANVASRESIZE_BOTTOMLEFT  = 6;
  GFL_CANVASRESIZE_BOTTOM      = 7;
  GFL_CANVASRESIZE_BOTTOMRIGHT = 8;

{$ifdef bStaticLink}
function gflResizeCanvas(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  width, height: GFL_INT32; resize_mode: GFL_CANVASRESIZE;
  var color: PGFL_COLOR): GFL_ERROR; stdcall;

function gflScaleToGrey(src: PGFL_BITMAP; dst: PPGFL_BITMAP; width, height: GFL_INT32): GFL_ERROR; stdcall;

function gflRotate(src: PGFL_BITMAP; dst: PPGFL_BITMAP; angle: GFL_INT32; var color: TGFL_COLOR): GFL_ERROR; stdcall;
function gflRotateFine(src: PGFL_BITMAP; dst: PPGFL_BITMAP; angle: double; var color: TGFL_COLOR): GFL_ERROR; stdcall;

function gflBitblt(src: PGFL_BITMAP; rect: PGFL_RECT;
  dst: PGFL_BITMAP; x_dest, y_dest: GFL_INT32): GFL_ERROR; stdcall;

function gflBitbltEx(src: PGFL_BITMAP; rect: PGFL_RECT;
  dst: PGFL_BITMAP; x_dest, y_dest: GFL_INT32): GFL_ERROR; stdcall;

function gflMerge(const src: PGFL_BITMAP; origin: PGFL_POINT;
  opacity: GFL_UINT32; num_bitmap: GFL_INT32; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflCombineAlpha(src: PGFL_BITMAP; dst: PPGFL_BITMAP; var color: TGFL_COLOR): GFL_ERROR; stdcall;

function gflSetTransparentColor(src: PGFL_BITMAP; dst: PPGFL_BITMAP; var mask_color, back_color: TGFL_COLOR): GFL_ERROR; stdcall;


{**  FIXME: I'm not C experts, is it a Pointer of data line y or of all bitmap data
#define gflGetBitmapPtr( _bitmap, _y ) \
	((_bitmap)->Data + (_y) * (_bitmap)->BytesPerLine)
**}
function gflGetBitmapPtr(var bitmap: PGFL_Bitmap; y_line: Integer): PGFL_UINT8;

function gflGetColorAt(const src: PGFL_BITMAP; x, y: GFL_INT32; var color: TGFL_COLOR): GFL_ERROR; stdcall;
function gflSetColorAt(var dst: PGFL_BITMAP; x, y: GFL_INT32; var color: TGFL_COLOR): GFL_ERROR; stdcall;
function gflGetColorAtEx(const src: PGFL_BITMAP; ptr: PGFL_UINT8; var color: TGFL_COLOR): GFL_ERROR; stdcall;
function gflSetColorAtEx(var dst: PGFL_BITMAP; ptr: PGFL_UINT8; var color: TGFL_COLOR): GFL_ERROR; stdcall;

function gflReplaceColor(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  color, new_color: PGFL_COLOR; tolerance: GFL_INT32): GFL_ERROR; stdcall;
{$endif bStaticLink}

// EXIF
const
  GFL_EXIF_IFD_0                = $0001;
  GFL_EXIF_MAIN_IFD             = $0002;
  GFL_EXIF_INTEROPERABILITY_IFD = $0004;
  GFL_EXIF_IFD_THUMBNAIL        = $0008;
  GFL_EXIF_GPS_IFD              = $0010;
  GFL_EXIF_MAKERNOTE_IFD        = $0020;

  GFL_EXIF_MAKER						 = $010F;
  GFL_EXIF_MODEL						 = $0110;
  GFL_EXIF_ORIENTATION			 = $0112;
  GFL_EXIF_EXPOSURETIME		   = $829A;
  GFL_EXIF_FNUMBER				   = $829D;
  GFL_EXIF_DATETIME_ORIGINAL = $9003;
  GFL_EXIF_SHUTTERSPEED			 = $9201;
  GFL_EXIF_APERTURE				   = $9202;
  GFL_EXIF_MAXAPERTURE			 = $9205;
  GFL_EXIF_FOCALLENGTH       = $920A;

{
/*
 * For advanced developer only!!!
 */
const
  GFL_EXIF_BYTE      = 1;
  GFL_EXIF_STRING    = 2;
  GFL_EXIF_USHORT    = 3;
  GFL_EXIF_ULONG     = 4;
  GFL_EXIF_URATIONAL = 5;
  GFL_EXIF_SBYTE     = 6;
  GFL_EXIF_UNDEFINED = 7;
  GFL_EXIF_SSHORT    = 8;
  GFL_EXIF_SLONG     = 9;
  GFL_EXIF_SRATIONAL = 10;
  GFL_EXIF_SINGLEF   = 11;
  GFL_EXIF_DOUBLE    = 12;
}

type
  PGFL_EXIF_ENTRY = ^TGFL_EXIF_ENTRY;
  TGFL_EXIF_ENTRY  = {packed} record
    Flag  : GFL_UINT32; // EXIF_...IFD
    Tag   : GFL_UINT32;
    Name  : PChar;
    Value : PChar;
  end;

  PTTabGFL_EXIF_ENTRY = ^TTabGFL_EXIF_ENTRY;
  TTabGFL_EXIF_ENTRY = array [0..MaxInt div SizeOf(TGFL_EXIF_ENTRY) - 1] of TGFL_EXIF_ENTRY;

  PGFL_EXIF_DATA = ^TGFL_EXIF_DATA;
  TGFL_EXIF_DATA  = {packed} record
    NumberOfItems : GFL_UINT32;
    ItemsList     : PTTabGFL_EXIF_ENTRY; // PGFL_EXIF_ENTRY;
  end;

{$ifdef bStaticLink}
function gflBitmapHasEXIF(src: PGFL_BITMAP): GFL_BOOL; stdcall;
function gflBitmapGetEXIF(src: PGFL_BITMAP; flags: GFL_UINT32): PGFL_EXIF_DATA; stdcall;
procedure gflFreeEXIF(exif: PGFL_EXIF_DATA); stdcall;
procedure gflBitmapSetEXIFThumbnail(bitmap: PGFL_BITMAP; const thumb_bitmap: PGFL_BITMAP); stdcall;
procedure gflBitmapRemoveEXIFThumbnail(src: PGFL_BITMAP); stdcall;

// exif from file
function gflLoadEXIF(const filename: PAnsiChar; flags: GFL_UINT32): PGFL_EXIF_DATA; stdcall;
{$IFDEF UNICODE_SUPPORT}
function gflLoadEXIFW(const filename: PWideChar; flags: GFL_UINT32): PGFL_EXIF_DATA; stdcall;
{$ENDIF UNICODE_SUPPORT}

{$else}

var
  gflBitmapGetEXIF :function(src: PGFL_BITMAP; flags: GFL_UINT32): PGFL_EXIF_DATA; stdcall;
  gflFreeEXIF :procedure(exif: PGFL_EXIF_DATA); stdcall;

{$endif bStaticLink}

//****** GPo 2008
//***** all exif and iptc records changed to packed records
//*****

{/*
 * For Advanced developer only  Exif 2
/*}
const
  GFL_EXIF_BYTE      = 1;
  GFL_EXIF_STRING    = 2;
  GFL_EXIF_USHORT    = 3;
  GFL_EXIF_ULONG     = 4;
  GFL_EXIF_URATIONAL = 5;
  GFL_EXIF_SBYTE     = 6;
  GFL_EXIF_UNDEFINED = 7;
  GFL_EXIF_SSHORT    = 8;
  GFL_EXIF_SLONG     = 9;
  GFL_EXIF_SRATIONAL = 10;
  GFL_EXIF_SINGLEF   = 11;
  GFL_EXIF_DOUBLE    = 12;

type
   PGFL_EXIF_ENTRYEX= ^TGFL_EXIF_ENTRYEX;
   TGFL_EXIF_ENTRYEX = packed record
		 Tag: GFL_UINT16;
		 Format: GFL_UINT16;
		 lfd: GFL_INT32;
		 NumberOfComponents: GFL_INT32;
		 Value: GFL_UINT32;
		 DataLength: GFL_INT32;
		 Data: Pointer;
     Next: PGFL_EXIF_ENTRYEX;
   end;

  PGFL_EXIF_DATAEX = ^TGFL_EXIF_DATAEX;
  TGFL_EXIF_DATAEX = packed record
   Root: PGFL_EXIF_ENTRYEX;
   UseMsbf: GFL_INT32;
	end;

{$ifdef bStaticLink}
function gflBitmapGetEXIF2(bitmap: PGFL_BITMAP): PGFL_EXIF_DATAEX; stdcall;
procedure gflFreeEXIF2(exif_data: PGFL_EXIF_DATAEX); stdcall;
procedure gflBitmapSetEXIF2(bitmap : PGFL_BITMAP; const exif : PGFL_EXIF_DATAEX); stdcall;
procedure gflBitmapSetEXIFValueString2(exif: PGFL_EXIF_DATAEX; ifd, tag: GFL_UINT16; const value: PChar); stdcall;
procedure gflBitmapSetEXIFValueInt2(exif: PGFL_EXIF_DATAEX; ifd,tag: GFL_UINT16; format, value: GFL_UINT32); stdcall;
procedure gflBitmapSetEXIFValueRational2(exif: PGFL_EXIF_DATAEX; ifd, tag: GFL_UINT16; p,q: GFL_UINT32); stdcall;
procedure gflBitmapSetEXIFValueRationalArray2(exif: PGFL_EXIF_DATAEX; ifd, tag: GFL_UINT16; const pq: PGFL_UINT32; count: GFL_INT32); stdcall;
{$endif bStaticLink}

// IPTC
const
  GFL_IPTC_BYLINE								  = $50;
  GFL_IPTC_BYLINETITLE						= $55;
  GFL_IPTC_CREDITS 								= $6e;
  GFL_IPTC_SOURCE 								= $73;
  GFL_IPTC_CAPTIONWRITER 					= $7a;
  GFL_IPTC_CAPTION 								= $78;
  GFL_IPTC_HEADLINE 						 	= $69;
  GFL_IPTC_SPECIALINSTRUCTIONS 		= $28;
  GFL_IPTC_OBJECTNAME 						= $05;
  GFL_IPTC_DATECREATED 						= $37;
  GFL_IPTC_RELEASEDATE 						= $1e;
  GFL_IPTC_TIMECREATED 						= $3c;
  GFL_IPTC_RELEASETIME 						= $23;
  GFL_IPTC_CITY 								  = $5a;
  GFL_IPTC_STATE 									= $5f;
  GFL_IPTC_COUNTRY 						 		= $65;
  GFL_IPTC_COUNTRYCODE 						= $64;
  GFL_IPTC_SUBLOCATION 						= $5c;
  GFL_IPTC_ORIGINALTRREF 					= $67;
  GFL_IPTC_CATEGORY 							= $0f;
  GFL_IPTC_COPYRIGHT 				 			= $74;
  GFL_IPTC_EDITSTATUS 			 			= $07;
  GFL_IPTC_PRIORITY 							= $0a;
  GFL_IPTC_OBJECTCYCLE 				 		= $4b;
  GFL_IPTC_JOBID 							 		= $16;
  GFL_IPTC_PROGRAM 								= $41;
  GFL_IPTC_KEYWORDS								= $19;
  GFL_IPTC_SUPCATEGORIES					= $14;
  GFL_IPTC_CONTENT_LOCATION       = $1b;
  GFL_IPTC_PROGRAM_VERSION        = $46;
  GFL_IPTC_CONTACT                = $76;

type
  PGFL_IPTC_ENTRY = ^TGFL_IPTC_ENTRY;
  TGFL_IPTC_ENTRY  = packed record
    Id  : GFL_UINT32;
    Name  : PChar;
    Value : PChar;
  end;

  PTTabGFL_IPTC_ENTRY = ^TTabGFL_IPTC_ENTRY;
  TTabGFL_IPTC_ENTRY = array [0..0] of TGFL_IPTC_ENTRY;

  PGFL_IPTC_DATA = ^TGFL_IPTC_DATA;
  TGFL_IPTC_DATA = packed record
    NumberOfItems : GFL_UINT32;
    ItemsList     : PTTabGFL_IPTC_ENTRY; // PGFL_IPTC_ENTRY;
  end;

{$ifdef bStaticLink}
function gflBitmapHasIPTC(src: PGFL_BITMAP): GFL_BOOL; stdcall;
function gflBitmapGetIPTC(src: PGFL_BITMAP; flags: GFL_UINT32): PGFL_IPTC_DATA; stdcall;
function gflBitmapSetIPTC(src: PGFL_BITMAP; iptc_data: PGFL_IPTC_DATA): GFL_ERROR; stdcall;
procedure gflFreeIPTC(iptc_data: PGFL_IPTC_DATA); stdcall;

function gflNewIPTC(): PGFL_IPTC_DATA; stdcall;
function gflBitmapGetIPTCValue(src: PGFL_BITMAP; id: GFL_UINT32; value: PChar; value_length: GFL_INT32): GFL_ERROR; stdcall;
function gflSetIPTCValue(iptc_data: PGFL_IPTC_DATA; id: GFL_UINT32; value: PChar): GFL_ERROR; stdcall;
function gflRemoveIPTCValue(iptc_data: PGFL_IPTC_DATA; id: GFL_UINT32): GFL_ERROR; stdcall;
// from file
function gflLoadIPTC(filename: PChar): PGFL_IPTC_DATA; stdcall;
function gflSaveIPTC(filename: PChar; iptc_data: PGFL_IPTC_DATA): GFL_ERROR; stdcall;

{$IFDEF UNICODE_SUPPORT} //* UNICODE support */
function gflLoadIPTCW(const filename: PWideChar): PGFL_IPTC_DATA; stdcall;
function gflSaveIPTCW(const filename: PWideChar; const iptc_data: PGFL_IPTC_DATA): GFL_ERROR; stdcall;
{$ENDIF}

function gflBitmapHasICCProfile(const bitmap: PGFL_BITMAP): GFL_BOOL; stdcall;
//* pData must be freed by gflFreeMemory */
procedure gflBitmapGetICCProfile(const bitmap: PGFL_BITMAP; var pData: PGFL_UINT8;
   pLength: PGFL_UINT32); stdcall;
procedure gflBitmapCopyICCProfile(const src, dst: PGFL_BITMAP); stdcall;
procedure gflBitmapRemoveICCProfile(bitmap: PGFL_BITMAP); stdcall;

// XMP
function gflBitmapGetXMP(const bitmap: PGFL_BITMAP; var pData: PGFL_UINT8;
   pLength: PGFL_UINT32): GFL_BOOL; stdcall;

procedure gflBitmapRemoveMetaData(src: PGFL_BITMAP); stdcall;

function gflJPEGGetComment(filename: PChar; comment: PChar; max_size: GFL_INT32): GFL_ERROR; stdcall;
function gflJPEGSetComment(filename: PChar; comment: PChar): GFL_ERROR; stdcall;
procedure gflBitmapSetComment(src: PGFL_BITMAP; comment: PChar); stdcall;
function gflPNGGetComment(filename: PChar; comment: PChar; max_size: GFL_INT32): GFL_ERROR; stdcall;
function gflPNGSetComment(filename: PChar; comment: PChar): GFL_ERROR; stdcall;

{$IFDEF UNICODE_SUPPORT} //* UNICODE support */
function gflJPEGGetCommentW(const filename: PWideChar; comment: PChar; max_size: Integer): GFL_ERROR; stdcall;
function gflJPEGSetCommentW(const filename: PWideChar; comment: PChar): GFL_ERROR; stdcall;
function gflPNGGetCommentW(const filename: PWideChar; comment: PChar; max_size: Integer): GFL_ERROR; stdcall;
function gflPNGSetCommentW(const filename: PWideChar; comment: PChar): GFL_ERROR; stdcall;
{$ENDIF}

// DPX LUT
function gflIsLutFile(const filename: PChar): GFL_BOOL; stdcall;

function gflIsCompatibleLutFile(const filename: PChar;
  const components_per_pixel, bits_per_component: GFL_INT32;
  lut_type: GFL_LUT_TYPE): GFL_BOOL; stdcall;

function gflApplyLutFile(src: PGFL_BITMAP; var dst: PGFL_BITMAP;
  const filename: PChar; lut_type: GFL_LUT_TYPE): GFL_ERROR; stdcall;


//------------------------------------------------------------------------------------------------------------------
// functions in LibGflExxx.dll
//------------------------------------------------------------------------------------------------------------------

function gflGetNumberOfColorsUsed(src: PGFL_BITMAP): GFL_UINT32; stdcall;

function gflNegative(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflBrightness(src: PGFL_BITMAP; dst: PPGFL_BITMAP; brightness: GFL_INT32): GFL_ERROR; stdcall;
function gflContrast(src: PGFL_BITMAP; dst: PPGFL_BITMAP; contrast: GFL_INT32): GFL_ERROR; stdcall;
function gflGamma(src: PGFL_BITMAP; dst: PPGFL_BITMAP; gamma: double): GFL_ERROR; stdcall;
function gflLogCorrection(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflNormalize(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEqualize(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEqualizeOnLuminance(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflBalance(src: PGFL_BITMAP; dst: PPGFL_BITMAP; var color: PGFL_COLOR): GFL_ERROR; stdcall;
function gflAdjust(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  brightness: GFL_INT32; contrast: GFL_INT32; gamma: double): GFL_ERROR; stdcall;
function gflAdjustHLS(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  hue: GFL_INT32; lightness: GFL_INT32; saturation: GFL_INT32): GFL_ERROR; stdcall;
function gflAutomaticContrast(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflAutomaticLevels(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflAverage(src: PGFL_BITMAP; dst: PPGFL_BITMAP; filter_size: GFL_INT32): GFL_ERROR; stdcall;
function gflSoften(src: PGFL_BITMAP; dst: PPGFL_BITMAP; percentage: GFL_INT32): GFL_ERROR; stdcall;
function gflBlur(src: PGFL_BITMAP; dst: PPGFL_BITMAP; percentage: GFL_INT32): GFL_ERROR; stdcall;
function gflGaussianBlur(src: PGFL_BITMAP; dst: PPGFL_BITMAP; filter_size: GFL_INT32): GFL_ERROR; stdcall;
function gflMaximum(src: PGFL_BITMAP; dst: PPGFL_BITMAP; filter_size: GFL_INT32): GFL_ERROR; stdcall;
function gflMinimum(src: PGFL_BITMAP; dst: PPGFL_BITMAP; filter_size: GFL_INT32): GFL_ERROR; stdcall;
function gflMedianBox(src: PGFL_BITMAP; dst: PPGFL_BITMAP; filter_size: GFL_INT32): GFL_ERROR; stdcall;
function gflMedianCross(src: PGFL_BITMAP; dst: PPGFL_BITMAP; filter_size: GFL_INT32): GFL_ERROR; stdcall;
function gflSharpen(src: PGFL_BITMAP; dst: PPGFL_BITMAP; percentage: GFL_INT32): GFL_ERROR; stdcall;

function gflEnhanceDetail(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEnhanceFocus(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflFocusRestoration(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEdgeDetectLight(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEdgeDetectMedium(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEdgeDetectHeavy(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEmboss(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflEmbossMore(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflSepia(src: PGFL_BITMAP; dst: PPGFL_BITMAP; percent: GFL_INT32): GFL_ERROR; stdcall;
function gflSepiaExt(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  percent: GFL_INT32; var color: PGFL_COLOR): GFL_ERROR; stdcall;

function gflReduceNoise(src: PGFL_BITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflDropShadow(src: PGFL_BITMAP; dst: PPGFL_BITMAP; size, depth, keep_size: GFL_INT32): GFL_ERROR; stdcall;
{$endif bStaticLink}

// CONVOLVE
type
  PGFL_FILTER = ^TGFL_FILTER;
  TGFL_FILTER = record
    Size: GFL_INT16;
    Matrix: array[0..15, 0..7] of GFL_INT16;
    Divisor: GFL_INT16;
    Bias: GFL_INT16;
  end;

{$ifdef bStaticLink}
function gflConvolve(src: PGFL_BITMAP; dst: PPGFL_BITMAP;
  var filter: PGFL_FILTER): GFL_ERROR; stdcall;
{$endif bStaticLink}

// SWAP COLORS
type
  GFL_SWAPCOLORS_MODE = GFL_UINT16;
const
  GFL_SWAPCOLORS_RBG = 0;
  GFL_SWAPCOLORS_BGR = 1;
  GFL_SWAPCOLORS_BRG = 2;
  GFL_SWAPCOLORS_GRB = 3;
  GFL_SWAPCOLORS_GBR = 4;

{$ifdef bStaticLink}
function gflSwapColors(src: PGFL_BITMAP; dst: PPGFL_BITMAP; mode: GFL_SWAPCOLORS_MODE): GFL_ERROR; stdcall;
{$endif bStaticLink}

// JPEG LOSSLESS
type
  GFL_LOSSLESS_TRANSFORM = GFL_UINT16;
const
  GFL_LOSSLESS_TRANSFORM_NONE            = 0;
  GFL_LOSSLESS_TRANSFORM_ROTATE90        = 1;
  GFL_LOSSLESS_TRANSFORM_ROTATE180       = 2;
  GFL_LOSSLESS_TRANSFORM_ROTATE270       = 3;
  GFL_LOSSLESS_TRANSFORM_VERTICAL_FLIP   = 4;
  GFL_LOSSLESS_TRANSFORM_HORIZONTAL_FLIP = 5;

{$ifdef bStaticLink}
function gflJpegLosslessTransform(filename: PChar; transform: GFL_LOSSLESS_TRANSFORM): GFL_ERROR; stdcall;
{$endif bStaticLink}

{$IFDEF MSWINDOWS}

{$ifdef bStaticLink}
function gflConvertBitmapIntoDIB(src: PGFL_BITMAP; var hDIB: THANDLE): GFL_ERROR; stdcall;
function gflConvertBitmapIntoDIBSection(const bitmap: PGFL_BITMAP; var hDIB: HBITMAP): GFL_ERROR; stdcall;
function gflConvertBitmapIntoDDB(src: PGFL_BITMAP; var hBitmap: HBITMAP): GFL_ERROR; stdcall;
function gflConvertBitmapIntoDDBEx(src: PGFL_BITMAP; var hBitmap: HBITMAP; var background_color : TGFL_COLOR): GFL_ERROR; stdcall;
function gflConvertDIBIntoBitmap(hDIB: THANDLE; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
function gflConvertDDBIntoBitmap(hBitmap: HBITMAP; dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflLoadBitmapIntoDIB(filename: PChar;
  var hDIB: THANDLE;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflLoadBitmapIntoDIBSection(filename: PChar;
  var hDib: HBITMAP;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflLoadBitmapIntoDDB(filename: PChar;
  var hBitmap: HBITMAP;
  var params: TGFL_LOAD_PARAMS;
  var info: TGFL_FILE_INFORMATION): GFL_ERROR; stdcall;

function gflAddText(src: PGFL_BITMAP; text, font_name: PChar;
  x, y, font_size, orientation: GFL_INT32;
  italic, bold, strike_out, underline, antialias: GFL_BOOL;
  var color: PGFL_COLOR): GFL_ERROR; stdcall;

{$IFDEF UNICODE_SUPPORT} //** Unicode support
function gflAddTextW(dst: PGFL_BITMAP; text, font_name: PWideChar;
  x, y, font_size, orientation: GFL_INT32;
  italic, bold, strike_out, antialias, underline: GFL_Bool;
  var color: PGFL_COLOR): GFL_ERROR; stdcall;
{$ENDIF}

function gflGetTextExtent(var text, font_name: PChar;
  var font_size, orientation: GFL_INT32;
  var italic, bold, strike_out, underline, antialias: GFL_BOOL;
  var text_width, text_height: GFL_INT32): GFL_ERROR; stdcall;

function gflImportFromClipboard(dst: PGFL_BITMAP): GFL_ERROR; stdcall;
function gflExportIntoClipboard(dst: PGFL_BITMAP): GFL_ERROR; stdcall;
function gflImportFromHWND(hBitmap: HWND; rect: PGFL_RECT;
  var dst: PGFL_BITMAP): GFL_ERROR; stdcall;
{$endif bStaticLink}

// LINE STYLE
type
  GFL_LINE_STYLE = GFL_UINT32;
const
  GFL_LINE_STYLE_SOLID      = 0;
  GFL_LINE_STYLE_DASH       = 1;
  GFL_LINE_STYLE_DOT        = 2;
  GFL_LINE_STYLE_DASHDOT    = 3;
  GFL_LINE_STYLE_DASHDOTDOT = 4;

{$ifdef bStaticLink}
function gflDrawLineColor(src: PGFL_BITMAP;
  x0, y0, x1, y1: GFL_INT32;
  line_width: GFL_UINT32;
  line_color: PGFL_COLOR;
  line_style: GFL_LINE_STYLE;
  dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflDrawPolylineColor(src: PGFL_BITMAP;
  points: PGFL_POINT;
  num_points: GFL_INT32;
  line_width: GFL_UINT32;
  line_color: PGFL_COLOR;
  line_style: GFL_LINE_STYLE;
  dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflDrawPolygonColor(src: PGFL_BITMAP;
  points: PGFL_POINT;
  num_points: GFL_INT32;
  fill_color: PGFL_COLOR;
  line_width: GFL_UINT32;
  line_color: PGFL_COLOR;
  line_style: GFL_LINE_STYLE;
  dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflDrawRectangleColor(src: PGFL_BITMAP;
  x0, y0, width, height: GFL_INT32;
  fill_color: PGFL_COLOR;
  line_width: GFL_UINT32;
  line_color: PGFL_COLOR;
  line_style: GFL_LINE_STYLE;
  dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflDrawPointColor(src: PGFL_BITMAP;
  x0, y0, width, height: GFL_INT32;
  line_width: GFL_UINT32;
  line_color: PGFL_COLOR;
  dst: PPGFL_BITMAP): GFL_ERROR; stdcall;

function gflDrawCircleColor(src: PGFL_BITMAP;
  x, y, radius: GFL_INT32;
  fill_color: PGFL_COLOR;
  line_width: GFL_UINT32;
  line_color: PGFL_COLOR;
  line_style: GFL_LINE_STYLE;
  dst: PPGFL_BITMAP): GFL_ERROR; stdcall;
{$endif bStaticLink}

{$ENDIF}

// lokale declarations added GPo 2008
function gflBitmapGetIsTrueColors(bitmap: PGFL_Bitmap): boolean;
function gflBitmapGetIs24Bits(bitmap: PGFL_Bitmap): boolean;


{$ifndef bStaticLink}
function gflLoadLib :Boolean;
{$endif bStaticLink}


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


//------------------------------------------------------------------------------
// functions in LibGflxxx.dll
//------------------------------------------------------------------------------

{**  FIXME: I'm not C experts, is it a Pointer of data line y or of all bitmap data
#define gflGetBitmapPtr( _bitmap, _y ) \
	((_bitmap)->Data + (_y) * (_bitmap)->BytesPerLine)
}
function gflGetBitmapPtr(var bitmap: PGFL_Bitmap; y_line: Integer): PGFL_UINT8;
begin
  If y_line >= bitmap.Height then
    y_line:= bitmap.Height-1
  else
  if y_line < 0 then
    y_line:= 0;
  Result:= PGFL_UINT8(PAnsiChar(bitmap.Data) + (y_line* Integer(bitmap.BytesPerLine)));
end;

function gflBitmapGetIsTrueColors(bitmap: PGFL_Bitmap): boolean;
begin
  Result:= bitmap.BType and GFL_TRUECOLORS = bitmap.BType;
end;

function gflBitmapGetIs24Bits(bitmap: PGFL_Bitmap): boolean;
begin
  Result:= bitmap.BType and GFL_IS24BITS = bitmap.BType;
end;


{$ifdef bStaticLink}

{------------------------------------------------------------------------------}
{ Static Link                                                                  }
{------------------------------------------------------------------------------}

function gflMemoryAlloc; external GflDLL;
function gflMemoryRealloc; external GflDLL;
procedure gflMemoryFree; external GflDLL;

function gflGetVersion; external GflDLL;
function gflGetVersionOfLibformat; external GflDLL;

function gflLibraryInit; external GflDLL;
function gflLibraryInitEx; external GflDLL;
procedure gflLibraryExit; external GflDLL;
procedure gflEnableLZW; external GflDLL;
procedure gflSetPluginsPathname; external GflDLL;

function gflGetNumberOfFormat; external GflDLL;
function gflGetFormatIndexByName; external GflDLL;
function gflGetFormatNameByIndex; external GflDLL;

function gflSaveParamsIsSupportedByIndex; external GflDLL;
function gflSaveParamsIsSupportedByName; external GflDLL;
function gflCompressionIsSupportedByIndex; external GflDLL;
function gflCompressionIsSupportedByName; external GflDLL;
function gflBitmapIsSupportedByIndex; external GflDLL;
function gflBitmapIsSupportedByName; external GflDLL;
function gflBitmapTypeIsSupportedByIndex; external GflDLL;
function gflBitmapTypeIsSupportedByName; external GflDLL;

function gflFormatIsSupported; external GflDLL;
function gflFormatIsWritableByIndex; external GflDLL;
function gflFormatIsWritableByName; external GflDLL;
function gflFormatIsReadableByIndex; external GflDLL;
function gflFormatIsReadableByName; external GflDLL;

function gflGetDefaultFormatSuffixByIndex; external GflDLL;
function gflGetDefaultFormatSuffixByName; external GflDLL;
function gflGetFormatDescriptionByIndex; external GflDLL;
function gflGetFormatDescriptionByName; external GflDLL;
function gflGetFormatInformationByName; external GflDLL;
function gflGetFormatInformationByIndex; external GflDLL;

function gflGetErrorString; external GflDLL;
function gflGetLabelForColorModel; external GflDLL;
function gflGetFileInformation; external GflDLL;
function gflGetFileInformationFromMemory; external GflDLL;
function gflGetFileInformationFromHandle; external GflDLL;
procedure gflFreeFileInformation; external GflDLL;

procedure gflGetDefaultLoadParams; external GflDLL;
procedure gflGetDefaultSaveParams; external GflDLL;
procedure gflGetDefaultPreviewParams; external GflDLL;
procedure gflGetDefaultThumbnailParams; external GflDLL;

function gflLoadBitmap; external GflDLL;
function gflLoadBitmapFromHandle; external GflDLL;
function gflLoadBitmapFromMemory; external GflDLL;

function gflLoadThumbnail; external GflDLL;
function gflLoadThumbnailFromHandle; external GflDLL;
function gflLoadThumbnailFromMemory; external GflDLL;

function gflSaveBitmap; external GflDLL;
function gflSaveBitmapIntoHandle; external GflDLL;
function gflSaveBitmapIntoMemory; external GflDLL;

//** Unicode support
{$IFDEF UNICODE_SUPPORT}
procedure gflSetPluginsPathnameW; external GflDLL;
function gflGetFileInformationW; external GflDLL;
function gflLoadBitmapW; external GflDLL;
function gflLoadThumbnailW; external GflDLL;
function gflSaveBitmapW; external GflDLL;

function gflLoadEXIFW; external GflDLL;
function gflLoadIPTCW; external GflDLL;
function gflSaveIPTCW; external GflDLL;

function gflFileCreateW; external GflDLL;

function gflJPEGGetCommentW; external GflDLL;
function gflJPEGSetCommentW; external GflDLL;
function gflPNGGetCommentW; external GflDLL;
function gflPNGSetCommentW; external GflDLL;

function gflAddTextW; external GfleDLL;
{$ENDIF}
//**

function gflAllockBitmap; external GflDLL;
function gflAllockBitmapEx; external GflDLL;
procedure gflFreeBitmap; external GflDLL;
procedure gflFreeBitmapData; external GflDLL;
function gflCloneBitmap; external GflDLL;

procedure gflBitmapSetName; external GflDLL;

function gflFileCreate; external GflDLL;
function gflFileAddPicture; external GflDLL;
procedure gflFileClose; external GflDLL;

function gflResize; external GflDLL;
function gflScaleToGrey; external GflDLL;
function gflChangeColorDepth; external GflDLL;

function gflFlipVertical; external GflDLL;
function gflFlipHorizontal; external GflDLL;
function gflCrop; external GflDLL;
function gflAutoCrop; external GflDLL;
function gflAutoCrop2; external GflDLL;
function gflResizeCanvas; external GflDLL;
function gflRotate; external GflDLL;
function gflRotateFine; external GflDLL;
function gflBitblt; external GflDLL;
function gflBitbltEx; external GflDLL;

function gflMerge; external GflDLL;
function gflCombineAlpha; external GflDLL;
function gflSetTransparentColor; external GflDLL;

function gflGetColorAt; external GflDLL;
function gflSetColorAt; external GflDLL;
function gflGetColorAtEx; external GflDLL;
function gflSetColorAtEx; external GflDLL;
function gflReplaceColor; external GflDLL;

function gflBitmapHasEXIF; external GflDLL;
function gflBitmapGetEXIF; external GflDLL;
procedure gflFreeEXIF; external GflDLL;
procedure gflBitmapSetEXIFThumbnail; external GflDLL;
procedure gflBitmapRemoveEXIFThumbnail; external GflDLL;
function gflLoadEXIF; external GflDLL;

// exif 2
function gflBitmapGetEXIF2; external GflDLL;
procedure gflFreeEXIF2; external GflDLL;
procedure gflBitmapSetEXIF2; external GflDLL;
procedure gflBitmapSetEXIFValueString2; external GflDLL;
procedure gflBitmapSetEXIFValueInt2; external GflDLL;
procedure gflBitmapSetEXIFValueRational2; external GflDLL;
procedure gflBitmapSetEXIFValueRationalArray2; external GflDLL;

// iptc
function gflBitmapHasIPTC; external GflDLL;
function gflBitmapGetIPTC; external GflDLL;
function gflBitmapGetIPTCValue; external GflDLL;
function gflNewIPTC; external GflDLL;
procedure gflFreeIPTC; external GflDLL;
function gflSetIPTCValue; external GflDLL;
function gflRemoveIPTCValue; external GflDLL;

function gflLoadIPTC; external GflDLL;
function gflSaveIPTC; external GflDLL;
function gflBitmapSetIPTC; external GflDLL;

function gflBitmapHasICCProfile; external GflDLL;
procedure gflBitmapGetICCProfile; external GflDLL;
procedure gflBitmapCopyICCProfile; external GflDLL;
procedure gflBitmapRemoveICCProfile; external GflDLL;

function gflBitmapGetXMP; external GflDLL;
procedure gflBitmapRemoveMetaData; external GflDLL;

procedure gflBitmapSetComment; external GflDLL;
function gflJPEGGetComment; external GflDLL;
function gflJPEGSetComment; external GflDLL;
function gflPNGGetComment; external GflDLL;
function gflPNGSetComment; external GflDLL;

function gflIsLutFile; external GflDLL;
function gflIsCompatibleLutFile; external GflDLL;
function gflApplyLutFile; external GflDLL;

//------------------------------------------------------------------------------
// functions in LibGflExxx.dll
//------------------------------------------------------------------------------
function gflGetNumberOfColorsUsed; external GfleDLL;
function gflNegative; external GfleDLL;
function gflBrightness; external GfleDLL;
function gflContrast; external GfleDLL;
function gflGamma; external GfleDLL;
function gflLogCorrection; external GfleDLL;
function gflNormalize; external GfleDLL;
function gflEqualize; external GfleDLL;
function gflEqualizeOnLuminance; external GfleDLL;
function gflBalance; external GfleDLL;
function gflAdjust; external GfleDLL;
function gflAdjustHLS; external GfleDLL;
function gflAutomaticContrast; external GfleDLL;
function gflAutomaticLevels; external GfleDLL;

function gflAverage; external GfleDLL;
function gflSoften; external GfleDLL;
function gflBlur; external GfleDLL;
function gflGaussianBlur; external GfleDLL;
function gflMaximum; external GfleDLL;
function gflMinimum; external GfleDLL;
function gflMedianBox; external GfleDLL;
function gflMedianCross; external GfleDLL;
function gflSharpen; external GfleDLL;

function gflEnhanceDetail; external GfleDLL;
function gflEnhanceFocus; external GfleDLL;
function gflFocusRestoration; external GfleDLL;
function gflEdgeDetectLight; external GfleDLL;
function gflEdgeDetectMedium; external GfleDLL;
function gflEdgeDetectHeavy; external GfleDLL;
function gflEmboss; external GfleDLL;
function gflEmbossMore; external GfleDLL;

function gflSepia; external GfleDLL;
function gflSepiaExt; external GfleDLL;

function gflReduceNoise; external GfleDLL;
function gflDropShadow; external GfleDLL;

function gflConvolve; external GfleDLL;

function gflSwapColors; external GfleDLL;

function gflJpegLosslessTransform; external GfleDLL;

{$IFDEF MSWINDOWS}

function gflConvertBitmapIntoDIB; external GfleDLL;
function gflConvertBitmapIntoDIBSection; external GfleDLL;
function gflConvertBitmapIntoDDB; external GfleDLL;
function gflConvertBitmapIntoDDBEx; external GfleDLL;
function gflConvertDIBIntoBitmap; external GfleDLL;
function gflConvertDDBIntoBitmap; external GfleDLL;

function gflLoadBitmapIntoDIB; external GfleDLL;
function gflLoadBitmapIntoDIBSection; external GfleDLL;
function gflLoadBitmapIntoDDB; external GfleDLL;
function gflAddText; external GfleDLL;
function gflGetTextExtent; external GfleDLL;

function gflImportFromClipboard; external GfleDLL;
function gflExportIntoClipboard; external GfleDLL;
function gflImportFromHWND; external GfleDLL;

function gflDrawLineColor; external GfleDLL;
function gflDrawPolylineColor; external GfleDLL;
function gflDrawPolygonColor; external GfleDLL;
function gflDrawRectangleColor; external GfleDLL;
function gflDrawPointColor; external GfleDLL;
function gflDrawCircleColor; external GfleDLL;

{$ENDIF}

{$else}

{------------------------------------------------------------------------------}
{ Dynamic Link                                                                 }
{------------------------------------------------------------------------------}

  var
    FHandle :THandle;

  function gflLoadLib :Boolean;
  begin
//  FHandle := LoadLibrary(GflDLL);
//  if FHandle = 0 then
//    begin Result := False; Exit; end;

    FHandle := LoadLibraryEx(GflDLL);

    gflLibraryInit := GetProcAddressEx(FHandle, 'gflLibraryInit');
    gflLibraryExit := GetProcAddressEx(FHandle, 'gflLibraryExit');
    gflEnableLZW := GetProcAddressEx(FHandle, 'gflEnableLZW');
    gflSetPluginsPathnameW := GetProcAddressEx(FHandle, 'gflSetPluginsPathnameW');

    gflGetNumberOfFormat := GetProcAddressEx(FHandle, 'gflGetNumberOfFormat');
    gflGetFormatInformationByIndex := GetProcAddressEx(FHandle, 'gflGetFormatInformationByIndex');

    gflGetFileInformationW := GetProcAddressEx(FHandle, 'gflGetFileInformationW');
    gflFreeFileInformation := GetProcAddressEx(FHandle, 'gflFreeFileInformation');

    gflGetDefaultLoadParams := GetProcAddressEx(FHandle, 'gflGetDefaultLoadParams');
    gflLoadBitmapW := GetProcAddressEx(FHandle, 'gflLoadBitmapW');
    gflFreeBitmap := GetProcAddressEx(FHandle, 'gflFreeBitmap');

    gflBitmapGetEXIF := GetProcAddressEx(FHandle, 'gflBitmapGetEXIF');
    gflFreeEXIF := GetProcAddressEx(FHandle, 'gflFreeEXIF');

//  Result := Assigned(gflLibraryInit) and Assigned(gflLibraryExit) and Assigned(gflEnableLZW) and Assigned(gflSetPluginsPathnameW) and
//    Assigned(gflGetNumberOfFormat) and Assigned(gflGetFormatInformationByIndex) and Assigned(gflGetFileInformationW) and
//    Assigned(gflFreeFileInformation) and Assigned(gflGetDefaultLoadParams) and Assigned(gflLoadBitmapW) and Assigned(gflFreeBitmap) and
//    Assigned(gflBitmapGetEXIF) and Assigned(gflFreeEXIF);

    Result := True;
  end;


{$endif bStaticLink}


//initialization
//  gflLibraryInit;
//finalization
//  gflLibraryExit;

end.


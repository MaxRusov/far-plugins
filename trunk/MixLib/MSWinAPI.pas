{$I Defines.inc}

unit MSWinAPI;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints plugin                                                            *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    ShellAPI;


  const
    { currentlly defined blend function }
    AC_SRC_OVER = $00;
    AC_SRC_ALPHA = $01;

    { alpha format flags }
    AC_SRC_NO_PREMULT_ALPHA = $01;
    AC_SRC_NO_ALPHA = $02;
    AC_DST_NO_PREMULT_ALPHA = $10;
    AC_DST_NO_ALPHA = $20;

  const
    IEI_PRIORITY_MAX     = $0002;
    IEI_PRIORITY_MIN     = $0001;
    IEI_PRIORITY_NORMAL  = $0000;

    IEIFLAG_ASYNC    = $0001;     // ask the extractor if it supports ASYNC extract (free threaded)
    IEIFLAG_CACHE    = $0002;     // returned from the extractor if it does NOT cache the thumbnail
    IEIFLAG_ASPECT   = $0004;     // passed to the extractor to beg it to render to the aspect ratio of the supplied rect
    IEIFLAG_OFFLINE  = $0008;     // if the extractor shouldn't hit the net to get any content neede for the rendering
    IEIFLAG_GLEAM    = $0010;     // does the image have a gleam ? this will be returned if it does
    IEIFLAG_SCREEN   = $0020;     // render as if for the screen  (this is exlusive with IEIFLAG_ASPECT )
    IEIFLAG_ORIGSIZE = $0040;     // render to the approx size passed, but crop ifneccessary
    IEIFLAG_QUALITY  = $0200;


  type
    IExtractImage = interface
      ['{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}']
      function GetLocation(pszPathBuffer :PWideChar; cch :DWORD; var pdwPriority :DWORD;
        var prgSize :TSize; dwRecClrDepth :DWORD; var pdwFlags :DWORD) :HResult; stdcall;
      function Extract(var phBmpThumbnail: HBITMAP): HResult; stdcall;
    end;

    SIGDN = DWORD;
    SICHINTF = DWORD;
    SFGAOF = ULONG;

    IShellItem = interface
      ['{43826d1e-e718-42ee-bc55-a1e261c37bfe}']
      function BindToHandler(pbc : IBindCtx; rbhid : TGUID; riid : TIID; var ppvOut : Pointer) : HResult; stdcall;
      function GetParent(var ppsi : IShellItem) : HResult; stdcall;
      function GetDisplayName(sigdnName : SIGDN; var ppszName : POLESTR) : HResult; stdcall;
      function GetAttributes(sfgaoMask : SFGAOF; var psfgaoAttribs : SFGAOF) : HResult; stdcall;
      function Compare(psi : IShellItem; hint : SICHINTF; var piOrder : integer) : HResult; stdcall;
    end;


 {-----------------------------------------------------------------------------}
 { Vista extensions                                                            }

  const
    CLSID_ThumbnailCache :TGUID = '{50EF4544-AC9F-4A8E-B21B-8A26180DB13F}';

{
enum WTS_FLAGS {
  WTS_NONE                  = 0x00000000,
  WTS_EXTRACT               = 0x00000000,
  WTS_INCACHEONLY           = 0x00000001,
  WTS_FASTEXTRACT           = 0x00000002,
  WTS_FORCEEXTRACTION       = 0x00000004,
  WTS_SLOWRECLAIM           = 0x00000008,
  WTS_EXTRACTDONOTCACHE     = 0x00000020,
  WTS_SCALETOREQUESTEDSIZE  = 0x00000040,
  WTS_SKIPFASTEXTRACT       = 0x00000080,
  WTS_EXTRACTINPROC         = 0x00000100,
  WTS_CROPTOSQUARE          = 0x00000200,
  WTS_INSTANCESURROGATE     = 0x00000400,
  WTS_REQUIRESURROGATE      = 0x00000800,
  WTS_APPSTYLE              = 0x00002000,
  WTS_WIDETHUMBNAILS        = 0x00004000,
  WTS_IDEALCACHESIZEONLY    = 0x00008000,
  WTS_SCALEUP               = 0x00010000
}
  const
    WTS_EXTRACT	          = $00;
    WTS_INCACHEONLY	  = $01;
    WTS_FASTEXTRACT	  = $02;
    WTS_FORCEEXTRACTION	  = $04;
    WTS_SLOWRECLAIM	  = $08;
    WTS_EXTRACTDONOTCACHE = $20;

    WTSAT_UNKNOWN	  = $00;
    WTSAT_RGB	          = $01;
    WTSAT_ARGB	          = $02;

  type
    PSharedBitmap = ^ISharedBitmap;
    ISharedBitmap = interface
      ['{091162a4-bc96-411f-aae8-c5122cd03363}']
      function GetSharedBitmap(var phbmp :HBitmap) :HResult; stdcall;
      function GetSize(var size :TSize) :HResult; stdcall;
      function GetFormat(var pat :DWORD) :HResult; stdcall;
      function InitializeBitmap(hbm :HBitmap; wtsAT :DWORD) :HResult; stdcall;
      function Detach(var phbmp :HBitmap) :HResult; stdcall;
    end;

    PTHUMBNAILID = ^TTHUMBNAILID;
    TTHUMBNAILID = array[0..15] of byte;

    IThumbnailCache = interface
      ['{F676C15D-596A-4ce2-8234-33996F445DB1}']
      function GetThumbnail(AItem :IShellItem; cxyRequestedThumbSize :UINT; flags :DWORD;
        AThumb :PSharedBitmap; var pOutFlags :DWORD; pThumbnailID :PTHUMBNAILID ) :HResult; stdcall;
      function GetThumbnailByID( {???}thumbnailID :TTHUMBNAILID; cxyRequestedThumbSize :UINT;
        AThumb :PSharedBitmap; var pOutFlags :DWORD) :HResult; stdcall;
    end;


//function SHCreateItemFromParsingName(pszPath :LPCWSTR; pbc :IBindCtx; const riid :TIID; ppv :Pointer) :HResult; stdcall;
//  external shell32 name 'SHCreateItemFromParsingName';

  var
    SHCreateItemFromParsingName :function(pszPath :LPCWSTR; pbc :IBindCtx; const riid :TIID; ppv :Pointer) :HResult; stdcall = nil;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

  var
    DLLHandle: THandle;


  procedure LoadDLL;
  begin
    DLLHandle := LoadLibrary('SHELL32.DLL');
    if DLLHandle >= 32 then begin
      SHCreateItemFromParsingName  := GetProcAddress(DLLHandle, 'SHCreateItemFromParsingName');
    end;
  end;


  procedure UnLoadDLL;
  begin
    if DLLHandle <> 0 then begin
      FreeLibrary(DLLHandle);
      DLLHandle := 0;
    end;
  end;


initialization
  LoadDLL;
finalization
  UnLoadDLL;
end.

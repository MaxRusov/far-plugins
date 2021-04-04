{$I Defines.inc}

unit PVApi;

// ��������� PVD ��������-���������, v1.0 / v2.0
// v1.0: ��������� ���� ���������� �����: UTF-8.

// Copyright (c) Skakov Pavel

// Copyright (c) Maximus5,
// http://code.google.com/p/conemu-maximus5

interface

uses
  Windows;

const
  // ������ ���������� PVD, ����������� ���� ������������ ������.
  // ������ ��� �������� ������������� ���������� � pvdInit ��� �������� �������������.
  PVD_CURRENT_INTERFACE_VERSION = 1;
  // ������ ��� �������� ������������� ���������� � pvdInit2 ��� �������� �������������.
  PVD_UNICODE_INTERFACE_VERSION = 2;

const
  // ����� ������ ���������� (������ ������ 2 ����������)
  PVD_IP_DECODE     = 1;         // ������� (��� ������ 1)
  PVD_IP_TRANSFORM  = 2;         // �������� ������� ��� Lossless transform (��������� � ����������)
  PVD_IP_DISPLAY    = 4;         // ����� ���� ����������� ������ ���������� � PicView ��������� DX (��������� � ����������)
  PVD_IP_PROCESSING = 8;         // PostProcessing operations (��������� � ����������)

  PVD_IP_MULTITHREAD   = $100;   // ������� ����� ���������� ������������ � ������ �����
  PVD_IP_ALLOWCACHE    = $200;   // PicView ����� ���������� ����� �� �������� pvdFileClose2 ��� ����������� �������������� �����������
  PVD_IP_CANREFINE     = $400;   // ������� ������������ ���������� ��������� (��������)
  PVD_IP_CANREFINERECT = $800;   // ������� ������������ ���������� ��������� (��������) ��������� �������
  PVD_IP_CANREDUCE     = $1000;  // ������� ����� ��������� ������� ����������� � ����������� ���������
  PVD_IP_NOTERMINAL    = $2000;  // ���� ������ ������� ������ ������������ � ������������ ��������
  PVD_IP_PRIVATE       = $4000;  // ����� ����� ������ � ��������� (PVD_IP_DECODE|PVD_IP_DISPLAY).
                                 // ���� ��������� �� ����� ���� ����������� ��� ������������� ������ ������
                                 // �� ����� ���������� ������ ��, ��� ����������� ���
  PVD_IP_DIRECT        = $8000;  // "�������" ������ ������. ��������, ����� ����� DirectX.
  PVD_IP_FOLDER        = $10000; // ������ ����� ���������� Thumbnail ��� ����� (a'la ��������� Windows � ������ �������)
  PVD_IP_CANDESCALE    = $20000; // �������������� ��������� � ������ ����������
  PVD_IP_CANUPSCALE    = $40000; // �������������� ��������� � ������ ����������

  // Review:
  PVD_IP_NEEDFILE    = $1000000; // �� ��������� ��������������� ����������� ����� - ������ ��� ������ ���

{ �����, ������������ pvdFileOpen/pvdFileOpen2 }
const
  // ������������� ��������������� �����������
  PVD_IIF_ANIMATED   = 1;
  // ���� ������� ������������ ���������� ��������� (��������) ��������� �������
  PVD_IIF_CAN_REFINE = 2;
  // ��������������� ���������, ���� ��������� ������� ����������� ����� (� ������� ������� �������� �� �����)
  PVD_IIF_FILE_REQUIRED = 4;
  // ��������������� ����������� ������������ ����� ����� ��� �������
  // ������ ����� ������ �������� �������� �������, � ����� ������� ��������� (����� � ������ ��������)
  PVD_IIF_MAGAZINE = $100;

  // Review:
  PVD_IIF_MOVIE  = $1000;         // ����� ����. nPages �������� ������������ ����� � ��.
  PVD_IIF_VECTOR = $2000;         //


{ ����� ���������� ��� ������������ pvdPageDecode/pvdPageDecode2 }
const
  // ������ ��������������� ����������� �������� ������ ��� ������
  PVD_IDF_READONLY          = 1;
  // **** ��������� ����� ������������ ������ �� 2-� ������ ����������
  // pImage �������� 32���� �� ������� � ������� ���� �������� ����� �������
  PVD_IDF_ALPHA             = 2;   // ��� ������� � �������� - ������� ���� ������� �� �������
  // ���� �� ������ (��������� ���������� ��� � pvdInfoDecode2.TransparentColor) ������� ���������� (������ ������ 2 ����������)
  PVD_IDF_TRANSPARENT       = 4;   // pvdInfoDecode2.TransparentColor �������� COLORREF ����������� �����
  PVD_IDF_TRANSPARENT_INDEX = 8;   // pvdInfoDecode2.TransparentColor �������� ������ ����������� �����
  PVD_IDF_ASDISPLAY         = 16;  // ��������� �������� �������� ������� ������ (����� �� ���������� ������ �����������)
  PVD_IDF_PRIVATE_DISPLAY   = 32;  // "����������" �������������, ������� ����� ���� ������������ ��� ������
                                   // ������ ���� �� ����������� (� ������� ������ ���� ���� PVD_IP_DISPLAY)
  PVD_IDF_COMPAT_MODE       = 64;  // ������ ������ ������ ������ � ������ ������������� � ������ (����� PVD1Helper.cpp)

  // Review:
  PVD_IDF_RETURN_BITMAP     = 128; // OUT: ������ ���������� HBitmap (� lParam)

  // Review:
  PVD_IDF_THUMBONLY         = $1000;  // IN: ��������� �����, ���� ����, ����� ������� 0
  PVD_IDF_THUMBFIRST        = $2000;  // IN: ��������� �����, ���� ����, ����� - ���� �����������
  PVD_IDF_THUMBNAIL         = $10000; // OUT: �������� �����

{pvdColorModel}
const
  // ������ ��������� ������ "PVD_CM_BGR" � "PVD_CM_BGRA"
  PVD_CM_UNKNOWN =  0;  // -- ����� ����������� ������ ����� �� ����� �������� ��������
  PVD_CM_GRAY    =  1;  // "Gray scale"  -- UNSUPPORTED !!!
  PVD_CM_AG      =  2;  // "Alpha_Gray"  -- UNSUPPORTED !!!
  PVD_CM_RGB     =  3;  // "RGB"         -- UNSUPPORTED !!!
  PVD_CM_BGR     =  4;  // "BGR"
  PVD_CM_YCBCR   =  5;  // "YCbCr"       -- UNSUPPORTED !!!
  PVD_CM_CMYK    =  6;  // "CMYK"
  PVD_CM_YCCK    =  7;  // "YCCK"        -- UNSUPPORTED !!!
  PVD_CM_YUV     =  8;  // "YUV"         -- UNSUPPORTED !!!
  PVD_CM_BGRA    =  9;  // "BGRA"
  PVD_CM_RGBA    = 10;  // "RGBA"        -- UNSUPPORTED !!!
  PVD_CM_ABRG    = 11;  // "ABRG"        -- UNSUPPORTED !!!
  PVD_CM_PRIVATE = 12;  // ������ ���� �������==������� � ���� �� ������������

{pvdOrientation}
const
  PVD_Ornt_Default      = 0;
  PVD_Ornt_TopLeft      = 1; // The 0th row is at the visual top of the image, and the 0th column is the visual left-hand side.
  PVD_Ornt_TopRight     = 2; // The 0th row is at the visual top of the image, and the 0th column is the visual right-hand side.
  PVD_Ornt_BottomRight  = 3; // The 0th row is at the visual bottom of the image, and the 0th column is the visual right-hand side.
  PVD_Ornt_BottomLeft   = 4; // The 0th row is at the visual bottom of the image, and the 0th column is the visual left-hand side.
  PVD_Ornt_LeftTop      = 5; // The 0th row is the visual left-hand side of the image, and the 0th column is the visual top.
  PVD_Ornt_RightTop     = 6; // The 0th row is the visual right-hand side of the image, and the 0th column is the visual top.
  PVD_Ornt_RightBottom  = 7; // The 0th row is the visual right-hand side of the image, and the 0th column is the visual bottom.
  PVD_Ornt_LeftBottom   = 8; // The 0th row is the visual left-hand side of the image, and the 0th column is the visual bottom.


(*
// pvdInitPlugin2 - ��������� ������������� ����������
struct pvdInitPlugin2
{
  UINT32 cbSize;               // [IN]  ������ ��������� � ������
  UINT32 nMaxVersion;          // [IN]  ������������ ������ ����������, ������� ����� ���������� PictureView
  const wchar_t *pRegKey;      // [IN]  ���� �������, � ������� ��������� ����� ������� ���� ���������.
                               //       �������� ��� ���������� pvd_bmp.pvd ���� ���� ����� �����
                               //       "Software\\Far2\\Plugins\\PictureView\\pvd_bmp.pvd"
                               //       ����������� � HKEY_CURRENT_USER.
                               //       ���������� ������������� ����� ������� ������������� �������� (����
                               //       ��� ���� ��� �����������), ����� ��� PicView ��� ���� ������������
                               //       ����������� ��������� ��� ��������.
  DWORD  nErrNumber;           // [OUT] ���������� (��� ����������) ��� ������ �������������
                               //       ���������� ���������� �������������� ������� pvdTranslateError2
  void  *pContext;             // [OUT] ��������, ������������ ��� ��������� � ����������

  // Some helper functions
  void  *pCallbackContext;     // [IN]  ��� �������� ������ ���� �������� � �������, ������ ����
  // 0-����������, 1-��������������, 2-������
  void (__stdcall* MessageLog)(void *pCallbackContext, const wchar_t* asMessage, UINT32 anSeverity);
  // asExtList ����� ��������� '*' (����� ������ TRUE) ��� '.' (TRUE ���� asExt �����). ��������� �������������������
  BOOL (__stdcall* ExtensionMatch)(wchar_t* asExtList, const wchar_t* asExt);
  //
  HMODULE hModule;             // [IN]  HANDLE ����������� ����������

  BOOL (__stdcall* CallSehed)(pvdCallSehedProc2 CalledProc, LONG_PTR Param1, LONG_PTR Param2, LONG_PTR* Result);
  int (__stdcall* SortExtensions)(wchar_t* pszExtensions);
  int (__stdcall* MulDivI32)(int a, int b, int c);  // (__int64)a * b / c;
  UINT (__stdcall* MulDivU32)(UINT a, UINT b, UINT c);  // (uint)((unsigned long long)(a)*(b)/(c))
  UINT (__stdcall* MulDivU32R)(UINT a, UINT b, UINT c);  // (uint)(((unsigned long long)(a)*(b) + (c)/2)/(c))
  int (__stdcall* MulDivIU32R)(int a, UINT b, UINT c);  // (int)(((long long)(a)*(b) + (c)/2)/(c))
//PRAGMA_ERROR("�������� ������� ������������� PNG. ����� ��������� ����� �� ICO.PVD �� � �� ������������ gdi+ ��� �������� CMYK");
  UINT32 Flags;                // [IN] ��������� �����: PVD_IPF_xxx
};
*)
type
  PPVDInitPlugin2 = ^TPVDInitPlugin2;
  TPVDInitPlugin2 = record
    cbSize :UINT;
    nMaxVersion :UINT;
    pRegKey :PWideChar;
    nErrNumber :DWORD;
    pContext :Pointer;
    pCallbackContext :Pointer;
    MessageLog :Pointer;
    ExtensionMatch :Pointer;
    hModule :THandle;

    CallSehed :Pointer;
    SortExtensions :Pointer;
    MulDivI32 :Pointer;
    MulDivU32 :Pointer;
    MulDivU32R :Pointer;
    MulDivIU32R :Pointer;

    Flags :UINT;
  end;


(*
// pvdInfoPlugin - ���������� � �������
struct pvdInfoPlugin
{
  UINT32 Priority;          // ��������� �������; ���� 0, �� ������ �� ����� ���������� � �������� �����������������
  const char *pName;        // ��� �������
  const char *pVersion;     // ������ �������
  const char *pComments;    // ����������� � �������: ��� ���� ������������, ��� ����� �������, ...
};
*)
type
  PPVDInfoPlugin = ^TPVDInfoPlugin;
  TPVDInfoPlugin = record
    Priority :UINT;
    pName :PAnsiChar;
    pVersion :PAnsiChar;
    pComments :PAnsiChar;
  end;

(*
struct pvdInfoPlugin2
{
  UINT32 cbSize;               // [IN]  ������ ��������� � ������
  UINT32 Flags;                // [OUT] ��������� ����� PVD_IP_xxx
  const wchar_t *pName;        // [OUT] ��� ����������
  const wchar_t *pVersion;     // [OUT] ������ ����������
  const wchar_t *pComments;    // [OUT] ����������� � ����������: ��� ���� ������������, ��� ����� ����������, ...
  UINT32 Priority;             // [OUT] ��������� ����������; ������������ ������ ��� ����� ����������� ��� ������������
                               //       ������ ���������. ��� ���� Priority ��� ���� � ������ �� ����� ��������.
  HMODULE hModule;             // [IN]  HANDLE ����������� ����������
};
*)
type
  PPVDInfoPlugin2 = ^TPVDInfoPlugin2;
  TPVDInfoPlugin2 = record
    cbSize :UINT;
    Flags :UINT;
    pName :PWideChar;
    pVersion :PWideChar;
    pComments :PWideChar;
    Priority :UINT;
    hModule :THandle;
  end;

(*
struct pvdFormats2
{
  UINT32 cbSize;		 // [IN]  ������ ��������� � ������
  const wchar_t *pActive;	 // [OUT] ������ �������� ���������� ����� �������.
				 //	  ��� ����������, ������� ������ ����� "������" ���������.
				 //       ����� ����������� �������� "*" ����������, ���
				 //       ��������� �������� �������������.
				 //       ���� ��� ������������� �� ���� �� ����������� �� ������� �� ���������� -
				 //       PicView ��� ����� ���������� ������� ���� �����������, ���� ����������
				 //       �� ������� � ������ ��� �����������.
   const wchar_t *pForbidden;	 // [OUT] ������ ������������ ���������� ����� �������.
				 //       ��� ������ � ���������� ������������ ��������� ��
				 //       ����� ���������� ������. ������� "." ��� �������������
				 //       ������ ��� ����������.
   const wchar_t *pInactive;	 // [OUT] ������ ���������� ���������� ����� �������.
				 //       ����� ����������� ����������, ������� ������ ����� �������
				 //       "� ��������", �� ��������, � ����������.
   // !!! ������ �������� "����������". ������������ ����� ������������� ������ ����������.
};
*)
type
  PPVDFormats2 = ^TPVDFormats2;
  TPVDFormats2 = record
    cbSize :UINT;
    pSupported :PWideChar;
    pIgnored :PWideChar;
    pInactive :PWideChar;
  end;


(*
// pvdInfoImage - ���������� � �����
struct pvdInfoImage
{
  UINT32 nPages;            // ���������� ������� �����������
  UINT32 Flags;             // ��������� �����: PVD_IIF_ANIMATED
  const char *pFormatName;  // �������� ������� �����
  const char *pCompression; // �������� ������
  const char *pComments;    // ��������� ����������� � �����
};
*)
type
  PPVDInfoImage = ^TPVDInfoImage;
  TPVDInfoImage = record
    nPages :UINT;
    Flags :UINT;
    pFormatName :PAnsiChar;
    pCompression :PAnsiChar;
    pComments :PAnsiChar;
  end;

(*
struct pvdInfoImage2
{
  UINT32 cbSize;               // [IN]  ������ ��������� � ������
  void   *pImageContext;       // [IN]  ��� ������ �� pvdFileOpen2 ����� ���� �� NULL,
                               //       ���� ������ ������������ ������� pvdFileDetect2
                               // [OUT] ��������, ������������ ��� ��������� � �����
  UINT32 nPages;               // [OUT] ���������� ������� �����������
                               //       ��� ������ �� pvdFileDetect2 ���������� �������������
  UINT32 Flags;                // [OUT] ��������� �����: PVD_IIF_xxx
                               //       ��� ������ �� pvdFileDetect2 �������� ���� PVD_IIF_FILE_REQUIRED
  const wchar_t *pFormatName;  // [OUT] �������� ������� �����
                               //       ��� ������ �� pvdFileDetect2 ���������� �������������, �� ����������
  const wchar_t *pCompression; // [OUT] �������� ������
                               //       ��� ������ �� pvdFileDetect2 ���������� �������������
  const wchar_t *pComments;    // [OUT] ��������� ����������� � �����
                               //       ��� ������ �� pvdFileDetect2 ���������� �������������
  DWORD  nErrNumber;           // [OUT] ���������� �� ������ �������������� ������� �����
                               //       ���������� ���������� �������������� ������� pvdTranslateError2
                               //       ��� �������� ���� (< 0x7FFFFFFF) PicView ������� ���
                               //       ���������� ������ ���������� ���� ������ �����. PicView
                               //       �� ����� ���������� ��� ������ ������������, ���� ������
                               //       ������� ���� �����-�� ������ �����������-���������.
  DWORD nReserved, nReserver2;
};

// pvdFileOpen - �������� �����: ��������� ������, ����� �� �� ������������ ����, � ��������� ����� ���������� � �����
//  ����������: ��� �������� �����
//  ���������:
//   pFileName   - ��� ������������ �����
//   lFileSize   - ����� ������������ ����� � ������. ���� 0, �� ���� �����������, � ���������� ���������� pBuf �����
//                 �������� ��� ��������� ������ � ����� �������� ������ �� ������ pvdFileClose.
//   pBuf        - �����, ���������� ������ ������������ �����
//   lBuf        - ����� ������ pBuf � ������. ������������� ������������� �� ����� 16 ��.
//   pImageInfo  - ��������� �� ��������� � ����������� � ����� ��� ���������� �����������, ���� �� ����� ������������ ����
//   ppImageContext - ��������� �� ��������. ����� ���� �������� ��������� ����� ������� �������� - ������������ ��������,
//                 ������� ����� ������������ ��� ��� ������ ������ ������� ������ � ������ ������. ������� ����� �
//                 ����, ��� ����� ����������� ������� � ���� ������ ������� ����� �������������� ��������� ������,
//                 ������� ������������� ������������ ��������, � �� ���������� ���������� ���������� �������.
//  ������������ ��������: TRUE - ���� ��������� ����� ������������ ��������� ����; ����� - FALSE

BOOL __stdcall pvdFileOpen2(void *pContext, const wchar_t *pFileName, INT64 lFileSize, const BYTE *pBuf, UINT32 lBuf, pvdInfoImage2 *pImageInfo);
*)
type
  PPVDInfoImage2 = ^TPVDInfoImage2;
  TPVDInfoImage2 = record
    cbSize :UINT;
    pImageContext :Pointer;
    nPages :UINT;
    Flags :UINT;
    pFormatName :PWideChar;
    pCompression :PWideChar;
    pComments :PWideChar;
    nErrNumber :DWORD;
    nReserverd, nReserverd2 :DWORD;
  end;


(*
// pvdInfoPage - ���������� � �������� �����������
struct pvdInfoPage
{
  UINT32 lWidth;            // ������ ��������
  UINT32 lHeight;           // ������ ��������
  UINT32 nBPP;              // ���������� ��� �� ������� (������ �������������� ���� - � ��������� �� ������������)
  UINT32 lFrameTime;        // ��� ������������� ����������� - ������������ ����������� �������� � �������� �������;
                            // ����� - �� ������������
};
*)
type
  PPVDInfoPage = ^TPVDInfoPage;
  TPVDInfoPage = record
    lWidth :UINT;
    lHeight :UINT;
    nBPP :UINT;
    lFrameTime :UINT;
  end;

(*
struct pvdInfoPage2
{
  UINT32 cbSize;            // [IN]  ������ ��������� � ������
  UINT32 iPage;             // [IN]  ����� �������� (0-based)
  UINT32 lWidth;            // [OUT] ������ ��������
  UINT32 lHeight;           // [OUT] ������ ��������
  UINT32 nBPP;              // [OUT] ���������� ��� �� ������� (������ �������������� ���� - � �������� �� ������������)
  UINT32 lFrameTime;        // [OUT] ��� ������������� ����������� - ������������ ����������� �������� � �������� �������;
                            //       ����� - �� ������������
  // Plugin output
  DWORD  nErrNumber;           // [OUT] ���������� �� ������
                           //       ���������� ���������� �������������� ������� pvdTranslateError2
  UINT32 nPages;               // [OUT] 0, ��� ������ ����� ��������������� ���������� ������� �����������
  const wchar_t *pFormatName;  // [OUT] NULL ��� ������ ����� ��������������� �������� ������� �����
  const wchar_t *pCompression; // [OUT] NULL ��� ������ ����� ��������������� �������� ������
};
*)
type
  PPVDInfoPage2 = ^TPVDInfoPage2;
  TPVDInfoPage2 = record
    cbSize :UINT;
    iPage :UINT;
    lWidth :UINT;
    lHeight :UINT;
    nBPP :UINT;
    lFrameTime :UINT;
    nErrNumber :DWORD;
    nPages :UINT;
    pFormatName :PWideChar;
    pCompression :PWideChar;
    Orientation :byte;               { Review v.13}
  end;


(*
// pvdInfoDecode - ���������� � �������������� �����������
struct pvdInfoDecode
{
  BYTE   *pImage;            // ��������� �� ������ ����������� � ������� RGB
  UINT32 *pPalette;          // ��������� �� ������� �����������, ������������ � �������� 8 � ������ ��� �� �������
  UINT32 Flags;              // ��������� �����: PVD_IDF_READONLY
  UINT32 nBPP;               // ���������� ��� �� ������� � �������������� �����������
  UINT32 nColorsUsed;        // ���������� ������������ ������ � �������; ���� 0, �� ������������ ��� ��������� �����
  INT32  lImagePitch;        // ������ - ����� ������ ��������������� ����������� � ������;
                             // ������������� �������� - ������ ���� ������ ����, ������������� - ����� �����
};
*)
type
  PPVDInfoDecode = ^TPVDInfoDecode;
  TPVDInfoDecode = record
    pImage :Pointer;
    pPalette :Pointer;
    Flags :UINT;
    nBPP :UINT;
    nColorsUsed :UINT;
    lImagePitch :Integer;
  end;

(*
struct pvdInfoDecode2
{
  UINT32 cbSize;             // [IN]  ������ ��������� � ������
  UINT32 iPage;              // [IN]  ����� ������������ �������� (0-based)
  UINT32 lWidth, lHeight;    // [IN]  ������������� ������ ��������������� ����������� (���� ������� ������������ ������������)
                             // [OUT] ������ �������������� ������� (pImage)
  UINT32 nBPP;               // [IN]  PicView ����� ��������� ���������������� ������ (���� �� ������������)
                             // [OUT] ���������� ��� �� ������� � �������������� �����������
                             //       ��� ������������� 32 ��� ����� ���� ������ ���� PVD_IDF_ALPHA
                             //       PicView �� ���������� ��� �������� ������������ - � ���������
                             //       ��������� pvdInfoPage2.nBPP, ��� ��� ����� �������� ������ ��������������
  INT32  lImagePitch;        // [OUT] ������ - ����� ������ ��������������� ����������� � ������;
                             //       ������������� �������� - ������ ���� ������ ����, ������������� - ����� �����
  UINT32 Flags;              // [IN]  PVD_IDF_ASDISPLAY | PVD_IDF_COMPAT_MODE
                             // [OUT] ��������� �����: PVD_IDF_*
  union {
  RGBQUAD TransparentColor;  // [OUT] if (Flags&PVD_IDF_TRANSPARENT) - �������� ����, ������� ��������� ����������
  DWORD  nTransparentColor;  //       if (Flags&PVD_IDF_TRANSPARENT_INDEX) - �������� ������ ����������� �����
  };                         // ��������! ��� �������� ����� PVD_IDF_ALPHA - Transparent ������������

  BYTE   *pImage;            // [OUT] ��������� �� ������ ����������� � ���������� �������
                             //       ������ ������� �� nBPP
                             //       1,4,8 ��� - ������ � ��������
                             //       16 ��� - ������ ��������� ����� ������� �� 5 ��� (BGR)
                             //       24 ��� - 8 ��� �� ��������� (BGR)
                             //       32 ��� - 8 ��� �� ��������� (BGR ��� BGRA ��� �������� PVD_IDF_ALPHA)
  UINT32 *pPalette;          // [OUT] ��������� �� ������� �����������, ������������ � �������� 8 � ������ ��� �� �������
  UINT32 nColorsUsed;        // [OUT] ���������� ������������ ������ � �������; ���� 0, �� ������������ ��� ��������� �����
                             //       (���� �� ������������, ������� ������ ��������� [1<<nBPP] ������)

  DWORD  nErrNumber;         // [OUT] ���������� �� ������ �������������
                             //       ���������� ���������� �������������� ������� pvdTranslateError2

  LPARAM lParam;             // [OUT] ��������� ����� ������������ ��� ���� �� ���� ����������

  pvdColorModel  ColorModel; // [OUT] ������ �������������� ������ PVD_CM_BGR & PVD_CM_BGRA
  DWORD          Precision;  // [RESERVED] bits per channel (8,12,16bit)
  POINT          Origin;     // [RESERVED] m_x & m_y; Interface apl returns m_x=0; m_y=Ymax;
  float          PAR;        // [RESERVED] Pixel aspect ratio definition
  pvdOrientation Orientation;// [RESERVED]
  UINT32 nPages;             // [OUT] 0, ��� ������ ����� ��������������� ���������� ������� �����������
  const wchar_t *pFormatName;  // [OUT] NULL ��� ������ ����� ��������������� �������� ������� �����
  const wchar_t *pCompression; // [OUT] NULL ��� ������ ����� ��������������� �������� ������
  union {
          RGBQUAD BackgroundColor; // [IN] ������� ����� ������������ ��� ���� ��� ����������
          DWORD  nBackgroundColor; //      ���������� �����������
  };
  UINT32 lSrcWidth,          // [OUT] ������� ����� �������� ������ ��������� �����������. ������ ���� ������
         lSrcHeight;         // [OUT] ����� ������� � ��������� ���� (����� TitleTemplate). ���� ��������� ��
                             //       �� ��������� - ����������� {0,0}.
};

// pvdPageDecode - ������������� �������� �����������
//  ����������: ����� ������� pvdFileOpen � pvdFileClose
//  ���������:
//   pImageContext  - ��������, ������������ ����������� � pvdFileOpen
//   iPage          - ����� �������� ����������� (��������� ���������� � 0)
//   pDecodeInfo    - ��������� �� ��������� � ����������� � �������������� ����������� ��� ���������� �����������
//   DecodeCallback - ��������� �� �������, ����� ������� ��������� ����� ������������� ���������� ��������� � ����
//                    �������������; NULL, ���� ����� ������� �� ���������������
//   pDecodeCallbackContext - ��������, ������������ � DecodeCallback
//  ������������ ��������: TRUE - ��� �������� ����������; ����� - FALSE
//  �������������� ��������� ������ 2:
//   pContext      - ��������, ������������ ����������� � pvdInit2
//   pImageContext - ��������, ������������ ����������� � pvdFileOpen2
BOOL __stdcall pvdPageDecode2(void *pContext, void *pImageContext, pvdInfoDecode2 *pDecodeInfo,
							  pvdDecodeCallback2 DecodeCallback, void *pDecodeCallbackContext);
*)
type
  PPVDInfoDecode2 = ^TPVDInfoDecode2;
  TPVDInfoDecode2 = packed record
    cbSize :UINT;
    iPage :UINT;
    lWidth :UINT;
    lHeight :UINT;
    nBPP :UINT;
    lImagePitch :Integer;
    Flags :UINT;
    nTransparentColor :DWORD;
    pImage :Pointer;
    pPalette :Pointer;
    nColorsUsed :UINT;
    nErrNumber :DWORD;
    lParam :LPARAM;
    ColorModel :byte; {PPVDColorModel}
    Precision :DWORD;
    Origin :TPoint;
    PAR :Extended; {???}
    Orientation :byte; {PPVDOrientation}
    nPages :UINT;
    pFormatName :PWideChar;
    pCompression :PWideChar;
    nBackgroundColor :DWORD;
    lSrcWidth :UINT;
    lSrcHeight :UINT;
    lSrcBPP :UINT;                   { Review v.12}
  end;

(*
struct pvdInfoDisplayInit2
{
	UINT32 cbSize;               // [IN]  ������ ��������� � ������
	HWND hWnd;                   // [IN]
	DWORD nCMYKparts;
	DWORD *pCMYKpalette;
	DWORD nCMYKsize;
	DWORD uCMYK2RGB;
	DWORD nErrNumber;            // [OUT]
};
*)
type
  PPVDInfoDisplayInit2 = ^TPVDInfoDisplayInit2;
  TPVDInfoDisplayInit2 = record
    cbSize :UINT;
    hWnd :HWND;
    nCMYKparts :DWORD;
    pCMYKpalette :Pointer;
    nCMYKsize :DWORD;
    uCMYK2RGB :DWORD;
    nErrNumber :DWORD;
  end;

(*
struct pvdInfoDisplayAttach2
{
	UINT32 cbSize;               // [IN]  ������ ��������� � ������
	HWND hWnd;                   // [IN]  ���� ����� ���� �������� � �������� ������
	BOOL bAttach;                // [IN]  ����������� ��� ���������� �� hWnd
	DWORD nErrNumber;            // [OUT]
};
*)
type
  PPVDInfoDisplayAttach2 = ^TPVDInfoDisplayAttach2;
  TPVDInfoDisplayAttach2 = record
    cbSize :UINT;
    hWnd :HWND;
    bAttach :BOOL;
    nErrNumber :DWORD;
  end;

(*
struct pvdInfoDisplayCreate2
{
	UINT32 cbSize;               // [IN]  ������ ��������� � ������
	pvdInfoDecode2* pImage;      // [IN]
	DWORD BackColor;             // [IN]  RGB background
	void* pDisplayContext;       // [OUT]
	DWORD nErrNumber;            // [OUT]
	const wchar_t* pFileName;    // [IN]  Information only. Valid only in pvdDisplayCreate2
	UINT32 iPage;                // [IN]  Information only
};
*)
type
  PPVDInfoDisplayCreate2 = ^TPVDInfoDisplayCreate2;
  TPVDInfoDisplayCreate2 = record
    cbSize :UINT;
    pImage :PPVDInfoDecode2;
    BackColor :DWORD;
    pDisplayContext :Pointer;
    nErrNumber :DWORD;
    pFileName :PWideChar;
    iPage :UINT;
  end;


const
  PVD_IDP_BEGIN     = 1;
  PVD_IDP_PAINT     = 2;
  PVD_IDP_COLORFILL = 3;
  PVD_IDP_COMMIT    = 4;

(*
struct pvdInfoDisplayPaint2
{
	UINT32 cbSize;               // [IN]  ������ ��������� � ������
	DWORD Operation;  // PVD_IDP_*
	HWND hWnd;                   // [IN]  ��� ��������
	HWND hParentWnd;             // [IN]
	union {
	RGBQUAD BackColor;  //
	DWORD  nBackColor;  //
	};
	RECT ImageRect;
	RECT DisplayRect;

	LPVOID pDrawContext; // ��� ���� ����� �������������� ����������� ��� �������� "HDC". ����������� ������ ��������� �� ������� PVD_IDP_COMMIT

	//RECT ParentRect;
	////DWORD BackColor;             // [IN]  RGB background
	//BOOL bFreePosition;
	//BOOL bCorrectMousePos;
	//POINT ViewCenter;
	//POINT DragBase;
	//UINT32 Zoom;
	//RECT rcGlobal;               // [IN]  � ����� ����� ���� ����� �������� ����������� (��������� ���������� ����� BackColor)
	//RECT rcCrop;                 // [IN]  ������������� ��������� (���������� ����� ����)
	DWORD nErrNumber;            // [OUT]
	
	DWORD nZoom; // [IN] ���������� ������ ��� ����������. 0x10000 == 100%
	DWORD nFlags; // [IN] PVD_IDPF_*
	
	DWORD *pChessMate;
	DWORD uChessMateWidth;
	DWORD uChessMateHeight;
};
*)
type
  PPVDInfoDisplayPaint2 = ^TPVDInfoDisplayPaint2;
  TPVDInfoDisplayPaint2 = record
    cbSize :UINT;
    Operation :DWORD;
    hWnd :HWND;
    hParentWnd :HWND;
    nBackColor :DWORD;
    ImageRect :TRECT;
    DisplayRect :TRECT;
    pDrawContext :Pointer;
    nErrNumber :DWORD;
    nZoom :DWORD;
    nFlags :DWORD;
    pChessMate :Pointer;
    uChessMateWidth :DWORD;
    uChessMateHeight :DWORD;
  end;

(*
// pvdDecodeCallback - �������, ��������� �� ������� ��������� � pvdPageDecode
//  ����������: �������� �� pvdPageDecode
//   �� �����������, �� ������������� ������������ ��������, ���� ������������� ����� ������ ���������� �����.
//  ���������:
//   pDecodeCallbackContext - ��������, ���������� ��������������� ���������� pvdPageDecode
//   iStep  - ����� �������� ���� ������������� (��������� �� 0 �� nSteps - 1)
//   nSteps - ����� ���������� ����� �������������
//  ������������ ��������: TRUE - ����������� �������������; FALSE - ������������� ������� ��������
typedef BOOL (__stdcall *pvdDecodeCallback)(void *pDecodeCallbackContext, UINT32 iStep, UINT32 nSteps);
typedef BOOL (__stdcall *pvdDecodeCallback2)(void *pDecodeCallbackContext2, UINT32 iStep, UINT32 nSteps, pvdInfoDecodeStep2* pImagePart);
*)
type
  TPVDDecodeCallback = function(AContext :Pointer; AStep, ASteps :Cardinal) :Boolean; stdcall;
  TPVDDecodeCallback2 = function(AContext :Pointer; AStep, ASteps :Cardinal; AInfo :Pointer) :Boolean; stdcall;


type
// pvdInit - ������������� �������
//  ����������: ���� ��� - ����� ����� �������� �������
//  ������������ ��������: ������ ���������� �������
//   ���� ��� ����� �� ���������� ���������� ���������, �� ��������� pvdExit � ������ ����� ��������.
//   �� ����� ������������ ��� -1. ����� ����� 1. ������������� ������������ ���������������� PVD_CURRENT_INTERFACE_VERSION
//   0 - ������ ��������/������������� �������.

//UINT32 __stdcall pvdInit(void);
  TpvdInit = function() :integer; stdcall;

// pvdExit - ���������� ������ � ��������
//  ����������: ���� ��� - ��������������� ����� ��������� �������

//void __stdcall pvdExit(void);
  TpvdExit = procedure(); stdcall;

// pvdPluginInfo - ����� ���������� � �������
//  ����������: ����� ������
//  ���������:
//   pPluginInfo - ��������� �� ��������� � ����������� � ������� ��� ���������� ��������

//void __stdcall pvdPluginInfo(pvdInfoPlugin *pPluginInfo);
  TpvdPluginInfo = procedure(pPluginInfo :PPVDInfoPlugin); stdcall;

// pvdFileOpen - �������� �����: ������ ������, ����� �� �� ������������ ����, � ��������� ����� ���������� � �����
//  ����������: ��� �������� �����
//  ���������:
//   pFileName   - ��� ������������ �����
//   lFileSize   - ����� ������������ ����� � ������. ���� 0, �� ���� �����������, � ���������� ���������� pBuf �����
//                 �������� ��� ��������� ������ � ����� �������� ������ �� ������ pvdFileClose.
//   pBuf        - �����, ���������� ������ ������������ �����
//   lBuf        - ����� ������ pBuf � ������. ������������� ������������� �� ����� 16 ��.
//   pImageInfo  - ��������� �� ��������� � ����������� � ����� ��� ���������� ��������, ���� �� ����� ������������ ����
//   ppContext   - ��������� �� ��������. ����� ���� �������� ������ ����� ������� �������� - ������������ ��������,
//                 ������� ����� ������������ ��� ��� ������ ������ ������� ������ � ������ ������. ������� ����� �
//                 ����, ��� ����� ����������� ������� � ���� ������ ������� ����� �������������� ��������� ������,
//                 ������� ������������� ������������ ��������, � �� ���������� ���������� ���������� �������.
//  ������������ ��������: TRUE - ���� ������ ����� ������������ ��������� ����; ����� - FALSE

//BOOL __stdcall pvdFileOpen(const char *pFileName, INT64 lFileSize, const BYTE *pBuf, UINT32 lBuf, pvdInfoImage *pImageInfo, void **ppContext);
  TpvdFileOpen = function(pFileName :PAnsiChar; lFileSize :Int64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage; var pContext :Pointer) :BOOL; stdcall;

// pvdPageInfo - ���������� � �������� �����������
//  ����������: ����� ������� pvdFileOpen � pvdFileClose
//  ���������:
//   pContext    - ��������, ������������ �������� � pvdFileOpen
//   iPage       - ����� �������� ����������� (��������� ���������� � 0)
//   pPageInfo   - ��������� �� ��������� � ����������� � �������� ����������� ��� ���������� ��������
//  ������������ ��������: TRUE - ��� �������� ����������; ����� - FALSE

//BOOL __stdcall pvdPageInfo(void *pContext, UINT32 iPage, pvdInfoPage *pPageInfo);
  TpvdPageInfo = function(pContext :Pointer; iPage :UINT; pPageInfo :PPVDInfoPage) :BOOL; stdcall;

// pvdPageDecode - ������������� �������� �����������
//  ����������: ����� ������� pvdFileOpen � pvdFileClose
//  ���������:
//   pContext       - ��������, ������������ �������� � pvdFileOpen
//   iPage          - ����� �������� ����������� (��������� ���������� � 0)
//   pDecodeInfo    - ��������� �� ��������� � ����������� � �������������� ����������� ��� ���������� ��������
//   DecodeCallback - ��������� �� �������, ����� ������� ������ ����� ������������� ���������� ��������� � ����
//                    �������������; NULL, ���� ����� ������� �� ���������������
//   pDecodeCallbackContext - ��������, ������������ � DecodeCallback
//  ������������ ��������: TRUE - ��� �������� ����������; ����� - FALSE

//BOOL __stdcall pvdPageDecode(void *pContext, UINT32 iPage, pvdInfoDecode *pDecodeInfo, pvdDecodeCallback DecodeCallback, void *pDecodeCallbackContext);
  TpvdPageDecode = function(pContext :Pointer; iPage :UINT; pDecodeInfo :PPVDInfoDecode; DecodeCallback :TPVDDecodeCallback; pDecodeCallbackContext :pointer) :BOOL; stdcall;


// pvdPageFree - ������������ ��������������� �����������
//  ����������: ����� �������� pvdPageDecode, ����� �������������� ����������� ������ �� �����
//  ���������:
//   pContext    - ��������, ������������ �������� � pvdFileOpen
//   pDecodeInfo - ��������� �� ��������� � ����������� � �������������� �����������, ����������� � pvdPageDecode

//void __stdcall pvdPageFree(void *pContext, pvdInfoDecode *pDecodeInfo);
  TpvdPageFree = procedure(pContext :Pointer; pDecodeInfo :PPVDInfoDecode); stdcall;


// pvdFileClose - �������� �����
//  ����������: ����� �������� pvdFileOpen, ����� ���� ������ �� �����
//  ���������:
//   pContext    - ��������, ������������ �������� � pvdFileOpen

//void __stdcall pvdFileClose(void *pContext);
  TpvdFileClose = procedure(pContext :Pointer); stdcall;


// pvdTranslateError2 - ������������ ���������� ��� ������
//  ����������: ������� ����� ���� ������� ����� �������, ��������� ������. ���� - �������� ������������ ������ �����
//   ����� ����� ��������. �������� "ERR_ERR_HEADER" ��� "Memory allocation failed (60Mb)".
//  ���������:
//   nErrNumber - ��� ������ ������������ ����������� � ���� nErrNumber ����� �� ��������
//   pszErrInfo - �����, � ������� ��������� ������ ����������� �������� ������
//   nBufLen    - ������ ������ � wchar_t
//  ������������ ��������: ������ ���������� TRUE. ����� ��������� ��� � ����� ������ �� ����������
//BOOL __stdcall pvdTranslateError2(DWORD nErrNumber, wchar_t *pszErrInfo, int nBufLen);
  TpvdTranslateError2 = function(nErrNumber :DWORD; pErrInfo :PWideChar; nBufLen :Integer) :Boolean; stdcall;

type
  TpvdInit2 = function(pInit :PpvdInitPlugin2) :integer; stdcall;
  TpvdExit2 = procedure(pContext :Pointer); stdcall;
  TpvdPluginInfo2 = procedure(pPluginInfo :PPVDInfoPlugin2); stdcall;
  TpvdReloadConfig2 = procedure(pContext :Pointer); stdcall;

  TpvdGetFormats2 = procedure(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  TpvdFileOpen2 = function(pContext :Pointer; pFileName :PWideChar; lFileSize :Int64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage2) :BOOL; stdcall;
  TpvdPageInfo2 = function(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  TpvdPageDecode2 = function(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :pointer) :BOOL; stdcall;
  TpvdPageFree2 = procedure(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2); stdcall;
  TpvdFileClose2 = procedure(pContext :Pointer; pImageContext :Pointer); stdcall;

  TpvdDisplayInit2 = function(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;
  TpvdDisplayAttach2 = function(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;
  TpvdDisplayCreate2 = function(pContext :Pointer; pDisplayCreate :PPVDInfoDisplayCreate2) :BOOL; stdcall;
  TpvdDisplayPaint2 = function(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;
  TpvdDisplayClose2 = procedure(pContext :Pointer; pDisplayContext :Pointer); stdcall;
  TpvdDisplayExit2 = procedure(pContext :Pointer); stdcall;


{------------------------------------------------------------------------------}
{ PVD_IIF_MOVIE                                                                }

const
  PVD_PC_Play                = 1;
  PVD_PC_Pause               = 2;
  PVD_PC_Stop                = 3;
  PVD_PC_GetState            = 4;
  PVD_PC_GetPos              = 5;
  PVD_PC_SetPos              = 6;
  PVD_PC_GetVolume           = 7;
  PVD_PC_SetVolume           = 8;
  PVD_PC_Mute                = 9;
  PVD_PC_GetLen              = 10;
  PVD_PC_GetBounds           = 11;
  PVD_PC_GetAudioStreamCount = 12;
  PVD_PC_GetAudioStream      = 13;
  PVD_PC_SetAudioStream      = 14;

type
  TpvdPlayControl = function(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; pInfo :Pointer) :Integer; stdcall;


{------------------------------------------------------------------------------}
{ ��������� �����                                                              }


(*

Relative Path	Name	Type
/{ushort=256}	ImageWidth	VT_UI2 or VT_UI4
/{ushort=257}	ImageLength	VT_UI2 or VT_UI4
/{ushort=258}	BitsPerSample	VT_UI2
/{ushort=259}	Compression	VT_UI2
/{ushort=262}	PhotometricInterpretation	VT_UI2
/{ushort=274}	Orientation	VT_UI2
/{ushort=277}	SamplesPerPixel	VT_UI2
/{ushort=284}	PlanarConfiguration	VT_UI2
/{ushort=530}	YCbCrSubSampling	VT_VECTOR | VT_UI2
/{ushort=531}	YCbCrPositioning	VT_UI2
***/{ushort=282}	XResolution	 VT_UI8
***/{ushort=283}	YResolution	VT_UI8
/{ushort=296}	ResolutionUnit	VT_UI2

*** /{ushort=306}  DateTime         VT_LPSTR
*** /{ushort=270}  ImageDescription VT_LPSTR
*** /{ushort=271}  Make	            VT_LPSTR
*** /{ushort=272}  Model	    VT_LPSTR

*** /{ushort=305}  Software	    VT_LPSTR
*** /{ushort=315}  Artist	    VT_LPSTR
*** /{ushort=33432} Copyright	VT_LPSTR

/{ushort=338}	ExtraSamples	VT_UI2
/{ushort=254}	NewSubfileType	VT_UI4
/{ushort=278}	RowsPerStrip	VT_UI2 or VT_UI4
/{ushort=279}	StripByteCounts	VT_VECTOR | VT_UI2 or VT_VECTOR | VT_UI4
/{ushort=273}	StripOffsets	VT_VECTOR | VT_UI2 or VT_VECTOR | VT_UI4


/{ushort=36864}	ExifVersion	VT_BLOB
/{ushort=40960}	FlashpixVersion	VT_BLOB
/{ushort=40961}	ColorSpace	VT_UI2
/{ushort=40962}	PixelXDimension	VT_UI2 or VT_UI4
/{ushort=40963}	PixelYDimension	VT_UI2 or VT_UI4
/{ushort=37500}	MakerNote	VT_BLOB
/{ushort=37510}	UserComment	VT_LPWSTR
/{ushort=36867}	DateTimeOriginal	VT_LPSTR
/{ushort=36868}	DateTimeDigitized	VT_LPSTR
/{ushort=42016}	ImageUniqueID	VT_LPSTR
/{ushort=42032}	CameraOwnerName	VT_LPSTR
/{ushort=42033}	BodySerialNumber	VT_LPSTR
/{ushort=42034}	LensSpecification	VT_VECTOR | VT_UI8
/{ushort=42035}	LensMake	VT_LPSTR
/{ushort=42036}	LensModel	VT_LPSTR
/{ushort=42037}	LensSerialNumber	VT_LPSTR

/{ushort=33434}	ExposureTime	VT_UI8
/{ushort=33437}	FNumber	VT_UI8

/{ushort=34850}	ExposureProgram	VT_UI2
/{ushort=34852}	SpectralSensitivity	VT_LPSTR
/{ushort=34855}	PhotographicSensitivity	VT_VECTOR | VT_UI2
/{ushort=34856}	OECF	VT_BLOB
/{ushort=34864}	SensitivityType	VT_UI2
/{ushort=34865}	StandardOutputSensitivity	VT_UI4
/{ushort=34866}	RecommendedExposureIndex	VT_UI4
/{ushort=34867}	ISOSpeed	VT_UI4
/{ushort=34868}	ISOSpeedLatitudeyyy	VT_UI4
/{ushort=34869}	ISOSpeedLatitudezzz	VT_UI4
/{ushort=37377}	ShutterSpeedValue	VT_I8
/{ushort=37378}	ApertureValue	VT_UI8
/{ushort=37379}	BrightnessValue	VT_I8
/{ushort=37380}	ExposureBiasValue	VT_I8
/{ushort=37381}	MaxApertureValue	VT_UI8
/{ushort=37382}	SubjectDistance	VT_UI8
/{ushort=37383}	MeteringMode	VT_UI2
/{ushort=37384}	LightSource	VT_UI2
/{ushort=37385}	Flash	VT_UI2
/{ushort=37386}	FocalLength	VT_UI8
/{ushort=37396}	SubjectArea	VT_VECTOR | VT_UI2
/{ushort=41483}	FlashEnergy	VT_UI8
/{ushort=41484}	SpatialFrequencyResponse	VT_BLOB
/{ushort=41486}	FocalPlaneXResolution	VT_UI8
/{ushort=41487}	FocalPlaneYResolution	VT_UI8
/{ushort=41488}	FocalPlaneResolutionUnit	VT_UI2
/{ushort=41492}	SubjectLocation	VT_VECTOR | VT_UI2
/{ushort=41493}	ExposureIndex	VT_UI8
/{ushort=41495}	SensingMethod	VT_UI2
/{ushort=41728}	FileSource	VT_BLOB
/{ushort=41729}	SceneType	VT_BLOB
/{ushort=41730}	CFAPattern	VT_BLOB
/{ushort=41985}	CustomRendered	VT_UI2
/{ushort=41986}	ExposureMode	VT_UI2
/{ushort=41987}	WhiteBalance	VT_UI2
/{ushort=41988}	DigitalZoomRatio	VT_UI8
/{ushort=41989}	FocalLengthIn35mmFilm	VT_UI2
/{ushort=41990}	SceneCaptureType	VT_UI2
/{ushort=41991}	GainControl	VT_UI8
/{ushort=41992}	Contrast	VT_UI2
/{ushort=41993}	Saturation	VT_UI2
/{ushort=41994}	Sharpness	VT_UI2
/{ushort=41995}	DeviceSettingDescription	VT_BLOB
/{ushort=41996}	SubjectDistanceRange	VT_UI2

{ushort=0}	GPSVersionID	VT_VECTOR | VT_UI1
{ushort=1}	GPSLatitudeRef	VT_LPSTR
{ushort=2}	GPSLatitude	VT_VECTOR | VT_UI8
{ushort=3}	GPSLongitudeRef	VT_LPSTR
{ushort=4}	GPSLongitude	{ushort=4}	GPSLongitude	VT_VECTOR | VT_UI8
{ushort=5}	GPSAltitudeRef	VT_UI1
{ushort=6}	GPSAltitude	VT_UI8
{ushort=7}	GPSTimeStamp	VT_VECTOR | VT_UI8
{ushort=8}	GPSSatellites	VT_LPSTR
{ushort=9}	GPSStatus	VT_LPSTR
{ushort=10}	GPSMeasureMode	VT_LPSTR
{ushort=11}	GPSDOP	VT_UI8
{ushort=12}	GPSSpeedRef	VT_LPSTR
{ushort=13}	GPSSpeed	VT_UI8
{ushort=14}	GPSTrackRef	VT_LPSTR
{ushort=15}	GPSTrack	VT_UI8


rdf	http://www.w3.org/1999/02/22-rdf-syntax-ns#	http://www.w3.org/TR/REC-rdf-syntax/
dc	http://purl.org/dc/elements/1.1/	http://www.adobe.com/devnet/xmp.html
xmp	http://ns.adobe.com/xap/1.0/	http://www.adobe.com/devnet/xmp.html
xmpidq	http://ns.adobe.com/xmp/Identifier/qual/1.0/	http://www.adobe.com/devnet/xmp.html
xmpRights	http://ns.adobe.com/xap/1.0/rights/	http://www.adobe.com/devnet/xmp.html
xmpMM	http://ns.adobe.com/xap/1.0/mm/	http://www.adobe.com/devnet/xmp.html
xmpBJ	http://ns.adobe.com/xap/1.0/bj/	http://www.adobe.com/devnet/xmp.html
xmpTPg	http://ns.adobe.com/xap/1.0/t/pg/	http://www.adobe.com/devnet/xmp.html
pdf	http://ns.adobe.com/pdf/1.3/	http://www.adobe.com/devnet/xmp.html
photoshop	http://ns.adobe.com/photoshop/1.0/	http://www.adobe.com/devnet/xmp.html
tiff	http://ns.adobe.com/tiff/1.0/	http://www.adobe.com/devnet/xmp.html
exif	http://ns.adobe.com/exif/1.0/	http://www.adobe.com/devnet/xmp.html
stDim	http://ns.adobe.com/xap/1.0/sType/Dimensions#	http://www.adobe.com/devnet/xmp.html
xapGImg	http://ns.adobe.com/xap/1.0/g/img/	http://www.adobe.com/devnet/xmp.html
stEvt	http://ns.adobe.com/xap/1.0/sType/ResourceEvent#	http://www.adobe.com/devnet/xmp.html
stRef	http://ns.adobe.com/xap/1.0/sType/ResourceRef#	http://www.adobe.com/devnet/xmp.html
stVer	http://ns.adobe.com/xap/1.0/sType/Version#	http://www.adobe.com/devnet/xmp.html
stJob	http://ns.adobe.com/xap/1.0/sType/Job#	http://www.adobe.com/devnet/xmp.html
aux	http://ns.adobe.com/exif/1.0/aux/	http://www.adobe.com/devnet/xmp.html
crs	http://ns.adobe.com/camera-raw-settings/1.0/	http://www.adobe.com/devnet/xmp.html
xmpDM	http://ns.adobe.com/xmp/1.0/DynamicMedia/	http://www.adobe.com/devnet/xmp.html
Iptc4xmpCore	http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/	http://www.iptc.org/cms/site/index.html?channel=CH0099
MicrosoftPhoto	http://ns.microsoft.com/photo/1.0/	People Tagging Overview
MP	http://ns.microsoft.com/photo/1.2/	People Tagging Overview
MPRI	http://ns.microsoft.com/photo/1.2/t/RegionInfo#	People Tagging Overview
MPReg	http://ns.microsoft.com/photo/1.2/t/Region#	People Tagging Overview
*)

const
  PVD_Tag_Description  = 101;  // ��������
  PVD_Tag_Time         = 102;  // ���� ������
  PVD_Tag_EquipMake    = 103;  // ������������� ������
  PVD_Tag_EquipModel   = 104;  // ������ ������
  PVD_Tag_Software     = 105;  // ���������
  PVD_Tag_Author       = 106;  // �����
  PVD_Tag_Copyright    = 107;  // �����

  PVD_Tag_Title        = 201;
  PVD_Tag_Artist       = 202;
  PVD_Tag_Album        = 203;
  PVD_Tag_Year         = 204;
  PVD_Tag_Genre        = 205;

  PVD_Tag_ExposureTime = 301;  // ��������
  PVD_Tag_FNumber      = 302;  // ���������
  PVD_Tag_ISO          = 303;  // ��������������������� (Photographic Sensitivity)
  PVD_Tag_FocalLength  = 304;  // �������� ����������
  PVD_Tag_Flash        = 305;  // �������
  PVD_Tag_XResolution  = 306;  // ���������� (dpi)
  PVD_Tag_YResolution  = 307;  // ���������� (dpi)
//PVD_Tag_ResolutionUnit = 308;  // ResolutionUnit (2 = Inches, 3 = Centimeters)

const
  PVD_TagCmd_Get   = 1;

const
  PVD_TagType_Int     = 1;
  PVD_TagType_Int64   = 2;
  PVD_TagType_Double  = 3;
  PVD_TagType_Str     = 4;

type
(*
  PPvdTagRec = ^TPvdTagRec;
  TPvdTagRec = record
    TagCode :UINT;
    TagName :PWideChar;
    TagType :Byte;
    case Integer of
      0: (IntValue :Integer);
      1: (NumVaule :Double);
      2: (StrVaule :PWideChar);
  end;

  PPvdTagArray = ^TPvdTagArray;
  TPvdTagArray = array[0..$7FFF] of TPvdTagRec;

  TpvdTagInfo = function(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; var aTagCount :Integer; var aTags :PPvdTagArray) :Integer; stdcall;
*)
  TpvdTagInfo = function(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


end.


{$I Defines.inc}

      {******************************************************************}
      { GDI+ API                                                         }
      {                                                                  }
      { home page : http://www.progdigy.com                              }
      { email     : hgourvest@progdigy.com                               }
      {                                                                  }
      { date      : 15-02-2002                                           }
      {                                                                  }
      { The contents of this file are used with permission, subject to   }
      { the Mozilla Public License Version 1.1 (the "License"); you may  }
      { not use this file except in compliance with the License. You may }
      { obtain a copy of the License at                                  }
      { http://www.mozilla.org/MPL/MPL-1.1.html                          }
      {                                                                  }
      { Software distributed under the License is distributed on an      }
      { "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
      { implied. See the License for the specific language governing     }
      { rights and limitations under the License.                        }
      {                                                                  }
      { *****************************************************************}

{$WEAKPACKAGEUNIT}

unit GDIPAPI;

{$ALIGN ON}
{$MINENUMSIZE 4}

{$ifdef bFreePascal}
 {$PACKRECORDS C} 
{$endif bFreePascal}

{-$DEFINE DELPHI6_UP}

interface

(**************************************************************************\
*
*   GDI+ public header file
*
\**************************************************************************)

uses
  Windows,
  ActiveX,
  DirectDraw;

type
  INT16   = type Smallint;
  UINT16  = type Word;
  PUINT16 = ^UINT16;
  UINT32  = type Cardinal;

(**************************************************************************\
*
*   GDI+ Private Memory Management APIs
*
\**************************************************************************)

const WINGDIPDLL = 'gdiplus.dll';

//----------------------------------------------------------------------------
// Memory Allocation APIs
//----------------------------------------------------------------------------

function GdipAlloc(size: ULONG): pointer; stdcall;
procedure GdipFree(ptr: pointer); stdcall;

(**************************************************************************\
*
*   GDI+ base memory allocation class
*
\**************************************************************************)

type
  TGdiplusBase = class
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;

(**************************************************************************\
*
*   GDI+ Enumeration Types
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Default bezier flattening tolerance in device pixels.
//--------------------------------------------------------------------------

const
  FlatnessDefault = 0.25;

//--------------------------------------------------------------------------
// Graphics and Container State cookies
//--------------------------------------------------------------------------
type
  GraphicsState     = UINT;
  GraphicsContainer = UINT;

//--------------------------------------------------------------------------
// Fill mode constants
//--------------------------------------------------------------------------

  FillMode = (
    FillModeAlternate,        // 0
    FillModeWinding           // 1
  );
  TFillMode = FillMode;

//--------------------------------------------------------------------------
// Quality mode constants
//--------------------------------------------------------------------------

{$IFDEF DELPHI6_UP}
  QualityMode = (
    QualityModeInvalid   = -1,
    QualityModeDefault   =  0,
    QualityModeLow       =  1, // Best performance
    QualityModeHigh      =  2  // Best rendering quality
  );
  TQualityMode = QualityMode;
{$ELSE}
  QualityMode = Integer;
  const
    QualityModeInvalid   = -1;
    QualityModeDefault   =  0;
    QualityModeLow       =  1; // Best performance
    QualityModeHigh      =  2; // Best rendering quality
{$ENDIF}

//--------------------------------------------------------------------------
// Alpha Compositing mode constants
//--------------------------------------------------------------------------
type
  CompositingMode = (
    CompositingModeSourceOver,    // 0
    CompositingModeSourceCopy     // 1
  );
  TCompositingMode = CompositingMode;

//--------------------------------------------------------------------------
// Alpha Compositing quality constants
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  CompositingQuality = (
    CompositingQualityInvalid          = ord(QualityModeInvalid),
    CompositingQualityDefault          = ord(QualityModeDefault),
    CompositingQualityHighSpeed        = ord(QualityModeLow),
    CompositingQualityHighQuality      = ord(QualityModeHigh),
    CompositingQualityGammaCorrected,
    CompositingQualityAssumeLinear
  );
  TCompositingQuality = CompositingQuality;
{$ELSE}
  CompositingQuality = Integer;
  const
    CompositingQualityInvalid          = QualityModeInvalid;
    CompositingQualityDefault          = QualityModeDefault;
    CompositingQualityHighSpeed        = QualityModeLow;
    CompositingQualityHighQuality      = QualityModeHigh;
    CompositingQualityGammaCorrected   = 3;
    CompositingQualityAssumeLinear     = 4;

type
  TCompositingQuality = CompositingQuality;
{$ENDIF}

//--------------------------------------------------------------------------
// Unit constants
//--------------------------------------------------------------------------

  Unit_ = (
    UnitWorld,      // 0 -- World coordinate (non-physical unit)
    UnitDisplay,    // 1 -- Variable -- for PageTransform only
    UnitPixel,      // 2 -- Each unit is one device pixel.
    UnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
    UnitInch,       // 4 -- Each unit is 1 inch.
    UnitDocument,   // 5 -- Each unit is 1/300 inch.
    UnitMillimeter  // 6 -- Each unit is 1 millimeter.
  );
  TUnit = Unit_;

//--------------------------------------------------------------------------
// MetafileFrameUnit
//
// The frameRect for creating a metafile can be specified in any of these
// units.  There is an extra frame unit value (MetafileFrameUnitGdi) so
// that units can be supplied in the same units that GDI expects for
// frame rects -- these units are in .01 (1/100ths) millimeter units
// as defined by GDI.
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  MetafileFrameUnit = (
    MetafileFrameUnitPixel      = ord(UnitPixel),
    MetafileFrameUnitPoint      = ord(UnitPoint),
    MetafileFrameUnitInch       = ord(UnitInch),
    MetafileFrameUnitDocument   = ord(UnitDocument),
    MetafileFrameUnitMillimeter = ord(UnitMillimeter),
    MetafileFrameUnitGdi        // GDI compatible .01 MM units
  );
  TMetafileFrameUnit = MetafileFrameUnit;
{$ELSE}
  MetafileFrameUnit = Integer;
  const
    MetafileFrameUnitPixel      = 2;
    MetafileFrameUnitPoint      = 3;
    MetafileFrameUnitInch       = 4;
    MetafileFrameUnitDocument   = 5;
    MetafileFrameUnitMillimeter = 6;
    MetafileFrameUnitGdi        = 7; // GDI compatible .01 MM units

type
  TMetafileFrameUnit = MetafileFrameUnit;
{$ENDIF}
//--------------------------------------------------------------------------
// Coordinate space identifiers
//--------------------------------------------------------------------------

  CoordinateSpace = (
    CoordinateSpaceWorld,     // 0
    CoordinateSpacePage,      // 1
    CoordinateSpaceDevice     // 2
  );
  TCoordinateSpace = CoordinateSpace;

//--------------------------------------------------------------------------
// Various wrap modes for brushes
//--------------------------------------------------------------------------

  WrapMode = (
    WrapModeTile,        // 0
    WrapModeTileFlipX,   // 1
    WrapModeTileFlipY,   // 2
    WrapModeTileFlipXY,  // 3
    WrapModeClamp        // 4
  );
  TWrapMode = WrapMode;

//--------------------------------------------------------------------------
// Various hatch styles
//--------------------------------------------------------------------------

  HatchStyle = (
    HatchStyleHorizontal,                  // = 0,
    HatchStyleVertical,                    // = 1,
    HatchStyleForwardDiagonal,             // = 2,
    HatchStyleBackwardDiagonal,            // = 3,
    HatchStyleCross,                       // = 4,
    HatchStyleDiagonalCross,               // = 5,
    HatchStyle05Percent,                   // = 6,
    HatchStyle10Percent,                   // = 7,
    HatchStyle20Percent,                   // = 8,
    HatchStyle25Percent,                   // = 9,
    HatchStyle30Percent,                   // = 10,
    HatchStyle40Percent,                   // = 11,
    HatchStyle50Percent,                   // = 12,
    HatchStyle60Percent,                   // = 13,
    HatchStyle70Percent,                   // = 14,
    HatchStyle75Percent,                   // = 15,
    HatchStyle80Percent,                   // = 16,
    HatchStyle90Percent,                   // = 17,
    HatchStyleLightDownwardDiagonal,       // = 18,
    HatchStyleLightUpwardDiagonal,         // = 19,
    HatchStyleDarkDownwardDiagonal,        // = 20,
    HatchStyleDarkUpwardDiagonal,          // = 21,
    HatchStyleWideDownwardDiagonal,        // = 22,
    HatchStyleWideUpwardDiagonal,          // = 23,
    HatchStyleLightVertical,               // = 24,
    HatchStyleLightHorizontal,             // = 25,
    HatchStyleNarrowVertical,              // = 26,
    HatchStyleNarrowHorizontal,            // = 27,
    HatchStyleDarkVertical,                // = 28,
    HatchStyleDarkHorizontal,              // = 29,
    HatchStyleDashedDownwardDiagonal,      // = 30,
    HatchStyleDashedUpwardDiagonal,        // = 31,
    HatchStyleDashedHorizontal,            // = 32,
    HatchStyleDashedVertical,              // = 33,
    HatchStyleSmallConfetti,               // = 34,
    HatchStyleLargeConfetti,               // = 35,
    HatchStyleZigZag,                      // = 36,
    HatchStyleWave,                        // = 37,
    HatchStyleDiagonalBrick,               // = 38,
    HatchStyleHorizontalBrick,             // = 39,
    HatchStyleWeave,                       // = 40,
    HatchStylePlaid,                       // = 41,
    HatchStyleDivot,                       // = 42,
    HatchStyleDottedGrid,                  // = 43,
    HatchStyleDottedDiamond,               // = 44,
    HatchStyleShingle,                     // = 45,
    HatchStyleTrellis,                     // = 46,
    HatchStyleSphere,                      // = 47,
    HatchStyleSmallGrid,                   // = 48,
    HatchStyleSmallCheckerBoard,           // = 49,
    HatchStyleLargeCheckerBoard,           // = 50,
    HatchStyleOutlinedDiamond,             // = 51,
    HatchStyleSolidDiamond,                // = 52,

    HatchStyleTotal                        // = 53,
  );

  const
    HatchStyleLargeGrid = HatchStyleCross; // 4
    HatchStyleMin       = HatchStyleHorizontal;
    HatchStyleMax       = HatchStyleSolidDiamond;

type
  THatchStyle = HatchStyle;

//--------------------------------------------------------------------------
// Dash style constants
//--------------------------------------------------------------------------

  DashStyle = (
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom          // 5
  );
  TDashStyle = DashStyle;

//--------------------------------------------------------------------------
// Dash cap constants
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  DashCap = (
    DashCapFlat             = 0,
    DashCapRound            = 2,
    DashCapTriangle         = 3
  );
  TDashCap = DashCap;
{$ELSE}
  DashCap = Integer;
  const
    DashCapFlat             = 0;
    DashCapRound            = 2;
    DashCapTriangle         = 3;

type
  TDashCap = DashCap;
{$ENDIF}

//--------------------------------------------------------------------------
// Line cap constants (only the lowest 8 bits are used).
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  LineCap = (
    LineCapFlat             = 0,
    LineCapSquare           = 1,
    LineCapRound            = 2,
    LineCapTriangle         = 3,

    LineCapNoAnchor         = $10, // corresponds to flat cap
    LineCapSquareAnchor     = $11, // corresponds to square cap
    LineCapRoundAnchor      = $12, // corresponds to round cap
    LineCapDiamondAnchor    = $13, // corresponds to triangle cap
    LineCapArrowAnchor      = $14, // no correspondence

    LineCapCustom           = $ff, // custom cap

    LineCapAnchorMask       = $f0  // mask to check for anchor or not.
  );
  TLineCap = LineCap;
{$ELSE}
  LineCap = Integer;
  const
    LineCapFlat             = 0;
    LineCapSquare           = 1;
    LineCapRound            = 2;
    LineCapTriangle         = 3;

    LineCapNoAnchor         = $10; // corresponds to flat cap
    LineCapSquareAnchor     = $11; // corresponds to square cap
    LineCapRoundAnchor      = $12; // corresponds to round cap
    LineCapDiamondAnchor    = $13; // corresponds to triangle cap
    LineCapArrowAnchor      = $14; // no correspondence

    LineCapCustom           = $ff; // custom cap

    LineCapAnchorMask       = $f0; // mask to check for anchor or not.

type
  TLineCap = LineCap;
{$ENDIF}

//--------------------------------------------------------------------------
// Custom Line cap type constants
//--------------------------------------------------------------------------

  CustomLineCapType = (
    CustomLineCapTypeDefault,
    CustomLineCapTypeAdjustableArrow
  );
  TCustomLineCapType = CustomLineCapType;

//--------------------------------------------------------------------------
// Line join constants
//--------------------------------------------------------------------------

  LineJoin = (
    LineJoinMiter,
    LineJoinBevel,
    LineJoinRound,
    LineJoinMiterClipped
  );
  TLineJoin = LineJoin;

//--------------------------------------------------------------------------
// Path point types (only the lowest 8 bits are used.)
//  The lowest 3 bits are interpreted as point type
//  The higher 5 bits are reserved for flags.
//--------------------------------------------------------------------------

{$IFDEF DELPHI6_UP}
  {$Z1}
  PathPointType = (
    PathPointTypeStart           = $00, // move
    PathPointTypeLine            = $01, // line
    PathPointTypeBezier          = $03, // default Bezier (= cubic Bezier)
    PathPointTypePathTypeMask    = $07, // type mask (lowest 3 bits).
    PathPointTypeDashMode        = $10, // currently in dash mode.
    PathPointTypePathMarker      = $20, // a marker for the path.
    PathPointTypeCloseSubpath    = $80, // closed flag

    // Path types used for advanced path.
    PathPointTypeBezier3         = $03  // cubic Bezier
  );
  TPathPointType = PathPointType;
  {$Z4}
{$ELSE}
  PathPointType = Byte;
  const
    PathPointTypeStart          : Byte = $00; // move
    PathPointTypeLine           : Byte = $01; // line
    PathPointTypeBezier         : Byte = $03; // default Bezier (= cubic Bezier)
    PathPointTypePathTypeMask   : Byte = $07; // type mask (lowest 3 bits).
    PathPointTypeDashMode       : Byte = $10; // currently in dash mode.
    PathPointTypePathMarker     : Byte = $20; // a marker for the path.
    PathPointTypeCloseSubpath   : Byte = $80; // closed flag

    // Path types used for advanced path.
    PathPointTypeBezier3        : Byte = $03;  // cubic Bezier

type
  TPathPointType = PathPointType;
{$ENDIF}

//--------------------------------------------------------------------------
// WarpMode constants
//--------------------------------------------------------------------------

  WarpMode = (
    WarpModePerspective,    // 0
    WarpModeBilinear        // 1
  );
  TWarpMode = WarpMode;

//--------------------------------------------------------------------------
// LineGradient Mode
//--------------------------------------------------------------------------

  LinearGradientMode = (
    LinearGradientModeHorizontal,         // 0
    LinearGradientModeVertical,           // 1
    LinearGradientModeForwardDiagonal,    // 2
    LinearGradientModeBackwardDiagonal    // 3
  );
  TLinearGradientMode = LinearGradientMode;

//--------------------------------------------------------------------------
// Region Comine Modes
//--------------------------------------------------------------------------

  CombineMode = (
    CombineModeReplace,     // 0
    CombineModeIntersect,   // 1
    CombineModeUnion,       // 2
    CombineModeXor,         // 3
    CombineModeExclude,     // 4
    CombineModeComplement   // 5 (Exclude From)
  );
  TCombineMode = CombineMode;

//--------------------------------------------------------------------------
 // Image types
//--------------------------------------------------------------------------

  ImageType = (
    ImageTypeUnknown,   // 0
    ImageTypeBitmap,    // 1
    ImageTypeMetafile   // 2
  );
  TImageType = ImageType;

//--------------------------------------------------------------------------
// Interpolation modes
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  InterpolationMode = (
    InterpolationModeInvalid          = ord(QualityModeInvalid),
    InterpolationModeDefault          = ord(QualityModeDefault),
    InterpolationModeLowQuality       = ord(QualityModeLow),
    InterpolationModeHighQuality      = ord(QualityModeHigh),
    InterpolationModeBilinear,
    InterpolationModeBicubic,
    InterpolationModeNearestNeighbor,
    InterpolationModeHighQualityBilinear,
    InterpolationModeHighQualityBicubic
  );
  TInterpolationMode = InterpolationMode;
{$ELSE}
  InterpolationMode = Integer;
  const
    InterpolationModeInvalid             = QualityModeInvalid;
    InterpolationModeDefault             = QualityModeDefault;
    InterpolationModeLowQuality          = QualityModeLow;
    InterpolationModeHighQuality         = QualityModeHigh;
    InterpolationModeBilinear            = 3;
    InterpolationModeBicubic             = 4;
    InterpolationModeNearestNeighbor     = 5;
    InterpolationModeHighQualityBilinear = 6;
    InterpolationModeHighQualityBicubic  = 7;

type
  TInterpolationMode = InterpolationMode;
{$ENDIF}

//--------------------------------------------------------------------------
// Pen types
//--------------------------------------------------------------------------

  PenAlignment = (
    PenAlignmentCenter,
    PenAlignmentInset
  );
  TPenAlignment = PenAlignment;

//--------------------------------------------------------------------------
// Brush types
//--------------------------------------------------------------------------

  BrushType = (
   BrushTypeSolidColor,
   BrushTypeHatchFill,
   BrushTypeTextureFill,
   BrushTypePathGradient,
   BrushTypeLinearGradient 
  );
  TBrushType = BrushType;

//--------------------------------------------------------------------------
// Pen's Fill types
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  PenType = (
   PenTypeSolidColor       =  ord(BrushTypeSolidColor),
   PenTypeHatchFill        =  ord(BrushTypeHatchFill),
   PenTypeTextureFill      =  ord(BrushTypeTextureFill),
   PenTypePathGradient     =  ord(BrushTypePathGradient),
   PenTypeLinearGradient   =  ord(BrushTypeLinearGradient),
   PenTypeUnknown          = -1
  );
  TPenType = PenType;
{$ELSE}
  PenType = Integer;
  const
    PenTypeSolidColor       =  0;
    PenTypeHatchFill        =  1;
    PenTypeTextureFill      =  2;
    PenTypePathGradient     =  3;
    PenTypeLinearGradient   =  4;
    PenTypeUnknown          = -1;

type
  TPenType = PenType;
{$ENDIF}

//--------------------------------------------------------------------------
// Matrix Order
//--------------------------------------------------------------------------

  MatrixOrder = (
    MatrixOrderPrepend,
    MatrixOrderAppend
  );
  TMatrixOrder = MatrixOrder;

//--------------------------------------------------------------------------
// Generic font families
//--------------------------------------------------------------------------

  GenericFontFamily = (
    GenericFontFamilySerif,
    GenericFontFamilySansSerif,
    GenericFontFamilyMonospace
  );
  TGenericFontFamily = GenericFontFamily;

//--------------------------------------------------------------------------
// FontStyle: face types and common styles
//--------------------------------------------------------------------------
type
  FontStyle = Integer;
  const
    FontStyleRegular    = Integer(0);
    FontStyleBold       = Integer(1);
    FontStyleItalic     = Integer(2);
    FontStyleBoldItalic = Integer(3);
    FontStyleUnderline  = Integer(4);
    FontStyleStrikeout  = Integer(8);
  Type
  TFontStyle = FontStyle;

//---------------------------------------------------------------------------
// Smoothing Mode
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  SmoothingMode = (
    SmoothingModeInvalid     = ord(QualityModeInvalid),
    SmoothingModeDefault     = ord(QualityModeDefault),
    SmoothingModeHighSpeed   = ord(QualityModeLow),
    SmoothingModeHighQuality = ord(QualityModeHigh),
    SmoothingModeNone,
    SmoothingModeAntiAlias8x4,
    SmoothingModeAntiAlias   = SmoothingModeAntiAlias8x4,
    SmoothingModeAntiAlias8x8);
  TSmoothingMode = SmoothingMode;
{$ELSE}
  SmoothingMode = Integer;
  const
    SmoothingModeInvalid     = QualityModeInvalid;
    SmoothingModeDefault     = QualityModeDefault;
    SmoothingModeHighSpeed   = QualityModeLow;
    SmoothingModeHighQuality = QualityModeHigh;
    SmoothingModeNone        = 3;
    SmoothingModeAntiAlias   = 4;

type
  TSmoothingMode = SmoothingMode;
{$ENDIF}

//---------------------------------------------------------------------------
// Pixel Format Mode
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  PixelOffsetMode = (
    PixelOffsetModeInvalid     = Ord(QualityModeInvalid),
    PixelOffsetModeDefault     = Ord(QualityModeDefault),
    PixelOffsetModeHighSpeed   = Ord(QualityModeLow),
    PixelOffsetModeHighQuality = Ord(QualityModeHigh),
    PixelOffsetModeNone,    // No pixel offset
    PixelOffsetModeHalf     // Offset by -0.5, -0.5 for fast anti-alias perf
  );
  TPixelOffsetMode = PixelOffsetMode;
{$ELSE}
  PixelOffsetMode = Integer;
  const
    PixelOffsetModeInvalid     = QualityModeInvalid;
    PixelOffsetModeDefault     = QualityModeDefault;
    PixelOffsetModeHighSpeed   = QualityModeLow;
    PixelOffsetModeHighQuality = QualityModeHigh;
    PixelOffsetModeNone        = 3;    // No pixel offset
    PixelOffsetModeHalf        = 4;    // Offset by -0.5, -0.5 for fast anti-alias perf

type
  TPixelOffsetMode = PixelOffsetMode;
{$ENDIF}

//---------------------------------------------------------------------------
// Text Rendering Hint
//---------------------------------------------------------------------------

  TextRenderingHint = (
    TextRenderingHintSystemDefault,                // Glyph with system default rendering hint
    TextRenderingHintSingleBitPerPixelGridFit,     // Glyph bitmap with hinting
    TextRenderingHintSingleBitPerPixel,            // Glyph bitmap without hinting
    TextRenderingHintAntiAliasGridFit,             // Glyph anti-alias bitmap with hinting
    TextRenderingHintAntiAlias,                    // Glyph anti-alias bitmap without hinting
    TextRenderingHintClearTypeGridFit              // Glyph CT bitmap with hinting
  );
  TTextRenderingHint = TextRenderingHint;

//---------------------------------------------------------------------------
// Metafile Types
//---------------------------------------------------------------------------

  MetafileType = (
    MetafileTypeInvalid,            // Invalid metafile
    MetafileTypeWmf,                // Standard WMF
    MetafileTypeWmfPlaceable,       // Placeable WMF
    MetafileTypeEmf,                // EMF (not EMF+)
    MetafileTypeEmfPlusOnly,        // EMF+ without dual, down-level records
    MetafileTypeEmfPlusDual         // EMF+ with dual, down-level records
  );
  TMetafileType = MetafileType;

//---------------------------------------------------------------------------
// Specifies the type of EMF to record
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  EmfType = (
    EmfTypeEmfOnly     = Ord(MetafileTypeEmf),          // no EMF+, only EMF
    EmfTypeEmfPlusOnly = Ord(MetafileTypeEmfPlusOnly),  // no EMF, only EMF+
    EmfTypeEmfPlusDual = Ord(MetafileTypeEmfPlusDual)   // both EMF+ and EMF
  );
  TEmfType = EmfType;
{$ELSE}
  EmfType = Integer;
  const
    EmfTypeEmfOnly     = Ord(MetafileTypeEmf);          // no EMF+, only EMF
    EmfTypeEmfPlusOnly = Ord(MetafileTypeEmfPlusOnly);  // no EMF, only EMF+
    EmfTypeEmfPlusDual = Ord(MetafileTypeEmfPlusDual);   // both EMF+ and EMF

type
  TEmfType = EmfType;
{$ENDIF}

//---------------------------------------------------------------------------
// EMF+ Persistent object types
//---------------------------------------------------------------------------

  ObjectType = (
    ObjectTypeInvalid,
    ObjectTypeBrush,
    ObjectTypePen,
    ObjectTypePath,
    ObjectTypeRegion,
    ObjectTypeImage,
    ObjectTypeFont,
    ObjectTypeStringFormat,
    ObjectTypeImageAttributes,
    ObjectTypeCustomLineCap
  );
  TObjectType = ObjectType;

const
  ObjectTypeMax = ObjectTypeCustomLineCap;
  ObjectTypeMin = ObjectTypeBrush;

function ObjectTypeIsValid(type_: ObjectType): BOOL;

//---------------------------------------------------------------------------
// EMF+ Records
//---------------------------------------------------------------------------

  // We have to change the WMF record numbers so that they don't conflict with
  // the EMF and EMF+ record numbers.

const
  GDIP_EMFPLUS_RECORD_BASE      = $00004000;
  GDIP_WMF_RECORD_BASE          = $00010000;

// macros
function GDIP_WMF_RECORD_TO_EMFPLUS(n: integer): Integer;
function GDIP_EMFPLUS_RECORD_TO_WMF(n: integer): Integer;
function GDIP_IS_WMF_RECORDTYPE(n: integer): BOOL;


{$IFDEF DELPHI6_UP}
type
  EmfPlusRecordType = (
   // Since we have to enumerate GDI records right along with GDI+ records,
   // We list all the GDI records here so that they can be part of the
   // same enumeration type which is used in the enumeration callback.

    WmfRecordTypeSetBkColor              = (META_SETBKCOLOR or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetBkMode               = (META_SETBKMODE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetMapMode              = (META_SETMAPMODE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetROP2                 = (META_SETROP2 or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetRelAbs               = (META_SETRELABS or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetPolyFillMode         = (META_SETPOLYFILLMODE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetStretchBltMode       = (META_SETSTRETCHBLTMODE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetTextCharExtra        = (META_SETTEXTCHAREXTRA or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetTextColor            = (META_SETTEXTCOLOR or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetTextJustification    = (META_SETTEXTJUSTIFICATION or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetWindowOrg            = (META_SETWINDOWORG or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetWindowExt            = (META_SETWINDOWEXT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetViewportOrg          = (META_SETVIEWPORTORG or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetViewportExt          = (META_SETVIEWPORTEXT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeOffsetWindowOrg         = (META_OFFSETWINDOWORG or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeScaleWindowExt          = (META_SCALEWINDOWEXT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeOffsetViewportOrg       = (META_OFFSETVIEWPORTORG or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeScaleViewportExt        = (META_SCALEVIEWPORTEXT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeLineTo                  = (META_LINETO or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeMoveTo                  = (META_MOVETO or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeExcludeClipRect         = (META_EXCLUDECLIPRECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeIntersectClipRect       = (META_INTERSECTCLIPRECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeArc                     = (META_ARC or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeEllipse                 = (META_ELLIPSE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeFloodFill               = (META_FLOODFILL or GDIP_WMF_RECORD_BASE),
    WmfRecordTypePie                     = (META_PIE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeRectangle               = (META_RECTANGLE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeRoundRect               = (META_ROUNDRECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypePatBlt                  = (META_PATBLT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSaveDC                  = (META_SAVEDC or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetPixel                = (META_SETPIXEL or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeOffsetClipRgn           = (META_OFFSETCLIPRGN or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeTextOut                 = (META_TEXTOUT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeBitBlt                  = (META_BITBLT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeStretchBlt              = (META_STRETCHBLT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypePolygon                 = (META_POLYGON or GDIP_WMF_RECORD_BASE),
    WmfRecordTypePolyline                = (META_POLYLINE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeEscape                  = (META_ESCAPE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeRestoreDC               = (META_RESTOREDC or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeFillRegion              = (META_FILLREGION or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeFrameRegion             = (META_FRAMEREGION or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeInvertRegion            = (META_INVERTREGION or GDIP_WMF_RECORD_BASE),
    WmfRecordTypePaintRegion             = (META_PAINTREGION or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSelectClipRegion        = (META_SELECTCLIPREGION or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSelectObject            = (META_SELECTOBJECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetTextAlign            = (META_SETTEXTALIGN or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeDrawText                = ($062F or GDIP_WMF_RECORD_BASE),  // META_DRAWTEXT
    WmfRecordTypeChord                   = (META_CHORD or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetMapperFlags          = (META_SETMAPPERFLAGS or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeExtTextOut              = (META_EXTTEXTOUT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetDIBToDev             = (META_SETDIBTODEV or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSelectPalette           = (META_SELECTPALETTE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeRealizePalette          = (META_REALIZEPALETTE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeAnimatePalette          = (META_ANIMATEPALETTE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetPalEntries           = (META_SETPALENTRIES or GDIP_WMF_RECORD_BASE),
    WmfRecordTypePolyPolygon             = (META_POLYPOLYGON or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeResizePalette           = (META_RESIZEPALETTE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeDIBBitBlt               = (META_DIBBITBLT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeDIBStretchBlt           = (META_DIBSTRETCHBLT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeDIBCreatePatternBrush   = (META_DIBCREATEPATTERNBRUSH or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeStretchDIB              = (META_STRETCHDIB or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeExtFloodFill            = (META_EXTFLOODFILL or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeSetLayout               = ($0149 or GDIP_WMF_RECORD_BASE),  // META_SETLAYOUT
    WmfRecordTypeResetDC                 = ($014C or GDIP_WMF_RECORD_BASE),  // META_RESETDC
    WmfRecordTypeStartDoc                = ($014D or GDIP_WMF_RECORD_BASE),  // META_STARTDOC
    WmfRecordTypeStartPage               = ($004F or GDIP_WMF_RECORD_BASE),  // META_STARTPAGE
    WmfRecordTypeEndPage                 = ($0050 or GDIP_WMF_RECORD_BASE),  // META_ENDPAGE
    WmfRecordTypeAbortDoc                = ($0052 or GDIP_WMF_RECORD_BASE),  // META_ABORTDOC
    WmfRecordTypeEndDoc                  = ($005E or GDIP_WMF_RECORD_BASE),  // META_ENDDOC
    WmfRecordTypeDeleteObject            = (META_DELETEOBJECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeCreatePalette           = (META_CREATEPALETTE or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeCreateBrush             = ($00F8 or GDIP_WMF_RECORD_BASE),  // META_CREATEBRUSH
    WmfRecordTypeCreatePatternBrush      = (META_CREATEPATTERNBRUSH or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeCreatePenIndirect       = (META_CREATEPENINDIRECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeCreateFontIndirect      = (META_CREATEFONTINDIRECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeCreateBrushIndirect     = (META_CREATEBRUSHINDIRECT or GDIP_WMF_RECORD_BASE),
    WmfRecordTypeCreateBitmapIndirect    = ($02FD or GDIP_WMF_RECORD_BASE),  // META_CREATEBITMAPINDIRECT
    WmfRecordTypeCreateBitmap            = ($06FE or GDIP_WMF_RECORD_BASE),  // META_CREATEBITMAP
    WmfRecordTypeCreateRegion            = (META_CREATEREGION or GDIP_WMF_RECORD_BASE),

    EmfRecordTypeHeader                  = EMR_HEADER,
    EmfRecordTypePolyBezier              = EMR_POLYBEZIER,
    EmfRecordTypePolygon                 = EMR_POLYGON,
    EmfRecordTypePolyline                = EMR_POLYLINE,
    EmfRecordTypePolyBezierTo            = EMR_POLYBEZIERTO,
    EmfRecordTypePolyLineTo              = EMR_POLYLINETO,
    EmfRecordTypePolyPolyline            = EMR_POLYPOLYLINE,
    EmfRecordTypePolyPolygon             = EMR_POLYPOLYGON,
    EmfRecordTypeSetWindowExtEx          = EMR_SETWINDOWEXTEX,
    EmfRecordTypeSetWindowOrgEx          = EMR_SETWINDOWORGEX,
    EmfRecordTypeSetViewportExtEx        = EMR_SETVIEWPORTEXTEX,
    EmfRecordTypeSetViewportOrgEx        = EMR_SETVIEWPORTORGEX,
    EmfRecordTypeSetBrushOrgEx           = EMR_SETBRUSHORGEX,
    EmfRecordTypeEOF                     = EMR_EOF,
    EmfRecordTypeSetPixelV               = EMR_SETPIXELV,
    EmfRecordTypeSetMapperFlags          = EMR_SETMAPPERFLAGS,
    EmfRecordTypeSetMapMode              = EMR_SETMAPMODE,
    EmfRecordTypeSetBkMode               = EMR_SETBKMODE,
    EmfRecordTypeSetPolyFillMode         = EMR_SETPOLYFILLMODE,
    EmfRecordTypeSetROP2                 = EMR_SETROP2,
    EmfRecordTypeSetStretchBltMode       = EMR_SETSTRETCHBLTMODE,
    EmfRecordTypeSetTextAlign            = EMR_SETTEXTALIGN,
    EmfRecordTypeSetColorAdjustment      = EMR_SETCOLORADJUSTMENT,
    EmfRecordTypeSetTextColor            = EMR_SETTEXTCOLOR,
    EmfRecordTypeSetBkColor              = EMR_SETBKCOLOR,
    EmfRecordTypeOffsetClipRgn           = EMR_OFFSETCLIPRGN,
    EmfRecordTypeMoveToEx                = EMR_MOVETOEX,
    EmfRecordTypeSetMetaRgn              = EMR_SETMETARGN,
    EmfRecordTypeExcludeClipRect         = EMR_EXCLUDECLIPRECT,
    EmfRecordTypeIntersectClipRect       = EMR_INTERSECTCLIPRECT,
    EmfRecordTypeScaleViewportExtEx      = EMR_SCALEVIEWPORTEXTEX,
    EmfRecordTypeScaleWindowExtEx        = EMR_SCALEWINDOWEXTEX,
    EmfRecordTypeSaveDC                  = EMR_SAVEDC,
    EmfRecordTypeRestoreDC               = EMR_RESTOREDC,
    EmfRecordTypeSetWorldTransform       = EMR_SETWORLDTRANSFORM,
    EmfRecordTypeModifyWorldTransform    = EMR_MODIFYWORLDTRANSFORM,
    EmfRecordTypeSelectObject            = EMR_SELECTOBJECT,
    EmfRecordTypeCreatePen               = EMR_CREATEPEN,
    EmfRecordTypeCreateBrushIndirect     = EMR_CREATEBRUSHINDIRECT,
    EmfRecordTypeDeleteObject            = EMR_DELETEOBJECT,
    EmfRecordTypeAngleArc                = EMR_ANGLEARC,
    EmfRecordTypeEllipse                 = EMR_ELLIPSE,
    EmfRecordTypeRectangle               = EMR_RECTANGLE,
    EmfRecordTypeRoundRect               = EMR_ROUNDRECT,
    EmfRecordTypeArc                     = EMR_ARC,
    EmfRecordTypeChord                   = EMR_CHORD,
    EmfRecordTypePie                     = EMR_PIE,
    EmfRecordTypeSelectPalette           = EMR_SELECTPALETTE,
    EmfRecordTypeCreatePalette           = EMR_CREATEPALETTE,
    EmfRecordTypeSetPaletteEntries       = EMR_SETPALETTEENTRIES,
    EmfRecordTypeResizePalette           = EMR_RESIZEPALETTE,
    EmfRecordTypeRealizePalette          = EMR_REALIZEPALETTE,
    EmfRecordTypeExtFloodFill            = EMR_EXTFLOODFILL,
    EmfRecordTypeLineTo                  = EMR_LINETO,
    EmfRecordTypeArcTo                   = EMR_ARCTO,
    EmfRecordTypePolyDraw                = EMR_POLYDRAW,
    EmfRecordTypeSetArcDirection         = EMR_SETARCDIRECTION,
    EmfRecordTypeSetMiterLimit           = EMR_SETMITERLIMIT,
    EmfRecordTypeBeginPath               = EMR_BEGINPATH,
    EmfRecordTypeEndPath                 = EMR_ENDPATH,
    EmfRecordTypeCloseFigure             = EMR_CLOSEFIGURE,
    EmfRecordTypeFillPath                = EMR_FILLPATH,
    EmfRecordTypeStrokeAndFillPath       = EMR_STROKEANDFILLPATH,
    EmfRecordTypeStrokePath              = EMR_STROKEPATH,
    EmfRecordTypeFlattenPath             = EMR_FLATTENPATH,
    EmfRecordTypeWidenPath               = EMR_WIDENPATH,
    EmfRecordTypeSelectClipPath          = EMR_SELECTCLIPPATH,
    EmfRecordTypeAbortPath               = EMR_ABORTPATH,
    EmfRecordTypeReserved_069            = 69,  // Not Used
    EmfRecordTypeGdiComment              = EMR_GDICOMMENT,
    EmfRecordTypeFillRgn                 = EMR_FILLRGN,
    EmfRecordTypeFrameRgn                = EMR_FRAMERGN,
    EmfRecordTypeInvertRgn               = EMR_INVERTRGN,
    EmfRecordTypePaintRgn                = EMR_PAINTRGN,
    EmfRecordTypeExtSelectClipRgn        = EMR_EXTSELECTCLIPRGN,
    EmfRecordTypeBitBlt                  = EMR_BITBLT,
    EmfRecordTypeStretchBlt              = EMR_STRETCHBLT,
    EmfRecordTypeMaskBlt                 = EMR_MASKBLT,
    EmfRecordTypePlgBlt                  = EMR_PLGBLT,
    EmfRecordTypeSetDIBitsToDevice       = EMR_SETDIBITSTODEVICE,
    EmfRecordTypeStretchDIBits           = EMR_STRETCHDIBITS,
    EmfRecordTypeExtCreateFontIndirect   = EMR_EXTCREATEFONTINDIRECTW,
    EmfRecordTypeExtTextOutA             = EMR_EXTTEXTOUTA,
    EmfRecordTypeExtTextOutW             = EMR_EXTTEXTOUTW,
    EmfRecordTypePolyBezier16            = EMR_POLYBEZIER16,
    EmfRecordTypePolygon16               = EMR_POLYGON16,
    EmfRecordTypePolyline16              = EMR_POLYLINE16,
    EmfRecordTypePolyBezierTo16          = EMR_POLYBEZIERTO16,
    EmfRecordTypePolylineTo16            = EMR_POLYLINETO16,
    EmfRecordTypePolyPolyline16          = EMR_POLYPOLYLINE16,
    EmfRecordTypePolyPolygon16           = EMR_POLYPOLYGON16,
    EmfRecordTypePolyDraw16              = EMR_POLYDRAW16,
    EmfRecordTypeCreateMonoBrush         = EMR_CREATEMONOBRUSH,
    EmfRecordTypeCreateDIBPatternBrushPt = EMR_CREATEDIBPATTERNBRUSHPT,
    EmfRecordTypeExtCreatePen            = EMR_EXTCREATEPEN,
    EmfRecordTypePolyTextOutA            = EMR_POLYTEXTOUTA,
    EmfRecordTypePolyTextOutW            = EMR_POLYTEXTOUTW,
    EmfRecordTypeSetICMMode              = 98,  // EMR_SETICMMODE,
    EmfRecordTypeCreateColorSpace        = 99,  // EMR_CREATECOLORSPACE,
    EmfRecordTypeSetColorSpace           = 100, // EMR_SETCOLORSPACE,
    EmfRecordTypeDeleteColorSpace        = 101, // EMR_DELETECOLORSPACE,
    EmfRecordTypeGLSRecord               = 102, // EMR_GLSRECORD,
    EmfRecordTypeGLSBoundedRecord        = 103, // EMR_GLSBOUNDEDRECORD,
    EmfRecordTypePixelFormat             = 104, // EMR_PIXELFORMAT,
    EmfRecordTypeDrawEscape              = 105, // EMR_RESERVED_105,
    EmfRecordTypeExtEscape               = 106, // EMR_RESERVED_106,
    EmfRecordTypeStartDoc                = 107, // EMR_RESERVED_107,
    EmfRecordTypeSmallTextOut            = 108, // EMR_RESERVED_108,
    EmfRecordTypeForceUFIMapping         = 109, // EMR_RESERVED_109,
    EmfRecordTypeNamedEscape             = 110, // EMR_RESERVED_110,
    EmfRecordTypeColorCorrectPalette     = 111, // EMR_COLORCORRECTPALETTE,
    EmfRecordTypeSetICMProfileA          = 112, // EMR_SETICMPROFILEA,
    EmfRecordTypeSetICMProfileW          = 113, // EMR_SETICMPROFILEW,
    EmfRecordTypeAlphaBlend              = 114, // EMR_ALPHABLEND,
    EmfRecordTypeSetLayout               = 115, // EMR_SETLAYOUT,
    EmfRecordTypeTransparentBlt          = 116, // EMR_TRANSPARENTBLT,
    EmfRecordTypeReserved_117            = 117, // Not Used
    EmfRecordTypeGradientFill            = 118, // EMR_GRADIENTFILL,
    EmfRecordTypeSetLinkedUFIs           = 119, // EMR_RESERVED_119,
    EmfRecordTypeSetTextJustification    = 120, // EMR_RESERVED_120,
    EmfRecordTypeColorMatchToTargetW     = 121, // EMR_COLORMATCHTOTARGETW,
    EmfRecordTypeCreateColorSpaceW       = 122, // EMR_CREATECOLORSPACEW,
    EmfRecordTypeMax                     = 122,
    EmfRecordTypeMin                     = 1,

    // That is the END of the GDI EMF records.

    // Now we start the list of EMF+ records.  We leave quite
    // a bit of room here for the addition of any new GDI
    // records that may be added later.

    EmfPlusRecordTypeInvalid = GDIP_EMFPLUS_RECORD_BASE,
    EmfPlusRecordTypeHeader,
    EmfPlusRecordTypeEndOfFile,

    EmfPlusRecordTypeComment,

    EmfPlusRecordTypeGetDC,

    EmfPlusRecordTypeMultiFormatStart,
    EmfPlusRecordTypeMultiFormatSection,
    EmfPlusRecordTypeMultiFormatEnd,

    // For all persistent objects

    EmfPlusRecordTypeObject,

    // Drawing Records

    EmfPlusRecordTypeClear,
    EmfPlusRecordTypeFillRects,
    EmfPlusRecordTypeDrawRects,
    EmfPlusRecordTypeFillPolygon,
    EmfPlusRecordTypeDrawLines,
    EmfPlusRecordTypeFillEllipse,
    EmfPlusRecordTypeDrawEllipse,
    EmfPlusRecordTypeFillPie,
    EmfPlusRecordTypeDrawPie,
    EmfPlusRecordTypeDrawArc,
    EmfPlusRecordTypeFillRegion,
    EmfPlusRecordTypeFillPath,
    EmfPlusRecordTypeDrawPath,
    EmfPlusRecordTypeFillClosedCurve,
    EmfPlusRecordTypeDrawClosedCurve,
    EmfPlusRecordTypeDrawCurve,
    EmfPlusRecordTypeDrawBeziers,
    EmfPlusRecordTypeDrawImage,
    EmfPlusRecordTypeDrawImagePoints,
    EmfPlusRecordTypeDrawString,

    // Graphics State Records

    EmfPlusRecordTypeSetRenderingOrigin,
    EmfPlusRecordTypeSetAntiAliasMode,
    EmfPlusRecordTypeSetTextRenderingHint,
    EmfPlusRecordTypeSetTextContrast,
    EmfPlusRecordTypeSetInterpolationMode,
    EmfPlusRecordTypeSetPixelOffsetMode,
    EmfPlusRecordTypeSetCompositingMode,
    EmfPlusRecordTypeSetCompositingQuality,
    EmfPlusRecordTypeSave,
    EmfPlusRecordTypeRestore,
    EmfPlusRecordTypeBeginContainer,
    EmfPlusRecordTypeBeginContainerNoParams,
    EmfPlusRecordTypeEndContainer,
    EmfPlusRecordTypeSetWorldTransform,
    EmfPlusRecordTypeResetWorldTransform,
    EmfPlusRecordTypeMultiplyWorldTransform,
    EmfPlusRecordTypeTranslateWorldTransform,
    EmfPlusRecordTypeScaleWorldTransform,
    EmfPlusRecordTypeRotateWorldTransform,
    EmfPlusRecordTypeSetPageTransform,
    EmfPlusRecordTypeResetClip,
    EmfPlusRecordTypeSetClipRect,
    EmfPlusRecordTypeSetClipPath,
    EmfPlusRecordTypeSetClipRegion,
    EmfPlusRecordTypeOffsetClip,

    EmfPlusRecordTypeDrawDriverString,

    EmfPlusRecordTotal,

    EmfPlusRecordTypeMax = EmfPlusRecordTotal-1,
    EmfPlusRecordTypeMin = EmfPlusRecordTypeHeader
  );
  TEmfPlusRecordType = EmfPlusRecordType;
{$ELSE}
type
  EmfPlusRecordType = Integer;
  // Since we have to enumerate GDI records right along with GDI+ records,
  // We list all the GDI records here so that they can be part of the
  // same enumeration type which is used in the enumeration callback.
  const
    WmfRecordTypeSetBkColor              = (META_SETBKCOLOR or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetBkMode               = (META_SETBKMODE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetMapMode              = (META_SETMAPMODE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetROP2                 = (META_SETROP2 or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetRelAbs               = (META_SETRELABS or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetPolyFillMode         = (META_SETPOLYFILLMODE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetStretchBltMode       = (META_SETSTRETCHBLTMODE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetTextCharExtra        = (META_SETTEXTCHAREXTRA or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetTextColor            = (META_SETTEXTCOLOR or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetTextJustification    = (META_SETTEXTJUSTIFICATION or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetWindowOrg            = (META_SETWINDOWORG or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetWindowExt            = (META_SETWINDOWEXT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetViewportOrg          = (META_SETVIEWPORTORG or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetViewportExt          = (META_SETVIEWPORTEXT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeOffsetWindowOrg         = (META_OFFSETWINDOWORG or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeScaleWindowExt          = (META_SCALEWINDOWEXT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeOffsetViewportOrg       = (META_OFFSETVIEWPORTORG or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeScaleViewportExt        = (META_SCALEVIEWPORTEXT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeLineTo                  = (META_LINETO or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeMoveTo                  = (META_MOVETO or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeExcludeClipRect         = (META_EXCLUDECLIPRECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeIntersectClipRect       = (META_INTERSECTCLIPRECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeArc                     = (META_ARC or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeEllipse                 = (META_ELLIPSE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeFloodFill               = (META_FLOODFILL or GDIP_WMF_RECORD_BASE);
    WmfRecordTypePie                     = (META_PIE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeRectangle               = (META_RECTANGLE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeRoundRect               = (META_ROUNDRECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypePatBlt                  = (META_PATBLT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSaveDC                  = (META_SAVEDC or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetPixel                = (META_SETPIXEL or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeOffsetClipRgn           = (META_OFFSETCLIPRGN or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeTextOut                 = (META_TEXTOUT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeBitBlt                  = (META_BITBLT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeStretchBlt              = (META_STRETCHBLT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypePolygon                 = (META_POLYGON or GDIP_WMF_RECORD_BASE);
    WmfRecordTypePolyline                = (META_POLYLINE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeEscape                  = (META_ESCAPE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeRestoreDC               = (META_RESTOREDC or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeFillRegion              = (META_FILLREGION or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeFrameRegion             = (META_FRAMEREGION or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeInvertRegion            = (META_INVERTREGION or GDIP_WMF_RECORD_BASE);
    WmfRecordTypePaintRegion             = (META_PAINTREGION or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSelectClipRegion        = (META_SELECTCLIPREGION or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSelectObject            = (META_SELECTOBJECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetTextAlign            = (META_SETTEXTALIGN or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeDrawText                = ($062F or GDIP_WMF_RECORD_BASE);  // META_DRAWTEXT
    WmfRecordTypeChord                   = (META_CHORD or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetMapperFlags          = (META_SETMAPPERFLAGS or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeExtTextOut              = (META_EXTTEXTOUT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetDIBToDev             = (META_SETDIBTODEV or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSelectPalette           = (META_SELECTPALETTE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeRealizePalette          = (META_REALIZEPALETTE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeAnimatePalette          = (META_ANIMATEPALETTE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetPalEntries           = (META_SETPALENTRIES or GDIP_WMF_RECORD_BASE);
    WmfRecordTypePolyPolygon             = (META_POLYPOLYGON or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeResizePalette           = (META_RESIZEPALETTE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeDIBBitBlt               = (META_DIBBITBLT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeDIBStretchBlt           = (META_DIBSTRETCHBLT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeDIBCreatePatternBrush   = (META_DIBCREATEPATTERNBRUSH or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeStretchDIB              = (META_STRETCHDIB or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeExtFloodFill            = (META_EXTFLOODFILL or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeSetLayout               = ($0149 or GDIP_WMF_RECORD_BASE);  // META_SETLAYOUT
    WmfRecordTypeResetDC                 = ($014C or GDIP_WMF_RECORD_BASE);  // META_RESETDC
    WmfRecordTypeStartDoc                = ($014D or GDIP_WMF_RECORD_BASE);  // META_STARTDOC
    WmfRecordTypeStartPage               = ($004F or GDIP_WMF_RECORD_BASE);  // META_STARTPAGE
    WmfRecordTypeEndPage                 = ($0050 or GDIP_WMF_RECORD_BASE);  // META_ENDPAGE
    WmfRecordTypeAbortDoc                = ($0052 or GDIP_WMF_RECORD_BASE);  // META_ABORTDOC
    WmfRecordTypeEndDoc                  = ($005E or GDIP_WMF_RECORD_BASE);  // META_ENDDOC
    WmfRecordTypeDeleteObject            = (META_DELETEOBJECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeCreatePalette           = (META_CREATEPALETTE or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeCreateBrush             = ($00F8 or GDIP_WMF_RECORD_BASE);  // META_CREATEBRUSH
    WmfRecordTypeCreatePatternBrush      = (META_CREATEPATTERNBRUSH or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeCreatePenIndirect       = (META_CREATEPENINDIRECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeCreateFontIndirect      = (META_CREATEFONTINDIRECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeCreateBrushIndirect     = (META_CREATEBRUSHINDIRECT or GDIP_WMF_RECORD_BASE);
    WmfRecordTypeCreateBitmapIndirect    = ($02FD or GDIP_WMF_RECORD_BASE);  // META_CREATEBITMAPINDIRECT
    WmfRecordTypeCreateBitmap            = ($06FE or GDIP_WMF_RECORD_BASE);  // META_CREATEBITMAP
    WmfRecordTypeCreateRegion            = (META_CREATEREGION or GDIP_WMF_RECORD_BASE);

    EmfRecordTypeHeader                  = EMR_HEADER;
    EmfRecordTypePolyBezier              = EMR_POLYBEZIER;
    EmfRecordTypePolygon                 = EMR_POLYGON;
    EmfRecordTypePolyline                = EMR_POLYLINE;
    EmfRecordTypePolyBezierTo            = EMR_POLYBEZIERTO;
    EmfRecordTypePolyLineTo              = EMR_POLYLINETO;
    EmfRecordTypePolyPolyline            = EMR_POLYPOLYLINE;
    EmfRecordTypePolyPolygon             = EMR_POLYPOLYGON;
    EmfRecordTypeSetWindowExtEx          = EMR_SETWINDOWEXTEX;
    EmfRecordTypeSetWindowOrgEx          = EMR_SETWINDOWORGEX;
    EmfRecordTypeSetViewportExtEx        = EMR_SETVIEWPORTEXTEX;
    EmfRecordTypeSetViewportOrgEx        = EMR_SETVIEWPORTORGEX;
    EmfRecordTypeSetBrushOrgEx           = EMR_SETBRUSHORGEX;
    EmfRecordTypeEOF                     = EMR_EOF;
    EmfRecordTypeSetPixelV               = EMR_SETPIXELV;
    EmfRecordTypeSetMapperFlags          = EMR_SETMAPPERFLAGS;
    EmfRecordTypeSetMapMode              = EMR_SETMAPMODE;
    EmfRecordTypeSetBkMode               = EMR_SETBKMODE;
    EmfRecordTypeSetPolyFillMode         = EMR_SETPOLYFILLMODE;
    EmfRecordTypeSetROP2                 = EMR_SETROP2;
    EmfRecordTypeSetStretchBltMode       = EMR_SETSTRETCHBLTMODE;
    EmfRecordTypeSetTextAlign            = EMR_SETTEXTALIGN;
    EmfRecordTypeSetColorAdjustment      = EMR_SETCOLORADJUSTMENT;
    EmfRecordTypeSetTextColor            = EMR_SETTEXTCOLOR;
    EmfRecordTypeSetBkColor              = EMR_SETBKCOLOR;
    EmfRecordTypeOffsetClipRgn           = EMR_OFFSETCLIPRGN;
    EmfRecordTypeMoveToEx                = EMR_MOVETOEX;
    EmfRecordTypeSetMetaRgn              = EMR_SETMETARGN;
    EmfRecordTypeExcludeClipRect         = EMR_EXCLUDECLIPRECT;
    EmfRecordTypeIntersectClipRect       = EMR_INTERSECTCLIPRECT;
    EmfRecordTypeScaleViewportExtEx      = EMR_SCALEVIEWPORTEXTEX;
    EmfRecordTypeScaleWindowExtEx        = EMR_SCALEWINDOWEXTEX;
    EmfRecordTypeSaveDC                  = EMR_SAVEDC;
    EmfRecordTypeRestoreDC               = EMR_RESTOREDC;
    EmfRecordTypeSetWorldTransform       = EMR_SETWORLDTRANSFORM;
    EmfRecordTypeModifyWorldTransform    = EMR_MODIFYWORLDTRANSFORM;
    EmfRecordTypeSelectObject            = EMR_SELECTOBJECT;
    EmfRecordTypeCreatePen               = EMR_CREATEPEN;
    EmfRecordTypeCreateBrushIndirect     = EMR_CREATEBRUSHINDIRECT;
    EmfRecordTypeDeleteObject            = EMR_DELETEOBJECT;
    EmfRecordTypeAngleArc                = EMR_ANGLEARC;
    EmfRecordTypeEllipse                 = EMR_ELLIPSE;
    EmfRecordTypeRectangle               = EMR_RECTANGLE;
    EmfRecordTypeRoundRect               = EMR_ROUNDRECT;
    EmfRecordTypeArc                     = EMR_ARC;
    EmfRecordTypeChord                   = EMR_CHORD;
    EmfRecordTypePie                     = EMR_PIE;
    EmfRecordTypeSelectPalette           = EMR_SELECTPALETTE;
    EmfRecordTypeCreatePalette           = EMR_CREATEPALETTE;
    EmfRecordTypeSetPaletteEntries       = EMR_SETPALETTEENTRIES;
    EmfRecordTypeResizePalette           = EMR_RESIZEPALETTE;
    EmfRecordTypeRealizePalette          = EMR_REALIZEPALETTE;
    EmfRecordTypeExtFloodFill            = EMR_EXTFLOODFILL;
    EmfRecordTypeLineTo                  = EMR_LINETO;
    EmfRecordTypeArcTo                   = EMR_ARCTO;
    EmfRecordTypePolyDraw                = EMR_POLYDRAW;
    EmfRecordTypeSetArcDirection         = EMR_SETARCDIRECTION;
    EmfRecordTypeSetMiterLimit           = EMR_SETMITERLIMIT;
    EmfRecordTypeBeginPath               = EMR_BEGINPATH;
    EmfRecordTypeEndPath                 = EMR_ENDPATH;
    EmfRecordTypeCloseFigure             = EMR_CLOSEFIGURE;
    EmfRecordTypeFillPath                = EMR_FILLPATH;
    EmfRecordTypeStrokeAndFillPath       = EMR_STROKEANDFILLPATH;
    EmfRecordTypeStrokePath              = EMR_STROKEPATH;
    EmfRecordTypeFlattenPath             = EMR_FLATTENPATH;
    EmfRecordTypeWidenPath               = EMR_WIDENPATH;
    EmfRecordTypeSelectClipPath          = EMR_SELECTCLIPPATH;
    EmfRecordTypeAbortPath               = EMR_ABORTPATH;
    EmfRecordTypeReserved_069            = 69;  // Not Used
    EmfRecordTypeGdiComment              = EMR_GDICOMMENT;
    EmfRecordTypeFillRgn                 = EMR_FILLRGN;
    EmfRecordTypeFrameRgn                = EMR_FRAMERGN;
    EmfRecordTypeInvertRgn               = EMR_INVERTRGN;
    EmfRecordTypePaintRgn                = EMR_PAINTRGN;
    EmfRecordTypeExtSelectClipRgn        = EMR_EXTSELECTCLIPRGN;
    EmfRecordTypeBitBlt                  = EMR_BITBLT;
    EmfRecordTypeStretchBlt              = EMR_STRETCHBLT;
    EmfRecordTypeMaskBlt                 = EMR_MASKBLT;
    EmfRecordTypePlgBlt                  = EMR_PLGBLT;
    EmfRecordTypeSetDIBitsToDevice       = EMR_SETDIBITSTODEVICE;
    EmfRecordTypeStretchDIBits           = EMR_STRETCHDIBITS;
    EmfRecordTypeExtCreateFontIndirect   = EMR_EXTCREATEFONTINDIRECTW;
    EmfRecordTypeExtTextOutA             = EMR_EXTTEXTOUTA;
    EmfRecordTypeExtTextOutW             = EMR_EXTTEXTOUTW;
    EmfRecordTypePolyBezier16            = EMR_POLYBEZIER16;
    EmfRecordTypePolygon16               = EMR_POLYGON16;
    EmfRecordTypePolyline16              = EMR_POLYLINE16;
    EmfRecordTypePolyBezierTo16          = EMR_POLYBEZIERTO16;
    EmfRecordTypePolylineTo16            = EMR_POLYLINETO16;
    EmfRecordTypePolyPolyline16          = EMR_POLYPOLYLINE16;
    EmfRecordTypePolyPolygon16           = EMR_POLYPOLYGON16;
    EmfRecordTypePolyDraw16              = EMR_POLYDRAW16;
    EmfRecordTypeCreateMonoBrush         = EMR_CREATEMONOBRUSH;
    EmfRecordTypeCreateDIBPatternBrushPt = EMR_CREATEDIBPATTERNBRUSHPT;
    EmfRecordTypeExtCreatePen            = EMR_EXTCREATEPEN;
    EmfRecordTypePolyTextOutA            = EMR_POLYTEXTOUTA;
    EmfRecordTypePolyTextOutW            = EMR_POLYTEXTOUTW;
    EmfRecordTypeSetICMMode              = 98;  // EMR_SETICMMODE,
    EmfRecordTypeCreateColorSpace        = 99;  // EMR_CREATECOLORSPACE,
    EmfRecordTypeSetColorSpace           = 100; // EMR_SETCOLORSPACE,
    EmfRecordTypeDeleteColorSpace        = 101; // EMR_DELETECOLORSPACE,
    EmfRecordTypeGLSRecord               = 102; // EMR_GLSRECORD,
    EmfRecordTypeGLSBoundedRecord        = 103; // EMR_GLSBOUNDEDRECORD,
    EmfRecordTypePixelFormat             = 104; // EMR_PIXELFORMAT,
    EmfRecordTypeDrawEscape              = 105; // EMR_RESERVED_105,
    EmfRecordTypeExtEscape               = 106; // EMR_RESERVED_106,
    EmfRecordTypeStartDoc                = 107; // EMR_RESERVED_107,
    EmfRecordTypeSmallTextOut            = 108; // EMR_RESERVED_108,
    EmfRecordTypeForceUFIMapping         = 109; // EMR_RESERVED_109,
    EmfRecordTypeNamedEscape             = 110; // EMR_RESERVED_110,
    EmfRecordTypeColorCorrectPalette     = 111; // EMR_COLORCORRECTPALETTE,
    EmfRecordTypeSetICMProfileA          = 112; // EMR_SETICMPROFILEA,
    EmfRecordTypeSetICMProfileW          = 113; // EMR_SETICMPROFILEW,
    EmfRecordTypeAlphaBlend              = 114; // EMR_ALPHABLEND,
    EmfRecordTypeSetLayout               = 115; // EMR_SETLAYOUT,
    EmfRecordTypeTransparentBlt          = 116; // EMR_TRANSPARENTBLT,
    EmfRecordTypeReserved_117            = 117; // Not Used
    EmfRecordTypeGradientFill            = 118; // EMR_GRADIENTFILL,
    EmfRecordTypeSetLinkedUFIs           = 119; // EMR_RESERVED_119,
    EmfRecordTypeSetTextJustification    = 120; // EMR_RESERVED_120,
    EmfRecordTypeColorMatchToTargetW     = 121; // EMR_COLORMATCHTOTARGETW,
    EmfRecordTypeCreateColorSpaceW       = 122; // EMR_CREATECOLORSPACEW,
    EmfRecordTypeMax                     = 122;
    EmfRecordTypeMin                     = 1;

    // That is the END of the GDI EMF records.

    // Now we start the list of EMF+ records.  We leave quite
    // a bit of room here for the addition of any new GDI
    // records that may be added later.

    EmfPlusRecordTypeInvalid   = GDIP_EMFPLUS_RECORD_BASE;
    EmfPlusRecordTypeHeader    = GDIP_EMFPLUS_RECORD_BASE + 1;
    EmfPlusRecordTypeEndOfFile = GDIP_EMFPLUS_RECORD_BASE + 2;

    EmfPlusRecordTypeComment   = GDIP_EMFPLUS_RECORD_BASE + 3;

    EmfPlusRecordTypeGetDC     = GDIP_EMFPLUS_RECORD_BASE + 4;

    EmfPlusRecordTypeMultiFormatStart   = GDIP_EMFPLUS_RECORD_BASE + 5;
    EmfPlusRecordTypeMultiFormatSection = GDIP_EMFPLUS_RECORD_BASE + 6;
    EmfPlusRecordTypeMultiFormatEnd     = GDIP_EMFPLUS_RECORD_BASE + 7;

    // For all persistent objects

    EmfPlusRecordTypeObject = GDIP_EMFPLUS_RECORD_BASE + 8;

    // Drawing Records

    EmfPlusRecordTypeClear           = GDIP_EMFPLUS_RECORD_BASE + 9;
    EmfPlusRecordTypeFillRects       = GDIP_EMFPLUS_RECORD_BASE + 10;
    EmfPlusRecordTypeDrawRects       = GDIP_EMFPLUS_RECORD_BASE + 11;
    EmfPlusRecordTypeFillPolygon     = GDIP_EMFPLUS_RECORD_BASE + 12;
    EmfPlusRecordTypeDrawLines       = GDIP_EMFPLUS_RECORD_BASE + 13;
    EmfPlusRecordTypeFillEllipse     = GDIP_EMFPLUS_RECORD_BASE + 14;
    EmfPlusRecordTypeDrawEllipse     = GDIP_EMFPLUS_RECORD_BASE + 15;
    EmfPlusRecordTypeFillPie         = GDIP_EMFPLUS_RECORD_BASE + 16;
    EmfPlusRecordTypeDrawPie         = GDIP_EMFPLUS_RECORD_BASE + 17;
    EmfPlusRecordTypeDrawArc         = GDIP_EMFPLUS_RECORD_BASE + 18;
    EmfPlusRecordTypeFillRegion      = GDIP_EMFPLUS_RECORD_BASE + 19;
    EmfPlusRecordTypeFillPath        = GDIP_EMFPLUS_RECORD_BASE + 20;
    EmfPlusRecordTypeDrawPath        = GDIP_EMFPLUS_RECORD_BASE + 21;
    EmfPlusRecordTypeFillClosedCurve = GDIP_EMFPLUS_RECORD_BASE + 22;
    EmfPlusRecordTypeDrawClosedCurve = GDIP_EMFPLUS_RECORD_BASE + 23;
    EmfPlusRecordTypeDrawCurve       = GDIP_EMFPLUS_RECORD_BASE + 24;
    EmfPlusRecordTypeDrawBeziers     = GDIP_EMFPLUS_RECORD_BASE + 25;
    EmfPlusRecordTypeDrawImage       = GDIP_EMFPLUS_RECORD_BASE + 26;
    EmfPlusRecordTypeDrawImagePoints = GDIP_EMFPLUS_RECORD_BASE + 27;
    EmfPlusRecordTypeDrawString      = GDIP_EMFPLUS_RECORD_BASE + 28;

    // Graphics State Records

    EmfPlusRecordTypeSetRenderingOrigin      = GDIP_EMFPLUS_RECORD_BASE + 29;
    EmfPlusRecordTypeSetAntiAliasMode        = GDIP_EMFPLUS_RECORD_BASE + 30;
    EmfPlusRecordTypeSetTextRenderingHint    = GDIP_EMFPLUS_RECORD_BASE + 31;
    EmfPlusRecordTypeSetTextContrast         = GDIP_EMFPLUS_RECORD_BASE + 32;
    EmfPlusRecordTypeSetInterpolationMode    = GDIP_EMFPLUS_RECORD_BASE + 33;
    EmfPlusRecordTypeSetPixelOffsetMode      = GDIP_EMFPLUS_RECORD_BASE + 34;
    EmfPlusRecordTypeSetCompositingMode      = GDIP_EMFPLUS_RECORD_BASE + 35;
    EmfPlusRecordTypeSetCompositingQuality   = GDIP_EMFPLUS_RECORD_BASE + 36;
    EmfPlusRecordTypeSave                    = GDIP_EMFPLUS_RECORD_BASE + 37;
    EmfPlusRecordTypeRestore                 = GDIP_EMFPLUS_RECORD_BASE + 38;
    EmfPlusRecordTypeBeginContainer          = GDIP_EMFPLUS_RECORD_BASE + 39;
    EmfPlusRecordTypeBeginContainerNoParams  = GDIP_EMFPLUS_RECORD_BASE + 40;
    EmfPlusRecordTypeEndContainer            = GDIP_EMFPLUS_RECORD_BASE + 41;
    EmfPlusRecordTypeSetWorldTransform       = GDIP_EMFPLUS_RECORD_BASE + 42;
    EmfPlusRecordTypeResetWorldTransform     = GDIP_EMFPLUS_RECORD_BASE + 43;
    EmfPlusRecordTypeMultiplyWorldTransform  = GDIP_EMFPLUS_RECORD_BASE + 44;
    EmfPlusRecordTypeTranslateWorldTransform = GDIP_EMFPLUS_RECORD_BASE + 45;
    EmfPlusRecordTypeScaleWorldTransform     = GDIP_EMFPLUS_RECORD_BASE + 46;
    EmfPlusRecordTypeRotateWorldTransform    = GDIP_EMFPLUS_RECORD_BASE + 47;
    EmfPlusRecordTypeSetPageTransform        = GDIP_EMFPLUS_RECORD_BASE + 48;
    EmfPlusRecordTypeResetClip               = GDIP_EMFPLUS_RECORD_BASE + 49;
    EmfPlusRecordTypeSetClipRect             = GDIP_EMFPLUS_RECORD_BASE + 50;
    EmfPlusRecordTypeSetClipPath             = GDIP_EMFPLUS_RECORD_BASE + 51;
    EmfPlusRecordTypeSetClipRegion           = GDIP_EMFPLUS_RECORD_BASE + 52;
    EmfPlusRecordTypeOffsetClip              = GDIP_EMFPLUS_RECORD_BASE + 53;

    EmfPlusRecordTypeDrawDriverString        = GDIP_EMFPLUS_RECORD_BASE + 54;

    EmfPlusRecordTotal                       = GDIP_EMFPLUS_RECORD_BASE + 55;

    EmfPlusRecordTypeMax = EmfPlusRecordTotal-1;
    EmfPlusRecordTypeMin = EmfPlusRecordTypeHeader;

type
  TEmfPlusRecordType = EmfPlusRecordType;
{$ENDIF}
//---------------------------------------------------------------------------
// StringFormatFlags
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// String format flags
//
//  DirectionRightToLeft          - For horizontal text, the reading order is
//                                  right to left. This value is called
//                                  the base embedding level by the Unicode
//                                  bidirectional engine.
//                                  For vertical text, columns are read from
//                                  right to left.
//                                  By default, horizontal or vertical text is
//                                  read from left to right.
//
//  DirectionVertical             - Individual lines of text are vertical. In
//                                  each line, characters progress from top to
//                                  bottom.
//                                  By default, lines of text are horizontal,
//                                  each new line below the previous line.
//
//  NoFitBlackBox                 - Allows parts of glyphs to overhang the
//                                  bounding rectangle.
//                                  By default glyphs are first aligned
//                                  inside the margines, then any glyphs which
//                                  still overhang the bounding box are
//                                  repositioned to avoid any overhang.
//                                  For example when an italic
//                                  lower case letter f in a font such as
//                                  Garamond is aligned at the far left of a
//                                  rectangle, the lower part of the f will
//                                  reach slightly further left than the left
//                                  edge of the rectangle. Setting this flag
//                                  will ensure the character aligns visually
//                                  with the lines above and below, but may
//                                  cause some pixels outside the formatting
//                                  rectangle to be clipped or painted.
//
//  DisplayFormatControl          - Causes control characters such as the
//                                  left-to-right mark to be shown in the
//                                  output with a representative glyph.
//
//  NoFontFallback                - Disables fallback to alternate fonts for
//                                  characters not supported in the requested
//                                  font. Any missing characters will be
//                                  be displayed with the fonts missing glyph,
//                                  usually an open square.
//
//  NoWrap                        - Disables wrapping of text between lines
//                                  when formatting within a rectangle.
//                                  NoWrap is implied when a point is passed
//                                  instead of a rectangle, or when the
//                                  specified rectangle has a zero line length.
//
//  NoClip                        - By default text is clipped to the
//                                  formatting rectangle. Setting NoClip
//                                  allows overhanging pixels to affect the
//                                  device outside the formatting rectangle.
//                                  Pixels at the end of the line may be
//                                  affected if the glyphs overhang their
//                                  cells, and either the NoFitBlackBox flag
//                                  has been set, or the glyph extends to far
//                                  to be fitted.
//                                  Pixels above/before the first line or
//                                  below/after the last line may be affected
//                                  if the glyphs extend beyond their cell
//                                  ascent / descent. This can occur rarely
//                                  with unusual diacritic mark combinations.

//---------------------------------------------------------------------------

  StringFormatFlags = Integer;
  const
    StringFormatFlagsDirectionRightToLeft        = $00000001;
    StringFormatFlagsDirectionVertical           = $00000002;
    StringFormatFlagsNoFitBlackBox               = $00000004;
    StringFormatFlagsDisplayFormatControl        = $00000020;
    StringFormatFlagsNoFontFallback              = $00000400;
    StringFormatFlagsMeasureTrailingSpaces       = $00000800;
    StringFormatFlagsNoWrap                      = $00001000;
    StringFormatFlagsLineLimit                   = $00002000;

    StringFormatFlagsNoClip                      = $00004000;

Type
  TStringFormatFlags = StringFormatFlags;

//---------------------------------------------------------------------------
// StringTrimming
//---------------------------------------------------------------------------

  StringTrimming = (
    StringTrimmingNone,
    StringTrimmingCharacter,
    StringTrimmingWord,
    StringTrimmingEllipsisCharacter,
    StringTrimmingEllipsisWord,
    StringTrimmingEllipsisPath
  );
  TStringTrimming = StringTrimming;

//---------------------------------------------------------------------------
// National language digit substitution
//---------------------------------------------------------------------------

  StringDigitSubstitute = (
    StringDigitSubstituteUser,          // As NLS setting
    StringDigitSubstituteNone,
    StringDigitSubstituteNational,
    StringDigitSubstituteTraditional
  );
  TStringDigitSubstitute = StringDigitSubstitute;
  PStringDigitSubstitute = ^TStringDigitSubstitute;

//---------------------------------------------------------------------------
// Hotkey prefix interpretation
//---------------------------------------------------------------------------

  HotkeyPrefix = (
    HotkeyPrefixNone,
    HotkeyPrefixShow,
    HotkeyPrefixHide
  );
  THotkeyPrefix = HotkeyPrefix;

//---------------------------------------------------------------------------
// String alignment flags
//---------------------------------------------------------------------------

  StringAlignment = (
    // Left edge for left-to-right text,
    // right for right-to-left text,
    // and top for vertical
    StringAlignmentNear,
    StringAlignmentCenter,
    StringAlignmentFar
  );
  TStringAlignment = StringAlignment;

//---------------------------------------------------------------------------
// DriverStringOptions
//---------------------------------------------------------------------------

  DriverStringOptions = Integer;
  const
    DriverStringOptionsCmapLookup             = 1;
    DriverStringOptionsVertical               = 2;
    DriverStringOptionsRealizedAdvance        = 4;
    DriverStringOptionsLimitSubpixel          = 8;

type
  TDriverStringOptions = DriverStringOptions;

//---------------------------------------------------------------------------
// Flush Intention flags
//---------------------------------------------------------------------------

  FlushIntention = (
    FlushIntentionFlush,  // Flush all batched rendering operations
    FlushIntentionSync    // Flush all batched rendering operations
                          // and wait for them to complete
  );
  TFlushIntention = FlushIntention;

//---------------------------------------------------------------------------
// Image encoder parameter related types
//---------------------------------------------------------------------------

  EncoderParameterValueType = Integer;
  const
    EncoderParameterValueTypeByte          : Integer = 1;    // 8-bit unsigned int
    EncoderParameterValueTypeASCII         : Integer = 2;    // 8-bit byte containing one 7-bit ASCII
                                                             // code. NULL terminated.
    EncoderParameterValueTypeShort         : Integer = 3;    // 16-bit unsigned int
    EncoderParameterValueTypeLong          : Integer = 4;    // 32-bit unsigned int
    EncoderParameterValueTypeRational      : Integer = 5;    // Two Longs. The first Long is the
                                                             // numerator, the second Long expresses the
                                                             // denomintor.
    EncoderParameterValueTypeLongRange     : Integer = 6;    // Two longs which specify a range of
                                                             // integer values. The first Long specifies
                                                             // the lower end and the second one
                                                             // specifies the higher end. All values
                                                             // are inclusive at both ends
    EncoderParameterValueTypeUndefined     : Integer = 7;    // 8-bit byte that can take any value
                                                             // depending on field definition
    EncoderParameterValueTypeRationalRange : Integer = 8;    // Two Rationals. The first Rational
                                                             // specifies the lower end and the second
                                                             // specifies the higher end. All values
                                                             // are inclusive at both ends
type
  TEncoderParameterValueType = EncoderParameterValueType;

//---------------------------------------------------------------------------
// Image encoder value types
//---------------------------------------------------------------------------

  EncoderValue = (
    EncoderValueColorTypeCMYK,
    EncoderValueColorTypeYCCK,
    EncoderValueCompressionLZW,
    EncoderValueCompressionCCITT3,
    EncoderValueCompressionCCITT4,
    EncoderValueCompressionRle,
    EncoderValueCompressionNone,
    EncoderValueScanMethodInterlaced,
    EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87,
    EncoderValueVersionGif89,
    EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive,
    EncoderValueTransformRotate90,
    EncoderValueTransformRotate180,
    EncoderValueTransformRotate270,
    EncoderValueTransformFlipHorizontal,
    EncoderValueTransformFlipVertical,
    EncoderValueMultiFrame,
    EncoderValueLastFrame,
    EncoderValueFlush,
    EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution,
    EncoderValueFrameDimensionPage
  );
  TEncoderValue = EncoderValue;

//---------------------------------------------------------------------------
// Conversion of Emf To WMF Bits flags
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  EmfToWmfBitsFlags = (
    EmfToWmfBitsFlagsDefault          = $00000000,
    EmfToWmfBitsFlagsEmbedEmf         = $00000001,
    EmfToWmfBitsFlagsIncludePlaceable = $00000002,
    EmfToWmfBitsFlagsNoXORClip        = $00000004
  );
  TEmfToWmfBitsFlags = EmfToWmfBitsFlags;
{$ELSE}
  EmfToWmfBitsFlags = Integer;
  const
    EmfToWmfBitsFlagsDefault          = $00000000;
    EmfToWmfBitsFlagsEmbedEmf         = $00000001;
    EmfToWmfBitsFlagsIncludePlaceable = $00000002;
    EmfToWmfBitsFlagsNoXORClip        = $00000004;
    
type
  TEmfToWmfBitsFlags = EmfToWmfBitsFlags;
{$ENDIF}
(**************************************************************************\
*
*   GDI+ Types
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Callback functions
//--------------------------------------------------------------------------

//ImageAbort = function: BOOL; stdcall; ???
  ImageAbort = function(AData :Pointer): BOOL; stdcall;
  DrawImageAbort         = ImageAbort;
  GetThumbnailImageAbort = ImageAbort;


  // Callback for EnumerateMetafile methods.  The parameters are:

  //      recordType      WMF, EMF, or EMF+ record type
  //      flags           (always 0 for WMF/EMF records)
  //      dataSize        size of the record data (in bytes), or 0 if no data
  //      data            pointer to the record data, or NULL if no data
  //      callbackData    pointer to callbackData, if any

  // This method can then call Metafile::PlayRecord to play the
  // record that was just enumerated.  If this method  returns
  // FALSE, the enumeration process is aborted.  Otherwise, it continues.

  EnumerateMetafileProc = function(recordType: EmfPlusRecordType; flags: UINT;
    dataSize: UINT; data: PBYTE; callbackData: pointer): BOOL; stdcall;

//--------------------------------------------------------------------------
// Primitive data types
//
// NOTE:
//  Types already defined in standard header files:
//      INT8
//      UINT8
//      INT16
//      UINT16
//      INT32
//      UINT32
//      INT64
//      UINT64
//
//  Avoid using the following types:
//      LONG - use INT
//      ULONG - use UINT
//      DWORD - use UINT32
//--------------------------------------------------------------------------

const
  { from float.h }
  FLT_MAX =  3.402823466e+38; // max value
  FLT_MIN =  1.175494351e-38; // min positive value

  REAL_MAX           = FLT_MAX;
  REAL_MIN           = FLT_MIN;
  REAL_TOLERANCE     = (FLT_MIN * 100);
  REAL_EPSILON       = 1.192092896e-07;        // FLT_EPSILON

//--------------------------------------------------------------------------
// Status return values from GDI+ methods
//--------------------------------------------------------------------------
type
  Status = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );
  TStatus = Status;

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPSizeF = ^TGPSizeF;
  TGPSizeF = record
    Width  : Single;
    Height : Single;
  end;

  function MakeSize(Width, Height: Single): TGPSizeF; overload;

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPSize = ^TGPSize;
  TGPSize = record
    Width  : Integer;
    Height : Integer;
  end;

  function MakeSize(Width, Height: Integer): TGPSize; overload;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPPointF = ^TGPPointF;
  TGPPointF = record
    X : Single;
    Y : Single;
  end;
  TPointFDynArray = array of TGPPointF;

  function MakePoint(X, Y: Single): TGPPointF; overload;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPPoint = ^TGPPoint;
  TGPPoint = record
    X : Integer;
    Y : Integer;
  end;
  TPointDynArray = array of TGPPoint;

  function MakePoint(X, Y: Integer): TGPPoint; overload;

//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPRectF = ^TGPRectF;
  TGPRectF = record
    X     : Single;
    Y     : Single;
    Width : Single;
    Height: Single;
  end;
  TRectFDynArray = array of TGPRectF;

  function MakeRect(x, y, width, height: Single): TGPRectF; overload;
  function MakeRect(location: TGPPointF; size: TGPSizeF): TGPRectF; overload;

type
  PGPRect = ^TGPRect;
  TGPRect = record
    X     : Integer;
    Y     : Integer;
    Width : Integer;
    Height: Integer;
  end;
  TRectDynArray = array of TGPRect;

  function MakeRect(x, y, width, height: Integer): TGPRect; overload;
  function MakeRect(location: TGPPoint; size: TGPSize): TGPRect; overload;
  function MakeRect(const Rect: TRect): TGPRect; overload;

type
  TPathData = class
  public
    Count  : Integer;
    Points : PGPPointF;
    Types  : PBYTE;
    constructor Create;
    destructor Destroy; override;
  end;

  PCharacterRange = ^TCharacterRange;
  TCharacterRange = record
    First  : Integer;
    Length : Integer;
  end;

  function MakeCharacterRange(First, Length: Integer): TCharacterRange;

(**************************************************************************
*
*   GDI+ Startup and Shutdown APIs
*
**************************************************************************)
type
  DebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning
  );
  TDebugEventLevel = DebugEventLevel;

  // Callback function that GDI+ can call, on debug builds, for assertions
  // and warnings.

  DebugEventProc = procedure(level: DebugEventLevel; message: PWideChar); stdcall;

  // Notification functions which the user must call appropriately if
  // "SuppressBackgroundThread" (below) is set.

  NotificationHookProc = function(out token: ULONG): Status; stdcall;
  NotificationUnhookProc = procedure(token: ULONG); stdcall;

  // Input structure for GdiplusStartup

{$ALIGN 8}
  GdiplusStartupInput = record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : DebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call
                                              // the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use
  end;                                        // its internal image codecs.
  TGdiplusStartupInput = GdiplusStartupInput;
  PGdiplusStartupInput = ^TGdiplusStartupInput;
{$ALIGN ON}

  // Output structure for GdiplusStartup()

  GdiplusStartupOutput = record
    // The following 2 fields are NULL if SuppressBackgroundThread is FALSE.
    // Otherwise, they are functions which must be called appropriately to
    // replace the background thread.
    //
    // These should be called on the application's main message loop - i.e.
    // a message loop which is active for the lifetime of GDI+.
    // "NotificationHook" should be called before starting the loop,
    // and "NotificationUnhook" should be called after the loop ends.

    NotificationHook  : NotificationHookProc;
    NotificationUnhook: NotificationUnhookProc;
  end;
  TGdiplusStartupOutput = GdiplusStartupOutput;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;

  // GDI+ initialization. Must not be called from DllMain - can cause deadlock.
  //
  // Must be called before GDI+ API's or constructors are used.
  //
  // token  - may not be NULL - accepts a token to be passed in the corresponding
  //          GdiplusShutdown call.
  // input  - may not be NULL
  // output - may be NULL only if input->SuppressBackgroundThread is FALSE.

 function GdiplusStartup(out token: ULONG; input: PGdiplusStartupInput;
   output: PGdiplusStartupOutput): Status; stdcall;

  // GDI+ termination. Must be called before GDI+ is unloaded.
  // Must not be called from DllMain - can cause deadlock.
  //
  // GDI+ API's may not be called after GdiplusShutdown. Pay careful attention
  // to GDI+ object destructors.

  procedure GdiplusShutdown(token: ULONG); stdcall;


(**************************************************************************\
*
* Copyright (c) 1998-2001, Microsoft Corp.  All Rights Reserved.
* Module Name:
*   Gdiplus Pixel Formats
* Abstract:
*   GDI+ Pixel Formats
*
\**************************************************************************)

type
  PARGB  = ^ARGB;
  ARGB   = DWORD;
  ARGB64 = Int64;

const
  ALPHA_SHIFT = 24;
  RED_SHIFT   = 16;
  GREEN_SHIFT = 8;
  BLUE_SHIFT  = 0;
  ALPHA_MASK  = (ARGB($ff) shl ALPHA_SHIFT);

  // In-memory pixel data formats:
  // bits 0-7 = format index
  // bits 8-15 = pixel size (in bits)
  // bits 16-23 = flags
  // bits 24-31 = reserved

type
  PixelFormat = Integer;
  TPixelFormat = PixelFormat;

const
  PixelFormatIndexed     = $00010000; // Indexes into a palette
  PixelFormatGDI         = $00020000; // Is a GDI-supported format
  PixelFormatAlpha       = $00040000; // Has an alpha component
  PixelFormatPAlpha      = $00080000; // Pre-multiplied alpha
  PixelFormatExtended    = $00100000; // Extended color 16 bits/channel
  PixelFormatCanonical   = $00200000;

  PixelFormatUndefined      = 0;
  PixelFormatDontCare       = 0;

  PixelFormat1bppIndexed    = (1  or ( 1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat4bppIndexed    = (2  or ( 4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat8bppIndexed    = (3  or ( 8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat16bppGrayScale = (4  or (16 shl 8) or PixelFormatExtended);
  PixelFormat16bppRGB555    = (5  or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppRGB565    = (6  or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppARGB1555  = (7  or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  PixelFormat24bppRGB       = (8  or (24 shl 8) or PixelFormatGDI);
  PixelFormat32bppRGB       = (9  or (32 shl 8) or PixelFormatGDI);
  PixelFormat32bppARGB      = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  PixelFormat32bppPARGB     = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  PixelFormat48bppRGB       = (12 or (48 shl 8) or PixelFormatExtended);
  PixelFormat64bppARGB      = (13 or (64 shl 8) or PixelFormatAlpha  or PixelFormatCanonical or PixelFormatExtended);
  PixelFormat64bppPARGB     = (14 or (64 shl 8) or PixelFormatAlpha  or PixelFormatPAlpha or PixelFormatExtended);
  PixelFormatMax            = 15;

function GetPixelFormatSize(pixfmt: PixelFormat): UINT;
function IsIndexedPixelFormat(pixfmt: PixelFormat): BOOL;
function IsAlphaPixelFormat(pixfmt: PixelFormat): BOOL;
function IsExtendedPixelFormat(pixfmt: PixelFormat): BOOL;

//--------------------------------------------------------------------------
// Determine if the Pixel Format is Canonical format:
//   PixelFormat32bppARGB
//   PixelFormat32bppPARGB
//   PixelFormat64bppARGB
//   PixelFormat64bppPARGB
//--------------------------------------------------------------------------

function IsCanonicalPixelFormat(pixfmt: PixelFormat): BOOL;

{$IFDEF DELPHI6_UP}
type
  PaletteFlags = (
    PaletteFlagsHasAlpha    = $0001,
    PaletteFlagsGrayScale   = $0002,
    PaletteFlagsHalftone    = $0004
  );
  TPaletteFlags = PaletteFlags;
{$ELSE}
type
  PaletteFlags = Integer;
  const
    PaletteFlagsHasAlpha    = $0001;
    PaletteFlagsGrayScale   = $0002;
    PaletteFlagsHalftone    = $0004;

type
  TPaletteFlags = PaletteFlags;
{$ENDIF}

  ColorPalette = record
    Flags  : UINT ;                 // Palette flags
    Count  : UINT ;                 // Number of color entries
    Entries: array [0..0] of ARGB ; // Palette color entries
  end;

  TColorPalette = ColorPalette;
  PColorPalette = ^TColorPalette;

(**************************************************************************\
*
*   GDI+ Color Object
*
\**************************************************************************)

//----------------------------------------------------------------------------
// Color mode
//----------------------------------------------------------------------------

  ColorMode = (
    ColorModeARGB32,
    ColorModeARGB64
  );
  TColorMode = ColorMode;

//----------------------------------------------------------------------------
// Color Channel flags 
//----------------------------------------------------------------------------

  ColorChannelFlags = (
    ColorChannelFlagsC,
    ColorChannelFlagsM,
    ColorChannelFlagsY,
    ColorChannelFlagsK,
    ColorChannelFlagsLast
  );
  TColorChannelFlags = ColorChannelFlags;

//----------------------------------------------------------------------------
// Color
//----------------------------------------------------------------------------

  // Common color constants
const
  aclAliceBlue            = $FFF0F8FF;
  aclAntiqueWhite         = $FFFAEBD7;
  aclAqua                 = $FF00FFFF;
  aclAquamarine           = $FF7FFFD4;
  aclAzure                = $FFF0FFFF;
  aclBeige                = $FFF5F5DC;
  aclBisque               = $FFFFE4C4;
  aclBlack                = $FF000000;
  aclBlanchedAlmond       = $FFFFEBCD;
  aclBlue                 = $FF0000FF;
  aclBlueViolet           = $FF8A2BE2;
  aclBrown                = $FFA52A2A;
  aclBurlyWood            = $FFDEB887;
  aclCadetBlue            = $FF5F9EA0;
  aclChartreuse           = $FF7FFF00;
  aclChocolate            = $FFD2691E;
  aclCoral                = $FFFF7F50;
  aclCornflowerBlue       = $FF6495ED;
  aclCornsilk             = $FFFFF8DC;
  aclCrimson              = $FFDC143C;
  aclCyan                 = $FF00FFFF;
  aclDarkBlue             = $FF00008B;
  aclDarkCyan             = $FF008B8B;
  aclDarkGoldenrod        = $FFB8860B;
  aclDarkGray             = $FFA9A9A9;
  aclDarkGreen            = $FF006400;
  aclDarkKhaki            = $FFBDB76B;
  aclDarkMagenta          = $FF8B008B;
  aclDarkOliveGreen       = $FF556B2F;
  aclDarkOrange           = $FFFF8C00;
  aclDarkOrchid           = $FF9932CC;
  aclDarkRed              = $FF8B0000;
  aclDarkSalmon           = $FFE9967A;
  aclDarkSeaGreen         = $FF8FBC8B;
  aclDarkSlateBlue        = $FF483D8B;
  aclDarkSlateGray        = $FF2F4F4F;
  aclDarkTurquoise        = $FF00CED1;
  aclDarkViolet           = $FF9400D3;
  aclDeepPink             = $FFFF1493;
  aclDeepSkyBlue          = $FF00BFFF;
  aclDimGray              = $FF696969;
  aclDodgerBlue           = $FF1E90FF;
  aclFirebrick            = $FFB22222;
  aclFloralWhite          = $FFFFFAF0;
  aclForestGreen          = $FF228B22;
  aclFuchsia              = $FFFF00FF;
  aclGainsboro            = $FFDCDCDC;
  aclGhostWhite           = $FFF8F8FF;
  aclGold                 = $FFFFD700;
  aclGoldenrod            = $FFDAA520;
  aclGray                 = $FF808080;
  aclGreen                = $FF008000;
  aclGreenYellow          = $FFADFF2F;
  aclHoneydew             = $FFF0FFF0;
  aclHotPink              = $FFFF69B4;
  aclIndianRed            = $FFCD5C5C;
  aclIndigo               = $FF4B0082;
  aclIvory                = $FFFFFFF0;
  aclKhaki                = $FFF0E68C;
  aclLavender             = $FFE6E6FA;
  aclLavenderBlush        = $FFFFF0F5;
  aclLawnGreen            = $FF7CFC00;
  aclLemonChiffon         = $FFFFFACD;
  aclLightBlue            = $FFADD8E6;
  aclLightCoral           = $FFF08080;
  aclLightCyan            = $FFE0FFFF;
  aclLightGoldenrodYellow = $FFFAFAD2;
  aclLightGray            = $FFD3D3D3;
  aclLightGreen           = $FF90EE90;
  aclLightPink            = $FFFFB6C1;
  aclLightSalmon          = $FFFFA07A;
  aclLightSeaGreen        = $FF20B2AA;
  aclLightSkyBlue         = $FF87CEFA;
  aclLightSlateGray       = $FF778899;
  aclLightSteelBlue       = $FFB0C4DE;
  aclLightYellow          = $FFFFFFE0;
  aclLime                 = $FF00FF00;
  aclLimeGreen            = $FF32CD32;
  aclLinen                = $FFFAF0E6;
  aclMagenta              = $FFFF00FF;
  aclMaroon               = $FF800000;
  aclMediumAquamarine     = $FF66CDAA;
  aclMediumBlue           = $FF0000CD;
  aclMediumOrchid         = $FFBA55D3;
  aclMediumPurple         = $FF9370DB;
  aclMediumSeaGreen       = $FF3CB371;
  aclMediumSlateBlue      = $FF7B68EE;
  aclMediumSpringGreen    = $FF00FA9A;
  aclMediumTurquoise      = $FF48D1CC;
  aclMediumVioletRed      = $FFC71585;
  aclMidnightBlue         = $FF191970;
  aclMintCream            = $FFF5FFFA;
  aclMistyRose            = $FFFFE4E1;
  aclMoccasin             = $FFFFE4B5;
  aclNavajoWhite          = $FFFFDEAD;
  aclNavy                 = $FF000080;
  aclOldLace              = $FFFDF5E6;
  aclOlive                = $FF808000;
  aclOliveDrab            = $FF6B8E23;
  aclOrange               = $FFFFA500;
  aclOrangeRed            = $FFFF4500;
  aclOrchid               = $FFDA70D6;
  aclPaleGoldenrod        = $FFEEE8AA;
  aclPaleGreen            = $FF98FB98;
  aclPaleTurquoise        = $FFAFEEEE;
  aclPaleVioletRed        = $FFDB7093;
  aclPapayaWhip           = $FFFFEFD5;
  aclPeachPuff            = $FFFFDAB9;
  aclPeru                 = $FFCD853F;
  aclPink                 = $FFFFC0CB;
  aclPlum                 = $FFDDA0DD;
  aclPowderBlue           = $FFB0E0E6;
  aclPurple               = $FF800080;
  aclRed                  = $FFFF0000;
  aclRosyBrown            = $FFBC8F8F;
  aclRoyalBlue            = $FF4169E1;
  aclSaddleBrown          = $FF8B4513;
  aclSalmon               = $FFFA8072;
  aclSandyBrown           = $FFF4A460;
  aclSeaGreen             = $FF2E8B57;
  aclSeaShell             = $FFFFF5EE;
  aclSienna               = $FFA0522D;
  aclSilver               = $FFC0C0C0;
  aclSkyBlue              = $FF87CEEB;
  aclSlateBlue            = $FF6A5ACD;
  aclSlateGray            = $FF708090;
  aclSnow                 = $FFFFFAFA;
  aclSpringGreen          = $FF00FF7F;
  aclSteelBlue            = $FF4682B4;
  aclTan                  = $FFD2B48C;
  aclTeal                 = $FF008080;
  aclThistle              = $FFD8BFD8;
  aclTomato               = $FFFF6347;
  aclTransparent          = $00FFFFFF;
  aclTurquoise            = $FF40E0D0;
  aclViolet               = $FFEE82EE;
  aclWheat                = $FFF5DEB3;
  aclWhite                = $FFFFFFFF;
  aclWhiteSmoke           = $FFF5F5F5;
  aclYellow               = $FFFFFF00;
  aclYellowGreen          = $FF9ACD32;

  // Shift count and bit mask for A, R, G, B components
  AlphaShift  = 24;
  RedShift    = 16;
  GreenShift  = 8;
  BlueShift   = 0;

  AlphaMask   = $ff000000;
  RedMask     = $00ff0000;
  GreenMask   = $0000ff00;
  BlueMask    = $000000ff;


type
{  TGPColor = class
  protected
     Argb: ARGB;
  public
    constructor Create; overload;
    constructor Create(r, g, b: Byte); overload;
    constructor Create(a, r, g, b: Byte); overload;
    constructor Create(Value: ARGB); overload;
    function GetAlpha: BYTE;
    function GetA: BYTE;
    function GetRed: BYTE;
    function GetR: BYTE;
    function GetGreen: Byte;
    function GetG: Byte;
    function GetBlue: Byte;
    function GetB: Byte;
    function GetValue: ARGB;
    procedure SetValue(Value: ARGB);
    procedure SetFromCOLORREF(rgb: COLORREF);
    function ToCOLORREF: COLORREF;
    function MakeARGB(a, r, g, b: Byte): ARGB;
  end;  }

  PGPColor = ^TGPColor;
  TGPColor = ARGB;
  TColorDynArray = array of TGPColor;

function MakeColor(r, g, b: Byte): ARGB; overload; inline;
function MakeColor(a, r, g, b: Byte): ARGB; overload; inline;
function GetAlpha(color: ARGB): BYTE; inline;
function GetRed(color: ARGB): BYTE; inline;
function GetGreen(color: ARGB): BYTE; inline;
function GetBlue(color: ARGB): BYTE; inline;
function ColorRefToARGB(rgb: COLORREF): ARGB; inline;
function ARGBToColorRef(Color: ARGB): COLORREF; inline;


(**************************************************************************\
*
*   GDI+ Metafile Related Structures
*
\**************************************************************************)

type
  { from Windef.h }
  RECTL = Windows.TRect;
  SIZEL = Windows.TSize;

  ENHMETAHEADER3 = record
    iType          : DWORD;  // Record type EMR_HEADER
    nSize          : DWORD;  // Record size in bytes.  This may be greater
                             // than the sizeof(ENHMETAHEADER).
    rclBounds      : RECTL;  // Inclusive-inclusive bounds in device units
    rclFrame       : RECTL;  // Inclusive-inclusive Picture Frame .01mm unit
    dSignature     : DWORD;  // Signature.  Must be ENHMETA_SIGNATURE.
    nVersion       : DWORD;  // Version number
    nBytes         : DWORD;  // Size of the metafile in bytes
    nRecords       : DWORD;  // Number of records in the metafile
    nHandles       : WORD;   // Number of handles in the handle table
                             // Handle index zero is reserved.
    sReserved      : WORD;   // Reserved.  Must be zero.
    nDescription   : DWORD;  // Number of chars in the unicode desc string
                             // This is 0 if there is no description string
    offDescription : DWORD;  // Offset to the metafile description record.
                             // This is 0 if there is no description string
    nPalEntries    : DWORD;  // Number of entries in the metafile palette.
    szlDevice      : SIZEL;  // Size of the reference device in pels
    szlMillimeters : SIZEL;  // Size of the reference device in millimeters

    cbPixelFormat  : DWORD;  // Size of PIXELFORMATDESCRIPTOR information
                             // This is 0 if no pixel format is set
    offPixelFormat : DWORD;  // Offset to PIXELFORMATDESCRIPTOR
                             // This is 0 if no pixel format is set
    bOpenGL        : DWORD;  // TRUE if OpenGL commands are present in
                             // the metafile, otherwise FALSE

    szlMicrometers : SIZEL;  // Size of the reference device in micrometers
  end;
  TENHMETAHEADER3 = ENHMETAHEADER3;
  PENHMETAHEADER3 = ^TENHMETAHEADER3;

  // Placeable WMFs

  // Placeable Metafiles were created as a non-standard way of specifying how
  // a metafile is mapped and scaled on an output device.
  // Placeable metafiles are quite wide-spread, but not directly supported by
  // the Windows API. To playback a placeable metafile using the Windows API,
  // you will first need to strip the placeable metafile header from the file.
  // This is typically performed by copying the metafile to a temporary file
  // starting at file offset 22 (0x16). The contents of the temporary file may
  // then be used as input to the Windows GetMetaFile(), PlayMetaFile(),
  // CopyMetaFile(), etc. GDI functions.

  // Each placeable metafile begins with a 22-byte header,
  //  followed by a standard metafile:

  PWMFRect16 = record
    Left   : INT16;
    Top    : INT16;
    Right  : INT16;
    Bottom : INT16;
  end;
  TPWMFRect16 = PWMFRect16;
  PPWMFRect16 = ^TPWMFRect16;
{$ALIGN 1}
  WmfPlaceableFileHeader = record
    Key         : UINT32;      // GDIP_WMF_PLACEABLEKEY
    Hmf         : INT16;       // Metafile HANDLE number (always 0)
    BoundingBox : PWMFRect16;  // Coordinates in metafile units
    Inch        : INT16;       // Number of metafile units per inch
    Reserved    : UINT32;      // Reserved (always 0)
    Checksum    : INT16;       // Checksum value for previous 10 WORDs
  end;
  TWmfPlaceableFileHeader = WmfPlaceableFileHeader;
  PWmfPlaceableFileHeader = ^TWmfPlaceableFileHeader;
{$ALIGN ON}
  // Key contains a special identification value that indicates the presence
  // of a placeable metafile header and is always 0x9AC6CDD7.

  // Handle is used to stored the handle of the metafile in memory. When written
  // to disk, this field is not used and will always contains the value 0.

  // Left, Top, Right, and Bottom contain the coordinates of the upper-left
  // and lower-right corners of the image on the output device. These are
  // measured in twips.

  // A twip (meaning "twentieth of a point") is the logical unit of measurement
  // used in Windows Metafiles. A twip is equal to 1/1440 of an inch. Thus 720
  // twips equal 1/2 inch, while 32,768 twips is 22.75 inches.

  // Inch contains the number of twips per inch used to represent the image.
  // Normally, there are 1440 twips per inch; however, this number may be
  // changed to scale the image. A value of 720 indicates that the image is
  // double its normal size, or scaled to a factor of 2:1. A value of 360
  // indicates a scale of 4:1, while a value of 2880 indicates that the image
  // is scaled down in size by a factor of two. A value of 1440 indicates
  // a 1:1 scale ratio.

  // Reserved is not used and is always set to 0.

  // Checksum contains a checksum value for the previous 10 WORDs in the header.
  // This value can be used in an attempt to detect if the metafile has become
  // corrupted. The checksum is calculated by XORing each WORD value to an
  // initial value of 0.

  // If the metafile was recorded with a reference Hdc that was a display.

const
  GDIP_EMFPLUSFLAGS_DISPLAY      = $00000001;

type
  TMetafileHeader = class
  public
    Type_        : TMetafileType;
    Size         : UINT;           // Size of the metafile (in bytes)
    Version      : UINT;           // EMF+, EMF, or WMF version
    EmfPlusFlags : UINT;
    DpiX         : Single;
    DpiY         : Single;
    X            : Integer;        // Bounds in device units
    Y            : Integer;
    Width        : Integer;
    Height       : Integer;
    Header       : record
    case integer of
      0: (WmfHeader: TMETAHEADER;);
      1: (EmfHeader: TENHMETAHEADER3);
    end;
    EmfPlusHeaderSize : Integer; // size of the EMF+ header in file
    LogicalDpiX       : Integer; // Logical Dpi of reference Hdc
    LogicalDpiY       : Integer; // usually valid only for EMF+
  public
    property GetType: TMetafileType read Type_;
    property GetMetafileSize: UINT read Size;
    // If IsEmfPlus, this is the EMF+ version; else it is the WMF or EMF ver
    property GetVersion: UINT read Version;
     // Get the EMF+ flags associated with the metafile
    property GetEmfPlusFlags: UINT read EmfPlusFlags;
    property GetDpiX: Single read DpiX;
    property GetDpiY: Single read DpiY;
    procedure GetBounds(out Rect: TGPRect);
    // Is it any type of WMF (standard or Placeable Metafile)?
    function IsWmf: BOOL;
    // Is this an Placeable Metafile?
    function IsWmfPlaceable: BOOL;
    // Is this an EMF (not an EMF+)?
    function IsEmf: BOOL;
    // Is this an EMF or EMF+ file?
    function IsEmfOrEmfPlus: BOOL;
    // Is this an EMF+ file?
    function IsEmfPlus: BOOL;
    // Is this an EMF+ dual (has dual, down-level records) file?
    function IsEmfPlusDual: BOOL;
    // Is this an EMF+ only (no dual records) file?
    function IsEmfPlusOnly: BOOL;
    // If it's an EMF+ file, was it recorded against a display Hdc?
    function IsDisplay: BOOL;
    // Get the WMF header of the metafile (if it is a WMF)
    function GetWmfHeader: PMetaHeader;
    // Get the EMF header of the metafile (if it is an EMF)
    function GetEmfHeader: PENHMETAHEADER3;
  end;

(**************************************************************************\
*
*   GDI+ Imaging GUIDs
*
\**************************************************************************)

//---------------------------------------------------------------------------
// Image file format identifiers
//---------------------------------------------------------------------------

const
  ImageFormatUndefined : TGUID = '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatMemoryBMP : TGUID = '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatBMP       : TGUID = '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatEMF       : TGUID = '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatWMF       : TGUID = '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatJPEG      : TGUID = '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatPNG       : TGUID = '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatGIF       : TGUID = '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatTIFF      : TGUID = '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatEXIF      : TGUID = '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatIcon      : TGUID = '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}';

//---------------------------------------------------------------------------
// Predefined multi-frame dimension IDs
//---------------------------------------------------------------------------

  FrameDimensionTime       : TGUID = '{6aedbd6d-3fb5-418a-83a6-7f45229dc872}';
  FrameDimensionResolution : TGUID = '{84236f7b-3bd3-428f-8dab-4ea1439ca315}';
  FrameDimensionPage       : TGUID = '{7462dc86-6180-4c7e-8e3f-ee7333a7a483}';

//---------------------------------------------------------------------------
// Property sets
//---------------------------------------------------------------------------

  FormatIDImageInformation : TGUID = '{e5836cbe-5eef-4f1d-acde-ae4c43b608ce}';
  FormatIDJpegAppHeaders   : TGUID = '{1c4afdcd-6177-43cf-abc7-5f51af39ee85}';

//---------------------------------------------------------------------------
// Encoder parameter sets
//---------------------------------------------------------------------------

  EncoderCompression      : TGUID = '{e09d739d-ccd4-44ee-8eba-3fbf8be4fc58}';
  EncoderColorDepth       : TGUID = '{66087055-ad66-4c7c-9a18-38a2310b8337}';
  EncoderScanMethod       : TGUID = '{3a4e2661-3109-4e56-8536-42c156e7dcfa}';
  EncoderVersion          : TGUID = '{24d18c76-814a-41a4-bf53-1c219cccf797}';
  EncoderRenderMethod     : TGUID = '{6d42c53a-229a-4825-8bb7-5c99e2b9a8b8}';
  EncoderQuality          : TGUID = '{1d5be4b5-fa4a-452d-9cdd-5db35105e7eb}';
  EncoderTransformation   : TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}';
  EncoderLuminanceTable   : TGUID = '{edb33bce-0266-4a77-b904-27216099e717}';
  EncoderChrominanceTable : TGUID = '{f2e455dc-09b3-4316-8260-676ada32481c}';
  EncoderSaveFlag         : TGUID = '{292266fc-ac40-47bf-8cfc-a85b89a655de}';

  CodecIImageBytes : TGUID = '{025d1823-6c7d-447b-bbdb-a3cbc3dfa2fc}';

type
  IImageBytes = Interface(IUnknown)
    ['{025D1823-6C7D-447B-BBDB-A3CBC3DFA2FC}']
    // Return total number of bytes in the IStream
    function CountBytes(out pcb: UINT): HRESULT; stdcall;
    // Locks "cb" bytes, starting from "ulOffset" in the stream, and returns the
    // pointer to the beginning of the locked memory chunk in "ppvBytes"
    function LockBytes(cb: UINT; ulOffset: ULONG; out ppvBytes: pointer): HRESULT; stdcall;
    // Unlocks "cb" bytes, pointed by "pvBytes", starting from "ulOffset" in the
    // stream
    function UnlockBytes(pvBytes: pointer; cb: UINT; ulOffset: ULONG): HRESULT; stdcall;
  end;

//--------------------------------------------------------------------------
// ImageCodecInfo structure
//--------------------------------------------------------------------------

  ImageCodecInfo = record
    Clsid             : TGUID;
    FormatID          : TGUID;
    CodecName         : PWCHAR;
    DllName           : PWCHAR;
    FormatDescription : PWCHAR;
    FilenameExtension : PWCHAR;
    MimeType          : PWCHAR;
    Flags             : DWORD;
    Version           : DWORD;
    SigCount          : DWORD;
    SigSize           : DWORD;
    SigPattern        : PBYTE;
    SigMask           : PBYTE;
  end;
  TImageCodecInfo = ImageCodecInfo;
  PImageCodecInfo = ^TImageCodecInfo;

//--------------------------------------------------------------------------
// Information flags about image codecs
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  ImageCodecFlags = (
    ImageCodecFlagsEncoder            = $00000001,
    ImageCodecFlagsDecoder            = $00000002,
    ImageCodecFlagsSupportBitmap      = $00000004,
    ImageCodecFlagsSupportVector      = $00000008,
    ImageCodecFlagsSeekableEncode     = $00000010,
    ImageCodecFlagsBlockingDecode     = $00000020,

    ImageCodecFlagsBuiltin            = $00010000,
    ImageCodecFlagsSystem             = $00020000,
    ImageCodecFlagsUser               = $00040000
  );
  TImageCodecFlags = ImageCodecFlags;
{$ELSE}
  ImageCodecFlags = Integer;
  const
    ImageCodecFlagsEncoder            = $00000001;
    ImageCodecFlagsDecoder            = $00000002;
    ImageCodecFlagsSupportBitmap      = $00000004;
    ImageCodecFlagsSupportVector      = $00000008;
    ImageCodecFlagsSeekableEncode     = $00000010;
    ImageCodecFlagsBlockingDecode     = $00000020;

    ImageCodecFlagsBuiltin            = $00010000;
    ImageCodecFlagsSystem             = $00020000;
    ImageCodecFlagsUser               = $00040000;

type
  TImageCodecFlags = ImageCodecFlags;
{$ENDIF}
//---------------------------------------------------------------------------
// Access modes used when calling Image::LockBits
//---------------------------------------------------------------------------

  ImageLockMode = Integer;
  const
    ImageLockModeRead         = $0001;
    ImageLockModeWrite        = $0002;
    ImageLockModeUserInputBuf = $0004;
type
  TImageLockMode = ImageLockMode;

//---------------------------------------------------------------------------
// Information about image pixel data
//---------------------------------------------------------------------------

{$ALIGN 1}
  BitmapData = record
    Width       : UINT;
    Height      : UINT;
    Stride      : Integer;
    PixelFormat : PixelFormat;
    Scan0       : Pointer;
    Reserved    : UINT_PTR;
  end;
  TBitmapData = BitmapData;
  PBitmapData = ^TBitmapData;
{$ALIGN ON}

//---------------------------------------------------------------------------
// Image flags
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  ImageFlags = (
    ImageFlagsNone                = 0,

    // Low-word: shared with SINKFLAG_x

    ImageFlagsScalable            = $0001,
    ImageFlagsHasAlpha            = $0002,
    ImageFlagsHasTranslucent      = $0004,
    ImageFlagsPartiallyScalable   = $0008,

    // Low-word: color space definition

    ImageFlagsColorSpaceRGB       = $0010,
    ImageFlagsColorSpaceCMYK      = $0020,
    ImageFlagsColorSpaceGRAY      = $0040,
    ImageFlagsColorSpaceYCBCR     = $0080,
    ImageFlagsColorSpaceYCCK      = $0100,

    // Low-word: image size info

    ImageFlagsHasRealDPI          = $1000,
    ImageFlagsHasRealPixelSize    = $2000,

    // High-word

    ImageFlagsReadOnly            = $00010000,
    ImageFlagsCaching             = $00020000
  );
  TImageFlags = ImageFlags;
{$ELSE}
  ImageFlags = Integer;
  const
    ImageFlagsNone                = 0;

    // Low-word: shared with SINKFLAG_x

    ImageFlagsScalable            = $0001;
    ImageFlagsHasAlpha            = $0002;
    ImageFlagsHasTranslucent      = $0004;
    ImageFlagsPartiallyScalable   = $0008;

    // Low-word: color space definition

    ImageFlagsColorSpaceRGB       = $0010;
    ImageFlagsColorSpaceCMYK      = $0020;
    ImageFlagsColorSpaceGRAY      = $0040;
    ImageFlagsColorSpaceYCBCR     = $0080;
    ImageFlagsColorSpaceYCCK      = $0100;

    // Low-word: image size info

    ImageFlagsHasRealDPI          = $1000;
    ImageFlagsHasRealPixelSize    = $2000;

    // High-word

    ImageFlagsReadOnly            = $00010000;
    ImageFlagsCaching             = $00020000;

type
  TImageFlags = ImageFlags;
{$ENDIF}


{$IFDEF DELPHI6_UP}
  RotateFlipType = (
    RotateNoneFlipNone = 0,
    Rotate90FlipNone   = 1,
    Rotate180FlipNone  = 2,
    Rotate270FlipNone  = 3,

    RotateNoneFlipX    = 4,
    Rotate90FlipX      = 5,
    Rotate180FlipX     = 6,
    Rotate270FlipX     = 7,

    RotateNoneFlipY    = Rotate180FlipX,
    Rotate90FlipY      = Rotate270FlipX,
    Rotate180FlipY     = RotateNoneFlipX,
    Rotate270FlipY     = Rotate90FlipX,

    RotateNoneFlipXY   = Rotate180FlipNone,
    Rotate90FlipXY     = Rotate270FlipNone,
    Rotate180FlipXY    = RotateNoneFlipNone,
    Rotate270FlipXY    = Rotate90FlipNone
  );
  TRotateFlipType = RotateFlipType;
{$ELSE}
  RotateFlipType = (
    RotateNoneFlipNone, // = 0,
    Rotate90FlipNone,   // = 1,
    Rotate180FlipNone,  // = 2,
    Rotate270FlipNone,  // = 3,

    RotateNoneFlipX,    // = 4,
    Rotate90FlipX,      // = 5,
    Rotate180FlipX,     // = 6,
    Rotate270FlipX      // = 7,
  );
  const
    RotateNoneFlipY    = Rotate180FlipX;
    Rotate90FlipY      = Rotate270FlipX;
    Rotate180FlipY     = RotateNoneFlipX;
    Rotate270FlipY     = Rotate90FlipX;

    RotateNoneFlipXY   = Rotate180FlipNone;
    Rotate90FlipXY     = Rotate270FlipNone;
    Rotate180FlipXY    = RotateNoneFlipNone;
    Rotate270FlipXY    = Rotate90FlipNone;

type
  TRotateFlipType = RotateFlipType;
{$ENDIF}

//---------------------------------------------------------------------------
// Encoder Parameter structure
//---------------------------------------------------------------------------

  EncoderParameter = record
    Guid           : TGUID;   // GUID of the parameter
    NumberOfValues : ULONG;   // Number of the parameter values
    Type_          : ULONG;   // Value type, like ValueTypeLONG  etc.
    Value          : Pointer; // A pointer to the parameter values
  end;
  TEncoderParameter = EncoderParameter;
  PEncoderParameter = ^TEncoderParameter;

//---------------------------------------------------------------------------
// Encoder Parameters structure
//---------------------------------------------------------------------------

{$ALIGN 8}
  EncoderParameters = record
    Count     : UINT;               // Number of parameters in this structure
    Parameter : array[0..0] of TEncoderParameter;  // Parameter values
  end;
  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;
{$ALIGN ON}

//---------------------------------------------------------------------------
// Property Item
//---------------------------------------------------------------------------

  PropertyItem = record // NOT PACKED !!
    id       : PROPID;  // ID of this property
    length   : ULONG;   // Length of the property value, in bytes
    type_    : WORD;    // Type of the value, as one of TAG_TYPE_XXX
    value    : Pointer; // property value
  end;
  TPropertyItem = PropertyItem;
  PPropertyItem = ^TPropertyItem;

//---------------------------------------------------------------------------
// Image property types
//---------------------------------------------------------------------------

const
  PropertyTagTypeByte      : Integer =  1;
  PropertyTagTypeASCII     : Integer =  2;
  PropertyTagTypeShort     : Integer =  3;
  PropertyTagTypeLong      : Integer =  4;
  PropertyTagTypeRational  : Integer =  5;
  PropertyTagTypeUndefined : Integer =  7;
  PropertyTagTypeSLONG     : Integer =  9;
  PropertyTagTypeSRational : Integer = 10;

//---------------------------------------------------------------------------
// Image property ID tags
//---------------------------------------------------------------------------

  PropertyTagExifIFD            = $8769;
  PropertyTagGpsIFD             = $8825;

  PropertyTagNewSubfileType     = $00FE;
  PropertyTagSubfileType        = $00FF;
  PropertyTagImageWidth         = $0100;
  PropertyTagImageHeight        = $0101;
  PropertyTagBitsPerSample      = $0102;
  PropertyTagCompression        = $0103;
  PropertyTagPhotometricInterp  = $0106;
  PropertyTagThreshHolding      = $0107;
  PropertyTagCellWidth          = $0108;
  PropertyTagCellHeight         = $0109;
  PropertyTagFillOrder          = $010A;
  PropertyTagDocumentName       = $010D;
  PropertyTagImageDescription   = $010E;
  PropertyTagEquipMake          = $010F;
  PropertyTagEquipModel         = $0110;
  PropertyTagStripOffsets       = $0111;
  PropertyTagOrientation        = $0112;
  PropertyTagSamplesPerPixel    = $0115;
  PropertyTagRowsPerStrip       = $0116;
  PropertyTagStripBytesCount    = $0117;
  PropertyTagMinSampleValue     = $0118;
  PropertyTagMaxSampleValue     = $0119;
  PropertyTagXResolution        = $011A;   // Image resolution in width direction
  PropertyTagYResolution        = $011B;   // Image resolution in height direction
  PropertyTagPlanarConfig       = $011C;   // Image data arrangement
  PropertyTagPageName           = $011D;
  PropertyTagXPosition          = $011E;
  PropertyTagYPosition          = $011F;
  PropertyTagFreeOffset         = $0120;
  PropertyTagFreeByteCounts     = $0121;
  PropertyTagGrayResponseUnit   = $0122;
  PropertyTagGrayResponseCurve  = $0123;
  PropertyTagT4Option           = $0124;
  PropertyTagT6Option           = $0125;
  PropertyTagResolutionUnit     = $0128;   // Unit of X and Y resolution
  PropertyTagPageNumber         = $0129;
  PropertyTagTransferFuncition  = $012D;
  PropertyTagSoftwareUsed       = $0131;
  PropertyTagDateTime           = $0132;
  PropertyTagArtist             = $013B;
  PropertyTagHostComputer       = $013C;
  PropertyTagPredictor          = $013D;
  PropertyTagWhitePoint         = $013E;
  PropertyTagPrimaryChromaticities = $013F;
  PropertyTagColorMap           = $0140;
  PropertyTagHalftoneHints      = $0141;
  PropertyTagTileWidth          = $0142;
  PropertyTagTileLength         = $0143;
  PropertyTagTileOffset         = $0144;
  PropertyTagTileByteCounts     = $0145;
  PropertyTagInkSet             = $014C;
  PropertyTagInkNames           = $014D;
  PropertyTagNumberOfInks       = $014E;
  PropertyTagDotRange           = $0150;
  PropertyTagTargetPrinter      = $0151;
  PropertyTagExtraSamples       = $0152;
  PropertyTagSampleFormat       = $0153;
  PropertyTagSMinSampleValue    = $0154;
  PropertyTagSMaxSampleValue    = $0155;
  PropertyTagTransferRange      = $0156;

  PropertyTagJPEGProc               = $0200;
  PropertyTagJPEGInterFormat        = $0201;
  PropertyTagJPEGInterLength        = $0202;
  PropertyTagJPEGRestartInterval    = $0203;
  PropertyTagJPEGLosslessPredictors = $0205;
  PropertyTagJPEGPointTransforms    = $0206;
  PropertyTagJPEGQTables            = $0207;
  PropertyTagJPEGDCTables           = $0208;
  PropertyTagJPEGACTables           = $0209;

  PropertyTagYCbCrCoefficients  = $0211;
  PropertyTagYCbCrSubsampling   = $0212;
  PropertyTagYCbCrPositioning   = $0213;
  PropertyTagREFBlackWhite      = $0214;

  PropertyTagICCProfile         = $8773;   // This TAG is defined by ICC
                                           // for embedded ICC in TIFF
  PropertyTagGamma                = $0301;
  PropertyTagICCProfileDescriptor = $0302;
  PropertyTagSRGBRenderingIntent  = $0303;

  PropertyTagImageTitle         = $0320;
  PropertyTagCopyright          = $8298;

// Extra TAGs (Like Adobe Image Information tags etc.)

  PropertyTagResolutionXUnit           = $5001;
  PropertyTagResolutionYUnit           = $5002;
  PropertyTagResolutionXLengthUnit     = $5003;
  PropertyTagResolutionYLengthUnit     = $5004;
  PropertyTagPrintFlags                = $5005;
  PropertyTagPrintFlagsVersion         = $5006;
  PropertyTagPrintFlagsCrop            = $5007;
  PropertyTagPrintFlagsBleedWidth      = $5008;
  PropertyTagPrintFlagsBleedWidthScale = $5009;
  PropertyTagHalftoneLPI               = $500A;
  PropertyTagHalftoneLPIUnit           = $500B;
  PropertyTagHalftoneDegree            = $500C;
  PropertyTagHalftoneShape             = $500D;
  PropertyTagHalftoneMisc              = $500E;
  PropertyTagHalftoneScreen            = $500F;
  PropertyTagJPEGQuality               = $5010;
  PropertyTagGridSize                  = $5011;
  PropertyTagThumbnailFormat           = $5012;  // 1 = JPEG, 0 = RAW RGB
  PropertyTagThumbnailWidth            = $5013;
  PropertyTagThumbnailHeight           = $5014;
  PropertyTagThumbnailColorDepth       = $5015;
  PropertyTagThumbnailPlanes           = $5016;
  PropertyTagThumbnailRawBytes         = $5017;
  PropertyTagThumbnailSize             = $5018;
  PropertyTagThumbnailCompressedSize   = $5019;
  PropertyTagColorTransferFunction     = $501A;
  PropertyTagThumbnailData             = $501B;    // RAW thumbnail bits in
                                                   // JPEG format or RGB format
                                                   // depends on
                                                   // PropertyTagThumbnailFormat

  // Thumbnail related TAGs

  PropertyTagThumbnailImageWidth        = $5020;   // Thumbnail width
  PropertyTagThumbnailImageHeight       = $5021;   // Thumbnail height
  PropertyTagThumbnailBitsPerSample     = $5022;   // Number of bits per
                                                   // component
  PropertyTagThumbnailCompression       = $5023;   // Compression Scheme
  PropertyTagThumbnailPhotometricInterp = $5024;   // Pixel composition
  PropertyTagThumbnailImageDescription  = $5025;   // Image Tile
  PropertyTagThumbnailEquipMake         = $5026;   // Manufacturer of Image
                                                   // Input equipment
  PropertyTagThumbnailEquipModel        = $5027;   // Model of Image input
                                                   // equipment
  PropertyTagThumbnailStripOffsets    = $5028;  // Image data location
  PropertyTagThumbnailOrientation     = $5029;  // Orientation of image
  PropertyTagThumbnailSamplesPerPixel = $502A;  // Number of components
  PropertyTagThumbnailRowsPerStrip    = $502B;  // Number of rows per strip
  PropertyTagThumbnailStripBytesCount = $502C;  // Bytes per compressed
                                                // strip
  PropertyTagThumbnailResolutionX     = $502D;  // Resolution in width
                                                // direction
  PropertyTagThumbnailResolutionY     = $502E;  // Resolution in height
                                                // direction
  PropertyTagThumbnailPlanarConfig    = $502F;  // Image data arrangement
  PropertyTagThumbnailResolutionUnit  = $5030;  // Unit of X and Y
                                                // Resolution
  PropertyTagThumbnailTransferFunction = $5031;  // Transfer function
  PropertyTagThumbnailSoftwareUsed     = $5032;  // Software used
  PropertyTagThumbnailDateTime         = $5033;  // File change date and
                                                 // time
  PropertyTagThumbnailArtist          = $5034;  // Person who created the
                                                // image
  PropertyTagThumbnailWhitePoint      = $5035;  // White point chromaticity
  PropertyTagThumbnailPrimaryChromaticities = $5036;
                                                    // Chromaticities of
                                                    // primaries
  PropertyTagThumbnailYCbCrCoefficients = $5037; // Color space transforma-
                                                 // tion coefficients
  PropertyTagThumbnailYCbCrSubsampling = $5038;  // Subsampling ratio of Y
                                                 // to C
  PropertyTagThumbnailYCbCrPositioning = $5039;  // Y and C position
  PropertyTagThumbnailRefBlackWhite    = $503A;  // Pair of black and white
                                                 // reference values
  PropertyTagThumbnailCopyRight       = $503B;   // CopyRight holder

  PropertyTagLuminanceTable           = $5090;
  PropertyTagChrominanceTable         = $5091;

  PropertyTagFrameDelay               = $5100;
  PropertyTagLoopCount                = $5101;

  PropertyTagPixelUnit         = $5110;  // Unit specifier for pixel/unit
  PropertyTagPixelPerUnitX     = $5111;  // Pixels per unit in X
  PropertyTagPixelPerUnitY     = $5112;  // Pixels per unit in Y
  PropertyTagPaletteHistogram  = $5113;  // Palette histogram

  // EXIF specific tag

  PropertyTagExifExposureTime  = $829A;
  PropertyTagExifFNumber       = $829D;

  PropertyTagExifExposureProg  = $8822;
  PropertyTagExifSpectralSense = $8824;
  PropertyTagExifISOSpeed      = $8827;
  PropertyTagExifOECF          = $8828;

  PropertyTagExifVer           = $9000;
  PropertyTagExifDTOrig        = $9003; // Date & time of original
  PropertyTagExifDTDigitized   = $9004; // Date & time of digital data generation

  PropertyTagExifCompConfig    = $9101;
  PropertyTagExifCompBPP       = $9102;

  PropertyTagExifShutterSpeed  = $9201;
  PropertyTagExifAperture      = $9202;
  PropertyTagExifBrightness    = $9203;
  PropertyTagExifExposureBias  = $9204;
  PropertyTagExifMaxAperture   = $9205;
  PropertyTagExifSubjectDist   = $9206;
  PropertyTagExifMeteringMode  = $9207;
  PropertyTagExifLightSource   = $9208;
  PropertyTagExifFlash         = $9209;
  PropertyTagExifFocalLength   = $920A;
  PropertyTagExifMakerNote     = $927C;
  PropertyTagExifUserComment   = $9286;
  PropertyTagExifDTSubsec      = $9290;  // Date & Time subseconds
  PropertyTagExifDTOrigSS      = $9291;  // Date & Time original subseconds
  PropertyTagExifDTDigSS       = $9292;  // Date & TIme digitized subseconds

  PropertyTagExifFPXVer        = $A000;
  PropertyTagExifColorSpace    = $A001;
  PropertyTagExifPixXDim       = $A002;
  PropertyTagExifPixYDim       = $A003;
  PropertyTagExifRelatedWav    = $A004;  // related sound file
  PropertyTagExifInterop       = $A005;
  PropertyTagExifFlashEnergy   = $A20B;
  PropertyTagExifSpatialFR     = $A20C;  // Spatial Frequency Response
  PropertyTagExifFocalXRes     = $A20E;  // Focal Plane X Resolution
  PropertyTagExifFocalYRes     = $A20F;  // Focal Plane Y Resolution
  PropertyTagExifFocalResUnit  = $A210;  // Focal Plane Resolution Unit
  PropertyTagExifSubjectLoc    = $A214;
  PropertyTagExifExposureIndex = $A215;
  PropertyTagExifSensingMethod = $A217;
  PropertyTagExifFileSource    = $A300;
  PropertyTagExifSceneType     = $A301;
  PropertyTagExifCfaPattern    = $A302;

  PropertyTagGpsVer            = $0000;
  PropertyTagGpsLatitudeRef    = $0001;
  PropertyTagGpsLatitude       = $0002;
  PropertyTagGpsLongitudeRef   = $0003;
  PropertyTagGpsLongitude      = $0004;
  PropertyTagGpsAltitudeRef    = $0005;
  PropertyTagGpsAltitude       = $0006;
  PropertyTagGpsGpsTime        = $0007;
  PropertyTagGpsGpsSatellites  = $0008;
  PropertyTagGpsGpsStatus      = $0009;
  PropertyTagGpsGpsMeasureMode = $00A;
  PropertyTagGpsGpsDop         = $000B;  // Measurement precision
  PropertyTagGpsSpeedRef       = $000C;
  PropertyTagGpsSpeed          = $000D;
  PropertyTagGpsTrackRef       = $000E;
  PropertyTagGpsTrack          = $000F;
  PropertyTagGpsImgDirRef      = $0010;
  PropertyTagGpsImgDir         = $0011;
  PropertyTagGpsMapDatum       = $0012;
  PropertyTagGpsDestLatRef     = $0013;
  PropertyTagGpsDestLat        = $0014;
  PropertyTagGpsDestLongRef    = $0015;
  PropertyTagGpsDestLong       = $0016;
  PropertyTagGpsDestBearRef    = $0017;
  PropertyTagGpsDestBear       = $0018;
  PropertyTagGpsDestDistRef    = $0019;
  PropertyTagGpsDestDist       = $001A;

(**************************************************************************\
*
*  GDI+ Color Matrix object, used with Graphics.DrawImage
*
\**************************************************************************)

//----------------------------------------------------------------------------
// Color matrix
//----------------------------------------------------------------------------

type
  ColorMatrix = packed array[0..4, 0..4] of Single;
  TColorMatrix = ColorMatrix;
  PColorMatrix = ^TColorMatrix;

//----------------------------------------------------------------------------
// Color Matrix flags
//----------------------------------------------------------------------------

  ColorMatrixFlags = (
    ColorMatrixFlagsDefault,
    ColorMatrixFlagsSkipGrays,
    ColorMatrixFlagsAltGray
  );
  TColorMatrixFlags = ColorMatrixFlags;

//----------------------------------------------------------------------------
// Color Adjust Type
//----------------------------------------------------------------------------

  ColorAdjustType = (
    ColorAdjustTypeDefault,
    ColorAdjustTypeBitmap,
    ColorAdjustTypeBrush,
    ColorAdjustTypePen,
    ColorAdjustTypeText,
    ColorAdjustTypeCount,
    ColorAdjustTypeAny      // Reserved
  );
  TColorAdjustType = ColorAdjustType;

//----------------------------------------------------------------------------
// Color Map
//----------------------------------------------------------------------------

  ColorMap = record
    oldColor: TGPColor;
    newColor: TGPColor;
  end;
  TColorMap = ColorMap;
  PColorMap = ^TColorMap;

//---------------------------------------------------------------------------
// Private GDI+ classes for internal type checking
//---------------------------------------------------------------------------

  GpGraphics = Pointer;

  GpBrush = Pointer;
  GpTexture = Pointer;
  GpSolidFill = Pointer;
  GpLineGradient = Pointer;
  GpPathGradient = Pointer;
  GpHatch =  Pointer;

  GpPen = Pointer;
  GpCustomLineCap = Pointer;
  GpAdjustableArrowCap = Pointer;

  GpImage = Pointer;
  GpBitmap = Pointer;
  GpMetafile = Pointer;
  GpImageAttributes = Pointer;

  GpPath = Pointer;
  GpRegion = Pointer;
  GpPathIterator = Pointer;

  GpFontFamily = Pointer;
  GpFont = Pointer;
  GpStringFormat = Pointer;
  GpFontCollection = Pointer;
  GpCachedBitmap = Pointer;

  GpStatus          = TStatus;
  GpFillMode        = TFillMode;
  GpWrapMode        = TWrapMode;
  GpUnit            = TUnit;
  GpCoordinateSpace = TCoordinateSpace;
  GpPointF          = PGPPointF;
  GpPoint           = PGPPoint;
  GpRectF           = PGPRectF;
  GpRect            = PGPRect;
  GpSizeF           = PGPSizeF;
  GpHatchStyle      = THatchStyle;
  GpDashStyle       = TDashStyle;
  GpLineCap         = TLineCap;
  GpDashCap         = TDashCap;

  GpPenAlignment    = TPenAlignment;

  GpLineJoin        = TLineJoin;
  GpPenType         = TPenType;

  GpMatrix          = Pointer; 
  GpBrushType       = TBrushType;
  GpMatrixOrder     = TMatrixOrder;
  GpFlushIntention  = TFlushIntention;
  GpPathData        = TPathData;

(**************************************************************************\
*
* Copyright (c) 1998-2001, Microsoft Corp.  All Rights Reserved.
* Module Name:
*   GdiplusFlat.h
* Abstract:
*   Private GDI+ header file.
*
\**************************************************************************)

  function GdipCreatePath(brushMode: GPFILLMODE;
    out path: GPPATH): GPSTATUS; stdcall;

  function GdipCreatePath2(v1: GPPOINTF; v2: PBYTE; v3: Integer; v4: GPFILLMODE;
    out path: GPPATH): GPSTATUS; stdcall;

  function GdipCreatePath2I(v1: GPPOINT; v2: PBYTE; v3: Integer; v4: GPFILLMODE;
    out path: GPPATH): GPSTATUS; stdcall;

  function GdipClonePath(path: GPPATH;
    out clonePath: GPPATH): GPSTATUS; stdcall;

  function GdipDeletePath(path: GPPATH): GPSTATUS; stdcall;

  function GdipResetPath(path: GPPATH): GPSTATUS; stdcall;

  function GdipGetPointCount(path: GPPATH;
    out count: Integer): GPSTATUS; stdcall;

  function GdipGetPathTypes(path: GPPATH; types: PBYTE;
    count: Integer): GPSTATUS; stdcall;

  function GdipGetPathPoints(v1: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipGetPathPointsI(v1: GPPATH; points: GPPOINT;
             count: Integer): GPSTATUS; stdcall;

  function GdipGetPathFillMode(path: GPPATH;
    var fillmode: GPFILLMODE): GPSTATUS; stdcall;

  function GdipSetPathFillMode(path: GPPATH;
    fillmode: GPFILLMODE): GPSTATUS; stdcall;

  function GdipGetPathData(path: GPPATH;
    pathData: Pointer): GPSTATUS; stdcall;

  function GdipStartPathFigure(path: GPPATH): GPSTATUS; stdcall;

  function GdipClosePathFigure(path: GPPATH): GPSTATUS; stdcall;

  function GdipClosePathFigures(path: GPPATH): GPSTATUS; stdcall;

  function GdipSetPathMarker(path: GPPATH): GPSTATUS; stdcall;

  function GdipClearPathMarkers(path: GPPATH): GPSTATUS; stdcall;

  function GdipReversePath(path: GPPATH): GPSTATUS; stdcall;

  function GdipGetPathLastPoint(path: GPPATH;
    lastPoint: GPPOINTF): GPSTATUS; stdcall;

  function GdipAddPathLine(path: GPPATH;
    x1, y1, x2, y2: Single): GPSTATUS; stdcall;

  function GdipAddPathLine2(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathArc(path: GPPATH; x, y, width, height, startAngle,
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipAddPathBezier(path: GPPATH;
    x1, y1, x2, y2, x3, y3, x4, y4: Single): GPSTATUS; stdcall;

  function GdipAddPathBeziers(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathCurve(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathCurve2(path: GPPATH; points: GPPOINTF; count: Integer;
    tension: Single): GPSTATUS; stdcall;

  function GdipAddPathCurve3(path: GPPATH; points: GPPOINTF; count: Integer;
    offset: Integer; numberOfSegments: Integer;
    tension: Single): GPSTATUS; stdcall;

  function GdipAddPathClosedCurve(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathClosedCurve2(path: GPPATH; points: GPPOINTF;
    count: Integer; tension: Single): GPSTATUS; stdcall;

  function GdipAddPathRectangle(path: GPPATH; x: Single; y: Single;
    width: Single; height: Single): GPSTATUS; stdcall;

  function GdipAddPathRectangles(path: GPPATH; rects: GPRECTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathEllipse(path: GPPATH;  x: Single; y: Single;
    width: Single; height: Single): GPSTATUS; stdcall;

  function GdipAddPathPie(path: GPPATH; x: Single; y: Single; width: Single;
    height: Single; startAngle: Single; sweepAngle: Single): GPSTATUS; stdcall;

  function GdipAddPathPolygon(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathPath(path: GPPATH; addingPath: GPPATH;
    connect: Bool): GPSTATUS; stdcall;

  function GdipAddPathString(path: GPPATH; string_: PWCHAR; length: Integer;
    family: GPFONTFAMILY; style: Integer; emSize: Single; layoutRect: PGPRectF;
    format: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipAddPathStringI(path: GPPATH; string_: PWCHAR; length: Integer;
    family: GPFONTFAMILY; style: Integer; emSize: Single; layoutRect: PGPRect;
    format: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipAddPathLineI(path: GPPATH; x1: Integer; y1: Integer; x2: Integer;
    y2: Integer): GPSTATUS; stdcall;

  function GdipAddPathLine2I(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathArcI(path: GPPATH; x: Integer; y: Integer; width: Integer;
    height: Integer; startAngle: Single; sweepAngle: Single): GPSTATUS; stdcall;

  function GdipAddPathBezierI(path: GPPATH; x1: Integer; y1: Integer;
    x2: Integer; y2: Integer; x3: Integer; y3: Integer; x4: Integer;
    y4: Integer): GPSTATUS; stdcall;

  function GdipAddPathBeziersI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathCurveI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathCurve2I(path: GPPATH; points: GPPOINT; count: Integer;
    tension: Single): GPSTATUS; stdcall;

  function GdipAddPathCurve3I(path: GPPATH; points: GPPOINT; count: Integer;
    offset: Integer; numberOfSegments: Integer;
    tension: Single): GPSTATUS; stdcall;

  function GdipAddPathClosedCurveI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathClosedCurve2I(path: GPPATH; points: GPPOINT;
    count: Integer; tension: Single): GPSTATUS; stdcall;

  function GdipAddPathRectangleI(path: GPPATH; x: Integer; y: Integer;
    width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipAddPathRectanglesI(path: GPPATH; rects: GPRECT;
    count: Integer): GPSTATUS; stdcall;

  function GdipAddPathEllipseI(path: GPPATH; x: Integer; y: Integer;
    width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipAddPathPieI(path: GPPATH; x: Integer; y: Integer; width: Integer;
    height: Integer; startAngle: Single; sweepAngle: Single): GPSTATUS; stdcall;

  function GdipAddPathPolygonI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipFlattenPath(path: GPPATH; matrix: GPMATRIX;
    flatness: Single): GPSTATUS; stdcall;

  function GdipWindingModeOutline(path: GPPATH; matrix: GPMATRIX;
    flatness: Single): GPSTATUS; stdcall;

  function GdipWidenPath(nativePath: GPPATH; pen: GPPEN; matrix: GPMATRIX;
    flatness: Single): GPSTATUS; stdcall;

  function GdipWarpPath(path: GPPATH; matrix: GPMATRIX; points: GPPOINTF;
    count: Integer; srcx: Single; srcy: Single; srcwidth: Single;
    srcheight: Single; warpMode: WARPMODE; flatness: Single): GPSTATUS; stdcall;

  function GdipTransformPath(path: GPPATH; matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipGetPathWorldBounds(path: GPPATH; bounds: GPRECTF;
    matrix: GPMATRIX; pen: GPPEN): GPSTATUS; stdcall;

  function GdipGetPathWorldBoundsI(path: GPPATH; bounds: GPRECT;
    matrix: GPMATRIX; pen: GPPEN): GPSTATUS; stdcall;

  function GdipIsVisiblePathPoint(path: GPPATH; x: Single; y: Single;
    graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

  function GdipIsVisiblePathPointI(path: GPPATH; x: Integer; y: Integer;
    graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

  function GdipIsOutlineVisiblePathPoint(path: GPPATH; x: Single; y: Single;
    pen: GPPEN; graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

  function GdipIsOutlineVisiblePathPointI(path: GPPATH; x: Integer; y: Integer;
    pen: GPPEN; graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// PathIterator APIs 
//----------------------------------------------------------------------------

  function GdipCreatePathIter(out iterator: GPPATHITERATOR;
    path: GPPATH): GPSTATUS; stdcall;

  function GdipDeletePathIter(iterator: GPPATHITERATOR): GPSTATUS; stdcall;

  function GdipPathIterNextSubpath(iterator: GPPATHITERATOR;
    var resultCount: Integer; var startIndex: Integer; var endIndex: Integer;
    out isClosed: Bool): GPSTATUS; stdcall;

  function GdipPathIterNextSubpathPath(iterator: GPPATHITERATOR;
    var resultCount: Integer; path: GPPATH;
    out isClosed: Bool): GPSTATUS; stdcall;

  function GdipPathIterNextPathType(iterator: GPPATHITERATOR;
    var resultCount: Integer; pathType: PBYTE; var startIndex: Integer;
    var endIndex: Integer): GPSTATUS; stdcall;

  function GdipPathIterNextMarker(iterator: GPPATHITERATOR;
    var resultCount: Integer; var startIndex: Integer;
    var endIndex: Integer): GPSTATUS; stdcall;

  function GdipPathIterNextMarkerPath(iterator: GPPATHITERATOR;
    var resultCount: Integer; path: GPPATH): GPSTATUS; stdcall;

  function GdipPathIterGetCount(iterator: GPPATHITERATOR;
    out count: Integer): GPSTATUS; stdcall;

  function GdipPathIterGetSubpathCount(iterator: GPPATHITERATOR;
    out count: Integer): GPSTATUS; stdcall;

  function GdipPathIterIsValid(iterator: GPPATHITERATOR;
    out valid: Bool): GPSTATUS; stdcall;

  function GdipPathIterHasCurve(iterator: GPPATHITERATOR;
    out hasCurve: Bool): GPSTATUS; stdcall;

  function GdipPathIterRewind(iterator: GPPATHITERATOR): GPSTATUS; stdcall;

  function GdipPathIterEnumerate(iterator: GPPATHITERATOR;
    var resultCount: Integer; points: GPPOINTF; types: PBYTE;
    count: Integer): GPSTATUS; stdcall;

  function GdipPathIterCopyData(iterator: GPPATHITERATOR;
    var resultCount: Integer; points: GPPOINTF; types: PBYTE;
    startIndex: Integer; endIndex: Integer): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Matrix APIs
//----------------------------------------------------------------------------

  function GdipCreateMatrix(out matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipCreateMatrix2(m11: Single; m12: Single; m21: Single; m22: Single;
    dx: Single; dy: Single; out matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipCreateMatrix3(rect: GPRECTF; dstplg: GPPOINTF;
    out matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipCreateMatrix3I(rect: GPRECT; dstplg: GPPOINT;
    out matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipCloneMatrix(matrix: GPMATRIX;
    out cloneMatrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipDeleteMatrix(matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipSetMatrixElements(matrix: GPMATRIX; m11: Single; m12: Single;
    m21: Single; m22: Single; dx: Single; dy: Single): GPSTATUS; stdcall;

  function GdipMultiplyMatrix(matrix: GPMATRIX; matrix2: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipTranslateMatrix(matrix: GPMATRIX; offsetX: Single;
    offsetY: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipScaleMatrix(matrix: GPMATRIX; scaleX: Single; scaleY: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipRotateMatrix(matrix: GPMATRIX; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipShearMatrix(matrix: GPMATRIX; shearX: Single; shearY: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipInvertMatrix(matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipTransformMatrixPoints(matrix: GPMATRIX; pts: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipTransformMatrixPointsI(matrix: GPMATRIX; pts: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipVectorTransformMatrixPoints(matrix: GPMATRIX; pts: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipVectorTransformMatrixPointsI(matrix: GPMATRIX; pts: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipGetMatrixElements(matrix: GPMATRIX;
    matrixOut: PSingle): GPSTATUS; stdcall;

  function GdipIsMatrixInvertible(matrix: GPMATRIX;
    out result: Bool): GPSTATUS; stdcall;

  function GdipIsMatrixIdentity(matrix: GPMATRIX;
    out result: Bool): GPSTATUS; stdcall;

  function GdipIsMatrixEqual(matrix: GPMATRIX; matrix2: GPMATRIX;
    out result: Bool): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Region APIs
//----------------------------------------------------------------------------

  function GdipCreateRegion(out region: GPREGION): GPSTATUS; stdcall;

  function GdipCreateRegionRect(rect: GPRECTF;
    out region: GPREGION): GPSTATUS; stdcall;

  function GdipCreateRegionRectI(rect: GPRECT;
    out region: GPREGION): GPSTATUS; stdcall;

  function GdipCreateRegionPath(path: GPPATH;
    out region: GPREGION): GPSTATUS; stdcall;

  function GdipCreateRegionRgnData(regionData: PBYTE; size: Integer;
    out region: GPREGION): GPSTATUS; stdcall;

  function GdipCreateRegionHrgn(hRgn: HRGN;
    out region: GPREGION): GPSTATUS; stdcall;

  function GdipCloneRegion(region: GPREGION;
    out cloneRegion: GPREGION): GPSTATUS; stdcall;

  function GdipDeleteRegion(region: GPREGION): GPSTATUS; stdcall;

  function GdipSetInfinite(region: GPREGION): GPSTATUS; stdcall;

  function GdipSetEmpty(region: GPREGION): GPSTATUS; stdcall;

  function GdipCombineRegionRect(region: GPREGION; rect: GPRECTF;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipCombineRegionRectI(region: GPREGION; rect: GPRECT;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipCombineRegionPath(region: GPREGION; path: GPPATH;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipCombineRegionRegion(region: GPREGION; region2: GPREGION;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipTranslateRegion(region: GPREGION; dx: Single;
    dy: Single): GPSTATUS; stdcall;

  function GdipTranslateRegionI(region: GPREGION; dx: Integer;
    dy: Integer): GPSTATUS; stdcall;

  function GdipTransformRegion(region: GPREGION;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipGetRegionBounds(region: GPREGION; graphics: GPGRAPHICS;
    rect: GPRECTF): GPSTATUS; stdcall;

  function GdipGetRegionBoundsI(region: GPREGION; graphics: GPGRAPHICS;
    rect: GPRECT): GPSTATUS; stdcall;

  function GdipGetRegionHRgn(region: GPREGION; graphics: GPGRAPHICS;
    out hRgn: HRGN): GPSTATUS; stdcall;

  function GdipIsEmptyRegion(region: GPREGION; graphics: GPGRAPHICS;
    out result: Bool): GPSTATUS; stdcall;

  function GdipIsInfiniteRegion(region: GPREGION; graphics: GPGRAPHICS;
    out result: Bool): GPSTATUS; stdcall;

  function GdipIsEqualRegion(region: GPREGION; region2: GPREGION;
    graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

  function GdipGetRegionDataSize(region: GPREGION;
    out bufferSize: UINT): GPSTATUS; stdcall;

  function GdipGetRegionData(region: GPREGION; buffer: PBYTE;
    bufferSize: UINT; sizeFilled: PUINT): GPSTATUS; stdcall;

  function GdipIsVisibleRegionPoint(region: GPREGION; x: Single; y: Single;
    graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

  function GdipIsVisibleRegionPointI(region: GPREGION; x: Integer; y: Integer;
    graphics: GPGRAPHICS; out result: Bool): GPSTATUS; stdcall;

  function GdipIsVisibleRegionRect(region: GPREGION; x: Single; y: Single;
    width: Single; height: Single; graphics: GPGRAPHICS;
    out result: Bool): GPSTATUS; stdcall;

  function GdipIsVisibleRegionRectI(region: GPREGION; x: Integer; y: Integer;
    width: Integer; height: Integer; graphics: GPGRAPHICS;
    out result: Bool): GPSTATUS; stdcall;

  function GdipGetRegionScansCount(region: GPREGION; out count: UINT;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipGetRegionScans(region: GPREGION; rects: GPRECTF;
    out count: Integer; matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipGetRegionScansI(region: GPREGION; rects: GPRECT;
    out count: Integer; matrix: GPMATRIX): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Brush APIs
//----------------------------------------------------------------------------

  function GdipCloneBrush(brush: GPBRUSH;
    out cloneBrush: GPBRUSH): GPSTATUS; stdcall;

  function GdipDeleteBrush(brush: GPBRUSH): GPSTATUS; stdcall;

  function GdipGetBrushType(brush: GPBRUSH;
    out type_: GPBRUSHTYPE): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// HatchBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateHatchBrush(hatchstyle: Integer; forecol: ARGB;
    backcol: ARGB; out brush: GPHATCH): GPSTATUS; stdcall;

  function GdipGetHatchStyle(brush: GPHATCH;
    out hatchstyle: GPHATCHSTYLE): GPSTATUS; stdcall;

  function GdipGetHatchForegroundColor(brush: GPHATCH;
    out forecol: ARGB): GPSTATUS; stdcall;

  function GdipGetHatchBackgroundColor(brush: GPHATCH;
    out backcol: ARGB): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// TextureBrush APIs
//----------------------------------------------------------------------------


  function GdipCreateTexture(image: GPIMAGE; wrapmode: GPWRAPMODE;
    var texture: GPTEXTURE): GPSTATUS; stdcall;

  function GdipCreateTexture2(image: GPIMAGE; wrapmode: GPWRAPMODE;
    x: Single; y: Single; width: Single; height: Single;
    out texture: GPTEXTURE): GPSTATUS; stdcall;

  function GdipCreateTextureIA(image: GPIMAGE;
    imageAttributes: GPIMAGEATTRIBUTES; x: Single; y: Single; width: Single;
    height: Single; out texture: GPTEXTURE): GPSTATUS; stdcall;

  function GdipCreateTexture2I(image: GPIMAGE; wrapmode: GPWRAPMODE; x: Integer;
    y: Integer; width: Integer; height: Integer;
    out texture: GPTEXTURE): GPSTATUS; stdcall;

  function GdipCreateTextureIAI(image: GPIMAGE;
    imageAttributes: GPIMAGEATTRIBUTES; x: Integer; y: Integer; width: Integer;
    height: Integer; out texture: GPTEXTURE): GPSTATUS; stdcall;

  function GdipGetTextureTransform(brush: GPTEXTURE;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipSetTextureTransform(brush: GPTEXTURE;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipResetTextureTransform(brush: GPTEXTURE): GPSTATUS; stdcall;

  function GdipMultiplyTextureTransform(brush: GPTEXTURE; matrix: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipTranslateTextureTransform(brush: GPTEXTURE; dx: Single;
    dy: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipScaleTextureTransform(brush: GPTEXTURE; sx: Single; sy: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipRotateTextureTransform(brush: GPTEXTURE; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipSetTextureWrapMode(brush: GPTEXTURE;
    wrapmode: GPWRAPMODE): GPSTATUS; stdcall;

  function GdipGetTextureWrapMode(brush: GPTEXTURE;
    var wrapmode: GPWRAPMODE): GPSTATUS; stdcall;

  function GdipGetTextureImage(brush: GPTEXTURE;
    out image: GPIMAGE): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// SolidBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateSolidFill(color: ARGB;
    out brush: GPSOLIDFILL): GPSTATUS; stdcall;

  function GdipSetSolidFillColor(brush: GPSOLIDFILL;
    color: ARGB): GPSTATUS; stdcall;

  function GdipGetSolidFillColor(brush: GPSOLIDFILL;
    out color: ARGB): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// LineBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateLineBrush(point1: GPPOINTF; point2: GPPOINTF; color1: ARGB;
    color2: ARGB; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipCreateLineBrushI(point1: GPPOINT; point2: GPPOINT; color1: ARGB;
    color2: ARGB; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipCreateLineBrushFromRect(rect: GPRECTF; color1: ARGB;
    color2: ARGB; mode: LINEARGRADIENTMODE; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipCreateLineBrushFromRectI(rect: GPRECT; color1: ARGB;
    color2: ARGB; mode: LINEARGRADIENTMODE; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipCreateLineBrushFromRectWithAngle(rect: GPRECTF; color1: ARGB;
    color2: ARGB; angle: Single; isAngleScalable: Bool; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipCreateLineBrushFromRectWithAngleI(rect: GPRECT; color1: ARGB;
    color2: ARGB; angle: Single; isAngleScalable: Bool; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipSetLineColors(brush: GPLINEGRADIENT; color1: ARGB;
    color2: ARGB): GPSTATUS; stdcall;

  function GdipGetLineColors(brush: GPLINEGRADIENT;
    colors: PARGB): GPSTATUS; stdcall;

  function GdipGetLineRect(brush: GPLINEGRADIENT;
    rect: GPRECTF): GPSTATUS; stdcall;

  function GdipGetLineRectI(brush: GPLINEGRADIENT;
    rect: GPRECT): GPSTATUS; stdcall;

  function GdipSetLineGammaCorrection(brush: GPLINEGRADIENT;
    useGammaCorrection: Bool): GPSTATUS; stdcall;

  function GdipGetLineGammaCorrection(brush: GPLINEGRADIENT;
    out useGammaCorrection: Bool): GPSTATUS; stdcall;

  function GdipGetLineBlendCount(brush: GPLINEGRADIENT;
    out count: Integer): GPSTATUS; stdcall;

  function GdipGetLineBlend(brush: GPLINEGRADIENT; blend: PSingle;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipSetLineBlend(brush: GPLINEGRADIENT; blend: PSingle;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipGetLinePresetBlendCount(brush: GPLINEGRADIENT;
    out count: Integer): GPSTATUS; stdcall;

  function GdipGetLinePresetBlend(brush: GPLINEGRADIENT; blend: PARGB;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipSetLinePresetBlend(brush: GPLINEGRADIENT; blend: PARGB;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipSetLineSigmaBlend(brush: GPLINEGRADIENT; focus: Single;
    scale: Single): GPSTATUS; stdcall;

  function GdipSetLineLinearBlend(brush: GPLINEGRADIENT; focus: Single;
    scale: Single): GPSTATUS; stdcall;

  function GdipSetLineWrapMode(brush: GPLINEGRADIENT;
    wrapmode: GPWRAPMODE): GPSTATUS; stdcall;

  function GdipGetLineWrapMode(brush: GPLINEGRADIENT;
    out wrapmode: GPWRAPMODE): GPSTATUS; stdcall;

  function GdipGetLineTransform(brush: GPLINEGRADIENT;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipSetLineTransform(brush: GPLINEGRADIENT;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipResetLineTransform(brush: GPLINEGRADIENT): GPSTATUS; stdcall;

  function GdipMultiplyLineTransform(brush: GPLINEGRADIENT; matrix: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipTranslateLineTransform(brush: GPLINEGRADIENT; dx: Single;
    dy: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipScaleLineTransform(brush: GPLINEGRADIENT; sx: Single; sy: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipRotateLineTransform(brush: GPLINEGRADIENT; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// PathGradientBrush APIs
//----------------------------------------------------------------------------

  function GdipCreatePathGradient(points: GPPOINTF; count: Integer;
    wrapMode: GPWRAPMODE; out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;

  function GdipCreatePathGradientI(points: GPPOINT; count: Integer;
    wrapMode: GPWRAPMODE; out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;

  function GdipCreatePathGradientFromPath(path: GPPATH;
    out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;

  function GdipGetPathGradientCenterColor(brush: GPPATHGRADIENT;
    out colors: ARGB): GPSTATUS; stdcall;

  function GdipSetPathGradientCenterColor(brush: GPPATHGRADIENT;
    colors: ARGB): GPSTATUS; stdcall;

  function GdipGetPathGradientSurroundColorsWithCount(brush: GPPATHGRADIENT;
    color: PARGB; var count: Integer): GPSTATUS; stdcall;

  function GdipSetPathGradientSurroundColorsWithCount(brush: GPPATHGRADIENT;
    color: PARGB; var count: Integer): GPSTATUS; stdcall;

  function GdipGetPathGradientPath(brush: GPPATHGRADIENT;
    path: GPPATH): GPSTATUS; stdcall;

  function GdipSetPathGradientPath(brush: GPPATHGRADIENT;
    path: GPPATH): GPSTATUS; stdcall;

  function GdipGetPathGradientCenterPoint(brush: GPPATHGRADIENT;
    points: GPPOINTF): GPSTATUS; stdcall;

  function GdipGetPathGradientCenterPointI(brush: GPPATHGRADIENT;
    points: GPPOINT): GPSTATUS; stdcall;

  function GdipSetPathGradientCenterPoint(brush: GPPATHGRADIENT;
    points: GPPOINTF): GPSTATUS; stdcall;

  function GdipSetPathGradientCenterPointI(brush: GPPATHGRADIENT;
    points: GPPOINT): GPSTATUS; stdcall;

  function GdipGetPathGradientRect(brush: GPPATHGRADIENT;
    rect: GPRECTF): GPSTATUS; stdcall;

  function GdipGetPathGradientRectI(brush: GPPATHGRADIENT;
    rect: GPRECT): GPSTATUS; stdcall;

  function GdipGetPathGradientPointCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;

  function GdipGetPathGradientSurroundColorCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;

  function GdipSetPathGradientGammaCorrection(brush: GPPATHGRADIENT;
    useGammaCorrection: Bool): GPSTATUS; stdcall;

  function GdipGetPathGradientGammaCorrection(brush: GPPATHGRADIENT;
    var useGammaCorrection: Bool): GPSTATUS; stdcall;

  function GdipGetPathGradientBlendCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;

  function GdipGetPathGradientBlend(brush: GPPATHGRADIENT;
    blend: PSingle; positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipSetPathGradientBlend(brush: GPPATHGRADIENT;
    blend: PSingle; positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipGetPathGradientPresetBlendCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;

  function GdipGetPathGradientPresetBlend(brush: GPPATHGRADIENT;
    blend: PARGB; positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipSetPathGradientPresetBlend(brush: GPPATHGRADIENT;
    blend: PARGB; positions: PSingle; count: Integer): GPSTATUS; stdcall;

  function GdipSetPathGradientSigmaBlend(brush: GPPATHGRADIENT;
    focus: Single; scale: Single): GPSTATUS; stdcall;

  function GdipSetPathGradientLinearBlend(brush: GPPATHGRADIENT;
    focus: Single; scale: Single): GPSTATUS; stdcall;

  function GdipGetPathGradientWrapMode(brush: GPPATHGRADIENT;
    var wrapmode: GPWRAPMODE): GPSTATUS; stdcall;

  function GdipSetPathGradientWrapMode(brush: GPPATHGRADIENT;
    wrapmode: GPWRAPMODE): GPSTATUS; stdcall;

  function GdipGetPathGradientTransform(brush: GPPATHGRADIENT;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipSetPathGradientTransform(brush: GPPATHGRADIENT;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipResetPathGradientTransform(
    brush: GPPATHGRADIENT): GPSTATUS; stdcall;

  function GdipMultiplyPathGradientTransform(brush: GPPATHGRADIENT;
    matrix: GPMATRIX; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipTranslatePathGradientTransform(brush: GPPATHGRADIENT;
    dx: Single; dy: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipScalePathGradientTransform(brush: GPPATHGRADIENT;
    sx: Single; sy: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipRotatePathGradientTransform(brush: GPPATHGRADIENT;
    angle: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipGetPathGradientFocusScales(brush: GPPATHGRADIENT;
    var xScale: Single; var yScale: Single): GPSTATUS; stdcall;

  function GdipSetPathGradientFocusScales(brush: GPPATHGRADIENT;
    xScale: Single; yScale: Single): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Pen APIs
//----------------------------------------------------------------------------

  function GdipCreatePen1(color: ARGB; width: Single; unit_: GPUNIT;
    out pen: GPPEN): GPSTATUS; stdcall;

  function GdipCreatePen2(brush: GPBRUSH; width: Single; unit_: GPUNIT;
    out pen: GPPEN): GPSTATUS; stdcall;

  function GdipClonePen(pen: GPPEN; out clonepen: GPPEN): GPSTATUS; stdcall;

  function GdipDeletePen(pen: GPPEN): GPSTATUS; stdcall;

  function GdipSetPenWidth(pen: GPPEN; width: Single): GPSTATUS; stdcall;

  function GdipGetPenWidth(pen: GPPEN; out width: Single): GPSTATUS; stdcall;

  function GdipSetPenUnit(pen: GPPEN; unit_: GPUNIT): GPSTATUS; stdcall;

  function GdipGetPenUnit(pen: GPPEN; var unit_: GPUNIT): GPSTATUS; stdcall;

  function GdipSetPenLineCap197819(pen: GPPEN; startCap: GPLINECAP;
    endCap: GPLINECAP; dashCap: GPDASHCAP): GPSTATUS; stdcall;

  function GdipSetPenStartCap(pen: GPPEN;
    startCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipSetPenEndCap(pen: GPPEN; endCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipSetPenDashCap197819(pen: GPPEN;
    dashCap: GPDASHCAP): GPSTATUS; stdcall;

  function GdipGetPenStartCap(pen: GPPEN;
    out startCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipGetPenEndCap(pen: GPPEN;
    out endCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipGetPenDashCap197819(pen: GPPEN;
    out dashCap: GPDASHCAP): GPSTATUS; stdcall;

  function GdipSetPenLineJoin(pen: GPPEN;
    lineJoin: GPLINEJOIN): GPSTATUS; stdcall;

  function GdipGetPenLineJoin(pen: GPPEN;
    var lineJoin: GPLINEJOIN): GPSTATUS; stdcall;

  function GdipSetPenCustomStartCap(pen: GPPEN;
    customCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipGetPenCustomStartCap(pen: GPPEN;
    out customCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipSetPenCustomEndCap(pen: GPPEN;
    customCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipGetPenCustomEndCap(pen: GPPEN;
    out customCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipSetPenMiterLimit(pen: GPPEN;
    miterLimit: Single): GPSTATUS; stdcall;

  function GdipGetPenMiterLimit(pen: GPPEN;
    out miterLimit: Single): GPSTATUS; stdcall;

  function GdipSetPenMode(pen: GPPEN;
    penMode: GPPENALIGNMENT): GPSTATUS; stdcall;

  function GdipGetPenMode(pen: GPPEN;
    var penMode: GPPENALIGNMENT): GPSTATUS; stdcall;

  function GdipSetPenTransform(pen: GPPEN;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipGetPenTransform(pen: GPPEN;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipResetPenTransform(pen: GPPEN): GPSTATUS; stdcall;

  function GdipMultiplyPenTransform(pen: GPPEN; matrix: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipTranslatePenTransform(pen: GPPEN; dx: Single; dy: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipScalePenTransform(pen: GPPEN; sx: Single; sy: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipRotatePenTransform(pen: GPPEN; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipSetPenColor(pen: GPPEN; argb: ARGB): GPSTATUS; stdcall;

  function GdipGetPenColor(pen: GPPEN; out argb: ARGB): GPSTATUS; stdcall;

  function GdipSetPenBrushFill(pen: GPPEN; brush: GPBRUSH): GPSTATUS; stdcall;

  function GdipGetPenBrushFill(pen: GPPEN;
    out brush: GPBRUSH): GPSTATUS; stdcall;

  function GdipGetPenFillType(pen: GPPEN;
    out type_: GPPENTYPE): GPSTATUS; stdcall;

  function GdipGetPenDashStyle(pen: GPPEN;
    out dashstyle: GPDASHSTYLE): GPSTATUS; stdcall;

  function GdipSetPenDashStyle(pen: GPPEN;
    dashstyle: GPDASHSTYLE): GPSTATUS; stdcall;

  function GdipGetPenDashOffset(pen: GPPEN;
    out offset: Single): GPSTATUS; stdcall;

  function GdipSetPenDashOffset(pen: GPPEN; offset: Single): GPSTATUS; stdcall;

  function GdipGetPenDashCount(pen: GPPEN;
    var count: Integer): GPSTATUS; stdcall;

  function GdipSetPenDashArray(pen: GPPEN; dash: PSingle;
    count: Integer): GPSTATUS; stdcall;

  function GdipGetPenDashArray(pen: GPPEN; dash: PSingle;
    count: Integer): GPSTATUS; stdcall;

  function GdipGetPenCompoundCount(pen: GPPEN;
    out count: Integer): GPSTATUS; stdcall;

  function GdipSetPenCompoundArray(pen: GPPEN; dash: PSingle;
    count: Integer): GPSTATUS; stdcall;

  function GdipGetPenCompoundArray(pen: GPPEN; dash: PSingle;
    count: Integer): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// CustomLineCap APIs
//----------------------------------------------------------------------------

  function GdipCreateCustomLineCap(fillPath: GPPATH; strokePath: GPPATH;
    baseCap: GPLINECAP; baseInset: Single;
    out customCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipDeleteCustomLineCap(
    customCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipCloneCustomLineCap(customCap: GPCUSTOMLINECAP;
    out clonedCap: GPCUSTOMLINECAP): GPSTATUS; stdcall;

  function GdipGetCustomLineCapType(customCap: GPCUSTOMLINECAP;
    var capType: CUSTOMLINECAPTYPE): GPSTATUS; stdcall;

  function GdipSetCustomLineCapStrokeCaps(customCap: GPCUSTOMLINECAP;
    startCap: GPLINECAP; endCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipGetCustomLineCapStrokeCaps(customCap: GPCUSTOMLINECAP;
    var startCap: GPLINECAP; var endCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipSetCustomLineCapStrokeJoin(customCap: GPCUSTOMLINECAP;
  lineJoin: GPLINEJOIN): GPSTATUS; stdcall;

  function GdipGetCustomLineCapStrokeJoin(customCap: GPCUSTOMLINECAP;
  var lineJoin: GPLINEJOIN): GPSTATUS; stdcall;

  function GdipSetCustomLineCapBaseCap(customCap: GPCUSTOMLINECAP;
  baseCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipGetCustomLineCapBaseCap(customCap: GPCUSTOMLINECAP;
  var baseCap: GPLINECAP): GPSTATUS; stdcall;

  function GdipSetCustomLineCapBaseInset(customCap: GPCUSTOMLINECAP;
  inset: Single): GPSTATUS; stdcall;

  function GdipGetCustomLineCapBaseInset(customCap: GPCUSTOMLINECAP;
  var inset: Single): GPSTATUS; stdcall;

  function GdipSetCustomLineCapWidthScale(customCap: GPCUSTOMLINECAP;
  widthScale: Single): GPSTATUS; stdcall;

  function GdipGetCustomLineCapWidthScale(customCap: GPCUSTOMLINECAP;
  var widthScale: Single): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// AdjustableArrowCap APIs
//----------------------------------------------------------------------------

  function GdipCreateAdjustableArrowCap(height: Single;
  width: Single;
  isFilled: Bool;
  out cap: GPADJUSTABLEARROWCAP): GPSTATUS; stdcall;

  function GdipSetAdjustableArrowCapHeight(cap: GPADJUSTABLEARROWCAP;
  height: Single): GPSTATUS; stdcall;

  function GdipGetAdjustableArrowCapHeight(cap: GPADJUSTABLEARROWCAP;
  var height: Single): GPSTATUS; stdcall;

  function GdipSetAdjustableArrowCapWidth(cap: GPADJUSTABLEARROWCAP;
  width: Single): GPSTATUS; stdcall;

  function GdipGetAdjustableArrowCapWidth(cap: GPADJUSTABLEARROWCAP;
  var width: Single): GPSTATUS; stdcall;

  function GdipSetAdjustableArrowCapMiddleInset(cap: GPADJUSTABLEARROWCAP;
  middleInset: Single): GPSTATUS; stdcall;

  function GdipGetAdjustableArrowCapMiddleInset(cap: GPADJUSTABLEARROWCAP;
  var middleInset: Single): GPSTATUS; stdcall;

  function GdipSetAdjustableArrowCapFillState(cap: GPADJUSTABLEARROWCAP;
  fillState: Bool): GPSTATUS; stdcall;

  function GdipGetAdjustableArrowCapFillState(cap: GPADJUSTABLEARROWCAP;
  var fillState: Bool): GPSTATUS; stdcall;

//---------------------------------------------------------------------------- 
// Image APIs
//----------------------------------------------------------------------------

  function GdipLoadImageFromStream(stream: ISTREAM;
  out image: GPIMAGE): GPSTATUS; stdcall;

  function GdipLoadImageFromFile(filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;

  function GdipLoadImageFromStreamICM(stream: ISTREAM;
  out image: GPIMAGE): GPSTATUS; stdcall;

  function GdipLoadImageFromFileICM(filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;

  function GdipCloneImage(image: GPIMAGE;
  out cloneImage: GPIMAGE): GPSTATUS; stdcall;

  function GdipDisposeImage(image: GPIMAGE): GPSTATUS; stdcall;

  function GdipSaveImageToFile(image: GPIMAGE;
  filename: PWCHAR;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;

  function GdipSaveImageToStream(image: GPIMAGE;
  stream: ISTREAM;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;

  function GdipSaveAdd(image: GPIMAGE;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;

  function GdipSaveAddImage(image: GPIMAGE;
  newImage: GPIMAGE;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;

  function GdipGetImageGraphicsContext(image: GPIMAGE;
  out graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipGetImageBounds(image: GPIMAGE;
  srcRect: GPRECTF;
  var srcUnit: GPUNIT): GPSTATUS; stdcall;

  function GdipGetImageDimension(image: GPIMAGE;
  var width: Single;
  var height: Single): GPSTATUS; stdcall;

  function GdipGetImageType(image: GPIMAGE;
  var type_: IMAGETYPE): GPSTATUS; stdcall;

  function GdipGetImageWidth(image: GPIMAGE;
  var width: UINT): GPSTATUS; stdcall;

  function GdipGetImageHeight(image: GPIMAGE;
  var height: UINT): GPSTATUS; stdcall;

  function GdipGetImageHorizontalResolution(image: GPIMAGE;
  var resolution: Single): GPSTATUS; stdcall;

  function GdipGetImageVerticalResolution(image: GPIMAGE;
  var resolution: Single): GPSTATUS; stdcall;

  function GdipGetImageFlags(image: GPIMAGE;
  var flags: UINT): GPSTATUS; stdcall;

  function GdipGetImageRawFormat(image: GPIMAGE;
  format: PGUID): GPSTATUS; stdcall;

  function GdipGetImagePixelFormat(image: GPIMAGE;
  out format: TPIXELFORMAT): GPSTATUS; stdcall;

  function GdipGetImageThumbnail(image: GPIMAGE; thumbWidth: UINT;
    thumbHeight: UINT; out thumbImage: GPIMAGE;
    callback: GETTHUMBNAILIMAGEABORT; callbackData: Pointer): GPSTATUS; stdcall;

  function GdipGetEncoderParameterListSize(image: GPIMAGE;
    clsidEncoder: PGUID; out size: UINT): GPSTATUS; stdcall;

  function GdipGetEncoderParameterList(image: GPIMAGE; clsidEncoder: PGUID;
    size: UINT; buffer: PENCODERPARAMETERS): GPSTATUS; stdcall;

  function GdipImageGetFrameDimensionsCount(image: GPIMAGE;
    var count: UINT): GPSTATUS; stdcall;

  function GdipImageGetFrameDimensionsList(image: GPIMAGE; dimensionIDs: PGUID;
    count: UINT): GPSTATUS; stdcall;

  function GdipImageGetFrameCount(image: GPIMAGE; dimensionID: PGUID;
    var count: UINT): GPSTATUS; stdcall;

  function GdipImageSelectActiveFrame(image: GPIMAGE; dimensionID: PGUID;
    frameIndex: UINT): GPSTATUS; stdcall;

  function GdipImageRotateFlip(image: GPIMAGE;
    rfType: ROTATEFLIPTYPE): GPSTATUS; stdcall;

  function GdipGetImagePalette(image: GPIMAGE; palette: PCOLORPALETTE;
    size: Integer): GPSTATUS; stdcall;

  function GdipSetImagePalette(image: GPIMAGE;
    palette: PCOLORPALETTE): GPSTATUS; stdcall;

  function GdipGetImagePaletteSize(image: GPIMAGE;
    var size: Integer): GPSTATUS; stdcall;

  function GdipGetPropertyCount(image: GPIMAGE;
    var numOfProperty: UINT): GPSTATUS; stdcall;

  function GdipGetPropertyIdList(image: GPIMAGE; numOfProperty: UINT;
    list: PPROPID): GPSTATUS; stdcall;

  function GdipGetPropertyItemSize(image: GPIMAGE; propId: PROPID;
    var size: UINT): GPSTATUS; stdcall;

  function GdipGetPropertyItem(image: GPIMAGE; propId: PROPID; propSize: UINT;
    buffer: PPROPERTYITEM): GPSTATUS; stdcall;

  function GdipGetPropertySize(image: GPIMAGE; var totalBufferSize: UINT;
    var numProperties: UINT): GPSTATUS; stdcall;

  function GdipGetAllPropertyItems(image: GPIMAGE; totalBufferSize: UINT;
    numProperties: UINT; allItems: PPROPERTYITEM): GPSTATUS; stdcall;

  function GdipRemovePropertyItem(image: GPIMAGE;
    propId: PROPID): GPSTATUS; stdcall;

  function GdipSetPropertyItem(image: GPIMAGE;
    item: PPROPERTYITEM): GPSTATUS; stdcall;

  function GdipImageForceValidation(image: GPIMAGE): GPSTATUS; stdcall;

//---------------------------------------------------------------------------- 
// Bitmap APIs
//----------------------------------------------------------------------------

  function GdipCreateBitmapFromStream(stream: ISTREAM;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromFile(filename: PWCHAR;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromStreamICM(stream: ISTREAM;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromFileICM(filename: PWCHAR;
    var bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromScan0(width: Integer; height: Integer;
    stride: Integer; format: PIXELFORMAT; scan0: PBYTE;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromGraphics(width: Integer; height: Integer;
    target: GPGRAPHICS; out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromDirectDrawSurface(surface: IDIRECTDRAWSURFACE7;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromGdiDib(gdiBitmapInfo: PBitmapInfo;
    gdiBitmapData: Pointer; out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateBitmapFromHBITMAP(hbm: HBITMAP; hpal: HPALETTE;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateHBITMAPFromBitmap(bitmap: GPBITMAP; out hbmReturn: HBITMAP;
    background: ARGB): GPSTATUS; stdcall;

  function GdipCreateBitmapFromHICON(hicon: HICON;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCreateHICONFromBitmap(bitmap: GPBITMAP;
    out hbmReturn: HICON): GPSTATUS; stdcall;

  function GdipCreateBitmapFromResource(hInstance: HMODULE;
    lpBitmapName: PWCHAR; out bitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCloneBitmapArea(x: Single; y: Single; width: Single;
    height: Single; format: PIXELFORMAT; srcBitmap: GPBITMAP;
    out dstBitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipCloneBitmapAreaI(x: Integer; y: Integer; width: Integer;
    height: Integer; format: PIXELFORMAT; srcBitmap: GPBITMAP;
    out dstBitmap: GPBITMAP): GPSTATUS; stdcall;

  function GdipBitmapLockBits(bitmap: GPBITMAP; rect: GPRECT; flags: UINT;
    format: PIXELFORMAT; lockedBitmapData: PBITMAPDATA): GPSTATUS; stdcall;

  function GdipBitmapUnlockBits(bitmap: GPBITMAP;
    lockedBitmapData: PBITMAPDATA): GPSTATUS; stdcall;

  function GdipBitmapGetPixel(bitmap: GPBITMAP; x: Integer; y: Integer;
    var color: ARGB): GPSTATUS; stdcall;

  function GdipBitmapSetPixel(bitmap: GPBITMAP; x: Integer; y: Integer;
    color: ARGB): GPSTATUS; stdcall;

  function GdipBitmapSetResolution(bitmap: GPBITMAP; xdpi: Single;
    ydpi: Single): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// ImageAttributes APIs
//----------------------------------------------------------------------------

  function GdipCreateImageAttributes(
    out imageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipCloneImageAttributes(imageattr: GPIMAGEATTRIBUTES;
    out cloneImageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipDisposeImageAttributes(
    imageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipSetImageAttributesToIdentity(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE): GPSTATUS; stdcall;

  function GdipResetImageAttributes(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE): GPSTATUS; stdcall;

  function GdipSetImageAttributesColorMatrix(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; colorMatrix: PCOLORMATRIX;
    grayMatrix: PCOLORMATRIX; flags: COLORMATRIXFLAGS): GPSTATUS; stdcall;

  function GdipSetImageAttributesThreshold(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool;
    threshold: Single): GPSTATUS; stdcall;

  function GdipSetImageAttributesGamma(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; gamma: Single): GPSTATUS; stdcall;

  function GdipSetImageAttributesNoOp(imageattr: GPIMAGEATTRIBUTES;
  type_: COLORADJUSTTYPE; enableFlag: Bool): GPSTATUS; stdcall;

  function GdipSetImageAttributesColorKeys(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; colorLow: ARGB;
    colorHigh: ARGB): GPSTATUS; stdcall;

  function GdipSetImageAttributesOutputChannel(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool;
    channelFlags: COLORCHANNELFLAGS): GPSTATUS; stdcall;

  function GdipSetImageAttributesOutputChannelColorProfile(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool;
    colorProfileFilename: PWCHAR): GPSTATUS; stdcall;

  function GdipSetImageAttributesRemapTable(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; mapSize: UINT;
    map: PCOLORMAP): GPSTATUS; stdcall;

  function GdipSetImageAttributesWrapMode(imageAttr: GPIMAGEATTRIBUTES;
    wrap: WRAPMODE; argb: ARGB; clamp: Bool): GPSTATUS; stdcall;

  function GdipSetImageAttributesICMMode(imageAttr: GPIMAGEATTRIBUTES;
    on_: Bool): GPSTATUS; stdcall;

  function GdipGetImageAttributesAdjustedPalette(imageAttr: GPIMAGEATTRIBUTES;
    colorPalette: PCOLORPALETTE;
    colorAdjustType: COLORADJUSTTYPE): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Graphics APIs
//----------------------------------------------------------------------------

  function GdipFlush(graphics: GPGRAPHICS;
    intention: GPFLUSHINTENTION): GPSTATUS; stdcall;

  function GdipCreateFromHDC(hdc: HDC;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipCreateFromHDC2(hdc: HDC; hDevice: THandle;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipCreateFromHWND(hwnd: HWND;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipCreateFromHWNDICM(hwnd: HWND;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipDeleteGraphics(graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipGetDC(graphics: GPGRAPHICS; var hdc: HDC): GPSTATUS; stdcall;

  function GdipReleaseDC(graphics: GPGRAPHICS; hdc: HDC): GPSTATUS; stdcall;

  function GdipSetCompositingMode(graphics: GPGRAPHICS;
    compositingMode: COMPOSITINGMODE): GPSTATUS; stdcall;

  function GdipGetCompositingMode(graphics: GPGRAPHICS;
    var compositingMode: COMPOSITINGMODE): GPSTATUS; stdcall;

  function GdipSetRenderingOrigin(graphics: GPGRAPHICS; x: Integer;
    y: Integer): GPSTATUS; stdcall;

  function GdipGetRenderingOrigin(graphics: GPGRAPHICS; var x: Integer;
    var y: Integer): GPSTATUS; stdcall;

  function GdipSetCompositingQuality(graphics: GPGRAPHICS;
    compositingQuality: COMPOSITINGQUALITY): GPSTATUS; stdcall;

  function GdipGetCompositingQuality(graphics: GPGRAPHICS;
    var compositingQuality: COMPOSITINGQUALITY): GPSTATUS; stdcall;

  function GdipSetSmoothingMode(graphics: GPGRAPHICS;
    smoothingMode: SMOOTHINGMODE): GPSTATUS; stdcall;

  function GdipGetSmoothingMode(graphics: GPGRAPHICS;
    var smoothingMode: SMOOTHINGMODE): GPSTATUS; stdcall;

  function GdipSetPixelOffsetMode(graphics: GPGRAPHICS;
    pixelOffsetMode: PIXELOFFSETMODE): GPSTATUS; stdcall;

  function GdipGetPixelOffsetMode(graphics: GPGRAPHICS;
    var pixelOffsetMode: PIXELOFFSETMODE): GPSTATUS; stdcall;

  function GdipSetTextRenderingHint(graphics: GPGRAPHICS;
    mode: TEXTRENDERINGHINT): GPSTATUS; stdcall;

  function GdipGetTextRenderingHint(graphics: GPGRAPHICS;
    var mode: TEXTRENDERINGHINT): GPSTATUS; stdcall;

  function GdipSetTextContrast(graphics: GPGRAPHICS;
    contrast: Integer): GPSTATUS; stdcall;

  function GdipGetTextContrast(graphics: GPGRAPHICS;
    var contrast: UINT): GPSTATUS; stdcall;

  function GdipSetInterpolationMode(graphics: GPGRAPHICS;
    interpolationMode: INTERPOLATIONMODE): GPSTATUS; stdcall;

  function GdipGetInterpolationMode(graphics: GPGRAPHICS;
    var interpolationMode: INTERPOLATIONMODE): GPSTATUS; stdcall;

  function GdipSetWorldTransform(graphics: GPGRAPHICS;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipResetWorldTransform(graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipMultiplyWorldTransform(graphics: GPGRAPHICS; matrix: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipTranslateWorldTransform(graphics: GPGRAPHICS; dx: Single;
    dy: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipScaleWorldTransform(graphics: GPGRAPHICS; sx: Single; sy: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipRotateWorldTransform(graphics: GPGRAPHICS; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;

  function GdipGetWorldTransform(graphics: GPGRAPHICS;
    matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipResetPageTransform(graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipGetPageUnit(graphics: GPGRAPHICS;
    var unit_: GPUNIT): GPSTATUS; stdcall;

  function GdipGetPageScale(graphics: GPGRAPHICS;
    var scale: Single): GPSTATUS; stdcall;

  function GdipSetPageUnit(graphics: GPGRAPHICS;
    unit_: GPUNIT): GPSTATUS; stdcall;

  function GdipSetPageScale(graphics: GPGRAPHICS;
    scale: Single): GPSTATUS; stdcall;

  function GdipGetDpiX(graphics: GPGRAPHICS;
    var dpi: Single): GPSTATUS; stdcall;

  function GdipGetDpiY(graphics: GPGRAPHICS;
    var dpi: Single): GPSTATUS; stdcall;

  function GdipTransformPoints(graphics: GPGRAPHICS;
    destSpace: GPCOORDINATESPACE; srcSpace: GPCOORDINATESPACE;
    points: GPPOINTF; count: Integer): GPSTATUS; stdcall;

  function GdipTransformPointsI(graphics: GPGRAPHICS;
    destSpace: GPCOORDINATESPACE; srcSpace: GPCOORDINATESPACE;
    points: GPPOINT; count: Integer): GPSTATUS; stdcall;

  function GdipGetNearestColor(graphics: GPGRAPHICS;
    argb: PARGB): GPSTATUS; stdcall;

// Creates the Win9x Halftone Palette (even on NT) with correct Desktop colors

  function GdipCreateHalftonePalette: HPALETTE; stdcall;

  function GdipDrawLine(graphics: GPGRAPHICS; pen: GPPEN; x1: Single;
    y1: Single; x2: Single; y2: Single): GPSTATUS; stdcall;

  function GdipDrawLineI(graphics: GPGRAPHICS; pen: GPPEN; x1: Integer;
    y1: Integer; x2: Integer; y2: Integer): GPSTATUS; stdcall;

  function GdipDrawLines(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawLinesI(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawArc(graphics: GPGRAPHICS; pen: GPPEN; x: Single; y: Single;
    width: Single; height: Single; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipDrawArcI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipDrawBezier(graphics: GPGRAPHICS; pen: GPPEN; x1: Single;
    y1: Single; x2: Single; y2: Single; x3: Single; y3: Single; x4: Single;
    y4: Single): GPSTATUS; stdcall;

  function GdipDrawBezierI(graphics: GPGRAPHICS; pen: GPPEN; x1: Integer;
    y1: Integer; x2: Integer; y2: Integer; x3: Integer; y3: Integer;
    x4: Integer; y4: Integer): GPSTATUS; stdcall;

  function GdipDrawBeziers(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawBeziersI(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawRectangle(graphics: GPGRAPHICS; pen: GPPEN; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;

  function GdipDrawRectangleI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipDrawRectangles(graphics: GPGRAPHICS; pen: GPPEN; rects: GPRECTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawRectanglesI(graphics: GPGRAPHICS; pen: GPPEN; rects: GPRECT;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawEllipse(graphics: GPGRAPHICS; pen: GPPEN; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;

  function GdipDrawEllipseI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipDrawPie(graphics: GPGRAPHICS; pen: GPPEN; x: Single; y: Single;
    width: Single;  height: Single; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipDrawPieI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipDrawPolygon(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawPolygonI(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawPath(graphics: GPGRAPHICS; pen: GPPEN;
    path: GPPATH): GPSTATUS; stdcall;

  function GdipDrawCurve(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawCurveI(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;

  function GdipDrawCurve2(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINTF;
    count: Integer; tension: Single): GPSTATUS; stdcall;

  function GdipDrawCurve2I(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINT;
    count: Integer; tension: Single): GPSTATUS; stdcall;

  function GdipDrawCurve3(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINTF;
    count: Integer; offset: Integer; numberOfSegments: Integer;
    tension: Single): GPSTATUS; stdcall;

  function GdipDrawCurve3I(graphics: GPGRAPHICS; pen: GPPEN; points: GPPOINT;
    count: Integer; offset: Integer; numberOfSegments: Integer;
    tension: Single): GPSTATUS; stdcall;

  function GdipDrawClosedCurve(graphics: GPGRAPHICS; pen: GPPEN;
    points: GPPOINTF; count: Integer): GPSTATUS; stdcall;

  function GdipDrawClosedCurveI(graphics: GPGRAPHICS; pen: GPPEN;
    points: GPPOINT; count: Integer): GPSTATUS; stdcall;

  function GdipDrawClosedCurve2(graphics: GPGRAPHICS; pen: GPPEN;
    points: GPPOINTF; count: Integer; tension: Single): GPSTATUS; stdcall;

  function GdipDrawClosedCurve2I(graphics: GPGRAPHICS; pen: GPPEN;
    points: GPPOINT; count: Integer; tension: Single): GPSTATUS; stdcall;

  function GdipGraphicsClear(graphics: GPGRAPHICS;
    color: ARGB): GPSTATUS; stdcall;

  function GdipFillRectangle(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;

  function GdipFillRectangleI(graphics: GPGRAPHICS; brush: GPBRUSH; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipFillRectangles(graphics: GPGRAPHICS; brush: GPBRUSH;
    rects: GPRECTF; count: Integer): GPSTATUS; stdcall;

  function GdipFillRectanglesI(graphics: GPGRAPHICS; brush: GPBRUSH;
    rects: GPRECT; count: Integer): GPSTATUS; stdcall;

  function GdipFillPolygon(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINTF; count: Integer; fillMode: GPFILLMODE): GPSTATUS; stdcall;

  function GdipFillPolygonI(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINT; count: Integer; fillMode: GPFILLMODE): GPSTATUS; stdcall;

  function GdipFillPolygon2(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINTF; count: Integer): GPSTATUS; stdcall;

  function GdipFillPolygon2I(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINT; count: Integer): GPSTATUS; stdcall;

  function GdipFillEllipse(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;

  function GdipFillEllipseI(graphics: GPGRAPHICS; brush: GPBRUSH; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipFillPie(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipFillPieI(graphics: GPGRAPHICS; brush: GPBRUSH; x: Integer;
    y: Integer; width: Integer; height: Integer; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;

  function GdipFillPath(graphics: GPGRAPHICS; brush: GPBRUSH;
    path: GPPATH): GPSTATUS; stdcall;

  function GdipFillClosedCurve(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINTF; count: Integer): GPSTATUS; stdcall;

  function GdipFillClosedCurveI(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINT; count: Integer): GPSTATUS; stdcall;

  function GdipFillClosedCurve2(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINTF; count: Integer; tension: Single;
    fillMode: GPFILLMODE): GPSTATUS; stdcall;

  function GdipFillClosedCurve2I(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINT; count: Integer; tension: Single;
    fillMode: GPFILLMODE): GPSTATUS; stdcall;

  function GdipFillRegion(graphics: GPGRAPHICS; brush: GPBRUSH;
    region: GPREGION): GPSTATUS; stdcall;

  function GdipDrawImage(graphics: GPGRAPHICS; image: GPIMAGE; x: Single;
    y: Single): GPSTATUS; stdcall;

  function GdipDrawImageI(graphics: GPGRAPHICS; image: GPIMAGE; x: Integer;
    y: Integer): GPSTATUS; stdcall;

  function GdipDrawImageRect(graphics: GPGRAPHICS; image: GPIMAGE; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;

  function GdipDrawImageRectI(graphics: GPGRAPHICS; image: GPIMAGE; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;

  function GdipDrawImagePoints(graphics: GPGRAPHICS; image: GPIMAGE;
    dstpoints: GPPOINTF; count: Integer): GPSTATUS; stdcall;

  function GdipDrawImagePointsI(graphics: GPGRAPHICS; image: GPIMAGE;
    dstpoints: GPPOINT; count: Integer): GPSTATUS; stdcall;

  function GdipDrawImagePointRect(graphics: GPGRAPHICS; image: GPIMAGE;
    x: Single; y: Single; srcx: Single; srcy: Single; srcwidth: Single;
    srcheight: Single; srcUnit: GPUNIT): GPSTATUS; stdcall;

  function GdipDrawImagePointRectI(graphics: GPGRAPHICS; image: GPIMAGE;
    x: Integer; y: Integer; srcx: Integer; srcy: Integer; srcwidth: Integer;
    srcheight: Integer; srcUnit: GPUNIT): GPSTATUS; stdcall;

  function GdipDrawImageRectRect(graphics: GPGRAPHICS; image: GPIMAGE;
    dstx: Single; dsty: Single; dstwidth: Single; dstheight: Single;
    srcx: Single; srcy: Single; srcwidth: Single; srcheight: Single;
    srcUnit: GPUNIT; imageAttributes: GPIMAGEATTRIBUTES;
    callback: DRAWIMAGEABORT; callbackData: Pointer): GPSTATUS; stdcall;

  function GdipDrawImageRectRectI(graphics: GPGRAPHICS; image: GPIMAGE;
    dstx: Integer; dsty: Integer; dstwidth: Integer; dstheight: Integer;
    srcx: Integer; srcy: Integer; srcwidth: Integer; srcheight: Integer;
    srcUnit: GPUNIT; imageAttributes: GPIMAGEATTRIBUTES;
    callback: DRAWIMAGEABORT; callbackData: Pointer): GPSTATUS; stdcall;

  function GdipDrawImagePointsRect(graphics: GPGRAPHICS; image: GPIMAGE;
    points: GPPOINTF; count: Integer; srcx: Single; srcy: Single;
    srcwidth: Single; srcheight: Single; srcUnit: GPUNIT;
    imageAttributes: GPIMAGEATTRIBUTES; callback: DRAWIMAGEABORT;
    callbackData: Pointer): GPSTATUS; stdcall;

  function GdipDrawImagePointsRectI(graphics: GPGRAPHICS; image: GPIMAGE;
    points: GPPOINT; count: Integer; srcx: Integer; srcy: Integer;
    srcwidth: Integer; srcheight: Integer; srcUnit: GPUNIT;
    imageAttributes: GPIMAGEATTRIBUTES; callback: DRAWIMAGEABORT;
    callbackData: Pointer): GPSTATUS; stdcall;

  function GdipEnumerateMetafileDestPoint(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoint: PGPPointF; callback: ENUMERATEMETAFILEPROC;
    callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileDestPointI(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoint: PGPPoint; callback: ENUMERATEMETAFILEPROC;
    callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileDestRect(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destRect: PGPRectF; callback: ENUMERATEMETAFILEPROC;
    callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileDestRectI(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destRect: PGPRect; callback: ENUMERATEMETAFILEPROC;
    callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileDestPoints(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoints: PGPPointF; count: Integer;
    callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileDestPointsI(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoints: PGPPoint; count: Integer;
    callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileSrcRectDestPoint(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoint: PGPPointF; srcRect: PGPRectF; srcUnit: TUNIT;
    callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileSrcRectDestPointI(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoint: PGPPoint; srcRect: PGPRect; srcUnit: TUNIT;
    callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileSrcRectDestRect(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destRect: PGPRectF; srcRect: PGPRectF; srcUnit: TUNIT;
    callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileSrcRectDestRectI(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destRect: PGPRect; srcRect: PGPRect; srcUnit: TUNIT;
    callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileSrcRectDestPoints(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoints: PGPPointF; count: Integer; srcRect: PGPRectF;
    srcUnit: TUNIT; callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipEnumerateMetafileSrcRectDestPointsI(graphics: GPGRAPHICS;
    metafile: GPMETAFILE; destPoints: PGPPoint; count: Integer; srcRect: PGPRect;
    srcUnit: TUNIT; callback: ENUMERATEMETAFILEPROC; callbackData: Pointer;
    imageAttributes: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;

  function GdipPlayMetafileRecord(metafile: GPMETAFILE;
    recordType: EMFPLUSRECORDTYPE; flags: UINT; dataSize: UINT;
    data: PBYTE): GPSTATUS; stdcall;

  function GdipSetClipGraphics(graphics: GPGRAPHICS; srcgraphics: GPGRAPHICS;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipSetClipRect(graphics: GPGRAPHICS; x: Single; y: Single;
    width: Single; height: Single; combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipSetClipRectI(graphics: GPGRAPHICS; x: Integer; y: Integer;
    width: Integer; height: Integer;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipSetClipPath(graphics: GPGRAPHICS; path: GPPATH;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipSetClipRegion(graphics: GPGRAPHICS; region: GPREGION;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipSetClipHrgn(graphics: GPGRAPHICS; hRgn: HRGN;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;

  function GdipResetClip(graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipTranslateClip(graphics: GPGRAPHICS; dx: Single;
    dy: Single): GPSTATUS; stdcall;

  function GdipTranslateClipI(graphics: GPGRAPHICS; dx: Integer;
    dy: Integer): GPSTATUS; stdcall;

  function GdipGetClip(graphics: GPGRAPHICS;
    region: GPREGION): GPSTATUS; stdcall;

  function GdipGetClipBounds(graphics: GPGRAPHICS;
    rect: GPRECTF): GPSTATUS; stdcall;

  function GdipGetClipBoundsI(graphics: GPGRAPHICS;
    rect: GPRECT): GPSTATUS; stdcall;

  function GdipIsClipEmpty(graphics: GPGRAPHICS;
    result: PBool): GPSTATUS; stdcall;

  function GdipGetVisibleClipBounds(graphics: GPGRAPHICS;
    rect: GPRECTF): GPSTATUS; stdcall;

  function GdipGetVisibleClipBoundsI(graphics: GPGRAPHICS;
    rect: GPRECT): GPSTATUS; stdcall;

  function GdipIsVisibleClipEmpty(graphics: GPGRAPHICS;
    var result: Bool): GPSTATUS; stdcall;

  function GdipIsVisiblePoint(graphics: GPGRAPHICS; x: Single; y: Single;
    var result: Bool): GPSTATUS; stdcall;

  function GdipIsVisiblePointI(graphics: GPGRAPHICS; x: Integer; y: Integer;
    var result: Bool): GPSTATUS; stdcall;

  function GdipIsVisibleRect(graphics: GPGRAPHICS; x: Single; y: Single;
    width: Single; height: Single; var result: Bool): GPSTATUS; stdcall;

  function GdipIsVisibleRectI(graphics: GPGRAPHICS; x: Integer; y: Integer;
    width: Integer; height: Integer; var result: Bool): GPSTATUS; stdcall;

  function GdipSaveGraphics(graphics: GPGRAPHICS;
    var state: GRAPHICSSTATE): GPSTATUS; stdcall;

  function GdipRestoreGraphics(graphics: GPGRAPHICS;
    state: GRAPHICSSTATE): GPSTATUS; stdcall;

  function GdipBeginContainer(graphics: GPGRAPHICS; dstrect: GPRECTF;
    srcrect: GPRECTF; unit_: GPUNIT;
    var state: GRAPHICSCONTAINER): GPSTATUS; stdcall;

  function GdipBeginContainerI(graphics: GPGRAPHICS; dstrect: GPRECT;
    srcrect: GPRECT; unit_: GPUNIT;
    var state: GRAPHICSCONTAINER): GPSTATUS; stdcall;

  function GdipBeginContainer2(graphics: GPGRAPHICS;
    var state: GRAPHICSCONTAINER): GPSTATUS; stdcall;

  function GdipEndContainer(graphics: GPGRAPHICS;
    state: GRAPHICSCONTAINER): GPSTATUS; stdcall;

  function GdipGetMetafileHeaderFromWmf(hWmf: HMETAFILE;
    wmfPlaceableFileHeader: PWMFPLACEABLEFILEHEADER;
    header: Pointer): GPSTATUS; stdcall;

  function GdipGetMetafileHeaderFromEmf(hEmf: HENHMETAFILE;
    header: Pointer): GPSTATUS; stdcall;

  function GdipGetMetafileHeaderFromFile(filename: PWCHAR;
    header: Pointer): GPSTATUS; stdcall;

  function GdipGetMetafileHeaderFromStream(stream: ISTREAM;
    header: Pointer): GPSTATUS; stdcall;

  function GdipGetMetafileHeaderFromMetafile(metafile: GPMETAFILE;
    header: Pointer): GPSTATUS; stdcall;

  function GdipGetHemfFromMetafile(metafile: GPMETAFILE;
    var hEmf: HENHMETAFILE): GPSTATUS; stdcall;

  function GdipCreateStreamOnFile(filename: PWCHAR; access: UINT;
    out stream: ISTREAM): GPSTATUS; stdcall;

  function GdipCreateMetafileFromWmf(hWmf: HMETAFILE; deleteWmf: Bool;
    wmfPlaceableFileHeader: PWMFPLACEABLEFILEHEADER;
    out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipCreateMetafileFromEmf(hEmf: HENHMETAFILE; deleteEmf: Bool;
    out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipCreateMetafileFromFile(file_: PWCHAR;
    out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipCreateMetafileFromWmfFile(file_: PWCHAR;
    wmfPlaceableFileHeader: PWMFPLACEABLEFILEHEADER;
    out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipCreateMetafileFromStream(stream: ISTREAM;
    out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipRecordMetafile(referenceHdc: HDC; type_: EMFTYPE;
    frameRect: GPRECTF; frameUnit: METAFILEFRAMEUNIT;
    description: PWCHAR; out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipRecordMetafileI(referenceHdc: HDC; type_: EMFTYPE;
    frameRect: GPRECT; frameUnit: METAFILEFRAMEUNIT; description: PWCHAR;
    out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipRecordMetafileFileName(fileName: PWCHAR; referenceHdc: HDC;
    type_: EMFTYPE; frameRect: GPRECTF; frameUnit: METAFILEFRAMEUNIT;
    description: PWCHAR; out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipRecordMetafileFileNameI(fileName: PWCHAR; referenceHdc: HDC;
    type_: EMFTYPE; frameRect: GPRECT; frameUnit: METAFILEFRAMEUNIT;
    description: PWCHAR; out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipRecordMetafileStream(stream: ISTREAM; referenceHdc: HDC;
    type_: EMFTYPE; frameRect: GPRECTF; frameUnit: METAFILEFRAMEUNIT;
    description: PWCHAR; out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipRecordMetafileStreamI(stream: ISTREAM; referenceHdc: HDC;
    type_: EMFTYPE; frameRect: GPRECT; frameUnit: METAFILEFRAMEUNIT;
    description: PWCHAR; out metafile: GPMETAFILE): GPSTATUS; stdcall;

  function GdipSetMetafileDownLevelRasterizationLimit(metafile: GPMETAFILE;
    metafileRasterizationLimitDpi: UINT): GPSTATUS; stdcall;

  function GdipGetMetafileDownLevelRasterizationLimit(metafile: GPMETAFILE;
    var metafileRasterizationLimitDpi: UINT): GPSTATUS; stdcall;

  function GdipGetImageDecodersSize(out numDecoders: UINT;
    out size: UINT): GPSTATUS; stdcall;

  function GdipGetImageDecoders(numDecoders: UINT; size: UINT;
    decoders: PIMAGECODECINFO): GPSTATUS; stdcall;

  function GdipGetImageEncodersSize(out numEncoders: UINT;
    out size: UINT): GPSTATUS; stdcall;

  function GdipGetImageEncoders(numEncoders: UINT; size: UINT;
    encoders: PIMAGECODECINFO): GPSTATUS; stdcall;

  function GdipComment(graphics: GPGRAPHICS; sizeData: UINT;
    data: PBYTE): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// FontFamily APIs
//----------------------------------------------------------------------------

  function GdipCreateFontFamilyFromName(name: PWCHAR;
    fontCollection: GPFONTCOLLECTION;
    out FontFamily: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipDeleteFontFamily(FontFamily: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipCloneFontFamily(FontFamily: GPFONTFAMILY;
    out clonedFontFamily: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipGetGenericFontFamilySansSerif(
    out nativeFamily: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipGetGenericFontFamilySerif(
    out nativeFamily: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipGetGenericFontFamilyMonospace(
    out nativeFamily: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipGetFamilyName(family: GPFONTFAMILY; name: PWideChar;
    language: LANGID): GPSTATUS; stdcall;

  function GdipIsStyleAvailable(family: GPFONTFAMILY; style: Integer;
    var IsStyleAvailable: Bool): GPSTATUS; stdcall;

  function GdipFontCollectionEnumerable(fontCollection: GPFONTCOLLECTION;
    graphics: GPGRAPHICS; var numFound: Integer): GPSTATUS; stdcall;

  function GdipFontCollectionEnumerate(fontCollection: GPFONTCOLLECTION;
    numSought: Integer; gpfamilies: array of GPFONTFAMILY;
    var numFound: Integer; graphics: GPGRAPHICS): GPSTATUS; stdcall;

  function GdipGetEmHeight(family: GPFONTFAMILY; style: Integer;
    out EmHeight: UINT16): GPSTATUS; stdcall;

  function GdipGetCellAscent(family: GPFONTFAMILY; style: Integer;
    var CellAscent: UINT16): GPSTATUS; stdcall;

  function GdipGetCellDescent(family: GPFONTFAMILY; style: Integer;
    var CellDescent: UINT16): GPSTATUS; stdcall;

  function GdipGetLineSpacing(family: GPFONTFAMILY; style: Integer;
    var LineSpacing: UINT16): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Font APIs
//----------------------------------------------------------------------------

  function GdipCreateFontFromDC(hdc: HDC; out font: GPFONT): GPSTATUS; stdcall;

  function GdipCreateFontFromLogfontA(hdc: HDC; logfont: PLOGFONTA;
    out font: GPFONT): GPSTATUS; stdcall;

  function GdipCreateFontFromLogfontW(hdc: HDC; logfont: PLOGFONTW;
    out font: GPFONT): GPSTATUS; stdcall;

  function GdipCreateFont(fontFamily: GPFONTFAMILY; emSize: Single;
    style: Integer; unit_: Integer; out font: GPFONT): GPSTATUS; stdcall;

  function GdipCloneFont(font: GPFONT;
    out cloneFont: GPFONT): GPSTATUS; stdcall;

  function GdipDeleteFont(font: GPFONT): GPSTATUS; stdcall;

  function GdipGetFamily(font: GPFONT;
    out family: GPFONTFAMILY): GPSTATUS; stdcall;

  function GdipGetFontStyle(font: GPFONT;
    var style: Integer): GPSTATUS; stdcall;

  function GdipGetFontSize(font: GPFONT; var size: Single): GPSTATUS; stdcall;

  function GdipGetFontUnit(font: GPFONT; var unit_: TUNIT): GPSTATUS; stdcall;

  function GdipGetFontHeight(font: GPFONT; graphics: GPGRAPHICS;
    var height: Single): GPSTATUS; stdcall;

  function GdipGetFontHeightGivenDPI(font: GPFONT; dpi: Single;
    var height: Single): GPSTATUS; stdcall;

  function GdipGetLogFontA(font: GPFONT; graphics: GPGRAPHICS;
    var logfontA: LOGFONTA): GPSTATUS; stdcall;

  function GdipGetLogFontW(font: GPFONT; graphics: GPGRAPHICS;
    var logfontW: LOGFONTW): GPSTATUS; stdcall;

  function GdipNewInstalledFontCollection(
    out fontCollection: GPFONTCOLLECTION): GPSTATUS; stdcall;

  function GdipNewPrivateFontCollection(
    out fontCollection: GPFONTCOLLECTION): GPSTATUS; stdcall;

  function GdipDeletePrivateFontCollection(
    out fontCollection: GPFONTCOLLECTION): GPSTATUS; stdcall;

  function GdipGetFontCollectionFamilyCount(fontCollection: GPFONTCOLLECTION;
    var numFound: Integer): GPSTATUS; stdcall;

  function GdipGetFontCollectionFamilyList(fontCollection: GPFONTCOLLECTION;
    numSought: Integer; gpfamilies: GPFONTFAMILY;
    var numFound: Integer): GPSTATUS; stdcall;

  function GdipPrivateAddFontFile(fontCollection: GPFONTCOLLECTION;
    filename: PWCHAR): GPSTATUS; stdcall;

  function GdipPrivateAddMemoryFont(fontCollection: GPFONTCOLLECTION;
    memory: Pointer; length: Integer): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Text APIs
//----------------------------------------------------------------------------

  function GdipDrawString(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; brush: GPBRUSH): GPSTATUS; stdcall;

  function GdipMeasureString(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; boundingBox: PGPRectF;
    codepointsFitted: PInteger; linesFilled: PInteger): GPSTATUS; stdcall;

  function GdipMeasureCharacterRanges(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; regionCount: Integer;
    const regions: GPREGION): GPSTATUS; stdcall;

  function GdipDrawDriverString(graphics: GPGRAPHICS; const text: PUINT16;
    length: Integer; const font: GPFONT; const brush: GPBRUSH;
    const positions: PGPPointF; flags: Integer;
    const matrix: GPMATRIX): GPSTATUS; stdcall;

  function GdipMeasureDriverString(graphics: GPGRAPHICS; text: PUINT16;
    length: Integer; font: GPFONT; positions: PGPPointF; flags: Integer;
    matrix: GPMATRIX; boundingBox: PGPRectF): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// String format APIs
//----------------------------------------------------------------------------

  function GdipCreateStringFormat(formatAttributes: Integer; language: LANGID;
    out format: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipStringFormatGetGenericDefault(
    out format: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipStringFormatGetGenericTypographic(
    out format: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipDeleteStringFormat(format: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipCloneStringFormat(format: GPSTRINGFORMAT;
    out newFormat: GPSTRINGFORMAT): GPSTATUS; stdcall;

  function GdipSetStringFormatFlags(format: GPSTRINGFORMAT;
    flags: Integer): GPSTATUS; stdcall;

  function GdipGetStringFormatFlags(format: GPSTRINGFORMAT;
    out flags: Integer): GPSTATUS; stdcall;

  function GdipSetStringFormatAlign(format: GPSTRINGFORMAT;
    align: STRINGALIGNMENT): GPSTATUS; stdcall;

  function GdipGetStringFormatAlign(format: GPSTRINGFORMAT;
    out align: STRINGALIGNMENT): GPSTATUS; stdcall;

  function GdipSetStringFormatLineAlign(format: GPSTRINGFORMAT;
    align: STRINGALIGNMENT): GPSTATUS; stdcall;

  function GdipGetStringFormatLineAlign(format: GPSTRINGFORMAT;
    out align: STRINGALIGNMENT): GPSTATUS; stdcall;

  function GdipSetStringFormatTrimming(format: GPSTRINGFORMAT;
    trimming: STRINGTRIMMING): GPSTATUS; stdcall;

  function GdipGetStringFormatTrimming(format: GPSTRINGFORMAT;
    out trimming: STRINGTRIMMING): GPSTATUS; stdcall;

  function GdipSetStringFormatHotkeyPrefix(format: GPSTRINGFORMAT;
    hotkeyPrefix: Integer): GPSTATUS; stdcall;

  function GdipGetStringFormatHotkeyPrefix(format: GPSTRINGFORMAT;
    out hotkeyPrefix: Integer): GPSTATUS; stdcall;

  function GdipSetStringFormatTabStops(format: GPSTRINGFORMAT;
    firstTabOffset: Single; count: Integer;
    tabStops: PSingle): GPSTATUS; stdcall;

  function GdipGetStringFormatTabStops(format: GPSTRINGFORMAT;
    count: Integer; firstTabOffset: PSingle;
    tabStops: PSingle): GPSTATUS; stdcall;

  function GdipGetStringFormatTabStopCount(format: GPSTRINGFORMAT;
    out count: Integer): GPSTATUS; stdcall;

  function GdipSetStringFormatDigitSubstitution(format: GPSTRINGFORMAT;
    language: LANGID;
    substitute: STRINGDIGITSUBSTITUTE): GPSTATUS; stdcall;

  function GdipGetStringFormatDigitSubstitution(format: GPSTRINGFORMAT;
    language: PUINT; substitute: PSTRINGDIGITSUBSTITUTE): GPSTATUS; stdcall;

  function GdipGetStringFormatMeasurableCharacterRangeCount(format: GPSTRINGFORMAT;
    out count: Integer): GPSTATUS; stdcall;

  function GdipSetStringFormatMeasurableCharacterRanges(format: GPSTRINGFORMAT;
    rangeCount: Integer; ranges: PCHARACTERRANGE): GPSTATUS; stdcall;

//----------------------------------------------------------------------------
// Cached Bitmap APIs
//----------------------------------------------------------------------------

  function GdipCreateCachedBitmap(bitmap: GPBITMAP; graphics: GPGRAPHICS;
    out cachedBitmap: GPCACHEDBITMAP): GPSTATUS; stdcall;

  function GdipDeleteCachedBitmap(
    cachedBitmap: GPCACHEDBITMAP): GPSTATUS; stdcall;

  function GdipDrawCachedBitmap(graphics: GPGRAPHICS;
    cachedBitmap: GPCACHEDBITMAP; x: Integer;
    y: Integer): GPSTATUS; stdcall;

  function GdipEmfToWmfBits(hemf: HENHMETAFILE; cbData16: UINT; pData16: PBYTE;
    iMapMode: Integer; eFlags: Integer): UINT; stdcall;

implementation

function GdipAlloc; external WINGDIPDLL name 'GdipAlloc' delayed;
procedure GdipFree; external WINGDIPDLL name 'GdipFree' delayed;
function GdiplusStartup; external WINGDIPDLL name 'GdiplusStartup' delayed;
procedure GdiplusShutdown; external WINGDIPDLL name 'GdiplusShutdown' delayed;

function GdipCreatePath; external WINGDIPDLL name 'GdipCreatePath' delayed;
function GdipCreatePath2; external WINGDIPDLL name 'GdipCreatePath2' delayed;
function GdipCreatePath2I; external WINGDIPDLL name 'GdipCreatePath2I' delayed;
function GdipClonePath; external WINGDIPDLL name 'GdipClonePath' delayed;
function GdipDeletePath; external WINGDIPDLL name 'GdipDeletePath' delayed;
function GdipResetPath; external WINGDIPDLL name 'GdipResetPath' delayed;
function GdipGetPointCount; external WINGDIPDLL name 'GdipGetPointCount' delayed;
function GdipGetPathTypes; external WINGDIPDLL name 'GdipGetPathTypes' delayed;
function GdipGetPathPoints; external WINGDIPDLL name 'GdipGetPathPoints' delayed;
function GdipGetPathPointsI; external WINGDIPDLL name 'GdipGetPathPointsI' delayed;
function GdipGetPathFillMode; external WINGDIPDLL name 'GdipGetPathFillMode' delayed;
function GdipSetPathFillMode; external WINGDIPDLL name 'GdipSetPathFillMode' delayed;
function GdipGetPathData; external WINGDIPDLL name 'GdipGetPathData' delayed;
function GdipStartPathFigure; external WINGDIPDLL name 'GdipStartPathFigure' delayed;
function GdipClosePathFigure; external WINGDIPDLL name 'GdipClosePathFigure' delayed;
function GdipClosePathFigures; external WINGDIPDLL name 'GdipClosePathFigures' delayed;
function GdipSetPathMarker; external WINGDIPDLL name 'GdipSetPathMarker' delayed;
function GdipClearPathMarkers; external WINGDIPDLL name 'GdipClearPathMarkers' delayed;
function GdipReversePath; external WINGDIPDLL name 'GdipReversePath' delayed;
function GdipGetPathLastPoint; external WINGDIPDLL name 'GdipGetPathLastPoint' delayed;
function GdipAddPathLine; external WINGDIPDLL name 'GdipAddPathLine' delayed;
function GdipAddPathLine2; external WINGDIPDLL name 'GdipAddPathLine2' delayed;
function GdipAddPathArc; external WINGDIPDLL name 'GdipAddPathArc' delayed;
function GdipAddPathBezier; external WINGDIPDLL name 'GdipAddPathBezier' delayed;
function GdipAddPathBeziers; external WINGDIPDLL name 'GdipAddPathBeziers' delayed;
function GdipAddPathCurve; external WINGDIPDLL name 'GdipAddPathCurve' delayed;
function GdipAddPathCurve2; external WINGDIPDLL name 'GdipAddPathCurve2' delayed;
function GdipAddPathCurve3; external WINGDIPDLL name 'GdipAddPathCurve3' delayed;
function GdipAddPathClosedCurve; external WINGDIPDLL name 'GdipAddPathClosedCurve' delayed;
function GdipAddPathClosedCurve2; external WINGDIPDLL name 'GdipAddPathClosedCurve2' delayed;
function GdipAddPathRectangle; external WINGDIPDLL name 'GdipAddPathRectangle' delayed;
function GdipAddPathRectangles; external WINGDIPDLL name 'GdipAddPathRectangles' delayed;
function GdipAddPathEllipse; external WINGDIPDLL name 'GdipAddPathEllipse' delayed;
function GdipAddPathPie; external WINGDIPDLL name 'GdipAddPathPie' delayed;
function GdipAddPathPolygon; external WINGDIPDLL name 'GdipAddPathPolygon' delayed;
function GdipAddPathPath; external WINGDIPDLL name 'GdipAddPathPath' delayed;
function GdipAddPathString; external WINGDIPDLL name 'GdipAddPathString' delayed;
function GdipAddPathStringI; external WINGDIPDLL name 'GdipAddPathStringI' delayed;
function GdipAddPathLineI; external WINGDIPDLL name 'GdipAddPathLineI' delayed;
function GdipAddPathLine2I; external WINGDIPDLL name 'GdipAddPathLine2I' delayed;
function GdipAddPathArcI; external WINGDIPDLL name 'GdipAddPathArcI' delayed;
function GdipAddPathBezierI; external WINGDIPDLL name 'GdipAddPathBezierI' delayed;
function GdipAddPathBeziersI; external WINGDIPDLL name 'GdipAddPathBeziersI' delayed;
function GdipAddPathCurveI; external WINGDIPDLL name 'GdipAddPathCurveI' delayed;
function GdipAddPathCurve2I; external WINGDIPDLL name 'GdipAddPathCurve2I' delayed;
function GdipAddPathCurve3I; external WINGDIPDLL name 'GdipAddPathCurve3I' delayed;
function GdipAddPathClosedCurveI; external WINGDIPDLL name 'GdipAddPathClosedCurveI' delayed;
function GdipAddPathClosedCurve2I; external WINGDIPDLL name 'GdipAddPathClosedCurve2I' delayed;
function GdipAddPathRectangleI; external WINGDIPDLL name 'GdipAddPathRectangleI' delayed;
function GdipAddPathRectanglesI; external WINGDIPDLL name 'GdipAddPathRectanglesI' delayed;
function GdipAddPathEllipseI; external WINGDIPDLL name 'GdipAddPathEllipseI' delayed;
function GdipAddPathPieI; external WINGDIPDLL name 'GdipAddPathPieI' delayed;
function GdipAddPathPolygonI; external WINGDIPDLL name 'GdipAddPathPolygonI' delayed;
function GdipFlattenPath; external WINGDIPDLL name 'GdipFlattenPath' delayed;
function GdipWindingModeOutline; external WINGDIPDLL name 'GdipWindingModeOutline' delayed;
function GdipWidenPath; external WINGDIPDLL name 'GdipWidenPath' delayed;
function GdipWarpPath; external WINGDIPDLL name 'GdipWarpPath' delayed;
function GdipTransformPath; external WINGDIPDLL name 'GdipTransformPath' delayed;
function GdipGetPathWorldBounds; external WINGDIPDLL name 'GdipGetPathWorldBounds' delayed;
function GdipGetPathWorldBoundsI; external WINGDIPDLL name 'GdipGetPathWorldBoundsI' delayed;
function GdipIsVisiblePathPoint; external WINGDIPDLL name 'GdipIsVisiblePathPoint' delayed;
function GdipIsVisiblePathPointI; external WINGDIPDLL name 'GdipIsVisiblePathPointI' delayed;
function GdipIsOutlineVisiblePathPoint; external WINGDIPDLL name 'GdipIsOutlineVisiblePathPoint' delayed;
function GdipIsOutlineVisiblePathPointI; external WINGDIPDLL name 'GdipIsOutlineVisiblePathPointI' delayed;
function GdipCreatePathIter; external WINGDIPDLL name 'GdipCreatePathIter' delayed;
function GdipDeletePathIter; external WINGDIPDLL name 'GdipDeletePathIter' delayed;
function GdipPathIterNextSubpath; external WINGDIPDLL name 'GdipPathIterNextSubpath' delayed;
function GdipPathIterNextSubpathPath; external WINGDIPDLL name 'GdipPathIterNextSubpathPath' delayed;
function GdipPathIterNextPathType; external WINGDIPDLL name 'GdipPathIterNextPathType' delayed;
function GdipPathIterNextMarker; external WINGDIPDLL name 'GdipPathIterNextMarker' delayed;
function GdipPathIterNextMarkerPath; external WINGDIPDLL name 'GdipPathIterNextMarkerPath' delayed;
function GdipPathIterGetCount; external WINGDIPDLL name 'GdipPathIterGetCount' delayed;
function GdipPathIterGetSubpathCount; external WINGDIPDLL name 'GdipPathIterGetSubpathCount' delayed;
function GdipPathIterIsValid; external WINGDIPDLL name 'GdipPathIterIsValid' delayed;
function GdipPathIterHasCurve; external WINGDIPDLL name 'GdipPathIterHasCurve' delayed;
function GdipPathIterRewind; external WINGDIPDLL name 'GdipPathIterRewind' delayed;
function GdipPathIterEnumerate; external WINGDIPDLL name 'GdipPathIterEnumerate' delayed;
function GdipPathIterCopyData; external WINGDIPDLL name 'GdipPathIterCopyData' delayed;
function GdipCreateMatrix; external WINGDIPDLL name 'GdipCreateMatrix' delayed;
function GdipCreateMatrix2; external WINGDIPDLL name 'GdipCreateMatrix2' delayed;
function GdipCreateMatrix3; external WINGDIPDLL name 'GdipCreateMatrix3' delayed;
function GdipCreateMatrix3I; external WINGDIPDLL name 'GdipCreateMatrix3I' delayed;
function GdipCloneMatrix; external WINGDIPDLL name 'GdipCloneMatrix' delayed;
function GdipDeleteMatrix; external WINGDIPDLL name 'GdipDeleteMatrix' delayed;
function GdipSetMatrixElements; external WINGDIPDLL name 'GdipSetMatrixElements' delayed;
function GdipMultiplyMatrix; external WINGDIPDLL name 'GdipMultiplyMatrix' delayed;
function GdipTranslateMatrix; external WINGDIPDLL name 'GdipTranslateMatrix' delayed;
function GdipScaleMatrix; external WINGDIPDLL name 'GdipScaleMatrix' delayed;
function GdipRotateMatrix; external WINGDIPDLL name 'GdipRotateMatrix' delayed;
function GdipShearMatrix; external WINGDIPDLL name 'GdipShearMatrix' delayed;
function GdipInvertMatrix; external WINGDIPDLL name 'GdipInvertMatrix' delayed;
function GdipTransformMatrixPoints; external WINGDIPDLL name 'GdipTransformMatrixPoints' delayed;
function GdipTransformMatrixPointsI; external WINGDIPDLL name 'GdipTransformMatrixPointsI' delayed;
function GdipVectorTransformMatrixPoints; external WINGDIPDLL name 'GdipVectorTransformMatrixPoints' delayed;
function GdipVectorTransformMatrixPointsI; external WINGDIPDLL name 'GdipVectorTransformMatrixPointsI' delayed;
function GdipGetMatrixElements; external WINGDIPDLL name 'GdipGetMatrixElements' delayed;
function GdipIsMatrixInvertible; external WINGDIPDLL name 'GdipIsMatrixInvertible' delayed;
function GdipIsMatrixIdentity; external WINGDIPDLL name 'GdipIsMatrixIdentity' delayed;
function GdipIsMatrixEqual; external WINGDIPDLL name 'GdipIsMatrixEqual' delayed;
function GdipCreateRegion; external WINGDIPDLL name 'GdipCreateRegion' delayed;
function GdipCreateRegionRect; external WINGDIPDLL name 'GdipCreateRegionRect' delayed;
function GdipCreateRegionRectI; external WINGDIPDLL name 'GdipCreateRegionRectI' delayed;
function GdipCreateRegionPath; external WINGDIPDLL name 'GdipCreateRegionPath' delayed;
function GdipCreateRegionRgnData; external WINGDIPDLL name 'GdipCreateRegionRgnData' delayed;
function GdipCreateRegionHrgn; external WINGDIPDLL name 'GdipCreateRegionHrgn' delayed;
function GdipCloneRegion; external WINGDIPDLL name 'GdipCloneRegion' delayed;
function GdipDeleteRegion; external WINGDIPDLL name 'GdipDeleteRegion' delayed;
function GdipSetInfinite; external WINGDIPDLL name 'GdipSetInfinite' delayed;
function GdipSetEmpty; external WINGDIPDLL name 'GdipSetEmpty' delayed;
function GdipCombineRegionRect; external WINGDIPDLL name 'GdipCombineRegionRect' delayed;
function GdipCombineRegionRectI; external WINGDIPDLL name 'GdipCombineRegionRectI' delayed;
function GdipCombineRegionPath; external WINGDIPDLL name 'GdipCombineRegionPath' delayed;
function GdipCombineRegionRegion; external WINGDIPDLL name 'GdipCombineRegionRegion' delayed;
function GdipTranslateRegion; external WINGDIPDLL name 'GdipTranslateRegion' delayed;
function GdipTranslateRegionI; external WINGDIPDLL name 'GdipTranslateRegionI' delayed;
function GdipTransformRegion; external WINGDIPDLL name 'GdipTransformRegion' delayed;
function GdipGetRegionBounds; external WINGDIPDLL name 'GdipGetRegionBounds' delayed;
function GdipGetRegionBoundsI; external WINGDIPDLL name 'GdipGetRegionBoundsI' delayed;
function GdipGetRegionHRgn; external WINGDIPDLL name 'GdipGetRegionHRgn' delayed;
function GdipIsEmptyRegion; external WINGDIPDLL name 'GdipIsEmptyRegion' delayed;
function GdipIsInfiniteRegion; external WINGDIPDLL name 'GdipIsInfiniteRegion' delayed;
function GdipIsEqualRegion; external WINGDIPDLL name 'GdipIsEqualRegion' delayed;
function GdipGetRegionDataSize; external WINGDIPDLL name 'GdipGetRegionDataSize' delayed;
function GdipGetRegionData; external WINGDIPDLL name 'GdipGetRegionData' delayed;
function GdipIsVisibleRegionPoint; external WINGDIPDLL name 'GdipIsVisibleRegionPoint' delayed;
function GdipIsVisibleRegionPointI; external WINGDIPDLL name 'GdipIsVisibleRegionPointI' delayed;
function GdipIsVisibleRegionRect; external WINGDIPDLL name 'GdipIsVisibleRegionRect' delayed;
function GdipIsVisibleRegionRectI; external WINGDIPDLL name 'GdipIsVisibleRegionRectI' delayed;
function GdipGetRegionScansCount; external WINGDIPDLL name 'GdipGetRegionScansCount' delayed;
function GdipGetRegionScans; external WINGDIPDLL name 'GdipGetRegionScans' delayed;
function GdipGetRegionScansI; external WINGDIPDLL name 'GdipGetRegionScansI' delayed;
function GdipCloneBrush; external WINGDIPDLL name 'GdipCloneBrush' delayed;
function GdipDeleteBrush; external WINGDIPDLL name 'GdipDeleteBrush' delayed;
function GdipGetBrushType; external WINGDIPDLL name 'GdipGetBrushType' delayed;
function GdipCreateHatchBrush; external WINGDIPDLL name 'GdipCreateHatchBrush' delayed;
function GdipGetHatchStyle; external WINGDIPDLL name 'GdipGetHatchStyle' delayed;
function GdipGetHatchForegroundColor; external WINGDIPDLL name 'GdipGetHatchForegroundColor' delayed;
function GdipGetHatchBackgroundColor; external WINGDIPDLL name 'GdipGetHatchBackgroundColor' delayed;
function GdipCreateTexture; external WINGDIPDLL name 'GdipCreateTexture' delayed;
function GdipCreateTexture2; external WINGDIPDLL name 'GdipCreateTexture2' delayed;
function GdipCreateTextureIA; external WINGDIPDLL name 'GdipCreateTextureIA' delayed;
function GdipCreateTexture2I; external WINGDIPDLL name 'GdipCreateTexture2I' delayed;
function GdipCreateTextureIAI; external WINGDIPDLL name 'GdipCreateTextureIAI' delayed;
function GdipGetTextureTransform; external WINGDIPDLL name 'GdipGetTextureTransform' delayed;
function GdipSetTextureTransform; external WINGDIPDLL name 'GdipSetTextureTransform' delayed;
function GdipResetTextureTransform; external WINGDIPDLL name 'GdipResetTextureTransform' delayed;
function GdipMultiplyTextureTransform; external WINGDIPDLL name 'GdipMultiplyTextureTransform' delayed;
function GdipTranslateTextureTransform; external WINGDIPDLL name 'GdipTranslateTextureTransform' delayed;
function GdipScaleTextureTransform; external WINGDIPDLL name 'GdipScaleTextureTransform' delayed;
function GdipRotateTextureTransform; external WINGDIPDLL name 'GdipRotateTextureTransform' delayed;
function GdipSetTextureWrapMode; external WINGDIPDLL name 'GdipSetTextureWrapMode' delayed;
function GdipGetTextureWrapMode; external WINGDIPDLL name 'GdipGetTextureWrapMode' delayed;
function GdipGetTextureImage; external WINGDIPDLL name 'GdipGetTextureImage' delayed;
function GdipCreateSolidFill; external WINGDIPDLL name 'GdipCreateSolidFill' delayed;
function GdipSetSolidFillColor; external WINGDIPDLL name 'GdipSetSolidFillColor' delayed;
function GdipGetSolidFillColor; external WINGDIPDLL name 'GdipGetSolidFillColor' delayed;
function GdipCreateLineBrush; external WINGDIPDLL name 'GdipCreateLineBrush' delayed;
function GdipCreateLineBrushI; external WINGDIPDLL name 'GdipCreateLineBrushI' delayed;
function GdipCreateLineBrushFromRect; external WINGDIPDLL name 'GdipCreateLineBrushFromRect' delayed;
function GdipCreateLineBrushFromRectI; external WINGDIPDLL name 'GdipCreateLineBrushFromRectI' delayed;
function GdipCreateLineBrushFromRectWithAngle; external WINGDIPDLL name 'GdipCreateLineBrushFromRectWithAngle' delayed;
function GdipCreateLineBrushFromRectWithAngleI; external WINGDIPDLL name 'GdipCreateLineBrushFromRectWithAngleI' delayed;
function GdipSetLineColors; external WINGDIPDLL name 'GdipSetLineColors' delayed;
function GdipGetLineColors; external WINGDIPDLL name 'GdipGetLineColors' delayed;
function GdipGetLineRect; external WINGDIPDLL name 'GdipGetLineRect' delayed;
function GdipGetLineRectI; external WINGDIPDLL name 'GdipGetLineRectI' delayed;
function GdipSetLineGammaCorrection; external WINGDIPDLL name 'GdipSetLineGammaCorrection' delayed;
function GdipGetLineGammaCorrection; external WINGDIPDLL name 'GdipGetLineGammaCorrection' delayed;
function GdipGetLineBlendCount; external WINGDIPDLL name 'GdipGetLineBlendCount' delayed;
function GdipGetLineBlend; external WINGDIPDLL name 'GdipGetLineBlend' delayed;
function GdipSetLineBlend; external WINGDIPDLL name 'GdipSetLineBlend' delayed;
function GdipGetLinePresetBlendCount; external WINGDIPDLL name 'GdipGetLinePresetBlendCount' delayed;
function GdipGetLinePresetBlend; external WINGDIPDLL name 'GdipGetLinePresetBlend' delayed;
function GdipSetLinePresetBlend; external WINGDIPDLL name 'GdipSetLinePresetBlend' delayed;
function GdipSetLineSigmaBlend; external WINGDIPDLL name 'GdipSetLineSigmaBlend' delayed;
function GdipSetLineLinearBlend; external WINGDIPDLL name 'GdipSetLineLinearBlend' delayed;
function GdipSetLineWrapMode; external WINGDIPDLL name 'GdipSetLineWrapMode' delayed;
function GdipGetLineWrapMode; external WINGDIPDLL name 'GdipGetLineWrapMode' delayed;
function GdipGetLineTransform; external WINGDIPDLL name 'GdipGetLineTransform' delayed;
function GdipSetLineTransform; external WINGDIPDLL name 'GdipSetLineTransform' delayed;
function GdipResetLineTransform; external WINGDIPDLL name 'GdipResetLineTransform' delayed;
function GdipMultiplyLineTransform; external WINGDIPDLL name 'GdipMultiplyLineTransform' delayed;
function GdipTranslateLineTransform; external WINGDIPDLL name 'GdipTranslateLineTransform' delayed;
function GdipScaleLineTransform; external WINGDIPDLL name 'GdipScaleLineTransform' delayed;
function GdipRotateLineTransform; external WINGDIPDLL name 'GdipRotateLineTransform' delayed;
function GdipCreatePathGradient; external WINGDIPDLL name 'GdipCreatePathGradient' delayed;
function GdipCreatePathGradientI; external WINGDIPDLL name 'GdipCreatePathGradientI' delayed;
function GdipCreatePathGradientFromPath; external WINGDIPDLL name 'GdipCreatePathGradientFromPath' delayed;
function GdipGetPathGradientCenterColor; external WINGDIPDLL name 'GdipGetPathGradientCenterColor' delayed;
function GdipSetPathGradientCenterColor; external WINGDIPDLL name 'GdipSetPathGradientCenterColor' delayed;
function GdipGetPathGradientSurroundColorsWithCount; external WINGDIPDLL name 'GdipGetPathGradientSurroundColorsWithCount' delayed;
function GdipSetPathGradientSurroundColorsWithCount; external WINGDIPDLL name 'GdipSetPathGradientSurroundColorsWithCount' delayed;
function GdipGetPathGradientPath; external WINGDIPDLL name 'GdipGetPathGradientPath' delayed;
function GdipSetPathGradientPath; external WINGDIPDLL name 'GdipSetPathGradientPath' delayed;
function GdipGetPathGradientCenterPoint; external WINGDIPDLL name 'GdipGetPathGradientCenterPoint' delayed;
function GdipGetPathGradientCenterPointI; external WINGDIPDLL name 'GdipGetPathGradientCenterPointI' delayed;
function GdipSetPathGradientCenterPoint; external WINGDIPDLL name 'GdipSetPathGradientCenterPoint' delayed;
function GdipSetPathGradientCenterPointI; external WINGDIPDLL name 'GdipSetPathGradientCenterPointI' delayed;
function GdipGetPathGradientRect; external WINGDIPDLL name 'GdipGetPathGradientRect' delayed;
function GdipGetPathGradientRectI; external WINGDIPDLL name 'GdipGetPathGradientRectI' delayed;
function GdipGetPathGradientPointCount; external WINGDIPDLL name 'GdipGetPathGradientPointCount' delayed;
function GdipGetPathGradientSurroundColorCount; external WINGDIPDLL name 'GdipGetPathGradientSurroundColorCount' delayed;
function GdipSetPathGradientGammaCorrection; external WINGDIPDLL name 'GdipSetPathGradientGammaCorrection' delayed;
function GdipGetPathGradientGammaCorrection; external WINGDIPDLL name 'GdipGetPathGradientGammaCorrection' delayed;
function GdipGetPathGradientBlendCount; external WINGDIPDLL name 'GdipGetPathGradientBlendCount' delayed;
function GdipGetPathGradientBlend; external WINGDIPDLL name 'GdipGetPathGradientBlend' delayed;
function GdipSetPathGradientBlend; external WINGDIPDLL name 'GdipSetPathGradientBlend' delayed;
function GdipGetPathGradientPresetBlendCount; external WINGDIPDLL name 'GdipGetPathGradientPresetBlendCount' delayed;
function GdipGetPathGradientPresetBlend; external WINGDIPDLL name 'GdipGetPathGradientPresetBlend' delayed;
function GdipSetPathGradientPresetBlend; external WINGDIPDLL name 'GdipSetPathGradientPresetBlend' delayed;
function GdipSetPathGradientSigmaBlend; external WINGDIPDLL name 'GdipSetPathGradientSigmaBlend' delayed;
function GdipSetPathGradientLinearBlend; external WINGDIPDLL name 'GdipSetPathGradientLinearBlend' delayed;
function GdipGetPathGradientWrapMode; external WINGDIPDLL name 'GdipGetPathGradientWrapMode' delayed;
function GdipSetPathGradientWrapMode; external WINGDIPDLL name 'GdipSetPathGradientWrapMode' delayed;
function GdipGetPathGradientTransform; external WINGDIPDLL name 'GdipGetPathGradientTransform' delayed;
function GdipSetPathGradientTransform; external WINGDIPDLL name 'GdipSetPathGradientTransform' delayed;
function GdipResetPathGradientTransform; external WINGDIPDLL name 'GdipResetPathGradientTransform' delayed;
function GdipMultiplyPathGradientTransform; external WINGDIPDLL name 'GdipMultiplyPathGradientTransform' delayed;
function GdipTranslatePathGradientTransform; external WINGDIPDLL name 'GdipTranslatePathGradientTransform' delayed;
function GdipScalePathGradientTransform; external WINGDIPDLL name 'GdipScalePathGradientTransform' delayed;
function GdipRotatePathGradientTransform; external WINGDIPDLL name 'GdipRotatePathGradientTransform' delayed;
function GdipGetPathGradientFocusScales; external WINGDIPDLL name 'GdipGetPathGradientFocusScales' delayed;
function GdipSetPathGradientFocusScales; external WINGDIPDLL name 'GdipSetPathGradientFocusScales' delayed;
function GdipCreatePen1; external WINGDIPDLL name 'GdipCreatePen1' delayed;
function GdipCreatePen2; external WINGDIPDLL name 'GdipCreatePen2' delayed;
function GdipClonePen; external WINGDIPDLL name 'GdipClonePen' delayed;
function GdipDeletePen; external WINGDIPDLL name 'GdipDeletePen' delayed;
function GdipSetPenWidth; external WINGDIPDLL name 'GdipSetPenWidth' delayed;
function GdipGetPenWidth; external WINGDIPDLL name 'GdipGetPenWidth' delayed;
function GdipSetPenUnit; external WINGDIPDLL name 'GdipSetPenUnit' delayed;
function GdipGetPenUnit; external WINGDIPDLL name 'GdipGetPenUnit' delayed;
function GdipSetPenLineCap197819; external WINGDIPDLL name 'GdipSetPenLineCap197819' delayed;
function GdipSetPenStartCap; external WINGDIPDLL name 'GdipSetPenStartCap' delayed;
function GdipSetPenEndCap; external WINGDIPDLL name 'GdipSetPenEndCap' delayed;
function GdipSetPenDashCap197819; external WINGDIPDLL name 'GdipSetPenDashCap197819' delayed;
function GdipGetPenStartCap; external WINGDIPDLL name 'GdipGetPenStartCap' delayed;
function GdipGetPenEndCap; external WINGDIPDLL name 'GdipGetPenEndCap' delayed;
function GdipGetPenDashCap197819; external WINGDIPDLL name 'GdipGetPenDashCap197819' delayed;
function GdipSetPenLineJoin; external WINGDIPDLL name 'GdipSetPenLineJoin' delayed;
function GdipGetPenLineJoin; external WINGDIPDLL name 'GdipGetPenLineJoin' delayed;
function GdipSetPenCustomStartCap; external WINGDIPDLL name 'GdipSetPenCustomStartCap' delayed;
function GdipGetPenCustomStartCap; external WINGDIPDLL name 'GdipGetPenCustomStartCap' delayed;
function GdipSetPenCustomEndCap; external WINGDIPDLL name 'GdipSetPenCustomEndCap' delayed;
function GdipGetPenCustomEndCap; external WINGDIPDLL name 'GdipGetPenCustomEndCap' delayed;
function GdipSetPenMiterLimit; external WINGDIPDLL name 'GdipSetPenMiterLimit' delayed;
function GdipGetPenMiterLimit; external WINGDIPDLL name 'GdipGetPenMiterLimit' delayed;
function GdipSetPenMode; external WINGDIPDLL name 'GdipSetPenMode' delayed;
function GdipGetPenMode; external WINGDIPDLL name 'GdipGetPenMode' delayed;
function GdipSetPenTransform; external WINGDIPDLL name 'GdipSetPenTransform' delayed;
function GdipGetPenTransform; external WINGDIPDLL name 'GdipGetPenTransform' delayed;
function GdipResetPenTransform; external WINGDIPDLL name 'GdipResetPenTransform' delayed;
function GdipMultiplyPenTransform; external WINGDIPDLL name 'GdipMultiplyPenTransform' delayed;
function GdipTranslatePenTransform; external WINGDIPDLL name 'GdipTranslatePenTransform' delayed;
function GdipScalePenTransform; external WINGDIPDLL name 'GdipScalePenTransform' delayed;
function GdipRotatePenTransform; external WINGDIPDLL name 'GdipRotatePenTransform' delayed;
function GdipSetPenColor; external WINGDIPDLL name 'GdipSetPenColor' delayed;
function GdipGetPenColor; external WINGDIPDLL name 'GdipGetPenColor' delayed;
function GdipSetPenBrushFill; external WINGDIPDLL name 'GdipSetPenBrushFill' delayed;
function GdipGetPenBrushFill; external WINGDIPDLL name 'GdipGetPenBrushFill' delayed;
function GdipGetPenFillType; external WINGDIPDLL name 'GdipGetPenFillType' delayed;
function GdipGetPenDashStyle; external WINGDIPDLL name 'GdipGetPenDashStyle' delayed;
function GdipSetPenDashStyle; external WINGDIPDLL name 'GdipSetPenDashStyle' delayed;
function GdipGetPenDashOffset; external WINGDIPDLL name 'GdipGetPenDashOffset' delayed;
function GdipSetPenDashOffset; external WINGDIPDLL name 'GdipSetPenDashOffset' delayed;
function GdipGetPenDashCount; external WINGDIPDLL name 'GdipGetPenDashCount' delayed;
function GdipSetPenDashArray; external WINGDIPDLL name 'GdipSetPenDashArray' delayed;
function GdipGetPenDashArray; external WINGDIPDLL name 'GdipGetPenDashArray' delayed;
function GdipGetPenCompoundCount; external WINGDIPDLL name 'GdipGetPenCompoundCount' delayed;
function GdipSetPenCompoundArray; external WINGDIPDLL name 'GdipSetPenCompoundArray' delayed;
function GdipGetPenCompoundArray; external WINGDIPDLL name 'GdipGetPenCompoundArray' delayed;
function GdipCreateCustomLineCap; external WINGDIPDLL name 'GdipCreateCustomLineCap' delayed;
function GdipDeleteCustomLineCap; external WINGDIPDLL name 'GdipDeleteCustomLineCap' delayed;
function GdipCloneCustomLineCap; external WINGDIPDLL name 'GdipCloneCustomLineCap' delayed;
function GdipGetCustomLineCapType; external WINGDIPDLL name 'GdipGetCustomLineCapType' delayed;
function GdipSetCustomLineCapStrokeCaps; external WINGDIPDLL name 'GdipSetCustomLineCapStrokeCaps' delayed;
function GdipGetCustomLineCapStrokeCaps; external WINGDIPDLL name 'GdipGetCustomLineCapStrokeCaps' delayed;
function GdipSetCustomLineCapStrokeJoin; external WINGDIPDLL name 'GdipSetCustomLineCapStrokeJoin' delayed;
function GdipGetCustomLineCapStrokeJoin; external WINGDIPDLL name 'GdipGetCustomLineCapStrokeJoin' delayed;
function GdipSetCustomLineCapBaseCap; external WINGDIPDLL name 'GdipSetCustomLineCapBaseCap' delayed;
function GdipGetCustomLineCapBaseCap; external WINGDIPDLL name 'GdipGetCustomLineCapBaseCap' delayed;
function GdipSetCustomLineCapBaseInset; external WINGDIPDLL name 'GdipSetCustomLineCapBaseInset' delayed;
function GdipGetCustomLineCapBaseInset; external WINGDIPDLL name 'GdipGetCustomLineCapBaseInset' delayed;
function GdipSetCustomLineCapWidthScale; external WINGDIPDLL name 'GdipSetCustomLineCapWidthScale' delayed;
function GdipGetCustomLineCapWidthScale; external WINGDIPDLL name 'GdipGetCustomLineCapWidthScale' delayed;
function GdipCreateAdjustableArrowCap; external WINGDIPDLL name 'GdipCreateAdjustableArrowCap' delayed;
function GdipSetAdjustableArrowCapHeight; external WINGDIPDLL name 'GdipSetAdjustableArrowCapHeight' delayed;
function GdipGetAdjustableArrowCapHeight; external WINGDIPDLL name 'GdipGetAdjustableArrowCapHeight' delayed;
function GdipSetAdjustableArrowCapWidth; external WINGDIPDLL name 'GdipSetAdjustableArrowCapWidth' delayed;
function GdipGetAdjustableArrowCapWidth; external WINGDIPDLL name 'GdipGetAdjustableArrowCapWidth' delayed;
function GdipSetAdjustableArrowCapMiddleInset; external WINGDIPDLL name 'GdipSetAdjustableArrowCapMiddleInset' delayed;
function GdipGetAdjustableArrowCapMiddleInset; external WINGDIPDLL name 'GdipGetAdjustableArrowCapMiddleInset' delayed;
function GdipSetAdjustableArrowCapFillState; external WINGDIPDLL name 'GdipSetAdjustableArrowCapFillState' delayed;
function GdipGetAdjustableArrowCapFillState; external WINGDIPDLL name 'GdipGetAdjustableArrowCapFillState' delayed;
function GdipLoadImageFromStream; external WINGDIPDLL name 'GdipLoadImageFromStream' delayed;
function GdipLoadImageFromFile; external WINGDIPDLL name 'GdipLoadImageFromFile' delayed;
function GdipLoadImageFromStreamICM; external WINGDIPDLL name 'GdipLoadImageFromStreamICM' delayed;
function GdipLoadImageFromFileICM; external WINGDIPDLL name 'GdipLoadImageFromFileICM' delayed;
function GdipCloneImage; external WINGDIPDLL name 'GdipCloneImage' delayed;
function GdipDisposeImage; external WINGDIPDLL name 'GdipDisposeImage' delayed;
function GdipSaveImageToFile; external WINGDIPDLL name 'GdipSaveImageToFile' delayed;
function GdipSaveImageToStream; external WINGDIPDLL name 'GdipSaveImageToStream' delayed;
function GdipSaveAdd; external WINGDIPDLL name 'GdipSaveAdd' delayed;
function GdipSaveAddImage; external WINGDIPDLL name 'GdipSaveAddImage' delayed;
function GdipGetImageGraphicsContext; external WINGDIPDLL name 'GdipGetImageGraphicsContext' delayed;
function GdipGetImageBounds; external WINGDIPDLL name 'GdipGetImageBounds' delayed;
function GdipGetImageDimension; external WINGDIPDLL name 'GdipGetImageDimension' delayed;
function GdipGetImageType; external WINGDIPDLL name 'GdipGetImageType' delayed;
function GdipGetImageWidth; external WINGDIPDLL name 'GdipGetImageWidth' delayed;
function GdipGetImageHeight; external WINGDIPDLL name 'GdipGetImageHeight' delayed;
function GdipGetImageHorizontalResolution; external WINGDIPDLL name 'GdipGetImageHorizontalResolution' delayed;
function GdipGetImageVerticalResolution; external WINGDIPDLL name 'GdipGetImageVerticalResolution' delayed;
function GdipGetImageFlags; external WINGDIPDLL name 'GdipGetImageFlags' delayed;
function GdipGetImageRawFormat; external WINGDIPDLL name 'GdipGetImageRawFormat' delayed;
function GdipGetImagePixelFormat; external WINGDIPDLL name 'GdipGetImagePixelFormat' delayed;
function GdipGetImageThumbnail; external WINGDIPDLL name 'GdipGetImageThumbnail' delayed;
function GdipGetEncoderParameterListSize; external WINGDIPDLL name 'GdipGetEncoderParameterListSize' delayed;
function GdipGetEncoderParameterList; external WINGDIPDLL name 'GdipGetEncoderParameterList' delayed;
function GdipImageGetFrameDimensionsCount; external WINGDIPDLL name 'GdipImageGetFrameDimensionsCount' delayed;
function GdipImageGetFrameDimensionsList; external WINGDIPDLL name 'GdipImageGetFrameDimensionsList' delayed;
function GdipImageGetFrameCount; external WINGDIPDLL name 'GdipImageGetFrameCount' delayed;
function GdipImageSelectActiveFrame; external WINGDIPDLL name 'GdipImageSelectActiveFrame' delayed;
function GdipImageRotateFlip; external WINGDIPDLL name 'GdipImageRotateFlip' delayed;
function GdipGetImagePalette; external WINGDIPDLL name 'GdipGetImagePalette' delayed;
function GdipSetImagePalette; external WINGDIPDLL name 'GdipSetImagePalette' delayed;
function GdipGetImagePaletteSize; external WINGDIPDLL name 'GdipGetImagePaletteSize' delayed;
function GdipGetPropertyCount; external WINGDIPDLL name 'GdipGetPropertyCount' delayed;
function GdipGetPropertyIdList; external WINGDIPDLL name 'GdipGetPropertyIdList' delayed;
function GdipGetPropertyItemSize; external WINGDIPDLL name 'GdipGetPropertyItemSize' delayed;
function GdipGetPropertyItem; external WINGDIPDLL name 'GdipGetPropertyItem' delayed;
function GdipGetPropertySize; external WINGDIPDLL name 'GdipGetPropertySize' delayed;
function GdipGetAllPropertyItems; external WINGDIPDLL name 'GdipGetAllPropertyItems' delayed;
function GdipRemovePropertyItem; external WINGDIPDLL name 'GdipRemovePropertyItem' delayed;
function GdipSetPropertyItem; external WINGDIPDLL name 'GdipSetPropertyItem' delayed;
function GdipImageForceValidation; external WINGDIPDLL name 'GdipImageForceValidation' delayed;
function GdipCreateBitmapFromStream; external WINGDIPDLL name 'GdipCreateBitmapFromStream' delayed;
function GdipCreateBitmapFromFile; external WINGDIPDLL name 'GdipCreateBitmapFromFile' delayed;
function GdipCreateBitmapFromStreamICM; external WINGDIPDLL name 'GdipCreateBitmapFromStreamICM' delayed;
function GdipCreateBitmapFromFileICM; external WINGDIPDLL name 'GdipCreateBitmapFromFileICM' delayed;
function GdipCreateBitmapFromScan0; external WINGDIPDLL name 'GdipCreateBitmapFromScan0' delayed;
function GdipCreateBitmapFromGraphics; external WINGDIPDLL name 'GdipCreateBitmapFromGraphics' delayed;
function GdipCreateBitmapFromDirectDrawSurface; external WINGDIPDLL name 'GdipCreateBitmapFromDirectDrawSurface' delayed;
function GdipCreateBitmapFromGdiDib; external WINGDIPDLL name 'GdipCreateBitmapFromGdiDib' delayed;
function GdipCreateBitmapFromHBITMAP; external WINGDIPDLL name 'GdipCreateBitmapFromHBITMAP' delayed;
function GdipCreateHBITMAPFromBitmap; external WINGDIPDLL name 'GdipCreateHBITMAPFromBitmap' delayed;
function GdipCreateBitmapFromHICON; external WINGDIPDLL name 'GdipCreateBitmapFromHICON' delayed;
function GdipCreateHICONFromBitmap; external WINGDIPDLL name 'GdipCreateHICONFromBitmap' delayed;
function GdipCreateBitmapFromResource; external WINGDIPDLL name 'GdipCreateBitmapFromResource' delayed;
function GdipCloneBitmapArea; external WINGDIPDLL name 'GdipCloneBitmapArea' delayed;
function GdipCloneBitmapAreaI; external WINGDIPDLL name 'GdipCloneBitmapAreaI' delayed;
function GdipBitmapLockBits; external WINGDIPDLL name 'GdipBitmapLockBits' delayed;
function GdipBitmapUnlockBits; external WINGDIPDLL name 'GdipBitmapUnlockBits' delayed;
function GdipBitmapGetPixel; external WINGDIPDLL name 'GdipBitmapGetPixel' delayed;
function GdipBitmapSetPixel; external WINGDIPDLL name 'GdipBitmapSetPixel' delayed;
function GdipBitmapSetResolution; external WINGDIPDLL name 'GdipBitmapSetResolution' delayed;
function GdipCreateImageAttributes; external WINGDIPDLL name 'GdipCreateImageAttributes' delayed;
function GdipCloneImageAttributes; external WINGDIPDLL name 'GdipCloneImageAttributes' delayed;
function GdipDisposeImageAttributes; external WINGDIPDLL name 'GdipDisposeImageAttributes' delayed;
function GdipSetImageAttributesToIdentity; external WINGDIPDLL name 'GdipSetImageAttributesToIdentity' delayed;
function GdipResetImageAttributes; external WINGDIPDLL name 'GdipResetImageAttributes' delayed;
function GdipSetImageAttributesColorMatrix; external WINGDIPDLL name 'GdipSetImageAttributesColorMatrix' delayed;
function GdipSetImageAttributesThreshold; external WINGDIPDLL name 'GdipSetImageAttributesThreshold' delayed;
function GdipSetImageAttributesGamma; external WINGDIPDLL name 'GdipSetImageAttributesGamma' delayed;
function GdipSetImageAttributesNoOp; external WINGDIPDLL name 'GdipSetImageAttributesNoOp' delayed;
function GdipSetImageAttributesColorKeys; external WINGDIPDLL name 'GdipSetImageAttributesColorKeys' delayed;
function GdipSetImageAttributesOutputChannel; external WINGDIPDLL name 'GdipSetImageAttributesOutputChannel' delayed;
function GdipSetImageAttributesOutputChannelColorProfile; external WINGDIPDLL name 'GdipSetImageAttributesOutputChannelColorProfile' delayed;
function GdipSetImageAttributesRemapTable; external WINGDIPDLL name 'GdipSetImageAttributesRemapTable' delayed;
function GdipSetImageAttributesWrapMode; external WINGDIPDLL name 'GdipSetImageAttributesWrapMode' delayed;
function GdipSetImageAttributesICMMode; external WINGDIPDLL name 'GdipSetImageAttributesICMMode' delayed;
function GdipGetImageAttributesAdjustedPalette; external WINGDIPDLL name 'GdipGetImageAttributesAdjustedPalette' delayed;
function GdipFlush; external WINGDIPDLL name 'GdipFlush' delayed;
function GdipCreateFromHDC; external WINGDIPDLL name 'GdipCreateFromHDC' delayed;
function GdipCreateFromHDC2; external WINGDIPDLL name 'GdipCreateFromHDC2' delayed;
function GdipCreateFromHWND; external WINGDIPDLL name 'GdipCreateFromHWND' delayed;
function GdipCreateFromHWNDICM; external WINGDIPDLL name 'GdipCreateFromHWNDICM' delayed;
function GdipDeleteGraphics; external WINGDIPDLL name 'GdipDeleteGraphics' delayed;
function GdipGetDC; external WINGDIPDLL name 'GdipGetDC' delayed;
function GdipReleaseDC; external WINGDIPDLL name 'GdipReleaseDC' delayed;
function GdipSetCompositingMode; external WINGDIPDLL name 'GdipSetCompositingMode' delayed;
function GdipGetCompositingMode; external WINGDIPDLL name 'GdipGetCompositingMode' delayed;
function GdipSetRenderingOrigin; external WINGDIPDLL name 'GdipSetRenderingOrigin' delayed;
function GdipGetRenderingOrigin; external WINGDIPDLL name 'GdipGetRenderingOrigin' delayed;
function GdipSetCompositingQuality; external WINGDIPDLL name 'GdipSetCompositingQuality' delayed;
function GdipGetCompositingQuality; external WINGDIPDLL name 'GdipGetCompositingQuality' delayed;
function GdipSetSmoothingMode; external WINGDIPDLL name 'GdipSetSmoothingMode' delayed;
function GdipGetSmoothingMode; external WINGDIPDLL name 'GdipGetSmoothingMode' delayed;
function GdipSetPixelOffsetMode; external WINGDIPDLL name 'GdipSetPixelOffsetMode' delayed;
function GdipGetPixelOffsetMode; external WINGDIPDLL name 'GdipGetPixelOffsetMode' delayed;
function GdipSetTextRenderingHint; external WINGDIPDLL name 'GdipSetTextRenderingHint' delayed;
function GdipGetTextRenderingHint; external WINGDIPDLL name 'GdipGetTextRenderingHint' delayed;
function GdipSetTextContrast; external WINGDIPDLL name 'GdipSetTextContrast' delayed;
function GdipGetTextContrast; external WINGDIPDLL name 'GdipGetTextContrast' delayed;
function GdipSetInterpolationMode; external WINGDIPDLL name 'GdipSetInterpolationMode' delayed;
function GdipGetInterpolationMode; external WINGDIPDLL name 'GdipGetInterpolationMode' delayed;
function GdipSetWorldTransform; external WINGDIPDLL name 'GdipSetWorldTransform' delayed;
function GdipResetWorldTransform; external WINGDIPDLL name 'GdipResetWorldTransform' delayed;
function GdipMultiplyWorldTransform; external WINGDIPDLL name 'GdipMultiplyWorldTransform' delayed;
function GdipTranslateWorldTransform; external WINGDIPDLL name 'GdipTranslateWorldTransform' delayed;
function GdipScaleWorldTransform; external WINGDIPDLL name 'GdipScaleWorldTransform' delayed;
function GdipRotateWorldTransform; external WINGDIPDLL name 'GdipRotateWorldTransform' delayed;
function GdipGetWorldTransform; external WINGDIPDLL name 'GdipGetWorldTransform' delayed;
function GdipResetPageTransform; external WINGDIPDLL name 'GdipResetPageTransform' delayed;
function GdipGetPageUnit; external WINGDIPDLL name 'GdipGetPageUnit' delayed;
function GdipGetPageScale; external WINGDIPDLL name 'GdipGetPageScale' delayed;
function GdipSetPageUnit; external WINGDIPDLL name 'GdipSetPageUnit' delayed;
function GdipSetPageScale; external WINGDIPDLL name 'GdipSetPageScale' delayed;
function GdipGetDpiX; external WINGDIPDLL name 'GdipGetDpiX' delayed;
function GdipGetDpiY; external WINGDIPDLL name 'GdipGetDpiY' delayed;
function GdipTransformPoints; external WINGDIPDLL name 'GdipTransformPoints' delayed;
function GdipTransformPointsI; external WINGDIPDLL name 'GdipTransformPointsI' delayed;
function GdipGetNearestColor; external WINGDIPDLL name 'GdipGetNearestColor' delayed;
function GdipCreateHalftonePalette; external WINGDIPDLL name 'GdipCreateHalftonePalette' delayed;
function GdipDrawLine; external WINGDIPDLL name 'GdipDrawLine' delayed;
function GdipDrawLineI; external WINGDIPDLL name 'GdipDrawLineI' delayed;
function GdipDrawLines; external WINGDIPDLL name 'GdipDrawLines' delayed;
function GdipDrawLinesI; external WINGDIPDLL name 'GdipDrawLinesI' delayed;
function GdipDrawArc; external WINGDIPDLL name 'GdipDrawArc' delayed;
function GdipDrawArcI; external WINGDIPDLL name 'GdipDrawArcI' delayed;
function GdipDrawBezier; external WINGDIPDLL name 'GdipDrawBezier' delayed;
function GdipDrawBezierI; external WINGDIPDLL name 'GdipDrawBezierI' delayed;
function GdipDrawBeziers; external WINGDIPDLL name 'GdipDrawBeziers' delayed;
function GdipDrawBeziersI; external WINGDIPDLL name 'GdipDrawBeziersI' delayed;
function GdipDrawRectangle; external WINGDIPDLL name 'GdipDrawRectangle' delayed;
function GdipDrawRectangleI; external WINGDIPDLL name 'GdipDrawRectangleI' delayed;
function GdipDrawRectangles; external WINGDIPDLL name 'GdipDrawRectangles' delayed;
function GdipDrawRectanglesI; external WINGDIPDLL name 'GdipDrawRectanglesI' delayed;
function GdipDrawEllipse; external WINGDIPDLL name 'GdipDrawEllipse' delayed;
function GdipDrawEllipseI; external WINGDIPDLL name 'GdipDrawEllipseI' delayed;
function GdipDrawPie; external WINGDIPDLL name 'GdipDrawPie' delayed;
function GdipDrawPieI; external WINGDIPDLL name 'GdipDrawPieI' delayed;
function GdipDrawPolygon; external WINGDIPDLL name 'GdipDrawPolygon' delayed;
function GdipDrawPolygonI; external WINGDIPDLL name 'GdipDrawPolygonI' delayed;
function GdipDrawPath; external WINGDIPDLL name 'GdipDrawPath' delayed;
function GdipDrawCurve; external WINGDIPDLL name 'GdipDrawCurve' delayed;
function GdipDrawCurveI; external WINGDIPDLL name 'GdipDrawCurveI' delayed;
function GdipDrawCurve2; external WINGDIPDLL name 'GdipDrawCurve2' delayed;
function GdipDrawCurve2I; external WINGDIPDLL name 'GdipDrawCurve2I' delayed;
function GdipDrawCurve3; external WINGDIPDLL name 'GdipDrawCurve3' delayed;
function GdipDrawCurve3I; external WINGDIPDLL name 'GdipDrawCurve3I' delayed;
function GdipDrawClosedCurve; external WINGDIPDLL name 'GdipDrawClosedCurve' delayed;
function GdipDrawClosedCurveI; external WINGDIPDLL name 'GdipDrawClosedCurveI' delayed;
function GdipDrawClosedCurve2; external WINGDIPDLL name 'GdipDrawClosedCurve2' delayed;
function GdipDrawClosedCurve2I; external WINGDIPDLL name 'GdipDrawClosedCurve2I' delayed;
function GdipGraphicsClear; external WINGDIPDLL name 'GdipGraphicsClear' delayed;
function GdipFillRectangle; external WINGDIPDLL name 'GdipFillRectangle' delayed;
function GdipFillRectangleI; external WINGDIPDLL name 'GdipFillRectangleI' delayed;
function GdipFillRectangles; external WINGDIPDLL name 'GdipFillRectangles' delayed;
function GdipFillRectanglesI; external WINGDIPDLL name 'GdipFillRectanglesI' delayed;
function GdipFillPolygon; external WINGDIPDLL name 'GdipFillPolygon' delayed;
function GdipFillPolygonI; external WINGDIPDLL name 'GdipFillPolygonI' delayed;
function GdipFillPolygon2; external WINGDIPDLL name 'GdipFillPolygon2' delayed;
function GdipFillPolygon2I; external WINGDIPDLL name 'GdipFillPolygon2I' delayed;
function GdipFillEllipse; external WINGDIPDLL name 'GdipFillEllipse' delayed;
function GdipFillEllipseI; external WINGDIPDLL name 'GdipFillEllipseI' delayed;
function GdipFillPie; external WINGDIPDLL name 'GdipFillPie' delayed;
function GdipFillPieI; external WINGDIPDLL name 'GdipFillPieI' delayed;
function GdipFillPath; external WINGDIPDLL name 'GdipFillPath' delayed;
function GdipFillClosedCurve; external WINGDIPDLL name 'GdipFillClosedCurve' delayed;
function GdipFillClosedCurveI; external WINGDIPDLL name 'GdipFillClosedCurveI' delayed;
function GdipFillClosedCurve2; external WINGDIPDLL name 'GdipFillClosedCurve2' delayed;
function GdipFillClosedCurve2I; external WINGDIPDLL name 'GdipFillClosedCurve2I' delayed;
function GdipFillRegion; external WINGDIPDLL name 'GdipFillRegion' delayed;
function GdipDrawImage; external WINGDIPDLL name 'GdipDrawImage' delayed;
function GdipDrawImageI; external WINGDIPDLL name 'GdipDrawImageI' delayed;
function GdipDrawImageRect; external WINGDIPDLL name 'GdipDrawImageRect' delayed;
function GdipDrawImageRectI; external WINGDIPDLL name 'GdipDrawImageRectI' delayed;
function GdipDrawImagePoints; external WINGDIPDLL name 'GdipDrawImagePoints' delayed;
function GdipDrawImagePointsI; external WINGDIPDLL name 'GdipDrawImagePointsI' delayed;
function GdipDrawImagePointRect; external WINGDIPDLL name 'GdipDrawImagePointRect' delayed;
function GdipDrawImagePointRectI; external WINGDIPDLL name 'GdipDrawImagePointRectI' delayed;
function GdipDrawImageRectRect; external WINGDIPDLL name 'GdipDrawImageRectRect' delayed;
function GdipDrawImageRectRectI; external WINGDIPDLL name 'GdipDrawImageRectRectI' delayed;
function GdipDrawImagePointsRect; external WINGDIPDLL name 'GdipDrawImagePointsRect' delayed;
function GdipDrawImagePointsRectI; external WINGDIPDLL name 'GdipDrawImagePointsRectI' delayed;
function GdipEnumerateMetafileDestPoint; external WINGDIPDLL name 'GdipEnumerateMetafileDestPoint' delayed;
function GdipEnumerateMetafileDestPointI; external WINGDIPDLL name 'GdipEnumerateMetafileDestPointI' delayed;
function GdipEnumerateMetafileDestRect; external WINGDIPDLL name 'GdipEnumerateMetafileDestRect' delayed;
function GdipEnumerateMetafileDestRectI; external WINGDIPDLL name 'GdipEnumerateMetafileDestRectI' delayed;
function GdipEnumerateMetafileDestPoints; external WINGDIPDLL name 'GdipEnumerateMetafileDestPoints' delayed;
function GdipEnumerateMetafileDestPointsI; external WINGDIPDLL name 'GdipEnumerateMetafileDestPointsI' delayed;
function GdipEnumerateMetafileSrcRectDestPoint; external WINGDIPDLL name 'GdipEnumerateMetafileSrcRectDestPoint' delayed;
function GdipEnumerateMetafileSrcRectDestPointI; external WINGDIPDLL name 'GdipEnumerateMetafileSrcRectDestPointI' delayed;
function GdipEnumerateMetafileSrcRectDestRect; external WINGDIPDLL name 'GdipEnumerateMetafileSrcRectDestRect' delayed;
function GdipEnumerateMetafileSrcRectDestRectI; external WINGDIPDLL name 'GdipEnumerateMetafileSrcRectDestRectI' delayed;
function GdipEnumerateMetafileSrcRectDestPoints; external WINGDIPDLL name 'GdipEnumerateMetafileSrcRectDestPoints' delayed;
function GdipEnumerateMetafileSrcRectDestPointsI; external WINGDIPDLL name 'GdipEnumerateMetafileSrcRectDestPointsI' delayed;
function GdipPlayMetafileRecord; external WINGDIPDLL name 'GdipPlayMetafileRecord' delayed;
function GdipSetClipGraphics; external WINGDIPDLL name 'GdipSetClipGraphics' delayed;
function GdipSetClipRect; external WINGDIPDLL name 'GdipSetClipRect' delayed;
function GdipSetClipRectI; external WINGDIPDLL name 'GdipSetClipRectI' delayed;
function GdipSetClipPath; external WINGDIPDLL name 'GdipSetClipPath' delayed;
function GdipSetClipRegion; external WINGDIPDLL name 'GdipSetClipRegion' delayed;
function GdipSetClipHrgn; external WINGDIPDLL name 'GdipSetClipHrgn' delayed;
function GdipResetClip; external WINGDIPDLL name 'GdipResetClip' delayed;
function GdipTranslateClip; external WINGDIPDLL name 'GdipTranslateClip' delayed;
function GdipTranslateClipI; external WINGDIPDLL name 'GdipTranslateClipI' delayed;
function GdipGetClip; external WINGDIPDLL name 'GdipGetClip' delayed;
function GdipGetClipBounds; external WINGDIPDLL name 'GdipGetClipBounds' delayed;
function GdipGetClipBoundsI; external WINGDIPDLL name 'GdipGetClipBoundsI' delayed;
function GdipIsClipEmpty; external WINGDIPDLL name 'GdipIsClipEmpty' delayed;
function GdipGetVisibleClipBounds; external WINGDIPDLL name 'GdipGetVisibleClipBounds' delayed;
function GdipGetVisibleClipBoundsI; external WINGDIPDLL name 'GdipGetVisibleClipBoundsI' delayed;
function GdipIsVisibleClipEmpty; external WINGDIPDLL name 'GdipIsVisibleClipEmpty' delayed;
function GdipIsVisiblePoint; external WINGDIPDLL name 'GdipIsVisiblePoint' delayed;
function GdipIsVisiblePointI; external WINGDIPDLL name 'GdipIsVisiblePointI' delayed;
function GdipIsVisibleRect; external WINGDIPDLL name 'GdipIsVisibleRect' delayed;
function GdipIsVisibleRectI; external WINGDIPDLL name 'GdipIsVisibleRectI' delayed;
function GdipSaveGraphics; external WINGDIPDLL name 'GdipSaveGraphics' delayed;
function GdipRestoreGraphics; external WINGDIPDLL name 'GdipRestoreGraphics' delayed;
function GdipBeginContainer; external WINGDIPDLL name 'GdipBeginContainer' delayed;
function GdipBeginContainerI; external WINGDIPDLL name 'GdipBeginContainerI' delayed;
function GdipBeginContainer2; external WINGDIPDLL name 'GdipBeginContainer2' delayed;
function GdipEndContainer; external WINGDIPDLL name 'GdipEndContainer' delayed;
function GdipGetMetafileHeaderFromWmf; external WINGDIPDLL name 'GdipGetMetafileHeaderFromWmf' delayed;
function GdipGetMetafileHeaderFromEmf; external WINGDIPDLL name 'GdipGetMetafileHeaderFromEmf' delayed;
function GdipGetMetafileHeaderFromFile; external WINGDIPDLL name 'GdipGetMetafileHeaderFromFile' delayed;
function GdipGetMetafileHeaderFromStream; external WINGDIPDLL name 'GdipGetMetafileHeaderFromStream' delayed;
function GdipGetMetafileHeaderFromMetafile; external WINGDIPDLL name 'GdipGetMetafileHeaderFromMetafile' delayed;
function GdipGetHemfFromMetafile; external WINGDIPDLL name 'GdipGetHemfFromMetafile' delayed;
function GdipCreateStreamOnFile; external WINGDIPDLL name 'GdipCreateStreamOnFile' delayed;
function GdipCreateMetafileFromWmf; external WINGDIPDLL name 'GdipCreateMetafileFromWmf' delayed;
function GdipCreateMetafileFromEmf; external WINGDIPDLL name 'GdipCreateMetafileFromEmf' delayed;
function GdipCreateMetafileFromFile; external WINGDIPDLL name 'GdipCreateMetafileFromFile' delayed;
function GdipCreateMetafileFromWmfFile; external WINGDIPDLL name 'GdipCreateMetafileFromWmfFile' delayed;
function GdipCreateMetafileFromStream; external WINGDIPDLL name 'GdipCreateMetafileFromStream' delayed;
function GdipRecordMetafile; external WINGDIPDLL name 'GdipRecordMetafile' delayed;
function GdipRecordMetafileI; external WINGDIPDLL name 'GdipRecordMetafileI' delayed;
function GdipRecordMetafileFileName; external WINGDIPDLL name 'GdipRecordMetafileFileName' delayed;
function GdipRecordMetafileFileNameI; external WINGDIPDLL name 'GdipRecordMetafileFileNameI' delayed;
function GdipRecordMetafileStream; external WINGDIPDLL name 'GdipRecordMetafileStream' delayed;
function GdipRecordMetafileStreamI; external WINGDIPDLL name 'GdipRecordMetafileStreamI' delayed;
function GdipSetMetafileDownLevelRasterizationLimit; external WINGDIPDLL name 'GdipSetMetafileDownLevelRasterizationLimit' delayed;
function GdipGetMetafileDownLevelRasterizationLimit; external WINGDIPDLL name 'GdipGetMetafileDownLevelRasterizationLimit' delayed;
function GdipGetImageDecodersSize; external WINGDIPDLL name 'GdipGetImageDecodersSize' delayed;
function GdipGetImageDecoders; external WINGDIPDLL name 'GdipGetImageDecoders' delayed;
function GdipGetImageEncodersSize; external WINGDIPDLL name 'GdipGetImageEncodersSize' delayed;
function GdipGetImageEncoders; external WINGDIPDLL name 'GdipGetImageEncoders' delayed;
function GdipComment; external WINGDIPDLL name 'GdipComment' delayed;
function GdipCreateFontFamilyFromName; external WINGDIPDLL name 'GdipCreateFontFamilyFromName' delayed;
function GdipDeleteFontFamily; external WINGDIPDLL name 'GdipDeleteFontFamily' delayed;
function GdipCloneFontFamily; external WINGDIPDLL name 'GdipCloneFontFamily' delayed;
function GdipGetGenericFontFamilySansSerif; external WINGDIPDLL name 'GdipGetGenericFontFamilySansSerif' delayed;
function GdipGetGenericFontFamilySerif; external WINGDIPDLL name 'GdipGetGenericFontFamilySerif' delayed;
function GdipGetGenericFontFamilyMonospace; external WINGDIPDLL name 'GdipGetGenericFontFamilyMonospace' delayed;
function GdipGetFamilyName; external WINGDIPDLL name 'GdipGetFamilyName' delayed;
function GdipIsStyleAvailable; external WINGDIPDLL name 'GdipIsStyleAvailable' delayed;
function GdipFontCollectionEnumerable; external WINGDIPDLL name 'GdipFontCollectionEnumerable' delayed;
function GdipFontCollectionEnumerate; external WINGDIPDLL name 'GdipFontCollectionEnumerate' delayed;
function GdipGetEmHeight; external WINGDIPDLL name 'GdipGetEmHeight' delayed;
function GdipGetCellAscent; external WINGDIPDLL name 'GdipGetCellAscent' delayed;
function GdipGetCellDescent; external WINGDIPDLL name 'GdipGetCellDescent' delayed;
function GdipGetLineSpacing; external WINGDIPDLL name 'GdipGetLineSpacing' delayed;
function GdipCreateFontFromDC; external WINGDIPDLL name 'GdipCreateFontFromDC' delayed;
function GdipCreateFontFromLogfontA; external WINGDIPDLL name 'GdipCreateFontFromLogfontA' delayed;
function GdipCreateFontFromLogfontW; external WINGDIPDLL name 'GdipCreateFontFromLogfontW' delayed;
function GdipCreateFont; external WINGDIPDLL name 'GdipCreateFont' delayed;
function GdipCloneFont; external WINGDIPDLL name 'GdipCloneFont' delayed;
function GdipDeleteFont; external WINGDIPDLL name 'GdipDeleteFont' delayed;
function GdipGetFamily; external WINGDIPDLL name 'GdipGetFamily' delayed;
function GdipGetFontStyle; external WINGDIPDLL name 'GdipGetFontStyle' delayed;
function GdipGetFontSize; external WINGDIPDLL name 'GdipGetFontSize' delayed;
function GdipGetFontUnit; external WINGDIPDLL name 'GdipGetFontUnit' delayed;
function GdipGetFontHeight; external WINGDIPDLL name 'GdipGetFontHeight' delayed;
function GdipGetFontHeightGivenDPI; external WINGDIPDLL name 'GdipGetFontHeightGivenDPI' delayed;
function GdipGetLogFontA; external WINGDIPDLL name 'GdipGetLogFontA' delayed;
function GdipGetLogFontW; external WINGDIPDLL name 'GdipGetLogFontW' delayed;
function GdipNewInstalledFontCollection; external WINGDIPDLL name 'GdipNewInstalledFontCollection' delayed;
function GdipNewPrivateFontCollection; external WINGDIPDLL name 'GdipNewPrivateFontCollection' delayed;
function GdipDeletePrivateFontCollection; external WINGDIPDLL name 'GdipDeletePrivateFontCollection' delayed;
function GdipGetFontCollectionFamilyCount; external WINGDIPDLL name 'GdipGetFontCollectionFamilyCount' delayed;
function GdipGetFontCollectionFamilyList; external WINGDIPDLL name 'GdipGetFontCollectionFamilyList' delayed;
function GdipPrivateAddFontFile; external WINGDIPDLL name 'GdipPrivateAddFontFile' delayed;
function GdipPrivateAddMemoryFont; external WINGDIPDLL name 'GdipPrivateAddMemoryFont' delayed;
function GdipDrawString; external WINGDIPDLL name 'GdipDrawString' delayed;
function GdipMeasureString; external WINGDIPDLL name 'GdipMeasureString' delayed;
function GdipMeasureCharacterRanges; external WINGDIPDLL name 'GdipMeasureCharacterRanges' delayed;
function GdipDrawDriverString; external WINGDIPDLL name 'GdipDrawDriverString' delayed;
function GdipMeasureDriverString; external WINGDIPDLL name 'GdipMeasureDriverString' delayed;
function GdipCreateStringFormat; external WINGDIPDLL name 'GdipCreateStringFormat' delayed;
function GdipStringFormatGetGenericDefault; external WINGDIPDLL name 'GdipStringFormatGetGenericDefault' delayed;
function GdipStringFormatGetGenericTypographic; external WINGDIPDLL name 'GdipStringFormatGetGenericTypographic' delayed;
function GdipDeleteStringFormat; external WINGDIPDLL name 'GdipDeleteStringFormat' delayed;
function GdipCloneStringFormat; external WINGDIPDLL name 'GdipCloneStringFormat' delayed;
function GdipSetStringFormatFlags; external WINGDIPDLL name 'GdipSetStringFormatFlags' delayed;
function GdipGetStringFormatFlags; external WINGDIPDLL name 'GdipGetStringFormatFlags' delayed;
function GdipSetStringFormatAlign; external WINGDIPDLL name 'GdipSetStringFormatAlign' delayed;
function GdipGetStringFormatAlign; external WINGDIPDLL name 'GdipGetStringFormatAlign' delayed;
function GdipSetStringFormatLineAlign; external WINGDIPDLL name 'GdipSetStringFormatLineAlign' delayed;
function GdipGetStringFormatLineAlign; external WINGDIPDLL name 'GdipGetStringFormatLineAlign' delayed;
function GdipSetStringFormatTrimming; external WINGDIPDLL name 'GdipSetStringFormatTrimming' delayed;
function GdipGetStringFormatTrimming; external WINGDIPDLL name 'GdipGetStringFormatTrimming' delayed;
function GdipSetStringFormatHotkeyPrefix; external WINGDIPDLL name 'GdipSetStringFormatHotkeyPrefix' delayed;
function GdipGetStringFormatHotkeyPrefix; external WINGDIPDLL name 'GdipGetStringFormatHotkeyPrefix' delayed;
function GdipSetStringFormatTabStops; external WINGDIPDLL name 'GdipSetStringFormatTabStops' delayed;
function GdipGetStringFormatTabStops; external WINGDIPDLL name 'GdipGetStringFormatTabStops' delayed;
function GdipGetStringFormatTabStopCount; external WINGDIPDLL name 'GdipGetStringFormatTabStopCount' delayed;
function GdipSetStringFormatDigitSubstitution; external WINGDIPDLL name 'GdipSetStringFormatDigitSubstitution' delayed;
function GdipGetStringFormatDigitSubstitution; external WINGDIPDLL name 'GdipGetStringFormatDigitSubstitution' delayed;
function GdipGetStringFormatMeasurableCharacterRangeCount; external WINGDIPDLL name 'GdipGetStringFormatMeasurableCharacterRangeCount' delayed;
function GdipSetStringFormatMeasurableCharacterRanges; external WINGDIPDLL name 'GdipSetStringFormatMeasurableCharacterRanges' delayed;
function GdipCreateCachedBitmap; external WINGDIPDLL name 'GdipCreateCachedBitmap' delayed;
function GdipDeleteCachedBitmap; external WINGDIPDLL name 'GdipDeleteCachedBitmap' delayed;
function GdipDrawCachedBitmap; external WINGDIPDLL name 'GdipDrawCachedBitmap' delayed;
function GdipEmfToWmfBits; external WINGDIPDLL name 'GdipEmfToWmfBits' delayed;

// -----------------------------------------------------------------------------
// TGdiplusBase class
// -----------------------------------------------------------------------------

class function TGdiplusBase.NewInstance: TObject;
begin
  Result := InitInstance(GdipAlloc(ULONG(instanceSize)));
end;

procedure TGdiplusBase.FreeInstance;
begin
  CleanupInstance;
  GdipFree(Self);
end;

// -----------------------------------------------------------------------------
// macros
// -----------------------------------------------------------------------------

function ObjectTypeIsValid(type_: ObjectType): BOOL;
begin
  result :=  ((type_ >= ObjectTypeMin) and (type_ <= ObjectTypeMax));
end;

function GDIP_WMF_RECORD_TO_EMFPLUS(n: integer): Integer;
begin
  result := (n or GDIP_WMF_RECORD_BASE);
end;

function GDIP_EMFPLUS_RECORD_TO_WMF(n: integer): Integer;
begin
  result := n and (not GDIP_WMF_RECORD_BASE);
end;

function GDIP_IS_WMF_RECORDTYPE(n: integer): BOOL;
begin
  result := ((n and GDIP_WMF_RECORD_BASE) <> 0);
end;


//--------------------------------------------------------------------------
// TGPPoint Util
//--------------------------------------------------------------------------

function MakePoint(X, Y: Integer): TGPPoint;
begin
  result.X := X;
  result.Y := Y;
end;

function MakePoint(X, Y: Single): TGPPointF;
begin
  Result.X := X;
  result.Y := Y;
end;

//--------------------------------------------------------------------------
// TGPSize Util
//--------------------------------------------------------------------------

function MakeSize(Width, Height: Single): TGPSizeF;
begin
  result.Width := Width;
  result.Height := Height;
end;

function MakeSize(Width, Height: Integer): TGPSize;
begin
  result.Width := Width;
  result.Height := Height;
end;

//--------------------------------------------------------------------------
// TCharacterRange Util
//--------------------------------------------------------------------------

function MakeCharacterRange(First, Length: Integer): TCharacterRange;
begin
  result.First  := First;
  result.Length := Length;
end;

// -----------------------------------------------------------------------------
// RectF class
// -----------------------------------------------------------------------------

function MakeRect(x, y, width, height: Single): TGPRectF; overload;
begin
  Result.X      := x;
  Result.Y      := y;
  Result.Width  := width;
  Result.Height := height;
end;

function MakeRect(location: TGPPointF; size: TGPSizeF): TGPRectF; overload;
begin
  Result.X      := location.X;
  Result.Y      := location.Y;
  Result.Width  := size.Width;
  Result.Height := size.Height;
end;

// -----------------------------------------------------------------------------
// Rect class
// -----------------------------------------------------------------------------

function MakeRect(x, y, width, height: Integer): TGPRect; overload;
begin
  Result.X      := x;
  Result.Y      := y;
  Result.Width  := width;
  Result.Height := height;
end;

function MakeRect(location: TGPPoint; size: TGPSize): TGPRect; overload;
begin
  Result.X      := location.X;
  Result.Y      := location.Y;
  Result.Width  := size.Width;
  Result.Height := size.Height;
end;

function MakeRect(const Rect: TRect): TGPRect;
begin
  Result.X := rect.Left;
  Result.Y := Rect.Top;
  Result.Width := Rect.Right-Rect.Left;
  Result.Height:= Rect.Bottom-Rect.Top;
end;

// -----------------------------------------------------------------------------
// PathData class
// -----------------------------------------------------------------------------

constructor TPathData.Create;
begin
  Count := 0;
  Points := nil;
  Types := nil;
end;

destructor TPathData.destroy;
begin
  if assigned(Points) then freemem(Points);
  if assigned(Types) then freemem(Types);
end;


function GetPixelFormatSize(pixfmt: PixelFormat): UINT;
begin
  result := (pixfmt shr 8) and $ff;
end;

function IsIndexedPixelFormat(pixfmt: PixelFormat): BOOL;
begin
  result := (pixfmt and PixelFormatIndexed) <> 0;
end;

function IsAlphaPixelFormat(pixfmt: PixelFormat): BOOL;
begin
  result := (pixfmt and PixelFormatAlpha) <> 0;
end;

function IsExtendedPixelFormat(pixfmt: PixelFormat): BOOL;
begin
  result := (pixfmt and PixelFormatExtended) <> 0;
end;

function IsCanonicalPixelFormat(pixfmt: PixelFormat): BOOL;
begin
  result := (pixfmt and PixelFormatCanonical) <> 0;
end;

// -----------------------------------------------------------------------------
// Color class
// -----------------------------------------------------------------------------

{  constructor TGPColor.Create;
  begin
    Argb := DWORD(Black);
  end;

  // Construct an opaque Color object with
  // the specified Red, Green, Blue values.
  //
  // Color values are not premultiplied.

  constructor TGPColor.Create(r, g, b: Byte);
  begin
    Argb := MakeARGB(255, r, g, b);
  end;

  constructor TGPColor.Create(a, r, g, b: Byte);
  begin
    Argb := MakeARGB(a, r, g, b);
  end;

  constructor TGPColor.Create(Value: ARGB);
  begin
    Argb := Value;
  end;

  function TGPColor.GetAlpha: BYTE;
  begin
    result := BYTE(Argb shr AlphaShift);
  end;

  function TGPColor.GetA: BYTE;
  begin
    result := GetAlpha;
  end;

  function TGPColor.GetRed: BYTE;
  begin
    result := BYTE(Argb shr RedShift);
  end;

  function TGPColor.GetR: BYTE;
  begin
    result := GetRed;
  end;

  function TGPColor.GetGreen: Byte;
  begin
    result := BYTE(Argb shr GreenShift);
  end;

  function TGPColor.GetG: Byte;
  begin
    result := GetGreen;
  end;

  function TGPColor.GetBlue: Byte;
  begin
    result := BYTE(Argb shr BlueShift);
  end;

  function TGPColor.GetB: Byte;
  begin
    result := GetBlue;
  end;

  function TGPColor.GetValue: ARGB;
  begin
    result := Argb;
  end;

  procedure TGPColor.SetValue(Value: ARGB);
  begin
    Argb := Value;
  end;

  procedure TGPColor.SetFromCOLORREF(rgb: COLORREF);
  begin
    Argb := MakeARGB(255, GetRValue(rgb), GetGValue(rgb), GetBValue(rgb));
  end;

  function TGPColor.ToCOLORREF: COLORREF;
  begin
    result := RGB(GetRed, GetGreen, GetBlue);
  end;

  function TGPColor.MakeARGB(a, r, g, b: Byte): ARGB;
  begin
    result := ((DWORD(b) shl  BlueShift) or
               (DWORD(g) shl GreenShift) or
               (DWORD(r) shl   RedShift) or
               (DWORD(a) shl AlphaShift));
  end;  }

function MakeColor(r, g, b: Byte): ARGB; overload;
begin
  result := MakeColor(255, r, g, b);
end;

function MakeColor(a, r, g, b: Byte): ARGB; overload;
begin
  result := ((DWORD(b) shl  BlueShift) or
             (DWORD(g) shl GreenShift) or
             (DWORD(r) shl   RedShift) or
             (DWORD(a) shl AlphaShift));
end;

function GetAlpha(color: ARGB): BYTE;
begin
  result := BYTE(color shr AlphaShift);
end;

function GetRed(color: ARGB): BYTE;
begin
  result := BYTE(color shr RedShift);
end;

function GetGreen(color: ARGB): BYTE;
begin
  result := BYTE(color shr GreenShift);
end;

function GetBlue(color: ARGB): BYTE;
begin
  result := BYTE(color shr BlueShift);
end;

function ColorRefToARGB(rgb: COLORREF): ARGB;
begin
  result := MakeColor(255, GetRValue(rgb), GetGValue(rgb), GetBValue(rgb));
end;

function ARGBToColorRef(Color: ARGB): COLORREF;
begin
  result := RGB(GetRed(Color), GetGreen(Color), GetBlue(Color));
end;


// -----------------------------------------------------------------------------
// MetafileHeader class
// -----------------------------------------------------------------------------

  procedure TMetafileHeader.GetBounds(out Rect: TGPRect);
  begin
    rect.X      := X;
    rect.Y      := Y;
    rect.Width  := Width;
    rect.Height := Height;
  end;

  function TMetafileHeader.IsWmf: BOOL;
  begin
    result :=  ((Type_ = MetafileTypeWmf) or (Type_ = MetafileTypeWmfPlaceable));
  end;

  function TMetafileHeader.IsWmfPlaceable: BOOL;
  begin
    result := (Type_ = MetafileTypeWmfPlaceable);
  end;

  function TMetafileHeader.IsEmf: BOOL;
  begin
    result := (Type_ = MetafileTypeEmf);
  end;

  function TMetafileHeader.IsEmfOrEmfPlus: BOOL;
  begin
    result := (Type_ >= MetafileTypeEmf);
  end;

  function TMetafileHeader.IsEmfPlus: BOOL;
  begin
    result := (Type_ >= MetafileTypeEmfPlusOnly)
  end;

  function TMetafileHeader.IsEmfPlusDual: BOOL;
  begin
    result := (Type_ = MetafileTypeEmfPlusDual)
  end;

  function TMetafileHeader.IsEmfPlusOnly: BOOL;
  begin
    result := (Type_ = MetafileTypeEmfPlusOnly)
  end;

  function TMetafileHeader.IsDisplay: BOOL;
  begin
    result := (IsEmfPlus and ((EmfPlusFlags and GDIP_EMFPLUSFLAGS_DISPLAY) <> 0));
  end;

  function TMetafileHeader.GetWmfHeader: PMetaHeader;
  begin
    if IsWmf then result :=  @Header.WmfHeader
             else result := nil;
  end;

  function TMetafileHeader.GetEmfHeader: PENHMETAHEADER3;
  begin
    if IsEmfOrEmfPlus then result := @Header.EmfHeader
                      else result := nil;
  end;

end.




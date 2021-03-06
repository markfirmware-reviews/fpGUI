{
    fpGUI  -  Free Pascal GUI Toolkit

    Copyright (C) 2006 - 2016 See the file AUTHORS.txt, included in this
    distribution, for details of the copyright.

    See the file COPYING.modifiedLGPL, included in this distribution,
    for details about redistributing fpGUI.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Description:
      This defines the CoreLib backend interface to the Ultibo API.
}

unit fpg_ultibo;

{--$mode objfpc}
{$mode delphi}{$H+}

{.$Define DEBUG}
{.$Define DND_DEBUG}
{.$Define DEBUGKEYS}

{$UNDEF AGG2D_NO_FONT}
{$UNDEF AGG2D_USE_FREETYPE}
{$UNDEF AGG2D_USE_WINFONTS}
{$DEFINE AGG2D_USE_RASTERFONTS}

interface

uses
  agg_basics ,
  agg_array ,
  agg_trans_affine ,
  agg_trans_viewport ,
  agg_path_storage ,
  agg_conv_stroke ,
  agg_conv_transform ,
  agg_conv_curve ,
  agg_conv_dash ,
  agg_rendering_buffer ,
  agg_renderer_base ,
  agg_renderer_scanline ,
  agg_span_gradient ,
  agg_span_image_filter_rgba ,
  agg_span_image_resample_rgba ,
  agg_span_converter ,
  agg_span_interpolator_linear ,
  agg_span_allocator ,
  agg_rasterizer_scanline_aa ,
  agg_gamma_functions ,
  agg_scanline_u ,
  agg_arc ,
  agg_bezier_arc ,
  agg_rounded_rect ,
  agg_font_engine ,
  agg_font_cache_manager ,
  agg_pixfmt ,
  agg_pixfmt_rgb ,
  agg_pixfmt_rgba ,
  agg_color ,
  agg_math_stroke ,
  agg_image_filters ,
  agg_vertex_source ,
  agg_render_scanlines ,

{$IFDEF AGG2D_USE_FREETYPE }
  agg_font_freetype ,
{$ENDIF }
{$IFDEF AGG2D_USE_RASTERFONTS}
  agg_embedded_raster_fonts ,
  agg_glyph_raster_bin ,
  agg_renderer_raster_text ,
{$ENDIF}

  GlobalConst,
  GlobalConfig,
  Platform,
  Threads,
  Devices,
  Framebuffer,
  Classes,
  SysUtils,
  fpg_base,
  fpg_impl
  {$IFDEF DEBUG}
  ,fpg_dbugintf
  {$ENDIF DEBUG}
  ;

{Agg2D constants}  
const
// LineJoin
 AGG_JoinMiter = miter_join;
 AGG_JoinRound = round_join;
 AGG_JoinBevel = bevel_join;

// LineCap
 AGG_CapButt   = butt_cap;
 AGG_CapSquare = square_cap;
 AGG_CapRound  = round_cap;

// TextAlignment
 AGG_AlignLeft   = 0;
 AGG_AlignRight  = 1;
 AGG_AlignCenter = 2;
 AGG_AlignTop    = AGG_AlignRight;
 AGG_AlignBottom = AGG_AlignLeft;

// BlendMode
 AGG_BlendAlpha      = end_of_comp_op_e;
 AGG_BlendClear      = comp_op_clear;
 AGG_BlendSrc        = comp_op_src;
 AGG_BlendDst        = comp_op_dst;
 AGG_BlendSrcOver    = comp_op_src_over;
 AGG_BlendDstOver    = comp_op_dst_over;
 AGG_BlendSrcIn      = comp_op_src_in;
 AGG_BlendDstIn      = comp_op_dst_in;
 AGG_BlendSrcOut     = comp_op_src_out;
 AGG_BlendDstOut     = comp_op_dst_out;
 AGG_BlendSrcAtop    = comp_op_src_atop;
 AGG_BlendDstAtop    = comp_op_dst_atop;
 AGG_BlendXor        = comp_op_xor;
 AGG_BlendAdd        = comp_op_plus;
 AGG_BlendSub        = comp_op_minus;
 AGG_BlendMultiply   = comp_op_multiply;
 AGG_BlendScreen     = comp_op_screen;
 AGG_BlendOverlay    = comp_op_overlay;
 AGG_BlendDarken     = comp_op_darken;
 AGG_BlendLighten    = comp_op_lighten;
 AGG_BlendColorDodge = comp_op_color_dodge;
 AGG_BlendColorBurn  = comp_op_color_burn;
 AGG_BlendHardLight  = comp_op_hard_light;
 AGG_BlendSoftLight  = comp_op_soft_light;
 AGG_BlendDifference = comp_op_difference;
 AGG_BlendExclusion  = comp_op_exclusion;
 AGG_BlendContrast   = comp_op_contrast;
  
{Agg2D types}  
type
 PAggColor = ^TAggColor;
 TAggColor = rgba8;

 TAggRectD = agg_basics.rect_d;

 TAggAffine = trans_affine;
 PAggAffine = trans_affine_ptr;

 TAggFontRasterizer = gray8_adaptor_type;
 PAggFontRasterizer = gray8_adaptor_type_ptr;

 TAggFontScanline = gray8_scanline_type;
 PAggFontScanline = gray8_scanline_type_ptr;

{$IFDEF AGG2D_USE_FREETYPE }
 TAggFontEngine = font_engine_freetype_int32;
{$ENDIF }

 TAggGradient  = (
   AGG_Solid ,
   AGG_Linear ,
   AGG_Radial );

 TAggDirection = (
   AGG_CW,
   AGG_CCW );

 TAggLineJoin  = int;
 TAggLineCap   = int;
 TAggBlendMode = comp_op_e;

 TAggTextAlignment = int;

 TAggDrawPathFlag = (
  AGG_FillOnly ,
  AGG_StrokeOnly ,
  AGG_FillAndStroke ,
  AGG_FillWithLineColor );

 TAggViewportOption = (
  AGG_Anisotropic ,
  AGG_XMinYMin ,
  AGG_XMidYMin ,
  AGG_XMaxYMin ,
  AGG_XMinYMid ,
  AGG_XMidYMid ,
  AGG_XMaxYMid ,
  AGG_XMinYMax ,
  AGG_XMidYMax ,
  AGG_XMaxYMax );

 TAggImageFilter = (
  AGG_NoFilter ,
  AGG_Bilinear ,
  AGG_Hanning ,
  AGG_Hermite ,
  AGG_Quadric ,
  AGG_Bicubic ,
  AGG_Catrom ,
  AGG_Spline16 ,
  AGG_Spline36 ,
  AGG_Blackman144 );

 TAggImageResample = (
  AGG_NoResample ,
  AGG_ResampleAlways ,
  AGG_ResampleOnZoomOut );

 TAggFontCacheType = (
  AGG_RasterFontCache ,
  AGG_VectorFontCache );

 TPixelFormat = (pf8bit, pf16bit, pf24bit, pf32bit);

 PAggTransformations = ^TAggTransformations;
 TAggTransformations = record
   affineMatrix : array[0..5 ] of double;
  end;
  
 TAggRasterizerGamma = object(vertex_source )
   m_alpha : gamma_multiply;
   m_gamma : gamma_power;

   constructor Construct(alpha ,gamma : double );

   function func_operator_gamma(x : double ) : double; virtual;
  end;

 TfpgUltiboImage = class;
 
 PAggImage = ^TAggImage;
 TAggImage = object
   renBuf : rendering_buffer;

   constructor Construct;
   destructor  Destruct;

   function  attach(bitmap : TfpgUltiboImage; flip : boolean ) : boolean;

   function  width : int;
   function  height : int;
  end;
  
{fpGUI classes}  
{type}
  TfpgUltiboWindow = class;
  TfpgUltiboDrag = class;
  
  TfpgUltiboFontResource = class(TfpgFontResourceBase)
  private
    {$IFDEF AGG2D_USE_FREETYPE}
    FFontData: THandle;
    {$ENDIF}
    {$IFDEF AGG2D_USE_RASTERFONTS}
    FFontData: int8u_ptr;
    {$ENDIF}
  protected
    {$IFDEF AGG2D_USE_FREETYPE}
    function    OpenFontByDesc(const desc: string): THandle;
    {$ENDIF}
    {$IFDEF AGG2D_USE_RASTERFONTS}
    function    GetFontByDesc(const desc: string): int8u_ptr;
    {$ENDIF}
  public
    {$IFDEF AGG2D_USE_FREETYPE}
    property    Handle: THandle read FFontData;
    {$ENDIF}
    {$IFDEF AGG2D_USE_RASTERFONTS}
    property    FontData: int8u_ptr read FFontData;
    {$ENDIF}
  public
    constructor Create(const afontdesc: string);
    destructor  Destroy; override;
    function    HandleIsValid: boolean;
    function    GetAscent: integer; override;
    function    GetDescent: integer; override;
    function    GetHeight: integer; override;
    function    GetTextWidth(const txt: string): integer; override;
  end;
  
  TfpgUltiboImage = class(TfpgImageBase)
  protected
    procedure   DoFreeImage; override;
    procedure   DoInitImage(acolordepth, awidth, aheight: integer; aimgdata: Pointer); override;
    procedure   DoInitImageMask(awidth, aheight: integer; aimgdata: Pointer); override;
  public
    constructor Create;
  end;
  
  TfpgUltiboCanvas = class(TfpgCanvasBase) {Based on TAgg2D class}
  private
    {Agg2D properties}
    m_rbuf : rendering_buffer;
    m_pixf : TPixelFormat;
 
    m_pixFormat ,m_pixFormatComp ,m_pixFormatPre ,m_pixFormatCompPre : pixel_formats;
    m_renBase   ,m_renBaseComp   ,m_renBasePre   ,m_renBaseCompPre   : renderer_base;
 
    m_renSolid ,m_renSolidComp : renderer_scanline_aa_solid;
 
    m_allocator : span_allocator;
    m_clipBox   : TAggRectD;
 
    m_blendMode ,m_imageBlendMode : TAggBlendMode;
 
    m_imageBlendColor : TAggColor;
 
    m_scanline   : scanline_u8;
    m_rasterizer : rasterizer_scanline_aa;
 
    m_masterAlpha ,m_antiAliasGamma : double;
 
    m_fillColor ,m_lineColor : TAggColor;
 
    m_fillGradient ,m_lineGradient : pod_auto_array;
 
    m_lineCap  : TAggLineCap;
    m_lineJoin : TAggLineJoin;
 
    m_fillGradientFlag ,m_lineGradientFlag : TAggGradient;
 
    m_fillGradientMatrix ,m_lineGradientMatrix : trans_affine;
 
    m_fillGradientD1 ,
    m_lineGradientD1 ,
    m_fillGradientD2 ,
    m_lineGradientD2 ,
    m_textAngle      : double;
    m_textAlignX     ,
    m_textAlignY     : TAggTextAlignment;
    m_textHints      : boolean;
    m_fontHeight     ,
    m_fontAscent     ,
    m_fontDescent    : double;
    m_fontCacheType  : TAggFontCacheType;
 
    m_imageFilter    : TAggImageFilter;
    m_imageResample  : TAggImageResample;
    m_imageFilterLut : image_filter_lut;
 
    m_fillGradientInterpolator ,
    m_lineGradientInterpolator : span_interpolator_linear;
 
    m_linearGradientFunction : gradient_x;
    m_radialGradientFunction : gradient_circle;
 
    m_lineWidth   : double;
    m_evenOddFlag : boolean;
 
    m_path      : path_storage;
    m_transform : trans_affine;
 
    m_convCurve  : conv_curve;
    m_convStroke : conv_stroke;
    m_convDash: conv_dash;
 
    m_pathTransform ,m_strokeTransform : conv_transform;
 
    m_imageFlip : boolean;
   
    {$IFNDEF AGG2D_NO_FONT}
    {$IFDEF AGG2D_USE_FREETYPE}
    m_fontEngine       : TAggFontEngine;
    m_fontCacheManager : font_cache_manager;
    {$ENDIF}
    {$IFDEF AGG2D_USE_RASTERFONTS}
    m_fontGlyph        : glyph_raster_bin;
    m_font_flip_y      : boolean;
    {$ENDIF}
    {$ENDIF}
 
    // Other Pascal-specific members
    m_gammaNone  : gamma_none;
    m_gammaAgg2D : TAggRasterizerGamma;
 
    m_ifBilinear    : image_filter_bilinear;
    m_ifHanning     : image_filter_hanning;
    m_ifHermite     : image_filter_hermite;
    m_ifQuadric     : image_filter_quadric;
    m_ifBicubic     : image_filter_bicubic;
    m_ifCatrom      : image_filter_catrom;
    m_ifSpline16    : image_filter_spline16;
    m_ifSpline36    : image_filter_spline36;
    m_ifBlackman144 : image_filter_blackman144;
    
    {Agg2D methods}
    procedure render(fillColor_ : boolean ); overload;
    procedure render(ras : PAggFontRasterizer; sl : PAggFontScanline ); overload;
    
    procedure addLine(x1 ,y1 ,x2 ,y2 : double );
    procedure updateRasterizerGamma;
    procedure renderImage(img : PAggImage; x1 ,y1 ,x2 ,y2 : integer; parl : PDouble );
  protected
    {fpGUI properties}
    FImg: TfpgUltiboImage;
    
    {fpGUI methods}
    procedure   DoSetFontRes(fntres: TfpgFontResourceBase); override;
    procedure   DoSetTextColor(cl: TfpgColor); override;
    procedure   DoSetColor(cl: TfpgColor); override;
    procedure   DoSetLineStyle(awidth: integer; astyle: TfpgLineStyle); override;
    procedure   DoGetWinRect(out r: TfpgRect); override;
    procedure   DoFillRectangle(x, y, w, h: TfpgCoord); override;
    procedure   DoXORFillRectangle(col: TfpgColor; x, y, w, h: TfpgCoord); override;
    procedure   DoFillTriangle(x1, y1, x2, y2, x3, y3: TfpgCoord); override;
    procedure   DoDrawRectangle(x, y, w, h: TfpgCoord); override;
    procedure   DoDrawLine(x1, y1, x2, y2: TfpgCoord); override;
    procedure   DoDrawImagePart(x, y: TfpgCoord; img: TfpgImageBase; xi, yi, w, h: integer); override;
    procedure   DoDrawString(x, y: TfpgCoord; const txt: string); override;
    procedure   DoSetClipRect(const ARect: TfpgRect); override;
    function    DoGetClipRect: TfpgRect; override;
    procedure   DoAddClipRect(const ARect: TfpgRect); override;
    procedure   DoClearClipRect; override;
    procedure   DoBeginDraw(awin: TfpgWindowBase; buffered: boolean); override;
    procedure   DoPutBufferToScreen(x, y, w, h: TfpgCoord); override;
    procedure   DoEndDraw; override;
    function    GetPixel(X, Y: integer): TfpgColor; override;
    procedure   SetPixel(X, Y: integer; const AValue: TfpgColor); override;
    procedure   DoDrawArc(x, y, w, h: TfpgCoord; a1, a2: Extended); override;
    procedure   DoFillArc(x, y, w, h: TfpgCoord; a1, a2: Extended); override;
    procedure   DoDrawPolygon(Points: PPoint; NumPts: Integer; Winding: boolean = False); override;
  public
    {fpGUI methods}
    constructor Create(awin: TfpgWindowBase); override;
    destructor  Destroy; override;
    
    {Agg2D methods}
    {Agg2D Vector Graphics Engine Initialization}
    function  Attach(bitmap : TfpgUltiboImage; flip_y : boolean = false ) : boolean;
    
    procedure ClearAll(c : TAggColor ); overload;
    procedure ClearAll(r ,g ,b : byte; a : byte = 255 ); overload;
    procedure FillAll(c: TAggColor); overload;
    procedure FillAll(r, g, b: byte; a: byte = 255); overload;
    
    {Agg2D Master Rendering Properties}
    procedure BlendMode(m : TAggBlendMode ); overload;
    function  BlendMode : TAggBlendMode; overload;
    
    procedure MasterAlpha(a : double ); overload;
    function  MasterAlpha : double; overload;
    
    procedure AntiAliasGamma(g : double ); overload;
    function  AntiAliasGamma : double; overload;
    
    procedure FillColor(c : TAggColor ); overload;
    procedure FillColor(r ,g ,b : byte; a : byte = 255 ); overload;
    procedure NoFill;
    
    procedure LineColor(c : TAggColor ); overload;
    procedure LineColor(r ,g ,b : byte; a : byte = 255 ); overload;
    procedure NoLine;
    
    function  FillColor : TAggColor; overload;
    function  LineColor : TAggColor; overload;
    
    procedure FillLinearGradient(const x1 ,y1 ,x2 ,y2 : double; c1 ,c2 : TAggColor; profile : double = 1.0 );
    procedure LineLinearGradient(const x1 ,y1 ,x2 ,y2 : double; c1 ,c2 : TAggColor; profile : double = 1.0 );
    
    procedure FillRadialGradient(const x ,y ,r : double; c1 ,c2 : TAggColor; profile : double = 1.0 ); overload;
    procedure LineRadialGradient(const x ,y ,r : double; c1 ,c2 : TAggColor; profile : double = 1.0 ); overload;
    
    procedure FillRadialGradient(const x ,y ,r : double; c1 ,c2 ,c3 : TAggColor ); overload;
    procedure LineRadialGradient(const x ,y ,r : double; c1 ,c2 ,c3 : TAggColor ); overload;
    
    procedure FillRadialGradient(const x ,y ,r : double ); overload;
    procedure LineRadialGradient(const x ,y ,r : double ); overload;
    
    procedure LineWidth(const w : double ); overload;
    function  LineWidth : double; overload;
    
    procedure LineCap(cap : TAggLineCap ); overload;
    function  LineCap : TAggLineCap; overload;
    
    procedure LineJoin(join : TAggLineJoin ); overload;
    function  LineJoin : TAggLineJoin; overload;
    
    procedure FillEvenOdd(evenOddFlag : boolean ); overload;
    function  FillEvenOdd : boolean; overload;
    
    {Agg2D Affine Transformations}
    function  Transformations : TAggTransformations; overload;
    procedure Transformations(tr : PAggTransformations ); overload;
    procedure ResetTransformations;
    
    procedure Affine(const tr : PAggAffine ); overload;
    procedure Affine(const tr : PAggTransformations ); overload;
    
    procedure Rotate   (const angle : double );
    procedure Scale    (const sx ,sy : double );
    procedure Skew     (const sx ,sy : double );
    procedure Translate(const x ,y : double );
    
    procedure Parallelogram(const x1 ,y1 ,x2 ,y2 : double; para : PDouble );
    
    procedure Viewport(const worldX1  ,worldY1  ,worldX2  ,worldY2 , screenX1 ,screenY1 ,screenX2 ,screenY2 : double; const opt : TAggViewportOption = AGG_XMidYMid );
    
    {Agg2D Coordinates Conversions}
    procedure WorldToScreen(x ,y : PDouble ); overload;
    procedure ScreenToWorld(x ,y : PDouble ); overload;
    function  WorldToScreen(scalar : double ) : double; overload;
    function  ScreenToWorld(scalar : double ) : double; overload;
    
    procedure AlignPoint(x ,y : PDouble );
    
    {Agg2D Clipping}
    procedure ClipBox(x1 ,y1 ,x2 ,y2 : double ); overload;
    function  ClipBox : TAggRectD; overload;
    
    procedure ClearClipBox(c : TAggColor ); overload;
    procedure ClearClipBox(r ,g ,b : byte; a : byte = 255 ); overload;
    
    function  InBox(worldX ,worldY : double ) : boolean;
    
    {Agg2D Basic Shapes}
    procedure Line(const x1, y1, x2, y2: double; AFixAlignment: boolean = false );
    procedure Triangle (const x1 ,y1 ,x2 ,y2 ,x3 ,y3 : double );
    procedure Rectangle(const x1 ,y1 ,x2 ,y2 : double; AFixAlignment: boolean = false);
    
    procedure RoundedRect(const x1 ,y1 ,x2 ,y2 ,r : double ); overload;
    procedure RoundedRect(const x1 ,y1 ,x2 ,y2 ,rx ,ry : double ); overload;
    procedure RoundedRect(const x1 ,y1 ,x2 ,y2 ,rxBottom ,ryBottom ,rxTop ,ryTop : double ); overload;
    
    procedure Ellipse(const cx ,cy ,rx ,ry : double );
    
    procedure Arc (const cx ,cy ,rx ,ry ,start ,sweep : double );
    procedure Star(const cx ,cy ,r1 ,r2 ,startAngle : double; const numRays : integer );
    
    procedure Curve(const x1 ,y1 ,x2 ,y2 ,x3 ,y3 : double ); overload;
    procedure Curve(const x1 ,y1 ,x2 ,y2 ,x3 ,y3 ,x4 ,y4 : double ); overload;
    
    procedure Polygon (const xy : PDouble; numPoints : integer );
    procedure Polyline(const xy : PDouble; numPoints : integer );
    
    {Agg2D Path Commands}
    procedure ResetPath;
    
    procedure MoveTo (const x ,y : double );
    procedure MoveRel(const dx ,dy : double );
    
    procedure LineTo (const x ,y : double );
    procedure LineRel(const dx ,dy : double );
    
    procedure HorLineTo (const x : double );
    procedure HorLineRel(const dx : double );
    
    procedure VerLineTo (const y : double );
    procedure VerLineRel(const dy : double );
    
    procedure ArcTo(rx ,ry ,angle : double; largeArcFlag ,sweepFlag : boolean; x ,y : double );
    
    procedure ArcRel(rx ,ry ,angle : double; largeArcFlag ,sweepFlag : boolean; dx ,dy : double );
    
    procedure QuadricCurveTo (xCtrl ,yCtrl ,xTo ,yTo : double ); overload;
    procedure QuadricCurveRel(dxCtrl ,dyCtrl ,dxTo ,dyTo : double ); overload;
    procedure QuadricCurveTo (xTo ,yTo : double ); overload;
    procedure QuadricCurveRel(dxTo ,dyTo : double ); overload;
    
    procedure CubicCurveTo (xCtrl1 ,yCtrl1 ,xCtrl2 ,yCtrl2 ,xTo ,yTo : double ); overload;
    procedure CubicCurveRel(dxCtrl1 ,dyCtrl1 ,dxCtrl2 ,dyCtrl2 ,dxTo ,dyTo : double ); overload;
    procedure CubicCurveTo (xCtrl2 ,yCtrl2 ,xTo ,yTo : double ); overload;
    procedure CubicCurveRel(dxCtrl2 ,dyCtrl2 ,dxTo ,dyTo : double ); overload;
    
    procedure AddEllipse(cx ,cy ,rx ,ry : double; dir : TAggDirection );
    procedure ClosePolygon;
    
    procedure DrawPath(flag : TAggDrawPathFlag = AGG_FillAndStroke );
    
    {Agg2D Text Rendering}
    procedure FlipText(const flip : boolean );
    
    procedure FontSet(fileName : AnsiString; height : double; bold : boolean = false; italic : boolean = false; cache : TAggFontCacheType = AGG_VectorFontCache; angle : double = 0.0 );
    
    function  FontHeight : double;
    
    procedure TextAlignment(alignX ,alignY : TAggTextAlignment );
    
    function  TextHints : boolean; overload;
    procedure TextHints(hints : boolean ); overload;
    function  TextWidth(str : AnsiString ) : double;
    
    procedure TextRender(x ,y : double; str : AnsiString; roundOff : boolean = false; ddx : double = 0.0; ddy : double = 0.0 );
    
    {Agg2D Image Rendering}
    procedure ImageFilter(f : TAggImageFilter ); overload;
    function  ImageFilter : TAggImageFilter; overload;
    
    procedure ImageResample(f : TAggImageResample ); overload;
    function  ImageResample : TAggImageResample; overload;
    
    procedure ImageFlip(f : boolean );
    
    procedure TransformImage(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; dstX1 ,dstY1 ,dstX2 ,dstY2 : double ); overload;
    procedure TransformImage( bitmap : TfpgUltiboImage; dstX1 ,dstY1 ,dstX2 ,dstY2 : double ); overload;
    procedure TransformImage(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; parallelo : PDouble ); overload;
    procedure TransformImage(bitmap : TfpgUltiboImage; parallelo : PDouble ); overload;
    
    procedure TransformImagePath(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; dstX1 ,dstY1 ,dstX2 ,dstY2 : double ); overload;
    procedure TransformImagePath(bitmap : TfpgUltiboImage; dstX1 ,dstY1 ,dstX2 ,dstY2 : double ); overload;
    procedure TransformImagePath(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; parallelo : PDouble ); overload;
    procedure TransformImagePath(bitmap : TfpgUltiboImage; parallelo : PDouble ); overload;
    
    procedure CopyImage(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; dstX ,dstY : double ); overload;
    procedure CopyImage(bitmap : TfpgUltiboImage; dstX ,dstY : double ); overload;
  end;
  
  TfpgUltiboWindow = class(TfpgWindowBase)
  private
  
  protected
    FWinHandle: TfpgWinHandle;
    FModalForWin: TfpgUltiboWindow;
    
    procedure   DoAllocateWindowHandle(AParent: TfpgWindowBase); override;
    procedure   DoReleaseWindowHandle; override;
    procedure   DoRemoveWindowLookup; override;
    procedure   DoSetWindowVisible(const AValue: Boolean); override;
    function    HandleIsValid: boolean; override;
    procedure   DoUpdateWindowPosition; override;
    procedure   DoMoveWindow(const x: TfpgCoord; const y: TfpgCoord); override;
    function    DoWindowToScreen(ASource: TfpgWindowBase; const AScreenPos: TPoint): TPoint; override;
    //procedure MoveToScreenCenter; override;
    procedure   DoSetWindowTitle(const ATitle: string); override;
    procedure   DoSetMouseCursor; override;
    procedure   DoDNDEnabled(const AValue: boolean); override;
    procedure   DoAcceptDrops(const AValue: boolean); override;
    procedure   DoDragStartDetected; override;
    function    GetWindowState: TfpgWindowState; override;
    property    WinHandle: TfpgWinHandle read FWinHandle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   ActivateWindow; override;
    procedure   CaptureMouse; override;
    procedure   ReleaseMouse; override;
    procedure   SetFullscreen(AValue: Boolean); override;
    procedure   BringToFront; override;
  end;
  
  TfpgUltiboApplication = class(TfpgApplicationBase)
  private
    FNextHandle:TfpgWinHandle;
    procedure   DoWakeMainThread(Sender: TObject);
  protected
    FParent:TfpgUltiboApplication;
    FFramebuffer:PFramebufferDevice;

    function    DoGetWindowHandle:TfpgWinHandle;
    function    DoGetFontFaceList: TStringList; override;
    procedure   DoWaitWindowMessage(atimeoutms: integer); override;
    function    MessagesPending: boolean; override;
    
    procedure   DoPutFramebufferRect(x, y, w, h: TfpgCoord; src: Pointer; stride: LongWord);
  public
    constructor Create(const AParams: string); override;
    destructor  Destroy; override;
    procedure   DoFlush;
    function    GetScreenWidth: TfpgCoord; override;
    function    GetScreenHeight: TfpgCoord; override;
    function    GetScreenPixelColor(APos: TPoint): TfpgColor; override;
    function    Screen_dpi_x: integer; override;
    function    Screen_dpi_y: integer; override;
    function    Screen_dpi: integer; override;
    property    Framebuffer:PFramebufferDevice read FFramebuffer;
  end;


  TfpgUltiboClipboard = class(TfpgClipboardBase)
  protected
    FClipboardText: TfpgString;
    function    DoGetText: TfpgString; override;
    procedure   DoSetText(const AValue: TfpgString); override;
    procedure   InitClipboard; override;
  end;

  
  TfpgUltiboFileList = class(TfpgFileListBase)
  private
    function    EncodeAttributesString(attrs: longword): TFileModeString;
  protected
    function    InitializeEntry(sr: TSearchRec): TFileEntry; override;
    procedure   PopulateSpecialDirs(const aDirectory: TfpgString); override;
  public
    constructor Create; override;
  end;

  
  TfpgUltiboMimeDataBase = class(TfpgMimeDataBase)

  end;

  
  TfpgUltiboDrag = class(TfpgDragBase)
  private
  
  protected
    FSource: TfpgUltiboWindow;
    function GetSource: TfpgUltiboWindow; virtual;
  public
    destructor Destroy; override;
    function Execute(const ADropActions: TfpgDropActions; const ADefaultAction: TfpgDropAction=daCopy): TfpgDropAction; override;
  end;
  
  
  TfpgUltiboTimer = class(TfpgBaseTimer)
  private
    FHandle: THandle;
  protected
    procedure   SetEnabled(const AValue: boolean); override;
  public
    constructor Create(AInterval: integer); override;
  end;

  
  TfpgUltiboSystemTrayIcon = class(TfpgComponent)
  public
    constructor Create(AOwner: TComponent); override;
    procedure   Show;
    procedure   Hide;
    function    IsSystemTrayAvailable: boolean;
    function    SupportsMessages: boolean;
  end;
  

implementation

uses
  fpg_main,
  fpg_widget,
  fpg_popupwindow,
  fpg_stringutils,
  fpg_form,
  Math,
  Agg2D;

{ Internal variables}
var
 DefaultApplication:TfpgApplication;

{ Agg2D variables}
var
 g_approxScale : double = 2.0; 

{ Agg2D types}
type
 PAggSpanConvImageBlend = ^TAggSpanConvImageBlend;
 TAggSpanConvImageBlend = object(span_convertor )
  private
   m_mode  : TAggBlendMode;
   m_color : TAggColor;
   m_pixel : pixel_formats_ptr; // m_pixFormatCompPre

  public
   constructor Construct(m : TAggBlendMode; c : TAggColor; p : pixel_formats_ptr );

   procedure convert(span : aggclr_ptr; x ,y : int; len : unsigned ); virtual;
  end;
 
{ Agg2D functions}
procedure Agg2DRenderer_render(gr : TfpgUltiboCanvas; renBase : renderer_base_ptr; renSolid : renderer_scanline_aa_solid_ptr; fillColor_ : boolean ); overload;
var
 span : span_gradient;
 ren  : renderer_scanline_aa;
 clr  : aggclr;
begin
 if (fillColor_ and
     (gr.m_fillGradientFlag = AGG_Linear ) ) or
    (not fillColor_ and
     (gr.m_lineGradientFlag = AGG_Linear ) ) then
  if fillColor_ then
   begin
    span.Construct(
     @gr.m_allocator ,
     @gr.m_fillGradientInterpolator ,
     @gr.m_linearGradientFunction ,
     @gr.m_fillGradient ,
     gr.m_fillGradientD1 ,
     gr.m_fillGradientD2 );

    ren.Construct   (renBase ,@span );
    render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ren );
   end
  else
   begin
    span.Construct(
     @gr.m_allocator ,
     @gr.m_lineGradientInterpolator ,
     @gr.m_linearGradientFunction ,
     @gr.m_lineGradient ,
     gr.m_lineGradientD1 ,
     gr.m_lineGradientD2 );

    ren.Construct   (renBase ,@span );
    render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ren );
   end
 else
  if (fillColor_ and
      (gr.m_fillGradientFlag = AGG_Radial ) ) or
     (not fillColor_ and
      (gr.m_lineGradientFlag = AGG_Radial ) ) then
   if fillColor_ then
    begin
     span.Construct(
      @gr.m_allocator ,
      @gr.m_fillGradientInterpolator ,
      @gr.m_radialGradientFunction ,
      @gr.m_fillGradient ,
      gr.m_fillGradientD1 ,
      gr.m_fillGradientD2 );

      ren.Construct   (renBase ,@span );
      render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ren );
    end
   else
    begin
     span.Construct(
      @gr.m_allocator ,
      @gr.m_lineGradientInterpolator ,
      @gr.m_radialGradientFunction ,
      @gr.m_lineGradient ,
      gr.m_lineGradientD1 ,
      gr.m_lineGradientD2 );

     ren.Construct   (renBase ,@span );
     render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ren );
    end
  else
   begin
    if fillColor_ then
     clr.Construct(gr.m_fillColor )
    else
     clr.Construct(gr.m_lineColor );

    renSolid.color_ (@clr );
    render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,renSolid );
   end;
end;

procedure Agg2DRenderer_render(gr : TfpgUltiboCanvas; renBase : renderer_base_ptr; renSolid : renderer_scanline_aa_solid_ptr; ras : gray8_adaptor_type_ptr; sl : gray8_scanline_type_ptr ); overload;
var
 span : span_gradient;
 ren  : renderer_scanline_aa;
 clr  : aggclr;
begin
 if gr.m_fillGradientFlag = AGG_Linear then
  begin
   span.Construct(
    @gr.m_allocator ,
    @gr.m_fillGradientInterpolator ,
    @gr.m_linearGradientFunction ,
    @gr.m_fillGradient ,
    gr.m_fillGradientD1 ,
    gr.m_fillGradientD2 );

   ren.Construct   (renBase ,@span );
   render_scanlines(ras ,sl ,@ren );
  end
 else
  if gr.m_fillGradientFlag = AGG_Radial then
   begin
    span.Construct(
     @gr.m_allocator ,
     @gr.m_fillGradientInterpolator ,
     @gr.m_radialGradientFunction ,
     @gr.m_fillGradient ,
     gr.m_fillGradientD1 ,
     gr.m_fillGradientD2 );

    ren.Construct   (renBase ,@span );
    render_scanlines(ras ,sl ,@ren );
   end
  else
   begin
    clr.Construct   (gr.m_fillColor );
    renSolid.color_ (@clr );
    render_scanlines(ras ,sl ,renSolid );
   end;
end;

procedure Agg2DRenderer_renderImage(gr : TfpgUltiboCanvas; img : PAggImage; renBase : renderer_base_ptr; interpolator : span_interpolator_linear_ptr );
var
 blend : TAggSpanConvImageBlend;

 si : span_image_filter_rgba;
 sg : span_image_filter_rgba_nn;
 sb : span_image_filter_rgba_bilinear;
 s2 : span_image_filter_rgba_2x2;
 sa : span_image_resample_rgba_affine;
 sc : span_converter;
 ri : renderer_scanline_aa;

 clr : aggclr;

 resample : boolean;

 sx ,sy : double;
begin
 case gr.m_pixf of
  pf32bit :
   blend.Construct(gr.m_imageBlendMode ,gr.m_imageBlendColor ,@gr.m_pixFormatCompPre );
  else
   blend.Construct(gr.m_imageBlendMode ,gr.m_imageBlendColor ,NIL );
 end;

 if gr.m_imageFilter = AGG_NoFilter then
  begin
   clr.ConstrInt(0 ,0 ,0 ,0 );
   sg.Construct (@gr.m_allocator ,@img.renBuf ,@clr ,interpolator ,rgba_order );
   sc.Construct (@sg ,@blend );
   ri.Construct (renBase ,@sc );

   render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ri );
  end
 else
  begin
   resample:=gr.m_imageResample = AGG_ResampleAlways;

   if gr.m_imageResample = AGG_ResampleOnZoomOut then
    begin
     interpolator._transformer.scaling_abs(@sx ,@sy );

     if (sx > 1.125 ) or
        (sy > 1.125 ) then
      resample:=true;
    end;

   if resample then
    begin
     clr.ConstrInt(0 ,0 ,0 ,0 );
     sa.Construct(
      @gr.m_allocator ,
      @img.renBuf ,
      @clr ,
      interpolator ,
      @gr.m_imageFilterLut ,
      rgba_order );

     sc.Construct(@sa ,@blend );
     ri.Construct(renBase ,@sc );

     render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ri );
    end
   else
    if gr.m_imageFilter = AGG_Bilinear then
     begin
      clr.ConstrInt(0 ,0 ,0 ,0 );
      sb.Construct(
       @gr.m_allocator ,
       @img.renBuf ,
       @clr ,
       interpolator ,
       rgba_order );

      sc.Construct(@sb ,@blend );
      ri.Construct(renBase ,@sc );

      render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ri );
     end
    else
     if gr.m_imageFilterLut.diameter = 2 then
      begin
       clr.ConstrInt(0 ,0 ,0 ,0 );
       s2.Construct(
        @gr.m_allocator ,
        @img.renBuf ,
        @clr ,
        interpolator,
        @gr.m_imageFilterLut ,
        rgba_order );

       sc.Construct(@s2 ,@blend );
       ri.Construct(renBase ,@sc );

       render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ri );
      end
     else
      begin
       clr.ConstrInt(0 ,0 ,0 ,0 );
       si.Construct(
        @gr.m_allocator ,
        @img.renBuf ,
        @clr ,
        interpolator ,
        @gr.m_imageFilterLut ,
        rgba_order );

       sc.Construct(@si ,@blend );
       ri.Construct(renBase ,@sc );

       render_scanlines(@gr.m_rasterizer ,@gr.m_scanline ,@ri );

      end;
  end;
end;

function ColorDepthToPixelFormat(const AColorDepth: integer): TPixelFormat;
begin
  case AColorDepth of
    8: Result := pf8bit;
    16: Result := pf16bit;
    24: Result := pf24bit;
    32: Result := pf32bit;
    else
      raise Exception.Create('Unknown ColorDepth parameter in ColorDepthToPixelFormat');
  end;
end;
 
 
{ TAggSpanConvImageBlend }
 
constructor TAggSpanConvImageBlend.Construct(m : TAggBlendMode; c : TAggColor; p : pixel_formats_ptr );
begin
 m_mode :=m;
 m_color:=c;
 m_pixel:=p;
end;

procedure TAggSpanConvImageBlend.convert(span : aggclr_ptr; x ,y : int; len : unsigned );
var
 l2 ,a : unsigned;

 s2 : PAggColor;
begin
 if (m_mode <> AGG_BlendDst ) and
    (m_pixel <> NIL ) then
  begin{!}
   l2:=len;
   s2:=PAggColor(span );

   repeat
    comp_op_adaptor_clip_to_dst_rgba_pre(
     m_pixel ,
     unsigned(m_mode ) ,
     int8u_ptr(s2 ) ,
     m_color.r ,
     m_color.g ,
     m_color.b ,
     base_mask ,
     cover_full );

    inc(ptrcomp(s2 ) ,sizeof(aggclr ) );
    dec(l2 );

   until l2 = 0;

  end;

 if m_color.a < base_mask then
  begin
   l2:=len;
   s2:=PAggColor(span );
   a :=m_color.a;

   repeat
    s2.r:=(s2.r * a ) shr base_shift;
    s2.g:=(s2.g * a ) shr base_shift;
    s2.b:=(s2.b * a ) shr base_shift;
    s2.a:=(s2.a * a ) shr base_shift;

    inc(ptrcomp(s2 ) ,sizeof(aggclr ) );
    dec(l2 );

   until l2 = 0;

  end;
end;

 
{ TAggRasterizerGamma }
constructor TAggRasterizerGamma.Construct(alpha ,gamma : double );
begin
 m_alpha.Construct(alpha );
 m_gamma.Construct(gamma );
end;

function TAggRasterizerGamma.func_operator_gamma(x : double ) : double;
begin
 result:=m_alpha.func_operator_gamma(m_gamma.func_operator_gamma(x ) );
end;


{ TAggImage }
constructor TAggImage.Construct;
begin
 renBuf.Construct;
end;

destructor TAggImage.Destruct;
begin
 renBuf.Destruct;
end;

function TAggImage.attach(bitmap : TfpgUltiboImage; flip : boolean ) : boolean;
var
 buffer : pointer;
 stride : integer;
begin
 result:=false;

 if Assigned(bitmap ) (* and
    not bitmap.Empty *)then        {$Note Implement TfpgImage.Empty }
  case bitmap.ColorDepth of
   32 :
    begin
    { Rendering Buffer }
     stride:=integer(TfpgImage(bitmap).ScanLine[1 ] ) - integer(TfpgImage(bitmap).ScanLine[0 ] );

     if stride < 0 then
      buffer:=TfpgImage(bitmap).ScanLine[bitmap.Height - 1 ]
     else
      buffer:=TfpgImage(bitmap).ScanLine[0 ];

     if flip then
      stride:=stride * -1;

     renBuf.attach(
      buffer ,
      bitmap.Width ,
      bitmap.Height ,
      stride );

    { OK }
     result:=true;
    end;
  end;
end;

function TAggImage.width : int;
begin
 result:=renBuf._width;
end;

function TAggImage.height : int;
begin
 result:=renBuf._height;
end;

 
{ TfpgUltiboFontResource }

constructor TfpgUltiboFontResource.Create(const afontdesc: string);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.Create afontdesc=' + afontdesc); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create;
 
 {$IFDEF AGG2D_USE_FREETYPE}
 FFontData:=OpenFontByDesc(afontdesc);
 //Ultibo To Do 
 {$ENDIF}
 {$IFDEF AGG2D_USE_RASTERFONTS}
 FFontData:=GetFontByDesc(afontdesc);
 {$ENDIF}
end;

destructor TfpgUltiboFontResource.Destroy;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.Destroy'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
 inherited Destroy;
end;

{$IFDEF AGG2D_USE_FREETYPE}
function TfpgUltiboFontResource.OpenFontByDesc(const desc: string): THandle;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.OpenFontByDesc desc=' + desc); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;
{$ENDIF}

{$IFDEF AGG2D_USE_RASTERFONTS}
function TfpgUltiboFontResource.GetFontByDesc(const desc: string): int8u_ptr;
type
 font_type = record
  font:int8u_ptr;
  name:PChar;
 end;
 
const
 font_count = 35;
 
 fonts:array[0..font_count - 1] of font_type = (
  (font:@gse4x6;               name:'gse4x6'               ) ,
  (font:@gse4x8;               name:'gse4x8'               ) ,
  (font:@gse5x7;               name:'gse5x7'               ) ,
  (font:@gse5x9;               name:'gse5x9'              ) ,
  (font:@gse6x9;               name:'gse6x9'               ) ,
  (font:@gse6x12;              name:'gse6x12'              ) ,
  (font:@gse7x11;              name:'gse7x11'              ) ,
  (font:@gse7x11_bold;         name:'gse7x11_bold'         ) ,
  (font:@gse7x15;              name:'gse7x15'              ) ,
  (font:@gse7x15_bold;         name:'gse7x15_bold'         ) ,
  (font:@gse8x16;              name:'gse8x16'              ) ,
  (font:@gse8x16_bold;         name:'gse8x16_bold'         ) ,
  (font:@mcs11_prop;           name:'mcs11_prop'           ) ,
  (font:@mcs11_prop_condensed; name:'mcs11_prop_condensed' ) ,
  (font:@mcs12_prop;           name:'mcs12_prop'           ) ,
  (font:@mcs13_prop;           name:'mcs13_prop'           ) ,
  (font:@mcs5x10_mono;         name:'mcs5x10_mono'         ) ,
  (font:@mcs5x11_mono;         name:'mcs5x11_mono'         ) ,
  (font:@mcs6x10_mono;         name:'mcs6x10_mono'         ) ,
  (font:@mcs6x11_mono;         name:'mcs6x11_mono'         ) ,
  (font:@mcs7x12_mono_high;    name:'mcs7x12_mono_high'    ) ,
  (font:@mcs7x12_mono_low;     name:'mcs7x12_mono_low'     ) ,
  (font:@verdana12;            name:'verdana12'            ) ,
  (font:@verdana12_bold;       name:'verdana12_bold'       ) ,
  (font:@verdana13;            name:'verdana13'            ) ,
  (font:@verdana13_bold;       name:'verdana13_bold'       ) ,
  (font:@verdana14;            name:'verdana14'            ) ,
  (font:@verdana14_bold;       name:'verdana14_bold'       ) ,
  (font:@verdana16;            name:'verdana16'            ) ,
  (font:@verdana16_bold;       name:'verdana16_bold'       ) ,
  (font:@verdana17;            name:'verdana17'            ) ,
  (font:@verdana17_bold;       name:'verdana17_bold'       ) ,
  (font:@verdana18;            name:'verdana18'            ) ,
  (font:@verdana18_bold;       name:'verdana18_bold'       ) ,
  (font:NIL;                   name:NIL ) );

var
 Count:LongWord;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetFontByDesc desc=' + desc); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=nil;
 
 for Count:=0 to font_count - 1 do
  begin
   if fonts[Count].font <> nil then
    begin
     if Uppercase(fonts[Count].name) = Uppercase(desc) then
      begin
       Result:=fonts[Count].font;
       Exit;
      end;
    end;  
  end;
end;
{$ENDIF}

function TfpgUltiboFontResource.HandleIsValid: boolean;
{$IFDEF AGG2D_USE_FREETYPE}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.HandleIsValid'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=FFontData <> 0;
end;
{$ENDIF}
{$IFDEF AGG2D_USE_RASTERFONTS}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.HandleIsValid'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=FFontData <> nil;
end;
{$ENDIF}

function TfpgUltiboFontResource.GetAscent: integer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetAscent'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;

function TfpgUltiboFontResource.GetDescent: integer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetDescent'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;

function TfpgUltiboFontResource.GetHeight: integer;
{$IFDEF AGG2D_USE_FREETYPE}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetHeight'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 

 //Ultibo To Do
end; 
{$ENDIF}
{$IFDEF AGG2D_USE_RASTERFONTS}
var
 glyph:glyph_raster_bin;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetHeight'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=0;
 
 if FFontData = nil then Exit;
 
 glyph.Construct(FFontData);
 
 Result:=Trunc(glyph.height);
end;
{$ENDIF}

function TfpgUltiboFontResource.GetTextWidth(const txt: string): integer;
{$IFDEF AGG2D_USE_FREETYPE}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetTextWidth'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;
{$ENDIF}
{$IFDEF AGG2D_USE_RASTERFONTS}
var
 glyph:glyph_raster_bin;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFontResource.GetTextWidth'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=0;
 
 if FFontData = nil then Exit;
 
 glyph.Construct(FFontData);
 
 Result:=Trunc(glyph.width(PChar(txt)));
end;
  
{$ENDIF}
  
{ TfpgUltiboImage }

constructor TfpgUltiboImage.Create;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboImage.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create;
 //Ultibo To Do //Nothing ?
end;

procedure TfpgUltiboImage.DoFreeImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboImage.DoFreeImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do //Nothing ?
end;

procedure TfpgUltiboImage.DoInitImage(acolordepth, awidth, aheight: integer; aimgdata: Pointer);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboImage.DoInitImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do //Nothing ?
end;

procedure TfpgUltiboImage.DoInitImageMask(awidth, aheight: integer; aimgdata: Pointer);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboImage.DoInitImageMask'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do //Nothing ?
end;

  
{ TfpgUltiboCanvas }
procedure TfpgUltiboCanvas.render(fillColor_ : boolean );
begin 
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.render'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if (m_blendMode = AGG_BlendAlpha ) or
    (m_pixf = pf24bit ) then
  Agg2DRenderer_render(self ,@m_renBase ,@m_renSolid ,fillColor_ )
 else
  Agg2DRenderer_render(self ,@m_renBaseComp ,@m_renSolidComp ,fillColor_ );

end;

procedure TfpgUltiboCanvas.render(ras : PAggFontRasterizer; sl : PAggFontScanline );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.render'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if (m_blendMode = AGG_BlendAlpha ) or
    (m_pixf = pf24bit ) then
  Agg2DRenderer_render(self ,@m_renBase ,@m_renSolid ,ras ,sl )
 else
  Agg2DRenderer_render(self ,@m_renBaseComp ,@m_renSolidComp ,ras ,sl );

end;

procedure TfpgUltiboCanvas.addLine(x1 ,y1 ,x2 ,y2 : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.addLine'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.move_to(x1 ,y1 );
 m_path.line_to(x2 ,y2 );
end;

procedure TfpgUltiboCanvas.updateRasterizerGamma;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.updateRasterizerGamma'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_gammaAgg2D.Construct(m_masterAlpha ,m_antiAliasGamma );
 m_rasterizer.gamma    (@m_gammaAgg2D );
end;

procedure TfpgUltiboCanvas.renderImage(img : PAggImage; x1 ,y1 ,x2 ,y2 : integer;  parl : PDouble );
var
 mtx : trans_affine;

 interpolator : span_interpolator_linear;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.renderImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 mtx.Construct(x1 ,y1 ,x2 ,y2 ,parallelo_ptr(parl ) );
 mtx.multiply (@m_transform );
 mtx.invert;

 m_rasterizer.reset;
 m_rasterizer.add_path(@m_pathTransform );

 interpolator.Construct(@mtx );

 if (m_blendMode = AGG_BlendAlpha ) or
    (m_pixf = pf24bit ) then
  Agg2DRenderer_renderImage(self ,img ,@m_renBasePre ,@interpolator )
 else
  Agg2DRenderer_renderImage(self ,img ,@m_renBaseCompPre ,@interpolator );
end;

procedure TfpgUltiboCanvas.DoSetFontRes(fntres: TfpgFontResourceBase);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoSetFontRes'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if fntres = nil then Exit; 
  
 {$IFDEF AGG2D_USE_FREETYPE}
 //Ultibo To Do //Needs FreeType
 {$ENDIF}
 {$IFDEF AGG2D_USE_RASTERFONTS}
 m_fontGlyph.font_(TfpgUltiboFontResource(fntres).FFontData);
 FontSet('',m_fontGlyph.height);
 {$ENDIF}
end;

procedure TfpgUltiboCanvas.DoSetTextColor(cl: TfpgColor);
var
  t: TRGBTriple;
  c: TfpgColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoSetTextColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 c := fpgColorToRGB(cl);
 t := fpgColorToRGBTriple(c);

 FillColor(t.Red, t.Green, t.Blue, t.Alpha);
end;

procedure TfpgUltiboCanvas.DoSetColor(cl: TfpgColor);
var
  t: TRGBTriple;
  c: TfpgColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoSetColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 c := fpgColorToRGB(cl);
 t := fpgColorToRGBTriple(c);

 LineColor(t.Red, t.Green, t.Blue, t.Alpha);
end;

procedure TfpgUltiboCanvas.DoSetLineStyle(awidth: integer; astyle: TfpgLineStyle);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoSetLineStyle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
//  LineWidth(awidth);
  case astyle of
    lsSolid:
      begin
        m_convDash.remove_all_dashes;
        m_convDash.add_dash(600, 0);  {$NOTE Find a better way to prevent dash generation }
      end;
    lsDash:
      begin
        m_convDash.remove_all_dashes;
        m_convDash.add_dash(3, 3);
      end;
    lsDot:
      begin
        m_convDash.remove_all_dashes;
        m_convDash.add_dash(1, 1.5);
      end;
    lsDashDot:
      begin
        m_convDash.remove_all_dashes;
        m_convDash.add_dash(3, 1);
      end;
    lsDashDotDot:
      begin
        m_convDash.add_dash(3, 1);
        m_convDash.add_dash(1, 1);
      end;
  end;
end;

procedure TfpgUltiboCanvas.DoGetWinRect(out r: TfpgRect);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoGetWinRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 r.Left    := 0;
 r.Top     := 0; 
 r.Width := FWindow.Width;
 r.Height := FWindow.Height;
 
 {$IFDEF DEBUG}
 LoggingOutput(' r.Left=' + IntToStr(r.Left) + ' r.Top=' + IntToStr(r.Top) + ' r.Width=' + IntToStr(r.Width) + ' r.Height=' + IntToStr(r.Height)); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
end;


procedure TfpgUltiboCanvas.DoFillRectangle(x, y, w, h: TfpgCoord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoFillRectangle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 FillColor(LineColor);
 LineColor(LineColor);
 // NoLine;
 LineWidth(1);
 if (w = 1) or (h = 1) then
  begin
   // we have a line
   LineCap(AGG_CapButt);
   if w = 1 then
    Line(x, y, x, y+h, True)
   else
    Line(x, y, x+w, y, True);
  end
 else
  Rectangle(x, y, x+w-1, y+h-1, True);
end;

procedure TfpgUltiboCanvas.DoXORFillRectangle(col: TfpgColor; x, y, w, h: TfpgCoord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoXORFillRectangle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Nothing ?
end;

procedure TfpgUltiboCanvas.DoFillTriangle(x1, y1, x2, y2, x3, y3: TfpgCoord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoFillTriangle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 LineWidth(1);
 FillColor(LineColor);
 LineColor(LineColor);
 Triangle(x1+0.5, y1+0.5, x2+0.5, y2+0.5, x3+0.5, y3+0.5);
end;

procedure TfpgUltiboCanvas.DoDrawRectangle(x, y, w, h: TfpgCoord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoDrawRectangle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 // LineWidth(FLineWidth);
 DoSetColor(FColor);
 NoFill;
 if (w = 1) or (h = 1) then
  begin
   // we have a line
   LineCap(AGG_CapButt);
   if w = 1 then
    Line(x, y, x, y+h, True)
   else
    Line(x, y, x+w, y, True);
  end
 else
  Rectangle(x, y, x+w-1, y+h-1, True);
end;

procedure TfpgUltiboCanvas.DoDrawLine(x1, y1, x2, y2: TfpgCoord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoDrawLine x1=' + IntToStr(x1) + ' y1=' + IntToStr(y1) + ' x2=' + IntToStr(x2) + ' y2=' + IntToStr(y2)); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Line(x1, y1, x2, y2, True);
end;

procedure TfpgUltiboCanvas.DoDrawImagePart(x, y: TfpgCoord; img: TfpgImageBase; xi, yi, w, h: integer);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoDrawImagePart x=' + IntToStr(x) + ' y=' + IntToStr(y)); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 {We use TransformImage so we can get alpha blending support. CopyImage doesn't use image blending, when it does painting.}
 TransformImage(TfpgImage(img), xi, yi, xi+w, yi+h, x, y, x+w, y+h);
end;

procedure TfpgUltiboCanvas.DoDrawString(x, y: TfpgCoord; const txt: string);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoDrawString x=' + IntToStr(x) + ' y=' + IntToStr(y) + ' txt=' + txt); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 DoSetTextColor(FTextColor);
 NoLine;
 TextHints(True);
 TextRender(x, y+FontHeight, txt);
end;

procedure TfpgUltiboCanvas.DoSetClipRect(const ARect: TfpgRect);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoSetClipRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 ClipBox(ARect.Left, ARect.Top, ARect.Right+1, ARect.Bottom+1);
end;

function TfpgUltiboCanvas.DoGetClipRect: TfpgRect;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoGetClipRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result.SetRect(Round(ClipBox.x1), Round(ClipBox.y1), Round(ClipBox.x2 - ClipBox.x1), Round(ClipBox.y2 - ClipBox.y1));
end;

procedure TfpgUltiboCanvas.DoAddClipRect(const ARect: TfpgRect);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoAddClipRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 {$NOTE TfpgUltiboCanvas.DoAddClipRect must still be implemented }
end;

procedure TfpgUltiboCanvas.DoClearClipRect;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoClearClipRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 ClipBox(0, 0, FWindow.width, FWindow.height);
 m_rasterizer.m_clipping := false;
end;
  
procedure TfpgUltiboCanvas.DoBeginDraw(awin: TfpgWindowBase; buffered: boolean);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoBeginDraw'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if Assigned(FImg) then
  begin
   { if the window was resized }
   if (FImg.Width <> FWindow.Width) or (FImg.Height <> FWindow.Height) then
    begin
     FImg.Free;
     FImg := nil;
    end;
  end;

 if not Assigned(FImg) then
  begin
   FImg := TfpgUltiboImage.Create;
   FImg.AllocateImage(32, FWindow.Width, FWindow.Height);
   Attach(FImg);
  end;
end;

procedure TfpgUltiboCanvas.DoEndDraw;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoEndDraw'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 // nothing to do here
end;

function TfpgUltiboCanvas.GetPixel(X, Y: integer): TfpgColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.GetPixel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
  
 Result := FImg.Colors[y, y];
end;
   
procedure TfpgUltiboCanvas.SetPixel(X, Y: integer; const AValue: TfpgColor);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.SetPixel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
  
 FImg.Colors[x, y] := AValue;
end;

procedure TfpgUltiboCanvas.DoDrawArc(x, y, w, h: TfpgCoord; a1, a2: Extended);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoDrawArc'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
  
 NoFill;
 LineColor(LineColor);
 Arc(x+(w/2), y+(h/2), w/2, h/2, Deg2Rad(a1+90), Deg2Rad(a2+90));
end;

procedure TfpgUltiboCanvas.DoFillArc(x, y, w, h: TfpgCoord; a1, a2: Extended);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoFillArc'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
  
 {$Note AggPas's Arc only does stroking, not filling. Make another plan }
 NoFill;
 LineColor(LineColor);
 Arc(x+(w/2), y+(h/2), w/2, h/2, Deg2Rad(a1+90), Deg2Rad(a2+90));
end;

procedure TfpgUltiboCanvas.DoDrawPolygon(Points: PPoint; NumPts: Integer; Winding: boolean);
var
 i: integer;
 poly: array of double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoDrawPolygon'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
  
 SetLength(poly, (NumPts*2)+1); // dynamic arrays start at 0, but we want to use 1..NumPts
 for i := 1 to NumPts do
  begin
   poly[i * 2 - 1] := Points[i-1].X + 0.5;
   poly[i * 2] := Points[i-1].Y + 0.5;
  end;
 // Draw Polygon
 LineWidth(1);
 LineColor(LineColor);
 FillColor($00, $00, $00);  // clBlack for now
 Polygon(@poly[1], NumPts);
end;

procedure TfpgUltiboCanvas.DoPutBufferToScreen(x, y, w, h: TfpgCoord);
var
 Stride:LongWord;
 Source:Pointer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DoPutBufferToScreen (x=' + IntToStr(x) + ' y=' + IntToStr(y) + ' w=' + IntToStr(w) + ' h=' + IntToStr(h) + ')'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if DefaultApplication = nil then Exit;
 
 if (w = 0) or (h = 0) then Exit;
 
 Stride:=m_rbuf._width - w;
 Source:=m_rbuf.row_xy(x,y,w);
 
 DefaultApplication.DoPutFramebufferRect(x, y, w, h, Source, Stride);
end;

constructor TfpgUltiboCanvas.Create(awin: TfpgWindowBase);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create(awin);

 FLineWidth := 1;
 m_rbuf.Construct;

 m_pixf:=pf32bit;

 pixfmt_rgba32           (m_pixFormat ,@m_rbuf );
 pixfmt_custom_blend_rgba(m_pixFormatComp ,@m_rbuf ,@comp_op_adaptor_rgba ,rgba_order );
 pixfmt_rgba32           (m_pixFormatPre ,@m_rbuf );
 pixfmt_custom_blend_rgba(m_pixFormatCompPre ,@m_rbuf ,@comp_op_adaptor_rgba ,rgba_order );

 m_renBase.Construct       (@m_pixFormat );
 m_renBaseComp.Construct   (@m_pixFormatComp );
 m_renBasePre.Construct    (@m_pixFormatPre );
 m_renBaseCompPre.Construct(@m_pixFormatCompPre );

 m_renSolid.Construct    (@m_renBase );
 m_renSolidComp.Construct(@m_renBaseComp );

 m_allocator.Construct;
 m_clipBox.Construct(0 ,0 ,0 ,0 );

 m_blendMode     :=AGG_BlendAlpha;
 m_imageBlendMode:=AGG_BlendDst;

 m_imageBlendColor.Construct(0 ,0 ,0 );

 m_scanline.Construct;
 m_rasterizer.Construct;

 m_masterAlpha   :=1.0;
 m_antiAliasGamma:=1.0;

 m_fillColor.Construct(255 ,255 ,255 );
 m_lineColor.Construct(0   ,0   ,0 );

 m_fillGradient.Construct(256 ,sizeof(aggclr ) );
 m_lineGradient.Construct(256 ,sizeof(aggclr ) );

 m_lineCap :=AGG_CapRound;
 m_lineJoin:=AGG_JoinRound;

 m_fillGradientFlag:=AGG_Solid;
 m_lineGradientFlag:=AGG_Solid;

 m_fillGradientMatrix.Construct;
 m_lineGradientMatrix.Construct;

 m_fillGradientD1:=0.0;
 m_lineGradientD1:=0.0;
 m_fillGradientD2:=100.0;
 m_lineGradientD2:=100.0;

 m_textAngle  :=0.0;
 m_textAlignX :=AGG_AlignLeft;
 m_textAlignY :=AGG_AlignBottom;
 m_textHints  :=true;
 m_fontHeight :=0.0;
 m_fontAscent :=0.0;
 m_fontDescent:=0.0;

 m_fontCacheType:=AGG_RasterFontCache;
 m_imageFilter  :=AGG_Bilinear;
 m_imageResample:=AGG_NoResample;

 m_gammaNone.Construct;

 m_ifBilinear.Construct;
 m_ifHanning.Construct;
 m_ifHermite.Construct;
 m_ifQuadric.Construct;
 m_ifBicubic.Construct;
 m_ifCatrom.Construct;
 m_ifSpline16.Construct;
 m_ifSpline36.Construct;
 m_ifBlackman144.Construct;

 m_imageFilterLut.Construct(@m_ifBilinear ,true );

 m_linearGradientFunction.Construct;
 m_radialGradientFunction.Construct;

 m_fillGradientInterpolator.Construct(@m_fillGradientMatrix );
 m_lineGradientInterpolator.Construct(@m_lineGradientMatrix );

 m_lineWidth  :=1;
 m_evenOddFlag:=false;

 m_imageFlip:=false;

 m_path.Construct;
 m_transform.Construct;

 m_convCurve.Construct (@m_path );
 m_convDash.Construct(@m_convCurve);
 m_convStroke.Construct(@m_convDash );

 m_pathTransform.Construct  (@m_convCurve ,@m_transform );
 m_strokeTransform.Construct(@m_convStroke ,@m_transform );

 m_convDash.remove_all_dashes;
 m_convDash.add_dash(600, 0);  {$NOTE Find a better way to prevent dash generation }

{$IFDEF AGG2D_USE_FREETYPE }
 m_fontEngine.Construct;
{$ENDIF }

{$IFNDEF AGG2D_NO_FONT}
{$IFDEF AGG2D_USE_FREETYPE }
 m_fontCacheManager.Construct(@m_fontEngine );
{$ENDIF }
{$IFDEF AGG2D_USE_RASTERFONTS}
 m_fontGlyph.Construct(nil );
 m_font_flip_y:=False;
{$ENDIF}
{$ENDIF}

 LineCap (m_lineCap );
 LineJoin(m_lineJoin );
end;
 
destructor TfpgUltiboCanvas.Destroy;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Destroy'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_rbuf.Destruct;

 m_allocator.Destruct;

 m_scanline.Destruct;
 m_rasterizer.Destruct;

 m_fillGradient.Destruct;
 m_lineGradient.Destruct;

 m_imageFilterLut.Destruct;
 m_path.Destruct;

 m_convCurve.Destruct;
 m_convStroke.Destruct;
 m_convDash.Destruct;

 {$IFNDEF AGG2D_NO_FONT}
 {$IFDEF AGG2D_USE_FREETYPE}
 m_fontEngine.Destruct;
 m_fontCacheManager.Destruct;
 {$ENDIF}
 {$IFDEF AGG2D_USE_RASTERFONTS}
 //Ultibo To Do //Nothing ?
 {$ENDIF}
 {$ENDIF}

 if Assigned(FImg) then FImg.Free;
 
 inherited Destroy;
end;

{Agg2D Vector Graphics Engine Initialization}
function TfpgUltiboCanvas.Attach(bitmap : TfpgUltiboImage; flip_y : boolean = false ) : boolean;
var
 buffer : pointer;
 stride : integer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Attach'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=false;

 if Assigned(bitmap )
  {and
    not bitmap.Empty }then    {$Warning Implement bitmap.Emtpy }
  case bitmap.ColorDepth of
   24,
   32:
    begin
    { Rendering Buffer }
     stride:=integer(TfpgImage(bitmap).ScanLine[1 ] ) - integer(TfpgImage(bitmap).ScanLine[0 ] );

     if stride < 0 then
      buffer:=TfpgImage(bitmap).ScanLine[bitmap.Height - 1 ]
     else
      buffer:=TfpgImage(bitmap).ScanLine[0 ];

     if flip_y then
      stride:=stride * -1;

     m_rbuf.attach(
      buffer ,
      bitmap.Width ,
      bitmap.Height ,
      stride );

     { Pixel Format }
     m_pixf :=  ColorDepthToPixelFormat(bitmap.ColorDepth);

     case m_pixf of
      pf24bit :
       begin
        pixfmt_rgb24(m_pixFormat ,@m_rbuf );
        pixfmt_rgb24(m_pixFormatPre ,@m_rbuf );

       end;

      pf32bit :
       begin
        pixfmt_rgba32           (m_pixFormat ,@m_rbuf );
        pixfmt_custom_blend_rgba(m_pixFormatComp ,@m_rbuf ,@comp_op_adaptor_rgba ,rgba_order );
        pixfmt_rgba32           (m_pixFormatPre ,@m_rbuf );
        pixfmt_custom_blend_rgba(m_pixFormatCompPre ,@m_rbuf ,@comp_op_adaptor_rgba ,rgba_order );

       end;

     end;

    { Reset state }
     m_renBase.reset_clipping       (true );
     m_renBaseComp.reset_clipping   (true );
     m_renBasePre.reset_clipping    (true );
     m_renBaseCompPre.reset_clipping(true );

     ResetTransformations;

     LineWidth(1.0 );
     LineColor(0   ,0   ,0 );
     FillColor(255 ,255 ,255 );

     TextAlignment(AGG_AlignLeft ,AGG_AlignBottom );

     ClipBox (0 ,0 ,bitmap.Width ,bitmap.Height );
     LineCap (AGG_CapRound );
     LineJoin(AGG_JoinRound );
     FlipText(false );

     ImageFilter  (AGG_Bilinear );
     ImageResample(AGG_NoResample );
     ImageFlip    (false );

     m_masterAlpha   :=1.0;
     m_antiAliasGamma:=1.0;

     m_rasterizer.gamma(@m_gammaNone );

     m_blendMode:=AGG_BlendAlpha;

     FillEvenOdd(false );
     BlendMode  (AGG_BlendAlpha );

     FlipText(false );
     ResetPath;

     ImageFilter  (AGG_Bilinear );
     ImageResample(AGG_NoResample );

    { OK }
     result:=true;
    end;
  end;
end;
  
procedure TfpgUltiboCanvas.ClearAll(c : TAggColor );
var
 clr : aggclr;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClearAll'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct  (c );
 m_renBase.clear(@clr );
end;

procedure TfpgUltiboCanvas.ClearAll(r ,g ,b : byte; a : byte = 255 );
var
 clr : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClearAll'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(r ,g ,b ,a );
 ClearAll     (clr );
end;
 
procedure TfpgUltiboCanvas.FillAll(c: TAggColor);
var
 clr: aggclr;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillAll'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct  (c );
 m_renBase.fill(@clr );
end;

procedure TfpgUltiboCanvas.FillAll(r, g, b: byte; a: byte);
var
 clr: TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillAll'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(r, g, b, a);
 FillAll(clr);
end;

{Agg2D Master Rendering Properties}
procedure TfpgUltiboCanvas.BlendMode(m : TAggBlendMode );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.BlendMode'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_blendMode:=m;

 m_pixFormatComp.comp_op_   (unsigned(m ) );
 m_pixFormatCompPre.comp_op_(unsigned(m ) );
end;

function TfpgUltiboCanvas.BlendMode : TAggBlendMode;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.BlendMode'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_blendMode;
end;

procedure TfpgUltiboCanvas.MasterAlpha(a : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.MasterAlpha'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_masterAlpha:=a;

 UpdateRasterizerGamma;
end;

function TfpgUltiboCanvas.MasterAlpha : double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.MasterAlpha'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_masterAlpha;
end;
  
procedure TfpgUltiboCanvas.AntiAliasGamma(g : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.AntiAliasGamma'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_antiAliasGamma:=g;

 UpdateRasterizerGamma;
end;

function TfpgUltiboCanvas.AntiAliasGamma : double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.AntiAliasGamma'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_antiAliasGamma;
end;

procedure TfpgUltiboCanvas.FillColor(c : TAggColor );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_fillColor       :=c;
 m_fillGradientFlag:=AGG_Solid;
end;

procedure TfpgUltiboCanvas.FillColor(r ,g ,b : byte; a : byte = 255 );
var
 clr : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(r ,g ,b ,a );
 FillColor    (clr );
end;

procedure TfpgUltiboCanvas.NoFill;
var
 clr : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.NoFill'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(0 ,0 ,0 ,0 );
 FillColor    (clr );
end;

procedure TfpgUltiboCanvas.LineColor(c : TAggColor );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_lineColor       :=c;
 m_lineGradientFlag:=AGG_Solid;
end;

procedure TfpgUltiboCanvas.LineColor(r ,g ,b : byte; a : byte = 255 );
var
 clr : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(r ,g ,b ,a );
 LineColor    (clr );
end;

procedure TfpgUltiboCanvas.NoLine;
var
 clr : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.NoLine'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(0 ,0 ,0 ,0 );
 LineColor    (clr );
end;

function TfpgUltiboCanvas.FillColor : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_fillColor;
end;

function TfpgUltiboCanvas.LineColor : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_lineColor;
end;
  
procedure TfpgUltiboCanvas.FillLinearGradient(const x1 ,y1 ,x2 ,y2 : double; c1 ,c2 : TAggColor; profile : double = 1.0 );
var
 i ,startGradient ,endGradient : int;

 k ,angle : double;

 c : TAggColor;

 clr : aggclr;
 tar : trans_affine_rotation;
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillLinearGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 startGradient:=128 - Trunc(profile * 127.0 );
 endGradient  :=128 + Trunc(profile * 127.0 );

 if endGradient <= startGradient then
  endGradient:=startGradient + 1;

 k:=1.0 / (endGradient - startGradient );
 i:=0;

 while i < startGradient do
  begin
   clr.Construct(c1 );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < endGradient do
  begin
   c:=c1.gradient(c2 ,(i - startGradient ) * k );

   clr.Construct(c );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < 256 do
  begin
   clr.Construct(c2 );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 angle:=ArcTan2(y2 - y1 ,x2 - x1 );

 m_fillGradientMatrix.reset;

 tar.Construct(angle );

 m_fillGradientMatrix.multiply(@tar );

 tat.Construct(x1 ,y1 );

 m_fillGradientMatrix.multiply(@tat );
 m_fillGradientMatrix.multiply(@m_transform );
 m_fillGradientMatrix.invert;

 m_fillGradientD1  :=0.0;
 m_fillGradientD2  :=Sqrt((x2 - x1 ) * (x2 - x1 ) + (y2 - y1 ) * (y2 - y1 ) );
 m_fillGradientFlag:=AGG_Linear;

 m_fillColor.Construct(0 ,0 ,0 );  // Set some real color
end;

procedure TfpgUltiboCanvas.LineLinearGradient(const x1 ,y1 ,x2 ,y2 : double; c1 ,c2 : TAggColor; profile : double = 1.0 );
var
 i ,startGradient ,endGradient : int;

 k ,angle : double;

 c : TAggColor;

 clr : aggclr;
 tar : trans_affine_rotation;
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineLinearGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 startGradient:=128 - Trunc(profile * 128.0 );
 endGradient  :=128 + Trunc(profile * 128.0 );

 if endGradient <= startGradient then
  endGradient:=startGradient + 1;

 k:=1.0 / (endGradient - startGradient );
 i:=0;

 while i < startGradient do
  begin
   clr.Construct(c1 );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < endGradient do
  begin
   c:=c1.gradient(c2 ,(i - startGradient) * k );

   clr.Construct(c );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < 256 do
  begin
   clr.Construct(c2 );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 angle:=ArcTan2(y2 - y1 ,x2 - x1 );

 m_lineGradientMatrix.reset;

 tar.Construct(angle );

 m_lineGradientMatrix.multiply(@tar );

 tat.Construct(x1 ,y1 );

 m_lineGradientMatrix.multiply(@tat );
 m_lineGradientMatrix.multiply(@m_transform );
 m_lineGradientMatrix.invert;

 m_lineGradientD1  :=0.0;
 m_lineGradientD2  :=Sqrt((x2 - x1 ) * (x2 - x1 ) + (y2 - y1 ) * (y2 - y1 ) );
 m_lineGradientFlag:=AGG_Linear;

 m_lineColor.Construct(0 ,0 ,0 );  // Set some real color
end;

procedure TfpgUltiboCanvas.FillRadialGradient(const x ,y ,r : double; c1 ,c2 : TAggColor; profile : double = 1.0 );
var
 i ,startGradient ,endGradient : int;

 k : double;
 c : TAggColor;

 clr : aggclr;
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillRadialGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 startGradient:=128 - Trunc(profile * 127.0 );
 endGradient  :=128 + Trunc(profile * 127.0 );

 if endGradient <= startGradient then
  endGradient:=startGradient + 1;

 k:=1.0 / (endGradient - startGradient );
 i:=0;

 while i < startGradient do
  begin
   clr.Construct(c1 );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < endGradient do
  begin
   c:=c1.gradient(c2 ,(i - startGradient ) * k );

   clr.Construct(c );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < 256 do
  begin
   clr.Construct(c2 );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 m_fillGradientD2:=worldToScreen(r );

 WorldToScreen(@x ,@y );

 m_fillGradientMatrix.reset;

 tat.Construct(x ,y );

 m_fillGradientMatrix.multiply(@tat );
 m_fillGradientMatrix.invert;

 m_fillGradientD1  :=0;
 m_fillGradientFlag:=AGG_Radial;

 m_fillColor.Construct(0 ,0 ,0 );  // Set some real color
end;

procedure TfpgUltiboCanvas.LineRadialGradient(const x ,y ,r : double; c1 ,c2 : TAggColor; profile : double = 1.0 );
var
 i ,startGradient ,endGradient : int;

 k : double;
 c : TAggColor;

 clr : aggclr;
 tat : trans_affine_translation;

begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineRadialGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 startGradient:=128 - Trunc(profile * 128.0 );
 endGradient  :=128 + Trunc(profile * 128.0 );

 if endGradient <= startGradient then
  endGradient:=startGradient + 1;

 k:=1.0 / (endGradient - startGradient );
 i:=0;

 while i < startGradient do
  begin
   clr.Construct(c1 );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < endGradient do
  begin
   c:=c1.gradient(c2 ,(i - startGradient ) * k );

   clr.Construct(c );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < 256 do
  begin
   clr.Construct(c2 );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 m_lineGradientD2:=worldToScreen(r );

 WorldToScreen(@x ,@y );

 m_lineGradientMatrix.reset;

 tat.Construct(x ,y );

 m_lineGradientMatrix.multiply(@tat );
 m_lineGradientMatrix.invert;

 m_lineGradientD1  :=0;
 m_lineGradientFlag:=AGG_Radial;

 m_lineColor.Construct(0 ,0 ,0 );  // Set some real color
end;

procedure TfpgUltiboCanvas.FillRadialGradient(const x ,y ,r : double; c1 ,c2 ,c3 : TAggColor );
var
 i : int;
 c : TAggColor;

 clr : aggclr;
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillRadialGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 i:=0;

 while i < 128 do
  begin
   c:=c1.gradient(c2 ,i / 127.0 );

   clr.Construct(c );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < 256 do
  begin
   c:=c2.gradient(c3 ,(i - 128 ) / 127.0 );

   clr.Construct(c );

   move(clr ,m_fillGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 m_fillGradientD2:=worldToScreen(r );

 WorldToScreen(@x ,@y );

 m_fillGradientMatrix.reset;

 tat.Construct(x ,y );

 m_fillGradientMatrix.multiply(@tat );
 m_fillGradientMatrix.invert;

 m_fillGradientD1  :=0;
 m_fillGradientFlag:=AGG_Radial;

 m_fillColor.Construct(0 ,0 ,0 ); // Set some real color
end;

procedure TfpgUltiboCanvas.LineRadialGradient(const x ,y ,r : double; c1 ,c2 ,c3 : TAggColor );
var
 i : int;
 c : TAggColor;

 clr : aggclr;
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineRadialGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 i:=0;

 while i < 128 do
  begin
   c:=c1.gradient(c2 ,i / 127.0 );

   clr.Construct(c );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 while i < 256 do
  begin
   c:=c2.gradient(c3 ,(i - 128 ) / 127.0 );

   clr.Construct(c );

   move(clr ,m_lineGradient.array_operator(i )^ ,sizeof(aggclr ) );
   inc (i );

  end;

 m_lineGradientD2:=worldToScreen(r );

 WorldToScreen(@x ,@y );

 m_lineGradientMatrix.reset;

 tat.Construct(x ,y );

 m_lineGradientMatrix.multiply(@tat );
 m_lineGradientMatrix.invert;

 m_lineGradientD1  :=0;
 m_lineGradientFlag:=AGG_Radial;

 m_lineColor.Construct(0 ,0 ,0 ); // Set some real color
end;

procedure TfpgUltiboCanvas.FillRadialGradient(const x ,y ,r : double );
var
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillRadialGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_fillGradientD2:=worldToScreen(r );

 WorldToScreen(@x ,@y );

 m_fillGradientMatrix.reset;

 tat.Construct(x ,y );

 m_fillGradientMatrix.multiply(@tat );
 m_fillGradientMatrix.invert;

 m_fillGradientD1:=0;
end;

procedure TfpgUltiboCanvas.LineRadialGradient(const x ,y ,r : double );
var
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineRadialGradient'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_lineGradientD2:=worldToScreen(r );

 WorldToScreen(@x ,@y );

 m_lineGradientMatrix.reset;

 tat.Construct(x ,y );

 m_lineGradientMatrix.multiply(@tat );
 m_lineGradientMatrix.invert;

 m_lineGradientD1:=0;
end;

procedure TfpgUltiboCanvas.LineWidth(const w : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineWidth'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_lineWidth:=w;

 m_convStroke.width_(w );
end;

function TfpgUltiboCanvas.LineWidth : double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineWidth'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_lineWidth;
end;

procedure TfpgUltiboCanvas.LineCap(cap : TAggLineCap );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineCap'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_lineCap:=cap;

 m_convStroke.line_cap_(cap );
end;

function TfpgUltiboCanvas.LineCap : TAggLineCap;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineCap'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_lineCap;
end;

procedure TfpgUltiboCanvas.LineJoin(join : TAggLineJoin );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineJoin'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_lineJoin:=join;

 m_convStroke.line_join_(join );
end;

function TfpgUltiboCanvas.LineJoin : TAggLineJoin;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineJoin'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_lineJoin;
end;

procedure TfpgUltiboCanvas.FillEvenOdd(evenOddFlag : boolean );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillEvenOdd'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_evenOddFlag:=evenOddFlag;

 if evenOddFlag then
  m_rasterizer.filling_rule(fill_even_odd )
 else
  m_rasterizer.filling_rule(fill_non_zero );
end;

function TfpgUltiboCanvas.FillEvenOdd : boolean;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FillEvenOdd'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_evenOddFlag;
end;

{Agg2D Affine Transformations}
function TfpgUltiboCanvas.Transformations : TAggTransformations;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Transformations'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_transform.store_to(@result.affineMatrix[0 ] );
end;

procedure TfpgUltiboCanvas.Transformations(tr : PAggTransformations );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Transformations'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_transform.load_from(@tr.affineMatrix[0 ] );

 m_convCurve.approximation_scale_ (worldToScreen(1.0 ) * g_approxScale );
 m_convStroke.approximation_scale_(worldToScreen(1.0 ) * g_approxScale );
end;

procedure TfpgUltiboCanvas.ResetTransformations;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ResetTransformations'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_transform.reset;
end;

procedure TfpgUltiboCanvas.Affine(const tr : PAggAffine );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Affine'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_transform.multiply(tr );

 m_convCurve.approximation_scale_ (WorldToScreen(1.0 ) * g_approxScale );
 m_convStroke.approximation_scale_(WorldToScreen(1.0 ) * g_approxScale );
end;

procedure TfpgUltiboCanvas.Affine(const tr : PAggTransformations );
var
 ta : trans_affine;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Affine'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 ta.Construct(
  tr.affineMatrix[0 ] ,tr.affineMatrix[1 ] ,tr.affineMatrix[2 ] ,
  tr.affineMatrix[3 ] ,tr.affineMatrix[4 ] ,tr.affineMatrix[5 ] );

 affine(PAggAffine(@ta ) );
end;

procedure TfpgUltiboCanvas.Rotate(const angle : double );
var
 tar : trans_affine_rotation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Rotate'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 tar.Construct(angle );

 m_transform.multiply(@tar );
end;

procedure TfpgUltiboCanvas.Scale(const sx ,sy : double );
var
 tas : trans_affine_scaling;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Scale'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 tas.Construct(sx ,sy );

 m_transform.multiply(@tas );

 m_convCurve.approximation_scale_ (worldToScreen(1.0 ) * g_approxScale );
 m_convStroke.approximation_scale_(worldToScreen(1.0 ) * g_approxScale );
end;

procedure TfpgUltiboCanvas.Skew(const sx ,sy : double );
var
 tas : trans_affine_skewing;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Skew'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 tas.Construct(sx ,sy );

 m_transform.multiply(@tas );
end;

procedure TfpgUltiboCanvas.Translate(const x ,y : double );
var
 tat : trans_affine_translation;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Translate'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 tat.Construct(x ,y );

 m_transform.multiply(@tat );
end;

procedure TfpgUltiboCanvas.Parallelogram(const x1 ,y1 ,x2 ,y2 : double; para : PDouble );
var
 ta : trans_affine;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Parallelogram'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 ta.Construct(x1 ,y1 ,x2 ,y2 ,parallelo_ptr(para ) );

 m_transform.multiply(@ta );

 m_convCurve.approximation_scale_ (worldToScreen(1.0 ) * g_approxScale );
 m_convStroke.approximation_scale_(worldToScreen(1.0 ) * g_approxScale );
end;

procedure TfpgUltiboCanvas.Viewport(const worldX1  ,worldY1  ,worldX2  ,worldY2 ,screenX1 ,screenY1 ,screenX2 ,screenY2 : double; const opt : TAggViewportOption = AGG_XMidYMid );
var
 vp : trans_viewport;
 mx : trans_affine;
begin 
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Viewport'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 vp.Construct;

 case opt of
  AGG_Anisotropic :
   vp.preserve_aspect_ratio(0.0 ,0.0 ,aspect_ratio_stretch );

  AGG_XMinYMin :
   vp.preserve_aspect_ratio(0.0 ,0.0 ,aspect_ratio_meet );

  AGG_XMidYMin :
   vp.preserve_aspect_ratio(0.5 ,0.0 ,aspect_ratio_meet );

  AGG_XMaxYMin :
   vp.preserve_aspect_ratio(1.0 ,0.0 ,aspect_ratio_meet );

  AGG_XMinYMid :
   vp.preserve_aspect_ratio(0.0 ,0.5 ,aspect_ratio_meet );

  AGG_XMidYMid :
   vp.preserve_aspect_ratio(0.5 ,0.5 ,aspect_ratio_meet );

  AGG_XMaxYMid :
   vp.preserve_aspect_ratio(1.0 ,0.5 ,aspect_ratio_meet );

  AGG_XMinYMax :
   vp.preserve_aspect_ratio(0.0 ,1.0 ,aspect_ratio_meet );

  AGG_XMidYMax :
   vp.preserve_aspect_ratio(0.5 ,1.0 ,aspect_ratio_meet );

  AGG_XMaxYMax :
   vp.preserve_aspect_ratio(1.0 ,1.0 ,aspect_ratio_meet );

 end;

 vp.world_viewport (worldX1  ,worldY1  ,worldX2  ,worldY2 );
 vp.device_viewport(screenX1 ,screenY1 ,screenX2 ,screenY2 );

 mx.Construct;

 vp.to_affine        (@mx );
 m_transform.multiply(@mx );

 m_convCurve.approximation_scale_ (WorldToScreen(1.0 ) * g_approxScale );
 m_convStroke.approximation_scale_(WorldToScreen(1.0 ) * g_approxScale );
end;

{Agg2D Coordinates Conversions}
procedure TfpgUltiboCanvas.WorldToScreen(x ,y : PDouble );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.WorldToScreen'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_transform.transform(@m_transform, x, y);
end;

procedure TfpgUltiboCanvas.ScreenToWorld(x ,y : PDouble );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ScreenToWorld'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_transform.inverse_transform(@m_transform, x, y);
end;

function TfpgUltiboCanvas.WorldToScreen(scalar : double ) : double;
var
 x1 ,y1 ,x2 ,y2 : double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.WorldToScreen'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 x1:=0;
 y1:=0;
 x2:=scalar;
 y2:=scalar;

 WorldToScreen(@x1 ,@y1 );
 WorldToScreen(@x2 ,@y2 );

 result:=Sqrt((x2 - x1 ) * (x2 - x1 ) + (y2 - y1 ) * (y2 - y1 ) ) * 0.7071068;
end;

function TfpgUltiboCanvas.ScreenToWorld(scalar : double ) : double;
var
 x1 ,y1 ,x2 ,y2 : double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ScreenToWorld'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 x1:=0;
 y1:=0;
 x2:=scalar;
 y2:=scalar;

 ScreenToWorld(@x1 ,@y1 );
 ScreenToWorld(@x2 ,@y2 );

 result:=Sqrt((x2 - x1 ) * (x2 - x1 ) + (y2 - y1 ) * (y2 - y1 ) ) * 0.7071068;
end;

procedure TfpgUltiboCanvas.AlignPoint(x ,y : PDouble );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.AlignPoint'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 WorldToScreen(x ,y );

 x^:=Floor(x^ ) + 0.5;
 y^:=Floor(y^ ) + 0.5;

 ScreenToWorld(x ,y );
end;

{Agg2D Clipping}
procedure TfpgUltiboCanvas.ClipBox(x1 ,y1 ,x2 ,y2 : double );
var
 rx1 ,ry1 ,rx2 ,ry2 : int;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClipBox'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_clipBox.Construct(x1 ,y1 ,x2 ,y2 );

 rx1:=Trunc(x1 );
 ry1:=Trunc(y1 );
 rx2:=Trunc(x2 );
 ry2:=Trunc(y2 );

 m_renBase.clip_box_       (rx1 ,ry1 ,rx2 ,ry2 );
 m_renBaseComp.clip_box_   (rx1 ,ry1 ,rx2 ,ry2 );
 m_renBasePre.clip_box_    (rx1 ,ry1 ,rx2 ,ry2 );
 m_renBaseCompPre.clip_box_(rx1 ,ry1 ,rx2 ,ry2 );

 m_rasterizer.clip_box(x1 ,y1 ,x2 ,y2 );
end;

function TfpgUltiboCanvas.ClipBox : TAggRectD;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClipBox'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_clipBox;
end;
  
procedure TfpgUltiboCanvas.ClearClipBox(c : TAggColor );
var
 clr : aggclr;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClearClipBox'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(c );

 m_renBase.copy_bar(0 ,0 ,m_renBase.width ,m_renBase.height ,@clr );
end;

procedure TfpgUltiboCanvas.ClearClipBox(r ,g ,b : byte; a : byte = 255 );
var
 clr : TAggColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClearClipBox'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 clr.Construct(r ,g ,b ,a );
 ClearClipBox (clr );
end;
  
function TfpgUltiboCanvas.InBox(worldX ,worldY : double ) : boolean;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.InBox'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 WorldToScreen(@worldX ,@worldY );

 result:=m_renBase.inbox(Trunc(worldX ) ,Trunc(worldY ) );
end;
  
{Agg2D Basic Shapes}
procedure TfpgUltiboCanvas.Line(const x1, y1, x2, y2: double; AFixAlignment: boolean = false);
var
  lx1, ly1, lx2, ly2: double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Line'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;

 lx1 := x1;
 ly1 := y1;
 lx2 := x2;
 ly2 := y2;

 if AFixAlignment then
 begin
   AlignPoint(@lx1, @ly1);
   AlignPoint(@lx2, @ly2);
 end;

 addLine(lx1, ly1, lx2, ly2);
 DrawPath(AGG_StrokeOnly );
end;

procedure TfpgUltiboCanvas.Triangle(const x1 ,y1 ,x2 ,y2 ,x3 ,y3 : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Triangle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 m_path.move_to(x1 ,y1 );
 m_path.line_to(x2 ,y2 );
 m_path.line_to(x3 ,y3 );
 m_path.close_polygon;

 DrawPath(AGG_FillAndStroke );
end;

procedure TfpgUltiboCanvas.Rectangle(const x1 ,y1 ,x2 ,y2 : double; AFixAlignment: boolean);
var
  lx1, ly1, lx2, ly2: double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Rectangle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;

 lx1 := x1;
 ly1 := y1;
 lx2 := x2;
 ly2 := y2;

 if AFixAlignment then
 begin
   AlignPoint(@lx1, @ly1);
   AlignPoint(@lx2, @ly2);
 end;

 m_path.move_to(lx1 ,ly1 );
 m_path.line_to(lx2 ,ly1 );
 m_path.line_to(lx2 ,ly2 );
 m_path.line_to(lx1 ,ly2 );
 m_path.close_polygon;

 DrawPath(AGG_FillAndStroke );
end;
  
procedure TfpgUltiboCanvas.RoundedRect(const x1 ,y1 ,x2 ,y2 ,r : double );
var
 rc : rounded_rect;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.RoundedRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 rc.Construct(x1 ,y1 ,x2 ,y2 ,r );

 rc.normalize_radius;
 rc.approximation_scale_(worldToScreen(1.0 ) * g_approxScale );

 m_path.add_path(@rc ,0 ,false );

 DrawPath(AGG_FillAndStroke );

end;

procedure TfpgUltiboCanvas.RoundedRect(const x1 ,y1 ,x2 ,y2 ,rx ,ry : double );
var
 rc : rounded_rect;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.RoundedRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 rc.Construct;

 rc.rect  (x1 ,y1 ,x2 ,y2 );
 rc.radius(rx ,ry );
 rc.normalize_radius;

 m_path.add_path(@rc ,0 ,false );

 DrawPath(AGG_FillAndStroke );

end;

procedure TfpgUltiboCanvas.RoundedRect(const x1 ,y1 ,x2 ,y2 ,rxBottom ,ryBottom ,rxTop ,ryTop : double );
var
 rc : rounded_rect;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.RoundedRect'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 rc.Construct;

 rc.rect  (x1 ,y1 ,x2 ,y2 );
 rc.radius(rxBottom ,ryBottom ,rxTop ,ryTop );
 rc.normalize_radius;

 rc.approximation_scale_(worldToScreen(1.0 ) * g_approxScale );

 m_path.add_path(@rc ,0 ,false );

 DrawPath(AGG_FillAndStroke );
end;

procedure TfpgUltiboCanvas.Ellipse(const cx ,cy ,rx ,ry : double );
var
 el : bezier_arc;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Ellipse'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;

 el.Construct(cx ,cy ,rx ,ry ,0 ,2 * pi );

 m_path.add_path(@el ,0 ,false );
 m_path.close_polygon;

 DrawPath(AGG_FillAndStroke );
end;

procedure TfpgUltiboCanvas.Arc(const cx ,cy ,rx ,ry ,start ,sweep : double );
var
 ar : {bezier_}agg_arc.arc;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Arc'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;

 ar.Construct(cx ,cy ,rx ,ry ,sweep ,start ,false );

 m_path.add_path(@ar ,0 ,false );

 DrawPath(AGG_StrokeOnly );
end;

procedure TfpgUltiboCanvas.Star(const cx ,cy ,r1 ,r2 ,startAngle : double; const numRays : integer );
var
 da ,a ,x ,y : double;

 i : int;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Star'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;

 da:=pi / numRays;
 a :=startAngle;

 i:=0;

 while i < numRays do
  begin
   x:=Cos(a ) * r2 + cx;
   y:=Sin(a ) * r2 + cy;

   if i <> 0 then
    m_path.line_to(x ,y )
   else
    m_path.move_to(x ,y );

   a:=a + da;

   m_path.line_to(Cos(a ) * r1 + cx ,Sin(a ) * r1 + cy );

   a:=a + da;

   inc(i );

  end;

 ClosePolygon;
 DrawPath(AGG_FillAndStroke );
end;

procedure TfpgUltiboCanvas.Curve(const x1 ,y1 ,x2 ,y2 ,x3 ,y3 : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Curve'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 m_path.move_to(x1 ,y1 );
 m_path.curve3 (x2 ,y2 ,x3 ,y3 );

 DrawPath(AGG_StrokeOnly );
end;

procedure TfpgUltiboCanvas.Curve(const x1 ,y1 ,x2 ,y2 ,x3 ,y3 ,x4 ,y4 : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Curve'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 m_path.move_to(x1 ,y1 );
 m_path.curve4 (x2 ,y2 ,x3 ,y3 ,x4 ,y4 );

 DrawPath(AGG_StrokeOnly );
end;

procedure TfpgUltiboCanvas.Polygon(const xy : PDouble; numPoints : integer );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Polygon'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 m_path.add_poly(double_2_ptr(xy ) ,numPoints );

 ClosePolygon;
 DrawPath(AGG_FillAndStroke );
end;

procedure TfpgUltiboCanvas.Polyline(const xy : PDouble; numPoints : integer );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.Polyline'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 m_path.add_poly(double_2_ptr(xy ) ,numPoints );

 DrawPath(AGG_StrokeOnly );
end;
  
{Agg2D Path Commands}
procedure TfpgUltiboCanvas.ResetPath;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ResetPath'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.remove_all;
 m_path.move_to(0 ,0 );
end;

procedure TfpgUltiboCanvas.MoveTo(const x ,y : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.MoveTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.move_to(x ,y );
end;

procedure TfpgUltiboCanvas.MoveRel(const dx ,dy : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.MoveRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.move_rel(dx ,dy );
end;

procedure TfpgUltiboCanvas.LineTo(const x ,y : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.line_to(x ,y );
end;

procedure TfpgUltiboCanvas.LineRel(const dx ,dy : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.LineRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.line_rel(dx ,dy );
end;

procedure TfpgUltiboCanvas.HorLineTo(const x : double );
begin 
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.HorLineTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.hline_to(x );
end;

procedure TfpgUltiboCanvas.HorLineRel(const dx : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.HorLineRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.hline_rel(dx );
end;

procedure TfpgUltiboCanvas.VerLineTo(const y : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.VerLineTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.vline_to(y );
end;

procedure TfpgUltiboCanvas.VerLineRel(const dy : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.VerLineRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.vline_rel(dy );
end;

procedure TfpgUltiboCanvas.ArcTo(rx ,ry ,angle : double; largeArcFlag ,sweepFlag : boolean; x ,y : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ArcTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.arc_to(rx ,ry ,angle ,largeArcFlag ,sweepFlag ,x ,y );
end;

procedure TfpgUltiboCanvas.ArcRel(rx ,ry ,angle : double; largeArcFlag ,sweepFlag : boolean; dx ,dy : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ArcRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.arc_rel(rx ,ry ,angle ,largeArcFlag ,sweepFlag ,dx ,dy );
end;

procedure TfpgUltiboCanvas.QuadricCurveTo (xCtrl ,yCtrl ,xTo ,yTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.QuadricCurveTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve3(xCtrl ,yCtrl ,xTo ,yTo );
end;

procedure TfpgUltiboCanvas.QuadricCurveRel(dxCtrl ,dyCtrl ,dxTo ,dyTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.QuadricCurveRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve3_rel(dxCtrl ,dyCtrl ,dxTo ,dyTo );
end;

procedure TfpgUltiboCanvas.QuadricCurveTo (xTo ,yTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.QuadricCurveTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve3(xTo ,yTo );
end;

procedure TfpgUltiboCanvas.QuadricCurveRel(dxTo ,dyTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.QuadricCurveRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve3_rel(dxTo ,dyTo );
end;

procedure TfpgUltiboCanvas.CubicCurveTo (xCtrl1 ,yCtrl1 ,xCtrl2 ,yCtrl2 ,xTo ,yTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.CubicCurveTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve4(xCtrl1 ,yCtrl1 ,xCtrl2 ,yCtrl2 ,xTo ,yTo );
end;

procedure TfpgUltiboCanvas.CubicCurveRel(dxCtrl1 ,dyCtrl1 ,dxCtrl2 ,dyCtrl2 ,dxTo ,dyTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.CubicCurveRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve4_rel(dxCtrl1 ,dyCtrl1 ,dxCtrl2 ,dyCtrl2 ,dxTo ,dyTo );
end;

procedure TfpgUltiboCanvas.CubicCurveTo (xCtrl2 ,yCtrl2 ,xTo ,yTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.CubicCurveTo'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve4(xCtrl2 ,yCtrl2 ,xTo ,yTo );
end;

procedure TfpgUltiboCanvas.CubicCurveRel(dxCtrl2 ,dyCtrl2 ,dxTo ,dyTo : double );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.CubicCurveRel'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.curve4_rel(dxCtrl2 ,dyCtrl2 ,dxTo ,dyTo );
end;

procedure TfpgUltiboCanvas.AddEllipse(cx ,cy ,rx ,ry : double; dir : TAggDirection );
var
 ar : bezier_arc;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.AddEllipse'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if dir = AGG_CCW then
  ar.Construct(cx ,cy ,rx ,ry ,0 ,2 * pi )
 else
  ar.Construct(cx ,cy ,rx ,ry ,0 ,-2 * pi );

 m_path.add_path(@ar ,0 ,false );
 m_path.close_polygon;
end;

procedure TfpgUltiboCanvas.ClosePolygon;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ClosePolygon'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_path.close_polygon;
end;

procedure TfpgUltiboCanvas.DrawPath(flag : TAggDrawPathFlag = AGG_FillAndStroke );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.DrawPath'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_rasterizer.reset;

 case flag of
  AGG_FillOnly :
   if m_fillColor.a <> 0 then
    begin
     m_rasterizer.add_path(@m_pathTransform );

     render(true );

    end;

  AGG_StrokeOnly :
   if (m_lineColor.a <> 0 ) and
      (m_lineWidth > 0.0 ) then
    begin
     m_rasterizer.add_path(@m_strokeTransform );

     render(false );

    end;

  AGG_FillAndStroke :
   begin
    if m_fillColor.a <> 0 then
     begin
      m_rasterizer.add_path(@m_pathTransform );

      render(true );

     end;

    if (m_lineColor.a <> 0 ) and
       (m_lineWidth > 0.0 ) then
     begin
      m_rasterizer.add_path(@m_strokeTransform );

      render(false );

     end;

   end;

  AGG_FillWithLineColor :
   if m_lineColor.a <> 0 then
    begin
     m_rasterizer.add_path(@m_pathTransform );

     render(false );

    end;
 end;
end;
  
{Agg2D Text Rendering}
procedure TfpgUltiboCanvas.FlipText(const flip : boolean );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FlipText'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 {$IFNDEF AGG2D_NO_FONT}
 {$IFDEF AGG2D_USE_FREETYPE}
 m_fontEngine.flip_y_(not flip );
 {$ENDIF}
 {$IFDEF AGG2D_USE_RASTERFONTS}
 m_font_flip_y:=not(flip);
 {$ENDIF}
 {$ENDIF}
end;

procedure TfpgUltiboCanvas.FontSet(fileName : AnsiString; height : double; bold : boolean = false; italic : boolean = false; cache : TAggFontCacheType = AGG_VectorFontCache; angle : double = 0.0 );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FontSet'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_textAngle    :=angle;
 m_fontHeight   :=height;
 m_fontCacheType:=cache;

{$IFDEF AGG2D_USE_FREETYPE }
 if cache = AGG_VectorFontCache then
  m_fontEngine.load_font(PChar(fileName) ,0 ,glyph_ren_outline )
 else
  m_fontEngine.load_font(PChar(fileName) ,0 ,glyph_ren_agg_gray8 );

 m_fontEngine.hinting_(m_textHints );

 if cache = AGG_VectorFontCache then
 {$NOTE We need to fix this. Translating from font pt to pixels is inaccurate. This is just a temp fix for now. }
  m_fontEngine.height_(height * 1.3333 ) // 9pt = ~12px so that is a ratio of 1.3333
 else
  m_fontEngine.height_(worldToScreen(height ) );
{$ENDIF}
{$IFDEF AGG2D_USE_RASTERFONTS}
 //Ultibo To Do //Nothing ?
{$ENDIF}
end;

function TfpgUltiboCanvas.FontHeight : double;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.FontHeight'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_fontHeight;
end;

procedure TfpgUltiboCanvas.TextAlignment(alignX ,alignY : TAggTextAlignment );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextAlignment'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_textAlignX:=alignX;
 m_textAlignY:=alignY;
end;

function TfpgUltiboCanvas.TextHints : boolean;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextHints'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_textHints;
end;

procedure TfpgUltiboCanvas.TextHints(hints : boolean );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextHints'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_textHints:=hints;
 
 {$IFNDEF AGG2D_NO_FONT}
 {$IFDEF AGG2D_USE_FREETYPE}
 m_fontEngine.hinting_(m_textHints );
 {$ENDIF}
 {$IFDEF AGG2D_USE_RASTERFONTS}
 //Ultibo To Do //Nothing ?
 {$ENDIF}
 {$ENDIF}
end;

function TfpgUltiboCanvas.TextWidth(str : AnsiString ) : double;
{$IFDEF AGG2D_NO_FONT}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextWidth str=' + str); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=0;
end;
{$ELSE}
{$IFDEF AGG2D_USE_FREETYPE}
var
 x ,y  : double;
 first : boolean;
 glyph : glyph_cache_ptr;
 str_  : PChar;

begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextWidth str=' + str); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if str = '' then exit(0);
 x:=0;
 y:=0;

 first:=true;
 str_ := PChar(str);

 while str_^ <> #0 do
  begin
   glyph:=m_fontCacheManager.glyph(int32u(str_^ ) );

   if glyph <> NIL then
    begin
     if not first then
      m_fontCacheManager.add_kerning(@x ,@y );

     x:=x + glyph.advance_x;
     y:=y + glyph.advance_y;

     first:=false;

    end;

   inc(ptrcomp(str_ ) );

  end;

 if m_fontCacheType = AGG_VectorFontCache then
  result:=x
 else
  result:=ScreenToWorld(x );
end;
{$ENDIF}
{$IFDEF AGG2D_USE_RASTERFONTS}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextWidth str=' + str); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=m_fontGlyph.width(PChar(str));
end;
{$ENDIF}
{$ENDIF}

procedure TfpgUltiboCanvas.TextRender(x ,y : double; str : AnsiString; roundOff : boolean = false; ddx : double = 0.0; ddy : double = 0.0 );
{$IFDEF AGG2D_NO_FONT}
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextRender str=' + str); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 {Nothing}
end;
{$ELSE}
{$IFDEF AGG2D_USE_FREETYPE}
var
 dx ,dy ,asc ,start_x ,start_y : double;

 glyph : glyph_cache_ptr;

 mtx  : trans_affine;
 str_ : PChar;

 tat : trans_affine_translation;
 tar : trans_affine_rotation;

  tr : conv_transform;
  charlen: int;
  char_id: int32u;
  First: Boolean;

begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextRender str=' + str); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if Str='' then exit;

 dx:=0.0;
 dy:=0.0;

 case m_textAlignX of
  AGG_AlignCenter :
   dx:=-textWidth(str ) * 0.5;

  AGG_AlignRight :
   dx:=-textWidth(str );

 end;

 asc  :=fontHeight;
 glyph:=m_fontCacheManager.glyph(int32u('H' ) );

 if glyph <> NIL then
  asc:=glyph.bounds.y2 - glyph.bounds.y1;

 if m_fontCacheType = AGG_RasterFontCache then
  asc:=screenToWorld(asc );

 case m_textAlignY of
  AGG_AlignCenter :
   dy:=-asc * 0.5;

  AGG_AlignTop :
   dy:=-asc;

 end;

 if m_fontEngine._flip_y then
  dy:=-dy;

 mtx.Construct;

 start_x:=x + dx;
 start_y:=y + dy;

 if roundOff then
  begin
   start_x:=Trunc(start_x );
   start_y:=Trunc(start_y );

  end;

 start_x:=start_x + ddx;
 start_y:=start_y + ddy;

 tat.Construct(-x ,-y );
 mtx.multiply (@tat );

 tar.Construct(m_textAngle );
 mtx.multiply (@tar );

 tat.Construct(x ,y );
 mtx.multiply (@tat );

 tr.Construct(m_fontCacheManager.path_adaptor ,@mtx );

 if m_fontCacheType = AGG_RasterFontCache then
  WorldToScreen(@start_x ,@start_y );

  str_:=@str[1 ];
  First:=true;

  while str_^ <> #0 do
  begin
    char_id := UTF8CharToUnicode(str_, charlen);
    inc(str_, charlen);
    glyph := m_fontCacheManager.glyph(char_id);

    if glyph <> NIL then
    begin
      if First then
      begin
        m_fontCacheManager.add_kerning(@x ,@y );
        First:=false;
      end;

      m_fontCacheManager.init_embedded_adaptors(glyph ,start_x ,start_y );

      if glyph.data_type = glyph_data_outline then
      begin
       m_path.remove_all;
       m_path.add_path(@tr ,0 ,false );

       drawPath;

      end;

     if glyph.data_type = glyph_data_gray8 then
      begin
        Render(
          m_fontCacheManager.gray8_adaptor ,
          m_fontCacheManager.gray8_scanline );
      end;

     start_x := start_x + glyph.advance_x;
     start_y := start_y + glyph.advance_y;

    end;
  end;
end;
{$ENDIF}
{$IFDEF AGG2D_USE_RASTERFONTS}
var
 dx ,dy ,asc ,start_x ,start_y : double;

 clr : aggclr;
 
 rt : renderer_raster_htext_solid;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TextRender str=' + str); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if str = '' then exit;

 dx:=0.0;
 dy:=0.0;

 case m_textAlignX of
  AGG_AlignCenter :
   dx:=-textWidth(str ) * 0.5;
  AGG_AlignRight :
   dx:=-textWidth(str );
 end;

 asc:=fontHeight;
 
 case m_textAlignY of
  AGG_AlignCenter :
   dy:=-asc * 0.5;
  AGG_AlignTop :
   dy:=-asc;
 end;
 
 if m_font_flip_y then dy:=-dy;
 
 start_x:=x + dx;
 start_y:=y + dy;

 if roundOff then
  begin
   start_x:=Trunc(start_x );
   start_y:=Trunc(start_y );
  end;

 start_x:=start_x + ddx;
 start_y:=start_y + ddy;
 
 rt.Construct(@m_renBase ,@m_fontGlyph );
 
 clr.Construct(m_fillColor );
 
 rt.color_(@clr);
 
 rt.render_text(start_x ,start_y ,PChar(str) ,m_font_flip_y);
end;
{$ENDIF}
{$ENDIF}
  
{Agg2D Image Rendering}
procedure TfpgUltiboCanvas.ImageFilter(f : TAggImageFilter );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ImageFilter'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_imageFilter:=f;

 case f of
  AGG_Bilinear :
   m_imageFilterLut.calculate(@m_ifBilinear ,true );

  AGG_Hanning :
   m_imageFilterLut.calculate(@m_ifHanning ,true );

  AGG_Hermite :
   m_imageFilterLut.calculate(@m_ifHermite ,true );

  AGG_Quadric :
   m_imageFilterLut.calculate(@m_ifQuadric ,true );

  AGG_Bicubic :
   m_imageFilterLut.calculate(@m_ifBicubic ,true );

  AGG_Catrom :
   m_imageFilterLut.calculate(@m_ifCatrom ,true );

  AGG_Spline16 :
   m_imageFilterLut.calculate(@m_ifSpline16 ,true );

  AGG_Spline36 :
   m_imageFilterLut.calculate(@m_ifSpline36 ,true );

  AGG_Blackman144 :
   m_imageFilterLut.calculate(@m_ifBlackman144 ,true );

 end;
end;

function TfpgUltiboCanvas.ImageFilter : TAggImageFilter;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ImageFilter'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_imageFilter;
end;

procedure TfpgUltiboCanvas.ImageResample(f : TAggImageResample );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ImageResample'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_imageResample:=f;
end;

function TfpgUltiboCanvas.ImageResample : TAggImageResample;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ImageResample'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 result:=m_imageResample;
end;

procedure TfpgUltiboCanvas.ImageFlip(f : boolean );
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.ImageFlip'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 m_imageFlip:=f;
end;

procedure TfpgUltiboCanvas.TransformImage(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; dstX1 ,dstY1 ,dstX2 ,dstY2 : double );
var
 parall : array[0..5 ] of double;
 image  : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   resetPath;
   moveTo(dstX1 ,dstY1 );
   lineTo(dstX2 ,dstY1 );
   lineTo(dstX2 ,dstY2 );
   lineTo(dstX1 ,dstY2 );
   closePolygon;

   parall[0 ]:=dstX1;
   parall[1 ]:=dstY1;
   parall[2 ]:=dstX2;
   parall[3 ]:=dstY1;
   parall[4 ]:=dstX2;
   parall[5 ]:=dstY2;

   renderImage(@image ,imgX1 ,imgY1 ,imgX2 ,imgY2 ,@parall[0 ] );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.TransformImage(bitmap : TfpgUltiboImage; dstX1 ,dstY1 ,dstX2 ,dstY2 : double );
var
 parall : array[0..5 ] of double;
 image  : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   ResetPath;
   MoveTo(dstX1 ,dstY1 );
   LineTo(dstX2 ,dstY1 );
   LineTo(dstX2 ,dstY2 );
   LineTo(dstX1 ,dstY2 );
   ClosePolygon;

   parall[0 ]:=dstX1;
   parall[1 ]:=dstY1;
   parall[2 ]:=dstX2;
   parall[3 ]:=dstY1;
   parall[4 ]:=dstX2;
   parall[5 ]:=dstY2;

   renderImage(@image ,0 ,0 ,image.renBuf._width ,image.renBuf._height ,@parall[0 ] );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.TransformImage(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; parallelo : PDouble );
var
 image : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   ResetPath;

   MoveTo(
    PDouble(ptrcomp(parallelo ) + 0 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 1 * sizeof(double ) )^ );

   LineTo(
    PDouble(ptrcomp(parallelo ) + 2 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 3 * sizeof(double ) )^ );

   LineTo(
    PDouble(ptrcomp(parallelo ) + 4 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 5 * sizeof(double ) )^ );

   LineTo(
    PDouble(ptrcomp(parallelo ) + 0 * sizeof(double ) )^ +
    PDouble(ptrcomp(parallelo ) + 4 * sizeof(double ) )^ -
    PDouble(ptrcomp(parallelo ) + 2 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 1 * sizeof(double ) )^ +
    PDouble(ptrcomp(parallelo ) + 5 * sizeof(double ) )^ -
    PDouble(ptrcomp(parallelo ) + 3 * sizeof(double ) )^ );

   ClosePolygon;

   renderImage(@image ,imgX1 ,imgY1 ,imgX2 ,imgY2 ,parallelo );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.TransformImage(bitmap : TfpgUltiboImage; parallelo : PDouble );
var
 image : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   ResetPath;

   MoveTo(
    PDouble(ptrcomp(parallelo ) + 0 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 1 * sizeof(double ) )^ );

   LineTo(
    PDouble(ptrcomp(parallelo ) + 2 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 3 * sizeof(double ) )^ );

   LineTo(
    PDouble(ptrcomp(parallelo ) + 4 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 5 * sizeof(double ) )^ );

   LineTo(
    PDouble(ptrcomp(parallelo ) + 0 * sizeof(double ) )^ +
    PDouble(ptrcomp(parallelo ) + 4 * sizeof(double ) )^ -
    PDouble(ptrcomp(parallelo ) + 2 * sizeof(double ) )^ ,
    PDouble(ptrcomp(parallelo ) + 1 * sizeof(double ) )^ +
    PDouble(ptrcomp(parallelo ) + 5 * sizeof(double ) )^ -
    PDouble(ptrcomp(parallelo ) + 3 * sizeof(double ) )^ );

   ClosePolygon;

   renderImage(@image ,0 ,0 ,image.renBuf._width ,image.renBuf._height ,parallelo );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.TransformImagePath(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; dstX1 ,dstY1 ,dstX2 ,dstY2 : double );
var
 parall : array[0..5 ] of double;
 image  : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImagePath'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   parall[0 ]:=dstX1;
   parall[1 ]:=dstY1;
   parall[2 ]:=dstX2;
   parall[3 ]:=dstY1;
   parall[4 ]:=dstX2;
   parall[5 ]:=dstY2;

   renderImage(@image ,imgX1 ,imgY1 ,imgX2 ,imgY2 ,@parall[0 ] );

   image.Destruct;
  end;
end;

{ TRANSFORMIMAGEPATH }
procedure TfpgUltiboCanvas.TransformImagePath(bitmap : TfpgUltiboImage; dstX1 ,dstY1 ,dstX2 ,dstY2 : double );
var
 parall : array[0..5 ] of double;
 image  : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImagePath'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   parall[0 ]:=dstX1;
   parall[1 ]:=dstY1;
   parall[2 ]:=dstX2;
   parall[3 ]:=dstY1;
   parall[4 ]:=dstX2;
   parall[5 ]:=dstY2;

   renderImage(@image ,0 ,0 ,image.renBuf._width ,image.renBuf._height ,@parall[0 ] );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.TransformImagePath(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer;  parallelo : PDouble );
var
 image : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImagePath'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   renderImage(@image ,imgX1 ,imgY1 ,imgX2 ,imgY2 ,parallelo );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.TransformImagePath(bitmap : TfpgUltiboImage; parallelo : PDouble );
var
 image : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.TransformImagePath'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   renderImage(@image ,0 ,0 ,image.renBuf._width ,image.renBuf._height ,parallelo );

   image.Destruct;
  end;
end;
  
procedure TfpgUltiboCanvas.CopyImage(bitmap : TfpgUltiboImage; imgX1 ,imgY1 ,imgX2 ,imgY2 : integer; dstX ,dstY : double );
var
 r     : agg_basics.rect;
 image : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.CopyImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   WorldToScreen(@dstX ,@dstY );
   r.Construct  (imgX1 ,imgY1 ,imgX2 ,imgY2 );

   m_renBase.copy_from(@image.renBuf ,@r ,Trunc(dstX ) - imgX1 ,Trunc(dstY ) - imgY1 );

   image.Destruct;
  end;
end;

procedure TfpgUltiboCanvas.CopyImage(bitmap : TfpgUltiboImage; dstX ,dstY : double );
var
 image : TAggImage;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboCanvas.CopyImage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 image.Construct;

 if image.attach(bitmap ,m_imageFlip ) then
  begin
   WorldToScreen(@dstX ,@dstY );

   m_renBase.copy_from(@image.renBuf ,NIL ,Trunc(dstX ) ,Trunc(dstY ) );

   image.Destruct;
  end;
end;
  
  
{ TfpgUltiboWindow }
  
procedure TfpgUltiboWindow.DoAllocateWindowHandle(AParent: TfpgWindowBase);
begin
  {$IFDEF DEBUG}
  LoggingOutput('TfpgUltiboWindow.DoAllocateWindowHandle'); //Ultibo To Do //Implement simpleipc for SendDebug
  {$ENDIF DEBUG} 
  
  if FWinHandle > 0 then Exit; 
  
  if DefaultApplication = nil then Exit;
  
  FWinHandle:=DefaultApplication.DoGetWindowHandle; 
  
  if waAutoPos in FWindowAttributes then
  begin
    FLeft := TfpgCoord(0);
    FTop  := TfpgCoord(0);
  end;
  
  if waFullScreen in FWindowAttributes then
    SetFullscreen(True);
  
  if waScreenCenterPos in FWindowAttributes then
  begin
    FLeft := (DefaultApplication.ScreenWidth - FWidth) div 2;
    FTop  := (DefaultApplication.ScreenHeight - FHeight) div 2;
    DoMoveWindow(FLeft, FTop);
  end
  else if waOneThirdDownPos in FWindowAttributes then
  begin
    FLeft := (DefaultApplication.ScreenWidth - FWidth) div 2;
    FTop  := (DefaultApplication.ScreenHeight - FHeight) div 3;
    DoMoveWindow(FLeft, FTop);
  end;
  
  //Ultibo To do
  
end;
  
procedure TfpgUltiboWindow.DoReleaseWindowHandle;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoReleaseWindowHandle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do
 
 if FWinHandle <= 0 then Exit;
 FWinHandle:=0;
end;

procedure TfpgUltiboWindow.DoRemoveWindowLookup;
begin
  {$IFDEF DEBUG}
  LoggingOutput('TfpgUltiboWindow.DoRemoveWindowLookup'); //Ultibo To Do //Implement simpleipc for SendDebug
  {$ENDIF DEBUG} 
  
  // Nothing to do here
end;
  
procedure TfpgUltiboWindow.DoSetWindowVisible(const AValue: Boolean);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoSetWindowVisible Value=' + BoolToStr(AValue)); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if AValue then
  begin
   fpgSendMessage(nil,Self,FPGM_PAINT);
  end
 else
  begin 
   //Ultibo To do 
  end; 
end;
  
procedure TfpgUltiboWindow.DoMoveWindow(const x: TfpgCoord; const y: TfpgCoord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoMoveWindow x=' + IntToStr(x) + ' y=' + IntToStr(y)); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

function TfpgUltiboWindow.DoWindowToScreen(ASource: TfpgWindowBase; const AScreenPos: TPoint): TPoint;
begin
  {$IFDEF DEBUG}
  LoggingOutput('TfpgUltiboWindow.DoWindowToScreen'); //Ultibo To Do //Implement simpleipc for SendDebug
  {$ENDIF DEBUG} 
  
  if not TfpgUltiboWindow(ASource).HandleIsValid then  Exit; 

  Result.X := AScreenPos.X;
  Result.Y := AScreenPos.Y;
  //Ultibo To do 
end;
  
procedure TfpgUltiboWindow.DoSetWindowTitle(const atitle: string);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoSetWindowTitle Title=' + atitle); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do  
end;
  
procedure TfpgUltiboWindow.DoSetMouseCursor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoSetMouseCursor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;
  
procedure TfpgUltiboWindow.DoDNDEnabled(const AValue: boolean);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoDNDEnabled'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

procedure TfpgUltiboWindow.DoAcceptDrops(const AValue: boolean);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoAcceptDrops'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

procedure TfpgUltiboWindow.DoDragStartDetected;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoDragStartDetected'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;
 
function TfpgUltiboWindow.GetWindowState: TfpgWindowState;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.GetWindowState'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=inherited GetWindowState;
 //Ultibo To do //Nothing ?
end;

constructor TfpgUltiboWindow.Create(AOwner: TComponent);
begin
  {$IFDEF DEBUG}
  LoggingOutput('TfpgUltiboWindow.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
  {$ENDIF DEBUG} 
  
  inherited Create(AOwner);
  FWinHandle:=0;
end;

destructor TfpgUltiboWindow.Destroy;
begin
  {$IFDEF DEBUG}
  LoggingOutput('TfpgUltiboWindow.Destroy'); //Ultibo To Do //Implement simpleipc for SendDebug
  {$ENDIF DEBUG} 
  
  inherited Destroy;
end;

procedure TfpgUltiboWindow.ActivateWindow;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.ActivateWindow'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

procedure TfpgUltiboWindow.CaptureMouse;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.CaptureMouse'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

procedure TfpgUltiboWindow.ReleaseMouse;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.ReleaseMouse'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

procedure TfpgUltiboWindow.SetFullscreen(AValue: Boolean);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.SetFullscreen'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited SetFullscreen(AValue);
 Left      := 0;
 Top       := 0;
 Width     := DefaultApplication.GetScreenWidth;
 Height    := DefaultApplication.GetScreenHeight;
 //Ultibo To do 
end;

procedure TfpgUltiboWindow.BringToFront;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.BringToFront'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;

function TfpgUltiboWindow.HandleIsValid: boolean;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.HandleIsValid'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=FWinHandle > 0;
end;

procedure TfpgUltiboWindow.DoUpdateWindowPosition;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboWindow.DoUpdateWindowPosition'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do 
end;
 

{ TfpgUltiboApplication }

procedure TfpgUltiboApplication.DoWakeMainThread(Sender: TObject);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.DoWakeMainThread'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;

function TfpgUltiboApplication.DoGetWindowHandle:TfpgWinHandle;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.DoGetWindowHandle'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if FParent <> nil then
  begin
   Result:=FParent.DoGetWindowHandle;
  end
 else
  begin 
   Lock;
   
   Inc(FNextHandle);
   
   Result:=FNextHandle;
  
   Unlock;
  end; 
end;

function TfpgUltiboApplication.DoGetFontFaceList: TStringList;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.DoGetFontFaceList'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 

 Result := TStringList.Create;
  //Ultibo To do
end;
  
constructor TfpgUltiboApplication.Create(const AParams: string);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create(AParams);
 FParent:=DefaultApplication;
 if FParent = nil then
  begin
   FFramebuffer:=FramebufferDeviceGetDefault;
   DefaultApplication:=TfpgApplication(Self);
   WakeMainThread:=DoWakeMainThread;
  end; 
  
 Terminated:=False;
 FIsInitialized:=True;  
 FNextHandle:=0;
end;

destructor TfpgUltiboApplication.Destroy;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.Destroy'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 FFramebuffer:=nil;
 FParent:=nil;
 if Self = DefaultApplication then
  begin
   DefaultApplication:=nil;
   WakeMainThread:=nil;
  end;
 inherited Destroy;
end;
  
function TfpgUltiboApplication.MessagesPending: boolean;
begin 
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.MessagesPending'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=False;
 //Ultibo To Do
end;
 
procedure TfpgUltiboApplication.DoWaitWindowMessage(atimeoutms: integer);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.DoWaitWindowMessage'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if (atimeoutms >= 0) and (not MessagesPending) then
  begin
   if Assigned(FOnIdle) then OnIdle(self);
  end;

 //Ultibo To do
end;
 
procedure TfpgUltiboApplication.DoPutFramebufferRect(x, y, w, h: TfpgCoord; src: Pointer; stride: LongWord);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.DoPutFramebufferRect (x=' + IntToStr(x) + ' y=' + IntToStr(y) + ' w=' + IntToStr(w) + ' h=' + IntToStr(h) + ' stride=' + IntToStr(stride) + ')'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 

 if FParent <> nil then
  begin
   FParent.DoPutFramebufferRect(x, y, w, h, src, stride);
  end
 else
  begin 
   if FFramebuffer = nil then
    begin
     FFramebuffer:=FramebufferDeviceGetDefault;
    end;
   
   if FFramebuffer = nil then Exit;
   
   FramebufferDevicePutRect(FFramebuffer, x, y, src, w, h, stride, FRAMEBUFFER_TRANSFER_DMA);
  end;  
end;
 
procedure TfpgUltiboApplication.DoFlush;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.DoFlush'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do
end;

function TfpgUltiboApplication.GetScreenWidth: TfpgCoord;
var
 Properties:TFramebufferProperties;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.GetScreenWidth'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if FParent <> nil then
  begin
   Result:=FParent.GetScreenWidth;
  end
 else
  begin 
   if FFramebuffer = nil then
    begin
     FFramebuffer:=FramebufferDeviceGetDefault;
    end;
   
   if FramebufferDeviceGetProperties(FFramebuffer,@Properties) = ERROR_SUCCESS then
    begin
     Result:=Properties.PhysicalWidth;
    end;
  end;  
end;

function TfpgUltiboApplication.GetScreenHeight: TfpgCoord;
var
 Properties:TFramebufferProperties;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.GetScreenHeight'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 if FParent <> nil then
  begin
   Result:=FParent.GetScreenHeight;
  end
 else
  begin 
   if FFramebuffer = nil then
    begin
     FFramebuffer:=FramebufferDeviceGetDefault;
    end;
   
   if FramebufferDeviceGetProperties(FFramebuffer,@Properties) = ERROR_SUCCESS then
    begin
     Result:=Properties.PhysicalHeight;
    end;
  end;  
end;

function TfpgUltiboApplication.GetScreenPixelColor(APos: TPoint): TfpgColor;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.GetScreenPixelColor'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do
end;

function TfpgUltiboApplication.Screen_dpi_x: integer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.Screen_dpi_x'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do
end;

function TfpgUltiboApplication.Screen_dpi_y: integer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.Screen_dpi_y'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do
end;

function TfpgUltiboApplication.Screen_dpi: integer;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboApplication.Screen_dpi'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To do
end;
  
  
{ TfpgUltiboClipboard }

function TfpgUltiboClipboard.DoGetText: TfpgString;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboClipboard.DoGetText'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=FClipboardText;
end;

procedure TfpgUltiboClipboard.DoSetText(const AValue: TfpgString);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboClipboard.DoSetText'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 FClipboardText:=AValue;
end;

procedure TfpgUltiboClipboard.InitClipboard;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboClipboard.InitClipboard'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 // nothing to do here
end;
  
{ TfpgUltiboFileList }

function TfpgUltiboFileList.EncodeAttributesString(attrs: longword ): TFileModeString;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFileList.EncodeAttributesString'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:='';
 //if (attrs and FILE_ATTRIBUTE_ARCHIVE) <> 0    then s := s + 'a' else s := s + ' ';
 if (attrs and FILE_ATTRIBUTE_HIDDEN) <> 0     then Result := Result + 'h';
 if (attrs and FILE_ATTRIBUTE_READONLY) <> 0   then Result := Result + 'r';
 if (attrs and FILE_ATTRIBUTE_SYSTEM) <> 0     then Result := Result + 's';
 if (attrs and FILE_ATTRIBUTE_TEMPORARY) <> 0  then Result := Result + 't';
 if (attrs and FILE_ATTRIBUTE_COMPRESSED) <> 0 then Result := Result + 'c';
end;

constructor TfpgUltiboFileList.Create;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFileList.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create;
 FHasFileMode := false;
end;

function TfpgUltiboFileList.InitializeEntry(sr: TSearchRec): TFileEntry;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFileList.InitializeEntry'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result := inherited InitializeEntry(sr);
 if Assigned(Result) then
  begin
   // using sr.Attr here is incorrect and needs to be improved!
   Result.Attributes   := EncodeAttributesString(sr.Attr);
   Result.IsExecutable := (LowerCase(Result.Extension) = '.exe');
  end;
end;

procedure TfpgUltiboFileList.PopulateSpecialDirs(const aDirectory: TfpgString);
const
  MAX_DRIVES = 25;
var
  n: integer;
  drvs: string;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboFileList.PopulateSpecialDirs'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 FSpecialDirs.Clear;

 // making drive list
 if Copy(aDirectory, 2, 1) = ':' then
  begin
   n := 0;
   while n <= MAX_DRIVES do
    begin
     drvs := chr(n+ord('A'))+':\';
     if SysUtils.DiskSize(n + 1) <> -1 then
      begin
       FSpecialDirs.Add(drvs);
      end;
     inc(n);
    end;
  end;

 inherited PopulateSpecialDirs(aDirectory);
end;
  
{ TfpgUltiboDrag }
  
function TfpgUltiboDrag.GetSource: TfpgUltiboWindow; 
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboDrag.GetSource'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=FSource;
end;

destructor TfpgUltiboDrag.Destroy; 
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboDrag.Destroy'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 {$IFDEF DND_DEBUG}
 SendDebug('TfpgUltiboDrag.Destroy ');
 {$ENDIF}
 inherited Destroy;
end;

function TfpgUltiboDrag.Execute(const ADropActions: TfpgDropActions; const ADefaultAction: TfpgDropAction=daCopy): TfpgDropAction; 
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboDrag.Execute'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;
  
procedure TimerCallBackProc(Data:Pointer);
begin
 { idEvent contains the handle to the timer that got triggered }
 fpgCheckTimers;
end;
  
{ TfpgUltiboTimer }

procedure TfpgUltiboTimer.SetEnabled(const AValue: boolean);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboTimer.SetEnabled'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited SetEnabled(AValue);
 if FEnabled then
  begin
   FHandle:=Threads.TimerCreateEx(Interval,TIMER_STATE_ENABLED,TIMER_FLAG_WORKER or TIMER_FLAG_RESCHEDULE,TTimerEvent(@TimerCallBackProc),nil);
  end
 else
  begin
   if FHandle <> INVALID_HANDLE_VALUE then
    begin
     Threads.TimerDestroy(FHandle);
     FHandle:=INVALID_HANDLE_VALUE;
    end;
  end;
end;

constructor TfpgUltiboTimer.Create(AInterval: integer);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboTimer.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create(AInterval);
 FHandle:=INVALID_HANDLE_VALUE;
end;
  
{ TfpgUltiboSystemTrayIcon }

constructor TfpgUltiboSystemTrayIcon.Create(AOwner: TComponent);
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboSystemTrayIcon.Create'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 inherited Create(AOwner);
end;

procedure TfpgUltiboSystemTrayIcon.Show;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboSystemTrayIcon.Show'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;

procedure TfpgUltiboSystemTrayIcon.Hide;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboSystemTrayIcon.Hide'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 //Ultibo To Do
end;

function TfpgUltiboSystemTrayIcon.IsSystemTrayAvailable: boolean;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboSystemTrayIcon.IsSystemTrayAvailable'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=False;
end;

function TfpgUltiboSystemTrayIcon.SupportsMessages: boolean;
begin
 {$IFDEF DEBUG}
 LoggingOutput('TfpgUltiboSystemTrayIcon.SupportsMessages'); //Ultibo To Do //Implement simpleipc for SendDebug
 {$ENDIF DEBUG} 
 
 Result:=True;
end;
  
initialization
 {Internal Variables}
 DefaultApplication:=nil;
 
 {Disable Console Autocreate}
 FRAMEBUFFER_CONSOLE_AUTOCREATE:=False;
 
finalization
 {Nothing}
 
end.
  
//
//  XRGraphic.h
//  XRose
//
//  Created by Tom Moore on Tue Jan 06 2004.
//
// MIT License
//
// Copyright (c) 2004 to present Thomas L. Moore.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Cocoa/Cocoa.h>
#import "GraphicGeometrySource.h"
NS_ASSUME_NONNULL_BEGIN

static NSString const * XRGraphicKeyGraphicType = @"GraphicType";
static NSString const * XRGraphicKeyStrokeColor = @"_strokeColor";
static NSString const * XRGraphicKeyFillColor = @"_fillColor";
static NSString const * XRGraphicKeyLineWidth = @"_lineWidth";

static NSString const * XRGraphicKeyMaxRadius = @"_maxRadius";
static NSString const * XRGraphicKeyPetalIncrement = @"_petalIncrement";
static NSString const * XRGraphicKeyAngleIncrement = @"_angleIncrement";
static NSString const * XRGraphicKeyHistogramIncrement = @"_histIncrement";
static NSString const * XRGraphicKeyDotSize = @"_dotSize";
static NSString const * XRGraphicKeyPercent = @"_percent";
static NSString const * XRGraphicKeyCount = @"_count";
static NSString const * XRGraphicKeyTotalCount = @"_totalCount";
static NSString const * XRGraphicKeyRelativePercent = @"_relativePercent";
static NSString const * XRGraphicKeyAngleSetting = @"_angleSetting";
static NSString const * XRGraphicKeyTickType = @"_tickType";
static NSString const * XRGraphicKeyShowTick = @"_showTick";
static NSString const * XRGraphicKeySpokeNumberAlignment = @"_spokeNumberAlign";
static NSString const * XRGraphicKeySpokeNumberCompassPoint = @"_spokeNumberCompassPoint";
static NSString const * XRGraphicKeySpokeNumberOrder = @"_spokeNumberOrder";
static NSString const * XRGraphicKeyShowLabel = @"_showLabel";
static NSString const * XRGraphicKeyLineLabel = @"_lineLabel";
static NSString const * XRGraphicKeyCurrentFont = @"_currentFont";
static NSString const * XRGraphicKeyLabelAngle = @"_labelAngle";
static NSString const * XRGraphicKeyLabel = @"Label";
static NSString const * XRGraphicKeyLabelFont = @"_labelFont";
static NSString const * XRGraphicKeyIsCore = @"_isCore";
static NSString const * XRGraphicKeyCountSetting = @"_countSetting";
static NSString const * XRGraphicKeyPercentSetting = @"_percentSetting";
static NSString const * XRGraphicKeyGeometryPercent = @"_geometryPercent";
static NSString const * XRGraphicKeyIsGeometryPercent = @"_isGeometryPercent";
static NSString const * XRGraphicKeyIsPercent = @"_isPercent";
static NSString const * XRGraphicKeyIsFixedCount = @"_isFixedCount";

static NSString const * GraphicTypeGraphic = @"Graphic";
static NSString const * GraphicTypeCircle = @"Circle";
static NSString const * GraphicTypeLabelCircle = @"LabelCircle";
static NSString const * GraphicTypeLine = @"Line";
static NSString const * GraphicTypeKite = @"Kite";
static NSString const * GraphicTypePetal = @"Petal";
static NSString const * GraphicTypeDot = @"Dot";
static NSString const * GraphicTypeHistogram = @"Histogram";
static NSString const * GraphicTypeDotDeviation = @"DotDeviation";

@class XRGeometryController;

@interface XRGraphic : NSObject

@property(nonatomic, weak) XRGeometryController *geometryController;
@property (nonatomic, nullable) NSBezierPath *drawingPath;
@property (nonatomic, nullable) NSColor *fillColor;
@property (nonatomic, nullable) NSColor *strokeColor;
@property (readwrite) BOOL drawsFill;
@property (readwrite) float lineWidth;
@property (readwrite) BOOL needsDisplay;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithController:(id<GraphicGeometrySource>)controller;

-(void)geometryDidChange:(NSNotification *)aNotification;

-(void)calculateGeometry;

-(NSRect)drawingRect;
-(void)drawRect:(NSRect )aRect;

- (BOOL)hitTest:(NSPoint)point;

-(void)setDefaultStrokeColor;

-(void)setDefaultFillColor;

-(void)setLineColor:(nullable NSColor *)aLineColor fillColor:(nullable NSColor *)aFillColor;

-(void)setTransparency:(float)alpha;

-(NSDictionary *)graphicSettings;

-(NSString *)stringFromBool:(BOOL)boolValue;
-(NSString *)stringFromInt:(int)intValue;
-(NSString *)stringFromFloat:(float)floatValue;

@end

NS_ASSUME_NONNULL_END

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

static const NSString * XRGraphicKeyGraphicType = @"GraphicType";
static const NSString * XRGraphicKeyStrokeColor = @"_strokeColor";
static const NSString * XRGraphicKeyFillColor = @"_fillColor";
static const NSString * XRGraphicKeyLineWidth = @"_lineWidth";

static const NSString * XRGraphicKeyMaxRadius = @"_maxRadius";
static const NSString * XRGraphicKeyPetalIncrement = @"_petalIncrement";
static const NSString * XRGraphicKeyAngleIncrement = @"_angleIncrement";
static const NSString * XRGraphicKeyHistogramIncrement = @"_histIncrement";
static const NSString * XRGraphicKeyDotSize = @"_dotSize";
static const NSString * XRGraphicKeyPercent = @"_percent";
static const NSString * XRGraphicKeyCount = @"_count";
static const NSString * XRGraphicKeyTotalCount = @"_totalCount";
static const NSString * XRGraphicKeyRelativePercent = @"_relativePercent";
static const NSString * XRGraphicKeyAngleSetting = @"_angleSetting";
static const NSString * XRGraphicKeyTickType = @"_tickType";
static const NSString * XRGraphicKeyShowTick = @"_showTick";
static const NSString * XRGraphicKeySpokeNumberAlignment = @"_spokeNumberAlign";
static const NSString * XRGraphicKeySpokeNumberCompassPoint = @"_spokeNumberCompassPoint";
static const NSString * XRGraphicKeySpokeNumberOrder = @"_spokeNumberOrder";
static const NSString * XRGraphicKeyShowLabel = @"_showLabel";
static const NSString * XRGraphicKeyLineLabel = @"_lineLabel";
static const NSString * XRGraphicKeyCurrentFont = @"_currentFont";
static const NSString * XRGraphicKeyLabelAngle = @"_labelAngle";
static const NSString * XRGraphicKeyLabel = @"Label";
static const NSString * XRGraphicKeyLabelFont = @"_labelFont";
static const NSString * XRGraphicKeyIsCore = @"_isCore";
static const NSString * XRGraphicKeyCountSetting = @"_countSetting";
static const NSString * XRGraphicKeyPercentSetting = @"_percentSetting";
static const NSString * XRGraphicKeyGeometryPercent = @"_geometryPercent";
static const NSString * XRGraphicKeyIsGeometryPercent = @"_isGeometryPercent";
static const NSString * XRGraphicKeyIsPercent = @"_isPercent";
static const NSString * XRGraphicKeyIsFixedCount = @"_isFixedCount";

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

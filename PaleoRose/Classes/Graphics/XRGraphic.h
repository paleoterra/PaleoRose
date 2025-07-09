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

static const NSString * _Nonnull XRGraphicKeyGraphicType = @"GraphicType";
static const NSString * _Nonnull XRGraphicKeyStrokeColor = @"_strokeColor";
static const NSString * _Nonnull XRGraphicKeyFillColor = @"_fillColor";
static const NSString * _Nonnull XRGraphicKeyLineWidth = @"_lineWidth";

static const NSString *  _Nonnull XRGraphicKeyMaxRadius = @"_maxRadius";
static const NSString *  _Nonnull XRGraphicKeyPetalIncrement = @"_petalIncrement";
static const NSString *  _Nonnull XRGraphicKeyAngleIncrement = @"_angleIncrement";
static const NSString *  _Nonnull XRGraphicKeyHistogramIncrement = @"_histIncrement";
static const NSString *  _Nonnull XRGraphicKeyDotSize = @"_dotSize";
static const NSString *  _Nonnull XRGraphicKeyPercent = @"_percent";
static const NSString *  _Nonnull XRGraphicKeyCount = @"_count";
static const NSString *  _Nonnull XRGraphicKeyTotalCount = @"_totalCount";
static const NSString *  _Nonnull XRGraphicKeyRelativePercent = @"_relativePercent";
static const NSString *  _Nonnull XRGraphicKeyAngleSetting = @"_angleSetting";
static const NSString *  _Nonnull XRGraphicKeyTickType = @"_tickType";
static const NSString *  _Nonnull XRGraphicKeyShowTick = @"_showTick";
static const NSString *  _Nonnull XRGraphicKeySpokeNumberAlignment = @"_spokeNumberAlign";
static const NSString *  _Nonnull XRGraphicKeySpokeNumberCompassPoint = @"_spokeNumberCompassPoint";
static const NSString *  _Nonnull XRGraphicKeySpokeNumberOrder = @"_spokeNumberOrder";
static const NSString *  _Nonnull XRGraphicKeyShowLabel = @"_showLabel";
static const NSString *  _Nonnull XRGraphicKeyLineLabel = @"_lineLabel";
static const NSString *  _Nonnull XRGraphicKeyCurrentFont = @"_currentFont";
static const NSString *  _Nonnull XRGraphicKeyLabelAngle = @"_labelAngle";
static const NSString *  _Nonnull XRGraphicKeyLabel = @"Label";
static const NSString *  _Nonnull XRGraphicKeyLabelFont = @"_labelFont";
static const NSString *  _Nonnull XRGraphicKeyIsCore = @"_isCore";
static const NSString *  _Nonnull XRGraphicKeyCountSetting = @"_countSetting";
static const NSString *  _Nonnull XRGraphicKeyPercentSetting = @"_percentSetting";
static const NSString *  _Nonnull XRGraphicKeyGeometryPercent = @"_geometryPercent";
static const NSString *  _Nonnull XRGraphicKeyIsGeometryPercent = @"_isGeometryPercent";
static const NSString *  _Nonnull XRGraphicKeyIsPercent = @"_isPercent";
static const NSString *  _Nonnull XRGraphicKeyIsFixedCount = @"_isFixedCount";
// #define XRGraphicKey

NS_ASSUME_NONNULL_BEGIN

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
-(instancetype)initWithController:(XRGeometryController *)controller;

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

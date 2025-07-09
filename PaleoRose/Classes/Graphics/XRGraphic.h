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

#define XRGraphicKeyGraphicType @"GraphicType"
#define XRGraphicKeyStrokeColor @"_strokeColor"
#define XRGraphicKeyFillColor @"_fillColor"
#define XRGraphicKeyLineWidth @"_lineWidth"

#define XRGraphicKeyMaxRadius @"_maxRadius"
#define XRGraphicKeyPetalIncrement @"_petalIncrement"
#define XRGraphicKeyAngleIncrement @"_angleIncrement"
#define XRGraphicKeyHistogramIncrement @"_histIncrement"
#define XRGraphicKeyDotSize @"_dotSize"
#define XRGraphicKeyPercent @"_percent"
#define XRGraphicKeyCount @"_count"
#define XRGraphicKeyTotalCount @"_totalCount"
#define XRGraphicKeyRelativePercent @"_relativePercent"
#define XRGraphicKeyAngleSetting @"_angleSetting"
#define XRGraphicKeyTickType @"_tickType"
#define XRGraphicKeyShowTick @"_showTick"
#define XRGraphicKeySpokeNumberAlignment @"_spokeNumberAlign"
#define XRGraphicKeySpokeNumberCompassPoint @"_spokeNumberCompassPoint"
#define XRGraphicKeySpokeNumberOrder @"_spokeNumberOrder"
#define XRGraphicKeyShowLabel @"_showLabel"
#define XRGraphicKeyLineLabel @"_lineLabel"
#define XRGraphicKeyCurrentFont @"_currentFont"
#define XRGraphicKeyLabelAngle @"_labelAngle"
#define XRGraphicKeyLabel @"Label"
#define XRGraphicKeyLabelFont @"_labelFont"
#define XRGraphicKeyIsCore @"_isCore"
#define XRGraphicKeyCountSetting @"_countSetting"
#define XRGraphicKeyPercentSetting @"_percentSetting"
#define XRGraphicKeyGeometryPercent @"_geometryPercent"
#define XRGraphicKeyIsGeometryPercent @"_isGeometryPercent"
#define XRGraphicKeyIsPercent @"_isPercent"
#define XRGraphicKeyIsFixedCount @"_isFixedCount"
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

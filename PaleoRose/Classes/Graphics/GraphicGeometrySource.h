//
//  GraphicGeometrySource.h
//  PaleoRose
//
//  Created by Cascade on 7/16/25.
//  Copyright 2025 PaleoRose. All rights reserved.
//

#import <AppKit/AppKit.h>

#define XRGeometryDidChange @"XRGeometryDidChange"
#define XRGeometryDidChangeIsPercent @"XRGeometryDidChangeIsPercent"
#define XRGeometryDidChangeSectors @"XRGeometryDidChangeSectors"

@protocol GraphicGeometrySource <NSObject>

@property (readonly) NSRect drawingBounds;

//- (void)setMainRect:(NSRect)aRect;
- (BOOL)isPercent;
- (BOOL)isEqualArea;
- (float)startingAngle;
- (float)sectorSize;
- (int)geometryMaxCount;
- (float)geometryMaxPercent;
- (float)hollowCoreSize;
- (double)radiusOfCount:(int)count;
- (double)radiusOfPercentValue:(double)percent;
- (NSRect)circleRectForCount:(int)count;
- (NSRect)circleRectForPercent:(float)percent;
- (NSRect)circleRectForGeometryPercent:(float)percent;
- (NSPoint)rotationOfPoint:(NSPoint)thePoint byAngle:(double)angle;
- (double)degreesFromRadians:(double)radians;
- (double)radiusOfRelativePercent:(float)percent;
- (CGFloat)unrestrictedRadiusOfRelativePercent:(CGFloat)percent;

@end

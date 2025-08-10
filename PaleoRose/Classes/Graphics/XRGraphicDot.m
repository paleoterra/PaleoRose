//
//  XRGraphicDot.m
//  XRose
//
//  Created by Tom Moore on Mon Jan 26 2004.
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

#import "XRGraphicDot.h"
#import "XRGeometryController.h"

static NSString * const KVOKeyDotSize = @"dotSize";

@interface XRGraphicDot()
@property (assign, nonatomic) int angleIncrement;
@property (assign, nonatomic) int totalCount;
@property (assign, nonatomic) int count;

-(void)registerForKVO;

@end

@implementation XRGraphicDot

-(instancetype)initWithController:(id<GraphicGeometrySource>)controller forIncrement:(int)increment valueCount:(int)count totalCount:(int)total
{
    if (!(self = [super initWithController:controller])) return nil;
    if(self)
    {
        _angleIncrement = increment;
        _totalCount = total;
        _count = count;

        self.dotSize = 4.0;
        [self setDrawsFill:YES];
        [self calculateGeometry];
        [self registerForKVO];
    }
    return self;
}

-(void)registerForKVO {
    [self addObserver:self
           forKeyPath:KVOKeyDotSize
              options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld
              context:NULL];
}

#pragma mark - Geometry Calculation

/**
 * Calculates the center angle for the dots based on the sector configuration.
 */
- (CGFloat)centerAngleForSector {
    const CGFloat startAngle = [self.geometryController startingAngle];
    const CGFloat sectorSize = [self.geometryController sectorSize];
    return startAngle + (sectorSize * ((CGFloat)self.angleIncrement + 0.5));
}

/**
 * Calculates the radius for a dot at the given index.
 */
- (CGFloat)radiusForDotAtIndex:(NSInteger)index isPercentMode:(BOOL)isPercent {
    if (isPercent) {
        const CGFloat percentValue = (CGFloat)(index + 1) / (CGFloat)self.totalCount;
        return [self.geometryController radiusOfPercentValue:percentValue];
    } else {
        return [self.geometryController radiusOfCount:(int)index];
    }
}

/**
 * Creates a dot at the specified radius and angle.
 */
- (void)addDotAtRadius:(CGFloat)radius angle:(CGFloat)angle {
    // Create a point at the specified radius on the Y-axis
    NSPoint centerPoint = NSMakePoint(0.0, radius);
    
    // Rotate the point to the correct angle
    centerPoint = [self.geometryController rotationOfPoint:centerPoint byAngle:angle];
    
    // Create a rect for the dot centered at the calculated point
    const CGFloat halfDotSize = self.dotSize * 0.5;
    NSRect dotRect = {
        .origin = NSMakePoint(centerPoint.x - halfDotSize, centerPoint.y - halfDotSize),
        .size = NSMakeSize(self.dotSize, self.dotSize)
    };
    
    [self.drawingPath appendBezierPathWithOvalInRect:dotRect];
}

- (void)calculateGeometry {
    // Initialize the drawing path
    self.drawingPath = [[NSBezierPath alloc] init];
    
    // Get configuration
    const BOOL isPercentMode = [self.geometryController isPercent];
    const CGFloat centerAngle = [self centerAngleForSector];
    
    // Create dots for each value
    for (NSInteger i = 0; i < self.count; i++) {
        const CGFloat radius = [self radiusForDotAtIndex:i isPercentMode:isPercentMode];
        [self addDotAtRadius:radius angle:centerAngle];
    }
}

-(NSDictionary *)graphicSettings {
    NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType : GraphicTypeDot,
        XRGraphicKeyAngleIncrement : [self stringFromInt: _angleIncrement],
        XRGraphicKeyTotalCount : [self stringFromInt: _totalCount],
        XRGraphicKeyCount : [self stringFromInt: _count],
        XRGraphicKeyDotSize : [self stringFromFloat: self.dotSize]
    };
    [parentDict addEntriesFromDictionary:classDict];
    return parentDict;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    if ([keyPath isEqualToString: KVOKeyDotSize]) {
        [self calculateGeometry];
    }
}
@end

//
//  XRGraphicKite.m
//  XRose
//
//  Created by Tom Moore on Sun Jan 25 2004.
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

#import "XRGraphicKite.h"
#import "XRGeometryController.h"

@interface XRGraphicKite()

@property (nonatomic, strong, nonnull) NSArray *angles;
@property (nonatomic, strong, nonnull) NSArray *values;

@end

@implementation XRGraphicKite

-(instancetype)initWithController:(id<GraphicGeometrySource>)controller withAngles:(NSArray *)angles forValues:(NSArray *)values {
	if (!(self = [super initWithController:controller])) return nil;
	if(self) {
        self.angles = angles;
        self.values = values;
		self.drawsFill = YES;
		self.fillColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
		[self calculateGeometry];
	}
	return self;
}

#pragma mark - Geometry Calculation

- (void)calculateGeometry {
    NSParameterAssert(_angles.count == _values.count);
    
    self.drawingPath = [NSBezierPath bezierPath];
    [self drawKiteOutline];
    [self drawHollowCoreIfNeeded];
}

- (void)drawKiteOutline {
    // Start with the last point to close the shape
    double lastValue = [_values.lastObject doubleValue];
    double radius = [self radiusForValue:lastValue];
    double lastAngle = [_angles.lastObject doubleValue];
    
    NSPoint startPoint = [self pointWithRadius:radius atAngle:lastAngle];
    [self.drawingPath moveToPoint:startPoint];
    
    // Draw the rest of the kite
    for (NSUInteger i = 0; i < _angles.count; i++) {
        radius = [self radiusForValue:[_values[i] doubleValue]];
        NSPoint point = [self pointWithRadius:radius atAngle:[_angles[i] doubleValue]];
        [self.drawingPath lineToPoint:point];
    }
}

- (void)drawHollowCoreIfNeeded {
    if ([self.geometryController hollowCoreSize] <= 0.0) {
        return;
    }
    
    double radius = [self radiusForValue:0.0];
    NSPoint centroid = NSZeroPoint;
    NSRect coreRect = NSMakeRect(centroid.x - radius,
                                centroid.y - radius,
                                radius * 2.0,
                                radius * 2.0);
    [self.drawingPath appendBezierPathWithOvalInRect:coreRect];
}

- (NSPoint)pointWithRadius:(double)radius atAngle:(double)angle {
    NSPoint point = NSMakePoint(0.0, radius);
    return [self.geometryController rotationOfPoint:point byAngle:angle];
}

- (double)radiusForValue:(double)value {
    if ([self.geometryController isPercent]) {
        return [self.geometryController radiusOfPercentValue:value];
    } else {
        return [self.geometryController radiusOfCount:value];
    }
}

-(NSDictionary *)graphicSettings {
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    theDict[XRGraphicKeyGraphicType] = GraphicTypeKite;
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

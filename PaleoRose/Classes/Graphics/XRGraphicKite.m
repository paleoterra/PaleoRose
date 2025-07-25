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

-(void)calculateGeometry
{
	NSUInteger count = [_angles count];
	NSPoint aPoint,targetPoint;
	float radius;
	self.drawingPath = [NSBezierPath bezierPath];
	if([self.geometryController isPercent]) {
		radius = [self.geometryController radiusOfPercentValue:[[_values lastObject] doubleValue]];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [self.geometryController rotationOfPoint:aPoint byAngle:[[_angles lastObject] doubleValue]];
		[self.drawingPath moveToPoint:targetPoint];
		for(int i=0;i<count;i++) {
			radius = [self.geometryController radiusOfPercentValue:[[_values objectAtIndex:i] doubleValue]];
			aPoint.x = 0.0;
			aPoint.y = radius;
			targetPoint = [self.geometryController rotationOfPoint:aPoint byAngle:[[_angles objectAtIndex:i] doubleValue]];
			[self.drawingPath lineToPoint:targetPoint];
		}
	}
	else {
		radius = [self.geometryController radiusOfCount:[[_values lastObject] doubleValue]];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [self.geometryController rotationOfPoint:aPoint byAngle:[[_angles lastObject] doubleValue]];
		[self.drawingPath moveToPoint:targetPoint];

		for(int i=0;i<count;i++) {
			radius = [self.geometryController radiusOfCount:[[_values objectAtIndex:i] intValue]];
			aPoint.x = 0.0;
			aPoint.y = radius;
			targetPoint = [self.geometryController rotationOfPoint:aPoint byAngle:[[_angles objectAtIndex:i] doubleValue]];
			[self.drawingPath lineToPoint:targetPoint];
			
		}
	}
	if([self.geometryController hollowCoreSize]>0.0) {
		NSRect aRect;
		NSPoint centroid = NSMakePoint(0.0,0.0);
		if([self.geometryController isPercent])
			radius = [self.geometryController radiusOfPercentValue:0.0];
		else
			radius = [self.geometryController radiusOfCount:0];
		aRect = NSMakeRect(centroid.x - radius,centroid.y - radius,2* radius,2* radius);
		[self.drawingPath appendBezierPathWithOvalInRect:aRect];
		//[self.drawingPath moveToPoint:targetPoint];
	}
}

-(NSDictionary *)graphicSettings {
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    theDict[XRGraphicKeyGraphicType] = GraphicTypeKite;
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

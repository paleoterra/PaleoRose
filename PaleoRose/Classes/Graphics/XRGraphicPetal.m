//
//  XRGraphicPetal.m
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

#import "XRGraphicPetal.h"
#import "XRGeometryController.h"

@interface XRGraphicPetal()
@property (readwrite, assign) int petalIncrement;
@property (readwrite, assign) float maxRadius;
@property (readwrite, assign) float percent;
@property (readwrite, assign) int count;
@end

@implementation XRGraphicPetal

-(instancetype)initWithController:(id<GraphicGeometrySource>)controller forIncrement:(int)increment forValue:(NSNumber *)aNumber
{
	if (!(self = [super initWithController:controller])) return nil;
	if(self)
	{
		_petalIncrement = increment;
		_percent = [aNumber floatValue];
		_count = [aNumber intValue];
		[self setDrawsFill:YES];
		[self calculateGeometry];
	}
	return self;
}

-(void)calculateGeometry {
	float radius1, radius2;
	float angle1;
	float angle2;
	float angle3;
	float angle4;
    NSPoint pivotPoint = NSMakePoint(0, 0);
	float size = [self.geometryController sectorSize];
	float start = [self.geometryController startingAngle];
    bool isPercent = [self.geometryController isPercent];
	//step 1. find the angles
    angle1 = [self restrictAngleToACircle:(_petalIncrement * size) + start];
    angle2 = [self restrictAngleToACircle:angle1 + size];

    angle3 =  [self restrictAngleToACircle:360.0 - angle1 + 90.0];
    angle4 =  [self restrictAngleToACircle:360.0 - angle2 + 90.0];

	self.drawingPath = [NSBezierPath bezierPath];

    radius1 = isPercent ? [self.geometryController radiusOfPercentValue:0.0] : [self.geometryController radiusOfCount:0];
    radius2 = isPercent ?  [self.geometryController radiusOfPercentValue:_percent] : [self.geometryController radiusOfCount:_count];
    NSPoint startPoint = NSMakePoint(0.0, radius1);
    NSPoint outerPoint = NSMakePoint(0.0, radius2);

    [self.drawingPath moveToPoint:[self.geometryController rotationOfPoint:startPoint byAngle:angle1]];
    [self.drawingPath lineToPoint:[self.geometryController rotationOfPoint:outerPoint byAngle:angle1]];
    [self.drawingPath appendBezierPathWithArcWithCenter:pivotPoint radius:radius2 startAngle:angle3 endAngle:angle4 clockwise:YES];
    [self.drawingPath lineToPoint:[self.geometryController rotationOfPoint:startPoint byAngle:angle2]];
    [self.drawingPath appendBezierPathWithArcWithCenter:pivotPoint radius:radius1 startAngle:angle4 endAngle:angle3 clockwise:NO];
}

-(NSDictionary *)graphicSettings {
	NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];

    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType : GraphicTypePetal,
        XRGraphicKeyPetalIncrement : [self stringFromInt: _petalIncrement],
        XRGraphicKeyMaxRadius      : [self stringFromFloat: _maxRadius],
        XRGraphicKeyPercent        : [self stringFromFloat: _percent],
        XRGraphicKeyCount          : [self stringFromInt: _count]
    };
    [parentDict addEntriesFromDictionary:classDict];
	return parentDict;
}
@end

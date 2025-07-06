//
//  XRGraphicHistogram.m
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

#import "XRGraphicHistogram.h"
#import "XRGeometryController.h"

@implementation XRGraphicHistogram
-(id)initWithController:(XRGeometryController *)controller forIncrement:(int)increment forValue:(NSNumber *)aNumber
{
	if (!(self = [super initWithController:controller])) return nil;
	if(self)
	{
		_histIncrement = increment;
		_percent = [aNumber floatValue];
		_count = [aNumber intValue];
		_lineWidth = 4.0;
		[self setDrawsFill:YES];
		[self calculateGeometry];
	}
	return self;
}

-(void)calculateGeometry
{
	
	
	NSPoint aPoint,targetPoint;
	float radius;
	float angle1;
	float size = [geometryController sectorSize];
	float start = [geometryController startingAngle];
	//step 1. find the angles
	angle1 = (_histIncrement * size)+(0.5 * size) + start;

	if(angle1>360.0)
		angle1 = angle1 - 360.0;
	_drawingPath = [NSBezierPath bezierPath];
	if([geometryController isPercent])
	{
		radius = [geometryController radiusOfPercentValue:0.0];
		aPoint = NSMakePoint(0.0,radius);
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		[_drawingPath moveToPoint:targetPoint];
		
		radius = [geometryController radiusOfPercentValue:_percent];
		aPoint = NSMakePoint(0.0,radius);
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		[_drawingPath lineToPoint:targetPoint];
		
	}
	else
	{
		radius = [geometryController radiusOfCount:0];
		aPoint = NSMakePoint(0.0,radius);
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		[_drawingPath moveToPoint:targetPoint];
		
		radius = [geometryController radiusOfCount:_count];
		aPoint = NSMakePoint(0.0,radius);
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		[_drawingPath lineToPoint:targetPoint];
		
	}
	[_drawingPath setLineWidth:_lineWidth];
}


-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    [theDict setObject:@"Histogram" forKey:@"GraphicType"];

	[theDict setObject:[NSString stringWithFormat:@"%i",_histIncrement] forKey:@"_histIncrement"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_percent] forKey:@"_percent"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_count] forKey:@"_count"];

	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

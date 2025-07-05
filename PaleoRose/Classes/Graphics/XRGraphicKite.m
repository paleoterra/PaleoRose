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

@implementation XRGraphicKite

-(id)initWithController:(XRGeometryController *)controller withAngles:(NSArray *)angles forValues:(NSArray *)values
{
	if (!(self = [super initWithController:controller])) return nil;
	if(self)
	{
		_angles = angles;
		_values = values;
		_drawsFill = YES;
		_fillColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
		[self calculateGeometry];
	}
	return self;
}

-(void)calculateGeometry
{
	NSUInteger count = [_angles count];
	NSPoint aPoint,targetPoint;
	float radius;
	_drawingPath = [NSBezierPath bezierPath];
	if([geometryController isPercent])
	{
		radius = [geometryController radiusOfPercentValue:[[_values lastObject] doubleValue]];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:[[_angles lastObject] doubleValue]];
		[_drawingPath moveToPoint:targetPoint];
		for(int i=0;i<count;i++)
		{
			//NSLog(@"value: %f angle %f", [[_values objectAtIndex:i] floatValue],[[_angles objectAtIndex:i] floatValue]);
			radius = [geometryController radiusOfPercentValue:[[_values objectAtIndex:i] doubleValue]];
			aPoint.x = 0.0;
			aPoint.y = radius;
			targetPoint = [geometryController rotationOfPoint:aPoint byAngle:[[_angles objectAtIndex:i] doubleValue]];
			[_drawingPath lineToPoint:targetPoint];
		}
		
	}
	else
	{
		radius = [geometryController radiusOfCount:[[_values lastObject] doubleValue]];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:[[_angles lastObject] doubleValue]];
		[_drawingPath moveToPoint:targetPoint];

		for(int i=0;i<count;i++)
		{
			radius = [geometryController radiusOfCount:[[_values objectAtIndex:i] intValue]];
			aPoint.x = 0.0;
			aPoint.y = radius;
			targetPoint = [geometryController rotationOfPoint:aPoint byAngle:[[_angles objectAtIndex:i] doubleValue]];
			[_drawingPath lineToPoint:targetPoint];
			
		}
	}
	if([geometryController hollowCoreSize]>0.0)
	{
		NSRect aRect;
		NSPoint centroid = NSMakePoint(0.0,0.0);
		if([geometryController isPercent])
			radius = [geometryController radiusOfPercentValue:0.0];
		else
			radius = [geometryController radiusOfCount:0];
		aRect = NSMakeRect(centroid.x - radius,centroid.y - radius,2* radius,2* radius);
		[_drawingPath appendBezierPathWithOvalInRect:aRect];
		//[_drawingPath moveToPoint:targetPoint];
	}
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
	
	
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

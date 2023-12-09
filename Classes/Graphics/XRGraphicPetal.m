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

@implementation XRGraphicPetal

-(id)initWithController:(XRGeometryController *)controller forIncrement:(int)increment forValue:(NSNumber *)aNumber
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



-(void)calculateGeometry
{

	
	NSPoint aPoint,targetPoint;
	float radius;
	float angle1;
	float angle2;
	float angle3;
	float angle4;
	float size = [geometryController sectorSize];
	float start = [geometryController startingAngle];
	//step 1. find the angles
	angle1 = (_petalIncrement * size) + start;
	angle2 = angle1 + size;
	if(angle1>360.0)
		angle1 = angle1 - 360.0;
	if(angle2>360.0)
		angle2 = angle2 - 360.0;
	angle3 =  360.0 - angle1 + 90.0;
	angle4 =  360.0 - angle2 + 90.0;
	if(angle3>360)
		angle3 = angle3 - 360.0;
	if(angle4>360)
		angle4 = angle4- 360.0;
	_drawingPath = [NSBezierPath bezierPath];

	if([geometryController isPercent])
	{
		
		//core point 1.
		radius = [geometryController radiusOfPercentValue:0.0];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];

		[_drawingPath moveToPoint:targetPoint];

		
		//move out to point 2.
		radius = [geometryController radiusOfPercentValue:_percent];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		[_drawingPath lineToPoint:targetPoint];

		//arc to point 3.
		aPoint.x = 0.0;
		aPoint.y = 0.0;
		[_drawingPath appendBezierPathWithArcWithCenter:aPoint radius:radius startAngle:angle3 endAngle:angle4 clockwise:YES];

		//line to point 4.
		radius = [geometryController radiusOfPercentValue:0.0];
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle2];
		[_drawingPath lineToPoint:targetPoint];

		//arc to point 1
		aPoint.x = 0.0;
		aPoint.y = 0.0;
		[_drawingPath appendBezierPathWithArcWithCenter:aPoint radius:radius startAngle:angle4 endAngle:angle3 clockwise:NO];

		
	}
	else
	{
		//core point 1.
		radius = [geometryController radiusOfCount:0];
		//NSLog(@"radius 1: %f",radius);
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		
		[_drawingPath moveToPoint:targetPoint];
		
		
		//move out to point 2.
		radius = [geometryController radiusOfCount:_count];
		//NSLog(@"radius 2: %f %i",radius,_count);
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle1];
		[_drawingPath lineToPoint:targetPoint];
		
		//arc to point 3.
		aPoint.x = 0.0;
		aPoint.y = 0.0;
		[_drawingPath appendBezierPathWithArcWithCenter:aPoint radius:radius startAngle:angle3 endAngle:angle4 clockwise:YES];
		
		//line to point 4.
		radius = [geometryController radiusOfCount:0];
		//NSLog(@"radius 4: %f",radius);
		aPoint.x = 0.0;
		aPoint.y = radius;
		targetPoint = [geometryController rotationOfPoint:aPoint byAngle:angle2];
		[_drawingPath lineToPoint:targetPoint];
		
		//arc to point 1
		aPoint.x = 0.0;
		aPoint.y = 0.0;
		[_drawingPath appendBezierPathWithArcWithCenter:aPoint radius:radius startAngle:angle4 endAngle:angle3 clockwise:YES];
	}
		
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
	
	
	[theDict setObject:[NSString stringWithFormat:@"%i",_petalIncrement] forKey:@"_petalIncrement"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_maxRadius] forKey:@"_maxRadius"];
	
	[theDict setObject:[NSString stringWithFormat:@"%f",_percent] forKey:@"_percent"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_count] forKey:@"_count"];
		
	return [NSDictionary dictionaryWithDictionary:theDict];
}
@end

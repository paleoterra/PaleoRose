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

@implementation XRGraphicDot

-(id)initWithController:(XRGeometryController *)controller forIncrement:(int)increment valueCount:(int)count totalCount:(int)total
{
	if (!(self = [super initWithController:controller])) return nil;
	if(self)
	{
		_angleIncrement = increment;
		_totalCount = total;
		_count = count;
		
		_dotSize = 4.0;
		[self setDrawsFill:YES];
		[self calculateGeometry];
	}
	return self;
}

-(void)calculateGeometry
{
	float radius;
	float startAngle = [geometryController startingAngle];
	float step = [geometryController sectorSize];
	float angle = startAngle + (step * ((float)_angleIncrement +0.5));
	NSRect aRect;
	NSPoint aPoint;
	_drawingPath = [[NSBezierPath alloc] init];
	aRect.size = NSMakeSize(_dotSize,_dotSize);
	if([geometryController isPercent])
	{
		for(int i=0;i<_count;i++)
		{
			radius = [geometryController radiusOfPercentValue:(float)(i+1)/(float)_totalCount];
			aPoint = NSMakePoint(0.0,radius);
			aPoint = [geometryController rotationOfPoint:aPoint byAngle:angle];
			aRect.origin.x = aPoint.x - (_dotSize * 0.5);
			aRect.origin.y = aPoint.y - (_dotSize * 0.5);
			[_drawingPath appendBezierPathWithOvalInRect:aRect];
		}
	}
	else
	{
		for(int i=0;i<_count;i++)
		{
			radius = [geometryController radiusOfCount:i];
			aPoint = NSMakePoint(0.0,radius);
			aPoint = [geometryController rotationOfPoint:aPoint byAngle:angle];
			aRect.origin.x = aPoint.x - (_dotSize * 0.5);
			aRect.origin.y = aPoint.y - (_dotSize * 0.5);
			[_drawingPath appendBezierPathWithOvalInRect:aRect];
		}
	}
}

-(void)setDotSize:(float)newSize
{
	_dotSize = newSize;
	[self calculateGeometry];
}

-(float)dotSize
{
	return _dotSize;
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
	
	
	[theDict setObject:[NSString stringWithFormat:@"%i",_angleIncrement] forKey:@"_angleIncrement"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_totalCount] forKey:@"_totalCount"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_count] forKey:@"_count"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_dotSize] forKey:@"_dotSize"];

	
	return [NSDictionary dictionaryWithDictionary:theDict];
}
@end

//
//  LITMArrowHead.m
//  LITMAppKit
//
//  Created by Tom Moore on Sat Mar 13 2004.
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


#import "LITMArrowHead.h"
#import "math.h"

@implementation LITMArrowHead

-(id)initWithSize:(float)size color:(NSColor *)color type:(int)type
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		[self setColor:color]; 
		[self setSize:size];
		[self setType:type];
		[self positionAtLineEndpoint:NSMakePoint(0.0,0.0) withAngle:0.0];
	}
	return self;
}


-(void)setColor:(NSColor *)color
{
	_arrowColor = color;
}

-(void)setSize:(float)size
{
	float scale;
	
	//scale = sqrt(size);
	scale = size;
	_scaleTransform = [NSAffineTransform transform];
	[_scaleTransform scaleXBy:scale yBy:scale];
	//assumes that the origin is unchanged in position.
	//[_scaleTransform translateXBy:-0.5*scale yBy:-0.5*scale];
}

-(void)setType:(int)type
{
	_type = type;
	//should command to reassemble path
	_path = [NSBezierPath bezierPath];
	switch(_type)
	{
		case 0://standard arrow
		{
			[_path moveToPoint:NSMakePoint(0.0,0.0)];
			
			[_path lineToPoint:NSMakePoint(5.0,-10.0)];
			[_path lineToPoint:NSMakePoint(-5.0,-10.0)];
			[_path lineToPoint:NSMakePoint(0.0,0.0)];
		}
			break;
		case 1://flying arrow
		{
			[_path moveToPoint:NSMakePoint(0.0,0.0)];
			[_path lineToPoint:NSMakePoint(5.0,-10.0)];
			[_path lineToPoint:NSMakePoint(0.0,-7.5)];
			
			[_path lineToPoint:NSMakePoint(-5.0,-10.0)];
			[_path lineToPoint:NSMakePoint(0.0,0.0)];
		}
			break;
		case 2: //half arrow left
		{
			[_path moveToPoint:NSMakePoint(0.0,0.0)];
			
			[_path lineToPoint:NSMakePoint(0.0,-7.5)];
			[_path lineToPoint:NSMakePoint(-5.0,-10.0)];
			[_path lineToPoint:NSMakePoint(0.0,0.0)];
		}
			break;
		case 4: //half arrow right
		{
			[_path moveToPoint:NSMakePoint(0.0,0.0)];
			
			
			[_path lineToPoint:NSMakePoint(5.0,-10.0)];
			[_path lineToPoint:NSMakePoint(0.0,-7.5)];
			[_path lineToPoint:NSMakePoint(0.0,0.0)];
		}
			break;
		
	}
}
-(void)positionAtLineEndpoint:(NSPoint)aPoint withAngle:(float)angle
{

	_positionTransform = [NSAffineTransform transform];

	[_positionTransform translateXBy:aPoint.x yBy:aPoint.y];

	[_positionTransform rotateByDegrees:360.0-angle];


}

-(void)drawRect:(NSRect)rect
{

	NSAffineTransform *aTrans = [NSAffineTransform transform];
	
	[aTrans appendTransform:_scaleTransform];

	[aTrans appendTransform:_positionTransform];

	[NSGraphicsContext saveGraphicsState];

	[aTrans concat];

	[_arrowColor set];
	
	[_path stroke];

	[_path fill];

	[NSGraphicsContext restoreGraphicsState];

}

@end

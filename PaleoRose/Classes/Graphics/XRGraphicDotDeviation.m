//
//  XRGraphicDotDeviation.m
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

#import "XRGraphicDotDeviation.h"
#import "XRGeometryController.h"

@implementation XRGraphicDotDeviation
-(id)initWithController:(id<GraphicGeometrySource>)controller forIncrement:(int)increment valueCount:(int)count totalCount:(int)total statistics:(NSDictionary *)stats
{
#ifdef GraphicsDebug
	NSLog(@"XRGraphicDotDeviation:initWithController");
#endif
	if (!(self = [super initWithController:controller])) return nil;
	if(self)
	{
		_angleIncrement = increment;
		_totalCount = total;
		_count = count;
		_mean = [[stats objectForKey:@"mean"] floatValue];
		
		_dotSize = 4.0;
		[self setDrawsFill:YES];
		[self calculateGeometry];
	}
	return self;
}

-(void)calculateGeometry
{
#ifdef GraphicsDebug
	NSLog(@"XRGraphicDotDeviation:calculateGeometry");
#endif

	float radius;
	int excess;
	int shortfall;
	float startAngle = [self.geometryController startingAngle];
	float step = [self.geometryController sectorSize];
	float angle = startAngle + (step * ((float)_angleIncrement +0.5));
	
	NSRect aRect;
	NSPoint aPoint;

	self.drawingPath = [[NSBezierPath alloc] init];
	aRect.size = NSMakeSize(_dotSize,_dotSize);
	
	if([self.geometryController isPercent])
	{

		if(_count>_mean)
		{

			excess = (int)(ceil((float)_count -_mean));
			
			for(int i=0;i<excess;i++)
			{

				radius = [self.geometryController radiusOfPercentValue:(float)(i+1+(int)floor(_mean))/(float)_totalCount];
				aPoint = NSMakePoint(0.0,radius);
				aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];

				aRect.origin.x = aPoint.x - (_dotSize * 0.5);
				aRect.origin.y = aPoint.y - (_dotSize * 0.5);

				[self.drawingPath appendBezierPathWithOvalInRect:aRect];

			}
		}
		else
		{
			shortfall = (int)(ceil(_mean -(float)_count));

			if(shortfall >0)
			{
			for(int i=0;i<shortfall;i++)
			{
				
				radius = [self.geometryController radiusOfPercentValue:(float)((int)ceil(_mean) - (i + 1))/(float)_totalCount];
				aPoint = NSMakePoint(0.0,radius);
				aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
				aRect.origin.x = aPoint.x - (_dotSize * 0.5);
				aRect.origin.y = aPoint.y - (_dotSize * 0.5);
				[self.drawingPath appendBezierPathWithOvalInRect:aRect];
			}
			}
			else
			{
				radius = [self.geometryController radiusOfPercentValue:(float)((int)ceil(_mean))/(float)_totalCount];
				aPoint = NSMakePoint(0.0,radius);
				aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
				aRect.origin.x = aPoint.x - (_dotSize * 0.5);
				aRect.origin.y = aPoint.y - (_dotSize * 0.5);
				[self.drawingPath appendBezierPathWithOvalInRect:aRect];
			}
		}
			
	}
	else
	{
		if(_count>_mean)
		{
			excess = (int)(ceil((float)_count -_mean));
			for(int i=0;i<excess;i++)
			{
				radius = [self.geometryController radiusOfCount:(float)(i+1+(int)floor(_mean))];
				aPoint = NSMakePoint(0.0,radius);
				aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
				aRect.origin.x = aPoint.x - (_dotSize * 0.5);
				aRect.origin.y = aPoint.y - (_dotSize * 0.5);
				[self.drawingPath appendBezierPathWithOvalInRect:aRect];
			}
		}
		else
		{
			shortfall = (int)(ceil(_mean -(float)_count));
			if(shortfall >0)
			{
				for(int i=0;i<shortfall;i++)
				{
					radius = [self.geometryController radiusOfCount:((int)ceil(_mean) - (i + 1))];
					aPoint = NSMakePoint(0.0,radius);
					aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
					aRect.origin.x = aPoint.x - (_dotSize * 0.5);
					aRect.origin.y = aPoint.y - (_dotSize * 0.5);
					//[self.drawingPath appendBezierPathWithOvalInRect:aRect];
				}
			
			}
			else
			{
				radius = [self.geometryController radiusOfPercentValue:(float)((int)ceil(_mean))/(float)_totalCount];
				aPoint = NSMakePoint(0.0,radius);
				aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
				aRect.origin.x = aPoint.x - (_dotSize * 0.5);
				aRect.origin.y = aPoint.y - (_dotSize * 0.5);
				[self.drawingPath appendBezierPathWithOvalInRect:aRect];
			}
		}
	}
}

-(void)setDotSize:(float)newSize
{
#ifdef GraphicsDebug
	NSLog(@"XRGraphicDotDeviation:setDotSize");
#endif
	_dotSize = newSize;
	[self calculateGeometry];
}

-(float)dotSize
{
#ifdef GraphicsDebug
	NSLog(@"XRGraphicDotDeviation:dotSize");
#endif
	return _dotSize;
}

-(NSDictionary *)graphicSettings
{
#ifdef GraphicsDebug
	NSLog(@"XRGraphicDotDeviation:graphicSettings");
#endif
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    [theDict setObject: GraphicTypeDotDeviation forKey:@"GraphicType"];

	[theDict setObject:[NSString stringWithFormat:@"%i",_angleIncrement] forKey:@"_angleIncrement"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_totalCount] forKey:@"_totalCount"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_count] forKey:@"_count"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_dotSize] forKey:@"_dotSize"];
	
	[theDict setObject:[NSString stringWithFormat:@"%f",_mean] forKey:@"_mean"];

	
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

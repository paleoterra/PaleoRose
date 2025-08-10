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

static NSString * const KVOKeyDotSize = @"dotSize";

@interface XRGraphicDotDeviation()
@property (assign, nonatomic) int angleIncrement;
@property (assign, nonatomic) int totalCount;
@property (assign, nonatomic) int count;
@property (assign, nonatomic) float mean;
@end

@implementation XRGraphicDotDeviation
-(instancetype)initWithController:(id<GraphicGeometrySource>)controller forIncrement:(int)increment valueCount:(int)count totalCount:(int)total statistics:(NSDictionary *)stats
{
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    if ([keyPath isEqualToString: KVOKeyDotSize]) {
        [self calculateGeometry];
    }
}

-(void)addToDrawingPath:(NSBezierPath *)path dotSize:(float)dotSize  radius:(float)radius angle:(float)angle geometryController:(XRGeometryController *)controller {
    NSPoint aPoint = NSMakePoint(0.0,radius);
    aPoint = [controller rotationOfPoint:aPoint byAngle:angle];
    NSRect aRect = NSMakeRect(
                              aPoint.x - (dotSize * 0.5),
                              aPoint.y - (dotSize * 0.5),
                              dotSize,
                              dotSize
                              );


    [path appendBezierPathWithOvalInRect:aRect];
}

-(void)calculateGeometry
{
	float radius;
	float startAngle = [self.geometryController startingAngle];
	float step = [self.geometryController sectorSize];
	float angle = startAngle + (step * ((float)_angleIncrement +0.5));
	
	NSRect aRect;

	self.drawingPath = [[NSBezierPath alloc] init];
	aRect.size = NSMakeSize(_dotSize,_dotSize);
    int excess = (int)(ceil((float)_count -_mean));
    int shortfall = (int)(ceil(_mean -(float)_count));

	if([self.geometryController isPercent])
	{

		if(_count>_mean)
		{
			for(int i=0;i<excess;i++)
			{

				radius = [self.geometryController radiusOfPercentValue:(float)(i+1+(int)floor(_mean))/(float)_totalCount];
                [self addToDrawingPath:self.drawingPath
                               dotSize:_dotSize
                                radius:radius
                                 angle:angle
                    geometryController:self.geometryController];

			}
		}
		else
		{
			if(shortfall >0)
			{
			for(int i=0;i<shortfall;i++)
			{
				
				radius = [self.geometryController radiusOfPercentValue:(float)((int)ceil(_mean) - (i + 1))/(float)_totalCount];
                [self addToDrawingPath:self.drawingPath
                               dotSize:_dotSize
                                radius:radius
                                 angle:angle
                    geometryController:self.geometryController];
			}
			}
			else
			{
				radius = [self.geometryController radiusOfPercentValue:(float)((int)ceil(_mean))/(float)_totalCount];
                [self addToDrawingPath:self.drawingPath
                               dotSize:_dotSize
                                radius:radius
                                 angle:angle
                    geometryController:self.geometryController];
			}
		}
			
	}
	else
	{
		if(_count>_mean)
		{
			for(int i=0;i<excess;i++)
			{
				radius = [self.geometryController radiusOfCount:(float)(i+1+(int)floor(_mean))];
                [self addToDrawingPath:self.drawingPath
                               dotSize:_dotSize
                                radius:radius
                                 angle:angle
                    geometryController:self.geometryController];
			}
		}
		else
		{
			if(shortfall >0)
			{
				for(int i=0;i<shortfall;i++)
				{
					radius = [self.geometryController radiusOfCount:((int)ceil(_mean) - (i + 1))];
                    [self addToDrawingPath:self.drawingPath
                                   dotSize:_dotSize
                                    radius:radius
                                     angle:angle
                        geometryController:self.geometryController];
				}
			
			}
			else
			{
				radius = [self.geometryController radiusOfPercentValue:(float)((int)ceil(_mean))/(float)_totalCount];
                [self addToDrawingPath:self.drawingPath
                               dotSize:_dotSize
                                radius:radius
                                 angle:angle
                    geometryController:self.geometryController];
			}
		}
	}
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType: GraphicTypeDotDeviation,
        XRGraphicKeyAngleIncrement: [self stringFromInt:_angleIncrement],
        XRGraphicKeyTotalCount: [self stringFromInt:_totalCount],
        XRGraphicKeyCount: [self stringFromInt:_count],
        XRGraphicKeyDotSize: [self stringFromFloat:_dotSize],
        XRGraphicKeyMean: [self stringFromFloat:_mean]
    };
    [parentDict addEntriesFromDictionary:classDict];
	return parentDict;
}

@end

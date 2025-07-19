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

static NSString * const KVOKeyDotSize = @"labelFont";

@interface XRGraphicDot()
@property (assign, nonatomic) int angleIncrement;
@property (assign, nonatomic) int totalCount;
@property (assign, nonatomic) int count;

-(void)registerForKVO;

@end

@implementation XRGraphicDot

-(id)initWithController:(id<GraphicGeometrySource>)controller forIncrement:(int)increment valueCount:(int)count totalCount:(int)total
{
    if (!(self = [super initWithController:controller])) return nil;
    if(self)
    {
        _angleIncrement = increment;
        _totalCount = total;
        _count = count;

        self.dotSize = 4.0;
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

-(void)calculateGeometry
{
    float radius;
    float startAngle = [self.geometryController startingAngle];
    float step = [self.geometryController sectorSize];
    float angle = startAngle + (step * ((float)_angleIncrement +0.5));
    NSRect aRect;
    NSPoint aPoint;
    self.drawingPath = [[NSBezierPath alloc] init];
    aRect.size = NSMakeSize(self.dotSize,self.dotSize);
    if([self.geometryController isPercent])
    {
        for(int i=0;i<_count;i++)
        {
            radius = [self.geometryController radiusOfPercentValue:(float)(i+1)/(float)_totalCount];
            aPoint = NSMakePoint(0.0,radius);
            aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
            aRect.origin.x = aPoint.x - (self.dotSize * 0.5);
            aRect.origin.y = aPoint.y - (self.dotSize * 0.5);
            [self.drawingPath appendBezierPathWithOvalInRect:aRect];
        }
    }
    else
    {
        for(int i=0;i<_count;i++)
        {
            radius = [self.geometryController radiusOfCount:i];
            aPoint = NSMakePoint(0.0,radius);
            aPoint = [self.geometryController rotationOfPoint:aPoint byAngle:angle];
            aRect.origin.x = aPoint.x - (self.dotSize * 0.5);
            aRect.origin.y = aPoint.y - (self.dotSize * 0.5);
            [self.drawingPath appendBezierPathWithOvalInRect:aRect];
        }
    }
}

-(NSDictionary *)graphicSettings {
    NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType : GraphicTypeDot,
        XRGraphicKeyAngleIncrement : [self stringFromInt: _angleIncrement],
        XRGraphicKeyTotalCount : [self stringFromInt: _totalCount],
        XRGraphicKeyCount : [self stringFromInt: _count],
        XRGraphicKeyDotSize : [self stringFromFloat: self.dotSize]
    };
    [parentDict addEntriesFromDictionary:classDict];
    return parentDict;
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
@end

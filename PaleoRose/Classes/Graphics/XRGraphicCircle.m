//
//  XRGraphicCircle.m
//  XRose
//
//  Created by Tom Moore on Sat Jan 24 2004.
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

#import "XRGraphicCircle.h"
#import "XRGeometryController.h"

@implementation XRGraphicCircle

-(instancetype)initWithController:(XRGeometryController *)controller {
    if(self = [super initWithController:controller]) {
        _isPercent = [controller isPercent];
        [self registerForKVO];
        if([self isMemberOfClass:[XRGraphicCircle class]]) // this prevents calculating geometry twice for circle labels
            [self calculateGeometry];
    }
    return self;
}

-(id)initCoreCircleWithController:(XRGeometryController *)aController {
	if(self = [super initWithController:aController])
	{
        self.countSetting = 0;
		_percentSetting = 0.0;
        [self registerForKVO];
		_isPercent = [aController isPercent];
		if([self isMemberOfClass:[XRGraphicCircle class]])
			[self calculateGeometry];
	}
	return self;
}

-(void)registerForKVO {
    int i = 0;
    NSArray *keys = @[@"countSetting", @"percentSetting"];
    for(i=0;i<keys.count;i++) {
        [self addObserver:self
               forKeyPath:keys[i]
                  options:NSKeyValueObservingOptionNew |
         NSKeyValueObservingOptionOld
                  context:NULL];
    }
}

-(void)setGeometryPercent:(float)percent {
	self.isGeometryPercent = YES;
	self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForGeometryPercent:percent]];
}

-(void)calculateGeometry {
	
	if([self.geometryController isPercent])
	{
		self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForPercent:_percentSetting]];
	}
	else
	{
		self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForCount:_countSetting]];
	}
}

-(NSDictionary *)graphicSettings {
    NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType : @"Circle",
        XRGraphicKeyCountSetting : [self stringFromInt:self.countSetting],
        XRGraphicKeyPercentSetting : [self stringFromFloat:_percentSetting],
        XRGraphicKeyGeometryPercent : [self stringFromFloat:_percentSetting],
        XRGraphicKeyIsGeometryPercent : [self stringFromBool:self.isGeometryPercent],
        XRGraphicKeyIsPercent : [self stringFromBool:_isPercent],
        XRGraphicKeyIsFixedCount : [self stringFromBool:_isFixedCount]
    };
    [parentDict addEntriesFromDictionary: classDict];
	return parentDict;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    if ([keyPath isEqualToString:@"countSetting"]) {
        _isPercent = NO;
        self.isGeometryPercent = NO;
        [self calculateGeometry];
    } else if ([keyPath isEqualToString:@"percentSetting"]) {
        _isPercent = YES;
        self.isGeometryPercent = NO;
        [self calculateGeometry];
    }
}
@end

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

-(id)initCoreCircleWithController:(XRGeometryController *)aController
{
	if (!(self = [super initWithController:aController])) return nil;
	if(self)
	{
		_countSetting = 0;
		_percentSetting = 0.0;
		_isPercent = [aController isPercent];
		if([self isMemberOfClass:[XRGraphicCircle class]])
			[self calculateGeometry];
	}
	return self;
}

-(void)setCountSetting:(int)count
{
	if(_countSetting != count)
	{
		_countSetting = count;
		_isPercent = NO;
		_isGeometryPercent = NO;
		[self calculateGeometry];
	}
}

-(int)countSetting
{
	return _countSetting;
}

-(void)setPercentSetting:(float)percent
{
	if(_percentSetting != percent)
	{
		_percentSetting = percent;
		_isPercent = YES;
		_isGeometryPercent = NO;
		[self calculateGeometry];
	}
}

-(void)setGeometryPercent:(float)percent
{
	_isGeometryPercent = YES;
	self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[geometryController circleRectForGeometryPercent:percent]];
}

-(float)percent
{
	return _percentSetting;
}

-(void)calculateGeometry
{
	
	if([geometryController isPercent])
	{
		self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[geometryController circleRectForPercent:_percentSetting]];
	}
	else
	{
		self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[geometryController circleRectForCount:_countSetting]];
	}
}

-(void)setIsFixed:(BOOL)isFixed
{
	_isFixedCount = isFixed;
}

-(BOOL)isFixed
{
	return _isFixedCount;
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    [theDict setObject:@"Circle" forKey:@"GraphicType"];

	[theDict setObject:[NSString stringWithFormat:@"%i",_countSetting] forKey:@"_countSetting"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_percentSetting] forKey:@"_percentSetting"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_percentSetting] forKey:@"_geometryPercent"];
	if(_isGeometryPercent)
		[theDict setObject:@"YES" forKey:@"_isGeometryPercent"];
	else
		[theDict setObject:@"NO" forKey:@"_isGeometryPercent"];
	if(_isPercent)
		[theDict setObject:@"YES" forKey:@"_isPercent"];
	else
		[theDict setObject:@"NO" forKey:@"_isPercent"];
	
	if(_isFixedCount)
		[theDict setObject:@"YES" forKey:@"_isFixedCount"];
	else
		[theDict setObject:@"NO" forKey:@"_isFixedCount"];
	
	
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

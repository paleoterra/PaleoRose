//
//  XRGraphicCircleLabel.m
//  XRose
//
//  Created by Tom Moore on Fri Feb 13 2004.
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

#import "XRGraphicCircleLabel.h"
#import "XRGeometryController.h"
#import "math.h"
@implementation XRGraphicCircleLabel


-(id)initCoreCircleWithController:(XRGeometryController *)aController
{
	if (!(self = [super initCoreCircleWithController:aController])) return nil;
	
	if(self)
	{
		_showLabel = NO;
		_labelPoint = NSMakePoint(0.0,0.0);
		_isPercent = [aController isPercent];
		_isCore = YES;
		_percentSetting = 0.0;
		_countSetting = 0;
		[self calculateGeometry];
	}
	return self;
}

-(id)initWithController:(XRGeometryController *)controller
{

	if (!(self = [super initWithController:controller])) return nil;
	if(self)
	{
		_showLabel = YES;
		_isCore = NO;
		_labelFont = [NSFont fontWithName:@"Arial-Black" size:12];
		_labelPoint = NSMakePoint(0.0,0.0);
	}

	return self;
}

-(void)setFont:(NSFont *)newFont
{
	_labelFont = newFont;
	[self calculateGeometry];
}

-(NSFont *)font
{
	return _labelFont;
}

-(void)setShowLabel:(BOOL)showLabel
{
	_showLabel = showLabel;
}

-(BOOL)showLabel
{
	return _showLabel;
}

-(void)setLabelAngle:(float)newAngle
{
	_labelAngle = newAngle;

	[self calculateGeometry];

}

-(float)labelAngle
{
	return _labelAngle;
}

-(void)computeLabelText
{

	NSRange aRange;
	aRange.location = 0;
	_isPercent = [geometryController isPercent];
	
	if(_isPercent)
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f %c",(_percentSetting * 100.0),'%']];
	else if(_isFixedCount)
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",(_percentSetting * (float)[geometryController geometryMaxCount])]];
	else
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",_countSetting]];
	
	aRange.length = [_label length];
	
	if(_labelFont)
		[_label setAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_labelFont,_strokeColor,nil]
														  forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]] range:aRange];
	
	//NSLog([_label description]);
}

-(void)computeTransform
{
	
	theTransform = [NSAffineTransform transform];
	//NSLog(@"Rotation angle: %f",_labelAngle);
	[theTransform rotateByDegrees:360.0-_labelAngle];

	
}

-(void)calculateGeometry
{
	//NSLog(@"calc geom 1");
	[self computeLabelText];
	//NSLog(@"calc geom 2");
	[self computeTransform];
	//NSLog(@"calc geom 3");
	if((!_showLabel)||(_isCore))
	{
		if((([geometryController isPercent])||(_isFixedCount))||((![geometryController isPercent])&&(_isFixedCount)))
		{
			_drawingPath = [NSBezierPath bezierPathWithOvalInRect:[geometryController circleRectForPercent:_percentSetting]];
		}
		else
		{
			_drawingPath = [NSBezierPath bezierPathWithOvalInRect:[geometryController circleRectForCount:_countSetting]];
		}
	}
	else
	{
		float radius,angle;

		if((([geometryController isPercent])||(_isFixedCount))||((![geometryController isPercent])&&(_isFixedCount)))
			radius = [geometryController radiusOfPercentValue:_percentSetting];
		else
			radius = [geometryController radiusOfCount:_countSetting];
		angle = [geometryController degreesFromRadians:atan((0.52*[_label size].width)/radius)];
		_drawingPath = [NSBezierPath bezierPath];
		[_drawingPath appendBezierPathWithArcWithCenter:NSMakePoint(0.0,0.0) radius:radius startAngle:90+angle endAngle:90-angle];
		_labelPoint = NSMakePoint(0 - (0.5*[_label size].width),radius - (0.5*[_label size].height));


				
	}
	[_drawingPath setLineWidth:_lineWidth];
}

-(void)drawRect:(NSRect)aRect
{
    [self computeLabelText];
    if(NSIntersectsRect(aRect,[_drawingPath bounds]))
    {  
        [NSGraphicsContext saveGraphicsState];

        [_strokeColor set];
		
		[theTransform concat];
		[_drawingPath stroke];
        if(_drawsFill)
        {	
            [_fillColor set];
            [_drawingPath fill];
        }
        if((_showLabel)&&(!_isCore))
		{
			//(@"at draw");
			//NSLog([_label description]);
			
			[_label drawAtPoint:_labelPoint];
			
		}

		
        [NSGraphicsContext restoreGraphicsState];
        [self setNeedsDisplay:NO];
    }
}

-(void)setGeometryPercent:(float)percent
{
	
	_percentSetting = percent*[geometryController geometryMaxPercent];
	//NSLog(@"percentSetting %f",_percentSetting);
	[self calculateGeometry];
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
	//NSLog(@"graphic  circle label");
	if(_showLabel)
		[theDict setObject:@"YES" forKey:@"_showLabel"];
	else
		[theDict setObject:@"NO" forKey:@"_showLabel"];
	
	[theDict setObject:[NSString stringWithFormat:@"%f",_labelAngle] forKey:@"_labelAngle"];
	[theDict setObject:_label forKey:@"Label"];
	[theDict setObject:_labelFont forKey:@"_labelFont"];
	
	if(_isCore)
		[theDict setObject:@"YES" forKey:@"_isCore"];
	else
		[theDict setObject:@"NO" forKey:@"_isCore"];

	//NSLog(@"end graphic  circle label");
	
	
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

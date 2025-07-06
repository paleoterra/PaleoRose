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
    _isPercent = [self.geometryController isPercent];

	if(_isPercent)
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f %c",(_percentSetting * 100.0),'%']];
	else if(self.isFixedCount)
        _label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",(_percentSetting * (float)[self.geometryController geometryMaxCount])]];
	else
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",_countSetting]];
	
	aRange.length = [_label length];
	
	if(_labelFont)
		[_label setAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_labelFont,self.strokeColor,nil]
														  forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]] range:aRange];
	
	//NSLog([_label description]);
}

-(void)computeTransform
{
	theTransform = [NSAffineTransform transform];
	[theTransform rotateByDegrees:360.0-_labelAngle];
}

-(void)calculateGeometry
{
	[self computeLabelText];
	[self computeTransform];
	if((!_showLabel)||(_isCore))
	{
        if((([self.geometryController isPercent])||(self.isFixedCount))||((![self.geometryController isPercent])&&(self.isFixedCount)))
		{
            self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForPercent:_percentSetting]];
		}
		else
		{
            self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForCount:_countSetting]];
		}
	}
	else
	{
		float radius,angle;

        if((([self.geometryController isPercent])||(self.isFixedCount))||((![self.geometryController isPercent])&&(self.isFixedCount)))
            radius = [self.geometryController radiusOfPercentValue:_percentSetting];
		else
            radius = [self.geometryController radiusOfCount:_countSetting];
        angle = [self.geometryController degreesFromRadians:atan((0.52*[_label size].width)/radius)];
		self.drawingPath = [NSBezierPath bezierPath];
		[self.drawingPath appendBezierPathWithArcWithCenter:NSMakePoint(0.0,0.0) radius:radius startAngle:90+angle endAngle:90-angle];
		_labelPoint = NSMakePoint(0 - (0.5*[_label size].width),radius - (0.5*[_label size].height));


				
	}
	[self.drawingPath setLineWidth:self.lineWidth];
}

-(void)drawRect:(NSRect)aRect
{
    [self computeLabelText];
    if(NSIntersectsRect(aRect,[self.drawingPath bounds]))
    {  
        [NSGraphicsContext saveGraphicsState];

        [self.strokeColor set];

		[theTransform concat];
		[self.drawingPath stroke];
        if(self.drawsFill)
        {	
            [self.fillColor set];
            [self.drawingPath fill];
        }
        if((_showLabel)&&(!_isCore))
		{
			[_label drawAtPoint:_labelPoint];
		}
        [NSGraphicsContext restoreGraphicsState];
        [self setNeedsDisplay:NO];
    }
}

-(void)setGeometryPercent:(float)percent
{
    _percentSetting = percent*[self.geometryController geometryMaxPercent];
	[self calculateGeometry];
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    [theDict setObject:@"LabelCircle" forKey:@"GraphicType"];
	if(_showLabel)
		[theDict setObject:@"YES" forKey:@"_showLabel"];
	else
		[theDict setObject:@"NO" forKey:@"_showLabel"];
	
	[theDict setObject:[NSString stringWithFormat:@"%f",_labelAngle] forKey:@"_labelAngle"];
    [theDict setObject:_label.string forKey:@"Label"];
	[theDict setObject:_labelFont forKey:@"_labelFont"];
	
	if(_isCore)
		[theDict setObject:@"YES" forKey:@"_isCore"];
	else
		[theDict setObject:@"NO" forKey:@"_isCore"];

	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

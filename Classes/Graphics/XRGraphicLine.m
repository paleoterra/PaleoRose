//
//  XRGraphicLine.m
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

#import "XRGraphicLine.h"
#import "XRGeometryController.h"

@implementation XRGraphicLine
-(id)initWithController:(XRGeometryController *)aController
{
	if (!(self = [super initWithController:aController])) return nil;
	if(self)
	{
		_tickType = XRGraphicLineTickTypeNone;
		_relativePercent = 1.0;
		_spokeNumberAlign = XRGraphicLineNumberAlignHorizontal;
		_spokeNumberCompassPoint = XRGraphicLineNumberPoints;
		_spokeNumberOrder = XRGraphicLineNumberingOrderQuad;
		_showLabel = YES;
		_spokePointOnly = NO;
		_currentFont = [NSFont fontWithName:@"Arial-Black" size:12];
	}
	return self;
}

-(void)setSpokeAngle:(float)angle
{
	_angleSetting = angle;
	[self setLineLabel];

	[self calculateGeometry];
}

-(float)spokeAngle
{
	return _angleSetting;
}

-(void)calculateGeometry
{
	float radius;

	NSPoint aPoint;

	aPoint = NSMakePoint(0.0,0.0);
	radius = [geometryController radiusOfRelativePercent:0.0];
	aPoint.y = radius;
	aPoint = [geometryController rotationOfPoint:aPoint byAngle:_angleSetting];
	_drawingPath = [[NSBezierPath alloc] init];
	[_drawingPath moveToPoint:aPoint];
	if((_tickType == XRGraphicLineTickTypeNone)||(!_showTick))
		radius = [geometryController radiusOfRelativePercent:_relativePercent];
	else if(_tickType == XRGraphicLineTickTypeMinor)
		radius = [geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent+ 0.05)];
	else
		radius = [geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent+ 0.1)];
	aPoint = NSMakePoint(0.0,0.0);
	aPoint.y = radius;

	aPoint = [geometryController rotationOfPoint:aPoint byAngle:_angleSetting];
	[_drawingPath lineToPoint:aPoint];
	
	
	[self setLabelTransform];		
	
	
}

-(void)setTickType:(int)tickType
{
	_tickType = tickType;
	[self calculateGeometry];
}

-(int)tickType
{
	return _tickType;
}

-(void)setShowTick:(BOOL)showTick
{
	_showTick = showTick;
	[self calculateGeometry];
}

-(void)setLineLabel
{
	

	if(((double)_angleSetting == 0.0)||((double)_angleSetting == 90.0) || ((double)_angleSetting == 180.0) || ((double)_angleSetting == 270.0)||((double)_angleSetting == 360.0))
	{

		if(_spokeNumberCompassPoint == XRGraphicLineNumberPoints)
		{
		if((double)_angleSetting == 0.0)
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:@"N"];
		else if((double)_angleSetting == 90.0)
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:@"E"];
		else if((double)_angleSetting == 180.0)
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:@"S"];
		else if((double)_angleSetting == 270.0)
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:@"W"];
		else
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:@"N" ];
		}
		else if(_spokeNumberOrder == XRGraphicLineNumberingOrderQuad)
		{
			double workAngle;
			if(_angleSetting <= 90.0)
			{
				workAngle = _angleSetting;
			}
			else if((_angleSetting > 90.0)&&(_angleSetting <= 180.0))
			{
				workAngle = 180.0 - _angleSetting;
			}
			else if((_angleSetting > 180.0)&&(_angleSetting <= 270.0))
			{
				workAngle = _angleSetting - 180.0;
			}
			else
			{
				workAngle = 360.0 - _angleSetting;
			}
			if((double)_angleSetting == (double)floor(_angleSetting))
			{
				_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",(int)workAngle]];
			}
			else
				_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",workAngle]];
			
		}
		else
		{
			if((double)_angleSetting == (double)floor(_angleSetting))
			{
				_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",(int)_angleSetting]];
			}
			else
				_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",_angleSetting]];
		}
	
			
	}
	else if((_spokeNumberOrder ==XRGraphicLineNumberingOrder360)&&(!_spokePointOnly))
	{
		if((double)_angleSetting == (double)floor(_angleSetting))
		{
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",(int)_angleSetting]];
		}
		else
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",_angleSetting]];
	}
	else if(!_spokePointOnly)
	{
		//NSLog(@"else");
		double workAngle;
		if(_angleSetting <= 90.0)
		{
			workAngle = _angleSetting;
		}
		else if((_angleSetting > 90.0)&&(_angleSetting <= 180.0))
		{
			workAngle = 180.0 - _angleSetting;
		}
		else if((_angleSetting > 180.0)&&(_angleSetting <= 270.0))
		{
			workAngle = _angleSetting - 180.0;
		}
		else
		{
			workAngle = 360.0 - _angleSetting;
		}
		if((double)_angleSetting == (double)floor(_angleSetting))
		{
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",(int)workAngle]];
		}
		else
			_lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",workAngle]];
	}
	else
	{
		_showLabel = NO;

		_lineLabel = [[NSMutableAttributedString alloc] initWithString:@""];
	}
	/*if((_spokeNumberOrder==XRGraphicLineNumberingOrderPointOnly)&&(((double)_angleSetting != 0.0)&&((double)_angleSetting != 90.0) && ((double)_angleSetting != 180.0) && ((double)_angleSetting != 270.0)&&((double)_angleSetting != 360.0)))
	{
		[_lineLabel release];
		_lineLabel = [[NSMutableAttributedString alloc] initWithString:@""];
	}*/
	[self setLabelTransform];
}


-(void)drawRect:(NSRect)aRect
{
    //NSLog(@"drawing graphic");
    
    if(NSIntersectsRect(aRect,[_drawingPath bounds]))
    {  
        [NSGraphicsContext saveGraphicsState];
        
        [_strokeColor set];
		//NSLog(@"width %f",[_drawingPath lineWidth]);
        [_drawingPath stroke];
        if(_drawsFill)
        {	
            [_fillColor set];
            [_drawingPath fill];
        }
        if(_showLabel)
		{
			
			[_labelTransform concat];
			[_lineLabel drawAtPoint:NSMakePoint(0.0,0.0)];
		}
        [NSGraphicsContext restoreGraphicsState];
        [self setNeedsDisplay:NO];
    }
}

-(void)setLabelTransform
{
	NSRange labelRange;
	labelRange.location = 0;
	labelRange.length = [_lineLabel length];
	[_lineLabel setAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_currentFont,_strokeColor,nil]
														   forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]] range:labelRange];
	_labelTransform = [NSAffineTransform transform];
	if(_spokeNumberAlign == XRGraphicLineNumberAlignHorizontal)
		[self appendHorizontalTransform];
	else
		[self appendParallelTransform];
}

-(void)appendHorizontalTransform
{
	NSSize theSize = [_lineLabel size];
	float displacement = [geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent + .2)];
	float rotationAngle;
	//step 1. shift to the center point
	[_labelTransform translateXBy:(-0.5*theSize.width) yBy:(-0.5*theSize.height)];
	//step 2. rotation in the inverse direction
	rotationAngle = _angleSetting - 90;
	
	[_labelTransform rotateByDegrees:(-1*rotationAngle)];
	
	//step 3. shift out
	[_labelTransform translateXBy:displacement yBy:0.0];
	
	//step 4. final rotation
	
	[_labelTransform rotateByDegrees:rotationAngle];
}

-(void)appendParallelTransform
{
	
	NSSize theSize = [_lineLabel size];
	
	float displacement = [geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent + 0.1)];
	float rotationAngle = 90-_angleSetting;
	//[_labelTransform translateXBy:(-0.5*theSize.width) yBy:(-0.5*theSize.height)];
	//transform 1.  Shift the text down by half the height.
	if((double)_angleSetting == 0.0) 
	{
		
		[_labelTransform translateXBy:(-0.5*theSize.width) yBy:displacement];
		
	}
	else if((double)_angleSetting == 180.0)
		[_labelTransform translateXBy:(-0.5*theSize.width) yBy:(displacement+theSize.height)*-1];
	else 
	{
		if(_angleSetting > 180.0)
		{
			
			[_labelTransform rotateByDegrees:rotationAngle-180];
			[_labelTransform translateXBy:-1 *(displacement+theSize.width) yBy:0.0];
			[_labelTransform translateXBy:0.0 yBy:(-0.5*theSize.height)];
		}
		else
		{
			
			[_labelTransform rotateByDegrees:rotationAngle];
			[_labelTransform translateXBy:displacement yBy:0.0];
			[_labelTransform translateXBy:0.0 yBy:(-0.5*theSize.height)];
		}
		
		
	}
}

-(void)setShowlabel:(BOOL)show
{
	_showLabel = show;
}

-(void)setNumberAlignment:(int)alignment
{
	_spokeNumberAlign = alignment;
}

-(void)setNumberOrder:(int)order
{
	_spokeNumberOrder = order;
	[self setLineLabel];
}

-(void)setNumberPoints:(int)pointRule
{
	_spokeNumberCompassPoint = pointRule;
	[self setLineLabel];
}

-(void)setFont:(NSFont *)font
{
	_currentFont = font;
	[self calculateGeometry];
}

-(NSFont *)font
{
	return _currentFont;
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
	//NSLog(@"graphic  line label");
	
	[theDict setObject:[NSString stringWithFormat:@"%f",_relativePercent] forKey:@"_relativePercent"];
	
	[theDict setObject:[NSString stringWithFormat:@"%f",_angleSetting] forKey:@"_angleSetting"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_tickType] forKey:@"_tickType"];
	
	if(_showTick)
		[theDict setObject:@"YES" forKey:@"_showTick"];
	else
		[theDict setObject:@"NO" forKey:@"_showTick"];
	
	
	
	[theDict setObject:[NSString stringWithFormat:@"%i",_spokeNumberAlign] forKey:@"_spokeNumberAlign"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_spokeNumberCompassPoint] forKey:@"_spokeNumberCompassPoint"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_spokeNumberOrder] forKey:@"_spokeNumberOrder"];
	
	if(_showLabel)
		[theDict setObject:@"YES" forKey:@"_showLabel"];
	else
		[theDict setObject:@"NO" forKey:@"_showLabel"];
	
	[theDict setObject:_lineLabel forKey:@"_lineLabel"];
	
	[theDict setObject:_currentFont forKey:@"_currentFont"];
	//NSLog(@"end graphic  line label");
	return [NSDictionary dictionaryWithDictionary:theDict];
}

-(void)setPointsOnly:(BOOL)value
{
	_spokePointOnly = value;

	[self setLineLabel];
}
@end

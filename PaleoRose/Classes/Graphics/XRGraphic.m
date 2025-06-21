//
//  XRGraphic.m
//  XRose
//
//  Created by Tom Moore on Tue Jan 06 2004.
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

#import "XRGraphic.h"
#import "XRGeometryController.h"
#import <math.h>

#import "XRGraphicCircle.h"
#import "XRGraphicCircleLabel.h"
#import "XRGraphicLine.h"
#import "XRGraphicKite.h"
#import "XRGraphicPetal.h"
#import "XRGraphicDot.h"
#import "XRGraphicHistogram.h"
#import "XRGraphicDotDeviation.h"
@implementation XRGraphic

-(id)initWithController:(XRGeometryController *)controller
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		_fillColor = [NSColor blackColor];
		_strokeColor = [NSColor blackColor];
		_lineWidth = 1.0;
		_needsDisplay = YES;
		_isSelected = NO;
		_drawsFill = NO;
		geometryController = controller;//not retained.
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChangeIsPercent object:geometryController];
	}
	return self;
}



-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
//calculate Rose Geometry

-(void)geometryDidChange:(NSNotification *)aNotification
{
	//NSLog(@"geometryDidChange");
	[self calculateGeometry];
}

-(void)calculateGeometry
{
	//NSLog(@"XRGraphic calculateGeometry");
	//here subclasses must set up the geometry of the graphic object.
}

//redraw
-(void)setNeedsDisplay:(BOOL)display
{
    _needsDisplay = display;
}

-(BOOL)needsDisplay
{
    return _needsDisplay;
}



//tests whether an object is within a rect.  If so, then needs display will return a YES

-(NSRect)drawingRect;//if this object needs redrawing, then use this to get its rect
{
    return [_drawingPath bounds];
}

-(void)drawRect:(NSRect)aRect
{

    @try {
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
        
        [NSGraphicsContext restoreGraphicsState];
        [self setNeedsDisplay:NO];
    }
	}
	@catch (NSException *exception){
		NSLog(@"%@:drawRect: Caught %@: %@",[self className], [exception name], [exception reason]);
	
	}
}


//hit test
- (BOOL)hitTest:(NSPoint)point
{
    return NO;
}

//selection
-(BOOL)isSelected
{
    return NO;//not selectable
}

-(void)setSelected:(BOOL)newSelection
{
    return;//not selectable
}

-(void)selectGraphic
{
    return;
}
-(void)deselectGraphic
{
    return;
}

//inspector info
-(NSDictionary *)inspectorInfo
{
    NSDictionary *theDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_fillColor,
		_strokeColor,
		[NSNumber numberWithFloat:_lineWidth],
		[NSNumber numberWithBool:_drawsFill],
		nil]
														forKeys:[NSArray arrayWithObjects:XRGraphicKeyFillColor,
															XRGraphicKeyStrokeColor,
															XRGraphicKeyLineWidth,
															XRGraphicKeyDrawsFill,
															nil]];
    return theDict;
}


//Color
-(void)setDrawsFill:(BOOL)fill
{
    _drawsFill = fill;
}

-(BOOL)drawsFill
{
    return _drawsFill;
}

-(NSColor *)strokeColor
{
    return _strokeColor;
}

-(void)setStrokeColor:(NSColor *)aColor
{
	_strokeColor = aColor;
	
    return;
}

-(void)setDefaultStrokeColor
{
    _strokeColor = [NSColor blackColor];
    return;
}

-(NSColor *)fillColor
{
    return _fillColor;
}

-(void)setFillColor:(NSColor *)aColor
{
	_fillColor = aColor;
    return;
}

-(void)setDefaultFillColor
{
    _fillColor = [NSColor blackColor];
}

-(void)setTransparency:(float)alpha
{
    NSColor *temp;
    if(alpha>1)
    {
        //NSLog(@"invalid alpha value");
        alpha = 1.0;
    }
    //do stroke
    if(!_strokeColor)
        [self setDefaultStrokeColor];
    temp = [_strokeColor colorWithAlphaComponent:alpha];
    if(temp)
    {
        _strokeColor = temp;
    }
    temp = nil;
    
    if(!_fillColor)
        [self setDefaultFillColor];
    temp = [_fillColor colorWithAlphaComponent:alpha];
    if(temp)
    {
        _fillColor = temp;
    }
    return;
    
}


-(void)setLineColor:(NSColor *)aLineColor fillColor:(NSColor *)aFillColor
{
	_strokeColor = aLineColor;
	_fillColor = aFillColor;

}

-(void)setLineWidth:(float)newWeight
{
	_lineWidth = newWeight;
	if(_drawingPath)
		[_drawingPath setLineWidth:_lineWidth];

}

-(float)lineWidth
{
	return _lineWidth;
}



-(BOOL)compareColor:(NSColor *)color1 withColor:(NSColor *)color2
{
    NSColor *color1a = [color1 colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];;
    NSColor *color2a = [color2 colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];;
	if([color1a redComponent]!=[color2a redComponent])
		return NO;
	if([color1a greenComponent]!=[color2a greenComponent])
		return NO;
	if([color1a blueComponent]!=[color2a blueComponent])
		return NO;
	if([color1a alphaComponent]!=[color2a alphaComponent])
		return NO;
	return YES;
}

-(NSDictionary *)graphicSettings
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	//NSLog(@"general graphic");
	if([self isKindOfClass:[XRGraphicCircleLabel class]])
		[theDict setObject:@"LabelCircle" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicCircle class]])
		[theDict setObject:@"Circle" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicLine class]])
		[theDict setObject:@"Line" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicKite class]])
		[theDict setObject:@"Kite" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicPetal class]])
		[theDict setObject:@"Petal" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicDot class]])
		[theDict setObject:@"Dot" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicHistogram class]])
		[theDict setObject:@"Histogram" forKey:@"GraphicType"];
	else if ([self isKindOfClass:[XRGraphicDotDeviation class]])
		[theDict setObject:@"DotDeviation" forKey:@"GraphicType"];
	else
		[theDict setObject:@"Graphic" forKey:@"GraphicType"];
	
	[theDict setObject:_fillColor forKey:@"_fillColor"];
	[theDict setObject:_strokeColor forKey:@"_strokeColor"];
    [theDict setObject:[NSString stringWithFormat:@"%f",_lineWidth] forKey:@"_lineWidth"];
	//NSLog(@"end general graphic");
	return [NSDictionary dictionaryWithDictionary:theDict];
}

@end

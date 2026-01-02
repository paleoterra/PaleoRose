//
//  XRLayer.m
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

#import "XRLayer.h"
#import "XRGeometryController.h"
#import "XRLayerCore.h"
#import "XRLayerGrid.h"
#import "XRLayerData.h"
#import "XRLayerText.h"
#import "XRLayerLineArrow.h"
#import <PaleoRose-Swift.h>

@implementation XRLayer

-(id)init {
    self = [super init];
    if(self) {
        _graphicalObjects = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];
        [self setStrokeColor:[NSColor blackColor]];
        [self setFillColor:[NSColor blackColor]];
        [self setIsVisible:YES];
        [self setIsActive:NO];
        _canFill = YES;
        _canStroke = YES;
    }
    return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		geometryController = aController;
		_graphicalObjects = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];
		[self setStrokeColor:[NSColor blackColor]];
		[self setFillColor:[NSColor blackColor]];
		[self setIsVisible:YES];
		[self setIsActive:NO];
		_canFill = YES;
		_canStroke = YES;
		
			}
	return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		NSColor *aColor;
		NSString *tempString;
		geometryController = aController;
		_graphicalObjects = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];
		if((aColor = [configure objectForKey:@"Stroke_Color"]))
			[self setStrokeColor:aColor];
		if((aColor = [configure objectForKey:@"Fill_Color"]))
			[self setFillColor:aColor];
		
		if((tempString = [configure objectForKey:@"Visible"]))
		{
			if([tempString isEqualToString:@"YES"])
				[self setIsVisible:YES];
			else
				[self setIsVisible:NO];
		}
		if((tempString = [configure objectForKey:@"Active"]))
		{
			if([tempString isEqualToString:@"YES"])
				[self setIsActive:YES];
			else
				[self setIsActive:NO];
		}
		
		if((tempString = [configure objectForKey:@"BIDIR"]))
		{
			if([tempString isEqualToString:@"YES"])
				_isBiDir = YES;
			else
				_isBiDir = NO;
		}
		
		if((tempString = [configure objectForKey:@"Layer_Name"]))
			_layerName = tempString;
		
		if((tempString = [configure objectForKey:@"Line_Weight"]))
			_lineWeight = [tempString floatValue];
		
		if((tempString = [configure objectForKey:@"Max_Count"]))
			_maxCount = [tempString floatValue];
		
		if((tempString = [configure objectForKey:@"Max_Percent"]))
			_lineWeight = [tempString floatValue];
		
		_canFill = YES;
		_canStroke = YES;
		
		 
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)isVisible
{
	return _isVisible;
}

-(void)setIsVisible:(BOOL)visible
{
	if(visible==_isVisible)
		return;
	_isVisible = visible;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(BOOL)isActive
{
	return _isActive;
}

-(void)setIsActive:(BOOL)active
{
	_isActive = active;//possibly change if needed a UI reaction
}

-(NSColor *)strokeColor
{
	return _strokeColor;
}

-(void)setStrokeColor:(NSColor *)color
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	_strokeColor = color;
	[self resetColorImage];
	//possibly post notification.
	while(aGraphic = [anEnum nextObject])
	{
		[aGraphic setStrokeColor:_strokeColor];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];

}

-(NSColor *)fillColor
{
	return _fillColor;
}

-(void)setFillColor:(NSColor *)color
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	_fillColor = color;
	[self resetColorImage];
	//possibly post notification.
	while(aGraphic = [anEnum nextObject])
	{
        if([aGraphic respondsToSelector:@selector(setFillColor:)]) {
            [aGraphic setFillColor:_fillColor];
        }
	}
	//NSLog(@"set fill color %@",[[self class] description]);
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(NSString *)layerName
{
	return _layerName;
}

-(void)setLayerName:(NSString *)layerName
{
	_layerName = layerName;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(BOOL)isBiDirectional
{
	return _isBiDir;
}

-(void)setBiDirectional:(BOOL)isBiDir
{

	_isBiDir = isBiDir;
	//requires updating the counts and percents
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(void)resetColorImage
{

	NSRect imageRect = NSMakeRect(0.0,0.0,16.0,16.0);
	_anImage = nil;
	_anImage = [[NSImage alloc] initWithSize:imageRect.size];
	//if(_anImage)
	//	NSLog([_anImage description]);
	//NSLog(@"reset image for object %@",[self layerName]);
	//NSLog(@"resetColorImage 1");
	NSBezierPath *aPath = [NSBezierPath bezierPathWithRect:imageRect];
	//NSLog(@"resetColorImage 1.1");
	[aPath setLineWidth:4.0];
	//NSLog(@"resetColorImage 1.2");
	[_anImage lockFocus];
	//NSLog(@"resetColorImage 1.3");
	[_strokeColor set];
	//NSLog(@"resetColorImage 1.4");
	[aPath stroke];
	//NSLog(@"resetColorImage 2");
	imageRect = NSInsetRect(imageRect,2.0,2.0);
	//NSLog(@"resetColorImage %i",[_graphicalObjects count]);
	if([_graphicalObjects count] > 0)
	{
		if([[_graphicalObjects objectAtIndex:0] respondsToSelector:@selector(drawsFill)] && [[_graphicalObjects objectAtIndex:0] drawsFill])
		{
			//NSLog(@"draws fill");
			[_fillColor set];
			aPath = [NSBezierPath bezierPathWithRect:imageRect];
			[aPath fill];
		}
	}
	//NSLog(@"resetColorImage 3");
	[_anImage unlockFocus];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];

	
		

}
-(NSImage *)colorImage
{
	return _anImage;
}

-(void)generateGraphics
{
	
}

-(void)drawRect:(NSRect)rect
{
}

-(void)geometryDidChange:(NSNotification *)notification
{
	[self generateGraphics];

	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)geometryDidChangePercent:(NSNotification *)notification
{
	[self generateGraphics];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)geometryDidChangeSectors:(NSNotification *)notification
{
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(int)maxCount
{
	return _maxCount;
}

-(float)maxPercent
{
	return _maxPercent;
}

-(void)setLineWeight:(float)lineWeight
{
	_lineWeight = lineWeight;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(float)lineWeight
{
	return _lineWeight;
}

-(NSDictionary *)layerSettings
{
	NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
	//NSLog(@"standard layer");
	if([self isKindOfClass:[XRLayerCore class]])
		[aDict setObject:@"Core_Layer" forKey:XRLayerXMLType];
	else if([self isKindOfClass:[XRLayerData class]])
		[aDict setObject:@"Data_Layer" forKey:XRLayerXMLType];
	else if([self isKindOfClass:[XRLayerGrid class]])
		[aDict setObject:@"Grid_Layer" forKey:XRLayerXMLType];
	else
		[aDict setObject:@"Layer" forKey:XRLayerXMLType];
	
	if(_isVisible)
		[aDict setObject:@"YES" forKey:@"Visible"];
	else
		[aDict setObject:@"NO" forKey:@"Visible"];
	
	if(_isActive)
		[aDict setObject:@"YES" forKey:@"Active"];
	else
		[aDict setObject:@"NO" forKey:@"Active"];
	
	[aDict setObject:_layerName forKey:@"Layer_Name"];
	
	if(_isBiDir)
		[aDict setObject:@"YES" forKey:@"BIDIR"];
	else
		[aDict setObject:@"NO" forKey:@"BIDIR"];

	[aDict setObject:_strokeColor forKey:@"Stroke_Color"];

	[aDict setObject:_fillColor forKey:@"Fill_Color"];
	//NSLog(@"line weight %f",_lineWeight);
	[aDict setObject:[NSString stringWithFormat:@"%f",_lineWeight] forKey:@"Line_Weight"];
	[aDict setObject:[NSString stringWithFormat:@"%i",_maxCount] forKey:@"Max_Count"];
	[aDict setObject:[NSString stringWithFormat:@"%f",_maxPercent] forKey:@"Max_Percent"];
	//NSLog(@"end standard layer");
	return [NSDictionary dictionaryWithDictionary:aDict];
}

-(XRDataSet *)dataSet
{
	return nil;
}

-(void)setDataSet:(XRDataSet *)aSet
{
	return;
}

-(BOOL)handleMouseEvent:(NSEvent *)anEvent
{
	//NSLog(@"layer handle mouse down");
	return NO;
}

-(BOOL)hitDetection:(NSPoint)testPoint
{
	return NO;
}

-(void)setGeometryController:(XRGeometryController *)controller
{
	if (geometryController == controller) {
		return;
	}

	// Remove old observers if we had a previous controller
	if (geometryController) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:XRGeometryDidChange object:geometryController];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:XRGeometryDidChangeIsPercent object:geometryController];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:XRGeometryDidChangeSectors object:geometryController];
	}

	geometryController = controller;

	// Add new observers
	if (geometryController) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];

		// Generate graphics now that we have a geometry controller
		// BUT: XRLayerData and XRLayerLineArrow need their dataset set first,
		// so they should NOT generate graphics here. Their setDataSet method will do it.
		if (![self isKindOfClass:[XRLayerData class]] && ![self isKindOfClass:[XRLayerLineArrow class]]) {
			[self generateGraphics];
		}
	}
}

-(XRGeometryController *)geometryController
{
	return geometryController;
}

-(NSString *)type
{
    return @"XRLayer";
}

@end

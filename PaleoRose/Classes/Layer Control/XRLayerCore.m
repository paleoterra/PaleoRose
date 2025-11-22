//
//  XRLayerCore.m
//  XRose
//
//  Created by Tom Moore on Thu Feb 05 2004.
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
#import "XRLayerCore.h"
#import "XRGeometryController.h"
#import <PaleoRose-Swift.h>

@implementation XRLayerCore
//+(void)initialize
//{
//	[XRLayerCore setKeys:[NSArray arrayWithObject:@"_coreType"] triggerChangeNotificationsForDependentKey:@"coreRadiusIsEditable"];
//
//	[XRLayerCore setKeys:[NSArray arrayWithObjects:@"_strokeColor",@"_fillColor",nil] triggerChangeNotificationsForDependentKey:@"updateColors"];
//}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"coreRadiusIsEditable"]) {
        NSArray *affectingKeys = @[@"_coreType"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    else if ([key isEqualToString:@"updateColors"]) {
        NSArray *affectingKeys = @[@"_strokeColor",@"_fillColor"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

-(id)initWithGeometryController:(XRGeometryController *)aController
{
	if (!(self = [super initWithGeometryController:aController])) return nil;
	if(self)
	{
		if([aController hollowCoreSize]>0.0)
			_coreType = XRLayerCoreTypeHollow;
		else
			_coreType = XRLayerCoreTypeOverlay;
		
		_lineWeight = 1.0;
		_corePattern = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[XRLayerCore class]]pathForImageResource:@"hollowCorePattern"]];
		_percentRadius = 0.02;
		_canFill = YES;
		[self setStrokeColor:[NSColor blackColor]];
		[self setFillColor:[NSColor whiteColor]];
		[self setLayerName:@"Core"];
		[self generateGraphics];
		
	
		
	}
	return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure
{
	if (!(self = [super initWithGeometryController:aController dictionary:configure])) return nil;
	if(self)
	{
		NSArray *anArray;
		NSString *tempstring;
		
		if((tempstring = [configure objectForKey:XRLayerCoreXMLCoreType]))
		{
			if([tempstring isEqualToString:@"YES"])
				_coreType = YES;
			else
				_coreType = NO;
		}
		if((tempstring = [configure objectForKey:XRLayerCoreXMLCoreRadius]))
			_percentRadius = [tempstring floatValue];
		
		
		
		[self generateGraphics];
		if((anArray = [configure objectForKey:XRLayerGraphicObjectArray]))
		{
			//NSLog(@"configure core graphics");
		}

	}
	return self;
}

-(id)initWithIsVisible:(BOOL)visible
                active:(BOOL)active
                 biDir:(BOOL)isBiDir
                  name:(NSString *)layerName
            lineWeight:(float)lineWeight
              maxCount:(int)maxCount
            maxPercent:(float)maxPercent
           strokeColor:(NSColor *)strokeColor
             fillColor:(NSColor *)fillColor
         percentRadius:(float)percentRadius
                  type:(BOOL)coreType{
    self = [super init];
    if (self) {
        _isVisible = visible;
        _isActive = active;
        _isBiDir = isBiDir;
        _layerName = layerName;
        _lineWeight = lineWeight;
        _maxCount = maxCount;
        _maxPercent = maxPercent;
        _maxPercent = maxPercent;
        _strokeColor = strokeColor;
        _fillColor = fillColor;
        _percentRadius = percentRadius;
        _coreType = coreType;
    }
    return self;
}

-(BOOL)coreType {
    return _coreType;
}

-(float)radius {
    return _percentRadius;
}

-(void)generateGraphics
{
	//NSLog(@"generating graphics");
	[_graphicalObjects removeAllObjects];
	if(!_coreType)
	{
		GraphicCircle * aCircle = [[GraphicCircle alloc] initWithController:geometryController];
		[aCircle setGeometryPercent:_percentRadius];
		[aCircle setDrawsFill:_canFill];
		[aCircle setStrokeColor:_strokeColor];
		[aCircle setFillColor:_fillColor];
		[_graphicalObjects addObject:aCircle];
	}
	else
	{
		
		GraphicCircle * aCircle = [[GraphicCircle alloc] initCoreCircleWithController:geometryController];
		NSImage *anImage = [[NSImage alloc] initWithSize:[_corePattern size]];
		NSColor *newColor;
		[anImage lockFocus];
		[_fillColor set];
		[[NSBezierPath bezierPathWithRect:NSMakeRect(0.0,0.0,[_corePattern size].width, [_corePattern size].height)] fill];
        [_corePattern drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0, 0.0, _corePattern.size.width, _corePattern.size.height) operation:NSCompositingOperationDestinationIn fraction:1.0];
		[anImage unlockFocus];
		newColor = [NSColor colorWithPatternImage:anImage];
		//newColor = [NSColor colorWithPatternImage:_corePattern];
		[aCircle setStrokeColor:_strokeColor];
		[aCircle setFillColor:newColor];
		[aCircle setDrawsFill:_canFill];
		[_graphicalObjects addObject:aCircle];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)drawRect:(NSRect)rect
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	if(_isVisible)
	{
		while(aGraphic = [anEnum nextObject])
		{
			[aGraphic setLineWidth:_lineWeight];
			[aGraphic drawRect:rect];
		}
	}
}

-(BOOL)coreRadiusIsEditable
{
	return !_coreType;
}

-(NSDictionary *)layerSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super layerSettings]];
	NSMutableArray *theGraphics  = [[NSMutableArray alloc] init];
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	if(_coreType)
		[theDict setObject:@"YES" forKey:XRLayerCoreXMLCoreType];
	else
		[theDict setObject:@"NO" forKey:XRLayerCoreXMLCoreType];
	[theDict setObject:[NSString stringWithFormat:@"%f",_percentRadius] forKey:XRLayerCoreXMLCoreRadius];
	
	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addObject:[aGraphic graphicSettings]];
	}
	[theDict setObject:theGraphics forKey:XRLayerGraphicObjectArray];
	return [NSDictionary dictionaryWithDictionary:theDict];
}

+(NSString *)classTag
{
	return @"CORE";
}

-(NSString *)type
{
	return @"XRLayerCore";
}

@end

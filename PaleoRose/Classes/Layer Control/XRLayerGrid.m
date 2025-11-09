//
//  XRLayerGrid.m
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

#import "XRLayerGrid.h"
#import "XRGeometryController.h"
#import "PaleoRose-Swift.h"
#import "sqlite3.h"

@implementation XRLayerGrid

+(void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:2],
			
			[NSNumber numberWithInt:36],
			[NSNumber numberWithFloat:10.0],
			[NSNumber numberWithFloat:.1],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithBool:NO],
			[NSNumber numberWithBool:YES],
			[NSNumber numberWithFloat:1.0],
			nil] 
					  forKeys:[NSArray arrayWithObjects:XRLayerGridDefaultRingCount,
						  
						  XRLayerGridDefaultSpokeCount,
						  XRLayerGridDefaultSpokeAngle,
						  XRLayerGridDefaultRingPercent,
						  XRLayerGridDefaultRingFixedCount,
						  XRLayerGridDefaultRingFixed,
						  XRLayerGridDefaultSectorLock,
						  XRLayerGridDefaultLineWidth,
						  nil]];
//	[XRLayerGrid setKeys:[NSArray arrayWithObject:@"_spokeSectorLock"] triggerChangeNotificationsForDependentKey:@"spokeSectorsEditable"];
//	[XRLayerGrid setKeys:[NSArray arrayWithObject:@"_fixedCount"] triggerChangeNotificationsForDependentKey:@"allowEditFixedRing"];
////	[XRLayerGrid setKeys:[NSArray arrayWithObject:@"_fixedCount"] triggerChangeNotificationsForDependentKey:@"allowEditVariableRing"];
//	[XRLayerGrid setKeys:[NSArray arrayWithObject:@"_fixedCount"] triggerChangeNotificationsForDependentKey:@"allowEditPercentRings"];
//	[XRLayerGrid setKeys:[NSArray arrayWithObject:@"_fixedCount"] triggerChangeNotificationsForDependentKey:@"allowEditCountRings"];
	[defaults registerDefaults:appDefaults];
	
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"spokeSectorsEditable"]) {
        NSArray *affectingKeys = @[@"_spokeSectorLock"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    else if ([key isEqualToString:@"allowEditFixedRing"]) {
        NSArray *affectingKeys = @[@"_fixedCount"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    else if ([key isEqualToString:@"allowEditVariableRing"]) {
        NSArray *affectingKeys = @[@"_fixedCount"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    else if ([key isEqualToString:@"allowEditPercentRings"]) {
        NSArray *affectingKeys = @[@"_fixedCount"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    else if ([key isEqualToString:@"allowEditCountRings"]) {
        NSArray *affectingKeys = @[@"_fixedCount"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

-(id)initWithGeometryController:(XRGeometryController *)aController
{
	if (!(self = [super initWithGeometryController:aController])) return nil;
	if(self)
	{
		_spokeCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:XRLayerGridDefaultSpokeCount];
		_spokeAngle = [[NSUserDefaults standardUserDefaults] floatForKey:XRLayerGridDefaultSpokeAngle];
		_ringCountIncrement = (int)[[NSUserDefaults standardUserDefaults] integerForKey:XRLayerGridDefaultRingCount];
		_fixedRingCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:XRLayerGridDefaultRingFixedCount];
		_ringPercentIncrement =[[NSUserDefaults standardUserDefaults] floatForKey:XRLayerGridDefaultRingPercent];
		_fixedCount = [[NSUserDefaults standardUserDefaults] boolForKey:XRLayerGridDefaultRingFixed];
		_ringsVisible = YES;
		_spokeSectorLock = [[NSUserDefaults standardUserDefaults] boolForKey:XRLayerGridDefaultSectorLock];
		_spokesVisible = YES;
		_lineWeight = [[NSUserDefaults standardUserDefaults] floatForKey:XRLayerGridDefaultLineWidth];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:aController];
		_showTicks = NO;
		_minorTicks = NO;
		_spokeNumberAlign = GraphicLineNumberAlignHorizontal;
		_spokeNumberCompassPoint = GraphicLineNumberCompassPointPoints;
		_spokeNumberOrder = GraphicLineNumberingOrderQuad;
		_showLabels = NO;
		_showRingLabels = NO;
		_pointsOnly = NO;
		_spokeFont = [NSFont fontWithName:@"ArialMT" size:12];
		_ringFont = [NSFont fontWithName:@"ArialMT" size:12];
		_labelAngle = 0.0;
		[self setLayerName:@"grid"];
		[self generateGraphics];
	}
	return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure
{
	if (!(self = [super initWithGeometryController:aController dictionary:configure])) return nil;
	if(self)
	{
		NSDictionary *ringpDict,*spokeDict;
		NSString *tempstring;
		NSFont *tempFont;
		
		if((ringpDict = [configure objectForKey:@"ringSettings"]))
		{
			if((tempstring = [ringpDict objectForKey:@"FixedCount"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_fixedCount = YES;
				else
					_fixedCount = NO;
			}
			if((tempstring = [ringpDict objectForKey:@"RingsVisible"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_ringsVisible = YES;
				else
					_ringsVisible = NO;
			}
			if((tempstring = [ringpDict objectForKey:@"RingLabelsOn"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_showRingLabels = YES;
				else
					_showRingLabels = NO;
			}
			if((tempstring = [ringpDict objectForKey:@"FixedRingCount"]))
				_fixedRingCount = [tempstring intValue];
			if((tempstring = [ringpDict objectForKey:@"RingCountIncrement"]))
				_ringCountIncrement = [tempstring floatValue];
			
			if((tempstring = [ringpDict objectForKey:@"ringPercentIncrement"]))
				_ringPercentIncrement = [tempstring floatValue];
			if((tempstring = [ringpDict objectForKey:@"_labelAngle"]))
				_labelAngle = [tempstring floatValue];
			if((tempFont = [ringpDict objectForKey:@"ringLabelFont"]))
				_ringFont = tempFont;
		}
		
		if((spokeDict = [configure objectForKey:@"spokeSettings"]))
		{
			if((tempstring = [spokeDict objectForKey:@"_spokeSectorLock"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_spokeSectorLock = YES;
				else
					_spokeSectorLock = NO;
			}
			if((tempstring = [spokeDict objectForKey:@"_spokesVisible"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_spokesVisible = YES;
				else
					_spokesVisible = NO;
			}
			if((tempstring = [spokeDict objectForKey:@"_isPercent"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_isPercent = YES;
				else
					_isPercent = NO;
			}
			if((tempstring = [spokeDict objectForKey:@"_showTicks"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_showTicks = YES;
				else
					_showTicks = NO;
			}
			if((tempstring = [spokeDict objectForKey:@"_minorTicks"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_minorTicks = YES;
				else
					_minorTicks = NO;
			}
			if((tempstring = [spokeDict objectForKey:@"_showLabels"]))
			{
				if([tempstring isEqualToString:@"YES"])
					_showLabels = YES;
				else
					_showLabels = NO;
			}
			if((tempstring = [spokeDict objectForKey:@"_spokeNumberAlign"]))
				_spokeNumberAlign = [tempstring intValue];
			if((tempstring = [spokeDict objectForKey:@"_spokeNumberCompassPoint"]))
				_spokeNumberCompassPoint = [tempstring intValue];
			if((tempstring = [spokeDict objectForKey:@"_spokeNumberOrder"]))
				_spokeNumberOrder = [tempstring intValue];
			
			if((tempFont = [spokeDict objectForKey:@"_spokeFont"]))
				_spokeFont = tempFont;
			if((tempstring = [spokeDict objectForKey:@"Spoke_Count"]))
				_spokeCount = [tempstring intValue];
			if((tempstring = [spokeDict objectForKey:@"Spoke_Angle"]))
				_spokeAngle = [tempstring floatValue];
			
		}

		[self generateGraphics];
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
          isFixedCount:(BOOL)isFixedCount
          ringsVisible:(BOOL)ringsVisible
        fixedRingCount:(int)fixedRingCount
    ringCountIncrement:(int)ringCountIncrement
    ringPercentIncrement:(float)ringPercentIncrement
        showRingLabels:(BOOL)showRingLabels
            labelAngle:(float)labelAngle
              ringFont:(NSFont *)ringFont
          radialsCount:(int)radialsCount
          radialsAngle:(float)radialsAngle
 radialsLabelAlignment:(int)radialsLabelAlignment
   radialsCompassPoint:(int)radialsCompassPoint
          radialsOrder:(int)radialsOrder
            radialFont:(NSFont *)radialFont
     radialsSectorLock:(BOOL)sectorLock
        radialsVisible:(BOOL)radialsVisible
      radialsIsPercent:(BOOL)isPercent
          radialsTicks:(BOOL)radialTicks
     radialsMinorTicks:(BOOL)radialMinorTicks
          radialLabels:(BOOL)radialLabels {
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
        _fixedCount = isFixedCount;
        _ringsVisible = ringsVisible;
        _fixedRingCount = fixedRingCount;
        _ringCountIncrement = ringCountIncrement;
        _ringPercentIncrement = ringPercentIncrement;
        _showRingLabels = showRingLabels;
        _labelAngle = labelAngle;
        _ringFont = ringFont;
        _spokeCount = radialsCount;
        _spokeAngle = radialsAngle;
        _spokeNumberAlign = radialsLabelAlignment;
        _spokeNumberCompassPoint = radialsCompassPoint;
        _spokeNumberOrder = radialsOrder;
        _spokeFont = radialFont;
        _spokeSectorLock = sectorLock;
        _spokesVisible = radialsVisible;
        _isPercent = isPercent;
        _showTicks = radialTicks;
        _minorTicks = radialMinorTicks;
        _showLabels = radialLabels;
    }
    return self;
}

-(void)setSpokeCount:(int)newCount
{
	if(newCount == _spokeCount)
		return;
	_spokeCount = newCount;
	_spokeAngle = 360.0/(float)_spokeCount;
	[self setValue:[NSNumber numberWithFloat:_spokeAngle] forKey:@"_spokeAngle"];
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)setSpokeAngle:(float)newAngle
{
	if(newAngle == _spokeAngle)
		return;
	if(![geometryController angleIsValidForSpoke:newAngle])
		return;
	_spokeAngle = newAngle;
	[self setValue:[NSNumber numberWithFloat:_spokeAngle] forKey:@"_spokeAngle"];
	_spokeCount = (int)(360.0/newAngle);
	[self setValue:[NSNumber numberWithInt:_spokeCount] forKey:@"_spokeCount"];
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(int)spokeCount
{
	return _spokeCount;
}

-(float)spokeAngle
{
	return _spokeAngle;
}

-(void)generateGraphics
{
	NS_DURING
	//NSLog(@"generating graphics");
	[self setValue:[NSNumber numberWithBool:[geometryController isPercent]] forKey:@"_isPercent"];
	if(_graphicalObjects)
		[_graphicalObjects removeAllObjects];
	else
		_graphicalObjects = [[NSMutableArray alloc] init];
	//NSLog(@"1");
	/*if(_fixedCount)
		NSLog(@"fixed count");*/
	//NSLog(@"line %f",_lineWeight);
	if(_fixedCount)
	{

		[self addFixedRings];
	}
	else
		[self addVariableRings];
	//do lines
	//NSLog(@"2");
	if(_spokeSectorLock)
		[self addVariableSpokes];
	else
		[self addFixedSpokes];
	//NSLog(@"3");
	NS_HANDLER
		NSLog(@"[XRLayerGrid generateGraphics] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER
}

-(void)addFixedSpokes
{
	NS_DURING
	float angle;
	GraphicLine *aLine;
	_spokeAngle = 360.0/(float)_spokeCount;
	[self setValue:[NSNumber numberWithInt:_spokeCount] forKey:@"_spokeCount"];
	[self setValue:[NSNumber numberWithFloat:_spokeAngle] forKey:@"_spokeAngle"];
	//NSLog(@"fixed spokes");
	for(int i=0;i<_spokeCount;i++)
	{
		angle = i * _spokeAngle;
		aLine = [[GraphicLine alloc] initWithController:geometryController];
		[aLine setSpokeAngle:angle];
		if(_showTicks)
		{
			//decide if major or minor.  Major only on compass points
			[aLine setShowTick:_showTicks];
			if(((double)angle == 90.0)||((double)angle == 180.0)||((double)angle == 270.0)||((double)angle == 360.0)||((double)angle == 90.0))
			{
				//NSLog(@"angle %f",angle);
				[aLine setTickType:GraphicLineTickTypeMajor];
			}
			else if(_minorTicks)
				[aLine setTickType:GraphicLineTickTypeMinor];
		}
		[aLine setFont:_spokeFont];
		[aLine setLineWidth:_lineWeight];
		[aLine setStrokeColor:_strokeColor];
		
		[self configureLine:aLine];
		[_graphicalObjects addObject:aLine];
	}
	NS_HANDLER
		//NSLog(@"[XRLayerGrid addFixedSpokes] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER
}

-(void)addVariableSpokes
{
	NS_DURING
	float angle;
	GraphicLine *aLine;
	_spokeCount = [geometryController sectorCount];
	[self setValue:[NSNumber numberWithInt:_spokeCount] forKey:@"_spokeCount"];
	_spokeAngle = 360.0/(float)_spokeCount;
	[self setValue:[NSNumber numberWithFloat:_spokeAngle] forKey:@"_spokeAngle"];

	for(int i=0;i<_spokeCount;i++)
	{
		angle = i * _spokeAngle;
		aLine = [[GraphicLine alloc] initWithController:geometryController];
		[aLine setSpokeAngle:angle];
		if(_showTicks)
		{
			//decide if major or minor.  Major only on compass points
			[aLine setShowTick:_showTicks];
			if(((double)angle == 90.0)||((double)angle == 180.0)||((double)angle == 270.0)||((double)angle == 360.0)||((double)angle == 0.0))
			{
				//NSLog(@"dangle %f",angle);
				[aLine setTickType:GraphicLineTickTypeMajor];
			}
			else if(_minorTicks)
				[aLine setTickType:GraphicLineTickTypeMinor];
		}
		[aLine setFont:_spokeFont];
		[aLine setLineWidth:_lineWeight];
		[aLine setStrokeColor:_strokeColor];
		[self configureLine:aLine];
		[_graphicalObjects addObject:aLine];
	}
	NS_HANDLER
		//NSLog(@"[XRLayerGrid addFixedSpokes] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER
}

-(void)configureLine:(GraphicLine *)aLine
{

	aLine.showLabel =_showLabels;
    aLine.spokeNumberAlign = _spokeNumberAlign;
    aLine.spokeNumberOrder = _spokeNumberOrder;
    aLine.spokeNumberCompassPoint = _spokeNumberCompassPoint;
    aLine.spokePointOnly = _pointsOnly;
}

-(void)addFixedRings
{
	NS_DURING
	GraphicCircleLabel *aCircle;
	float percent;
	[self setValue:[NSNumber numberWithBool:[geometryController isPercent]] forKey:@"_isPercent"];
	//NSLog(@"fixed rings");
	for(int i=0;i<_fixedRingCount;i++)
	{
		percent = (float)(i+1)/(float)_fixedRingCount;
		aCircle = [[GraphicCircleLabel alloc] initWithController:geometryController];
        aCircle.isFixedCount = YES;
		[aCircle setGeometryPercent:percent];
		[aCircle setLineWidth:_lineWeight];
		
		[aCircle setLabelAngle:_labelAngle];
		[aCircle setShowLabel:_showRingLabels];

		aCircle.labelFont = _ringFont;
		[aCircle setStrokeColor:_strokeColor];
		[_graphicalObjects addObject:aCircle];
		
		
	}
	//NSLog(@"count %i",[_graphicalObjects count]);
	if([geometryController hollowCoreSize]>0.0)//core boundary
	{
		aCircle = nil;
		aCircle = [[GraphicCircleLabel alloc] initCoreCircleWithController:geometryController];
		
		[aCircle setLabelAngle:_labelAngle];
		[aCircle setShowLabel:_showRingLabels];
		aCircle.labelFont = _ringFont;
		[aCircle setLineWidth:_lineWeight];
		[aCircle setStrokeColor:_strokeColor];
		
		[_graphicalObjects addObject:aCircle];
		
	}
	NS_HANDLER
		//NSLog(@"[XRLayerGrid addFixedRings] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER

}

-(void)addVariableRings
{
	NS_DURING
	GraphicCircleLabel *aCircle;
	[self setValue:[NSNumber numberWithBool:[geometryController isPercent]] forKey:@"_isPercent"];
	if([geometryController isPercent])
	{
		float max = [geometryController geometryMaxPercent];
		
		int count = (int)(max/_ringPercentIncrement);
		//NSLog(@" percent %i",count);
		float percent;
		//NSLog(@"here1");
		for(int i=0;i<count;i++)
		{
			percent = (float)(i+1)* _ringPercentIncrement;
			//NSLog(@"percent %f",percent);
			aCircle = [[GraphicCircleLabel alloc] initWithController:geometryController];
			[aCircle setPercentSetting:percent];
			[aCircle setLineWidth:_lineWeight];
			[aCircle setStrokeColor:_strokeColor];
			[aCircle setLabelAngle:_labelAngle];
			[aCircle setShowLabel:_showRingLabels];
			aCircle.labelFont = _ringFont;
            aCircle.isFixedCount = NO;
			[_graphicalObjects addObject:aCircle];
			
		}

		if([geometryController hollowCoreSize]>0.0)//core boundary
		{
			
			aCircle = nil;
			aCircle = [[GraphicCircleLabel alloc] initCoreCircleWithController:geometryController];
			
			[aCircle setPercentSetting:0.0];
			[aCircle setLineWidth:_lineWeight];
			
			[aCircle setStrokeColor:_strokeColor];
			
			[aCircle setLabelAngle:_labelAngle];
			[aCircle setShowLabel:_showRingLabels];
			aCircle.labelFont = _ringFont;
            aCircle.isFixedCount = NO;

			[_graphicalObjects addObject:aCircle];

		}
	}
	else
	{
		int max = [geometryController geometryMaxCount];
		int count = (int)((float)max/(float)_ringCountIncrement);
		int ringCount;
		for(int i=0;i<count;i++)
		{
			ringCount = ((i+1)*_ringCountIncrement);
			//NSLog(@"ring percent %i, i %i, %i max %i",ringCount,i,_ringCountIncrement,[geometryController geometryMaxCount]);
			aCircle = [[GraphicCircleLabel alloc] initWithController:geometryController];
			[aCircle setCountSetting:ringCount];
			[aCircle setLineWidth:_lineWeight];
			[aCircle setStrokeColor:_strokeColor];
			[aCircle setLabelAngle:_labelAngle];
			[aCircle setShowLabel:_showRingLabels];
			aCircle.labelFont = _ringFont;
            aCircle.isFixedCount = NO;
			[_graphicalObjects addObject:aCircle];
		}
		if([geometryController hollowCoreSize]>0.0)//core boundary
		{
			aCircle = [[GraphicCircleLabel alloc] initCoreCircleWithController:geometryController];
			[aCircle setPercentSetting:0.0];
			[aCircle setLineWidth:_lineWeight];
			[aCircle setStrokeColor:_strokeColor];
			[aCircle setLabelAngle:_labelAngle];
			[aCircle setShowLabel:_showRingLabels];
			aCircle.labelFont = _ringFont;
            aCircle.isFixedCount = NO;
			[_graphicalObjects addObject:aCircle];
		}
	}
	NS_HANDLER
		NSLog(@"[XRLayerGrid addVariableRings] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER
	
}

-(void)drawRect:(NSRect)rect
{
	//NSLog(@"will draw grid");
	//NS_DURING
	if(!_isVisible)
		return;
	//NSLog(@"drawing grid");
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	
	while(aGraphic = [anEnum nextObject])
	{
		if(([aGraphic isKindOfClass:[GraphicCircleLabel class]])&&(_ringsVisible))
		{
			
			[aGraphic drawRect:rect];
		}
		else if(([aGraphic isKindOfClass:[GraphicLine class]])&&(_spokesVisible))
		{
			
			[aGraphic drawRect:rect];
		}
	}
	//NSLog(@"******GRaphics count %i",[_graphicalObjects count]);
	/*NS_HANDLER
		NSLog(@"[XRLayerGrid addVariableRings] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER*/
}

-(BOOL)fixedCount
{
	return _fixedCount;
}

-(void)setFixedCount:(BOOL)isFixed
{
	if(_fixedCount != isFixed)
	{
	_fixedCount = isFixed;
	
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	}
}

-(BOOL)spokeSectorLock
{
	return _spokeSectorLock;
}

-(void)setSpokeSectorLock:(BOOL)sectorLock
{
	if(_spokeSectorLock != sectorLock)
	{
		_spokeSectorLock = sectorLock;
		[self generateGraphics];
		[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	}
}

-(BOOL)spokeSectorsEditable
{

	if(_spokeSectorLock)
		return NO;
	else
		return YES;
}

-(BOOL)allowEditFixedRing
{
	return _fixedCount;
}

-(BOOL)allowEditVariableRing
{
	return !_fixedCount;
}

-(void)geometryDidChangeSectors:(NSNotification *)notification
{
	
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)spokeAngleDidChange
{
	_spokeCount = (int)(360.0/_spokeAngle);
	[self setValue:[NSNumber numberWithInt:_spokeCount] forKey:@"_spokeCount"];
}

-(void)spokeCountDidChange
{
	_spokeAngle = 360.0/(float)_spokeCount;
	[self setValue:[NSNumber numberWithFloat:_spokeAngle] forKey:@"_spokeAngle"];
}


-(void)geometryDidChangePercent:(NSNotification *)notification
{
	[self generateGraphics];
	[self setValue:[NSNumber numberWithBool:[geometryController isPercent]] forKey:@"_isPercent"];
	[self setValue:[NSNumber numberWithBool:_fixedCount] forKey:@"_fixedCount"];

	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(BOOL)allowEditPercentRings
{

	return _isPercent;
}

-(BOOL)allowEditCountRings
{

	return !_isPercent;
}

-(void)setSpokeFont:(NSFont *)font
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	_spokeFont = font;
	while(aGraphic = [anEnum nextObject])
	{
		if([aGraphic isKindOfClass:[GraphicLine class]])
			[(GraphicLine *)aGraphic setFont:_spokeFont];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(NSFont *)spokeFont
{
	return _spokeFont;
}

-(void)setRingFont:(NSFont *)font
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	_ringFont = font;
	while(aGraphic = [anEnum nextObject])
	{
        if([aGraphic isKindOfClass:[GraphicCircleLabel class]]) {
            GraphicCircleLabel *graphic = (GraphicCircleLabel *)aGraphic;
            graphic.labelFont = _ringFont;
        }
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	
}
-(NSFont *)ringFont
{
	return _ringFont;
}

-(BOOL)showLabels {
    return _showRingLabels;
}

-(int)fixedRingCount {
    return _fixedRingCount;
}

-(BOOL)ringsVisible {
    return _ringsVisible;
}

-(int)ringCountIncrement {
    return _ringCountIncrement;
}

-(float)ringPercentIncrement {
    return _ringPercentIncrement;
}

-(float)ringLabelAngle {
    return _labelAngle;
}

-(NSString *)ringFontName {
    return [_ringFont fontName];
}

-(float)ringFontSize {
    return [_ringFont pointSize];
}

-(int)radialsCount {
    return _spokeCount;
}

-(float)radialsAngle {
    return _spokeAngle;
}

-(int)radialsLabelAlign {
    return _spokeNumberAlign;
}

-(int)radialsCompassPoint {
    return _spokeNumberCompassPoint;
}

-(int)radiansOrder {
    return _spokeNumberOrder;
}

-(NSString *)radianFontName {
    return [_spokeFont fontName];
}

-(float)radianFontSize {
    return [_spokeFont pointSize];
}

-(BOOL)radianSectorLock {
    return _spokeSectorLock;
}

-(BOOL)radianVisible {
    return _spokesVisible;
}

-(BOOL)radianIsPercent {
    return _isPercent;
}

-(BOOL)radianTicks {
    return _showTicks;
}

-(BOOL)radianMinorTicks {
    return _minorTicks;
}

-(BOOL)radianLabels {
    return _showLabels;
}

-(NSDictionary *)layerSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super layerSettings]];
	NSMutableDictionary *ringSettings = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *spokeSettings = [[NSMutableDictionary alloc] init];
	NSMutableArray *theGraphics  = [[NSMutableArray alloc] init];
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	//(@"layerSettings 1");
	//ring settings
	if(_fixedCount)
		[ringSettings setObject:@"YES" forKey:@"FixedCount"];
	else
		[ringSettings setObject:@"NO" forKey:@"FixedCount"];
	
	if(_ringsVisible)
		[ringSettings setObject:@"YES" forKey:@"RingsVisible"];
	else
		[ringSettings setObject:@"NO" forKey:@"RingsVisible"];
	
	[ringSettings setObject:[NSString stringWithFormat:@"%i",_fixedRingCount] forKey:@"FixedRingCount"];
	[ringSettings setObject:[NSString stringWithFormat:@"%i",_ringCountIncrement] forKey:@"RingCountIncrement"];
	[ringSettings setObject:[NSString stringWithFormat:@"%f",_ringPercentIncrement] forKey:@"ringPercentIncrement"];
	//NSLog(@"layerSettings 2");
	if(_showRingLabels)
		[ringSettings setObject:@"YES" forKey:@"RingLabelsOn"];
	else
		[ringSettings setObject:@"NO" forKey:@"RingLabelsOn"];
	
	[ringSettings setObject:[NSString stringWithFormat:@"%f",_labelAngle] forKey:@"_labelAngle"];
	
	[ringSettings setObject:_ringFont forKey:@"ringLabelFont"];

	////spoke settings
	[spokeSettings setObject:[NSString stringWithFormat:@"%i",_spokeCount] forKey:@"Spoke_Count"];
	[spokeSettings setObject:[NSString stringWithFormat:@"%f",_spokeAngle] forKey:@"Spoke_Angle"];
	if(_spokeSectorLock)
		[spokeSettings setObject:@"YES" forKey:@"_spokeSectorLock"];
	else
		[spokeSettings setObject:@"NO" forKey:@"_spokeSectorLock"];
	
	if(_spokesVisible)
		[spokeSettings setObject:@"YES" forKey:@"_spokesVisible"];
	else
		[spokeSettings setObject:@"NO" forKey:@"_spokesVisible"];
	
	if(_isPercent)
		[spokeSettings setObject:@"YES" forKey:@"_isPercent"];
	else
		[spokeSettings setObject:@"NO" forKey:@"_isPercent"];
	
	if(_showTicks)
		[spokeSettings setObject:@"YES" forKey:@"_showTicks"];
	else
		[spokeSettings setObject:@"NO" forKey:@"_showTicks"];
	
	if(_minorTicks)
		[spokeSettings setObject:@"YES" forKey:@"_minorTicks"];
	else
		[spokeSettings setObject:@"NO" forKey:@"_minorTicks"];
	
	if(_showLabels)
		[spokeSettings setObject:@"YES" forKey:@"_showLabels"];
	else
		[spokeSettings setObject:@"NO" forKey:@"_showLabels"];
	[spokeSettings setObject:[NSString stringWithFormat:@"%i",_spokeNumberAlign] forKey:@"_spokeNumberAlign"];
	[spokeSettings setObject:[NSString stringWithFormat:@"%i",_spokeNumberCompassPoint] forKey:@"_spokeNumberCompassPoint"];
	[spokeSettings setObject:[NSString stringWithFormat:@"%i",_spokeNumberOrder] forKey:@"_spokeNumberOrder"];
	
	[spokeSettings setObject:_spokeFont forKey:@"_spokeFont"];
	[theDict setObject:ringSettings forKey:@"ringSettings"];
	[theDict setObject:spokeSettings forKey:@"spokeSettings"];
	//NSLog(@"here 5");
	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addObject:[aGraphic graphicSettings]];
	}
	//NSLog(@"here 6");
	[theDict setObject:theGraphics forKey:XRLayerGraphicObjectArray];
	//NSLog(@"here 7");
	return [NSDictionary dictionaryWithDictionary:theDict];
}

+(NSString *)classTag
{
	return @"GRID";
}

-(NSString *)type
{
	return @"XRLayerGrid";
}

-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db   layerID:(int)layerID 
{
	if (!(self = [self initWithGeometryController:aController])) return nil;
	if(self)
	{
		[super configureWithSQL:db forLayerID:layerID];
		[self configureWithSQL:db forLayerID:layerID];
	}
	return self;
}

-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid
{
	int columns;
	//long long int  rowIDOfFill =-1;
	//long long int  rowIDOfStroke=-1;
	sqlite3_stmt *stmt;
	NSString *columnName = nil;
	NSString *ringFontName = nil;
	NSString *spokeFontName = nil;
	float ringFontSize = 12.0, spokeFontSize = 12.0;
	const char *pzTail;
	NSString *command = [NSString stringWithFormat:@"SELECT * FROM _layerGrid WHERE LAYERID=%i",layerid];
	//NSLog(@"Configuring with SQL");
	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		columns = sqlite3_column_count(stmt);
		for(int i=0;i<columns;i++)
		{
			columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
			if([columnName isEqualToString:@"RINGS_ISFIXEDCOUNT"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_fixedCount = YES;
				else
					_fixedCount = NO;
			}
			else if([columnName isEqualToString:@"RINGS_VISIBLE"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_ringsVisible = YES;
				else
					_ringsVisible = NO;
			}
			else if([columnName isEqualToString:@"RINGS_LABELS"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_showRingLabels = YES;
				else
					_showRingLabels = NO;
			}
				else if([columnName isEqualToString:@"RADIALS_SECTORLOCK"])
				{
					NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
					if([result isEqualToString:@"TRUE"])
						_spokeSectorLock = YES;
					else
						_spokeSectorLock = NO;
				}else if([columnName isEqualToString:@"RADIALS_VISIBLE"])
				{
					NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
					if([result isEqualToString:@"TRUE"])
						_spokesVisible = YES;
					else
						_spokesVisible = NO;
				}else if([columnName isEqualToString:@"RADIALS_ISPERCENT"])
				{
					NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
					if([result isEqualToString:@"TRUE"])
						_isPercent = YES;
					else
						_isPercent = NO;
				}
			else if([columnName isEqualToString:@"RADIALS_TICKS"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_showTicks = YES;
				else
					_showTicks = NO;
			}
			else if([columnName isEqualToString:@"RADIALS_MINORTICKS"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_minorTicks = YES;
				else
					_minorTicks = NO;
			}
			else if([columnName isEqualToString:@"RADIALS_LABELS"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_showLabels = YES;
				else
					_showLabels = NO;
			}
			else if([columnName isEqualToString:@"RINGS_FIXEDCOUNT"])
			{
				_fixedRingCount = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_COUNTINCREMENT"])
			{
				_ringCountIncrement = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"RADIALS_COUNT"])
			{
				_spokeCount = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"RADIALS_LABELALIGN"])
			{
				_spokeNumberAlign = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"RADIALS_COMPASSPOINT"])
			{
				_spokeNumberCompassPoint = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"RADIALS_ORDER"])
			{
				_spokeNumberOrder = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_PERCENTINCREMENT"])
			{
				_ringPercentIncrement = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_LABELANGLE"])
			{
				_labelAngle = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_LABELANGLE"])
			{
				_labelAngle = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_FONTSIZE"])
			{
				ringFontSize = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_FONTSIZE"])
			{
				ringFontSize = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RADIALS_ANGLE"])
			{
				_spokeAngle = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RADIALS_FONTSIZE"])
			{
				spokeFontSize = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"RINGS_FONTNAME"])
			{
				ringFontName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
			}
			else if([columnName isEqualToString:@"RADIALS_FONT"])
			{
				spokeFontName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
			}
			
					
			
			
		}
	}
	if(ringFontName)
		[self setRingFont:[NSFont fontWithName:ringFontName size:ringFontSize]];
	if(spokeFontName)
		[self setSpokeFont:[NSFont fontWithName:spokeFontName size:spokeFontSize]];
	
	[self generateGraphics];
}


@end

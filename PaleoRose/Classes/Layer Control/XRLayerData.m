//
//  XRLayerData.m
//  XRose
//
//  Created by Tom Moore on Sun Jan 25 2004.
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

#import "XRLayerData.h"
#import "XRDataSet.h"
#import "XRGeometryController.h"
#import "XRStatistic.h"
#import <PaleoRose-Swift.h>

@implementation XRLayerData
+(void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:XRLayerDataPlotTypePetal],

			nil] 
					  forKeys:[NSArray arrayWithObjects:XRLayerDataDefaultKeyType,
						  nil]];
	[defaults registerDefaults:appDefaults];
	
}
-(id)initWithGeometryController:(XRGeometryController *)aController withSet:(XRDataSet *)aSet
{
	if (!(self = [super initWithGeometryController:aController])) return nil;
	if(self)
	{
		_theSet = aSet; //note: not retained by this object
		if(_theSet)
			[self setLayerName:[aSet name]];
		_sectorValues = [[NSMutableArray alloc] init];
		_sectorValuesCount = [[NSMutableArray alloc] init];
		_statistics =  [[NSMutableArray alloc] init];
		_plotType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:XRLayerDataDefaultKeyType];
		[self calculateSectorValues];
		[self generateGraphics];
		_lineWeight = 1.0;
		_dotRadius = 4.0;
		
	}
	return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController  withSet:(XRDataSet *)aSet dictionary:(NSDictionary *)configure
{
	if (!(self = [super initWithGeometryController:aController dictionary:configure])) return nil;
	if(self)
	{
		NSArray *anArray;
		NSString *tempstring;

		
		
		_theSet = aSet; //note: not retained by this object
		//[self setLayerName:[aSet name]];
		_sectorValues = [[NSMutableArray alloc] init];
		_sectorValuesCount = [[NSMutableArray alloc] init];
		_statistics =  [[NSMutableArray alloc] init];
		
		if((tempstring = [configure objectForKey:@"Plot_Type"]))
			_plotType = [tempstring intValue];
		if((tempstring = [configure objectForKey:@"Total_Count"]))
			_totalCount = [tempstring intValue];
		if((tempstring = [configure objectForKey:@"Dot_Radius"]))
			_dotRadius = [tempstring floatValue];
		//[theDict setObject:[_theSet dataSetDictionary] forKey:@"Data_Set"];
		[self calculateSectorValues];
		[self generateGraphics];
		if((anArray = [configure objectForKey:XRLayerGraphicObjectArray]))
		{
			//NSLog(@"configure data graphics");
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
              plotType:(int)plotType
            totalCount:(int)totalCount
             dotRadius:(float)dotRadius
             datasetId:(int)datasetId {
    self = [super init];
    if (self) {
        _graphicalObjects = [[NSMutableArray alloc] init];
        _sectorValues = [[NSMutableArray alloc] init];
        _sectorValuesCount = [[NSMutableArray alloc] init];
        _statistics = [[NSMutableArray alloc] init];
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
        _plotType = plotType;
        _totalCount = totalCount;
        _dotRadius = dotRadius;
        _datasetId = datasetId;
        _canFill = YES;
        _canStroke = YES;
        // Generate the color preview image for the table view
        [self resetColorImage];
    }
    return self;
}

-(void)setPlotType:(int)newType
{
	_plotType = newType;
	[self calculateSectorValues];
	[self generateGraphics];
}

-(int)plotType
{
	return _plotType;
}

-(void)calculateSectorValues
{
	float angle1,angle2,sectorSize,startAngle;
	int sectorCount,aCount,maxCount,totalCount;
	//NSLog(@"calculate values");
	
	sectorSize = [geometryController sectorSize];
	startAngle = [geometryController startingAngle];
	//NSLog(@"size %f angle %f",sectorSize,startAngle);
	sectorCount = [geometryController sectorCount];
	//NSLog(@"count %f %f",(double)sectorCount,((double)360.0/(double)sectorSize));
	
	[_sectorValues removeAllObjects];
	[_sectorValuesCount removeAllObjects];
	maxCount = 0;
	totalCount = 0;
	//NSLog(@"count %i",sectorCount);
	if(!_theSet)
		return;
	for(int i = 0;i<sectorCount; i++)
	{
		angle1 = ((float)i * sectorSize) + startAngle;

		angle2 = angle1 + sectorSize;

		if(angle1 >= 360.0)
			angle1 = angle1- 360.0;
		if(angle2 >= 360.0)
			angle2 = angle2- 360.0;
		//NSLog(@"calculate values0.1");
		aCount = [_theSet valueCountFromAngle:angle1 toAngle2:angle2 biDir:_isBiDir];
		//NSLog(@"calculate values %i", aCount);
		if(aCount>maxCount)
			maxCount = aCount;
		totalCount += aCount;
		//NSLog(@"calculate values %i", totalCount);
		[_sectorValuesCount addObject:[NSNumber numberWithInt:aCount]];

		
	}
	//NSLog(@"calculate values1");
	_totalCount = totalCount;
	_maxCount = maxCount;
	_maxPercent = (float)maxCount/(float)totalCount;
	[_sectorValues removeAllObjects];
	if([geometryController isPercent])
	{
		NSNumber *aNumber;
		NSEnumerator *anEnum = [_sectorValuesCount objectEnumerator];
		while(aNumber = [anEnum nextObject])
		{
			
			[_sectorValues addObject:[NSNumber numberWithFloat:[aNumber floatValue]/(float)totalCount]];
		}
	}
	else
	{
		[_sectorValues addObjectsFromArray:_sectorValuesCount];
	}
	//NSLog(@"calculate values3");
	[self setStatisticsArray];
	//NSLog(@"Sector Count Array2: %@",[_sectorValues description]);
}


-(void)generateGraphics
{
	//NS_DURING
	float size = [geometryController sectorSize];
	float start = [geometryController startingAngle];
		[_graphicalObjects removeAllObjects];
	if(!_theSet)
		return;
	//NSLog(@"plotType = %i",_plotType);
	switch(_plotType)
	{
		case XRLayerDataPlotTypePetal:
		{
			GraphicPetal *petal;
			if([geometryController isPercent])
			{
				for(int i=0;i<[_sectorValues count];i++)
				{
					if([[_sectorValues objectAtIndex:i]doubleValue] != 0.0)
					{
						petal = [[GraphicPetal alloc] initWithController:geometryController forIncrement:i forValue:[_sectorValues objectAtIndex:i]];
						[_graphicalObjects addObject:petal];
						//NSLog([[_graphicalObjects lastObject] description]);
						
						[(Graphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
						[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
						[[_graphicalObjects lastObject] setFillColor:_fillColor];
					}
				}
			} else {
				for(int i=0;i<[_sectorValues count];i++)
				{
					if([[_sectorValues objectAtIndex:i]doubleValue] != 0.0)
					{
						petal = [[GraphicPetal alloc] initWithController:geometryController forIncrement:i forValue:[_sectorValuesCount objectAtIndex:i]];
						[_graphicalObjects addObject:petal];
						[(Graphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
						[(Graphic *)[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
						[(Graphic *)[_graphicalObjects lastObject] setFillColor:_fillColor];
					}
				}
			}


		}
			break;
		case XRLayerDataPlotTypeKite:
		{
			NSMutableArray *theAngles = [[NSMutableArray alloc] init];
			GraphicKite *aKite;
			int count;
			float angle;
			count = (int)[_sectorValues count];
			for(int i=0;i<count;i++)
			{
				angle = start + ((i + 0.5) * size);
				if(angle>=360.0)
					angle = 360.0 - angle;
				[theAngles addObject:[NSNumber numberWithFloat:angle]];
			}
			if([geometryController isPercent])
				aKite = [[GraphicKite alloc] initWithController:geometryController withAngles:[NSArray arrayWithArray:theAngles] forValues:_sectorValues];
			else
				aKite = [[GraphicKite alloc] initWithController:geometryController withAngles:[NSArray arrayWithArray:theAngles] forValues:_sectorValuesCount];
			[_graphicalObjects addObject:aKite];
			[(Graphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
			[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
			[[_graphicalObjects lastObject] setFillColor:_fillColor];
		}
			break;
		case XRLayerDataPlotTypeDot:
		{
			int count = (int)[_sectorValuesCount count];
			for(int i=0;i<count;i++)
			{
				if([[_sectorValuesCount objectAtIndex:i] intValue]>0)
				{
					[_graphicalObjects addObject:[[GraphicDot alloc] initWithController:geometryController forIncrement:i valueCount:[[_sectorValuesCount objectAtIndex:i] intValue] totalCount:_totalCount]];
					[(Graphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
					[[_graphicalObjects lastObject] setDotSize:_dotRadius];
					[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
					[[_graphicalObjects lastObject] setFillColor:_fillColor];
				}
			}

		}
			break;
		case XRLayerDataPlotTypeHistogram:
		{
			GraphicHistogram *hist;
			
			for(int i=0;i<[_sectorValues count];i++)
			{
				if([[_sectorValues objectAtIndex:i]doubleValue] != 0.0)
				{
					hist = [[GraphicHistogram alloc] initWithController:geometryController forIncrement:i forValue:[_sectorValues objectAtIndex:i]];
					[_graphicalObjects addObject:hist];
					[(Graphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
					[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
					[[_graphicalObjects lastObject] setFillColor:_fillColor];
				}
			}
			
		}
			break;
		case XRLayerDataPlotTypeDotDeviation:
		{
			NSDictionary *aDict = [_theSet meanCountWithIncrement:size startingAngle:start isBiDirectional:_isBiDir];
			GraphicDotDeviation *aGraphic;
			GraphicCircle *aCircle;
			int count = (int)[_sectorValuesCount count];

			for(int i=0;i<count;i++)
			{
				aGraphic = [[GraphicDotDeviation alloc] initWithController:geometryController forIncrement:i valueCount:[[_sectorValuesCount objectAtIndex:i] intValue] totalCount:_totalCount statistics:aDict];
				if(aGraphic)
				{
				[aGraphic setLineWidth:_lineWeight];
				[aGraphic setDotSize:_dotRadius];
				[aGraphic setStrokeColor:_strokeColor];
				[aGraphic setFillColor:_fillColor];
				[_graphicalObjects addObject:aGraphic];
				aGraphic = nil;
				}
			}
			//display mean circle
			float _mean = [[aDict objectForKey:@"mean"] floatValue];
			aCircle = [[GraphicCircle alloc] initWithController:geometryController];
			if([geometryController isPercent])
			{
				[aCircle setPercentSetting:(_mean/(float)_totalCount)];
			}
			else
			{
				[aCircle setCountSetting:(int)_mean];
			}
			[_graphicalObjects addObject:aCircle];
		}
			
			break;
		default:
			[_graphicalObjects removeAllObjects];
			break;
	}
	[self resetColorImage];
	//NSLog(@"posting notifications");
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
	//NSLog(@"done 1 posting notifications");
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	//NSLog(@"done 2 posting notifications");
	/*NS_HANDLER
		NSLog(@"generateGraphics error");
		NSLog(@"[XRLayerData generateGraphics] %@",[localException name]);
		[localException raise];
	NS_ENDHANDLER*/
}

-(void)drawRect:(NSRect)rect
{
	//NSLog(@"XRLayerData:drawRect");
	if(!_isVisible)
		return;
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	id  aGraphic;
	//NSLog(@"drawing graphic layer %i",[_graphicalObjects count]);
	while(aGraphic = [anEnum nextObject])
	{
		[aGraphic drawRect:rect];
	}
}

-(int)totalCount
{
	return _totalCount;
}

-(void)setDotRadius:(float)radius
{
	if(_dotRadius != radius)
	{
		_dotRadius = radius;
		if(([self plotType] == XRLayerDataPlotTypeDot)||([self plotType] == XRLayerDataPlotTypeDotDeviation))
		{
			[self generateGraphics];
		}
	}
}

-(float)dotRadius
{
	return _dotRadius;
}

-(int)datasetId {
    // Return the stored dataset ID if we don't have a dataset reference yet
    // Otherwise return the actual dataset's ID
    if (_theSet) {
        return _theSet.setId;
    }
    return _datasetId;
}


-(void)geometryDidChangeSectors:(NSNotification *)notification
{
	
	[self calculateSectorValues];
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)didChangeValueForKey:(NSString *)key
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
		
	if([key isEqualToString:@"_isBiDir"])
	{
		//NSLog(@"setting bidir");
		[self calculateSectorValues];
		[self generateGraphics];

	}
	
	if([key isEqualToString:@"_plotType"])
	{
		[self generateGraphics];
	}
	
	if([key isEqualToString:@"_layerName"])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
	}
	
	if([key isEqualToString:@"_strokeColor"])
	{
		
		[self resetColorImage];
		[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
		while(aGraphic = [anEnum nextObject])
		{
		
			[aGraphic setStrokeColor:_strokeColor];
			
		}
		
	}
	if([key isEqualToString:@"_fillColor"])
	{
		[self resetColorImage];
		[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
		while(aGraphic = [anEnum nextObject])
		{
			
			[aGraphic setFillColor:_fillColor];
		}
	}
	if([key isEqualToString:@"_lineWeight"])
	{
		//NSLog(@"lineWeight");
		while(aGraphic = [anEnum nextObject])
		{
			
			[aGraphic setLineWidth:_lineWeight];
			
		}
		
	}
	if(((_plotType==XRLayerDataPlotTypeDot)||(_plotType==XRLayerDataPlotTypeDotDeviation))&&([key isEqualToString:@"_dotRadius"]))
	{

		while(aGraphic = [anEnum nextObject])
		{
			if([aGraphic isKindOfClass:[GraphicDot class]])
				[(GraphicDot *)aGraphic setDotSize:_dotRadius];
			else if([aGraphic isKindOfClass:[GraphicDotDeviation class]])
				[(GraphicDotDeviation *)aGraphic setDotSize:_dotRadius];

			
		}
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];

}

-(void)setStatisticsArray
{
	if(_statistics)
		[_statistics removeAllObjects];
	else
		_statistics = [[NSMutableArray alloc] init];
	
	//[_statistics addObjectsFromArray:[_theSet calculateStatisticObjectsForBiDir:_isBiDir]];
	[_statistics addObjectsFromArray:[_theSet calculateStatisticObjectsForBiDir:_isBiDir startAngle:[geometryController startingAngle] sectorSize:[geometryController sectorSize]]];

	
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerDataStatisticsDidChange object:self];
	
}

-(NSMutableArray *)statisticsArray
{
	return _statistics;
}


-(NSDictionary *)layerSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super layerSettings]];
	NSMutableArray *theGraphics  = [[NSMutableArray alloc] init];
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	
	[theDict setObject:[_theSet dataSetDictionary] forKey:@"Data_Set"];

	[theDict setObject:[NSString stringWithFormat:@"%i",_plotType] forKey:@"Plot_Type"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_totalCount] forKey:@"Total_Count"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_dotRadius] forKey:@"Dot_Radius"];

	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addObject:[aGraphic graphicSettings]];
	}
	[theDict setObject:theGraphics forKey:XRLayerGraphicObjectArray];
	return [NSDictionary dictionaryWithDictionary:theDict];
}

-(XRDataSet *)dataSet
{
	return _theSet;
}

+(NSString *)classTag
{
	return @"DATA";
}

-(void)setDataSet:(XRDataSet *)aSet
{
	_theSet = aSet;
	[self calculateSectorValues];
	[self generateGraphics];
}

-(NSString *)type
{
	return @"XRLayerData";
}

@end

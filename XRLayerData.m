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
#import "XRGraphicKite.h"
#import "XRGraphicPetal.h"
#import "XRGraphicDot.h"
#import "XRGraphicHistogram.h"
#import "XRGraphicDotDeviation.h"
#import "XRStatistic.h"
#import "XRGraphic.h"
#import "XRGraphicCircle.h"
#import "sqlite3.h"
#import "LITMXMLTree.h"

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
			XRGraphicPetal *petal;
			if([geometryController isPercent])
			{
				for(int i=0;i<[_sectorValues count];i++)
				{
					if([[_sectorValues objectAtIndex:i]doubleValue] != 0.0)
					{
						petal = [[XRGraphicPetal alloc] initWithController:geometryController forIncrement:i forValue:[_sectorValues objectAtIndex:i]];
						[_graphicalObjects addObject:petal];
						//NSLog([[_graphicalObjects lastObject] description]);
						
						[(XRGraphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
						[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
						[[_graphicalObjects lastObject] setFillColor:_fillColor];
					}
				}
			} else {
				for(int i=0;i<[_sectorValues count];i++)
				{
					if([[_sectorValues objectAtIndex:i]doubleValue] != 0.0)
					{
						petal = [[XRGraphicPetal alloc] initWithController:geometryController forIncrement:i forValue:[_sectorValuesCount objectAtIndex:i]];
						[_graphicalObjects addObject:petal];
						[(XRGraphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
						[(XRGraphic *)[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
						[(XRGraphic *)[_graphicalObjects lastObject] setFillColor:_fillColor];
					}
				}
			}


		}
			break;
		case XRLayerDataPlotTypeKite:
		{
			NSMutableArray *theAngles = [[NSMutableArray alloc] init];
			XRGraphicKite *aKite;
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
				aKite = [[XRGraphicKite alloc] initWithController:geometryController withAngles:[NSArray arrayWithArray:theAngles] forValues:_sectorValues];
			else
				aKite = [[XRGraphicKite alloc] initWithController:geometryController withAngles:[NSArray arrayWithArray:theAngles] forValues:_sectorValuesCount];
			[_graphicalObjects addObject:aKite];
			[(XRGraphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
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
					[_graphicalObjects addObject:[[XRGraphicDot alloc] initWithController:geometryController forIncrement:i valueCount:[[_sectorValuesCount objectAtIndex:i] intValue] totalCount:_totalCount]];
					[(XRGraphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
					[[_graphicalObjects lastObject] setDotSize:_dotRadius];
					[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
					[[_graphicalObjects lastObject] setFillColor:_fillColor];
				}
			}

		}
			break;
		case XRLayerDataPlotTypeHistogram:
		{
			XRGraphicHistogram *hist;
			
			for(int i=0;i<[_sectorValues count];i++)
			{
				if([[_sectorValues objectAtIndex:i]doubleValue] != 0.0)
				{
					hist = [[XRGraphicHistogram alloc] initWithController:geometryController forIncrement:i forValue:[_sectorValues objectAtIndex:i]];
					[_graphicalObjects addObject:hist];
					[(XRGraphic *)[_graphicalObjects lastObject] setLineWidth:_lineWeight];
					[[_graphicalObjects lastObject] setStrokeColor:_strokeColor];
					[[_graphicalObjects lastObject] setFillColor:_fillColor];
				}
			}
			
		}
			break;
		case XRLayerDataPlotTypeDotDeviation:
		{
			NSDictionary *aDict = [_theSet meanCountWithIncrement:size startingAngle:start isBiDirectional:_isBiDir];
			XRGraphicDotDeviation *aGraphic;
			XRGraphicCircle *aCircle;
			int count = (int)[_sectorValuesCount count];

			for(int i=0;i<count;i++)
			{
				aGraphic = [[XRGraphicDotDeviation alloc] initWithController:geometryController forIncrement:i valueCount:[[_sectorValuesCount objectAtIndex:i] intValue] totalCount:_totalCount statistics:aDict];
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
			aCircle = [[XRGraphicCircle alloc] initWithController:geometryController];
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


-(void)geometryDidChangeSectors:(NSNotification *)notification
{
	
	[self calculateSectorValues];
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)didChangeValueForKey:(NSString *)key
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	XRGraphic *aGraphic;
		
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
			if([aGraphic isKindOfClass:[XRGraphicDot class]])
				[(XRGraphicDot *)aGraphic setDotSize:_dotRadius];
			else if([aGraphic isKindOfClass:[XRGraphicDotDeviation class]])
				[(XRGraphicDotDeviation *)aGraphic setDotSize:_dotRadius];

			
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
	//if(_statistics)
	//	NSLog(@"stats is live %i",[_statistics count]);
	return _statistics;
}


-(NSDictionary *)layerSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super layerSettings]];
	NSMutableArray *theGraphics  = [[NSMutableArray alloc] init];
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	XRGraphic *aGraphic;
	
	[theDict setObject:[_theSet dataSetDictionary] forKey:@"Data_Set"];

	[theDict setObject:[NSString stringWithFormat:@"%i",_plotType] forKey:@"Plot_Type"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_totalCount] forKey:@"Total_Count"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_dotRadius] forKey:@"Dot_Radius"];

	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addObject:[aGraphic graphicSettings]];
	}
	[theDict setObject:theGraphics forKey:XRLayerGraphicObjectArray];
	//NSLog(@"end data layer");
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


-(LITMXMLTree *)xmlTreeForVersion:(NSString *)version
{
	NSString *currentVersion = @"1.0";
	if((version == nil)||([currentVersion isEqualToString:version]))
		return [self xmlTreeForVersion1_0];
	return nil;
}

-(LITMXMLTree *)xmlTreeForVersion1_0
{
	LITMXMLTree *rootTree = [self baseXMLTreeForVersion:@"1.0"];
	
	[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"PARENTDATA" attributes:nil attributeOrder:nil contents:[_theSet name]]];
	[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"PLOTTYPE" attributes:nil attributeOrder:nil contents:[NSString stringWithFormat:@"%i",_plotType]]];
	[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"TOTALCOUNT" attributes:nil attributeOrder:nil contents:[NSString stringWithFormat:@"%i",_totalCount]]];
	[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"DOTRADIUS" attributes:nil attributeOrder:nil contents:[NSString stringWithFormat:@"%f",_dotRadius]]];
	
	return rootTree;
}

-(id)initWithGeometryController:(XRGeometryController *)aController xmlTree:(LITMXMLTree *)configureTree forVersion:(NSString *)version
{
	if (!(self = [self initWithGeometryController:aController withSet:nil])) return nil;
	if(self)
	{
		
		[self configureBaseWithXMLTree:configureTree version:version];
		[self configureWithXMLTree:configureTree version:version];
		[self generateGraphics];
		return self;
	}
	return nil;
}

-(void)configureWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version
{
	NSString *currentVersion = @"1.0";
	if((version == nil)||([currentVersion isEqualToString:version]))
	{
		[self configureBaseWithXMLTree1_0:configureTree];
		[self configureWithXMLTree1_0:configureTree];
		
	}
	return;
}

-(void)configureWithXMLTree1_0:(LITMXMLTree *)configureTree
{

	NSString *content;
	if((content = [[configureTree findXMLTreeElement:@"PLOTTYPE"] contentsString]))
		_plotType = [content intValue];
	if((content = [[configureTree findXMLTreeElement:@"TOTALCOUNT"] contentsString]))
		_totalCount = [content intValue];
	if((content = [[configureTree findXMLTreeElement:@"DOTRADIUS"] contentsString]))
		_dotRadius = [content floatValue];

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

-(void)saveToSQLDB:(sqlite3 *)db layerID:(int)layerID
{
	NSMutableString *command = [[NSMutableString alloc] init];
	long long datasetID;
	int error;
	char *errorMsg;
	[super saveToSQLDB:db layerID:layerID];
	datasetID = (long long)[self findDatasetIDByName:[_theSet name] inSQLDB:db];
	//NSLog(@"dataset2: %i %@ %i",(int)datasetID,[_theSet name],(int)[self findDatasetIDByName:[_theSet name] inSQLDB:db]);
	
	[command appendString:@"INSERT INTO _layerData (LAYERID,DATASET,PLOTTYPE,TOTALCOUNT,DOTRADIUS) "];
	[command appendFormat:@"VALUES (%i,%i,%i,%i,%f) ",layerID,(int)datasetID,_plotType,_totalCount,_dotRadius];
	error = sqlite3_exec(db,[command UTF8String],nil,nil,&errorMsg);
	if(error!=SQLITE_OK)
		NSLog(@"error: %s",errorMsg);
	
    if(_theSet) {
        [_theSet saveToSQLDB:db];
    }
	
}

-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db   layerID:(int)layerID 
{
	if (!(self = [self initWithGeometryController:aController])) return nil;
	if(self)
	{
		_sectorValues = [[NSMutableArray alloc] init];
		_sectorValuesCount = [[NSMutableArray alloc] init];
		_statistics =  [[NSMutableArray alloc] init];
		_plotType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:XRLayerDataDefaultKeyType];
		
		_lineWeight = 1.0;
		_dotRadius = 4.0;
		[super configureWithSQL:db forLayerID:layerID];
		[self configureWithSQL:db forLayerID:layerID];
		[self calculateSectorValues];
		[self generateGraphics];
	}
	return self;
}

-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid
{
	int columns;

	sqlite3_stmt *stmt;
	NSString *columnName;

	const char *pzTail;
	NSString *command = [NSString stringWithFormat:@"SELECT * FROM _layerData WHERE LAYERID=%i",layerid];

	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		columns = sqlite3_column_count(stmt);
		for(int i=0;i<columns;i++)
		{
			columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
			//NSLog(columnName);
			if([columnName isEqualToString:@"PLOTTYPE"])
				_plotType = (int)sqlite3_column_int(stmt,i);
			else if([columnName isEqualToString:@"TOTALCOUNT"])
				_totalCount = (int)sqlite3_column_int(stmt,i);
			else if([columnName isEqualToString:@"DOTRADIUS"])
				_dotRadius = (float)sqlite3_column_double(stmt,i);
			/* note: data set information not loaded here.  It is loaded by the tablecontroller when using dataset name method below*/
			
		}
	}
	sqlite3_finalize(stmt);
	
}


-(NSString *)getDatasetNameWithLayerID:(int)layerID fromDB:(sqlite3 *)db
{
	int columns;
	
	sqlite3_stmt *stmt;
	NSString *columnName;
	NSString *datasetName;
	
	const char *pzTail;
	NSString *command = [NSString stringWithFormat:@"SELECT NAME FROM _datasets where _datasets._id = %i;",layerID];
	//NSLog(@"Configuring with SQL");
	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		columns = sqlite3_column_count(stmt);
		for(int i=0;i<columns;i++)
		{
			columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
			//NSLog(columnName);
			if([columnName isEqualToString:@"NAME"])
				datasetName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
			
			/* note: data set information not loaded here.  It is loaded by the tablecontroller when using dataset name method below*/
			
		}
	}
	sqlite3_finalize(stmt);
	
	return datasetName;
}


@end

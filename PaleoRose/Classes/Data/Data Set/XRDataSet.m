//
//  XRDataSet.m
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

#import "XRDataSet.h"
#import <math.h>
#import "XRStatistic.h"
#import "sqlite3.h"
#import "LITMXMLBinaryEncoding.h"

@implementation XRDataSet

#pragma mark Initers

-(id)initWithTable:(NSString *)table column:(NSString *)column db:(sqlite3 *)db
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		predicate = nil;
		tableName = table;
		columnName = column;
		_theValues = [[NSMutableData alloc] init];
        if([self readSQL:db])
			return self;
		else
			return nil;
	}
	return self;
}

-(id)initWithTable:(NSString *)table column:(NSString *)column db:(sqlite3 *)db predicate:(NSString *)aPredicate;
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		predicate = nil;
		tableName = table;
		columnName = column;
	
		predicate = aPredicate;
		_theValues = [[NSMutableData alloc] init];
        if([self readSQL:db])
			return self;
		else
			return nil;
		
	}
	return self;
}

-(id)initWithData:(NSData *)data withName:(NSString *)name
{
    if (!(self = [super init])) return nil;
    if(self)
    {
        _theValues = [[NSMutableData alloc] init];
        _name = name;
        [_theValues appendData:data];
    }
    return self;
}

-(id)initWithId:(int)setId name:(NSString *)name tableName:(NSString *)table column:(NSString *)column predicate:(NSString *)aPredicate comments:(NSAttributedString *)comments data:(NSData *)data {
    if (!(self = [super init])) return nil;
    if(self)
    {
        _theValues = [[NSMutableData alloc] init];
        _name = name;
        _setId = setId;
        tableName = table;
        columnName = column;
        predicate = aPredicate;
        _comments = [[NSMutableAttributedString alloc] initWithAttributedString:comments];

        [_theValues appendData:data];
    }
    return self;
}

#pragma mark Accessors

-(NSData *)theData
{
	return [NSData dataWithData:_theValues];
}

-(NSString *)name
{
    return _name;
}

-(int)setId {
    return _setId;
}

-(void)setId:(int)newId {
    _setId = newId;
}

-(void)setName:(NSString *)name;
{
    _name = name;
}

-(void)setComments:(NSMutableAttributedString *)aString
{
    _comments = aString;
}

-(NSAttributedString *)comments
{
    return _comments;
}

-(void)setPredicate:(NSString *)newPred
{
    predicate = nil;
    predicate = newPred;
}

-(NSString *)predicate
{
    return predicate;
}
-(void)setTableName:(NSString *)newTable
{
    tableName = nil;
    tableName = newTable;
}
-(NSString *)tableName
{
    return tableName;
}

-(void)setColumnName:(NSString *)newColumn
{
    columnName = nil;
    columnName = newColumn;
}

-(NSString *)columnName
{
    return columnName;
}

-(NSDictionary *)dataSetDictionary
{
    NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
    //NSLog(@"creating dataSetDictionary");
    [theDict setObject:_theValues forKey:@"values"];
    //NSLog(@"1");
    [theDict setObject:_name forKey:@"name"];
    //NSLog(@"2");
    if(_comments)
        [theDict setObject:_comments forKey:@"comments"];

    return [NSDictionary dictionaryWithDictionary:theDict];
}

#pragma mark Statistics

-(NSArray *)currentStatistics
{
    return _circularStatistics;
}

-(XRStatistic *)currentStatisticWithName:(NSString *)name
{
    NSEnumerator *anEnum =  [_circularStatistics objectEnumerator];
    XRStatistic *aStat;
    while(aStat = [anEnum nextObject])
    {
        if([aStat.statisticName isEqualToString:name])
        {
            return aStat;
        }
    }
    return nil;
}

-(int)valueCountFromAngle:(float)angle1 toAngle2:(float)angle2
{
	float aValue;
	//NSLog(@"valueCountFromAngle1");
	float *valueArray = (float *)malloc([_theValues length]);
	int count;
	//NSLog(@"valueCountFromAngle2");
	int values = (int)([_theValues length]/sizeof(float));
    [_theValues getBytes:valueArray length:[_theValues length]];
	count = 0;

	for(int i=0;i<values;i++)
	{
		aValue = valueArray[i];
		if(angle1<angle2)
		{
			if((angle1<=aValue)&&(aValue<angle2))
				count++;
		}
		else
		{
			if((aValue>=angle1)||(aValue<angle2))
			{
				count++;
			}
		}
	}

	free(valueArray);
	return count;
}

-(int)valueCountFromAngle:(float)angle1 toAngle2:(float)angle2 biDir:(BOOL)biDir
{
	int count = [self valueCountFromAngle:angle1 toAngle2:angle2];
	float angle3, angle4;
	if(biDir)
	{
		angle3 = angle1 + 180.0;
		if(angle3 > 360.0)
			angle3 -= 360.0;
		angle4 = angle2 + 180.0;
		if(angle4 > 360.0)
			angle4 -= 360.0;
		count += [self valueCountFromAngle:angle3 toAngle2:angle4];
	}

	return count;
}

-(NSDictionary *)meanCountWithIncrement:(float)angleIncrement startingAngle:(float)startAngle isBiDirectional:(BOOL)isBiDir
{
	int total;
	int result;
	float angle1;
	float angle2;
	float mean;
	float sd;
	int totalIncrements = (int)(360.0/angleIncrement);
	NSMutableArray *anArray = [[NSMutableArray alloc] init];
	total = 0;
	for(int i=0;i<totalIncrements;i++)
	{
		angle1 = (i * angleIncrement) + startAngle;
		angle2 = angle1 + angleIncrement;
		if(angle1>360.0)
			angle1 = angle1 - 360.0;
		if(angle2>360.0)
			angle2 = angle2 - 360.0;
		result = [self valueCountFromAngle:angle1 toAngle2:angle2 biDir:isBiDir];
		total += result;
		[anArray addObject:[NSNumber numberWithInt:result]];
	}
	mean = (float)total / (float)totalIncrements;
	sd = [self standardDeviation:anArray mean:(float)mean];

	return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:mean],[NSNumber numberWithFloat:sd],nil]
									   forKeys:[NSArray arrayWithObjects:@"mean",@"sd",nil]];
}

//use only for the above method.  Not valid 
-(float)standardDeviation:(NSArray *)anArray mean:(float)mean
{
	int count = (int)[anArray count];
	float value;
	NSEnumerator *anEnum = [anArray objectEnumerator];
	NSNumber *aNum;
	value = 0;
	while(aNum = [anEnum nextObject])
	{
		value *= ([aNum floatValue] - mean)*([aNum floatValue] - mean);
	}
	value = sqrt(value / (float)(count - 1));
	return value;
}

//grid dependent statistics
-(NSArray *)calculateStatisticObjectsForBiDir:(BOOL)isBiDir startAngle:(float)startAngle sectorSize:(float)sectorSize
{
	[self calculateStatisticObjectsForBiDir:isBiDir];
	[_circularStatistics addObject:[self chiSquaredWithStartAngle:startAngle sectorSize:sectorSize isBiDir:isBiDir]];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRDataSetChangedStatisticsNotification object:self];
	return _circularStatistics;
}
//grid independent statistics

-(NSArray *)calculateStatisticObjectsForBiDir:(BOOL)isBiDir
{
	
	XRStatistic *aStat;
	if(_circularStatistics)
		[_circularStatistics removeAllObjects];
	else
		_circularStatistics = [[NSMutableArray alloc] init];
	
	//XRStatistic *aStat;
	//General Statistics
	//count
	aStat = [XRStatistic statisticWithName:@"N" withIntValue:(int)[_theValues length]/4];
	[_circularStatistics addObject:aStat];
	//bidir count
	if(isBiDir)
	{
	aStat = [XRStatistic statisticWithName:@"N (Bi-Dir)" withIntValue:(int)[_theValues length]/2];
	[_circularStatistics addObject:aStat];
	}
	//unidirectional stats
	//aStat = [XRStatistic emptyStatisticWithName:@"Unidirectional Statistics"];
	//[_circularStatistics addObject:aStat];
	[self calculateNonSectorStatisticsForBiDirection:isBiDir];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRDataSetChangedStatisticsNotification object:self];
	return _circularStatistics;
}

-(void)calculateNonSectorStatisticsForBiDirection:(BOOL)isBiDir
{
	float sumXVector,sumXVectorCBar;
	float sumYVector,sumYVectorSBar;
	float meanDir;
	int rbarPosition;
	int kappaPosition;
	int standErrorPosition;
	int calculationType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vectorCalculationMethod"] intValue];
	//this section is affected by the calculation approach 
	[self computeXVector:isBiDir];
	sumXVector = [[_circularStatistics objectAtIndex:[_circularStatistics count]-2] floatValue];
	sumXVectorCBar = [[_circularStatistics objectAtIndex:[_circularStatistics count]-1] floatValue];
	[self computeYVector:isBiDir];
	sumYVector = [[_circularStatistics objectAtIndex:[_circularStatistics count]-2] floatValue];
	sumYVectorSBar = [[_circularStatistics objectAtIndex:[_circularStatistics count]-1] floatValue];

	meanDir = (float)[self degreesFromRadians:atan2((double)sumYVector,(double)sumXVector)];
	//NSLog(@"%f %f %f %f %f",sumXVector, sumXVectorCBar, sumYVector, sumYVectorSBar,meanDir);
	if(meanDir < 0.0)
		meanDir += 360.0;
	if(calculationType==0)
		meanDir = meanDir/2.0;
	//end calculation approach
	
	[_circularStatistics addObject:[XRStatistic statisticWithName:[NSString stringWithUTF8String:"θ̅"] withFloatValue:meanDir]];
	[[_circularStatistics lastObject] setASCIIName:@"Mean Direction"];
	//@"Resultant Length (R)"
	[_circularStatistics addObject:[XRStatistic statisticWithName:[NSString stringWithUTF8String:"R"] withFloatValue:sqrt((sumXVector*sumXVector)+(sumYVector*sumYVector))]];
	[[_circularStatistics lastObject] setASCIIName:@"Resultant Length (R)"];
	//@"Mean Resultant Length (R-Bar)" 
	[_circularStatistics addObject:[XRStatistic statisticWithName:@"Circular Varience" withFloatValue:(1.0-sqrt((sumXVectorCBar*sumXVectorCBar)+(sumYVectorSBar*sumYVectorSBar)))]];
	[_circularStatistics addObject:[XRStatistic statisticWithName:[NSString stringWithUTF8String:"R̅"] withFloatValue:sqrt((sumXVectorCBar*sumXVectorCBar)+(sumYVectorSBar*sumYVectorSBar))]];
	[[_circularStatistics lastObject] setASCIIName:@"Mean Resultant Length (R-Bar)"];
	rbarPosition = (int)[_circularStatistics count] - 1;
	[_circularStatistics addObject:[self calculateRayleighForRBar:[_circularStatistics objectAtIndex:rbarPosition]]];
	[_circularStatistics addObject:[self calculateKappaForRBar:[_circularStatistics objectAtIndex:rbarPosition]]];
	kappaPosition = (int)[_circularStatistics count] - 1;
	[_circularStatistics addObject:[self calculateStandardErrorWithN:(int)[_theValues length]/4 rbar:[_circularStatistics objectAtIndex:rbarPosition] kappa:[_circularStatistics objectAtIndex:kappaPosition]]];
	standErrorPosition = (int)[_circularStatistics count] -1;
	[_circularStatistics addObject:[self calculateAngleIntervalWithStandardError:[_circularStatistics objectAtIndex:standErrorPosition]]];
}

-(void)computeXVector:(BOOL)isBiDir
{
	float *values = (float *)malloc([_theValues length]);
	float _sumXVector;
	float _sumXVectorCBar;
	float inversevalue = 0.0;
	int calculationType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vectorCalculationMethod"] intValue];
	int count = (int)[_theValues length]/sizeof(float);
	_sumXVector = 0.0;
    [_theValues getBytes:values length:[_theValues length]];
	if(calculationType == 1)
	{
		for(int i=0;i<count;i++)
		{
			_sumXVector += cos([self radiansFromDegrees:values[i]]);
		}
		if(isBiDir)
		{
			for(int i=0;i<count;i++)
			{
				float tempValue = values[i] + 180.0;
				if(tempValue > 180)
					tempValue -= 360.0;
				_sumXVector += cos([self radiansFromDegrees:tempValue]);
			}
		}
		if(isBiDir)
			_sumXVectorCBar = _sumXVector / count * 2;
		else
			_sumXVectorCBar = _sumXVector / count;
	}
	else
	{
		for(int i=0;i<count;i++)
		{
			inversevalue = values[i] * 2;
			while(inversevalue > 360.0)
				inversevalue = inversevalue - 360.0;
			_sumXVector += cos([self radiansFromDegrees:inversevalue]);
		}
		if(isBiDir)
		{
			for(int i=0;i<count;i++)
			{
				inversevalue = (values[i] + 180);
				if(inversevalue>360)
					inversevalue -= 360.0;
				inversevalue = inversevalue * 2;
				while(inversevalue > 360.0)
					inversevalue = inversevalue - 360.0;
				_sumXVector += cos([self radiansFromDegrees:inversevalue]);
			}
		}
		if(isBiDir)
			_sumXVectorCBar = _sumXVector /( count * 2);
		else
			_sumXVectorCBar = _sumXVector /( count);
	}
	[_circularStatistics addObject:[XRStatistic statisticWithName:@"X Vector" withFloatValue:_sumXVector]];
	[_circularStatistics addObject:[XRStatistic statisticWithName:[NSString stringWithUTF8String:"C̅"] withFloatValue:_sumXVectorCBar]];
	[[_circularStatistics lastObject] setASCIIName:@"Standarized X Vector"];
	free(values);
	return;
}

-(void)computeYVector:(BOOL)isBiDir
{
	float *values = (float *)malloc([_theValues length]);
	float _sumYVector,_sumYVectorSBar;
	float inversevalue;
	int count = (int)[_theValues length]/sizeof(float);
	int calculationType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vectorCalculationMethod"] intValue];
	_sumYVector = 0.0;
    [_theValues getBytes:values length: [_theValues length]];
	if(calculationType == 1)
	{
		for(int i=0;i<count;i++)
		{
			_sumYVector += sin([self radiansFromDegrees:values[i]]);
		}
		if(isBiDir)
		{
			for(int i=0;i<count;i++)
			{
				float tempValue = values[i] + 180.0;
				if(tempValue > 180)
					tempValue -= 360.0;
				_sumYVector += sin([self radiansFromDegrees:tempValue]);
			}
		}
		if(isBiDir)
			_sumYVectorSBar = _sumYVector / count * 2;
		else
			_sumYVectorSBar = _sumYVector / count;
	}
	else
	{
		for(int i=0;i<count;i++)
		{
			inversevalue = values[i] * 2;
			while(inversevalue > 360.0)
				inversevalue = inversevalue - 360.0;
			_sumYVector += sin([self radiansFromDegrees:inversevalue]);
		}
		if(isBiDir)
		{
			for(int i=0;i<count;i++)
			{
				inversevalue = (values[i] + 180);
				if(inversevalue>360)
					inversevalue -= 360.0;
				inversevalue = inversevalue * 2;
				while(inversevalue > 360.0)
					inversevalue = inversevalue - 360.0;
				_sumYVector += sin([self radiansFromDegrees:inversevalue]);
			}
		}
		if(isBiDir)
			_sumYVectorSBar = _sumYVector /( count * 2);
		else
			_sumYVectorSBar = _sumYVector /( count);
	}
	[_circularStatistics addObject:[XRStatistic statisticWithName:@"Y Vector" withFloatValue:_sumYVector]];
	[_circularStatistics addObject:[XRStatistic statisticWithName:[NSString stringWithUTF8String:"S̅"] withFloatValue:_sumYVectorSBar]];
	[[_circularStatistics lastObject] setASCIIName:@"Standarized Y Vector"];
	free(values);
	return;
}

-(XRStatistic *)calculateRayleighForRBar:(XRStatistic *)rbar
{
	int count;
	float rbarValue = [rbar floatValue];
	float stat;
	float scalerfactor;
	XRStatistic *result;
	float calresult;
	count = (int)[_theValues length]/4;
	stat = count * rbarValue * rbarValue;
	scalerfactor = 1 + (2 * stat - stat*stat)/(4*count) -  (24 * stat - 132 * stat* stat + 76 * stat* stat* stat - 9 * stat* stat* stat* stat) / (288 * count* count);
	calresult = exp(-stat)*scalerfactor;
	//NSLog(@"rayleigh: %i %f %f %f %f",count,stat,scalerfactor,calresult,rbarValue);
	result = [XRStatistic statisticWithName:@"Rayleigh Probability" withFloatValue:calresult];
	
	return result;
}

-(XRStatistic *)calculateKappaForRBar:(XRStatistic *)rbar
{
	float result;
	XRStatistic *theStat;
	if([rbar floatValue]<.53)
		result =  (2 * [rbar floatValue]) + ([rbar floatValue]*[rbar floatValue]*[rbar floatValue]) + (5 * [rbar floatValue]*[rbar floatValue]*[rbar floatValue]*[rbar floatValue]*[rbar floatValue])/6;
	else if([rbar floatValue]<.85)
		result =  -0.4 + 1.39 * [rbar floatValue] + 0.43/(1 - [rbar floatValue]);
	else
		result = 1/(([rbar floatValue]*[rbar floatValue]*[rbar floatValue]) - 4 * ([rbar floatValue]*[rbar floatValue]) + 3 * [rbar floatValue]);
	theStat = [XRStatistic statisticWithName:[NSString stringWithUTF8String:"κ (est)"] withFloatValue:result];
	[theStat setASCIIName:@"Concentration Parameter (Kappa): Estimated"];
	return theStat;
}

-(XRStatistic *)calculateStandardErrorWithN:(int)n rbar:(XRStatistic *)rbar kappa:(XRStatistic *)kappa
{
	float result = 1/sqrt(((float)n * [rbar floatValue] * [kappa floatValue]));
	XRStatistic *theStat;
	//NSLog(@"n: %i, rbar %f, kappa %f, result %f, degrees %f",n, [rbar floatValue], [kappa floatValue],result,[self degreesFromRadians:result]);
	
	theStat =  [XRStatistic statisticWithName:@"Se" withFloatValue:[self degreesFromRadians:result]];
	[theStat setASCIIName:@"Standard Error Of Mean Direction (Se)"];
	return theStat;
}

-(XRStatistic *)calculateAngleIntervalWithStandardError:(XRStatistic *)error
{
	XRStatistic *theStat =  [XRStatistic statisticWithName:[NSString stringWithUTF8String:"θ̅± (95%)"] withFloatValue:([error floatValue] * 1.64)];
	[theStat setASCIIName:@"95% Confidence Interval"];
	return theStat;
}

-(double)radiansFromDegrees:(double)degrees
{
	double pi = 3.14159265358989323846;
	double result = pi/ 180.0 * degrees;
	return result;
}

-(double)degreesFromRadians:(double)radians
{
	double pi = 3.14159265358989323846;
	double result = 180.0 * radians / pi;
	return result;
}

-(XRStatistic *)chiSquaredWithStartAngle:(float)startAngle sectorSize:(float)sectorSize isBiDir:(BOOL)isBiDir
{
	int sectorCount = 360.0/sectorSize;
	float angle;
	float expectedFreq;
	XRStatistic *theStat;
	int *countArray = (int *)malloc(sizeof(int)*sectorCount);
	int totalCount = 0;
	for(int i=0;i<sectorCount;i++)
	{
		angle = (startAngle + (i*sectorSize));
		countArray[i] = [self valueCountFromAngle:angle toAngle2:(angle + sectorSize) biDir:isBiDir];
		totalCount += countArray[i];
	}
	expectedFreq = (float)totalCount/(float)sectorCount;
	[self standardDeviationForIntArray:countArray count:sectorCount expected:expectedFreq];
	theStat = [XRStatistic emptyStatisticWithName:[NSString stringWithUTF8String:"χ2"]];
	if(expectedFreq <+ 5.0)
		 [theStat setValueString:@"Expected Frequency Too Low: must be >=5 per sector" ];
	else
		[theStat setValueString:[NSString stringWithFormat:@"%f: df = ",(double)(sectorCount-1)]];
	[theStat setASCIIName:@"Chi-Squared"];
    free(countArray);
	return theStat;
	
}

-(float)standardDeviationForIntArray:(int *)array count:(int)count expected:(float)expected
{
	float s = 0.0;
	
	for(int i=0;i<count;i++)
		s = (((float)array[i] - expected)*((float)array[i] - expected))/expected;
	return s;
	
}

-(NSString *)statisticsDescription
{
	NSEnumerator *anEnum = [_circularStatistics objectEnumerator];
	XRStatistic *aStat;
	NSMutableString *theString = [[NSMutableString alloc] init];
	
	
	while(aStat = [anEnum nextObject])
	{
		if([[aStat ASCIINameString] isEqualToString:@"N (Bi-Dir)"])
			[theString appendString:@"Data is treated as bi-directional\n"];
		else
			[theString appendFormat:@"%@ = \t\t%@\n",[aStat ASCIINameString],[aStat valueString]];
		
	}
	return theString;
}

#pragma mark SQL

-(NSString *)buildSQL
{
	NSMutableString *aSql = [[NSMutableString alloc] init];
	[aSql appendFormat:@"SELECT \"%@\" FROM \"%@\" WHERE \"%@\" >= 0 AND \"%@\" <=360",columnName,tableName,columnName,columnName];
	if(predicate)
		[aSql appendFormat:@" AND %@", predicate];
	//NSLog(aSql);
	return aSql;
}

-(NSString *)buildCountSQL
{
	//NSLog(@"1");
	NSMutableString *aSql = [[NSMutableString alloc] init];
	//NSLog(@"2");
	[aSql appendFormat:@"SELECT COUNT(\"%@\") FROM \"%@\" WHERE \"%@\">=0 AND \"%@\"<=360",columnName,tableName,columnName,columnName];
	//NSLog(@"3");
	if(predicate)
		[aSql appendFormat:@" AND %@", predicate];
	//NSLog(aSql);
	return aSql;
}

-(BOOL)readSQL:(sqlite3 *)db
{
	NSString *theSQL = [self buildSQL];
	NSString *theCountSQL = [self buildCountSQL];

	sqlite3_stmt *stmt;
	const char *pzTail;
	int count = 0, index;
	float *data;
	float aValue;
    int error;

	error = sqlite3_prepare(db,[theCountSQL UTF8String],-1,&stmt,&pzTail);
	if(error!=SQLITE_OK)
	{
		return NO;
	}
	while(sqlite3_step(stmt)!=SQLITE_DONE)
	{
		count = sqlite3_column_int(stmt,0);
	}
    if (count > 0) {
        data = (float *)malloc(sizeof(float)*count);
        
        sqlite3_prepare(db,[theSQL UTF8String],-1,&stmt,&pzTail);
        
        index = -1;
        
        while(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            index++;
            aValue = (float)sqlite3_column_double(stmt,0);
            data[index] = aValue;
        }
        _theValues = nil;
        _theValues = [[NSMutableData alloc] init];
        [_theValues appendBytes:data length:(sizeof(float)*count)];
        free(data);
    }

	return YES;
}

// private
-(BOOL)readSQLFromDB:(sqlite3 *)db
{
	NSString *theSQL = [self buildSQL];
	NSString *theCountSQL = [self buildCountSQL];
	
	sqlite3_stmt *stmt;
	const char *pzTail;
	int error;
	int count = 0, index;
	float *data;
	float aValue;

	error = sqlite3_prepare(db,[theCountSQL UTF8String],-1,&stmt,&pzTail);
	if(error!=SQLITE_OK)
	{
		NSLog(@"error %i is SQL: %@\nError: %s",error,theCountSQL,sqlite3_errmsg(db));
		return NO;
	}
	while(sqlite3_step(stmt)!=SQLITE_DONE)
	{
		count = sqlite3_column_int(stmt,0);
	}
    if (count > 0) {
	data = (float *)malloc(sizeof(float)*count);

    sqlite3_prepare(db,[theSQL UTF8String],-1,&stmt,&pzTail);

	index = -1;

	while(sqlite3_step(stmt)!=SQLITE_DONE)
	{
		index++;
		aValue = (float)sqlite3_column_double(stmt,0);
		data[index] = aValue;
	}
	_theValues = nil;
	_theValues = [[NSMutableData alloc] init];
	[_theValues appendBytes:data length:(sizeof(float)*count)];
    free(data);
    }
	return YES;
}

-(id)initFromSQL:(sqlite3 *)db forIndex:(int)index
{
	//NSLog(@"index: %i",index);
	if (!(self = [super init])) return nil;
	if(self)
	{
		sqlite3_stmt *stmt;
		NSString *theString;
		const char *pzMsg;
		NSString *command = [NSString stringWithFormat:@"SELECT * FROM _datasets WHERE _id=%i",index];
		sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzMsg);
		while(sqlite3_step(stmt)==SQLITE_ROW)
		{
			for(int i=0;i<6;i++)
			{
				theString = [NSString stringWithUTF8String:sqlite3_column_name(stmt,i)];
				
				if([theString isEqualToString:@"NAME"])
				{
					[self setName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)]];
					//NSLog([self name]);
				}
				else if([theString isEqualToString:@"TABLENAME"])
				{
					[self setTableName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)]];
					//NSLog(tableName);
				}
				else if([theString isEqualToString:@"COLUMNNAME"])
				{
					[self setColumnName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)]];
					//NSLog(columnName);
				}
				else if([theString isEqualToString:@"PREDICATE"])
				{
					char *aTextResult = (char *)sqlite3_column_text(stmt,i);
					if(aTextResult)
						[self setPredicate:[NSString stringWithUTF8String:aTextResult]];
				}
				else if([theString isEqualToString:@"COMMENTS"])
				{
					char *aTextResult = (char *)sqlite3_column_text(stmt,i);
					if(aTextResult)
						[self setComments:[[NSMutableAttributedString alloc] initWithRTF: decodeBase64([NSString stringWithUTF8String:aTextResult]) documentAttributes:nil  ]];
				}
			}
		}
		[self readSQLFromDB:db];
		return self;
	}
	return self;
}

#pragma mark Mutability

-(void)appendData:(NSData *)data
{
	[_theValues appendData:data];
}

-(void)appendDataFromFile:(NSString *)path encoding:(NSStringEncoding)encoding
{
	NSString *theContents = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:encoding];
	NSScanner *theScanner = [NSScanner scannerWithString:theContents];
	
	float aValue;
	_name = [path lastPathComponent];
	while(![theScanner isAtEnd])
	{
		[theScanner scanFloat:&aValue];
		
		if((aValue<=360.0)||(aValue>=0))
			[_theValues appendBytes:&aValue length:sizeof(float)];
	}
	
}

@end

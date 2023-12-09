//
//  XRDataSet.h
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

#import <Foundation/Foundation.h>
#import "XRoseDocument.h"
#import "sqlite3.h"
#define XRDataSetChangedStatisticsNotification @"XRDataSetChangedStatisticsNotification"

@class LITMXMLTree,XRStatistic;
@interface XRDataSet : NSObject {
	NSMutableData *_theValues;
	NSString *_name;
	NSMutableAttributedString *_comments;
	//statistics
	NSMutableArray *_circularStatistics;
	XRoseDocument *theDocument;
	NSString *predicate;
	NSString *tableName;
	NSString *columnName;

}


-(id)initWithTable:(NSString *)table column:(NSString *)column forDocument:(NSDocument *)aDoc;
-(id)initWithTable:(NSString *)table column:(NSString *)column forDocument:(NSDocument *)aDoc predicate:(NSString *)aPredicate;

//rewrite for SQL
-(int)valueCountFromAngle:(float)angle1 toAngle2:(float)angle2;
-(int)valueCountFromAngle:(float)angle1 toAngle2:(float)angle2 biDir:(BOOL)biDir;
-(NSString *)name;
-(void)setName:(NSString *)name;

-(void)setComments:(NSMutableAttributedString *)aString;
-(NSAttributedString *)comments;

-(NSData *)theData;

//persistent storage



//statistics
-(NSDictionary *)meanCountWithIncrement:(float)angleIncrement startingAngle:(float)startAngle isBiDirectional:(BOOL)isBiDir;
-(float)standardDeviation:(NSArray *)anArray mean:(float)mean;
-(NSArray *)calculateStatisticObjectsForBiDir:(BOOL)isBiDir startAngle:(float)startAngle sectorSize:(float)sectorSize;
-(NSArray *)calculateStatisticObjectsForBiDir:(BOOL)isBiDir;
-(NSArray *)currentStatistics;
-(XRStatistic *)currentStatisticWithName:(NSString *)name;
-(void)calculateNonSectorStatisticsForBiDirection:(BOOL)isBiDir;
-(void)computeXVector:(BOOL)isBiDir;
-(void)computeYVector:(BOOL)isBiDir;
-(XRStatistic *)calculateRayleighForRBar:(XRStatistic *)rbar;
-(XRStatistic *)calculateKappaForRBar:(XRStatistic *)rbar;
-(XRStatistic *)calculateAngleIntervalWithStandardError:(XRStatistic *)error;
-(XRStatistic *)calculateStandardErrorWithN:(int)n rbar:(XRStatistic *)rbar kappa:(XRStatistic *)kappa;

-(double)radiansFromDegrees:(double)degrees;
-(double)degreesFromRadians:(double)radians;


-(NSDictionary *)dataSetDictionary;
-(XRStatistic *)chiSquaredWithStartAngle:(float)startAngle sectorSize:(float)sectorSize isBiDir:(BOOL)isBiDir;
-(float)standardDeviationForIntArray:(int *)array count:(int)count expected:(float)expected;
-(NSString *)statisticsDescription;
-(NSString *)buildSQL;

//depreciate
-(id)initWithContentsOfASCIIFile:(NSString *)filePath encoding:(NSStringEncoding)encoding;
		  //-(id)initWithXMLTree:(LITMXMLTree *)aTree;
-(id)initWithData:(NSData *)theData withName:(NSString *)name;
-(void)appendData:(NSData *)data;
//-(id)initWithData:(NSData *)dataArray withName:(NSString *)name;
-(void)appendDataFromFile:(NSString *)path encoding:(NSStringEncoding)encoding;
	//load
-(id)initWithXMLTree:(LITMXMLTree *)aTree forVersion:(NSString *)version;//load from xml
-(id)initWithVersion1_0XMLTree:(LITMXMLTree *)aTree;//version 1.0/current version

	//save
-(LITMXMLTree *)treeForVersion:(NSString *)version;//create tree with current version (nil) or specified version
-(LITMXMLTree *)dataXMLDataVersion1_0;//verison 1.0/current version

-(void)saveToSQLDB:(sqlite3 *)db;
-(void)setPredicate:(NSString *)newPred;
-(NSString *)predicate;
-(void)setTableName:(NSString *)newTable;
-(NSString *)tableName;
-(void)setColumnName:(NSString *)newColumn;
-(NSString *)columnName;
-(id)initFromSQL:(sqlite3 *)db forIndex:(int)index;
-(BOOL)readSQL;
@end

//
//  XRLayerData.h
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

#import <Cocoa/Cocoa.h>
#import "XRLayer.h"

#define XRLayerDataPlotTypePetal 0
#define XRLayerDataPlotTypeHistogram 1
#define XRLayerDataPlotTypeDot 2
#define XRLayerDataPlotTypeDotDeviation 3
#define XRLayerDataPlotTypeKite 4

#define XRLayerDataDefaultKeyType @"XRLayerDataDefaultKeyType"
#define XRLayerDataStatisticsDidChange @"XRLayerDataStatisticsDidChange"
@class XRDataSet;
@interface XRLayerData : XRLayer {
	XRDataSet *_theSet;
	int _plotType;
	int _totalCount;
	float _dotRadius;
	
	NSMutableArray *_sectorValues;
	NSMutableArray *_sectorValuesCount;
	NSMutableArray *_statistics;
}
-(id)initWithGeometryController:(XRGeometryController *)aController withSet:(XRDataSet *)aSet;
-(id)initWithGeometryController:(XRGeometryController *)aController  withSet:(XRDataSet *)aSet dictionary:(NSDictionary *)configure;

-(id)initWithIsVisible:(BOOL)visible
              active:(BOOL)active
               biDir:(BOOL)isBiDir
                name:(NSString *)layerName
          lineWeight:(float)lineWeight
            maxCount:(int)maxCount
            maxPercent:(float)maxPercent
              plotType:(int)plotType
            totalCount:(int)totalCount
             dotRadius:(float)dotRadius;

-(void)setPlotType:(int)newType;
-(int)plotType;
-(void)calculateSectorValues;
-(int)totalCount;
-(void)setDotRadius:(float)radius;
-(float)dotRadius;


-(void)setStatisticsArray;
-(NSMutableArray *)statisticsArray;
-(XRDataSet *)dataSet;

-(LITMXMLTree *)xmlTreeForVersion1_0;
@end

//
//  XRStatistic.h
//  XRose
//
//  Created by Tom Moore on Fri Jan 30 2004.
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

#define XRStatN @"N"
#define XRStatUni @"Unidirectional Statistics"
#define XRStatXVector @"X Vector"
#define XRStatXVectorStandard @"X Vector Standarized" withFloatValue:_sumXVectorCBar
#define XRStatYVector @"Y Vector" withFloatValue:_sumYVector
#define XRStatYVectorStandard @"Y Vector Standarized"
#define XRStatResultLength @"Resultant Length (R)"
#define XRStatResultLengthMean @"Mean Resultant Length (R-Bar)"
#define XRStatMeanDirection @"Mean Direction" withFloatValue:_meanDirection];
#define XRStatCircularVarience @"Circular Varience" 



@interface XRStatistic : NSObject

@property (nonatomic) NSString *statisticName;
@property (nonatomic, getter = ASCIINameString) NSString *ASCIIName;
@property (nonatomic) NSString *valueString;




+(id)emptyStatisticWithName:(NSString *)name;
+(id)statisticWithName:(NSString *)name withFloatValue:(float)aValue;
+(id)statisticWithName:(NSString *)name withIntValue:(int)aValue;

-(void)setFloatValue:(float)aValue;
-(float)floatValue;
-(void)setIntValue:(int)aValue;
-(int)intValue;
@end

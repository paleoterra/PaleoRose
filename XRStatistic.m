//
//  XRStatistic.m
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

#import "XRStatistic.h"

@interface XRStatistic()

@property (readwrite) BOOL isEmpty;
@property (readwrite) BOOL isFloat;
@property (nonatomic) NSFormatter *aFormatter;
@property (nonatomic) NSNumber *value;

@end

@implementation XRStatistic


-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		_isEmpty = NO;
	}
	return self;
}
+(id)emptyStatisticWithName:(NSString *)name
{
	XRStatistic *aStat = [[XRStatistic alloc] init];
    aStat.statisticName = name;

	aStat.isEmpty = YES;
	return aStat;
}

+(id)statisticWithName:(NSString *)name withFloatValue:(float)aValue
{
	XRStatistic *aStat = [[XRStatistic alloc] init];
	aStat.statisticName = name;
	[aStat setFloatValue:aValue];
	return aStat;
}

+(id)statisticWithName:(NSString *)name withIntValue:(int)aValue
{
	XRStatistic *aStat = [[XRStatistic alloc] init];
	aStat.statisticName = name;
	[aStat setIntValue:aValue];

	return aStat;
}

-(NSString *)ASCIINameString
{
	if(_ASCIIName)
		return _ASCIIName;
	else
		return _statisticName;
}

-(void)setFloatValue:(float)aValue
{
	_isFloat = YES;
    _value = [NSNumber numberWithFloat:aValue];
	if(!_aFormatter)
		[self setValueString:[NSString stringWithFormat:@"%f",aValue]];
	else
		[self setValueString:[_aFormatter stringForObjectValue:[NSNumber numberWithFloat:aValue]]];
		
}

-(float)floatValue
{
	return [_value floatValue];
}
-(void)setIntValue:(int)aValue
{
	_isFloat = NO;
	_value = [NSNumber numberWithInt:aValue];
	if(!_aFormatter)
		[self setValueString:[NSString stringWithFormat:@"%i",aValue]];
	else
		[self setValueString:[_aFormatter stringForObjectValue:[NSNumber numberWithInt:aValue]]];
	
}

-(int)intValue
{
	return [_value intValue];
}

-(void)setFormatter:(NSFormatter *)formatter
{
	_aFormatter = formatter;
	if(_isFloat)
		[self setValueString:[_aFormatter stringForObjectValue:_value]];
	else
		[self setValueString:[_aFormatter stringForObjectValue:_value]];
}

-(void)setEmpty:(BOOL)isEmpty
{
	_isEmpty = isEmpty;
}
@end

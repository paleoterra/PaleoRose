//
//  LITMPercentFormatter.m
//  LITMAppKit
//
//  Created by Tom Moore on Mon Feb 23 2004.
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


#import "LITMPercentFormatter.h"


@implementation LITMPercentFormatter

-(NSString *) stringForObjectValue:(id)anObject
{
	if([anObject isKindOfClass:[NSNumber class]])
	{
		return [NSString stringWithFormat:@"%5.2f %c",[anObject floatValue]*100.0,'%'];
	}
	return [NSString stringWithFormat:@"0 %c",'%']; 
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	
	float result = 0.0;
	NSScanner *scanner = [NSScanner scannerWithString:string];
	
	if([scanner scanFloat:&result])
	{
		if(anObject)
			*anObject = [NSNumber numberWithFloat:result/100.0];
		return YES;
	}
	
	return NO;
}
@end

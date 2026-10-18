//
//  XRStatisticTests.m
//  PaleoRose
//
//  Created by Thomas Moore on 3/21/17.
//
// MIT License
//
// Copyright (c) 2017 to present Thomas L. Moore.
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

#import <XCTest/XCTest.h>
#import "XRStatistic.h"

@interface XRStatisticTests : XCTestCase

@property (nonatomic) XRStatistic *testObject;

@end

@implementation XRStatisticTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGeneralInitializer {
    NSString *name = @"Test Statistic";
    _testObject = [XRStatistic emptyStatisticWithName:name];
    
    XCTAssertTrue([name isEqualToString:_testObject.statisticName]);
    XCTAssertTrue([name isEqualToString:_testObject.ASCIIName]);
    XCTAssertNil(_testObject.valueString);
    
}

-(void)testGeneralInitializerWithFloat {
    NSString *name = @"Test Statistic";
    _testObject = [XRStatistic statisticWithName:name withFloatValue:27.5];
    
    XCTAssertTrue([name isEqualToString:_testObject.statisticName]);
    XCTAssertTrue([name isEqualToString:_testObject.ASCIIName]);
    XCTAssertTrue([_testObject.valueString isEqualToString:@"27.500000"]);

}

-(void)testGeneralInitializerWithInt {
    NSString *name = @"Test Statistic";
    _testObject = [XRStatistic statisticWithName:name withIntValue:154];
    
    XCTAssertTrue([name isEqualToString:_testObject.statisticName]);
    XCTAssertTrue([name isEqualToString:_testObject.ASCIIName]);
    XCTAssertTrue([_testObject.valueString isEqualToString:@"154"]);
}

-(void)testSettingFloatValues {
    NSString *name = @"Test Statistic";
    _testObject = [XRStatistic statisticWithName:name withFloatValue:27.5];
    
    XCTAssertTrue([_testObject.valueString isEqualToString:@"27.500000"]);
    
    [_testObject setFloatValue:88.2];
    XCTAssertEqualWithAccuracy([_testObject floatValue], 88.2,0.01);
    XCTAssertTrue([_testObject.valueString isEqualToString:@"88.199997"]);
    
    [_testObject setFloatValue:128.25];
    XCTAssertEqual([_testObject floatValue], 128.25);
    XCTAssertTrue([_testObject.valueString isEqualToString:@"128.250000"]);
    
    [_testObject setFloatValue:-128.25];
    XCTAssertEqual([_testObject floatValue], -128.25);
    XCTAssertTrue([_testObject.valueString isEqualToString:@"-128.250000"]);
}
@end

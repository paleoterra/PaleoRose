//
//  XRLayerDataTests.m
//  PaleoRose
//
//  Created by Thomas Moore on 3/18/17.
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
#import "sqlite3.h"
#import "XRLayerData.h"
#import "XRGeometryController.h"
#import "XRDataSet.h"

@interface XRLayerDataTests : XCTestCase

@property (readwrite) sqlite3 *file;

@property (nonatomic) XRGeometryController *mockController;
@property (nonatomic) XRDataSet *mockDataSet;

@end

@implementation XRLayerDataTests



//- (void)setUp {
//    [super setUp];
//
//    NSString *path = [[NSBundle bundleForClass:[self class] ] pathForResource:@"testset" ofType:@"XRose"];
//    sqlite3_open([path cStringUsingEncoding:NSUTF8StringEncoding], &_file);
//    _mockController = mock([XRGeometryController class]);
//
//}
//
//- (void)tearDown {
//    sqlite3_close(self.file);
//    self.file = NULL;
//    [super tearDown];
//}
//
//-(void)testCreationOfTheTestObject {
//    XRLayerData *testObject = [[XRLayerData alloc] initWithGeometryController:self.mockController withSet:_mockDataSet];
//    XCTAssertNotNil(testObject);
//}
//
//
//-(void)testXRLayerDataGetsNonNilResult {
//    XRLayerData *layer = [[XRLayerData alloc] init];
//    NSString *result = [layer getDatasetNameWithLayerID:1 fromDB:self.file];
//    XCTAssertNotNil(result);
//}
//
//-(void)testXRLayerDataGetsCorrectName {
//    XRLayerData *layer = [[XRLayerData alloc] init];
//    NSString *result = [layer getDatasetNameWithLayerID:1 fromDB:self.file];
//    XCTAssertTrue([result isEqualToString: @"dfgdf"]);
//}
@end

/* XRGeometryController */
//
// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
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

#define XRGeometryDidChange @"XRGeometryDidChange" //generic notification for any change in geometry
#define XRGeometryDidChangeIsPercent @"XRGeometryDidChangeIsPercent" //in this case, much has to be redrawn completely.. layers should pick this up
#define XRGeometryDidChangeSectors @"XRGeometryDidChangeSectors" //in this case, much has to be redrawn completely.. layers should pick this up

//defaults keys
#define XRGeometryDefaultKeyEqualArea @"XRGeometryDefaultKeyEqualArea"
#define XRGeometryDefaultKeyPercent @"XRGeometryDefaultKeyPercent"
#define XRGeometryDefaultKeySectorSize @"XRGeometryDefaultKeySectorSize"
#define XRGeometryDefaultKeyStartingAngle @"XRGeometryDefaultKeyStartingAngle"
#define XRGeometryDefaultKeyHollowCoreSize @"XRGeometryDefaultKeyHollowCoreSize"
#import "sqlite3.h"
@class LITMXMLTree;
@interface XRGeometryController : NSObject
{
    IBOutlet id _roseTableController;
	NSRect _mainRect;
	NSRect _circleRect;
	float _relativeSizeOfCircleRect;
	//geometry settings
	BOOL _isEqualArea; //should the calculations be area based?
	BOOL _isPercent; //should the counting be done by percents or by actual counts
	int _geometryMaxCount; //max scale for current geometry in counts
	float _geometryMaxPercent; //max scale for current geometry in percent
	float _hollowCoreSize; //size in percent of max circle size
	float _sectorSize;//should be set after data are loaded
	float _startingAngle;
	int _sectorCount;
	NSUndoManager *theUndoManager;
}

-(void)configureIsEqualArea:(BOOL)isEqualArea
                  isPercent:(BOOL)isPercent
                   maxCount:(int)maxCount
                 maxPercent:(float)maxPercent
                 hollowCore:(float)hollowCore
                 sectorSize:(float)sectorSize
              startingAngle:(float)startingAngle
                sectorCount:(int)sectorCount
               relativeSize:(float)relativeSize;

-(void)setRelativeSizeOfCircleRect:(float)percent;
-(float)relativeSizeOfCircleRect;

-(void)resetGeometryWithBoundsRect:(NSRect)newBounds;

//settings
//grid system
-(BOOL)isEqualArea;
-(void)setEqualArea:(BOOL)equal;
-(BOOL)isPercent;
-(void)setPercent:(BOOL)percent;
-(int)geometryMaxCount;
-(void)setGeomentryMaxCount:(int)newCount;
-(void)calculateGeometryMaxCount;
-(void)calculateGeometryMaxPercent;
-(float)geometryMaxPercent;
-(void)setGeomentryMaxPercent:(float)percent;
-(float)hollowCoreSize;
-(void)setHollowCoreSize:(float)newSize;
//sector system
-(float)startingAngle;
-(void)setStartingAngle:(float)angle;
-(float)sectorSize;
-(void)setSectorSize:(float)angle;
-(int)sectorCount;
-(void)setSectorCount:(int)count;
//geometry calculations
//trig
-(double)radiansFromDegrees:(double)degrees;
-(double)degreesFromRadians:(double)radians;
-(NSPoint)rotationOfPoint:(NSPoint)thePoint byAngle:(double)angle;
-(double)radiusOfRelativePercent:(double)percent;
-(double)unrestrictedRadiusOfRelativePercent:(double)percent;
-(double)unrestrictedRadiusOfRelativePercentNoCore:(double)percent;


//calculate radius for count or value
-(double)radiusOfCount:(int)count;
-(double)radiusOfPercentValue:(double)percent;

//calculations for circle rects
-(NSRect)circleRectForPercent:(float)percent;
-(NSRect)circleRectForGeometryPercent:(float)percent;
-(NSRect)circleRectForCount:(int)count;
-(NSRect)circleRectForHollowCore;

-(BOOL)angleIsValidForSpoke:(float)angle;

-(NSDictionary *)geometrySettings;
//-(void)configureController:(NSDictionary *)settings;
-(void)configureController:(LITMXMLTree *)settings forVersion:(NSString *)version; 
-(void)configureControllerForVersion1_0:(LITMXMLTree *)settings;

-(LITMXMLTree *)xmlTreeForVersion:(NSString *)version;
-(LITMXMLTree *)xmlTreeForVersion1_0;

-(void)calculateRelativePositionWithPoint:(NSPoint)target intoRadius:(float *)estimatedRadius intoAngle:(float *)estimatedAngle;

-(NSRect)drawingBounds;
@end

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

#import "XRGeometryController.h"
#import <math.h>
#import <sqlite3.h>
#import <PaleoRose-Swift.h>

@implementation XRGeometryController

+(void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjects:[NSArray arrayWithObjects:@"YES",
			[NSNumber numberWithFloat:.5],
			[NSNumber numberWithFloat:10.0],
			[NSNumber numberWithFloat:0.0],
			[NSNumber numberWithFloat:0.0],
			nil] 
					  forKeys:[NSArray arrayWithObjects:@"XRGeometryDefaultKeyEqualArea",
						  XRGeometryDefaultKeyPercent,
						  XRGeometryDefaultKeySectorSize,
						  XRGeometryDefaultKeyStartingAngle,
						  XRGeometryDefaultKeyHollowCoreSize,
						  nil]];
	
	[defaults registerDefaults:appDefaults];

	
}

-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		_relativeSizeOfCircleRect = 0.9;
		_isEqualArea = [[NSUserDefaults standardUserDefaults] boolForKey:XRGeometryDefaultKeyEqualArea];
		_isPercent = [[NSUserDefaults standardUserDefaults] boolForKey:XRGeometryDefaultKeyPercent];
		_sectorSize = [[NSUserDefaults standardUserDefaults] floatForKey:XRGeometryDefaultKeySectorSize];
		_startingAngle = [[NSUserDefaults standardUserDefaults] floatForKey:XRGeometryDefaultKeyStartingAngle];
		_geometryMaxCount = 10;//probably automatically resized
		_geometryMaxPercent = .3;//probably automatically resized
		_hollowCoreSize = 0.0;//probably automatically resized
		_sectorCount = 36;
		_circleRect = NSMakeRect(146.0,0.0,474.0,393.0);
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:self];
	}
	return self;
}

-(void)dealloc
{
	//[theUndoManager removeAllActionsWithTarget:self];
	theUndoManager = nil;
}

-(void)configureIsEqualArea:(BOOL)isEqualArea
                  isPercent:(BOOL)isPercent
                   maxCount:(int)maxCount
                 maxPercent:(float)maxPercent
                 hollowCore:(float)hollowCore
                 sectorSize:(float)sectorSize
              startingAngle:(float)startingAngle
                sectorCount:(int)sectorCount
               relativeSize:(float)relativeSize {
    _isPercent = isPercent;
    _isEqualArea = isEqualArea;
    _geometryMaxCount = maxCount;
    _geometryMaxPercent = maxPercent;
    _hollowCoreSize = hollowCore;
    _sectorSize = sectorSize;
    _startingAngle = startingAngle;
    _sectorCount = sectorCount;
    _relativeSizeOfCircleRect = relativeSize;
    [[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChange object:self];
}

-(void)setUndoManager:(NSUndoManager *)aManager
{
	theUndoManager = aManager;
}
-(void)setRelativeSizeOfCircleRect:(float)percent
{
	if((percent <= 1.0)&&(percent >0.0))
	{
		[theUndoManager registerUndoWithTarget:self selector:@selector(setRelativeSizeOfCircleRectWithNumber:) object:[NSNumber numberWithFloat:_relativeSizeOfCircleRect]];
		[theUndoManager setActionName:@" Plot Size"];
		_relativeSizeOfCircleRect = percent;
		[self resetGeometryWithBoundsRect:_mainRect];
		
	}
}

-(void)setRelativeSizeOfCircleRectWithNumber:(NSNumber *)aNumber
{
	[self setRelativeSizeOfCircleRect:[aNumber floatValue]];
}

-(float)relativeSizeOfCircleRect
{
	return _relativeSizeOfCircleRect;
}

-(void)resetGeometryWithBoundsRect:(NSRect)newBounds
{

	_mainRect = newBounds;
	_circleRect = NSInsetRect(_mainRect,_mainRect.size.width * (1.0 - _relativeSizeOfCircleRect),_mainRect.size.height * (1.0 - _relativeSizeOfCircleRect));
	NSLog(@"XRGeometryController: resetGeometryWithBoundsRect - mainRect=%@, circleRect=%@, posting XRGeometryDidChange", NSStringFromRect(_mainRect), NSStringFromRect(_circleRect));
	[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChange object:self];
}

-(BOOL)isEqualArea
{
	return _isEqualArea;
}

-(void)setEqualArea:(BOOL)equal
{
	if(_isEqualArea!=equal)
	{
		[theUndoManager registerUndoWithTarget:self selector:@selector(setEqualAreaWithNumber:) object:[NSNumber numberWithBool:_isEqualArea]];
		if(!_isEqualArea)
			[theUndoManager setActionName:@" Equal Area Rose"];
		else
			[theUndoManager setActionName:@" Linear Rose"];
		_isEqualArea = equal;
		[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChange object:self];
		
	}
}

-(void)setEqualAreaWithNumber:(NSNumber *)aNumber
{
	[self setEqualArea:[aNumber boolValue]];
}

-(BOOL)isPercent
{
	return _isPercent;
}

-(void)setPercent:(BOOL)percent
{
	if(_isPercent!=percent)
	{
		[theUndoManager registerUndoWithTarget:self selector:@selector(setPercentWithNumber:) object:[NSNumber numberWithBool:_isPercent]];
		if(!_isPercent)
			[theUndoManager setActionName:@"Percent Count"];
		else
			[theUndoManager setActionName:@"Number Count"];
		_isPercent = percent;
		[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChangeIsPercent object:self];
	}
}

-(void)setPercentWithNumber:(NSNumber *)aNumber
{
	[self setPercent:[aNumber boolValue]];
}

-(int)geometryMaxCount
{
	return _geometryMaxCount;
}

-(void)setGeomentryMaxCount:(int)newCount
{
	//NSLog(@"changed value: %i",newCount);
	if(_geometryMaxCount!=newCount)
	{
		[theUndoManager registerUndoWithTarget:self selector:@selector(setGeomentryMaxCountWithNumber:) object:[NSNumber numberWithInt:_geometryMaxCount]];
		[theUndoManager setActionName:@"Max Count"];
		_geometryMaxCount = newCount;
		[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChange object:self];
	}
}

-(void)setGeomentryMaxCountWithNumber:(NSNumber *)aNumber
{
	[self setGeomentryMaxCount:[aNumber intValue]];
}

-(void)calculateGeometryMaxCount
{
	LayersTableController *controller = (LayersTableController *)self.layersTableController;
	int result = [controller calculateGeometryMaxCount];
	if(result > 0)
		[self setGeomentryMaxCount:result];
}

-(void)calculateGeometryMaxPercent
{
	LayersTableController *controller = (LayersTableController *)self.layersTableController;
	float result = [controller calculateGeometryMaxPercent];
	if(result > 0.0)
		[self setGeomentryMaxPercent:result];
}

-(float)geometryMaxPercent
{
	//NSLog(@"geometryMaxPercent %f",_geometryMaxPercent);
	return _geometryMaxPercent;
}

-(void)setGeomentryMaxPercent:(float)percent
{
	if(_geometryMaxPercent!=percent)
	{
		[theUndoManager registerUndoWithTarget:self selector:@selector(setGeomentryMaxPercentWithNumber:) object:[NSNumber numberWithFloat:_geometryMaxPercent]];
		[theUndoManager setActionName:@"Max Percent"];
		_geometryMaxPercent = percent;
		[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChange object:self];
	}
}

-(void)setGeomentryMaxPercentWithNumber:(NSNumber *)aNumber
{
	[self setGeomentryMaxPercent:[aNumber floatValue]];
}

-(float)hollowCoreSize
{
	return _hollowCoreSize;
}

-(void)setHollowCoreSize:(float)newSize
{
	if(_hollowCoreSize!=newSize)
	{
		[theUndoManager registerUndoWithTarget:self selector:@selector(setHollowCoreSizeWithNumber:) object:[NSNumber numberWithFloat:_hollowCoreSize]];
		[theUndoManager setActionName:@"Hollow Core"];
		_hollowCoreSize = newSize;
		[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChange object:self];
	}
}

-(void)setHollowCoreSizeWithNumber:(NSNumber *)aNumber
{
	[self setHollowCoreSize:[aNumber floatValue]];
}

-(float)startingAngle
{
	return _startingAngle;
}

-(void)setStartingAngle:(float)angle
{
	[theUndoManager registerUndoWithTarget:self selector:@selector(setStartingAngleWithNumber:) object:[NSNumber numberWithFloat:_startingAngle]];
	[theUndoManager setActionName:@"Start Angle"];
	_startingAngle = angle;
	//NSLog(@"starting angle %f %f",_startingAngle,angle);
	//requires updating counts and percents
	[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChangeSectors object:self];
}

-(void)setStartingAngleWithNumber:(NSNumber *)aNumber
{
	[self setStartingAngle:[aNumber floatValue]];
}

-(float)sectorSize
{
	return _sectorSize;
}

-(void)setSectorSize:(float)angle
{
	[theUndoManager registerUndoWithTarget:self selector:@selector(setSectorSizeWithNumber:) object:[NSNumber numberWithFloat:_sectorSize]];
	[theUndoManager setActionName:@"Sector Size"];
	_sectorSize = angle;
	//requires updating everythign
	[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChangeSectors object:self];
}

-(void)setSectorSizeWithNumber:(NSNumber *)aNumber
{
	[self setSectorSize:[aNumber floatValue]];
}
-(int)sectorCount
{
	return _sectorCount;
}

-(void)setSectorCount:(int)count
{
	[theUndoManager registerUndoWithTarget:self selector:@selector(setSectorCountWithNumber:) object:[NSNumber numberWithFloat:_sectorCount]];
	[theUndoManager setActionName:@"Sector Count"];
	_sectorSize = 360.0/(float)count;
	_sectorCount = count;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRGeometryDidChangeSectors object:self];
}

-(void)setSectorCountWithNumber:(NSNumber *)aNumber
{
	[self setSectorCount:[aNumber floatValue]];
}
//geometry calculations

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

-(NSPoint)rotationOfPoint:(NSPoint)thePoint byAngle:(double)angle
{
	//page 251 CRC
	NSPoint shifted;
	double rotationAngle;
	double radians;
	//NSLog(@"rotationOfPoint: centroid %@  point %@",NSStringFromPoint(centroid),NSStringFromPoint(thePoint));

	rotationAngle = 360 - angle;
	radians = [self radiansFromDegrees:rotationAngle];
	shifted.x = (thePoint.x * cos(radians)) - (thePoint.y * sin(radians));
	shifted.y = (thePoint.x * sin(radians)) + (thePoint.y * cos(radians));
	//NSLog(@"centroid %@ start: %@ SHifted %@ rotated %@",NSStringFromPoint(centroid),NSStringFromPoint(thePoint),NSStringFromPoint(newPoint),NSStringFromPoint(shifted));

	return shifted;
}


-(double)radiusOfRelativePercent:(double)percent
{
	//this calculation exists to calculate the actual percentage.  Callers should estimate the percent of the largest value and send it to this method
	double hollowSqr = _hollowCoreSize * _hollowCoreSize;
	double percentRadius,relativeRadius,workPercent;
	double radius;
	workPercent = percent;
	if(workPercent>1.1)
		workPercent = 1.1;
	//double relativeRadius = ((1.0 - _hollowCoreSize) * percent)+(_hollowCoreSize);
	radius = (_circleRect.size.width / 2.0);//full circle radius in pixels
	if(_isEqualArea)
	{
		//double relativeRadius = ((1.0 - _hollowCoreSize) * percent)+(_hollowCoreSize);
		percentRadius = ((1.0- hollowSqr) * workPercent) + hollowSqr;
		relativeRadius = sqrt(percentRadius);
		radius = radius * relativeRadius;
										   
		
	}
	else
	{
		//in linear terms, simply subtract the hollow core from the radius, multiply it by percent, re-add core;

		percentRadius = ((1.0- hollowSqr) * workPercent) + hollowSqr;
		radius = radius * percentRadius;
	}
	//NSLog(@"percent %f radius %f core size %f", percent, radius,_hollowCoreSize);
	//NSLog(@"radius %f",radius);
	return radius;
}

-(double)unrestrictedRadiusOfRelativePercent:(double)percent
{
	//this calculation exists to calculate the actual percentage.  Callers should estimate the percent of the largest value and send it to this method
	double hollowSqr = _hollowCoreSize * _hollowCoreSize;
	double percentRadius,relativeRadius,workPercent;
	double radius;
	workPercent = percent;
	
	//double relativeRadius = ((1.0 - _hollowCoreSize) * percent)+(_hollowCoreSize);
	radius = (_circleRect.size.width / 2.0);//full circle radius in pixels
		if(_isEqualArea)
		{
			//double relativeRadius = ((1.0 - _hollowCoreSize) * percent)+(_hollowCoreSize);
			percentRadius = ((1.0- hollowSqr) * workPercent) + hollowSqr;
			relativeRadius = sqrt(percentRadius);
			radius = radius * relativeRadius;
			
			
		}
		else
		{
			//in linear terms, simply subtract the hollow core from the radius, multiply it by percent, re-add core;
			
			percentRadius = ((1.0- hollowSqr) * workPercent) + hollowSqr;
			radius = radius * percentRadius;
		}
		//NSLog(@"percent %f radius %f core size %f", percent, radius,_hollowCoreSize);
		//NSLog(@"radius %f",radius);
		return radius;
}

-(double)unrestrictedRadiusOfRelativePercentNoCore:(double)percent
{
	return (_circleRect.size.width / 2.0)*percent;
	
}

//calculate radius for count or value
-(double)radiusOfCount:(int)count
{
	//NSLog(@"radius of count %i",count);
	double relativePercent = (double)count/(double)_geometryMaxCount;//find the percent of max value
	double radius = [self radiusOfRelativePercent:relativePercent];
	//NSLog(@"result %f",radius);
	return radius;
}

-(double)radiusOfPercentValue:(double)percent
{
	double relativePercent = (double)percent/(double)_geometryMaxPercent;
	double radius = [self radiusOfRelativePercent:relativePercent];
	return radius;
}

//calculations for circle rects
-(NSRect)circleRectForPercent:(float)percent
{
	double radius = [self radiusOfRelativePercent:(percent/_geometryMaxPercent)];
	NSRect aRect;
	aRect.size = NSMakeSize((float)radius*2.0,(float)radius*2.0);
	//NSLog(NSStringFromRect(_circleRect));
	//NSLog(NSStringFromRect(aRect));
	aRect.origin = NSMakePoint(0.0 - ((float)radius),(0.0 - ((float)radius)));
	return aRect;
}

-(NSRect)circleRectForGeometryPercent:(float)percent
{
	double radius = [self radiusOfRelativePercent:percent];
	NSRect aRect;
	aRect.size = NSMakeSize((float)radius*2.0,(float)radius*2.0);
	//NSLog(NSStringFromRect(_circleRect));
	//NSLog(NSStringFromRect(aRect));
	aRect.origin = NSMakePoint(0.0 - ((float)radius),(0.0 - ((float)radius)));
	return aRect;
}

-(NSRect)circleRectForCount:(int)count
{
	double radius = [self radiusOfRelativePercent:((double)count/(double)_geometryMaxCount)];
	//NSLog(@"result %f",radius);
	NSRect aRect;
	aRect.size = NSMakeSize((float)radius*2.0,(float)radius*2.0);
	//NSLog(NSStringFromRect(aRect));
	aRect.origin = NSMakePoint(0.0 - ((float)radius),(0.0 - ((float)radius)));
	return aRect;
}

-(NSRect)circleRectForHollowCore
{
	NSRect aRect;
	double width = _circleRect.size.width * _hollowCoreSize;
	aRect.size = NSMakeSize(width,width);
	aRect.origin = NSMakePoint(width/2.0,width/2.0);
	return aRect;
}

-(BOOL)angleIsValidForSpoke:(float)angle
{
	if((double)floor((360.0/angle))  ==((double)(360.0/angle)))
		return YES;
	else
		return NO;
}

-(NSDictionary *)geometrySettings
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	
	if(_isEqualArea)
		[theDict setObject:@"YES" forKey:@"_isEqualArea"];
	else
		[theDict setObject:@"NO" forKey:@"_isEqualArea"];
	
	if(_isPercent)
		[theDict setObject:@"YES" forKey:@"_isPercent"];
	else
		[theDict setObject:@"NO" forKey:@"_isPercent"];
	
	[theDict setObject:[NSString stringWithFormat:@"%i",_geometryMaxCount] forKey:@"_geometryMaxCount"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_geometryMaxPercent] forKey:@"_geometryMaxPercent"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_hollowCoreSize] forKey:@"_hollowCoreSize"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_sectorSize] forKey:@"_sectorSize"];
	[theDict setObject:[NSString stringWithFormat:@"%f",_startingAngle] forKey:@"_startingAngle"];
	[theDict setObject:[NSString stringWithFormat:@"%i",_sectorCount] forKey:@"_sectorCount"];

	return [NSDictionary dictionaryWithDictionary:theDict];
}

-(void)calculateRelativePositionWithPoint:(NSPoint)target intoRadius:(float *)estimatedRadius intoAngle:(float *)estimatedAngle
{
	float tempRadius;
	//*estimatedAngle = [self degreesFromRadians:atan2(target.x,target.y)];
	//NSLog(@"%f %f",target.x,target.y);
	*estimatedAngle = [self degreesFromRadians:atan2(target.y,target.x)]*-1;
	tempRadius = sqrt((target.x*target.x) + (target.y*target.y));
	//NSLog(NSStringFromRect(_circleRect));
	*estimatedRadius = tempRadius/(_circleRect.size.width/2.0);
	
	//NSLog(@"relativePosition %f %f %f",*estimatedAngle,*estimatedRadius,(_circleRect.size.width/2.0));
}

-(NSRect)drawingBounds
{
	return _mainRect;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    XRGeometryController *rhs = other;
    if (_isEqualArea != [rhs isEqualArea]) {
        return false;
    }
    if (_isPercent != [rhs isPercent]) {
        return false;
    }
    if (!NSEqualRects(_mainRect, [rhs drawingBounds])) {
        return false;
    }
    if (_geometryMaxCount != rhs.geometryMaxCount) {
        return false;
    }
    if (_hollowCoreSize != rhs.hollowCoreSize) {
        return false;
    }
    if (_sectorSize != rhs.sectorSize) {
        return false;
    }
    if (_startingAngle != rhs.startingAngle) {
        return false;
    }
    if (_sectorCount != rhs.sectorCount) {
        return false;
    }
    if (_relativeSizeOfCircleRect != rhs.relativeSizeOfCircleRect) {
        return false;
    }
    return true;
}

@end

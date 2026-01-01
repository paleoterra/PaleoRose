//
//  XRLayerLineArrow.m
//  XRose
//
//  Created by Tom Moore on Sun Mar 14 2004.
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

#import "XRLayerLineArrow.h"
#import "XRDataSet.h"
#import "XRStatistic.h"
#import "XRGeometryController.h"
#import "PaleoRose-Swift.h"
#import <Cocoa/Cocoa.h>
@implementation XRLayerLineArrow

-(id)initWithGeometryController:(XRGeometryController *)aController withSet:(XRDataSet *)aSet
{
    if (!(self = [super initWithGeometryController:aController])) return nil;
    if(self)
    {
        _theSet = aSet; //note: not retained by this object
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statisticsDidChange:) name:XRDataSetChangedStatisticsNotification object:_theSet];
        if(aSet)
            [self setLayerName:[aSet name]];
        else
            [self setLayerName:@"unnamed"];
        [self setStrokeColor:[NSColor blackColor]];
        [self setFillColor:[NSColor blackColor]];

        _arrowSize = 1.0;
        _type = 0;
        _headType = 1;
        _showVector = YES;
        _showError = YES;
        [self generateGraphics];
    }
    return self;
}

-(id)initWithIsVisible:(BOOL)visible
                active:(BOOL)active
                 biDir:(BOOL)isBiDir
                  name:(NSString *)layerName
            lineWeight:(float)lineWeight
              maxCount:(int)maxCount
            maxPercent:(float)maxPercent
           strokeColor:(NSColor *)strokeColor
             fillColor:(NSColor *)fillColor
             arrowSize:(float)arrowSize
            vectorType:(int)vectorType
             arrowType:(int)arrowType
            showVector:(BOOL)showVector
             showError:(BOOL)showError
             datasetId:(int)datasetId {
    self = [super init];
    if (self) {
        _graphicalObjects = [[NSMutableArray alloc] init];
        _isVisible = visible;
        _isActive = active;
        _isBiDir = isBiDir;
        _layerName = layerName;
        _lineWeight = lineWeight;
        _maxCount = maxCount;
        _maxPercent = maxPercent;
        _strokeColor = strokeColor;
        _fillColor = fillColor;
        _arrowSize = arrowSize;
        _type = vectorType;
        _headType = arrowType;
        _showVector = showVector;
        _showError = showError;
        _datasetId = datasetId;
        _canFill = YES;
        _canStroke = YES;
        // Generate the color preview image for the table view
        [self resetColorImage];
    }
    return self;
}

-(void)setLayerName:(NSString *)layerName
{
    _layerName = [NSString stringWithFormat:@"Stat_%@",layerName];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(void)generateGraphics
{
    if (!_theSet) {
        return;
    }

    if (!geometryController) {
        return;
    }

    NSMutableDictionary *theDictionary = [[NSMutableDictionary alloc] init];
    float vector = 0.0;
    float radius;
    float radiusCore = 0.0;
    float vectorStrength = 0.0;
    float errorAngle = 0.0;
    ArrowHead *anArrow;
    NSBezierPath *aPath;
    NSArray *stats = [_theSet currentStatistics];
    NSEnumerator *anEnum = [stats objectEnumerator];
    XRStatistic *theStat;
    [_graphicalObjects removeAllObjects];
    while(theStat = [anEnum nextObject])
    {
        if([theStat.statisticName isEqualToString:[NSString stringWithUTF8String:"θ̅"]])
            vector = [theStat floatValue];
        if([theStat.statisticName isEqualToString:[NSString stringWithUTF8String:"R̅"]])
            vectorStrength = [theStat floatValue];
        if([theStat.statisticName isEqualToString:[NSString stringWithUTF8String:"θ̅± (95%)"]])
            errorAngle = [theStat floatValue];
    }
    switch(_type)
    {

        case 1://vector strength
        {
            radiusCore = [geometryController radiusOfRelativePercent:0.0];
            radius = [geometryController radiusOfRelativePercent:vectorStrength];
        }
            break;
        case 2://outer ring simple vector
        {
            radiusCore = [geometryController unrestrictedRadiusOfRelativePercent:1.05];
            radius = radiusCore + 30.0;

        }
            break;
        default://simple vector
        {
            radiusCore = [geometryController radiusOfRelativePercent:0.0];
            radius = [geometryController radiusOfRelativePercent:1.0];

        }
            break;
    }
    aPath = [NSBezierPath bezierPath];
    [aPath moveToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radiusCore) byAngle:vector]];
    [aPath lineToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radius) byAngle:vector]];
    [theDictionary setObject:aPath forKey:@"vector"];

    anArrow = [[ArrowHead alloc] initWithSize:_arrowSize color:_strokeColor type:_headType];

    [anArrow positionAtLineEndpoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radius) byAngle:vector] withAngle:vector];
    [theDictionary setObject:anArrow forKey:@"arrow"];
    [_graphicalObjects addObject:theDictionary];
    [self configureErrorWithVector:vector error:errorAngle];

    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)configureErrorWithVector:(float)vAngle error:(float)error
{
    NSBezierPath *errorPath = [NSBezierPath bezierPath];
    //NSLog(@"anglg %f error %f",vAngle,error);
    float radiusCore;
    float radius;
    float midRadius;
    float leftAngle = vAngle - error;
    float rightAngle = vAngle + error;
    if(vAngle > 180.0)
        return;
    if(leftAngle<0)
        leftAngle = 360+leftAngle;
    if(rightAngle >360)
        rightAngle = 360-rightAngle;
    radiusCore = [geometryController unrestrictedRadiusOfRelativePercent:1.05];
    radius = radiusCore+15;
    midRadius = radiusCore+7;
    [errorPath moveToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radiusCore) byAngle:leftAngle]];
    [errorPath lineToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radius) byAngle:leftAngle]];
    [errorPath moveToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radiusCore) byAngle:rightAngle]];
    [errorPath lineToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radius) byAngle:rightAngle]];

    [errorPath moveToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,midRadius) byAngle:rightAngle]];
    //NSLog(@"angles %f %f",leftAngle,rightAngle);
    rightAngle = 360 - rightAngle + 90;
    //NSLog(@"angles %f %f",leftAngle,rightAngle);
    while(rightAngle > 360.0)
        rightAngle = rightAngle-360.0;
    while(rightAngle < 0.00)
        rightAngle = 360.0+rightAngle;
    leftAngle = 360 - leftAngle + 90;
    //NSLog(@"angles %f %f",leftAngle,rightAngle);
    while(leftAngle < 0.0)
        leftAngle = 360.0+leftAngle;
    while(leftAngle > 360.0)
        leftAngle = leftAngle-360.0;
    //NSLog(@"*angles %f %f",leftAngle,rightAngle);
    [errorPath appendBezierPathWithArcWithCenter:NSMakePoint(0.0,0.0) radius:midRadius startAngle:rightAngle endAngle:leftAngle];
    if(errorPath)
        [_graphicalObjects addObject:errorPath];
}
-(void)drawRect:(NSRect)rect
{
    if (!_graphicalObjects || [_graphicalObjects count] == 0) {
        return;
    }

    [NSGraphicsContext saveGraphicsState];
    [_strokeColor set];

    if(_isVisible)
    {
        if(_showVector)
        {
            NSBezierPath *path;
            NSDictionary *dict = [_graphicalObjects objectAtIndex:0];

            if((path = [[_graphicalObjects objectAtIndex:0] objectForKey:@"vector"]))
            {
                [(NSBezierPath *)path setLineWidth:_lineWeight];
                [(NSBezierPath *)path stroke];
                [[dict objectForKey:@"arrow"] drawRect:rect];
            }
        }
        if((_showError)&&([_graphicalObjects count]>1))
        {
            NSBezierPath *path = [_graphicalObjects objectAtIndex:1];
            if(path)
            {
                [path setLineWidth:_lineWeight];
                [path stroke];
            }
        }
    }
    [NSGraphicsContext restoreGraphicsState];
}

-(void)setStrokeColor:(NSColor *)color
{
    _strokeColor = color;
    [self resetColorImage];
    //possibly post notification.
    for(int i=0;i<[_graphicalObjects count];i++)
    {
        if([[_graphicalObjects objectAtIndex:i] respondsToSelector:@selector(setColor:)])
            [[_graphicalObjects objectAtIndex:i] setColor:_strokeColor];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];

}

-(XRDataSet *)dataSet
{
    return _theSet;
}

-(void)statisticsDidChange:(NSNotification *)notification
{
    [self generateGraphics];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(void)setDataSet:(XRDataSet *)aSet
{
    _theSet = aSet;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statisticsDidChange:) name:XRDataSetChangedStatisticsNotification object:_theSet];
    [self generateGraphics];
}

-(NSString *)type
{
    return @"XRLayerLineArrow";
}

-(int)datasetId {
    // Return the stored dataset ID if we don't have a dataset reference yet
    // Otherwise return the actual dataset's ID
    if (_theSet) {
        return _theSet.setId;
    }
    return _datasetId;
}

-(float)arrowSize {
    return _arrowSize;
}

-(int)vectorType {
    return _type;
}

-(int)arrowType {
    return _headType;
}

-(BOOL)showVector {
    return _showVector;
}
-(BOOL)showError {
    return _showError;
}

@end

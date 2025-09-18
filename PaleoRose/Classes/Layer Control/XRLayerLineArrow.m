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
#import "sqlite3.h"
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
             showError:(BOOL)showError {
    self = [super init];
    if (self) {
        _isVisible = visible;
        _isActive = active;
        _isBiDir = isBiDir;
        _layerName = layerName;
        _lineWeight = lineWeight;
        _maxCount = maxCount;
        _maxPercent = maxPercent;
        _maxPercent = maxPercent;
        _strokeColor = strokeColor;
        _fillColor = fillColor;
        _arrowSize = arrowSize;
        _type = vectorType;
        _headType = arrowType;
        _showVector = showVector;
        _showError = showError;
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
    NSMutableDictionary *theDictionary = [[NSMutableDictionary alloc] init];
    float vector = 0.0;
    float radius;
    float radiusCore = 0.0;
    float vectorStrength = 0.0;
    float errorAngle = 0.0;
    ArrowHead *anArrow;
    NSBezierPath *aPath;
    NSEnumerator *anEnum = [[_theSet currentStatistics] objectEnumerator];
    XRStatistic *theStat;
    //NSLog(@"1");
    [_graphicalObjects removeAllObjects];
    //NSLog(@"2");
    while(theStat = [anEnum nextObject])
    {
        if([theStat.statisticName isEqualToString:[NSString stringWithUTF8String:"θ̅"]])
            vector = [theStat floatValue];
        if([theStat.statisticName isEqualToString:[NSString stringWithUTF8String:"R̅"]])
            vectorStrength = [theStat floatValue];
        if([theStat.statisticName isEqualToString:[NSString stringWithUTF8String:"θ̅± (95%)"]])
            errorAngle = [theStat floatValue];
    }
    //NSLog(@"3");
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
    //NSLog(@"4");
    aPath = [NSBezierPath bezierPath];
    [aPath moveToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radiusCore) byAngle:vector]];
    [aPath lineToPoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radius) byAngle:vector]];
    [theDictionary setObject:aPath forKey:@"vector"];

    //NSLog(@"5 %f %i",_arrowSize,_headType);
    anArrow = [[ArrowHead alloc] initWithSize:_arrowSize color:_strokeColor type:_headType];

    //NSLog(@"5.5 %f %f",radiusCore, radius);
    [anArrow positionAtLineEndpoint:[geometryController rotationOfPoint:NSMakePoint(0.0,radius) byAngle:vector] withAngle:vector];
    //NSLog(@"6");
    [theDictionary setObject:anArrow forKey:@"arrow"];
    [_graphicalObjects addObject:theDictionary];
    //NSLog(@"7");
    [self configureErrorWithVector:vector error:errorAngle];


    //[_graphicalObjects addObject:theDictionary];
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
    //NSLog(@"drawing arrowline %i",[_graphicalObjects count]);
    [NSGraphicsContext saveGraphicsState];
    [_strokeColor set];
    //NSLog([_strokeColor description]);
    if(_isVisible)
    {
        if(_showVector)
        {
            NSBezierPath *path;
            NSDictionary *dict = [_graphicalObjects objectAtIndex:0];

            if((path = [[_graphicalObjects objectAtIndex:0] objectForKey:@"vector"]))
            {
                //NSLog([path description]);
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

+(NSString *)classTag
{
    return @"VECTOR";
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

-(void)saveToSQLDB:(sqlite3 *)db layerID:(int)layerID
{
    NSString *showvector,*showerror;
    long long int datasetID;
    NSMutableString *command= [[NSMutableString alloc] init];
    int error;
    char *errorMsg;
    [super saveToSQLDB:db layerID:layerID];
    datasetID = [_theSet setId];

    if(_showVector)
        showvector = @"TRUE";
    else
        showvector = @"FALSE";
    if(_showError)
        showerror = @"TRUE";
    else
        showerror = @"FALSE";

    [command appendString:@"INSERT INTO _layerLineArrow (LAYERID,DATASET,ARROWSIZE,VECTORTYPE,ARROWTYPE,SHOWVECTOR,SHOWERROR) "];
    [command appendFormat:@"VALUES (%i,%i,%f,%i,%i,\"%@\",\"%@\") ",layerID,(int)datasetID,_arrowSize,_type,_headType,showvector,showerror];
    error = sqlite3_exec(db,[command UTF8String],nil,nil,&errorMsg);
    if(error!=SQLITE_OK)
        NSLog(@"error: %s",errorMsg);

    if(_theSet) {
        [_theSet saveToSQLDB:db];
    }

}

-(int)datasetId {
    return _theSet.setId;
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

-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db   layerID:(int)layerID
{
    if (!(self = [self initWithGeometryController:aController])) return nil;
    if(self)
    {
        [self setStrokeColor:[NSColor blackColor]];
        [self setFillColor:[NSColor blackColor]];

        _arrowSize = 1.0;
        _type = 0;
        _headType = 1;
        _showVector = YES;
        _showError = YES;

        [super configureWithSQL:db forLayerID:layerID];
        [self configureWithSQL:db forLayerID:layerID];
        [self generateGraphics];
    }
    return self;
}

-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid
{
    int columns;

    sqlite3_stmt *stmt;
    NSString *columnName;

    const char *pzTail;
    NSString *command = [NSString stringWithFormat:@"SELECT * FROM _layerLineArrow WHERE LAYERID=%i",layerid];
    //NSLog(@"Configuring with SQL");
    sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);

    while(sqlite3_step(stmt)==SQLITE_ROW)
    {
        columns = sqlite3_column_count(stmt);
        for(int i=0;i<columns;i++)
        {
            columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
            //NSLog(columnName);
            if([columnName isEqualToString:@"ARROWSIZE"])
                _arrowSize = (float)sqlite3_column_double(stmt,i);
            else if([columnName isEqualToString:@"VECTORTYPE"])
                _type = (int)sqlite3_column_int(stmt,i);
            else if([columnName isEqualToString:@"ARROWTYPE"])
                _headType = (float)sqlite3_column_double(stmt,i);
            else if([columnName isEqualToString:@"SHOWVECTOR"])
            {
                NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
                if([result isEqualToString:@"TRUE"])
                    _showVector = YES;
                else
                    _showVector = NO;
            }
            else if([columnName isEqualToString:@"SHOWERROR"])
            {

                NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
                if([result isEqualToString:@"TRUE"])
                    _showError = YES;
                else
                    _showError = NO;
            }
            /* note: data set information not loaded here.  It is loaded by the tablecontroller when using dataset name method below*/

        }
    }
    sqlite3_finalize(stmt);

}


-(NSString *)getDatasetNameWithLayerID:(int)layerID fromDB:(sqlite3 *)db
{
    int columns;

    sqlite3_stmt *stmt;
    NSString *columnName;
    NSString *datasetName;

    const char *pzTail;
    NSString *command = [NSString stringWithFormat:@"SELECT NAME FROM _datasets d, _layerLineArrow l where l.DATASET=d._id AND l.LAYERID=%i",layerID];
    //NSLog(@"Configuring with SQL");
    sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);

    while(sqlite3_step(stmt)==SQLITE_ROW)
    {
        columns = sqlite3_column_count(stmt);
        for(int i=0;i<columns;i++)
        {
            columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
            //NSLog(columnName);
            if([columnName isEqualToString:@"NAME"])
                datasetName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];

            /* note: data set information not loaded here.  It is loaded by the tablecontroller when using dataset name method below*/

        }
    }
    sqlite3_finalize(stmt);

    return datasetName;
}
@end

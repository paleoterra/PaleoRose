//
//  XRLayer.m
//  XRose
//
//  Created by Tom Moore on Sat Jan 24 2004.
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

#import "XRLayer.h"
#import "XRGeometryController.h"
#import "XRLayerCore.h"
#import "XRLayerGrid.h"
#import "XRLayerData.h"
#import "XRLayerText.h"
#import "XRLayerLineArrow.h"
#import "sqlite3.h"
#import <PaleoRose-Swift.h>

@implementation XRLayer

-(id)init {
    self = [super init];
    if(self) {
        _graphicalObjects = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];
        [self setStrokeColor:[NSColor blackColor]];
        [self setFillColor:[NSColor blackColor]];
        [self setIsVisible:YES];
        [self setIsActive:NO];
        _canFill = YES;
        _canStroke = YES;
    }
    return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		geometryController = aController;
		_graphicalObjects = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];
		[self setStrokeColor:[NSColor blackColor]];
		[self setFillColor:[NSColor blackColor]];
		[self setIsVisible:YES];
		[self setIsActive:NO];
		_canFill = YES;
		_canStroke = YES;
		
			}
	return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		NSColor *aColor;
		NSString *tempString;
		geometryController = aController;
		_graphicalObjects = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChange:) name:XRGeometryDidChange object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangePercent:) name:XRGeometryDidChangeIsPercent object:geometryController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geometryDidChangeSectors:) name:XRGeometryDidChangeSectors object:geometryController];
		if((aColor = [configure objectForKey:@"Stroke_Color"]))
			[self setStrokeColor:aColor];
		if((aColor = [configure objectForKey:@"Fill_Color"]))
			[self setFillColor:aColor];
		
		if((tempString = [configure objectForKey:@"Visible"]))
		{
			if([tempString isEqualToString:@"YES"])
				[self setIsVisible:YES];
			else
				[self setIsVisible:NO];
		}
		if((tempString = [configure objectForKey:@"Active"]))
		{
			if([tempString isEqualToString:@"YES"])
				[self setIsActive:YES];
			else
				[self setIsActive:NO];
		}
		
		if((tempString = [configure objectForKey:@"BIDIR"]))
		{
			if([tempString isEqualToString:@"YES"])
				_isBiDir = YES;
			else
				_isBiDir = NO;
		}
		
		if((tempString = [configure objectForKey:@"Layer_Name"]))
			_layerName = tempString;
		
		if((tempString = [configure objectForKey:@"Line_Weight"]))
			_lineWeight = [tempString floatValue];
		
		if((tempString = [configure objectForKey:@"Max_Count"]))
			_maxCount = [tempString floatValue];
		
		if((tempString = [configure objectForKey:@"Max_Percent"]))
			_lineWeight = [tempString floatValue];
		
		_canFill = YES;
		_canStroke = YES;
		
		 
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)isVisible
{
	return _isVisible;
}

-(void)setIsVisible:(BOOL)visible
{
	if(visible==_isVisible)
		return;
	_isVisible = visible;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(BOOL)isActive
{
	return _isActive;
}

-(void)setIsActive:(BOOL)active
{
	_isActive = active;//possibly change if needed a UI reaction
}

-(NSColor *)strokeColor
{
	return _strokeColor;
}

-(void)setStrokeColor:(NSColor *)color
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	_strokeColor = color;
	[self resetColorImage];
	//possibly post notification.
	while(aGraphic = [anEnum nextObject])
	{
		[aGraphic setStrokeColor:_strokeColor];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];

}

-(NSColor *)fillColor
{
	return _fillColor;
}

-(void)setFillColor:(NSColor *)color
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	Graphic *aGraphic;
	_fillColor = color;
	[self resetColorImage];
	//possibly post notification.
	while(aGraphic = [anEnum nextObject])
	{
        if([aGraphic respondsToSelector:@selector(setFillColor:)]) {
            [aGraphic setFillColor:_fillColor];
        }
	}
	//NSLog(@"set fill color %@",[[self class] description]);
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(NSString *)layerName
{
	return _layerName;
}

-(void)setLayerName:(NSString *)layerName
{
	_layerName = layerName;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(BOOL)isBiDirectional
{
	return _isBiDir;
}

-(void)setBiDirectional:(BOOL)isBiDir
{

	_isBiDir = isBiDir;
	//requires updating the counts and percents
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerInspectorRequiresReload object:self];
}

-(void)resetColorImage
{

	NSRect imageRect = NSMakeRect(0.0,0.0,16.0,16.0);
	_anImage = nil;
	_anImage = [[NSImage alloc] initWithSize:imageRect.size];
	//if(_anImage)
	//	NSLog([_anImage description]);
	//NSLog(@"reset image for object %@",[self layerName]);
	//NSLog(@"resetColorImage 1");
	NSBezierPath *aPath = [NSBezierPath bezierPathWithRect:imageRect];
	//NSLog(@"resetColorImage 1.1");
	[aPath setLineWidth:4.0];
	//NSLog(@"resetColorImage 1.2");
	[_anImage lockFocus];
	//NSLog(@"resetColorImage 1.3");
	[_strokeColor set];
	//NSLog(@"resetColorImage 1.4");
	[aPath stroke];
	//NSLog(@"resetColorImage 2");
	imageRect = NSInsetRect(imageRect,2.0,2.0);
	//NSLog(@"resetColorImage %i",[_graphicalObjects count]);
	if([_graphicalObjects count] > 0)
	{
		if([[_graphicalObjects objectAtIndex:0] respondsToSelector:@selector(drawsFill)] && [[_graphicalObjects objectAtIndex:0] drawsFill])
		{
			//NSLog(@"draws fill");
			[_fillColor set];
			aPath = [NSBezierPath bezierPathWithRect:imageRect];
			[aPath fill];
		}
	}
	//NSLog(@"resetColorImage 3");
	[_anImage unlockFocus];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];

	
		

}
-(NSImage *)colorImage
{
	return _anImage;
}

-(void)generateGraphics
{
	
}

-(void)drawRect:(NSRect)rect
{
}

-(void)geometryDidChange:(NSNotification *)notification
{
	
	[self generateGraphics];

	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)geometryDidChangePercent:(NSNotification *)notification
{
	[self generateGraphics];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)geometryDidChangeSectors:(NSNotification *)notification
{
	[self generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(int)maxCount
{
	return _maxCount;
}

-(float)maxPercent
{
	return _maxPercent;
}

-(void)setLineWeight:(float)lineWeight
{
	_lineWeight = lineWeight;
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(float)lineWeight
{
	return _lineWeight;
}

-(NSDictionary *)layerSettings
{
	NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
	//NSLog(@"standard layer");
	if([self isKindOfClass:[XRLayerCore class]])
		[aDict setObject:@"Core_Layer" forKey:XRLayerXMLType];
	else if([self isKindOfClass:[XRLayerData class]])
		[aDict setObject:@"Data_Layer" forKey:XRLayerXMLType];
	else if([self isKindOfClass:[XRLayerGrid class]])
		[aDict setObject:@"Grid_Layer" forKey:XRLayerXMLType];
	else
		[aDict setObject:@"Layer" forKey:XRLayerXMLType];
	
	if(_isVisible)
		[aDict setObject:@"YES" forKey:@"Visible"];
	else
		[aDict setObject:@"NO" forKey:@"Visible"];
	
	if(_isActive)
		[aDict setObject:@"YES" forKey:@"Active"];
	else
		[aDict setObject:@"NO" forKey:@"Active"];
	
	[aDict setObject:_layerName forKey:@"Layer_Name"];
	
	if(_isBiDir)
		[aDict setObject:@"YES" forKey:@"BIDIR"];
	else
		[aDict setObject:@"NO" forKey:@"BIDIR"];

	[aDict setObject:_strokeColor forKey:@"Stroke_Color"];

	[aDict setObject:_fillColor forKey:@"Fill_Color"];
	//NSLog(@"line weight %f",_lineWeight);
	[aDict setObject:[NSString stringWithFormat:@"%f",_lineWeight] forKey:@"Line_Weight"];
	[aDict setObject:[NSString stringWithFormat:@"%i",_maxCount] forKey:@"Max_Count"];
	[aDict setObject:[NSString stringWithFormat:@"%f",_maxPercent] forKey:@"Max_Percent"];
	//NSLog(@"end standard layer");
	return [NSDictionary dictionaryWithDictionary:aDict];
}

-(XRDataSet *)dataSet
{
	return nil;
}

+(NSString *)classTag
{
	return @"GENERIC";
}

-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db   layerID:(int)layerID 
{
	return nil;
}


-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db layerID:(int)layerID withParentView:(NSView *)parentView
{
	return nil;
}

+(id)layerWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db layerID:(int)layerid withParentView:(NSView *)parentView
{
	NSString *command = [NSString stringWithFormat:@"SELECT TYPE FROM _layers where LAYERID=%i",layerid];
	NSString *resultString;
	sqlite3_stmt *stmt;
	const char *pzTail;
	char *result;
	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	sqlite3_step(stmt);
	result = (char *)sqlite3_column_text(stmt,0);
	resultString = [NSString stringWithUTF8String:result];
	//NSLog(resultString);
	sqlite3_finalize(stmt);
	
	if([@"XRLayerLineArrow" isEqualToString:resultString])
		return [[XRLayerLineArrow alloc] initWithGeometryController:aController sqlDB:db layerID:layerid];
	else if([@"XRLayerCore" isEqualToString:resultString])
		return [[XRLayerCore alloc] initWithGeometryController:aController sqlDB:db layerID:layerid];
	else if([@"XRLayerData" isEqualToString:resultString])
		return [[XRLayerData alloc] initWithGeometryController:aController sqlDB:db layerID:layerid];
	else if([@"XRLayerGrid" isEqualToString:resultString])
		return [[XRLayerGrid alloc] initWithGeometryController:aController sqlDB:db layerID:layerid];
	else if([@"XRLayerText" isEqualToString:resultString])
		return [[XRLayerText alloc] initWithGeometryController:aController sqlDB:db layerID:layerid withParentView:parentView];
	else
		return nil;
	
	return nil;
}

-(void)setDataSet:(XRDataSet *)aSet
{
	return;
}

-(BOOL)handleMouseEvent:(NSEvent *)anEvent
{
	//NSLog(@"layer handle mouse down");
	return NO;
}

-(BOOL)hitDetection:(NSPoint)testPoint
{
	return NO;
}

-(void)saveToSQLDB:(sqlite3 *)db layerID:(int)layerID
{
	NSMutableString *command = [[NSMutableString alloc] init];
	
	long long int  rowIDOfFill = [self saveColor:[self fillColor] toSQLDB:db];
	long long int  rowIDOfStroke = [self saveColor:[self strokeColor] toSQLDB:db];
	NSString *visible,*active,*bidir;
	int error;
	char *errorMsg;

	if([self isVisible])
		visible = @"TRUE";
	else
		visible = @"FALSE";
	if([self isActive])
		active = @"TRUE";
	else
		active = @"FALSE";
	if([self isBiDirectional])
		bidir = @"TRUE";
	else
		bidir = @"FALSE";
	
	[command appendString:@"INSERT INTO _layers (LAYERID,TYPE,VISIBLE,ACTIVE,BIDIR,LAYER_NAME,LINEWEIGHT,MAXCOUNT,MAXPERCENT,STROKECOLORID,FILLCOLORID) "];
	[command appendFormat:@"VALUES (%i,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%f,%i,%f,%i,%i) ",layerID,[self type],visible,active,bidir,_layerName,_lineWeight,_maxCount,_maxPercent,(int)rowIDOfStroke,(int)rowIDOfFill];
	error = sqlite3_exec(db,[command UTF8String],nil,nil,&errorMsg);
	if(error!=SQLITE_OK)
		NSLog(@"error: %s",errorMsg);
}

-(long long int)saveColor:(NSColor *)aColor toSQLDB:(sqlite3 *)db
{
	
	CGFloat red,blue,green,alpha;
	int error;
	char *errorMsg;
	long long int result;
    NSColor *tempColor = [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	[tempColor getRed:&red green:&green blue:&blue alpha:&alpha];
	if(aColor==nil)
		return -1;
	
	NSString *insertCommand = [NSString stringWithFormat:@"INSERT INTO _colors (RED,BLUE,GREEN,ALPHA) VALUES (%f,%f,%f,%f)",red,blue,green,alpha];

	//step 1. check to see if the color is already present in the database
	result =[self findColorIDForColor:aColor  inDB:db];
	if(result>-1)
		return result;

	//If this point reached, this color does not exist in the database.  So add...
	error = sqlite3_exec(db,[insertCommand UTF8String],nil,nil,&errorMsg);
	if(error)
		NSLog(@"error: %s", errorMsg);
	else
		result = [self findColorIDForColor:aColor inDB:db];
	return result;
	
}

-(long long int)findColorIDForColor:(NSColor *)aColor inDB:(sqlite3 *)db
{
	CGFloat red,blue,green,alpha;
	int error;
    NSColor *tempColor = [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	const char *pzTail;
	sqlite3_stmt *stmt;
	long long int result;
	if(aColor==nil)
		return -1;
	[tempColor getRed:&red green:&green blue:&blue alpha:&alpha];
	NSString *searchCommand = [NSString stringWithFormat:@"SELECT COLORID FROM _colors WHERE  (RED=\"%f\" AND BLUE=\"%f\" AND GREEN=\"%f\" AND ALPHA=\"%f\")",red,blue,green,alpha];
	//NSLog(searchCommand);
	result = -1;
	error = sqlite3_prepare(db,[searchCommand UTF8String],-1,&stmt,&pzTail);
	if(error!=SQLITE_OK)
		NSLog(@"error: unknown");
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		int count = sqlite3_column_count(stmt);
		for(int i=0;i<count;i++)
		{
			NSString *resultString = [NSString stringWithUTF8String:sqlite3_column_name(stmt,i)];
			if([resultString isEqualToString:@"COLORID"])
			{
			result = sqlite3_column_int64(stmt,i);

			}
		}

	}
	sqlite3_finalize(stmt);

	return result;
	
}

//can be fill or stroke.  If isFill is no, then stroke
-(void)setColorFromDB:(sqlite3 *)db withIndex:(long long int)colorIndex isFill:(BOOL)isFill
{
	int columns;
	NSColor *aColor;
	float red = 0;
	float blue = 0;
	float green = 0;
	float alpha = 0;
	sqlite3_stmt *stmt;
	NSString *columnName;
	const char *pzTail;
	
	NSString *command = [NSString stringWithFormat:@"SELECT * FROM _colors WHERE COLORID=%i",(int)colorIndex];
	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		columns = sqlite3_column_count(stmt);
		for(int i=0;i<columns;i++)
		{
			columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
			if([columnName isEqualToString:@"RED"])
			{
				red = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"BLUE"])
			{
				blue = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"GREEN"])
			{
				green = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"ALPHA"])
			{
				alpha = (float)sqlite3_column_double(stmt,i);
			}
		}
		
	}
	//NSLog(@"%f %f %f %f %i",red,blue,green,alpha,colorIndex);
	aColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
	if(isFill)
		[self setFillColor:aColor];
	else
		[self setStrokeColor:aColor];
}

-(NSString *)type
{
	return @"XRLayer";
}

-(long long int)findDatasetIDByName:(NSString *)aName inSQLDB:(sqlite3 *)db
{
	const char *pzTail;
	sqlite3_stmt *stmt;
	long long int result;
	
	NSString *searchCommand = [NSString stringWithFormat:@"SELECT _id FROM _datasets where  NAME=\"%@\"",aName];;
	result = -1;

	sqlite3_prepare(db,[searchCommand UTF8String],-1,&stmt,&pzTail);
	while(sqlite3_step(stmt)!=SQLITE_DONE)
	{
		result = sqlite3_column_int64(stmt,0);
		
	}
	sqlite3_finalize(stmt);
	//NSLog(@"dataset1: %i",(int)result);
	return result;
	
}

-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid
{
	int columns;
	long long int  rowIDOfFill =-1;
	long long int  rowIDOfStroke=-1;
	sqlite3_stmt *stmt;
	NSString *columnName;
	const char *pzTail;
	NSString *command = [NSString stringWithFormat:@"SELECT * FROM _layers WHERE LAYERID=%i",layerid];
	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		columns = sqlite3_column_count(stmt);
		for(int i=0;i<columns;i++)
		{
			columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
			if([columnName isEqualToString:@"VISIBLE"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					[self setIsVisible:YES];
				else
					[self setIsVisible:NO];
			}
			else if([columnName isEqualToString:@"ACTIVE"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					[self setIsActive:YES];
				else
					[self setIsActive:NO];
			}
			else if([columnName isEqualToString:@"BIDIR"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					[self setBiDirectional:YES];
				else
					[self setBiDirectional:NO];
			}
			else if([columnName isEqualToString:@"LAYER_NAME"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				[self setLayerName:result];
			}
			else if([columnName isEqualToString:@"LINEWEIGHT"])
			{
				[self setLineWeight:(float)sqlite3_column_double(stmt,i)];
			
			}
			else if([columnName isEqualToString:@"MAXCOUNT"])
			{
				_maxCount = sqlite3_column_int(stmt,i);
			}
			else if([columnName isEqualToString:@"MAXPERCENT"])
			{
				_maxPercent = (float)sqlite3_column_double(stmt,i);
			}
			else if([columnName isEqualToString:@"STROKECOLORID"])
			{
				rowIDOfStroke = sqlite3_column_int64(stmt,i);
			}
			else if([columnName isEqualToString:@"FILLCOLORID"])
			{
				rowIDOfFill = sqlite3_column_int64(stmt,i);
			}
			

		}
	}
	//NSLog(@"%i %i",rowIDOfFill,rowIDOfStroke);
	if(rowIDOfFill>0)
		[self setColorFromDB:db withIndex:rowIDOfFill isFill:YES];
	if(rowIDOfStroke>0)
		[self setColorFromDB:db withIndex:rowIDOfStroke isFill:NO];
}

-(NSString *)getDatasetNameWithLayerID:(int)layerID fromDB:(sqlite3 *)db
{ 
	return nil;
}
@end

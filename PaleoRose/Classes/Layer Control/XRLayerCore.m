//
//  XRLayerCore.m
//  XRose
//
//  Created by Tom Moore on Thu Feb 05 2004.
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
#import "XRLayerCore.h"
#import "XRGraphic.h"
#import "XRGraphicCircle.h"
#import "XRGeometryController.h"
#import "sqlite3.h"
#import "LITMXMLTree.h"

@implementation XRLayerCore
//+(void)initialize
//{
//	[XRLayerCore setKeys:[NSArray arrayWithObject:@"_coreType"] triggerChangeNotificationsForDependentKey:@"coreRadiusIsEditable"];
//
//	[XRLayerCore setKeys:[NSArray arrayWithObjects:@"_strokeColor",@"_fillColor",nil] triggerChangeNotificationsForDependentKey:@"updateColors"];
//}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"coreRadiusIsEditable"]) {
        NSArray *affectingKeys = @[@"_coreType"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    else if ([key isEqualToString:@"updateColors"]) {
        NSArray *affectingKeys = @[@"_strokeColor",@"_fillColor"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

-(id)initWithGeometryController:(XRGeometryController *)aController
{
	if (!(self = [super initWithGeometryController:aController])) return nil;
	if(self)
	{
		if([aController hollowCoreSize]>0.0)
			_coreType = XRLayerCoreTypeHollow;
		else
			_coreType = XRLayerCoreTypeOverlay;
		
		_lineWeight = 1.0;
		_corePattern = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[XRLayerCore class]]pathForImageResource:@"hollowCorePattern"]];
		_percentRadius = 0.02;
		_canFill = YES;
		[self setStrokeColor:[NSColor blackColor]];
		[self setFillColor:[NSColor whiteColor]];
		[self setLayerName:@"Core"];
		[self generateGraphics];
		
	
		
	}
	return self;
}

-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure
{
	if (!(self = [super initWithGeometryController:aController dictionary:configure])) return nil;
	if(self)
	{
		NSArray *anArray;
		NSString *tempstring;
		
		if((tempstring = [configure objectForKey:XRLayerCoreXMLCoreType]))
		{
			if([tempstring isEqualToString:@"YES"])
				_coreType = YES;
			else
				_coreType = NO;
		}
		if((tempstring = [configure objectForKey:XRLayerCoreXMLCoreRadius]))
			_percentRadius = [tempstring floatValue];
		
		
		
		[self generateGraphics];
		if((anArray = [configure objectForKey:XRLayerGraphicObjectArray]))
		{
			//NSLog(@"configure core graphics");
		}

	}
	return self;
}


-(void)generateGraphics
{
	//NSLog(@"generating graphics");
	[_graphicalObjects removeAllObjects];
	if(!_coreType)
	{
		XRGraphicCircle * aCircle = [[XRGraphicCircle alloc] initWithController:geometryController];
		[aCircle setGeometryPercent:_percentRadius];
		[aCircle setDrawsFill:_canFill];
		[aCircle setStrokeColor:_strokeColor];
		[aCircle setFillColor:_fillColor];
		[_graphicalObjects addObject:aCircle];
	}
	else
	{
		
		XRGraphicCircle * aCircle = [[XRGraphicCircle alloc] initCoreCircleWithController:geometryController];
		NSImage *anImage = [[NSImage alloc] initWithSize:[_corePattern size]];
		NSColor *newColor;
		[anImage lockFocus];
		[_fillColor set];
		[[NSBezierPath bezierPathWithRect:NSMakeRect(0.0,0.0,[_corePattern size].width, [_corePattern size].height)] fill];
        [_corePattern drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0, 0.0, _corePattern.size.width, _corePattern.size.height) operation:NSCompositingOperationDestinationIn fraction:1.0];
		[anImage unlockFocus];
		newColor = [NSColor colorWithPatternImage:anImage];
		//newColor = [NSColor colorWithPatternImage:_corePattern];
		[aCircle setStrokeColor:_strokeColor];
		[aCircle setFillColor:newColor];
		[aCircle setDrawsFill:_canFill];
		[_graphicalObjects addObject:aCircle];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)drawRect:(NSRect)rect
{
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	XRGraphic *aGraphic;
	if(_isVisible)
	{
		while(aGraphic = [anEnum nextObject])
		{
			[aGraphic setLineWidth:_lineWeight];
			[aGraphic drawRect:rect];
		}
	}
}

-(BOOL)coreRadiusIsEditable
{
	return !_coreType;
}

-(NSDictionary *)layerSettings
{
	NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[super layerSettings]];
	NSMutableArray *theGraphics  = [[NSMutableArray alloc] init];
	NSEnumerator *anEnum = [_graphicalObjects objectEnumerator];
	XRGraphic *aGraphic;
	if(_coreType)
		[theDict setObject:@"YES" forKey:XRLayerCoreXMLCoreType];
	else
		[theDict setObject:@"NO" forKey:XRLayerCoreXMLCoreType];
	[theDict setObject:[NSString stringWithFormat:@"%f",_percentRadius] forKey:XRLayerCoreXMLCoreRadius];
	
	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addObject:[aGraphic graphicSettings]];
	}
	[theDict setObject:theGraphics forKey:XRLayerGraphicObjectArray];
	return [NSDictionary dictionaryWithDictionary:theDict];
}

+(NSString *)classTag
{
	return @"CORE";
}


-(LITMXMLTree *)xmlTreeForVersion:(NSString *)version
{
	NSString *currentVersion = @"1.0";
	if((version == nil)||([currentVersion isEqualToString:version]))
		return [self xmlTreeForVersion1_0];
	return nil;
}

-(LITMXMLTree *)xmlTreeForVersion1_0
{
	LITMXMLTree *rootTree = [self baseXMLTreeForVersion:@"1.0"];
	
	if(_coreType)
		[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:XRLayerCoreXMLCoreType attributes:nil attributeOrder:nil contents:@"YES"]];
	else
		[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:XRLayerCoreXMLCoreType attributes:nil attributeOrder:nil contents:@"NO"]];
	
	[rootTree addChild:[LITMXMLTree xmlTreeWithElementTag:XRLayerCoreXMLCoreRadius attributes:nil attributeOrder:nil contents:[NSString stringWithFormat:@"%f",_percentRadius]]];

	return rootTree;
}

-(id)initWithGeometryController:(XRGeometryController *)aController xmlTree:(LITMXMLTree *)configureTree forVersion:(NSString *)version
{
	if (!(self = [super initWithGeometryController:aController])) return nil;
	if(self)
	{
		
		[self configureBaseWithXMLTree:configureTree version:version];
		[self configureWithXMLTree:configureTree version:version];
		[self generateGraphics];
		return self;
	}
	return nil;
}

-(void)configureWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version
{
	NSString *currentVersion = @"1.0";
	if((version == nil)||([currentVersion isEqualToString:version]))
	{
		[self configureBaseWithXMLTree1_0:configureTree];
		[self configureWithXMLTree1_0:configureTree];
	}
	return;
}

-(void)configureWithXMLTree1_0:(LITMXMLTree *)configureTree
{
	NSString *content;
	if((content = [[configureTree findXMLTreeElement:XRLayerCoreXMLCoreType] contentsString]))
	{
		if([content isEqualToString:@"YES"])
			_coreType = YES;
		else
			_coreType = NO;

	}
	if((content = [[configureTree findXMLTreeElement:XRLayerCoreXMLCoreRadius] contentsString]))
		_percentRadius = [content intValue];

}

-(NSString *)type
{
	return @"XRLayerCore";
}

-(void)saveToSQLDB:(sqlite3 *)db layerID:(int)layerID
{
	NSString *coretype;
	NSMutableString *command= [[NSMutableString alloc] init];
	int error;
	char *errorMsg;
	[super saveToSQLDB:db layerID:layerID];

	
	if(_coreType)
		coretype = @"TRUE";
	else
		coretype = @"FALSE";
		
	[command appendString:@"INSERT INTO _layerCore (LAYERID,RADIUS,TYPE) "];
	[command appendFormat:@"VALUES (%i,%f,\"%@\") ",layerID,_percentRadius,coretype];
	error = sqlite3_exec(db,[command UTF8String],nil,nil,&errorMsg);
	if(error!=SQLITE_OK)
		NSLog(@"error: %s",errorMsg);
	
	
	
}

-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db   layerID:(int)layerID 
{
	if (!(self = [self initWithGeometryController:aController])) return nil;
	if(self)
	{
		[super configureWithSQL:db forLayerID:layerID];
		[self configureWithSQL:db forLayerID:layerID];
	}
	return self;
}

-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid
{
	int columns;
	//long long int  rowIDOfFill =-1;
	//long long int  rowIDOfStroke=-1;
	sqlite3_stmt *stmt;
	NSString *columnName;
	//NSString *ringFontName;
	//NSString *spokeFontName;
	//float ringFontSize,spokeFontSize;
	const char *pzTail;
	NSString *command = [NSString stringWithFormat:@"SELECT * FROM _layerCore WHERE LAYERID=%i",layerid];
	//NSLog(@"Configuring with SQL");
	sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		columns = sqlite3_column_count(stmt);
		for(int i=0;i<columns;i++)
		{
			columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
			//NSLog(columnName);
			if([columnName isEqualToString:@"TYPE"])
			{
				NSString *result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)];
				if([result isEqualToString:@"TRUE"])
					_coreType = YES;
				else
					_coreType = NO;
			}
			else if([columnName isEqualToString:@"RADIUS"])
				_percentRadius = (float)sqlite3_column_double(stmt,i);
		}
	}
	sqlite3_finalize(stmt);
	[self generateGraphics];
}
@end

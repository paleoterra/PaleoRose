//
//  XRLayer.h
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

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#define XRLayerRequiresRedraw @"XRLayerRequiresRedraw"
#define XRLayerTableRequiresReload @"XRLayerTableRequiresReload"
#define XRLayerInspectorRequiresReload @"XRLayerInspectorRequiresReload"

#define XRLayerXMLType @"Layer_Type"
#define XRLayerGraphicObjectArray @"Graphics"
@class XRGeometryController,XRDataSet,LITMXMLTree;
@interface XRLayer : NSObject {
	NSMutableArray *_graphicalObjects;
	BOOL _isVisible;
	BOOL _isActive;
	NSColor *_strokeColor;
	NSColor *_fillColor;
	NSString *_layerName;
	BOOL _isBiDir;
	float _lineWeight;
	int _maxCount;//should be set when sector size is set
	float _maxPercent;
	NSImage *_anImage;
	BOOL _canFill;
	BOOL _canStroke;
	__weak XRGeometryController *geometryController;
	//loose connection to the dataset
}

+(NSString *)classTag;

-(id)initWithGeometryController:(XRGeometryController *)aController;
-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure;
-(void)dealloc;


-(BOOL)isVisible;
-(void)setIsVisible:(BOOL)visible;
-(BOOL)isActive;
-(void)setIsActive:(BOOL)active;
-(NSColor *)strokeColor;
-(void)setStrokeColor:(NSColor *)color;
-(NSColor *)fillColor;
-(void)setFillColor:(NSColor *)color;
-(NSString *)layerName;
-(void)setLayerName:(NSString *)layerName;
-(BOOL)isBiDirectional;
-(void)setBiDirectional:(BOOL)isBiDir;
-(void)resetColorImage;
-(NSImage *)colorImage;
-(void)generateGraphics;
-(void)drawRect:(NSRect)rect;
//notification responses.. implemented by subclasses
-(void)geometryDidChange:(NSNotification *)notification;
-(void)geometryDidChangePercent:(NSNotification *)notification;
-(int)maxCount;
-(float)maxPercent;
-(void)setLineWeight:(float)lineWeight;
-(float)lineWeight;
-(void)setDataSet:(XRDataSet *)aSet;
-(XRDataSet *)dataSet;
-(NSDictionary *)layerSettings; 

//xml
-(LITMXMLTree *)baseXMLTreeForVersion:(NSString *)version;
-(LITMXMLTree *)baseXMLTree1_0;
-(id)initWithGeometryController:(XRGeometryController *)aController xmlTree:(LITMXMLTree *)configureTree forVersion:(NSString *)version;
+(id)layerWithGeometryController:(XRGeometryController *)aController xmlTree:(LITMXMLTree *)configureTree forVersion:(NSString *)version withParentView:(NSView *)parentView;

-(void)configureBaseWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version;
-(void)configureBaseWithXMLTree1_0:(LITMXMLTree *)configureTree;
-(void)configureWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version;
-(void)configureWithXMLTree1_0:(LITMXMLTree *)configureTree;

-(LITMXMLTree *)xmlTreeForVersion:(NSString *)version;


-(LITMXMLTree *)xmlTreeForVersion1_0;
-(BOOL)handleMouseEvent:(NSEvent *)anEvent;
-(BOOL)hitDetection:(NSPoint)testPoint;
-(NSString *)type;
-(void)saveToSQLDB:(sqlite3 *)db layerID:(int)layerID DEPRECATED_ATTRIBUTE;
-(long long int)saveColor:(NSColor *)aColor toSQLDB:(sqlite3 *)db DEPRECATED_ATTRIBUTE;
-(long long int)findColorIDForColor:(NSColor *)aColor inDB:(sqlite3 *)db DEPRECATED_ATTRIBUTE;
-(long long int)findDatasetIDByName:(NSString *)aName inSQLDB:(sqlite3 *)db DEPRECATED_ATTRIBUTE;
+(id)layerWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db layerID:(int)layerid withParentView:(NSView *)parentView DEPRECATED_ATTRIBUTE;
-(NSString *)getDatasetNameWithLayerID:(int)layerID fromDB:(sqlite3 *)db DEPRECATED_ATTRIBUTE;
-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid DEPRECATED_ATTRIBUTE;//
@end

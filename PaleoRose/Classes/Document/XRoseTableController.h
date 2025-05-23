/* XRoseTableController */
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
#define XRLayerDragType @"XRLayerDragType"
#import "sqlite3.h"
@class XRDataSet,LITMXMLTree,XRLayer;
@interface XRoseTableController : NSObject
{
	__weak IBOutlet id _rosePlotController;
    __weak IBOutlet id _roseTableView;
    __weak IBOutlet id _roseView;
    __weak IBOutlet id _windowController;
	NSArray *colorArray;
	NSMutableArray *_theLayers;
	NSTimer *_timer;

}

-(void)addDataLayerForSet:(XRDataSet *)aSet;
-(void)drawRect:(NSRect)rect;
-(void)detectLayerHitAtPoint:(NSPoint)point;
-(int)calculateGeometryMaxCount;
-(float)calculateGeometryMaxPercent;

-(void)displaySelectedLayerInInspector;

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation;
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation;
- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard;
-(void)moveLayers:(NSArray *)layerNumbers toRow:(int)row;
-(void)deleteLayersForTableName:(NSString *)aTableName;
-(void)setColorArray;


-(void)addCoreLayer:(id)sender;

-(BOOL)layerExistsWithName:(NSString *)aName;
-(NSString *)newLayerNameForBaseName:(NSString *)aName;
-(NSDictionary *)layersSettings;
-(void)configureController:(NSDictionary *)configureSettings;

-(NSArray *)dataLayerNames;
-(void)displaySheetForVStatLayer:(id)sender;

-(LITMXMLTree *)xmlTreeForVersion:(NSString *)version;

-(void)configureControllerWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version withDataSets:(NSArray *)datasets;

-(void)deleteLayer:(XRLayer *)aLayer;
-(XRLayer *)lastLayer;
-(void)handleMouseEvent:(NSEvent *)anEvent;
-(XRLayer *)activeLayerWithPoint:(NSPoint )aPoint;
-(NSString *)generateStatisticsString;
-(void)configureControllerWithSQL:(sqlite3 *)db withDataSets:(NSArray *)datasets  DEPRECATED_ATTRIBUTE;
-(void)saveToSQLDB:(sqlite3 *)db DEPRECATED_ATTRIBUTE;
@end

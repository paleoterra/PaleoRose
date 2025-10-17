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

#import "XRoseTableController.h"
#import "XRGeometryController.h"
#import "XRoseDocument.h"
#import "XRLayerData.h"
#import "XRLayer.h"
#import "XRoseView.h"
#import "XRLayerGrid.h"
#import "XRPropertyInspector.h"
#import "XRGridInspector.h"
#import "XRLayerCore.h"
#import "XRCoreInspector.h"
#import "XRDataSet.h"
#import "XRLayerLineArrow.h"
#import "XRVStatCreatePanelController.h"
#import "XRLayerText.h"
#import "sqlite3.h"

@interface XRoseTableController()

@property XRVStatCreatePanelController *aController;

@end

@implementation XRoseTableController

-(id)init {
    if (!(self = [super init])) return nil;
    if(self) {
        _theLayers = [[NSMutableArray alloc] init];
        [self setColorArray];
    }
    return self;
}


-(void)addDataLayerForSet:(XRDataSet *)aSet {
    static int colorNumber = 0;
    XRLayerData *thedatalayer  = [[XRLayerData alloc] initWithGeometryController:_rosePlotController withSet:aSet];
    [thedatalayer setStrokeColor:[colorArray objectAtIndex:colorNumber]];
    [thedatalayer setFillColor:[colorArray objectAtIndex:colorNumber]];
    
    if([self layerExistsWithName:[thedatalayer layerName]]) {
        [thedatalayer setLayerName:[self newLayerNameForBaseName:[thedatalayer layerName]]];
    }
    
    [_theLayers addObject:thedatalayer];
    
    colorNumber++;
    if(colorNumber==[colorArray count])
        colorNumber = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:thedatalayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:thedatalayer];
    [_roseTableView reloadData];
    [_roseView display];
}

-(void)layerRequestsReload:(NSNotification *)aNotification {
    [_roseTableView reloadData];
}

-(void)layerRequestsRedraw:(NSNotification *)notification {
    [_roseView display];
}

-(void)trigggerDrawing:(NSTimer *)timer {
    _timer = nil;
    [_roseView display];
}

-(void)drawRect:(NSRect)rect {
    NSEnumerator *anEnum = [_theLayers reverseObjectEnumerator];
    XRLayer *aLayer;
    
    while(aLayer = [anEnum nextObject]) {
        [aLayer drawRect:rect];
    } 
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [_theLayers count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    if([[aTableColumn identifier] isEqualToString:@"layerName"]) {
        return [[_theLayers objectAtIndex:rowIndex] layerName];
    } else if([[aTableColumn identifier] isEqualToString:@"layerColors"]) {
        return [[_theLayers objectAtIndex:rowIndex] colorImage];
    } else {
        if([[_theLayers objectAtIndex:rowIndex] isVisible]) {
            return [NSNumber numberWithInt:NSControlStateValueOn];
        }
        else
            return [NSNumber numberWithInt:NSControlStateValueOff];
    }
    return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    if([[aTableColumn identifier] isEqualToString:@"layerName"]) {
        [[_theLayers objectAtIndex:rowIndex] setLayerName:anObject];
    } else if([[aTableColumn identifier] isEqualToString:@"isVisible"]) {
        if([anObject intValue] == NSControlStateValueOn)
            [[_theLayers objectAtIndex:rowIndex] setIsVisible:YES];
        else
            [[_theLayers objectAtIndex:rowIndex] setIsVisible:NO];
        [_roseView display];
    }
}

-(void)awakeFromNib {
    XRLayerGrid *aGrid = [[XRLayerGrid alloc] initWithGeometryController:_rosePlotController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:aGrid];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:aGrid];
    
    [aGrid setLayerName:@"Default Grid"];
    [_theLayers addObject:aGrid];
    [_roseTableView registerForDraggedTypes:[NSArray arrayWithObject:XRLayerDragType]];
    [_roseTableView reloadData];
}

-(void)detectLayerHitAtPoint:(NSPoint)point {
    [[XRPropertyInspector defaultInspector] displayInfoForObject:_rosePlotController];
    for(int i=0;i<[_theLayers count];i++) {
        [_roseTableView deselectRow:i];
    }
}

-(int)calculateGeometryMaxCount {
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    int maxCount = -1;
    XRLayer *aLayer;
    while(aLayer = [anEnum nextObject]) {
        if([aLayer isKindOfClass:[XRLayerData class]]) {
            if(maxCount < [aLayer maxCount]) {
                maxCount = [aLayer maxCount];
            }
        }
    }
    return maxCount;
}

-(float)calculateGeometryMaxPercent {
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    float maxPercent = -1.0;
    XRLayer *aLayer;
    while(aLayer = [anEnum nextObject]) {
        if([aLayer isKindOfClass:[XRLayerData class]]) {
            if(maxPercent  < [aLayer maxPercent]) {
                maxPercent = [aLayer maxPercent];
            }
        }
    }
    return maxPercent;
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [self displaySelectedLayerInInspector];
}

-(void)displaySelectedLayerInInspector {
    if([_roseTableView numberOfSelectedRows]==0) {
        [[XRPropertyInspector defaultInspector] displayInfoForObject:nil];
    } else if([_roseTableView numberOfSelectedRows]>1) {
        [[XRPropertyInspector defaultInspector] displayInfoForObject:nil];
    } else {
        NSUInteger row = [_roseTableView selectedRow];
        for(int i=0;i<[_theLayers count];i++) {
            if(i==row) {
                [[_theLayers objectAtIndex:row] setIsActive:YES];
                [[XRPropertyInspector defaultInspector] displayInfoForObject:[_theLayers objectAtIndex:row]];
            }
            else
                [[_theLayers objectAtIndex:row] setIsActive:NO];
        }
    }
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
    
}

//drag and drop
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    if([info draggingSource] != _roseTableView)
        return NO;
    else {
        [self moveLayers:[[info draggingPasteboard] propertyListForType:XRLayerDragType] toRow:row];
        return YES;
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if([info draggingSource] != _roseTableView)
        return NSDragOperationNone;
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard {
    [pboard declareTypes:[NSArray arrayWithObject:XRLayerDragType] owner:self];
    [pboard setPropertyList:rows forType:XRLayerDragType];
    return YES;
}

-(void)moveLayers:(NSArray *)layerNumbers toRow:(int)row {
    NSMutableArray *anArray = [[NSMutableArray alloc] init];
    NSEnumerator *layers  = [layerNumbers reverseObjectEnumerator];
    NSNumber *layerNumber;
    
    while(layerNumber = [layers nextObject]) {
        [anArray insertObject:[_theLayers objectAtIndex:[layerNumber intValue]] atIndex:0];
        [_theLayers removeObjectAtIndex:[layerNumber intValue]];
    }
    for(int i=0;i<[anArray count];i++) {
        if((row+i)>=[_theLayers count])
            [_theLayers addObject:[anArray objectAtIndex:i]];
        else
            [_theLayers insertObject:[anArray objectAtIndex:i] atIndex:(row+i)];
    }
    
    [_roseTableView reloadData];
    [_roseView display];
}

-(void)setColorArray {
    NSMutableArray *anArray = [[NSMutableArray alloc] init];
    [anArray addObject:[NSColor blackColor]];
    [anArray addObject:[NSColor blueColor]];
    [anArray addObject:[NSColor brownColor]];
    [anArray addObject:[NSColor cyanColor]];
    [anArray addObject:[NSColor darkGrayColor]];
    [anArray addObject:[NSColor grayColor]];
    [anArray addObject:[NSColor greenColor]];
    [anArray addObject:[NSColor lightGrayColor]];
    [anArray addObject:[NSColor magentaColor]];
    [anArray addObject:[NSColor orangeColor]];
    [anArray addObject:[NSColor purpleColor]];
    [anArray addObject:[NSColor redColor]];
    [anArray addObject:[NSColor yellowColor]];
    colorArray = [NSArray arrayWithArray:anArray];
}

-(void)addCoreLayer:(id)sender {
    XRLayerCore *aCore = [[XRLayerCore alloc] initWithGeometryController:_rosePlotController];
    if([self layerExistsWithName:[aCore layerName]]) {
        [aCore setLayerName:[self newLayerNameForBaseName:[aCore layerName]]];
    }
    
    [_theLayers insertObject:aCore atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:aCore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:aCore];
    [_roseTableView reloadData];
    [_roseView display];
}

-(void)addGridLayer:(id)sender {
    XRLayerGrid *aGrid = [[XRLayerGrid alloc] initWithGeometryController:_rosePlotController];
    if([self layerExistsWithName:[aGrid layerName]]) {
        [aGrid setLayerName:[self newLayerNameForBaseName:[aGrid layerName]]];
    }
    [_theLayers insertObject:aGrid atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:aGrid];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:aGrid];
    [_roseTableView reloadData];
    [_roseView display];
}

-(void)addTextLayer:(id)sender {
    XRLayerText *aText = [[XRLayerText alloc] initWithGeometryController:_rosePlotController parentView:_roseTableView];
    if([self layerExistsWithName:[aText layerName]]) {
        [aText setLayerName:[self newLayerNameForBaseName:[aText layerName]]];
    }
    [_theLayers insertObject:aText atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:aText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:aText];
    [_roseTableView reloadData];
    [_roseView display];
}

-(void)deleteLayers:(id)sender {
    NSIndexSet *theSet = [_roseTableView selectedRowIndexes];
    NSMutableArray *dataSetArray = [[NSMutableArray alloc] init];
    NSEnumerator *anEnum;
    NSUInteger count = [_theLayers count]-1;
    
    XRLayer *aLayer;
    XRDataSet *aSet;
    BOOL remove;
    for(int i = (int)count; i > -1; i-- ) {
        if([theSet containsIndex:(unsigned int)i]) {
            aLayer = [_theLayers objectAtIndex:i];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:XRLayerTableRequiresReload object:aLayer];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:XRLayerRequiresRedraw object:aLayer];
            if([aLayer isKindOfClass:[XRLayerData class]]) {
                [dataSetArray addObject:[(XRLayerData *)aLayer dataSet]];//make sure data sets aren't deleted too soon
                [_theLayers removeObjectAtIndex:i];
                
            }
            else
                [_theLayers removeObjectAtIndex:i];
        }
    }
    count = [_theLayers count];//count of remaining layers
    
    for(int i= (int)count-1;i>-1;i--) {
        anEnum = [dataSetArray objectEnumerator];
        remove = NO;
        while(aSet = [anEnum nextObject]) {
            if(aSet == [[_theLayers objectAtIndex:i] dataSet])
                remove = YES;
        }
        if(remove) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:XRLayerTableRequiresReload object:[_theLayers objectAtIndex:i]];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:XRLayerRequiresRedraw object:[_theLayers objectAtIndex:i]];
            [_theLayers removeObjectAtIndex:i];
        }
    }
    anEnum = [dataSetArray objectEnumerator];
    while(aSet = [anEnum nextObject])
        [(XRoseDocument *)[_windowController document] removeDataSet:aSet];
    [_roseTableView reloadData];
    [_roseTableView deselectAll:self];
    [_roseView display];
}

-(void)deleteLayer:(XRLayer *)aLayer {
    [_theLayers removeObject:aLayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XRLayerTableRequiresReload object:aLayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XRLayerRequiresRedraw object:aLayer];
    [(XRoseDocument *)[_windowController document] removeDataSet:[aLayer dataSet]];
    
    [_roseTableView reloadData];
    
    [_roseView display];
}

-(void)deleteLayersForTableName:(NSString *)aTableName {
    NSMutableArray *anArray = [[NSMutableArray alloc] init];
    for(int i=0;i<[_theLayers count];i++) {
        if([[[[_theLayers objectAtIndex:i] dataSet] tableName] isEqualToString:aTableName])
            [anArray addObject:[_theLayers objectAtIndex:i]];
    }
    for(int i=0;i<[anArray count];i++) {
        [self deleteLayer:[anArray objectAtIndex:i]];
    }
}

-(XRLayer *)lastLayer {
    return [_theLayers lastObject];
}

-(BOOL)layerExistsWithName:(NSString *)aName {
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    XRLayer *aLayer;
    while(aLayer = [anEnum nextObject]) {
        if([[aLayer layerName] isEqualToString:aName])
            return YES;
    }
    return NO;
}

-(NSString *)newLayerNameForBaseName:(NSString *)aName {
    NSString *newName;
    int i = 1;
    do {
        newName = [aName stringByAppendingFormat:@"-%i",i];
        i++;
    } while([self layerExistsWithName:newName]);
    return newName;
}

-(NSDictionary *)layersSettings {
    NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *theArray = [[NSMutableArray alloc] init];
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    XRLayer *aLayer;
    while(aLayer = [anEnum nextObject]) {
        [theArray addObject:[aLayer layerSettings]];
    }
    [theDict setObject:theArray forKey:@"layers"];
    return [NSDictionary dictionaryWithDictionary:theDict];
}

-(void)configureController:(NSDictionary *)configureSettings {
    
}

-(NSArray *)dataLayerNames {
    NSMutableArray *anArray = [[NSMutableArray alloc] init];
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    XRLayer *aLayer;
    
    while(aLayer = [anEnum nextObject]) {
        if([aLayer isKindOfClass:[XRLayerData class]])
            [anArray addObject:[aLayer layerName]];
    }
    return [NSArray arrayWithArray:anArray];
}

-(XRLayer *)dataLayerWithName:(NSString *)name {
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    XRLayer *aLayer;
    
    while(aLayer = [anEnum nextObject]) {
        if(([aLayer isKindOfClass:[XRLayerData class]])&&([[aLayer layerName] isEqualToString:name]))
            return aLayer;
    }
    return nil;
}

-(void)displaySheetForVStatLayer:(id)sender
{
    NSArray *anArray = [self dataLayerNames];
    if([anArray count] >0) {
        
        self.aController = [[XRVStatCreatePanelController alloc] initWithArray:anArray];
        [[_windowController window]
         beginSheet:[self.aController window]
         completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSModalResponseOK) {
                XRLayer *theTargetLayer = [self dataLayerWithName:[self.aController selectedName]];
                [self->_theLayers addObject:[[XRLayerLineArrow alloc]initWithGeometryController:self->_rosePlotController withSet:[(XRLayerData *)theTargetLayer dataSet]]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:[self->_theLayers lastObject]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:[self->_theLayers lastObject]];
                [self->_roseTableView reloadData];
                [self->_roseView display];
            }
            self.aController = nil;
        }];
    }
}

-(void)configureControllerWithSQL:(sqlite3 *)db withDataSets:(NSArray *)datasets {
    NSMutableArray *anArray = [[NSMutableArray alloc] init];
    int k;
    const char *pzMsg;
    sqlite3_stmt *stmt;
    XRLayer *aLayer;
    sqlite3_prepare(db,"SELECT LAYERID FROM _layers ORDER BY LAYERID",-1,&stmt,&pzMsg);
    while(sqlite3_step(stmt)==SQLITE_ROW) {
        [anArray addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt,0)]];
    }
    sqlite3_finalize(stmt);
    
    [_theLayers removeAllObjects];
    [_roseTableView reloadData];
    for(int i=0;i <[anArray count];i++) {
        aLayer = [XRLayer layerWithGeometryController:_rosePlotController sqlDB:db layerID:[[anArray objectAtIndex:i] intValue] withParentView:_roseTableView];
        if([aLayer isKindOfClass:[XRLayerData class]]) {
            XRLayerData *dataLayer = (XRLayerData *)aLayer;
            NSString *name = [dataLayer getDatasetNameWithLayerID:i fromDB:db];
            
            for(int j= 0;j<[datasets count];j++) {
                k=-1;
                if([name isEqualToString:[[datasets objectAtIndex:j] name]]) {
                    k = j;
                    ;
                    [dataLayer  setDataSet:[datasets objectAtIndex:j]];
                    
                    j = (int)[datasets count];
                }
                if(k>-1) {
                    [_theLayers addObject:dataLayer];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:dataLayer];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:dataLayer ];
                }
            }
        }
        else if ([aLayer isKindOfClass:[XRLayerLineArrow class]]) {
            XRLayerLineArrow *arrowLayer = (XRLayerLineArrow *)aLayer;
            NSString *name = [arrowLayer  getDatasetNameWithLayerID:i fromDB:db];
            for(int j= 0;j<[datasets count];j++) {
                k=-1;
                if([name isEqualToString:[[datasets objectAtIndex:j] name]]) {
                    k = j;
                    [arrowLayer setDataSet:[datasets objectAtIndex:j]];
                    
                    j = (int)[datasets count];
                }
                if(k>-1) {
                    [_theLayers addObject:arrowLayer];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:arrowLayer];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:arrowLayer];
                }
            }
        }
        else {
            [_theLayers addObject:aLayer];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsReload:) name:XRLayerTableRequiresReload object:aLayer];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerRequestsRedraw:) name:XRLayerRequiresRedraw object:aLayer];
        }
    }
    [_roseTableView reloadData];
    [_roseView display];
}

-(void)handleMouseEvent:(NSEvent *)anEvent {
    for(int i=0;i<[_theLayers count];i++) {
        if([_roseTableView isRowSelected:i]) {
            if([(XRLayer *)[_theLayers objectAtIndex:i] handleMouseEvent:anEvent])
                break;
        }
    }
}

-(XRLayer *)activeLayerWithPoint:(NSPoint )aPoint {
    for(int i=0;i<[_theLayers count];i++) {
        if([_roseTableView isRowSelected:i]) {
            if([(XRLayer *)[_theLayers objectAtIndex:i] hitDetection:aPoint])
                return [_theLayers objectAtIndex:i];
        }
    }
    return nil;
}

-(NSString *)generateStatisticsString {
    NSEnumerator *anEnum = [_theLayers objectEnumerator];
    XRLayer *aLayer;
    NSMutableString *aString = [[NSMutableString alloc] init];
    while(aLayer = [anEnum nextObject]) {
        if([aLayer isKindOfClass:[XRLayerData class]]) {
            [aString appendFormat:@"\nData Set: %@\n",[aLayer layerName]];
            [aString appendString:[[(XRLayerData *)aLayer dataSet] statisticsDescription]];
            [aString appendFormat:@"\n\n"];
        }
    }
    return aString;
}

@end

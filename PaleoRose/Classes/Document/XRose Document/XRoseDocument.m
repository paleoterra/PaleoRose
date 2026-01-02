//
//  XRoseDocument.m
//  XRose
//
//  Created by Tom Moore on Fri Jan 23 2004.
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

#import "XRoseDocument.h"
#import "XRDataSet.h"
#import "XRoseWindowController.h"
#import "XRGeometryController.h"
#import "XRAppendDialogController.h"
#import "XREncodingAccessoryView.h"
#import "XRoseView.h"

#import "XRStatistic.h"
#import "PaleoRose-Swift.h"
#import <Security/Security.h>
#import <Security/AuthSession.h>
#import "XRTableImporter.h"
#import <os/activity.h>


@interface XRoseDocument() <DatasetColumnProvider>

@property (nonatomic) NSMutableArray *dataSets;

@property (nonatomic) NSObject *currentSheetController;
@property (nonatomic) XRTableImporter *tableImporter;

@property (nonatomic) NSMutableArray *tables;

@property (readwrite) DocumentModel* documentModel;
@property (readwrite) BOOL didLoad;

@property (weak, nonatomic) XRoseWindowController *mainWindowController;
@end

@implementation XRoseDocument

#pragma mark - Creating a Document Object

- (id)init
{
    self = [super init];
    if (self) {
		_dataSets = [[NSMutableArray alloc] init];
		_tables = [[NSMutableArray alloc] init];
        _tableImporter = [[XRTableImporter alloc] init];
        _documentModel = [[DocumentModel alloc] initInMemoryStore:[[InMemoryStore alloc] init] document:self];
        [self subscribeToDocumentModel];
        [self createDB];
        _didLoad = NO;
	}
    return self;
}

-(void)subscribeToDocumentModel {
    NSArray *keys = @[@"dataSets", @"layers"];
    for(int i = 0; i<[keys count]; i++) {
        [self.documentModel addObserver:self
                             forKeyPath:keys[i]
                                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial)
                                context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context {
    NSLog(@"Change Description");
    NSLog(@"%@", keyPath);
    NSLog(@"%@", [change description]);

    if([keyPath isEqualToString:@"tableNames"]) {
        [self discoverTables];
    }
}

#pragma mark - Reading the Document's Content

-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    if([typeName isEqualToString:@"XRose"])
    {
        NSError *error = nil;
        [self.documentModel openFile:url error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return NO;
        }
        self.didLoad = YES;
        return YES;
    }
    return NO;
}

#pragma mark - Writing the Document's Content
-(BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    NSError *error = nil;
    [self.documentModel storeWithGeometryController:[self.mainWindowController geometryController] error:&error];
    if (error != nil) {
        NSLog(@"Cannot store geometry: %@", [error localizedDescription]);
    }
    [self.documentModel setWindowSize:[self.mainWindowController window].frame.size error:&error];
    if (error != nil) {
        *outError = error;
        return NO;
    }

    [self.documentModel writeToFile:url error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return NO;
    }
    return YES;
}

#pragma mark - Getting Document Metadata

#pragma mark - Managing File Type Information

#pragma mark - Creating and Manageing Window Controllers

-(void)makeWindowControllers
{
    XRoseWindowController *aController = [[XRoseWindowController alloc] initWithWindowNibName:@"XRoseDocument"];
    [self addWindowController:aController];
    _mainWindowController = aController;
    _mainWindowController.documentModel = self.documentModel;
    [[NSNotificationCenter defaultCenter] addObserver:aController selector:@selector(importerCompleted:) name:@"XRTableListChanged" object:nil];
}

#pragma mark - Managing Document Windows

#pragma mark - Configuring the Autosave Behavior

#pragma mark - Autosaving the Document

#pragma mark - Managing Document Versions

#pragma mark - Storing Documents in iCloud

#pragma mark - Managing Undo and Redo Actions

#pragma mark - Updating the Document Change Count

#pragma mark - Handling Window Restoration

#pragma mark - Presenting a Save Panel

#pragma mark - Supporting User Activities

#pragma mark - Validating User Interface Items

#pragma mark - Performing Tasks Serially

#pragma mark - Handling User Actions

- (void)printDocument:(id)sender {
    [[NSPrintOperation printOperationWithView:[self.mainWindowController mainView] printInfo:[self printInfo]] runOperation];
}

#pragma mark - Closing the Document

#pragma mark - Reverting the Document Contents

#pragma mark - Duplicating the Document

#pragma mark - Renaming the Document

#pragma mark - Moving the Document

#pragma mark - Locking the Document

#pragma mark - Printing the Document

#pragma mark - Sharing the Document

#pragma mark - Handling Script Commands

#pragma mark - Displaying Errors to the User

- (NSError *)willPresentError:(NSError *)anError
{
    //NSLog(@"will present error");
    return anError;
}

- (BOOL)presentError:(NSError *)error
{
    if([super respondsToSelector:@selector(presentError:)])
        return [super presentError:error];
    else
        return NO;
}

#pragma mark - NSObject

// **** REFACTOR/MOVE
-(void)awakeFromNib
{
    NSError *error;
    if(self.didLoad) {
        [self loadDatasetsFromDB:[self.documentModel memoryStore]];
        [self.documentModel configureWithGeometryController:[self.mainWindowController geometryController] error:&error];
        if (error != nil) {
            NSLog(@"Error reading geometry: %@", [error localizedDescription]);
        }

        CGRect frame = [self.mainWindowController.window frame];
        frame.size = self.documentModel.windowSize;
        if (frame.size.width != 0) {
            [[self.mainWindowController window] setFrame:frame display:YES];
        }

        // NOTE: LayersTableController no longer uses SQLite configuration.
        // Layers are loaded from DocumentModel via Combine publishers.
    }
    else {

    }
    self.didLoad = NO;
}

#pragma mark - Accessors

-(sqlite3 *)documentInMemoryStore
{
    return [self.documentModel memoryStore];
}

// **** REFACTOR/MOVE
-(NSArray *)tableList
{
    return self.tables;
}

#pragma mark - PR Window Controller Delegate

// **** REFACTOR/MOVE
-(void)configureDocument
{
    NSError *error;
	if([self.documentModel memoryStore] != NULL)
	{
        CGRect frame = [self.mainWindowController.window frame];
        frame.size = [self.documentModel windowSize];
        if (frame.size.width != 0) {
            [[self.mainWindowController window] setFrame:frame display:YES];
        }
        [self.documentModel configureWithGeometryController:[self.mainWindowController geometryController] error:&error];
        if (error != nil) {
            NSLog(@"Error configuring document: %@", [error localizedDescription]);
        }

	}
	else
	{
		[self createDB];
	}
	[self.mainWindowController setTableList:self.tables];
	[self discoverTables];
}

// **** REFACTOR/MOVE
-(void)addDataLayer:(id)sender
{
    os_activity_initiate("add data layer", OS_ACTIVITY_FLAG_DEFAULT, ^{
        [self loadDataSet];
    });
}

// **** REFACTOR/MOVE
-(void)loadDataSet
{
    DatasetCreationSheet *controller = [[DatasetCreationSheet alloc] initWithTableArray:[self.documentModel dataTableNames]
                                                                          columnProvider:self];
    self.currentSheetController = controller;
    [[self.mainWindowController window]
     beginSheet:[controller window]
     completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {
            XRDataSet *aSet = [[XRDataSet alloc] initWithTable:[controller selectedTable]
                                                         column:[controller selectedColumn]
                                                             db:[self.documentModel memoryStore]];
            [aSet setName:[controller selectedName]];
            if(aSet)
            {
                [self.dataSets addObject:aSet];
                [self.mainWindowController.layersTableController addDataLayerFor:aSet];

                [self updateChangeCount:NSChangeDone];
            }

        }
        self.currentSheetController = nil;
    }];
}

#pragma mark Data Sets

// **** REFACTOR/MOVE
-(void)addDataSet:(XRDataSet *)aSet
{
    [self.dataSets addObject:aSet];
}

// **** REFACTOR/MOVE
-(void)removeDataSet:(XRDataSet *)aSet
{
    [self.dataSets removeObject:aSet];
}

// **** REFACTOR/MOVE
-(XRDataSet *)dataSetWithName:(NSString *)name
{
    NSEnumerator *anEnum = [self.dataSets objectEnumerator];
    XRDataSet *theSet;
    while(theSet = [anEnum nextObject])
    {
        if([[theSet name] isEqualToString:name])
            return theSet;
    }
    return nil;
}

// **** REFACTOR/MOVE
-(NSString *)FTestStatisticsForSetNames:(NSArray *)setNames biDirectional:(BOOL)isBiDir
{
    XRDataSet *tempSet1 = [self dataSetWithName:[setNames objectAtIndex:0]];
    XRDataSet *tempSet2 = [self dataSetWithName:[setNames objectAtIndex:1]];
    XRDataSet *set1,*set2,*set3;
    NSMutableString *aString = [[NSMutableString alloc] init];
    float R1,R2,Rp;
    float FStatistic,n;

    float kp;//kappa pooled
        FStatistic = 0;
    if(tempSet1)
        set1= [[XRDataSet alloc] initWithData:[tempSet1 theData] withName:[setNames objectAtIndex:0]];
    else
        return nil;
    if(tempSet2)
        set2= [[XRDataSet alloc] initWithData:[tempSet2 theData] withName:[setNames objectAtIndex:1]];
    else
        return nil;
    set3 = [[XRDataSet alloc] initWithData:[tempSet1 theData] withName:[NSString stringWithFormat:@"Test Set for %@ and %@",[setNames objectAtIndex:0],[setNames objectAtIndex:1]]];
    [set3 appendData:[tempSet2 theData]];
    //generate all the stats
    [set1 calculateStatisticObjectsForBiDir:isBiDir];
    [set2 calculateStatisticObjectsForBiDir:isBiDir];
    [set3 calculateStatisticObjectsForBiDir:isBiDir];
    [aString appendFormat:@"\nData Set: %@",[set1 name]];
    [aString appendFormat:@"\n%@",[set1 statisticsDescription]];
    [aString appendFormat:@"\nData Set: %@",[set2 name]];
    [aString appendFormat:@"\n%@",[set2 statisticsDescription]];
    [aString appendFormat:@"\nData Set: %@",[set3 name]];
    [aString appendFormat:@"\n%@",[set3 statisticsDescription]];
    kp = [[set3 currentStatisticWithName:[NSString stringWithUTF8String:"κ (est)"]] floatValue];
    n = (float)[[set3 currentStatisticWithName:@"N"] intValue];
    R1 = [[set1 currentStatisticWithName:[NSString stringWithUTF8String:"R"]] floatValue];
    R2 = [[set2 currentStatisticWithName:[NSString stringWithUTF8String:"R"]] floatValue];
    Rp = [[set3 currentStatisticWithName:[NSString stringWithUTF8String:"R"]] floatValue];
    if(kp >=10.0)
    {
        FStatistic = ((n - 2.0)*(R1 + R2 - Rp))/(n-R1-R2);

    }
    else if(kp>=2.0)
    {
        FStatistic = (1 + (3/(8*kp)))*((n - 2.0)*(R1 + R2 - Rp))/(n-R1-R2);
        //NSLog(@"%f %f %f %f %f",FStatistic,kp,R1,R2,Rp);
    }
    if(kp<2.0)
        [aString appendFormat:@"\n%@",@"F-Statistic: Not Calculable.  Kappa below 2"];
    else
        [aString appendFormat:@"\n%@",[NSString stringWithFormat:@"F-Statistic: \t%f \tdf1: = 1\tdf2 = %i",FStatistic,(int)n-2]];

    return aString;
}

#pragma mark - SQLITE CRUD

// **** REFACTOR/MOVE
-(void)createDB
{
    NSError *error = nil;
    if([[self windowControllers] count]) {
        [self.documentModel setWindowSize:[self.mainWindowController window].frame.size error:&error];
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        [self.documentModel storeWithGeometryController:[self.mainWindowController geometryController] error:&error];
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
    }
}

// **** REFACTOR/MOVE
-(void)datasetsRenameTable:(NSString *)oldName toName:(NSString *)newName
{
    NSEnumerator *anEnum = [self.dataSets objectEnumerator];
    XRDataSet *aSet;
    while(aSet = [anEnum nextObject])
    {
        if([[aSet tableName] isEqualToString:oldName])
            [aSet setTableName:newName];
    }
}

// **** REFACTOR/MOVE
-(NSArray *)retrieveNonTextColumnNamesFromTable:(NSString *)aTableName
{
    NSError *error = nil;
    NSArray *columns = [self.documentModel possibleColumnNamesWithTable:aTableName error:&error];
    if (error != nil) {
        [self presentError:error];
         return nil;
    }
    return columns;
}

#pragma mark - DatasetColumnProvider

- (NSArray<NSString *> *)numericColumnsForTable:(NSString *)tableName
{
    NSArray *columns = [self retrieveNonTextColumnNamesFromTable:tableName];
    return columns ?: @[];
}

// **** REFACTOR/MOVE
-(void)discoverTables
{
    [self.tables removeAllObjects];
    [self.tables addObjectsFromArray:[self.documentModel dataTableNames]];
    [self.mainWindowController updateTable];
}

// **** REFACTOR/MOVE
-(void)loadDatasetsFromDB:(sqlite3 *)db
{
    self.dataSets = [[NSMutableArray alloc] initWithArray: self.documentModel.dataSets];
}

#pragma mark Importing Data

// **** RESEARCH
-(void)importTable:(id)sender
{
    //NSLog(@"in importTable");
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowsMultipleSelection:NO]; //this should change as the code matures
    [op setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", nil]];
    [op beginSheetModalForWindow:[self.mainWindowController window] completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK)
        {
            NSEnumerator *anEnum = [[op URLs] objectEnumerator];
            NSString *aPath;
            while((aPath = [[anEnum nextObject] path]))
            {
                [op close];
                [self.tableImporter importTableFromFile:aPath forDocument:self] ;
                //NSLog(@"***back at document***");
                [self.mainWindowController updateTable];


            }
        }
    }];
}

#pragma mark Print Operation Delegate

- (void)printOperationDidRun:(NSPrintOperation *)printOperation
					 success:(BOOL)success
				 contextInfo:(void *)info {
    if (success) {
        // Can save updated NSPrintInfo, but only if you have
        // a specific reason for doing so
        // [self setPrintInfo: [printOperation printInfo]];
    }
}

@end
